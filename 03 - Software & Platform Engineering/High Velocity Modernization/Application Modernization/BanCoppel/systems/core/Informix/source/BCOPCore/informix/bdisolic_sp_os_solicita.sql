CREATE PROCEDURE "informix".sp_os_solicita(pempresa CHAR(3), pnum_solicitud CHAR(20), pusuario CHAR(8))
RETURNING  VARCHAR(6);

--Autor: Juan AndrÃ©s Coronel M., 14-08-2007
--Procedimiento usado para hacer la solicitud de ordenes de supervision

--Modifico: JesÃºs Manuel Aguilar Heredia;
--Descripion: Se modifica para relanzamiento de solicitudes de coppel cuando se envie una sola solicitud de os calle para banco y coppel al mismo tiempo.
--Fecha: 23-10-2011

--Modifico: JosuÃ© Remberto Zazueta Acosta
--Descripion: Se crea relanzamiento de solicitud coppel cuando esta tiene 3 lanzamientos pero que su domicilio fue modificado
--Fecha: 05-01-2015

--Modifico: Jose Raul Pacheco
--Descripion: Se crea flujo para identificar si el origen de la solicitud es prospectos
--Fecha: 07-04-2015

--Modifico: JosuÃ© Remberto Zazueta Acosta
--Descripion: Se modifica para quitar campo de mas en select a pr_cliente y cambiar el nombre de el 
--parametro o_empresa  por pempresa
--Fecha: 05-01-2015


DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
DEFINE dFechaEnt        DATE;
DEFINE pComentario      VARCHAR(60) ;
DEFINE iCuantos         INTEGER;
DEFINE SQL_ERR     		INTEGER;
DEFINE ISAM_ERR    		INTEGER;
DEFINE ERROR_INFO  		VARCHAR(80);
DEFINE P_COD_RET   		VARCHAR(6);
DEFINE P_MENSAJE   		VARCHAR(80);
DEFINE wBegin           CHAR(1);
DEFINE sEs_Coppel       SMALLINT;

DEFINE iContadorRelanzamiento INTEGER;
DEFINE iSecOS			INTEGER;
DEFINE iSolEnviadasOS	INTEGER;
DEFINE cSolCoppel       CHAR(20);
DEFINE cSolBanco        CHAR(20);
DEFINE cSolicitud       CHAR(20);
DEFINE cTipoSol        CHAR(1);
DEFINE iSeguir			INTEGER;
DEFINE iBanderaAutDirecta	INTEGER;
DEFINE cMensaje			CHAR(50);
DEFINE cStatusBan		CHAR(2);

-- VARIABLES PARA VERIFICAR SI SE CAMBIO EL DOMICILIO
DEFINE	cOservaciones	CHAR(80);
DEFINE	cEntre_calles	CHAR(40);
DEFINE	cEstado			CHAR(2);
DEFINE	cMunicipio		CHAR(5);
DEFINE	cCiudad			SMALLINT;
DEFINE	cColonia		CHAR(60);
DEFINE	cCalle			CHAR(40);
DEFINE	cNumeroextcalle	CHAR(10);
DEFINE	cNumerointcalle	CHAR(10);

DEFINE	cOservaciones_Act		CHAR(80);
DEFINE	cEntre_calles_Act		CHAR(40);
DEFINE	cEstado_Act				CHAR(2);
DEFINE	cMunicipio_Act			CHAR(5);
DEFINE	cCiudad_Act				SMALLINT;
DEFINE	cColonia_Act			CHAR(60);
DEFINE	cCalle_Act				CHAR(40);
DEFINE	cNumeroextcalle_Act		CHAR(10);
DEFINE	cNumerointcalle_Act		CHAR(10);

DEFINE  dFecha_insert	DATE;
DEFINE  dFecha_resp		DATE;
DEFINE 	cNumcte			CHAR(20);
DEFINE 	sRelanParam    	SMALLINT;
DEFINE 	sRelanSol    	SMALLINT;
DEFINE 	sSumRelanSol 	SMALLINT;
DEFINE 	sRelanSolProsp 	SMALLINT;
DEFINE 	cCteProsp		CHAR(20);
DEFINE 	cNumCteBco		CHAR(20);
DEFINE  iBand			SMALLINT;
DEFINE 	cNumCteRel		CHAR(20);
DEFINE  sSeg2			SMALLINT;
DEFINE  iSecu			INTEGER;
DEFINE  iCont			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE ibanderaMesa     INTEGER;
DEFINE V_telefonocelular LIKE bdinteg:si_telefonos_actual.telefono;
DEFINE vApellPaterno    LIKE bdinteg:si_cliente.apell_paterno;
DEFINE vFechaHoy        DATE;
DEFINE CodRet_regev	    VARCHAR(6);

LET iSecuencia=0;
LET ibanderaMesa=0;

LET iContadorRelanzamiento = 0;
LET iSecOS				= 0;
LET iSolEnviadasOS		= 0;
LET iSeguir				= 0;
LET cSolCoppel      	= "" ;
LET cSolBanco      	 	= "" ;
LET cSolicitud      	= "" ;
LET cTipoSol			= "";
LET iBanderaAutDirecta	= 0;
LET cMensaje			= "";
LET cStatusBan			="";
LET sEs_Coppel			=0;

LET	cOservaciones		="";
LET	cEntre_calles		="";
LET	cEstado				="";
LET	cMunicipio			="";
LET	cCiudad				="";
LET	cColonia			="";
LET	cCalle				="";
LET	cNumeroextcalle		="";
LET	cNumerointcalle		="";

LET	cOservaciones_Act	="";
LET	cEntre_calles_Act	="";
LET	cEstado_Act			="";
LET	cMunicipio_Act		="";
LET	cCiudad_Act			="";
LET	cColonia_Act		="";
LET	cCalle_Act			="";
LET	cNumeroextcalle_Act	="";
LET	cNumerointcalle_Act	="";
LET sSumRelanSol 	    = 0;
LET sRelanSolProsp 		= 0;
LET cCteProsp			="";
LET cNumCteBco			="";

LET dFecha_insert 	= DATE(1);
LET dFecha_resp 	= DATE(1);
LET cNumcte			="";

LET sRelanParam    	 = 0;
LET sRelanSol    	 = 0;
LET iBand			 = 0;
LET cNumCteRel		 = '';
LET sSeg2			 = 0;
LET iSecu			 = 0;
LET iCont			 = 0;
LET pcomentario		 = "";
LET vApellPaterno    = '';
LET vFechaHoy        = '';
LET CodRet_regev	 = 'OOOOOO';

	   --SET DEBUG FILE TO "/informix/Rebeca/sp_os_solicita.out";
	   --TRACE ON;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
        RETURN P_COD_RET;
    END EXCEPTION;

    ON EXCEPTION IN (-535)
        LET wBegin = "S";
        COMMIT WORK;
        BEGIN WORK;
    END EXCEPTION WITH RESUME;

	LET wBegin = "N";
    BEGIN WORK;
	LET P_COD_RET = '000000';

    LET vStatusSol = '??';

	--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    SELECT CURRENT YEAR TO DAY INTO vHoy FROM dual ;

	SELECT MAX(NVL(secuenciaos,0)) --consulta para obtener la secuencia con la que se envio a os calle
		INTO iSecOS
	FROM "informix".ss_solicitud_os
	WHERE status = 'D'
--	AND fecha_solicitud > DATE(1) --VALIDAR
	AND num_solicitud = pnum_solicitud;

    -- VALIDANDO SI LA SOLICITUD ES COPPEL
    IF (SELECT tipo_solicitud FROM "informix".ss_solicitudes WHERE num_solicitud=pnum_solicitud AND status_solicitud='OA')="C" THEN
        -- SI LA SOLICITUD ES COPPEL SE VERIFICA SI EL CLIENTE TIENE UNA SOLICITUD BANCOPPEL
        IF EXISTS(SELECT num_solicitud FROM "informix".ss_solicitud_os WHERE secuenciaos=iSecOS AND num_solicitud in
            (select num_solicitud from bdisolic:ss_solicitudes where numcte in (select numcte from bdisolic:ss_solicitudes where num_solicitud = pnum_solicitud) 
			and num_solicitud <> pnum_solicitud and status_solicitud not in ('RT','AT','AP','CN')))
           THEN 
          -- SI EL CLIENTE CUENTA CON SOLICITUD BANCOPPEL SE OBTIENE EL NUMERO DE SOLICITUD Y SE VALIDAN LOS DOS ESTATUS

			  SELECT a.num_solicitud, a.status_solicitud --COSTEO ALTO
                INTO  cSolBanco, cStatusBan
                FROM  "informix".ss_solicitudes a
                INNER JOIN  "informix".ss_solicitud_os b
                      ON a.empresa=b.empresa AND a.num_solicitud=b.num_solicitud
                WHERE b.secuenciaos=iSecOS AND b.num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where numcte in (select numcte from bdisolic:ss_solicitudes where num_solicitud = pnum_solicitud) and num_solicitud <> pnum_solicitud);

           -- SE VERIFICA QUE LA SOLICITUD ESTE EN UN ESTATUS VALIDO, SI ES OA SE LANZARA BANCO
           IF cStatusBan='OA' THEN
               LET pnum_solicitud=cSolBanco;
           ELIF (cStatusBan<>'RT') AND (cStatusBan<>'AT') AND (cStatusBan<>'AP') THEN
               LET P_COD_RET = '000002';
               LET iSeguir = 1;
           END IF;

        END IF;
		
		LET sEs_Coppel = 1;
    END IF;

	IF  NVL(iSecOS,0) > 0 THEN
			SELECT COUNT(secuenciaos)
 			INTO iSolEnviadasOS
			FROM "informix".ss_solicitud_os
			WHERE status = 'D'
--			AND fecha_solicitud > DATE(1)
			AND num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where numcte in (select numcte from bdisolic:ss_solicitudes where num_solicitud = pnum_solicitud) and status_solicitud = 'OA')
			AND secuenciaos = iSecOS;
			
			IF iSolEnviadasOS > 1 THEN

				FOREACH
					SELECT a.num_solicitud, b.tipo_solicitud --para obtener si el envio OScalle de la solicitud contemplaba una solicitud de coppel
						INTO cSolicitud,cTipoSol
					FROM "informix".ss_solicitud_os a
					INNER JOIN "informix".ss_solicitudes b ON (a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud)
				   WHERE status = 'D'
--					AND fecha_solicitud > DATE(1)
					AND a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where numcte in (select numcte from bdisolic:ss_solicitudes where num_solicitud = pnum_solicitud) and status_solicitud = 'OA')
					AND secuenciaos = iSecOS

					IF cTipoSol = "C" THEN
						LET cSolCoppel = cSolicitud;
					ELSE
						LET cSolBanco = cSolicitud;
						LET pnum_solicitud = cSolicitud;
					END IF;
				END FOREACH;
			END IF;
	END IF;
	
	IF ( SELECT COUNT(ejecutivo) FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pusuario AND sucursal='9700') > 0 THEN
		LET ibanderaMesa = 1;
	
	END IF;
	
	WHILE  iSeguir = 0
		LET iContadorRelanzamiento = iContadorRelanzamiento+1;

		IF iContadorRelanzamiento = 2 THEN
			LET iSeguir = 1;
			LET pnum_solicitud = cSolCoppel;
			LET sEs_Coppel = 1;
		END IF;

		    SELECT TRIM (status_solicitud) , numcte INTO vStatusSol , cNumcte
		    FROM "informix".ss_solicitudes 
		    WHERE empresa = pempresa
		    AND num_solicitud = pnum_solicitud;

		   -- ANALIZAR LA POSIBILIDAD DE REENVIAR LAS SOLIC RECHAZADAS, IDENTIFICANDO CUALES PROCEDEN.
		    IF vStatusSol NOT IN  ('CC', 'OA') THEN
		        IF vStatusSol IN ('EE', 'OS') THEN
		            LET P_COD_RET = '000001';  -- YA HAY UNA OS EN PROCESO ACTUALMENTE
		        ELSE
					IF vStatusSol IN ("AT","AP") AND pnum_solicitud = cSolCoppel THEN
						IF NOT EXISTS (SELECT  num_solicitud FROM "informix".ss_os_solautdirecta WHERE num_solicitud = pnum_solicitud) THEN
							LET P_COD_RET = '000002';  --Estatus actual no valido para solicitar OS
						ELSE
							LET iBanderaAutDirecta = 1;
							LET cMensaje= "S50 Supervisar, Autorizacion Automatica";
						END IF;
					ELSE
						LET P_COD_RET = '000002';  -- ESTATUS ACTUAL NO VALIDO PARA SOLICITAR OS
					END IF;
		        END IF;
		 	END IF;

		    SELECT COUNT(*) INTO iCuantos FROM "informix".ss_solicitud_os WHERE num_solicitud = pnum_solicitud AND status = 'S';
		    IF iCuantos >0 THEN
		        LET P_COD_RET = '000003';  --YA HAY UNA SOLICITUD DE OS EN ESPERA DE SER PROCESADA.
		       --SI HUBIESE ALGUNA EN ESTATUS 'S',  SI ESTA EN S ES PORQUE NO HA LLEGADO A LA HORA DEL CRON, O PORQUE
		       --POR ALGUN MOTIVO ESTÃ TRONANDO LA INTEGRACION DE DATOS. PARA QUE METER OTRA???
		    END IF;
						
			IF sEs_Coppel = 1 THEN
			
			
				SELECT DISTINCT(COUNT(fecha_entrada)) INTO sRelanSol
				FROM  bdisolic: "informix".ss_autorizacion 
				WHERE  num_solicitud = pnum_solicitud AND status_solicitud  = 'OS';
				
				SELECT valor  INTO sRelanParam
				FROM  bdisolic: "informix".ss_param WHERE secuencia = 155;
				
				--OBTENER EL CLIENTE BANCO PARA IR A BUSCARLO EN LA PR_CLIENTE PARA DETERMINAR SI TUVO COMO ORIGEN CLIENTE PROSPECTO.
				SELECT numcte
				INTO cNumCteBco					
				FROM "informix".ss_solicitudes
				WHERE num_solicitud = pnum_solicitud;
				
				IF 	NVL(cNumCteBco,"") <> ""  THEN
				
					SELECT numcte_pros
					INTO cCteProsp
					FROM bdiprospectos:"informix".pr_cliente 
					WHERE empresa = pempresa 
						AND numcte = cNumCteBco
						AND tipo_cliente = 3;
					
					IF NVL(cCteProsp,"") <> "" THEN
					
						SELECT COUNT(num_solicitud)
						INTO sRelanSolProsp
						FROM bdiprospectos:"informix".pr_autorizacion
						WHERE empresa = pempresa 
						AND num_solicitud = cCteProsp
						AND status_solicitud = 'OS';
					END IF;	
				END IF;	
				
				LET sSumRelanSol = sRelanSol + NVL(sRelanSolProsp ,0) ;
				
				IF sSumRelanSol >= sRelanParam THEN
				
					SELECT numcte INTO cNumcte				
					FROM  bdisolic: "informix".ss_solicitudes 
					WHERE num_solicitud = pnum_solicitud;
				
					SELECT fecha_insert INTO dFecha_insert				
					FROM  bdinteg: "informix".si_direcciones_actual 
					WHERE numcte = cNumcte AND tipo_dir = 1;

					SELECT fecha_respuesta INTO dFecha_resp
					FROM bdisolic: "informix".ss_solicitud_os
					WHERE num_solicitud = pnum_solicitud
					AND fecha_solicitud = (SELECT MAX(fecha_solicitud)  
						FROM bdisolic: "informix".ss_solicitud_os
						WHERE num_solicitud = pnum_solicitud);
					
					LET dFecha_insert = NVL(dFecha_insert,'01/01/1900');
					LET dFecha_resp = NVL(dFecha_resp,'01/01/1900');
					
					--IF (NVL(dFecha_insert,'01/01/1900')) >= (NVL(dFecha_resp,'01/01/1900')) THEN
					IF dFecha_insert >= dFecha_resp THEN					 
						LET iSecu = 0;
						FOREACH							
							SELECT secuencia 
							INTO iSecu
							FROM bdinteg:"informix".si_direcciones 
							WHERE tipo_dir = 1 AND numcte = cNumcte 
							ORDER BY  secuencia DESC
							
							LET iCont = iCont + 1;
							IF iCont = 2 THEN
								EXIT FOREACH;
							END IF;
						END FOREACH;
						
						SELECT observaciones,entre_calles,estado,municipio,numerociudad,numerocolonia,numerocalle,numeroextcalle,numerointcalle 
						INTO cOservaciones,cEntre_calles,cEstado,cMunicipio,cCiudad,cColonia,cCalle,cNumeroextcalle,cNumerointcalle
						FROM bdinteg: "informix".si_direcciones 
						WHERE numcte = cNumcte
						AND secuencia = iSecu
						AND tipo_dir = '1';

						SELECT observaciones,entre_calles,estado,municipio,numerociudad,numerocolonia,numerocalle,numeroextcalle,numerointcalle 
						INTO cOservaciones_Act,cEntre_calles_Act,cEstado_Act,cMunicipio_Act,cCiudad_Act,cColonia_Act,cCalle_Act,cNumeroextcalle_Act,cNumerointcalle_Act
						FROM bdinteg: "informix".si_direcciones_actual WHERE numcte = cNumcte AND tipo_dir = 1;
						
						IF (cOservaciones <> cOservaciones_Act) OR (cEntre_calles <> cEntre_calles_Act)
						 OR (cEstado <> cEstado_Act) OR (cMunicipio <> cMunicipio_Act) OR (cCiudad <> cCiudad_Act)
						 OR (cColonia <> cColonia_Act) OR (cCalle <> cCalle_Act) OR (cNumeroextcalle <> cNumeroextcalle_Act) OR (cNumerointcalle <>cNumerointcalle_Act) THEN
						 	LET P_COD_RET = '000000';
						ELSE 
							LET P_COD_RET = '000004';							LET iBand = 1;
							EXIT;						
						END IF;
					ELSE
						LET P_COD_RET = '000004';						LET iBand = 1;
						EXIT;
					END IF;
				END IF;
			END IF;
						
		    IF (P_COD_RET ='000000') THEN
		        ---ROLLBACK WORK;
				--RETURN P_COD_RET;
		    --END IF;
				--POR AHORA NO SE VALIDA QUE NO EXISTA ALGUNA OS PENDIENTE DE RESPUESTA (YA ENVIADA A COPPEL), PARA PEDIR OTRA, PARA DAR LA FLEXIBILIDAD
			        --DE SOLICITAR UNA NUEVA, SUPONIENDO QUE LA ANTERIOR IBA CON DATOS ERRONEOS O YA SE DA POR PERDIDA, SI TIENE MUCHOS DIAS.
			        --ESTAS VALIDACIONES YA ESTAN DENTRO DEL SP_OS_INTEGRACION

			    INSERT INTO "informix".ss_solicitud_os (empresa,  num_solicitud,  fecha_solicitud, status, usuario_solicita, observacion1)
			    VALUES                      (pempresa, pnum_solicitud, CURRENT,'S',  NVL(pusuario, 'sistema'),cMensaje);

				LET cMensaje= "";

				IF iBanderaAutDirecta = 0 THEN

					SELECT max(fecha_entrada)
					INTO dFechaEnt
					FROM "informix".ss_autorizacion
					WHERE num_solicitud  = pnum_solicitud
					AND status_solicitud = vStatusSol;

					UPDATE "informix".ss_autorizacion
					SET fecha_salida = vHoy
					WHERE num_solicitud  = pnum_solicitud
					AND status_solicitud = vStatusSol
					AND fecha_entrada    = dFechaEnt;

				    IF vStatusSol = 'CC' THEN
				       LET pComentario = 'Solicitud Enviada a Orden de Supervision';
				    ELIF vStatusSol = 'OA' THEN
				       LET pComentario = 'Re-Enviada a Orden de Supervision';
					   
						IF vStatusSol = 'OA' THEN --RQM 09 474 -2
							IF (SELECT COUNT(numcte) FROM "informix".ss_solicitudes WHERE	numcte = cNumcte AND num_solicitud = pnum_solicitud) >0  THEN							
							
									SELECT NVL(telact.telefono,''), NVL(d.apell_paterno,'')
									INTO V_telefonocelular, vApellPaterno
									FROM bdinteg:"informix".si_cliente d
									LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual telact ON ( d.numcte = telact.numcte AND telact.tipo_tel = 2)									 
									WHERE d.numcte = cNumcte 
									AND telact.telefono IN (SELECT telefono FROM bdinteg:"informix".si_telefonos tel WHERE telact.telefono = tel.telefono 
									AND telact.numcte = tel.numcte AND d.numcte = tel.numcte AND tel.verificado = 'V' AND tel.tipo_tel = 2);

									IF V_telefonocelular <> "" OR  V_telefonocelular IS NOT NULL THEN
											
			                   			    CALL bdimnsj:"informix".sp_registra_evento('2','CRED_SMS','NOTIF_OA_SMS',cNumcte,pnum_solicitud,'','2',vApellPaterno,'','','','','','','','','','',V_telefonocelular,0,0,0,0,0,current,current)  
											RETURNING CodRet_regev;		
										IF CodRet_regev = '000000' THEN LET P_COD_RET = '000000'; END IF;	
									END IF;
							END IF;
						END IF;
				    END IF;

				    LET vStatusSol = 'EE';

					UPDATE "informix".ss_solicitudes SET status_solicitud = vStatusSol
					 WHERE empresa = pempresa
					   AND num_solicitud = pnum_solicitud;

					INSERT INTO "informix".ss_autorizacion
						(empresa, ejecutivo_auto, num_solicitud, status_solicitud,
						comentario, fecha_entrada, fecha_salida)
					VALUES
						(pempresa, nvl(pusuario, 'sistema'), pnum_solicitud, vStatusSol,
						 pComentario, vHoy, vHoy);
						 		--Se modifica para registrar en la tabla de mesa de control que la solicitud fue enviada por un analista de mesa.
		
						IF ibanderaMesa = 1  THEN
						
							SELECT MAX(secuencia+1) 
							INTO iSecuencia 
							FROM "informix".ss_autorizacion_especial 
							WHERE empresa=pempresa 
							AND num_solicitud=pnum_solicitud;	


							INSERT INTO "informix".ss_autorizacion_especial
							(empresa,num_solicitud,numcte,secuencia,comentario,causa_solicitud,montolinea_ant,montolinea_nvo,status_ant,status_nvo,usuario_modif,fecha_modif,tipo_movimiento ) 
							VALUES(pempresa,pnum_solicitud,cNumcte,NVL(iSecuencia,1),pComentario,'',0,0,'OA',vStatusSol,pusuario,today,'');
							
						END IF
					END IF;	 
			END IF;
			IF NVL(cSolCoppel,"") = "" OR NVL(iSecOS,0) = 0 THEN -- EN CASO DE CONTAR CON LA SOLICITUD DE COPPEL SE VUELVE A INICIAR EL PROCESO PARA RELANZAR LA SOLICITUD
				LET iSeguir = 1;
			END IF;
			IF iSolEnviadasOS > 1  THEN
				LET P_COD_RET = '000000';  -- ESTATUS ACTUAL NO VALIDO PARA SOLICITAR OS
			END IF;
	END WHILE;
	
	IF (iBand = 1) THEN
		LET P_COD_RET = '000004';
	END IF;

	IF P_COD_RET = '000000' THEN
		COMMIT WORK;
	ELSE
		ROLLBACK WORK;
	END IF;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;

    RETURN P_COD_RET;
END;
END PROCEDURE;