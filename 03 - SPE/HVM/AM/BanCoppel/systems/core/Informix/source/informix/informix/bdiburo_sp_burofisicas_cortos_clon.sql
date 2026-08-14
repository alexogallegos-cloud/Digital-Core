CREATE PROCEDURE "informix".sp_burofisicas_cortos_clon()
RETURNING CHAR(6),
          CHAR(100);


-- Autor: Roque Enrique Solis Campaña
-- Fecha de Modificación 19/08/2009
-- Observaciones: Se modifica el acceso a la tabla si_feriado de la base de datos bdinteg,
--                eliminación de variables innecesarias, omitir las comparaciones con los 
--                estatus y los filtros o validaciones que se hicieran con los mismos debido a 
--                que solo se espera créditos con estatus "AA", contemplar la eliminación de las 
--                tablas temporales.
-- Fecha de Modificación 20/08/2009
-- Observaciones: Se modificaron el índice de la tabla br_burofisicas_cortos.

DEFINE vcodret                       CHAR(6);
DEFINE vfecha_hoy                    DATE;
DEFINE vPriDiaMes                    DATE;
DEFINE vcredito_maximo               DECIMAL(18,2);
DEFINE vcredito_maximo1              DECIMAL(18,2);
DEFINE vrea_cal_cuota                INTEGER;
DEFINE vmonto                        DECIMAL(18);
DEFINE vheader                       CHAR(150);
DEFINE vsegmento_pn                  CHAR(375);
DEFINE vsegmento1_pn                 CHAR(375);
DEFINE vsegmento2_pa                 CHAR(326);
DEFINE vsegmento4_tl                 CHAR(436);
DEFINE vsegmento5_tr                 CHAR(255);
DEFINE vapell_paterno                CHAR(26);
DEFINE vapell_materno                CHAR(26);
DEFINE vnombre1                      CHAR(26);
DEFINE vnombre2                      CHAR(26);
DEFINE vfecha_nac                    DATE;
DEFINE vanio                         CHAR(4);
DEFINE vmes                          CHAR(2);
DEFINE vdia                          CHAR(2);

DEFINE vanioup                       CHAR(4);
DEFINE vmesup                        CHAR(2);
DEFINE vdiaup                        CHAR(2);

DEFINE vrfc                          CHAR(13);
DEFINE vestado_civil                 CHAR(1);
DEFINE vsexo                         CHAR(1);
DEFINE vcalle,vcalle1                CHAR(40);
DEFINE vcolonia                      CHAR(40);
DEFINE vdelegacion                   CHAR(40);
DEFINE vestado                       CHAR(4);
DEFINE vcod_postal                   CHAR(10);
DEFINE vnum_credito                  CHAR(25);
DEFINE vnum_producto                 CHAR(4);
DEFINE vtp_linea                     CHAR(4);
DEFINE vnum_pagos                    CHAR(5);
DEFINE vfrecuencia                   CHAR(1);
DEFINE vfecha_apertura               DATE;
DEFINE vnumcte                       CHAR(20);
DEFINE vencabezado1                  CHAR(4);
DEFINE vversion                      CHAR(2);
DEFINE vclave_usu_bc                 CHAR(10);
DEFINE vnombre_usu                   CHAR(16);
DEFINE vciclo                        CHAR(2);
DEFINE vfecha_reporte                CHAR(8);
DEFINE vfechaup                CHAR(8);
DEFINE vuso_futuro                   CHAR(10);
DEFINE vinf_adicional                CHAR(98);
DEFINE vsql                          CHAR(2000);
DEFINE varchivo                      CHAR(60);
DEFINE varchivo_des                  CHAR(60);
--DEFINE i                             SMALLINT;
DEFINE vfecha_ini                    DATE;
DEFINE vpago_cap, vpago_int          DATE;
DEFINE vfrecpago                     CHAR(1);
DEFINE vcuota_cap                    INTEGER;
DEFINE vcuotas_ven                   SMALLINT;
DEFINE vmonto_otorgado, vsaldo_vig, vsaldo_venc, vsaldo_actual,v_interes        DECIMAL(18,2);
DEFINE vfechacuota                   DATE;
DEFINE vdiasvenc                     SMALLINT;
DEFINE vmop                          CHAR(2);
DEFINE vnumreg                       INTEGER;
DEFINE existe                        SMALLINT;
DEFINE vciudad                       CHAR(40);
DEFINE vruta_interfase               CHAR(200);
DEFINE vsecuencia                    SMALLINT;
DEFINE vmanzana                      SMALLINT;
DEFINE vandador                      SMALLINT;
DEFINE vlote                         SMALLINT;
DEFINE vedificio                     SMALLINT;
DEFINE ventrada                      SMALLINT;
DEFINE vdiacuota                     SMALLINT;
DEFINE sCommit                       SMALLINT;
DEFINE contador_commit               INTEGER;
DEFINE dtFecha_ultimo_reporte        DATE;
DEFINE vmontoinsoluto                DECIMAL(18,2);      
DEFINE vfecha_vencido                DATE;
DEFINE vmontolutpago                 DECIMAL(18,2);      
DEFINE vdiasatraso                   INTEGER;
DEFINE vfechaultpago                 DATE;
DEFINE vfechaultcompra               DATE;

DEFINE iPeriodo                      INTEGER;
DEFINE dtFechaProxReporte            DATE;
DEFINE sProceso                      SMALLINT;
DEFINE cStatusProc                   CHAR(1);
DEFINE cMensajeFin                   CHAR(100);
DEFINE iTotalProcesados              INTEGER;
DEFINE vStatusCred                   CHAR(02);
DEFINE vstatus_credAnt               CHAR(02);
DEFINE vfecha_fin_mes_ant            date;
define vsaldo_vencAnt                decimal(18,2);

-- Agrega variables para tabla de datos en texto
-- Segmento PN
DEFINE tb_apell_paterno          CHAR(26);
DEFINE tb_apell_materno          CHAR(26);
DEFINE tb_nombre1                CHAR(26);
DEFINE tb_nombre2                CHAR(26);
DEFINE tb_fecha_nac              CHAR(08);
DEFINE tb_rfc                    CHAR(13);
DEFINE tb_nacionalidad           CHAR(03);
DEFINE tb_estado_civil           CHAR(1);
DEFINE tb_sexo                   CHAR(1);

-- Segmento PA
DEFINE tb_calle                  CHAR(40);
DEFINE tb_colonia                CHAR(40);
DEFINE tb_delegacion             CHAR(40);
DEFINE tb_ciudad                 CHAR(40);
DEFINE tb_estado                 CHAR(4);
DEFINE tb_cod_postal             CHAR(10);
DEFINE tb_codigo_pais   		 CHAR(2);  --RQM 09 467_Version 14  

-- Segmento TL
DEFINE tb_clave_usu              CHAR(10);
DEFINE tb_nombre_usu             CHAR(16);
DEFINE tb_num_credito            CHAR(25);
DEFINE tb_responsabilidad        CHAR(01);
DEFINE tb_tipo_cuenta            CHAR(01);
DEFINE tb_tipo_producto          CHAR(02);
DEFINE tb_clave_monetaria        CHAR(02);
DEFINE tb_num_pagos              CHAR(05);
DEFINE tb_frecpago               CHAR(01);
DEFINE tb_monto_pagar            DECIMAL(18);
DEFINE tb_fecha_apertura         CHAR(08);
DEFINE tb_fecha_ult_pago         CHAR(08);
DEFINE tb_fecha_ult_compra       CHAR(08);
DEFINE tb_fecha_cierre           CHAR(08);
DEFINE tb_fecha_reporte          CHAR(08);
DEFINE tb_credito_maximo         DECIMAL(18,2); 
DEFINE tb_saldo_actual           DECIMAL(18,2);
DEFINE tb_monto_otorgado         DECIMAL(18,2);
DEFINE tb_saldo_venc             DECIMAL(18,2);
DEFINE tb_cuotas_ven             SMALLINT;
DEFINE tb_mop                    CHAR(02);
DEFINE tb_clave_obs              CHAR(02);
DEFINE tb_plazo_meses       	 CHAR(5); --RQM 09 467_Version 14 
-- Segmento TRLR
DEFINE tb_total_sdo_actual       DECIMAL(14,2);
DEFINE tb_total_sdo_vencido      DECIMAL(14,2);
DEFINE tb_total_seg_intf         DECIMAL(03);
DEFINE tb_total_seg_pn           DECIMAL(09);
DEFINE tb_total_seg_pa           DECIMAL(09);
DEFINE tb_total_seg_pe           DECIMAL(09);
DEFINE tb_total_seg_tl           DECIMAL(09);
DEFINE tb_total_bloques          DECIMAL(06);
DEFINE tb_nombre_otorg           CHAR(09);
DEFINE tb_domicilio_dev          CHAR(65);
DEFINE tb_fecha_vencimiento      CHAR(08);
DEFINE tb_monto_insoluto         DECIMAL(18,2);
DEFINE tb_ultimo_pago            DECIMAL(18,2);

DEFINE vlMnpioReportar  char(40);  --GEV
DEFINE vlCodigoReportar   char(10);
DEFINE vlCodigoPOstalZona char(5);
-- Venta de cartera ini
DEFINE isqlErr                   INTEGER;
DEFINE iBanderaIndex             INTEGER;
DEFINE vperio_ejecucion          CHAR(02);
DEFINE iCP                       INTEGER;
DEFINE dFechaConsulta            DATE;
DEFINE vfecha_hoy_aux            DATE;

--IPCB CAMPOS NUEVOS RQM 09 467_Version 14 
DEFINE scalle_conocido 		SMALLINT;
DEFINE cpais     			CHAR(3);
DEFINE ccodigo_pais  		CHAR(2);
DEFINE cplazo_meses  		CHAR(4);
DEFINE dplazo_meses  		DECIMAL(5,2);
DEFINE vclave_ciudad   		CHAR(3);
DEFINE vclave_edo      		CHAR(2);

DEFINE tb_monto_originacion  DECIMAL(18,2);
DEFINE d_monto_originacion   DECIMAL(18,2);
DEFINE dmonto_autorizado     DECIMAL(18,2);

DEFINE vsegmento3_pe   		 CHAR(500);
DEFINE vmonto_int			 DECIMAL(18,2);

-- Segmento PE
DEFINE cnombre_empleador   	CHAR(99);
DEFINE tb_nombre_empleador 	CHAR(99);
DEFINE vprofesion          	CHAR(3);
DEFINE tb_origen_razon_soc 	CHAR(2);

DEFINE tb_fingcartvenc	  	CHAR(8);
DEFINE v_fecha_vencto 	  	DATE;
DEFINE vf_ingcartvenc 	  	CHAR(8);
DEFINE tb_diasatraso       	SMALLINT;
DEFINE vnum_tarjeta         CHAR(25);
DEFINE vnum_tarjeta_ant     CHAR(25);
DEFINE dFecha_reporte_tarj  DATE;
DEFINE cStatus_tar          CHAR(1);
DEFINE vCodstatus_tarjetanvo CHAR(3);
DEFINE tb_num_credito_ext   CHAR(25);
DEFINE cCredExterno         CHAR(20);
DEFINE tb_num_tarjeta       CHAR(25);
DEFINE vcodret2             char(5);
DEFINE cProceso             CHAR(4);
DEFINE iIsamErr             INTEGER;
DEFINE iCuenta_regs         INTEGER;  
DEFINE iCuenta_regs_2       INTEGER;  

--IPCB CAMPOS NUEVOS RQM 09 467_Version 14    

LET dtFecha_ultimo_reporte  = DATE(1);
LET iPeriodo                = 0;
LET dtFechaProxReporte      = DATE(1);
LET sProceso                = 0;
LET cStatusProc             = "";
LET sCommit                 = 0;
LET contador_commit         = 0;
LET iBanderaIndex           = 0;
LET iCP                     = 0;
LET cMensajeFin             = '';
LET iTotalProcesados        = 0;
LET vperio_ejecucion        = '7';
LET vmontoinsoluto          = 0;
LET vfecha_vencido          = DATE(1);
LET vmontolutpago           = 0;      
LET vdiasatraso             = 0;
LET vfechaultpago           = DATE(1);
LET vfechaultcompra         = DATE(1);
LET vStatusCred             = '';
LET vstatus_credAnt         = '';
LET vfecha_fin_mes_ant      = DATE(1);
LET vsaldo_vencAnt          = 0;

LET vsegmento5_tr           = '';
LET tb_total_sdo_actual     = 0;
LET tb_total_sdo_vencido    = 0;
LET tb_total_seg_intf       = 0;
LET tb_total_seg_pn         = 0;
LET tb_total_seg_pa         = 0;
LET tb_total_seg_pe         = 0;
LET tb_total_seg_tl         = 0;
LET tb_total_bloques        = 0;
LET tb_nombre_otorg         = '';
LET tb_domicilio_dev        = '';
LET tb_fecha_vencimiento    = '';
LET tb_monto_insoluto       = 0;
LET tb_ultimo_pago          = 0;

LET vnum_credito = '';

LET vanioup      = '';
LET vmesup       = '';
LET vdiaup       = '';
LET vfechaup = '';
LET vfecha_hoy_aux = date(1);

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
LET dmonto_autorizado = 0;
LET tb_origen_razon_soc = '';

LET vclave_edo 		= '';
LET scalle_conocido = 0;
LET cpais    		= '';
LET vclave_ciudad	= '';
LET vnum_tarjeta    = '';
LET vnum_tarjeta_ant = '';
LET dFecha_reporte_tarj = date(1);
LET cStatus_tar         = '';
LET vCodstatus_tarjetanvo = '';
LET tb_num_credito_ext   = '';
LET tb_num_tarjeta = '';
LET vcodret2 = '';
LET cProceso = '0058';
LET iIsamErr = 0;
LET iCuenta_regs = 0;
LET iCuenta_regs_2 = 0;

BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
      LET vcodret = iSqlErr;

      LET cMensajeFin = 'Proceso ENVIO PAGOS PARCIALES cancelado' || ' ' || vnum_credito;

      UPDATE bdicred:sd_control_procesos
         SET status_proceso = 'C',
             mensaje        = vcodret || ' ' || cMensajeFin
       WHERE empresa='001' 
         AND cod_proceso = 'cintaparcialbc_clon';

	  let cMensajeFin = trim(vcodret) || '- ' || iIsamErr || '-' || trim(vnum_credito);
	  CALL bdicobranza:sp_inserta_bitacora_cob('001', cProceso, vcodret, cMensajeFin, '02') RETURNING vcodret2; 	 
		 
      RETURN vcodret,cMensajeFin;

      ROLLBACK WORK;

   END IF;
END EXCEPTION;

LET vcodret = "000000";
LET vsql = "";

--SET DEBUG FILE TO "/RESPALDOS/ipcb/pruebas/trace/sp_burofisicas_cortos.out";
--TRACE ON; 

   CALL bdicobranza:sp_inserta_bitacora_cob('001', cProceso, vcodret, cMensajeFin, '01') RETURNING vcodret2; 

   SELECT UPPER(valor) 
     INTO vencabezado1
     FROM br_param
    WHERE cod_param = 3;

   SELECT UPPER(valor) 
     INTO vversion
     FROM br_param
    WHERE cod_param = 4;

   SELECT UPPER(valor) 
     INTO vnombre_usu
     FROM br_param
    WHERE cod_param = 6;

   SELECT UPPER(valor) 
     INTO vciclo
     FROM br_param
    WHERE cod_param = 7;

    SELECT UPPER(valor) 
      INTO vuso_futuro
      FROM br_param
     WHERE cod_param = 8;

    SELECT UPPER(valor) 
      INTO vclave_usu_bc
      FROM br_param
     WHERE cod_param = 127;

     LET vinf_adicional = "&";

     SELECT fecha_hoy,pri_dia_mes
       INTO vfecha_hoy,vPriDiaMes
       FROM bdicred:sd_fechas
      WHERE empresa='001';

--temporal para pruebas	  
--	  let vfecha_hoy = mdy('10','20','2014'); 
--	  let vPriDiaMes = mdy('10','01','2014'); 
--temporal para pruebas
   
   --let vfecha_hoy = mdy(1,14,2019);  -- TEST MACF
   
   let vfecha_ini = mdy(month(vfecha_hoy),1,year(vfecha_hoy));
   let vfecha_fin_mes_ant = date(vfecha_ini - 1 units day);

-- Verifica que el control de procesos no reporte el proceso activo para poder ejecutarlo
   SELECT status_proceso, fecha_proceso, fecha_prox_proceso --gev
     INTO cStatusProc, dtFecha_ultimo_reporte, dtFechaProxReporte --gev
     FROM bdicred:sd_control_procesos
    WHERE empresa='001' 
      AND cod_proceso = 'cintaparcialbc_clon';

 IF dtFecha_ultimo_reporte IS NULL THEN
     LET dtFecha_ultimo_reporte = vfecha_hoy - 1 UNITS DAY;
  END IF;
 
  IF dtFechaProxReporte IS NULL THEN
    LET dtFechaProxReporte = vfecha_hoy;  
  END IF;
  
  
  IF cStatusProc IS NULL THEN
    INSERT INTO bdicred:sd_control_procesos (empresa,cod_proceso,fecha_proceso,status_proceso,fecha_prox_proceso)
    VALUES ('001','cintaparcialbc_clon',vfecha_hoy-3 units day,'',vfecha_hoy);
  END IF;
	  
  IF cStatusProc = 'I' THEN
     LET vcodret = '000001';
     LET cMensajeFin = 'Proceso ENVIO PAGOS PARCIALES en ejecución';
     RETURN vcodret,cMensajeFin;
  END IF;

-- Valida que el día actual corresponda al día de ejecución que indica el control de procesos   IF (vfecha_hoy <= NVL(dtFecha_ultimo_reporte,DATE(1)) AND cStatusProc = 'F') THEN
  IF (vfecha_hoy <= NVL(dtFecha_ultimo_reporte,DATE(1)) AND cStatusProc = 'F') THEN
      LET vcodret = '000002';
      LET cMensajeFin = 'El proceso ENVIO PAGOS PARCIALES ya fue ejecutado';
      RETURN vcodret,cMensajeFin;
   END IF;        

   IF vfecha_hoy > NVL(dtFecha_ultimo_reporte,DATE(1)) AND cStatusProc in ('C','I') THEN
-- Reinicio donde se quedo
       UPDATE bdicred:sd_control_procesos
          SET status_proceso = 'I',
              mensaje = 'PROCESANDO'
        WHERE cod_proceso = 'cintaparcialbc_clon';

   ELSE
       UPDATE bdicred:sd_control_procesos
          SET --fecha_proceso = vfecha_hoy,
              status_proceso = 'I',
              mensaje = 'PROCESANDO'
        WHERE cod_proceso = 'cintaparcialbc_clon';    
   END IF;        
/*
   IF EXISTS (SELECT * FROM bdinteg:si_feriado WHERE empresa = '001' AND pais = '001' AND fecha  = dtFechaProxReporte AND laborable = 'N') THEN
      LET dtFechaProxReporte = date(dtFechaProxReporte + 1);
   END IF;
*/
-- Hace las adaptaciones a la tabla de SEPOMEX
    select {+FULL(bdinteg:si_catsepomex)} *,
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
         when  d_estado= 'TLAXCALA'then 'TLA'
         when  d_estado= 'VERACRUZ DE IGNACIO DE LA LLAVE'then 'VER'
         when  d_estado= 'YUCATAN'then 'YUC'
         when  d_estado= 'ZACATECAS'then 'ZAC'
         when  d_estado= 'MEXICO'then 'EM '
		 
    ELSE '' END estado_abrev FROM bdinteg:si_catsepomex into temp sepomex with no log;
 ---Creación de indices por cada una de las validacines de SEPOMEX
    CREATE INDEX idx_sepomex  ON sepomex(d_codigo,d_mnpio,estado_abrev) in dbs_movhis_idx5 online;
    CREATE INDEX idx_sepomex1 ON sepomex(d_mnpio,estado_abrev) in dbs_movhis_idx5 online;
    CREATE INDEX idx_sepomex2 ON sepomex(d_asenta,estado_abrev) in dbs_movhis_idx5 online;
    CREATE INDEX idx_sepomex3 ON sepomex(d_codigo,estado_abrev) in dbs_movhis_idx5 online;

    UPDATE STATISTICS MEDIUM FOR TABLE sepomex;

    LET vfecha_ini = MDY(MONTH(vfecha_hoy),1,YEAR(vfecha_hoy));
    LET vanio      = YEAR(vfecha_hoy);
    LET vmes       = LPAD(MONTH(vfecha_hoy),2,"0");
    LET vdia       = LPAD(DAY(vfecha_hoy),2,"0");
    LET vfecha_reporte = vdia||vmes||vanio;

    SELECT {+INDEX(bdicred:sd_maecredanexo idx_maecredanexo2)} a.num_credito,a.num_producto,a.numcte,a.fecha_apertura,d.maneja_linea,a.period_pag_int,d.dia_cuota,fecha_ult_pago,a.status_cred,a.plazo   --RQM 09 467_Version 14 incluye a.plazo
--      INTO vnum_credito,vnum_producto,vnumcte,vfecha_apertura,vtp_linea,vfrecuencia,vdiacuota,vcuota_cap,vpago_cap
      FROM bdicred:sd_maecred a,
           bdicred:sd_maecredanexo b,
           bdicred:sd_maesdoshist c,
    bdicred:sd_definicion d
     WHERE a.empresa = '001'
		--AND a.sucursal in ('0547','0249','0192')--para pruebas
       AND a.num_credito >= '600000000000'
       AND status_cred NOT IN ('CV','FC')
       AND a.empresa = b.empresa
       AND a.num_credito = b.num_credito
       AND a.empresa = c.empresa
       AND a.num_credito = c.num_credito
       AND b.fecha_ult_pago >= dtFecha_ultimo_reporte
       AND b.fecha_ult_pago < vfecha_hoy
         AND a.empresa = d.empresa
         AND a.num_producto = d.num_producto
     AND c.fecha = CASE WHEN DAY(b.fecha_ult_pago) >= b.dia_corte THEN 
                          MDY(MONTH(b.fecha_ult_pago),b.dia_corte,YEAR(b.fecha_ult_pago))                                
                     ELSE
                          MDY(MONTH(b.fecha_ult_pago - 1 UNITS MONTH),b.dia_corte,YEAR(b.fecha_ult_pago - 1 UNITS MONTH)) 
                     END					 
					 
     AND a.fecha_apertura < mdy(month(vfecha_hoy),'01',year(vfecha_hoy))
--and a.num_credito in (select num_credito from bdicred:sd_maecred_temp)
UNION ALL
--    SELECT a.num_credito,a.num_producto,a.numcte,a.fecha_apertura,d.maneja_linea,a.period_pag_int,b.dia_corte,c.monto_financiado,fecha_ult_pago
    SELECT a.num_credito,a.num_producto,a.numcte,a.fecha_apertura,d.maneja_linea,a.period_pag_int,b.dia_corte dia_cuota,fecha_ult_pago,a.status_cred,a.plazo   --RQM 09 467_Version 14 incluye a.plazo
      FROM bdicred:sd_maecredcrd a,
           bdicred:sd_maecredanexocrd b,
--           bdicred:sd_maesdoshistcrd c,
           bdicred:sd_maesdoscrd c,
           bdicred:sd_definicion d
     WHERE a.empresa = '001'
	   --AND a.sucursal in ('0547','0249','0192')--para pruebas
       AND a.num_credito >= '610000000000'
       AND a.num_producto = '6011'
       AND a.status_cred <> 'FF'
       AND a.empresa = b.empresa
       AND a.num_credito = b.num_credito
       AND a.empresa = c.empresa
       AND a.num_credito = c.num_credito
       AND b.fecha_ult_pago >= dtFecha_ultimo_reporte
       AND b.fecha_ult_pago < vfecha_hoy
       AND a.empresa = d.empresa
       AND a.num_producto = d.num_producto
/*       AND c.fecha = CASE WHEN DAY(b.fecha_ult_pago) >= day(b.dia_corte) THEN 
                          MDY(MONTH(b.fecha_ult_pago),day(b.dia_corte),YEAR(b.fecha_ult_pago))                                
                     ELSE
                          MDY(MONTH(b.fecha_ult_pago - 1 UNITS MONTH),day(b.dia_corte),YEAR(b.fecha_ult_pago - 1 UNITS MONTH)) 
                     END
     AND a.fecha_apertura < c.fecha*/
     AND a.fecha_apertura < vfecha_hoy
--and a.num_credito in (select num_credito from bdicred:sd_maecredcrd_temp)
    INTO temp creditos WITH NO LOG;

    
	
	--IF EXISTS (SELECT * FROM bdiburo:br_burofisicas_cortos_clon WHERE numreg = 1) THEN
	SELECT COUNT(*) INTO iCuenta_regs
	FROM bdiburo:br_burofisicas_cortos_clon WHERE numreg = 1;
	
	IF iCuenta_regs > 0 THEN
        TRUNCATE TABLE "informix".br_burofisicas_describe_cortos_clon;
        TRUNCATE TABLE "informix".br_burofisicas_cortos_clon;
    END IF;

    select max(numreg) into vnumreg
    from bdiburo:br_burofisicas_cortos_clon where numreg > 0;

    IF vnumreg IS NULL OR vnumreg = 0 THEN LET vnumreg = 1; END IF;

    SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 3;

FOREACH WITH HOLD
    SELECT num_credito,num_producto,numcte,fecha_apertura,maneja_linea,period_pag_int,dia_cuota,fecha_ult_pago,status_cred,plazo  --RQM 09 467_Version 14 incluye plazo cplazo_meses
      INTO vnum_credito,vnum_producto,vnumcte,vfecha_apertura,vtp_linea,vfrecuencia,vdiacuota,vpago_cap,vStatusCred, cplazo_meses
      FROM creditos 
	  WHERE num_credito not in ('700000000021','700000000013','700000000039') --Exclusion RQI 21 052 

      LET vanioup = YEAR(vpago_cap);
      LET vmesup = LPAD(MONTH(vpago_cap),2,"0");
      LET vdiaup = LPAD(DAY(vpago_cap),2,"0");
      LET vfechaup = vdiaup||vmesup||vanioup;
 
      --IF EXISTS (SELECT * FROM bdiburo:br_burofisicas_describe_cortos_clon WHERE num_credito = vnum_credito AND fecha_ult_pago = vfechaup) THEN 
      --   CONTINUE FOREACH; 
      --END IF;
	  
	  SELECT count(*) into iCuenta_regs_2
	  FROM bdiburo:br_burofisicas_describe_cortos_clon WHERE num_credito = vnum_credito AND fecha_ult_pago = vfechaup;
	  
	  IF iCuenta_regs_2 > 0 THEN
	     CONTINUE FOREACH; 
	  END IF;
	  	  
      SELECT 
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(TRIM(apell_paterno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(TRIM(apell_materno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(TRIM(nombre1),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(TRIM(nombre2),""),'1','L'),'0','O'),'5','S'),'8','B'),
             fecha_nac,TRIM(rfc),
             nvl(estado_civil," "),nvl(sexo,"I")
        INTO vapell_paterno,vapell_materno,vnombre1,
             vnombre2,vfecha_nac,vrfc,
             vestado_civil,vsexo
        FROM bdinteg:si_cliente a, bdinteg:si_ctepf b
       WHERE a.numcte = vnumcte
         AND a.numcte = b.numcte; 


    IF vfecha_nac IS NULL THEN 
       LET vrfc = ""; 
    END IF;

-- Venta de cartera ini
-- Solo se reporta el mes de la venta

   LET vsegmento_pn = "";   LET vsegmento2_pa = "";  LET vsegmento3_pe=""; LET vsegmento4_tl = "";  --RQM 09 467_Version 14 se limpia variable vsegmento3_pe

-- Inicializa variables
-- Segmento PN
   LET tb_apell_paterno = "";   LET tb_apell_materno = "";   LET tb_nombre1       = "";   LET tb_nombre2       = "";
   LET tb_fecha_nac     = "";   LET tb_rfc           = "";   LET tb_nacionalidad  = "";   LET tb_estado_civil  = "";
   LET tb_sexo          = "";

-- Segmento PA
   LET tb_calle         = "";   LET tb_colonia       = "";   LET tb_delegacion    = "";   LET tb_ciudad        = "";
   LET tb_estado        = "";   LET tb_cod_postal    = "";   LET vcredito_maximo  = 0.0;

-- Segmento TL
   LET tb_clave_usu         = "";   LET tb_nombre_usu        = "";   LET tb_num_credito       = "";   LET tb_responsabilidad   = "";
   LET tb_tipo_cuenta       = "";   LET tb_tipo_producto     = "";   LET tb_clave_monetaria   = "";   LET tb_num_pagos         = "";
   LET tb_frecpago          = "";   LET tb_monto_pagar       = 0.0;   LET tb_fecha_apertura    = "";   LET tb_fecha_ult_pago    = "";
   LET tb_fecha_ult_compra  = "";   LET tb_fecha_cierre      = "";   LET tb_fecha_reporte     = "";   LET tb_credito_maximo    = 0.0;
   LET tb_saldo_actual      = 0.0;   LET tb_monto_otorgado    = 0.0;   LET tb_saldo_venc        = 0.0;   LET tb_cuotas_ven        = 0;
   LET tb_mop               = "";   LET tb_clave_obs         = "";   LET vrea_cal_cuota       = 0;
   LET vlMnpioReportar = '';   		LET vlCodigoReportar ='';     LET vlCodigoPOstalZona =''; --GEV

-- Segmento PE --RQM 09 467_Version 14
   LET tb_nombre_empleador 	= "";	LET tb_origen_razon_soc 	= "";	LET tb_fingcartvenc 		= "";	LET tb_diasatraso 			= 0;	   
      
-- INICIA ARMADO SEGMENTO PN (Nombre)

   LET vanio = YEAR(vfecha_nac);
   LET vmes = LPAD(MONTH(vfecha_nac),2,"0");
   LET vdia = LPAD(DAY(vfecha_nac),2,"0");

-- Agrega Apellido Paterno
    LET vsegmento1_pn    = LPAD(LENGTH(TRIM(vapell_paterno)),2,"0")||TRIM(vapell_paterno);
    LET tb_apell_paterno = TRIM(vapell_paterno);

-- Agrega Apellido Materno
   IF vapell_materno IS NOT NULL THEN
      LET vsegmento1_pn    = TRIM(vsegmento1_pn)||'00'||LPAD(LENGTH(TRIM(vapell_materno)),2,"0")||TRIM(vapell_materno);
      LET tb_apell_materno = TRIM(vapell_materno);
   ELSE
      LET vsegmento1_pn = TRIM(vsegmento1_pn)||'0016NO PROPORCIONADO';
   END IF;

-- Agrega Primero Nombre
   LET vsegmento1_pn = TRIM(vsegmento1_pn)||'02'||LPAD(LENGTH(TRIM(vnombre1)),2,"0")||vnombre1;
   LET tb_nombre1    = vnombre1;

-- Agrega Segundo Nombre
   IF vnombre2 IS NOT NULL THEN
      LET vsegmento1_pn = TRIM(vsegmento1_pn)||'03'||LPAD(LENGTH(TRIM(vnombre2)),2,"0")||vnombre2;
      LET tb_nombre2    = vnombre2;
   END IF;

-- Agrega Fecha de Nacimiento
   IF vfecha_nac IS NOT NULL THEN
      LET vsegmento1_pn = TRIM(vsegmento1_pn)||'0408'||vdia||vmes||vanio;
      LET tb_fecha_nac = vdia||vmes||vanio;
   END IF;

-- Agrega RFC
   LET existe = LENGTH(vrfc);
   IF vrfc IS NULL OR existe < 10 THEN
      IF vrfc[2,2] = "A" OR vrfc[2,2] = "E" OR vrfc[2,2] = "I" OR vrfc[2,2] = "O" OR vrfc[2,2] = "U" THEN
         LET vrfc = vapell_paterno[1,2]||vapell_materno[1,1]||vnombre1[1,1]||vanio[3,4]||vmes||vdia;
      ELSE
         LET vrfc = vapell_paterno[1,1]||vapell_paterno[3,3]||vapell_materno[1,1]||vnombre1[1,1]||vanio[3,4]||vmes||vdia;
      END IF
   END IF

   LET vsegmento1_pn = TRIM(vsegmento1_pn)||'05'||LPAD(LENGTH(TRIM(vrfc)),2,"0")||vrfc;
   LET tb_rfc = vrfc;

-- Agrega Nacionalidad
   LET vsegmento1_pn = TRIM(vsegmento1_pn)||'0802MX';
   LET tb_nacionalidad  = "MX";

-- Agrega Estado Civil
   IF vestado_civil IS NOT NULL THEN
      IF vestado_civil = 'C' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101M';
      END IF;
      IF vestado_civil = 'S' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101S';
      END IF;
      IF vestado_civil = 'U' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101F';
      END IF;
      IF vestado_civil = 'D' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101D';
      END IF;
      IF vestado_civil = 'V' THEN
         LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1101W';
      END IF;
      LET tb_estado_civil  = vestado_civil;
   END IF;

-- Agrega Sexo
   IF vsexo IS NOT NULL THEN
      LET vsegmento1_pn = TRIM(vsegmento1_pn)||'1201'||vsexo;
      LET tb_sexo  = vsexo;
   END IF;
   LET vsegmento_pn = 'PN'||TRIM(vsegmento1_pn);
-- TERMINA ARMADO SEGMENTO PN (Nombre)

-- INICIA ARMADO SEGMENTO PA (Dirección)
/*
   SELECT {+INDEX(bdinteg:si_direcciones inx_direcciones)} MAX(secuencia) 
     INTO vsecuencia
     FROM bdinteg:si_direcciones
    WHERE numcte = vnumcte 
      AND tipo_dir = '1';
*/
		SELECT limit 1 Trim(f.nombrecalle)||' '|| case when nvl(a.numeroextcalle,'') = '' then 'SN' else Trim(a.numeroextcalle) end ||' '||Trim(a.numerointcalle),
			nvl(Trim(g.nombrezona),''),nvl(Trim(g.municipiozona),''), Trim(c.estado),
			lpad(trim(a.cod_postal),5,"0"),manzana,andador,lote,edificio,entrada,
			nvl(substr( CodigoPOstalZona,1,5),''),--GEV
			case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' then 1 else 0 end,
			a.pais, a.ciudad, a.estado
		INTO vcalle,vcolonia,vdelegacion,vestado,vcod_postal,
			vmanzana,vandador,vlote,vedificio,ventrada,
			vlCodigoPOstalZona, scalle_conocido, cpais, vclave_ciudad, vclave_edo
		FROM bdinteg:si_direcciones_actual a 
        left outer join bdisolic:ss_circulo_edos c on a.estado = c.clave
        left outer join bdinteg:si_catzonas g on (a.numerociudad = g.numerociudad and a.numerocolonia = g.numerocolonia)
        left outer join bdinteg:si_catcalles f on a.numerocalle = f.numerocalle
        WHERE a.numcte= vnumcte
          AND a.tipo_dir="1"
          AND c.empresa = "001";
	  
	  ---Inicia Bloque de Validaciones Sepomex  --GEV
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
       ---Fin de Bloque de Validaciones Sepomex ---GEV
--validar para la tabla c la clave del estado ya que usa el campo clave

     LET vcalle1 = "";
     IF vmanzana > 0 THEN
        LET vcalle1 ="mza. "|| vmanzana;
     END IF
     IF vandador > 0 THEN
        LET vcalle1 =TRIM(vcalle1)||"and. "||     vmanzana ;
     END IF
     IF vlote > 0 THEN
        LET vcalle1 =TRIM(vcalle1)||"lt. "  ||   vlote ;
     END IF
     IF vedificio > 0 THEN
        LET vcalle1 =TRIM(vcalle1)||"ed. "||     vedificio ;
     END IF
     IF ventrada > 0 THEN
        LET vcalle1 =TRIM(vcalle1)||"ent. "||     ventrada ;
     END IF
     LET vcalle = TRIM(vcalle)||' '||TRIM(vcalle1);
	 
	 IF scalle_conocido = 1 THEN
		   LET vcalle = 'DOMICILIO CONOCIDO SN';
	 END IF;

  LET vciudad = "";

  IF vcod_postal IS NULL THEN     LET vcod_postal = "00000";  END IF;

-- Agrega Direccion
  LET vsegmento2_pa = LPAD(LENGTH(TRIM(vcalle)),2,"0")||vcalle;
  LET tb_calle      = vcalle;

-- Agrega Colonia
  IF vcolonia IS NOT NULL THEN
     LET vsegmento2_pa = TRIM(vsegmento2_pa)||'01'||LPAD(LENGTH(TRIM(vcolonia)),2,"0")||vcolonia;
     LET tb_colonia    = vcolonia;
  ELSE
	let vsegmento2_pa = trim(vsegmento2_pa)||'0100'; --RQM 09 467_Version 14
  END IF;

-- Agrega Delegacion o Municipio
  IF vdelegacion != "" THEN
     LET vsegmento2_pa = TRIM(vsegmento2_pa)||'02'||LPAD(LENGTH(TRIM(vdelegacion)),2,"0")||vdelegacion;
     LET tb_delegacion = vdelegacion;
  ELIF vdelegacion = "" or vdelegacion is null then
	 LET vsegmento2_pa = trim(vsegmento2_pa)||'0200'; --RQM 09 467_Version 14	 
-- Agrega Ciudad si delegacion es blanco --RQM 09 467_Version 14	
	   SELECT nvl(nombre,'') INTO vciudad
           FROM bdinteg:si_ciudades 
          WHERE estado = vclave_edo
            AND ciudad = vclave_ciudad;       
		
		IF  vciudad != ''  then
			LET vsegmento2_pa = TRIM(vsegmento2_pa)||'03'||LPAD(LENGTH(TRIM(vciudad)),2,"0")||vciudad;
			LET tb_ciudad     = vciudad;
		ELSE-- vciudad = ''  then 
		  let vsegmento2_pa = trim(vsegmento2_pa)||'0300'; 
		END IF
  END IF

-- Agrega Estado
  LET vsegmento2_pa = TRIM(vsegmento2_pa)||'04'||LPAD(LENGTH(TRIM(vestado)),2,"0")||TRIM(vestado);
  LET tb_estado     = TRIM(vestado);

-- Agrega Codigo Postal
  LET vsegmento2_pa = TRIM(vsegmento2_pa)||'05'||LPAD(LENGTH(TRIM(vcod_postal)),2,"0")||TRIM(vcod_postal);
  LET tb_cod_postal = TRIM(vcod_postal);

-- Agregar origen del domicilio (pais) --RQM 09 467_Version 14
  LET vsegmento2_pa = trim(vsegmento2_pa)||'1202MX';
  LET tb_codigo_pais  = 'MX';  
  
  LET vsegmento2_pa = 'PA'||TRIM(vsegmento2_pa);
-- TERMINA ARMADO SEGMENTO PA (Dirección)

  LET vcuotas_ven = 0;
  LET vpago_int = "";
-- INICIA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14
  --Etiqueta PE -Nombre o Razo Social del empleador 
        SELECT nvl(a.nombre_empresa,'')
          INTO cnombre_empleador
          FROM bdinteg:si_ingresos a
         WHERE a.numcte = vNumcte
           AND a.sec_ingreso = (SELECT max(sec_ingreso)
                                  FROM bdinteg:si_ingresos 
                                 WHERE numcte = a.numcte);

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
    END IF;
    
	let vsegmento3_pe = 	lpad(length(trim(cnombre_empleador)),2,"0")  || trim(cnombre_empleador);
	let tb_nombre_empleador = trim(cnombre_empleador);  

	-- Agregar origen del domicilio De la razón social (pais) 
	let vsegmento3_pe = trim(vsegmento3_pe)||'1802MX';
	let tb_origen_razon_soc  = 'MX';

	let vsegmento3_pe = 'PE'||trim(vsegmento3_pe);           	  
-- TERMINA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14	

-- INICIA ARMADO SEGMENTO TL (Datos Financieros)
    
	-- RQM 09 502 MACF
	-- Obtener el número de tarjeta de br_burofisicas_describe_clon
	if vnum_producto in('6001','6600','7000','8100') then
		select limit 1 num_tarjeta into vnum_tarjeta
		  from bdiburo:br_burofisicas_describe_clon
		 where num_credito = vnum_credito
		   and nvl(fecha_cierre,'') = '';   --agregar 20190303 revisar después si se puede meter índice aquí
 	  
         -- si no existe, significa que no se envió en la cinta mensual anterior, buscar en sd_tarjeta 
	     if nvl(vnum_tarjeta,'') = '' then
		    select a.num_tarjeta, a.status_tar
              into vnum_tarjeta, cStatus_tar		 
		      from bdicred:sd_tarjeta a
             where a.empresa = '001' and a.num_credito = vnum_credito
               and a.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where empresa = '001'
                                  and num_credito = a.num_credito and tipo_tarjeta = 'T');
		 end if;
    end if;	
	

	-- RQM 09 502 MACF

  --IF vnum_producto in ('6001','6600','7000') THEN  --IPCB 10sep14- RQM 06 316//Incluir producto 7000 tarjeta platino
  IF vnum_producto in ('6001','6600','7000','8100') THEN 
      SELECT monto_otorgado,
          nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0),
          nvl(monto_vencido + mto_venc_trasp,0), nvl(sdo_no_exig,0),
          nvl(monto_financiado,0),case when sdo_cap_insoluto >=0 then sdo_cap_insoluto else 0 end
        INTO vmonto_otorgado, vsaldo_vig, vsaldo_venc, v_interes,vcuota_cap, vmontoinsoluto
        FROM bdicred:sd_maesdos c
       WHERE c.empresa = '001'
         AND c.num_credito = vnum_credito;
--RQM 09 325 rss se implementa fecha_vencido, dias_atraso, monto_ultimo_pago_h
  -- Obtiene datos de indicadores
        select fecha_ultima_compra, num_vencidos, saldo_maximo, fecha_vencido, dias_atraso, monto_ultimo_pago_h
          into vpago_int, vcuotas_ven, vcredito_maximo, vfecha_vencido, vdiasatraso, vmontolutpago
          from bdicred:sd_indicador_cred
         where empresa = "001" 
           and num_credito = vnum_credito;
  ELSE
      SELECT monto_otorgado,
          nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0),
          nvl(monto_vencido + mto_venc_trasp,0), sdo_no_exig,
          monto_otorgado,case when sdo_cap_insoluto >=0 then sdo_cap_insoluto else 0 end
        INTO vmonto_otorgado, vsaldo_vig, vsaldo_venc, v_interes, vcredito_maximo, vmontoinsoluto
        FROM bdicred:sd_maesdoscrd c
       WHERE c.empresa = '001'
         AND c.num_credito = vnum_credito;

      SELECT {+INDEX(bdicred:sd_amortiza_creditocrd amorsx)} 
             nvl(SUM(capital_mto_cuota - capital_pagado - interes_pagado - iva_pagado),0), 
             nvl(SUM(CASE WHEN capital_status IN ('2','7') THEN 1 ELSE 0 END),0)
        INTO vcuota_cap,
             vcuotas_ven
        FROM bdicred:sd_amortiza_creditocrd
       WHERE empresa = '001'
         AND num_credito = vnum_credito
         AND capital_status in ('1','2','7');

--RQM 09 325 rss se implementa fecha_vencido, dias_atraso, monto_ultimo_pago_h
		select nvl(fecha_vencido,date(1)), -- primer incumplimiento
               nvl(dias_atraso,0), -- dias de atraso
               fecha_ultimo_pago_h -- fecha de ultimo pago
          into vfecha_vencido,
               vdiasatraso,
               vfechaultpago
          from bdicred:sd_indicador_cred_crd
         where empresa = "001" 
           and num_credito = vnum_credito;	

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

--RQM 09 325 rss se implementa fecha_vencido, dias_atraso, monto_ultimo_pago_h
  END IF;

--RQM 09 325 rss 
   if (vStatusCred in ('AA','FF')) or (vStatusCred = 'VP' and vsaldo_venc <= 0) then 
      let vdiasatraso = 0; 
   else 
      let vdiasatraso = vdiasatraso ;
      let vfecha_hoy = vfecha_hoy ;
      let vPriDiaMes = vPriDiaMes ;

      let vdiasatraso = vdiasatraso + round((date(vfecha_hoy) - date(vPriDiaMes)));
   end if;

   if vfecha_vencido is null then let vfecha_vencido = date(1); end if;

   LET vfechacuota = MDY(MONTH(vfecha_hoy),vdiacuota,YEAR(vfecha_hoy));

   IF vfechacuota < vfecha_apertura OR vnum_credito IS NULL THEN -- creditos sin procesar
      CONTINUE FOREACH;
   END IF

-- Agregar Clave y nombre del otorgante
   LET vsegmento4_tl = '02TL0110'||vclave_usu_bc||'02'||LPAD(LENGTH(TRIM(vnombre_usu)),2,"0")||vnombre_usu;
   LET tb_clave_usu  = vclave_usu_bc;
   LET tb_nombre_usu = vnombre_usu;

-- Agregar Numero de credito
   -- LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'04'||LPAD(LENGTH(TRIM(vnum_credito)),2,"0")||TRIM(vnum_credito);
   -- LET tb_num_credito = TRIM(vnum_credito);

   
   --if vnum_producto <> '6011' then
   if vnum_producto in('6001','6600','7000','8100') then  -- RQM 09 502
      LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'04'||LPAD(LENGTH(TRIM(vnum_tarjeta)),2,"0")||TRIM(vnum_tarjeta);
      LET tb_num_credito = TRIM(vnum_credito);
      LET tb_num_tarjeta = trim(vnum_tarjeta);
   else
      LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'04'||LPAD(LENGTH(TRIM(vnum_credito)),2,"0")||TRIM(vnum_credito);
      LET tb_num_credito = TRIM(vnum_credito);
	  LET tb_num_tarjeta = '';
   end if;
   
     
   
-- Agregar Tipo de responsabilidad de la cuenta
-- I = Individual
-- J = Mancomunada
-- C = Obligado Solidario

   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'0501I0601';
   LET tb_responsabilidad   = "I";

-- Agregar Tipo de cuenta y tipo de producto
-- TIPO DE CUENTA
-- I = Pagos Fijos
-- M = Hipotecaria
-- O = Sin limite preesTABLEcido
-- R = Revolvente

-- TIPO DE PRODUCTO
-- CC = Tarjeta de Credito
-- PL = Prestamo Personal

  IF vtp_linea = '1' THEN
     LET vsegmento4_tl    = TRIM(vsegmento4_tl)||'R0702CC';
     LET vnum_pagos       = 0;
     LET vfrecpago        = "M";
     LET tb_tipo_cuenta   = "R";
     LET tb_tipo_producto = "CC";
  ELIF vtp_linea = '0' THEN
        LET vsegmento4_tl =  TRIM(vsegmento4_tl)||'R0702CC';
        LET vnum_pagos       =  0;
        LET vfrecpago        =  "M";
        LET tb_tipo_cuenta   =  "R";
        LET tb_tipo_producto =  "CC";
   ELSE
      CONTINUE FOREACH;
   END IF;

--Agregar Clave Monetaria
-- MX = Pesos
-- US = Dolares
-- UD = Unidades de Inversion
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'0802MX';
   LET tb_clave_monetaria   = "MX";

-- Agregar Numero de Pagos
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'10'||LPAD(LENGTH(vnum_pagos),2,"0")||TRIM(vnum_pagos);
   LET tb_num_pagos = TRIM(vnum_pagos);

-- Agregar Fecuencia de Pagos
-- M = Mensual
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'1101'||vfrecpago;
   LET tb_frecpago = vfrecpago;

-- Agregar Monto a Pagar 
-- Se adelanta la obtencion de saldos
   LET vsaldo_actual = 0;
    
   
   IF ( v_interes IS NULL OR v_interes <= 0 ) THEN
      LET v_interes = 0;
   END IF;

-- Se agregan exepciones de pago y saldo
   LET vsaldo_vig = vsaldo_vig + v_interes;
   LET vrea_cal_cuota = 0;

   IF vcuota_cap >= vsaldo_vig THEN
      IF vsaldo_vig > 0 THEN
         LET vcuota_cap = vsaldo_vig / 10;
         LET vrea_cal_cuota = 1;
      ELSE
         LET vcuota_cap = 0;
      END IF;
   END IF;

   IF ROUND(vcuota_cap,0) = 0 AND vsaldo_vig > 0 THEN
      LET vcuota_cap = vsaldo_vig / 10;
      LET vrea_cal_cuota = 1;
   END IF;

   IF ROUND(vcuota_cap,0) = 0 THEN LET vcuota_cap = ROUND(vsaldo_vig,0); END IF;

   IF vcuota_cap > 0 THEN
      LET vmonto = ROUND(vcuota_cap,0);
   ELSE
      LET vmonto = 0;
   END IF

 
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'1209'||LPAD(ROUND(vmonto,0),9,"0");
   LET tb_monto_pagar = ROUND(vmonto,0);
   
-- Agregar Fecha de Apertura de la Cuenta
   LET vanio = YEAR(vfecha_apertura);
   LET vmes = LPAD(MONTH(vfecha_apertura),2,"0");
   LET vdia = LPAD(DAY(vfecha_apertura),2,"0");
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'1308'||vdia||vmes||vanio;

   LET tb_fecha_apertura    = vdia||vmes||vanio;

  IF vpago_cap IS NULL THEN LET vpago_cap = vfecha_apertura; END IF;
  IF vpago_int IS NULL THEN LET vpago_int = vfecha_apertura; END IF;

-- Agregar Fecha de Ultimo Pago
  LET vanio = YEAR(vpago_cap);
  LET vmes = LPAD(MONTH(vpago_cap),2,"0");
  LET vdia = LPAD(DAY(vpago_cap),2,"0");

  LET vsegmento4_tl     = TRIM(vsegmento4_tl)||'1408'||vdia||vmes||vanio;
  LET tb_fecha_ult_pago = vdia||vmes||vanio;

-- Agregar Fecha de Ultima Compra
  IF vpago_int >= vfecha_hoy THEN LET vpago_int = vpago_cap; END IF;

  LET vanio = YEAR(vpago_int);
  LET vmes = LPAD(MONTH(vpago_int),2,"0");
  LET vdia = LPAD(DAY(vpago_int),2,"0");

  LET vsegmento4_tl       = TRIM(vsegmento4_tl)||'1508'||vdia||vmes||vanio;
  LET tb_fecha_ult_compra = vdia||vmes||vanio;

  
-- Agregar Fecha Reporte
   LET vsegmento4_tl     = TRIM(vsegmento4_tl)||'1708'||vfecha_reporte;
   LET tb_fecha_reporte  = vfecha_reporte;

   IF (vsaldo_venc IS NULL) OR (vsaldo_venc < 0) THEN LET vsaldo_venc = 0; END IF

-- Agregar Saldo Máximo

  IF (vcredito_maximo is null) or (vcredito_maximo < 0) then let vcredito_maximo = 0.0; end if

  LET vsegmento4_tl     = TRIM(vsegmento4_tl)||'2109'||LPAD(ROUND(vcredito_maximo,0),9,"0");
  LET tb_credito_maximo = ROUND(vcredito_maximo,0);

-- Agregar Saldo Actual
  LET vsaldo_actual   = ROUND(vsaldo_vig,0);
  LET tb_saldo_actual = vsaldo_actual;
  
  
  IF nvl(vsaldo_actual,'') = '' THEN --- RQM 09 467_Version 14
    LET vsegmento4_tl = trim(vsegmento4_tl)||'2200';
  END IF;

    
  IF vsaldo_actual >= 0 THEN
     LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2210'||LPAD(ROUND(vsaldo_actual,0),10,"0");
  ELSE
     LET vsaldo_actual = abs(vsaldo_actual);
     LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2210'||LPAD(ROUND(vsaldo_actual,0),9,"0")||"-";
  END IF

-- Agregar Limite de Credito
	IF nvl(vmonto_otorgado,'') = '' THEN --- RQM 09 467_Version 14
		LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2300';
	ELSE
		LET vsegmento4_tl     = TRIM(vsegmento4_tl)||'2309'||LPAD(ROUND(vmonto_otorgado,0),9,"0");
		LET tb_monto_otorgado = ROUND(vmonto_otorgado,0);
	END IF;
	
-- Se agregan pagos vencidos
  IF (vsaldo_venc <= 0 OR vcuotas_ven = 0 OR vcuotas_ven IS NULL) THEN
     LET vcuotas_ven = 0;
  END IF;   

---Modificar de acuerdo a circulo
/*--RQM 09 325 rss
  IF vfecha_apertura > vfecha_ini THEN
     LET vmop = "00";
               --ELIF (vmonto = 0  AND vstatus_cred <> 'CV')   THEN
  ELIF (vmonto = 0 )   THEN
     LET vmop = "01";
     LET vsaldo_venc = 0;
  ELIF (vcuotas_ven = 0) THEN
     LET vmop = "01";
     LET vsaldo_venc = 0;
  ELIF vcuotas_ven = 1 THEN
     LET vmop = "02";
  ELIF vcuotas_ven = 2 THEN
     LET vmop = "03";
  ELIF vcuotas_ven = 3 THEN
     LET vmop = "04";
  ELIF vcuotas_ven = 4 THEN
     LET vmop = "05";
  ELIF vcuotas_ven = 5 THEN
     LET vmop = "06";
  ELIF (vcuotas_ven >= 6) AND (vcuotas_ven <= 12)  THEN
     LET vmop = "07";
  ELIF vcuotas_ven > 12 THEN
     LET vmop = "96";
  END IF
*/--RQM 09 325 rss
--RQM 09 325 rss
    LET vmop = '';
    if (vmontoinsoluto > 0 and vmontoinsoluto < 1) then
       let vmontoinsoluto =1;
	end if;
---Modificar de acuerdo a circulo

   let vfecha_hoy_aux = (vfecha_hoy + 1 units day);
   execute PROCEDURE bdicred:"informix".monthadd(vfecha_hoy_aux, -1) into vfecha_hoy_aux;

--   if (vfecha_apertura < ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultpago < ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultcompra < ((vfecha_hoy + 1 units day) - 1 units month)) and vdiasatraso = 0 and vmontoinsoluto <= 0 then
--      let vmop = "UR";
--   elif (vfecha_apertura >= ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultpago < ((vfecha_hoy + 1 units day) - 1 units month)) and (vfechaultcompra < ((vfecha_hoy + 1 units day) - 1 units month)) and vdiasatraso = 0 then

   if vfecha_apertura < vfecha_hoy_aux and vfechaultpago < vfecha_hoy_aux and vfechaultcompra < vfecha_hoy_aux and vdiasatraso = 0 and vmontoinsoluto <= 0 then
      let vmop = "UR";
   elif vfecha_apertura >= vfecha_hoy_aux and vfechaultpago < vfecha_hoy_aux and vfechaultcompra < vfecha_hoy_aux and vdiasatraso = 0 then
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
--   elif (vdiasatraso >= 150 and vdiasatraso <= (vfecha_hoy - (vfecha_hoy - 1 units year)) - 1) then
--   elif (vdiasatraso >= 150 and vdiasatraso <= 354) then
   elif (vdiasatraso >= 150 and vdiasatraso <= (abs(date(vfecha_hoy)) - abs(date(vfecha_hoy - 1 units year))) - 1) then
      let vmop = "07";
   else
      let vmop = "96";
   end if
--RQM 09 325 rss

   IF vsaldo_venc < 1 AND vcuotas_ven > 0 THEN
      LET vsaldo_venc = 1; 
   END IF

-- Agregar Saldo vencido
	IF  NVL(vsaldo_venc,'') = '' THEN --- RQM 09 467_Version 14
            let vsegmento4_tl = trim(vsegmento4_tl)||'2400';
	ELSE
		LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2409'||LPAD(ROUND(vsaldo_venc,0),9,"0");
		LET tb_saldo_venc = ROUND(vsaldo_venc,0);
	END IF;

	
-- Agregar Numero de Pagos Vencidos
  IF vsaldo_venc > 0 THEN
     LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2504'||LPAD(vcuotas_ven,4,"0");
     LET tb_cuotas_ven = vcuotas_ven;
  END IF

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
  
     LET vsegmento4_tl = TRIM(vsegmento4_tl)||'2602'||vmop;
     LET tb_mop        = vmop;

   
--RQM 09 325 rss --IPCB 10sep14- RQM 06 316//Incluir producto 7000 tarjeta platino
    LET vstatus_credAnt = '';
    --IF vnum_producto IN ('6001','6600','7000') AND vStatusCred = 'AA' AND vmop != 'UR' THEN  
    IF vnum_producto IN ('6001','6600','7000','8100') AND vStatusCred = 'AA' AND vmop != 'UR' THEN
       SELECT status_cred  
         INTO vstatus_credAnt
         FROM bdicred:sd_maecredcont
        WHERE empresa = '001'
          AND fecha = vfecha_fin_mes_ant  --'2013/07/31'
          AND num_credito = vnum_credito;
    ELIF vnum_producto = '6011' AND vStatusCred IN ('AA','VP') AND vmop != 'UR' THEN
   select status_cred, nvl(nvl(monto_vencido + mto_venc_trasp,0) + -- MONTO VENCIDO
                     nvl(int_tra_no_exig,0) + -- INTERES VENCIDO
                     nvl(mto_venc_int,0),0)   
     into vstatus_credAnt, vsaldo_vencAnt
     from bdicred:sd_maecredcontcrd a inner join bdicred:sd_maesdoscontcrd b
       on a.num_credito = b.num_credito
    where a.empresa = '001'  and b.empresa = '001'
      and a.fecha = b.fecha 
      and a.fecha = vfecha_fin_mes_ant  --'2013/07/31'
      and a.num_credito = vnum_credito;
    END IF;
--IPCB 10sep14- RQM 06 316//Incluir producto 7000 tarjeta platino        
    --IF (vnum_producto IN ('6001','6600','7000') AND vstatus_credAnt IN ('BT','BA') AND vStatusCred = 'AA') 
	IF (vnum_producto IN ('6001','6600','7000','8100') AND vstatus_credAnt IN ('BT','BA') AND vStatusCred = 'AA')
		OR  (vnum_producto='6011' AND 
	 (vstatus_credAnt IN ('BT','BA') or (vstatus_credAnt ='VP' and vsaldo_vencAnt > 0))
	  AND vStatusCred IN ('AA','VP') AND vsaldo_venc <= 0) THEN 
			   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'3002'||'EL';
			   LET tb_clave_obs               = 'EL';
	END IF;

  
  LET vanio = year(vfecha_vencido);
  LET vmes = lpad(month(vfecha_vencido),2,"0");
  LET vdia = lpad(day(vfecha_vencido),2,"0");
  
  IF vmop IN ('00','01','UR') THEN  --RQM 09 467_Version 14
	LET vsegmento4_tl = TRIM(vsegmento4_tl)||'430801011900';
	LET tb_fecha_vencimiento = '01011900';
  ELSE
	LET vsegmento4_tl = TRIM(vsegmento4_tl)||'4308'||vdia||vmes||vanio;
	LET tb_fecha_vencimiento = vdia||vmes||vanio;
  END IF;

-- Saldo insoluto
  LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'4410'||
                       lpad(round(vmontoinsoluto,0),10,"0");
  LET tb_monto_insoluto = round(vmontoinsoluto,0);

-- MONTO DE ULTIMO PAGO
  LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'4509'||
                        lpad(round(vmontolutpago,0),9,"0");
  LET tb_ultimo_pago = round(vmontolutpago,0);
--RQM 09 325 rss 
-- PLAZO EN MESES RQM 09 467_Version 14
   IF vnum_producto = '6011' THEN  
	 let vsegmento4_tl  = TRIM(vsegmento4_tl)||'500'|| length(cplazo_meses)+3 || trim(cplazo_meses) || '.00';                       
	 let tb_plazo_meses = trim(cplazo_meses);    
  ELSE
	 LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'50040.00';
	 let tb_plazo_meses = '0'; 
  END IF; 
-- MONTO DE CRÉDITO A LA ORIGINACION  --RQM 09 467_Version 14
	IF vnum_producto <> '6011' THEN
	  SELECT monto_solicitado INTO dmonto_autorizado
		FROM bdisolic:ss_solicitudes
	   WHERE empresa = '001'
		 AND num_solicitud = vnum_credito;
	  
	  IF  nvl(dmonto_autorizado,'') = '' THEN	 
		 select nvl(monto_otorgado,0) INTO dmonto_autorizado
			from bdicred:sd_maesdos
			where empresa = "001"
			and num_credito = vnum_credito;
	  END IF;	 
	  
	  LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'5109'||
						  lpad(round(dmonto_autorizado,0),9,"0");
	  LET tb_monto_originacion = round(dmonto_autorizado,0);			 
    ELSE   
		SELECT nvl(monto_otorgado,0)    
        into d_monto_originacion
        FROM bdicred:sd_maesdoscontcrd
        where empresa = "001"
        and fecha = vfecha_fin_mes_ant
        and num_credito = vnum_credito;
    
	  LET vsegmento4_tl  = TRIM(vsegmento4_tl)||'5109'||
						lpad(round(d_monto_originacion,0),9,"0");
	  LET tb_monto_originacion = round(d_monto_originacion,0);
    END IF;	

-- Agregar clave de observacion -- Venta de Cartera Fin
   LET vsegmento4_tl = TRIM(vsegmento4_tl)||'9903FIN';
   LET vsegmento4_tl = 'TL'||TRIM(vsegmento4_tl);
-- TERMINA ARMADO SEGMENTO TL (Datos Financieros)

   IF TRIM(vsegmento_pn) != "PN" AND TRIM(vsegmento2_pa) != "PA" AND TRIM(vsegmento3_pe) != "PE" AND TRIM(vsegmento4_tl) != "TL" THEN
--
    --SELECT count(*) INTO iCP
		--FROM sepomex WHERE d_codigo = tb_cod_postal AND d_mnpio = tb_delegacion AND estado_abrev = tb_estado;

      IF iCP IS NULL THEN LET iCP = 0; END IF;

      IF iCP > 0 THEN

          BEGIN WORK;

          LET vnumreg = vnumreg + 1;
          INSERT INTO br_burofisicas_cortos_clon
               VALUES(vnumreg,vsegmento_pn);

          LET vnumreg = vnumreg + 1;
          INSERT INTO br_burofisicas_cortos_clon
               VALUES(vnumreg,vsegmento2_pa);
			   
		  LET vnumreg = vnumreg + 1; --RQM 09 467_Version 14  
		  INSERT INTO br_burofisicas_cortos_clon
				VALUES(vnumreg,vsegmento3_pe);			   

          LET vnumreg = vnumreg + 1;
          INSERT INTO br_burofisicas_cortos_clon
               VALUES(vnumreg,vsegmento4_tl);

    -- Se agrega tabla para grabar informacion enviada
          INSERT INTO br_burofisicas_describe_cortos_clon (num_credito, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, rfc, nacionalidad,
		         estado_civil, sexo, calle, colonia, delegacion, ciudad, estado, cod_postal, origen_dom, razon_social, origen_razon_soc, clave_usu,
				 nombre_usu, responsabilidad, tipo_cuenta, tipo_producto, clave_monetaria, num_pagos, frecpago, monto_pagar, fecha_apertura, fecha_ult_pago,
				 fecha_ult_compra, fecha_cierre, fecha_reporte, credito_maximo, saldo_actual, monto_otorgado, saldo_venc, cuotas_ven, mop, clave_obs, 
				 int_calculo, fecha_vencimiento, monto_insoluto, ultimo_pago, plazo_meses, monto_originacion, num_tarjeta) 
               VALUES (tb_num_credito, tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, 
                       tb_estado_civil, tb_sexo, tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
					   tb_codigo_pais, tb_nombre_empleador,tb_origen_razon_soc,  --RQM 09 467_Version 14  
					   tb_clave_usu, 
                       tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, 
                       tb_monto_pagar, tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, 
                       tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado, tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota,tb_fecha_vencimiento,tb_monto_insoluto,tb_ultimo_pago
					   ,tb_plazo_meses,tb_monto_originacion,vnum_tarjeta); --tb_plazo_meses,tb_monto_originacion, RQM 09 467_Version 14 
--                       tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado, tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota); 

		  
          COMMIT WORK;

          LET tb_total_sdo_vencido = tb_total_sdo_vencido + tb_saldo_venc;
          LET tb_total_sdo_actual = tb_total_sdo_actual + tb_saldo_actual;

          LET tb_total_seg_pn = tb_total_seg_pn + 1;
          LET tb_total_seg_pa = tb_total_seg_pa + 1;
          LET tb_total_seg_tl = tb_total_seg_tl + 1;

          LET contador_commit = contador_commit  + 1;
          LET tb_total_bloques = tb_total_bloques + 1;
          LET iTotalProcesados = iTotalProcesados + 1;
      END IF;
      LET iCP = 0;
   END IF

END FOREACH; 

UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_cortos_clon;
UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_describe_cortos_clon;

IF WEEKDAY(vfecha_hoy) = 1 THEN
-- Genera registro encabezado
    LET vheader = vencabezado1||vversion||vclave_usu_bc||vnombre_usu||
                  vciclo||vfecha_reporte||vuso_futuro||
                  RPAD(TRIM(vinf_adicional),98,"&");
    LET vnumreg = 1;
    LET tb_total_seg_intf = 1;

    LET tb_nombre_otorg = vnombre_usu;
    LET tb_domicilio_dev = 'INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.';

    INSERT INTO br_burofisicas_cortos_clon VALUES (vnumreg,vheader);

-- Descarga y arma segmento TRLR y lo inserta

/* Por el RQM 09 430 Envio de Cintas Semanales a Circulo de Crédito, se hace la separación de la generación de las cintas a las SICs
    LET varchivo = "genburofiscortos.sql";
    LET varchivo_des = "genburofis_describe_cortos.sql";

    LET vsql = '';
    LET vsql = 'echo " UNLOAD TO /resplogifx/burodecredito/enviodepagos/xburofiscortos.unl' ||
                    ' SELECT registro FROM bdiburo:br_burofisicas_cortos WHERE numreg=1 ' ||
                    ' UNION ' ||
                    ' SELECT CASE WHEN substr(a.registro,1,2)='||'''TL'''||' AND a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
                    ' THEN trim((select registro from bdiburo:br_burofisicas_cortos where numreg=a.numreg-2))::lvarchar ||' || 
                    ' trim((select registro from bdiburo:br_burofisicas_cortos where numreg=a.numreg-1))::lvarchar||' || 
                    ' trim((replace(registro,'||'''3002CV9903FIN'''||','||'''3002NV9903FIN'''||')))::lvarchar '  ||
                    ' ELSE trim((select registro from bdiburo:br_burofisicas_cortos where numreg=a.numreg-2))::lvarchar||' ||  
                    ' trim((select registro from bdiburo:br_burofisicas_cortos where numreg=a.numreg-1))::lvarchar||' ||  
                    ' trim(registro)::lvarchar' ||  
                    ' END' ||  
                    ' FROM bdiburo:br_burofisicas_cortos a where substr(a.registro,1,2)='||'''TL'''||' '||  
                    ' UNION ' ||  
                    ' SELECT '||'''TRLR'''||'||lpad(sum(saldo_actual)::DEC(14,0),14,'||'''0'''||')||'||''''''||'||lpad(sum(saldo_venc)::DEC(14,0),14,'||'''0'''||')' ||  
                    ' ||'||'''001'''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||' ||  
                    ' '||'''000000000'''||'||'||''''''||'||LPAD(count(*)::INTEGER,9,'||'''0'''||')||'||'''000000BANCOPPEL       '''||'||RPAD('||'''INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.'''||',160,'||'''*'''||') ' ||  
                    ' FROM bdiburo:br_burofisicas_describe_cortos;' ||
                    ' " > /resplogifx/burodecredito/enviodepagos/genburofiscortos.sql';
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/enviodepagos/genburofiscortos.sql';
    SYSTEM vsql;

    LET vsql = "sed 's/&/ /g' /resplogifx/burodecredito/enviodepagos/xburofiscortos.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/[~]*|//g' /resplogifx/burodecredito/enviodepagos/xburofis1cortos.unl > /resplogifx/burodecredito/enviodepagos/xburofis2cortos.unl ";
    SYSTEM vsql;

    LET vsql = "sed 's/|//g' /resplogifx/burodecredito/enviodepagos/xburofis2cortos.unl > /resplogifx/burodecredito/enviodepagos/xburofis1cortos.unl ";
    SYSTEM vsql;

    LET vsql = "cat /resplogifx/burodecredito/enviodepagos/xburofis1cortos.unl | tr -d '\n' > /resplogifx/burodecredito/enviodepagos/cintafispagos"||vfecha_reporte||".txt ";
    SYSTEM vsql;

    LET vsql = "rm /resplogifx/burodecredito/enviodepagos/xburofis*.unl /resplogifx/burodecredito/enviodepagos/genburofiscortos.sql";
    SYSTEM vsql;

    LET vsql = "gzip /resplogifx/burodecredito/enviodepagos/cintafispagos"||vfecha_reporte||".txt ";
    SYSTEM vsql;

*/--Por el RQM 09 430 Envio de Cintas Semanales a Circulo de Crédito, se hace la separación de la generación de las cintas a las SICs

END IF;

DROP TABLE sepomex;
DROP TABLE creditos;

LET cMensajeFin = 'El proceso ENVIO PAGOS PARCIALES se ejecutó exitosamente. Créditos procs. ' || iTotalProcesados;

IF DATE(vfecha_hoy) - DATE(dtFecha_ultimo_reporte) > 1 THEN
   LET dtFechaProxReporte = vfecha_hoy;
END IF;

IF EXISTS (SELECT * FROM bdinteg:si_feriado WHERE empresa = '001' AND pais = '001' AND fecha  = dtFechaProxReporte AND laborable = 'N') THEN
   LET dtFechaProxReporte = date(dtFechaProxReporte + 1);
END IF;


IF dtfechaproxreporte is null then LET dtfechaproxreporte = vfecha_hoy; END IF
UPDATE bdicred:sd_control_procesos
   SET fecha_proceso = dtFechaProxReporte,
       fecha_prox_proceso = dtFechaProxReporte + 1, --gev
	   status_proceso = 'F',
       mensaje        = vcodret || ' ' || cMensajeFin
 WHERE cod_proceso = 'cintaparcialbc_clon';   

 CALL bdicobranza:sp_inserta_bitacora_cob('001', cProceso, vcodret, cMensajeFin, '03') RETURNING vcodret2; 
 
RETURN vcodret,cMensajeFin;

END;
END PROCEDURE

DOCUMENT
'Se realiza procedimiento para reportar a las',
'sociedades crediticias por entregas parciales los',
'clientes que pagan y se ponen al corriente durante',
'el mes',
'AUTOR : Viridiana Osobampo',
'FECHA : 18/08/2009',
'BD    : BDIBURO';

create procedure "informix".burofisicas_clon()
       returning char(5),
                 char(50);

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

   define vlMnpioReportar  char(40);  --fmj dic2012
   define vlCodigoReportar   char(10);
   define vlCodigoPOstalZona char(5);
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
   
BEGIN

       ON EXCEPTION SET iSqlErr, iIsamErr
           IF iSqlErr != 0 THEN
              IF itempsepomex = 1 THEN
                 drop table sepomex;
              END IF;
              IF itempcredito = 1 THEN
                 drop table creditos;
              END IF;
              let vcodret = iSqlErr;
              IF (sCommit = -1) THEN
                 rollback work;
              END IF;
			  
			  let cMensaje = trim(vcodret) || '- ' || iIsamErr || '-' || trim(vnum_credito);
			  CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '02') RETURNING vcodret2;
			  
              RETURN vcodret,vnum_credito;
           END IF;
        END EXCEPTION;


   LET vsegmento4_tr           = '';
   LET tb_nombre_otorg         = '';
   LET tb_domicilio_dev        = '';

   LET iCP                     = 0;
   LET vsegmento_pe 		   = ''; --RQM 09 467_Version 14
   
--SET DEBUG FILE TO "/RESPALDOS/ipcb/cintas/trace_burofisicas.unl";
-- SET DEBUG FILE TO "/ifxsif01/macf/sics/burofisicas_clon.trc";  --PRUEBAS MACF 
-- TRACE ON; 

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
      into vfecha_hoy--, vfecha_corte
      from bdinteg:si_fechas
     where empresa = '001';

	 --let vfecha_hoy = mdy(12,1,2018);  -- RQM 09 502 TEST MACF 
	 
--temporal para pruebas unicamente
  -- let vfecha_hoy = mdy('01','31','2018');
  -- let vfecha_corte = mdy('01','20','2018');
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
when  d_estado= 'TLAXCALA'then 'TLA'
when  d_estado= 'VERACRUZ DE IGNACIO DE LA LLAVE'then 'VER'
when  d_estado= 'YUCATAN'then 'YUC'
when  d_estado= 'ZACATECAS'then 'ZAC'
when  d_estado= 'MEXICO'then 'EM'
ELSE '' END estado_abrev FROM bdinteg:si_catsepomex into temp sepomex with no log;

CREATE INDEX idx_sepomex ON sepomex(d_codigo,d_mnpio,estado_abrev) in dbs_movhis_idx5 online;
CREATE INDEX idx_sepomex1 ON sepomex(d_mnpio,estado_abrev) in dbs_movhis_idx5 online;
CREATE INDEX idx_sepomex2 ON sepomex(d_asenta,estado_abrev) in dbs_movhis_idx5 online;
CREATE INDEX idx_sepomex3 ON sepomex(d_codigo,estado_abrev) in dbs_movhis_idx5 online;



UPDATE STATISTICS MEDIUM FOR TABLE sepomex;

LET itempsepomex    = 1;

   let vfecha_ini = mdy(month(vfecha_hoy),1,year(vfecha_hoy));
   let vfecha_fin_mes_ant = date(vfecha_ini - 1 units day);

   let vano = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vano;

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

    
	--IF  (select count(*) from bdiburo:br_burofisicas_clon where numreg = 1 and  substr(registro,35,8) matches vfecha_reporte) = 0 THEN
	select count(*) into iCuenta_regs
	from bdiburo:br_burofisicas_clon where numreg = 1 and  substr(registro,35,8) matches vfecha_reporte;
	
	IF iCuenta_regs = 0 THEN
        truncate table "informix".br_burofisicas_describe_clon;
        truncate table "informix".br_burofisicas_clon;
        truncate table "informix".br_burofisicas_concilia_clon;
        DROP INDEX "informix".idx_br_burofisicas_clon; 
        DROP INDEX "informix".idx_br_burofisicas_describe_clon;
        DROP INDEX "informix".inxburoconcilia_clon;
		DROP INDEX "informix".idx_br_burofisicas_describe_clon_numtarj;

--- Genera registro encabezado para Circulo
       let vheader = vencabezado1||vversion||vclave_usu||vnombre_usu||vciclo||vfecha_reporte||vuso_futuro||rpad(trim(vinf_adicional),98,"&");

       insert into bdiburo:br_burofisicas_clon values(vnumreg,vheader);    

    END IF;

    UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_clon;
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_describe_clon;
    UPDATE STATISTICS medium for table "informix".br_burofisicas_concilia_clon;

--Se crea tabla temporal con los creditos a procesar TDC
	  SELECT c.numcte, c.num_producto, c.credito_externo,c.num_credito,c.status_cred, mae.fecha_apertura,c.campo_trab3, 0 as plazo
      FROM bdicred:sd_maecredcont c
	  INNER JOIN bdicred:sd_maecred mae on mae.empresa=c.empresa and mae.num_credito=c.num_credito and mae.fecha_apertura <= vfecha_hoy
      WHERE c.empresa = "001"
      AND c.fecha = vfecha_hoy 
	  and c.status_cred in ('AA','BA','BT')
      AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_clon)
      AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_clon)       

    UNION ALL
    SELECT c.numcte, c.num_producto, mae.credito_externo,c.num_credito,mae.status_cred, mae.fecha_apertura,c.campo_trab3, 0 as plazo
      FROM bdicred:sd_maecredcont c
      INNER JOIN bdicred:sd_maecred mae on mae.empresa=c.empresa and mae.num_credito=c.num_credito
      WHERE c.empresa = "001"
      AND c.fecha = vfecha_fin_mes_ant 
      and c.status_cred in ('AA','BA','BT')
      AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_clon)
      AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_clon)
      and c.num_credito not in (select num_credito from bdicred:sd_maecredcont WHERE empresa = '001' and fecha = vfecha_hoy)
    INTO temp creditos WITH NO LOG;


--Se anexa a tabla temporal con los creditos a procesar REESTRUCTURAS
    INSERT INTO creditos
    SELECT c.numcte, c.num_producto, c.credito_externo,c.num_credito,c.status_cred, c.fecha_apertura,c.campo_trab3, c.plazo
      FROM bdicred:sd_maecredcontcrd c
     WHERE c.empresa = "001"
       AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_clon)
       AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_clon)
       AND c.fecha = vfecha_hoy 
       AND c.num_producto = '6011';
	   
    INSERT INTO creditos
    SELECT c.numcte, c.num_producto, c.credito_externo,c.num_credito,mae.status_cred, mae.fecha_apertura,c.campo_trab3, mae.plazo
      FROM bdicred:sd_maecredcontcrd c
      INNER JOIN bdicred:sd_maecredcrd mae on mae.empresa=c.empresa and mae.num_credito=c.num_credito 
     WHERE c.empresa = "001"
       AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_clon)
       AND c.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_clon)
       and c.num_credito not in (select num_credito from bdicred:sd_maecredcontcrd WHERE empresa = '001' and fecha = vfecha_hoy and num_producto = '6011')
       AND c.fecha = vfecha_fin_mes_ant 
       AND c.num_producto = '6011';

--IPCB 06082014/Integra Cancelaciones aperturadas el mismo mes.
	INSERT INTO creditos
    SELECT a.numcte, a.num_producto,  '' credito_externo,b.num_credito, a.status_cred, a.fecha_apertura,a.campo_trab3, 0 as plazo
      FROM bdicred:sd_maecred a inner join bdicred:sd_cred_can b
        ON a.num_credito = b.num_credito  AND fecha_can BETWEEN vfecha_ini AND vfecha_hoy  AND folio_cancelacion <>''
     WHERE a.status_cred IN ('FF','FI')
       AND fecha_apertura BETWEEN  vfecha_ini AND vfecha_hoy 
       AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_clon)
       AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_clon);

	INSERT INTO creditos	   
	SELECT a.numcte, a.num_producto,  '' credito_externo,a.num_credito, status_cred, fecha_apertura,a.campo_trab3, a.plazo
	  FROM bdicred:sd_maecredcrd a INNER JOIN bdicred:sd_maecredanexocrd b
		ON b.empresa = a.empresa AND a.num_credito = b.num_credito AND b.fecha_proceso BETWEEN vfecha_ini AND vfecha_hoy
	 WHERE a.empresa = '001'
	   AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_clon)
       AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_clon)
       AND status_cred IN ('FF','FI')
	   AND num_producto = '6011'
	   AND fecha_apertura BETWEEN vfecha_ini AND vfecha_hoy;  

    CREATE INDEX idx_creditos ON creditos(status_cred,num_credito,credito_externo,num_producto,numcte);
    update statistics medium for table creditos;

    IF (select count(*) from bdiburo:br_burofisicas_clon) = 1 THEN
        select count(*)::integer into iTotalProcesados from creditos;
        INSERT INTO bdiburo:br_burofisicas_concilia_clon (empresa, num_producto, num_credito, motivo, fecha_cinta,int_calculo) VALUES('001',cNumProducto,vnum_credito,'TCP',vfecha_hoy,iTotalProcesados);
    END IF;

    select max(numreg) into vnumreg
    from bdiburo:br_burofisicas_clon where numreg > 0;


-- crea temporal pago de reestructuras -- reemplazar con indicadores de credito
    select num_credito, max(fecha_mov) fecha_mov
    from bdicred:sd_movhiscrd 
    where empresa = '001'
      and num_credito matches '61*'
      and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanualcrd)
      and codigo_ref = 1
      and reversado = 'N'
      and fecha_mov <= vfecha_hoy
    group by num_credito
    into temp MovtosCred with no log;
	
    create unique index indx_mov on MovtosCred(num_credito);
    update statistics medium for table MovtosCred;


	select valor 
	 into iEjecucion_primera_vez
	 from bdiburo:br_param where cod_param = 15;
	
    foreach with hold
        select numcte, num_producto, credito_externo, num_credito, status_cred, fecha_apertura,campo_trab3, plazo
          into vnumcte,cNumProducto, cCredExterno,vnum_credito,vstatus_cred, vfecha_apertura,vidbaja, cplazo_meses
          from creditos 
		  where num_credito not in ('700000000021','700000000013','700000000039') --Exclusion RQI 21 052  P-SIF-CRE-20150224-05
				 
        LET cNumCredito = vnum_credito;

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

		 -- RQM 09 502
		 if cNumProducto in('6001','6600','7000','8100') then
		    select a.num_tarjeta, a.status_tar
              into vnum_tarjeta, cStatus_tar		 
		      from bdicred:sd_tarjeta a
             where a.empresa = '001' and a.num_credito = vnum_credito
               and a.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where empresa = '001'
                                  and num_credito = a.num_credito and tipo_tarjeta = 'T');
            
			 
		 end if;
		 
		 --- Buscar cual tarjeta se enviÃ³ con anterioridad a BurÃ³
		 -- Si es primer envÃ­o se guardarÃ¡ la tarjeta en la nueva tabla br_bitacora_tarjeta
		 if iEjecucion_primera_vez = '1' then
			   insert into bdiburo:br_bitacora_tarjeta(num_credito, num_tarjeta, numcte)
			   values(vnum_credito,vnum_tarjeta,vnumcte);
			   
		 elif nvl(vnum_tarjeta,'') <> '' then -- Si tiene tarjeta y NO es primer envÃ­o revisar si vnum_tarjeta es igual a v_num_tarjeta_anterior (enviada antes)  
	 
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
		
-- INICIO SEGMENTO PN (Nombre)
        select 
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(apell_paterno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(apell_materno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(nombre1),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(nombre2),""),'1','L'),'0','O'),'5','S'),'8','B'),
             fecha_nac,trim(rfc),nvl(fecha_alta,""),nvl(nacionalidad,"01"),nvl(residencia,"MX"),
             nvl(estado_civil," "),nvl(sexo,"I"), trim(b.profesion)
         into vapell_paterno,vapell_materno,vnombre1,vnombre2,vfecha_nac,vrfc,vfecha_alta,vnacionalidad,vresidencia,
             vestado_civil,vsexo, vprofesion
         from bdinteg:si_cliente a,
              bdinteg:si_ctepf b
         where a.numcte=b.numcte
           and a.numcte=vnumcte;

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
          SELECT limit 1 Trim(f.nombrecalle)||' '|| case when nvl(a.numeroextcalle,'') = '' then 'SN' else Trim(a.numeroextcalle) end ||' '||
            Trim(a.numerointcalle),
                nvl(Trim(g.nombrezona),''),nvl(Trim(g.municipiozona),''), Trim(c.estado),-- a.cod_postal,
            lpad(trim(a.cod_postal),5,"0"),manzana,andador,lote,edificio,entrada,codini,codfin,
                nvl(substr( CodigoPOstalZona,1,5),''),
                case when f.nombrecalle like '%conocido%' or f.nombrecalle like '%CONOCIDO%' then 1 else 0 end,
                a.pais, a.ciudad, a.estado
            INTO vcalle, vcolonia,vdelegacion,vestado,vcod_postal, 
                 vmanzana,vandador,vlote,vedificio,ventrada, vcodini,vcodfin,
                 vlCodigoPOstalZona, scalle_conocido, cpais, vclave_ciudad, vclave_edo
            FROM bdinteg:si_direcciones_actual a 
                      left outer join bdisolic:ss_circulo_edos c on a.estado = c.clave
                      left outer join bdinteg:si_catzonas g on (a.numerociudad = g.numerociudad and a.numerocolonia = g.numerocolonia)
                      left outer join bdinteg:si_catcalles f on a.numerocalle = f.numerocalle
            WHERE a.numcte= vnumcte
            AND a.tipo_dir="1"
            AND c.empresa = "001";
                
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
               let vcalle1 =trim(vcalle1)||"and. "||     vmanzana ;
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
           let vcalle = vcalle[2,26];
           let existe1 = existe1 + 1;
         end while;
         let vcalle = trim(vquita);
         if hueco = 0 then
           let vcalle = trim(vquita)||" 1";
         end if;
         let vciudad = "";

         if vcod_postal IS NULL then
            let vcod_postal = "00000";
         end if;
   
        
--IPCB Abr15 - Envio de tramas sin direccion, asignacio de blando, para armar la trama
		IF vestado is null or vestado = '' THEN
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
		END IF;

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
		if vdelegacion = '' or vdelegacion is null then
         --estado y ciudad de si_direcciones_actual para con eso consultar el nombre de la ciudad en si_ciudades.
         SELECT nvl(nombre,'') INTO vciudad
           FROM bdinteg:si_ciudades 
          WHERE estado = vclave_edo
            AND ciudad = vclave_ciudad;       

         if vciudad = '' OR vciudad is null then 
			let vciudad = '';  
			let vsegmento2_pa = trim(vsegmento2_pa)||'0300'; --RQM 09 467_Version 14
         else-- vciudad != ''  then
           let vsegmento2_pa = trim(vsegmento2_pa)||'03'||
                               lpad(length(trim(vciudad)),2,"0")||vciudad;
           let tb_ciudad        = vciudad;
         end if
		end if
		 
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
-- INICIA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14
  --Etiqueta PE -Nombre o Razo Social del empleador 
        SELECT nvl(a.nombre_empresa,'')
          INTO cnombre_empleador
          FROM bdinteg:si_ingresos a
         WHERE a.numcte = vNumcte
           AND a.sec_ingreso = (SELECT max(sec_ingreso)
                                  FROM bdinteg:si_ingresos 
                                 WHERE numcte = a.numcte);

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
    END IF;
    
	let vsegmento_pe = 	lpad(length(trim(cnombre_empleador)),2,"0")  || trim(cnombre_empleador);
	let tb_nombre_empleador = trim(cnombre_empleador);
	
	SELECT limit 1 Trim(f.nombrecalle)||' '|| case when nvl(a.numeroextcalle,'') = '' then 'SN' else Trim(a.numeroextcalle) end ||' '||
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
	   let vcalle_pe1 =trim(vcalle_pe1)||"and. "||     vmanzana_pe ;
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
	let vcalle_pe = vcalle_pe[2,26];
	let existe1 = existe1 + 1;
	END while;
	let vcalle_pe = trim(vquita);
	if hueco = 0 THEN
	let vcalle_pe = trim(vquita)||" 1";
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
		-- Agrega Ciudad
			--estado y ciudad de si_direcciones_actual para con eso consultar el nombre de la ciudad en si_ciudades.
		SELECT nvl(nombre,'') INTO vciudad_pe
		FROM bdinteg:si_ciudades 
		WHERE estado = vclave_edo_pe
		AND ciudad = vclave_ciudad_pe;       

		if vciudad_pe = '' OR vciudad_pe is null then 
			let vciudad_pe = '';  
			let vsegmento_pe = trim(vsegmento_pe)||'0400'; --RQM 09 467_Version 14
		else-- vciudad_pe != ''  then
			let vsegmento_pe = trim(vsegmento_pe)||'04'||
							   lpad(length(trim(vciudad_pe)),2,"0")||vciudad_pe;
			let tb_ciudad_pe        = vciudad_pe;
		end if;
	end if;

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
-- TERMINA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14

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
		-- RQM 09 502 - Se modifica para agregar en su lugar el NÃºmero de tarjeta - solo si no es Reestructura
		 if cNumProducto in('6001','6600','7000','8100') then
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
         LET vfrecpago        =  "M";
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

		--- RQM 09 502 MACF - Si tarjeta cambiÃ³, obtener la causa del cambio dependiendo de ello se informa clave de observaciÃ³n
		if cNumProducto in('6001','6600','7000','8100') then
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
		
     		 
-- Claves de observacion de cierre el saldo es CERO
        -- if (vstatus_cred = 'FF' or vstatus_cred = 'FC' or vstatus_cred = 'CV') then
          if (vstatus_cred = 'FF' or vstatus_cred = 'FC' or vstatus_cred = 'CV' or vstatus_cred = 'FI' ) then
            let vmonto = 0;
            let vsaldo_actual = 0;
            let vsaldo_venc = 0;
            if (cNumProducto <> '6011') then
              --if (vstatus_cred = 'FF') then RQM 09 343-0
              if (vstatus_cred IN ('FF','FI') ) then 
                    select nvl(monto_otorgado,0) -- MONTO OTORGADO
                    into vmonto_otorgado
                    from bdicred:sd_maesdos
                    where empresa = "001"
                    and num_credito = vnum_credito;
                elif (vstatus_cred = 'FC') then
                    select nvl(monto_otorgado,0) -- MONTO OTORGADO
                    into vmonto_otorgado
                    from bdicred:sd_maesdos_vendida
                    where empresa = "001"
                   and num_credito = vnum_credito;
                else
  -- Obtiene el saldo vencido de la cuenta vendida de TDC    
--IPCB 12mar14 Se cambia la extraccio del saldo vencido para no duplicar el capital y considerar el iva  
                    select nvl(((monto_vencido + mto_venc_trasp) + 
                               ((sdo_moratorio + sdo_contab_mora)*1.16)) + 
                                (select sum((interes_debe - interes_pagado) + (iva_debe - iva_pagado)) 
                                   from bdicred:sd_amortiza_credito_vendida
                                  where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7')),0),
                            nvl(monto_otorgado,0),
                            nvl(mto_fin_ven_trasp,0) -- CUOTAS VENCIDAS
                      into vsaldo_venc,
                           vmonto_otorgado,
					       vcuotas_ven
                      from bdicred:sd_maesdos_vendida a
                     where empresa = "001"
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
				
				select nvl(monto_otorgado,0) -- MONTO OTORGADO
				into vmonto_otorgado 
				from bdicred:sd_maesdoscont 
				where empresa = "001"
				and fecha = vfecha_hoy
				and num_credito = vnum_credito;

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
				IF vstatus_cred IN ('AA','BA') AND cNumProducto = '6001' THEN--IPCB Jul 2018 -Agrega al saldo  el saldo de las credisoluciones con que cuente.
					SELECT NVL(SUM(c.sdo_cap_insoluto),0)
					  INTO vsdo_cierre_credisol
					  FROM bdicred:sd_promocion_credito a
						INNER JOIN bdicred:sd_maecredcontcrd b on b.fecha = vfecha_hoy and b.empresa = a.empresa and b.num_credito = a.num_sol_prestamo and b.status_cred = 'AA'
						INNER JOIN bdicred:sd_maesdoscontcrd c on c.fecha = vfecha_hoy and c.empresa = a.empresa and c.num_credito = a.num_sol_prestamo
					 WHERE a.empresa = '001'
				       AND a.num_credito = vnum_credito;
					 
					 IF (vmontoinsoluto < 0 or vmontoinsoluto is null) THEN
						LET vmontoinsoluto = vsdo_cierre_credisol;
					 ELSE
						LET vmontoinsoluto = vmontoinsoluto +  vsdo_cierre_credisol;  
					END IF;	
				END IF;	   
			end if;
          end if;
--IPCB 19092013 redondeo de vmondo centavos a uno
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

    -- Agregar Fecha de Ultimo Pago
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
                   and num_credito = vnum_credito;
            else
                select nvl(monto_otorgado,0)
                  into vcredito_maximo
                  from bdicred:sd_maesdoscrd
                 where empresa = "001"
                   and num_credito = vnum_credito;
            end if;

            let vmonto_otorgado = vcredito_maximo;

            select nvl(fecha_vencido,date(1)), -- primer incumplimiento
                   nvl(dias_atraso,0), -- dias de atraso
                   nvl(fecha_ultimo_pago_h,date(1)) -- fecha de ultimo pago
              into vfecha_vencido,
                   vdiasatraso,
                   vfechaultpago
              from bdicred:sd_indicador_cred_crd
             where empresa = "001" 
               and num_credito = vnum_credito;	
         else
            select nvl(fecha_ultimo_pago_h,date(1)), --fecha de ultimo pago
                   nvl(fecha_ultima_compra_h,date(1)), --fecha de ultima compra
                   nvl(saldo_maximo_h,0), --credito maximo
                   nvl(fecha_vencido,date(1)), -- primer incumplimiento
                   nvl(dias_atraso,0), -- dias de atraso
                   nvl(monto_ultimo_pago_h,0) -- monto de ultimo pago
              into vfechaultpago,
                   vfechaultcompra,
                   vcredito_maximo,
                   vfecha_vencido,
                   vdiasatraso,
                   vmontolutpago
              from bdicred:sd_indicador_cred
             where empresa = "001" 
               and num_credito = vnum_credito;	
         end if;
           
         --if (vfechaultpago   is null) then let vfechaultpago   = date(1); end if;   -- RQM 09 467_Version 14
         --if (vfechaultcompra is null) then let vfechaultcompra = date(1); end if;   -- RQM 09 467_Version 14

         let vano = year(vfechaultpago);
         let vmes = lpad(month(vfechaultpago),2,"0");
         let vdia = lpad(day(vfechaultpago),2,"0");

         IF (vfechaultpago IS NOT NULL AND vfechaultpago <> '01/01/1900') THEN 
            let vsegmento3_tl = trim(vsegmento3_tl)||'1408'||vdia||vmes||vano;
			let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1408'||vdia||vmes||vano; --MACF
            let tb_fecha_ult_pago    = vdia||vmes||vano;
         else
            let vsegmento3_tl = trim(vsegmento3_tl)||'1400';
			let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1400'; --MACF
            let tb_fecha_ult_pago    = '';
         end if;
         
    -- Agregar Fecha de Ultima Compra
         let vano = year(vfechaultcompra);
         let vmes = lpad(month(vfechaultcompra),2,"0");
         let vdia = lpad(day(vfechaultcompra),2,"0");

         IF (vfechaultcompra IS NOT NULL AND vfechaultcompra <> '01/01/1900') THEN
           let vsegmento3_tl = trim(vsegmento3_tl)||'1508'||vdia||vmes||vano;
		   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1508'||vdia||vmes||vano; --MACF
           let tb_fecha_ult_compra  = vdia||vmes||vano;
         ELSE
           let vsegmento3_tl = trim(vsegmento3_tl)||'1500';
		   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1500';  --MACF
           let tb_fecha_ult_compra  = '';
         END IF;
    -- Agregar Fecha de cierrre de la cuenta

        if vClaveObserv_tarjeta  = 'LS' then --RQM 09 502 MACF
		   let vano = year(vfecha_hoy);
		   let vmes = lpad(month(vfecha_hoy),2,"0");
           let vdia = lpad(day(vfecha_hoy),2,"0");
		
		   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1608'||vdia||vmes||vano; --MACF
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
		 let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'1708'||vfecha_reporte; --MACF
         let tb_fecha_reporte     = vfecha_reporte;

    -- Agregar Credito Maximo
         if vcredito_maximo < vsaldo_actual then let vcredito_maximo = vsaldo_actual; end if;

         let vsegmento3_tl = trim(vsegmento3_tl)||'2109'||
                               lpad(round(vcredito_maximo,0),9,"0");
		 let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2109'||       --MACF
                               lpad(round(vcredito_maximo,0),9,"0");
         let tb_credito_maximo    = round(vcredito_maximo,0);

    -- Agregar Saldo Actual
		 if vClaveObserv_tarjeta  = 'LS' then --RQM 09 502 MACF
		    let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2200';  --MACF
			let tb_saldo_actual_2  = 0; 
		 end if;

		 if nvl(vsaldo_actual,'') = '' then --- RQM 09 467_Version 14
			let vsegmento3_tl = trim(vsegmento3_tl)||'2200';
		 end if; 
		 
		 if (vsaldo_actual > 0 and vsaldo_actual < 1) then
			 let vsaldo_actual = 1;
		 end if;

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

		 
    -- Agregar Limite de Credito
         if (vmonto_otorgado > 0 and vmonto_otorgado < 1) then
            let vmonto_otorgado=1;
         end if;
		 
		IF vmonto_otorgado is null or vmonto_otorgado = '' THEN
			let vsegmento3_tl = trim(vsegmento3_tl)||'2300';
			let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2300';  --MACF
		ELSE
			let vsegmento3_tl = trim(vsegmento3_tl)||'2309'||
								 lpad(round(vmonto_otorgado,0),9,"0");
			let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2309'||      --MACF
								 lpad(round(vmonto_otorgado,0),9,"0");
			let tb_monto_otorgado    = round(vmonto_otorgado,0);
		END IF;

    -- Agregar Saldo vencido
       if vClaveObserv_tarjeta  = 'LS' then --RQM 09 502 MACF
		  let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2400';  --MACF
       	  let tb_saldo_venc_2 = 0; 
	   end if;

	   if (vsaldo_venc > 0 and vsaldo_venc < 1) then
		  let vsaldo_venc=1;
	   end if;
	 
	   if  nvl(vsaldo_venc,'') = '' then --- RQM 09 467_Version 14
			let vsegmento3_tl = trim(vsegmento3_tl)||'2400';
	   else
			let vsegmento3_tl = trim(vsegmento3_tl)||'2409'||
							 lpad(round(vsaldo_venc,0),9,"0");
			let tb_saldo_venc        = round(vsaldo_venc,0);
	   end if;

	   
        -- Agregar Numero de Pagos Vencidos
       if (vsaldo_venc <= 0 or vcuotas_ven is null) then
           let vcuotas_ven = 0;
       end if;

       let vsegmento3_tl = trim(vsegmento3_tl)||'2504'||
                         lpad(vcuotas_ven,4,"0");
	   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2504'||  --MACF
                         lpad(vcuotas_ven,4,"0");	
       let tb_cuotas_ven        = vcuotas_ven;

    -- Agregar Forma de Pago
       -- UR = consideran creditos que no tuvieron movimientos en el 
       --      mes de generacion de la cinta (del dia 1 al Ãºltimo dia del mes que se reporta)
       -- 00 = se consideran creditos que fueron aperturados en el mes de 
       --      generacion de la cinta (del dia 1 al Ãºltimo dia del mes que se reporta)
       -- 01 = se consideran creditos que estÃ¡n al corriente y que hayan tenido movimientos. 
       --      Asi mismo se incluyen los creditos que fueron aperturados en el mes de generacion 
       --      de la cinta (del dia 1 al Ãºltimo dia del mes que se reporta) y hayan tenido movimientos en ese mismo mes
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
		   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'2602UR';  --MACF
		   let tb_mop_2        = 'UR';	
	   end if;
	   

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

		   let vsegmento3_tl = trim(vsegmento3_tl)||'2602'||vmop;
		   let tb_mop               = vmop;

	   
		--IPCB27sep2013 Integra consulta a sd_maecredcont para validar estatus de credito anterior 
		if vstatus_cred = 'AA' or (vstatus_cred = 'VP' and vsaldo_venc <= 0) Then
			if (cNumProducto = '6001' or cNumProducto = '6600') then
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
	 
	    -- RQM 09 502 MACF  clave de observaciÃ³n
		if vClaveObserv_tarjeta = 'LS' then
		    LET vsegmento3_tl_2 = TRIM(vsegmento3_tl_2)||'3002'|| vClaveObserv_tarjeta;  --MACF
			LET tb_clave_obs_2               = vClaveObserv_tarjeta;
		end if;	 
		
			if (vstatus_cred = 'CV') then
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
			elif ((vstatus_credAnt in ('BT','BA') and vstatus_cred = 'AA')
				  or ((vstatus_credAnt= 'VP' and vsaldo_vencAnt > 0) 
					   and (vstatus_cred = 'VP' and vsaldo_venc <= 0))) then 
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
		*/ --indica Ángeles Corvera que esto se sustituye por lo del RQM 09 502
		
		--- RQM 09 502 MACF
		--- CÃ³digo anterior comentado se sustituye por el siguiente:   
		
		if cNumProducto in('6001','6600','7000','8100') then
		   --- RQM 09 502 MACF    -- PRIMERA EJECUCIÓN
		   if iEjecucion_primera_vez = '1' then
			   let vsegmento3_tl = trim(vsegmento3_tl)||'41'||
			   lpad(length(trim(vnum_credito)),2,"0")||trim(vnum_credito);
			   let tb_num_credito_ext       = trim(vnum_credito);
                -- Validar si la tarjeta reportada es diferente a la actual y no hubo cancelaciÃ³n por Robo o extravÃ­o
			elif cTarjetaCambiada = 'S' and vClaveObserv_tarjeta = '' then
                   -- Significa que ya se asignó una nueva y no hay clave obs LS				
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
		LET vsegmento3_tl_2 = TRIM(vsegmento3_tl_2)||'430801011900';  --MACF
		LET tb_fecha_vencimiento = '01011900';
	   ELSE
		LET vsegmento3_tl = TRIM(vsegmento3_tl)||'4308'||vdia||vmes||vano;
		LET vsegmento3_tl_2 = TRIM(vsegmento3_tl_2)||'4308'||vdia||vmes||vano;  --MACF
		LET tb_fecha_vencimiento = vdia||vmes||vano;
	   END IF;
	   
    -- SALDO INSOLUTO DEL PRINCIPAL
       LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'4410'||
                            lpad(round(vmontoinsoluto,0),10,"0");
	   LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'4410'||      --MACF
                            lpad(round(vmontoinsoluto,0),10,"0");
       let tb_monto_insoluto = round(vmontoinsoluto,0);

    -- MONTO DE ULTIMO PAGO
       LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'4509'||
                            lpad(round(vmontolutpago,0),9,"0");
	   LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'4509'||    --MACF
                            lpad(round(vmontolutpago,0),9,"0");	
       let tb_ultimo_pago = round(vmontolutpago,0);
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
		 LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'50040.00';   --MACF
         let tb_plazo_meses = '0'; 
      END IF;

      --Monto del Credito en la originacio IPCB
      IF cNumProducto <> '6011' THEN
          SELECT monto_solicitado INTO dmonto_autorizado
            FROM bdisolic:ss_solicitudes
           WHERE empresa = '001'
             AND num_solicitud = vnum_credito;
		  
		  IF  nvl(dmonto_autorizado,'') = '' THEN	 
		     select nvl(monto_otorgado,0) INTO dmonto_autorizado
				from bdicred:sd_maesdos
				where empresa = "001"
				and num_credito = vnum_credito;
		  END IF;	 
		  
		  LET vsegmento3_tl  = TRIM(vsegmento3_tl)||'5109'||
                              lpad(round(dmonto_autorizado,0),9,"0");
		  LET vsegmento3_tl_2  = TRIM(vsegmento3_tl_2)||'5109'||      --MACF
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
	   let vsegmento3_tl_2 = trim(vsegmento3_tl_2)||'9903FIN';  --MACF
       let vsegmento3_tl_2 = 'TL'||trim(vsegmento3_tl_2);
 	   
--IPCB Abr15- Se modifica la validacio para integrar a la cinta los registros marcados con CSS en la concilia .
        --- VALIDAR CON RICARDO SI ESTA PARTE SEGUIRA EXISTIENDO - RQM 09 467_Version 14
       if bmotivo = 1 then
           INSERT INTO bdiburo:br_burofisicas_concilia_clon VALUES('001',cNumProducto,vnum_credito,'CSS',vfecha_hoy,
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
                INSERT INTO bdiburo:br_burofisicas_concilia_clon (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CPS',vfecha_hoy);
			END IF;
       end if;
			let vsegmento3_tl = replace(vsegmento3_tl,'TGD0924BAN',vclave_usu_bc);
			
			let vnumreg = vnumreg + 1;
			insert into br_burofisicas_clon
			values(vnumreg,vsegmento_pn);

			let vnumreg = vnumreg + 1;
			insert into br_burofisicas_clon
			values(vnumreg,vsegmento2_pa);
			
			let vnumreg = vnumreg + 1; --RQM 09 467_Version 14  
			insert into br_burofisicas_clon
			values(vnumreg,vsegmento_pe);
			
			let vnumreg = vnumreg + 1;
			insert into br_burofisicas_clon
			values(vnumreg,vsegmento3_tl);
			

		
--    let tb_fecha_nac=tb_fecha_nac;let tb_fecha_apertura=tb_fecha_apertura;let tb_fecha_ult_pago=tb_fecha_ult_pago;let tb_fecha_ult_compra=tb_fecha_ult_compra;let tb_fecha_cierre=tb_fecha_cierre;let tb_fecha_reporte=tb_fecha_reporte;let tb_fecha_vencimiento=tb_fecha_vencimiento;
-- Se agrega tabla para grabar informacion enviada
--IPCB 12mar14 - Se integran al insert vstatus_cred,cNumProducto
			insert into br_burofisicas_describe_clon
			   values (tb_num_credito, tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
					   tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
					   tb_codigo_pais, tb_nombre_empleador,tb_calle_pe,tb_colonia_pe,tb_delegacion_pe,tb_ciudad_pe,tb_estado_pe,tb_cod_postal_pe, tb_origen_razon_soc,  --RQM 09 467_Version 14  
					   tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar,
					   tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado,
					   tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota,tb_fecha_vencimiento,tb_monto_insoluto,tb_ultimo_pago,tb_plazo_meses,tb_monto_originacion,vstatus_cred,cNumProducto,tb_num_credito_ext,tb_num_tarjeta);

-- RQM 09 502 MACF Si hubo cambio de tarjeta y la causa fue Robo o Extravio (cve observ LS) se inserta otro registro casi identico
			-- pero con saldos en ceros para cerrar esa TDC ante las SICs
			if cTarjetaCambiada = 'S' then
			
			    if vClaveObserv_tarjeta = 'LS' then
					let vsegmento3_tl_2 = replace(vsegmento3_tl_2,'TGD0924BAN',vclave_usu_bc);
				
					let vnumreg = vnumreg + 1;
					insert into br_burofisicas_clon
					values(vnumreg,vsegmento_pn);

					let vnumreg = vnumreg + 1;
					insert into br_burofisicas_clon
					values(vnumreg,vsegmento2_pa);
					
					let vnumreg = vnumreg + 1; --RQM 09 467_Version 14  
					insert into br_burofisicas_clon
					values(vnumreg,vsegmento_pe);
					
					let vnumreg = vnumreg + 1;
					insert into br_burofisicas_clon
					values(vnumreg,vsegmento3_tl_2);
					
					insert into br_burofisicas_describe_clon
					values (tb_num_credito, tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
						   tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
						   tb_codigo_pais, tb_nombre_empleador,tb_calle_pe,tb_colonia_pe,tb_delegacion_pe,tb_ciudad_pe,tb_estado_pe,tb_cod_postal_pe, tb_origen_razon_soc,
						   tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar_2,
						   tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre_2, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual_2, tb_monto_otorgado,
						   tb_saldo_venc_2, tb_cuotas_ven, tb_mop_2,tb_clave_obs_2, vrea_cal_cuota,tb_fecha_vencimiento,tb_monto_insoluto,tb_ultimo_pago,tb_plazo_meses,tb_monto_originacion,vstatus_cred,cNumProducto,tb_num_credito_ext,tb_num_tarjeta_ant);
			    end if;
				
				--Antes de terminar, si la tarjeta cambio respecto a la enviada anteriormente actualizar la cuenta con la nueva tarjeta
				if vnum_tarjeta <> '0000000000000000' then
					update bdiburo:br_bitacora_tarjeta
					   set num_tarjeta =  vnum_tarjeta, cambio = 'S'
					 where num_credito = vnum_credito;
				else
				    update bdiburo:br_bitacora_tarjeta
					   set num_tarjeta =  '', cambio = 'X'
					 where num_credito = vnum_credito; 
				end if;
				
			end if;
					   
		    let contador_commit = contador_commit  + 1;
			let actualiza_esta = actualiza_esta + 1;

       let cNumProducto = '';  let cCredExterno = '';

	   
       IF (contador_commit >= 50) THEN
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
	  
      end foreach
      
  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;
  LET sCommit = 0;
  
  --COMENTADAS PARA PRUEBAS MACF
  --BEGIN;  CREATE INDEX "informix".idx_br_burofisicas_clon          ON "informix".br_burofisicas_clon(numreg) in dbs_movhis_idx3 ONLINE;  COMMIT;
  --BEGIN;  CREATE INDEX "informix".idx_br_burofisicas_describe_clon ON "informix".br_burofisicas_describe_clon(num_credito) in dbs_movhis_idx3 ONLINE;  COMMIT;
  --BEGIN;  CREATE INDEX "informix".inxburoconcilia_clon             ON "informix".br_burofisicas_concilia_clon(empresa, num_producto, num_credito, motivo, fecha_cinta) in dbs_movhis_idx3 ONLINE;  COMMIT;

  -- CREADAS PARA PRUEBAS MACF
  CREATE INDEX "informix".idx_br_burofisicas_clon          ON "informix".br_burofisicas_clon(numreg) in dbs_movhis_idx5 online;
  CREATE INDEX "informix".idx_br_burofisicas_describe_clon ON "informix".br_burofisicas_describe_clon(num_credito) in dbs_movhis_idx5 online;
  CREATE INDEX "informix".inxburoconcilia_clon             ON "informix".br_burofisicas_concilia_clon(empresa, num_producto, num_credito, motivo, fecha_cinta) in dbs_movhis_idx5 online;
  CREATE INDEX "informix".idx_br_burofisicas_describe_clon_numtarj  ON "informix".br_burofisicas_describe_clon(num_tarjeta) in dbs_movhis_idx5 online;
  
  update statistics medium for table "informix".br_burofisicas_clon;
  update statistics medium for table "informix".br_burofisicas_describe_clon;
  update statistics medium for table "informix".br_burofisicas_concilia_clon;
  
--temporal se inhabilita solo para pruebas
  --EXECUTE PROCEDURE burofisicas_concilia(vfecha_reporte) INTO vcodret;
--temporal se inhabilita solo para pruebas

  drop table sepomex; drop table creditos;     --- Comentar para pruebas solamente RQM 09 467_Version 14


    let cMensajeFin = 'Creditos procs. ' || iTotalProcesados;
    
    /* --- SOLO PRUEBAS
    LET vHora = ''; LET vDia1 = '';
     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vDia1 
      from sysmaster:sysshmvals;

     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora 
      from sysmaster:sysshmvals;

      INSERT INTO bdiburo:br_cronometro(accion,fecha,hora) values('Final',vDia1, vHora);
    --- SOLO PRUEBAS  */
    CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, vcodret, cMensaje, '03') RETURNING vcodret2; 
	
	
  return vcodret,cMensajeFin;
END;
end procedure;