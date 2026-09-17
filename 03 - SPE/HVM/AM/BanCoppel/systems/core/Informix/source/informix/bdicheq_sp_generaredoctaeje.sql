CREATE PROCEDURE "informix".sp_generaredoctaeje(pEmpresa char(3))
RETURNING CHAR(5);
        
    DEFINE vcSql char(600);
    DEFINE vcStmt char(250);
    DEFINE vInserto CHAR(15);
    DEFINE vNombre_cte CHAR(150);
    DEFINE vcodret, vCP CHAR(5);
    DEFINE vNum_Tarjeta CHAR(16);
    DEFINE vRFC_Cliente CHAR(13);
    DEFINE vSucursal_num, anioFechaEmision CHAR(4);
    DEFINE  vdescripcion CHAR(180);
    DEFINE vDireccion_cte CHAR(200);
    DEFINE vSucursal_nombre CHAR(40);
    DEFINE vfechaAltaMes, vfechaAltaDia, mesFechaEmision CHAR(2);
    DEFINE cFech_param, cFech_param_ini CHAR(10);
    DEFINE vempresa, vexiste_genedoctaeje CHAR(3);
    DEFINE vCve_ruta, vCve_ahorro, vClabe, vCurp CHAR(60);
    DEFINE vcortSig, vMensajeProducto, vPiePagina CHAR(255);
    DEFINE vDireccion_col, vDireccion_del, vEdo_cd CHAR(120);
    DEFINE vmensajegeneraArch, cErrorInfo, vErrorInfo CHAR(80);
    DEFINE vaniomes, vcodRetspCortSig, vcodRetgeneraArch CHAR(6);
    DEFINE vcodretDet, vcodretEnc, vmin_aniomes, vmax_aniomes CHAR(6);
    DEFINE vcuenta, vnumCte, vNum_cte, vexiste_invcrec, vexiste_pagare CHAR(20);
    DEFINE vexiste_credito, vexiste_movhis, vexiste_movhisold, vmin_cta, vmax_cta CHAR(20);
    
    DEFINE bInicia BOOLEAN;
    DEFINE vTasaBruta, vGAT DECIMAL(9, 6);
    DEFINE vdiaSdo, iIsamErr, viDias, vDiaMesiversario SMALLINT;
    DEFINE vSaldoProm, vacumSdo, vsdocuenta, vdeposito, vretiro MONEY(14,2);
    DEFINE vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vInteresesNetos, vTotRetirosEfec, vTotOtrosCargos  DECIMAL(18,2);
    DEFINE vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros, vOtrosCargos, vRetencionIsr DECIMAL(18,2);
    DEFINE vcortSig2, vsecuencia, vnlinea, vidreg, vsqlerr, visamerr, vmesiversario, vaniversario INTEGER;
    DEFINE vultejec, vfecha_hoy, vfecha_ant, vfechaAlta, vultDiaMes, vPrimDiaMes, vfechCortSig, vfechealt, vhorainicio, vFecha_emision DATE;
    DEFINE vFechaAltaEnc, vFechaInicio, vfechaFinal, dFechaInicioMovimientos, dFechaFinMovimientos, dFechaCorte, dFechaEmision, dFechaNacimiento DATE;

    LET vaniomes = "";                              LET vcodretDet = "";                        LET vcodretEnC = "";
    LET vhorainicio = "";                           LET cErrorInfo="";                          LET vErrorInfo= "INICIO DEL PROCESO";
    LET vcortSig2 = 0;                              LET vcortSig = "";                          LET vsecuencia = 0;
    LET vnlinea =0;                                 LET vidreg = 0;                             LET vultejec = '';
    LET vmensajegeneraArch = "";                    LET vsqlerr = 0;                            LET vdeposito = 0;
    LET vretiro = 0;                                LET vfechealt = "";                         LET vsdocuenta = 0;
    LET vdescripcion = "";                          LET vempresa = "";                          LET vnumCte= "";
    LET vcuenta = "";                               LET vfechaAlta = "";                        LET vcodret = "000";
    LET vfecha_hoy = "";                            LET vfecha_ant = "";                        LET vultDiaMes = "";
    LET vmesiversario = 0;                          LET vaniversario = 0;                       LET vfechaAltaMes = "";
    LET vfechaAltaDia = "";                         LET bInicia = "F";                          LET iIsamErr = 0;
    LET vFecha_emision = "01-01-1900";              LET vNum_cte = "";                          LET vNum_Tarjeta = "";
    LET vNombre_cte = "";                           LET vDireccion_cte = "";                    LET vDireccion_col = "";
    LET vDireccion_del = "";                        LET vEdo_cd = "";                           LET vCve_ruta = "";
    LET vSucursal_nombre = "";                      LET vSucursal_num  = "";                    LET vRFC_Cliente = "";
    LET vCP = "";                                   LET vCve_ahorro = "";                       LET vClabe = "";
    LET vCurp = "";                                 LET vFechaAlta = "";                        LET vFechaInicio = "";
    LET vMensajeProducto = "";                      LET vInserto = "";                          LET vSaldoAnterior = 0;
    LET vDepositos = 0;                             LET vInteresesPagados = 0;                  LET vRetiros = 0;
    LET vOtrosCargos = 0;                           LET vIvaOtrosCargos = 0;                    LET vSaldoCorte = 0;
    LET vSaldoPromedio = 0;                         LET vRetencionIsr = 0;                      LET vInteresesNetos = 0;
    LET viDias = 0;                                 LET vTasaBruta = 0;                         LET vPiePagina  = "";
    LET vfechaFinal = "";                           LET vcSql = "";                             LET vcStmt = "";         
    LET vmin_cta = '';                              LET vmax_cta = '';
    LET dFechaInicioMovimientos = '01-01-1900';     LET dFechaFinMovimientos = '01-01-1900';    LET dFechaCorte = '01-01-1900';
    LET vDiaMesiversario = 0;                       LET dFechaEmision = '01-01-1900';           LET dFechaNacimiento = '01-01-1900';
    LET vTotRetirosEfec = 0;                        LET vTotOtrosCargos = 0;                    LET vGAT = 0; 
    LET mesFechaEmision = '';                       LET anioFechaEmision = '';
    
    --- SET DEBUG FILE TO "/tmp/sp_generaredoctaeje.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "./sp_generaredoctaeje.err";
            TRACE ON;
            
            LET vcodret = vsqlerr;
            LET vErrorInfo = cErrorInfo;
            
            IF bInicia = "T" THEN
                ROLLBACK WORK;
            END IF;
            
            LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                        'SET status_proc = '''||'C'||''','||
                        'cod_ret = '''||vcodret||''','||
                        'mensaje = '''||vErrorInfo||''','||
                        'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                        'WHERE fecha = '''||vfecha_hoy||''' '||
                        'AND  status_proc = '''||'I'||''' '||
                        'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
            SYSTEM vcSql;
            LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
            SYSTEM vcStmt;
            
            RETURN vcodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    IF pEmpresa IS NULL  THEN
        LET vcodret = '001';
        RETURN vcodret;
    END IF; 
    
    -- // obtener la fecha de ayer y hoy
    SELECT fecha_ant, fecha_hoy
      INTO vfecha_ant, vfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = "001";
     
    SELECT valor
      INTO cFech_param
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO cFech_param_ini
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'FechIniCon_movhis_ol';
       
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmin_cta, vmax_cta
      FROM sc_maehis;
      
    SELECT MIN(aniomes), MAX(aniomes)
      INTO vmin_aniomes, vmax_aniomes
      FROM sc_maehis;

    -- // obtener el dia en que se descargan los archivos de texto
    SELECT dia_mesiversario
      INTO vDiaMesiversario
      FROM sc_configuracion_edocta
     WHERE dia_mesiversario IS NOT NULL;

    -- // armar la fecha de emision
    IF DAY(vfecha_ant) < vdiaMesiversario THEN
    
        LET dFechaEmision = MDY( MONTH(vfecha_ant), vDiaMesiversario, YEAR(vfecha_ant) );
        
    ELSE
        --- LET dFechaEmision = MDY( MONTH(vfecha_ant + 1 UNITS MONTH), vDiaMesiversario, YEAR(vfecha_ant) );
        
        LET mesFechaEmision = LPAD(MONTH(vfecha_ant) + 1, 2, '0');
        LET anioFechaEmision = YEAR(vfecha_ant);
        
        IF mesFechaEmision > '12' THEN
           LET mesFechaEmision = '01';
           LET anioFechaEmision = YEAR(vfecha_ant) + 1;
        END IF;
        
        LET dFechaEmision = MDY( mesFechaEmision, vDiaMesiversario, anioFechaEmision );         
    END IF;

    -- // obtener la fecha en que se ejecutó por última vez.
    SELECT NVL(MAX(fecha),vfecha_ant)
      INTO vultejec
      FROM sc_contproc_edocta
     WHERE proceso = 'GENERA EDO CTA EJE'
       AND empresa = pEmpresa
       AND status_proc = 'F'
       AND tipo_proc   = 'D';

    IF vultejec >= vfecha_hoy THEN -- // si no se ejecuto hoy
        LET vcodret = '000';
        RETURN vcodret;
    END IF;
    
    -- // si no hay registro de que el proceso haya quedado inconcluso se inserta uno nuevo, sino solo se actualiza
    SELECT empresa
      INTO vexiste_genedoctaeje
      FROM sc_contproc_edocta
     WHERE proceso = 'GENERA EDO CTA EJE'
       AND fecha   = vfecha_hoy
       AND empresa = pEmpresa
       AND status_proc in('I','C')
       AND tipo_proc   = 'D';
       
    IF vexiste_genedoctaeje is null OR vexiste_genedoctaeje = '' THEN
        LET vcSql = 'echo " INSERT INTO bdicheq:sc_contproc_edocta (empresa, proceso, fecha, tipo_proc, status_proc, ejecutivo, hora_inicio, hora_fin, cod_ret, mensaje) '||
                    'VALUES('''||pempresa||''', '''||'GENERA EDO CTA EJE'||''', '''||vfecha_hoy||''', '''||'D'||''', '''||'I'||''', USER,'||
                    '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||'''),'||
                    'NULL,'''||vcodret||''', '''||vErrorInfo||''');" > /tmp/contproc_edocta.sql';
        SYSTEM vcSql;
        LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
        SYSTEM vcStmt;
    ELSE
        LET vcSql = 'echo " UPDATE bdicheq:sc_contproc_edocta '||
                    'SET status_proc =  '''||'I'||''','||
                    'hora_inicio = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||'''),'||
                    'hora_fin = NULL '||
                    'WHERE fecha = '''||vfecha_hoy||''' AND status_proc = '''||'C'||''' AND  tipo_proc = '''||'D'||''';" > /tmp/contproc_edocta.sql';
        SYSTEM vcSql;
        LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
        SYSTEM vcStmt;
    END IF;
    
    CREATE TEMP TABLE tmp_ctesno( num_cte CHAR(20) ) WITH NO LOG;
    CREATE INDEX idx_ctesno ON tmp_ctesno(num_cte) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctesno;
    
    INSERT INTO tmp_ctesno
    SELECT num_cte
      FROM sc_maechq 
     WHERE empresa = pEmpresa
       AND producto = '1100'
       AND status_cta <> '2';
    
    INSERT INTO tmp_ctesno
    SELECT num_cte
      FROM bdinvers:sv_maeinv 
     WHERE empresa = pEmpresa
       AND status_cta = '1';
    
    INSERT INTO tmp_ctesno
    SELECT numcte
      FROM bdicred:sd_maecred 
     WHERE numcte = vnumCte;
    
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctesno;
    
    SELECT UNIQUE num_cte
      FROM tmp_ctesno
      INTO TEMP tmp_ctesexcluidos WITH NO LOG;
    CREATE INDEX idx_ctesexc ON tmp_ctesexcluidos(num_cte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctesexcluidos;
    
    FOREACH WITH HOLD -- // obtener las cuentas que sean participantes y que cumplan su aniversario o mesiversario
        SELECT {+INDEX(sc_maehis maehis1)}
               mae.aniomes, mae.cuenta, mae.num_cte, mae.fechaini, mae.fechafin, mae.acum_sdo_pos, mae.dia_sdo_pos
          INTO vaniomes, vcuenta, vnumCte, dFechaInicioMovimientos, dFechaFinMovimientos, vacumSdo, vdiaSdo
          FROM sc_maehis AS mae,
               sc_prod_participan_edocta AS prod
         WHERE mae.aniomes BETWEEN vmin_aniomes and vmax_aniomes
           AND mae.cuenta BETWEEN vmin_cta AND vmax_cta
           AND mae.cuenta NOT IN ( SELECT ee.num_cuenta 
                                     FROM bdicheq:sc_encabezado_edocta ee
                                    WHERE ee.num_cuenta = mae.cuenta 
                                      AND ee.fechafinal = vfecha_ant )
           AND mae.fechaini < vfecha_ant
           AND mae.fechafin BETWEEN vultejec AND vfecha_ant
           AND mae.num_cte NOT IN( SELECT num_cte 
                                     FROM tmp_ctesexcluidos AS ctes
                                    WHERE ctes.num_cte = mae.num_cte )
           AND prod.producto = mae.producto
           AND prod.gpo_producto = 'CH'
                
        -- // calcular saldo promedio de la cuenta
        IF vdiaSdo <>  0 THEN
            LET vSaldoProm = vacumSdo / vdiaSdo;
        ELSE
            LET vSaldoProm = 0;
        END IF;

        BEGIN WORK;
        LET bInicia = "T";

        IF vSaldoProm > 50 THEN
            -- // ejecutar el store para llenar el encabezado
            SELECT NVL(MAX(idreg), 0) + 1
              INTO vidreg
              FROM sc_encabezado_edocta;

            EXECUTE PROCEDURE sp_generaredoctaejeencabezado(pEmpresa, vcuenta, vaniomes)
            INTO vcodretEnc, vFecha_emision, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del,
                 vEdo_cd, vCve_ruta, vSucursal_nombre, vRFC_Cliente, vCP, vCve_ahorro, vClabe, vCurp, vFechaAltaEnc, vFechaInicio,
                 vMensajeProducto, vInserto, vfechaFinal, vSucursal_num, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta, 
                 vPiePagina, vTotRetirosEfec, vTotOtrosCargos, vGAT;
         
            IF trim(vcodretEnc) = '000' THEN -- // hacer las inserciones si el resultado del SP_generarEdoCtaejeencabezado fue satisfactorio
                
                INSERT INTO sc_encabezado_edocta 
                (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, 
                 direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, sucursal_nombre, rfc, cp, 
                 cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte,
                 vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, vCve_ruta, vSucursal_nombre, vRFC_Cliente, vCP,
                 vCve_ahorro, vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, vinserto, vfechaFinal, vSucursal_num);
                
                INSERT INTO sc_encabezado2_edocta
                (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros,
                 otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta);

                LET vsecuencia = 1;
                LET vnlinea = 1;

                INSERT INTO sc_piepagina_edocta 
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
                
                INSERT INTO sc_mensajes_edocta
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, 'Cuando utilices un cajero automático no aceptes ayuda de nadie.');
                
                INSERT INTO sc_mensajes_edocta
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea + 1, 'No se deje sorprender por llamadas telefónicas, mensajes por teléfono o mensajes en su correo electrónico en los que se le solicite su número de tarjeta de débito.');
                
                INSERT INTO sc_mensajes_edocta
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea + 2, 'Al pagar con su tarjeta de débito y antes de firmar el recibo, verifique que el monto total de la compra sea el correcto.');
                
                INSERT INTO sc_grafica
                (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vSaldoCorte, vTotRetirosEfec, vDepositos, vInteresesPagados, vOtrosCargos, vIvaOtrosCargos, vTotOtrosCargos, vGAT);
                
            ELSE -- // si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecución
            
                ROLLBACK WORK;
                
                LET bInicia = "F";
                LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
                LET vcodret = '003';
                
                LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                            'SET status_proc = '''||'C'||''','||
                            'cod_ret = '''||vcodret||''','||
                            'mensaje = '''||vErrorInfo||''','||
                            'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                            'WHERE fecha = '''||vfecha_hoy||''' '||
                            'AND  status_proc = '''||'I'||''' '||
                            'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
                SYSTEM vcSql;
                LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
                SYSTEM vcStmt;
                
                RETURN vcodret;
                
            END IF;

            -- // ejecutar store para el detalle
            LET vsecuencia = 0;

            FOREACH
                EXECUTE PROCEDURE sp_generaredoctaejedetalle(pEmpresa, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos)
                INTO vcodretDet,vdescripcion,vsdocuenta,vfechealt,vdeposito,vretiro
                
                IF trim(vcodretDet) = '000' THEN -- // si el resultado fue satisfactorio hacer las inserciones para los detalles
                    LET vsecuencia = vsecuencia + 1;
                    LET vnlinea = 0;

                    FOREACH -- // cortar los detalles en lineas
                        EXECUTE PROCEDURE bdicred:corta_linea(vdescripcion, 40)
                        INTO vcortSig, vcortsig2

                        LET  vnlinea =vnlinea + 1;

                        IF vnlinea > 1 THEN
                            LET vretiro = 0.00;
                            LET vdeposito = 0.00;
                            LET vsdocuenta = 0.00;
                            LET vfechealt = '01-01-1900';
                        END IF;

                        INSERT INTO bdicheq:sc_detalle_edocta
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, vretiro, vdeposito, vsdocuenta);
                    END FOREACH;
                ELSE -- // si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecución
                    IF trim(vcodretDet) <> '002' THEN -- // 002 la cuenta no tiene movimientos
                        ROLLBACK WORK;
                        
                        LET bInicia = "F";
                        LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
                        LET vcodret = '004';
                        
                        LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                                    'SET status_proc = '''||'C'||''','||
                                    'cod_ret = '''||vcodret||''','||
                                    'mensaje = '''||vErrorInfo||''','||
                                    'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                                    'WHERE fecha = '''||vfecha_hoy||''' '||
                                    'AND  status_proc = '''||'I'||''' '||
                                    'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
                        SYSTEM vcSql;
                        LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
                        SYSTEM vcStmt;
                        
                        RETURN vcodret;
                    END IF;
                END IF;
            END FOREACH;
        
        ELSE  -- // saldo de la cuenta menor o igual a 50
            -- // obtener la fecha de alta de la cuenta para saber si es su aniversario
            SELECT fecha_alta
              INTO vfechaAlta
              FROM bdicheq:sc_maenoc
             WHERE cuenta = vcuenta
               AND empresa = pEmpresa;

            -- // obtener el mes y dia de corte para compararlo con la fech_alt
            LET dFechaNacimiento = dFechaFinMovimientos + 1 UNITS DAY;

            IF TO_CHAR(vfechaAlta, '%m%d') = TO_CHAR(dFechaNacimiento, '%m%d' ) THEN
                LET  vaniversario = 1;
            ELIF
                TO_CHAR(vfechaAlta,'%m%d')  = '0229' AND TO_CHAR(dFechaNacimiento + 1 UNITS DAY, '%m%d') <> '0229' THEN
                IF TO_CHAR(dFechaNacimiento,'%m%d' ) = '0228' THEN
                    LET vaniversario = 1;
                END IF;
            END IF;

            IF vaniversario = 1 THEN
                -- // verificar que la cuenta no tenga movimientos en los últimos 6 meses.
                EXECUTE PROCEDURE bdicheq:sp_cortesig(dFechaFinMovimientos, -6)
                INTO vcodRetspCortSig, vfechCortSig;
                
                SELECT {+INDEX(sc_movhis idx_movhisnew1)} FIRST 1 cuenta
                  INTO vexiste_movhis
                  FROM bdicheq:sc_movhis
                 WHERE empresa = pEmpresa
                   AND cuenta = vcuenta
                   AND fech_alt BETWEEN vfechCortSig AND dFechaFinMovimientos
                   AND fech_alt >= cFech_param
                   AND cancelad <> 'S';
                
                SELECT {+INDEX(sc_movhis_old idx_movhis)} FIRST 1 cuenta
                  INTO vexiste_movhisold
                  FROM bdicheq:sc_movhis_old
                 WHERE empresa = pEmpresa
                   AND cuenta = vcuenta
                   AND fech_alt BETWEEN vfechCortSig AND dFechaFinMovimientos
                   AND fech_alt >= cFech_param_ini
                   AND fech_alt < cFech_param
                   AND cancelad <> 'S';
                   
                IF (vexiste_movhis is null OR vexiste_movhis = '') AND (vexiste_movhisold is null OR vexiste_movhisold = '')THEN
                    -- // ejecutar el store para llenar encabezado
                    SELECT NVL(MAX(idreg),0) + 1
                      INTO vidreg
                      FROM bdicheq:sc_encabezado_edocta;

                    EXECUTE PROCEDURE sp_generaredoctaejeencabezado(pEmpresa, vcuenta, vaniomes)
                    INTO vcodretEnc,vFecha_emision,vNum_cte,vNum_Tarjeta,vNombre_cte,vDireccion_cte,vDireccion_col,vDireccion_del,vEdo_cd,
                         vCve_ruta,vSucursal_nombre,vRFC_Cliente,vCP,vCve_ahorro,vClabe,vCurp,vFechaAltaEnc,vFechaInicio,vMensajeProducto,
                         vInserto,vfechaFinal,vSucursal_num,vSaldoAnterior,vDepositos,vInteresesPagados,vRetiros,vOtrosCargos,vIvaOtrosCargos,
                         vSaldoCorte,vSaldoPromedio,vRetencionIsr,vInteresesNetos,viDias,vTasaBruta,vPiePagina, vTotRetirosEfec, vTotOtrosCargos, vGAT;
                 
                    -- // si el resultado fue satisfactorio hacer las inserciones
                    IF trim(vcodretEnc) = '000' THEN
                    
                        INSERT INTO sc_encabezado_edocta
                        (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte,
                         direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, sucursal_nombre, rfc, cp,
                         cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte,
                         vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, vCve_ruta, vSucursal_nombre, vRFC_Cliente, vCP,
                         vCve_ahorro, vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, vInserto, vfechaFinal, vSucursal_num);
                         
                        INSERT INTO sc_encabezado2_edocta
                        (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros,
                         otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias, tasabruta)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                         vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta);

                        LET vsecuencia = 1;
                        LET vnlinea = 1;

                        INSERT INTO sc_piepagina_edocta 
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
                        
                        INSERT INTO sc_mensajes_edocta
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, 'Cuando utilices un cajero automático no aceptes ayuda de nadie.');
                        
                        INSERT INTO sc_mensajes_edocta
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea + 1, 'No se deje sorprender por llamadas telefónicas, mensajes por teléfono o mensajes en su correo electrónico en los que se le solicite su número de tarjeta de débito.');
                        
                        INSERT INTO sc_mensajes_edocta
                        (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea + 2, 'Al pagar con su tarjeta de débito y antes de firmar el recibo, verifique que el monto total de la compra sea el correcto.');
                        
                        INSERT INTO sc_grafica
                        (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
                        VALUES
                        (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vSaldoCorte, vTotRetirosEfec, vDepositos, vInteresesPagados, vOtrosCargos, vIvaOtrosCargos, vTotOtrosCargos, vGAT);
                        
                    ELSE  -- // si el resultado no fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecución
                    
                        ROLLBACK WORK;
                        
                        LET bInicia = "F";
                        LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
                        LET vcodret = '005' ;
                        
                        LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                                    'SET status_proc = '''||'C'||''','||
                                    'cod_ret = '''||vcodret||''','||
                                    'mensaje = '''||vErrorInfo||''','||
                                    'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                                    'WHERE fecha = '''||vfecha_hoy||''' '||
                                    'AND  status_proc = '''||'I'||''' '||
                                    'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
                        SYSTEM vcSql;
                        LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
                        SYSTEM vcStmt;
                        
                        RETURN vcodret;
                        
                    END IF;
                END IF; 
            END IF; 
        END IF; 

        COMMIT WORK;
        LET bInicia = "F";        
    END FOREACH;
    
    -- // actualizar el control de proceso
    LET vErrorInfo = 'PROCESO EXITOSO';
    LET vcSql = 'echo "UPDATE bdicheq:sc_contproc_edocta '||
                'SET status_proc = '''||'F'||''','||
                'cod_ret = '''||vcodret||''','||
                'mensaje = '''||vErrorInfo||''','||
                'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                'WHERE fecha = '''||vfecha_hoy||''' '||
                'AND  status_proc = '''||'I'||''' '||
                'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta.sql';
    SYSTEM vcSql;
    LET vcStmt = 'dbaccess bdicheq /tmp/contproc_edocta.sql';
    SYSTEM vcStmt;
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE;