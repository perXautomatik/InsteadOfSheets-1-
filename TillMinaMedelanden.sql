
with
     KORRIGERANDE AS (SELECT ##FULAATTKORRIGERA.ÄGARE
			   , ##FULAATTKORRIGERA.POSTADRESS
			   , ##FULAATTKORRIGERA.POSTNR
			   , ##FULAATTKORRIGERA.POSTORT
			   , ##FULAATTKORRIGERA.[personnr/Organisationnr]
			   , ##FULAATTKORRIGERA.SOURCE
			   , ##CORRIGERANDE.ÄGARE                     CÄGARE
			   , ##CORRIGERANDE.POSTADRESS                CPOSTADRESS
			   , ##CORRIGERANDE.POSTNR                    CPOSTNR
			   , ##CORRIGERANDE.POSTORT                   CPOSTORT
			   , ##CORRIGERANDE.[personnr/Organisationnr] CPERSONNRORGAN
			   , ##CORRIGERANDE.SOURCE                    CSOURCE
			   , ##CORRIGERANDE.ID
		      FROM ##CORRIGERANDE
			  INNER JOIN ##FULAATTKORRIGERA ON ##CORRIGERANDE.ID = ##FULAATTKORRIGERA.ID)
    ,first as (
SELECT dia Dnr, beteckning fastighet, isnull(NAMN,'') [Ägare], isnull(replace(replace(ADRESS,', '+postnr,''),postort,''),'') Postadress, isnull(POSTNR,'') POSTNR, isnull(POSTORT,'') POSTORT, isnull(replace(PERSORGNR,'-',''),'') [personnr/Organisationnr], isnull(SOURCE,'') source, isnull(STATUSKOMMENTAR,'') STATUSKOMMENTAR
from ##fordig
    LEFT OUTER JOIN ##TOINSERT on ##fordig.FNR = ##TOINSERT.FNR
    INNER join KirFnr
        ON coalesce(##FORDIG.FNR, ##TOINSERT.FNR) = KirFnr.fnr)
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