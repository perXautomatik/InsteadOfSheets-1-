WITH filterBadAdress AS (SELECT (SELECT master.dbo.FracToDec(andel)) 'fra',
                                FNR,
                                BETECKNING,
                                ärndenr                              'arndenr',
                                Namn,
                                Adress,
                                POSTNUMMER,
                                postOrt,
                                PERSORGNR
                         FROM tempExcel.dbo.InputPlusGeofir),
     filterSmallOwnersBadAdress AS (SELECT fra,
                                           POSTORT,
                                           POSTNUMMER,
                                           ADRESS,
                                           NAMN,
                                           BETECKNING,
                                           arndenr,
                                           PERSORGNR,
                                           RowNum
                                    FROM (SELECT fra,
                                                 POSTORT,
                                                 POSTNUMMER,
                                                 ADRESS,
                                                 NAMN,
                                                 BETECKNING,
                                                 arndenr,
                                                 PERSORGNR,
                                                 RowNum
                                          FROM (SELECT q.fra,
                                                       q.POSTORT,
                                                       q.POSTNUMMER,
                                                       q.ADRESS,
                                                       q.NAMN,
                                                       q.BETECKNING,
                                                       q.arndenr,
                                                       q.PERSORGNR,
                                                       ROW_NUMBER() OVER (PARTITION BY q.arndenr ORDER BY q.fra DESC) RowNum
                                                FROM filterBadAdress AS q
                                                         INNER JOIN filterBadAdress thethree
                                                                    ON q.arndenr = thethree.arndenr AND q.namn = thethree.namn) X
                                          WHERE X.RowNum = 1
                                            AND postOrt <> ''
                                            AND POSTNUMMER <> ''
                                            AND Adress <> ''
                                            AND Namn IS NOT NULL) AS asdasd
                                    UNION
                                    SELECT fra,
                                           POSTORT,
                                           POSTNUMMER,
                                           ADRESS,
                                           NAMN,
                                           BETECKNING,
                                           arndenr,
                                           PERSORGNR,
                                           RowNum
                                    FROM (SELECT fra,
                                                 POSTORT,
                                                 POSTNUMMER,
                                                 ADRESS,
                                                 NAMN,
                                                 BETECKNING,
                                                 arndenr,
                                                 PERSORGNR,
                                                 RowNum
                                          FROM (SELECT q.fra,
                                                       q.POSTORT,
                                                       q.POSTNUMMER,
                                                       q.ADRESS,
                                                       q.NAMN,
                                                       q.BETECKNING,
                                                       q.arndenr,
                                                       q.PERSORGNR,
                                                       ROW_NUMBER() OVER (PARTITION BY q.arndenr ORDER BY q.fra DESC) RowNum
                                                FROM filterBadAdress AS q
                                                         INNER JOIN filterBadAdress thethree
                                                                    ON q.arndenr = thethree.arndenr AND q.namn = thethree.namn) X
                                          WHERE X.RowNum > 1
                                            AND X.RowNum < 4
                                            AND fra > 0.3
                                            AND postOrt <> ''
                                            AND POSTNUMMER <> ''
                                            AND Adress <> ''
                                            AND Namn IS NOT NULL) AS asdasdx),
     adressCompl AS (SELECT fra,
                            AdressComplettering.POSTORT,
                            AdressComplettering.POSTNUMMER,
                            AdressComplettering.ADRESS,
                            AdressComplettering.NAMN,
                            BETECKNING,
                            toComplete.arndenr,
                            PERSORGNR,
                            RowNum
                     FROM (SELECT fra,
                                  POSTORT,
                                  POSTNUMMER,
                                  ADRESS,
                                  NAMN,
                                  BETECKNING,
                                  arndenr,
                                  PERSORGNR,
                                  RowNum
                           FROM filterSmallOwnersBadAdress
                           WHERE postOrt = ''
                              OR POSTNUMMER = ''
                              OR Adress = ''
                              OR Namn IS NULL) AS toComplete
                              LEFT OUTER JOIN tempExcel.dbo.AdressComplettering
                                              ON AdressComplettering.arndenr = toComplete.arndenr)
SELECT DISTINCT adressCompl.fra,
                adressCompl.POSTORT,
                adressCompl.POSTNUMMER,
                adressCompl.ADRESS,
                adressCompl.NAMN,
                adressCompl.BETECKNING,
                adressCompl.arndenr,
                adressCompl.PERSORGNR
FROM adressCompl
UNION
(SELECT filterSmallOwnersBadAdress.fra,
        filterSmallOwnersBadAdress.POSTORT,
        filterSmallOwnersBadAdress.POSTNUMMER,
        filterSmallOwnersBadAdress.ADRESS,
        filterSmallOwnersBadAdress.NAMN,
        filterSmallOwnersBadAdress.BETECKNING,
        filterSmallOwnersBadAdress.arndenr,
        filterSmallOwnersBadAdress.PERSORGNR
 FROM filterSmallOwnersBadAdress
 WHERE postOrt <> ''
   AND POSTNUMMER <> ''
   AND Adress <> ''
   AND Namn IS NOT NULL)
ORDER BY arndenr;