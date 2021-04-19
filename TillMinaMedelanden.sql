:r "C:\Users\crbk01\.DataGrip2019.3\config\projects\Kv-Utsökning\TillMinaMedelanden\synonyms.sql";


;IF object_id('TEMPDB..#toInsert') IS not null BEGIN
    drop table #toInsert
    end
IF object_id('TEMPDB..#kalla') IS not null BEGIN
drop table #kalla
end
IF object_id('TEMPDB..#fordig') IS not null BEGIN
drop table #fordig
end
;

declare @inputFnr dbo.KontaktUpgTableType;
declare @arMening as VARCHAR(200) set @arMening = 'Klart vatten - information om avlopp';
declare @diareAr as int set @diareAr = null;
declare @lopNrLargerOrEq as int set @lopNrLargerOrEq = null;
DECLARE @handRubrik1 as NVARCHAR(200)
DECLARE @handRubrik2 as NVARCHAR(200)
set @handRubrik1 = N'%utförandeintyg'
set @handRubrik2 = N'Ansökan/anmälan om enskild cavloppsanläggning%';
DECLARE	@HandKat as VARCHAR(50) set @HandKat = N'ANSÖKAN';
declare @statusFilter1 as varchar(50) set @STATUSFILTER1 = 'Makulerat';
declare @statusFilter2 as varchar(50) set @STATUSFILTER2 = 'Avslutat';
;if object_id('tempdb..#ref') is null begin CREATE table #ref (dia VARCHAR(50) PRIMARY KEY );
INSERT INTO #ref VALUES ('MBNV-2019-749'), ('MBNV-2019-750'), ('MBNV-2019-751'), ('MBNV-2019-752'), ('MBNV-2019-761'), ('MBNV-2019-762'), ('MBNV-2019-764'), ('MBNV-2019-765'), ('MBNV-2019-767'), ('MBNV-2019-770'), ('MBNV-2019-774'), ('MBNV-2019-775'), ('MBNV-2019-795'), ('MBNV-2019-799'), ('MBNV-2019-801'), ('MBNV-2019-803'), ('MBNV-2019-806'), ('MBNV-2019-812'), ('MBNV-2019-816'), ('MBNV-2019-817'), ('MBNV-2019-818'), ('MBNV-2019-821'), ('MBNV-2019-822'), ('MBNV-2019-823'), ('MBNV-2019-825'), ('MBNV-2019-827'), ('MBNV-2019-828'), ('MBNV-2019-829'), ('MBNV-2019-833'), ('MBNV-2019-835'), ('MBNV-2019-836'), ('MBNV-2019-837'), ('MBNV-2019-846'), ('MBNV-2019-856'), ('MBNV-2019-858'), ('MBNV-2019-863'), ('MBNV-2019-864'), ('MBNV-2019-875'), ('MBNV-2019-877'), ('MBNV-2019-879'), ('MBNV-2019-886'), ('MBNV-2019-892'), ('MBNV-2019-908'), ('MBNV-2019-911'), ('MBNV-2019-920'), ('MBNV-2019-923'), ('MBNV-2019-933'), ('MBNV-2019-934'), ('MBNV-2019-937'), ('MBNV-2019-952'), ('MBNV-2019-964'), ('MBNV-2019-1043'), ('MBNV-2019-1044'), ('MBNV-2019-1045'), ('MBNV-2019-1048'), ('MBNV-2019-1059'), ('MBNV-2019-1065'), ('MBNV-2019-1067'), ('MBNV-2019-1075'), ('MBNV-2019-1077'), ('MBNV-2019-1079'), ('MBNV-2019-1080'), ('MBNV-2019-1081'), ('MBNV-2019-1083'), ('MBNV-2019-1089'), ('MBNV-2019-1090'), ('MBNV-2019-1093'), ('MBNV-2019-1094'), ('MBNV-2019-1098'), ('MBNV-2019-1104'), ('MBNV-2019-1105'), ('MBNV-2019-1107'), ('MBNV-2019-1112'), ('MBNV-2019-1113'), ('MBNV-2019-1114'), ('MBNV-2019-1116'), ('MBNV-2019-1117'), ('MBNV-2019-1123'), ('MBNV-2019-1124'), ('MBNV-2019-1125'), ('MBNV-2019-1130'), ('MBNV-2019-1138'), ('MBNV-2019-1141'), ('MBNV-2019-1152'), ('MBNV-2019-1155'), ('MBNV-2019-1157'), ('MBNV-2019-1158'), ('MBNV-2019-1162'), ('MBNV-2019-1165'), ('MBNV-2019-1166'), ('MBNV-2019-1169'), ('MBNV-2019-1171'), ('MBNV-2019-1174'), ('MBNV-2019-1176'), ('MBNV-2019-1180'), ('MBNV-2019-1182'), ('MBNV-2019-1183'), ('MBNV-2019-1184'), ('MBNV-2019-1187'), ('MBNV-2019-1248'), ('MBNV-2019-1249'), ('MBNV-2019-1283'), ('MBNV-2019-1287'), ('MBNV-2019-1289'), ('MBNV-2019-1290'), ('MBNV-2019-1292'), ('MBNV-2019-1304'), ('MBNV-2019-1307'), ('MBNV-2019-1314'), ('MBNV-2019-1318'), ('MBNV-2019-1324'), ('MBNV-2019-1338'), ('MBNV-2019-1348'), ('MBNV-2019-1350'), ('MBNV-2019-1352'), ('MBNV-2019-1354'), ('MBNV-2019-1357'), ('MBNV-2019-1360'), ('MBNV-2019-1366'), ('MBNV-2019-1367'), ('MBNV-2019-1368'), ('MBNV-2019-1369'), ('MBNV-2019-1370'), ('MBNV-2019-1371'), ('MBNV-2019-1372'), ('MBNV-2019-1373'), ('MBNV-2019-1374'), ('MBNV-2019-1375'), ('MBNV-2019-1376'), ('MBNV-2019-1408'), ('MBNV-2019-1734'), ('MBNV-2019-1738'), ('MBNV-2019-1739'), ('MBNV-2020-709'), ('MBNV-2020-710'), ('MBNV-2020-711'), ('MBNV-2020-712'), ('MBNV-2020-713')
end
;if object_id('tempdb..#excluded') is null begin CREATE table #excluded (dia VARCHAR(50),fas VARCHAR(50))

CREATE INDEX exCInd on #EXCLUDED(fas,dia);
INSERT INTO #excluded (FAS)
VALUES
(N'TRÄKUMLA TJÄNGDARVE 1:27'),
(N'FOLLINGBO ROSENDAL 1:40'),
(N'FOLLINGBO SLÄTTFLISHAGE 4:1'),
(N'FOLLINGBO SLÄTTFLISHAGE 2:2'),
(N'FOLLINGBO SYLFASTE 1:15'),
(N'FOLLINGBO SYLFASTE 1:19'),
(N'FOLLINGBO TINGSTOMT 1:20'),
(N'FOLLINGBO KLINTE 1:64'),
(N'TRÄKUMLA INGVARDS 1:59'),
(N'VISBY ANNELUND 1:20'),
(N'VISBY GUSTAVSVIK 1:13'),
(N'VISBY SNÄCKGÄRDET 1:30')
       ;
end
;if object_id('tempdb..#SockenLista') is null begin CREATE table #SockenLista (socken NVARCHAR(50) NOT NULL PRIMARY KEY ) INSERT INTO #SockenLista VALUES
--(N'Kräklingbo'),('Alskog'),('Lau'),(N'När'),('Burs'),('Sjonhem')
    ('Follingbo'),('Hejdeby'),('Lokrume'),('Martebo'),(N'Träkumla'),('Visby'),(N'Västerhejde')
end

if object_id('tempdb..#toInsert') is null begin
begin TRANSACTION;
with
    --joinX as (select * from [admsql04].[EDPVisionRegionGotland].DBO.VWAEHAERENDE INNER join FastighetsLista ON coalesce(nullif([admsql04].[EDPVisionRegionGotland].DBO.VWAEHAERENDE.strFastighetsbeteckning,''),strSoekbegrepp) = FastighetsLista.FASTIGHET),
    k as (
	SELECT vA.STRDIARIENUMMER Dia,coalesce(nullif(vA.STRFASTIGHETSBETECKNING, ''), va.STRSOEKBEGREPP) kir,STRFNRID fnr,va.strLogKommentar,strAerendeStatusPresent
		/*,isnull(h.STRRUBRIK,1) strUbrik,
	       nullif(a.STRAERENDEMENING,@ARMENING) mening,
	    	nullif(a.strAerendeStatusPresent,@STATUSFILTER1) status1,
	          nullif(a.strAerendeStatusPresent,@STATUSFILTER2) status2*/
	    FROM
	         (select STRDIARIENUMMER,STRFASTIGHETSBETECKNING,STRSOEKBEGREPP,STRFNRID,strLogKommentar,strAerendeStatusPresent,STRAERENDEMENING,RECAERENDEID from  [admsql04].[EDPVisionRegionGotland].DBO.VWAEHAERENDE
	             Where
	                not( strAerendeStatusPresent =@STATUSFILTER1 or strAerendeStatusPresent= @STATUSFILTER2) and STRAERENDEMENING = @ARMENING
	             ) va
	    INNER JOIN #SOCKENLISTA ON LEFT(coalesce(nullif(va.STRFASTIGHETSBETECKNING, ''), va.STRSOEKBEGREPP), len(SOCKEN)) = SOCKEN
	    LEFT OUTER JOIN
	        (select RECAERENDEID, (case when strRubrik is null then @HandKat else strRubrik end) strRubrikx from [admsql04].[EDPVisionRegionGotland].DBO.vwAehHaendelse q
	        WHERE  q.strHaendelseKategori = @HandKat or
	              strRubrik like @HANDRUBRIK1 Or
	              strRubrik like @HANDRUBRIK2 ) H
	        ON va.RECAERENDEID = h.RECAERENDEID
		Where
	      		h.strRubrikx IS NULL
	),
	k2 as (SELECT *  from k)
     ,exluded as (
         select p.DIA,p.KIR,p.FNR,p.strAerendeStatusPresent,p.strLogKommentar from (SELECT K2.*, coalesce(T.DIA, T.FAS) X
		  FROM K2
		      LEFT OUTER JOIN #EXCLUDED T
		      ON
			      coalesce(T.DIA, T.FAS) = K2.DIA
			      OR
			      coalesce(T.FAS, T.DIA) = K2.KIR
) p
            WHERE x is null
         )
   ,correctFnr as (select DIA, coalesce(KirFnr.Fnr,a.fnr) Fnr,coalesce(a.strLogKommentar,strAerendeStatusPresent) as strLogKommentar   FROM exluded a LEFT OUTER JOIN KirFnr ON a.KIR = KirFnr.BETECKNING ) --vision has sometimes a internal nr instad of fnr in the fnrcolumn
  ,toInsert as (select strLogKommentar statuskommentar ,DIA,Fnr from correctFnr)

    --insert into @inputFnr (id,Diarienummer,Fnr,fastighet,HÄNDELSEDATUM ) --;if object_id('tempdb..#TRM') is null begin begin  TRANSACTION--SELECT * INTO #TRM from @INPUTFNR ;--END adressCorrecting = gisTable1 -- don't think the view of gisTable1 has 3 segments, so union is not nessessary.--    ip as (select fnr from @INPUTFNR),
select *, GETDATE() inskdatum
into #toInsert
from toInsert
end
;

--;if object_id('tempdb..#FulaAdresser') is null begin CREATE table #FulaAdresser (adress NVARCHAR NOT NULL PRIMARY KEY ) INSERT INTO #FulaAdresser VALUES('DALHEM HALLVIDE 119, HALFVEDE, 62256 DALHEM'), ('c/o LILIAN PETTERSSON, SANDA STENHUSE 310'), ('DALHEM GRANSKOGS 966'), ('GRANSKOGS DALHEM 966'), (N'GAMLA NORRBYVÄGEN 15, ÖSTRA TÄCKERÅKER, 13674 NORRBY'), (N'ÖSTRA TÄCKERÅKER GAMLA NORRBYVÄGEN 15'), (N'ALVA GUDINGS 328 VÅN 2, GAMLA SKOLAN, 62346 HEMSE'), ('DALHEM KAUNGS 538, DUNBODI, 62256 DALHEM'), ('HERTZBERGSGATE 3 A0360 OSLO NORGE'), ('DALHEM HALLVIDE 119, HALFVEDE'), ('OLAV M. TROVIKS VEI 500864 OSLO NORGE'), ('LORNSENSTR. 30DE-24105 KIEL TYSKLAND'), (N'FRÜLINGSSTRASSE 3882110 GERMENING TYSKLAND'), (N'c/o FÖRENINGEN GOTLANDSTÅGET HÄSSELBY 166'), ('c/o TRYGGVE PETTERSSON KAUNGS 524'), (N'c/o L. ANDERSSON DJURSTRÖMS VÄG 11'), (N'PRÄSTBACKEN 8'), ('HALLA BROE 105'), (N'GAMLA SKOLAN ALVA GUDINGS 328 VÅN 2')
--end;

if object_id('tempdb..#kalla') is null begin
    BEGIN TRANSACTION;
    if object_id('tempdb..#fordig') is not null begin drop table #FORDIG END;
with
    COLUMNPROCESSBADNESSSCORE AS (   SELECT FNR , org , ANDEL , namn , INSKDATUM , adress ,  POSTORT ,  POSTNR , 'geosecma' src
    , ((CASE WHEN namn IS NULL THEN 1 ELSE 0 END) + (CASE WHEN postnr IS NULL THEN 1 ELSE 0 END) + (CASE WHEN postort IS NULL THEN 1 ELSE 0 END)
	+ (CASE WHEN adress IS NULL THEN 1 ELSE 0 END) + (CASE WHEN org is NULL THEN 1 ELSE 0 END))    BADNESS
	FROM (SELECT namn, org, FNR, ANDEL, INSKDATUM, ADRESS
	    , nullif(CASE WHEN postnrAvskFinns THEN substring(POSTNRPOSTORT, postNrAvsk + 1, LEN(POSTNRPOSTORT)) END,'') POSTORT
	    , nullif(CASE WHEN postnrAvskFinns THEN left(POSTNRPOSTORT, postNrAvsk - 1) END,'') POSTNR
	    FROM (select *, postNrAvsk > 0 as postnrAvskFinns from (
	        select *,charindex(' ', POSTNRPOSTORT) postNrAvsk from
		 (SELECT namn , org, FNR, ANDEL, INSKDATUM
		 , nullif(CASE WHEN adressKommaFinns THEN
		     	substring(ADRESS, adressKomma + 2, LEN(ADRESS))
		    		 Else concat(POSTNR,' ',POSTORT) END ,'')
		     POSTNRPOSTORT
		 , nullif(CASE WHEN ADRESSKOMMAFINNS THEN
		     	left(ADRESS, adressKomma - 1)
		     		else ADRESS END,'')
		     ADRESS
		 FROM (select *,ADRESSKOMMA > 0 AND POSTORT IS NULL AND POSTNR IS NULL adresskommaFinns from (
		     select *,charindex(',', ADRESS) adressKomma from (
			 SELECT nullif(NAME,'') namn
			      , nullif(PERSORGNR,'') org
			      , REALESTATEKEY        FNR
			      , SHAREPART            ANDEL
			      , ACQUISITIONDATE      INSKDATUM
			      , ADDRESS              ADRESS
			      , NULL                 POSTORT
			      , NULL                 POSTNR
			 FROM [gisdata].SDE_GEOFIR_GOTLAND.GNG.INFO_CURRENTOWNER q
			    INNER JOIN #TOINSERT x on x.FNR = q.REALESTATEKEY
			 ) innerTemp
		     ) SRC) src)q
	        ) innerTemp2 ) SPLITADRESS) ADRESSSPLITTER)
    , rest AS (SELECT Z.FNR, null ORG, 		null ANDEL,null NAMN,  null  co, null ADRESS, null  adr2, null POSTNR, null POSTORT, null SRC from COLUMNPROCESSBADNESSSCORE z WHERE BADNESS > 1)
     --, rest as (SELECT * from ip except (SELECT fnr from SRC1LAGFARa))
    , SRC1LAGFARa AS (SELECT Z.FNR, Z.ORG, 	Z.ANDEL,Z.NAMN,  '' co, Z.ADRESS, '' adr2, Z.POSTNR, Z.POSTORT, SRC FROM COLUMNPROCESSBADNESSSCORE z WHERE BADNESS < 2)

SELECT * into #kalla from SRC1LAGFARa union all SELECT *from rest;
end
--drop table #fordig
if object_id('tempdb..#fordig') is null begin
    BEGIN TRANSACTION;
WITH
    SRC1LAGFARa as (SELECT * from #KALLA where src is not null)
    ,rest as (SELECT fnr from #KALLA WHERE src is null)

    , s1 as (select z.FNR,	PERSORGNR, z.andel,z.NAMN, FAL_CO, 		FAL_UTADR1, FAL_UTADR2, FAL_POSTNR, FAL_POSTORT , 	'lagfart' SRC FROM  [GISDATA].SDE_GEOFIR_GOTLAND.GNG.FA_LAGFART_V2 Z INNER JOIN REST IP ON IP.FNR = Z.FNR 	WHERE coalesce(nullif(FAL_CO,''), nullif(FAL_UTADR1,''), nullif(FAL_UTADR2,''), nullif(FAL_POSTNR,''), nullif(FAL_POSTORT,'')) IS NOT NULL)
    , s2 as (SELECT z.FNR,	PERSORGNR, z.andel,z.NAMN, SAL_CO, 		SAL_UTADR1, SAL_UTADR2, SAL_POSTNR, SAL_POSTORT , 	'lagfart' SRC  FROM [GISDATA].SDE_GEOFIR_GOTLAND.GNG.FA_LAGFART_V2 Z INNER JOIN REST IP ON IP.FNR = Z.FNR	WHERE coalesce(nullif(SAL_CO,''), nullif(SAL_UTADR1,''), nullif(SAL_UTADR2,''), nullif(SAL_POSTNR,''), nullif(SAL_POSTORT,'')) IS NOT NULL)
    , s3 as (SELECT z.FNR,	PERSORGNR, z.andel,z.NAMN, UA_UTADR1, 		UA_UTADR2,  UA_UTADR3, 	UA_UTADR4,  UA_LAND , 		'lagfart' SRC  FROM [GISDATA].SDE_GEOFIR_GOTLAND.GNG.FA_LAGFART_V2 Z INNER JOIN REST IP ON IP.FNR = Z.FNR 	WHERE coalesce(nullif(UA_UTADR1,''), nullif(UA_UTADR2,''), nullif(UA_UTADR3,''), nullif(UA_UTADR4,''), nullif(UA_LAND,'')) IS NOT NULL)

    , [3toOneUnion] AS (SELECT * FROM S1 UNION ALL select * FROM S2 UNION all SELECT * FROM S3 UNION ALL SELECT * FROM SRC1LAGFARA Z)

    , T1 AS (SELECT q.FNR, PERSORGNR, ANDEL, NAMN, FAL_CO, 		FAL_UTADR1, FAL_UTADR2, FAL_POSTNR, FAL_POSTORT,'TAXERINGAGARE' src  	FROM [GISDATA].SDE_GEOFIR_GOTLAND.GNG.FA_TAXERINGAGARE_V2 Q INNER JOIN (SELECT FNR FROM rest EXCEPT SELECT FNR FROM [3toOneUnion])x ON X.FNR = Q.FNR WHERE coalesce(nullif(FAL_CO,''), nullif(FAL_UTADR1,''), nullif(FAL_UTADR2,''), nullif(FAL_POSTNR,''), nullif(FAL_POSTORT,'')) IS NOT NULL)
    , T2 AS (SELECT q.FNR, PERSORGNR, ANDEL, NAMN, SAL_CO, 		SAL_UTADR1, SAL_UTADR2, SAL_POSTNR, SAL_POSTORT,'TAXERINGAGARE' src  	FROM [GISDATA].SDE_GEOFIR_GOTLAND.GNG.FA_TAXERINGAGARE_V2 Q INNER JOIN (SELECT FNR FROM rest EXCEPT SELECT FNR FROM [3toOneUnion])x ON X.FNR = Q.FNR WHERE coalesce(nullif(SAL_CO,''), nullif(SAL_UTADR1,''), nullif(SAL_UTADR2,''), nullif(SAL_POSTNR,''), nullif(SAL_POSTORT,'')) IS NOT NULL)
    , T3 AS (SELECT q.FNR, PERSORGNR, ANDEL, NAMN, UA_UTADR1, 		UA_UTADR2,  UA_UTADR3,  UA_UTADR4,  UA_LAND,    'TAXERINGAGARE' src  	FROM [GISDATA].SDE_GEOFIR_GOTLAND.GNG.FA_TAXERINGAGARE_V2 Q INNER JOIN (SELECT FNR FROM rest EXCEPT SELECT FNR FROM [3toOneUnion])x ON X.FNR = Q.FNR WHERE coalesce(nullif(UA_UTADR1,''), nullif(UA_UTADR2,''), nullif(UA_UTADR3,''), nullif(UA_UTADR4,''), nullif(UA_LAND,'')) IS NOT NULL)

    , [3toOneUnion2] as (select * from t1 union all SELECT * from t2 union all SELECT * from t3 UNION ALL SELECT FNR, PERSORGNR, ANDEL, NAMN,  FAL_CO, FAL_UTADR1, FAL_UTADR2, FAL_POSTNR, FAL_POSTORT, SRC from [3toOneUnion])

, FARDIG
    AS (SELECT FNR, PERSORGNR
	     , format(try_cast(CASE WHEN charindex('/', ANDEL, 1) > 0 THEN try_cast(left(ANDEL, charindex('/', ANDEL, 1) - 1) AS FLOAT) / try_cast(right(ANDEL, len(ANDEL) - charindex('/', ANDEL, 1)) AS FLOAT)END AS FLOAT), '0.00') ANDELMIN
	     , NAMN
	     , ltrim(replace(replace(ltrim(CONCAT(CASE WHEN FAL_POSTNR IS NULL THEN FAL_CO
			     ELSE nullif('c/o ' + FAL_CO + ', ', 'c/o , ')END, FAL_UTADR1, ' ', FAL_UTADR2, ', ', FAL_POSTNR, ' ', FAL_POSTORT)), '  ', ' '), ' , ', ', ')) ADRESS
	 , FAL_POSTORT   POSTORT, FAL_POSTNR POSTNR, SRC SOURCE FROM  [3toOneUnion2])
SELECT * into #fordig from FARDIG
        end ;
--SELECT * TOP 3 ANDEL unless noone owns more than 25 then add all
--drop table #fulaAttKorrigera
--drop table #Corrigerande
--DROP INDEX KorrigeringsIndex on #Corrigerande
;if object_id('tempdb..#fulaAttKorrigera') is null begin CREATE TABLE #fulaAttKorrigera ( Ägare nvarchar(200), Postadress nvarchar(200), POSTNR nvarchar(200), POSTORT nvarchar(200), [personnr/Organisationnr] nvarchar(200), SOURCE varchar(200), Id INTEGER NOT NULL DEFAULT 0 );;if object_id('tempdb..KorrigeringsIndex') is null begin CREATE INDEX KorrigeringsIndex on #fulaAttKorrigera(Ägare,POSTADRESS,POSTORT,POSTNR,[personnr/Organisationnr],SOURCE,id)end
;if object_id('tempdb..#Corrigerande') is null begin CREATE TABLE #Corrigerande (Ägare nvarchar(200), Postadress nvarchar(200), POSTNR nvarchar(200), POSTORT nvarchar(200), [personnr/Organisationnr] nvarchar(200), SOURCE varchar(200),Id INTEGER primary key NOT NULL DEFAULT 0);
INSERT INTO #fulaAttKorrigera(Ägare, Postadress, POSTNR, POSTORT,id) VALUES ('Staten FORTIFIKATIONSVERKET', ' ', '63189', 'ESKILSTUNA', 1), ('Staten SVERIGES LANTBRUKSUNIVERSITET', 'Box 7070 ', 'SLU,', '75007 UPPSALA', 2), ('Lasmi AB', 'c/o SANCHES SUAREZ ', N'Gustavsviksvägen', '36, 62141 VISBY', 3), (N'Koloniföreningen Kamraterna u.p.a.', 'c/o P JANSSON ', N'LINGVÄGEN', '219 LGH 1002, 12361 FARSTA', 4), ('Martin Plahn', N'RUDKÄLLAVÄGEN 2 ', 'BROLUNDA,', '15534 NYKVARN', 5), ('Kristine Torkelsdotter', 'c/o WESTER ', 'HELLVI', N'MALMS 955, 62450 LÄRBRO', 6), ('FRANZISKA SCHNEIDER-STOTZER', N'c/o GRABEN 43294 BÜREN A/A', '', 'SCHWEIZ', 7), ('TOMAS SCHNEIDER', N'c/o GRABEN 4,3294 BRÜEN A/A', '', 'SCHWEIZ', 8), (N'Föreningen Follingbo Folkets Hus u p a', 'c/o LARS ANDERSSON ', 'STORA', N'TÖRNEKVIOR 5, 62137 VISBY', 9), (N'W. Wetterström Smide Mek & Rörledningsfirma Handelsbolag', 'BOX 369 ', N'VITVÄRSVÄGEN', '3, 62325 LJUGARN', 10), ('Romaklosters pastorat', 'c/o ROMA PASTORSEXPEDITION ', N'VISBYVÄGEN', '33 B, 62254 ROMAKLOSTER', 11), (N'Gun Astrid Sörlin', 'c/o WALLIN ', N'STRANDVÄGEN', N'29, 62462 FÅRÖSUND', 12), ('Sirredarre AB', 'c/o LINDA JENSEN ', N'INGENJÖRSVÄGEN', '18 LGH 1202, 11759 STOCKHOLM', 14), (N'Niklas Per Emil Möller', '322 RODNEY STREET APT 17 BROOKLYN .N.Y., USA', '11211', 'BROOKLYN  .N.Y., USA', 15), (N'VÄSTERHEJDE FOLKETS HUS FÖRENING UPA', 'c/o SOCIALDEMOKRATERNA GOTLAND ', N'STENHUGGARVÄGEN', '6, 62153 VISBY', 16), (N'Aktiebolaget Lunds Allé Visby', N'c/o SÖDERSTRAND ', N'BERGGRÄND', '5, 62157 VISBY', 17), (N'VISBY ALLMÄNNA IDROTTSKLUBB', 'c/o VISBY AIK ', 'BOX', '1049, 62121 VISBY', 18), (N'Ludvig Söderberg', 'c/o RA EKONOMI AB ', 'HORNSGATAN', '103, 11728 STOCKHOLM', 19), ('Mats Wiktorsson', 'c/o JOVANOVIC ', 'SANKT', 'PAULSGATAN 14 LGH 1205, 11846 STOCKHOLM', 20), ('', 'c/o Ann-Sofie Ekedahl, Vadkastliden 5 ', '45196', 'UDDEVALLA',21), (N'GOTLANDS MOTORFÖRENINGS SPEEDWAYKLUBB', '1035 ', '62121', 'VISBY',22), (N'PRÄSTLÖNETILLGÅNGAR I VISBY STIFT', 'BOX 1334 ', '62124', 'VISBY',23)
,(N'VALLS GRUSTAG EK FÖR', 'ROSARVE VALL/M ENEKVIST/ ', '62193', 'VISBY',25),
('Introbolaget 4271 AB', 'c/o EKONOMERNA NB & IC HB ', N'TUVÄNGSVÄGEN', N'4, 15242 SÖDERTÄLJE',26);
INSERT INTO #fulaAttKorrigera(ÄGARE, POSTADRESS, POSTNR, POSTORT, [personnr/Organisationnr], SOURCE,id) VALUES (N'Lena Nordström', 'RUA EDUARDO HENRIQUES PEREIRA NO 1 ', 'BLOCO', '1, 2 B, 2655-267 ERICEIRA, PORTUGAL', '196204112764', 'geosecma',13), (N'Lena Katarina Nordström', '', '', 'PORTUGAL', '196204112764', 'lagfart',13)
,('Ingela Karin Spillmann', '', '', 'SCHWEIZ', '194003191246', 'lagfart',24);
END
 INSERT INTO #Corrigerande(Ägare, Postadress, POSTNR, POSTORT,id) VALUES
(N'Aktiebolaget Lunds Allé Visby', N'c/o SÖDERSTRAND, BERGGRÄND 5','62157','VISBY',17),
(N'FRANZISKA SCHNEIDER-STOTZER', N'Atelier Stadtgraben, Graben 4', 'CH-3294', N'Büren an der Aare, SCHWEIZ',7),
(N'Föreningen Follingbo Folkets Hus u p a ', N'c/o LARS ANDERSSON, STORA TÖRNEKVIOR 5','62137', 'VISBY',9),
(N'GOTLANDS MOTORFÖRENINGS', 'SPEEDWAYKLUBB 1035 ', '62121', 'VISBY',22),
(N'Gun Astrid Sörlin', N'c/o WALLIN, STRANDVÄGEN 29', '62462',N'FÅRÖSUND',12),
(N'Koloniföreningen Kamraterna u.p.a.', N'c/o P, JANSSONLINGVÄGEN 219 LGH 1002', '12361', 'FARSTA',4),
(N'Kristine Torkelsdotter','c/o WESTER, HELLVI MALMS 955', '62450', N'LÄRBRO',6),
(N'Lasmi AB c/o SANCHES SUAREZ', N'Gustavsviksvägen 36','62141', 'VISBY',3),
(N'Ludvig Söderberg', 'c/o RA EKONOMI AB, HORNSGATAN 103','11728','STOCKHOLM',19),
(N'Martin Plahn', N'RUDKÄLLAVÄGEN 2 BROLUNDA', '15534', 'NYKVARN',5),
(N'Mats Wiktorsson c/o JOVANOVIC', 'SANKT PAULSGATAN 14 LGH 1205','11846','STOCKHOLM',20),
(N'Niklas Per Emil Möller', '322 RODNEY STREET APT 17', '11211', 'BROOKLYN .N.Y., USA',15),
(N'PRÄSTLÖNETILLGÅNGAR I', 'VISBY STIFT BOX 1334 ', '62124', 'VISBY',23),
(N'Romaklosters pastorat', N'c/o ROMA PASTORSEXPEDITION, VISBYVÄGEN 33 B', '62254', 'ROMAKLOSTER',11),
(N'SVERIGES LANTBRUKSUNIVERSITET', 'SLU, Box 7070', '75007', 'UPPSALA',2),
(N'Sirredarre AB c/o LINDA JENSEN', N'INGENJÖRSVÄGEN 18 LGH 1202','11759','STOCKHOLM',14),
(N'Staten', 'FORTIFIKATIONSVERKET', '63189', 'ESKILSTUNA',1),
(N'TOMAS SCHNEIDER', N'Atelier Stadtgraben, Graben 4', 'CH-3294', N'Büren an der Aare, SCHWEIZ',8),
(N'VISBY ALLMÄNNA IDROTTSKLUBB', 'c/o VISBY AIK, BOX 1049','62121','VISBY',18),
(N'VÄSTERHEJDE FOLKETS HUS FÖRENING UPA', N'c/o SOCIALDEMOKRATERNA GOTLAND, STENHUGGARVÄGEN 6', '62153','VISBY',16),
(N'W. Wetterström Smide Mek & Rörledningsfirma Handelsbolag', N'BOX 369 VITVÄRSVÄGEN 3','62325', N'LJUGARN',10),
(N'c/o Ann-Sofie Ekedahl', 'Vadkastliden 5', '45196', 'UDDEVALLA',21),
(N'VALLS GRUSTAG EK FÖR', 'c/o M ENEKVIST, Vall rosarve', '62193', 'VISBY',25),
('Introbolaget 4271 AB c/o EKONOMERNA NB & IC HB', N'TUVÄNGSVÄGEN 4', N'15242', N'SÖDERTÄLJE',26);

INSERT INTO #Corrigerande(ÄGARE, POSTADRESS, POSTNR, POSTORT, [personnr/Organisationnr], SOURCE,id) VALUES
       (N'Lena Nordström', 'RUA EDUARDO HENRIQUES PEREIRA NO 1 BLOCO 1, 2 B', '2655-267','ERICEIRA, PORTUGAL', '196204112764', 'geosecma',13)
       ,('Spillmann Thulin, Ingela', 'Seestrasse 222', '8700', N'Küsnacht ZH SCHWEIZ', '194003191246', 'googlade tel.search.ch',24);
END
;
--o	Vilande – Gem. Anläggning
--o	Vilande – kommunal anslutning
--o	Väntande – uppskov
--o	Väntande – överklangande

--Excelfilen ska ha kolumnerna
          -- dia        Fastighet          Ägare                 Postadress       Postnr                Postort              Personnr          Organisationsnr statuskommentar
with
     KORRIGERANDE AS (SELECT #FULAATTKORRIGERA.ÄGARE
			   , #FULAATTKORRIGERA.POSTADRESS
			   , #FULAATTKORRIGERA.POSTNR
			   , #FULAATTKORRIGERA.POSTORT
			   , #FULAATTKORRIGERA.[personnr/Organisationnr]
			   , #FULAATTKORRIGERA.SOURCE
			   , #CORRIGERANDE.ÄGARE                     CÄGARE
			   , #CORRIGERANDE.POSTADRESS                CPOSTADRESS
			   , #CORRIGERANDE.POSTNR                    CPOSTNR
			   , #CORRIGERANDE.POSTORT                   CPOSTORT
			   , #CORRIGERANDE.[personnr/Organisationnr] CPERSONNRORGAN
			   , #CORRIGERANDE.SOURCE                    CSOURCE
			   , #CORRIGERANDE.ID
		      FROM #CORRIGERANDE
			  INNER JOIN #FULAATTKORRIGERA ON #CORRIGERANDE.ID = #FULAATTKORRIGERA.ID)
    ,first as (
SELECT dia Dnr, beteckning fastighet, isnull(NAMN,'') [Ägare], isnull(replace(replace(ADRESS,', '+postnr,''),postort,''),'') Postadress, isnull(POSTNR,'') POSTNR, isnull(POSTORT,'') POSTORT, isnull(replace(PERSORGNR,'-',''),'') [personnr/Organisationnr], isnull(SOURCE,'') source, isnull(STATUSKOMMENTAR,'') STATUSKOMMENTAR
from #fordig
    LEFT OUTER JOIN #TOINSERT on #fordig.FNR = #TOINSERT.FNR
    INNER join KirFnr
        ON coalesce(#FORDIG.FNR, #TOINSERT.FNR) = KirFnr.fnr)
select *,concat(row_number() OVER (PARTITION BY dnr ORDER BY FASTIGHET),'/',count([personnr/Organisationnr]) over (PARTITION BY dnr))  Antal from (SELECT distinct DNR, FASTIGHET,
       COALESCE(CÄGARE,FIRST.ÄGARE) ÄGARE, COALESCE(CPOSTADRESS, FIRST.POSTADRESS) POSTADRESS, COALESCE(CPOSTNR, FIRST.POSTNR) POSTNR, COALESCE(CPOSTORT,FIRST.POSTORT) POSTORT, COALESCE(CPERSONNRORGAN, FIRST.[personnr/Organisationnr])[personnr/Organisationnr], COALESCE(CSOURCE,FIRST.SOURCE)SOURCE, STATUSKOMMENTAR
from first
	LEFT OUTER JOIN  korrigerande on
	    coalesce(korrigerande.ÄGARE,			first.Ägare) = 				first.Ägare AND
   	    coalesce(korrigerande.POSTADRESS,			FIRST.POSTADRESS) = 			FIRST.POSTADRESS AND
   	    coalesce(korrigerande.POSTNR,			FIRST.POSTNR) = 			FIRST.POSTNR AND
   	    coalesce(korrigerande.POSTORT,			FIRST.POSTORT) = 			FIRST.POSTORT AND
   	    coalesce(korrigerande.[personnr/Organisationnr],	FIRST.[personnr/Organisationnr]) = 	FIRST.[personnr/Organisationnr] AND
	    coalesce(korrigerande.SOURCE,			FIRST.SOURCE) = 			FIRST.SOURCE) as c
order by STATUSKOMMENTAR,POSTNR,dnr,ÄGARE,POSTORT,POSTADRESS