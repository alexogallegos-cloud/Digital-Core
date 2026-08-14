CREATE PROCEDURE "informix".sp_grabarincrementolincred(pEmpresa  CHAR(3), 
													   pSolicitud CHAR(20))
															
RETURNING CHAR(5) AS CodigoRetorno, 
		  CHAR(80) AS Mensaje;			

DEFINE cod_ret     CHAR(5);
DEFINE cod_retseg     CHAR(5);
DEFINE vFechaFin   DATE;
DEFINE vFechaIni   DATE;
DEFINE vLinCred    DECIMAL(18,2);
DEFINE vCont       SMALLINT;
DEFINE sql_err     SMALLINT;
DEFINE vMen        CHAR(80);
DEFINE vMenseg     CHAR(80);
DEFINE cErrorInfo  CHAR(80);
DEFINE iIsamErr    SMALLINT;
DEFINE vDias       smallint;
DEFINE cNumproducto CHAR(04);
DEFINE vIncremento DECIMAL(18,2);
DEFINE cSucursal   CHAR(04);

LET cod_ret        = "00000";
LET cod_retseg        = "00000";
LET vFechaFin      = DATE(1);
LET vFechaIni      = DATE(1);
LET vLinCred       = 0;
LET vCont          = 0;
LET sql_err        = 0;
LET vMen           = "El proceso se ejecuto correctamente";
LET vMenseg     = "El proceso se ejecuto correctamente";
LET cErrorInfo     = "";
LET iIsamErr       = 0;
LET vDias          = 0;
LET cNumproducto   = '';
LET vIncremento    = 0;
LET cSucursal      = '';

BEGIN
	
ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
    IF sql_err != 0 THEN
        LET cod_ret = sql_err;
        LET vMen= cErrorInfo;
        RETURN cod_ret, vMen;	
    END IF;
END EXCEPTION;

 --SET DEBUG FILE TO '/informix/sp_grabarincrementolincred.out';
 --TRACE ON ;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
IF (NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "") THEN
    LET cod_ret = "456";
    LET vMen    = "Parametros insuficientes para realizar la consulta";
    RETURN cod_ret, vMen;
END IF;

SELECT fecha_hoy 
  INTO vFechaFin 
  FROM bdicred:sd_fechas
 WHERE empresa = pEmpresa;

SELECT TRIM(valor) INTO vDias FROM bdicred:sd_param WHERE empresa = pEmpresa and cod_param = '011';

LET vFechaIni = vFechaFin - vDias UNITS DAY;
/*
SELECT lincred_sugerida, num_producto, lincred_sugerida - lincred_actual,sucursal
  INTO vLinCred,cNumproducto,vIncremento,cSucursal 
  FROM bdicred:sd_bitacora_aumlincred
 WHERE empresa = pEmpresa 
   AND num_solicitud = pSolicitud 
   AND status = 'AP'  
   AND fecha_status BETWEEN vFechaIni AND vFechaFin;
   */
   SELECT lincred_sugerida, num_producto, lincred_sugerida - lincred_actual,sucursal
  INTO vLinCred,cNumproducto,vIncremento,cSucursal 
  FROM bdicred:sd_bitacora_aumlincred
 WHERE empresa = pEmpresa 
   AND num_solicitud = pSolicitud 
   AND status = 'AP'  
   AND fecha_insert = ( SELECT MAX(fecha_insert)
						FROM bdicred:sd_bitacora_aumlincred
						WHERE empresa = pEmpresa 
						AND num_solicitud = pSolicitud 
						AND status = 'AP' );
   
   
/*
SELECT lincred_sugerida 
  INTO vLinCred 
  FROM bdicred:sd_prospectos_aumlincred
 WHERE empresa = pEmpresa 
   AND num_solicitud = pSolicitud 
   AND resp_cte = '1'  
   AND fecha_insert BETWEEN vFechaIni AND vFechaFin;
*/
   LET vCont = DBINFO("sqlca.sqlerrd2");
   IF vCont = 0 THEN
       LET cod_ret = "457"; -- El cliente no a autorizado o esta fuera de la vigencia
       LET vMen    = "El Cliente no a autorizado y/o fuera de vigencia";
       RETURN cod_ret, vMen;
   END IF;

   UPDATE bdicred:sd_maesdos 
      SET monto_otorgado = vLinCred, 
          fecha_ult_mov = vFechaFin 
    WHERE empresa = pEmpresa
      AND num_credito = pSolicitud;

    LET vCont = DBINFO("sqlca.sqlerrd2");
    IF vCont = 0 THEN 
        LET cod_ret = "458"; -- No existe el Cliente en la sd_maesdos
        LET vMen    = "No existe el Cliente en la sd_maesdos";
        RETURN cod_ret, vMen;
    END IF;

    EXECUTE PROCEDURE bdicred:GENMOV( pEmpresa, pSolicitud
                                     , cNumproducto , 1
                                     ,'008' , vFechaFin
                                     , vIncremento , 'Act LineaCredito'
                                     , cSucursal, '01'
                                     , '0000'
                                     ) INTO cod_ret, vMen;
	
	IF cod_ret = "00000" THEN
	EXECUTE PROCEDURE bdicred:sp_segmentacion_lincred( pEmpresa, pSolicitud, vLinCred) INTO cod_retseg, vMenseg;
	
		ELSE
	
			IF cod_retseg != "00000" THEN 
				LET cod_ret = cod_retseg; 
				LET vMen    = "Error al Grabar Segmento en sp bdicred:sp_segmentacion_lincred";
			RETURN cod_ret, vMen;
			END IF;
	END IF;
														
	
RETURN cod_ret, vMen;

END;
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para grabar',
'el incremto de la linea de credito',
'AUTOR : Nubia Janeth Montoya Medina ',
'FECHA : 05/JULIO/2010',
'BD    : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Incremento de linea de credito por inflacion',
'Modifico    : SECP',
'Fecha       : 07/10/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se separo la logica de Incremento de linea de credito por inflacion por el fallo del monto otrogado, se realiza el grabado en de infacion en el sp_grabarincrementolincredinf ',
'Modifico    : SECP',
'Fecha       : 07/31/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_grabarincrementolincredinf(pEmpresa  CHAR(3), 
													   pSolicitud CHAR(20))
															
RETURNING CHAR(5)   AS CodigoRetorno, 
		  CHAR(80)  AS Mensaje;			

-- CONTROL DE CAMBIOS:
---------------------------------------------------------------------------------
-- Autor: SECP.
-- Modificacion: Graba el incremento por inflacion.
-- Fecha de Modificacion: 31/07/2025.
-- Peticion: RQM 10 1647 â Incremento  linea de credito TDC por inflacion.
---------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************	
DEFINE cod_ret                  CHAR(5);            -- Codigo de retono
DEFINE vFechaFin                DATE;               -- Fecha de fin o fecha actual del sistema.
DEFINE vFechaIni                DATE;               -- Fecha de inicio calculada (fecha actual - vDias).
DEFINE vCont                    SMALLINT;           -- Contador de filas afectadas por un UPDATE/DELETE.
DEFINE sql_err                  SMALLINT;           -- Codigo de error SQL.
DEFINE vMen                     CHAR(80);           -- Mensaje de retorno del procedimiento.
DEFINE cErrorInfo               CHAR(80);           -- Informacion detallada del error SQL.
DEFINE iIsamErr                 SMALLINT;           -- Codigo de error ISAM (errores del sistema de archivos).
DEFINE vDias                    SMALLINT;           -- Numero de dias para calculo de fechas.
DEFINE cNumproductoInf          CHAR(04);           -- Numero de producto asociado al incremento por inflacion.
DEFINE vIncrementoInf           DECIMAL(18,2);      -- Monto del incremento por inflacion.
DEFINE cSucursalInf             CHAR(4);            -- Sucursal asociada al incremento por inflacion.
DEFINE vLinCredInf              DECIMAL(18,2);      -- Nueva linea de credito despues del incremento por inflacion.
DEFINE c_incremento_inflacion   CHAR(1);            -- Bandera de aceptacion/rechazo del incremento por inflacion.
DEFINE cCodretConBue 		    CHAR(5);            -- Codigo de retorno de sp_consultarctesincrementolincred_web.
DEFINE cMensaje 				CHAR(80);           -- Mensaje de sp_consultarctesincrementolincred_web.
DEFINE cIsCtePros 				CHAR(1);            -- Indica si el cliente es prospecto (de sp_consultarctesincrementolincred_web).
DEFINE c_num_cte 				CHAR(20);           -- Numero de cliente.
DEFINE cNombre 				    CHAR(120);          -- Nombre del cliente.
DEFINE cRFC 					CHAR(13);           -- RFC del cliente.
DEFINE dtFechaSol 				DATE;               -- Fecha de solicitud (de sp_consultarctesincrementolincred_web).
DEFINE dtFechaAut 				DATE;               -- Fecha de autorizacion (de sp_consultarctesincrementolincred_web).
DEFINE dLinCredAct 				DECIMAL(18,2);      -- Linea de credito actual (de sp_consultarctesincrementolincred_web).
DEFINE dLinCredCal 				DECIMAL (18,2);     -- Linea de credito calculada (de sp_consultarctesincrementolincred_web).
DEFINE cOrigen 					CHAR(1);            -- Origen (de sp_consultarctesincrementolincred_web).
DEFINE cStatus 					CHAR(2);            -- Estatus (de sp_consultarctesincrementolincred_web).
DEFINE cDescStatus 				CHAR(40);           -- Descripcion del estatus (de sp_consultarctesincrementolincred_web).
DEFINE cComentario 				CHAR(80);           -- Comentario (de sp_consultarctesincrementolincred_web).
DEFINE cNumSol 				    CHAR(20);           -- Numero de solicitud (de sp_consultarctesincrementolincred_web).
DEFINE cNumcte                  CHAR(20);           -- Numero de cliente para ejecutar sp_consultarctesincrementolincred_web.

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET cod_ret                 = "00000";
LET vFechaFin               = DATE(1);
LET vFechaIni               = DATE(1);
LET vCont                   = 0;
LET sql_err                 = 0;
LET vMen                    = "El proceso se ejecuto correctamente";
LET cErrorInfo              = "";
LET iIsamErr                = 0;
LET vDias                   = 0;
LET cNumproductoInf         = '';
LET vIncrementoInf          = 0;
LET cSucursalInf            = '';
LET vLinCredInf             = 0;
LET c_incremento_inflacion  = "";
LET cCodretConBue 			= "";
LET cMensaje 				= "";
LET cIsCtePros 				= "";
LET c_num_cte 				= ""; 
LET cNombre 				= "";
LET cRFC 					= "";
LET dtFechaSol 				= '';
LET dtFechaAut 				= ''; 
LET dLinCredAct 			= 0;
LET dLinCredCal 			= 0;
LET cOrigen 				= '';
LET cStatus 				= '';
LET cDescStatus 			= '';
LET cComentario 			= '';
LET cNumSol 				= '';
LET cNumCte                 = '';

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
	
    ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
        IF sql_err != 0 THEN
            LET cod_ret = sql_err;
            LET vMen= cErrorInfo;
            RETURN cod_ret, vMen;	
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- SET DEBUG FILE TO '/informix/sp_grabarincrementolincred.out';
    -- TRACE ON;

    -- **********************************************************************
    -- *                        PROGRAMA PRINCIPAL
    -- **********************************************************************

    -- Valida que los parametros de entrada no esten vacios.
    IF (NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "") THEN
        LET cod_ret = "00003";
        LET vMen    = "Parametros insuficientes para realizar la consulta";
        RETURN cod_ret, vMen;
    END IF;

    -- Obtiene la fecha actual del sistema desde la tabla sd_fechas para la empresa.
    SELECT fecha_hoy 
        INTO vFechaFin 
        FROM bdicred:sd_fechas
        WHERE empresa = pEmpresa;

    -- Obtiene el numero de dias de un parmetrizado para calcular la fecha de inicio.
    SELECT TRIM(valor) INTO vDias FROM bdicred:sd_param WHERE empresa = pEmpresa and cod_param = '011';

    -- Calcula la fecha de inicio restando los dias de la fecha actual.
    LET vFechaIni = vFechaFin - vDias UNITS DAY;


    -- Busca el ultimo incremento por inflacion que ha sido aceptado por el cliente pero que aun no ha sido aplicado.
    SELECT nueva_linea_credito, num_producto, nueva_linea_credito  - linea_actual,sucursal,bandera_aceptacion_rechazo,num_cliente
        INTO vLinCredInf,cNumproductoInf,vIncrementoInf,cSucursalInf,c_incremento_inflacion,cNumCte 
        FROM bdicred:sd_bitacora_incremento_inflacion 
        WHERE  num_credito = pSolicitud 
        AND bandera_aceptacion_rechazo  = "1"
        AND confirma_incremento = "0"
        AND fecha_aceptacion_oferta = (SELECT MAX(fecha_aceptacion_oferta) 
                                            FROM bdicred:sd_bitacora_incremento_inflacion 
                                            WHERE  num_credito = pSolicitud 
                                            AND bandera_aceptacion_rechazo  = "1"
                                            AND confirma_incremento = "0" );

            -- Llama al sp_consultarctesincrementolincred_web para verificar si el cliente tiene un incremento por buen comportamiento pendiente.
            EXECUTE PROCEDURE bdicred:"informix".sp_consultarctesincrementolincred_web("001",cNumCte,"","","1","",0,0) 
                INTO cCodretConBue, cMensaje, cIsCtePros, c_num_cte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, cComentario, cNumSol;

            -- Valida que no haya un incremento por buen comportamiento activo si lo hay, el incremento por inflacion no puede ser aplicado.
            IF cCodretConBue = "00000" THEN
                LET vMen    = "El Incremento por buen comportamiento esta en activo";
                LET cod_ret  = '00004'; 
                RETURN cod_ret, vMen;
            END IF;

        -- Valida si se encontro un registro de incremento por inflacion pendiente, si no se encuentra, significa que el cliente no ha aceptado o la oferta ya no es valida.
        IF vLincredInf IS NULL THEN
            LET cod_ret = "00001"; -- No existe el Cliente en la sd_maesdos
            LET vMen    = "El Cliente no a autorizado y/o fuera de vigencia";
            RETURN cod_ret, vMen;
        END IF;
        
        -- Actualiza la linea de credito en la tabla sd_maesdos.
        UPDATE bdicred:sd_maesdos 
            SET monto_otorgado = vLinCredInf, 
            fecha_ult_mov = vFechaFin 
            WHERE empresa = pEmpresa
            AND num_credito = pSolicitud;

        -- Obtiene el numero de filas afectadas por el UPDATE.
        LET vCont = DBINFO("sqlca.sqlerrd2");

        -- Si no se afecto ninguna fila, significa que el registro del cliente no se encontro.
        IF vCont = 0 THEN 
            LET cod_ret = "00002"; -- No existe el Cliente en la sd_maesdos
            LET vMen    = "No existe el Cliente en la sd_maesdos";
            RETURN cod_ret, vMen;
        END IF;

        -- Llama a al GENMOV para registrar el movimiento de la actualizacion de la linea de credito en la tabla sd_movdia.
        EXECUTE PROCEDURE bdicred:GENMOV( pEmpresa, pSolicitud
                                        , cNumproductoInf , 1
                                        ,'008' , vFechaFin
                                        , vIncrementoInf , 'Act LinCredInfla'
                                        , cSucursalInf, '01'
                                        , '0000'
                                        ) INTO cod_ret, vMen;
                                                            
        
    RETURN cod_ret, vMen;

END;
END PROCEDURE
DOCUMENT 
'Autor       : SECP',
'Modificacion: Graba el incremento por inflacion.',
'Fecha       : 07/31/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

create procedure "informix".sp_geninsumos_calif_parte(pEjecucion smallint)
       returning char(5) ,CHAR(100),char(60);
	   
    DEFINE vcodret          CHAR(5);			DEFINE iSqlErr      	INTEGER;
	DEFINE iIsamErr         INTEGER;			DEFINE cErrorInfo       CHAR(100);
	DEFINE cMensajeRet    	CHAR(100);
	
	DEFINE n_alto					SMALLINT;		DEFINE c_antecedentes_buro 		CHAR(4);
	DEFINE n_antig_cte		 		INTEGER;		DEFINE n_antig_cred				INTEGER;	
	DEFINE n_bajo					SMALLINT;		DEFINE n_bkatr					INTEGER;	
	DEFINE n_bloq					SMALLINT;		DEFINE n_bloq_op				SMALLINT;	
	DEFINE d_capital_ven_exigible	DECIMAL (18,2);	DEFINE d_capital_vig_exigible	DECIMAL (18,2);
	DEFINE d_comision_apert			DECIMAL (18,2);	DEFINE d_comision_disp			DECIMAL (18,2);
	DEFINE n_consulta_sin_info		SMALLINT;		DEFINE n_mop					INTEGER;
	DEFINE c_facturacion			VARCHAR (9);	DEFINE dt_apertura				DATE;
	DEFINE dt_ap_cte				DATE;			DEFINE dt_ultcons_varcc			DATE;
	DEFINE dt_corte					DATE;			DEFINE dt_fec_reest				DATE;
	DEFINE c_gpo_originacion		CHAR (1);		DEFINE n_gveces_1				SMALLINT;
	DEFINE n_gveces_2				SMALLINT;		DEFINE n_gveces_3				SMALLINT;
	DEFINE n_impagos_consec			INTEGER;		DEFINE n_imp_hist_6m			INTEGER;
	DEFINE n_sin_mov				INTEGER;		DEFINE d_moratorios				DECIMAL (18,2);	
	DEFINE d_intvenc_bal			DECIMAL (18,2);	DEFINE d_intvenc_ord			DECIMAL (18,2);
	DEFINE d_int_venc_exig_corte	DECIMAL (18,2);	DEFINE d_int_venc_exig_cierre	DECIMAL (18,2);
	DEFINE d_int_vig_exig			DECIMAL (18,2);	DEFINE d_limite_credito			DECIMAL (18,2);
	DEFINE d_limite_credito_corte	DECIMAL (18,2);	DEFINE d_limite_credito_inicio	DECIMAL (18,2);
	DEFINE d_limite_credito_orig	DECIMAL (18,2);	DEFINE n_medio					SMALLINT;
	DEFINE n_meses_pagosost			INTEGER;		DEFINE n_meses_venc				DECIMAL (18,2);
	DEFINE d_monto_exigido			DECIMAL (18,2);	DEFINE d_monto_exigido1			DECIMAL (18,2);
	DEFINE d_monto_exigido2			DECIMAL (18,2);	DEFINE d_monto_exigido3			DECIMAL (18,2);
	DEFINE d_monto_pagar_otros		DECIMAL (18,2);	DEFINE d_monto_pagar_propio		DECIMAL (18,2);
	DEFINE n_moras					INTEGER;		DEFINE c_nom_cte				VARCHAR (107);
	DEFINE c_numcte					CHAR (20);		DEFINE c_num_credito			CHAR (20);
	DEFINE c_cta_credisol			CHAR (20);		DEFINE c_producto				CHAR (4);
	DEFINE d_pago_capital			DECIMAL (18,2);	DEFINE d_pago_int_venc			DECIMAL (18,2);
	DEFINE n_pago_int_vig			DECIMAL (18,2);	DEFINE d_pago_minimo			DECIMAL (18,2);
	DEFINE d_pago_realizado			DECIMAL (18,2);	DEFINE d_pago_realizado_1		DECIMAL (18,2);
	DEFINE d_pago_realizado_2		DECIMAL (18,2);	DEFINE d_pago_realizado_3		DECIMAL (18,2);
	DEFINE n_pago_sost				SMALLINT;		DEFINE d_porcentaje_pago		DECIMAL (18,6);
	DEFINE d_porcentaje_uso			DECIMAL (18,6);	DEFINE n_resc					SMALLINT;
	DEFINE d_saldo_cierre			DECIMAL (18,2);	DEFINE d_saldo_cierre_credisol	DECIMAL (18,2);
	DEFINE d_saldo_corte			DECIMAL (18,2);	DEFINE d_saldo_corte_credisol	DECIMAL (18,2);
	DEFINE d_saldo_corte1			DECIMAL (18,2);	DEFINE d_saldo_corte2			DECIMAL (18,2);
	DEFINE d_saldo_corte3			DECIMAL (18,2);	DEFINE d_saldo_exigible			DECIMAL (18,2);
	DEFINE d_saldo_no_exigible		DECIMAL (18,2);	DEFINE n_scoreburo				INTEGER;
	DEFINE n_scoreotor				INTEGER;		DEFINE n_sin_consulta			SMALLINT;
	DEFINE c_status_corte			CHAR (2);		DEFINE c_status_mes_reporte		CHAR (2);
	DEFINE c_sucursal				CHAR (4);		DEFINE c_nombre_prod			VARCHAR (40);
	DEFINE dt_cierre_proc			DATE;
			 
	DEFINE dt_ini_per_proc DATE; 		DEFINE dt_ini_per_movs DATE;	
	DEFINE dt_ap_revolvente DATE;		DEFINE dt_ult_pos_disp DATE; 	
	DEFINE dt_ap_plazo     DATE;  		DEFINE dt_ult_vnt_disp DATE; 
	DEFINE dt_ult_atm_disp DATE; 		DEFINE dt_ult_pago 	   DATE;	
	DEFINE dt_ult_mov	   DATE;		DEFINE dt_ini_per_rep  DATE;	
	DEFINE dt_corte_plazo  DATE;		DEFINE dt_corte_credsol DATE;
	DEFINE dt_ult_compra   DATE;		DEFINE dt_ap_flex 		DATE;
	 	    
	DEFINE n_dia_corte INTEGER; 					DEFINE n_cod_bloqueo INTEGER; 					
	DEFINE n_ult_mov INTEGER; 						DEFINE dia_corte_plazo INTEGER; 
	DEFINE d_pago_minimo_plazo_a	DECIMAL (18,2); DEFINE dia_corte_credsol  INTEGER; 
	
	DEFINE d_monto_vencido_periodo 	DECIMAL (18,2); 	DEFINE d_mto_venc_trasp_periodo	DECIMAL (18,2);
	DEFINE d_pago_minimo_rev		DECIMAL (18,2);		DEFINE d_pago_minimo_plazo		DECIMAL (18,2);
	DEFINE d_pago_cap_vig 		 	DECIMAL (18,2);		DEFINE d_pago_cap_venc			DECIMAL (18,2);
	DEFINE d_saldo_corte_credisol_a  DECIMAL (18,2);
	DEFINE d_pago_nogenarar_int     DECIMAL (18,2);
	
	DEFINE cflg_cons_cc				CHAR(20);		DEFINE c_evalua_cc				 CHAR(1); 	
	DEFINE c_gveces					CHAR(7);		DEFINE cta_plazo 				 CHAR (20);
	DEFINE c_nombre1,c_nombre2		VARCHAR (26);	DEFINE c_ap_paterno,c_ap_materno VARCHAR (26); 
	DEFINE cta_credsol_msi 			CHAR (20);		DEFINE cred_ini,cred_fin  		 CHAR(20);	     
	DEFINE cMensajeRet2    	CHAR(60);	DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22); 	
	
	DEFINE bandera_sdos		SMALLINT; DEFINE v_saldo_corte,v_saldo_diferido,d_sdo_corte_cred1,d_sdo_corte_cred2,d_sdo_corte_cred3, d_sdo_corte_cred4 DECIMAL (18,2);
	DEFINE v_fec_sdo		DATE;

   DEFINE contador_commit	 INTEGER;	DEFINE val_trans_Commit   SMALLINT;
   DEFINE val_t1, val_t2,val_t3 SMALLINT;

----CJAC CAMPOS ADICIONALES 
    DEFINE d_comision_cobranza DECIMAL (18,2);
    DEFINE d_comisionexig_cobranza DECIMAL (18,2);
    DEFINE d_saldo_corte_t DECIMAL (18,2);
    DEFINE d_sdo_corte_cred_t DECIMAL (18,2);
    DEFINE v_numero_cuenta_det CHAR(20);
    DEFINE v_meses_primer_crdbco INTEGER;
    DEFINE v_meses_ult_atr_bk   INTEGER;
    DEFINE v_veces_monto_bco_sist CHAR(7);
    DEFINE v_intereses_ordinarios DECIMAL (18,2);
	DEFINE v_intereses_etapa1 DECIMAL (18,2);
	DEFINE v_intereses_etapa2 DECIMAL (18,2);
	DEFINE v_intereses_etapa3 DECIMAL (18,2);
    DEFINE v_intereses_moratorios DECIMAL (18,2);
    DEFINE v_num_pagos_vencidos INTEGER;
    DEFINE v_tasa_interes DECIMAL(18,5);
	DEFINE v_tasa_efectiva DECIMAL(18,5);
    DEFINE v_capital_cierre DECIMAL(18,2);
    DEFINE v_numero_anios   DECIMAL(18,5);
    DEFINE v_etapa_cred     CHAR(8);
    DEFINE v_gastos_originacion DECIMAL(18,2);
    DEFINE v_modelo_score   CHAR(6);
    DEFINE v_segmento       CHAR(6);
    DEFINE v_eficiencia     DECIMAL(18,2);
    DEFINE v_exist_seg      INTEGER;
	DEFINE v_form_sdoapagarxri	DECIMAL(18,2);
	DEFINE v_form_pgominx12 DECIMAL(18,2);
	DEFINE v_form1 DECIMAL(18,2);
	DEFINE v_log1 DECIMAL(18,2);
	DEFINE v_log2 DECIMAL(18,2);
	DEFINE n_imp_hist_6m_corte INTEGER;
	DEFINE n_impagos_consec_corte INTEGER;
	DEFINE v_etapa_cred_corte     CHAR(8);
	DEFINE cCodRet1 CHAR(6);
	DEFINE ptipogrupo CHAR(1);
	DEFINE pevalua_cc CHAR(1);
	
	DEFINE v_indicador_cat     		SMALLINT; 
	DEFINE v_num_cta_msi	CHAR(20);
	DEFINE v_num_cta_msi_tmp CHAR(20);
	DEFINE v_num_producto_mc	 CHAR(4);
	DEFINE d_sdo_corte_msi_t DECIMAL(18,2);				   				   
	DEFINE v_sdo_corte_msi DECIMAL(18,2);
	DEFINE v_sdo_corte_msi_1 DECIMAL(18,2);
	DEFINE v_sdo_corte_msi_2 DECIMAL(18,2);
	DEFINE v_sdo_corte_msi_3 DECIMAL(18,2);
	DEFINE v_sdo_corte_msi_4 DECIMAL(18,2);
	DEFINE v_saldo_cierre_msi_tmp DECIMAL(18,2);
	DEFINE v_sdo_corte_msi_1_tmp DECIMAL(18,2);
	DEFINE v_sdo_corte_msi_2_tmp DECIMAL(18,2);
	DEFINE v_sdo_corte_msi_3_tmp DECIMAL(18,2);
	DEFINE v_sdo_corte_msi_4_tmp DECIMAL(18,2);										 																						
	DEFINE v_saldo_diferido_msi DECIMAL (18,2);										
	DEFINE v_Promedio_MSI_contratados DECIMAL(18,2);
	DEFINE v_Promedio_MSI_plazo DECIMAL (18,2);
	DEFINE v_Promedio_MSI_meses DECIMAL (18,2);										
	DEFINE v_Promedio_MSI_amort  DECIMAL(18,2);
	DEFINE v_Promedio_MSI_contratados_a DECIMAL(18,2);											   
	DEFINE v_Saldo_prom_MSI  DECIMAL(18,2);
	DEFINE v_Saldo_prom_MSI_a DECIMAL(18,2);
	DEFINE v_saldopmsi_total DECIMAL(18,2);									 									
	DEFINE v_MSI_hist  DECIMAL(18,2);
	DEFINE v_MSI_act  DECIMAL(18,2);
	DEFINE v_saldo_cierre_msi  DECIMAL(18,2);
	DEFINE v_MSI_amort_plazo SMALLINT;
	DEFINE v_MSI_amort_pagados SMALLINT;
	DEFINE v_MSI_amort_a DECIMAL(18,2);
	DEFINE v_MSI_amort DECIMAL(18,2);
	DEFINE v_MSI_amort_count DECIMAL(18,2);									
	DEFINE v_numtarjeta CHAR(18); 
	DEFINE v_rfc CHAR(16); 
	DEFINE v_curp CHAR(20);
	DEFINE v_cod_postal CHAR(10);
	
	DEFINE v_catcontrato DECIMAL(18,2);
	DEFINE v_pagoexigepsi DECIMAL(18,2);
	DEFINE v_saldopmsi DECIMAL(18,2);
	DEFINE v_cod_ret_otro CHAR(5);
	DEFINE v_periodo_anterior DATE;
	DEFINE v_dias_periodo_tc INTEGER;
	DEFINE v_sdo_acum_mes DECIMAL(18,2);
	DEFINE v_sdo_acum_int DECIMAL(18,2);
	DEFINE v_saldo_rev DECIMAL(18,2);
    DEFINE v_interes_rev DECIMAL(18,2);
	DEFINE v_meses SMALLINT;
	DEFINE sum_capvig1 DECIMAL(18,2);
	DEFINE sum_capvig2 DECIMAL(18,2);
	DEFINE v_saldopci DECIMAL(18,2);
	DEFINE v_saldopci_total DECIMAL(18,2);
	DEFINE v_interesespci DECIMAL(18,2);
	DEFINE v_dia_corte_credisol SMALLINT;
	DEFINE v_tasa_fija DECIMAL(18,2);
	DEFINE v_relacion SMALLINT; 
	DEFINE v_cte_relevante	        SMALLINT;
	DEFINE d_pago_nogint_inicio     DECIMAL (18,2);
	DEFINE v_tasa_rev DECIMAL (18,2);
	DEFINE v_cat_cuenta DECIMAL (18,2);
	DEFINE v_pagongi	DECIMAL(18,2);
	DEFINE v_pagonginicio DECIMAL(18,2);
	DEFINE v_comtotal   DECIMAL(18,2);
	DEFINE v_comtardio  DECIMAL(18,2);
	DEFINE v_comremf DECIMAL(18,2);
	DEFINE v_comaclara DECIMAL(18,2);
	
	DEFINE v_verificacion_num_anios DECIMAL;
  
  --Requerimiento de septiembre 2022
  	DEFINE v_pago_cierre DECIMAL (18,2);	 --pago_cierre
	DEFINE v_pago_cierre_1 DECIMAL (18,2);	 --pago_cierre_1
	DEFINE v_pago_cierre_2 DECIMAL (18,2); --pago_cierre_2
	DEFINE v_pago_cierre_3 DECIMAL (18,2); --pago_cierre_3
	DEFINE dt_corte_cierre DATE;
	DEFINE dt_cierre_prod_pago_cierre_1 DATE;
	DEFINE dt_cierre_prod_pago_cierre_2 DATE;
	DEFINE dt_cierre_prod_pago_cierre_3 DATE;
	DEFINE dt_ini_prod_pago_cierre_1 DATE;
	DEFINE dt_ini_prod_pago_cierre_2 DATE;	
		
	DEFINE v_impago0 SMALLINT;
	DEFINE v_impago1 SMALLINT;
	DEFINE v_impago2 SMALLINT;
	DEFINE v_impago3 SMALLINT;

	DEFINE v_impago0_corte	SMALLINT;
	DEFINE v_impago1_corte	SMALLINT;
	DEFINE v_impago2_corte	SMALLINT;
	DEFINE v_impago3_corte	SMALLINT;
	
		--leer archivo
	DEFINE sqlArchivoLeer CHAR(20000);
	DEFINE contador INTEGER;
	DEFINE mes CHAR(2);
	DEFINE anio CHAR(4);
	DEFINE comandoNombre CHAR(500);
	DEFINE pRutaArchivo char(500);
	DEFINE pNombreArchivo  CHAR(300);

    LET vcodret = "00000";		LET cMensajeRet = "";	

	LET n_alto					= 0;		LET c_antecedentes_buro 	= '';		
	LET n_antig_cte		 		= 0;		LET n_antig_cred			= 0;		
	LET n_bajo					= 0;		LET n_bkatr					= 0;	
	LET n_bloq					= 0;		LET n_bloq_op				= 0;		
	LET d_capital_ven_exigible	= 0;		LET d_capital_vig_exigible	= 0;		
	LET d_comision_apert		= 0;		LET d_comision_disp			= 0;
	LET n_consulta_sin_info		= 0;		LET n_mop					= 0;		
	LET c_facturacion			= '';		LET dt_apertura				= date(1);	
	LET dt_ap_cte				= date(1);	LET dt_ultcons_varcc		= date(1);
	LET dt_corte				= date(1);	LET dt_fec_reest			= date(1);	
	LET c_gpo_originacion	    = ''; 		
	LET n_gveces_1				= 0;		
	LET n_gveces_2				= 0;		LET n_gveces_3				= 0;
	LET n_impagos_consec		= 0;		LET n_imp_hist_6m			= 0;		
	LET n_sin_mov				= 0;		LET d_moratorios			= 0;		
	LET d_intvenc_bal			= 0;		LET d_intvenc_ord			= 0;
	LET d_int_venc_exig_corte	= 0;		LET d_int_venc_exig_cierre	= 0;		
	LET d_int_vig_exig			= 0;		LET d_limite_credito		= 0;		
	LET d_limite_credito_corte	= 0;		LET d_limite_credito_inicio	= 0;
	LET d_limite_credito_orig	= 0;		LET n_medio					= 0;		
	LET n_meses_pagosost		= 0;		LET n_meses_venc			= 0;		
	LET d_monto_exigido			= 0;		LET d_monto_exigido1		= 0;
	LET d_monto_exigido2		= 0;		LET d_monto_exigido3		= 0;		
	LET d_monto_pagar_otros		= 0;		LET d_monto_pagar_propio	= 0;		
	LET n_moras					= 0;		LET c_nom_cte				= '';
	LET c_numcte				= '';		LET c_num_credito		    = '';		
	LET c_cta_credisol			= '';		LET c_producto				= ''; 		
	LET d_pago_capital			= 0;		LET d_pago_int_venc			= 0;
	LET n_pago_int_vig			= 0;		LET d_pago_minimo			= 0;		
	LET d_pago_realizado		= 0;		LET d_pago_realizado_1		= 0;		
	LET d_pago_realizado_2		= 0;		LET d_pago_realizado_3		= 0;
	LET n_pago_sost				= 0;		LET d_porcentaje_pago		= 0;		
	LET d_porcentaje_uso		= 0;		LET n_resc					= 0;		
	LET d_saldo_cierre			= 0;		LET d_saldo_cierre_credisol	= 0;
	LET d_saldo_corte			= 0;		LET d_saldo_corte_credisol	= 0;		
	LET d_saldo_corte1			= 0;		LET d_saldo_corte2			= 0;		
	LET d_saldo_corte3			= 0;		LET d_saldo_exigible		= 0;
	LET d_saldo_no_exigible		= 0;		LET n_scoreburo				= 0;		
	LET n_scoreotor				= 0;		LET n_sin_consulta			= 0;		
	LET c_status_corte			= '';		LET c_status_mes_reporte	= '';
	LET c_sucursal				= '';		LET c_nombre_prod			= '';		
	LET dt_cierre_proc			= date(1);	LET dt_ini_per_proc			= date(1);	
	LET dt_corte				= date(1);	LET dt_ini_per_movs 		= date(1);
	LET dt_ap_revolvente 		= date(1);	LET dt_ap_plazo 			= date(1); 		LET dt_ap_flex = date(1);	
	LET dt_ult_pos_disp			= date(1);  LET dt_ult_vnt_disp			= date(1); 	
	LET dt_ult_atm_disp			= date(1);	LET dt_ult_pago				= date(1); 
	LET dt_ult_mov				= date(1);	LET n_dia_corte 			= 0; 		
	LET n_cod_bloqueo 			= 0;		LET n_ult_mov 				= 0;		
	LET d_monto_vencido_periodo	= 0; 		LET d_mto_venc_trasp_periodo = 0;
	LET d_pago_minimo_rev		= 0;		LET d_pago_minimo_plazo		= 0;		
	LET d_pago_cap_vig 		 	= 0;		LET d_pago_cap_venc			= 0;		
	LET cflg_cons_cc			= '';		LET c_nombre1				= '';
	LET c_nombre2				='';		LET c_ap_paterno 			= '';		
	LET c_ap_materno    		='';		LET c_evalua_cc				='';		
	LET dt_ini_per_rep			= date(1);  LET cta_plazo				='';
	LET dia_corte_plazo			=0;			LET dt_corte_plazo			= date(1);  
	LET d_pago_minimo_plazo_a   =0;			LET cta_credsol_msi				=''; 		
	LET dia_corte_credsol  		=0; 		LET dt_corte_credsol		= date(1);
	LET d_saldo_corte_credisol_a =0;		LET dt_ult_compra			= date(1);
	LET cred_ini = '';      
	LET cred_fin = '';
	LET bandera_sdos		=0; LET v_fec_sdo=date(1); LET v_saldo_corte=0; LET v_saldo_diferido=0; 
	LET d_sdo_corte_cred1=0; LET d_sdo_corte_cred2=0; LET d_sdo_corte_cred3=0; LET  d_sdo_corte_cred4  = 0;
	LET contador_commit = 	0;	LET val_trans_Commit = 	0;
	LET val_t1 = 	0; LET  val_t2  = 	0; LET val_t3 = 	0;
	LET d_pago_nogenarar_int = 0;
	
--INICIALIZACION DE CAMPOS ADICIONALES
    LET d_comision_cobranza = 0;
    LET d_comisionexig_cobranza = 0;
    LET d_saldo_corte_t = 0;
    LET d_sdo_corte_cred_t = 0;
    LET v_numero_cuenta_det = '';
    LET v_meses_primer_crdbco = 0;
    LET v_meses_ult_atr_bk   = 0;
    LET v_veces_monto_bco_sist = 0;
    LET v_intereses_ordinarios = 0;
	LET v_intereses_etapa1 = 0;
	LET v_intereses_etapa2 = 0;
	LET v_intereses_etapa3 = 0;
    LET v_intereses_moratorios = 0; 
    LET v_num_pagos_vencidos =0;
    LET v_tasa_interes = 0;
	LET v_tasa_efectiva = 0;
    LET v_capital_cierre = 0;
    LET v_numero_anios = 0;
    LET v_etapa_cred ='';
    LET v_gastos_originacion =0;
    LET v_modelo_score='';
    LET v_segmento='';
    LET v_eficiencia=0;
    LET v_exist_seg=0;
	LET v_form_sdoapagarxri =0;
	LET v_form_pgominx12 =0;
	LET v_form1 =0;
	LET v_log1 =0;
	LET v_log2 =0;
	LET n_imp_hist_6m_corte =0;
	LET n_impagos_consec_corte		= 0;
	LET v_etapa_cred_corte     ='';
	LET cCodRet1  = '000000';
	LET ptipogrupo = '';
	LET pevalua_cc = '';
	LET v_cat_cuenta =0;
	
	LET v_indicador_cat     	 =1;
	
	LET v_catcontrato = 0;
	LET v_pagoexigepsi = 0;
	LET v_saldopmsi=0;
	LET v_saldopmsi_total = 0;					   
	LET v_cod_ret_otro ='00000';
	LET v_periodo_anterior=date(1);
	LET v_dias_periodo_tc=0;
	LET v_sdo_acum_mes =0;
	LET v_sdo_acum_int =0;
	LET v_saldo_rev =0;
    LET v_interes_rev =0;
	LET v_meses =0;
	LET sum_capvig1=0;
	LET sum_capvig2=0;
	LET v_saldopci =0;
	LET v_saldopci_total =0;
	LET v_interesespci =0;
	LET v_dia_corte_credisol =0;
	LET v_tasa_fija=0;
	LET v_relacion=0;
	LET v_cte_relevante  		 =0;
	LET d_pago_nogint_inicio =0;
	LET d_sdo_corte_msi_t=0;					 
	LET v_sdo_corte_msi =0;
	LET v_sdo_corte_msi_1 =0;
	LET v_sdo_corte_msi_2 =0;
	LET v_sdo_corte_msi_3 =0;
	LET v_sdo_corte_msi_4 =0;
	LET v_saldo_cierre_msi =0;
	LET v_saldo_cierre_msi_tmp = 0;
	LET v_sdo_corte_msi_1_tmp = 0;
	LET v_sdo_corte_msi_2_tmp = 0;
	LET v_sdo_corte_msi_3_tmp = 0;
	LET v_sdo_corte_msi_4_tmp = 0;												   
	LET v_saldo_diferido_msi=0;

	LET v_num_cta_msi='';
	LET v_num_cta_msi_tmp = '';
	LET v_num_producto_mc = '';
	LET v_Promedio_MSI_contratados=0;
	LET v_Promedio_MSI_plazo=0;
	LET v_Promedio_MSI_meses=0;
	LET v_Promedio_MSI_amort=0;
	LET v_Saldo_prom_MSI=0;
	LET v_Saldo_prom_MSI_a=0;
	LET v_saldopmsi_total=0;
	LET v_MSI_hist=0;
	LET v_MSI_act=0;
	LET v_Promedio_MSI_contratados_a=0;
	LET v_MSI_amort_plazo=0;
	LET v_MSI_amort_pagados=0;
	LET v_MSI_amort_a=0;
	LET v_MSI_amort=0;
	LET v_MSI_amort_count=0;								 
	
	LET v_verificacion_num_anios = 0; --nuevo
	
	
	--Requerimiento de septiembre
	LET v_impago0 = 0;
	LET v_impago1 = 0;
	LET v_impago2 = 0;
	LET v_impago3 = 0;
	LET v_pago_cierre = 0;
	LET v_pago_cierre_1 = 0;	
	LET v_pago_cierre_2 = 0;	
	LET v_pago_cierre_3 = 0;	
	LET dt_corte_cierre = date(1);
	LET dt_cierre_prod_pago_cierre_1 = date(1);
	LET dt_cierre_prod_pago_cierre_2 = date(1);
	LET dt_cierre_prod_pago_cierre_3 = date(1);
	LET dt_ini_prod_pago_cierre_1 = date(1);
	LET dt_ini_prod_pago_cierre_2 = date(1);
   
			
	LET v_impago0_corte = 0;
	LET v_impago1_corte = 0;
	LET v_impago2_corte = 0;
	LET v_impago3_corte = 0;
	--Leer archivo
	
	LET pRutaArchivo = "/resplogifx/archivoscartera/";
	LET pNombreArchivo = '';
	LET sqlArchivoLeer = '';
	LET contador = 0;
	LET mes ='';
	LET anio ='';
	LET comandoNombre = '';

BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
	IF val_t1 = 1 THEN
	  drop table univ_ctas_calif;
	END IF;
	IF val_t2 = 1 THEN
	  drop table movs_pagos;
	END IF;
	IF val_t3 = 1 THEN	  
	  drop table movs_comis;
	END IF;
	  LET vcodret=  iSqlErr;
	  LET cMensajeRet2 = '';
	IF (val_trans_Commit = -1) THEN
		rollback work;
	END IF;  
	  RETURN vcodret,c_num_credito,cMensajeRet2;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOS/Optimizacion_junio2023/sp_geninsumos_calif_parte"||pEjecucion||".out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
  FROM sysmaster:sysshmvals;

SELECT  pri_dia_mes - 1 units day
INTO  dt_cierre_proc
FROM sd_fechas
WHERE empresa='001';

--LET dt_cierre_proc = mdy('09','30','2023');
LET dt_ini_per_proc = mdy(month(dt_cierre_proc),'01',year(dt_cierre_proc));

--Reproceso
--LET dt_ini_per_proc = mdy('02','01','2019');
--LET dt_cierre_proc = mdy('02','28','2019');
--Reproceso


IF pEjecucion = 1 THEN

	
	LET mes = month(dt_cierre_proc- 1 units month);
	IF LEN(mes) == 1 THEN
		LET mes = TRIM("0"||mes);
	END IF;
	
	LET anio = Year(dt_cierre_proc);
	LET pNombreArchivo = "Insumos_Calif_tdc_lectura_"||TRIM(mes)||TRIM(anio)||".unl";
	
	--LET comandoNombre = "/usr/bin/ if [ -f "||TRIM(pRutaArchivo)||TRIM(pNombreArchivo)" ] THEN /usr/bin/rm -rf "||TRIM(pRutaArchivo)||TRIM(pNombreArchivo)||" fi";
	LET comandoNombre = "/usr/bin/rm -rf "||TRIM(pRutaArchivo)||TRIM(pNombreArchivo);
		SYSTEM TRIM(comandoNombre);
		
	LET pNombreArchivo = "Insumos_Calif_tdc_lectura_"||TRIM(mes)||TRIM(anio)||".unl.gz";	
	LET comandoNombre = "/usr/bin/gzip -dk "||TRIM(pRutaArchivo)||TRIM(pNombreArchivo);
		SYSTEM TRIM(comandoNombre);

	LET pNombreArchivo = "Insumos_Calif_tdc_lectura_"||TRIM(mes)||TRIM(anio)||".unl";

		
		
	DROP TABLE IF EXISTS tempdatosarchivo;
	CREATE TABLE bdicred:'informix'.tempdatosarchivo(
							num_credito CHAR(20),
							catcontrato DECIMAL (18,2),
							relacion SMALLINT,
							gastos_originacion DECIMAL(18,2),
							facturacion VARCHAR(9),							
							fecha_reestructura DATE,
							numero_cuenta_det CHAR(20),
							pagoexigepsi DECIMAL(18,2),
							comtardio DECIMAL(18,2),
							tipo_producto VARCHAR(40),
							pago_realizado DECIMAL(18,2),
							pago_realizado1 DECIMAL(18,2),
							pago_realizado2 DECIMAL(18,2),
							pago_cierre DECIMAL(18,2),
							pago_cierre1 DECIMAL(18,2),
							pago_cierre2 DECIMAL(18,2),
							
							pago_minimo DECIMAL (18,2),
							monto_exigido DECIMAL (18,2),
							monto_exigido1 DECIMAL (18,2),
							monto_exigido2 DECIMAL (18,2),
							saldo_corte1 DECIMAL(18,2),
							saldo_corte2 DECIMAL(18,2),
							
							saldo_corte_credisol1 DECIMAL(18,2),
							saldo_corte_credisol2 DECIMAL(18,2),
							saldo_corte_credisol3 DECIMAL(18,2),

							pago_sostenido SMALLINT,
							reestructura SMALLINT,
							
							impago0_corte SMALLINT,
							impago1_corte SMALLINT,
							impago2_corte SMALLINT,
							impago0 SMALLINT,
							impago1 SMALLINT,
							impago2 SMALLINT

							
	);

	CREATE INDEX "informix".idx_tempDatos ON bdicred:"informix".tempdatosarchivo(num_credito);
	update statistics medium for table bdicred:"informix".tempdatosarchivo;

	LET sqlArchivoLeer = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; LOAD FROM "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo); 			--/RESPALDOS/PruebasIFSR/insumos_junio/archivo_tdc_prueba.txt" ;
	LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||" INSERT INTO bdicred:tempdatosarchivo(num_credito,catcontrato,relacion,"; 
	LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||"gastos_originacion,facturacion,";
	LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||"fecha_reestructura,numero_cuenta_det,pagoexigepsi,comtardio,tipo_producto,pago_realizado,";
	LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||"pago_realizado1,pago_realizado2,pago_cierre,pago_cierre1,pago_cierre2,pago_minimo,monto_exigido,monto_exigido1,monto_exigido2,";
	LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||"saldo_corte1,saldo_corte2,saldo_corte_credisol1,saldo_corte_credisol2,saldo_corte_credisol3,";
	LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||"pago_sostenido,reestructura,";
	LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||"impago0_corte,impago1_corte,impago2_corte,impago0,impago1,impago2)'";
	LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||" | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1";

		
	--COMMIT WORK;
	SYSTEM TRIM(sqlArchivoLeer);
	--BEGIN WORK;
END IF;



SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO cred_ini,cred_fin
FROM sd_param  WHERE cod_param = (930 + pEjecucion)::CHAR(3);


--Crea universo a procesar
select 
a.num_credito, a.numcte,
a.fecha_apertura,
a.id_unidad_prod  cod_bloqueo, 
a.status_cred status_mes_reporte, a.sucursal, 
a.num_producto,
t.catcontrato,t.relacion,
t.gastos_originacion,t.facturacion,
t.fecha_reestructura,t.numero_cuenta_det,t.pagoexigepsi,t.comtardio,
t.tipo_producto,
t.pago_realizado,t.pago_realizado1,t.pago_realizado2,t.pago_cierre,t.pago_cierre1,t.pago_cierre2,
t.pago_minimo,t.monto_exigido,t.monto_exigido1,t.monto_exigido2,
t.saldo_corte1,t.saldo_corte2,
t.saldo_corte_credisol1,t.saldo_corte_credisol2,t.saldo_corte_credisol3,
t.pago_sostenido,t.reestructura,
t.impago0_corte,t.impago1_corte,t.impago2_corte,
t.impago0,t.impago1,t.impago2
from sd_maecredcont a
LEFT JOIN tempdatosarchivo t ON (t.num_credito  > cred_ini AND t.num_credito <= cred_fin AND a.num_credito = t.num_credito)
--LEFT JOIN tempdatosarchivo t ON (a.num_credito = t.num_credito) --pruebas
where a.fecha = dt_cierre_proc  AND a.empresa = '001'
AND a.num_credito  > cred_ini AND a.num_credito <= cred_fin     --rango ctas /se comenta para pruebas
--and a.num_credito in  --('600019009338')
and a.num_producto in ('6001','6600','8500')
and a.num_credito not in (select num_credito from sd_insumos_calif where fecha_cierre = dt_cierre_proc)
--and a.num_credito in('600001276648','600001278362','600001280970','600001283867')      
into temp univ_ctas_calif with no log;



LET val_t1 = 1;


CREATE INDEX "informix".idx_univcalif ON univ_ctas_calif(num_credito);


update statistics medium for table univ_ctas_calif;

--MOVIMIENTOS QUE ESTAN EN EL REPORTE

--Extrae base de movimientos  del ultimo cuatrimestre
select num_credito,fecha_mov,codigo_fun,codigo_ref, monto
from sd_movhis
where empresa = '001'
--and fecha_mov >= (dt_ini_per_proc - 4 units month) --mdy ('02','01','2018') -- actual
and fecha_mov >= (dt_ini_per_proc - 1 units month) --mdy ('02','01','2018')
and fecha_mov <= dt_cierre_proc        --mdy ('11','30','2018')
and num_credito in (select num_Credito from univ_ctas_calif)--actual
--and num_credito in (select num_Credito from tempdatosoyp)--cambio
and codigo_fun in (select cod_fun from sd_conceptospagomanual)
--and codigo_ref in (7,10,901,8,5,1)  --,6640) iva_interes_vencido
and codigo_ref in (7,8,5,923,925,926,907,908,909,10,901,1,2,6616,6617,6652,6709) 
and reversado = 'N'
into temp movs_pagos with no log;
LET val_t2 = 1;

CREATE INDEX "informix".idx_movs_pagos ON movs_pagos(fecha_mov,num_credito);


update statistics medium for table movs_pagos;

--MOVIMIENTOS QUE NO ESTAN EN EL REPORTE
--Extrae base de movimientos  del ultimo cuatrimestre
select num_credito,fecha_mov,codigo_fun,codigo_ref, reversado, monto
from sd_movhis
where empresa = '001'
and fecha_mov >= (dt_ini_per_proc - 4 units month) --mdy ('02','01','2018') -- actual
--and fecha_mov >= (dt_ini_per_proc - 1 units month) --mdy ('02','01','2018') -- cambio viernes
and fecha_mov <= dt_cierre_proc        --mdy ('11','30','2018')
and num_credito in (select num_Credito from univ_ctas_calif)--actual
and num_credito not in (select num_Credito from tempdatosarchivo)--cambio
and codigo_fun in (select cod_fun from sd_conceptospagomanual)
--and codigo_ref in (7,10,901,8,5,1)  --,6640) iva_interes_vencido
and codigo_ref in (7,8,5,923,925,926,907,908,909,10,901,1,2,6616,6617,6652,6709) 
and reversado = 'N'
into temp movs_pagos2 with no log;
LET val_t2 = 1;
begin;
CREATE INDEX idx_movs_pagos2 ON movs_pagos2(fecha_mov,num_credito) ONLINE;
commit;

update statistics medium for table movs_pagos2;
------

select num_credito,fecha_mov,codigo_fun,codigo_ref, monto
from sd_movhis
where empresa = '001'
and fecha_mov >= dt_ini_per_proc --mdy ('11','01','2018')
and fecha_mov <= dt_cierre_proc        --mdy ('11','30','2018')
and num_credito in (select num_Credito from univ_ctas_calif)
and codigo_fun in ('339','002','018','033')
--and codigo_ref in (96,50,51,60,2,6218,6219,6220,6221)
and codigo_ref in (96,50,51,60,2,6218,6219,6220,6221,902,950,904,951)
and reversado = 'N'
into temp movs_comis with no log;
LET val_t3 = 1;

CREATE INDEX "informix".idx_movs_comis ON movs_comis(num_credito,codigo_fun,codigo_ref);


update statistics medium for table movs_comis;
--Datos Fijos
SELECT MAX(fecha_info) 
INTO dt_ultcons_varcc
FROM bdiburo:br_variables_cc;

--LET c_facturacion 	 = 'Mensual';
--LET dt_fec_reest  	 = DATE(1);
LET d_intvenc_bal 	 = 0;
LET d_intvenc_ord	 = 0;
LET n_meses_pagosost = 0;
LET n_pago_int_vig   = 0;
--LET n_pago_sost 	 = 0;
--LET n_resc 			 = 0;

    FOREACH WITH HOLD
		SELECT  num_credito, numcte, num_producto, 
				sucursal,catcontrato,relacion,
				gastos_originacion,facturacion,
				fecha_apertura,
				fecha_reestructura,numero_cuenta_det,pagoexigepsi,comtardio,
				cod_bloqueo,status_mes_reporte,
				tipo_producto,
				pago_realizado,pago_realizado1,pago_realizado2,
				pago_cierre,pago_cierre1,pago_cierre2,
				pago_minimo,monto_exigido,monto_exigido1,monto_exigido2,					
				saldo_corte1,saldo_corte2,
				saldo_corte_credisol1,saldo_corte_credisol2,saldo_corte_credisol3,		
				pago_sostenido,reestructura,
				impago0_corte,impago1_corte,impago2_corte,
				impago0,impago1,impago2			
          INTO  c_num_credito, c_numcte,c_producto,
				c_sucursal,v_catcontrato,v_relacion,
				v_gastos_originacion,c_facturacion,
				dt_apertura,
				dt_fec_reest,v_numero_cuenta_det,v_pagoexigepsi,v_comtardio,
				n_cod_bloqueo,c_status_mes_reporte,
				c_nombre_prod,
				d_pago_realizado_1,d_pago_realizado_2,d_pago_realizado_3,
				v_pago_cierre_1,v_pago_cierre_2,v_pago_cierre_3,
				d_monto_exigido,d_monto_exigido1,d_monto_exigido2,d_monto_exigido3,
				d_saldo_corte2,d_saldo_corte3,
				d_sdo_corte_cred2,d_sdo_corte_cred3,d_sdo_corte_cred4,
				n_pago_sost,n_resc,
				v_impago1_corte,v_impago2_corte,v_impago3_corte,
				v_impago1,v_impago2,v_impago3			
        FROM  univ_ctas_calif
		
	
	LET v_interesespci=0;	
		IF (val_trans_Commit = 0) THEN
            BEGIN WORK;
            LET contador_commit = 0;
            LET val_trans_Commit = -1;
        END IF; 
		
		/*select NVL(num_tarjeta,'') INTO v_numtarjeta
		from sd_tarjeta
		where num_credito=c_num_credito
		and status_tar='A'
		and tipo_tarjeta='T';*/
		
		IF c_nombre_prod is null or c_nombre_prod = '' THEN
			
			LET c_facturacion 	 = 'Mensual';
			LET dt_fec_reest  	 = DATE(1);
			LET v_pagoexigepsi = 0;
			LET n_pago_sost 	 = 0;
			LET n_resc 			 = 0;
			LET v_comtardio=0;

				

				select nvl(b.monto,0) Into v_gastos_originacion from sd_definicion a
				inner join sd_tpcomis b
				on a.cod_comision_apertura=b.cod_comis
				where num_producto=c_producto;
				
									

				SELECT trim(nombre_prod)  INTO c_nombre_prod
				FROM sd_definicion 
				WHERE num_producto = c_producto;	  
				
			
		END IF;
		
		
			
			select NVL(num_tarjeta,'') INTO v_numtarjeta
			from sd_tarjeta
			where num_credito = c_num_credito
			AND SECUENCIA IN (SELECT MAX(secuencia) FROM sd_tarjeta where num_credito=c_num_credito AND tipo_tarjeta='T'); 
		
		
		
			select NVL(a.rfc,''), NVL(c.curp,'')
			INTO v_rfc, v_curp
			from bdinteg:si_cliente a
			INNER join bdinteg:si_ctepf c
			on a.numcte=c.numcte
			where a.numcte=c_numcte;
		
		
		
			SELECT NVL(cod_postal,'') INTO v_cod_postal
			FROM bdinteg:si_direcciones_actual 
			where numcte=c_numcte		
			and secuencia in(select max(secuencia) from bdinteg:si_direcciones_actual where numcte=c_numcte	);
		
		
		/*IF nvl(v_cod_postal,'')='' OR v_cod_postal= '00000' THEN
			LET v_cod_postal= '20000';
		END IF
	
		IF length(v_rfc)<13 THEN
			LET v_rfc= RPAD(TRIM(v_rfc),13,"0");
		END IF;
	
		IF length(v_curp)<18 THEN
			LET v_curp=RPAD(TRIM(v_curp),18,"X");
		END IF;	
		
		IF v_curp LIKE('%#%') THEN 
			LET v_curp= REPLACE(v_curp, '#', 'X');
		END IF;
		
		IF v_curp LIKE('%|%') THEN 
			LET v_curp= REPLACE(v_curp, '|', 'X');
		END IF;
		
		IF v_curp LIKE('%.%') THEN 
			LET v_curp= REPLACE(v_curp, '.', 'X');
		END IF;
		
		IF trim(v_curp) LIKE('% %') THEN 
			LET v_curp= REPLACE(trim(v_curp), ' ', 'X');
		END IF;
		
		IF v_curp LIKE('%/%') THEN 
			LET v_curp= REPLACE(v_curp, '/', 'X');
		END IF;
		
		IF v_curp LIKE('%*%') THEN 
			LET v_curp= REPLACE(v_curp, '*', 'X');
		END IF;
		
		IF v_curp LIKE('%+%') THEN 
			LET v_curp= REPLACE(v_curp, '+', 'X');
		END IF;
		
		IF v_curp LIKE('%-%') THEN 
			LET v_curp= REPLACE(v_curp, '-', 'X');
		END IF;
		
		IF v_curp LIKE('%$%') THEN 
			LET v_curp= REPLACE(v_curp, '$', 'X');
		END IF;
		
		IF v_curp LIKE('%"%') THEN 
			LET v_curp= REPLACE(v_curp, '"', 'X');
		END IF;
	*/
	
		IF v_catcontrato is null or v_catcontrato = '' THEN --optimizacion
			select cat into v_catcontrato
			from bdisolic:ss_revision_determinacion 
			where num_solicitud=c_num_credito;
			
			IF v_catcontrato IS NULL THEN
				select cat_caratula into v_catcontrato
				from bdicred:sd_definicion 
				where num_producto=c_producto;
			END IF;
		END IF;
		


		
		--LET v_pagoexigepsi=0; --optimizacion
		LET v_pagongi=0;
		LET v_pagonginicio=0;
		LET v_comtotal=0;
		--LET v_comtardio=0;
		LET v_saldopmsi=0;
		LET v_comremf =0;
		LET v_comaclara =0;
		
        
		--SALDO_REV, INTERES_REV
		EXECUTE PROCEDURE sp_mes_siguiente(mdy(month(dt_cierre_proc), '20', year(dt_cierre_proc)),-1,DAY(mdy(month(dt_cierre_proc), '20', year(dt_cierre_proc))))
		INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;			
		
		SELECT sdo_cap_insoluto, sdo_no_exig into v_sdo_acum_mes, v_sdo_acum_int
		FROM sd_maesdoshist WHERE num_credito=c_num_credito AND fecha=mdy(month(dt_cierre_proc), '20', year(dt_cierre_proc));
		
		LET v_saldo_rev=v_sdo_acum_mes;		LET v_interes_rev=round((v_sdo_acum_int)/(abs(v_dias_periodo_tc)),2);
		
		IF v_saldo_rev<0 THEN
			LET v_saldo_rev=0;
		END IF;

		
		select	case when (mto_venc_trasp + monto_vencido) <= 0 then 0 else  (mto_venc_trasp + monto_vencido) end capital_ven_exigible, --8
		case when (Monto_financiado - monto_vencido - mto_venc_trasp)  <= 0 then 0 else (Monto_financiado - monto_vencido - mto_venc_trasp) end capital_vig_exigible, --9
		b.sdo_cap_insoluto saldo_cierre,
		(b.monto_vencido + b.mto_venc_trasp  + b.int_tra_no_exig + b.mto_venc_int) saldo_exigible,
		case when (b.sdo_cap_insoluto - b.monto_vencido - b.mto_venc_trasp) <= 0 then 0 else (b.sdo_cap_insoluto - b.monto_vencido - b.mto_venc_trasp) end Saldo_No_Exigible,
		b.monto_otorgado  limite_credito,
		(case when sdo_moratorio< 0 then 0 else  sdo_moratorio end + case when sdo_contab_mora < 0 then 0 else sdo_contab_mora end) moratorios,
		 c.dia_corte,
		b.int_tra_no_exig int_venc_exig_cierre, b.mto_fin_ven_trasp
		INTO d_capital_ven_exigible, d_capital_vig_exigible, d_saldo_cierre, d_saldo_exigible, d_saldo_no_exigible, d_limite_credito,d_moratorios, --dt_ap_revolvente, dt_ap_plazo, 
			n_dia_corte  ,d_int_venc_exig_cierre, v_meses 
		from sd_maesdoscont b 
		inner join sd_maecredanexo c on ( b.empresa = c.empresa and b.num_Credito = c.num_credito)
		where b.fecha= dt_cierre_proc
		and b.empresa ='001' 
		and b.num_Credito =c_num_credito;


		
	LET n_alto					= 0;		--LET c_antecedentes_buro 	= '';
	LET n_antig_cte		 		= 0;	
	LET n_antig_cred			= 0;		LET n_bajo					= 0;		LET n_bkatr					= 0;		
	LET n_bloq					= 0;		LET n_bloq_op				= 0;		LET d_comision_apert		= 0;		
	LET d_comision_disp			= 0;		LET n_consulta_sin_info		= 0;		LET n_mop					= 0;		
	LET dt_ap_cte				= date(1);	
	LET c_gpo_originacion	    = ''; 		
	LET n_gveces_1				= 0;		
	LET n_gveces_2				= 0;		LET n_gveces_3				= 0;		LET n_impagos_consec		= 0;		
	LET n_imp_hist_6m			= 0;		LET n_sin_mov				= 0;		LET d_int_venc_exig_corte	= 0;		
	LET d_int_vig_exig			= 0;		LET d_limite_credito_corte	= 0;		LET d_limite_credito_inicio	= 0;		
	LET d_limite_credito_orig	= 0;		LET n_medio					= 0;		LET n_meses_venc			= 0;		
	--LET d_monto_exigido			= 0;		LET d_monto_exigido1		= 0;		LET d_monto_exigido2		= 0;		
	--LET d_monto_exigido3		= 0;	--optimizacion	
	LET d_monto_pagar_otros		= 0;		LET d_monto_pagar_propio	= 0;
	LET n_moras					= 0;		LET c_nom_cte				= '';			--se comenta por optimizacion 
	LET c_cta_credisol			= '';	
	LET d_pago_capital			= 0;		LET d_pago_int_venc			= 0;		LET d_pago_minimo			= 0;		
	LET d_pago_realizado		= 0;		--LET d_pago_realizado_1		= 0;		LET d_pago_realizado_2		= 0;		
	--LET d_pago_realizado_3		= 0;		
	LET d_porcentaje_pago		= 0;		LET d_porcentaje_uso		= 0;		
	LET d_saldo_cierre_credisol	= 0;		LET d_saldo_corte			= 0;		
	LET d_saldo_corte_credisol	= 0;		
	LET d_saldo_corte1			= 0;		
	--LET d_saldo_corte2			= 0;		LET d_saldo_corte3			= 0;		
	LET n_scoreburo				= 0;		LET n_scoreotor				= 0;		
	LET n_sin_consulta			= 0;		
	LET c_status_corte			= '';		--LET c_nombre_prod			= '';		
	LET dt_ult_pos_disp			= date(1); 	
	LET dt_ult_vnt_disp			= date(1); 	LET dt_ult_atm_disp			= date(1);	LET dt_ult_pago				= date(1); 	
	LET dt_ult_mov				= date(1);	LET n_ult_mov 				= 0;		LET d_monto_vencido_periodo	= 0; 		
	LET d_mto_venc_trasp_periodo = 0;		LET d_pago_minimo_rev		= 0;		LET d_pago_minimo_plazo		= 0;		
	LET d_pago_cap_vig 		 	= 0;		LET d_pago_cap_venc			= 0;		LET cflg_cons_cc			= '';		
	LET c_nombre1				= '';		LET c_nombre2				='';		LET c_ap_paterno 			= '';		
	LET c_ap_materno    		='';		LET c_evalua_cc				='';		LET cta_plazo				='';
	LET dia_corte_plazo			=0;			LET dt_corte_plazo			= date(1);  LET d_pago_minimo_plazo_a   =0;			
	LET dt_ult_compra			= date(1);	LET  dt_corte = mdy(month(dt_cierre_proc),n_dia_corte,year(dt_cierre_proc));
	LET dt_ini_per_rep			= mdy(month(dt_cierre_proc),(n_dia_corte+1),year(dt_cierre_proc))-1 units month;

    --INICIALIZACION DE CAMPOS ADICIONALES
    LET d_comision_cobranza = 0;
    LET d_comisionexig_cobranza = 0;
    LET d_saldo_corte_t = 0;
    LET d_sdo_corte_cred_t = 0;
    --LET v_numero_cuenta_det = '';
    LET v_meses_primer_crdbco = 0;
    LET v_meses_ult_atr_bk   = 0;
    LET v_veces_monto_bco_sist = 0;
    LET v_intereses_ordinarios = 0;
    LET v_intereses_moratorios = 0; 
    LET v_num_pagos_vencidos =0;
    LET v_tasa_interes = 0;
    LET v_capital_cierre = 0;
	
	--mop, ACT y MORAS		

		--SELECT dias_act, moras_hist_h ---impagos_consec_ch
		SELECT dias_atraso, moras_hist_h
		  INTO n_mop, n_moras
          FROM sd_indicador_cred
         WHERE empresa = '001' 
           AND num_Credito = c_num_credito;	 

		SELECT act INTO n_impagos_consec_corte
		FROM sd_maesdoshist WHERE NUM_CREDITO=c_num_credito 
		and fecha=dt_corte;
		
		SELECT act INTO n_impagos_consec
		FROM sd_maesdoscont WHERE NUM_CREDITO=c_num_credito 
		and fecha=dt_cierre_proc;

	
	--Campo 3 n_antig_cte, dt_ap_cte
	/*	SELECT min(mdy(month(fecha_apertura),day(fecha_apertura),year(fecha_apertura))) INTO dt_ap_cte 
				FROM (SELECT min(fecha_apertura)fecha_apertura
					  FROM sd_maecred WHERE numcte=c_numcte   --Tarjetas
					union all
					  SELECT min(fecha_apertura)fecha_apertura		
					  FROM sd_maecredcrd WHERE numcte=c_numcte AND num_producto <> '6800'  --Prestamos y nomina
					union all
					  SELECT min(fecha_otorga) fecha_apertura
                      FROM sd_linea_prestamo WHERE num_credito in (SELECT num_credito FROM sd_maecredcrd
															       WHERE numcte = c_numcte AND num_producto = '6800'));  --Flexibles*/
		
		--Fec_apertura_revolvente
		SELECT NVL(min(fecha_apertura),mdy('12','31','4000')) INTO dt_ap_revolvente
		FROM sd_maecred WHERE numcte=c_numcte;   
		--Fec_apertura_Prestamos y nomina
		SELECT NVL(min(fecha_apertura),mdy('12','31','4000')) INTO dt_ap_plazo		
		FROM sd_maecredcrd WHERE numcte=c_numcte AND num_producto <> '6800';
		--Fec_apertura_Flexibles
		SELECT NVL(min(fecha_otorga),mdy('12','31','4000'))  INTO dt_ap_flex
        FROM sd_linea_prestamo WHERE num_credito in (SELECT num_credito FROM sd_maecredcrd
		   									        WHERE numcte = c_numcte AND num_producto = '6800');
													
		IF dt_ap_revolvente <= dt_ap_plazo AND dt_ap_revolvente <= dt_ap_flex THEN
			LET dt_ap_cte = dt_ap_revolvente;
		ELIF  dt_ap_plazo <= dt_ap_revolvente AND dt_ap_plazo <= dt_ap_flex THEN
			LET dt_ap_cte = dt_ap_plazo;
		ELIF dt_ap_flex <= dt_ap_revolvente AND dt_ap_flex <= dt_ap_plazo THEN
			LET dt_ap_cte= dt_ap_flex;
		END IF;	
																   
		LET n_antig_cte = (year(dt_corte) - year(dt_ap_cte)) * 12 + (month(dt_corte) - month(dt_ap_cte));		
		--c4
		LET n_antig_cred = (year(dt_corte) - year(dt_apertura)) * 12 + (month(dt_corte) - month(dt_apertura));
	    
		--c6 y 7
		IF  (c_status_mes_reporte = 'BT' OR (c_status_mes_reporte = 'E2' and n_impagos_consec IN (2,3)) OR (c_status_mes_reporte = 'E3' and n_impagos_consec >=4))  OR  n_cod_bloqueo in (3,4,1) THEN
			LET n_bloq = 1;
		ELSE
			LET n_bloq = 0;
		END IF;	
		
		IF n_cod_bloqueo in (3,4,1) THEN
			LET n_bloq_op = 1;
		ELSE
			LET n_bloq_op = 0;
		END IF;	
		
		
		
		--consulta pago minimo fecha actual
		SELECT 
		   --pago_minimo Al corte   Junio--Incluyendo moratorios
			CASE WHEN b.sdo_cap_insoluto > 0 THEN case when b.monto_financiado < 0 then 0 else b.monto_financiado end  + b.int_tra_no_exig + b.mto_venc_int 
						+ (case when b.sdo_contab_mora < 0 then 0 else b.sdo_contab_mora end + case when b.sdo_moratorio< 0 then 0 else  b.sdo_moratorio end )            --Moratorios
						+  round(( case when b.sdo_contab_mora < 0 then 0 else b.sdo_contab_mora end + case when b.sdo_moratorio< 0 then 0 else  b.sdo_moratorio end )*.16,2)   --Iva Moratoriios
				 ELSE 0 END pago_minimo,
				b.monto_vencido monto_vencido_periodo, b.mto_venc_trasp mto_venc_trasp_periodo,b.monto_otorgado limite_credito_corte,
				b.int_tra_no_exig int_venc_exig_corte,
				c.monto_otorgado limite_credito_inicio				 
			INTO  d_pago_minimo,
				  d_monto_vencido_periodo, d_mto_venc_trasp_periodo,d_limite_credito_corte,
				  d_int_venc_exig_corte,
				  d_limite_credito_inicio
		FROM sd_maesdoshist b                                                                                                           --Junio        
		LEFT JOIN sd_maesdoshist c ON (c.fecha = (dt_corte - 1 UNITS MONTH) AND c.empresa = b.empresa AND b.num_Credito = c.num_credito) --Mayo
		LEFT JOIN sd_maesdoshist d ON (d.fecha = (dt_corte - 2 UNITS MONTH) AND d.empresa = b.empresa AND b.num_Credito = d.num_credito) --Abril
		LEFT JOIN sd_maesdoshist e ON (e.fecha = (dt_corte - 3 UNITS MONTH) AND e.empresa = b.empresa AND b.num_Credito = e.num_credito) --Marzo 
		LEFT JOIN sd_maesdoshist f ON (f.fecha = (dt_corte - 4 UNITS MONTH) AND f.empresa = b.empresa AND b.num_Credito = f.num_credito) --Febrero
		WHERE b.fecha = dt_corte AND b.empresa = '001' AND b.num_credito = c_num_credito;

		
		
--Query 2	
	--montos que no esten en el reporte 
		IF d_monto_exigido is null or d_monto_exigido = '' THEN
		
			SELECT 
		   --pago_minimo Al corte   Junio--Incluyendo moratorios
		   /* CASE WHEN b.sdo_cap_insoluto > 0 THEN case when b.monto_financiado < 0 then 0 else b.monto_financiado end  + b.int_tra_no_exig + b.mto_venc_int 
						+ (case when b.sdo_contab_mora < 0 then 0 else b.sdo_contab_mora end + case when b.sdo_moratorio< 0 then 0 else  b.sdo_moratorio end )            --Moratorios
						+  round(( case when b.sdo_contab_mora < 0 then 0 else b.sdo_contab_mora end + case when b.sdo_moratorio< 0 then 0 else  b.sdo_moratorio end )*.16,2)   --Iva Moratoriios
				 ELSE 0 END pago_minimo ,
			b.monto_vencido monto_vencido_periodo, b.mto_venc_trasp mto_venc_trasp_periodo,b.monto_otorgado limite_credito_corte,
			b.int_tra_no_exig int_venc_exig_corte,*/
			--d_monto_exigido (al inicio del periodo)   Mayo  --Incluyendo moratorios
			CASE WHEN c.sdo_cap_insoluto > 0 THEN  case when c.monto_financiado < 0 then 0 else c.monto_financiado end  + c.int_tra_no_exig + c.mto_venc_int 
						+ (case when c.sdo_contab_mora < 0 then 0 else c.sdo_contab_mora end + case when c.sdo_moratorio< 0 then 0 else  c.sdo_moratorio end )            --Moratorios
						+  round((case when c.sdo_contab_mora < 0 then 0 else c.sdo_contab_mora end + case when c.sdo_moratorio< 0 then 0 else  c.sdo_moratorio end)*.16,2)   --Iva Moratoriios
						ELSE 0 END monto_exigido, 
			--c.monto_otorgado limite_credito_inicio,
			--d_monto_exigido-1  Abril --Incluyendo moratorios
			CASE WHEN d.sdo_cap_insoluto > 0 THEN  case when d.monto_financiado < 0 then 0 else d.monto_financiado end  + d.int_tra_no_exig + d.mto_venc_int 
						+ (case when d.sdo_contab_mora < 0 then 0 else d.sdo_contab_mora end + case when d.sdo_moratorio< 0 then 0 else  d.sdo_moratorio end)            --Moratorios
						+  round((case when d.sdo_contab_mora < 0 then 0 else d.sdo_contab_mora end + case when d.sdo_moratorio< 0 then 0 else  d.sdo_moratorio end)*.16,2)   --Iva Moratoriios
				 ELSE 0 END monto_exigido1,
		   --d_monto_exigido-2 Marzo  --Incluyendo moratorios      
		   --d_monto_exigido-2 Marzo  --Incluyendo moratorios      
			 CASE WHEN e.sdo_cap_insoluto > 0 THEN  case when e.monto_financiado < 0 then 0 else e.monto_financiado end  + e.int_tra_no_exig + e.mto_venc_int 
						+ (case when e.sdo_contab_mora < 0 then 0 else e.sdo_contab_mora end + case when e.sdo_moratorio< 0 then 0 else  e.sdo_moratorio end)            --Moratorios
						+  round((case when e.sdo_contab_mora < 0 then 0 else e.sdo_contab_mora end + case when e.sdo_moratorio< 0 then 0 else  e.sdo_moratorio end)*.16,2)   --Iva Moratoriios
				  ELSE 0 END monto_exigido2,
			--d_monto_exigido-3 Febrero --Incluyendo moratorios
			CASE WHEN f.sdo_cap_insoluto > 0 THEN  case when f.monto_financiado < 0 then 0 else f.monto_financiado end  + f.int_tra_no_exig + f.mto_venc_int 
						+ (case when f.sdo_contab_mora < 0 then 0 else f.sdo_contab_mora end + case when f.sdo_moratorio< 0 then 0 else  f.sdo_moratorio end)            --Moratorios
						+  round((case when f.sdo_contab_mora < 0 then 0 else f.sdo_contab_mora end + case when f.sdo_moratorio< 0 then 0 else  f.sdo_moratorio end)*.16,2)   --Iva Moratoriios
				 ELSE 0 END monto_exigido3 
			 INTO  --d_pago_minimo,
				  --  d_monto_vencido_periodo, d_mto_venc_trasp_periodo,d_limite_credito_corte,
					--d_int_venc_exig_corte,
					d_monto_exigido,
					--d_limite_credito_inicio,
					d_monto_exigido1,-- d_saldo_corte1,
					d_monto_exigido2, --d_saldo_corte2,
					d_monto_exigido3--, d_saldo_corte3
			FROM sd_maesdoshist b                                                                                                           --Junio        
			LEFT JOIN sd_maesdoshist c ON (c.fecha = (dt_corte - 1 UNITS MONTH) AND c.empresa = b.empresa AND b.num_Credito = c.num_credito) --Mayo
			LEFT JOIN sd_maesdoshist d ON (d.fecha = (dt_corte - 2 UNITS MONTH) AND d.empresa = b.empresa AND b.num_Credito = d.num_credito) --Abril
			LEFT JOIN sd_maesdoshist e ON (e.fecha = (dt_corte - 3 UNITS MONTH) AND e.empresa = b.empresa AND b.num_Credito = e.num_credito) --Marzo 
			LEFT JOIN sd_maesdoshist f ON (f.fecha = (dt_corte - 4 UNITS MONTH) AND f.empresa = b.empresa AND b.num_Credito = f.num_credito) --Febrero
			WHERE b.fecha = dt_corte AND b.empresa = '001' AND b.num_credito = c_num_credito;

		
		END IF;
		
    
		
		
	/*
		IF (d_monto_vencido_periodo + d_mto_venc_trasp_periodo)  = 0 THEN 
			LET c_status_corte = 'AA';
		ELIF d_monto_vencido_periodo > 0  THEN
			LET c_status_corte = 'BA';
		ELIF  d_mto_venc_trasp_periodo > 0 THEN
			LET c_status_corte = 'BT';
		END IF;
		IF c_status_corte='' THEN
			LET c_status_corte= c_status_mes_reporte;
		END IF;
		*/
		
		Select status_cred_20 INTO c_status_corte
		FROM sd_sdodiario
		WHERE num_credito=c_num_credito
		and fecha = mdy(month(dt_cierre_proc),'01',year(dt_cierre_proc));
		
		
		
		--Obtiene saldo total al corte 
		LET bandera_sdos = 0; --CJAC CAMPO ADICIONAL SALDO_CORTE_T MISMA FORMULA QUE vsaldo_corte PERO CON FECHA DEL MES DE PROCESO se cambia ciclo para traer el saldo al corte del mes en proceso
		
		WHILE (bandera_sdos <= 4) LOOP
		
			IF bandera_sdos < 3 or (bandera_sdos >= 3 AND (d_saldo_corte2 is null or d_saldo_corte2 = '')) THEN									 
				LET v_fec_sdo = dt_corte - bandera_sdos UNITS MONTH;
				
				SELECT NVL((CASE WHEN (NVL(sdo_cap_insoluto,0) < 0) THEN
									DECODE( 2,1, NVL(sdo_cap_insoluto,0),0)  
							ELSE NVL(sdo_cap_insoluto,0) +  NVL(ROUND((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2),0)  +			
								CASE WHEN NVL(int_tra_no_exig,0) > 0 THEN
									NVL(int_tra_no_exig,0) - NVL((SELECT interes_debe FROM sd_amortiza_credito 
																  WHERE a.num_credito = num_credito AND b.fecha = fecha_cuota),0) 
								ELSE 0
								END +
							(SELECT NVL (campo_trabajo1 ,0)	FROM sd_amortiza_credito 
								WHERE a.empresa = empresa 
								AND a.num_credito = num_credito 
								AND b.fecha = fecha_cuota)END),0) SaldoTotal				  
				INTO v_saldo_corte				--Mayo
				FROM sd_maecred a 				
				JOIN sd_maesdoshist b ON ( a.empresa = b.empresa and b.fecha = v_fec_sdo
					and a.num_credito = b.num_credito) 				 
				JOIN bdinteg:si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
				WHERE a.empresa = '001'
				AND a.num_credito = c_num_credito;	
				SELECT tasa_interes INTO v_tasa_interes
				FROM sd_maecred WHERE num_credito = c_num_credito;	
				/*select tasa_interes INTO v_tasa_interes
				from sd_maecredcont where num_credito=c_num_credito and fecha in(select min(fecha) from sd_maecredcont where num_credito=c_num_credito)*/


				SELECT  sum(saldo_pendiente)  
				INTO v_saldo_diferido
				--FROM sd_detalle_dif_edocta  --IPCB Cambio para liberacion y generacion de Dic 2018// tabla creada oltp sd_sdo_diferido  
				FROM sd_info_edocta_calif  
				WHERE fecha_emision = v_fec_sdo 
				and num_credito = c_num_credito;
			
				IF bandera_sdos = 0 THEN   --Junio
					IF v_saldo_corte < 0 OR v_saldo_corte is null THEN 
						LET d_saldo_corte_t =0;
					ELSE
						LET d_saldo_corte_t = v_saldo_corte;
					END IF;
					
					IF v_saldo_diferido < 0 OR v_saldo_diferido IS NULL THEN 
						LET d_sdo_corte_cred_t = 0;
					ELSE
						LET d_sdo_corte_cred_t = v_saldo_diferido;
					END IF;	
					
					--LET d_saldo_corte_t = d_saldo_corte_t - d_sdo_corte_cred_t;
					
				ELIF bandera_sdos = 1 THEN   --Mayo
					IF v_saldo_corte < 0 OR v_saldo_corte is null THEN 
						LET d_saldo_corte =0;
					ELSE
						LET d_saldo_corte = v_saldo_corte;
					END IF;
					
					IF v_saldo_diferido < 0 OR v_saldo_diferido IS NULL THEN 
						LET d_sdo_corte_cred1 = 0;
					ELSE
						LET d_sdo_corte_cred1 = v_saldo_diferido;
					END IF;	
				ELIF bandera_sdos = 2 THEN --Abril
					IF v_saldo_corte < 0 OR v_saldo_corte is null THEN 
						LET d_saldo_corte1 =0;
					ELSE
						LET d_saldo_corte1 = v_saldo_corte;
					END IF;				
					IF v_saldo_diferido < 0 OR v_saldo_diferido IS NULL THEN 
						LET d_sdo_corte_cred2 = 0;
					ELSE
						LET d_sdo_corte_cred2 = v_saldo_diferido;	
					END IF;					
				ELIF bandera_sdos = 3 THEN --Marzo 
					IF v_saldo_corte < 0 OR v_saldo_corte is null THEN 
						LET d_saldo_corte2 =0;
					ELSE
						LET d_saldo_corte2 = v_saldo_corte;
					END IF;
					
					IF v_saldo_diferido < 0 OR v_saldo_diferido IS NULL THEN 
						LET d_sdo_corte_cred3 = 0;
					ELSE
						LET d_sdo_corte_cred3 = v_saldo_diferido;	
					END IF;					
				ELIF bandera_sdos = 4 THEN	--Febrero
					IF v_saldo_corte < 0 OR v_saldo_corte is null THEN 
						LET d_saldo_corte3 =0;
					ELSE
						LET d_saldo_corte3 = v_saldo_corte;	
					END IF;
					
					IF v_saldo_diferido < 0 OR v_saldo_diferido IS NULL THEN 
						LET d_sdo_corte_cred4 = 0;
					ELSE
						LET d_sdo_corte_cred4 = v_saldo_diferido;
					END IF;					
				END IF;
				
			END IF;
			LET bandera_sdos = (bandera_sdos+1);	
		END LOOP;
		
--Query  3	

		--IF n_scoreotor is null or n_scoreotor = '' THEN --optimizacion
			IF EXISTS (SELECT * FROM bdisolic:ss_Revision_determinacion WHERE num_solicitud = c_num_credito) THEN
				SELECT evalua_cc, grupo, bs_score, score_prop, situacion_pago
				INTO c_evalua_cc,c_gpo_originacion,n_scoreburo,n_scoreotor,v_eficiencia 
				FROM bdisolic:ss_Revision_determinacion 
				WHERE num_solicitud = c_num_credito;
				IF n_scoreotor IS NULL THEN
					SELECT a.evalua_cc,a.grupo,b.evaluacion,c.evaluacion, a.situacion_pago
					INTO c_evalua_cc,c_gpo_originacion,n_scoreburo,n_scoreotor,v_eficiencia 
					FROM bdisolic:ss_resum_scor_fin  a LEFT JOIN bdisolic:ss_resumen_scoring b
					 ON a.num_solicitud = b.num_solicitud AND b.seccion = 1
					LEFT JOIN bdisolic:ss_resumen_scoring c
					 ON a.num_solicitud = c.num_solicitud AND c.seccion = 2
					WHERE a.num_solicitud = c_num_credito; 
				END IF
			ELSE			
				SELECT a.evalua_cc,a.grupo,b.evaluacion,c.evaluacion, a.situacion_pago
				INTO c_evalua_cc,c_gpo_originacion,n_scoreburo,n_scoreotor,v_eficiencia 
				FROM bdisolic:ss_resum_scor_fin  a LEFT JOIN bdisolic:ss_resumen_scoring b
				 ON a.num_solicitud = b.num_solicitud AND b.seccion = 1
				LEFT JOIN bdisolic:ss_resumen_scoring c
				 ON a.num_solicitud = c.num_solicitud AND c.seccion = 2
				WHERE a.num_solicitud = c_num_credito; 			
			END IF;
			
			IF NVL(c_gpo_originacion,'')='' OR  c_gpo_originacion=' ' THEN 
				EXECUTE PROCEDURE bdisolic:"informix".sp_obtienegrupo_cons (c_num_credito) INTO cCodRet1,ptipogrupo,pevalua_cc;
				IF cCodRet1='000000' THEN
					LET c_gpo_originacion=ptipogrupo;
				END IF;
			END IF;	
			
			
			--IF c_antecedentes_buro is null or c_antecedentes_buro = '' THEN --optimizacion
			IF c_evalua_cc = '0' THEN
				LET c_antecedentes_buro = 'Buen';
			ELIF c_evalua_cc = 'X' OR  c_evalua_cc is null THEN	
				LET c_antecedentes_buro = '';
			ELSE  --ELIF c_evalua_cc >= '1' THEN
				LET c_antecedentes_buro = 'Mal';	
			END IF;	
			--END IF;
			
			
			IF c_evalua_cc='X' THEN
                LET v_modelo_score='NO HIT';
            ELIF c_evalua_cc in('0','1','2','3','4') THEN
                LET v_modelo_score='HIT';
            END IF;
			
		--END IF; --optimizacion
		
		
	



		   --Reproceso de Junio // se cambia para que apunte a la sd_indicador_cred_hist de fin de mes 
	  
		/*   SELECT dias_atraso,impagos_consec_h, moras_hist_h
		    INTO n_mop,n_impagos_consec, n_moras
			FROM sd_indicador_cred_hist 
			WHERE empresa = '001' AND fecha= dt_cierre_proc AND num_Credito = c_num_credito;
  
		   --Reproceso de Junio*/
		   IF  n_mop IS NULL THEN
				LET n_mop = 0;
				LET n_meses_venc = 0;
			ELSE
				LET n_meses_venc =  ROUND(n_mop /30.4,0);
		   END IF;
				   
--Validar cuando son buenos y malos	
		/*IF c_evalua_cc = '0' THEN
			LET c_antecedentes_buro ='0';
		ELIF c_evalua_cc = 'X' OR  c_evalua_cc is null THEN	
			LET c_antecedentes_buro = '';
		ELSE  --ELIF c_evalua_cc >= '1' THEN
			LET c_antecedentes_buro = 'X';	
		END IF;*/

		/*LET c_antecedentes_buro = c_evalua_cc;
		IF c_evalua_cc >= '1' OR  c_evalua_cc is null THEN
			LET c_antecedentes_buro = 'X';
		END IF;*/
		
		
--Query 4
        SELECT trim(num_credito),meses_desde_primer_cred_banco,BKATR,gveces,monto_pagar_otros,monto_pagar_propios
         INTO  cflg_cons_cc,v_meses_primer_crdbco,n_bkatr,c_gveces,d_monto_pagar_otros,d_monto_pagar_propio
         FROM bdiburo:br_variables_cc
         WHERE fecha_info = dt_ultcons_varcc 
           AND num_Credito = c_num_credito;  
 
           LET v_numero_cuenta_det = cflg_cons_cc;
           LET v_meses_ult_atr_bk   = n_bkatr;
           LET v_veces_monto_bco_sist =c_gveces;
		   
			IF cflg_cons_cc IS NULL THEN
				LET n_sin_consulta = 1;
				LET n_consulta_sin_info = 0;
		  	ELSE
				IF n_bkatr IS NULL OR c_gveces  IS NULL OR d_monto_pagar_otros IS NULL OR d_monto_pagar_propio IS NULL THEN
					LET n_consulta_sin_info = 1;
					LET n_sin_consulta = 0;
				ELSE
					LET n_consulta_sin_info = 0;
					LET n_sin_consulta = 0;			
				END IF;
			END IF;

			IF 	n_bkatr IS NOT NULL  THEN
				LET n_bkatr = n_bkatr;
			ELSE 
				IF n_consulta_sin_info = 1 THEN  --Consulta sin informacion
					IF c_status_mes_reporte = 'AA' OR  (c_status_mes_reporte = 'E1' AND n_impagos_consec=0)  THEN
						LET n_bkatr = 13;
					ELSE	
						LET n_bkatr = 0;
					END IF;
				ELSE  --Sin consulta
					IF n_impagos_consec > 0 THEN
						LET n_bkatr = 0;
					ELSE
						LET n_bkatr = 10;
					END IF;
				END IF;
			END IF;		
			
			/*IF 	d_monto_pagar_propio IS NULL  THEN
			--conforme a indicaciones correo Josafatt (ASUNTO Proyecto Calificacion de Cartera.)12 Octubre y reunion con Gaby de ese mismo dia.
				LET d_monto_pagar_propio = 0;
			END IF;*/
			
			IF 	c_gveces  IS NOT NULL  THEN
				IF c_gveces  = 'GVeces1' THEN
					LET n_gveces_1 = 1;
					LET n_gveces_2 = 0;
					LET n_gveces_3 = 0;
				ELIF c_gveces  = 'GVeces2' THEN
					LET n_gveces_1 = 0;
					LET n_gveces_2 = 1;
					LET n_gveces_3 = 0;
				ELIF c_gveces  = 'GVeces3' THEN	
					LET n_gveces_1 = 0;
					LET n_gveces_2 = 0;
					LET n_gveces_3 = 1;
				END IF;	
			ELSE 
				IF n_consulta_sin_info = 1 THEN  --Consulta sin informacion
				--	IF d_pago_minimo > 640 THEN  --IPCB 06/11/18 se solicita tomar el d_monto_pagar_propio de las variables de circulo y no el pago minimo
				    IF d_monto_pagar_propio  > 640 THEN
						LET n_gveces_1 = 0;
						LET n_gveces_2 = 1;
						LET n_gveces_3 = 0;
					ELSE
						LET n_gveces_1 = 1;
						LET n_gveces_2 = 0;
						LET n_gveces_3 = 0;
					END IF;
				ELSE  --Sin consulta
					LET n_gveces_1 = 0;
					LET n_gveces_2 = 0;
					LET n_gveces_3 = 1;
				END IF;
			END IF;
			
			/*IF 	d_monto_pagar_otros IS NULL  THEN
				LET d_monto_pagar_otros = 0;
			END IF;*/

            -- CJAC CAMPOS ADICIONALES numero_cuenta_det, v_meses_primer_crdbco,v_meses_ult_atr_bk,monto_pagar_propio,monto_pagar_otros,veces_monto_bco_sis
                           
           IF v_numero_cuenta_det IS NULL THEN
                LET v_numero_cuenta_det ='ND';
                LET v_meses_primer_crdbco= -99999;
                LET v_meses_ult_atr_bk= -99999;
                LET d_monto_pagar_propio= 0;
                LET d_monto_pagar_otros= 0;
                LET v_veces_monto_bco_sist= -99999;
           ELSE 
                IF v_meses_primer_crdbco IS NULL THEN
                    LET v_meses_primer_crdbco= '';
                END IF;
                IF v_meses_ult_atr_bk IS NULL THEN
                    LET v_meses_ult_atr_bk= '';
                END IF;
                IF d_monto_pagar_propio IS NULL THEN
                    LET d_monto_pagar_propio= '';
                END IF;
                IF d_monto_pagar_otros IS NULL THEN
                    LET d_monto_pagar_otros= '';
                END IF;
                IF v_veces_monto_bco_sist IS NULL THEN
                    LET v_veces_monto_bco_sist= '';
                END IF;
           END IF;

                 --CJAC CAMPO ADICIONAL intereses_ordinarios
        IF day(dt_cierre_proc)='31' THEN 
            SELECT nvl(intvig31,0), nvl(intvenc31,0), nvl(meses_vencidos31,0), (nvl(capvig31,0) + nvl(captrans31,0) + nvl(capvencnoexig31,0) + nvl(capvenexig31,0))
            INTO v_intereses_ordinarios, v_intereses_moratorios, v_num_pagos_vencidos, v_capital_cierre
            FROM sd_sdodiario 
            WHERE num_credito=c_num_credito and fecha = dt_ini_per_proc;
        END IF;

        IF day(dt_cierre_proc)='30' THEN 
            SELECT nvl(intvig30,0), nvl(intvenc30,0), nvl(meses_vencidos30,0), (nvl(capvig30,0) + nvl(captrans30,0) + nvl(capvencnoexig30,0) + nvl(capvenexig30,0))
            INTO v_intereses_ordinarios, v_intereses_moratorios, v_num_pagos_vencidos, v_capital_cierre
            FROM sd_sdodiario 
            WHERE num_credito=c_num_credito and fecha = dt_ini_per_proc;
        END IF;

        IF day(dt_cierre_proc)='29' THEN 
            SELECT nvl(intvig29,0), nvl(intvenc29,0), nvl(meses_vencidos29,0), (nvl(capvig29,0) + nvl(captrans29,0) + nvl(capvencnoexig29,0) + nvl(capvenexig29,0))
            INTO v_intereses_ordinarios, v_intereses_moratorios, v_num_pagos_vencidos, v_capital_cierre  
            FROM sd_sdodiario 
            WHERE num_credito=c_num_credito and fecha = dt_ini_per_proc;
        END IF;

        IF day(dt_cierre_proc)='28' THEN 
            SELECT nvl(intvig28,0), nvl(intvenc28,0), nvl(meses_vencidos28,0), (nvl(capvig28,0) + nvl(captrans28,0) + nvl(capvencnoexig28,0) + nvl(capvenexig28,0))
            INTO v_intereses_ordinarios, v_intereses_moratorios, v_num_pagos_vencidos, v_capital_cierre 
            FROM sd_sdodiario 
            WHERE num_credito=c_num_credito and fecha = dt_ini_per_proc;
        END IF;
            
        --CJAC  CAMPO ADICIONAL capital_cierre
        LET v_capital_cierre=v_capital_cierre-v_intereses_ordinarios; --modificacion solicitada el 11/dic/2019
   
   
--Query  5--Monto del Credito en la originacio 
        SELECT monto_solicitado INTO d_limite_credito_orig
          FROM bdisolic:ss_solicitudes
         WHERE empresa = '001'
           AND num_solicitud = c_num_credito;
		   		  
		  IF  d_limite_credito_orig IS NULL THEN	
			SELECT limite_aut  INTO d_limite_credito_orig
			FROM sd_tarjeta 
			WHERE num_Credito  =c_num_credito
			  AND tipo_tarjeta = 'T'
			  AND status_tar = 'A' ;
		  END IF;	 
--Query 6
		--IF EXISTS (SELECT * FROM sd_indicador_cred_hist WHERE empresa = '001' AND fecha= dt_corte AND num_Credito = c_num_credito) THEN --IPCB se cambia por la operativa
		IF EXISTS (SELECT * FROM sd_indicador_cred WHERE empresa = '001' AND num_Credito = c_num_credito) THEN
			SELECT NVL(pos_disp_fecha,DATE(1)),NVL(vnt_disp_fecha,DATE(1)),NVL(atm_disp_fecha,DATE(1)),NVL(fecha_ultimo_pago,DATE(1)),NVL(fecha_ultima_compra,DATE(1))
			  INTO dt_ult_pos_disp, dt_ult_vnt_disp, dt_ult_atm_disp,dt_ult_pago,dt_ult_compra
			 -- FROM sd_indicador_cred_hist --IPCB se cambia por la operativa
			 FROM sd_indicador_cred
			 WHERE empresa = '001' 
			 --  AND fecha= dt_corte        --mdy ('06','20','2018')  --IPCB se quita por cambio a la operativa
			   AND num_Credito = c_num_credito;
			   
			   IF dt_ult_pos_disp >= dt_ult_vnt_disp AND dt_ult_pos_disp >= dt_ult_atm_disp AND dt_ult_pos_disp >= dt_ult_pago AND dt_ult_pos_disp >= dt_ult_compra THEN
					LET dt_ult_mov = dt_ult_pos_disp;
			   ELIF dt_ult_vnt_disp >= dt_ult_pos_disp AND dt_ult_vnt_disp >= dt_ult_atm_disp AND dt_ult_vnt_disp >= dt_ult_pago AND dt_ult_vnt_disp >= dt_ult_compra THEN
					LET dt_ult_mov = dt_ult_vnt_disp;
			   ELIF dt_ult_atm_disp >= dt_ult_pos_disp AND dt_ult_atm_disp >= dt_ult_vnt_disp AND dt_ult_atm_disp >= dt_ult_pago AND dt_ult_atm_disp >= dt_ult_compra THEN
					LET dt_ult_mov = dt_ult_atm_disp;
			   ELIF dt_ult_pago >=  dt_ult_pos_disp AND dt_ult_pago >= dt_ult_vnt_disp AND dt_ult_pago >= dt_ult_atm_disp AND dt_ult_pago >= dt_ult_compra  THEN
					LET dt_ult_mov = dt_ult_pago;
			   ELIF  dt_ult_compra >=  dt_ult_pos_disp AND dt_ult_compra >= dt_ult_vnt_disp AND dt_ult_compra >= dt_ult_atm_disp AND dt_ult_compra >= dt_ult_pago   THEN
					LET dt_ult_mov = dt_ult_compra;			
			   END IF;

			   LET n_ult_mov = (year(dt_corte)  - year(dt_ult_mov)) * 12 +  (month(dt_corte) - month(dt_ult_mov));
			   
			   IF n_ult_mov >= 13 THEN
					LET n_sin_mov = 1;
			   ELSE
					LET n_sin_mov = 0;
			   END IF;
		ELSE
			LET n_sin_mov = 0;
		END IF;	
         --Query 7  ---MOVIMIENTOS
		--Comision Apertura 
		SELECT SUM(monto) INTO d_comision_apert
		 FROM movs_comis
		 WHERE num_credito = c_num_credito
		 AND codigo_fun = '339'
		 AND codigo_ref = 96;
		 
		--Comisiones Disposicion
		SELECT SUM(monto) INTO d_comision_disp
		 FROM movs_comis
		 WHERE num_credito = c_num_credito
		 AND((codigo_fun = '339' AND codigo_ref in (50,51)));
		   -- OR (codigo_fun = '002' AND codigo_ref = 60 ));
		   
		SELECT SUM(monto) INTO v_comaclara
		 FROM movs_comis
		 WHERE num_credito = c_num_credito
		 --AND((codigo_fun = '018' AND codigo_ref in (2))); 
		 AND((codigo_fun = '018' AND codigo_ref in (2,902,904))); 
		 
		SELECT SUM(monto) INTO v_comremf
		 FROM movs_comis
		 WHERE num_credito = c_num_credito
		 AND((codigo_fun = '033' AND codigo_ref in (6218,6219,6220,6221))); 
		 
	
		LET v_comtotal= nvl(d_comision_disp,0) + nvl(v_comaclara,0) + nvl(v_comremf,0);
		


		 
		
		 --IPCB se consideran los pagos completos, incluye moratorios
		 SELECT SUM (CASE WHEN codigo_ref in (5,923,925,926,2,6616,6617,6652,6709) THEN monto ELSE 0 END) Interes_Vencido,
				SUM (CASE WHEN codigo_ref in (7,10,901,907,908,909) THEN monto ELSE 0 END) Capital_Vigente,
				SUM (CASE WHEN codigo_ref = 8 THEN monto ELSE 0 END) Capital_vencido,
				SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_completo_realizado
				INTO d_pago_int_venc, d_pago_cap_vig, d_pago_cap_venc,d_pago_realizado
		   FROM movs_pagos
		  WHERE fecha_mov BETWEEN dt_ini_per_rep AND dt_corte  --21/05 a 20/06
		    AND num_credito = c_num_credito;
   								 
		LET d_pago_capital = d_pago_cap_vig + d_pago_cap_venc;


		--CAMBIOS A LOS REPORTES
		IF d_pago_realizado_1 is null or d_pago_realizado_1 = '' THEN
			SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_completo_realizado_1
				INTO d_pago_realizado_1
			FROM movs_pagos2
			WHERE fecha_mov BETWEEN (dt_ini_per_rep - 1 units month) AND (dt_corte - 1 units month) --21/04 a 20/05
		    AND num_credito = c_num_credito;
			

			SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_completo_realizado_2
				INTO d_pago_realizado_2
			FROM movs_pagos2
			WHERE fecha_mov BETWEEN (dt_ini_per_rep - 2 units month) AND (dt_corte - 2 units month) --21/03 a 20/04
		    AND num_credito = c_num_credito;	
			

			SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_completo_realizado_3
				INTO d_pago_realizado_3
			FROM movs_pagos2
			WHERE fecha_mov BETWEEN (dt_ini_per_rep - 3 units month) AND (dt_corte - 3 units month) --21/02 a 20/03
		    AND num_credito = c_num_credito;
			
		END IF;
		--FIN CAMBIOS REPORTES		
		/*
		   SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_completo_realizado_1
				INTO d_pago_realizado_1
		   FROM movs_pagos
		  WHERE fecha_mov BETWEEN (dt_ini_per_rep - 1 units month) AND (dt_corte - 1 units month) --21/04 a 20/05
		    AND num_credito = c_num_credito;
			

		   SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_completo_realizado_2
				INTO d_pago_realizado_2
		   FROM movs_pagos
		  WHERE fecha_mov BETWEEN (dt_ini_per_rep - 2 units month) AND (dt_corte - 2 units month) --21/03 a 20/04
		    AND num_credito = c_num_credito;		
			

		  SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_completo_realizado_3
			INTO d_pago_realizado_3
		   FROM movs_pagos
		  WHERE fecha_mov BETWEEN (dt_ini_per_rep - 3 units month) AND (dt_corte - 3 units month) --21/02 a 20/03
		    AND num_credito = c_num_credito;	
			*/
			
		--NUEVO************************************************************
	
		
		--se mantiene siempre la busqueda del primer mes por reportes 	
				LET dt_corte_cierre = mdy(month(dt_cierre_proc),(n_dia_corte+1),year(dt_cierre_proc));
		
		SELECT SUM (CASE WHEN codigo_ref = 1 THEN NVL(monto,0) ELSE 0 END) Pago_cierre_incompleto
			INTO v_pago_cierre
		FROM movs_pagos
		WHERE fecha_mov BETWEEN dt_corte_cierre AND dt_cierre_proc  --corte+1 al cierre del producto -- septiembre 21 al 30
			AND num_credito = c_num_credito;
			
		--Se suma el pago realizado hasta la fecha corte del mes
			LET v_pago_cierre = NVL(d_pago_realizado,0) +  NVL(v_pago_cierre,0);
			
			
					
--CAMBIO REPORTES
		IF v_pago_cierre_1 is null or v_pago_cierre_1 = '' THEN
			
			LET dt_cierre_prod_pago_cierre_1 = dt_ini_per_proc - 1 units DAY; -- 1/09/2022 - 1 Day = 31/08/2022
			
			SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END)  Pago_cierre_incompleto_1
				INTO v_pago_cierre_1
			FROM movs_pagos2
			WHERE fecha_mov BETWEEN (dt_corte_cierre - 1 units month) AND (dt_cierre_prod_pago_cierre_1) -- agosto 21 al 31
		    AND num_credito = c_num_credito;	
		
			--Se suma el pago realizado hasta la fecha corte del mes
			LET v_pago_cierre_1 = NVL(d_pago_realizado_1,0) + NVL(v_pago_cierre_1,0);
			
			LET dt_ini_prod_pago_cierre_1 = mdy(month(dt_cierre_prod_pago_cierre_1), '01', year(dt_cierre_prod_pago_cierre_1)); -- 31/08/2022 a primer dia del mes = 01/08/2022
			LET dt_cierre_prod_pago_cierre_2 = dt_ini_prod_pago_cierre_1 - 1 units DAY; -- 01/08/2022 - 1 Day = 31/07/2022
			
			SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_cierre_incompleto_2
				INTO v_pago_cierre_2
			FROM movs_pagos2
			WHERE fecha_mov BETWEEN (dt_corte_cierre - 2 units month) AND (dt_cierre_prod_pago_cierre_2)-- julio 21 al 31
		    AND num_credito = c_num_credito;	
		
			--Se suma el pago realizado hasta la fecha corte del mes
			LET v_pago_cierre_2 = NVL(d_pago_realizado_2,0) +  NVL(v_pago_cierre_2,0);
			
			LET dt_ini_prod_pago_cierre_2 = mdy(month(dt_cierre_prod_pago_cierre_2), '01', year(dt_cierre_prod_pago_cierre_2)); -- 31/07/2022 a primer dia del mes = 01/07/2022
			LET dt_cierre_prod_pago_cierre_3 = dt_ini_prod_pago_cierre_2 - 1 units DAY; -- 01/08/2022 - 1 Day = 30/06/2022
			
			
			SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_cierre_incompleto_3
				INTO v_pago_cierre_3
			FROM movs_pagos2
			WHERE fecha_mov BETWEEN (dt_corte_cierre - 3 units month) AND (dt_cierre_prod_pago_cierre_3) -- junio 21 al 30
		    AND num_credito = c_num_credito;
			
			
			--Se suma el pago realizado hasta la fecha corte del mes
			LET v_pago_cierre_3 = NVL(d_pago_realizado_3,0) +  NVL(v_pago_cierre_3,0);
			
		END IF;
	
--FIN CAMBIO REPORTES	
		
		/*
			LET dt_cierre_prod_pago_cierre_1 = dt_ini_per_proc - 1 units DAY; -- 1/09/2022 - 1 Day = 31/08/2022
			
		SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END)  Pago_cierre_incompleto_1
			INTO v_pago_cierre_1
		FROM movs_pagos
		WHERE fecha_mov BETWEEN (dt_corte_cierre - 1 units month) AND (dt_cierre_prod_pago_cierre_1) -- agosto 21 al 31
		    AND num_credito = c_num_credito;	
		
		--Se suma el pago realizado hasta la fecha corte del mes
			LET v_pago_cierre_1 = NVL(d_pago_realizado_1,0) + NVL(v_pago_cierre_1,0);
			
			LET dt_ini_prod_pago_cierre_1 = mdy(month(dt_cierre_prod_pago_cierre_1), '01', year(dt_cierre_prod_pago_cierre_1)); -- 31/08/2022 a primer dia del mes = 01/08/2022
			LET dt_cierre_prod_pago_cierre_2 = dt_ini_prod_pago_cierre_1 - 1 units DAY; -- 01/08/2022 - 1 Day = 31/07/2022
			
		SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_cierre_incompleto_2
			INTO v_pago_cierre_2
		FROM movs_pagos
		WHERE fecha_mov BETWEEN (dt_corte_cierre - 2 units month) AND (dt_cierre_prod_pago_cierre_2)-- julio 21 al 31
		    AND num_credito = c_num_credito;	
		
		--Se suma el pago realizado hasta la fecha corte del mes
			LET v_pago_cierre_2 = NVL(d_pago_realizado_2,0) +  NVL(v_pago_cierre_2,0);
			
			LET dt_ini_prod_pago_cierre_2 = mdy(month(dt_cierre_prod_pago_cierre_2), '01', year(dt_cierre_prod_pago_cierre_2)); -- 31/07/2022 a primer dia del mes = 01/07/2022
			LET dt_cierre_prod_pago_cierre_3 = dt_ini_prod_pago_cierre_2 - 1 units DAY; -- 01/08/2022 - 1 Day = 30/06/2022
			
			
		SELECT SUM (CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END) Pago_cierre_incompleto_3
			INTO v_pago_cierre_3
		FROM movs_pagos
		WHERE fecha_mov BETWEEN (dt_corte_cierre - 3 units month) AND (dt_cierre_prod_pago_cierre_3) -- junio 21 al 30
		    AND num_credito = c_num_credito;
			
			
			--Se suma el pago realizado hasta la fecha corte del mes
			LET v_pago_cierre_3 = NVL(d_pago_realizado_3,0) +  NVL(v_pago_cierre_3,0);
		*/	
		
		--se calcula el del mes actual
			--NUEVO IMPAGO del pago cierre 
		IF v_pago_cierre < d_monto_exigido THEN 
			LET v_impago0 = 1;
		ELSE 
			LET v_impago0 = 0;
		END IF;
		--creditos que no estan en el reporte
		IF v_impago1 is null or v_impago1 = '' THEN
			IF v_pago_cierre_1 < d_monto_exigido1 THEN 
				LET v_impago1 = 1;
			ELSE 
				LET v_impago1 = 0;
			END IF;
			
			IF v_pago_cierre_2 < d_monto_exigido2 THEN 
				LET v_impago2 = 1;
			ELSE 
				LET v_impago2 = 0;
			END IF;
			
			IF v_pago_cierre_3 < d_monto_exigido3 THEN 
				LET v_impago3 = 1;
			ELSE 
				LET v_impago3 = 0;
			END IF;
		END IF;
	--se calcula el del mes actual
		IF NVL(d_pago_realizado,0)  <  d_monto_exigido THEN --d_monto_exigido  --corte
			LET v_impago0_corte = 1;
		ELSE	
			LET v_impago0_corte = 0;
		END IF;
		
--creditos que no esten en el reporte		
		IF v_impago1_corte is null or v_impago1_corte = '' THEN
			
			IF NVL(d_pago_realizado_1,0) < d_monto_exigido1 THEN 		--1 mes atras
				LET v_impago1_corte = 1;
			ELSE	
				LET v_impago1_corte = 0;
			END IF;
		
			IF NVL(d_pago_realizado_2,0) < d_monto_exigido2 THEN 		--2 mes atras
				LET v_impago2_corte = 1;
			ELSE	
				LET v_impago2_corte = 0;
			END IF;
			
			IF NVL(d_pago_realizado_3,0) < d_monto_exigido3 THEN 		--3 mes atras
				LET v_impago3_corte = 1;
			ELSE	
				LET v_impago3_corte = 0;
			END IF;	
			
		END IF;
		 --NUEVO************************************************************
		--IF d_monto_exigido = 0 OR d_pago_realizado IS NULL THEN --IPCB se solicito modificacion de la formula @12 nov Josafatt
		IF (d_saldo_corte+d_sdo_corte_cred1) = 0 OR d_pago_realizado IS NULL THEN
			LET d_porcentaje_pago = 0;
		ELSE
			--LET d_porcentaje_pago = Round((d_pago_realizado/d_monto_exigido),2);	--IPCB se solicito modificacion de la formula @12 nov Josafatt
			LET d_porcentaje_pago = Round(d_pago_realizado/(d_saldo_corte+d_sdo_corte_cred1),6); --CJAC Se modifica longitud de los decimales de (18,2) a (18,6) asi como el redondeo a 6 decimales
		END IF;
		
		IF d_limite_credito_corte = 0 THEN
			LET d_porcentaje_uso = 0;
		ELSE	
			LET d_porcentaje_uso = Round(((d_saldo_corte + d_sdo_corte_cred1) / d_limite_credito_corte),6); --CJAC Se suma d_sdo_corte_cred1 y se modifico la longitud de decimal (18,2) a (18,6)
		END IF;
		
		IF d_porcentaje_uso < 0 THEN
			LET d_porcentaje_uso = 0;
		END IF;

         --Query 8
		
			 --se comenta para optimizacion del sp, se toma el valor de un reporte
			SELECT trim(nombre1),trim(nombre2),trim(apell_paterno),trim(apell_materno) 
			  INTO c_nombre1,c_nombre2,c_ap_paterno,c_ap_materno 
			  FROM bdinteg:si_Cliente
			 WHERE numcte = c_numcte;      
			 
			 LET c_nom_cte = c_nombre1||' '||c_nombre2||' '||c_ap_paterno||' '||c_ap_materno;
		

--Query 9
		/*
			--se comenta para optimizacion del sp, se toma el valor de un reporte
			SELECT trim(nombre_prod)  INTO c_nombre_prod
			  FROM sd_definicion 
			 WHERE num_producto = c_producto;	  
		*/
--Nivel de Riesgos/Campo 1,5, 
		IF n_antig_cte <= 42 AND d_limite_credito <=  15000 THEN
			LET n_alto = 1;	
		ELIF (n_antig_cte <= 42 AND d_limite_credito > 40000) OR (n_antig_cte > 42 AND d_limite_credito <= 15000 ) OR (d_limite_credito > 15000 AND d_limite_credito <= 40000) THEN
			LET n_medio = 1;
		ELIF n_antig_cte > 42 AND d_limite_credito > 40000 THEN
			LET n_bajo = 1;
		END IF;	
--HIST
		/* PRODUCTIVO
		SELECT count(*) INTO n_imp_hist_6m
		  FROM sd_maecredcont
		 WHERE fecha BETWEEN (dt_cierre_proc - 5 UNITS MONTH) AND dt_cierre_proc 
		   AND num_Credito = c_num_credito
		   AND (status_cred IN ('BA','BT') OR (status_cred='E1' and n_impagos_consec=1) OR (status_cred='E2' AND n_impagos_consec in(2,3)) OR (status_cred='E3' AND n_impagos_consec>=4));
		  */
		
		-- se agrega para prueba AFC
		SELECT count(*) INTO n_imp_hist_6m
		  FROM sd_maecredcont a inner join sd_maesdoscont b on b.fecha = a.fecha and b.num_credito = a.num_credito
		 WHERE a.fecha BETWEEN (dt_cierre_proc - 5 UNITS MONTH) AND dt_cierre_proc
		   AND a.num_Credito = c_num_credito
		   AND (a.status_cred IN ('BA','BT') OR (a.status_cred IN ('E1','E2','E3') and b.act >= 1));
		   
		
		/*SELECT count(*) INTO n_imp_hist_6m_corte  --NUEVO CAMPO HIST_Corte
		FROM sd_maesdoscont
		WHERE fecha BETWEEN (dt_corte - 5 UNITS MONTH) AND dt_corte 
		AND num_Credito = c_num_credito
		AND (status_cred IN ('BA','BT') OR (status_cred='E1' and n_impagos_consec=1) OR (status_cred='E2' AND n_impagos_consec in(2,3)) OR (status_cred='E3' AND n_impagos_consec>=4));
		*/
		/*
		SELECT count(*) INTO n_imp_hist_6m_corte  --NUEVO CAMPO HIST_Corte
		FROM sd_maecredcont a inner join sd_maesdoscont b 
		on a.fecha = b.fecha and a.num_Credito = b.num_Credito 
		WHERE a.fecha BETWEEN (dt_cierre_proc - 6 UNITS MONTH) AND dt_cierre_proc
		AND a.num_Credito = c_num_credito
		AND (status_cred IN ('BA','BT') OR (status_cred='E1' and act=1) OR (status_cred='E2' AND act in(2,3)) OR (status_cred='E3' AND act>=4));*/

		SELECT count(*)   -----hist corte
		INTO n_imp_hist_6m_corte
		FROM bdicred:sd_maesdoshist 
		WHERE empresa = '001'
		AND num_credito = c_num_credito
		AND (monto_vencido > 0 or mto_venc_trasp > 0)
		AND fecha BETWEEN (mdy(month(dt_cierre_proc), n_dia_corte, year(dt_cierre_proc)) - 5 UNITS MONTH) AND mdy(month(dt_cierre_proc), n_dia_corte, year(dt_cierre_proc));

		--IF n_imp_hist_6m_corte>6 THEN
		--	LET n_imp_hist_6m_corte=6;
		--END IF;
	
		--n_impagos_consec_corte = ACT_corte = 7
		--n_imp_hist_6m_corte = HIST_Corte = 0
		--Nuevo*******************
		IF n_impagos_consec_corte < 6 AND n_imp_hist_6m_corte < n_impagos_consec_corte THEN
			LET n_imp_hist_6m_corte = n_impagos_consec_corte;
		ELSE IF n_impagos_consec_corte >=6 AND n_imp_hist_6m_corte< n_impagos_consec_corte THEN	
			LET n_imp_hist_6m_corte = 6;
			END IF;
		END IF;	
		
		--NUEVO
		--If ACT_corte<6 y HIST_corte<ACT_corte, 
		--	entonces HIST_corte=ACT_corte, 
		--else if ACT_corte>=6 y HIST_corte<ACT_corte, 
		--	entonces HIST_corte=6.Â 

		--NUEVO
		
--credisol & MSI
	SELECT limit 1 num_sol_prestamo  INTO c_cta_credisol
	  FROM sd_promocion_credito a
			INNER JOIN sd_maecredcontcrd b on b.fecha = dt_cierre_proc  and b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred IN('AA','E1')
				WHERE a.num_credito = c_num_credito
				  AND num_sol_prestamo <> ''
				  AND num_pro_prestamo = '6900';
				 
				  
	select nvl(max(num_sol_prestamo),0) INTO v_num_cta_msi  --# v_num_cta_msi nÃºmero de crÃ©dito MSI mÃ¡s reciente
	  FROM sd_promocion_credito a
			INNER JOIN sd_maecredcontcrd b on b.fecha = dt_cierre_proc  and b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred IN('AA','E1')
				WHERE a.num_credito = c_num_credito
				  AND num_sol_prestamo <> ''
				  AND num_pro_prestamo = '8900';								

	SELECT SUM(c.sdo_cap_insoluto)+ SUM(c.sdo_intereses)+ SUM(c.sdo_no_exig) --CJAC Cambio a definiciones a saldo_cierre_credisol
				INTO d_saldo_cierre_credisol
				FROM sd_promocion_credito a
		  INNER JOIN sd_maecredcontcrd b on b.fecha = dt_cierre_proc and b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred IN('AA','E1') 
		  INNER JOIN sd_maesdoscontcrd c on c.fecha = dt_cierre_proc and c.empresa = a.empresa and c.num_credito = a.num_sol_prestamo
			   WHERE a.empresa = '001'
				 AND num_pro_prestamo = '6900'					   
				 AND a.num_credito = c_num_credito;
		SELECT count(*)
				INTO v_MSI_hist
				FROM sd_promocion_credito
				WHERE num_pro_prestamo = '8900'
				AND status in ('2','6','7')
 				AND num_credito = c_num_credito;
				
		SELECT count(num_sol_prestamo), sum(a.plazo) 
				INTO v_Promedio_MSI_meses, v_Promedio_MSI_plazo 
				FROM sd_promocion_credito a
				INNER JOIN sd_maecredcontcrd b on b.fecha = dt_cierre_proc  and b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred IN('AA','E1')	   
				WHERE a.num_credito = c_num_credito
				  AND num_pro_prestamo = '8900';
				
				LET v_MSI_act =v_Promedio_MSI_meses;
 
				LET v_Promedio_MSI_contratados = v_Promedio_MSI_plazo/v_Promedio_MSI_meses; --# Promedio de plazos de MSI activas al corte
				LET v_saldopci= 0;
				LET v_saldopci_total=0;
				LET d_saldo_corte_credisol = 0;
				LET v_Promedio_MSI_amort = 0;
				LET v_MSI_amort = 0;
				LET v_saldo_cierre_msi = 0;
				LET v_sdo_corte_msi = 0;
				LET v_sdo_corte_msi_1 = 0;
				LET v_sdo_corte_msi_2 = 0;
				LET v_sdo_corte_msi_3 = 0;
				LET v_sdo_corte_msi_4 = 0;			  
				LET v_Saldo_prom_MSI=0;

				FOREACH WITH HOLD
					SELECT a.num_sol_prestamo, dia_corte, num_producto
					  INTO cta_credsol_msi , dia_corte_credsol, v_num_producto_mc
					  FROM sd_promocion_credito a
						INNER JOIN sd_maecredcontcrd b on b.fecha = dt_cierre_proc and b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred IN('AA','E1')
						INNER JOIN sd_maecredanexocrd  c on a.empresa  = c.empresa  and c.num_credito = a.num_sol_prestamo 
					 WHERE a.empresa = '001'
					   AND a.num_credito = c_num_credito

					IF dia_corte_credsol >= 21 THEN --Si dia corte > = 21 se trae la fecha de corte de un mes previo
						 IF month(dt_ini_per_proc - 1 units day) = 2  AND (dia_corte_credsol= 29 OR dia_corte_credsol=30) THEN
							LET  dt_corte_credsol = dt_ini_per_proc - 1 units day;
						 ELIF dia_corte_credsol = 31 THEN
							LET  dt_corte_credsol = dt_ini_per_proc - 1 units day;
						 ELSE
							LET  dt_corte_credsol = mdy(month(dt_ini_per_proc - 1 units day),dia_corte_credsol,year(dt_ini_per_proc - 1 units day));		 
						 END IF;				
					ELSE --Si dia corte < 21, trae la fecha de corte del mes procesado
						LET  dt_corte_credsol = mdy(month(dt_cierre_proc),dia_corte_credsol,year(dt_cierre_proc));
					END IF;	

				
				
				 SELECT NVL(sdo_cap_insoluto,0) 
				   INTO d_saldo_corte_credisol_a
				   FROM sd_maesdoshistcrd c  
				  WHERE fecha = dt_corte_credsol
					AND c.num_Credito  =cta_credsol_msi;
				   
					IF v_num_producto_mc = '6900' THEN	-- Si eres credisolucion, sumas variables de credisolucion
						LET d_saldo_corte_credisol = d_saldo_corte_credisol + NVL(d_saldo_corte_credisol_a,0);
					ELSE 							-- Si eres msi, sumas variables de msi
						LET v_sdo_corte_msi = NVL(v_sdo_corte_msi,0) + NVL(d_saldo_corte_credisol_a,0);	--#v_sdo_corte_msi saldo total al corte del periodo de MSI 
		
					END IF;				

					
					--SALDOPCI
					select capvig20+capvig21+capvig22+capvig23+capvig24+capvig25+capvig26+capvig27+capvig28+capvig29+capvig30+capvig31 
					into sum_capvig1
					from sd_SDODIARIOCRD  
					where num_credito= cta_credsol_msi
					and fecha=(mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol))- 1 units month);  --28741.38

					select capvig1+capvig2+capvig3+capvig4+capvig5+capvig6+capvig7+capvig8+capvig9+capvig10+capvig11+capvig12+capvig13+capvig14+capvig15+capvig16+capvig17+capvig18+capvig19 
					into sum_capvig2
					from sd_SDODIARIOCRD 
					where num_credito= cta_credsol_msi
					and fecha=mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));  --49080.6

					IF v_num_producto_mc = '6900' THEN	-- Si eres credisolucion, sumas variables de credisolucion
						LET v_saldopci_total= ((sum_capvig1+sum_capvig2)/abs(v_dias_periodo_tc));
																		
						LET v_saldopci=v_saldopci + v_saldopci_total;
					ELSE
						LET v_saldopmsi_total = (nvl(sum_capvig1,0)+nvl(sum_capvig2,0)/abs(v_dias_periodo_tc));  --# v_saldopmsi Saldo promedio diario de MSI al corte
						LET v_saldopmsi=v_saldopmsi + v_saldopmsi_total;
					END IF;
					LET v_dia_corte_credisol=dia_corte_credsol;
					

					IF v_dia_corte_credisol='31' THEN 
						SELECT intvig31+intvenc31
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='30' THEN 
						SELECT intvig30+intvenc30 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;

					IF v_dia_corte_credisol='29' THEN 
						SELECT intvig29+intvenc29
						INTO v_interesespci 
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;

					IF v_dia_corte_credisol='28' THEN 
						SELECT intvig28+intvenc28 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='27' THEN 
						SELECT intvig27+intvenc27 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='26' THEN 
						SELECT intvig26+intvenc26 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='25' THEN 
						SELECT intvig25+intvenc25 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='24' THEN 
						SELECT intvig24+intvenc24 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='23' THEN 
						SELECT intvig23+intvenc23 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='22' THEN 
						SELECT intvig22+intvenc22 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;			
					
					IF v_dia_corte_credisol='21' THEN 
						SELECT intvig21+intvenc21 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='20' THEN 
						SELECT intvig20+intvenc20 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='19' THEN 
						SELECT intvig19+intvenc19 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='18' THEN 
						SELECT intvig18+intvenc18
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='17' THEN 
						SELECT intvig17+intvenc17
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;			
					
					IF v_dia_corte_credisol='16' THEN 
						SELECT intvig16+intvenc16
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='15' THEN 
						SELECT intvig15+intvenc15
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='14' THEN 
						SELECT intvig14+intvenc14 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='13' THEN 
						SELECT intvig13+intvenc13
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='12' THEN 
						SELECT intvig12+intvenc12 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='11' THEN 
						SELECT intvig11+intvenc11 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					
					IF v_dia_corte_credisol='10' THEN 
						SELECT intvig10+intvenc10
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='9' THEN 
						SELECT intvig9+intvenc9 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='8' THEN 
						SELECT intvig8+intvenc8 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
								
					IF v_dia_corte_credisol='7' THEN 
						SELECT intvig7+intvenc7 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='6' THEN 
						SELECT intvig6+intvenc6 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='5' THEN 
						SELECT intvig5+intvenc5
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='4' THEN 
						SELECT intvig4+intvenc4 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
					
					IF v_dia_corte_credisol='3' THEN 
						SELECT intvig3+intvenc3 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
								
					IF v_dia_corte_credisol='2' THEN 
						SELECT intvig2+intvenc2 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;
										
					IF v_dia_corte_credisol='1' THEN 
						SELECT intvig1+intvenc1 
						INTO v_interesespci
						FROM sd_SDODIARIOCRD 
						WHERE num_credito=cta_credsol_msi and fecha = mdy(month(dt_corte_credsol), '01', year(dt_corte_credsol));
					END IF;	
					
					SELECT NVL(plazo,0)
					INTO v_MSI_amort_plazo
					FROM sd_promocion_credito
					WHERE num_sol_prestamo = cta_credsol_msi
 					AND num_pro_prestamo = '8900';

					SELECT count(*)
					INTO v_MSI_amort_pagados
					FROM bdicred:sd_amortiza_creditocrd
					WHERE capital_status = '5'
					AND num_credito = cta_credsol_msi
					AND fecha_cuota <= dt_cierre_proc;		   

				 LET v_MSI_amort_a=0;

				 LET v_MSI_amort_a = v_MSI_amort_plazo - v_MSI_amort_pagados;  --# v_MSI_amort_a total de plazos MSI menos plazos pagados
				 LET v_MSI_amort = v_MSI_amort + v_MSI_amort_a;  --# Suma de plazos por pagar
				
					SELECT max(num_sol_prestamo)
					INTO v_num_cta_msi_tmp
					FROM sd_promocion_credito a
					INNER JOIN sd_maecredcontcrd b on b.fecha = dt_cierre_proc  and b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred IN('AA','E1')		
					WHERE a.num_credito = c_num_credito
					AND num_pro_prestamo = '8900';
				
				IF trim(v_num_cta_msi_tmp) <> '' THEN
				
					LET v_saldo_cierre_msi_tmp = 0;
					LET v_sdo_corte_msi_1_tmp = 0;
					LET v_sdo_corte_msi_2_tmp = 0;
					LET v_sdo_corte_msi_3_tmp = 0;
					LET v_sdo_corte_msi_4_tmp = 0;
					
					SELECT NVL(sdo_cap_insoluto,0) INTO  v_saldo_cierre_msi_tmp
									FROM bdicred:sd_maesdoscontcrd
										WHERE num_credito  = cta_credsol_msi
											  AND fecha = dt_cierre_proc;
					
					LET v_saldo_cierre_msi = nvl(v_saldo_cierre_msi,0) + nvl(v_saldo_cierre_msi_tmp,0);
				  
					SELECT NVL(sdo_cap_insoluto,0) INTO  v_sdo_corte_msi_1_tmp
									FROM bdicred:sd_maesdoshistcrd
										WHERE num_credito  = cta_credsol_msi
											  AND fecha = (MDY(MONTH(dt_corte_credsol),20,YEAR(dt_corte_credsol)) -1 units month);
					LET v_sdo_corte_msi_1 = nvl(v_sdo_corte_msi_1,0) + nvl(v_sdo_corte_msi_1_tmp,0);
					
					SELECT NVL(sdo_cap_insoluto,0) INTO  v_sdo_corte_msi_2_tmp
													   
									FROM bdicred:sd_maesdoshistcrd
										WHERE num_credito  = cta_credsol_msi
											  AND fecha = (MDY(MONTH(dt_corte_credsol),20,YEAR(dt_corte_credsol)) -2 units month);
	  
	  
					LET v_sdo_corte_msi_2 = nvl(v_sdo_corte_msi_2,0) + nvl(v_sdo_corte_msi_2_tmp,0);
	
					SELECT NVL(sdo_cap_insoluto,0) INTO  v_sdo_corte_msi_3_tmp
																																													 
									FROM bdicred:sd_maesdoshistcrd
										WHERE num_credito  = cta_credsol_msi

													   
											  AND fecha = (MDY(MONTH(dt_corte_credsol),20,YEAR(dt_corte_credsol)) -3 units month);
												   
	  
					LET v_sdo_corte_msi_3 = nvl(v_sdo_corte_msi_3,0) + nvl(v_sdo_corte_msi_3_tmp,0);
											  
					SELECT NVL(sdo_cap_insoluto,0) INTO  v_sdo_corte_msi_4_tmp
									FROM bdicred:sd_maesdoshistcrd
										WHERE num_credito  = cta_credsol_msi
											  AND fecha = (MDY(MONTH(dt_corte_credsol),20,YEAR(dt_corte_credsol)) -4 units month);
					LET v_sdo_corte_msi_4 = nvl(v_sdo_corte_msi_4,0) + nvl(v_sdo_corte_msi_4_tmp,0);
			
				ELSE
					LET v_saldo_cierre_msi=0;
					LET v_sdo_corte_msi=0;
					LET v_sdo_corte_msi_1=0;
					LET v_sdo_corte_msi_2=0;
					LET v_sdo_corte_msi_3=0;
				END IF;
				END FOREACH  
				LET v_MSI_amort_count =0;

/*								
				SELECT count(num_sol_prestamo) INTO v_MSI_amort_count 
					FROM sd_promocion_credito a
					INNER JOIN sd_maecredcontcrd b on b.fecha = dt_cierre_proc  and b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred IN('AA','E1')
					WHERE b.num_credito = c_num_credito
					AND num_pro_prestamo = '8900';
*/
				LET v_Promedio_MSI_meses = v_Promedio_MSI_meses; 			  
				IF v_Promedio_MSI_meses < 1 THEN
					LET v_Saldo_prom_MSI = 0;
				ELSE
					LET v_Promedio_MSI_amort = v_MSI_amort/v_Promedio_MSI_meses; --# Promedio de Plazos/meses por pagar de MSI activos al momento del corte
					LET v_Saldo_prom_MSI = v_saldo_cierre_msi/v_Promedio_MSI_meses; --#v_MSI_amort_count = Conteo de crÃ©ditos MSI activos
				END IF;
								
				/*select nvl(b.monto,0) Into v_gastos_originacion from sd_definicion a
				inner join sd_tpcomis b
				on a.cod_comision_apertura=b.cod_comis
				where num_producto=c_producto;*/ --optmizacion 
				
				execute procedure "informix".sp_tasaefectiva(d_limite_credito, v_gastos_originacion, v_tasa_interes, 12, 'M')
				INTO v_log2, v_tasa_efectiva;
				
				IF v_tasa_efectiva =0 THEN 
					LET v_tasa_efectiva= 0.00001;
				END IF;
				
				--LET v_tasa_fija=v_tasa_interes;
				LET v_tasa_interes= v_tasa_interes/100;
				
				LET v_form_sdoapagarxri=((d_saldo_corte+d_saldo_corte_credisol+v_sdo_corte_msi) * (v_tasa_interes));
				LET v_form_pgominx12=(NVL(d_pago_minimo,0)*12);
				/*
				IF v_form_pgominx12 =0 OR v_form_sdoapagarxri =0 THEN
					LET v_form1 =0;
					--LET v_log1= -logn(1 - v_form1);
					--LET v_log2= logn(1+v_tasa_interes);
					--LET v_numero_anios = v_log1/v_log2;
					LET v_numero_anios = -((logn(1-v_form1))/(logn(1+(v_tasa_interes/100))));
	
				ELSE
					LET v_form1 =(v_form_sdoapagarxri/v_form_pgominx12);
					LET v_numero_anios = -((logn(1- v_form1))/(logn(1+(v_tasa_interes/100))));
					--LET v_log1= -logn(1 - v_form1);
					--LET v_log2= logn(1+v_tasa_interes);
					--LET v_numero_anios = v_log1/v_log2;					
					--LET v_numero_anios = -logn(1 - v_form1)/(logn(1+v_tasa_interes));
				END IF;*/
				--LET v_numero_anios =  ((-logn(1 -((d_sdo_corte_cred_t+d_saldo_corte_credisol)*v_tasa_interes)/(NVL(d_pago_minimo,0)*12)))/(logn(1+v_tasa_interes)));
				
				--LET v_log1 = ((d_saldo_corte+d_sdo_corte_cred1)*6)/100;--
				
			IF d_monto_exigido > 0 THEN --Validacion para evitar el error al calcular el logn
				LET v_verificacion_num_anios = 1-((d_saldo_corte+d_sdo_corte_cred1)*(v_tasa_efectiva))/(NVL(d_monto_exigido,0)*12);
			END IF
				
		IF d_monto_exigido > 0 AND v_verificacion_num_anios > 0 THEN 
		
			---LET v_numero_anios = -((logn(1-((d_sdo_corte_cred_t+d_saldo_corte_credisol)*(v_tasa_interes))/(NVL(d_pago_minimo,0)*12)))/(logn(1+(v_tasa_interes))));
			--LET v_numero_anios = -((logn(1-((d_saldo_corte+d_saldo_corte_credisol)*(v_tasa_efectiva))/(NVL(d_pago_minimo,0)*12)))/(logn(1+(v_tasa_efectiva))));--cambio de variable
			
			
			--principal --LET v_numero_anios = -((logn(1-((d_saldo_corte+d_saldo_corte_credisol)*(v_tasa_efectiva))/(NVL(d_pago_minimo,0)*12)))/(logn(1+(v_tasa_efectiva))));  --CAC CAMBIO DE VARIABLE
		
			--modificada
			LET v_numero_anios = -((logn(1-((d_saldo_corte+d_sdo_corte_cred1)*(v_tasa_efectiva))/(NVL(d_monto_exigido,0)*12)))/(logn(1+(v_tasa_efectiva))));  --CAC CAMBIO DE VARIABLE

			
			--IF v_numero_anios<0 THEN 
			--	LET v_numero_anios=1;
			--END IF;
		ELSE  				 
			LET v_numero_anios = 1;		   
		END IF;
		
		  IF n_impagos_consec > 3 THEN
		    LET v_etapa_cred='3';
			LET v_intereses_etapa3=v_intereses_ordinarios;
			LET v_intereses_etapa1=0;
			LET v_intereses_etapa2=0;
		  ELIF n_impagos_consec >= 2 AND n_impagos_consec <= 3  THEN
	        LET v_etapa_cred='2';
			LET v_intereses_etapa2=v_intereses_ordinarios;
			LET v_intereses_etapa1=0;
			LET v_intereses_etapa3=0;
	      ELIF n_impagos_consec <= 1 THEN
	        LET v_etapa_cred='1';
			LET v_intereses_etapa1=v_intereses_ordinarios;
			LET v_intereses_etapa3=0;
			LET v_intereses_etapa2=0;
	      END IF;
		  
		  LET v_etapa_cred_corte=0;
		  IF NVL(n_impagos_consec_corte,0) > 3 THEN
		    LET v_etapa_cred_corte='3';
		  ELIF NVL(n_impagos_consec_corte,0) >= 2 AND n_impagos_consec_corte <= 3  THEN
	        LET v_etapa_cred_corte='2';
	      ELIF NVL(n_impagos_consec_corte,0) <= 1 THEN
	        LET v_etapa_cred_corte='1';
	      END IF;
	        
	        
	       
          /* --se mueve por optimizacion
            IF c_evalua_cc='X' THEN
                LET v_modelo_score='NO HIT';
            ELIF c_evalua_cc in('0','1','2','3','4') THEN
                LET v_modelo_score='HIT';
            END IF;*/
            
            select count(num_credito) into v_exist_seg from sd_clientes_clean_behavior 
            where fecha_reporte= (select max(fecha_reporte) from sd_clientes_clean_behavior) -- where num_credito= c_num_credito)
            and num_credito=c_num_credito 
            and status_bit is null;
            
            IF v_exist_seg>0 THEN 
                LET v_segmento='Clean';
            ELSE
                LET v_segmento='Dirty';
            END IF;
			
			SELECT nvl(numeric2,0) INTO v_cte_relevante
			FROM bdinteg:si_cliente
			WHERE numcte=c_numcte;
			
			IF v_relacion is null or v_relacion = '' THEN --optimizacion
				IF v_cte_relevante = 0 THEN 
					LET v_relacion=8;
				ELSE
					LET v_relacion=v_cte_relevante;
				END IF
			END IF;
			
	        
	        /*IF n_mop >0 THEN 
				LET v_indicador_cat=0;
			ELIF v_relacion <>8 THEN
				LET v_indicador_cat=0;
			ELIF n_antig_cred<=12  THEN
				LET v_indicador_cat=0;
			ELIF n_resc <>0 THEN
				LET v_indicador_cat=0;
			END IF;	*/
			
			 if dt_apertura >= mdy(month(dt_cierre_proc), '01',year(dt_cierre_proc))-1 UNITS YEAR and v_relacion =8 and n_impagos_consec=0 then 
				LET v_indicador_cat=1;  
			else 
				LET v_indicador_cat=0;
			end if
			
			
			SELECT limit 1 tasa_anual as tasarev, 
			cat as Catcuenta
			INTO v_tasa_fija, v_cat_cuenta
			FROM sd_info_edocta_calif WHERE NUM_CREDITO=c_num_credito
			AND fecha_emision=mdy(month(dt_cierre_proc), '20', year(dt_cierre_proc));	
			
			LET v_tasa_fija= v_tasa_fija/100;
		
			-- PAGO PARA NO GENERAR INTERESES
			SELECT NVL((CASE WHEN (NVL(sdo_cap_insoluto,0) < 0) THEN DECODE( 2,1, NVL(sdo_cap_insoluto,0),0)  
				ELSE NVL(sdo_cap_insoluto,0) +  NVL(ROUND((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2),0)  +
				CASE WHEN NVL(int_tra_no_exig,0) > 0 THEN
				NVL(int_tra_no_exig,0) - NVL((SELECT interes_debe FROM bdicred:"informix".sd_amortiza_credito WHERE a.num_credito = num_credito AND b.fecha = fecha_cuota),0)
				ELSE 0 END + (SELECT NVL (campo_trabajo1 ,0) FROM bdicred:"informix".sd_amortiza_credito
				WHERE a.empresa = empresa AND a.num_credito = num_credito AND b.fecha = fecha_cuota)end),0) d_pago_nogenarar_int 
				INTO d_pago_nogenarar_int
			from bdicred:"informix".sd_maecredcont a
				join bdicred:"informix".sd_maesdoshist b on (a.empresa = b.empresa and b.fecha =dt_corte
				and a.num_credito = b.num_credito)
				join bdinteg:"informix".si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal )
				where a.empresa = '001' and a.fecha = dt_cierre_proc and a.num_credito = c_num_credito;
				
			-- PAGO PARA NO GENERAR INTERESES T-1
			SELECT NVL((CASE WHEN (NVL(sdo_cap_insoluto,0) < 0) THEN DECODE( 2,1, NVL(sdo_cap_insoluto,0),0)  
				ELSE NVL(sdo_cap_insoluto,0) +  NVL(ROUND((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2),0)  +
				CASE WHEN NVL(int_tra_no_exig,0) > 0 THEN
				NVL(int_tra_no_exig,0) - NVL((SELECT interes_debe FROM bdicred:"informix".sd_amortiza_credito WHERE a.num_credito = num_credito AND b.fecha = fecha_cuota),0)
				ELSE 0 END + (SELECT NVL (campo_trabajo1 ,0) FROM bdicred:"informix".sd_amortiza_credito
				WHERE a.empresa = empresa AND a.num_credito = num_credito AND b.fecha = fecha_cuota)end),0) d_pago_nogint_inicio 
				INTO d_pago_nogint_inicio
			from bdicred:"informix".sd_maecredcont a
				join bdicred:"informix".sd_maesdoshist b on (a.empresa = b.empresa and b.fecha = (dt_corte - 1 units month)
				and a.num_credito = b.num_credito)
				join bdinteg:"informix".si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal )
				where a.empresa = '001' and a.fecha = (dt_ini_per_proc -1 units day) and a.num_credito = c_num_credito;
			
			
		
		 -- BEGIN;
			INSERT INTO sd_insumos_calif
			(fecha_cierre,num_credito,num_cliente, 
			alto, antecedentes_buro, antig_cliente, antig_credito, bajo, 
			bkatr, bloqueo, bloqueo_operativo, capital_ven_exigible, capital_vig_exigible,
			comision_apertura, comision_disposicion, consulta_sin_info, dias_incumplimiento, facturacion, 
			fecha_apertura, fecha_apertura_cte, fecha_consulta, fecha_corte, fecha_reestructura, 
			grupo_originacion, gveces1, gveces2, gveces3, 
			impagos_consecutivos, impagos_historicos, inactividad_13, int_moratorios, int_vencido_bal, 
			int_vencido_ord, interes_ven_exigible, interes_vencido, interes_vig_exigible, limite_credito, 
			limite_credito_corte, limite_credito_inicio, linea_autorizada, medio, meses_sostenido, 
			meses_vencido, monto_exigido, monto_exigido1, monto_exigido2, monto_exigido3, 
			monto_pagar_otros, monto_pagar_propio, mora, nombre_cliente, 
			num_cuenta_credisol, num_producto, pago_capital, pago_interes_ven, 
			pago_interes_vig, pago_minimo, pago_realizado, pago_realizado1, pago_realizado2, 
			pago_realizado3, pago_sostenido, porcentaje_pago, porcentaje_uso, reestructura, 
			saldo_cierre, saldo_cierre_credisol, saldo_corte, saldo_corte_credisol, saldo_corte1, 
			saldo_corte2, saldo_corte3, saldo_exigible, saldo_no_exigible, score_buro, 
			score_originacion, sin_consulta, status_cred, status_fin_mes, sucursal,
			tipo_producto,saldo_corte_credisol1,saldo_corte_credisol2,saldo_corte_credisol3,saldo_corte_credisol4,
            comision_cobranza, comisionexig_cobranza, saldo_corte_t, numero_cuenta_det, meses_primer_crdbco,
            meses_ult_atr_bk, veces_monto_bco_sistema, num_pagos_vencidos, intereses_ordinarios, 
            intereses_moratorios,tasa_contractual, numero_anios, intereses_etapa3, etapa_cred, capital_cierre, gastos_originacion,
            modelo_score,segmento,eficiencia, tasa_efectiva,impagos_consec_corte,etapa_cred_corte,impagos_hist_corte, num_cuenta_msi, num_tarjeta,
			catcontrato, relacion, cat_cuenta, indicadorcat, tasa_int_fija, meses,pagoexigepsi,pagongi,pagonginicio,comtotal,comtardio,
			saldo_corte_msi,saldo_corte_msi1,saldo_corte_msi2,saldo_corte_msi3,saldo_corte_msi4,saldorev,interesrev,saldopmsi,saldopci,interespci,
			Promedio_MSI_contratados,Promedio_MSI_amort,Saldo_prom_MSI,MSI_hist,MSI_act,saldo_cierre_msi,intereses_etapa1,intereses_etapa2,cod_postal,rfc,curp
			,impago0_corte, impago1_corte, impago2_corte, impago3_corte, pago_cierre, pago_cierre1, pago_cierre2, 
			pago_cierre3, impago0, impago1, impago2, impago3)
			VALUES
			(dt_cierre_proc, c_num_credito, c_numcte, 
			n_alto, c_antecedentes_buro, n_antig_cte, n_antig_cred, n_bajo, 
			n_bkatr, n_bloq, n_bloq_op, d_capital_ven_exigible, d_capital_vig_exigible,
			NVL(d_comision_apert,0), NVL(d_comision_disp,0), n_consulta_sin_info, NVL(n_mop,0), c_facturacion, 
			dt_apertura, dt_ap_cte, dt_ultcons_varcc, dt_corte, dt_fec_reest, 
			NVL(c_gpo_originacion,''), n_gveces_1, n_gveces_2, n_gveces_3, 
			NVL(n_impagos_consec,0), n_imp_hist_6m, n_sin_mov, NVL(d_moratorios,0), NVL(d_intvenc_bal,0), 
			NVL(d_intvenc_ord,0), NVL(d_int_venc_exig_corte,0), NVL(d_int_venc_exig_cierre,0), NVL(v_intereses_ordinarios,0), NVL(d_limite_credito,0), 
			NVL(d_limite_credito_corte,0), NVL(d_limite_credito_inicio,0), NVL(d_limite_credito_orig,0), n_medio, n_meses_pagosost, 
			NVL(n_meses_venc,0), NVL(d_monto_exigido,0), NVL(d_monto_exigido1,0), NVL(d_monto_exigido2,0), NVL(d_monto_exigido3,0), 
			NVL(d_monto_pagar_otros,0), NVL(d_monto_pagar_propio,0), NVL(n_moras,0), c_nom_cte,
			NVL(c_cta_credisol,''), c_producto, NVL(d_pago_capital,0), NVL(d_pago_int_venc,0), 
			NVL(n_pago_int_vig,0), NVL(d_pago_minimo,0), NVL(d_pago_realizado,0), NVL(d_pago_realizado_1,0), NVL(d_pago_realizado_2,0), 
			NVL(d_pago_realizado_3,0), n_pago_sost, NVL(d_porcentaje_pago,0), NVL(d_porcentaje_uso,0), n_resc, 
			NVL(d_saldo_cierre,0), NVL(d_saldo_cierre_credisol,0), NVL(d_saldo_corte,0), NVL(d_saldo_corte_credisol,0), NVL(d_saldo_corte1,0), 
			NVL(d_saldo_corte2,0), NVL(d_saldo_corte3,0), NVL(d_saldo_exigible,0), NVL(d_saldo_no_exigible,0), NVL(n_scoreburo,0), 
			NVL(n_scoreotor,0), n_sin_consulta, c_status_corte, c_status_mes_reporte, c_sucursal,
			c_nombre_prod,NVL(d_sdo_corte_cred1,0),NVL(d_sdo_corte_cred2,0),NVL(d_sdo_corte_cred3,0),
			NVL(d_sdo_corte_cred4,0),
            NVL(d_comision_cobranza,0), NVL(d_comisionexig_cobranza, 0), NVL(d_saldo_corte_t,0), v_numero_cuenta_det,v_meses_primer_crdbco,
            v_meses_ult_atr_bk, v_veces_monto_bco_sist, v_num_pagos_vencidos, v_intereses_ordinarios, 
            v_intereses_moratorios, v_tasa_interes, v_numero_anios,v_intereses_etapa3,v_etapa_cred,v_capital_cierre, NVL(v_gastos_originacion,0), 
            v_modelo_score,v_segmento,v_eficiencia, v_tasa_efectiva,NVL(n_impagos_consec_corte,0),v_etapa_cred_corte,n_imp_hist_6m_corte, v_num_cta_msi, v_numtarjeta,
			v_catcontrato,v_relacion,v_cat_cuenta,v_indicador_cat,v_tasa_fija,v_meses,v_pagoexigepsi,NVL(d_pago_nogenarar_int,0),NVL(d_pago_nogint_inicio,0),nvl(v_comtotal,0), v_comtardio,
			NVL(v_sdo_corte_msi,0),NVL(v_sdo_corte_msi_1,0),NVL(v_sdo_corte_msi_2,0),NVL(v_sdo_corte_msi_3,0),NVL(v_sdo_corte_msi_4,0),NVL(v_saldo_rev,0),NVL(v_interes_rev,0),NVL(v_saldopmsi,0),v_saldopci,v_interesespci,
			NVL(v_Promedio_MSI_contratados,0),NVL(v_Promedio_MSI_amort,0),NVL(v_Saldo_prom_MSI,0),NVL(v_MSI_hist,0),NVL(v_MSI_act,0),NVL(v_saldo_cierre_msi,0),v_intereses_etapa1,v_intereses_etapa2,v_cod_postal,v_rfc,v_curp,
			v_impago0_corte, v_impago1_corte, v_impago2_corte, v_impago3_corte, NVL(v_pago_cierre,0), NVL(v_pago_cierre_1,0), NVL(v_pago_cierre_2,0), 
			NVL(v_pago_cierre_3,0), v_impago0, v_impago1, v_impago2, v_impago3 );

		  --COMMIT;
		  
			LET contador_commit = contador_commit  + 1;
			
			IF (contador_commit >= 500) THEN
				COMMIT WORK;
				LET contador_commit = 0; 
				BEGIN WORK;
			END IF;
			
    END FOREACH
	
  IF val_trans_Commit = -1 THEN
     COMMIT WORK;
  END IF;
  LET val_trans_Commit = 0;	

SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc 
  FROM sysmaster:sysshmvals;
  
LET cMensajeRet = 'Proceso Insumos Calificacion TDC '|| pEjecucion ||' Ok';
LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc;	
	
RETURN vcodret,  cMensajeRet,cMensajeRet2;

END;
END PROCEDURE;