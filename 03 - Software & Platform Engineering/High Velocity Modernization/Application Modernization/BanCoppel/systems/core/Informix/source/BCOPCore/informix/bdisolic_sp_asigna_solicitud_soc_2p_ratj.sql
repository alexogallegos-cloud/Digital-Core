CREATE PROCEDURE "informix".sp_asigna_solicitud_soc_2p_ratj(pEmpresa CHAR(3), pEjecutivoAtiende CHAR(8))
RETURNING
	CHAR(6) 		AS CodRet,
	CHAR(20) 		AS NumSolicitud,
	CHAR(20) 		AS NumCte;
	
-------------------------------------------------------------------------------------------------------------
-- CONTROL DE CAMBIOS	
-------------------------------------------------------------------------------------------------------------
-- ModificÃÂ³: Gabriela Esmeralda GonzÃÂ¡lez BÃÂ¡ÃÂ±ez
-- Fecha de ModificaciÃÂ³n: 11-02-2019
-- DescripciÃÂ³n: Se modifica el flujo de las solicitudes 
--              para clientes con solicitudes previas canceladas por mesa de control.
-- RQ: RQM 09 501 - ImplementaciÃÂ³n - Flujo para Clientes con Solicitudes Canceladas en Mesa de Control.
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

 --	SET DEBUG FILE TO "/RESPALDOSNEW/gpe/sp_asigna_solicitud_soc.out";
--	TRACE ON; 
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF NVL(pEmpresa, "") = "" OR NVL(pEjecutivoAtiende, "") = "" THEN
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

    BEGIN WORK;

        DELETE FROM "informix".ss_cte_procesando WHERE usuario = pEjecutivoAtiende;

        UPDATE  bdisolic:ss_solicitudes_mc SET ejecutivo_atiende ='' WHERE ejecutivo_atiende = pEjecutivoAtiende AND status_fin = '' AND revisado <> 'S';

--    WHILE nuevasol = 0 
		LET nuevasol = 0;
		LET entrof = 0;
        FOREACH
            SELECT FIRST 1 a.num_solicitud, a.numcte, a.sucursal, 1 region,
            DECODE (NVL(b.numcte,0), 0, 0, 1) idbox,
                 NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1 AND c.evalua_cc = '0' AND evaluacion >=0),0) + 
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc = '0' AND num_solicitud in (SELECT num_solicitud FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1  AND c.evalua_cc = '0' AND evaluacion < 0)),0) +
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc <> '0'),0) score,					
                a.prioridad
            INTO cNumSolicitud, cNumCte, cSucursal,cRegion,cIdBox, cScore, cPrioridad
            FROM bdisolic:"informix".ss_solicitudes_mc a 			 
            LEFT OUTER JOIN bdinteg:si_bitacora_ife b ON ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
            LEFT OUTER JOIN bdisolic:ss_resum_scor_fin c ON (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud)
            WHERE a.empresa = pEmpresa
            AND status_ini = 'MC' AND status_fin = ""
            AND a.sucursal IN 
            (SELECT sucursal
             FROM bdinteg:si_sucursales a, bdinteg:si_catciudades b
             WHERE a.ciudad = b.numerociudad 
             AND tpo_sucursal = 'S'
             AND numero_region IN('5','10','14','666','13'))
             AND ejecutivo_atiende = ''
             AND a.num_solicitud not in 
                    (SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes_mc
                    WHERE status_ini = 'MC'
                    AND (
                           (status_ini = 'MC' AND  status_fin = "")
                            AND NVL(ejecutivo_autoriza,'') ='' 
                            AND NVL(ejecutivo_atiende,'') ='' 
                            AND ((fecha_determinacion + iDiaCambio UNITS DAY < today )
                                    OR 
                                 (fecha_determinacion + iDiaCambio UNITS DAY <= today AND hora_insert <= vHoraAnterior)
                                 )

                        ))
			AND a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where status_solicitud = 'MC') 			
            UNION ALL
            SELECT a.num_solicitud, a.numcte, a.sucursal, 2 region,
            DECODE (NVL(b.numcte,0), 0, 0, 1) idbox,
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1 AND c.evalua_cc = '0' AND evaluacion >=0),0) + 
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc = '0' AND num_solicitud in (SELECT num_solicitud FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 1  AND c.evalua_cc = '0' AND evaluacion < 0)),0) +
                NVL((SELECT evaluacion FROM bdisolic:ss_resumen_scoring WHERE a.empresa = empresa AND a.num_solicitud = num_solicitud AND seccion = 2 AND c.evalua_cc <> '0'),0) score,					
                a.prioridad
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
             AND a.num_solicitud not in 
                    (SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes_mc
                    WHERE status_ini = 'MC'
                    AND (
                           (status_ini = 'MC' AND  status_fin = "")
                            AND NVL(ejecutivo_autoriza,'') ='' 
                            AND NVL(ejecutivo_atiende,'') ='' 
                            AND ((fecha_determinacion + iDiaCambio UNITS DAY < today )
                                    OR 
                                 (fecha_determinacion + iDiaCambio UNITS DAY <= today AND hora_insert <= vHoraAnterior)
                                 )

                        ))
			AND a.num_solicitud in (select num_solicitud from bdisolic:ss_solicitudes where status_solicitud = 'MC') 
            ORDER BY 7 DESC, 6 ASC ,4 ASC ,5 ASC

--			LET cSQL = 'sleep 20';
--            SYSTEM cSQL;

        -- MARCAMOS LA SOLICITUD QUE SE ESTA ATENDIENDO.
            UPDATE "informix".ss_solicitudes_mc SET ejecutivo_atiende = pEjecutivoAtiende WHERE num_solicitud = cNumSolicitud AND sucursal = cSucursal and revisado <> 'S' and ejecutivo_atiende = '';	

            IF DBINFO("sqlca.sqlerrd2") > 0 THEN
                INSERT INTO "informix".ss_cte_procesando(numcte, usuario, fecha_insercion, hora_insercion)
                VALUES(cNumCte, pEjecutivoAtiende, CURRENT, CURRENT HOUR TO SECOND);
				LET nuevasol = 1;
                EXIT FOREACH;
            END IF;
			
			LET entrof = 1;
			
        END FOREACH;

        IF (DBINFO("sqlca.sqlerrd2") = 0 AND nuevasol = 0 and entrof = 0)  THEN
             LET cCodRet = '000002'; -- NO SE ENCUENTRAN SOLICITUDES MC PARA SER ATENDIDAS.
             LET nuevasol = 2;
         END IF;

    --END WHILE;

    COMMIT WORK;

	IF (ven_transacc = 1) THEN
        BEGIN WORK;
	END IF;
		
    RETURN cCodRet, NVL(cNumSolicitud,''), NVL(cNumCte,'');

END
END PROCEDURE;