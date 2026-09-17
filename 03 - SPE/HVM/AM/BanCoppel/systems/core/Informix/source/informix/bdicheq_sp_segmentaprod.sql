CREATE PROCEDURE "informix".sp_segmentaprod( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50);
    
    DEFINE cCodRet              CHAR(5);
    DEFINE cCodRet2             CHAR(5);
    DEFINE cCodRet3             CHAR(50);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE iDesErr              CHAR(50);
    DEFINE dFechaHoy            DATE;
    DEFINE dPriDiaMes           DATE;
    DEFINE dUltDiaMesAnt        DATE;
    DEFINE dFechaFin            DATE;
    DEFINE dFechaIni            DATE;
    DEFINE iAnio                SMALLINT;
    DEFINE cAnioMesIni          CHAR(6);
    DEFINE cAnioMesFin          CHAR(6);
    DEFINE cProdEfectiva        CHAR(4);
    DEFINE cFechConMovHis       DATE;
    DEFINE cFechConMovHisOld    DATE;
    DEFINE cFechConMovHisOld2   DATE;
    DEFINE cNumCte              CHAR(20);
    DEFINE cCuenta              CHAR(20);
    DEFINE dFechaInsert         DATE;
    DEFINE cSucursal            CHAR(4);
    DEFINE dFechaNac            DATE;
    DEFINE cSexo                CHAR(1);
    DEFINE cZona                CHAR(60);
    DEFINE cEstado              CHAR(30);
    DEFINE iEdad                SMALLINT;
    DEFINE iProdsChq            SMALLINT;
    DEFINE cNombreChq           CHAR(40);
    DEFINE iProdsCrd            SMALLINT;
    DEFINE cNombreCrd           CHAR(40);
    DEFINE cAnioMes             CHAR(6);
    DEFINE mSdoAcum             DECIMAL(18,2);
    DEFINE iDias                SMALLINT;
    DEFINE mSdoProm             DECIMAL(18,2);
    DEFINE dFechaMov            DATE;
    DEFINE cTransacc            CHAR(4);
    DEFINE cDescripcion         CHAR(50);
    DEFINE cNaturaleza          CHAR(1);
    DEFINE mMonto               DECIMAL(14,2);
    DEFINE mSdoMin              DECIMAL(14,2);
    DEFINE mSdoMax              DECIMAL(14,2);
    DEFINE cMes                 CHAR(2);
    DEFINE dResiduo             DECIMAL(6, 2); 
    DEFINE mCapVig1             DECIMAL(14,2);
    DEFINE mCapVig2             DECIMAL(14,2);
    DEFINE mCapVig3             DECIMAL(14,2);
    DEFINE mCapVig4             DECIMAL(14,2);
    DEFINE mCapVig5             DECIMAL(14,2);
    DEFINE mCapVig6             DECIMAL(14,2);
    DEFINE mCapVig7             DECIMAL(14,2);
    DEFINE mCapVig8             DECIMAL(14,2);
    DEFINE mCapVig9             DECIMAL(14,2);
    DEFINE mCapVig10            DECIMAL(14,2);
    DEFINE mCapVig11            DECIMAL(14,2);
    DEFINE mCapVig12            DECIMAL(14,2);
    DEFINE mCapVig13            DECIMAL(14,2);
    DEFINE mCapVig14            DECIMAL(14,2);
    DEFINE mCapVig15            DECIMAL(14,2);
    DEFINE mCapVig16            DECIMAL(14,2);
    DEFINE mCapVig17            DECIMAL(14,2);
    DEFINE mCapVig18            DECIMAL(14,2);
    DEFINE mCapVig19            DECIMAL(14,2);
    DEFINE mCapVig20            DECIMAL(14,2);
    DEFINE mCapVig21            DECIMAL(14,2);
    DEFINE mCapVig22            DECIMAL(14,2);
    DEFINE mCapVig23            DECIMAL(14,2);
    DEFINE mCapVig24            DECIMAL(14,2);
    DEFINE mCapVig25            DECIMAL(14,2);
    DEFINE mCapVig26            DECIMAL(14,2);
    DEFINE mCapVig27            DECIMAL(14,2);
    DEFINE mCapVig28            DECIMAL(14,2);
    DEFINE mCapVig29            DECIMAL(14,2);
    DEFINE mCapVig30            DECIMAL(14,2);
    DEFINE mCapVig31            DECIMAL(14,2);
    
    LET cCodRet             = '000';               
    LET cCodRet2            = '000';
    LET cCodRet3            = 'PROCESO FINALIZADO';
    LET iSqlErr             = 0;                   
    LET iSamErr             = 0;
    LET iDesErr             = '';              
    LET dFechaHoy           = '';
    LET dPriDiaMes          = '';
    LET dUltDiaMesAnt       = '';
    LET dFechaFin           = '';
    LET dFechaIni           = '';
    LET iAnio               = 0;
    LET cAnioMesIni         = '';
    LET cAnioMesFin         = '';
    LET cProdEfectiva       = '';
    LET cFechConMovHis      = '';
    LET cFechConMovHisOld   = '';
    LET cFechConMovHisOld2  = '';
    LET cNumCte             = '';
    LET cCuenta             = '';
    LET dFechaInsert        = '';
    LET cSucursal           = '';
    LET dFechaNac           = '';
    LET cSexo               = '';
    LET cZona               = '';
    LET cEstado             = '';
    LET iEdad               = 0;
    LET iProdsChq           = 0;
    LET cNombreChq          = '';
    LET iProdsCrd           = 0;
    LET cNombreCrd          = '';
    LET cAnioMes            = '';
    LET mSdoAcum            = 0.00;
    LET iDias               = 0;
    LET mSdoProm            = 0.00;
    LET dFechaMov           = '';
    LET cTransacc           = '';
    LET cDescripcion        = '';
    LET cNaturaleza         = '';
    LET mMonto              = 0.00;
    LET mSdoMin             = 0.00;
    LET mSdoMax             = 0.00;
    LET cMes                = '';
    LET dResiduo            = 0.00; 
    LET mCapVig1            = 0.00;
    LET mCapVig2            = 0.00;
    LET mCapVig3            = 0.00;
    LET mCapVig4            = 0.00;
    LET mCapVig5            = 0.00;
    LET mCapVig6            = 0.00;
    LET mCapVig7            = 0.00;
    LET mCapVig8            = 0.00;
    LET mCapVig9            = 0.00;
    LET mCapVig10           = 0.00;
    LET mCapVig11           = 0.00;
    LET mCapVig12           = 0.00;
    LET mCapVig13           = 0.00;
    LET mCapVig14           = 0.00;
    LET mCapVig15           = 0.00;
    LET mCapVig16           = 0.00;
    LET mCapVig17           = 0.00;
    LET mCapVig18           = 0.00;
    LET mCapVig19           = 0.00;
    LET mCapVig20           = 0.00;
    LET mCapVig21           = 0.00;
    LET mCapVig22           = 0.00;
    LET mCapVig23           = 0.00;
    LET mCapVig24           = 0.00;
    LET mCapVig25           = 0.00;
    LET mCapVig26           = 0.00;
    LET mCapVig27           = 0.00;
    LET mCapVig28           = 0.00;
    LET mCapVig29           = 0.00;
    LET mCapVig30           = 0.00;
    LET mCapVig31           = 0.00;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_segmentaprod.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = iDesErr;
            RETURN cCodRet, cCodRet2, cCodRet3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_segmentaprod.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LAS FECHAS A UTILIZAR
    SELECT fecha_hoy, pri_dia_mes
      INTO dFechaHoy, dPriDiaMes
      FROM sc_fechas
     WHERE empresa = pEmpresa;
    
    LET dUltDiaMesAnt = dPriDiaMes - 1 UNITS DAY;
    LET dFechaFin = dUltDiaMesAnt;
    LET dFechaIni = dPriDiaMes - 6 UNITS MONTH;
    LET iAnio = YEAR(dFechaFin) - 1;
    LET cAnioMesIni = iAnio||'01';
    LET cAnioMesFin = YEAR(dFechaFin)||LPAD(MONTH(dFechaFin), 2, '0');
    
    -- // OBTIENE LOS PARAMETROS A UTILIZAR
    SELECT valor
      INTO cProdEfectiva
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'RepRiesgos2000';     
    
    SELECT valor 
      INTO cFechConMovHis
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
    
    SELECT valor 
      INTO cFechConMovHisOld
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';
    
    SELECT valor 
      INTO cFechConMovHisOld2
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechaIniMovhisOld2';
    
    -- // TABLA TEMPORAL PARA INFORMACION DEMOGRAFICA
    CREATE TEMP TABLE tmp_segdemografica1(
        numcte          CHAR(20), 
        edad            SMALLINT, 
        sexo            CHAR(1), 
        zona            CHAR(60), 
        estado          CHAR(30)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL PARA OTROS PRODUCTOS
    CREATE TEMP TABLE tmp_segproductos1(
        numcte          CHAR(20),
        producto        CHAR(4),
        nombre          CHAR(40),
        fecha_alta      DATE,
        tipo            SMALLINT
    ) WITH NO LOG;
    CREATE INDEX idxtmp_segproductos_ctetpo1 ON tmp_segproductos1(numcte, tipo) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segproductos1;
    
    CREATE TEMP TABLE tmp_segdescripcion1(
        numcte          CHAR(20),
        fecha_insert    DATE,
        sucursal        CHAR(4),
        cuenta          CHAR(20),
        producto        CHAR(20),
        no_prods_chq    SMALLINT,
        producto_chq    CHAR(40),
        no_prods_crd    SMALLINT,
        producto_crd    CHAR(40)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL DE SALDOS
    CREATE TEMP TABLE tmp_segsaldos1(
        numcte          CHAR(20),
        cuenta          CHAR(20),
        producto        CHAR(20),
        aniomes         CHAR(6),
        sdo_prom        DECIMAL(18,2),
        sdo_min         DECIMAL(18,2),
        sdo_max         DECIMAL(18,2)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL PARA TRANSACCIONES    
    CREATE TEMP TABLE tmp_segtransacciones1(
        numcte          CHAR(20),
        cuenta          CHAR(20),
        fecha           DATE,
        transacc        CHAR(4),
        descripcion     CHAR(50),
        naturaleza      CHAR(1),
        monto           DECIMAL(14,2)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL PARA INFORMACION DEMOGRAFICA
    CREATE TEMP TABLE tmp_segdemografica2(
        numcte          CHAR(20), 
        edad            SMALLINT, 
        sexo            CHAR(1), 
        zona            CHAR(60), 
        estado          CHAR(30)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL PARA OTROS PRODUCTOS
    CREATE TEMP TABLE tmp_segproductos2(
        numcte          CHAR(20),
        producto        CHAR(4),
        nombre          CHAR(40),
        fecha_alta      DATE,
        tipo            SMALLINT
    ) WITH NO LOG;
    CREATE INDEX idxtmp_segproductos_ctetpo2 ON tmp_segproductos2(numcte, tipo) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segproductos2;
    
    CREATE TEMP TABLE tmp_segdescripcion2(
        numcte          CHAR(20),
        fecha_insert    DATE,
        sucursal        CHAR(4),
        cuenta          CHAR(20),
        producto        CHAR(20),
        no_prods_chq    SMALLINT,
        producto_chq    CHAR(40),
        no_prods_crd    SMALLINT,
        producto_crd    CHAR(40)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL DE SALDOS
    CREATE TEMP TABLE tmp_segsaldos2(
        numcte          CHAR(20),
        cuenta          CHAR(20),
        producto        CHAR(20),
        aniomes         CHAR(6),
        sdo_prom        DECIMAL(18,2),
        sdo_min         DECIMAL(18,2),
        sdo_max         DECIMAL(18,2)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL PARA TRANSACCIONES    
    CREATE TEMP TABLE tmp_segtransacciones2(
        numcte          CHAR(20),
        cuenta          CHAR(20),
        fecha           DATE,
        transacc        CHAR(4),
        descripcion     CHAR(50),
        naturaleza      CHAR(1),
        monto           DECIMAL(14,2)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL PARA INFORMACION DEMOGRAFICA
    CREATE TEMP TABLE tmp_segdemografica3(
        numcte          CHAR(20), 
        edad            SMALLINT, 
        sexo            CHAR(1), 
        zona            CHAR(60), 
        estado          CHAR(30)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL PARA OTROS PRODUCTOS
    CREATE TEMP TABLE tmp_segproductos3(
        numcte          CHAR(20),
        producto        CHAR(4),
        nombre          CHAR(40),
        fecha_alta      DATE,
        tipo            SMALLINT
    ) WITH NO LOG;
    CREATE INDEX idxtmp_segproductos_ctetpo3 ON tmp_segproductos3(numcte, tipo) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segproductos3;
    
    CREATE TEMP TABLE tmp_segdescripcion3(
        numcte          CHAR(20),
        fecha_insert    DATE,
        sucursal        CHAR(4),
        cuenta          CHAR(20),
        producto        CHAR(20),
        no_prods_chq    SMALLINT,
        producto_chq    CHAR(40),
        no_prods_crd    SMALLINT,
        producto_crd    CHAR(40)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL DE SALDOS
    CREATE TEMP TABLE tmp_segsaldos3(
        numcte          CHAR(20),
        cuenta          CHAR(20),
        producto        CHAR(20),
        aniomes         CHAR(6),
        sdo_prom        DECIMAL(18,2),
        sdo_min         DECIMAL(18,2),
        sdo_max         DECIMAL(18,2)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL PARA TRANSACCIONES    
    CREATE TEMP TABLE tmp_segtransacciones3(
        numcte          CHAR(20),
        cuenta          CHAR(20),
        fecha           DATE,
        transacc        CHAR(4),
        descripcion     CHAR(50),
        naturaleza      CHAR(1),
        monto           DECIMAL(14,2)
    ) WITH NO LOG;
    
    -- // TABLA TEMPORAL DE MOVS HISTORICOS DE LOS ULTIMOS 6 MESES
    SELECT {+INDEX(sc_movhis_old2 idx_movhisnew6_old2)}
           cuenta
      FROM sc_movhis_old2 
     WHERE fech_alt BETWEEN dFechaIni AND dFechaFin
       AND fech_alt >= cFechConMovHisOld2
       AND fech_alt < cFechConMovHisOld
       AND cancelad <> 'S'
       AND producto = cProdEfectiva
    UNION ALL
    SELECT {+INDEX(sc_movhis_old idx_movhisnew6_old)}
           cuenta
      FROM sc_movhis_old 
     WHERE fech_alt BETWEEN dFechaIni AND dFechaFin
       AND fech_alt >= cFechConMovHisOld
       AND fech_alt < cFechConMovHis
       AND cancelad <> 'S'
       AND producto = cProdEfectiva
    UNION ALL
    SELECT {+INDEX(sc_movhis idx_movhisnew6)}
           cuenta 
      FROM sc_movhis
     WHERE fech_alt BETWEEN dFechaIni AND dFechaFin
       AND fech_alt >= cFechConMovHis
       AND cancelad <> 'S'
       AND producto = cProdEfectiva
    INTO TEMP tmp_segmovimientos WITH NO LOG;
    CREATE INDEX idx_tmpmovs_cta ON tmp_segmovimientos(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_segmovimientos;
    
    -- // TABLA TEMPORAL DE CUENTAS EFECTIVAS QUE APERTURARON HACE MAS DE 6 MESES Y TIENEN TARJETA DE DEBITO ACTIVA
    SELECT mae.num_cte, mae.cuenta, mae.sdo_actual
      FROM sc_maechq mae,
           sc_maenoc noc,
           sc_tarjeta trj
     WHERE mae.empresa = pEmpresa
       AND mae.cuenta LIKE '10%'
       AND mae.producto = cProdEfectiva
       AND mae.status_cta IN('1','3','4','5')
       AND noc.empresa = mae.empresa
       AND noc.cuenta = mae.cuenta
       AND ( dUltDiaMesAnt - noc.fecha_alta ) > 180
       AND trj.cuenta = mae.cuenta
       AND trj.numcte = mae.num_cte
       AND trj.prodtarjeta = mae.producto
       AND trj.tipo_tarjeta = 'T'
       AND trj.status_tar = 'A'
    INTO TEMP tmp_segctas WITH NO LOG;
    CREATE INDEX idxtmp_segctas_cte ON tmp_segctas(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_segctas;
    
    SELECT num_cte, COUNT(*) AS no_ctas
      FROM tmp_segctas
     GROUP BY 1
    HAVING COUNT(*) < 2
    INTO TEMP tmp_segctes WITH NO LOG;
    CREATE INDEX idxtmp_segctes_cte ON tmp_segctes(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_segctes;
    
    SELECT cta.num_cte, cta.cuenta, cta.sdo_actual
      FROM tmp_segctas cta,
           tmp_segctes cte
     WHERE cta.num_cte = cte.num_cte
    INTO TEMP tmp_segcuentas WITH NO LOG;
    CREATE INDEX idxtmp_segcuentas_cta ON tmp_segcuentas(cuenta) USING BTREE;
    CREATE INDEX idxtmp_segcuentas_ctasdo ON tmp_segcuentas(cuenta, sdo_actual) USING BTREE;
    UPDATE STATISTICS HIGH FOR TABLE tmp_segcuentas;
    
    -- // CLIENTES SIN TRANSACCIONES EN LOS ULTIMOS 6 MESES CON SALDO MAYOR A CERO
    FOREACH
        SELECT FIRST 300000 num_cte, cuenta
          INTO cNumCte, cCuenta
          FROM tmp_segcuentas
         WHERE cuenta NOT IN(SELECT cuenta FROM tmp_segmovimientos)
           AND sdo_actual > 0.00
           
        SELECT cte.fecha_insert, cte.sucursal, pf.fecha_nac, pf.sexo, TRIM(zona.nombrezona)||' '||TRIM(zona.municipiozona), TRIM(edo.nombre)
          INTO dFechaInsert, cSucursal, dFechaNac, cSexo, cZona, cEstado
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf pf ON (pf.numcte = cte.numcte)
          LEFT OUTER JOIN bdinteg:si_direcciones_actual dir ON (dir.numcte = pf.numcte AND dir.tipo_dir = 1)
          LEFT OUTER JOIN bdinteg:si_catzonas zona ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
         WHERE cte.numcte = cNumCte;
         
        LET iEdad = TRUNC( ( ( dFechaHoy - dFechaNac) / 365 ), 0);
         
        INSERT INTO tmp_segdemografica1 VALUES(cNumCte, iEdad, cSexo, cZona, cEstado);
        
        DELETE FROM tmp_segproductos1
         WHERE numcte >= '000001001'
           AND tipo > 0;
        
        INSERT INTO tmp_segproductos1 
        SELECT num_cte, mae.producto, pro.nombre, noc.fecha_alta, 1
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc,
               bdicheq:sc_producto pro
         WHERE mae.num_cte = cNumCte
           AND mae.cuenta = noc.cuenta
           AND mae.producto <> cProdEfectiva
           AND mae.status_cta IN('1','3','4','5')
           AND pro.producto = mae.producto;
           
        INSERT INTO tmp_segproductos1
        SELECT num_cte, mae.cod_instrum, pro.nombre, mae.fecha_alta, 1
          FROM bdinvers:sv_maeinv mae,
               bdinvers:sv_instrum pro
         WHERE mae.num_cte = cNumCte
           AND mae.status_cta = '1'
           AND pro.cod_instrum = mae.cod_instrum;
           
        INSERT INTO tmp_segproductos1
        SELECT numcte, mae.num_producto, pro.nombre_prod, mae.fecha_apertura, 2
          FROM bdicred:sd_maecred mae,
               bdicred:sd_definicion pro
         WHERE mae.numcte = cNumCte
           AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
           AND pro.num_producto = mae.num_producto;
           
        INSERT INTO tmp_segproductos1
        SELECT numcte, mae.num_producto, pro.nombre_prod, mae.fecha_apertura, 2
          FROM bdicred:sd_maecredcrd mae,
               bdicred:sd_definicion pro
         WHERE mae.numcte = cNumCte
           AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
           AND pro.num_producto = mae.num_producto;
           
        LET iProdsChq = 0;
        LET iProdsCrd = 0;
        LET cNombreChq = '';
        LET cNombreCrd = '';
           
        SELECT COUNT(*)
          INTO iProdsChq
          FROM tmp_segproductos1
         WHERE numcte = cNumCte
           AND tipo = 1;
        
        FOREACH
            SELECT nombre
              INTO cNombreChq
              FROM tmp_segproductos1
             WHERE numcte = cNumCte
               AND tipo = 1
             ORDER BY fecha_alta
             
            LET cNombreChq = cNombreChq;
            EXIT FOREACH;
        END FOREACH;
        
        SELECT COUNT(*)
          INTO iProdsCrd
          FROM tmp_segproductos1
         WHERE numcte = cNumCte
           AND tipo = 2;
        
        FOREACH
            SELECT nombre
              INTO cNombreCrd
              FROM tmp_segproductos1
             WHERE numcte = cNumCte
               AND tipo = 2
             ORDER BY fecha_alta
            
            LET cNombreCrd = cNombreCrd;
            EXIT FOREACH;
        END FOREACH;
        
        INSERT INTO tmp_segdescripcion1 VALUES(cNumCte, dFechaInsert, cSucursal, cCuenta, 'CUENTA EFECTIVA', iProdsChq, cNombreChq, iProdsCrd, cNombreCrd); 
        
        FOREACH 
            SELECT aniomes, capvigacum, diacum,
                   capvig1, capvig2, capvig3, capvig4, capvig5, capvig6, capvig7, capvig8, capvig9, capvig10,
                   capvig11, capvig12, capvig13, capvig14, capvig15, capvig16, capvig17, capvig18, capvig19, capvig20,
                   capvig21, capvig22, capvig23, capvig24, capvig25, capvig26, capvig27, capvig28, capvig29, capvig30, capvig31
              INTO cAnioMes, mSdoAcum, iDias,
                   mCapVig1, mCapVig2, mCapVig3, mCapVig4, mCapVig5, mCapVig6, mCapVig7, mCapVig8, mCapVig9, mCapVig10,
                   mCapVig11, mCapVig12, mCapVig13, mCapVig14, mCapVig15, mCapVig16, mCapVig17, mCapVig18, mCapVig19, mCapVig20,
                   mCapVig21, mCapVig22, mCapVig23, mCapVig24, mCapVig25, mCapVig26, mCapVig27, mCapVig28, mCapVig29, mCapVig30, mCapVig31
              FROM sc_sdodiarioc_2015
             WHERE cuenta = cCuenta
               AND aniomes >= cAnioMesIni
               AND aniomes <= cAnioMesFin
            UNION
            SELECT aniomes, capvigacum, diacum,
                   capvig1, capvig2, capvig3, capvig4, capvig5, capvig6, capvig7, capvig8, capvig9, capvig10,
                   capvig11, capvig12, capvig13, capvig14, capvig15, capvig16, capvig17, capvig18, capvig19, capvig20,
                   capvig21, capvig22, capvig23, capvig24, capvig25, capvig26, capvig27, capvig28, capvig29, capvig30, capvig31
              FROM sc_sdodiarioc
             WHERE cuenta = cCuenta
               AND aniomes >= cAnioMesIni
               AND aniomes <= cAnioMesFin
           
            IF iDias > 0 THEN
                LET mSdoProm = mSdoAcum / iDias;
            ELSE
                LET mSdoProm = mSdoAcum;
            END IF;
            
            LET mSdoMin = 0.00;
            LET mSdoMax = 0.00;
            
            LET cMes = SUBSTR(cAnioMes, 5, 2);
            LET iAnio = SUBSTR(cAnioMes, 1, 4);
            LET dResiduo = MOD(iAnio, 4);
            
            IF cMes IN('01','03','05','07','08','10','12') THEN
                IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                IF mCapVig29 <  mSdoMin THEN LET mSdoMin = mCapVig29; END IF;
                IF mCapVig30 <  mSdoMin THEN LET mSdoMin = mCapVig30; END IF;
                IF mCapVig31 <  mSdoMin THEN LET mSdoMin = mCapVig31; END IF;
                
                IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                IF mCapVig29 >  mSdoMax THEN LET mSdoMax = mCapVig29; END IF;
                IF mCapVig30 >  mSdoMax THEN LET mSdoMax = mCapVig30; END IF;
                IF mCapVig31 >  mSdoMax THEN LET mSdoMax = mCapVig31; END IF;
            END IF;
            
            IF cMes IN('04','06','09','11') THEN
                IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                IF mCapVig29 <  mSdoMin THEN LET mSdoMin = mCapVig29; END IF;
                IF mCapVig30 <  mSdoMin THEN LET mSdoMin = mCapVig30; END IF;
                
                IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                IF mCapVig29 >  mSdoMax THEN LET mSdoMax = mCapVig29; END IF;
                IF mCapVig30 >  mSdoMax THEN LET mSdoMax = mCapVig30; END IF;
                IF mCapVig31 >  mSdoMax THEN LET mSdoMax = mCapVig31; END IF;
            END IF;
            
            IF cMes = '02' THEN
                IF dResiduo = 0 THEN
                    IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                    IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                    IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                    IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                    IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                    IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                    IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                    IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                    IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                    IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                    IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                    IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                    IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                    IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                    IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                    IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                    IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                    IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                    IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                    IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                    IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                    IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                    IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                    IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                    IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                    IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                    IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                    IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                    IF mCapVig29 <  mSdoMin THEN LET mSdoMin = mCapVig29; END IF;
                    
                    IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                    IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                    IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                    IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                    IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                    IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                    IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                    IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                    IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                    IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                    IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                    IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                    IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                    IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                    IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                    IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                    IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                    IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                    IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                    IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                    IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                    IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                    IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                    IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                    IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                    IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                    IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                    IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                    IF mCapVig29 >  mSdoMax THEN LET mSdoMax = mCapVig29; END IF;
                ELSE
                    IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                    IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                    IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                    IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                    IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                    IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                    IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                    IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                    IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                    IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                    IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                    IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                    IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                    IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                    IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                    IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                    IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                    IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                    IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                    IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                    IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                    IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                    IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                    IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                    IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                    IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                    IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                    IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                    
                    IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                    IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                    IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                    IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                    IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                    IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                    IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                    IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                    IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                    IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                    IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                    IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                    IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                    IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                    IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                    IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                    IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                    IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                    IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                    IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                    IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                    IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                    IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                    IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                    IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                    IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                    IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                    IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                END IF;
            END IF;
            
            INSERT INTO tmp_segsaldos1 VALUES(cNumCte, cCuenta, 'CUENTA EFECTIVA', cAnioMes, mSdoProm, mSdoMin, mSdoMax);
        END FOREACH;
        
        FOREACH
            SELECT {+INDEX(sc_movhis_old2 movhis1_old2)}
                   mov.fech_alt, mov.transacc, trx.descripcion, trx.naturaleza, mov.monto_tot
              INTO dFechaMov, cTransacc, cDescripcion, cNaturaleza, mMonto
              FROM sc_movhis_old2 mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt <= dFechaFin
               AND mov.fech_alt >= cFechConMovHisOld2
               AND mov.fech_alt < cFechConMovHisOld
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
            UNION ALL
            SELECT {+INDEX(sc_movhis_old movhis1)}
                   mov.fech_alt, mov.transacc, trx.descripcion, trx.naturaleza, mov.monto_tot
              FROM sc_movhis_old mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt <= dFechaFin
               AND mov.fech_alt >= cFechConMovHisOld
               AND mov.fech_alt < cFechConMovHis
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
            UNION ALL
            SELECT {+INDEX(sc_movhis idx_movhisnew4)}
                   mov.fech_alt, mov.transacc, trx.descripcion, trx.naturaleza, mov.monto_tot
              FROM sc_movhis mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt <= dFechaFin
               AND mov.fech_alt >= cFechConMovHis
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
             
            INSERT INTO tmp_segtransacciones1 VALUES(cNumCte, cCuenta, dFechaMov, cTransacc, cDescripcion, cNaturaleza, mMonto);
        END FOREACH;
    END FOREACH;
        
    -- // CLIENTES SIN TRANSACCIONES EN LOS ULTIMOS 6 MESES CON SALDO IGUAL O MENOR A CERO
    FOREACH
        SELECT FIRST 100000 num_cte, cuenta
          INTO cNumCte, cCuenta
          FROM tmp_segcuentas
         WHERE cuenta NOT IN(SELECT cuenta FROM tmp_segmovimientos)
           AND sdo_actual <= 0.00
           
        SELECT cte.fecha_insert, cte.sucursal, pf.fecha_nac, pf.sexo, TRIM(zona.nombrezona)||' '||TRIM(zona.municipiozona), TRIM(edo.nombre)
          INTO dFechaInsert, cSucursal, dFechaNac, cSexo, cZona, cEstado
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf pf ON (pf.numcte = cte.numcte)
          LEFT OUTER JOIN bdinteg:si_direcciones_actual dir ON (dir.numcte = pf.numcte AND dir.tipo_dir = 1)
          LEFT OUTER JOIN bdinteg:si_catzonas zona ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
         WHERE cte.numcte = cNumCte;
         
        LET iEdad = TRUNC( ( ( dFechaHoy - dFechaNac) / 365 ), 0);
         
        INSERT INTO tmp_segdemografica2 VALUES(cNumCte, iEdad, cSexo, cZona, cEstado);
        
        DELETE FROM tmp_segproductos2
         WHERE numcte >= '000001001'
           AND tipo > 0;
        
        INSERT INTO tmp_segproductos2 
        SELECT num_cte, mae.producto, pro.nombre, noc.fecha_alta, 1
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc,
               bdicheq:sc_producto pro
         WHERE mae.num_cte = cNumCte
           AND mae.cuenta = noc.cuenta
           AND mae.producto <> cProdEfectiva
           AND mae.status_cta IN('1','3','4','5')
           AND pro.producto = mae.producto;
           
        INSERT INTO tmp_segproductos2
        SELECT num_cte, mae.cod_instrum, pro.nombre, mae.fecha_alta, 1
          FROM bdinvers:sv_maeinv mae,
               bdinvers:sv_instrum pro
         WHERE mae.num_cte = cNumCte
           AND mae.status_cta = '1'
           AND pro.cod_instrum = mae.cod_instrum;
           
        INSERT INTO tmp_segproductos2
        SELECT numcte, mae.num_producto, pro.nombre_prod, mae.fecha_apertura, 2
          FROM bdicred:sd_maecred mae,
               bdicred:sd_definicion pro
         WHERE mae.numcte = cNumCte
           AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
           AND pro.num_producto = mae.num_producto;
           
        INSERT INTO tmp_segproductos2
        SELECT numcte, mae.num_producto, pro.nombre_prod, mae.fecha_apertura, 2
          FROM bdicred:sd_maecredcrd mae,
               bdicred:sd_definicion pro
         WHERE mae.numcte = cNumCte
           AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
           AND pro.num_producto = mae.num_producto;
           
        LET iProdsChq = 0;
        LET iProdsCrd = 0;
        LET cNombreChq = '';
        LET cNombreCrd = '';
           
        SELECT COUNT(*)
          INTO iProdsChq
          FROM tmp_segproductos2
         WHERE numcte = cNumCte
           AND tipo = 1;
           
        FOREACH
            SELECT nombre
              INTO cNombreChq
              FROM tmp_segproductos2
             WHERE numcte = cNumCte
               AND tipo = 1
             ORDER BY fecha_alta
             
            LET cNombreChq = cNombreChq;
            EXIT FOREACH;
        END FOREACH;
        
        SELECT COUNT(*)
          INTO iProdsCrd
          FROM tmp_segproductos2
         WHERE numcte = cNumCte
           AND tipo = 2;
        
        FOREACH
            SELECT nombre
              INTO cNombreCrd
              FROM tmp_segproductos2
             WHERE numcte = cNumCte
               AND tipo = 2
             ORDER BY fecha_alta
            
            LET cNombreCrd = cNombreCrd;
            EXIT FOREACH;
        END FOREACH;
        
        INSERT INTO tmp_segdescripcion2 VALUES(cNumCte, dFechaInsert, cSucursal, cCuenta, 'CUENTA EFECTIVA', iProdsChq, cNombreChq, iProdsCrd, cNombreCrd);    
        
        FOREACH 
            SELECT aniomes, capvigacum, diacum,
                   capvig1, capvig2, capvig3, capvig4, capvig5, capvig6, capvig7, capvig8, capvig9, capvig10,
                   capvig11, capvig12, capvig13, capvig14, capvig15, capvig16, capvig17, capvig18, capvig19, capvig20,
                   capvig21, capvig22, capvig23, capvig24, capvig25, capvig26, capvig27, capvig28, capvig29, capvig30, capvig31
              INTO cAnioMes, mSdoAcum, iDias,
                   mCapVig1, mCapVig2, mCapVig3, mCapVig4, mCapVig5, mCapVig6, mCapVig7, mCapVig8, mCapVig9, mCapVig10,
                   mCapVig11, mCapVig12, mCapVig13, mCapVig14, mCapVig15, mCapVig16, mCapVig17, mCapVig18, mCapVig19, mCapVig20,
                   mCapVig21, mCapVig22, mCapVig23, mCapVig24, mCapVig25, mCapVig26, mCapVig27, mCapVig28, mCapVig29, mCapVig30, mCapVig31
              FROM sc_sdodiarioc_2015
             WHERE cuenta = cCuenta
               AND aniomes >= cAnioMesIni
               AND aniomes <= cAnioMesFin
            UNION
            SELECT aniomes, capvigacum, diacum,
                   capvig1, capvig2, capvig3, capvig4, capvig5, capvig6, capvig7, capvig8, capvig9, capvig10,
                   capvig11, capvig12, capvig13, capvig14, capvig15, capvig16, capvig17, capvig18, capvig19, capvig20,
                   capvig21, capvig22, capvig23, capvig24, capvig25, capvig26, capvig27, capvig28, capvig29, capvig30, capvig31
              FROM sc_sdodiarioc
             WHERE cuenta = cCuenta
               AND aniomes >= cAnioMesIni
               AND aniomes <= cAnioMesFin
           
            IF iDias > 0 THEN
                LET mSdoProm = mSdoAcum / iDias;
            ELSE
                LET mSdoProm = mSdoAcum;
            END IF;
            
            LET mSdoMin = 0.00;
            LET mSdoMax = 0.00;
            
            LET cMes = SUBSTR(cAnioMes, 5, 2);
            LET iAnio = SUBSTR(cAnioMes, 1, 4);
            LET dResiduo = MOD(iAnio, 4);
            
            IF cMes IN('01','03','05','07','08','10','12') THEN
                IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                IF mCapVig29 <  mSdoMin THEN LET mSdoMin = mCapVig29; END IF;
                IF mCapVig30 <  mSdoMin THEN LET mSdoMin = mCapVig30; END IF;
                IF mCapVig31 <  mSdoMin THEN LET mSdoMin = mCapVig31; END IF;
                
                IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                IF mCapVig29 >  mSdoMax THEN LET mSdoMax = mCapVig29; END IF;
                IF mCapVig30 >  mSdoMax THEN LET mSdoMax = mCapVig30; END IF;
                IF mCapVig31 >  mSdoMax THEN LET mSdoMax = mCapVig31; END IF;
            END IF;
            
            IF cMes IN('04','06','09','11') THEN
                IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                IF mCapVig29 <  mSdoMin THEN LET mSdoMin = mCapVig29; END IF;
                IF mCapVig30 <  mSdoMin THEN LET mSdoMin = mCapVig30; END IF;
                
                IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                IF mCapVig29 >  mSdoMax THEN LET mSdoMax = mCapVig29; END IF;
                IF mCapVig30 >  mSdoMax THEN LET mSdoMax = mCapVig30; END IF;
                IF mCapVig31 >  mSdoMax THEN LET mSdoMax = mCapVig31; END IF;
            END IF;
            
            IF cMes = '02' THEN
                IF dResiduo = 0 THEN
                    IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                    IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                    IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                    IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                    IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                    IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                    IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                    IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                    IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                    IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                    IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                    IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                    IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                    IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                    IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                    IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                    IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                    IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                    IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                    IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                    IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                    IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                    IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                    IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                    IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                    IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                    IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                    IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                    IF mCapVig29 <  mSdoMin THEN LET mSdoMin = mCapVig29; END IF;
                    
                    IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                    IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                    IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                    IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                    IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                    IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                    IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                    IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                    IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                    IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                    IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                    IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                    IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                    IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                    IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                    IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                    IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                    IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                    IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                    IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                    IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                    IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                    IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                    IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                    IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                    IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                    IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                    IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                    IF mCapVig29 >  mSdoMax THEN LET mSdoMax = mCapVig29; END IF;
                ELSE
                    IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                    IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                    IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                    IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                    IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                    IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                    IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                    IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                    IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                    IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                    IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                    IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                    IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                    IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                    IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                    IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                    IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                    IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                    IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                    IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                    IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                    IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                    IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                    IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                    IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                    IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                    IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                    IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                    
                    IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                    IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                    IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                    IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                    IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                    IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                    IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                    IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                    IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                    IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                    IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                    IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                    IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                    IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                    IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                    IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                    IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                    IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                    IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                    IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                    IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                    IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                    IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                    IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                    IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                    IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                    IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                    IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                END IF;
            END IF;
            
            INSERT INTO tmp_segsaldos2 VALUES(cNumCte, cCuenta, 'CUENTA EFECTIVA', cAnioMes, mSdoProm, mSdoMin, mSdoMax);
        END FOREACH;
        
        FOREACH
            SELECT {+INDEX(sc_movhis_old2 movhis1_old2)}
                   mov.fech_alt, mov.transacc, trx.descripcion, trx.naturaleza, mov.monto_tot
              INTO dFechaMov, cTransacc, cDescripcion, cNaturaleza, mMonto
              FROM sc_movhis_old2 mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt <= dFechaFin
               AND mov.fech_alt >= cFechConMovHisOld2
               AND mov.fech_alt < cFechConMovHisOld
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
            UNION ALL
            SELECT {+INDEX(sc_movhis_old movhis1)}
                   mov.fech_alt, mov.transacc, trx.descripcion, trx.naturaleza, mov.monto_tot
              FROM sc_movhis_old mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt <= dFechaFin
               AND mov.fech_alt >= cFechConMovHisOld
               AND mov.fech_alt < cFechConMovHis
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
            UNION ALL
            SELECT {+INDEX(sc_movhis idx_movhisnew4)}
                   mov.fech_alt, mov.transacc, trx.descripcion, trx.naturaleza, mov.monto_tot
              FROM sc_movhis mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt <= dFechaFin
               AND mov.fech_alt >= cFechConMovHis
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
             
            INSERT INTO tmp_segtransacciones2 VALUES(cNumCte, cCuenta, dFechaMov, cTransacc, cDescripcion, cNaturaleza, mMonto);
        END FOREACH;
    END FOREACH;
          
    -- // CLIENTES CON TRANSACCIONES EN LOS ULTIMOS 6 MESES 
    FOREACH
        SELECT FIRST 2100000 num_cte, cuenta
          INTO cNumCte, cCuenta
          FROM tmp_segcuentas
         WHERE cuenta IN(SELECT cuenta FROM tmp_segmovimientos)
           
        SELECT cte.fecha_insert, cte.sucursal, pf.fecha_nac, pf.sexo, TRIM(zona.nombrezona)||' '||TRIM(zona.municipiozona), TRIM(edo.nombre)
          INTO dFechaInsert, cSucursal, dFechaNac, cSexo, cZona, cEstado
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf pf ON (pf.numcte = cte.numcte)
          LEFT OUTER JOIN bdinteg:si_direcciones_actual dir ON (dir.numcte = pf.numcte AND dir.tipo_dir = 1)
          LEFT OUTER JOIN bdinteg:si_catzonas zona ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
         WHERE cte.numcte = cNumCte;
         
        LET iEdad = TRUNC( ( ( dFechaHoy - dFechaNac) / 365 ), 0);
         
        INSERT INTO tmp_segdemografica3 VALUES(cNumCte, iEdad, cSexo, cZona, cEstado);
        
        DELETE FROM tmp_segproductos3
         WHERE numcte >= '000001001'
           AND tipo > 0;
        
        INSERT INTO tmp_segproductos3 
        SELECT num_cte, mae.producto, pro.nombre, noc.fecha_alta, 1
          FROM bdicheq:sc_maechq mae,
               bdicheq:sc_maenoc noc,
               bdicheq:sc_producto pro
         WHERE mae.num_cte = cNumCte
           AND mae.cuenta = noc.cuenta
           AND mae.producto <> cProdEfectiva
           AND mae.status_cta IN('1','3','4','5')
           AND pro.producto = mae.producto;
           
        INSERT INTO tmp_segproductos3
        SELECT num_cte, mae.cod_instrum, pro.nombre, mae.fecha_alta, 1
          FROM bdinvers:sv_maeinv mae,
               bdinvers:sv_instrum pro
         WHERE mae.num_cte = cNumCte
           AND mae.status_cta = '1'
           AND pro.cod_instrum = mae.cod_instrum;
           
        INSERT INTO tmp_segproductos3
        SELECT numcte, mae.num_producto, pro.nombre_prod, mae.fecha_apertura, 2
          FROM bdicred:sd_maecred mae,
               bdicred:sd_definicion pro
         WHERE mae.numcte = cNumCte
           AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
           AND pro.num_producto = mae.num_producto;
           
        INSERT INTO tmp_segproductos3
        SELECT numcte, mae.num_producto, pro.nombre_prod, mae.fecha_apertura, 2
          FROM bdicred:sd_maecredcrd mae,
               bdicred:sd_definicion pro
         WHERE mae.numcte = cNumCte
           AND mae.status_cred IN('AA','BA','BT','E1','E2','E3')
           AND pro.num_producto = mae.num_producto;
           
        LET iProdsChq = 0;
        LET iProdsCrd = 0;
        LET cNombreChq = '';
        LET cNombreCrd = '';
           
        SELECT COUNT(*)
          INTO iProdsChq
          FROM tmp_segproductos3
         WHERE numcte = cNumCte
           AND tipo = 1;
           
        FOREACH
            SELECT nombre
              INTO cNombreChq
              FROM tmp_segproductos3
             WHERE numcte = cNumCte
               AND tipo = 1
             ORDER BY fecha_alta
             
            LET cNombreChq = cNombreChq;
            EXIT FOREACH;
        END FOREACH;
        
        SELECT COUNT(*)
          INTO iProdsCrd
          FROM tmp_segproductos3
         WHERE numcte = cNumCte
           AND tipo = 2;
        
        FOREACH
            SELECT nombre
              INTO cNombreCrd
              FROM tmp_segproductos3
             WHERE numcte = cNumCte
               AND tipo = 2
             ORDER BY fecha_alta
            
            LET cNombreCrd = cNombreCrd;
            EXIT FOREACH;
        END FOREACH;
        
        INSERT INTO tmp_segdescripcion3 VALUES(cNumCte, dFechaInsert, cSucursal, cCuenta, 'CUENTA EFECTIVA', iProdsChq, cNombreChq, iProdsCrd, cNombreCrd);    
        
        FOREACH 
            SELECT aniomes, capvigacum, diacum,
                   capvig1, capvig2, capvig3, capvig4, capvig5, capvig6, capvig7, capvig8, capvig9, capvig10,
                   capvig11, capvig12, capvig13, capvig14, capvig15, capvig16, capvig17, capvig18, capvig19, capvig20,
                   capvig21, capvig22, capvig23, capvig24, capvig25, capvig26, capvig27, capvig28, capvig29, capvig30, capvig31
              INTO cAnioMes, mSdoAcum, iDias,
                   mCapVig1, mCapVig2, mCapVig3, mCapVig4, mCapVig5, mCapVig6, mCapVig7, mCapVig8, mCapVig9, mCapVig10,
                   mCapVig11, mCapVig12, mCapVig13, mCapVig14, mCapVig15, mCapVig16, mCapVig17, mCapVig18, mCapVig19, mCapVig20,
                   mCapVig21, mCapVig22, mCapVig23, mCapVig24, mCapVig25, mCapVig26, mCapVig27, mCapVig28, mCapVig29, mCapVig30, mCapVig31
              FROM sc_sdodiarioc_2015
             WHERE cuenta = cCuenta
               AND aniomes >= cAnioMesIni
               AND aniomes <= cAnioMesFin
            UNION
            SELECT aniomes, capvigacum, diacum,
                   capvig1, capvig2, capvig3, capvig4, capvig5, capvig6, capvig7, capvig8, capvig9, capvig10,
                   capvig11, capvig12, capvig13, capvig14, capvig15, capvig16, capvig17, capvig18, capvig19, capvig20,
                   capvig21, capvig22, capvig23, capvig24, capvig25, capvig26, capvig27, capvig28, capvig29, capvig30, capvig31
              FROM sc_sdodiarioc
             WHERE cuenta = cCuenta
               AND aniomes >= cAnioMesIni
               AND aniomes <= cAnioMesFin
           
            IF iDias > 0 THEN
                LET mSdoProm = mSdoAcum / iDias;
            ELSE
                LET mSdoProm = mSdoAcum;
            END IF;
            
            LET mSdoMin = 0.00;
            LET mSdoMax = 0.00;
            
            LET cMes = SUBSTR(cAnioMes, 5, 2);
            LET iAnio = SUBSTR(cAnioMes, 1, 4);
            LET dResiduo = MOD(iAnio, 4);
            
            IF cMes IN('01','03','05','07','08','10','12') THEN
                IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                IF mCapVig29 <  mSdoMin THEN LET mSdoMin = mCapVig29; END IF;
                IF mCapVig30 <  mSdoMin THEN LET mSdoMin = mCapVig30; END IF;
                IF mCapVig31 <  mSdoMin THEN LET mSdoMin = mCapVig31; END IF;
                
                IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                IF mCapVig29 >  mSdoMax THEN LET mSdoMax = mCapVig29; END IF;
                IF mCapVig30 >  mSdoMax THEN LET mSdoMax = mCapVig30; END IF;
                IF mCapVig31 >  mSdoMax THEN LET mSdoMax = mCapVig31; END IF;
            END IF;
            
            IF cMes IN('04','06','09','11') THEN
                IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                IF mCapVig29 <  mSdoMin THEN LET mSdoMin = mCapVig29; END IF;
                IF mCapVig30 <  mSdoMin THEN LET mSdoMin = mCapVig30; END IF;
                
                IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                IF mCapVig29 >  mSdoMax THEN LET mSdoMax = mCapVig29; END IF;
                IF mCapVig30 >  mSdoMax THEN LET mSdoMax = mCapVig30; END IF;
                IF mCapVig31 >  mSdoMax THEN LET mSdoMax = mCapVig31; END IF;
            END IF;
            
            IF cMes = '02' THEN
                IF dResiduo = 0 THEN
                    IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                    IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                    IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                    IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                    IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                    IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                    IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                    IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                    IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                    IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                    IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                    IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                    IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                    IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                    IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                    IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                    IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                    IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                    IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                    IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                    IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                    IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                    IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                    IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                    IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                    IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                    IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                    IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                    IF mCapVig29 <  mSdoMin THEN LET mSdoMin = mCapVig29; END IF;
                    
                    IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                    IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                    IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                    IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                    IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                    IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                    IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                    IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                    IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                    IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                    IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                    IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                    IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                    IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                    IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                    IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                    IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                    IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                    IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                    IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                    IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                    IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                    IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                    IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                    IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                    IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                    IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                    IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                    IF mCapVig29 >  mSdoMax THEN LET mSdoMax = mCapVig29; END IF;
                ELSE
                    IF mCapVig1  <> mSdoMin THEN LET mSdoMin = mCapVig1;  END IF;
                    IF mCapVig2  <  mSdoMin THEN LET mSdoMin = mCapVig2;  END IF;
                    IF mCapVig3  <  mSdoMin THEN LET mSdoMin = mCapVig3;  END IF;
                    IF mCapVig4  <  mSdoMin THEN LET mSdoMin = mCapVig4;  END IF;
                    IF mCapVig5  <  mSdoMin THEN LET mSdoMin = mCapVig5;  END IF;
                    IF mCapVig6  <  mSdoMin THEN LET mSdoMin = mCapVig6;  END IF;
                    IF mCapVig7  <  mSdoMin THEN LET mSdoMin = mCapVig7;  END IF;
                    IF mCapVig8  <  mSdoMin THEN LET mSdoMin = mCapVig8;  END IF;
                    IF mCapVig9  <  mSdoMin THEN LET mSdoMin = mCapVig9;  END IF;
                    IF mCapVig10 <  mSdoMin THEN LET mSdoMin = mCapVig10; END IF;
                    IF mCapVig11 <  mSdoMin THEN LET mSdoMin = mCapVig11; END IF;
                    IF mCapVig12 <  mSdoMin THEN LET mSdoMin = mCapVig12; END IF;
                    IF mCapVig13 <  mSdoMin THEN LET mSdoMin = mCapVig13; END IF;
                    IF mCapVig14 <  mSdoMin THEN LET mSdoMin = mCapVig14; END IF;
                    IF mCapVig15 <  mSdoMin THEN LET mSdoMin = mCapVig15; END IF;
                    IF mCapVig16 <  mSdoMin THEN LET mSdoMin = mCapVig16; END IF;
                    IF mCapVig17 <  mSdoMin THEN LET mSdoMin = mCapVig17; END IF;
                    IF mCapVig18 <  mSdoMin THEN LET mSdoMin = mCapVig18; END IF;
                    IF mCapVig19 <  mSdoMin THEN LET mSdoMin = mCapVig19; END IF;
                    IF mCapVig20 <  mSdoMin THEN LET mSdoMin = mCapVig20; END IF;
                    IF mCapVig21 <  mSdoMin THEN LET mSdoMin = mCapVig21; END IF;
                    IF mCapVig22 <  mSdoMin THEN LET mSdoMin = mCapVig22; END IF;
                    IF mCapVig23 <  mSdoMin THEN LET mSdoMin = mCapVig23; END IF;
                    IF mCapVig24 <  mSdoMin THEN LET mSdoMin = mCapVig24; END IF;
                    IF mCapVig25 <  mSdoMin THEN LET mSdoMin = mCapVig25; END IF;
                    IF mCapVig26 <  mSdoMin THEN LET mSdoMin = mCapVig26; END IF;
                    IF mCapVig27 <  mSdoMin THEN LET mSdoMin = mCapVig27; END IF;
                    IF mCapVig28 <  mSdoMin THEN LET mSdoMin = mCapVig28; END IF;
                    
                    IF mCapVig1  <> mSdoMax THEN LET mSdoMax = mCapVig1;  END IF;
                    IF mCapVig2  >  mSdoMax THEN LET mSdoMax = mCapVig2;  END IF;
                    IF mCapVig3  >  mSdoMax THEN LET mSdoMax = mCapVig3;  END IF;
                    IF mCapVig4  >  mSdoMax THEN LET mSdoMax = mCapVig4;  END IF;
                    IF mCapVig5  >  mSdoMax THEN LET mSdoMax = mCapVig5;  END IF;
                    IF mCapVig6  >  mSdoMax THEN LET mSdoMax = mCapVig6;  END IF;
                    IF mCapVig7  >  mSdoMax THEN LET mSdoMax = mCapVig7;  END IF;
                    IF mCapVig8  >  mSdoMax THEN LET mSdoMax = mCapVig8;  END IF;
                    IF mCapVig9  >  mSdoMax THEN LET mSdoMax = mCapVig9;  END IF;
                    IF mCapVig10 >  mSdoMax THEN LET mSdoMax = mCapVig10; END IF;
                    IF mCapVig11 >  mSdoMax THEN LET mSdoMax = mCapVig11; END IF;
                    IF mCapVig12 >  mSdoMax THEN LET mSdoMax = mCapVig12; END IF;
                    IF mCapVig13 >  mSdoMax THEN LET mSdoMax = mCapVig13; END IF;
                    IF mCapVig14 >  mSdoMax THEN LET mSdoMax = mCapVig14; END IF;
                    IF mCapVig15 >  mSdoMax THEN LET mSdoMax = mCapVig15; END IF;
                    IF mCapVig16 >  mSdoMax THEN LET mSdoMax = mCapVig16; END IF;
                    IF mCapVig17 >  mSdoMax THEN LET mSdoMax = mCapVig17; END IF;
                    IF mCapVig18 >  mSdoMax THEN LET mSdoMax = mCapVig18; END IF;
                    IF mCapVig19 >  mSdoMax THEN LET mSdoMax = mCapVig19; END IF;
                    IF mCapVig20 >  mSdoMax THEN LET mSdoMax = mCapVig20; END IF;
                    IF mCapVig21 >  mSdoMax THEN LET mSdoMax = mCapVig21; END IF;
                    IF mCapVig22 >  mSdoMax THEN LET mSdoMax = mCapVig22; END IF;
                    IF mCapVig23 >  mSdoMax THEN LET mSdoMax = mCapVig23; END IF;
                    IF mCapVig24 >  mSdoMax THEN LET mSdoMax = mCapVig24; END IF;
                    IF mCapVig25 >  mSdoMax THEN LET mSdoMax = mCapVig25; END IF;
                    IF mCapVig26 >  mSdoMax THEN LET mSdoMax = mCapVig26; END IF;
                    IF mCapVig27 >  mSdoMax THEN LET mSdoMax = mCapVig27; END IF;
                    IF mCapVig28 >  mSdoMax THEN LET mSdoMax = mCapVig28; END IF;
                END IF;
            END IF;
            
            INSERT INTO tmp_segsaldos3 VALUES(cNumCte, cCuenta, 'CUENTA EFECTIVA', cAnioMes, mSdoProm, mSdoMin, mSdoMax);
        END FOREACH;
        
        FOREACH
            SELECT {+INDEX(sc_movhis_old2 movhis1_old2)}
                   mov.fech_alt, mov.transacc, trx.descripcion, trx.naturaleza, mov.monto_tot
              INTO dFechaMov, cTransacc, cDescripcion, cNaturaleza, mMonto
              FROM sc_movhis_old2 mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt <= dFechaFin
               AND mov.fech_alt >= cFechConMovHisOld2
               AND mov.fech_alt < cFechConMovHisOld
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
            UNION ALL
            SELECT {+INDEX(sc_movhis_old movhis1)}
                   mov.fech_alt, mov.transacc, trx.descripcion, trx.naturaleza, mov.monto_tot
              FROM sc_movhis_old mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt <= dFechaFin
               AND mov.fech_alt >= cFechConMovHisOld
               AND mov.fech_alt < cFechConMovHis
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
            UNION ALL
            SELECT {+INDEX(sc_movhis idx_movhisnew4)}
                   mov.fech_alt, mov.transacc, trx.descripcion, trx.naturaleza, mov.monto_tot
              FROM sc_movhis mov,
                   bdinteg:si_transacc trx
             WHERE mov.empresa = pEmpresa
               AND mov.cuenta = cCuenta
               AND mov.fech_alt <= dFechaFin
               AND mov.fech_alt >= cFechConMovHis
               AND mov.cancelad <> 'S'
               AND mov.transacc = trx.numero
               AND trx.sistema = '01'
               AND trx.se_emite_edocta = 'S'
             
            INSERT INTO tmp_segtransacciones3 VALUES(cNumCte, cCuenta, dFechaMov, cTransacc, cDescripcion, cNaturaleza, mMonto);
        END FOREACH;
    END FOREACH;
    
    CREATE INDEX idxtmp_segdemografica_cte1 ON tmp_segdemografica1(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segdemografica1;
    
    CREATE INDEX idxtmp_segdescripcion_cte1 ON tmp_segdescripcion1(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segdescripcion1;
    
    CREATE INDEX idxtmp_segsaldos_cte1 ON tmp_segsaldos1(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segsaldos1;
    
    CREATE INDEX idxtmp_segtransacciones_cte1 ON tmp_segtransacciones1(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segtransacciones1;
    
    CREATE INDEX idxtmp_segdemografica_cte2 ON tmp_segdemografica2(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segdemografica2;
    
    CREATE INDEX idxtmp_segdescripcion_cte2 ON tmp_segdescripcion2(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segdescripcion2;
    
    CREATE INDEX idxtmp_segsaldos_cte2 ON tmp_segsaldos2(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segsaldos2;
    
    CREATE INDEX idxtmp_segtransacciones_cte2 ON tmp_segtransacciones2(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segtransacciones2;
    
    CREATE INDEX idxtmp_segdemografica_cte3 ON tmp_segdemografica3(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segdemografica3;
    
    CREATE INDEX idxtmp_segdescripcion_cte3 ON tmp_segdescripcion3(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segdescripcion3;
    
    CREATE INDEX idxtmp_segsaldos_cte3 ON tmp_segsaldos3(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segsaldos3;
    
    CREATE INDEX idxtmp_segtransacciones_cte3 ON tmp_segtransacciones3(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_segtransacciones3;
    
    END;

    RETURN cCodRet, cCodRet2, cCodRet3;

END PROCEDURE;