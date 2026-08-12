CREATE PROCEDURE "informix".libmaysuc(pempresa char(3), pfecha_hoy date,v_mayor char(10),
                         v_sub char(10), v_subsub char(10),v_ssubsub char(10),
                         v_sssubsub char(10), v_sector char(10))

DEFINE tempresa           char(3);
DEFINE tccmayor           char(10);
DEFINE tccsub             char(10);
DEFINE tccsubsub          char(10);
DEFINE tccssubsub         char(10);
DEFINE tccsssubsub        char(10);
DEFINE tsector            char(10);
DEFINE tciudad            char(3);
DEFINE tsucursal          char(4);
DEFINE tmoneda            char(2);
DEFINE tsaldo_inicio_mes  money(18,2);
DEFINE tsaldo_actual      money(18,2);
DEFINE tsaldo_inicial     money(18,2);
DEFINE tsaldo_final       money(18,2);
DEFINE tfecha_hoy         date;
DEFINE tmonto             money(18,2);
DEFINE tusuario           char(8);
DEFINE tcontrol_poliza    int;
DEFINE tfecha_valida      date;
DEFINE tnaturaleza        char(1);
DEFINE tnat_cta           char(1);
DEFINE tsecuencia         int;
DEFINE tnro_auxiliar      char(12);
DEFINE v_dia              CHAR(2);
DEFINE v_mes              CHAR(2);
DEFINE v_ano              CHAR(4);
DEFINE v_fecha_inicio     DATE;
DEFINE v_fecha_fin        DATE;
DEFINE lv_minfecha        date;
DEFINE lv_maxfecha        date;
DEFINE v_fecha_inicio_bkp CHAR(8);
DEFINE v_fecha_fin_bkp    CHAR(8);
DEFINE v_fecha_inicio1    DATE;
DEFINE v_fecha_fin1       DATE;
DEFINE v_fecha_hoy        DATE;
DEFINE v_flag_fech1       DATE;
DEFINE v_subcuenta        CHAR(50);
DEFINE v_cuenta           CHAR(60);
DEFINE vdescripcion_det   CHAR(50);
DEFINE tnombrecta         CHAR(40);
DEFINE tnombmon           CHAR(30);
DEFINE unecta             CHAR(60);

 
   DELETE FROM co_libmaenca;
   DELETE FROM co_libmadet;

   LET v_subcuenta = NULL;
   LET v_cuenta    = NULL;

   LET v_dia = DAY(pfecha_hoy);
   IF v_dia < 10 then
      let v_dia = "0"||v_dia;
   END IF

   LET v_mes = MONTH(pfecha_hoy);
   IF v_mes < 10 then
      let v_mes = "0"||v_mes;
   END IF

   LET v_ano = YEAR(pfecha_hoy);

   LET v_fecha_inicio_bkp = v_mes||"01"||v_ano;
   LET v_fecha_fin_bkp    = v_mes||v_dia||v_ano;

   LET v_fecha_inicio  = v_fecha_inicio_bkp;
   LET v_fecha_fin     = v_fecha_fin_bkp;

   LET v_fecha_inicio1 = v_mes||"01"||v_ano;
   LET v_fecha_fin1    = v_mes||v_dia||v_ano ;

   SELECT fecha_hoy
   INTO   v_fecha_hoy
   FROM   co_fechas
   WHERE  empresa = pempresa;

   SET ISOLATION TO DIRTY READ;
   FOREACH
      SELECT distinct
             empresa,
             ccmayor,
             ccsub,
             ccsubsub,
             ccssubsub,
             ccsssubsub,
             sector,
             ciudad,
             sucursal,
             moneda
      INTO
             tempresa,
             tccmayor,
             tccsub,
             tccsubsub,
             tccssubsub,
             tccsssubsub,
             tsector,
             tciudad,
             tsucursal,
             tmoneda
      FROM co_saldos
      WHERE
           empresa = pempresa
      AND  ccmayor    = v_mayor
      AND  ccsub      = v_sub
      AND  ccsubsub   = v_subsub
      AND  ccssubsub  = v_ssubsub
      AND  ccsssubsub = v_sssubsub
      AND  sector     = v_sector
      AND  mes_dia between v_fecha_inicio and v_fecha_fin
      ORDER BY
           empresa, moneda, ccmayor, ccsub, ccsubsub, ccssubsub,
           ccsssubsub, sector, ciudad, sucursal, moneda

      select min(mes_dia)
      into   lv_minfecha
      from co_saldos
      where empresa    = tempresa
      and   ccmayor    = tccmayor
      and   ccsub      = tccsub
      and   ccsubsub   = tccsubsub
      and   ccssubsub  = tccssubsub
      and   ccsssubsub = tccsssubsub
      and   sector     = tsector
      and   ciudad     = tciudad
      and   sucursal   = tsucursal
      and   moneda     = tmoneda
      and   mes_dia between v_fecha_inicio and v_fecha_fin;

      select saldo_inicio_dia
      into tsaldo_inicio_mes
      from co_saldos
      where empresa    = tempresa
      and   ccmayor    = tccmayor
      and   ccsub      = tccsub
      and   ccsubsub   = tccsubsub
      and   ccssubsub  = tccssubsub
      and   ccsssubsub = tccsssubsub
      and   sector     = tsector
      and   ciudad     = tciudad
      and   sucursal   = tsucursal
      and   moneda     = tmoneda
      and   mes_dia    = lv_minfecha;

      select nombre
      into   tnombrecta
      from bdinteg:si_catalog
      where empresa    = tempresa
      and   ccmayor    = tccmayor
      and   ccsub      = tccsub
      and   ccsubsub   = tccsubsub
      and   ccssubsub  = tccssubsub
      and   ccsssubsub = tccsssubsub
      and   sector     = tsector;

      select descripcion
      into   tnombmon
      from   bdinteg:si_divisas
      where  empresa = tempresa
      and    divisa  = tmoneda;

      let unecta = trim(tccmayor)||trim(tccsub)||trim(tccsubsub)||
                   trim(tccssubsub)||trim(tccsssubsub)||trim(tsector);

      INSERT INTO co_libMAenca
         VALUES(tempresa,unecta,
                tccmayor,tccsub,tccsubsub,tccssubsub,
                tccsssubsub,tsector,tciudad,tsucursal,tmoneda,
                tsaldo_inicio_mes,tnombrecta,tnombmon);

      LET tsaldo_inicial = tsaldo_inicio_mes;
      FOREACH
         select fecha_valida,usuario,control_poliza,secuencia,
                nro_auxiliar,naturaleza,monto,descripcion_det
         into   tfecha_valida,tusuario,tcontrol_poliza,tsecuencia,
                tnro_auxiliar,tnaturaleza,tmonto,vdescripcion_det
         from co_movtos
         where empresa    = tempresa
         and   ccmayor    = tccmayor
         and   ccsub      = tccsub
         and   ccsubsub   = tccsubsub
         and   ccssubsub  = tccssubsub
         and   ccsssubsub = tccsssubsub
         and   sector     = tsector
         and   ciudad     = tciudad
         and   sucursal   = tsucursal
         and   moneda     = tmoneda
         and   fecha_valida between v_fecha_inicio and v_fecha_fin
         and   fecha_captura <= v_fecha_hoy
         order by fecha_valida,usuario,control_poliza,secuencia,
                  nro_auxiliar

         select naturaleza_cta
         into   tnat_cta
         from bdinteg:si_catalog
         where empresa    = tempresa
         and   ccmayor    = tccmayor
         and   ccsub      = tccsub
         and   ccsubsub   = tccsubsub
         and   ccssubsub  = tccssubsub
         and   ccsssubsub = tccsssubsub
         and   sector     = tsector;

         if tfecha_valida is null then
         else
            if tnat_cta = "D" then
               if tnaturaleza = "D" then
                  let tsaldo_final = tsaldo_inicial + tmonto;
               else
                  let tsaldo_final = tsaldo_inicial - tmonto;
               end if
            else
               if tnaturaleza = "D" then
                  let tsaldo_final = tsaldo_inicial - tmonto;
               else
                  let tsaldo_final = tsaldo_inicial + tmonto;
               end if
            end if

            let unecta = trim(tccmayor)||trim(tccsub)||trim(tccsubsub)||
                         trim(tccssubsub)||trim(tccsssubsub)||trim(tsector);

            INSERT INTO co_libMAdet
            VALUES(tempresa,
                   unecta,
                   tccmayor,
                   tccsub,
                   tccsubsub,
                   tccssubsub,
                   tccsssubsub,
                   tsector,
                   tciudad,
                   tsucursal,
                   tmoneda,
                   tfecha_valida,
                   tusuario,
                   tcontrol_poliza,
                   tsecuencia,
                   tnro_auxiliar,
                   tnaturaleza,
                   tsaldo_inicial,
                   tmonto,
                   tsaldo_final,
                   vdescripcion_det);
            LET tsaldo_inicial = tsaldo_final;
         end if
      END FOREACH;
   END FOREACH;
END PROCEDURE;