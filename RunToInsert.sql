
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