:r TillMinaMedelanden/header.sql
with
    TrimValues as (select ##d3AdressSplitt.i,C_O,ltrim(Adress2) as adress,ltrim(##d3AdressSplitt.PostOrt) as PostOrt2,##del2.POSToRT,ltrim(postnr) as postnr,POSTNUMMER,##d3AdressSplitt.adress as orgAdrr from ##d3AdressSplitt join ##del2 on ##d3AdressSplitt.i = ##del2.i),

    fixPostOrt as (select i,C_O,adress,PostOrtZ = case when PostOrt2 like '%' + ress.POSToRT then ress.POSToRT else case when PostOrt2 is null then postort else PostOrt2 end end,postnr =case when PostOrt2 like cast(POSTNUMMER as varchar(255)) + '%' then cast(POSTNUMMER as varchar(255))else case when POSTNUMMER is null then postnr else cast(POSTNUMMER as varchar(255)) end end,ress.POSToRT,orgAdrr from (select i,C_O,adress,cast(PostOrt2 as varchar(255)) as PostOrt2,POSToRT,postnr,POSTNUMMER,orgAdrr from TrimValues) as ress),

    GroupAdresses as (select C_O,adress,PostOrtZ as postort,postnr as POSTNUMMER,max(andel) as andel,namn,BETECKNING,arndenr from ##del1 join fixPostOrt on ##del1.i = fixPostOrt.i group by C_O, adress, PostOrtZ, postnr,  namn, BETECKNING, arndenr),

    ParaMakeMaka as (select ANDEL as justForVisual,POSTORT,C_O,POSTNUMMER,ADRESS,NAMN,(select top 1 namn from GroupAdresses as x where x.BETECKNING = GroupAdresses.BETECKNING AND x.ADRESS = GroupAdresses.ADRESS and x.NAMN <> GroupAdresses.NAMN) as Namn2,BETECKNING,arndenr from GroupAdresses),

    MakeMaka as (select fra,C_O,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr,rn from (SELECT master.dbo.FracToDec(justForVisual) as fra,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,C_O,Namn2,BETECKNING,arndenr,ROW_NUMBER() OVER (PARTITION BY (case when ParaMakeMaka.Namn2 is not null then case when ParaMakeMaka.NAMN > ParaMakeMaka.namn2 then ParaMakeMaka.NAMN + ParaMakeMaka.Namn2 else ParaMakeMaka.Namn2 + ParaMakeMaka.NAMN end else ParaMakeMaka.NAMN end),BETECKNING ORDER BY BETECKNING,ADRESS ) As rn FROM ParaMakeMaka) t where t.rn = 1),

    grupperaEfterAndel as (select fra,C_O,justForVisual,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr,ROW_NUMBER() OVER (PARTITION BY BETECKNING ORDER BY fra desc ) As rn from MakeMaka),

    filterBadAdress as (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr from grupperaEfterAndel where POSTORT is not null and POSTNUMMER is not null and ADRESS is not null and NAMN is not null),

    filterSmallOwnersBadAdress as (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,
                                          NAMN,Namn2,BETECKNING,arndenr,RowNum from (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr,RowNum from (select q.fra,q.C_O,q.POSTORT,q.POSTNUMMER,q.ADRESS,q.NAMN,q.Namn2,q.BETECKNING,q.arndenr,ROW_NUMBER() OVER ( PARTITION BY q.arndenr ORDER BY q.fra desc) RowNum from filterBadAdress as q INNER JOIN filterBadAdress thethree ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X WHERE X.RowNum = 1) as asdasd union select *from (select *from (select q.fra,q.C_O,q.POSTORT,q.POSTNUMMER,q.ADRESS,q.NAMN,q.Namn2,q.BETECKNING,q.arndenr,ROW_NUMBER() OVER ( PARTITION BY q.arndenr ORDER BY q.fra desc ) RowNum from filterBadAdress as q INNER JOIN filterBadAdress thethree ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X WHERE X.RowNum > 1 and X.RowNum < 4 AND fra > 0.3) as asdasdx)

    --select refx.Diarienr,qlx.BETECKNING,qlx.C_O,qlx.POSTORT, qlx.POSTNUMMER,qlx.ADRESS,qlx.NAMN, qlx.Namn2  from (select fra,C_O,POSTORT,POSTNUMMER,ADRESS,NAMN,Namn2,BETECKNING,arndenr from filterSmallOwnersBadAdress where POSTNUMMER <> '') as qlx right outer join (select Diarienr from [tempExcel].[dbo].[FNRKIRDIARENR_FörUtskick]) as refx on refx.Diarienr = qlx.arndenr
	select * from GroupAdresses

:r TillMinaMedelanden/DropTemps