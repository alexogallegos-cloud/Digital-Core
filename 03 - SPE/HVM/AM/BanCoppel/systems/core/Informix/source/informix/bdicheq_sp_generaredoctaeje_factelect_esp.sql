CREATE PROCEDURE "informix".sp_generaredoctaeje_factelect_esp( pEmpresa char(3), pFecha DATE, pBandera SMALLINT, pOpcion SMALLINT )
RETURNING CHAR(5);
   
    DEFINE vcSql                    CHAR(600);
    DEFINE vcStmt                   CHAR(250);
    DEFINE vNombre_cte              CHAR(254);
    DEFINE vcodret                  CHAR(5);
    DEFINE vCP                      CHAR(5);
    DEFINE vNum_Tarjeta             CHAR(16);
    DEFINE vRFC_Cliente             CHAR(13);
    DEFINE vSucursal_num            CHAR(4);
    DEFINE vdescripcion             CHAR(180);
    DEFINE vDireccion_cte           CHAR(200);
    DEFINE vSucursal_nombre         CHAR(40);
    DEFINE vexiste_genedoctaeje     CHAR(3);
    DEFINE vClabe                   CHAR(60);
    DEFINE vCurp                    CHAR(60);
    DEFINE vcortSig                 CHAR(255);
    DEFINE vDireccion_col           CHAR(120);
    DEFINE vDireccion_del           CHAR(120);
    DEFINE vEdo_cd                  CHAR(120);
    DEFINE cErrorInfo               CHAR(80);
    DEFINE vErrorInfo               CHAR(80);
    DEFINE vaniomes                 CHAR(6);
    DEFINE vcodretDet               CHAR(6);
    DEFINE vcodretEnc               CHAR(6);
    DEFINE vmin_aniomes             CHAR(6);
    DEFINE vmax_aniomes             CHAR(6);
    DEFINE vcuenta                  CHAR(20);
    DEFINE vNum_cte                 CHAR(20);
    DEFINE vmin_cta                 CHAR(20);
    DEFINE vmax_cta                 CHAR(20);
    DEFINE vMensajeProducto         CHAR(255);
    DEFINE vPiePagina               CHAR(255);
    DEFINE bInicia                  BOOLEAN;
    DEFINE iIsamErr                 SMALLINT;
    DEFINE viDias                   SMALLINT;
    DEFINE vsdocuenta               MONEY(14,2);
    DEFINE vdeposito                MONEY(14,2);
    DEFINE vretiro                  MONEY(14,2);
    DEFINE vTasaBruta               DECIMAL(9, 6);
    DEFINE vGAT                     DECIMAL(9, 6);
    DEFINE vIvaOtrosCargos          DECIMAL(18,2);
    DEFINE vSaldoCorte              DECIMAL(18,2);
    DEFINE vSaldoPromedio           DECIMAL(18,2);
    DEFINE vInteresesNetos          DECIMAL(18,2);
    DEFINE vSaldoAnterior           DECIMAL(18,2);
    DEFINE vDepositos               DECIMAL(18,2);
    DEFINE vInteresesPagados        DECIMAL(18,2);
    DEFINE vRetiros                 DECIMAL(18,2);
    DEFINE vOtrosCargos             DECIMAL(18,2);
    DEFINE vRetencionIsr            DECIMAL(18,2);
    DEFINE vTotRetirosEfec          DECIMAL(18,2);
    DEFINE vTotOtrosCargos          DECIMAL(18,2);
    DEFINE vcortSig2                INTEGER;
    DEFINE vsecuencia               INTEGER;
    DEFINE vnlinea                  INTEGER;
    DEFINE GLOBAL vidreg            INTEGER  DEFAULT 0;
    DEFINE vsqlerr                  INTEGER;
    DEFINE visamerr                 INTEGER;
    DEFINE vultejec                 DATE;
    DEFINE vfecha_hoy               DATE;
    DEFINE vfecha_ant               DATE;
    DEFINE vfechaAlta               DATE;
    DEFINE vfechealt                DATE;
    DEFINE vFecha_emision           DATE;
    DEFINE vFechaAltaEnc            DATE;
    DEFINE vFechaInicio             DATE;
    DEFINE vfechaFinal              DATE;
    DEFINE dFechaInicioMovimientos  DATE;
    DEFINE dFechaFinMovimientos     DATE;
    DEFINE dFechaEmision            DATE;
    DEFINE dFechaEmision_esp        DATE;
    DEFINE vruta_descarga           CHAR(60);
    DEFINE vsql                     CHAR(500);
    DEFINE vfecha                   CHAR(8);
    DEFINE vfechaproc               DATE;    
    -- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
    DEFINE vestado                  CHAR(4);
    DEFINE vciudad                  VARCHAR(60); 
    DEFINE vtelefono                CHAR(14);
    DEFINE vgerente                 CHAR(40);
    DEFINE cNumProducto             CHAR(4);
    DEFINE vmensaje                 CHAR(255);
    DEFINE vGATReal                 DECIMAL(9, 6);
    DEFINE vcorreo                  CHAR(100);
    DEFINE vEnvioMovtos             SMALLINT;
    ---NUEVAS VARIABLES
    DEFINE vConfirmacion            CHAR(5);
    DEFINE vValor_tasa              DECIMAL(9, 6);
    DEFINE vValor_tasa_isr          DECIMAL(9, 6); 
    DEFINE vBaseisr                 MONEY (16,2);
    DEFINE vanio                    INTEGER;
    DEFINE vresiduo                 INTEGER;
    DEFINE vaniobase                INTEGER;
    DEFINE vbase_exenta             MONEY (16,2);
    DEFINE v_descuento              MONEY (16,2);
    DEFINE v_Subtotal               MONEY (16,2);
    DEFINE v_Total                  MONEY (16,2);
    DEFINE v_secuencia              INTEGER;
    DEFINE v_tasa_isr               MONEY (16,2);
    DEFINE vtpo_persona             CHAR(2); 
    DEFINE ves_fisica               CHAR(1);
    DEFINE vexento_isr              CHAR(1); 
    DEFINE vres_iva_otros_cargos    DECIMAL(18,2);
    DEFINE v_Isr_valida             DECIMAL(18,2);
    DEFINE vSdoMesAnt               MONEY;
    DEFINE vTotRetiros              MONEY;
    DEFINE vTotDepositos            MONEY;
    DEFINE vSdoActual               MONEY;
    DEFINE v_exi_coreo              INTEGER;
    DEFINE v_exi_factelect          INTEGER;
    DEFINE vExportacion             CHAR(2);
    DEFINE vLongIden                CHAR(2);
    DEFINE vIdenRegFis              CHAR(3);
    DEFINE vObjImp                  CHAR(2);   
    DEFINE vBase                    MONEY (18,2);
    DEFINE vValidaTPersona			INTEGER; 

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
    LET vdescripcion = "";                                                  
    LET vcuenta = "";                                  
    LET vcodret = "000";
    LET vfecha_hoy = "";                           
    LET vfecha_ant = "";                                                                                         
    LET bInicia = "F";                         
    LET iIsamErr = 0;
    LET vFecha_emision = "01-01-1900";             
    LET vNum_cte = "";                         
    LET vNum_Tarjeta = "";
    LET vNombre_cte = "";                          
    LET vDireccion_cte = "";                   
    LET vDireccion_col = "";
    LET vDireccion_del = "";                       
    LET vEdo_cd = "";                          
    LET vSucursal_nombre = "";                     
    LET vSucursal_num  = "";                   
    LET vRFC_Cliente = "";
    LET vCP = "";                                  
    LET vClabe = "";
    LET vCurp = "";                                                        
    LET vFechaInicio = "";                    
    LET vSaldoAnterior = 0;
    LET vDepositos = 0;                            
    LET vInteresesPagados = 0;                 
    LET vRetiros = 0;
    LET vOtrosCargos = 0;                          
    LET vIvaOtrosCargos = 0;                   
    LET vSaldoCorte = 0;
    LET vSaldoPromedio = 0;                        
    LET vRetencionIsr = 0;   
    LET vTotRetirosEfec = 0;
    LET vTotOtrosCargos = 0;
    LET vInteresesNetos = 0;
    LET viDias = 0;                                
    LET vTasaBruta = 0;    
    LET vGAT = 0;   
    LET vfechaFinal = "";                          
    LET vcSql = "";                            
    LET vcStmt = "";        
    LET vmin_cta = '';                             
    LET vmax_cta = '';
    LET dFechaInicioMovimientos = '01-01-1900';    
    LET dFechaFinMovimientos = '01-01-1900';   
    LET dFechaEmision = '01-01-1900'; 
    LET dFechaEmision_esp = '01012010';
    LET vMensajeProducto = '';
    LET vPiePagina = "";
    LET vruta_descarga = '';
    LET vsql = '';
    LET vfecha = '';
    LET vfechaproc = '';
    -- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
    LET vestado = "";
    LET vciudad = "";
    LET vtelefono = "";
    LET vgerente = "";
    LET cNumProducto = "";
    LET vmensaje = '';
    LET vGATReal = 0;
    LET vcorreo = '';
    LET vEnvioMovtos = 0;
    ---NUEVAS VARIABLES
    LET vConfirmacion =  " ";
    LET vValor_tasa   =  0;
    LET vBaseisr      =  0.0;
    LET vaniobase     =  365;
    LET v_descuento   =  0.00;
    LET v_Subtotal    =  0.00;
    LET v_Total       =  0.00;
    LET vSdoMesAnt    = 0;
    LET vTotRetiros   = 0;
    LET vTotDepositos = 0;
    LET vSdoActual    = 0;
    LET v_exi_coreo   =  0;
    LET v_exi_factelect  =  0;
    LET vExportacion  =  " ";
    LET vLongIden     =  " ";
    LET vIdenRegFis   =  " ";
    LET vObjImp       =  " ";
    LET vBase         = 0.00;
    LET vValidaTPersona = 0;

    BEGIN
   
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/sp_generaredoctaeje_factelect_esp.err";
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
   
    --SET DEBUG FILE TO "/RESPALDOSNEW/Edbert_Bajo/CFDI/trace_esp.txt";
    --TRACE ON;
   
 
    -- DEFINE LA FORMA EN QUE SE MANEJARA LA FECHA EMISION 
    IF pOpcion = 1 THEN 
     -- // Armar la fecha de emision
      LET vfecha_ant    = pFecha;
      LET dFechaEmision = vfecha_ant;
      
    ELSE 
     -- FECHA ESPECIAL 
      LET vfecha_ant    = pFecha;
      LET dFechaEmision = dFechaEmision_esp;
    END IF;  
   

    -- // Obtener parametros de consultas
    SELECT valor
      INTO vruta_descarga
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'RutaDescargaFED';
      
    SELECT MIN(cuenta), MAX(cuenta), MIN(aniomes), MAX(aniomes)
      INTO vmin_cta, vmax_cta, vmin_aniomes, vmax_aniomes
      FROM sc_maehis;
     
    -- // CARGA TABLA CON CUENTAS POR PROCESAR
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxprocesar') THEN
        DROP TABLE "informix".ctasxprocesar;
    END IF;
   
    CREATE TABLE "informix".ctasxprocesar( cuenta char(20) not null )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idxtmp_ctasxprocesar_cuenta ON "informix".ctasxprocesar(cuenta) USING BTREE;

   
    IF  pBandera = 1 THEN
        LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentasxprocesar.unl INSERT INTO ctasxprocesar" > /resplogifx/conciliachq/ctasxproc.sql';
        SYSTEM vsql;
        LET vsql = '';
       
        --LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxproc.sql';
        LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/ctasxproc.sql';
        SYSTEM vsql;
        LET vsql = '';
       
        UPDATE STATISTICS HIGH FOR TABLE ctasxprocesar;
        
        -- SE OBTIENE EL MONTO EXENTO
        SELECT valor::INT
        INTO vbase_exenta 
        FROM sc_param
        WHERE empresa = '001'
        AND codparam ='baseexenta';
         
        -- // CALCULA EL ANIO BASE 
      
        LET vanio    = YEAR(vfecha_hoy);
        LET vresiduo =  MOD(vanio, 4);
      
        IF vresiduo  = 0 THEN 
           LET vaniobase = 366;
        END IF;
      
        --SE OBTIENE EL ANIO MES        
        LET v_secuencia  =  year(vfecha_ant)||lpad(month(vfecha_ant),2,"0");
                
        FOREACH WITH HOLD
            SELECT --{+INDEX(sc_maehis maehis1)}
                   mae.aniomes, mae.cuenta, mae.fechaini, mae.fechafin, mae.sdo_mes_ant, mae.totretiros,mae.totdepositos, mae.sdo_actual
              INTO vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros,vTotDepositos,vSdoActual
              FROM sc_maehis AS mae
             WHERE mae.aniomes BETWEEN vmin_aniomes and vmax_aniomes
               AND mae.cuenta BETWEEN vmin_cta AND vmax_cta
               AND mae.cuenta IN ( SELECT cuenta FROM ctasxprocesar )
               AND mae.cuenta NOT IN ( SELECT {+INDEX(sc_encabezado_edocta_factelect idx_encabezadofechacuenta_fe)}
                                              ee.num_cuenta
                                         FROM sc_encabezado_edocta_factelect ee
                                        WHERE ee.num_cuenta = mae.cuenta
                                          AND ee.fecha_emision = dFechaEmision )
               --AND mae.fechaini < vfecha_ant
               AND mae.fechafin = vfecha_ant
               AND mae.producto NOT IN('9901')
      
                   
            BEGIN WORK;
            LET bInicia = "T";
           
            -- // Ejecutar el store para llenar el encabezado
            SELECT NVL(MAX(idreg), 0) + 1
              INTO vidreg
              FROM sc_encabezado_edocta_factelect;
              
            LET vEnvioMovtos = 0;
            LET vcorreo = '';

            EXECUTE PROCEDURE sp_generaredoctaejeencabezado_factelect(pEmpresa, vcuenta, vaniomes)
            INTO vcodretEnc, vFecha_emision, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd,
                 vSucursal_nombre, vRFC_Cliente, vCP, vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vfechaFinal, vSucursal_num, vSaldoAnterior, vDepositos,
                 vInteresesPagados, vRetiros, vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta,
                 vTotRetirosEfec, vTotOtrosCargos, vGAT, vMensajeProducto, vPiePagina,
                 vestado,vciudad, vtelefono, vgerente, cNumProducto, vGATReal, vEnvioMovtos;    
                
            -- // Hacer las inserciones si el resultado del SP_generarEdoCtaejeencabezado_factelect fue satisfactorio
         
            IF  TRIM(vcodretEnc) = '000' THEN
                SELECT COUNT(*) 
                INTO   v_exi_coreo
                FROM   bdinteg:si_altaserv_edoctamov 
                WHERE  numcte = vNum_cte
                AND  cuenta = vcuenta;
                  
                IF  v_exi_coreo > 0 THEN 
                    IF  vSaldoPromedio >= 300 THEN 
                        SELECT correo_elec 
                        INTO   vcorreo
                        FROM   bdinteg:si_correos 
                        WHERE  numcte = vNum_cte 
                        AND    status_correo = 'A' 
                        AND    tipo_correo = 1 
                        AND    valido = 1
                        AND    secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = vNum_cte AND status_correo = 'A' AND tipo_correo = 1 AND valido = 1 );
                             
                        IF  vcorreo IS NULL THEN  
                            LET vcorreo = ''; 
                        END IF; 

                    ELSE
                        LET vcorreo = '';
                    END IF;
                        
                ELSE 
                    LET vcorreo = '';
                END IF; 
                  
                LET vcorreo = NVL(vcorreo,'');
                
                IF vRetencionIsr > 0 THEN
                
                    --OBTIENE LA TASA-ISR
                    SELECT first 1 tasa_isr
                    INTO   v_tasa_isr
                    FROM   sc_isr  
                    WHERE  cuenta    = vcuenta
                    AND    secuencia = v_secuencia
                    AND    tasa_isr  > 0;
                                       
                    IF   v_tasa_isr IS NULL  THEN 
                         LET v_tasa_isr = 0;
                    END IF;
                       
                    --TASA ISR          
                    LET vValor_tasa = TRUNC(((v_tasa_isr / 100 ) *  viDias) / vaniobase,6 ); 
                        
                    --OBTIENE EL SALDO PROMEDIO 
                    IF   vSaldoPromedio > vbase_exenta THEN 
                         LET vBaseisr = vSaldoPromedio - vbase_exenta;
                         LET vValor_tasa_isr = vValor_tasa;
                    ELSE
                         LET vBaseisr = 0;
                         LET vValor_tasa_isr = 0.0;
                    END IF;
                                                    
                ELSE      
                    LET vBaseisr = 0.0; 
                    LET vValor_tasa_isr = 0.0;
                    
                END IF;  

                --VALIDA EL VALOR DE LAS COMISIONES 
                
                LET vres_iva_otros_cargos = 0;
                LET vres_iva_otros_cargos = TRUNC((vOtrosCargos * .16 ),2);
                
                IF vres_iva_otros_cargos <> vIvaOtrosCargos THEN 
                   LET vOtrosCargos = TRUNC((vIvaOtrosCargos /.16),2); 
                ELSE 
                   LET vOtrosCargos = vOtrosCargos;
                END IF; 
            
                --VALIDA VALOR DE RETENCION ISR
                LET v_Isr_valida  = 0;
                LET v_Isr_valida  = TRUNC((vBaseisr * vValor_tasa_isr ),2); 
                
                IF  v_Isr_valida <> vRetencionIsr THEN
                    SELECT FIRST 1 promedio,       dia_promedio,   TRUNC((((tasa_isr / 100) * dia_promedio) / vaniobase),6)
                    INTO           vSaldoPromedio, viDias,         vValor_tasa_isr  
                    FROM   sc_isr 
                    WHERE  cuenta = vcuenta
                    AND    secuencia IN (SELECT MAX(secuencia) FROM sc_isr
                                            WHERE  cuenta = vcuenta);
                
                    LET vBaseisr =  ROUND((vRetencionIsr / vValor_tasa_isr ),2);                
                END IF;
                
                -- INICIALIZAMOS LA VARIABLE v_descuento
                LET v_descuento = 0.0;  
                
                IF  vIvaOtrosCargos = 0 AND vRetencionIsr > 0 THEN 
                    LET v_descuento = 0.01;
                    LET v_Subtotal  = 0.01;
                    LET v_Total     = v_Subtotal - v_descuento + vIvaOtrosCargos;
                END IF;             
                
                IF  vOtrosCargos = 0 AND vIvaOtrosCargos = 0 AND vRetencionIsr = 0 THEN 
                    LET v_descuento = 0.01;
                    LET v_Subtotal  = 0.01;
                    LET v_Total     = v_Subtotal - v_descuento + vIvaOtrosCargos; 
                END IF;     
                
                IF  vIvaOtrosCargos > 0 AND vRetencionIsr > 0 THEN  
                    LET v_descuento = 0.00;
                    LET v_Subtotal  = vOtrosCargos;
                    LET v_Total     = v_Subtotal - v_descuento + vIvaOtrosCargos; 
                END IF; 
                
                IF  vIvaOtrosCargos > 0 AND vRetencionIsr =  0 THEN  
                    LET v_descuento = 0.00;
                    LET v_Subtotal  = vOtrosCargos;
                    LET v_Total     = v_Subtotal - v_descuento + vIvaOtrosCargos;
                END IF; 
    
                -- Se obtiene el valor por el tipo de operacion del banco. 
                SELECT exportacion
                INTO   vExportacion
                FROM   bdicheq:sc_exportacion
                WHERE  exportacion = "01";
            
                --Regimen Fiscal
                Select count(*)
                Into vValidaTPersona
                From bdinteg:si_fiscal
                Where numcte = vNum_cte
                or regim_fiscal is null or regim_fiscal = "";

                IF  vValidaTPersona = "0" THEN
                    LET  vIdenRegFis = "616";
                ELSE 
                    Select regim_fiscal
                    Into vIdenRegFis
                    From bdinteg:si_fiscal
                    Where numcte = vNum_cte;
                END IF;                             
                               
                --Si la cuenta es objeto de impuesto 02, si no es objeto de impuesto 01
                IF   vOtrosCargos > 0 THEN 
                     LET  vObjImp = "02"; 
                ELSE 
                     LET  vObjImp = "01";
                END IF; 
                
                -- Variable para la base 
                LET vBase = vOtrosCargos;
                
                INSERT INTO sc_encabezado_edocta_factelect
                (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta,
                 sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc, correo, confirmacion,              exportacion, reg_fiscal, obj_impuesto, base)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, ' ',
                vSucursal_nombre, vRFC_Cliente, vCP, ' ', vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, '000000000000000', vfechaFinal, vSucursal_num, vciudad, vestado, vtelefono, vgerente, vcorreo, vConfirmacion,vExportacion,vIdenRegFis,vObjImp,      vBase);
               
                INSERT INTO sc_encabezado2_edocta_factelect
                (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros,
                 otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta,baseisr,tasaisr,descuento,subtotal,total)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta, vBaseisr, vValor_tasa_isr,v_descuento,v_Subtotal,v_Total);

                LET vsecuencia = 1;
                LET vnlinea = 1;
               
                INSERT INTO sc_piepagina_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
               
                FOREACH WITH HOLD                
                    select nlinea, mensaje, secuencia
                      into vnlinea, vmensaje, vsecuencia
                      from bdicheq:sc_mensajes_producto
                     where producto = cNumProducto
                       and secuencia in ('2','3','4','5','6','7','8','9')
                   
                    IF   vsecuencia = 2 THEN LET vsecuencia = 1;
                    ELIF vsecuencia = 3 THEN LET vsecuencia = 2;
                    ELIF vsecuencia = 4 THEN LET vsecuencia = 3;
                    ELIF vsecuencia = 5 THEN LET vsecuencia = 4;
                    ELIF vsecuencia = 6 THEN LET vsecuencia = 5;
                    ELIF vsecuencia = 7 THEN LET vsecuencia = 6;
                    ELIF vsecuencia = 8 THEN LET vsecuencia = 7;
                    ELIF vsecuencia = 9 THEN LET vsecuencia = 9;
                    END IF;
                                                           
                    INSERT INTO sc_mensajes_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vmensaje);
                END FOREACH;
               
                INSERT INTO sc_grafica_fe
                (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat, gat_real)
                VALUES
                (vidreg,dFechaEmision,vcuenta,vSaldoAnterior,vSaldoCorte,vTotRetirosEfec,vDepositos,vInteresesPagados,vOtrosCargos,vIvaOtrosCargos,vTotOtrosCargos,vGAT,vGATReal);
           
                 --// GENERA EL REGISTRO EN LA NUEVA TABLA DE CONSULTA DE ESTADOS DE CUENTA

                SELECT COUNT(*)
                INTO   v_exi_factelect
                FROM   sc_maehis_factelect
                WHERE  cuenta  = vcuenta 
                AND    aniomes = vaniomes;
               
               
                IF v_exi_factelect > 0 THEN 
                   DELETE FROM sc_maehis_factelect WHERE cuenta = vcuenta AND aniomes = vaniomes;
                END IF; 
                 
                 INSERT INTO "informix".sc_maehis_factelect(empresa,aniomes,cuenta,fechaini,fechafin,sdo_mes_ant,totretiros,totdepositos,sdo_actual)
                 VALUES(pEmpresa, vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros, vTotDepositos, vSdoActual);
           
          
            -- // Si el resultado NO fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecuciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n
            ELSE
                ROLLBACK WORK;
                LET bInicia = "F";
                LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
                LET vcodret = '003';
                RETURN vcodret;
            END IF;

            -- // Ejecutar store para el detalle
            LET vsecuencia = 0;

            FOREACH
                EXECUTE PROCEDURE sp_generaredoctaejedetalle_factelect_esp (pEmpresa, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, pOpcion)
                INTO vcodretDet, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro
                -- // Codigo de retorno diferente a 002 (la cuenta no tiene movimientos)
                IF TRIM(vcodretDet) <> '000' AND TRIM(vcodretDet) <> '002' THEN
                    ROLLBACK WORK;
                    LET bInicia = "F";
                    LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
                    LET vcodret = '004';
                    RETURN vcodret;
                END IF;
            END FOREACH;
           
            COMMIT WORK;
            LET bInicia = "F";       
        END FOREACH;
       
    ELSE
        -- // Obtiene las Cuentas y las arroja en la tabla temporal de trabajo
        INSERT INTO "informix".ctasxprocesar
        SELECT --{+INDEX(sc_maehis maehis1)} 
        mae.cuenta
        FROM sc_maehis AS mae
        WHERE mae.aniomes BETWEEN vmin_aniomes and vmax_aniomes
        AND mae.cuenta BETWEEN vmin_cta AND vmax_cta
        AND mae.cuenta NOT IN ( SELECT {+INDEX(sc_encabezado_edocta_factelect idx_encabezadofechacuenta_fe)}
                                  ee.num_cuenta
                             FROM sc_encabezado_edocta_factelect ee
                            WHERE ee.num_cuenta = mae.cuenta
                              AND ee.fechafinal = mae.fechafin )
        --AND mae.fechaini < vfecha_ant
        AND mae.fechafin = vfecha_ant
        AND mae.producto NOT IN('9901');
        
        
         -- SE OBTIENE EL MONTO EXENTO
      SELECT valor::INT
        INTO vbase_exenta 
        FROM sc_param
       WHERE empresa = '001'
         AND codparam ='baseexenta';
         
    -- // CALCULA EL ANIO BASE 
      
      LET vanio    = YEAR(vfecha_hoy);
      LET vresiduo =  MOD(vanio, 4);
      
      IF vresiduo  = 0 THEN 
         LET vaniobase = 366;
      END IF;
      
      --SE OBTIENE EL ANIO MES      
      LET v_secuencia  =  year(vfecha_ant)||lpad(month(vfecha_ant),2,"0");

          
        -- // Obtener las cuentas donde los intereses pagados sean mayor a 2000.00
        FOREACH WITH HOLD
            SELECT --{+INDEX(sc_maehis maehis1)}
                   mae.aniomes, mae.cuenta, mae.fechaini, mae.fechafin, mae.sdo_mes_ant, mae.totretiros,mae.totdepositos, mae.sdo_actual
              INTO vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros,vTotDepositos,vSdoActual
              FROM sc_maehis AS mae
             WHERE mae.aniomes BETWEEN vmin_aniomes and vmax_aniomes
               AND mae.cuenta BETWEEN vmin_cta AND vmax_cta
               AND mae.cuenta IN ( SELECT cuenta FROM "informix".ctasxprocesar )
               --AND mae.fechaini < vfecha_ant
               AND mae.fechafin = vfecha_ant
               AND mae.producto NOT IN('9901')
                   
            BEGIN WORK;
            LET bInicia = "T";
           
            -- // Ejecutar el store para llenar el encabezado
            SELECT NVL(MAX(idreg), 0) + 1
              INTO vidreg
              FROM sc_encabezado_edocta_factelect;
              
            LET vEnvioMovtos = 0;
            LET vcorreo = '';

            EXECUTE PROCEDURE sp_generaredoctaejeencabezado_factelect(pEmpresa, vcuenta, vaniomes)
            INTO vcodretEnc, vFecha_emision, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd,
                 vSucursal_nombre, vRFC_Cliente, vCP, vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vfechaFinal, vSucursal_num, vSaldoAnterior, vDepositos,
                 vInteresesPagados, vRetiros, vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta,
                 vTotRetirosEfec, vTotOtrosCargos, vGAT, vMensajeProducto, vPiePagina,
                 vestado,vciudad, vtelefono, vgerente, cNumProducto, vGATReal, vEnvioMovtos;    
                
            -- // Hacer las inserciones si el resultado del SP_generarEdoCtaejeencabezado_factelect fue satisfactorio
            IF trim(vcodretEnc) = '000' THEN
               SELECT COUNT(*) 
                 INTO v_exi_coreo
                 FROM bdinteg:si_altaserv_edoctamov 
                WHERE numcte = vNum_cte
                  AND cuenta = vcuenta;
                  
                  IF  v_exi_coreo > 0 THEN 
                      IF vSaldoPromedio >= 300 THEN 
                          SELECT correo_elec 
                            INTO vcorreo
                            FROM bdinteg:si_correos 
                           WHERE numcte = vNum_cte 
                             AND status_correo = 'A' 
                             AND tipo_correo = 1 
                             AND valido = 1
                             AND secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = vNum_cte AND status_correo = 'A' AND tipo_correo = 1 AND valido = 1 );
                             
                             IF  vcorreo IS NULL THEN  
                                 LET vcorreo = ''; 
                             END IF; 

                       ELSE
                            LET vcorreo = '';
                       END IF;
                        
                   ELSE 
                        LET vcorreo = '';
                   END IF; 
                  
                   LET vcorreo = NVL(vcorreo,'');
                
                -----RSV
                
            IF vRetencionIsr > 0 THEN
            
               --OBTIENE LA TASA-ISR
                SELECT first 1 tasa_isr
                  INTO v_tasa_isr
                  FROM sc_isr  
                 WHERE cuenta    = vcuenta
                   AND secuencia = v_secuencia
                   AND tasa_isr > 0;
                   
                   
                   IF v_tasa_isr IS NULL  THEN 
                       LET v_tasa_isr = 0;
                   END IF;
                   
                --TASA ISR          
                LET vValor_tasa = TRUNC(((v_tasa_isr / 100 ) *  viDias) / vaniobase,6 ); 
            
        
                SELECT tpo_persona
                  INTO vtpo_persona
                  FROM bdinteg:si_cliente
                 WHERE numcte = vNum_cte;

                SELECT es_fisica, exento_isr
                  INTO ves_fisica, vexento_isr
                  FROM bdinteg:si_tipper
                 WHERE tpo_persona = vtpo_persona;

                IF vexento_isr = 'N' THEN
                   IF ves_fisica = 'S' THEN
                      IF  vSaldoPromedio > vbase_exenta THEN 
                          LET vBaseisr = vSaldoPromedio - vbase_exenta;
                          LET vValor_tasa_isr = vValor_tasa;
                      ELSE
                          LET vBaseisr = 0;
                          LET vValor_tasa_isr = 0.0;
                      END IF;
                   ELSE
                      LET vBaseisr = vSaldoPromedio;
                      LET vValor_tasa_isr = vValor_tasa;
                   END IF;
                ELSE   
                    LET vBaseisr = 0;
                    LET vValor_tasa_isr = 0.0;
                END IF;                 
            ELSE      
                LET vBaseisr = 0.0; 
                LET vValor_tasa_isr = 0.0;
            END IF;  

                
            -- INICIALIZAMOS LA VARIABLE v_descuento
            LET v_descuento = 0.0;  
            
                
            IF vIvaOtrosCargos = 0 AND vRetencionIsr > 0 THEN 
               LET v_descuento = 0.00;
            END IF;  
            
            
            IF vOtrosCargos = 0 AND vIvaOtrosCargos = 0 AND vRetencionIsr = 0 THEN 
               LET v_descuento = 0.01;
            END IF; 
            
            
            IF vIvaOtrosCargos > 0 AND vRetencionIsr > 0 THEN  
               LET v_descuento = 0.00;
            END IF; 
            
            
            IF vIvaOtrosCargos > 0 AND vRetencionIsr =  0 THEN  
               LET v_descuento = 0.00;
            END IF; 

            --DETERMINA EL TOTAL
            LET v_Subtotal =  ( vOtrosCargos + v_descuento + vRetencionIsr );
            --DETERMINA EL SUBTOTAL
            LET v_Total    =  ( vOtrosCargos + vIvaOtrosCargos );
            
            --VALIDA EL VALOR DE LAS COMISIONES 
            LET vres_iva_otros_cargos = 0;
            LET vres_iva_otros_cargos = TRUNC((vOtrosCargos * .16 ),2);
            
            IF vres_iva_otros_cargos <> vIvaOtrosCargos THEN 
               LET vOtrosCargos = TRUNC((vIvaOtrosCargos /.16),2); 
            ELSE 
               LET vOtrosCargos = vOtrosCargos;
            END IF;
            
            --VALIDA VALOR DE RETENCION ISR
            LET v_Isr_valida  = 0;
            LET v_Isr_valida  = TRUNC((vBaseisr * vValor_tasa_isr ),2); 
            
            
            IF v_Isr_valida <> vRetencionIsr THEN 
               LET  vBaseisr  =  ROUND((vRetencionIsr / vValor_tasa_isr + .01 ),2);
               LET  vSaldoPromedio = ROUND((vRetencionIsr / vValor_tasa_isr + .01 + vbase_exenta),2);
            ELSE 
               LET vBaseisr = vBaseisr; 
               LET vSaldoPromedio = vSaldoPromedio; 
            END IF; 
                        
            --VALIDA LA BASE Y LA TASA
            IF vRetencionIsr > 0 AND vBaseisr = 0  AND vValor_tasa_isr = 0 THEN  
                SELECT promedio, dia_promedio, promedio - vbase_exenta, TRUNC((((tasa_isr / 100) * dia_promedio) / vaniobase),6)
                  INTO vSaldoPromedio,viDias,vBaseisr,vValor_tasa_isr  
                  FROM sc_isr 
                 WHERE cuenta = vcuenta
                   AND tasa_isr IN (SELECT MAX(tasa_isr)  FROM sc_isr
                                     WHERE cuenta = vcuenta); 
            END IF; 

                   
                INSERT INTO sc_encabezado_edocta_factelect
                (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta,
                 sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc, correo, confirmacion)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, ' ',
                 vSucursal_nombre, vRFC_Cliente, vCP, ' ', vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, '000000000000000', vfechaFinal, vSucursal_num, vciudad, vestado, vtelefono, vgerente, vcorreo, vConfirmacion);
               
                INSERT INTO sc_encabezado2_edocta_factelect
                (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros,
                 otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta ,baseisr,tasaisr,descuento,subtotal,total)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta, vBaseisr, vValor_tasa_isr,v_descuento,v_Subtotal,v_Total);

                LET vsecuencia = 1;
                LET vnlinea = 1;
               
                INSERT INTO sc_piepagina_edocta_factelect
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
               
                FOREACH WITH HOLD                
                    select nlinea, mensaje, secuencia
                      into vnlinea, vmensaje, vsecuencia
                      from bdicheq:sc_mensajes_producto
                     where producto = cNumProducto
                       and secuencia in ('2','3','4','5','6','7','8','9')
                   
                    IF   vsecuencia = 2 THEN LET vsecuencia = 1;
                    ELIF vsecuencia = 3 THEN LET vsecuencia = 2;
                    ELIF vsecuencia = 4 THEN LET vsecuencia = 3;
                    ELIF vsecuencia = 5 THEN LET vsecuencia = 4;
                    ELIF vsecuencia = 6 THEN LET vsecuencia = 5;
                    ELIF vsecuencia = 7 THEN LET vsecuencia = 6;
                    ELIF vsecuencia = 8 THEN LET vsecuencia = 7;
                    ELIF vsecuencia = 9 THEN LET vsecuencia = 9;
                    END IF;
                                                           
                    INSERT INTO sc_mensajes_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vmensaje);
                END FOREACH;
               
                INSERT INTO sc_grafica_fe
                (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat, gat_real)
                VALUES
                (vidreg,dFechaEmision,vcuenta,vSaldoAnterior,vSaldoCorte,vTotRetirosEfec,vDepositos,vInteresesPagados,vOtrosCargos,vIvaOtrosCargos,vTotOtrosCargos,vGAT,vGATReal);
                
                --// GENERA EL REGISTRO EN LA NUEVA TABLA DE CONSULTA DE ESTADOS DE CUENTA
            
            INSERT INTO "informix".sc_maehis_factelect(empresa,aniomes,cuenta,fechaini,fechafin,sdo_mes_ant,totretiros,totdepositos,sdo_actual)
            VALUES(pEmpresa, vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros, vTotDepositos, vSdoActual);

            
            -- // Si el resultado NO fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecucion
            ELSE
                ROLLBACK WORK;
                LET bInicia = "F";
                LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
                LET vcodret = '003';
                RETURN vcodret;
            END IF;

            -- // Ejecutar store para el detalle
            LET vsecuencia = 0;

            FOREACH
                EXECUTE PROCEDURE sp_generaredoctaejedetalle_factelect(pEmpresa, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos)
                INTO vcodretDet, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro
                -- // Codigo de retorno diferente a 002 (la cuenta no tiene movimientos)
                IF TRIM(vcodretDet) <> '000' AND TRIM(vcodretDet) <> '002' THEN
                    ROLLBACK WORK;
                    LET bInicia = "F";
                    LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
                    LET vcodret = '004';
                    RETURN vcodret;
                END IF;
            END FOREACH;
           
            COMMIT WORK;
            LET bInicia = "F";       
        END FOREACH;
   
    END IF;
   
   
   
    IF  pOpcion = 1 THEN 
    LET vfecha = TO_CHAR(vfecha_ant, '%m%d%Y');
   
    -- // GENERA EL ARCHIVO DE LA TABLA sc_encabezado_edocta_factelect
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_encabezado_edocta_'||vfecha||'.txt'||
               ' SELECT * FROM sc_encabezado_edocta_factelect WHERE fecha_emision = '''|| vfecha_ant ||''' AND num_cuenta IN (SELECT cuenta FROM ctasxprocesar) ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'dskrga_fed.sql';
    SYSTEM vsql;
   
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/dskrga_fed.sql"; 
    SYSTEM vsql;
   
    -- // GENERA EL ARCHIVO DE LA TABLA sc_encabezado2_edocta_factelect
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_encabezado2_edocta_'||vfecha||'.txt'||
               ' SELECT * FROM sc_encabezado2_edocta_factelect WHERE fecha_emision = '''|| vfecha_ant ||''' AND num_cuenta IN (SELECT cuenta FROM ctasxprocesar) ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'dskrga_fed.sql';
    SYSTEM vsql;
   
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/dskrga_fed.sql"; 
    SYSTEM vsql;
   
    -- // GENERA EL ARCHIVO DE LA TABLA sc_detalle_edocta_factelect
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_detalle_edocta_'||vfecha||'.txt'||
               ' SELECT * FROM sc_detalle_edocta_factelect WHERE fecha_emision = '''|| vfecha_ant ||''' AND num_cuenta IN (SELECT cuenta FROM ctasxprocesar) ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'dskrga_fed.sql';
    SYSTEM vsql;
   
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/dskrga_fed.sql"; 
    SYSTEM vsql;
   
    -- // GENERA EL ARCHIVO DE LA TABLA sc_piepagina_edocta_factelect
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_piepagina_edocta_'||vfecha||'.txt'||
               ' SELECT * FROM sc_piepagina_edocta_factelect WHERE fecha_emision = '''|| vfecha_ant ||''' AND num_cuenta IN (SELECT cuenta FROM ctasxprocesar) ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'dskrga_fed.sql';
    SYSTEM vsql;
   
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/dskrga_fed.sql"; 
    SYSTEM vsql;
   
    -- // GENERA EL ARCHIVO DE LA TABLA sc_mensajes_edocta_factelect
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_mensajes_edocta_'||vfecha||'.txt'||
               ' SELECT * FROM sc_mensajes_edocta_factelect WHERE fecha_emision = '''|| vfecha_ant ||''' AND num_cuenta IN (SELECT cuenta FROM ctasxprocesar) ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'dskrga_fed.sql';
    SYSTEM vsql;
   
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/dskrga_fed.sql"; 
    SYSTEM vsql;
   
    -- // GENERA EL ARCHIVO DE LA TABLA sc_grafica_fe
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_grafica_edocta_'||vfecha||'.txt'||
               ' SELECT * FROM sc_grafica_fe WHERE fecha_emision = '''|| vfecha_ant ||''' AND num_cuenta IN (SELECT cuenta FROM ctasxprocesar) ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'dskrga_fed.sql';
    SYSTEM vsql;
   
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/dskrga_fed.sql"; 
    SYSTEM vsql;
   
    -- // GENERA EL ARCHIVO DE LA TABLA sc_aclaraciones_edocta_factelect
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(vruta_descarga) ||'sc_aclaraciones_edocta_'||vfecha||'.txt'||
               ' SELECT * FROM sc_aclaraciones_edocta_factelect WHERE fecha_emision = '''|| vfecha_ant ||''' AND num_cuenta IN (SELECT cuenta FROM ctasxprocesar) ORDER BY num_cuenta" > '|| TRIM(vruta_descarga) ||'dskrga_fed.sql';
    SYSTEM vsql;
   
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/edoctacfd/dskrga_fed.sql"; 
    SYSTEM vsql;
    END IF; 
   
    RETURN vcodret;
   
    END;
   
END PROCEDURE;