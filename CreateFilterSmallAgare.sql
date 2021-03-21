WITH filterBadAdress as (SELECT q.fra, q.POSTORT, q.POSTNUMMER, q.ADRESS, q.NAMN, q.BETECKNING, q.arndenr, q.PERSORGNR,* from #input q)
 select fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR, RowNum
 into #filterSmallOwnersBadAdress
 from (select fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR, RowNum
       from (select q.fra, q.POSTORT, q.POSTNUMMER, q.ADRESS, q.NAMN, q.BETECKNING, q.arndenr, q.PERSORGNR,
		    ROW_NUMBER() OVER ( PARTITION BY q.arndenr ORDER BY q.fra desc) RowNum
	     from filterBadAdress as q
		      INNER JOIN filterBadAdress thethree
				 ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X
       WHERE X.RowNum = 1 AND postOrt <> '' AND POSTNUMMER <> '' AND Adress <> '' AND Namn is not null) as asdasd
 union
 select fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR, RowNum
 from (select fra, POSTORT, POSTNUMMER, ADRESS, NAMN, BETECKNING, arndenr, PERSORGNR, RowNum
       from (select q.fra, q.POSTORT, q.POSTNUMMER, q.ADRESS, q.NAMN, q.BETECKNING, q.arndenr, q.PERSORGNR,
		    ROW_NUMBER() OVER ( PARTITION BY q.arndenr ORDER BY q.fra desc ) RowNum
	     from filterBadAdress as q
		      INNER JOIN filterBadAdress thethree
				 ON q.arndenr = thethree.arndenr and q.namn = thethree.namn) X
       WHERE X.RowNum > 1
	 and X.RowNum < 4
	 AND fra > 0.3
	 AND postOrt <> '' AND POSTNUMMER <> '' AND Adress <> '' AND Namn is not null) as asdasdx
