CREATE PROCEDURE "informix".sp_generaredoctaeje_factelectxcuenta( pEmpresa CHAR(3), pCuenta CHAR(20), pFechaFin DATE )
RETURNING CHAR(5), CHAR(80);
    
    DEFINE vNombre_cte              CHAR(150);
    DEFINE vcodret                  CHAR(5);
    DEFINE vcodret2                 CHAR(5);
    DEFINE vCP                      CHAR(5);
    DEFINE vNum_Tarjeta             CHAR(16);
    DEFINE vRFC_Cliente             CHAR(13);
    DEFINE vSucursal_num            CHAR(4);
    DEFINE vdescripcion             CHAR(180);
    DEFINE vDireccion_cte           CHAR(200);
    DEFINE vSucursal_nombre         CHAR(40);
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
    DEFINE vmin_cta                 CHAR(20);
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
    DEFINE vidreg                   INTEGER;
    DEFINE vsqlerr                  INTEGER;
    DEFINE vfechealt                DATE;
    DEFINE vFecha_emision           DATE;
    DEFINE vFechaAltaEnc            DATE;
    DEFINE vFechaInicio             DATE;
    DEFINE vfechaFinal              DATE;
    DEFINE dFechaInicioMovimientos  DATE;
    DEFINE dFechaFinMovimientos     DATE;
    DEFINE dFechaEmision            DATE;
	DEFINE vestado 			        CHAR(4);
	DEFINE vciudad 			        VARCHAR(60);  
	DEFINE vtelefono 		        CHAR(14);
	DEFINE vgerente 		        CHAR(40);
	DEFINE cNumProducto		        CHAR(4);
	DEFINE vmensaje			        CHAR(255);
    DEFINE vGATReal                 DECIMAL(9, 6);
    DEFINE iExiste                  SMALLINT;
    DEFINE cProceso                 SMALLINT;
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
	DEFINE vtpo_persona             CHAR(2); 
	DEFINE ves_fisica               CHAR(1);
	DEFINE vexento_isr              CHAR(1); 
	DEFINE vres_iva_otros_cargos    DECIMAL(18,2);
	DEFINE v_Isr_valida             DECIMAL(18,2);
	DEFINE vfecha_ant               DATE;
	DEFINE vfecha_hoy               DATE;
	DEFINE vSdoMesAnt               MONEY;
	DEFINE vTotRetiros              MONEY;
	DEFINE vTotDepositos            MONEY;
	DEFINE vSdoActual               MONEY;
	
	
    LET vaniomes = "";                              
    LET vcodretDet = "";                        
    LET vcodretEnC = "";                          
    LET cErrorInfo="";                          
    LET vErrorInfo= "";
    LET vcortSig2 = 0;                              
    LET vcortSig = "";                          
    LET vsecuencia = 0;
    LET vnlinea =0;                                 
    LET vidreg = 0;                                         
    LET vsqlerr = 0;                            
    LET vdeposito = 0;
    LET vretiro = 0;                                
    LET vfechealt = "";                         
    LET vsdocuenta = 0;
    LET vdescripcion = "";                                                   
    LET vcuenta = "";                                   
    LET vcodret = "";
    LET vcodret2 = "";                                                                                                            
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
    LET dFechaInicioMovimientos = '';     
    LET dFechaFinMovimientos = '';    
    LET dFechaEmision = pFechaFin;  
    LET vMensajeProducto = '';
    LET vPiePagina = "";
	LET vestado = "";
	LET vciudad = "";
	LET vtelefono = "";
	LET vgerente = "";
	LET cNumProducto = "";
	LET vmensaje = '';
    LET vGATReal = 0;
    LET iExiste = 0;
    LET cProceso = 0;
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
	LET vfecha_ant    = ""; 
	LET vSdoMesAnt    = 0;
	LET vTotRetiros   = 0;
	LET vTotDepositos = 0;
	LET vSdoActual    = 0;

    BEGIN
    
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        SET DEBUG FILE TO "./sp_generaredoctaeje_factelectxcuenta.err";
        TRACE ON;
        IF vsqlerr != 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = iIsamErr;
            LET vErrorInfo = cErrorInfo;
            IF bInicia = "T" THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet, vErrorInfo;
        END IF;
    END EXCEPTION;
        
     --SET DEBUG FILE TO "/informix/moha/sp_generaredoctaeje_factelectxcuenta.out";
     --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM sc_encabezado_edocta_factelect
     WHERE fecha_emision = dFechaEmision
       AND num_cuenta = pCuenta;
       
    IF iExiste > 0 THEN
        LET cProceso = 1;
    ELSE    
        SELECT COUNT(*)
          INTO iExiste
          FROM sc_encabezado_edocta_factelect_old
         WHERE fecha_emision = dFechaEmision
           AND num_cuenta = pCuenta;
           
        IF iExiste > 0 THEN
            LET cProceso = 2;
        ELSE
            LET bInicia = "F";
            LET vErrorInfo = 'CUENTA NO EXISTE EN TABLAS. VERIFIQUE.';
            LET vcodret = '100';            
            RETURN vcodret, vErrorInfo;
        END IF;
    END IF;
	
	
	
	  -- // Obtener la fecha de ayer y hoy
    SELECT fecha_ant, fecha_hoy
      INTO vfecha_ant, vfecha_hoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	
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
        SELECT aniomes, cuenta, fechaini, fechafin, mae.sdo_mes_ant, mae.totretiros, mae.totdepositos, mae.sdo_actual
          INTO vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros, vTotDepositos, vSdoActual
          FROM sc_maehis 
         WHERE empresa = pEmpresa
           AND cuenta = pCuenta
           AND aniomes = aniomes
           AND fechaini < pFechaFin
           AND fechafin = pFechaFin
           AND producto NOT IN('9901')
                
        BEGIN WORK;
        LET bInicia = "T";
        LET vEnvioMovtos = 0;
        LET vcorreo = '';
		
        EXECUTE PROCEDURE sp_generaredoctaejeencabezado_factelect( pEmpresa, vcuenta, vaniomes )
        INTO vcodretEnc, vFecha_emision, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, 
             vSucursal_nombre, vRFC_Cliente, vCP, vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vfechaFinal, vSucursal_num, vSaldoAnterior, vDepositos, 
             vInteresesPagados, vRetiros, vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta,
             vTotRetirosEfec, vTotOtrosCargos, vGAT, vMensajeProducto, vPiePagina, vestado, vciudad, vtelefono, vgerente, cNumProducto, vGATReal, vEnvioMovtos; 
             
        IF TRIM(vcodretEnc) = '000' THEN 
        
            IF cProceso = 1 THEN
				-- VALIDACION DE CORREO
				IF vEnvioMovtos = 1 THEN
					SELECT correo_elec 
					  INTO vcorreo
					  FROM bdinteg:si_correos 
					 WHERE numcte = vNum_cte 
					   AND status_correo = 'A' 
					   AND tipo_correo = 1 
					   AND valido = 1
					   AND secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = vNum_cte AND status_correo = 'A' AND tipo_correo = 1 AND valido = 1 );
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
			
			
			 IF v_Isr_valida > 0 THEN 
			     IF v_Isr_valida <> vRetencionIsr THEN 
			        LET  vBaseisr  =  ROUND((vRetencionIsr / vValor_tasa_isr + .01 ),2);
			        LET  vSaldoPromedio = ROUND((vRetencionIsr / vValor_tasa_isr + .01 + vbase_exenta),2);
			     ELSE 
			        LET vBaseisr = vBaseisr; 
			        LET vSaldoPromedio = vSaldoPromedio; 
			     END IF;    
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

				
                SELECT NVL(MAX(idreg), 0) + 1
                  INTO vidreg
                  FROM sc_encabezado_edocta_factelect;
        
                DELETE FROM sc_encabezado_edocta_factelect
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
				   
            
                INSERT INTO sc_encabezado_edocta_factelect
                (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, 
                 sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc, correo, confirmacion)               
			   VALUES
                (vidreg, dFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, ' ', 
                 vSucursal_nombre, vRFC_Cliente, vCP, ' ', vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, '000000000000000', vfechaFinal, vSucursal_num, vciudad, vestado, vtelefono, vgerente, vcorreo, vConfirmacion);
                
				DELETE FROM sc_encabezado2_edocta_factelect
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
                
                INSERT INTO sc_encabezado2_edocta_factelect
                (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros, 
                 otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta,baseisr,tasaisr,descuento,subtotal,total)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta, vBaseisr, vValor_tasa_isr,v_descuento,v_Subtotal,v_Total);
             
                DELETE FROM sc_piepagina_edocta_factelect
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;

                LET vsecuencia = 1;
                LET vnlinea = 1;
                
                INSERT INTO sc_piepagina_edocta_factelect 
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
            
                DELETE FROM sc_mensajes_edocta_factelect
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
                
                FOREACH WITH HOLD 				
                    SELECT nlinea, mensaje, secuencia
                      INTO vnlinea, vmensaje, vsecuencia
                      FROM sc_mensajes_producto
                     WHERE producto = cNumProducto
                       AND secuencia in ('2','3','4','5','6','7','8','9')
                    
                    IF vsecuencia = 2 THEN 
                        LET vsecuencia = 1;
                    ELIF vsecuencia = 3 THEN 
                        LET vsecuencia = 2;
                    ELIF vsecuencia = 4 THEN 
                        LET vsecuencia = 3;
                    ELIF vsecuencia = 5 THEN 
                        LET vsecuencia = 4; 
                    ELIF vsecuencia = 6 THEN 
                        LET vsecuencia = 5; 
                    ELIF vsecuencia = 7 THEN 
                        LET vsecuencia = 6; 
                    ELIF vsecuencia = 8 THEN 
                        LET vsecuencia = 7; 
                    ELIF vsecuencia = 9 THEN 
                        LET vsecuencia = 9; 
                    END IF;
                                                            
                    INSERT INTO sc_mensajes_edocta_factelect
                    (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vmensaje);
                END FOREACH;
                
                DELETE FROM sc_grafica_fe
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
                
                INSERT INTO sc_grafica_fe
                (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat, gat_real)
                VALUES
                (vidreg,dFechaEmision,vcuenta,vSaldoAnterior,vSaldoCorte,vTotRetirosEfec,vDepositos,vInteresesPagados,vOtrosCargos,vIvaOtrosCargos,vTotOtrosCargos,vGAT,vGATReal);
                
				
				DELETE FROM sc_maehis_factelect
				WHERE aniomes = vaniomes
				AND   cuenta  = vcuenta;
				
				INSERT INTO "informix".sc_maehis_factelect(empresa,aniomes,cuenta,fechaini,fechafin,sdo_mes_ant,totretiros,totdepositos,sdo_actual)
                VALUES(pEmpresa, vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros, vTotDepositos, vSdoActual);
				
				
				
                DELETE FROM sc_detalle_edocta_factelect
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
                   
                LET vsecuencia = 0;

                FOREACH
                    EXECUTE PROCEDURE sp_generaredoctaejedetalle_factelect(pEmpresa, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos)
                    INTO vcodretDet, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro
                    
                    IF TRIM(vcodretDet) <> '000' AND TRIM(vcodretDet) <> '002' THEN 
						ROLLBACK WORK;
						LET bInicia = "F";
						LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
						LET vcodret = '004';
						RETURN vcodret, vErrorInfo;
                    END IF;
                END FOREACH;
                
            ELIF cProceso = 2 THEN
			
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
			
			
			 IF v_Isr_valida > 0 THEN 
			     IF v_Isr_valida <> vRetencionIsr THEN 
			        LET  vBaseisr  =  ROUND((vRetencionIsr / vValor_tasa_isr + .01 ),2);
			        LET  vSaldoPromedio = ROUND((vRetencionIsr / vValor_tasa_isr + .01 + vbase_exenta),2);
			     ELSE 
			        LET vBaseisr = vBaseisr; 
			        LET vSaldoPromedio = vSaldoPromedio; 
			     END IF;    
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
			
            
                SELECT NVL(MAX(idreg), 0) + 1
                  INTO vidreg
                  FROM sc_encabezado_edocta_factelect_old;
            
                DELETE FROM sc_encabezado_edocta_factelect_old
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
            
                INSERT INTO sc_encabezado_edocta_factelect_old
                (idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, 
                 sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc, correo)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vNum_cte, vNum_Tarjeta, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd, ' ', 
                 vSucursal_nombre, vRFC_Cliente, vCP, ' ', vClabe, vCurp, vFechaAltaEnc, vFechaInicio, vMensajeProducto, '000000000000000', vfechaFinal, vSucursal_num, vciudad, vestado, vtelefono, vgerente);
                
                DELETE FROM sc_encabezado2_edocta_factelect_old
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
                
                INSERT INTO sc_encabezado2_edocta_factelect_old
                (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros, 
                 otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vSaldoAnterior, vDepositos, vInteresesPagados, vRetiros,
                 vOtrosCargos, vIvaOtrosCargos, vSaldoCorte, vSaldoPromedio, vRetencionIsr, vInteresesNetos, viDias, vTasaBruta);
             
                DELETE FROM sc_piepagina_edocta_factelect_old
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;

                LET vsecuencia = 1;
                LET vnlinea = 1;
                
                INSERT INTO sc_piepagina_edocta_factelect_old 
                (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                VALUES
                (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
            
                DELETE FROM sc_mensajes_edocta_factelect_old
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
                
                FOREACH WITH HOLD 				
                    SELECT nlinea, mensaje, secuencia
                      INTO vnlinea, vmensaje, vsecuencia
                      FROM sc_mensajes_producto
                     WHERE producto = cNumProducto
                       AND secuencia in ('2','3','4','5','6','7','8','9')
                    
                    IF vsecuencia = 2 THEN 
                        LET vsecuencia = 1;
                    ELIF vsecuencia = 3 THEN 
                        LET vsecuencia = 2;
                    ELIF vsecuencia = 4 THEN 
                        LET vsecuencia = 3;
                    ELIF vsecuencia = 5 THEN 
                        LET vsecuencia = 4; 
                    ELIF vsecuencia = 6 THEN 
                        LET vsecuencia = 5; 
                    ELIF vsecuencia = 7 THEN 
                        LET vsecuencia = 6; 
                    ELIF vsecuencia = 8 THEN 
                        LET vsecuencia = 7; 
                    ELIF vsecuencia = 9 THEN 
                        LET vsecuencia = 9; 
                    END IF;
                                                            
                    INSERT INTO sc_mensajes_edocta_factelect_old
                    (idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
                    VALUES
                    (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vmensaje);
                END FOREACH;
                
                DELETE FROM sc_grafica_fe_old
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
                
                INSERT INTO sc_grafica_fe_old
                (id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat, gat_real)
                VALUES
                (vidreg,dFechaEmision,vcuenta,vSaldoAnterior,vSaldoCorte,vTotRetirosEfec,vDepositos,vInteresesPagados,vOtrosCargos,vIvaOtrosCargos,vTotOtrosCargos,vGAT,vGATReal);
                
				DELETE FROM sc_maehis_factelect
				WHERE aniomes = vaniomes
				AND   cuenta  = vcuenta;
				
				INSERT INTO "informix".sc_maehis_factelect(empresa,aniomes,cuenta,fechaini,fechafin,sdo_mes_ant,totretiros,totdepositos,sdo_actual)
                VALUES(pEmpresa, vaniomes, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos, vSdoMesAnt, vTotRetiros, vTotDepositos, vSdoActual);

				
                DELETE FROM sc_detalle_edocta_factelect_old
                 WHERE fecha_emision = dFechaEmision
                   AND num_cuenta = pCuenta;
                   
                LET vsecuencia = 0;
                
                FOREACH
                    EXECUTE PROCEDURE sp_generaredoctaejedetalle_factelect(pEmpresa, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos)
                    INTO vcodretDet, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro
                    
                    IF TRIM(vcodretDet) = '000' THEN 
                        LET vsecuencia = vsecuencia + 1;
                        LET vnlinea = 0;
                        
                        FOREACH 
                            EXECUTE PROCEDURE bdicred:corta_linea(vdescripcion, 40)
                            INTO vcortSig, vcortsig2

                            LET vnlinea = vnlinea + 1;

                            IF vnlinea > 1 THEN
                                LET vretiro = 0.00;
                                LET vdeposito = 0.00;
                                LET vsdocuenta = 0.00;
                                LET vfechealt = '01-01-1900';
                            END IF;
                            
                            INSERT INTO sc_detalle_edocta_factelect_old
                            (idreg, fecha_emision, num_cuenta, secuencia, nlinea, fechamov, descripcion, retiro, deposito, saldo)
                            VALUES
                            (vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vfechealt, vcortSig, vretiro, vdeposito, vsdocuenta);
                        END FOREACH;
                    ELSE 
                        IF TRIM(vcodretDet) <> '002' THEN 
                            ROLLBACK WORK;
                            LET bInicia = "F";
                            LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
                            LET vcodret = '004';
                            RETURN vcodret, vErrorInfo;
                        END IF;
                    END IF;
                END FOREACH;
                
            END IF;
        
        ELSE 
        
            ROLLBACK WORK;
            LET bInicia = "F";
            LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
            LET vcodret = '003';            
            RETURN vcodret, vErrorInfo;
            
        END IF;
        
        COMMIT WORK;
        LET bInicia = "F";        
    END FOREACH;
    
    LET vcodret = '000';
    LET vErrorInfo = 'PROCESO EJECUTADO EXITOSAMENTE';
    
    END;
    
    RETURN vcodret, vErrorInfo;
    
END PROCEDURE;