CREATE PROCEDURE "informix".gen_totalbalanza(pempresa char(3),p_val char(2),w_fecha date,p_ext char(2),v_usuario char(10))
--****************************************************************************
DEFINE bpempresa         char(3);
DEFINE bpccmayor         char(10);
DEFINE bpccsub           char(10);
DEFINE bpccsubsub        char(10);
DEFINE bpccssubsub       char(10);
DEFINE bpccsssubsub      char(10);
DEFINE bpsector          char(10);
DEFINE bpciudad          char(3);
DEFINE bpsucursal        char(4);
DEFINE bpmoneda          char(2);
DEFINE bpmes_dia         char(10);
DEFINE bpsaldo_dia_anterior  money(18,2);
DEFINE bpcargos_dia      money(18,2);
DEFINE bpabonos_dia      money(18,2);
DEFINE bpsaldo_actual    money(18,2);
DEFINE bptipo_cta        char(1);
DEFINE bpromedio_anual   money(18,2);

DEFINE baccmayor         char(10);
DEFINE baccsub           char(10);
DEFINE baccsubsub        char(10);
DEFINE baccssubsub       char(10);
DEFINE baccsssubsub      char(10);
DEFINE basector          char(10);

DEFINE v_mayor           char(10);
DEFINE v_mayor1          char(1);
DEFINE v_mayor2          char(10);
DEFINE w_cuantos         integer;
DEFINE fecha_movto       DATE;

DEFINE v_len_may         smallint;
DEFINE v_len_s           smallint;
DEFINE v_len_ss          smallint;
DEFINE v_len_sss         smallint;
DEFINE v_len_ssss        smallint;
DEFINE v_len_sect        smallint;
DEFINE i                 smallint;

DEFINE v_cero_may        char(10);
DEFINE v_cero_s          char(10);
DEFINE v_cero_ss         char(10);
DEFINE v_cero_sss        char(10);
DEFINE v_cero_ssss       char(10);
DEFINE v_cero_sect       char(10);
DEFINE v_cero_may_1      char(10);
DEFINE v_cero_may_2      char(10);
DEFINE v_nombre          char(50);
DEFINE v_nat             char(1);
DEFINE v_tpc             money(14,6);
DEFINE v_monpar          char(2);
DEFINE v_descsuc         char(40);
DEFINE v_fecha_tc        date;
DEFINE v_cuenta          char(20);

--set debug file to "/tmp/gen_totalbalanza.out";
--trace on;

SELECT len_may  ,len_s  ,len_ss  ,len_sss  ,len_ssss  ,len_sect, valor_cambio
INTO   v_len_may,v_len_s,v_len_ss,v_len_sss,v_len_ssss,v_len_sect, v_monpar
FROM   co_param
WHERE  empresa = pempresa;

LET v_tpc = 0;

LET v_cero_may   = "";
LET v_cero_s     = "";
LET v_cero_ss    = "";
LET v_cero_sss   = "";
LET v_cero_ssss  = "";
LET v_cero_sect  = "";
LET v_cero_may_1 = "";
LET v_cero_may_2 = "";
LET bpromedio_anual = 0;
LET v_cuenta     = "";
LET v_fecha_tc = "";

FOR i = 1 TO v_len_may
   LET v_cero_may   = TRIM(v_cero_may) || "0";
END FOR;

LET v_cero_may = v_cero_may;

FOR i = 1 TO v_len_s
   LET v_cero_s     = TRIM(v_cero_s) || "0";
END FOR;
FOR i = 1 TO v_len_ss
   LET v_cero_ss    = TRIM(v_cero_ss) || "0";
END FOR;
FOR i = 1 TO v_len_sss
   LET v_cero_sss   = TRIM(v_cero_sss) || "0";
END FOR;
FOR i = 1 TO v_len_ssss
   LET v_cero_ssss  = TRIM(v_cero_ssss) || "0";
END FOR;
FOR i = 1 TO v_len_sect
   LET v_cero_sect  = TRIM(v_cero_sect) || "0";
END FOR;
FOR i = 2 TO v_len_may
   LET v_cero_may_1 = TRIM(v_cero_may_1) || "0";
END FOR;
FOR i = 3 TO v_len_may
   LET v_cero_may_2 = TRIM(v_cero_may_2) || "0";
END FOR;

FOREACH
   SELECT empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector,
          ciudad, sucursal, moneda, mes_dia, saldo_dia_anterior, cargos_dia,
          abonos_dia, saldo_actual, tipo_cta, naturaleza_cta, nombre, desc_sucursal
     INTO bpempresa, bpccmayor, bpccsub, bpccsubsub, bpccssubsub, bpccsssubsub, bpsector,
          bpciudad, bpsucursal, bpmoneda, bpmes_dia, bpsaldo_dia_anterior, bpcargos_dia,
          bpabonos_dia, bpsaldo_actual, bptipo_cta, v_nat, v_nombre, v_descsuc
     FROM co_balanza
    WHERE empresa    = pempresa    
      AND ccmayor    IS NOT NULL
      AND ccsub      IS NOT NULL      
      AND ccsubsub   IS NOT NULL
      AND ccssubsub  IS NOT NULL  
      AND ccsssubsub IS NOT NULL
      AND sector     IS NOT NULL     
      AND ciudad     IS NOT NULL
      AND sucursal   IS NOT NULL   
      AND moneda     IS NOT NULL
      AND mes_dia    IS NOT NULL     
      AND tipo_cta   IS NOT NULL
      AND usuario    = v_usuario   
      AND (saldo_dia_anterior <> 0 or cargos_dia <> 0 or abonos_dia <> 0 or
          saldo_actual <> 0)
      ORDER BY ccmayor DESC, ccsub DESC, ccsubsub DESC,
       ccssubsub DESC, ccsssubsub DESC, sector DESC, moneda DESC, mes_dia

   LET baccmayor    = bpccmayor;
   LET baccsub      = bpccsub;
   LET baccsubsub   = bpccsubsub;
   LET baccssubsub  = bpccssubsub;
   LET baccsssubsub = bpccsssubsub;
   LET basector     = bpsector;

   -- ENCABEZADO PRIMER NIVEL
   LET v_mayor = bpccmayor[1,1]||TRIM(v_cero_may_1);
   LET v_mayor1 = bpccmayor[1,1];
      SELECT count(*) INTO w_cuantos FROM co_balanza
      WHERE empresa    = bpempresa AND
            ccmayor    = v_mayor AND
            ccsub      = v_cero_s AND
            ccsubsub   = v_cero_ss AND
            ccssubsub  = v_cero_sss AND
            ccsssubsub = v_cero_ssss AND
            sector     = v_cero_sect AND
            ciudad     = bpciudad AND
            sucursal   = bpsucursal AND
            moneda     = bpmoneda AND
            mes_dia    = bpmes_dia AND
            tipo_cta   = "T" AND
            usuario    = v_usuario;

      if w_cuantos = 0 then
         -- acumula saldos de totalizadoras
         SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
         nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
         into bpsaldo_dia_anterior,bpcargos_dia,
              bpabonos_dia,bpsaldo_actual,bpromedio_anual
         FROM co_balanza
        WHERE empresa      = pempresa
          AND ccmayor[1,1] = v_mayor1
          AND ccsub        IS NOT NULL
          AND ccsubsub     IS NOT NULL
          AND ccssubsub    IS NOT NULL
          AND ccsssubsub   IS NOT NULL
          AND sector       IS NOT NULL
          AND ciudad       = bpciudad
          AND sucursal     = bpsucursal
          AND moneda       = bpmoneda
          AND mes_dia      = bpmes_dia
          AND tipo_cta     = "D"
          AND usuario      = v_usuario;

         LET bpccmayor    = v_mayor;
         LET bpccsub      = v_cero_s;
         LET bpccsubsub   = v_cero_ss;
         LET bpccssubsub  = v_cero_sss;
         LET bpccsssubsub = v_cero_ssss;
         LET bpsector     = v_cero_sect;
         LET bptipo_cta   = "T";

         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);

         -- regresa valores originales
         LET bpccmayor     = baccmayor;
         LET bpccsub       = baccsub;
         LET bpccsubsub    = baccsubsub;
         LET bpccssubsub   = baccssubsub;
         LET bpccsssubsub  = baccsssubsub;
         LET bpsector      = basector;
      END IF
   
   -- ENCABEZADO SEGUNDO NIVEL
   LET v_mayor = bpccmayor[1,2]||TRIM(v_cero_may_2);
   LET v_mayor2 = bpccmayor[1,2];
   
     SELECT count(*) INTO w_cuantos FROM co_balanza
      WHERE empresa    = bpempresa AND
            ccmayor    = v_mayor AND
            ccsub      = v_cero_s AND
            ccsubsub   = v_cero_ss AND
            ccssubsub  = v_cero_sss AND
            ccsssubsub = v_cero_ssss AND
            sector     = v_cero_sect AND
            ciudad     = bpciudad AND
            sucursal   = bpsucursal AND
            moneda     = bpmoneda  AND
            mes_dia    = bpmes_dia AND
            tipo_cta   = "T" AND
            usuario    = v_usuario;

      IF w_cuantos = 0 THEN
         SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
                nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
         INTO bpsaldo_dia_anterior,bpcargos_dia,
              bpabonos_dia,bpsaldo_actual,bpromedio_anual
         FROM co_balanza
        WHERE empresa      = bpempresa
         AND  ccmayor[1,2] = v_mayor2
         AND  ccsub        IS NOT NULL
         AND  ccsubsub     IS NOT NULL
         AND  ccssubsub    IS NOT NULL
         AND  ccsssubsub   IS NOT NULL
         AND  sector       IS NOT NULL
         AND  ciudad       = bpciudad
         AND  sucursal     = bpsucursal
         AND  moneda       = bpmoneda
         AND  mes_dia      = bpmes_dia
         AND  tipo_cta     = "D"
         AND  usuario      = v_usuario;

         LET bpccmayor    = v_mayor;
         LET bpccsub      = v_cero_s;
         LET bpccsubsub   = v_cero_ss;
         LET bpccssubsub  = v_cero_sss;
         LET bpccsssubsub = v_cero_ssss;
         LET bpsector     = v_cero_sect;
         LET bptipo_cta   = "T";

         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);

         -- regresa valores originales
         LET bpccmayor     = baccmayor;
         LET bpccsub       = baccsub;
         LET bpccsubsub    = baccsubsub;
         LET bpccssubsub   = baccssubsub;
         LET bpccsssubsub  = baccsssubsub;
         LET bpsector      = basector;
      end if

  -- Determina si se trata de una cuenta totalizadora
  -- cuarto nivel

  LET bpccmayor     = bpccmayor;
  LET bpccsub       = bpccsub;
  LET bpccsubsub    = bpccsubsub;
  LET bpccssubsub   = bpccssubsub;
  LET bpccsssubsub  = bpccsssubsub;

  IF bpccmayor > v_cero_may AND bpccsub > v_cero_s AND
     bpccsubsub > v_cero_ss AND bpccssubsub > v_cero_sss AND
     bpccsssubsub > v_cero_ssss THEN

     -- sector cero cuarto nivel
     SELECT count(*) INTO w_cuantos FROM co_balanza
     where empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = bpccsub AND
           ccsubsub   = bpccsubsub AND
           ccssubsub  = bpccssubsub AND
           ccsssubsub = bpccsssubsub AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda  AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;

     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        WHERE empresa     = bpempresa AND
              ccmayor     = bpccmayor AND
              ccsub       = bpccsub AND
              ccsubsub    = bpccsubsub AND
              ccssubsub   = bpccssubsub AND
              ccsssubsub  = bpccsssubsub AND
              sector      IS NOT NULL AND
              ciudad      = bpciudad AND
              sucursal    = bpsucursal AND
              moneda      = bpmoneda AND
              mes_dia     = bpmes_dia AND
              tipo_cta    = "D" AND
              usuario     = v_usuario;

        LET bpsector   = v_cero_sect;
        LET bptipo_cta = "T";

         
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);

        -- regresa valores originales
        LET bpsector  = basector;
     END IF

     -- sector cero tercer nivel
     SELECT count(*) INTO w_cuantos FROM co_balanza
     WHERE empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = bpccsub AND
           ccsubsub   = bpccsubsub AND
           ccssubsub  = bpccssubsub AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;

     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        WHERE empresa    = bpempresa AND
              ccmayor    = bpccmayor AND
              ccsub      = bpccsub AND
              ccsubsub   = bpccsubsub AND
              ccssubsub  = bpccssubsub AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND
              ciudad     = bpciudad AND
              sucursal   = bpsucursal AND
              moneda     = bpmoneda AND
              mes_dia    = bpmes_dia AND
              tipo_cta   = "D" AND
              usuario    = v_usuario;

        LET bpccsssubsub = v_cero_ssss;
        LET bpsector = v_cero_sect;
        LET bptipo_cta = "T";

         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);

        -- regresa valores originales
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     end if

     -- sector cero segundo nivel
     SELECT count(*) into w_cuantos from co_balanza
     where empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = bpccsub AND
           ccsubsub   = bpccsubsub AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        WHERE empresa  = bpempresa AND
              ccmayor  = bpccmayor AND
              ccsub    = bpccsub AND
              ccsubsub = bpccsubsub AND
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND 
              ciudad   = bpciudad AND
              sucursal = bpsucursal AND
              moneda   = bpmoneda  AND
              mes_dia  = bpmes_dia AND
              tipo_cta = "D" AND
              usuario  = v_usuario;

        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";

         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccssubsub  = baccssubsub;
        LET bpccsssubsub = baccsssubsub;
        LET bpsector     = basector;
     END IF

     -- sector cero primer nivel
     SELECT count(*) INTO w_cuantos FROM co_balanza
     WHERE empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = bpccsub AND
           ccsubsub   = v_cero_ss AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        WHERE empresa  = bpempresa AND
              ccmayor  = bpccmayor AND
              ccsub    = bpccsub AND
              ccsubsub   IS NOT NULL AND
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND
              ciudad   = bpciudad AND
              sucursal = bpsucursal AND
              moneda   = bpmoneda  AND
              mes_dia  = bpmes_dia AND
              tipo_cta = "D" AND
              usuario  = v_usuario;

        LET bpccsubsub   = v_cero_ss;
        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsubsub    = baccsubsub;
        LET bpccssubsub   = baccssubsub;
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     END IF

     -- sector cero nivel mayor
     SELECT count(*) INTO w_cuantos FROM co_balanza
     WHERE empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = v_cero_s AND
           ccsubsub   = v_cero_ss AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
        bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        WHERE empresa    = bpempresa AND
              ccmayor    = bpccmayor AND
              ccsub      IS NOT NULL AND
              ccsubsub   IS NOT NULL AND
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND
              ciudad     = bpciudad AND
              sucursal   = bpsucursal AND
              moneda     = bpmoneda  AND
              mes_dia    = bpmes_dia AND
              tipo_cta   = "D" AND
              usuario    = v_usuario;

        LET bpccsub      = v_cero_s;
        LET bpccsubsub   = v_cero_ss;
        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsub       = baccsub;
        LET bpccsubsub    = baccsubsub;
        LET bpccssubsub   = baccssubsub;
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     END IF
  END IF
  -- tercer nivel
  IF bpccmayor > v_cero_may AND bpccsub > v_cero_s AND
     bpccsubsub > v_cero_ss AND bpccssubsub > v_cero_sss AND
     bpccsssubsub = v_cero_ssss THEN
     -- sector cero tercer nivel
     SELECT count(*) INTO w_cuantos FROM co_balanza
     WHERE empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = bpccsub AND
           ccsubsub   = bpccsubsub AND
           ccssubsub  = bpccssubsub AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        WHERE empresa   = bpempresa AND
              ccmayor   = bpccmayor AND
              ccsub     = bpccsub AND
              ccsubsub  = bpccsubsub AND
              ccssubsub = bpccssubsub AND
              ccsssubsub IS NOT NULL AND 
              sector     IS NOT NULL AND
              ciudad    = bpciudad AND
              sucursal  = bpsucursal AND
              moneda    = bpmoneda  AND
              mes_dia   = bpmes_dia AND
              tipo_cta  = "D" AND
              usuario   = v_usuario;

        LET bpsector   = v_cero_sect;
        LET bptipo_cta = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     end if

     -- sector cero segundo nivel
     SELECT count(*) into w_cuantos from co_balanza
     where empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = bpccsub AND
           ccsubsub   = bpccsubsub AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     if w_cuantos = 0 then
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        into   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        from co_balanza
        where empresa    = bpempresa AND
              ccmayor    = bpccmayor AND
              ccsub      = bpccsub AND
              ccsubsub   = bpccsubsub AND
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND
              ciudad     = bpciudad AND
              sucursal   = bpsucursal AND
              moneda     = bpmoneda  AND
              mes_dia    = bpmes_dia AND
              tipo_cta   = "D" AND
              usuario    = v_usuario;

        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccssubsub  = baccssubsub;
        LET bpccsssubsub = baccsssubsub;
        LET bpsector     = basector;
     end if

     -- sector cero primer nivel
     SELECT count(*) into w_cuantos from co_balanza
     where empresa    = bpempresa   AND
           ccmayor    = bpccmayor   AND
           ccsub      = bpccsub AND
           ccsubsub   = v_cero_ss AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;

     if w_cuantos = 0 then
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        into   bpsaldo_dia_anterior,bpcargos_dia,
        bpabonos_dia,bpsaldo_actual,bpromedio_anual
        from co_balanza
        where empresa  = bpempresa AND
              ccmayor  = bpccmayor AND
              ccsub    = bpccsub AND
              ccsubsub   IS NOT NULL AND 
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND
              ciudad   = bpciudad AND
              sucursal = bpsucursal AND
              moneda   = bpmoneda  AND
              mes_dia  = bpmes_dia AND
              tipo_cta = "D" AND
              usuario  = v_usuario;

        LET bpccsubsub   = v_cero_ss;
        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsubsub    = baccsubsub;
        LET bpccssubsub   = baccssubsub;
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     END IF

     -- sector cero nivel mayor
     SELECT count(*) into w_cuantos from co_balanza
     where empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = v_cero_s AND
           ccsubsub   = v_cero_ss AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     if w_cuantos = 0 then
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        into   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        from co_balanza
        where empresa    = bpempresa AND
              ccmayor    = bpccmayor AND
              ccsub      IS NOT NULL AND
              ccsubsub   IS NOT NULL AND
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND
              ciudad     = bpciudad  AND
              sucursal   = bpsucursal AND
              moneda     = bpmoneda  AND
              mes_dia    = bpmes_dia AND
              tipo_cta   = "D" AND
              usuario    = v_usuario;

        LET bpccsub      = v_cero_s;
        LET bpccsubsub   = v_cero_ss;
        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsub  = baccsub;
        LET bpccsubsub  = baccsubsub;
        LET bpccssubsub  = baccssubsub;
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     END IF
  END IF
  -- segundo nivel
  IF bpccmayor > v_cero_may AND bpccsub   > v_cero_s AND
     bpccsubsub > v_cero_ss AND bpccssubsub = v_cero_sss AND
     bpccsssubsub = v_cero_ssss THEN
     -- sector cero segundo nivel
     SELECT count(*) into w_cuantos from co_balanza
     where empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = bpccsub AND
           ccsubsub   = bpccsubsub AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        WHERE empresa    = bpempresa AND
              ccmayor    = bpccmayor AND
              ccsub      = bpccsub AND
              ccsubsub   = bpccsubsub AND
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND 
              sector     IS NOT NULL AND
              ciudad     = bpciudad AND
              sucursal   = bpsucursal AND
              moneda     = bpmoneda  AND
              mes_dia    = bpmes_dia AND
              tipo_cta   = "D" AND
              usuario    = v_usuario;

        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector 	 = v_cero_sect;
        LET bptipo_cta 	 = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccssubsub  = baccssubsub;
        LET bpccsssubsub = baccsssubsub;
        LET bpsector     = basector;
     END IF

     -- sector cero primer nivel
     SELECT count(*) into w_cuantos from co_balanza
     where empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = bpccsub AND
           ccsubsub   = v_cero_ss AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        WHERE empresa       = bpempresa AND
              ccmayor       = bpccmayor AND
              ccsub         = bpccsub AND
              ccsubsub      IS  NOT NULL AND
              ccssubsub     IS  NOT NULL AND
              ccsssubsub    IS  NOT NULL AND
              sector        IS  NOT NULL AND
              ciudad        = bpciudad AND
              sucursal      = bpsucursal AND
              moneda        = bpmoneda  AND
              mes_dia       = bpmes_dia AND
              tipo_cta 	    = "D" AND
              usuario       = v_usuario;

        LET bpccsubsub   = v_cero_ss;
        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsubsub    = baccsubsub;
        LET bpccssubsub   = baccssubsub;
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     end if

     -- sector cero nivel mayor
     SELECT count(*) into w_cuantos from co_balanza
     where empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = v_cero_s AND
           ccsubsub   = v_cero_ss AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;

     if w_cuantos = 0 then
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        into   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        from co_balanza
        where empresa    = bpempresa AND
              ccmayor    = bpccmayor AND
              ccsub      IS NOT NULL AND
              ccsubsub   IS NOT NULL AND
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND
              ciudad     = bpciudad AND
              sucursal   = bpsucursal AND
              moneda     = bpmoneda  AND
              mes_dia    = bpmes_dia AND
              tipo_cta   = "D" AND
              usuario    = v_usuario;

        LET bpccsub 	 = v_cero_s;
        LET bpccsubsub   = v_cero_ss;
        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsub  = baccsub;
        LET bpccsubsub  = baccsubsub;
        LET bpccssubsub  = baccssubsub;
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     END IF
  END IF

  -- primer nivel
  IF bpccmayor > v_cero_may AND bpccsub  > v_cero_s AND
     bpccsubsub = v_cero_ss AND bpccssubsub = v_cero_sss AND
     bpccsssubsub = v_cero_ssss THEN

     -- sector cero primer nivel
     SELECT count(*) INTO w_cuantos FROM co_balanza
     where empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = bpccsub AND
           ccsubsub   = v_cero_ss AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;

     if w_cuantos = 0 then
        SELECT sum(saldo_dia_anterior),sum(cargos_dia),
               sum(abonos_dia), sum(saldo_actual),nvl(sum(promedio_anual),0)
        into   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        from co_balanza
        where empresa     = bpempresa AND
              ccmayor     = bpccmayor AND
              ccsub       = bpccsub AND
              ccsubsub    IS NOT NULL AND
              ccssubsub   IS NOT NULL AND
              ccsssubsub  IS NOT NULL AND
              sector      IS NOT NULL AND
              ciudad     = bpciudad AND
              sucursal   = bpsucursal AND
              moneda     = bpmoneda  AND
              mes_dia    = bpmes_dia AND
              tipo_cta   = "D" AND
              usuario    = v_usuario;

        LET bpccsubsub   = v_cero_ss;
        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        --LET bpromedio_anual = (bpsaldo_dia_anterior+bpsaldo_actual)/(month(bpmes_dia));

         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsubsub  = baccsubsub;
        LET bpccssubsub  = baccssubsub;
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     END IF

     -- sector cero nivel mayor
     SELECT count(*) INTO w_cuantos FROM co_balanza
     WHERE empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = v_cero_s AND
           ccsubsub   = v_cero_ss AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        where empresa    = bpempresa AND
              ccmayor    = bpccmayor AND
              ccsub      IS NOT NULL AND
              ccsubsub   IS NOT NULL AND
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND
              ciudad     = bpciudad AND
              sucursal   = bpsucursal AND
              moneda     = bpmoneda  AND
              mes_dia    = bpmes_dia AND
              tipo_cta   = "D" AND
              usuario    = v_usuario;

        LET bpccsub      = v_cero_s;
        LET bpccsubsub   = v_cero_ss;
        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsub       = baccsub;
        LET bpccsubsub    = baccsubsub;
        LET bpccssubsub   = baccssubsub;
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     END IF
  END IF
  -- mayor nivel
  IF bpccmayor > v_cero_may AND bpccsub = v_cero_s AND
     bpccsubsub = v_cero_ss AND bpccssubsub = v_cero_sss AND
     bpccsssubsub = v_cero_ssss THEN
     -- sector cero nivel mayor
     SELECT count(*) INTO w_cuantos FROM co_balanza
     WHERE empresa    = bpempresa AND
           ccmayor    = bpccmayor AND
           ccsub      = v_cero_s AND
           ccsubsub   = v_cero_ss AND
           ccssubsub  = v_cero_sss AND
           ccsssubsub = v_cero_ssss AND
           sector     = v_cero_sect AND
           ciudad     = bpciudad AND
           sucursal   = bpsucursal AND
           moneda     = bpmoneda AND
           mes_dia    = bpmes_dia AND
           tipo_cta   IS NOT NULL AND
           usuario    = v_usuario;
     IF w_cuantos = 0 THEN
        SELECT nvl(sum(saldo_dia_anterior),0),nvl(sum(cargos_dia),0),
               nvl(sum(abonos_dia),0),nvl(sum(saldo_actual),0),nvl(sum(promedio_anual),0)
        INTO   bpsaldo_dia_anterior,bpcargos_dia,
               bpabonos_dia,bpsaldo_actual,bpromedio_anual
        FROM co_balanza
        WHERE empresa    = bpempresa AND
              ccmayor    = bpccmayor AND
              ccsub      IS NOT NULL AND
              ccsubsub   IS NOT NULL AND
              ccssubsub  IS NOT NULL AND
              ccsssubsub IS NOT NULL AND
              sector     IS NOT NULL AND
              ciudad     = bpciudad AND
              sucursal   = bpsucursal AND
              moneda     = bpmoneda  AND
              mes_dia    = bpmes_dia AND
              tipo_cta   = "D" AND
              usuario    = v_usuario;

        LET bpccsub 	 = v_cero_s;
        LET bpccsubsub   = v_cero_ss;
        LET bpccssubsub  = v_cero_sss;
        LET bpccsssubsub = v_cero_ssss;
        LET bpsector     = v_cero_sect;
        LET bptipo_cta   = "T";
        
         INSERT INTO co_balanza(empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
               sector,ciudad,sucursal,moneda,mes_dia,saldo_dia_anterior,
               cargos_dia,abonos_dia,saldo_actual,tipo_cta,naturaleza_cta,nombre,desc_sucursal,promedio_anual,usuario)
         VALUES(bpempresa,bpccmayor,bpccsub,bpccsubsub,bpccssubsub,bpccsssubsub,
               bpsector,bpciudad,bpsucursal,bpmoneda,bpmes_dia,bpsaldo_dia_anterior,
               bpcargos_dia,bpabonos_dia,bpsaldo_actual,bptipo_cta," "," "," ",bpromedio_anual,v_usuario);
        -- regresa valores originales
        LET bpccsub  = baccsub;
        LET bpccsubsub    = baccsubsub;
        LET bpccssubsub   = baccssubsub;
        LET bpccsssubsub  = baccsssubsub;
        LET bpsector      = basector;
     END IF
   END IF
END FOREACH

FOREACH
   SELECT ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,sucursal
   INTO baccmayor,baccsub,baccsubsub,baccssubsub,baccsssubsub,basector,
        bpsucursal
   FROM co_balanza
   WHERE empresa    = pempresa
     AND ccmayor    IS NOT NULL
     AND ccsub      IS NOT NULL
     AND ccsubsub   IS NOT NULL
     AND ccssubsub  IS NOT NULL
     AND ccsssubsub IS NOT NULL
     AND sector     IS NOT NULL
     AND ciudad     IS NOT NULL
     AND sucursal   IS NOT NULL
     AND moneda     IS NOT NULL
     AND mes_dia    IS NOT NULL
     AND tipo_cta   IS NOT NULL
     AND usuario    = v_usuario

   SELECT nombre,naturaleza_cta
   INTO v_nombre,v_nat
   FROM bdinteg:si_catalog
   WHERE empresa = pempresa
   AND   ccmayor = baccmayor
   AND   ccsub   = baccsub
   AND   ccsubsub = baccsubsub
   AND   ccssubsub = baccssubsub
   AND   ccsssubsub = baccsssubsub
   AND   sector = basector;

   SELECT nombre
   INTO   v_descsuc
   FROM   bdinteg:si_sucursales
   WHERE  empresa = pempresa
   AND    sucursal = bpsucursal;

   UPDATE co_balanza
      SET nombre = v_nombre,
          naturaleza_cta = v_nat,
          desc_sucursal = v_descsuc
   WHERE empresa = pempresa
   AND   ccmayor = baccmayor
   AND   ccsub   = baccsub
   AND   ccsubsub = baccsubsub
   AND   ccssubsub = baccssubsub
   AND   ccsssubsub = baccsssubsub
   AND   sector = basector
   AND   usuario = v_usuario;

END FOREACH
   FOREACH
      SELECT ccmayor,
             ccsub,
             ccsubsub,
             ccssubsub,
             ccsssubsub,
             sector,
             ciudad,
             sucursal,
             moneda,
             saldo_dia_anterior,
             cargos_dia,
             abonos_dia,
             saldo_actual
      INTO
             baccmayor,
             baccsub,
             baccsubsub,
             baccssubsub,
             baccsssubsub,
             basector,
             bpciudad,
             bpsucursal,
             bpmoneda,
             bpsaldo_dia_anterior,
             bpcargos_dia,
             bpabonos_dia,
             bpsaldo_actual
      FROM co_balanza
      WHERE empresa = pempresa
      AND   ccmayor IS NOT NULL
      AND   ccsub IS NOT NULL
      AND   ccsubsub IS NOT NULL
      AND   ccssubsub IS NOT NULL
      AND   ccsssubsub IS NOT NULL
      AND   sector IS NOT NULL
      AND   ciudad IS NOT NULL
      AND   sucursal IS NOT NULL
      AND   moneda <> '01'
      AND   mes_dia IS NOT NULL
      AND   tipo_cta IS NOT NULL
      AND   usuario = v_usuario

      IF p_val = "S" THEN
            IF p_val <> " " THEN

               SELECT nvl(preciocontable,0)
               INTO v_tpc
               FROM bdirepaut:sp_preciocontable
               WHERE moneda = bpmoneda
               AND fecha = w_fecha;

                IF v_tpc = 0 OR v_tpc IS NULL THEN
                   LET v_tpc = 0;
                END IF 
            END IF
		LET bpsaldo_dia_anterior = bpsaldo_dia_anterior * v_tpc;
		LET bpcargos_dia         = bpcargos_dia * v_tpc;
		LET bpabonos_dia         = bpabonos_dia * v_tpc;
		LET bpsaldo_actual       = bpsaldo_actual * v_tpc;
        LET bpromedio_anual      = bpromedio_anual * v_tpc;
     END IF

     IF p_val = "S" THEN
         UPDATE co_balanza
         SET saldo_dia_anterior = bpsaldo_dia_anterior,
             cargos_dia = bpcargos_dia,
             abonos_dia = bpabonos_dia,
             saldo_actual = bpsaldo_actual,
             promedio_anual = bpromedio_anual
         WHERE empresa = pempresa
         AND   ccmayor = baccmayor
         AND   ccsub   = baccsub
         AND   ccsubsub = baccsubsub
         AND   ccssubsub = baccssubsub
         AND   ccsssubsub = baccsssubsub
         AND   sector = basector
         AND   ciudad = bpciudad
         AND   sucursal = bpsucursal
         AND   moneda = bpmoneda
         AND   usuario = v_usuario;
     END IF
   END FOREACH

     IF p_val = "S" THEN
        SELECT empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, ciudad as a,
               sucursal as b, '01' as c, mes_dia, nvl(sum(saldo_dia_anterior),0) as d,
               nvl(sum(cargos_dia),0) as e, nvl(sum(abonos_dia),0) as f,
               nvl(sum(saldo_actual),0) as g, tipo_cta, naturaleza_cta,  nombre, desc_sucursal,
               '' as h, 0 as i, nvl(sum(promedio_anual),0) as j, usuario from co_balanza
        WHERE usuario = v_usuario
        GROUP BY 1,20,2,3,4,5,6,7,8,9,11,16,17,18,19,21,23 --22
        ORDER BY 1,20,2,3,4,5,6,7,8,9,11,16,17,18,19,21,23 --22
        INTO temp balan;

        DELETE FROM co_balanza
        WHERE usuario = v_usuario;

        INSERT INTO co_balanza SELECT * FROM balan;
        DROP TABLE balan;
        
     END IF

END PROCEDURE;