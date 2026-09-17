CREATE PROCEDURE "informix".sp_graba_bitacora_proceso(pIdOpere char(4),pFechaInser datetime year to second,pMensaje varchar(100))
	RETURNING CHAR(5)
	
	--Realizo: Francisco Rodríguez Ibarrra
	--Solicito: Mauricio Leon
	--Actividad: graba en bitacora 
	-- Fecha: 24-08-2011
	
	--DEFINICION DE VARIABLES
	DEFINE vCodRet 		CHAR(5);
	DEFINE sql_err 		INTEGER;
	
	--Asignacion de valores a variables
	LET vCodRet='00000';
	
	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				let vCodRet = sql_err;
				RETURN vCodRet;
			END IF ;
		END EXCEPTION ;
		
		INSERT INTO bdibpi:"informix".bpidocsbitacora (id_operacion,fecha,descripcion) VALUES (pIdOpere,pFechaInser,pMensaje);
		RETURN vCodRet;
	END
END PROCEDURE
		;