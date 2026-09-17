CREATE PROCEDURE "informix".sp_burofisicas_cortos()
RETURNING CHAR(6),
          CHAR(100);


-- Autor: Roque Enrique Solis CampaÃ±a
-- Fecha de ModificaciÃ³n 19/08/2009
-- Observaciones: Se modifica el acceso a la tabla si_feriado de la base de datos bdinteg,
--                eliminaciÃ³n de variables innecesarias, omitir las comparaciones con los 
--                estatus y los filtros o validaciones que se hicieran con los mismos debido a 
--                que solo se espera crÃ©ditos con estatus "AA", contemplar la eliminaciÃ³n de las 
--                tablas temporales.
-- Fecha de ModificaciÃ³n 20/08/2009
-- Observaciones: Se modificaron el Ã­ndice de la tabla br_burofisicas_cortos.

DEFINE vcodret                       CHAR(6);
DEFINE vfecha_hoy                    DATE;
DEFINE vPriDiaMes                    DATE;
DEFINE vUltDiaMes					 DATE;
DEFINE vUltMesRep					 DATE;
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
DEFINE vdescripcion_feriado char(30);
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
LET vdescripcion_feriado = '';

BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
      LET vcodret = iSqlErr;

      LET cMensajeFin = 'Proceso ENVIO PAGOS PARCIALES cancelado' || ' ' || vnum_credito;

      UPDATE bdicred:sd_control_procesos
         SET status_proceso = 'C',
             mensaje        = vcodret || ' ' || cMensajeFin
       WHERE empresa='001' 
         AND cod_proceso = 'cintaparcialbc';

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

	 SELECT fecha_hoy,pri_dia_mes,ult_dia_mes
       INTO vfecha_hoy,vPriDiaMes,vUltDiaMes
       FROM bdicred:sd_fechas
      WHERE empresa='001';

--temporal para pruebas	  
--  let vfecha_hoy = mdy('01','15','2019');
--  let vPriDiaMes = mdy('01','01','2019');
--temporal para pruebas
   
   
   
   let vfecha_ini = mdy(month(vfecha_hoy),1,year(vfecha_hoy));
   let vfecha_fin_mes_ant = date(vfecha_ini - 1 units day);

-- Verifica que el control de procesos no reporte el proceso activo para poder ejecutarlo
   SELECT status_proceso, fecha_proceso, fecha_prox_proceso --gev
     INTO cStatusProc, dtFecha_ultimo_reporte, dtFechaProxReporte --gev
     FROM bdicred:sd_control_procesos
    WHERE empresa='001' 
      AND cod_proceso = 'cintaparcialbc';

 IF dtFecha_ultimo_reporte IS NULL THEN
     LET dtFecha_ultimo_reporte = vfecha_hoy - 1 UNITS DAY;
  END IF;
  
--IPCB Trae ultimo del mes de reporte
  IF month(dtFecha_ultimo_reporte) <> month(vfecha_hoy) THEN
	LET vUltMesRep = monthadd(vUltDiaMes, -1);
  ELSE
	LET vUltMesRep = vUltDiaMes;
  END IF;
 
  IF dtFechaProxReporte IS NULL THEN
    LET dtFechaProxReporte = vfecha_hoy;  
  END IF;
  
  
  IF cStatusProc IS NULL THEN
    INSERT INTO bdicred:sd_control_procesos (empresa,cod_proceso,fecha_proceso,status_proceso,fecha_prox_proceso)
    VALUES ('001','cintaparcialbc',vfecha_hoy-3 units day,'',vfecha_hoy);
  END IF;
	  
  IF cStatusProc = 'I' THEN
     LET vcodret = '000001';
     LET cMensajeFin = 'Proceso ENVIO PAGOS PARCIALES en ejecucion';
     RETURN vcodret,cMensajeFin;
  END IF;

-- Valida que el dÃ­a actual corresponda al dÃ­a de ejecuciÃ³n que indica el control de procesos   IF (vfecha_hoy <= NVL(dtFecha_ultimo_reporte,DATE(1)) AND cStatusProc = 'F') THEN
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
        WHERE cod_proceso = 'cintaparcialbc';

   ELSE
       UPDATE bdicred:sd_control_procesos
          SET --fecha_proceso = vfecha_hoy,
              status_proceso = 'I',
              mensaje = 'PROCESANDO'
        WHERE cod_proceso = 'cintaparcialbc';    
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
 ---CreaciÃ³n de indices por cada una de las validacines de SEPOMEX
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
     AND c.fecha = CASE WHEN DAY(b.fecha_ult_pago) >= b.dia_corte  and (b.dia_corte > day(vUltMesRep)) THEN
							 vUltMesRep
                        WHEN DAY(b.fecha_ult_pago) >= b.dia_corte  and  (b.dia_corte <= day(vUltMesRep)) THEN 
							 MDY(MONTH(b.fecha_ult_pago),b.dia_corte,YEAR(b.fecha_ult_pago))
                        WHEN DAY(b.fecha_ult_pago) < b.dia_corte  and  (b.dia_corte > day(bdicred:monthadd(vUltMesRep,-1)))THEN
							 bdicred:monthadd(vUltMesRep,-1)
						ELSE
							MDY(MONTH(bdicred:monthadd(vUltMesRep,-1)),b.dia_corte,YEAR(bdicred:monthadd(vUltMesRep,-1)))                        
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

    
	
	--IF EXISTS (SELECT * FROM bdiburo:br_burofisicas_cortos WHERE numreg = 1) THEN
	SELECT COUNT(*) INTO iCuenta_regs
	FROM bdiburo:br_burofisicas_cortos WHERE numreg = 1;
	
	IF iCuenta_regs > 0 THEN
        TRUNCATE TABLE "informix".br_burofisicas_describe_cortos;
        TRUNCATE TABLE "informix".br_burofisicas_cortos;
    END IF;

    select max(numreg) into vnumreg
    from bdiburo:br_burofisicas_cortos where numreg > 0;

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
 
      --IF EXISTS (SELECT * FROM bdiburo:br_burofisicas_describe_cortos WHERE num_credito = vnum_credito AND fecha_ult_pago = vfechaup) THEN 
      --   CONTINUE FOREACH; 
      --END IF;
	  
	  SELECT count(*) into iCuenta_regs_2
	  FROM bdiburo:br_burofisicas_describe_cortos WHERE num_credito = vnum_credito AND fecha_ult_pago = vfechaup;
	  
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

-- INICIA ARMADO SEGMENTO PA (DirecciÃ³n)
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
-- TERMINA ARMADO SEGMENTO PA (DirecciÃ³n)

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


	-- Agregar origen del domicilio De la razÃ³n social (pais) 
	let vsegmento3_pe = trim(vsegmento3_pe)||'1802MX';
	let tb_origen_razon_soc  = 'MX';

	let vsegmento3_pe = 'PE'||trim(vsegmento3_pe);           	  
-- TERMINA SEGMENTO PE (EMPLEO DEL CLIENTE) --RQM 09 467_Version 14	

-- INICIA ARMADO SEGMENTO TL (Datos Financieros)
    
	-- RQM 09 502 MACF
	-- Obtener el nÃºmero de tarjeta de br_burofisicas_describe
	if vnum_producto in('6001','6600','7000','8100','8500') then
		/*select limit 1 num_tarjeta into vnum_tarjeta
		  from bdiburo:br_burofisicas_describe
		 where num_credito = vnum_credito
           and nvl(fecha_cierre,'') = '';*/

    select num_tarjeta  into vnum_tarjeta
		  from bdiburo:br_bitacora_tarjeta
		 where num_credito = vnum_credito;		   
 	  
         -- si no existe, significa que no se enviÃ³ en la cinta mensual anterior, buscar en sd_tarjeta 
	     if nvl(vnum_tarjeta,'') = '' then
		    select a.num_tarjeta, a.status_tar
              into vnum_tarjeta, cStatus_tar		 
		      from bdicred:sd_tarjeta a
             where a.empresa = '001' and a.num_credito = vnum_credito
               and a.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where empresa = '001'
                                  and num_credito = a.num_credito and tipo_tarjeta = 'T');
								  
			-- Si tampoco estÃ¡ en sd_tarjeta, buscarla en intercard:tarjeta
			if nvl(vnum_tarjeta,'') = '' then
			   select limit 1 a.numtarjeta into vnum_tarjeta
			     from intercard:tarjeta a, intercard:tarjetacuenta b
                where a.numtarjeta = b.numtarjeta and b.numcuenta = vnum_credito and codstatustarjeta = 'ACT' and titular = 'T';
			end if;
            
			-- Si tampoco estÃ¡ en intercard:tarjeta
            if nvl(vnum_tarjeta,'') = '' then  			
			   let vnum_tarjeta = '0000000000000000'; --asignarle ceros para que no truene el armado de la cadena 
            end if;
			
		 end if;
    end if;	
	


	-- RQM 09 502 MACF

  --IF vnum_producto in ('6001','6600','7000') THEN  --IPCB 10sep14- RQM 06 316//Incluir producto 7000 tarjeta platino
  IF vnum_producto in ('6001','6600','7000','8100','8500') THEN 
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
   if vnum_producto in('6001','6600','7000','8100','8500') then  -- RQM 09 502
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

-- Agregar Saldo MÃ¡ximo

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
    IF vnum_producto IN ('6001','6600','7000','8100','8500') AND vStatusCred = 'AA' AND vmop != 'UR' THEN
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
	IF (vnum_producto IN ('6001','6600','7000','8100','8500') AND vstatus_credAnt IN ('BT','BA') AND vStatusCred = 'AA')
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
-- MONTO DE CRÃ?DITO A LA ORIGINACION  --RQM 09 467_Version 14
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
          INSERT INTO br_burofisicas_cortos
               VALUES(vnumreg,vsegmento_pn);

          LET vnumreg = vnumreg + 1;
          INSERT INTO br_burofisicas_cortos
               VALUES(vnumreg,vsegmento2_pa);
			   
		  LET vnumreg = vnumreg + 1; --RQM 09 467_Version 14  
		  INSERT INTO br_burofisicas_cortos
				VALUES(vnumreg,vsegmento3_pe);			   

          LET vnumreg = vnumreg + 1;
          INSERT INTO br_burofisicas_cortos
               VALUES(vnumreg,vsegmento4_tl);

    -- Se agrega tabla para grabar informacion enviada
          INSERT INTO br_burofisicas_describe_cortos (num_credito, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, rfc, nacionalidad,
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

UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_cortos;
UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_describe_cortos;

IF WEEKDAY(vfecha_hoy) = 1 THEN
-- Genera registro encabezado
    LET vheader = vencabezado1||vversion||vclave_usu_bc||vnombre_usu||
                  vciclo||vfecha_reporte||vuso_futuro||
                  RPAD(TRIM(vinf_adicional),98,"&");
    LET vnumreg = 1;
    LET tb_total_seg_intf = 1;

    LET tb_nombre_otorg = vnombre_usu;
    LET tb_domicilio_dev = 'INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.';

    INSERT INTO br_burofisicas_cortos VALUES (vnumreg,vheader);


-- Descarga y arma segmento TRLR y lo inserta

/* Por el RQM 09 430 Envio de Cintas Semanales a Circulo de CrÃ©dito, se hace la separaciÃ³n de la generaciÃ³n de las cintas a las SICs
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

*/--Por el RQM 09 430 Envio de Cintas Semanales a Circulo de CrÃ©dito, se hace la separaciÃ³n de la generaciÃ³n de las cintas a las SICs

END IF;

DROP TABLE sepomex;
DROP TABLE creditos;

LET cMensajeFin = 'El proceso ENVIO PAGOS PARCIALES se ejecuto exitosamente. Creditos procs. ' || iTotalProcesados;

IF DATE(vfecha_hoy) - DATE(dtFecha_ultimo_reporte) > 1 THEN
   LET dtFechaProxReporte = vfecha_hoy;
END IF;

--IF EXISTS (SELECT * FROM bdinteg:si_feriado WHERE empresa = '001' AND pais = '001' AND fecha  = dtFechaProxReporte AND laborable = 'N') THEN
--   LET dtFechaProxReporte = date(dtFechaProxReporte + 1);
--END IF;

SELECT descripcion INTO vdescripcion_feriado
  FROM bdinteg:si_feriado WHERE empresa = '001' AND pais = '001' AND fecha  = dtFechaProxReporte AND laborable = 'N';
  
IF nvl(vdescripcion_feriado,'') <> '' THEN
   LET dtFechaProxReporte = date(dtFechaProxReporte + 1);
END IF;

IF dtfechaproxreporte is null then LET dtfechaproxreporte = vfecha_hoy; END IF
UPDATE bdicred:sd_control_procesos
   SET fecha_proceso = dtFechaProxReporte,
       fecha_prox_proceso = dtFechaProxReporte + 1, --gev
	   status_proceso = 'F',
       mensaje        = vcodret || ' ' || cMensajeFin
 WHERE cod_proceso = 'cintaparcialbc';   

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

CREATE PROCEDURE "informix".sp_cac_calculalinsugcte
													(
														pEmpresa 		CHAR(3),
														pNumSolicitud	CHAR(20),
														pCompIngreso	CHAR(1),
														pIngresoMens	DECIMAL(18,2),
														pOtrosComp		DECIMAL(18,2)
													)
	RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET,
		DECIMAL(18,2)	AS LINEA_SUGERIDA,
		DECIMAL(18,2)	AS MONTO_INCREM,
		DECIMAL(4,2)	AS RAZON_INCREM,
		DECIMAL(5,2)	AS TASAINTERES_ANUAL_INCREM;

	---DECLARACIONES
	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cCodRet				CHAR(6);
	DEFINE cMensajeRet			CHAR(80);

	DEFINE dAum1				DECIMAL(18,2);
	DEFINE dAum2				DECIMAL(18,2);
	DEFINE sLineaCredito		SMALLINT;
	DEFINE dMontoOtor			DECIMAL(18,2);
	DEFINE dLineaSugerida		DECIMAL(18,2);
	DEFINE dLineaSolicitada		DECIMAL(18,2);
	DEFINE iNumPagos			INTEGER;
	DEFINE dtFechaNumPagos		DATE;
	DEFINE dtFechaHoy			DATE;
	DEFINE dCTP					DECIMAL(18,2);
	DEFINE dIDP					DECIMAL(18,2);
	DEFINE iPorcIngreso			INTEGER;
	DEFINE dCMA					DECIMAL(18,2);
	DEFINE dFCP					DECIMAL(18,2);
	DEFINE dCRA					DECIMAL(18,2);
	DEFINE dTIP					DECIMAL(18,2);
	DEFINE dPorcTopeValMin		DECIMAL(4,2);
	DEFINE dPorcTopeValMax_cci	DECIMAL(4,2);
	DEFINE dPorcTopeValMax_sci	DECIMAL(4,2);
	DEFINE dPagosRealizados		DECIMAL(18,2);
	DEFINE dCTC					DECIMAL(18,2);
	DEFINE dMontoIncremento		DECIMAL(18,2);
	DEFINE dRazonIncremento		DECIMAL(4,2);
	DEFINE dCompromPagoSIC		DECIMAL(18,2);
	DEFINE cBand1				CHAR(1);
	DEFINE dValorSM				DECIMAL(18,2);
	DEFINE dIngresoMensDec		DECIMAL(18,2);
	DEFINE dIngresoMaximo		DECIMAL(18,2);
	DEFINE dLineaMinima			DECIMAL(18,2);
	DEFINE dLineaMaxima_cci		DECIMAL(18,2);
	DEFINE dLineaMaxima_sci		DECIMAL(18,2);		
	DEFINE mCompromisosbanco    MONEY (14,2);
	DEFINE dImporte_hip		    MONEY (14,2);
	DEFINE dSalarioMin		    DECIMAL (18,2);
	DEFINE dTopeAbono		    DECIMAL (18,2);
	DEFINE dTopeSalMin		    DECIMAL (18,2);
	DEFINE cSucursal			CHAR(80);
	DEFINE dIvaSuc				DECIMAL(18,2);
	DEFINE dTasa_Interes        DECIMAL(9,6);		--	RQM 10 1224
	DEFINE dTasa_Mora           DECIMAL(9,6);	
	DEFINE cCodRetTDif			CHAR(6);

	---INICIALIZACIONES
	LET iSqlErr					= 0;
	LET iIsamErr           		= 0;
	LET cCodRet            		= '000000';
	LET cMensajeRet           	= 'PROCESO EXITOSO';
	LET dAum1					= 0.0;
	LET dAum2					= 0.0;
	LET sLineaCredito			= 0;
	LET dMontoOtor				= 0.0;
	LET dLineaSugerida			= 0.0;
	LET dLineaSolicitada		= 0.0;
	LET iNumPagos				= 0;
	LET dtFechaNumPagos			= DATE(1);
	LET dCTP					= 0.0;
	LET dIDP					= 0.0;
	LET iPorcIngreso			= 0;
	LET dCMA					= 0.0;
	LET dFCP					= 0.0;
	LET dCRA					= 0.0;
	LET dTIP					= 0.0;
	LET dPorcTopeValMin			= 0.0;
	LET dPorcTopeValMax_cci		= 0.0;
	LET dPorcTopeValMax_sci		= 0.0;
	LET dPagosRealizados		= 0.0;
	LET dCTC					= 0.0;
	LET dMontoIncremento		= 0.0;
	LET dRazonIncremento		= 0.0;
	LET dCompromPagoSIC			= 0.0;
	LET cBand1					= '0';
	LET dValorSM				= 0.0;
	LET dIngresoMensDec			= 0;
	LET dIngresoMaximo			= 0;
	LET dLineaMinima 			= 0 ;
	LET dLineaMaxima_cci 		= 0 ;
	LET dLineaMaxima_sci 		= 0 ;		
	LET mCompromisosbanco       = 0;	
	LET dImporte_hip           = 0;	
	LET dSalarioMin            = 0;								
	LET dTopeAbono             = 0;								
	LET dTopeSalMin            = 0;
	LET cSucursal              = '';
	LET dIvaSuc				   = 0.0;
	LET dTasa_Interes		   = 0; 				--	RQM 10 1224
	LET dTasa_Mora             = 0;	
	LET cCodRetTDif			   = 0;

	-- CMA - CAPACIDAD MAXIMA DE ABONOS
	-- CTP - CAPACIDAD TOTAL DE PAGOS
	-- IDP - INGRESO DEMOSTRADO EN PAGOS
	-- FCP - FACTOR PARA CAPACIDAD DE PAGO
	-- CRA - CAPACIDAD REAL DE ABONO

	BEGIN 
		ON EXCEPTION SET iSqlErr, iIsamErr, cMensajeRet
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN cCodRet, cMensajeRet, dLineaSugerida, dMontoIncremento, dRazonIncremento, dTIP ;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		 --SET DEBUG FILE TO '/informix/jesus/sp_cac_calculalinsugcte.out';
		 --TRACE ON;

		-- VALIDA QUE LOS PARAMETROS DE ENTRADA NO ESTEN VACIOS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumSolicitud,'') = '' OR NVL(pCompIngreso,'') = ''OR NVL(pIngresoMens,0.0) = 0.0 THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTAN PARAMETROS DE ENTRADA';
		ELSE						
			-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual menor a 1.27 sm 
			SELECT valor 
			INTO dAum2
			FROM bdicred:"informix".sd_param 
			WHERE cod_param = '017'
			AND empresa = pEmpresa;	
			-- validacion de los parametros.
			IF NVL(dAum2,0.0) = 0.0 THEN
				LET cCodRet = '000002';
				LET cMensajeRet = 'ERROR AL OBTENER PORCENTAJE DE INCREMENTO PARA SALARIOS MINIMOS MENORES A 1.27';
			ELSE
				-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual mayor o igual a 1.27 sm 
				SELECT valor 
				INTO dAum1
				FROM bdicred:"informix".sd_param 
				WHERE cod_param = '016'
				AND empresa = pEmpresa;

				-- validacion de los parametros.
				IF NVL(dAum1,0.0) = 0.0 THEN
					LET cCodRet = '000003';
					LET cMensajeRet = 'ERROR OBTENER EL PORCENTAJE DE INCREMENTO DE SALARIOS MINIMOS MAYORES A 1.27';
				ELSE
					-- Compara créd con lín créd MN para increm línea
					SELECT valor 
					INTO sLineaCredito
					FROM bdicred:"informix".sd_param
					WHERE cod_param = '023'
					AND empresa = pEmpresa;

					IF NVL(sLineaCredito,'') = '' THEN
						LET cCodRet = '000004';
						LET cMensajeRet = 'ERROR AL OBTENER LA LINEA DE CREDITO A COMPARAR PARA INCREMENTOS DE LINEA';
					ELSE
						-- OBTIENE LOS DATOS DE LA SOLICTUD DE AUMENTO DE LINEA DE CREDITO
						SELECT a.lincred_actual, a.lincred_solicitada,c.ingreso_mensual,a.compromisos_bco,a.compromisos_hip,a.pago_minimo,a.abonomensual,a.ingreso_idp, a.sucursal										
						INTO dMontoOtor, dLineaSolicitada,dIngresoMensDec,mCompromisosbanco,dImporte_hip,dCompromPagoSIC, dCTC,dIDP, cSucursal
						FROM bdicred:"informix".sd_bitacora_aumlincred a						
						INNER JOIN bdisolic:"informix".ss_resum_scor_fin c ON  c.num_solicitud = a.num_solicitud AND c.empresa = a.empresa	
						WHERE a.empresa = pEmpresa
						AND a.num_solicitud = pNumSolicitud
						AND a.status = 'AC'
						AND a.fecha_insert = a.fecha_insert;
						IF dbinfo('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '000005';
							LET cMensajeRet = 'NO EXISTEN DATOS DE AUMENTO DE LINEA DE CREDITO PARA ESTA SOLICITUD';
						ELSE
						
							
							-- OBTIENE EL VALOR DEL SALARIO MINIMO INCREMENTO DE LINEA
							SELECT TRIM(valor)::DECIMAL(18,2)
							INTO dValorSM
							FROM bdicred:"informix".sd_param
							WHERE empresa = '001'
							AND cod_param = '013';
							
							LET dSalarioMin = ROUND ((dValorSM * 30.42),-2);
							-- TOPA EL INGRESO MENSUAL AL VALOR DEL SALARIO MINIMON DE INCREMENTO DE LINEA CUANDO ESTE ES MENOR A 1 SM
							IF pIngresoMens < dSalarioMin THEN
								LET pIngresoMens = dSalarioMin;
							END IF
							-- VALIDA QUE TIENE COMPROBANTE DE INGRESOS
							IF pCompIngreso = '1' THEN
								IF dIDP > pIngresoMens THEN	
									LET pIngresoMens = dIDP;									
								END IF
							-- VALIDA QUE NO TIENE COMPROBANTE DE INGRESOS
							ELSE											
								
								SELECT TRIM(valor)::DECIMAL(18,2) --se homologa al tope de ingresos demostrado productivo
								INTO dTopeSalMin
								FROM bdisolic:"informix".ss_param 
								WHERE secuencia = '353'
								AND empresa = pEmpresa;	
								
								LET dIngresoMaximo= ROUND(dSalarioMin * dTopeSalMin,-2);
								
								IF dIngresoMensDec > dIngresoMaximo THEN	
									LET pIngresoMens = dIngresoMaximo;									
								END IF	
								
								IF dIDP > pIngresoMens THEN	
									LET pIngresoMens = dIDP;
								ELSE
									LET pIngresoMens = pIngresoMens;
								END IF
							END IF
							-- OBTIENE FACTOR PARA CAPACIDAD DE PAGO
								SELECT TRIM(valor)
								INTO dFCP
								FROM bdicred:"informix".sd_param
								WHERE cod_param = '003'
								AND empresa = pEmpresa;
								
								IF NVL(dFCP,0.0) = 0.0 THEN
									LET cCodRet = '000007';
									LET cMensajeRet = 'ERROR AL OBTENER EL PARAMETRO DE PORCENTAJE DE FACTOR PARA CAPACIDAD DE PAGO';
									LET cBand1 = '1';
								ELSE	
									LET pIngresoMens = pIngresoMens-dImporte_hip;	
									LET dCMA = (pIngresoMens * dFCP) - dCompromPagoSIC - dCTC-mCompromisosbanco - pOtrosComp;
								END IF
							-- VALIDA QUE SI LA BANDERA ES IGUAL A CERO EL FLUJO SIGUE EL CAMINO FELIZ
							
							IF cBand1 = '0' THEN
								-- VALIDA QUE SI ES MENOR SE RECHAZA  POR CAPACIDAD DE PAGO SATURADA  (RCP)
								IF dCMA < -450 THEN
									LET cCodRet = '000008';
									LET cMensajeRet = 'SE RECHAZA EL CALCULO DE LA LINEA SUGERIDA POR CAPACIDAD DE PAGO SATURADA';
								-- SE OTORGARA INCREMENTO MINIMO DE ACUERDO A LOS TOPES SUGERIDOS
								ELIF (dCMA >= -450) THEN										
									-- SE OBTIENE TASA DE INTERES ANUALIZADA PARA INCREMENTO DE LINEA EN SUCURSAL.
									
									/*SELECT TRIM(valor)
									INTO dTIP
									FROM bdicred:"informix".sd_param
									WHERE cod_param = '006'
									AND empresa = pEmpresa;*/
									
									--Lazalde
									SELECT iva INTO dIvaSuc 
									FROM bdinteg:"informix".si_sucursales WHERE empresa = pEmpresa AND sucursal = cSucursal;

									EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pEmpresa, pNumSolicitud, '') INTO cCodRetTDif, dTasa_Interes, dTasa_Mora;
									IF cCodRetTDif <> '000000' THEN
										LET cCodRet = '000009';
										LET cMensajeRet = 'ERROR AL OBTENER EL PARÁMETRO DE LA TASA DE INTERÉS DEL PERIODO';
									END IF;
									
									LET dTIP = ((dTasa_Interes) + (dTasa_Interes * dIvaSuc))/100;
									
									IF NVL(dTasa_Interes, 0) = 0 THEN
									
										SELECT ((c.valor) +  (c.valor * dIvaSuc))/100
										INTO  dTIP
											  FROM bdicred:"informix".sd_definicion a,
												   bdinteg:"informix".si_fechavalor c
											 WHERE a.empresa = "001"
											   AND a.num_producto = "6001"
											   AND c.empresa = a.empresa
											   AND c.tasa = a.cod_tasa_base
											   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
													   WHERE r.empresa = "001"
														 AND r.tasa = a.cod_tasa_base);
									END IF;
									
									-- VALIDA QUE EXISTA LA TASA DE INTERES ANUALIZADA PARA INCREMENTO DE LINEA
									IF NVL(dTIP,0.0) = 0.0 THEN
										LET cCodRet = '000009';
										LET cMensajeRet = 'ERROR AL OBTENER EL PARÁMETRO DE LA TASA DE INTERÉS DEL PERIODO';									
									ELSE										
										SELECT TRIM(valor)::DECIMAL(18,2)
										INTO dTopeAbono
										FROM bdicred:"informix".sd_param
										WHERE cod_param = '045'
										AND empresa = pEmpresa;
									
										-- OBTIENE LA CAPACIDAD REAL DE ABONO OBTENIENDO EL MENOR DEL 20% DEL INGRESO CONTRA EL LA CAPACIDAD MAXIMA DE ABONO
										IF (pIngresoMens * dTopeAbono) <= dCMA THEN
											LET dCRA = (pIngresoMens * dTopeAbono);
										ELSE
											LET dCRA = dCMA;
										END IF
										-- REALIZA CALCULOS DE LA LINEA SUGERIDA
										LET dLineaSugerida = (dCRA * (1-POW((1+(dTIP/12)),12*-1))) / (dTIP/12);
										-- OBTIENE EL VALOR MINIMO DEL TOPE DE LINEAS
										SELECT  valor_minimo,valor_maximo_cci,valor_maximo_sci
										INTO dPorcTopeValMin,dPorcTopeValMax_cci,dPorcTopeValMax_sci
										FROM bdicred:"informix".sd_topes_suc_aumlincred
										WHERE dMontoOtor BETWEEN linea_actual_valor1 AND linea_actual_valor2;

										LET dLineaMinima = dMontoOtor + (dMontoOtor * dPorcTopeValMin);
										LET dLineaMaxima_cci = dMontoOtor + (dMontoOtor * dPorcTopeValMax_cci);
										LET dLineaMaxima_sci = dMontoOtor + (dMontoOtor * dPorcTopeValMax_sci);
										
										--SE COMPARA LINEA SUGERIDA CONTRA LINEA MAXIMA EXTABLECIDA 
										IF pCompIngreso = '1' THEN
											IF dLineaSugerida >  dLineaMaxima_cci THEN
												LET dLineaSugerida = dLineaMaxima_cci;
											END IF;											
										ELSE
											IF dLineaSugerida >  dLineaMaxima_sci THEN
												LET dLineaSugerida = dLineaMaxima_sci;
											END IF;	
										END IF;
										
										--SE COMPARA LINEA SUGERIDA CONTRA LINEA MINIMA EXTABLECIDA 
										IF dLineaSugerida <  dLineaMinima THEN
											LET dLineaSugerida = dLineaMinima;
										END IF;						
										--SE COMPARA LINEA SUGERIDA CONTRA LO SOLICITADO POR EL CLIENTE
										IF dLineaSugerida > dLineaSolicitada THEN
											LET dLineaSugerida = dLineaSolicitada;
										END IF;
																					
										-- REDONDEA LA LINEA SUGERIDA A CENTENAS
										LET dLineaSugerida = ROUND(dLineaSugerida, - 2);
										-- OBTIENE EL MONTO DEL INCREMENTO DE LA LINEA DE CREDITO
										LET dMontoIncremento = dLineaSugerida - dMontoOtor;
										
										-- OBTIENE EL PORCENTAJE DEL INCREMENTO DE LA LINEA DE CREDITO
										LET dRazonIncremento = (dLineaSugerida / dMontoOtor) - 1;
										IF dLineaSugerida <= dMontoOtor  THEN
											LET dLineaSugerida = 0.0;
											LET dMontoIncremento = 0.0;
											LET dRazonIncremento = 0.0;
											LET cCodRet = '000010';
											LET cMensajeRet = 'LÍNEA SUGERIDA RESULTA MENOR A LA LÍNEA ACTUAL VERIFICAR INGRESO MENSUAL';																		
										END IF
									END IF--dTIP
								END IF--CMA
							END IF--cBand1							
						END IF--Datos
					END IF
				END IF
			END IF
		END IF

		RETURN cCodRet, cMensajeRet, ROUND(dLineaSugerida, - 2), ROUND(dMontoIncremento, - 2), dRazonIncremento, dTIP;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para hacer el recalculo de la linea sugerida para sucursal', 
'AUTOR: Mohamed Carreón ',
'FECHA: Noviembre 2011',
'VERSION: 20111114.1747',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'----------------------------------------------------------------------------------',
'Autor: Guadalupe Payan',
'Modificación: Se obtiene pago_minimo y abonomensual de la sd_bitacora_aumlincred y ya no de la tabla ss_resum_scor_fin como se hacia anteriormente.',
'Fecha de modificación: 05/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agrega el calculo para obtener la tasa de interes anualizada para incremento de linea (dTIP) por sucursal.',
'Fecha de modificación: 08/Febrero/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_genera_saldos_previos_edc(pempresa CHAR(3))
        RETURNING CHAR(5)
		
		
		DEFINE v_ruta      	VARCHAR(255);
        DEFINE cod_ret     	CHAR(5);
        DEFINE sql_err     	INTEGER;
        DEFINE v_sql        CHAR(8000);
        DEFINE v_sql1       CHAR(8000);
        DEFINE v_sql2       CHAR(8000);
        DEFINE v_sql3       CHAR(8000);
        DEFINE v_sql4       CHAR(8000);
        DEFINE v_fecha_hoy	DATE;
        DEFINE iFinDiaAnt   INTEGER;
		DEFINE iFinMesAnt   INTEGER;
		DEFINE iFinAnioAnt  INTEGER;
		DEFINE iMesAct   	INTEGER;
		DEFINE iAnioAct  	INTEGER;
		
		LET v_ruta      = "";
        LET v_sql       = "";
        LET v_sql1      = "";
        LET v_sql2      = "";
        LET v_sql3      = "";
        LET v_sql4      = "";
        LET iFinDiaAnt 	= 0;
		LET iFinMesAnt 	= 0;
		LET iFinAnioAnt = 0;
		LET iMesAct 	= 0;
		LET iAnioAct 	= 0;
		LET v_fecha_hoy = DATE(1);
		
/* 		SET DEBUG FILE TO "/informix/Rebeca/sp_genera_saldos_previos_edc.out";
        TRACE ON; */
		
		BEGIN

			ON EXCEPTION SET sql_err
				LET cod_ret = sql_err;
				RETURN cod_ret;
			END EXCEPTION;
			
			LET cod_ret = "00000";
			SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';
						
			select day(pri_dia_mes-1), month(add_months((pri_dia_mes),-1)) mes_ant, year(add_months((pri_dia_mes),-1)) anio_ant, month(fecha_hoy) mes_act, year(fecha_hoy) anio_act,fecha_hoy 
					into iFinDiaAnt,iFinMesAnt,iFinAnioAnt,iMesAct,iAnioAct,v_fecha_hoy
			from bdicred:sd_fechas; 
			
			LET v_sql1 = 	' echo set isolation to dirty read; ' ||
                            ' echo "UNLOAD TO '||trim(v_ruta)||'SaldosPreviosEdocta'||to_char(v_fecha_hoy,"%m%Y")||'.txt '||
							' select a.num_credito,'||
							'c.capvig21,c.captrans21,c.capvencnoexig21,c.capvenexig21,'||
							'c.capvig22,c.captrans22,c.capvencnoexig22,c.capvenexig22,'||
							'c.capvig23,c.captrans23,c.capvencnoexig23,c.capvenexig23,'||
							'c.capvig24,c.captrans24,c.capvencnoexig24,c.capvenexig24,'||
							'c.capvig25,c.captrans25,c.capvencnoexig25,c.capvenexig25,'||
							'c.capvig26,c.captrans26,c.capvencnoexig26,c.capvenexig26,'||
							'c.capvig27,c.captrans27,c.capvencnoexig27,c.capvenexig27,'||
							'c.capvig28,c.captrans28,c.capvencnoexig28,c.capvenexig28,'||
							'c.capvig29,c.captrans29,c.capvencnoexig29,c.capvenexig29,'||
							'c.capvig30,c.captrans30,c.capvencnoexig30,c.capvenexig30,'||
							'c.capvig29,c.captrans29,c.capvencnoexig29,c.capvenexig29,'||
							'c.capvig30,c.captrans30,c.capvencnoexig30,c.capvenexig30,'||
							'c.capvig31,c.captrans31,c.capvencnoexig31,c.capvenexig31,';
			
			LET v_sql2 =	'b.capvig1,b.captrans1,b.capvencnoexig1,b.capvenexig1,'||
							'b.capvig2,b.captrans2,b.capvencnoexig2,b.capvenexig2,'||
							'b.capvig3,b.captrans3,b.capvencnoexig3,b.capvenexig3,'||
							'b.capvig4,b.captrans4,b.capvencnoexig4,b.capvenexig4,'||
							'b.capvig5,b.captrans5,b.capvencnoexig5,b.capvenexig5,'||
							'b.capvig6,b.captrans6,b.capvencnoexig6,b.capvenexig6,'||
							'b.capvig7,b.captrans7,b.capvencnoexig7,b.capvenexig7,'||
							'b.capvig8,b.captrans8,b.capvencnoexig8,b.capvenexig8,'||
							'b.capvig9,b.captrans9,b.capvencnoexig9,b.capvenexig9,'||
							'b.capvig10,b.captrans10,b.capvencnoexig10,b.capvenexig10,'||
							'b.capvig11,b.captrans11,b.capvencnoexig11,b.capvenexig11,'||
							'b.capvig12,b.captrans12,b.capvencnoexig12,b.capvenexig12,'||
							'b.capvig13,b.captrans13,b.capvencnoexig13,b.capvenexig13,'||
							'b.capvig14,b.captrans14,b.capvencnoexig14,b.capvenexig14,'||
							'b.capvig15,b.captrans15,b.capvencnoexig15,b.capvenexig15,'||
							'b.capvig16,b.captrans16,b.capvencnoexig16,b.capvenexig16,'||
							'b.capvig17,b.captrans17,b.capvencnoexig17,b.capvenexig17,'||
							'b.capvig18,b.captrans18,b.capvencnoexig18,b.capvenexig18,'||
							'b.capvig19,b.captrans19,b.capvencnoexig19,b.capvenexig19,'||
							'b.capvig20,b.captrans20,b.capvencnoexig20,b.capvenexig20, a.tasa_interes '||
							'from bdicred:sd_maecred a ';
			LET v_sql3 = 	'join bdicred:sd_sdodiario b on (b.fecha=mdy('||iMesAct||',01,'||iAnioAct||') and  a.num_credito = b.num_credito) ' ||
							'join bdicred:sd_sdodiario c on (c.fecha=mdy('||iFinMesAnt||',01,'||iFinAnioAnt||') and  a.num_credito = c.num_credito) ' ||
							'where a.empresa = '''||pempresa||''' ' ||
							'and a.status_cred not in (''CV'') ' ||
							'and fecha_apertura <= mdy('|| month(v_fecha_hoy)||','||day(v_fecha_hoy)||','||year(v_fecha_hoy)||') ' ||
							'and a.sucursal = ''0002''" > queryNEC.sql';
			
			LET v_sql = trim(v_sql1)||trim(v_sql2)||' '||trim(v_sql3);
			SYSTEM v_sql;

			LET v_sql = "dbaccess bdicred queryNEC.sql";
			SYSTEM v_sql;
			
			LET v_sql = '';
			LET v_sql = 'rm queryNEC.sql ';
			SYSTEM v_sql;
			
		END;
	RETURN cod_ret;
END PROCEDURE;