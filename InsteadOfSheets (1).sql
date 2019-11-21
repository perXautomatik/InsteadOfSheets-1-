

   IF OBJECT_ID('tempdb..#TempWithIdentity') IS NOT NULL DROP TABLE tableWithRowNumbre create table dbo.tableWithRowNumbre
    (
        i          int not null identity (1,1) primary key,
        POSTORT    varchar(255),
        POSTNUMMER varchar(255),
        ADRESS     varchar(255),
        NAMN       varchar(255),
        andel      varchar(255),
        BETECKNING varchar(255),
        arndenr    varchar(255)
    )

SET IDENTITY_INSERT tableWithRowNumbre ON;

INSERT INTO dbo.tableWithRowNumbre( i, ANDEL, POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, arndenr )
        SELECT MAX(TempWithIdentityx.nrx) AS i, MAX(ANDEL) AS ANDEL, POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr AS arendenr
	   FROM
	   (
		   SELECT ROW_NUMBER() OVER(ORDER BY NEWID()) AS nrx, * FROM tempExcel.dbo.InputPlusGeofir
	   ) AS [TempWithIdentityx]
	   GROUP BY POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr;

SET IDENTITY_INSERT tableWithRowNumbre OFF;

IF OBJECT_ID('tempdb..#del1') IS NOT NULL DROP TABLE #del1 CREATE TABLE dbo.#del1
(
	i int NOT NULL IDENTITY(1, 1) PRIMARY KEY, NAMN varchar(255), andel varchar(255), BETECKNING varchar(255), arndenr varchar(255)
);

SET IDENTITY_INSERT #del1 ON;

INSERT INTO dbo.#del1( i, NAMN, andel, BETECKNING, arndenr )
	   SELECT i, NAMN, andel, BETECKNING, arndenr
	   FROM tableWithRowNumbre;

SET IDENTITY_INSERT #del1 OFF;



IF OBJECT_ID('tempdb..#del2') IS NOT NULL DROP TABLE #del2 CREATE TABLE dbo.#del2
(
    i int NOT NULL IDENTITY(1, 1) PRIMARY KEY, POSTORT varchar(255), POSTNUMMER varchar(255), ADRESS varchar(255)
);

SET IDENTITY_INSERT #del2 ON;

INSERT INTO dbo.#del2( POSTORT, POSTNUMMER, adress, i )
	   SELECT POSTORT, POSTNUMMER, adress, i
	   FROM tableWithRowNumbre;

SET IDENTITY_INSERT #del2 OFF;

IF OBJECT_ID('tempdb..#splitAdressCTE') IS NOT NULL DROP TABLE #splitAdressCTE CREATE TABLE dbo.#splitAdressCTE
(
    i int , ADRESS varchar(255), Rn varchar(255), ExtractedValuesFromNames varchar(255)
);


--populate the temporary table

--adress, i FROM #del2 as x
--
INSERT INTO dbo.#splitAdressCTE( i, Rn, adress, ExtractedValuesFromNames )
	   SELECT Del2s.i, f.Rn, f.adress, f.ExtractedValuesFromNames
	   FROM ( SELECT adress, i FROM #del2 ) AS Del2s
                CROSS APPLY
                    --lite osäker på vad detta gör, tror att kan vara ett sätt att använda
                    --row_number() och Value from så att man kan itterera över ressultatet i splitt
	                (SELECT Rn = ROW_NUMBER() OVER (PARTITION BY Del2s.adress ORDER BY Del2s.adress),
                                Del2s.adress,
                                ExtractedValuesFromNames = value FROM STRING_SPLIT(Del2s.adress, ',') AS D
                    ) AS f;

IF OBJECT_ID('tempdb..#d3AdressSplitt') IS NOT NULL DROP TABLE #d3AdressSplitt CREATE TABLE dbo.#d3AdressSplitt
  (
      i                        int,
      ADRESS                   varchar(255),
      C_O                      varchar(255),
      Adress2                  varchar(255),
      PostOrt                  varchar(255),
      postnr                   varchar(255)
  );

INSERT INTO dbo.#d3AdressSplitt( i,adress,C_O,Adress2,PostOrt,postnr )
	SELECT i,adress
         , C_O = (case
                      when (select max(c2.rn) from #splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4
                          then STUFF(
                              (SELECT '' + c2.ExtractedValuesFromNames + ' '
                               FROM #splitAdressCTE c2
                               WHERE (c2.ADRESS = c1.ADRESS)
                                 and c2.Rn = 1
                               group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')
                      else null end)
         , Adress2 = (case
                          when (select max(c2.rn) from #splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4
                              then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' '
                                          FROM #splitAdressCTE c2
                                          WHERE (c2.ADRESS = c1.ADRESS)
                                            and c2.Rn = 2
                                          group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')
                          else STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' '
                                      FROM #splitAdressCTE c2
                                      WHERE (c2.ADRESS = c1.ADRESS)
                                        and c2.Rn = 1
                                      group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '') end)

	     ,PostOrt = (case when (select max(c2.rn)from #splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM #splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 3 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM #splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 2 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '') end)
	     ,postnr  = (case when (select max(c2.rn)from #splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM #splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn >= 4 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM #splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 3 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '') end)
	FROM #splitAdressCTE c1 group by i, adress
;

with
    TrimValues as (select #d3AdressSplitt.i,C_O,ltrim(Adress2) as adress,ltrim(#d3AdressSplitt.PostOrt) as PostOrt2,#del2.POSToRT,ltrim(postnr) as postnr,POSTNUMMER,#d3AdressSplitt.adress as orgAdrr from #d3AdressSplitt join #del2 on #d3AdressSplitt.i = #del2.i),

    fixPostOrt as (select i,C_O,adress,PostOrtZ = case when PostOrt2 like '%' + ress.POSToRT then ress.POSToRT else case when PostOrt2 is null then postort else PostOrt2 end end,postnr =case when PostOrt2 like cast(POSTNUMMER as varchar(255)) + '%' then cast(POSTNUMMER as varchar(255))else case when POSTNUMMER is null then postnr else cast(POSTNUMMER as varchar(255)) end end,ress.POSToRT,orgAdrr from (select i,C_O,adress,cast(PostOrt2 as varchar(255)) as PostOrt2,POSToRT,postnr,POSTNUMMER,orgAdrr from TrimValues) as ress),

    GroupAdresses as (select C_O,adress,PostOrtZ as postort,postnr as POSTNUMMER,max(andel) as andel,namn,BETECKNING,arndenr from #del1 join fixPostOrt on #del1.i = fixPostOrt.i group by C_O, adress, PostOrtZ, postnr,  namn, BETECKNING, arndenr),

    ParaMakeMaka as (select ANDEL as justForVisual,POSTORT,C_O,POSTNUMMER,ADRESS,NAMN,(select top 1 namn from GroupAdresses as x where x.BETECKNING = GroupAdresses.BETECKNING AND x.ADRESS = GroupAdresses.ADRESS and x.NAMN <> GroupAdresses.NAMN) as Namn2,BETECKNING,arndenr from GroupAdresses),

    MakeMaka as (select fra,C_O,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr,rn from (SELECT master.dbo.FracToDec(justForVisual) as fra,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,C_O,Namn2,BETECKNING,arndenr,ROW_NUMBER() OVER (PARTITION BY (case when ParaMakeMaka.Namn2 is not null then case when ParaMakeMaka.NAMN > ParaMakeMaka.namn2 then ParaMakeMaka.NAMN + ParaMakeMaka.Namn2 else ParaMakeMaka.Namn2 + ParaMakeMaka.NAMN end else ParaMakeMaka.NAMN end),BETECKNING ORDER BY BETECKNING,ADRESS ) As rn FROM ParaMakeMaka) t where t.rn = 1),

    grupperaEfterAndel as (select fra,C_O,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr,ROW_NUMBER() OVER (PARTITION BY BETECKNING ORDER BY fra desc ) As rn from MakeMaka),

    filterBadAdress as (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr from grupperaEfterAndel where POSTORT is not null and POSTNUMMER is not null and ADRESS is not null and NAMN is not null),

    filterSmallOwnersBadAdress as (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,
                                          NAMN,Namn2,BETECKNING,arndenr,RowNum from (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr,RowNum from (select q.fra,q.C_O,q.POSTORT,q.POSTNUMMER,q.ADRESS,q.NAMN,q.Namn2,q.BETECKNING,q.arndenr,ROW_NUMBER() OVER ( PARTITION BY q.arndenr ORDER BY q.fra desc) RowNum from filterBadAdress as q INNER JOIN filterBadAdress thethree ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X WHERE X.RowNum = 1) as asdasd union select *from (select *from (select q.fra,q.C_O,q.POSTORT,q.POSTNUMMER,q.ADRESS,q.NAMN,q.Namn2,q.BETECKNING,q.arndenr,ROW_NUMBER() OVER ( PARTITION BY q.arndenr ORDER BY q.fra desc ) RowNum from filterBadAdress as q INNER JOIN filterBadAdress thethree ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X WHERE X.RowNum > 1 and X.RowNum < 4 AND fra > 0.3) as asdasdx)

    --select distinct refx.Diarienr,qlx.BETECKNING,qlx.C_O,qlx.POSTORT, qlx.POSTNUMMER,qlx.ADRESS,qlx.NAMN, qlx.Namn2  from (select fra, C_O, POSTORT, POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr from filterSmallOwnersBadAdress where POSTNUMMER <> '') as qlx right outer join (select Diarienr from [tempExcel].[dbo].[FNRKIRDIARENR_FörUtskick]) as refx on refx.Diarienr = qlx.arndenr
	select * from tableWithRowNumbre



IF OBJECT_ID('tempdb..#TempWithIdentity') IS NOT NULL DROP TABLE tableWithRowNumbre
     IF OBJECT_ID('tempdb..#del1') IS NOT NULL DROP TABLE #del1
   IF OBJECT_ID('tempdb..#del2') IS NOT NULL DROP TABLE #del2
  IF OBJECT_ID('tempdb..#splitAdressCTE') IS NOT NULL DROP TABLE #splitAdressCTE

IF OBJECT_ID('tempdb..#d3AdressSplitt') IS NOT NULL DROP TABLE #d3AdressSplitt
