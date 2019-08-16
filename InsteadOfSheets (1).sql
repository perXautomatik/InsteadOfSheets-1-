--ressultatet vi vill ha är formatet
--BETECKNING,NAMN,NAMN2,Ärendenr, c_o,ADRESS,POSTORT where adress is not more than 33 char long
-- if adress is null, on one of receptant, take the non null val
--ANDEL, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, ärndenr,

   /* --Check for existance
använd geofir databas istället för att importera csv fil, enda csvn skall ha är ärendenr och fastighet.


***** Script for SelectTopNRows command from SSMS  *****/
/*exec sp_addlinkedserver @server = GISDATA*/

/*SELECT hidev.FNR,hidev.BETECKNING,
       [ANDEL],[AGTYP],[NAMN],[NAMN_OMV],[TNMARK],[FNAMN],[MNAMN],[ENAMN],[KORTNAMN],[KORTNAMN_OMV],[FAL_CO],[FAL_UTADR1],[FAL_UTADR2],[FAL_POSTNR],[FAL_POSTORT],[SAL_CO],[SAL_UTADR1],[SAL_UTADR2],[SAL_POSTNR],[SAL_POSTORT],[UA_UTADR1],[UA_UTADR2],[UA_UTADR3],[UA_UTADR4],[UA_LAND]into OrginalAndGeofir FROM [GISDATA].sde_geofir_gotland.gng.FA_TAXERINGAGARE_V2 AS tax LEFT JOIN (SELECT fa.FNR, fa.BETECKNING FROM Hideviken left JOIN GISDATA.sde_geofir_gotland.gng.FA_FASTIGHET AS fa ON _FASTIGHET_ = fa.BETECKNING where fa.BETECKNING is not null ) AS hidev ON hidev.FNR = tax.FNR where hidev.BETECKNING is not null;
*/
--drop table dbo.#TempWithIdentity

--create temp table to add an identity column
--create table dbo.#TempWithIdentity(i int not null identity(1,1) primary key,POSTORT varchar(255), POSTNUMMER int, ADRESS varchar(255), NAMN varchar(255), andel varchar(255), BETECKNING varchar(255), ärndenr varchar(255))
--populate the temporary table
--insert into dbo.#TempWithIdentity(ANDEL, POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr) select ANDEL, POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr from
  --  (select ANDEL, POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr from
  --OrginalAndGeofir
   -- qvc union select ANDEL, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, ärndenr from (select POSTORT, POSTNUMMER, ADRESS, NAMN, andel, ÄrendeNr4års2019.Fastighet as BETECKNING, ärndenr from tempExcel.dbo.årsPåm2019Compl join tempExcel.dbo.ÄrendeNr4års2019 on ÄrendeNr4års2019.Fastighet = årsPåm2019Compl.Fastighet) as asdas)
    --as sdf;

with
            TempWithIdentity as (select row_number() over (order by newid()) as i,* from InputPlusGeofir),
            CompletteratOrginal as (select max(i) as nrx, max(ANDEL) as ANDEL, POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr from TempWithIdentity
                                group by POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr),

            del1 as (select andel, namn, BETECKNING, ärndenr,nrx from CompletteratOrginal),
            del2 as (select POSTORT, POSTNUMMER, adress,nrx from CompletteratOrginal),

            splitAdressCTE AS (SELECT f.*, nrx FROM (SELECT adress, nrx FROM del2) X CROSS APPLY (SELECT Rn=ROW_NUMBER() Over (Partition by X.adress Order by X.adress),X.adress, ExtractedValuesFromNames = value FROM STRING_SPLIT(X.adress, ',') AS D) f),

            d3AdressSplitt as (SELECT nrx,adress,C_O = (case when (select max(c2.rn)from splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 1 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else null end),Adress2 = (case when (select max(c2.rn)from splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 2 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 1 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '') end),PostOrt = (case when (select max(c2.rn)from splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 3 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 2 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '') end),postnr  = (case when (select max(c2.rn)from splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn >= 4 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 3 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '') end)FROM splitAdressCTE c1 group by nrx, adress),

            TrimValues as (select d3AdressSplitt.nrx,C_O,ltrim(Adress2) as adress,ltrim(d3AdressSplitt.PostOrt) as PostOrt2,del2.POSToRT,ltrim(postnr)                 as postnr,POSTNUMMER,d3AdressSplitt.adress as orgAdrr from d3AdressSplitt join del2 on d3AdressSplitt.nrx = del2.nrx),

            fixPostOrt as (select nrx,C_O,adress,PostOrtZ = case when PostOrt2 like '%' + ress.POSToRT then ress.POSToRT else case when PostOrt2 is null then postort else PostOrt2 end end,postnr =case when PostOrt2 like cast(POSTNUMMER as varchar(255)) + '%' then cast(POSTNUMMER as varchar(255))else case when POSTNUMMER is null then postnr else cast(POSTNUMMER as varchar(255)) end end,ress.POSToRT,orgAdrr from (select nrx,C_O,adress,cast(PostOrt2 as varchar(255)) as PostOrt2,POSToRT,postnr,POSTNUMMER,orgAdrr from TrimValues) as ress),

            GroupAdresses as (select C_O,adress,PostOrtZ as postort,postnr as POSTNUMMER,max(andel) as andel,namn,BETECKNING,ärndenr from del1 join fixPostOrt on del1.nrx = fixPostOrt.nrx group by C_O, adress, PostOrtZ, postnr,  namn, BETECKNING, ärndenr),

            ParaMakeMaka as (select ANDEL as justForVisual,POSTORT,C_O,POSTNUMMER,ADRESS,NAMN,(select top 1 namn from GroupAdresses as x where x.BETECKNING = GroupAdresses.BETECKNING AND x.ADRESS = GroupAdresses.ADRESS and x.NAMN <> GroupAdresses.NAMN) as Namn2,BETECKNING,ärndenr from GroupAdresses),

            MakeMaka as (select fra,C_O,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr,rn from (SELECT master.dbo.FracToDec(justForVisual)                                                                      as fra,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,C_O,Namn2,BETECKNING,ärndenr,ROW_NUMBER() OVER (PARTITION BY (case when ParaMakeMaka.Namn2 is not null then case when ParaMakeMaka.NAMN > ParaMakeMaka.namn2 then ParaMakeMaka.NAMN + ParaMakeMaka.Namn2 else ParaMakeMaka.Namn2 + ParaMakeMaka.NAMN end else ParaMakeMaka.NAMN end),BETECKNING ORDER BY BETECKNING,ADRESS ) As rn FROM ParaMakeMaka) t where t.rn = 1),

            grupperaEfterAndel as (select fra,C_O,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr,ROW_NUMBER() OVER (PARTITION BY BETECKNING ORDER BY fra desc ) As rn from MakeMaka),

            filterBadAdress as (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr from grupperaEfterAndel where POSTORT is not null and POSTNUMMER is not null and ADRESS is not null and NAMN is not null),

            filterSmallOwnersBadAdress as (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr,RowNum from (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr,RowNum from (select q.fra,q.C_O,q.POSTORT,q.POSTNUMMER,q.ADRESS,q.NAMN,q.Namn2,q.BETECKNING,q.ärndenr,ROW_NUMBER() OVER ( PARTITION BY q.ärndenr ORDER BY q.fra desc) RowNum from filterBadAdress as q INNER JOIN filterBadAdress thethree ON q.ärndenr = thethree.ärndenr and q.namn = thethree.namn) X WHERE X.RowNum = 1) as asdasd union select *from (select *from (select q.fra,q.C_O,q.POSTORT,q.POSTNUMMER,q.ADRESS,q.NAMN,q.Namn2,q.BETECKNING,q.ärndenr,ROW_NUMBER() OVER ( PARTITION BY q.ärndenr ORDER BY q.fra desc ) RowNum from filterBadAdress as q INNER JOIN filterBadAdress thethree ON q.ärndenr = thethree.ärndenr and q.namn = thethree.namn) X WHERE X.RowNum > 1 and X.RowNum < 4 AND fra > 0.3) as asdasdx),

            errorAdress as (select POSTORT, POSTNUMMER, ADRESS, NAMN, Namn2, Fastighet, ÄrendeNr4års2019.ärndenr from filterSmallOwnersBadAdress right outer join ÄrendeNr4års2019 on ÄrendeNr4års2019.ärndenr = filterSmallOwnersBadAdress.ärndenr where namn is null)

            ,errorcheck as (  select Fastighet as eFas,errorAdress.ärndenr as eÄr, asdasd.*from errorAdress left outer join  MakeMaka as asdasd on errorAdress.Fastighet = asdasd.BETECKNING)

select
       C_O,
       POSTORT,
       POSTNUMMER,
       ADRESS,
       NAMN,
       Namn2,
       BETECKNING,
       ärndenr

from filterSmallOwnersBadAdress

--drop table dbo.#TempWithIdentity
