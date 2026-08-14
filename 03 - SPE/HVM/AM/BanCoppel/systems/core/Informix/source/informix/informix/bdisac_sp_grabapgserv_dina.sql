CREATE PROCEDURE "informix".sp_grabapgserv_dina(cSucursal CHAR(4),
												cCategoria CHAR(2),
												cConvenio CHAR(5),
												cReferencia1 CHAR(40),
												cReferencia2 CHAR(40),
												cFormaPago CHAR(1),
												deImportePago DECIMAL (10,2),
												deImpComisionConvenio DECIMAL (6,2),
												deIvaComisionConvenio DECIMAL (6,2),
												deImpComisionCliente DECIMAL (6,2),
												deIvaComisionCliente DECIMAL (6,2),
												cCuentaCargo CHAR(12),
												cUsuario CHAR(8),
												cFolio_suc CHAR(16),
												cTransacc_suc CHAR(4),
												dFechaPago DATE)

RETURNING CHAR(5);

	-- Definicion de Variables
    DEFINE cCodRet			CHAR(5);
    DEFINE vcSucursal 		CHAR(4);
    DEFINE iSql_err 		INT;
    DEFINE iFlgConfCen 		INT;
    DEFINE iFlgConfSuc 		INT;
    DEFINE vcSucursalBPI 	CHAR(10);
	DEFINE cSucursalCentBTS CHAR (4);
	
	-- Declaracion de variables para la dependencia de sistemas RGLL, 20141205
	DEFINE iSqlErr     		INTEGER;
	DEFINE iIsamErr    		INTEGER;
	DEFINE cInfoErr    		CHAR(100);
	DEFINE cContador        SMALLINT;
	DEFINE CdRetVerSis 		CHAR (5);
	DEFINE IndCrreCred 		CHAR (1);
	DEFINE IndDispCred 		CHAR (1);
	DEFINE IndCrreChqs 		CHAR (1);
	DEFINE IndDispChqs 		CHAR (1);
	DEFINE IndCrreInvs 		CHAR (1);
	DEFINE IndDispInvs 		CHAR (1);
	DEFINE IndCrreSrvs 		CHAR (1);   
    DEFINE cReferencia3     CHAR (40);
    DEFINE statusConv       CHAR (1);
	DEFINE dFechaHoy		DATE;

    -- Inicializando variables
	LET cCodRet 			= "00000";
    LET iSql_err 			= 0;
    LET vcSucursal 			= "";
    LET iFlgConfCen 		= 1;
    LET iFlgConfSuc 		= 0;
    LET vcSucursalBPI 		= "";
	LET cSucursalCentBTS 	= "";
	
	-- Inicializando variables para la dependencia de sistemas RGLL, 20141205
	LET iSqlErr     		= 0;
    LET iIsamErr    		= 0;
	LET cInfoErr    		= '';
    LET cContador          	= 0;
	LET CdRetVerSis			= '';
	LET IndCrreCred 	    = '';
	LET IndDispCred 		= '';
	LET IndCrreChqs 		= '';
	LET IndDispChqs 		= '';
	LET IndCrreInvs 		= '';
	LET IndDispInvs 		= '';
	LET IndCrreSrvs 		= '';
    LET cReferencia3        = '';
    LET statusConv          = '';
	LET dFechaHoy			= '';	

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO '/respaldosbd/resbdrigoberto/sp_grabapgserv_dina.out';
	--TRACE ON;

	-- OBTIENE LA SUCURSAL DE PAGOS PROGRAMADOS y BPI
    SELECT valor INTO vcSucursal FROM bdiprog:"informix".pp_parametros WHERE cve_param = '12';
	SELECT cSucursal INTO vcSucursalBPI FROM bdinteg:"informix".si_canales WHERE cc_canal IN ('5003','5007','5008','5011') AND cc_canal=cSucursal;
	SELECT valor INTO cSucursalCentBTS FROM bdisac:"informix".sac_param WHERE cod_param = '87015';

	-- SI EL PAGO LLEGO POR CENTRAL DE PGPRO o BPI NO SE CONFIRMA EN SUCURSAL
	IF cSucursal = vcSucursal OR cSucursal = vcSucursalBPI OR cSucursal= cSucursalCentBTS THEN
		LET iFlgConfSuc = 1;
	END IF;
	
    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		-- Se validan cierres de los sistemas antes de iniciar proceso de PGPROG:
		EXECUTE FUNCTION bdinteg:"informix".verifica_sistemas()
		INTO CdRetVerSis, IndCrreCred, IndDispCred, IndCrreChqs, IndDispChqs, IndCrreInvs, IndDispInvs, IndCrreSrvs;
		 
		IF cCategoria = '06' AND cConvenio = '001' THEN
            LET cReferencia3 = cReferencia2;
            LET cReferencia2 = SUBSTR(cReferencia1, 12,1);
        END IF; 
		
        if cCategoria = '03' and cConvenio = '001' then
           SELECT statusconvenio INTO statusConv FROM bdisac:sac_convenios
            WHERE numcategoria = '03'
                 and numconvenio = '001';

              IF statusConv = 'I' THEN
                   LET cCodRet = '00060';
                   RETURN cCodRet;
                -- RETURN cCodRet, cTrans_Interact, cIp, iPuerto, iTimeOut, cCod_cons_trama, cSp_escenarios, cCampo_codresp, cCod_cons_codresp, cCod_cons_bitacora, cCodresp_noenviada, cCodresp_timeout, cAidaban, cCod_cons_idtran;
               END IF;         
		END IF;	

		SELECT fecha_hoy INTO dFechaHoy 
		FROM sac_fechas WHERE empresa = '001';
			
			IF dFechaHoy <> dFechaPago THEN
				LET cCodRet = '01241';
				LET iSqlErr = 0;
				LET iIsamErr = 0;
				LET cInfoErr = 'LA FECHA DEL SISTEMA Y DE CENTRAL SON DIFERENTES' || ' ' || cSucursal;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
				RETURN cCodRet;
			END IF;

		--	TELMEX (bdisac - bdicheq):
		IF cCategoria = '02' AND cConvenio = '001' THEN
			IF IndCrreSrvs <> '1' THEN
				LET cCodRet = '00060';
				LET iSqlErr = 0;
				LET iIsamErr = 0;
				LET cInfoErr = 'Sistema Servicios No Disponible.';
				
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
				RETURN cCodRet;
			ELSE
				
				IF IndCrreChqs <> '1' THEN
					LET cCodRet = '00061';
					LET iSqlErr = 0;
					LET iIsamErr = 0;
					LET cInfoErr = 'Sistema Cheques No Disponible.';
					
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
					RETURN cCodRet;
				ELSE
				
					IF IndDispChqs <> '1' THEN
						LET cCodRet = '00062';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
						
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
						RETURN cCodRet;
					END IF;
				END IF;				
			END IF;
		END IF;
				
		-- DISH/MASTV/SKY/CABLEMAS/MEGACABLE (bdisac - bdicheq):
		IF (cCategoria = '06' AND cConvenio IN ( '001', '002', '003','004','005' )) THEN
			IF IndCrreSrvs <> '1' THEN
				LET cCodRet = '00060';
				LET iSqlErr = 0;
				LET iIsamErr = 0;
				LET cInfoErr = 'Sistema Servicios No Disponible.';
				
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
				RETURN cCodRet;
			ELSE
			
				IF IndCrreChqs <> '1' THEN
					LET cCodRet = '00061';
					LET iSqlErr = 0;
					LET iIsamErr = 0;
					LET cInfoErr = 'Sistema Cheques No Disponible.';
					
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
					RETURN cCodRet;
				ELSE
				
					IF IndDispChqs <> '1' THEN
						LET cCodRet = '00062';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
						
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
						RETURN cCodRet;
					END IF;
				END IF;
			END IF;
		END IF;
		
		--Rigoberto Gonzalez
		--Se agrega el convenio de pagos de impuestos del gobierno de jalisco 
		IF (cCategoria = '08' AND (cConvenio ='004' OR cConvenio ='003')) THEN
			IF IndCrreSrvs <> '1' THEN
				LET cCodRet = '00060';
				LET iSqlErr = 0;
				LET iIsamErr = 0;
				LET cInfoErr = 'Sistema Servicios No Disponible.';
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
				RETURN cCodRet;
			ELSE
				
				IF IndCrreChqs <> '1' THEN
					LET cCodRet = '00061';
					LET iSqlErr = 0;
					LET iIsamErr = 0;
					LET cInfoErr = 'Sistema Cheques No Disponible.';
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
					RETURN cCodRet;
				ELSE
				
					IF IndDispChqs <> '1' THEN
						LET cCodRet = '00062';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
						
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
						RETURN cCodRet;
					END IF;
				END IF;
			END IF;
		END IF;
		
		--	ECI/ARAB/AVON/DYCLASS/CAMI/SUKRN/SOLFI y demás pagos referenciados que sólo aceptan pago en Efe y CC (bdisac - bdicheq):		
		IF (cCategoria = '09' AND cConvenio IN ('001', '002', '003', '004', '005','006', '007', '008', '009', '010', '011', '012', '013', '014', '015')) THEN
			IF IndCrreSrvs <> '1' THEN
				LET cCodRet = '00060';
				LET iSqlErr = 0;
				LET iIsamErr = 0;
				LET cInfoErr = 'Sistema Servicios No Disponible.';
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
				RETURN cCodRet;
			ELSE
				
				IF IndCrreChqs <> '1' THEN
					LET cCodRet = '00061';
					LET iSqlErr = 0;
					LET iIsamErr = 0;
					LET cInfoErr = 'Sistema Cheques No Disponible.';
					
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
					RETURN cCodRet;
				ELSE
				
					IF IndDispChqs <> '1' THEN
						LET cCodRet = '00062';
						LET iSqlErr = 0;
						LET iIsamErr = 0;
						LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
						
						EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_grabapgserv_dina");
						RETURN cCodRet;
					END IF;
				END IF;
			END IF;
		END IF;
		
		--	Se valida existencia de referencia1 y referencia2 p/TELMEX (ambas son obligatorias):		
		IF ( cCategoria IN ('02','06') AND cConvenio = '001' ) THEN			
			IF cReferencia1 = "" THEN
				LET cCodRet = '00065';
				RETURN cCodRet;
			ELSE
				IF cReferencia2 = "" THEN
					LET cCodRet = '00066';
					RETURN cCodRet;
				END IF;
			END IF;
		END IF;
	
		IF cSucursal <> "" AND cCategoria <> "" AND cConvenio <> "" AND cReferencia1 <> ""  AND cFolio_suc <> "" THEN
		
			IF  ( cCategoria = "07" AND cConvenio IN ("006","007","008")) THEN
			
				SELECT COUNT(*)
				INTO cContador
				FROM bdisac:"informix".sac_movimientos
				WHERE numcategoria = cCategoria 
				AND numconvenio = cConvenio
				AND referencia1 = cReferencia1
				AND importe_pago = deImportePago
				AND status_cancelado = 'N';
				
				IF NVL( cContador, 0) = 0 THEN			
					INSERT INTO bdisac:"informix".sac_movimientos (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago,
						importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
						flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert,status_cancelado)
					VALUES (cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, cFormaPago, deImportePago, deImpComisionConvenio, deIvaComisionConvenio,
						deImpComisionCliente, deIvaComisionCliente, cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, iFlgConfCen, iFlgConfSuc, dFechaPago, CURRENT, 'N');
				ELSE
					LET cCodRet = "00025";
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
				
				IF NVL( cContador, 0) = 0 THEN
					INSERT INTO bdisac:"informix".sac_movimientos (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago,
						importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
						flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado,referencia3 )
					VALUES (cSucursal, cCategoria, cConvenio, cReferencia1, cReferencia2, cFormaPago, deImportePago, deImpComisionConvenio, deIvaComisionConvenio,
						deImpComisionCliente, deIvaComisionCliente, cCuentaCargo, cUsuario, cFolio_suc, cTransacc_suc, iFlgConfCen, iFlgConfSuc, dFechaPago, CURRENT, 'N',cReferencia3 );
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
END PROCEDURE;