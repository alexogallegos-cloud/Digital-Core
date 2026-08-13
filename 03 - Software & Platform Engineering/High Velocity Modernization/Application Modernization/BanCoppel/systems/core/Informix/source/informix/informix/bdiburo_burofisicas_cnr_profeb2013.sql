create procedure "informix".burofisicas_cnr_profeb2013()
       returning char(5),
                 char(50);

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
--   LET dtFechaCierre  = date(1);
   LET dtFechaCierre  = null;

BEGIN

       ON EXCEPTION SET iSqlErr
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
              RETURN vcodret,vnum_credito;
           END IF;
        END EXCEPTION;


   LET vsegmento4_tr           = '';
   LET tb_nombre_otorg         = '';
   LET tb_domicilio_dev        = '';

   LET iCP                     = 0;

--SET DEBUG FILE TO "burofisicascnr.out";
--TRACE ON; 

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
      where cod_param = 128;

   let vinf_adicional = "&";

   select pri_dia_mes - 1
      into vfecha_hoy
      from bdicred:sd_fechas
     where empresa = '001';

--temporal para pruebas unicamente
let vfecha_hoy = mdy('02','28','2013');
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
when  d_estado= 'DISTRITO FEDERAL'then 'DF'
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

   let vano = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vano;


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
/*
   IF  (select count(*) from sysindices where idxname='inxburofisicas' and owner='informix' and tabid>0) > 0 THEN
        DROP INDEX "informix".inxburofisicas; 
    END IF;
*/
   IF  (select count(*) from bdiburo:br_burofisicas_cnr where numreg = 1 and  substr(registro,35,8) matches vfecha_reporte) = 0 THEN
        truncate table "informix".br_burofisicas_describe_cnr;
        truncate table "informix".br_burofisicas_cnr;
        truncate table "informix".br_burofisicas_concilia_cnr;
        DROP INDEX "informix".idx_br_burofisicas_cnr; 
        DROP INDEX "informix".idx_br_burofisicas_describe_cnr;
        DROP INDEX "informix".inxburoconcilia_cnr;
--- Genera registro encabezado para Círculo
       let vheader = vencabezado1||vversion||vclave_usu||vnombre_usu||vciclo||vfecha_reporte||vuso_futuro||rpad(trim(vinf_adicional),98,"&");
       insert into br_burofisicas_cnr
          values(vnumreg,vheader);    
    END IF;

UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_cnr;
UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_describe_cnr;
UPDATE STATISTICS medium for table "informix".br_burofisicas_concilia_cnr;

--    let vfecha_hoy_ant = mdy(month(vfecha_hoy),1,year(vfecha_hoy)) - 1; 

--Se crea tabla temporal con los créditos a procesar
      SELECT a.numcte, a.num_producto, a.credito_externo,a.num_credito,NVL(a.status_cred,"AA") status_cred, b.monto_otorgado, b.fecha_ult_mov, 
                        a.fecha_apertura, a.plazo,a.periodo_plazo,case when a.num_producto = '6300' then 'PL' else 'PN' end tipo_contrato
--        FROM bdicred:sd_maecredcrd a
        FROM bdicred:sd_maecredcontcrd a
        LEFT OUTER JOIN bdicred:sd_maesdoscontcrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito and b.fecha = vfecha_hoy
       WHERE a.fecha = vfecha_hoy
and a.empresa = "001"
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr)
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
         AND a.num_producto <> '6011'
         AND a.fecha_apertura <= vfecha_hoy
and a.num_producto = '6300'
UNION ALL
      SELECT a.numcte, a.num_producto, a.credito_externo,a.num_credito,NVL(a.status_cred,"AA") status_cred, b.monto_otorgado, b.fecha_ult_mov, 
                        a.fecha_apertura, a.plazo,a.periodo_plazo,case when a.num_producto = '6300' then 'PL' else 'PN' end tipo_contrato
        FROM bdicred:sd_maecredcrd a
        LEFT OUTER JOIN bdicred:sd_maesdoscrd b on b.empresa=a.empresa and b.num_credito=a.num_credito
       WHERE a.empresa = "001"
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr)
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
         AND a.num_producto <> '6011'
         AND a.fecha_apertura <= vfecha_hoy
AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_maecredcontcrd where fecha = vfecha_hoy and empresa = '001')
and a.num_producto = '6300'

/*      SELECT a.numcte, a.num_producto, a.credito_externo,a.num_credito,NVL(c.status_cred,"AA") status_cred, b.monto_otorgado, b.fecha_ult_mov, 
                        a.fecha_apertura, a.plazo,a.periodo_plazo,case when a.num_producto = '6300' then 'PL' else 'PN' end tipo_contrato
--        FROM bdicred:sd_maecredcrd a
        FROM bdicred:sd_maecredcontcrd a
        LEFT OUTER JOIN bdicred:sd_maesdoscontcrd b ON b.empresa = a.empresa AND b.num_credito = a.num_credito and b.fecha = mdy(month(vfecha_hoy),1,year(vfecha_hoy)) - 1
        inner join bdicred:sd_maecredcrd c ON c.empresa = a.empresa AND c.num_credito = a.num_credito 
       WHERE a.fecha = mdy(month(vfecha_hoy),1,year(vfecha_hoy)) - 1
and a.empresa = "001"
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_describe_cnr)
         AND a.num_credito NOT IN (SELECT num_credito FROM bdiburo:br_burofisicas_concilia_cnr)
         AND a.num_producto <> '6011'
         AND a.fecha_apertura <= vfecha_hoy
AND a.num_credito NOT IN (SELECT num_credito FROM bdicred:sd_maecredcontcrd where fecha = vfecha_hoy and empresa = '001')
and a.num_producto = '6300'
*/
    INTO temp creditos WITH NO LOG;


CREATE INDEX idx_creditos ON creditos(status_cred,num_credito,credito_externo,num_producto,numcte);

update statistics medium for table creditos;

   IF  (select count(*) from bdiburo:br_burofisicas_cnr) = 1 THEN
       select count(*)::integer into iTotalProcesados from creditos;
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
    group by 1
    into temp cred_movhis with no log;
    create unique index inx_cred_movhis on cred_movhis(num_credito);
    update statistics medium for table cred_movhis;
-- se crea temporal para pago maximo

  foreach with hold
      SELECT numcte, num_producto, credito_externo, num_credito,NVL(status_cred,"AA") status_cred, monto_otorgado, fecha_ult_mov, fecha_apertura, plazo, periodo_plazo, tipo_contrato
         into vnumcte,cNumProducto, cCredExterno,vnum_credito,vstatus_cred, vmonto_otorgado,vfecha_finiq,vpago_int,vnum_pagos,vfrecpago,tb_tipo_producto
         from creditos 

    LET cNumCredito = vnum_credito;

        if vfecha_finiq <= vfecha_ini then
               INSERT INTO bdiburo:br_burofisicas_concilia_cnr (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CNP',vfecha_hoy);
           continue foreach;
        end if

         select 
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(apell_paterno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(apell_materno),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(nombre1),""),'1','L'),'0','O'),'5','S'),'8','B'),
             REPLACE(REPLACE(REPLACE(REPLACE(nvl(trim(nombre2),""),'1','L'),'0','O'),'5','S'),'8','B'),
             fecha_nac,trim(rfc),nvl(fecha_alta,""),nvl(nacionalidad,"01"),nvl(residencia,"MX"),
             nvl(estado_civil," "),nvl(sexo,"I")
         into vapell_paterno,vapell_materno,vnombre1,vnombre2,vfecha_nac,vrfc,vfecha_alta,vnacionalidad,vresidencia,
             vestado_civil,vsexo
             from bdinteg:si_cliente a,bdinteg:si_ctepf b
             where a.numcte=b.numcte
             and a.numcte=vnumcte;

    IF (sCommit = 0) THEN
       BEGIN WORK;
       LET contador_commit = 0;
       LET sCommit = -1;
    END IF; 

     if vfecha_nac is null then let vrfc = "";  end if;

-- Venta de cartera ini
-- Solo se reporta el mes de la venta
     if (vstatus_cred = "CV") then
        let vfecha_venta = null;

        select b.fecha,fecha_apertura,dia_cuota,
                monto_otorgado,0,nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0)
          into vfecha_venta,vfecha_apertura,vdiacuota,
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
               INSERT INTO bdiburo:br_burofisicas_concilia_cnr (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CNP',vfecha_hoy);
               continue foreach;
           end if;
     end if;

-- Venta de cartera ini
     let yaexiste = 0;
     LET vsegmento_pn = "";
     LET vsegmento2_pa = "";
     LET vsegmento3_tl = "";

    if vstatus_cred not in ("CV","FF") then
         select d.maneja_linea,
                fecha_apertura,e.dia_corte --,mto_fin_ven_trasp::smallint mto_fin_ven_trasp--agregar meses vencidos
           into vtp_linea,
                vfecha_apertura,vdiacuota
            from bdicred:sd_maecredcrd b, bdicred:sd_maesdoscontcrd c,
--            from bdicred:sd_maecredcontcrd b, bdicred:sd_maesdoscontcrd c,
                bdicred:sd_maecredanexocrd e,
                 outer bdicred:sd_definicion d
            where --b.fecha = vfecha_hoy
                b.empresa = '001'
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
     if vapell_materno is not null then
        let vsegmento1_pn = trim(vsegmento1_pn)||'00'||
                            lpad(length(trim(vapell_materno)),2,"0")||trim(vapell_materno);
                            
        let tb_apell_materno = trim(vapell_materno);
     else
        let vsegmento1_pn = trim(vsegmento1_pn)||'0016NO PROPORCIONADO';
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

     SELECT Trim(f.nombrecalle)||' '||Trim(a.numeroextcalle)||' '||
	    Trim(a.numerointcalle),
            Trim(g.nombrezona),Trim(g.municipiozona), Trim(c.estado),
            a.cod_postal,manzana,andador,lote,edificio,entrada,codini,codfin,
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

-- Agrega Direccion
     let vsegmento2_pa = lpad(length(trim(vcalle)),2,"0")||vcalle;
     let tb_calle         = vcalle;

-- Agrega Colonia
     if vcolonia is not null then
        let vsegmento2_pa = trim(vsegmento2_pa)||'01'||
                            lpad(length(trim(vcolonia)),2,"0")||vcolonia;
        let tb_colonia       = vcolonia;
     end if;

-- Agrega Delegacion o Municipío
     if vdelegacion is null or vdelegacion = "" then
        LET vdelegacion = 'CONOCIDO';
     end if

        let vsegmento2_pa = trim(vsegmento2_pa)||'02'||
                               lpad(length(trim(vdelegacion)),2,"0")||vdelegacion;
        let tb_delegacion     = vdelegacion;

-- Agrega Ciudad
     if vciudad != "" then
       let vsegmento2_pa = trim(vsegmento2_pa)||'03'||
                           lpad(length(trim(vciudad)),2,"0")||vciudad;
       let tb_ciudad        = vciudad;
     end if

-- Agrega Estado
     let vsegmento2_pa = trim(vsegmento2_pa)||'04'||
     lpad(length(trim(vestado)),2,"0")||trim(vestado);
     let tb_estado        = trim(vestado);

-- Agrega Codigo Postal
     let vsegmento2_pa = trim(vsegmento2_pa)||'05'||
     lpad(length(trim(vcod_postal)),2,"0")||trim(vcod_postal);
     let tb_cod_postal    = trim(vcod_postal);

     let vsegmento2_pa = 'PA'||trim(vsegmento2_pa);

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
        let tb_tipo_cuenta       = "I";
        let vsegmento3_tl = trim(vsegmento3_tl)||tb_tipo_cuenta||'0702'||tb_tipo_producto;

--Agregar Clave Monetaria
  -- MX = Pesos
  -- US = Dolares
  -- UD = Unidades de Inversion
     let vsigla_div = "MX";
     let vsegmento3_tl = trim(vsegmento3_tl)||'0802MX';
     let tb_clave_monetaria   = "MX";

-- Agregar Numero de Pagos
     let vsegmento3_tl = trim(vsegmento3_tl)||'10'||
     lpad(length(vnum_pagos),2,"0")||trim(vnum_pagos);
     let tb_num_pagos         = trim(vnum_pagos);

-- Agregar Fecuencia de Pagos
   -- M = Mensual
     let vsegmento3_tl = trim(vsegmento3_tl)||'1101'||vfrecpago;
     let tb_frecpago          = vfrecpago;

-- Agregar Monto a Pagar 
-- Se adelanta la obtención de saldos
     let vsaldo_actual = 0;
     let v_interes = 0;

-- Venta de Cartera ini
     if vstatus_cred not in ('CV') then
             select nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0),
                    nvl(monto_vencido + mto_venc_trasp,0), nvl(sdo_no_exig,0)
               into vsaldo_vig, vsaldo_venc, v_interes
               from bdicred:sd_maesdoscontcrd 
              where fecha = vfecha_hoy
                and empresa = "001"
                and num_credito = vnum_credito;

        if vsaldo_vig is null then let vsaldo_vig = 0; end if; 
        if vsaldo_venc is null then let vsaldo_venc = 0; end if; 
        if v_interes is null then let v_interes = 0; end if; 

        if ( v_interes is null or v_interes <= 0 ) then
           let v_interes = 0;
        end if;
            
     end if;

     select limit 1 capital_mto_cuota into vcuota_cap
       from bdicred:sd_amortiza_creditocrd
      where empresa = "001"  and num_credito = vnum_credito
        and fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd
                  where empresa = "001"  and num_credito = vnum_credito and fecha_cuota <= vfecha_hoy) and fecha_cuota <= vfecha_hoy;

-- Se agregan exepciones de pago y saldo
     let vsaldo_vig = vsaldo_vig + v_interes;
     let vrea_cal_cuota = 0;

     if round(vcuota_cap,0) = 0 then let vcuota_cap = round(vsaldo_vig,0); end if;

     if vcuota_cap > 0 and vstatus_cred != 'FF' then
       let vmonto = round(vcuota_cap,0);
     else
      let vmonto = 0;
     end if
--el monto a pagar no puede ser mayor al saldo actual
     if vmonto > vsaldo_vig then let vmonto = vsaldo_vig; end if;

     let vsegmento3_tl = trim(vsegmento3_tl)||'1209'||
                         lpad(round(vmonto,0),9,"0");
     let tb_monto_pagar       = round(vmonto,0);

-- Agregar Fecha de Apertura de la Cuenta
     let vano = year(vfecha_apertura);
     let vmes = lpad(month(vfecha_apertura),2,"0");
     let vdia = lpad(day(vfecha_apertura),2,"0");
     let vsegmento3_tl = trim(vsegmento3_tl)||'1308'||vdia||vmes||vano;
     let tb_fecha_apertura    = vdia||vmes||vano;

  -- Obtencion de la ultima fecha de pago
     let vpago_cap = "";

 -- Obtencion de la ultima fecha de pago

----validar pagos para pp y credinómina
/*        select max(fecha_mov) 
            into vpago_cap
            from bdicred:sd_movhiscrd
            where empresa = "001" 
            and num_credito = vnum_credito
            and codigo_fun in ('021','023','027','028')
            and codigo_ref = 1
            and fecha_mov > date(0)
            and fecha_mov <= vfecha_hoy 
            and reversado = 'N';*/

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
     let vano = year(vpago_cap);
     let vmes = lpad(month(vpago_cap),2,"0");
     let vdia = lpad(day(vpago_cap),2,"0");

     let vsegmento3_tl = trim(vsegmento3_tl)||'1408'||vdia||vmes||vano;
     let tb_fecha_ult_pago    = vdia||vmes||vano;

-- Agregar Fecha de Ultima Compra
     let vano = year(vpago_int);
     let vmes = lpad(month(vpago_int),2,"0");
     let vdia = lpad(day(vpago_int),2,"0");

     let vsegmento3_tl = trim(vsegmento3_tl)||'1508'||vdia||vmes||vano;
     let tb_fecha_ult_compra  = vdia||vmes||vano;

     let tb_fecha_cierre = '';
-- Venta de cartera ini
        if (vstatus_cred = "CV") then
            let vano = year(vfecha_venta);
            let vmes = lpad(month(vfecha_venta),2,"0");
            let vdia = lpad(day(vfecha_venta),2,"0");
            let vsegmento3_tl = trim(vsegmento3_tl)||'1608'||vdia||vmes||vano;
            let dtFechaCierre      = vfecha_venta;
            let tb_fecha_cierre      = vdia||vmes||vano;
        ELIF vstatus_cred = "FF"  THEN
            select fecha_ult_pago into dtFechaLiquidacion
            from bdicred:sd_maecredanexocrd 
            where empresa='001' and num_credito=vnum_credito;

            LET vano = YEAR(dtFechaLiquidacion);
            LET vmes = LPAD(MONTH(dtFechaLiquidacion),2,"0");
            LET vdia = LPAD(DAY(dtFechaLiquidacion),2,"0");
            LET vsegmento3_tl = TRIM(vsegmento3_tl)||'1608'||vdia||vmes||vano;
            let dtFechaCierre      = dtFechaLiquidacion;
            LET tb_fecha_cierre = vdia||vmes||vano;
        END IF;

     if (dtFechaCierre < vfecha_ini) or (dtFechaCierre > vfecha_hoy) then
        INSERT INTO bdiburo:br_burofisicas_concilia_cnr (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CNP',vfecha_hoy);
        continue foreach;
     end if;

-- Agregar Fecha Reporte
     let vsegmento3_tl = trim(vsegmento3_tl)||'1708'||vfecha_reporte;
     let tb_fecha_reporte     = vfecha_reporte;

     if (vsaldo_venc is null) or (vsaldo_venc < 0) then let vsaldo_venc = 0; end if

     let vsaldo_actual = vsaldo_vig;
     let vdiasvenc = 0;
     if vstatus_cred = "FF" or (vmonto = 0 and vstatus_cred <> "CV") then
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

     let vsegmento3_tl = trim(vsegmento3_tl)||'2309'||
                         lpad(round(vmonto_otorgado,0),9,"0");
     let tb_monto_otorgado    = round(vmonto_otorgado,0);

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
          and capital_status in (2,7);
    elif vstatus_cred = "FF" then
        let vcuotas_ven = 0;
    else 
      let vcuotas_ven = 0;

      SELECT mto_fin_ven_trasp::smallint mto_fin_ven_trasp 
        INTO vcuotas_ven
       FROM bdicred:sd_maecredcrd b, bdicred:sd_maesdoscontcrd c,
--       FROM bdicred:sd_maecredcontcrd b, bdicred:sd_maesdoscontcrd c,
      OUTER bdicred:sd_definicioncrd d, bdicred:sd_maecredanexocrd e
      WHERE --b.fecha = vfecha_hoy
            b.empresa = '001'
        AND b.empresa = c.empresa
        AND b.num_credito = c.num_credito
        AND c.fecha = vfecha_hoy
        AND d.num_producto = b.num_producto
        AND b.empresa = d.empresa
AND e.empresa = b.empresa
        AND b.num_credito=e.num_credito
        AND b.num_credito = vnum_credito;
    end if;

-- Cartera vendida fin
   if vcuotas_ven is null then let vcuotas_ven = 0; end if;

---Modificar de acuerdo a circulo
   if vfecha_apertura > vfecha_ini then
        if cNumProducto = '6011' then
          let vmop = "01";
        else
          let vmop = "00";
        end if;
   elif (vmonto = 0 and vstatus_cred <> 'CV') then
      let vmop = "01";
      let vsaldo_venc = 0;
   elif (vcuotas_ven = 0) then
      let vmop = "01";
      let vsaldo_venc = 0;
   elif vcuotas_ven = 1 then
      let vmop = "02";
   elif vcuotas_ven = 2 then
      let vmop = "03";
   elif vcuotas_ven = 3 then
      let vmop = "04";
   elif vcuotas_ven = 4 then
      let vmop = "05";
   elif vcuotas_ven = 5 then
      let vmop = "06";
   elif (vcuotas_ven >= 6) and (vcuotas_ven <= 12)  then
      let vmop = "07";
   elif vcuotas_ven > 12 then
      let vmop = "96";
   end if

-- Agregar Saldo vencido
     if vsaldo_venc > 0 and vsaldo_venc < 1 then
        let vsaldo_venc=1;
     end if;

   let vsegmento3_tl = trim(vsegmento3_tl)||'2409'||
                         lpad(round(vsaldo_venc,0),9,"0");
   let tb_saldo_venc        = round(vsaldo_venc,0);

-- Agregar Numero de Pagos Vencidos
   if vsaldo_venc > 0 then
       let vsegmento3_tl = trim(vsegmento3_tl)||'2504'||
                         lpad(vcuotas_ven,4,"0");
       let tb_cuotas_ven        = vcuotas_ven;
   end if

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
   
   let vsegmento3_tl = trim(vsegmento3_tl)||'2602'||vmop;
   let tb_mop               = vmop;

-- Venta de Cartera ini
    if (vstatus_cred = 'CV') then
        let vsegmento3_tl = trim(vsegmento3_tl)||'3002'||'CV';
        let tb_clave_obs               = 'CV';
    elif vstatus_cred = "FF" then
           LET vsegmento3_tl = TRIM(vsegmento3_tl)||'3002'||'CC';
           LET tb_clave_obs               = 'CC';
    end if;

-- Agergar clave de observación
-- Venta de Cartera Fin
   let vsegmento3_tl = trim(vsegmento3_tl)||'9903FIN';
   let vsegmento3_tl = 'TL'||trim(vsegmento3_tl);

     if trim(vsegmento_pn) != "PN" and trim(vsegmento2_pa) != "PA" and trim(vsegmento3_tl) != "TL" then
--Se validan CPs para la cinta de Buró
		--SELECT count(*) INTO iCP --GEV
          --FROM sepomex WHERE d_codigo = tb_cod_postal AND substr(d_mnpio,1,27) = tb_delegacion AND estado_abrev = tb_estado;  

        IF iCP IS NULL THEN LET iCP = 0; END IF;

        IF iCP > 0 THEN
           let vsegmento3_tl = replace(vsegmento3_tl,'TGD0924BAN',vclave_usu_bc);
        ELSE
                INSERT INTO bdiburo:br_burofisicas_concilia_cnr VALUES('001',cNumProducto,vnum_credito,'CPS',vfecha_hoy,
                       tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
                       tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
                       tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar,
                       tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado,
                       tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota);
        END IF;

            let vnumreg = vnumreg + 1;
            insert into br_burofisicas_cnr
            values(vnumreg,vsegmento_pn);

            let vnumreg = vnumreg + 1;
            insert into br_burofisicas_cnr
            values(vnumreg,vsegmento2_pa);

            let vnumreg = vnumreg + 1;
            insert into br_burofisicas_cnr
            values(vnumreg,vsegmento3_tl);

-- Se agrega tabla para grabar informacion enviada
            insert into br_burofisicas_describe_cnr
               values (tb_num_credito, tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
                       tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
                       tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar,
                       tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado,
                       tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota);

            let contador_commit = contador_commit  + 1;
            let actualiza_esta = actualiza_esta + 1;
     else
            INSERT INTO bdiburo:br_burofisicas_concilia_cnr (empresa, num_producto, num_credito, motivo, fecha_cinta) VALUES('001',cNumProducto,vnum_credito,'CNP',vfecha_hoy);
     end if;

    let cNumProducto = '';
    let cCredExterno = '';
    let vmonto_otorgado=0; 
    let vsaldo_vig = 0; 
    let vsaldo_venc=0;
LET dtFechaCierre  = null;

   IF (contador_commit >= 2000) THEN
      COMMIT WORK;
/*
      if actualiza_esta<500000 and mod(actualiza_esta,30000)=0 then
         UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_cnr;
         UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_burofisicas_describe_cnr;
         UPDATE STATISTICS medium for table "informix".br_burofisicas_concilia_cnr;
      end if;
*/
      LET contador_commit = 0; 
      BEGIN WORK;
   END IF;

  end foreach

  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;

  LET sCommit = 0;
  LET cNumCredito = 'Inicia proc. conciliación';

  SET LOCK MODE TO WAIT 3;
  BEGIN;
  CREATE INDEX "informix".idx_br_burofisicas_cnr          ON "informix".br_burofisicas_cnr(numreg) ONLINE;
  COMMIT;
  BEGIN;
  CREATE INDEX "informix".idx_br_burofisicas_describe_cnr ON "informix".br_burofisicas_describe_cnr(num_credito) ONLINE;
  COMMIT;
  BEGIN;
  CREATE INDEX "informix".inxburoconcilia_cnr             ON "informix".br_burofisicas_concilia_cnr(empresa, num_producto, num_credito, motivo, fecha_cinta) ONLINE;
  COMMIT;

  update statistics medium for table "informix".br_burofisicas_cnr;
  update statistics medium for table "informix".br_burofisicas_describe_cnr;
  update statistics medium for table "informix".br_burofisicas_concilia_cnr;

  EXECUTE PROCEDURE burofisicas_concilia_cnr(vfecha_reporte) INTO vcodret;

  drop table sepomex;
  drop table creditos;

  let cMensajeFin = 'Créditos procs. ' || iTotalProcesados;
  return vcodret,cMensajeFin;
END;
end procedure;