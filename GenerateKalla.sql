
--;if object_id('tempdb..#FulaAdresser') is null begin CREATE table #FulaAdresser (adress NVARCHAR NOT NULL PRIMARY KEY ) INSERT INTO #FulaAdresser VALUES('DALHEM HALLVIDE 119, HALFVEDE, 62256 DALHEM'), ('c/o LILIAN PETTERSSON, SANDA STENHUSE 310'), ('DALHEM GRANSKOGS 966'), ('GRANSKOGS DALHEM 966'), (N'GAMLA NORRBYV�GEN 15, �STRA T�CKER�KER, 13674 NORRBY'), (N'�STRA T�CKER�KER GAMLA NORRBYV�GEN 15'), (N'ALVA GUDINGS 328 V�N 2, GAMLA SKOLAN, 62346 HEMSE'), ('DALHEM KAUNGS 538, DUNBODI, 62256 DALHEM'), ('HERTZBERGSGATE 3 A0360 OSLO NORGE'), ('DALHEM HALLVIDE 119, HALFVEDE'), ('OLAV M. TROVIKS VEI 500864 OSLO NORGE'), ('LORNSENSTR. 30DE-24105 KIEL TYSKLAND'), (N'FR�LINGSSTRASSE 3882110 GERMENING TYSKLAND'), (N'c/o F�RENINGEN GOTLANDST�GET H�SSELBY 166'), ('c/o TRYGGVE PETTERSSON KAUNGS 524'), (N'c/o L. ANDERSSON DJURSTR�MS V�G 11'), (N'PR�STBACKEN 8'), ('HALLA BROE 105'), (N'GAMLA SKOLAN ALVA GUDINGS 328 V�N 2')
--end;

if object_id('tempdb..#kalla') is null begin
    BEGIN TRANSACTION;
    if object_id('tempdb..#fordig') is not null begin drop table #FORDIG END;
with
    COLUMNPROCESSBADNESSSCORE AS (   SELECT FNR , org , ANDEL , namn , INSKDATUM , adress ,  POSTORT ,  POSTNR , 'geosecma' src
    , ((IIF(namn IS NULL, 1, 0)) + (IIF(postnr IS NULL, 1, 0)) + (IIF(postort IS NULL, 1, 0))
	+ (IIF(adress IS NULL, 1, 0)) + (IIF(org is NULL, 1, 0))) BADNESS
	FROM (SELECT namn, org, FNR, ANDEL, INSKDATUM, ADRESS
	    , nullif(CASE WHEN postNrAvsk > 0 THEN substring(POSTNRPOSTORT, postNrAvsk + 1, LEN(POSTNRPOSTORT)) END,'') POSTORT
	    , nullif(CASE WHEN postNrAvsk > 0 THEN left(POSTNRPOSTORT, postNrAvsk - 1) END,'') POSTNR
	    FROM (select * from (
	        select *,charindex(' ', POSTNRPOSTORT) postNrAvsk from
		 (SELECT namn , org, FNR, ANDEL, INSKDATUM
		 , nullif(IIF(adressKommaFinns, substring(ADRESS, adressKomma + 2, LEN(ADRESS)),
			      concat(POSTNR, ' ', POSTORT)), '')
		     POSTNRPOSTORT
		 , nullif(IIF(ADRESSKOMMAFINNS, left(ADRESS, adressKomma - 1), ADRESS), '')
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