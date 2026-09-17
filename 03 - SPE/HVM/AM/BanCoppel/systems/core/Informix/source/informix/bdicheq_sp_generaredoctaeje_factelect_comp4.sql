CREATE PROCEDURE "informix".sp_generaredoctaeje_factelect_comp4( pEmpresa char(3) )
RETURNING CHAR(5);
    
    DEFINE GLOBAL vidreg INTEGER DEFAULT 0;    
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
    DEFINE vcuenta                  CHAR(20);
    DEFINE vNum_cte                 CHAR(20);
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
    DEFINE vsqlerr                  INTEGER;
    DEFINE visamerr                 INTEGER;
    DEFINE vultejec                 DATE;
    DEFINE vfecha_hoy               DATE;
    DEFINE vult_mes                 DATE;
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
    DEFINE vruta_descarga           CHAR(60);
    DEFINE vsql                     CHAR(500);
    DEFINE vfecha                   CHAR(8);
    DEFINE vfechaproc               DATE;
    DEFINE vestado                  CHAR(4);
    DEFINE vciudad                  VARCHAR(60); 
    DEFINE vtelefono                CHAR(14);
    DEFINE vgerente                 CHAR(40);
    DEFINE cNumProducto             CHAR(4);
    DEFINE vmensaje                 CHAR(255);
    DEFINE vGATReal                 DECIMAL(9, 6);
    DEFINE vcodretparam             CHAR(5);   
    DEFINE vcuenta_min              CHAR(20);
    DEFINE vinicio_proceso          SMALLINT;
    DEFINE vSdoMesAnt               MONEY;
    DEFINE vTotRetiros              MONEY;
    DEFINE vTotDepositos            MONEY;
    DEFINE vSdoActual               MONEY;
	DEFINE vcorreo	                CHAR(100);
    DEFINE vEnvioMovtos             SMALLINT;	
  	---NUEVAS VARIABLES
	DEFINE vConfirmacion            CHAR(5);
	DEFINE vValor_tasa              DECIMAL(9, 6);
    DEFINE vValor_tasa_isr          DECIMAL(9, 6); 
	DEFINE vBaseisr                 MONEY (16,2);
	DEFINE vanio 					INTEGER;
	DEFINE vresiduo				    INTEGER;
	DEFINE vaniobase                INTEGER;
	DEFINE vbase_exenta             MONEY (16,2);
	DEFINE v_descuento              MONEY (16,2);
	DEFINE v_Subtotal				MONEY (16,2);
	DEFINE v_Total					MONEY (16,2);
	DEFINE v_secuencia              INTEGER;
	DEFINE v_tasa_isr               MONEY (16,2);
	DEFINE ves_fisica               CHAR(1);
	DEFINE vexento_isr              CHAR(1); 
	DEFINE vres_iva_otros_cargos    DECIMAL(18,2);
	DEFINE v_Isr_valida             DECIMAL(18,2);
	DEFINE v_exi_coreo              INTEGER;
	DEFINE vcuenta_max              CHAR(20);
	DEFINE vExportacion             CHAR(2);
	DEFINE vLongIden                CHAR(2);
	DEFINE vIdenRegFis              CHAR(3);
	DEFINE vObjImp                  CHAR(2);   
    DEFINE vBase                    MONEY (18,2);	
	DEFINE vProdcfdi                INTEGER;
	DEFINE vValidaTPersona			INTEGER;
    
    LET vidreg = 0;       
    LET vaniomes = "";                             
    LET vcodretDet = "";                       
    LET vcodretEnC = "";                         
    LET cErrorInfo = "";                         
    LET vErrorInfo = "INICIO DEL PROCESO";
    LET vcortSig2 = 0;                             
    LET vcortSig = "";                         
    LET vsecuencia = 0;
    LET vnlinea =0;                                
    LET vultejec = '';                  
    LET vsqlerr = 0;                           
    LET vdeposito = 0;
    LET vretiro = 0;                               
    LET vfechealt = "";                        
    LET vsdocuenta = 0;
    LET vdescripcion = "";                                                  
    LET vcuenta = "";                                  
    LET vcodret = "00000";
    LET vfecha_hoy = ""; 
    LET vult_mes = "";     
    LET vfecha_ant = "";                                                                                         
    LET bInicia = "F";                         
    LET iIsamErr = 0;
    LET vFecha_emision = "";             
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
    LET dFechaInicioMovimientos = '';    
    LET dFechaFinMovimientos = '';   
    LET dFechaEmision = ''; 
    LET vMensajeProducto = '';
    LET vPiePagina = "";
    LET vruta_descarga = '';
    LET vsql = '';
    LET vfecha = '';
    LET vfechaproc = '';
    LET vestado = "";
    LET vciudad = "";
    LET vtelefono = "";
    LET vgerente = "";
    LET cNumProducto = "";
    LET vmensaje = '';
    LET vGATReal = 0;
    LET vcodretparam = '';
    LET vcuenta_min = '';
    LET vinicio_proceso = 0;
    LET vSdoMesAnt = 0;
    LET vTotRetiros = 0;
    LET vTotDepositos = 0;
    LET vSdoActual = 0;
	LET vcorreo = "";
    LET vEnvioMovtos = 0;	
    ---NUEVAS VARIABLES
	LET vConfirmacion =  " ";
	LET vValor_tasa   =  0;
	LET vBaseisr      =  0.0;
	LET vaniobase     =  365;
	LET v_descuento   =  0.00;
	LET v_Subtotal    =  0.00;
	LET v_Total	      =  0.00;
	LET v_exi_coreo   =  0;
    LET vcuenta_max   = '';
	LET vExportacion  = " ";
	LET vLongIden     = " ";
	LET vIdenRegFis   = " ";
	LET vObjImp       = " ";
	LET vBase         = 0.00;
	LET vProdcfdi     = 0;
	LET vValidaTPersona = 0;
	   
    BEGIN
   
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/sp_generaredoctaeje_factelect_comp4.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            LET vErrorInfo = cErrorInfo;
			LET vcuenta = vcuenta;
            IF bInicia = "T" THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
   
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/edoctacfd/sp_generaredoctaeje_factelect_comp4.out';
	---    TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
   
    -- // Obtener la fecha de ayer y hoy
    SELECT fecha_ant, fecha_hoy, pri_dia_mes - 1 units day
      INTO vfecha_ant, vfecha_hoy, vult_mes
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	 
    
    -- // VERIFICA SE HAYA EFECTUADO EL PASO DE MOVS A HISTORICO
    SELECT fecha
      INTO vfechaproc
      FROM sc_contproc
     WHERE empresa = pempresa
       AND proceso = "pasomovshist"
       AND fecha   = vfecha_ant;
      
        IF vfechaproc is null THEN
           LET vcodret = '953';
           RETURN vcodret;
       END IF;

    -- // Armar la fecha de emision
    LET dFechaEmision = vfecha_ant;

    -- // obtener la fecha de ultima ejecucion correcta
    SELECT NVL(MAX(fecha),vfecha_ant)
      INTO vultejec
      FROM sc_contproc_edocta_factelect
     WHERE proceso = 'GENERA EDO CTA FE'
       AND empresa = pEmpresa
       AND status_proc = 'F'
       AND tipo_proc   = 'D';

        IF vultejec >= vfecha_hoy THEN -- // si no se ejecuto hoy
           LET vcodret = '00000';
           RETURN vcodret;
       END IF;
   
    WHILE vinicio_proceso = 0
        SET ISOLATION TO DIRTY READ;
        SELECT COUNT(*)
          INTO vinicio_proceso
          FROM sc_contproc
         WHERE empresa = pEmpresa
           AND proceso = 'ini_genedoctafed'
           AND fecha = vfecha_ant;
    END WHILE;
   
    -- // OBTIENE VALORES PARA RANGO DE SERIALES A PROCESAR
    SELECT valor
      INTO vcuenta_min
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'CtaIniGenEdoCtaComp4';
	   
	   
	SELECT valor
      INTO vcuenta_max
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'CtaIniGenEdoCtaComp5';
	   

	    -- SE OBTIENE EL MONTO EXENTO
	  SELECT valor::INT
	    INTO vbase_exenta 
        FROM sc_param
       WHERE empresa = '001'
         AND codparam ='baseexenta';
	  

	  -- // CALCULA ANIOBASE
	  
	  LET vanio    = YEAR(vfecha_hoy);
      LET vresiduo =  MOD(vanio, 4);
	  
      IF vresiduo  = 0 THEN 
         LET vaniobase = 366;
      END IF;
	  
	   
	    --SE OBTIENE EL ANIO MES 		
	  LET v_secuencia  =  year(vfecha_ant)||lpad(month(vfecha_ant),2,"0");
	   
         
    -- // Obtener las cuentas a procesar
    FOREACH WITH HOLD
	
        SELECT mae.aniomes, mae.cuenta, mae.fechaini, 			 mae.fechafin,         mae.sdo_mes_ant,  mae.totretiros, mae.totdepositos, mae.sdo_actual
        INTO   vaniomes,    vcuenta,    dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt,       vTotRetiros,    vTotDepositos,    vSdoActual
        FROM   sc_maehis_cfdi_cap AS mae
        WHERE  mae.cuenta >= vcuenta_min
		AND    mae.cuenta < vcuenta_max
	    --AND    mae.cuenta NOT IN (SELECT fe.cuenta 
		--					      FROM   sc_maehis_factelect fe 
		--					      WHERE  fe.empresa  = "001"
		--					      AND    fe.cuenta   = mae.cuenta
		--					      AND    fe.fechafin = mae.fechafin)
               
        BEGIN WORK;
        LET bInicia = "T";
       
        -- // Ejecutar el store para llenar el encabezado       
        SELECT valor::int
          INTO vidreg
          FROM sc_param
         WHERE empresa = pEmpresa
           AND codparam = 'RegIniGenEdoCtaComp4';
          
        LET vidreg = vidreg + 1;
        LET vEnvioMovtos = 0;
        LET vcorreo = '';
		
		
        SELECT COUNT(*) 
		INTO   vProdcfdi
		FROM   bdicheq:sc_maehis_factelect 
		WHERE  empresa  = "001"
		AND    cuenta   = vcuenta
		AND    fechafin = dFechaFinMovimientos;
				
		IF vProdcfdi = 0 THEN 
		   SELECT COUNT(*) 
		   INTO   vProdcfdi
		   FROM   bdicheq:sc_maehis_factelect 
		   WHERE  empresa = "001"
		   AND    aniomes = vaniomes
		   AND    cuenta  = vcuenta;
		
		    IF vProdcfdi =  0 THEN 
		    
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

                    --Se Obtiene Regimen Fiscal
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
                       
                        IF  vsecuencia  = 2 THEN LET vsecuencia = 1;
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
                   
		        
                -- // Si el resultado NO fue satisfactorio agregar el mensaje en el control de proceso y terminar la ejecuciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n
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
                    IF TRIM(vcodretDet) <> "000"  AND TRIM(vcodretDet) <> '002' THEN
                        ROLLBACK WORK;
                        LET bInicia = "F";
                        LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
                        LET vcodret = '004';
                        RETURN vcodret;
                    END IF;
                END FOREACH;
		        
                UPDATE sc_param 
                   SET valor = vidreg
                 WHERE empresa = pEmpresa
                   AND codparam = 'RegIniGenEdoCtaComp4';
            END IF;
		END IF;
        COMMIT WORK;
        LET bInicia = "F";       
    END FOREACH;
   
    UPDATE sc_contproc
       SET fecha = vfecha_ant
     WHERE empresa = pEmpresa
       AND proceso = 'genedoctafedcomp4';
   
    END;
   
    RETURN vcodret;
   
END PROCEDURE;