CREATE PROCEDURE "informix".sp_consparamservi(pEmpresa CHAR(3), pSucursal CHAR(4), pCodigo1 CHAR(20), 
                                              pCodigo2 CHAR(20), pCodigo3 CHAR(20), pCodigo4 CHAR(20))
	RETURNING CHAR(5),CHAR(20),CHAR(20),CHAR(20),CHAR(20);
	
	DEFINE vCodret	CHAR(5);
	DEFINE vsqlerr	INTEGER;
	DEFINE visamerr	INTEGER;
	DEFINE sRetorno1 CHAR(20);
	DEFINE sRetorno2 CHAR(20);
	DEFINE sRetorno3 CHAR(20);
	DEFINE sRetorno4 CHAR(20);

	LET vCodret = "000";
	LET sRetorno1 = "";
	LET sRetorno2 = "";
	LET sRetorno3 = "";
	LET sRetorno4 = "";
	
	SET ISOLATION TO DIRTY READ;
	
	BEGIN
		ON EXCEPTION SET vsqlerr, visamerr
		   IF vsqlerr != 0 THEN
				LET vCodret = vsqlerr;
				RETURN vCodret, sRetorno1, sRetorno2, sRetorno3, sRetorno4;
		   END IF;
		END EXCEPTION;
		
		SELECT valor
		INTO sRetorno1
		FROM bdinteg:"informix".si_sucservicios
		WHERE empresa = pEmpresa
		AND sucursal = pSucursal
		AND cod_servicio = pCodigo1;

		SELECT valor
		INTO sRetorno2
		FROM bdinteg:"informix".si_sucservicios
		WHERE empresa = pEmpresa
		AND sucursal = pSucursal
		AND cod_servicio = pCodigo2;

		SELECT valor
		INTO sRetorno3
		FROM bdinteg:"informix".si_sucservicios
		WHERE empresa = pEmpresa
		AND sucursal = pSucursal
		AND cod_servicio = pCodigo3;

		SELECT valor
		INTO sRetorno4
		FROM bdinteg:"informix".si_sucservicios
		WHERE empresa = pEmpresa
		AND sucursal = pSucursal
		AND cod_servicio = pCodigo4;
		
		IF pCodigo1 <> "" AND sRetorno1 IS NULL THEN
			LET vCodret = "001";
			LET sRetorno1 = " ";
		END IF;

		IF pCodigo2 <> "" AND sRetorno2 IS NULL THEN
			LET vCodret = "002";
			LET sRetorno2 = " ";
		END IF;

		IF pCodigo3 <> "" AND sRetorno3 IS NULL THEN
			LET vCodret = "003";
			LET sRetorno3 = " ";
		END IF;

		IF pCodigo4 <> "" AND sRetorno4 IS NULL THEN
			LET vCodret = "004";
			LET sRetorno4 = " ";
		END IF;
		
		IF pCodigo2 = "" THEN
			LET sRetorno2 = " ";
		END IF;
		
		RETURN vCodret, sRetorno1, sRetorno2, sRetorno3, sRetorno4;
	END;
END PROCEDURE
DOCUMENT
"Consulta para tomar los parametros de servicios",
"Autor : Rodolfo Javier Tortolero Varela",
"FECHA : 20/Febrero/2012",
"Ver.  : 1.1",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_grabarespcliente(cCuenta CHAR(20), cSucursal CHAR(4), cCajero CHAR(8), sRespuesta SMALLINT)

RETURNING
CHAR(5); --Codigo de Retorno

DEFINE cCodRet      CHAR(5);
DEFINE iSqlErr      INTEGER;
--SET LOCK MODE TO WAIT 10;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
set isolation to dirty read;
    ---SET DEBUG FILE TO "/tmp/sp_GrabaRespCliente.out";
	---TRACE ON;

    INSERT INTO bitacora_edocta(num_credito, sucursal, cajero, respuesta) VALUES(cCuenta, cSucursal, cCajero, sRespuesta);

    LET cCodRet = '00000';

    RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
"Graba Respuesta Cliente",
"AUTOR: Saúl Ivanhoe Valdespino",
"FECHA: 08/05/2009",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_actualiza_tiemposymovimientos(pNum_cte	CHAR(20),
															 Ptipo CHAR(1))
RETURNING CHAR(5);

DEFINE sCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE i  INTEGER;
DEFINE sClientePLD BIGINT;
DEFINE sClienteApertura BIGINT;

LET sCodRet = "";
LET iSqlErr = 0;
LET i = 1;
LET sClientePLD = 0;
LET sClienteApertura = 0;

BEGIN
ON EXCEPTION SET iSqlErr
   IF iSqlErr <> 0 THEN
      LET sCodRet = iSqlErr;
      RETURN sCodRet;
   END IF;
END EXCEPTION;

   LET sCodRet = "00000";

	-- SET DEBUG FILE TO "/home/tmp/jairo/sp_actualiza_tiemposymovimientos.out";
	-- TRACE ON;   
	
	SET ISOLATION TO DIRTY READ;
   
	IF pTipo = '1' THEN
		--TIEMPOS PLD
		LET sClientePLD = (SELECT MAX(id_tiempomov) FROM si_bit_tiempoymovimientos WHERE num_cte = pNum_cte);
		UPDATE bdinteg:"informix".si_bit_tiempoymovimientos SET tiempo_pld_fin = CURRENT, vigente = '1' WHERE id_tiempomov = sClientePLD;
	ELIF pTipo = '2' THEN
		--TIEMPOS APERTURA
		LET sClienteApertura = (SELECT MAX(id_tiempomov) FROM si_bit_tiempoymovimientos WHERE num_cte = pNum_cte);
		UPDATE bdinteg:"informix".si_bit_tiempoymovimientos SET tiempo_apertura_fin = CURRENT, vigente = '1' WHERE id_tiempomov = sClienteApertura;
	END IF;

	RETURN sCodRet;
	
END;
END PROCEDURE
DOCUMENT
'Folio: 347',
'Autor: 97823465 - Eliseo Roman',
'Fecha:11/12/2017',
'Descripcion: Se crea sp para actualizar tiempos y movimientos.',
'Sustento: RQM 18 113 Reporte de tiempos y movimientos de los proceso de apertura y asignaciÃ³n de crÃ©dito, captaciÃ³n y servicios. - AnÃ¡lisis TÃ©cnico',
'Solicita: Abraham Narvaez/Christian Rojas.',
'BD: bdinteg:';

CREATE PROCEDURE "informix".sp_depura_si_bitsmstelsms_bpi()
RETURNING CHAR(5),INTEGER;
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
    DEFINE vcodret1         CHAR(5);
    DEFINE error_info		CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
	DEFINE vcontador2       INTEGER;
	DEFINE vRegistros		INTEGER;
	DEFINE vId				INTEGER;
	DEFINE vfecha_oper     	DATE; 
	
---------------------------
--Inicializando variables--
---------------------------
	--SET DEBUG FILE TO "/informix/bdibpi/spl/sp_depura_si_bitsmstelsms_bpi.out"; --Se genera log en un archivo .out
	--TRACE ON;
	
		LET vcodret1        = '00000';
		LET sql_err	        = 0;
		LET isam_err        = 0;
		LET vcontador1      = -1;
		LET vcontador2      = 0;
		LET vRegistros      = 0;
		LET vId 			= 0;

	/*Incia SP*/
BEGIN

		ON EXCEPTION SET sql_err, isam_err
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcontador1 = isam_err;
				RETURN vcodret1, vcontador1;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		SELECT COUNT(*) INTO vRegistros  FROM "informix".si_bitsmstelsms_bpi  WHERE fecha NOT IN (SELECT fecha FROM si_bitsmstelsms_bpi  WHERE DATE(fecha) BETWEEN TODAY-7 AND TODAY);
	
				
		IF vRegistros > 0 THEN
			
			FOREACH WITH HOLD

			SELECT fecha INTO vfecha_oper FROM "informix".si_bitsmstelsms_bpi  
			WHERE fecha NOT IN (SELECT fecha FROM si_bitsmstelsms_bpi  WHERE DATE(fecha) BETWEEN TODAY-7 AND TODAY)
			
			IF vcontador1 = -1 THEN
				LET vcontador1 = 0;
				BEGIN WORK;
			END IF;
		
			DELETE FROM "informix".si_bitsmstelsms_bpi  WHERE fecha NOT IN (SELECT fecha FROM si_bitsmstelsms_bpi  WHERE DATE(fecha) BETWEEN TODAY-7 AND TODAY);
		
			LET vcontador1 = vcontador1 + 1;
			LET vcontador2 = vcontador2 + 1;
		
			 IF vcontador2 >= 1000 THEN
				LET vcontador2 = 0;
				COMMIT WORK;
				BEGIN WORK;
			 END IF;
		
			COMMIT WORK;
			BEGIN WORK;
			
			END FOREACH;
			IF vcontador1 > -1 THEN		
				COMMIT WORK;
			END IF;
		ELSE 
			LET vcodret1 = '00000';
		END IF;

		RETURN vcodret1, vcontador1;	
	END;
END PROCEDURE;