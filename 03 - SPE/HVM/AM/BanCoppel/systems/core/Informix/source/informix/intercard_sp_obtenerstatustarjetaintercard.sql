CREATE PROCEDURE "informix".sp_obtenerstatustarjetaintercard(pRegistros int)
	RETURNING CHAR(5) as codret,CHAR(3) as codestatustarjeta,CHAR(2) as  codigoiso,CHAR(30) as descestatustarjeta

	------------------------------------------------------------------------------------------------------------------------------------
	--Elaboró: Francisco Rodríguez Ibarra
    --Actividad: Obtiene los registro de la intercard:statustarjeta
    --Solicito: Mauricio León
    --Fecha: 13-10-2010
	------------------------------------------------------------------------------------------------------------------------------------			
				
	-- DECLARA
	DEFINE vCod_Ret char(5);
    DEFINE sql_err integer ;
	DEFINE vCodEstatusTarjeta char(9);
	DEFINE vCodigoIso char(4);
	DEFINE vDescEstatusTarjeta char(25);
	DEFINE vICont INTEGER;
	-- INICIALIZA
	LET vCod_Ret = '00000';
	LET vCodEstatusTarjeta='';
	LET vCodigoIso = '';
	LET vDescEstatusTarjeta = '';
	LET vICont=0;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,vCodEstatusTarjeta,vCodigoIso,vDescEstatusTarjeta;
		  END IF ;
		END EXCEPTION ;
		
    SET ISOLATION TO DIRTY READ;
    set lock mode to wait 3;

		FOREACH
							
			SELECT SKIP pRegistros FIRST 10 codstatustarjeta,codigoiso,UPPER(descstatustarjeta)
			INTO vCodEstatusTarjeta,vCodigoIso,vDescEstatusTarjeta
			FROM intercard:statustarjeta
			
			RETURN vCod_Ret,vCodEstatusTarjeta,vCodigoIso,vDescEstatusTarjeta WITH RESUME;
	
		END FOREACH;
		
	END;

END PROCEDURE;