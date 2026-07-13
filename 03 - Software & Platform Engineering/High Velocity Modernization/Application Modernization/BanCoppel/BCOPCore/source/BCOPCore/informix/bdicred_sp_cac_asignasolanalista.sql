CREATE PROCEDURE "informix".sp_cac_asignasolanalista(pEmpresa     CHAR(3),
													  pNumCredito CHAR(20),
													  pUsuario 	  CHAR(8),
													  pMonto 	  DECIMAL(18,2))
														   
RETURNING CHAR(6)           AS cod_ret,
          VARCHAR(107,1)    AS mensaje_ret,
	INTEGER           AS iGuardoHistorica

DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(255,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(107,1);
DEFINE cNombreUsuario    VARCHAR(107,1);
DEFINE iBanderGuardar    INTEGER;
DEFINE iBanderaMensaje    INTEGER;
DEFINE iRevisionCac    INTEGER;
DEFINE iNivelAuto    INTEGER;
DEFINE cPuesto         CHAR(107);
DEFINE cRangoAut         CHAR(2);
DEFINE cUsuarioProceso  CHAR(8);
DEFINE dtFecha  DATE;
DEFINE dtFechaInsert DATE;
DEFINE cEstatus CHAR(2);
DEFINE dtHoraIngresoAC      DATETIME HOUR TO FRACTION;
	
LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET cMensajeRet        = "CONSULTA EXITOSA";
LET cNombreUsuario     = "";
LET iBanderGuardar     = 0;
LET iBanderaMensaje    = 0;
LET iRevisionCac       = 0;
LET iNivelAuto         = 0;
LET cPuesto       	   = "";
LET cRangoAut       	   = "";
LET cUsuarioProceso    ="";
LET dtFecha       	   = DATE(1);
LET dtFechaInsert      = DATE(1);
LET cEstatus           = "";
LET dtHoraIngresoAC      = CURRENT;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet,1;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/sp_cac_asignasolanalista.out';
	--TRACE ON;

	IF NVL(pEmpresa,"") = "" OR NVL(pNumCredito,"") = "" OR NVL(pUsuario,"") = ""  OR NVL(pMonto,0) = 0 THEN
	 LET cCodRet = "000001";
	 LET cMensajeRet = "PARAMETROS DE ENTRADA INVALIDOS";
	 RETURN cCodRet,cMensajeRet,1;
	END IF;
	
	SELECT MAX(fecha_insert) --PIQV
	INTO dtFechaInsert
	FROM "informix".sd_bitacora_aumlincred
	WHERE empresa = pEmpresa
	AND num_solicitud = pNumCredito
	AND status = 'AC';
	
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		 LET cCodRet = "000007";
		 LET cMensajeRet = "EL ESTATUS DE LA SOLICITUD CAMBIÓ FAVOR DE VERIFICAR";
		 RETURN cCodRet,cMensajeRet,1;	
	END IF;	
	
	
	--JMAH
	DELETE FROM bdicred:"informix".sd_sol_procesando_aumlincred WHERE usuario =pUsuario;
	
	SELECT revision_cac
		INTO iRevisionCac
	FROM bdicred:"informix".sd_autorizacion_aumlincred
	WHERE  num_solicitud = pNumCredito
	AND status = 'AC'
	 AND fecha_status = (SELECT MAX(fecha_status)	
						FROM bdicred:"informix".sd_autorizacion_aumlincred
						WHERE  num_solicitud = pNumCredito
						AND status = 'AC' );
	   
	
	SELECT b.nombre,a.nivel,a.puesto,a.rango_autorizacion
		INTO cNombreUsuario,iNivelAuto,cPuesto, cRangoAut
	FROM bdicred:"informix".sd_perfiles_cac_aumlincred a 
	INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo  = a.ejecutivo)
	INNER JOIN bdicred:"informix".sd_autorizaciones_cac_aumlincred c ON (pMonto BETWEEN c.monto_minimo AND c.monto_maximo)
	WHERE  b.ejecutivo = pUsuario
	AND a.rango_autorizacion = c.rango_autorizacion;
	
	
	IF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_sol_procesando_aumlincred WHERE num_credito = pNumCredito) THEN	
		SELECT  b.nombre,a.usuario
			INTO cNombreUsuario,cUsuarioProceso
		FROM bdicred:"informix".sd_sol_procesando_aumlincred a
		INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo = a.usuario)
		WHERE num_credito = pNumCredito;
		
		IF cUsuarioProceso <>  pUsuario THEN
			LET cCodRet = "000002";
			LET cMensajeRet = "SOLICITUD ESTÁ SIENDO ATENDIDA POR "|| TRIM(cNombreUsuario);		
		ELSE
			IF iRevisionCac > iNivelAuto   THEN
				LET cCodRet = "000006";	
				LET cMensajeRet = "MISMO USUARIO ATENDIENDO LA SOLICITUD PERO YA PASO DE REVISION ";
			ELSE
				LET cCodRet = "000004";	
				LET cMensajeRet = "MISMO USUARIO ATENDIENDO LA SOLICITUD (CASOS DE ERROR) ";	
			END IF;
		END IF;		
		
		RETURN cCodRet,cMensajeRet, 1;
	END IF
	
	IF NVL(iNivelAuto,0) = 0 THEN
		LET iNivelAuto= 6;
	END IF;	
	
	IF iRevisionCac > 0 THEN 		
		IF iNivelAuto < iRevisionCac THEN  --se checa que se el mismo analista que trabajo la solicitud
					
			SELECT limit 1 ejecutivo
				INTO cUsuarioProceso
			FROM bdicred:"informix".sd_historica_cac_aumlincred
			WHERE   solicitud = pNumCredito and fecha_insert = dtFechaInsert --Lazalde agrega fecha insert
			and puesto::INTEGER = (SELECT  MAX(puesto::INTEGER)
									FROM  bdicred:"informix".sd_historica_cac_aumlincred
									WHERE   solicitud = pNumCredito and fecha_insert = dtFechaInsert ); --Lazalde agrega fecha insert
							
			IF TRIM(cUsuarioProceso) <> TRIM(pUsuario) THEN
				LET iBanderaMensaje =1;
			ELSE
				LET cCodRet = "000005";	
				LET cMensajeRet = "MISMO USUARIO QUE ATENDIO LA SOLICITUD";	
			END IF;		
			LET iBanderGuardar = 1;	
		ELIF iNivelAuto > iRevisionCac THEN
			LET iBanderaMensaje =1;
		ELIF (iNivelAuto = iRevisionCac) AND iNivelAuto =1 THEN	
			LET iBanderGuardar = 1;	
		END IF;		
		IF iNivelAuto = 6 THEN
			LET iBanderaMensaje =1;
		END IF;
	ELSE --cuando el campo sea 0 solo la puede trabajar un analista 
		IF iNivelAuto = iRevisionCac +1 THEN
			UPDATE bdicred:"informix".sd_autorizacion_aumlincred
			SET revision_cac = iNivelAuto
			WHERE num_solicitud = pNumCredito
			AND status = 'AC';				
		ELSE 
			LET iBanderaMensaje =1;
		END IF;
	END IF;
	IF iBanderaMensaje = 1 THEN
		LET cCodRet = "000003";
		LET cMensajeRet = "LA AUTORIZACIÓN NO CORRESPONDE A ESE NIVEL, FAVOR DE VALIDAR";
		RETURN cCodRet,cMensajeRet, iBanderGuardar;	
	END IF;
	
	IF iBanderGuardar = 0 THEN
		--Lazalde
		
			INSERT INTO "informix".sd_historica_cac_aumlincred
			(empresa,solicitud,ejecutivo,puesto,Rango_autorizacion,user_insert,fecha_insert,fecha_comentario, hora_revision)
			VALUES(pEmpresa, pNumCredito, pUsuario,cPuesto, cRangoAut, USER, dtFechaInsert,CURRENT, CURRENT HOUR TO FRACTION(3));
		
	END IF
	
	INSERT INTO bdicred:"informix".sd_sol_procesando_aumlincred(empresa,num_credito,usuario,fecha_insert)
	VALUES (pEmpresa, pNumCredito, pUsuario,CURRENT);


RETURN cCodRet,cMensajeRet,iBanderGuardar;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para la asignacion de solicitudes de incremento de líneas de crédito.',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 21/SEPT/2011',
'BD: BDICRED',
'VERSION:20110921.1107',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Juan Daniel Lazalde Centeno',
'Modificación: Se agrego fecha_comentario y hora revision en el insert a la tabla sd_historica_cac_aumlincred y se agrego fecha_insert en la consulta de sd_historica_cac_aumlincred para tomar el maximo puesto de la solicitud en revision',
'Fecha de modificación: 14/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_cac_histincremento(	
					pEmpresa CHAR(3), 
					pNumCte CHAR(20),
					pNumCred CHAR(20), 
					pEstatus CHAR(2)
					)
					
RETURNING CHAR(6)           AS cod_ret,
    VARCHAR(107,1)    AS mensaje_ret,
	VARCHAR(20) AS NumCredito,
	VARCHAR(2) AS Estatus,
	VARCHAR(10) AS Origen,
	VARCHAR(10) AS FechaCambioEstatus,
	DECIMAL(18,2) AS LineaInicial,
	DECIMAL(18,2) AS LineaFinal;


DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(255,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(107,1);
DEFINE cNumCred        CHAR(20);
DEFINE cEstatus        CHAR(2);
DEFINE cOrigen         CHAR(10);
DEFINE cFechaCambioEstatus   CHAR(10);
DEFINE dLineaInicial  DECIMAL(18,2);
DEFINE dLineaFinal    DECIMAL(18,2);

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET cMensajeRet        = "CONSULTA EXITOSA";
LET cNumCred = "";
LET cEstatus = "";
LET cOrigen = "";
LET cFechaCambioEstatus = "";
LET dLineaInicial = 0.0;
LET dLineaFinal = 0.0;
BEGIN

--SET DEBUG FILE TO "/home/sp_cac_histincremento.out";
--TRACE ON;

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet, cNumCred, cEstatus, cOrigen, cFechaCambioEstatus, dLineaInicial, dLineaFinal;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 4;
 
        FOREACH WITH HOLD  
			SELECT num_solicitud, status,DECODE(origen,"C","CENTRAL","S","SUCURSAL"),NVL(LPAD(DAY(fecha_status),2,'0') || '/' || LPAD(MONTH(fecha_status),2,'0') || '/' || YEAR(fecha_status),'') , lincred_actual,lincred_sugerida
			INTO cNumCred, cEstatus, cOrigen, cFechaCambioEstatus, dLineaInicial, dLineaFinal
			FROM "informix".sd_bitacora_aumlincred 
			WHERE empresa = pEmpresa
			AND numcte = pNumCte
			AND num_solicitud = pNumCred
			AND status = pEstatus
			ORDER BY fecha_insert

			RETURN cCodRet,cMensajeRet,cNumCred, cEstatus, cOrigen, cFechaCambioEstatus, dLineaInicial, dLineaFinal
			WITH RESUME;
        END FOREACH; 
        
END;
END PROCEDURE
DOCUMENT 
'Obtiene los incrementos aporbados para la solicitud',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 04/02/2013',
'BD: BDICRED',
'Version: 20130204.1714';

CREATE PROCEDURE "informix".sp_cac_observprevias(pEmpresa CHAR(3), pNumeroCredito CHAR(20), dtFechaInc DATE)					
RETURNING CHAR(6)        AS cod_ret, 
          VARCHAR(107,1) AS mensaje_ret, 
		  VARCHAR(208)   AS fechacomcjustificacion;


DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      VARCHAR(255,1);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(107,1);
DEFINE dtFechaComcJustificacion VARCHAR(208);

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = "";
LET cCodRet            = "000000";
LET cMensajeRet        = "CONSULTA EXITOSA";
LET dtFechaComcJustificacion = "";
BEGIN

--SET DEBUG FILE TO "/home/sp_cac_observprevias.out";
--TRACE ON;

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet     = iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN cCodRet,cMensajeRet, dtFechaComcJustificacion;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 4;

       FOREACH WITH HOLD  
          SELECT NVL(LPAD(DAY(fecha_comentario),2,'0') || '/' || LPAD(MONTH(fecha_comentario),2,'0') || '/' || YEAR(fecha_comentario),'')  || ' ' || justificacion 
		INTO dtFechaComcJustificacion
		FROM "informix".sd_historica_cac_aumlincred
		WHERE empresa = pEmpresa 
		AND solicitud = pNumeroCredito
		AND fecha_insert = dtFechaInc
		ORDER BY puesto

	    RETURN cCodRet,cMensajeRet,dtFechaComcJustificacion
            WITH RESUME;
        END FOREACH;
END;
END PROCEDURE
DOCUMENT 
'Obtiene las justificaciones para la solicitud de incremento de línea de crédito',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 04/02/2013',
'BD: BDICRED',
'Version: 20130204.1714';

CREATE PROCEDURE "informix".sp_cac_obtenanalisisydeterlincred(pEmpresa CHAR(3),pNumeroCredito CHAR(20),pStatus CHAR(2),pOrigen CHAR(1),pFecha_insert DATE)
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET,
		-- INFORMACION GENERAL DEL CLIENTE
		VARCHAR(20) 	AS NUM_SOL_INCREM,
		CHAR(2) 		AS STA_SOL_INCREM,
		VARCHAR(20) 	AS NUM_CREDITO,
		VARCHAR(20)		AS NUM_CTE,
		VARCHAR(107)	AS NOM_CTE,
		CHAR(13)		AS RFC,
		DATE			AS FECHA_ORIGEN,
		VARCHAR(15)		AS ORIGEN,
		CHAR(10)		AS FECHA_SOL_INCREM,
		CHAR(10)		AS FECHA_ULT_INCREM,
		CHAR(2)			AS GRADO_RIESGO,
		-- INFORMACION SOCIEDAD DE INFORMACION CREDITICIA
		CHAR(10)		AS ANTEC_BC,
		CHAR(10)		AS ANTEC_CC,
		MONEY(17,2)		AS COMPROM_PAGO_SIC,
		MONEY(17,2)		AS COMPROM_Hipotecario,
		-- INFORMACION CLIENTES COPPEL
		VARCHAR(20)		AS NUM_CTE_CPL,
		SMALLINT		AS ANTIGUEDAD,
		CHAR(2)			AS PUNTUALIDAD,
		DECIMAL(7,2)	AS EFICIENCIA_PAGO,
		DECIMAL(17,2)	AS MTO_VENCIDO,
		DECIMAL(17,2)	AS ABONO_MENSUAL,
		-- DETERMINACION DE INCREMENTO DE LINEA
		MONEY(17,2)		AS INGRESO_MENSUAL,
		DECIMAL(20,2)	AS ING_DEM_PAGOS,
		CHAR(2)			AS COMPRO_INGRESOS,
		DECIMAL(18,2)	AS COMPROMISO_BANCO,
		DECIMAL(18,2)	AS LINEA_CRED_ACT,
		DECIMAL(16,2)	AS LINEA_CRED_SOL,
		DECIMAL(18,2)	AS LINEA_CRED_SUG,
		DECIMAL(18,2)	AS MONTO_INCREM,
		DECIMAL(5,2)	AS PORC_INCREM,
		CHAR(800)		AS OBSERV_PREV,
		DECIMAL(18,2)       AS INGRESO_MC,
		DECIMAL(18,2)       AS OTROS_COMP,
		CHAR(2)             AS ESTATUS,
		CHAR(3)		AS CAUSA,
		CHAR(10)                AS FECHA_PRIMER_COMPRA;
			
		---DECLARACIONES
		DEFINE iSqlErr							INTEGER;
		DEFINE iIsamErr							INTEGER;
		DEFINE cCodRet							CHAR(6);
		DEFINE cMensajeRet						CHAR(80);
		-- INFORMACION GENERAL DEL CLIENTE
		DEFINE vcNum_Sol_Increm					VARCHAR(20);
		DEFINE cSta_Sol_Increm					CHAR(2);
		DEFINE vcNum_Credito					VARCHAR(20);
		DEFINE vcNum_Cte						VARCHAR(20);
		DEFINE vcNom_Cte						VARCHAR(107);
		DEFINE cRFC								CHAR(13);
		DEFINE dtFecha_Origen					DATE;
		DEFINE vcOrigen							VARCHAR(15);
		DEFINE cFecha_Sol_Increm				CHAR(10);
		DEFINE cFecha_Ult_Increm				CHAR(10);	
		DEFINE cGradoRiesgo						CHAR(2);
		-- INFORMACION SOCIEDAD DE INFORMACION CREDITICIA
		DEFINE cAntec_BC						CHAR(10);
		DEFINE cAntec_CC						CHAR(10);
		DEFINE mComprom_Pago_SIC				MONEY(17,2);
		-- INFORMACION CLIENTES COPPEL
		DEFINE vcNum_Cte_Cpl					VARCHAR(20);
		DEFINE sAntiguedad						SMALLINT;
		DEFINE cPuntualidad						CHAR(2);
		DEFINE dEficiencia_Pago					DECIMAL(7,2);
		DEFINE dMto_Vencido						DECIMAL(17,2);
		DEFINE dAbono_Mensual					DECIMAL(17,2);
		-- DETERMINACION DE INCREMENTO DE LINEA
		DEFINE mIngreso_Mensual					MONEY(17,2);
		DEFINE dIngDemoPagos					DECIMAL(20,2);
		DEFINE cComprobIngreso					CHAR(2);
		DEFINE dLineaCredAct					DECIMAL(18,2);
		DEFINE dLineaCredSol					DECIMAL(16,2);
		DEFINE dLineaCredSug					DECIMAL(20,2);
		DEFINE dMontoIncrem						DECIMAL(20,2);
		DEFINE dPorcIncrem						DECIMAL(5,2);
		DEFINE cObservPrev						CHAR(800);
		DEFINE cJustificacion					CHAR(200);
		DEFINE mCompromisosbanco            	MONEY (14,2);
		DEFINE mCompromisosbancoprestamo    	MONEY (14,2);
		DEFINE mCompromisosbancoTDC		    	MONEY(14,2);
		DEFINE mPorcentajecompromisosbancoTDC	DECIMAL(14,2);
		DEFINE dImporte_hip      				DECIMAL(14,2);
		DEFINE cCodUdi      					CHAR(2);
		DEFINE cCodUs       					CHAR(2);
		DEFINE dTpCambioUdi 					DECIMAL(14,6);
		DEFINE dTpCambioUs  					DECIMAL(14,6);
		DEFINE cClase        					CHAR(1);
		DEFINE iBanderaActualizar				INTEGER;
		DEFINE iBanderaActualizarhip			INTEGER;
		DEFINE iBanderaActualizaridp			INTEGER;
		DEFINE iBanderaActualizarSic			INTEGER;
		DEFINE cNumcredito						CHAR(20);
		DEFINE iNumPagos						INTEGER;				
		DEFINE dCTP								DECIMAL(18,4);
		DEFINE dIDP								DECIMAL(18,4);
		DEFINE iPorcIngreso						INTEGER;
		DEFINE dPagosRealizados					DECIMAL(18,2);
		DEFINE dtFechaHoy						DATE;
		DEFINE dtFechaInc						DATE;
		
		DEFINE dIngresoMC 						DECIMAL(18,2);
		DEFINE dOtrosComp						DECIMAL(18,2);
		DEFINE cEstatus                                                       CHAR(2);
		DEFINE cCausa                                                         CHAR(3);
		DEFINE dtFechaInsert					DATE;
		DEFINE cFechaPrimerCompra					CHAR(10);
		
		---INICIALIZACIONES
		LET iSqlErr            					= 0;
		LET iIsamErr           					= 0;
		LET cCodRet            					= '000000';
		LET cMensajeRet							= 'Proceso exitoso';
		LET vcNum_Sol_Increm					= '';
		LET cSta_Sol_Increm						= '';
		LET vcNum_Credito						= '';
		LET vcNum_Cte							= '';
		LET vcNom_Cte							= '';
		LET cRFC								= '';
		LET dtFecha_Origen						= DATE(1);
		LET vcOrigen							= '';
		LET cGradoRiesgo						= '';
		LET cFecha_Sol_Increm					= '';
		LET cFecha_Ult_Increm					= '';
		LET cAntec_BC							= '';
		LET mComprom_Pago_SIC					= 0.0;
		LET cAntec_CC							= '';
		LET vcNum_Cte_Cpl						= '';
		LET sAntiguedad							= 0;
		LET cPuntualidad						= '';
		LET dEficiencia_Pago					= 0.0;
		LET dMto_Vencido						= 0.0;
		LET dAbono_Mensual						= 0.0;
		LET mIngreso_Mensual					= 0.0;
		LET dIngDemoPagos						= 0.0;
		LET cComprobIngreso						= '';
		LET dLineaCredAct						= 0.0;
		LET dLineaCredSol						= 0.0;
		LET dLineaCredSug						= 0.0;
		LET dMontoIncrem						= 0.0;
		LET dPorcIncrem							= 0.0;
		LET cObservPrev							= '';
		LET cJustificacion						= '';
		LET mCompromisosbanco           		= 0;
		LET mCompromisosbancoprestamo   		= 0;
		LET mCompromisosbancoTDC	    		= 0;
		LET mPorcentajecompromisosbancoTDC	    = 0;
		LET dImporte_hip	 				   	= 0;
		LET cCodUdi      						= "";
		LET cCodUs       						= "";
		LET dTpCambioUdi 						= 0;
		LET dTpCambioUs  						= 0;
		LET cClase       						= "";	
		LET iBanderaActualizar       			= 0;	
		LET iBanderaActualizarhip       		= 0;	
		LET iBanderaActualizaridp       		= 0;	
		LET iBanderaActualizarSic       		= 0;	
		LET cNumcredito       					="";	
		LET iNumPagos							= 0;		
		LET dCTP								= 0.0;
		LET dIDP								= 0.0;
		LET iPorcIngreso						= 0;
		LET dPagosRealizados					= 0;
		LET dtFechaHoy							= DATE(1);
		LET dtFechaInc							= DATE(1);
		
		LET dIngresoMC                                   =0;
		LET dOtrosComp			         =0;
		LET cEstatus			         ="";
		LET cCausa 			         ="";
		LET dtFechaInsert                                =DATE(1);
		LET cFechaPrimerCompra                          ='';
		
		
		
	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;							
				RETURN cCodRet, cMensajeRet, NVL(vcNum_Sol_Increm,''), NVL(cSta_Sol_Increm,''), NVL(vcNum_Credito,''), NVL(vcNum_Cte,''), 
				NVL(vcNom_Cte,''), NVL(cRFC,''), NVL(dtFecha_Origen,'01/01/1900'), NVL(vcOrigen,''), NVL(cFecha_Sol_Increm,''), NVL(cFecha_Ult_Increm,''), 
				NVL(cGradoRiesgo,''), NVL(cAntec_BC,''), NVL(cAntec_CC,''), NVL(mComprom_Pago_SIC,0.0),NVL(dImporte_hip,0.0), NVL(vcNum_Cte_Cpl,''), NVL(sAntiguedad,0), 
				NVL(cPuntualidad,''), NVL(dEficiencia_Pago,0.0), NVL(dMto_Vencido,0.0),	NVL(dAbono_Mensual,0.0), NVL(mIngreso_Mensual,0.0), 
				NVL(dIngDemoPagos,0.0), NVL(cComprobIngreso,''), NVL(mCompromisosbanco,0.0) ,NVL(dLineaCredAct,0.0), NVL(dLineaCredSol,0.0), NVL(dLineaCredSug,0.0), 
				NVL(dMontoIncrem,0.0), NVL(dPorcIncrem,0.0), NVL(cObservPrev,''), NVL(dIngresoMC,0.0), NVL(dOtrosComp,0.0), NVL(cEstatus,''),NVL(cCausa,''),NVL(cFechaPrimerCompra,'');
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO "/informix/paulq/sp_cac_obtenanalisisydeterlincred.out";
		--TRACE OFF;
		
		IF NOT EXISTS (SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) OR (NVL(pNumeroCredito,'') = '') THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'EMPRESA NO ES VALIDA O EL NUMERO DE CREDITO ESTA VACIO';
		ELSE		
			-- OBTIENE LOS DATOS DE LA BITACORA DE AUMENTO DE LINEA DE CREDITO
			SELECT a.num_solicitud, a.status, a.num_solicitud, a.numcte, DECODE(TRIM(origen),'C','Central','S','Sucursal'), a.grado_riesgo, a.lincred_actual, a.lincred_sugerida,
				(lincred_sugerida - lincred_actual)::DECIMAL(20,2), LPAD(DAY(fecha_insert),2,'0') || '/' || LPAD(MONTH(fecha_insert),2,'0') || '/' || YEAR(fecha_insert), 
				a.numcte_cop, DECODE(a.antecedentes_buro,"0","BUENOS","1","MALOS","X","NULOS"), DECODE(a.antecedentes_circulo,"0","BUENOS","1","MALOS","X","NULOS"), 
				DECODE(a.comp_ingreso,"S","SI","N","NO"),a.lincred_solicitada,a.pago_minimo,a.compromisos_hip,a.compromisos_bco,a.ingreso_idp,
				a.antiguedad,a.puntualidad,a.eficienciapago,a.montovencido,a.abonomensual, a.fecha_insert,
				case when (b.f_primer_compra < b.f_primer_disp or (b.f_primer_disp is null and b.f_primer_compra is not null)) then
				     LPAD(DAY(b.f_primer_compra ),2,'0') || '/' || LPAD(MONTH(b.f_primer_compra ),2,'0') || '/' || YEAR(b.f_primer_compra )
				 else
				     LPAD(DAY(b.f_primer_disp),2,'0') || '/' || LPAD(MONTH(b.f_primer_disp ),2,'0') || '/' || YEAR(b.f_primer_disp)
				 end as fechaPrimerCompra				
			INTO vcNum_Sol_Increm, cSta_Sol_Increm, vcNum_Credito, vcNum_Cte, vcOrigen, cGradoRiesgo, dLineaCredAct, dLineaCredSug,
				dMontoIncrem, cFecha_Sol_Increm, vcNum_Cte_Cpl, cAntec_BC, cAntec_CC, cComprobIngreso, dLineaCredSol,mComprom_Pago_SIC,dImporte_hip,mCompromisosbanco,dIDP,
				sAntiguedad, cPuntualidad, dEficiencia_Pago, dMto_Vencido, dAbono_Mensual,dtFechaInc,cFechaPrimerCompra
			FROM "informix".sd_bitacora_aumlincred a
			LEFT JOIN "informix".sd_indicador_cred b on a.num_solicitud = b.num_credito
			WHERE a.empresa = pEmpresa
				AND a.num_solicitud = pNumeroCredito 
				--AND status IN('AC','AP')
				--AND fecha_status IN (SELECT MAX(fecha_status) FROM "informix".sd_bitacora_aumlincred WHERE num_solicitud = pNumeroCredito AND status = pStatus AND origen = pOrigen)
				AND a.status = pStatus
				AND a.origen = pOrigen
				AND a.fecha_status = pFecha_insert;
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000002';
				LET cMensajeRet = 'Estatus invalido para ser asignado, favor de verificar';
			ELSE
				-- OBTIENE EL POPRCENTAJE DE INCREMENTO
				LET dPorcIncrem = dMontoIncrem / dLineaCredAct;
				
				-- OBTIENE EL NOMBRE, RFC Y NUMERO DE CLIENTE COPPEL
				SELECT TRIM(c.apell_paterno) || ' ' || TRIM(c.apell_materno) || ' ' || TRIM(c.nombre1) || ' ' || TRIM(c.nombre2) , c.rfc, mc.fecha_apertura
				INTO vcNom_Cte, cRFC, dtFecha_Origen
				FROM "informix".sd_maecred mc, bdinteg:"informix".si_cliente c
				WHERE mc.empresa = pEmpresa
					AND mc.numcte = vcNum_Cte
					AND mc.num_credito = pNumeroCredito
					AND c.empresa = mc.empresa
					AND mc.numcte = c.numcte;
				-- OBTIENE LA FECHA DEL ULTIMO INCREMENTO REALIZADO Y OBTIENE EL COMPROMISO DE PAGO DE LAS SIC.
				--SELECT LPAD(DAY(fecha_status),2,'0') || '/' || LPAD(MONTH(fecha_status),2,'0') || '/' || YEAR(fecha_status) 
				SELECT MAX(LPAD(DAY(fecha_status),2,'0') || '/' || LPAD(MONTH(fecha_status),2,'0') || '/' || YEAR(fecha_status)) --PIQV
				INTO cFecha_Ult_Increm
				FROM "informix".sd_bitacora_aumlincred
				WHERE empresa = pEmpresa
					AND num_solicitud = pNumeroCredito
					AND status = 'AP'
					AND fecha_insert = fecha_insert;
				-- OBTIENE EL INGRESO MENSUAL.
				SELECT ingreso_mensual
				INTO mIngreso_Mensual
				FROM bdisolic:"informix".ss_resum_scor_fin
				WHERE empresa = pEmpresa
					AND num_solicitud = pNumeroCredito;		
				
				LET vcNum_Cte_Cpl = NVL(vcNum_Cte_Cpl,'');
				
					/*FOREACH WITH HOLD  
						-- OBTIENE LAS OBSERVACIONES PREVIAS DE LA HISTORICA.				
						SELECT justificacion
						INTO cJustificacion
						FROM "informix".sd_historica_cac_aumlincred
						WHERE empresa = pEmpresa
						  AND solicitud = pNumeroCredito
						  AND fecha_insert = dtFechaInc --PIQV
						ORDER BY puesto
											
						--SE ACUMULAN LAS OBSERVACIONES DEL CREDITO Y SE AGUARDAN EN UNA SOLA VARIABLE.
						IF TRIM(NVL(cJustificacion,'')) <> '' THEN 
							LET cObservPrev = TRIM(cObservPrev)||TRIM(NVL(cJustificacion,''))||"-";					 
						END IF;
					END FOREACH*/

    			  IF mCompromisosbanco IS NULL THEN
				  ---- SE OBTIENE EL POCENTAJE DE LOS COMPROMISOS DE TDC
					SELECT valor INTO mPorcentajecompromisosbancoTDC
					 FROM bdisolic:"informix".ss_param
					WHERE empresa= pEmpresa AND secuencia= 35;
			
				--******* COMPROMISOS BANCO INI			-- CREDITOS REVOLVENTES
					LET cNumcredito = "";
					LET mCompromisosbanco =0;
					FOREACH
						SELECT num_credito
						INTO cNumcredito
						FROM "informix".sd_maecred
						WHERE empresa = pEmpresa
							AND numcte = vcNum_Cte
							AND status_cred NOT IN ("FF","FM","FR","FE","CC","FC","CV")

						SELECT NVL(a.sdo_cap_insoluto,0)
						INTO mCompromisosbancoTDC
						FROM "informix".sd_maesdos a
						WHERE a.empresa     = pEmpresa
							AND a.num_credito = cNumcredito;
						  
					   IF mCompromisosbancoTDC IS NULL OR mCompromisosbancoTDC <= 0 THEN
						   LET mCompromisosbancoTDC = 0;
					   ELSE
						   IF Round(mCompromisosbancoTDC,-1) - mCompromisosbancoTDC < 0 THEN
								LET mCompromisosbancoTDC = Round(mCompromisosbancoTDC,-1) + 10;
						   ELSE
								LET mCompromisosbancoTDC = Round(mCompromisosbancoTDC,-1);
							END IF;
					   END IF;				   
					   
					   LET mCompromisosbanco = round((mCompromisosbanco + mCompromisosbancoTDC) * mPorcentajecompromisosbancoTDC ,-1);
					END FOREACH;				
				-- CREDITOS A PLAZO
					FOREACH
						SELECT num_credito
						INTO cNumcredito
						FROM "informix".sd_maecredcrd
						WHERE empresa = pEmpresa
							AND numcte = vcNum_Cte
							AND status_cred NOT IN ("FF","FM","FR","FE","CC","FC","CV")

						SELECT NVL(a.capital_mto_cuota,0)
						INTO mCompromisosbancoprestamo
						FROM "informix".sd_amortiza_creditocrd a
						WHERE a.empresa     = pEmpresa
							AND a.num_credito = cNumcredito
							AND a.num_pago = 1;

					   IF mCompromisosbancoprestamo IS NULL THEN
						   LET mCompromisosbancoprestamo = 0;
					   END IF;

					   LET mCompromisosbanco = mCompromisosbanco + mCompromisosbancoprestamo;
					   
					END FOREACH;
					IF mCompromisosbanco >= 0 THEN
						LET iBanderaActualizar =1;
					END IF;
				
							
				
				END IF;				--******* COMPROMISOS BANCO FIN
				
				-- JDLC: INGRESO VALIDO MC, OTROS COMPROMISOS, ESTATUS, MOTIVO DE CANCELACION, RECHAZO, PRIMER FECHA DE COMPRA				
					SELECT limit 1 a.ingreso_mc, a.otros_comp, a.estatus, a.causa					  					 
					INTO dIngresoMC, dOtrosComp, cEstatus, cCausa
						FROM "informix".sd_historica_cac_aumlincred a						
						WHERE a.empresa = pEmpresa AND solicitud = pNumeroCredito AND a.justificacion IS NOT NULL
						AND fecha_insert = dtFechaInc
						AND puesto = (SELECT MAX(puesto)					
									FROM "informix".sd_historica_cac_aumlincred
									WHERE empresa = pEmpresa
									AND solicitud = pNumeroCredito AND justificacion IS NOT NULL 
									AND fecha_insert = dtFechaInc);
								
				
				IF dImporte_hip IS NULL THEN
					---datos para obtener la informacion de los creditos hipotecarios
					SELECT fecha_hoy
					INTO dtFechaHoy
					FROM "informix".sd_fechas
					WHERE empresa = pEmpresa;					 

					SELECT TRIM(valor) INTO cCodUdi
					FROM bdinteg:"informix".si_param
					WHERE empresa = pEmpresa
						AND cod_param = 16;

					SELECT TRIM(valor) INTO cCodUs
					FROM bdinteg:"informix".si_param
					WHERE empresa = pEmpresa
					AND cod_param = 17;

					SELECT TRIM(valor) INTO cClase
					FROM "informix".sd_param
					WHERE empresa = pEmpresa
						AND cod_param = "336";

					EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, dtFechaHoy,cCodUdi,cClase,'0')
					INTO cCodRet,dTpCambioUdi;

					IF cCodRet <>'00000' THEN
					   RETURN cCodRet, cMensajeRet, NVL(vcNum_Sol_Increm,''), NVL(cSta_Sol_Increm,''), NVL(vcNum_Credito,''), NVL(vcNum_Cte,''), 
						NVL(vcNom_Cte,''), NVL(cRFC,''), NVL(dtFecha_Origen,'01/01/1900'), NVL(vcOrigen,''), NVL(cFecha_Sol_Increm,''), NVL(cFecha_Ult_Increm,''), 
						NVL(cGradoRiesgo,''), NVL(cAntec_BC,''), NVL(cAntec_CC,''), NVL(mComprom_Pago_SIC,0.0),NVL(dImporte_hip,0.0), NVL(vcNum_Cte_Cpl,''), NVL(sAntiguedad,0), 
						NVL(cPuntualidad,''), NVL(dEficiencia_Pago,0.0), NVL(dMto_Vencido,0.0),	NVL(dAbono_Mensual,0.0), NVL(mIngreso_Mensual,0.0), 
						NVL(dIngDemoPagos,0.0), NVL(cComprobIngreso,''), NVL(mCompromisosbanco,0.0) ,NVL(dLineaCredAct,0.0), NVL(dLineaCredSol,0.0), NVL(dLineaCredSug,0.0), 
						NVL(dMontoIncrem,0.0), NVL(dPorcIncrem,0.0), NVL(cObservPrev,''), NVL(dIngresoMC,0.0), NVL(dOtrosComp,0.0), NVL(cEstatus,''),NVL(cCausa,''), NVL(cFechaPrimerCompra,'');
					END IF;

					EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, dtFechaHoy,cCodUs,cClase,'1')
					INTO cCodRet,dTpCambioUs;

					IF cCodRet <>'00000' THEN
					   RETURN cCodRet, cMensajeRet, NVL(vcNum_Sol_Increm,''), NVL(cSta_Sol_Increm,''), NVL(vcNum_Credito,''), NVL(vcNum_Cte,''), 
						NVL(vcNom_Cte,''), NVL(cRFC,''), NVL(dtFecha_Origen,'01/01/1900'), NVL(vcOrigen,''), NVL(cFecha_Sol_Increm,''), NVL(cFecha_Ult_Increm,''), 
						NVL(cGradoRiesgo,''), NVL(cAntec_BC,''), NVL(cAntec_CC,''), NVL(mComprom_Pago_SIC,0.0),NVL(dImporte_hip,0.0), NVL(vcNum_Cte_Cpl,''), NVL(sAntiguedad,0), 
						NVL(cPuntualidad,''), NVL(dEficiencia_Pago,0.0), NVL(dMto_Vencido,0.0),	NVL(dAbono_Mensual,0.0), NVL(mIngreso_Mensual,0.0), 
						NVL(dIngDemoPagos,0.0), NVL(cComprobIngreso,''), NVL(mCompromisosbanco,0.0) ,NVL(dLineaCredAct,0.0), NVL(dLineaCredSol,0.0), NVL(dLineaCredSug,0.0), 
						NVL(dMontoIncrem,0.0), NVL(dPorcIncrem,0.0), NVL(cObservPrev,''), NVL(dIngresoMC,0.0), NVL(dOtrosComp,0.0), NVL(cEstatus,''),NVL(cCausa,''), NVL(cFechaPrimerCompra,'');
					END IF;
						
					---datos para obtener la informacion de los creditos hipotecarios
					SELECT NVL(SUM(CASE WHEN tl08 = 'N$' OR tl08 = 'MX'  THEN tl12 * b.factor  ELSE 0 END),0) +
					NVL(SUM(CASE WHEN tl08 = 'UD' THEN (tl12 * b.factor) * dTpCambioUdi ELSE 0 END),0) +
					NVL(SUM(CASE WHEN tl08 = 'US' THEN (tl12 * b.factor) * dTpCambioUs ELSE 0 END),0)
					INTO dImporte_hip
					FROM bdiburo:"informix".br_tl a, bdisolic:"informix".ss_circulo_frecpag b
					WHERE a.tl11 = b.tipo
						AND num_cliente = vcNum_Cte
						AND tl06 = 'M'
						AND tl07 = 'RE'
						AND tl12 <> 0
						AND tl02 <> 'SIC';	
					 IF dImporte_hip >= 0 THEN --JMAH Se corrigen compromisos hipotecarios
						IF NVL(mComprom_Pago_SIC,0) >= 0 THEN
							LET mComprom_Pago_SIC = mComprom_Pago_SIC -dImporte_hip;
							LET iBanderaActualizarSic =1;
						END IF;
						LET iBanderaActualizarhip =1;
					 END IF;
				END IF;
				----HISTORICO DE RESERVAS ini
				-- OBTIENE HISTORIAL DE PAGOS EN BANCOPPEL INCREMENTO -- OBTIENE INGRESO DEMOSTRADO EN PAGOS,
				IF dIDP IS NULL THEN 
					SELECT TRIM(valor)
					INTO iNumPagos
					FROM "informix".sd_param 
					WHERE cod_param = '002'
						AND empresa = pEmpresa;

					-- FACTOR A CONSIDERAD PARA EL CALCULO DEL IDP
					SELECT TRIM(valor)
					INTO iPorcIngreso
					FROM "informix".sd_param 
					WHERE cod_param = '004'
						AND empresa = pEmpresa;
											
					-- OBTIENE LOS PAGOS REALIZADOS EN LOS ULTIMOS 6 MESES.
					SELECT SUM(NVL(PagosRealizados,0))
					INTO dPagosRealizados
					FROM TABLE (MULTISET( 		
											SELECT FIRST 6 fecha_corte,NVL(pagos_realizados,0) AS PagosRealizados											
											FROM "informix".sd_hist_reserva
											WHERE empresa = pEmpresa
												AND num_credito = pNumeroCredito
											GROUP BY fecha_corte,pagos_realizados
											ORDER BY fecha_corte DESC 
										 ));
										 
					-- OBTIENE LA CAPACIDAD TOTAL DE PAGOS
					LET dCTP = dPagosRealizados / iNumPagos;
					-- OBTIENE EL INGRESO DEMOSTRADO EN PAGOS					
					LET dIDP = TRUNC(dCTP * iPorcIngreso,2);
					LET iBanderaActualizaridp =1;
				END IF;				
				----HISTORICO DE RESERVAS fin
				IF  iBanderaActualizar = 1 OR iBanderaActualizarhip =1 OR iBanderaActualizaridp =1 OR iBanderaActualizarSic = 1 THEN
					--se actualizan los compromisos en banco e hipotecarios del cliente.				
					UPDATE "informix".sd_bitacora_aumlincred
					SET compromisos_bco  = CASE WHEN iBanderaActualizar = 1 THEN mCompromisosbanco ELSE compromisos_bco END,
						compromisos_hip  = CASE WHEN iBanderaActualizarhip = 1 THEN dImporte_hip ELSE compromisos_hip END,
						ingreso_idp  = CASE WHEN iBanderaActualizaridp = 1 THEN dIDP ELSE ingreso_idp END,
						pago_minimo  = CASE WHEN iBanderaActualizarSic = 1 THEN mComprom_Pago_SIC ELSE pago_minimo END
					WHERE empresa = pEmpresa
						AND num_solicitud = pNumeroCredito
						AND status = "AC"
						--AND fecha_status IN (SELECT MAX(fecha_status) FROM "informix".sd_bitacora_aumlincred WHERE num_solicitud = pNumeroCredito AND status = pStatus )
						AND fecha_insert = dtFechaInc;							
				END IF;													
			END IF;
		END IF			
		RETURN cCodRet, cMensajeRet, NVL(vcNum_Sol_Increm,''), NVL(cSta_Sol_Increm,''), NVL(vcNum_Credito,''), NVL(vcNum_Cte,''), 
				NVL(vcNom_Cte,''), NVL(cRFC,''), NVL(dtFecha_Origen,'01/01/1900'), NVL(vcOrigen,''), NVL(cFecha_Sol_Increm,''), NVL(cFecha_Ult_Increm,''), 
				NVL(cGradoRiesgo,''), NVL(cAntec_BC,''), NVL(cAntec_CC,''), NVL(mComprom_Pago_SIC,0.0),NVL(dImporte_hip,0.0), NVL(vcNum_Cte_Cpl,''), NVL(sAntiguedad,0), 
				NVL(cPuntualidad,''), NVL(dEficiencia_Pago,0.0), NVL(dMto_Vencido,0.0),	NVL(dAbono_Mensual,0.0), NVL(mIngreso_Mensual,0.0), 
				NVL(dIDP,0.0), NVL(cComprobIngreso,''), NVL(mCompromisosbanco,0.0) ,NVL(dLineaCredAct,0.0), NVL(dLineaCredSol,0.0), NVL(dLineaCredSug,0.0), 
				NVL(dMontoIncrem,0.0), NVL(dPorcIncrem,0.0), NVL(cObservPrev,''), NVL(dIngresoMC,0.0), NVL(dOtrosComp,0.0), NVL(cEstatus,''),NVL(cCausa,''), NVL(cFechaPrimerCompra,'');
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener información de solicitudes para el incremento de linea de crédito consultado según los criterios especificados por el analista de crédito', 
'AUTOR: Mohamed Carreón ',
'FECHA: Septiembre 2011',
'MODIFICACIÓN: Se modifica para contemplar las reglas de informix y cambiar mensaje "NO HAY REGISTROS PARA EL CREDITO EN LA BITACORA DE AUMENTO DE LINEA DE CREDITO" por',
'			   "Estatus invalido para ser asignado, favor de verificar" cuando el "cCodRet = 000002". Se agrega parametro "pStatus"',
'MODIFICÓ: Guadalupe Payan',
'FECHA MODIFICACIÓN: 26/07/2012',
'VERSION: 20120726.1438',
'MODIFICACIÓN: Se modifica para obtener los datos de la tabla "sd_bitacora_aumlincred" en lugar de la tabla "ss_resum_scor_fin" ya que en la primer tabla se encuentran los datos',
'			   mas actuales y Se contemplan reglas de informix.',
'MODIFICÓ: Guadalupe Payan',
'FECHA MODIFICACIÓN: 28/09/2012',
'VERSION: 20120928.1126',
'MODIFICACIÓN: Se modifica para hacer mas grande el tamaño de la variable cObservPrev de varchar(200) a char(800) y ahora se obtiene la justificacion de la tabla sd_historica_cac_aumlincred y',
'			   ya no de la tabla sd_autorizacion_aumlincred.',
'MODIFICÓ: Guadalupe Payan',
'FECHA MODIFICACIÓN: 08/10/2012',
'VERSION: 20121008.1034',
'MODIFICACIÓN: Se modifica para que a la fecha de hoy (fecha_hoy) ya no se le quiten los seis meses ya que esta tomando meses incompletos,',
'			   ahora se tomara el primer dia del mes (pri_dia_mes) y se le restara un dia menos seis mes para que este sea el inicio del rango,',
'			   y se obtendra el dia ultimo del mes anterior y se guardara en la nueva variable "dtFechaNumPagos2" para que esta sea el tope del rango de fechas.',
'MODIFICÓ: Guadalupe Payan',
'FECHA MODIFICACIÓN: 29/04/2013',
'VERSION: 20130429.1657',
'BD    : BDICRED',
'MODIFICACIÓN: Se agrega pFecha_insert como parametro con tipo de dato DATE, en la consulta principal se agrega el parametro como filtrado,',
'			   se valida el parametro pOrigen si es "S" se genera la consulta de la tabla sd_historica_cac_aumlincred y llena en la variable cObservPrev,',
'              de lo contrario si pOrigen es "C" la variable cObservPrev quedara vacia.',
'              Se quita filtro de fecha insert de la tabla "sd_historica_cac_aumlincred" para obtener la justificacion correcta.',
'MODIFICÓ: Mario Olivo',
'FECHA MODIFICACIÓN: 14/05/2013',
'VERSION: 20130514.1145',
'BD    : BDICRED',
'MODIFICACIÓN: Se modifica para cambiar la logica de obtener los seis meses de los pagos realizados de la tabla "sd_hist_reserva", ahora se obtendran con un', 
' 			   FIRST 6 que obtendra la sumatoria de pagos realizados de las ultimas 6 fechas de corte.',
'MODIFICÓ: Guadalupe Payan',
'FECHA MODIFICACIÓN: 22/05/2013',
'VERSION: 20130522.1009',
'BD    : BDICRED',
'MODIFICACIÓN: Se agregan los campos ingreso_mc, otros_comp, estatus y causa para que los regrese en la consulta. Se agrega la VALIDACION DE CONSULTA DE COMPROMISOS BANCO', 
'MODIFICÓ: Daniel Lazalde : JDLC ',
'FECHA MODIFICACIÓN: 27/01/2014',
'VERSION: 20130522.1009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_excepciones(pFechaIni CHAR (10), pFechaFin CHAR(10), pExcepcion CHAR(3))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS tiene_causa,
			  CHAR(100) 	AS descripcion,
			  INTEGER 		AS total_excepcion,
			  DECIMAL(18,2) AS porcentaje,
			  INTEGER 		AS total_general,
			  DECIMAL(18,2) AS total_porcentaje;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcExcepcion			DECIMAL(18,2);
	DEFINE dPorcExcepcionAcum		DECIMAL(18,2);
	DEFINE cExcepcion				CHAR(3);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE iTotalExcepcion 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcExcepcionTotal     DECIMAL(18,2);

	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = "";
	LET cCodRet                  = "000000";
	LET cMensajeRet              = "SE REALIZO LA CONSULTA CORRECTAMENTE";
	LET dPorcExcepcion			     = 0;
	LET dPorcExcepcionAcum		     = 0;
	LET iTotalExcepcion			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = "";
	LET cBandera				 = "";
	LET cExcepcion				 = "";
	LET cCausa 					 = "";
	LET dPorcExcepcionTotal         = 0;

	BEGIN

	--SET DEBUG FILE TO "/home/sp_cac_rep_excepciones.out";
	--TRACE ON;
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet=cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = "000002";
					LET cMensajeRet = "PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA";
				END IF;	 
				IF  cBandera = "S" THEN
					DROP TABLE tme_consultaincrementos;
				END IF;
				RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0), NVL(vcDescripcion,' '), NVL(iTotalExcepcion, 0), NVL(dPorcExcepcion, 0), NVL(iTotal, 0), NVL(dPorcExcepcionTotal, 0);
		   END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--se validan los parametros de entrada.
		IF NVL(pFechaIni,"") = ""  OR NVL(pFechaFin,"") = "" THEN
			LET cCodRet = "000001";
			LET cMensajeRet = "FALTA PARAMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA";
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalExcepcion, 0), NVL(dPorcExcepcion, 0),NVL(iTotal, 0), NVL(dPorcExcepcionTotal, 0);
		END IF;
		
		IF pExcepcion IS NULL THEN 
		 LET pExcepcion = "";
		END IF;
		
		-- Crear una tabla temporal para insertar los datos de la consulta	
		IF EXISTS (SELECT tabname FROM systables  WHERE tabname = 'tme_consultaincrementos') THEN	
			DROP TABLE tme_consultaincrementos;
		END IF;

		-- Se crea la tabla de trabajo
		CREATE TEMP TABLE tme_consultaincrementos
		(
			excepcion CHAR(3),
			causa	CHAR(3),
			descripcion  CHAR(100),
			totalRegistros INTEGER,
			porcentaje   decimal(18,2)		
		)WITH NO LOG;	
			
		LET cBandera = "S";

		----se insertan el total de registros por excepcion
		FOREACH WITH HOLD
			SELECT clave_excepcion,TRIM(descripcion)
				INTO cExcepcion,vcDescripcion
			FROM "informix".sd_excepciones_aumlincred 
			WHERE clave_excepcion = (CASE WHEN pExcepcion = "" THEN clave_excepcion ELSE pExcepcion END)
				
			FOREACH WITH HOLD
				SELECT COUNT(excepciones)
				INTO iTotalExcepcion
				FROM  "informix".sd_sol_excepciones_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND empresa = '001'
					AND excepciones = cExcepcion			
				
				INSERT INTO tme_consultaincrementos(excepcion,causa,descripcion,totalRegistros,porcentaje)
				VALUES(cExcepcion,'',vcDescripcion,NVL(iTotalExcepcion,0),0);	 
				
			END FOREACH;  	
		END FOREACH;
		
		--se obtiene el total de los registros para esta consulta	
		SELECT NVL(SUM(totalregistros),0), COUNT(excepcion)
		INTO iTotal,iTotalReg
		FROM  tme_consultaincrementos 
		WHERE excepcion = excepcion
			AND causa = ""
			AND totalRegistros <> 0;
		
		LET iTotalRegistros = iTotal;
					
		IF iTotalReg <> 0 THEN
			--se realiza el calculo del porcentaje por cada  Excepcion del total de registros de la consulta	
			FOREACH
				SELECT excepcion,descripcion,totalRegistros
				INTO cExcepcion, vcDescripcion,iTotalExcepcion
				FROM  tme_consultaincrementos
				WHERE excepcion = excepcion
					AND causa = ""
					AND totalRegistros <> 0	
				
				LET dPorcExcepcion= ((iTotalExcepcion * 100)/iTotalRegistros);
				IF (dPorcExcepcionAcum + dPorcExcepcion) < 100 THEN
					LET iCont = iCont + 1;
					IF iTotalReg = iCont THEN
						LET dPorcExcepcion= 100 - dPorcExcepcionAcum;
					END IF;
					LET dPorcExcepcionAcum = dPorcExcepcionAcum + dPorcExcepcion;
				ELSE
					LET iCont = iCont + 1;
					LET dPorcExcepcion= 100 - dPorcExcepcionAcum;
					LET dPorcExcepcionAcum = dPorcExcepcionAcum + dPorcExcepcion;
				END IF;
						
				UPDATE tme_consultaincrementos
				SET porcentaje = dPorcExcepcion
				WHERE excepcion = cExcepcion;
			END FOREACH;
		END IF;
		
		--Se obtienen totales de ambos casos y se guardan en la tabla
		
			SELECT SUM(totalRegistros),SUM(porcentaje)
				INTO iTotalRegistros, dPorcExcepcionTotal
			FROM  tme_consultaincrementos
			WHERE causa="";	
		
		--se obtiene los datos de la tabla
		FOREACH
			SELECT excepcion,causa,descripcion,totalRegistros,porcentaje
			INTO cExcepcion,cCausa,vcDescripcion,iTotalExcepcion,dPorcExcepcion
			FROM tme_consultaincrementos
			--ORDER BY excepcion,causa
			
			IF NVL(cCausa,"") <> "" THEN
				LET iTieneCausa = 1;
				LET  vcDescripcion = TRIM (cCausa) || '-' || TRIM (vcDescripcion);
			ELSE
				LET iTieneCausa = 0;				
			END IF;
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0), NVL(vcDescripcion,''),NVL(iTotalExcepcion, 0), NVL(dPorcExcepcion, 0),NVL(iTotalRegistros, 0), NVL(dPorcExcepcionTotal, 0) WITH RESUME;			 
		END FOREACH;	
		
		IF  cBandera = "S" THEN
			DROP TABLE tme_consultaincrementos;
		END IF;
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada excepción de acuerdo al mes consultado',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 04/02/2013',
'BD: BDICRED',
'Version: 20130204.1714';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aplicados
	(
	pFechaInicial 	CHAR(10),
	pFechaFinal 	CHAR(10),
	pStatus 		CHAR(2),
	pOrigen             CHAR(1),
	pOpcFecha           CHAR(1) -- 1--> FechaOrigen 2--> FechaAtencion
	)
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,     
			  DATE  		AS fecha_atencion,
			  VARCHAR(20) 	AS Numero_solicitud,
			  CHAR(8) 		AS  Origen,
			  VARCHAR(20) 	AS Numero_Cliente,
			  VARCHAR(26) 	AS Apell_Paterno,
			  VARCHAR(26) 	AS Apell_Materno,
			  VARCHAR(53) 	AS Nombre,
			  DECIMAL(18,2) AS Lincred_actual,
			  DECIMAL(18,2) AS Lincred_sugerida,
			  DECIMAL(18,2) AS Incremento,
			  CHAR(2) 		AS Status,
			  VARCHAR(45) 	AS AnalistaCac,
			  VARCHAR(45) 	AS Analista2nivel,
			  VARCHAR(45) 	AS Analista3nivel,
			  VARCHAR(45) 	AS Analista4nivel,
			  VARCHAR(106) 	AS motivo,
			  DATE              AS FechaStatus,
			  INTEGER           AS TotalNumReg,
			  VARCHAR(45)       AS NomEjecutivoMaxPuesto;
			  
			  
	---DECLARACIONES         
	DEFINE cCodRet               	CHAR(6); 
	DEFINE cMensajeRet           	CHAR(80);
	DEFINE cComentario           	CHAR(80);
	DEFINE iSqlErr      	     	INTEGER;
	DEFINE iIsamErr              	INTEGER;
	DEFINE iCon            		 	INTEGER;
	DEFINE cErrorInfo            	CHAR(80);

	DEFINE  dtFechaAtencion 			DATE;
	DEFINE vcNumSol 				VARCHAR(20);	
	DEFINE cOrigen  				CHAR(8);
	DEFINE vcNumCte 				VARCHAR(20);
	DEFINE vcApellPaterno			VARCHAR(26);
	DEFINE vcApellMaterno 			VARCHAR(26);
	DEFINE vcNombre 				VARCHAR(53);
	DEFINE dLinCredAct 		    	DECIMAL(18,2);
	DEFINE dLinCredCal 	     		DECIMAL(18,2);
	DEFINE dIncremento				DECIMAL(18,2);
	DEFINE dMontoIncremento			DECIMAL(18,2);
	DEFINE cStatus 					CHAR(2);
	DEFINE vcAnalistaCac			VARCHAR(45);
	DEFINE vcAnalista2nivel 		VARCHAR(45);
	DEFINE vcAnalista3nivel 		VARCHAR(45);
	DEFINE vcAnalista4nivel 		VARCHAR(45);

	DEFINE vcMotivo 				VARCHAR(106);
	DEFINE cCausa 					CHAR(3);
	DEFINE cPuesto 					CHAR(3);
	DEFINE cNomEjecutivo 			CHAR(45);
	DEFINE dtFecha 				DATE;
	DEFINE dtFecha_status 			DATE;
	DEFINE iContador			INTEGER;
	DEFINE cNomEjecutivoMaxPuesto		CHAR(45);
	DEFINE cEjecutivo		CHAR(10);
	

	---INICIALIZACIONES
	LET iSqlErr                  	= 0;
	LET iIsamErr                 	= 0;
	LET iCon                 	 	= 0;
	LET cErrorInfo               	= '';
	LET cCodRet                  	= '000000';
	LET cMensajeRet              	= 'SE REALIZÓ LA CONSULTA CORRECTAMENTE';

	LET  dtFechaAtencion 		 		=DATE(1);
	LET vcNumSol 			 		= '';	
	LET cOrigen  		     		= '';
	LET vcNumCte 			 		= '';
	LET vcApellPaterno		 		= '';
	LET vcApellMaterno 		 		= '';
	LET vcNombre 			 		= '';
	LET dLinCredAct 		 		= 0;
	LET dLinCredCal 	     		= 0;
	LET dIncremento			 		= 0;
	LET dMontoIncremento	 		= 0;
	LET cStatus 			 		= '';
	LET vcAnalistaCac		 		= '';
	LET vcAnalista2nivel 	 		= '';
	LET vcAnalista3nivel 	 		= '';
	LET vcAnalista4nivel      		= '';
	LET vcMotivo 			 		= '';
	LET cCausa 			 		    = '';
	LET cPuesto 			 		= '';
	LET cNomEjecutivo	 		    = '';
	LET dtFecha_status 				= DATE(1);
	LET iContador					= 0;
	LET cNomEjecutivoMaxPuesto		= '';
	LET cEjecutivo					= '';

	BEGIN
		--SET DEBUG FILE TO 'sp_consulta_gral_aumlincred_aplicados.out';
		--TRACE ON;
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	
				RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				       NVL(vcNombre,''),0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''),'', NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');	
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		IF pStatus IS NULL THEN 
		 LET pStatus = "";
		END IF;
		
		-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
		IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
			RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''),'', NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');
		ELSE
		
			IF pFechaInicial > pFechaFinal THEN
				LET cCodRet = '000002';
				LET cMensajeRet = 'LA FECHA INICIAL ES MAYOR A LA FECHA FINAL';
				RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
					   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''),'', NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');
			ELSE		
			
				IF pOpcFecha = '1' THEN --Busqueda por fechaOrigen: fecha_insert					
					FOREACH WITH HOLD							
						SELECT a.fecha_insert, a.num_solicitud,a.origen ,a.numcte,						
							a.lincred_actual,a.lincred_sugerida,a.status,a.causa_status,
							a.fecha_status,a.ejecutivo
						INTO  dtFechaAtencion,vcNumSol,cOrigen,vcNumCte, 
						dLinCredAct, dLinCredCal,cStatus, cCausa, dtFecha_status,cEjecutivo
						FROM  "informix".sd_bitacora_aumlincred a
						WHERE a.empresa ='001'
						AND a.fecha_insert  >= pFechaInicial
						AND a.fecha_insert <= pFechaFinal
						AND a.status = "AP"	
						ORDER BY fecha_insert
					
						
						LET dMontoIncremento = dLinCredCal - dLinCredAct;
						IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
							LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
						ELSE
							LET dIncremento = 0;
						END IF;
						
						SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))					
						INTO vcNombre, vcApellPaterno,vcApellMaterno
						FROM bdinteg:'informix'.si_cliente
						WHERE numcte = vcNumCte;
						
					
					IF NVL(cCausa,"") <> "" THEN
					
					--se obtiene la descripcion del motivo de rechazo o cancelacion
						SELECT causa_status||' - '||TRIM(descripcion)
						INTO vcMotivo
						FROM 'informix'.sd_causas_aumlincred
						WHERE status = cStatus
						AND causa_status = cCausa;
					END IF;
						
					IF NVL(cOrigen,"") = "S" THEN	
						
						--Obtener el nombre del ejecutivo del maximo puesto						
						SELECT c.nombre 
						INTO cNomEjecutivoMaxPuesto
						FROM "informix".sd_historica_cac_aumlincred h
						INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
						WHERE h.solicitud = vcNumSol
						AND h.fecha_insert = dtFechaAtencion
						AND h.puesto = (
									SELECT max(puesto)
									FROM "informix".sd_historica_cac_aumlincred
									WHERE solicitud = vcNumSol
									AND fecha_insert =  dtFechaAtencion
								);
						
						IF  NVL(cNomEjecutivoMaxPuesto,"") = "" THEN 
							SELECT LIMIT 1 c.nombre 
							INTO cNomEjecutivoMaxPuesto
							FROM "informix".sd_perfiles_cac_aumlincred h
							INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
							WHERE h.ejecutivo = cEjecutivo;
							
							IF  NVL(cNomEjecutivoMaxPuesto,"") = "" THEN 
								LET cNomEjecutivoMaxPuesto ="SUCURSAL";
							END IF;
							
						END IF;							
						--LET cOrigen = DECODE(cOrigen,"CENTRAL","C","SUCURSAL","S");
					ELSE
						LET cNomEjecutivoMaxPuesto ="CENTRAL";
					END IF;
					LET cOrigen = DECODE(cOrigen,"C","CENTRAL","S","SUCURSAL");				
						LET iContador = iContador + 1;
						RETURN cCodRet, cMensajeRet, dtFechaAtencion,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
						NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'') WITH RESUME;	
					END FOREACH; 
				ELSE
						--Busqueda por fechaAtencion: fecha_status
						FOREACH WITH HOLD							
							SELECT a.fecha_insert, a.num_solicitud,a.origen ,a.numcte,						
								a.lincred_actual,a.lincred_sugerida,a.status,a.causa_status,
								a.fecha_status,a.ejecutivo
							INTO  dtFechaAtencion,vcNumSol,cOrigen,vcNumCte, 
							dLinCredAct, dLinCredCal,cStatus, cCausa, dtFecha_status,cEjecutivo
							FROM  "informix".sd_bitacora_aumlincred a
							WHERE a.empresa ='001'
							AND a.fecha_insert = a.fecha_insert
							AND a.fecha_status  >= pFechaInicial
							AND a.fecha_status <= pFechaFinal
							AND a.status        = "AP"								
							ORDER BY fecha_status
						
							
							LET dMontoIncremento = dLinCredCal - dLinCredAct;
							IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
								LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
							ELSE
								LET dIncremento = 0;
							END IF;
							
							SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))					
							INTO vcNombre, vcApellPaterno,vcApellMaterno
							FROM bdinteg:'informix'.si_cliente
							WHERE numcte = vcNumCte;
							
							
						IF NVL(cCausa,"") <> "" THEN
						
						--se obtiene la descripcion del motivo de rechazo o cancelacion
							SELECT causa_status||' - '||TRIM(descripcion)
							INTO vcMotivo
							FROM 'informix'.sd_causas_aumlincred
							WHERE status = cStatus
							AND causa_status = cCausa;
						END IF;
							
							
							
					IF NVL(cOrigen,"") = "S" THEN	
						
						--Obtener el nombre del ejecutivo del maximo puesto						
						SELECT c.nombre 
						INTO cNomEjecutivoMaxPuesto
						FROM "informix".sd_historica_cac_aumlincred h
						INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
						WHERE h.solicitud = vcNumSol
						AND h.fecha_insert = dtFechaAtencion
						AND h.puesto = (
									SELECT max(puesto)
									FROM "informix".sd_historica_cac_aumlincred
									WHERE solicitud = vcNumSol
									AND fecha_insert =  dtFechaAtencion
								);
						
						IF  NVL(cNomEjecutivoMaxPuesto,"") = "" THEN 
							SELECT LIMIT 1 c.nombre 
							INTO cNomEjecutivoMaxPuesto
							FROM "informix".sd_perfiles_cac_aumlincred h
							INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
							WHERE h.ejecutivo = cEjecutivo;
							
							IF  NVL(cNomEjecutivoMaxPuesto,"") = "" THEN 
								LET cNomEjecutivoMaxPuesto ="SUCURSAL";
							END IF;
							
						END IF;							
						--LET cOrigen = DECODE(cOrigen,"CENTRAL","C","SUCURSAL","S");
					ELSE
						LET cNomEjecutivoMaxPuesto ="CENTRAL";
					END IF;
						LET cOrigen = DECODE(cOrigen,"C","CENTRAL","S","SUCURSAL");		
						
							LET iContador = iContador + 1;
							RETURN cCodRet, cMensajeRet, dtFechaAtencion,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
							NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'') WITH RESUME;	
						END FOREACH; 
				
				
				END IF; 
						
				IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
					LET cCodRet= '000003';
					LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
					RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
					       NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');
				END IF;	   		
			END IF
		END IF
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha (Fecha Origen o Fecha Atención)',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 06/02/2014',
'MODIFICO : Daniel Lazalde',
'BD: BDICRED',
'VERSION: 20140206.0001';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aut	(pFechaInicial 	CHAR(10),pFechaFinal 	CHAR(10),	pStatus CHAR(2)	)
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,     
			  DATE  		AS fecha_origen,
			  VARCHAR(20) 	AS Numero_solicitud,
			  CHAR(1) 		AS  Origen,
			  VARCHAR(20) 	AS Numero_Cliente,
			  VARCHAR(26) 	AS Apell_Paterno,
			  VARCHAR(26) 	AS Apell_Materno,
			  VARCHAR(53) 	AS Nombre,
			  DECIMAL(18,2) AS Lincred_actual,
			  DECIMAL(18,2) AS Lincred_sugerida,
			  DECIMAL(18,2) AS Incremento,
			  CHAR(2) 		AS Status,
			  VARCHAR(45) 	AS AnalistaCac,
			  VARCHAR(45) 	AS Analista2nivel,
			  VARCHAR(45) 	AS Analista3nivel,
			  VARCHAR(45) 	AS Analista4nivel,
			  VARCHAR(106) 	AS motivo,
			  DATE              AS fecha_ingresoAC,
			  DATETIME HOUR TO FRACTION(3) AS hora_ingresoAC,
			  DATE              AS fecha_atencion,
			  DATETIME HOUR TO FRACTION(3) AS hora_atencion;
			  
			  
	---DECLARACIONES         
	DEFINE cCodRet               	CHAR(6); 
	DEFINE cMensajeRet           	CHAR(80);
	DEFINE cComentario           	CHAR(80);
	DEFINE iSqlErr      	     	INTEGER;
	DEFINE iIsamErr              	INTEGER;
	DEFINE iCon            		 	INTEGER;
	DEFINE cErrorInfo            	CHAR(80);

	DEFINE dtFechaOrigen 			DATE;
	DEFINE vcNumSol 				VARCHAR(20);	
	DEFINE cOrigen  				CHAR(1);
	DEFINE vcNumCte 				VARCHAR(20);
	DEFINE vcApellPaterno			VARCHAR(26);
	DEFINE vcApellMaterno 			VARCHAR(26);
	DEFINE vcNombre 				VARCHAR(53);
	DEFINE dLinCredAct 		    	DECIMAL(18,2);
	DEFINE dLinCredCal 	     		DECIMAL(18,2);
	DEFINE dIncremento				DECIMAL(18,2);
	DEFINE dMontoIncremento			DECIMAL(18,2);
	DEFINE cStatus 					CHAR(2);
	DEFINE vcAnalistaCac			VARCHAR(45);
	DEFINE vcAnalista2nivel 		VARCHAR(45);
	DEFINE vcAnalista3nivel 		VARCHAR(45);
	DEFINE vcAnalista4nivel 		VARCHAR(45);

	DEFINE vcMotivo 				VARCHAR(106);
	DEFINE cCausa 					CHAR(3);
	DEFINE cPuesto 					CHAR(3);
	DEFINE cNomEjecutivo 			CHAR(45);
	DEFINE dtFecha 					DATE;
	DEFINE dtFechaIngresoAC     DATE;
	DEFINE dtFechaIngreso     DATE;
	DEFINE dtHoraIngresoAC      DATETIME HOUR TO FRACTION;
	DEFINE dtHoraIngreso      DATETIME HOUR TO FRACTION;
	DEFINE dtFechaAtencion     DATE;
	DEFINE dtHoraAtencion      DATETIME HOUR TO FRACTION;
	
	---INICIALIZACIONES
	LET iSqlErr                  	= 0;
	LET iIsamErr                 	= 0;
	LET iCon                 	 	= 0;
	LET cErrorInfo               	= '';
	LET cCodRet                  	= '000000';
	LET cMensajeRet              	= 'SE REALIZÓ LA CONSULTA CORRECTAMENTE';

	LET dtFechaOrigen 		 		=DATE(1);
	LET vcNumSol 			 		= '';	
	LET cOrigen  		     		= '';
	LET vcNumCte 			 		= '';
	LET vcApellPaterno		 		= '';
	LET vcApellMaterno 		 		= '';
	LET vcNombre 			 		= '';
	LET dLinCredAct 		 		= 0;
	LET dLinCredCal 	     		= 0;
	LET dIncremento			 		= 0;
	LET dMontoIncremento	 		= 0;
	LET cStatus 			 		= '';
	LET vcAnalistaCac		 		= '';
	LET vcAnalista2nivel 	 		= '';
	LET vcAnalista3nivel 	 		= '';
	LET vcAnalista4nivel      		= '';
	LET vcMotivo 			 		= '';
	LET cCausa 			 		    = '';
	LET cPuesto 			 		= '';
	LET cNomEjecutivo	 		    = '';
	LET dtFechaIngresoAC     = DATE(1);
	LET dtHoraIngresoAC      = CURRENT;
	LET dtFechaAtencion     = DATE(1);
	LET dtHoraAtencion      = CURRENT;
	

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	
				RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				       NVL(vcNombre,''),0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT);	
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO 'sp_consulta_gral_aumlincred_aut.out';
		--TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
		IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
			RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT);
		ELSE
			IF pFechaInicial > pFechaFinal THEN
				LET cCodRet = '000002';
				LET cMensajeRet = 'LA FECHA INICIAL ES MAYOR A LA FECHA FINAL';
				RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
					   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT);
			ELSE		
				FOREACH WITH HOLD							
					SELECT fecha_insert, num_solicitud,origen ,numcte,						
						lincred_actual,lincred_sugerida,status,causa_status						
					INTO dtFechaOrigen,vcNumSol,cOrigen,vcNumCte, 
					dLinCredAct, dLinCredCal,cStatus, cCausa 					
					FROM  bdicred:"informix".sd_bitacora_aumlincred
					WHERE empresa ='001'
					AND fecha_insert  >= pFechaInicial
					AND fecha_insert <= pFechaFinal
					AND status=pStatus							
					ORDER BY fecha_insert
				
					
					LET dMontoIncremento = dLinCredCal - dLinCredAct;
					IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
						LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
					ELSE
						LET dIncremento = 0;
					END IF;
					
					SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))					
					INTO vcNombre, vcApellPaterno,vcApellMaterno
					FROM bdinteg:'informix'.si_cliente
					WHERE numcte = vcNumCte;
					
					LET vcAnalistaCac		 		= '';
					LET vcAnalista2nivel 	 		= '';
					LET vcAnalista3nivel 	 		= '';
					LET vcAnalista4nivel      		= '';
					
					IF NVL(cOrigen,"") = "S" THEN
						FOREACH WITH HOLD
							SELECT b.nombre,a.puesto,a.fecha_atencion, EXTEND(a.hora_atencion, HOUR TO SECOND)  
							INTO cNomEjecutivo,cPuesto,dtFechaIngreso, dtHoraIngreso
							FROM bdicred:"informix".sd_historica_cac_aumlincred a
							INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo = a.ejecutivo)
							WHERE a.solicitud = vcNumSol
							AND a.fecha_insert = dtFechaOrigen
							ORDER BY a.puesto							

							IF cPuesto = '01' 	THEN  
								LET vcAnalistaCac = cNomEjecutivo;
								LET dtFechaIngresoAC =dtFechaIngreso;
								LET dtHoraIngresoAC = dtHoraIngreso;
							ELIF cPuesto in ('02','03') THEN 
								LET vcAnalista2nivel = cNomEjecutivo;
								LET dtFechaAtencion =dtFechaIngreso;
								LET dtHoraAtencion = dtHoraIngreso;
							ELIF cPuesto in ('04') THEN 
								LET vcAnalista3nivel = cNomEjecutivo;
								LET dtFechaAtencion =dtFechaIngreso;
								LET dtHoraAtencion = dtHoraIngreso;
							ELIF cPuesto in ('05','06','07','08') THEN
								LET vcAnalista4nivel = cNomEjecutivo;
								LET dtFechaAtencion =dtFechaIngreso;
								LET dtHoraAtencion = dtHoraIngreso;
							END IF

						END FOREACH
						IF cPuesto = '01' 	THEN
							LET dtFechaAtencion =dtFechaIngresoAC;
							LET dtHoraAtencion = dtHoraIngresoAC;
						END IF;
					END IF;
					
					
					IF NVL(cCausa,"") <> "" THEN
					
					--se obtiene la descripcion del motivo de rechazo o cancelacion
						SELECT causa_status||' - '||TRIM(descripcion)
						INTO vcMotivo
						FROM bdicred:'informix'.sd_causas_aumlincred
						WHERE status = cStatus
						AND causa_status = cCausa;
					END IF;	
				
				
					RETURN cCodRet, cMensajeRet,dtFechaOrigen,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
					NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT) WITH RESUME;	
					
				END FOREACH;  
				
				IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
					LET cCodRet= '000003';
					LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
					RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
					       NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT);
				END IF;	   		
			END IF
		END IF
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 09/03/2011',
'MODIFICO : Mohamed Carreón',
'DESCIPCION CAMBIO : Se agregó la fecha final y la fecha inicial',
'FECHA : 12/06/2011',
'MODIFICACIÓN: Se modifica para contemplar las reglas de informix, se elimina la variable "cNum_credito" ya que no es utilizada en el codigo.',
'FECHA MODIFICACIÓN: 25/07/2012',
'MODIFICÓ: Guadalupe Payan',
'BD: BDICRED',
'VERSION: 20120725.1150',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agregan los campos Fecha Ingreso AC, Hora Ingreso AC, Fecha Atención, Hora Atención en el retorno del sp',
'Fecha de modificación: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consultar_excepciones_aumlincred()
RETURNING 
CHAR(6)		AS codigo_retorno,
CHAR(80)	AS mensaje_retorno,	
CHAR(4)		AS clave_excepcion,
CHAR(80)	AS desc_status; 

---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cDescripcion		CHAR(80);
DEFINE cCveExcepcion	CHAR(4);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = '';
LET cCodRet             = '000000';
LET cMensajeRet         = 'SE REALIZÓ LA CONSULTA CORRECTAMENTE';
LET cCveExcepcion		= '';
LET cDescripcion		= '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet,cCveExcepcion,cDescripcion;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_consultar_excepciones_aumlincred.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	FOREACH WITH HOLD
		SELECT clave_excepcion,TRIM(descripcion)
		INTO cCveExcepcion,cDescripcion
		FROM 'informix'.sd_excepciones_aumlincred
		ORDER BY clave_excepcion	
					
		RETURN cCodRet,cMensajeRet,cCveExcepcion,cDescripcion WITH RESUME;
	END FOREACH;		

    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = '000001';
        LET cMensajeRet = 'NO HAY INFORMACIÓN DEL CATÁLOGO DE EXCEPCIONES DE AUMENTO DE LÍNEA DE CRÉDITO';
		RETURN cCodRet,cMensajeRet,cCveExcepcion,cDescripcion;
    END IF
	
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la obtencion de las excepciones de incrementos de linea de crédito',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 04/02/2013',
'BD    : BDICRED',
'Version: 20130204.0001',
'MODIFICADO POR :  ';

CREATE PROCEDURE "informix".detalle_edocta(
								 pEmpresa CHAR(3),
			           pNumCredito CHAR(20),
			           pFechaEmision DATE,
			           pNumRegistros SMALLINT)
RETURNING CHAR(5),
    			DATE ,    			CHAR(20),    			SMALLINT,
					SMALLINT,				CHAR(9),					CHAR(255),
					CHAR(16),				CHAR(16);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err   SMALLINT;
DEFINE sCodRet   CHAR(5);

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 			CHAR(20);

DEFINE v_secuencia 		SMALLINT;
DEFINE v_nlinea 			SMALLINT;
DEFINE v_fecha_mov 		CHAR(9);
DEFINE v_concepto 		CHAR(255);
DEFINE v_cargos 			CHAR(16);
DEFINE v_abonos 			CHAR(16);

DEFINE v_Registros    SMALLINT;

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';

LET v_fecha_emision 		= " ";
LET v_num_credito 			= "";

LET v_secuencia 		= 0;
LET v_nlinea 				= 0;
LET v_fecha_mov 		= "";
LET v_concepto 			= "";
LET v_cargos 				= "";
LET v_abonos 				= "";

LET v_Registros    	= 0;

--SET DEBUG FILE TO "detalle_edocta.out";
--TRACE ON;

BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
					nvl(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
					NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
					NVL(v_cargos,""),NVL(v_abonos,"");
		END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	FOREACH 
		SELECT	fecha_emision,			num_credito,				secuencia,
						nlinea,							fecha_mov,					concepto,
						cargos,							abonos
		INTO		v_fecha_emision,			v_num_credito,				v_secuencia,
						v_nlinea,							v_fecha_mov,					v_concepto,
						v_cargos,							v_abonos
		 FROM bdicred@pld_tcp:sd_detalle_edocta
		 --FROM sd_detalle_edocta
		 WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
		 ORDER BY secuencia,nlinea


		LET v_Registros = v_Registros + 1;
		IF v_Registros <= pNumRegistros THEN
				CONTINUE FOREACH;
		END IF
		
		IF v_num_credito IS NULL THEN
				LET sCodRet = "185";
	      RETURN sCodRet, 
					nvl(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
					NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
					NVL(v_cargos,""),NVL(v_abonos,"");
		END IF

	  RETURN sCodRet, 
					v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0),
					NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
					NVL(v_cargos,""),NVL(v_abonos,"")
     WITH RESUME;
	
	END FOREACH
	
END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".mensajes_edocta(
					   pEmpresa CHAR(3),
			           pNumCredito CHAR(20),
			           pFechaEmision DATE,
			           pNumRegistros SMALLINT)
RETURNING CHAR(5), DATE ,CHAR(20),SMALLINT,	SMALLINT,CHAR(255),	CHAR(255);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 		CHAR(20);

DEFINE v_secuencia 			SMALLINT;
DEFINE v_nlinea 			SMALLINT;
DEFINE v_si_paga 			CHAR(255);
DEFINE v_mensajes 			CHAR(255);


DEFINE v_Registros          SMALLINT;

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err          = 0;
LET sCodRet          = '000';
LET v_fecha_emision  = " ";
LET v_num_credito 	 = "";
LET v_secuencia 	 = 0;
LET v_nlinea 		 = 0;
LET v_si_paga 		 = "";
LET v_mensajes 		 = "";
LET v_Registros    	 = 0;

--SET DEBUG FILE TO "mensajes_edocta.out";
--TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err
    LET sCodRet = sql_err;
    RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
    END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
    
   IF pFechaEmision <= mdy('03','20','2010') THEN

        FOREACH 
            SELECT 	fecha_emision,	num_credito, secuencia,
                    nlinea,	si_paga, mensajes
            INTO 	v_fecha_emision, v_num_credito,	v_secuencia,
                    v_nlinea, v_si_paga, v_mensajes
            FROM bdicred@pld_tcp:sd_mensajes_edocta
			--FROM sd_mensajes_edocta
            WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
            ORDER BY secuencia,nlinea


            LET v_Registros = v_Registros + 1;

            IF v_Registros <= pNumRegistros THEN
                    CONTINUE FOREACH;
            END IF

            IF v_num_credito IS NULL THEN
                LET sCodRet = "185";

            RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
            END IF

            RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
            WITH RESUME;

        END FOREACH

   ELSE

        FOREACH 


            SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
			--FROM sd_mensajes_edocta a
            FROM bdicred@pld_tcp:sd_mensajes_edocta a
            --left outer join bdicred:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
			left outer join bdicred@pld_tcp:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
            WHERE a.fecha_emision = pFechaEmision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = pNumCredito
            UNION ALL
            select fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
            INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
            FROM bdicred@pld_tcp:sd_mensajes_edocta a
			--FROM sd_mensajes_edocta a
            WHERE a.fecha_emision = pFechaEmision and num_credito = pNumCredito
            order by 2,3,4


            LET v_Registros = v_Registros + 1;

            IF v_Registros <= pNumRegistros THEN
                    CONTINUE FOREACH;
            END IF

            IF v_num_credito IS NULL THEN
                LET sCodRet = "185";

            RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
            END IF

            RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
            WITH RESUME;

        END FOREACH

   END IF;
	
END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_rep_ctes_pagvencidos(pEmpresa CHAR(03))

RETURNING CHAR(6),CHAR(80);

DEFINE cCodret         CHAR(6);
DEFINE iIsamErr        SMALLINT;
DEFINE cMensajeRet     CHAR(80);
DEFINE sql_err         INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE v_fch_ini       DATE;
DEFINE v_fch_fin       DATE;
DEFINE cNombre_Archivo CHAR(100);
DEFINE cSql            CHAR(2024);
DEFINE var_rga         CHAR(05);
DEFINE cNom_mes        CHAR(10);
DEFINE pFecha          DATE;
DEFINE iNum_dia        INTEGER;
DEFINE iNum_mes        INTEGER;
DEFINE iNum_anio       INTEGER;
DEFINE iQuery          SMALLINT;
DEFINE cruta				CHAR(100);

DEFINE cNum_credito             CHAR(20);
DEFINE cSucursal				CHAR(04);
DEFINE dFecha_apertura			DATE;
DEFINE sNum_periodos			SMALLINT;
DEFINE dMonto_otorgado			DECIMAL(18,02);
DEFINE dSdo_cap_insoluto		DECIMAL(18,02);
DEFINE dSdo_capital				DECIMAL(18,02);
DEFINE dTransitorio				DECIMAL(18,02);
DEFINE dVencido_exigible		DECIMAL(18,02);
DEFINE dVencido_no_exigible		DECIMAL(18,02);
DEFINE dInteres_vencido			DECIMAL(18,02);


LET cCodret         = '000000';
LET iIsamErr        = 0;
LET v_fch_ini       = '';
LET v_fch_fin       = '';
LET sql_err         = 0;
LET cErrorInfo      = '';
LET cNombre_Archivo = '';
LET cSql            = '';
LET iNum_dia        = 0;
LET iNum_anio       = 0;
LET iNum_mes        = 0;
LET cNom_mes        = '';
LET iQuery          = 0;
LET cMensajeRet     = 'El proceso de PAGOS VENCIDOS se ejecutó correctamente';
--Variables que se usan para el insert y creación del archivo de salida
LET cNum_credito            = '';
LET cSucursal				= '';
LET dFecha_apertura			= date(0);
LET sNum_periodos			= 0;
LET dMonto_otorgado			= 0.00;
LET dSdo_cap_insoluto		= 0.00;
LET dSdo_capital			= 0.00;
LET dTransitorio			= 0.00;
LET dVencido_exigible		= 0.00;
LET dVencido_no_exigible	= 0.00;
LET dInteres_vencido		= 0.00;
LET cruta					= "";

BEGIN

 ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
             LET cCodret = sql_err;
             LET cMensajeRet= cErrorInfo;
             RETURN cCodret,cMensajeRet;
  END EXCEPTION;

--SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_rep_ctes_pagvencidos.out";
--TRACE ON;
--Ruta
SELECT TRIM(valor_alfabetico) 
	INTO cRuta
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' and tipo_campania = 50 
	AND num_parametro = 2;

LET pFecha    = TODAY;
LET iNum_dia  = day(pFecha);
LET iNum_mes  = month(pFecha);
LET iNum_anio = year(pFecha);

IF iNum_dia >= 1 AND iNum_dia <= 5 THEN
--Query de consulta al fin de mes
    LET iQuery = 1;
    LET iNum_dia = day(mdy(month(pFecha),1,year(pFecha))-1);
    IF iNum_mes > 1  THEN LET iNum_mes = iNum_mes - 1; ELSE LET iNum_mes = 12; END IF;
    IF iNum_mes = 1  THEN LET cNom_mes = 'Enero';         END IF;
    IF iNum_mes = 2  THEN LET cNom_mes = 'Febrero';       END IF;
    IF iNum_mes = 3  THEN LET cNom_mes = 'Marzo';         END IF;
    IF iNum_mes = 4  THEN LET cNom_mes = 'Abril';         END IF;
    IF iNum_mes = 5  THEN LET cNom_mes = 'Mayo';          END IF;
    IF iNum_mes = 6  THEN LET cNom_mes = 'Junio';         END IF;
    IF iNum_mes = 7  THEN LET cNom_mes = 'Julio';         END IF;
    IF iNum_mes = 8  THEN LET cNom_mes = 'Agosto';        END IF;
    IF iNum_mes = 9  THEN LET cNom_mes = 'Septiembre';    END IF;
    IF iNum_mes = 10 THEN LET cNom_mes = 'Octubre';       END IF;
    IF iNum_mes = 11 THEN LET cNom_mes = 'Noviembre';     END IF;
    IF iNum_mes = 12 THEN LET cNom_mes = 'Diciembre'; LET iNum_anio = year(pFecha)-1; END IF;
ELIF iNum_dia >= 21 AND iNum_dia <= 25 THEN
--Query de consulta al corte
    LET iQuery = 2;
    LET iNum_dia = 20;
    IF iNum_mes = 1  THEN LET cNom_mes = 'Enero';       END IF;
    IF iNum_mes = 2  THEN LET cNom_mes = 'Febrero';     END IF;
    IF iNum_mes = 3  THEN LET cNom_mes = 'Marzo';       END IF;
    IF iNum_mes = 4  THEN LET cNom_mes = 'Abril';       END IF;
    IF iNum_mes = 5  THEN LET cNom_mes = 'Mayo';        END IF;
    IF iNum_mes = 6  THEN LET cNom_mes = 'Junio';       END IF;
    IF iNum_mes = 7  THEN LET cNom_mes = 'Julio';       END IF;
    IF iNum_mes = 8  THEN LET cNom_mes = 'Agosto';      END IF;
    IF iNum_mes = 9  THEN LET cNom_mes = 'Septiembre';  END IF;
    IF iNum_mes = 10 THEN LET cNom_mes = 'Octubre';     END IF;
    IF iNum_mes = 11 THEN LET cNom_mes = 'Noviembre';   END IF;
    IF iNum_mes = 12 THEN LET cNom_mes = 'Diciembre';   END IF;
ELSE
    LET cCodret     = '999999';
    LET cMensajeRet = 'Hoy no es un día válido para ejecutar el proceso de PAGOS VENCIDOS';
    RETURN cCodret,cMensajeRet;
END IF;

LET  cNombre_Archivo= 'Rep_Ctes_PagosVencidos_' || iNum_dia || TRIM(cNom_mes) || iNum_anio || '.txt';

IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_ctes_pagosvencidos' ) THEN
   DROP TABLE temp_ctes_pagosvencidos;
END IF;

   CREATE TABLE  temp_ctes_pagosvencidos
    ( num_credito        CHAR(20),  
      sucursal           CHAR(04),
      fecha_apertura     DATE,
      num_periodos       SMALLINT,
      monto_otorgado     DECIMAL(18,02),
      sdo_cap_insoluto   DECIMAL(18,02),
      sdo_capital        DECIMAL(18,02),
      monto_vencido      DECIMAL(18,02),
      mto_venc_trasp     DECIMAL(18,02),
      cap_tras_no_venci  DECIMAL(18,02),
      interes_vencido    DECIMAL(18,02)
    );

CREATE INDEX idx_temp_ctes
    ON informix.temp_ctes_pagosvencidos(num_credito, sucursal);

SET ISOLATION TO dirty READ;
SET LOCK MODE TO WAIT 3;

IF iQuery = 1 THEN
  INSERT INTO  temp_ctes_pagosvencidos
    select a.num_credito, a.sucursal, fecha_apertura, num_periodos, monto_otorgado, sdo_cap_insoluto,  
    sdo_capital vigente, monto_vencido transitorio, mto_venc_trasp vencido_exigible, cap_tras_no_venci vencido_no_exigible, 
    case when mto_venc_trasp > 0 then int_tra_no_exig - nvl((select sdo_int_anticip from bdicred:sd_maesdoshist where empresa = pEmpresa 
    and a.num_credito = num_credito and fecha = mdy(month(a.fecha),'20',year(a.fecha))),0) else 0 end interes_vencido 
    from bdicred:sd_maecredcont a,
    bdicred:sd_maesdoscont c,
    bdicred:sd_histvalcon b
    where a.empresa = pEmpresa
      and a.empresa = b.empresa and a.empresa = c.empresa
      and a.num_credito = b.num_credito and a.num_credito = c.num_credito
      and a.fecha = mdy(iNum_mes,iNum_dia,iNum_anio) and a.fecha = c.fecha
      and fecha_alta = a.fecha and num_periodos in (1,2,3);
ELSE
    FOREACH
        select b.num_credito, 
        (select count(*) from bdicred:sd_maesdoshist d where empresa = pEmpresa and b.num_credito = d.num_credito and fecha >= 
        (select max(fecha) from bdicred:sd_maesdoshist where empresa = pEmpresa and b.num_credito = num_credito and monto_vencido > 0) and fecha <= b.fecha and (monto_vencido > 0 or mto_venc_trasp > 0)), 
        monto_otorgado, sdo_cap_insoluto, sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, 
        case when mto_venc_trasp > 0  then int_tra_no_exig - sdo_int_anticip else 0 end
          into cNum_credito, 
        sNum_periodos, dMonto_otorgado, dSdo_cap_insoluto, dSdo_capital, dTransitorio, dVencido_exigible, dVencido_no_exigible, 
        dInteres_vencido 
        from bdicred:sd_maesdoshist b
        where b.empresa = pEmpresa
          and b.num_credito = b.num_credito
        and b.fecha = mdy(iNum_mes,iNum_dia,iNum_anio)
                and b.num_credito = (select num_credito from bdicred:sd_maecred where empresa=pEmpresa and num_credito=b.num_credito)
          and (monto_vencido > 0 or mto_venc_trasp > 0)
          and (select count(*) from bdicred:sd_maesdoshist c where empresa = pEmpresa and b.num_credito = c.num_credito and fecha >= 
        (select max(fecha) from bdicred:sd_maesdoshist where empresa = pEmpresa and b.num_credito = num_credito and monto_vencido > 0)
        and fecha <= b.fecha and (monto_vencido > 0 or mto_venc_trasp > 0)) in (1,2,3)

        select a.sucursal, fecha_apertura 
          into cSucursal, dFecha_apertura
        from bdicred:sd_maecred a
        where a.empresa = '001' 
          and a.num_credito = cNum_credito;

      INSERT INTO temp_ctes_pagosvencidos VALUES (
         cNum_credito,cSucursal,dFecha_apertura,sNum_periodos,dMonto_otorgado,dSdo_cap_insoluto,
         dSdo_capital,dTransitorio,dVencido_exigible,dVencido_no_exigible,dInteres_vencido);

--Se inicializan las variables que se usan para el insert y creación del archivo de salida
        LET cNum_credito            = '';
        LET cSucursal				= '';
        LET dFecha_apertura			= date(0);
        LET sNum_periodos			= 0;
        LET dMonto_otorgado			= 0.00;
        LET dSdo_cap_insoluto		= 0.00;
        LET dSdo_capital			= 0.00;
        LET dTransitorio			= 0.00;
        LET dVencido_exigible		= 0.00;
        LET dVencido_no_exigible	= 0.00;
        LET dInteres_vencido		= 0.00;

    END FOREACH

END IF;

  --Se genera archivo con la informacion del reporte
LET cSql = '';
LET cSql = 'echo "UNLOAD TO ' ||  trim(cRuta) || 'ReporteCtes_PagosVencidos.unl' || ' DELIMITER ' || '''|'''|| 
           ' select * from bdicred:temp_ctes_pagosvencidos;'|| 
           ' " >'||TRIM(cruta)||'ReporteCtes_PagosVencidos.sql';

SYSTEM cSql;

LET cSql = '';
LET cSql = 'dbaccess bdicred ' || TRIM(cruta) || 'ReporteCtes_PagosVencidos.sql';
SYSTEM cSql;

LET cSql = "sed 's/|$//g' " || trim(cruta) || "ReporteCtes_PagosVencidos.unl > " || trim(cruta) || cNombre_Archivo;
SYSTEM cSql;
     
LET cSql = '';
LET cSQL = 'rm ' || trim(cruta) || 'ReporteCtes_PagosVencidos.sql';
SYSTEM cSql;

LET cSql = '';
LET cSQL = 'rm ' || trim(cruta) || 'ReporteCtes_PagosVencidos.unl';
SYSTEM cSql;

DROP TABLE  temp_ctes_pagosvencidos;  
       
RETURN cCodret,cMensajeRet;

END
END PROCEDURE;