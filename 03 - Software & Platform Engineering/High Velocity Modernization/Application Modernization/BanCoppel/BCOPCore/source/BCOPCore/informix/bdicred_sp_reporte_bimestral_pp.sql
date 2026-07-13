CREATE PROCEDURE "informix".sp_reporte_bimestral_pp()
RETURNING   CHAR(5) 	AS retorno; --,
            --CHAR(100)   AS mensaje_ret;

--DeclaraciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n de variables.

DEFINE v_num_producto           CHAR(4);
DEFINE v_num_producto_ext           CHAR(4);
DEFINE v_num_credito            CHAR(20);          
DEFINE v_num_cliente            CHAR(20);
DEFINE v_reestructura           SMALLINT;
DEFINE v_fecha_apertura         CHAR(12);
DEFINE v_fecha_ult_dispo        CHAR(12);
DEFINE v_fecha_ult_dispo_date		DATE;
DEFINE v_num_disposiciones      SMALLINT;
DEFINE v_fecha_vencimiento      CHAR(12);
DEFINE v_periodo_facturacion    SMALLINT;
DEFINE v_plazo_total            DECIMAL(18,2);     
DEFINE v_linea_autorizada       DECIMAL(18,2);
DEFINE v_mec_pago               SMALLINT;
DEFINE v_fecha_corte_date		DATE;
DEFINE v_fecha_corte            CHAR(12);
DEFINE v_saldo_cierre           DECIMAL(18,2);
DEFINE v_monto_exigible         DECIMAL(18,2);
DEFINE v_capital_exigible       DECIMAL(18,2);
DEFINE v_mto_exig_pago_int      DECIMAL(18,2);
DEFINE v_mto_exig_pago_int1      DECIMAL(18,2);
DEFINE v_mto_exig_pago_comisiones DECIMAL(18,2);
DEFINE v_mto_exig_pago_iva      DECIMAL(18,2);
DEFINE v_mto_exig_pago_iva1      DECIMAL(18,2);
DEFINE v_mto_exig_x_comis_faltapago DECIMAL(18,2);
DEFINE v_pago_realizado        DECIMAL(18,2);
DEFINE v_pago_capital          DECIMAL(18,2);
DEFINE v_pago_realizado_x_int  DECIMAL(18,2);
DEFINE v_pago_x_comisiones     DECIMAL(18,2);
DEFINE v_pago_x_mora     		DECIMAL(18,2);
DEFINE v_pago_x_iva_mora     	DECIMAL(18,2);
DEFINE v_pago_realizado_x_iva  DECIMAL(18,2);
DEFINE v_pago_x_comis_faltapago DECIMAL(18,2);   
DEFINE v_condonaciones          DECIMAL(18,2);
DEFINE v_indic_garantias        SMALLINT;
DEFINE v_num_garantias          SMALLINT;
DEFINE v_porcentaje_pago        DECIMAL(18,2);
DEFINE v_dias_atraso            SMALLINT;
DEFINE v_atr                    DECIMAL(18,2);
DEFINE v_max_atr                DECIMAL(18,2);
DEFINE v_meses_bkatr            INTEGER;
DEFINE v_delegada               SMALLINT;
DEFINE v_monto_a_pagar_reportado  DECIMAL(18,2);
DEFINE v_sdo_reportado_sic      DECIMAL(18,2);
DEFINE v_antiguedad_cliente     INTEGER;
DEFINE v_metodologia            SMALLINT;
DEFINE v_probabilidad_incump_interna DECIMAL(18,2);
DEFINE v_severidad_perdida_interna  DECIMAL(18,2);
DEFINE v_exp_incumplimiento_interna DECIMAL(18,2);
DEFINE v_mto_reservas           DECIMAL(18,2);    
DEFINE iSqlErr      					INTEGER;
DEFINE iIsamErr         				INTEGER;
DEFINE cErrorInfo       				CHAR(100);
DEFINE cCodRet          				CHAR(6);
DEFINE cMensajeRet    					CHAR(100);
DEFINE v_sucursal                       char(4);
DEFINE v_empresa                     	CHAR(3); 
DEFINE v_alto                          SMALLINT;
DEFINE v_medio                         SMALLINT;
DEFINE v_bajo                          SMALLINT;
DEFINE v_tasa_interes                  DECIMAL(18,2);
DEFINE v_status_cred                   CHAR(2);
DEFINE v_calif_cred                    SMALLINT;
DEFINE v_clave_cons                    CHAR(20);
DEFINE v_segmento_riesgo               SMALLINT;
DEFINE v_relacion_con_institucion      SMALLINT;
DEFINE v_cte_relevante				   SMALLINT;	
DEFINE v_cociente                      DECIMAL(18,2);
DEFINE v_expo_incumpl_total            SMALLINT;
DEFINE v_mto_total_reservas            DECIMAL(18,2);
DEFINE v_cat_originacion               DECIMAL(18,2);
DEFINE v_cat_publicidad                DECIMAL(18,2);
DEFINE pPeriodo              		   DATE;
DEFINE piniPeriodo					   DATE;
DEFINE flag_aniobis					   INTEGER;
DEFINE v_num_solicitud_sic			   CHAR(20);
DEFINE v_mto_exig_x_mora DECIMAL(18,2);
DEFINE v_mto_exig_x_iva_mora DECIMAL(18,2);
DEFINE v_dia_corte  CHAR(2);
DEFINE v_mto_pago_int DECIMAL(18,2);
DEFINE c_CodRet                          CHAR(6); 
DEFINE mMensaje                         VARCHAR(100,1); 
DEFINE dFechaPer0                       DATE; 
DEFINE dFechaPer1                       DATE; 
DEFINE dFechaPer2                       DATE;
DEFINE dFechaPer3                       DATE; 
DEFINE dFechaPer4                       DATE; 
DEFINE dFechaPer5                       DATE; 
DEFINE dFechaPer6                       DATE; 
DEFINE dFechaPer7                       DATE; 
DEFINE v_facturacion					CHAR(2);
DEFINE cRuta CHAR (50);
DEFINE cBitCamp CHAR (50);
DEFINE cCadena  CHAR (1500);
DEFINE vfec_cons DATE;
DEFINE v_cred_externo CHAR(20);

--INICIALIZACION DE VARIABLES

LET v_num_producto           ="";
LET v_num_producto_ext           ="";
LET v_num_credito            ="";        
LET v_num_cliente            ="";
LET v_reestructura           =0;
LET v_fecha_apertura         ="";
LET v_fecha_ult_dispo        ="";
LET v_fecha_ult_dispo_date	 =DATE(1);
LET v_num_disposiciones      =0;
LET v_fecha_vencimiento      ="";
LET v_periodo_facturacion    =0;
LET v_plazo_total            =0;  
LET v_linea_autorizada       =0;
LET v_mec_pago               =0;
LET v_fecha_corte_date		=DATE(1);
LET v_fecha_corte            ="";
LET v_saldo_cierre           =0;
LET v_monto_exigible         =0;
LET v_capital_exigible       =0;
LET v_mto_exig_pago_int      =0;
LET v_mto_exig_pago_int1      =0;
LET v_mto_exig_pago_comisiones =0;
LET v_mto_exig_pago_iva      =0;
LET v_mto_exig_pago_iva1      =0;
LET v_mto_exig_x_comis_faltapago =0;
LET v_pago_realizado        =0;
LET v_pago_capital          =0;
LET v_pago_realizado_x_int  =0;
LET v_pago_x_comisiones     =0;
LET v_pago_realizado_x_iva  =0;
LET v_pago_x_comis_faltapago =0;
LET v_condonaciones          =0;
LET v_indic_garantias        =0;
LET v_num_garantias          =0;
LET v_porcentaje_pago        =0;
LET v_dias_atraso            =0;
LET v_atr                    =0;
LET v_max_atr                =0;
LET v_meses_bkatr            =0;
LET v_delegada               =0;
LET v_monto_a_pagar_reportado  =0;
LET v_sdo_reportado_sic      =0;
LET v_antiguedad_cliente     =0;
LET v_metodologia            =0;
LET v_probabilidad_incump_interna =0;
LET v_severidad_perdida_interna  =0;
LET v_exp_incumplimiento_interna =0;
LET v_mto_reservas           =0;
LET iSqlErr                         = 0;
LET iIsamErr         				= 0;
LET cErrorInfo       				= "";
LET cCodRet          				= "00000";
LET cMensajeRet    					= "REPORTE BIMESTRAL PRESTAMOS se realizÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³ correctamente";
LET v_empresa              			= '001';
LET v_sucursal                      ='';
LET v_alto                          =0;
LET v_medio                         =0;
LET v_bajo                          =0;
LET v_tasa_interes                  =0;
LET v_status_cred                   ='';
LET v_calif_cred                    =0;
LET v_clave_cons                    ='0';
LET v_segmento_riesgo               =0;
LET v_relacion_con_institucion      =0;
LET v_cte_relevante				    =0;
LET v_cociente                      =0;
LET v_expo_incumpl_total            =0;
LET v_mto_total_reservas            =0;
LET v_cat_originacion               =0;
LET v_cat_publicidad                =0;
LET v_num_solicitud_sic				='';
LET v_pago_x_mora     		=0;
LET v_pago_x_iva_mora     	=0;
LET v_mto_exig_x_mora 		=0;
LET v_mto_exig_x_iva_mora 	=0;
LET v_dia_corte  ='';
LET v_mto_pago_int		=0;
LET c_CodRet                         =""; 
LET mMensaje                        ="";  
LET dFechaPer0                      =DATE(1); 
LET dFechaPer1                      =DATE(1); 
LET dFechaPer2                      =DATE(1);
LET dFechaPer3                      =DATE(1); 
LET dFechaPer4                      =DATE(1); 
LET dFechaPer5                      =DATE(1); 
LET dFechaPer6                      =DATE(1); 
LET dFechaPer7                      =DATE(1); 
LET v_facturacion					='';
LET cRuta = '';
LET cBitCamp = '';
LET cCadena = '';
LET vfec_cons =DATE(1);
LET v_cred_externo ='';


BEGIN
    --Errores no controlados.
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;

          RETURN cCodRet; --, cMensajeRet;
    END EXCEPTION;

    --SET DEBUG FILE TO "/resplogifx/archivoscontabilidad/sp_reporte_bimestral_pp.out";
    --TRACE ON;


    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;

   -- LET pPeriodo = mdy(month(today),1,year(today)) - 1 units day;
   --IPCB  Se cambia por consulta a la BD
	SELECT pri_dia_mes-1 units day , pri_dia_mes-2 units month  
	INTO pPeriodo, piniPeriodo
	FROM bdicred:sd_fechas;
	
	LET cRuta="/resplogifx/archivosriesgos/";	
	LET cBitCamp="bimestral_pp";
	LET cBitCamp= TRIM(cBitCamp)||'_'||YEAR(today)||LPAD(MONTH(today),2,0)||LPAD(DAY(today),2,0)||'.unl';

--Reproceso de diciembre
--LET pPeriodo = mdy('12','31','2018');
--LET piniPeriodo = mdy('11','01','2018');
--Reproceso de Junio	

--Valida Anio Bisiesto
IF mod(year(pPeriodo),4) = 0 AND ((mod(year(pPeriodo),4)) = 0 OR (mod(year(pPeriodo),4) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;
	
	--AAME 2021-02-03 RQM 10 1177 Se modifica para contemplar los 2 nuevos productos de prestamo (9100,9300)
    ---FOREACH WITH HOLD
        
        SELECT  num_producto, 
        num_credito, 
        num_cliente, 
        50 as Reestructura,
        TO_CHAR(fecha_apertura, '%Y/%m/%d') as fecha_apertura, 
        num_disposiciones, 
        TO_CHAR(fecha_vencimiento, '%Y/%m/%d') as fecha_vencimiento, 
        50 as Periodo_Facturacion, 
        --round(((fecha_vencimiento-fecha_apertura)/30.4),2) as plazo_total, 
	((fecha_vencimiento-fecha_apertura)/30.4) as plazo_total, 
        linea_autorizada, 
        10 as mec_pago,  
		fecha_corte as fecha_corte_date,
        TO_CHAR(fecha_corte, '%Y/%m/%d') as fecha_corte, 
        saldo_cierre,   
        monto_exigible, 
        capital_exigible, 
        (interes_vencido_bal+interes_vigente+interes_vencido_ord)as Mto_exig_pago_int,
        0.00 as mto_exig_pago_comisiones, 
        (iva_interes_vencido_bal + iva_interes_vencido_ord+ iva_interes_vigente) as mto_exig_pago_iva, 
        0.00 as mto_exig_x_comis_faltapago, 
        pago_realizado, 
		pago_capital, 
        (pago_int_venc_bal + pago_int_venc_ord + pago_interes_vigente)as pago_realizado_x_int,
		--(pago_interes_vigente)as pago_realizado_x_int,
        0.00 as pago_x_comisiones, 
        (pago_iva_int_venc_bal + pago_iva_int_venc_ord + pago_iva_interes_vigente) as pago_realizado_x_iva,
		--(pago_iva_interes_vigente) as pago_realizado_x_iva,
        0.00 as pago_x_comis_faltapago, 
		status_fin_mes,
        0.00 as condonaciones, 
        1 as indic_garantias, 
        0 as num_garantias, 
        porcentaje_pago,    
        dias_atraso, 
        atr, 
        max_atr, 
        meses_bkatr,
        delegada, 
        (monto_pagar_propios+monto_pagar_otros) as Monto_a_pagar_reportado,
		saldo_sic,
        antiguedad_cliente, 
        0 as metodologia, 
        0 as probabilidad_incump_interna, 
        0 as severidad_perdida_interna, 
        0 as exp_incumplimiento_interna, 
        0 as mto_reservas,
        alto,
        medio,
        bajo, 
		80.9 as cat_publicidad, 
		facturacion,
		fecha_ulm_disp as fecha_ulm_disp_date,
	TO_CHAR(fecha_ulm_disp, '%Y/%m/%d') as fecha_ulm_disp
        FROM sd_insumos_calif_pp 
        WHERE num_producto in('6300', '7600', '7700', '6800','9100','9300')
		and fecha_cierre=pPeriodo --MES PAR
		and num_credito not in(select num_credito from sd_reporte_bimestral_pp where fecha_cierre=pPeriodo)
		INTO TEMP universo_cred with no log;
		--UNION
		
		insert into universo_cred
		SELECT a.num_producto, 
        a.num_credito, 
        num_cliente, 
        500 as Reestructura,
        a.fecha_apertura, 
        num_disposiciones, 
        fecha_vencimiento, 
        50 as Periodo_Facturacion, 
        --round(((fecha_vencimiento-fecha_apertura)/30.4),2) as plazo_total, 
		(((b.fecha_vencim)-(b.fecha_apertura))/30.4) as plazo_total,
        linea_autorizada, 
        10 as mec_pago,  
	TO_DATE(a.fecha_corte,'%Y/%m/%d'),
        a.fecha_corte,
        saldo_cierre,   
        monto_exigible, 
        capital_exigible, 
        (interes_vencido_bal+interes_vigente+interes_vencido_ord)as Mto_exig_pago_int,
        0.00 as mto_exig_pago_comisiones, 
        (iva_interes_vencido_bal + iva_interes_vencido_ord+ iva_interes_vigente) as mto_exig_pago_iva, 
        0.00 as mto_exig_x_comis_faltapago, 
        pago_realizado, 
		pago_capital, 
        (pago_int_venc_bal + pago_int_venc_ord + pago_interes_vigente)as pago_realizado_x_int,
		--(pago_interes_vigente)as pago_realizado_x_int,
        0.00 as pago_x_comisiones, 
        (pago_iva_int_venc_bal + pago_iva_int_venc_ord + pago_iva_interes_vigente) as pago_realizado_x_iva,
		--(pago_iva_interes_vigente) as pago_realizado_x_iva,
        0.00 as pago_x_comis_faltapago, 
		status_fin_mes,
        0.00 as condonaciones, 
        1 as indic_garantias, 
        0 as num_garantias, 
        porcentaje_pago,    
        dias_atraso, 
        atr, 
        max_atr, 
        meses_bkatr,
        delegada, 
        (monto_pagar_propios+monto_pagar_otros) as Monto_a_pagar_reportado,
		saldo_sic,
        antiguedad_cliente, 
        0 as metodologia, 
        0 as probabilidad_incump_interna, 
        0 as severidad_perdida_interna, 
        0 as exp_incumplimiento_interna, 
        0 as mto_reservas,
        alto,
        medio,
        bajo, 
		80.9 as cat_publicidad, 
		facturacion,
		b.fecha_apertura,
	    a.fecha_apertura
        FROM sd_insumos_calif_reest_pp a
        inner join sd_maecredcontcrd b
        on a.num_credito=b.num_credito and a.num_producto=b.num_producto and a.fecha_cierre=b.fecha
        WHERE a.num_producto in('8600')
		and fecha_cierre=pPeriodo --MES PAR
		and a.num_credito not in(select num_credito from sd_reporte_bimestral_pp where fecha_cierre=pPeriodo);
		
		
		FOREACH WITH HOLD
			select num_producto,num_credito,num_cliente,reestructura,fecha_apertura,num_disposiciones,fecha_vencimiento,periodo_facturacion,plazo_total,linea_autorizada,mec_pago,fecha_corte_date,
		fecha_corte,saldo_cierre,monto_exigible,capital_exigible,mto_exig_pago_int, mto_exig_pago_comisiones, mto_exig_pago_iva,mto_exig_x_comis_faltapago,pago_realizado,pago_capital,
		pago_realizado_x_int, pago_x_comisiones,pago_realizado_x_iva,pago_x_comis_faltapago,status_fin_mes,condonaciones,indic_garantias,num_garantias,porcentaje_pago,dias_atraso,atr,max_atr,
		meses_bkatr,delegada, monto_a_pagar_reportado,saldo_sic, antiguedad_cliente,metodologia,probabilidad_incump_interna,severidad_perdida_interna, exp_incumplimiento_interna,mto_reservas,
		alto, medio,bajo,cat_publicidad,facturacion,fecha_ulm_disp_date,fecha_ulm_disp
			INTO v_num_producto, v_num_credito, v_num_cliente, v_reestructura, v_fecha_apertura,v_num_disposiciones, v_fecha_vencimiento,      
        v_periodo_facturacion, v_plazo_total, v_linea_autorizada, v_mec_pago, v_fecha_corte_date,v_fecha_corte, v_saldo_cierre, v_monto_exigible, v_capital_exigible,      
        v_mto_exig_pago_int, v_mto_exig_pago_comisiones, v_mto_exig_pago_iva, v_mto_exig_x_comis_faltapago, v_pago_realizado, v_pago_capital,
        v_pago_realizado_x_int, v_pago_x_comisiones, v_pago_realizado_x_iva, v_pago_x_comis_faltapago, v_status_cred, v_condonaciones, v_indic_garantias,
        v_num_garantias, v_porcentaje_pago, v_dias_atraso, v_atr, v_max_atr, v_meses_bkatr, v_delegada, v_monto_a_pagar_reportado, v_sdo_reportado_sic,
		v_antiguedad_cliente,v_metodologia, v_probabilidad_incump_interna, v_severidad_perdida_interna, v_exp_incumplimiento_interna, v_mto_reservas, 
        v_alto,v_medio, v_bajo,v_cat_publicidad,v_facturacion,v_fecha_ult_dispo_date, v_fecha_ult_dispo 
		FROM universo_cred


        IF v_num_producto<>'6800' THEN
            LET v_fecha_ult_dispo=v_fecha_apertura;
        END IF;
	
	/*SELECT moratorios_tc, iva_moratorios_tc 
	INTO v_mto_exig_x_mora, v_mto_exig_x_iva_mora
	FROM sd_encabezado2_edoctacrd 
	WHERE num_credito=v_num_credito 
	AND fecha_emision=v_fecha_corte_date;*/
	
	/*SELECT sdo_contab_mora+sdo_moratorio, nvl(round((sdo_contab_mora + sdo_moratorio) * (0.16),2),0)
	INTO v_mto_exig_x_mora, v_mto_exig_x_iva_mora
	FROM bdicred:sd_maesdoshistcrd
	WHERE num_credito =v_num_credito and fecha= (v_fecha_corte_date -1 units day);*/---ACC
	
	
	
	IF MONTH(v_fecha_corte_date)=12 THEN
		IF DAY(v_fecha_corte_date)=26 THEN
			SELECT sdo_contab_mora+sdo_moratorio, nvl(round((sdo_contab_mora + sdo_moratorio) * (0.16),2),0)
			INTO v_mto_exig_x_mora, v_mto_exig_x_iva_mora
			FROM bdicred:sd_maesdoshistcrd
			WHERE num_credito =v_num_credito and fecha= (v_fecha_corte_date -2 units day);
		ELSE
			SELECT sdo_contab_mora+sdo_moratorio, nvl(round((sdo_contab_mora + sdo_moratorio) * (0.16),2),0)
			INTO v_mto_exig_x_mora, v_mto_exig_x_iva_mora
			FROM bdicred:sd_maesdoshistcrd
			WHERE num_credito =v_num_credito and fecha= (v_fecha_corte_date -1 units day);
		END IF
	ELSE	
		SELECT sdo_contab_mora+sdo_moratorio, nvl(round((sdo_contab_mora + sdo_moratorio) * (0.16),2),0)
		INTO v_mto_exig_x_mora, v_mto_exig_x_iva_mora
		FROM bdicred:sd_maesdoshistcrd
		WHERE num_credito =v_num_credito and fecha= (v_fecha_corte_date -1 units day);
	END IF;
	
	
	  
	
	--LET v_pago_realizado_x_int=v_pago_realizado_x_int+ NVL(v_mto_pago_int,0); ACC
	
	SELECT LIMIT 1 num_solicitud_sic 
	INTO v_num_solicitud_sic 
	FROM bdisolic:ss_solicitudes_sic
	WHERE numcte=v_num_cliente
	AND fecha_insert in(select max(fecha_insert) FROM bdisolic:ss_solicitudes_sic
						WHERE numcte=v_num_cliente);
						
	/*SELECT LIMIT 1 nvl(folio_bc,'0'),
	INTO v_clave_cons
	FROM bdisolic:ss_solicitudes_sic
	WHERE numcte=v_num_cliente
	and num_solicitud=v_num_solicitud_sic
	AND fecha_insert in(select max(fecha_insert) FROM bdisolic:ss_solicitudes_sic
						WHERE numcte=v_num_cliente and num_solicitud=v_num_solicitud_sic);*/
						
	SELECT  limit 1  nvl(folio_bc,'0'), nvl(fecha_sic,date(0)) fecha_consulta_bc
	INTO v_clave_cons, vfec_cons
	FROM bdisolic:ss_solicitudes_sic
	WHERE numcte=v_num_cliente
	and num_solicitud=v_num_solicitud_sic;
	
	IF v_clave_cons = 0 THEN
		select limit 1 max(es03) INTO v_clave_cons
		from bdiburo:br_es
		where num_cliente =v_num_cliente and institucion = 'BC'
		and fecha = vfec_cons;
	END IF;
	
	/*SELECT folio_bc
	INTO v_clave_cons
	FROM bdisolic:ss_solicitudes_sic
	WHERE num_solicitud=v_num_credito;*/
	

        SELECT tasa_interes INTO v_tasa_interes
        FROM sd_maecredcrd
        WHERE num_credito= v_num_credito;

        SELECT cat, dia_corte INTO v_cat_originacion, v_dia_corte
        FROM sd_maecredanexocrd 
        WHERE num_credito= v_num_credito;
		
		IF v_num_producto ='6800' THEN 
			EXECUTE PROCEDURE sp_calcula_fechas_porperiodo_calif('001',v_facturacion,v_num_producto,day(v_fecha_ult_dispo_date),pPeriodo)
			INTO c_CodRet, mMensaje, dFechaPer0, dFechaPer1, dFechaPer2, dFechaPer3, dFechaPer4, dFechaPer5, dFechaPer6,dFechaPer7;
		ELSE
			EXECUTE PROCEDURE sp_calcula_fechas_porperiodo_calif('001',v_facturacion,v_num_producto,v_dia_corte,pPeriodo)
			INTO c_CodRet, mMensaje, dFechaPer0, dFechaPer1, dFechaPer2, dFechaPer3, dFechaPer4, dFechaPer5, dFechaPer6,dFechaPer7;
		END IF;
		
		SELECT
		SUM(case when codigo_ref =2 then monto else 0 end) pago_mora,
		SUM(case when codigo_ref = 3 then monto else 0 end) pago_ivamora,
		SUM(case when codigo_ref = 7 then monto else 0 end) pago_int
		INTO v_pago_x_mora, v_pago_x_iva_mora, v_mto_pago_int
		FROM bdicred:sd_movhiscrd
		WHERE empresa = '001'
		AND fecha_mov <= v_fecha_corte_date --'20181217'
		AND fecha_mov >= dFechaPer1 + 1 units day  --'20181118'
		AND num_credito =v_num_credito
		and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd)
		and codigo_ref in (2,3,7)
		AND reversado = 'N';
        
        IF v_status_cred ='AA' OR v_status_cred='BA' or ((v_status_cred in ('E1') AND v_atr=0 and v_dias_atraso=0) or (v_status_cred in ('E1') AND v_atr=1 and (v_dias_atraso>0 and v_dias_atraso<30)) or (v_status_cred in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90))) THEN
            LET v_calif_cred=1;
        ELIF v_status_cred ='BT' or (v_status_cred in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90))  THEN
            LET v_calif_cred=5;
        END IF;

        --LET v_clave_cons=v_num_credito;

        IF v_alto=1 THEN
            LET v_segmento_riesgo=1;
        ELIF v_medio=1 THEN
            LET v_segmento_riesgo=2;
        ELIF v_bajo=1 THEN
            LET v_segmento_riesgo=3;
        END IF;     

		IF v_sdo_reportado_sic>0 THEN
			LET v_cociente=(v_monto_a_pagar_reportado/v_sdo_reportado_sic);
		END IF;
		LET v_relacion_con_institucion=1;
		
		/*select count(num_cliente) INTO v_cte_relevante
		from cat_ctes_rel
		where num_cliente=v_num_cliente;
		
		IF v_cte_relevante>0 THEN 
			LET v_relacion_con_institucion=7;
		ELSE
			LET v_relacion_con_institucion=1;
		END IF*/
		

	/*IF v_dia_corte IN(29,30,31) AND month(pPeriodo)='02' THEN
		SELECT int_venc_bal27 + intvig27 + (((intvenc27)-(int_venc_bal27))),ivaint_venc_bal27 + ((ivaintvenc27)-(ivaint_venc_bal27)) + ivaintvig27
                                INTO v_mto_exig_pago_int,v_mto_exig_pago_iva
                                FROM bdicred:sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=mdy(month(pPeriodo),'01',year(pPeriodo)); 
	END IF;*/--esta validacion ya esta en los insumos de calificacion
	
	/*IF v_dia_corte ='1' AND month(pPeriodo)='02' THEN
		SELECT int_venc_bal27, ivaint_venc_bal27
        INTO v_mto_exig_pago_int1,v_mto_exig_pago_iva1
        FROM bdicred:sd_sdodiariocrd
        WHERE num_credito=v_num_credito and fecha=mdy(month(pPeriodo),'01',year(pPeriodo)); 
		
		LET v_mto_exig_pago_int=v_mto_exig_pago_int+ NVL(v_mto_exig_pago_int1,0);
		LET v_mto_exig_pago_iva=v_mto_exig_pago_iva+ NVL(v_mto_exig_pago_iva1,0);
	END IF;*/-- esta validacion ya esta en los insumos de calificacion
		
	IF v_num_disposiciones = 0 THEN
		let v_num_disposiciones=1;
	END IF;	
	
	IF v_clave_cons='' OR v_clave_cons=' ' THEN
		let v_clave_cons='0';
	END IF;

	--IF EXISTS (select credito_externo from sd_maecredcrd where NUM_CREDITO=v_num_credito) THEN
	IF v_num_producto='8600' THEN
	---IF (select credito_externo from sd_maecredcrd where NUM_CREDITO=v_num_credito) <>'' THEN	
		select credito_externo into v_cred_externo 
		from sd_maecredcrd where NUM_CREDITO=v_num_credito;
	  
		SELECT num_producto INTO v_num_producto_ext FROM sd_maecredcrd where num_credito =v_cred_externo;
		LET v_num_producto=v_num_producto_ext;
		
		/*select status_cred, fecha_apertura, fecha_vencim, tasa_interes into v_status_cred, v_fecha_apertura, v_fecha_vencimiento, v_tasa_interes
		from sd_maecredcontcrd where NUM_CREDITO=v_num_credito and fecha=pPeriodo;*/
		
		/*select monto_otorgado into v_linea_autorizada 
		from sd_maesdoscrd where NUM_CREDITO=v_num_credito;*/
		
		/*select dia_corte INTO v_dia_corte
		from sd_maecredanexocrd where NUM_CREDITO=v_num_credito;*/
		
		select NVL(monto_condonado,0) INTO v_condonaciones
		from sd_bitacora_quitacondonacion where num_credito=v_num_credito;
		
		/*EXECUTE PROCEDURE sp_calcula_fechas_porperiodo_calif('001','M','8600',v_dia_corte,pPeriodo)
		INTO c_CodRet, mMensaje, dFechaPer0, dFechaPer1, dFechaPer2, dFechaPer3, dFechaPer4, dFechaPer5, dFechaPer6,dFechaPer7;*/
		
		IF v_status_cred IN('AA','BA') or ((v_status_cred in ('E1') AND v_atr=0 and v_dias_atraso=0) or (v_status_cred in ('E1') AND v_atr=1 and (v_dias_atraso>0 and v_dias_atraso<30)) or (v_status_cred in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)))THEN
			LET v_calif_cred=1;
		ELIF v_status_cred IN('BT','VP') or (v_status_cred in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90)) THEN
			LET v_calif_cred=5;
		END IF;
		
		--LET v_fecha_corte = dFechaPer0;		
		--LET v_num_credito=v_cred_externo;
		LET v_reestructura=500;
	END IF;

        BEGIN WORK;
            INSERT INTO sd_reporte_bimestral_pp ( fecha_cierre, num_producto, num_credito, num_cliente, reestructura, fecha_apertura, fecha_ult_disposicion,
                        num_disposiciones, fecha_vencimiento, escala_facturacion, plazo_total, linea_autorizada, tasa_interes, mecanismo_pago,
                        fecha_corte, saldo_cierre, monto_exigible, capital_exigible, mto_exigible_pago_int, mto_exig_pago_comis, mto_exig_pago_iva,
                        mto_exig_comis_falta_pago, pago_realizado, pago_capital, pago_realizado_int, pago_realizado_comis, pago_realizado_iva,
                        pago_realizado_comis_falta_pago, clasif_credito, condonaciones, relacion_con_institucion, clave_consulta, indic_garantia,
                        num_garantias, porcentaje_pago, dias_atraso, atr, max_atr, meses_bkatr, delegada, segmento_riesgo, mto_pagar_reportado_sic,
                        sdo_reportado_sic, cociente, antiguedad_cliente, expo_incumpl_total, mto_total_reservas, metodologia_calc_reserv, probab_incumpl_interno,
                        severidad_perd_interna, expo_incumpl_interna, mto_de_reservas, cat_originacion, cat_publicidad,pago_realizado_x_mora,pago_realizado_x_ivamora,  
						monto_exig_x_mora,monto_exig_x_ivamora)
                 VALUES( pPeriodo, v_num_producto, v_num_credito, v_num_cliente, v_reestructura, v_fecha_apertura,v_fecha_ult_dispo,v_num_disposiciones, v_fecha_vencimiento,      
                        v_periodo_facturacion, v_plazo_total, v_linea_autorizada, v_tasa_interes, v_mec_pago, v_fecha_corte, v_saldo_cierre, v_monto_exigible, v_capital_exigible,      
                        v_mto_exig_pago_int, v_mto_exig_pago_comisiones, v_mto_exig_pago_iva, v_mto_exig_x_comis_faltapago, v_pago_realizado, v_pago_capital,
                        v_pago_realizado_x_int, v_pago_x_comisiones, v_pago_realizado_x_iva, v_pago_x_comis_faltapago, v_calif_cred,v_condonaciones, v_relacion_con_institucion, NVL(v_clave_cons,'0'),v_indic_garantias,
                        v_num_garantias, v_porcentaje_pago, v_dias_atraso, v_atr, v_max_atr, v_meses_bkatr, v_delegada, v_segmento_riesgo, v_monto_a_pagar_reportado, 
                        v_sdo_reportado_sic, v_cociente, v_antiguedad_cliente,v_expo_incumpl_total, v_mto_total_reservas, v_metodologia, v_probabilidad_incump_interna, 
                        v_severidad_perdida_interna, v_exp_incumplimiento_interna, v_mto_reservas, v_cat_originacion, v_cat_publicidad,v_pago_x_mora,v_pago_x_iva_mora,
						v_mto_exig_x_mora,v_mto_exig_x_iva_mora);

		COMMIT WORK;
	
	END FOREACH; 
	
	LET cCadena = '';
	LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCamp)  ||'  delimiter '';'' SELECT num_producto,num_credito,num_cliente,reestructura,fecha_apertura,fecha_ult_disposicion,num_disposiciones,fecha_vencimiento,escala_facturacion,plazo_total,linea_autorizada,tasa_interes,mecanismo_pago,fecha_corte,saldo_cierre,monto_exigible,capital_exigible,mto_exigible_pago_int,mto_exig_pago_comis,mto_exig_pago_iva,mto_exig_comis_falta_pago,pago_realizado,pago_capital,pago_realizado_int,pago_realizado_comis,pago_realizado_iva,pago_realizado_comis_falta_pago,clasif_credito,condonaciones,relacion_con_institucion,clave_consulta,indic_garantia,num_garantias,porcentaje_pago,dias_atraso,atr,max_atr,meses_bkatr,delegada,segmento_riesgo,mto_pagar_reportado_sic,sdo_reportado_sic,cociente,antiguedad_cliente,expo_incumpl_total,mto_total_reservas,metodologia_calc_reserv,probab_incumpl_interno,severidad_perd_interna,expo_incumpl_interna,mto_de_reservas,cat_originacion,cat_publicidad,pago_realizado_x_mora,pago_realizado_x_ivamora,monto_exig_x_mora,monto_exig_x_ivamora FROM bdicred:"informix".sd_reporte_bimestral_pp WHERE fecha_cierre= ''' ||mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo))|| '''" >'||TRIM(cRuta)||'bimestral_pp.sql';
	SYSTEM cCadena;				
	LET cCadena='chmod 777 '|| TRIM(cRuta)||'bimestral_pp.sql';
	System cCadena;				
	let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bimestral_pp.sql';
	System cCadena;				
	LET cCadena = '' ;
	LET cCadena = 'rm ' || TRIM(cRuta) || 'bimestral_pp.sql';
	SYSTEM cCadena;
	
	
    LET cCodRet     = "00000";
    LET cMensajeRet = "REPORTE DE BIMESTRALES PP OK ";

	RETURN cCodRet; --, cMensajeRet;
END
END PROCEDURE;