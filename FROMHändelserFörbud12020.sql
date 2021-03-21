:r TillMinaMedelanden/CreateFilterByHasArende

--Select * from HändelserFörbud12020,HändelseKontakter,ÄrendeKontakter

--select * from HändelserFörbud12020 cross Apply FiltreraBortArendenMedAnsokan(

DECLARE @handelser AS HandelseTableType;
INSERT INTO @handelser (Diarienummer, huvudfastighet, Ärendemening, Text, Rubrik, Riktning, Datum, ArendeKommentar)
   SELECT Diarienummer,
          [Ärendets huvudfastighet],
          Ärendemening,
          Text,
          Rubrik,
          Riktning,
          cast(Händelsedatum as datetime),
          Kommentar
FROM HändelserFörbud12020;


select * from dbo.usp_FilterByHasArende(@handelser)