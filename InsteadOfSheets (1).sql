
    --create temp table to add an identity column
    create table dbo.#TempWithIdentity(i int not null identity(1,1) primary key,POSTORT varchar(255), POSTNUMMER int, ADRESS varchar(255), NAMN varchar(255), andel varchar(255), BETECKNING varchar(255), ärndenr varchar(255),
                                       #TempWithIdentity int not null)
    --populate the temporary table
    insert into dbo.#TempWithIdentity(i,ANDEL, POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr)
    select max(nrx) as i, max(ANDEL) as ANDEL, POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr from (select top 10 row_number() over (order by newid()) as nrx,* from #TempWithIdentity) TempWithIdentityx
                                group by POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, ärndenr;

  --        union
   --       select ANDEL, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, ärndenr
   --       from (select POSTORT, POSTNUMMER, ADRESS, NAMN, andel, ÄrendeNr4års2019.Fastighet as BETECKNING, ärndenr
    --            from tempExcel.dbo.årsPåm2019Compl
    --                     join tempExcel.dbo.ÄrendeNr4års2019
    --                          on ÄrendeNr4års2019.Fastighet = årsPåm2019Compl.Fastighet) as asdas
    --
    --


with
         CompletteratOrginal as (select * from #tempWithIdentity),

            del1 as (select andel, namn, BETECKNING, ärndenr,i from CompletteratOrginal),
            del2 as (select POSTORT, POSTNUMMER, adress,i from CompletteratOrginal),

            splitAdressCTE AS (SELECT f.*, i FROM (SELECT adress, i FROM del2) X CROSS APPLY (SELECT Rn=ROW_NUMBER() Over (Partition by X.adress Order by X.adress),X.adress, ExtractedValuesFromNames = value FROM STRING_SPLIT(X.adress, ',') AS D) f),

            d3AdressSplitt as (SELECT i,adress,C_O = (case when (select max(c2.rn)from splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 1 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else null end),Adress2 = (case when (select max(c2.rn)from splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 2 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 1 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '') end),PostOrt = (case when (select max(c2.rn)from splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 3 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 2 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '') end),postnr  = (case when (select max(c2.rn)from splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)) >= 4 then STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn >= 4 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '')else STUFF((SELECT '' + c2.ExtractedValuesFromNames + ' ' FROM splitAdressCTE c2 WHERE (c2.ADRESS = c1.ADRESS)and c2.Rn = 3 group by c2.ExtractedValuesFromNames FOR XML PATH ('')), 1, 0, '') end)FROM splitAdressCTE c1 group by nrx, adress),

            TrimValues as (select d3AdressSplitt.nrx,C_O,ltrim(Adress2) as adress,ltrim(d3AdressSplitt.PostOrt) as PostOrt2,del2.POSToRT,ltrim(postnr) as postnr,POSTNUMMER,d3AdressSplitt.adress as orgAdrr from d3AdressSplitt join del2 on d3AdressSplitt.nrx = del2.nrx),

            fixPostOrt as (select nrx,C_O,adress,PostOrtZ = case when PostOrt2 like '%' + ress.POSToRT then ress.POSToRT else case when PostOrt2 is null then postort else PostOrt2 end end,postnr =case when PostOrt2 like cast(POSTNUMMER as varchar(255)) + '%' then cast(POSTNUMMER as varchar(255))else case when POSTNUMMER is null then postnr else cast(POSTNUMMER as varchar(255)) end end,ress.POSToRT,orgAdrr from (select nrx,C_O,adress,cast(PostOrt2 as varchar(255)) as PostOrt2,POSToRT,postnr,POSTNUMMER,orgAdrr from TrimValues) as ress),

            GroupAdresses as (select C_O,adress,PostOrtZ as postort,postnr as POSTNUMMER,max(andel) as andel,namn,BETECKNING,ärndenr from del1 join fixPostOrt on del1.nrx = fixPostOrt.nrx group by C_O, adress, PostOrtZ, postnr,  namn, BETECKNING, ärndenr),

            ParaMakeMaka as (select ANDEL as justForVisual,POSTORT,C_O,POSTNUMMER,ADRESS,NAMN,(select top 1 namn from GroupAdresses as x where x.BETECKNING = GroupAdresses.BETECKNING AND x.ADRESS = GroupAdresses.ADRESS and x.NAMN <> GroupAdresses.NAMN) as Namn2,BETECKNING,ärndenr from GroupAdresses),

            MakeMaka as (select fra,C_O,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr,rn from (SELECT master.dbo.FracToDec(justForVisual)                                                                      as fra,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,C_O,Namn2,BETECKNING,ärndenr,ROW_NUMBER() OVER (PARTITION BY (case when ParaMakeMaka.Namn2 is not null then case when ParaMakeMaka.NAMN > ParaMakeMaka.namn2 then ParaMakeMaka.NAMN + ParaMakeMaka.Namn2 else ParaMakeMaka.Namn2 + ParaMakeMaka.NAMN end else ParaMakeMaka.NAMN end),BETECKNING ORDER BY BETECKNING,ADRESS ) As rn FROM ParaMakeMaka) t where t.rn = 1),

            grupperaEfterAndel as (select fra,C_O,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr,ROW_NUMBER() OVER (PARTITION BY BETECKNING ORDER BY fra desc ) As rn from MakeMaka),

            filterBadAdress as (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr from grupperaEfterAndel where POSTORT is not null and POSTNUMMER is not null and ADRESS is not null and NAMN is not null),

            filterSmallOwnersBadAdress as (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr,RowNum from (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,ärndenr,RowNum from (select q.fra,q.C_O,q.POSTORT,q.POSTNUMMER,q.ADRESS,q.NAMN,q.Namn2,q.BETECKNING,q.ärndenr,ROW_NUMBER() OVER ( PARTITION BY q.ärndenr ORDER BY q.fra desc) RowNum from filterBadAdress as q INNER JOIN filterBadAdress thethree ON q.ärndenr = thethree.ärndenr and q.namn = thethree.namn) X WHERE X.RowNum = 1) as asdasd union select *from (select *from (select q.fra,q.C_O,q.POSTORT,q.POSTNUMMER,q.ADRESS,q.NAMN,q.Namn2,q.BETECKNING,q.ärndenr,ROW_NUMBER() OVER ( PARTITION BY q.ärndenr ORDER BY q.fra desc ) RowNum from filterBadAdress as q INNER JOIN filterBadAdress thethree ON q.ärndenr = thethree.ärndenr and q.namn = thethree.namn) X WHERE X.RowNum > 1 and X.RowNum < 4 AND fra > 0.3) as asdasdx)

    select C_O,
           POSTORT,
           POSTNUMMER,
           ADRESS,
           NAMN,
           Namn2,
           BETECKNING,
           ärndenr

    from filterSmallOwnersBadAdress

drop table dbo.#TempWithIdentity;