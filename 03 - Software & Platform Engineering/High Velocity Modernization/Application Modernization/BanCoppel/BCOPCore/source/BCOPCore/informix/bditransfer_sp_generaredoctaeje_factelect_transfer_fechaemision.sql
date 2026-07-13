CREATE PROCEDURE "informix".sp_generaredoctaeje_factelect_transfer_fechaemision(pEmpresa char(3), dFechaEmision date)
RETURNING CHAR(5);
   
    DEFINE vcSql                    CHAR(600);
    DEFINE vcStmt                   CHAR(250);
    --DEFINE vNombre_cte              CHAR(150);
    DEFINE vcodret                  CHAR(5);
    --DEFINE vCP                      CHAR(5);
    DEFINE vNum_Tarjeta             CHAR(16);
    --DEFINE vRFC_Cliente             CHAR(13);
    --DEFINE vSucursal_num            CHAR(4);
    DEFINE vdescripcion             CHAR(180);
    --DEFINE vDireccion_cte           CHAR(200);
    DEFINE vSucursal_nombre         CHAR(40);
    DEFINE vexiste_genedoctaeje     CHAR(3);
    --DEFINE vClabe                   CHAR(60);
    --DEFINE vCurp                    CHAR(60);
    DEFINE vcortSig                 CHAR(255);
    --DEFINE vDireccion_col           CHAR(120);
    DEFINE vDireccion_del           CHAR(120);
    DEFINE vEdo_cd                  CHAR(120);
    DEFINE cErrorInfo               CHAR(80);
    DEFINE vErrorInfo               CHAR(80);
    DEFINE vaniomes                 CHAR(6);
    DEFINE vcodretDet               CHAR(6);
    DEFINE vcodretEnc               CHAR(6);
    DEFINE vmin_aniomes             CHAR(6);
    DEFINE vmax_aniomes             CHAR(6);
    --DEFINE vcuenta                  CHAR(20);
    --DEFINE vNum_cte                 CHAR(20);
    DEFINE vmin_cta                 CHAR(20);
    DEFINE vmax_cta                 CHAR(20);
    DEFINE vMensajeProducto         CHAR(255);
    DEFINE vPiePagina               CHAR(255);
   
    DEFINE bInicia                  BOOLEAN;
   
    DEFINE iIsamErr                 SMALLINT;
    --DEFINE viDias                   SMALLINT;
   
    DEFINE vsdocuenta               MONEY(14,2);
    DEFINE vdeposito                MONEY(14,2);
    DEFINE vretiro                  MONEY(14,2);
   
    DEFINE vTasaBruta               DECIMAL(9, 6);
    DEFINE vGAT                     DECIMAL(9, 6);
    DEFINE vIvaOtrosCargos          DECIMAL(18,2);
    --DEFINE vSaldoCorte              DECIMAL(18,2);
    --DEFINE vSaldoPromedio           DECIMAL(18,2);
    DEFINE vInteresesNetos          DECIMAL(18,2);
    --DEFINE vSaldoAnterior           DECIMAL(18,2);
    --DEFINE vDepositos               DECIMAL(18,2);
    DEFINE vInteresesPagados        DECIMAL(18,2);
    --DEFINE vRetiros                 DECIMAL(18,2);
    DEFINE vOtrosCargos             DECIMAL(18,2);
    DEFINE vRetencionIsr            DECIMAL(18,2);
    DEFINE vTotRetirosEfec          DECIMAL(18,2);
    DEFINE vTotOtrosCargos          DECIMAL(18,2);
   
    DEFINE vcortSig2                INTEGER;
    DEFINE vsecuencia               INTEGER;
    DEFINE vnlinea                  INTEGER;
    DEFINE vidreg                   INTEGER;
    DEFINE vsqlerr                  INTEGER;
    DEFINE visamerr                 INTEGER;
   
    DEFINE vultejec                 DATE;
    DEFINE vfecha_hoy               DATE;
    DEFINE vfecha_ant               DATE;
    DEFINE vfechaAlta               DATE;
    DEFINE vfechealt                DATE;
    DEFINE vFecha_emision           DATE;
    --DEFINE vFechaAltaEnc            DATE;
    --DEFINE vFechaInicio             DATE;
    DEFINE vfechaFinal              DATE;
    DEFINE dFechaInicioMovimientos  DATE;
    DEFINE dFechaFinMovimientos     DATE;
    --DEFINE dFechaEmision            DATE;
   
    DEFINE vsql                     CHAR(500);
    DEFINE vfecha                   CHAR(8);
    DEFINE vfechaproc               DATE;
    -- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
    DEFINE vestado             CHAR(50);
    DEFINE vciudad             VARCHAR(60); 
    DEFINE vtelefono         CHAR(14);
    DEFINE vgerente         CHAR(40);
    DEFINE cNumProducto        CHAR(4);
    DEFINE vmensaje            CHAR(255);
     
    DEFINE vfechafin         DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vnumcte            CHAR(20);
    DEFINE vnumctetf        CHAR(20);
    DEFINE vnombre_completo CHAR(150);
    DEFINE vdireccion          CHAR(200);
    DEFINE vzona               CHAR(120);
    DEFINE vnomsuc             CHAR(40);
    --DEFINE vciudad ya esta declarado arriba
    --DEFINE vestado 
    --DEFINE vMensajeProducto     CHAR(255);   ya esta definida arriba
    DEFINE vrfc                CHAR(13);
    DEFINE vrfc_alterno        CHAR(13);
    DEFINE vcp                CHAR(5);
    DEFINE vclabe            CHAR(60);
    DEFINE vcurp            CHAR(60);
    DEFINE valta_cte        DATE;
    DEFINE vfechaini        DATE;
    DEFINE vsucursal        CHAR(4);
    DEFINE vsdoant            DECIMAL(18,2);
    DEFINE vtotdep            DECIMAL(18,2);
    DEFINE vtotret            DECIMAL(18,2);
    DEFINE vsdoact            DECIMAL(18,2);
    DEFINE vsdoprom            DECIMAL(18,2);
    DEFINE vdias             SMALLINT;
    DEFINE cMensajeProducto CHAR(255); 
    DEFINE vedosuc             CHAR(4);
    DEFINE vcdsuc             VARCHAR(60);  --
    DEFINE vtel             CHAR(14);
    --DEFINE vgerente         CHAR(40);
    DEFINE vdescrip         CHAR(180);
    DEFINE vmonto              MONEY(14,2);
    DEFINE vmontoRet          MONEY(14,2);
    DEFINE vmontodep          MONEY(14,2);
    DEFINE vsdoactual          MONEY(14,2);
    --DEFINE vcortSig           
    --DEFINE vfechealt
    DEFINE vcuantos          INTEGER;
    DEFINE vcuantos2          INTEGER; 
    DEFINE vconreg             smallint;
    DEFINE viva               MONEY(14,2);
    DEFINE vcomisiones          MONEY(14,2);
    DEFINE votrocargos        MONEY(14,2);
    DEFINE vretiefect       MONEY(14,2);
   
    LET vaniomes = "";                             
    LET vcodretDet = "";                       
    LET vcodretEnC = "";                         
    LET cErrorInfo="";                         
    LET vErrorInfo= "INICIO DEL PROCESO";
    LET vcortSig2 = 0;                             
    LET vcortSig = "";                         
    LET vsecuencia = 0;
    LET vnlinea =0;                                
    LET vidreg = 0;                            
    LET vultejec = '';                  
    LET vsqlerr = 0;                           
    LET vdeposito = 0;
    LET vretiro = 0;                               
    LET vfechealt = "";                        
    LET vsdocuenta = 0;
    --LET vdescrip = "";                                                  
    LET vcuenta = "";                                  
    LET vcodret = "00000";
    LET vfecha_hoy = "";                           
    LET vfecha_ant = "";                                                                                         
    LET bInicia = "F";                         
    LET iIsamErr = 0;
    LET vFecha_emision = "01-01-1900";             
    --LET vNum_cte = "";                         
    LET vNum_Tarjeta = "";
    --LET vNombre_cte = "";                          
    --LET vDireccion_cte = "";                   
    --LET vDireccion_col = "";
    LET vDireccion_del = "";                       
    LET vEdo_cd = "";                          
    LET vSucursal_nombre = "";                     
    --LET vSucursal_num  = "";                   
    LET vrfc = "";
    LET vrfc_alterno ="";
    LET vCP = "";                                  
    LET vClabe = "";
    LET vCurp = "";                                                        
    --LET vFechaInicio = "";                    
    --LET vSaldoAnterior = 0;
    --LET vDepositos = 0;                            
    LET vInteresesPagados = 0;                 
    --LET vRetiros = 0;
    LET vOtrosCargos = 0;                          
    LET vIvaOtrosCargos = 0;                   
    --LET vSaldoCorte = 0;
    --LET vSaldoPromedio = 0;                        
    LET vRetencionIsr = 0;   
    LET vTotRetirosEfec = 0;
    LET vTotOtrosCargos = 0;
    LET vInteresesNetos = 0;
    --LET viDias = 0;                                
    LET vTasaBruta = 0;    
    LET vGAT = 0;   
    LET vfechaFinal = "";                          
    LET vcSql = "";                            
    LET vcStmt = "";        
    LET vmin_cta = '';                             
    LET vmax_cta = '';
    LET dFechaInicioMovimientos = '01-01-1900';    
    LET dFechaFinMovimientos = '01-01-1900';   
    --LET dFechaEmision = '01-01-1900'; 
    LET vMensajeProducto = '';
    LET vPiePagina = "";
    --LET vruta_descarga = ''; 
    LET vsql = '';
    LET vfecha = '';
    LET vfechaproc = '';
    -- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
    LET vestado             = "";
    LET vciudad             = "";
    LET vtel             = "";
    LET vgerente             = "";
    LET cNumProducto        = "";
    LET vmensaje             = '';
    LET vdescrip = "";    
    LET vmonto         = 0;
    LET vmontoRet     = 0;
    LET vmontodep     = 0;
    LET vsdoactual     = 0;
    LET vcdsuc        = "";
    LET vcuantos            = 0;
    LET vcuantos2            = 0;
    LET vnumctetf             = "";
    LET vnumcte             = "";
    LET viva                   = 0;
    LET vcomisiones            = 0;
    LET votrocargos            = 0;
    LET vretiefect            = 0;
    
     --SET DEBUG FILE TO "/informix/1170/german/sp_generaredoctaeje_factelect_transfer_fechaemision.out";
     --TRACE ON;

    BEGIN
   
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "./sp_generaredoctaeje_factelect_transfer_fechaemision.err";
            TRACE ON;
           
            LET vcodret = vsqlerr;
            LET vErrorInfo = cErrorInfo;
           
            IF bInicia = "T" THEN
                ROLLBACK WORK;
            END IF;
           
           
            RETURN vcodRet;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF pEmpresa IS NULL  THEN
        LET vcodret = '00001';
        RETURN vcodret;
    END IF;
   
    -- // Obtener la fecha de ayer y hoy
    SELECT pri_dia_mes - 1 units day, fecha_hoy
      INTO vfecha_ant, vfecha_hoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
     
      -- // Armar la fecha de emision
        --LET dFechaEmision = vfecha_ant;
        --LET dFechaEmision = '06-30-2016';
   
     select count(*)
     into vconreg
     from bditransfer:tf_resumen_edocta
     where periodo_fin = dFechaEmision;
   
     
       if vconreg = 0 then
          let vcodret = "00969"; -- NO EXISTE INFORMACION TRANSFER DEL PERIODO SOLICITADO
          return vcodret;
      
       else
   
   

            FOREACH WITH HOLD
             
            SELECT tf.periodo_fin, tf.cuenta, /*tf.numcte,*/  TRIM(NVL(TRIM(tf.nombre), "")||' '||NVL(TRIM(tf.ape_paterno), "")||' '||NVL(TRIM(tf.ape_materno), "")),
            TRIM(NVL(TRIM(tf.calle), "")||' '||NVL(TRIM(tf.no_ext), "")||' '||NVL(TRIM(tf.no_int), "")), tf.colonia/*nombrezona de si_catzonas */, tf.municipio, tf.ent_federativa,
            /*tf.rfc,*/ tf.cod_postal, tf.clabe , tf.curp, tf.fecha_apert, /*<--FECHA DE ALTA DEL CTE*/ tf.periodo_ini, LPAD (TRIM(tf.sucursal),4,'0')/*tf.sucursal*/, tf.saldo_ini, tf.abonos_sum,
            tf.cargos_sum, tf.saldo_fin, tf.saldo_prom,  tf.diasperiodo,  (tf.sv_tici - tf.at_tisi) as iva,tf.monto_efectivo, tf.comisiones_sum,
            ( tf.cargos_sum - tf.monto_efectivo) as otrocargo
            into vfechafin, vcuenta, /*vnumcte, /*vtarjeta,*/ vnombre_completo,
            vdireccion, vzona, vciudad, vestado,
            /*vrfc,*/ vcp, vclabe, vcurp, valta_cte, vfechaini,  vsucursal, vsdoant, vtotdep,
            vtotret, vsdoact, vsdoprom, vdias, viva, vretiefect, vcomisiones, votrocargos
            from bditransfer:tf_resumen_edocta tf , bditransfer:tf_maecte mae
            where tf.periodo_fin =  dFechaEmision
            and tf.integridad = 'V'
            and tf.cuenta = mae.cuenta_tf
           
                    select rfc, numcte, numcte_tf            
                into vrfc, vnumcte, vnumctetf
                from bditransfer:tf_maecte
                where cuenta_tf = vcuenta;
                --and status_cta ='1';-- se agrega validacion de status cuenta
           
                    IF vnumcte IS NOT null THEN
                   
                    select rfc, rfc_alterno 
                    into  vrfc, vrfc_alterno
                    from bdinteg:si_cliente
                    where numcte = vnumcte;
                           
                            IF vrfc_alterno IS NOT null THEN
                               
                                LET vrfc = vrfc_alterno;
                           
                            END IF
                           
                    END IF
           
            BEGIN WORK;
            LET bInicia = "T";
           
            /*
            LET vsucursal = '5001';
           
            select nombre
            into vnomsuc
            from bdinteg:si_sucursales 
            where sucursal =vsucursal;
            */
           
            /*
            FOREACH
                EXECUTE PROCEDURE bdicobranza:sp_obtenerposicion (vnomsuc, ",")
                into vcuantos , vcuantos2
               
                exit FOREACH;
               
            end FOREACH
            */
                   
            --select substr ( nombre, 1, vcuantos - 1), estado,  ciudad, telefono1, gerente
           
            LET vsucursal = '5001';
           
            select nombre, estado,  ciudad, telefono1, gerente
            into   vnomsuc, vedosuc, vcdsuc , vtel, vgerente
            from bdinteg:si_sucursales
            where sucursal = vsucursal;
           
            select nombre
            into vcdsuc
            from bdinteg:si_ciudades
            where estado = vedosuc 
            and ciudad = vcdsuc;  
           
            select siglas
            into vedosuc
            from bdinteg:si_estados
            where estado = vedosuc;
           
           
           
            SELECT LIMIT 1
                       TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto
                  INTO vMensajeProducto
                  FROM bdicheq:sc_producto AS ap
                 WHERE ap.empresa = '001'
                   AND ap.producto = '8000';
             
              -- mensaje para sc_piepagina_edocta_factelect
              SELECT LIMIT 1 mensaje
              INTO vPiePagina
              FROM bdicheq:sc_mensajes_producto
             WHERE producto = '8000'
             and secuencia = '1';
             
             
             
                -- se obtiene el numero de tarjeta
           
                select tar.num_tarjeta
                into vNum_Tarjeta
                from bdicheq:sc_tarjeta tar
                where tar.cuenta = vcuenta
                  and tar.status_tar = 'A';
              -- *********** TERMINA PARTE DE TRANSFER ****** --
                     
               
                -- // Ejecutar el store para llenar el encabezado
                SELECT NVL(MAX(idreg), 0) + 1
                  INTO vidreg
                  FROM bdicheq:sc_encabezado_edocta_factelect;

             
                -- // Hacer las inserciones si el resultado del SP_generarEdoCtaejeencabezado_factelect fue satisfactorio
               
                IF ( vrfc IS NULL OR vnombre_completo IS NULL OR vfechaini IS NULL OR vfechafin IS NULL ) THEN
                    LET vcodret = '00001';
                    RETURN vcodret;
                END IF;
               
                  IF trim(vcodret) = '00000' THEN
        --        IF trim(vcodretEnc) = '000' THEN
               
                    INSERT INTO bdicheq:sc_encabezado_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta,
                     sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vnumctetf, nvl (vNum_Tarjeta,''), vnombre_completo, vdireccion, vzona,/*vDireccion_col,*/ vciudad, vestado, ' ',
                     vnomsuc, vrfc, vcp, ' ', vclabe, vcurp, valta_cte,  vfechaini, vMensajeProducto, '000000000000000', vfechafin, vsucursal, vcdsuc, vedosuc, vtel, vgerente);
                   
                    INSERT INTO bdicheq:sc_encabezado2_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros,
                     otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsdoant, vtotdep, '0', vtotret,
                     vcomisiones, viva, vsdoact, vsdoprom, '0', '0', vdias, '0');

                    LET vsecuencia = 1;
                    LET vnlinea = 1;
                   
                    INSERT INTO bdicheq:sc_piepagina_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
                   
                        FOREACH WITH HOLD -- PARA INSERTAR LAS TABLAS
                           
                           
                            select  nlinea, mensaje, secuencia
                            into  vnlinea, vmensaje, vsecuencia
                            from bdicheq:sc_mensajes_producto
                            where producto = '8000'
                            and secuencia in ('2','3','4','5','6','7','8')
                           
                           
                            IF vsecuencia = 2 THEN LET vsecuencia = 1;
                                ELIF vsecuencia = 3 THEN LET vsecuencia = 2;
                                ELIF vsecuencia = 4 THEN LET vsecuencia = 3;
                                ELIF vsecuencia = 5 THEN LET vsecuencia = 4;
                                ELIF vsecuencia = 6 THEN LET vsecuencia = 5;
                                ELIF vsecuencia = 7 THEN LET vsecuencia = 6;
                                ELIF vsecuencia = 8 THEN LET vsecuencia = 7;
                            END IF
                           
                                                                   
                            INSERT INTO bdicheq:sc_mensajes_edocta_factelect
                            (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                            VALUES
                            (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vmensaje);

                       
                        END FOREACH --TERMINA FOREACH
                   
                    INSERT INTO bdicheq:sc_grafica_fe
                    (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsdoant, vsdoact, vretiefect, vtotdep, '0', vcomisiones, viva, votrocargos, '0');
               
                -- // Si el resultado NO fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecuciÃ³n
                ELSE
               
                   ROLLBACK WORK;
                   
                    LET bInicia = "F";
                   
                    LET vcodret = '00003';
                             
                   
                    RETURN vcodret;
                   
                END IF;

                -- // Ejecutar store para el detalle
                LET vsecuencia = 0;
                LET vmontodep = 0;
                LET vmontoRet = 0;
                LET vsdoactual = vsdoact;

                FOREACH
                        SELECT TRIM(NVL(TRIM(det.desc_mov1), "")||' '||NVL(TRIM(det.desc_mov2), "")||' '||NVL(TRIM(det.desc_mov3), "")), det.monto, det.fecha_mov   
                        INTO  vdescrip,/* vdesc2, vdesc3,*/ vmonto, vfechealt
                        FROM bditransfer:tf_detalle_edocta  det
                        where det.cuenta = vcuenta
                        and det.periodo_fin = vfechafin
                        ORDER BY fecha_mov desc , orden_mov::integer desc
                   
                        IF vmonto < 0 THEN
                            LET vmontoRet = vmonto;
                            LET vmontodep = 0;
                            LET vmontoRet = vmontoRet * -1;
                        ELSE
                            LET vmontodep = vmonto;
                            LET vmontoRet = 0;
                        END IF
                       
                               
                        LET vsdoactual = vsdoactual - vmontodep + vmontoRet;
                             
           
                        LET vsecuencia = vsecuencia + 1;
                        LET vnlinea = 0;
                       
                        -- // Cortar los detalles en lineas
                        FOREACH
                            EXECUTE PROCEDURE bdicred:corta_linea(vdescrip, 40)
                            INTO vcortSig, vcortsig2

                            LET vnlinea = vnlinea + 1;

                            IF vnlinea > 1 THEN
                           
                            LET vfechealt = '01-01-1900';
                               
                            INSERT INTO bdicheq:sc_detalle_edocta_factelect
                            (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                            VALUES
                            (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, '0.00', '0.00', '0.00');                   
                       
                            ELSE
                       
                            INSERT INTO bdicheq:sc_detalle_edocta_factelect
                            (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                            VALUES
                            (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, vmontoRet, vmontodep, vsdoactual);
                           
                            END IF;
                           
                        END FOREACH;
                   
                   
                END FOREACH;
               
                COMMIT WORK;
                LET bInicia = "F";       
            END FOREACH;
           
                RETURN vcodret;
        END IF;
   
    END;
   
END PROCEDURE;