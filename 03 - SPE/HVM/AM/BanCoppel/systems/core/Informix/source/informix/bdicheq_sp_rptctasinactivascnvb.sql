CREATE PROCEDURE "informix".sp_rptctasinactivascnvb( pEmpresa CHAR(3), pTipoEjec SMALLINT )
RETURNING CHAR(5), INTEGER;
       
    DEFINE Sql_Err                  INTEGER;
    DEFINE Isam_Err                 INTEGER;
    DEFINE Desc_Err                 CHAR(50);
    DEFINE vCodRet1                 CHAR(5);
    DEFINE vCodRet2                 CHAR(5);
    DEFINE vCodRet3                 CHAR(50);
    DEFINE vContador                INTEGER;
    DEFINE vContador2               INTEGER;
    DEFINE vdFechMovHisOld4         DATE;
    DEFINE vdFechMovHisOld3         DATE;
    DEFINE vdFechMovHisOld2         DATE;
    DEFINE vdFechMovHisOld          DATE;
    DEFINE vdFechMovHis             DATE;
    DEFINE vcCuenta                 CHAR(20);
    DEFINE vcProducto               CHAR(40);
    DEFINE vcNumCte                 CHAR(20);
    DEFINE vcTarjeta                CHAR(16);
    DEFINE vcSucursal               CHAR(4);
    DEFINE vcNombreCte              CHAR(100);
    DEFINE vmSdoActual              DECIMAL(18,2);
    DEFINE vdFechaUltDep            DATE;
    DEFINE vdFechaUltRet            DATE;
    DEFINE vcDomicilio              CHAR(200);
    DEFINE vcCalle                  CHAR(40);
    DEFINE vcNoExt                  CHAR(10);
    DEFINE vcNoInt                  CHAR(10);
    DEFINE vcDepto                  CHAR(10);
    DEFINE vcColonia                CHAR(40);
    DEFINE vcMuicipio               CHAR(30);
    DEFINE vcCiudad                 CHAR(20);
    DEFINE vcEstado                 CHAR(10);
    DEFINE vcCodPos                 CHAR(10);
    DEFINE vdFechaNotific           DATE;
    DEFINE vmSdoInform              DECIMAL(18,2);
    DEFINE vdFechaInactividad       DATE;
    DEFINE vdFechaMov               DATE;
    DEFINE vmMontoMov               DECIMAL(14,2);
    DEFINE iExisteConcentra         SMALLINT;
    DEFINE vdFechaConcentra         DATE;
    DEFINE vmSdoConcentra           DECIMAL(18,2);
    DEFINE vcUsuarioConcentra       CHAR(8);
    DEFINE vcResulConcentra         CHAR(10);
    DEFINE vcFolioConcentra         CHAR(16);
    DEFINE vdFechaDesconcentra      DATE;
    DEFINE vmSdoDesconcentra        DECIMAL(18,2);
    DEFINE vcUsuarioDesconcentra    CHAR(8);
    DEFINE vcFolioDesconcentra      CHAR(16);
    DEFINE vdFechaReConcentra       DATE;
    DEFINE vmSdoReConcentra         DECIMAL(18,2);
    DEFINE vcResulReConcentra       CHAR(10);
    DEFINE vcFolioReConcentra       CHAR(16);
    DEFINE vdFechaTraspBenef        DATE;
    DEFINE vmSdoTraspBenef          DECIMAL(18,2);
    DEFINE vcDescTraspBenef         CHAR(10);
    DEFINE vcResulTraspBenef        CHAR(10);
    DEFINE vcFolioTraspBenef        CHAR(16);
    DEFINE vcUsuarioTraspBenef      CHAR(8);
    DEFINE vdValorSM                DECIMAL(14,2);
    DEFINE vdFechaMin               DATE;
    DEFINE vcStatusMov              CHAR(1);
    
    LET Sql_Err	= 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '000';
    LET vCodRet2 = '';
    LET vCodRet3 = '';
    LET vContador = 0;
    LET vContador2 = 0;
    LET vdFechMovHisOld4 = '';
    LET vdFechMovHisOld3 = '';
    LET vdFechMovHisOld2 = '';
    LET vdFechMovHisOld = '';
    LET vdFechMovHis = '';
    LET vcCuenta = '';
    LET vcProducto = '';
    LET vcNumCte = '';
    LET vcTarjeta = '';
    LET vcSucursal = '';
    LET vcNombreCte = '';
    LET vmSdoActual = 0.00;
    LET vdFechaUltDep = '';
    LET vdFechaUltRet = '';
    LET vcDomicilio = '';
    LET vcCalle = '';
    LET vcNoExt = '';
    LET vcNoInt = '';
    LET vcDepto = '';
    LET vcColonia = '';
    LET vcMuicipio = '';
    LET vcCiudad = '';
    LET vcEstado = '';
    LET vcCodPos = '';
    LET vdFechaNotific = '';
    LET vmSdoInform = '';
    LET vdFechaInactividad = '';
    LET vdFechaMov = '';
    LET vmMontoMov = 0.00;
    LET iExisteConcentra = 0;
    LET vdFechaConcentra = '';
    LET vmSdoConcentra = 0.00;
    LET vcUsuarioConcentra = '';
    LET vcResulConcentra = '';
    LET vcFolioConcentra = '';
    LET vdFechaDesconcentra = '';
    LET vmSdoDesconcentra = 0.00;
    LET vcUsuarioDesconcentra = '';
    LET vcFolioDesconcentra = '';
    LET vdFechaReConcentra = '';
    LET vmSdoReConcentra = 0.00;
    LET vcResulReConcentra = '';
    LET vcFolioReConcentra = '';
    LET vdFechaTraspBenef = '';
    LET vmSdoTraspBenef = 0.00;
    LET vcDescTraspBenef = '';
    LET vcResulTraspBenef = '';
    LET vcFolioTraspBenef = '';
    LET vcUsuarioTraspBenef = '';
    LET vdValorSM = 0.00;
    LET vdFechaMin = '';
    LET vcStatusMov = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/jivan/sp_rptctasinactivascnvb.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            LET vcCuenta = vcCuenta;
            RETURN vCodRet1, vContador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/jivan/sp_rptctasinactivascnvb.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    CREATE TEMP TABLE sc_rptctasinactivascnvb
      (
        producto char(40),
        numcte char(20),
        num_tarjeta char(16),
        cuenta char(20),
        sucursal char(4),
        nombre_cte char(100),
        sdo_actual decimal(18,2), 
        fecha_inactividad date,
        fecha_ult_dep date,
        fecha_ult_ret date,
        domicilio char(200),
        calle char(40),
        no_ext char(10),
        no_int char(10),
        depto char(10),
        colonia char(40),
        muicipio char(30),
        ciudad char(20),
        estado char(10),
        cod_pos char(10),
        fecha_notific date,
        sdo_inform decimal(18,2),
        fecha_mov date,
        monto_mov decimal(14,2),
        status_cta char(1),
        fecha_concentra date,
        sdo_concentra decimal(18,2),
        usuario_concentra char(8),
        resul_concentra char(10),
        folio_concentra char(16),
        fecha_desconcentra date,
        sdo_desconcentra decimal(18,2),
        usuario_desconcentra char(8),
        folio_desconcentra char(16),
        fecha_reconcentra date,
        sdo_reconcentra decimal(18,2),
        resul_reconcentra char(10),
        folio_reconcentra char(16),
        fecha_trasp_benef date,
        sdo_trasp_benef decimal(18,2),
        desc_trasp_benef char(10),
        resul_trasp_benef char(10),
        folio_trasp_benef char(16),
        usuario_trasp_benef char(8)
      ) 
    WITH NO LOG LOCK MODE ROW;
    
    SELECT valor * 300
      INTO vdValorSM
      FROM sc_param
     WHERE codparam = 'smdf';
    
    SELECT valor
      INTO vdFechMovHisOld4
      FROM sc_param
     WHERE codparam = 'FechaIniMovhisOld4';
     
    SELECT valor
      INTO vdFechMovHisOld3
      FROM sc_param
     WHERE codparam = 'vfechconmovhisold3';
     
    SELECT valor
      INTO vdFechMovHisOld2
      FROM sc_param
     WHERE codparam = 'FechaIniMovhisOld2';
     
    SELECT valor
      INTO vdFechMovHisOld
      FROM sc_param
     WHERE codparam = 'FechIniCon_movhis_ol';
     
    SELECT valor
      INTO vdFechMovHis
      FROM sc_param
     WHERE codparam = 'fechcon_movhis';
     
    SELECT ina.cuenta
      FROM sc_ctasinformadas ina,
           sc_ctasinactinfor3anios inf
     WHERE ina.cuenta = inf.cuenta
    INTO TEMP tmp_ctasinactivas WITH NO LOG;
    CREATE INDEX idxtmp_ctasinactivas_cta ON tmp_ctasinactivas(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctasinactivas;
    
    SELECT UNIQUE cuenta
      FROM tmp_ctasinactivas
    INTO TEMP tmp_ctainactiva WITH NO LOG;
    CREATE INDEX idxtmp_ctainactiva_cta ON tmp_ctainactiva(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctainactiva;
    
    IF pTipoEjec = 1 THEN
        FOREACH 
            SELECT ina.cuenta
              INTO vcCuenta
              FROM tmp_ctainactiva ina
             WHERE ina.cuenta IN ( SELECT cuenta FROM sc_maechq WHERE cuenta = ina.cuenta AND status_cta IN('5','6','7','8') )
             
            SELECT MIN(fecha_rep) 
              INTO vdFechaMin
              FROM sc_ctasinactinfor3anios 
             WHERE cuenta = vcCuenta;
              
            SELECT UNIQUE inf.producto, inf.num_cte, inf.num_tarjeta, mae.sucursal, inf.cliente, mae.sdo_actual, inf.fech_ult_dep, inf.fech_ult_ret,
                   inf.domicilio, inf.calle, inf.no_ext, inf.no_int, inf.depto, inf.colonia, inf.municipio, inf.ciudad, inf.estado, inf.codpos,
                   inf.fecha_rep, inf.sdo_actual
              INTO vcProducto, vcNumCte, vcTarjeta, vcSucursal, vcNombreCte, vmSdoActual, vdFechaUltDep, vdFechaUltRet, 
                   vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos,
                   vdFechaNotific, vmSdoInform
              FROM sc_ctasinactinfor3anios inf,
                   sc_maechq mae,
                   sc_maenoc noc
             WHERE inf.cuenta = vcCuenta
               AND inf.fecha_rep = vdFechaMin
               AND inf.cuenta = mae.cuenta
               AND mae.empresa = noc.empresa
               AND mae.cuenta = noc.cuenta;
            
            -- // CALCULA FECHA DE INACTIVIDAD
            IF vdFechaUltRet >= vdFechaUltDep THEN
                LET vdFechaInactividad = vdFechaUltRet + 3 UNITS YEAR;
            ELSE
                LET vdFechaInactividad = vdFechaUltDep + 3 UNITS YEAR;
            END IF;
            
            -- // VERIFICA SI LA CUENTA TUVO MOVIMIENTOS PARA ACTIVARSE
            SELECT FIRST 1 fech_alt, monto_tot
              INTO vdFechaMov, vmMontoMov
              FROM sc_movhis_old4
             WHERE empresa = pEmpresa
               AND cuenta = vcCuenta
               AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
               AND fech_alt > vdFechaNotific
               AND cancelad <> 'S'
               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
               AND num_serial = ( SELECT MIN(num_serial)
                                    FROM sc_movhis_old4
                                   WHERE empresa = pEmpresa
                                     AND cuenta = vcCuenta
                                     AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                     AND fech_alt > vdFechaNotific
                                     AND cancelad <> 'S' 
                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
            
            IF vdFechaMov is null OR vdFechaMov = '' THEN
                SELECT FIRST 1 fech_alt, monto_tot
                  INTO vdFechaMov, vmMontoMov
                  FROM sc_movhis_old3
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                   AND fech_alt > vdFechaNotific
                   AND cancelad <> 'S'
                   AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old3
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                         AND fech_alt > vdFechaNotific
                                         AND cancelad <> 'S'
                                         AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                
                IF vdFechaMov is null OR vdFechaMov = '' THEN
                    SELECT FIRST 1 fech_alt, monto_tot
                      INTO vdFechaMov, vmMontoMov
                      FROM sc_movhis_old2
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                       AND fech_alt > vdFechaNotific
                       AND cancelad <> 'S'
                       AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old2
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                             AND fech_alt > vdFechaNotific
                                             AND cancelad <> 'S'
                                             AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                             
                    IF vdFechaMov is null OR vdFechaMov = '' THEN
                        SELECT FIRST 1 fech_alt, monto_tot
                          INTO vdFechaMov, vmMontoMov
                          FROM sc_movhis_old
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                           AND fech_alt > vdFechaNotific
                           AND cancelad <> 'S'
                           AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                 AND fech_alt > vdFechaNotific
                                                 AND cancelad <> 'S' 
                                                 AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                                 
                        IF vdFechaMov is null OR vdFechaMov = '' THEN
                            SELECT FIRST 1 fech_alt, monto_tot
                              INTO vdFechaMov, vmMontoMov
                              FROM sc_movhis
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND fech_alt >= vdFechMovHis
                               AND fech_alt > vdFechaNotific
                               AND cancelad <> 'S'
                               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND fech_alt >= vdFechMovHis
                                                     AND fech_alt > vdFechaNotific
                                                     AND cancelad <> 'S' 
                                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                        END IF;
                    END IF;
                END IF;
            END IF;
            
            IF vdFechaMov is not null OR vdFechaMov <> '' THEN
                LET vdFechaMov = vdFechaMov;
                LET vmMontoMov = vmMontoMov;
                LET vcStatusMov = '1';
            ELSE
                LET vdFechaMov = '';
                LET vmMontoMov = null;
                LET vcStatusMov = '';
            END IF;
            
            -- // VERIFICA SI LA CUENTA SE CONCENTRO, DESCONCENTRO, RE-CONCENTRO Y TRASPASO
            SELECT COUNT(*)
              INTO iExisteConcentra
              FROM sc_cuentas_concentradas
             WHERE cuenta = vcCuenta;
             
            IF iExisteConcentra > 0 THEN
                SELECT UNIQUE fecha_concentra, sdo_concentrado, folio, fecha_pago_concentra, pago_sdo_concentra, fecha_trasp_benefic, sdo_trasp_beneficiencia
                  INTO vdFechaConcentra, vmSdoConcentra, vcFolioConcentra, vdFechaDesconcentra, vmSdoDesconcentra, vdFechaTraspBenef, vmSdoTraspBenef
                  FROM sc_cuentas_concentradas
                 WHERE cuenta = vcCuenta;
                 
                LET vcUsuarioConcentra = 'informix';
                LET vcResulConcentra = 'EXITOSO';
                
                -- // VERIFICA DATOS DE LA DESCONCENTRACION
                IF vdFechaDesconcentra is not null OR vdFechaDesconcentra <> '' THEN
                    SELECT FIRST 1 usuario, folio_suc
                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                      FROM sc_movhis_old4
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0324'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old4
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0324');
                                             
                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                        SELECT FIRST 1 usuario, folio_suc
                          INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                          FROM sc_movhis_old3
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0324'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old3
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0324');
                        
                        IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                            SELECT FIRST 1 usuario, folio_suc
                              INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                              FROM sc_movhis_old2
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0324'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old2
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0324');
                                                     
                            IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                SELECT FIRST 1 usuario, folio_suc
                                  INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                  FROM sc_movhis_old
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0324'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis_old
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0324');
                                                         
                                IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                    SELECT FIRST 1 usuario, folio_suc
                                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                      FROM sc_movhis
                                     WHERE empresa = pEmpresa
                                       AND cuenta = vcCuenta
                                       AND fech_alt >= vdFechMovHis
                                       AND fech_alt > vdFechaConcentra
                                       AND cancelad <> 'S'
                                       AND transacc = '0324'
                                       AND num_serial = ( SELECT MIN(num_serial)
                                                            FROM sc_movhis
                                                           WHERE empresa = pEmpresa
                                                             AND cuenta = vcCuenta
                                                             AND fech_alt >= vdFechMovHis
                                                             AND fech_alt > vdFechaConcentra
                                                             AND cancelad <> 'S'
                                                             AND transacc = '0324');
                                                             
                                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                        LET vdFechaDesconcentra = '';
                                        LET vmSdoDesconcentra = null;
                                        LET vcUsuarioDesconcentra = '';
                                        LET vcFolioDesconcentra = '';
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                -- // VERIFICA DATOS DE LA RE-CONCENTRACION
                SELECT FIRST 1 fech_alt, folio_suc
                  INTO vdFechaReConcentra, vcFolioReConcentra
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0320'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0320');
                       
                IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                    SELECT FIRST 1 fech_alt, folio_suc
                      INTO vdFechaReConcentra, vcFolioReConcentra
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0320'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0320');
                                             
                    IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                        SELECT FIRST 1 fech_alt, folio_suc
                          INTO vdFechaReConcentra, vcFolioReConcentra
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0320'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0320');
                                                 
                        IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                            SELECT FIRST 1 fech_alt, folio_suc
                              INTO vdFechaReConcentra, vcFolioReConcentra
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0320'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0320');
                                                     
                            IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                                SELECT FIRST 1 fech_alt, folio_suc
                                  INTO vdFechaReConcentra, vcFolioReConcentra
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0320'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0320');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF vdFechaReConcentra is not null OR vdFechaReConcentra <> '' THEN
                    LET vdFechaReConcentra = vdFechaReConcentra;
                    LET vmSdoReConcentra = vmSdoConcentra;
                    LET vcResulReConcentra = 'EXITOSO';
                    LET vcFolioReConcentra = vcFolioReConcentra;
                ELSE
                    LET vdFechaReConcentra = '';
                    LET vmSdoReConcentra = null;
                    LET vcResulReConcentra = '';
                    LET vcFolioReConcentra = '';
                END IF;
                
                -- // VALIDA DATOS DE TRASPASO A LA BENEFICENCIA PUBLICA
                SELECT FIRST 1 folio_suc
                  INTO vcFolioTraspBenef
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0322'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0322');
                       
                IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                    SELECT FIRST 1 folio_suc
                      INTO vcFolioTraspBenef
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0322'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0322');
                                             
                    IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                        SELECT FIRST 1 folio_suc
                          INTO vcFolioTraspBenef
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0322'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0322');
                                                 
                        IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                            SELECT FIRST 1 folio_suc
                              INTO vcFolioTraspBenef
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0322'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0322');
                                                     
                            IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                                SELECT FIRST 1 folio_suc
                                  INTO vcFolioTraspBenef
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0322'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0322');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef <= vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = vmSdoTraspBenef;
                    LET vcDescTraspBenef = 'SPEI';
                    LET vcResulTraspBenef = 'EXITOSO';
                    LET vcFolioTraspBenef = vcFolioTraspBenef;
                    LET vcUsuarioTraspBenef = 'informix';
                ELIF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef > vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = 0.00;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = 'EXCEDE 300 DSMGVDF';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                ELSE
                    LET vdFechaTraspBenef = '';
                    LET vmSdoTraspBenef = null;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = '';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                END IF;
            ELSE
                LET vdFechaConcentra = '';
                LET vmSdoConcentra = null;
                LET vcUsuarioConcentra = '';
                LET vcResulConcentra = '';
                LET vcFolioConcentra = '';
                LET vdFechaDesconcentra = '';
                LET vmSdoDesconcentra = null;
                LET vcUsuarioDesconcentra = '';
                LET vcFolioDesconcentra = '';
                LET vdFechaReConcentra = '';
                LET vmSdoReConcentra = null;
                LET vcResulReConcentra = '';
                LET vcFolioReConcentra = '';
                LET vdFechaTraspBenef = '';
                LET vmSdoTraspBenef = null;
                LET vcDescTraspBenef = '';
                LET vcResulTraspBenef = '';
                LET vcFolioTraspBenef = '';
                LET vcUsuarioTraspBenef = '';
            END IF;
            
            INSERT INTO sc_rptctasinactivascnvb VALUES
            ( vcProducto, vcNumCte, vcTarjeta, vcCuenta, vcSucursal, vcNombreCte, vmSdoActual, 
              vdFechaInactividad, vdFechaUltDep, vdFechaUltRet, 
              vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos, 
              vdFechaNotific, vmSdoInform, 
              vdFechaMov, vmMontoMov, vcStatusMov, 
              vdFechaConcentra, vmSdoConcentra, vcUsuarioConcentra, vcResulConcentra, vcFolioConcentra,
              vdFechaDesconcentra, vmSdoDesconcentra, vcUsuarioDesconcentra, vcFolioDesconcentra,
              vdFechaReConcentra, vmSdoReConcentra, vcResulReConcentra, vcFolioReConcentra,
              vdFechaTraspBenef, vmSdoTraspBenef, vcDescTraspBenef, vcResulTraspBenef, vcFolioTraspBenef, vcUsuarioTraspBenef );
            
            LET vContador = vContador + 1;
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                EXIT FOREACH;
            END IF;
            
            LET vcCuenta = '';
            LET vcProducto = '';
            LET vcNumCte = '';
            LET vcTarjeta = '';
            LET vcSucursal = '';
            LET vcNombreCte = '';
            LET vmSdoActual = 0.00;
            LET vdFechaUltDep = '';
            LET vdFechaUltRet = '';
            LET vcDomicilio = '';
            LET vcCalle = '';
            LET vcNoExt = '';
            LET vcNoInt = '';
            LET vcDepto = '';
            LET vcColonia = '';
            LET vcMuicipio = '';
            LET vcCiudad = '';
            LET vcEstado = '';
            LET vcCodPos = '';
            LET vdFechaNotific = '';
            LET vmSdoInform = '';
            LET vdFechaInactividad = '';
            LET vdFechaMov = '';
            LET vmMontoMov = 0.00;
            LET iExisteConcentra = 0;
            LET vdFechaConcentra = '';
            LET vmSdoConcentra = 0.00;
            LET vcUsuarioConcentra = '';
            LET vcResulConcentra = '';
            LET vcFolioConcentra = '';
            LET vdFechaDesconcentra = '';
            LET vmSdoDesconcentra = 0.00;
            LET vcUsuarioDesconcentra = '';
            LET vcFolioDesconcentra = '';
            LET vdFechaReConcentra = '';
            LET vmSdoReConcentra = 0.00;
            LET vcResulReConcentra = '';
            LET vcFolioReConcentra = '';
            LET vdFechaTraspBenef = '';
            LET vmSdoTraspBenef = 0.00;
            LET vcDescTraspBenef = '';
            LET vcResulTraspBenef = '';
            LET vcFolioTraspBenef = '';
            LET vcUsuarioTraspBenef = '';
            LET vdFechaMin = '';
        END FOREACH;   
        
        LET vContador2 = 0;
        
        FOREACH 
            SELECT ina.cuenta
              INTO vcCuenta
              FROM tmp_ctainactiva ina
             WHERE ina.cuenta IN ( SELECT cuenta FROM sc_maechq WHERE cuenta = ina.cuenta AND status_cta = '1' )
             
            SELECT MIN(fecha_rep) 
              INTO vdFechaMin
              FROM sc_ctasinactinfor3anios 
             WHERE cuenta = vcCuenta;
              
            SELECT UNIQUE inf.producto, inf.num_cte, inf.num_tarjeta, mae.sucursal, inf.cliente, mae.sdo_actual, inf.fech_ult_dep, inf.fech_ult_ret,
                   inf.domicilio, inf.calle, inf.no_ext, inf.no_int, inf.depto, inf.colonia, inf.municipio, inf.ciudad, inf.estado, inf.codpos,
                   inf.fecha_rep, inf.sdo_actual
              INTO vcProducto, vcNumCte, vcTarjeta, vcSucursal, vcNombreCte, vmSdoActual, vdFechaUltDep, vdFechaUltRet, 
                   vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos,
                   vdFechaNotific, vmSdoInform
              FROM sc_ctasinactinfor3anios inf,
                   sc_maechq mae,
                   sc_maenoc noc
             WHERE inf.cuenta = vcCuenta
               AND inf.fecha_rep = vdFechaMin
               AND inf.cuenta = mae.cuenta
               AND mae.empresa = noc.empresa
               AND mae.cuenta = noc.cuenta;
            
            -- // CALCULA FECHA DE INACTIVIDAD
            IF vdFechaUltRet >= vdFechaUltDep THEN
                LET vdFechaInactividad = vdFechaUltRet + 3 UNITS YEAR;
            ELSE
                LET vdFechaInactividad = vdFechaUltDep + 3 UNITS YEAR;
            END IF;
            
            -- // VERIFICA SI LA CUENTA TUVO MOVIMIENTOS PARA ACTIVARSE
            SELECT FIRST 1 fech_alt, monto_tot
              INTO vdFechaMov, vmMontoMov
              FROM sc_movhis_old4
             WHERE empresa = pEmpresa
               AND cuenta = vcCuenta
               AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
               AND fech_alt > vdFechaNotific
               AND cancelad <> 'S'
               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
               AND num_serial = ( SELECT MIN(num_serial)
                                    FROM sc_movhis_old4
                                   WHERE empresa = pEmpresa
                                     AND cuenta = vcCuenta
                                     AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                     AND fech_alt > vdFechaNotific
                                     AND cancelad <> 'S' 
                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
            
            IF vdFechaMov is null OR vdFechaMov = '' THEN
                SELECT FIRST 1 fech_alt, monto_tot
                  INTO vdFechaMov, vmMontoMov
                  FROM sc_movhis_old3
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                   AND fech_alt > vdFechaNotific
                   AND cancelad <> 'S'
                   AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old3
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                         AND fech_alt > vdFechaNotific
                                         AND cancelad <> 'S'
                                         AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                
                IF vdFechaMov is null OR vdFechaMov = '' THEN
                    SELECT FIRST 1 fech_alt, monto_tot
                      INTO vdFechaMov, vmMontoMov
                      FROM sc_movhis_old2
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                       AND fech_alt > vdFechaNotific
                       AND cancelad <> 'S'
                       AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old2
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                             AND fech_alt > vdFechaNotific
                                             AND cancelad <> 'S'
                                             AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                             
                    IF vdFechaMov is null OR vdFechaMov = '' THEN
                        SELECT FIRST 1 fech_alt, monto_tot
                          INTO vdFechaMov, vmMontoMov
                          FROM sc_movhis_old
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                           AND fech_alt > vdFechaNotific
                           AND cancelad <> 'S'
                           AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                 AND fech_alt > vdFechaNotific
                                                 AND cancelad <> 'S' 
                                                 AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                                 
                        IF vdFechaMov is null OR vdFechaMov = '' THEN
                            SELECT FIRST 1 fech_alt, monto_tot
                              INTO vdFechaMov, vmMontoMov
                              FROM sc_movhis
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND fech_alt >= vdFechMovHis
                               AND fech_alt > vdFechaNotific
                               AND cancelad <> 'S'
                               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND fech_alt >= vdFechMovHis
                                                     AND fech_alt > vdFechaNotific
                                                     AND cancelad <> 'S' 
                                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                        END IF;
                    END IF;
                END IF;
            END IF;
            
            IF vdFechaMov is not null OR vdFechaMov <> '' THEN
                LET vdFechaMov = vdFechaMov;
                LET vmMontoMov = vmMontoMov;
                LET vcStatusMov = '1';
            ELSE
                LET vdFechaMov = '';
                LET vmMontoMov = null;
                LET vcStatusMov = '';
            END IF;
            
            -- // VERIFICA SI LA CUENTA SE CONCENTRO, DESCONCENTRO, RE-CONCENTRO Y TRASPASO
            SELECT COUNT(*)
              INTO iExisteConcentra
              FROM sc_cuentas_concentradas
             WHERE cuenta = vcCuenta;
             
            IF iExisteConcentra > 0 THEN
                SELECT UNIQUE fecha_concentra, sdo_concentrado, folio, fecha_pago_concentra, pago_sdo_concentra, fecha_trasp_benefic, sdo_trasp_beneficiencia
                  INTO vdFechaConcentra, vmSdoConcentra, vcFolioConcentra, vdFechaDesconcentra, vmSdoDesconcentra, vdFechaTraspBenef, vmSdoTraspBenef
                  FROM sc_cuentas_concentradas
                 WHERE cuenta = vcCuenta;
                 
                LET vcUsuarioConcentra = 'informix';
                LET vcResulConcentra = 'EXITOSO';
                
                -- // VERIFICA DATOS DE LA DESCONCENTRACION
                IF vdFechaDesconcentra is not null OR vdFechaDesconcentra <> '' THEN
                    SELECT FIRST 1 usuario, folio_suc
                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                      FROM sc_movhis_old4
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0324'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old4
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0324');
                                             
                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                        SELECT FIRST 1 usuario, folio_suc
                          INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                          FROM sc_movhis_old3
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0324'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old3
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0324');
                        
                        IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                            SELECT FIRST 1 usuario, folio_suc
                              INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                              FROM sc_movhis_old2
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0324'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old2
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0324');
                                                     
                            IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                SELECT FIRST 1 usuario, folio_suc
                                  INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                  FROM sc_movhis_old
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0324'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis_old
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0324');
                                                         
                                IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                    SELECT FIRST 1 usuario, folio_suc
                                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                      FROM sc_movhis
                                     WHERE empresa = pEmpresa
                                       AND cuenta = vcCuenta
                                       AND fech_alt >= vdFechMovHis
                                       AND fech_alt > vdFechaConcentra
                                       AND cancelad <> 'S'
                                       AND transacc = '0324'
                                       AND num_serial = ( SELECT MIN(num_serial)
                                                            FROM sc_movhis
                                                           WHERE empresa = pEmpresa
                                                             AND cuenta = vcCuenta
                                                             AND fech_alt >= vdFechMovHis
                                                             AND fech_alt > vdFechaConcentra
                                                             AND cancelad <> 'S'
                                                             AND transacc = '0324');
                                                             
                                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                        LET vdFechaDesconcentra = '';
                                        LET vmSdoDesconcentra = null;
                                        LET vcUsuarioDesconcentra = '';
                                        LET vcFolioDesconcentra = '';
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                -- // VERIFICA DATOS DE LA RE-CONCENTRACION
                SELECT FIRST 1 fech_alt, folio_suc
                  INTO vdFechaReConcentra, vcFolioReConcentra
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0320'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0320');
                       
                IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                    SELECT FIRST 1 fech_alt, folio_suc
                      INTO vdFechaReConcentra, vcFolioReConcentra
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0320'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0320');
                                             
                    IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                        SELECT FIRST 1 fech_alt, folio_suc
                          INTO vdFechaReConcentra, vcFolioReConcentra
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0320'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0320');
                                                 
                        IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                            SELECT FIRST 1 fech_alt, folio_suc
                              INTO vdFechaReConcentra, vcFolioReConcentra
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0320'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0320');
                                                     
                            IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                                SELECT FIRST 1 fech_alt, folio_suc
                                  INTO vdFechaReConcentra, vcFolioReConcentra
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0320'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0320');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF vdFechaReConcentra is not null OR vdFechaReConcentra <> '' THEN
                    LET vdFechaReConcentra = vdFechaReConcentra;
                    LET vmSdoReConcentra = vmSdoConcentra;
                    LET vcResulReConcentra = 'EXITOSO';
                    LET vcFolioReConcentra = vcFolioReConcentra;
                ELSE
                    LET vdFechaReConcentra = '';
                    LET vmSdoReConcentra = null;
                    LET vcResulReConcentra = '';
                    LET vcFolioReConcentra = '';
                END IF;
                
                -- // VALIDA DATOS DE TRASPASO A LA BENEFICENCIA PUBLICA
                SELECT FIRST 1 folio_suc
                  INTO vcFolioTraspBenef
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0322'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0322');
                       
                IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                    SELECT FIRST 1 folio_suc
                      INTO vcFolioTraspBenef
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0322'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0322');
                                             
                    IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                        SELECT FIRST 1 folio_suc
                          INTO vcFolioTraspBenef
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0322'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0322');
                                                 
                        IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                            SELECT FIRST 1 folio_suc
                              INTO vcFolioTraspBenef
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0322'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0322');
                                                     
                            IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                                SELECT FIRST 1 folio_suc
                                  INTO vcFolioTraspBenef
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0322'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0322');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef <= vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = vmSdoTraspBenef;
                    LET vcDescTraspBenef = 'SPEI';
                    LET vcResulTraspBenef = 'EXITOSO';
                    LET vcFolioTraspBenef = vcFolioTraspBenef;
                    LET vcUsuarioTraspBenef = 'informix';
                ELIF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef > vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = 0.00;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = 'EXCEDE 300 DSMGVDF';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                ELSE
                    LET vdFechaTraspBenef = '';
                    LET vmSdoTraspBenef = null;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = '';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                END IF;
            ELSE
                LET vdFechaConcentra = '';
                LET vmSdoConcentra = null;
                LET vcUsuarioConcentra = '';
                LET vcResulConcentra = '';
                LET vcFolioConcentra = '';
                LET vdFechaDesconcentra = '';
                LET vmSdoDesconcentra = null;
                LET vcUsuarioDesconcentra = '';
                LET vcFolioDesconcentra = '';
                LET vdFechaReConcentra = '';
                LET vmSdoReConcentra = null;
                LET vcResulReConcentra = '';
                LET vcFolioReConcentra = '';
                LET vdFechaTraspBenef = '';
                LET vmSdoTraspBenef = null;
                LET vcDescTraspBenef = '';
                LET vcResulTraspBenef = '';
                LET vcFolioTraspBenef = '';
                LET vcUsuarioTraspBenef = '';
            END IF;
            
            INSERT INTO sc_rptctasinactivascnvb VALUES
            ( vcProducto, vcNumCte, vcTarjeta, vcCuenta, vcSucursal, vcNombreCte, vmSdoActual, 
              vdFechaInactividad, vdFechaUltDep, vdFechaUltRet, 
              vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos, 
              vdFechaNotific, vmSdoInform, 
              vdFechaMov, vmMontoMov, vcStatusMov, 
              vdFechaConcentra, vmSdoConcentra, vcUsuarioConcentra, vcResulConcentra, vcFolioConcentra,
              vdFechaDesconcentra, vmSdoDesconcentra, vcUsuarioDesconcentra, vcFolioDesconcentra,
              vdFechaReConcentra, vmSdoReConcentra, vcResulReConcentra, vcFolioReConcentra,
              vdFechaTraspBenef, vmSdoTraspBenef, vcDescTraspBenef, vcResulTraspBenef, vcFolioTraspBenef, vcUsuarioTraspBenef );
            
            LET vContador = vContador + 1;
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                EXIT FOREACH;
            END IF;
            
            LET vcCuenta = '';
            LET vcProducto = '';
            LET vcNumCte = '';
            LET vcTarjeta = '';
            LET vcSucursal = '';
            LET vcNombreCte = '';
            LET vmSdoActual = 0.00;
            LET vdFechaUltDep = '';
            LET vdFechaUltRet = '';
            LET vcDomicilio = '';
            LET vcCalle = '';
            LET vcNoExt = '';
            LET vcNoInt = '';
            LET vcDepto = '';
            LET vcColonia = '';
            LET vcMuicipio = '';
            LET vcCiudad = '';
            LET vcEstado = '';
            LET vcCodPos = '';
            LET vdFechaNotific = '';
            LET vmSdoInform = '';
            LET vdFechaInactividad = '';
            LET vdFechaMov = '';
            LET vmMontoMov = 0.00;
            LET iExisteConcentra = 0;
            LET vdFechaConcentra = '';
            LET vmSdoConcentra = 0.00;
            LET vcUsuarioConcentra = '';
            LET vcResulConcentra = '';
            LET vcFolioConcentra = '';
            LET vdFechaDesconcentra = '';
            LET vmSdoDesconcentra = 0.00;
            LET vcUsuarioDesconcentra = '';
            LET vcFolioDesconcentra = '';
            LET vdFechaReConcentra = '';
            LET vmSdoReConcentra = 0.00;
            LET vcResulReConcentra = '';
            LET vcFolioReConcentra = '';
            LET vdFechaTraspBenef = '';
            LET vmSdoTraspBenef = 0.00;
            LET vcDescTraspBenef = '';
            LET vcResulTraspBenef = '';
            LET vcFolioTraspBenef = '';
            LET vcUsuarioTraspBenef = '';
            LET vdFechaMin = '';
        END FOREACH;   
    ELSE
        FOREACH 
            SELECT cuenta
              INTO vcCuenta
              FROM tmp_ctainactiva
              
            SELECT MIN(fecha_rep) 
              INTO vdFechaMin
              FROM sc_ctasinactinfor3anios 
             WHERE cuenta = vcCuenta;
        
            SELECT UNIQUE inf.producto, inf.num_cte, inf.num_tarjeta, mae.sucursal, inf.cliente, mae.sdo_actual, inf.fech_ult_dep, inf.fech_ult_ret,
                   inf.domicilio, inf.calle, inf.no_ext, inf.no_int, inf.depto, inf.colonia, inf.municipio, inf.ciudad, inf.estado, inf.codpos,
                   inf.fecha_rep, inf.sdo_actual
              INTO vcProducto, vcNumCte, vcTarjeta, vcSucursal, vcNombreCte, vmSdoActual, vdFechaUltDep, vdFechaUltRet, 
                   vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos,
                   vdFechaNotific, vmSdoInform
              FROM sc_ctasinactinfor3anios inf,
                   sc_maechq mae,
                   sc_maenoc noc
             WHERE inf.cuenta = vcCuenta
               AND inf.fecha_rep = vdFechaMin
               AND inf.cuenta = mae.cuenta
               AND mae.empresa = noc.empresa
               AND mae.cuenta = noc.cuenta;
            
            -- // CALCULA FECHA DE INACTIVIDAD
            IF vdFechaUltRet >= vdFechaUltDep THEN
                LET vdFechaInactividad = vdFechaUltRet + 3 UNITS YEAR;
            ELSE
                LET vdFechaInactividad = vdFechaUltDep + 3 UNITS YEAR;
            END IF;
            
            -- // VERIFICA SI LA CUENTA TUVO MOVIMIENTOS PARA ACTIVARSE
            SELECT FIRST 1 fech_alt, monto_tot
              INTO vdFechaMov, vmMontoMov
              FROM sc_movhis_old4
             WHERE empresa = pEmpresa
               AND cuenta = vcCuenta
               AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
               AND fech_alt > vdFechaNotific
               AND cancelad <> 'S'
               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
               AND num_serial = ( SELECT MIN(num_serial)
                                    FROM sc_movhis_old4
                                   WHERE empresa = pEmpresa
                                     AND cuenta = vcCuenta
                                     AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                     AND fech_alt > vdFechaNotific
                                     AND cancelad <> 'S' 
                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
            
            IF vdFechaMov is null OR vdFechaMov = '' THEN
                SELECT FIRST 1 fech_alt, monto_tot
                  INTO vdFechaMov, vmMontoMov
                  FROM sc_movhis_old3
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                   AND fech_alt > vdFechaNotific
                   AND cancelad <> 'S'
                   AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old3
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                         AND fech_alt > vdFechaNotific
                                         AND cancelad <> 'S'
                                         AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                
                IF vdFechaMov is null OR vdFechaMov = '' THEN
                    SELECT FIRST 1 fech_alt, monto_tot
                      INTO vdFechaMov, vmMontoMov
                      FROM sc_movhis_old2
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                       AND fech_alt > vdFechaNotific
                       AND cancelad <> 'S'
                       AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old2
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                             AND fech_alt > vdFechaNotific
                                             AND cancelad <> 'S'
                                             AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                             
                    IF vdFechaMov is null OR vdFechaMov = '' THEN
                        SELECT FIRST 1 fech_alt, monto_tot
                          INTO vdFechaMov, vmMontoMov
                          FROM sc_movhis_old
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                           AND fech_alt > vdFechaNotific
                           AND cancelad <> 'S'
                           AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                 AND fech_alt > vdFechaNotific
                                                 AND cancelad <> 'S' 
                                                 AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                                 
                        IF vdFechaMov is null OR vdFechaMov = '' THEN
                            SELECT FIRST 1 fech_alt, monto_tot
                              INTO vdFechaMov, vmMontoMov
                              FROM sc_movhis
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND fech_alt >= vdFechMovHis
                               AND fech_alt > vdFechaNotific
                               AND cancelad <> 'S'
                               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND fech_alt >= vdFechMovHis
                                                     AND fech_alt > vdFechaNotific
                                                     AND cancelad <> 'S' 
                                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                        END IF;
                    END IF;
                END IF;
            END IF;
            
            IF vdFechaMov is not null OR vdFechaMov <> '' THEN
                LET vdFechaMov = vdFechaMov;
                LET vmMontoMov = vmMontoMov;
                LET vcStatusMov = '1';
            ELSE
                LET vdFechaMov = '';
                LET vmMontoMov = null;
                LET vcStatusMov = '';
            END IF;
            
            -- // VERIFICA SI LA CUENTA SE CONCENTRO, DESCONCENTRO, RE-CONCENTRO Y TRASPASO
            SELECT COUNT(*)
              INTO iExisteConcentra
              FROM sc_cuentas_concentradas
             WHERE cuenta = vcCuenta;
             
            IF iExisteConcentra > 0 THEN
                SELECT UNIQUE fecha_concentra, sdo_concentrado, folio, fecha_pago_concentra, pago_sdo_concentra, fecha_trasp_benefic, sdo_trasp_beneficiencia
                  INTO vdFechaConcentra, vmSdoConcentra, vcFolioConcentra, vdFechaDesconcentra, vmSdoDesconcentra, vdFechaTraspBenef, vmSdoTraspBenef
                  FROM sc_cuentas_concentradas
                 WHERE cuenta = vcCuenta;
                 
                LET vcUsuarioConcentra = 'informix';
                LET vcResulConcentra = 'EXITOSO';
                
                -- // VERIFICA DATOS DE LA DESCONCENTRACION
                IF vdFechaDesconcentra is not null OR vdFechaDesconcentra <> '' THEN
                    SELECT FIRST 1 usuario, folio_suc
                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                      FROM sc_movhis_old4
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0324'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old4
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0324');
                                             
                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                        SELECT FIRST 1 usuario, folio_suc
                          INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                          FROM sc_movhis_old3
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0324'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old3
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0324');
                        
                        IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                            SELECT FIRST 1 usuario, folio_suc
                              INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                              FROM sc_movhis_old2
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0324'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old2
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0324');
                                                     
                            IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                SELECT FIRST 1 usuario, folio_suc
                                  INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                  FROM sc_movhis_old
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0324'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis_old
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0324');
                                                         
                                IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                    SELECT FIRST 1 usuario, folio_suc
                                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                      FROM sc_movhis
                                     WHERE empresa = pEmpresa
                                       AND cuenta = vcCuenta
                                       AND fech_alt >= vdFechMovHis
                                       AND fech_alt > vdFechaConcentra
                                       AND cancelad <> 'S'
                                       AND transacc = '0324'
                                       AND num_serial = ( SELECT MIN(num_serial)
                                                            FROM sc_movhis
                                                           WHERE empresa = pEmpresa
                                                             AND cuenta = vcCuenta
                                                             AND fech_alt >= vdFechMovHis
                                                             AND fech_alt > vdFechaConcentra
                                                             AND cancelad <> 'S'
                                                             AND transacc = '0324');
                                                             
                                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                        LET vdFechaDesconcentra = '';
                                        LET vmSdoDesconcentra = null;
                                        LET vcUsuarioDesconcentra = '';
                                        LET vcFolioDesconcentra = '';
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                -- // VERIFICA DATOS DE LA RE-CONCENTRACION
                SELECT FIRST 1 fech_alt, folio_suc
                  INTO vdFechaReConcentra, vcFolioReConcentra
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0320'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0320');
                       
                IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                    SELECT FIRST 1 fech_alt, folio_suc
                      INTO vdFechaReConcentra, vcFolioReConcentra
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0320'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0320');
                                             
                    IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                        SELECT FIRST 1 fech_alt, folio_suc
                          INTO vdFechaReConcentra, vcFolioReConcentra
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0320'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0320');
                                                 
                        IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                            SELECT FIRST 1 fech_alt, folio_suc
                              INTO vdFechaReConcentra, vcFolioReConcentra
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0320'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0320');
                                                     
                            IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                                SELECT FIRST 1 fech_alt, folio_suc
                                  INTO vdFechaReConcentra, vcFolioReConcentra
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0320'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0320');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF vdFechaReConcentra is not null OR vdFechaReConcentra <> '' THEN
                    LET vdFechaReConcentra = vdFechaReConcentra;
                    LET vmSdoReConcentra = vmSdoConcentra;
                    LET vcResulReConcentra = 'EXITOSO';
                    LET vcFolioReConcentra = vcFolioReConcentra;
                ELSE
                    LET vdFechaReConcentra = '';
                    LET vmSdoReConcentra = null;
                    LET vcResulReConcentra = '';
                    LET vcFolioReConcentra = '';
                END IF;
                
                -- // VALIDA DATOS DE TRASPASO A LA BENEFICENCIA PUBLICA
                SELECT FIRST 1 folio_suc
                  INTO vcFolioTraspBenef
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0322'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0322');
                       
                IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                    SELECT FIRST 1 folio_suc
                      INTO vcFolioTraspBenef
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0322'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0322');
                                             
                    IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                        SELECT FIRST 1 folio_suc
                          INTO vcFolioTraspBenef
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0322'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0322');
                                                 
                        IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                            SELECT FIRST 1 folio_suc
                              INTO vcFolioTraspBenef
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0322'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0322');
                                                     
                            IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                                SELECT FIRST 1 folio_suc
                                  INTO vcFolioTraspBenef
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0322'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0322');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef <= vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = vmSdoTraspBenef;
                    LET vcDescTraspBenef = 'SPEI';
                    LET vcResulTraspBenef = 'EXITOSO';
                    LET vcFolioTraspBenef = vcFolioTraspBenef;
                    LET vcUsuarioTraspBenef = 'informix';
                ELIF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef > vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = 0.00;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = 'EXCEDE 300 DSMGVDF';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                ELSE
                    LET vdFechaTraspBenef = '';
                    LET vmSdoTraspBenef = null;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = '';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                END IF;
            ELSE
                LET vdFechaConcentra = '';
                LET vmSdoConcentra = null;
                LET vcUsuarioConcentra = '';
                LET vcResulConcentra = '';
                LET vcFolioConcentra = '';
                LET vdFechaDesconcentra = '';
                LET vmSdoDesconcentra = null;
                LET vcUsuarioDesconcentra = '';
                LET vcFolioDesconcentra = '';
                LET vdFechaReConcentra = '';
                LET vmSdoReConcentra = null;
                LET vcResulReConcentra = '';
                LET vcFolioReConcentra = '';
                LET vdFechaTraspBenef = '';
                LET vmSdoTraspBenef = null;
                LET vcDescTraspBenef = '';
                LET vcResulTraspBenef = '';
                LET vcFolioTraspBenef = '';
                LET vcUsuarioTraspBenef = '';
            END IF;
            
            INSERT INTO sc_rptctasinactivascnvb VALUES
            ( vcProducto, vcNumCte, vcTarjeta, vcCuenta, vcSucursal, vcNombreCte, vmSdoActual, 
              vdFechaInactividad, vdFechaUltDep, vdFechaUltRet, 
              vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos, 
              vdFechaNotific, vmSdoInform, 
              vdFechaMov, vmMontoMov, vcStatusMov, 
              vdFechaConcentra, vmSdoConcentra, vcUsuarioConcentra, vcResulConcentra, vcFolioConcentra,
              vdFechaDesconcentra, vmSdoDesconcentra, vcUsuarioDesconcentra, vcFolioDesconcentra,
              vdFechaReConcentra, vmSdoReConcentra, vcResulReConcentra, vcFolioReConcentra,
              vdFechaTraspBenef, vmSdoTraspBenef, vcDescTraspBenef, vcResulTraspBenef, vcFolioTraspBenef, vcUsuarioTraspBenef );
            
            LET vContador = vContador + 1;
            
            LET vcCuenta = '';
            LET vcProducto = '';
            LET vcNumCte = '';
            LET vcTarjeta = '';
            LET vcSucursal = '';
            LET vcNombreCte = '';
            LET vmSdoActual = 0.00;
            LET vdFechaUltDep = '';
            LET vdFechaUltRet = '';
            LET vcDomicilio = '';
            LET vcCalle = '';
            LET vcNoExt = '';
            LET vcNoInt = '';
            LET vcDepto = '';
            LET vcColonia = '';
            LET vcMuicipio = '';
            LET vcCiudad = '';
            LET vcEstado = '';
            LET vcCodPos = '';
            LET vdFechaNotific = '';
            LET vmSdoInform = '';
            LET vdFechaInactividad = '';
            LET vdFechaMov = '';
            LET vmMontoMov = 0.00;
            LET iExisteConcentra = 0;
            LET vdFechaConcentra = '';
            LET vmSdoConcentra = 0.00;
            LET vcUsuarioConcentra = '';
            LET vcResulConcentra = '';
            LET vcFolioConcentra = '';
            LET vdFechaDesconcentra = '';
            LET vmSdoDesconcentra = 0.00;
            LET vcUsuarioDesconcentra = '';
            LET vcFolioDesconcentra = '';
            LET vdFechaReConcentra = '';
            LET vmSdoReConcentra = 0.00;
            LET vcResulReConcentra = '';
            LET vcFolioReConcentra = '';
            LET vdFechaTraspBenef = '';
            LET vmSdoTraspBenef = 0.00;
            LET vcDescTraspBenef = '';
            LET vcResulTraspBenef = '';
            LET vcFolioTraspBenef = '';
            LET vcUsuarioTraspBenef = '';
        END FOREACH;   
    END IF;
    
    CREATE INDEX idxtmp_rptctasinactivascnvb_cta ON sc_rptctasinactivascnvb(cuenta) ONLINE;
    CREATE INDEX idxtmp_rptctasinactivascnvb_cte ON sc_rptctasinactivascnvb(numcte) ONLINE;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_rptctasinactivascnvb;
    
    END;
     
    RETURN vCodRet1, vContador;
     
END PROCEDURE;