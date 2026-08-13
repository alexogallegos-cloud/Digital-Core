CREATE PROCEDURE "informix".sp_rptmedinv(pempresa CHAR(3))
RETURNING CHAR(5);

	DEFINE vcodret1         	CHAR(5);
    DEFINE vcodret2         	CHAR(5);
    DEFINE vcodret3         	CHAR(50);
    DEFINE sql_err          	INTEGER;
    DEFINE isam_err         	INTEGER;
    DEFINE desc_err         	CHAR(50);
    DEFINE vcontador        	INTEGER;
    DEFINE ven_transacc     	SMALLINT; 
	DEFINE vsql             	CHAR(500);
    DEFINE vstmt            	CHAR(200);
	DEFINE vfecha		    	DATE;
	
	/*VARIABLES DE REPORTE APEDIAINV */
	
    --Fecha_hoy--
	DEFINE vfecha_hoy			DATE;
   --Moneda--
    DEFINE vmoneda 				CHAR(2);
	--Desc. Moneda--
    DEFINE vdesc_moneda 		CHAR(35);
    --Regional--
    DEFINE vregional			CHAR(45);
    --Plaza--
	DEFINE vplaza 				CHAR(45);
     --Sucursal --
	DEFINE vsucursal 			CHAR(4);	
	--Nom. Sucursal --
	DEFINE vnom_sucursal 		CHAR(120);
	--Inversion
	DEFINE vinversion 			CHAR(15); 
    --Concepto --
	DEFINE vconcepto			CHAR(15);
    --Secuencia --
	DEFINE vsecuencia			CHAR(12); 
    --Promotor
	DEFINE vpromotor			CHAR(10);
    --Cliente --
	DEFINE vcliente		  		CHAR(20); 
	--Nombre Cliente --
	DEFINE vnom_cliente  		CHAR(140); 	
    --Plazo
	DEFINE vplazo    			INTEGER;
    --Fecha Vencimiento
	DEFINE vfec_venc 			DATE;  
    --Capital
	DEFINE vcapital 			MONEY(18,2);
    --Tasa
	DEFINE vtasa	 			CHAR(20);
    --Sobretasa
	DEFINE vsob_tasa 			CHAR(20);  
    --Instruccion Capital --
	DEFINE vinst_cap 			CHAR(20);
    --Instruccion Interes --
	DEFINE vinst_interes 		CHAR(20);
	--Instrumento de Inversion --
	DEFINE vcod_inst_inversion 	CHAR(5);
    --Instrumento de Inversion --
    DEFINE vinst_inversion 		CHAR(15);
	
	/*VARIABLES DE REPORTE MOVCONTINV */
	
    DEFINE vproducto 			CHAR(5);
	 --Transaccion
	DEFINE  vtransaccion 		CHAR(40);
	 --Importe
	DEFINE  vimporte 			MONEY(18,2);
	 --Contabiliza
	DEFINE  vcontabiliza 		CHAR(2);
	--Cuenta Debito
	DEFINE  vcuenta_deb			CHAR(20);
	--Cuenta Credito
	DEFINE  vcuenta_cre			CHAR(20);
	--Secuencia
	DEFINE psecuencia			INTEGER;
	--Cuenta
	DEFINE  pcuenta				CHAR(20);
	
	
	/*VARIABLES DE REPORTE movhisINV */
	--Cuenta Credito
    DEFINE vfolio_tran 			CHAR(4);
	--Moneda concatenada
	DEFINE vmoneda_conc			CHAR(45);
	--Numero Serial 
	DEFINE pserial				INTEGER;
	--Transaccion 
	DEFINE ptransacc			CHAR(5);
	
	/*VARIABLES DE REPORTE MOVREVINV */
	--Sucursal Concatenada
	DEFINE vsucursal_conc		CHAR(125);
	
	/*VARIABLES DE REPORTE SDODIAINV */
	--Cuenta Credito
	DEFINE  vnum_certificado	CHAR(20);
	DEFINE  vinteres			MONEY(18,2);
	DEFINE  vretencion			MONEY(18,2);
	DEFINE  vinteres_nto		MONEY(18,2);
	DEFINE  vpago_intereses		MONEY(18,2);
	DEFINE  vinteres_pagar		MONEY(18,2);
	DEFINE  vfec_ult_pago		DATE;
	DEFINE  vfec_apertura		DATE;
	DEFINE  vfec_vencimiento	DATE;
	
     

    LET  vcodret1         		= '000';
    LET  vcodret2         		= '000';
    LET  vcodret3         		= '';
    LET  sql_err	       		= 0 ;
    LET  isam_err         		= 0 ;
    LET  desc_err         		= '';
    LET  vcontador        		= 0 ;
    LET  ven_transacc     		= 0 ;
	LET  vsql             		= '';
    LET  vstmt            		= '';
	
	/*VARIABLES DE REPORTE APEDIAINV */
	LET  vfecha_hoy  	 		= '';
    LET  vmoneda 		 		= '';
	LET  vdesc_moneda			= '';
    LET  vregional 		 		= '';
	LET  vplaza 		 		= '';
	LET  vsucursal 		 		= '';
	LET  vnom_sucursal 			= '';
	LET  vinversion 	 		= '';
	LET  vconcepto 		 		= '';
	LET  vsecuencia 	 		= '';
	LET  vpromotor 		 		= '';
	LET  vcliente  		 		= '';
	LET  vnom_cliente	 		= '';
	LET  vplazo    		 		= 0 ;
	LET  vfec_venc 		 		= '';
	LET  vcapital 		 		= 0.00;
	LET  vtasa  		 		= '';
	LET  vsob_tasa 		 		= '';  
	LET  vinst_cap 		 		= '';
	LET  vinst_interes 	 		= '';
	LET  vcod_inst_inversion 	= '';
    LET  vinst_inversion 		= '';
	
	/*VARIABLES DE REPORTE MOVCONTINV */
	LET vproducto 				= '';
	LET  vtransaccion 			= '';
	LET  vimporte 				= 0.00;
	LET  vcontabiliza 			= '';
	LET  vcuenta_deb			= '';
	LET  vcuenta_cre			= '';
	LET  psecuencia				= 0 ;
	LET  pcuenta				= '';
	LET  ptransacc				= 0 ;
  
  /*VARIABLES DE REPORTE movhisINV */
	LET  vfolio_tran			= '';
	LET  vmoneda_conc			= '';
	LET  pserial				= 0 ;
	
	/*VARIABLES DE REPORTE MOVREVINV */
	
	LET vsucursal_conc			= '';
	
	/*VARIABLES DE REPORTE SDODIAINV */
	
	LET vnum_certificado		= '';
	LET vinteres				= 0.00;
	LET vretencion				= 0.00;
	LET vinteres_nto			= 0.00;
	LET vinteres_pagar			= 0.00;
	LET vfec_ult_pago			= '';
	LET vfec_apertura			= '';
	LET vfec_vencimiento		= '';
	
    
    BEGIN

     ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_rptmedinv.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;
        END IF;
     END EXCEPTION;
    
    -- SET DEBUG FILE TO "/informix/resplogifx/conciliachq/sp_rptmedinv.out";
     --TRACE ON;
	 
	 SELECT fecha_hoy
     INTO vfecha
     FROM sv_fechas
     WHERE empresa = pempresa;
	 

     SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
    
     IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'apediainv') THEN
        DROP TABLE bdinvers:"informix".apediainv; 
     END IF;
    
		CREATE TABLE bdinvers:"informix".apediainv(
	  
		  --Sucursal --
		  sucursal 				CHAR(120),
		  --Inversion
		  inversion 			CHAR(15), 
		  --Concepto --
		  concepto 				CHAR(15),
		  --Secuencia --
		  secuencia 			CHAR(12), 
		  --Promotor
		  promotor 				CHAR(10),
		  --Cliente --
		  cliente  				CHAR(20),
		  --Nombre Cliente --
		  nom_cliente  			CHAR(140),  	 
		  --Plazo
		  plazo    				INTEGER,
		  --Fecha Vencimiento
		  fec_venc 				CHAR(10),  
		  --Capital
		  capital 				MONEY(18,2),
		  --Tasa
		  tasa 					CHAR(18),
		  --Sobretasa
		  sob_tasa 				CHAR(18),  
		  --Instruccion Capital --
		  inst_cap 				CHAR(20),
		  --Instruccion Interes --
		  inst_interes 			CHAR(20))
		  --Cod. Instrumento de Inversion --
		  --cod_inst_inversion 	CHAR(5),
		  --Instrumento de Inversion --
		 -- inst_inversion 		CHAR(15))
	 
     EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
    
    
     FOREACH 
        
		SELECT

		--Sucursal --
		sv_maeinv.sucursal,
		--Inversion
		sv_maeinv.cuenta inversion, 
		--Concepto --
		sv_maeinv.secuencia||' '||TRIM(( CASE sv_maeinv.secuencia WHEN 1 THEN "Apertura" ELSE "Reinversion" END)) concepto,
		--Secuencia --
		sv_maeinv.secuencia,
		--Promotor
		sv_maeinv.promotor, 
		--Cliente --
		si_cliente.numcte cliente,
		--Nombre Cliente --
		TRIM(si_cliente.apell_paterno)||' '||TRIM(si_cliente.apell_materno)||' '||TRIM(si_cliente.nombre1)||' '||TRIM(si_cliente.nombre2) nombre_cliente,
		--Plazo
		sv_maeinv.plazo plazo, 
		--Fecha Vencimiento
		sv_maeinv.fecha_venc vence, 
		--Capital
		sv_maeinv.capital capital,
		--Tasa
		sv_maeinv.tasa tasa,
		--Sobretasa
		sv_maeinv.sobretasa sobretasa,   
		--Instruccion Capital --
		TRIM(sv_maeinstruccap.inst_vento)||' '||
		TRIM((CASE sv_maeinstruccap.inst_vento
		  WHEN '01' THEN 'Reinversion'
		  WHEN '02' THEN sv_maeinstruccap.cta_cheques 
		  WHEN '03' THEN 'Cheque de Caja'
		  ELSE ''  END))Instruccion_Capital,
		 --Instruccion Interes --
		 TRIM(sv_maeinstruccap.inst_vento)||' '||
		 TRIM((CASE sv_maeinstruccap.inst_vento
		  WHEN '01' THEN 'Reinversion'
		  WHEN '02' THEN sv_maeinstruccap.cta_cheques 
		  WHEN '03' THEN 'Cheque de Caja'
		  ELSE ''  END))Instruccion_Interes		
		
		  INTO             		         	
		  vsucursal,vinversion, vconcepto, vsecuencia, 	 		
		  vpromotor,vcliente ,vnom_cliente,vplazo,vfec_venc,vcapital,vtasa,vsob_tasa,vinst_cap,vinst_interes 		
			  
		FROM     "informix".sv_maeinv sv_maeinv         

		INNER JOIN bdinteg:"informix".si_cliente si_cliente   ON  sv_maeinv.num_cte = si_cliente.numcte   		   AND  sv_maeinv.status_cta = "1"        
		INNER JOIN "informix".sv_maeinstrucc sv_maeinstruccap ON sv_maeinv.cuenta = sv_maeinstruccap.cuenta AND sv_maeinv.empresa = sv_maeinstruccap.empresa 
													  AND sv_maeinstruccap.cap_int  = "C"
		WHERE sv_maeinv.fecha_alta = vfecha
        
		INSERT INTO "informix".apediainv VALUES 
		( vsucursal, vinversion, vconcepto, vsecuencia, vpromotor, vcliente ,vnom_cliente, vplazo, to_char(vfec_venc,'%d/%m/%Y'), vcapital, vtasa, vsob_tasa, vinst_cap, vinst_interes );
						
     END FOREACH;
    
     CREATE INDEX "informix".idx_apediainv ON bdinvers:"informix".apediainv(inversion) USING BTREE;
     UPDATE STATISTICS MEDIUM FOR TABLE apediainv;
    
     LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/apediainv'||TO_CHAR(vfecha,'%m%d%y')||'.txt '||
                'select * from apediainv order by sucursal, inversion;" > /resplogifx/conciliachq/apediainvtmp.sql';
     SYSTEM vsql;
     LET vsql = '';
    
     LET vstmt = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/apediainvtmp.sql"; 
     SYSTEM vstmt;
     LET vstmt = '';
	

	 -- REPORTE MOVCONTINV     
	
	
	 IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movcontinv') THEN
        DROP TABLE bdinvers:"informix".movcontinv; 
     END IF;
    
     CREATE TABLE bdinvers:"informix".movcontinv(
	  
		 --Moneda--
		 moneda 			CHAR(2),
		 --Desc. Moneda--
		 desc_moneda 		CHAR(35),
		 --Fecha_hoy--
		 fecha_hoy 			CHAR(10),
		 --Producto --
		 producto 			CHAR(5),
		 --Transaccion
		 transaccion 		CHAR(40),
		 --Importe
		 importe 			MONEY(18,2),
		 --Contabiliza
		 contabiliza 		CHAR(2),
		 --Cuenta Debito
		 cuenta_deb			CHAR(20),
		 --Cuenta Credito
		 cuenta_cre			CHAR(20))
	 
     EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
 
     FOREACH 
        
		SELECT    sv_movhis.cod_instrum, sv_maeinv.plaza, sv_maeinv.plazo,sv_movhis.cuenta, sv_movhis.transacc, sv_movhis.num_serial
		INTO      vproducto,			vplaza,			vplazo , pcuenta, ptransacc, pserial		
		FROM	  sv_movhis sv_movhis                        
                         INNER JOIN sv_maeinv sv_maeinv ON sv_maeinv.empresa = sv_movhis.empresa 
                                                       AND sv_maeinv.cuenta = sv_movhis.cuenta
                                                       AND sv_maeinv.secuencia = sv_movhis.secuencia
		WHERE     sv_movhis.fech_alt = vfecha
		  AND     sv_movhis.cancelad <> 'S'
		
        SELECT secuencia INTO psecuencia
			FROM  sv_plazotasa
			WHERE cod_instrum = vproducto
			  AND plaza = vplaza
			  AND vplazo BETWEEN plazo_min AND plazo_max;
		
		SELECT    
			--Moneda
			sv_instrum.moneda,
			--Desc. Moneda
			si_divisas.descripcion desc_moneda,
			--Fecha
			vfecha,
			--Producto
			sv_movhis.cod_instrum producto ,  
			--Transaccion
			TRIM(sv_movhis.transacc)||' '||TRIM(si_transacc.descripcion) transaccion, 
			--Importe
			sv_movhis.monto_tot importe,
			--Contabiliza
			si_transacc.se_contabiliza contabiliza,
			-- Cuenta Débito
		   Trim (si_prodtran.a_ccmayor)||'-'|| Trim (si_prodtran.a_ccsub)||'-'|| Trim (si_prodtran.a_ccsubsub) ||'-'|| Trim (si_prodtran.a_ccsssub) ||'-'|| Trim (si_prodtran.a_ccssssub)||'-'||  Trim (si_prodtran.a_sector) cuenta_debito,
		   -- Cuenta Crédito
		   Trim (si_prodtran.c_ccmayor)||'-'||Trim (si_prodtran.c_ccsub)||'-'|| Trim (si_prodtran.c_ccsubsub)||'-'|| Trim (si_prodtran.c_ccsssub)||'-'||Trim (si_prodtran.c_ccssssub) ||'-'|| Trim (si_prodtran.c_sector) cuenta_credito
		   
		   INTO             		         	
				vmoneda,vdesc_moneda,vfecha_hoy, vproducto,vtransaccion,vimporte,vcontabiliza,vcuenta_deb,vcuenta_cre		
			  
		   
		FROM
			(((("informix".sv_movhis sv_movhis INNER JOIN "informix".sv_instrum sv_instrum ON sv_movhis.empresa = sv_instrum.empresa 
																   AND sv_movhis.cod_instrum = sv_instrum.cod_instrum)
																   					
													
		INNER JOIN bdinteg:"informix".si_transacc si_transacc ON sv_movhis.empresa = si_transacc.empresa
														     AND si_transacc.numero = ptransacc
															 AND si_transacc.sistema ='03'
														     AND si_transacc.se_contabiliza = 'S')
															 
		INNER JOIN bdinteg:"informix".si_divisas si_divisas   ON sv_instrum.moneda = si_divisas.divisa 
																   AND sv_instrum.empresa = si_divisas.empresa)       
		  
		INNER JOIN bdinteg:"informix".si_prodtran si_prodtran ON si_transacc.empresa = si_prodtran.empresa 
												  AND si_transacc.numero = si_prodtran.transaccion												  
												  AND si_prodtran.producto= sv_movhis.cod_instrum
												  AND si_prodtran.secuencia = psecuencia
												  AND si_prodtran.sistema ='03')
		WHERE sv_movhis.num_serial = pserial;
												  
		IF vmoneda IS NOT NULL THEN
			INSERT INTO "informix".movcontinv VALUES 
			(vmoneda,vdesc_moneda,to_char(vfecha_hoy,'%d/%m/%Y'), vproducto,vtransaccion,vimporte,vcontabiliza,vcuenta_deb,vcuenta_cre);
		END IF;	
		
     END FOREACH;
    
     CREATE INDEX "informix".idx_movcontinv ON bdinvers:"informix".movcontinv(producto) USING BTREE;
     UPDATE STATISTICS MEDIUM FOR TABLE movcontinv;
	 
    
     LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/movcontinv'||TO_CHAR(vfecha,'%m%d%y')||'.txt '||
                'select * from movcontinv order by moneda, producto,transaccion;" > /resplogifx/conciliachq/movcontinvtmp.sql';
     SYSTEM vsql;
     LET vsql = '';
    
     LET vstmt = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/movcontinvtmp.sql"; 
     SYSTEM vstmt;
     LET vstmt = '';
	
	 -- REPORTE movhisINV     
		
	 IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movhisinv') THEN
        DROP TABLE bdinvers:"informix".movhisinv; 
     END IF;
    
     CREATE TABLE bdinvers:"informix".movhisinv(
	 
		 --Fecha_hoy--
		 fecha_hoy	 			CHAR(10), 
		 --Moneda--
		 moneda 				CHAR(50),	
		 --Regional--
		 regional 				CHAR(45),
		 --Plaza--
		 plaza 					CHAR(45),
		 --Sucursal --
		 sucursal 				CHAR(4),
		 --Nom. Sucursal --
		 nom_sucursal 			CHAR(120),
		 --Inversion
		 inversion 				CHAR(15),
		 --Folio Trans.
		 folio_tran				CHAR(5),
		 --Transaccion
		 transaccion			CHAR(45),
		 --Importe
		 importe				MONEY(18,2))
	 
     EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
    
    
     FOREACH 
	 SELECT    sv_movhis.cod_instrum, sv_maeinv.plaza, sv_maeinv.plazo,sv_movhis.cuenta, sv_movhis.transacc, sv_movhis.num_serial --pserial
		INTO      vproducto,			vplaza,			vplazo , pcuenta, ptransacc, pserial
		
		FROM	  sv_movhis sv_movhis 
						 INNER JOIN sv_instrum sv_instrum ON sv_movhis.empresa = sv_instrum.empresa 
													   AND sv_movhis.cod_instrum = sv_instrum.cod_instrum                                
                         INNER JOIN sv_maeinv sv_maeinv ON sv_maeinv.empresa = sv_movhis.empresa 
                                                       AND sv_maeinv.cuenta = sv_movhis.cuenta
                                                       AND sv_maeinv.secuencia = sv_movhis.secuencia
		WHERE     sv_movhis.fech_alt = vfecha
		  AND     sv_movhis.cancelad <> 'S'
			
		SELECT secuencia INTO psecuencia
			FROM  sv_plazotasa
			WHERE cod_instrum = vproducto
			  AND plaza = vplaza
			  AND vplazo BETWEEN plazo_min AND plazo_max;
													   
	 SELECT 
     --Fecha
     vfecha fecha,
     --Moneda
     TRIM(sv_instrum.moneda)||' '||TRIM(si_divisas.descripcion) moneda, 
     --Regional--
     TRIM(si_plazas.regional)||' '|| TRIM(si_regional.nombre) regional,
     --Plaza--
	 TRIM(sv_maeinv.plaza)||' '||TRIM(si_plazas.nombre) plaza ,
     --Sucursal --
     sv_maeinv.sucursal,
	 --Nombre Sucursal --
	 si_sucursales.nombre sucursal_nom, 
     --Inversion
     sv_maeinv.cuenta inversion,  
     --Folio Transaccion
     sv_movhis.transacc Folio,
     --Descripcion Transaccion
     si_transacc.descripcion transaccion,
     --Importe
     sv_movhis.monto_tot importe
 
     INTO vfecha_hoy,vmoneda_conc,vregional,vplaza,vsucursal,vnom_sucursal,vinversion,vfolio_tran,vtransaccion,vimporte
   
	 FROM
     (((((((
	 "informix".sv_movhis sv_movhis INNER JOIN bdinteg:"informix".si_sucursales si_sucursales ON sv_movhis.empresa = si_sucursales.empresa 
																	  AND sv_movhis.sucursal = si_sucursales.sucursal)       
																	  
	 INNER JOIN bdinteg:"informix".si_transacc si_transacc ON sv_movhis.empresa = si_transacc.empresa 
														  AND si_transacc.numero = ptransacc   --ptransacc
														  AND si_transacc.sistema = '03')       
											  
	 INNER JOIN "informix".sv_instrum sv_instrum ON sv_movhis.cod_instrum = sv_instrum.cod_instrum 
												AND sv_movhis.empresa = sv_instrum.empresa
												AND sv_movhis.cuenta = pcuenta)
																												   
	 INNER JOIN "informix".sv_maeinv sv_maeinv ON sv_movhis.cuenta = sv_maeinv.cuenta 
								  AND sv_movhis.empresa = sv_maeinv.empresa
								  AND sv_movhis.secuencia = sv_maeinv.secuencia)     -- secuencia
								  
     INNER JOIN bdinteg:"informix".si_plazas si_plazas ON si_sucursales.empresa = si_plazas.empresa 
										  AND si_sucursales.plaza = si_plazas.plaza)       
										  
	 INNER JOIN bdinteg:"informix".si_divisas si_divisas ON sv_instrum.moneda = si_divisas.divisa 
											AND sv_instrum.empresa = si_divisas.empresa)       
											
	 INNER JOIN bdinteg:"informix".si_regional si_regional ON si_plazas.regional = si_regional.regional)
	 WHERE sv_movhis.num_serial = pserial;
	
	 INSERT INTO "informix".movhisinv VALUES 
     (to_char(vfecha_hoy,'%d/%m/%Y'),vmoneda_conc,vregional,vplaza,vsucursal,vnom_sucursal,vinversion,vfolio_tran,vtransaccion,vimporte);
						
     END FOREACH;
    
     CREATE INDEX "informix".idx_movhisinv ON bdinvers:"informix".movhisinv(inversion) USING BTREE;
     UPDATE STATISTICS MEDIUM FOR TABLE movhisinv;
    
     LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/movhisinv'||TO_CHAR(vfecha,'%m%d%y')||'.txt '||
               ' select * from movhisinv order by folio_tran,transaccion,importe;" > /resplogifx/conciliachq/movhisinvtmp.sql';
     SYSTEM vsql;
     LET vsql = '';
    
     LET vstmt = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/movhisinvtmp.sql"; 
     SYSTEM vstmt;
     LET vstmt = '';
	
	
	 -- REPORTE MOVREVINV      
	
	
	 IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'movrevinv') THEN
        DROP TABLE bdinvers:"informix".movrevinv; 
     END IF;
    
     CREATE TABLE bdinvers:"informix".movrevinv(
		 
		 --Fecha_hoy--
		 fecha_hoy	 			CHAR(10), 
		 --Moneda--
		 moneda 				CHAR(50),	
		 --Regional--
		 regional 				CHAR(45),
		 --Plaza--
		 plaza 					CHAR(45),
		 --Sucursal --
		 sucursal 				CHAR(125),
		 --Inversion
		 inversion 				CHAR(15),
		 --Folio Trans.
		 folio_tran				CHAR(5),
		 --Transaccion
		 transaccion			CHAR(45),
		 --Importe
		 importe				MONEY(18,2))
	 
     EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
    
    
     FOREACH
        
	 SELECT 
	 --Fecha
     vfecha fecha,
     --Moneda
     TRIM(sv_instrum.moneda)||' '||TRIM(si_divisas.descripcion) moneda, 
	 --Regional--
     TRIM(si_plazas.regional)||' '|| TRIM(si_regional.nombre) regional,
     --Plaza--
	 TRIM(sv_maeinv.plaza)||' '||TRIM(si_plazas.nombre) plaza ,
     --Sucursal --
     TRIM(sv_maeinv.sucursal)||' '||TRIM(si_sucursales.nombre) sucursal,     
     --Inversion
     sv_maeinv.cuenta inversion,  
     --Folio Transaccion
     sv_movhis.transacc Folio,
     --Descripcion Transaccion
     si_transacc.descripcion transaccion,
     --Importe
     sv_movhis.monto_tot importe
	
	 INTO 
	 vfecha_hoy,vmoneda_conc,vregional,vplaza,vsucursal_conc,vinversion,vfolio_tran,vtransaccion,vimporte


	 FROM
     (((((((
		"informix".sv_movhis sv_movhis INNER JOIN bdinteg:"informix".si_sucursales si_sucursales ON sv_movhis.empresa = si_sucursales.empresa 
																		  AND sv_movhis.sucursal = si_sucursales.sucursal)      
		
		INNER JOIN bdinteg:"informix".si_transacc si_transacc ON sv_movhis.empresa = si_transacc.empresa 
												  AND sv_movhis.transacc = si_transacc.numero
												  AND si_transacc.sistema = '03')       
		
		INNER JOIN "informix".sv_instrum sv_instrum ON sv_movhis.cod_instrum = sv_instrum.cod_instrum 
										AND sv_movhis.empresa = sv_instrum.empresa)             
	 
		INNER JOIN "informix".sv_maeinv sv_maeinv ON sv_movhis.cuenta = sv_maeinv.cuenta 
									  AND sv_movhis.empresa = sv_maeinv.empresa)       
		
		INNER JOIN bdinteg:"informix".si_plazas si_plazas ON si_sucursales.empresa = si_plazas.empresa 
											  AND si_sucursales.plaza = si_plazas.plaza)       
		
		INNER JOIN bdinteg:"informix".si_divisas si_divisas ON sv_instrum.moneda = si_divisas.divisa 
												AND sv_instrum.empresa = si_divisas.empresa)       
		
		INNER JOIN bdinteg:"informix".si_regional si_regional ON si_plazas.empresa = si_regional.empresa 
												  AND si_plazas.regional = si_regional.regional  )
												  
	 WHERE sv_movhis.fech_alt = vfecha
	   AND sv_movhis.cancelad = 'S'
		
		INSERT INTO "informix".movrevinv VALUES 
		(to_char(vfecha_hoy,'%d/%m/%Y'),vmoneda_conc,vregional,vplaza,vsucursal_conc,vinversion,vfolio_tran,vtransaccion,vimporte);
		
     END FOREACH;
    
    CREATE INDEX "informix".idx_movrevinv ON bdinvers:"informix".movrevinv(transaccion) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE movrevinv;
    
    
    LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/movrevinv'||TO_CHAR(vfecha,'%m%d%y')||'.txt '||
               ' select * from movrevinv order by folio_tran,transaccion,importe;" > /resplogifx/conciliachq/movrevinvtmp.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/movrevinvtmp.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
	
	
	-- REPORTE SDODIAINV       
	
	 IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'sdodiainv') THEN
        DROP TABLE bdinvers:"informix".sdodiainv; 
     END IF;
    
     CREATE TABLE bdinvers:"informix".sdodiainv(
		 
		 --Fecha_hoy--
		 --fecha_hoy	 			CHAR(10), 
		 --Sucursal --
		 sucursal 				CHAR(15),
		 --Producto
		 producto 				CHAR(15),
		 --Num de Certificado
		 num_certificado		CHAR(25),
		 --Secuencia --		
		 secuencia				CHAR(12),
		 --Cliente --
		 cliente  				CHAR(20),
		 --Nombre Cliente --
		 nom_cliente  			CHAR(140), 
		 --Principal
		 principal				MONEY(18,2),
		 --Interes
		 interes				MONEY(18,2),
		 --Retencion
		 retencion				MONEY(18,2),
		 --Interes Neto
		 interes_nto			MONEY(18,2),
		 --Pago Intereses
		 pago_interes			MONEY(18,2),
		 --Fecha Ultimo Pago
		 fec_ult_pago			CHAR(10),
		 --Interes por Pagar
		 int_por_pag			MONEY(18,2),
		 --Fecha Apertura		
		 fec_apertura			CHAR(10),
		 --Plazo
		 plazo					INTEGER,
		 --Tasa
		 tasa					CHAR(18),
		 --Fecha Vencimiento
		 fec_vencimiento		CHAR(10))
	 
    EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
    
    
    FOREACH 
	
	 SELECT    sv_maeinv.cuenta
		INTO     pcuenta 		

		FROM	  sv_maeinv sv_maeinv 
					
		WHERE sv_maeinv.status_cta not in('2', '4')
        
	 SELECT
     --Sucursal --
     sv_maeinv.sucursal sucursal,
     --Producto 
     sv_maeinv.cod_instrum Producto,
     --Num de Certificado
     sv_maeinv.cuenta numero_de_Certificado,
     --Secuencia --
     sv_maeinv.secuencia,
     --Cliente --
     si_cliente.numcte cliente,
     --Nombre Cliente --
     TRIM(si_cliente.apell_paterno)||' '||TRIM(si_cliente.apell_materno)||' '||TRIM(si_cliente.nombre1)||' '||TRIM(si_cliente.nombre2) nombre_cliente,
     --Principal
     sv_maeinv.capital principal, 
     --Interes
     sv_maeinv.intereses interes,
     --Retencion
     sv_maeinv.isr retencion,
     --Interes Neto
     (sv_maeinv.intereses - sv_maeinv.isr) interes_neto,
     --Pago Intereses
     sv_maeinv.per_acred_int pago_interes,
     --Fecha Ultimo Pago
     sv_maeinv.fec_ult_mov, 
     --Interes por Pagar
     sv_maeinstrucc.importe interes_por_pagar,    
     --Fecha Apertura
     sv_maeinv.fecha_alta fecha_apertura,
     --Plazo
     sv_maeinv.plazo,
     --Tasa
     (sv_maeinv.tasa + sv_maeinv.sobretasa) tasa, 
     --Fecha Vencimiento
     sv_maeinv.fecha_venc
     
	 INTO vsucursal,vcod_inst_inversion,vnum_certificado,vsecuencia,vcliente,vnom_cliente,
		  vcapital,vinteres,vretencion,vinteres_nto,vpago_intereses,vfec_ult_pago,vinteres_pagar,vfec_apertura,vplazo,vtasa,vfec_vencimiento
		  

	 FROM
 
	 "informix".sv_maeinv sv_maeinv INNER JOIN bdinteg:"informix".si_sucursales si_sucursales ON sv_maeinv.empresa = si_sucursales.empresa 
																						     AND sv_maeinv.sucursal = si_sucursales.sucursal
	
 	 INNER JOIN bdinteg:"informix".si_cliente si_cliente ON sv_maeinv.num_cte = si_cliente.numcte
	
	 INNER JOIN "informix".sv_maeinstrucc sv_maeinstrucc ON sv_maeinv.cuenta = sv_maeinstrucc.cuenta 
													    AND sv_maeinv.empresa = sv_maeinstrucc.empresa
														       	
	 WHERE
     sv_maeinstrucc.cap_int = 'I' AND
     sv_maeinv.status_cta IN ('1','3') AND
	 sv_maeinv.cuenta = pcuenta;
    
	INSERT INTO "informix".sdodiainv VALUES 
	( vsucursal,vcod_inst_inversion,vnum_certificado,vsecuencia,vcliente,vnom_cliente,vcapital,vinteres,vretencion,
	  vinteres_nto,vpago_intereses,to_char(vfec_ult_pago,'%d/%m/%Y'),vinteres_pagar,to_char(vfec_apertura,'%d/%m/%Y'),vplazo,vtasa,to_char(vfec_vencimiento,'%d/%m/%Y'));
			
     END FOREACH;
    
     CREATE INDEX "informix".idx_sdodiainv ON bdinvers:"informix".sdodiainv(producto) USING BTREE;
     UPDATE STATISTICS MEDIUM FOR TABLE sdodiainv;
	 
    
     LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/sdodiainv'||TO_CHAR(vfecha,'%m%d%y')||'.txt '||
               ' select * from sdodiainv order by sucursal,producto,cliente;" > /resplogifx/conciliachq/sdodiainvtmp.sql';
     SYSTEM vsql;
     LET vsql = '';
    
     LET vstmt = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/sdodiainvtmp.sql"; 
     SYSTEM vstmt;
     LET vstmt = '';
	 

	 -- REPORTE VENCIMEINTOS       
	
	
	 IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'vencimientos') THEN
        DROP TABLE bdinvers:"informix".vencimientos; 
    END IF;
    
     CREATE TABLE bdinvers:"informix".vencimientos(
		 
		 --Fecha_hoy--
		 fecha_hoy	 			CHAR(10), 
		 --Moneda--
		 moneda 				CHAR(5),	
		 --Moneda Desc--
		 nom_moneda	 			CHAR(50),	
		 --Regional--
		 regional 				CHAR(45),
		 --Plaza--
		 plaza 					CHAR(45),
		 --Sucursal --
		 sucursal 				CHAR(15),
		 --Nom Sucursal --
		 nom_sucursal 			CHAR(125),
		 --Producto
		 producto 				CHAR(15),
		 --Desc Producto
		 desc_producto			CHAR(50),
		 --Inversion
		 inversion 				CHAR(15),
		 --Nombre Cliente --
		 cliente  			    CHAR(140), 
		 --Capital
		 capital				MONEY(18,2),
		 --Fecha Ultimo Pago
		 fec_ult_pago			CHAR(10),	 
		 --Interes por Pagar
		 int_por_pag			MONEY(18,2),	 
		 --Fecha Apertura		
		 fec_apertura			CHAR(10),
		 --Plazo
		 plazo					INTEGER,
		 --Tasa
		 tasa					CHAR(18),
		 --Fecha Vencimiento
		 fec_vencimiento		CHAR(10))
     
	 
     EXTENT SIZE 3200 NEXT SIZE 320 LOCK MODE ROW;
    
    
     FOREACH 
        
	 SELECT

     --Fecha_hoy
     vfecha,
     --Moneda
     sv_instrum.moneda,
	 --Desc. Moneda
	 si_divisas.descripcion moneda, 
     --Regional
     TRIM(si_plazas.regional)||' '|| TRIM(si_regional.nombre) regional,
     --Plaza
	 TRIM(sv_maeinv.plaza)||' '||TRIM(si_plazas.nombre) plaza ,
     --Sucursal 
     sv_maeinv.sucursal sucursal,
	 --Nom Sucursal
	 si_sucursales.nombre nom_sucursal,
     --Producto 
     sv_maeinv.cod_instrum,
	 --Desc Producto
	 sv_instrum.nombre producto, 
     --Inversion
     sv_maeinv.cuenta inversion,
     --Cliente 
     TRIM(si_cliente.apell_paterno)||' '||TRIM(si_cliente.apell_materno)||' '||TRIM(si_cliente.nombre1)||' '||TRIM(si_cliente.nombre2) cliente,
     --Capital
     sv_maeinv.capital capital,
     --Ultimo Pago
     sv_maeinv.fec_ult_mov ultimo_pago,
     --Interes por Pagar
     sv_maeinstrucc.importe int_x_pagar,
     --Fecha Apertura
     sv_maeinv.fecha_alta Apertura, 
     --Plazo
     sv_maeinv.plazo plazo,
     --Tasa
     (sv_maeinv.tasa + sv_maeinv.sobretasa) tasa, 
     --Fecha Vencimiento
     sv_maeinv.fecha_venc vencimiento
	 
	 INTO vfecha_hoy,vmoneda,vdesc_moneda,vregional,vplaza,vsucursal,vnom_sucursal,vcod_inst_inversion,vinst_inversion,vinversion,
		  vnom_cliente,vcapital,vfec_ult_pago,vinteres_pagar,vfec_apertura,vplazo,vtasa,vfec_vencimiento
			   
     FROM
     (((((((
	 "informix".sv_maeinv sv_maeinv INNER JOIN bdinteg:"informix".si_sucursales si_sucursales ON sv_maeinv.empresa = si_sucursales.empresa 
	 AND sv_maeinv.sucursal = si_sucursales.sucursal)
	
	 INNER JOIN bdinteg:"informix".si_cliente si_cliente ON sv_maeinv.num_cte = si_cliente.numcte)

	 INNER JOIN "informix".sv_maeinstrucc sv_maeinstrucc ON sv_maeinv.empresa = sv_maeinstrucc.empresa 
												              AND sv_maeinv.cuenta = sv_maeinstrucc.cuenta
															  AND sv_maeinstrucc.cap_int = 'I')	
															  
	 INNER JOIN "informix".sv_instrum sv_instrum ON sv_instrum.cod_instrum = sv_maeinv.cod_instrum 
												AND sv_instrum.empresa = sv_maeinv.empresa) 
												
	 INNER JOIN bdinteg:"informix".si_divisas si_divisas ON sv_instrum.empresa = si_divisas.empresa 
											 AND sv_instrum.moneda = si_divisas.divisa)
											
	 INNER JOIN bdinteg:"informix".si_plazas si_plazas ON si_sucursales.empresa = si_plazas.empresa 
										  AND si_sucursales.plaza = si_plazas.plaza)
	
	 INNER JOIN bdinteg:"informix".si_regional si_regional ON si_plazas.empresa = si_regional.empresa 
	 										   AND si_plazas.regional = si_regional.regional  )
     --INNER JOIN "informix".sv_fechas sv_fechas    ON si_divisas.empresa = sv_fechas.empresa   

	 WHERE
     sv_maeinv.status_cta NOT IN('2','4')
        
		INSERT INTO "informix".vencimientos VALUES 
		( to_char(vfecha_hoy,'%d/%m/%Y'),vmoneda,vdesc_moneda,vregional,vplaza,vsucursal,vnom_sucursal,vcod_inst_inversion,vinst_inversion,vinversion,
		  vnom_cliente,vcapital,to_char(vfec_ult_pago,'%d/%m/%Y'),vinteres_pagar,to_char(vfec_apertura,'%d/%m/%Y'),vplazo,vtasa,to_char(vfec_vencimiento,'%d/%m/%Y'));
			
			
			
     END FOREACH;
    
     CREATE INDEX "informix".idx_vencimientos ON bdinvers:"informix".vencimientos(inversion) USING BTREE;
     UPDATE STATISTICS MEDIUM FOR TABLE vencimientos;
   
    
     LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/conciliachq/vencimientos'||TO_CHAR(vfecha,'%m%d%y')||'.txt '||
                'select * from vencimientos order by moneda,sucursal,producto,fec_vencimiento,inversion;" > /resplogifx/conciliachq/vencimientostmp.sql';
     SYSTEM vsql;
     LET vsql = '';
    
     LET vstmt = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/vencimientostmp.sql"; 
     SYSTEM vstmt;
     LET vstmt = '';
	 
    
     END;
    
     RETURN vcodret1;
    
END PROCEDURE;