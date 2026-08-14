CREATE PROCEDURE "informix".sp_generainfo_automatiza_800(pFecha DATE)
RETURNING CHAR(6), CHAR(80); 
          
DEFINE cCodRet             CHAR(6); 
DEFINE cCodRet_2           CHAR(6); 
DEFINE cMensajeRet         CHAR(80);
DEFINE iSqlErr             INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);
DEFINE cSql                CHAR(2000);
DEFINE cNombreArchivo1     CHAR(50); 
DEFINE cNombreArchivo      CHAR(50);
DEFINE cRuta               CHAR(100);
DEFINE cEmpresa            CHAR(3);
DEFINE cSeparador          CHAR(1);
DEFINE cSql_c              CHAR(250);
DEFINE cMensaje            CHAR(80);
DEFINE iParam              SMALLINT;
DEFINE vproceso			   CHAR(06);
DEFINE cCodRetIB           CHAR(6);
DEFINE dtFecha_hoy         DATE;
DEFINE cEjecuc_1a_vez      CHAR(1);
DEFINE v_num_credito       CHAR(20);
DEFINE v_numcte            CHAR(20);
DEFINE dt_fecha_ultima_compra DATE;
DEFINE dt_atm_disp_fecha      DATE;
DEFINE dt_vnt_disp_fecha      DATE;
DEFINE dt_Fecha_ult_mov       DATE;
DEFINE d_monto_ultima_compra DECIMAL(18,2);
DEFINE d_atm_disp_monto      DECIMAL(18,2);
DEFINE d_vnt_disp_monto      DECIMAL(18,2);
DEFINE d_monto_ult_mov       DECIMAL(18,2);
DEFINE v_correo_elec         CHAR(100);
DEFINE v_cod_postal          CHAR(5); 
DEFINE v_numeroextcalle      CHAR(10);
DEFINE v_numerointcalle      CHAR(10);
DEFINE v_nombrezona          CHAR(32);
DEFINE v_municipiozona       CHAR(27);
DEFINE v_calle               CHAR(30);
DEFINE v_nom_estado          CHAR(30);
DEFINE dtFecha_diaprev       DATE;
DEFINE dt_fecha_ultimo_pago  DATE;
DEFINE d_monto_ult_pago      DECIMAL(18,2);
DEFINE d_monto_ult_pago_a    DECIMAL(18,2);
DEFINE v_telefono            CHAR(13);
DEFINE v_tel_cel             CHAR(13);
DEFINE d_saldo_autorizado    DECIMAL(18,2);
DEFINE i_pagos_vencidos      INTEGER;
DEFINE i_pagos_vencidos_a    INTEGER;
DEFINE d_pago_minimo         DECIMAL(18,2);
DEFINE d_pago_minimo_a       DECIMAL(18,2);

DEFINE d_pago_una_mora       DECIMAL(18,2);
DEFINE d_saldo_vencido       DECIMAL(18,2);
DEFINE d_saldo_vencido_a     DECIMAL(18,2);
DEFINE d_saldo_actual        DECIMAL(18,2);
DEFINE d_saldo_actual_a      DECIMAL(18,2);
DEFINE d_saldo_intereses     DECIMAL(18,2);
DEFINE d_saldo_intereses_a     DECIMAL(18,2);
DEFINE d_saldo_iva           DECIMAL(18,2);
DEFINE d_saldo_iva_a         DECIMAL(18,2);
DEFINE d_saldo_liquidar      DECIMAL(18,2);
DEFINE d_saldo_liquidar_a    DECIMAL(18,2);
DEFINE iActualiza            INTEGER;
DEFINE dt_fecha_dom_actual   DATE;
DEFINE dt_fecha_insert_dom   DATE;
DEFINE dt_fecha_apertura     DATE;
DEFINE c_num_producto        CHAR(4);
DEFINE c_nombre1             CHAR(26);
DEFINE c_nombre2             CHAR(26);
DEFINE c_apell_paterno       CHAR(26);
DEFINE c_apell_materno       CHAR(26);
DEFINE c_rfc                 CHAR(13);
DEFINE dt_fecha_nac          DATE;
DEFINE cNombreArchivo_aux	 CHAR(50); 
DEFINE cNombreArchivo_head   CHAR(14);
DEFINE cGeneraSql			 CHAR(2000); 
DEFINE iGenera_info_dia      INTEGER;
DEFINE c_actualiza_dom       CHAR(1);
DEFINE i_dia_semana          INTEGER;
DEFINE i_dia_saldos          INTEGER;
DEFINE dtFecha_IniMes        DATE;
DEFINE dIntMoratorio         DECIMAL(18,2);
DEFINE dt_fecha_proceso_800  DATE;
DEFINE dtFecha_reg_bita      DATE;

--- Para el consultasaldosgeneral
DEFINE cMensajeRetornoCSG	CHAR(80);
DEFINE cNumeroCreditoCSG	CHAR(20);
DEFINE cCodigoTipcredCSG	CHAR(2);
DEFINE dFechaOrigenCSG		DATE;
DEFINE dFechaProxPago		DATE;
DEFINE dPagoMinimoCSG		DECIMAL(18,2);
DEFINE dFechaUltPagoCSG		DATE;
DEFINE iPlazoCSG			INTEGER;
DEFINE iPagosRealizadosCSG	INTEGER;
DEFINE dLineaOtorgadaCSG	DECIMAL(18,2);
DEFINE dTasaInteresCSG		DECIMAL(9,6);
DEFINE dTasaMoratoriosCSG	DECIMAL(9,6);
DEFINE dMontoSbcCSG			DECIMAL(14,2);
DEFINE dCapVigCSG			DECIMAL(18,2);
DEFINE dCapTransCSG			DECIMAL(18,2);
DEFINE dCapVdoExigCSG		DECIMAL(18,2);
DEFINE dCapVdoNoExigCSG		DECIMAL(18,2);
DEFINE dSdoActTotalCapCSG	DECIMAL(18,2);
DEFINE dIntVigCSG			DECIMAL(18,2);
DEFINE dIntVdoCSG			DECIMAL(18,2);
DEFINE dIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIntMesCSG			DECIMAL(18,2);
DEFINE dSdoActTotalIntCSG	DECIMAL(18,2);
DEFINE dIvaIntVigCSG		DECIMAL(18,2);
DEFINE dIvaIntVdoCSG		DECIMAL(18,2);
DEFINE dIvaIntMoratoriosCSG	DECIMAL(18,2);
DEFINE dIvaIntMesCSG		DECIMAL(18,2);
DEFINE dSdoActTotalIvaCSG	DECIMAL(18,2);
DEFINE dComPendCSG			DECIMAL(18,2);
DEFINE dIvaComCSG			DECIMAL(18,2);
DEFINE dSdoRetenidoCSG		DECIMAL(18,2);
DEFINE dTotalLiquidacionCSG	DECIMAL(18,2);
DEFINE dIntDevengadoCSG		DECIMAL(18,2);
DEFINE dIvaIntDevengadoCSG	DECIMAL(18,2);
DEFINE dLineaDisponibleCSG	DECIMAL(18,2);
DEFINE dPagosVdosCSG		DECIMAL(18,2);
DEFINE cDescStatusCredCSG	CHAR(60);
DEFINE iIdBloqueoCredCSG	INTEGER;
DEFINE cBloqueoCtaCSG		CHAR(60); 
DEFINE cIdCausaBloqueoCSG	CHAR(3);
DEFINE cCausaBloqueoCtaCSG	CHAR(50);
DEFINE cIdSitEspCteCSG		CHAR(1);
DEFINE iIdCausaEspCteCSG	INTEGER;
DEFINE cSitEspCteCSG		CHAR(75);
DEFINE cIdSitEspCredCSG		CHAR(1);
DEFINE iIdCausaEspCredCSG	INTEGER;
DEFINE cSitEspCredCSG		CHAR(75);
--- Para el consultasaldosgeneral

LET cCodRet                = "000000"; 
LET cCodRet_2              = '';
LET cMensajeRet            = 'PROCESO EXITOSO'; 
LET iSqlErr                = 0;
LET iIsamErr               = 0;
LET cErrorInfo             = "";
LET cSql                   = "";
LET cNombreArchivo1        = "";
LET cNombreArchivo         = "";
LET cRuta                  = "";
LET cEmpresa               = '001';
LET cSeparador             = '';
LET cSql_c                 = "";
LET cMensaje               = "";
LET iParam                 = 0;
LET vproceso			   = "0096";
LET cCodRetIB              = "";
LET dtFecha_hoy            = date(1);
LET cEjecuc_1a_vez         = '';
LET dt_fecha_ultima_compra  = date(1);
LET dt_atm_disp_fecha       = date(1);
LET dt_vnt_disp_fecha       = date(1);
LET dt_Fecha_ult_mov        = NULL;
LET d_monto_ultima_compra   = 0;
LET d_atm_disp_monto        = 0;
LET d_vnt_disp_monto        = 0;
LET d_monto_ult_mov         = 0;
LET v_num_credito           = '';
LET v_numcte                = '';
LET v_correo_elec           = '';
LET v_cod_postal            = ''; 
LET v_numeroextcalle        = '';
LET v_numerointcalle        = '';
LET v_nombrezona            = '';
LET v_municipiozona         = '';
LET v_calle                 = '';
LET v_nom_estado            = '';
LET dtFecha_diaprev         = date(1);
LET dt_fecha_ultimo_pago    = date(1);
LET d_monto_ult_pago        = 0;
LET d_monto_ult_pago_a        = 0;
LET v_telefono              = '';
LET v_tel_cel               = '';
LET d_saldo_autorizado      = 0;
LET i_pagos_vencidos        = 0;
LET i_pagos_vencidos_a      = 0;
LET d_pago_minimo           = 0;
LET d_pago_minimo_a           = 0;
LET d_pago_una_mora         = 0;
LET d_saldo_vencido         = 0;
LET d_saldo_vencido_a         = 0;
LET d_saldo_actual          = 0;
LET d_saldo_actual_a        = 0;
LET d_saldo_intereses       = 0;
LET d_saldo_intereses_a     = 0;
LET d_saldo_iva             = 0;
LET d_saldo_iva_a           = 0;
LET d_saldo_liquidar        = 0;
LET d_saldo_liquidar_a        = 0;
LET iActualiza              = 0;
LET dt_fecha_dom_actual     = date(1);
LET dt_fecha_insert_dom     = date(1);
LET dt_fecha_apertura       = date(1);
LET c_num_producto          = '';
LET c_nombre1               = '';
LET c_nombre2               = '';
LET c_apell_paterno         = '';
LET c_apell_materno         = '';
LET c_rfc                   = '';
LET dt_fecha_nac            = date(1); 
LET cNombreArchivo_aux      = '';
LET cNombreArchivo_head     = 'encabezado.txt';
LET cSql                	= ''; 
LET cGeneraSql				= '';	
LET iGenera_info_dia        = 0;
LET c_actualiza_dom         = '';
LET i_dia_semana            = 0;
LET i_dia_saldos            = 0;
LET dtFecha_IniMes          = date(1);
LET dIntMoratorio           = 0;
LET dtFecha_reg_bita        = date(1);

--- Para el consultasaldosgeneral
LET cMensajeRetornoCSG	    = '';
LET cNumeroCreditoCSG	    = '';
LET cCodigoTipcredCSG	    = '';
LET dFechaOrigenCSG		    =DATE(1);
LET dFechaProxPago		    =DATE(1);
LET dPagoMinimoCSG		    = 0;
LET dFechaUltPagoCSG		=DATE(1);
LET iPlazoCSG			    = 0;
LET iPagosRealizadosCSG	    = 0; 
LET dLineaOtorgadaCSG	    = 0;
LET dTasaInteresCSG		    = 0;
LET dTasaMoratoriosCSG      = 0;	
LET dMontoSbcCSG		    = 0;
LET dCapVigCSG			    = 0;
LET dCapTransCSG		    = 0;
LET dCapVdoExigCSG		    = 0;
LET dCapVdoNoExigCSG	    = 0;
LET dSdoActTotalCapCSG	    = 0;
LET dIntVigCSG			    = 0;
LET dIntVdoCSG			    = 0;
LET dIntMoratoriosCSG	    = 0;
LET dIntMesCSG			    = 0;
LET dSdoActTotalIntCSG	    = 0;
LET dIvaIntVigCSG		    = 0;
LET dIvaIntVdoCSG		    = 0;
LET dIvaIntMoratoriosCSG    = 0;
LET dIvaIntMesCSG		    = 0;
LET dSdoActTotalIvaCSG	    = 0;
LET dComPendCSG			    = 0;
LET dIvaComCSG			    = 0;
LET dSdoRetenidoCSG		    = 0;
LET dTotalLiquidacionCSG    = 0;
LET dIntDevengadoCSG	    = 0;
LET dIvaIntDevengadoCSG	    = 0;
LET dLineaDisponibleCSG   	= 0;
LET dPagosVdosCSG		    = 0;
LET cDescStatusCredCSG	    = '';
LET iIdBloqueoCredCSG	    = 0; 
LET cBloqueoCtaCSG		    = '';
LET cIdCausaBloqueoCSG	    = '';
LET cCausaBloqueoCtaCSG	    = '';
LET cIdSitEspCteCSG		    = '';
LET iIdCausaEspCteCSG	    = 0;
LET cSitEspCteCSG		    = '';
LET cIdSitEspCredCSG		= '';
LET iIdCausaEspCredCSG	    = 0;
LET cSitEspCredCSG		    = '';
--- Para el consultasaldosgeneral

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
        LET cCodRet     = iSqlErr;
        LET cMensajeRet = cErrorInfo || ' ' || v_num_credito ;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCodRet,cMensajeRet,"02")
                     INTO cCodRet_2;
       RETURN cCodRet, trim(cMensajeRet); 
    END IF;
END EXCEPTION;

 --SET DEBUG FILE TO "/ifxsif01/macf/sp_generainfo_automatiza_800.out";    
 --TRACE ON; 

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


   EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,"000000","INI PROC. GENERA INFO AUTOM. 800","02")
             INTO cCodRet_2;

   SELECT fecha_hoy INTO dtFecha_hoy
     FROM bdicred:sd_fechas
    WHERE empresa = cEmpresa;
	
	/*LET dtFecha_hoy = MDY('04','11','2021');*/  --- SOLO TESTS p fecha proceso
	
    LET dtFecha_diaprev = dtFecha_hoy - 1;
	
	/*LET dtFecha_diaprev = MDY('12','29','2021');*/  --- SOLO TESTS p fecha info
	
	LET i_dia_semana = weekday(dtFecha_hoy);
	
	LET i_dia_saldos = day(dtFecha_diaprev);
	
	LET dtFecha_IniMes = MDY(month(dtFecha_hoy),'01',year(dtFecha_hoy));
	
	select trim(valor) into cEjecuc_1a_vez
	  from cb_param 
	 where cod_param = 9;
	 
	-- Nombre de archivo
	select valor_alfabetico into cNombreArchivo1 
      from bdicobranza:cb_param_campania       
     where tipo_campania = 1
       and grupo_parametro = 'ARCHIVOS' 
       and num_parametro = 96;
	   
	-- Ruta archivo
	select valor_alfabetico into cRuta 
      from bdicobranza:cb_param_campania       
     where tipo_campania = 1
       and grupo_parametro = 'ARCHIVOS' 
       and num_parametro = 97;
	 
	 LET cNombreArchivo = trim(cNombreArchivo1) || LPAD(day(dtFecha_hoy),2,0) ||  LPAD(month(dtFecha_hoy),2,0) || year(dtFecha_hoy) || '.txt';
	 LET cNombreArchivo_aux = trim(cNombreArchivo1) || 'aux.txt';
	
	 LET cSql = '' ;
	 --LET cSql = 'echo "Sucursal|Empleado|Nombre_Cajero|Clientes_c_vencido|" > '|| TRIM(cRuta) || trim(cNombreArchivo_head);
	 LET cSql = 'echo "Cliente|Credito|Producto|Nombre|Segundo_Nombre|Apellido_Paterno|Apellido_Materno|Fecha_Nacimiento|RFC|' ||
                'Correo_electronico|Calle|Numero_Exterior|Numero_Interior|Colonia|Municipio|CP|Estado|Telefono|Celular|Fecha_Apertura|' ||
                'Saldo_Autorizado|Fecha_Ultimo_Mov|Monto_Ultimo_Mov|Fecha_Ultimo_Pago|Monto_Ultimo_Pago|Pagos_Vencidos|Pago_Minimo|' ||
                'Pago_Una_Mora|Saldo_Vencido|Saldo_Actual|Saldo_Intereses|Saldo_IVA|Saldo_Liquidar" > '|| TRIM(cRuta) || trim(cNombreArchivo_head);
     SYSTEM trim(cSql);	

	 IF cEjecuc_1a_vez = 0  THEN -- Veces subsecuentes
	 
	    ------------------    TDC PROCESO EJECS. POSTERIORES --------------------------- 
	    -- Al iniciar el proceso se buscarán las cuentas que ya no estén activas, para TDC que su estatus sea diferente a: AA, BA y BT; 
	    -- Para cuentas a plazo que su estatus sea diferente a AA, BA, BT y VP; y se eliminarán de la tabla de trabajo
	 
	  
	  FOREACH WITH HOLD
	      select num_credito into v_num_credito
		    from bdicred:sd_maecred
            where status_cred not in ('AA','BA','BT','E1','E2','E3')

          LET v_num_credito = NVL(v_num_credito,'');
		  
		  begin;
		      DELETE bdicobranza:cb_automatiza_800_credito WHERE num_credito = v_num_credito;
		  commit;
			
	  END FOREACH;
	  
	  LET v_num_credito = '';
	  
	  FOREACH WITH HOLD
	      select num_credito into v_num_credito
		    from bdicred:sd_maecredcrd
            where status_cred not in('AA','BA','BT','VP','E1','E2','E3')

          LET v_num_credito = NVL(v_num_credito,'');
		  
		  begin;
		      DELETE bdicobranza:cb_automatiza_800_credito WHERE num_credito = v_num_credito;
		  commit;
			
	  END FOREACH;
	  
	  LET v_num_credito = ''; 
	  
	  select fecha_insert into dtFecha_reg_bita
        from bdicobranza:cb_procesos_cob 
	   where empresa = cEmpresa and num_proceso = '0090' and sistema = 'AGEXT';
	  
	  --- Bloque principal TDC
	   select a.num_credito, a.numcte, b.monto_otorgado, a.fecha_apertura, a.num_producto, b.sdo_cap_insoluto
	     from bdicred:sd_maecred a, bdicred:sd_maesdos b, bdicred:sd_indicador_cred c 
		where a.empresa = cEmpresa and a.num_credito = b.num_credito and a.num_credito = c.num_credito
		  and a.num_credito not in(select num_credito from bdicred:sd_inactivos_12meses)
		  and a.num_credito not in(select num_credito from bdicobranza:cb_automatiza_800_credito where fecha_proceso = dtFecha_hoy)
		  and a.status_cred in ('AA','BA','BT','E1','E2','E3')
		  and (c.fecha_ultimo_pago = dtFecha_diaprev or c.atm_disp_fecha = dtFecha_diaprev or vnt_disp_fecha = dtFecha_diaprev or fecha_ultima_compra = dtFecha_diaprev)
		  and b.mto_fin_ven_trasp between 0 and 8
		 into temp paso_creds_tdc_800 with no log;
			 
			create unique index inx_paso_creds_tdc_800 on paso_creds_tdc_800(num_credito);
			update statistics medium for table paso_creds_tdc_800;

	 
	  FOREACH WITH HOLD
	      select num_credito, numcte, monto_otorgado, fecha_apertura, num_producto, sdo_cap_insoluto
		    into v_num_credito, v_numcte, d_saldo_autorizado, dt_fecha_apertura, c_num_producto, d_saldo_actual_a
		    FROM paso_creds_tdc_800
			 
			  
		 --- Último movimiento
		 -- Tabla: sd_indicador_cred. (campos: fecha_ultima_compra, atm_disp_fecha o vnt_disp_fecha)
		 -- Monto ult mov - sd_indicador_cred  se obtendrán los campos:  (monto_ultima_compra, atm_disp_monto,  vnt_disp_monto) dependiendo de la fecha de ultimo mov.
		 
		 select fecha_ultima_compra, atm_disp_fecha, vnt_disp_fecha, monto_ultima_compra, atm_disp_monto, vnt_disp_monto, fecha_ultimo_pago,
			       num_vencidos, pago_minimo, sdo_tot_vencido, sdo_tot_liquidar, monto_ultimo_pago
			  into dt_fecha_ultima_compra, dt_atm_disp_fecha, dt_vnt_disp_fecha, d_monto_ultima_compra, d_atm_disp_monto, d_vnt_disp_monto, dt_fecha_ultimo_pago,	  
			       i_pagos_vencidos_a, d_pago_minimo_a, d_saldo_vencido_a, d_saldo_liquidar_a, d_monto_ult_pago_a
			  from bdicred:sd_indicador_cred
			 where empresa = cEmpresa
			   and num_credito = v_num_credito; 
		 
		 LET dt_fecha_ultima_compra = NVL(dt_fecha_ultima_compra,'');
		 LET dt_atm_disp_fecha = NVL(dt_atm_disp_fecha,'');
		 LET dt_vnt_disp_fecha = NVL(dt_vnt_disp_fecha,'');
		 LET dt_fecha_ultimo_pago = NVL(dt_fecha_ultimo_pago,'');
		 LET d_monto_ultima_compra = NVL(d_monto_ultima_compra,0);
		 LET d_atm_disp_monto = NVL(d_atm_disp_monto,0);
		 LET d_vnt_disp_monto = NVL(d_vnt_disp_monto,0);
		 
		 LET d_saldo_actual    = NVL(d_saldo_actual_a,0);
         LET i_pagos_vencidos  = NVL(i_pagos_vencidos_a,0);
		 LET d_pago_minimo     = NVL(d_pago_minimo_a,0);
	     LET d_saldo_vencido   = NVL(d_saldo_vencido_a,0);
		 LET d_saldo_liquidar  = NVL(d_saldo_liquidar_a,0);
		 LET d_monto_ult_pago  = NVL(d_monto_ult_pago_a,0);
		 

		 IF dt_fecha_ultima_compra = dtFecha_diaprev THEN
		    LET dt_Fecha_ult_mov = dt_fecha_ultima_compra;
			LET d_monto_ult_mov = d_monto_ultima_compra;
		 ELIF dt_atm_disp_fecha = dtFecha_diaprev THEN
		    LET dt_Fecha_ult_mov = dt_atm_disp_fecha;
			LET d_monto_ult_mov = d_atm_disp_monto;
         ELIF dt_vnt_disp_fecha = dtFecha_diaprev THEN
            LET dt_Fecha_ult_mov = dtFecha_diaprev;
			LET d_monto_ult_mov = d_vnt_disp_monto;
         END IF;			
		 
		 LET dt_Fecha_ult_mov = NVL(dt_Fecha_ult_mov,'');
		 
		 IF nvl(dt_Fecha_ult_mov,'') <> '' OR dt_fecha_ultimo_pago = dtFecha_diaprev THEN
            LET iGenera_info_dia = 1;
		 --ELIF dt_fecha_ultimo_pago <> '' AND dt_fecha_ultimo_pago = dtFecha_diaprev THEN
		 --ELIF dt_fecha_ultimo_pago = dtFecha_diaprev THEN
		
			 IF i_dia_saldos = 1 THEN
			   	SELECT (intvig1 + intvenc1 +  moratorios1), (ivaintvig1 + ivaintvenc1 + (moratorios1 *.16)) INTO d_saldo_intereses_a, d_saldo_iva_a
                  FROM bdicred:sd_sdodiario
                 WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 2 THEN
		         SELECT (intvig2 + intvenc2 +  moratorios2), (ivaintvig2 + ivaintvenc2 + (moratorios2 *.16)) INTO d_saldo_intereses_a, d_saldo_iva_a
                  FROM bdicred:sd_sdodiario
                 WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				 
		     ELIF i_dia_saldos = 3 THEN
			     SELECT (intvig3 + intvenc3 +  moratorios3), (ivaintvig3 + ivaintvenc3 + (moratorios3 *.16)) INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				
			 ELIF i_dia_saldos = 4 THEN
				 SELECT (intvig4 + intvenc4 + moratorios4), (ivaintvig4 + ivaintvenc4 + (moratorios4 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			 ELIF i_dia_saldos = 5 THEN
			     SELECT (intvig5 + intvenc5 + moratorios5), (ivaintvig5 + ivaintvenc5 + (moratorios5 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 6 THEN
			     SELECT (intvig6 + intvenc6 + moratorios6), (ivaintvig6 + ivaintvenc6 + (moratorios6 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 7 THEN
			     SELECT (intvig7 + intvenc7 + moratorios7), (ivaintvig7 + ivaintvenc7 + (moratorios7 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 8 THEN
			     SELECT (intvig8 + intvenc8 + moratorios8), (ivaintvig8 + ivaintvenc8 + (moratorios8 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 9 THEN
			     SELECT (intvig9 + intvenc9 + moratorios9), (ivaintvig9 + ivaintvenc9 + (moratorios9 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 10 THEN
			     SELECT (intvig10 + intvenc10 + moratorios10), (ivaintvig10 + ivaintvenc10 + (moratorios10 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 11 THEN
			     SELECT (intvig11 + intvenc11 + moratorios11), (ivaintvig11 + ivaintvenc11 + (moratorios11 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 12 THEN
			     SELECT (intvig12 + intvenc12 + moratorios12), (ivaintvig12 + ivaintvenc12 + (moratorios12 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			 ELIF i_dia_saldos = 13 THEN
			     SELECT (intvig13 + intvenc13 + moratorios13), (ivaintvig13 + ivaintvenc13 + (moratorios13 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 14 THEN
			     SELECT (intvig14 + intvenc14 + moratorios14), (ivaintvig14 + ivaintvenc14 + (moratorios14 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 15 THEN
			     SELECT (intvig15 + intvenc15 + moratorios15), (ivaintvig15 + ivaintvenc15 + (moratorios15 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 16 THEN
			     SELECT (intvig16 + intvenc16 + moratorios16), (ivaintvig16 + ivaintvenc16 + (moratorios16 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 17 THEN
			     SELECT (intvig17 + intvenc17 + moratorios17), (ivaintvig17 + ivaintvenc17 + (moratorios17 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 18 THEN
			     SELECT (intvig18 + intvenc18 + moratorios18), (ivaintvig18 + ivaintvenc18 + (moratorios18 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 19 THEN
			     SELECT (intvig19 + intvenc19 + moratorios19), (ivaintvig19 + ivaintvenc19 + (moratorios19 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 20 THEN
			     SELECT (intvig20 + intvenc20 + moratorios20), (ivaintvig20 + ivaintvenc20 + (moratorios20 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 21 THEN
			     SELECT (intvig21 + intvenc21 + moratorios21), (ivaintvig21 + ivaintvenc21 + (moratorios21 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 22 THEN
			     SELECT (intvig22 + intvenc22 + moratorios22), (ivaintvig22 + ivaintvenc22 + (moratorios22 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 23 THEN
			     SELECT (intvig23 + intvenc23 + moratorios23), (ivaintvig23 + ivaintvenc23 + (moratorios23 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 24 THEN
			     SELECT (intvig24 + intvenc24 + moratorios24), (ivaintvig24 + ivaintvenc24 + (moratorios24 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 25 THEN
			     SELECT (intvig25 + intvenc25 + moratorios25), (ivaintvig25 + ivaintvenc25 + (moratorios25 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 26 THEN
			     SELECT (intvig26 + intvenc26 + moratorios26), (ivaintvig26 + ivaintvenc26 + (moratorios26 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 27 THEN
			     SELECT (intvig27 + intvenc27 + moratorios27), (ivaintvig27 + ivaintvenc27 + (moratorios27 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 28 THEN
			     SELECT (intvig28 + intvenc28 + moratorios28), (ivaintvig28 + ivaintvenc28 + (moratorios28 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 29 THEN
			     SELECT (intvig29 + intvenc29 + moratorios29), (ivaintvig29 + ivaintvenc29 + (moratorios29 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELIF i_dia_saldos = 30 THEN
			     SELECT (intvig30 + intvenc30 + moratorios30), (ivaintvig30 + ivaintvenc30 + (moratorios30 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				  
			 ELSE 
			    SELECT (intvig31 + intvenc31 + moratorios31), (ivaintvig31 + ivaintvenc31 + (moratorios31 *.16))  INTO d_saldo_intereses_a, d_saldo_iva_a
                   FROM bdicred:sd_sdodiario
                  WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			 END IF; 
			
		 
		    LET d_saldo_intereses = NVL(d_saldo_intereses_a,0);
            LET d_saldo_iva       = NVL(d_saldo_iva_a,0);
					 
		     select fecha_domicilio into dt_fecha_dom_actual
			   from bdicobranza:cb_automatiza_800_credito
			  where num_credito = v_num_credito;

			  LET dt_fecha_dom_actual = NVL(dt_fecha_dom_actual,'01/01/1900');
		 
			 select limit 1 correo_elec into v_correo_elec
			   from bdinteg:si_correos
			  where numcte = v_numcte
				and status_correo = 'A';
				
			 SELECT fecha_insert INTO dt_fecha_insert_dom
			   FROM bdinteg:si_direcciones_actual 
			  WHERE numcte = v_numcte
				AND tipo_dir = '1';
			 
			 IF nvl(dt_fecha_dom_actual,'') <> '' OR dt_fecha_dom_actual <> '01/01/900' THEN
			   IF dt_fecha_insert_dom > dt_fecha_dom_actual THEN
					LET c_actualiza_dom = '1';
			   ELSE
					LET c_actualiza_dom = '0';
			   END IF;
			 ELSE
				LET c_actualiza_dom = '1';
			 END IF;
			
			 IF c_actualiza_dom = '1' THEN
				 SELECT LIMIT 1 d.cod_postal, d.numeroextcalle, d.numerointcalle, e.nombrezona, e.municipiozona, f.nombrecalle, h.nombre
					INTO v_cod_postal, v_numeroextcalle, v_numerointcalle, v_nombrezona, v_municipiozona, v_calle, v_nom_estado 
				   FROM bdinteg:si_direcciones_actual d  
										join bdinteg:si_catzonas e on e.numerociudad = d.numerociudad and e.numerocolonia = d.numerocolonia
										join bdinteg:si_catcalles f on f.numerocalle = d.numerocalle
										join bdinteg:si_ciudades i on i.ciudad_coppel = d.numerociudad join bdinteg:si_estados h on h.estado = i.estado
				   WHERE d.numcte = v_numcte
					 AND d.tipo_dir = '1';
			 END IF;		 
		  
		  
			  SELECT LIMIT 1 tel.telefono INTO v_telefono
				FROM bdinteg:si_telefonos_actual tel 
			   WHERE tel.numcte = v_numcte  
				 AND tel.tipo_tel = 1 
				 AND tel.cofetel ='V';

				
			  SELECT LIMIT 1 tel.telefono INTO v_tel_cel
				FROM bdinteg:si_telefonos_actual tel 
			   WHERE tel.numcte = v_numcte  
				 AND tel.tipo_tel = 2 
				 AND tel.cofetel ='V';
				
				
				SELECT pago_una_mora into d_pago_una_mora
				  from bdicred:sd_sdos_cartera_linea
				  where num_credito = v_num_credito;
				  
				 LET d_pago_una_mora = nvl(d_pago_una_mora,0);
			
				--- ACTUALIZAR O INSERTAR
				IF c_actualiza_dom = '1' THEN
					BEGIN;
						 UPDATE bdicobranza:cb_automatiza_800_credito 
						 SET correo_electronico= v_correo_elec, calle= v_calle, num_exterior= v_numeroextcalle, num_interior= v_numerointcalle, 
							 colonia= v_nombrezona, municipio= v_municipiozona, cp= v_cod_postal, estado= v_nom_estado, telefono= v_telefono, 
							 celular= v_tel_cel, saldo_autorizado= d_saldo_autorizado, fecha_ultimo_mov= dt_Fecha_ult_mov, monto_ultimo_mov= d_monto_ult_mov, 
							 fecha_ultimo_pago= dt_fecha_ultimo_pago, monto_ultimo_pago= d_monto_ult_pago, pagos_vencidos= i_pagos_vencidos, 
							 pago_minimo= d_pago_minimo, pago_una_mora= d_pago_una_mora, saldo_vencido= d_saldo_vencido, saldo_actual=d_saldo_actual, 
							 saldo_intereses= d_saldo_intereses, saldo_iva= d_saldo_iva, saldo_liquidar= d_saldo_liquidar, fecha_domicilio= dtFecha_hoy,
							 fecha_proceso = dtFecha_hoy
						 WHERE num_credito = v_num_credito;

					COMMIT;
					LET iActualiza = DBINFO("sqlca.sqlerrd2");
				ELSE 
				   BEGIN;
						 UPDATE bdicobranza:cb_automatiza_800_credito  --Se actualiza todo menos el domicilio
						 SET correo_electronico= v_correo_elec, --calle= v_calle, num_exterior= v_numeroextcalle, num_interior= v_numerointcalle, 
							 --colonia= v_nombrezona, municipio= v_municipiozona, cp= v_cod_postal, estado= v_nom_estado, 
							 telefono= v_telefono, 
							 celular= v_tel_cel, saldo_autorizado= d_saldo_autorizado, fecha_ultimo_mov= dt_Fecha_ult_mov, monto_ultimo_mov= d_monto_ult_mov, 
							 fecha_ultimo_pago= dt_fecha_ultimo_pago, monto_ultimo_pago= d_monto_ult_pago, pagos_vencidos= i_pagos_vencidos, 
							 pago_minimo= d_pago_minimo, pago_una_mora= d_pago_una_mora, saldo_vencido= d_saldo_vencido, saldo_actual=d_saldo_actual, 
							 saldo_intereses= d_saldo_intereses, saldo_iva= d_saldo_iva, saldo_liquidar= d_saldo_liquidar, fecha_proceso= dtFecha_hoy
						 WHERE num_credito = v_num_credito;

					COMMIT;
				    LET iActualiza = DBINFO("sqlca.sqlerrd2");
				END IF;
			
				
				IF iActualiza = 0 THEN  --No existía la cuenta entonces se inserta
				
				   begin;
				       INSERT INTO bdicobranza:cb_automatiza_800_credito(num_credito, correo_electronico, calle, num_exterior, num_interior, colonia, municipio, 
					     cp, estado, telefono, celular, fecha_apertura, saldo_autorizado, fecha_ultimo_mov, monto_ultimo_mov, fecha_ultimo_pago, monto_ultimo_pago,
					     pagos_vencidos, pago_minimo, pago_una_mora, saldo_vencido, saldo_actual, saldo_intereses, saldo_iva, saldo_liquidar, fecha_domicilio, 
					     fecha_proceso) 
					   VALUES(v_num_credito, v_correo_elec, v_calle, v_numeroextcalle, v_numerointcalle, v_nombrezona, v_municipiozona, v_cod_postal, 
					     v_nom_estado, v_telefono, v_tel_cel, dt_fecha_apertura, d_saldo_autorizado, dt_Fecha_ult_mov, d_monto_ult_mov, dt_fecha_ultimo_pago, 
					     d_monto_ult_pago, i_pagos_vencidos, d_pago_minimo, d_pago_una_mora, d_saldo_vencido, d_saldo_actual, d_saldo_intereses, d_saldo_iva, 
					     d_saldo_liquidar, dtFecha_hoy, dtFecha_hoy);
				   commit;
				END IF;
			
		 ELSE   
		    LET iGenera_info_dia = 0;
		    LET c_actualiza_dom = '';
			LET iActualiza = 0;
			LET d_saldo_actual    = 0;
            LET i_pagos_vencidos  = 0;
		    LET d_pago_minimo     = 0;
		    LET d_saldo_vencido   = 0;
		    LET d_saldo_liquidar  = 0;
		    LET d_monto_ult_pago  = 0;
		    LET d_saldo_intereses = 0; 
		    LET d_saldo_iva       = 0;
		    CONTINUE FOREACH;
		
		 END IF;
		 
		 LET iGenera_info_dia = 0;
		 LET c_actualiza_dom = '';
		 LET iActualiza = 0;
		 LET d_saldo_actual    = 0;
         LET i_pagos_vencidos  = 0;
		 LET d_pago_minimo     = 0;
		 LET d_saldo_vencido   = 0;
		 LET d_saldo_liquidar  = 0;
		 LET d_monto_ult_pago  = 0;
		 LET d_saldo_intereses = 0; 
		 LET d_saldo_iva       = 0;
		 
	  END FOREACH;
	  
	      ------------------    TDC PROCESO EJECS. POSTERIORES --------------------------- FIN
		  
	      ------------------    PLAZO PROCESO EJECS. POSTERIORES --------------------------- INI
		  -- Para validar si se ejecutó el día previo
		  IF NVL(dtFecha_reg_bita,'') <>  '' AND (dtFecha_reg_bita < dtFecha_diaprev) THEN
		     LET dtFecha_diaprev = dtFecha_reg_bita;
          END IF;			 
		  
	  
	      select a.num_credito, a.numcte, b.monto_otorgado, a.fecha_apertura, a.num_producto, b.sdo_cap_insoluto, b.mto_fin_ven_trasp
		    from bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_indicador_cred_crd c 
		   where a.num_credito = b.num_credito and a.num_credito = c.num_credito
		     and a.num_credito not in(select num_credito from bdicobranza:cb_automatiza_800_credito where fecha_proceso = dtFecha_hoy)
			 and a.status_cred in ('AA','BA','BT','VP','E1','E2','E3')
			 and c.fecha_ultimo_pago >= dtFecha_diaprev
			 and b.mto_fin_ven_trasp between 0 and 8
			 into temp paso_creds_cnr_800 with no log;
			 
			 create unique index inx_paso_creds_cnr_800 on paso_creds_cnr_800(num_credito);
			 update statistics medium for table paso_creds_cnr_800;
	  
	   FOREACH WITH HOLD
	       select num_credito, numcte, monto_otorgado, fecha_apertura, num_producto, sdo_cap_insoluto, mto_fin_ven_trasp
		    into v_num_credito, v_numcte, d_saldo_autorizado, dt_fecha_apertura, c_num_producto,d_saldo_actual_a, i_pagos_vencidos_a
			from paso_creds_cnr_800
		    
	
            IF c_num_producto = '6800' THEN
			   select fecha_otorga into dt_fecha_apertura
			     from bdicred:sd_linea_prestamo
                where num_credito = v_num_credito 
				  and NVL(disposicion_activada,'') <> '';
			    
				LET dt_fecha_apertura = NVL(dt_fecha_apertura,'01/01/1900');
				
				IF NVL(dt_fecha_apertura,'') = '' OR dt_fecha_apertura = '01/01/1900' THEN
				   CONTINUE FOREACH;
				END IF;
				  
			END IF;
			
            LET dt_Fecha_ult_mov = dt_fecha_apertura;	
			LET d_monto_ult_mov = 0;
			
			select fecha_ultimo_pago, pago_minimo, sdo_tot_vencido, sdo_tot_liquidar, monto_ultimo_pago
		     into dt_fecha_ultimo_pago, d_pago_minimo_a, d_saldo_vencido_a, d_saldo_liquidar_a, d_monto_ult_pago_a 		  
             from bdicred:sd_indicador_cred_crd
            where empresa = cEmpresa
			  and num_credito = v_num_credito; 		  
		 	
			LET dt_fecha_ultimo_pago = NVL(dt_fecha_ultimo_pago,'');  
			
			LET d_saldo_actual    = NVL(d_saldo_actual_a,0);
            LET i_pagos_vencidos  = NVL(i_pagos_vencidos_a,0);
		    LET d_pago_minimo     = NVL(d_pago_minimo_a,0);
			LET d_saldo_vencido   = NVL(d_saldo_vencido_a,0);
			LET d_saldo_liquidar  = NVL(d_saldo_liquidar_a,0);
			LET d_monto_ult_pago  = NVL(d_monto_ult_pago_a,0);
			
			
			IF dt_fecha_ultimo_pago >= dtFecha_diaprev THEN
			                                                  
				LET iGenera_info_dia = 1;
				
				IF i_dia_saldos = 1 THEN
					SELECT (intvig1 +  intvenc1),  (ivaintvig1 + ivaintvenc1)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 2 THEN
			      SELECT (intvig2 +  intvenc2),  (ivaintvig2 + ivaintvenc2)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 3 THEN
					SELECT (intvig3 +  intvenc3),  (ivaintvig3 + ivaintvenc3)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 4 THEN
					SELECT (intvig4 + intvenc4),  (ivaintvig4 + ivaintvenc4)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				
				ELIF i_dia_saldos = 5 THEN
				    SELECT (intvig5 + intvenc5),  (ivaintvig5 + ivaintvenc5)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 6 THEN
				    SELECT (intvig6 + intvenc6),  (ivaintvig6 + ivaintvenc6)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 7 THEN
				    SELECT (intvig7 + intvenc7),  (ivaintvig7 + ivaintvenc7)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				
				ELIF i_dia_saldos = 8 THEN
				    SELECT (intvig8 + intvenc8),  (ivaintvig8 + ivaintvenc8)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 9 THEN
				    SELECT (intvig9 + intvenc9),  (ivaintvig9 + ivaintvenc9)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 10 THEN
				    SELECT (intvig10 + intvenc10),  (ivaintvig10 + ivaintvenc10)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				
				ELIF i_dia_saldos = 11 THEN
				    SELECT (intvig11 + intvenc11),  (ivaintvig11+ ivaintvenc11)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 12 THEN
				    SELECT (intvig12 + intvenc12),  (ivaintvig12+ ivaintvenc12)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 13 THEN
				    SELECT (intvig13 + intvenc13),  (ivaintvig13+ ivaintvenc13)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 14 THEN
				   SELECT (intvig14 + intvenc14),  (ivaintvig14+ ivaintvenc14)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 15 THEN
				   SELECT (intvig15 + intvenc15),  (ivaintvig15+ ivaintvenc15)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				
				ELIF i_dia_saldos = 16 THEN
				   SELECT (intvig16 + intvenc16),  (ivaintvig16+ ivaintvenc16)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 17 THEN
				   SELECT (intvig17 + intvenc17),  (ivaintvig17+ ivaintvenc17)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				
				ELIF i_dia_saldos = 18 THEN
				   SELECT (intvig18 + intvenc18),  (ivaintvig18+ ivaintvenc18)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 19 THEN
				  SELECT (intvig19 + intvenc19),  (ivaintvig19+ ivaintvenc19)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				
				ELIF i_dia_saldos = 20 THEN
				  SELECT (intvig20 + intvenc20),  (ivaintvig20+ ivaintvenc20)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				
				ELIF i_dia_saldos = 21 THEN
				  SELECT (intvig21 + intvenc21),  (ivaintvig21+ ivaintvenc21)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				
				ELIF i_dia_saldos = 22 THEN
				  SELECT (intvig22 + intvenc22),  (ivaintvig22+ ivaintvenc22)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 23 THEN
				  SELECT (intvig23 + intvenc23),  (ivaintvig23+ ivaintvenc23)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 24 THEN
				  SELECT (intvig24 + intvenc24),  (ivaintvig24+ ivaintvenc24)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 25 THEN
				  SELECT (intvig25 + intvenc25),  (ivaintvig25+ ivaintvenc25)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 26 THEN
				  SELECT (intvig26 + intvenc26),  (ivaintvig26+ ivaintvenc26)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 27 THEN
				  SELECT (intvig27 + intvenc27),  (ivaintvig27+ ivaintvenc27)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 28 THEN  
				  SELECT (intvig28 + intvenc28),  (ivaintvig28+ ivaintvenc28)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 29 THEN
				  SELECT (intvig29 + intvenc29),  (ivaintvig29+ ivaintvenc29)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELIF i_dia_saldos = 30 THEN
				  SELECT (intvig30 + intvenc30),  (ivaintvig30+ ivaintvenc30)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				ELSE
				  SELECT (intvig31 + intvenc31),  (ivaintvig31+ ivaintvenc31)   INTO d_saldo_intereses_a, d_saldo_iva_a
					  FROM bdicred:sd_sdodiariocrd
					 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
					 
				END IF;

				
				LET d_saldo_intereses_a = NVL(d_saldo_intereses_a,0);
				LET d_saldo_iva_a       = NVL(d_saldo_iva_a,0);
				
				SELECT SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))
				  INTO dIntMoratorio
				  FROM bdicred:sd_amortiza_creditocrd
				 WHERE empresa = cEmpresa
				   AND num_credito = v_num_credito
				   AND capital_status IN ('2','7','6');
				
				LET d_saldo_intereses = d_saldo_intereses_a + dIntMoratorio;
				LET d_saldo_iva       = d_saldo_iva_a + round( (dIntMoratorio*.16),0);
				
				
				--IF NVL(dt_fecha_ultimo_pago,'') <> '' AND dt_fecha_ultimo_pago = dtFecha_diaprev THEN
				--	  LET iGenera_info_dia = 1;
				
					 SELECT fecha_domicilio into dt_fecha_dom_actual
						 from bdicobranza:cb_automatiza_800_credito
						where num_credito = v_num_credito;

					 LET dt_fecha_dom_actual = NVL(dt_fecha_dom_actual,'01/01/1900');
					
					SELECT limit 1 correo_elec into v_correo_elec
					  FROM bdinteg:si_correos
					 WHERE numcte = v_numcte
					   AND status_correo = 'A';
					
					SELECT fecha_insert INTO dt_fecha_insert_dom
					  FROM bdinteg:si_direcciones_actual 
					 WHERE numcte = v_numcte
					   AND tipo_dir = '1';
					
					 IF NVL(dt_fecha_dom_actual,'') <> '' OR dt_fecha_dom_actual <> '01/01/900' THEN
					   IF dt_fecha_insert_dom > dt_fecha_dom_actual THEN
							LET c_actualiza_dom = '1';
					   ELSE
							LET c_actualiza_dom = '0';
					   END IF;
					 ELSE
						LET c_actualiza_dom = '1';
					 END IF;
					
					 IF c_actualiza_dom = '1' THEN
						 SELECT LIMIT 1 d.cod_postal, d.numeroextcalle, d.numerointcalle, e.nombrezona, e.municipiozona, f.nombrecalle, h.nombre
							INTO v_cod_postal, v_numeroextcalle, v_numerointcalle, v_nombrezona, v_municipiozona, v_calle, v_nom_estado 
						   FROM bdinteg:si_direcciones_actual d  
												join bdinteg:si_catzonas e on e.numerociudad = d.numerociudad and e.numerocolonia = d.numerocolonia
												join bdinteg:si_catcalles f on f.numerocalle = d.numerocalle
												join bdinteg:si_ciudades i on i.ciudad_coppel = d.numerociudad join bdinteg:si_estados h on h.estado = i.estado
						   WHERE d.numcte = v_numcte
							 AND d.tipo_dir = '1';
					 END IF;		 
				  
				  
					 SELECT LIMIT 1 tel.telefono INTO v_telefono
					   FROM bdinteg:si_telefonos_actual tel 
					  WHERE tel.numcte = v_numcte  
						AND tel.tipo_tel = 1 
					   AND tel.cofetel ='V';

					
					 SELECT LIMIT 1 tel.telefono INTO v_tel_cel
					   FROM bdinteg:si_telefonos_actual tel 
					  WHERE tel.numcte = v_numcte  
						AND tel.tipo_tel = 2 
						AND tel.cofetel ='V';
					
					
					 SELECT pago_una_mora into d_pago_una_mora
					   from bdicred:sd_sdos_cartera_linea
					   where num_credito = v_num_credito;
					  
					  LET d_pago_una_mora = nvl(d_pago_una_mora,0);
					 
					 --- ACTUALIZAR O INSERTAR
						IF c_actualiza_dom = '1' THEN
							BEGIN;
								 UPDATE bdicobranza:cb_automatiza_800_credito 
								 SET correo_electronico= v_correo_elec, calle= v_calle, num_exterior= v_numeroextcalle, num_interior= v_numerointcalle, 
									 colonia= v_nombrezona, municipio= v_municipiozona, cp= v_cod_postal, estado= v_nom_estado, telefono= v_telefono, 
									 celular= v_tel_cel, saldo_autorizado= d_saldo_autorizado, fecha_ultimo_mov= dt_Fecha_ult_mov, monto_ultimo_mov= d_monto_ult_mov, 
									 fecha_ultimo_pago= dt_fecha_ultimo_pago, monto_ultimo_pago= d_monto_ult_pago, pagos_vencidos= i_pagos_vencidos, 
									 pago_minimo= d_pago_minimo, pago_una_mora= d_pago_una_mora, saldo_vencido= d_saldo_vencido, saldo_actual=d_saldo_actual, 
									 saldo_intereses= d_saldo_intereses, saldo_iva= d_saldo_iva, saldo_liquidar= d_saldo_liquidar, fecha_domicilio= dtFecha_hoy,
									 fecha_proceso = dtFecha_hoy
								 WHERE num_credito = v_num_credito;

							COMMIT;
							LET iActualiza = DBINFO("sqlca.sqlerrd2");
						ELSE 
						   BEGIN;
								 UPDATE bdicobranza:cb_automatiza_800_credito  --Se actualiza todo menos el domicilio
								 SET correo_electronico= v_correo_elec, --calle= v_calle, num_exterior= v_numeroextcalle, num_interior= v_numerointcalle, 
									 --colonia= v_nombrezona, municipio= v_municipiozona, cp= v_cod_postal, estado= v_nom_estado, 
									 telefono= v_telefono, 
									 celular= v_tel_cel, saldo_autorizado= d_saldo_autorizado, fecha_ultimo_mov= dt_Fecha_ult_mov, monto_ultimo_mov= d_monto_ult_mov, 
									 fecha_ultimo_pago= dt_fecha_ultimo_pago, monto_ultimo_pago= d_monto_ult_pago, pagos_vencidos= i_pagos_vencidos, 
									 pago_minimo= d_pago_minimo, pago_una_mora= d_pago_una_mora, saldo_vencido= d_saldo_vencido, saldo_actual=d_saldo_actual, 
									 saldo_intereses= d_saldo_intereses, saldo_iva= d_saldo_iva, saldo_liquidar= d_saldo_liquidar, fecha_proceso= dtFecha_hoy
								 WHERE num_credito = v_num_credito;

							COMMIT;
							LET iActualiza = DBINFO("sqlca.sqlerrd2");
						END IF;
						
						
						IF iActualiza = 0 THEN  --No existía la cuenta entonces se inserta
						   begin;
							  INSERT INTO bdicobranza:cb_automatiza_800_credito(num_credito, correo_electronico, calle, num_exterior, num_interior, colonia, municipio, 
							   cp, estado, telefono, celular, fecha_apertura, saldo_autorizado, fecha_ultimo_mov, monto_ultimo_mov, fecha_ultimo_pago, monto_ultimo_pago,
							   pagos_vencidos, pago_minimo, pago_una_mora, saldo_vencido, saldo_actual, saldo_intereses, saldo_iva, saldo_liquidar, fecha_domicilio, 
							   fecha_proceso) 
							   VALUES(v_num_credito, v_correo_elec, v_calle, v_numeroextcalle, v_numerointcalle, v_nombrezona, v_municipiozona, v_cod_postal, 
							   v_nom_estado, v_telefono, v_tel_cel, dt_fecha_apertura, d_saldo_autorizado, dt_Fecha_ult_mov, d_monto_ult_mov, dt_fecha_ultimo_pago, 
							   d_monto_ult_pago, i_pagos_vencidos, d_pago_minimo, d_pago_una_mora, d_saldo_vencido, d_saldo_actual, d_saldo_intereses, d_saldo_iva, 
							   d_saldo_liquidar, dtFecha_hoy, dtFecha_hoy);

						   commit;
						END IF;
		
		    ELSE
		      LET iGenera_info_dia = 0;
		      LET c_actualiza_dom = '';
		      LET iActualiza = 0;
			  LET d_saldo_actual    = 0;
              LET i_pagos_vencidos  = 0;
		      LET d_pago_minimo     = 0;
		      LET d_saldo_vencido   = 0;
		      LET d_saldo_liquidar  = 0;
		      LET d_monto_ult_pago  = 0;
		      LET d_saldo_intereses = 0; 
		      LET d_saldo_iva       = 0;
		      CONTINUE FOREACH;
		 END IF;
	       
		   LET iGenera_info_dia = 0;
		   LET c_actualiza_dom = '';
		   LET iActualiza = 0;
		   LET d_saldo_actual    = 0;
           LET i_pagos_vencidos  = 0;
		   LET d_pago_minimo     = 0;
		   LET d_saldo_vencido   = 0;
		   LET d_saldo_liquidar  = 0;
		   LET d_monto_ult_pago  = 0;
		   LET d_saldo_intereses = 0; 
		   LET d_saldo_iva       = 0;
		   
	  
	  END FOREACH;
	 
	      
		  ------------------    PLAZO PROCESO EJECS. POSTERIORES --------------------------- FIN
		  
    ELSE    
	
	    ------------------    TDC PROCESO DE 1A Y ÚNICA VEZ ---------------------------
	    ------------------------------------------------------------------------
	
	    --Validar si a hay info del  primer día de ejecución (si ya hubo una primera ejecución interrumpida)
			 select limit 1 fecha_proceso into dt_fecha_proceso_800
			   from bdicobranza:cb_automatiza_800_credito;

		    IF NVL(dt_fecha_proceso_800,'') <> '' THEN
			   IF dt_fecha_proceso_800 <> dtFecha_hoy THEN
			      LET dtFecha_hoy = dt_fecha_proceso_800;
			   END IF;
			END IF;
	
	      select a.num_credito, a.numcte, b.monto_otorgado, a.fecha_apertura, a.num_producto, b.sdo_cap_insoluto
		    from bdicred:sd_maecred a, bdicred:sd_maesdos b 
		   where a.empresa = cEmpresa and a.num_credito = b.num_credito
		     and a.num_credito not in(select num_credito from bdicred:sd_inactivos_12meses)
			 and a.num_credito not in(select num_credito from bdicobranza:cb_automatiza_800_credito where fecha_proceso = dtFecha_hoy)
		     and a.status_cred in ('AA','BA','BT','E1','E2','E3')
			 and b.mto_fin_ven_trasp between 0 and 8
			 into temp paso_creds_tdc_800 with no log;
			 
			create unique index inx_paso_creds_tdc_800 on paso_creds_tdc_800(num_credito);
			update statistics medium for table paso_creds_tdc_800;

	
	  FOREACH WITH HOLD
	      select num_credito, numcte, monto_otorgado, fecha_apertura, num_producto, sdo_cap_insoluto
		    into v_num_credito, v_numcte, d_saldo_autorizado, dt_fecha_apertura, c_num_producto, d_saldo_actual_a
		    FROM paso_creds_tdc_800
		
		
		 --- Último movimiento
		 -- Tabla: sd_indicador_cred. (campos: fecha_ultima_compra, atm_disp_fecha o vnt_disp_fecha)
		 -- Monto ult mov - sd_indicador_cred  se obtendrán los campos:  (monto_ultima_compra, atm_disp_monto,  vnt_disp_monto) dependiendo de la fecha de ultimo mov.
			
			
			select fecha_ultima_compra, atm_disp_fecha, vnt_disp_fecha, monto_ultima_compra, atm_disp_monto, vnt_disp_monto, fecha_ultimo_pago,
			       num_vencidos, pago_minimo, sdo_tot_vencido, sdo_tot_liquidar, monto_ultimo_pago
			  into dt_fecha_ultima_compra, dt_atm_disp_fecha, dt_vnt_disp_fecha, d_monto_ultima_compra, d_atm_disp_monto, d_vnt_disp_monto, dt_fecha_ultimo_pago,	  
			       i_pagos_vencidos_a, d_pago_minimo_a, d_saldo_vencido_a, d_saldo_liquidar_a, d_monto_ult_pago_a
			  from bdicred:sd_indicador_cred
			 where empresa = cEmpresa
			   and num_credito = v_num_credito; 		  
			 
			 
			 LET dt_fecha_ultima_compra = NVL(dt_fecha_ultima_compra,'');
			 LET dt_atm_disp_fecha = NVL(dt_atm_disp_fecha,'');
			 LET dt_vnt_disp_fecha = NVL(dt_vnt_disp_fecha,'');
			 LET dt_fecha_ultimo_pago = NVL(dt_fecha_ultimo_pago,'');
			 LET d_monto_ultima_compra = NVL(d_monto_ultima_compra,0);
			 LET d_atm_disp_monto = NVL(d_atm_disp_monto,0);
			 LET d_vnt_disp_monto = NVL(d_vnt_disp_monto,0);

			 LET d_saldo_actual    = NVL(d_saldo_actual_a,0);
             LET i_pagos_vencidos  = NVL(i_pagos_vencidos_a,0);
			 LET d_pago_minimo     = NVL(d_pago_minimo_a,0);
			 LET d_saldo_vencido   = NVL(d_saldo_vencido_a,0);
			 LET d_saldo_liquidar  = NVL(d_saldo_liquidar_a,0);
			 LET d_monto_ult_pago  = NVL(d_monto_ult_pago_a,0);
			
			
			 IF dt_fecha_ultima_compra = dtFecha_diaprev THEN
				LET dt_Fecha_ult_mov = dt_fecha_ultima_compra;
				LET d_monto_ult_mov = d_monto_ultima_compra;
			 ELIF dt_atm_disp_fecha = dtFecha_diaprev THEN
				LET dt_Fecha_ult_mov = dt_atm_disp_fecha;
				LET d_monto_ult_mov = d_atm_disp_monto;
			 ELIF dt_vnt_disp_fecha = dtFecha_diaprev THEN
				LET dt_Fecha_ult_mov = dtFecha_diaprev;
				LET d_monto_ult_mov = d_vnt_disp_monto;
			 END IF;			
			 
			 LET dt_Fecha_ult_mov = NVL(dt_Fecha_ult_mov,'');
		
		 
		 -- Como es de única vez, se descarga de cualquier manera
		 LET iGenera_info_dia = 1;
	  
		 -- TDC: sd_indicador_cred  se obtendrán los campos:  (monto_ultima_compra, atm_disp_monto,  vnt_disp_monto) dependiendo de la fecha de ultimo mov.
		 
		    IF i_dia_saldos = 1 THEN
			   SELECT (intvig1 +  intvenc1 +  moratorios1), (ivaintvig1+ivaintvenc1+(moratorios1 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELIF i_dia_saldos = 2 THEN
			  SELECT (intvig2 +  intvenc2 +  moratorios2), (ivaintvig2+ivaintvenc2+(moratorios2 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
		 
		    ELIF i_dia_saldos = 3 THEN
			  SELECT (intvig3 +  intvenc3 +  moratorios3), (ivaintvig3+ivaintvenc3+(moratorios3 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
				
			ELIF i_dia_saldos = 4 THEN
			  SELECT (intvig4 +  intvenc4 +  moratorios4), (ivaintvig4+ivaintvenc4+(moratorios4 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELIF i_dia_saldos = 5 THEN
			  SELECT (intvig5 +  intvenc5 +  moratorios5), (ivaintvig5+ivaintvenc5+(moratorios5 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 6 THEN
			  SELECT (intvig6 +  intvenc6 +  moratorios6), (ivaintvig6+ivaintvenc6+(moratorios6 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELIF i_dia_saldos = 7 THEN
			  SELECT (intvig7 +  intvenc7 +  moratorios7), (ivaintvig7+ivaintvenc7+(moratorios7 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 8 THEN
			  SELECT (intvig8 +  intvenc8 +  moratorios8), (ivaintvig8+ivaintvenc8+(moratorios8 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 9 THEN
			   SELECT (intvig9 +  intvenc9 +  moratorios9), (ivaintvig9+ivaintvenc9+(moratorios9 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELIF i_dia_saldos = 10 THEN
			  SELECT (intvig10 +  intvenc10 +  moratorios10), (ivaintvig10+ivaintvenc10+(moratorios10 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELIF i_dia_saldos = 11 THEN
			  SELECT (intvig11 +  intvenc11 +  moratorios11), (ivaintvig11+ivaintvenc11+(moratorios11 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 12 THEN
			  SELECT (intvig12 +  intvenc12 +  moratorios12), (ivaintvig12+ivaintvenc12+(moratorios12 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELIF i_dia_saldos = 13 THEN
			  SELECT (intvig13 +  intvenc13 +  moratorios13), (ivaintvig13+ivaintvenc13+(moratorios13 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELIF i_dia_saldos = 14 THEN
			  SELECT (intvig14 +  intvenc14 +  moratorios14), (ivaintvig14+ivaintvenc14+(moratorios14 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 15 THEN
			  SELECT (intvig15 +  intvenc15 +  moratorios15), (ivaintvig15+ivaintvenc15+(moratorios15 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 16 THEN
			  SELECT (intvig16 +  intvenc16 +  moratorios16), (ivaintvig16+ivaintvenc16+(moratorios16 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 17 THEN
			  SELECT (intvig17 +  intvenc17 +  moratorios17), (ivaintvig17+ivaintvenc17+(moratorios17 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 18 THEN
			  SELECT (intvig18 +  intvenc18 +  moratorios18), (ivaintvig18+ivaintvenc18+(moratorios18 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELIF i_dia_saldos = 19 THEN
			  SELECT (intvig19 +  intvenc19 +  moratorios19), (ivaintvig19+ivaintvenc19+(moratorios19 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 20 THEN
			  SELECT (intvig20 +  intvenc20 +  moratorios20), (ivaintvig20+ivaintvenc20+(moratorios20 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 21 THEN
			  SELECT (intvig21 +  intvenc21 +  moratorios21), (ivaintvig21+ivaintvenc21+(moratorios21 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 22 THEN
			  SELECT (intvig22 +  intvenc22 +  moratorios22), (ivaintvig22+ivaintvenc22+(moratorios22 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 23 THEN
			  SELECT (intvig23 +  intvenc23 +  moratorios23), (ivaintvig23+ivaintvenc23+(moratorios23 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 24 THEN
			  SELECT (intvig24 +  intvenc24 +  moratorios24), (ivaintvig24+ivaintvenc24+(moratorios24 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 25 THEN
			  SELECT (intvig25 +  intvenc25 +  moratorios25), (ivaintvig25+ivaintvenc25+(moratorios25 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 26 THEN
			  SELECT (intvig26 +  intvenc26 +  moratorios26), (ivaintvig26+ivaintvenc26+(moratorios26 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 27 THEN
			  SELECT (intvig27 +  intvenc27 +  moratorios27), (ivaintvig27+ivaintvenc27+(moratorios27 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 28 THEN
			  SELECT (intvig28 +  intvenc28 +  moratorios28), (ivaintvig28+ivaintvenc28+(moratorios28 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 29 THEN
			  SELECT (intvig29 +  intvenc29 +  moratorios29), (ivaintvig29+ivaintvenc29+(moratorios29 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELIF i_dia_saldos = 30 THEN
			  SELECT (intvig30 +  intvenc30 +  moratorios30), (ivaintvig30+ivaintvenc30+(moratorios30 *.16))
				INTO d_saldo_intereses_a, d_saldo_iva_a
                FROM bdicred:sd_sdodiario
               WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			   
			ELSE 
			   SELECT (intvig31 +  intvenc31 +  moratorios31), (ivaintvig31+ivaintvenc31+(moratorios31 *.16))
				 INTO d_saldo_intereses_a, d_saldo_iva_a
                 FROM bdicred:sd_sdodiario
                WHERE fecha = dtFecha_IniMes and num_credito = v_num_credito;
			END IF; 
		 
		    LET d_saldo_intereses = NVL(d_saldo_intereses_a,0);
            LET d_saldo_iva       = NVL(d_saldo_iva_a,0);
		 
			 SELECT limit 1 correo_elec into v_correo_elec
			   FROM bdinteg:si_correos
			  WHERE numcte = v_numcte
				AND status_correo = 'A';
				
			SELECT fecha_insert INTO dt_fecha_insert_dom
			FROM bdinteg:si_direcciones_actual 
		   WHERE numcte = v_numcte
			 AND tipo_dir = '1';
		 
		
		     SELECT LIMIT 1 d.cod_postal, d.numeroextcalle, d.numerointcalle, e.nombrezona, e.municipiozona, f.nombrecalle, h.nombre
				INTO v_cod_postal, v_numeroextcalle, v_numerointcalle, v_nombrezona, v_municipiozona, v_calle, v_nom_estado 
			   FROM bdinteg:si_direcciones_actual d  
									join bdinteg:si_catzonas e on e.numerociudad = d.numerociudad and e.numerocolonia = d.numerocolonia
									join bdinteg:si_catcalles f on f.numerocalle = d.numerocalle
									join bdinteg:si_ciudades i on i.ciudad_coppel = d.numerociudad join bdinteg:si_estados h on h.estado = i.estado
			   WHERE d.numcte = v_numcte
				 AND d.tipo_dir = '1';
		  
		  
   	      SELECT LIMIT 1 tel.telefono INTO v_telefono
   	        FROM bdinteg:si_telefonos_actual tel 
           WHERE tel.numcte = v_numcte  
             AND tel.tipo_tel = 1 
             AND tel.cofetel ='V';

			
		  SELECT LIMIT 1 tel.telefono INTO v_tel_cel
   	        FROM bdinteg:si_telefonos_actual tel 
           WHERE tel.numcte = v_numcte  
             AND tel.tipo_tel = 2 
             AND tel.cofetel ='V';
			
			SELECT pago_una_mora into d_pago_una_mora
			  from bdicred:sd_sdos_cartera_linea
			  where num_credito = v_num_credito;
			  
			 LET d_pago_una_mora = nvl(d_pago_una_mora,0);
			
			   begin;
                  
				   INSERT INTO bdicobranza:cb_automatiza_800_credito(num_credito, correo_electronico, calle, num_exterior, num_interior, colonia, municipio, 
				   cp, estado, telefono, celular, fecha_apertura, saldo_autorizado, fecha_ultimo_mov, monto_ultimo_mov, fecha_ultimo_pago, monto_ultimo_pago,
				   pagos_vencidos, pago_minimo, pago_una_mora, saldo_vencido, saldo_actual, saldo_intereses, saldo_iva, saldo_liquidar, fecha_domicilio, 
				   fecha_proceso) 
	               VALUES(v_num_credito, v_correo_elec, v_calle, v_numeroextcalle, v_numerointcalle, v_nombrezona, v_municipiozona, v_cod_postal, 
				   v_nom_estado, v_telefono, v_tel_cel, dt_fecha_apertura, d_saldo_autorizado, dt_Fecha_ult_mov, d_monto_ult_mov, dt_fecha_ultimo_pago, 
				   --0,0,0,0,0,0,0,0,0, dtFecha_hoy, dtFecha_hoy);
				   d_monto_ult_pago, i_pagos_vencidos, d_pago_minimo, d_pago_una_mora, d_saldo_vencido, d_saldo_actual, d_saldo_intereses, d_saldo_iva, 
				   d_saldo_liquidar, dtFecha_hoy, dtFecha_hoy);
				   
			   commit;
		  
	  END FOREACH;
	             ------------------    TDC PROCESO DE 1A Y ÚNICA VEZ --------------------------- FIN
	    
	             ------------------ PLAZO - PROCESO DE 1A Y ÚNICA VEZ --------------------------- INI

		 select a.num_credito, a.numcte, b.monto_otorgado, a.fecha_apertura, a.num_producto, b.sdo_cap_insoluto, b.mto_fin_ven_trasp
		    from bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b 
		   where a.num_credito = b.num_credito
		     and a.num_credito not in(select num_credito from bdicobranza:cb_automatiza_800_credito where fecha_proceso = dtFecha_hoy)
			 and b.mto_fin_ven_trasp between 0 and 8
			 and a.status_cred in ('AA','BA','BT','VP','E1','E2','E3')
			 into temp paso_creds_cnr_800 with no log;
			 
			 create unique index inx_paso_creds_cnr_800 on paso_creds_cnr_800(num_credito);
			 update statistics medium for table paso_creds_cnr_800;
	  
	  FOREACH WITH HOLD
	       select num_credito, numcte, monto_otorgado, fecha_apertura, num_producto, sdo_cap_insoluto, mto_fin_ven_trasp
		    into v_num_credito, v_numcte, d_saldo_autorizado, dt_fecha_apertura, c_num_producto, d_saldo_actual_a, i_pagos_vencidos_a
			from paso_creds_cnr_800
			
	
            IF c_num_producto = '6800' THEN
			   select fecha_otorga into dt_fecha_apertura
			     from bdicred:sd_linea_prestamo
                where num_credito = v_num_credito 
				  and NVL(disposicion_activada,'') <> '';
			    
				LET dt_fecha_apertura = NVL(dt_fecha_apertura,'01/01/1900');
				
				IF NVL(dt_fecha_apertura,'') = '' OR dt_fecha_apertura = '01/01/1900' THEN
				   CONTINUE FOREACH;
				END IF;
				  
			END IF;
			
            LET dt_Fecha_ult_mov = dt_fecha_apertura;	
			LET d_monto_ult_mov = 0;

			select fecha_ultimo_pago, pago_minimo, sdo_tot_vencido, sdo_tot_liquidar, monto_ultimo_pago
		     into dt_fecha_ultimo_pago, d_pago_minimo_a, d_saldo_vencido_a, d_saldo_liquidar_a, d_monto_ult_pago_a 		  
             from bdicred:sd_indicador_cred_crd
            where empresa = cEmpresa
			  and num_credito = v_num_credito; 		  
		 	
			LET dt_fecha_ultimo_pago = NVL(dt_fecha_ultimo_pago,'');
			
			LET d_saldo_actual    = NVL(d_saldo_actual_a,0);
            LET i_pagos_vencidos  = NVL(i_pagos_vencidos_a,0);
		    LET d_pago_minimo     = NVL(d_pago_minimo_a,0);
			LET d_saldo_vencido   = NVL(d_saldo_vencido_a,0);
			LET d_saldo_liquidar  = NVL(d_saldo_liquidar_a,0);
			LET d_monto_ult_pago  = NVL(d_monto_ult_pago_a,0);
			
			IF i_dia_saldos = 1 THEN
			   	SELECT (intvig1 +  intvenc1),  (ivaintvig1 + ivaintvenc1)  INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 2 THEN
		         SELECT (intvig2 +  intvenc2),  (ivaintvig2 + ivaintvenc2)  INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				
		    ELIF i_dia_saldos = 3 THEN			
				SELECT (intvig3 +  intvenc3),  (ivaintvig3 + ivaintvenc3)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 4 THEN
			     SELECT (intvig4 +  intvenc4),  (ivaintvig4 + ivaintvenc4)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 5 THEN
			     SELECT (intvig5 +  intvenc5),  (ivaintvig5 + ivaintvenc5)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
			
            ELIF i_dia_saldos = 6 THEN
			     SELECT (intvig6 +  intvenc6),  (ivaintvig6 + ivaintvenc6)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
			
			ELIF i_dia_saldos = 7 THEN
			     SELECT (intvig7 +  intvenc7),  (ivaintvig7 + ivaintvenc7)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 8 THEN
			     SELECT (intvig8 +  intvenc8),  (ivaintvig8 + ivaintvenc8)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 9 THEN
			     SELECT (intvig9 +  intvenc9),  (ivaintvig9 + ivaintvenc9)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 10 THEN
			     SELECT (intvig10+  intvenc10),  (ivaintvig10 + ivaintvenc10)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 11 THEN
			     SELECT (intvig11 +  intvenc11),  (ivaintvig11 + ivaintvenc11)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 12 THEN
			     SELECT (intvig12 +  intvenc12),  (ivaintvig12 + ivaintvenc12)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 13 THEN
			     SELECT (intvig13 +  intvenc13),  (ivaintvig13 + ivaintvenc13)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 14 THEN
			     SELECT (intvig14 +  intvenc14),  (ivaintvig14 + ivaintvenc14)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 15 THEN
			     SELECT (intvig15 +  intvenc15),  (ivaintvig15 + ivaintvenc15)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 16 THEN
			     SELECT (intvig16 +  intvenc16),  (ivaintvig16 + ivaintvenc16)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 17 THEN
			     SELECT (intvig17 +  intvenc17),  (ivaintvig17 + ivaintvenc17)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 18 THEN
			     SELECT (intvig18 +  intvenc18),  (ivaintvig18 + ivaintvenc18)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 19 THEN
			     SELECT (intvig19 +  intvenc19),  (ivaintvig19 + ivaintvenc19)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 20 THEN
			     SELECT (intvig20 +  intvenc20),  (ivaintvig20 + ivaintvenc20)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 21 THEN
			     SELECT (intvig21 +  intvenc21),  (ivaintvig21 + ivaintvenc21)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 22 THEN
			     SELECT (intvig22 +  intvenc22),  (ivaintvig22 + ivaintvenc22)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 23 THEN
			     SELECT (intvig23 +  intvenc23),  (ivaintvig23 + ivaintvenc23)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 24 THEN
			     SELECT (intvig24 +  intvenc24),  (ivaintvig24 + ivaintvenc24)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 25 THEN
			     SELECT (intvig25 +  intvenc25),  (ivaintvig25 + ivaintvenc25)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 26 THEN
			     SELECT (intvig26 +  intvenc26),  (ivaintvig26 + ivaintvenc26)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 27 THEN
			     SELECT (intvig27 +  intvenc27),  (ivaintvig27 + ivaintvenc27)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 28 THEN
			     SELECT (intvig28 +  intvenc28),  (ivaintvig28 + ivaintvenc28)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 29 THEN
			     SELECT (intvig29 +  intvenc29),  (ivaintvig29 + ivaintvenc29)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELIF i_dia_saldos = 30 THEN
			     SELECT (intvig30 +  intvenc30),  (ivaintvig30 + ivaintvenc30)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
				 
			ELSE
			     SELECT (intvig31 +  intvenc31),  (ivaintvig31 + ivaintvenc31)   INTO d_saldo_intereses_a, d_saldo_iva_a
				  FROM bdicred:sd_sdodiariocrd
				 WHERE fecha =  dtFecha_IniMes and num_credito = v_num_credito;
			
			END IF;
			
			LET d_saldo_intereses_a = NVL(d_saldo_intereses_a,0);
            LET d_saldo_iva_a       = NVL(d_saldo_iva_a,0);
			
			SELECT SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))
  			  INTO dIntMoratorio
			  FROM bdicred:sd_amortiza_creditocrd
			 WHERE empresa = cEmpresa
			   AND num_credito = v_num_credito
			   AND capital_status IN ('2','7','6');
			
			LET d_saldo_intereses = d_saldo_intereses_a +dIntMoratorio;
			LET d_saldo_iva       = d_saldo_iva_a + round( (dIntMoratorio*.16),0);
			
			-- Como es de única vez, se descarga de cualquier manera
		    LET iGenera_info_dia = 1;
		    
			SELECT limit 1 correo_elec into v_correo_elec
		      FROM bdinteg:si_correos
		     WHERE numcte = v_numcte
		       AND status_correo = 'A';
			
				 SELECT LIMIT 1 d.cod_postal, d.numeroextcalle, d.numerointcalle, e.nombrezona, e.municipiozona, f.nombrecalle, h.nombre
					INTO v_cod_postal, v_numeroextcalle, v_numerointcalle, v_nombrezona, v_municipiozona, v_calle, v_nom_estado 
				   FROM bdinteg:si_direcciones_actual d  
										join bdinteg:si_catzonas e on e.numerociudad = d.numerociudad and e.numerocolonia = d.numerocolonia
										join bdinteg:si_catcalles f on f.numerocalle = d.numerocalle
										join bdinteg:si_ciudades i on i.ciudad_coppel = d.numerociudad join bdinteg:si_estados h on h.estado = i.estado
				   WHERE d.numcte = v_numcte
					 AND d.tipo_dir = '1';
		  
		  
   	      SELECT LIMIT 1 tel.telefono INTO v_telefono
   	        FROM bdinteg:si_telefonos_actual tel 
           WHERE tel.numcte = v_numcte  
             AND tel.tipo_tel = 1 
             AND tel.cofetel ='V';
 
			
		  SELECT LIMIT 1 tel.telefono INTO v_tel_cel
   	        FROM bdinteg:si_telefonos_actual tel 
           WHERE tel.numcte = v_numcte  
             AND tel.tipo_tel = 2 
             AND tel.cofetel ='V';
			
			
			SELECT pago_una_mora into d_pago_una_mora
			  from bdicred:sd_sdos_cartera_linea
			  where num_credito = v_num_credito;
			  
			 LET d_pago_una_mora = nvl(d_pago_una_mora,0);
			 
			 
			 begin;
			      INSERT INTO bdicobranza:cb_automatiza_800_credito(num_credito, correo_electronico, calle, num_exterior, num_interior, colonia, municipio, 
				   cp, estado, telefono, celular, fecha_apertura, saldo_autorizado, fecha_ultimo_mov, monto_ultimo_mov, fecha_ultimo_pago, monto_ultimo_pago,
				   pagos_vencidos, pago_minimo, pago_una_mora, saldo_vencido, saldo_actual, saldo_intereses, saldo_iva, saldo_liquidar, fecha_domicilio, 
				   fecha_proceso) 
	               VALUES(v_num_credito, v_correo_elec, v_calle, v_numeroextcalle, v_numerointcalle, v_nombrezona, v_municipiozona, v_cod_postal, 
				   v_nom_estado, v_telefono, v_tel_cel, dt_fecha_apertura, d_saldo_autorizado, dt_Fecha_ult_mov, d_monto_ult_mov, dt_fecha_ultimo_pago, 
				   --0,0,0,0,0,0,0,0,0, dtFecha_hoy, dtFecha_hoy);
				    d_monto_ult_pago, i_pagos_vencidos, d_pago_minimo, d_pago_una_mora, d_saldo_vencido, d_saldo_actual, d_saldo_intereses, d_saldo_iva, 
				    d_saldo_liquidar, dtFecha_hoy, dtFecha_hoy);

			   commit;
			 
	  
	  END FOREACH;
	
	      ------------------ PLAZO -- PROCESO DE 1A Y ÚNICA VEZ ---------------------------
		  
	END IF;
	
	    IF cEjecuc_1a_vez = 1 and NVL(dt_fecha_proceso_800,'') <> '' THEN
		   LET dtFecha_hoy = dt_fecha_proceso_800;
		END IF;
	                       
		 LET cSql = "";
		 
		 IF i_dia_semana >= 2 AND i_dia_semana <= 6 THEN			   		   
			
			 LET cSql = " SELECT b.numcte, a.num_credito, b.num_producto, c.nombre1, c.nombre2, c.apell_paterno, c.apell_materno, " 
			            || "to_char(d.fecha_nac, '%d/%m/%Y'),  c.rfc, a.correo_electronico, a.calle, a.num_exterior, a.num_interior, a.colonia, a.municipio, "
						|| "a.cp, a.estado, a.telefono, a.celular, to_char(a.fecha_apertura, '%d/%m/%Y'), a.saldo_autorizado, "
						|| "to_char(a.fecha_ultimo_mov, '%d/%m/%Y'), "
						|| "a.monto_ultimo_mov, to_char(a.fecha_ultimo_pago, '%d/%m/%Y'), a.monto_ultimo_pago, a.pagos_vencidos, a.pago_minimo, "
						|| "a.pago_una_mora, a.saldo_vencido, a.saldo_actual, a.saldo_intereses, a.saldo_iva, a.saldo_liquidar "
						|| " FROM bdicobranza:cb_automatiza_800_credito a," 
						|| "    bdicred:sd_maecred b,"
						|| "    bdinteg:si_cliente c," 
						|| "    bdinteg:si_ctepf d"
						|| " WHERE a.num_credito = b.num_credito " 
						|| "   AND b.numcte = c.numcte " 
						|| "   AND c.numcte = d.numcte "
						|| "   AND a.fecha_proceso = '" || dtFecha_hoy || "' "   ---|| "';" ; 
						|| "UNION "
						|| "SELECT b.numcte, a.num_credito, b.num_producto, c.nombre1, c.nombre2, c.apell_paterno, c.apell_materno, " 
						|| "to_char(d.fecha_nac, '%d/%m/%Y'), c.rfc, a.correo_electronico, a.calle, a.num_exterior, a.num_interior, a.colonia, a.municipio, "
						|| "a.cp, a.estado, a.telefono, a.celular, to_char(a.fecha_apertura, '%d/%m/%Y'), a.saldo_autorizado, "
						|| "to_char(a.fecha_ultimo_mov, '%d/%m/%Y'), " 
						|| "a.monto_ultimo_mov, to_char(a.fecha_ultimo_pago, '%d/%m/%Y'), a.monto_ultimo_pago, a.pagos_vencidos, a.pago_minimo, "
						|| "a.pago_una_mora, a.saldo_vencido, a.saldo_actual, a.saldo_intereses, a.saldo_iva, a.saldo_liquidar "
						|| " FROM bdicobranza:cb_automatiza_800_credito a," 
						|| "    bdicred:sd_maecredcrd b,"
						|| "    bdinteg:si_cliente c," 
						|| "    bdinteg:si_ctepf d "
						|| " WHERE a.num_credito = b.num_credito" 
						|| "   AND b.numcte = c.numcte" 
						|| "   AND c.numcte = d.numcte"
						|| "   AND a.fecha_proceso = '" || dtFecha_hoy || "';" ;
					
		 ELIF i_dia_semana = 1 THEN
		 
		     LET cSql = " SELECT b.numcte, a.num_credito, b.num_producto, c.nombre1, c.nombre2, c.apell_paterno, c.apell_materno, " 
			            || "to_char(d.fecha_nac, '%d/%m/%Y'),  c.rfc, a.correo_electronico, a.calle, a.num_exterior, a.num_interior, a.colonia, a.municipio, "
						|| "a.cp, a.estado, a.telefono, a.celular, to_char(a.fecha_apertura, '%d/%m/%Y'), a.saldo_autorizado, "
						|| "to_char(a.fecha_ultimo_mov, '%d/%m/%Y'), "
						|| "a.monto_ultimo_mov, to_char(a.fecha_ultimo_pago, '%d/%m/%Y'), a.monto_ultimo_pago, a.pagos_vencidos, a.pago_minimo, "
						|| "a.pago_una_mora, a.saldo_vencido, a.saldo_actual, a.saldo_intereses, a.saldo_iva, a.saldo_liquidar "
						|| " FROM bdicobranza:cb_automatiza_800_credito a," 
						|| "    bdicred:sd_maecred b,"
						|| "    bdinteg:si_cliente c," 
						|| "    bdinteg:si_ctepf d"
						|| " WHERE a.num_credito = b.num_credito " 
						|| "   AND b.numcte = c.numcte " 
						|| "   AND c.numcte = d.numcte "
						|| "   AND a.fecha_proceso BETWEEN '" || dtFecha_diaprev || "'" || ' AND ' || "'" || dtFecha_hoy || "' "
						|| "UNION "
						|| "SELECT b.numcte, a.num_credito, b.num_producto, c.nombre1, c.nombre2, c.apell_paterno, c.apell_materno, " 
						|| "to_char(d.fecha_nac, '%d/%m/%Y'), c.rfc, a.correo_electronico, a.calle, a.num_exterior, a.num_interior, a.colonia, a.municipio, "
						|| "a.cp, a.estado, a.telefono, a.celular, to_char(a.fecha_apertura, '%d/%m/%Y'), a.saldo_autorizado, "
						|| "to_char(a.fecha_ultimo_mov, '%d/%m/%Y'), " 
						|| "a.monto_ultimo_mov, to_char(a.fecha_ultimo_pago, '%d/%m/%Y'), a.monto_ultimo_pago, a.pagos_vencidos, a.pago_minimo, "
						|| "a.pago_una_mora, a.saldo_vencido, a.saldo_actual, a.saldo_intereses, a.saldo_iva, a.saldo_liquidar "
						|| " FROM bdicobranza:cb_automatiza_800_credito a," 
						|| "    bdicred:sd_maecredcrd b,"
						|| "    bdinteg:si_cliente c," 
						|| "    bdinteg:si_ctepf d "
						|| " WHERE a.num_credito = b.num_credito" 
						|| "   AND b.numcte = c.numcte" 
						|| "   AND c.numcte = d.numcte"
		                || "   AND a.fecha_proceso BETWEEN '" || dtFecha_diaprev || "'" || ' AND ' || "'" || dtFecha_hoy || "';";
		
		END IF;
		 
		 IF i_dia_semana >= 1 AND i_dia_semana <= 6 THEN
		 
  		 LET cGeneraSql = "";	
  		 LET cGeneraSql = "'" || TRIM(cRuta) ||TRIM(cNombreArchivo_aux) || "' DELIMITER '|'"; 
  		 LET cGeneraSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cGeneraSql) || ' ' || TRIM(cSql) || '" > ' || TRIM(cRuta) || 'Genera_info_800.sql';
  		 SYSTEM cGeneraSql;
  		 
  		 LET cSql = '' ;
  		 LET cSql = 'chmod 775 ' || TRIM(cRuta) || 'Genera_info_800.sql';
  		 LET cSql = '' ;
  		 LET cSql = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Genera_info_800.sql';
  		 SYSTEM trim(cSql);
  		
  		 LET cSql = '' ;
  		 LET cSql = 'cat ' || trim(cRuta) || trim(cNombreArchivo_head) || ' ' || trim(cRuta) || trim(cNombreArchivo_aux)  || '>' ||trim(cRuta) || trim(cNombreArchivo); 
  		 SYSTEM trim(cSql);
  		 
  		 LET cSql = '' ;
  		 LET cSql = 'rm ' || TRIM(cRuta) || trim(cNombreArchivo_aux) ;
  		 SYSTEM trim(cSql);
  		 
  		 LET cSql = '';
  	     LET cSql = 'gzip -f ' ||trim(cRuta) || trim(cNombreArchivo); 
  		 SYSTEM trim(cSql);
		 
		 END IF;
		 
		 -- Actualizar la bandera con la fecha del día de ejecución
		 IF cEjecuc_1a_vez = 1 THEN
		   begin;
		     UPDATE bdicobranza:cb_procesos_cob SET fecha_insert = dt_fecha_proceso_800
		      WHERE empresa = cEmpresa and num_proceso = '0090' and sistema = 'AGEXT';
		   commit;
		 ELSE
		   begin;
		     UPDATE bdicobranza:cb_procesos_cob SET fecha_insert = dtFecha_hoy
		     WHERE empresa = cEmpresa and num_proceso = '0090' and sistema = 'AGEXT';
		   commit;
         END IF;		   
		   
		 DROP TABLE paso_creds_tdc_800;
		 DROP TABLE paso_creds_cnr_800;

	EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa,vproceso,cCodRet,cMensajeRet,"03") INTO cCodRet_2;
	
RETURN cCodRet, trim(cMensajeRet);

END
END PROCEDURE;