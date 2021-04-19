--hämta ärendenr från vision--drop TABLE #ALIAS--drop table #PATO

--;if object_id('tempExcel.dbo.AdressCorrection') is null begin CREATE SYNONYM AdressCorrection FOR tempExcel.dbo.[20201112Flaggor ägaruppgifter-nyutskick]  	end
--;if object_id('tempExcel.dbo.FastighetsLista') 	is null begin CREATE SYNONYM FastighetsLista for  tempExcel.dbo.[20201108ChristofferRäknarExcel]           	end
--;if object_id('tempExcel.dbo.[admsql04].[EDPVisionRegionGotland].DBO.VWAEHAERENDE') 	is null begin CREATE SYNONYM [admsql04].[EDPVisionRegionGotland].DBO.VWAEHAERENDE for 	  [admsql04].[EDPVisionRegionGotland].DBO.VWAEHAERENDE          end
;if object_id('tempExcel.dbo.KirFnr') 		is null begin CREATE SYNONYM KirFnr for 	  [GISDATA].[sde_geofir_gotland].[gng].FA_FASTIGHET             end
;if object_id('tempExcel.dbo.FasAdresser') 	is null begin CREATE SYNONYM FasAdresser for 	  [GISDATA].[sde_geofir_gotland].[gng].FASTIGHETSADRESS_IG      end
--;if object_id('tempExcel.dbo.[admsql04].[EDPVisionRegionGotland].DBO.vwAehHaendelse') 	is null begin CREATE SYNONYM [admsql04].[EDPVisionRegionGotland].DBO.vwAehHaendelse for  [admsql04].[EDPVisionRegionGotland].DBO.vwAehHaendelse 	END;
