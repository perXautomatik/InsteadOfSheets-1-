with filterBadAdress as (
    select (SELECT master.dbo.FracToDec(andel)) 'fra',
           FNR,
           BETECKNING,
           ärndenr                              'arndenr',
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
                            AdressComplettering.POSTORT,
                            AdressComplettering.POSTNUMMER,
                            AdressComplettering.ADRESS,
                            AdressComplettering.NAMN,
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
                              left outer join tempExcel.dbo.AdressComplettering
                                              on AdressComplettering.arndenr = toComplete.arndenr)
select *
from adressCompl
union
(select *
from filterSmallOwnersBadAdress
where postOrt <> '' AND POSTNUMMER <> '' AND Adress <> '' AND Namn is not null)
order by arndenr, RowNum



