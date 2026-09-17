CREATE PROCEDURE "informix".sp_ofi_ticketmovtos	(pEmpresa CHAR(3),pNumCredito CHAR(20), pSucursal CHAR(4))
	RETURNING
	CHAR(5) AS COD_RET, 
	CHAR(80) AS MENSAJE_RETORNO,
	CHAR(20) AS NUM_CREDITO,
	CHAR(40) AS DESCRIPCION_PRODUCTO,	
	CHAR(20) AS NUM_CLIENTE,
	CHAR(150) AS NOM_CLIENTE,
	DECIMAL(18,2) AS MONTO_INICIAL,
	DATE AS FECHA_INICIAL,
	DECIMAL(18,2) AS SDO_ULT_CORTE,
	DECIMAL(18,2) AS INT_MORATORIOS,
	DECIMAL(18,2) AS IVA_INT_MORATORIO,
	DECIMAL(18,2) AS USTED_DEBE,
	DECIMAL(18,2) AS SDO_VENCIDO;
	
	---DECLARACIONES
    DEFINE iSqlErr         	INTEGER;
    DEFINE iIsamErr        	INTEGER;
    DEFINE cErrorInfo      	CHAR(80);
    DEFINE cCodRet         	CHAR(6);
    DEFINE cMensajeRet     	CHAR(80);
    DEFINE iNRows          	INTEGER;
	DEFINE cCodRetCD		CHAR(6);   
	DEFINE cMensajeCD 		CHAR(80); 
    DEFINE cNumCredCD 		CHAR(20); 
	DEFINE cNumCteCD 		CHAR(20);  
	DEFINE cNomProductoCD	CHAR(40);
    DEFINE cNumTarjetaCD    CHAR(20); 
    DEFINE cNomCteCD     	CHAR(150);
	DEFINE dSdoUltCorte		DECIMAL(18,2);
	DEFINE dIntereses			MONEY(18,2); 
	DEFINE dIvaIntereses        MONEY(18,2);
	DEFINE dComisionesPendientes MONEY(18,2);
	DEFINE dIvaComisionesPendientes MONEY(18,2); 
	DEFINE dIva					MONEY(18,2); 
	DEFINE dtFecha 				DATE;
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE cCsg_codigo_ret			CHAR(6);
	DEFINE cCsg_mensaje_ret			CHAR(80);
	DEFINE cCsg_num_credito			CHAR(20);
	DEFINE cCsg_cod_tipcred			CHAR(2);
	DEFINE dtCsg_fec_origen			DATE;
	DEFINE dtCsg_fec_prox_pago		DATE;
	DEFINE mCsg_pago_min			MONEY(18,2);
	DEFINE dtCsg_fec_ult_pago		DATE;
	DEFINE iCsg_plazo				INTEGER;
	DEFINE iCsg_pagos_realizados	INTEGER;
	DEFINE mCsg_linea_otorgada		MONEY(18,2);
	DEFINE mCsg_tasa_interes			DECIMAL(9,6);
	DEFINE dCsg_tasa_moratorios		DECIMAL(9,6);
	DEFINE dCsg_monto_sbc			DECIMAL(14,2);
	DEFINE mCsg_cap_vig				MONEY(18,2);
	DEFINE mCsg_cap_trans			MONEY(18,2);
	DEFINE mCsg_cap_vdo_exig		MONEY(18,2);
	DEFINE mCsg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE mCsg_sdo_act_total_cap	MONEY(18,2);
	DEFINE mCsg_int_vig				MONEY(18,2);
	DEFINE mCsg_int_vdo				MONEY(18,2);
	DEFINE mCsg_int_moratorios		MONEY(18,2);
	DEFINE mCsg_int_mes				MONEY(18,2);
	DEFINE mCsg_sdo_act_total_int	MONEY(18,2);
	DEFINE mCsg_iva_int_vig			MONEY(18,2);
	DEFINE mCsg_iva_int_vdo			MONEY(18,2);
	DEFINE mCsg_iva_int_moratorios	MONEY(18,2);
	DEFINE mCsg_iva_int_mes			MONEY(18,2);
	DEFINE mCsg_sdo_act_total_iva	MONEY(18,2);
	DEFINE mCsg_com_pend			MONEY(18,2);
	DEFINE mCsg_iva_com				MONEY(18,2);
	DEFINE mCsg_sdo_retenido		MONEY(18,2);
	DEFINE mCsg_tot_liquidacion		MONEY(18,2);
	DEFINE mCsg_int_devengado		MONEY(18,2);
	DEFINE mCsg_iva_int_devengado	MONEY(18,2);
	DEFINE mCsg_linea_disp			MONEY(18,2);
	DEFINE mCsg_pagos_vdos			MONEY(18,2);
	DEFINE cCsg_desc_status_cred	CHAR(60);
	DEFINE iCsg_id_bloqueo_cred		INTEGER;
	DEFINE cCsg_bloqueo_cta			CHAR(60);
	DEFINE cCsg_id_causa_bloq_cred	CHAR(3);
	DEFINE cCsg_causa_bloqueo_cta	CHAR(50);
	DEFINE cCsg_id_sit_esp_cte		CHAR(1);
	DEFINE iCsg_id_causa_esp_cte	INTEGER;
	DEFINE cCsg_sit_esp_cte			CHAR(75);
	DEFINE cCsg_id_sit_esp_cred		CHAR(1);
	DEFINE iCsg_id_causa_esp_cred	INTEGER;
	DEFINE cCsg_sit_esp_cred		CHAR(75);
	
	---INICIALIZACIONES
    LET iSqlErr            	= 0;
    LET iIsamErr           	= 0;
    LET cErrorInfo         	= "";
    LET cCodRet            	= "00000";
    LET cMensajeRet        	= "PROCESO EXITOSO";
    LET iNRows             	= 0;
	LET cCodRetCD			= "";
	LET cMensajeCD 			= "";
    LET cNumCredCD 			= "";
	LET cNumCteCD 			= "";
	LET cNomProductoCD		= "";
    LET cNumTarjetaCD    	= "";
    LET cNomCteCD     		= "";
	LET dSdoUltCorte		= 0.0;
	LET dIntereses			= 0; 
	LET dIvaIntereses       = 0;
	LET dComisionesPendientes    = 0;
	LET dIvaComisionesPendientes   = 0;
	LET dIva 				= 0;
	LET dtFecha 			= MDY(1,1,1900);
	--VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET cCsg_codigo_ret				= "00000";
	LET cCsg_mensaje_ret			= "";
	LET cCsg_num_credito			= "";
	LET cCsg_cod_tipcred			= "";
	LET dtCsg_fec_origen			= MDY(1,1,1900);
	LET dtCsg_fec_prox_pago			= MDY(1,1,1900);
	LET mCsg_pago_min				= 0.0;
	LET dtCsg_fec_ult_pago			= MDY(1,1,1900);
	LET iCsg_plazo					= 0;
	LET iCsg_pagos_realizados		= 0;
	LET mCsg_linea_otorgada			= 0.0;
	LET mCsg_tasa_interes			= 0.0;
	LET dCsg_tasa_moratorios		= 0.0;
	LET dCsg_monto_sbc				= 0.0;
	LET mCsg_cap_vig				= 0.0;
	LET mCsg_cap_trans				= 0.0;
	LET mCsg_cap_vdo_exig			= 0.0;
	LET mCsg_cap_vdo_no_exig		= 0.0;
	LET mCsg_sdo_act_total_cap		= 0.0;
	LET mCsg_int_vig				= 0.0;
	LET mCsg_int_vdo				= 0.0;
	LET mCsg_int_moratorios			= 0.0;
	LET mCsg_int_mes				= 0.0;
	LET mCsg_sdo_act_total_int		= 0.0;
	LET mCsg_iva_int_vig			= 0.0;
	LET mCsg_iva_int_vdo			= 0.0;
	LET mCsg_iva_int_moratorios		= 0.0;
	LET mCsg_iva_int_mes			= 0.0;
	LET mCsg_sdo_act_total_iva		= 0.0;
	LET mCsg_com_pend				= 0.0;
	LET mCsg_iva_com				= 0.0;
	LET mCsg_sdo_retenido			= 0.0;
	LET mCsg_tot_liquidacion		= 0.0;
	LET mCsg_int_devengado			= 0.0;
	LET mCsg_iva_int_devengado		= 0.0;
	LET mCsg_linea_disp				= 0.0;
	LET mCsg_pagos_vdos				= 0.0;
	LET cCsg_desc_status_cred		= "";
	LET iCsg_id_bloqueo_cred		= 0;
	LET cCsg_bloqueo_cta			= "";
	LET cCsg_id_causa_bloq_cred		= "";
	LET cCsg_causa_bloqueo_cta		= "";
	LET cCsg_id_sit_esp_cte			= "";
	LET iCsg_id_causa_esp_cte		= 0;
	LET cCsg_sit_esp_cte			= "";
	LET cCsg_id_sit_esp_cred		= "";
	LET iCsg_id_causa_esp_cred		= 0;
	LET cCsg_sit_esp_cred			= "";
	
BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet,cMensajeRet,'','','','',0,'',0,0,0,0,0;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_ofi_ticketmovtos.out";
	--TRACE ON;
	-- VALIDA LOS PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,"") =  "" OR NVL(pNumCredito,"") = ""  OR NVL(pSucursal,"") = "" THEN
		LET cCodRet = '00361';
		LET cMensajeRet = 'PARAMETROS DE ENTRADA ESTAN VACIOS';
		RETURN cCodRet,cMensajeRet,'','','','',0,'',0,0,0,0,0;
	END IF 

	-- OBTIENE LOS DATOS DEL PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE "informix".sp_consulta_datos_general 	(pEmpresa, '',pNumCredito,'','','','')
	INTO cCodRetCD,cMensajeCD,cNumCredCD,cNumCteCD,cNomProductoCD,cNumTarjetaCD,cNomCteCD;
	IF cCodRetCD::INTEGER <> 0 THEN
		LET cCodRet = '00363';
		LET cMensajeRet = cMensajeCD;
		RETURN cCodRet,cMensajeRet,'','','','',0,'',0,0,0,0,0;
	END IF
	
	-- OBTIENE LOS SALDOS DEL  PRESTAMO/REESTRUCTURA/CREDINOMINA
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,pNumCredito)
	INTO  cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,dtCsg_fec_prox_pago,mCsg_pago_min,
			dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,mCsg_linea_otorgada,mCsg_tasa_interes,dCsg_tasa_moratorios,
			dCsg_monto_sbc,mCsg_cap_vig,mCsg_cap_trans,mCsg_cap_vdo_exig,mCsg_cap_vdo_no_exig,mCsg_sdo_act_total_cap,mCsg_int_vig,
			mCsg_int_vdo,mCsg_int_moratorios,mCsg_int_mes,mCsg_sdo_act_total_int,mCsg_iva_int_vig,mCsg_iva_int_vdo,mCsg_iva_int_moratorios,
			mCsg_iva_int_mes,mCsg_sdo_act_total_iva,mCsg_com_pend,mCsg_iva_com,mCsg_sdo_retenido,mCsg_tot_liquidacion,mCsg_int_devengado,
			mCsg_iva_int_devengado,mCsg_linea_disp,mCsg_pagos_vdos,cCsg_desc_status_cred,iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,
			cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
			iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;
	IF cCsg_codigo_ret::INTEGER <> 0 THEN
		LET cCodRet = '00364';
		LET cMensajeRet = cCsg_mensaje_ret;
		RETURN cCodRet,cMensajeRet,'','','','',0,'',0,0,0,0,0;
	END IF
	
	--se obtiene el iva de la sucursal	
	SELECT iva  
	INTO dIva
	FROM bdinteg:"informix".si_sucursales 
	WHERE sucursal = pSucursal;
	
	-- OBTENER EL SALDO AL ULTIMO CORTE
	SELECT sdo_cap_insoluto + mto_venc_tra_int + (mto_venc_tra_int * dIva)+ sdo_moratorio +(sdo_moratorio * dIva)+ sdo_retenido +
		   sdo_intereses +(sdo_intereses * dIva) + sdo_no_exig + (sdo_no_exig * dIva), fecha
      INTO dSdoUltCorte,dtFecha
      FROM "informix".sd_maesdoshistcrd h
    WHERE h.empresa = pEmpresa
       AND h.num_credito = pNumCredito
       AND h.fecha   = (SELECT MAX(z.fecha)
                      FROM "informix".sd_maesdoshistcrd z
                      WHERE z.empresa = pEmpresa
                      AND z.num_credito = pNumCredito);
					  
	--se obtienen las comisiones pendientes
	SELECT NVL(SUM(DECODE(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0) +
		   NVL(SUM(DECODE(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
	INTO  dComisionesPendientes
	FROM  "informix".sd_detcomi dc  ,
	"informix".sd_tpcomis tc   
	WHERE dc.num_credito = pNumCredito
	AND fecha_alta = dtFecha
	AND dc.estado_com  = 'A'   
	AND dc.cod_comis   = tc.cod_comis 
	AND tc.comi_o_seg IN ('1','4');			
	  
	LET dIvaComisionesPendientes = dComisionesPendientes * dIva;
	LET dSdoUltCorte = NVL(dSdoUltCorte,0) + NVL(dComisionesPendientes,0) + NVL(dIvaComisionesPendientes,0);

	RETURN cCodRet,cMensajeRet,NVL(cNumCredCD,""),NVL(cNomProductoCD,""),NVL(cNumCteCD,""),NVL(cNomCteCD,""),NVL(mCsg_linea_otorgada,0),NVL(dtCsg_fec_origen,""),
	NVL(dSdoUltCorte,0),NVL(mCsg_int_moratorios,0),NVL(mCsg_iva_int_moratorios,0),NVL(mCsg_tot_liquidacion,0),NVL(mCsg_pagos_vdos,0);
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta con información general del cliente y los saldos del credito', 
'AUTOR: Mohamed Carreón, Jesús Aguilar ',
'FECHA: 29 Abril 2011',
'BD: BDICRED',
'VERSION: 20110429.1641';

CREATE PROCEDURE "informix".sp_consultas_cac_centralpba(pEmpresa          CHAR(3), 
                                                     pSucursal         CHAR(4),
                                                     pFechaInicial     DATE,
                                                     pFechaFinal       DATE,
                                                     pNumSol           CHAR(20),
                                                     pBanCac           CHAR(1),
                                                     pCac_Opt1_1       DECIMAL(5,2),
                                                     pCac_Opt3_1       INTEGER)
RETURNING 
          CHAR(6),          -- Código de Retorno  
          CHAR(80),         -- Mensaje de Retorno
          CHAR(20),         -- Número de Solicitud
          CHAR(20),         -- Número de Cliente
          CHAR(104),        -- Nombre del Cliente
          CHAR(13),         -- RFC
          CHAR(4),          -- Sucursal
          DATE,             -- Fecha Solicitud
          DATE,             -- Fecha Cambio Estatus
          DECIMAL(18,2),    -- Importe de Linea
          DECIMAL(5,2),     -- Eficiencia
          INTEGER,          -- Historial
          DECIMAL(5,2),     -- Puntos 1a Sección
          DECIMAL(5,2),     -- Puntos 2da Sección
          CHAR(2),          -- Estatus
          CHAR(511),        -- Observaciones Anteriores
          DECIMAL(8,2);
                  
DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE iComproboIngresos       INTEGER;
DEFINE iProfPens               INTEGER;
DEFINE cBanCac                 CHAR(1);

DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);

DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;

DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);

DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);

DEFINE dfecha                  CHAR(10);
DEFINE ddia                    CHAR(02);
DEFINE dmes                    CHAR(02);
DEFINE danio                   CHAR(04);


LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;
LET iComproboIngresos          = 0;
LET iProfPens                  = 0;
LET cBanCac                    = '';

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET dfecha                     = '';


-- ** HISTORIAL DE CAMBIOS ** --

--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.

-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la selección principal los 3 tipos de consulta 
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones;
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!
--SET DEBUG FILE TO '/tmp/sp_consultas_CAC_central.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizó la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor 
           INTO dfecha 
           FROM "informix".sd_param 
          WHERE cod_param='030';
     LET pFechaInicial=DATE(dfecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;    
  
FOREACH 

    -- Se obtienen los datos de la solicitud.
     SELECT 
            sol.num_solicitud,         -- Número de Solicitud
            sol.numcte,                -- Número Cte
            sol.sucursal,              -- Sucursal
            sol.status_solicitud,      -- Status Solicitud
            sol.tipo_solicitud,        -- Tipo Solicitud
            sol.monto_solicitado,      -- Monto Solicitado
            sol.fecha_insert,          -- Fecha Insert
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima Autorización
                 THEN NVL(aut.fecha_entrada,date(1))
                 ELSE NVL(esp.fecha_modif,date(1)) 
            END),
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de Autorización
                 THEN NVL(aut.comentario,"")
                 ELSE NVL(esp.comentario,"")
            END),
            NVL(aut.revision_cac,0)
       INTO cNumSolicitud,
            cNumCte,
            cSucursal,
            cStatusSol,
            cTipoSolicitud,
            dMontoSolicitado,
            dtFechaInsert,
            dtFechaModificacion,
            cComentarioAut,
            iRevisionCac
      FROM bdisolic:"informix".ss_solicitudes sol
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
                                                          AND aut.empresa= sol.empresa 
                                                          AND aut.status_solicitud= sol.status_solicitud
                                                          AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
                                                                                   FROM bdisolic:ss_autorizacion aut_aux
                                                                                   WHERE aut_aux.empresa= sol.empresa 
                                                                                   AND aut_aux.num_solicitud= sol.num_solicitud 
                                                                                   AND aut_aux.status_solicitud= sol.status_solicitud)
                                                          AND aut.ejecutivo_auto= aut.ejecutivo_auto)
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa  
                                                                   AND esp.num_solicitud= sol.num_solicitud
                                                                   AND esp.numcte=sol.numcte
                                                                   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0) 
                                                                                         FROM bdisolic:ss_autorizacion_especial AS esp_aux
                                                                                        WHERE esp_aux.empresa= sol.empresa
                                                                                          AND esp_aux.num_solicitud= sol.num_solicitud
                                                                                          AND esp_aux.numcte= sol.numcte)
                                                                   AND sol.status_solicitud= esp.status_nvo)
      Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
     WHERE sol.num_solicitud= (CASE WHEN pNumSol IS NULL THEN sol.num_solicitud ELSE pNumSol END)
       AND sol.empresa= pEmpresa
       AND sol.status_solicitud= (CASE WHEN pBanCac= 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opción de la consulta es CAC, si es asi tendrian que ser solo status "RT"
       AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
       AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
       AND (sol.fecha_insert >= (CASE WHEN pFechaInicial IS NULL THEN sol.fecha_insert ELSE pFechaInicial END) 
       AND  sol.fecha_insert <= (CASE WHEN pFechaFinal IS NULL THEN sol.fecha_insert ELSE pFechaFinal END))
       
       

    -- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
    -- En caso contrario no se mostraria en la consulta.

       IF cStatusSol IN ('CC','BC') THEN
            SELECT COUNT(*)
              INTO iInfoBuro
              FROM bdiburo:"informix".br_traslado AS tras 
        INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud= reg.num_solicitud) 
             WHERE tras.num_solicitud = cNumSolicitud;
             
             IF NVL(iInfoBuro,0) = 0 THEN
                CONTINUE FOREACH;
             END IF;
       END IF;

    -- Se obtienen los datos de la información crediticia en COPPEL/BANCOPPEL.
    
    IF pBanCac= 'S' THEN
        SELECT ef.situacion_pago,         -- Situacion Pago
               ef.meses_historia          -- Meses Historia
          INTO dSituacionPago,
               iMesesHistoria
          FROM bdisolic:"informix".ss_resum_scor_fin AS ef 
         WHERE ef.empresa= pEmpresa
           AND ef.num_solicitud= cNumSolicitud
           AND ef.meses_historia > 13
           AND ef.fuente =  'T' 
           AND NVL(ef.evalua_cc,'') <> '1'; -- No haya tenido malos antecedentes crediticios    
    ELSE 
       SELECT ef.situacion_pago,         -- Situacion Pago
               ef.meses_historia          -- Meses Historia
          INTO dSituacionPago,
               iMesesHistoria
          FROM bdisolic:"informix".ss_resum_scor_fin AS ef 
         WHERE ef.empresa= pEmpresa
           AND ef.num_solicitud= cNumSolicitud;
    END IF
          IF dSituacionPago IS NULL AND iMesesHistoria IS NULL THEN
            CONTINUE FOREACH;
          END IF;

    -- Se obtiene las puntuaciones del scoring que se le realizó al cliente.
    SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
           NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
           NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
           COUNT(num_solicitud) AS cantidad
      INTO dSeccion1,
           dSeccion2,
           dSumaSecciones,
           iCantidad
      FROM bdisolic:"informix".ss_resumen_scoring 
     WHERE empresa= pEmpresa
       AND num_solicitud = cNumSolicitud
       AND seccion IN ('1','2'); 

    IF iCantidad <> 2 THEN 

           LET dSeccion1= 0;
           LET dSeccion2= 0;
           LET dSumaSecciones= 0;

        SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
               COUNT(*) AS cuantos
          INTO dSeccion1, icuantos
          FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:ss_resum_scor_fin rsf
         WHERE rsf.empresa = pEmpresa
           AND rsf.num_solicitud = cNumSolicitud
           AND rsf.empresa = sf.empresa
           AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
           AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
           AND sf.min_mes_hist <= rsf.meses_historia
           AND sf.max_mes_hist >= rsf.meses_historia
           AND sf.min_porc_pago <= rsf.situacion_pago
           AND sf.max_porc_pago >= rsf.situacion_pago;

       FOREACH      
            SELECT sg.empresa, sg.seccion, 
                   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
              INTO cEmpAux, iSecAux, dSeccionAux
              FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:ss_scoring_grupo sg
             WHERE sg.empresa = dc.empresa
               AND sg.grupo = dc.grupo
               AND sg.seccion = dc.seccion
               AND dc.num_solicitud = cNumSolicitud
               AND dc.seccion = '2'
               AND dc.empresa = pEmpresa
          GROUP BY sg.empresa, sg.seccion, sg.agrupar

            LET dSeccion2= dSeccion2 + dSeccionAux;
            LET dSumaSecciones= dSeccion1 + dSeccion2;
   END FOREACH;

   END IF;

       IF pBanCac= "S" THEN

            IF (dSumaSecciones < pCac_Opt1_1) THEN
                  CONTINUE FOREACH;
            END IF;
            {IF pCac_Opt3_1 <> 0 THEN
                IF iRevisionCac <> 0 THEN
                    CONTINUE FOREACH;
                END IF;
            END IF;}

       

       END IF;

 -- Se obtiene el nombre del cliente
    SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
                                              TRIM(nvl(a.nombre2,'')) ||' '||
                                              TRIM(nvl(a.apell_paterno,'')) ||' '||
                                              TRIM(nvl(a.apell_materno,'')),
                                              TRIM(a.razon_social)),
           rfc
      INTO cNombreCte, cRFC
      FROM bdinteg:"informix".si_cliente a
     WHERE a.numcte = cNumCte;


    RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones WITH RESUME;
           
END FOREACH;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'las consultas del Aplicativo CConCac en el central',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 03/01/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultas_cac_centralpba(pEmpresa          CHAR(3), 
                                                     pSucursal         CHAR(4),
                                                     pFechaInicial     DATE,
                                                     pFechaFinal       DATE,
                                                     pNumSol           CHAR(20),
                                                     pBanCac           CHAR(1),
                                                     pCac_Opt1_1       DECIMAL(5,2),
                                                     pCac_Opt3_1       INTEGER,
                                                     pArea             CHAR(2),
                                                     pStatus           CHAR(2),
                                                     pCausa            CHAR(3)
                                                     )
RETURNING 
          CHAR(6),          -- Código de Retorno  
          CHAR(80),         -- Mensaje de Retorno
          CHAR(20),         -- Número de Solicitud
          CHAR(20),         -- Número de Cliente
          CHAR(104),        -- Nombre del Cliente
          CHAR(13),         -- RFC
          CHAR(4),          -- Sucursal
          DATE,             -- Fecha Solicitud
          DATE,             -- Fecha Cambio Estatus
          DECIMAL(18,2),    -- Importe de Linea
          DECIMAL(5,2),     -- Eficiencia
          INTEGER,          -- Historial
          DECIMAL(5,2),     -- Puntos 1a Sección
          DECIMAL(5,2),     -- Puntos 2da Sección
          CHAR(2),          -- Estatus
          CHAR(511),        -- Observaciones Anteriores
          DECIMAL(8,2),     -- Suma de Secciones
		  CHAR(3);          -- Causa del Status
                  
DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE iComproboIngresos       INTEGER;
DEFINE iProfPens               INTEGER;
DEFINE cBanCac                 CHAR(1);

DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);

DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;

DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);

DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);

DEFINE dfecha                  CHAR(10);
DEFINE ddia                    CHAR(02);
DEFINE dmes                    CHAR(02);
DEFINE danio                   CHAR(04);
DEFINE sCausa					CHAR(3);
DEFINE sECCondicion1				VARCHAR(3);
DEFINE nECValor1					DECIMAL(5,2);
DEFINE sECCondicion2				VARCHAR(3);
DEFINE nECValor2					DECIMAL(5,2);
DEFINE sMACCondicion1				VARCHAR(3);
DEFINE nMACValor1					DECIMAL(5,2);
DEFINE sMACCondicion2				VARCHAR(3);
DEFINE nMACValor2					DECIMAL(5,2);
DEFINE sPSCondicion1				VARCHAR(3);
DEFINE nPSValor1					DECIMAL(5,2);
DEFINE sPSCondicion2				VARCHAR(3);
DEFINE nPSValor2					DECIMAL(5,2);

DEFINE iEficiencia              INTEGER; 
DEFINE iMeseshist               INTEGER; 
DEFINE iPuntuacionScoring       INTEGER;

LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;
LET iComproboIngresos          = 0;
LET iProfPens                  = 0;
LET cBanCac                    = '';

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET dfecha                     = '';
LET sCausa						= '';
LET sECCondicion1				= '';
LET nECValor1					= 0.0;
LET sECCondicion2				= '';
LET nECValor2					= 0.0;
LET sMACCondicion1				= '';
LET nMACValor1				= 0.0;
LET sMACCondicion2			= '';
LET nMACValor2				= 0.0;
LET sPSCondicion1				= '';
LET nPSValor1					= 0.0;
LET sPSCondicion2				= '';
LET nPSValor2					= 0.0;
LET iEficiencia             = 0;
LET iMeseshist               = 0; 
LET iPuntuacionScoring      = 0;


-- ** HISTORIAL DE CAMBIOS ** --

--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.

-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la selección principal los 3 tipos de consulta 
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed Carreón 
--07/06/ 2010
--Comentarios: se agregó la causa del status y los filtros para los criterios del cac y mc.

--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validación de eficiencia, meses de historia y puntuación scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(sCausa,'');
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!

--SET DEBUG FILE TO '/home/sysifx/Viridiana/sp_consultas_CAC_central.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizó la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor 
           INTO dfecha 
           FROM "informix".sd_param 
          WHERE cod_param='030';
     LET pFechaInicial=DATE(dfecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;   

  
IF pArea <> '' THEN
--- >>> POR CAC O MC <<< ---
---  OBTIENE LOS CRITERIOS DE EFICIENCIA COPPEL

    SELECT valor1,valor2
      INTO nECValor1,nECValor2
      FROM sd_criterios_consulta_cac
     WHERE id_area = pArea 
       AND tpo_criterio = "01";

---  OBTIENE LOS CRITERIOS DE MESES DE HISTORIA COPPEL
    SELECT valor1,valor2
      INTO nMACValor1,nMACValor2
      FROM sd_criterios_consulta_cac
     WHERE id_area = pArea 
       AND tpo_criterio = "02";

---  OBTIENE LOS CRITERIOS DE PUNTUACION DE SCORING
    SELECT valor1,valor2
      INTO nPSValor1,nPSValor2
      FROM sd_criterios_consulta_cac
     WHERE id_area = pArea 
       AND tpo_criterio = "03";
END IF;

  
FOREACH 
    -- Se obtienen los datos de la solicitud.
     SELECT 
            sol.num_solicitud,         -- Número de Solicitud
            sol.numcte,                -- Número Cte
            sol.sucursal,              -- Sucursal
            sol.status_solicitud,      -- Status Solicitud
            sol.tipo_solicitud,        -- Tipo Solicitud
            sol.monto_solicitado,      -- Monto Solicitado
            sol.fecha_insert,          -- Fecha Insert
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima Autorización
                 THEN NVL(aut.fecha_entrada,date(1))
                 ELSE NVL(esp.fecha_modif,date(1)) 
            END),
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de Autorización
                 THEN NVL(aut.comentario,"")
                 ELSE NVL(esp.comentario,"")
            END),
            NVL(aut.revision_cac,0),
	    aut.causa_solicitud
       INTO cNumSolicitud,
            cNumCte,
            cSucursal,
            cStatusSol,
            cTipoSolicitud,
            dMontoSolicitado,
            dtFechaInsert,
            dtFechaModificacion,
            cComentarioAut,
            iRevisionCac,
			sCausa
      FROM bdisolic:"informix".ss_solicitudes sol
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
                                                          AND aut.empresa= sol.empresa 
                                                          AND aut.status_solicitud= sol.status_solicitud
                                                          AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
                                                                                   FROM bdisolic:ss_autorizacion aut_aux
                                                                                   WHERE aut_aux.empresa= sol.empresa 
                                                                                   AND aut_aux.num_solicitud= sol.num_solicitud 
                                                                                   AND aut_aux.status_solicitud= sol.status_solicitud)
                                                          AND aut.ejecutivo_auto= aut.ejecutivo_auto)
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa  
                                                                   AND esp.num_solicitud= sol.num_solicitud
                                                                   AND esp.numcte=sol.numcte
                                                                   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0) 
                                                                                         FROM bdisolic:ss_autorizacion_especial AS esp_aux
                                                                                        WHERE esp_aux.empresa= sol.empresa
                                                                                          AND esp_aux.num_solicitud= sol.num_solicitud
                                                                                          AND esp_aux.numcte= sol.numcte)
                                                                   AND sol.status_solicitud= esp.status_nvo)
      Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
	LEFT OUTER JOIN bdicred:sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
     WHERE sol.num_solicitud= (CASE WHEN pNumSol IS NULL THEN sol.num_solicitud ELSE pNumSol END)
       AND sol.empresa= pEmpresa
       AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opción de la consulta es CAC, si es asi tendrian que ser solo status "RT"
       AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
       AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
       AND (sol.fecha_insert >= (CASE WHEN pFechaInicial IS NULL THEN sol.fecha_insert ELSE pFechaInicial END) 
			AND  sol.fecha_insert <= (CASE WHEN pFechaFinal IS NULL THEN sol.fecha_insert ELSE pFechaFinal END))
		AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)
		AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
		AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)       

    -- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
    -- En caso contrario no se mostraria en la consulta.

       IF cStatusSol IN ('CC','BC') THEN
            SELECT COUNT(*)
              INTO iInfoBuro
              FROM bdiburo:"informix".br_traslado AS tras 
        INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud= reg.num_solicitud) 
             WHERE tras.num_solicitud = cNumSolicitud;
             
             IF NVL(iInfoBuro,0) = 0 THEN
                CONTINUE FOREACH;
             END IF;
       END IF;

    -- Se obtienen los datos de la información crediticia en COPPEL/BANCOPPEL.  

               SELECT ef.situacion_pago,         -- Situacion Pago
                       ef.meses_historia          -- Meses Historia
                  INTO dSituacionPago,
                       iMesesHistoria
                  FROM bdisolic:"informix".ss_resum_scor_fin AS ef 
                 WHERE ef.empresa= pEmpresa
                   AND ef.num_solicitud= cNumSolicitud;

                  IF dSituacionPago IS NULL AND iMesesHistoria IS NULL THEN
                    CONTINUE FOREACH;
                  END IF;

                IF NVL(pArea, "") <> "" THEN

                      IF NOT ((dSituacionPago >= nECValor1 AND dSituacionPago <= nECValor2) AND 
                               (iMesesHistoria >= nMACValor1 AND iMesesHistoria <=nMACValor2)) THEN

                            CONTINUE FOREACH;
                  END IF;

    END IF;
    -- Se obtiene las puntuaciones del scoring que se le realizó al cliente.
    SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
           NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
           NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
           COUNT(num_solicitud) AS cantidad
      INTO dSeccion1,
           dSeccion2,
           dSumaSecciones,
           iCantidad
      FROM bdisolic:"informix".ss_resumen_scoring 
     WHERE empresa= pEmpresa
       AND num_solicitud = cNumSolicitud
       AND seccion IN ('1','2'); 

    IF iCantidad <> 2 THEN 

           LET dSeccion1= 0;
           LET dSeccion2= 0;
           LET dSumaSecciones= 0;

        SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
               COUNT(*) AS cuantos
          INTO dSeccion1, icuantos
          FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:ss_resum_scor_fin rsf
         WHERE rsf.empresa = pEmpresa
           AND rsf.num_solicitud = cNumSolicitud
           AND rsf.empresa = sf.empresa
           AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
           AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
           AND sf.min_mes_hist <= rsf.meses_historia
           AND sf.max_mes_hist >= rsf.meses_historia
           AND sf.min_porc_pago <= rsf.situacion_pago
           AND sf.max_porc_pago >= rsf.situacion_pago;

       FOREACH      
            SELECT sg.empresa, sg.seccion, 
                   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
              INTO cEmpAux, iSecAux, dSeccionAux
              FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:ss_scoring_grupo sg
             WHERE sg.empresa = dc.empresa
               AND sg.grupo = dc.grupo
               AND sg.seccion = dc.seccion
               AND dc.num_solicitud = cNumSolicitud
               AND dc.seccion = '2'
               AND dc.empresa = pEmpresa
          GROUP BY sg.empresa, sg.seccion, sg.agrupar

            LET dSeccion2= dSeccion2 + dSeccionAux;
            LET dSumaSecciones= dSeccion1 + dSeccion2;
   END FOREACH;

   END IF;

   IF NVL(pArea,"") <> "" THEN
        IF NOT (dSumaSecciones >= nPSValor1 AND dSumaSecciones <= nPSValor2) THEN
                CONTINUE FOREACH;
        END IF;
   END IF;

 -- Se obtiene el nombre del cliente
    SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
                                              TRIM(nvl(a.nombre2,'')) ||' '||
                                              TRIM(nvl(a.apell_paterno,'')) ||' '||
                                              TRIM(nvl(a.apell_materno,'')),
                                              TRIM(a.razon_social)),
           rfc
      INTO cNombreCte, cRFC
      FROM bdinteg:"informix".si_cliente a
     WHERE a.numcte = cNumCte;


    RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(sCausa,'') WITH RESUME;
           
END FOREACH;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'las consultas del Aplicativo CConCac en el central',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 03/01/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_generacion_edocta(pEmpresa CHAR(3), pFechaCorte DATE, pNumcredito CHAR(20))
RETURNING CHAR (6) AS Codret, 
		  CHAR(100) AS Descripcion;

--	'DESCRIPCION:  se actualiza el flag_generacion a 0',
-- 'AUTOR : Elizabeth Anzures Ibarguen',
-- 'FECHA : 26/OCTUBRE/2011',	  
---Definicion de Variables          
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(100);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);

---Inicializaciones
LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Proceso Exitoso";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet=cErrorInfo;
     RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/respaldosbd/Malena/sp_generacion_edocta.out';
--TRACE ON;

	--Validacion de parametros de entrada
	IF (pEmpresa='') OR (pFechaCorte='') OR (pNumcredito = '') OR (pEmpresa IS NULL) OR (pFechaCorte IS NULL) OR (pNumcredito IS NULL) THEN
		LET cCodRet = "000001";
		LET cMensajeRet="Uno o mas parametros de entrada son invalidos";
	ELSE												
			--Se actualiza el campo flag_generacion a 2 para indicar que ya se generó la muestra de los estados de cuenta para esa fecha de corte.
				--se actuliza un 0 ya no se indica si se genera
			UPDATE bdicred:"informix".sd_muestra_edocta 
			SET flag_generacion = 0 
			WHERE fecha_corte= pFechaCorte
			AND num_credito=pNumcredito;
			
			IF dbinfo("sqlca.sqlerrd2") = 0  THEN
				LET cCodRet = "000002";
				LET cMensajeRet="No se actualizó el credito recibido";				
			END IF;
	END IF;
	RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para marcar los creditos que ya les fue generada la muestra de los estados de cuenta para esa fecha de corte',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 02/AGOSTO/2011',
'BD: BDICRED',
'VERSION:20110802.0850';

CREATE PROCEDURE "informix".sp_mec_muestrasximprimir
(
pTipo			CHAR(1),
pUsuario		CHAR(8),
pTarjeta		CHAR(20),
pFechaCorte 	DATE
)

RETURNING
	CHAR(6) AS COD_RET,
	CHAR(20) AS TARJETA;

	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE cCodRet         		CHAR(6);
	DEFINE cNumTarjeta			CHAR(20);
    DEFINE iNRows           	INTEGER;

	---INICIALIZACIONES
    LET iSqlErr            		= 0;
    LET cCodRet            		= '000000';
	LET cNumTarjeta				= '';
	LET iNRows              	= 0;
	
--DESCRIPCION: MOFICICACION: Se valida que no exista en la tabla sd_mec_control para no imprimirse mas de una ves por el mismo usuario', 
--'AUTOR: Elizabeth Anzures ',
--'FECHA: octubre 2011',
BEGIN
    
    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet,NULL;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- VALIDA  EL TIPO DE EJECUCION 
	IF NVL(pTipo,'') = '' OR pTipo NOT IN ('1','2','3') THEN
		LET cCodRet = '000001';
		RETURN cCodRet,NULL;
	END IF
    
	-- VALIDA SI EL TIPO DE EJECUCION DEL SP ES DE CONSULTA
	IF pTipo = '1' THEN
		IF NVL(pUsuario,'') = '' OR NVL(pFechaCorte,'') = '' THEN
			LET cCodRet = '000002';
			RETURN cCodRet,NULL;
		END IF
		-- OBTIENE LAS TARJETAS QUE NO SE HAN IMPRESO
		FOREACH WITH HOLD
			SELECT tarjeta
			INTO cNumTarjeta
			FROM bdicred:'informix'.sd_mec_control
			WHERE usuario = pUsuario AND status = '0' AND fecha_corte = pFechaCorte
			
			RETURN cCodRet,cNumTarjeta WITH RESUME;
		END FOREACH
		
	    LET iNRows = dbinfo("sqlca.sqlerrd2");
	    IF iNRows = 0 THEN
	        LET cCodRet = "000003";
	        RETURN cCodRet,NULL;
	    END IF
	-- VALIDA SI EL TIPO DE JECUCION PARA INSERTAR LAS MUESTRAS A IMPRIMIR
	ELIF pTipo = '2' THEN
		IF NVL(pUsuario,'') = '' OR NVL(pTarjeta,'') = '' OR NVL(pFechaCorte,'') = '' THEN
			LET cCodRet = '000004';
			RETURN cCodRet,NULL;
		END IF
		
		if not exists (SELECT tarjeta FROM bdicred:'informix'.sd_mec_control
			WHERE usuario = pUsuario AND tarjeta = pTarjeta  /*AND status = '0'*/ AND fecha_corte = pFechaCorte ) 
		then
			INSERT INTO bdicred:'informix'.sd_mec_control(usuario,tarjeta,fecha_corte)
			VALUES(pUsuario,pTarjeta,pFechaCorte);
		end if;
		
		RETURN cCodRet,'';
	-- VALIDA SI EL TIPO DE EJECUCION  ES PARA ACTUALIZAR LAS MUESTRAS IMPRESAS
	ELIF pTipo = '3' THEN
		IF NVL(pUsuario,'') = '' OR NVL(pTarjeta,'') = '' OR NVL(pFechaCorte,'') = '' THEN
			LET cCodRet = '000005';
			RETURN cCodRet,NULL;
		END IF
		
		UPDATE bdicred:'informix'.sd_mec_control
		SET status = '1'
		WHERE usuario = pUsuario AND status = '0' AND tarjeta = pTarjeta AND fecha_corte = pFechaCorte;
		
		RETURN cCodRet,'';
	END IF
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para onsultar/insertar/actualizar las muestras por imprimir en el aplicativo de muestras de estados de cuenta (Cmuestreoedoct.exe)', 
'				Tipo de Ejecución:', 
'				 1 > Consulta las muestras que están tienen archivo pdf generado y que están por imprimir.', 
'				 2 > Inserta las muestras que están tienen archivo pdf generado y que están por imprimir.', 
'				 3 > Actualiza la muestras que ya están impresas.', 
'AUTOR: Mohamed Carreón ',
'FECHA: Septiembre 2011',
'VERSION: 20110912.1317';

CREATE PROCEDURE "informix".sp_consulta_respaldo_mec
(
pFechaCorte DATE
)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(20) AS NUM_CREDITO,
	CHAR(20) AS NUM_TARJETA,
	CHAR(2) AS STA_MES_ANTE,
	CHAR(2) AS STA_MES_ACT,
	CHAR(2) AS TIP_LOGICA;
	
	---DECLARACIONES
    DEFINE iSqlErr         	INTEGER;
    DEFINE cCodRet         	CHAR(6);
	DEFINE cNumCredito		CHAR(20);
	DEFINE cNumTarjeta		CHAR(20);
	DEFINE cStaMesAnt		CHAR(2);
	DEFINE cStaMesAct		CHAR(2);
	DEFINE cTipoLogica		CHAR(2);
	
	---INICIALIZACIONES
    LET iSqlErr            	= 0;
    LET cCodRet            	= '000000';
	LET cNumCredito			= '';
	LET cNumTarjeta			= '';
	LET cStaMesAnt			= '';
	LET cStaMesAct			= '';
	LET cTipoLogica			= '';

BEGIN
    
    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet,NULL,NULL,NULL,NULL,NULL;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/has/sp_consulta_respaldo_mec.out';
	--TRACE ON;

	-- VALIDA QUE LA FECHA NO ESTE VACIA
	IF NVL(pFechaCorte,DATE(1)) = DATE(1)  THEN
		LET cCodRet = '000001';
	ELSE
		-- BARRE EL RESPALDO DE  LAS MUESTRAS
		FOREACH
			SELECT num_credito, num_tarjeta, estatus_mes_anterior, estatus_mes_actual, tipo_logica
			INTO cNumCredito, cNumTarjeta, cStaMesAnt, cStaMesAct, cTipoLogica
			FROM bdicred:'informix'.sd_resp_muestra_edocta
			WHERE fecha_corte = pFechaCorte
		
			RETURN cCodRet,cNumCredito,cNumTarjeta,cStaMesAnt,cStaMesAct,cTipoLogica WITH RESUME;
		END FOREACH

		-- VALIDA QUE HAYA DATOS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002';
		END IF
	END IF
   
	RETURN cCodRet,cNumCredito,cNumTarjeta,cStaMesAnt,cStaMesAct,cTipoLogica ;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procediento que realiza la consulta al respaldo de muestras', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2011',
'VERSION: 20111020.1550';

CREATE PROCEDURE "informix".sp_gen_rep_cargo(pTipoReporte CHAR(6),pReversado CHAR(1),pFech_Ini CHAR(10),pFech_Fin CHAR(10))
RETURNING  
	CHAR(6) AS cod_ret, 
	CHAR(80) AS desc_ret,
	CHAR(100)	As concepto,
	CHAR(20)	AS num_credito,
	CHAR(104)	AS nomcte,	
	MONEY(18,2)	AS importe_cargo,	
	MONEY(18,2)	AS cap_vigente,
	MONEY(18,2)	AS cap_transitorio,
	MONEY(18,2)	AS cap_vencido,
	MONEY(18,2)	AS cap_vdo_noexigible,
	MONEY(18,2) AS capital_total,
	MONEY(18,2)	AS int_vigente,
	MONEY(18,2)	AS iva_intvigente,
	MONEY(18,2)	AS interes_vencido,
	MONEY(18,2)	AS iva_interesvencido,
	MONEY(18,2)	AS int_moratorio,
	MONEY(18,2)	AS iva_intmoratorio,
	DATE		AS fecha_mov,
	CHAR(4)		AS transaccion,	
	CHAR(50)	AS descripcion,	
	CHAR(16) AS folio_grupo, 
	CHAR(3) AS cod_cargo, 
	CHAR(16) AS folio_mov, 
	MONEY(14,2) AS sdo_ant_rev,
	MONEY(14,2) AS sdo_post_rev;

DEFINE cCodRet 		     CHAR(6);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cMensajeRet       CHAR(80);	
DEFINE cFolio_Grupo      CHAR(16);
DEFINE cNumcte	   		 CHAR(20);
DEFINE cNum_credito	     CHAR(20);
DEFINE mImporte          MONEY(14,2);
DEFINE cCodigo_cargo     CHAR(2);
DEFINE cDesc_cargo       CHAR(100);
DEFINE cFolio            CHAR(16);
DEFINE dFecha_Aplic      DATE;
DEFINE dFechaIni      DATE;
DEFINE dFechaFin      DATE;
DEFINE dFecha_AplicRev   DATE;
DEFINE iReg              INTEGER;
DEFINE dtFechaHoy        DATE;
DEFINE mSaldoAntRev      MONEY(14,2);
DEFINE mSaldoPostRev     MONEY(14,2);
DEFINE cTransaccion 			CHAR(4);
DEFINE m_cap_vigente			MONEY(18,2);
DEFINE m_cap_transitorio		MONEY(18,2);
DEFINE m_cap_vencido			MONEY(18,2);
DEFINE m_cap_vdo_noexigible		MONEY(18,2);
DEFINE m_int_vigente			MONEY(18,2);
DEFINE m_iva_intvigente			MONEY(18,2);
DEFINE m_interes_vencido		MONEY(18,2);
DEFINE m_iva_interesvencido		MONEY(18,2);
DEFINE m_int_moratorio			MONEY(18,2);
DEFINE m_iva_intmoratorio		MONEY(18,2);
DEFINE cNomCte					VARCHAR(80);
DEFINE mCapital_total			MONEY(18,2);
DEFINE cObservaciones			CHAR(200);
DEFINE cObservacionesRev	    CHAR(200);


LET cCodRet = '000000';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET cErrorInfo = "";
LET cMensajeRet = "CONSULTA EXITOSA";
LET cNumcte = '';
LET cNum_credito = '';
LET cFolio_Grupo = '';
LET mImporte = 0.0;
LET cCodigo_cargo = '';
LET cDesc_cargo = '';
LET cFolio = '';
LET dFecha_Aplic = DATE(1);
LET dFecha_AplicRev = DATE(1);
LET dFechaIni = DATE(1);
LET dFechaFin = DATE(1);
LET iReg = 0;
LET dtFechaHoy = DATE(1);
LET mSaldoAntRev   = 0.0;
LET mSaldoPostRev   = 0.0;
LET cTransaccion = "";
LET m_cap_vigente = 0.0;
LET m_cap_transitorio = 0.0;
LET m_cap_vencido = 0.0;
LET m_cap_vdo_noexigible = 0.0;
LET m_int_vigente = 0.0;
LET m_iva_intvigente = 0.0;
LET m_interes_vencido = 0.0;
LET m_iva_interesvencido = 0.0;
LET m_int_moratorio = 0.0;
LET m_iva_intmoratorio = 0.0;
LET cNomCte = "";
LET mCapital_total = 0.0;
LET cObservaciones = '';
LET cObservacionesRev = '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;         
		 RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
			NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
			NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
			NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
			NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
			NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
       END IF;
    END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_gen_rep_cargo.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	IF NVL(pReversado,"") = "" OR pReversado NOT IN ("N","S") OR
	NVL(pTipoReporte,"") = "" OR pTipoReporte NOT IN ("Manual","Masivo") THEN
		LET cCodRet= "000001";
		LET cMensajeRet = "Parametros de entrada invalidos";
		RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
			NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
			NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
			NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
			NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
			NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
	END IF
	
	--Se obtiene la fecha del dia
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sd_fechas
	WHERE empresa = "001";
	
	--Valida si las fechas recibidas son nulas y si lo es asi las iguala a la fecha del dia
	IF NVL(pFech_Ini,'') =  '' THEN
		LET dFechaIni = dtFechaHoy;		
	ELSE
		LET dFechaIni =  pFech_Ini::DATE;
	END IF;
	
	IF NVL(pFech_Fin,'') =  '' THEN
		LET dFechaFin = dtFechaHoy;
	ELSE
		LET dFechaFin =  pFech_Fin::DATE;
	END IF
	
		
	-- valida que la fecha ini no sea mayor que la fecha fin
    IF dFechaIni > dFechaFin THEN
		LET cCodRet= '000002';
		LET cMensajeRet = "LA FECHA INICIAL ES MAYOR A LA FECHA FINAL";
		RETURN cCodRet,cMensajeRet ,cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
			NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
			NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
			NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
			NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
			NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
    END IF; 
	-- Valida que la fecha fin no sea mayor que la fecha actual
	IF dFechaFin > dtFechaHoy THEN
		LET cCodRet= '000003';
		LET cMensajeRet = "LA FECHA FINAL ES MAYOR A LA FECHA ACTUAL";
		RETURN cCodRet,cMensajeRet , cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
			NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
			NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
			NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
			NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
			NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);
	END IF;
IF pTipoReporte = 'Masivo' THEN	
	FOREACH WITH HOLD 		
		SELECT folio_grupo, num_credito, importe_cargo, cod_cargo, desc_cargo, folio, fecha_cargo,
				fecha_reverso,cap_total_pos,cap_total_ant
			INTO cFolio_Grupo, cNum_credito, mImporte, cCodigo_cargo, cDesc_cargo, cFolio, dFecha_Aplic,
				dFecha_AplicRev,mSaldoAntRev,mSaldoPostRev
		FROM "informix".sd_bitacora_cargos
		WHERE reverso =  pReversado 
		AND folio_grupo <> ""
		AND fecha_cargo BETWEEN dFechaIni AND dFechaFin			
		
		IF pReversado = "S" THEN
			LET dFecha_Aplic = dFecha_AplicRev;
		END IF;
		LET iReg = iReg + 1;
		RETURN cCodRet,cMensajeRet,  cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
			NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
			NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
			NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
			NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
			NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0) WITH RESUME;
	END FOREACH;	
ELIF pTipoReporte = 'Manual' THEN
	FOREACH
		SELECT cod_cargo,desc_cargo,numcte,num_credito,importe_cargo,cap_vig_pos,
				cap_tran_pos, cap_venc_pos,	cap_venc_noexi_pos, cap_total_pos,
				int_vig_ant, iva_int_vig_ant, int_ven_ant, iva_int_ven_ant,
				int_mora_ant, iva_int_mora_ant,fecha_cargo, fecha_reverso,observaciones, observaciones_rev				
		INTO  cCodigo_cargo,cDesc_cargo,cNumcte, cNum_credito,mImporte,m_cap_vigente,m_cap_transitorio,m_cap_vencido,
				m_cap_vdo_noexigible,mCapital_total,m_int_vigente,m_iva_intvigente,m_interes_vencido,
				m_iva_interesvencido,m_int_moratorio,m_iva_intmoratorio,dFecha_Aplic,dFecha_AplicRev,cObservaciones,cObservacionesRev
		FROM "informix".sd_bitacora_cargos 
		WHERE reverso = pReversado
		AND folio_grupo = ""
		AND fecha_cargo  BETWEEN dFechaIni AND dFechaFin	
		
		IF pReversado = "S" THEN
			LET cObservaciones = cObservacionesRev;
			LET dFecha_Aplic = dFecha_AplicRev;
		END IF;
		
		--se obtiene el nombre del cliente			
		SELECT TRIM(nombre1)|| " " || TRIM(nombre2) || " " ||  TRIM(apell_paterno) || " " || TRIM(apell_materno)
		INTO cNomCte
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = cNumcte;
		--se obtiene la transaccion relacionada al concepto
		SELECT transacc
		INTO  cTransaccion
		FROM "informix".sd_conceptoscargoscredito
		WHERE codigo = cCodigo_cargo;

		LET iReg = iReg + 1;
		RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
			NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
			NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
			NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
			NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
			NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0) WITH RESUME;
	END FOREACH;
END IF;
IF iReg =0 THEN
	LET cCodRet = "000004";
    LET cMensajeRet = "No ahi datos con la información proporcionada";  
	RETURN cCodRet,cMensajeRet, cDesc_cargo,NVL(cNum_credito,""),NVL(cNomCte,""),NVL(mImporte,0.0),	
		NVL(m_cap_vigente,0.0),NVL(m_cap_transitorio,0.0),NVL(m_cap_vencido,0.0),NVL(m_cap_vdo_noexigible,0.0),
		NVL(mCapital_total,0.0),NVL(m_int_vigente,0.0),NVL(m_iva_intvigente,0.0),NVL(m_interes_vencido,0.0),
		NVL(m_iva_interesvencido,0.0),NVL(m_int_moratorio,0.0),NVL(m_iva_intmoratorio,0.0),NVL(dFecha_Aplic,DATE(1)),
		NVL(cTransaccion,""),NVL(cObservaciones,""), NVL(cFolio_Grupo,""), NVL(cCodigo_cargo,""), NVL(cFolio,""),
		NVL(mSaldoAntRev,0.0),NVL(mSaldoPostRev,0.0);	
END IF;		
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE INFORMACION PARA GENERACION DE REPORTE DE CARGOS MANUALES Y MASIVOS', 
'AUTOR: JESUS MANUEL AGUILAR HEREDIA',
'FECHA: JULIO 2011',
'VERSION: 20110720.1253',
'BD: BDICRED',
'DESCRIPCION: SE MODIFICA PARA NO REALIZAR CAMBIOS EN LA FECHAS QUE SE RECIBEN COMO PARAMETROS DE ENTRADA, Y HOMOLGARLO CON LA VERSION DE APLICACION DE PAGOS', 
'AUTOR: JESUS MANUEL AGUILAR HEREDIA',
'FECHA: AGOSTO 2011',
'VERSION: 20110829.1253',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_grabarcargosmanuales
(
	p_Empresa					CHAR(3),
	p_Usuario					CHAR(8),
	p_FolioSuc					CHAR(16),
	p_NumCte					CHAR(20),
	p_NumCredito				CHAR(20),
	p_ImporteCargo 				MONEY(18,2),
	p_Transaccion				CHAR(4),
	p_Concepto					CHAR(20),
	p_Observaciones				CHAR(200),
	p_CapitalVigente			MONEY(18,2),
	p_CapitalTransitorio		MONEY(18,2),
	p_CapitalVencido			MONEY(18,2),
	p_CapitalVdoNoExigible		MONEY(18,2),
	p_CapitalTotal				MONEY(18,2),
	p_InteresVigente			MONEY(18,2),
	p_IvaInteresVigente			MONEY(18,2),
	p_InteresVencido			MONEY(18,2),
	p_IvaInteresVencido			MONEY(18,2),
	p_InteresMoratorio			MONEY(18,2),
	p_IvaInteresMoratorio		MONEY(18,2),
	p_codigo                    CHAR(2)
)
RETURNING
	CHAR(5) AS COD_RET,
	MONEY(18,2) AS CapitalVigente,
	MONEY(18,2) AS CapitalTransitorio,
	MONEY(18,2) AS CapitalVencido,
	MONEY(18,2) AS CapitalVdoNoExigible,
	MONEY(18,2) AS CapitalTotal,
	MONEY(18,2) AS InteresVigente,
	MONEY(18,2) AS IvaInteresVigente,
	MONEY(18,2) AS InteresVencido,
	MONEY(18,2) AS IvaInteresVencido,
	MONEY(18,2) AS InteresMoratorio,
	MONEY(18,2) AS IvaInteresMoratorio;

---DECLARACIONES
	DEFINE v_cod_ret				 CHAR(5);
	DEFINE iSqlErr					INTEGER;
	DEFINE iSamErr					INTEGER;

	DEFINE s_Sucursal				CHAR(4);
	DEFINE s_NumProducto			CHAR(4);
	DEFINE dFecha_Hoy				DATE;
	DEFINE dFecha_dia               DATE;
	DEFINE dHora                    CHAR(8); 
	DEFINE cFolioCargo              CHAR(16);
	DEFINE iBandera                INTEGER;	
	DEFINE cBanderaReversion       CHAR(1);	

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE csg_codigo_ret			CHAR(6);
	DEFINE csg_mensaje_ret			CHAR(80);
	DEFINE csg_num_credito			CHAR(20);
	DEFINE csg_cod_tipcred			CHAR(2);
	DEFINE csg_fec_origen			DATE;
	DEFINE csg_fec_prox_pago		DATE;
	DEFINE csg_pago_min				MONEY(18,2);
	DEFINE csg_fec_ult_pago			DATE;
	DEFINE csg_plazo				INTEGER;
	DEFINE csg_pagos_realizados		INTEGER;
	DEFINE csg_linea_otorgada		MONEY(18,2);
	DEFINE csg_tasa_interes			DECIMAL(9,6);
	DEFINE csg_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg_monto_sbc			DECIMAL(14,2);
	DEFINE csg_cap_vig				MONEY(18,2);
	DEFINE csg_cap_trans			MONEY(18,2);
	DEFINE csg_cap_vdo_exig			MONEY(18,2);
	DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg_int_vig				MONEY(18,2);
	DEFINE csg_int_vdo				MONEY(18,2);
	DEFINE csg_int_moratorios		MONEY(18,2);
	DEFINE csg_int_mes				MONEY(18,2);
	DEFINE csg_sdo_act_total_int	MONEY(18,2);
	DEFINE csg_iva_int_vig			MONEY(18,2);
	DEFINE csg_iva_int_vdo			MONEY(18,2);
	DEFINE csg_iva_int_moratorios	MONEY(18,2);
	DEFINE csg_iva_int_mes			MONEY(18,2);
	DEFINE csg_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg_com_pend				MONEY(18,2);
	DEFINE csg_iva_com				MONEY(18,2);
	DEFINE csg_sdo_retenido			MONEY(18,2);
	DEFINE csg_tot_liquidacion		MONEY(18,2);
	DEFINE csg_int_devengado		MONEY(18,2);
	DEFINE csg_iva_int_devengado	MONEY(18,2);
	DEFINE csg_linea_disp			MONEY(18,2);
	DEFINE csg_pagos_vdos			MONEY(18,2);
	DEFINE csg_desc_status_cred		CHAR(60);
	DEFINE csg_id_bloqueo_cred		INTEGER;
	DEFINE csg_bloqueo_cta			CHAR(60);
	DEFINE csg_id_causa_bloq_cred	CHAR(3);
	DEFINE csg_causa_bloqueo_cta	CHAR(50);
	DEFINE csg_id_sit_esp_cte		CHAR(1);
	DEFINE csg_id_causa_esp_cte		INTEGER;
	DEFINE csg_sit_esp_cte			CHAR(75);
	DEFINE csg_id_sit_esp_cred		CHAR(1);
	DEFINE csg_id_causa_esp_cred	INTEGER;
	DEFINE csg_sit_esp_cred			CHAR(75);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_datos_general
	DEFINE dat_codigo_ret           CHAR(6);
	DEFINE dat_Mensaje_ret          CHAR(80);
	DEFINE dat_Num_Cred             CHAR(20);
	DEFINE dat_Num_Cte              CHAR(20);
	DEFINE dat_Nom_Pdcto            CHAR(40);
	DEFINE dat_Num_Tarjeta          CHAR(20);
	DEFINE dat_Nom_Cte              CHAR(150);
	 
	
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE cargoref_tc_ofi
	DEFINE car_Cod_Ret              CHAR(6);
	DEFINE car_Sald_Disp            DECIMAL(14,2);
	DEFINE car_Impor_Cgdo           DECIMAL(14,2);
	DEFINE car_Imp_comi             DECIMAL(14,2);
	DEFINE car_Iva_comi             DECIMAL(14,2);
	
			 
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL CARGO
	DEFINE csg2_codigo_ret			CHAR(6);
	DEFINE csg2_mensaje_ret			CHAR(80);
	DEFINE csg2_num_credito			CHAR(20);
	DEFINE csg2_cod_tipcred			CHAR(2);
	DEFINE csg2_fec_origen			DATE;
	DEFINE csg2_fec_prox_pago		DATE;
	DEFINE csg2_pago_min			MONEY(18,2);
	DEFINE csg2_fec_ult_pago		DATE;
	DEFINE csg2_plazo				INTEGER;
	DEFINE csg2_pagos_realizados	INTEGER;
	DEFINE csg2_linea_otorgada		MONEY(18,2);
	DEFINE csg2_tasa_interes		DECIMAL(9,6);
	DEFINE csg2_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg2_monto_sbc			DECIMAL(14,2);
	DEFINE csg2_cap_vig				MONEY(18,2);
	DEFINE csg2_cap_trans			MONEY(18,2);
	DEFINE csg2_cap_vdo_exig		MONEY(18,2);
	DEFINE csg2_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg2_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg2_int_vig				MONEY(18,2);
	DEFINE csg2_int_vdo				MONEY(18,2);
	DEFINE csg2_int_moratorios		MONEY(18,2);
	DEFINE csg2_int_mes				MONEY(18,2);
	DEFINE csg2_sdo_act_total_int	MONEY(18,2);
	DEFINE csg2_iva_int_vig			MONEY(18,2);
	DEFINE csg2_iva_int_vdo			MONEY(18,2);
	DEFINE csg2_iva_int_moratorios	MONEY(18,2);
	DEFINE csg2_iva_int_mes			MONEY(18,2);
	DEFINE csg2_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg2_com_pend			MONEY(18,2);
	DEFINE csg2_iva_com				MONEY(18,2);
	DEFINE csg2_sdo_retenido		MONEY(18,2);
	DEFINE csg2_tot_liquidacion		MONEY(18,2);
	DEFINE csg2_int_devengado		MONEY(18,2);
	DEFINE csg2_iva_int_devengado	MONEY(18,2);
	DEFINE csg2_linea_disp			MONEY(18,2);
	DEFINE csg2_pagos_vdos			MONEY(18,2);
	DEFINE csg2_desc_status_cred	CHAR(60);
	DEFINE csg2_id_bloqueo_cred		INTEGER;
	DEFINE csg2_bloqueo_cta			CHAR(60);
	DEFINE csg2_id_causa_bloq_cred	CHAR(3);
	DEFINE csg2_causa_bloqueo_cta	CHAR(50);
	DEFINE csg2_id_sit_esp_cte		CHAR(1);
	DEFINE csg2_id_causa_esp_cte	INTEGER;
	DEFINE csg2_sit_esp_cte			CHAR(75);
	DEFINE csg2_id_sit_esp_cred		CHAR(1);
	DEFINE csg2_id_causa_esp_cred	INTEGER;
	DEFINE csg2_sit_esp_cred		CHAR(75);
	DEFINE dMes                     CHAR(2);
	DEFINE dDia                     CHAR(2);	
	---INICIALIZACIONES
	LET v_cod_ret = "00000";
	LET s_Sucursal					= "";
	LET s_NumProducto				= "";
	LET dFecha_Hoy					= MDY(1,1,1900);
	LET dFecha_dia                  = DATE(1);
	LET dHora                       = "";
	LET cFolioCargo					= "";
	LET iBandera                    = 0;		
	LET cBanderaReversion           = "N";		
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET csg_codigo_ret				= "000000";
	LET csg_mensaje_ret				= "";
	LET csg_num_credito				= "";
	LET csg_cod_tipcred				= "";
	LET csg_fec_origen				= MDY(1,1,1900);
	LET csg_fec_prox_pago			= MDY(1,1,1900);
	LET csg_pago_min				= 0.0;
	LET csg_fec_ult_pago			= MDY(1,1,1900);
	LET csg_plazo					= 0;
	LET csg_pagos_realizados		= 0;
	LET csg_linea_otorgada			= 0.0;
	LET csg_tasa_interes			= 0.0;
	LET csg_tasa_moratorios			= 0.0;
	LET csg_monto_sbc				= 0.0;
	LET csg_cap_vig					= 0.0;
	LET csg_cap_trans				= 0.0;
	LET csg_cap_vdo_exig			= 0.0;
	LET csg_cap_vdo_no_exig			= 0.0;
	LET csg_sdo_act_total_cap		= 0.0;
	LET csg_int_vig					= 0.0;
	LET csg_int_vdo					= 0.0;
	LET csg_int_moratorios			= 0.0;
	LET csg_int_mes					= 0.0;
	LET csg_sdo_act_total_int		= 0.0;
	LET csg_iva_int_vig				= 0.0;
	LET csg_iva_int_vdo				= 0.0;
	LET csg_iva_int_moratorios		= 0.0;
	LET csg_iva_int_mes				= 0.0;
	LET csg_sdo_act_total_iva		= 0.0;
	LET csg_com_pend				= 0.0;
	LET csg_iva_com					= 0.0;
	LET csg_sdo_retenido			= 0.0;
	LET csg_tot_liquidacion			= 0.0;
	LET csg_int_devengado			= 0.0;
	LET csg_iva_int_devengado		= 0.0;
	LET csg_linea_disp				= 0.0;
	LET csg_pagos_vdos				= 0.0;
	LET csg_desc_status_cred		= "";
	LET csg_id_bloqueo_cred			= 0;
	LET csg_bloqueo_cta				= "";
	LET csg_id_causa_bloq_cred		= "";
	LET csg_causa_bloqueo_cta		= "";
	LET csg_id_sit_esp_cte			= "";
	LET csg_id_causa_esp_cte		= 0;
	LET csg_sit_esp_cte				= "";
	LET csg_id_sit_esp_cred			= "";
	LET csg_id_causa_esp_cred		= 0;
	LET csg_sit_esp_cred			= "";	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_datos_general
	LET dat_codigo_ret           	= "";
	LET dat_Mensaje_ret          	= "";
	LET dat_Num_Cred             	= "";
	LET dat_Num_Cte              	= "";
	LET dat_Nom_Pdcto            	= "";
	LET dat_Num_Tarjeta          	= "";
	LET dat_Nom_Cte              	= "";		
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE cargoref_tc_ofi
	LET car_Cod_Ret                 = "";
	LET car_Sald_Disp           	= 0.0;
	LET car_Impor_Cgdo           	= 0.0;
	LET car_Imp_comi             	= 0.0;
	LET car_Iva_comi             	= 0.0;	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL CARGO
	LET csg2_codigo_ret				= "";
	LET csg2_mensaje_ret			= "";
	LET csg2_num_credito			= "";
	LET csg2_cod_tipcred			= "";
	LET csg2_fec_origen				= MDY(1,1,1900);
	LET csg2_fec_prox_pago			= MDY(1,1,1900);
	LET csg2_pago_min				= 0.0;
	LET csg2_fec_ult_pago			= MDY(1,1,1900);
	LET csg2_plazo					= 0;
	LET csg2_pagos_realizados		= 0;
	LET csg2_linea_otorgada			= 0.0;
	LET csg2_tasa_interes			= 0.0;
	LET csg2_tasa_moratorios		= 0.0;
	LET csg2_monto_sbc				= 0.0;
	LET csg2_cap_vig				= 0.0;
	LET csg2_cap_trans				= 0.0;
	LET csg2_cap_vdo_exig			= 0.0;
	LET csg2_cap_vdo_no_exig		= 0.0;
	LET csg2_sdo_act_total_cap		= 0.0;
	LET csg2_int_vig				= 0.0;
	LET csg2_int_vdo				= 0.0;
	LET csg2_int_moratorios			= 0.0;
	LET csg2_int_mes				= 0.0;
	LET csg2_sdo_act_total_int		= 0.0;
	LET csg2_iva_int_vig			= 0.0;
	LET csg2_iva_int_vdo			= 0.0;
	LET csg2_iva_int_moratorios		= 0.0;
	LET csg2_iva_int_mes			= 0.0;
	LET csg2_sdo_act_total_iva		= 0.0;
	LET csg2_com_pend				= 0.0;
	LET csg2_iva_com				= 0.0;
	LET csg2_sdo_retenido			= 0.0;
	LET csg2_tot_liquidacion		= 0.0;
	LET csg2_int_devengado			= 0.0;
	LET csg2_iva_int_devengado		= 0.0;
	LET csg2_linea_disp				= 0.0;
	LET csg2_pagos_vdos				= 0.0;
	LET csg2_desc_status_cred		= "";
	LET csg2_id_bloqueo_cred		= 0;
	LET csg2_bloqueo_cta			= "";
	LET csg2_id_causa_bloq_cred		= "";
	LET csg2_causa_bloqueo_cta		= "";
	LET csg2_id_sit_esp_cte			= "";
	LET csg2_id_causa_esp_cte		= 0;
	LET csg2_sit_esp_cte			= "";
	LET csg2_id_sit_esp_cred		= "";
	LET csg2_id_causa_esp_cred		= 0;
	LET csg2_sit_esp_cred			= "";
	LET dMes                        = "";
	LET dDia                        = "";
BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
		IF cBanderaReversion ='S' THEN
			CALL "informix".reversion ('001', '9350', p_Usuario,p_FolioSuc,"A") Returning v_cod_ret;	
		END IF;
        IF iSqlErr <> 0 THEN
			LET v_cod_ret = iSqlErr;
        END IF;		
        RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_grabarcargosmanuales.out";
	--TRACE ON;
	
	SELECT fecha_hoy
	INTO dFecha_Hoy
	FROM "informix".sd_fechas;
	
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
	INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
			csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
			csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
			csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
			csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
			csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
			csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
			csg_id_causa_esp_cred,csg_sit_esp_cred;

	IF csg_codigo_ret::INTEGER <> 0 THEN
		LET v_cod_ret = "00001";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	----CHECAR SI TAMBIEN SE VALIDARA ESTO 
	--- VALIDAR QUE LOS SALDOS DE LA APLICACION SEAN LOS MISMO QUE LOS DE LA BASE DE DATOS
	IF (p_CapitalVigente <> csg_cap_vig) OR (p_CapitalTransitorio <> csg_cap_trans) OR (p_CapitalVencido <> csg_cap_vdo_exig)
		OR (p_CapitalVdoNoExigible <> csg_cap_vdo_no_exig) OR (p_CapitalTotal <> csg_sdo_act_total_cap) OR (p_InteresVigente <> csg_int_vig)
		OR (p_IvaInteresVigente <> csg_iva_int_vig) OR (p_InteresVencido <> csg_int_vdo) OR (p_IvaInteresVencido <> csg_iva_int_vdo) 
		OR (p_InteresMoratorio <> csg_int_moratorios) OR (p_IvaInteresMoratorio <> csg_iva_int_moratorios) THEN
		LET v_cod_ret = "00002";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF


    SELECT trim(valor) 
    INTO s_Sucursal   ---Sucursal   '9250'
    FROM "informix".sd_param
    WHERE empresa = '001'
    AND cod_param = '28';

    IF s_Sucursal = '' OR s_Sucursal IS NULL THEN
		LET v_cod_ret = "00006";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END IF;
	 
	---OBTENER EL NUMERO DE  TARJETA DEL CREDITO  EN CUESTION
	EXECUTE PROCEDURE "informix".sp_consulta_datos_general(p_Empresa, '', p_NumCredito,'','','','')
	INTO dat_codigo_ret, dat_Mensaje_ret, dat_Num_Cred, dat_Num_Cte, dat_Nom_Pdcto, dat_Num_Tarjeta, dat_Nom_Cte;

	
	--- REALIZA EL CARGO AL CREDITO EN CUESTION	
	EXECUTE PROCEDURE "informix".cargoref_tc_ofi(p_Empresa, s_Sucursal, p_Usuario, dat_Num_Tarjeta, p_ImporteCargo, p_FolioSuc, p_Transaccion )
	INTO car_Cod_Ret, car_Sald_Disp, car_Impor_Cgdo, car_Imp_comi, car_Iva_comi;

	IF car_Cod_Ret::INTEGER = 8 THEN
		LET v_cod_ret = "00005";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	ELIF car_Cod_Ret::INTEGER <> 0 THEN
		LET v_cod_ret = "00003";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	LET cBanderaReversion = "S";
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO DESPUES DEL CARGO
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
	INTO csg2_codigo_ret,csg2_mensaje_ret,csg2_num_credito,csg2_cod_tipcred,csg2_fec_origen,csg2_fec_prox_pago,csg2_pago_min,
			csg2_fec_ult_pago,csg2_plazo,csg2_pagos_realizados,csg2_linea_otorgada,csg2_tasa_interes,csg2_tasa_moratorios,
			csg2_monto_sbc,csg2_cap_vig,csg2_cap_trans,csg2_cap_vdo_exig,csg2_cap_vdo_no_exig,csg2_sdo_act_total_cap,csg2_int_vig,
			csg2_int_vdo,csg2_int_moratorios,csg2_int_mes,csg2_sdo_act_total_int,csg2_iva_int_vig,csg2_iva_int_vdo,csg2_iva_int_moratorios,
			csg2_iva_int_mes,csg2_sdo_act_total_iva,csg2_com_pend,csg2_iva_com,csg2_sdo_retenido,csg2_tot_liquidacion,csg2_int_devengado,
			csg2_iva_int_devengado,csg2_linea_disp,csg2_pagos_vdos,csg2_desc_status_cred,csg2_id_bloqueo_cred,csg2_bloqueo_cta,
			csg2_id_causa_bloq_cred,csg2_causa_bloqueo_cta,csg2_id_sit_esp_cte,csg2_id_causa_esp_cte,csg2_sit_esp_cte,csg2_id_sit_esp_cred,
			csg2_id_causa_esp_cred,csg2_sit_esp_cred;

	IF csg2_codigo_ret::INTEGER <> 0 THEN
		LET v_cod_ret = "00004";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	
	--- INSERTA LA COLUMNA DE SALDO ACTUAL
	INSERT INTO "informix".sd_bitacora_cargos 
				(numcte,num_credito, fecha_cargo,hora_cargo, fecha_reverso, hora_reverso, importe_cargo, cap_vig_ant, cap_tran_ant, cap_venc_ant, cap_venc_noexi_ant,
				cap_total_ant, int_vig_ant, iva_int_vig_ant, int_ven_ant, iva_int_ven_ant, int_mora_ant, iva_int_mora_ant, cap_vig_pos,
				cap_tran_pos, cap_venc_pos,	cap_venc_noexi_pos, cap_total_pos, cod_cargo, desc_cargo, resultado, folio, folio_grupo, reverso, observaciones,observaciones_rev,usuario)
	VALUES (dat_Num_Cte,p_NumCredito,dFecha_Hoy,CURRENT,'','',p_ImporteCargo, csg_cap_vig, csg_cap_trans, csg_cap_vdo_exig, csg_cap_vdo_no_exig,
			csg_sdo_act_total_cap, csg_int_vig, csg_iva_int_vig, csg_int_vdo, csg_iva_int_vdo, csg_int_moratorios, csg_iva_int_moratorios, csg2_cap_vig,
			csg2_cap_trans, csg2_cap_vdo_exig, csg2_cap_vdo_no_exig, csg2_sdo_act_total_cap, p_codigo, p_Concepto,"OK", p_FolioSuc, '',"N",p_Observaciones,"",p_Usuario);
	

	RETURN v_cod_ret, csg2_cap_vig - csg_cap_vig, csg2_cap_trans-csg_cap_trans , csg2_cap_vdo_exig-csg_cap_vdo_exig ,
			csg2_cap_vdo_no_exig - csg_cap_vdo_no_exig, csg2_sdo_act_total_cap - csg_sdo_act_total_cap, csg2_int_vig - csg_int_vig, 
			csg2_iva_int_vig - csg_iva_int_vig, csg2_int_vdo - csg_int_vdo,
			csg2_iva_int_vdo - csg_iva_int_vdo, csg2_int_moratorios - csg_int_moratorios,
			csg2_iva_int_moratorios - csg2_iva_int_moratorios;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR :Héctor Manuel Bojorquez Ruelas,Jesus Manuel Aguilar Heredia',
'DESCRIPCION: Procedimiento que Realiza el Cargo Manual validando que los saldos en pantallas sean los ultimos datos y hace registro en bitácora.',
'Crédito',
'FECHA : JULIO de 2011',
'VERSION: 20100118.2023',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_grabarcargosmasivos
(
	p_Empresa					CHAR(3),
	p_Usuario					CHAR(8),
	p_FolioGpo					CHAR(16),
	p_NumCredito				CHAR(20),
	p_ImporteCargo 				MONEY(18,2),
	p_Transaccion				CHAR(4),
	p_codigo                    CHAR(2), 
	p_DesCodigo  				CHAR(50),
	p_Concepto					CHAR(50)
	
)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(16) AS FolioPago;

---DECLARACIONES
	DEFINE v_cod_ret				 CHAR(6);
	DEFINE iSqlErr					INTEGER;
	DEFINE iSamErr					INTEGER;

	DEFINE s_Sucursal				CHAR(4);
	DEFINE dFecha_dia               DATE;
	DEFINE dHora                    CHAR(8); 
	DEFINE cFolioCargo              CHAR(16);
	DEFINE iBandera                 INTEGER;
	DEFINE cBanderaReversion        CHAR(1);
	
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE csg_codigo_ret			CHAR(6);
	DEFINE csg_mensaje_ret			CHAR(80);
	DEFINE csg_num_credito			CHAR(20);
	DEFINE csg_cod_tipcred			CHAR(2);
	DEFINE csg_fec_origen			DATE;
	DEFINE csg_fec_prox_pago		DATE;
	DEFINE csg_pago_min				MONEY(18,2);
	DEFINE csg_fec_ult_pago			DATE;
	DEFINE csg_plazo				INTEGER;
	DEFINE csg_pagos_realizados		INTEGER;
	DEFINE csg_linea_otorgada		MONEY(18,2);
	DEFINE csg_tasa_interes			DECIMAL(9,6);
	DEFINE csg_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg_monto_sbc			DECIMAL(14,2);
	DEFINE csg_cap_vig				MONEY(18,2);
	DEFINE csg_cap_trans			MONEY(18,2);
	DEFINE csg_cap_vdo_exig			MONEY(18,2);
	DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg_int_vig				MONEY(18,2);
	DEFINE csg_int_vdo				MONEY(18,2);
	DEFINE csg_int_moratorios		MONEY(18,2);
	DEFINE csg_int_mes				MONEY(18,2);
	DEFINE csg_sdo_act_total_int	MONEY(18,2);
	DEFINE csg_iva_int_vig			MONEY(18,2);
	DEFINE csg_iva_int_vdo			MONEY(18,2);
	DEFINE csg_iva_int_moratorios	MONEY(18,2);
	DEFINE csg_iva_int_mes			MONEY(18,2);
	DEFINE csg_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg_com_pend				MONEY(18,2);
	DEFINE csg_iva_com				MONEY(18,2);
	DEFINE csg_sdo_retenido			MONEY(18,2);
	DEFINE csg_tot_liquidacion		MONEY(18,2);
	DEFINE csg_int_devengado		MONEY(18,2);
	DEFINE csg_iva_int_devengado	MONEY(18,2);
	DEFINE csg_linea_disp			MONEY(18,2);
	DEFINE csg_pagos_vdos			MONEY(18,2);
	DEFINE csg_desc_status_cred		CHAR(60);
	DEFINE csg_id_bloqueo_cred		INTEGER;
	DEFINE csg_bloqueo_cta			CHAR(60);
	DEFINE csg_id_causa_bloq_cred	CHAR(3);
	DEFINE csg_causa_bloqueo_cta	CHAR(50);
	DEFINE csg_id_sit_esp_cte		CHAR(1);
	DEFINE csg_id_causa_esp_cte		INTEGER;
	DEFINE csg_sit_esp_cte			CHAR(75);
	DEFINE csg_id_sit_esp_cred		CHAR(1);
	DEFINE csg_id_causa_esp_cred	INTEGER;
	DEFINE csg_sit_esp_cred			CHAR(75);
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_datos_general
	DEFINE dat_codigo_ret           CHAR(6);
	DEFINE dat_Mensaje_ret          CHAR(80);
	DEFINE dat_Num_Cred             CHAR(20);
	DEFINE dat_Num_Cte              CHAR(20);
	DEFINE dat_Nom_Pdcto            CHAR(40);
	DEFINE dat_Num_Tarjeta          CHAR(20);
	DEFINE dat_Nom_Cte              CHAR(150);
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE cargoref_tc_ofi
	DEFINE car_Cod_Ret              CHAR(6);
	DEFINE car_Sald_Disp            DECIMAL(14,2);
	DEFINE car_Impor_Cgdo           DECIMAL(14,2);
	DEFINE car_Imp_comi             DECIMAL(14,2);
	DEFINE car_Iva_comi             DECIMAL(14,2);
			 
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL PAGO
	DEFINE csg2_codigo_ret			CHAR(6);
	DEFINE csg2_mensaje_ret			CHAR(80);
	DEFINE csg2_num_credito			CHAR(20);
	DEFINE csg2_cod_tipcred			CHAR(2);
	DEFINE csg2_fec_origen			DATE;
	DEFINE csg2_fec_prox_pago		DATE;
	DEFINE csg2_pago_min			MONEY(18,2);
	DEFINE csg2_fec_ult_pago		DATE;
	DEFINE csg2_plazo				INTEGER;
	DEFINE csg2_pagos_realizados	INTEGER;
	DEFINE csg2_linea_otorgada		MONEY(18,2);
	DEFINE csg2_tasa_interes		DECIMAL(9,6);
	DEFINE csg2_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg2_monto_sbc			DECIMAL(14,2);
	DEFINE csg2_cap_vig				MONEY(18,2);
	DEFINE csg2_cap_trans			MONEY(18,2);
	DEFINE csg2_cap_vdo_exig		MONEY(18,2);
	DEFINE csg2_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg2_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg2_int_vig				MONEY(18,2);
	DEFINE csg2_int_vdo				MONEY(18,2);
	DEFINE csg2_int_moratorios		MONEY(18,2);
	DEFINE csg2_int_mes				MONEY(18,2);
	DEFINE csg2_sdo_act_total_int	MONEY(18,2);
	DEFINE csg2_iva_int_vig			MONEY(18,2);
	DEFINE csg2_iva_int_vdo			MONEY(18,2);
	DEFINE csg2_iva_int_moratorios	MONEY(18,2);
	DEFINE csg2_iva_int_mes			MONEY(18,2);
	DEFINE csg2_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg2_com_pend			MONEY(18,2);
	DEFINE csg2_iva_com				MONEY(18,2);
	DEFINE csg2_sdo_retenido		MONEY(18,2);
	DEFINE csg2_tot_liquidacion		MONEY(18,2);
	DEFINE csg2_int_devengado		MONEY(18,2);
	DEFINE csg2_iva_int_devengado	MONEY(18,2);
	DEFINE csg2_linea_disp			MONEY(18,2);
	DEFINE csg2_pagos_vdos			MONEY(18,2);
	DEFINE csg2_desc_status_cred	CHAR(60);
	DEFINE csg2_id_bloqueo_cred		INTEGER;
	DEFINE csg2_bloqueo_cta			CHAR(60);
	DEFINE csg2_id_causa_bloq_cred	CHAR(3);
	DEFINE csg2_causa_bloqueo_cta	CHAR(50);
	DEFINE csg2_id_sit_esp_cte		CHAR(1);
	DEFINE csg2_id_causa_esp_cte	INTEGER;
	DEFINE csg2_sit_esp_cte			CHAR(75);
	DEFINE csg2_id_sit_esp_cred		CHAR(1);
	DEFINE csg2_id_causa_esp_cred	INTEGER;
	DEFINE csg2_sit_esp_cred		CHAR(75);
	DEFINE dMes                     CHAR(2);
	DEFINE dDia                     CHAR(2);
	DEFINE dFecha_Hoy				DATE;
	---INICIALIZACIONES
	LET v_cod_ret                   = "000000";
	LET s_Sucursal					= "";
	LET dFecha_dia                  = DATE(1);
	LET dHora                       = "";
	LET cFolioCargo					= "";
	LET iBandera                    = 0;
	LET cBanderaReversion           = "N";

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET csg_codigo_ret				= "000000";
	LET csg_mensaje_ret				= "";
	LET csg_num_credito				= "";
	LET csg_cod_tipcred				= "";
	LET csg_fec_origen				= DATE(1);
	LET csg_fec_prox_pago			= DATE(1);
	LET csg_pago_min				= 0.0;
	LET csg_fec_ult_pago			= DATE(1);
	LET csg_plazo					= 0;
	LET csg_pagos_realizados		= 0;
	LET csg_linea_otorgada			= 0.0;
	LET csg_tasa_interes			= 0.0;
	LET csg_tasa_moratorios			= 0.0;
	LET csg_monto_sbc				= 0.0;
	LET csg_cap_vig					= 0.0;
	LET csg_cap_trans				= 0.0;
	LET csg_cap_vdo_exig			= 0.0;
	LET csg_cap_vdo_no_exig			= 0.0;
	LET csg_sdo_act_total_cap		= 0.0;
	LET csg_int_vig					= 0.0;
	LET csg_int_vdo					= 0.0;
	LET csg_int_moratorios			= 0.0;
	LET csg_int_mes					= 0.0;
	LET csg_sdo_act_total_int		= 0.0;
	LET csg_iva_int_vig				= 0.0;
	LET csg_iva_int_vdo				= 0.0;
	LET csg_iva_int_moratorios		= 0.0;
	LET csg_iva_int_mes				= 0.0;
	LET csg_sdo_act_total_iva		= 0.0;
	LET csg_com_pend				= 0.0;
	LET csg_iva_com					= 0.0;
	LET csg_sdo_retenido			= 0.0;
	LET csg_tot_liquidacion			= 0.0;
	LET csg_int_devengado			= 0.0;
	LET csg_iva_int_devengado		= 0.0;
	LET csg_linea_disp				= 0.0;
	LET csg_pagos_vdos				= 0.0;
	LET csg_desc_status_cred		= "";
	LET csg_id_bloqueo_cred			= 0;
	LET csg_bloqueo_cta				= "";
	LET csg_id_causa_bloq_cred		= "";
	LET csg_causa_bloqueo_cta		= "";
	LET csg_id_sit_esp_cte			= "";
	LET csg_id_causa_esp_cte		= 0;
	LET csg_sit_esp_cte				= "";
	LET csg_id_sit_esp_cred			= "";
	LET csg_id_causa_esp_cred		= 0;
	LET csg_sit_esp_cred			= "";	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_datos_general
	LET dat_codigo_ret           	= "";
	LET dat_Mensaje_ret          	= "";
	LET dat_Num_Cred             	= "";
	LET dat_Num_Cte              	= "";
	LET dat_Nom_Pdcto            	= "";
	LET dat_Num_Tarjeta          	= "";
	LET dat_Nom_Cte              	= "";	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE cargoref_tc_ofi
	LET car_Cod_Ret                 = "";
	LET car_Sald_Disp           	= 0.0;
	LET car_Impor_Cgdo           	= 0.0;
	LET car_Imp_comi             	= 0.0;
	LET car_Iva_comi             	= 0.0;	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL PAGO
	LET csg2_codigo_ret				= "";
	LET csg2_mensaje_ret			= "";
	LET csg2_num_credito			= "";
	LET csg2_cod_tipcred			= "";
	LET csg2_fec_origen				= DATE(1);
	LET csg2_fec_prox_pago			= DATE(1);
	LET csg2_pago_min				= 0.0;
	LET csg2_fec_ult_pago			= DATE(1);
	LET csg2_plazo					= 0;
	LET csg2_pagos_realizados		= 0;
	LET csg2_linea_otorgada			= 0.0;
	LET csg2_tasa_interes			= 0.0;
	LET csg2_tasa_moratorios		= 0.0;
	LET csg2_monto_sbc				= 0.0;
	LET csg2_cap_vig				= 0.0;
	LET csg2_cap_trans				= 0.0;
	LET csg2_cap_vdo_exig			= 0.0;
	LET csg2_cap_vdo_no_exig		= 0.0;
	LET csg2_sdo_act_total_cap		= 0.0;
	LET csg2_int_vig				= 0.0;
	LET csg2_int_vdo				= 0.0;
	LET csg2_int_moratorios			= 0.0;
	LET csg2_int_mes				= 0.0;
	LET csg2_sdo_act_total_int		= 0.0;
	LET csg2_iva_int_vig			= 0.0;
	LET csg2_iva_int_vdo			= 0.0;
	LET csg2_iva_int_moratorios		= 0.0;
	LET csg2_iva_int_mes			= 0.0;
	LET csg2_sdo_act_total_iva		= 0.0;
	LET csg2_com_pend				= 0.0;
	LET csg2_iva_com				= 0.0;
	LET csg2_sdo_retenido			= 0.0;
	LET csg2_tot_liquidacion		= 0.0;
	LET csg2_int_devengado			= 0.0;
	LET csg2_iva_int_devengado		= 0.0;
	LET csg2_linea_disp				= 0.0;
	LET csg2_pagos_vdos				= 0.0;
	LET csg2_desc_status_cred		= "";
	LET csg2_id_bloqueo_cred		= 0;
	LET csg2_bloqueo_cta			= "";
	LET csg2_id_causa_bloq_cred		= "";
	LET csg2_causa_bloqueo_cta		= "";
	LET csg2_id_sit_esp_cte			= "";
	LET csg2_id_causa_esp_cte		= 0;
	LET csg2_sit_esp_cte			= "";
	LET csg2_id_sit_esp_cred		= "";
	LET csg2_id_causa_esp_cred		= 0;
	LET csg2_sit_esp_cred			= "";	
	LET dMes                        = "";
	LET dDia                        = "";
	LET dFecha_Hoy					= DATE(1);
	
BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr		
		IF cBanderaReversion ='S' THEN
			CALL "informix".reversion ('001', s_Sucursal, 'carmas',cFolioCargo,"A") Returning v_cod_ret;	
		END IF;
        IF iSqlErr <> 0 THEN
			LET v_cod_ret = iSqlErr;
        END IF;		
        RETURN v_cod_ret,'';
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_grabarcargosmasivos.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
	INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
			csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
			csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
			csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
			csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
			csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
			csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
			csg_id_causa_esp_cred,csg_sit_esp_cred;

	IF csg_codigo_ret::INTEGER <> 0 THEN
		LET v_cod_ret = "000001";
		RETURN v_cod_ret,'';
	END IF
	
    SELECT trim(valor) 
    INTO s_Sucursal
    FROM "informix".sd_param
    WHERE empresa = '001'
    AND cod_param = '28';

    IF s_Sucursal = '' OR s_Sucursal IS NULL THEN
		LET v_cod_ret = "000002";
		RETURN v_cod_ret,'';
    END IF;
	
	SELECT fecha_hoy
	INTO dFecha_Hoy
	FROM "informix".sd_fechas;
	
	---PARA OBTENER LA FECHA Y LA HORA ESACTA PARA PONERLA EN LA INSERCCION EN UN SP..VISUALAIZER
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  
	INTO dFecha_dia
	FROM sysmaster:"informix".sysshmvals;

	WHILE iBandera  = 0 
		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
		INTO dHora
		FROM sysmaster:"informix".sysshmvals;	
		
		LET dDia =  DAY(dFecha_dia);
		LET dMes =  MONTH(dFecha_dia);
	
		LET cFolioCargo = "carmas"||LPAD(TRIM(dDia),2,'0')
								  ||LPAD(TRIM(dMes),2,'0')|| SUBSTR(dHora, 1, 2)|| SUBSTR(dHora, 4, 2)||SUBSTR(dHora, 7, 2);
		
		IF EXISTS (	SELECT folio  FROM "informix".sd_bitacora_cargos	WHERE folio =  cFolioCargo AND folio_grupo = p_FolioGpo) THEN
				LET iBandera = 0;
		ELSE
				LET iBandera = 1;
		END IF;
	END WHILE
	
	
	---OBTENER EL NUMERO DE  TARJETA DEL CREDITO  EN CUESTION
	EXECUTE PROCEDURE "informix".sp_consulta_datos_general(p_Empresa, '', p_NumCredito,'','','','')
	INTO dat_codigo_ret, dat_Mensaje_ret, dat_Num_Cred, dat_Num_Cte, dat_Nom_Pdcto, dat_Num_Tarjeta, dat_Nom_Cte;
	
	--- REALIZA EL CARGO AL CREDITO EN CUESTION
	EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi(p_Empresa, s_Sucursal, 'carmas', dat_Num_Tarjeta, p_ImporteCargo, cFolioCargo, p_Transaccion )
	INTO car_Cod_Ret, car_Sald_Disp, car_Impor_Cgdo, car_Imp_comi, car_Iva_comi;

	IF car_Cod_Ret::INTEGER = 8 THEN
		LET v_cod_ret = "000007";
		RETURN v_cod_ret,'';   --credito nulo
	ELIF car_Cod_Ret::INTEGER <> 0 THEN
		LET v_cod_ret = "000008";
		RETURN v_cod_ret,'';
	END IF
	LET cBanderaReversion = "S";
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO DESPUES DEL CARGO
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
	INTO csg2_codigo_ret,csg2_mensaje_ret,csg2_num_credito,csg2_cod_tipcred,csg2_fec_origen,csg2_fec_prox_pago,csg2_pago_min,
			csg2_fec_ult_pago,csg2_plazo,csg2_pagos_realizados,csg2_linea_otorgada,csg2_tasa_interes,csg2_tasa_moratorios,
			csg2_monto_sbc,csg2_cap_vig,csg2_cap_trans,csg2_cap_vdo_exig,csg2_cap_vdo_no_exig,csg2_sdo_act_total_cap,csg2_int_vig,
			csg2_int_vdo,csg2_int_moratorios,csg2_int_mes,csg2_sdo_act_total_int,csg2_iva_int_vig,csg2_iva_int_vdo,csg2_iva_int_moratorios,
			csg2_iva_int_mes,csg2_sdo_act_total_iva,csg2_com_pend,csg2_iva_com,csg2_sdo_retenido,csg2_tot_liquidacion,csg2_int_devengado,
			csg2_iva_int_devengado,csg2_linea_disp,csg2_pagos_vdos,csg2_desc_status_cred,csg2_id_bloqueo_cred,csg2_bloqueo_cta,
			csg2_id_causa_bloq_cred,csg2_causa_bloqueo_cta,csg2_id_sit_esp_cte,csg2_id_causa_esp_cte,csg2_sit_esp_cte,csg2_id_sit_esp_cred,
			csg2_id_causa_esp_cred,csg2_sit_esp_cred;

	IF csg2_codigo_ret::INTEGER <> 0 THEN
		LET v_cod_ret = "000003";
		RETURN v_cod_ret,'';
	END IF
	
	
	--- SE ACTUALIZA EL REGISTRO DEL CATALOGO DE PAGOS CON LA INFORMACION DEL PAGO REALIZADO
	INSERT INTO "informix".sd_bitacora_cargos 
				(numcte,num_credito, fecha_cargo,hora_cargo, fecha_reverso, hora_reverso, importe_cargo, cap_vig_ant, cap_tran_ant, cap_venc_ant, cap_venc_noexi_ant,
				cap_total_ant, int_vig_ant, iva_int_vig_ant, int_ven_ant, iva_int_ven_ant, int_mora_ant, iva_int_mora_ant, cap_vig_pos,
				cap_tran_pos, cap_venc_pos,	cap_venc_noexi_pos, cap_total_pos, cod_cargo, desc_cargo, resultado, folio, folio_grupo, reverso, observaciones,observaciones_rev,usuario)
	VALUES (dat_Num_Cte,p_NumCredito,dFecha_Hoy,dHora,'','',p_ImporteCargo, csg_cap_vig, csg_cap_trans, csg_cap_vdo_exig, csg_cap_vdo_no_exig,
			csg_sdo_act_total_cap, csg_int_vig, csg_iva_int_vig, csg_int_vdo, csg_iva_int_vdo, csg_int_moratorios, csg_iva_int_moratorios, csg2_cap_vig,
			csg2_cap_trans, csg2_cap_vdo_exig, csg2_cap_vdo_no_exig, csg2_sdo_act_total_cap, p_codigo, p_DesCodigo,"OK", cFolioCargo,p_FolioGpo,"N","","",p_Usuario);
	
	
	RETURN v_cod_ret, cFolioCargo;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR :Héctor Manuel Bojórquez Ruelas,Jesus Manuel Aguilar Heredia',
'DESCRIPCION: Procedimiento que Realiza el Cargo Masivo.',
'Crédito',
'FECHA : JULIO de 2011',
'VERSION: 20110713.1023',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_grabarreversocargoman (pFolio CHAR(16), pEjecutivo CHAR(8),  pObservacionRev CHAR(200))

RETURNING  CHAR(5);

DEFINE cCodRet 			 		CHAR(5);
DEFINE iSqlErr			 		INTEGER;
DEFINE cSucursal				CHAR(4);
DEFINE cCredito					CHAR(20);
DEFINE vFecha                   DATE;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_grabarreversocargoman.out";
	--TRACE ON;

	LET cCodRet   = '00000';
	LET iSqlErr	  = 0;		
	LET cSucursal = '';
	LET cCredito = '';
    LET vFecha   = date(1);

    
	SELECT fecha_hoy
	INTO vfecha
	FROM "informix".sd_fechas;


	SELECT LIMIT 1 num_credito
	INTO cCredito
	FROM "informix".sd_bitacora_cargos
	WHERE fecha_cargo = vfecha
      AND folio = pFolio;


    SELECT trim(valor) 
    INTO cSucursal
    FROM "informix".sd_param
    WHERE empresa = '001'
    AND cod_param = '28';

   
        IF cCredito <> '' AND cCredito IS NOT NULL AND cSucursal <> '' AND cSucursal IS NOT NULL THEN

            CALL "informix".reversion ('001', cSucursal, pEjecutivo,pFolio, "A") Returning cCodRet;	

                IF cCodRet <> 0 THEN --La reversion no se realizo exitosamente
                    LET cCodRet= '10000';
                    RETURN cCodRet;
                END IF;	

            UPDATE "informix".sd_bitacora_cargos 
			SET reverso='S', 
			observaciones_rev = pObservacionRev ,
			fecha_reverso = vfecha,
			hora_reverso = CURRENT
			WHERE folio = pFolio; --Actualiza a reversado el estatus del Cargo manual.

        ELSE 
            LET cCodRet= '10000';
        END IF;       
	RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: MANDA LLAMAR LA REVERSION Y ACTUALIZA A REVERSADO EL ESTATUS EN LOS CARGOS MANUALES', 
'AUTOR: Héctor Manuel Bojórquez Ruelas,Jesus Manuel Aguilar Heredia',
'FECHA: JULIO 2011',
'VERSION: 20110714.1702',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_grabarreversocargosmasivos (pFolio CHAR(16))

RETURNING  CHAR(6), CHAR(100);

--definicion de variables
DEFINE cCodRet 			 		CHAR(6);
DEFINE cMensaje                 CHAR(100) ;
DEFINE iSqlErr			 		INTEGER;
DEFINE cCredito					CHAR(20);
DEFINE dFecha_Hoy                   DATE;
DEFINE dHora                    CHAR(8);
DEFINE cEmpresa                 CHAR(3);
DEFINE cReverso                 CHAR(1);  

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
DEFINE csg_codigo_ret			CHAR(6);
DEFINE csg_mensaje_ret			CHAR(80);
DEFINE csg_num_credito			CHAR(20);
DEFINE csg_cod_tipcred			CHAR(2);
DEFINE csg_fec_origen			DATE;
DEFINE csg_fec_prox_pago		DATE;
DEFINE csg_pago_min				MONEY(18,2);
DEFINE csg_fec_ult_pago			DATE;
DEFINE csg_plazo				INTEGER;
DEFINE csg_pagos_realizados		INTEGER;
DEFINE csg_linea_otorgada		MONEY(18,2);
DEFINE csg_tasa_interes			DECIMAL(9,6);
DEFINE csg_tasa_moratorios		DECIMAL(9,6);
DEFINE csg_monto_sbc			DECIMAL(14,2);
DEFINE csg_cap_vig				MONEY(18,2);
DEFINE csg_cap_trans			MONEY(18,2);
DEFINE csg_cap_vdo_exig			MONEY(18,2);
DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
DEFINE csg_sdo_act_total_cap	MONEY(18,2);
DEFINE csg_int_vig				MONEY(18,2);
DEFINE csg_int_vdo				MONEY(18,2);
DEFINE csg_int_moratorios		MONEY(18,2);
DEFINE csg_int_mes				MONEY(18,2);
DEFINE csg_sdo_act_total_int	MONEY(18,2);
DEFINE csg_iva_int_vig			MONEY(18,2);
DEFINE csg_iva_int_vdo			MONEY(18,2);
DEFINE csg_iva_int_moratorios	MONEY(18,2);
DEFINE csg_iva_int_mes			MONEY(18,2);
DEFINE csg_sdo_act_total_iva	MONEY(18,2);
DEFINE csg_com_pend				MONEY(18,2);
DEFINE csg_iva_com				MONEY(18,2);
DEFINE csg_sdo_retenido			MONEY(18,2);
DEFINE csg_tot_liquidacion		MONEY(18,2);
DEFINE csg_int_devengado		MONEY(18,2);
DEFINE csg_iva_int_devengado	MONEY(18,2);
DEFINE csg_linea_disp			MONEY(18,2);
DEFINE csg_pagos_vdos			MONEY(18,2);
DEFINE csg_desc_status_cred		CHAR(60);
DEFINE csg_id_bloqueo_cred		INTEGER;
DEFINE csg_bloqueo_cta			CHAR(60);
DEFINE csg_id_causa_bloq_cred	CHAR(3);
DEFINE csg_causa_bloqueo_cta	CHAR(50);
DEFINE csg_id_sit_esp_cte		CHAR(1);
DEFINE csg_id_causa_esp_cte		INTEGER;
DEFINE csg_sit_esp_cte			CHAR(75);
DEFINE csg_id_sit_esp_cred		CHAR(1);
DEFINE csg_id_causa_esp_cred	INTEGER;
DEFINE csg_sit_esp_cred			CHAR(75);
	 
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL CARGO
DEFINE csg2_codigo_ret			CHAR(6);
DEFINE csg2_mensaje_ret			CHAR(80);
DEFINE csg2_num_credito			CHAR(20);
DEFINE csg2_cod_tipcred			CHAR(2);
DEFINE csg2_fec_origen			DATE;
DEFINE csg2_fec_prox_pago		DATE;
DEFINE csg2_pago_min			MONEY(18,2);
DEFINE csg2_fec_ult_pago		DATE;
DEFINE csg2_plazo				INTEGER;
DEFINE csg2_pagos_realizados	INTEGER;
DEFINE csg2_linea_otorgada		MONEY(18,2);
DEFINE csg2_tasa_interes		DECIMAL(9,6);
DEFINE csg2_tasa_moratorios		DECIMAL(9,6);
DEFINE csg2_monto_sbc			DECIMAL(14,2);
DEFINE csg2_cap_vig				MONEY(18,2);
DEFINE csg2_cap_trans			MONEY(18,2);
DEFINE csg2_cap_vdo_exig		MONEY(18,2);
DEFINE csg2_cap_vdo_no_exig		MONEY(18,2);
DEFINE csg2_sdo_act_total_cap	MONEY(18,2);
DEFINE csg2_int_vig				MONEY(18,2);
DEFINE csg2_int_vdo				MONEY(18,2);
DEFINE csg2_int_moratorios		MONEY(18,2);
DEFINE csg2_int_mes				MONEY(18,2);
DEFINE csg2_sdo_act_total_int	MONEY(18,2);
DEFINE csg2_iva_int_vig			MONEY(18,2);
DEFINE csg2_iva_int_vdo			MONEY(18,2);
DEFINE csg2_iva_int_moratorios	MONEY(18,2);
DEFINE csg2_iva_int_mes			MONEY(18,2);
DEFINE csg2_sdo_act_total_iva	MONEY(18,2);
DEFINE csg2_com_pend			MONEY(18,2);
DEFINE csg2_iva_com				MONEY(18,2);
DEFINE csg2_sdo_retenido		MONEY(18,2);
DEFINE csg2_tot_liquidacion		MONEY(18,2);
DEFINE csg2_int_devengado		MONEY(18,2);
DEFINE csg2_iva_int_devengado	MONEY(18,2);
DEFINE csg2_linea_disp			MONEY(18,2);
DEFINE csg2_pagos_vdos			MONEY(18,2);
DEFINE csg2_desc_status_cred	CHAR(60);
DEFINE csg2_id_bloqueo_cred		INTEGER;
DEFINE csg2_bloqueo_cta			CHAR(60);
DEFINE csg2_id_causa_bloq_cred	CHAR(3);
DEFINE csg2_causa_bloqueo_cta	CHAR(50);
DEFINE csg2_id_sit_esp_cte		CHAR(1);
DEFINE csg2_id_causa_esp_cte	INTEGER;
DEFINE csg2_sit_esp_cte			CHAR(75);
DEFINE csg2_id_sit_esp_cred		CHAR(1);
DEFINE csg2_id_causa_esp_cred	INTEGER;
DEFINE csg2_sit_esp_cred		CHAR(75);

	
--Inicializacion de variables
LET cCodRet   = '000000';
LET cMensaje =  'Proceso Exitoso!!!';
LET iSqlErr	  = 0;		
LET cCredito = '';
LET dFecha_Hoy   = date(1);
LET dHora    = '';
LET cEmpresa = "001";
LET cReverso =  "";

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
LET csg_codigo_ret				= "000000";
LET csg_mensaje_ret				= "";
LET csg_num_credito				= "";
LET csg_cod_tipcred				= "";
LET csg_fec_origen				= MDY(1,1,1900);
LET csg_fec_prox_pago			= MDY(1,1,1900);
LET csg_pago_min				= 0.0;
LET csg_fec_ult_pago			= MDY(1,1,1900);
LET csg_plazo					= 0;
LET csg_pagos_realizados		= 0;
LET csg_linea_otorgada			= 0.0;
LET csg_tasa_interes			= 0.0;
LET csg_tasa_moratorios			= 0.0;
LET csg_monto_sbc				= 0.0;
LET csg_cap_vig					= 0.0;
LET csg_cap_trans				= 0.0;
LET csg_cap_vdo_exig			= 0.0;
LET csg_cap_vdo_no_exig			= 0.0;
LET csg_sdo_act_total_cap		= 0.0;
LET csg_int_vig					= 0.0;
LET csg_int_vdo					= 0.0;
LET csg_int_moratorios			= 0.0;
LET csg_int_mes					= 0.0;
LET csg_sdo_act_total_int		= 0.0;
LET csg_iva_int_vig				= 0.0;
LET csg_iva_int_vdo				= 0.0;
LET csg_iva_int_moratorios		= 0.0;
LET csg_iva_int_mes				= 0.0;
LET csg_sdo_act_total_iva		= 0.0;
LET csg_com_pend				= 0.0;
LET csg_iva_com					= 0.0;
LET csg_sdo_retenido			= 0.0;
LET csg_tot_liquidacion			= 0.0;
LET csg_int_devengado			= 0.0;
LET csg_iva_int_devengado		= 0.0;
LET csg_linea_disp				= 0.0;
LET csg_pagos_vdos				= 0.0;
LET csg_desc_status_cred		= "";
LET csg_id_bloqueo_cred			= 0;
LET csg_bloqueo_cta				= "";
LET csg_id_causa_bloq_cred		= "";
LET csg_causa_bloqueo_cta		= "";
LET csg_id_sit_esp_cte			= "";
LET csg_id_causa_esp_cte		= 0;
LET csg_sit_esp_cte				= "";
LET csg_id_sit_esp_cred			= "";
LET csg_id_causa_esp_cred		= 0;
LET csg_sit_esp_cred			= "";


---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL CARGO
LET csg2_codigo_ret				= "";
LET csg2_mensaje_ret			= "";
LET csg2_num_credito			= "";
LET csg2_cod_tipcred			= "";
LET csg2_fec_origen				= MDY(1,1,1900);
LET csg2_fec_prox_pago			= MDY(1,1,1900);
LET csg2_pago_min				= 0.0;
LET csg2_fec_ult_pago			= MDY(1,1,1900);
LET csg2_plazo					= 0;
LET csg2_pagos_realizados		= 0;
LET csg2_linea_otorgada			= 0.0;
LET csg2_tasa_interes			= 0.0;
LET csg2_tasa_moratorios		= 0.0;
LET csg2_monto_sbc				= 0.0;
LET csg2_cap_vig				= 0.0;
LET csg2_cap_trans				= 0.0;
LET csg2_cap_vdo_exig			= 0.0;
LET csg2_cap_vdo_no_exig		= 0.0;
LET csg2_sdo_act_total_cap		= 0.0;
LET csg2_int_vig				= 0.0;
LET csg2_int_vdo				= 0.0;
LET csg2_int_moratorios			= 0.0;
LET csg2_int_mes				= 0.0;
LET csg2_sdo_act_total_int		= 0.0;
LET csg2_iva_int_vig			= 0.0;
LET csg2_iva_int_vdo			= 0.0;
LET csg2_iva_int_moratorios		= 0.0;
LET csg2_iva_int_mes			= 0.0;
LET csg2_sdo_act_total_iva		= 0.0;
LET csg2_com_pend				= 0.0;
LET csg2_iva_com				= 0.0;
LET csg2_sdo_retenido			= 0.0;
LET csg2_tot_liquidacion		= 0.0;
LET csg2_int_devengado			= 0.0;
LET csg2_iva_int_devengado		= 0.0;
LET csg2_linea_disp				= 0.0;
LET csg2_pagos_vdos				= 0.0;
LET csg2_desc_status_cred		= "";
LET csg2_id_bloqueo_cred		= 0;
LET csg2_bloqueo_cta			= "";
LET csg2_id_causa_bloq_cred		= "";
LET csg2_causa_bloqueo_cta		= "";
LET csg2_id_sit_esp_cte			= "";
LET csg2_id_causa_esp_cte		= 0;
LET csg2_sit_esp_cte			= "";
LET csg2_id_sit_esp_cred		= "";
LET csg2_id_causa_esp_cred		= 0;
LET csg2_sit_esp_cred			= "";

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet, '';
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_grabarreversocargosmasivos.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		---PARA OBTENER LA FECHA Y LA HORA ESACTA PARA PONERLA EN LA INSERCCION EN UN SP..VISUALAIZER
	SELECT fecha_hoy
	INTO dFecha_Hoy
	FROM "informix".sd_fechas;
	
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
	INTO dHora
	FROM sysmaster:"informix".sysshmvals;	

	SELECT LIMIT 1 num_credito, reverso
	INTO cCredito, cReverso
	FROM "informix".sd_bitacora_cargos
	WHERE fecha_cargo = dFecha_Hoy
      AND folio = pFolio;
	  
	  
	IF cReverso =  "S" THEN
		LET cCodRet= '100000';
        RETURN cCodRet, 'El folio ya fue reversado anteriormente';
	END IF;

		--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa,cCredito) 
		INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
				csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
				csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
				csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
				csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
				csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
				csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
				csg_id_causa_esp_cred,csg_sit_esp_cred;

		IF csg_codigo_ret::INTEGER <> 0 THEN
			LET cCodRet = "000001";  --Error en la obtencion del saldo antes del reverso
			RETURN cCodRet,'Error en la obtencion del saldo antes del reverso';
		END IF


   
        IF cCredito <> '' AND cCredito IS NOT NULL THEN

            CALL "informix".reversion ('001', "9250", "carmas", pFolio, "A") Returning cCodRet;	

                IF cCodRet = -284 THEN --El Cargo del folio ya fue reversado anteriormente
                    LET cCodRet= '100000';
                    RETURN cCodRet, 'El Cargo del folio ya fue reversado anteriormente';
				elif cCodRet = "431" THEN -- CARGO NO ES EL ULTIMO REVERSA EN ORDEN	 
					LET cCodRet= '200000';
					RETURN cCodRet, 'El crédito del folio no es el mas actual';
				elif cCodRet   = '000'  THEN
					LET cCodRet   = '000000';
					
					--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO DESPUES DEL CARGO
					EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa,cCredito) 
					INTO csg2_codigo_ret,csg2_mensaje_ret,csg2_num_credito,csg2_cod_tipcred,csg2_fec_origen,csg2_fec_prox_pago,csg2_pago_min,
							csg2_fec_ult_pago,csg2_plazo,csg2_pagos_realizados,csg2_linea_otorgada,csg2_tasa_interes,csg2_tasa_moratorios,
							csg2_monto_sbc,csg2_cap_vig,csg2_cap_trans,csg2_cap_vdo_exig,csg2_cap_vdo_no_exig,csg2_sdo_act_total_cap,csg2_int_vig,
							csg2_int_vdo,csg2_int_moratorios,csg2_int_mes,csg2_sdo_act_total_int,csg2_iva_int_vig,csg2_iva_int_vdo,
							csg2_iva_int_moratorios,csg2_iva_int_mes,csg2_sdo_act_total_iva,csg2_com_pend,csg2_iva_com,csg2_sdo_retenido,
							csg2_tot_liquidacion,csg2_int_devengado,csg2_iva_int_devengado,csg2_linea_disp,csg2_pagos_vdos,csg2_desc_status_cred,
							csg2_id_bloqueo_cred,csg2_bloqueo_cta,csg2_id_causa_bloq_cred,csg2_causa_bloqueo_cta,csg2_id_sit_esp_cte,
							csg2_id_causa_esp_cte,csg2_sit_esp_cte,csg2_id_sit_esp_cred,csg2_id_causa_esp_cred,csg2_sit_esp_cred;

					IF csg2_codigo_ret::INTEGER <> 0 THEN
						LET cCodRet = "000004";   --Error en la obtencion del saldo despues del reverso
						RETURN cCodRet,'Error en la obtencion del saldo despues del reverso';
					END IF

										
				else
					LET cCodRet= '400000';
					RETURN cCodRet, 'Error en el reverso del Cargo';
				
                END IF;	

            UPDATE "informix".sd_bitacora_cargos    
			SET fecha_reverso = dFecha_Hoy,
				hora_reverso = dHora,
				reverso = "S"				
			WHERE folio = pFolio; --Actualiza a reversado el estatus del Cargo Masivo.

        ELSE 
            LET cCodRet= '300000';
			LET cMensaje = 'Numero de crédito no se encuentra en la bitacora de Cargos ';
        END IF;       



	RETURN cCodRet,cMensaje;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: EJECUTA LA REVERSION DE LOS CARGOS SOLICITADOS', 
'AUTOR: Hector Manuel Bojorquez Ruelas,Jesus Manuel Aguilar Heredia',
'FECHA: JULIO 2011',
'VERSION: 20110713.11202',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_obtenerconceptocargomanuales(p_Codconcepto CHAR(2),p_transaccion CHAR(4))
RETURNING CHAR(6),     --cod_ret
		  CHAR(2),     --Codigo pago
          VARCHAR(50), --descripcion
          CHAR(4);     --transaccion


---DECLARACIONES
DEFINE v_cod_ret      CHAR(6);
DEFINE iSqlErr        INTEGER;
DEFINE iSamErr        INTEGER;
DEFINE vIndicaTpoCons INTEGER;
DEFINE cCodigo        CHAR(2);
DEFINE cConcepto	  VARCHAR(50);
DEFINE ctransaccion   CHAR(4);

---INICIALIZACIONES
LET v_cod_ret            = '000000';
LET iSqlErr              = 0;
LET iSamErr              = 0;
LET vIndicaTpoCons       = 0;
LET cCodigo              = "";
LET cConcepto            = "";
LET ctransaccion         = "";
 
BEGIN

ON EXCEPTION
    SET iSqlErr, iSamErr
    IF iSqlErr <> 0 THEN
        LET v_cod_ret = iSqlErr;
    END IF;
    RETURN v_cod_ret,'','','';
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_obtenerconceptocargomanuales.out";
--TRACE ON;
	
		IF p_Codconcepto = "" THEN
			FOREACH
				SELECT codigo, concepto, transacc
				INTO cCodigo, cConcepto, ctransaccion
				FROM "informix".sd_conceptoscargoscredito
				WHERE mostrar_pantalla ='1'
				AND transacc = (case when nvl(p_transaccion,"") = "" then transacc else p_transaccion end)
				ORDER BY codigo
			
				RETURN v_cod_ret,cCodigo,cConcepto,ctransaccion WITH RESUME;

			END FOREACH;			
		ELSE
			FOREACH
				SELECT codigo, concepto, transacc
				INTO cCodigo, cConcepto, ctransaccion
				FROM "informix".sd_conceptoscargoscredito
				WHERE codigo = p_Codconcepto 
				AND transacc = (case when nvl(p_transaccion,"") = "" then transacc else p_transaccion end)
				
				RETURN v_cod_ret,cCodigo,cConcepto,ctransaccion WITH RESUME;

			END FOREACH;
			  
		END IF;	  

	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		--NO SE ENCUANTRAN REGISTROS PARA EL CRITERIO DE BUSQUEDA SOLICITADO	
		LET v_cod_ret = "000001";
		RETURN v_cod_ret,cCodigo,cConcepto,ctransaccion;
	END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR :Héctor Manuel Bojórquez Ruelas,Jesus Manuel Aguilar Heredia ',
'DESCRIPCION: Procedimiento que obtiene el catálogo de los Conceptos de Cargos,transacciones y codigo de funcion.',
'Crédito',
'FECHA : Julio de 2011',
'VERSION: 20110708.1752',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtenereversocargosman(pFolio CHAR(16))
RETURNING CHAR(5), CHAR(80), CHAR(20),CHAR(20), CHAR(40) , CHAR(20),CHAR(150) , DECIMAL(18,2),DECIMAL (18,2), DECIMAL(18,2),DECIMAL(18,2),
DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2), CHAR(20), CHAR(50);

--DECLARACION DE VARIABLES
DEFINE vCodRet    CHAR(5);
DEFINE vSqlErr, vIsamErr INTEGER;
DEFINE cNumCred   CHAR(20);
DEFINE cFolio     CHAR(16);
DEFINE cCodigo_retorno CHAR(6);
DEFINE cMensaje_retorno CHAR (80);
DEFINE cNumero_credito	CHAR(20);
DEFINE cNumero_cliente	CHAR(20);
DEFINE cNombre_producto	CHAR(40);
DEFINE cNumero_tarjeta	CHAR(20);
DEFINE cNombre_cliente	CHAR (150);	
DEFINE cImporte_Cargo		DECIMAL(18,2);
DEFINE cCapital_vigente	DECIMAL(18,2);
DEFINE cCapital_transitorio DECIMAL(18,2);
DEFINE cCapital_vencido DECIMAL(18,2);
DEFINE cCapital_vencido_no_exigible DECIMAL(18,2);
DEFINE cInteres_vigente DECIMAL(18,2);
DEFINE cIva_de_interes_vigente DECIMAL(18,2);
DEFINE cInteres_vencido DECIMAL(18,2);
DEFINE cIva_de_interes_vencido DECIMAL(18,2);
DEFINE cInteres_moratorio DECIMAL(18,2);
DEFINE cIva_interesmoratorio	 DECIMAL(18,2);
DEFINE cCapital_Total	DECIMAL(18,2);
DEFINE cConcepto		CHAR(20);
DEFINE cDescripcion     CHAR(200);
--INICIALIZACION DE VARIABLES

LET vCodRet = "00000";
LET cNumCred = '';
LET cFolio   = '';
LET cCodigo_retorno = 0;
LET cMensaje_retorno  = 0;
LET cNumero_credito	 = 0;
LET cNumero_cliente	 = 0;
LET cNombre_producto	 = 0;
LET cNumero_tarjeta	 = 0;
LET cNombre_cliente	 = 0;
LET cImporte_Cargo		 = 0;
LET cCapital_vigente	 = 0;
LET cCapital_transitorio  = 0;
LET cCapital_vencido  = 0;
LET cCapital_vencido_no_exigible  = 0;
LET cInteres_vigente  = 0;
LET cIva_de_interes_vigente  = 0;
LET cInteres_vencido  = 0;
LET cIva_de_interes_vencido = 0;
LET cInteres_moratorio  = 0;
LET cIva_interesmoratorio	  = 0;
LET cCapital_Total	 = 0;
LET cConcepto		='';
LET cDescripcion   = '';

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtenereversocargosman.out";
	--TRACE ON;

BEGIN
	--MANEJO DE ERRORES
	ON EXCEPTION SET vSqlErr, vIsamErr
		IF vSqlErr != 0 THEN
			LET vCodRet = vSqlErr;
			RETURN vCodRet,'', '', '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','' ;
		END IF;
	END EXCEPTION;

	IF NOT EXISTS( SELECT num_credito FROM "informix".sd_bitacora_cargos WHERE folio = pFolio) THEN              --El folio recibido no se trata de un cargo manual
		LET vCodRet= '20000';
		RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','' ;
	END IF;

	IF EXISTS ( SELECT num_credito FROM "informix".sd_bitacora_cargos WHERE folio = pFolio AND reverso = 'S') THEN
		LET vCodRet= '30000';
		RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','' ;			
	END IF;

	--VALIDACION PARA REVERSAR PAGO MANUAL

	SELECT Limit 1 trim(num_credito)
	INTO cNumCred
	FROM "informix".sd_movdia
	WHERE folio_suc = pFolio;	

	SELECT folio_suc 
		INTO cFolio
	FROM  "informix".sd_movdia
	WHERE num_credito = cNumCred
	AND reversado <> 'S'
	AND secuencia = (SELECT MAX(secuencia)  
					 FROM  "informix".sd_movdia
					 WHERE num_credito = cNumCred 
					 AND reversado <> 'S');
	

	IF  cFolio <> pFolio THEN            --El folio recibido no es el ultimo movimiento
		LET vCodRet= '10000';
		RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','','', '', '','', '', '','', '','','' ;
	END IF;		

	CALL "informix".sp_consulta_datos_general('001', '', cNumCred,'','','','')
	RETURNING cCodigo_retorno, cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente;

	FOREACH

		SELECT importe_cargo, cap_vig_ant, cap_tran_ant, cap_venc_ant, cap_venc_noexi_ant,cap_total_ant, int_vig_ant, iva_int_vig_ant, 
				int_ven_ant, iva_int_ven_ant, int_mora_ant,  iva_int_mora_ant, cod_cargo, observaciones
		INTO cImporte_Cargo, cCapital_vigente, cCapital_transitorio, cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total, cInteres_vigente, 
			cIva_de_interes_vigente, cInteres_vencido, cIva_de_interes_vencido, cInteres_moratorio, cIva_interesmoratorio, cConcepto, cDescripcion
		FROM "informix".sd_bitacora_cargos
		WHERE folio= pFolio	
		AND reverso =  'N'

		RETURN vCodRet,cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente, cImporte_Cargo, cCapital_vigente,
				cCapital_transitorio, cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total ,cInteres_vigente, cIva_de_interes_vigente, 
				cInteres_vencido, cIva_de_interes_vencido, cInteres_moratorio, cIva_interesmoratorio, cConcepto, cDescripcion WITH RESUME;

	END FOREACH
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE DATOS GENERALES, DETALLE DE APLICACION Y SALDOS NUEVOS',
'AUTOR: HECTOR MANUEL BOJORQUEZ RUELAS,Jesus Manuel Aguilar Heredia',
'FECHA: JULIO 2011',
'VERSION: 20110714.1408',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_obtenerinforeversioncargo(pFolio_grupo  CHAR(16))
RETURNING  CHAR(6), CHAR(50), CHAR(20), MONEY(14,2), CHAR(2), char(100), CHAR(100), CHAR(16), CHAR(1);


DEFINE cCodRet 		     CHAR(6);
DEFINE iSqlErr           INTEGER;
DEFINE cMensaje          CHAR(50);
DEFINE iReg              INTEGER; 

DEFINE cCredito		     CHAR(20);
DEFINE iImporte          MONEY(14,2);
DEFINE cCodigo_cargo      CHAR(2);
DEFINE cDesc_cargo        CHAR(100);
DEFINE cResultado        CHAR(16);
DEFINE cFolio            CHAR(16);
DEFINE cReverso          CHAR(1);

LET cCodRet           = '000000';
LET iSqlErr	          = 0;
LET cMensaje          = 'Proceso Exitoso!!!';
LET iReg              = 0;

LET cCredito		  = '';
LET iImporte          = 0;
LET cCodigo_cargo      = '';
LET cDesc_cargo        = '';
LET cResultado        = '';
LET cFolio            = '';
LET cReverso          = '';

BEGIN
ON EXCEPTION SET iSqlErr
    IF iSqlErr != 0 THEN
        LET cCodRet= iSqlErr;
        RETURN cCodRet,cMensaje,cCredito,iImporte,cCodigo_cargo,cDesc_cargo,cResultado,cFolio,cReverso;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_obtenerinforeversioncargo.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


	FOREACH WITH HOLD
		
		SELECT num_credito, importe_cargo, cod_cargo, desc_cargo, resultado, folio, reverso
		INTO  cCredito, iImporte, cCodigo_cargo, cDesc_cargo, cResultado, cFolio, cReverso
		FROM "informix".sd_bitacora_cargos
		WHERE folio_grupo = pFolio_grupo
	
		
		RETURN cCodRet,cMensaje,cCredito,iImporte,cCodigo_cargo,cDesc_cargo,cResultado,cFolio,cReverso WITH RESUME;

	END FOREACH
			
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "000002";
		LET cMensaje = "No se encontraron registros del folio solicitado";
		RETURN cCodRet,cMensaje,cCredito,iImporte,cCodigo_cargo,cDesc_cargo,cResultado,cFolio,cReverso;
	END IF;
		
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE INFORMACION DE TODOS LOS REVERSOS DE CARGOS DEL FOLIO GRUPAL SOLICITADO', 
'AUTOR: HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: JULIO 2011',
'VERSION: 20110712.1822',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_select_muestras
(
pEmpresa 	CHAR(3)
)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(20) AS NUM_CRED,
	CHAR(20) AS NUM_TARJ,
	CHAR(60) AS STA_MES_ANT,
	CHAR(60) AS STA_MES_ACT,
	SMALLINT AS FLAG_AUTO,
	CHAR(2) AS TIPO_LOGICA;

	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE cCodRet         		CHAR(6);
	DEFINE cNumCredito			CHAR(20);
	DEFINE cNumTarjeta			CHAR(20);
	DEFINE cStatusMesAnt		CHAR(60);
	DEFINE cStatusMesAct		CHAR(60);
	DEFINE sFlagAutomatico		SMALLINT;
	DEFINE dtFechaUltCorte		DATE;
	DEFINE dtFechaHoy			DATE;
	DEFINE sMesUFC 				SMALLINT;
	DEFINE sDiaUFC 				SMALLINT;
	DEFINE sAnioUFC 			SMALLINT;
	DEFINE sMesHoy 				SMALLINT;
	DEFINE sDiaHoy 				SMALLINT;
	DEFINE sAnioHoy 			SMALLINT;
    DEFINE iNRows           	INTEGER;
	DEFINE cTipoLogica			CHAR(2);
	DEFINE dtFechaSigCorte		date;
	

	---INICIALIZACIONES
    LET iSqlErr            		= 0;
    LET cCodRet            		= '000000';
	LET cNumCredito				= '';
	LET cNumTarjeta				= '';
	LET cStatusMesAnt			= '';
	LET cStatusMesAct			= '';
	LET sFlagAutomatico			= 0;
	LET dtFechaUltCorte			= DATE(1);
	LET dtFechaHoy				= DATE(1);
	LET sMesUFC 				= 0;
	LET sDiaUFC 				= 0;
	LET sAnioUFC 				= 0;
	LET sMesHoy 				= 0;
	LET sDiaHoy 				= 0;
	LET sAnioHoy 				= 0;
	LET iNRows              	= 0;
	LET cTipoLogica				= '';
	LET dtFechaSigCorte			= DATE(1);
	

BEGIN
    
    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	---SET DEBUG FILE TO '/home/sysifx/has/sp_select_muestras.out';
	---TRACE ON;
	
	IF NVL(pEmpresa,'') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	-- OBTIENE LA ULTIMA FECHA DE CORTE DEL REPOSITORIO DE MUESTRAS
	SELECT MAX(fecha_corte)
	INTO dtFechaUltCorte
	FROM bdicred:'informix'.sd_muestra_edocta
	WHERE empresa = pEmpresa
	AND flag_generacion < 2
	AND fecha_corte = fecha_corte;
	
	--- VALIDA QUE LA ULTIMA FECHA DE CORTE NO ESTE VACIA
	IF NVL(dtFechaUltCorte,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000002';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	LET sMesUFC = MONTH(dtFechaUltCorte);
	LET sDiaUFC = DAY(dtFechaUltCorte);
	LET sAnioUFC = YEAR(dtFechaUltCorte);
	
	-- OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:'informix'.sd_fechas
	WHERE empresa = pEmpresa;

	
	--- VALIDA QUE LA FECHA DLEL SISTEMA NO ESTE VACIA
	IF NVL(dtFechaHoy,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000003';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	LET sMesHoy = MONTH(dtFechaHoy);
	LET sDiaHoy = DAY(dtFechaHoy);
	LET sAnioHoy = YEAR(dtFechaHoy);
	
	--- VALIDA QUE EL ULTIMO CORTE EN LAS MUESTRAS SEA EL CORTE DEL MES EN CURSO
	/*IF sAnioUFC <> sAnioHoy OR sMesUFC <> sMesHoy OR sDiaUFC <> 20 OR sDiaHoy < 20 THEN
		LET cCodRet = '000004';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF*/
	
	--LET dtFechaSigCorte	=  dtFechaUltCorte - 1 UNITS MONTH - 1 units day;
	
	-- OBTIENE LOS DATOS DE LAS MUESTRAS SELECCIONADAS
	FOREACH WITH HOLD
		SELECT	TRIM(NVL(num_credito,'')), 
				TRIM(NVL(num_tarjeta,'')), 
				TRIM(CASE WHEN NVL(estatus_mes_anterior,'') = '' THEN '' ELSE (SELECT descripcion FROM 'informix'.sd_tipocartera WHERE empresa = '001' AND status_cred = estatus_mes_anterior) END), 
				TRIM(CASE WHEN NVL(estatus_mes_actual,'') = '' THEN '' ELSE (SELECT descripcion FROM 'informix'.sd_tipocartera WHERE empresa = '001' AND status_cred = estatus_mes_actual) END),
				NVL(flag_automatico,0),
				tipo_logica
		INTO cNumCredito, cNumTarjeta, cStatusMesAnt, cStatusMesAct, sFlagAutomatico, cTipoLogica
		FROM bdicred:'informix'.sd_muestra_edocta
		WHERE empresa = pEmpresa
		AND fecha_corte = dtFechaUltCorte
		AND flag_generacion < 2
		

		RETURN cCodRet,cNumCredito,cNumTarjeta,cStatusMesAnt,cStatusMesAct,sFlagAutomatico,cTipoLogica WITH RESUME;
	END FOREACH
	
    LET iNRows = dbinfo("sqlca.sqlerrd2");
    
    IF iNRows = 0 THEN
        LET cCodRet = "000005";
        RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
    END IF
	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener las muestras ya seleeccionadas para se candidatas a a generar posteriormente el estado de cuenta', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2011',
'VERSION: 20110805.1813';

CREATE PROCEDURE "informix".sp_valida_numcredito(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaCorte DATE)
RETURNING CHAR (6) AS Codret, 
		  CHAR(100) AS Descripcion,
		  CHAR(20) AS NumCliente,
		  CHAR(20) AS NumCredito,		  
		  CHAR(20) AS NumTarjeta,
		  DATE AS Fecha,
		  DECIMAL(20,2) AS MontoFinVenTrasp,
		  CHAR(2) AS CodStatusAct,
		  CHAR(60) AS DescStatusAct,
		  CHAR (2) AS CodStatusAnt,
		  CHAR(60) AS DescStatusAnt;

---Definicion de Variables          
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(100);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE dtFechaCorte           DATE;
DEFINE dtFechaCorteAnt		 DATE;
DEFINE cNumCredito           CHAR(20);
DEFINE cNumTarjeta			 CHAR(20);
DEFINE cNumCte               CHAR(20);
DEFINE dtFecha                DATE;
DEFINE dMtoFinVenTrasp       DECIMAL(20,2);
DEFINE cStatusAct            CHAR(2);
DEFINE cDescStatusAct		 CHAR(60);
DEFINE cStatusAnt            CHAR(2);
DEFINE cDescStatusAnt		 CHAR(60);
DEFINE scont                 SMALLINT;
DEFINE dtFechaHoy 			 DATE;
DEFINE sMesHoy 				SMALLINT;
DEFINE sDiaHoy 				SMALLINT;
DEFINE sAnioHoy 			SMALLINT;


---Inicializaciones
LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Credito Valido";
LET dtFechaCorte				 = MDY(1,1,1900);
LET dtFechaCorteAnt			 = MDY(1,1,1900);         
LET cNumCredito            	 = "";
LET cNumTarjeta            	 = "";
LET cNumCte            	     = "";
LET dtFecha                 	 = MDY(1,1,1900);
LET dMtoFinVenTrasp        	 = 0;
LET cStatusAct             	 = "";
LET cDescStatusAct		  	 = "";
LET cStatusAnt            	 = "";
LET cDescStatusAnt		 	 = "";
LET scont                    = 0;
LET dtFechaHoy				 = MDY(1,1,1900);
LET sMesHoy 				= 0;
LET sDiaHoy 				= 0;
LET sAnioHoy 				= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet=cErrorInfo;
     RETURN cCodRet, cMensajeRet,'','','','',0,'','','','';
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/sp_valida_numcredito.out';
--TRACE ON;

	--Validacion de parametros de entrada
	IF (pEmpresa='') OR (pFechaCorte='') OR (pNumCredito='') OR (pEmpresa IS NULL) OR (pFechaCorte IS NULL) OR (pNumCredito IS NULL) THEN
		LET cCodRet = "000001";
		LET cMensajeRet="Uno o mas parametros de entrada son invalidos";
	ELSE		
		--Se obtienen las fechas de corte
		--LET dtFechaCorte=pFechaCorte;
		--LET dtFechaCorteAnt=mdy(MONTH(pFechaCorte),'20',YEAR(pFechaCorte)) - 1 units MONTH;
			
		-- OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:'informix'.sd_fechas
	WHERE empresa = pEmpresa;
	--- VALIDA QUE LA FECHA DLEL SISTEMA NO ESTE VACIA
	IF NVL(dtFechaHoy,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'LA FECHA DEL SISTEMA ESTA VACIA';
	END IF
	LET sMesHoy = MONTH(dtFechaHoy);
	LET sDiaHoy = DAY(dtFechaHoy);
	LET sAnioHoy = YEAR(dtFechaHoy);
	
	--- VALIDA QUE EL ULTIMO CORTE EN LAS MUESTRAS SEA EL CORTE DEL MES EN CURSO
	IF sDiaHoy < 20 THEN
	LET dtFechaCorte = dtFechaHoy - 1 units MONTH;
	LET dtFechaCorte = mdy(MONTH(dtFechaCorte),'20',YEAR(dtFechaCorte)); 
	LET dtFechaCorteAnt=mdy(MONTH(dtFechaCorte),'20',YEAR(dtFechaCorte)) - 1 units MONTH;
	ELSE
	LET dtFechaCorte = mdy(MONTH(dtFechaHoy),'20',YEAR(dtFechaHoy));
	LET dtFechaCorteAnt=mdy(MONTH(dtFechaCorte),'20',YEAR(dtFechaCorte)) - 1 units MONTH;
	END IF
		
		IF NOT EXISTS (SELECT num_credito FROM bdicred:"informix".sd_muestra_edocta 
									WHERE num_credito = pNumCredito) THEN
									
			--Se consulta la información del cliente con el credito recibido.					
			SELECT a.num_credito,c.numcte,c.num_tarjeta, a.fecha, a.mto_fin_ven_trasp, 				 
			(CASE WHEN a.monto_vencido > 0 THEN 'BA' WHEN a.mto_venc_trasp > 0 THEN 'BT' WHEN a.sdo_capital = a.sdo_cap_insoluto THEN 'AA' END)estatus_actual,
			(CASE WHEN b.monto_vencido > 0 THEN 'BA' WHEN b.mto_venc_trasp > 0 THEN 'BT' WHEN b.sdo_capital = b.sdo_cap_insoluto THEN 'AA' END)estatus_anterior
			INTO cNumCredito,cNumCte,cNumTarjeta,dtFecha,dMtoFinVenTrasp,cStatusAct,cStatusAnt
			FROM bdicred:"informix".sd_maecred d, 
            bdicred:"informix".sd_maesdoshist a  , 
            bdicred:"informix".sd_tarjeta c, 
            bdicred:"informix".sd_maesdoshist b  
			WHERE d.empresa = '001' 
			AND d.num_credito = pNumCredito
			AND a.num_credito = d.num_credito				
			AND a.fecha=dtFechaCorte
			AND a.empresa = '001'
			AND a.empresa = c.empresa
			AND a.num_credito = c.num_credito
			AND c.secuencia = 
            (SELECT MAX(tar2.secuencia) 
                    FROM bdicred:"informix".sd_tarjeta tar2 
                    WHERE tar2.empresa = a.empresa
                    AND tar2.num_credito = a.num_credito AND tar2.tipo_tarjeta ='T')
			AND c.tipo_tarjeta ='T'
      		AND b.num_credito= d.num_credito
			AND b.empresa=c.empresa
			AND b.num_credito= c.num_credito
			AND b.fecha=dtFechaCorteAnt;
			
			LET scont = dbinfo("sqlca.sqlerrd2");
			IF scont = 0 THEN
				LET cCodRet= "000003";
				LET cMensajeRet= "Numero de Credito no valido";			
			END IF;
			---Se obtienen las descripciones de los estatus
			SELECT descripcion
			INTO cDescStatusAct
			FROM bdicred:"informix".sd_tipocartera
			WHERE status_cred=cStatusAct;
			
			SELECT descripcion
			INTO cDescStatusAnt
			FROM bdicred:"informix".sd_tipocartera
			WHERE status_cred=cStatusAnt;				
		ELSE 
			LET cCodRet = "000002";
			LET cMensajeRet="El credito ya existe como muestra para la fecha de corte";
		END IF;
	END IF;
	RETURN cCodRet, cMensajeRet,NVL(cNumCte,''),NVL(cNumCredito,''),NVL(cNumTarjeta,''),NVL(dtFecha,MDY(1,1,1900)),NVL(dMtoFinVenTrasp,0),NVL(cStatusAct,''),NVL(cDescStatusAct,''),NVL(cStatusAnt,''),NVL(cDescStatusAnt,'');
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para validar si existe el credito y obtener la información del cliente Titular del credito',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 13/JULIO/2011',
'BD: BDICRED',
'VERSION:20110713.1030';

CREATE PROCEDURE "informix".calculamesiversario(diacorte INTEGER, fechatrab DATE, cantidad INTEGER, TpDiasFechaPago INTEGER)
     RETURNING
       CHAR(5)        AS Cod_Ret,
       DATE           AS fecha_mes;

     DEFINE d1            DATE;
     DEFINE cCodRet       CHAR(5);
     DEFINE FechaMes      DATE;
     DEFINE FechaAux      DATE;
     DEFINE ldiaMes       INTEGER;
     DEFINE d2            DATE;

    LET d1      = DATE(1);
    LET cCodRet ='00000';
    LET FechaMes = DATE(1);
    LET FechaAux = DATE(1);

  --  set debug file to "/pisa/cas/calculamesiversario.out";
  --  trace on;

    LET fechatrab = MDY(MONTH(fechatrab),'01',YEAR(fechatrab));

    if (TpDiasFechaPago = 2) then  -- indicador calculos quincenales
        if (diacorte <= 15) then
            CALL "informix".monthadd(fechatrab,cantidad) RETURNING FechaMes;
        else
            let FechaMes = fechatrab;
        end if;
    else
        CALL "informix".monthadd(fechatrab,cantidad) RETURNING FechaMes;
    end if;

    LET FechaAux = FechaMes;

    WHILE (day(FechaAux) <> diacorte and month(FechaAux) = month(FechaMes))
        LET FechaAux = FechaAux + 1;
    END WHILE

        IF month(FechaAux) <> month(FechaMes) THEN
           LET FechaAux = FechaAux - 1;
        END IF;

    CALL "informix".sp_valfechabil(FechaAux,'+') RETURNING cCodRet, FechaMes;

    RETURN cCodRet, FechaMes;

END PROCEDURE;