CREATE PROCEDURE "informix".sp_grabapagoservicio (cSucursal CHAR (4), cCategoria CHAR (2), cConvenio CHAR(5), cReferencia1 CHAR (20), cReferencia2 CHAR (20),cFormaPago CHAR (1), deImportePago DECIMAL (10,2), deImpComisionConvenio DECIMAL (6,2),deIvaComisionConvenio DECIMAL (6,2), deImpComisionCliente DECIMAL (6,2), deIvaComisionCliente DECIMAL (6,2), cCuentaCargo CHAR (12),cUsuario CHAR(8),cFolio_suc CHAR (16), cTransacc_suc CHAR(4), dFechaPago DATE)

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
	--DEFINE cRef1		CHAR(20); 			-- DSB-TH-17/06/2016- Variable sin utilizar
    DEFINE iSqlErr     INTEGER;
    DEFINE iIsamErr    INTEGER;
	DEFINE cInfoErr    CHAR(100);
	DEFINE cContador   SMALLINT;
	DEFINE CdRetVerSis CHAR (5);
	DEFINE IndCrreCred CHAR (1);
	DEFINE IndDispCred CHAR (1);
	DEFINE IndCrreChqs CHAR (1);
	DEFINE IndDispChqs CHAR (1);
	DEFINE IndCrreInvs CHAR (1);
	DEFINE IndDispInvs CHAR (1);
	DEFINE IndCrreSrvs CHAR (1);
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

    DEFINE c_MetCob VARCHAR(3);

-- Inicializa variables
     LET cCodRet            = "00000";
     LET iSql_err           = 0;
     LET vcSucursal         = "";
     LET iFlgConfCen        = 1;
     LET iFlgConfSuc        = 0;
     LET vcSucursalBPI      = "";
	 LET cSucursalCentBTS   = "";
	 --LET cRef1			="";		-- DSB-TH-17/06/2016- Variable sin utilizar
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
   
    LET c_MetCob                = '';	 
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO '/home/sysifx/Trinidad/homo_APP/sp_grabapagoservicio.out';
	--TRACE ON;

	-- OBTIENE LA SUCURSAL DE PAGOS PROGRAMADOS y BPI
    SELECT valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
    --SELECT valor INTO vcSucursalBPI FROM bdiprog:"informix".pp_parametros WHERE cve_param = '22';
	SELECT cSucursal INTO vcSucursalBPI FROM bdinteg:"informix".si_canales WHERE cc_canal IN ('5003','5007','5008','5011') AND cc_canal=cSucursal;
	SELECT valor INTO cSucursalCentBTS FROM bdisac:"informix".sac_param WHERE cod_param = '87015';
	SELECT valor INTO cSucCreditoCentBTS FROM bdisac:"informix".sac_param WHERE cod_param = '87023';

	--Obtener folio_sucursal appriza
	SELECT valor INTO cSucursalCentApp FROM bdisac:"informix".sac_param WHERE cod_param = '87112';
	SELECT valor INTO cSucCreditoCentApp FROM bdisac:"informix".sac_param WHERE cod_param = '87130';
	

	-- SI EL PAGO LLEGO POR CENTRAL DE PGPRO o BPI NO SE CONFIRMA EN SUCURSAL
	IF cSucursal = vcSucursal OR cSucursal = vcSucursalBPI OR cSucursal= cSucursalCentBTS OR cSucursal= cSucCreditoCentBTS OR cSucursal= cSucursalCentApp OR cSucursal= cSucCreditoCentApp THEN
		LET iFlgConfSuc = 1;
	END IF;

    BEGIN
        ON EXCEPTION SET iSql_err, iIsamErr, cInfoErr
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSql_err, iIsamErr, TRIM(cInfoErr) || ' ' || cFolio_suc, "sp_grabapagoservicio");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

--	2013.11.01 FRG-i - Se identifica el tipo de servicio a pagar, para validar los sistemas relacionados:
	EXECUTE FUNCTION bdinteg: "informix".verifica_sistemas() -- Se validan cierres de los sistemas antes de iniciar proceso de PGPROG:
	INTO CdRetVerSis, IndCrreCred, IndDispCred, IndCrreChqs, IndDispChqs, IndCrreInvs, IndDispInvs, IndCrreSrvs;
	
	-- Se valida que la fecha concuerde con la dia actual
	SELECT fecha_hoy INTO dFechaHoy 
	FROM sac_fechas WHERE empresa = '001';
			
		IF dFechaHoy <> dFechaPago THEN
			LET cCodRet = '01241';
			LET iSqlErr = 0;
			LET iIsamErr = 0;
			LET cInfoErr = 'LA FECHA DEL SISTEMA Y DE CENTRAL SON DIFERENTES' || ' ' || cSucursal;
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
			RETURN cCodRet;
		END IF;

--	Abonos Coppel (sÃÂ??ÃÂ?ÃÂÃÂ³lo bdisac):
		if cCategoria = '01' and cConvenio = '001'
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

--	DISH/MASTV/SKY (bdisac - bdicheq):
		if cCategoria = '06' and cConvenio between '001' and '003'
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

--	GDF/ Club ProtecciÃÂ??ÃÂ?ÃÂÃÂ³n (bdisac - bdicheq - bdicred (en caso de cargo TDC-BCP)):
		if (cCategoria = '08' and cConvenio = '001') or (cCategoria = '01' and cConvenio = '002')
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
						if cFormaPago = '5'
							then
								if IndCrreCred <> '1'
									then
										LET cCodRet = '00063';
										LET iSqlErr = 0;
										LET iIsamErr = 0;
										LET cInfoErr = 'Sistema CrÃÂ??ÃÂ?ÃÂÃÂ©dito No Disponible.';
										EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
										RETURN cCodRet;
									else
									if IndDispCred <> '1'
										then
											LET cCodRet = '00064';
											LET iSqlErr = 0;
											LET iIsamErr = 0;
											LET cInfoErr = 'Sistema CrÃÂ??ÃÂ?ÃÂÃÂ©dito Temporalmente Fuera de Servicio.';
											EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
											RETURN cCodRet;
										else
									end if;
								end if;								
							else
						end if;
				end if;
			else
		end if;

--	ECI/ARAB/AVON/DYCLASS/CAMI/SUKRN/SOLFI y demÃÂ??ÃÂ?ÃÂÃÂ¡s pagos referenciados que sÃÂ??ÃÂ?ÃÂÃÂ³lo aceptan pago en Efe y CC (bdisac - bdicheq):
		if cCategoria = '09' and cConvenio between '001' and '015'
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


--	2019.06.04 - NMR - Se agrega validacion para evitar pagos dobles de Remesas
		IF cCategoria = '07' AND cConvenio in ('004','006','007','008','009') THEN
			
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
                
                IF cSucursal not in('9764','9251') THEN --Se agrega ValidaciÃÂ³n de sucursal Automatica de Appriza - NMR 11MAY2020
                	SELECT FIRST 1 r_delimethodcod INTO c_MetCob FROM sac_app_qryi /* Parametro para identificar una remesa para cobro en ventanilla o Abono directoa cuenta -- EPG 24/03/2020 */
	                 WHERE txn_status = 'A' AND unirefnum = cReferencia1 AND r_delimethodcod <> '';
	               
	                IF c_MetCob = 'DEP' THEN
	                	LET cCodRet  = '01246';
						LET iSqlErr  = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Orden Dirigida Abono Directo a Cuenta';
						EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapagoservicio");
						RETURN cCodRet; 
	                 END IF;   
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

	IF cSucursal <> "" AND cCategoria <> "" AND cConvenio <> "" AND cReferencia1 <> ""  AND cFolio_suc <> "" THEN
	
		IF cSucursal = cSucursalCentBTS OR cSucursal = cSucCreditoCentBTS OR cSucursal = cSucursalCentApp OR cSucursal = cSucCreditoCentApp THEN
			--Es una remesa automatica
		
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
			
				IF ((cCategoria = "07" AND cConvenio ="004") OR (cCategoria = "07" AND cConvenio ="009")) THEN
				
					--Obtengo los datos del beneficiario
					EXECUTE PROCEDURE bdisac:"informix".sp_obtienedatosremaut(cCategoria, cConvenio, cReferencia1, cSucursal)
					INTO pCodRet, v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_rfc, v_fecha_nac, v_cta_benef, v_moneda_origen, v_importe_origen;
					
					IF cSucursal = cSucCreditoCentBTS OR cSucursal = cSucCreditoCentApp THEN
						--Automatica Credito
						INSERT INTO bdisac:"informix".sac_remesas_estadistica (numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen,
									nombre1, nombre2, appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado)
						VALUES (cCategoria, cConvenio, cSucursal, cReferencia1, deImportePago, cUsuario, cFolio_suc, dFechaPago, 'C',
									v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_fecha_nac, v_rfc, v_moneda_origen, v_cta_benef, v_importe_origen, 'N');
					ELSE
						--Automatica
						INSERT INTO bdisac:"informix".sac_remesas_estadistica (numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen,
									nombre1, nombre2, appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado)
						VALUES (cCategoria, cConvenio, cSucursal, cReferencia1, deImportePago, cUsuario, cFolio_suc, dFechaPago, 'A',
									v_nombre1, v_nombre2, v_appaterno, v_apmaterno, v_fecha_nac, v_rfc, v_moneda_origen, v_cta_benef, v_importe_origen, 'N');
					END IF;
					
				END IF;
			
				INSERT INTO bdisac:"informix".sac_movimientos (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, referencia3, forma_pago, importe_pago,importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte,
				cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert,status_cancelado)
				VALUES (cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, v_rfc, cFormaPago, deImportePago,
				deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente,
				cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, iFlgConfCen, iFlgConfSuc, dFechaPago, CURRENT, 'N');
					
			ELSE
			
				LET cCodRet = "00002";
				
			END IF;
			
		ELSE
	
			IF  ((cCategoria = "07" AND cConvenio ="006") OR (cCategoria ="07" AND cConvenio ="007") OR (cCategoria ="07" AND cConvenio ="008")) THEN
			
				--DSB 21/03/2017
				/*
				SELECT COUNT(*)
				INTO cContador				
				FROM bdisac:"informix".sac_movimientos
				WHERE numcategoria = cCategoria 
				AND numconvenio = cConvenio
				AND referencia1 = cReferencia1
				AND importe_pago = deImportePago
				AND status_cancelado = 'N';
				*/
					
				--DSB 21/03/2017
				SELECT
				FIRST 1 folio_suc
				INTO cFolioSucAnt				
				FROM bdisac:"informix".sac_movimientos
				WHERE numcategoria = cCategoria 
				AND numconvenio = cConvenio
				AND referencia1 = cReferencia1
				AND importe_pago = deImportePago
				AND status_cancelado = 'N';
						
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN --SI LA BUSQUEDA NO ARROJA RESULTADOS
					INSERT INTO bdisac:"informix".sac_movimientos (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago,importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte,
					cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert,status_cancelado)
					VALUES (cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, cFormaPago, deImportePago,
					   deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente,
					   cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, iFlgConfCen, iFlgConfSuc, dFechaPago, CURRENT, 'N');
					
					IF ((cCategoria = "07" AND cConvenio ="004") OR (cCategoria = "07" AND cConvenio ="006") OR (cCategoria ="07" AND cConvenio ="007")
					OR (cCategoria ="07" AND cConvenio ="008") OR (cCategoria = "07" AND cConvenio ="009")) THEN
						INSERT INTO bdisac:"informix".sac_remesas_estadistica (numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, status_cancelado)
						VALUES (cCategoria, cConvenio, cSucursal, cReferencia1, deImportePago, cUsuario, cFolio_suc, dFechaPago, 'V', 'N');
					END IF;
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
													
						INSERT INTO bdisac:"informix".sac_movimientos (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago,importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte,
						cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert,status_cancelado)
						VALUES (cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, cFormaPago, deImportePago,
						deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente,
						cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, iFlgConfCen, iFlgConfSuc, dFechaPago, CURRENT, 'N');
						
						IF ((cCategoria = "07" AND cConvenio ="004") OR (cCategoria = "07" AND cConvenio ="006") OR (cCategoria ="07" AND cConvenio ="007")
						OR (cCategoria ="07" AND cConvenio ="008") OR (cCategoria = "07" AND cConvenio ="009")) THEN
							INSERT INTO bdisac:"informix".sac_remesas_estadistica (numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, status_cancelado)
							VALUES (cCategoria, cConvenio, cSucursal, cReferencia1, deImportePago, cUsuario, cFolio_suc, dFechaPago, 'V', 'N');
						END IF;
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

				IF cContador = 0 
					THEN
						INSERT INTO bdisac:"informix".sac_movimientos (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago,importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte,
						cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert,status_cancelado)
						VALUES (cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, cFormaPago, deImportePago,
						deImpComisionConvenio, deIvaComisionConvenio, deImpComisionCliente, deIvaComisionCliente,
						cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, iFlgConfCen, iFlgConfSuc, dFechaPago, CURRENT, 'N');
						
						IF ((cCategoria = "07" AND cConvenio ="004") OR (cCategoria = "07" AND cConvenio ="006") OR (cCategoria ="07" AND cConvenio ="007")
						OR (cCategoria ="07" AND cConvenio ="008") OR (cCategoria = "07" AND cConvenio ="009")) THEN
							INSERT INTO bdisac:"informix".sac_remesas_estadistica (numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, status_cancelado)
							VALUES (cCategoria, cConvenio, cSucursal, cReferencia1, deImportePago, cUsuario, cFolio_suc, dFechaPago, 'V', 'N');
						END IF;
					ELSE
						LET cCodRet = "00002";
				END IF;
				
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
'AUTOR : HÃÂ??ÃÂ?ÃÂÃÂ©ctor Bojorquez',
'DESCRIPCION: Se encarga de guardar la informaciÃÂ??ÃÂ?ÃÂÃÂ³n de una transaccion de pago de servicio originada en sucursal',
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
'DESCRIPCION: Se agrega validaciÃÂ??ÃÂ?ÃÂÃÂ³n de cierre procesos centrales por Proy. Indep. Sistemas',
'FECHA : Nov. 2013',
'VERSION: 20131101',
'DESCRIPCION: Se modifica para que se valide la Referencia2 para un pago Telmex.',
'FECHA MODIFICACION: 25/Nov/2013',
'EJECUTADO O LLAMADO POR: Caja',
'FECHA CREACION: Nov-2013',
'VERSION: 20131125',
'AUTOR : FRG',
'DESCRIPCION: HomologaciÃÂ??ÃÂ?ÃÂÃÂ³n con Vers. Prod.',
'FECHA : Feb. 2014',
'VERSION: 20140205',
'BD    : bdisac',
'-------',
'Modifica: Mario Olivo',
'folio: 1542',
'Descripcion: se agrega la transaccion 8709',
'centro:230142',
'fecha:2016',
 'MODIFICACION -- DSB-TH-17/06/2016',
'DESCRIPCION: "HomologaciÃÂ??ÃÂ?ÃÂÃÂ³n de caja appriza con RQM 10-239-5 Y RQM 10-495 y cambio BTS_parametro sucursal"; HomologaciÃÂ??ÃÂ?ÃÂÃÂ³n con Vers. Prod., Pago de remesas Appriza',
'Modifica: Trinidad HernÃÂ??ÃÂ?ÃÂÃÂ¡ndez',
'folio: 73',
'FECHA : 17/06/2016',
'VERSION: 20160617.1613',
'BD    : bdisac',
'--------------------',
'MODIFICACION -- 15/11/2016',
'DESCRIPCION: " Se modifica para consultar la tabla sac_param en appriza',
'Modifica: Viridiana Paredes Romero',
'folio: 150',
'--------------------',
'MODIFICACION -- 	DSB 21/03/2017',
'DESCRIPCION: "		Se modifica procedimeinto para validar correcta insercion de pagos de WU en tablas: bdisac:sac_movimientos y bdicheq:sc_movdia',
'Modifica: 			Jose Angel Gaxiola Gaxiola',
'folio: 			1784 INC_REMESAS_SIN_MOVIMIENTOS',
'BD : 				bdisac',
'--------------------',
'MODIFICACION -- 	DSB 26/09/2017',
'DESCRIPCION: "		Se modifica para agregar flujo para CFE ',
'Modifica: 			Aaron QuiÃÂ??ÃÂ?ÃÂÃÂ±onez',
'folio: 			308  HOMOLOGACION SERVICIOS COPPEL',
'BD : 				bdisac',
'--------------------',
'MODIFICACION -- 	DSB 24/03/2020',
'DESCRIPCION: "		Se modifica diferenciar remesas de appriza cobro en ventanilla y abono directo a cuenta',
'Modifica: 			Eduardo Pineda',
'folio: 			RQI 62 845 - Controlar el mensaje 1100',
'BD : 				bdisac';

CREATE PROCEDURE "informix".sp_app_queryorder_prue
(		
		pTxn_status				CHAR  (1),
		pUnirefnum				CHAR  (16),
		pCode_Company			CHAR  (3),
		pChanneldid				CHAR  (3),
		pLocationunit			CHAR  (15),
		pNnumber				CHAR  (15),
		pTypecode_Branch		CHAR  (3),	
		pCountrycode_Branch		CHAR  (3),
		pStatecode_Branch		CHAR  (3),
		pTerminalid				CHAR  (15),
		pProcessdate_Qry		CHAR  (8),
		pProcesstime_Qry		CHAR  (6),
		pCode_Operacion			CHAR  (5),
		pCode					CHAR  (4),
		pMessage				CHAR  (255),
		pCode_d					CHAR  (4),
		pMessage_d				CHAR  (255),
		pProcessDate			CHAR  (8),
		pProcessTime			CHAR  (6),
		pRule					CHAR  (3),
		pValue					CHAR  (3),
		pGlobalTrackingNumber	CHAR  (20),
		pOrderStatusCode		CHAR  (3),
		pOrderStatusDate		CHAR  (8),
		pOrderStatusTime		CHAR  (6),
		pUniqueReferenceNumber	CHAR  (16),
		pCodesalecom			CHAR  (3),
		pCountryCode			CHAR  (3),
		pStateCodeSale			CHAR  (3),
		pSaleDate				CHAR  (8),
		pSaleTime				CHAR  (6),
		pCountryCode_o			CHAR  (3),
		pCurrencyCode			CHAR  (3),
		pServiceCode			CHAR  (3),
		pCountryCode_d			CHAR  (3),
		pCurrencyCode_d			CHAR  (3),
		pDeliveryMethodCode		CHAR  (3),
		pPayNetworkCode			CHAR  (3),
		pPaySubNetworkCode		CHAR  (15),
		pBranchNumber			CHAR  (15),
		pAccountTypeCode		CHAR  (3),
		pAccountNumber			CHAR  (30),
		pOriginAmount			CHAR  (20),
		pDestinationAmount		CHAR  (20),
		pRetailExchangeRate		CHAR  (21),
		pWholesaleExchangeRate	CHAR  (21),
		pDestinExchangeRate 	CHAR  (21),
		pServiceFeeAmount		CHAR  (20),
		pDiscountAmount			CHAR  (20),
		pTypeCode				CHAR  (3),
		pAccountNumber_c		CHAR  (30),
		pBicCode				CHAR  (11),
		pReferenceNumber		CHAR  (30),
		pCustomerNumber			CHAR  (20),
		pFirstName				CHAR  (40),
		pMiddleName				CHAR  (40),
		pLastName				CHAR  (40),
		pMotherMaidenName		CHAR  (40),
		pAddress				CHAR  (80),
		pCity					CHAR  (40),
		pCountryCode_a			CHAR  (3),
		pStateCode				CHAR  (3),
		pZipCode				CHAR  (10),
		pTypeCode_i				CHAR  (3),
		pNumber					CHAR  (20),
		pExpirationDate			CHAR  (8),
		pIssuerCountryCode		CHAR  (3),
		pIssuerStateCode		CHAR  (3),
		pDateOfBirth			CHAR  (8),
		pCustomerNumber_b		CHAR  (20),
		pFirstName_b			CHAR  (40),
		pMiddleName_b			CHAR  (40),
		pLastName_b				CHAR  (40),
		pMotherMaidenName_b		CHAR  (40),
		pFirstName_f			CHAR  (40),
		pMiddleName_f			CHAR  (40),
		pLastName_f				CHAR  (40),
		pMotherMaidenName_f		CHAR  (40),
		pAddress_b				CHAR  (80),
		pCity_b					CHAR  (40),
		pCountryCode_b			CHAR  (3),
		pStateCode_b			CHAR  (3),
		pZipCode_b				CHAR  (10),
		pEmail					CHAR  (100),
		pHomePhoneNumber		CHAR  (15),
		pWorkPhoneNumber		CHAR  (15),
		pNumber_cl				CHAR  (15),
		pReceiveEmail			CHAR  (3),
		pReceiveSMS				CHAR  (3),
		pTypeCode_ib			CHAR  (3),
		pNumber_ib				CHAR  (20),
		pExpirationDate_ib		CHAR  (8),
		pIssuerCountryCode_ib	CHAR  (3),
		pIssuerStateCode_ib		CHAR  (3),
		pReasonTypeCode			CHAR  (3),
		pReasonForTransfer		CHAR  (40),
		pSourceOfFunds			CHAR  (40),
		pSecurityPhrase			CHAR  (40),
		pFreeMessage			CHAR  (255),
		pUsuario				CHAR  (8),
		pModo					SmallInt
)
RETURNING CHAR (5) AS cCodRet,CHAR (255) AS cMensCode,CHAR (255) AS cMensajeD;

		--Declaracion de variables 
		DEFINE cCodRet 		    CHAR(5);
		DEFINE iSqlErr			INT;
		DEFINE cStatus			CHAR(1);
		DEFINE cMensCode		CHAR(255);
		DEFINE cMensajeD		CHAR(255);
		DEFINE cCodRetMessg		CHAR(5);
		DEFINE cCod_estado_sucursal CHAR(2);
		DEFINE cCod_estado_remesa		CHAR(2);
	
		
		LET cCodRet 			= '00000'; 
		LET iSqlErr				= 0;
		LET cStatus				= '';
		LET cMensCode			= '';
		LET cMensajeD			= '';
		LET cCodRetMessg		= '';
		LET cCod_estado_sucursal = '';
		LET cCod_estado_remesa = '';

		--SET DEBUG FILE TO '/tmp/adrian/sp_app_queryorder.out';
		--TRACE ON;	
		

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensCode,cMensajeD;
		END IF;
	END EXCEPTION;
	
	
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
	
	IF pTxn_status = '' OR pUnirefnum = '' OR  pCode_Company = '' OR  pChanneldid = '' OR pLocationunit = '' OR  pNnumber = '' OR  pTypecode_Branch = '' OR pCountrycode_Branch = '' OR 
		pStatecode_Branch = '' OR  pTerminalid	= '' THEN
		LET cCodRet = '00001';
	
	ELSE 
		EXECUTE PROCEDURE bdisac:"informix".sp_app_mensajes ('QRYI', pCode,pCode_d) INTO cCodRetMessg,cMensCode,cMensajeD;
		IF cCodRetMessg <> '00000' THEN
			LET cMensCode = pMessage;
			LET cMensajeD = pMessage_d;
		END IF ;
		
		--Almacenar datos en bdisac: sac_app_qryi
		INSERT INTO bdisac:"informix".sac_app_qryi (txn_status,unirefnum,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,processdate,processtime,r_operacion,r_code,
		r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_rule,r_value,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,r_uniquerefnum,r_codesalecom,
		r_countrycode,r_statecodesale,r_saledate,r_saletime,r_countrycode_o,r_currencycode,r_servicecode,r_countrycode_d,r_currencycod_d,r_delimethodcod,r_playnwcode,
		r_paysubnwcode,r_branchnumber,r_accounttcod,r_accountnumber,r_originamount,r_destinamount,r_rexchangerate,r_wholesalerate,r_deexhangerate,r_servfeeamount,
		r_discountamoun,r_typecode,r_accountnum,r_biccode,r_refnumber,r_customernum,r_firstname,r_middlename,r_lastname,r_mommaidenname,r_address,r_city,
		r_countrycode_a,r_statecode,r_zipcode,r_typecode_i,r_number,r_expirdate,r_isscontrycode,r_issstatecode,r_dateofbirth,r_customernum_b,r_firstname_b,r_middlename_b,
		r_lastname_b,r_mommaidenna_b,r_firstname_f,r_middlename_f,r_lastname_f,r_mommaidenna_f,r_address_b,r_city_b,r_countrycode_b,r_statecode_b,r_zipcode_b,r_email,
		r_homephonenum,r_workphonenum,r_number_cl,r_receiveemail,r_receivesms,r_typecode_ib,r_number_ib,r_expirdate_ib,r_issconcode_ib,r_issstacode_ib,r_reastypecode,r_refortransfer,
		r_sourceoffunds,r_securphrase,r_feemessage,user_insert,fecha)
		VALUES (pTxn_status,pUnirefnum,pCode_Company,pChanneldid,pLocationunit,pNnumber,pTypecode_Branch,pCountrycode_Branch,pStatecode_Branch,pTerminalid,pProcessdate_Qry,pProcesstime_Qry,
		pCode_Operacion,pCode,cMensCode,pCode_d,cMensajeD,pProcessDate,pProcessTime,pRule,pValue,pGlobalTrackingNumber,pOrderStatusCode,pOrderStatusDate,pOrderStatusTime,pUniqueReferenceNumber,
		pCodesalecom,pCountryCode,pStateCodeSale,pSaleDate,pSaleTime,pCountryCode_o,pCurrencyCode,pServiceCode,pCountryCode_d,pCurrencyCode_d,pDeliveryMethodCode,pPayNetworkCode,pPaySubNetworkCode,
		pBranchNumber,pAccountTypeCode,pAccountNumber,pOriginAmount,pDestinationAmount,pRetailExchangeRate,pWholesaleExchangeRate,pDestinExchangeRate ,pServiceFeeAmount,pDiscountAmount,pTypeCode,
		pAccountNumber_c,pBicCode,pReferenceNumber,pCustomerNumber,pFirstName,pMiddleName,pLastName,pMotherMaidenName,pAddress,pCity,pCountryCode_a,pStateCode,pZipCode,
		pTypeCode_i,pNumber,pExpirationDate,pIssuerCountryCode,pIssuerStateCode,pDateOfBirth,pCustomerNumber_b,pFirstName_b,pMiddleName_b,pLastName_b,pMotherMaidenName_b,pFirstName_f,
		pMiddleName_f,pLastName_f,pMotherMaidenName_f,pAddress_b,pCity_b,pCountryCode_b,pStateCode_b,pZipCode_b,pEmail,pHomePhoneNumber,pWorkPhoneNumber,pNumber_cl,
		pReceiveEmail,pReceiveSMS,pTypeCode_ib,pNumber_ib,pExpirationDate_ib,pIssuerCountryCode_ib,pIssuerStateCode_ib,pReasonTypeCode,pReasonForTransfer,pSourceOfFunds,
		pSecurityPhrase,pFreeMessage,pUsuario,CURRENT);
		
	END IF;
	/*
	IF pCode_Operacion = '00000' AND pCode = '0000' AND TRIM(pOrderStatusCode) = 'NPD' THEN
		SELECT estado INTO cCod_estado_sucursal FROM bdinteg:"informix".si_sucursales where sucursal=pNnumber;
		SELECT cod_estado INTO  cCod_estado_remesa FROM "informix".sac_estaremesasorig where cve_prov_estado=pStateCode_b AND remesadora='APP';
		
		IF EXISTS (Select cod_estado,nom_estado,cve_prov_estado from "informix".sac_estaremesasorig where cve_prov_estado = pStateCode_b  and remesadora='APP') THEN
				IF cCod_estado_sucursal = cCod_estado_remesa THEN
					RETURN cCodRet,cMensCode,cMensajeD;
				ELSE	
					IF EXISTS (SELECT cod_estado,nom_estado,cod_excep,tipo_excep,remesadora FROM "informix".sac_edosremorigexcep WHERE cod_estado = cCod_estado_remesa) THEN 
						IF EXISTS (SELECT cod_estado,nom_estado,cod_excep,tipo_excep,remesadora FROM "informix".sac_edosremorigexcep WHERE remesadora ='APP' and cod_estado = cCod_estado_remesa and ((cod_excep = TO_CHAR(pNnumber) AND tipo_excep = 'S') OR (cod_excep = cCod_estado_sucursal AND tipo_excep = 'E'))) THEN
								RETURN cCodRet,cMensCode,cMensajeD;
						ELSE
								INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pNnumber,cCod_estado_sucursal,pStateCode_b,cCod_estado_remesa,'001',pUnirefnum,'APP',CURRENT);
								LET cCodRet = '00005';								
								RETURN cCodRet,cMensCode,cMensajeD;
						END IF;
					ELSE
						INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pNnumber,cCod_estado_sucursal,pStateCode_b,cCod_estado_remesa,'001',pUnirefnum,'APP',CURRENT);
						LET cCodRet = '00005';
						RETURN cCodRet,cMensCode,cMensajeD;
					
					END IF;			
				END IF;

		ELSE
			--INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pNnumber,cCod_estado_sucursal,pStateCode_b,cCod_estado_remesa,'002',pUnirefnum,'APP',CURRENT);
			--LET cCodRet = '00004';			
			RETURN cCodRet,cMensCode,cMensajeD;			
		END IF;
	ELSE*/	
		RETURN cCodRet,cMensCode,cMensajeD;
	--END IF;
	
	
		

END;
END PROCEDURE
DOCUMENT
'AUTOR : 97498531',
'Nombre : Oscar Millan Rivas',
'DESCRIPCION: Genera trama para pago de remesas Appriza pay, valida el estado de origen con el estado al que pertenece sucursal',
'FOLIO:330',
'FECHA :16 nov 17 ',
'VERSION: ',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE  "informix".sp_valida_hipinfonavitdv(pNumReferencia CHAR(10))
	RETURNING 
		CHAR(5) AS CodigoRetorno;

	--DEFINICION DE LAS VARIABLES
	DEFINE iCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE isumapares INTEGER;
	DEFINE isumanones INTEGER;
	DEFINE iresiduo INTEGER;
	DEFINE idv INTEGER;
	DEFINE idvcapturado INTEGER;
	DEFINE icont INTEGER;
	DEFINE icos DECIMAL;

	--INICIALIZACION DE LAS VARIABLES
	LET iCodRet= '00000';
	LET iSqlErr= 0;
	LET isumapares= 0;
	LET isumanones= 0;
	LET iresiduo= 0;
	LET idv= 0;
	LET idvcapturado=0;
	LET icont = 1;
	LET icos = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			RETURN iCodRet;
		END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/HMLG/sp_hipdv.out';
		--TRACE ON;	

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF TRIM(pNumReferencia) = '' THEN
			LET iCodRet = '00080';
		ELIF LENGTH(pNumReferencia) <> 10 THEN
			LET iCodRet = '00047';
		ELIF pNumReferencia = '0000000000' THEN 
			LET iCodRet = '00109';
		ELSE
			--PASO 1 SUMAR POSICIONES NONES Y PARES DE LA REFERENCIA EXCLUYENDO POSICION 10
			WHILE icont <= 10
				IF icont = 10 THEN 
					LET idvcapturado = SUBSTR(pNumReferencia,icont,1)::INTEGER;
				ELSE
					IF MOD(icont,2) = 0 THEN
						LET isumapares = isumapares + SUBSTR(pNumReferencia,icont,1)::INTEGER;
					ELSE
						LET isumanones = isumanones + SUBSTR(pNumReferencia,icont,1)::INTEGER;
					END IF;
				END IF;
				LET icont = icont + 1;
			END WHILE;
			
			--PASO 2 EL RESULADO DE LA SUMATORIA DE LOS NONES SE DIVIDE ENTRE 10
			LET iresiduo = MOD(isumanones,10);
			
			--PASO 3 EL RESIDUO DE LA ADIVISION ANTERIOR SE DIVIDE ENTRE 5, TAMBIEN SE GUARDA EL COSIENTE DE LA DIVISION
			--LET iresiduo = MOD(iresiduo,5);
			LET icos = iresiduo / 5;
			
			--PASO 4 EL RESULTADO DE LA SUMA DE LOS NONES DEL PASO 1 SE MULTIPLICA POR 2, Se vuelve a inicializar la variable icont para reciclarla
			LET icont = 0;  
			LET icont = isumanones * 2;
			
			-- PASO 5 AL RESULTADO DEL PUNTO 4 SE LE SUMA EL RESULTADO DE LA SUMA DE LOS PARES DEL PASO 1
			LET icont = icont + isumapares;
			
			-- PASO 6 AL RESULTADO DEL PASO 5 SE LE SUMA EL COSIENTE DE LA DIVISION DEL PASO 3
			LET icont = icont + icos;
			
			-- PASO 7 AL RESULTADO DEL PASO 6 SE DIVIDE ENTRE 10
			LET icont = MOD(icont,10);
			
			-- PASO 8 EL DV ES EL RESIDUO DEL PASO 7
			LET iresiduo = icont;
			
			-- SI EL DV CAPTURADO ES EL MISMO QUE EL CALCULADO EL CODIGO DE RETORNO ES CORRECTO (00000).
			IF iresiduo <> idvcapturado AND  iCodRet = '00000' then
				LET iCodRet = '00109';
			END IF
			
		END IF;
		
		RETURN iCodRet;
		
	END;
END PROCEDURE;