   IF OBJECT_ID('master.dbo.FracToDec8','U') IS NOT NULL
       DROP TABLE FracToDec8

   create table dbo.FracToDec8
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

INSERT INTO dbo.FracToDec8(fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR)
        SELECT distinct (SELECT master.dbo.FracToDec(andel)) 'fra',POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, tempExcel.dbo.InputPlusGeofir.ärndenr, PERSORGNR FROM tempExcel.dbo.InputPlusGeofir;


   IF OBJECT_ID('master.dbo.RowNrByBeteckning','U') IS NOT NULL
       DROP TABLE RowNrByBeteckning

   create table dbo.RowNrByBeteckning
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

INSERT INTO dbo.RowNrByBeteckning(fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR,RowNum)
		SELECT distinct q.fra,q.POSTORT,q.POSTNUMMER,q.ADRESS,q.NAMN,q.BETECKNING,q.arndenr,q.PERSORGNR,
                                         ROW_NUMBER() OVER (PARTITION BY q.BETECKNING ORDER BY q.fra DESC) RowNum
                                  FROM FracToDec8 AS q INNER JOIN FracToDec8 thethree ON q.BETECKNING = thethree.BETECKNING AND q.namn = thethree.namn;

WITH
     FilterBad as (SELECT fra,POSTORT,POSTNUMMER,ADRESS,NAMN,BETECKNING,arndenr,PERSORGNR,RowNum
                            FROM RowNrByBeteckning
                            WHERE RowNrByBeteckning.postOrt <> ''
                              AND RowNrByBeteckning.POSTNUMMER <> ''
                              AND RowNrByBeteckning.Adress <> ''
                              AND RowNrByBeteckning.Namn IS NOT NULL),


     filterSmallOwners AS (select distinct * from FilterBad where  FilterBad.RowNum = 1
                                    UNION
                                    select * from  FilterBad where FilterBad.RowNum > 1 AND FilterBad.RowNum < 4 AND fra > 0.3 )


	,stuffBeteckning as ( select arndenr,POSTORT,POSTNUMMER,ADRESS,NAMN,STUFF((SELECT ', ' + CAST(innerTable.BETECKNING AS nvarchar(50)) FROM filterSmallOwners AS innerTable WHERE innerTable.Namn = ressult.Namn order by Beteckning FOR XML PATH('')),1,1,'') AS Beteckning from filterSmallOwners ressult group by namn, POSTORT, POSTNUMMER, ADRESS,arndenr)
	
	,stuffNamn as ( select arndenr,POSTORT,POSTNUMMER,ADRESS,STUFF((SELECT ', ' + CAST(innerTable.Namn AS nvarchar(50)) FROM stuffBeteckning AS innerTable WHERE innerTable.Beteckning = ressult.Beteckning AND innerTable.ADRESS = ressult.ADRESS order by Beteckning FOR XML PATH('')),1,1,'') AS NAMN,Beteckning from stuffBeteckning ressult group by Beteckning, POSTORT, POSTNUMMER, ADRESS,arndenr)
   
   
 select * from stuffNamn order by Beteckning
   
   IF OBJECT_ID('master..#FracToDec8','U') IS NOT NULL
       DROP TABLE FracToDec8