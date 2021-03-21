IF OBJECT_ID (N'dbo.HandelseTableType', N'FN') IS NOT NULL DROP TYPE HandelseTableType; Go
CREATE TYPE HandelseTableType
   AS TABLE
      (
    Diarienummer              varchar(20)  not null,
    huvudfastighet            varchar(50),
    Ärendemening              varchar(100),
    Text                      varchar(max),
    Rubrik                    varchar(100) not null,
    Riktning                  varchar(20),
    Datum                     dateTime  not null,
    ArendeKommentar           varchar(200),
    id                        int identity not null
     )
go
