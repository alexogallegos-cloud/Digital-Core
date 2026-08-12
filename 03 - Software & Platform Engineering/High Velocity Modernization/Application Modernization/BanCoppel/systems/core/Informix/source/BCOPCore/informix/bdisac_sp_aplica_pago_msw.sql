CREATE PROCEDURE "informix".sp_aplica_pago_msw(pOrigen CHAR(4),pTransaccion CHAR(5),pCategoria CHAR(2),pConvenio CHAR(3),pSucursal_tienda CHAR(4),
	pCajero CHAR(8),pCaja CHAR(3),pFecha CHAR(8),pHora CHAR(6),pFolio_peracion CHAR(18),pReferencia_1 CHAR(40),pReferencia_2 CHAR(40),pReferencia_3 CHAR(40),
	pReferencia_4 CHAR(40),pImporte CHAR(10),pFormapago CHAR(1))
	RETURNING
	CHAR(5) 	AS codigo,
	CHAR(30) 	AS mensaje,
	CHAR(16)	AS folio_suc;
	
	DEFINE iSqlErr                INTEGER;
    DEFINE iIsamErr               INTEGER;
    DEFINE cInfoErr               CHAR(100);
	DEFINE cCodRet                CHAR(5);
	DEFINE cMensaje				  CHAR(30);
	DEFINE cFolioSuc			  CHAR(16);

	--Variables para obtener el folio TAE Categoria ='03' y convenio = '001'
	DEFINE cCodRetTae             CHAR(5);
	DEFINE cFolioTae			  CHAR(9);
	                                 
	DEFINE deImpComisionConvenio  DECIMAL (6,2);
	DEFINE deIvaComisionConvenio  DECIMAL (6,2);
	DEFINE deImpComisionCliente   DECIMAL (6,2);
	DEFINE deIvaComisionCliente   DECIMAL (6,2);	
                                     
	DEFINE cCodRet2				  CHAR(5);
	DEFINE mTotComision			  MONEY(16,2);
	DEFINE mTotIVA				  MONEY(16,2);
	DEFINE mTotIvaComision		  MONEY(16,2);
	DEFINE mImporte				  MONEY(16,2);
	DEFINE mTotalaCobrar		  MONEY(16,2);
	                                 
	DEFINE cCuenta				  CHAR(20);
	DEFINE cTransacc			  CHAR(4);
	DEFINE cTransuc				  CHAR(4);
	DEFINE cConsecutivo			  CHAR(2);
	DEFINE cHoraActual			  DATETIME YEAR TO SECOND;
	DEFINE dFecha				  DATE;
	
	DEFINE cCategoria			  CHAR(2);
	DEFINE cConvenio              CHAR(3);
	DEFINE cNomrutinadv_ref1      CHAR(40);
	DEFINE cCodigoretorno         CHAR(5);
    DEFINE cIerrcomcodigo         CHAR(3);
	DEFINE cIerrcomsistema        CHAR(3);
	DEFINE cConfirma_pago         CHAR(1);
	
	DEFINE cMoneda		 	      CHAR(2); 
	DEFINE mMonto_serv			  MONEY(16,2); 
	DEFINE mMonto_cargoserv		  MONEY(16,2); 
	DEFINE cDescripcion			  CHAR(40); 
	DEFINE iMovto_serv			  INTEGER;
	DEFINE iMovto_cargoserv		  INTEGER;
	DEFINE cSucursal_bcpl         CHAR(4);
	DEFINE fFecha_actual		  DATE;
    DEFINE fFecha_actual_chq	  DATE;
	DEFINE cFechaFormat			  CHAR(8);
    DEFINE cFechaFormat_chq		  CHAR(8);
	DEFINE iContador              INTEGER;
	DEFINE cConciliacion		  CHAR(1);
	DEFINE cCategoriaConvenio	  CHAR(40);
	---------------------------------------
	--Variables para validar datos
	DEFINE vpTransaccion         CHAR(4);
	DEFINE vpCatCon			 	 CHAR(5);
	DEFINE vpSucursal_tienda 	 CHAR(4);
	DEFINE vpFormapago 			 CHAR(1);

	DEFINE vpCuenta_cargo         CHAR(12);
	DEFINE cLaborable			CHAR(1);						 

	LET vpTransaccion 		  = '';
	LET vpCatCon 		  	  = '';
	LET vpSucursal_tienda 	  = '';
	LET vpFormapago			  = '';
	--------------------------------------
	LET cCodRet               = "00000";
	LET cMensaje              = "Exitoso";
	LET cFolioSuc             = '';
	
	LET cCodRetTae			  ="00000";
	LET cFolioTae			  ='';

	LET deImpComisionConvenio = 0 ;
	LET deIvaComisionConvenio = 0 ;
	LET deImpComisionCliente  = 0 ;
	LET deIvaComisionCliente  = 0 ;
	LET cCodRet2			  = '';
	LET mTotComision		  = 0;
	LET mTotIVA				  = 0;
	LET mTotIvaComision		  = 0;
	LET mImporte			  = 0;
	LET mTotalaCobrar		  = 0;
	LET cCuenta				  = '';
	LET cTransacc			  = '';
	LET cTransuc			  = '';
	LET cConsecutivo		  = '';
	LET cHoraActual 		  = '';
	LET dFecha				  = '';
	
	LET cCategoria			  = '';
	LET cConvenio             = '';
	LET cNomrutinadv_ref1     = '';
	LET cCodigoretorno        = '';
    LET cIerrcomcodigo        = '';
	LET cIerrcomsistema       = '';
	LET cConfirma_pago        = '1';
	
	LET cMoneda		          = '';
	LET mMonto_serv		      = '';
	LET mMonto_cargoserv      = '';
	LET cDescripcion		  = '';
	LET iMovto_serv		      = '';   
	LET iMovto_cargoserv      = '';
	LET cSucursal_bcpl        = '';
	LET fFecha_actual         = '';
    LET fFecha_actual_chq     = '';
	LET cFechaFormat          = '';
    LET cFechaFormat_chq      = '';
	LET iContador 			  = 0;
	LET cConciliacion         = '';
	LET cCategoriaConvenio	  = '';
	LET vpCuenta_cargo 		  = ''; 
	LET cLaborable			  = "";					 
	
	--SET DEBUG FILE TO '/informix/Aaron/sp_aplica_pago_msw_hs.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error:sp_caplica_pago_msw";
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_aplica_pago_msw");
				
				SELECT id_sucursal, 'informix', folio_suc  
				  INTO cSucursal_bcpl, pCajero, cFolioSuc 
				  FROM sac_movimientoshistorial 
				 WHERE folio_suc = cFolioSuc;
				
				IF DBINFO('sqlca.sqlerrd2') <> 0 THEN 
					EXECUTE PROCEDURE "informix".sp_reversionsac('001', cSucursal_bcpl, pCajero, cFolioSuc ) INTO cCodRet;
				END IF;
				
				RETURN cCodRet, cMensaje, cFolioSuc;
            END IF;
        END EXCEPTION;

	    SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
		
		SELECT valor
		INTO cSucursal_bcpl
		FROM "informix".sac_param where cod_param = '9997';
		
		SELECT fecha_hoy INTO fFecha_actual 
		  FROM "informix".sac_fechas;

        SELECT fecha_hoy INTO fFecha_actual_chq
		  FROM bdicheq:"informix".sc_fechas;
		  
		
		
		LET cFechaFormat = YEAR(fFecha_actual) || LPAD(MONTH(fFecha_actual),2,0) || LPAD(DAY(fFecha_actual),2,0);
        LET cFechaFormat_chq = YEAR(fFecha_actual_chq) || LPAD(MONTH(fFecha_actual_chq),2,0) || LPAD(DAY(fFecha_actual_chq),2,0);
	
		IF pOrigen = "CPL" OR pOrigen = "BCPL" THEN
			INSERT INTO "informix".bitacora_aplicapago_hs
				VALUES (pOrigen,pTransaccion,pCategoria,pConvenio,pSucursal_tienda,pCajero,pCaja,pFecha,pHora,pFolio_peracion,pReferencia_1,pReferencia_2,pReferencia_3,
						pReferencia_4,pImporte,pFormapago,cConfirma_pago,current);
		END IF;		 
		
		IF pOrigen = "" OR pCategoria = "" OR pConvenio = "" OR pSucursal_tienda = "" OR 
		   pCajero = "" OR pImporte = "" THEN
			LET cCodRet = '00300';
			LET cMensaje = 'Error:sp_caplica_pago_msw';
            RETURN cCodRet, cMensaje, cFolioSuc;
		END IF;
		
		SELECT Laborable
		INTO cLaborable
		FROM bdinteg:"informix".si_feriado
		WHERE empresa = '001' AND pais = "001" AND fecha = mdy(SUBSTR(pFecha,5,2),SUBSTR(pFecha,7,2),SUBSTR(pFecha,1,4));
		
		IF NVL(cLaborable,"S") = "N" THEN
			LET pFecha = TO_CHAR(mdy(SUBSTR(pFecha,5,2),SUBSTR(pFecha,7,2),SUBSTR(pFecha,1,4)) + 1 UNITS DAY, '%Y%m%d');
		END IF;
		
		IF cFechaFormat <> pFecha or cFechaFormat_chq <> pFecha THEN
			LET cCodRet = '00301';
			LET cMensaje = 'Error:Actualizar fecha';
            RETURN cCodRet, cMensaje, cFolioSuc;
		END IF;
		
		IF pOrigen = "CPL" OR pOrigen = "BCPL" THEN	
		
		    SELECT conciliacion
    		INTO   cConciliacion
    		FROM   sac_servicios_cpl
    		WHERE  numcategoria = pCategoria  
    		AND    numconvenio  = pConvenio;
    		
    		IF cConciliacion != '1' OR cConciliacion IS NULL THEN
    			LET cCodRet = '00311';
    			LET cMensaje = 'Servicio no activo para Coppel';
                RETURN cCodRet, cMensaje, cFolioSuc;
		    END IF; 
		
			SELECT COUNT(*) INTO iContador
			  FROM "informix".sac_movimientos 
			 WHERE id_sucursal = cSucursal_bcpl 
			   AND origen = pOrigen AND sucursal_cpl = pSucursal_tienda   
			   AND referencia1 = pReferencia_1 AND fecha_pago = mdy(SUBSTR(pFecha,5,2),SUBSTR(pFecha,7,2),SUBSTR(pFecha,1,4))
			   AND caja_cpl = pCaja AND folio_operacion = pFolio_peracion 
			   AND status_cancelado = 'N';
			
			IF iContador > 0 THEN	
				LET cCodRet = '00303';
			    LET cMensaje = 'Folio operacion duplicado';
				RETURN cCodRet, cMensaje, cFolioSuc;
			END IF;	
		
			SELECT trans_cen_efectivo_cliente_cpl, cuenta_prestadora, imp_com_trans_conv, iva_convenio,  trans_suc_efectivo
			  INTO cTransacc, cCuenta, deImpComisionConvenio, deIvaComisionConvenio, cTransuc 
			  FROM "informix".sac_convenios 
			 WHERE numcategoria = pCategoria  
			   AND numconvenio = pConvenio;
		
			LET cCategoria = pCategoria;
		    LET cConvenio  = pConvenio;
		
				IF cCategoria = '02' AND cConvenio = '001' THEN 
					EXECUTE PROCEDURE "informix".sp_validadvtelmex(pReferencia_1, pReferencia_3) 
					   INTO cCodigoretorno, cIerrcomcodigo, cIerrcomsistema;
					LET pReferencia_2 = pReferencia_3;   
				ELIF cCategoria = '02' AND cConvenio = '003' THEN 
					EXECUTE PROCEDURE "informix".sp_axtel_validadv (pReferencia_1) 
					   INTO cCodigoretorno, cIerrcomcodigo;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 17 FOR 1);
				ELIF cCategoria = '04' AND cConvenio = '001' THEN 
					EXECUTE PROCEDURE "informix".sp_cfe_validadv (pReferencia_1,pImporte) 
					   INTO cCodigoretorno, cIerrcomcodigo;	
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 30 FOR 1);
				ELIF cCategoria = '06' AND cConvenio = '001' THEN 
					EXECUTE PROCEDURE "informix".sp_calculadvsky(pReferencia_1) 
					   INTO cCodigoretorno, cIerrcomcodigo, cIerrcomsistema;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 12 FOR 1);
				ELIF cCategoria = '06' AND cConvenio = '002' THEN  -- DISH 
					--LET pReferencia_1 = lpad(trim(pReferencia_1),14,'0');
					--EXECUTE PROCEDURE "informix".sp_calculadvdish(pReferencia_1) 
					--INTO cCodigoretorno, cIerrcomcodigo, cIerrcomsistema;
					--LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 13 FOR 1);
					LET cCodRet = '00555';
					LET cMensaje = 'Servicio no disponible';
					RETURN cCodRet, cMensaje, cFolioSuc;	
				ELIF cCategoria = '06' AND cConvenio = '003' THEN 
					EXECUTE PROCEDURE "informix".sp_calculadvmastv(pReferencia_1) 
					   INTO cCodigoretorno, cIerrcomcodigo, cIerrcomsistema;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 13 FOR 1);
				ELIF cCategoria = '06' AND cConvenio = '004' THEN 
					EXECUTE PROCEDURE "informix".sp_cablemas_validadv(pReferencia_1) 
					   INTO cCodigoretorno, cIerrcomcodigo;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 32 FOR 1);
				ELIF cCategoria = '06' AND cConvenio = '005' THEN 

					IF pOrigen = "CPL"  and instr(trim(pImporte),'.') > 0 THEN
						EXECUTE PROCEDURE "informix".sp_valida_dv_megacable_cpl(pReferencia_1, lpad(trim(replace(pImporte,'.','')),8,'0')) ---MEGACABLE
					   	INTO cCodigoretorno;
					ELSE
						EXECUTE PROCEDURE "informix".sp_valida_dv_megacable(pReferencia_1,trim(pImporte)) ---MEGACABLE
					   	INTO cCodigoretorno;
					END IF;

					   LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 26 FOR 1);

			    ELIF cCategoria = '08' AND cConvenio = '003' THEN 
					EXECUTE PROCEDURE "informix".sp_valida_dv_gobjalisco(pReferencia_1,pImporte) ---JALISCO
					   INTO cCodigoretorno;
					   LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 32 FOR 1);
				ELIF cCategoria = '08' AND cConvenio = '004' THEN 
					EXECUTE PROCEDURE "informix".sp_valida_dv_gobsinaloa(pReferencia_1,pImporte) ---SINALOA
					   INTO cCodigoretorno;	   
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 30 FOR 1);	
				ELIF cCategoria = '09' AND cConvenio = '001' THEN 
					EXECUTE PROCEDURE "informix".sp_calculadveci(pReferencia_1) 
					   INTO cCodigoretorno, cIerrcomcodigo, cIerrcomsistema;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 10 FOR 1);
				ELIF cCategoria = '09' AND cConvenio = '002' THEN 
					EXECUTE PROCEDURE "informix".sp_calculadvarabela(pReferencia_1) 
					   INTO cCodigoretorno, cIerrcomcodigo, cIerrcomsistema;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 8 FOR 1);
				ELIF cCategoria = '09' AND cConvenio = '003' THEN
					LET pReferencia_1 = lpad(trim(pReferencia_1),20,'0');				
					EXECUTE PROCEDURE "informix".sp_validarefavon(pReferencia_1, lpad(trim(replace(pImporte,'.','')),8,'0'))
					   INTO cCodigoretorno;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 19 FOR 2);
				ELIF cCategoria = '09' AND cConvenio = '004' THEN 
					EXECUTE PROCEDURE "informix".sp_validadvdyclass(pReferencia_1) 
					   INTO cCodigoretorno, cIerrcomcodigo, cIerrcomsistema;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 9 FOR 1);
				ELIF cCategoria = '09' AND cConvenio = '005' THEN 
					EXECUTE PROCEDURE "informix".sp_validadvcaminemos(pReferencia_1) 
					   INTO cCodigoretorno;
					LET pReferencia_2 = pReferencia_3;
				ELIF cCategoria = '09' AND cConvenio = '006' THEN 
					EXECUTE PROCEDURE "informix".sp_valida_dv_sukarne(pReferencia_1) 
					   INTO cCodigoretorno;
					LET pReferencia_2 = pReferencia_3;
				ELIF cCategoria = '09' AND cConvenio = '007' THEN 
					EXECUTE PROCEDURE "informix".sp_valida_dv_solfi(pReferencia_1) 
					   INTO cCodigoretorno;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 9 FOR 1);
				ELIF cCategoria = '09' AND cConvenio = '008' THEN 
					EXECUTE PROCEDURE "informix".sp_carnival_validadv(pReferencia_1) 
					   INTO cCodigoretorno;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 8 FOR 1);
				ELIF cCategoria = '09' AND cConvenio = '009' THEN 
					EXECUTE PROCEDURE "informix".sp_yvesrocher_valdv(pReferencia_1) 
					   INTO cCodigoretorno;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 15 FOR 1);
				ELIF cCategoria = '09' AND cConvenio = '010' THEN 
					EXECUTE PROCEDURE "informix".sp_valid_dv_stanhome(pReferencia_1) 
					   INTO cCodigoretorno;
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 9 FOR 1);
				ELIF cCategoria = '09' AND cConvenio = '011' THEN 
					EXECUTE PROCEDURE "informix".sp_japac_validadv(pReferencia_1) 
					   INTO cCodigoretorno, cIerrcomcodigo;	
					LET pReferencia_2 = SUBSTRING(pReferencia_1 FROM 22 FOR 1);
				END IF;
				
				IF cCodigoretorno <> '00000' THEN
					LET cCodRet = '00310';
					LET cMensaje = 'Referencia o DV incorrecto';
					RETURN cCodRet, cMensaje, cFolioSuc;
				END IF;
				
				EXECUTE PROCEDURE "informix".sp_obtienefoliocoppel_hs(RPAD(TRIM(pCajero),8,"00000000"),RPAD(TRIM(pHora),6,"000000"))
							 INTO cCodRet,cFolioSuc;

				IF cCodRet <> '00000' THEN
					LET cMensaje = 'Error:sp_obtienefoliocoppel_hs';
					LET cFolioSuc = '';
					RETURN cCodRet, cMensaje, cFolioSuc;
				END IF;  
			
				LET	dFecha = mdy(SUBSTR(pFecha,5,2),SUBSTR(pFecha,7,2),SUBSTR(pFecha,1,4));
				LET deIvaComisionConvenio = round (deImpComisionConvenio * (deIvaComisionConvenio/100),2);
			
				IF pCategoria||pConvenio = '02003' OR pCategoria||pConvenio = '04001' OR pCategoria||pConvenio = '06004' OR pCategoria||pConvenio = '09011' THEN
					EXECUTE PROCEDURE "informix".sp_grabapagoservicio_hs(cSucursal_bcpl, pCategoria, pConvenio, pReferencia_1, pReferencia_2, pFormapago, pImporte, deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, '', pCajero, cFolioSuc, cTransuc, dFecha, pOrigen, pSucursal_tienda, pCaja, pTransaccion, pHora, pFolio_peracion, pReferencia_3, pReferencia_4)
								 INTO cCodRet;
					IF cCodRet = '00000' THEN 
                          LET cMensaje = 'Exitoso';
					ELSE 
						IF cCodRet = '00060' OR cCodRet = '00061' OR cCodRet = '00062' OR cCodRet = '00063' OR cCodRet = '00064' THEN
							LET cMensaje = 'Error:Verificar cierre cheques';
						ELSE
							LET cMensaje = 'Error:sp_grabapagoservicio_hs';
							 UPDATE "informix".bitacora_aplicapago_hs SET confirma_pago = '0' 
                              WHERE (categoria = pCategoria AND convenio = pConvenio AND folio_operacion = pFolio_peracion);
						END IF;						
					END IF;
				
				ELSE
					EXECUTE PROCEDURE "informix".sp_grabapagoservicio_hs(cSucursal_bcpl, pCategoria, pConvenio, pReferencia_1, pReferencia_2, pFormapago, pImporte, deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, '', pCajero, cFolioSuc, cTransuc, dFecha, pOrigen, pSucursal_tienda, pCaja, pTransaccion, pHora, pFolio_peracion, pReferencia_3, pReferencia_4)
					INTO cCodRet;
					IF cCodRet = '00000' THEN
						EXECUTE PROCEDURE bdicheq:"informix".abono_ref('001', cSucursal_bcpl, pCajero, cTransacc, cTransuc, cFolioSuc, cCuenta, 0, pImporte, pImporte, 0, 0, 0, '01', 'Abono Homologacion', '', '') INTO cCodRet;				
					ELSE
						IF cCodRet = '00060' OR cCodRet = '00061' OR cCodRet = '00062' OR cCodRet = '00063' OR cCodRet = '00064' THEN
							LET cMensaje = 'Error:Verificar cierre cheques';
							LET cFolioSuc = '';
							RETURN cCodRet, cMensaje, cFolioSuc;
						ELSE
							LET cMensaje = 'Error:sp_aplica_pago_msw(sp_grabapagoservicio_hs)';
							LET cFolioSuc = '';
							RETURN cCodRet, cMensaje, cFolioSuc;
						END IF;
					END IF;
				
					IF cCodRet = '000' THEN 
					
						/* Foreach	
							EXECUTE PROCEDURE bdicheq:"informix".sp_mini21('001',pCajero,cSucursal_bcpl,cFolioSuc) 
							 INTO cCodRet, cMoneda, mMonto_serv, mMonto_cargoserv, cDescripcion, iMovto_serv, iMovto_cargoserv
						end foreach;

						IF cCodRet = '00000' THEN  */											  
							EXECUTE PROCEDURE "informix".sp_confpagoservicio (cSucursal_bcpl, pCategoria, pConvenio, pReferencia_1, pReferencia_2, cFolioSuc) INTO cCodRet, cMensaje;
							IF cCodRet = '00000' THEN
								LET cMensaje = 'Exitoso';
							ELSE
								LET cMensaje = 'Error:sp_aplica_pago_msw(sp_confpagoservicio)';
								UPDATE "informix".bitacora_aplicapago_hs SET confirma_pago = '0' 
								 WHERE (categoria = pCategoria AND convenio = pConvenio AND folio_operacion = pFolio_peracion);
							END IF;
						/* ELSE
							EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucursal_bcpl, pCajero, cFolioSuc, '') INTO cCodRet;
							IF cCodRet = '000' THEN
								LET cCodRet = '00000';
							END IF;
							LET cMensaje = 'Error:sp_aplica_pago_msw(DESCUADRE)';
							RETURN cCodRet, cMensaje, cFolioSuc;
						END IF; */
					ELSE
						LET cMensaje = 'Error:sp_aplica_pago_msw (abono_ref)';
						LET cFolioSuc = '';
						RETURN cCodRet, cMensaje, cFolioSuc;
					END IF;	
					
				END IF;
		ELIF pOrigen = "bex" OR pOrigen = "BEX" THEN

			--Valindaciones
			-- Numero de Transaccion
			SELECT numero INTO vpTransaccion FROM bdinteg:"informix".si_transacc where numero = pTransaccion;
			-- Numero de Sucursal
			SELECT sucursal INTO vpSucursal_tienda FROM bdinteg:"informix".si_sucursales where sucursal = pSucursal_tienda;
			-- Categoria y Convenio 
			SELECT (numcategoria || numconvenio) INTO vpCatCon FROM "informix".sac_convenios where numcategoria = pCategoria AND numconvenio = pConvenio;

			IF pFormapago <> "2" OR vpTransaccion IS NULL OR vpSucursal_tienda IS NULL OR vpCatCon IS NULL THEN
				LET cCodRet = '00304';
				LET cMensaje = 'Error:Parametros de entrada con valor incorrecto ';
				RETURN cCodRet, cMensaje, cFolioSuc;
			END IF;

			SELECT COUNT(*) INTO iContador
				FROM "informix".sac_movimientos 
			WHERE id_sucursal = pSucursal_tienda 
				AND origen = pOrigen  
				AND referencia1 = pReferencia_1 AND fecha_pago = mdy(SUBSTR(pFecha,5,2),SUBSTR(pFecha,7,2),SUBSTR(pFecha,1,4))
				AND caja_cpl = pCaja AND folio_operacion = pFolio_peracion;
				
			
			IF iContador > 0 THEN	
				LET cCodRet = '00303';
			    LET cMensaje = 'Folio operacion duplicado';
				RETURN cCodRet, cMensaje, pFolio_peracion;
			END IF;
			
			IF cCategoria = '03' THEN
				LET cCategoriaConvenio = 'TA_'||pCategoria||pConvenio||'_';
			ELSE 
				LET cCategoriaConvenio = 'PS_'||pCategoria||pConvenio||'_';
			END IF;
		
			SELECT trans_cen_abono_convenio, cuenta_prestadora, imp_com_trans_conv, iva_convenio,  trans_suc_efectivo
			  INTO cTransacc, cCuenta, deImpComisionConvenio, deIvaComisionConvenio, cTransuc 
			  FROM "informix".sac_control_convenios_canales 
			WHERE numcategoria = pCategoria  
			   AND numconvenio = pConvenio
			   AND canal = pOrigen;
						
			LET	dFecha = mdy(SUBSTR(pFecha,5,2),SUBSTR(pFecha,7,2),SUBSTR(pFecha,1,4));
			LET deIvaComisionConvenio = round (deImpComisionConvenio * (deIvaComisionConvenio/100),2);
			LET cFolioSuc = pFolio_peracion;
			
			SELECT FIRST 1 cuenta into vpCuenta_cargo FROM bdicheq:"informix".sc_movdia WHERE folio_suc = cFolioSuc;
			
			EXECUTE PROCEDURE "informix".sp_grabapagoservicio_hs(pSucursal_tienda, pCategoria, pConvenio, pReferencia_1, pReferencia_2, pFormapago, pImporte, deImpComisionConvenio, 
			deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, vpCuenta_cargo, pCajero, pFolio_peracion, cTransacc, dFecha, pOrigen, pSucursal_tienda, pCaja, pTransaccion, pHora, 
			pFolio_peracion, pReferencia_3, pReferencia_4)
			INTO cCodRet;
			
			IF cCodRet = '00000' THEN
				EXECUTE PROCEDURE bdicheq:"informix".abono_ref('001', pSucursal_tienda, pCajero, cTransacc, cTransacc, pFolio_peracion, cCuenta, 0, pImporte, pImporte, 0, 0, 0, '01', TRIM(cCategoriaConvenio)||TRIM(pFolio_peracion)||'_'||TRIM(pReferencia_4), '', '') INTO cCodRet;				
			ELSE
				IF cCodRet = '00060' OR cCodRet = '00061' OR cCodRet = '00062' OR cCodRet = '00063' OR cCodRet = '00064' THEN
					LET cMensaje = 'Error:Verificar cierre cheques';
					RETURN cCodRet, cMensaje, pFolio_peracion;
				ELSE
					LET cMensaje = 'Error:sp_aplica_pago_msw(sp_grabapagoservicio_hs)';
					RETURN cCodRet, cMensaje, pFolio_peracion;
				END IF;
			END IF;

			IF cCodRet = '000' THEN 
				/* Foreach	
					EXECUTE PROCEDURE bdicheq:"informix".sp_mini21('001',pCajero,pSucursal_tienda,pFolio_peracion) 
					INTO cCodRet, cMoneda, mMonto_serv, mMonto_cargoserv, cDescripcion, iMovto_serv, iMovto_cargoserv
				END foreach;

				IF cCodRet = '00000' THEN 											  
					LET cMensaje = 'Exitoso';
					LET cFolioSuc = pFolio_peracion;
				ELSE
					EXECUTE PROCEDURE bdicheq:"informix".reversion('001', pSucursal_tienda, pCajero, pFolio_peracion, '') INTO cCodRet;
					IF cCodRet = '000' THEN
						LET cCodRet = '00320';
						LET cMensaje = 'Error:"Reversado"-sp_aplica_pago_msw(DESCUADRE)';
					ELSE
						LET cMensaje = 'Error:sp_aplica_pago_msw(DESCUADRE)';
					END IF;
					RETURN cCodRet, cMensaje, pFolio_peracion;
				END IF; */
				LET cCodRet = '00000';
				LET cMensaje = 'Exitoso';
				LET cFolioSuc = pFolio_peracion;
			ELSE
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', pSucursal_tienda, pCajero, pFolio_peracion, '') INTO cCodRet;
					IF cCodRet = '000' THEN
						LET cCodRet = '00320';
						LET cMensaje = 'Error:"Reversado"-sp_aplica_pago_msw';
					ELSE
						LET cMensaje = 'Error:sp_aplica_pago_msw(DESCUADRE)';
					END IF;
					RETURN cCodRet, cMensaje, pFolio_peracion;
				--LET cMensaje = 'Error:sp_aplica_pago_msw (abono_ref)';
				--RETURN cCodRet, cMensaje, pFolio_peracion;
			END IF;	
			IF trim(trim(pCategoria)||trim(pConvenio)) = '03001' THEN
				Execute Procedure sp_obtienefolio_tae() INTO cCodRetTae, cFolioTae;
				Let cMensaje = trim(cMensaje)||'|'||trim(cFolioTae);
			END IF;	
		ELSE
			LET cCodRet = '00302';
			LET cMensaje = 'Origen Desconocido';
            RETURN cCodRet, cMensaje, cFolioSuc;

		END IF;
		RETURN cCodRet, cMensaje, cFolioSuc;
	END;
	
END PROCEDURE;