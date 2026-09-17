create procedure "informix".burofisicas_fecha(fechaproceso date, fechacorteproceso date)
       returning char(5);

   define vcodret        char(5);
   define vcodret2       char(5);

   define vfecha_hoy     date;
--jom ini
   define vfecha_corte      date;
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
   define vsegmento4     char(436);
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
          vsaldo_actual,vmonto_pago decimal(18,2);
   define vfecha_cap, vfecha_int, vfecha_venc, vfecha_pricuo,vfechacuota date;
   define vdiasvenc smallint;
   define vmop char(2);
   define vnumreg integer;
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
   define contador_stat INTEGER;


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

-- Venta de cartera ini
   define vfecha_venta         date;

   let vcodret = "000";
   let vsql = "";

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

   let vinf_adicional = "&";

  drop table "informix".br_burofisicas;

  create table "informix".br_burofisicas
    (
      numreg integer,
      registro char(500)
    )  extent size 32 next size 32 lock mode row;
  
--    alter table br_burofisicas type (RAW);


-- Borra tabla de descripciones

drop table "informix".br_burofisicas_describe;

CREATE TABLE "informix".br_burofisicas_describe ( 
    num_credito     	CHAR(25),
    apell_paterno   	CHAR(26),
    apell_materno   	CHAR(26),
    nombre1         	CHAR(26),
    nombre2         	CHAR(26),
    fecha_nac       	CHAR(8),
    rfc             	CHAR(13),
    nacionalidad    	CHAR(3),
    estado_civil    	CHAR(1),
    sexo            	CHAR(1),
    calle           	CHAR(40),
    colonia         	CHAR(40),
    delegacion      	CHAR(40),
    ciudad          	CHAR(40),
    estado          	CHAR(4),
    cod_postal      	CHAR(10),
    clave_usu       	CHAR(10),
    nombre_usu      	CHAR(16),
    responsabilidad 	CHAR(1),
    tipo_cuenta     	CHAR(1),
    tipo_producto   	CHAR(2),
    clave_monetaria 	CHAR(2),
    num_pagos       	CHAR(5),
    frecpago        	CHAR(1),
    monto_pagar     	DECIMAL(18,0),
    fecha_apertura  	CHAR(8),
    fecha_ult_pago  	CHAR(8),
    fecha_ult_compra	CHAR(8),
    fecha_cierre    	CHAR(8),
    fecha_reporte   	CHAR(8),
    credito_maximo  	DECIMAL(18,2),
    saldo_actual    	DECIMAL(18,2),
    monto_otorgado  	DECIMAL(18,2),
    saldo_venc      	DECIMAL(18,2),
    cuotas_ven      	SMALLINT,
    mop             	CHAR(2),
    clave_obs         	CHAR(2),
    int_calculo     	INTEGER 
    ) extent size 32 next size 32 lock mode row;

--   alter table br_burofisicas_describe type (RAW);

--   select pri_dia_mes - 1, 
--          date(to_date(LPAD(year(pri_dia_mes - 1),4,0)||LPAD(month(pri_dia_mes - 1),2,0)||day(20),"%Y%m%d"))
--      into vfecha_hoy, vfecha_corte
--      from bdinteg:si_fechas;

   let vfecha_hoy   = fechaproceso;
   let vfecha_corte = fechacorteproceso;

   let vfecha_ini = mdy(month(vfecha_hoy),1,year(vfecha_hoy));

   let vano = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vano;

   --- Genera registro encabezado
   let vheader = vencabezado1||vversion||vclave_usu||vnombre_usu||
                 vciclo||vfecha_reporte||vuso_futuro||
                 rpad(trim(vinf_adicional),98,"&");
   let vlongitud = 0;
   let vnumreg = 1;
   let vreg_proc = 0;
   let vtot_proc = 0;
   let contador_commit = -1;
   let contador_stat = 0;

   insert into br_burofisicas
      values(vnumreg,vheader);

--   call sp_fechas_archivo("burofisicas_hora","Inicio") returning vcodret2;

--  Crea tablas temporales ini
    set isolation dirty read;
    set lock mode to wait 03;
    ---set pdqpriority 5;

    select num_credito, max(fecha_mov) fecha_mov
        from bdicred:sd_movhis
        where empresa = "001" 
        and fecha_mov > date(0)
        and fecha_mov <= vfecha_hoy
        and num_credito > ''
        and reversado = 'N'
        and codigo_fun in ('033', '334')
        and codigo_ref = 1
    group by 1 into temp mov033 with no log;

    CREATE unique INDEX inxmov033 ON mov033(num_credito);
    update statistics high for table mov033(num_credito);

--    call sp_fechas_archivo("burofisicas_hora","Mov033") returning vcodret2;

     select num_credito, max(fecha_mov) fecha_mov
        from bdicred:sd_movhis
        where empresa = "001" 
        and fecha_mov > date(0)
        and fecha_mov <= vfecha_hoy
        and num_credito > ''
        and reversado = 'N'
        and codigo_fun = '002'
        and codigo_ref in (30,37,50)
      group by 1 into temp mov002 with no log;

      CREATE unique INDEX inxmov002 ON mov002(num_credito);
      update statistics high for table mov002(num_credito);

--    call sp_fechas_archivo("burofisicas_hora","mov002") returning vcodret2;

     select b.num_credito,d.maneja_linea,b.divisa,b.period_pag_int,
            fecha_apertura,b.numcte,monto_otorgado,dia_cuota
        from bdicred:sd_maecred b, bdicred:sd_maesdoscont c,
             outer bdicred:sd_definicion d
        where b.empresa = c.empresa
          and b.num_credito = c.num_credito
          and c.fecha = vfecha_hoy
          and d.num_producto = b.num_producto
          and b.empresa = d.empresa into temp crenocv with no log;

       CREATE unique INDEX inxcrenocv ON crenocv(num_credito);
       update statistics high for table crenocv(num_credito);

--       call sp_fechas_archivo("burofisicas_hora","crenocv") returning vcodret2;

     select b.num_credito,d.maneja_linea,b.divisa,b.period_pag_int,
            fecha_apertura,b.numcte,monto_otorgado,dia_cuota
        from bdicred:sd_maecred_vendida b, bdicred:sd_maesdos_vendida c,
             outer bdicred:sd_definicion d
        where b.empresa = c.empresa
          and b.num_credito = c.num_credito
          and d.num_producto = b.num_producto
          and b.empresa = d.empresa into temp crecv with no log;

       CREATE unique INDEX inxcrecv ON crecv(num_credito);
        update statistics high for table crecv(num_credito);

--        call sp_fechas_archivo("burofisicas_hora","crecv") returning vcodret2;

--        select num_credito, count(*) cuotas
--         from bdicred:sd_amortiza_credito b
--        where empresa = '001'
--          and b.capital_status in (2,7)
--          and fecha_cuota >= date(0) 
--          group by num_credito into temp amortiza;
      
        select num_credito, num_periodos cuotas 
         from bdicred:sd_histvalcon 
         where empresa = '001' 
           and num_credito > '' 
           and fecha_alta = vfecha_hoy
          into temp amortiza with no log;


       CREATE unique INDEX inxamortiza ON amortiza(num_credito);
        update statistics high for table amortiza(num_credito);

--        call sp_fechas_archivo("burofisicas_hora","amortiza") returning vcodret2;

        select num_credito, nvl(max(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci),0) monto
         from bdicred:sd_maesdoscont
         where empresa = '001'
           and fecha <= vfecha_hoy
         group by num_credito
         union all
        select num_credito, nvl(max(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci),0) monto
          from bdicred:sd_maesdoshist
         where empresa = '001'
           and fecha <= vfecha_hoy
        group by num_credito into temp maximo with no log;

       CREATE INDEX inxmaximo ON maximo(num_credito);
        update statistics high for table maximo(num_credito);

--        call sp_fechas_archivo("burofisicas_hora","maximo") returning vcodret2;

--SET DEBUG FILE TO "burofisicas.out";
--TRACE ON; 

   foreach with hold
      select 
             a.numcte,trim(apell_paterno),trim(apell_materno),
             trim(nombre1),trim(nombre2),fecha_nac,trim(rfc),
             fecha_alta,nacionalidad,residencia,estado_civil,sexo,
             num_credito,status_cred
         into vnumcte,vapell_paterno,vapell_materno,vnombre1,
             vnombre2,vfecha_nac,vrfc,vfecha_alta,vnacionalidad,vresidencia,
             vestado_civil,vsexo,vnum_credito,vstatus_cred
         from bdinteg:si_cliente a,bdinteg:si_ctepf b, bdicred:sd_maecred c
         where a.numcte = b.numcte 
         and c.empresa = "001"
         and a.numcte = c.numcte
--         and c.num_credito = '600000005592'
         and c.fecha_apertura <= vfecha_hoy -- esto es precisamente para reportar unicamente creditos aperturados en el mes anterior
--         order by a.numcte, num_credito -- jom
         order by num_credito -- jom

         if (contador_commit = -1) then
            begin work;
            let contador_commit = 0;
         end if; 

-- Venta de cartera ini
-- Solo se reporta el mes de la venta

        if (contador_commit >= 10000) then
           commit work;
           if (contador_stat >= 25000) then
                update statistics medium for table "informix".br_burofisicas;
                update statistics medium for table "informix".br_burofisicas_describe;
                let contador_stat = 0;
           end if;
           let contador_commit = 1;
           begin work;
        end if;

     if (vstatus_cred = "CV") then
        let vfecha_venta = null;
        select fecha into vfecha_venta
          from bdicred:sd_maecred_vendida
         where fecha >= vfecha_ini
           and empresa = '001'
           and num_credito = vnum_credito;

           if (vfecha_venta is null) then
                continue foreach;
           end if;
     end if;
-- Venta de cartera ini


     let yaexiste = 0;
     LET vsegmento_pn = "";
     LET vsegmento2_pa = "";
     LET vsegmento3_tl = "";

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

     let vrea_cal_cuota = 0;

     if vapell_paterno is null then let vapell_paterno = ""; end if;
     if vapell_materno is null then let vapell_materno = ""; end if;
     if vnombre1 is null then  let vnombre1 = ""; end if;
     if vnombre2 is null then let vnombre2 = ""; end if;
     if vfecha_nac is null then let vrfc = "";  end if;
     if vfecha_alta is null then let vfecha_alta = ""; end if;
     if vnacionalidad is null then let vnacionalidad = "01"; end if;
     if vresidencia is null then let vresidencia = "MX"; end if;
     if vestado_civil is null then let vestado_civil = " "; end if;
     if vsexo is null then let vsexo = "I"; end if;
     if vstatus_cred is null then let vstatus_cred = "AA"; end if;

-- Inicia Segmento PN (Nombre)
--     call sp_fechas_archivo("burofisicas_hora","Seg PN") returning vcodret2;

     let existe = length(vapell_paterno);
     let existe1 = 0;
     let vquita = "";
     let vespacio = "";
     while existe1 < existe
         if vapell_paterno[1,1]="~" then
         else
           if vapell_paterno[1,1]="0" then
              let vapell_paterno[1,1] = "O";
           end if
           if vapell_paterno[1,1]="1" then
              let vapell_paterno[1,1] = "L";
           end if
           if vapell_paterno[1,1]="5" then
              let vapell_paterno[1,1] = "S";
           end if
           if vapell_paterno[1,1]="8" then
              let vapell_paterno[1,1] = "B";
           end if
           if vespacio = "F" then
            let vquita = trim(vquita)||" "||vapell_paterno[1,1];
            let vespacio = "";
           else
            let vquita = trim(vquita)||vapell_paterno[1,1];
           end if;
           if vapell_paterno[1,1]=" " then
              let vespacio = "F";
           end if;
         end if;
         let vapell_paterno = vapell_paterno[2,26];
         let existe1 = existe1 + 1;
     end while;
     let vapell_paterno = trim(vquita);
     if vapell_paterno = "X X" then
        let vapell_paterno = "XX";
     end if;
     let existe = length(vapell_materno);
     let existe1 = 0;
     let vquita = "";
     let vespacio = "";
     while existe1 < existe
         if vapell_materno[1,1]="~" then
         else
           if vapell_materno[1,1]="0" then
              let vapell_materno[1,1] = "O";
           end if
           if vapell_materno[1,1]="1" then
              let vapell_materno[1,1] = "L";
           end if
           if vapell_materno[1,1]="5" then
              let vapell_materno[1,1] = "S";
           end if
           if vapell_materno[1,1]="8" then
              let vapell_materno[1,1] = "B";
           end if
           if vespacio = "F" then
            let vquita = trim(vquita)||" "||vapell_materno[1,1];
            let vespacio = "";
           else
            let vquita = trim(vquita)||vapell_materno[1,1];
           end if;
           if vapell_materno[1,1]=" " then
              let vespacio = "F";
           end if;
         end if;
         let vapell_materno = vapell_materno[2,26];
         let existe1 = existe1 + 1;
     end while;
     let vapell_materno = trim(vquita);
     if vapell_materno = "X X" then
             let vapell_materno = "XX";
     end if;
     let existe = length(vnombre1);
     let existe1 = 0;
     let vquita = "";
     let vespacio = "";
     while existe1 < existe
       if vnombre1[1,1]="~" then
       else
        if vnombre1[1,1]="0" then
          let vnombre1[1,1] = "O";
        end if
        if vnombre1[1,1]="1" then
          let vnombre1[1,1] = "L";
        end if
        if vnombre1[1,1]="5" then
          let vnombre1[1,1] = "S";
        end if
        if vnombre1[1,1]="8" then
          let vnombre1[1,1] = "B";
        end if
        if vespacio = "F" then
         let vquita = trim(vquita)||" "||vnombre1[1,1];
         let vespacio = "";
        else
         let vquita = trim(vquita)||vnombre1[1,1];
        end if;
        if vnombre1[1,1]=" " then
         let vespacio = "F";
        end if;
       end if;
       let vnombre1 = vnombre1[2,26];
       let existe1 = existe1 + 1;
     end while;
     let vnombre1 = trim(vquita);
     let existe = length(vnombre2);
     let existe1 = 0;
     let vquita = "";
     let vespacio = "";
     while existe1 < existe
       if vnombre2[1,1]="~" then
       else
        if vnombre2[1,1]="0" then
          let vnombre2[1,1] = "O";
        end if
        if vnombre2[1,1]="1" then
          let vnombre2[1,1] = "L";
        end if
        if vnombre2[1,1]="5" then
          let vnombre2[1,1] = "S";
        end if
        if vnombre2[1,1]="8" then
          let vnombre2[1,1] = "B";
        end if
        if vespacio = "F" then
         let vquita = trim(vquita)||" "||vnombre2[1,1];
         let vespacio = "";
        else
         let vquita = trim(vquita)||vnombre2[1,1];
        end if;
        if vnombre2[1,1]=" " then
         let vespacio = "F";
        end if;
       end if;
       let vnombre2 = vnombre2[2,26];
       let existe1 = existe1 + 1;
     end while;
     let vnombre2 = trim(vquita);
     if vnombre1 = "-" then
         let vnombre1 = vnombre2;
         let vnombre2 = "";
     end if;
     let vfecha_finiq = "";
     if vstatus_cred = "FF" then
        select fecha_ult_mov into vfecha_finiq
           from bdicred:sd_maesdos
           where num_credito = vnum_credito and empresa = "001";
        if vfecha_finiq <= vfecha_ini then
           continue foreach;
        end if
     end if

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

-- Termina Segmento PN
--    call sp_fechas_archivo("burofisicas_hora","Seg PA") returning vcodret2;
-- Inicia Segmento PA (Direccion)

     select max(secuencia) into vsecuencia
       from bdinteg:si_direcciones
      where numcte = vnumcte and tipo_dir = '1';

     SELECT Trim(f.nombrecalle)||' '||Trim(a.numeroextcalle)||' '||
	    Trim(a.numerointcalle),
            Trim(g.nombrezona),Trim(b.nombre), Trim(c.estado),
            a.cod_postal,manzana,andador,lote,edificio,entrada,codini,codfin
       INTO vcalle,vcolonia,vdelegacion,vestado,vcod_postal,
            vmanzana,vandador,vlote,vedificio,ventrada, vcodini,vcodfin
       FROM bdinteg:si_direcciones as a,bdinteg:si_ciudades as b,
            bdisolic:ss_circulo_edos as c,bdinteg:si_catcalles f,
	    bdinteg:si_catzonas g
      WHERE a.numcte=vnumcte 
        AND a.secuencia=vsecuencia 
        AND a.pais = b.pais
     	AND a.estado = b.estado 
        AND a.ciudad = b.ciudad
        AND c.empresa = "001"
        AND a.estado = c.clave 
        AND a.numerociudad = g.numerociudad 
        AND a.numerocolonia = g.numerocolonia
        AND a.numerocalle = f.numerocalle;

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
    if vcod_postal[1,1] IN( 1,2,3,4,5,6,7,8,9)  then
      let vcod_postala = vcod_postal[1,1] * 10000;
    else
      let vcod_postala = 0;
    end if
    if vcod_postal[2,2] IN ( 1,2,3,4,5,6,7,8,9) THEN
      let vcod_postala = vcod_postala + vcod_postal[2,2] * 1000;
    else
      let vcod_postala = vcod_postala + 0;
    end if
    if vcod_postal[3,3] IN ( 1,2,3,4,5,6,7,8,9) THEN
      let vcod_postala = vcod_postala + vcod_postal[3,3] * 100;
    else
      let vcod_postala = vcod_postala + 0;
    end if
    if vcod_postal[4,4] IN ( 1,2,3,4,5,6,7,8,9) THEN
      let vcod_postala = vcod_postala + vcod_postal[4,4] * 10;
    else
      let vcod_postala = vcod_postala + 0;
    end if
    if vcod_postal[5,5] IN ( 1,2,3,4,5,6,7,8,9) THEN
      let vcod_postala = vcod_postala + vcod_postal[5,5] ;
    else
      let vcod_postala = vcod_postala + 0;
    end if
    if vcod_postala < vcodini or vcod_postala > vcodfin then
       let vcod_postal = lpad(round(vcodini),5,"0");
    end if
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

     if vdelegacion != "" then
        let vsegmento2_pa = trim(vsegmento2_pa)||'02'||
                               lpad(length(trim(vdelegacion)),2,"0")||vdelegacion;
        let tb_delegacion     = vdelegacion;
     end if

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

-- Termina Segmento PA (Direccion)
--     call sp_fechas_archivo("burofisicas_hora","Seg TL") returning vcodret2;
-- Inicia Segmento TL (Datos Financieros)
 
-- Venta de caretra Ini

    if (vstatus_cred = "CV") then
        select num_credito, maneja_linea,divisa,period_pag_int,
                fecha_apertura,numcte,monto_otorgado,dia_cuota
          into vnum_credito,vtp_linea,vdivisa,vfrecuencia,
                 vfecha_apertura,vnumcte,vlinea_prod,vdiacuota
          from crecv
          where num_credito = vnum_credito;
    else
         select num_credito, maneja_linea,divisa,period_pag_int,
                fecha_apertura,numcte,monto_otorgado,dia_cuota
           into vnum_credito,vtp_linea,vdivisa,vfrecuencia,
                 vfecha_apertura,vnumcte,vlinea_prod,vdiacuota
           from crenocv
          where num_credito = vnum_credito;
    end if;

--     call sp_fechas_archivo("burofisicas_hora","Datos credito") returning vcodret2;

-- Venta de caretra Fin

     let vfechacuota = mdy(month(vfecha_hoy),vdiacuota,year(vfecha_hoy));
     if vfechacuota < vfecha_apertura or vnum_credito is null then -- creditos sin procesar
        continue foreach;
     end if
     if vlinea_prod is null or vlinea_prod = 0 then
        let vlinea_prod = 1000;
     end if;

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

     if vtp_linea = '1' then
        let vsegmento3_tl = trim(vsegmento3_tl)||'R0702CC';
        let vnum_pagos = 0;
        let vfrecpago = "M";
        let tb_tipo_cuenta       = "R";
        let tb_tipo_producto     = "CC";
     else
--        SET DEBUG FILE TO "burofisicas.out";
--        TRACE ON; 
--        let vnum_credito = vnum_credito;

        let vsegmento3_tl = trim(vsegmento3_tl)||'I0702PL';
        select count(num_pago) into vnum_pagos
             from bdicred:sd_amortiza_credito
        where num_credito = vnum_credito and empresa = "001";
        select clave into vfrecpago from bdicred:sd_codpint
	        where period_pag_int = vfrecuencia and empresa = "001";
        let tb_tipo_cuenta       = "I";
        let tb_tipo_producto     = "PL";
     end if;

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

     let vmonto_otorgado = 0;
     let vsaldo_vig = 0;
     let vsaldo_actual = 0;
     let vsaldo_venc = 0;
     let vcuotas_ven = 0;

-- Venta de Cartera ini
     if (vstatus_cred = 'CV') then
         select monto_otorgado,
                0,
                nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0)
           into vmonto_otorgado, vsaldo_vig, vsaldo_venc
           from bdicred:sd_maesdos_vendida 
           where empresa = "001"
            and num_credito = vnum_credito;
     
     else
         select monto_otorgado,
                nvl(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci,0),
                nvl(monto_vencido + mto_venc_trasp,0)
           into vmonto_otorgado, vsaldo_vig, vsaldo_venc
           from bdicred:sd_maesdoscont 
          where fecha = vfecha_hoy
            and empresa = "001"
            and num_credito = vnum_credito;
     end if;

--     call sp_fechas_archivo("burofisicas_hora","Saldos") returning vcodret2;

-- Venta de Cartera fin

     -- Obtencion del monto a pagar
     -- Monto financiado al corte
     if vtp_linea = '1' then
-- Venta de Cartera ini
        if (vstatus_cred = 'CV') then
            let vcuota_cap = 0;
        else
            select monto_financiado into vcuota_cap
              from bdicred:sd_maesdoshist
              where fecha = vfecha_corte
                and empresa = "001"
                and num_credito = vnum_credito;
        end if;
     else
      select (capital_mto_cuota + interes_debe - interes_pagado)  into vcuota_cap
           from bdicred:sd_amortiza_credito
           where num_credito = vnum_credito and
                 empresa = "001" and
                 num_pago = 1;
     end if

-- Se agregan exepciones de pago y saldo
    
     let vrea_cal_cuota = 0;
     if vcuota_cap >= vsaldo_vig then
        if vsaldo_vig > 0 then
            let vcuota_cap = vsaldo_vig / 10;
            let vrea_cal_cuota = 1;
        else
            let vcuota_cap = 0;
        end if;
     end if;
     
     if round(vcuota_cap,0) = 0 and vsaldo_vig > 0 then
        let vcuota_cap = vsaldo_vig / 10;
        let vrea_cal_cuota = 1;
     end if;

     if round(vcuota_cap,0) = 0 then let vcuota_cap = round(vsaldo_vig,0); end if;

     if vcuota_cap > 0 then
       let vmonto = round(vcuota_cap,0);
     else
      let vmonto = 0;
     end if

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
     let vpago_int = "";
     -- Obtencion de la ultima fecha de pago
 
     select fecha_mov into vpago_cap
       from mov033
     where num_credito = vnum_credito;

    -- Obtencion de la ultima fecha de compra

     select fecha_mov into vpago_int
       from mov002
      where num_credito = vnum_credito;

--        call sp_fechas_archivo("burofisicas_hora","fec 002") returning vcodret2; 

     if vpago_cap is null then let vpago_cap = vfecha_apertura; end if;
     if vpago_int is null then let vpago_int = vfecha_apertura; end if;
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



-- Agregar Fecha de cierrre de la cuenta

     if vstatus_cred = "FF" then
        let vano = year(vfecha_finiq);
        let vmes = lpad(month(vfecha_finiq),2,"0");
        let vdia = lpad(day(vfecha_finiq),2,"0");
        let vsegmento3_tl = trim(vsegmento3_tl)||'1608'||vdia||vmes||vano;
        let tb_fecha_cierre      = vdia||vmes||vano;
     else
-- Venta de cartera ini
        if (vstatus_cred = "CV") then
            let vano = year(vfecha_venta);
            let vmes = lpad(month(vfecha_venta),2,"0");
            let vdia = lpad(day(vfecha_venta),2,"0");
            let vsegmento3_tl = trim(vsegmento3_tl)||'1608'||vdia||vmes||vano;
            let tb_fecha_cierre      = vdia||vmes||vano;
        end if;
-- Venta de cartera fin
     end if

-- Agregar Fecha Reporte

     let vsegmento3_tl = trim(vsegmento3_tl)||'1708'||vfecha_reporte;
     let tb_fecha_reporte     = vfecha_reporte;

-- where num_credito = vnum_credito and empresa = "001";

     if (vsaldo_venc is null) or (vsaldo_venc < 0) then let vsaldo_venc = 0; end if

     let vsaldo_actual = vsaldo_vig;
     let vcuotas_ven = 0;
     let vdiasvenc = 0;
     if vstatus_cred = "FF" or (vmonto = 0 and vstatus_cred <> "CV") then
--           let vsaldo_actual = 0;
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

-- Agregar Credito Maximo

      select max(monto)
       into vcredito_maximo
       from maximo
      where num_credito = vnum_credito;


--     foreach
--        select first 1 nvl(sum(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci),0)
--         into vcredito_maximo
--         from bdicred:sd_maesdoscont
--         where empresa = '001'
--           and num_credito = vnum_credito
--           and fecha <= vfecha_hoy
--         group by fecha
--         union all
--        select sum(sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci)
--          from bdicred:sd_maesdoshist
--         where empresa = '001'
--           and num_credito = vnum_credito
--           and fecha <= vfecha_hoy
--         group by fecha
--         order by 1 desc
--     end foreach
--
--     call sp_fechas_archivo("burofisicas_hora","Credito max") returning vcodret2; 

     if (vcredito_maximo is null) or (vcredito_maximo < 0) then let vcredito_maximo = 0.0; end if
     let vsegmento3_tl = trim(vsegmento3_tl)||'2109'||
                           lpad(round(vcredito_maximo,0),9,"0");
     let tb_credito_maximo    = round(vcredito_maximo,0);
  --                       lpad(round(vmonto_otorgado,0),9,"0");

-- Agregar Saldo Actual

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

     let vsegmento3_tl = trim(vsegmento3_tl)||'2309'||
                         lpad(round(vmonto_otorgado,0),9,"0");
     let tb_monto_otorgado    = round(vmonto_otorgado,0);

     if (vsaldo_venc > vsaldo_actual and vstatus_cred <> "CV")  then
        let vsaldo_venc = vsaldo_actual;
     end if;
   if vsaldo_venc <= 0 then
       let vcuotas_ven = 0;
       let vdiasvenc = 0;
   end if;

-- Se agregan pagos vencidos

-- Cartera vendida ini
-- Se lee la historia de amortizaciones para la cartera vendida
     if (vstatus_cred = 'CV') then
        select count(*)
         into vcuotas_ven
         from bdicred:sd_amortiza_credito_vendida b
        where empresa = '001'
          and num_credito = vnum_credito
          and b.capital_status in (2,7)
          and fecha_cuota >= date(0);
    else
        let vcuotas_ven = 0;
        select cuotas
         into vcuotas_ven
         from amortiza
        where num_credito = vnum_credito;

        if (vcuotas_ven = 0 or vcuotas_ven is null) then
           let vcuotas_ven = 0;
        end if;   
--        select count(*)
--         into vcuotas_ven
--         from bdicred:sd_amortiza_credito b
--        where empresa = '001'
--          and num_credito = vnum_credito
--          and b.capital_status in (2,7)
--          and fecha_cuota >= date(0);
    end if;
 
-- Cartera vendida fin

   if vcuotas_ven is null then let vcuotas_ven = 0; end if;

   ---Modificar de acuerdo a circulo
   if vfecha_apertura > vfecha_ini then
      let vmop = "00";
   elif (vmonto = 0 and vstatus_cred <> 'CV') then
-- jom 
--      let vmop = "UR";
      let vmop = "01";
      let vsaldo_venc = 0;
--jom
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
    end if;
-- Agergar clave de observación

-- Venta de Cartera Fin

   let vsegmento3_tl = trim(vsegmento3_tl)||'9903FIN';
   let vsegmento3_tl = 'TL'||trim(vsegmento3_tl);

     if trim(vsegmento_pn) != "PN" and trim(vsegmento2_pa) != "PA" and trim(vsegmento3_tl) != "TL" then
        let vnumreg = vnumreg + 1;
        insert into br_burofisicas
        values(vnumreg,vsegmento_pn);

        let vnumreg = vnumreg + 1;
        insert into br_burofisicas
        values(vnumreg,vsegmento2_pa);

        let vnumreg = vnumreg + 1;
        insert into br_burofisicas
        values(vnumreg,vsegmento3_tl);


-- Se agrega tabla para grabar informacion enviada
        insert into br_burofisicas_describe
           values (tb_num_credito, tb_apell_paterno, tb_apell_materno, tb_nombre1, tb_nombre2, tb_fecha_nac, tb_rfc, tb_nacionalidad, tb_estado_civil, tb_sexo,
                   tb_calle, tb_colonia, tb_delegacion, tb_ciudad, tb_estado, tb_cod_postal,
                   tb_clave_usu, tb_nombre_usu, tb_responsabilidad, tb_tipo_cuenta, tb_tipo_producto, tb_clave_monetaria, tb_num_pagos, tb_frecpago, tb_monto_pagar,
                   tb_fecha_apertura, tb_fecha_ult_pago, tb_fecha_ult_compra, tb_fecha_cierre, tb_fecha_reporte, tb_credito_maximo, tb_saldo_actual, tb_monto_otorgado,
                   tb_saldo_venc, tb_cuotas_ven, tb_mop,tb_clave_obs, vrea_cal_cuota);

        let vreg_proc = vreg_proc + 1;
        let vtot_proc = vtot_proc + 1;

        let contador_commit = contador_commit  + 1;
        let contador_stat = contador_stat + 1;

        if (vreg_proc >= 10000) then 
            let vreg_proc = 0; 
--            call sp_fechas_archivo("burofisicas_hora","Reg: "||vtot_proc) returning vcodret2;            
        end if;

     end if;

--     call sp_fechas_archivo("burofisicas_hora","Insert Desc") returning vcodret2; 
  end foreach

  if (contador_commit > 0) then
      commit work;
  end if;

--  call sp_fechas_archivo("burofisicas_hora","termina cursor") returning vcodret2;
--  call sp_fechas_archivo("burofisicas_hora","Reg tot: "||vtot_proc) returning vcodret2;

  CREATE INDEX "informix".inxburofisicas ON "informix".br_burofisicas(numreg);

  update statistics medium for table "informix".br_burofisicas;
  update statistics medium for table "informix".br_burofisicas_describe;

  select valor into vruta_interfase
      from bdiburo:br_param
      where cod_param = 9;
  let varchivo = "genburofis.sql";
  let varchivo_des = "genburofis_describe.sql";
  
  let vsql = 'echo " unload to xburofis.unl'||" delimiter '|' "||
             '" > '||trim(varchivo);
  system vsql;

  let vsql = 'echo "'||
             "select registro from br_burofisicas order by numreg "||
                 '" >> '||trim(varchivo);
  system vsql;

  let vsql = "dbaccess bdiburo "||trim(varchivo);
  system vsql;

  let vsql = "sed 's/&/ /g' xburofis.unl > xburofis1.unl ";
  system vsql;

  let vsql = "sed 's/[~]*|//g' xburofis1.unl > xburofis2.unl ";
  system vsql;

  let vsql = "sed 's/|//g' xburofis2.unl > xburofis1.unl ";
  system vsql;

  let vsql = "cp  xburofis1.unl  "||trim(vruta_interfase)||"/cintafis"||vfecha_reporte||".txt ";
  system vsql;

  let vsql = "rm xburofis*";
  system vsql;

--  call sp_fechas_archivo("burofisicas_hora","Fin") returning vcodret2;
  return vcodret;
end procedure;