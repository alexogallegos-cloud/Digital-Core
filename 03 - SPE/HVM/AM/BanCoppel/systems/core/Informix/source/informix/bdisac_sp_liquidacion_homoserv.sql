CREATE PROCEDURE "informix".sp_liquidacion_homoserv(pCategoria CHAR(2), pConvenio CHAR(3))
	RETURNING CHAR(5)  AS CodRet, CHAR(16) AS Folio, CHAR(60) AS Mensaje;
		  
		-- // DECLARACION DE VARIABLES.
    DEFINE Sql_Err                          INTEGER;
    DEFINE Isam_Err                         INTEGER;
    DEFINE Desc_Err                         CHAR(50);
    DEFINE cCodRet	                        CHAR(5);  
	DEFINE vCuenta                          CHAR(20);	
    DEFINE vFolio                           CHAR(16);
	DEFINE vFolio_Comisiones		        CHAR(16);
	DEFINE vFolio_IVA_Comisiones	        CHAR(16);
    DEFINE cNombre                          CHAR(10);
	DEFINE iImporte_Pago_srv                INTEGER;
	DEFINE iCuenta_Pago_srv                 INTEGER;
	DEFINE iImporte_Pago_chq                INTEGER;
	DEFINE iImporte_Comision_Srv			DECIMAL(10,2);
	DEFINE iImporte_IVA_Comision_Srv		DECIMAL(10,2);
	DEFINE iImporte_Cobro_Comisiones_Srv	DECIMAL(10,2);
	DEFINE iImporte_Pago_chq_2              INTEGER;
	DEFINE cNumcategoria                    CHAR(2);
	DEFINE cNumconvenio                     CHAR(3);
	DEFINE cCuenta_prestadora               CHAR(20);
	DEFINE vMensaje                         CHAR(60);
	DEFINE pCuenta                          CHAR(20);
	DEFINE vTranret                         CHAR(4);
	DEFINE vFechoy                          DATE;
	DEFINE vSdodisp                         money(14,2);
	DEFINE vMontoret                        money(14,2);
	DEFINE cCtranssuc		                CHAR(4);
	DEFINE cTransCoppel                     CHAR(4);
	DEFINE cEtranssuc		                CHAR(4);
	DEFINE cCtransacc                       CHAR(4);
	DEFINE cCtransacc_Com		            CHAR(4);
	DEFINE cCtransacc_IVA_Com	            CHAR(4);
    DEFINE cAtransacc                       CHAR(4);
	DEFINE cCargo_cliente                   CHAR(4);
	DEFINE cEfectivo_cliente                CHAR(4);
	DEFINE cConsecutivo                     CHAR(2);
	DEFINE iSdo_actual		                INTEGER;
	DEFINE dFecha_hoy	                    DATE;
	DEFINE cDescripcionSPJ	                CHAR(100);
	DEFINE iImporte_Comisiones	            INTEGER;
	DEFINE iIva_Convenio		            INTEGER;
	DEFINE cCod_err2          	            CHAR(5);
	
	-- COMISION Sky
    DEFINE cCodRet_Sky	         	        CHAR(5);  
	DEFINE vCuenta_Sky          	        CHAR(20);	
    DEFINE vFolio_Sky            	        CHAR(16);
	DEFINE pCuenta_Sky		                CHAR(20);
	DEFINE vMensaje_Sky				        CHAR(60);
	DEFINE vTotal_Cargo_Coms_Sky	        MONEY(14,2);
	DEFINE vTotal_Cargo_Iva_Sky		        MONEY(14,2);
	DEFINE vTotal_Comision_Sky		        MONEY(14,2);
	DEFINE iSdo_actual_Sky			        MONEY(14,2);
	DEFINE ctranret_Sky				        CHAR(4);
	DEFINE DFecha_hoy_Sky			        DATE;
	DEFINE msdodisp_Sky				        MONEY (14,2);
	DEFINE mmontoret_Sky			        MONEY (14,2);

	--SET DEBUG FILE TO "/informix/EPG/sp_liquidacion_homoserv.out";
    --TRACE ON;
	
    -- // INICIALIZACION DE VARIABLES.
	LET Sql_Err	                           = 0;
    LET Isam_Err                           = 0;
    LET Desc_Err                           = '';
    LET cCodRet                            = '00001';
	LET cCod_err2                          = '00000';
	LET vCuenta                            = '';  
    LET vFolio                             = '';
	LET vFolio_Comisiones		           = '';
	LET vFolio_IVA_Comisiones	           = '';
	LET cNombre                            = '';
	LET iImporte_Pago_srv                  = '0';
	LET iCuenta_Pago_srv 	               = 0;
	LET iImporte_Pago_chq                  = '0';
	LET iImporte_Comision_Srv			   = 0.00;
	LET iImporte_IVA_Comision_Srv		   = 0.00;
	LET iImporte_Cobro_Comisiones_Srv	   = 0.00;
	LET iImporte_Pago_chq_2                = '0';
	LET cNumcategoria                      = '';
	LET cNumconvenio                       = '';
	LET cCuenta_prestadora                 = '0';
	LET vMensaje                           = '';
	LET pCuenta                            = '';
	LET vTranret                           = " ";
	LET vFechoy                            = " ";
	LET vSdodisp                           = 0;
	LET vMontoret                          = 0;
	LET cCtranssuc                         = '';
	LET cTransCoppel                       = '';
	LET cEtranssuc                         = '';
	LET cCtransacc                         = '';
	LET cCtransacc_Com		               = '';
	LET cCtransacc_IVA_Com	               = '';
    LET cAtransacc                         = '';
	LET cCargo_cliente                     = '';
	LET cEfectivo_cliente                  = '';
    LET cConsecutivo                       = '';	
	LET iSdo_actual                        = 0;
	LET dFecha_hoy	                       = CURRENT;
	LET cDescripcionSPJ	                   = 'Ejecuta liquidacion del servicio homologado:';
	LET iImporte_Comisiones	               = 0;
	LET iIva_Convenio	                   = 0;
	
	-- COMISION Sky
	LET cCodRet_Sky					       ='00000';
	LET vCuenta_Sky       			       = '';  
    LET vFolio_Sky        			       = '';
	LET pCuenta_Sky       			       = '';
	LET vMensaje_Sky				       = '';
	LET iSdo_actual_Sky				       =0;
	LET vTotal_Cargo_Coms_Sky		       =0;
	LET vTotal_Cargo_Iva_Sky		       =0;
	LET vTotal_Comision_Sky			       =0;
	LET ctranret_Sky				       ='';
	LET DFecha_hoy_Sky				       =CURRENT;
	LET msdodisp_Sky				       ='';
	LET mmontoret_Sky				       ='';

	
	
    BEGIN

	ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        IF Sql_Err <> 0 THEN
            LET cCodRet = Sql_Err;
            EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (Sql_Err, Isam_Err, Desc_Err, "sp_liquidacion_homoserv");
         RETURN cCodRet, vFolio, vMensaje;
        END IF;
    END EXCEPTION;
    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	

	SELECT fecha_hoy  INTO dFecha_hoy FROM sac_fechas WHERE empresa = '001';

	SELECT numcategoria, numconvenio, nomcomercialempresa, cuenta_prestadora, trans_suc_cargo, trans_suc_efectivo, 
		   trans_cen_cargo_cliente, trans_cen_efectivo_cliente, trans_cliq_cpl, trans_aliq_cpl, 
		   CASE WHEN pCategoria||pConvenio= '02003' THEN '01'--AXTEL
				WHEN pCategoria||pConvenio= '04001' THEN '02'--CFE
				WHEN pCategoria||pConvenio= '06004' THEN '03'--CABLEMAS
				WHEN pCategoria||pConvenio= '09011' THEN '04'--JAPAC
				WHEN pCategoria||pConvenio= '09002' THEN '05' END,--ARABELA
		   NVL(imp_com_trans_conv,0), NVL(iva_convenio,0), trans_cen_efectivo_cliente_cpl
	  INTO cNumcategoria, cNumconvenio, cNombre, cCuenta_prestadora, cCtranssuc, cEtranssuc, 
		   cCargo_cliente, cEfectivo_cliente, cCtransacc, cAtransacc, cConsecutivo, iImporte_Comisiones, iIva_Convenio, cTransCoppel
	  FROM bdisac:"informix".sac_convenios 
	 WHERE numcategoria = pCategoria
	   AND numconvenio  = pConvenio;
	   
	IF pCategoria = '04' AND pConvenio = '001' THEN
		LET cNombre = 'CFE';
	END IF;
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_LH_SC', dFecha_Hoy, '0', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));
	
	IF cConsecutivo = "05" THEN   --Caso Liquidacion de Comisiones
		--VERIFICO QUE NO SE HAYA EJECUTADO LA LIQUIDACION DE COMISIONES
		IF EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqbcpl WHERE proceso = 'LIQU_'||cNombre AND status = '1' AND fecha_proceso = dFecha_hoy) THEN
			LET cCodRet= "00001";
			LET vMensaje = "Liquidacion ya ha sido ejecutado";
			RETURN cCodRet, vFolio, vMensaje;
		ELIF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqbcpl WHERE proceso = 'LIQU_'||cNombre AND status = '0' AND fecha_proceso = dFecha_hoy) THEN
			INSERT INTO bdisac:"informix".sac_procesos_liqbcpl(proceso, fecha_proceso, status, user_insert, saldo_cta_pres, importe_srv, importe_chq, importe_comision, iva_comision, fecha_insert)
			VALUES ('LIQU_'||cNombre, dFecha_hoy, '0', 'informix','','','','','', CURRENT);
		END IF;
	ELSE
		--VERIFICO QUE NO SE HAYA EJECUTADO LA LIQUIDACION
		IF EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqhs WHERE proceso = 'LIQU_'||cNombre AND status = '1' AND fecha_proceso = dFecha_hoy) THEN
			LET cCodRet= "00001";
			LET vMensaje = "Liquidacion ya ha sido ejecutado";
			RETURN cCodRet, vFolio, vMensaje;
		ELIF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqhs WHERE proceso = 'LIQU_'||cNombre AND status = '0' AND fecha_proceso = dFecha_hoy ) THEN
			INSERT INTO bdisac:"informix".sac_procesos_liqhs(proceso, fecha_proceso, status, user_insert, saldo_cta_pres, importe_srv, inporte_chq, fecha_insert)
			VALUES ('LIQU_'||cNombre, dFecha_hoy, '0', 'informix','','','', CURRENT);
		END IF;
	END IF;
	
	IF cConsecutivo = "05" THEN   --Caso Liquidacion de Comisiones
		--Busco la transaccion para Comisiones de Arabela
		SELECT valor INTO cCtransacc_Com 
		FROM   bdisac:"informix".sac_param 
		WHERE  cod_param = '41';
		
		--Busco la transaccion para IVA de Comisiones de Arabela
		SELECT valor INTO cCtransacc_IVA_Com
		FROM   bdisac:"informix".sac_param 
		WHERE  cod_param = '42';
		
		
	ELSE
	
		SELECT valor INTO pCuenta 
		FROM   bdisac:"informix".sac_param 
		WHERE  cod_param = '40';
		
		SELECT mae.cuenta INTO vCuenta FROM bdicheq:"informix".sc_maechq mae
		 INNER JOIN bdicheq:"informix".sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta )
		 INNER JOIN bdicheq:"informix".sc_producto pro ON ( pro.empresa = mae.empresa AND pro.producto = mae.producto )
		 INNER JOIN bdinteg:"informix".si_cliente cte ON ( cte.numcte = mae.num_cte )
		  LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON ( tar.empresa = mae.empresa AND tar.cuenta = mae.cuenta AND tar.tipo_tarjeta = 'T' AND tar.status_tar = 'A' )
		 WHERE mae.empresa = '001'         
		   AND mae.cuenta = pCuenta; 
		
		-- // VERIFICA QUE LA CUENTA EXISTA               
		IF vCuenta is null OR vCuenta = '' OR vCuenta <> pCuenta THEN
			LET vFolio = '';
			LET cCodRet = '00100';
			LET vMensaje = 'No existe cuenta';
			RETURN cCodRet, vFolio, vMensaje;
		END IF;
		
	END IF
   
	IF cConsecutivo = "05" THEN   --Caso ARABELA
	
		--MONTO TOTAL DE LAS OPERACIONES DE SERVICIOS CRUZADO CON CHEQUES
		SELECT NVL(SUM(importe_pago),0), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0)
		INTO   iImporte_Pago_srv, iImporte_Comision_Srv, iImporte_IVA_Comision_Srv
		FROM   bdisac:sac_movimientos
		WHERE  numcategoria     = cNumcategoria
		AND    numconvenio      = cNumconvenio
		AND    status_cancelado <> 'S'
		AND    fecha_pago       = dFecha_hoy
		AND    folio_suc IN
		(	SELECT folio_suc
			FROM   bdicheq:sc_movdia
			WHERE  fech_alt     =  dFecha_hoy
			AND    transacc     IN (cCargo_cliente, cEfectivo_cliente, cTransCoppel)
			AND    transacc_suc IN (cCtranssuc, cEtranssuc)
			AND    cancelad     <> 'S'
		);
		
		LET iImporte_Pago_chq   = iImporte_Pago_srv;
		LET iImporte_Pago_chq_2 = iImporte_Pago_srv;
		   
		   
	ELSE
		
		--MONTO TOTAL DE LAS OPERACIONES DE SERVICIOS
		SELECT NVL(SUM(importe_pago),0), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0)
		  INTO iImporte_Pago_srv, iImporte_Comision_Srv, iImporte_IVA_Comision_Srv
		  FROM bdisac:"informix".sac_movimientos
		 WHERE numcategoria = cNumcategoria
		   AND numconvenio = cNumconvenio
		   AND fecha_pago = dFecha_hoy
		   AND status_cancelado <> 'S'
		   AND id_sucursal <> '9764'
		   AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1);
		   
		--IMPORTE TOTAL EN CHEQUES
		SELECT NVL(SUM(monto_tot),0), NVL(SUM(monto_tot),0) INTO iImporte_Pago_chq, iImporte_Pago_chq_2
		  FROM bdicheq:"informix".sc_movdia 
		 WHERE transacc IN (cCargo_cliente, cEfectivo_cliente) 
		   AND transacc_suc IN (cCtranssuc, cEtranssuc)
		   AND fech_alt = dFecha_hoy
		   AND cancelad <> 'S';
		   
	END IF;
		
		--SALDO EN LA CTA PRESTADORA
		SELECT sdo_actual INTO iSdo_actual 
		  FROM bdicheq:"informix".sc_maechq 
		 WHERE cuenta = cCuenta_prestadora;
		
		-----OPERACIONES PARA CARGO Y ABONO
		IF cConsecutivo = "05" THEN   --Caso ARABELA
		
			--Hago el calculo de las comisiones Para Servicios y Cheques
			LET iImporte_Cobro_Comisiones_Srv 	= iImporte_Comision_Srv + iImporte_IVA_Comision_Srv; --Calculo el total del cobro de comisiones de Servicios
			
			--SI EL SALDO EN LA CTA PRESTADORA ES MENOR A LA COMISION DETECTADA EN CHEQUES NO APLICA CARGO
			IF iSdo_actual < iImporte_Cobro_Comisiones_Srv THEN
			
				LET cCodRet  = '00000';
				LET vMensaje = 'No hay Saldo en la Cuenta';
				
				UPDATE bdisac:"informix".sac_procesos_liqbcpl
				   SET status           = '1',
				       saldo_cta_pres   = iSdo_actual,
					   importe_srv      = iImporte_Pago_srv,
					   importe_chq      = iImporte_Pago_chq,
					   importe_comision = iImporte_Comision_Srv,
					   iva_comision     = iImporte_IVA_Comision_Srv
				 WHERE proceso          = 'LIQU_'||cNombre
				   AND status           = '0'
				   AND fecha_proceso    = dFecha_hoy;
				
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod('1', 'BPI_PGOARA', 'PGOARA_NA', 'GRUPO_ARABELA', '', '', '2', 
				iImporte_Comision_Srv, iImporte_IVA_Comision_Srv, '','','','','','','','','','',1,0,0,0,0,CURRENT,'')
				INTO cCod_err2;

				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));
				RETURN cCodRet, vFolio, vMensaje;
		
			END IF;
		
			--GENERACION DEL 1ER FOLIO_SUC
			LET vFolio_Comisiones = 'sys_bcpl'||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,2)||cConsecutivo;
			
			--SE EJECUTA EL CARGO DE COMISIONES
			EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001','9764','informix',cCtransacc_Com,cCtranssuc,vFolio_Comisiones,cCuenta_prestadora,0,iImporte_Comision_Srv,'01','Cargo Comisiones','','')
			   INTO cCodRet, vTranret, vFechoy, vSdodisp, vMontoret;
				IF cCodRet = '000' THEN
					LET cCodRet  = '00000';
					LET vMensaje = 'Exitoso';
				ELSE
					LET vMensaje = 'Error controlado cargo_ref Comisiones';
					EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', vMensaje, 'sp_liquidacion_homoserv');
				END IF;
				
			--En caso de que la aplicacion del Cargo de comisiones haya sido correcta, se realizara el Cargo IVA de Comisiones
			IF cCodRet = '00000' THEN
			
				--GENERACION DEL 2DO FOLIO_SUC
				LET vFolio_IVA_Comisiones = 'sys_bcpl'||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,2)||cConsecutivo;
				
				--SE EJECUTA EL CARGO DE IVA DE COMISIONES
				EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001','9764','informix',cCtransacc_IVA_Com,cCtranssuc,vFolio_IVA_Comisiones,cCuenta_prestadora,0,iImporte_IVA_Comision_Srv,'01','Cargo Pago IVA de Comisiones','','')
				   INTO cCodRet, vTranret, vFechoy, vSdodisp, vMontoret;
					IF cCodRet = '000' THEN
						LET cCodRet  = '00000';
						LET vMensaje = 'Exitoso';
					ELSE
						LET vMensaje = 'Error controlado cargo_ref';
						EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', vMensaje, 'sp_liquidacion_homoserv');
					END IF;
					
				IF cCodRet = '00000' THEN
					UPDATE bdisac:"informix".sac_procesos_liqbcpl
					   SET status           = '1',
					       saldo_cta_pres   = iSdo_actual,
						   importe_srv      = iImporte_Pago_srv,
						   importe_chq      = iImporte_Pago_chq,
						   importe_comision = iImporte_Comision_Srv,
						   iva_comision     = iImporte_IVA_Comision_Srv
					 WHERE proceso          = 'LIQU_'||cNombre
					   AND status           = '0'
					   AND fecha_proceso    = dFecha_hoy;
					--ACTUALIZA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));			
				ELSE
					UPDATE bdisac:"informix".sac_procesos_liqbcpl
					   SET status           = '0',
					       saldo_cta_pres   = iSdo_actual,
						   importe_srv      = iImporte_Pago_srv,
						   importe_chq      = iImporte_Pago_chq,
						   importe_comision = iImporte_Comision_Srv,
						   iva_comision     = iImporte_IVA_Comision_Srv
					 WHERE proceso          = 'LIQU_'||cNombre
					   AND status           = '0'
					   AND fecha_proceso    = dFecha_hoy;			   
					LET vMensaje = vFolio_IVA_Comisiones || " " || vMensaje;
					RETURN cCodRet, vFolio_Comisiones, vMensaje;
				END IF;
				
			END IF; 
			
			IF iImporte_Pago_srv = iImporte_Pago_chq THEN
				RETURN cCodRet, vFolio_Comisiones, vMensaje;
			ELIF iImporte_Pago_srv < iImporte_Pago_chq THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOCHE','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iImporte_Pago_srv,iImporte_Pago_chq,'','','','','','','','','',1,0,0,0,0,'','') 
				INTO cCod_err2;
				
				LET cCodRet  = '00104';
				LET vMensaje = 'Dif Servicios vs Cheques';
				RETURN cCodRet, vFolio, vMensaje;
			ELIF iImporte_Pago_srv > iImporte_Pago_chq	THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOSER','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iImporte_Pago_srv,iImporte_Pago_chq,'','','','','','','','','',1,0,0,0,0,'','')
				INTO cCod_err2;
				
				LET cCodRet  = '00104';
				LET vMensaje = 'Dif Servicios vs Cheques';
				RETURN cCodRet, vFolio, vMensaje;	
			END IF; ---FIN ARABELA
			

		ELSE
		
			IF pCategoria = '04' AND pConvenio = '001' THEN
				CALL bdisac:"informix".sp_liqui_comision_sky('06', '001') --SE EJECUTA PROCEDIMIENTO PARA COMISION SKY
				RETURNING cCodRet_Sky, vFolio_Sky, vMensaje_Sky; 
	        END IF;
		

		
		
			--SI EL SALDO EL LA CTA PRESTADORA ES MENOR A LO QUE HAY EN CHEQUES, SE LIQUIDA LO QUE HAY EN LA CTA PRESTADORA
			IF iSdo_actual < iImporte_Pago_chq THEN 
				LET iImporte_Pago_chq = iSdo_actual;
			END IF;	
			
			--SI EL IMPORTE EN CHEQUES ES CERO NO APLICA CARGO NI ABONO
			IF iImporte_Pago_chq <= 0 THEN
				LET cCodRet  = '00000';
				LET vMensaje = 'No hay Movimientos';
				UPDATE bdisac:"informix".sac_procesos_liqhs SET status = '1', saldo_cta_pres = iSdo_actual, importe_srv = iImporte_Pago_srv, inporte_chq = iImporte_Pago_chq_2
				 WHERE PROCESO = 'LIQU_'||cNombre
				   AND status = '0' 
				   AND fecha_proceso = dFecha_hoy;			   

				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));			
				RETURN cCodRet, vFolio, vMensaje;			
			END IF;

			--GENRECION DE FOLIO_SUC
			LET vFolio = 'sys_bcpl'||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,2)||cConsecutivo;
			
			--SE EJECUTA EL CARGO TOTAL DEL SERVICIO
			EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001','9764','informix',cCtransacc,cCtranssuc,vFolio,cCuenta_prestadora,0,iImporte_Pago_chq,'01','Cargo Pago Liquidacion HomoServicios','','') 
			   INTO cCodRet, vTranret, vFechoy, vSdodisp, vMontoret;
				IF cCodRet = '000' THEN
					--SE EJECUTA EL ABONO TOTAL DEL SERVICIO A LA CUENTA CONCENTRADORA
					EXECUTE PROCEDURE bdicheq:"informix".abono_ref('001','9764','informix',cAtransacc,cCtranssuc,vFolio,pCuenta,1,iImporte_Pago_chq,iImporte_Pago_chq,0,0,0,'01','Abono Pago Liquidacion HomoServicios ','0','') 
						INTO cCodRet;
					IF cCodRet = '000' THEN
						LET cCodRet  = '00000';
						LET vMensaje = 'Exitoso';
					ELSE
						--SI OCURRE UN ERROR EN EL ABONO SE REVERSA LA OPERACION
						EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', vMensaje, 'sp_liquidacion_homoserv');	
						EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9764', 'informix', vFolio, '') into cCodRet;
						LET vMensaje = 'Error abono_ref';
						LET cCodRet  = '00200';
						RETURN cCodRet, vFolio, vMensaje;
					END IF;
				ELSE 
					LET vMensaje = 'Error controlado cargo_ref';	
					EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', vMensaje, 'sp_liquidacion_homoserv');					
				END IF;	
			
			IF cCodRet = '00000' THEN	
				UPDATE bdisac:"informix".sac_procesos_liqhs SET status = '1', saldo_cta_pres = iSdo_actual, importe_srv = iImporte_Pago_srv, inporte_chq = iImporte_Pago_chq_2
				 WHERE PROCESO = 'LIQU_'||cNombre
				   AND status = '0' 
				   AND fecha_proceso = dFecha_hoy;
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));			

	
			ELSE
				UPDATE bdisac:"informix".sac_procesos_liqhs SET status = '0', saldo_cta_pres = iSdo_actual, importe_srv = iImporte_Pago_srv, inporte_chq = iImporte_Pago_chq_2
				 WHERE PROCESO = 'LIQU_'||cNombre
				   AND status = '0' 
				   AND fecha_proceso = dFecha_hoy;			   
				RETURN cCodRet, vFolio, vMensaje;
			END IF;	
			
			
			IF iImporte_Pago_srv = iImporte_Pago_chq THEN
				RETURN cCodRet, vFolio, vMensaje;
			ELIF iSdo_actual < iImporte_Pago_chq_2 THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_CTAPRE','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iSdo_actual,iImporte_Pago_chq_2,'','','','','','','','','',1,0,0,0,0,'','') 
				INTO cCod_err2;
				
				LET cCodRet  = '00101';
				LET vMensaje = 'Dif sdo_cta';
				RETURN cCodRet, vFolio, vMensaje;
			ELIF iImporte_Pago_srv < iImporte_Pago_chq THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOCHE','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iImporte_Pago_srv,iImporte_Pago_chq,'','','','','','','','','',1,0,0,0,0,'','') 
				INTO cCod_err2;
				
				LET cCodRet  = '00102';
				LET vMensaje = 'Dif Serv';
				RETURN cCodRet, vFolio, vMensaje;
			ELIF iImporte_Pago_srv > iImporte_Pago_chq	THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOSER','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iImporte_Pago_srv,iImporte_Pago_chq,'','','','','','','','','',1,0,0,0,0,'','')
				INTO cCod_err2;
				
				LET cCodRet  = '00103';
				LET vMensaje = 'Dif Chqs';			
				RETURN cCodRet, vFolio, vMensaje;
			END IF;
		END IF;

END	
END PROCEDURE
DOCUMENT
'Desarrollador: Eduardo Pineda Guzman',
'Modifica: Victor Manuel Hernandez Lopez',
'Fecha: 30 MAYO 2024',
'Funcion del SPL: Se separa del flujo el proceso de sky, para que se ejecute sin depender de la transaccionalidad de cfe u otro servicio';

CREATE PROCEDURE  "informix".sp_metricas_envio_dinero_mes (pfecharepor DATE)

RETURNING CHAR(5) AS iCodRet, char(50) as iMensaje;
	--GENERAR REPOTE DE METRICAS DE ENVIOS DE DINERO REMESAS Y ENROLAMIENTO--
	
	DEFINE iCodRet 			CHAR(5);
	DEFINE iMensaje			CHAR(50);
	DEFINE cRutaArch 		CHAR(100);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cDia 			CHAR(2);
	DEFINE cMes 			CHAR(2);
	DEFINE cAnio 			CHAR(4);
	DEFINE dFecha_Hoy 		DATE;
	DEFINE cStmt 			CHAR (500);
	DEFINE vValida			INTEGER;
	
	

	DEFINE vfecha_proceso			DATE;
	DEFINE vfecha_procesoI			DATE;
	DEFINE vfecha_procesoF			DATE;
	DEFINE vtipo_remesa				CHAR(3); 
	DEFINE vabono_cuenta			CHAR(2);
	DEFINE vmonto_total				MONEY;
	DEFINE vmonto_dolares			MONEY;
	DEFINE vbeneficiario_nombre1	CHAR(30);
	DEFINE vbeneficiario_nombre2	CHAR(30); 
	DEFINE vbeneficiario_appaterno	CHAR(30);
	DEFINE vbeneficiario_apmaterno	CHAR(30);
	DEFINE vbeneficiario_fecha_nac	DATE;
	DEFINE vbeneficiario_estado		CHAR(50);
	DEFINE vbeneficiario_mncpo_del	CHAR(50);
	DEFINE vbeneficiario_ciudad		CHAR(50);
	DEFINE vbeneficiario_direccion	CHAR(100);
	DEFINE vbeneficiario_colonia	CHAR(80);
	DEFINE vbeneficiario_calle 		CHAR(50);
	DEFINE vsucursal				CHAR(4);
	DEFINE vnum_confirmacion		CHAR(20);
	DEFINE vfolio_sucursal			CHAR(16);
	DEFINE vnumCliente				CHAR(20);
	DEFINE vNombreBenef				CHAR(300);
	
	
	DEFINE vnombre_estado			CHAR(30);
	--DEFINE vsucursal				CHAR(4); 
	DEFINE vtotal_enrolados			INTEGER;
	DEFINE vtotal_penrolados		INTEGER;
	DEFINE vtotal_t1				INTEGER;
	DEFINE vtotal_t2				INTEGER;
	DEFINE vtotal_pt1				INTEGER;
	DEFINE vtotal_pt2				INTEGER;
	DEFINE vtusuarios_enrolados 	INTEGER;
	DEFINE vtusuarios_no_enrolados 	INTEGER;
	DEFINE vPromedio			 	DECIMAL;
	
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_metricas_envio_dinero.out';
	--TRACE ON; 
	--SET DEBUG FILE TO '/INFORMIXTMP/HMLG/sp_metricas_envio_dinero.out';
	--TRACE ON;
	
	LET vfecha_proceso			= MDY('01','01','1900');
	LET vfecha_procesoF			= MDY('01','01','1900');
	LET vfecha_procesoI			= MDY('01','01','1900');	
	LET iCodRet = "00000";
	LET cRutaArch = '';
	LET iSqlErr = 0;
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET dFecha_Hoy = MDY('01','01','1900');
	LET cStmt = '';
	LET iMensaje = '';
	LET vValida = 0;
	

	LET vtipo_remesa			= '';	
	LET vabono_cuenta			= '';
	LET vmonto_total			= 0;	
	LET vmonto_dolares			= 0;
	LET vbeneficiario_nombre1	= '';
	LET vbeneficiario_nombre2	= '';
	LET vbeneficiario_appaterno	= '';
	LET vbeneficiario_apmaterno	= '';
	LET vbeneficiario_fecha_nac	= MDY('01','01','1900');
	LET vbeneficiario_estado	= '';	
	LET vbeneficiario_mncpo_del	= '';
	LET vbeneficiario_ciudad	= '';	
	LET vbeneficiario_direccion	= '';
	LET vbeneficiario_colonia	= '';
	LET vbeneficiario_calle 	= '';	
	LET vsucursal				= '';
	LET vnum_confirmacion		= '';
	LET vfolio_sucursal			= '';
	LET vnumCliente				= '';
	LET vNombreBenef			= '';	
	
		
	LET vnombre_estado 			= '';						
	LET vtotal_enrolados		= 0;			
	LET vtotal_penrolados		= 0;		
	LET vtotal_t1				= 0;			
	LET vtotal_t2				= 0;			
	LET vtotal_pt1				= 0;			
	LET vtotal_pt2				= 0;			
	LET vtusuarios_enrolados 	= 0;	
	LET vtusuarios_no_enrolados	= 0; 	
	LET vPromedio				= 0.00;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			LET iMensaje = "Proceso NO Exitoso Error BD.";
			
			
			IF cRutaArch IS NOT NULL OR cRutaArch <> "" THEN 
				LET cStmt = 'rm -f ' || cRutaArch;
				SYSTEM cStmt;
			END IF;
			
			drop table if exists tempsuc_pivMovHis1;
			
			DROP TABLE IF EXISTS tempsuc_edo;
			DROP TABLE IF EXISTS tempsuc_periodo;
			DROP TABLE IF EXISTS temptipoctee;
			DROP TABLE IF EXISTS temptipocte1;
			DROP TABLE IF EXISTS temptipocte2;
			DROP TABLE IF EXISTS temptipocte11;
			DROP TABLE IF EXISTS temptipocte22;
			DROP TABLE IF EXISTS tempsuc1;
			DROP TABLE IF EXISTS temp_wu_enrol;
			DROP TABLE IF EXISTS temp_wu_noenrol;
			DROP TABLE IF EXISTS temp_app_enrol;
			DROP TABLE IF EXISTS temp_app_noenrol;
			DROP TABLE IF EXISTS temp_bts_enrol;
			DROP TABLE IF EXISTS temp_bts_noenrol;
			DROP TABLE IF EXISTS tempsuc_piv;
			DROP TABLE IF EXISTS tempsuc_pivMovHis;
			DROP TABLE IF EXISTS tempsuc_edo_t1t2;
			DROP TABLE IF EXISTS temp_totalrempag;
			DROP TABLE IF EXISTS temp_reporteenrolamiento58;
			DROP TABLE IF EXISTS tempsuc_periodot;
			
			
			RETURN iCodRet,iMensaje;
			
		END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
			drop table if exists tempsuc_pivMovHis1;
			DROP TABLE IF EXISTS tempsuc_edo;
			DROP TABLE IF EXISTS tempsuc_periodo;
			DROP TABLE IF EXISTS temptipoctee;
			DROP TABLE IF EXISTS temptipocte1;
			DROP TABLE IF EXISTS temptipocte2;
			DROP TABLE IF EXISTS temptipocte11;
			DROP TABLE IF EXISTS temptipocte22;
			DROP TABLE IF EXISTS tempsuc1;
			DROP TABLE IF EXISTS temp_wu_enrol;
			DROP TABLE IF EXISTS temp_wu_noenrol;
			DROP TABLE IF EXISTS temp_app_enrol;
			DROP TABLE IF EXISTS temp_app_noenrol;
			DROP TABLE IF EXISTS temp_bts_enrol;
			DROP TABLE IF EXISTS temp_bts_noenrol;
			DROP TABLE IF EXISTS tempsuc_piv;
			DROP TABLE IF EXISTS tempsuc_pivMovHis;
			DROP TABLE IF EXISTS tempsuc_edo_t1t2;
			DROP TABLE IF EXISTS temp_totalrempag;
			DROP TABLE IF EXISTS temp_reporteenrolamiento58;
			DROP TABLE IF EXISTS tempsuc_periodot;
		
		
		IF pfecharepor IS NULL OR  pfecharepor = "" THEN
		
			SELECT fecha_hoy 
			INTO dFecha_Hoy 
			FROM bdisac:sac_fechas
			WHERE empresa = "001";
		
			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
		
			LET vfecha_proceso			= dFecha_Hoy;
			LET dFecha_Hoy 				= vfecha_proceso -36;
			
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM sac_movimientoshistorial 
				WHERE fecha_insert >= EXTEND(dFecha_Hoy, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
				AND fecha_insert <= EXTEND(vfecha_proceso, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis1  WITH NO LOG;
			
			
			SELECT FIRST 1 MIN(fecha_insert),MAX(fecha_insert)
				INTO vfecha_procesoI,vfecha_procesoF
				FROM tempsuc_pivMovHis1
				WHERE MONTH(fecha_insert) = MONTH(dFecha_Hoy +15);
				
		ELSE 
		
			LET vfecha_proceso			= pfecharepor;
			LET dFecha_Hoy 				= vfecha_proceso -36;
			
			LET cDia = LPAD(DAY(vfecha_proceso::DATE), 2, '0');
			LET cMEs = LPAD(MONTH(vfecha_proceso::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(vfecha_proceso::DATE), 4, '0');
			
			
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM sac_movimientoshistorial 
				WHERE fecha_insert >= EXTEND(dFecha_Hoy, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
				AND fecha_insert <= EXTEND(vfecha_proceso, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis1  WITH NO LOG;
			
			SELECT FIRST 1 MIN(fecha_insert),MAX(fecha_insert)
				INTO vfecha_procesoI,vfecha_procesoF
				FROM tempsuc_pivMovHis1
				WHERE MONTH(fecha_insert) = MONTH(dFecha_Hoy +15);

		END IF;
				
		
		IF vfecha_procesoI IS NOT NULL OR vfecha_procesoF IS NOT NULL THEN 
				
			--"METRICAS DE ENVIOS DE DINERO REPORTE 2 MENSUAL"
			
			
			--01 Genera tabla Pivote con sucursales que pagaron remesas
				
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM tempsuc_pivMovHis1 
				WHERE fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                AND fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis  WITH NO LOG;
			
			drop table if exists tempsuc_pivMovHis1;
			
			SELECT  id_sucursal as sucursal
				FROM tempsuc_pivMovHis 
				WHERE numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764') 
				AND status_cancelado = 'N'
				GROUP BY id_sucursal
			INTO TEMP tempsuc_piv  WITH NO LOG;
			
			--02 Totales de ususarios enrolados por sucursal de tabla pivote 
			SELECT b.cve_estado,d.nombre AS nombre_estado,a.sucursal
				FROM tempsuc_piv a
				LEFT JOIN bdinteg:si_ptf b on a.sucursal = b.id_ptf and b.tipo in ('S','O')
				LEFT JOIN bdinteg:si_estados d ON b.cve_pais = d.pais
				AND b.cve_estado = d.estado
				GROUP BY a.sucursal, b.cve_estado,d.nombre
			INTO TEMP tempsuc_edo  WITH NO LOG;
			
			--03 Total de enrolados y por periodo del reporte
			SELECT sucursal,NVL(count(*),0) as total_enrolados 
				FROM sac_cte_remesas  /*fechas para totales*/
				WHERE fecha_insert 
				BETWEEN vfecha_procesoI 
				AND vfecha_procesoF
				AND sucursal <> ''
				GROUP BY sucursal
			INTO TEMP tempsuc_periodot  WITH NO LOG; 
			
			SELECT sucursal,NVL(count(*),0) as totale_periodo 
				FROM sac_cte_remesas
				WHERE fecha_insert 
				BETWEEN vfecha_procesoI 
				AND vfecha_procesoF
				AND sucursal <> ''
				GROUP BY sucursal
			INTO TEMP tempsuc_periodo  WITH NO LOG; 
			
			
			--04 Junta tablas temporales tempsuc_edo y tempsuc_periodo
			SELECT a.cve_estado,a.nombre_estado,a.sucursal,NVL(cc.total_enrolados,0) as total_enrolados,NVL(b.totale_periodo,0) AS total_penrolados  
				FROM tempsuc_edo a
				LEFT JOIN tempsuc_periodo b ON a.sucursal = b.sucursal
				LEFT JOIN tempsuc_periodot cc ON a.sucursal = cc.sucursal
			INTO TEMP tempsuc1  WITH NO LOG;
			
			DROP TABLE IF EXISTS tempsuc_edo;
			DROP TABLE IF EXISTS tempsuc_periodo;
			DROP TABLE IF EXISTS tempsuc_periodot;
			
			--05 Busqueda del tipo de cliente de cada enrolado *****
			
			SELECT sucursal, numcte, fecha_insert 
				FROM bdisac:sac_cte_remesas
				WHERE fecha_insert 
				BETWEEN vfecha_procesoI 
				AND vfecha_procesoF
			INTO TEMP temptotcteenr WITH NO LOG;
			
			SELECT a.sucursal,a.numcte,a.fecha_insert,b.tipo_cliente
				FROM temptotcteenr a
				LEFT JOIN bdinteg:si_cliente b ON a.numcte = b.numcte /*fechas para totales*/
				WHERE a.fecha_insert 
				BETWEEN vfecha_procesoI 
				AND vfecha_procesoF
			INTO TEMP temptipoctee  WITH NO LOG;
			
			--06 genera tablas con totales por el tipo de cliente 
			SELECT sucursal,NVL(count(*),0) AS total_ct1
				FROM temptipoctee
				WHERE tipo_cliente = 1
				GROUP BY sucursal 
			INTO TEMP temptipocte1  WITH NO LOG;
				
			SELECT sucursal,NVL(count(*),0) AS total_ct2
				FROM temptipoctee
				WHERE tipo_cliente = 2
				GROUP BY sucursal 
			INTO TEMP temptipocte2  WITH NO LOG;
				
			SELECT sucursal,NVL(count(*),0) AS total_ct1p
				FROM temptipoctee
				WHERE tipo_cliente = 1
				AND fecha_insert >= vfecha_procesoI
				AND fecha_insert <= vfecha_procesoF
				GROUP BY sucursal 
			INTO TEMP temptipocte11  WITH NO LOG;
				
			SELECT sucursal,NVL(count(*),0) AS total_ct2p
				FROM temptipoctee
				WHERE tipo_cliente = 2
				AND fecha_insert >= vfecha_procesoI
				AND fecha_insert <= vfecha_procesoF
				GROUP BY sucursal 
			INTO TEMP temptipocte22  WITH NO LOG;
			
			
			DROP TABLE IF EXISTS temptipoctee;
			
			
			--6 Junta tablas temporales a 1 reporte
			SELECT a.cve_estado,a.nombre_estado,a.sucursal,a.total_enrolados,
				a.total_penrolados,
				NVL(total_ct1,0)AS  total_t1,
				NVL(total_ct2,0)AS total_t2,
				NVL(total_ct1p,0)AS total_pt1,
				NVL(total_ct2p,0)AS total_pt2
				FROM tempsuc1 a
				LEFT JOIN temptipocte1 d ON a.sucursal = d.sucursal
				LEFT JOIN temptipocte2 e ON a.sucursal = e.sucursal
				LEFT JOIN temptipocte11 f ON a.sucursal = f.sucursal
				LEFT JOIN temptipocte22 h ON a.sucursal = h.sucursal
			INTO TEMP tempsuc_edo_t1t2  WITH NO LOG;
			
			DROP TABLE IF EXISTS temptipocte1;
			DROP TABLE IF EXISTS temptipocte2;
			DROP TABLE IF EXISTS temptipocte11;
			DROP TABLE IF EXISTS temptipocte22;
			DROP TABLE IF EXISTS tempsuc1;
			
			--7 BUSQUEDA DE TOTALES POR REMESADORA 
			
				--7.1 BUSQEDA PARA WU
				
					SELECT a.id_sucursal,count(unique(a.referencia1)) as TotalWU_usuenrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_wu_pay w ON a.referencia1 = w.mtcn
						AND a.folio_suc = w.foreign_rs_refnum_rp
						WHERE a.numcategoria = '07'
						AND a.numconvenio IN ('006','007','008')
                        and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND w.numcte <> ''
                        and w.conf_pago = 'P'
                        and w.txn_status = 'A' 
                        and w.retcode = '00000'
						GROUP BY a.id_sucursal
                       INTO TEMP temp_wu_enrol  WITH NO LOG;
					
					SELECT a.id_sucursal,count(unique(a.referencia1)) as TotalWU_usu_no_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_wu_pay w ON a.referencia1 = w.mtcn
						AND a.folio_suc = w.foreign_rs_refnum_rp
						WHERE a.numcategoria = '07'
						AND a.numconvenio IN ('006','007','008')
						and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND w.numcte = ''
                        and w.conf_pago = 'P'
                        and w.txn_status = 'A' 
                        and w.retcode = '00000'
						GROUP BY a.id_sucursal
                       INTO TEMP temp_wu_noenrol  WITH NO LOG;					
			
				--7.2 BUSQUEDA PARA APPRIZA
				
					SELECT trim(ap.nnumber) as sucursal,count(unique(ap.unirefnum)) as TotalAPP_usu_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_app_payi ap ON a.referencia1 = ap.unirefnum
						AND a.folio_suc = ap.refnum
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '009'
                        and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND 
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND ap.numcte <> ''
                        and ap.txn_status = 'A'
                        and ap.r_code_d = 'P000' 
                        and ap.r_code = '0000'
						GROUP BY ap.nnumber
                    INTO TEMP temp_app_enrol   WITH NO LOG;
					
					SELECT trim(ap.nnumber) as sucursal,count(unique(ap.unirefnum)) as TotalAPP_usu_no_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_app_payi ap ON a.referencia1 = ap.unirefnum
						AND a.folio_suc = ap.refnum
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '009'
                        and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND 
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND  
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND ap.numcte = ''
                        and ap.txn_status = 'A'
                        and ap.r_code_d = 'P000' 
                        and ap.r_code = '0000'
						GROUP BY ap.nnumber
                    INTO TEMP temp_app_noenrol   WITH NO LOG;


				--7.3 BUSQUEDA PARA BTS

					SELECT a.id_sucursal as sucursal,count(unique(bt.confirmation_nm)) as TotalBTS_usu_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_bts_payi bt ON a.referencia1 = bt.confirmation_nm
						AND a.folio_suc = bt.bank_ref_nm
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '004'
						and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND 
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
                        AND bt.numcte <> ''
						AND bt.opcode = '1100'
						AND bt.txn_status = 'A'
						GROUP BY a.id_sucursal
                    INTO TEMP temp_bts_enrol   WITH NO LOG;
					
					SELECT a.id_sucursal as sucursal,count(unique(bt.confirmation_nm)) as TotalBTS_usu_no_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_bts_payi bt ON a.referencia1 = bt.confirmation_nm
						AND a.folio_suc = bt.bank_ref_nm
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '004'
						and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
                        AND bt.numcte = ''
						AND bt.opcode = '1100'
						AND bt.txn_status = 'A'
						GROUP BY a.id_sucursal
                    INTO TEMP temp_bts_noenrol   WITH NO LOG;


					
				--7.4 Union de resultados
				
					SELECT a.sucursal,
						(NVL(app1.totalapp_usu_enrol,0) + NVL(bts1.totalbts_usu_enrol,0) + NVL(wu1.totalwu_usuenrol,0)) as tusuarios_enrolados,
						(NVL(app2.totalapp_usu_no_enrol,0) + NVL(bts2.totalbts_usu_no_enrol,0) + NVL(wu2.totalwu_usu_no_enrol,0)) as tusuarios_no_enrolados
						FROM tempsuc_piv a
						LEFT JOIN temp_app_enrol app1 ON a.sucursal = app1.sucursal
						LEFT JOIN temp_bts_enrol bts1 ON a.sucursal = bts1.sucursal
						LEFT JOIN temp_wu_enrol wu1 ON a.sucursal = wu1.id_sucursal
						LEFT JOIN temp_app_noenrol app2 ON a.sucursal = app2.sucursal
						LEFT JOIN temp_bts_noenrol bts2 ON a.sucursal = bts2.sucursal
						LEFT JOIN temp_wu_noenrol wu2 ON a.sucursal = wu2.id_sucursal
					INTO TEMP temp_totalrempag  WITH NO LOG;
					
					DROP TABLE IF EXISTS temp_wu_enrol;
					DROP TABLE IF EXISTS temp_wu_noenrol;
					DROP TABLE IF EXISTS temp_app_enrol;
					DROP TABLE IF EXISTS temp_app_noenrol;
					DROP TABLE IF EXISTS temp_bts_enrol;
					DROP TABLE IF EXISTS temp_bts_noenrol;
					
			--8 GENERA REPORTE 

				SELECT a.nombre_estado,a.sucursal,
				a.total_penrolados,
				a.total_pt1,a.total_pt2,
				b.tusuarios_enrolados,b.tusuarios_no_enrolados,0 as promedio
				FROM tempsuc_edo_t1t2 a
				LEFT JOIN temp_totalrempag b ON a.sucursal = b.sucursal
				INTO temp_reporteenrolamiento58;
			
				DROP TABLE IF EXISTS tempsuc_piv;
				DROP TABLE IF EXISTS tempsuc_pivMovHis;
				DROP TABLE IF EXISTS tempsuc_edo_t1t2;
				DROP TABLE IF EXISTS temp_totalrempag;
				
				SELECT COUNT(*) 
				INTO vValida
				FROM temp_reporteenrolamiento58;
				
				
				IF vValida <> 0  THEN
					
				
					LET cRutaArch = '/home/systelmex/metricas_envio_dinero_2_mes_DDMMAAAA.csv';
			
					LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
					LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
					LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);

					LET cStmt = 'rm -f ' || cRutaArch;
					SYSTEM cStmt;			
										
					LET cStmt = 'echo "' || "METRICAS DE ENVIOS DE DINERO REPORTE 2 MENSUAL " || vfecha_procesoI ||" - "|| vfecha_procesoF || '" >> ' || cRutaArch;
					SYSTEM cStmt; 
			
					LET cStmt = 'echo "' || "ESTADO" || "," ||"SUCURSAL" || "," || "CLIENTES ENROLADOS PERIODO" || "," || "CLIENTES ENROLADOS T1 PERIODO" || "," || "CLIENTES ENROLADOS T2 PERIODO" || "," || 
						"TOTAL TRANSACCIONES USUARIO ENROLADO PERIODO" || "," || "TOTAL TRANSACCIONES USUARIO NO ENROLADO PERIODO" || "," || "PROMEDIO USUARIO ENROLADO PERIODO" || '" >> ' || cRutaArch;
						SYSTEM cStmt;
				/*
					FOREACH
					
						SELECT  sucursal,total_penrolados,tusuarios_enrolados
						INTO vsucursal,vtotal_enrolados,vtusuarios_enrolados
						FROM temp_reporteenrolamiento58
						
						
						
						IF vtusuarios_enrolados <> 0  THEN
							IF vtotal_enrolados <> 0 THEN
								LET vPromedio = ROUND((ROUND(vtusuarios_enrolados,2)/ROUND(vtotal_enrolados,2)),2);
								UPDATE temp_reporteenrolamiento58 SET promedio = vPromedio WHERE sucursal = vsucursal;
							ELSE
								UPDATE temp_reporteenrolamiento58 SET promedio = 0 WHERE sucursal = vsucursal;
							END IF;
						ELSE
							UPDATE temp_reporteenrolamiento58 SET promedio = 0 WHERE sucursal = vsucursal;
						END IF;
						
						
					END FOREACH;
					*/
					
					LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinerom_2.csv';
					SYSTEM cStmt;
					
					LET cStmt = 'echo "UNLOAD TO /home/systelmex/metricas_envio_dinerom_2.csv DELIMITER '','' SELECT * FROM temp_reporteenrolamiento58 ORDER BY 1,2;">/home/systelmex/reportemetenrm2.sql';
					SYSTEM cStmt;
				
					let cStmt= 'dbaccess bdisac	/home/systelmex/reportemetenrm2.sql';
					system cStmt;
					
					SYSTEM 'tail -n +1 /home/systelmex/metricas_envio_dinerom_2.csv >> ' || cRutaArch;
					
					LET cStmt = 'rm -f /home/systelmex/reportemetenrm2.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinerom_2.csv';
					SYSTEM cStmt;
					
					DROP TABLE IF EXISTS temp_reporteenrolamiento58;
					LET iCodRet = "00000";				
					LET iMensaje =  "Proceso Exitoso 2 Mensual";
					
					
					INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_2m',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero_mensual','Reporte Metricas de Envio de Dinero y Enrolamiento 2 mensual');
	
				
				ELSE
					LET cStmt = 'rm -f ' || cRutaArch;
					SYSTEM cStmt;
				
					LET iCodRet = "00000";				
					LET iMensaje =  "Proceso Exitoso 2 mensual  Sin Datos";
					INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_2m',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero_mensual','Reporte Metricas de Envio de Dinero y Enrolamiento 2 mensual');
				END IF;
					
		ELSE
			
			LET iCodRet = "00001";				
			LET iMensaje =  "Proceso NO Exitoso";
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('REP_MET_ENV_DIN_ENROL_2m',today,'0','informix',CURRENT,'1','sp_metricas_envio_dinero_mensual','Reporte Metricas de Envio de Dinero y Enrolamiento 2 mensual');
		
		END IF;
		
		
		RETURN iCodRet,iMensaje;
		
	END;

END PROCEDURE;