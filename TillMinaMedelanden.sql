with filterBadAdress as (
    select (SELECT master.dbo.FracToDec(andel)) 'fra',
           CAST(FNR AS int)             as      FNR,
           CAST(BETECKNING AS nvarchar) as      BETECKNING,
           CAST(ärndenr AS nvarchar)            'arndenr',
           CAST(Namn AS nvarchar)       as      Namn,
           CAST(Adress AS nvarchar)     as      Adress,
           CAST(POSTNUMMER AS nvarchar) as      POSTNUMMER,
           CAST(postOrt AS nvarchar)    as      postOrt,
           CAST(PERSORGNR AS nvarchar)  as      PERSORGNR
    from
         --tempExcel.
        dbo.Generator_InputPlusGeofir
),
     filterSmallOwnersBadAdress as (
         select fra,
                POSTORT,
                POSTNUMMER,
                ADRESS,
                NAMN,
                BETECKNING,
                arndenr,
                PERSORGNR,
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
                              INNER JOIN filterBadAdress thethree
                                         ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X
               WHERE X.RowNum = 1 AND postOrt <> '' AND POSTNUMMER <> '' AND Adress <> '' AND Namn is not null) as asdasd
         union
         select fra,
                POSTORT,
                POSTNUMMER,
                ADRESS,
                NAMN,
                BETECKNING,
                arndenr,
                PERSORGNR,
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
                            ROW_NUMBER() OVER ( PARTITION BY q.arndenr ORDER BY q.fra desc ) RowNum
                     from filterBadAdress as q
                              INNER JOIN filterBadAdress thethree
                                         ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X
               WHERE X.RowNum > 1
                 and X.RowNum < 4
                 AND fra > 0.3
                 AND postOrt <> '' AND POSTNUMMER <> '' AND Adress <> '' AND Namn is not null) as asdasdx)
        ,
     adressCompl as (select fra,
                            Bootstrap_AdressComplettering.POSTORT,
                            Bootstrap_AdressComplettering.POSTNUMMER,
                            Bootstrap_AdressComplettering.ADRESS,
                            Bootstrap_AdressComplettering.NAMN,
                            BETECKNING,
                            toComplete.arndenr,
                            PERSORGNR,
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
                           from filterSmallOwnersBadAdress
                           where postOrt = '' OR POSTNUMMER = '' OR Adress = '' OR Namn is null) as toComplete
                              left outer join tempExcel.dbo.Bootstrap_AdressComplettering
                                              on Bootstrap_AdressComplettering.arndenr = toComplete.arndenr)
select *
from adressCompl
union
(select *
from filterSmallOwnersBadAdress
where postOrt <> '' AND POSTNUMMER <> '' AND Adress <> '' AND Namn is not null)
order by arndenr, RowNum



