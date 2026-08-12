CREATE PROCEDURE "informix".sp_consflag_respuesta (pMensaje CHAR(5),pCod_interact CHAR(5),pCod_WS CHAR(4),pCod_detail CHAR(4))
RETURNING CHAR(6) AS Cod_ret, CHAR(1) AS flag

--	DECLARA VARIABLES
DEFINE cCod_ret CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cFlag CHAR(1);
DEFINE cFlagint CHAR(1);
DEFINE cFlagrev CHAR(1);
--	INICIALIZA VARIABLES
LET iSqlErr = 0;
LET cCod_ret = '000000';
LET cFlag = '0';
LET cFlagint = '0';
LET cFlagrev = '0';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_consflag_respuesta.out";
--TRACE ON; 
BEGIN
-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		LET cCod_ret = iSqlErr;
		LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	END EXCEPTION;

	-- VALIDACIÓN DE PARÁMETROS
	
	IF NVL(pMensaje,'') = ''THEN
			LET cCod_ret = '000001';
			LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	END IF
	
	IF ( NVL(pCod_interact,'') = ''  OR pCod_interact::INT= 0) AND NVL(pCod_WS,'') = '' OR NVL(pCod_detail,'') = ''  THEN
		LET cCod_ret = '000000';
		LET cFlag = '1';
		RETURN cCod_ret,cFlag;
	ELIF pCod_interact::INT <> 0 then
		LET cCod_ret = '000002';
		LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	
	END IF
	
	LET pMensaje = UPPER(pMensaje);
	
	SELECT flag_rev,flag_intento
	INTO cFlagint,cFlagrev
	FROM bdisac:"informix".sac_app_cat_mensajesdetail
	WHERE agent_trans_type_code = TRIM(pMensaje)
	AND opcode= TRIM (pCod_WS)
	AND opcode_detail = TRIM (pCod_detail);
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCod_ret = '000003';
		LET cFlag = '1';
		RETURN cCod_ret,cFlag;
	END IF
	
	IF cFlagint::INT = 1 or cFlagrev::INT = 1 THEN
		LET cFlag = '1';
	END IF
	
	RETURN cCod_ret,cFlag;
	
END
END PROCEDURE
DOCUMENT
'AUTOR:95358919 - MARIO OLIVO',
'FOLIO:95',
'DESCRIPCION: el SP regresa el flag ya sea para mandar a reversar o bien intentar el reverso.',
'FECHA:2016/07/26',
'SOLICITA:Leonardo Hernandez',
'RQM: Adendum',
'VERSION:20160726.1752',
'BD:bdisac';

CREATE PROCEDURE "informix".sp_insertaconciliaciontotalporconvenio()
RETURNING
CHAR(5)         AS retorno;

    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
	DEFINE cCodRet              CHAR(5);
	DEFINE vconsmovhis          CHAR(10);
	DEFINE cTranCredPGDF   	    CHAR(5);	
	DEFINE cTranCredPEDOF   	    CHAR(5);	
	DEFINE cTranCredPCP   	    CHAR(5);
    DEFINE cNomConvenio         CHAR(40);	
	DEFINE cConvenio         	CHAR(5);
	DEFINE cConv 		        CHAR(3);
    DEFINE cCateg       	    CHAR(2);
	DEFINE cCuenta_contable     CHAR(30);
	DEFINE cCuenta_cheques      CHAR(30);
	DEFINE iProceso_automatico  INTEGER;
	DEFINE iTransCargoCuenta    INTEGER;
	DEFINE cNumTransaccEfec     CHAR(4);
    DEFINE cNumTransaccEfec_cpl CHAR(4);
	DEFINE cNumCargoClien		CHAR(4);
	DEFINE deImporte_archivo    DECIMAL(16,2);
	DEFINE dFecha_pago          DATE;
	DEFINE mCargoCuenta         MONEY(16,2);
	DEFINE deImporte_conta      DECIMAL(16,2);
	DEFINE cIdSucursal			CHAR(4);
	DEFINE iNumPagos            INTEGER;
	DEFINE mImpComisionConvenio    MONEY(16,2);
	DEFINE mIVAComisionConvenio    MONEY(16,2);
	DEFINE mImpComisionCte         MONEY(16,2);
	DEFINE mIVAComisionCte         MONEY(16,2);
	DEFINE iConfirmacionCentral     INTEGER;
	DEFINE iConfirmacionSucursal    INTEGER;
	DEFINE dFechaTransfer			DATE;
	DEFINE vmax_fechaold            DATE;	
	DEFINE cDescripcionSPJ	 CHAR(100);
	DEFINE cConvenTransfer	CHAR (120);
	DEFINE cConvenTransfer2 CHAR (120);
			
	LET cCodRet  =   "00000";	
	LET cTranCredPGDF       = '';
    LET cTranCredPEDOF      = '';
	LET cTranCredPCP		= '';
	LET cNomConvenio  = "";
	LET cConvenio  = "";
	LET cConv   = "";
    LET cCateg  = "";
	LET cCuenta_contable  = "";
	LET cCuenta_cheques   = "";
	LET iProceso_automatico  = 0;
	LET iTransCargoCuenta = 0;
	LET cNumTransaccEfec  = '';
	LET cNumTransaccEfec_cpl  = '';
	LET cNumCargoClien	  = '';
	LET deImporte_archivo = 0;	
	LET dFecha_pago  = "01-01-1990";	
	LET mCargoCuenta      = 0;
	LET deImporte_conta   = 0;
	LET cIdSucursal           = "";
	LET iNumPagos             = 0;
	LET mImpComisionConvenio = 0;
	LET mIVAComisionConvenio = 0;
	LET mImpComisionCte      = 0;
	LET mIVAComisionCte      = 0;
	LET iConfirmacionCentral  = 0;
	LET iConfirmacionSucursal = 0;
	LET dFechaTransfer		= '01-01-1990';
	LET vmax_fechaold    = '';	
	LET cDescripcionSPJ	 = 'Inserta totales para reporte de SOC conciliacion total por convenio';	
	LET cConvenTransfer = '';
	LET cConvenTransfer2 = '';

	--SET DEBUG FILE TO  '/informix/yuri/convenios/sp_insertaconciliaciontotalporconvenioyu.out';
	--TRACE ON;
		
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_insertaconciliaciontotalporconvenio");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;	

		SELECT fecha_hoy-1
		INTO dFecha_pago
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = "001";			
		
		SELECT valor INTO vconsmovhis FROM bdicheq:"informix".sc_param WHERE codparam = 'fechcon_movhis' AND  empresa = '001';
		SELECT valor INTO cTranCredPGDF FROM bdisac:"informix".sac_param WHERE cod_param = '87040';
		SELECT valor INTO cTranCredPEDOF FROM bdisac:"informix".sac_param WHERE cod_param = '25';
		
		--INSERTA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_CTC_S', dFecha_pago, '0', 'informix', 'sp_insertaconciliaciontotalporconvenio', cDescripcionSPJ);

		--HOMOLOGACION CLUB DE PROTECCION COPPEL
		SELECT valor INTO cTranCredPCP FROM bdisac:"informix".sac_param WHERE cod_param = 82;
        FOREACH			
            SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
                   NVL(cuenta_prestadora,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), 
                   NVL(trans_cen_efectivo_cliente,''),NVL(trans_cen_efectivo_cliente_cpl,''), NVL(trans_cen_cargo_cliente,'')
              INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, cCuenta_cheques, 
				   iProceso_automatico, iTransCargoCuenta, cNumTransaccEfec,cNumTransaccEfec_cpl, cNumCargoClien 
              FROM bdisac:"informix".sac_convenios
             WHERE numcategoria || numconvenio <> '08002'
             UNION 
            SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
                   NVL(valor,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), 
                   NVL(trans_cen_efectivo_cliente,''), NVL(trans_cen_efectivo_cliente_cpl,''), NVL(trans_cen_cargo_cliente,'')
              FROM bdisac:"informix".sac_convenios, bdisac:sac_param
             WHERE numcategoria || numconvenio = '08002'
               AND cod_param IN ('30','31','32','33','34')
             ORDER BY nomconvenio	
				
								
				IF cCateg = '10' THEN				
					FOREACH
						SELECT SUM(importe_pago), id_sucursal, COUNT(referencia1), SUM(importe_comision_convenio), SUM(iva_comision_convenio),
							SUM(importe_comision_cte), SUM(iva_comision_cte), SUM(flag_confirmacion_central), SUM(flag_confirmacion_sucursal)
						INTO deImporte_archivo, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
							iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_movimientoshistorial
						WHERE fecha_pago = dFecha_pago-1
						AND numcategoria = cCateg 
						AND numconvenio = cConv			
						AND status_cancelado = 'N'
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY id_sucursal
						ORDER BY id_sucursal	
					
						SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE fech_alt = dFecha_pago-1
						AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec)
						AND cuenta = cCuenta_cheques
						AND usuario = 'systrans';
						
						IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_conciliaciontotalporconvenio where numcategoria=cCateg and numconvenio=cConv and fecha_pago=dFecha_pago-1 and id_sucursal=cIdSucursal) THEN
							INSERT INTO bdisac:"informix".sac_conciliaciontotalporconvenio (retorno, numcategoria, numconvenio, nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, id_sucursal, numpagos, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal)
							VALUES (cCodRet, cCateg, cConv, cNomConvenio, dFecha_pago-1, deImporte_archivo, cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal);									
						END IF;	
					END FOREACH;
				ELSE			
					FOREACH
						--Se calcula el total de los movimientos por sucursal
						SELECT SUM(importe_pago), id_sucursal, COUNT(referencia1), SUM(importe_comision_convenio), SUM(iva_comision_convenio),
							SUM(importe_comision_cte), SUM(iva_comision_cte), SUM(flag_confirmacion_central), SUM(flag_confirmacion_sucursal)
						INTO deImporte_archivo, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
							iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_movimientoshistorial
						WHERE fecha_pago = dFecha_pago
						AND numcategoria = cCateg 
						AND numconvenio = cConv			
						AND status_cancelado = 'N'
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY id_sucursal
						ORDER BY id_sucursal	

						IF cCateg = '08' AND cConv = '002' THEN
							LET deImporte_archivo = 0;
							LET deImporte_archivo = ( SELECT  SUM(importe_pago)
													  FROM bdisac:"informix".sac_movimientoshistorial a, bdisac:sac_edomex_cuentas b
													 WHERE a.fecha_pago = dFecha_pago
													   AND a.numcategoria = cCateg 
													   AND a.numconvenio = cConv			
													   AND a.status_cancelado = 'N'
													   AND a.flag_confirmacion_central = 1 
													   AND a.flag_confirmacion_sucursal = 1
													   AND substr(referencia1,1,6) = prefijo
													   AND cuenta = cCuenta_cheques
													   group by cuenta);                                       
												 
					   END IF;
						--Se calcula el Total de Cheques por sucursal
						--Pago de Remesas
						IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
							SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis
							WHERE fech_alt = dFecha_pago
							AND cancelad <> 'S' AND transacc IN(cNumCargoClien, cNumTransaccEfec)
							AND cuenta = cCuenta_cheques
							AND sucursal = cIdSucursal;					
						ELSE --Club de Proteccion
							IF cConvenio = "01002" THEN
								SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
								FROM bdicheq:"informix".sc_movhis
								WHERE fech_alt = dFecha_pago
								AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
								AND cuenta = cCuenta_cheques
								AND sucursal = cIdSucursal;					
							ELSE --GDF
								IF cConvenio = "08001" THEN
									SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' AND transacc IN(cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;	
								ELIF cConvenio = "08002" THEN
									SELECT NVL(SUM(monto_tot), 0) 
									INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' 
									AND transacc IN(cTranCredPEDOF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;								
								ELSE --Todos los demas convenios que no sean Orden de Pago y Transfer									
									IF cConvenio NOT IN ("07001" ,"07002", "07003") AND cCateg <> '10' THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis
										WHERE fech_alt = dFecha_pago
										AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec, cNumTransaccEfec_cpl)
										AND cuenta = cCuenta_cheques
										AND sucursal = cIdSucursal;
									ELSE --Es un Envio, Cobro o Cancelacion de Orden de Pago
										LET mCargoCuenta = 0;
									END IF;								
								END IF;
							END IF;			
						END IF;			

					INSERT INTO bdisac:"informix".sac_conciliaciontotalporconvenio (retorno, numcategoria, numconvenio, nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, id_sucursal, numpagos, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal)
					VALUES (cCodRet, cCateg, cConv, cNomConvenio, dFecha_pago, deImporte_archivo, cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal);									
						
					END FOREACH;			
					--Sumar al total de cheques los que en movimientos tienen algun flag en 0
					FOREACH
						SELECT SUM(importe_pago), id_sucursal, COUNT(referencia1), SUM(importe_comision_convenio), SUM(iva_comision_convenio),
							SUM(importe_comision_cte), SUM(iva_comision_cte), SUM(flag_confirmacion_central), SUM(flag_confirmacion_sucursal)
						INTO deImporte_archivo, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
							iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_movimientoshistorial
						WHERE fecha_pago = dFecha_pago
						AND numcategoria = cCateg AND numconvenio = cConv			
						AND status_cancelado = 'N'
						AND (flag_confirmacion_central = 0
						OR flag_confirmacion_sucursal = 0)
						GROUP BY id_sucursal
						ORDER BY id_sucursal	
						IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
							SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis
							WHERE fech_alt = dFecha_pago
							AND cancelad <> 'S' AND transacc IN(cNumCargoClien, cNumTransaccEfec)
							AND cuenta = cCuenta_cheques
							AND sucursal = cIdSucursal;					
						ELSE --Club de Proteccion
							IF cConvenio = "01002" THEN
								SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
								FROM bdicheq:"informix".sc_movhis
								WHERE fech_alt = dFecha_pago
								AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
								AND cuenta = cCuenta_cheques
								AND sucursal = cIdSucursal;					
							ELSE --GDF
								IF cConvenio = "08001" THEN
									SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' AND transacc IN(cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;	
								 ELIF cConvenio = "08002" THEN
									SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' 
									AND transacc IN(cTranCredPEDOF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;								
								ELSE --Todos los demas convenios que no sean Orden de Pago y Transfer
									IF cConvenio NOT IN ("07001" ,"07002", "07003") AND cCateg <> '10' THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis
										WHERE fech_alt = dFecha_pago
										AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec,cNumTransaccEfec_cpl)
										AND cuenta = cCuenta_cheques
										AND sucursal = cIdSucursal;
									ELSE --Es un Envio, Cobro o Cancelacion de Orden de Pago
										LET mCargoCuenta = 0;
									END IF;
								END IF;
							END IF;			
						END IF;
						
						IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_conciliaciontotalporconvenio where numcategoria=cCateg and numconvenio=cConv and fecha_pago=dFecha_pago and id_sucursal=cIdSucursal) THEN
							INSERT INTO bdisac:"informix".sac_conciliaciontotalporconvenio (retorno, numcategoria, numconvenio, nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, id_sucursal, numpagos, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal)
							VALUES (cCodRet, cCateg, cConv, cNomConvenio, dFecha_pago, 0, cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta, cIdSucursal, iNumPagos, 0, 0, 0, 0, iConfirmacionCentral, iConfirmacionSucursal);												
						END IF;					
					END FOREACH;
				END IF;
		END FOREACH;		
		--INSERTA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_CTC_S', dFecha_pago, '1', 'informix', 'sp_insertaconciliaciontotalporconvenio', cDescripcionSPJ);
		RETURN cCodRet;
	END;		
END PROCEDURE;