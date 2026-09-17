CREATE PROCEDURE "informix".sp_edoctaconsolidado(pEmpresa CHAR(3),
									 pCuenta CHAR(20),
									 pAnioMes CHAR(6),
									 pUsuario char(10),
									 p_iConsulta INTEGER)

RETURNING CHAR(5), CHAR(50);

    DEFINE vCodRet    CHAR(5);
    DEFINE vSqlErr, vIsamErr INTEGER;
    DEFINE vCiclo 	integer;
    DEFINE dFechaMov1,dFechaInicial, dFechaFinal,dFechaini DATE;
    DEFINE cDescripcionFin, cDescripcion CHAR(50);
    DEFINE mRetiro, mDeposito, mMonto,mSaldoActual MONEY(18, 2);
    DEFINE cNaturaleza CHAR(1);
    DEFINE cSucursal CHAR(50);
    DEFINE cNombre char(60);
    DEFINE cNomSucursal char(130);
    DEFINE cTransaccion CHAR(5);
    DEFINE cMes Char(2);
    DEFINE vconsmovhis CHAR(10);
    DEFINE vconsmovhisold CHAR(10);
    DEFINE vconsmovhisold2 CHAR(10);

    LET mSaldoActual =0;
    LET cNombre ="";
    LET cNomSucursal="";
    LET dFechaini="";
    LET cTransaccion="";
    LET vCodRet = "0000";
    LET cDescripcionFin = "";
    LET cDescripcion = "";
    LET mRetiro = 0;
    LET mDeposito = 0;
    LET vCiclo = 0;
    LET dFechaMov1 = "";
    LET pCuenta = TRIM(pCuenta);
    LET cSucursal = "";
    LET cMes="";

    -- set debug file to "/tmp/sp_edoctaconsolidado.out";
    -- trace on;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        IF vSqlErr != 0 THEN
            LET vCodRet = vSqlErr;
            LET cDescripcionFin = 'Excepcion no cotrolada';
            RETURN vCodRet, cDescripcionFin;
        END IF;
    END EXCEPTION;

    -- // VALIDACION DE PARAMETROS DE ENTRADA
    LET cMes= SUBSTR(pAnioMes, 5,2);

    IF pEmpresa="" OR pEmpresa IS NULL OR
       pCuenta ="" OR pCuenta IS NULL OR
       pAnioMes ="" OR pAnioMes IS NULL OR  LENGTH(pAnioMes )<>6 OR
       cMes > '12' OR cMes = '00' THEN
        LET vCodRet = '840'; -- Parametros no vÃ¡dos
        LET cDescripcionFin = 'Problemas con los parÃ¡tros';
        RETURN vCodRet, cDescripcionFin;
    END IF;

    -- // LIMPIO TABLA PARA REG. NUEVOS
    --DELETE FROM  vedoctamov
    -- WHERE cod_usuario= pUsuario;

    -- // VALIDACION DE CUENTA, PARA ESTADO DE CUENTA CONSOLIDADO.
    IF NOT EXISTS (SELECT 1 FROM bdicheq:sc_ctaedoesp WHERE empresa = pEmpresa AND  cuenta = pCuenta) THEN
        LET vCodRet = '850';
        LET cDescripcionFin = 'Cuenta no valida para estado de cuenta consolidado';
        RETURN vCodRet, cDescripcionFin;
    END IF;

    -- // EL SALDO ACTUAL DE LA CUENTA, LA FECHA DE INICIO Y FECHA FINAL DEL PERIODO DEL ESTADO DE CUENTA.
    SELECT sdo_actual, fechaini, fechafin
      INTO mSaldoActual, dFechaInicial, dFechaFinal
      FROM informix.sc_maehis
     WHERE empresa = pEmpresa
       AND cuenta = pCuenta
       AND aniomes=pAnioMes;

    SELECT valor
      INTO vconsmovhis
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';

    SELECT valor
      INTO vconsmovhisold
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';

    SELECT valor
      INTO vconsmovhisold2
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechaIniMovhisOld2';

    FOREACH
        -- // OBTIENE LA TRANSACCION, SUCURSAL, LA FECHA ALTA Y LA SUMATORIA DE LOS MOVIMIENTOS, QUE CORRESPONDAN AL LA CLAUSULA WHERE
        SELECT {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
               a.transacc, b.naturaleza, a.sucursal, a.fech_alt, sum(a.monto_tot)
          INTO cTransaccion,cNaturaleza,cSucursal, dFechaMov1, mMonto
          FROM bdicheq:sc_movhis a,
               bdinteg:si_transacc b
         WHERE a.empresa = pEmpresa
           AND a.cuenta = pCuenta
           AND a.fech_alt BETWEEN dFechaInicial AND dFechaFinal
           AND a.fech_alt >= vconsmovhis
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.empresa = a.empresa
           AND b.numero = a.transacc
           AND b.se_emite_edocta = 'S'
         GROUP BY a.transacc, b.naturaleza, a.sucursal, a.fech_alt

        UNION ALL

        SELECT {+INDEX(bdicheq:sc_movhis_old movhis1)}
               a.transacc, b.naturaleza, a.sucursal, a.fech_alt, sum(a.monto_tot)
          FROM bdicheq:sc_movhis_old a,
               bdinteg:si_transacc b
         WHERE a.empresa = pEmpresa
           AND a.cuenta = pCuenta
           AND a.fech_alt BETWEEN dFechaInicial AND dFechaFinal
           AND a.fech_alt >= vconsmovhisold
           AND a.fech_alt < vconsmovhis
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.empresa = a.empresa
           AND b.numero = a.transacc
           AND b.se_emite_edocta = 'S'
         GROUP BY a.transacc, b.naturaleza, a.sucursal, a.fech_alt

        UNION ALL

        SELECT {+INDEX(bdicheq:sc_movhis_old2 movhis1_old2)}
               a.transacc, b.naturaleza, a.sucursal, a.fech_alt, sum(a.monto_tot)
          FROM bdicheq:sc_movhis_old2 a,
               bdinteg:si_transacc b
         WHERE a.empresa = pEmpresa
           AND a.cuenta = pCuenta
           AND a.fech_alt BETWEEN dFechaInicial AND dFechaFinal
           AND a.fech_alt >= vconsmovhisold2
           AND a.fech_alt < vconsmovhisold
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.empresa = a.empresa
           AND b.numero = a.transacc
           AND b.se_emite_edocta = 'S'
         GROUP BY a.transacc, b.naturaleza, a.sucursal, a.fech_alt

        UNION ALL

        SELECT {+INDEX(bdicheq:sc_movhis_old3 movhis1_old3)}
               a.transacc, b.naturaleza, a.sucursal, a.fech_alt, sum(a.monto_tot)
          FROM bdicheq:sc_movhis_old3 a,
               bdinteg:si_transacc b
         WHERE a.empresa = pEmpresa
           AND a.cuenta = pCuenta
           AND a.fech_alt BETWEEN dFechaInicial AND dFechaFinal
           AND a.fech_alt < vconsmovhisold2
           AND a.cancelad <> 'S'
           AND a.transacc = b.numero
           AND b.empresa = a.empresa
           AND b.numero = a.transacc
           AND b.se_emite_edocta = 'S'
         GROUP BY a.transacc, b.naturaleza, a.sucursal, a.fech_alt

         ORDER BY a.fech_alt DESC, b.naturaleza desc, sucursal ASC

        -- // SE OBTIENE LA DESCRIPCION DE LA TRANSACCION Y LA NATURALEZA
        SELECT TRIM(descripcion) AS descripcion
          INTO cDescripcion
          FROM bdinteg:si_transacc
         wHERE numero = cTransaccion;

        -- // OBTIENE EL NOMBRE DE LA SUCURSAL
        SELECT nombre
          INTO cNombre
          FROM bdinteg:si_sucursales
         WHERE sucursal = cSucursal;

        -- // SE OBTIENE LA CADENA CON EL NÃ?ERO DE SUCURSAL, EL NOMBRE Y LA FECHA HORA DEL MOVIMIENTO
        LET cNomSucursal = trim(cSucursal)  || ' - ' ||NVL(TRIM(cNombre),'');
        LET mRetiro = 0;
        LET mDeposito = 0;

        -- // VALIDACION DE LOS MOVIMIENTOS, SI ES CARGO, ABONO O REGRESION
        IF cNaturaleza = 'C' THEN
            LET mRetiro = mMonto;
        ELIF cNaturaleza = 'A' THEN
            LET mDeposito = mMonto;
        END IF;

        -- // CALCULA EL SALDO DE LA CUENTA
        LET mSaldoActual = mSaldoActual - mDeposito +  mRetiro;

        -- // SE INCREMENTA, EN CADA REGISTRO
        LET vCiclo = vCiclo + 1;

        -- // ALMACENA LOS DATOS OBTENIDOS EN LAS CONSULTAS ANTERIORES
        Insert Into vedoctamov (empresa,cod_usuario,secuencia,cuenta,fechamov,referencia,descripcion,retiro,deposito,
                                saldo,generico_1,generico_2,generico_3,generico_4,generico_5,generico_6,consulta)
        Values
        (pEmpresa,pUsuario, vCiclo, pCuenta, dFechaMov1,'','', mRetiro, mDeposito , mSaldoActual,cDescripcion,cNomSucursal,'','','','', p_iConsulta );

        LET mMonto = 0;
    END FOREACH;

    LET cDescripcionFin = 'Estado de cuenta generado';

    RETURN Trim(vCodRet), cDescripcionFin;

    END
END PROCEDURE

DOCUMENT
'DESCRIPCION: Genera el estado de cuenta consolidado, obtiene la sumatoria del monto de los movimientos agrupados por sucursal, por transaccion y fecha',
'AUTOR: Cristian Valentina Aguilar',
'FECHA: Mayo 2009',
'VERSION: 20090504',
'BD: BDICHEQ',

'DESCRIPCION: La funcionalidad es la misma, solo cambio la presentacion los movimientos ya se ordenan por sucursal en orden ascendente',
'Modificó: Cristian Valentina Aguilar',
'FECHA: Mayo 2009',
'VERSION: 20090521',
'BD: BDICHEQ',

'DESCRIPCION: Se modifica para que no borre la tabla vedocta',
'Modificó: Jose Angel Lopez',
'FECHA: 15/07/2010',
'VERSION: 20100715',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".corrige_sdodiarioc(pempresa char(3))
    
RETURNING CHAR(5), CHAR(5), INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE nComit           SMALLINT;
    DEFINE vcuantos         INTEGER;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vfecha_con       DATE;
    DEFINE vpri_hab_mes     DATE;
    DEFINE vdia             CHAR(2);
    DEFINE vaniomes         CHAR(6);
    
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    DEFINE vmin_cta         CHAR(20);
    DEFINE vmax_cta         CHAR(20);
    
    DEFINE vcuenta          CHAR(20);
    DEFINE vsucursal        CHAR(4);
    DEFINE vsdo_dia_ant     MONEY(18,2);
    DEFINE vimp_chq_sbg     MONEY(18,2);
    DEFINE vint_acum        MONEY(18,2);
    DEFINE vfecha_alta      DATE;
    DEFINE vprovint         MONEY(18,2);
    DEFINE vdesprov         MONEY(18,2);
    DEFINE vpagoint         MONEY(18,2);
    DEFINE vcap_ant         MONEY(18,2);
    
    BEGIN

    ON EXCEPTION SET sql_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_sdodiarioc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_sdodiarioc.out";
    --- TRACE ON;

    LET vcodret1  = "000";
    LET vcodret2  = "000";
    LET sql_err   = 0;
    LET isam_err  = 0;
    LET nComit    = 0;
    LET vcuantos  = -1;
    
    LET vfecha_hoy   = '07/10/2010';
    LET vfecha_ant   = '07/09/2010';
    LET vfecha_con   = '07/08/2010';
    LET vpri_hab_mes = '07/01/2010';
    LET vdia         = DAY(vfecha_ant);
    LET vaniomes     = YEAR(vfecha_ant)||LPAD(MONTH(vfecha_ant),2,'0');
    
    LET vmincta  = '';
    LET vmaxcta  = '';
    LET vmin_cta = '';
    LET vmax_cta = '';
    
    LET vcuenta      = ''; 
    LET vsucursal    = '';
    LET vsdo_dia_ant = 0.00;
    LET vimp_chq_sbg = 0.00;
    LET vint_acum    = 0.00;
    LET vfecha_alta  = '';
    LET vprovint     = 0.00;
    LET vdesprov     = 0.00;
    LET vpagoint     = 0.00;
    LET vcap_ant     = 0.00;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_movhis;
    
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = pempresa
       AND cuenta BETWEEN vmincta AND vmaxcta
       AND fech_alt = vfecha_ant
       AND cancelad != 'S'
       AND transacc = '3381'
      INTO TEMP tmp_provint WITH NO LOG;
    CREATE INDEX idx_provint ON tmp_provint(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_provint;
    
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = pempresa
       AND cuenta BETWEEN vmincta AND vmaxcta
       AND fech_alt = vfecha_ant
       AND cancelad != 'S'
       AND transacc = '3382'
      INTO TEMP tmp_desprov WITH NO LOG;
    CREATE INDEX idx_desprov ON tmp_desprov(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_desprov;
    
    SELECT {+INDEX(sc_movhis idx_movhisnew4)}
           cuenta, monto_tot
      FROM sc_movhis
     WHERE empresa = pempresa
       AND cuenta BETWEEN vmincta AND vmaxcta
       AND fech_alt = vfecha_ant
       AND cancelad != 'S'
       AND transacc = '3276'
      INTO TEMP tmp_pagoint WITH NO LOG;
    CREATE INDEX idx_pagoint ON tmp_pagoint(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_pagoint;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmin_cta, vmax_cta
      FROM maechq_10Jul2010;
    
    FOREACH WITH HOLD
        SELECT chq.cuenta, chq.sucursal, chq.sdo_dia_ant, chq.imp_chq_sbg, noc.int_acum, noc.fecha_alta
          INTO vcuenta, vsucursal, vsdo_dia_ant, vimp_chq_sbg, vint_acum, vfecha_alta
          FROM maechq_10jul2010 chq, 
               maenoc_10jul2010 noc
         WHERE chq.empresa = pempresa
           AND chq.cuenta BETWEEN vmin_cta AND vmax_cta
           AND chq.status_cta != '2'
           AND noc.empresa = chq.empresa
           AND noc.cuenta = chq.cuenta
    
        IF vcuantos = -1 THEN
            LET nComit = 1;
            LET vcuantos = 0;
            BEGIN WORK;
        END IF;
        
        IF vimp_chq_sbg < 0 THEN
            LET vimp_chq_sbg = vimp_chq_sbg * -1;
        END IF

        LET vsdo_dia_ant = vsdo_dia_ant - vimp_chq_sbg;
        
        -- // PROVISIONES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vprovint 
          FROM tmp_provint
         WHERE cuenta = vcuenta;
         
        -- // DESPROVISIONES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vdesprov
          FROM tmp_desprov
         WHERE cuenta = vcuenta;
         
        -- // PAGO DE INTERESES
        SELECT NVL(SUM(monto_tot), 0.00)
          INTO vpagoint
          FROM tmp_pagoint
         WHERE cuenta = vcuenta;
        
        IF DAY(vfecha_alta) = DAY(vfecha_hoy) THEN
            CALL sp_capintafecha(vcuenta, vfecha_con)
            RETURNING vcodret1, vcap_ant, vint_acum;
        END IF;
        
        IF vfecha_hoy = vpri_hab_mes THEN 
            IF DAY(vfecha_alta) <> DAY(vfecha_hoy) THEN 
                LET vint_acum = vprovint;
            END IF;
        ELSE 
            LET vprovint = vprovint - vdesprov;
            LET vint_acum = ((vint_acum + vprovint) - vpagoint);
        END IF; 
        
        -- // Actualiza tabla de saldos diarios y provisiones no capitalizadas..
        CALL sp_actsdodiarioc(vcuenta, vaniomes, vsucursal, vsdo_dia_ant, vint_acum, vdia) 
        RETURNING vcodret1;
        
        LET vcuantos = vcuantos + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta      = ''; 
        LET vsucursal    = '';
        LET vsdo_dia_ant = 0.00;
        LET vimp_chq_sbg = 0.00;
        LET vint_acum    = 0.00;
        LET vfecha_alta  = '';
        LET vprovint     = 0.00;
        LET vdesprov     = 0.00;
        LET vpagoint     = 0.00;
        LET vcap_ant     = 0.00;
    END FOREACH;

    IF nComit = 1 THEN
        COMMIT WORK;
        LET nComit = 0;
    END IF;

    END;

    RETURN vcodret1, vcodret2, vcuantos;

END PROCEDURE;