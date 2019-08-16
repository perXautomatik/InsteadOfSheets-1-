
create or alter view InputPlusGeofir as
SELECT FNR,
       BETECKNING,
       ärndenr,
       CAST(
               CASE
                   WHEN [ANDEL] is null OR [ANDEL] = ''
                       THEN '1/1'
                   ELSE [ANDEL]
                   END AS varchar) as andel,
       CAST(
               CASE
                   WHEN [NAMN] is null OR [NAMN] = ''
                       THEN KORTNAMN
                   ELSE [NAMN]
                   END AS varchar) as Namn,
       CAST(
               CASE
                   WHEN ([FAL_UTADR2] is null OR [FAL_UTADR2] = '') AND ([FAL_POSTNR] is null OR [FAL_POSTNR] = '') then
                       CASE
                           WHEN (SAL_UTADR1 is null OR SAL_UTADR1 = '') AND (SAL_POSTNR is null OR SAL_POSTNR = '')
                               THEN UA_UTADR1
                           ELSE SAL_UTADR1
                           END
                   ELSE FAL_UTADR2
                   END AS varchar) as Adress,

       CAST(
               CASE
                   WHEN ([FAL_UTADR2] is null OR [FAL_UTADR2] = '') AND ([FAL_POSTNR] is null OR [FAL_POSTNR] = '') then
                       CASE
                           WHEN (SAL_UTADR1 is null OR SAL_UTADR1 = '') AND (SAL_POSTNR is null OR SAL_POSTNR = '')
                               THEN UA_UTADR2
                           ELSE SAL_POSTNR
                           END
                   ELSE [FAL_POSTNR]
                   END AS varchar) as POSTNUMMER,
       CAST(
               CASE
                   WHEN ([FAL_POSTORT] is null OR [FAL_POSTORT] = '') AND ([FAL_POSTNR] is null OR [FAL_POSTNR] = '')
                       then
                       CASE
                           WHEN (SAL_UTADR1 is null OR SAL_UTADR1 = '') AND (SAL_POSTNR is null OR SAL_POSTNR = '')
                               THEN UA_LAND
                           ELSE SAL_POSTORT
                           END
                   ELSE [FAL_POSTORT]
                   END AS varchar) as postOrt

FROM (SELECT input.FNR,
             input.BETECKNING,input._Ärendenr_ as ärndenr,
             [UA_UTADR2],
             [UA_UTADR1],
             [UA_LAND],
             [SAL_POSTORT],
             [SAL_POSTNR],
             [NAMN],
             [KORTNAMN],
             [FAL_UTADR2],
             [FAL_POSTORT],
             [FAL_POSTNR],
             [ANDEL],
             --[AGTYP],
             [SAL_UTADR1]
             --,[UA_UTADR4],--[UA_UTADR3],--[TNMARK],--[SAL_UTADR2],--[SAL_CO],--[NAMN_OMV],--[MNAMN],--[KORTNAMN_OMV],--[FNAMN],--[FAL_UTADR1],--[FAL_CO],--[ENAMN]
FROM [GISDATA].sde_geofir_gotland.gng.FA_TAXERINGAGARE_V2 as tax
         LEFT JOIN
     (SELECT input.FNR, input.BETECKNING, Hideviken._Ärendenr_
      FROM Hideviken
               left JOIN [GISDATA].sde_geofir_gotland.gng.FA_FASTIGHET AS input ON _FASTIGHET_ = input.BETECKNING
      where input.BETECKNING is not null) AS input ON input.FNR = tax.FNR
      where input.BETECKNING is not null) as OrginalAndGeofir
