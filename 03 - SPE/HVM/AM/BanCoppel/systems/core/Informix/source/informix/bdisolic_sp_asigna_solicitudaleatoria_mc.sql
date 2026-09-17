CREATE PROCEDURE "informix".sp_asigna_solicitudaleatoria_mc(pEmpresa CHAR(3), pStatus CHAR(2), ejecutivo_mc CHAR(8),tipo_ejecucion CHAR(1))
RETURNING CHAR(6)       AS codigo_retorno,
          VARCHAR(20,1) AS numero_solicitud,
		  VARCHAR(20,1) AS numero_cliente,
		  CHAR(100) as nombrecliente, 
		  CHAR(80) as nombreanalista, 
		  DATETIME HOUR TO SECOND as hora;

DEFINE cCodRet		    CHAR(6);
DEFINE iSqlErr		    INTEGER;
DEFINE iSamErr		    INTEGER;
DEFINE cErrorInfo	    VARCHAR(80);

DEFINE cCodRet2         CHAR(6);
DEFINE cMensajeRet2     VARCHAR(80);	
DEFINE cNumSolicitud	CHAR(20);
DEFINE cNumCte			CHAR(20);
DEFINE cRevisado		CHAR(1);
DEFINE cNombreCte		CHAR(100);
DEFINE cRfc				CHAR(13);
DEFINE cSucursal		CHAR(4);
DEFINE dFechaInsert		DATE;
DEFINE dFechaModif		DATE;
DEFINE dcMontoSolic		DECIMAL(18,2);
DEFINE cStatusIni		CHAR(2);
DEFINE v_hereda_status  CHAR(2);
DEFINE cCausaSolic		CHAR(3);
DEFINE cObservaciones	CHAR(300);
DEFINE cNumProducto		CHAR(4);
DEFINE cStatusFin		CHAR(2);
DEFINE cEjecAtiende		CHAR(8);
DEFINE cEjecAutoriza	CHAR(8);
DEFINE dtHoraInsert		DATETIME HOUR TO SECOND;
DEFINE dFechaDetermin	DATE;
DEFINE dcEficiencia		DECIMAL(18,2);
DEFINE sHistorial		SMALLINT;
DEFINE dcSeccion1		DECIMAL(18,2);
DEFINE dcSeccion2		DECIMAL(18,2);
DEFINE cNombreAnalista 	CHAR(100);
DEFINE cHora 			DATETIME HOUR TO SECOND;
DEFINE cUsuario 		CHAR(8);
DEFINE cIpMaquina 		CHAR(16);
DEFINE cStatusaAnalista CHAR(8);
DEFINE cAp_Paterno		CHAR(26);
DEFINE cAp_Materno  	CHAR(26);
DEFINE cNombre1 		CHAR(26);
DEFINE cNombre2			CHAR(26);

DEFINE cCodRet3			CHAR(6);
DEFINE cMensajeRet3 	CHAR(45);

LET cCodRet				= "000000";
LET iSqlErr				= 0;
LET iSamErr				= 0;
LET cErrorInfo			= "";

LET cCodRet2        	= "";
LET cMensajeRet2    	= "";
LET cNumSolicitud		= "";
LET cNumCte				= "";
LET cRevisado			= 'N';
LET cNombreCte			= '';
LET cRfc				= '';
LET cSucursal			= '';
LET dFechaInsert		= DATE(1);
LET dFechaModif			= DATE(1);
LET dcMontoSolic		= 0.00;
LET cStatusIni			= '';
LET v_hereda_status		= '';
LET cCausaSolic			= '';
LET cObservaciones		= '';
LET cNumProducto		= '';
LET cStatusFin			= '';
LET cEjecAtiende		= '';
LET cEjecAutoriza		= '';
LET dtHoraInsert		= "";
LET dFechaDetermin		= DATE(1);
LET dcEficiencia		= 0.00;
LET sHistorial			= 0;
LET dcSeccion1			= 0.00; 
LET dcSeccion2			= 0.00;
LET cNombreAnalista 	= '';
LET cHora 				= "";
LET cUsuario 			= '';
LET cIpMaquina 			= '';
LET cStatusaAnalista 	= '';
LET cAp_Paterno			= '';
LET cAp_Materno  		= '';
LET cNombre1 			= '';
LET cNombre2			= '';

LET cCodRet3      		= "";
LET cMensajeRet3    	= "";

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN NVL(cCodRet,''),NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''), NVL(cNombreAnalista,''), NVL(cHora,'');
END IF;
END EXCEPTION; 	

--SET DEBUG FILE TO "/informix/gpe/sp_asigna_solicitud_mc.out";
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF TRIM(NVL(pEmpresa,"")) = "" OR TRIM(NVL(pStatus,"")) = "" OR TRIM(NVL(ejecutivo_mc,"")) = "" THEN
	LET cCodRet = "000001"; --SE VALIDA QUE LA EJECUCIÃ??N CONTENGA LOS PARAMETROS REQUERIDOS
	RETURN NVL(cCodRet,''),NVL(cNumSolicitud,''),NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cNombreAnalista,''), NVL(cHora,'');
END IF;

IF tipo_ejecucion IN( 1,3) THEN
-- PARA DESBLOQUEAR SOLICITUDES PENDIENTES POR EL ANALISTA

	FOREACH 
	  EXECUTE PROCEDURE "informix".sp_consultaactualizasolicmc(pEmpresa, '', ejecutivo_mc, 'MC', '', '', 1)
		INTO cCodRet, cNumSolicitud, cNumCte, cNombreCte, cRfc, cSucursal, dFechaInsert, 
				   dFechaModif, dcMontoSolic, dcEficiencia, sHistorial, cStatusIni, dcSeccion1, 
				   dcSeccion2, cCausaSolic, cObservaciones, cNumProducto,cStatusFin, cEjecAtiende, 
				   cEjecAutoriza, dtHoraInsert, dFechaDetermin, cRevisado

		IF tipo_ejecucion = 1 THEN
		
			DELETE FROM "informix".ss_cte_procesando WHERE usuario = ejecutivo_mc;
		
			UPDATE  bdisolic:ss_solicitudes_mc SET ejecutivo_atiende ='' WHERE ejecutivo_atiende = ejecutivo_mc AND status_fin = '' AND revisado <> 'S';

			EXECUTE PROCEDURE "informix".sp_mc_sol_procesando(cNumCte,ejecutivo_mc,1)
			INTO cCodRet2, cMensajeRet2;

          
			IF cCodRet2 = -268 THEN
				CONTINUE FOREACH;
			ELIF cCodRet2 = '000000' THEN 
				EXECUTE PROCEDURE "informix".sp_actualizasolicmc(cNumSolicitud, cSucursal , ejecutivo_mc, 1)
				INTO cCodRet3, cMensajeRet3;
				
				IF cCodRet3 <> '00000' THEN
					CONTINUE FOREACH;
				END IF
				
				RETURN NVL(cCodRet2,''),NVL(cNumSolicitud,''),NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cNombreAnalista,''), NVL(cHora,'');
				EXIT FOREACH;    
			END IF
		ELIF tipo_ejecucion = 3 THEN
			SELECT usuario INTO cUsuario FROM bdisolic:ss_cte_procesando WHERE numcte = cNumCte AND fecha_insercion = dFechaInsert;
			IF NVL(cUsuario,'') <> '' THEN
				CONTINUE FOREACH;
			ELSE
				RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cNombreAnalista,''), NVL(dtHoraInsert,'') WITH RESUME;
			END IF;
		END IF;
		
	END FOREACH;

ELIF tipo_ejecucion = 2 THEN

	FOREACH
	SELECT a.numcte, b.num_solicitud, --TRIM(d.nombre1)||' '||TRIM(d.nombre2)||' '||TRIM(d.apell_paterno)||' '||TRIM(d.apell_materno) ,
									 d.nombre1, d.nombre2, d.apell_paterno, d.apell_materno,
	 c.nombre, a.hora_insercion
	INTO cNumCte,cNumSolicitud,cNombre1, cNombre2, cAp_Paterno, cAp_Materno, cNombreAnalista, cHora
	FROM bdisolic:ss_solicitudes_mc b
	INNER JOIN bdisolic:ss_cte_procesando a ON(a.numcte = b.numcte)
	--INNER JOIN bdisolic:ss_solicitudes_mc b ON(a.numcte = b.numcte)
	INNER JOIN bdinteg:si_ejecut c ON (a.usuario = c.ejecutivo)
	INNER JOIN bdinteg:si_cliente d ON(a.numcte = d.numcte)
	AND b.fecha_insert = (select max(fecha_insert) from bdisolic:ss_solicitudes_mc e where e.numcte = a.numcte)
	
	LET cNombreCte = TRIM(cNombre1)||' '||TRIM(cNombre2)||' '||TRIM(cAp_Paterno)||' '||TRIM(cAp_Materno);

	RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cNombreAnalista,''), NVL(cHora,'') WITH RESUME;

	END FOREACH;


ELIF tipo_ejecucion = 4 THEN

	FOREACH
	
	
	SELECT a.ejecutivo ,a.nombre_analista,a.ipmaquina,a.status_analista
		INTO cEjecAtiende,cNombreAnalista,cIpMaquina, cStatusaAnalista
	FROM bdisolic:ss_analistaenatencion a
	--INNER JOIN bdisolic:ss_cte_procesando b on (b.usuario = a.ejecutivo)
	
	RETURN cCodRet, NVL(cEjecAtiende,''), NVL(cIpMaquina,''), NVL(TRIM(cNombreAnalista),''), NVL(TRIM(cStatusaAnalista),''), NVL(cHora,'') WITH RESUME;

	END FOREACH;
END IF;

IF DBINFO("sqlca.sqlerrd2") = 0 THEN
	LET cCodRet = "000002"; --NO HAY CLIENTES POR ASIGNAR
	RETURN NVL(cCodRet,''),NVL(cNumSolicitud,''),NVL(cNumCte,''), NVL(cNombreCte,''), NVL(cNombreAnalista,''), NVL(cHora,'');
END IF;

END
END PROCEDURE
