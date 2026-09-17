CREATE PROCEDURE "informix".sp_asigna_solicitud_soc(pEmpresa CHAR(3), pEjecutivoAtiende CHAR(8), pBandera CHAR(1))
RETURNING
	CHAR(6) 		AS CodRet,
	CHAR(20) 		AS NumSolicitud,
	CHAR(20) 		AS NumCte;
	
-------------------------------------------------------------------------------------------------------------
-- CONTROL DE CAMBIOS	
-------------------------------------------------------------------------------------------------------------
-- Modific : Gabriela Esmeralda Gonz lez B  ez
-- Fecha de Modificaci n: 11-02-2019
-- Descripci n: Se modifica el flujo de las solicitudes 
--              para clientes con solicitudes previas canceladas por mesa de control.
-- RQ: RQM 09 501 - Implementaci n - Flujo para Clientes con Solicitudes Canceladas en Mesa de Control.
-- CC Rational: 29749 
-------------------------------------------------------------------------------------------------------------

---DECLARACIONES
DEFINE cCodRet			CHAR(6);
DEFINE cCodRet2			CHAR(6);
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);

-- VARIABLES DEL PROCESO
DEFINE cNumSolicitud	CHAR(20);
DEFINE cNumCte			CHAR(20);
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
DEFINE cRevisado		CHAR(1);
DEFINE cTimeTranscurrido	CHAR(40);
DEFINE sDiasTransc		SMALLINT;
DEFINE cHorasTransc		CHAR(10);
DEFINE iTmpMaxMostrar	SMALLINT;
DEFINE iDiaCambio		SMALLINT;
DEFINE cMinTransc		CHAR(10);
DEFINE cMinutosMax		CHAR(10);
DEFINE iPaso			INTEGER;
DEFINE vHoraActual 		DATETIME HOUR TO SECOND;
DEFINE vHoraAnterior 	DATETIME HOUR TO SECOND;
DEFINE dfecha 			DATE;
DEFINE cHora 			CHAR(10);
DEFINE cMensaje 		CHAR(80);
DEFINE cStatusNuevo 	CHAR(2);
DEFINE cStatusMovil 	CHAR(1);
DEFINE cRegion 			CHAR(1); 
DEFINE cIdBox 			CHAR(1);
DEFINE cScore 			DECIMAL(18,2);
DEFINE cPrioridad 		INTEGER; -- GEGB 20190211 RQM 09 501
--APR
DEFINE cValor_alfabetico CHAR(100);
DEFINE cFLagGeoMov         CHAR(1);
DEFINE cFolioMovil         CHAR(20);
DEFINE cNumCteBco			CHAR(20);
DEFINE cCteProsp   			CHAR(20);
DEFINE cStatusSolic			CHAR(2);
DEFINE cDesStatusCtePros	CHAR(40);
DEFINE cClientePros			CHAR(1);
DEFINE sBanAuto		    	SMALLINT;
DEFINE cStatusRespOs		CHAR(1);
DEFINE cDiaVigencia  		CHAR(2);
DEFINE cStatusPr			CHAR(2);
DEFINE iSecuenciaOs         INTEGER;
DEFINE cNuevoStatus         CHAR(2);
DEFINE cMensajeStatus       CHAR(80);
DEFINE iPros		        INTEGER;
DEFINE iProsOS		        INTEGER;
DEFINE cNumPros2			CHAR(20);
DEFINE cStatusOS2			CHAR(1);
DEFINE cDescEstatustit      CHAR(50);	
DEFINE cMot					INTEGER;

DEFINE cClaveSup			CHAR(1);
DEFINE cBand_clave			CHAR(1);
DEFINE cStatus_vig			CHAR(2);
DEFINE dFecha_Ent			DATE;
DEFINE dFecha_Hoy			DATE;
DEFINE sDias_Vig			SMALLINT;
DEFINE cNumProd				CHAR(4);
DEFINE cVigenciaVencida		INTEGER;
DEFINE vdiastrans INTEGER;
DEFINE cNumSolOs CHAR(20);
DEFINE cGeoCte CHAR (20);
DEFINE dFechaVencimiento DATE;
DEFINE cTipoSol CHAR(1);

--- RQM 09492
DEFINE iValido                  INTEGER;
DEFINE v_valor                  DECIMAL(14,2);
DEFINE cMensajeRet              CHAR(100);   
DEFINE cCodRetComp		        CHAR(6);
DEFINE ven_transacc             INTEGER;
DEFINE nuevasol                 SMALLINT;
DEFINE entrof                   SMALLINT;
DEFINE cSQL       CHAR(200);
DEFINE iCompingreso  INTEGER;
DEFINE isolcomp  INTEGER;

-- RQM 09632
DEFINE cCompParametrico     CHAR(2);

--PV 1005900 - Comprobante de ingresos - Nuevas variables para logica de comprobante de ingresos
DEFINE v_tiempo_espera CHAR(10);
DEFINE v_tiempo_valor  CHAR(20);
DEFINE v_fecha_creacion CHAR(20);

-- INICIALIZACIONES
LET cCodRet				= '000000';
LET cCodRet2			= '000000';
LET iSqlErr				= 0;
LET iSamErr				= 0;
LET cErrorInfo			= '';

-- INICIALIZACION DE VARIABLES DEL PROCESO.
LET cNumSolicitud		= '';
LET cNumCte				= '';
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
LET cRevisado			= 'N';
LET cTimeTranscurrido	= '';
LET sDiasTransc			= 0;
LET cHorasTransc		= '00:00:00';
LET iTmpMaxMostrar		= 0;
LET iDiaCambio			= 0;
LET cMinTransc			= '00:00:00';
LET cMinutosMax			= '';
LET iPaso				= 0;
LET cDescEstatustit		= '';

LET cClaveSup			= '';
LET cBand_clave			= '';
LET cStatus_vig			= '';
LET dFecha_Hoy			= DATE(1);
LET dFecha_Ent			= DATE(1);
LET sDias_Vig			= 0;
LET cNumProd	  		= "";
LET cVigenciaVencida	= 0;
	
LET vHoraActual 		= CURRENT;
LET dfecha 				= today;
LET cMensaje 			= "";
LET cStatusNuevo 		= "";
LET cStatusMovil 		= "";
LET cFLagGeoMov 		= '';
LET cFolioMovil 		= '';
LET cRegion 			= ''; 
LET cIdBox 				= '';
LET cScore 				= 0.00;
LET cPrioridad 			= 0; -- GEGB 20190211 RQM 09 501

--APR
LET cValor_alfabetico 	= "";
LET cNumCteBco  		= "";
LET cCteProsp  			= "";
LET cStatusSolic  		= "";
LET cDesStatusCtePros 	= "";
LET cClientePros 		= "";
LET sBanAuto  			= 0;
LET cStatusRespOs 		= "";
LET cDiaVigencia 		= "00";
LET cStatusPr 			= "";
LET iSecuenciaOs   		= 0;
LET cNuevoStatus   		= "";
LET cMensajeStatus 		= "";
LET iPros				= 0;
LET iProsOS				= 0;
LET cNumpros2			='';
LET cStatusOS2			='S';
LET cMot				= 0;

LET vdiastrans 			= 0;
LET cNumSolOs 			= '';	
LET cGeoCte 			= '';
LET dFechaVencimiento 	= DATE(1);
LET cTipoSol 			= '';
--RQM 09 492
LET v_valor             = 0;
LET cMensajeRet         = '';
LET iValido             = 0;
LET cCodRetComp		    = '000000';
LET ven_transacc        = 0;
LET nuevasol            = 0;
LET entrof              = 0;
LET cSQL                = '';
LET iCompingreso = 0;
LET isolcomp = 0;

-- RQM 09632
LET cCompParametrico = '0';
--PV 1005900 - Comprobante de ingresos - Inicializacion nuevas variables
LET v_tiempo_espera = '';
LET v_fecha_creacion = '';
LET v_tiempo_valor ='';
		
BEGIN

	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr::CHAR(8);
            LET cCodRet = '000002'; -- 
            RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,'');

		END IF;
	END EXCEPTION; 
	
	ON EXCEPTION IN (-535)
		LET ven_transacc = 1;
		COMMIT;
		BEGIN;
	END EXCEPTION WITH RESUME;

    --SET DEBUG FILE TO "/home/e10001202/PV1005900/sp_asigna_solicitud_soc.out";
	--TRACE ON; 
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF NVL(pEmpresa, "") = "" OR NVL(pEjecutivoAtiende, "") = "" OR pBandera='' THEN
		LET cCodRet = "000001"; -- PARAMETROS OBLIGATORIOS.
        RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,'');	
    END IF;
	
	-- OBTENEMOS EL VALOR DE HORAS MAXIMO PARA MOSTRAR LAS SOLICITUDES MC.
	SELECT valor_numerico  INTO iTmpMaxMostrar FROM bdicobranza:"informix".cb_param_campania 
	WHERE tipo_campania = '56' AND grupo_parametro = 'MCTRLINEA' AND num_parametro = '1';
	
	-- LIMITE DE TIEMPO MAXIMO PARA SER ATENDIDA UNA SOLICITUD EN PANTALLA CCONCAC.
	SELECT valor_alfabetico,valor_numerico INTO cMinutosMax,iDiaCambio FROM bdicobranza:"informix".cb_param_campania 
	WHERE tipo_campania = '56' AND grupo_parametro = 'MCTRLINEA' AND num_parametro = '2';	
    --LET cHora = vHoraActual - '00:10:00';
	
	LET cHora = vHoraActual - TRIM(cMinutosMax)::DATETIME HOUR TO SECOND; 
	LET vHoraAnterior = cHora;
	
	-- PV 1005900 - Comprobante de ingresos - Obtener tiempo de espera configurado para digitalizacion
    SELECT nvl(valor,'00:05:00')
    INTO v_tiempo_valor
    FROM bdisolic:ss_param
    WHERE secuencia=107;

    LET v_tiempo_espera = TRIM(v_tiempo_valor)::DATETIME HOUR TO SECOND;

    BEGIN WORK;

        DELETE FROM "informix".ss_cte_procesando WHERE usuario = pEjecutivoAtiende;

        UPDATE  bdisolic:ss_solicitudes_mc SET ejecutivo_atiende ='' WHERE ejecutivo_atiende = pEjecutivoAtiende AND status_fin = '' AND revisado <> 'S';
	IF pBandera =2 THEN 
        --    WHILE nuevasol = 0 
		LET nuevasol = 0;
		LET entrof = 0;
        FOREACH
            SELECT a.num_solicitud, a.numcte, a.sucursal, 1 region,
            DECODE (NVL(b.numcte,0), 0, 0, 1) idbox,
                 NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1 AND c.evalua_cc = '0' AND evaluacion >=0),0) + 
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc = '0' AND num_solicitud in (SELECT num_solicitud FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1  AND c.evalua_cc = '0' AND evaluacion < 0)),0) +
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc <> '0'),0) score,					
                a.prioridad, a.num_producto, (SELECT  count(d.num_solicitud) FROM bdisolic:"informix".ss_solicitudes_mc d 			 
             inner join bdidigital@coppelimg_app:dg_expediente e ON (d.numcte = e.cliente AND d.num_solicitud = e.cuenta)
             inner join bdidigital@coppelimg_app:dg_tipodocumento t ON (e.cod_docto = t.cod_docto and t.cod_grupo = '006')
			WHERE d.num_solicitud = a.num_solicitud ) as comprobante
            INTO cNumSolicitud, cNumCte, cSucursal,cRegion,cIdBox, cScore, cPrioridad, cNumProd, iCompingreso
            FROM bdisolic:"informix".ss_solicitudes_mc a 			 
            LEFT OUTER JOIN bdinteg:si_bitacora_ife b ON ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
            LEFT OUTER JOIN bdisolic:ss_resum_scor_fin c ON (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud)
            WHERE a.empresa = pEmpresa
            AND status_ini = 'MC' AND status_fin = ""
            /*AND a.sucursal IN 
            (SELECT sucursal
             FROM bdinteg:si_sucursales a, bdinteg:si_catciudades b
             WHERE a.ciudad = b.numerociudad 
             AND tpo_sucursal = 'S'
             AND numero_region IN('5','10','14','666','13'))*/
             AND ejecutivo_atiende = ''
			AND a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where status_solicitud = 'MC') 			
            /*UNION ALL
            SELECT a.num_solicitud, a.numcte, a.sucursal, 2 region,
            DECODE (NVL(b.numcte,0), 0, 0, 1) idbox,
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1 AND c.evalua_cc = '0' AND evaluacion >=0),0) + 
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc = '0' AND num_solicitud in (SELECT num_solicitud FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1  AND c.evalua_cc = '0' AND evaluacion < 0)),0) +
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc <> '0'),0) score,					
                a.prioridad, a.num_producto,(SELECT  count(d.num_solicitud) FROM bdisolic:"informix".ss_solicitudes_mc d 			 
             inner join bdidigital@coppelimg_app:dg_expediente e ON (d.numcte = e.cliente AND d.num_solicitud = e.cuenta)
             inner join bdidigital@coppelimg_app:dg_tipodocumento t ON (e.cod_docto = t.cod_docto and t.cod_grupo = '006')
			WHERE d.num_solicitud = a.num_solicitud ) as comprobante
            FROM bdisolic:"informix".ss_solicitudes_mc a 			 
            LEFT OUTER JOIN bdinteg:si_bitacora_ife b ON ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
            LEFT OUTER JOIN bdisolic:ss_resum_scor_fin c ON (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud)
            WHERE a.empresa = pEmpresa
            AND status_ini = 'MC' 
            AND status_fin = ""
            AND ejecutivo_atiende = ''
            AND a.sucursal IN 
            (SELECT sucursal
             FROM bdinteg:si_sucursales a, bdinteg:si_catciudades b
             WHERE a.ciudad = b.numerociudad 
             AND tpo_sucursal = 'S'
             AND numero_region NOT IN('5','10','14','666','13'))
			AND a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where status_solicitud = 'MC')*/ 
            ORDER BY 9 ASC, 8 ASC, 7 DESC, 6 ASC ,4 ASC ,5 ASC

            --			LET cSQL = 'sleep 20';
            --            SYSTEM cSQL;
            
            -- PV 1005900 - Comprobante de ingresos - Query que me trae el valor del parametrico para su posterior validacion
            SELECT elemento
            INTO cCompParametrico
            FROM bdisolic:"informix".ss_detalle_scoring
            WHERE empresa = '001'
            AND seccion = '2'
            AND grupo = '38'
            AND tpo_persona = '01' 
            AND num_solicitud = cNumSolicitud;
			
			
            --PV 1005900 - Comprobante de ingresos -Valido Si el cliente dijo que si tiene comprobante en el parametrico(cCompParametrico <> 1)
			IF cCompParametrico <> 1 THEN
			
                --PV 1005900 - Query que me trae el conteo entre el cruce de dg_expediente con dg_tipodocuemnto para ver si hay documento digitalizado
               SELECT COUNT(*)
                INTO iCompingreso
                FROM bdidigital@coppelimg_app:dg_expediente e
                INNER JOIN bdidigital@coppelimg_app:dg_tipodocumento t ON (e.cod_docto = t.cod_docto AND t.cod_grupo = '006')
                WHERE e.cliente = cNumCte AND e.cuenta = cNumSolicitud;
				
				--PV 1005900 - Validacion en caso de que el documento no este digitalizado.
                IF iCompingreso = 0 THEN  
                    
					--PV 1005900 - Query para corroborrar cual fue el ultimo estado de la solicitud y obtener la fecha con hora de la misma
					SELECT MAX(ss_a.fecha_hora) INTO v_fecha_creacion 
                    FROM bdisolic:"informix".ss_autorizacion AS ss_a
					INNER JOIN bdisolic:"informix".ss_solicitudes AS ss_s ON ss_a.num_solicitud = ss_s.num_solicitud AND ss_a.status_solicitud = ss_s.status_solicitud
					WHERE ss_s.status_solicitud IN('MC','LC') 
                    AND ss_s.num_solicitud = cNumSolicitud;

					  IF (CURRENT - TRIM(v_fecha_creacion)::DATETIME YEAR TO SECOND) < (INTERVAL(0) DAY TO DAY + TRIM(v_tiempo_espera):: INTERVAL HOUR TO SECOND) THEN
                        CONTINUE FOREACH; --PV 1005900 - No ha pasado el tiempo de espera (5min), omitir solicitud
                    END IF;
                    
                END IF;
            END IF;

        -- MARCAMOS LA SOLICITUD QUE SE ESTA ATENDIENDO.
            UPDATE "informix".ss_solicitudes_mc SET ejecutivo_atiende = pEjecutivoAtiende WHERE num_solicitud = cNumSolicitud AND sucursal = cSucursal and revisado <> 'S' and ejecutivo_atiende = '';	

            IF DBINFO("sqlca.sqlerrd2") > 0 THEN
                INSERT INTO "informix".ss_cte_procesando(numcte, usuario, fecha_insercion, hora_insercion)
                VALUES(cNumCte, pEjecutivoAtiende, CURRENT, CURRENT HOUR TO SECOND);
				
				--RQM101432-4vr2 Se contempla para cuando sea prestamo y se vaya autorizar actualizar la informacion de linea superior	
				SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = cNumSolicitud;
				IF cNumProd NOT IN ('6001','6500')  AND iCompingreso > 0 THEN  		  
					--SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = cNumSolicitud; SE CAMBIA 2 LINEAS ARRIBA PARA EVITAR MAS DE 1 INSERT A LA SS_SOLICITUDES_CAC
					IF isolcomp = 0 THEN
						INSERT INTO "informix".ss_solicitudes_cac (empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
						VALUES (pEmpresa, cNumSolicitud, cNumcte,csucursal, cNumProd, 'MC', pEjecutivoAtiende, pEjecutivoAtiende, "S", cMensaje, "N", dcMontoSolic, CURRENT,CURRENT, CURRENT, 'S');	
					ELSE
						UPDATE  "informix".ss_solicitudes_cac SET  status = 'MC', ejecutivo_atiende = pEjecutivoAtiende, ejecutivo_autoriza= pEjecutivoAtiende, comprobante_valido= 'S', observaciones = cMensaje WHERE num_solicitud = cNumSolicitud;
					END IF;
				ELIF cNumProd IN ('6001')  AND iCompingreso > 0 THEN  	
					IF isolcomp = 0 THEN
							INSERT INTO "informix".ss_solicitudes_cac 
							(empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
							VALUES (pEmpresa, cNumSolicitud, cNumcte,csucursal, cNumProd, 'MC', pEjecutivoAtiende, "", "S", cMensaje, "S", v_valor, CURRENT,CURRENT, DATE(1), "S");												
					ELSE
						UPDATE  "informix".ss_solicitudes_cac SET  status = 'MC', ejecutivo_atiende = pEjecutivoAtiende, comprobante_valido= 'N', comprobante_valido_cac= 'N' WHERE num_solicitud = cNumSolicitud;
					END IF;								
				END IF;

				LET nuevasol = 1;
				LET entrof = 1;	
				
                EXIT FOREACH;
            END IF;
			
        END FOREACH;

        --IF (DBINFO("sqlca.sqlerrd2") = 0 AND nuevasol = 0 and entrof = 0)  THEN
		IF (nuevasol = 0 and entrof = 0)  THEN
			LET cNumSolicitud = '';
			LET cNumCte = '';
			LET cCodRet = '000002'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.
			LET nuevasol = 2;
		END IF;
		 
	END IF;
	
	IF pBandera =1 THEN 

		LET nuevasol = 0;
		LET entrof = 0;
        FOREACH
        SELECT num_solicitud,numcte,sucursal,region,idbox,score,prioridad,num_producto, comprobante
           INTO cNumSolicitud, cNumCte, cSucursal,cRegion,cIdBox, cScore, cPrioridad,cNumProd, iCompingreso
			FROM (
            SELECT  a.num_solicitud, a.numcte, a.sucursal, 1 region,
            DECODE (NVL(b.numcte,0), 0, 0, 1) idbox,
                 NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1 AND c.evalua_cc = '0' AND evaluacion >=0),0) + 
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc = '0' AND num_solicitud in (SELECT num_solicitud FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1  AND c.evalua_cc = '0' AND evaluacion < 0)),0) +
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc <> '0'),0) score,					
                a.prioridad, a.num_producto, (SELECT  count(d.num_solicitud) FROM bdisolic:"informix".ss_solicitudes_mc d 			 
             inner join bdidigital@coppelimg_app:dg_expediente e ON (d.numcte = e.cliente AND d.num_solicitud = e.cuenta)
             inner join bdidigital@coppelimg_app:dg_tipodocumento t ON (e.cod_docto = t.cod_docto and t.cod_grupo = '006')
			WHERE d.num_solicitud = a.num_solicitud ) as comprobante
           -- INTO cNumSolicitud, cNumCte, cSucursal,cRegion,cIdBox, cScore, cPrioridad,cNumProd
            FROM bdisolic:"informix".ss_solicitudes_mc a 			 
            LEFT OUTER JOIN bdinteg:si_bitacora_ife b ON ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
            LEFT OUTER JOIN bdisolic:ss_resum_scor_fin c ON (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud)
            WHERE a.empresa = pEmpresa
            AND status_ini = 'MC' AND status_fin = ""
            /*AND a.sucursal IN 
            (SELECT sucursal
             FROM bdinteg:si_sucursales a, bdinteg:si_catciudades b
             WHERE a.ciudad = b.numerociudad 
             AND tpo_sucursal = 'S'
             AND numero_region IN('5','10','14','666','13'))*/
             AND ejecutivo_atiende = ''
			AND a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where status_solicitud = 'MC') 
			/*--AND a.num_solicitud in (SELECT  distinct num_solicitud FROM bdisolic:"informix".ss_solicitudes_mc a 			 
            --inner join bdidigital@coppelimg_app:dg_expediente e ON (a.numcte = e.cliente)
            --inner join bdidigital@coppelimg_app:dg_tipodocumento t ON (e.cod_docto = t.cod_docto and t.cod_grupo = '006'))	
            UNION ALL
            SELECT a.num_solicitud, a.numcte, a.sucursal, 2 region,
            DECODE (NVL(b.numcte,0), 0, 0, 1) idbox,
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1 AND c.evalua_cc = '0' AND evaluacion >=0),0) + 
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc = '0' AND num_solicitud in (SELECT num_solicitud FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1  AND c.evalua_cc = '0' AND evaluacion < 0)),0) +
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc <> '0'),0) score,					
                a.prioridad,a.num_producto, (SELECT  count(d.num_solicitud) FROM bdisolic:"informix".ss_solicitudes_mc d 			 
             inner join bdidigital@coppelimg_app:dg_expediente e ON (d.numcte = e.cliente AND d.num_solicitud = e.cuenta)
             inner join bdidigital@coppelimg_app:dg_tipodocumento t ON (e.cod_docto = t.cod_docto and t.cod_grupo = '006')
			WHERE d.num_solicitud = a.num_solicitud ) as comprobante
            FROM bdisolic:"informix".ss_solicitudes_mc a 			 
            LEFT OUTER JOIN bdinteg:si_bitacora_ife b ON ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
            LEFT OUTER JOIN bdisolic:ss_resum_scor_fin c ON (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud)
            WHERE a.empresa = pEmpresa
            AND status_ini = 'MC' 
            AND status_fin = ""
            AND ejecutivo_atiende = ''
            AND a.sucursal IN 
            (SELECT sucursal
             FROM bdinteg:si_sucursales a, bdinteg:si_catciudades b
             WHERE a.ciudad = b.numerociudad 
             AND tpo_sucursal = 'S'
             AND numero_region NOT IN('5','10','14','666','13'))
			AND a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where status_solicitud = 'MC') */
			)
        ORDER BY 9 DESC,CASE 
						WHEN num_producto IN (select num_producto from bdicnweb:"informix".sw_mc_productosmc) THEN 1
						ELSE 2 
						END, 8 DESC, 7 DESC, 6 ASC ,4 ASC ,5 ASC	-- GEGB 20190211 RQM 09 501		  

--			LET cSQL = 'sleep 20';
--            SYSTEM cSQL;

        -- PV 1005900 - Comprobante de ingresos - Query que me trae el valor del parametrico para su posterior validacion
            SELECT elemento
            INTO cCompParametrico
            FROM bdisolic:"informix".ss_detalle_scoring
            WHERE empresa = '001'
            AND seccion = '2'
            AND grupo = '38'
            AND tpo_persona = '01' 
            AND num_solicitud = cNumSolicitud;
			
			--PV 1005900 - Comprobante de ingresos -Valido Si el cliente dijo que si tiene comprobante en el parametrico(cCompParametrico <> 1)
			IF cCompParametrico <> 1 THEN
			
                --PV 1005900 - Query que me trae el conteo entre el cruce de dg_expediente con dg_tipodocuemnto para ver si hay documento digitalizado
               SELECT COUNT(*)
                INTO iCompingreso
                FROM bdidigital@coppelimg_app:dg_expediente e
                INNER JOIN bdidigital@coppelimg_app:dg_tipodocumento t ON (e.cod_docto = t.cod_docto AND t.cod_grupo = '006')
                WHERE e.cliente = cNumCte AND e.cuenta = cNumSolicitud;
				
				--PV 1005900 - Validacion en caso de que el documento no este digitalizado.
                IF iCompingreso = 0 THEN  
                    
					--PV 1005900 - Query para corroborrar cual fue el ultimo estado de la solicitud y obtener la fecha con hora de la misma
					SELECT MAX(ss_a.fecha_hora) INTO v_fecha_creacion 
                    FROM bdisolic:"informix".ss_autorizacion AS ss_a
					INNER JOIN bdisolic:"informix".ss_solicitudes AS ss_s ON ss_a.num_solicitud = ss_s.num_solicitud AND ss_a.status_solicitud = ss_s.status_solicitud
					WHERE ss_s.status_solicitud IN('MC','LC') 
                    AND ss_s.num_solicitud = cNumSolicitud;

					  IF (CURRENT - TRIM(v_fecha_creacion)::DATETIME YEAR TO SECOND) < (INTERVAL(0) DAY TO DAY + TRIM(v_tiempo_espera):: INTERVAL HOUR TO SECOND) THEN
                        CONTINUE FOREACH; --PV 1005900 - No ha pasado el tiempo de espera (5min), omitir solicitud
                    END IF;
                    
                END IF;
            END IF;


        -- MARCAMOS LA SOLICITUD QUE SE ESTA ATENDIENDO.
            UPDATE "informix".ss_solicitudes_mc SET ejecutivo_atiende = pEjecutivoAtiende WHERE num_solicitud = cNumSolicitud AND sucursal = cSucursal and revisado <> 'S' and ejecutivo_atiende = '';	

            IF DBINFO("sqlca.sqlerrd2") > 0 THEN
                INSERT INTO "informix".ss_cte_procesando(numcte, usuario, fecha_insercion, hora_insercion)
                VALUES(cNumCte, pEjecutivoAtiende, CURRENT, CURRENT HOUR TO SECOND);
				
				--RQM101432-4vr2 Se contempla para cuando sea prestamo y se vaya autorizar actualizar la informacion de linea superior	
				SELECT count(*) INTO isolcomp FROM bdisolic:"informix".ss_solicitudes_cac  WHERE num_solicitud = cNumSolicitud;
				IF cNumProd NOT IN ('6001','6500')  AND iCompingreso > 0 THEN  		  
					IF isolcomp = 0 THEN
						INSERT INTO "informix".ss_solicitudes_cac (empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
						VALUES (pEmpresa, cNumSolicitud, cNumcte,csucursal, cNumProd, 'MC', pEjecutivoAtiende, pEjecutivoAtiende, "S", cMensaje, "N", dcMontoSolic, CURRENT,CURRENT, CURRENT, 'S');	
					ELSE
						UPDATE  "informix".ss_solicitudes_cac SET  status = 'MC', ejecutivo_atiende = pEjecutivoAtiende, ejecutivo_autoriza= pEjecutivoAtiende, comprobante_valido= 'S', observaciones = cMensaje WHERE num_solicitud = cNumSolicitud;
					END IF;
				ELIF cNumProd IN ('6001')  AND iCompingreso > 0 THEN  	
					IF isolcomp = 0 THEN
							INSERT INTO "informix".ss_solicitudes_cac 
							(empresa, num_solicitud, numcte, sucursal, num_producto, status, ejecutivo_atiende, ejecutivo_autoriza, comprobante_valido, observaciones, os, linea_determinada_sistema, fecha_insert,hora_insert, fecha_determinacion, revisado) 
							VALUES (pEmpresa, cNumSolicitud, cNumcte,csucursal, cNumProd, 'MC', pEjecutivoAtiende, "", "S", cMensaje, "S", v_valor, CURRENT,CURRENT, DATE(1), "S");												
					ELSE
						UPDATE  "informix".ss_solicitudes_cac SET  status = 'MC', ejecutivo_atiende = pEjecutivoAtiende, comprobante_valido= 'N', comprobante_valido_cac= 'N' WHERE num_solicitud = cNumSolicitud;
					END IF;								
				END IF;	

				LET nuevasol = 1;
				LET entrof = 1;		
				
                EXIT FOREACH;
            END IF;
			
        END FOREACH;

        --IF (DBINFO("sqlca.sqlerrd2") = 0 AND nuevasol = 0 and entrof = 0)  THEN
		IF (nuevasol = 0 and entrof = 0)  THEN
			LET cNumSolicitud = '';
			LET cNumCte = '';
            LET cCodRet = '000002'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.
            LET nuevasol = 2;
         END IF;
		 
	END IF;

    COMMIT WORK;

	IF (ven_transacc = 1) THEN
        BEGIN WORK;
	END IF;
		        	           
    RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,'');
   -- RETURN cCodRet, '600000005089', '000001035';

END
END PROCEDURE;