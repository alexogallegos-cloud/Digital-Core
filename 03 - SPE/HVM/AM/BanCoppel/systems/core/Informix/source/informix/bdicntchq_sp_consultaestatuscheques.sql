CREATE PROCEDURE "informix".sp_consultaestatuscheques(pClave CHAR(1), pEstatus CHAR(1))
RETURNING CHAR(6) AS cod_ret,
          CHAR(1) AS clave,
          CHAR(1) AS estatus,
	  VARCHAR(50) AS descripcion;
		  
		   
	--DECLARACIONES
	DEFINE cCodRet            CHAR(6);
	DEFINE iSqlErr            INTEGER;
	DEFINE cClave             CHAR(1);
	DEFINE cEstatus           CHAR(1);
	DEFINE vDescripcion       VARCHAR(50);
	
	--INICIALIZACIONES
	LET cCodRet            = '000000';
	LET iSqlErr            = 0;
	LET cClave             = '';
	LET cEstatus           = '';
	LET vDescripcion       = '';
	
	
	
	--SET DEBUG FILE TO '/dbexportb/carlos/reportecheques/constatuscheq.out';
	--TRACE ON;	
	--SET EXPLAIN FILE TO '/dbexportb/carlos/reportecheques/constatuscheq.out';
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN  TRIM(cCodRet), NVL(cClave,''), NVL(cEstatus,''), TRIM(NVL(vDescripcion,''));
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--************************************************************************************
		--*****************************CONTROL DE ERRORES POR PARAMETROS**********************
		--************************************************************************************
		IF NVL(pClave,'') = '' THEN
			LET cCodRet = '590';
			RETURN  TRIM(cCodRet), NVL(cClave,''), NVL(cEstatus,''), TRIM(NVL(vDescripcion,''));
		END IF;
		
		--************************************************************************************
		--*****************************       BLOQUE DE CONSULTAS       **********************
		--************************************************************************************
		
		IF pEstatus IS NULL THEN
			LET pEstatus = '';
		END IF;
	
		FOREACH
			SELECT clave, status, descripcion
			INTO cClave, cEstatus, vDescripcion
			FROM "informix".sq_status_chequera
			WHERE clave = pClave
			AND status = DECODE(pEstatus,'',status,pEstatus)
			
			
			RETURN  TRIM(cCodRet), cClave, cEstatus, TRIM(vDescripcion) WITH RESUME;
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '595'; --NO EXISTEN REGISTROS CON EL CRITERIO DE CONSULTA
			RETURN  TRIM(cCodRet), NVL(cClave,''), NVL(cEstatus,''), TRIM(NVL(vDescripcion,''));
		END IF;
	
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: PROCEDIMIENTO QUE HACE UNA BUSQUEDA EN LA TABLA SQ_STATUS_CHEQUERA RECIBIENDO COMO PARAMETRO CLAVE o CLAVE Y ESTATUS, DEVOLVIENDO CLAVE, STATUS Y DESCRIPCION.',
'AUTOR: CARLOS OCHOA',   
'FECHA DE CREACION: 23 de SEPTIEMBRE DE 2013',
'VERSION: 20130923',
'BD: bdicntchq';

CREATE PROCEDURE "informix".sp_validar_num_cheques(pEmpresa char(3), pCuenta char(20), pNumParam integer)
        RETURNING char(5);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Validar el numero de cheques activos permitidos
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 19/03/2010

   DEFINE vCodret   char(5);
   DEFINE vValorMaxChqs  char(60);
   DEFINE vNumChqesActivos integer;
   DEFINE sql_err integer;
   DEFINE iChqSolic char(60);
   DEFINE iCheques_activos char(10);
   DEFINE alt_consumo char(5);  

	ON EXCEPTION SET sql_err
	   IF sql_err <> 0 THEN
		LET vCodret = sql_err;
		RETURN vCodret;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO  "/informix/Aida/spvalidar_num_cheques.out";
	--TRACE ON;
	
		LET vCodret = '000';
	LET vValorMaxChqs = '';
	LET vNumChqesActivos = 0;
	LET alt_consumo = 1;
	
	BEGIN
		IF EXISTS(SELECT valor FROM sq_param WHERE cod_param = pNumParam) THEN

			SELECT valor 
			INTO vValorMaxChqs
			FROM sq_param 
			WHERE cod_param = pNumParam;

		ELSE
			LET vCodret = '001';
			RETURN vCodret;
		END IF;
		
		SELECT count(numero)
		INTO vNumChqesActivos
		FROM bdicheq:sc_contch
		WHERE cuenta = pCuenta
		AND empresa = pEmpresa
		AND estado = "A";
		
		SELECT chequeras_sol,cheques_activos
		INTO iChqSolic, iCheques_activos
		FROM bdicntchq:"informix".sq_ctealtconsumo
		WHERE cuenta = pcuenta	
		AND alt_consumo = '1';
	   
		IF NVL(iCheques_activos,0) <> 0 THEN  --si no entra significa que no es de alto consumo
			IF (vNumChqesActivos > iCheques_activos::integer) THEN
				LET vCodret = '002';
				RETURN vCodret;
			END IF;
		END IF;		
		
		IF (vNumChqesActivos > vValorMaxChqs::integer) THEN
			LET vCodret = '002';
			RETURN vCodret;
		END IF;

		RETURN vCodret;
	END;

END PROCEDURE;