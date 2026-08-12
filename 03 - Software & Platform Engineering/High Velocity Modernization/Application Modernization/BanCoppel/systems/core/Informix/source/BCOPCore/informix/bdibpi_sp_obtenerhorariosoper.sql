CREATE PROCEDURE "informix".sp_obtenerhorariosoper(pRegistros SMALLINT)
RETURNING CHAR(5),CHAR(4),CHAR(8),CHAR(8),CHAR(150),CHAR(10)

	------------------------------------------------------------------------------------------------------------------------
	--Elaboró:Francisco Rodríguez Ibarra.
	--Actividad:Se utiliza para obtener los horarios de  operación, debido a la migración de BD de postgres a informix
	--Solicito:Diana Castellanos
	--Fecha:21/10/2010
	------------------------------------------------------------------------------------------------------------------------
	
	--DECLARACION DE VARIABLES
	DEFINE vCod_Ret CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vIdOper CHAR(4);
	DEFINE vH_Ini_Baja CHAR(8);
	DEFINE vH_Fin_Baja	CHAR(8);
	DEFINE vMsn_TimeOut CHAR(150);
	DEFINE vFec_Baja CHAR(10);
	DEFINE vIcont INTEGER;
	
	--INICIALIZAR VALORES A VARIABLES;
	LET vCod_Ret='00000';
	LET vIdOper='';
	LET vH_Ini_Baja='01-01-1900';
	LET vH_Fin_Baja='01-01-1900';
	LET vMsn_TimeOut='';
	LET vFec_Baja='';
	
	LET vIcont=0;
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,vIdOper,vH_Ini_Baja,vH_Fin_Baja,vMsn_TimeOut,vFec_Baja;
		  END IF ;
		END EXCEPTION ;


		FOREACH
		
			SELECT SKIP pRegistros FIRST 10 id_oper, h_ini_baja::CHAR(8), h_fin_baja::CHAR(8),msn_timeout,fecha_baja 
			INTO vIdOper,vH_Ini_Baja,vH_Fin_Baja,vMsn_TimeOut,vFec_Baja
			 FROM bdibpi:bpi_cat_operaciones
			     WHERE id_oper <> '1000' 
			    AND id_oper <> '1001' 
			    AND id_oper <> '1002' 
			    AND id_oper <> '1003'
			 ORDER BY id_oper
			 
			 IF (vIdOper<>'' OR vIdOper IS NOT NULL) THEN
				LET vIcont=1;
				RETURN vCod_Ret,vIdOper,vH_Ini_Baja,vH_Fin_Baja,vMsn_TimeOut,vFec_Baja WITH RESUME;
			 END IF;
		 
		 END FOREACH;
		 
		 IF (vIcont=0) THEN
			LET vCod_Ret='00001';			RETURN vCod_Ret,vIdOper,vH_Ini_Baja,vH_Fin_Baja,vMsn_TimeOut,vFec_Baja;
		 END IF;
		
	END;
END PROCEDURE;