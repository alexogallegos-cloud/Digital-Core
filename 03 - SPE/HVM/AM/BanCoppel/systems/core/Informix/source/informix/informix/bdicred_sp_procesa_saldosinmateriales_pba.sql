CREATE PROCEDURE "informix".sp_procesa_saldosinmateriales_pba (pEmpresa CHAR(3) )

RETURNING CHAR(5),     -- Codigo de Retorno
          CHAR(80);   -- Mensaje de retorno
	---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cCodRetRev		CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE cSucursal				CHAR(4);
DEFINE cNumcte				    CHAR(20);
DEFINE cNumCred				    CHAR(20);
DEFINE cCodProd			    	CHAR(1);
DEFINE iCompromiso				INTEGER;
DEFINE iFky_estatus             INTEGER;
DEFINE iFallecido               INTEGER;
DEFINE iResultado               INTEGER;
DEFINE cComentario              CHAR(250);
DEFINE mTot_liquidacion			MONEY(18,2);
DEFINE cCodRetCan				CHAR(5);
DEFINE cFolioSucCan				CHAR(16);

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
DEFINE csg_codigo_ret			CHAR(6);
DEFINE csg_mensaje_ret			CHAR(80);
DEFINE csg_num_credito			CHAR(20);
DEFINE csg_cod_tipcred			CHAR(2);
DEFINE cStatus					CHAR(2);
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
DEFINE csg_dMoraBase        DECIMAL(18,2);
DEFINE csg_dMoraCopete      DECIMAL(18,2);
DEFINE csg_dIvamoraBase     DECIMAL(18,2);
DEFINE csg_dIvaMoraCopete   DECIMAL(18,2);

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE principal
DEFINE cLiqCodRet			CHAR(5);
DEFINE pri_Remanente			MONEY(14,2);
DEFINE pri_IntMoratorio			MONEY(14,2);
DEFINE pri_IntVencido			MONEY(14,2);
DEFINE pri_CapVencido			MONEY(14,2);
DEFINE pri_IntVigente			MONEY(14,2);
DEFINE pri_CapVigente			MONEY(14,2);
DEFINE pri_Impuesto				MONEY(14,2);
DEFINE pri_Comisiones			MONEY(14,2);
DEFINE pri_Seguro				MONEY(14,2);

--VARIABLES DEL sp_principal_pp
DEFINE pp_cod_ret           CHAR(5);
DEFINE pp_mens_ret          CHAR(125);
DEFINE pp_sdo_ant           DECIMAL(18,2);
DEFINE pp_comision          DECIMAL(18,2);
DEFINE pp_iva_com           DECIMAL(18,2);
DEFINE pp_int_mora          DECIMAL(18,2);
DEFINE pp_iva_int_mora      DECIMAL(18,2);
DEFINE pp_int_vdo           DECIMAL(18,2);
DEFINE pp_iva_int_vdo       DECIMAL(18,2);
DEFINE pp_int_ordi          DECIMAL(18,2);
DEFINE pp_iva_int_ordi      DECIMAL(18,2);
DEFINE pp_capital           DECIMAL(18,2);
DEFINE pp_monto_pago        DECIMAL(18,2);
DEFINE pp_cuenta_eje        CHAR(20);
DEFINE pp_sdo_act           DECIMAL(18,2);
DEFINE pp_pago_min          DECIMAL(18,2);
DEFINE pp_fecha_limite_pago CHAR(17);

---VARIABLES DEL PROCESO DE sp_principal_rr
DEFINE rr_cod_ret			CHAR(5);
DEFINE rr_menssaje_ret      CHAR(125);
DEFINE rr_sdo_ant			DECIMAL(18,2);
DEFINE rr_comision			DECIMAL(18,2);
DEFINE rr_iva_com			DECIMAL(18,2);
DEFINE rr_int_mora			DECIMAL(18,2);
DEFINE rr_iva_int_mora      DECIMAL(18,2);
DEFINE rr_int_vdo			DECIMAL(18,2);
DEFINE rr_iva_int_vdo       DECIMAL(18,2);
DEFINE rr_int_ordi          DECIMAL(18,2);
DEFINE rr_iva_int_ordi      DECIMAL(18,2);
DEFINE rr_capital		    DECIMAL(18,2);
DEFINE rr_monto_pago        DECIMAL(18,2);
DEFINE rr_cuenta_eje        CHAR(20);
DEFINE rr_sdo_act           DECIMAL(18,2);
DEFINE rr_pago_min          DECIMAL(18,2);
DEFINE rr_fecha_limite_pago	CHAR(17);
DEFINE cTransacc	CHAR(4);
DEFINE cCodFun	CHAR(3);
DEFINE iCodRef	INTEGER;

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
DEFINE cBCCodret		CHAR(6);   
DEFINE CBCMensajeRet	CHAR(80); 
	-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
DEFINE cCodRetGF			CHAR(6);
DEFINE cFolioSuc			CHAR(16);

---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cCodRetRev			= '00000';
LET cCodRetGF			= '000000';
LET cMensajeRet			= 'Proceso Exitoso';

LET cSucursal					= "";
LET cNumcte						= "";
LET cFolioSuc					= "";
LET cNumCred					= "";

LET cCodProd					= "";
LET iCompromiso					= 0;
LET cComentario					= "";
LET iFky_estatus                = 0;
LET iFallecido                  = 0;
LET iResultado                  = 0;
LET mTot_liquidacion			= 0;
LET cCodRetCan					= "";
LET cFolioSucCan				= "";

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
LET csg_codigo_ret				= "000000";
LET csg_mensaje_ret				= "";
LET csg_num_credito				= "";
LET csg_cod_tipcred				= "";
LET cStatus						= "";
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
LET csg_dMoraBase               = "";
LET csg_dMoraCopete             = "";
LET csg_dIvamoraBase            = "";
LET csg_dIvaMoraCopete          = "";
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE principal
LET cLiqCodRet				= "";
LET pri_Remanente				= 0.0;
LET pri_IntMoratorio			= 0.0;
LET pri_IntVencido				= 0.0;
LET pri_CapVencido				= 0.0;
LET pri_IntVigente				= 0.0;
LET pri_CapVigente				= 0.0;
LET pri_Impuesto				= 0.0;
LET pri_Comisiones				= 0.0;
LET pri_Seguro					= 0.0;

--VARIABLES DEL sp_principal_pp
LET pp_cod_ret              = "00000";
LET pp_mens_ret             = "";
LET pp_sdo_ant              = 0;
LET pp_comision             = 0;
LET pp_iva_com              = 0;
LET pp_int_mora             = 0;
LET pp_iva_int_mora         = 0;
LET pp_int_vdo              = 0;
LET pp_iva_int_vdo          = 0;
LET pp_int_ordi             = 0;
LET pp_iva_int_ordi         = 0;
LET pp_capital              = 0;
LET pp_monto_pago           = 0;
LET pp_cuenta_eje           = 0;
LET pp_sdo_act              = 0;
LET pp_pago_min             = 0;
LET pp_fecha_limite_pago    = "";

---VARIABLES DEL PROCESO DE sp_principal_rr
LET rr_cod_ret				= "";
LET rr_menssaje_ret      	= "";
LET rr_sdo_ant				= 0.0;
LET rr_comision				= 0.0;
LET rr_iva_com				= 0.0;
LET rr_int_mora				= 0.0;
LET rr_iva_int_mora      	= 0.0;
LET rr_int_vdo				= 0.0;
LET rr_iva_int_vdo       	= 0.0;
LET rr_int_ordi          	= 0.0;
LET rr_iva_int_ordi      	= 0.0;
LET rr_capital		    	= 0.0;
LET rr_monto_pago        	= 0.0;
LET rr_cuenta_eje        	= "";
LET rr_sdo_act           	= 0.0;
LET rr_pago_min          	= 0.0;
LET rr_fecha_limite_pago	= "";
LET cTransacc	= "8019";
LET cCodFun	= "";
LET iCodRef	= 0;
	

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
LET cBCCodret		= "";
LET CBCMensajeRet   = "";
	
BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr,cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/jesus/sp_procesa_saldosinmateriales.out";
	--TRACE ON;
	
	
		
	IF NVL(pEmpresa,'') = ''  THEN
		LET cCodRet	= '00001';
		LET cMensajeRet	= 'PARAMETRO DE ENTRADA INVALIDOS';
		RETURN cCodRet,cMensajeRet;
	END IF;
	

	
    SELECT trim(valor) 
    INTO cSucursal
    FROM "informix".sd_param
    WHERE empresa = '001'
    AND cod_param = '28';

    IF NVL(cSucursal,'') = '' THEN
		LET cCodRet = "00001";
		LET cMensajeRet	= 'OCURRIO UN ERROR AL OBTENER LA SUCURSAL';
		RETURN cCodRet,cMensajeRet;
    END IF;
	
	FOREACH WITH HOLD
		SELECT  numcte,num_credito,saldo_total
		INTO cNumcte,cNumCred,mTot_liquidacion
		FROM "informix".sd_saldos_inmateriales
		WHERE aplica_si ='0'
				
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,cNumCred) 
		INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
				csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
				csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
				csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
				csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
				csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
				csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
				csg_id_causa_esp_cred,csg_sit_esp_cred;

		IF csg_codigo_ret::INTEGER <> 0 THEN		
				LET cComentario = "SE EXCLUYO DEL PROCESO,POR ERROR EN EL PROCEDIMIENTO sp_consulta_saldos_general";
				LET iResultado = '3';			
		END IF;		
		
		IF NVL(cComentario,'') ='' THEN --SIN PROBLEMAS

			SELECT tp_solicitud
			INTO cCodProd
			FROM bdisolic:"informix".ss_solic_producto
			WHERE empresa = pEmpresa
			AND prefijo_sol = SUBSTR(cNumCred,1,2);		
	
	
			EXECUTE PROCEDURE "informix".sp_procesa_inmateriales(pEmpresa,cCodProd, cNumCred,cNumcte)
			INTO  cLiqCodRet;
			
		   IF cCodProd = 'T' AND cLiqCodRet::INTEGER <> 0 THEN 				
					LET iResultado = '3';					
					LET  cComentario = "SE EXCLUYO DEL PROCESO,POR ERROR EN EL PROCEDIMIENTO sp_procesa_inmateriales";					 
		   ELIF cCodProd IN ('P','R')  AND cLiqCodRet::INTEGER <> 0  THEN --PAGO  PRESTAMO PERSONAL O CREDINOMINA
			-- SE REALIZA EL DESBLOQUEO DE LA CUENTA				
				 	LET iResultado = '3';	
					LET cComentario = "SE EXCLUYO DEL PROCESO,POR ERROR EN EL PROCEDIMIENTO sp_procesa_inmateriales";		
			END IF;
		  
		 END IF;  --VALIDACION DE EXITO
			
		IF NVL(cComentario,'') ='' THEN --SIN PROBLEMAS	
			LET iResultado = '2';			
			LET cComentario = "PROCESADO EXITOSAMENTE" ;
			LET cStatus = "FI";
		END IF;  		

		UPDATE "informix".sd_saldos_inmateriales
		SET aplica_si = iResultado ,
		comentarios = cComentario,
		estatus_fin = cStatus
		WHERE empresa = pEmpresa 
		AND num_credito =cNumCred;
		
		
		LET cStatus = "";
		LET cComentario = "";
		LET iResultado = '2';
	
   END FOREACH;
   RETURN cCodRet,cMensajeRet;
END;
END PROCEDURE
DOCUMENT    
'DESCRIPCION: Procedimiento para  la aplicacion de saldos inmateriales', 
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 21 Mayo 2014',
'VERSION: 20140521.1645',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_venta_cartera_pba(pEmpresa char(3))
returning char (87);

--  Autor: Paul Ivan Quintero Varela.
--  Fecha: 05/03/2008.
--  Observaciones: Se creá un sp_para el proceso de la Venta de la Cartera.


--  Autor: Paul Ivan Quintero Varela.
--  Fecha: 18/12/2008.
--  Observaciones: Se modifica procedimiento para la solución de la incidencia
--                 de la baja de cartera en relación al rubro de reservas.


DEFINE cNumCredito                  Char(20);
DEFINE cNumCte                      Char(20);
DEFINE cNumProducto                 Char(4);
DEFINE dFecha                       Date;
DEFINE dpri_dia_mes					Date;
DEFINE ddia_corte				char(2);
DEFINE cFolio                       Char(16);
DEFINE cSucursal                    Char(4);
DEFINE cDivisa                      Char(2);
DEFINE vPeriodicidad                Char(1);
DEFINE vCalif_Riesgo                Char(2);
DEFINE vMontoLineaNoDispuesta       Decimal(16,2);
DEFINE vMontoVencidoExigible        Decimal(16,2);
DEFINE vMontoVencidoNoExigible      Decimal(16,2);
DEFINE vMontoVencidoPorCobrar       Decimal(14,2);
DEFINE vMontoReservado              Decimal(16,2);
DEFINE vCapitalVig                  Money(14,2);
DEFINE vCapitalVen                  Money(14,2);
--DEFINE pFecha                       Date;
DEFINE vCredito                     Char(20);
DEFINE vTotal                       Money(16,2);
DEFINE vPeriodo                     Char(1);
DEFINE vNum_Periodo                 Smallint;
DEFINE vInteres_venc                Money(16,2);
DEFINE vGrado                       Char(2);
DEFINE vProducto                    Char(4);
DEFINE vSucursal                    Char(4);
DEFINE vDivisa                      Char(2);
DEFINE vIntMora                     Decimal(14,2);
DEFINE vIvaIntMora                  Decimal(14,2);
DEFINE vPorcIva                     Decimal(14,2);
DEFINE vPorcIva_rees                Decimal(14,2);
DEFINE vImporteReserva              Money(16,2);
DEFINE vPorcentajeReserva           Decimal(14,2);
DEFINE vGrado_Aplicar               Char(2);
DEFINE vCalificacion                Char(2);
DEFINE vMontoExigyNoExig            Decimal(16,2);
DEFINE cEvaluaCC                    Char(1);
DEFINE vImporteReservaBuroCC        Money(16,2);
DEFINE vNvoPeriodo                  Smallint;
DEFINE vNvoPeriodo2                 Smallint;
DEFINE vNvoPeriodo3                 Smallint;
DEFINE vfechaini                    Date;
--DEFINE vfechafin                    Date;
DEFINE vcuotasvenc                  smallint;
DEFINE vtotal_dias                  smallint;
DEFINE vtotal_capitalizado          Money(16,2);
DEFINE vmonto_capitalizado          Money(16,2);
DEFINE vMontoCompara                Money(16,2);
DEFINE vcodigo_ref                  INTEGER;
DEFINE fechafinmesant               DATE;
DEFINE vencifinmes                  SMALLINT;
DEFINE vtarjeta                     CHAR(20);
DEFINE cproduto                     VARCHAR(3);

DEFINE CodRet              CHAR(5);
DEFINE Mensaje             CHAR(80);
DEFINE sql_err             SMALLINT;
DEFINE isam_err            SMALLINT;
DEFINE error_info          CHAR(40);
DEFINE nRows               SMALLINT;

--- variables para procesar reestructuras SDFM 22/02/2012
DEFINE vMontoVencidoExigible_rees DECIMAL(16,2);
DEFINE vMontoVencidoNoExigible_rees DECIMAL(16,2);
DEFINE vInteresVencido DECIMAL(16,2);
DEFINE vInteresVencido_rees DECIMAL(16,2);
DEFINE vInteresVencido_ant DECIMAL(16,2);
DEFINE vIvaInteresVencido DECIMAL(16,2);
DEFINE vIvaInteresVencido_rees DECIMAL(16,2);
DEFINE vIvaInteresVencido_ant DECIMAL(16,2);
DEFINE vCapitalVig_rees DECIMAL(16,2);
DEFINE vCapitalVen_rees DECIMAL(16,2);
DEFINE cStatusCred          CHAR(02);
define dproxfechapago, dfechaproceso date;
DEFINE dfecha_vencto61 DATE;
DEFINE dfecha_vencto63 DATE;



--Set debug file to 'sp_Proceso_Venta_Cartera.out';
--trace on;

set isolation to dirty read;
set lock mode to wait 3;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
     Rollback Work;
	 SET DEBUG FILE TO "Proceso_Venta_de_Cartera_Info.err";
      TRACE sql_err|| " * "||isam_err|| " * " ||error_info;
      LET CodRet = sql_err;
      RETURN CodRet|| ' ERROR en el proceso VENTA DE CARTERA ' || cNumCredito;
   END EXCEPTION;

--SET DEBUG FILE TO '/informix/sp_venta_cartera_v01.out';
--TRACE ON;

let vcodigo_ref = 0;

--- variables para procesar reestructuras SDFM 22/02/2012
LET vSucursal = '';
LET vMontoVencidoExigible_rees = 0;
LET vMontoVencidoNoExigible_rees = 0;
LET vInteresVencido = 0;
LET vInteresVencido_rees = 0;
LET vInteresVencido_ant = 0;
LET vIvaInteresVencido = 0;
LET vIvaInteresVencido_rees = 0;
LET vIvaInteresVencido_ant = 0;
LET vCapitalVig_rees = 0;
LET vCapitalVen_rees = 0;
LET cStatusCred = '';
let dproxfechapago = date(0);
let dfechaproceso   = date(0);
LET dfecha_vencto61 = DATE(0);
LET dfecha_vencto63 = DATE(0);

/*
Select fecha_hoy,fecha_hoy --Obtiene la Fecha del Dia
Into vfechafin,dFecha--, vult_hab_mes, vpri_hab_mes
*/
Select pri_dia_mes, fecha_hoy  --Obtiene la Fecha del Dia
Into dpri_dia_mes, dFecha--, vult_hab_mes, vpri_hab_mes
From bdicred:sd_fechas
Where empresa = pEmpresa;

-- temporal para pruebas
--let dFecha = mdy('02','28','2012');
-- temporal para pruebas

ForEach With hold

        Select num_credito, numcte, num_producto, status_cred
        Into cNumCredito, cNumCte, cNumProducto, cStatusCred
		From bdicred:sd_maecred
        where empresa = pempresa
        and status_cred = 'BT'
        and id_unidad_prod = 1
		AND campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
        and num_credito in (Select num_credito From bdicobranza:cb_rep_cart_quebrantar
							where fechareporte = (Select max(fechareporte)
												  From bdicobranza:cb_rep_cart_quebrantar
												  where producto = '6001'
												  )
							)
		union all
		Select num_credito, numcte, num_producto, status_cred
        From bdicred:sd_maecredcrd
        where empresa = pempresa
        and id_origen = '1'
		and status_cred != 'CV'
        and num_producto = '6011'
		AND campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
        and num_credito in (Select num_credito From bdicobranza:cb_rep_cart_quebrantar
		                     where fechareporte = (Select max(fechareporte)
													From bdicobranza:cb_rep_cart_quebrantar
													where producto = '6011'
												   )
						    )
        union all
		Select num_credito, numcte, num_producto, status_cred
		From bdicred:sd_maecredcrd
        where empresa = pempresa
        and id_origen = '1'
		and status_cred != 'CV'
        and num_producto = '6300'
		AND campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
        and num_credito in (Select num_credito From bdicobranza:cb_rep_cart_quebrantar
		                    where fechareporte = (Select max(fechareporte)
												  From bdicobranza:cb_rep_cart_quebrantar
												  where producto = '6300'
												 )
							)
        Begin Work;


	IF cNumProducto = '6001' THEN

        -- Se Replica la informacion de los creditos por Vender a la tabla bdicred:sd_maecred_vendida.
        	Insert into bdicred:sd_maecred_vendida
			Select current, * From bdicred:sd_maecred Where empresa = pEmpresa and num_credito= cNumCredito;

		-- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
		    Update bdicred:sd_maecred Set status_cred= 'CV' Where empresa = pEmpresa and num_credito= cNumCredito;

		-- Se Actualiza la fecha de proceso por estar bloqueados los créditos
		    Update bdicred:sd_maecredanexo Set fecha_proceso = current Where empresa=pEmpresa And num_credito= cNumCredito;

		-- Se realiza el Bloqueo de la tarjeta.
            foreach
                select num_tarjeta
                  into vtarjeta
                from bdicred:sd_tarjeta
                where empresa=pEmpresa
                  and num_credito=cNumCredito
                  and tipo_tarjeta<>'0'
                  and status_tar <> 'C'

                  select codproductotarjeta
                    into cproduto
                  from intercard:tarjeta
                  where numtarjeta=vtarjeta;

                  execute procedure intercard:"informix".sp_cancelacion_tarjeta
                  (vtarjeta,cproduto,'informix') INTO CodRet, Mensaje;

                  if CodRet='001' or CodRet='002' then
                     LET CodRet = '000000';
                     LET Mensaje= " ";
                  end if;
            end foreach;

			Update bdicred:sd_tarjeta Set status_tar= 'C', limite_aut = 0, motivo = 'CV' Where empresa= pEmpresa And num_credito= cNumCredito and status_tar <> 'C';

		-- Se Replica la informacion del Maestro de saldos a la tabla bdicred:sd_maesdos_vendida.
		    Insert into bdicred:sd_maesdos_vendida
			Select current, * From bdicred:sd_maesdos Where empresa=pEmpresa And num_credito= cNumCredito;

        -- se Replica la informacion de la Tabla sd_amortiza_credito a la tabla sd_amortiza_credito_vendida.
        	Insert into bdicred:sd_amortiza_credito_vendida
			Select current, * From bdicred:sd_amortiza_credito Where empresa= pEmpresa And num_credito= cNumCredito and fecha_cuota >= date(0);

            SELECT
--                a.num_producto, c.fecha_hoy, a.sucursal, a.divisa, a.periodo_plazo, calificacion_riesgo,
                a.num_producto, a.sucursal, a.divisa, a.periodo_plazo, calificacion_riesgo,
                b.monto_otorgado - (b.sdo_capital + b.monto_vencido + b.mto_venc_trasp + b.cap_tras_no_venci),-- Se obtiene el monto de la LINEA DE CREDITO NO DISPUESTA
                b.Mto_venc_trasp, b.cap_tras_no_venci, b.int_tra_no_exig, b.monto_reservado,
                b.sdo_capital, b.sdo_cap_insoluto
            INTO
--                cNumProducto,dFecha, cSucursal, cDivisa, vPeriodicidad, vCalif_Riesgo,
                cNumProducto, cSucursal, cDivisa, vPeriodicidad, vCalif_Riesgo,
                vMontoLineaNoDispuesta,
                vMontoVencidoExigible, vMontoVencidoNoExigible,vInteresVencido, vMontoReservado,
                vCapitalVig, vCapitalVen
            FROM
--                sd_maecred a, sd_maesdos b, sd_fechas c, sd_definicion d,
                sd_maecred a, sd_maesdos b, sd_definicion d,
                bdinteg:si_sucursales e
            WHERE a.empresa        = pEmpresa
              AND a.num_credito      = cNumCredito
              AND a.bandera_ministra = 'M'
              AND b.empresa          = a.empresa
              AND b.num_credito      = a.num_credito
--              AND c.empresa          = a.empresa
              AND d.empresa          = a.empresa
              AND d.num_producto     = a.num_producto
              AND e.empresa			= a.empresa
              AND e.sucursal         = a.sucursal;

            If vMontoLineaNoDispuesta >= 0 Then
                -- Cancelacion del registro de la LINEA DE CREDITO NO DISPUESTA
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 1,
                                "444", dFecha, vMontoLineaNoDispuesta, "CarVendida",
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
            Else
                let vMontoLineaNoDispuesta = abs(vMontoLineaNoDispuesta);
                -- Saldo Negativo Inversa de la Cancelacion del registro de la LINEA DE CREDITO NO DISPUESTA
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 2,
                                "444", dFecha, vMontoLineaNoDispuesta, "CarVendida",
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
            End If;

                -- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 3,
                                "444", dFecha, vMontoVencidoExigible, "CarVendida",
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;

                -- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 4,
                                "444", dFecha, vMontoVencidoNoExigible, "CarVendida",
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;

        -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias
               CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 5,
                           "444", dFecha, vInteresVencido, "CarVendida",
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;

        -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias Moratorios

             --SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) + Sum(mora_sdo_ordi+mora_provi_cope-mora_sdo_cope_pag))
             SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) + Sum(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag))
             INTO vIntMora
             FROM sd_amortiza_credito
             WHERE  empresa = pEmpresa
             AND num_credito = cNumCredito
             AND capital_status IN ("2","7");

             IF  vIntMora IS NULL OR  vIntMora < 0 THEN
                LET vIntMora = 0;
             END IF;

               CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 6,
                           "444", dFecha, vIntMora , "CarVendida",
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;

        -- Iva Vencido por Cobrar
             Select
                Sum(iva_debe - iva_pagado)
             Into
                vMontoVencidoPorCobrar
             From
                sd_amortiza_credito
             Where empresa= pEmpresa
               And num_credito= cNumCredito
               and capital_status <> '5';


            -- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias
               CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 7,
                           "444", dFecha, vMontoVencidoPorCobrar, "CarVendida",
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;

            -- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias MORATORIOS

                    -- Se obtiene el iva de la sucursal
                    SELECT iva
                    INTO vPorcIva
                    FROM bdinteg:si_sucursales
                    WHERE empresa = pEmpresa
                    AND sucursal = cSucursal;

                    IF vPorcIva IS NULL THEN
                        LET vPorcIva=0;
                    END IF;

                 SELECT SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * vPorcIva)-mora_iva_pagado)
                 INTO vIvaIntMora
                 FROM sd_amortiza_credito
                 WHERE  num_credito = cNumCredito
                 AND empresa = pEmpresa
                 AND capital_status IN ("2","7")
                 AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * vPorcIva)) > 0;

                 IF  (vIvaIntMora  IS NULL) OR (vIvaIntMora < 0) or (vIntMora <= 0) THEN
                        LET vIvaIntMora = 0;
                 END IF;

                CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 8,
                           "444", dFecha, vIvaIntMora, "CarVendida",
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;

        -- Proceso de la Calificacion de la Cartera Vendida
                    Select fecha_vencto
                    Into vfechaini
                    From bdicred:sd_maecredanexo
                    Where empresa     = pEmpresa
                    And	  num_credito = cNumCredito;

                    If Not vfechaini Is Null Then

                        LET vcuotasvenc = ((Year(dFecha) - Year(vfechaini)) * 12) + Month(dFecha) - Month(vfechaini);
                        if (day(dFecha) <= 20) then let vcuotasvenc = vcuotasvenc - 1; end if;

                        If vcuotasvenc Is Null Then
                            let vcuotasvenc = 0;
                        End If
                        If vcuotasvenc < 0 Then
                            let vcuotasvenc = 0;
                        End If
                    else
                        LET vcuotasvenc = 0;
                    End if

                    let fechafinmesant=date(mdy(month(dFecha),'01',year(dFecha))-1);

                    select num_periodos into vencifinmes
                    from bdicred:sd_histvalcon
                    where empresa=pEmpresa
                      and num_credito=cNumCredito
                      and fecha_alta=fechafinmesant;

                      if vencifinmes is null then let vencifinmes=0; end if;

                      IF vcuotasvenc>0 AND vcuotasvenc>vencifinmes THEN
                        LET vcuotasvenc=vencifinmes;
                      END IF;

                LET vTotal =  vCapitalVen + vInteresVencido;

    -- Procesa de la Calificacion
            /*
			-- Elimina el Movimiento Generado de la Calificacion anterior
			 --  DELETE FROM sd_movcalcval
			 --  WHERE empresa = pEmpresa;

			-- Elimina el Movimiento del Dia en Historico
			  -- DELETE FROM sd_histvalcon
			  -- WHERE empresa = pEmpresa and
              -- year(fecha_alta) = Year(pFecha) and
              -- month(fecha_alta) = Month(pFecha);
			*/
			-- Determina la Periodicidad del Credito
				IF UPPER(vPeriodicidad) = "S" THEN
						IF vcuotasvenc > 18 THEN
							LET vcuotasvenc = 18;
						END IF
				END IF

				IF UPPER(vPeriodicidad) = "Q" THEN
					IF vcuotasvenc > 13 THEN
						LET vcuotasvenc = 13;
					END IF
				END IF

				IF UPPER(vPeriodicidad) = "M" THEN
					IF vcuotasvenc > 9 THEN
						LET vcuotasvenc = 9;
					END IF
				END IF

			 -- Extrae el Numero de Periodos Vencidos
				SELECT porcentaje, grado, grado
				INTO vPorcentajeReserva, vGrado_Aplicar, vCalificacion
				FROM sd_porc_reserva
				WHERE empresa = pEmpresa and
					periodo = vPeriodicidad and
					num_periodo = vcuotasvenc and
					tipocredito = "01";

             -- No se toman los intereses en cuenta para creditos con mas de 1 pago vencido
				IF UPPER(vPeriodicidad) = "M" THEN
					IF vInteresVencido > 1 THEN
						LET vTotal = vTotal - vInteresVencido;
					END IF
				END IF

			-- Calcula el Importe de la Reserva
				LET vImporteReserva = vTotal * (vPorcentajeReserva / 100);

			-- Inserta informacion Calculada
				INSERT INTO sd_movcalcval  (empresa,
											num_credito,
											periodo,
											num_periodo,
											grado_riesgo,
											importe,
											porcentaje,
											imp_reservas,
											calificacion,
											fecha)
									VALUES (pEmpresa,
											cNumCredito,
											vPeriodicidad,
											vcuotasvenc,
											vGrado_Aplicar,
											vTotal,
											vPorcentajeReserva,
											vImporteReserva,
											vCalificacion,
											dFecha);


			  -- Actualiza Maestro de Credito Central
                                UPDATE sd_maecred
                                   SET calificacion_riesgo = vCalificacion
				                 WHERE empresa = pEmpresa
                                   And  num_credito = cNumCredito;

 			-- Graba Movimiento en Historico de Calificaciones
     			INSERT INTO sd_histvalcon (empresa,
	 									   num_credito,
										   fecha_alta,
										   calif_ant,
										   calif_actual,
										   porcentaje,
										   num_periodos,
										   importe,
										   importe_reserva)
								   VALUES (pEmpresa,
                                            cNumCredito,
										    dFecha,
										    vCalif_Riesgo,
										    vCalificacion,
										    vPorcentajeReserva,
										    vcuotasvenc,
										    vTotal,
										    vImporteReserva);


            -- Se Actualizan los saldos
               Update sd_maesdos
                  Set mto_venc_trasp=0, monto_vencido=0,
                      cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0,
                      sdo_capital=0, sdo_cap_insoluto=0, monto_otorgado = 0,
                      monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0
                 Where empresa = pEmpresa
                   And num_credito= cNumCredito;

            -- Se Actualizan las amortizaciones

               Update sd_amortiza_credito
                  Set capital_status = 5,
                      iva_pagado = iva_debe,
                      mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
                      mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
                      mora_provi_ordi = 0,
                      mora_provi_cope = 0,
                      capital_pagado  = 0
                 Where empresa = pEmpresa
                   And num_credito= cNumCredito
                   and (capital_status in ('2','7') or interes_debe <> 0);

      --FMV 23may13 Actualiza dias de atraso para el indicador de buro en tarjeta
              UPDATE "informix".sd_indicador_cred 
                 SET dias_atraso   = (dFecha - nvl(vfechaini,dFecha) + 1)
               WHERE num_credito   = cNumCredito
                 AND empresa       = pEmpresa;




	ELIF cNumProducto = '6011' THEN
        -- Se Replica la informacion de los creditos (REESTRUCTURA) por Vender a la tabla bdicred:sd_maecred_vendida.
        INSERT INTO bdicred:sd_maecredcrd_vendida
        SELECT CURRENT, * FROM bdicred:sd_maecredcrd
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;

        -- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
        UPDATE bdicred:sd_maecredcrd
        SET status_cred= 'CV'
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;


        -- FMV 23May13  ajuste de indicador de buro por la venta de Cartera 6011           
        	SELECT fecha_vencto
			  INTO dfecha_vencto61
		      FROM bdicred:sd_maecredanexocrd
			 WHERE empresa = pEmpresa
		       AND num_credito = cNumCredito;      
               
          UPDATE "informix".sd_indicador_cred_crd
             SET dias_atraso   = (dFecha - nvl(dfecha_vencto61,dFecha) + 1)
           WHERE empresa       = pEmpresa
             AND num_credito   = cNumCredito;




        -- Se Actualiza la fecha de proceso por estar bloqueados los créditos
        UPDATE bdicred:sd_maecredanexocrd   
        SET fecha_proceso = CURRENT
        WHERE empresa = pEmpresa
        AND num_credito = cNumCredito;

        -- Se Replica la informacion del Maestro de saldos a la tabla bdicred:sd_maesdos_vendida.
        INSERT INTO bdicred:sd_maesdoscrd_vendida
        SELECT CURRENT, * FROM bdicred:sd_maesdoscrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito;

        -- se Replica la informacion de la Tabla sd_amortiza_credito a la tabla sd_amortiza_credito_vendida.
        INSERT INTO bdicred:sd_amortiza_creditocrd_vendida
        ---SELECT CURRENT, * FROM bdicred:sd_amortiza_creditocrd
        SELECT {+INDEX(sd_amortiza_creditocrd idx_amortiza_creditocrd4)} CURRENT, * FROM bdicred:sd_amortiza_creditocrd
        ----WHERE empresa = pEmpresa
        ----AND num_credito= cNumCredito
        WHERE num_credito= cNumCredito
        AND fecha_cuota >= date(1);

        SELECT
            a.num_producto, a.sucursal, a.divisa,
            (b.monto_vencido + b.mto_venc_trasp),(b.sdo_capital + b.cap_tras_no_venci), b.int_tra_no_exig,
            b.sdo_capital, b.sdo_cap_insoluto
        INTO
            cNumProducto, vSucursal, cDivisa,
            vMontoVencidoExigible_rees, vMontoVencidoNoExigible_rees,vInteresVencido,
            vCapitalVig_rees, vCapitalVen_rees
        FROM  bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_definicion c , bdinteg:si_sucursales d
        WHERE a.empresa          = pEmpresa
          AND a.num_credito      = cNumCredito
          AND a.bandera_ministra = 'M'
          AND b.empresa          = a.empresa
          AND b.num_credito      = a.num_credito
          AND c.empresa          = a.empresa
          AND c.num_producto     = a.num_producto
          AND d.empresa			 = a.empresa
          AND d.sucursal         = a.sucursal;

        -- Por la venta de la cartera vencida EXIGIBLE
		IF vMontoVencidoExigible_rees > 0 THEN

			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 1, "445", dFecha, vMontoVencidoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				IF CodRet != '00000' THEN
				   LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				END IF;
		END IF;

        -- Por la venta de la cartera vencida NO EXIGIBLE
		IF vMontoVencidoNoExigible_rees > 0 THEN

			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 2, "445", dFecha, vMontoVencidoNoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;
		END IF;
-------------------------
        IF cStatusCred = 'BT' THEN
            --creditos BT
            --balanza
            ---select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            select {+INDEX(sd_amortiza_creditocrd idx_amortiza_creditocrd3)}  nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7')
            and fecha_cuota <= (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '601'
                                and codigo_ref = 3
                                and reversado = 'N');

            --orden
            ---select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            select {+INDEX(sd_amortiza_creditocrd idx_amortiza_creditocrd3)}  nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7')
            and fecha_cuota > (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '601'
                                and codigo_ref = 3
                                and reversado = 'N');

        ELSE
            select {+INDEX(sd_amortiza_creditocrd idx_amortiza_creditocrd3)} nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            FROM bdicred:sd_amortiza_creditocrd
            WHERE empresa = pEmpresa
            AND num_credito= cNumCredito
            AND capital_status in ('2','7');

        END IF;

-------------------------

        IF cStatusCred = 'BT' THEN
        -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias
			IF vInteresVencido_rees > 0 THEN

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 3, "445", dFecha, vInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;

			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 4, "445", dFecha, vIvaInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;
			END IF;
		END IF;

        -- Baja del Interes Vencido por Cobrar

		IF vInteresVencido > 0 THEN

			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 5, "445", dFecha, vInteresVencido, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;

			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 6, "445", dFecha, vIvaInteresVencido, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;

		END IF;

        -- Se Actualizan los saldos
        UPDATE bdicred:sd_maesdoscrd
        SET    mto_venc_trasp=0, monto_vencido=0, cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0, sdo_capital=0,
               sdo_cap_insoluto=0, monto_otorgado = 0, monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0,
               ---- se agregan campos para que Juan Olivares valide
               sdo_intereses = 0, sdo_dia_ant_int = 0, provision_normal = 0, sdo_cap_insoluto = 0, sdo_dia_ant_cap = 0, sdo_mes_ant_cap = 0,
               sdo_acum_mes_cap = 0, mto_capitalizado = 0, mto_ministra_cap = 0, cargos_dia_cap = 0, abonos_dia_cap = 0, cargos_mes_cap = 0,
               abonos_mes_cap = 0, sdo_global_int = 0, mto_venc_int = 0, mto_fin_ven_trasp = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito;

        -- Se Actualizan las amortizaciones

        ---UPDATE sd_amortiza_creditocrd
        UPDATE {+INDEX(sd_amortiza_creditocrd idx_amortiza_creditocrd3)}  sd_amortiza_creditocrd
        SET    capital_status = 5, iva_pagado = iva_debe, mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
               mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope, mora_provi_ordi = 0, mora_provi_cope = 0, capital_pagado  = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito
        AND    (capital_status in ('2','7') or interes_debe <> 0);


	ELSE

        -- Se Replica la informacion de los creditos (PRESTAMO PERSONAL) por Vender a la tabla bdicred:sd_maecred_vendida.
        INSERT INTO bdicred:sd_maecredcrd_vendida
        SELECT CURRENT, * FROM bdicred:sd_maecredcrd
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;

        -- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
        UPDATE bdicred:sd_maecredcrd
        SET status_cred= 'CV'
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;


     -- FMV 23May13  ajuste de indicador de buro por la venta de Cartera 6300           
        	SELECT fecha_vencto
			  INTO dfecha_vencto63
		      FROM bdicred:sd_maecredanexocrd
			 WHERE empresa = pEmpresa
		       AND num_credito = cNumCredito;      
               
          UPDATE "informix".sd_indicador_cred_crd
             SET dias_atraso   = (dFecha - nvl(dfecha_vencto63,dFecha) + 1)
           WHERE empresa       = pEmpresa
             AND num_credito   = cNumCredito;






        -- Se Actualiza la fecha de proceso por estar bloqueados los créditos
        UPDATE bdicred:sd_maecredanexocrd
        SET fecha_proceso = CURRENT
        WHERE empresa = pEmpresa
        AND num_credito = cNumCredito;

        -- Se Replica la informacion del Maestro de saldos a la tabla bdicred:sd_maesdos_vendida.
        INSERT INTO bdicred:sd_maesdoscrd_vendida
        SELECT CURRENT, * FROM bdicred:sd_maesdoscrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito;

        -- se Replica la informacion de la Tabla sd_amortiza_credito a la tabla sd_amortiza_credito_vendida.
        INSERT INTO bdicred:sd_amortiza_creditocrd_vendida
        ---SELECT CURRENT, * FROM bdicred:sd_amortiza_creditocrd
        SELECT {+INDEX(sd_amortiza_creditocrd idx_amortiza_creditocrd4)}  CURRENT, * FROM bdicred:sd_amortiza_creditocrd
        ---WHERE empresa = pEmpresa
        ---AND num_credito= cNumCredito
        WHERE num_credito= cNumCredito
        AND fecha_cuota >= date(1);

        SELECT
            a.num_producto, a.sucursal, a.divisa,
            (b.monto_vencido + b.mto_venc_trasp),(b.sdo_capital + b.cap_tras_no_venci), b.int_tra_no_exig,
            b.sdo_capital, b.sdo_cap_insoluto,
			e.dia_corte
        INTO
            cNumProducto, vSucursal, cDivisa,
            vMontoVencidoExigible_rees, vMontoVencidoNoExigible_rees,vInteresVencido,
            vCapitalVig_rees, vCapitalVen_rees,
			ddia_corte

        FROM  bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_definicion c , bdinteg:si_sucursales d, bdicred:sd_maecredanexocrd e
        WHERE a.empresa          = pEmpresa
          AND a.num_credito      = cNumCredito
          AND a.bandera_ministra = 'M'
          AND b.empresa          = a.empresa
          AND b.num_credito      = a.num_credito
          AND c.empresa          = a.empresa
          AND c.num_producto     = a.num_producto
          AND d.empresa			 = a.empresa
          AND d.sucursal         = a.sucursal
		  AND e.empresa 		 = a.empresa
		  AND e.num_credito      = a.num_credito;

        -- Por la venta de la cartera vencida EXIGIBLE

		IF vMontoVencidoExigible_rees > 0 THEN

			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 1, "446", dFecha, vMontoVencidoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				IF CodRet != '00000' THEN
				   LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				END IF;

		END IF;

					-- Por la venta de la cartera vencida NO EXIGIBLE
		IF vMontoVencidoNoExigible_rees > 0 THEN

			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 2, "446", dFecha, vMontoVencidoNoExigible_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;

		END IF;

-------------------------
       -- IF cStatusCred = 'BT' THEN
            --creditos BT
            --balanza
            ---select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            select {+INDEX(sd_amortiza_creditocrd idx_amortiza_creditocrd3)}  nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7')
            and fecha_cuota <= (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '026'
                                and codigo_ref = 3
                                and reversado = 'N');

            --orden
            --select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido 08/06/2012 PARA PP POR RSS
			select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7')
            and fecha_cuota > (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '026'
                                and codigo_ref = 3
                                and reversado = 'N');
		/*
			SELECT iva
			INTO vPorcIva
			FROM bdinteg:si_sucursales
			WHERE empresa = pEmpresa
			AND sucursal = vSucursal;

			IF vPorcIva IS NULL THEN
				LET vPorcIva=0;
			END IF;

			LET vIvaInteresVencido = vInteresVencido * vPorcIva;
        ELSE
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            FROM bdicred:sd_amortiza_creditocrd
            WHERE empresa = pEmpresa
            AND num_credito= cNumCredito
            AND capital_status in ('2','7');
        END IF;*/

-------------------------

      --  IF cStatusCred = 'BT' THEN
        -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias

			IF vInteresVencido_rees > 0 THEN

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 3, "446", dFecha, vInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;
			END IF;

			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

			IF vIvaInteresVencido_rees > 0 THEN

					CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 4, "446", dFecha, vIvaInteresVencido_rees, "CarVendida", vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

					 IF CodRet != '00000' THEN
						LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
						RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
					 END IF;

			END IF;


      --  END IF;

		---------------  Baja de intereses provisionados antes de la fecha de la provision de este mes

        	select prox_fecha_pago, fecha_proceso
			INTO dproxfechapago, dfechaproceso
			from bdicred:sd_maecredanexocrd
			where empresa = pEmpresa
			and num_credito = cNumCredito;

            if (month(dproxfechapago) = month(dfechaproceso) and year(dproxfechapago) = year(dfechaproceso)) then

                select nvl(sum(monto),0)
                INTO vInteresVencido_ant
                from bdicred:sd_movhiscrd
                where empresa = pEmpresa
                and fecha_mov = dpri_dia_mes - 1
                and num_credito = cNumCredito
                and codigo_fun = '606'
                and codigo_ref = 8
                and reversado = 'N';

                if nvl(vInteresVencido_ant,0) = 0 then
                    let vInteresVencido_ant = 0;
                else
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 7, "446", dFecha, vInteresVencido_ant, "CarVendida", vSucursal, cDivisa, "0000","","")
                         RETURNING CodRet, Mensaje;

                         IF CodRet != '00000' THEN
                            LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                            RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                         END IF;
                end if;

                select nvl(sum(monto),0)
                INTO vIvaInteresVencido_ant
                from bdicred:sd_movhiscrd
                where empresa = pEmpresa
                and fecha_mov = dpri_dia_mes - 1
                and num_credito = cNumCredito
                and codigo_fun = '606'
                and codigo_ref = 9
                and reversado = 'N';

                if nvl(vIvaInteresVencido_ant,0) = 0 then
                    let vIvaInteresVencido_ant = 0;
                else
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 8, "446", dFecha, vIvaInteresVencido_ant, "CarVendida", vSucursal, cDivisa, "0000","","")
                         RETURNING CodRet, Mensaje;

                         IF CodRet != '00000' THEN
                            LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
                            RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
                         END IF;
                end if;

            else
                LET vInteresVencido_ant = 0;
                LET vIvaInteresVencido_ant = 0;
            end if;

		-----------------

        -- Baja del Interes Vencido por Cobrar

		IF vInteresVencido > 0 THEN
			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 5, "446", dFecha, vInteresVencido, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;
		END IF;

		IF vIvaInteresVencido > 0 THEN
			CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 6, "446", dFecha, vIvaInteresVencido, "CarVendida", vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;

				 IF CodRet != '00000' THEN
					LET Mensaje = 'Error en SPL GenMovcrd'||' '|| TRIM(Mensaje);
					RETURN CodRet|| ' ' || cNumCredito || TRIM(Mensaje);
				 END IF;
		END IF;

        -- Se Actualizan los saldos
        UPDATE bdicred:sd_maesdoscrd
        SET    mto_venc_trasp=0, monto_vencido=0, cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0, sdo_capital=0,
               sdo_cap_insoluto=0, monto_otorgado = 0, monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0,
               ---- se agregan campos para que Juan Olivares valide
               sdo_intereses = 0, sdo_dia_ant_int = 0, provision_normal = 0, sdo_cap_insoluto = 0, sdo_dia_ant_cap = 0, sdo_mes_ant_cap = 0,
               sdo_acum_mes_cap = 0, mto_capitalizado = 0, mto_ministra_cap = 0, cargos_dia_cap = 0, abonos_dia_cap = 0, cargos_mes_cap = 0,
               abonos_mes_cap = 0, sdo_global_int = 0, mto_venc_int = 0, mto_fin_ven_trasp = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito;

        -- Se Actualizan las amortizaciones

        UPDATE sd_amortiza_creditocrd
        SET    capital_status = 5, iva_pagado = iva_debe, mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
               mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope, mora_provi_ordi = 0, mora_provi_cope = 0, capital_pagado  = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito
        AND    (capital_status in ('2','7') or interes_debe <> 0);

	END IF;
	--SE realiza el marcaje del cliente RQI 27 100 JMAH
	EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',1,cNumCte, USER)
	INTO CodRet, Mensaje;
	
    LET vInteresVencido_rees = 0;
    LET vIvaInteresVencido_rees = 0;
    LET vInteresVencido = 0;
    LET vIvaInteresVencido = 0;
	LET vInteresVencido_ant = 0;
	LET vIvaInteresVencido_ant = 0;
	LET cStatusCred = '';

    Commit Work;

End Foreach;

LET CodRet = '00000';
RETURN CodRet || ' El proceso de VENTA DE CARTERA se ejecutó exitosamente.';

end;
end procedure;