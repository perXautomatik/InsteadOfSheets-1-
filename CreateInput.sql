
    select (SELECT master.dbo.FracToDec(andel)) 'fra',
           CAST(FNR AS int)             as      FNR,
           CAST(BETECKNING AS nvarchar) as      BETECKNING,
           CAST(ärndenr AS nvarchar)            'arndenr',
           CAST(Namn AS nvarchar)       as      Namn,
           CAST(Adress AS nvarchar)     as      Adress,
           CAST(POSTNUMMER AS nvarchar) as      POSTNUMMER,
           CAST(postOrt AS nvarchar)    as      postOrt,
           CAST(PERSORGNR AS nvarchar)  as      PERSORGNR
    into #input
    from
         --tempExcel.
        dbo.Generator_InputPlusGeofir
