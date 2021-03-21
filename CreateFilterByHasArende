IF OBJECT_ID (N'dbo.HandelseTableType', N'FN') IS NOT NULL DROP TYPE HandelseTableType; Go
CREATE Function dbo.usp_FilterByHasArende(@TVP HandelseTableType READONLY)
RETURNS table AS
      return
            select tv.* from @tvp tv left outer join (select Diarienummer from @TVP where Rubrik like N'%ansökan%'
            AND Riktning = 'inkommande' group by Diarienummer) has on has.Diarienummer = tv.Diarienummer where has.Diarienummer is null
GO

