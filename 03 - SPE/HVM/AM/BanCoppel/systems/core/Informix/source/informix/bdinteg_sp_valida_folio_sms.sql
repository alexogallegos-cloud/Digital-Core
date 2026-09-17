CREATE PROCEDURE "informix".sp_valida_folio_sms(pEmpresa CHAR(3), pSucursal CHAR(4), pProducto CHAR(8),pNumCte CHAR(20), pEjecutivo CHAR(8))
RETURNING CHAR(6)        AS codigo_retorno,
		  INTEGER        AS req_validacion,
          INTEGER        AS flag_validacion;

DEFINE cCodRet		CHAR(6);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);
DEFINE iReqVal      INTEGER; 
DEFINE iFlag        INTEGER;   
DEFINE cTelefono    CHAR(13);
DEFINE cVerificado    CHAR(1);

LET cCodRet			= "000000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET iReqVal         = 0;
LET iFlag           = 0;
LET cTelefono       = '';
LET cVerificado       = '';

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN NVL(cCodRet,''),NVL(iReqVal,0),NVL(iFlag,0);
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/paulq/sp_valida_folio_sms.out";
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF TRIM(NVL(pEmpresa,"")) = "" OR TRIM(NVL(pSucursal,"")) = "" OR TRIM(NVL(pProducto,"")) = ""  OR  TRIM(NVL(pNumCte,"")) = "" OR TRIM(NVL(pEjecutivo,"")) = "" THEN
	LET cCodRet  = "000001";
	RETURN NVL(cCodRet,''),NVL(iReqVal,0),NVL(iFlag,0);
END IF;

SELECT LIMIT 1 1 
  INTO iReqVal
  FROM "informix".si_prod_sucursal_sms
 WHERE empresa = pEmpresa
   AND num_producto = pProducto
   AND sucursal = pSucursal;
 
IF NVL(iReqVal,0) = 1 THEN	
	-- RQI 27 008 20/01/2016 Se agrega validación para relacionar la tabla si_telefonos donde el telefono haya sido verificado JMA
	  	SELECT LIMIT 1 a.telefono
		  INTO cTelefono
		  FROM "informix".si_telefonos_actual a
		  INNER JOIN  "informix".si_telefonos b on (b.numcte     = a.numcte 
												   AND b.tipo_tel   = a.tipo_tel
												   AND b.status_tel = a.status_tel
												   AND b.telefono = a.telefono 
												   AND b.verificado = 'V')
		 WHERE a.numcte     = pNumCte
		   AND a.tipo_tel   = 1
		   AND a.status_tel = 'A';
		   
		   IF NVL(cTelefono,'') = '' THEN
				LET iFlag = 0;
		   ELSE		
				LET iFlag = 1;	   
		   END IF;
	
		IF iFlag = 0 THEN
			SELECT LIMIT 1 a.telefono, b.verificado 
			  INTO cTelefono,cVerificado 
			  FROM "informix".si_telefonos_actual a
			  LEFT JOIN  "informix".si_telefonos b on (b.numcte     = a.numcte 
												   AND b.tipo_tel   = a.tipo_tel
												   AND b.status_tel = a.status_tel
												   AND b.telefono = a.telefono 
												   )
			 WHERE a.numcte     = pNumCte
			   AND a.tipo_tel   = 2
			   AND a.status_tel = 'A';
			   
			   IF NVL(cTelefono,'') = '' or  cVerificado = 'V' THEN
					LET iFlag = 1;
			   END IF;
		END IF;	   
		IF iFlag = 0 THEN
				FOREACH 
					SELECT LIMIT 1 1
					   INTO iFlag
					   FROM "informix".si_bitsmstels b
					  WHERE b.numcte     = pNumCte
					   AND b.telefono   = cTelefono
					   AND b.bandera    = 't'
				  ORDER BY b.fecha DESC
				END FOREACH
        END IF;
END IF;

RETURN NVL(cCodRet,''),NVL(iReqVal,0),NVL(iFlag,0);

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para revisar si el folio sms ya fué validado',
'FECHA: 12/NOV/2015',
'BD: bdinteg',
'AUTOR: PAUL IVAN QUINTERO VARELA';

CREATE PROCEDURE "informix".sp_reconsultastatushuellalineaatrasadas()

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) 	AS CodigoRetorno,
	CHAR(43) 	AS TramaSalida,
	CHAR(1)		AS EstatusConsulta;

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 		INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE cCadena			CHAR(43);	
	DEFINE cEstatusConsulta	CHAR(1);
	DEFINE cNumCte			CHAR(20);
	DEFINE dFechaConsulta	DATE;
	
	DEFINE iCantidad		INTEGER;
	DEFINE sCont			SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET iSql_err			= 0;
	LET cCodRet				= '00000';
	LET cCadena				= "";
	LET cEstatusConsulta	= "";
	LET iCantidad			= 0;
	LET sCont				= 0;
	LET cNumCte				= '';
	LET dFechaConsulta		= DATE(1);

	--SET DEBUG FILE TO "/tmp/Victor/sp_reconsultastatushuellalineaatrasadas.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
			
				RETURN  cCodRet, cCadena,cEstatusConsulta;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--Obtiene la cantidad de huellas a enviar por ejecucion
		SELECT valor ::INT INTO iCantidad FROM si_param WHERE cod_param = 347;
		
		IF iCantidad IS NULL THEN
			LET iCantidad = 10;
		END IF;
		
		FOREACH
			--Buscar las huellas que no se han enviado de dias anteriores
			--status_consulta: 0 SIN ENVIAR, 3 ERROR, 9 PENDIENTE
			SELECT LIMIT iCantidad {+AVOID_FULL("informix".tmp_si_huella_linea)} TRIM(numcte) ||"|"|| TRIM(secuencia)||"|"||TRIM(sucursal)
			||"|"||TRIM(ip), status_consulta,numcte, fecha_consulta
			INTO cCadena, cEstatusConsulta,cNumCte,dFechaConsulta
			FROM bdinteg:"informix".tmp_si_huella_linea
			WHERE status_consulta IN ('3','9','0')
			AND fecha_insert < CURRENT - 1 UNITS DAY 
			AND (CASE WHEN NVL(ticket, '') = '' THEN 0 ELSE ticket::INT END) <= 0 
			ORDER BY status_consulta 
			
			--Se ingresa actualizaciÃ³n de registros enviados al demonio de huellas atrasadas
			UPDATE {+AVOID_FULL("informix".tmp_si_huella_linea)} "informix".tmp_si_huella_linea SET status_consulta='1' WHERE numcte=cNumCte AND fecha_consulta=dFechaConsulta AND status_consulta=cEstatusConsulta;
			
			IF cCadena IS NOT NULL THEN
				RETURN cCodRet, TRIM(cCadena), cEstatusConsulta WITH RESUME;
			END IF;
			
		END FOREACH;

	END
END PROCEDURE;