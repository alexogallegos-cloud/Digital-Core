CREATE PROCEDURE "informix".sp_grabarreversopagosmasivos(pFolio CHAR(16))

RETURNING  CHAR(6), CHAR(100);

--definicion de variables
DEFINE cCodRet 			 		CHAR(6);
DEFINE cMensaje                 CHAR(100) ;
DEFINE iSqlErr			 		INTEGER;
DEFINE cCredito					CHAR(20);
DEFINE vFecha                   DATE;
DEFINE dHora                    CHAR(8);
DEFINE cEmpresa                 CHAR(3);
DEFINE cReverso                 CHAR(1);  
DEFINE cCodRetObProd            CHAR(6);
DEFINE cNumProdObProd           CHAR(4);
DEFINE cDescripcionObProd       CHAR(50);
DEFINE cCodProd                 CHAR(1);
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

	
--Inicializacion de variables
LET cCodRet   = '000000';
LET cMensaje =  'Proceso Exitoso!!!';
LET iSqlErr	  = 0;		
LET cCredito = '';
LET vFecha   = date(1);
LET dHora    = '';
LET cEmpresa = "001";
LET cReverso =  "";
LET cCodRetObProd               = "";
LET cNumProdObProd              = "";
LET cDescripcionObProd          = "";
LET cCodProd                    = "";

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


---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL PAGO
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
	
	--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_grabarreversopagosmasivos.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	
    /*
	SELECT fecha_hoy
	INTO vfecha
	FROM "informix".sd_fechas;
	*/
	
		---PARA OBTENER LA FECHA Y LA HORA ESACTA PARA PONERLA EN LA INSERCCION EN UN SP..VISUALAIZER
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  
	INTO vfecha
	FROM sysmaster:"informix".sysshmvals;
	
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
	INTO dHora
	FROM sysmaster:"informix".sysshmvals;	

	SELECT LIMIT 1 num_credito, reverso
	INTO cCredito, cReverso
	FROM "informix".sd_bitacora_pagos
	--WHERE fecha_mov = vfecha
	WHERE fecha_pago = vfecha
      AND folio = pFolio;
	   
	  
	IF cReverso =  "S" THEN
		LET cCodRet= '100000';
        RETURN cCodRet, 'El pago del folio ya fue reversado anteriormente';
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

            CALL "informix".reversion ('001', "9250", "pagmas", pFolio, "A") Returning cCodRet;	

                IF cCodRet = -284 THEN --El pago del folio ya fue reversado anteriormente
                    LET cCodRet= '100000';
                    RETURN cCodRet, 'El pago del folio ya fue reversado anteriormente';
				elif cCodRet = "431" THEN -- PAGO NO ES EL ULTIMO REVERSA EN ORDEN	 
					LET cCodRet= '200000';
					RETURN cCodRet, 'El crédito del folio no es el mas actual';
				elif cCodRet   = '000'  THEN
					LET cCodRet   = '000000';
					
					--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO DESPUES DEL PAGO
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

										
				ELSE
					LET cCodRet= '400000';
					RETURN cCodRet, 'Error en el reverso del pago';
				
                END IF;
				
				UPDATE "informix".sd_bitacora_pagos 
				SET 
					fecha_reverso = vfecha,
					hora_reverso = dHora,
					resultado =  "OK",
					ejecutar =  "S",
					reverso = "S",
					saldo_ante_rev = csg_cap_vig,
					saldo_post_rev = csg2_cap_vig
				WHERE folio = pFolio; --Actualiza a reversado el estatus del pago masivo.
				
				UPDATE "informix".sd_bitacorapagos SET status = "S" WHERE folio = pFolio; --Actualiza a reversado el estatus del pago masivo.


        ELSE 

            LET cCodRet= '300000';
			LET cMensaje = 'Numero de crédito no se encuentra en la bitacora de pagos ';
        END IF;       

	RETURN cCodRet,cMensaje;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: EJECUTA LA REVERSION DE LOS PAGOS SOLICITADOS', 
'AUTOR: Hector MAnuel Bojorquez Ruelas',
'FECHA: MAYO 2011',
'VERSION: 20110531.1702',
'BD: BDICRED',
'DESCRIPCION: Se agrega update en la tabla bdicred:sd_bitacorapagos', 
'AUTOR: Mireya Reyes',
'FECHA: Enero 2014',
'VERSION: 20140107.1550',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_obtenereversopagosman(pFolio CHAR(16))

RETURNING CHAR(5), CHAR(80), CHAR(20),CHAR(20), CHAR(40) , CHAR(20),CHAR(150) , DECIMAL(18,2),DECIMAL (18,2), DECIMAL(18,2),DECIMAL(18,2),
DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2), CHAR(50), CHAR(50);

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
DEFINE cImporte_pago		DECIMAL(18,2);
DEFINE cCapital_vigente	DECIMAL(18,2);
DEFINE cCapital_transitorio DECIMAL(18,2);
DEFINE cCapital_vencido DECIMAL(18,2);
DEFINE cCapital_vencido_no_exigible DECIMAL(18,2);
DEFINE cInteres_vigente DECIMAL(18,2);
DEFINE cIva_de_interes_vigente DECIMAL(18,2);
DEFINE cInteres_vencido DECIMAL(18,2);
DEFINE cIva_de_interes_vencido DECIMAL(18,2);
DEFINE cInteres_moratorioBase DECIMAL(18,2);
DEFINE cInteres_moratorioCopete DECIMAL(18,2);
DEFINE cIva_interesmoratorioBase	 DECIMAL(18,2);
DEFINE cIva_interesmoratorioCopete DECIMAL(18,2);
DEFINE cCapital_Total	DECIMAL(18,2);
DEFINE cConcepto		CHAR(50);
DEFINE cDescripcion     CHAR(50);
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
LET cImporte_pago		 = 0;
LET cCapital_vigente	 = 0;
LET cCapital_transitorio  = 0;
LET cCapital_vencido  = 0;
LET cCapital_vencido_no_exigible  = 0;
LET cInteres_vigente  = 0;
LET cIva_de_interes_vigente  = 0;
LET cInteres_vencido  = 0;
LET cIva_de_interes_vencido = 0;
LET cInteres_moratorioBase  = 0;
LET cInteres_moratorioCopete = 0;
LET cIva_interesmoratorioBase	  = 0;
LET cIva_interesmoratorioBase = 0;
LET cCapital_Total	 = 0;
LET cConcepto		='';
LET cDescripcion   = '';

	--set debug file to "/tmp/sp_Obtienereversopagosman.out";
	--trace on;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    BEGIN
		--MANEJO DE ERRRORES
		ON EXCEPTION SET vSqlErr, vIsamErr
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;
				RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','','', '', '','', '', '','', '','','','','';
			END IF;
		END EXCEPTION;

		IF NOT EXISTS( SELECT num_credito FROM "informix".sd_bitacorapagos WHERE folio = pFolio) THEN              --El folio recibido no se trata de un pago manual
			LET vCodRet= '20000';
			RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','','', '', '','', '', '','', '','','','','';
		END IF;

		IF EXISTS ( SELECT status FROM "informix".sd_bitacorapagos WHERE folio = pFolio AND status = 'R') THEN
			LET vCodRet= '30000';
			RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','','', '', '','', '', '','', '','','','','';			
		END IF;

		--VALIDACION PARA REVERSAR PAGO MANUAL

		SELECT Limit 1 trim(num_credito)
		INTO cNumCred
		FROM "informix".sd_movdia
		WHERE folio_suc = pFolio
		AND codigo_ref= '1';
		
		
		IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'tmp1') THEN
			DROP TABLE tmp1;
		END IF;

		IF cNumCred IS NULL THEN
			SELECT Limit 1 trim(num_credito)
			INTO cNumCred
			FROM "informix".sd_movdiacrd
			WHERE folio_suc = pFolio
			AND codigo_ref= '1';
			
			SELECT folio_suc, fecha_mov,hora_mov		
			FROM  "informix".sd_movdiacrd
			WHERE num_credito = cNumCred
			AND reversado <> 'S'
			ORDER BY fecha_mov DESC, hora_mov DESC
			INTO temp tmp1;
			
		ELSE
			SELECT folio_suc, fecha_mov,hora_mov		
			FROM  "informix".sd_movdia
			WHERE num_credito = cNumCred
			AND reversado <> 'S'
			ORDER BY fecha_mov DESC, hora_mov DESC
			INTO temp tmp1;
		
        END IF;
		
		SELECT  FIRST  1 trim(folio_suc)
		INTO cFolio
		FROM  tmp1;		

		DROP TABLE tmp1;

		IF  cFolio <> pFolio THEN            --El folio recibido no es el ultimo movimiento
			LET vCodRet= '10000';
			RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','','', '', '','', '', '','', '','','','','';
		END IF;		

		CALL "informix".sp_consulta_datos_general('001', '', cNumCred,'','','','')
		RETURNING cCodigo_retorno, cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente;

		FOREACH

			SELECT importe_pago, capital_vigente, capital_transitorio, capital_vencido, capital_vencido_noexigible,capital_total, interes_vigente, iva_interesvigente, 
					interes_vencido, iva_interesvencido, interes_moratorio_base, interes_moratorio_copete,iva_interesmoratoriobase, iva_interesmoratoriocopete,concepto_mov, descripcion_pago
			INTO cImporte_pago, cCapital_vigente, cCapital_transitorio, cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total, cInteres_vigente, cIva_de_interes_vigente, 
				cInteres_vencido, cIva_de_interes_vencido, cInteres_moratorioBase, cInteres_moratorioCopete, cIva_interesmoratorioBase, cIva_interesmoratorioCopete,cConcepto, cDescripcion
			FROM "informix".sd_bitacorapagos
			WHERE folio= pFolio	
			AND secuencia IN (1,2)
			AND status = 'A'
			ORDER BY secuencia 

			RETURN vCodRet,cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente, cImporte_pago, cCapital_vigente, cCapital_transitorio, 
					cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total ,cInteres_vigente, cIva_de_interes_vigente, 
					cInteres_vencido, cIva_de_interes_vencido, cInteres_moratorioBase, cInteres_moratorioCopete,cIva_interesmoratorioBase, cIva_interesmoratorioCopete,cConcepto, cDescripcion WITH RESUME;

		END FOREACH
		
    END
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE DATOS GENERALES, DETALLE DE APLICACION Y SALDOS NUEVOS',
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'FECHA: ENERO 2010',
'VERSION: 20100122.1402',
'BD: BDICRED',
'Modificado por: Mohamed Carreón, Descripción: se agregó el filtro del numero del prodcto y se adecuaron las validaciones para prestamo personal, 20100705.1140',
'Modificacion: Se agrega consulta en la tabla sd_movdiacrd, cuando no encontrar numcte en la tabla sd_movdia. ',
'Modifico: Mireya Gpe. Reyes Vargas',
'Folio: 1395 Condonacion de intereses',
'BD: bdicred',
'Fecha: 07-enero-2014',
'version: 20140107.1721',
'Modificacion: Se modifica el la variable cConcepto para aumentar la cantidad de caracteres a 50 para que muestre el concepto completo.',
'Modifico: Mario Gamaliel Olivo Urias',
'Folio: 1395 Condonacion de intereses',
'BD: bdicred',
'Fecha: 21-Febrero-2014',
'version: 20140221.1017';

create procedure "informix".abono_cred(pEmpresa    CHAR(3),
			     pCredito    CHAR(20),
			     pSucursal   CHAR(4),
			     pUsuario    CHAR(8),
			     pTran       CHAR(4),
			     pMonto      DECIMAL(14,2),
			     pFolio      CHAR(16),
			     pTarjeta    CHAR(20),
			     pMontoDls   DECIMAL(14,2),
			     pTpCambio   DECIMAL(14,6),
			     pFecha      DATE,
			     pReferencia CHAR(40),
			     pTpMov      CHAR(1),
	  		     pRfcComer    VARCHAR(20),
			     pRef23       VARCHAR(23))

   RETURNING CHAR(5);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vSucCred	      CHAR(4);
   DEFINE vIvaSuc	      DECIMAL(5,3);
   DEFINE vIvaBase	      DECIMAL(5,3);
   DEFINE vTpTran             CHAR(2);
   DEFINE vTpTranRel          CHAR(2);
   DEFINE vTranRelac          CHAR(4);
   DEFINE vTranParalela       CHAR(4);
   DEFINE vTranNro	      SMALLINT;
   DEFINE vDiasRet	      SMALLINT;
   DEFINE vMensaje	      CHAR(1);
   DEFINE vProducto	      CHAR(4);
   DEFINE vTranRetuvo	      CHAR(4);
   DEFINE vDivisa             CHAR(2);
   DEFINE vMtoRet	      DECIMAL(14,2);
   DEFINE vTran               CHAR(4);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;



--  SET LOCK MODE TO WAIT 10;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vTranNro   = pTran;
   LET vMtoRet    = 0;
   LET vTRan      = "";

   LET pTran = vTranNro;
   IF LENGTH(pTran) < 4 THEN
       LET pTran = LPAD(TRIM(pTran),4,"6");
   END IF

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   -- ******************************
   -- Extrae Parametro de IVA Base *
   -- ******************************
   SELECT valor INTO vIvaBase
     FROM bdinteg:si_param
    WHERE empresa = pEmpresa
      AND cod_param = 47;

   IF vIvaBase IS NULL THEN
	LET vIvaBase = 0;
   END IF

   -- **************************************************
   -- Extrae informacion de Sucursal e Iva del Credito *
   -- **************************************************
   SELECT a.sucursal, a.iva, b.num_producto, b.divisa
     INTO vSucCred, vIvaSuc, vProducto, vDivisa
     FROM bdinteg:si_sucursales a, sd_maecred b
    WHERE b.empresa = pEmpresa
      AND b.num_credito = pCredito
      AND a.empresa = b.empresa
      AND a.sucursal = b.sucursal;

   -- ***************************************
   -- Extrae informacion de la Transaccion  *
   -- ***************************************

   SELECT tipo_tran, NVL(tran_relac,"0000"), NVL(trancivaesp,"0000"),
	  NVL(dias_ret,0)
     INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
     FROM bdinteg:si_transacc
    WHERE empresa = pEmpresa
      AND sistema = "06"
      AND numero = pTran;

   IF LENGTH(vTranRelac) = 0 THEN
	LET vTranRelac = "0000";
   END IF

   IF LENGTH(vTranParalela) = 0 THEN
	LET vTranParalela = "0000";
   END IF


   -- **************************************************************
   -- Determina la transaccion a utilizar por clasificacion de IVA *
   -- **************************************************************
   IF vIvaSuc <> vIvaBase AND vTranParalela <> "0000" THEN
	LET pTran = vTranParalela;
   END IF

   -- ******************************************************************
   -- Determina si es reversion y busca los valores para la aplicacion *
   -- ******************************************************************
   IF pTpMov = "R" THEN
	-- Extrae Datos de la Transaccion de Reversion
	SELECT tipo_tran, NVL(tran_relac,"0000"), NVL(trancivaesp,"0000"),
               NVL(dias_ret,0)
   	  INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
     	  FROM bdinteg:si_transacc
   	 WHERE empresa = pEmpresa
      	   AND sistema = "06"
      	   AND numero = pTran;

   	IF LENGTH(vTranRelac) = 0 THEN
        	LET vTranRelac = "0000";
  	END IF

   	IF LENGTH(vTranParalela) = 0 THEN
        	LET vTranParalela = "0000";
  	 END IF

    if (pTran in ('6876','6874','6875')) then let vTranRelac = pTran; end if;

        -- Extrae Datos de la Transaccion a Reversar
	IF vTranRelac <> "0000" THEN
		LET vTran = vTranRelac;
        	SELECT tipo_tran, NVL(tran_relac,"0000"),
		       NVL(trancivaesp,"0000"), NVL(dias_ret,0)
          	  INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
          	  FROM bdinteg:si_transacc
         	 WHERE empresa = pEmpresa
           	   AND sistema = "06"
           	   AND numero = vTran; --MEL

        	IF LENGTH(vTranRelac) = 0 THEN
                	LET vTranRelac = "0000";
        	END IF

        	IF LENGTH(vTranParalela) = 0 THEN
                	LET vTranParalela = "0000";
         	END IF
        ELSE
           LET vTran = "";
	END IF

   END IF

   -- Libera Retencion por Reversion
   IF vTpTran >= "20" AND vTpTran <= "29" AND pTpMov = "R" THEN

		SELECT monto
		  INTO vMtoRet
		  FROM sd_maeretenido
		 WHERE empresa = pEmpresa
		   AND num_credito = pCredito
		   AND folio_suc = pFOlio
		   AND estatus = "P"	
		   AND transacc = vTran;

		  IF vMtoRet IS NULL THEN
			   SELECT monto
			   INTO   vMtoRet
			   FROM   sd_maeretenido
			   WHERE  empresa = pEmpresa
			   AND    num_credito = pCredito
			   AND    folio_suc = pFOlio
			   AND    estatus = "P"
			   AND    transacc = pTran;
		  END IF;
	
		IF vMtoRet IS NULL THEN LET vMtoRet = 0; end if;
		
		-- SE VALIDA QUE SE AFECTE LA MAERETENIDO PARA PODER ACTUALIZAR SU RETENIDO CORRESPONDIENTE PIQV
		IF vMtoRet > 0 THEN
		        UPDATE sd_maeretenido
				   SET estatus = "S"
				 WHERE empresa = pEmpresa
				   AND num_credito = pCredito
				   AND folio_suc = pFOlio
				   AND estatus = "P"	
				   AND transacc IN(pTran,vTran);

					let pFOlio = pFOlio;
					let pTran = pTran;
					
				IF DBINFO("sqlca.sqlerrd2") > 0 THEN
					UPDATE sd_maesdos SET sdo_retenido = sdo_retenido - vMtoRet
					 WHERE empresa = pEmpresa
					   AND num_credito = pCredito;					
		        END IF;				
		END IF;		
		
        UPDATE sd_movhis
           SET reversado = "S"
         WHERE empresa = pEmpresa
           AND num_credito = pCredito
           AND folio_suc = pFOlio
           AND transacc_suc = vTran;

            let pFOlio = pFOlio;
            let pTran = pTran;

        UPDATE sd_movdia
           SET reversado = "S"
         WHERE empresa = pEmpresa
           AND num_credito = pCredito
           AND folio_suc = pFOlio
           AND transacc_suc IN(pTran,vTran);

	   -- Reversa Movimientos sin retencion
   ELIF vTpTran >= "00" AND vTpTran <= "19" AND pTpMov = "R" THEN

        UPDATE sd_maesdos SET sdo_capital = sdo_capital - pMonto,
                              sdo_cap_insoluto = sdo_cap_insoluto - pMonto,
                              mto_ministra_cap = mto_ministra_cap - pMonto,
                              cargos_mes_cap   = cargos_mes_cap - pMonto
         WHERE empresa = pEmpresa
           AND num_credito = pCredito;

let pTran = pTran;
	UPDATE sd_movdia
	   SET reversado = "S"
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFolio
	   AND transacc_suc IN(pTran,vTran);
	   --AND transacc_suc = pTran;

   ELIF VTpTran >= "00" AND vTpTran <= "19" AND pTpMov <> "R" THEN
	UPDATE sd_maesdos SET sdo_capital = sdo_capital - pMonto,
			      sdo_cap_insoluto = sdo_cap_insoluto - pMonto,
		              mto_ministra_cap = mto_ministra_cap - pMonto,
          		      cargos_mes_cap   = cargos_mes_cap - pMonto
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito;

   END IF

   -- **************************
   -- Aplica Movimiento Diario *
   -- **************************
   IF pTpMov <> "R" THEN
   	EXECUTE PROCEDURE genmov_tc(pEmpresa, pCredito, vProducto,
                               	    pFecha, pMonto, pFolio, pSucursal,
                                    vDivisa, pTran, pTarjeta, pReferencia,
			            pTpCambio, pMontoDls, pUsuario, vSucCred,
				      pRfcComer,pRef23)
   	INTO cod_ret, vMensaje;
   	IF cod_ret <> "000" THEN
		RETURN cod_ret;
   	END IF
   END IF

   -- ************************************************
   -- Ejecuta Aplicacion de Transaccion Relacionada  *
   -- ************************************************
   IF vTranRelac IS NULL THEN
	LET vTranRelac = "0000";
   END IF

   IF vTranRelac <> "0000" THEN
	SELECT tipo_tran INTO vTpTranRel
	  FROM bdinteg:si_transacc
	 WHERE empresa = pEmpresa
	   AND sistema = "06"
	   AND numero = vTranRelac;

	IF pTpMov = "R" THEN
		SELECT monto INTO pMonto
	          FROM sd_movdia
		 WHERE empresa = pEmpresa
		   AND num_credito = pCredito
		   AND folio_suc = pFolio
		   AND transacc_suc = vTranRelac;
	END IF

let vTranRelac = vTranRelac;
let pFolio = pFolio;
let pMonto = pMonto;

        EXECUTE PROCEDURE abono_cred(pEmpresa, pCredito, pSucursal,
                                     pUsuario,vTranRelac, pMonto,
                                     pFolio, pTarjeta, pMontoDls,
                                     pTpCambio, pFecha, pReferencia,"R",
					       pRfcComer,pRef23)

	INTO cod_ret;

   END IF


   RETURN cod_ret;


END PROCEDURE
DOCUMENT
'Esta funcion se encarga de realizar los movimientos de abono y reversion ',
'relacionados a la tarjeta de credito',
'AUTOR : Procesaminto Interactivo S.A.',
'FECHA : 23/01/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

CREATE PROCEDURE "informix".tc_concilia_credito_especial (pEmpresa CHAR(03), pTransacc CHAR(04))
		--  Fecha 		 8 caracter MMDDYYYY
RETURNING CHAR(100);

	-- *************************************************************************
	-- *                      DEFINICION DE VARIABLES                          *
	-- *************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	--------------------------------------------------------
	--	Varibale de Control de Fecha Proceso
	--------------------------------------------------------
	DEFINE vFechaHoy	DATE;
	--------------------------------------------------------
	--	Varibale Proceso Conciliacion
	--------------------------------------------------------
	DEFINE v_cuenta				CHAR(20);
	DEFINE v_tarjeta				CHAR(20);
	DEFINE v_sucursal				CHAR(4);
	DEFINE v_usuario				CHAR(8);

	DEFINE v_tp_movto				CHAR(1);
	DEFINE v_tran_central			VARCHAR(4);
	DEFINE v_folio_mov			CHAR(16);
	DEFINE v_monto				DECIMAL(14,2);
	DEFINE v_monto2				DECIMAL(14,2);
	DEFINE v_retenido				DECIMAL(14,2);

	DEFINE v_moneda				CHAR(2);
	DEFINE v_referencia			VARCHAR	(40);
	DEFINE v_folio_original		VARCHAR	(16);
	DEFINE v_rfc_comer			VARCHAR	(20);
	DEFINE v_referencia23 		VARCHAR	(23);

	DEFINE v_archivo				VARCHAR(30);
	DEFINE v_consecutivo			INTEGER;
	DEFINE v_fecha				DATE;
	DEFINE v_tabla				VARCHAR	(40);


	DEFINE vBandera	      	CHAR(1);
	DEFINE v_NumTransacc	VARCHAR(4);
	DEFINE v_MontoConcilia	DECIMAL(14,2);
	DEFINE v_FormaAplica	CHAR(1);

	--------------------------------------------------------
	--	Variables ley de Transparencia
	--------------------------------------------------------

	DEFINE v_transparencia		VARCHAR(40);
	DEFINE v_divisa         	CHAR(3);
	DEFINE v_monto_divisa   	DECIMAL(12,2);
	DEFINE v_num_cajero     	CHAR(14);
	DEFINE v_forma_pago     	CHAR(1);
	DEFINE v_desc_forma_pago  VARCHAR(8);


	DEFINE v_codigo_fun				CHAR(3);
	DEFINE v_codigo_ref				INT;

  --//Variables para ubicar folio diferente transaccion en linea
    DEFINE vtamanio      SMALLINT;
    DEFINE vt_indicador  CHAR(1);
    DEFINE vt_newfolio   CHAR(16);
    DEFINE vt_folsucorig CHAR(16);
    DEFINE vg_estatus    VARCHAR(5);
    DEFINE v_MontoConcilia_sdofavor   DECIMAL(14,2);

    DEFINE vCantReg            INTEGER;
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------
	LET cod_ret       = "000";
	LET sql_err       = "";
	--------------------------------------------------------
	--	Varibale de Control de Fecha Proceso
	--------------------------------------------------------
	LET vFechaHoy	= " ";
	--------------------------------------------------------
	--	Varibale Proceso Conciliacion
	--------------------------------------------------------
	LET v_cuenta		= "";
	LET v_sucursal		= "";
	LET v_usuario		= "";

	LET v_tp_movto		= "";
	LET v_tran_central	= "";
	LET v_folio_mov		= "";
	LET v_monto			= 0;
	LET v_monto2        = 0;

	LET v_moneda			= "";
	LET v_referencia		= "";
	LET v_folio_original	= "";
	LET v_rfc_comer			= "";
	LET v_referencia23 		= "";

	LET v_archivo		= "";
	LET v_consecutivo	= 0;
	LET v_fecha			= " ";
	LET v_tabla			= "";


	LET vBandera	    = "C";
	LET v_NumTransacc	= "";
	LET v_MontoConcilia	= 0;
	LET v_FormaAplica	= "";
	--------------------------------------------------------
	--	Variables ley de Transparencia
	--------------------------------------------------------

	LET v_transparencia 			 = "";
	LET v_divisa               = "";
	LET v_monto_divisa         = 0;
	LET v_num_cajero           = "";
	LET v_forma_pago           = "";
	LET v_desc_forma_pago      = "";

	LET v_codigo_fun				= "";
	LET v_codigo_ref				= 0;
    LET v_MontoConcilia_sdofavor	 = 0;
    let vCantReg = 0;
    

BEGIN


   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;

-- SET DEBUG FILE TO "tc_concilia_credito";
-- TRACE ON;

  SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                 	INICA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Obtengo parametros
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SELECT fecha_hoy 		INTO vFechaHoy
	FROM bdinteg:si_fechas WHERE empresa = pEmpresa;

	LET v_divisa               = "";
	LET v_monto_divisa         = 0;
	LET v_num_cajero           = "";
	LET v_forma_pago           = "";

	FOREACH WITH HOLD
        select num_credito, folio_suc, monto, num_tarjeta, referencia
          into v_cuenta, v_folio_mov, v_monto, v_tarjeta, v_referencia
          from bdicred:sd_carga_pos    
         where indicador = '0'
--           and num_credito = '600002921036'

           select num_tarjeta
             into v_tarjeta
             from bdicred:sd_tarjeta
            where empresa = pEmpresa
              and num_tarjeta[1,15] = v_tarjeta[1,15];

           select sdo_retenido
             into v_retenido
             from bdicred:Sd_maesdos
            where empresa = pEmpresa
              and num_credito = v_cuenta;


        begin work;
		
	   update bdicred:sd_carga_pos    
          set indicador = '1'
        where num_credito = v_cuenta
          and folio_suc = v_folio_mov
          and monto = v_monto
          and num_tarjeta[1,15] = v_tarjeta[1,15];

         let vCantReg = 0;
		 
         SELECT SUM(monto) 
		   INTO v_monto2
           FROM bdicred:sd_maeretenido
          WHERE empresa = pEmpresa
            AND num_credito = v_cuenta
            AND folio_suc = v_folio_mov
            and estatus = "P"
            AND transacc = pTransacc;
			
			IF v_monto2 IS NULL THEN
			   LET v_monto2 = 0;
            END IF;	
		 
         UPDATE bdicred:sd_maeretenido SET estatus = "L"
          WHERE empresa = pEmpresa
            AND num_credito = v_cuenta
            AND folio_suc = v_folio_mov
            and estatus = "P"
            AND transacc = pTransacc;
            
             LET vCantReg = DBINFO("sqlca.sqlerrd2");

             if ( vCantReg <= 0 ) then let v_retenido = 0; end if;
             let v_folio_mov = substr(v_folio_mov,1,9)||'2'||substr(v_folio_mov,11);

			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Executa SPL de conciliacion de credito
			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		  	EXECUTE PROCEDURE bdicred:conciliatc
                  (
                  	pEmpresa, 		v_tarjeta, 		'9290', 		'sysconau',
                   	'C',		pTransacc,  v_folio_mov,    	v_monto,
                   	'01',  		v_referencia,   '000000000000000', 	'A',
                   	'', 	'')
            INTO cod_ret, vBandera;

            if ( cod_ret <> '000') then
                rollback work;
                continue FOREACH;
--                RETURN cod_ret||" tarjeta: "||v_tarjeta||" monto: "||v_monto||" folio: "||v_folio_mov;
            End if;
            

            if ( v_retenido is null or v_retenido < 0) then let v_retenido = 0; end if;

            if ( v_retenido < v_monto ) then
               let v_monto = v_retenido;
            end if;

			IF vCantReg > 0 THEN -- SE VALIDA QUE SOLO ACTUALICE EL SALDO RETENIDO SI HAY RETENIDOS PENDIENTES PIQV
				update bdicred:Sd_maesdos set sdo_retenido = sdo_retenido - v_monto2
				 where empresa = pEmpresa
				   and num_credito = v_cuenta;
		    END IF;

      commit work;

	END FOREACH;

	LET cod_ret = "000";
	
	RETURN cod_ret;
-- ****************************************************************************
-- *                 FINALIZA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
END;

END PROCEDURE;