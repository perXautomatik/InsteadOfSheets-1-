IF OBJECT_ID('tempdb..##TempWithIdentity') IS NOT NULL DROP TABLE ##TempWithIdentity create table dbo.##TempWithIdentity
    (
        i          int not null identity (1,1) primary key,
        POSTORT    varchar(255),
        POSTNUMMER varchar(255),
        ADRESS     varchar(255),
        NAMN       varchar(255),
        andel      varchar(255),
        BETECKNING varchar(255),
        arndenr    varchar(255)
    )

--select ROW_NUMBER() OVER(ORDER BY newid()) AS nrx, i, ANDEL, POSTORT, POSTNUMMER, adress, NAMN, BETECKNING, arndenr from dbo.Generator_InputPlusGeofir

SET IDENTITY_INSERT ##TempWithIdentity ON;