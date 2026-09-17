create procedure "informix".burofisicas()
-- EXECUTE PROCEDURE burofisicas();
       returning char(5),
                 char(50);
   -- Modifs: 20200729
   define vcodret        char(5);
   define vcodret2       char(5);
   define vfecha_hoy     date;
--jom ini
   define vfecha_corte      date;
   define vcredito_maximo   decimal(18,2);
   define vrea_cal_cuota    integer;
--jom fin
   define vmoneda        char(2);
   define vmonto         decimal(18);
   define vlinea_prod    decimal(18,2);
   define vheader        char(150);
   define vheader1       char(70);
   define vsegmento_pn   char(375);
   define vsegmento1_pn  char(375);
   define vsegmento_pa   char(326);
   define vsegmento2_pa  char(326);
   define vsegmento_tl   char(436);
   define vsegmento3_tl  char(436);
   define vsegmento4_tr  char(255);
   define vsegmento5     char(253);
   define vlongitud      integer;
   define vapell_paterno char(26);
   define vapell_materno char(26);
   define vnombre1       char(26);
   define vnombre2       char(26);
   define vfecha_nac     date;
   define vano           char(4);
   define vmes           char(2);
   define vdia           char(2);
   define vrfc           char(13);
   define vfecha_alta    date;
   define vnacionalidad  char(3);
   define vresidencia    char(1);
   define vestado_civil  char(1);
   define vsexo          char(1);
   define vcalle,vcalle1 char(40);
   define vcolonia       char(40);
   define vmunicipio     char(3);
   define vdelegacion    char(40);
   define vdelegacion1   char(3);
   define vestado        char(4);
   define vcod_postal    char(10);
   define vnum_credito   char(25);
   define vnum_tarjeta   char(25);
   define vtp_linea      char(4);
   define vdivisa        char(2);
   define vnum_pagos     char(5);
   define vfrecuencia    char(1);
   define vfecha_apertura date;
   define vfecha_pago,vfecha_cuota    date;
   define vfecha_finiq   date;
   define vnumcte        char(20);
   define vencabezado1   char(4);
   define vversion       char(2);
   define vclave_usu     char(10);
   define vclave_usu_bc  char(10);
   define vnombre_usu    char(16);
   define vciclo         char(2);
   define vfecha_reporte char(8);
   define vuso_futuro    char(10);
   define vinf_adicional char(98);
   define vsql           char(200);
   define varchivo       char(60);
   define varchivo_des   char(60);
   define i              smallint;
   define vfecha_ini     date;
   define vfecha_fin_mes_ant date;
   define vstatus_cred   char(2);
   define vpago_cap, vpago_int date;
   define vsiglas_edo    char(4);
   define vsigla_div     char(2);
   define vfrecpago      char(1);
   define vcuota_cap     integer;
   define vmin_cuota,vcuota_int smallint;
   define vcuotas_vencap,vcuotas_venint,vcuotas_ven smallint;
   define vmonto_otorgado, vsaldo_vig, vsaldo_venc,
          vsaldo_actual,vmonto_pago,v_interes decimal(18,2);
   define vfecha_cap, vfecha_int, vfecha_venc, vfecha_pricuo,vfechacuota date;
   define vdiasvenc smallint;
   define vmop char(2);
   define vnumreg integer;
   define vnumreg_bc integer;
   define nombre_estado char(30);
   define existe smallint;
   define vquita char(40);
   define existe1 smallint;
   define vespacio char(1);
   define existecod smallint;
   define vciudad        char(40);
   define vruta_interfase      char(200);
   define vsecuencia smallint;
   define hueco smallint;
   define vmanzana smallint;
   define vandador smallint;
   define vlote smallint;
   define vedificio smallint;
   define ventrada smallint;
   define vcodini,vcodfin,vcod_postala  integer;
   define vdiacuota smallint;
   define vreg_proc INTEGER;
   define vtot_proc INTEGER;
   define contador_commit INTEGER;
   DEFINE sCommit      SMALLINT;
   define contador_stat INTEGER;
   define actualiza_esta integer;
   define iTotalProcesados integer; 
   define bmotivo integer ; --IPCB Abr15 -para identificar que le falta el segmento de direccion
   
-- Agrega variables para tabla de datos en texto
-- Segmento PN
   define tb_apell_paterno char(26);
   define tb_apell_materno char(26);

   define tb_nombre1       char(26);
   define tb_nombre2       char(26);
   define tb_fecha_nac     char(08);
   define tb_rfc           char(13);
   define tb_nacionalidad  char(03);
   define tb_estado_civil  char(1);
   define tb_sexo          char(1);

-- Segmento PA
   define tb_calle         char(40);
   define tb_colonia       char(40);
   define tb_delegacion    char(40);
   define tb_ciudad        char(40);
   define tb_estado        char(4);
   define tb_cod_postal    char(10);
   define tb_codigo_pais   char(2);  --RQM 09 467_Version 14  

-- Segmento TL
   define tb_clave_usu         char(10);
   define tb_nombre_usu        char(16);
   define tb_num_credito       char(25);
   define tb_num_credito_ext   char(25); --IPCB marzo2015   
   define tb_responsabilidad   char(01);
   define tb_tipo_cuenta       char(01);
   define tb_tipo_producto     char(02);
   define tb_clave_monetaria   char(02);
   define tb_num_pagos         char(05);
   define tb_frecpago          char(01);
   define tb_monto_pagar       decimal(18);
   define tb_fecha_apertura    char(08);
   define tb_fecha_ult_pago    char(08);
   define tb_fecha_ult_compra  char(08);
   define tb_fecha_cierre      char(08);
   define tb_fecha_reporte     char(08);
   define tb_credito_maximo    decimal(18,2); 
   define tb_saldo_actual      decimal(18,2);
   define tb_monto_otorgado    decimal(18,2);
   define tb_saldo_venc        decimal(18,2);
   define tb_cuotas_ven        smallint;
   define tb_mop               char(02);
   define tb_clave_obs         char(02);
   define tb_fecha_vencimiento char(08);
   define tb_monto_insoluto    decimal(18,2);
   define tb_ultimo_pago       decimal(18,2);
   define tb_plazo_meses       char(5); --RQM 09 467_Version 14

-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
   define tb_dias_atraso INTEGER;
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				   
   

   define vlMnpioReportar  char(40);  --fmj dic2012
   define vlCodigoReportar   char(10);
   define vlCodigoPOstalZona char(5);
   define vlCodigoPOstalZona_2 char(7);
-- Venta de cartera ini
   define iSqlErr              INTEGER;

   DEFINE cNumProducto         CHAR(4);
   DEFINE cCredExterno         CHAR(20);
   DEFINE dtFechaApRee         DATE;
   DEFINE indice               CHAR(50);
   DEFINE dtFecha_corteRee     DATE;
   DEFINE iDiaCorteRee         INTEGER;
   DEFINE cNumCredito          CHAR(25);
   DEFINE cMensajeFin          CHAR(50);
   
-- Segmento TRLR
   DEFINE tb_nombre_otorg      CHAR(09);
   DEFINE tb_domicilio_dev     CHAR(100);

   DEFINE iCP                  INTEGER;
   DEFINE itempsepomex         SMALLINT;
   DEFINE itempcredito         SMALLINT;

-- CAMPOS NUEVOS 12
   DEFINE vfechavencido       date;
   DEFINE vmontolutpago       decimal(18,2);      
   DEFINE vmontoinsoluto      decimal(18,2);      

   DEFINE vfecha_vencido date;
   DEFINE vdiasatraso INTEGER;
   DEFINE vfechaultpago date;
   DEFINE vfechaultcompra date;
   define vfecha_dia date;

--IPCB Validacion para Clve_obs 'EL'
define vstatus_credAnt char(2);
define vsaldo_vencAnt  decimal(18,2);
--IPCB Valida baja para Clave_obs 'UP'
DEFINE vidbaja  char(4);
--IPCB CAMPOS NUEVOS RQM 09 467_Version 14 
   define scalle_conocido 		smallint;
   define cpais     			char(3);
   define ccodigo_pais  		char(2);
   define cplazo_meses  		char(4);
   define dplazo_meses  		decimal(5,2);
   define vclave_ciudad   		char(3);
   define vclave_edo      		char(2);
   
   DEFINE tb_monto_originacion  decimal(18,2);
   DEFINE d_monto_originacion   decimal(18,2);
   DEFINE dmonto_autorizado     decimal(18,2);
   
   define vsegmento_pe   		 char(500);
   define vcalle_pe,vcalle_pe1   char(40);
   define vcolonia_pe       	 char(40);
   define vdelegacion_pe    	 char(40);
   define vestado_pe        	 char(4);
   define vcod_postal_pe    	 char(10);
   define vmanzana_pe 			 smallint;
   define vandador_pe 			 smallint;
   define vlote_pe 				 smallint;
   define vedificio_pe 			 smallint;
   define ventrada_pe 			 smallint;
   define vcodini_pe,vcodfin_pe  integer; 
   define vlCodigoPOstalZona_pe  char(5);
   define vlCodigoPOstalZona_pe_2  char(7);
   define scalle_conocido_pe 	 smallint;
   define cpais_pe     			 char(3);
   define vclave_ciudad_pe   	 char(3);
   define vclave_edo_pe      	 char(2); 
   define iCP_pe                 integer;
   define vlMnpioReportar_pe     char(40);
   define vlCodigoReportar_pe    char(10);
   define vciudad_pe             char(40);
   define vmonto_int			 decimal(18,2);
   
-- Segmento PE
   define cnombre_empleador   char(99);
   define tb_nombre_empleador char(99);
   define vprofesion          char(3);
   define tb_origen_razon_soc char(2);
   define tb_calle_pe         char(40);
   define tb_colonia_pe       char(40);
   define tb_delegacion_pe    char(40);   
   define tb_ciudad_pe        char(40);
   define tb_estado_pe        char(4);
   define tb_cod_postal_pe    char(10);
   define tb_fingcartvenc	  char(8);
   define v_fecha_vencto 	  date;
   define vf_ingcartvenc 	  char(8);
   define tb_diasatraso       smallint;
--IPCB CAMPOS NUEVOS RQM 09 467_Version 14    
  DEFINE vHora char(12);  --- SOLO PRUEBAS 
  DEFINE vDia1  char(10); --- SOLO PRUEBAS
  
  DEFINE vsdo_cierre_credisol decimal(18,2); --IPCB Jul 2018 -Agrega al saldo  el saldo de las credisoluciones con que cuente.
  DEFINE iDiaCorte            INTEGER;
  DEFINE iEjecucion_primera_vez  INTEGER;
  DEFINE tb_num_tarjeta       CHAR(25);
  DEFINE tb_num_tarjeta_ant   CHAR(25);
  DEFINE cProceso             CHAR(4);
  DEFINE vempresa             CHAR(3);
  DEFINE cMensaje             CHAR(50);
  DEFINE iIsamErr             INTEGER;
  
  DEFINE vnum_tarjeta_ant      CHAR(25);
  DEFINE vCodstatus_tarjetanvo CHAR(3);
  DEFINE vClaveObserv_tarjeta  CHAR(2);
  DEFINE dFecha_reporte_tarj   DATE;
  DEFINE cStatus_tar           CHAR(1);
  DEFINE cTarjetaCambiada      CHAR(1);
  DEFINE vsegmento3_tl_2       CHAR(436);
  
  DEFINE tb_num_tarjeta_2      CHAR(25);
  DEFINE tb_monto_pagar_2      DECIMAL(18); 
  DEFINE tb_fecha_cierre_2     CHAR(08);
  DEFINE tb_saldo_actual_2     DECIMAL(18,2);
  DEFINE tb_saldo_venc_2       DECIMAL(18,2);
  DEFINE tb_mop_2              CHAR(02);
  DEFINE tb_clave_obs_2        CHAR(02);
  DEFINE iCuenta_regs          INTEGER;  
  DEFINE vnumeroextcalle       CHAR(10);
  DEFINE vnumerointcalle       CHAR(10);
  DEFINE vnombrecalle          CHAR(30);
  DEFINE vnumeroextcalle_pe    CHAR(10);
  DEFINE vnumerointcalle_pe    CHAR(10);
  DEFINE vnombrecalle_pe       CHAR(30);
  DEFINE vCuentaExiste         CHAR(20);
  DEFINE  vfac_pagmin, vmto_pago_min   DECIMAL(18,2);  --IPCB 10Nov20// Variables para calculo de monto_pagar
  DEFINE vv_frep_fuc, vv_frep_fup, vv_frep_fap  INTEGER; --IPCB 10Nov20// Variables para calculo de monto_pagar
  DEFINE vNum_credito_bfbase   CHAR(20);
  DEFINE cArma_PN              CHAR(1);
  DEFINE cArma_PA              CHAR(1);
  DEFINE cArma_PE              CHAR(1);
  DEFINE vsegmento_pn_base     CHAR(375);
  DEFINE vsegmento_pa_base     CHAR(326);
  DEFINE vsegmento_pe_base     CHAR(500);
  DEFINE vsegmento_pn_base_t   CHAR(375);
  DEFINE vsegmento_pa_base_t   CHAR(326);
  DEFINE vsegmento_pe_base_t   CHAR(500);
  DEFINE dt_fecha_reporte      DATE;
  DEFINE vFecha_insert_dom     DATE;
  DEFINE vfecha_insert_trabajo DATE;
  DEFINE iRegsInsert           INTEGER;
  DEFINE iRegsUpd              INTEGER;
  DEFINE vestado_civil_prev    CHAR(1);
  DEFINE vprofesion_prev       CHAR(3);
  DEFINE cCambio_estado_civil  CHAR(1);
  DEFINE vrazon_social_prev    char(99);
  DEFINE cnombre_empleador_temp  char(99);
  DEFINE iLong_NomEmpleador    INTEGER;
  DEFINE cEsNumerico           CHAR(1);
  DEFINE i_act                 INTEGER;
  DEFINE cCredExterno_bis      CHAR(20);
  
  DEFINE vIndProceso           CHAR(1); --RQM 09 549
  DEFINE vIndicaQuita		   CHAR(1); --RQM 09 549
  DEFINE vMontoQuita           DECIMAL(18,2);  --RQM 09 549
  DEFINE vFechaLiquida         DATE; --RQM 09 549
  DEFINE vFechInsrt			   DATE; --RQM 09 549
  DEFINE vFechaNegociacion	   DATE; --RQM 09 549
  DEFINE existcred			   INTEGER; --RQM 09 549
  
  DEFINE vindicador_exec		CHAR(1); --JAHJ
  define strpista				char(50);
  
   let vcodret = "000";
   let vsql = "";
   LET cNumProducto = "";
   LET cCredExterno = "";
   LET dtFechaApRee = DATE(0);
   LET contador_commit = 0;
   LET sCommit                 = 0;
   LET dtFecha_corteRee = DATE(0);
   LET iDiaCorteRee = 0;
   LET iTotalProcesados = 0;
   LET cNumCredito ='';
   LET cMensajeFin = '';
   LET vnum_credito = '';
   LET itempsepomex    = 0;
   LET itempcredito    = 0;
   LET vfecha_fin_mes_ant = date(1);
   LET vfecha_vencido = date(1);
   LET vmontolutpago = 0;
   LET vmontoinsoluto = 0;
   LET vdiasatraso = 0;
   LET vfechaultpago = date(1);
   LET vfechaultcompra = date(1);
   let vfecha_dia = date(1);
   LET vstatus_credAnt = "";
   LET vsaldo_vencAnt= 0;
   LET vidbaja ="";
   LET bmotivo = 0;  --IPCB Abr15-para identificar que le falta el segmento de direccio
   LET scalle_conocido = 0;
   LET cpais    = '';
   LET ccodigo_pais = '';
   LET tb_codigo_pais = '';
   LET cnombre_empleador = '';
   LET tb_nombre_empleador = '';
   LET cplazo_meses = '';
   LET tb_monto_originacion = 0;
   LET d_monto_originacion = 0;
   LET tb_plazo_meses = '';
   LET vprofesion = '';
   LET dplazo_meses = 0;
   LET vclave_ciudad = '';
   LET vclave_edo = '';
   LET dmonto_autorizado = 0;
   LET tb_origen_razon_soc = '';
   LET vsdo_cierre_credisol = 0; --IPCB Jul 2018 -Agrega al saldo  el saldo de las credisoluciones con que cuente.
   LET iDiaCorte = 0;
   LET vnum_tarjeta = '';
   LET vnum_tarjeta_ant = '';
   LET vCodstatus_tarjetanvo = '';
   LET vClaveObserv_tarjeta = '';
   LET iEjecucion_primera_vez = 0;
   LET tb_num_tarjeta = '';
   LET tb_num_tarjeta_ant = '';
   LET cProceso = '0056';
   LET vempresa = '001';
   LET cMensaje = '';
   LET iIsamErr = 0;
   LET vcodret2 = '';
   LET dFecha_reporte_tarj = date(1);
   LET cStatus_tar = '';
   LET cTarjetaCambiada = '';
   LET vsegmento3_tl_2 = '';
   LET tb_num_tarjeta_2   = 0;
   LET tb_monto_pagar_2   = 0;
   LET tb_fecha_cierre_2  = '';
   LET tb_saldo_actual_2  = 0;
   LET tb_saldo_venc_2    = 0;
   LET tb_mop_2           = '';
   LET tb_clave_obs_2     = '';
   LET iCuenta_regs       = 0;
   LET vnumeroextcalle    = '';
   LET vnumerointcalle    = '';
   LET vnombrecalle       = '';
   LET vnumeroextcalle_pe   = '';
   LET vnumerointcalle_pe   = ''; 
   LET vnombrecalle_pe      = '';
   LET vCuentaExiste        = '';
   LET vfac_pagmin         = 0; --IPCB 10Nov20
   LET vmto_pago_min       = 0; --IPCB 10Nov20
   LET vv_frep_fuc = 0;         --IPCB 10Nov20
   LET vv_frep_fup = 0;         --IPCB 10Nov20
   LET vv_frep_fap = 0;         --IPCB 10Nov20 

   LET vNum_credito_bfbase  = '';
   LET cArma_PN             = '';
   LET cArma_PA             = '';
   LET cArma_PE             = '';
   LET vsegmento_pn_base    = '';
   LET vsegmento_pa_base    = '';
   LET vsegmento_pe_base    = '';
   LET vsegmento_pn_base_t  = '';
   LET vsegmento_pa_base_t  = '';
   LET vsegmento_pe_base_t  = '';
   LET dt_fecha_reporte     = date(1);
   LET vFecha_insert_dom    = date(1);
   LET vfecha_insert_trabajo = date(1);
   LET iRegsInsert           = 0;
   LET iRegsUpd              = 0;
   LET tb_num_credito        = '';
   LET tb_monto_pagar        =0;
   LET vfecha_apertura       = date(1);
   LET vestado_civil_prev    = '';
   LET vprofesion_prev       = '';
   LET cCambio_estado_civil  = '';
   LET vrazon_social_prev    = '';
   LET cnombre_empleador_temp = '';
   LET iLong_NomEmpleador     = 0;
   LET cEsNumerico            = '';
   LET i_act                  = 0;
   LET cCredExterno_bis       = '';
   
   LET vIndProceso            = ''; --RQM 09 549
   LET vIndicaQuita			  = ''; --RQM 09 549
   LET vMontoQuita            = 0; 	--RQM 09 549
   LET vFechaLiquida          = date(1); --RQM 09 549
   LET vFechInsrt			  = date(1); --RQM 09 549
   LET vFechaNegociacion	  = DATE(1); --RQM 09 549
   LET existcred			  = 0; --RQM 09 549
   
   LET vindicador_exec		= 0;  -- JAHJ
   let strpista = '';
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
   LET tb_dias_atraso         = 0;
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN   
   
   
BEGIN

       ON EXCEPTION SET iSqlErr, iIsamErr
           IF iSqlErr != 0 THEN
              IF itempsepomex = 1 THEN
                 drop table sepomex;
              END IF;
              IF itempcredito = 1 THEN
                 drop table creditos;
				 drop table temp_creditos2;
				 drop table cred_bqc_tdc;
              END IF;
              let vcodret = iSqlErr;
              IF (sCommit = -1) THEN
                 rollback work;
              END IF;
			  
			  let cMensaje = trim(vcodret) || '- ' || iIsamErr || '-' || trim(vnum_credito) || ' ' || strpista;
			  CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '02') RETURNING vcodret2;
			  
              RETURN vcodret,vnum_credito ||' '|| strpista;
           END IF;
        END EXCEPTION;


   LET vsegmento4_tr           = '';
   LET tb_nombre_otorg         = '';
   LET tb_domicilio_dev        = '';

   LET iCP                     = 0;
   LET vsegmento_pe 		   = ''; --RQM 09 467_Version 14
   
--SET DEBUG FILE TO "/RESPALDOS/ipcb/cintas/trace_burofisicas.unl";
--  SET DEBUG FILE TO "/ifxsif01/macf/burofisicas.out";
--  TRACE ON; 

   /* --- SOLO PRUEBAS
     LET vHora = ''; LET vDia1 = '';
     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vDia1 
      from sysmaster:sysshmvals;

     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora 
      from sysmaster:sysshmvals;

      INSERT INTO bdiburo:br_cronometro(accion,fecha,hora) values('Inicio',vDia1, vHora);
    --- SOLO PRUEBAS */ 

	CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '01') RETURNING vcodret2; 
	
	set isolation to dirty read;
	set lock mode to wait 3;

   select upper(valor) into vencabezado1
      from br_param
      where cod_param = 3;

   select upper(valor) into vversion
      from br_param
      where cod_param = 4;
    
   select upper(valor) into vclave_usu
      from br_param
      where cod_param = 1;

   select upper(valor) into vnombre_usu
      from br_param
      where cod_param = 6;

   select upper(valor) into vciclo
      from br_param
      where cod_param = 7;

   select upper(valor) into vuso_futuro
      from br_param
      where cod_param = 8;

   select upper(valor) into vclave_usu_bc
      from br_param
      where cod_param = 127;

   let vinf_adicional = "&";

   select pri_dia_mes - 1 
          --,date(to_date(LPAD(year(pri_dia_mes - 1),4,0)||LPAD(month(pri_dia_mes - 1),2,0)||day(20),"%Y%m%d"))
      into vfecha_hoy --, vfecha_corte
      from bdinteg:si_fechas
     where empresa = '001';

	--JAHJ recuperamos el estado de proceso
	select valor into vindicador_exec
		from br_param
		where cod_param = 170;
	
	--let vclave_usu = 'JVA4190BAN';
	
--temporal para pruebas unicamente
  --let vfecha_hoy = mdy('07','01','2025');
   --let vfecha_corte = mdy('12','20','2021');
--temporal para pruebas unicamente

-- Hace las adaptaciones a la tabla de SEPOMEX
select {+INDEX(bdinteg:si_catsepomex sicatsepomex)} *,
CASE when  d_estado= 'AGUASCALIENTES'then 'AGS'
when  d_estado= 'BAJA CALIFORNIA'then 'BCN'
when  d_estado= 'BAJA CALIFORNIA SUR'then 'BCS'
when  d_estado= 'CAMPECHE'then 'CAM'
when  d_estado= 'CHIAPAS'then 'CHS'
when  d_estado= 'CHIHUAHUA'then 'CHI'
when  d_estado= 'COAHUILA DE ZARAGOZA'then 'COA'
when  d_estado= 'COLIMA'then 'COL'
when  d_estado= 'CIUDAD DE MEXICO'then 'CDMX'
when  d_estado= 'DURANGO'then 'DGO'
when  d_estado= 'GUERRERO'then 'GRO'
when  d_estado= 'GUANAJUATO'then 'GTO'
when  d_estado= 'HIDALGO'then 'HGO'
when  d_estado= 'JALISCO'then 'JAL'
when  d_estado= 'MICHOACAN DE OCAMPO'then 'MICH'
when  d_estado= 'MORELOS'then 'MOR'
when  d_estado= 'NAYARIT'then 'NAY'
when  d_estado= 'NUEVO LEON'then 'NL'
when  d_estado= 'OAXACA'then 'OAX'
when  d_estado= 'PUEBLA'then 'PUE'
when  d_estado= 'QUERETARO'then 'QRO'
when  d_estado= 'QUINTANA ROO'then 'QR'
when  d_estado= 'SAN LUIS POTOSI'then 'SLP'
when  d_estado= 'SINALOA'then 'SIN'
when  d_estado= 'SONORA'then 'SON'
when  d_estado= 'TABASCO'then 'TAB'
when  d_estado= 'TAMAULIPAS'then 'TAM'
when  d_estado= 'TLAXCALA'then 'TLAX'
when  d_estado= 'VERACRUZ DE IGNACIO DE LA LLAVE'then 'VER'
when  d_estado= 'YUCATAN'then 'YUC'
when  d_estado= 'ZACATECAS'then 'ZAC'
when  d_estado= 'MEXICO'then 'EM'
ELSE '' END estado_abrev FROM bdinteg:si_catsepomex into temp sepomex with no log;



select distinct(d_estado),estado_abrev,c_estado from sepomex
into temp estados_sepomex with no log;

/*CREATE INDEX idx_sepomex ON sepomex(d_codigo,d_mnpio,estado_abrev) in dbs_movhis_idx5 online;
CREATE INDEX idx_sepomex1 ON sepomex(d_mnpio,estado_abrev) in dbs_movhis_idx5 online;
CREATE INDEX idx_sepomex2 ON sepomex(d_asenta,estado_abrev) in dbs_movhis_idx5 online;*/

CREATE INDEX idx_sepomex3 ON sepomex(d_codigo,estado_abrev); -- in dbs_movhis_idx5 online;
CREATE INDEX idx_sepomex ON sepomex(d_codigo,d_mnpio,estado_abrev,d_asenta);



UPDATE STATISTICS MEDIUM FOR TABLE sepomex;

LET itempsepomex    = 1;

   let vfecha_ini = mdy(month(vfecha_hoy),1,year(vfecha_hoy));
   let vfecha_fin_mes_ant = date(vfecha_ini - 1 units day);

   let vano = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vano;
   let dt_fecha_reporte = vmes || "/" || vdia || "/" || vano;
   --- Genera registro encabezado
   let vlongitud = 0;
   let vnumreg = 1;
   let vnumreg_bc = 1;
   let vreg_proc = 0;
   let vtot_proc = 0;
   let contador_stat = 0;
   let actualiza_esta = 0;

    LET itempcredito    = 1;

    LET tb_nombre_otorg = vnombre_usu;
    LET tb_domicilio_dev = 'INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.';

    
	--IF  (select count(*) from bdiburo:br_burofisicas where numreg = 1 and  substr(registro,35,8) matches vfecha_reporte) = 0 THEN
	select count(*) into iCuenta_regs
	from bdiburo:br_burofisicas where numreg = 1 and  substr(registro,35,8) matches vfecha_reporte;
	
	let strpista = 'antes de borrar los indeces';
	IF iCuenta_regs = 0 THEN
        --truncate table "informix".br_burofisicas_describe;  -- Ya No es necesario truncar por que preexistira informacion RQI 21 220 MACF
        truncate table "informix".br_burofisicas;
        truncate table "informix".br_burofisicas_concilia;
        

        --DROP INDEX "informix".idx_br_burofisicas_describe;  -- Ya No es necesario eliminar indice por que preexistira informacion RQI 21 220 MACF
        --   --DROP INDEX "informix".inxburoconcilia;
		IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_br_burofisicas' 
				AND tabid = (SELECT tabid 
								FROM systables WHERE tabname = 'br_burofisicas'))
		THEN
			DROP INDEX "informix".idx_br_burofisicas; 
	    END IF;

        IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_br_burofisicas_describe_numtarj' 
				AND tabid = (SELECT tabid 
								FROM systables WHERE tabname = 'br_burofisicas_describe'))
								
		THEN
		   DROP INDEX "informix".idx_br_burofisicas_describe_numtarj;
		END IF;		 
--- Genera registro encabezado para Circulo
       let vheader = vencabezado1||vversion||vclave_usu||vnombre_usu||vciclo||vfecha_reporte||vuso_futuro||rpad(trim(vinf_adicional),98,"&");

       insert into bdiburo:br_burofisicas values(vnumreg,vheader);    

    END IF;

	let strpista = 'despues de borrar los indeces';
    UPDATE STATISTICS medium FOR TABLE "informix".br_burofisicas_base;
    UPDATE STATISTICS medium FOR TABLE "informix".br_burofisicas;
    UPDATE STATISTICS medium FOR TABLE "informix".br_burofisicas_describe;  --Ya NO actualizar estadisticas RQI 21 220
    --UPDATE STATISTICS medium for table "informix".br_burofisicas_concilia;

	let strpista = 'antes de del if';

	IF iCuenta_regs = 0 and vindicador_exec = 0 THEN
	
		-- RQM 09 459 Condonaciones y Quitas
		SELECT  a.numcte, a.num_producto,a.num_credito, a.indicador_proceso,a.fecha_status, max(fecha_insert) fecha_insert
		FROM bdicred:sd_bitacora_quitacondonacion a
		WHERE a.indicador_proceso = 'Q' AND a.estatus_proceso = 'FI'
		AND a.fecha_status BETWEEN vfecha_ini AND vfecha_hoy
		AND a.num_producto IN ('6001','6011','8100','8500') group by 1,2,3,4,5
		INTO TEMP cred_bqc_tdc WITH NO LOG;

		SELECT  b.numcte, b.num_producto, a.credito_externo, a.num_credito, a.status_cred, a.fecha_apertura, a.campo_trab3, a.plazo, indicador_proceso
		 FROM bdicred:sd_maecred a 
		 INNER JOIN cred_bqc_tdc b ON a.num_credito = b.num_credito AND b.fecha_status BETWEEN vfecha_ini AND vfecha_hoy
		 where a.status_cred IN ('FF','FI')
		union all
		SELECT  b.numcte, b.num_producto, a.credito_externo, a.num_credito, a.status_cred, a.fecha_apertura, a.campo_trab3, a.plazo, indicador_proceso
		 FROM bdicred:sd_maecredcrd a 
		 INNER JOIN cred_bqc_tdc b ON a.num_credito = b.num_credito AND b.fecha_status BETWEEN vfecha_ini AND vfecha_hoy
		 WHERE a.num_producto = '6011' and a.status_cred IN ('FF','FI')
  		INTO temp creditos WITH NO LOG;	

	
		--Se crea tabla temporal con los creditos a procesar TDC
		SELECT c.numcte, c.num_producto, c.credito_externo,c.num_credito,c.status_cred, mae.fecha_apertura,c.campo_trab3, 0 as plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcont c
		  INNER JOIN bdicred:sd_maecred mae on mae.empresa=c.empresa and mae.num_credito=c.num_credito and mae.fecha_apertura <= vfecha_hoy
		  WHERE c.empresa = "001"
		  AND c.fecha = vfecha_hoy 
		  and c.status_cred in ('AA','BA','BT','E1','E2','E3')
		  --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe)
		  --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
          --AND c.num_credito in(select num_credito from ctas_hallazgos)
		 AND c.num_credito NOT IN(SELECT num_credito FROM creditos)
		  UNION ALL
		SELECT  c.numcte, c.num_producto, mae.credito_externo,c.num_credito,mae.status_cred, mae.fecha_apertura,c.campo_trab3, 0 as plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcont c
		  INNER JOIN bdicred:sd_maecred mae on mae.empresa=c.empresa and mae.num_credito=c.num_credito
		  WHERE c.empresa = "001"
		  AND c.fecha = vfecha_fin_mes_ant 
		  and c.status_cred in ('AA','BA','BT','E1','E2','E3')
		  --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe)
		  --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
		  and c.num_credito not in (select num_credito from bdicred:sd_maecredcont WHERE empresa = '001' and fecha = vfecha_hoy)
		  AND c.num_credito NOT IN(SELECT num_credito FROM creditos)
		 INTO temp temp_creditos2 WITH NO LOG;

		
		insert into creditos
		select numcte, num_producto, credito_externo, num_credito, status_cred, fecha_apertura, campo_trab3, plazo, indicador_proceso from temp_creditos2;


	--Se anexa a tabla temporal con los creditos a procesar REESTRUCTURAS
	  	INSERT INTO creditos
		SELECT  c.numcte, c.num_producto, c.credito_externo,c.num_credito,c.status_cred, c.fecha_apertura,c.campo_trab3, c.plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcontcrd c
		 WHERE c.empresa = "001"
		   --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe)
		   --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
		   AND c.fecha = vfecha_hoy 
		   AND c.num_producto = '6011'
		   AND c.num_credito NOT IN(SELECT num_credito FROM creditos);
		   
		INSERT INTO creditos
		SELECT  c.numcte, c.num_producto, c.credito_externo,c.num_credito,mae.status_cred, mae.fecha_apertura,c.campo_trab3, mae.plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcontcrd c
		  INNER JOIN bdicred:sd_maecredcrd mae on mae.empresa=c.empresa and mae.num_credito=c.num_credito
		 WHERE c.empresa = "001"
		   --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe)
		   --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
		   and c.num_credito not in (select num_credito from bdicred:sd_maecredcontcrd WHERE empresa = '001' and fecha = vfecha_hoy and num_producto = '6011')
		   AND c.fecha = vfecha_fin_mes_ant 
		   AND c.num_producto = '6011'
		   AND c.num_credito NOT IN(SELECT num_credito FROM creditos);

	--IPCB 06082014/Integra Cancelaciones aperturadas el mismo mes.
		INSERT INTO creditos
		SELECT  a.numcte, a.num_producto,  '' credito_externo,b.num_credito, a.status_cred, a.fecha_apertura,a.campo_trab3, 0 as plazo, '' indicador_proceso
		  FROM bdicred:sd_maecred a inner join bdicred:sd_cred_can b
			ON a.num_credito = b.num_credito  AND b.fecha_can BETWEEN vfecha_ini AND vfecha_hoy  AND b.folio_cancelacion <>''
		 WHERE a.status_cred IN ('FF','FI')
		   AND a.fecha_apertura BETWEEN  vfecha_ini AND vfecha_hoy
		   AND a.num_credito NOT IN(SELECT num_credito FROM creditos);
		   --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe)
		   --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia);
		   

		INSERT INTO creditos	   
		SELECT  a.numcte, a.num_producto,  '' credito_externo,a.num_credito, status_cred, fecha_apertura,a.campo_trab3, a.plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcrd a INNER JOIN bdicred:sd_maecredanexocrd b
			ON b.empresa = a.empresa AND a.num_credito = b.num_credito AND b.fecha_proceso BETWEEN vfecha_ini AND vfecha_hoy
		 WHERE a.empresa = '001'
		   --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe)
		   --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
		   AND a.status_cred IN ('FF','FI')
		   AND a.num_producto = '6011'
		   AND a.fecha_apertura BETWEEN vfecha_ini AND vfecha_hoy
		   AND a.num_credito NOT IN(SELECT num_credito FROM creditos);
		CREATE INDEX idx_creditos ON creditos(status_cred,num_credito,credito_externo,num_producto,numcte);
		update statistics medium for table creditos;

		BEGIN; -- JAHJ
			UPDATE bdiburo:br_param
				SET valor = '1'
				WHERE cod_param = 170;
		COMMIT;

	ELSE
	
			let strpista = 'iniciamos el else';

	-- RQM 09 459 Condonaciones y Quitas
		SELECT  a.numcte, a.num_producto,a.num_credito, a.indicador_proceso,a.fecha_status, max(fecha_insert) fecha_insert
		FROM bdicred:sd_bitacora_quitacondonacion a
		WHERE a.indicador_proceso = 'Q' AND a.estatus_proceso = 'FI'
		AND a.fecha_status BETWEEN vfecha_ini AND vfecha_hoy
		AND a.num_producto IN ('6001','6011','8100','8500') group by 1,2,3,4,5
		INTO TEMP cred_bqc_tdc WITH NO LOG;



		SELECT  b.numcte, b.num_producto, a.credito_externo, a.num_credito, a.status_cred, a.fecha_apertura, a.campo_trab3, a.plazo, indicador_proceso
		 FROM bdicred:sd_maecred a 
		 INNER JOIN cred_bqc_tdc b ON a.num_credito = b.num_credito AND b.fecha_status BETWEEN vfecha_ini AND vfecha_hoy
		 where a.status_cred IN ('FF','FI') 
		union all
		SELECT  b.numcte, b.num_producto, a.credito_externo, a.num_credito, a.status_cred, a.fecha_apertura, a.campo_trab3, a.plazo, indicador_proceso
		 FROM bdicred:sd_maecredcrd a 
		 INNER JOIN cred_bqc_tdc b ON a.num_credito = b.num_credito AND b.fecha_status BETWEEN vfecha_ini AND vfecha_hoy
		 WHERE a.num_producto = '6011' and a.status_cred IN ('FF','FI') 
		INTO temp creditos WITH NO LOG;
	
	--Se crea tabla temporal con los creditos a procesar TDC
		SELECT  c.numcte, c.num_producto, c.credito_externo,c.num_credito,c.status_cred, mae.fecha_apertura,c.campo_trab3, 0 as plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcont c
		  INNER JOIN bdicred:sd_maecred mae on mae.empresa=c.empresa and mae.num_credito=c.num_credito and mae.fecha_apertura <= vfecha_hoy
		  WHERE c.empresa = "001" 
		  AND c.fecha = vfecha_hoy 
		  --and c.status_cred in ('AA','BA','BT')
		  AND c.status_cred in ('AA','BA','BT','E1','E2','E3')
          AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe where fecha_reporte = vfecha_reporte)  -- RQI 21 220 MACF
		  --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
		  AND c.num_credito NOT IN(SELECT num_credito FROM creditos)
		UNION ALL
		SELECT  c.numcte, c.num_producto, mae.credito_externo,c.num_credito,mae.status_cred, mae.fecha_apertura,c.campo_trab3, 0 as plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcont c
		  INNER JOIN bdicred:sd_maecred mae on mae.empresa=c.empresa and mae.num_credito=c.num_credito
		  WHERE c.empresa = "001"
		  AND c.fecha = vfecha_fin_mes_ant 
		  --and c.status_cred in ('AA','BA','BT')
		  AND c.status_cred in ('AA','BA','BT','E1','E2','E3') 
		  AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe where fecha_reporte = vfecha_reporte)  -- RQI 21 220 MACF 
          --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
		  and c.num_credito not in (select num_credito from bdicred:sd_maecredcont WHERE empresa = '001' and fecha = vfecha_hoy)
		  AND c.num_credito NOT IN(SELECT num_credito FROM creditos)
   		INTO temp temp_creditos2 WITH NO LOG;

		
		insert into creditos
		select numcte, num_producto, credito_externo, num_credito, status_cred, fecha_apertura, campo_trab3, plazo, indicador_proceso from temp_creditos2;


	--Se anexa a tabla temporal con los creditos a procesar REESTRUCTURAS
		INSERT INTO creditos
		SELECT  c.numcte, c.num_producto, c.credito_externo,c.num_credito,c.status_cred, c.fecha_apertura,c.campo_trab3, c.plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcontcrd c
		 WHERE c.empresa = "001"
           AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe where fecha_reporte = vfecha_reporte)  -- RQI 21 220 MACF
		   --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
		   AND c.fecha = vfecha_hoy 
		   AND c.num_producto = '6011' 
		   AND c.num_credito NOT IN(SELECT num_credito FROM creditos);
		   
		INSERT INTO creditos
		SELECT  c.numcte, c.num_producto, c.credito_externo,c.num_credito,mae.status_cred, mae.fecha_apertura,c.campo_trab3, mae.plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcontcrd c
		  INNER JOIN bdicred:sd_maecredcrd mae on mae.empresa=c.empresa and mae.num_credito=c.num_credito
		 WHERE c.empresa = "001"
           AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe where fecha_reporte = vfecha_reporte)  -- RQI 21 220 MACF
		   --AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
		   and c.num_credito not in (select num_credito from bdicred:sd_maecredcontcrd WHERE empresa = '001' and fecha = vfecha_hoy and num_producto = '6011')
		   AND c.fecha = vfecha_fin_mes_ant 
		   AND c.num_producto = '6011' 
		   AND c.num_credito NOT IN(SELECT num_credito FROM creditos);

	--IPCB 06082014/Integra Cancelaciones aperturadas el mismo mes.
		INSERT INTO creditos
		SELECT  a.numcte, a.num_producto,  '' credito_externo,b.num_credito, a.status_cred, a.fecha_apertura,a.campo_trab3, 0 as plazo, '' indicador_proceso
		  FROM bdicred:sd_maecred a inner join bdicred:sd_cred_can b
			ON a.num_credito = b.num_credito  AND b.fecha_can BETWEEN vfecha_ini AND vfecha_hoy  AND b.folio_cancelacion <>''
		 WHERE a.status_cred IN ('FF','FI')
		   AND a.fecha_apertura BETWEEN  vfecha_ini AND vfecha_hoy 
           AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe where fecha_reporte = vfecha_reporte) -- RQI 21 220 MACF
		   AND a.num_credito NOT IN(SELECT num_credito FROM creditos);
		   --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia);		   

		INSERT INTO creditos	   
		SELECT  a.numcte, a.num_producto,  '' credito_externo,a.num_credito, status_cred, fecha_apertura,a.campo_trab3, a.plazo, '' indicador_proceso
		  FROM bdicred:sd_maecredcrd a INNER JOIN bdicred:sd_maecredanexocrd b
			ON b.empresa = a.empresa AND a.num_credito = b.num_credito AND b.fecha_proceso BETWEEN vfecha_ini AND vfecha_hoy
		 WHERE a.empresa = '001'
           AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe where fecha_reporte = vfecha_reporte)  -- RQI 21 220 MACF
		   --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia)
		   AND a.status_cred IN ('FF','FI')
		   AND a.num_producto = '6011'
		   AND a.fecha_apertura BETWEEN vfecha_ini AND vfecha_hoy 
		   AND a.num_credito NOT IN(SELECT num_credito FROM creditos);
	   
--		CREATE INDEX idx_creditos ON creditos(status_cred,num_credito,credito_externo,num_producto,numcte);
		CREATE INDEX idx_creditos ON creditos(num_credito);
		update statistics medium for table creditos;
		
		BEGIN; -- JAHJ
			UPDATE bdiburo:br_param
				SET valor = '1'
				WHERE cod_param = 170;
		COMMIT;
		
		let strpista = 'terminamos el else';

	END IF;
	
    IF (select count(*) from bdiburo:br_burofisicas) = 1 THEN
        select count(*)::integer into iTotalProcesados from creditos;
        --INSERT INTO bdiburo:br_burofisicas_concilia (empresa, num_producto, num_credito, motivo, fecha_cinta,int_calculo) VALUES('001',cNumProducto,vnum_credito,'TCP',vfecha_hoy,iTotalProcesados);
    END IF;
   
   
    select max(numreg) into vnumreg
    from bdiburo:br_burofisicas where numreg > 0;


-- crea temporal pago de reestructuras -- reemplazar con indicadores de credito
    select num_credito, max(fecha_mov) fecha_mov
    from bdicred:sd_movhiscrd 
    /*where empresa = '001'
      and num_credito matches '61*'
      and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd)
      and codigo_ref = 1
      and reversado = 'N'
      and fecha_mov <= vfecha_hoy*/
  	  where empresa = '001' and fecha_mov <= vfecha_hoy                        
	  and num_credito >= ''
	  --and num_credito in (select num_credito from creditos where num_producto = '6011')
      and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd where num_producto = '6011')
      and codigo_ref = 1
      and reversado = 'N'
      and num_producto = '6011'
    group by num_credito
    into temp MovtosCred with no log;
	
    create unique index indx_mov on MovtosCred(num_credito);
    update statistics medium for table MovtosCred;
                           

	select valor 
	 into iEjecucion_primera_vez
	 from bdiburo:br_param where cod_param = 15;
	
		let strpista = 'antes del foreach';

	
    foreach with hold
        select  numcte, num_producto, credito_externo, num_credito, status_cred, fecha_apertura,campo_trab3, plazo, indicador_proceso
          into vnumcte,cNumProducto, cCredExterno,vnum_credito,vstatus_cred, vfecha_apertura,vidbaja, cplazo_meses, vIndicaQuita
          from creditos 
		  where num_credito not in ('700000000021','700000000013','700000000039') --Exclusion RQI 21 052  P-SIF-CRE-20150224-05
				 
        LET cNumCredito = vnum_credito;
        LET cCredExterno_bis = cCredExterno;

         IF (sCommit = 0) THEN
            BEGIN WORK;
            LET contador_commit = 0;
            LET sCommit = -1;
         END IF; 

    -- Inicializa variables
    -- Segmento PN
         let tb_apell_paterno = "";
         let tb_apell_materno = "";
         let tb_nombre1       = "";
         let tb_nombre2       = "";
         let tb_fecha_nac     = "";
         let tb_rfc           = "";
         let tb_nacionalidad  = "";
         let tb_estado_civil  = "";
         let tb_sexo          = "";

    -- Segmento PA
         let tb_calle         = "";
         let tb_colonia       = "";
         let tb_delegacion    = "";
         let tb_ciudad        = "";
         let tb_estado        = "";
         let tb_cod_postal    = "";
         let vcredito_maximo  = 0.0;

    -- Segmento TL
         let tb_clave_usu         = "";
         let tb_nombre_usu        = "";
         let tb_num_credito       = "";
         let tb_num_credito_ext   = ""; --IPCB Marzo2015
         let tb_responsabilidad   = "";
         let tb_tipo_cuenta       = "";
         let tb_tipo_producto     = "";
         let tb_clave_monetaria   = "";
         let tb_num_pagos         = "";
         let tb_frecpago          = "";
         let tb_monto_pagar       = 0.0;
         let tb_fecha_apertura      = "";
         let tb_fecha_ult_pago    = "";
         let tb_fecha_ult_compra  = "";
         let tb_fecha_cierre      = "";
         let tb_fecha_reporte     = "";
         let tb_credito_maximo    = 0.0;
         let tb_saldo_actual      = 0.0;
         let tb_monto_otorgado    = 0.0;
         let tb_saldo_venc        = 0.0;
         let tb_cuotas_ven        = 0;
         let tb_mop               = "";
         let tb_clave_obs         = "";
         let vlMnpioReportar      = '';
         let vlCodigoReportar     ='';
         let vlCodigoPOstalZona   ='';
		 let vlCodigoPOstalZona_2   ='';
         let tb_fecha_vencimiento = "";
         let tb_monto_insoluto    = 0.0;
         let tb_ultimo_pago       = 0.0;

         let vrea_cal_cuota = 0;

    -- NUEVOS CAMPOS 12
         LET vfecha_vencido = date(1);
         LET vmontolutpago = 0;

         LET vsegmento_pn = "";
         LET vsegmento2_pa = "";
         LET vsegmento3_tl = "";
		 
    -- Segmento PE
         LET tb_nombre_empleador 	= "";
         LET tb_origen_razon_soc 	= "";
         LET tb_calle_pe 			= "";
         LET tb_colonia_pe 			= "";
         LET tb_delegacion_pe 		= ""; 
         LET tb_ciudad_pe 			= "";
         LET tb_estado_pe 			= "";
         LET tb_cod_postal_pe 		= "";
         LET tb_fingcartvenc 		= "";
         LET tb_diasatraso 			= 0;	 

		 LET vlCodigoPOstalZona_pe  = '';
		 LET vlCodigoPOstalZona_pe_2 = '';
		 
		 LET vfac_pagmin         = 0; --IPCB 10Nov20
         LET vmto_pago_min       = 0; --IPCB 10Nov20
         LET vv_frep_fuc         = 0; --IPCB 10Nov20
         LET vv_frep_fup         = 0; --IPCB 10Nov20
         LET vv_frep_fap         = 0; --IPCB 10Nov20 
		 
		 LET vIndProceso		 = ''; -- RQM 09 459
		 
		 -- RQM 09 502
		 if cNumProducto in('6001','6600','7000','8100','8500','5400') then
		    select a.num_tarjeta, a.status_tar
              into vnum_tarjeta, cStatus_tar		 
		      from bdicred:sd_tarjeta a
             where a.empresa = '001' and a.num_credito = vnum_credito
               and a.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where empresa = '001'
                                  and num_credito = a.num_credito and tipo_tarjeta = 'T');
            
			 
		 end if;
		 
		-- RQM 09 459 Condonaciones y Quitas
		-- SI ES QUITA
		IF vIndicaQuita = 'Q' THEN
			-- TARJETA CLASICA, TARJETA ORO
			IF cNumProducto IN('6001','8100') THEN
				SELECT a.indicador_proceso, a.mto_quita, b.fecha_proceso, max(fecha_insert) fecha_insert
					INTO vIndProceso, vMontoQuita, vFechaLiquida, vFechInsrt
				FROM bdicred:sd_bitacora_quitacondonacion a
				INNER JOIN bdicred:sd_maecredanexo b ON a.num_credito=b.num_credito
				INNER JOIN bdicred:sd_maecred c ON c.num_credito = a.num_credito
				WHERE a.fecha_status BETWEEN vfecha_ini AND vfecha_hoy
				AND a.num_credito = vnum_credito
				AND a.indicador_proceso = 'Q'
				AND a.estatus_proceso = 'FI'
				AND c.status_cred IN ('FF','FI')
				group by 1,2,3;
			-- REESTRUCTURA DE TDC
			ELIF cNumProducto IN('6011') THEN
				SELECT a.indicador_proceso, a.mto_quita, b.fecha_proceso, max(fecha_insert) fecha_insert
					INTO vIndProceso, vMontoQuita, vFechaLiquida, vFechInsrt
				FROM bdicred:sd_bitacora_quitacondonacion a
				INNER JOIN bdicred:sd_maecredanexocrd b ON a.num_credito=b.num_credito
				INNER JOIN bdicred:sd_maecredcrd c ON c.num_credito = a.num_credito
				WHERE a.fecha_status BETWEEN vfecha_ini AND vfecha_hoy
				AND a.num_credito = vnum_credito
				AND a.indicador_proceso = 'Q'
				AND a.estatus_proceso = 'FI'
				AND c.status_cred IN ('FF','FI')
				group by 1,2,3;
			END IF;
		END IF;
			
		let strpista = 'foreach 1';

/*
		 --- Buscar cual tarjeta se envio con anterioridad a Buro
		 -- Si es primer envio se guardara la tarjeta en la nueva tabla br_bitacora_tarjeta
		 if iEjecucion_primera_vez = '1' then
			   insert into bdiburo:br_bitacora_tarjeta(num_credito, num_tarjeta, numcte)
			   values(vnum_credito,vnum_tarjeta,vnumcte);
			   
		 elif nvl(vnum_tarjeta,'') <> '' then -- Si tiene tarjeta y NO es primer envio revisar si vnum_tarjeta es igual a v_num_tarjeta_anterior (enviada antes)  
	 
		     select num_tarjeta
			   into vnum_tarjeta_ant
			   from bdiburo:br_bitacora_tarjeta
			   where num_credito = vnum_credito;

		     if vnum_tarjeta <> vnum_tarjeta_ant then
				  let cTarjetaCambiada = 'S';
				  let tb_num_tarjeta_ant = vnum_tarjeta_ant;
			 end if;
	     else
		     let vnum_tarjeta = '0000000000000000'; 
		 end if;
*/

		 if iEjecucion_primera_vez = '1' then
			   insert into bdiburo:br_bitacora_tarjeta(num_credito, num_tarjeta, numcte)
			   values(vnum_credito,vnum_tarjeta,vnumcte);
			   
		-----------   CODIGO  NUEVO
		
		elif nvl(vnum_tarjeta,'') <> '' then
		
		    select num_tarjeta
		  	  into vnum_tarjeta_ant
		      from bdiburo:br_bitacora_tarjeta
			 where num_credito = vnum_credito;
		
		   if vfecha_apertura < vfecha_ini then

			  if (nvl(vnum_tarjeta_ant,'') <> '') AND (vnum_tarjeta <> vnum_tarjeta_ant) then
			 
				    let cTarjetaCambiada = 'S';
				    let tb_num_tarjeta_ant = vnum_tarjeta_ant;
			 
			  end if;
		
		     -- No existia en la cinta del mes anterior, 
		   elif nvl(vnum_tarjeta_ant,'') = '' then
			      -- Se inserta y no hay reemplazo
			      INSERT INTO bdiburo:br_bitacora_tarjeta(num_credito, num_tarjeta, numcte, cambio,fecha_insert,fecha_upd)
			      VALUES(vnum_credito, vnum_tarjeta, vnumcte, '',vfecha_hoy,NULL);
		    
		   end if;
		
		else
		     let vnum_tarjeta = '0000000000000000'; 
		end if;

		--- RQM 09 502 MACF - Si tarjeta cambio, obtener la causa del cambio dependiendo de ello se informa clave de observacion
		if cNumProducto in('6001','6600','7000','8100','8500','5400') then
		   if iEjecucion_primera_vez <> '1' then
			
			if cTarjetaCambiada = 'S' then
			   -- buscar la tarjeta en intercard:bitacoracambiosstatustarjeta y validar si fue por EXT o ROB
				select a.codstatustarjetanvo into vCodstatus_tarjetanvo
   				  from intercard:bitacoracambiosstatustarjeta a 
				 where a.tarjeta = vnum_tarjeta_ant
                   and a.fechahora = (select max(fechahora) 
				                        from intercard:bitacoracambiosstatustarjeta where tarjeta = a.tarjeta);
				
                if vCodstatus_tarjetanvo is null then let vCodstatus_tarjetanvo = ''; end if;
				
                if vCodstatus_tarjetanvo in('EXT','ROB') then
				   let vClaveObserv_tarjeta = 'LS';
				else   
				   let vClaveObserv_tarjeta = '';
				end if;
			end if;
			
		   end if;	
        end if;
		--- RQM 09 502 MACF
		let strpista = 'foreach 2';

	
   -- RQI 21 220 MACF
   IF vfecha_apertura >= vfecha_ini THEN
      LET cArma_PN = 'S';   
   ELSE
   
     SELECT nvl(estado_civil,''), nvl(profesion,'')
	   INTO vestado_civil, vprofesion
	   FROM bdinteg:si_ctepf
	  WHERE numcte=vnumcte;
   
      --LET vestado_civil = NVL(vestado_civil,'');
	  
      SELECT estado_civil INTO vestado_civil_prev
	   FROM  bdiburo:br_burofisicas_describe
	   WHERE num_credito = vnum_credito;
	   
	   LET vestado_civil_prev = NVL(vestado_civil_prev,'');
	   
	   let strpista = 'foreach 3';

      IF TRIM(vestado_civil) <> TRIM(vestado_civil_prev) THEN
         let tb_estado_civil  = vestado_civil;
		 LET cCambio_estado_civil = 'S';
	  ELSE
	     -- Si no cambio deja el que tenia anteriormente
		 let tb_estado_civil  = vestado_civil_prev;
		 LET cCambio_estado_civil = 'N';
      END IF;
	  
	  IF cCambio_estado_civil = 'N' THEN
         SELECT first 1 registro INTO vsegmento_pn_base_t
	       FROM br_burofisicas_base
	      WHERE num_credito = vnum_credito
	      AND tipo_segmento='PN';
	   
         LET vsegmento_pn_base = NVL(vsegmento_pn_base_t,'');
	     LET cArma_PN = 'N';
		 
		  IF vClaveObserv_tarjeta = 'LS' then 
			  --consulta br_burofisicas_describe
			 SELECT first 1 apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, rfc, nacionalidad, sexo
			   INTO tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_sexo
			  FROM bdiburo:br_burofisicas_describe
			  WHERE num_credito = vnum_credito;
		  END IF; 
		 
	  ELSE
	     LET cArma_PN = 'S';
	  END IF;
	     
	  
   END IF;
   
   -- RQI 21 220 MACF
   IF cArma_PN = 'S' OR (vsegmento_pn_base = '' OR vsegmento_pn_base is null) THEN
	  LET cArma_PN = 'S';

				let strpista = 'foreach 4 PN';

-- INICIO SEGMENTO PN (Nombre)
        select a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, b.fecha_nac, a.rfc, a.fecha_alta, b.nacionalidad, a.residencia,
             /*REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(apell_paterno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(apell_materno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(nombre1),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(nombre2),""),'1','L'),'0','O'),'5','S'),'8','B'),
             fecha_nac,trim(rfc),nvl(fecha_alta,""),nvl(nacionalidad,"01"),nvl(residencia,"MX"),
             nvl(estado_civil," "),nvl(sexo,"I"), trim(b.profesion)*/
			 b.estado_civil, b.sexo, b.profesion
         into vapell_paterno,vapell_materno,vnombre1,vnombre2,vfecha_nac,vrfc,vfecha_alta,vnacionalidad,vresidencia,
             vestado_civil,vsexo, vprofesion
         from bdinteg:si_cliente a,
              bdinteg:si_ctepf b
         where a.numcte=b.numcte
           and a.numcte=vnumcte;
		
		 LET vapell_paterno = REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(vapell_paterno),""),'1','L'),'0','O'),'5','S'),'8','B');
		 LET vapell_materno = REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(vapell_materno),""),'1','L'),'0','O'),'5','S'),'8','B');
		 LET vnombre1 = REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(vnombre1),""),'1','L'),'0','O'),'5','S'),'8','B');
		 LET vnombre2 = REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(vnombre2),""),'1','L'),'0','O'),'5','S'),'8','B');
		 LET vrfc = trim(vrfc);
		 LET vfecha_alta = nvl(vfecha_alta,"");
		 LET vnacionalidad = nvl(vnacionalidad,"01");
		 LET vresidencia = nvl(vresidencia,"MX");
		 LET vestado_civil = nvl(vestado_civil," ");
		 LET vsexo = nvl(vsexo,"I");
		 LET vprofesion = trim(vprofesion);
		
         if vapell_paterno = "X X" then
            let vapell_paterno = "XX";
         end if;

         if vapell_materno = "X X" then
                 let vapell_materno = "XX";
         end if;

         if vnombre1 = "-" then
             let vnombre1 = vnombre2;
             let vnombre2 = "";
         end if;

         let vano = year(vfecha_nac);
         let vmes = lpad(month(vfecha_nac),2,"0");
         let vdia = lpad(day(vfecha_nac),2,"0");

    -- Agrega Apellido Paterno
         let vsegmento1_pn = lpad(length(trim(vapell_paterno)),2,"0")||
                               trim(vapell_paterno);
         let tb_apell_paterno = trim(vapell_paterno);


    -- Agrega Apellido Materno
         if vapell_materno is not null and vapell_materno <> '' then
            let vsegmento1_pn = trim(vsegmento1_pn)||'00'||
                                lpad(length(trim(vapell_materno)),2,"0")||trim(vapell_materno);

            let tb_apell_materno = trim(vapell_materno);
         else
            let vsegmento1_pn = trim(vsegmento1_pn)||'0016NO PROPORCIONADO';  --RQM 09 467_Version 14
         end if;

    -- Agrega Primero Nombre
         let vsegmento1_pn = trim(vsegmento1_pn)||'02'||
                             lpad(length(trim(vnombre1)),2,"0")||vnombre1;
         let tb_nombre1       = vnombre1;

    -- Agrega Segundo Nombre
         if vnombre2 is not null then
            let vsegmento1_pn = trim(vsegmento1_pn)||'03'||
                                lpad(length(trim(vnombre2)),2,"0")||vnombre2;
            let tb_nombre2       = vnombre2;
		 else
			let vsegmento1_pn = trim(vsegmento1_pn)||'0300';
         end if;

    -- Agrega Fecha de Nacimiento
         if vfecha_nac is not null then
            let vsegmento1_pn = trim(vsegmento1_pn)||'0408'||vdia||vmes||vano;
            let tb_fecha_nac     = vdia||vmes||vano;
         end if;

    -- Agrega RFC
         if vfecha_nac is null then let vrfc = "";  end if;

         let existe = length(vrfc);
         let existe1 = 0;
         let vquita = "";
         while existe1 < existe
          if vrfc[1,1]="~" or vrfc[1,1]=" " then
          else
             let vquita = trim(vquita)||vrfc[1,1];
          end if;
          let vrfc = vrfc[2,13];
          let existe1 = existe1 + 1;
         end while;
         let vrfc = trim(vquita);
         let existe = length(vrfc);
         if vrfc is null or existe < 10 then
            if vrfc[2,2] = "A" or vrfc[2,2] = "E" or vrfc[2,2] = "I" or vrfc[2,2] = "O" or vrfc[2,2] = "U" Then
               let vrfc = vapell_paterno[1,2]||vapell_materno[1,1]||vnombre1[1,1]||vano[3,4]||vmes||vdia;
            else
               let vrfc = vapell_paterno[1,1]||vapell_paterno[3,3]||vapell_materno[1,1]||vnombre1[1,1]||vano[3,4]||vmes||vdia;
            end if  
         end if


         let vsegmento1_pn = trim(vsegmento1_pn)||'05'||
                                     lpad(length(trim(vrfc)),2,"0")||vrfc;
         let tb_rfc           = vrfc;
         
    -- Agrega Nacionalidad
         let vsegmento1_pn = trim(vsegmento1_pn)||'0802MX';
         let tb_nacionalidad  = "MX";

    -- Agrega Estado Civil
        if vestado_civil is not null then
            if vestado_civil = 'C' then
               let vsegmento1_pn = trim(vsegmento1_pn)||'1101M';
            end if;
            if vestado_civil = 'S' then
               let vsegmento1_pn = trim(vsegmento1_pn)||'1101S';
            end if;
            if vestado_civil = 'U' then
               let vsegmento1_pn = trim(vsegmento1_pn)||'1101F';
            end if;
            if vestado_civil = 'D' then
               let vsegmento1_pn = trim(vsegmento1_pn)||'1101D';
            end if;
            if vestado_civil = 'V' then
               let vsegmento1_pn = trim(vsegmento1_pn)||'1101W';
            end if;
           let tb_estado_civil  = vestado_civil;
         end if;

    -- Agrega Sexo
         if vsexo is not null then
            let vsegmento1_pn = trim(vsegmento1_pn)||'1201'||vsexo;
            let tb_sexo          = vsexo;
         end if;
         let vsegmento_pn = 'PN'||trim(vsegmento1_pn);

  END IF;

-- INICIO SEGMENTO PA (DIRECCION)
         /* 
         SELECT limit 1 Trim(f.nombrecalle)||' '||Trim(a.numeroextcalle)||' '||
            Trim(a.numerointcalle),
                Trim(g.nombrezona),Trim(g.municipiozona), Trim(c.estado),-- a.cod_postal,
            lpad(trim(a.cod_postal),5,"0"),manzana,andador,lote,edificio,entrada,codini,codfin,
                substr( CodigoPOstalZona,1,5),
                case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' then 1 else 0 end,
                a.pais, a.ciudad
           INTO vcalle,vcolonia,vdelegacion,vestado,vcod_postal,
                vmanzana,vandador,vlote,vedificio,ventrada, vcodini,vcodfin,
                vlCodigoPOstalZona, scalle_conocido, cpais, vclave_ciudad
           FROM bdinteg:si_direcciones_actual as a,--bdinteg:si_ciudades as b,
                bdisolic:ss_circulo_edos as c,bdinteg:si_catcalles f,
            bdinteg:si_catzonas g
          WHERE a.numcte=vnumcte 
            AND a.tipo_dir="1"
            AND c.empresa = "001"
            AND a.estado = c.clave 
            AND a.numerociudad = g.numerociudad 
            AND a.numerocolonia = g.numerocolonia
            AND a.numerocalle = f.numerocalle;
          */    
-- RQI 21 220 MACF		
   IF vfecha_apertura >= vfecha_ini THEN
      LET cArma_PA = 'S';
   ELSE
   
			let strpista = 'foreach PA';

	  SELECT fecha_insert INTO vFecha_insert_dom
	    FROM bdinteg:si_direcciones_actual 
	   WHERE numcte = vnumcte
		 AND tipo_dir = '1';
   
	   LET vFecha_insert_dom = NVL(vFecha_insert_dom,date(1));
	   
	   IF vFecha_insert_dom >= vfecha_ini THEN
          LET cArma_PA = 'S';
	   ELSE  
	   
		  SELECT first 1 registro INTO vsegmento_pa_base_t
		  FROM br_burofisicas_base
		 WHERE num_credito = vnum_credito
		   AND tipo_segmento='PA';
		   
		  LET vsegmento_pa_base = NVL(vsegmento_pa_base_t,'');
		  LET cArma_PA = 'N';
		  
		  IF vClaveObserv_tarjeta = 'LS' THEN 
	      --consulta br_burofisicas_describe
		    SELECT first 1 calle, colonia, delegacion, ciudad, estado, cod_postal, origen_dom
		      INTO tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal, tb_codigo_pais
		      FROM bdiburo:br_burofisicas_describe
		     WHERE num_credito = vnum_credito;
		  END IF;
		  
	    END IF; 
		  
   END IF;
	
	 
	-- RQI 21 220 MACF
	IF cArma_PA = 'S' OR (vsegmento_pa_base = '' OR vsegmento_pa_base is null) THEN  -- DOM ACTUALIZADO DEL CTE (Ini)
	   LET cArma_PA = 'S';
		  
          /*SELECT limit 1 Trim(f.nombrecalle)||' '|| case when nvl(a.numeroextcalle,'') = '' then 'SN' else Trim(a.numeroextcalle) end ||' '||
            Trim(a.numerointcalle),
                nvl(Trim(g.nombrezona),''),nvl(Trim(g.municipiozona),''), Trim(c.estado),-- a.cod_postal,
            lpad(trim(a.cod_postal),5,"0"),manzana,andador,lote,edificio,entrada,codini,codfin,
                nvl(substr( CodigoPOstalZona,1,5),''),
                case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' then 1 else 0 end,
                a.pais, a.ciudad, a.estado*/
		  SELECT limit 1 case when substr(f.nombrecalle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(f.nombrecalle) else trim(f.nombrecalle) end nombrecalle,
		    a.numeroextcalle, a.numerointcalle, g.nombrezona, g.municipiozona, b.estado_abrev, a.cod_postal,
			a.manzana, a.andador, a.lote, a.edificio, a.entrada, c.codini, c.codfin, g.CodigoPOstalZona,
			case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' or f.nombrecalle like '%SIN%NOMBRE%' or f.nombrecalle like '%sin%nombre%' then 1 else 0 end,
			a.pais, a.ciudad, a.estado	
            /*INTO vcalle, vcolonia,vdelegacion,vestado,vcod_postal, 
                 vmanzana,vandador,vlote,vedificio,ventrada, vcodini,vcodfin,
                 vlCodigoPOstalZona, scalle_conocido, cpais, vclave_ciudad, vclave_edo*/
			INTO vnombrecalle, vnumeroextcalle, vnumerointcalle, vcolonia, vdelegacion, vestado, vcod_postal,
				 vmanzana, vandador, vlote, vedificio, ventrada, vcodini, vcodfin,
				 vlCodigoPOstalZona_2, scalle_conocido, cpais, vclave_ciudad, vclave_edo
            FROM bdinteg:si_direcciones_actual a 
            		  left outer join estados_sepomex b on lpad(trim(a.estado),2,"0") = b.c_estado
                      left outer join bdisolic:ss_circulo_edos c on lpad(trim(a.estado),2,"0") = c.clave
                      left outer join bdinteg:si_catzonas g on (a.numerociudad = g.numerociudad and a.numerocolonia = g.numerocolonia)
                      left outer join bdinteg:si_catcalles f on a.numerocalle = f.numerocalle
            WHERE a.numcte= vnumcte
            AND a.tipo_dir="1"
            AND c.empresa = "001";
			
			IF nvl(vnumeroextcalle,'') = '' or nvl(vnumeroextcalle,'') = 'S/N' or nvl(vnumeroextcalle,'') = 'S/n' or nvl(vnumeroextcalle,'') = 's/N' or nvl(vnumeroextcalle,'') = 's/n' or vnumeroextcalle = '0' or vnumeroextcalle = '00' or vnumeroextcalle = '000' or vnumeroextcalle = '0000'  then let vnumeroextcalle = 'SN'; end if;
			IF nvl(vnumerointcalle,'') = '' or nvl(vnumerointcalle,'') = 'S/N' or nvl(vnumerointcalle,'') = 'S/n' or nvl(vnumerointcalle,'') = 's/N' or nvl(vnumerointcalle,'') = 's/n' or vnumerointcalle= '0' or vnumerointcalle= '00' or vnumerointcalle= '000' or vnumerointcalle= '0000' then let vnumerointcalle= 'SN'; end if;

			LET vnumerointcalle = TRIM(vnumerointcalle);
			LET vcalle = trim(vnombrecalle) || ' ' || trim(vnumeroextcalle) || ' ' || vnumerointcalle;
			LET vcolonia = nvl(Trim(vcolonia),'');
			LET vdelegacion = nvl(Trim(vdelegacion),'');
			LET vestado = TRIM(vestado);
			LET vcod_postal = lpad(trim(vcod_postal),5,"0");
			LET vlCodigoPOstalZona = nvl(substr(vlCodigoPOstalZona_2,1,5),'');
			
                
            ---Inicia Bloque de Validaciones Sepomex
            ---Validacion por Codigo POstal del Cliente, Delegacion, Estado
            SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
              FROM sepomex WHERE d_codigo = vcod_postal AND substr(d_mnpio,1,27) = vdelegacion AND estado_abrev = vestado
              group by d_mnpio, d_codigo ;  
            ---Validacion por Delegacion, Estado  
            IF nvl(iCP,0) <= 0 THEN
             SELECT first 1 count(*), d_mnpio, d_codigo INTO iCP, vlMnpioReportar, vlCodigoReportar
              FROM sepomex WHERE  substr(d_mnpio,1,27) = vdelegacion AND estado_abrev = vestado
             group by d_mnpio, d_codigo ;    

            end if;
            ---Validacion por Colonia, Estado  		
            IF nvl(iCP,0) <= 0 THEN
             SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
              FROM sepomex WHERE  trim(substr(d_asenta,1,32)) = vcolonia AND estado_abrev = vestado
              group by d_mnpio, d_codigo ;  

            end if;
            ---Validacion por Codigo POstal de Zona, Estado  		
            IF nvl(iCP,0) <= 0 THEN
             SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
              FROM sepomex WHERE  d_codigo = lpad(vlCodigoPOstalZona,5,"0") AND estado_abrev = vestado
             group by d_mnpio, d_codigo ;   

            end if;
            IF nvl(iCP,0) <= 0 THEN
             SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
              FROM sepomex WHERE  d_codigo = vcod_postal AND estado_abrev = vestado
              group by d_mnpio, d_codigo ;  

            end if;
            ---Validacion por Codigo POstal de Zona, Estado  		
            IF nvl(iCP,0) > 0 THEN
              let vdelegacion =vlMnpioReportar;
              let vcod_postal =vlCodigoReportar;
            END IF;  
           ---Fin de Bloque de Validaciones Sepomex

         let existe = length(vcalle);
           if existe < 40 then
             let vcalle1 = "";
             if vmanzana > 0 then
               let vcalle1 ="mza. "|| vmanzana;
             end if
             if vandador > 0 then
               let vcalle1 =trim(vcalle1)||"and. "||     vandador ; -- AQUI VA vandador??
             end if
             if vlote > 0 then
               let vcalle1 =trim(vcalle1)||"lt. "  ||   vlote ;
             end if
             if vedificio > 0 then
               let vcalle1 =trim(vcalle1)||"ed. "||     vedificio ;
             end if
             if ventrada > 0 then
               let vcalle1 =trim(vcalle1)||"ent. "||     ventrada ;
             end if
           let vcalle = trim(vcalle)||' '||trim(vcalle1);
           end if

         let existe = length(vcalle);
         let existe1 = 0;
         let vquita = "";
         let vespacio = "";
         let hueco = 0;
         while existe1 < existe
           if vcalle[1,1]="~" then
           else
            if vcalle[1,1]="#" and vespacio = "" then
               let vespacio = "F";
            end if
            if vespacio = "F" then
              let vquita = trim(vquita)||" "||vcalle[1,1];
              let vespacio = "";
              let hueco = 1;
            else
              let vquita = trim(vquita)||vcalle[1,1];
            end if;
            if vcalle[1,1]=" " then
               let vespacio = "F";
            end if;
           end if;
           let vcalle = vcalle[2,40];
           let existe1 = existe1 + 1;
         end while;
         let vcalle = trim(vquita);
         if hueco = 0 then
           let vcalle = trim(vquita)||"1";
         end if;
         let vciudad = "";

         if vcod_postal IS NULL then
            let vcod_postal = "00000";
         end if;
   
        
--IPCB Abr15 - Envio de tramas sin direccion, asignacio de blando, para armar la trama
	/*	IF vestado is null or vestado = '' THEN
			LET vcalle = '';
			LET vcolonia = '';
			LET vdelegacion = ''; 
			LET vestado = '';
			LET vcod_postal = '';
			LET vmanzana = '';
			LET vandador = '';
			LET vlote = '';
			LET vedificio = '';
			LET ventrada = '';
			LET vcodini = '';
			LET vcodfin = '';
			LET vlCodigoPOstalZona = '';

			LET bmotivo = 1;
		ELSE 
			LET bmotivo =0;
		END IF;*/

	   IF scalle_conocido = 1 THEN
		   LET vcalle = 'DOMICILIO CONOCIDO SN';
	   END IF;
	       
    -- Agrega Direccion
         let vsegmento2_pa = lpad(length(trim(vcalle)),2,"0")||vcalle;
         let tb_calle         = vcalle;
    -- Agrega Colonia
         if vcolonia is not null then
            let vsegmento2_pa = trim(vsegmento2_pa)||'01'||
                                lpad(length(trim(vcolonia)),2,"0")||vcolonia;
            let tb_colonia       = vcolonia;
		 ELSE
			let vsegmento2_pa = trim(vsegmento2_pa)||'0100'; --RQM 09 467_Version 14
         end if;

    -- Agrega Delegacion o Municipio
         if vdelegacion != "" then       
            let vsegmento2_pa = trim(vsegmento2_pa)||'02'||
                                   lpad(length(trim(vdelegacion)),2,"0")||vdelegacion;
            let tb_delegacion     = vdelegacion;
		 ELIF vdelegacion = "" or vdelegacion is null then
			let vsegmento2_pa = trim(vsegmento2_pa)||'0200'; --RQM 09 467_Version 14
         end if                          

    -- Agrega Ciudad
		--if vdelegacion = '' or vdelegacion is null then
         --estado y ciudad de si_direcciones_actual para con eso consultar el nombre de la ciudad en si_ciudades.
         --SELECT nvl(nombre,'') INTO vciudad
		  SELECT nombre INTO vciudad
           FROM bdinteg:si_ciudades 
          WHERE estado = lpad(trim(vclave_edo),2,"0") 
            AND ciudad = lpad(trim(vclave_ciudad),3,"0"); --vclave_ciudad;       
			
		 LET vciudad = nvl(vciudad,'');	

         if vciudad = '' OR vciudad is null then 
			let vciudad = '';  
			let vsegmento2_pa = trim(vsegmento2_pa)||'0300'; --RQM 09 467_Version 14
         else-- vciudad != ''  then
           let vsegmento2_pa = trim(vsegmento2_pa)||'03'||
                               lpad(length(trim(vciudad)),2,"0")||vciudad;
           let tb_ciudad        = vciudad;
         end if
		--end if
		 
--IPCB Abr2015 -- Para integrar la etiqueta de delegacio vacia al segmento en blanco
	--IF 	vdelegacion = "" and vciudad = ""  THEN
/*	IF (vdelegacion is null or vdelegacion = '') and (vciudad is null or vciudad = '')  THEN
            let vsegmento2_pa = trim(vsegmento2_pa)||'02'||
                                   lpad(length(trim(vdelegacion)),2,"0")||vdelegacion;
            let tb_delegacion     = vdelegacion;
            
            let vsegmento2_pa = trim(vsegmento2_pa)||'03'||
                               lpad(length(trim(vciudad)),2,"0")||vciudad;
            let tb_ciudad        = vciudad;
	END IF;*/

    -- Agrega Estado
         let vsegmento2_pa = trim(vsegmento2_pa)||'04'||
         lpad(length(trim(vestado)),2,"0")||trim(vestado);
         let tb_estado        = trim(vestado);

    -- Agrega Codigo Postal
         let vsegmento2_pa = trim(vsegmento2_pa)||'05'||
         lpad(length(trim(vcod_postal)),2,"0")||trim(vcod_postal);
         let tb_cod_postal    = trim(vcod_postal);

    -- Agregar origen del domicilio (pais) RQM 09 467_Version 14
  		 let vsegmento2_pa = trim(vsegmento2_pa)||'1202MX';
         let tb_codigo_pais  = 'MX';
    
         let vsegmento2_pa = 'PA'||trim(vsegmento2_pa);
  END IF;   -- DOM ACTUALIZADO DEL CTE (Fin)

-- INICIA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14
  --Etiqueta PE -Nombre o Razo Social del empleador 
        --SELECT nvl(a.nombre_empresa,'')

		let strpista = 'foreach 5';

		
		SELECT a.nombre_empresa
          INTO cnombre_empleador
          FROM bdinteg:si_ingresos a
         WHERE a.numcte = vNumcte
           AND a.sec_ingreso = (SELECT max(sec_ingreso)
                                  FROM bdinteg:si_ingresos 
                                 WHERE numcte = a.numcte);
	  
	  LET cnombre_empleador = NVL(cnombre_empleador,'');

     IF cnombre_empleador = '' or cnombre_empleador is null THEN
        IF vprofesion = '06' THEN 
           LET cnombre_empleador = 'DESEMPLEADO';
        ELIF vprofesion = '10' THEN
           LET cnombre_empleador = 'TRABAJADOR INDEPENDIENTE';
        ELIF vprofesion = '12' THEN
           LET cnombre_empleador = 'LABORES DEL HOGAR';
        ELIF vprofesion = '15' THEN
           LET cnombre_empleador = 'ESTUDIANTE';
        ELIF vprofesion = '16' THEN
           LET cnombre_empleador = 'JUBILADO';
        ELSE 
           LET cnombre_empleador = 'TRABAJADOR INDEPENDIENTE';  
        END IF;
	ELSE
        LET iLong_NomEmpleador = LENGTH(cnombre_empleador);
        CALL bdinteg:"informix".sp_esnumerico (cnombre_empleador) RETURNING cEsNumerico;   --RQM 09 599 Hallazgos Banxico 2021 - MACF
		IF cEsNumerico = 'V' THEN
		   LET cnombre_empleador_temp = 'TRABAJADOR INDEPENDIENTE';
		   LET cnombre_empleador = cnombre_empleador_temp;
		ELIF cEsNumerico = 'F' THEN 
		   --IF (iLong_NomEmpleador >= 1 AND iLong_NomEmpleador <= 5) THEN
			   IF iLong_NomEmpleador >= 1 AND iLong_NomEmpleador <= 2 THEN
				  LET cnombre_empleador = 'TRABAJADOR INDEPENDIENTE';
			   ELIF iLong_NomEmpleador = 4 THEN
				  LET cnombre_empleador_temp = REPLACE(nvl(trim(cnombre_empleador),""),'OTRO','TRABAJADOR INDEPENDIENTE');
				  LET cnombre_empleador_temp = REPLACE(nvl(trim(cnombre_empleador_temp),""),'OTRA','TRABAJADOR INDEPENDIENTE');
				  LET cnombre_empleador = cnombre_empleador_temp;
			   ELIF iLong_NomEmpleador = 5 THEN	  
				  LET cnombre_empleador_temp = REPLACE(nvl(trim(cnombre_empleador),""),'OTROS','TRABAJADOR INDEPENDIENTE');
				  LET cnombre_empleador = cnombre_empleador_temp;
			   END IF; 
			   --LET cnombre_empleador = cnombre_empleador_temp;
            --END IF;			
		END IF;  --RQM 09 599 Hallazgos Banxico 2021 - MACF 

    END IF;
	
	let vsegmento_pe = 	lpad(length(trim(cnombre_empleador)),2,"0")  || trim(cnombre_empleador);
	let tb_nombre_empleador = trim(cnombre_empleador);
-- RQI 21 220 MACF
   IF vfecha_apertura >= vfecha_ini THEN
      LET cArma_PE = 'S';
   ELSE
      -- VALIDAR SI DIR. EMPLEO CAMBIO EN EL ULTIMO MES
	  SELECT fecha_insert INTO vFecha_insert_trabajo
	    FROM bdinteg:si_direcciones_actual 
	   WHERE numcte = vnumcte
		 AND tipo_dir = '2';
   
	   LET vFecha_insert_trabajo = NVL(vFecha_insert_trabajo,date(1));
	   
	   IF vFecha_insert_trabajo >= vfecha_ini THEN
          LET cArma_PE = 'S';
	   ELSE  
	     -- VALIDAR LA PROFESION
		 SELECT razon_social INTO vrazon_social_prev
		   FROM br_burofisicas_describe
		   WHERE num_credito = vnum_credito;
		   
		   LET vrazon_social_prev = NVL(vrazon_social_prev,'');
		   
	       IF TRIM(cnombre_empleador) <> TRIM(vrazon_social_prev) THEN
		      LET cArma_PE = 'S';
		   ELSE
   
			 SELECT first 1 registro INTO vsegmento_pe_base_t
			   FROM bdiburo:br_burofisicas_base
			  WHERE num_credito = vnum_credito
				AND tipo_segmento='PE';
			   
			  LET vsegmento_pe_base = NVL(vsegmento_pe_base_t,'');
			  LET cArma_PE = 'N';
			  
			  IF vClaveObserv_tarjeta = 'LS' THEN 
				--consulta br_burofisicas_describe
				SELECT first 1 razon_social, calle_pe, colonia_pe, delegacion_pe, ciudad_pe, estado_pe, cod_postal_pe, origen_razon_soc
				  INTO tb_nombre_empleador, tb_calle_pe, tb_colonia_pe, tb_delegacion_pe, tb_ciudad_pe, tb_estado_pe, tb_cod_postal_pe, tb_origen_razon_soc
				  FROM bdiburo:br_burofisicas_describe
				 WHERE num_credito = vnum_credito;
			  END IF;
		  END IF;
		  
	   END IF;
   END IF;
	
	let strpista = 'foreach PE';

	-- RQI 21 220 MACF 
	IF cArma_PE = 'S' OR (vsegmento_pe_base = '' or vsegmento_pe_base is null) THEN  --- VALIDACION CAMBIO DOM TRAB (Ini)
	   LET cArma_PE = 'S';
	
	/*SELECT limit 1 Trim(f.nombrecalle)||' '|| case when nvl(a.numeroextcalle,'') = '' then 'SN' else Trim(a.numeroextcalle) end ||' '||
	Trim(a.numerointcalle),
		nvl(Trim(g.nombrezona),''),nvl(Trim(g.municipiozona),''), Trim(c.estado),-- a.cod_postal,
	lpad(trim(a.cod_postal),5,"0"),manzana,andador,lote,edificio,entrada,codini,codfin,
		nvl(substr( CodigoPOstalZona,1,5),''),
		case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' then 1 else 0 end,
		a.pais, a.ciudad, a.estado
	INTO vcalle_pe, vcolonia_pe,vdelegacion_pe,vestado_pe,vcod_postal_pe, 
		 vmanzana_pe,vandador_pe,vlote_pe,vedificio_pe,ventrada_pe, vcodini_pe,vcodfin_pe,
		 vlCodigoPOstalZona_pe, scalle_conocido_pe, cpais_pe, vclave_ciudad_pe, vclave_edo_pe
	FROM bdinteg:si_direcciones_actual a 
			  left outer join bdisolic:ss_circulo_edos c on a.estado = c.clave
			  left outer join bdinteg:si_catzonas g on (a.numerociudad = g.numerociudad and a.numerocolonia = g.numerocolonia)
			  left outer join bdinteg:si_catcalles f on a.numerocalle = f.numerocalle
	WHERE a.numcte= vnumcte
	AND a.tipo_dir="2"
	AND c.empresa = "001";*/
	
	
	SELECT limit 1 case when substr(f.nombrecalle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(f.nombrecalle) else trim(f.nombrecalle) end nombrecalle, 
			a.numeroextcalle, a.numerointcalle, g.nombrezona, g.municipiozona, b.estado_abrev, a.cod_postal,
			a.manzana, a.andador, a.lote, a.edificio, a.entrada, c.codini, c.codfin, g.CodigoPOstalZona,
			case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' or f.nombrecalle like '%SIN%NOMBRE%' or f.nombrecalle like '%sin%nombre%' then 1 else 0 end,
			a.pais, a.ciudad, a.estado	
			INTO vnombrecalle_pe, vnumeroextcalle_pe, vnumerointcalle_pe, vcolonia_pe, vdelegacion_pe, vestado_pe, vcod_postal_pe,
				 vmanzana_pe, vandador_pe, vlote_pe, vedificio_pe, ventrada_pe, vcodini_pe, vcodfin_pe,
				 vlCodigoPOstalZona_pe_2, scalle_conocido_pe, cpais_pe, vclave_ciudad_pe, vclave_edo_pe
            FROM bdinteg:si_direcciones_actual a 
                      left outer join estados_sepomex b on lpad(trim(a.estado),2,"0") = b.c_estado
                      left outer join bdisolic:ss_circulo_edos c on lpad(trim(a.estado),2,"0") = c.clave
                      left outer join bdinteg:si_catzonas g on (a.numerociudad = g.numerociudad and a.numerocolonia = g.numerocolonia)
                      left outer join bdinteg:si_catcalles f on a.numerocalle = f.numerocalle
            WHERE a.numcte= vnumcte
            AND a.tipo_dir="2"
            AND c.empresa = "001";
			
			--IF nvl(vnumeroextcalle_pe,'') = '' OR vnumeroextcalle_pe::INT = 0 then let vnumeroextcalle_pe = 'SN'; end if;
			IF nvl(vnumeroextcalle_pe,'') = '' or nvl(vnumeroextcalle_pe,'') = 'S/N' or nvl(vnumeroextcalle_pe,'') = 'S/n' or nvl(vnumeroextcalle_pe,'') = 's/N' or nvl(vnumeroextcalle_pe,'') = 's/n' or vnumeroextcalle_pe= '0' or vnumeroextcalle_pe= '00' or vnumeroextcalle_pe= '000' or vnumeroextcalle_pe= '0000'  then let vnumeroextcalle_pe= 'SN'; end if;
			IF nvl(vnumerointcalle_pe,'') = '' or nvl(vnumerointcalle_pe,'') = 'S/N' or nvl(vnumerointcalle_pe,'') = 'S/n' or nvl(vnumerointcalle_pe,'') = 's/N' or nvl(vnumerointcalle_pe,'') = 's/n' or vnumerointcalle_pe= '0' or vnumerointcalle_pe= '00' or vnumerointcalle_pe= '000' or vnumerointcalle_pe= '0000'  then let vnumerointcalle_pe= 'SN'; end if;
			LET vnumerointcalle_pe = TRIM(vnumerointcalle_pe);
			LET vcalle_pe = trim(vnombrecalle_pe) || ' ' || trim(vnumeroextcalle_pe) || ' ' || vnumerointcalle_pe;
			LET vcolonia_pe = nvl(Trim(vcolonia_pe),'');
			LET vdelegacion_pe = nvl(Trim(vdelegacion_pe),'');
			LET vestado_pe = TRIM(vestado_pe);
			LET vcod_postal_pe = lpad(trim(vcod_postal_pe),5,"0");
			LET vlCodigoPOstalZona_pe = nvl(substr(vlCodigoPOstalZona_pe_2,1,5),'');
	
	
	let strpista = 'foreach 7';


	---Inicia Bloque de Validaciones Sepomex PE
	---Validacion por Codigo POstal del Cliente, Delegacion, Estado
	SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
	  FROM sepomex WHERE d_codigo = vcod_postal_pe AND substr(d_mnpio,1,27) = vdelegacion_pe AND estado_abrev = vestado_pe
	  group by d_mnpio, d_codigo ;
	  
	---Validacion por Delegacion, Estado  
	IF nvl(iCP_pe,0) <= 0 THEN
		 SELECT first 1 count(*), d_mnpio, d_codigo INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
		  FROM sepomex WHERE  substr(d_mnpio,1,27) = vdelegacion_pe AND estado_abrev = vestado_pe
		 group by d_mnpio, d_codigo ;    
	END IF;
	
	---Validacion por Colonia, Estado  		
	IF nvl(iCP_pe,0) <= 0 THEN
		 SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
		  FROM sepomex WHERE  trim(substr(d_asenta,1,32)) = vcolonia_pe AND estado_abrev = vestado_pe
		  group by d_mnpio, d_codigo ;  
	END IF;
	
	---Validacion por Codigo POstal de Zona, Estado  		
	IF nvl(iCP_pe,0) <= 0 THEN
		 SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
		  FROM sepomex WHERE  d_codigo = lpad(vlCodigoPOstalZona_pe,5,"0") AND estado_abrev = vestado_pe
		 group by d_mnpio, d_codigo ;   
	END IF;

	IF nvl(iCP_pe,0) <= 0 THEN
		 SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
		  FROM sepomex WHERE  d_codigo = vcod_postal_pe AND estado_abrev = vestado_pe
		  group by d_mnpio, d_codigo ;  
	END IF;
	
	---Validacion por Codigo POstal de Zona, Estado  		
	IF nvl(iCP_pe,0) > 0 THEN
		  let vdelegacion_pe =vlMnpioReportar_pe;
		  let vcod_postal_pe =vlCodigoReportar_pe;
	END IF;  
	---Fin de Bloque de Validaciones Sepomex PE

	let existe = length(vcalle_pe);

	IF existe < 40 THEN
	 let vcalle_pe1 = "";
	 IF vmanzana_pe > 0 THEN
	   let vcalle_pe1 ="mza. "|| vmanzana_pe;
	 END IF
	 IF vandador_pe > 0 THEN
	   let vcalle_pe1 =trim(vcalle_pe1)||"and. "||     vandador_pe ;
	 END IF
	 IF vlote_pe > 0 THEN
	   let vcalle_pe1 =trim(vcalle_pe1)||"lt. "  ||   vlote_pe ;
	 END IF
	 IF vedificio_pe > 0 THEN
	   let vcalle_pe1 =trim(vcalle_pe1)||"ed. "||     vedificio_pe ;
	 END IF
	 IF ventrada_pe > 0 THEN
	   let vcalle_pe1 =trim(vcalle_pe1)||"ent. "||     ventrada_pe ;
	 END IF
	let vcalle_pe = trim(vcalle_pe)||' '||trim(vcalle_pe1);
	END IF

	let existe = length(vcalle_pe);
	let existe1 = 0;
	let vquita = "";
	let vespacio = "";
	let hueco = 0;
	while existe1 < existe
	if vcalle_pe[1,1]="~" THEN
	else
	if vcalle_pe[1,1]="#" and vespacio = "" THEN
	   let vespacio = "F";
	END if
	if vespacio = "F" THEN
	  let vquita = trim(vquita)||" "||vcalle_pe[1,1];
	  let vespacio = "";
	  let hueco = 1;
	else
	  let vquita = trim(vquita)||vcalle_pe[1,1];
	END if;
	if vcalle_pe[1,1]=" " THEN
	   let vespacio = "F";
	END if;
	END if;
	let vcalle_pe = vcalle_pe[2,40];
	let existe1 = existe1 + 1;
	END while;
	let vcalle_pe = trim(vquita);
	if hueco = 0 THEN
	let vcalle_pe = trim(vquita)||"1";
	END if;
	let vciudad_pe = "";

	if vcod_postal_pe IS NULL THEN
	let vcod_postal_pe = "00000";
	END if;

	--Envio de tramas sin direccion, asignacion de blanco, para armar la trama
	IF vestado_pe is null or vestado_pe = '' THEN
	LET vcalle_pe = '';
	LET vcolonia_pe = '';
	LET vdelegacion_pe = ''; 
	LET vestado_pe = '';
	LET vcod_postal_pe = '';
	LET vmanzana_pe = '';
	LET vandador_pe = '';
	LET vlote_pe = '';
	LET vedificio_pe = '';
	LET ventrada_pe = '';
	LET vcodini_pe = '';
	LET vcodfin_pe = '';
	LET vlCodigoPOstalZona_pe = '';

	LET bmotivo = 1;
	ELSE 
	LET bmotivo =0;
	END IF;

	IF scalle_conocido_pe = 1 THEN
	   LET vcalle_pe = 'DOMICILIO CONOCIDO SN';
	END IF;

	-- Agrega Direccion
	let vsegmento_pe = trim(vsegmento_pe)||'00'||
						lpad(length(trim(vcalle_pe)),2,"0")||vcalle_pe;
	let tb_calle_pe         = vcalle_pe;

	-- Agrega Colonia
	if vcolonia_pe is not null then
	let vsegmento_pe = trim(vsegmento_pe)||'02'||
						lpad(length(trim(vcolonia_pe)),2,"0")||vcolonia_pe;
	let tb_colonia_pe       = vcolonia_pe;
	ELSE
	let vsegmento_pe = trim(vsegmento_pe)||'0200'; --RQM 09 467_Version 14
	end if;

	-- Agrega Delegacion o Municipio
	if vdelegacion_pe != "" then       
		let vsegmento_pe = trim(vsegmento_pe)||'03'||
							   lpad(length(trim(vdelegacion_pe)),2,"0")||vdelegacion_pe;
		let tb_delegacion_pe     = vdelegacion_pe;
	elif vdelegacion_pe = "" or vdelegacion_pe is null then
		let vsegmento_pe = trim(vsegmento_pe)||'0300'; --RQM 09 467_Version 14                 
    end if;
		-- Agrega Ciudad
			--estado y ciudad de si_direcciones_actual para con eso consultar el nombre de la ciudad en si_ciudades.
		--SELECT nvl(nombre,'') INTO vciudad_pe
		SELECT nombre INTO vciudad_pe
		FROM bdinteg:si_ciudades 
		WHERE estado = vclave_edo_pe
		AND ciudad = vclave_ciudad_pe;       
		
		LET vciudad_pe = nvl(vciudad_pe,'');

		if vciudad_pe = '' OR vciudad_pe is null then 
			let vciudad_pe = '';  
			let vsegmento_pe = trim(vsegmento_pe)||'0400'; --RQM 09 467_Version 14
		else-- vciudad_pe != ''  then
			let vsegmento_pe = trim(vsegmento_pe)||'04'||
							   lpad(length(trim(vciudad_pe)),2,"0")||vciudad_pe;
			let tb_ciudad_pe        = vciudad_pe;
		end if;
	

	-- Agrega Estado
	let vsegmento_pe = trim(vsegmento_pe)||'05'||
	lpad(length(trim(vestado_pe)),2,"0")||trim(vestado_pe);
	let tb_estado_pe        = trim(vestado_pe);

	-- Agrega Codigo Postal
	let vsegmento_pe = trim(vsegmento_pe)||'06'||
	lpad(length(trim(vcod_postal_pe)),2,"0")||trim(vcod_postal_pe);
	let tb_cod_postal_pe    = trim(vcod_postal_pe);

	-- Agregar origen del domicilio De la razon social (pais) 
	let vsegmento_pe = trim(vsegmento_pe)||'1802MX';
	let tb_origen_razon_soc  = 'MX';

	let vsegmento_pe = 'PE'||trim(vsegmento_pe);           	  
-- TERMINA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14

 END IF;   --- VALIDACION CAMBIO DOM TRAB (Fin)

-- INICIA SEGMENTO TL(RESUMEN DE CREDITO)
    -- Agregar Clave y nombre del otorgante
         let vsegmento3_tl = '02TL0110'||vclave_usu||'02'||
             lpad(length(trim(vnombre_usu)),2,"0")||vnombre_usu;
         let tb_clave_usu         = vclave_usu;
         let tb_nombre_usu        = vnombre_usu;

		 let vsegmento3_tl_2 = '02TL0110'||vclave_usu||'02'||     --MACF
             lpad(length(trim(vnombre_usu)),2,"0")||vnombre_usu;
			 
    -- Agregar Numero de credito
         --let vsegmento3_tl = trim(vsegmento3_tl)||'04'||
             --lpad(length(trim(vnum_credito)),2,"0")||trim(vnum_credito);
		-- RQM 09 502 - Se modifica para agregar en su lugar el Numero de tarjeta - solo si no es Reestructura
		 if cNumProducto in('6001','6600','7000','8100','8500','5400') then
		     let vsegmento3_tl = trim(vsegmento3_tl)||'04'||
				 lpad(length(trim(vnum_tarjeta)),2,"0")||trim(vnum_tarjeta);
			 let tb_num_credito = trim(vnum_credito);
			 let tb_num_tarjeta = trim(vnum_tarjeta);
			 
			 if cTarjetaCambiada = 'S' then
			    let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'04'||
				   lpad(length(trim(vnum_tarjeta_ant)),2,"0")||trim(vnum_tarjeta_ant);  --MACF
			 end if;
		 else 	
			let vsegmento3_tl = trim(vsegmento3_tl)||'04'||
            lpad(length(trim(vnum_credito)),2,"0")||trim(vnum_credito);
			let tb_num_credito = trim(vnum_credito);
			let tb_num_tarjeta = ''; 			 
		 end if;
		 

	 
    -- Agregar Tipo de responsabilidad de la cuenta
         -- I = Individual
         -- J = Mancomunada
         -- C = Obligado Solidario
         let vsegmento3_tl = trim(vsegmento3_tl)||'0501I0601';
         let tb_responsabilidad   = "I";

		 let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'0501I0601'; --MACF

    -- Agregar Tipo de cuenta y tipo de producto
        -- TIPO DE CUENTA
        -- I = Pagos Fijos
        -- M = Hipotecaria
        -- O = Sin limite preestablecido
        -- R = Revolvente

        -- TIPO DE PRODUCTO
        -- CC = Tarjeta de Credito
        -- PL = Prestamo Personal

         LET vsegmento3_tl =  TRIM(vsegmento3_tl)||'R0702CC';
		 LET vsegmento3_tl_2 =  TRIM(vsegmento3_tl_2)||'R0702CC'; --MACF
         LET vnum_pagos       =  0;
         LET vfrecpago        =  "Z";  --IPCB 10Nov20// Se corrige la frecuencia de Pago LET vfrecpago        =  "M";
         LET tb_tipo_cuenta   =  "R";
         LET tb_tipo_producto =  "CC";

    --Agregar Clave Monetaria
      -- MX = Pesos
      -- US = Dolares
      -- UD = Unidades de Inversion
         let vsigla_div = "MX";
         let vsegmento3_tl = trim(vsegmento3_tl)||'0802MX';
		 let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'0802MX'; --MACF
         let tb_clave_monetaria   = "MX";

    -- Agregar Numero de Pagos
         let vsegmento3_tl = trim(vsegmento3_tl)||'10'||
         lpad(length(vnum_pagos),2,"0")||trim(vnum_pagos);
		 let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'10'|| --MACF
         lpad(length(vnum_pagos),2,"0")||trim(vnum_pagos);
         let tb_num_pagos         = trim(vnum_pagos);

    -- Agregar Fecuencia de Pagos
       -- M = Mensual
         let vsegmento3_tl = trim(vsegmento3_tl)||'1101'||vfrecpago;
		 let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1101'||vfrecpago; --MACF
         let tb_frecpago          = vfrecpago;

    -- Agregar Monto a Pagar 
    -- Se adelanta la obtencion de saldos
         let vmonto_otorgado = 0;
         let vsaldo_vig = 0;
         let vsaldo_actual = 0;
         let vsaldo_venc = 0;
         let vcuotas_ven = 0;
         let v_interes = 0;
		 let vmontoinsoluto = 0;

		--- RQM 09 502 MACF - Si tarjeta cambio, obtener la causa del cambio dependiendo de ello se informa clave de observacion
		/*if cNumProducto in('6001','6600','7000','8100','8500','5400') then
		   if iEjecucion_primera_vez <> '1' then
			
			if cTarjetaCambiada = 'S' then
			   -- buscar la tarjeta en intercard:bitacoracambiosstatustarjeta y validar si fue por EXT o ROB
				select a.codstatustarjetanvo into vCodstatus_tarjetanvo
   				  from intercard:bitacoracambiosstatustarjeta a 
				 where a.tarjeta = vnum_tarjeta_ant
                   and a.fechahora = (select max(fechahora) 
				                        from intercard:bitacoracambiosstatustarjeta where tarjeta = a.tarjeta);
				
                if vCodstatus_tarjetanvo is null then let vCodstatus_tarjetanvo = ''; end if;
				
                if vCodstatus_tarjetanvo in('EXT','ROB') then
				   let vClaveObserv_tarjeta = 'LS';
				else   
				   let vClaveObserv_tarjeta = '';
				end if;
			end if;
			
		   end if;	
        end if;*/
		--- RQM 09 502 MACF
		
     		let strpista = 'foreach 8';

-- Claves de observacion de cierre el saldo es CERO
        -- if (vstatus_cred = 'FF' or vstatus_cred = 'FC' or vstatus_cred = 'CV') then
          if (vstatus_cred = 'FF' or vstatus_cred = 'FC' or vstatus_cred = 'CV' or vstatus_cred = 'FI' ) then
            let vmonto = 0;
            let vsaldo_actual = 0;
            let vsaldo_venc = 0;
            if (cNumProducto <> '6011') then
              --if (vstatus_cred = 'FF') then RQM 09 343-0
              if (vstatus_cred IN ('FF','FI') ) then 
                    --select nvl(monto_otorgado,0) -- MONTO OTORGADO
					select monto_otorgado
                    into vmonto_otorgado
                    from bdicred:sd_maesdos
                    where empresa = "001"
                    and num_credito = vnum_credito;
					
					LET vmonto_otorgado = nvl(vmonto_otorgado,0);
					
                elif (vstatus_cred = 'FC') then
                    --select nvl(monto_otorgado,0) -- MONTO OTORGADO
					select monto_otorgado
                    into vmonto_otorgado
                    from bdicred:sd_maesdos_vendida
                    where empresa = "001"
				   and fecha between vfecha_ini and vfecha_hoy  --IPCB Ene2020, se agrega filtro por mes de venta error reportado -284																										
                   and num_credito = vnum_credito;
				   
				   LET vmonto_otorgado = nvl(vmonto_otorgado,0);
                else
  -- Obtiene el saldo vencido de la cuenta vendida de TDC    
--IPCB 12mar14 Se cambia la extraccio del saldo vencido para no duplicar el capital y considerar el iva  
                    select nvl(((monto_vencido + mto_venc_trasp) + 
                               ((sdo_moratorio + sdo_contab_mora)*1.16)) + 
                                (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) 
                                   from bdicred:sd_amortiza_credito_vendida
                                  where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6') and a.fecha = fecha ) ,0),
                            nvl(monto_otorgado,0),
                            nvl(mto_fin_ven_trasp,0) -- CUOTAS VENCIDAS
                      into vsaldo_venc,
                           vmonto_otorgado,
					       vcuotas_ven
                      from bdicred:sd_maesdos_vendida a
                     where empresa = "001"
					   and fecha between vfecha_ini and vfecha_hoy --IPCB Ene2020, se agrega filtro por mes de venta error reportado -284 
                       and num_credito = vnum_credito;
                end if;
            end if;
         else
            if (cNumProducto = '6011') THEN
              select dia_corte 
                into iDiaCorteRee
                from bdicred:sd_maecredanexocrd
               where empresa = "001"
                 and num_credito = vnum_credito;

              let vfecha_dia = mdy(month(vfecha_hoy),iDiaCorteRee  - 1,year(vfecha_hoy));
                 
              SELECT nvl(nvl(monto_financiado,0) + -- SALDO DE CAPITAL 
                     nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
                     nvl(mto_venc_int,0) + -- IVA DE INTERES VENCIDO
                     nvl(sdo_no_exig,0) + -- INTERES VIGENTE
                     nvl(mto_finan_vdo,0),0)  -- IVA DE INTERES VIGENTE
                into vmonto
                FROM bdicred:sd_maesdoshistcrd a 
                where empresa = "001"
                and fecha = vfecha_dia
                and num_credito = vnum_credito;

              SELECT nvl(nvl(sdo_cap_insoluto,0) + -- SALDO INSOLUTO 
                     nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
                     nvl(mto_venc_int,0) +    -- IVA DE INTERES VENCIDO
                     nvl(sdo_no_exig,0) +     -- INTERES VIGENTE
                     nvl(mto_finan_vdo,0) +    -- IVA DE INTERES VIGENTE
                     nvl(provision_normal,0) + -- PROVISION FIN DE MES
                     nvl(sdo_global_int,0),0), -- IVA DE PROVISION FIN DE MES

                     nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
                     nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
                     nvl(mto_venc_int,0),0), -- IVA DE INTERES VENCIDO
                     nvl(mto_fin_ven_trasp,0), -- CUOTAS VENCIDAS
					 nvl(sdo_cap_insoluto,0), -- SALDO INSOLUTO
					 nvl(monto_otorgado,0)    --RQM 09 467_Version 14
                into vsaldo_actual,
                     vsaldo_venc,
                     vcuotas_ven,
					 vmontoinsoluto,
					 d_monto_originacion
                FROM bdicred:sd_maesdoscontcrd
                where empresa = "001"
                and fecha = vfecha_hoy
                and num_credito = vnum_credito;

                -- SOLO APLICA PARA 1er DIA INHABIL
                if (vmonto is null or vmonto = -1) then
                    let vmonto = vsaldo_actual;
                end if;
				
            else
			   IF cNumProducto = '7800' THEN
					LET vfecha_corte = mdy(month(vfecha_hoy),20,year(vfecha_hoy));			   
				ELSE
					select dia_corte 
					  into iDiaCorte
					  from bdicred:sd_maecredanexo
				     where empresa = "001"
					  and num_credito = vnum_credito;
						
					LET vfecha_corte= mdy(month(vfecha_hoy),iDiaCorte,year(vfecha_hoy));
				END IF;
							
				select nvl(monto_financiado,0) + -- CAPITAL
					   nvl(sdo_moratorio,0) + NVL(sdo_contab_mora,0) + -- MORATORIO
					   round(((nvl(sdo_moratorio,0) + NVL(sdo_contab_mora,0)) * 0.16),2) +  -- Moratorio
					   case when (case when NVL(sdo_int_anticip,0) > 0 then (int_tra_no_exig - sdo_acum_mes_int) else int_tra_no_exig end) > 0 
							then (case when NVL(sdo_int_anticip,0) > 0 then (int_tra_no_exig - sdo_acum_mes_int) else int_tra_no_exig end) 
							else 0 
					   end + -- INTERES VENCIDO
					   NVL(mto_venc_int,0) -- IVA VENCIDO
				into vmonto
				from bdicred:sd_maesdoshist
				where empresa = "001"
				and fecha = vfecha_corte
				and num_credito = vnum_credito;
				
				--select nvl(monto_otorgado,0) -- MONTO OTORGADO
				select monto_otorgado
				into vmonto_otorgado 
				from bdicred:sd_maesdoscont 
				where empresa = "001"
				and fecha = vfecha_hoy
				and num_credito = vnum_credito;
				
				let vmonto_otorgado = nvl(vmonto_otorgado,0);

				if (vmonto_otorgado <= 0 or vmonto_otorgado is null) then
					let vmonto_otorgado = 0;
				end if;
				
				if (vmonto <= 0 or vmonto is null) then
					let vmonto = 0;
				end if;
				
                let vfecha_dia = mdy(month(vfecha_hoy),'01',year(vfecha_hoy));

                if day(vfecha_hoy) = 28 then 
                    select nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0),
                           nvl(captrans28 + capvenexig28 + intvenc28 + ivaintvenc28 + moratorios28 + round((moratorios28 * 0.16),2),0),
                           nvl(meses_vencidos28,0),
						   nvl(capvig28 + captrans28 + capvencnoexig28 + capvenexig28,0)
                      into vsaldo_actual,
                           vsaldo_venc,
                           vcuotas_ven,
						   vmontoinsoluto
                    from bdicred:sd_sdodiario 
                    where fecha = vfecha_dia
                    and num_credito = vnum_credito;
                elif day(vfecha_hoy) = 29 then 
                    select nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0),
                           nvl(captrans29 + capvenexig29 + intvenc29 + ivaintvenc29 + moratorios29 + round((moratorios29 * 0.16),2),0),
                           nvl(meses_vencidos29,0),
						   nvl(capvig29 + captrans29 + capvencnoexig29 + capvenexig29,0)
                      into vsaldo_actual,
                           vsaldo_venc,
                           vcuotas_ven,
						   vmontoinsoluto
                    from bdicred:sd_sdodiario 
                    where fecha = vfecha_dia
                    and num_credito = vnum_credito;
                elif day(vfecha_hoy) = 30 then 
                    select nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0),
                           nvl(captrans30 + capvenexig30 + intvenc30 + ivaintvenc30 + moratorios30 + round((moratorios30 * 0.16),2),0),
                           nvl(meses_vencidos30,0),
						   nvl(capvig30 + captrans30 + capvencnoexig30 + capvenexig30,0)
                      into vsaldo_actual,
                           vsaldo_venc,
                           vcuotas_ven,
						   vmontoinsoluto
                    from bdicred:sd_sdodiario 
                    where fecha = vfecha_dia
                    and num_credito = vnum_credito;
                else
                    select nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0),
                           nvl(captrans31 + capvenexig31 + intvenc31 + ivaintvenc31 + moratorios31 + round((moratorios31 * 0.16),2),0),
                           nvl(meses_vencidos31,0),
						   nvl(capvig31 + captrans31 + capvencnoexig31 + capvenexig31,0)						   
                      into vsaldo_actual,
                           vsaldo_venc,
                           vcuotas_ven,
						   vmontoinsoluto
                    from bdicred:sd_sdodiario 
                    where fecha = vfecha_dia
                    and num_credito = vnum_credito;
					
              end if;		  
				--IF vstatus_cred IN ('AA','BA') AND cNumProducto = '6001' THEN--IPCB Jul 2018 -Agrega al saldo  el saldo de las credisoluciones con que cuente.
				--IF vstatus_cred IN ('AA','BA','E1') AND cNumProducto = '6001' THEN--IPCB Jul 2018 -Agrega al saldo  el saldo de las credisoluciones con que cuente. IFRS MACF
				IF vstatus_cred IN ('AA','BA','E1') AND cNumProducto != '6011' THEN -- Para que tome en cuenta todas los productos de tdc para MSI																													  
					SELECT NVL(SUM(c.sdo_cap_insoluto),0)
					  INTO vsdo_cierre_credisol
					  FROM bdicred:sd_promocion_credito a
						INNER JOIN bdicred:sd_maecredcontcrd b on b.fecha = vfecha_hoy and b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred in ('AA','E1')
						INNER JOIN bdicred:sd_maesdoscontcrd c on c.fecha = vfecha_hoy and c.empresa = a.empresa and c.num_credito = a.num_sol_prestamo and (c.monto_vencido + c.mto_venc_trasp) = 0
					 WHERE a.empresa = '001'
				       AND a.num_credito = vnum_credito;
					 
					 IF (vmontoinsoluto < 0 or vmontoinsoluto is null) THEN
						LET vmontoinsoluto = vsdo_cierre_credisol;
					 ELSE
						LET vmontoinsoluto = vmontoinsoluto +  vsdo_cierre_credisol;  
					END IF;
                    --IPCB Feb 2019 - Se integra el saldo de la credisolucion al saldo actual.
					IF 	(vsaldo_actual < 0 OR vsaldo_actual is null) THEN
						LET vsaldo_actual = vsdo_cierre_credisol;
					ELSE
						LET vsaldo_actual = vsaldo_actual + vsdo_cierre_credisol;
					END IF;
				END IF;	   
			end if;
          end if;
--IPCB 19092013 redondeo de vmonto centavos a uno
         if (vmonto > 0 and vmonto < 1) then
           let vmonto=1;
         elif (vmonto >= 1) then
            let vmonto = round(vmonto,0);
         else
            let vmonto = 0;
         end if;
--IPCB 26nov14: Agrega validacion para  saldo_act si <= 0 entonces monto_pagar	=0 para creditos con Baja	 
		 if vidbaja = 'BAJA' and vsaldo_actual <= 0 then
		   let vmonto = 0;
		 end if;
--IPCB 10Nov20 //inicio bloque extraccion  informacion para validar el monto_pagar.
    -- Agregar Fecha de Ultimo Pago y Ultima Compra
         if (cNumProducto = '6011') THEN
            select fecha_mov
              into vfechaultpago
              from MovtosCred
             where num_credito = vnum_credito;

            let vfechaultcompra = vfecha_apertura;

            if (vstatus_cred = 'CV') then
                select first 1 nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
                       nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
                       nvl(mto_venc_int,0),0),   -- IVA DE INTERES VENCIDO
                       nvl(mto_fin_ven_trasp,0), -- CUOTAS VENCIDAS
                       nvl(monto_otorgado,0)
                  into vsaldo_venc,
					   vcuotas_ven,
                       vcredito_maximo
                  FROM bdicred:sd_maesdoscrd_vendida
                 where empresa = "001"
				   and fecha between vfecha_ini and vfecha_hoy --IPCB Ene2020, se agrega filtro por mes de venta 																					
                   and num_credito = vnum_credito;
            else
                --select nvl(monto_otorgado,0)
				select monto_otorgado
                  into vcredito_maximo
                  from bdicred:sd_maesdoscrd
                 where empresa = "001"
                   and num_credito = vnum_credito;
				   
				   let vcredito_maximo = nvl(vcredito_maximo,0);
            end if;
		let strpista = 'foreach 9';

            let vmonto_otorgado = vcredito_maximo;

            /*select nvl(fecha_vencido,date(1)), -- primer incumplimiento
                   nvl(dias_atraso,0), -- dias de atraso
                   nvl(fecha_ultimo_pago_h,date(1)) -- fecha de ultimo pago*/
			select fecha_vencido, dias_atraso, fecha_ultimo_pago_h	   
              into vfecha_vencido,
                   vdiasatraso,
                   vfechaultpago
              from bdicred:sd_indicador_cred_crd
             where empresa = "001" 
               and num_credito = vnum_credito;	
			   
			   let vfecha_vencido = nvl(vfecha_vencido,date(1));
			   let vdiasatraso  = nvl(vdiasatraso,0);
			   let vfechaultpago = nvl(vfechaultpago,date(1));
         else
            /*select nvl(fecha_ultimo_pago_h,date(1)), --fecha de ultimo pago
                   nvl(fecha_ultima_compra_h,date(1)), --fecha de ultima compra
                   nvl(saldo_maximo_h,0), --credito maximo
                   nvl(fecha_vencido,date(1)), -- primer incumplimiento
                   nvl(dias_atraso,0), -- dias de atraso
                   nvl(monto_ultimo_pago_h,0) -- monto de ultimo pago*/
			  select fecha_ultimo_pago_h, fecha_ultima_compra_h, saldo_maximo_h, fecha_vencido, dias_atraso, monto_ultimo_pago_h
              into vfechaultpago,
                   vfechaultcompra,
                   vcredito_maximo,
                   vfecha_vencido,
                   vdiasatraso,
                   vmontolutpago
              from bdicred:sd_indicador_cred
             where empresa = "001" 
               and num_credito = vnum_credito;
			   
               let vfechaultpago = nvl(vfechaultpago,date(1));



			   let vfechaultcompra = nvl(vfechaultcompra,date(1));
			   let vcredito_maximo = nvl(vcredito_maximo,0);
               let vfecha_vencido = nvl(vfecha_vencido,date(1));
			   let vdiasatraso = nvl(vdiasatraso,0);
			   let vmontolutpago = nvl(vmontolutpago,0);
			   
		   
               -- Jom Ini ultima disposicion ADN ini
               IF (cNumProducto = '7800') THEN
                    --select nvl(fecha_ult_disp,date(1)) --fecha de ultima compra
					select fecha_ult_disp
                    into vfechaultcompra 
                    from bdisolic:ss_adn_solicitudcuenta
                    where num_solicitud = vnum_credito;
					
					let vfechaultcompra = nvl(vfechaultcompra,date(1));
               END IF;
                -- Jom Ini ultima disposicion ADN fin
         end if;     
                      
        --IPCB 10Nov20 //Se mueve redondeo de vsaldo_actual
		 if (vsaldo_actual > 0 and vsaldo_actual < 1) then
			 let vsaldo_actual = 1;
		 end if;

--IPCB Feb 2019 -Se valida el saldo actual, y los negativos se pasan a 0
         if  vsaldo_actual < 0   then
             let vsaldo_actual = 0;	 
         end if;		
                
         IF vsaldo_actual > 0 AND vmonto <= 0   THEN
             LET vv_frep_fuc = vfecha_hoy - vfechaultcompra;
             LET vv_frep_fup = vfecha_hoy - vfechaultpago;
             LET vv_frep_fap = vfecha_hoy - vfecha_apertura;
             
             IF vv_frep_fuc >= 31 AND 
               (vfechaultpago = '' OR vfechaultpago = date(1) OR vv_frep_fup > 31) AND 
                vv_frep_fap >= 31 THEN
               
               SELECT factor_pago_min,mto_pago_min 
                INTO vfac_pagmin, vmto_pago_min
                FROM bdicred:sd_definicion
                WHERE num_producto = cNumProducto;
                
                LET vmonto = (vsaldo_actual * vfac_pagmin)/100;
                
                IF vmonto < vmto_pago_min THEN
                    LET vmonto = vmto_pago_min;
                ELIF vmonto > vsaldo_actual THEN  
                    LET vmonto = vsaldo_actual;
                END IF;
                
             END IF;
         END IF;    
--IPCB 10Nov20 //fin bloque extraccion  informacion para validar el monto_pagar.

         if vClaveObserv_tarjeta  = 'LS' then --RQM 09 502 MACF
            let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1200';  --RQM 09 502 MACF
			 let tb_monto_pagar_2       = 0; 
         end if; 

		 let vsegmento3_tl = trim(vsegmento3_tl)||'1209'||
							 lpad(round(vmonto,0),9,"0");
		 let tb_monto_pagar       = round(vmonto,0);
		 
		 
    -- Agregar Fecha de Apertura de la Cuenta
         let vano = year(vfecha_apertura);
         let vmes = lpad(month(vfecha_apertura),2,"0");
         let vdia = lpad(day(vfecha_apertura),2,"0");
         let vsegmento3_tl = trim(vsegmento3_tl)||'1308'||vdia||vmes||vano;
		 let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1308'||vdia||vmes||vano; --MACF
         let tb_fecha_apertura    = vdia||vmes||vano;

    -- Agregar Fecha de Ultimo Pago    --IPCB 10Nov20 INI// Se comenta bloque para subirlo y validar vmonto(monto_pagar) 
 /*        if (cNumProducto = '6011') THEN
            select fecha_mov
              into vfechaultpago
              from MovtosCred
             where num_credito = vnum_credito;

            let vfechaultcompra = vfecha_apertura;

            if (vstatus_cred = 'CV') then
                select first 1 nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
                       nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
                       nvl(mto_venc_int,0),0),   -- IVA DE INTERES VENCIDO
                       nvl(mto_fin_ven_trasp,0), -- CUOTAS VENCIDAS
                       nvl(monto_otorgado,0)
                  into vsaldo_venc,
					   vcuotas_ven,
                       vcredito_maximo
                  FROM bdicred:sd_maesdoscrd_vendida
                 where empresa = "001"
				   and fecha between vfecha_ini and vfecha_hoy --IPCB Ene2020, se agrega filtro por mes de venta 																					
                   and num_credito = vnum_credito;
            else
                --select nvl(monto_otorgado,0)
				select monto_otorgado
                  into vcredito_maximo
                  from bdicred:sd_maesdoscrd
                 where empresa = "001"
                   and num_credito = vnum_credito;
				   
				   let vcredito_maximo = nvl(vcredito_maximo,0);
            end if;

            let vmonto_otorgado = vcredito_maximo;

			select fecha_vencido, dias_atraso, fecha_ultimo_pago_h	   
              into vfecha_vencido,
                   vdiasatraso,
                   vfechaultpago
              from bdicred:sd_indicador_cred_crd
             where empresa = "001" 
               and num_credito = vnum_credito;	
			   
			   let vfecha_vencido = nvl(vfecha_vencido,date(1));
			   let vdiasatraso  = nvl(vdiasatraso,0);
			   let vfechaultpago = nvl(vfechaultpago,date(1));
         else
			  select fecha_ultimo_pago_h, fecha_ultima_compra_h, saldo_maximo_h, fecha_vencido, dias_atraso, monto_ultimo_pago_h
              into vfechaultpago,
                   vfechaultcompra,
                   vcredito_maximo,
                   vfecha_vencido,
                   vdiasatraso,
                   vmontolutpago
              from bdicred:sd_indicador_cred
             where empresa = "001" 
               and num_credito = vnum_credito;
			   
			   let vfechaultpago = nvl(vfechaultpago,date(1));
			   let vfechaultcompra = nvl(vfechaultcompra,date(1));
			   let vcredito_maximo = nvl(vcredito_maximo,0);
               let vfecha_vencido = nvl(vfecha_vencido,date(1));
			   let vdiasatraso = nvl(vdiasatraso,0);
			   let vmontolutpago = nvl(vmontolutpago,0);
			   
               -- Jom Ini ultima disposicion ADN ini
               IF (cNumProducto = '7800') THEN
                    --select nvl(fecha_ult_disp,date(1)) --fecha de ultima compra
					select fecha_ult_disp
                    into vfechaultcompra 
                    from bdisolic:ss_adn_solicitudcuenta
                    where num_solicitud = vnum_credito;
					
					let vfechaultcompra = nvl(vfechaultcompra,date(1));
               END IF;
                -- Jom Ini ultima disposicion ADN fin
         end if;
 */ --IPCB 10Nov20 FIN// Se comenta bloque para subirlo y validar vmonto(monto_pagar)          
         --if (vfechaultpago   is null) then let vfechaultpago   = date(1); end if;   -- RQM 09 467_Version 14
         --if (vfechaultcompra is null) then let vfechaultcompra = date(1); end if;   -- RQM 09 467_Version 14

         let vano = year(vfechaultpago);
         let vmes = lpad(month(vfechaultpago),2,"0");
         let vdia = lpad(day(vfechaultpago),2,"0");

         IF (vfechaultpago IS NOT NULL AND vfechaultpago <> '01/01/1900') THEN 
            let vsegmento3_tl = trim(vsegmento3_tl)||'1408'||vdia||vmes||vano;
			let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1408'||vdia||vmes||vano; --RQM 09 502
            let tb_fecha_ult_pago    = vdia||vmes||vano;
         else
            let vsegmento3_tl = trim(vsegmento3_tl)||'1400';
			let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1400'; --RQM 09 502
            let tb_fecha_ult_pago    = '';
         end if;
         
    -- Agregar Fecha de Ultima Compra
         let vano = year(vfechaultcompra);
         let vmes = lpad(month(vfechaultcompra),2,"0");
         let vdia = lpad(day(vfechaultcompra),2,"0");

         IF (vfechaultcompra IS NOT NULL AND vfechaultcompra <> '01/01/1900') THEN
           let vsegmento3_tl = trim(vsegmento3_tl)||'1508'||vdia||vmes||vano;
		   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1508'||vdia||vmes||vano; --RQM 09 502
           let tb_fecha_ult_compra  = vdia||vmes||vano;
         ELSE
           let vsegmento3_tl = trim(vsegmento3_tl)||'1500';
		   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1500';  --RQM 09 502
           let tb_fecha_ult_compra  = '';
         END IF;
    -- Agregar Fecha de cierrre de la cuenta

        if vClaveObserv_tarjeta  = 'LS' then --RQM 09 502
		   let vano = year(vfecha_hoy);
		   let vmes = lpad(month(vfecha_hoy),2,"0");
           let vdia = lpad(day(vfecha_hoy),2,"0");
		
		   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1608'||vdia||vmes||vano; --RQM 09 502
           let tb_fecha_cierre_2      = vdia||vmes||vano;	 
		end if; 

		--if (vstatus_cred = 'FF' or vstatus_cred = 'FC' or vstatus_cred = 'CV') then
         if (vstatus_cred = 'FF' or vstatus_cred = 'FC' or vstatus_cred = 'CV'  or vstatus_cred = 'FI') then  
             if (cNumProducto = '6011') THEN
               select fecha_proceso,
                      nvl((fecha_proceso - nvl(fecha_vencto,fecha_proceso)) + 1,0)
                 into dtFechaApRee,
                      vdiasatraso
                 from bdicred:sd_maecredanexocrd
                where empresa = "001"
                  and num_credito = vnum_credito;
             else
               select fecha_proceso,
                      nvl((fecha_proceso - nvl(fecha_vencto,fecha_proceso)) + 1,0)
                 into dtFechaApRee,
                      vdiasatraso
                 from bdicred:sd_maecredanexo
                where empresa = "001"
                  and num_credito = vnum_credito;
            end if;

            let vano = year(dtFechaApRee);
            let vmes = lpad(month(dtFechaApRee),2,"0");
            let vdia = lpad(day(dtFechaApRee),2,"0");

            let vsegmento3_tl = trim(vsegmento3_tl)||'1608'||vdia||vmes||vano;
            let tb_fecha_cierre      = vdia||vmes||vano;
         else
            let tb_fecha_cierre      = "";
         end if;

	   
    -- Agregar Fecha Reporte
         let vsegmento3_tl = trim(vsegmento3_tl)||'1708'||vfecha_reporte;
		 let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1708'||vfecha_reporte; --RQM 09 502
         let tb_fecha_reporte     = vfecha_reporte;

    -- Agregar Credito Maximo
         if vcredito_maximo < vsaldo_actual then let vcredito_maximo = vsaldo_actual; end if;

         let vsegmento3_tl = trim(vsegmento3_tl)||'2109'||
                               lpad(round(vcredito_maximo,0),9,"0");
		 let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2109'||       --RQM 09 502
                               lpad(round(vcredito_maximo,0),9,"0");
         let tb_credito_maximo    = round(vcredito_maximo,0);

    -- Agregar Saldo Actual
		 if vClaveObserv_tarjeta  = 'LS' then --RQM 09 502 MACF
		    let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2200';  
			let tb_saldo_actual_2  = 0; 
		 end if;

		 if nvl(vsaldo_actual,'') = '' then --- RQM 09 467_Version 14
			let vsegmento3_tl = trim(vsegmento3_tl)||'2200';
		 end if; 
/*	--IPCB 10Nov20 INI-Se mueve bloque de validacion  a donde se valida el vmonto	 		 
		 if (vsaldo_actual > 0 and vsaldo_actual < 1) then
			 let vsaldo_actual = 1;
		 end if;

--IPCB Feb 2019 -Se valida el saldo actual, y los negativos se pasan a 0
         if  vsaldo_actual < 0   then
             let vsaldo_actual = 0;	 
         end if;		 		 
*/  --IPCB 10Nov20 FIN-Se mueve bloque de validacion  a donde se valida el vmonto	 		 
		 let vsaldo_actual = round(vsaldo_actual,0);
		 let tb_saldo_actual  = vsaldo_actual;
			 
		 if (vsaldo_actual >= 0) then
			let vsegmento3_tl = trim(vsegmento3_tl)||'2210'||
							 lpad(round(vsaldo_actual,0),10,"0");
		 else
			let vsaldo_actual = abs(vsaldo_actual);
			let vsegmento3_tl = trim(vsegmento3_tl)||'2210'||
								  lpad(round(vsaldo_actual,0),9,"0")||"-";
		 end if;                
	-- RQM 09 599 Hallazgos BANXICO 2021 - MACF
	-- Mover este query que estaba mas abajo para obtener el dato dmonto_autorizado antes, para ser usado en el monto_otorgado 
	-- si este es 1, '' o nulo, Solo se mueve el query.
			let strpista = 'foreach 10';

	--Monto del Credito en la originacio IPCB
      IF cNumProducto <> '6011' THEN
          SELECT monto_solicitado INTO dmonto_autorizado
            FROM bdisolic:ss_solicitudes
           WHERE empresa = '001'
             AND num_solicitud = vnum_credito;
			 
			 let dmonto_autorizado = nvl(dmonto_autorizado,0);
		  
		  --IF  nvl(dmonto_autorizado,'') = '' THEN	 
		  IF  dmonto_autorizado = 0 THEN	 
		     --select nvl(monto_otorgado,0) INTO dmonto_autorizado
			 select monto_otorgado INTO dmonto_autorizado
				from bdicred:sd_maesdos
				where empresa = "001"
				and num_credito = vnum_credito;
				
				let dmonto_autorizado = nvl(dmonto_autorizado,0); 
		  END IF;	 
		  
		  --LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'5109'||
          --                    lpad(round(dmonto_autorizado,0),9,"0");
		  --LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'5109'||      --RQM 09 502
          --                    lpad(round(dmonto_autorizado,0),9,"0");
          --LET tb_monto_originacion = round(dmonto_autorizado,0);
			 
      --ELSE       
          --LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'5109'||
          --                  lpad(round(d_monto_originacion,0),9,"0");
          --LET tb_monto_originacion = round(d_monto_originacion,0);
      END IF;
	  --Monto del Credito en la originacio IPCB
	  -- Mover este query que estaba mas abajo para tener el dato de dmonto_autorizado, para ser usado en el limite de credito si este es 1, '' o nulo
		 
    -- Agregar Limite de Credito
        --if (vmonto_otorgado > 0 and vmonto_otorgado < 1) then
		if (vmonto_otorgado >= 0 and vmonto_otorgado <= 1) then --RQM 09 599 Hallazgos BANXICO 2021 - MACF
            --let vmonto_otorgado=1;  
            IF vstatus_cred NOT IN ('FF','FI','FC','CV') THEN 
			
				IF cNumProducto = '8100' THEN
				
					   IF nvl(cCredExterno_bis,'') = '' THEN
						  select credito_externo
							into cCredExterno_bis
							from bdicred:sd_maecred
						   where num_credito = vnum_credito
							 and empresa = vempresa;
					   END IF;
					   
					   select nvl(monto_solicitado,0)
						 into dmonto_autorizado                   			   
						 from bdisolic:ss_solicitudes 
						where num_solicitud = cCredExterno_bis
						  and empresa = vempresa;
						  
						IF nvl(dmonto_autorizado,'') = '' or  dmonto_autorizado is null THEN
						   LET dmonto_autorizado = 0;
						END IF;
						 
						LET vmonto_otorgado =  dmonto_autorizado;

				ELSE
				  LET vmonto_otorgado =  dmonto_autorizado;
				END IF;
				
 			END IF;
        end if;

		 
		IF vmonto_otorgado is null or vmonto_otorgado = '' THEN
			let vsegmento3_tl = trim(vsegmento3_tl)||'2300';
			let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2300';  --RQM 09 502
		ELSE
			let vsegmento3_tl = trim(vsegmento3_tl)||'2309'||
								 lpad(round(vmonto_otorgado,0),9,"0");
			let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2309'||      --RQM 09 502
								 lpad(round(vmonto_otorgado,0),9,"0");
			let tb_monto_otorgado    = round(vmonto_otorgado,0);
		END IF;

    -- Agregar Saldo vencido
       if vClaveObserv_tarjeta  = 'LS' then --RQM 09 502 MACF
		  let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2400';
       	  let tb_saldo_venc_2 = 0; 
	   end if;

	   if (vsaldo_venc > 0 and vsaldo_venc < 1) then
		  let vsaldo_venc=1;
	   end if;
	 
	   IF vIndProceso = 'Q' THEN --RQM 09 549
	   let tb_saldo_venc = vMontoQuita;
			let vsegmento3_tl = trim(vsegmento3_tl)||'2409'|| 
								lpad(round(tb_saldo_venc,0),9,"0");
	   ELSE
		   if  nvl(vsaldo_venc,'') = '' then --- RQM 09 467_Version 14
				let vsegmento3_tl = trim(vsegmento3_tl)||'2400';
		   else
				let vsegmento3_tl = trim(vsegmento3_tl)||'2409'||
								 lpad(round(vsaldo_venc,0),9,"0");
				let tb_saldo_venc        = round(vsaldo_venc,0);
		   end if;
	   end if;

	   
        -- Agregar Numero de Pagos Vencidos
       if (vsaldo_venc <= 0 or vcuotas_ven is null) then
           let vcuotas_ven = 0;
       end if;

       let vsegmento3_tl = trim(vsegmento3_tl)||'2504'||
                         lpad(vcuotas_ven,4,"0");
	   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2504'||  --RQM 09 502
                         lpad(vcuotas_ven,4,"0");	
       let tb_cuotas_ven        = vcuotas_ven;

    -- Agregar Forma de Pago
       -- UR = consideran creditos que no tuvieron movimientos en el 
       --      mes de generacion de la cinta (del dia 1 al ultimo dia del mes que se reporta)
       -- 00 = se consideran creditos que fueron aperturados en el mes de 
       --      generacion de la cinta (del dia 1 al ultimo dia del mes que se reporta)
       -- 01 = se consideran creditos que estan al corriente y que hayan tenido movimientos. 
       --      Asi mismo se incluyen los creditos que fueron aperturados en el mes de generacion 
       --      de la cinta (del dia 1 al ultimo dia del mes que se reporta) y hayan tenido movimientos en ese mismo mes
       -- 02 = Atraso de 01 a 29 dias
       -- 03 = Atraso de 30 a 59 dias
       -- 04 = Atraso de 60 a 89 dias
       -- 05 = Atraso de 90 a 119 dias
       -- 06 = Atraso de 120 a 149 dias
       -- 07 = Atraso de 150 hasta 12 meses
       -- 96 = atraso de 12 meses
       -- 97 = Cuenta con deuda parcial o total sin recuperar
       -- 99 = Fraude cometido por el cliente 

       --if (vstatus_cred = 'FC' or vstatus_cred = 'FF') then RQM 09 343-0
       if (vstatus_cred = 'FC' or vstatus_cred = 'FF' or vstatus_cred = 'FI' ) then
           let vfechaultpago = dtFechaApRee;
           let vdiasatraso = 0;
       end if;

	   if (vmontoinsoluto < 0 or vmontoinsoluto is null) then
		  let vmontoinsoluto = 0;
--IPCB 23092013-- INTEGRA REDONDEO A UNO DEL MONTO INSLOUTO      
           elif (vmontoinsoluto > 0 and vmontoinsoluto < 1) then
                   let vmontoinsoluto =1;
	   end if;
	   
       if vClaveObserv_tarjeta  = 'LS' then --RQM 09 502 MACF
		   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2602UR';
		   let tb_mop_2        = 'UR';	
	   end if;
	   

		if vIndProceso = 'Q' then --RQM 09 549
			let vmop = "97";
		else
		   if (vfecha_apertura < ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultpago < ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultcompra < ((vfecha_hoy + 1 units day) - 1 units month)) and vdiasatraso = 0 and vmontoinsoluto <= 0 then
			  let vmop = "UR";
		   elif (vfecha_apertura >= ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultpago < ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultcompra < ((vfecha_hoy + 1 units day) - 1 units month)) and vdiasatraso = 0 then
			  let vmop = "00";
		   elif (vdiasatraso  =   0) then
			  let vmop = "01";
		   elif (vdiasatraso >=   1 and vdiasatraso <=  29) then
			  let vmop = "02";
		   elif (vdiasatraso >=  30 and vdiasatraso <=  59) then
			  let vmop = "03";
		   elif (vdiasatraso >=  60 and vdiasatraso <=  89) then
			  let vmop = "04";
		   elif (vdiasatraso >=  90 and vdiasatraso <= 119) then
			  let vmop = "05";
		   elif (vdiasatraso >= 120 and vdiasatraso <= 149) then
			  let vmop = "06";
		   elif (vdiasatraso >= 150 and vdiasatraso <= (abs(date(vfecha_hoy)) - abs(date(vfecha_hoy - 1 units year))) - 1) then
			  let vmop = "07";
		   else
			  let vmop = "96";
		   end if
		end if;

		   let vsegmento3_tl = trim(vsegmento3_tl)||'2602'||vmop;
		   let tb_mop               = vmop;

	   
		--IPCB27sep2013 Integra consulta a sd_maecredcont para validar estatus de credito anterior 
		--if vstatus_cred = 'AA' or (vstatus_cred = 'VP' and vsaldo_venc <= 0) Then
		if ( vstatus_cred IN('AA','E1','VP') and vsaldo_venc <= 0) Then   -- IFRS MACF
		--if (cNumProducto = '6001' or cNumProducto = '6600' or cNumProducto = '8500') then
			 if (cNumProducto = '6001' or cNumProducto = '6600' or cNumProducto = '8500' or cNumProducto = '7000' or cNumProducto = '8100') then   -- Agregar Platinum y Oro MACF 20210122
				select status_cred  
				into vstatus_credAnt
				from bdicred:sd_maecredcont 
				where empresa = '001'
				and fecha = vfecha_fin_mes_ant  --'2013/07/31'
				and num_credito = vnum_credito;
			 elif (cNumProducto = '6011') then   
				select status_cred, nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
					 nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
					 nvl(mto_venc_int,0),0)   
				into vstatus_credAnt, vsaldo_vencAnt
				from bdicred:sd_maecredcontcrd a inner join bdicred:sd_maesdoscontcrd b
				on a.num_credito = b.num_credito
				where a.empresa = '001'  and b.empresa = '001'
				and a.fecha = b.fecha 
				and a.fecha = vfecha_fin_mes_ant
				and a.num_credito = vnum_credito;
			end if;
		end if;
 
   
        -- Agregar clave de observacion
        let tb_clave_obs = '';
	 

	    -- RQM 09 502 MACF  clave de observacion
		if vClaveObserv_tarjeta = 'LS' then
		    LET vsegmento3_tl_2 = TRIM(vsegmento3_tl_2)||'3002'|| vClaveObserv_tarjeta;
			LET tb_clave_obs_2               = vClaveObserv_tarjeta;
		end if;	 
		
			IF (vIndProceso = 'Q' AND vmop = '97') THEN --RQM 09 549
				LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'LC';
				LET tb_clave_obs               = 'LC';
			elif (vstatus_cred = 'CV') then
				let vsegmento3_tl = trim(vsegmento3_tl)||'3002'||'CV';
				let tb_clave_obs               = 'CV';
			--elif (vstatus_cred = 'FF') then RQM 09 343-0
			elif (vstatus_cred IN ('FF','FI')) then
				   LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'CC';
				   LET tb_clave_obs               = 'CC';
			elif (vstatus_cred = 'FC') THEN
				   LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'RV';
				   LET tb_clave_obs               = 'RV';
	--IPCB 090913: Se agrega la asignacion de la clave de observacion 'PC'
			elif (vmop >= '02' and vmop <> 'UR') then
				   LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'PC';
				   LET tb_clave_obs               = 'PC';
	--IPCB27sep2013 Se agrega la asignacion de la clave de observacion 'EL'
			--elif ((vstatus_credAnt in ('BT','BA') and vstatus_cred = 'AA')
			--or ((vstatus_credAnt= 'VP' and vsaldo_vencAnt > 0) 
			--		   and (vstatus_cred = 'VP' and vsaldo_venc <= 0))) then 
			elif (vstatus_credAnt in ('BT','BA','VP','E1','E2','E3') AND vsaldo_vencAnt > 0 AND vstatus_cred in ('AA','E1','VP') AND vsaldo_venc <= 0) THEN           -- IFRS MACF
				   LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'EL';
				   LET tb_clave_obs               = 'EL';
			end if; 



	 
	 
	 
--IPCB RQM 09 375--INICIO --Proceso trascodificacio platino Marzo2015// Oro Agosto 2018
        /*IF cNumProducto in  ('7000','8100') and (vfecha_apertura >= vfecha_ini  and vfecha_apertura <= vfecha_hoy ) THEN
         let vsegmento3_tl = trim(vsegmento3_tl)||'41'||
             lpad(length(trim(cCredExterno)),2,"0")||trim(cCredExterno);
        ELSE
		 Let cCredExterno = '';
        END IF;
		-- let tb_num_credito_ext       = trim(vnum_credito);
		*/ --indica Angeles Corvera que esto se sustituye por lo del RQM 09 502
		
		--- RQM 09 502 MACF
		--- Codigo anterior comentado se sustituye por el siguiente:   
		
		if cNumProducto in('6001','6600','7000','8100','8500','5400') then
		   --- RQM 09 502 MACF    
		   if iEjecucion_primera_vez = '1' then
			   let vsegmento3_tl = trim(vsegmento3_tl)||'41'||            -- PRIMERA EJECUCION
			   lpad(length(trim(vnum_credito)),2,"0")||trim(vnum_credito);
			   let tb_num_credito_ext       = trim(vnum_credito);
                -- Validar si la tarjeta reportada es diferente a la actual y no hubo cancelacion por Robo o extravio
			elif cTarjetaCambiada = 'S' and vClaveObserv_tarjeta = '' then
                   -- Significa que ya se asigno una nueva y no hay clave obs LS				
				   let vsegmento3_tl = trim(vsegmento3_tl)||'41'||
                    lpad(length(trim(vnum_tarjeta_ant)),2,"0")||trim(vnum_tarjeta_ant);
				   let tb_num_credito_ext       = trim(vnum_tarjeta_ant);
			else
			  let cCredExterno = '';
			  let tb_num_credito_ext = '';
            end if;
		end if;
		
	
 		 
--IPCB RQM 09 375--FIN    --Proceso trascodificacio
    -- NUEVOS CAMPOS
    -- FECHA DE PRIMER INCUMPLIMIENTO
       if vfecha_vencido is null then let vfecha_vencido = date(1); end if;

       let vano = year(vfecha_vencido);
       let vmes = lpad(month(vfecha_vencido),2,"0");
       let vdia = lpad(day(vfecha_vencido),2,"0");
	   
	   IF vmop in ('00','01','UR') THEN  --RQM 09 467_Version 14
		LET vsegmento3_tl = TRIM(vsegmento3_tl)||'430801011900';
		LET vsegmento3_tl_2 = TRIM(vsegmento3_tl_2)||'430801011900';  -- RQM 09 502
		LET tb_fecha_vencimiento = '01011900';
	   ELSE
		LET vsegmento3_tl = TRIM(vsegmento3_tl)||'4308'||vdia||vmes||vano;
		LET vsegmento3_tl_2 = TRIM(vsegmento3_tl_2)||'4308'||vdia||vmes||vano;  --RQM 09 502
		LET tb_fecha_vencimiento = vdia||vmes||vano;
	   END IF;
	   
    -- SALDO INSOLUTO DEL PRINCIPAL
       LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'4410'||
                            lpad(round(vmontoinsoluto,0),10,"0");
	   LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'4410'||      --RQM 09 502
                            lpad(round(vmontoinsoluto,0),10,"0");
       let tb_monto_insoluto = round(vmontoinsoluto,0);

    -- MONTO DE ULTIMO PAGO
       LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'4509'||
                            lpad(round(vmontolutpago,0),9,"0");
	   LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'4509'||    --RQM 09 502
                            lpad(round(vmontolutpago,0),9,"0");	
       let tb_ultimo_pago = round(vmontolutpago,0);
	   
	-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
		
	   IF vdiasatraso < 0   THEN LET vdiasatraso = 0;   END IF;	
	   IF vdiasatraso > 999 THEN LET vdiasatraso = 999; END IF;	
		
	   LET vsegmento3_tl    = TRIM(vsegmento3_tl)||'4903'||
                            lpad(vdiasatraso,3,"0");
	   LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'4903'||    
                            lpad(vdiasatraso,3,"0");	
       let tb_dias_atraso = vdiasatraso;

	-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN	
	   
    -- PLAZO EN MESES RQM 09 467_Version 14
       IF cNumProducto = '6011' THEN  
         --LET dplazo_meses = iplazo_meses/30.4;
         --LET dplazo_meses = ROUND((iplazo_meses/30.4),2);
         --LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'50'|| trim(cplazo_meses) || '.00';  
                              --lpad(length(trim(cplazo_meses)),2,"0")||cplazo_meses;
                              
         let vsegmento3_tl  = TRIM(vsegmento3_tl)||'500'|| length(cplazo_meses)+3 || trim(cplazo_meses) || '.00';                       
         let tb_plazo_meses = trim(cplazo_meses);    
      ELSE
         LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'50040.00';
		 LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'50040.00';   --RQM 09 502
         let tb_plazo_meses = '0'; 
      END IF;

      --Monto del Credito en la originacio IPCB
      IF cNumProducto <> '6011' THEN
	      --RQM 09 599 Hallazgos BANXICO 2021 - MACF Query movido a la parte de arriba
          /*SELECT monto_solicitado INTO dmonto_autorizado
            FROM bdisolic:ss_solicitudes
           WHERE empresa = '001'
             AND num_solicitud = vnum_credito;
			 
			 let dmonto_autorizado = nvl(dmonto_autorizado,0);
		  
		  --IF  nvl(dmonto_autorizado,'') = '' THEN	 
		  IF  dmonto_autorizado = 0 THEN	 
		     --select nvl(monto_otorgado,0) INTO dmonto_autorizado
			 select monto_otorgado INTO dmonto_autorizado
				from bdicred:sd_maesdos
				where empresa = "001"
				and num_credito = vnum_credito;
				
				let dmonto_autorizado = nvl(dmonto_autorizado,0); 
		  END IF;*/	 
		  
		  LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'5109'||
                              lpad(round(dmonto_autorizado,0),9,"0");
		  LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'5109'||      --RQM 09 502
                              lpad(round(dmonto_autorizado,0),9,"0");
          LET tb_monto_originacion = round(dmonto_autorizado,0);
			 
      ELSE       
          LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'5109'||
                            lpad(round(d_monto_originacion,0),9,"0");
          LET tb_monto_originacion = round(d_monto_originacion,0);
      END IF;			 
    

       IF vsaldo_venc IS NULL THEN let vsaldo_venc = 0; END IF; 

       
    -- Fin
       let vsegmento3_tl = trim(vsegmento3_tl)||'9903FIN';
       let vsegmento3_tl = 'TL'||trim(vsegmento3_tl);
	   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'9903FIN';  --RQM 09 502
       let vsegmento3_tl_2 = 'TL'||trim(vsegmento3_tl_2);
 	   
--IPCB Abr15- Se modifica la validacio para integrar a la cinta los registros marcados con CSS en la concilia .
        --- VALIDAR CON RICARDO SI ESTA PARTE SEGUIRA EXISTIENDO - RQM 09 467_Version 14
       /* --QUITAR LA PARTE DEL INSERT A BR_BUROFISICAS_CONCILIA
	   if bmotivo = 1 then
           INSERT INTO bdiburo:br_burofisicas_concilia VALUES('001',cNumProducto,vnum_credito,'CSS',vfecha_hoy,
                    tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
                    tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
                    tb_codigo_pais, tb_nombre_empleador,tb_calle_pe,tb_colonia_pe,tb_delegacion_pe,tb_ciudad_pe,tb_estado_pe,tb_cod_postal_pe, tb_origen_razon_soc,  --RQM 09 467_Version 14  
                    tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar,
                    tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado,
                    tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota,
					tb_plazo_meses, tb_monto_originacion, --RQM 09 467_Version 14
					vstatus_cred,tb_monto_insoluto,
                    tb_num_credito_ext);
       else
    --Se validan CPs para la cinta de Buro
            IF iCP IS NULL THEN LET iCP = 0; END IF;
			
			IF iCP <= 0 THEN
                INSERT INTO bdiburo:br_burofisicas_concilia (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CPS',vfecha_hoy);
			END IF;
       end if;
	   */
			let vsegmento3_tl = replace(vsegmento3_tl,'TGD0924BAN',vclave_usu_bc);

            -- Validar si la cuenta no es nueva y se encuentra en br_burofisicas_base. RQI 21 220 MACF
	        -- cArma_PN, cArma_PA, cArma_PE
			
		let strpista = 'foreach 12';


			--- RQI 21 220 MACF
			IF vfecha_apertura >= vfecha_ini THEN
			
			   let vnumreg = vnumreg + 1;
			   insert into br_burofisicas
			   values(vnumreg,vsegmento_pn);
               
			   INSERT INTO br_burofisicas_base(num_credito,registro,tipo_segmento,fecha_reporte) 
			   VALUES(tb_num_credito,TRIM(vsegmento_pn),'PN',vfecha_hoy);
			ELSE
			  IF cArma_PN <> 'S' THEN
			     let vnumreg = vnumreg + 1;
			     insert into br_burofisicas
			     values(vnumreg,TRIM(vsegmento_pn_base));
			  ELSE
			     let vnumreg = vnumreg + 1;
			     insert into br_burofisicas
			     values(vnumreg,vsegmento_pn);
				 
				 UPDATE br_burofisicas_base SET registro =TRIM(vsegmento_pn), fecha_reporte = vfecha_hoy
				  WHERE num_credito = tb_num_credito AND tipo_segmento= 'PN';
				 
			  END IF;
			END IF;
        
		 IF vfecha_apertura >= vfecha_ini THEN

  		    let vnumreg = vnumreg + 1;
			insert into br_burofisicas
			values(vnumreg,vsegmento2_pa);
			
			INSERT INTO br_burofisicas_base(num_credito,registro,tipo_segmento,fecha_reporte) 
			   VALUES(tb_num_credito,TRIM(vsegmento2_pa),'PA',vfecha_hoy);
			
         ELSE
			  IF cArma_PA <> 'S' THEN
				  let vnumreg = vnumreg + 1;
				  insert into br_burofisicas
				  values(vnumreg,TRIM(vsegmento_pa_base));
			  ELSE
				  let vnumreg = vnumreg + 1;
				  insert into br_burofisicas
				  values(vnumreg,TRIM(vsegmento2_pa));
				  
				  UPDATE br_burofisicas_base SET registro =TRIM(vsegmento2_pa), fecha_reporte = vfecha_hoy
				   WHERE num_credito = tb_num_credito AND tipo_segmento= 'PA';
			  END IF;			 
			   
		  END IF;


	    IF vfecha_apertura >= vfecha_ini  THEN		

		    let vnumreg = vnumreg + 1; --RQM 09 467_Version 14  
			insert into br_burofisicas
			values(vnumreg,vsegmento_pe);
			
            INSERT INTO br_burofisicas_base(num_credito,registro,tipo_segmento,fecha_reporte) 
			   VALUES(tb_num_credito,TRIM(vsegmento_pe),'PE',vfecha_hoy);
			
		 ELSE
			  IF cArma_PE <> 'S' THEN
				  let vnumreg = vnumreg + 1;
				  insert into br_burofisicas
				  values(vnumreg,TRIM(vsegmento_pe_base));
			  ELSE
				  let vnumreg = vnumreg + 1;
				  insert into br_burofisicas
				  values(vnumreg,TRIM(vsegmento_pe));
				  
				  UPDATE br_burofisicas_base SET registro =TRIM(vsegmento_pe), fecha_reporte = vfecha_hoy
				   WHERE num_credito = tb_num_credito AND tipo_segmento= 'PE';
			  END IF;	
			  
		  END IF;
			
			let vnumreg = vnumreg + 1;
			insert into br_burofisicas
			values(vnumreg,vsegmento3_tl);
			

            --- RQI 21 220 MACF
		    IF vfecha_apertura >= vfecha_ini THEN		
--    let tb_fecha_nac=tb_fecha_nac;let tb_fecha_apertura=tb_fecha_apertura;let tb_fecha_ult_pago=tb_fecha_ult_pago;let tb_fecha_ult_compra=tb_fecha_ult_compra;let tb_fecha_cierre=tb_fecha_cierre;let tb_fecha_reporte=tb_fecha_reporte;let tb_fecha_vencimiento=tb_fecha_vencimiento;
-- Se agrega tabla para grabar informacion enviada
--IPCB 12mar14 - Se integran al insert vstatus_cred,cNumProducto
			   insert into br_burofisicas_describe
			   values (tb_num_credito, tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
					   tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
					   tb_codigo_pais, tb_nombre_empleador,tb_calle_pe,tb_colonia_pe,tb_delegacion_pe,tb_ciudad_pe,tb_estado_pe,tb_cod_postal_pe, tb_origen_razon_soc,  --RQM 09 467_Version 14  
					   tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar,
					   tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado,
					   tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota,tb_fecha_vencimiento,tb_monto_insoluto,tb_ultimo_pago,tb_plazo_meses,tb_monto_originacion,vstatus_cred,cNumProducto,tb_num_credito_ext,tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
					   tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN					   
					   );

                LET iRegsInsert = iRegsInsert+1;
			ELIF vindproceso = 'Q' THEN	-- RQM 09 549
				UPDATE br_burofisicas_describe SET estado_civil = tb_estado_civil,
				calle= tb_calle, colonia= tb_colonia, delegacion=tb_delegacion, ciudad=tb_ciudad, estado=tb_estado, cod_postal=tb_cod_postal, origen_dom=tb_codigo_pais,  --PA
				razon_social= tb_nombre_empleador, calle_pe=tb_calle_pe, colonia_pe=tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe, estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE	   
				clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, --TL
				tipo_producto= tb_tipo_producto, clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, 
				monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura, fecha_ult_pago= tb_fecha_ult_pago, 
				fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
				credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc,
				cuotas_ven= tb_cuotas_ven, mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento,
				monto_insoluto= tb_monto_insoluto, ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion,
				status_cred= vstatus_cred, num_producto= cNumProducto, credito_externo= tb_num_credito_ext, num_tarjeta= tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
				dias_atraso = tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				
				WHERE num_credito = tb_num_credito;
			   
				LET iRegsUpd = iRegsUpd+1;
            ELIF (cArma_PN = 'S' AND cArma_PA = 'S' AND cArma_PE = 'S') THEN	 
			   UPDATE br_burofisicas_describe SET estado_civil = tb_estado_civil, --PN
			   calle= tb_calle, colonia= tb_colonia, delegacion=tb_delegacion, ciudad=tb_ciudad, estado=tb_estado, cod_postal=tb_cod_postal, origen_dom=tb_codigo_pais,  --PA
			   razon_social= tb_nombre_empleador, calle_pe=tb_calle_pe, colonia_pe=tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe, estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE	   
			   clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, --TL
			   tipo_producto= tb_tipo_producto, clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, 
			   monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura, fecha_ult_pago= tb_fecha_ult_pago, 
			   fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
			   credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc,
			   cuotas_ven= tb_cuotas_ven, mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento,
			   monto_insoluto= tb_monto_insoluto, ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion,
			   status_cred= vstatus_cred, num_producto= cNumProducto, credito_externo= tb_num_credito_ext, num_tarjeta= tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
				dias_atraso = tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				
			   WHERE num_credito = tb_num_credito;
			   
			   LET iRegsUpd = iRegsUpd+1;
			ELIF (cArma_PN = 'S' AND cArma_PA = 'N' AND cArma_PE = 'S') THEN
			   UPDATE br_burofisicas_describe SET estado_civil = tb_estado_civil, --PN
			   --calle= tb_calle, colonia= tb_colonia, delegacion=tb_delegacion, ciudad=tb_ciudad, estado=tb_estado, cod_postal=tb_cod_postal, origen_dom=tb_codigo_pais,  --PA
			   razon_social= tb_nombre_empleador, calle_pe=tb_calle_pe, colonia_pe=tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe, estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE	   
			   clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, --TL
			   tipo_producto= tb_tipo_producto, clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, 
			   monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura, fecha_ult_pago= tb_fecha_ult_pago, 
			   fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
			   credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc,
			   cuotas_ven= tb_cuotas_ven, mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento,
			   monto_insoluto= tb_monto_insoluto, ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion,
			   status_cred= vstatus_cred, num_producto= cNumProducto, credito_externo= tb_num_credito_ext, num_tarjeta= tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
				dias_atraso = tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				   
			   WHERE num_credito = tb_num_credito;
			
			   LET iRegsUpd = iRegsUpd+1;
			ELIF (cArma_PN = 'S' AND cArma_PA = 'N' AND cArma_PE = 'N') THEN
			   UPDATE br_burofisicas_describe SET estado_civil = tb_estado_civil, --PN
			   --calle= tb_calle, colonia= tb_colonia, delegacion=tb_delegacion, ciudad=tb_ciudad, estado=tb_estado, cod_postal=tb_cod_postal, origen_dom=tb_codigo_pais,  --PA
			   --razon_social= tb_nombre_empleador, calle_pe=tb_calle_pe, colonia_pe=tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe, estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE	   
			   clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, --TL
			   tipo_producto= tb_tipo_producto, clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, 
			   monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura, fecha_ult_pago= tb_fecha_ult_pago, 
			   fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
			   credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc,
			   cuotas_ven= tb_cuotas_ven, mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento,
			   monto_insoluto= tb_monto_insoluto, ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion,
			   status_cred= vstatus_cred, num_producto= cNumProducto, credito_externo= tb_num_credito_ext, num_tarjeta= tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
				dias_atraso = tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				   
			   WHERE num_credito = tb_num_credito;
			   
			   LET iRegsUpd = iRegsUpd+1;
			ELIF (cArma_PN = 'S' AND cArma_PA = 'S' AND cArma_PE = 'N') THEN
			   UPDATE br_burofisicas_describe SET estado_civil = tb_estado_civil, --PN
			   calle= tb_calle, colonia= tb_colonia, delegacion=tb_delegacion, ciudad=tb_ciudad, estado=tb_estado, cod_postal=tb_cod_postal, origen_dom=tb_codigo_pais,  --PA
			   --razon_social= tb_nombre_empleador, calle_pe=tb_calle_pe, colonia_pe=tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe, estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE	   
			   clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, --TL
			   tipo_producto= tb_tipo_producto, clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, 
			   monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura, fecha_ult_pago= tb_fecha_ult_pago, 
			   fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
			   credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc,
			   cuotas_ven= tb_cuotas_ven, mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento,
			   monto_insoluto= tb_monto_insoluto, ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion,
			   status_cred= vstatus_cred, num_producto= cNumProducto, credito_externo= tb_num_credito_ext, num_tarjeta= tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
				dias_atraso = tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				   
			   WHERE num_credito = tb_num_credito;
			   
			   LET iRegsUpd = iRegsUpd+1;
			ELIF (cArma_PN = 'N' AND cArma_PA = 'S' AND cArma_PE = 'S') THEN
			   UPDATE br_burofisicas_describe SET --estado_civil = tb_estado_civil, --PN
			   calle= tb_calle, colonia= tb_colonia, delegacion=tb_delegacion, ciudad=tb_ciudad, estado=tb_estado, cod_postal=tb_cod_postal, origen_dom=tb_codigo_pais,  --PA
			   razon_social= tb_nombre_empleador, calle_pe=tb_calle_pe, colonia_pe=tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe, estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE	   
			   clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, --TL
			   tipo_producto= tb_tipo_producto, clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, 
			   monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura, fecha_ult_pago= tb_fecha_ult_pago, 
			   fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
			   credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc,
			   cuotas_ven= tb_cuotas_ven, mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento,
			   monto_insoluto= tb_monto_insoluto, ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion,
			   status_cred= vstatus_cred, num_producto= cNumProducto, credito_externo= tb_num_credito_ext, num_tarjeta= tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
				dias_atraso = tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				   
			   WHERE num_credito = tb_num_credito;
			   
			   LET iRegsUpd = iRegsUpd+1;
			ELIF (cArma_PN = 'N' AND cArma_PA = 'S' AND cArma_PE = 'N') THEN
			   UPDATE br_burofisicas_describe SET --estado_civil = tb_estado_civil, --PN
			   calle= tb_calle, colonia= tb_colonia, delegacion=tb_delegacion, ciudad=tb_ciudad, estado=tb_estado, cod_postal=tb_cod_postal, origen_dom=tb_codigo_pais,  --PA
			   --razon_social= tb_nombre_empleador, calle_pe=tb_calle_pe, colonia_pe=tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe, estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE	   
			   clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, --TL
			   tipo_producto= tb_tipo_producto, clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, 
			   monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura, fecha_ult_pago= tb_fecha_ult_pago, 
			   fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
			   credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc,
			   cuotas_ven= tb_cuotas_ven, mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento,
			   monto_insoluto= tb_monto_insoluto, ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion,
			   status_cred= vstatus_cred, num_producto= cNumProducto, credito_externo= tb_num_credito_ext, num_tarjeta= tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
				dias_atraso = tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				   
			   WHERE num_credito = tb_num_credito;
			   
			   LET iRegsUpd = iRegsUpd+1;
			ELIF (cArma_PN = 'N' AND cArma_PA = 'N' AND cArma_PE = 'S') THEN
			   UPDATE br_burofisicas_describe SET --estado_civil = tb_estado_civil, --PN
			   --calle= tb_calle, colonia= tb_colonia, delegacion=tb_delegacion, ciudad=tb_ciudad, estado=tb_estado, cod_postal=tb_cod_postal, origen_dom=tb_codigo_pais,  --PA
			   razon_social= tb_nombre_empleador, calle_pe=tb_calle_pe, colonia_pe=tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe, estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE	   
			   clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, --TL
			   tipo_producto= tb_tipo_producto, clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, 
			   monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura, fecha_ult_pago= tb_fecha_ult_pago, 
			   fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
			   credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc,
			   cuotas_ven= tb_cuotas_ven, mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento,
			   monto_insoluto= tb_monto_insoluto, ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion,
			   status_cred= vstatus_cred, num_producto= cNumProducto, credito_externo= tb_num_credito_ext, num_tarjeta= tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
				dias_atraso = tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				   
			   WHERE num_credito = tb_num_credito;
			   
			   LET iRegsUpd = iRegsUpd+1;
			ELIF (cArma_PN = 'N' AND cArma_PA = 'N' AND  cArma_PE = 'N') THEN  --Actualiza solamente la info de TL
			   UPDATE br_burofisicas_describe SET --estado_civil = tb_estado_civil, --PN
			   --calle= tb_calle, colonia= tb_colonia, delegacion=tb_delegacion, ciudad=tb_ciudad, estado=tb_estado, cod_postal=tb_cod_postal, origen_dom=tb_codigo_pais,  --PA
			   --razon_social= tb_nombre_empleador, calle_pe=tb_calle_pe, colonia_pe=tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe, estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE	   
			   clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, --TL
			   tipo_producto= tb_tipo_producto, clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, 
			   monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura, fecha_ult_pago= tb_fecha_ult_pago, 
			   fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
			   credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc,
			   cuotas_ven= tb_cuotas_ven, mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento,
			   monto_insoluto= tb_monto_insoluto, ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion,
			   status_cred= vstatus_cred, num_producto= cNumProducto, credito_externo= tb_num_credito_ext, num_tarjeta= tb_num_tarjeta,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
				dias_atraso = tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN				   
			   WHERE num_credito = tb_num_credito;
			   
			   LET iRegsUpd = iRegsUpd+1;
			END IF;
            -- RQM 09 502 MACF Si hubo cambio de tarjeta y la causa fue Robo o Extravio (cve observ LS) se inserta otro registro casi identico
			-- pero con saldos en ceros para cerrar esa TDC ante las SICs
			if cTarjetaCambiada = 'S' then
			
			    if vClaveObserv_tarjeta = 'LS' then
					let vsegmento3_tl_2 = replace(vsegmento3_tl_2,'TGD0924BAN',vclave_usu_bc);
				
                    IF cArma_PN = 'N' THEN  --- RQI 21 220 MACF
					   let vnumreg = vnumreg + 1;
					   insert into br_burofisicas
					   values(vnumreg,vsegmento_pn_base);
                    ELSE
                       let vnumreg = vnumreg + 1;
					   insert into br_burofisicas
						values(vnumreg,vsegmento_pn);
                    END IF;

                    IF cArma_PA = 'N' THEN  --- RQI 21 220 MACF
						let vnumreg = vnumreg + 1;
						insert into br_burofisicas
						values(vnumreg,vsegmento_pa_base);
					ELSE
					    let vnumreg = vnumreg + 1;
					    insert into br_burofisicas
					    values(vnumreg,vsegmento2_pa);
                    END IF;
					
                    IF cArma_PE = 'N' THEN   --- RQI 21 220 MACF
						let vnumreg = vnumreg + 1; --RQM 09 467_Version 14  
						insert into br_burofisicas
						values(vnumreg,vsegmento_pe_base);
					ELSE
					
					   let vnumreg = vnumreg + 1; --RQM 09 467_Version 14  
					    insert into br_burofisicas
					    values(vnumreg,vsegmento_pe);
                    END IF;
					
					let vnumreg = vnumreg + 1;
					insert into br_burofisicas
					values(vnumreg,vsegmento3_tl_2);
					
					insert into br_burofisicas_describe
					values (tb_num_credito, tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
						   tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
						   tb_codigo_pais, tb_nombre_empleador,tb_calle_pe,tb_colonia_pe,tb_delegacion_pe,tb_ciudad_pe,tb_estado_pe,tb_cod_postal_pe, tb_origen_razon_soc,
						   tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar_2,
						   tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre_2, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual_2, tb_monto_otorgado,
						   tb_saldo_venc_2, tb_cuotas_ven, tb_mop_2,tb_clave_obs_2, vrea_cal_cuota,tb_fecha_vencimiento,tb_monto_insoluto,tb_ultimo_pago,tb_plazo_meses,tb_monto_originacion,vstatus_cred,cNumProducto,tb_num_credito_ext,tb_num_tarjeta_ant,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
					       tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN					   
						   );
			    end if;
				
				--Antes de terminar, si la tarjeta cambio respecto a la enviada anteriormente actualizar la cuenta con la nueva tarjeta
				if vnum_tarjeta <> '0000000000000000' then
					update bdiburo:br_bitacora_tarjeta
					   set num_tarjeta =  vnum_tarjeta, cambio = 'S', fecha_upd = vfecha_hoy,
					   tarjeta_anterior = vnum_tarjeta_ant                                      -- RQM 09 599 Hallazgos Banxico -MACF
					 where num_credito = vnum_credito;
				else
				    update bdiburo:br_bitacora_tarjeta
					   set num_tarjeta =  '', cambio = 'X', fecha_upd = vfecha_hoy
					 where num_credito = vnum_credito; 
				end if;
				
			end if;
					   
		    let contador_commit = contador_commit  + 1;
			let actualiza_esta = actualiza_esta + 1;

       let cNumProducto = '';  let cCredExterno = '';

	   
       IF (contador_commit >= 5000) THEN
          COMMIT WORK;
     /*     if actualiza_esta<500000 and mod(actualiza_esta,30000)=0 then
             UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas;
             UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_describe;
             UPDATE STATISTICS medium for table "informix".br_burofisicas_concilia;
          end if;*/
          LET contador_commit = 0; 
          BEGIN WORK;
       END IF;

      LET scalle_conocido = 0;
      LET cplazo_meses = '';
      LET vprofesion = '';
      LET cpais = '';
      LET vclave_ciudad = '';
      LET vclave_edo = '';
      LET cnombre_empleador = '';
      LET dmonto_autorizado = 0;
      LET cTarjetaCambiada = '';
	  
	  LET vnum_tarjeta = '';  --agregar 20190303
      LET vnum_tarjeta_ant = ''; --agregar 20190303
	  LET vClaveObserv_tarjeta = ''; --agregar 20190304
	  
	  LET vnumeroextcalle    = '';
      LET vnumerointcalle    = '';
      LET vnombrecalle       = '';
      LET vnumeroextcalle_pe   = '';
      LET vnumerointcalle_pe   = ''; 
      LET vnombrecalle_pe      = '';
      LET vCuentaExiste        = '';
	  
      LET vsegmento_pn_base  = '';
	  LET vsegmento_pa_base  = '';
	  LET vsegmento_pe_base  = '';
	  LET cArma_PN = '';
	  LET cArma_PA = '';
      LET cArma_PE = '';
	  LET tb_num_credito = '';
	  LET tb_monto_pagar = 0;
	  LET vnum_credito = '';
	  LET vestado_civil_prev = '';
	  LET vrazon_social_prev = '';
	  LET vstatus_credAnt = "";
	  LET vsaldo_vencAnt = 0;
	  
      end foreach
      
	  	let strpista = 'finalizamos el foreach';

	  
  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;
  LET sCommit = 0;
  
 
  	let strpista = 'antes de crear los indices';


  IF NOT EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_br_burofisicas' 
				AND tabid = (SELECT tabid 
								FROM systables WHERE tabname = 'br_burofisicas'))
		THEN
		CREATE INDEX "informix".idx_br_burofisicas   ON "informix".br_burofisicas(numreg); --in dbs_movhis_idx5 online;
	END IF;

 IF NOT EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_br_burofisicas_describe_numtarj' 
				AND tabid = (SELECT tabid 
								FROM systables WHERE tabname = 'br_burofisicas_describe'))
		THEN
		CREATE INDEX "informix".idx_br_burofisicas_describe_numtarj  ON "informix".br_burofisicas_describe(num_tarjeta); --in dbs_movhis_idx5 	online;
  	END IF;



  --CREATE INDEX "informix".idx_br_burofisicas_describe ON "informix".br_burofisicas_describe(num_credito) in dbs_movhis_idx5 online;  --Ya debe existir por los UPD. RQI 21 220 MACF 
  --CREATE INDEX "informix".inxburoconcilia             ON "informix".br_burofisicas_concilia(empresa, num_producto, num_credito, motivo, fecha_cinta) in dbs_movhis_idx5 online;

	let strpista = 'despues de crear los indeces';

  -- JAHJ  
  IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_br_burofisicas' 
				AND tabid = (SELECT tabid 
								FROM systables WHERE tabname = 'br_burofisicas'))
		THEN
			LET vindicador_exec = '0';
	END IF;

  IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_br_burofisicas_describe_numtarj' 
				AND tabid = (SELECT tabid 
								FROM systables WHERE tabname = 'br_burofisicas_describe'))
		THEN
			LET vindicador_exec = '0';
	END IF;
  
  BEGIN; -- JAHJ  TERMINAMOS PROCESO
				UPDATE bdiburo:br_param
					SET valor = '0' 
					WHERE cod_param = 170;
  COMMIT;
  
  
  
  update statistics medium for table "informix".br_burofisicas;
  update statistics medium for table "informix".br_burofisicas_describe;
  --update statistics medium for table "informix".br_burofisicas_concilia;
  
--temporal se inhabilita solo para pruebas
  --EXECUTE PROCEDURE burofisicas_concilia(vfecha_reporte) INTO vcodret;
--temporal se inhabilita solo para pruebas

  drop table sepomex; 
  drop table creditos;     --- Comentar para pruebas solamente RQM 09 467_Version 14
  drop table temp_creditos2;
  drop table cred_bqc_tdc;


    --let cMensajeFin = 'Creditos procs. ' || iTotalProcesados;
    let cMensajeFin = 'Creditos procs. ' || iTotalProcesados || ' I= ' || iRegsInsert || '- U= '|| iRegsUpd;
    /* --- SOLO PRUEBAS
    LET vHora = ''; LET vDia1 = '';
     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vDia1 
      from sysmaster:sysshmvals;

     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora 
      from sysmaster:sysshmvals;

      INSERT INTO bdiburo:br_cronometro(accion,fecha,hora) values('Final',vDia1, vHora);
    --- SOLO PRUEBAS  */
    CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '03') RETURNING vcodret2; 
	
		let strpista = 'acabamos';
  return vcodret,cMensajeFin;
END;
end procedure
DOCUMENT
'Fecha: 20201127',
'Modif: Optimizar proceso para reducir tiempo de ejecucion',
'Autor: Marco A. Campos',
'Fecha: 20210122',
'Modificacion: Agregar los productos Platinum(7000) y ORO(8100) en validacion de estatus de credito anterior.',
'Autor: Marco A. Campos',
'Fecha: 20240313',
'Modificacion: Se habilita una bandera para determinar si el proceso termina correctamente',
'Autor: Jose Alejandro Hernandez';

CREATE PROCEDURE "informix".burofisicas_cnr() 
       returning char(5),
                 char(50);
				 
--EXECUTE PROCEDURE "informix".burofisicas_cnr();

   define vcodret        char(5);
   define vcodret2       char(5);
   define vfecha_hoy     date;
--jom ini
   define vcredito_maximo   decimal(18,2);
   define vcredito_maximo2  decimal(18,2);
   define vrea_cal_cuota    integer;
--jom fin
   define vmoneda        char(2);
   define vmonto         decimal(18);
   define vlinea_prod    decimal(18,2);
   define vheader        char(150);
   define vheader1       char(70);
   define vsegmento_pn   char(375);
   define vsegmento1_pn  char(375);
   define vsegmento_pa   char(326);
   define vsegmento2_pa  char(326);
   define vsegmento_tl   char(436);
   define vsegmento3_tl  char(436);
   define vsegmento4_tr  char(255);
   define vsegmento5     char(253);
   define vlongitud      integer;
   define vapell_paterno char(26);
   define vapell_materno char(26);
   define vnombre1       char(26);
   define vnombre2       char(26);
   define vfecha_nac     date;
   define vano           char(4);
   define vmes           char(2);
   define vdia           char(2);
   define vrfc           char(13);
   define vfecha_alta    date;
   define vnacionalidad  char(3);
   define vresidencia    char(1);
   define vestado_civil  char(1);
   define vsexo          char(1);
   define vcalle,vcalle1 char(40);
   define vcolonia       char(40);
   define vmunicipio     char(3);
   define vdelegacion    char(40);
   define vdelegacion1   char(3);
   define vestado        char(4);
   define vcod_postal    char(10);
   define vnum_credito   char(25);
   define vnum_tarjeta   char(25);
   define vtp_linea      char(4);
   define vdivisa        char(2);
   define vnum_pagos     char(5);
   define vfrecuencia    char(1);
   define vfecha_apertura date;
   define vfecha_pago,vfecha_cuota    date;
   define vfecha_finiq   date;
   define vnumcte        char(20);
   define vencabezado1   char(4);
   define vversion       char(2);
   define vclave_usu     char(10);
   define vclave_usu_bc  char(10);
   define vnombre_usu    char(16);
   define vciclo         char(2);
   define vfecha_reporte char(8);
   define vuso_futuro    char(10);
   define vinf_adicional char(98);
   define vsql           char(200);
   define varchivo       char(60);
   define varchivo_des   char(60);
   define i              smallint;
   define vfecha_ini     date;
   define vfecha_fin_mes_ant date;
   define vstatus_cred   char(2);
   define vpago_cap, vpago_int date;
   define vsiglas_edo    char(4);
   define vsigla_div     char(2);
   define vfrecpago      char(1);
   define vcuota_cap     integer;
   define vmin_cuota,vcuota_int smallint;
   define vcuotas_vencap,vcuotas_venint,vcuotas_ven smallint;
   define vmonto_otorgado, vsaldo_vig, vsaldo_venc,
          vsaldo_actual,vmonto_pago,v_interes decimal(18,2);
   define vfecha_cap, vfecha_int, vfecha_venc, vfecha_pricuo,vfechacuota date;
   define vdiasvenc smallint;
   define vmop char(2);
   define vnumreg integer;
   define vnumreg_bc integer;
   define nombre_estado char(30);
   define existe smallint;
   define vquita char(40);
   define existe1 smallint;
   define vespacio char(1);
   define existecod smallint;
   define vciudad        char(40);
   define yaexiste    smallint;
   define vruta_interfase      char(200);
   define vsecuencia smallint;
   define hueco smallint;
   define vmanzana smallint;
   define vandador smallint;
   define vlote smallint;
   define vedificio smallint;
   define ventrada smallint;
   define vcodini,vcodfin,vcod_postala  integer;
   define vdiacuota smallint;
   define vreg_proc INTEGER;
   define vtot_proc INTEGER;
   define contador_commit INTEGER;
   DEFINE sCommit      SMALLINT;
   define contador_stat INTEGER;
   define actualiza_esta integer;
   define iTotalProcesados integer;

   define bmotivo integer ; --IPCB Abr15 -para identificar que le falta el segmento de direccion

-- Agrega variables para tabla de datos en texto
-- Segmento PN
   define tb_apell_paterno char(26);
   define tb_apell_materno char(26);
   define tb_nombre1       char(26);
   define tb_nombre2       char(26);
   define tb_fecha_nac     char(08);
   define tb_rfc           char(13);
   define tb_nacionalidad  char(03);
   define tb_estado_civil  char(1);
   define tb_sexo          char(1);

-- Segmento PA
   define tb_calle         char(40);
   define tb_colonia       char(40);
   define tb_delegacion    char(40);
   define tb_ciudad        char(40);
   define tb_estado        char(4);
   define tb_cod_postal    char(10);
   define tb_codigo_pais   char(2);  --RQM 09 467_Version 14  

-- Segmento TL
   define tb_clave_usu         char(10);
   define tb_nombre_usu        char(16);
   define tb_num_credito       char(25);
   define tb_responsabilidad   char(01);
   define tb_tipo_cuenta       char(01);
   define tb_tipo_producto     char(02);
   define tb_clave_monetaria   char(02);
   define tb_num_pagos         char(05);
   define tb_frecpago          char(01);
   define tb_monto_pagar       decimal(18);
   define tb_fecha_apertura    char(08);
   define tb_fecha_ult_pago    char(08);
   define tb_fecha_ult_compra  char(08);
   define tb_fecha_cierre      char(08);
   define tb_fecha_reporte     char(08);
   define tb_credito_maximo    decimal(18,2); 
   define tb_saldo_actual      decimal(18,2);
   define tb_monto_otorgado    decimal(18,2);
   define tb_saldo_venc        decimal(18,2);
   define tb_cuotas_ven        smallint;
   define tb_mop               char(02);
   define tb_clave_obs         char(02);

   define tb_fecha_vencimiento char(08);
   define tb_monto_insoluto    decimal(18,2);
   define tb_ultimo_pago       decimal(18,2);
   define tb_plazo_meses       char(5); --RQM 09 467_Version 14 
   
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
   define tb_dias_atraso INTEGER;
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN	   

   define vlMnpioReportar  char(40);  --GEV
   define vlCodigoReportar   char(10);
   define vlCodigoPOstalZona char(5);
-- Venta de cartera ini
   define vfecha_venta         date;
   define iSqlErr              INTEGER;

   DEFINE cNumProducto         CHAR(4);
   DEFINE cCredExterno         CHAR(20);
   DEFINE dtFechaApRee         DATE;
   DEFINE indice               CHAR(50);
   DEFINE dtFecha_corteRee     DATE;
   DEFINE iDiaCorteRee         INTEGER;
   DEFINE cNumCredito          CHAR(25);
   DEFINE cMensajeFin          CHAR(50);

-- Segmento TRLR
   DEFINE tb_nombre_otorg           CHAR(09);
   DEFINE tb_domicilio_dev          CHAR(100);

   DEFINE iCP                       INTEGER;
   DEFINE itempsepomex    SMALLINT;
   DEFINE itempcredito    SMALLINT;

   DEFINE dtFechaLiquidacion  DATE;
   DEFINE dtFechaCierre  DATE;
-- CAMPOS NUEVOS 12
   DEFINE vmontolutpago       decimal(18,2);
   DEFINE vmontoinsoluto      decimal(18,2);
   DEFINE vfecha_vencido      date;
   DEFINE vdiasatraso       integer;
   DEFINE vfechaultpago date;

--IPCB Validacion para Clve_obs 'EL'
define vstatus_credAnt char(2);
--IPCB CAMPOS NUEVOS RQM 09 467_Version 14 
   define scalle_conocido 		smallint;
   define cpais     			char(3);
   define ccodigo_pais  		char(2);
   define cplazo_meses  		char(4);
   define dplazo_meses  		decimal(5,2);
   define vclave_ciudad   		char(3);
   define vclave_edo      		char(2);
   
   DEFINE tb_monto_originacion  decimal(18,2);
   DEFINE d_monto_originacion   decimal(18,2);
   DEFINE dmonto_autorizado     decimal(18,2);
   
   define vsegmento_pe   		 char(500);
   define vcalle_pe,vcalle_pe1   char(40);
   define vcolonia_pe       	 char(40);
   define vdelegacion_pe    	 char(40);
   define vestado_pe        	 char(4);
   define vcod_postal_pe    	 char(10);
   define vmanzana_pe 			 smallint;
   define vandador_pe 			 smallint;
   define vlote_pe 				 smallint;
   define vedificio_pe 			 smallint;
   define ventrada_pe 			 smallint;
   define vcodini_pe,vcodfin_pe  integer; 
   define vlCodigoPOstalZona_pe  char(5);
   define scalle_conocido_pe 	 smallint;
   define cpais_pe     			 char(3);
   define vclave_ciudad_pe   	 char(3);
   define vclave_edo_pe      	 char(2); 
   define iCP_pe                 integer;
   define vlMnpioReportar_pe     char(40);
   define vlCodigoReportar_pe    char(10);
   define vciudad_pe             char(40);
   define vmonto_int			 decimal(18,2);
   define vplazo_meses			 decimal(18,2);
   define splazo_meses			 char(10);
-- Segmento PE
   define cnombre_empleador   char(99);
   define tb_nombre_empleador char(99);
   define vprofesion          char(3);
   define tb_origen_razon_soc char(2);
   define tb_calle_pe         char(40);
   define tb_colonia_pe       char(40);
   define tb_delegacion_pe    char(40);   
   define tb_ciudad_pe        char(40);
   define tb_estado_pe        char(4);
   define tb_cod_postal_pe    char(10);
   define tb_fingcartvenc	  char(8);
   define v_fecha_vencto 	  date;
   define vf_ingcartvenc 	  char(8);
   define tb_diasatraso       smallint;
--IPCB CAMPOS NUEVOS RQM 09 467_Version 14   
  DEFINE vHora char(12);  --- SOLO PRUEBAS 
  DEFINE vDia1  char(10); --- SOLO PRUEBAS
    
--IPCB19042014 Valida baja para Clave_obs 'UP'
DEFINE vidbaja  char(4);
----IPCB Nov2019--RQM 09 542
 DEFINE v_dispact,vsec_credito  smallint;
 DEFINE vfec_utdisp_flex, dt_feccan_linea, dt_feccan_pres date;
 DEFINE vnum_pagos_sndip char(5);
 
 DEFINE cArma_PN              CHAR(1);
  DEFINE cArma_PA              CHAR(1);
  DEFINE cArma_PE              CHAR(1);
  DEFINE vsegmento_pn_base     CHAR(375);
  DEFINE vsegmento_pa_base     CHAR(326);
  DEFINE vsegmento_pe_base     CHAR(500);
  DEFINE vsegmento_pn_base_t   CHAR(375);
  DEFINE vsegmento_pa_base_t   CHAR(326);
  DEFINE vsegmento_pe_base_t   CHAR(500);
  DEFINE dt_fecha_reporte      DATE;
  DEFINE vFecha_insert_dom     DATE;
  DEFINE vfecha_insert_trabajo DATE;
  DEFINE iRegsInsert           INTEGER;
  DEFINE iRegsUpd              INTEGER;
  DEFINE vestado_civil_prev    CHAR(1);
  DEFINE vprofesion_prev       CHAR(3);
  DEFINE cCambio_estado_civil  CHAR(1);
  DEFINE vrazon_social_prev    char(99);
  DEFINE cProceso              CHAR(4);
  DEFINE cMensajeRet	       CHAR(50);
  DEFINE cCod_ret_2            CHAR(6);
  DEFINE vNumcred_pn_base      CHAR(25);
  DEFINE vNumcred_pa_base      CHAR(25);
  DEFINE vNumcred_pe_base      CHAR(25);
  DEFINE vNumcred_describe     CHAR(25);
  DEFINE mVenc_mesant          decimal(18,2);
  DEFINE cnombre_empleador_temp  char(99);
  DEFINE iLong_NomEmpleador    INTEGER;
  DEFINE cEsNumerico           CHAR(1);
  
  DEFINE vIndProceso           CHAR(1); --RQM 09 549
  DEFINE vIndicaQuitaPP		   CHAR(1); --RQM 09 549
  DEFINE vMontoQuita           DECIMAL(18,2);  --RQM 09 549
  DEFINE vFechaLiquida         DATE; --RQM 09 549
  DEFINE vFechaInsertBit	   DATE; --RQM 09 549
  DEFINE vFechaNegociacion	   DATE; --RQM 09 549
  DEFINE existcred			   INTEGER; --RQM 09 549
  
   let vcodret = "000";
   let vsql = "";
   LET cNumProducto = "";
   LET cCredExterno = "";
   LET dtFechaApRee = DATE(0);
   LET contador_commit = 0;
   LET sCommit                 = 0;
   LET dtFecha_corteRee = DATE(0);
   LET iDiaCorteRee = 0;
   LET iTotalProcesados = 0;
   LET cNumCredito ='';
   LET cMensajeFin = '';
   LET vnum_credito = '';
   LET itempsepomex    = 0;
   LET itempcredito    = 0;
   LET dtFechaLiquidacion  = date(1);
   LET dtFechaCierre  = date(1);

   LET vmontolutpago       = 0;
   LET vmontoinsoluto      = 0;
   LET vfecha_vencido      = date(1);

   let tb_fecha_vencimiento = "";
   let tb_monto_insoluto    = 0.0;
   let tb_ultimo_pago       = 0.0;
   let vdiasatraso       = 0;
   LET vfechaultpago = date(1);
   LET vstatus_credAnt = "";
   LET vfecha_fin_mes_ant = date(1);
   LET vidbaja = "";

   LET bmotivo = 0;  --IPCB Abr15-para identificar que le falta el segmento de direccion
   
   
   LET vsegmento_pe = '';
   LET scalle_conocido = 0;
   LET cpais = '';
   LET vclave_ciudad = '';
   LET vclave_edo = '';
   LET tb_codigo_pais = '';
   LET tb_origen_razon_soc = '';
   LET cnombre_empleador = '';
   LET tb_nombre_empleador = '';
   LET tb_plazo_meses = '';
   LET cnombre_empleador = '';
   LET tb_nombre_empleador = '';
   LET cplazo_meses = '';
   LET tb_monto_originacion = 0;
   LET d_monto_originacion = 0;
   LET tb_plazo_meses = '';
   LET vprofesion = '';
   LET dplazo_meses = 0;
   LET vclave_ciudad = '';
   LET vclave_edo = '';
   LET dmonto_autorizado = 0;
   LET vplazo_meses = 0;
   LET splazo_meses = '0.00';
   LET tb_origen_razon_soc = '';
   LET tb_monto_originacion = 0;
--IPCB Nov2019--RQM 09 542
   LET v_dispact = 0;
   LET vsec_credito = 0;
   --LET vnum_pagos_sndip = 0;
   LET vfec_utdisp_flex = date(1);
   LET dt_feccan_linea  = date(1);
   LET dt_feccan_pres  = date(1);
   
   LET cArma_PN              = '';
   LET cArma_PA              = '';
   LET cArma_PE              = '';
   LET vsegmento_pn_base     = '';
   LET vsegmento_pa_base     = '';
   LET vsegmento_pe_base     = '';
   LET vsegmento_pn_base_t   = '';
   LET vsegmento_pa_base_t   = '';
   LET vsegmento_pe_base_t   = '';
   LET dt_fecha_reporte      = date(1);
   LET vFecha_insert_dom     = date(1);
   LET vfecha_insert_trabajo = date(1);
   LET iRegsInsert           = 0;
   LET iRegsUpd              = 0;
   LET tb_num_credito        = '';
   LET tb_monto_pagar        =0;
   LET vfecha_apertura       = date(1);
   LET vestado_civil_prev    = '';
   LET vprofesion_prev       = '';
   LET cCambio_estado_civil  = '';
   LET vrazon_social_prev    = '';
   LET cProceso              = '0124';
   LET cMensajeRet           = 'PROCESO EXITOSO';
   LET cCod_ret_2            = '';
   LET vNumcred_pn_base      = '';
   LET vNumcred_pa_base      = '';
   LET vNumcred_pe_base      = '';
   LET vNumcred_describe     = '';
   LET mVenc_mesant          = 0;
   LET cnombre_empleador_temp = '';
   LET iLong_NomEmpleador     = 0;
   LET cEsNumerico            = '';
   
   LET vIndProceso            = ''; --RQM 09 549
   LET vIndicaQuitaPP		  = ''; --RQM 09 549
   LET vMontoQuita            = 0; 	--RQM 09 549
   LET vFechaLiquida          = date(1); --RQM 09 549
   LET vFechaInsertBit		  = date(1); --RQM 09 549
   LET vFechaNegociacion	  = DATE(1); --RQM 09 549
   LET existcred			  = 0;	--RQM 09 549
   
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
   LET tb_dias_atraso         = 0;
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN     
   
BEGIN

       ON EXCEPTION SET iSqlErr
           IF iSqlErr != 0 THEN
              IF itempsepomex = 1 THEN
                 drop table sepomex;
              END IF;
              IF itempcredito = 1 THEN
                 drop table creditos_sel;
				 drop table cred_bqc;
              END IF;
              let vcodret = iSqlErr;
              IF (sCommit = -1) THEN
                 rollback work;
              END IF;
			  let cMensajeRet = trim(vcodret) || ' Error en el proceso: ' || trim(vnum_credito);
			  CALL bdicobranza:sp_inserta_bitacora_cob('001', cProceso, vcodret, cMensajeRet, '02') RETURNING cCod_ret_2;
			  
              RETURN vcodret,vnum_credito;
           END IF;
        END EXCEPTION;


   LET vsegmento4_tr           = '';
   LET tb_nombre_otorg         = '';
   LET tb_domicilio_dev        = '';

   LET iCP                     = 0;
   LET vsegmento_pe 		   = ''; --RQM 09 467_Version 14
   
--SET DEBUG FILE TO "/RESPALDOS/INFOSAT/FLEX/burofisicas_cnr.out";
  --SET DEBUG FILE TO "/ifxsif01/macf/burofisicas_cnr.out";
  --TRACE ON; 

  /* --- SOLO PRUEBAS
     LET vHora = ''; LET vDia1 = '';
     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vDia1 
      from sysmaster:sysshmvals;

     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora 
      from sysmaster:sysshmvals;

      INSERT INTO bdiburo:br_cronometro_cnr(accion,fecha,hora) values('Inicio',vDia1, vHora);
   --- SOLO PRUEBAS */ 


set isolation to dirty read;
set lock mode to wait 3;

   CALL bdicobranza:sp_inserta_bitacora_cob_2('001', cProceso, vcodret, cMensajeRet, '01') RETURNING cCod_ret_2; 

   select upper(valor) into vencabezado1
      from br_param
      where cod_param = 3;

   select upper(valor) into vversion
      from br_param
      where cod_param = 4;
   
    
   select upper(valor) into vclave_usu
      from br_param
      where cod_param = 1;

   select upper(valor) into vnombre_usu
      from br_param
      where cod_param = 6;

--	LET vclave_usu = 'JVA4190BAN';

   select upper(valor) into vciclo
      from br_param
      where cod_param = 7;

   select upper(valor) into vuso_futuro
      from br_param
      where cod_param = 8;

   select upper(valor) into vclave_usu_bc
      from br_param
      where cod_param = 128;

   let vinf_adicional = "&";

   select pri_dia_mes - 1
      into vfecha_hoy
      from bdicred:sd_fechas
     where empresa = '001';

--temporal para pruebas unicamente
   --let vfecha_hoy = mdy('08','31','2021');
--temporal para pruebas unicamente

-- Hace las adaptaciones a la tabla de SEPOMEX
--select {+FULL(bdinteg:si_catsepomex)} *,
select {+INDEX(bdinteg:si_catsepomex sicatsepomex)} *,
CASE when  d_estado= 'AGUASCALIENTES'then 'AGS'
when  d_estado= 'BAJA CALIFORNIA'then 'BCN'
when  d_estado= 'BAJA CALIFORNIA SUR'then 'BCS'
when  d_estado= 'CAMPECHE'then 'CAM'
when  d_estado= 'CHIAPAS'then 'CHS'
when  d_estado= 'CHIHUAHUA'then 'CHI'
when  d_estado= 'COAHUILA DE ZARAGOZA'then 'COA'
when  d_estado= 'COLIMA'then 'COL'
when  d_estado= 'CIUDAD DE MEXICO'then 'CDMX'
when  d_estado= 'DURANGO'then 'DGO'
when  d_estado= 'GUERRERO'then 'GRO'
when  d_estado= 'GUANAJUATO'then 'GTO'
when  d_estado= 'HIDALGO'then 'HGO'
when  d_estado= 'JALISCO'then 'JAL'
when  d_estado= 'MICHOACAN DE OCAMPO'then 'MICH'
when  d_estado= 'MORELOS'then 'MOR'
when  d_estado= 'NAYARIT'then 'NAY'
when  d_estado= 'NUEVO LEON'then 'NL'
when  d_estado= 'OAXACA'then 'OAX'
when  d_estado= 'PUEBLA'then 'PUE'
when  d_estado= 'QUERETARO'then 'QRO'
when  d_estado= 'QUINTANA ROO'then 'QR'
when  d_estado= 'SAN LUIS POTOSI'then 'SLP'
when  d_estado= 'SINALOA'then 'SIN'
when  d_estado= 'SONORA'then 'SON'
when  d_estado= 'TABASCO'then 'TAB'
when  d_estado= 'TAMAULIPAS'then 'TAM'
when  d_estado= 'TLAXCALA'then 'TLAX'
when  d_estado= 'VERACRUZ DE IGNACIO DE LA LLAVE'then 'VER'
when  d_estado= 'YUCATAN'then 'YUC'
when  d_estado= 'ZACATECAS'then 'ZAC'
when  d_estado= 'MEXICO'then 'EM'
ELSE '' END estado_abrev FROM bdinteg:si_catsepomex into temp sepomex with no log;

select distinct(d_estado),estado_abrev,c_estado from sepomex
into temp estados_sepomex with no log;
---Creacion de indices por cada una de las validacines de SEPOMEX
begin;
CREATE INDEX idx_sepomex ON sepomex(d_codigo,d_mnpio,estado_abrev) ONLINE;
commit;
begin;CREATE INDEX idx_sepomex1 ON sepomex(d_mnpio,estado_abrev) ONLINE;
commit;
begin;
CREATE INDEX idx_sepomex2 ON sepomex(d_asenta,estado_abrev) ONLINE;
commit;
begin;
CREATE INDEX idx_sepomex3 ON sepomex(d_codigo,estado_abrev) ONLINE;
commit;
UPDATE STATISTICS MEDIUM FOR TABLE sepomex;

LET itempsepomex    = 1;

   let vfecha_ini = mdy(month(vfecha_hoy),1,year(vfecha_hoy));
   let vfecha_fin_mes_ant = date(vfecha_ini - 1 units day);

   let vano = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vano;
   let dt_fecha_reporte = vmes || "/" || vdia || "/" || vano;

   --- Genera registro encabezado
/*
   let vheader = vencabezado1||vversion||vclave_usu||vnombre_usu||
                 vciclo||vfecha_reporte||vuso_futuro||
                 rpad(trim(vinf_adicional),98,"&");
*/
   let vlongitud = 0;
   let vnumreg = 1;
   let vnumreg_bc = 1;
   let vreg_proc = 0;
   let vtot_proc = 0;
   let contador_stat = 0;
   let actualiza_esta = 0;

    LET itempcredito    = 1;

    LET tb_nombre_otorg = vnombre_usu;
    LET tb_domicilio_dev = 'INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.';


   IF  (select count(*) from bdiburo:br_burofisicas_cnr where numreg = 1 and  substr(registro,35,8) matches vfecha_reporte) = 0 THEN
       -- truncate table "informix".br_burofisicas_describe_cnr;     -- Ya No es necesario truncar por que preexistira informacion RQI 21 225 MACF
        truncate table "informix".br_burofisicas_cnr;
        truncate table "informix".br_burofisicas_concilia_cnr;
        DROP INDEX "informix".idx_br_burofisicas_cnr; 
       -- DROP INDEX "informix".idx_br_burofisicas_describe_cnr;     -- Ya No es necesario eliminar Ã­ndice por que preexistira informacion RQI 21 225 MACF
       -- DROP INDEX "informix".inxburoconcilia_cnr;
--- Genera registro encabezado para CÃ­rculo
       let vheader = vencabezado1||vversion||vclave_usu||vnombre_usu||vciclo||vfecha_reporte||vuso_futuro||rpad(trim(vinf_adicional),98,"&");
       insert into br_burofisicas_cnr
          values(vnumreg,vheader);    
    END IF;

    UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_cnr;
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_describe_cnr;
    UPDATE STATISTICS medium for table "informix".br_burofisicas_concilia_cnr;
	
--AAME 2015-03-23 RQM 10 550 Se modifica para contemplar los 2 nuevos productos de prestamo ('7600','7700') 
--AAME 2021-02-03 RQM 10 1177 Se modifica para contemplar los 2 nuevos productos de prestamo (9100,9300)
--Se crea tabla temporal con los crÃ©ditos a procesar
--IPCB Nov2019-Se modifica la extraccion de universo, excluyendo 6800 flexible, para generarlocorrectamente.

-- RQM 09 459 Condonaciones y Quitas
	SELECT a.numcte, a.num_producto,a.num_credito, a.indicador_proceso,a.fecha_status, max(fecha_insert) fecha_insert 
	FROM bdicred:sd_bitacora_quitacondonacion a
	WHERE a.indicador_proceso = 'Q' AND a.estatus_proceso = 'FI'
	AND a.fecha_status BETWEEN mdy(month(vfecha_hoy),1,year(vfecha_hoy)) AND vfecha_hoy
	AND a.num_producto NOT IN ('6011','6001','8100','8500') group by 1,2,3,4,5
	INTO TEMP cred_bqc WITH NO LOG;

	SELECT  a.numcte, a.num_producto, b.credito_externo,a.num_credito,NVL(b.status_cred,"E1") status_cred, c.monto_otorgado, c.fecha_ult_mov, 
                        b.fecha_apertura, b.plazo,b.periodo_plazo,case when b.num_producto IN ('6300','7600','7700','9100','9300') then 'PL' else 'PN' end tipo_contrato, b.campo_trab3
						,0 dispact, 1 sec_credito, date(1) fec_ultdisp_flex, a.indicador_proceso
	FROM cred_bqc  a
	INNER JOIN bdicred:sd_maecredcrd b ON a.num_credito = b.num_credito AND b.status_cred IN ('FF','FI')
	LEFT OUTER JOIN bdicred:sd_maesdoscontcrd c ON c.num_credito = a.num_credito and a.fecha_insert = c.fecha
	WHERE a.fecha_status BETWEEN mdy(month(vfecha_hoy),1,year(vfecha_hoy)) AND vfecha_hoy
	AND b.num_producto NOT IN ('6011','6900','8900') 
	 INTO temp creditos_sel WITH NO LOG;

      INSERT INTO creditos_sel
	  SELECT  a.numcte, a.num_producto, a.credito_externo,a.num_credito,NVL(a.status_cred,"E1") status_cred, b.monto_otorgado, b.fecha_ult_mov, 
                        a.fecha_apertura, a.plazo,a.periodo_plazo,case when a.num_producto IN ('6300','7600','7700','9100','9300') then 'PL' else 'PN' end tipo_contrato, a.campo_trab3
						,0 dispact, 1 sec_credito, date(1) fec_ultdisp_flex, '' indicador_proceso
        FROM bdicred:sd_maecredcontcrd a
        LEFT OUTER JOIN bdicred:sd_maesdoscontcrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito and a.fecha = b.fecha
       WHERE a.empresa = "001"
         --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr WHERE fecha_reporte <> vfecha_reporte)
		 AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr WHERE fecha_reporte = vfecha_reporte)
         --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
         AND a.num_producto NOT IN ( '6011','6900','6800','8900')
         AND a.fecha = vfecha_hoy
		 AND a.status_cred <> 'FI'
		 AND a.num_credito NOT IN(SELECT num_credito FROM creditos_sel);


      CREATE INDEX inx_creditos_sel ON creditos_sel(num_credito);
      update statistics medium for table creditos_sel;
	--AAME 2021-02-03 RQM 10 1177 Se modifica para contemplar los 2 nuevos productos de prestamo (9100,9300)
	--AAME 2015-03-23 RQM 10 550 Se modifica para contemplar los 2 nuevos productos de prestamo ('7600','7700') 
      insert into creditos_sel
      SELECT  a.numcte, a.num_producto, a.credito_externo,a.num_credito,NVL(mae.status_cred,"E1") status_cred, b.monto_otorgado, b.fecha_ult_mov, 
                        a.fecha_apertura, a.plazo,a.periodo_plazo,case when a.num_producto IN ('6300','7600','7700','9100','9300') then 'PL' else 'PN' end tipo_contrato, a.campo_trab3
						,0 dispact, 1  sec_credito, date(1) fec_ultdisp_flex, '' indicador_proceso
        FROM bdicred:sd_maecredcontcrd a
        LEFT OUTER JOIN bdicred:sd_maesdoscontcrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito and a.fecha = b.fecha
        INNER JOIN bdicred:sd_maecredcrd mae on mae.empresa=a.empresa and mae.num_credito=a.num_credito and  mae.status_cred <> 'FI'
       WHERE a.empresa = "001"
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr WHERE fecha_reporte = vfecha_reporte)
         --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
         AND a.num_producto NOT IN ( '6011','6900','6800','8900')
         AND a.fecha = mdy(month(vfecha_hoy),1,year(vfecha_hoy)) - 1 units day
		 AND a.num_credito NOT IN(SELECT num_credito FROM creditos_sel);

		--AAME 2021-02-03 RQM 10 1177 Se modifica para contemplar los 2 nuevos productos de prestamo (9100,9300)
		 --AAME 2015-03-23 RQM 10 550 Se modifica para contemplar los 2 nuevos productos de prestamo ('7600','7700') 	 
--IPCB 08082014/Integra Cancelaciones aperturadas el mismo mes.
	INSERT INTO creditos_sel   
	SELECT  a.numcte, a.num_producto, a.credito_externo,a.num_credito,NVL(A.status_cred,"FF") status_cred, C.monto_otorgado, C.fecha_ult_mov, 
           a.fecha_apertura, a.plazo,a.periodo_plazo,case when a.num_producto IN ('6300','7600','7700','9100','9300') then 'PL' else 'PN' end tipo_contrato, a.campo_trab3
		   ,0 dispact, 1 sec_credito, date(1) fec_ultdisp_flex, '' indicador_proceso
	  FROM bdicred:sd_maecredcrd a 
    INNER JOIN bdicred:sd_maecredanexocrd b ON b.empresa = a.empresa AND a.num_credito = b.num_credito 
       AND b.fecha_proceso BETWEEN mdy(month(vfecha_hoy),1,year(vfecha_hoy)) AND vfecha_hoy
    LEFT OUTER JOIN bdicred:sd_maesdoscrd c ON c.empresa = a.empresa AND c.num_credito = a.num_credito
	 WHERE a.empresa = '001'
	   AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr WHERE fecha_reporte = vfecha_reporte)
       --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
	   AND a.status_cred = 'FF'
	   AND a.num_producto NOT IN ( '6011','6900','6800','8900')
       AND a.fecha_apertura BETWEEN  mdy(month(vfecha_hoy),1,year(vfecha_hoy)) AND vfecha_hoy
	   AND a.num_credito NOT IN(SELECT num_credito FROM creditos_sel);

--AAME 2021-02-03 RQM 10 1177 Se modifica para contemplar los 2 nuevos productos de prestamo (9100,9300)
--IPCB 07052018/Integra la extracciÃ³n de FI
	INSERT INTO creditos_sel   
	SELECT  a.numcte, a.num_producto, a.credito_externo,a.num_credito,"FI" status_cred, C.monto_otorgado, C.fecha_ult_mov, 
           a.fecha_apertura, a.plazo,a.periodo_plazo,case when a.num_producto IN ('6300','7600','7700','9100','9300') then 'PL' else 'PN' end tipo_contrato, a.campo_trab3
		   ,0 dispact, 1 sec_credito, date(1) fec_ultdisp_flex, '' indicador_proceso
	  FROM bdicred:sd_maecredcrd_inmaterial a 
     LEFT OUTER JOIN bdicred:sd_maesdoscrd_inmaterial c ON c.empresa = a.empresa AND c.num_credito = a.num_credito
	 WHERE  a.fecha BETWEEN mdy(month(vfecha_hoy),1,year(vfecha_hoy)) AND vfecha_hoy
       AND a.empresa = '001'
	   AND a.num_Credito >=''
	   AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr WHERE fecha_reporte = vfecha_reporte)
       --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
	   AND a.num_producto NOT IN ( '6011','6900','6800','8900')
	   AND a.num_credito NOT IN(SELECT num_credito FROM creditos_sel);

--IPCB Nov2019-Se genera bloque para universo de flexible RQM 09 542 --INICIO  
--Flex Vigentes con disposicion 
	INSERT INTO creditos_sel  
  SELECT  a.numcte, a.num_producto, a.credito_externo,a.num_credito,NVL(a.status_cred,"E1") status_cred, lp.monto_linea monto_otorgado, b.fecha_ult_mov, 
                        lp.fecha_otorga fecha_apertura, a.plazo,a.periodo_plazo, 'LR' tipo_contrato, a.campo_trab3
         ,1 dispact, sec_credito,a.fecha_apertura fec_ultdisp_flex, '' indicador_proceso				
        FROM  bdicred:sd_maecredcontcrd a
        inner join bdicred:sd_linea_prestamo lp on a.num_credito = lp.num_credito and (fecha_ult_pf is null or fecha_ult_pf > vfecha_hoy)and sec_credito > 0
        LEFT OUTER JOIN bdicred:sd_maesdoscontcrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito and a.fecha = b.fecha
       WHERE a.empresa = "001"
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr WHERE fecha_reporte = vfecha_reporte)
         --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
         AND a.num_producto IN ( '6800')
         AND a.fecha = vfecha_hoy
		 AND a.status_cred <> 'FI'
		 AND a.num_credito NOT IN(SELECT num_credito FROM creditos_sel);
		 
		          --INTO temp creditos_sel WITH NO LOG;
--Flex SIN PRESTAMO DISPONIBLE
	INSERT INTO creditos_sel 
  SELECT  a.numcte, a.num_producto, a.credito_externo,a.num_credito,"E1" status_cred, lp.monto_linea, b.fecha_ult_mov, 
                        lp.fecha_otorga, a.plazo,a.periodo_plazo, 'LR' tipo_contrato, a.campo_trab3
	    ,0 v_dispact, sec_credito,a.fecha_apertura, '' indicador_proceso
        FROM bdicred:sd_maecredcrd a
        inner join bdicred:sd_linea_prestamo lp on a.num_credito = lp.num_credito and fecha_otorga <=vfecha_hoy  --(fecha_ult_pf is null or fecha_ult_pf > vfecha_hoy)
																				  and(fecha_ult_pf is null OR fecha_ult_pf > vfecha_hoy OR fecha_cancela > vfecha_hoy)
		
        LEFT OUTER JOIN bdicred:sd_maesdoscrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito 
       WHERE a.empresa = "001"
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr WHERE fecha_reporte = vfecha_reporte)
         --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
         AND a.num_producto IN ( '6800')
		 AND a.status_cred not in ('FI','CV')
		 AND a.num_credito NOT IN(SELECT num_credito FROM creditos_sel);

--Flex CANCELADAS Y VENDIDAS
	INSERT INTO creditos_sel  
  SELECT  a.numcte, a.num_producto, a.credito_externo,a.num_credito,status_cred, lp.monto_linea, b.fecha_ult_mov, 
                        lp.fecha_otorga, a.plazo,a.periodo_plazo, 'LR' tipo_contrato, a.campo_trab3
        ,1 v_dispact, sec_credito 	,a.fecha_apertura, '' indicador_proceso
        FROM bdicred:sd_maecredcrd a
        inner join bdicred:sd_linea_prestamo lp on a.num_credito = lp.num_credito 
		        and fecha_ult_pf is not null
				and ((fecha_cancela BETWEEN mdy(month(vfecha_hoy),1,year(vfecha_hoy)) AND vfecha_hoy)
					 OR (fecha_ult_pf BETWEEN mdy(month(vfecha_hoy),1,year(vfecha_hoy)) AND vfecha_hoy))
        LEFT OUTER JOIN bdicred:sd_maesdoscrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito --and a.fecha = b.fecha
       WHERE a.empresa = "001"
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr WHERE fecha_reporte = vfecha_reporte)
         --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
         AND a.num_producto IN ( '6800')
         AND a.status_cred <> 'FI'
		 AND a.num_credito NOT IN(SELECT num_credito FROM creditos_sel);

 
--Flexibles Inmateriales FI
	INSERT INTO creditos_sel   
  SELECT  a.numcte, a.num_producto, a.credito_externo,a.num_credito,"FI" status_cred, lp.monto_linea, C.fecha_ult_mov, 
          lp.fecha_otorga,  a.plazo,a.periodo_plazo, 'LR' tipo_contrato, a.campo_trab3
		  ,1 v_dispact, sec_credito ,a.fecha_apertura, '' indicador_proceso
	  FROM bdicred:sd_maecredcrd_inmaterial a 
	  inner join bdicred:sd_linea_prestamo lp on a.num_credito = lp.num_credito
     LEFT OUTER JOIN bdicred:sd_maesdoscrd_inmaterial c ON c.empresa = a.empresa AND c.num_credito = a.num_credito
	 WHERE  a.fecha BETWEEN mdy(month(vfecha_hoy),1,year(vfecha_hoy)) AND vfecha_hoy
       AND a.empresa = '001'
	   AND a.num_Credito >=''
	   AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr WHERE fecha_reporte = vfecha_reporte)
       --AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
	   AND a.num_producto IN  ('6800')
	   AND a.num_credito NOT IN(SELECT num_credito FROM creditos_sel);
   		 
--IPCB Nov2019-Se genera bloque para universo de flexible RQM 09 542 --FIN

   IF (select count(*) from bdiburo:br_burofisicas_cnr) = 1 THEN
       select count(*)::integer into iTotalProcesados from creditos_sel;
       INSERT INTO bdiburo:br_burofisicas_concilia_cnr (empresa, num_producto, num_credito, motivo, fecha_cinta,int_calculo) VALUES('001',cNumProducto,vnum_credito,'TCP',vfecha_hoy,iTotalProcesados);
    END IF;

    select max(numreg) into vnumreg
    from bdiburo:br_burofisicas_cnr where numreg > 0;

-- se crea temporal para pago maximo
   select num_credito, max(fecha_mov) fecha_max
     from bdicred:sd_movhiscrd
    where empresa = "001" 
      and codigo_fun in ('021','023','027','028')
      and codigo_ref = 1
      and reversado = 'N'
      and fecha_mov <= vfecha_hoy 
	  and num_credito in(SELECT num_credito FROM creditos_sel)
	  	--and num_credito in( '680000427616','680000043967','680000017649')--PRUEBAS IPCB
    group by 1
    into temp cred_movhis with no log;
    create unique index inx_cred_movhis on cred_movhis(num_credito);
    update statistics medium for table cred_movhis;
-- se crea temporal para pago maximo

  foreach with hold
      SELECT numcte, num_producto, credito_externo, num_credito,NVL(status_cred,"E1") status_cred, monto_otorgado, fecha_ult_mov, fecha_apertura, plazo, periodo_plazo, tipo_contrato,campo_trab3,dispact, sec_credito ,fec_ultdisp_flex, indicador_proceso
         into vnumcte,cNumProducto, cCredExterno,vnum_credito,vstatus_cred, vmonto_otorgado,vfecha_finiq,vpago_int,vnum_pagos,vfrecpago,tb_tipo_producto,vidbaja, v_dispact, vsec_credito,vfec_utdisp_flex, vIndicaQuitaPP
         from creditos_sel
--	where num_credito in( '680000427616','680000043967','680000017649')--PRUEBAS IPCB

-- RQM 09 459 Condonaciones y Quitas
			-- SI ES QUITA
				IF vIndicaQuitaPP = 'Q' THEN
					SELECT a.indicador_proceso, a.mto_quita, b.fecha_proceso, max(a.fecha_insert) fecha_insert
					INTO vIndProceso, vMontoQuita, vFechaLiquida, vFechaInsertBit
					FROM bdicred:sd_bitacora_quitacondonacion a
					--INNER JOIN (SELECT num_credito, max(fecha_insert) fecha_insert FROM bdicred:sd_bitacora_quitacondonacion group by num_credito)j ON a.num_credito = j.num_credito
					INNER JOIN bdicred:sd_maecredanexocrd b ON a.num_credito=b.num_credito
					INNER JOIN bdicred:sd_maecredcrd c ON c.num_credito = a.num_credito
					WHERE a.fecha_status BETWEEN vfecha_ini AND vfecha_hoy
					AND a.num_credito = vnum_credito
					AND a.indicador_proceso = 'Q'
					AND a.estatus_proceso = 'FI'
					AND c.status_cred IN ('FF','FI')
					group by 1,2,3;
				ELSE
					LET vIndProceso = '';
				END IF;

--IPCB 25nov14: correccion frecuencia de pago Quincenal para credinomina de clave Q por clave S			 
	IF cNumProducto = '6400' and vfrecpago = 'Q' THEN
	  LET vfrecpago = 'S';
	END IF;

    LET cNumCredito = vnum_credito;  
	
	IF (sCommit = 0) THEN
       BEGIN WORK;
       LET contador_commit = 0;
       LET sCommit = -1;
    END IF; 
	 
-- Venta de cartera ini
-- Solo se reporta el mes de la venta
     if (vstatus_cred = "CV") then
        let vfecha_venta = null;
--IPCB 12mar14 Se cambia la extraccio del saldo vencido para considerar los intereses moratorios
        select b.fecha,dia_cuota,
                monto_otorgado,0,--nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0)
				nvl(((monto_vencido + mto_venc_trasp) + ((sdo_contab_mora + sdo_moratorio)*1.16)) + 
                     (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado))
					 from bdicred:sd_amortiza_creditocrd_vendida
					 where c.empresa = empresa and c.num_credito = num_credito 
					 and capital_status in ('2','7','6')),0)
          into vfecha_venta,vdiacuota,
                vmonto_otorgado, vsaldo_vig, vsaldo_venc
          from bdicred:sd_maecredcrd_vendida b, bdicred:sd_maesdoscrd_vendida c,
             outer bdicred:sd_definicion d
        where b.empresa = '001'
          and b.empresa = c.empresa
          and b.fecha=c.fecha
          and b.num_credito = vnum_credito
          and b.num_credito = c.num_credito
          and d.num_producto = b.num_producto
          and b.empresa = d.empresa;

           if vmonto_otorgado is null then let vmonto_otorgado = 0; end if; 
           if vsaldo_vig is null then let vsaldo_vig = 0; end if; 
           if vsaldo_venc is null then let vsaldo_venc = 0; end if; 

           if (vfecha_venta is null) then
               INSERT INTO bdiburo:br_burofisicas_concilia_cnr (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CVC',vfecha_hoy);
               continue foreach;
           end if;
     end if;

-- Venta de cartera ini
     let yaexiste = 0;
     LET vsegmento_pn = "";
     LET vsegmento2_pa = "";
     LET vsegmento3_tl = "";

    --if vstatus_cred not in ("CV","FF") then RQM 09 343-0
    if vstatus_cred not in ("CV","FF","FI") then
         select d.maneja_linea,
                e.dia_corte --,mto_fin_ven_trasp::smallint mto_fin_ven_trasp--agregar meses vencidos
           into vtp_linea,
                vdiacuota
            from bdicred:sd_maecredcrd b, bdicred:sd_maesdoscontcrd c,
                bdicred:sd_maecredanexocrd e,
                 outer bdicred:sd_definicion d
            where b.empresa = '001'
              and b.num_credito = vnum_credito
              and c.empresa = b.empresa
              and c.fecha = vfecha_hoy
              and c.num_credito = b.num_credito
              and e.empresa = b.empresa
              and e.num_credito = b.num_credito
              and b.empresa = d.empresa 
              and b.num_producto = d.num_producto;
    end if;

	-- Inicializa variables
-- Segmento PN
     let tb_apell_paterno = "";
     let tb_apell_materno = "";
     let tb_nombre1       = "";
     let tb_nombre2       = "";
     let tb_fecha_nac     = "";
     let tb_rfc           = "";
     let tb_nacionalidad  = "";
     let tb_estado_civil  = "";
     let tb_sexo          = "";

-- Segmento PA
     let tb_calle         = "";
     let tb_colonia       = "";
     let tb_delegacion    = "";
     let tb_ciudad        = "";
     let tb_estado        = "";
     let tb_cod_postal    = "";

     let vcredito_maximo  = 0.0;
     let vcredito_maximo2 = 0.0;

-- Segmento TL
     let tb_clave_usu         = "";
     let tb_nombre_usu        = "";
     let tb_num_credito       = "";
     let tb_responsabilidad   = "";
     let tb_tipo_cuenta       = "";
     let tb_clave_monetaria   = "";
     let tb_num_pagos         = "";
     let tb_frecpago          = "";
     let tb_monto_pagar       = 0.0;
     let tb_fecha_apertura      = "";
     let tb_fecha_ult_pago    = "";
     let tb_fecha_ult_compra  = "";
     let tb_fecha_cierre      = "";
     let tb_fecha_reporte     = "";
     let tb_credito_maximo    = 0.0;
     let tb_saldo_actual      = 0.0;
     let tb_monto_otorgado    = 0.0;
     let tb_saldo_venc        = 0.0;
     let tb_cuotas_ven        = 0;
     let tb_mop               = "";
     let tb_clave_obs         = "";
	 let vlMnpioReportar = '';
     let vlCodigoReportar ='';
     let vlCodigoPOstalZona ='';

     let vrea_cal_cuota = 0;

-- Segmento PE
	 LET tb_nombre_empleador 	= "";
	 LET tb_origen_razon_soc 	= "";
	 LET tb_calle_pe 			= "";
	 LET tb_colonia_pe 			= "";
	 LET tb_delegacion_pe 		= ""; 
	 LET tb_ciudad_pe 			= "";
	 LET tb_estado_pe 			= "";
	 LET tb_cod_postal_pe 		= "";
	 LET tb_fingcartvenc 		= "";
	 LET tb_diasatraso 			= 0;	
	 
	 SELECT limit 1 num_credito INTO vNumcred_describe
	   FROM bdiburo:br_burofisicas_describe_cnr
	  WHERE num_credito = vnum_credito;
	  
	  LET vNumcred_describe = NVL(vNumcred_describe,'');
	 
	 SELECT first 1 num_credito,registro INTO vNumcred_pn_base, vsegmento_pn_base_t -- Validar si existe info previa para la cuenta en base
	   FROM bdiburo:br_burofisicas_cnr_base
	  WHERE num_credito = vnum_credito
	    AND tipo_segmento='PN';
			
	 LET vsegmento_pn_base = NVL(vsegmento_pn_base_t,'');
	 LET vNumcred_pn_base = NVL(vNumcred_pn_base,'');
	
	IF vsegmento_pn_base = '' THEN
	   LET cArma_PN = 'S';
	ELSE

	   SELECT estado_civil, profesion
	     INTO vestado_civil, vprofesion
	     FROM bdinteg:si_ctepf
        WHERE numcte=vnumcte;
	
	    LET vestado_civil = NVL(vestado_civil,'');
	  
        SELECT estado_civil INTO vestado_civil_prev
	      FROM  bdiburo:br_burofisicas_describe_cnr
	     WHERE num_credito = cNumCredito;
	   
	    LET vestado_civil_prev = NVL(vestado_civil_prev,'');
	   
        IF TRIM(vestado_civil) <> TRIM(vestado_civil_prev) THEN
           let tb_estado_civil  = vestado_civil;
		   LET cCambio_estado_civil = 'S';
	    ELSE
	       -- Si no cambio deja el que tenia anteriormente
		   let tb_estado_civil  = vestado_civil_prev;
		   LET cCambio_estado_civil = 'N';
        END IF;
	  
	    IF cCambio_estado_civil = 'N' THEN
         
		   /*SELECT registro INTO vsegmento_pn_base_t
	         FROM bdiburo:br_burofisicas_cnr_base
	        WHERE num_credito = vnum_credito
	        AND tipo_segmento='PN';
	   
           LET vsegmento_pn_base = NVL(vsegmento_pn_base_t,'');*/
	       LET cArma_PN = 'N';
		 
	    ELSE
	       LET cArma_PN = 'S';
	    END IF;    
    END IF;
	
	IF cArma_PN = 'S' OR (vsegmento_pn_base = '' OR vsegmento_pn_base is NULL) THEN  -- Validar si se crea el segmento PN o se consulta en tabla base(RQI 21 225 Reing proc cinta ctas plazo) MACF
	  --LET cArma_PN = 'S';
--        if vfecha_finiq <= vfecha_ini then
--               INSERT INTO bdiburo:br_burofisicas_concilia_cnr (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CNP',vfecha_hoy);
--           continue foreach;
--        end if

         select 
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(apell_paterno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(apell_materno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(nombre1),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(nombre2),""),'1','L'),'0','O'),'5','S'),'8','B'),
             fecha_nac,trim(rfc),nvl(fecha_alta,""),nvl(nacionalidad,"01"),nvl(residencia,"MX"),
             nvl(estado_civil," "),nvl(sexo,"I"), trim(b.profesion)
         into vapell_paterno,vapell_materno,vnombre1,vnombre2,vfecha_nac,vrfc,vfecha_alta,vnacionalidad,vresidencia,
             vestado_civil,vsexo, vprofesion
             from bdinteg:si_cliente a,bdinteg:si_ctepf b
             where a.numcte=b.numcte
             and a.numcte=vnumcte;

    /*IF (sCommit = 0) THEN
       BEGIN WORK;
       LET contador_commit = 0;
       LET sCommit = -1;
    END IF;*/ 

     if vfecha_nac is null then let vrfc = "";  end if;

 
-- Inicia Segmento PN (Nombre)
     if vapell_paterno = "X X" then
        let vapell_paterno = "XX";
     end if;

     if vapell_materno = "X X" then
             let vapell_materno = "XX";
     end if;

     if vnombre1 = "-" then
         let vnombre1 = vnombre2;
         let vnombre2 = "";
     end if;
     let vfecha_finiq = "";

     let vano = year(vfecha_nac);
     let vmes = lpad(month(vfecha_nac),2,"0");
     let vdia = lpad(day(vfecha_nac),2,"0");

-- Agrega Apellido Paterno
     let vsegmento1_pn = lpad(length(trim(vapell_paterno)),2,"0")||
                           trim(vapell_paterno);
     let tb_apell_paterno = trim(vapell_paterno);


-- Agrega Apellido Materno
     IF nvl(vapell_materno,'') <> '' THEN
        let vsegmento1_pn = trim(vsegmento1_pn)||'00'||
                            lpad(length(trim(vapell_materno)),2,"0")||trim(vapell_materno);
                            
        let tb_apell_materno = trim(vapell_materno);
     ELSE
        let vsegmento1_pn = trim(vsegmento1_pn)||'0016NO PROPORCIONADO';  --RQM 09 467_Version 14
     END IF;

-- Agrega Primero Nombre
     let vsegmento1_pn = trim(vsegmento1_pn)||'02'||
                         lpad(length(trim(vnombre1)),2,"0")||vnombre1;
     let tb_nombre1       = vnombre1;

-- Agrega Segundo Nombre
     if vnombre2 is not null then
        let vsegmento1_pn = trim(vsegmento1_pn)||'03'||
                            lpad(length(trim(vnombre2)),2,"0")||vnombre2;
        let tb_nombre2       = vnombre2;
     end if;

-- Agrega Fecha de Nacimiento
     if vfecha_nac is not null then
        let vsegmento1_pn = trim(vsegmento1_pn)||'0408'||vdia||vmes||vano;
        let tb_fecha_nac     = vdia||vmes||vano;
     end if;

-- Agrega RFC
     let existe = length(vrfc);
     let existe1 = 0;
     let vquita = "";
     while existe1 < existe
      if vrfc[1,1]="~" or vrfc[1,1]=" " then
      else
         let vquita = trim(vquita)||vrfc[1,1];
      end if;
      let vrfc = vrfc[2,13];
      let existe1 = existe1 + 1;
     end while;
     let vrfc = trim(vquita);
     let existe = length(vrfc);
     if vrfc is null or existe < 10 then
        if vrfc[2,2] = "A" or vrfc[2,2] = "E" or vrfc[2,2] = "I" or vrfc[2,2] = "O" or vrfc[2,2] = "U" Then
           let vrfc = vapell_paterno[1,2]||vapell_materno[1,1]||vnombre1[1,1]||vano[3,4]||vmes||vdia;
        else
           let vrfc = vapell_paterno[1,1]||vapell_paterno[3,3]||vapell_materno[1,1]||vnombre1[1,1]||vano[3,4]||vmes||vdia;
        end if  
     end if

     let vsegmento1_pn = trim(vsegmento1_pn)||'05'||
                                 lpad(length(trim(vrfc)),2,"0")||vrfc;
     let tb_rfc           = vrfc;

-- Agrega Nacionalidad
     let vsegmento1_pn = trim(vsegmento1_pn)||'0802MX';
     let tb_nacionalidad  = "MX";

-- Agrega Estado Civil
    if vestado_civil is not null then
        if vestado_civil = 'C' then
           let vsegmento1_pn = trim(vsegmento1_pn)||'1101M';
        end if;
        if vestado_civil = 'S' then
           let vsegmento1_pn = trim(vsegmento1_pn)||'1101S';
        end if;
        if vestado_civil = 'U' then
           let vsegmento1_pn = trim(vsegmento1_pn)||'1101F';
        end if;
        if vestado_civil = 'D' then
           let vsegmento1_pn = trim(vsegmento1_pn)||'1101D';
        end if;
        if vestado_civil = 'V' then
           let vsegmento1_pn = trim(vsegmento1_pn)||'1101W';
        end if;
       let tb_estado_civil  = vestado_civil;
     end if;

-- Agrega Sexo
     if vsexo is not null then
        let vsegmento1_pn = trim(vsegmento1_pn)||'1201'||vsexo;
        let tb_sexo          = vsexo;
     end if;
     let vsegmento_pn = 'PN'||trim(vsegmento1_pn);

    END IF;  -- Validar si se crea el segmento PN o se consulta en tabla base(RQI 21 225 Reing proc cinta ctas plazo) MACF
	 
     /* 
     SELECT Trim(f.nombrecalle)||' '||Trim(a.numeroextcalle)||' '||
	    Trim(a.numerointcalle),
            Trim(g.nombrezona),Trim(g.municipiozona), Trim(c.estado),-- a.cod_postal,
            lpad(trim(a.cod_postal),5,"0"),manzana,andador,lote,edificio,entrada,codini,codfin,
			substr( CodigoPOstalZona,1,5)
       INTO vcalle,vcolonia,vdelegacion,vestado,vcod_postal,
            vmanzana,vandador,vlote,vedificio,ventrada, vcodini,vcodfin,
			vlCodigoPOstalZona
       FROM bdinteg:si_direcciones_actual as a,
            bdisolic:ss_circulo_edos as c,bdinteg:si_catcalles f,
	    bdinteg:si_catzonas g
      WHERE a.numcte=vnumcte 
        AND a.tipo_dir="1"
        AND c.empresa = "001"
        AND a.estado = c.clave 
        AND a.numerociudad = g.numerociudad 
        AND a.numerocolonia = g.numerocolonia
        AND a.numerocalle = f.numerocalle;
		  */
	
	 --SELECT registro INTO vsegmento_pa_base_t
	 SELECT first 1 num_credito,registro INTO vNumcred_pa_base, vsegmento_pa_base_t  
	   FROM bdiburo:br_burofisicas_cnr_base
	  WHERE num_credito = vnum_credito
	    AND tipo_segmento='PA';
		   
	  LET vsegmento_pa_base = NVL(vsegmento_pa_base_t,'');
	  LET vNumcred_pa_base = NVL(vNumcred_pa_base,'');   
	  
	IF vsegmento_pa_base = '' THEN 
	   LET cArma_PA = 'S';
    ELSE
	  SELECT fecha_insert INTO vFecha_insert_dom
	    FROM bdinteg:si_direcciones_actual 
	   WHERE numcte = vnumcte
		 AND tipo_dir = '1';
   
	   LET vFecha_insert_dom = NVL(vFecha_insert_dom,date(1));
	   
	   IF vFecha_insert_dom >= vfecha_ini THEN
          LET cArma_PA = 'S';
	   ELSE  
	   
		/*SELECT registro INTO vsegmento_pa_base_t
		  FROM bdiburo:br_burofisicas_cnr_base
		 WHERE num_credito = vnum_credito
		   AND tipo_segmento='PA';
		   
		  LET vsegmento_pa_base = NVL(vsegmento_pa_base_t,'');*/
		  LET cArma_PA = 'N';
		  
	    END IF; 
		  
    END IF;
	
	 
   IF cArma_PA = 'S' OR (vsegmento_pa_base = '' OR vsegmento_pa_base is NULL) THEN  -- DOM ACTUALIZADO DEL CTE (Ini)
	   --LET cArma_PA = 'S'; 
	
	
		  --SELECT limit 1 Trim(f.nombrecalle)||' '||Trim(a.numeroextcalle)||' '||
		  --SELECT limit 1 case when substr(f.nombrecalle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(f.nombrecalle) else trim(f.nombrecalle) end||' '|| case when nvl(a.numeroextcalle,'') = '' or numeroextcalle::INT = 0 then 'SN' else Trim(a.numeroextcalle) end ||' '|| Trim(a.numerointcalle),
                  SELECT limit 1 case when substr(f.nombrecalle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(f.nombrecalle) else Trim(f.nombrecalle) end||' '|| case when nvl(a.numeroextcalle,'') = '' or nvl(a.numeroextcalle,'') = 'S/N' or nvl(a.numeroextcalle,'') = 'S/n' or nvl(a.numeroextcalle,'') = 's/N' or nvl(a.numeroextcalle,'') = 's/n' or a.numeroextcalle = '0' or a.numeroextcalle = '00' or a.numeroextcalle = '000' or a.numeroextcalle = '0000' then 'SN' else Trim(a.numeroextcalle) end ||' '||case when nvl(a.numerointcalle,'') = '' or nvl(a.numerointcalle,'') = 'S/N' or nvl(a.numerointcalle,'') = 'S/n' or nvl(a.numerointcalle,'') = 's/N' or nvl(a.numerointcalle,'') = 's/n' or a.numerointcalle = '0' or a.numerointcalle = '00' or a.numerointcalle = '000' or a.numerointcalle = '0000' then 'SN' else Trim(a.numerointcalle) end,
		nvl(Trim(g.nombrezona),''),nvl(Trim(g.municipiozona),''), Trim(b.estado_abrev),-- a.cod_postal,
            lpad(trim(a.cod_postal),5,"0"),manzana,andador,lote,edificio,entrada,codini,codfin,
                nvl(substr( CodigoPOstalZona,1,5),''),
                case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' or f.nombrecalle like '%SIN%NOMBRE%' or f.nombrecalle like '%sin%nombre%' then 1 else 0 end,
                a.pais, a.ciudad, a.estado
            INTO vcalle, vcolonia,vdelegacion,vestado,vcod_postal, 
                 vmanzana,vandador,vlote,vedificio,ventrada, vcodini,vcodfin,
                 vlCodigoPOstalZona, scalle_conocido, cpais, vclave_ciudad, vclave_edo
            FROM bdinteg:si_direcciones_actual a 
                      left outer join estados_sepomex b on lpad(trim(a.estado),2,"0") = b.c_estado
                      left outer join bdisolic:ss_circulo_edos c on lpad(trim(a.estado),2,"0") = c.clave
                      left outer join bdinteg:si_catzonas g on (a.numerociudad = g.numerociudad and a.numerocolonia = g.numerocolonia)
                      left outer join bdinteg:si_catcalles f on a.numerocalle = f.numerocalle
            WHERE a.numcte= vnumcte
            AND a.tipo_dir="1"
            AND c.empresa = "001";
		  
		   if vcalle is null then let vcalle = ''; end if;
		   
		---Inicia Bloque de Validaciones Sepomex --GEV
		---Validacion por Codigo POstal del Cliente, Delegacion, Estado
        SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE d_codigo = vcod_postal AND substr(d_mnpio,1,27) = vdelegacion AND estado_abrev = vestado
          group by d_mnpio, d_codigo ;  
        ---Validacion por Delegacion, Estado  
        IF nvl(iCP,0) <= 0 THEN
         SELECT first 1 count(*), d_mnpio, d_codigo INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE  substr(d_mnpio,1,27) = vdelegacion AND estado_abrev = vestado
         group by d_mnpio, d_codigo ;    
		 
        end if;
		---Validacion por Colonia, Estado  		
        IF nvl(iCP,0) <= 0 THEN
         SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE  trim(substr(d_asenta,1,32)) = vcolonia AND estado_abrev = vestado
          group by d_mnpio, d_codigo ;  
		  
        end if;
		---Validacion por Codigo POstal de Zona, Estado  		
        IF nvl(iCP,0) <= 0 THEN
         SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE  d_codigo = lpad(vlCodigoPOstalZona,5,"0") AND estado_abrev = vestado
         group by d_mnpio, d_codigo ;   
		 
        end if;
		IF nvl(iCP,0) <= 0 THEN
         SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP, vlMnpioReportar, vlCodigoReportar
          FROM sepomex WHERE  d_codigo = vcod_postal AND estado_abrev = vestado
          group by d_mnpio, d_codigo ;  
		  
        end if;
		---Validacion por Codigo POstal de Zona, Estado  		
        IF nvl(iCP,0) > 0 THEN
          let vdelegacion =vlMnpioReportar;
          let vcod_postal =vlCodigoReportar;
		END IF;  
       ---Fin de Bloque de Validaciones Sepomex --GEV

     let existe = length(vcalle);
       if existe < 40 then
         let vcalle1 = "";
         if vmanzana > 0 then
           let vcalle1 ="mza. "|| vmanzana;
         end if
         if vandador > 0 then
           let vcalle1 =trim(vcalle1)||"and. "||     vandador ;
         end if
         if vlote > 0 then
           let vcalle1 =trim(vcalle1)||"lt. "  ||   vlote ;
         end if
         if vedificio > 0 then
           let vcalle1 =trim(vcalle1)||"ed. "||     vedificio ;
         end if
         if ventrada > 0 then
           let vcalle1 =trim(vcalle1)||"ent. "||     ventrada ;
         end if
       let vcalle = trim(vcalle)||' '||trim(vcalle1);
       end if

     let existe = length(vcalle);
     let existe1 = 0;
     let vquita = "";
     let vespacio = "";
     let hueco = 0;
     while existe1 < existe
       if vcalle[1,1]="~" then
       else
        if vcalle[1,1]="#" and vespacio = "" then
           let vespacio = "F";
        end if
        if vespacio = "F" then
          let vquita = trim(vquita)||" "||vcalle[1,1];
          let vespacio = "";
          let hueco = 1;
        else
          let vquita = trim(vquita)||vcalle[1,1];
        end if;
        if vcalle[1,1]=" " then
           let vespacio = "F";
        end if;
       end if;
       let vcalle = vcalle[2,40];
       let existe1 = existe1 + 1;
     end while;
     let vcalle = trim(vquita);
     if hueco = 0 then
       let vcalle = trim(vquita)||"1";
     end if;
     let vciudad = "";

     if vcod_postal IS NULL then
        let vcod_postal = "00000";
     end if;

--IPCB Abr15 - Envio de tramas sin direccion, asignacion de blando, para armar la trama
	/*IF vestado is null or vestado = '' THEN
		LET vcalle = '';
		LET vcolonia = '';
		LET vdelegacion = ''; 
		LET vestado = '';
		LET vcod_postal = '';
		LET vmanzana = '';
		LET vandador = '';
		LET vlote = '';
		LET vedificio = '';
		LET ventrada = '';
		LET vcodini = '';
		LET vcodfin = '';
		LET vlCodigoPOstalZona = '';

		LET bmotivo = 1;
	ELSE 
		LET bmotivo =0;
	END IF;	 */

	IF scalle_conocido = 1 THEN
       LET vcalle = 'DOMICILIO CONOCIDO SN';
    END IF;

-- Agrega Direccion
     let vsegmento2_pa = lpad(length(trim(vcalle)),2,"0")||vcalle;
     let tb_calle         = vcalle;
-- Agrega Colonia
    if vcolonia is not null then
        let vsegmento2_pa = trim(vsegmento2_pa)||'01'||
                            lpad(length(trim(vcolonia)),2,"0")||vcolonia;
        let tb_colonia       = vcolonia;
	ELSE
		let vsegmento2_pa = trim(vsegmento2_pa)||'0100'; --RQM 09 467_Version 14
	end if;

-- Agrega Delegacion o MunicipÃ­o
--     if vdelegacion is null or vdelegacion = "" then
--        LET vdelegacion = 'CONOCIDO';
--     end if

        --let vsegmento2_pa = trim(vsegmento2_pa)||'02'||
        --                       lpad(length(trim(vdelegacion)),2,"0")||vdelegacion;
        --let tb_delegacion     = vdelegacion;
         
         if vdelegacion != "" then      
            let vsegmento2_pa = trim(vsegmento2_pa)||'02'||
                                   lpad(length(trim(vdelegacion)),2,"0")||vdelegacion;
            let tb_delegacion     = vdelegacion;
		ELIF vdelegacion = "" or vdelegacion is null then
			let vsegmento2_pa = trim(vsegmento2_pa)||'0200'; --RQM 09 467_Version 14  
         end if                          

-- Agrega Ciudad
--     if vciudad != "" then
--       let vsegmento2_pa = trim(vsegmento2_pa)||'03'||
--                           lpad(length(trim(vciudad)),2,"0")||vciudad;
--       let tb_ciudad        = vciudad;
--     end if

 -- Agrega Ciudad
		--IF vdelegacion = '' OR vdelegacion IS NULL THEN  --RQM 09 467_Version 14
         SELECT nombre INTO vciudad
           FROM bdinteg:si_ciudades 
          WHERE estado = lpad(trim(vclave_edo),2,"0") --vclave_edo
            AND ciudad = lpad(trim(vclave_ciudad),3,"0"); --vclave_ciudad;       

         if vciudad = '' OR vciudad is null then 
			let vciudad = '';  
			let vsegmento2_pa = trim(vsegmento2_pa)||'0300'; --RQM 09 467_Version 14
         else--		     IF vciudad != "" AND vciudad IS NOT NULL THEN
           let vsegmento2_pa = trim(vsegmento2_pa)||'03'||
                               lpad(length(trim(vciudad)),2,"0")||vciudad;
           let tb_ciudad        = vciudad;
         END IF
		--END IF

       /* IF (vdelegacion is null or vdelegacion = '') and (vciudad is null or vciudad = '')  THEN
                let vsegmento2_pa = trim(vsegmento2_pa)||'02'||
                                       lpad(length(trim(vdelegacion)),2,"0")||vdelegacion;
                let tb_delegacion     = vdelegacion;
                
                let vsegmento2_pa = trim(vsegmento2_pa)||'03'||
                                   lpad(length(trim(vciudad)),2,"0")||vciudad;
                let tb_ciudad        = vciudad;
    	END IF;*/


-- Agrega Estado
     let vsegmento2_pa = trim(vsegmento2_pa)||'04'||
     lpad(length(trim(vestado)),2,"0")||trim(vestado);
     let tb_estado        = trim(vestado);

-- Agrega Codigo Postal
     let vsegmento2_pa = trim(vsegmento2_pa)||'05'||
     lpad(length(trim(vcod_postal)),2,"0")||trim(vcod_postal);
     let tb_cod_postal    = trim(vcod_postal);

    -- Agregar origen del domicilio (pais) RQM 09 467_Version 14
    let vsegmento2_pa = trim(vsegmento2_pa)||'1202MX';
           let tb_codigo_pais  = 'MX';

     let vsegmento2_pa = 'PA'||trim(vsegmento2_pa);

 END IF; -- DOM ACTUALIZADO DEL CTE (Fin)

	 
-- INICIA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14
  --Etiqueta PE -Nombre o Razo Social del empleador 
        SELECT nvl(a.nombre_empresa,'')
          INTO cnombre_empleador
          FROM bdinteg:si_ingresos a
         WHERE a.numcte = vNumcte
           AND a.sec_ingreso = (SELECT max(sec_ingreso)
                                  FROM bdinteg:si_ingresos 
                                 WHERE numcte = a.numcte);

      --LET cnombre_empleador = NVL(cnombre_empleador,'');

     IF cnombre_empleador = '' or cnombre_empleador is null THEN
        IF vprofesion = '06' THEN 
           LET cnombre_empleador = 'DESEMPLEADO';
        ELIF vprofesion = '10' THEN
           LET cnombre_empleador = 'TRABAJADOR INDEPENDIENTE';
        ELIF vprofesion = '12' THEN
           LET cnombre_empleador = 'LABORES DEL HOGAR';
        ELIF vprofesion = '15' THEN
           LET cnombre_empleador = 'ESTUDIANTE';
        ELIF vprofesion = '16' THEN
           LET cnombre_empleador = 'JUBILADO';
        ELSE 
           LET cnombre_empleador = 'TRABAJADOR INDEPENDIENTE';  
        END IF;

	ELSE
	    LET iLong_NomEmpleador = LENGTH(cnombre_empleador);
        CALL bdinteg:"informix".sp_esnumerico (cnombre_empleador) RETURNING cEsNumerico;   --RQM 09 599 Hallazgos Banxico 2021 - MACF
		IF cEsNumerico = 'V' THEN
		   LET cnombre_empleador_temp = 'TRABAJADOR INDEPENDIENTE';
		   LET cnombre_empleador = cnombre_empleador_temp;
		ELIF cEsNumerico = 'F' THEN 
		   IF iLong_NomEmpleador >= 1 AND iLong_NomEmpleador <= 2 THEN
			  LET cnombre_empleador = 'TRABAJADOR INDEPENDIENTE';
		   ELIF iLong_NomEmpleador = 4 THEN
			  LET cnombre_empleador_temp = REPLACE(nvl(trim(cnombre_empleador),""),'OTRO','TRABAJADOR INDEPENDIENTE');
			  LET cnombre_empleador_temp = REPLACE(nvl(trim(cnombre_empleador_temp),""),'OTRA','TRABAJADOR INDEPENDIENTE');
			  LET cnombre_empleador = cnombre_empleador_temp;
		   ELIF iLong_NomEmpleador = 5 THEN	  
			  LET cnombre_empleador_temp = REPLACE(nvl(trim(cnombre_empleador),""),'OTROS','TRABAJADOR INDEPENDIENTE');
			  LET cnombre_empleador = cnombre_empleador_temp;
		   END IF; 
		END IF;  --RQM 09 599 Hallazgos Banxico 2021 - MACF 
    END IF;

     let vsegmento_pe = lpad(length(trim(cnombre_empleador)),2,"0")  || trim(cnombre_empleador);
     let tb_nombre_empleador = trim(cnombre_empleador);

	 
   --SELECT registro INTO vsegmento_pe_base_t
   SELECT first 1 num_credito,registro INTO vNumcred_pe_base, vsegmento_pe_base_t 
     FROM bdiburo:br_burofisicas_cnr_base
    WHERE num_credito = vnum_credito
      AND tipo_segmento='PE';
   
   LET vsegmento_pe_base = NVL(vsegmento_pe_base_t,'');
   LET vNumcred_pe_base = NVL(vNumcred_pe_base,''); 
  
 
   IF vsegmento_pe_base = ''  THEN 
      LET cArma_PE = 'S';
   ELSE
      -- VALIDAR SI DIR. EMPLEO CAMBIO EN EL ULTIMO MES
	  SELECT fecha_insert INTO vFecha_insert_trabajo
	    FROM bdinteg:si_direcciones_actual 
	   WHERE numcte = vnumcte
		 AND tipo_dir = '2';
   
	   LET vFecha_insert_trabajo = NVL(vFecha_insert_trabajo,date(1));
	   
	   IF vFecha_insert_trabajo >= vfecha_ini THEN
          LET cArma_PE = 'S';
	   ELSE  
	     -- VALIDAR LA PROFESION
		 SELECT razon_social INTO vrazon_social_prev
		   FROM bdiburo:br_burofisicas_describe_cnr
		   WHERE num_credito = vnum_credito;
		   
		   LET vrazon_social_prev = NVL(vrazon_social_prev,'');
		   
	       IF TRIM(cnombre_empleador) <> TRIM(vrazon_social_prev) THEN
		      LET cArma_PE = 'S';
		   ELSE
   
			 /*SELECT registro INTO vsegmento_pe_base_t
			   FROM bdiburo:br_burofisicas_cnr_base
			  WHERE num_credito = vnum_credito
				AND tipo_segmento='PE';
			   
			  LET vsegmento_pe_base = NVL(vsegmento_pe_base_t,'');*/
			  LET cArma_PE = 'N';

		  END IF;
		  
	   END IF;
   END IF;
	
	
   IF cArma_PE = 'S' OR (vsegmento_pe_base = '' OR vsegmento_pe_base is NULL) THEN  --- VALIDACION CAMBIO DOM TRAB (Ini)
	   --LET cArma_PE = 'S';	 
	 
	 
	--SELECT limit 1 case when substr(f.nombrecalle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(f.nombrecalle) else trim(f.nombrecalle) end ||' '|| case when nvl(a.numeroextcalle,'') = '' or a.numeroextcalle::INT = 0 then 'SN' else Trim(a.numeroextcalle) end ||' '|| Trim(a.numerointcalle),
	SELECT limit 1 case when substr(f.nombrecalle,1,1) in('0','1','2','3','4','5','6','7','8','9') then "CALLE "||trim(f.nombrecalle) else Trim(f.nombrecalle) end ||' '|| case when nvl(a.numeroextcalle,'') = '' or nvl(a.numeroextcalle,'') = 'S/N' or nvl(a.numeroextcalle,'') = 'S/n' or nvl(a.numeroextcalle,'') = 's/N' or nvl(a.numeroextcalle,'') = 's/n' or a.numeroextcalle = '0' or a.numeroextcalle = '00' or a.numeroextcalle = '000'  or a.numeroextcalle = '0000' then 'SN' else Trim(a.numeroextcalle) end ||' '||case when nvl(a.numerointcalle,'') = '' or nvl(a.numerointcalle,'') = 'S/N' or nvl(a.numerointcalle,'') = 'S/n' or nvl(a.numerointcalle,'') = 's/N' or nvl(a.numerointcalle,'') = 's/n' or a.numerointcalle = '0' or a.numerointcalle = '00' or a.numerointcalle = '000' or a.numerointcalle = '0000' then 'SN' else Trim(a.numerointcalle) end,
	nvl(Trim(g.nombrezona),''),nvl(Trim(g.municipiozona),''), Trim(b.estado_abrev),-- a.cod_postal,
	lpad(trim(a.cod_postal),5,"0"),manzana,andador,lote,edificio,entrada,codini,codfin,
		nvl(substr( CodigoPOstalZona,1,5),''),
		case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' or f.nombrecalle like '%SIN%NOMBRE%' or f.nombrecalle like '%sin%nombre%' then 1 else 0 end,
		a.pais, a.ciudad, a.estado
	INTO vcalle_pe, vcolonia_pe,vdelegacion_pe,vestado_pe,vcod_postal_pe, 
		 vmanzana_pe,vandador_pe,vlote_pe,vedificio_pe,ventrada_pe, vcodini_pe,vcodfin_pe,
		 vlCodigoPOstalZona_pe, scalle_conocido_pe, cpais_pe, vclave_ciudad_pe, vclave_edo_pe
	FROM bdinteg:si_direcciones_actual a 
	          left outer join estados_sepomex b on lpad(trim(a.estado),2,"0") = b.c_estado
			  left outer join bdisolic:ss_circulo_edos c on lpad(trim(a.estado),2,"0") = c.clave
			  left outer join bdinteg:si_catzonas g on (a.numerociudad = g.numerociudad and a.numerocolonia = g.numerocolonia)
			  left outer join bdinteg:si_catcalles f on a.numerocalle = f.numerocalle
	WHERE a.numcte= vnumcte
	AND a.tipo_dir="2"
	AND c.empresa = "001";

	---Inicia Bloque de Validaciones Sepomex PE
	---Validacion por Codigo POstal del Cliente, Delegacion, Estado
	SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
	  FROM sepomex WHERE d_codigo = vcod_postal_pe AND substr(d_mnpio,1,27) = vdelegacion_pe AND estado_abrev = vestado_pe
	  group by d_mnpio, d_codigo ;
	  
	---Validacion por Delegacion, Estado  
	IF nvl(iCP_pe,0) <= 0 THEN
		 SELECT first 1 count(*), d_mnpio, d_codigo INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
		  FROM sepomex WHERE  substr(d_mnpio,1,27) = vdelegacion_pe AND estado_abrev = vestado_pe
		 group by d_mnpio, d_codigo ;    
	END IF;
	
	---Validacion por Colonia, Estado  		
	IF nvl(iCP_pe,0) <= 0 THEN
		 SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
		  FROM sepomex WHERE  trim(substr(d_asenta,1,32)) = vcolonia_pe AND estado_abrev = vestado_pe
		  group by d_mnpio, d_codigo ;  
	END IF;
	
	---Validacion por Codigo POstal de Zona, Estado  		
	IF nvl(iCP_pe,0) <= 0 THEN
		 SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
		  FROM sepomex WHERE  d_codigo = lpad(vlCodigoPOstalZona_pe,5,"0") AND estado_abrev = vestado_pe
		 group by d_mnpio, d_codigo ;   
	END IF;

	IF nvl(iCP_pe,0) <= 0 THEN
		 SELECT first 1 count(*), d_mnpio, d_codigo  INTO iCP_pe, vlMnpioReportar_pe, vlCodigoReportar_pe
		  FROM sepomex WHERE  d_codigo = vcod_postal_pe AND estado_abrev = vestado_pe
		  group by d_mnpio, d_codigo ;  
	END IF;
	
	---Validacion por Codigo POstal de Zona, Estado  		
	IF nvl(iCP_pe,0) > 0 THEN
		  let vdelegacion_pe =vlMnpioReportar_pe;
		  let vcod_postal_pe =vlCodigoReportar_pe;
	END IF;  
	---Fin de Bloque de Validaciones Sepomex PE

	let existe = length(vcalle_pe);

	IF existe < 40 THEN
	 let vcalle_pe1 = "";
	 IF vmanzana_pe > 0 THEN
	   let vcalle_pe1 ="mza. "|| vmanzana_pe;
	 END IF
	 IF vandador_pe > 0 THEN
	   let vcalle_pe1 =trim(vcalle_pe1)||"and. "||     vandador_pe ;
	 END IF
	 IF vlote_pe > 0 THEN
	   let vcalle_pe1 =trim(vcalle_pe1)||"lt. "  ||   vlote_pe ;
	 END IF
	 IF vedificio_pe > 0 THEN
	   let vcalle_pe1 =trim(vcalle_pe1)||"ed. "||     vedificio_pe ;
	 END IF
	 IF ventrada_pe > 0 THEN
	   let vcalle_pe1 =trim(vcalle_pe1)||"ent. "||     ventrada_pe ;
	 END IF
	let vcalle_pe = trim(vcalle_pe)||' '||trim(vcalle_pe1);
	END IF

	let existe = length(vcalle_pe);
	let existe1 = 0;
	let vquita = "";
	let vespacio = "";
	let hueco = 0;
	while existe1 < existe
	if vcalle_pe[1,1]="~" THEN
	else
	if vcalle_pe[1,1]="#" and vespacio = "" THEN
	   let vespacio = "F";
	END if
	if vespacio = "F" THEN
	  let vquita = trim(vquita)||" "||vcalle_pe[1,1];
	  let vespacio = "";
	  let hueco = 1;
	else
	  let vquita = trim(vquita)||vcalle_pe[1,1];
	END if;
	if vcalle_pe[1,1]=" " THEN
	   let vespacio = "F";
	END if;
	END if;
	let vcalle_pe = vcalle_pe[2,40];
	let existe1 = existe1 + 1;
	END while;
	let vcalle_pe = trim(vquita);
	if hueco = 0 THEN
	let vcalle_pe = trim(vquita)||"1";
	END if;
	let vciudad_pe = "";

	if vcod_postal_pe IS NULL THEN
	let vcod_postal_pe = "00000";
	END if;

	--Envio de tramas sin direccion, asignacion de blanco, para armar la trama
	IF vestado_pe is null or vestado_pe = '' THEN
	LET vcalle_pe = '';
	LET vcolonia_pe = '';
	LET vdelegacion_pe = ''; 
	LET vestado_pe = '';
	LET vcod_postal_pe = '';
	LET vmanzana_pe = '';
	LET vandador_pe = '';
	LET vlote_pe = '';
	LET vedificio_pe = '';
	LET ventrada_pe = '';
	LET vcodini_pe = '';
	LET vcodfin_pe = '';
	LET vlCodigoPOstalZona_pe = '';

	LET bmotivo = 1;
	ELSE 
	LET bmotivo =0;
	END IF;

	IF scalle_conocido_pe = 1 THEN
	   LET vcalle_pe = 'DOMICILIO CONOCIDO SN';
	END IF;

	-- Agrega Direccion
	let vsegmento_pe = trim(vsegmento_pe)||'00'||
						lpad(length(trim(vcalle_pe)),2,"0")||vcalle_pe;
	let tb_calle_pe         = vcalle_pe;

	-- Agrega Colonia
	if vcolonia_pe is not null then
	let vsegmento_pe = trim(vsegmento_pe)||'02'||
						lpad(length(trim(vcolonia_pe)),2,"0")||vcolonia_pe;
	let tb_colonia_pe       = vcolonia_pe;
	ELSE
	let vsegmento_pe = trim(vsegmento_pe)||'0200'; --IPCB ene2018
	end if;

	-- Agrega Delegacion o Municipio
	if vdelegacion_pe != "" then       
		let vsegmento_pe = trim(vsegmento_pe)||'03'||
							   lpad(length(trim(vdelegacion_pe)),2,"0")||vdelegacion_pe;
		let tb_delegacion_pe     = vdelegacion_pe;
	elif vdelegacion_pe = "" or vdelegacion_pe is null then
		let vsegmento_pe = trim(vsegmento_pe)||'0300'; --IPCB ene2018                 
    end if;
		-- Agrega Ciudad
			--estado y ciudad de si_direcciones_actual para con eso consultar el nombre de la ciudad en si_ciudades.
		SELECT nvl(nombre,'') INTO vciudad_pe
		FROM bdinteg:si_ciudades 
		WHERE estado = vclave_edo_pe
		AND ciudad = vclave_ciudad_pe;       

		if vciudad_pe = '' OR vciudad_pe is null then 
			let vciudad_pe = '';  
			let vsegmento_pe = trim(vsegmento_pe)||'0400'; --IPCB ene2018
		else-- vciudad_pe != ''  then
			let vsegmento_pe = trim(vsegmento_pe)||'04'||
							   lpad(length(trim(vciudad_pe)),2,"0")||vciudad_pe;
			let tb_ciudad_pe        = vciudad_pe;
		end if;
	--end if;

	-- Agrega Estado
	let vsegmento_pe = trim(vsegmento_pe)||'05'||
	lpad(length(trim(vestado_pe)),2,"0")||trim(vestado_pe);
	let tb_estado_pe        = trim(vestado_pe);

	-- Agrega Codigo Postal
	let vsegmento_pe = trim(vsegmento_pe)||'06'||
	lpad(length(trim(vcod_postal_pe)),2,"0")||trim(vcod_postal_pe);
	let tb_cod_postal_pe    = trim(vcod_postal_pe);

	-- Agregar origen del domicilio De la razÃ³n social (pais) 
	let vsegmento_pe = trim(vsegmento_pe)||'1802MX';
	let tb_origen_razon_soc  = 'MX';

	let vsegmento_pe = 'PE'||trim(vsegmento_pe);           	  
-- TERMINA SEGMENTO PE (EMPLEO DEL CLIENTE)  --RQM 09 467_Version 14

   END IF;
-- Agregar Clave y nombre del otorgante
     let vsegmento3_tl = '02TL0110'||vclave_usu||'02'||
         lpad(length(trim(vnombre_usu)),2,"0")||vnombre_usu;
     let tb_clave_usu         = vclave_usu;
     let tb_nombre_usu        = vnombre_usu;

-- Agregar Numero de credito
     let vsegmento3_tl = trim(vsegmento3_tl)||'04'||
         lpad(length(trim(vnum_credito)),2,"0")||trim(vnum_credito);
     let tb_num_credito       = trim(vnum_credito);

-- Agregar Tipo de responsabilidad de la cuenta
     -- I = Individual
     -- J = Mancomunada
     -- C = Obligado Solidario
     let vsegmento3_tl = trim(vsegmento3_tl)||'0501I0601';
     let tb_responsabilidad   = "I";

-- Agregar Tipo de cuenta y tipo de producto
    -- TIPO DE CUENTA
    -- I = Pagos Fijos
    -- M = Hipotecaria
    -- O = Sin limite preestablecido
    -- R = Revolvente

    -- TIPO DE PRODUCTO
    -- CC = Tarjeta de Credito
    -- PL = Prestamo Personal
    -- if cNumProducto = '6800' then
      --  let tb_tipo_cuenta       = "R";
     --else
        let tb_tipo_cuenta       = "I";
    -- end if;

     let vsegmento3_tl = trim(vsegmento3_tl)||tb_tipo_cuenta||'0702'||tb_tipo_producto;

--Agregar Clave Monetaria
  -- MX = Pesos
  -- US = Dolares
  -- UD = Unidades de Inversion
     let vsigla_div = "MX";
     let vsegmento3_tl = trim(vsegmento3_tl)||'0802MX';
     let tb_clave_monetaria   = "MX";

-- Agregar Numero de Pagos
	IF cNumProducto = '6800' AND  v_dispact = 0 THEN
		let vnum_pagos_sndip = '1';
	    let vsegmento3_tl = trim(vsegmento3_tl)||'10'||
		lpad(length(vnum_pagos_sndip),2,"0")||trim(vnum_pagos_sndip);
		let tb_num_pagos         = trim(vnum_pagos_sndip);	
	ELSE
		 let vsegmento3_tl = trim(vsegmento3_tl)||'10'||
		 lpad(length(vnum_pagos),2,"0")||trim(vnum_pagos);
		 let tb_num_pagos         = trim(vnum_pagos);
	END IF;
-- Agregar Fecuencia de Pagos
   -- M = Mensual
     let vsegmento3_tl = trim(vsegmento3_tl)||'1101'||vfrecpago;
     let tb_frecpago          = vfrecpago;

-- Agregar Monto a Pagar 
-- Se adelanta la obtencion de saldos
     let vsaldo_actual = 0;
     let v_interes = 0;

-- Venta de Cartera ini
     if vstatus_cred not in ('CV') then
             select nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0),
                    nvl(monto_vencido + mto_venc_trasp,0), nvl(sdo_no_exig,0),
                    nvl(sdo_cap_insoluto,0)
               into vsaldo_vig, vsaldo_venc, v_interes,
                    vmontoinsoluto
               from bdicred:sd_maesdoscontcrd 
              where fecha = vfecha_hoy
                and empresa = "001"
                and num_credito = vnum_credito;

        if vsaldo_vig is null then let vsaldo_vig = 0; end if; 
        if vsaldo_venc is null then let vsaldo_venc = 0; end if; 
        if v_interes is null then let v_interes = 0; end if; 
	
		if vmontoinsoluto is null then let vmontoinsoluto = 0; end if;


        if ( v_interes is null or v_interes <= 0 ) then
           let v_interes = 0;
        end if;
            
     end if;

     select limit 1 capital_mto_cuota into vcuota_cap
       from bdicred:sd_amortiza_creditocrd
      where empresa = "001"  and num_credito = vnum_credito
        and fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd
                  where empresa = "001"  and num_credito = vnum_credito);

-- Se agregan exepciones de pago y saldo
     let vsaldo_vig = vsaldo_vig + v_interes;
     let vrea_cal_cuota = 0;

--IPCB 190913:redondeos a uno
     if (vcuota_cap > 0 and vcuota_cap < 1) then
        let vcuota_cap = 1;
     end if;
     if (vsaldo_vig > 0 and vsaldo_vig < 1) then
        let vsaldo_vig = 1;
     end if;
     if (vmontoinsoluto > 0 and vmontoinsoluto < 1) then
        let vmontoinsoluto = 1;
     end if;

     if round(vcuota_cap,0) = 0 then let vcuota_cap = round(vsaldo_vig,0); end if;

     if vcuota_cap > 0 and vstatus_cred not in ('FF','FI') then
       let vmonto = round(vcuota_cap,0);
     else
       let vmonto = 0;
     end if
--el monto a pagar no puede ser mayor al saldo actual
     if vmonto > vsaldo_vig then let vmonto = vsaldo_vig; end if;
	 
--IPCB 26nov14: Agrega validacion para  saldo_act si <= 0 entonces monto_pagar	=0 para crÃ©ditos con Baja	 
	 if vidbaja = 'BAJA' and vsaldo_vig <= 0 then
		   let vmonto = 0;
	 end if;	 

     let vsegmento3_tl = trim(vsegmento3_tl)||'1209'||
                         lpad(round(vmonto,0),9,"0");
     let tb_monto_pagar       = round(vmonto,0);

-- Agregar Fecha de Apertura de la Cuenta
     let vfecha_apertura = vpago_int;
     let vano = year(vfecha_apertura);
     let vmes = lpad(month(vfecha_apertura),2,"0");
     let vdia = lpad(day(vfecha_apertura),2,"0");
     let vsegmento3_tl = trim(vsegmento3_tl)||'1308'||vdia||vmes||vano;
     let tb_fecha_apertura    = vdia||vmes||vano;

  -- Obtencion de la ultima fecha de pago
     let vpago_cap = "";

 -- Obtencion de la ultima fecha de pago

----validar pagos para pp y credinomina
     select fecha_max
       into vpago_cap
       from cred_movhis
      where num_credito = vnum_credito;

     if vpago_cap is null then let vpago_cap = vfecha_apertura; end if;

     if vpago_int > mdy(month(vfecha_hoy),day(vfecha_hoy),year(vfecha_hoy)) then
        let vpago_int = mdy(month(vfecha_hoy),day(vfecha_hoy),year(vfecha_hoy));
     end if
     if vpago_cap > mdy(month(vfecha_hoy),day(vfecha_hoy),year(vfecha_hoy)) then
        let vpago_cap = mdy(month(vfecha_hoy),day(vfecha_hoy),year(vfecha_hoy));
     end if

-- Agregar Fecha de Ultimo Pago
     if (vpago_cap is not null and vpago_cap <> '01/01/1900') then  --RQM 09 467_Version 14
         let vano = year(vpago_cap);
         let vmes = lpad(month(vpago_cap),2,"0");
         let vdia = lpad(day(vpago_cap),2,"0");
    
         let vsegmento3_tl = trim(vsegmento3_tl)||'1408'||vdia||vmes||vano;
         let tb_fecha_ult_pago    = vdia||vmes||vano;
     else
         let vsegmento3_tl = trim(vsegmento3_tl)||'1400';  --RQM 09 467_Version 14
            let tb_fecha_ult_pago    = ''; 
     end if;
     
-- Agregar Fecha de Ultima Compra
	 IF cNumProducto = '6800' THEN
	     LET vpago_int = vfec_utdisp_flex;
	 END IF;

	 if (vpago_int is not null and vpago_int <> '01/01/1900' AND vsec_credito >= 1) then  --RQM 09 467_Version 14
		 let vano = year(vpago_int);
		 let vmes = lpad(month(vpago_int),2,"0");
		 let vdia = lpad(day(vpago_int),2,"0");
	
		 let vsegmento3_tl = trim(vsegmento3_tl)||'1508'||vdia||vmes||vano;
		 let tb_fecha_ult_compra  = vdia||vmes||vano;
	 else
		 let vsegmento3_tl = trim(vsegmento3_tl)||'1500';
		 let tb_fecha_ult_compra  = ''; 
	 end if;

     let tb_fecha_cierre = '';
-- Venta de cartera ini
        if (vstatus_cred = "CV") then
            let vano = year(vfecha_venta);
            let vmes = lpad(month(vfecha_venta),2,"0");
            let vdia = lpad(day(vfecha_venta),2,"0");
            let vsegmento3_tl = trim(vsegmento3_tl)||'1608'||vdia||vmes||vano;
            let dtFechaCierre      = vfecha_venta;
            let tb_fecha_cierre      = vdia||vmes||vano;
        --ELIF vstatus_cred = "FF"  THEN RQM 09 343-0
        ELIF vstatus_cred IN ("FF","FI")  THEN
		--IPCB Nov2019-RQM 09 542 Fecha_cierre flexible
			IF cNumProducto = '6800' THEN
				select case when fecha_cancela between vfecha_ini and vfecha_hoy then fecha_cancela else date(1) end fec_cancel_l,
					  case when fecha_ult_pf between vfecha_ini and vfecha_hoy then fecha_ult_pf else date(1) end fec_cancel_p
					INTO dt_feccan_linea, dt_feccan_pres
				from bdicred:sd_linea_prestamo
				where num_credito = vnum_credito;
				
				IF   dt_feccan_linea = date(1)  AND dt_feccan_pres <> date(1) THEN
					LET dtFechaLiquidacion = dt_feccan_pres;
				ELIF dt_feccan_linea <> date(1) AND dt_feccan_pres = date(1) THEN
					LET dtFechaLiquidacion = dt_feccan_linea;
				ELSE
					IF dt_feccan_linea >= dt_feccan_pres THEN
						LET dtFechaLiquidacion = dt_feccan_linea;
					ELSE
						LET dtFechaLiquidacion = dt_feccan_pres;
					END IF;
				END IF;
			ELSE 
		--IPCB Abr15- Se cambia el campo fecha_ult_pago  por fecha_proceso para asignar  al campo tb_fecha_cierre		
				select fecha_proceso into dtFechaLiquidacion
				from bdicred:sd_maecredanexocrd 
				where empresa='001' and num_credito=vnum_credito;
			END IF;
            LET vano = YEAR(dtFechaLiquidacion);
            LET vmes = LPAD(MONTH(dtFechaLiquidacion),2,"0");
            LET vdia = LPAD(DAY(dtFechaLiquidacion),2,"0");
            LET vsegmento3_tl = TRIM(vsegmento3_tl)||'1608'||vdia||vmes||vano;
            let dtFechaCierre      = dtFechaLiquidacion;
            LET tb_fecha_cierre = vdia||vmes||vano;
        END IF;

--     if (dtFechaCierre < vfecha_ini) or (dtFechaCierre > vfecha_hoy) then
--        INSERT INTO bdiburo:br_burofisicas_concilia_cnr (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CNP',vfecha_hoy);
--        continue foreach;
--     end if;

-- Agregar Fecha Reporte
     let vsegmento3_tl = trim(vsegmento3_tl)||'1708'||vfecha_reporte;
     let tb_fecha_reporte     = vfecha_reporte;

     if (vsaldo_venc is null) or (vsaldo_venc < 0) then let vsaldo_venc = 0; end if

     let vsaldo_actual = vsaldo_vig;
     let vdiasvenc = 0;
     --if vstatus_cred = "FF" or (vmonto = 0 and vstatus_cred <> "CV") then RQM 09 343-0
     if vstatus_cred IN("FF","FI") or (vmonto = 0 and vstatus_cred <> "CV") then
           let vsaldo_venc = 0;
           let vcuotas_ven = 0;
     end if;
     let vdiasvenc = 0;
     if vsaldo_venc > 0 then
       let vfecha_alta = vpago_cap;
       let vdiasvenc = vfecha_hoy - vpago_cap;
       if vdiasvenc <= 0 then
          let vdiasvenc = 1;
       end if
     end if

    let vcredito_maximo = vmonto_otorgado;

     if (vcredito_maximo is null) or (vcredito_maximo < 0) then let vcredito_maximo = 0.0; end if
     let vsegmento3_tl = trim(vsegmento3_tl)||'2109'||
                           lpad(round(vcredito_maximo,0),9,"0");
     let tb_credito_maximo    = round(vcredito_maximo,0);

-- Agregar Saldo Actual
     if (vsaldo_actual > 0 and vsaldo_actual < 1) then
         let vsaldo_actual = 1;
     end if;

     let vsaldo_actual = round(vsaldo_actual,0);
     let tb_saldo_actual  = vsaldo_actual;
     
	 if vsaldo_actual is null or vsaldo_actual = '' then --- RQM 09 467_Version 14
            let vsegmento3_tl = trim(vsegmento3_tl)||'2200';
     end if; 
	 
     if vsaldo_actual >= 0 then
      let vsegmento3_tl = trim(vsegmento3_tl)||'2210'||
                         lpad(round(vsaldo_actual,0),10,"0");
     else
      let vsaldo_actual = abs(vsaldo_actual);
      let vsegmento3_tl = trim(vsegmento3_tl)||'2210'||
                              lpad(round(vsaldo_actual,0),9,"0")||"-";
     end if
     
-- Agregar Limite de Credito
     if vmonto_otorgado > 0 and vmonto_otorgado < 1 then
        let vmonto_otorgado=1;
     end if;

	 IF vmonto_otorgado is null or vmonto_otorgado = '' THEN
		let vsegmento3_tl = trim(vsegmento3_tl)||'2300';
	 ELSE
		let vsegmento3_tl = trim(vsegmento3_tl)||'2309'||
						 lpad(round(vmonto_otorgado,0),9,"0");
		let tb_monto_otorgado    = round(vmonto_otorgado,0);
	 END IF;
	 
     if (vsaldo_venc > vsaldo_actual and vstatus_cred <> "CV")  then
        let vsaldo_venc = vsaldo_actual;
     end if;

-- Se agregan pagos vencidos
-- Cartera vendida ini
-- Se lee la historia de amortizaciones para la cartera vendida
    if vstatus_cred = 'CV' then
        select count(*)
         into vcuotas_ven
         from bdicred:sd_amortiza_creditocrd_vendida b
        where empresa = '001'
          and num_credito = vnum_credito
          and capital_status in (2,7,6);
    --elif vstatus_cred = "FF" then RQM 09 343-0
    elif vstatus_cred IN("FF","FI") then
        let vcuotas_ven = 0;
    else 
      let vcuotas_ven = 0;

      SELECT mto_fin_ven_trasp::smallint mto_fin_ven_trasp 
        INTO vcuotas_ven
       FROM bdicred:sd_maecredcrd b, bdicred:sd_maesdoscontcrd c,
      OUTER bdicred:sd_definicioncrd d, bdicred:sd_maecredanexocrd e
      WHERE b.empresa = '001'
        AND b.empresa = c.empresa
        AND b.num_credito = c.num_credito
        AND c.fecha = vfecha_hoy
        AND d.num_producto = b.num_producto
        AND b.empresa = d.empresa
        AND b.num_credito=e.num_credito
        AND b.num_credito = vnum_credito;
    end if;

-- Cartera vendida fin
   if vcuotas_ven is null then let vcuotas_ven = 0; end if;

-- Agregar Saldo vencido
     IF vIndProceso = 'Q' THEN --RQM 09 549
		let tb_saldo_venc = vMontoQuita;
			let vsegmento3_tl = trim(vsegmento3_tl)||'2409'|| 
								lpad(round(tb_saldo_venc,0),9,"0");
	 ELSE
		 if nvl(vsaldo_venc,'') = '' then --- RQM 09 467_Version 14
				let vsegmento3_tl = trim(vsegmento3_tl)||'2400';
		 else       
			 if vsaldo_venc > 0 and vsaldo_venc < 1 then
				let vsaldo_venc=1;
			 end if;

		   let vsegmento3_tl = trim(vsegmento3_tl)||'2409'||
								 lpad(round(vsaldo_venc,0),9,"0");
		   let tb_saldo_venc        = round(vsaldo_venc,0);
		 end if;
	 END IF;

-- Agregar Numero de Pagos Vencidos
   if vsaldo_venc > 0 then
       let vsegmento3_tl = trim(vsegmento3_tl)||'2504'||
                         lpad(vcuotas_ven,4,"0");
       let tb_cuotas_ven        = vcuotas_ven;
   end if

-- LEE INDICADOR DE CREDITO CRD INI
    --IF cNumProducto = '6800' and vstatus_cred = 'AA' THEN 
	IF (cNumProducto = '6800' AND vstatus_cred IN ('AA','E1') AND vsaldo_venc <= 0 ) then
	  LET vfecha_vencido = date(1);
	  LET vdiasatraso = 0;
	  
	  select  fecha_ultimo_pago_h -- fecha de ultimo pago
		  into vfechaultpago
		  from bdicred:sd_indicador_cred_crd
		 where empresa = "001"
		   and num_credito = vnum_credito;
	  
	ELSE  
		select nvl(fecha_vencido,date(1)), -- primer incumplimiento
			   nvl(dias_atraso,0), -- dias de atraso
			   fecha_ultimo_pago_h -- fecha de ultimo pago
		  into vfecha_vencido,
			   vdiasatraso,
			   vfechaultpago
		  from bdicred:sd_indicador_cred_crd
		 where empresa = "001"
		   and num_credito = vnum_credito;
   END IF;	   
	  

    if (vdiasatraso is null or vdiasatraso < 0) then
        let vdiasatraso = 0;
    end if;

    if (vfechaultpago is not null) then
        select nvl(sum(monto),0)
          into vmontolutpago -- monto de ultimo pago de crd
          from bdicred:sd_movhiscrd
         where empresa = '001'
           and num_credito = vnum_credito
           and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd)
           and codigo_ref = 1
           and fecha_mov = vfechaultpago
           and reversado = 'N';
    else
        let vmontolutpago = 0;
    end if;

-- Para clave de Observacion "CV" reportar MOP al momento de la venta
   if (vstatus_cred = 'CV') then
        select nvl((vfecha_venta - fecha_vencto) + 1,0)
          into vdiasatraso
          from bdicred:sd_maecredanexocrd
         WHERE empresa = '001'
           and num_credito = vnum_credito;
        let vmontoinsoluto = 0;
-- Para cuentas que se reesturcturan el MOP es "01"
   --elif (vstatus_cred = 'FC' or vstatus_cred = 'FF') then RQM 09 343-0
   elif (vstatus_cred = 'FC' or vstatus_cred = 'FF' or vstatus_cred = 'FI') then
        let vdiasatraso = 0;
        let vmontoinsoluto = 0;
   end if;

-- LEE INDICADOR DE CREDITO CRD FIN

-- Agregar Forma de Pago
   -- UR = Cuenta sin informacion
   -- 00 = Muy reciente para ser informada
   -- 01 = Pago puntual y adecudo
   -- 02 = Atraso de 01 a 29 dias
   -- 03 = Atraso de 30 a 59 dias
   -- 04 = Atraso de 60 a 89 dias
   -- 05 = Atraso de 90 a 119 dias
   -- 06 = Atraso de 120 a 149 dias
   -- 07 = Atraso de 150 hasta 12 meses
   -- 96 = atraso de 12 meses
   -- 97 = Cuenta con deuda parcial o total sin recuperar
   -- 99 = Fraude cometido por el cliente 
  
---Modificar de acuerdo a circulo
	if (vIndProceso = 'Q') then --RQM 09 549
		let vmop = "97";
	else
		if (vdiasatraso    =   0) then
			let vmop = "01";
		elif (vdiasatraso >=   1 and vdiasatraso <=  29) then
			let vmop = "02";
		elif (vdiasatraso >=  30 and vdiasatraso <=  59) then
			let vmop = "03";
		elif (vdiasatraso >=  60 and vdiasatraso <=  89) then
			let vmop = "04";
		elif (vdiasatraso >=  90 and vdiasatraso <= 119) then
			let vmop = "05";
		elif (vdiasatraso >= 120 and vdiasatraso <= 149) then
			let vmop = "06";
		elif (vdiasatraso >= 150 and vdiasatraso <= (abs(date(vfecha_hoy)) - abs(date(vfecha_hoy - 1 units year))) - 1) then
			let vmop = "07";
		else
			let vmop = "96";
		end if;
	end if;
 
   let vsegmento3_tl = trim(vsegmento3_tl)||'2602'||vmop;
   let tb_mop               = vmop;

--IPCB27sep2013 Integra consulta a sd_maecredcontCRD para validar estatus de credito anterior 
   select status_cred, nvl(monto_vencido + mto_venc_trasp,0)  
     into vstatus_credAnt, mVenc_mesant
     from bdicred:sd_maecredcontcrd a,
	      bdicred:sd_maesdoscontcrd b
    where a.empresa = '001'
      and a.fecha = vfecha_fin_mes_ant
	  and a.fecha = b.fecha
      and a.num_credito = vnum_credito
	  and a.num_credito = b.num_credito;

	if (vIndProceso = 'Q' AND vmop = '97') THEN --RQM 09 549
			LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'LC';
			LET tb_clave_obs               = 'LC';
-- Venta de Cartera ini
    elif (vstatus_cred = 'CV') then
        let vsegmento3_tl = trim(vsegmento3_tl)||'3002'||'CV';
        let tb_clave_obs               = 'CV';
    --elif vstatus_cred = "FF" then RQM 09 343-0
    elif vstatus_cred IN ("FF","FI") then
           LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'CC';
           LET tb_clave_obs               = 'CC';
--IPCB 070813: Se agrega la asignacion de la clave de observacion 'PC'
    elif vmop >= '02' and vmop <> 'UR'  then
           LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'PC';
           LET tb_clave_obs               = 'PC';
--IPCB01oct2013 Se agrega la asignacion de la clave de observacion 'EL'
    --elif (vstatus_credAnt in ('BT','BA') and vstatus_cred = 'AA') then 
	elif vstatus_credAnt in ('BT','BA','E1','E2','E3') AND mVenc_mesant > 0 and vstatus_cred IN ('AA','E1') AND vsaldo_venc <= 0 then
           LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'EL';
           LET tb_clave_obs               = 'EL';
    end if;



-- NUEVOS CAMPOS
-- FECHA DE PRIMER INCUMPLIMIENTO

   if vfecha_vencido is null then let vfecha_vencido = date(1); end if;

   let vano = year(vfecha_vencido);
   let vmes = lpad(month(vfecha_vencido),2,"0");
   let vdia = lpad(day(vfecha_vencido),2,"0");

    IF vmop in ('00','01','UR') THEN  --RQM 09 467_Version 14
		LET vsegmento3_tl = TRIM(vsegmento3_tl)||'430801011900';
		LET tb_fecha_vencimiento = '01011900';
	ELSE
	   LET vsegmento3_tl = TRIM(vsegmento3_tl)||'4308'||vdia||vmes||vano;
	   LET tb_fecha_vencimiento = vdia||vmes||vano;
	END IF;
-- SALDO INSOLUTO DEL PRINCIPAL

   LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'4410'||
                        lpad(round(vmontoinsoluto,0),10,"0");
   let tb_monto_insoluto = round(vmontoinsoluto,0);

-- MONTO DE ULTIMO PAGO
   LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'4509'||
                        lpad(round(vmontolutpago,0),9,"0");
   let tb_ultimo_pago = round(vmontolutpago,0);


-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
	
   IF vdiasatraso < 0   THEN LET vdiasatraso = 0;   END IF;	
   IF vdiasatraso > 999 THEN LET vdiasatraso = 999; END IF;	
	
   LET vsegmento3_tl    = TRIM(vsegmento3_tl)||'4903'||	lpad(vdiasatraso,3,"0");
-- ahj?   LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'4903'|| lpad(vdiasatraso,3,"0");	
   let tb_dias_atraso = vdiasatraso;

	-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN


-- PLAZO EN MESES RQM 09 467_Version 14
   IF  vfrecpago = 'S' THEN
	 LET vplazo_meses = ROUND((vnum_pagos / 2),2);
   ELIF vfrecpago = 'W' THEN
	 LET vplazo_meses = ROUND((vnum_pagos / 4),2);
   ELSE
     LET vplazo_meses = ROUND((vnum_pagos / 1),2);
   END IF;
   
   LET splazo_meses = trim(TO_CHAR(vplazo_meses,"###,###.##"));	
   
   IF splazo_meses = '.00' THEN
	 LET splazo_meses = '0.00';
   END IF;
                     
   let vsegmento3_tl  = TRIM(vsegmento3_tl)||'50'|| lpad(length(trim(splazo_meses)),2,"0") || trim(splazo_meses) ;
   let tb_plazo_meses = vplazo_meses;    

--Monto del CrÃ©dito en la originacion RQM 09 467_Version 14
   IF nvl(vmonto_otorgado,'') <> '' THEN
      LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'5109'||
                  lpad(round(vmonto_otorgado,0),9,"0");
      LET tb_monto_originacion = round(vmonto_otorgado,0);
   ELSE
      LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'510200';
      LET tb_monto_originacion = 0;
   END IF;

    
-- Fin

-- Agergar clave de observacion
-- Venta de Cartera Fin
   let vsegmento3_tl = trim(vsegmento3_tl)||'9903FIN';
   let vsegmento3_tl = 'TL'||trim(vsegmento3_tl);

   ---No se va a actualizar la informacion de concilia
   ---CONSIDERAR ESTO
   
--IPCB Abr15- Se modifica la validacion para integrar a la cinta los registros marcados con CSS en la concilia .
     /*if bmotivo = 1 then
--IPCB 19mar14 - Cambia por insert de motivo de CSE x CSS para homologar las claves con el proceso burofisicas
 		INSERT INTO bdiburo:br_burofisicas_concilia_cnr VALUES('001',cNumProducto,vnum_credito,'CSS',vfecha_hoy,
                   tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
                   tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
                   tb_codigo_pais, tb_nombre_empleador,tb_calle_pe,tb_colonia_pe,tb_delegacion_pe,tb_ciudad_pe,tb_estado_pe,tb_cod_postal_pe, tb_origen_razon_soc,  --RQM 09 467_Version 14 
                   tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar,
                   tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado,
                   tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota, 
				   tb_plazo_meses, tb_monto_originacion, --RQM 09 467_Version 14
				   vstatus_cred , tb_monto_insoluto);
     else
        IF iCP IS NULL THEN LET iCP = 0; END IF;

        IF iCP > 0 THEN
           let vsegmento3_tl = replace(vsegmento3_tl,'TGD0924BAN',vclave_usu_bc);
        ELSE
--IPCB 19mar14 -Cambia por insert corto para no duplicar informacion ya que estos registros se insertan en la br_burofisicas_describe_cnr		
			INSERT INTO bdiburo:br_burofisicas_concilia_cnr (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CPS',vfecha_hoy);	   
        END IF;
	 end if;
	 */

	 IF cArma_PN = 'S' THEN 
	 	 
        let vnumreg = vnumreg + 1;
        insert into br_burofisicas_cnr
        values(vnumreg,vsegmento_pn);
		
		IF vNumcred_pn_base = '' THEN
		   INSERT INTO br_burofisicas_cnr_base(num_credito,registro,tipo_segmento,fecha_reporte) 
			   VALUES(vnum_credito,TRIM(vsegmento_pn),'PN',vfecha_hoy);
		ELSE
		   UPDATE br_burofisicas_cnr_base SET registro =TRIM(vsegmento_pn), fecha_reporte = vfecha_hoy
			  WHERE num_credito = vnum_credito AND tipo_segmento= 'PN';
		END IF;
	 ELIF cArma_PN = 'N' THEN
		let vnumreg = vnumreg + 1;
		 insert into br_burofisicas_cnr
		 values(vnumreg,TRIM(vsegmento_pn_base));
	 END IF;
	 
	 
	-- IF vpago_int >= vfecha_ini  THEN
	 IF cArma_PA = 'S' THEN
        let vnumreg = vnumreg + 1;
        insert into br_burofisicas_cnr
        values(vnumreg,vsegmento2_pa);

		IF vNumcred_pa_base = '' THEN
		   INSERT INTO br_burofisicas_cnr_base(num_credito,registro,tipo_segmento,fecha_reporte) 
		    VALUES(vnum_credito,TRIM(vsegmento2_pa),'PA',vfecha_hoy);
		ELSE
		   UPDATE br_burofisicas_cnr_base SET registro =TRIM(vsegmento2_pa), fecha_reporte = vfecha_hoy
			WHERE num_credito = vnum_credito AND tipo_segmento= 'PA';
		END IF;
	 ELIF cArma_PA = 'N' THEN
		 let vnumreg = vnumreg + 1;
		 insert into br_burofisicas_cnr
		 values(vnumreg,TRIM(vsegmento_pa_base));
	END IF;
	 
		
	 IF cArma_PE = 'S' THEN	
        let vnumreg = vnumreg + 1; --RQM 09 467_Version 14 
		insert into br_burofisicas_cnr
		  values(vnumreg,vsegmento_pe);
        
		IF vNumcred_pe_base = '' THEN
		   INSERT INTO br_burofisicas_cnr_base(num_credito,registro,tipo_segmento,fecha_reporte) 
		    VALUES(vnum_credito,TRIM(vsegmento_pe),'PE',vfecha_hoy);
		ELSE
		   UPDATE br_burofisicas_cnr_base SET registro =TRIM(vsegmento_pe), fecha_reporte = vfecha_hoy
			  WHERE num_credito = vnum_credito AND tipo_segmento= 'PE'; 
		END IF;
	 ELSE
		 let vnumreg = vnumreg + 1;
		 insert into br_burofisicas_cnr
		 values(vnumreg,TRIM(vsegmento_pe_base));
    END IF;
	 
	 
			  
        let vnumreg = vnumreg + 1;
        insert into br_burofisicas_cnr
        values(vnumreg,vsegmento3_tl);

		
		--IF vpago_int >= vfecha_ini THEN
		IF vNumcred_describe = '' THEN
-- Se agrega tabla para grabar informacion enviada
--IPCB 19mar14 - Se integran al insert vstatus_cred,cNumProducto
			insert into br_burofisicas_describe_cnr
			   values (tb_num_credito, tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
					   tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
					   tb_codigo_pais, tb_nombre_empleador,tb_calle_pe,tb_colonia_pe,tb_delegacion_pe,tb_ciudad_pe,tb_estado_pe,tb_cod_postal_pe, tb_origen_razon_soc,  --RQM 09 467_Version 14  
					   tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar,
					   tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado,
					   tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota,tb_fecha_vencimiento,tb_monto_insoluto,tb_ultimo_pago,tb_plazo_meses,tb_monto_originacion,vstatus_cred ,cNumProducto,
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
					   tb_dias_atraso
-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN					   
					   );
			--let contador_commit = contador_commit  + 1;
			let actualiza_esta = actualiza_esta + 1;
			LET iRegsInsert = iRegsInsert+1;
			
		ELIF vindproceso = 'Q' THEN -- RQM 09 549
		  UPDATE br_burofisicas_describe_cnr SET estado_civil = tb_estado_civil,
		    calle= tb_calle, colonia = tb_colonia, delegacion = tb_delegacion, ciudad = tb_ciudad, estado= tb_estado, cod_postal= tb_cod_postal, 
			origen_dom= tb_codigo_pais,
			razon_social= tb_nombre_empleador, calle_pe= tb_calle_pe, colonia_pe= tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe,
			estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE
			clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, tipo_producto= tb_tipo_producto,
	        clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura,  	
	        fecha_ult_pago= tb_fecha_ult_pago, fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
	        credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc, cuotas_ven= tb_cuotas_ven,  	
	        mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento, monto_insoluto= tb_monto_insoluto,
	        ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion, status_cred= vstatus_cred, num_producto= cNumProducto,
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
			dias_atraso = tb_dias_atraso
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN
			WHERE num_credito = tb_num_credito;
			
			LET iRegsUpd = iRegsUpd+1;
		
		ELIF (cArma_PN = 'S'	AND cArma_PA = 'S' AND  cArma_PE = 'S') THEN  -- UPD 1
		
		  UPDATE br_burofisicas_describe_cnr SET estado_civil = tb_estado_civil, --PN
		    calle= tb_calle, colonia = tb_colonia, delegacion = tb_delegacion, ciudad = tb_ciudad, estado= tb_estado, cod_postal= tb_cod_postal, 
			origen_dom= tb_codigo_pais, -- PA
			razon_social= tb_nombre_empleador, calle_pe= tb_calle_pe, colonia_pe= tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe,
			estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE
			clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, tipo_producto= tb_tipo_producto,
	        clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura,  	
	        fecha_ult_pago= tb_fecha_ult_pago, fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
	        credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc, cuotas_ven= tb_cuotas_ven,  	
	        mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento, monto_insoluto= tb_monto_insoluto,
	        ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion, status_cred= vstatus_cred, num_producto= cNumProducto,
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
			dias_atraso = tb_dias_atraso
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN			
			WHERE num_credito = tb_num_credito;
			
			LET iRegsUpd = iRegsUpd+1;
		ELIF (cArma_PN = 'S'	AND cArma_PA = 'N' AND  cArma_PE = 'S') THEN -- UPD 2

		    UPDATE br_burofisicas_describe_cnr SET estado_civil = tb_estado_civil, --PN
		    --calle= tb_calle, colonia = tb_colonia, delegacion = tb_delegacion, ciudad = tb_ciudad, estado= tb_estado, cod_postal= tb_cod_postal, 
			--origen_dom= tb_codigo_pais, -- PA
			razon_social= tb_nombre_empleador, calle_pe= tb_calle_pe, colonia_pe= tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe,
			estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE
			clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, tipo_producto= tb_tipo_producto,
	        clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura,  	
	        fecha_ult_pago= tb_fecha_ult_pago, fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
	        credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc, cuotas_ven= tb_cuotas_ven,  	
	        mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento, monto_insoluto= tb_monto_insoluto,
	        ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion, status_cred= vstatus_cred, num_producto= cNumProducto,
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
			dias_atraso = tb_dias_atraso
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN			
			WHERE num_credito = tb_num_credito;
			
			LET iRegsUpd = iRegsUpd+1;
		
		ELIF (cArma_PN = 'S'	AND cArma_PA = 'N' AND  cArma_PE = 'N') THEN  -- UPD 3
		
		    UPDATE br_burofisicas_describe_cnr SET estado_civil = tb_estado_civil, --PN
		    --calle= tb_calle, colonia = tb_colonia, delegacion = tb_delegacion, ciudad = tb_ciudad, estado= tb_estado, cod_postal= tb_cod_postal, 
			--origen_dom= tb_codigo_pais, -- PA
			--razon_social= tb_nombre_empleador, calle_pe= tb_calle_pe, colonia_pe= tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe,
			--estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE
			clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, tipo_producto= tb_tipo_producto,
	        clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura,  	
	        fecha_ult_pago= tb_fecha_ult_pago, fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
	        credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc, cuotas_ven= tb_cuotas_ven,  	
	        mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento, monto_insoluto= tb_monto_insoluto,
	        ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion, status_cred= vstatus_cred, num_producto= cNumProducto,
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
			dias_atraso = tb_dias_atraso
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN			
			WHERE num_credito = tb_num_credito;
			
			LET iRegsUpd = iRegsUpd+1;

		ELIF (cArma_PN = 'S'	AND cArma_PA = 'S' AND  cArma_PE = 'N') THEN  -- UPD 4

		    UPDATE br_burofisicas_describe_cnr SET estado_civil = tb_estado_civil, --PN
		    calle= tb_calle, colonia = tb_colonia, delegacion = tb_delegacion, ciudad = tb_ciudad, estado= tb_estado, cod_postal= tb_cod_postal, 
			origen_dom= tb_codigo_pais, -- PA
			--razon_social= tb_nombre_empleador, calle_pe= tb_calle_pe, colonia_pe= tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe,
			--estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE
			clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, tipo_producto= tb_tipo_producto,
	        clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura,  	
	        fecha_ult_pago= tb_fecha_ult_pago, fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
	        credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc, cuotas_ven= tb_cuotas_ven,  	
	        mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento, monto_insoluto= tb_monto_insoluto,
	        ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion, status_cred= vstatus_cred, num_producto= cNumProducto,
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
			dias_atraso = tb_dias_atraso
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN			
			WHERE num_credito = tb_num_credito;
			
			LET iRegsUpd = iRegsUpd+1;
		
		ELIF (cArma_PN = 'N'	AND cArma_PA = 'S' AND  cArma_PE = 'S') THEN		-- UPD 5
		
		   UPDATE br_burofisicas_describe_cnr SET --estado_civil = tb_estado_civil, --PN
		    calle= tb_calle, colonia = tb_colonia, delegacion = tb_delegacion, ciudad = tb_ciudad, estado= tb_estado, cod_postal= tb_cod_postal, 
			origen_dom= tb_codigo_pais, -- PA
			razon_social= tb_nombre_empleador, calle_pe= tb_calle_pe, colonia_pe= tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe,
			estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE
			clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, tipo_producto= tb_tipo_producto,
	        clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura,  	
	        fecha_ult_pago= tb_fecha_ult_pago, fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
	        credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc, cuotas_ven= tb_cuotas_ven,  	
	        mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento, monto_insoluto= tb_monto_insoluto,
	        ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion, status_cred= vstatus_cred, num_producto= cNumProducto,
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
			dias_atraso = tb_dias_atraso
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN			
			WHERE num_credito = tb_num_credito;
			
			LET iRegsUpd = iRegsUpd+1;
		
		ELIF (cArma_PN = 'N'	AND cArma_PA = 'S' AND  cArma_PE = 'N') THEN  -- UPD 6
		
		    UPDATE br_burofisicas_describe_cnr SET --estado_civil = tb_estado_civil, --PN
		    calle= tb_calle, colonia = tb_colonia, delegacion = tb_delegacion, ciudad = tb_ciudad, estado= tb_estado, cod_postal= tb_cod_postal, 
			origen_dom= tb_codigo_pais, -- PA
			--razon_social= tb_nombre_empleador, calle_pe= tb_calle_pe, colonia_pe= tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe,
			--estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE
			clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, tipo_producto= tb_tipo_producto,
	        clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura,  	
	        fecha_ult_pago= tb_fecha_ult_pago, fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
	        credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc, cuotas_ven= tb_cuotas_ven,  	
	        mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento, monto_insoluto= tb_monto_insoluto,
	        ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion, status_cred= vstatus_cred, num_producto= cNumProducto,
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
			dias_atraso = tb_dias_atraso
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN			
			WHERE num_credito = tb_num_credito;
			
			LET iRegsUpd = iRegsUpd+1;
		
		ELIF (cArma_PN = 'N'	AND cArma_PA = 'N' AND  cArma_PE = 'S') THEN   -- UPD 7
		
		    UPDATE br_burofisicas_describe_cnr SET --estado_civil = tb_estado_civil, --PN
		    --calle= tb_calle, colonia = tb_colonia, delegacion = tb_delegacion, ciudad = tb_ciudad, estado= tb_estado, cod_postal= tb_cod_postal, 
			--origen_dom= tb_codigo_pais, -- PA
			razon_social= tb_nombre_empleador, calle_pe= tb_calle_pe, colonia_pe= tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe,
			estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE
			clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, tipo_producto= tb_tipo_producto,
	        clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura,  	
	        fecha_ult_pago= tb_fecha_ult_pago, fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
	        credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc, cuotas_ven= tb_cuotas_ven,  	
	        mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento, monto_insoluto= tb_monto_insoluto,
	        ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion, status_cred= vstatus_cred, num_producto= cNumProducto,
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
			dias_atraso = tb_dias_atraso
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN			
			WHERE num_credito = tb_num_credito;
		
			LET iRegsUpd = iRegsUpd+1;
		
		ELIF (cArma_PN = 'N'	AND cArma_PA = 'N' AND  cArma_PE = 'N') THEN  -- UPD 8 Actualiza solamente la info de TL
		
            UPDATE br_burofisicas_describe_cnr SET --estado_civil = tb_estado_civil, --PN
		    --calle= tb_calle, colonia = tb_colonia, delegacion = tb_delegacion, ciudad = tb_ciudad, estado= tb_estado, cod_postal= tb_cod_postal, 
			--origen_dom= tb_codigo_pais, -- PA
			--razon_social= tb_nombre_empleador, calle_pe= tb_calle_pe, colonia_pe= tb_colonia_pe, delegacion_pe= tb_delegacion_pe, ciudad_pe= tb_ciudad_pe,
			--estado_pe= tb_estado_pe, cod_postal_pe= tb_cod_postal_pe, origen_razon_soc= tb_origen_razon_soc, --PE
			clave_usu= tb_clave_usu, nombre_usu= tb_nombre_usu, responsabilidad= tb_responsabilidad, tipo_cuenta= tb_tipo_cuenta, tipo_producto= tb_tipo_producto,
	        clave_monetaria= tb_clave_monetaria, num_pagos= tb_num_pagos, frecpago= tb_frecpago, monto_pagar= tb_monto_pagar, fecha_apertura= tb_fecha_apertura,  	
	        fecha_ult_pago= tb_fecha_ult_pago, fecha_ult_compra= tb_fecha_ult_compra, fecha_cierre= tb_fecha_cierre, fecha_reporte= tb_fecha_reporte,
	        credito_maximo= tb_credito_maximo, saldo_actual= tb_saldo_actual, monto_otorgado= tb_monto_otorgado, saldo_venc= tb_saldo_venc, cuotas_ven= tb_cuotas_ven,  	
	        mop= tb_mop, clave_obs= tb_clave_obs, int_calculo= vrea_cal_cuota, fecha_vencimiento= tb_fecha_vencimiento, monto_insoluto= tb_monto_insoluto,
	        ultimo_pago= tb_ultimo_pago, plazo_meses= tb_plazo_meses, monto_originacion= tb_monto_originacion, status_cred= vstatus_cred, num_producto= cNumProducto,
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 INI
			dias_atraso = tb_dias_atraso
		-- SE AGREGA segmento (49) DÃ­as de vencido (campo nuevo) JOM 24/SEP/2026 FIN			
			WHERE num_credito = tb_num_credito;
		
			LET iRegsUpd = iRegsUpd+1;
		
		END IF;
		
		let contador_commit = contador_commit  + 1;
		
    let cNumProducto = '';
    let cCredExterno = '';
    let vmonto_otorgado=0; 
    let vsaldo_vig = 0; 
    let vsaldo_venc=0;
	let mVenc_mesant=0;

    LET vsegmento_pe = '';
    LET scalle_conocido = 0;
    LET cpais = '';
    LET vclave_ciudad = '';
    LET vclave_edo = '';
    LET tb_codigo_pais = '';
    LET tb_origen_razon_soc = '';
    LET cnombre_empleador = '';
    LET tb_nombre_empleador = '';
    LET tb_plazo_meses = '';
    LET tb_monto_originacion = 0;
	LET cArma_PN = '';
    LET cArma_PA = '';
    LET cArma_PE = '';
	LET vsegmento_pn_base = '';
	LET vsegmento_pa_base = '';
	LET vsegmento_pe_base = '';
	LET vsegmento_pn_base_t   = '';
    LET vsegmento_pa_base_t   = '';
    LET vsegmento_pe_base_t   = '';
	LET vestado_civil_prev    = '';
    LET vprofesion_prev       = '';
    LET cCambio_estado_civil  = '';
    LET vrazon_social_prev    = '';
	LET vano = "";
    LET vmes = "";
    LET vdia = "";
	LET vNumcred_describe     = '';
	LET vNumcred_pn_base      = '';
	LET vNumcred_pa_base      = '';
	LET vNumcred_pe_base      = '';
    LET cnombre_empleador_temp = '';
	LET iLong_NomEmpleador     = 0;
    LET cEsNumerico            = '';  

   IF (contador_commit >= 2000) THEN
      COMMIT WORK;
      LET contador_commit = 0; 
      BEGIN WORK;
   END IF;

  end foreach

  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;

  LET sCommit = 0;
  LET cNumCredito = 'Inicia proc. conciliacion';

  BEGIN;
	CREATE INDEX "informix".idx_br_burofisicas_cnr          ON "informix".br_burofisicas_cnr(numreg);
  COMMIT;
  --BEGIN;
  --CREATE INDEX "informix".idx_br_burofisicas_describe_cnr ON "informix".br_burofisicas_describe_cnr(num_credito) in dbs_movhis_idx3 ONLINE;
  --COMMIT;
  --BEGIN;
  --CREATE INDEX "informix".inxburoconcilia_cnr             ON "informix".br_burofisicas_concilia_cnr(empresa, num_producto, num_credito, motivo, fecha_cinta) in dbs_movhis_idx3 ONLINE;
  --COMMIT;

  update statistics medium for table "informix".br_burofisicas_cnr;
  --update statistics medium for table "informix".br_burofisicas_describe_cnr;
  --update statistics medium for table "informix".br_burofisicas_concilia_cnr;


  --EXECUTE PROCEDURE burofisicas_concilia_cnr(vfecha_reporte) INTO vcodret;

  drop table sepomex;
  drop table creditos_sel;
  drop table cred_bqc;

  --let cMensajeFin = 'Creditos procs. ' || iTotalProcesados;
  --let cMensajeFin = 'Creditos procs. ' || iTotalProcesados;
  let cMensajeFin = 'Creditos procs. ' || iTotalProcesados || ' I= ' || iRegsInsert || ' - U= '|| iRegsUpd;
  
  /* --- SOLO PRUEBAS
    LET vHora = ''; LET vDia1 = '';
     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vDia1 
      from sysmaster:sysshmvals;

     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora 
      from sysmaster:sysshmvals;

      INSERT INTO bdiburo:br_cronometro_cnr(accion,fecha,hora) values('Final',vDia1, vHora);
    --- SOLO PRUEBAS */
  CALL bdicobranza:sp_inserta_bitacora_cob_2('001', cProceso, vcodret, cMensajeRet, '03') RETURNING cCod_ret_2; 
  
  return vcodret,cMensajeFin;
END;
end procedure;