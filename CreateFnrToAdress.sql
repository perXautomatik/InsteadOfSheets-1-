DROP FUNCTION FnrToAdress;
GO
CREATE FUNCTION DBO.FnrToAdress(@INPUTFNR INTEGER)
    RETURNS TABLE AS RETURN SELECT FNR
				 , CAST(
		CASE WHEN [ANDEL] IS NULL OR [ANDEL] = '' THEN '1/1' ELSE [ANDEL] END AS VARCHAR) AS ANDEL
				 , CAST(
		CASE WHEN [NAMN] IS NULL OR [NAMN] = '' THEN KORTNAMN ELSE [NAMN] END AS VARCHAR) AS NAMN
				 , CAST(
		CASE WHEN ([FAL_UTADR2] IS NULL OR [FAL_UTADR2] = '') AND ([FAL_POSTNR] IS NULL OR [FAL_POSTNR] = '')
			 THEN CASE WHEN (SAL_UTADR1 IS NULL OR SAL_UTADR1 = '') AND
					(SAL_POSTNR IS NULL OR SAL_POSTNR = '') THEN UA_UTADR1
										ELSE SAL_UTADR1
			      END
			 ELSE FAL_UTADR2
		END AS VARCHAR)                                                                   AS ADRESS
				 , CAST(
		CASE WHEN ([FAL_UTADR2] IS NULL OR [FAL_UTADR2] = '') AND ([FAL_POSTNR] IS NULL OR [FAL_POSTNR] = '')
			 THEN CASE WHEN (SAL_UTADR1 IS NULL OR SAL_UTADR1 = '') AND
					(SAL_POSTNR IS NULL OR SAL_POSTNR = '') THEN UA_UTADR2
										ELSE SAL_POSTNR
			      END
			 ELSE [FAL_POSTNR]
		END AS VARCHAR)                                                                   AS POSTNUMMER
				 , CAST(
		CASE WHEN ([FAL_POSTORT] IS NULL OR [FAL_POSTORT] = '') AND ([FAL_POSTNR] IS NULL OR [FAL_POSTNR] = '')
			 THEN CASE WHEN (SAL_UTADR1 IS NULL OR SAL_UTADR1 = '') AND
					(SAL_POSTNR IS NULL OR SAL_POSTNR = '') THEN UA_LAND
										ELSE SAL_POSTORT
			      END
			 ELSE [FAL_POSTORT]
		END AS VARCHAR)                                                                   AS POSTORT
				 , [PERSORGNR]
			    FROM (SELECT FNR
				       , [UA_UTADR2]
				       , [UA_UTADR1]
				       , [UA_LAND]
				       , [SAL_POSTORT]
				       , [SAL_POSTNR]
				       , [NAMN]
				       , [KORTNAMN]
				       , [FAL_UTADR2]
				       , [FAL_POSTORT]
				       , [FAL_POSTNR]
				       , [ANDEL]
				       , [SAL_UTADR1]
				       , [PERSORGNR]
				  FROM (SELECT FNR
					     , [UA_UTADR2]
					     , [UA_UTADR1]
					     , [UA_LAND]
					     , [SAL_POSTORT]
					     , [SAL_POSTNR]
					     , [NAMN]
					     , [KORTNAMN]
					     , [FAL_UTADR2]
					     , [FAL_POSTORT]
					     , [FAL_POSTNR]
					     , min(ANDEL) 'andel'
					     , [SAL_UTADR1]
					     , [PERSORGNR]
					FROM [GISDATA].SDE_GEOFIR_GOTLAND.GNG.FA_TAXERINGAGARE_V2
					GROUP BY FNR, [UA_UTADR2], [UA_UTADR1], [UA_LAND], [SAL_POSTORT], [SAL_POSTNR]
					       , [NAMN], [KORTNAMN], [FAL_UTADR2], [FAL_POSTORT], [FAL_POSTNR]
					       , [SAL_UTADR1], [PERSORGNR]) AS TAX
				  WHERE @INPUTFNR = TAX.FNR) T;
GO