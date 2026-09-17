CREATE PROCEDURE "informix".ctasgiradas (v_empresa CHAR(4), v_fechainicio date,
v_fechafin date)

DEFINE tempresa           char(3);
DEFINE tauxiliar          char(12);
DEFINE tsucursal          char(4);
DEFINE tciudad            char(3);
DEFINE tccmayor           char(10);
DEFINE tccsub             char(10);
DEFINE tccsubsub          char(10);
DEFINE tccssubsub         char(10);
DEFINE tccsssubsub        char(10);
DEFINE tsector            char(10);
DEFINE tmoneda            char(2);
DEFINE tmes_dia           date;
DEFINE tsaldo_inicio_dia  money(18,2);
DEFINE tsaldo_fin_de_dia  money(18,2);

DEFINE v_cuenta           char(60);
DEFINE v_fechahoy         date;
DEFINE v_mesinicio        char(2);
DEFINE v_anoinicio        char(4);
DEFINE v_mesfin           char(2);
DEFINE v_anofin           char(4);
DEFINE v_meshoy           char(2);
DEFINE v_anohoy           char(4);

LET tempresa          = "";
LET tauxiliar         = "";
LET tsucursal         = "";
LET tciudad           = "";
LET tccmayor          = "";
LET tccsub            = "";
LET tccsubsub         = "";
LET tccssubsub        = "";
LET tccsssubsub       = "";
LET tsector           = "";
LET tmoneda           = "";
LET tmes_dia          = current;
LET v_cuenta          = "";
LET tsaldo_inicio_dia = 0;
LET tsaldo_fin_de_dia = 0;


  TRUNCATE co_ctasob;

   SELECT fecha_hoy
   INTO   v_fechahoy
   FROM   co_fechas
   WHERE  empresa = v_empresa;

   LET v_mesinicio = MONTH(v_fechainicio);
   LET v_mesfin = MONTH(v_fechafin);
   LET v_meshoy = MONTH(v_fechahoy);

   LET v_anoinicio = YEAR(v_fechainicio);
   LET v_anofin = YEAR(v_fechafin);
   LET v_anohoy = YEAR(v_fechahoy);

   IF v_mesfin = v_meshoy AND v_anofin = v_anohoy THEN
      SET ISOLATION TO DIRTY READ;
      FOREACH
         SELECT
                empresa,
                ccmayor,
                ccsub,
                ccsubsub,
                ccssubsub,
                ccsssubsub,
                sector,
                ciudad,
                sucursal,
                moneda,
                mes_dia,
                saldo_inicio_dia,
                saldo_fin_de_dia
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
                tmoneda,
                tmes_dia,
                tsaldo_inicio_dia,
                tsaldo_fin_de_dia
           FROM co_sdodias
           WHERE empresa = v_empresa
                and saldo_fin_de_dia < 0
                and mes_dia
                between v_fechainicio and v_fechafin

           LET v_cuenta= trim(tccmayor)||trim(tccsub)||trim(tccsubsub)||
               trim(tccssubsub)||trim(tccsssubsub)||trim(tsector);

           INSERT INTO co_ctasob
               (empresa,
                cuenta,
                ccmayor,
                ccsub,
                ccsubsub,
                ccssubsub,
                ccsssubsub,
                sector,
                auxiliar,
                ciudad,
                sucursal,
                moneda,
                mes_dia,
                saldo_inicio_dia,
                saldo_fin_de_dia)
          VALUES
               (tempresa,
                v_cuenta,
                tccmayor,
                tccsub,
                tccsubsub,
                tccssubsub,
                tccsssubsub,
                tsector,
                '',
                tciudad,
                tsucursal,
                tmoneda,
                tmes_dia,
                tsaldo_inicio_dia,
                tsaldo_fin_de_dia);
      END FOREACH

      FOREACH
         SELECT
                empresa,
                ccmayor,
                ccsub,
                ccsubsub,
                ccssubsub,
                ccsssubsub,
                sector,
                auxiliar,
                ciudad,
                sucursal,
                moneda,
                mes_dia,
                saldo_inicio_dia,
                saldo_fin_de_dia
       INTO
                tempresa,
                tccmayor,
                tccsub,
                tccsubsub,
                tccssubsub,
                tccsssubsub,
                tsector,
                tauxiliar,
                tciudad,
                tsucursal,
                tmoneda,
                tmes_dia,
                tsaldo_inicio_dia,
                tsaldo_fin_de_dia
           FROM co_diasaux
           WHERE empresa = v_empresa
                and saldo_fin_de_dia < 0
                and mes_dia
                between v_fechainicio and v_fechafin

           LET v_cuenta= trim(tccmayor)||trim(tccsub)||trim(tccsubsub)||
               trim(tccssubsub)||trim(tccsssubsub)||trim(tsector);

           INSERT INTO co_ctasob
               (empresa,
                cuenta,
                ccmayor,
                ccsub,
                ccsubsub,
                ccssubsub,
                ccsssubsub,
                sector,
                auxiliar,
                ciudad,
                sucursal,
                moneda,
                mes_dia,
                saldo_inicio_dia,
                saldo_fin_de_dia)
          VALUES
               (tempresa,
                v_cuenta,
                tccmayor,
                tccsub,
                tccsubsub,
                tccssubsub,
                tccsssubsub,
                tsector,
                tauxiliar,
                tciudad,
                tsucursal,
                tmoneda,
                tmes_dia,
                tsaldo_inicio_dia,
                tsaldo_fin_de_dia);
      END FOREACH
   END IF

   IF (v_anoinicio < v_anohoy) OR  (v_mesinicio < v_meshoy AND v_anoinicio = v_anohoy) THEN
      SET ISOLATION TO DIRTY READ;

      FOREACH
         SELECT
                empresa,
                ccmayor,
                ccsub,
                ccsubsub,
                ccssubsub,
                ccsssubsub,
                sector,
                ciudad,
                sucursal,
                moneda,
                mes_dia,
                saldo_inicio_dia,
                saldo_fin_de_dia
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
                tmoneda,
                tmes_dia,
                tsaldo_inicio_dia,
                tsaldo_fin_de_dia
           FROM co_histsdodias
           WHERE empresa = v_empresa
                and saldo_fin_de_dia < 0
                and mes_dia
                between v_fechainicio and v_fechafin

           LET v_cuenta= trim(tccmayor)||trim(tccsub)||trim(tccsubsub)||
               trim(tccssubsub)||trim(tccsssubsub)||trim(tsector);

           INSERT INTO co_ctasob
               (empresa,
                cuenta,
                ccmayor,
                ccsub,
                ccsubsub,
                ccssubsub,
                ccsssubsub,
                sector,
                auxiliar,
                ciudad,
                sucursal,
                moneda,
                mes_dia,
                saldo_inicio_dia,
                saldo_fin_de_dia)
          VALUES
               (tempresa,
                v_cuenta,
                tccmayor,
                tccsub,
                tccsubsub,
                tccssubsub,
                tccsssubsub,
                tsector,
                '',
                tciudad,
                tsucursal,
                tmoneda,
                tmes_dia,
                tsaldo_inicio_dia,
                tsaldo_fin_de_dia);
      END FOREACH

      FOREACH
         SELECT
                empresa,
                ccmayor,
                ccsub,
                ccsubsub,
                ccssubsub,
                ccsssubsub,
                sector,
                auxiliar,
                ciudad,
                sucursal,
                moneda,
                mes_dia,
                saldo_inicio_dia,
                saldo_fin_de_dia
       INTO
                tempresa,
                tccmayor,
                tccsub,
                tccsubsub,
                tccssubsub,
                tccsssubsub,
                tsector,
                tauxiliar,
                tciudad,
                tsucursal,
                tmoneda,
                tmes_dia,
                tsaldo_inicio_dia,
                tsaldo_fin_de_dia
           FROM co_histdiasaux
           WHERE empresa = v_empresa
                and saldo_fin_de_dia < 0
                and mes_dia
                between v_fechainicio and v_fechafin

           LET v_cuenta= trim(tccmayor)||trim(tccsub)||trim(tccsubsub)||
               trim(tccssubsub)||trim(tccsssubsub)||trim(tsector);

           INSERT INTO co_ctasob
               (empresa,
                cuenta,
                ccmayor,
                ccsub,
                ccsubsub,
                ccssubsub,
                ccsssubsub,
                sector,
                auxiliar,
                ciudad,
                sucursal,
                moneda,
                mes_dia,
                saldo_inicio_dia,
                saldo_fin_de_dia)
          VALUES
               (tempresa,
                v_cuenta,
                tccmayor,
                tccsub,
                tccsubsub,
                tccssubsub,
                tccsssubsub,
                tsector,
                tauxiliar,
                tciudad,
                tsucursal,
                tmoneda,
                tmes_dia,
                tsaldo_inicio_dia,
                tsaldo_fin_de_dia);
      END FOREACH
   END IF
END PROCEDURE;