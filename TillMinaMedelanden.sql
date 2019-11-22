   IF OBJECT_ID('master.dbo.FracToDec8','U') IS NOT NULL
       DROP TABLE master.dbo.FracToDec8 create table master.dbo.FracToDec8(fra decimal(14,6),POSTORT varchar(255),POSTNUMMER varchar(255),ADRESS varchar(255),NAMN varchar(255),BETECKNING nvarchar(255),arndenr nvarchar(255),PERSORGNR nvarchar(255));

   INSERT INTO master.dbo.FracToDec8(fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR)
        SELECT distinct (SELECT master.dbo.FracToDec(andel)) 'fra',POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, tempExcel.dbo.InputPlusGeofir.ärndenr, PERSORGNR FROM tempExcel.dbo.InputPlusGeofir;


   IF OBJECT_ID('master.dbo.stuffArenden','U') IS NOT NULL
       DROP TABLE master.dbo.stuffArenden
   create table master.dbo.stuffArenden
   (
       fra        decimal(14, 6),
       POSTORT    varchar(255),
       POSTNUMMER varchar(255),
       ADRESS     varchar(255),
       NAMN       varchar(255),
       BETECKNING nvarchar(255),
       arndenr    nvarchar(255),
       PERSORGNR  nvarchar(255),
       RowNum     bigint
   );

INSERT INTO master.dbo.stuffArenden(fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING,  arndenr, PERSORGNR)
select
    distinct						fra,POSTORT,  POSTNUMMER, ADRESS, NAMN, BETECKNING,  ltrim(STUFF((SELECT ', ' + CAST(innerTable.arndenr AS nvarchar(50))
																											FROM FracToDec8 AS innerTable
																												WHERE ressult.BETECKNING = innerTable.BETECKNING and
																													IIf(ressult.Namn is null, ressult.BETECKNING, ressult.Namn) = IIf(innerTable.Namn is null, innerTable.BETECKNING, innerTable.Namn) --DUE TO sql treating null = null as unknown
																															order by arndenr desc FOR XML PATH('')),1,1,'')) AS
																							arndenr,PERSORGNR
    FROM FracToDec8 ressult
    group by namn, POSTORT, POSTNUMMER, ADRESS,PERSORGNR, BETECKNING, fra;

  IF OBJECT_ID('master.dbo.giveRowNumber','U') IS NOT NULL
       DROP TABLE master.dbo.giveRowNumber create table master.dbo.giveRowNumber 
(
       fra        decimal(14, 6),
       POSTORT    varchar(255),
       POSTNUMMER varchar(255),
       ADRESS     varchar(255),
       NAMN       varchar(255),
       BETECKNING nvarchar(255),
       arndenr    nvarchar(255),
       PERSORGNR  nvarchar(255),
       RowNum     bigint
);

INSERT INTO giveRowNumber(fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR, RowNum) 
   

  --   FilterBad as (SELECT fra,POSTORT,POSTNUMMER,ADRESS,NAMN,BETECKNING,arndenr,PERSORGNR,RowNum FROM RowNrByBeteckning WHERE RowNrByBeteckning.postOrt <> '' AND RowNrByBeteckning.POSTNUMMER <> '' AND RowNrByBeteckning.Adress <> '' AND RowNrByBeteckning.Namn IS NOT NULL),

         	SELECT distinct                     theTab.fra,     theTab.POSTORT,     theTab.POSTNUMMER,      theTab.ADRESS,      theTab.NAMN,    theTab.BETECKNING,      theTab.arndenr,     theTab.PERSORGNR,
             ROW_NUMBER() OVER (PARTITION BY theTab.BETECKNING,IIf(theTab.arndenr is null, theTab.BETECKNING, theTab.arndenr) ORDER BY theTab.fra DESC) RowNum
                  FROM stuffArenden AS theTab INNER JOIN stuffArenden innerTable ON
                      theTab.BETECKNING = innerTable.BETECKNING and
                      --DUE TO sql treating null = null as unknown
                        IIf(theTab.Namn is null, theTab.BETECKNING, theTab.Namn) = IIf(innerTable.Namn is null, innerTable.BETECKNING, innerTable.Namn)
                        and
                        IIf(theTab.arndenr is null, theTab.BETECKNING, theTab.arndenr) = IIf(innerTable.arndenr is null, innerTable.BETECKNING, innerTable.arndenr);


WITH
   filterSmallOwners AS(select distinct * from giveRowNumber where  giveRowNumber.RowNum = 1
                        UNION
                        select *
                        from  giveRowNumber where giveRowNumber.RowNum > 1 AND giveRowNumber.RowNum < 4 AND fra > 0.3)


   , stuffBeteckning as (select arndenr,
                                POSTORT,
                                POSTNUMMER,
                                ADRESS,
                                NAMN,
                                ltrim(STUFF((SELECT ', ' + CAST(innerTable.BETECKNING AS nvarchar(50))
                                       FROM filterSmallOwners AS innerTable
                                where
                                    --TODO: fix this DUE TO sql treating null = null as unknown, the table will filter out all null names,
                                    ressult.Namn = innerTable.Namn

                                    order by Beteckning FOR XML PATH ('')), 1, 1, '')) AS Beteckning
                         from filterSmallOwners ressult
                         group by namn, POSTORT, POSTNUMMER, ADRESS, arndenr)

   ,valjLangstArendeNr as (select max(arndenr) arndenr, POSTORT, POSTNUMMER, ADRESS, NAMN, Beteckning from stuffBeteckning group by POSTORT, POSTNUMMER, ADRESS, NAMN, Beteckning)

   , stuffNamn as (select arndenr,
                          POSTORT,
                          POSTNUMMER,
                          ADRESS,
                          ltrim(STUFF((SELECT ', ' + CAST(innerTable.Namn AS nvarchar(50))
                                 FROM valjLangstArendeNr AS innerTable
                                 
                          where
                                ressult.BETECKNING = innerTable.BETECKNING and
                      --DUE TO sql treating null = null as unknown
                        IIf(ressult.Adress is null, ressult.BETECKNING, ressult.Adress) = IIf(innerTable.Adress is null, innerTable.BETECKNING, innerTable.Adress)
                        and
                        IIf(ressult.arndenr is null, ressult.BETECKNING, ressult.arndenr) = IIf(innerTable.arndenr is null, innerTable.BETECKNING, innerTable.arndenr)

                                 order by Beteckning FOR XML PATH ('')), 1, 1, '')) AS NAMN,
                          Beteckning
                   from valjLangstArendeNr ressult
                   group by Beteckning, POSTORT, POSTNUMMER, ADRESS, arndenr)


select arndenr, POSTORT, POSTNUMMER, ADRESS, NAMN, Beteckning

from stuffNamn where Beteckning is not null union select arndenr, POSTORT, POSTNUMMER, ADRESS, NAMN, Beteckning
from filterSmallOwners where namn is null order by arndenr desc,Beteckning
   
   IF OBJECT_ID('master..#FracToDec8','U') IS NOT NULL
       DROP TABLE master.dbo.FracToDec8