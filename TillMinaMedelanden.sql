   IF OBJECT_ID('master.dbo.FracToDec8','U') IS NOT NULL
       DROP TABLE master.dbo.FracToDec8

   create table master.dbo.FracToDec8
    (
  fra decimal(14,6),
  POSTORT varchar(255),
  POSTNUMMER varchar(255),
  ADRESS varchar(255),
  NAMN varchar(255),
  BETECKNING nvarchar(255),
  arndenr nvarchar(255),
  PERSORGNR nvarchar(255)
);

--SET IDENTITY_INSERT FracToDec3 ON;

INSERT INTO master.dbo.FracToDec8(fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR)
        SELECT distinct (SELECT master.dbo.FracToDec(andel)) 'fra',POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, tempExcel.dbo.InputPlusGeofir.ärndenr, PERSORGNR FROM tempExcel.dbo.InputPlusGeofir;


   IF OBJECT_ID('master.dbo.RowNrByBeteckning','U') IS NOT NULL
       DROP TABLE master.dbo.RowNrByBeteckning

   create table master.dbo.RowNrByBeteckning
    (
  fra decimal(14,6),
  POSTORT varchar(255),
  POSTNUMMER varchar(255),
  ADRESS varchar(255),
  NAMN varchar(255),
  BETECKNING nvarchar(255),
  arndenr nvarchar(255),
  PERSORGNR nvarchar(255),
  RowNum bigint
);

INSERT INTO master.dbo.RowNrByBeteckning(   fra,            POSTORT,            POSTNUMMER,             ADRESS,             NAMN,           BETECKNING,             arndenr,            PERSORGNR,          RowNum)
		SELECT distinct                     theTab.fra,     theTab.POSTORT,     theTab.POSTNUMMER,      theTab.ADRESS,      theTab.NAMN,    theTab.BETECKNING,      theTab.arndenr,     theTab.PERSORGNR,
             ROW_NUMBER() OVER (PARTITION BY theTab.BETECKNING,IIf(theTab.arndenr is null, theTab.BETECKNING, theTab.arndenr) ORDER BY theTab.fra DESC) RowNum
                  FROM FracToDec8 AS theTab INNER JOIN FracToDec8 innerTable ON
                      theTab.BETECKNING = innerTable.BETECKNING and
                      --DUE TO sql treating null = null as unknown
                        IIf(theTab.Namn is null, theTab.BETECKNING, theTab.Namn) = IIf(innerTable.Namn is null, innerTable.BETECKNING, innerTable.Namn)
                        and
                        IIf(theTab.arndenr is null, theTab.BETECKNING, theTab.arndenr) = IIf(innerTable.arndenr is null, innerTable.BETECKNING, innerTable.arndenr)
                        ;
   WITH
  --   FilterBad as (SELECT fra,POSTORT,POSTNUMMER,ADRESS,NAMN,BETECKNING,arndenr,PERSORGNR,RowNum FROM RowNrByBeteckning WHERE RowNrByBeteckning.postOrt <> '' AND RowNrByBeteckning.POSTNUMMER <> '' AND RowNrByBeteckning.Adress <> '' AND RowNrByBeteckning.Namn IS NOT NULL),

     stuffArende as (
         select
             distinct fra,POSTORT,POSTNUMMER,ADRESS,NAMN,BETECKNING,STUFF((SELECT ', ' + CAST(innerTable.arndenr AS nvarchar(50))
         FROM RowNrByBeteckning AS innerTable
         WHERE
            ressult.BETECKNING = innerTable.BETECKNING and
            --DUE TO sql treating null = null as unknown
            IIf(ressult.Namn is null, ressult.BETECKNING, ressult.Namn) = IIf(innerTable.Namn is null, innerTable.BETECKNING, innerTable.Namn)

         order by Beteckning FOR XML PATH('')),1,1,'') AS arndenr,PERSORGNR,min(RowNum) RowNum FROM RowNrByBeteckning ressult
         group by namn, POSTORT, POSTNUMMER, ADRESS,PERSORGNR, BETECKNING, fra
   ),


   filterSmallOwners AS(select distinct * from stuffArende where  stuffArende.RowNum = 1
   UNION
   select *
   from  stuffArende where stuffArende.RowNum > 1 AND stuffArende.RowNum < 4 AND fra > 0.3)


   ,stuffBeteckning as(select arndenr,POSTORT,POSTNUMMER,ADRESS,NAMN,STUFF((SELECT ', ' + CAST(innerTable.BETECKNING AS nvarchar(50)) FROM filterSmallOwners AS innerTable WHERE innerTable.Namn = ressult.Namn order by Beteckning FOR XML PATH('')),1,1,'') AS Beteckning from filterSmallOwners ressult group by namn, POSTORT, POSTNUMMER, ADRESS,arndenr)

   ,stuffNamn as(select arndenr,POSTORT,POSTNUMMER,ADRESS,STUFF((SELECT ', ' + CAST(innerTable.Namn AS nvarchar(50)) FROM stuffBeteckning AS innerTable WHERE innerTable.Beteckning = ressult.Beteckning AND innerTable.ADRESS = ressult.ADRESS order by Beteckning FOR XML PATH('')),1,1,'') AS NAMN,Beteckning from stuffBeteckning ressult group by Beteckning, POSTORT, POSTNUMMER, ADRESS,arndenr)
   
   
 select * from stuffNamn order by Beteckning
   
   IF OBJECT_ID('master..#FracToDec8','U') IS NOT NULL
       DROP TABLE master.dbo.FracToDec8