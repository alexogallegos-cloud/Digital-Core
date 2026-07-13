CREATE PROCEDURE "informix".sp_cnsif_soliccred(cID_USUARIOC char(8),cID_FUNCIONC char(10),cNumCte char(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(11),pNumRegistro INTEGER,pRecuperacion INTEGER)
    RETURNING   CHAR(5)  AS Cod_Retorno,  
					CHAR(20) AS Numero_Solicitud, 
					CHAR(4)  AS Sucursal,  
					CHAR(4)  AS Cve_Producto, 
					CHAR(40) AS Producto,  
					CHAR(2)  AS Cve_Status_Solicitud,   
					CHAR(40) AS Desc_Status_Solicitud, 
					MONEY(14,2) AS Ingreso_Mensual,  
					CHAR(30) AS Cve_Promotor, 
					DECIMAL(5,2) AS Eficiencia_Pago, 
					MONEY(14,2) AS Linea_Tienda,  
					SMALLINT AS Meses_Historia,  
					CHAR(1)  AS Cve_Situacion_Especial,  
					SMALLINT AS Cve_Causa, 
					CHAR(50) AS Desc_Situacion_Causa,  
					DATE     AS Fecha,    
					CHAR(1)  AS Respuesta,
					CHAR(1)  AS Situacion_respuesta_OS,  
					SMALLINT AS Causa_respuesta_OS, 
					CHAR(80) AS Desc_Situacion_Causa_OS, 
					CHAR(7) AS Seccion_1, 
					CHAR(7) AS Seccion_2, 
					CHAR(7) AS Suma_Total,  
					DECIMAL(18,2) AS Importe_Linea, 
					CHAR(2)  AS Calificacion_Riesgo,  
					DATE     AS Fecha_BURO, 
					DATETIME HOUR to FRACTION(3) AS Hora, 
					CHAR(80) AS Comentario, 
					CHAR(2)  AS Origen_consulta, 
					DATE     AS Periodo_Inicial, 
					DATE     AS Periodo_Final,
					DECIMAL(5,2)  AS evaluacion_scoring,
					DECIMAL(5,2)  AS evaluacion_scoring4;
                             
                                
DEFINE iexiste            INT;
DEFINE cCodRet            CHAR(5);
DEFINE cCodRetSp          CHAR(5);
DEFINE iSql_err           INT;
        --VARIABLES COMUNES     
DEFINE cNumSol            CHAR(20);
DEFINE cSucursal          CHAR(4);
DEFINE cCveProducto       CHAR(4);
DEFINE cDProducto         CHAR(40);
DEFINE cStatusSol         CHAR(2);
DEFINE cDescStatusSol     CHAR(40);
DEFINE dFecha             DATE;
DEFINE dEvaluacionScoring DECIMAL(5, 2);
--VARIABLES SOLICITUDES
DEFINE mIngresoMensual    MONEY(14,2);
DEFINE cCvePromotor       CHAR(30);
DEFINE dEficienciaPago    DECIMAL(5,2);
DEFINE mLineaTienda       MONEY(14,2);
DEFINE sintMesesHistoria  SMALLINT;
DEFINE cSituacionEspecial CHAR(1);
DEFINE iCausa             SMALLINT;
DEFINE cDescSitCausa      CHAR(50);
DEFINE cRespuesta         CHAR(1);
DEFINE cssosctesupSitEsp  CHAR(1);
DEFINE sintssosctesupCausa SMALLINT;
DEFINE csdcaosDescCausa   CHAR(80);
DEFINE dSeccion1          DECIMAL(5,2);
DEFINE dSeccion2          DECIMAL(5,2);
DEFINE dSumaTotal         DECIMAL(5,0);
DEFINE dImporteLinea      DECIMAL(18,2);
DEFINE cCalifRiesgo       CHAR(2);
DEFINE dEvaluacionScoring4 DECIMAL(5,2);
--VARIABLES BURO
DEFINE dFechaBuro         DATE;
DEFINE dHora              DATETIME HOUR to FRACTION(3);
DEFINE cComentario        CHAR(20);
DEFINE cOrigenConsulta    CHAR(2);
DEFINE dPeriodoI_1        DATE;
DEFINE dPeriodoF_1        DATE;
--VARIABLES DE PAGINACION
DEFINE iCont              INT;

--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa           CHAR(3);

--AUXILIARES PARA SOLICITUDES
DEFINE iCantidad          INT;
DEFINE auxEmpresa         CHAR(3);
DEFINE auxSeccion2        DECIMAL(5,2);
DEFINE dSumatoria         DECIMAL(5,2);
DEFINE dSumaParcial       DECIMAL(5,2);

--inicializando variables
LET  iexiste 			  = 0;
LET cCodRet  			  = "00000";
LET cCodRetSp			  = "";
LET iSql_err 			  = 0 ;      
--COMUNES
LET cNumSol               = "";
LET cSucursal             = "";
LET cCveProducto          = 0;
LET cDProducto            = "";
LET cStatusSol            = "";
LET cDescStatusSol        = "";
LET dFecha                = "";
--SOLICITUDES
LET mIngresoMensual       = 0;
LET dEvaluacionScoring	  = 0;
LET cCvePromotor          = "";
LET dEficienciaPago       = 0;
LET mLineaTienda          = 0;
LET sintMesesHistoria     = 0;
LET cSituacionEspecial    = "";
LET iCausa                = "";
LET cDescSitCausa         = "";
LET cRespuesta            = "";
LET cssosctesupSitEsp     = "";
LET sintssosctesupCausa   = 0;
LET csdcaosDescCausa      = "";
LET dSeccion1             = 0.0;
LET dSeccion2             = 0.0;
LET dSumaTotal            = 0.0;
LET dImporteLinea         = 0.0;
LET cCalifRiesgo          = "";
LET dEvaluacionScoring4   = 0;
--BURO
LET dFechaBuro            = "";
LET dHora                 = "";
LET cComentario           = "";
LET cOrigenConsulta       = "";
LET dPeriodoI_1           = "";
LET dPeriodoF_1           = "";
--AUXILIARES PARA SOLICITUDES
LET iCantidad             = 0;
LET auxEmpresa            = "";
LET auxSeccion2           = 0.0;
LET dSumatoria            = 0.0;
let dSumaParcial          = 0;

--VARIABLES DE PAGINACION 
LET iCont                 = 0;

--SE DEJA COMO CONSTANTE
LET pEmpresa              = '001';

BEGIN
	ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
					LET cCodRet = iSql_err;
					RETURN 
					cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
					dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
					cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
					cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
			END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_soliccred.out";
	--TRACE ON;

	-- TERMINA VALIDACION
	IF      cID_USUARIOC = ''       OR
			cID_FUNCIONC = ''       OR
			cNumCte      = ''       OR 
			cSISTEMACUENTA = '' THEN 
			LET cCodRet = "00045";
			RETURN
			cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
			dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
			cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
			cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
	END IF; 
	IF cSISTEMACUENTA <> 'SOLICITUDES' AND cSISTEMACUENTA <> 'BURO'   THEN 
			LET cCodRet = "00049";
			RETURN 
			cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
			dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
			cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
			cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
	END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
                RETURN 
                cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
                dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
                cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
                cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN 
            cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
            dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
            cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
            cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
        END IF;
    END IF;  
	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNumCte,'06','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
			RETURN 
					cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
					dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
					cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
					cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
	END IF;            
                
	IF cSISTEMACUENTA = 'SOLICITUDES' THEN 
	
		SELECT NVL(COUNT(numcte),0) into iexiste FROM bdisolic:ss_solicitudes WHERE numcte  = cNumCte;
		
		IF iexiste  = 0 THEN 
				LET cCodRet = "00017";
				RETURN 
				cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
				dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
				cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
				cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
		END IF
			
		set isolation to dirty read;
		FOREACH                         
			SELECT SKIP pNumRegistro FIRST pRecuperacion nvl(sf.ingreso_mensual,0) as ingreso_mensual,a.num_solicitud, a.sucursal,  b.num_producto, b.nombre_prod,
				a.user_insert AS clave_promotor,nvl(sf.situacion_pago,0) AS eficiencia_pago,nvl(sf.linea_tienda,0) AS linea_tienda,
				nvl(sf.meses_historia,0) AS meses_historia,sf.situacion_credito AS situacion_esp,sf.causa,nvl(cau.descripcion,'') AS descripcion_situacion_causa,  
				ssos.fecha_solicitud, nvl(ssos.status, '') AS Respuesta,nvl(sssup.situacionespecial,''), nvl(sssup.causasituacionespecial,0),
				nvl(secesp.descripcion,'') as descripcion_sit_causa_os,nvl(a.status_solicitud, '') AS status_solicitud, 
				ss.descripcion, nvl(a.monto_solicitado,0) AS Importe_Linea_Recomendado
				INTO            
				mIngresoMensual,cNumSol,cSucursal,cCveProducto,cDProducto,cCvePromotor,dEficienciaPago,mLineaTienda,sintMesesHistoria,
				cSituacionEspecial,iCausa, cDescSitCausa, dFecha, cRespuesta, cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,
				cStatusSol, cDescStatusSol,dImporteLinea                                
				FROM bdisolic:ss_solicitudes a 
				LEFT JOIN bdisolic:ss_resum_scor_fin sf ON a.num_solicitud = sf.num_solicitud
				AND a.empresa = sf.empresa                      
				LEFT JOIN bdicred:sd_definicion b ON a.num_producto = b.num_producto 
				LEFT JOIN bdisolic:ss_status_sol ss ON ss.status_solicitud = a.status_solicitud 
				AND a.empresa = ss.empresa 
				LEFT JOIN bdicred:sd_causas_cte_coppel cau ON sf.situacion_credito = cau.situacion
				And sf.empresa = cau.empresa
				AND sf.causa = cau.causa
				LEFT JOIN bdisolic:ss_solicitud_os ssos ON a.num_solicitud = ssos.num_solicitud   
				AND ssos.fecha_solicitud = ( SELECT max(fecha_solicitud) FROM bdisolic:ss_solicitud_os ssosb                    
				WHERE ssosb.num_solicitud = ssos.num_solicitud                    
				AND ssosb.empresa = ssos.empresa)  
				AND a.empresa = ssos.empresa 
				LEFT JOIN bdisolic:ss_osclientesupervisar sssup ON a.num_solicitud = sssup.num_solicitud
				AND a.empresa = sssup.empresa
				LEFT JOIN bdisitesp:se_catsitesp secesp ON a.empresa = secesp.empresa
				AND sssup.empresa = secesp.empresa
				AND sssup.situacionespecial = secesp.situacion   
				AND sssup.causasituacionespecial = secesp.causa   
				WHERE a.empresa = pEmpresa 
				AND numcte = cNumCte
				ORDER BY a.num_solicitud DESC
			
			SELECT  nvl(sum(decode(seccion, '1', nvl(evaluacion,0), 0)),0) AS seccion1,  
				nvl(sum(decode(seccion, '2', nvl(evaluacion,0), 0)),0) AS seccion2,  
				nvl(sum(nvl(evaluacion, 0)),0) AS Suma,
				count(num_solicitud) as cantidad 
				INTO
				dSeccion1, dSeccion2, dSumaTotal,iCantidad
				FROM bdisolic:ss_resumen_scoring
				WHERE empresa = pEmpresa
				AND seccion IN ('1', '2')
				AND num_solicitud = cNumSol;

			LET dSumatoria                  = 0.0;
				
			IF iCantidad <> 2 THEN

			FOREACH
				SELECT  sg.empresa, sg.seccion, decode(nvl(sg.agrupar, ''), '', sum(nvl(dc.valor,0)), max(nvl(dc.valor,0))) AS suma 
				INTO
				auxEmpresa, auxSeccion2, dSumaParcial
				FROM bdisolic:ss_detalle_scoring dc, 
				bdisolic:ss_scoring_grupo sg 
				WHERE sg.empresa = dc.empresa 
				AND sg.grupo = dc.grupo 
				AND sg.seccion = dc.seccion 
				AND dc.num_solicitud = cNumSol 
				AND dc.seccion = '2' 
				AND dc.empresa = pEmpresa
				GROUP BY sg.empresa, sg.seccion, sg.agrupar
				
				LET dSumatoria = dSumatoria + dSumaParcial;
		
			END FOREACH;
				
			LET dSeccion2 = dSumatoria;
			LET dSeccion1 = dSumaTotal - dSeccion2;
			END IF
			
			SELECT  nvl(calificacion_riesgo, '') AS calificacion_riesgo 
			INTO cCalifRiesgo
			FROM bdicred:sd_maecred  
			WHERE empresa= pEmpresa  
			AND num_credito = cNumSol;
			
			LET iCont=iCont+1;
			
			-- CONSULTA 
			EXECUTE PROCEDURE bdicnweb:"informix".sp_calificacion_scoring(cID_USUARIOC, cID_FUNCIONC, cNumSol, '3')
			INTO cCodRetSp, dEvaluacionScoring;
			
			IF cCodRetSp <> "00000" THEN
				LET dEvaluacionScoring = 0;
			END IF;
			
			IF cCveProducto IN ('6001', '6300', '6400') THEN
				EXECUTE PROCEDURE bdicnweb:"informix".sp_calificacion_scoring(cID_USUARIOC, cID_FUNCIONC, cNumSol, '4')
				INTO cCodRetSp, dEvaluacionScoring4;
				
				IF cCodRetSp <> "00000" THEN
					LET dEvaluacionScoring4 = 0;
				END IF;
			END IF;
			
			RETURN 
			cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
			dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
			cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
			cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4 WITH resume;                                          
			
		END FOREACH;
			
		IF iCont = 0 THEN
		LET cCodRet = '1001'; 
				RETURN 
				cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
				dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
				cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
				cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
		END IF
	
	ELIF cSISTEMACUENTA = 'BURO' THEN 
		IF      cID_USUARIOC = ''       OR
		cID_FUNCIONC = ''       OR
		cNumCte      = ''       OR 
		dPERIODOI IS NULL   OR
		dPERIODOF IS NULL   OR
		cSISTEMACUENTA = '' THEN 
		LET cCodRet = "00003";
		RETURN
		cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
		dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
		cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
		cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
		END IF;

		SELECT NVL(COUNT(numcte),0) into iexiste FROM bdisolic:ss_solicitudes WHERE numcte  = cNumCte;          
		
		IF iexiste  = 0 THEN 
				LET cCodRet = "00017";
				RETURN 
				cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
				dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
				cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
				cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
		END IF

        SELECT NVL(COUNT(*),0) INTO iexiste
        FROM bdisolic:ss_solicitudes sol
        LEFT JOIN bdicred:sd_definicion b ON sol.num_producto = b.num_producto 
        LEFT JOIN bdisolic:ss_status_sol ss ON ss.status_solicitud = sol.status_solicitud 
        AND sol.empresa = ss.empresa
        LEFT OUTER JOIN bdiburo:br_auditor bur ON (bur.solicitud = sol.num_solicitud 
        AND sol.status_solicitud = bur.institucion 
        AND fecha||hora = (select max(fecha||hora) FROM bdiburo:br_auditor  
        WHERE solicitud = bur.solicitud AND institucion = bur.institucion)) 
        --LEFT OUTER JOIN bdiburo:sb_regreso reg ON  (reg.num_solicitud = sol.num_solicitud 
        --AND reg.institucion =sol.status_solicitud) 
		--IPCB cambio de sb_regreso por br_respuesta por reingenieria de Demonios
		LEFT OUTER JOIN bdiburo:br_respuesta reg ON  (reg.num_solicitud = sol.num_solicitud 
		AND reg.institucion =sol.status_solicitud) 
        LEFT OUTER JOIN bdiburo:br_traslado tra ON (tra.num_solicitud = sol.num_solicitud 
        AND tra.institucion =sol.status_solicitud) 
        WHERE sol.fecha_insert BETWEEN dPERIODOI AND dPERIODOF 
        AND sol.status_solicitud IN ('BC','CC')
        AND sol.numcte = cNumCte;
                
		IF iexiste  = 0 THEN 
				LET cCodRet = "00094";
				RETURN 
				cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
				dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
				cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
				cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
		END IF
		
		set isolation to dirty read;
		FOREACH 
			SELECT SKIP pNumRegistro FIRST pRecuperacion    sol.num_solicitud,      sol.sucursal, sol.num_producto,
			b.nombre_prod,  sol.fecha_insert fecha, bur.hora,
			CASE WHEN substr(regreso,38,4) = 'PA04' THEN  'Segmento Direccion -Estado'  
			WHEN substr(regreso,38,4) = 'PN05' THEN  'Segmento Nombre - Apellido Materno'  
			WHEN substr(regreso,38,4) = 'PN02' THEN  'Segmento Nombre - Primer Nombre'  
			WHEN substr(regreso,38,4) = 'PN03' THEN  'Segmento Nombre - Segundo Nombre'  
			WHEN substr(regreso,38,4) = 'PNPN' THEN  'Segmento Nombre - RFC'  
			WHEN substr(regreso,38,4) = 'PN00' THEN  'Segmento Nombre - Apellido Paterno'  
			WHEN substr(regreso,38,4) = 'PA05' THEN  'Error en CP'  
			WHEN substr(regreso,32,7) = '1101YES' THEN  'Error en cadena de CC'  
			WHEN substr(regreso,34,6) = '0506PA' THEN  'Error en CP'  
			WHEN tra.envio1 = '0003000400' THEN  'Segmento Direccion - DirecciÃÂ³n incompleta o sin asignar'  
			WHEN reg.regreso is null THEN  'Sin respuesta de ' || sol.status_solicitud  
			WHEN length(regreso) = 4005 THEN  'No se puede procesar respuesta -Longitud excede 4005 caracteres'  
			ELSE  bur.comentario END comentario,
			sol.status_solicitud,
			ss.descripcion,
			sol.status_solicitud AS Origen_Consulta ,dPERIODOI,dPERIODOF
			INTO            
			cNumSol,cSucursal,cCveProducto,cDProducto,dFechaBuro,dHora,cComentario,cStatusSol, cDescStatusSol, cOrigenConsulta, dPeriodoI_1, dPeriodoF_1
			FROM bdisolic:ss_solicitudes sol
			LEFT JOIN bdicred:sd_definicion b ON sol.num_producto = b.num_producto 
			LEFT JOIN bdisolic:ss_status_sol ss ON ss.status_solicitud = sol.status_solicitud 
			AND sol.empresa = ss.empresa
			LEFT OUTER JOIN bdiburo:br_auditor bur ON (bur.solicitud = sol.num_solicitud 
			AND sol.status_solicitud = bur.institucion 
			AND fecha||hora = (select max(fecha||hora) FROM bdiburo:br_auditor  
			WHERE solicitud = bur.solicitud AND institucion = bur.institucion)) 
			--LEFT OUTER JOIN bdiburo:sb_regreso reg ON  (reg.num_solicitud = sol.num_solicitud 
			--AND reg.institucion =sol.status_solicitud) 
			--IPCB cambio de sb_regreso por br_respuesta por reingenieria de Demonios
			LEFT OUTER JOIN bdiburo:br_respuesta reg ON  (reg.num_solicitud = sol.num_solicitud 
			AND reg.institucion =sol.status_solicitud) 
			LEFT OUTER JOIN bdiburo:br_traslado tra ON (tra.num_solicitud = sol.num_solicitud 
			AND tra.institucion =sol.status_solicitud) 
			WHERE sol.fecha_insert BETWEEN dPERIODOI AND dPERIODOF 
			AND sol.status_solicitud IN ('BC','CC')
			AND sol.numcte = cNumCte
			ORDER BY sol.num_solicitud DESC
							
			LET iCont=iCont+1;
			
			RETURN 
			cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
			dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
			cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
			cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4 WITH resume;

		END FOREACH;
      
		IF iCont = 0 THEN
		LET cCodRet = '1001'; 
				RETURN 
				cCodRet, cNumSol, cSucursal, cCveProducto, cDProducto, cStatusSol, cDescStatusSol, mIngresoMensual, cCvePromotor,
				dEficienciaPago, mLineaTienda, sintMesesHistoria, cSituacionEspecial, iCausa, cDescSitCausa, dFecha, cRespuesta, 
				cssosctesupSitEsp, sintssosctesupCausa, csdcaosDescCausa,dSeccion1, dSeccion2, dSumaTotal,dImporteLinea,
				cCalifRiesgo,dFechaBuro,dHora,cComentario,cOrigenConsulta,dPeriodoI_1,dPeriodoF_1,dEvaluacionScoring,dEvaluacionScoring4;
		END IF
     
	END IF;
END
END PROCEDURE
DOCUMENT                
"AutOR : ARTURO CERVANTES PEÃ?A",
"FUNCIONAMIENTO:btener la informaciÃÂ³n de las Solicitudes de CrÃÂ©dito, tal como: datos Generales, datos de la Solicitud, ",
"EvaluaciÃÂ³n Clientes Coppel y Respuesta de SupervisiÃÂ³n. El SP obtendrÃÂ¡ la informaciÃÂ³n de la Base de Datos central de Informix,",
"Enviando como parÃÂ¡metro el  No. de Cliente",
"VER   : 1.0",
"FECHA : 16-02-2012",
"Autor : Oscar Flores Conde",
"FUNCIONAMIENTO: Consulta del valor obtenido en la seccion 3 del scoring para las solicitudes de credito",
"FECHA : 04-07-2015",
"VER   : 1.1",
"Autor : L. Montserrat LeÃ³n Amador",
"FUNCIONAMIENTO: Consulta del valor obtenido en la seccion 4 del scoring para los productos 6001, 6300, 6400.",
"FECHA : 09-09-2016",
"VER   : 1.2",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_traslada_boletos_pba2(p_cve_sorteo char(5), p_fecha_pase DATE)
RETURNING CHAR(5)  AS Codigo_retorno, 
          CHAR(80) AS Mensaje,
          CHAR(1)  AS Reverso,
          CHAR(25) AS StorePro;              
               
    DEFINE vsqlerr           INTEGER; 
    DEFINE v_codigo_retorno	CHAR(5);
    DEFINE v_mensaje	  	    CHAR(80);
    DEFINE v_reverso         CHAR(1);
    DEFINE v_store_pro       CHAR(25);
    DEFINE vrowid      INTEGER;
    DEFINE vd_valida   DATE;
    DEFINE vd_fecha2   DATE;
    DEFINE vd_fsorteo  DATE;
    DEFINE vc_numcte   CHAR(10);
    DEFINE vi_nociudadcoppel  INTEGER;
    DEFINE vi_nocoloniacoppel INTEGER;
    DEFINE vc_nomzonacoppel   CHAR(20);
    DEFINE vc_nomcuidad       CHAR(20);  
    DEFINE vc_nombre          CHAR(25);
    DEFINE vc_telef1          CHAR(10);
    DEFINE vc_telef2          CHAR(13);
    DEFINE vc_domicilio       CHAR(50);
    DEFINE vc_nomcalle        CHAR(20); 
    DEFINE vc_numextcalle     CHAR(10);
    DEFINE vc_nomcolonia      CHAR(20);
    DEFINE vc_nombre_cte   CHAR(45);
    DEFINE vc_cvesorteo    INTEGER;
	DEFINE v_foliosuc CHAR(16);
    DEFINE v_param		  CHAR(5);  -- FMV 21-Sep-10: Parámetro para traer clave de sorteo normal 2010.

    SET debug file TO "/tmp/traslada_boletos.out";
    TRACE ON;

    LET v_codigo_retorno = "00000";
    LET v_mensaje = "Proceso Inicia Correctamente";
    LET v_reverso = '0';
    LET v_store_pro = 'sp_traslada_boletos';
    LET vrowid     = 0;
    LET vd_valida  = (p_fecha_pase - 1 units day);
    LET vd_fsorteo = (vd_valida - 1 units day);

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = 'sp_traslada_boletos';
            RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
    END EXCEPTION;
	   /*VALIDA QUE LA BANDERA DEL CONCURSO 00002 SEA 2*/
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = p_cve_sorteo AND flag_sort = 2) THEN
					
				/*se agrega para optimizacion de busqueda*/
    
				-- FMV 21-Sep-10: Parámetro para traer clave de sorteo normal 2010.
				SELECT valor 
				INTO v_param 
				FROM bdinteg:si_param
				WHERE cod_param = 118;
				
				SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
				INTO vc_cvesorteo
				FROM si_sorteo
				WHERE cve_sorteo = v_param;     -- FMV 21-Sep-10    
				
				IF NOT EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
								 FROM bdinteg:si_sorteo 
								WHERE cve_sorteo = v_param) THEN -- FMV 21-Sep-10 
					LET v_codigo_retorno = "00040";
					LET v_mensaje = "Se Genero Error en si_sorteo, No Existe Sorteo!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;   
				
				IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo
							 FROM bdinteg:si_sorteo
							WHERE cve_sorteo = v_param  -- FMV 21-Sep-10 
							  AND f_fin < vd_fsorteo) THEN                  
					LET v_codigo_retorno = "00042";
					LET v_mensaje = "Se Genero Error en si_sorteo, Sorteo No esta Vigente!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;
				
				--*********************************************************--
				-- Creado por: Francisco Martinez Viveros	
				--Fecha Creacion: 31/AGOSTO/2010
				--Fecha Modifica: 09/NOVIEMBRE/2010 
				--Objetivo: Traspasa los boletos generados diariamente y 
				--          los envia a la tabla historica con los datos del clte.    
				--*********************************************************--

				
				IF (p_fecha_pase is null) THEN
					LET v_codigo_retorno = "00030";
					LET v_mensaje = "Se genero error de Ejecucion, Verifique Fecha Nula!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				-- BGM 08-Nov-2010: se coloca en primera instancia el foreach para actualizar los datos del cliente 
				-- sobre la misma tabla si_boleto
				-- FOREACH 1 
				FOREACH cursor_actual WITH HOLD FOR              
					SELECT {+index (si_boleto idx_si_bol_clte)} fecha, numcte   --FMV 8-NOV-10: SE ADICIONA INDICE               
					INTO vd_fecha2, vc_numcte  
					FROM bdinteg:"informix".si_boleto 
					WHERE fecha = vd_valida 
					AND numcte > '0000000'

					BEGIN WORK;

					-- BGM 08-Nov-2010: se coloca query optimizado por Faviola Martínez.
					-- FMV 09-Nov-2010: Query filtrado por Faviola Martínez, con aquellos Clientes q no tienen datos completos.

					SELECT {+index (SI_CATCALLES idx_catcalles)}
							CAT.numerociudadcoppel,CAT.numerocoloniacoppel,CAT.nombrezonacoppel, 
							CIU.NOMBRECIUDAD, SCA.NOMBRECALLE, SE.nombre,tel1.telefono, tel2.telefono,
							dom.numeroextcalle, CAT.nombrezona    
					  INTO vi_nociudadcoppel, vi_nocoloniacoppel, vc_nomzonacoppel, vc_nomcuidad,
							vc_nomcalle, vc_nombre, vc_telef1, vc_telef2, vc_numextcalle,
							vc_nomcolonia
					FROM BDINTEG:SI_DIRECCIONES_ACTUAL DOM  
					LEFT OUTER JOIN BDINTEG:SI_CATCALLES SCA ON (DOM.NUMEROCALLE = SCA.NUMEROCALLE)
					LEFT OUTER JOIN BDINTEG:SI_CATZONAS CAT ON (DOM.NUMEROCIUDAD = CAT.NUMEROCIUDAD AND DOM.NUMEROCOLONIA = CAT.NUMEROCOLONIA)  
					LEFT JOIN BDINTEG:SI_CATCIUDADES CIU ON (DOM.NUMEROCIUDAD = CIU.NUMEROCIUDAD  )
					LEFT JOIN BDINTEG:SI_ESTADOS SE ON ( DOM.estado   = SE.ESTADO )
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dom.numcte AND tel1.tipo_tel = 1)
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dom.numcte AND tel2.tipo_tel = 2)
					WHERE DOM.NUMCTE = vc_numcte 
					-- AND DOM.SECUENCIA IN (SELECT MAX(SID.SECUENCIA) FROM BDINTEG:SI_DIRECCIONES_ACTUAL SID WHERE SID.NUMCTE = DOM.NUMCTE AND SID.TIPO_DIR = 1 ) 
					AND DOM.TIPO_DIR  = 1;
					
					--FMV: Se Adiciona validacion para los telefonos por si el dato en null
					IF (vc_telef1 IS NULL) OR (vc_telef1= '') THEN 
						LET vc_telef1 = '0';
					END IF;
					
					IF (vc_telef2 IS NULL) OR (vc_telef2= '') THEN 
						LET vc_telef2 = '0';
					END IF;
					
					LET vc_nombre_cte = (SELECT trim(nombre1)||' '||   
												trim(nombre2)||' '||    
												trim(apell_paterno)||' '|| 
												trim(apell_materno)                                            
												FROM bdinteg:si_cliente WHERE numcte = vc_numcte);    
												
					LET vc_domicilio =  trim(vc_nomcalle)||' '||
										trim(vc_numextcalle)||' '||                                                                      
										trim(vc_nomcolonia);
				
					-- BGM 08-Nov-2010: se hace el update sobre si_boleto en lugar de si_boleto_hist
					UPDATE bdinteg:"informix".si_boleto        --{+index (si_mensajes_enviar_his idx_msgs_envhis)}
					SET telefono1 = vc_telef1,
						telefono2 = vc_telef2,
						nombre    = vc_nombre_cte,
						ciudad    = vc_nomcuidad,
						domicilio = vc_domicilio,
						ent_fed = vc_nombre --SE AGREGA PARA GUARDARSE EN LA TABLA
					WHERE CURRENT OF cursor_actual;  
						
					COMMIT WORK;
				END FOREACH; 
				
				IF (v_reverso <> '0') THEN        
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				LET v_codigo_retorno = "00000";
				LET v_mensaje = "Proceso Pase de Boletos, Termino Correctamente!";
				LET v_reverso = '0';         
				LET v_store_pro = 'sp_traslada_boletos';    

				-- BGM 08-Nov-2010: se cambia de posición el FOREACH para que al final haga el traslado a si_boleto_hist, 
				-- pero sin borrar los datos de si_boleto porque los necesitará el sp_detalle_boletos

				FOREACH cursor_inserta WITH HOLD FOR
					SELECT  {+index (si_boleto idx_si_boleto)}numcte, foliosuc
						INTO vc_numcte, v_foliosuc
					--INTO vrowid            
					FROM bdinteg:"informix".si_boleto
					WHERE date(f_registro) = vd_valida 
					AND numcte <> ''
					
					BEGIN WORK;
					
					INSERT INTO --{+index (si_boleto_hist idx_si_boleto_hist)} 
					bdinteg:"informix".si_boleto_hist
					SELECT {+index (si_boleto idx_si_boleto)} *
					FROM bdinteg:"informix".si_boleto
					WHERE numcte = vc_numcte
					  AND foliosuc = v_foliosuc;                                                                 
				COMMIT WORK;                           
				END FOREACH;
	ELSE
		LET v_codigo_retorno = "22222";
        LET v_mensaje = "¡EL SORTEO NAVIDEÑO NO ESTA ACTIVO!";
        LET v_reverso = '1';
        LET v_store_pro = v_store_pro;     
	END IF;			
    
    END;   --begin        
    
    RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
    
END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÁLEZ',
'FECHA DE MODIFICACIÓN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_replica_indicadores_ctes_bi(iIndicador INTEGER,dFechaProceso DATE)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE vCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE iNomErr          INTEGER;
DEFINE iNanErr          INTEGER;
DEFINE iEnTransaccion   SMALLINT;
DEFINE cProceso			CHAR(100);
DEFINE cEvento			CHAR(100);

--DEFINE dFechaproceso    DATE;
DEFINE dFechahoy        DATETIME YEAR TO FRACTION;
DEFINE dFechafin        DATETIME YEAR TO FRACTION;
DEFINE dnregsCb         DECIMAL(18,0);
DEFINE dnregsStg        DECIMAL(18,0);
DEFINE dnregsDif        DECIMAL(18,0);
DEFINE dncontaCb        DECIMAL(18,0);
DEFINE dncontaStg       DECIMAL(18,0);
DEFINE dncontaDif       DECIMAL(18,0);


--ASIGNACION DE VARIABLES
LET cProceso = '';
LET cEvento = '';
LET dFechahoy = CURRENT::DATE;
LET vCodRet = '000000';
LET cMensCodRet = 'EL PROCESO DE REPLICA DE ESTADISTICAS SE A GENERADO CORRECTAMENTE';

--SET DEBUG FILE TO "/tmp/ALAN/MANTENIMIENTOREPLICAS/basededatos/bdinteg/sp/sp_replica_estadisticas_ctes_bi.out";
--TRACE ON;

BEGIN
     --Manejo del error
		ON EXCEPTION SET iNomErr, iNanErr, cMensCodRet
			LET cEvento = 'MANEJO DE EXCEPCIONES';
			IF iNomErr <> 0 THEN
				LET vCodRet=iNomErr;
				IF iEnTransaccion = 1 THEN

					ROLLBACK;

					SELECT DBINFO('utc_to_datetime',sh_curtime)
					INTO dFechafin
					FROM sysmaster:"informix".sysshmvals;
					--UPDATE bdibi@coppel_tcp:"informix".bi_controlprocesos
					UPDATE bdibi@stag_ids1170:"informix".bi_controlprocesos
					SET maxfecha_cargada = dFechaproceso, flagfinalizado = 'F', coderror = vCodRet, msgerror = cMensCodRet, fecha_cargafin = dFechafin
                    WHERE id_proc = iIndicador
                    AND fecha_carga = dFechaProceso;

			    END IF;

				INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaProceso, cProceso, cEvento, vCodret, cMensCodRet);

				RETURN vCodRet, cMensCodRet;
		    END IF;
		END EXCEPTION;

		LET cProceso = 'PRINCIPAL';
		LET cEvento = 'VALIDACION DE PARAMETROS';

		IF dFechaproceso IS NULL OR dFechaproceso = '' THEN
			LET vCodRet = '000001';
			LET cMensCodRet = 'PARAMETRO INCORRECTO, PARAMETRO VACIO';
			RETURN vCodRet, cMensCodRet;
		ELIF iIndicador IS NULL OR  iIndicador ='' THEN
			LET vCodRet = '000002';
			LET cMensCodRet = 'PARAMETRO INCORRECTO, PARAMETRO VACIO';
			RETURN vCodRet, cMensCodRet;
		ELIF iIndicador <> '2' AND iIndicador <> '101' THEN
			LET vCodRet = '000003';
			LET cMensCodRet = 'PARAMETRO INCORRECTO';	
			RETURN vCodRet, cMensCodRet;
		END IF;

		LET cEvento = 'OBTENCION DE FECHA-HORA DE INICIO DE REPLICA';
		SELECT DBINFO('utc_to_datetime',sh_curtime)
		INTO dFechahoy
		FROM sysmaster:"informix".sysshmvals;

		LET cEvento = 'GUARDA INFORMACION INICIAL EN bi_controlprocesos';
		
	IF iIndicador = 2 THEN
					
			--INSERT INTO bdibi@coppel_tcp:"informix".bi_controlprocesos (fecha_carga, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin,
			INSERT INTO bdibi@stag_ids1170:"informix".bi_controlprocesos (fecha_carga, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin,
	                                                           maxfecha_cargada, flagfinalizado, coderror, msgerror)
			VALUES (dFechaproceso,iIndicador, 'bdinteg:sp_replica_estadisticas_ctes_bi', dFechahoy, NULL, NULL, 'F', NULL, NULL);
	

		BEGIN WORK;
			LET iEnTransaccion = 1;

			LET cEvento = 'CALCULO DE TOTALES DE LA FECHA PROCESO EN si_indicadores_ctes_nvos_det';
			SELECT COUNT (*)
			INTO dnregsCb
			FROM bdinteg:"informix".si_indicadores_ctes_nvos_det
			WHERE fecha = dFechaproceso;

			LET cEvento = 'CALCULO DE TOTALES GLOBALES EN si_indicadores_ctes_nvos_det';
			SELECT COUNT (*)
			INTO dncontaCb
			FROM bdinteg:"informix".si_indicadores_ctes_nvos_det;

			LET cEvento = 'INSERCION DE REGISTROS EN LA TABLA bdibi:bi_indicadores_ctes_nvos_det';
			--INSERT INTO bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det (tipo_movto, fecha, sucursal, nombre_suc, ejecutivo, nombre_ejecut,
			INSERT INTO bdibi@stag_ids1170:"informix".bi_indicadores_ctes_nvos_det (tipo_movto, fecha, sucursal, nombre_suc, ejecutivo, nombre_ejecut,
																altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep,
																telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep,
																telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep,
																telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
			SELECT a.tipo_movto, a.fecha, a.sucursal, b.nom_suc, a.ejecutivo, b.nom_emp,
				   a.altas_ctes, a.correo_cap, a.correo_val, a.correo_inval, a.correo_pen, a.correo_rep,
				   a.telcasa_cap, a.telcasa_val, a.telcasa_inval, a.telcasa_pen, a.telcasa_rep,
				   a.telcel_cap, a.telcel_val, a.telcel_inval, a.telcel_pen, a.telcel_ver, a.telcel_rep,
				   a.telotro_cap, a.telotro_val, a.telotro_inval, a.telotro_pen, a.telotro_rep
			FROM  bdinteg:si_indicadores_ctes_nvos_det a , si_tmp_sucursal_ejecut b
			WHERE a.ejecutivo = b.ejecutivo
			AND a.sucursal = b.sucursal
			AND a.fecha = dFechaproceso;
	
			
			LET cEvento = 'CALCULO DE TOTALES DE LA FECHA PROCESO EN bi_indicadores_ctes_nvos_det';
			SELECT COUNT (*)
			INTO dnregsStg
			--FROM bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det
			FROM bdibi@stag_ids1170:"informix".bi_indicadores_ctes_nvos_det	
			WHERE fecha = dFechaproceso;

			LET dnregsDif = dnregsCb - dnregsStg;

			LET cEvento = 'CALCULO DE TOTALES GLOBALES EN bi_indicadores_ctes_nvos_det';
		    SELECT COUNT (*)
			INTO dncontaStg
			--FROM bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det;
			FROM bdibi@stag_ids1170:"informix".bi_indicadores_ctes_nvos_det;

			LET dncontaDif = dncontaCb - dncontaStg;

			LET cEvento = 'GUARDA INFORMACION bi_cifras_control';
			--INSERT INTO bdibi@coppel_tcp:"informix".bi_cifras_control (fecha, id_proc, descripcion, fecha_carga, nregs_cb, nregs_stg, nregs_dif,
			INSERT INTO bdibi@stag_ids1170:"informix".bi_cifras_control (fecha, id_proc, descripcion, fecha_carga, nregs_cb, nregs_stg, nregs_dif,
	                                                            nconta_cb, nconta_stg, nconta_dif, import_cb, import_stg, import_dif, nombre_sp)
			VALUES (dFechaproceso,iIndicador, 'ESTADISTICAS DE CLIENTES', CURRENT::DATE, dnregsCb, dnregsStg, dnregsDif, dncontaCb, dncontaStg, dncontaDif, 0, 0, 0,'bdinteg:sp_replica_estadisticas_ctes_bi');

			LET cEvento = 'OBTENCION DE FECHA-HORA FINAL DE REPLICA';
			SELECT DBINFO('utc_to_datetime',sh_curtime)
			INTO dFechafin
			FROM sysmaster:"informix".sysshmvals;

			LET cEvento = 'GUARDA INFORMACION FINAL EN bi_controlprocesos';
			--UPDATE bdibi@coppel_tcp:"informix".bi_controlprocesos
			UPDATE bdibi@stag_ids1170:"informix".bi_controlprocesos
			SET maxfecha_cargada = dFechaproceso, flagfinalizado = 'V', coderror = vCodRet, msgerror = cMensCodRet, fecha_cargafin = dFechafin
            WHERE id_proc = iIndicador
            AND fecha_carga = dFechaProceso;

		COMMIT WORK;
		LET iEnTransaccion = 0;

	ELSE
		IF iIndicador = 101 THEN
		
				--INSERT INTO bdibi@coppel_tcp:"informix".bi_controlprocesos (fecha_carga, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin,
				INSERT INTO bdibi@stag_ids1170:"informix".bi_controlprocesos (fecha_carga, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin,
	                                                           maxfecha_cargada, flagfinalizado, coderror, msgerror)
				VALUES (dFechaproceso,iIndicador, 'bdinteg:sp_replica_estadisticas_ctes_bi', dFechahoy, NULL, NULL, 'F', NULL, NULL);
	

			BEGIN WORK;
				LET iEnTransaccion = 1;

				LET cEvento = 'CALCULO DE TOTALES DE LA FECHA PROCESO EN si_indicadores_kiosko';
				SELECT COUNT (*)
				INTO dnregsCb
				FROM bdinteg:"informix".si_indicadores_kiosko
				WHERE fecha_proceso = dFechaproceso;

				LET cEvento = 'CALCULO DE TOTALES GLOBALES EN si_indicadores_kiosko';
				SELECT COUNT (*)
				INTO dncontaCb
				FROM bdinteg:"informix".si_indicadores_kiosko;

				LET cEvento = 'INSERCION DE REGISTROS EN LA TABLA bdibi:bi_indicadores_kiosko';
				--INSERT INTO bdibi@coppel_tcp:"informix".bi_indicadores_kiosko (fecha_proceso, sucursal,nombre_suc ,cons_movimientos, cons_saldos, cons_edocta, user_insert)
				INSERT INTO bdibi@stag_ids1170:"informix".bi_indicadores_kiosko (fecha_proceso, sucursal,nombre_suc,cons_movimientos, cons_saldos, cons_edocta, user_insert)
				SELECT a.fecha_proceso, a.sucursal, b.nombre,a.cons_movimientos, a.cons_saldos, a.cons_edocta, USER
				FROM  bdinteg:si_indicadores_kiosko a,bdinteg:si_sucursales b
				WHERE fecha_proceso = dFechaproceso
				AND   a.sucursal = b.sucursal;
			

			
				LET cEvento = 'CALCULO DE TOTALES DE LA FECHA PROCESO EN bi_indicadores_kiosko';
				SELECT COUNT (*)
				INTO dnregsStg
				--FROM bdibi@coppel_tcp:"informix".bi_indicadores_kiosko
				FROM bdibi@stag_ids1170:"informix".bi_indicadores_kiosko	
				WHERE fecha_proceso = dFechaproceso;

				LET dnregsDif = dnregsCb - dnregsStg;

				LET cEvento = 'CALCULO DE TOTALES GLOBALES EN bi_indicadores_kiosko';
				SELECT COUNT (*)
				INTO dncontaStg
				--FROM bdibi@coppel_tcp:"informix".bi_indicadores_kiosko;
				FROM bdibi@stag_ids1170:"informix".bi_indicadores_kiosko;

				LET dncontaDif = dncontaCb - dncontaStg;

				LET cEvento = 'GUARDA INFORMACION bi_cifras_control';
				--INSERT INTO bdibi@coppel_tcp:"informix".bi_cifras_control (fecha, id_proc, descripcion, fecha_carga, nregs_cb, nregs_stg, nregs_dif,
				INSERT INTO bdibi@stag_ids1170:"informix".bi_cifras_control (fecha, id_proc, descripcion, fecha_carga, nregs_cb, nregs_stg, nregs_dif,
	                                                            nconta_cb, nconta_stg, nconta_dif, import_cb, import_stg, import_dif, nombre_sp)
				VALUES (dFechaproceso, iIndicador, 'ESTADISTICAS DE CLIENTES', CURRENT::DATE, dnregsCb, dnregsStg, dnregsDif, dncontaCb, dncontaStg, dncontaDif, 0, 0, 0,'bdinteg:sp_replica_estadisticas_ctes_bi');

				LET cEvento = 'OBTENCION DE FECHA-HORA FINAL DE REPLICA';
				SELECT DBINFO('utc_to_datetime',sh_curtime)
				INTO dFechafin
				FROM sysmaster:"informix".sysshmvals;

				LET cEvento = 'GUARDA INFORMACION FINAL EN bi_controlprocesos';
				--UPDATE bdibi@coppel_tcp:"informix".bi_controlprocesos
				UPDATE bdibi@stag_ids1170:"informix".bi_controlprocesos
				SET maxfecha_cargada = dFechaproceso, flagfinalizado = 'V', coderror = vCodRet, msgerror = cMensCodRet, fecha_cargafin = dFechafin
				WHERE id_proc = iIndicador
				AND fecha_carga = dFechaProceso;

			COMMIT WORK;
				LET iEnTransaccion = 0;
		
		END IF;
	END IF;
				RETURN vCodRet, cMensCodRet;

END;

END PROCEDURE
DOCUMENT
'EQUIPO:AnÃ¡lisis y diseÃ±o de Mannto.4',
'FECHA:19/06/2015',
'VERSION:20150616',
'MODIFICO: Ingrid Pamela CÃ¡zarez Villegas',
'DESCRIPCION: Se realiza reporte de correos y telÃ©fonos capturatos en altas y mantenimiento de datos de clientes titulares';

CREATE PROCEDURE "informix".sp_traslada_boletos_pbai(p_cve_sorteo char(5), p_fecha_pase DATE)
RETURNING CHAR(5)  AS Codigo_retorno, 
          CHAR(80) AS Mensaje,
          CHAR(1)  AS Reverso,
          CHAR(25) AS StorePro;              
               
    DEFINE vsqlerr           INTEGER; 
    DEFINE v_codigo_retorno	CHAR(5);
    DEFINE v_mensaje	  	    CHAR(80);
    DEFINE v_reverso         CHAR(1);
    DEFINE v_store_pro       CHAR(25);
    DEFINE vrowid      INTEGER;
    DEFINE vd_valida   DATE;
    DEFINE vd_fecha2   DATE;
    DEFINE vd_fsorteo  DATE;
    DEFINE vc_numcte   CHAR(10);
    DEFINE vi_nociudadcoppel  INTEGER;
    DEFINE vi_nocoloniacoppel INTEGER;
    DEFINE vc_nomzonacoppel   CHAR(20);
    DEFINE vc_nomcuidad       CHAR(20);  
    DEFINE vc_nombre          CHAR(25);
    DEFINE vc_telef1          CHAR(10);
    DEFINE vc_telef2          CHAR(13);
    DEFINE vc_domicilio       CHAR(50);
    DEFINE vc_nomcalle        CHAR(20); 
    DEFINE vc_numextcalle     CHAR(10);
    DEFINE vc_nomcolonia      CHAR(20);
    DEFINE vc_nombre_cte   CHAR(45);
    DEFINE vc_cvesorteo    INTEGER;
	DEFINE v_foliosuc CHAR(16);
    DEFINE v_param		  CHAR(5);  -- FMV 21-Sep-10: Parámetro para traer clave de sorteo normal 2010.

    --SET debug file TO "/tmp/traslada_boletos2.out";
    --TRACE ON;

    LET v_codigo_retorno = "00000";
    LET v_mensaje = "Proceso Inicia Correctamente";
    LET v_reverso = '0';
    LET v_store_pro = 'sp_traslada_boletos';
    LET vrowid     = 0;
    LET vd_valida  = (p_fecha_pase - 1 units day);
    LET vd_fsorteo = (vd_valida - 1 units day);

    SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET LOCK MODE TO wait 3;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = 'sp_traslada_boletos';
            RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
    END EXCEPTION;
	   /*VALIDA QUE LA BANDERA DEL CONCURSO 00002 SEA 2*/
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = p_cve_sorteo AND flag_sort = 2) THEN
					
				/*se agrega para optimizacion de busqueda*/
    
				-- FMV 21-Sep-10: Parámetro para traer clave de sorteo normal 2010.
				SELECT valor 
				INTO v_param 
				FROM bdinteg:si_param
				WHERE cod_param = 118;
				
				SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
				INTO vc_cvesorteo
				FROM si_sorteo
				WHERE cve_sorteo = v_param;     -- FMV 21-Sep-10    
				
				IF NOT EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
								 FROM bdinteg:si_sorteo 
								WHERE cve_sorteo = v_param) THEN -- FMV 21-Sep-10 
					LET v_codigo_retorno = "00040";
					LET v_mensaje = "Se Genero Error en si_sorteo, No Existe Sorteo!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;   
				
				IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo
							 FROM bdinteg:si_sorteo
							WHERE cve_sorteo = v_param  -- FMV 21-Sep-10 
							  AND f_fin < vd_fsorteo) THEN                  
					LET v_codigo_retorno = "00042";
					LET v_mensaje = "Se Genero Error en si_sorteo, Sorteo No esta Vigente!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;
				
				--*********************************************************--
				-- Creado por: Francisco Martinez Viveros	
				--Fecha Creacion: 31/AGOSTO/2010
				--Fecha Modifica: 09/NOVIEMBRE/2010 
				--Objetivo: Traspasa los boletos generados diariamente y 
				--          los envia a la tabla historica con los datos del clte.    
				--*********************************************************--

				
				IF (p_fecha_pase is null) THEN
					LET v_codigo_retorno = "00030";
					LET v_mensaje = "Se genero error de Ejecucion, Verifique Fecha Nula!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				-- BGM 08-Nov-2010: se coloca en primera instancia el foreach para actualizar los datos del cliente 
				-- sobre la misma tabla si_boleto
				-- FOREACH 1 
				FOREACH cursor_actual WITH HOLD FOR              
					SELECT {+index (si_boleto idx_si_bol_clte)} fecha, numcte   --FMV 8-NOV-10: SE ADICIONA INDICE               
					INTO vd_fecha2, vc_numcte  
					FROM bdinteg:"informix".si_boleto 
					WHERE fecha = vd_valida 
					AND numcte > '0000000'

					BEGIN WORK;

					-- BGM 08-Nov-2010: se coloca query optimizado por Faviola Martínez.
					-- FMV 09-Nov-2010: Query filtrado por Faviola Martínez, con aquellos Clientes q no tienen datos completos.

					SELECT {+index (SI_CATCALLES idx_catcalles)}
							CAT.numerociudadcoppel,CAT.numerocoloniacoppel,CAT.nombrezonacoppel, 
							CIU.NOMBRECIUDAD, SCA.NOMBRECALLE, SE.nombre,tel1.telefono, tel2.telefono,
							dom.numeroextcalle, CAT.nombrezona    
					  INTO vi_nociudadcoppel, vi_nocoloniacoppel, vc_nomzonacoppel, vc_nomcuidad,
							vc_nomcalle, vc_nombre, vc_telef1, vc_telef2, vc_numextcalle,
							vc_nomcolonia
					FROM BDINTEG:SI_DIRECCIONES_ACTUAL DOM  
					LEFT OUTER JOIN BDINTEG:SI_CATCALLES SCA ON (DOM.NUMEROCALLE = SCA.NUMEROCALLE)
					LEFT OUTER JOIN BDINTEG:SI_CATZONAS CAT ON (DOM.NUMEROCIUDAD = CAT.NUMEROCIUDAD AND DOM.NUMEROCOLONIA = CAT.NUMEROCOLONIA)  
					LEFT JOIN BDINTEG:SI_CATCIUDADES CIU ON (DOM.NUMEROCIUDAD = CIU.NUMEROCIUDAD  )
					LEFT JOIN BDINTEG:SI_ESTADOS SE ON ( DOM.estado   = SE.ESTADO )
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dom.numcte AND tel1.tipo_tel = 1)
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dom.numcte AND tel2.tipo_tel = 2)
					WHERE DOM.NUMCTE = vc_numcte 
					-- AND DOM.SECUENCIA IN (SELECT MAX(SID.SECUENCIA) FROM BDINTEG:SI_DIRECCIONES_ACTUAL SID WHERE SID.NUMCTE = DOM.NUMCTE AND SID.TIPO_DIR = 1 ) 
					AND DOM.TIPO_DIR  = 1;
					
					--FMV: Se Adiciona validacion para los telefonos por si el dato en null
					IF (vc_telef1 IS NULL) OR (vc_telef1= '') THEN 
						LET vc_telef1 = '0';
					END IF;
					
					IF (vc_telef2 IS NULL) OR (vc_telef2= '') THEN 
						LET vc_telef2 = '0';
					END IF;
					
					LET vc_nombre_cte = (SELECT trim(nombre1)||' '||   
												trim(nombre2)||' '||    
												trim(apell_paterno)||' '|| 
												trim(apell_materno)                                            
												FROM bdinteg:si_cliente WHERE numcte = vc_numcte);    
												
					LET vc_domicilio =  trim(vc_nomcalle)||' '||
										trim(vc_numextcalle)||' '||                                                                      
										trim(vc_nomcolonia);
				
					-- BGM 08-Nov-2010: se hace el update sobre si_boleto en lugar de si_boleto_hist
					UPDATE bdinteg:"informix".si_boleto        --{+index (si_mensajes_enviar_his idx_msgs_envhis)}
					SET telefono1 = vc_telef1,
						telefono2 = vc_telef2,
						nombre    = vc_nombre_cte,
						ciudad    = vc_nomcuidad,
						domicilio = vc_domicilio,
						ent_fed = vc_nombre --SE AGREGA PARA GUARDARSE EN LA TABLA
					WHERE CURRENT OF cursor_actual;  
						
					COMMIT WORK;
				END FOREACH; 
				
				IF (v_reverso <> '0') THEN        
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				LET v_codigo_retorno = "00000";
				LET v_mensaje = "Proceso Pase de Boletos, Termino Correctamente!";
				LET v_reverso = '0';         
				LET v_store_pro = 'sp_traslada_boletos';    

				-- BGM 08-Nov-2010: se cambia de posición el FOREACH para que al final haga el traslado a si_boleto_hist, 
				-- pero sin borrar los datos de si_boleto porque los necesitará el sp_detalle_boletos

				FOREACH cursor_inserta WITH HOLD FOR
					SELECT  {+index (si_boleto idx_si_boleto)}numcte, foliosuc
						INTO vc_numcte, v_foliosuc
					--INTO vrowid            
					FROM bdinteg:"informix".si_boleto
					WHERE date(f_registro) = vd_valida 
					AND numcte <> ''
					
					BEGIN WORK;
					
					INSERT INTO --{+index (si_boleto_hist idx_si_boleto_hist)} 
					bdinteg:"informix".si_boleto_hist
					SELECT {+index (si_boleto idx_si_boleto)} *
					FROM bdinteg:"informix".si_boleto
					WHERE numcte = vc_numcte
					  AND foliosuc = v_foliosuc;                                                                 
				COMMIT WORK;                           
				END FOREACH;
	ELSE
		LET v_codigo_retorno = "22222";
        LET v_mensaje = "¡EL SORTEO NAVIDEÑO NO ESTA ACTIVO!";
        LET v_reverso = '1';
        LET v_store_pro = v_store_pro;     
	END IF;			
    
    END;   --begin        
    
    RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
    
END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÁLEZ',
'FECHA DE MODIFICACIÓN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_dispersionlinea_bpi(pidempresa CHAR(3),pnumcte CHAR(9),pnombrearchivo CHAR(20),pSucursal CHAR(10),pUsuario CHAR(10),pTransaccionIva CHAR(5),pTransaccionCargo CHAR(5),pFolioSuc CHAR(20),pCuenta CHAR(20),pIvaDisp MONEY(14,2),pCargoDisp MONEY(14,2))
returning char(5);

--Realizó: Jose Ruben Lopez Hernadez
--Fecha: 26/03/2013
--Actividad:Se unifico la ejecucion de los sp de cargo de iva y de comision 
--BD:bdicheq.

    DEFINE vsqlerr          INTEGER;
    DEFINE vcodret          CHAR(5);
	DEFINE vcodret2         CHAR(5);
	DEFINE vcodret3         CHAR(5);
	DEFINE vcodret4         CHAR(5);
	DEFINE vcodret5         CHAR(5);
	DEFINE vcodret6         CHAR(5);
	DEFINE cFolio 			CHAR(16);
	DEFINE cMensaje 		CHAR(50);
	DEFINE cTransacCargo    CHAR(4);
	DEFINE dFechacargo      DATE;
	DEFINE mSaldoEje        MONEY(14,2);
	DEFINE mRedondeo        MONEY(18,5);
	DEFINE mDispLinea		MONEY;
	DEFINE mMontoTransIvaDisp	MONEY(16,2);
	DEFINE cProducto	 CHAR(4);
	DEFINE cTpoPersona	 CHAR(1);
	
	LET vsqlerr = 0;
    LET vcodret = "00000";
	LET vcodret2 = "00000";
	LET vcodret3="00000";
	LET vcodret4="00000";
	LET vcodret5="00000";
	LET vcodret6="00000";
	LET cFolio = '';
	LET cMensaje = " ";
	LET cTransacCargo='';
	LET dFechacargo='';
	LET mSaldoEje=0;
	LET mRedondeo=0;
	LET mDispLinea = 0.0;
	LET mMontoTransIvaDisp = 0;
	LET cProducto	 = "";
	LET cTpoPersona	 = "";
	
	--SET debug FILE TO "/tmp/sp_dispersionlinea_bpi_2.out";
	--Trace ON;
	

    BEGIN

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
			INSERT INTO bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)VALUES(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,CURRENT);
            RETURN vcodret;
        END IF;
    END EXCEPTION;

	--SET debug FILE TO "/informix/moha/sp_dispersionlinea_bpi.out";
	--Trace ON;

	
    CALL "informix".sp_cargadividearchivonomina_bpi(pnombrearchivo)
		RETURNING vcodret, cFolio, cMensaje;

    IF 	vcodret <> "00000" THEN		
		LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_cargadividearchivonomina_bpi)';
	ELSE
		SELECT producto
		INTO cProducto
		FROM "informix".sc_maechq
		WHERE empresa = "001"
		AND cuenta = pCuenta;
		   
		SELECT tpper_valida
		INTO cTpoPersona
		FROM bdicheq:"informix".sc_producto
		WHERE empresa = "001" 
		AND producto = cProducto;
		
		IF cTpoPersona IN ("2","4","5") AND cProducto <> "2600" THEN
			-- OBTIENE EL IVA
			SELECT valor
			INTO mMontoTransIvaDisp
			FROM bdinteg:"informix".si_param
			WHERE cod_param = 47
			AND empresa = "001";
			--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
			SELECT disp_linea
			INTO mDispLinea
			FROM "informix".sc_maecomtasserv_pm
			WHERE cuenta = pCuenta;
			
			IF mDispLinea IS NOT NULL THEN
				LET pCargoDisp = mDispLinea;
				LET pIvaDisp = pCargoDisp * mMontoTransIvaDisp;
				LET pTransaccionIva = "0260";
				LET pTransaccionCargo = "3255";
			END IF
		END IF
	
		IF pCargoDisp <> 0 THEN--bandera ejecutar los cargos					
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',pSucursal,pUsuario,pTransaccionIva,'',pFolioSuc,pCuenta,0,pIvaDisp,'01','','','')
					INTO vcodret4,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo;
					IF vcodret4="000" THEN
							EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',pSucursal,pUsuario,pTransaccionCargo,'',pFolioSuc,pCuenta,0,pCargoDisp,'01','','','')	
							INTO vcodret5,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo;
							IF vcodret5="000" THEN
								CALL bdicheq:"informix".sp_dispercionnomina_bpi() returning vcodret2;
								IF vcodret2 = "000" THEN 
									LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE CC';
								ELSE
									EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pSucursal,pUsuario,pFolioSuc, 'A')
									INTO vcodret6;	
									LET vcodret = vcodret2;
									LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_dispercionnomina_bpi)';
								END IF
							ELSE
								EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pSucursal,pUsuario,pFolioSuc, 'A')
								INTO vcodret6;	
								LET vcodret = vcodret5;
								LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(cargo_ref CARGO)';	
							END IF
					ELSE
						LET vcodret = vcodret4;
						LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(cargo_ref IVA)';	
					END IF
		ELSE--No se ejecutan los cargos
			CALL "informix".sp_dispercionnomina_bpi() returning vcodret2;
					IF vcodret2 = "000" THEN 
						LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE SC';
					ELSE
						LET vcodret = vcodret2;
						LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_dispercionnomina_bpi)';
					END IF

		END IF
	END IF;

	INSERT INTO bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)VALUES(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,current);
    RETURN vcodret;
    END;

END PROCEDURE;