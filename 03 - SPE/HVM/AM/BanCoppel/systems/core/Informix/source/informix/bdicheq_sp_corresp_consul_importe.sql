CREATE PROCEDURE "informix".sp_corresp_consul_importe(pEmpresa CHAR(3),
                                                      pPeriodo CHAR(6))
RETURNING CHAR(6)       AS cod_ret,
          CHAR(80)      AS mensaje_ret,
          CHAR(7)       AS periodo,
          MONEY(18,2)   AS captacion_mes_ant,
          MONEY(18,2)   AS captacion_promedio,
          DECIMAL(18,2) AS parametro_limite,
          MONEY(20,2)   AS limite_calculado,
          MONEY(18,2)   AS importe_acum_mes;
    
    DEFINE iSqlErr          INTEGER; 
    DEFINE iIsamErr         INTEGER;
    DEFINE cMensaje         CHAR(80);

    DEFINE cCodRet          CHAR(6);
    DEFINE cMensaje_ret     CHAR(80);
    DEFINE dtFechaHoy       DATE;
    DEFINE dParamLimit      DECIMAL(18,2);
    DEFINE mCapPromedio     MONEY(18,2);
    DEFINE mCapMesAnt       MONEY(18,2);
    DEFINE mImpAcumMes      MONEY(18,2);
    DEFINE cPeriodo         CHAR(7);
    DEFINE mLimitCalc       MONEY(20,2);
    DEFINE dtPeriodo_aux    DATE;
    DEFINE dtPeriodo_ant    DATE;
    DEFINE cPeriodo_ant     CHAR(6);
    
    LET iSqlErr         = 0;
    LET iIsamErr        = 0;
    LET cMensaje        = "";
    
    LET cCodRet         = "000000";
    LET cMensaje_ret    = "Proceso realizado satisfactoriamente.";
    LET dtFechaHoy      = DATE(1);
    LET dParamLimit     = 0;
    LET mCapPromedio    = 0;
    LET mCapMesAnt      = 0;
    LET mImpAcumMes     = 0;
    LET cPeriodo        = "";
    LET mLimitCalc      = 0;
    LET dtPeriodo_aux   = DATE(1);
    LET dtPeriodo_ant   = DATE(1);
    LET cPeriodo_ant    = "";

    --- SET DEBUG FILE TO "/home/sysifx/viridiana/sp_corresp_consul_importe.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr,cMensaje
        LET cCodRet = iSqlErr;
        LET cMensaje_ret = cMensaje;
        RETURN cCodRet, cMensaje_ret, NVL(cPeriodo,""), NVL(mCapMesAnt,0), NVL(mCapPromedio,0), NVL(dParamLimit,0), NVL(mLimitCalc,0), NVL(mImpAcumMes,0);
    END EXCEPTION;
    
    IF NVL(pEmpresa,"") = "" OR NVL(pPeriodo,"") = "" THEN
        LET cCodRet = "000001";
        LET cMensaje_ret = "Es necesario indicar los parámetros para la consulta.";
        RETURN cCodRet, cMensaje_ret, NVL(cPeriodo,""), NVL(mCapMesAnt,0), NVL(mCapPromedio,0), NVL(dParamLimit,0), NVL(mLimitCalc,0), NVL(mImpAcumMes,0);
    END IF;

    SELECT fecha_hoy
      INTO dtFechaHoy
      FROM "informix".sc_fechas
     WHERE empresa = pEmpresa;

    SELECT monto
      INTO mCapPromedio
      FROM "informix".sc_corresp_limite
     WHERE periodo = pPeriodo;

    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = "000003";
        LET cMensaje_ret = "No existe información para el período seleccionado.";
        RETURN cCodRet, cMensaje_ret, NVL(cPeriodo,""), NVL(mCapMesAnt,0), NVL(mCapPromedio,0), NVL(dParamLimit,0), NVL(mLimitCalc,0), NVL(mImpAcumMes,0);
    END IF;

    SELECT valor
      INTO dParamLimit
      FROM "informix".sc_param_corresp
     WHERE empresa = pEmpresa
       AND codparam = "002";

    IF NVL(dParamLimit,0) = 0 THEN
        LET cCodRet = "000002";
        LET cMensaje_ret = "No se encuentra el parámetro de monto limite para corresponsal.";
        RETURN cCodRet, cMensaje_ret, NVL(cPeriodo,""), NVL(mCapMesAnt,0), NVL(mCapPromedio,0), NVL(dParamLimit,0), NVL(mLimitCalc,0), NVL(mImpAcumMes,0);
    END IF;
    
    LET mLimitCalc = (dParamLimit/100) * mCapPromedio;
    
    LET dtPeriodo_aux= MDY(SUBSTR(pPeriodo,5,6), "01", SUBSTR(pPeriodo,1,4));
    
    EXECUTE PROCEDURE "informix".monthadd(dtPeriodo_aux, -1) 
    INTO dtPeriodo_ant;

    LET cPeriodo_ant = YEAR(dtPeriodo_ant) || LPAD(MONTH(dtPeriodo_ant),2,0);

    SELECT monto
      INTO mCapMesAnt
      FROM "informix".sc_corresp_monto
     WHERE periodo = cPeriodo_ant;

    IF SUBSTR(pPeriodo,5,6) = LPAD(MONTH(dtFechaHoy),2,0) THEN
        SELECT valor
          INTO mImpAcumMes
          FROM "informix".sc_param_corresp
         WHERE empresa = pEmpresa
           AND codparam = "003";
    ELSE 
        SELECT monto
          INTO mImpAcumMes
          FROM "informix".sc_corresp_acumulado
         WHERE periodo = pPeriodo;
    END IF;      

    LET cPeriodo = SUBSTR(pPeriodo,5,6) || "/" || SUBSTR(pPeriodo,1,4);

    RETURN cCodRet, cMensaje_ret, NVL(cPeriodo,""), NVL(mCapMesAnt,0), NVL(mCapPromedio,0), NVL(dParamLimit,0), NVL(mLimitCalc,0), NVL(mImpAcumMes,0);

    END 
    
END PROCEDURE

DOCUMENT
"Descripción: Procedimiento que obtiene el importe de movimientos efectuados vía corresponsal.",
"BD: bdicheq",
"Fecha: 12/Nov/2010",
"Autor: Viridiana Osobampo Aguilar";

CREATE PROCEDURE "informix".sp_corresp_consul_transac(pPeriodo CHAR(6))
RETURNING CHAR(6)     AS cod_ret,
          CHAR(80)    AS mensaje_ret,
          INTEGER     AS num_transac,
          CHAR(4)     AS transac,
          CHAR(50)    AS descripcion_transac,
          MONEY(18,2) AS importe;
    
    DEFINE iSqlErr          INTEGER; 
    DEFINE iIsamErr         INTEGER;
    DEFINE cMensaje         CHAR(80);
    
    DEFINE cCodRet          CHAR(6);
    DEFINE cMensaje_ret     CHAR(80);
    DEFINE cTransac         CHAR(4);
    DEFINE iNumTransac      INTEGER;
    DEFINE cDescTransac     CHAR(50);
    DEFINE mImporte         MONEY(18,2);
    DEFINE mTotalCapMesAnt  MONEY(18,2);
    DEFINE dtPeriodoAnt     DATE;
    DEFINE cPeriodo_ant     CHAR(6);
    DEFINE dtPeriodoAux     DATE;
    DEFINE sExiste          SMALLINT;
    
    LET iSqlErr         = 0;
    LET iIsamErr        = 0;
    LET cMensaje        = "";
    
    LET cCodRet         = "000000";
    LET cMensaje_ret    = "Proceso realizado satisfactoriamente.";
    LET cTransac        = "";
    LET iNumTransac     = 0;
    LET cDescTransac    = "";
    LET mImporte        = 0;
    LET mTotalCapMesAnt = 0;
    LET dtPeriodoAnt    = DATE(1);
    LET cPeriodo_ant    = "";
    LET dtPeriodoAux    = DATE(1);
    LET sExiste         = 0;

    --- SET DEBUG FILE TO "/home/sysifx/viridiana/sp_corresp_consul_transac.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr,cMensaje
        LET cCodRet = iSqlErr;
        LET cMensaje_ret = cMensaje;
        IF  sExiste > 0 THEN        
            DROP TABLE tmp_transac;
        END IF;
        RETURN cCodRet, cMensaje_ret,NVL(iNumTransac,0),NVL(cTransac,""),NVL(cDescTransac,""),NVL(mImporte,0);
    END EXCEPTION;
    
    IF NVL(pPeriodo,"") = "" THEN
        LET cCodRet = "000001";
        LET cMensaje_ret = "Es necesario indicar el período para la consulta.";
        RETURN cCodRet, cMensaje_ret,NVL(iNumTransac,0),NVL(cTransac,""),NVL(cDescTransac,""),NVL(mImporte,0);
    END IF;
    
    LET dtPeriodoAux = MDY(SUBSTR(pPeriodo,5,6), "01", SUBSTR(pPeriodo,1,4));
    
    EXECUTE PROCEDURE "informix".monthadd(dtPeriodoAux, -1) 
    INTO dtPeriodoAnt; 
    
    LET cPeriodo_ant = YEAR(dtPeriodoAnt) || LPAD(MONTH(dtPeriodoAnt),2,0);
    
    SELECT COUNT(tabid) 
      INTO sExiste
      FROM systables
     WHERE tabname = "tmp_transac";

    IF  sExiste > 0 THEN        
        DROP TABLE tmp_transac;
    END IF;

    CREATE TEMP TABLE tmp_transac
        (
            numero      INTEGER,
            transaccion CHAR(4),
            descripcion CHAR(50),
            importe     MONEY(18,2)
        );

    FOREACH
        SELECT c.transacc, c.num_transacc, c.monto           
          INTO cTransac, iNumTransac, mImporte            
          FROM "informix".sc_corresp_monto_mes c            
         WHERE c.periodo = cPeriodo_ant

        SELECT descripcion
          INTO cDescTransac
          FROM bdinteg:"informix".si_transacc
         WHERE numero = cTransac;  

        INSERT INTO tmp_transac (numero, transaccion, descripcion, importe)
        VALUES (iNumTransac, cTransac, cDescTransac, mImporte);
    END FOREACH;
    
    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = "000002";
        LET cMensaje_ret = "No se encontraron registros de transacciones para el período indicado.";
        DROP TABLE tmp_transac;
        RETURN cCodRet, cMensaje_ret,NVL(iNumTransac,0),NVL(cTransac,""),NVL(cDescTransac,""),NVL(mImporte,0);
    END IF;
    
    SELECT monto
      INTO mTotalCapMesAnt
      FROM "informix".sc_corresp_monto
     WHERE periodo = cPeriodo_ant;
    
    INSERT INTO tmp_transac (descripcion, importe)
    VALUES ("Total Captación Mes Anterior",mTotalCapMesAnt);
    
    LET cTransac = "";
    LET iNumTransac = 0;
    LET cDescTransac = "";
    LET mImporte    = 0;
    LET mTotalCapMesAnt = 0;
    
    FOREACH
        SELECT numero, transaccion, descripcion, importe
        INTO iNumTransac, cTransac, cDescTransac, mImporte
        FROM tmp_transac
        
        RETURN cCodRet, cMensaje_ret,NVL(iNumTransac,0),NVL(cTransac,""),NVL(cDescTransac,""),NVL(mImporte,0) WITH RESUME;
    END FOREACH;
    
    DROP TABLE tmp_transac;
    
    END 
    
END PROCEDURE

DOCUMENT
"Descripción: Procedimiento que obtiene el detalle de transacciones ",
"BD: bdicheq",
"Fecha: 12/Nov/2010",
"Autor: Viridiana Osobampo Aguilar";

CREATE PROCEDURE "informix".sp_corresp_consul_promedio(pPeriodo CHAR(6))
RETURNING CHAR(6)     AS cod_ret,
          CHAR(80)    AS mensaje_ret,
          CHAR(15)    AS periodo,
          MONEY(18,2) AS importe_mes;
    
    DEFINE iSqlErr          INTEGER; 
    DEFINE iIsamErr         INTEGER;
    DEFINE cMensaje         CHAR(80);
    
    DEFINE cCodRet          CHAR(6);
    DEFINE cMensaje_ret     CHAR(80);
    DEFINE cPeriodo         CHAR(15);
    DEFINE mImporteMes      MONEY(18,2);
    DEFINE mTotalCaptacion  MONEY(18,2);
    DEFINE dtPeriodo_aux    DATE;
    DEFINE dtPeriodoAnt     DATE;
    DEFINE cPeriodo_ant     CHAR(6);
    DEFINE mMontoProm       MONEY(18,2);
    DEFINE cPeriodoMonto    CHAR(6);
    DEFINE cMesPeriodo      CHAR(15);
    DEFINE sExiste          SMALLINT;
    
    LET iSqlErr         = 0;
    LET iIsamErr        = 0;
    LET cMensaje        = "";
    
    LET cCodRet         = "000000";
    LET cMensaje_ret    = "Proceso realizado satisfactoriamente.";
    LET cPeriodo        = "";
    LET mImporteMes     = 0;
    LET mTotalCaptacion = 0;
    LET dtPeriodo_aux   = DATE(1);
    LET dtPeriodoAnt    = DATE(1);
    LET cPeriodo_ant    = "";
    LET mMontoProm      = 0;
    LET cPeriodoMonto   = "";
    LET cMesPeriodo     = "";
    LET sExiste         = 0;
    
    --- SET DEBUG FILE TO "/home/sysifx/viridiana/sp_corresp_consul_promedio.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr,cMensaje
        LET cCodRet = iSqlErr;
        LET cMensaje_ret = cMensaje;
        
        SELECT COUNT(tabid)
          INTO sExiste
          FROM systables
         WHERE tabname = "promedios";

        IF sExiste > 0 THEN
            DROP TABLE promedios;
        END IF;
        
        RETURN cCodRet, cMensaje_ret,NVL(cMesPeriodo,""),NVL(mImporteMes,0);
    END EXCEPTION;
    
    IF NVL(pPeriodo,"") = "" THEN
        LET cCodRet = "000001";
        LET cMensaje_ret = "Es necesario indicar el período para la consulta.";
        RETURN cCodRet, cMensaje_ret,NVL(cMesPeriodo,""),NVL(mImporteMes,0);
    END IF;
    
    LET dtPeriodo_aux = MDY((SUBSTR(pPeriodo,5,6)), "01", SUBSTR(pPeriodo,1,4));
    
    EXECUTE PROCEDURE "informix".monthadd(dtPeriodo_aux, -12) 
    INTO dtPeriodoAnt;
    
    LET cPeriodo_ant = YEAR(dtPeriodoAnt) || LPAD(MONTH(dtPeriodoAnt),2,0);
    
    SELECT COUNT(tabid)
      INTO sExiste
      FROM systables
     WHERE tabname = "promedios";

    IF sExiste > 0 THEN
        DROP TABLE promedios;
    END IF;

    CREATE TEMP TABLE promedios
        (
            mesperiodo  char(15),
            importe     money(18,2)
        );

    FOREACH
        SELECT monto, periodo
          INTO mMontoProm, cPeriodoMonto
          FROM "informix".sc_corresp_monto
         WHERE periodo >= cPeriodo_ant
           AND periodo < pPeriodo
         order by periodo asc
        
        LET cMesPeriodo = DECODE(SUBSTR(cPeriodoMonto,5,6), "01", "Enero", 
                                                            "02", "Febrero",
                                                            "03", "Marzo",
                                                            "04", "Abril",
                                                            "05", "Mayo",
                                                            "06", "Junio",
                                                            "07", "Julio",
                                                            "08", "Agosto",
                                                            "09", "Septiembre",
                                                            "10", "Octubre",
                                                            "11", "Noviembre",
                                                            "12", "Diciembre");
        
        LET cMesPeriodo = TRIM(cMesPeriodo) || "-" || SUBSTR(cPeriodoMonto,1,4);

        INSERT INTO promedios(mesperiodo, importe)
        VALUES (cMesPeriodo, mMontoProm);
    END FOREACH;  
    
    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = "000002";
        LET cMensaje_ret = "No se encuentra captación realizada respecto al período indicado.";
        DROP TABLE promedios;
        RETURN cCodRet, cMensaje_ret,NVL(cMesPeriodo,""),NVL(mImporteMes,0);
    END IF;

    SELECT monto
      INTO mTotalCaptacion
      FROM "informix".sc_corresp_limite
     WHERE periodo = pPeriodo;

    INSERT INTO promedios(mesperiodo,importe)
    VALUES ("Cálculo", mTotalCaptacion);

    LET cMesPeriodo = "";

    FOREACH
        SELECT mesperiodo, importe
        INTO cMesPeriodo, mImporteMes
        FROM promedios

        RETURN cCodRet, cMensaje_ret,NVL(cMesPeriodo,""),NVL(mImporteMes,0) WITH RESUME;
    END FOREACH;  

    DROP TABLE promedios;

    END 
    
END PROCEDURE

DOCUMENT
"Descripción: Procedimiento que obtiene el monto de captación realizada por corresponsal de los últimos doce",
               "períodos a partir de la fecha indicada para la consulta",
"BD: bdicheq",
"Fecha: 12/Nov/2010",
"Autor: Viridiana Osobampo Aguilar";

CREATE PROCEDURE "informix".sp_abonos_operaciones(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcodret_abono    CHAR(5);
    
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);    
    DEFINE vtransacc        CHAR(4);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vsucursal        CHAR(4);  
    DEFINE vusuario         CHAR(8);
    DEFINE vmoneda          CHAR(2);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcomienza     = -1;
    LET ven_transacc  = 0;
    LET vcodret_abono = '';
    
    LET vsql         = '';
    LET vstmt        = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vtransacc    = '';
    LET vdescripcion = '';
    LET vsucursal    = '9250';
    LET vusuario     = 'informix';
    LET vmoneda      = '01';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_abonos_operaciones.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_abonos_operaciones.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxabonar') THEN
        DROP TABLE "informix".ctasxabonar;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxabonar
      (
        cuenta      char(20)    not null,
        monto       money(18,2) not null,
        transacc    char(4)     not null,
        descripcion char(40)    not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxabon ON "informix".ctasxabonar(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/abonos_operaciones.unl DELIMITER ''","'' INSERT INTO ctasxabonar" > /resplogifx/conciliachq/abonos.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/abonos.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxabonar;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = vusuario||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta, monto, transacc, descripcion
          INTO vcuenta, vmonto, vtransacc, vdescripcion
          FROM ctasxabonar
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        CALL abono_ref( pempresa,       -- empresa
                        vsucursal,         -- sucursal
                        vusuario,       -- usuario
                        vtransacc,      -- transaccion
                        '0000',         -- transacc suc
                        vfolio,         -- folio
                        vcuenta,        -- cuenta
                        0,              -- cheque
                        vmonto,         -- monto
                        vmonto,         -- monto firme
                        0,              -- monto sbc
                        0,              -- monto rem
                        0,              -- dias ret
                        vmoneda,        -- divisa
                        vdescripcion,   -- referencia
                        ' ',            -- num tarjeta
                        vusuario )      -- autoriza
        RETURNING vcodret_abono;
        
        IF vcodret_abono = '000' THEN
            LET vcontador2 = vcontador2 + 1;
            COMMIT WORK;
            BEGIN WORK;
        ELSE 
            ROLLBACK WORK;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vcuenta       = '';
        LET vmonto        = 0.00;
        LET vtransacc     = '';
        LET vdescripcion  = '';
        LET vcodret_abono = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;