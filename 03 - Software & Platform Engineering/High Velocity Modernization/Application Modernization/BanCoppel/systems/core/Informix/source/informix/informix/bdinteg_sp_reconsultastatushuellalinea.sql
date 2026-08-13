CREATE PROCEDURE "informix".sp_reconsultastatushuellalinea()

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5) 	AS CodigoRetorno,
	CHAR(2000) 	AS TramaSalida,
	CHAR(1)		AS EstatusConsulta;

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err 		INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE cCadena			CHAR(2000);
	DEFINE cEstatusConsulta	CHAR(1);

	--INICIALIZACION DE VARIABLES--
	LET iSql_err		= 0;
	LET cCodRet			= '00000';
	LET cCadena			= "";
	LET cEstatusConsulta	= "";

	--SET DEBUG FILE TO "/tmp/JA/sp_reconsultastatushuellalinea.out";
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

		FOREACH
			--Buscar las huellas que no se han enviado
			SELECT LIMIT 10 {+AVOID_FULL("informix".si_huella_linea)} TRIM(numcte) ||"|"|| TRIM(secuencia) ||"|"|| TRIM(sexo) ||"|"|| TRIM(sucursal) ||"|"|| YEAR(fecha_alta_huella)|| LPAD(MONTH(fecha_alta_huella),2,0) || LPAD(DAY(fecha_alta_huella),2,0) ||"|"|| TRIM(ip) ||"|"|| TRIM(tipo_mov_huella) ||"|"||
			TRIM(empleado) ||"|"|| TRIM(tipo_sensor) ||"|"|| TRIM(dmapa) ||"|"|| TRIM(imapa) ||"|"|| TRIM(status_huella) ||"|"|| TRIM(ref_coppel) ||"|"|| 
			YEAR(fecha_ult_cambio)|| LPAD(MONTH(fecha_ult_cambio),2,0)|| LPAD(DAY(fecha_ult_cambio),2,0)||" "||(fecha_ult_cambio::DATETIME HOUR TO HOUR::CHAR(2))||":"|| (fecha_ult_cambio::DATETIME MINUTE TO MINUTE::CHAR(2))||":"||(fecha_ult_cambio::DATETIME SECOND TO SECOND::CHAR(2)) ||"|"|| 
			TRIM(tipo_cliente) ||"|"||TRIM(tipo_verificacion) ||"|"|| TRIM(status_consulta), status_consulta --0 SIN ENVIAR, 3 ERROR, 9 PENDIENTE
			INTO cCadena, cEstatusConsulta
			FROM bdinteg:"informix".si_huella_linea
			WHERE fecha_consulta = TODAY 
			AND (CASE WHEN NVL(ticket, '') = '' THEN 0 ELSE ticket::INT END) <= 0 
			AND status_consulta IN ('3','9','0') 
			AND fecha_insert < CURRENT - 10 UNITS MINUTE 
			ORDER BY status_consulta, fecha_consulta DESC 
			
			
			/*SELECT LIMIT 10 TRIM(numcte) ||"|"|| TRIM(secuencia) ||"|"|| TRIM(sexo) ||"|"|| TRIM(sucursal) ||"|"|| YEAR(fecha_alta_huella)|| LPAD(MONTH(fecha_alta_huella),2,0) || LPAD(DAY(fecha_alta_huella),2,0) ||"|"|| TRIM(ip) ||"|"|| TRIM(tipo_mov_huella) ||"|"||
			TRIM(empleado) ||"|"|| TRIM(tipo_sensor) ||"|"|| TRIM(dmapa) ||"|"|| TRIM(imapa) ||"|"|| TRIM(status_huella) ||"|"|| TRIM(ref_coppel) ||"|"|| 
			YEAR(fecha_ult_cambio)|| LPAD(MONTH(fecha_ult_cambio),2,0)|| LPAD(DAY(fecha_ult_cambio),2,0)||" "||(fecha_ult_cambio::DATETIME HOUR TO HOUR::CHAR(2))||":"|| (fecha_ult_cambio::DATETIME MINUTE TO MINUTE::CHAR(2))||":"||(fecha_ult_cambio::DATETIME SECOND TO SECOND::CHAR(2)) ||"|"|| 
			TRIM(tipo_cliente) ||"|"||TRIM(tipo_verificacion) ||"|"|| TRIM(status_consulta), status_consulta --0 SIN ENVIAR, 3 ERROR, 9 PENDIENTE
			INTO cCadena, cEstatusConsulta
			FROM bdinteg:"informix".si_huella_linea
			WHERE status_consulta IN ('3','9') 
			AND (CASE WHEN NVL(ticket, '') = '' THEN 0 ELSE ticket::INT END) <= 0 
			AND DATE(fecha_consulta) = TODAY 
			AND fecha_insert::DATETIME HOUR TO MINUTE < CURRENT HOUR TO MINUTE - 1 UNITS MINUTE 
			ORDER BY status_consulta, fecha_consulta DESC 
			*/
			IF cCadena IS NOT NULL THEN
				RETURN cCodRet, TRIM(cCadena), cEstatusConsulta WITH RESUME;
			END IF;
		END FOREACH;

	END
END PROCEDURE
DOCUMENT
'Se obtienen los registros de las huellas que no se han enviado tuvieron algun problema o estan pendientes por enviar',
'Autor :Josue Zepeda',
'FECHA : 22/07/2013',
'BD: bdinteg',
'Folio: 1335',
'Autor: 94565457',
'Fecha: 30/10/2013',
'ModificaciÃ³n: Se modifica agregando; "LIMIT 100" a consulta, y se ordena por; "status_consulta,fecha_alta_huella" ',
'Sustento: El dia 26/09/2013 Se llega acuerdo entre Sonia Guzman Rodriguez y Manuel Osuna para realizar dicha modificacion',
'Solicita: Jaime Gonzalez',
'BD: BDINTEG',
'ASUNTO:		ModificaciÃ³n',
'ELABORÃ: 		95579737 - JosÃ© Ernesto Raygoza Villa',
'DESCRIPCIÃN: 	Se modifica el limite de registros, de 100 a 10, el  status_consulta se cambia de (1,9) a (0,9) y se condiciona que la fecha del Ãºltimo cambia sea la de hoy',
'FECHA: 		10/11/2013',
'Autor: 92802036 Josue Zepeda',
'Fecha: 28/10/2013',
'ModificaciÃ³n: Se modifica filtrandose por fecha_consulta" ',
'Sustento: El dia 28/10/2013 Se llega acuerdo entre Sonia Guzman Rodriguez y Manuel Osuna para realizar dicha modificacion',
'Solicita: Jaime Gonzalez',
'BD: BDINTEG',
'Folio:1354',
'Autor:92802036 - Josue Zepeda',
'Fecha:27/11/2013',
'ModificaciÃ³n: Se Agrega status_consulta =  3 y se valida fecha_insert',
'Sustento: Se definio por Telefono Con Manuel Osuna y Sonia Guzman, y se acepto por correo',
'se encuentra plasmado el cambio en el cuerpo del correo del dÃ­a 27/11/2013',
'Solicita:Manuel Osuna',
'BD:BDINTEG',
'Autor:95564063 - Anahi Leyva',
'Fecha:07/01/2015',
'ModificaciÃ³n: Se quita filtro de registros con status_consulta= 0',
'Sustento: RQI 64 061_Mantenimiento_comparacion_de_huellas_en_linea_v1.0',
'Solicita: Jaime Gonzalez',
'BD:Bdinteg',
'---------------------------------------------------------------------------------------------------------------------------------',
'Folio.........: 1575 - INC_ReenvioHuella',
'Autor.........: 95526749 - JesÃºs Horacio LÃ³pez GonzÃ¡lez',
'Fecha.........: 09/03/2015 - DSB20150309',
'ModificaciÃ³n..: Se modifica para que consulte los clientes con status = 0 y tengan 10 minutos o mas de haberse insertado',
'Sustento......: 64 076_MejCorrec_v1.0.',
'Solicita......: JosÃ© Angel LÃ³pez Adams',
'BD............: BDINTEG',
'----------------------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_bit_solicitudessos (pNumCte CHAR(20), 
														   pTipoSol CHAR(20), 
														   pNombreInc CHAR (104), 
														   pFechaNacInc DATE, 
														   pNombreCorr CHAR(104),
														   pFechaNacCorr DATE, 
														   pSucursal CHAR(4), 
														   pNumEmp CHAR(8), 
														   pOrigen CHAR(1)) 
RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cFechaNacInc DATE;


--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';
LET cFechaNacInc = DATE(1);

--SET DEBUG FILE TO '/informix/cristo/sp_bit_solicitudessos.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF (pNumCte IS NULL OR pNumCte  = '') OR (pTipoSol IS NULL OR pTipoSol = '')
		OR (pNombreInc  IS NULL OR pNombreInc  = '') 
		OR (pFechaNacInc IS NULL OR pFechaNacInc = '') 
		OR (pNombreCorr IS NULL OR pNombreCorr = '')  
		OR (pFechaNacCorr IS NULL OR pFechaNacCorr = '') 
		OR (pSucursal IS NULL OR pSucursal = '') 
		OR (pNumEmp IS NULL OR pNumEmp = '') 
		OR (pOrigen IS NULL OR pOrigen = '') THEN
		LET cCodRet = '00001';
	ELSE
		
		SELECT first 1 {+AVOID("informix".si_ctepf)}fecha_nac INTO cFechaNacInc FROM "informix".si_ctepf WHERE numcte=pNumCte;
		
		IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
			LET pFechaNacInc = cFechaNacInc;			
		END IF;
		
		INSERT INTO bdinteg:"informix".si_bitacora_solicitudessos
		(numcte, tipo_sol, nombre_inc, fecha_nac_inc, nombre_corr, fecha_nac_corr, sucursal, numemp, origen, fecha_insert)
		VALUES( pNumCte, pTipoSol  , pNombreInc, pFechaNacInc  , pNombreCorr, pFechaNacCorr, pSucursal, pNumEmp, pOrigen,CURRENT);
	END IF	
	RETURN cCodRet;
		
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION:Se crea procedimiento almacenado para llamar sp_bit_solicitudessos el cual guardara  una bitacora de las coincidencias para su posterior procesamiento. ',
'AUTOR : Leonardo Alfonso Plata Garcia',
'FECHA : 06/09/2013',
'MODIFICACION: Se obtiene fecha de nacimiento del cliente para evitar errores en la convercion de fechas antes del llamado de este procedimiento',
'FECHA: 25/03/2015',
'VERSION: ',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actualizactebiometria(pTipo CHAR(1), pNumCte CHAR(20))
    RETURNING CHAR(5) AS CodRet;

    --Definicion de Variables
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);

    --Inicializacion de Variables
    LET iSqlErr = 0;
    LET cCodRet = '000';

    --SET DEBUG FILE TO '/informix/IrisA/sp_actualizactebiometria.out';
    --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		IF pTipo = '1' THEN
			UPDATE "informix".si_cliente SET tpo_biometria = '2' WHERE numcte = pNumCte;
		ELSE
			LET cCodRet = '001'; -- No Existe el Tipo de Consulta
		END IF;

        RETURN cCodRet;
    END;
END PROCEDURE;