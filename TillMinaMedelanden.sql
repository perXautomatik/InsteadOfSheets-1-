--hämta ärendenr från vision--drop TABLE #ALIAS--drop table #PATO

--;if object_id('tempExcel.dbo.AdressCorrection') is null begin CREATE SYNONYM AdressCorrection FOR tempExcel.dbo.[20201112Flaggor ägaruppgifter-nyutskick]  	end
--;if object_id('tempExcel.dbo.FastighetsLista') 	is null begin CREATE SYNONYM FastighetsLista for  tempExcel.dbo.[20201108ChristofferRäknarExcel]           	end
;if object_id('tempExcel.dbo.VisionArenden') 	is null begin CREATE SYNONYM VisionArenden for 	  [admsql04].[EDPVisionRegionGotland].DBO.VWAEHAERENDE          end
;if object_id('tempExcel.dbo.KirFnr') 		is null begin CREATE SYNONYM KirFnr for 	  [GISDATA].[sde_geofir_gotland].[gng].FA_FASTIGHET             end
;if object_id('tempExcel.dbo.FasAdresser') 	is null begin CREATE SYNONYM FasAdresser for 	  [GISDATA].[sde_geofir_gotland].[gng].FASTIGHETSADRESS_IG      end
;if object_id('tempExcel.dbo.VisionHandelser') 	is null begin CREATE SYNONYM VisionHandelser for  [admsql04].[EDPVisionRegionGotland].DBO.vwAehHaendelse 	END

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


;if object_id('tempdb..#SockenLista') is null begin CREATE table #SockenLista (socken NVARCHAR(50) NOT NULL PRIMARY KEY ) INSERT INTO #SockenLista VALUES
--(N'Kräklingbo'),('Alskog'),('Lau'),(N'När'),('Burs'),('Sjonhem')
    ('Follingbo'),('Hejdeby'),('Lokrume'),('Martebo'),(N'Träkumla'),('Visby'),(N'Västerhejde')
end

if object_id('tempdb..#toInsert') is null begin
begin TRANSACTION;
with
    --joinX as (select * from VisionArenden INNER join FastighetsLista ON coalesce(nullif(VisionArenden.strFastighetsbeteckning,''),strSoekbegrepp) = FastighetsLista.FASTIGHET),
    k as (
	SELECT vA.STRDIARIENUMMER Dia,coalesce(nullif(vA.STRFASTIGHETSBETECKNING, ''), va.STRSOEKBEGREPP) kir,STRFNRID fnr,va.strLogKommentar,strAerendeStatusPresent
		/*,isnull(h.STRRUBRIK,1) strUbrik,
	       nullif(a.STRAERENDEMENING,@ARMENING) mening,
	    	nullif(a.strAerendeStatusPresent,@STATUSFILTER1) status1,
	          nullif(a.strAerendeStatusPresent,@STATUSFILTER2) status2*/
	    FROM
	         (select STRDIARIENUMMER,STRFASTIGHETSBETECKNING,STRSOEKBEGREPP,STRFNRID,strLogKommentar,strAerendeStatusPresent,STRAERENDEMENING,RECAERENDEID from  VISIONARENDEN) va
	    INNER JOIN #SOCKENLISTA ON LEFT(coalesce(nullif(va.STRFASTIGHETSBETECKNING, ''), va.STRSOEKBEGREPP), len(SOCKEN)) = SOCKEN
	    LEFT OUTER JOIN
	        (select RECAERENDEID, (case when strRubrik is null then @HandKat else strRubrik end) strRubrikx from VisionHandelser
	        WHERE  VisionHandelser.strHaendelseKategori = @HandKat or
	              strRubrik like @HANDRUBRIK1 Or
	              strRubrik like @HANDRUBRIK2 ) H
	        ON va.RECAERENDEID = h.RECAERENDEID
		Where va.STRAERENDEMENING = @ARMENING AND not( va.strAerendeStatusPresent =@STATUSFILTER1  or va.strAerendeStatusPresent= @STATUSFILTER2  )
		and
	      		h.strRubrikx IS NULL
	)
    /*SELECT *  from k end drop table #toInsert
*/
   ,correctFnr as (select DIA, coalesce(KirFnr.Fnr,a.fnr) Fnr,a.strLogKommentar FROM k a LEFT OUTER JOIN KirFnr ON a.KIR = KirFnr.BETECKNING ) --vision has sometimes a internal nr instad of fnr in the fnrcolumn
  ,toInsert as (select strLogKommentar statuskommentar
  ,DIA,Fnr from correctFnr)

    --insert into @inputFnr (id,Diarienummer,Fnr,fastighet,HÄNDELSEDATUM ) --;if object_id('tempdb..#TRM') is null begin begin  TRANSACTION--SELECT * INTO #TRM from @INPUTFNR ;--END adressCorrecting = gisTable1 -- don't think the view of gisTable1 has 3 segments, so union is not nessessary.--    ip as (select fnr from @INPUTFNR),
select *, GETDATE() inskdatum
into #toInsert
from toInsert
end
;
--drop table #toInsert
--drop table #kalla
--drop table #fordig

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
	    , nullif(CASE WHEN spaceLoc > 0 THEN substring(POSTNRPOSTORT, spaceLoc + 1, LEN(POSTNRPOSTORT)) END,'') POSTORT
	    , nullif(CASE WHEN spaceLoc > 0 THEN  left(POSTNRPOSTORT, spaceLoc - 1) END,'') POSTNR
	    FROM (select *,charindex(' ', POSTNRPOSTORT) spaceLoc from
		 (SELECT nullif(NAME,'') namn , nullif(PERSORGNR,'') org, FNR, ANDEL, INSKDATUM
		 , CASE WHEN CommaLoc > 0 AND POSTORT IS NULL AND POSTNR IS NULL THEN substring(ADRESS, CommaLoc + 2, LEN(ADRESS))Else concat(POSTNR,' ',POSTORT) END POSTNRPOSTORT
		 , nullif(CASE WHEN CommaLoc > 0 AND POSTORT IS NULL AND POSTNR IS NULL THEN left(ADRESS, CommaLoc - 1) else ADRESS END,'') ADRESS
		 FROM (select *,charindex(',', ADRESS) CommaLoc from (
		     SELECT NAME
			  , PERSONORGANISATIONNR PERSORGNR
			  , REALESTATEKEY        FNR
			  , SHAREPART            ANDEL
			  , ACQUISITIONDATE      INSKDATUM
			  , ADDRESS              ADRESS
			  , NULL                 POSTORT
			  , NULL                 POSTNR
		     FROM [gisdata].SDE_GEOFIR_GOTLAND.GNG.INFO_CURRENTOWNER q
		     	INNER JOIN #TOINSERT x on x.FNR = q.REALESTATEKEY
		     ) SRC) src)q) SPLITADRESS) ADRESSSPLITTER)
    , rest AS (SELECT Z.FNR, null ORG, 		null ANDEL,null NAMN,  null  co, null ADRESS, null  adr2, null POSTNR, null POSTORT, null SRC from COLUMNPROCESSBADNESSSCORE z WHERE BADNESS > 1) --, rest as (SELECT * from ip except (SELECT fnr from SRC1LAGFARa))
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