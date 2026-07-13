CREATE PROCEDURE "informix".sp_generaredoctaejeencabezado(pEmpresa CHAR(3), 
                                                          pCuenta CHAR(20), 
                                                          pAniomes CHAR(6))

RETURNING CHAR(5)       AS vcodret, 
          DATE          AS dFecha_emision,
          CHAR(20)      AS cNum_cte,
          CHAR(16)      AS cNum_Tarjeta,
          CHAR(150)     AS cNombre_cte,
          CHAR(200)     AS cDireccion_cte,
          CHAR(120)     AS cDireccion_col,
          CHAR(120)     AS cDireccion_del,
          CHAR(120)     AS cEdo_cd,              
          CHAR(60)      AS cCve_ruta,
          CHAR(40)      AS cSucursal_nombre,
          CHAR(13)      AS cRFC_Cliente,
          CHAR(5)       AS cCP,
          CHAR(60)      AS cCve_ahorro,
          CHAR(60)      AS cClabe,
          CHAR(60)      AS cCurp,
          DATE          AS dFechaAlta,
          DATE          AS dFechaInicio,
          CHAR(255)     AS cMensajeProducto,
          CHAR(15)      AS cInserto,
          DATE          AS dFechaFinal,
          CHAR(4)       AS cSucursal,
          DECIMAL(16,2) AS mSaldoAnterior,
          DECIMAL(16,2) AS mDepositos,
          DECIMAL(16,2) AS mInteresesPagados,
          DECIMAL(16,2) AS mRetiros,
          DECIMAL(16,2) AS mOtrosCargos,
          DECIMAL(16,2) AS mIvaOtrosCargos,
          DECIMAL(16,2) AS mSaldoCorte,
          DECIMAL(16,2) AS mSaldoPromedio,
          DECIMAL(16,2) AS mRetencionIsr,              
          DECIMAL(16,2) AS mInteresesNetos,
          SMALLINT      AS iDias,             
          DECIMAL(9, 6) AS dTasaBruta,
          CHAR(255)     AS cPiePagina,
          DECIMAL(16,2) AS mTotRetirosEfec, 
          DECIMAL(16,2) AS mTotOtrosCargos,
          DECIMAL(9, 6) AS dGAT;

    -- Elaborado por : Lorenzo Ibarra Garcia
    -- Fecha: 17-06-2009
    -- Regresa los datos de las cuentas eje para formar el encabezado, el encabezado2 y el pie de pagina (adaptación del sp_edoctagenerales).
    -- Modificó: Lorenzo Ibarra Garcia
    -- Fecha: 10-07-2009
    -- Se corrigió la forma que se hacia el cálculo para obtener el saldo promedio del periodo de 6 meses ya que se debe de calcular
    -- el saldo del mes máximo mas la sumatoria del calculo del saldo de los 5 meses posteriores y el resultado dividirlo entre 6.

    DEFINE vcodret CHAR(5);
    DEFINE dFecha_emision DATE;
    DEFINE cNum_cte CHAR(20);
    DEFINE cNum_Tarjeta CHAR(16);
    DEFINE cNombre_cte CHAR(150);
    DEFINE cDireccion_cte CHAR(200);
    DEFINE cDireccion_col CHAR(120);
    DEFINE cDireccion_del CHAR(120);
    DEFINE cEdo_cd CHAR(120);              
    DEFINE cCve_ruta CHAR(60);
    DEFINE cSucursal_nombre CHAR(40);
    DEFINE cRFC_Cliente CHAR(13);
    DEFINE cCP CHAR(5);
    DEFINE cCve_ahorro CHAR(60);
    DEFINE cClabe CHAR(60);
    DEFINE cCurp CHAR(60);
    DEFINE dFechaAlta DATE;
    DEFINE dFechaInicio DATE;
    DEFINE cMensajeProducto CHAR(255);
    DEFINE cInserto CHAR(15);
    DEFINE cSucursal CHAR(4);
    DEFINE mSaldoAnterior DECIMAL(16,2);
    DEFINE mDepositos DECIMAL(16,2);
    DEFINE mInteresesPagados DECIMAL(16,2);
    DEFINE mRetiros DECIMAL(16,2);
    DEFINE mOtrosCargos DECIMAL(16,2);
    DEFINE mIvaOtrosCargos DECIMAL(16,2);
    DEFINE mSaldoCorte DECIMAL(16,2);
    DEFINE mSaldoPromedio DECIMAL(16,2);
    DEFINE mRetencionIsr DECIMAL(16,2);              
    DEFINE mInteresesNetos DECIMAL(16,2);
    DEFINE iDias SMALLINT;             
    DEFINE dTasaBruta DECIMAL(9, 6);
    DEFINE cPiePagina CHAR(255);
    DEFINE mAux1 DECIMAL(16, 2);
    DEFINE vsec_dir SMALLINT;
    DEFINE vsqlerr INTEGER;  
    DEFINE visamerr INTEGER;
    DEFINE v_numerocolonia INTEGER;
    DEFINE v_numerocalle INTEGER;
    DEFINE v_centro INTEGER;
    DEFINE v_jefegrupozona INTEGER;
    DEFINE v_supervisorzona INTEGER;
    DEFINE v_numerociudad SMALLINT;
    DEFINE v_numeroextcalle CHAR(10);
    DEFINE v_ultimos_meses INTEGER;
    DEFINE v_acciones_menor SMALLINT;
    DEFINE v_acciones_igual1 SMALLINT;
    DEFINE v_acciones_monto1 DECIMAL(8,2);
    DEFINE v_acciones_mayor SMALLINT;
    DEFINE v_acciones_igual2 SMALLINT;
    DEFINE v_acciones_monto2 DECIMAL(8,2);
    DEFINE v_acciones_accion CHAR(120);
    DEFINE cCondicion1 CHAR(2);
    DEFINE cCondicion2 CHAR(2);
    DEFINE cNumProducto CHAR(4);    
    DEFINE tPeriodoAnterior date;
    DEFINE cRetornoSPcortesig char(6);
    DEFINE dSaldoPromedioPeriodoAnt DECIMAL(16,2);
    DEFINE vexiste_maehis CHAR(6);
    DEFINE vexiste_marcaje CHAR(15);
    DEFINE mTotRetirosEfec DECIMAL(18,2);
    DEFINE mTotOtrosCargos DECIMAL(18,2);
    DEFINE dGAT DECIMAL(9, 6);

    LET vcodret = "000";
    LET cMensajeProducto = "";
    LET cNum_Tarjeta = "";
    LET cClabe = "";
    LET cNum_cte = "";
    LET cNombre_cte = "";
    LET cDireccion_cte = "";
    LET cDireccion_col = "";
    LET cDireccion_del = "";
    LET cEdo_cd = "";
    LET cCP = "";
    LET cRFC_Cliente = "";
    LET cCurp = "";
    LET cSucursal_nombre = "";
    LET dFechaInicio = "";
    LET dFecha_emision = "";
    LET dFechaAlta = "";
    LET mSaldoPromedio= 0;
    LET mInteresesNetos = 0;
    LET mSaldoAnterior = 0;
    LET mDepositos = 0;
    LET mRetiros = 0;
    LET mInteresesPagados = 0;
    LET mOtrosCargos = 0;
    LET mIvaOtrosCargos = 0;
    LET mSaldoCorte = 0;
    LET mRetencionIsr = 0;
    LET iDias = 0;
    LET dTasaBruta = 0;
    LET mAux1 = 0;
    LET vsec_dir = 0;
    LET pCuenta = TRIM(pCuenta);
    LET v_numerocolonia = 0;
    LET v_numerocalle = 0;
    LET v_centro = 0;
    LET v_jefegrupozona = 0;
    LET v_supervisorzona = 0;
    LET v_numerociudad = 0;
    LET v_numeroextcalle = "";
    LET cInserto = "";
    LET cSucursal = "";
    LET cCve_ruta = "";
    LET cCve_ahorro = "";
    LET v_acciones_menor = 0;
    LET v_acciones_igual1 = 0;
    LET v_acciones_monto1 = 0;
    LET v_acciones_mayor = 0;
    LET v_acciones_igual2 = 0;
    LET v_acciones_monto2 = 0;
    LET v_acciones_accion = "";
    LET cCondicion1 = "";
    LET cCondicion2 = "";
    LET cPiePagina = "";
    LET cNumProducto = "";
    LET tPeriodoAnterior = "";
    LET cRetornoSPcortesig ="";
    LET dSaldoPromedioPeriodoAnt = 0;
    LET mTotRetirosEfec = 0;
    LET mTotOtrosCargos = 0;
    LET dGAT = 0;

    -- SET debug FILE TO "/tmp/sp_generaredoctaejeencabezado.out";
    -- trace on;

    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "./sp_generaredoctaejeencabezado.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col,
                   cDireccion_del, cEdo_cd, cCve_ruta, cSucursal_nombre, cRFC_Cliente, cCP, cCve_ahorro,
                   cClabe, cCurp, dFechaAlta, dFechaInicio, cMensajeProducto, cInserto, dFecha_emision, cSucursal,
                   mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
                   mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
                   iDias, dTasaBruta, cPiePagina, mTotRetirosEfec, mTotOtrosCargos, dGAT;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    -- // validar que los parámetros se hayan recibido correctamente
    IF (TRIM(pEmpresa) = "" OR pEmpresa IS NULL) THEN
        LET vcodret = "001";
        RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col,
               cDireccion_del, cEdo_cd, cCve_ruta, cSucursal_nombre, cRFC_Cliente, cCP, cCve_ahorro,
               cClabe, cCurp, dFechaAlta, dFechaInicio, cMensajeProducto, cInserto, dFecha_emision, cSucursal,
               mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
               mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
               iDias, dTasaBruta, cPiePagina, mTotRetirosEfec, mTotOtrosCargos, dGAT;
    END IF;
    
    IF (TRIM(pCuenta) = "" OR pCuenta IS NULL) THEN
        LET vcodret = "002";
        RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col,
               cDireccion_del, cEdo_cd, cCve_ruta, cSucursal_nombre, cRFC_Cliente, cCP, cCve_ahorro,
               cClabe, cCurp, dFechaAlta, dFechaInicio, cMensajeProducto, cInserto, dFecha_emision, cSucursal,
               mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
               mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
               iDias, dTasaBruta, cPiePagina, mTotRetirosEfec, mTotOtrosCargos, dGAT;
    END IF;
    
    SELECT {+INDEX(sc_maehis idx_maehis1)} FIRST 1 aniomes 
      INTO vexiste_maehis
      FROM bdicheq:sc_maehis mc 
     WHERE mc.empresa = pEmpresa 
       AND mc.cuenta = pCuenta 
       AND mc.aniomes = pAniomes;
       
    IF vexiste_maehis is null OR vexiste_maehis = '' THEN
        LET vcodret = "003";
        RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col,
               cDireccion_del, cEdo_cd, cCve_ruta, cSucursal_nombre, cRFC_Cliente, cCP, cCve_ahorro,
               cClabe, cCurp, dFechaAlta, dFechaInicio, cMensajeProducto, cInserto, dFecha_emision, cSucursal,
               mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
               mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
               iDias, dTasaBruta, cPiePagina, mTotRetirosEfec, mTotOtrosCargos, dGAT;
    END IF
    
    -- // OBTENER EL ESTADO DE CUENTA
    SELECT {+INDEX(sc_maehis idx_maehis1)} LIMIT 1
           TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.num_tarjeta,
           TRIM(mc.num_cte), mc.cuenta_clabe, NVL(mc.fechaini, MDY(1, 1, 1900)), NVL(mc.fechafin, MDY(1, 1, 1900)),
           NVL(sdo_mes_ant, 0), NVL(totdepositos, 0), NVL(totintpag, 0), NVL(totretiros, 0),
           NVL(totcomcobrada, 0), NVL(totivacobrado, 0), NVL(sdo_actual, 0), NVL(totisrcobrado, 0),
           NVL(dia_sdo_pos, 0), NVL(tasabruta, 0), NVL(acum_sdo_pos, 0), mc.producto,
           NVL(totretirosefec, 0), NVL(tototroscargos, 0), NVL(gat, 0) 
      INTO cMensajeProducto, cNum_Tarjeta, cNum_cte, cClabe, dFechaInicio, dFecha_emision, mSaldoAnterior, mDepositos, 
           mInteresesPagados, mRetiros, mOtrosCargos, mIvaOtrosCargos, mSaldoCorte, mRetencionIsr, iDias, dTasaBruta, mAux1, cNumProducto,
           mTotRetirosEfec, mTotOtrosCargos, dGAT
      FROM bdicheq:sc_maehis AS mc,
           bdicheq:sc_producto AS ap
     WHERE mc.empresa = pEmpresa 
       AND mc.cuenta = pCuenta 
       AND mc.aniomes = pAniomes 
       AND ap.empresa = mc.empresa 
       AND ap.producto = mc.producto;

    -- // Extrae la Ultima Secuencia de Tipo casa de Direcciones MEL
    SELECT MAX(secuencia) 
      INTO vsec_dir
      FROM bdinteg:si_direcciones
     WHERE numcte = cNum_cte 
       AND tipo_dir = 1;

    IF vsec_dir IS NULL THEN
        LET vsec_dir = 1;
    END IF

    IF iDias = 0 THEN
        LET mSaldoPromedio= 0;
    ELSE
        LET mSaldoPromedio= mAux1 / iDias;
    END IF;

    LET mInteresesNetos = mInteresesPagados - mRetencionIsr;

    IF cNum_cte IS NULL THEN
        SELECT LIMIT 1
               TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto,
               TRIM(mc.num_cte), mc.cuenta_clabe
          INTO cMensajeProducto, cNum_cte, cClabe
          FROM bdicheq:sc_maechq AS mc,
               bdicheq:sc_producto AS ap
         WHERE mc.empresa = pEmpresa 
           AND mc.cuenta = pCuenta 
           AND ap.empresa = mc.empresa 
           AND ap.producto = mc.producto;

        SELECT LIMIT 1
               CASE WHEN cte.tpo_persona = "01" THEN 
                   NVL(TRIM(cte.nombre1), "")||' '||NVL(TRIM(cte.nombre2), "")||' '||NVL(TRIM(cte.apell_paterno), "")||' '||NVL(TRIM(cte.apell_materno), "")
               ELSE 
                   NVL(TRIM(cte.razon_social), "") 
               END AS nombrex,
               suc.nombre, cte.fecha_insert, cte.rfc, cpf.curp, 
               TRIM(cal.nombrecalle)||" "||NVL(dir.numeroextcalle,0)||" "||NVL(dir.numerointcalle,0),
               TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal, dir.numerocolonia, dir.numerocalle,
               dir.numerociudad, dir.numeroextcalle, cte.sucursal
          INTO cNombre_cte, cSucursal_nombre, dFechaAlta, cRFC_Cliente, cCurp, cDireccion_cte,
               cDireccion_col, cDireccion_del, cEdo_cd, cCP, v_numerocolonia, v_numerocalle,
               v_numerociudad, v_numeroextcalle, cSucursal
          FROM bdinteg:si_cliente AS cte
          LEFT JOIN bdinteg:si_ctepf cpf ON (cpf.numcte = cte.numcte)
          LEFT JOIN bdinteg:si_direcciones AS dir ON (dir.numcte = cte.numcte)
          LEFT JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
          LEFT JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
          LEFT JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
          LEFT JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
          LEFT JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
         WHERE cte.empresa = pEmpresa 
           AND cte.numcte = cNum_cte 
           AND dir.secuencia = vsec_dir;

        LET dFechaInicio = "";
        LET dFecha_emision = "";
        LET mSaldoAnterior = 0;
        LET mDepositos = 0;
        LET mInteresesPagados = 0;
        LET mRetiros = 0;
        LET mOtrosCargos = 0;
        LET mIvaOtrosCargos = 0;
        LET mSaldoCorte = 0;
        LET mSaldoPromedio = 0;
        LET mRetencionIsr = 0;
        LET mInteresesNetos = 0;
        LET iDias = 0;
        LET dTasaBruta = 0;
    ELSE
        SELECT LIMIT 1
               CASE WHEN cte.tpo_persona = "01" THEN 
                   NVL(TRIM(cte.nombre1), "")||' '||NVL(TRIM(cte.nombre2), "")||' '||NVL(TRIM(cte.apell_paterno), "")||' '||NVL(TRIM(cte.apell_materno), "")
               ELSE 
                   NVL(TRIM(cte.razon_social), "") 
               END AS nombrex,
               suc.nombre, cte.fecha_insert, cte.rfc, cpf.curp, 
               TRIM(cal.nombrecalle)||" "||NVL(dir.numeroextcalle,0)||" "||NVL(dir.numerointcalle,0),
               TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal, dir.numerocolonia, dir.numerocalle,
               dir.numerociudad, dir.numeroextcalle, cte.sucursal
          INTO cNombre_cte, cSucursal_nombre, dFechaAlta, cRFC_Cliente, cCurp, cDireccion_cte, cDireccion_col,
               cDireccion_del, cEdo_cd, cCP, v_numerocolonia, v_numerocalle,
               v_numerociudad, v_numeroextcalle, cSucursal
          FROM bdinteg:si_cliente AS cte
          LEFT JOIN bdinteg:si_ctepf AS cpf ON (cpf.numcte = cte.numcte)
          LEFT JOIN bdinteg:si_direcciones AS dir ON (dir.numcte = cte.numcte)
          LEFT JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
          LEFT JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
          LEFT JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
          LEFT JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
          LEFT JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
         WHERE cte.empresa = pEmpresa 
           AND cte.numcte = cNum_cte 
           AND dir.secuencia = vsec_dir;
    END IF;

    -- // generar la clave de ruta
    SELECT LIMIT 1 d.centro, d.jefegrupozona, d.supervisorzona
      INTO v_centro, v_jefegrupozona,	v_supervisorzona
      FROM bdinteg:si_catzonas d
     WHERE d.numerociudad = v_numerociudad
       AND d.numerocolonia = v_numerocolonia;

    LET cCve_ruta = LPAD(v_numerociudad,4,'0')||"/"||
                    LPAD(v_centro,6,'0')||"/"||
                    LPAD(v_jefegrupozona,8,'0')||"/"||
                    LPAD(v_supervisorzona,8,'0')||"/"||
                    LPAD(v_numerocolonia,4,'0')||"/"||
                    LPAD(v_numerocalle,6,'0')||"/"||
                    LPAD(TRIM(v_numeroextcalle),5,'0');

    -- // OBTENER CLAVE DE AHORRO
    FOREACH WITH HOLD
        -- // obtener los parametros para las validaciones
        SELECT {+INDEX(bdicheq:sc_acciones_edocta idx_acciones)}
               ultimos_meses, menor, igual1, monto1, mayor, igual2, monto2, accion
          INTO v_ultimos_meses, v_acciones_menor, v_acciones_igual1, v_acciones_monto1,
               v_acciones_mayor, v_acciones_igual2, v_acciones_monto2, v_acciones_accion
          FROM bdicheq:sc_acciones_edocta
         WHERE accion IS NOT NULL

        -- // calcular el periodo anterior
        EXECUTE PROCEDURE sp_cortesig(dFecha_emision, -v_ultimos_meses + 1)
        INTO cRetornoSPcortesig, tPeriodoAnterior;

        --obtener la suma del saldo promedio del periodo anterior
        SELECT {+INDEX(sc_maehis idx_maehis2)} 
               SUM(case when dia_sdo_pos > 0 then acum_sdo_pos/dia_sdo_pos else 0 end) / v_ultimos_meses
          INTO dSaldoPromedioPeriodoAnt
          FROM bdicheq:sc_maehis
         WHERE empresa = pEmpresa
           AND cuenta = pCuenta
           AND fechafin >= tPeriodoAnterior;

        -- // comparar el saldo promedio del periodo con el de la tabla sc_acciones_edocta
        -- // obtener las condiciones para las validaciones
        IF v_acciones_menor = 1 AND v_acciones_igual1 = 1 THEN
            LET cCondicion1 = "<=";
        ELIF v_acciones_menor = 1 THEN
            LET cCondicion1 = "<";
        ELIF v_acciones_igual1 = 1 THEN
            LET cCondicion1 = "=";
        ELSE
            LET cCondicion1 = "";
        END IF;

        IF v_acciones_mayor = 1 AND v_acciones_igual2 = 1 THEN
            LET cCondicion2 = ">=";
        ELIF v_acciones_mayor = 1 THEN
            LET cCondicion2 = ">";
        ELIF v_acciones_igual2 = 1 THEN
            LET cCondicion2 = "=";
        ELSE
            LET cCondicion2 = "";
        END IF;

        -- // comparar el saldo promedio del periodo con el de la tabla sc_acciones_edocta para obtener la accion
        IF cCondicion1 = "<=" THEN
            IF cCondicion2 = ">=" THEN
                IF dSaldoPromedioPeriodoAnt <= v_acciones_monto1 AND dSaldoPromedioPeriodoAnt >= v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = ">" THEN
                IF dSaldoPromedioPeriodoAnt <= v_acciones_monto1 AND dSaldoPromedioPeriodoAnt > v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = "=" THEN
                IF dSaldoPromedioPeriodoAnt <= v_acciones_monto1 AND dSaldoPromedioPeriodoAnt = v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = "" THEN
                IF dSaldoPromedioPeriodoAnt <= v_acciones_monto1 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            END IF;
        ELIF cCondicion1 = "<" THEN
            IF cCondicion2 = ">=" THEN
                IF dSaldoPromedioPeriodoAnt < v_acciones_monto1 AND dSaldoPromedioPeriodoAnt >= v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = ">" THEN
                IF dSaldoPromedioPeriodoAnt < v_acciones_monto1 AND dSaldoPromedioPeriodoAnt > v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = "=" THEN
                IF dSaldoPromedioPeriodoAnt < v_acciones_monto1 AND dSaldoPromedioPeriodoAnt = v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = "" THEN
                IF dSaldoPromedioPeriodoAnt < v_acciones_monto1 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            END IF;
        ELIF cCondicion1 = "=" THEN
            IF cCondicion2 = ">=" THEN
                IF dSaldoPromedioPeriodoAnt = v_acciones_monto1 AND dSaldoPromedioPeriodoAnt >= v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = ">" THEN
                IF dSaldoPromedioPeriodoAnt = v_acciones_monto1 AND dSaldoPromedioPeriodoAnt > v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = "=" THEN
                IF dSaldoPromedioPeriodoAnt = v_acciones_monto1 AND dSaldoPromedioPeriodoAnt = v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = "" THEN
                IF dSaldoPromedioPeriodoAnt = v_acciones_monto1 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            END IF;
        ELIF cCondicion1 = "" THEN
            IF cCondicion2 = ">=" THEN
                IF dSaldoPromedioPeriodoAnt >= v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = ">" THEN
                IF dSaldoPromedioPeriodoAnt > v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            ELIF cCondicion2 = "=" THEN
                IF dSaldoPromedioPeriodoAnt = v_acciones_monto2 THEN
                    LET cCve_ahorro = v_acciones_accion;
                END IF;
            END IF;
        END IF;

        -- // verificar si se obtuvo la accion, para salir del foreach. sino para que continue
        IF cCve_ahorro <> "" THEN
            EXIT FOREACH;
        END IF;
    END FOREACH;

    -- // obtener inserto
    SELECT {+INDEX(sc_marcaje idx_marcaje)} insertos 
      INTO vexiste_marcaje
      FROM bdicheq:sc_marcaje 
     WHERE num_cuenta = pCuenta;
     
    IF vexiste_marcaje is not null OR vexiste_marcaje <> '' THEN
        SELECT {+INDEX(sc_marcaje idx_marcaje)}
               LIMIT 1 NVL(insertos,"000000000000000")
          INTO cInserto
          FROM bdicheq:sc_marcaje
         WHERE num_cuenta = pCuenta;
    ELSE
        LET cInserto = "000000000000000";
    END IF;
    
    -- // obtener el pie de pagina    
    SELECT {+INDEX(sc_mensajes_producto idx_mensajes)}
           LIMIT 1 mensaje
      INTO cPiePagina
      FROM sc_mensajes_producto
     WHERE producto = cNumProducto;

    RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col,
           cDireccion_del, cEdo_cd, cCve_ruta, cSucursal_nombre, cRFC_Cliente, cCP, cCve_ahorro,
           cClabe, cCurp, dFechaAlta, dFechaInicio, cMensajeProducto, cInserto, dFecha_emision, cSucursal,
           mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
           mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
           iDias, dTasaBruta, cPiePagina, mTotRetirosEfec, mTotOtrosCargos, dGAT;

    END;
    
END PROCEDURE;