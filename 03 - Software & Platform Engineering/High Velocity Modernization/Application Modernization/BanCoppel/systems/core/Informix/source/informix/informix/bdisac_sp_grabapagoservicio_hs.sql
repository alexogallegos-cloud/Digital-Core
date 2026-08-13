CREATE PROCEDURE "informix".sp_grabapagoservicio_hs(cSucursal CHAR (4), cCategoria CHAR (2), cConvenio CHAR(5), cReferencia1 CHAR (40), cReferencia2 CHAR (40),cFormaPago CHAR (1), deImportePago DECIMAL (10,2), deImpComisionConvenio DECIMAL (6,2),deIvaComisionConvenio DECIMAL (6,2), deImpComisionCliente DECIMAL (6,2), deIvaComisionCliente DECIMAL (6,2), cCuentaCargo CHAR (12),cUsuario CHAR(8),cFolio_suc CHAR (16), cTransacc_suc CHAR(4), dFechaPago DATE, cOrigen CHAR(4), pSucursal_cpl CHAR(4), pCaja CHAR(3), cTransaccion CHAR(5), cHora CHAR(6), cFolio_Operacion CHAR(18), cReferencia_3 CHAR(40), cReferencia_4 CHAR(40))

RETURNING CHAR(5);

-- Definicion de Variables
    DEFINE cCodRet          CHAR(5);
	DEFINE pCodRet			CHAR(5);
    DEFINE vcSucursal       CHAR(4);
    DEFINE iSql_err         INT;
    DEFINE iFlgConfCen      INT;
    DEFINE iFlgConfSuc      INT;
    DEFINE vcSucursalBPI    CHAR(10);
	DEFINE cSucursalCentBTS CHAR (4);
	--DEFINE cRef1			CHAR(20); -- NMR-15/10/2019- Variable sin utilizar
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
	DEFINE cInfoErr         CHAR(100);
	DEFINE cContador        SMALLINT;
	DEFINE CdRetVerSis      CHAR (5);
	DEFINE IndCrreCred      CHAR (1);
	DEFINE IndDispCred      CHAR (1);
	DEFINE IndCrreChqs      CHAR (1);
	DEFINE IndDispChqs      CHAR (1);
	DEFINE IndCrreInvs      CHAR (1);
	DEFINE IndDispInvs      CHAR (1);
	DEFINE IndCrreSrvs      CHAR (1);	
	DEFINE cSucCreditoCentBTS CHAR (4);
	DEFINE cSucursalCentApp CHAR(4);
	DEFINE cSucCreditoCentApp CHAR (4);
	--DSB 21/03/2017
	DEFINE cExisteTrx		CHAR(20);
	DEFINE cFolioSucAnt		CHAR(20);
	DEFINE v_nombre1			VARCHAR(40);
	DEFINE v_nombre2			VARCHAR(40);
	DEFINE v_appaterno			VARCHAR(40);
	DEFINE v_apmaterno			VARCHAR(40);
	DEFINE v_fecha_nac			DATE;
	DEFINE v_rfc				VARCHAR(13);
	DEFINE v_moneda_origen		CHAR(3);
	DEFINE v_importe_origen		MONEY;
	DEFINE v_cta_benef			VARCHAR(20);
	DEFINE vvRemesaPagada		INTEGER; --NMR04JUN19
	DEFINE dFechaHoy			DATE;

-- Inicializa variables
     LET cCodRet            = "00000";
     LET iSql_err           = 0;
     LET vcSucursal         = "";
     LET iFlgConfCen        = 1;
     LET iFlgConfSuc        = 1;
     LET vcSucursalBPI      = "";
	 LET cSucursalCentBTS   = "";
	 --LET cRef1				=""; -- NMR-15/10/2019- Variable sin utilizar
     LET iSqlErr     		= 0;
     LET iIsamErr    		= 0;
	 LET cInfoErr    		= '';
     LET cContador          = 0;
	 LET CdRetVerSis		= '';
	 LET IndCrreCred 	    = '';
	 LET IndDispCred 		= '';
	 LET IndCrreChqs 		= '';
	 LET IndDispChqs 		= '';
	 LET IndCrreInvs 		= '';
	 LET IndDispInvs 		= '';
	 LET IndCrreSrvs 		= '';
	 LET cSucCreditoCentBTS = '';
	 LET cSucursalCentApp	= '';
	 LET cSucCreditoCentApp = '';
	 --DSB 21/03/2017
	 LET cExisteTrx 		= '';
	 LET cFolioSucAnt		= '';
	LET v_nombre1				= '';
	LET v_nombre2				= '';
	LET v_appaterno				= '';
	LET v_apmaterno				= '';
	LET v_fecha_nac				= '';
	LET v_rfc					= '';
	LET v_moneda_origen			= '';
	LET v_importe_origen		= 0;
	LET v_cta_benef				= '';
	LET	pCodRet					= '00000';
	LET vvRemesaPagada			= 0; --NMR04JUN19
	LET dFechaHoy				= '';
	
	 
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO '/informix/noe/sp_grabapagoserviciohs.out';
	--TRACE ON;

	-- OBTIENE LA SUCURSAL DE PAGOS PROGRAMADOS y BPI
    SELECT valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
    --SELECT valor INTO vcSucursalBPI FROM bdiprog:"informix".pp_parametros WHERE cve_param = '22';
	SELECT cSucursal INTO vcSucursalBPI FROM bdinteg:"informix".si_canales WHERE cc_canal IN ('5003','5007','5008') AND cc_canal=cSucursal;
	SELECT valor INTO cSucursalCentBTS FROM bdisac:"informix".sac_param WHERE cod_param = '87015';
	SELECT valor INTO cSucCreditoCentBTS FROM bdisac:"informix".sac_param WHERE cod_param = '87023';

	--Obtener folio_sucursal appriza
	SELECT valor INTO cSucursalCentApp FROM bdisac:"informix".sac_param WHERE cod_param = '87112';
	SELECT valor INTO cSucCreditoCentApp FROM bdisac:"informix".sac_param WHERE cod_param = '87130';
	
	
	-- SI EL PAGO LLEGO POR CENTRAL DE PGPRO o BPI NO SE CONFIRMA EN SUCURSAL
	IF cSucursal = vcSucursal OR cSucursal = vcSucursalBPI OR cSucursal= cSucursalCentBTS THEN
		LET iFlgConfSuc = 1;
	END IF;

    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSql_err, iIsamErr, TRIM(cInfoErr) || ' ' || cFolio_suc, "sp_grabapagoservicio_hs");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

--	2013.11.01 FRG-i - Se identifica el tipo de servicio a pagar, para validar los sistemas relacionados:
	EXECUTE FUNCTION bdinteg:verifica_sistemas() -- Se validan cierres de los sistemas antes de iniciar proceso de PGPROG:
	INTO CdRetVerSis, IndCrreCred, IndDispCred, IndCrreChqs, IndDispChqs, IndCrreInvs, IndDispInvs, IndCrreSrvs;

	-- Se valida que la fecha concuerde con la dia actual
	SELECT fecha_hoy INTO dFechaHoy 
	FROM sac_fechas WHERE empresa = '001';
			
		IF dFechaHoy <> dFechaPago THEN
			LET cCodRet = '01241';
			LET iSqlErr = 0;
			LET iIsamErr = 0;
			LET cInfoErr = 'LA FECHA DEL SISTEMA Y DE CENTRAL SON DIFERENTES' || ' ' || cSucursal;
			EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
			RETURN cCodRet;
		END IF;
		
--	Abonos Coppel (solo bdisac):
		if cCategoria = '01' and cConvenio = '001'
			then
				if IndCrreSrvs <> '1'
					then
						LET cCodRet = '00060';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Servicios No Disponible.';
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
						RETURN cCodRet;
					else
				end if;
			else
		end if;

--	TELMEX (bdisac - bdicheq):
		if cCategoria = '02' and cConvenio = '001'
			then
				if IndCrreSrvs <> '1'
					then
						LET cCodRet = '00060';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Servicios No Disponible.';
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
						RETURN cCodRet;
					else
						if IndCrreChqs <> '1'
							then
								LET cCodRet = '00061';
								LET iSqlErr = 0;
								LET iIsamErr = 0;
								LET cInfoErr = 'Sistema Cheques No Disponible.';
								EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
								RETURN cCodRet;
							else
								if IndDispChqs <> '1'
									then
										LET cCodRet = '00062';
										LET iSqlErr = 0;
										LET iIsamErr = 0;
										LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
										EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
										RETURN cCodRet;
									else
								end if;
						end if;
				end if;
			else
		end if;

--	DISH/MASTV/SKY (bdisac - bdicheq):
		if cCategoria = '06' and cConvenio between '001' and '003'
			then
				if IndCrreSrvs <> '1'
					then
						LET cCodRet = '00060';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Servicios No Disponible.';
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
						RETURN cCodRet;
					else
						if IndCrreChqs <> '1'
							then
								LET cCodRet = '00061';
								LET iSqlErr = 0;
								LET iIsamErr = 0;
								LET cInfoErr = 'Sistema Cheques No Disponible.';
								EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
								RETURN cCodRet;
							else
								if IndDispChqs <> '1'
									then
										LET cCodRet = '00062';
										LET iSqlErr = 0;
										LET iIsamErr = 0;
										LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
										EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
										RETURN cCodRet;
									else
								end if;
						end if;
				end if;
			else
		end if;
		
--	CFE (bdisac - bdicheq):
		if cCategoria = '04' and cConvenio = '001'
			then
				if IndCrreSrvs <> '1'
					then
						LET cCodRet = '00060';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Servicios No Disponible.';
						EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
						RETURN cCodRet;
					else
						if IndCrreChqs <> '1'
							then
								LET cCodRet = '00061';
								LET iSqlErr = 0;
								LET iIsamErr = 0;
								LET cInfoErr = 'Sistema Cheques No Disponible.';
								EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
								RETURN cCodRet;
							else
								if IndDispChqs <> '1'
									then
										LET cCodRet = '00062';
										LET iSqlErr = 0;
										LET iIsamErr = 0;
										LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
										EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
										RETURN cCodRet;
									else
								end if;
						end if;
				end if;
			else
		end if;

--	ODP (Alta-Cobro-Canc.)/BTS/WU/OV/VG (bdisac - bdicheq):
		if cCategoria = '07' and cConvenio between '001' and '009'
			then
				if IndCrreSrvs <> '1'
					then
						LET cCodRet = '00060';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Servicios No Disponible.';
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
						RETURN cCodRet;
					else
						if IndCrreChqs <> '1'
							then
								LET cCodRet = '00061';
								LET iSqlErr = 0;
								LET iIsamErr = 0;
								LET cInfoErr = 'Sistema Cheques No Disponible.';
								EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
								RETURN cCodRet;
							else
								if IndDispChqs <> '1'
									then
										LET cCodRet = '00062';
										LET iSqlErr = 0;
										LET iIsamErr = 0;
										LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
										EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
										RETURN cCodRet;
									else
								end if;
						end if;
				end if;
			else
		end if;

--	GDF/ Club ProtecciÃÂ³n (bdisac - bdicheq - bdicred (en caso de cargo TDC-BCP)):
		if (cCategoria = '08' and cConvenio = '001') or (cCategoria = '01' and cConvenio = '002')
			then
				if IndCrreSrvs <> '1'
					then
						LET cCodRet = '00060';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Servicios No Disponible.';
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
						RETURN cCodRet;
					else
						if IndCrreChqs <> '1'
							then
								LET cCodRet = '00061';
								LET iSqlErr = 0;
								LET iIsamErr = 0;
								LET cInfoErr = 'Sistema Cheques No Disponible.';
								EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
								RETURN cCodRet;
							else
								if IndDispChqs <> '1'
									then
										LET cCodRet = '00062';
										LET iSqlErr = 0;
										LET iIsamErr = 0;
										LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
										EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
										RETURN cCodRet;
									else
								end if;
						end if;
						if cFormaPago = '5'
							then
								if IndCrreCred <> '1'
									then
										LET cCodRet = '00063';
										LET iSqlErr = 0;
										LET iIsamErr = 0;
										LET cInfoErr = 'Sistema CrÃÂ©dito No Disponible.';
										EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
										RETURN cCodRet;
									else
									if IndDispCred <> '1'
										then
											LET cCodRet = '00064';
											LET iSqlErr = 0;
											LET iIsamErr = 0;
											LET cInfoErr = 'Sistema CrÃÂ©dito Temporalmente Fuera de Servicio.';
											EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
											RETURN cCodRet;
										else
									end if;
								end if;								
							else
						end if;
				end if;
			else
		end if;

--	ECI/ARAB/AVON/DYCLASS/CAMI/SUKRN/SOLFI y demÃÂ¡s pagos referenciados que sÃÂ³lo aceptan pago en Efe y CC (bdisac - bdicheq):
		if cCategoria = '09' and cConvenio between '001' and '015'
			then
				if IndCrreSrvs <> '1'
					then
						LET cCodRet = '00060';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Servicios No Disponible.';
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
						RETURN cCodRet;
					else
						if IndCrreChqs <> '1'
							then
								LET cCodRet = '00061';
								LET iSqlErr = 0;
								LET iIsamErr = 0;
								LET cInfoErr = 'Sistema Cheques No Disponible.';
								EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
								RETURN cCodRet;
							else
								if IndDispChqs <> '1'
									then
										LET cCodRet = '00062';
										LET iSqlErr = 0;
										LET iIsamErr = 0;
										LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
										EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
										RETURN cCodRet;
									else
								end if;
						end if;
				end if;
			else
		end if;
		
		
--	2019.06.04 - NMR - Se agrega validacion para evitar pagos dobles de Remesas APPRIZA
		IF cCategoria = '07' AND cConvenio = '009' THEN
			
			LET vvRemesaPagada=0;

			--BUSCA EN MOVIMIENTOS DEL DIA
				SELECT count(*) INTO vvRemesaPagada FROM bdicheq:sc_movdia M, bdisac:sac_movimientos S
				WHERE M.folio_suc=S.folio_suc
				AND S.referencia1= cReferencia1
				AND S.status_cancelado <>'S'
				AND M.cancelad <> 'S'
				AND S.numcategoria = cCategoria
				AND S.numconvenio = cConvenio;

				IF vvRemesaPagada = 0 THEN
					--BUSCA EN HISTORIAL
						SELECT count(*) INTO vvRemesaPagada FROM bdicheq:sc_movhis M, bdisac:sac_movimientoshistorial S
						WHERE M.folio_suc=S.folio_suc
						AND S.referencia1= cReferencia1
						AND S.status_cancelado <> 'S'
						AND M.cancelad <> 'S'
						AND S.numcategoria = cCategoria
						AND S.numconvenio = cConvenio;
				END IF;

				IF vvRemesaPagada > 0 THEN
					LET cCodRet = '00138';
					LET iSqlErr = 0;
					LET iIsamErr = 0;
					LET cInfoErr = 'Orden pagada, los fondos han sido retirados o depositados';
					EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
					RETURN cCodRet;
				END IF;
		END IF;

--	2013.11.25 - FRG-i		--	Se valida existencia de referencia1 y referencia2 p/TELMEX (ambas son obligatorias):
	if (cCategoria = '02' or cCategoria = '06') AND cConvenio = '001'
		then
		if cReferencia1 = "" OR cReferencia2 = ""
				then
					let cCodRet = '00065';
					return cCodRet;
		end if;
	end if;

	IF cSucursal <> "" AND cCategoria <> "" AND cConvenio <> "" AND cReferencia1 <> ""  AND cFolio_suc <> ""  THEN
			
			IF  ((cCategoria = "07" AND cConvenio ="006") OR (cCategoria ="07" AND cConvenio ="007") OR (cCategoria ="07" AND cConvenio ="008")) THEN

				--DSB 15/10/2019
				SELECT
				FIRST 1 folio_suc
				INTO cFolioSucAnt				
				FROM bdisac:"informix".sac_movimientos
				WHERE numcategoria = cCategoria 
				AND numconvenio = cConvenio
				AND referencia1 = cReferencia1
				AND flag_confirmacion_central = '1'
				AND flag_confirmacion_sucursal = '1'
				AND status_cancelado = 'N';
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN --SI LA BUSQUEDA NO ARROJA RESULTADOS

							--OBTIENE DATOS DEL BENEFICIARIO
					EXECUTE PROCEDURE bdisac:"informix".sp_obtienedatosremaut(cCategoria, cConvenio, cReferencia1, cSucursal)
					INTO pCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
			
					INSERT INTO bdisac:"informix".sac_remesas_estadistica (numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, status_cancelado) --se envia la sucursal coppel
					VALUES (cCategoria, cConvenio, pSucursal_cpl, cReferencia1, deImportePago, cUsuario, cFolio_suc, dFechaPago, 'T', 'N');

			   		INSERT INTO bdisac:"informix".sac_movimientos (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago,importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert,status_cancelado, origen, sucursal_cpl, caja_cpl, transaccion, hora, folio_operacion, referencia3, referencia4)
					VALUES (cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, cFormaPago, deImportePago, deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, iFlgConfCen, iFlgConfSuc, dFechaPago, CURRENT, 'N', cOrigen, pSucursal_cpl, pCaja, cTransaccion, cHora, cFolio_Operacion, v_rfc, cReferencia_4);
					   
				ELSE
					
					SELECT {+INDEX(sc_movdia idx_sc_movdia9)}
					FIRST 1 folio_suc
					INTO cExisteTrx
					FROM bdicheq:sc_movdia
					WHERE folio_suc = cFolioSucAnt;
							
					IF cExisteTrx = 0 OR cExisteTrx IS NULL THEN
						UPDATE {+INDEX (bdisac:sac_movimientos idx_sac_movimientos7)} bdisac:sac_movimientos
						SET status_cancelado = 'S', referencia4 = 'REVSAC'
						WHERE folio_suc = cFolioSucAnt;
												
							--OBTIENE DATOS DEL BENEFICIARIO
						EXECUTE PROCEDURE bdisac:"informix".sp_obtienedatosremaut(cCategoria, cConvenio, cReferencia1, cSucursal)
						INTO pCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
				
						INSERT INTO bdisac:"informix".sac_remesas_estadistica (numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, status_cancelado) --se envia la sucursal coppel
						VALUES (cCategoria, cConvenio, pSucursal_cpl, cReferencia1, deImportePago, cUsuario, cFolio_suc, dFechaPago, 'T', 'N');

						INSERT INTO bdisac:"informix".sac_movimientos (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago,importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert,status_cancelado, origen, sucursal_cpl, caja_cpl, transaccion, hora, folio_operacion, referencia3, referencia4)
						VALUES (cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, cFormaPago, deImportePago, deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, iFlgConfCen, iFlgConfSuc, dFechaPago, CURRENT, 'N', cOrigen, pSucursal_cpl, pCaja, cTransaccion, cHora, cFolio_Operacion, v_rfc, cReferencia_4);
						
					ELSE
						LET cCodRet = "00025";
					END IF;
					
				END IF;	
				
			ELSE
			
				SELECT COUNT(*)
				INTO cContador
				FROM bdisac:"informix".sac_movimientos
				WHERE id_sucursal = cSucursal 
				AND numcategoria = cCategoria 
				AND numconvenio = cConvenio
				AND referencia1 = cReferencia1 
				AND referencia2 = cReferencia2 
				AND folio_suc = cFolio_suc;

				IF cContador = 0 THEN

					IF ((cCategoria = "07" AND cConvenio ="004") OR (cCategoria = "07" AND cConvenio ="006") OR (cCategoria ="07" AND cConvenio ="007") OR (cCategoria ="07" AND cConvenio ="008") OR (cCategoria = "07" AND cConvenio ="009")) THEN

							--OBTIENE DATOS DEL BENEFICIARIO
						EXECUTE PROCEDURE bdisac:"informix".sp_obtienedatosremaut(cCategoria, cConvenio, cReferencia1, cSucursal)
						INTO pCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
				
						INSERT INTO bdisac:"informix".sac_remesas_estadistica (numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, status_cancelado) --se envia la sucursal coppel
						VALUES (cCategoria, cConvenio, pSucursal_cpl, cReferencia1, deImportePago, cUsuario, cFolio_suc, dFechaPago, 'T', 'N');
					END IF;

			   		INSERT INTO bdisac:"informix".sac_movimientos (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago,importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert,status_cancelado, origen, sucursal_cpl, caja_cpl, transaccion, hora, folio_operacion, referencia3, referencia4)
					VALUES (cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, cFormaPago, deImportePago, deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente, cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, iFlgConfCen, iFlgConfSuc, dFechaPago, CURRENT, 'N', cOrigen, pSucursal_cpl, pCaja, cTransaccion, cHora, cFolio_Operacion, v_rfc, cReferencia_4);

				ELSE
					LET cCodRet = "00002";
				END IF;
				
			END IF;
				
    ELSE
                -- Indica que uno de los campos llave viene vacio
                LET cCodRet = "00001";
	END IF;
	
    RETURN cCodRet;
	
    END;
END PROCEDURE
DOCUMENT
'AUTOR : HÃÂ©tor Bojorquez',
'DESCRIPCION: Se encarga de guardar la informaciÃÂ³n de una transaccion de pago de servicio originada en sucursal',
'en la tabla bdisac:sac_movimientos de Central',
'MODIFICO : Jasmin Soto',
'DESCRIPCION: Se agrega validacion para cuando sea movimiento de central de BTS se inserte el iFlgConfSuc en 1',
'FECHA MODIFICACION: Noviembre de 2012',
'MODIFICO : Mario Galalardo',
'DESCRIPCION: Se modifica para que permita el valor de cReferencia2 vacio solo para la transaccion 8905 ',
'FECHA MODIFICACION: 10/06/2013',
'MODIFICO : Christian Echavarria',
'DESCRIPCION: Se modifica para que no sea obligatorio el valor de cReferencia2 ',
'FECHA MODIFICACION: 05/09/2013',
'EJECUTADO O LLAMADO POR: Caja',
'FECHA CREACION: Agosto de 2008',
'VERSION: 20080905',
'AUTOR : FRG',
'DESCRIPCION: Se agrega validaciÃÂ³n de cierre procesos centrales por Proy. Indep. Sistemas',
'FECHA : Nov. 2013',
'VERSION: 20131101',
'DESCRIPCION: Se modifica para que se valide la Referencia2 para un pago Telmex.',
'FECHA MODIFICACION: 25/Nov/2013',
'EJECUTADO O LLAMADO POR: Caja',
'FECHA CREACION: Nov-2013',
'VERSION: 20131125',
'AUTOR : FRG',
'DESCRIPCION: HomologaciÃÂ³n SP con Vers. Prod.',
'FECHA : Feb. 2014',
'VERSION: 20140205',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_benefremesas_wu(pFechaIni DATE,pFechaFin DATE)
RETURNING
CHAR(5)		AS codigo_respuesta,
CHAR(80)	AS mensaje_respuesta;

	--DEFINICIONES
	DEFINE iSqlErr              	INTEGER;
	DEFINE iIsamErr             	INTEGER;
	DEFINE cInfoErr             	CHAR(100);
	DEFINE cCodRet              	CHAR(5);
	DEFINE cMensaje					CHAR(80);
	DEFINE cDescripcionINS			CHAR(100);
	DEFINE cStmt					CHAR(400);
	DEFINE cStatus					CHAR(1);
	DEFINE iCuantosTelefonos		INTEGER;
	DEFINE cPrimer_nombre			CHAR(40);
	DEFINE cSegundo_nombre			CHAR(40);
	DEFINE cApellido_paterno		CHAR(40);
	DEFINE cApellido_materno		CHAR(40);
	DEFINE cFecha_nacimiento		CHAR(8);
	DEFINE cNumero_identificacion	CHAR(20);
	DEFINE iNumero_total_remesas	INTEGER;
	DEFINE mMonto_total_remesas		MONEY;
	DEFINE cBenef_ciudad			CHAR(24);
	DEFINE cBenef_edo				CHAR(40);
	DEFINE cBenef_tel_celular		CHAR(20);
	DEFINE cBenef_tel_celular1		CHAR(20);
	DEFINE cBenef_tel_celular2		CHAR(20);
	DEFINE cBenef_tel_celular3		CHAR(20);
	DEFINE dFechaIni 				DATE;
	DEFINE dFechaFin				DATE;
	DEFINE sCont					SMALLINT;
	DEFINE cMtcn					CHAR(10);
	DEFINE cFechaInsert				DATETIME YEAR TO SECOND;
	DEFINE vOrigen					VARCHAR(15);
	DEFINE dMontoTotalRemesas		DECIMAL(12,2);
	DEFINE iIdProceso				INTEGER;
	DEFINE iIdSubProceso			INTEGER;
	
	--INICIALIZACIONES
	LET iCuantosTelefonos			= 0;
	LET cCodRet  					= "00000";
	LET cMensaje 					= 'PROCESO EXITOSO';	
	LET cDescripcionINS		 		= 'Inserta info beneficiarios con mas de 3 remesas WUOVVG pagadas en periodo de 6 meses';
	LET cStmt						= '';
	LET cStatus						= '0';
	LET iCuantosTelefonos			= 0;
	LET cPrimer_nombre				= '';
	LET cSegundo_nombre				= '';
	LET cApellido_paterno			= '';
	LET cApellido_materno			= '';
	LET cFecha_nacimiento			= '';
	LET cNumero_identificacion		= '';
	LET iNumero_total_remesas		= 0;
	LET mMonto_total_remesas		= 0;
	LET cBenef_ciudad				= '';
	LET cBenef_edo					= '';
	LET cBenef_tel_celular			= '';
	LET cBenef_tel_celular1			= '';
	LET cBenef_tel_celular2			= '';
	LET cBenef_tel_celular3			= '';
	LET dFechaIni 					= '';
	LET dFechaFin					= '';
	LET sCont						= 0;
	LET cMtcn						= '';
	LET cFechaInsert				= '';
	LET vOrigen						= '';
	LET dMontoTotalRemesas			= 0;
	
	--SET DEBUG FILE TO "/tmp/adrian/sp_benefremesas_wu.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_benefremesas_wu");
                RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;				
		
		--OBTENER FECHAS PARA PROCESO AUTOMATICO
		IF pFechaIni = pFechaFin THEN
			LET dFechaIni = pFechaFin - 6 UNITS MONTH;
			LET dFechaIni = MDY(MONTH(dFechaIni),01,YEAR(dFechaIni));
			LET dFechaFin = pFechaFin;
			LET dFechaFin = MDY(MONTH(dFechaFin),01,YEAR(dFechaFin));
		ELSE --OBTENER FECHAS PARA PROCESO MANUAL
			LET dFechaIni = pFechaIni;					
			LET dFechaFin = pFechaFin;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ALTA', 0, 0, 'REPORTE WUN', '', 'informix')
		INTO iIdProceso, iIdSubProceso;
		
		IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='INS_BENREM_WU' and fecha_proceso = pFechaFin) THEN								
			--INSERTA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_BENREM_WU', pFechaFin, '0', 'informix', 'sp_benefremesas_wu', cDescripcionINS);	
		ELSE
			SELECT status
			INTO   cStatus
			FROM   bdisac:"informix".sac_procesos_jobs
			WHERE  proceso       = 'INS_BENREM_WU'
			AND    fecha_proceso = pFechaFin;
			IF cStatus = '0' THEN
				--Borro historial
				DELETE {+INDEX(bdisac:"informix".sac_benefremesas idxsac_benefremesasfm)}
				FROM   bdisac:"informix".sac_benefremesas
				WHERE  fecha = dFechaFin
				AND    marca = 'WUN';
			END IF;
		END IF;
		
		--SE EJECUTA SOLO SI NO HAY REGISTRO EXITOSO
		IF cStatus = '0' THEN
		
			--Trunco datos de las tablas establecidas
			TRUNCATE bdisac:"informix".sac_wu_agrupa_totales;
			TRUNCATE bdisac:"informix".sac_wu_filtra_totales;
			TRUNCATE bdisac:"informix".sac_wu_tels_totales;
			TRUNCATE bdisac:"informix".sac_wu_final_totales;
		
			-----PASO 1: Obtengo datos de proceso global (sac_wu_pay + sac_wu_pay_old)
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 1', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_agrupa_totales_01;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_agrupa_totales_02;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_agrupa_totales_03;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_agrupa_totales_04;
			
			LET sCont = 0;
			
			--Lleno datos iniciales para tomar en cuenta de la tabla sac_wu_pay_old
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT benef_fecha_nac, benef_id_number, mtcn, 
					   benef_nombre1, benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
					   NVL(((DECODE(monto_destino,'', '0', NULL, '0', monto_destino)::INTEGER)/100)::MONEY,0) AS monto_total_remesas,
					   fecha_insert, 'sac_wu_pay_old' AS origen
				INTO   cFecha_nacimiento, cNumero_identificacion, cMtcn,
				       cPrimer_nombre, cSegundo_nombre, cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					   dMontoTotalRemesas, cFechaInsert, vOrigen
				FROM   bdisac:"informix".sac_wu_pay_old
				WHERE  retcode      =  '00000'
				AND    conf_pago    =  'P'
				AND    fecha_insert >= dFechaIni
				AND    fecha_insert <  dFechaFin
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
				INSERT INTO bdisac:"informix".sac_wu_agrupa_totales (benef_fecha_nac, benef_id_number, mtcn, benef_nombre1,
						benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
						monto_total_remesas, fecha_insert, origen)
				VALUES (cFecha_nacimiento, cNumero_identificacion, cMtcn, cPrimer_nombre, cSegundo_nombre,
						cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					    dMontoTotalRemesas, cFechaInsert, vOrigen);
				
			END FOREACH;
			
			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			LET sCont = 0;
			
			--Lleno datos iniciales para tomar en cuenta de la tabla sac_wu_pay
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT benef_fecha_nac, benef_id_number, mtcn, 
					   benef_nombre1, benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
					   NVL(((DECODE(monto_destino,'', '0', NULL, '0', monto_destino)::INTEGER)/100)::MONEY,0) AS monto_total_remesas,
					   fecha_insert, 'sac_wu_pay' AS origen
				INTO   cFecha_nacimiento, cNumero_identificacion, cMtcn,
				       cPrimer_nombre, cSegundo_nombre, cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					   dMontoTotalRemesas, cFechaInsert, vOrigen
				FROM   bdisac:"informix".sac_wu_pay
				WHERE  retcode      =  '00000'
				AND    conf_pago    =  'P'
				AND    fecha_insert >= dFechaIni
				AND    fecha_insert <  dFechaFin
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
				INSERT INTO bdisac:"informix".sac_wu_agrupa_totales (benef_fecha_nac, benef_id_number, mtcn, benef_nombre1,
						benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
						monto_total_remesas, fecha_insert, origen)
				VALUES (cFecha_nacimiento, cNumero_identificacion, cMtcn, cPrimer_nombre, cSegundo_nombre,
						cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					    dMontoTotalRemesas, cFechaInsert, vOrigen);
				
			END FOREACH;
			
			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_wu_agrupa_totales_01
			ON bdisac:"informix".sac_wu_agrupa_totales(benef_fecha_nac, benef_id_number) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_agrupa_totales_02
			ON bdisac:"informix".sac_wu_agrupa_totales(mtcn) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_agrupa_totales_03
			ON bdisac:"informix".sac_wu_agrupa_totales(fecha_insert) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_agrupa_totales_04
			ON bdisac:"informix".sac_wu_agrupa_totales(benef_fecha_nac, benef_id_number, fecha_insert) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_wu_agrupa_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 1', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 2: Quitare los registros duplicados (mtcn) Dado que uno de los movimientos esta reversado
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 2', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			FOREACH
				SELECT mtcn, COUNT(*) AS cuenta
				INTO   cMtcn, sCont
				FROM   bdisac:"informix".sac_wu_agrupa_totales
				GROUP BY mtcn
				HAVING COUNT(*) > 1
				
				SELECT FIRST 1 benef_fecha_nac, benef_id_number, benef_nombre1, benef_nombre2, benef_appaterno,
				       benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
					   monto_total_remesas, fecha_insert, origen
				INTO   cFecha_nacimiento, cNumero_identificacion, cPrimer_nombre, cSegundo_nombre,
				       cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					   dMontoTotalRemesas, cFechaInsert, vOrigen
				FROM   bdisac:"informix".sac_wu_agrupa_totales
				WHERE  mtcn         = cMtcn
				AND    fecha_insert = (SELECT MAX(fecha_insert) FROM sac_wu_agrupa_totales WHERE mtcn = cMtcn);
				
				--Primero borro los registros duplicados
				DELETE FROM bdisac:"informix".sac_wu_agrupa_totales
				WHERE mtcn = cMtcn;
				
				--Finalmente inserto el ultimo registro encontrado para el mtcn
				INSERT INTO bdisac:"informix".sac_wu_agrupa_totales (benef_fecha_nac, benef_id_number, mtcn, benef_nombre1,
						benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
						monto_total_remesas, fecha_insert, origen)
				VALUES (cFecha_nacimiento, cNumero_identificacion, cMtcn, cPrimer_nombre, cSegundo_nombre,
						cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					    dMontoTotalRemesas, cFechaInsert, vOrigen);
				
			END FOREACH;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 2', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 3: Filtro datos de solo los que cumplan con la condicion que tengan mas de 3 remesas pagadas de la tabla generada en el paso 1
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 3', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_filtra_totales_01;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_filtra_totales_02;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_filtra_totales_03;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_filtra_totales_04;
			
			--Ahora si inicio primero sabiendo de la base total aquellas que tengan mas de 3 remesas
			SET ISOLATION TO DIRTY READ;
			INSERT   INTO bdisac:"informix".sac_wu_filtra_totales
			SELECT   {+INDEX(sac_wu_agrupa_totales idx_sac_wu_agrupa_totales_01)}
					 benef_fecha_nac, benef_id_number,
					 COUNT(*) AS numero_total_remesas,
					 SUM(monto_total_remesas) AS monto_total_remesas,
					 MAX(fecha_insert) AS secuencia
			FROM     bdisac:"informix".sac_wu_agrupa_totales
			GROUP BY 1,2
			HAVING COUNT(*) >= 3;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_wu_filtra_totales_01
			ON bdisac:"informix".sac_wu_filtra_totales(benef_fecha_nac, benef_id_number) ONLINE;

			CREATE INDEX bdisac:"informix".idx_sac_wu_filtra_totales_02
			ON bdisac:"informix".sac_wu_filtra_totales(secuencia) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_filtra_totales_03
			ON bdisac:"informix".sac_wu_filtra_totales(benef_fecha_nac, benef_id_number, secuencia) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_filtra_totales_04
			ON bdisac:"informix".sac_wu_filtra_totales(benef_fecha_nac, benef_id_number, numero_total_remesas, monto_total_remesas) ONLINE;

			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_wu_filtra_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 3', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 4: Obtengo el dato del ultimo registro segun su secuencia.
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 4', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_final_totales_01;
			
			--Obtengo los datos ligando la secuencia
			SET ISOLATION TO DIRTY READ;
			INSERT INTO bdisac:"informix".sac_wu_final_totales
			SELECT {+INDEX(sac_wu_filtra_totales idx_sac_wu_filtra_totales_04)}c.benef_fecha_nac, c.benef_id_number, a.benef_nombre1, a.benef_nombre2,
				   a.benef_appaterno, a.benef_apmaterno, a.benef_ciudad, a.benef_edo, a.benef_tel_celular,
				   c.numero_total_remesas, c.monto_total_remesas
			FROM   bdisac:"informix".sac_wu_agrupa_totales a,
			       bdisac:"informix".sac_wu_filtra_totales c
			WHERE  a.benef_fecha_nac = c.benef_fecha_nac
			AND    a.benef_id_number = c.benef_id_number
			AND    a.fecha_insert    = c.secuencia;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_wu_final_totales_01
			ON sac_wu_final_totales(benef_fecha_nac, benef_id_number) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_wu_final_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 4', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 5: Obtengo unicidad de celulares por fechaNacimiento e IdNumber
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_tels_totales_01;
			
			--Obtener unicidad de celulares por fechaNacimiento e IdNumber
			SET ISOLATION TO DIRTY READ;
			INSERT INTO bdisac:"informix".sac_wu_tels_totales
			SELECT UNIQUE a.benef_fecha_nac, a.benef_id_number, a.benef_tel_celular
			FROM   bdisac:"informix".sac_wu_agrupa_totales a,
			       bdisac:"informix".sac_wu_final_totales b
			WHERE  a.benef_fecha_nac = b.benef_fecha_nac
			AND    a.benef_id_number = b.benef_id_number;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_wu_tels_totales_01
			ON bdisac:"informix".sac_wu_tels_totales(benef_fecha_nac, benef_id_number) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_wu_tels_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 4', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 6: Genero la base final con los 3 numeros telefonicos
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 5', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			LET sCont = 0;
			
			--Realizo algoritmo para determinar los 3 numeros telefonicos
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT {+INDEX(sac_wu_final_totales idx_sac_wu_final_totales_01)}
					   benef_fecha_nac, benef_id_number, numero_total_remesas, monto_total_remesas,
					   benef_ciudad, benef_edo, benef_nombre1, benef_nombre2, benef_appaterno, benef_apmaterno
				INTO   cFecha_nacimiento, cNumero_identificacion, iNumero_total_remesas, mMonto_total_remesas,
					   cBenef_ciudad, cBenef_edo, cPrimer_nombre, cSegundo_nombre, cApellido_paterno, cApellido_materno
				FROM   bdisac:"informix".sac_wu_final_totales
				
				--Inicializaciones de las variables a utilizar
				LET iCuantosTelefonos = 0;
				LET cBenef_tel_celular1 = '';
				LET cBenef_tel_celular2 = '';
				LET cBenef_tel_celular3 = '';
				
				FOREACH
					SELECT FIRST 3 benef_tel_celular
					INTO   cBenef_tel_celular
					FROM   bdisac:"informix".sac_wu_tels_totales
					WHERE  benef_fecha_nac = cFecha_nacimiento
					AND    benef_id_number = cNumero_identificacion
					
					IF cBenef_tel_celular <> '' AND cBenef_tel_celular is NOT NULL THEN
						IF iCuantosTelefonos = 0 THEN
							LET cBenef_tel_celular1 = cBenef_tel_celular;
							LET iCuantosTelefonos = iCuantosTelefonos + 1;
						ELIF iCuantosTelefonos = 1 AND (cBenef_tel_celular1 <> cBenef_tel_celular) THEN
							LET cBenef_tel_celular2 = cBenef_tel_celular;
							LET iCuantosTelefonos = iCuantosTelefonos + 1;
						ELIF iCuantosTelefonos = 2 AND (cBenef_tel_celular1 <> cBenef_tel_celular) AND (cBenef_tel_celular2 <> cBenef_tel_celular) THEN
							LET cBenef_tel_celular3 = cBenef_tel_celular;
							LET iCuantosTelefonos = iCuantosTelefonos + 1;
						ELIF iCuantosTelefonos >= 3 THEN
							EXIT FOREACH;
						END IF;
					END IF;
					
				END FOREACH;
				
				LET cStmt = 'WUN'||'|'||TRIM(cPrimer_nombre)|| ' ' ||TRIM(cSegundo_nombre)|| ' ' ||TRIM(cApellido_paterno)|| ' ' ||TRIM(cApellido_materno)||'|'||TRIM(cBenef_ciudad)||'|'||TRIM(cBenef_edo)||'|'||TRIM(cBenef_tel_celular1)||'|'||TRIM(cBenef_tel_celular2)||'|'||TRIM(cBenef_tel_celular3)||'|'||iNumero_total_remesas||'|'||mMonto_total_remesas;
				
				INSERT INTO bdisac:"informix".sac_benefremesas (fecha,marca,linea,fecha_insert)
				VALUES(dFechaFin,'WUN',cStmt,current);
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
			END FOREACH;

			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
				LET sCont = 0;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 5', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--ACTUALIZA STATUS DE INSERTA INFO
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj(1, 'INS_BENREM_WU', pFechaFin, '1', 'informix', 'sp_benefremesas_wu', cDescripcionINS);		
			
		END IF;	--EJECUTE SOLO SI NO HAY REGISTRO
		
		
		RETURN cCodRet, cMensaje;

	END;
END PROCEDURE;