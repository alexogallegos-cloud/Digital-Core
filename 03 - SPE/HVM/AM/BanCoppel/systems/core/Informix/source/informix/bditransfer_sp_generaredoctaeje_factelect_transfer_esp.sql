CREATE PROCEDURE "informix".sp_generaredoctaeje_factelect_transfer_esp(pEmpresa char(3))
RETURNING CHAR(5);
    
    DEFINE vcSql                    CHAR(600);
    DEFINE vcStmt                   CHAR(250);
    DEFINE vcodret                  CHAR(5);
    DEFINE vNum_Tarjeta             CHAR(16);
    DEFINE vdescripcion             CHAR(180);
    DEFINE vSucursal_nombre         CHAR(40);
    DEFINE vexiste_genedoctaeje     CHAR(3);
    DEFINE vcortSig                 CHAR(255);
    DEFINE vDireccion_del           CHAR(120);
    DEFINE vEdo_cd                  CHAR(120);
    DEFINE cErrorInfo               CHAR(80);
    DEFINE vErrorInfo               CHAR(80);
    DEFINE vaniomes                 CHAR(6);
    DEFINE vcodretDet               CHAR(6);
    DEFINE vcodretEnc               CHAR(6);
    DEFINE vmin_aniomes             CHAR(6);
    DEFINE vmax_aniomes             CHAR(6);
    DEFINE vmin_cta                 CHAR(20);
    DEFINE vmax_cta                 CHAR(20);
    DEFINE vMensajeProducto         CHAR(255);
    DEFINE vPiePagina               CHAR(255);
    DEFINE bInicia                  BOOLEAN;
    DEFINE iIsamErr                 SMALLINT;
    DEFINE vsdocuenta               MONEY(14,2);
    DEFINE vdeposito                MONEY(14,2);
    DEFINE vretiro                  MONEY(14,2);
    DEFINE vTasaBruta               DECIMAL(9, 6);
    DEFINE vGAT                     DECIMAL(9, 6);
    DEFINE vIvaOtrosCargos          DECIMAL(18,2);
    DEFINE vInteresesNetos          DECIMAL(18,2);
    DEFINE vInteresesPagados        DECIMAL(18,2);
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
    DEFINE vfechaFinal              DATE;
    DEFINE dFechaInicioMovimientos  DATE;
    DEFINE dFechaFinMovimientos     DATE;
    DEFINE dFechaEmision            DATE;
    DEFINE vsql                     CHAR(500);
    DEFINE vfecha                   CHAR(8);
    DEFINE vfechaproc               DATE;
	
    
	-- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
	DEFINE vestado 			CHAR(50);
	DEFINE vciudad 			VARCHAR(60);  
	DEFINE vtelefono 		CHAR(14);
	DEFINE vgerente 		CHAR(40);
	DEFINE cNumProducto		CHAR(4);
	DEFINE vmensaje			CHAR(255);
	DEFINE vfechafin 		DATE;
	DEFINE vcuenta  		CHAR(20);
	DEFINE vnumcte			CHAR(20);
	DEFINE vnumctetf		CHAR(20);
	DEFINE vnombre_completo CHAR(150);
	DEFINE vdireccion  		CHAR(200);
	DEFINE vzona	   		CHAR(120);
	DEFINE vnomsuc     		CHAR(40);
	DEFINE vrfc				CHAR(13);
	DEFINE vrfc_alterno		CHAR(13);
	DEFINE vcp				CHAR(5);
	DEFINE vclabe			CHAR(60);
	DEFINE vcurp			CHAR(60);
	DEFINE valta_cte		DATE;
	DEFINE vfechaini		DATE;
	DEFINE vsucursal		CHAR(4);
	DEFINE vsdoant			DECIMAL(18,2);
	DEFINE vtotdep			DECIMAL(18,2);
	DEFINE vtotret			DECIMAL(18,2);
	DEFINE vsdoact			DECIMAL(18,2);
	DEFINE vsdoprom			DECIMAL(18,2);
	DEFINE vdias 			SMALLINT;
	DEFINE cMensajeProducto CHAR(255);  
	DEFINE vedosuc 			CHAR(4);
	DEFINE vcdsuc 			VARCHAR(60); 
	DEFINE vtel 			CHAR(14);
	DEFINE vdescrip     	CHAR(180);
	DEFINE vmonto 		 	MONEY(14,2);
	DEFINE vmontoRet 	 	MONEY(14,2);
	DEFINE vmontodep 	 	MONEY(14,2);
	DEFINE vsdoactual 	 	MONEY(14,2);
	DEFINE vcuantos  		INTEGER;
	DEFINE vcuantos2  		INTEGER;  
	DEFINE vconreg 			smallint;
    DEFINE viva      	 	MONEY(14,2);
	DEFINE vcomisiones 	 	MONEY(14,2);
	DEFINE votrocargos		MONEY(14,2);
    DEFINE vretiefect       MONEY(14,2);
    DEFINE vcorreo          CHAR(100);
	DEFINE vEnvioMovtos     SMALLINT;
	
	
	
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
	DEFINE vfecha_ant_edo_cta       DATE;
	DEFINE vtpo_persona             CHAR(2); 
	DEFINE vNum_cte                 CHAR(20);
	DEFINE vres_iva_otros_cargos    DECIMAL(18,2);
	DEFINE ves_fisica               CHAR(1);
	DEFINE vexento_isr              CHAR(1); 
	DEFINE Vcodret_2                CHAR(5);
	
    LET vaniomes = "";                              
    LET vcodretDet = "";                        
    LET vcodretEnC = "";                          
    LET cErrorInfo ="";                          
    LET vErrorInfo = "INICIO DEL PROCESO";
    LET vcortSig2 = 0;                              
    LET vcortSig = "";                          
    LET vsecuencia = 0;
    LET vnlinea = 0;                                 
    LET vidreg = 0;                             
    LET vultejec = '';                   
    LET vsqlerr = 0;                            
    LET vdeposito = 0;
    LET vretiro = 0;                                
    LET vfechealt = "";                         
    LET vsdocuenta = 0;                                                 
    LET vcuenta = "";                                   
    LET vcodret = "00000";
    LET vfecha_hoy = "";                            
    LET vfecha_ant = "";                                                                                          
    LET bInicia = "F";                          
    LET iIsamErr = 0;
    LET vFecha_emision = "01-01-1900";                                    
    LET vNum_Tarjeta = "";
    LET vDireccion_del = "";                        
    LET vEdo_cd = "";                           
    LET vSucursal_nombre = "";                                       
    LET vrfc = "";
	LET vrfc_alterno ="";
    LET vCP = "";                                   
    LET vClabe = "";
    LET vCurp = "";                                                                                      
    LET vInteresesPagados = 0;                  
    LET vOtrosCargos = 0;                           
    LET vIvaOtrosCargos = 0;                                            
    LET vRetencionIsr = 0;    
    LET vTotRetirosEfec = 0;
    LET vTotOtrosCargos = 0;
    LET vInteresesNetos = 0;                                
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
    LET vMensajeProducto = '';
    LET vPiePagina = ""; 
    LET vsql = '';
    LET vfecha = '';
    LET vfechaproc = '';
	LET Vcodret_2 = ''; 
    
    -- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
	LET vestado 	 = "";
	LET vciudad 	 = "";
	LET vtel 		 = "";
	LET vgerente 	 = "";
	LET cNumProducto = "";
	LET vmensaje 	 = '';
	LET vdescrip     = "";     
	LET vmonto 		 = 0;
	LET vmontoRet 	 = 0;
	LET vmontodep 	 = 0;
	LET vsdoactual 	 = 0;
	LET vcdsuc		 = "";
	LET vcuantos	 = 0;
	LET vcuantos2	 = 0;
	LET vnumctetf 	 = "";
	LET vnumcte 	 = "";
	LET viva   		 = 0;
	LET vcomisiones	 = 0;
	LET votrocargos	 = 0;
	LET vretiefect	 = 0;
    LET vcorreo      = '';
	LET vEnvioMovtos = 0;
	
	
	
	---NUEVAS VARIABLES
	LET vConfirmacion =  " ";
	LET vValor_tasa   =  0;
	LET vBaseisr      =  0.0;
	LET vaniobase     =  365;
	LET v_descuento   =  0.00;
	LET v_Subtotal    =  0.00;
	LET v_Total	      =  0.00;
	

    BEGIN
    
    ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/sp_generaredoctaeje_factelect_transfer.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            LET vErrorInfo = cErrorInfo;
            IF bInicia = "T" THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
    
     ---SET DEBUG FILE TO "/resplogifx/conciliachq/TRANSFER.TXT";
     ---TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF pEmpresa IS NULL  THEN
        LET vcodret = '00001';
        RETURN vcodret;
    END IF; 
    
    -- // Obtener la fecha de ayer y hoy
    SELECT pri_dia_mes - 1 units day, fecha_hoy,fecha_ant
      INTO vfecha_ant, vfecha_hoy,vfecha_ant_edo_cta
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
	 
	 
      -- SE OBTIENE EL MONTO EXENTO
	  SELECT valor::INT
	    INTO vbase_exenta 
        FROM bdicheq:sc_param
       WHERE empresa = '001'
         AND codparam ='baseexenta';
	  

	  -- // CALCULA ANIOBASE
	  
	  LET vanio    = YEAR(vfecha_hoy);
      LET vresiduo =  MOD(vanio, 4);
	  
      IF vresiduo  = 0 THEN 
         LET vaniobase = 366;
      END IF;
	  

	   
	    --SE OBTIENE EL ANIO MES 		
	  LET v_secuencia  =  year(vfecha_ant_edo_cta)||lpad(month(vfecha_ant_edo_cta),2,"0");
	 

	 
	-- // Armar la fecha de emision
	LET dFechaEmision = vfecha_ant;
    
	--RETENCION ISR
	LET  vRetencionIsr  = 0;
	
		  -- // CARGA TABLA CON CUENTAS POR PROCESAR
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxprocesar_tranf') THEN
        DROP TABLE "informix".ctasxprocesar_tranf;
    END IF;
	
	CREATE TABLE "informix".ctasxprocesar_tranf( cuenta char(20) not null )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idxtmp_ctasxprocesar_cuenta_tr ON "informix".ctasxprocesar_tranf(cuenta) USING BTREE;
	
	    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentasxprocesar_tr.unl INSERT INTO ctasxprocesar_tranf" > /resplogifx/conciliachq/ctasxproc_tr.sql';
        SYSTEM vsql;
        LET vsql = '';
       
        LET vsql = '/ifxsif01/bin/dbaccess bditransfer /resplogifx/conciliachq/ctasxproc_tr.sql'; 
        SYSTEM vsql;
        LET vsql = '';
		

		FOREACH WITH HOLD 
			SELECT tf.periodo_fin, tf.cuenta, TRIM(NVL(TRIM(tf.nombre), "")||' '||NVL(TRIM(tf.ape_paterno), "")||' '||NVL(TRIM(tf.ape_materno), "")), 
                   TRIM(NVL(TRIM(tf.calle), "")||' '||NVL(TRIM(tf.no_ext), "")||' '||NVL(TRIM(tf.no_int), "")), tf.colonia, tf.municipio, tf.ent_federativa,
                   tf.cod_postal, tf.clabe , tf.curp, tf.fecha_apert, tf.periodo_ini, LPAD (TRIM(tf.sucursal),4,'0'), tf.saldo_ini, tf.abonos_sum,
                   tf.cargos_sum, tf.saldo_fin, tf.saldo_prom,  tf.diasperiodo,  (tf.sv_tici - tf.at_tisi) as iva,tf.monto_efectivo, tf.comisiones_sum, 
                   ( tf.cargos_sum - tf.monto_efectivo) as otrocargo, tf.email,mae.numcte
			  INTO vfechafin, vcuenta, vnombre_completo,
                   vdireccion, vzona, vciudad, vestado, 
                   vcp, vclabe, vcurp, valta_cte, vfechaini,  vsucursal, vsdoant, vtotdep, 
                   vtotret, vsdoact, vsdoprom, vdias, viva, vretiefect, vcomisiones, votrocargos, vcorreo, vNum_cte
			  FROM bditransfer:tf_resumen_edocta tf, 
                   bditransfer:tf_maecte mae 
			 WHERE tf.periodo_fin =  dFechaEmision
			   AND tf.integridad = 'V'
			   AND tf.cuenta = mae.cuenta_tf
			   AND tf.cuenta IN ( SELECT cuenta FROM ctasxprocesar_tranf )  
			   AND tf.cuenta NOT IN ( SELECT ee.num_cuenta
                                         FROM bdicheq:sc_encabezado_edocta_factelect ee
                                        WHERE ee.num_cuenta = tf.cuenta
                                          AND ee.fechafinal = tf.periodo_fin)
			  
			  
			
            SELECT rfc, numcte, numcte_tf         	
			  INTO vrfc, vnumcte, vnumctetf
			  FROM bditransfer:tf_maecte
			 WHERE cuenta_tf = vcuenta;
			
			IF vnumcte IS NOT null THEN
                SELECT rfc, rfc_alterno, envio_movtos
				  INTO  vrfc, vrfc_alterno, vEnvioMovtos
				  FROM bdinteg:si_cliente 
				 WHERE numcte = vnumcte;
							
				IF vrfc_alterno IS NOT null THEN
                    LET vrfc = vrfc_alterno;
				END IF
			END IF
			
			BEGIN WORK;
			LET bInicia = "T";
					
			LET vsucursal = '5001';
			
			SELECT nombre, estado,  ciudad, telefono1, gerente
			  INTO vnomsuc, vedosuc, vcdsuc , vtel, vgerente
			  FROM bdinteg:si_sucursales 
			 WHERE sucursal = vsucursal;
			
			SELECT nombre 
			  INTO vcdsuc
			  FROM bdinteg:si_ciudades 
			 WHERE estado = vedosuc  
			   AND ciudad = vcdsuc;   
			
			SELECT siglas 
			  INTO vedosuc
			  FROM bdinteg:si_estados 
			 WHERE estado = vedosuc;
			
			SELECT LIMIT 1 TRIM(producto) || ' ' || TRIM(nombre) AS producto
			  INTO vMensajeProducto
			  FROM bdicheq:sc_producto 
			 WHERE empresa = '001'
			   AND producto = '8000';
			  
			-- mensaje para sc_piepagina_edocta_factelect
			SELECT LIMIT 1 mensaje
			  INTO vPiePagina
			  FROM bdicheq:sc_mensajes_producto
			 WHERE producto = '8000'
			   and secuencia = '1';
			 
			-- se obtiene el numero de tarjeta
		   SELECT LIMIT 1 tar.num_tarjeta 
			  INTO vNum_Tarjeta
			  FROM bdicheq:sc_tarjeta tar
			 WHERE tar.cuenta = vcuenta
			   AND tar.status_tar = 'A'
			   AND tar.tipo_tarjeta = 'T';
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
			
			IF vEnvioMovtos = 1 THEN
				LET vcorreo = vcorreo;
            ELSE
                LET vcorreo = '';
            END IF;
			
			LET vcorreo = NVL(vcorreo,'');

			
			IF vRetencionIsr > 0 THEN
			
			   --OBTIENE LA TASA-ISR
                SELECT first 1 tasa_isr
                  INTO v_tasa_isr
                  FROM bdicheq:sc_isr 
                 WHERE cuenta    = vcuenta
                   AND secuencia = v_secuencia
                   AND tasa_isr > 0;
				   
				   
				   IF v_tasa_isr IS NULL  THEN 
			           LET v_tasa_isr = 0;
			       END IF;
                   
                --TASA ISR 			
                LET vValor_tasa = TRUNC(((v_tasa_isr / 100 ) *  vdias) / vaniobase,6 ); 
			
		
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
				      IF  vsdoprom > vbase_exenta THEN 
			              LET vBaseisr = vsdoprom - vbase_exenta;
					      LET vValor_tasa_isr = vValor_tasa;
				      ELSE
                          LET vBaseisr = 0;
                          LET vValor_tasa_isr = 0.0;
					  END IF;
                   ELSE
				   	  LET vBaseisr = vsdoprom;
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
			
				
			IF viva = 0 AND vRetencionIsr > 0 THEN 
			   LET v_descuento = 0.00;
			END IF;  
			
			
			IF vcomisiones = 0 AND viva = 0 AND vRetencionIsr = 0 THEN 
			   LET v_descuento = 0.01;
			END IF; 
			
			
			IF viva > 0 AND vRetencionIsr > 0 THEN  
			   LET v_descuento = 0.00;
			END IF; 
			
			
			IF viva > 0 AND vRetencionIsr =  0 THEN  
			   LET v_descuento = 0.00;
			END IF; 

			--DETERMINA EL TOTAL
			LET v_Subtotal =  ( vcomisiones + v_descuento + vRetencionIsr );
			--DETERMINA EL SUBTOTAL
			LET v_Total    =  ( vcomisiones + viva );
			
			--VALIDA EL VALOR DE LAS COMISIONES	
			LET vres_iva_otros_cargos = 0;
			LET vres_iva_otros_cargos = TRUNC((vcomisiones * .16 ),2);
			
			IF vres_iva_otros_cargos <> viva THEN 
			   LET vcomisiones = TRUNC((viva /.16),2); 
            ELSE 
               LET vcomisiones = vcomisiones;
            END IF; 
				
			IF trim(vcodret) = '00000' THEN 
                INSERT INTO bdicheq:sc_encabezado_edocta_factelect
				(idreg, fecha_emision, num_cuenta, num_cte, num_tarjeta, nombre_cte, direccion_cte, direccion_col, direccion_del, edo_cd, cve_ruta, 
				 sucursal_nombre, rfc, cp, cve_ahorro, clabe, curp, fechaalta, fechainicio, mensajeproducto, inserto, fechafinal, sucursal, ciudad_suc, siglas_edo_suc, telefono_suc, gerente_suc, correo,confirmacion )
				VALUES
				(vidreg, dFechaEmision, vcuenta, vnumctetf, nvl (vNum_Tarjeta,''), vnombre_completo, vdireccion, vzona,vciudad, vestado, ' ', 
				 vnomsuc, vrfc, vcp, ' ', vclabe, vcurp, valta_cte,  vfechaini, vMensajeProducto, '000000000000000', vfechafin, vsucursal, vcdsuc, vedosuc, vtel, vgerente, vcorreo, vConfirmacion);
					
				 INSERT INTO bdicheq:sc_encabezado2_edocta_factelect
				 (idreg, fecha_emision, num_cuenta, saldoanterior, depositos, interesespagados, retiros, 
				  otroscargos, ivaotroscargos, saldocorte, saldopromedio, retencionisr, interesesnetos, dias,tasabruta, baseisr,tasaisr,descuento,subtotal,total)
				VALUES
				(vidreg, dFechaEmision, vcuenta, vsdoant, vtotdep, '0', vtotret,
				vcomisiones, viva, vsdoact, vsdoprom,vRetencionIsr, '0', vdias, '0',vBaseisr, vValor_tasa_isr,v_descuento,v_Subtotal,v_Total);

				LET vsecuencia = 1;
				LET vnlinea = 1;
					
				INSERT INTO bdicheq:sc_piepagina_edocta_factelect 
				(idreg, fecha_emision, num_cuenta, secuencia, nlinea, mensaje)
				VALUES
				(vidreg, dFechaEmision, vcuenta, vsecuencia, vnlinea, vPiePagina);
					
				FOREACH WITH HOLD -- PARA INSERTAR LAS TABLAS
					SELECT nlinea, mensaje, secuencia
					  INTO vnlinea, vmensaje, vsecuencia
					  FROM bdicheq:sc_mensajes_producto
					 WHERE producto = '8000'
					   AND secuencia IN('2','3','4','5','6','7','8')
							
                    IF   vsecuencia = 2 THEN LET vsecuencia = 1;
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
				END FOREACH 
					
				INSERT INTO bdicheq:sc_grafica_fe
				(id_reg, fecha_emision, num_cuenta, saldo_inicial, saldo_final, retiros_efectivo, depositos, intereses, comisiones, comisiones_iva, otros_cargos, gat)
				VALUES
				(vidreg, dFechaEmision, vcuenta, vsdoant, vsdoact, vretiefect, vtotdep, '0', vcomisiones, viva, votrocargos, '0');
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
				SELECT TRIM(NVL(TRIM(desc_mov1), "")||' '||NVL(TRIM(desc_mov2), "")||' '||NVL(TRIM(desc_mov3), "")), monto, fecha_mov    
				  INTO vdescrip, vmonto, vfechealt
				  FROM bditransfer:tf_detalle_edocta  
				 WHERE cuenta = vcuenta
				   AND periodo_fin = vfechafin
				 ORDER BY fecha_mov DESC, orden_mov::INTEGER DESC
					
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
	
	
    END;
    
END PROCEDURE;