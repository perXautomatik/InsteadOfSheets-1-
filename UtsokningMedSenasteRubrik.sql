begin transaction

use tempExcel;
:r TillMinaMedelanden/CreateKirToFnr.sql
:r TillMinaMedelanden/CreateFnrToAdress.sql
:r TillMinaMedelanden/CreateHandelseTableType.sql
:r TillMinaMedelanden/CreateCheckThatItsNotBadHadelseNamn.sql
:r TillMinaMedelanden/CreateFilterByHasArende

with
     utanOnödigaHandlingar as (SELECT [Diarienummer]  "dianr", [Händelsedatum] "dat", [Riktning]      "rikt", [Rubrik]        "rub", [Ärendets huvudfastighet] "kir", text Kommentar
     from Bootstrap_HändelseTexter where [dbo].[checkThatItsNotBadHadelseNamn]([Rubrik]) = 1 AND [Diarienummer] <> '--- Makulerad ---')
    ,harBeslut as (select distinct dianr, 'beslut' as hasBes from utanOnödigaHandlingar where rub like '%beslut%' AND rikt = N'Utgående' group by dianr), harForbud as (select distinct dianr, N'förbud' as hasForb from utanOnödigaHandlingar where rub = N'Beslut om förbud avlopp' AND rikt = N'Utgående' group by dianr)
    ,SenastInkommande as (select dianr, max(rub) "rub", max(dat) "maxDat" from utanOnödigaHandlingar where rikt = 'inkommande' group by dianr)
    ,senastKontaktMedHandelsetext as (select dianr, (select top 1 [Kommentar] HandelseText from utanOnödigaHandlingar as Tinner where [Kommentar] is not null AND (left(rub, len(N'Kontakt i ärende')) = ('Kontakt i ärende') OR left(rub, len('Information om')) = ('Information om'))and Tinner.dianr = Touter.dianr order by dat) as senastKontakt from utanOnödigaHandlingar as Touter)
    ,ingenKontaktTextArenden as (select utanOnödigaHandlingar.dianr, rub, dat from utanOnödigaHandlingar right join (select * from senastKontaktMedHandelsetext where senastKontakt is null) senasteHandelseIfallIntoKontakt on utanOnödigaHandlingar.dianr = senasteHandelseIfallIntoKontakt.dianr)
    ,senasteHendelseOmInteText as (select dianr, (select top 1 rub from ingenKontaktTextArenden as Tinner where Tinner.dianr = Touter.dianr order by dat) as senastRub from utanOnödigaHandlingar as Touter)
    ,verkarBra as (select distinct kir, senasteHendelseOmInteText.dianr, isnull(senastKontakt, senastRub) senaste from (select Bootstrap_HändelseTexter.[Diarienummer], Bootstrap_HändelseTexter.[Ärendets huvudfastighet] kir from Bootstrap_HändelseTexter group by Diarienummer, Bootstrap_HändelseTexter.[Ärendets huvudfastighet]) ref left outer join senastKontaktMedHandelsetext on ref.Diarienummer = senastKontaktMedHandelsetext.dianr left outer join senasteHendelseOmInteText on senasteHendelseOmInteText.dianr = ref.Diarienummer left outer join diarienummerMedAnsokan on diarienummerMedAnsokan.dianr = ref.Diarienummer where has is null )
    ,tobeJoinedWithFir as (select kir,senaste, r.* from verkarBra left outer join (select max(Diarienummer) Diarienummer,[Ärendets huvudfastighet] from Bootstrap_HändelseTexter group by [Ärendets huvudfastighet]) Bootstrap_HändelseTexter on [Ärendets huvudfastighet] = verkarBra.kir left outer join [tempExcel].dbo.ÄrendensSenasteKonaktMedH r on Bootstrap_HändelseTexter.Diarienummer = r.Diarienummer where senaste is not null)
    ,doesWithoutAdress as (select * from tobeJoinedWithFir where Händelsedatum is null)
    ,doesWithAdress as (select * from tobeJoinedWithFir where Händelsedatum is not null)
    ,nowHasFnr as (select distinct kir,dbo.KirToFnr(kir) fnr from doesWithoutAdress)
    ,joinRessults as (select kir,senaste,Diarienummer,Händelsedatum,HändelseNamn,HändelseGatuadress,HändelsePostNummer from doesWithAdress union select nowHasFnr.kir,doesWithoutAdress.senaste,doesWithoutAdress.Diarienummer,doesWithoutAdress.Händelsedatum,namn,adress,POSTNUMMER from nowHasFnr cross apply FnrToAdress(fnr) x join doesWithoutAdress on doesWithoutAdress.kir = nowHasFnr.kir)
select * from JOINRessults order by kir, Diarienummer


