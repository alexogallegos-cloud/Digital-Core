CREATE PROCEDURE "informix".sp_repctacapmensualinv()
    
    RETURNING CHAR(5);

    DEFINE cNumcte              CHAR(20);
    DEFINE cProd                CHAR(4);
    DEFINE cCuenta              CHAR(20);
    DEFINE cTarjeta             CHAR(20);
    DEFINE mSaldo_actual        money;
    DEFINE mSaldo_disponible    money;
    DEFINE cSuc                 CHAR(4);
    DEFINE mSaldo_corte         money;
    DEFINE iStatus_cta          integer;
    DEFINE mMonto_apertura      money;
    DEFINE mTasa_bruta          money;
    DEFINE iReinversion         char(1);
    DEFINE iPlazo_inversion     integer;
    DEFINE mISR                 money;
    DEFINE dFecha_apertura      DATE;
    DEFINE dFecha_vencimiento   DATE;
    DEFINE mInteres_bruto       money;
    DEFINE mInteres_neto        money;
    DEFINE mPremio              money;
    DEFINE dtHora               DATETIME HOUR TO FRACTION(3);
    DEFINE mMonto               MONEY;
    DEFINE p_cod_ret            VARCHAR(5);
    DEFINE error_info           VARCHAR(80);
    DEFINE p_mensaje            VARCHAR(80);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
    DEFINE nComit               INTEGER;
    DEFINE nCont                INTEGER;
    DEFINE nCont2               INTEGER;
    DEFINE dfecha_hoy           DATE;
    DEFINE cFechaNomArc         CHAR(10);
    DEFINE cAnio                CHAR(4);
    DEFINE cMes                 CHAR(2);
    DEFINE cDia                 CHAR(2);
    DEFINE cNom                 CHAR(40);
    DEFINE vSql                 CHAR(600);
    DEFINE cStatus_tar          CHAR(3);
    DEFINE cVRein               CHAR(2);
    DEFINE cVRein2              CHAR(2);
    DEFINE vmaxcta              CHAR(20);
    DEFINE vmincta              CHAR(20);


    BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
    LET p_cod_ret = sql_err;
    LET p_mensaje = error_info;
    IF nComit = 1 THEN
    ROLLBACK WORK;
    END IF;
    RETURN p_cod_ret;
    END EXCEPTION;

    -- Set debug file To '/tmp/sp_repctacapmensualinv.out';
    -- Trace On;

    LET cNumcte = '';
    LET cProd = '';
    LET cCuenta = '';
    LET cTarjeta = '';
    LET mSaldo_actual = '0';
    LET mSaldo_disponible = '0';
    LET cSuc = '';
    LET mSaldo_corte = '0';
    LET iStatus_cta = '';
    LET mMonto_apertura = '0';
    LET mTasa_bruta = '0';
    LET iReinversion = '';
    LET iPlazo_inversion = '';
    LET mISR = '0';
    LET dFecha_apertura = '';
    LET dFecha_vencimiento = '';
    LET mInteres_bruto = '0';
    LET mInteres_neto = '0';
    LET mPremio = '';
    LET dtHora = '';
    LET p_cod_ret = '00000';
    LET sql_err = '0';
    LET isam_err = '0';
    LET error_info = '';
    LET p_mensaje = '';
    LET nComit = 0;
    LET nCont = 0;
    LET nCont2 = 0;
    LET dfecha_hoy = '';
    LET cFechaNomArc = '';
    LET cAnio = '';
    LET cMes = '';
    LET cDia = '';
    LET cNom = '';
    LET vSql = '';
    LET cVRein = '';
    LET cVRein2 = '';

    BEGIN WORK;
    LET nComit = 1;
    
    -- // Proceso de cuando se debe o en k rango generar la informacion
    UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repctacapmensual;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM bdinvers:sv_maeinv;

    FOREACH with hold
        Select inv.num_cte, inv.cod_instrum, inv.cuenta, inv.capital, inv.capital - (inv.sdo_retenido + inv.sdo_cong) as saldo_disponible,
               inv.sucursal, inv.status_cta, inv.capital, inv.tasa, inv.plazo, inv.isr, inv.fecha_alta, fecha_venc, inv.intereses, inv.intereses-inv.isr
          Into cNumcte,cProd,cCuenta, mSaldo_actual,mSaldo_disponible,
               cSuc,iStatus_cta,mMonto_apertura,mTasa_bruta,iPlazo_inversion,mISR, dFecha_apertura,dFecha_vencimiento, mInteres_bruto,mInteres_neto
          From bdinvers:sv_maeinv inv
         Where inv.empresa = '001'
           And inv.cuenta BETWEEN vmincta AND vmaxcta
           And inv.secuencia = (Select max(secuencia)
                                  From bdinvers:sv_maeinv
                                 Where empresa = inv.empresa
                                   And cuenta = inv.cuenta)

        LET iReinversion = '';
        LET cVRein = '';
        LET cVRein2 = '';

        Select ma.inst_vento 
          Into cVRein
          From bdinvers:sv_maeinstrucc ma,
         Outer bdinvers:sv_instrucc ins
         Where cuenta = cCuenta
           And ins.codigo = ma.inst_vento
           And cap_int = 'C';

        Select ma.inst_vento 
          Into cVRein2
          From bdinvers:sv_maeinstrucc ma,
         OUTER bdinvers:sv_instrucc ins
         Where cuenta = cCuenta
           And  ins.codigo = ma.inst_vento
           And cap_int = 'I';

        IF (cVRein = '') or(cVRein2 = '')  THEN
            Let iReinversion = '';
        END IF;
        
        IF (cVRein = 01) AND(cVRein2 = 01)  THEN
            Let iReinversion = '1';
        END IF;
        
        IF (cVRein = 01) AND(cVRein2 = 02)  THEN
            Let iReinversion = '2';
        END IF;
        
        IF (cVRein = 02) AND(cVRein2 = 02)  THEN
            Let iReinversion = '3';
        END IF;

        INSERT INTO bdicheq:sc_repctacapmensual (num_cte, producto, cuenta, num_tarjeta, saldo_actual, saldo_disponible, sucursal,
        saldoalcorte, status_cta, monto_apertura, tasa_bruta, reinversion,plazo_inversion, isr,fecha_apertura,fecha_vencimiento,
        interes_bruto, interes_neto, premio_meta)
        VALUES (cNumcte,cProd,cCuenta,cTarjeta,mSaldo_actual,mSaldo_disponible,cSuc,mSaldo_corte,iStatus_cta,mMonto_apertura,
                mTasa_bruta,iReinversion,iPlazo_inversion,mISR,dFecha_apertura,dFecha_vencimiento,mInteres_bruto,mInteres_neto,mPremio);
        --saldoalcorte, status_cta, monto_apertura, tasa_bruta, reinversion,plazo_inversion, isr,fecha_apertura,fecha_vencimiento,
        --interes_bruto, interes_neto, premio_meta);

        LET nCont = nCont + 1;
        LET nCont2 = nCont2 + 1;

        -- // Realiza comint cada 5000 registros
        IF nComit = 1 AND nCont = 5000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET nComit = 1;
            LET nCont = 0;
        END IF;
        
        -- // Realiza un statistics cada 50000 registros
        IF nCont2 = 50000 THEN
            UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repctacapmensual;
            LET nCont2 = 0;
        END IF;
    END FOREACH;

    COMMIT WORK;
    LET nComit =0;

    RETURN p_cod_ret;

    END;
    
END PROCEDURE
DOCUMENT
    'DESCRIPCION: Programa que se encarga de generar el reporte de cuentas para carteras mensual, base de datos inversiones',
    'se creo la tabla bdicheq:sc_repctacapmensual, que es la tabla que se llenara para tomar los datos para generar el archivo',
    'AUTOR: Jesus Antonio Bastidas Lopez',
    'FECHA: Diciembre/2008',
    'BD: Bdicheq';

CREATE PROCEDURE "informix".sp_repmovcarterasdiario()
    
    RETURNING CHAR(5);

    DEFINE cNumcte      CHAR(20);
    DEFINE cTarjeta     CHAR(20);
    DEFINE cSuc         CHAR(4);
    DEFINE cTransacc    CHAR(4);
    DEFINE cProd        CHAR(4);
    DEFINE cCuenta      CHAR(20);
    DEFINE dFecha       DATE;
    DEFINE dtHora       DATETIME HOUR TO FRACTION(3);
    DEFINE mMonto       MONEY;
    DEFINE p_cod_ret    VARCHAR(5);
    DEFINE error_info   VARCHAR(80);
    DEFINE p_mensaje    VARCHAR(80);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE nComit       INTEGER;
    DEFINE nCont        INTEGER;
    DEFINE nCont2       INTEGER;
    DEFINE dfecha_hoy   DATE;
    DEFINE cFechaNomArc CHAR(10);
    DEFINE cAnio        CHAR(4);
    DEFINE cMes         CHAR(2);
    DEFINE cDia         CHAR(2);
    DEFINE cNom         CHAR(40);
    DEFINE vSql         CHAR(600);
    DEFINE cStatus_tar  CHAR(3);
    DEFINE dFecha_ant   DATE;
    DEFINE cValorIP     CHAR(20);

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET p_cod_ret = sql_err;
        LET p_mensaje = error_info;
        IF nComit = 1 THEN
            ROLLBACK WORK;
        END IF;
        RETURN p_cod_ret;
    END EXCEPTION;

    -- Set debug file To '/tmp/sp_repmovcarterasdiario.out';
    -- Trace On;

    LET cNumcte = '';
    LET cTarjeta = '';
    LET cSuc = '';
    LET cTransacc = '';
    LET cProd = '';
    LET cCuenta = '';
    LET dFecha = '';
    LET dtHora = '';
    LET mMonto = '0';
    LET p_cod_ret = '00000';
    LET sql_err = '0';
    LET isam_err = '0';
    LET error_info = '';
    LET p_mensaje = '';
    LET nComit = 0;
    LET nCont = 0;
    LET nCont2 = 0;
    LET dfecha_hoy = '';
    LET cFechaNomArc = '';
    LET cAnio = '';
    LET cMes = '';
    LET cDia = '';
    LET cNom = '';
    LET vSql = '';
    LET dFecha_ant  = '';
    LET cValorIP = '';

    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sc_repmovcarterasdiario') THEN
        DROP TABLE bdicheq:sc_repmovcarterasdiario;
        CREATE RAW TABLE bdicheq:sc_repmovcarterasdiario(
            num_cte CHAR(20),  
            num_tarjeta CHAR(20), 
            sucursal CHAR(4), 
            transaccion CHAR(4),
            producto CHAR(4), 
            cuenta CHAR(20), 
            fecha_mov DATE,  
            hora_mov DATETIME HOUR TO FRACTION(3) ,
            monto_mov MONEY);
    ELSE 
        CREATE RAW TABLE bdicheq:sc_repmovcarterasdiario(
            num_cte CHAR(20),  
            num_tarjeta CHAR(20), 
            sucursal CHAR(4), 
            transaccion CHAR(4),
            producto CHAR(4), 
            cuenta CHAR(20), 
            fecha_mov DATE,  
            hora_mov DATETIME HOUR TO FRACTION(3) ,
            monto_mov MONEY);
    END IF;
    
    UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterasdiario;

    BEGIN WORK;
    LET nComit = 1;

    SELECT fecha_hoy
      INTO dfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';

    -- // Selecciona la fecha de ultima ejecucion del proceso
    SELECT max(fecha_ejecucion) 
      INTO dFecha_ant
      FROM bdicheq:sc_ctrrepcarteras
     WHERE proceso = 'sp_RepMovCarterasDiario';

    IF dFecha_ant = dfecha_hoy THEN
        LET p_cod_ret = 100;  --Ya se ejecuto proceso en mismo dia
        ROLLBACK WORK;
        RETURN p_cod_ret;
    END IF;

    -- // Reguistra la fecha de ultima ejecucion en tabla de control de procesos
    INSERT INTO bdicheq:sc_ctrrepcarteras (proceso,fecha_ejecucion)
    VALUES('sp_RepMovCarterasDiario',dfecha_hoy);

    SELECT NVL(valor, '') 
      INTO cValorIP
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'ipptebanco';

    IF cValorIP = ''  THEN
        LET p_cod_ret = "110"; --DATOS INCOMPLETOS
        ROLLBACK WORK;
        RETURN p_cod_ret;
    END IF;

    FOREACH with hold
        SELECT {+INDEX(sc_movhis idx_movhisnew1)}
               mae.num_cte, nvl(mov.num_tarjeta, ''), nvl(mov.sucursal, ''), 
               mov.transacc, mov.producto, mov.cuenta, mov.fech_alt, mov.fech_hor, mov.monto_tot
          INTO cNumcte, cTarjeta, cSuc, cTransacc, cProd, cCuenta, dFecha, dtHora, mMonto
          FROM bdicheq:sc_movhis mov,
               bdicheq:sc_maechq mae
      -- INNER JOIN bdicheq:sc_maechq mae ON (mov.cuenta = mae.cuenta)
         WHERE mov.empresa = '001'
           AND mov.cuenta = mae.cuenta
           AND mov.fech_alt >= dFecha_ant 
           AND mov.fech_alt < dfecha_hoy
           AND mov.cancelad <> 'S'
           AND mae.empresa = mov.empresa
           AND mae.cuenta = mov.cuenta

        INSERT INTO bdicheq:sc_repmovcarterasdiario (num_cte,num_tarjeta,sucursal,transaccion,producto,cuenta,fecha_mov,hora_mov,monto_mov)
        VALUES(cNumcte, cTarjeta, cSuc, cTransacc, cProd, cCuenta, dFecha, dtHora, mMonto);

        LET nCont = nCont + 1;
        LET nCont2 = nCont2 + 1;

        -- // Realiza comint cada 5000 registros
        IF nComit = 1 AND nCont = 5000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET nComit = 1;
            LET nCont = 0;
        END IF;
        
        -- // Realiza un statistics cada 50000 registros
        IF nCont2 = 50000 THEN
            UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterasdiario;
            LET nCont2 = 0;
        END IF;
    END FOREACH;

    COMMIT WORK;
    LET nComit = 0;

    CALL sp_repvovcarterasinvdiario() 
    RETURNING p_cod_ret;

    -- ALTER TABLE bdicheq:sc_repmovcarterasdiario type (standard);
    CREATE INDEX idxrepcartdia ON bdicheq:sc_repmovcarterasdiario (num_cte) USING BTREE;
    UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterasdiario;

    LET canio = Year(dfecha_hoy);
    LET cmes = lpad(Month(dfecha_hoy),2,'0');
    LET cdia = lpad(Day(dfecha_hoy),2,'0');

    LET cnom= "Cm"||cdia||cmes||canio||".txt";

    LET vsql = '';
    LET  vsql = 'echo "UNLOAD TO ' || ("/tmp/"||trim(cnom)) ||
                ' SELECT num_cte, num_tarjeta, sucursal, transaccion, producto, cuenta, fecha_mov,'||
                ' hora_mov, monto_mov FROM bdicheq:sc_repmovcarterasdiario;" > /tmp/query.sql';
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = "dbaccess bdicheq /tmp/query.sql ";
    SYSTEM vsql;

    LET vsql = '';   -- Se copia Archivo a directorio de carteras en PB
    LET vsql = "scp /tmp/"|| trim(cnom) || " sysnomina@" ||Trim (cValorIP)||":/sysx/progs/archivoscartera";
    SYSTEM vsql;

    LET vsql = '';  --Se borra archivo una vez generado
    LET vsql = "rm -rf /tmp/" || trim(cnom);
    SYSTEM vsql;

    -- // Borro index
    -- DROP INDEX idxrepcartdia;

    RETURN p_cod_ret;

    END;
    
END PROCEDURE
DOCUMENT
    'DESCRIPCION: Programa que se encarga de generar el reporte de movimientos diarios para carteras',
    'se creo la tabla bdicheq:sc_RepMovCarterasDiario, que es la tabla que se llenara para tomar los datos para generar el archivo',
    'AUTOR: Armando Mercado, Clemente Angulo',
    'FECHA: Diciembre/2008',
    'BD: Bdicheq';

CREATE PROCEDURE "informix".sp_repmovcarterashist(pFechaIni DATE, pFechaFin DATE)

    RETURNING CHAR(5);

    DEFINE         cNumcte                    CHAR(20);
    DEFINE         cTarjeta                   CHAR(20);
    DEFINE         cSuc                       CHAR(4);
    DEFINE         cTransacc                  CHAR(4);
    DEFINE         cProd                      CHAR(4);
    DEFINE         cCuenta                    CHAR(20);
    DEFINE         dFecha                     DATE;
    DEFINE         dtHora                     DATETIME HOUR TO FRACTION(3);
    DEFINE         mMonto                     MONEY;
    DEFINE         p_cod_ret                  VARCHAR(5);
    DEFINE         error_info                 VARCHAR(80);
    DEFINE         p_mensaje                  VARCHAR(80);
    DEFINE         sql_err                    INTEGER;
    DEFINE         isam_err                   INTEGER;
    DEFINE         nComit                     INTEGER;
    DEFINE         nCont                      INTEGER;
    DEFINE         nCont2                     INTEGER;
    DEFINE         dfecha_hoy                 DATE;
    DEFINE         cFechaNomArc               CHAR(10);
    DEFINE         cAnio                      CHAR(4);
    DEFINE         cMes                       CHAR(2);
    DEFINE         cDia                       CHAR(2);
    DEFINE         cNom                       CHAR(40);
    DEFINE         vSql                       CHAR(600);
    DEFINE         cValorIP                   CHAR(20);

    -- Set debug file to '/tmp/sp_repmovcarterashist.out';
    -- trace on;

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, error_info
        LET p_cod_ret = sql_err;
        LET p_mensaje = error_info;
        IF nComit = 1 THEN
            ROLLBACK WORK;
        END IF;
        RETURN p_cod_ret;
    END EXCEPTION;

    LET cNumcte = '';
    LET cTarjeta = '';
    LET cSuc = '';
    LET cTransacc = '';
    LET cProd = '';
    LET cCuenta = '';
    LET dFecha = '';
    LET dtHora = '';
    LET mMonto = '0';
    LET p_cod_ret = '00000';
    LET sql_err = '0';
    LET isam_err = '0';
    LET error_info = '';
    LET p_mensaje = '';
    LET nComit = 0;
    LET nCont = 0;
    LET nCont2 = 0;
    LET dfecha_hoy = '';
    LET cFechaNomArc = '';
    LET cAnio = '';
    LET cMes = '';
    LET cDia = '';
    LET cNom = '';
    LET vSql = '';
    LET cValorIP = '';

    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sc_repmovcarterashist') THEN
        DROP TABLE bdicheq:sc_repmovcarterashist;
        CREATE RAW TABLE bdicheq:sc_repmovcarterashist(
            num_cte CHAR(20),  
            num_tarjeta CHAR(20), 
            sucursal CHAR(4), 
            transaccion CHAR(4),
            producto CHAR(4), 
            cuenta CHAR(20), 
            fecha_mov DATE,  
            hora_mov DATETIME HOUR TO FRACTION(3) ,
            monto_mov MONEY);
    ELSE
        CREATE RAW TABLE bdicheq:sc_repmovcarterashist(
            num_cte CHAR(20),  
            num_tarjeta CHAR(20), 
            sucursal CHAR(4), 
            transaccion CHAR(4),
            producto CHAR(4), 
            cuenta CHAR(20), 
            fecha_mov DATE,  
            hora_mov DATETIME HOUR TO FRACTION(3) ,
            monto_mov MONEY);
    END IF;
    
    UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterashist;

    BEGIN WORK;
    LET nComit = 1;

    -- // Valida parametros de entrada
    IF (pFechaIni = '') OR (pFechaFin = '') OR (pFechaIni IS NULL) OR (pFechaFin IS NULL)  THEN
        LET p_cod_ret = "110"; --DATOS INCOMPLETOS
        ROLLBACK WORK;
        RETURN p_cod_ret;
    END IF;
    
    IF pFechaFin <= pFechaIni THEN --Error en fechas
        LET p_cod_ret = "100"; -- Fecha inicial mayor a fecha final
        ROLLBACK WORK;
        RETURN p_cod_ret;
    END IF;

    SELECT NVL(valor, '') 
      INTO cValorIP
      FROM bdicheq:sc_param
     WHERE empresa = '001' 
       AND codparam = 'ipptebanco';

    IF cValorIP = ''  THEN
        LET p_cod_ret = "110"; --DATOS INCOMPLETOS
        ROLLBACK WORK;
        RETURN p_cod_ret;
    END IF;

    FOREACH	WITH HOLD
        SELECT {+INDEX(sc_movhis idx_movhisnew1)}
               mae.num_cte, NVL(mov.num_tarjeta, ''), NVL(mov.sucursal, ''), mov.transacc, 
               mov.producto, mov.cuenta, mov.fech_alt, mov.fech_hor, mov.monto_tot
          INTO cNumcte, cTarjeta, cSuc, cTransacc, cProd, cCuenta, dFecha, dtHora, mMonto
          FROM bdicheq:sc_movhis mov,
               bdicheq:sc_maechq mae
      -- INNER JOIN bdicheq:sc_maechq mae ON (mov.cuenta = mae.cuenta)
         WHERE mov.empresa = '001'
           AND mov.cuenta = mae.cuenta
           AND mov.fech_alt >= pFechaIni 
           AND mov.fech_alt <= pFechaFin
           AND mov.cancelad <> 'S'
           AND mae.empresa = mov.empresa
           AND mae.cuenta = mov.cuenta

        INSERT INTO bdicheq:sc_repmovcarterashist (num_cte, num_tarjeta, sucursal, transaccion, producto, cuenta, fecha_mov, hora_mov, monto_mov)
        VALUES(cNumcte, cTarjeta, cSuc, cTransacc, cProd, cCuenta, dFecha, dtHora, mMonto);

        LET nCont = nCont + 1;
        LET nCont2 = nCont2 + 1;

        IF nComit = 1 AND nCont = 5000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET nComit = 1;
            LET nCont = 0;
        END IF;
        
        IF nCont2 = 50000 THEN
            UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterashist;
            LET nCont2 = 0;
        END IF;
    END FOREACH;

    COMMIT WORK;
    LET nComit = 0;

    -- ALTER TABLE bdicheq:sc_repmovcarterashist type (standard);
    CREATE INDEX idxrepmovcarthist ON bdicheq:sc_repmovcarterashist(num_cte) USING BTREE;
    UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterashist;

    LET cFechaNomArc = to_char(pFechaFin, "%Y/%m/%d" );
    LET canio = cFechaNomArc[1,4];
    LET cmes = cFechaNomArc[6,7];
    LET cdia = cFechaNomArc[9,10];

    LET cnom = "Cmh"||cdia||cmes||canio||".txt";

    LET vsql = '';
    LET vsql = 'echo "UNLOAD TO /tmp/'||TRIM(cnom) ||
               ' SELECT num_cte, num_tarjeta, sucursal, transaccion, producto, cuenta, fecha_mov, '||
               ' hora_mov, monto_mov FROM bdicheq:sc_repmovcarterashist;" > /tmp/query_repmovcarterashist.sql';
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = "dbaccess bdicheq /tmp/query_repmovcarterashist.sql";
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = "scp /tmp/"|| trim(cnom) || " sysnomina@" ||Trim (cValorIP)||":/sysx/progs/archivoscartera";
    SYSTEM vsql;

    LET vsql = '';
    LET vsql = "rm -rf /tmp/" || trim(cnom);
    SYSTEM vsql;

    LET vsql = '';

    -- DROP INDEX idxrepmovcarthist;

    RETURN p_cod_ret;
    
    END;
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Programa que se encarga de generar el reporte de movimientos para carteras en modo historico por medio de la identificacion',
'de un periodo. Ademas, se creo la tabla bdicheq:sc_repmovcarterashist, que es la tabla que se llenara para tomar los datos para generar el archivo',
'AUTOR: Clemente Angulo',
'FECHA: 11/Diciembre/2008',
'BD: Bdicheq';

CREATE PROCEDURE "informix".sp_repmovcarterasinvdiario()
    
    RETURNING CHAR(5);

    DEFINE cNumcte      CHAR(20);
    DEFINE cTarjeta     CHAR(20);
    DEFINE cSuc         CHAR(4);
    DEFINE cTransacc    CHAR(4);
    DEFINE cProd        CHAR(4);
    DEFINE cCuenta      CHAR(20);
    DEFINE dFecha       DATE;
    DEFINE dtHora       DATETIME HOUR TO FRACTION(3);
    DEFINE mMonto       MONEY;
    DEFINE p_cod_ret    VARCHAR(5);
    DEFINE error_info   VARCHAR(80);
    DEFINE p_mensaje    VARCHAR(80);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE nComit       INTEGER;
    DEFINE nCont        INTEGER;
    DEFINE nCont2       INTEGER;
    DEFINE dfecha_hoy   DATE;
    DEFINE cFechaNomArc CHAR(10);
    DEFINE cAnio        CHAR(4);
    DEFINE cMes         CHAR(2);
    DEFINE cDia         CHAR(2);
    DEFINE cNom         CHAR(40);
    DEFINE vSql         CHAR(600);
    DEFINE cStatus_tar  CHAR(3);
    DEFINE dFecha_ant   DATE;
    DEFINE cValorIP     CHAR(20);
    DEFINE vmaxcta      CHAR(20);
    DEFINE vmincta      CHAR(20);

    BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
    LET p_cod_ret = sql_err;
    LET p_mensaje = error_info;
    IF nComit = 1 THEN
    ROLLBACK WORK;
    END IF;
    RETURN p_cod_ret;
    END EXCEPTION;

    -- Set debug file To '/tmp/sp_repmovcarterasinvdiario.out';
    -- Trace On;

    LET cNumcte = '';
    LET cTarjeta = '';
    LET cSuc = '';
    LET cTransacc = '';
    LET cProd = '';
    LET cCuenta = '';
    LET dFecha = '';
    LET dtHora = '';
    LET mMonto = '0';
    LET p_cod_ret = '00000';
    LET sql_err = '0';
    LET isam_err = '0';
    LET error_info = '';
    LET p_mensaje = '';
    LET nComit = 0;
    LET nCont = 0;
    LET nCont2 = 0;
    LET dfecha_hoy = '';
    LET cFechaNomArc = '';
    LET cAnio = '';
    LET cMes = '';
    LET cDia = '';
    LET cNom = '';
    LET vSql = '';
    LET dFecha_ant  = '';
    LET cValorIP = '';

    UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterasdiario;

    BEGIN WORK;
    LET nComit = 1;

    SELECT fecha_hoy
      INTO dfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';

    -- // Selecciona la fecha de ultima ejecucion del proceso
    SELECT max(fecha_ejecucion) 
      INTO dFecha_ant
      FROM bdicheq:sc_ctrrepcarteras
     WHERE proceso = 'sp_RepMovCarterasInvDiario';

    IF dFecha_ant = dfecha_hoy THEN
        LET p_cod_ret = 100;  --Ya se ejecuto proceso en mismo dia
        ROLLBACK WORK;
        RETURN p_cod_ret;
    END IF;

    -- // Reguistra la fecha de ultima ejecucion en tabla de control de procesos
    INSERT INTO bdicheq:sc_ctrrepcarteras (proceso,fecha_ejecucion)
    VALUES('sp_RepMovCarterasInvDiario',dfecha_hoy);
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM bdinvers:sv_movhis;

    FOREACH with hold
        SELECT '', nvl(mov.sucursal, ''), mov.transacc, mov.cod_instrum, 
               mov.cuenta, mov.fech_alt, mov.fech_hor, mov.monto_tot
          INTO cTarjeta, cSuc, cTransacc, cProd, cCuenta, dFecha, dtHora, mMonto
          FROM bdinvers:sv_movhis mov        
         WHERE mov.empresa = '001'
           AND mov.cuenta BETWEEN vmincta AND vmaxcta
           AND mov.fech_alt >= dFecha_ant 
           AND mov.fech_alt < dfecha_hoy

        SELECT limit 1 trim(nvl(num_cte, '')) 
          INTO cNumcte
          FROM bdinvers:sv_maeinv
         WHERE empresa = '001' 
           AND cuenta = cCuenta;

        INSERT INTO bdicheq:sc_repmovcarterasdiario (num_cte,num_tarjeta,sucursal,transaccion,producto,cuenta,fecha_mov,hora_mov,monto_mov)
        VALUES(cNumcte, cTarjeta, cSuc, cTransacc, cProd, cCuenta, dFecha, dtHora, mMonto);

        LET nCont = nCont + 1;
        LET nCont2 = nCont2 + 1;

        -- // Realiza comint cada 5000 registros
        IF nComit = 1 AND nCont = 5000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET nComit = 1;
            LET nCont = 0;
        END IF;
        
        -- // Realiza un statistics cada 50000 registros 
        IF nCont2 = 50000 THEN
            UPDATE STATISTICS medium FOR TABLE bdicheq:sc_repmovcarterasdiario;
            LET nCont2 = 0;
        END IF;
    END FOREACH;

    COMMIT WORK;
    LET nComit = 0;    

    RETURN p_cod_ret;

    END;

END PROCEDURE
DOCUMENT
    'DESCRIPCION: Programa que se encarga de generar el reporte de movimientos diarios de Inversiones para carteras',
    'se creo la tabla bdicheq:sc_RepMovCarterasDiario, que es la tabla que se llenara para tomar los datos para generar el archivo',
    'AUTOR: Armando Mercado',
    'FECHA: Enero/2009',
    'BD: Bdicheq',
    'REGISTROS X MINUTO: 19,800 En ambiente de desarrollo';

create procedure "informix".cal_fecharet( pfechaofi  date )
    RETURNING char(5), date;  

    DEFINE v_codret         char(5);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;  
    DEFINE v_fechapre       date;
    DEFINE v_esferiadox     char(1); 

    LET v_codret = "000";
    LET v_fechapre = " ";

    BEGIN

    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            return v_codret,v_fechapre;
        end if;
    end exception;

    -- set debug file to "cal_fecharet.txt";
    -- trace on;
    
    set isolation to dirty read;

    -- // Valida la informacion de entrada
    IF pfechaofi is null THEN
        -- // Datos de entrada incompletos
        LET v_codret = 210; 
        RETURN v_codret, v_fechapre; 
    END IF;

    -- // Validar feriado, sab o dom
    select "1"
      into v_esferiadox
      from bdinteg:si_feriado
     where fecha = pfechaofi;

    IF v_esferiadox is null THEN
        LET v_esferiadox = "0";
    END IF

    -- // Cuando es feriado, sab, dom o fuera de horario se pasa al sig habil
    IF v_esferiadox = "1" or 
       to_char(pfechaofi, "%A") = "Saturday" or 
       to_char(pfechaofi, "%A") = "Sunday" THEN 
        -- // Calcular la fecha correcta
        
        call cal_fecha_pre_fh(pfechaofi)
        returning v_codret, v_fechapre;	
        
        RETURN v_codret, v_fechapre;
    END IF

    LET v_fechapre = pfechaofi;	

    END;    

    RETURN v_codret,v_fechapre;

END PROCEDURE;