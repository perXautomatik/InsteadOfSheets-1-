with filterBadAdress as (
    select (SELECT master.dbo.FracToDec(andel)) 'fra',
           FNR,
           BETECKNING,
           ärndenr 'arndenr',
           Namn,
           Adress,
           POSTNUMMER,
           postOrt,
           PERSORGNR
    from tempExcel.dbo.InputPlusGeofir
),

filterSmallOwnersBadAdress as (
select fra,
       POSTORT,
       POSTNUMMER,
       ADRESS,
       NAMN,
       BETECKNING,
       arndenr
    ,PERSORGNR,
       RowNum
from (select fra,
             POSTORT,
             POSTNUMMER,
             ADRESS,
             NAMN,
             BETECKNING,
             arndenr,
            PERSORGNR,
             RowNum
      from (select q.fra,
                   q.POSTORT,
                   q.POSTNUMMER,
                   q.ADRESS,
                   q.NAMN,
                   q.BETECKNING,
                   q.arndenr,
                   q.PERSORGNR,
                   ROW_NUMBER() OVER ( PARTITION BY q.arndenr ORDER BY q.fra desc) RowNum
            from filterBadAdress as q
                     INNER JOIN filterBadAdress thethree ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X
      WHERE X.RowNum = 1) as asdasd
union
select *
from (select *
      from (select q.fra,
                   q.POSTORT,
                   q.POSTNUMMER,
                   q.ADRESS,
                   q.NAMN,
                   q.BETECKNING,
                   q.arndenr,
                   q.PERSORGNR,
                   ROW_NUMBER() OVER ( PARTITION BY q.arndenr ORDER BY q.fra desc ) RowNum
            from filterBadAdress as q
                     INNER JOIN filterBadAdress thethree ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X
      WHERE X.RowNum > 1
        and X.RowNum < 4
        AND fra > 0.3) as asdasdx)

select * from filterSmallOwnersBadAdress where postOrt = '' order by arndenr, RowNum