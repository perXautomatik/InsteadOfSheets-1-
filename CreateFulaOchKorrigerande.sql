
--SELECT * TOP 3 ANDEL unless noone owns more than 25 then add all
--drop table #fulaAttKorrigera
--drop table #Corrigerande
--DROP INDEX KorrigeringsIndex on #Corrigerande
;if object_id('tempdb..#fulaAttKorrigera') is null begin CREATE TABLE #fulaAttKorrigera ( Ägare nvarchar(200), Postadress nvarchar(200), POSTNR nvarchar(200), POSTORT nvarchar(200), [personnr/Organisationnr] nvarchar(200), SOURCE varchar(200), Id INTEGER NOT NULL DEFAULT 0 );;if object_id('tempdb..KorrigeringsIndex') is null begin CREATE INDEX KorrigeringsIndex on #fulaAttKorrigera(Ägare,POSTADRESS,POSTORT,POSTNR,[personnr/Organisationnr],SOURCE,id)end
INSERT INTO #fulaAttKorrigera(Ägare, Postadress, POSTNR, POSTORT,id) VALUES ('Staten FORTIFIKATIONSVERKET', ' ', '63189', 'ESKILSTUNA', 1), ('Staten SVERIGES LANTBRUKSUNIVERSITET', 'Box 7070 ', 'SLU,', '75007 UPPSALA', 2), ('Lasmi AB', 'c/o SANCHES SUAREZ ', N'Gustavsviksvägen', '36, 62141 VISBY', 3), (N'Koloniföreningen Kamraterna u.p.a.', 'c/o P JANSSON ', N'LINGVÄGEN', '219 LGH 1002, 12361 FARSTA', 4), ('Martin Plahn', N'RUDKÄLLAVÄGEN 2 ', 'BROLUNDA,', '15534 NYKVARN', 5), ('Kristine Torkelsdotter', 'c/o WESTER ', 'HELLVI', N'MALMS 955, 62450 LÄRBRO', 6), ('FRANZISKA SCHNEIDER-STOTZER', N'c/o GRABEN 43294 BÜREN A/A', '', 'SCHWEIZ', 7), ('TOMAS SCHNEIDER', N'c/o GRABEN 4,3294 BRÜEN A/A', '', 'SCHWEIZ', 8), (N'Föreningen Follingbo Folkets Hus u p a', 'c/o LARS ANDERSSON ', 'STORA', N'TÖRNEKVIOR 5, 62137 VISBY', 9), (N'W. Wetterström Smide Mek & Rörledningsfirma Handelsbolag', 'BOX 369 ', N'VITVÄRSVÄGEN', '3, 62325 LJUGARN', 10), ('Romaklosters pastorat', 'c/o ROMA PASTORSEXPEDITION ', N'VISBYVÄGEN', '33 B, 62254 ROMAKLOSTER', 11), (N'Gun Astrid Sörlin', 'c/o WALLIN ', N'STRANDVÄGEN', N'29, 62462 FÅRÖSUND', 12), ('Sirredarre AB', 'c/o LINDA JENSEN ', N'INGENJÖRSVÄGEN', '18 LGH 1202, 11759 STOCKHOLM', 14), (N'Niklas Per Emil Möller', '322 RODNEY STREET APT 17 BROOKLYN .N.Y., USA', '11211', 'BROOKLYN  .N.Y., USA', 15), (N'VÄSTERHEJDE FOLKETS HUS FÖRENING UPA', 'c/o SOCIALDEMOKRATERNA GOTLAND ', N'STENHUGGARVÄGEN', '6, 62153 VISBY', 16), (N'Aktiebolaget Lunds Allé Visby', N'c/o SÖDERSTRAND ', N'BERGGRÄND', '5, 62157 VISBY', 17), (N'VISBY ALLMÄNNA IDROTTSKLUBB', 'c/o VISBY AIK ', 'BOX', '1049, 62121 VISBY', 18), (N'Ludvig Söderberg', 'c/o RA EKONOMI AB ', 'HORNSGATAN', '103, 11728 STOCKHOLM', 19), ('Mats Wiktorsson', 'c/o JOVANOVIC ', 'SANKT', 'PAULSGATAN 14 LGH 1205, 11846 STOCKHOLM', 20), ('', 'c/o Ann-Sofie Ekedahl, Vadkastliden 5 ', '45196', 'UDDEVALLA',21), (N'GOTLANDS MOTORFÖRENINGS SPEEDWAYKLUBB', '1035 ', '62121', 'VISBY',22), (N'PRÄSTLÖNETILLGÅNGAR I VISBY STIFT', 'BOX 1334 ', '62124', 'VISBY',23)
,(N'VALLS GRUSTAG EK FÖR', 'ROSARVE VALL/M ENEKVIST/ ', '62193', 'VISBY',25),
('Introbolaget 4271 AB', 'c/o EKONOMERNA NB & IC HB ', N'TUVÄNGSVÄGEN', N'4, 15242 SÖDERTÄLJE',26);
INSERT INTO #fulaAttKorrigera(ÄGARE, POSTADRESS, POSTNR, POSTORT, [personnr/Organisationnr], SOURCE,id) VALUES (N'Lena Nordström', 'RUA EDUARDO HENRIQUES PEREIRA NO 1 ', 'BLOCO', '1, 2 B, 2655-267 ERICEIRA, PORTUGAL', '196204112764', 'geosecma',13), (N'Lena Katarina Nordström', '', '', 'PORTUGAL', '196204112764', 'lagfart',13)
,('Ingela Karin Spillmann', '', '', 'SCHWEIZ', '194003191246', 'lagfart',24);
END
;if object_id('tempdb..#Corrigerande') is null begin CREATE TABLE #Corrigerande (Ägare nvarchar(200), Postadress nvarchar(200), POSTNR nvarchar(200), POSTORT nvarchar(200), [personnr/Organisationnr] nvarchar(200), SOURCE varchar(200),Id INTEGER primary key NOT NULL DEFAULT 0);
 INSERT INTO #Corrigerande(Ägare, Postadress, POSTNR, POSTORT,id) VALUES
(N'Aktiebolaget Lunds Allé Visby', N'c/o SÖDERSTRAND, BERGGRÄND 5','62157','VISBY',17),
(N'FRANZISKA SCHNEIDER-STOTZER', N'Atelier Stadtgraben, Graben 4', 'CH-3294', N'Büren an der Aare, SCHWEIZ',7),
(N'Föreningen Follingbo Folkets Hus u p a ', N'c/o LARS ANDERSSON, STORA TÖRNEKVIOR 5','62137', 'VISBY',9),
(N'GOTLANDS MOTORFÖRENINGS', 'SPEEDWAYKLUBB 1035 ', '62121', 'VISBY',22),
(N'Gun Astrid Sörlin', N'c/o WALLIN, STRANDVÄGEN 29', '62462',N'FÅRÖSUND',12),
(N'Koloniföreningen Kamraterna u.p.a.', N'c/o P, JANSSONLINGVÄGEN 219 LGH 1002', '12361', 'FARSTA',4),
(N'Kristine Torkelsdotter','c/o WESTER, HELLVI MALMS 955', '62450', N'LÄRBRO',6),
(N'Lasmi AB c/o SANCHES SUAREZ', N'Gustavsviksvägen 36','62141', 'VISBY',3),
(N'Ludvig Söderberg', 'c/o RA EKONOMI AB, HORNSGATAN 103','11728','STOCKHOLM',19),
(N'Martin Plahn', N'RUDKÄLLAVÄGEN 2 BROLUNDA', '15534', 'NYKVARN',5),
(N'Mats Wiktorsson c/o JOVANOVIC', 'SANKT PAULSGATAN 14 LGH 1205','11846','STOCKHOLM',20),
(N'Niklas Per Emil Möller', '322 RODNEY STREET APT 17', '11211', 'BROOKLYN .N.Y., USA',15),
(N'PRÄSTLÖNETILLGÅNGAR I', 'VISBY STIFT BOX 1334 ', '62124', 'VISBY',23),
(N'Romaklosters pastorat', N'c/o ROMA PASTORSEXPEDITION, VISBYVÄGEN 33 B', '62254', 'ROMAKLOSTER',11),
(N'SVERIGES LANTBRUKSUNIVERSITET', 'SLU, Box 7070', '75007', 'UPPSALA',2),
(N'Sirredarre AB c/o LINDA JENSEN', N'INGENJÖRSVÄGEN 18 LGH 1202','11759','STOCKHOLM',14),
(N'Staten', 'FORTIFIKATIONSVERKET', '63189', 'ESKILSTUNA',1),
(N'TOMAS SCHNEIDER', N'Atelier Stadtgraben, Graben 4', 'CH-3294', N'Büren an der Aare, SCHWEIZ',8),
(N'VISBY ALLMÄNNA IDROTTSKLUBB', 'c/o VISBY AIK, BOX 1049','62121','VISBY',18),
(N'VÄSTERHEJDE FOLKETS HUS FÖRENING UPA', N'c/o SOCIALDEMOKRATERNA GOTLAND, STENHUGGARVÄGEN 6', '62153','VISBY',16),
(N'W. Wetterström Smide Mek & Rörledningsfirma Handelsbolag', N'BOX 369 VITVÄRSVÄGEN 3','62325', N'LJUGARN',10),
(N'c/o Ann-Sofie Ekedahl', 'Vadkastliden 5', '45196', 'UDDEVALLA',21),
(N'VALLS GRUSTAG EK FÖR', 'c/o M ENEKVIST, Vall rosarve', '62193', 'VISBY',25),
('Introbolaget 4271 AB c/o EKONOMERNA NB & IC HB', N'TUVÄNGSVÄGEN 4', N'15242', N'SÖDERTÄLJE',26);

INSERT INTO #Corrigerande(ÄGARE, POSTADRESS, POSTNR, POSTORT, [personnr/Organisationnr], SOURCE,id) VALUES
       (N'Lena Nordström', 'RUA EDUARDO HENRIQUES PEREIRA NO 1 BLOCO 1, 2 B', '2655-267','ERICEIRA, PORTUGAL', '196204112764', 'geosecma',13)
       ,('Spillmann Thulin, Ingela', 'Seestrasse 222', '8700', N'Küsnacht ZH SCHWEIZ', '194003191246', 'googlade tel.search.ch',24);
END
;
--o	Vilande – Gem. Anläggning
--o	Vilande – kommunal anslutning
--o	Väntande – uppskov
--o	Väntande – överklangande

--Excelfilen ska ha kolumnerna
          -- dia        Fastighet          Ägare                 Postadress       Postnr                Postort              Personnr          Organisationsnr statuskommentar