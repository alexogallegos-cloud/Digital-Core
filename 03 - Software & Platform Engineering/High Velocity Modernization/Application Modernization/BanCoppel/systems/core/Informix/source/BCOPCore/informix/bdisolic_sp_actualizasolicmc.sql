CREATE PROCEDURE "informix".sp_actualizasolicmc(pNumSolicitud CHAR(20), pSucursal CHAR(4), pEjecutivoAtiende CHAR(8), pTipo SMALLINT)
RETURNING
	CHAR(6) AS CodRet,
	CHAR(45) AS NombreAtiende;
	
-- DECLARACIONES
DEFINE cCodRet            	CHAR(6);
DEFINE cCodRet2            	CHAR(6);
DEFINE iSqlErr     			INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);

DEFINE cEjecutAtiende 		CHAR(8);
DEFINE cStatusFin 			CHAR(2);
DEFINE cMinutosMax			CHAR(10);
DEFINE dtHoraInsert			DATETIME HOUR TO FRACTION;
DEFINE cMinTransc			CHAR(10);
DEFINE cNomAtiende			CHAR(45);

-- INICIALIZACIONES
LET cCodRet 				= '00000';
LET cCodRet2 				= '000000';
LET iSqlErr 				= 0;
LET iIsamErr 				= 0;
LET cErrorInfo 				= '';

LET cEjecutAtiende 			= '';
LET cStatusFin	 			= '';
LET cMinutosMax				= '00:00:00';
LET dtHoraInsert			= EXTEND(CURRENT,HOUR TO FRACTION(5));
LET cMinTransc				= '00:00:00';
LET cNomAtiende				= '';

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr::CHAR(6);
			RETURN cCodRet, NVL(cNomAtiende ,'');
		END IF;
	END EXCEPTION; 
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	-- SET DEBUG FILE TO "/home/sysifx/vlv/sp_actualizasolicmc.out";
	-- TRACE ON;
	
	IF NVL(pTipo, 0) = 0 OR pTipo NOT IN(1,2) THEN
		LET cCodRet = '00001'; -- DEBE ESPECIFICAR EL TIPO CORRECTO DE EJECUCIÓN A REALIZAR.
		RETURN cCodRet, NVL(cNomAtiende ,'');
	END IF
	
	IF pTipo = 1 THEN -- MARCAMOS LA SOLICITUD COMO ANTENDIDA.
	
		IF NVL(pNumSolicitud,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pEjecutivoAtiende, '') = '' THEN
			LET cCodRet = '00002'; -- FALTAN PARAMETROS OBLIGATORIOS
			RETURN cCodRet, NVL(cNomAtiende ,'');
		END IF
		
	 -- VERIFICAMOS SI LA SOLICITUD ESTA SIENDO ATENDIDA POR ALGUN USUARIO.
		SELECT ejecutivo_atiende, status_fin, hora_insert
		  INTO cEjecutAtiende, cStatusFin, dtHoraInsert
		FROM "informix".ss_solicitudes_mc
		WHERE num_solicitud = pNumSolicitud
		  AND sucursal = pSucursal;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00003'; -- NO SE ENCONTRARON REGISTROS CON EL CRITERIO DE BUSQUEDA.
			RETURN cCodRet, NVL(cNomAtiende ,'');
		END IF
		
		IF TRIM(NVL(cEjecutAtiende,'')) <> '' AND TRIM(NVL(cEjecutAtiende,'')) <> TRIM(NVL(pEjecutivoAtiende, '')) AND TRIM(NVL(cStatusFin,'')) = '' THEN
			SELECT nombre INTO cNomAtiende FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = TRIM(cEjecutAtiende);
			
			LET cCodRet = '00004'; -- LA SOLICITUD YA ESTA SIENDO ATENDIDA POR OTRO USUARIO.

		ELIF TRIM(NVL(cEjecutAtiende,'')) <> '' AND TRIM(NVL(cStatusFin,'')) <> '' THEN
			SELECT nombre INTO cNomAtiende FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = TRIM(cEjecutAtiende);
			
			LET cCodRet = '00005'; -- LA SOLICITUD YA FUE ATENDIDA POR OTRO USUARIO.
			
		ELIF TRIM(NVL(cEjecutAtiende,'')) = '' AND TRIM(NVL(cStatusFin,'')) <> '' THEN
			LET cCodRet = '00006'; -- SOLICITUD SE ENVIO A ORDEN SUPERVISION CALLE POR SISTEMA.
			
		ELIF NVL(TRIM(cEjecutAtiende),'') = '' OR TRIM(NVL(cEjecutAtiende,'')) = TRIM(NVL(pEjecutivoAtiende, '')) AND NVL(TRIM(cStatusFin), '') = '' THEN
		
		 -- LIMITE DE TIEMPO MAXIMO PARA SER ATENDIDA UNA SOLICITUD EN PANTALLA CCONCAC.
			SELECT valor_alfabetico::DATETIME HOUR TO SECOND INTO cMinutosMax FROM bdicobranza:"informix".cb_param_campania 
			WHERE tipo_campania = '56' AND grupo_parametro = 'MCTRLINEA' AND num_parametro = '2';			
		 -- OBTENEMOS LOS MINUTOS QUE TIENE LA SOLICITUD "MC" DESDE QUE SE DIO DE ALTA.
			
			 -- MARCAMOS LA SOLICITUD QUE SE ESTA ATENDIENDO.
				UPDATE "informix".ss_solicitudes_mc SET ejecutivo_atiende = pEjecutivoAtiende WHERE num_solicitud = pNumSolicitud AND sucursal = pSucursal;		
		END IF
	END IF
	
	-- REGRESAMOS LA SOLICITUD A SU ESTADO ORIGINAL.
	IF pTipo = 2 THEN
	
		IF NVL(pNumSolicitud,'') = '' OR NVL(pSucursal,'') = '' THEN
			LET cCodRet = '00002'; -- FALTAN PARAMETROS OBLIGATORIOS
			RETURN cCodRet, NVL(cNomAtiende ,'');
		END IF
		
		-- ACTUALIZAMOS LA SOLITUD COMO SE ENCONTRABA AL PRICIPIO PARA QUE PUEDA SER ATENDIDA POR OTRO USUARIO.
		UPDATE "informix".ss_solicitudes_mc SET ejecutivo_atiende = "" 
		WHERE num_solicitud = pNumSolicitud AND sucursal = pSucursal
		AND status_fin = "";
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00009'; -- LA SOLICITUD NO FUE REESTABLECIDA.
		END IF
	END IF
	
	RETURN cCodRet, NVL(cNomAtiende ,'');
END;

END PROCEDURE
