:r TillMinaMedelanden/CreateInput.sql
:r TillMinaMedelanden/CreateFilterSmallAgare.sql

with
    inputX as (select fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR, RowNum from ##filterSmallOwnersBadAdress)
   ,ShooHornTable as (select * from tempExcel.dbo.Bootstrap_AdressComplettering)
,noNeedToComplete as (select *from inputX where postOrt <> '' AND POSTNUMMER <> '' AND Adress <> '' AND Namn is not null)
,toComplete as (select * from inputX where postOrt = '' OR POSTNUMMER = '' OR Adress = '' OR Namn is null)
,adressCompl as (select fra, ShooHornTable.POSTORT, ShooHornTable.POSTNUMMER, ShooHornTable.ADRESS, ShooHornTable.NAMN, BETECKNING, toComplete.arndenr, PERSORGNR, RowNum
	from toComplete left outer join
	    ShooHornTable on ShooHornTable.arndenr = toComplete.arndenr)

select * from adressCompl union select * from noNeedTOComplete order by arndenr, RowNum



