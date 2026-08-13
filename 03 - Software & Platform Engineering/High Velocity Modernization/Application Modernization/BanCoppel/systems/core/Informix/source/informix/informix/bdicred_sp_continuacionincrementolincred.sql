CREATE PROCEDURE "informix".sp_continuacionincrementolincred (pEmpresa CHAR(3), pNumCredito CHAR(20))	

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCodRet2     CHAR(6);
DEFINE cMensajeRet  CHAR(80);


DEFINE iMesesHist   INTEGER;
DEFINE cPuntualidad CHAR(3);
DEFINE iEficiencia  INTEGER;
DEFINE cSituacion   CHAR(2);
DEFINE iCausaSE     INTEGER;
DEFINE iSitEspRechazo  INTEGER;
DEFINE cMotivo      CHAR(1);
DEFINE cTipoRech    CHAR(1);
DEFINE dMaxMtoUdi   DECIMAL(14,2);
DEFINE dValorUdi    DECIMAL(14,6);
DEFINE cCodUdi      CHAR(2);
DEFINE cClase       CHAR(1);
DEFINE cStatus		CHAR(2);
DEFINE cCausa		CHAR(3);
DEFINE sLineaCreditoBC  SMALLINT;
DEFINE sLineaCreditoCAC INTEGER;
DEFINE cNumCte 		CHAR(20);
DEFINE dtFechaInsert DATE;
DEFINE cSucursal 		CHAR(20);
DEFINE dLineaSugerida DECIMAL(18,2);
DEFINE dLincredSolicitada DECIMAL(18,2);
DEFINE dComparacion85      DECIMAL(10,2);
DEFINE iVencidomuebles INTEGER;
DEFINE iVencidoropa    INTEGER;
DEFINE iVencidoprestamos INTEGER;
DEFINE iAbonomuebles	 INTEGER;
DEFINE iAbonoropa      INTEGER;
DEFINE iAbonoprestamos INTEGER;
DEFINE iAvanza INTEGER;
DEFINE dEva_min_sup    DECIMAL(5,2);
DEFINE dEva_max_sup    DECIMAL(5,2);
DEFINE iSinRespuesta   INTEGER;
--Homologacion.
DEFINE iDiasVigenciaHomo  			INTEGER;
DEFINE cNumSolSIC  					CHAR(20);
DEFINE dtFechaSic 					DATE;
DEFINE cConsultaSic  				CHAR(2);
DEFINE cCod_ret                		CHAR(5);
DEFINE dtFechaHoy		    		DATE;
--Declaracion variables sp_valida_respuesta_bc_ofi.
DEFINE cCodigoRetorno 				CHAR(6);
DEFINE vcDescripcionError			VARCHAR(255);
--IPCB se integra variable para lectura de la institución de la consulta a BC
DEFINE institucion_sic     			CHAR(2);
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB 
DEFINE ccausaRT    					CHAR(4);

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "000000";
LET cCodRet2        = "000000";
LET cMensajeRet     = "PROCESO EXITOSO";

LET iMesesHist      = 0;
LET cPuntualidad    = "";
LET iEficiencia     = 0;
LET cSituacion      = "";
LET iCausaSE        = 0;
LET iSitEspRechazo  = 0;
LET cMotivo         = "";
LET cTipoRech       = "";
LET dMaxMtoUdi      = 0;
LET dValorUdi       = 0;
LET cCodUdi         = "";
LET cClase          = "";
LET cStatus         = "";
LET cCausa          = "";
LET sLineaCreditoBC = 0;
LET sLineaCreditoCAC = 0;
LET cNumCte         = "";
LET dtFechaInsert   = DATE(1);
LET cSucursal       = "";
LET dLineaSugerida  = 0;
LET dLincredSolicitada  = 0;
LET dComparacion85       = 0;
LET	iVencidomuebles = 0;
LET	iVencidoropa    = 0;
LET	iVencidoprestamos = 0;
LET	iAbonomuebles	 = 0;
LET	iAbonoropa     = 0;
LET	iAbonoprestamos = 0;
LET	iAvanza = 0;
LET	dEva_min_sup = 0;
LET	dEva_max_sup = 0;
LET	iSinRespuesta = 0;
--Homologacion.
LET iDiasVigenciaHomo				= 7;
LET cNumSolSIC 						= ""; 
LET dtFechaSic 						= DATE(1);
LET cConsultaSic 					= "";
LET cCod_ret                		= "000";
LET dtFechaHoy			   			= DATE(1);
--Declaracion variables sp_valida_respuesta_bc_ofi.
LET cCodigoRetorno 					= "000000";
LET vcDescripcionError 				= "";
--IPCB se integra variable para lectura de la institución de la consulta a BC
LET institucion_sic 			    ='BC';
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB 
LET ccausaRT 						= "";
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
	INSERT INTO  bdicred:"informix".sd_bitacora_continuacion (codigo_error, solicitud, fecha, hora, comentario) 
	VALUES (iSqlErr, pNumCredito, TODAY, CURRENT HOUR TO FRACTION(3), cErrorInfo);
	RETURN ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/respaldosbd/Malena/sp_continuacionincrementolincred .out';
	--TRACE ON;
	
-- Compara línea crédito para enviar a BC 
SELECT valor 
  INTO sLineaCreditoBC
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '027'
   AND empresa = pEmpresa ;

IF NVL(sLineaCreditoBC,"") = "" THEN
    INSERT INTO  bdicred:"informix".sd_bitacora_continuacion (codigo_error, solicitud, fecha, hora, comentario) 
	VALUES ("001", pNumCredito, TODAY, CURRENT HOUR TO FRACTION(3), "ERROR AL OBTENER LA LÍNEA CRÉDITO PARA ENVIAR A BC PARA INCREMENTOS DE LÍNEA");
	RETURN ;
END IF;
-- Compara línea crédito para enviar aL CAC 
SELECT valor 
  INTO sLineaCreditoCAC
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '043'
   AND empresa = pEmpresa ;

IF NVL(sLineaCreditoCAC,"") = "" THEN
	INSERT INTO  bdicred:"informix".sd_bitacora_continuacion (codigo_error, solicitud, fecha, hora, comentario) 
	VALUES ("002", pNumCredito, TODAY, CURRENT HOUR TO FRACTION(3), "ERROR AL OBTENER LA LÍNEA CRÉDITO PARA ENVIAR A CC PARA INCREMENTOS DE LÍNEA");
    RETURN ;
END IF;	
--valor para los porcentajes de eficiencia
SELECT evaluacion_min, evaluacion_max INTO dEva_min_sup, dEva_max_sup
FROM bdisolic:"informix".ss_scoring_solic
WHERE empresa = pEmpresa
AND tp_solicitud = "T"
AND seccion = 3
AND tpo_persona = "01"
AND activa = '0'; 



	IF (SELECT count(folio_movil) 
			FROM bdisolic:"informix".ss_solicitudes_movil							
			WHERE 	empresa  = pEmpresa 
			AND  folio_movil = pNumCredito AND  status <> '3') > 0 THEN
			
			EXECUTE PROCEDURE bdisolic:"informix".sp_evalua_sol_movil(pEmpresa ,pNumCredito) INTO cCodRet2,cMensajeRet ;	

	ELSE



		FOREACH WITH HOLD
			SELECT  a.meseshist,a.puntualidad,a.eficiencia,a.sitespecial,a.causa,a.vdoropa,a.vdomuebles,a.vdoprestamos,
			a.abonomesropa,a.abonomesmuebles,a.abonomesprestamos,b.numcte,b.fecha_insert,b.sucursal,b.lincred_solicitada,b.lincred_sugerida,a.sin_respuesta
			INTO iMesesHist,cPuntualidad,iEficiencia,cSituacion,iCausaSE, iVencidoropa,iVencidomuebles,iVencidoprestamos,
			iAbonoropa,iAbonomuebles, iAbonoprestamos, cNumCte, dtFechaInsert, cSucursal, dLincredSolicitada, dLineaSugerida,iSinRespuesta
			FROM bdicred:"informix".sd_graba_respuesta_conscoppel a -- NO TIENE BASE DE DATOS
			INNER JOIN "informix".sd_bitacora_aumlincred b ON (a.num_solicitud = b.num_solicitud AND b.status = "EC")
			WHERE a.num_solicitud = pNumCredito
			AND a.empresa = pEmpresa
			ORDER BY fecha_insert  desc
		
		IF DBINFO("sqlca.sqlerrd2") >	0 THEN
		
			   IF iSinRespuesta = 0 THEN
					LET cStatus    = "RT";
					LET cCausa     = "RCC";
			   ELIF cPuntualidad = "Z" THEN--validar puntualidad Z
					LET cStatus    = "RT";
					LET cCausa     = "RCP";
				ELIF iEficiencia  < dEva_min_sup OR iEficiencia  >  dEva_max_sup THEN			
					LET cStatus    = "RT";
					LET cCausa     = "REC";				
				ELSE
					--validar siuaciones especiales
					SELECT motivo_rechazo_sol, tipo_rechazo
						INTO cMotivo, cTipoRech
					FROM bdicred:"informix".sd_situacion_cred
					WHERE empresa = pEmpresa
					AND situacion = cSituacion;

					-- *****************************
					-- Valida Situacion de credito *
					-- *****************************

					IF cMotivo IS NULL THEN
						LET cMotivo ="0";
					END IF

					IF cMotivo = "1" THEN
						LET iSitEspRechazo = 1;       
					END IF

					IF cTipoRech = "1" THEN
						LET iSitEspRechazo = 1;     
					ELSE
						SELECT motivo_rechazo_sol
						INTO cMotivo
						FROM bdicred:"informix".sd_causas_cte_coppel
						WHERE empresa = pEmpresa
						AND situacion = cSituacion
						AND causa = iCausaSE;
						
						IF cMotivo = "1" THEN
							LET iSitEspRechazo = 1;              
						END IF
					END IF

					IF iSitEspRechazo = 1 THEN
						LET cStatus    = "RT";
						LET cCausa     = "RSE";	  
					ELSE --validar vencidos
						IF NVL(iVencidomuebles,0) > 0 OR NVL(iVencidoropa,0) > 0 OR NVL(iVencidoprestamos,0) > 0 THEN
							SELECT valor 
								INTO dMaxMtoUdi
							FROM bdisolic:"informix".ss_param
							WHERE empresa = pEmpresa
							AND secuencia = 309;

							-- *****************************************
							--  Extrae Clase y Tipo de Cmabio para UDI *
							-- *****************************************
							SELECT TRIM(valor) 
								INTO cCodUdi
							FROM bdinteg:"informix".si_param
							WHERE empresa = pEmpresa
							AND cod_param = 16;

							SELECT TRIM(valor) INTO cClase
							FROM bdicred:"informix".sd_param
							WHERE empresa = pEmpresa
							AND cod_param = "336";

							CALL bdinteg:"informix".valor_divisa_pesos(pEmpresa, TODAY, cCodUdi, cClase,'0') 
								RETURNING cCodRet, dValorUdi;

							IF (cCodRet <> "00000") THEN	
								INSERT INTO  bdicred:"informix".sd_bitacora_continuacion (codigo_error, solicitud, fecha, hora, comentario) 
								VALUES ("003", pNumCredito, TODAY, CURRENT HOUR TO FRACTION(3), "ERROR AL OBTENER EL VALOR DE LA UDIS");							    						
								RETURN ;
							END IF;					
							
							LET dComparacion85 = dMaxMtoUdi * dValorUdi;

							
							IF NOT ( iVencidomuebles <= iAbonomuebles/2 AND iVencidomuebles <= dComparacion85 ) AND iVencidomuebles > 0 THEN
								LET iAvanza = 1;
							END IF

							IF NOT ( iVencidoropa <= iAbonoropa/2 AND iVencidoropa <= dComparacion85 ) AND iAvanza = 0 AND iVencidoropa > 0 THEN
								LET iAvanza = 1;
							END IF

							IF NOT ( iVencidoprestamos <= iAbonoprestamos/2 AND iVencidoprestamos <= dComparacion85 ) AND iAvanza = 0 AND iVencidoprestamos > 0 THEN
								LET iAvanza = 1;
							END IF						
							
							IF ( iAvanza = 1 ) THEN
								LET cStatus    = "CN";
								LET cCausa     = "CVC";								  
							END IF;
						END IF;				END IF; --validacion de las situacion especiales	
				END IF; -- validacion de la erron en consulta a coppel		
			 
			
			--IF (dLineaSugerida >= sLineaCreditoBC) AND cStatus = "" THEN --se compara en pesos y no en salarios mínimos
			IF cStatus = "" THEN --se compara en pesos y no en salarios mínimos	
				LET cStatus     = "BC";
			ELSE
				IF (dLineaSugerida >= sLineaCreditoCAC) AND cStatus = "" THEN --se compara en pesos y no en salarios mínimos
					LET cStatus     = "AC";			ELIF (dLineaSugerida < sLineaCreditoCAC) AND cStatus = "" THEN 
					LET cStatus     = "AT";			END IF;		
			END IF;		
			
			UPDATE bdicred:"informix".sd_bitacora_aumlincred  
			SET status          = cStatus,
				causa_status 	= cCausa,
				fecha_status    = today,
				hora_status     = CURRENT,
				antiguedad 		 = iMesesHist,
				puntualidad		 = cPuntualidad,
				eficienciapago	 = iEficiencia,
				montovencido 	 = (NVL(iVencidoropa,0)+NVL(iVencidomuebles,0)+ NVL(iVencidoprestamos,0)),
				abonomensual 	 = (NVL(iAbonoropa,0)+ NVL(iAbonomuebles,0)+NVL(iAbonoprestamos,0)),
				situacion 		 = cSituacion,
				causa 			 = iCausaSE		
			WHERE fecha_insert  = dtFechaInsert
			AND numcte          = cNumCte
			AND num_solicitud   = pNumCredito
			AND empresa         = pEmpresa
			AND status			="EC";
					
			INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
			VALUES(pEmpresa, pNumCredito, cStatus, cCausa, USER, TODAY, TODAY, 0);		
			 
			IF cStatus = "BC" THEN ------Envio a Buro de crédito
							
				--------------------------------HOMOLOGACION CON PROCESO PRODUCTIVO ----------------------------------
				SELECT fecha_hoy
				INTO dtFechaHoy
				FROM bdicred:"informix".sd_fechas
				WHERE empresa = pEmpresa;			
					
				------Obtencion del parametro de dias de vigencia de consultas SIC
				SELECT valor
				INTO iDiasVigenciaHomo
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = 362;
				
				IF NVL(iDiasVigenciaHomo,0) = 0 THEN
					LET iDiasVigenciaHomo = 0; 
				END IF;   	    
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB --se extrae el nuevo campo causa_rt, para validar los rechazos	
				SELECT num_solicitud_sic, fecha_sic, institucion,causa_rt
				INTO cNumSolSIC, dtFechaSic, cConsultaSic, ccausaRT				   
				FROM bdisolic:"informix".ss_solicitudes_sic
				WHERE rowid = (SELECT MAX(rowid)
							   FROM bdisolic:"informix".ss_solicitudes_sic
							   WHERE numcte= cNumCte
							   AND (fecha_sic >= dtFechaHoy - iDiasVigenciaHomo or fecha_sic IS NULL));
							   
				--IPCB se integra variable para lectura de la institución de la consulta a BC
				SELECT status_solicitud
				INTO institucion_sic
				FROM bdisolic:"informix".ss_status_sol 
				WHERE empresa = pEmpresa 
				AND tipo_auto = '1';									   
								   
				IF cNumSolSIC IS NULL THEN 
					INSERT INTO bdisolic:"informix".ss_solicitudes_sic
						(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
					VALUES(pEmpresa,cNumCte,pNumCredito,pNumCredito,institucion_sic,dtFechaHoy,NULL);
				
					INSERT INTO bdicred:"informix".sd_solicitudes_aumlincred_sucursal 
					(empresa, institucion, num_credito, numcte, status, origen, sucursal, fecha_envio, fecha_respuesta) 
					VALUES (pEmpresa, 'BC', pNumCredito, cNumCte, 'BC', 'S',cSucursal,TODAY,TODAY);
				
				   EXECUTE PROCEDURE bdiburo:"informix".burocred(pEmpresa, "0001", "BC", pNumCredito, 0) 
				   INTO cCod_ret;
				ELSE
					IF dtFechaSic IS NULL THEN 
						INSERT INTO bdisolic:"informix".ss_solicitudes_sic
						(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
						VALUES(pEmpresa,cNumCte,pNumCredito,cNumSolSIC,institucion_sic,dtFechaHoy,NULL);
					ELSE
						INSERT INTO bdisolic:"informix".ss_solicitudes_sic
						(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic,causa_rt)
						VALUES(pEmpresa,cNumCte,pNumCredito,cNumSolSIC,cConsultaSic,dtFechaHoy,dtFechaSic,ccausaRT);			
--IPCB junio2017 //RECHAZO POR CREDITO BLOQUEADO RCB	
						IF ccausaRT = 'RCB' THEN				
							UPDATE bdicred:"informix".sd_bitacora_aumlincred 
							SET status          = 'RT',
								causa_status 	= 'RCB',
								fecha_status    = dtFechaHoy,
								hora_status     = CURRENT,
								revisioncac     = 0
							WHERE fecha_insert  = dtFechaHoy
							AND numcte          = cNumCte
							AND num_solicitud   = pNumCredito
							AND empresa         = pEmpresa;
					
							INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
							VALUES(pEmpresa, pNumCredito, 'RT', 'RCB', 'sistema', dtFechaHoy, dtFechaHoy, 0);

							IF EXISTS (SELECT fecha_sic  FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = cNumCte and num_Solicitud = pNumCredito and fecha_sic is null) THEN
								UPDATE bdisolic:"informix".ss_solicitudes_sic set fecha_sic = dtFechaHoy, causa_rt = 'RCB'
								WHERE numcte = cNumCte and num_Solicitud = pNumCredito and fecha_sic is null;					
							END IF;
						ELSE					
									
							EXECUTE PROCEDURE bdiburo:"informix".sp_valida_respuesta_bc_ofi(pEmpresa,pNumCredito)
							INTO cCodigoRetorno,vcDescripcionError; 
						END IF;				
					END IF;
				END IF;
				--------------------------------FIN DE HOMOLOGACION CON PROCESO PRODUCTIVO ---------------------------								
			END IF;
		END IF;
			EXIT FOREACH;
		END FOREACH;
	END IF
RETURN ;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para continuacion de flujo de clientes que tramitaron un incremento en su linea de crédito',
' y fueron enviados a consulta coppel',
'AUTOR : Maria Elena Angulo, Jesus Manuel Aguilar',
'FECHA : 29/Nov/2011',
'BD: BDICRED',
'VERSION:20111129.1107',
'MODIFICACION: Se modifico para hacer la homologacion con proceso productivo',
'AUTOR: Guadalupe Payan',
'FECHA: Junio 2012',
'VERSION: 20120613.0951';

CREATE PROCEDURE "informix".sp817_setrandomseed(n DECIMAL(10) DEFAULT NULL)
   DEFINE GLOBAL seed DECIMAL(10) DEFAULT NULL;
   DEFINE hora integer;
   DEFINE minuto integer;
   DEFINE segundo integer;
   IF n IS NULL THEN
      let hora = current::datetime HOUR TO HOUR::char(2)::int;
      let minuto = current::datetime MINUTE TO MINUTE::char(2)::int;
      let segundo = current::datetime SECOND TO SECOND::char(2)::int;
      IF minuto>segundo THEN
         LET n = hora*minuto/(segundo+1);
      ELSE
         LET n = hora*segundo/(minuto+1);
      END IF;
   END IF;
   LET seed = n;
END PROCEDURE;