with
    input as (SELECT ärndenr,* from tempExcel.dbo.årsPåm2019Compl),
    Query4 as (select Fastighet,* FROM tempExcel.dbo.Query4),
    QVC as (select ärndenr,ANDEL,POSTORT,adress,POSTNUMMER,value,ärendenr,NAMN, BETECKNING,* from master.dbo.qxg),

    q as (select ANDEL, POSTORT, POSTNUMMER,
                (select * from string_split(ADRESS,',')) as correctedAdress, (select ress from (select trim(ressWithSpaces) as ress from (SELECT value as ressWithSpaces FROM qvc CROSS APPLY STRING_SPLIT(adress, ',') GROUP BY value) soki) asd  where not (ress = POSTORT OR ress = try_cast(POSTNUMMER as varchar))) as adress,
                  NAMN, BETECKNING, qvc.ärendenr ärndenr from qvc
                union select
	       ANDEL, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, ärndenr
            from (select POSTORT,POSTNUMMER,ADRESS,NAMN,andel,Query4.Fastighet as BETECKNING,ärndenr from input I join Query4 on Query4.Fastighet = I.Fastighet) as å),

     rs as (select ANDEL as justForVisual
                    , POSTORT, POSTNUMMER, ADRESS, NAMN,
                   (select top 1 namn
                    from q as x
                    where x.BETECKNING = q.BETECKNING
                      AND x.ADRESS = q.ADRESS
                      and x.NAMN <> q.NAMN) as Namn2
                    , BETECKNING, ärndenr from q),
--removes dupes, by comparing strings and combining them in sorted order
tz as (select *
        from (SELECT master.dbo.FracToDec(justForVisual) as fra,justForVisual,
                     POSTORT, POSTNUMMER, ADRESS, NAMN, Namn2, BETECKNING, ärndenr,
                     ROW_NUMBER() OVER (PARTITION BY
                         (case when rs.Namn2 is not null then  case   when rs.NAMN > rs.namn2 then  rs.NAMN + rs.Namn2  else rs.Namn2 + rs.NAMN end
                              else rs.NAMN end)
                         ORDER BY BETECKNING,ADRESS
                         ) As rn
              FROM rs) t
        where t.rn = 1),

zq as (select fra, justForVisual, POSTORT, POSTNUMMER, ADRESS, NAMN, Namn2, BETECKNING,
       ärndenr,ROW_NUMBER() OVER (PARTITION BY BETECKNING ORDER BY fra desc) As rn
from tz),

Andelar as (select POSTORT,
              POSTNUMMER,
              ADRESS,
              NAMN,
              Namn2,
              BETECKNING,
              ärndenr
       from zq
where rn < 4 AND fra > 0.3333 and POSTORT is not null and POSTNUMMER is not null and ADRESS is not null and NAMN  is not null),


qz2 as (select POSTORT,
              POSTNUMMER,
              ADRESS,
              NAMN,
              Namn2,
              BETECKNING,
              ärndenr
       from zq
where POSTORT is not null and POSTNUMMER is not null and ADRESS is not null and NAMN  is not null)

