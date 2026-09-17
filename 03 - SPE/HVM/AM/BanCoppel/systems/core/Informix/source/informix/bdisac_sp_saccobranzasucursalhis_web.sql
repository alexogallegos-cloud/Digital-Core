CREATE PROCEDURE "informix".sp_saccobranzasucursalhis_web(cSucursal CHAR(4), dFechaIni DATE, siRegistros SMALLINT,stipo smallint)

    -- DATOS A REGRESAR
    RETURNING
    CHAR(5)  AS retorno,            --Codigo de Retorno
    CHAR(40) AS nombre,             --Nombre convenio
	CHAR(5)  AS IdConvenio,
    CHAR(16) AS folio_suc,          --Folio de sucursal
    CHAR(40) AS referencia1,        --Num telefono (Telmex), Num cliente(Coppel)
    CHAR(40) AS referencia2,        --DV (Telmex), Recibo(Coppel)
    CHAR(30) AS IdReferencia1,      --Nombre Referencia 1
    CHAR(30) AS IdReferencia2,      --Nombre Referencia 2
    MONEY(16,2) AS montoCargo,      --Monto de cargo a cuenta
    MONEY(16,2) AS montoEfectivo,   --Monto de pago en efectivo
    CHAR(1) AS forma_pago,
    CHAR(40) AS region,             --Region de la sucursal
    CHAR(4) AS sucursal,            --Numero de la sucursal
    MONEY(16,2) AS montoTotal,      --Monto total de la transaccion
    CHAR(10) AS operador,           --Operador que realiza la transaccion
    CHAR(20) AS cuentacargo,        --Cuenta a la que se realizo el cargo
    SMALLINT AS ciclo;

    -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE iIsamErr                 INTEGER;
    DEFINE iCuantos                 INTEGER;
    DEFINE cTransCargoTelmex        CHAR(4);
    DEFINE cTransCargoCoppel        CHAR(4);
    DEFINE cInfoErr                 CHAR(100);
    DEFINE cCodRetParam             CHAR(5);
    DEFINE cIdConvenio              CHAR(5);
    DEFINE cFormaPago               CHAR(3);
    DEFINE cIdReferencia1           CHAR(100);
    DEFINE cIdReferencia2           CHAR(100);
    DEFINE cRegion                  CHAR(40);
    DEFINE cFolioSuc                CHAR(16);
    DEFINE cReferencia1             CHAR(40);
    DEFINE cReferencia2             CHAR(40);
    DEFINE cNomconvenio             CHAR(40);
    DEFINE mCargoCuenta             MONEY(16,2);
    DEFINE mCargoEfectivo           MONEY(16,2);
    DEFINE siCiclo                  SMALLINT;
    DEFINE cFecha_Hoy               CHAR(10);
    DEFINE mImporteTotal            MONEY(16,2);
    DEFINE cOperador                CHAR(10);
    DEFINE cCuentaCargo             CHAR(20);
    DEFINE cTransEfecTelmex         CHAR(4);
    DEFINE cTransEfecCoppel         CHAR(4);
    DEFINE ctransEfecEnvioOrden			CHAR(4);
    DEFINE ctransEfecEnvioComision		CHAR(4);
    DEFINE ctransEfecEnvioIVA			CHAR(4);
    DEFINE ctransCargoEnvioOrden		CHAR(4);
    DEFINE ctransCargoEnvioComision		CHAR(4);
    DEFINE ctransCargoEnvioIVA			CHAR(4);
    DEFINE ctransEfecPagoOrden			CHAR(4);
    DEFINE ctransEfecCancelacionOrden	CHAR(4);
	DEFINE cTransCargoSky    			CHAR(4);
    DEFINE cTransEfecSky            	CHAR(4);
    DEFINE cTransCargo					CHAR(4);
    DEFINE cTransEfec					CHAR(4);
	DEFINE siProcesoAutomatico			SMALLINT;
--HOMOLOGACION GDF
	DEFINE cTranCredPGDF   				CHAR(100);
--HOMOLOGACION CLUB DE PROTECCION COPPEL
	DEFINE cTranCredPCP   				CHAR(100);
--HOMOLOGACION TAE
	DEFINE cTranCredPTAE   				CHAR(100);
--HOMOLOGACION EDOMEX
	DEFINE cTranCredEDOMEX   			CHAR(100);
	
    DEFINE cCconsmovhis      CHAR(10);	
    --INICIALIZACION DE VARIABLES--
    LET cCodRet               = "00000";
    LET cCodRetParam          = "";
    LET cIdConvenio           = "";
    LET cIdReferencia1        = "";
    LET cIdReferencia2        = "";
    LET cFolioSuc             = "";
    LET cReferencia1          = "";
    LET cReferencia2          = "";
    LET cNomconvenio          = "";
    LET cFormaPago            = "";
    LET cRegion               = "";
    LET cTransCargoTelmex     = "";
    LET cTransCargoCoppel     = "";
    LET mCargoCuenta          = 0;
    LET mCargoEfectivo        = 0;
    LET siCiclo               = 0;
    LET iCuantos              = 0;
    LET cFecha_Hoy            = "";
    LET mImporteTotal         = 0;
    LET cOperador             = '';
    LET cCuentaCargo          = '';
    LET cTransEfecTelmex      = '';
    LET cTransEfecCoppel      = '';
	LET ctransEfecEnvioOrden		= "";
    LET ctransEfecEnvioComision     = "";
    LET ctransEfecEnvioIVA			= "";
    LET ctransCargoEnvioOrden		= "";
    LET ctransCargoEnvioComision    = "";
    LET ctransCargoEnvioIVA			= "";
    LET ctransEfecPagoOrden			= "";
    LET ctransEfecCancelacionOrden  = "";
	LET cTransCargoSky    			= "";
    LET cTransEfecSky            	= "";
    LET cTransCargo					= "";
    LET cTransEfec					= "";
	LET siProcesoAutomatico			= 0;
--HOMOLOGACION GDF	
	LET cTranCredPGDF   		    = '';
--HOMOLOGACION CLUB DE PROTECCION COPPEL	
	LET cTranCredPCP   		    = '';
--HOMOLOGACION TAE
	LET cTranCredPTAE   	 = "";
--HOMOLOGACION EDOMEX
	LET cTranCredEDOMEX  	 = "";	
	
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

            IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportecobranzasucursal");
                    RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
            END IF;

        END EXCEPTION;

	--SET DEBUG FILE TO  "/home/sysifx/JesusBueno/sacreportehis_suc.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
        IF  cSucursal = "" OR LENGTH(cSucursal) <> 4 THEN
                LET cCodRet = "00001";
                RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
        ELSE
            
            SELECT  fecha_hoy
            INTO cFecha_hoy
            FROM bdisac:"informix".sac_fechas
			WHERE empresa='001';

            SELECT valor
            INTO cCconsmovhis
            FROM bdicheq:"informix".sc_param
            WHERE codparam = 'fechcon_movhis' AND empresa = '001';

			SELECT LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoTelmex AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoTelmex,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoCoppel AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoCoppel,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecCoppel AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecCoppel,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecTelmex AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecTelmex,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecEnvioOrden AS INTEGER)), 0)AS CHAR(4))), 4, '0') AS transEfecEnvioOrden,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecEnvioComision AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecEnvioComision,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecEnvioIVA AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecEnvioIVA,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoEnvioOrden AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoEnvioOrden,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoEnvioComision AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoEnvioComision,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transCargoEnvioIVA AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoEnvioIVA,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecPagoOrden AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecPagoOrden,
					LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecCancelacionOrden AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecCancelacionOrden,
					LPAD (TRIM(CAST(NVL(SUM(CAST(transCargoSky AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transCargoSky,
                    LPAD(TRIM(CAST(NVL(SUM(CAST(transEfecSky AS INTEGER)), 0) AS CHAR(4))), 4, '0') AS transEfecSky
			INTO cTransCargoTelmex,
					cTransCargoCoppel,
					cTransEfecCoppel,
					cTransEfecTelmex,
					ctransEfecEnvioOrden,
					ctransEfecEnvioComision,
					ctransEfecEnvioIVA,
					ctransCargoEnvioOrden,
					ctransCargoEnvioComision,
					ctransCargoEnvioIVA,
					ctransEfecPagoOrden,
					ctransEfecCancelacionOrden,
					cTransCargoSky,
	                cTransEfecSky
			FROM TABLE(MULTISET(SELECT CASE WHEN cod_param = 80001 THEN TRIM(VALOR) END AS transCargoTelmex,
                                        CASE WHEN cod_param = 80002 THEN TRIM(VALOR) END AS transCargoCoppel,
                                        CASE WHEN cod_param = 901001 THEN TRIM(VALOR) END AS transEfecCoppel,
                                        CASE WHEN cod_param = 902001 THEN TRIM(VALOR) END AS transEfecTelmex,
                                        CASE WHEN cod_param = 5070011 THEN TRIM(VALOR) END AS transEfecEnvioOrden,
                                        CASE WHEN cod_param = 511070011 THEN TRIM(VALOR) END AS transEfecEnvioComision,
                                        CASE WHEN cod_param = 510070011 THEN TRIM(VALOR) END AS transEfecEnvioIVA,
                                        CASE WHEN cod_param = 5070012 THEN TRIM(VALOR) END AS transCargoEnvioOrden,
                                        CASE WHEN cod_param = 511070012 THEN TRIM(VALOR) END AS transCargoEnvioComision,
                                        CASE WHEN cod_param = 510070012 THEN TRIM(VALOR) END AS transCargoEnvioIVA,
                                        CASE WHEN cod_param = 41407002 THEN TRIM(VALOR) END AS transEfecPagoOrden,
                                        CASE WHEN cod_param = 41507003 THEN TRIM(VALOR) END AS transEfecCancelacionOrden,
										CASE WHEN cod_param = 80006 THEN TRIM(VALOR) END AS transCargoSky,
										CASE WHEN cod_param = 906001 THEN TRIM(VALOR) END AS transEfecSky
                                FROM bdisac:"informix".sac_param));



            IF dFechaIni > cFecha_hoy THEN
                LET cCodRet = "00001";
                RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
            ELSE

                FOREACH
                
                    SELECT  b.folio_suc, f.numcategoria||f.numconvenio AS numconvenio,f.nomconvenio, b.referencia1, b.referencia2, b.forma_pago, e.nombre, b.importe_pago, b.usuario, b.cuenta_cargo, f.trans_cen_cargo_cliente, f.trans_cen_efectivo_cliente, f.proceso_automatico,
							f.nombre_referencia1, f.nombre_referencia2
                    INTO cFolioSuc, cIdConvenio, cNomconvenio,cReferencia1, cReferencia2, cFormaPago, cRegion, mImporteTotal, cOperador, cCuentaCargo, cTransCargo, cTransEfec, 
							siProcesoAutomatico, cIdReferencia1, cIdReferencia2
                    FROM bdisac:"informix".sac_movimientoshistorial b, bdinteg:"informix".si_sucursales c, bdinteg:"informix".si_plazas d, bdinteg:"informix".si_regional e, bdisac:"informix".sac_convenios f
                    WHERE b.numcategoria = f.numcategoria
                    AND b.id_sucursal = cSucursal
                    AND b.numconvenio = f.numconvenio
                    AND b.status_cancelado <> 'S'
                    AND b.fecha_pago  = dFechaIni
                    AND c.sucursal = b.id_sucursal
                    AND d.plaza = c.plaza
                    AND e.empresa = '001'
                    AND e.regional = d.regional
                    ORDER BY folio_suc

					IF siProcesoAutomatico = 1 THEN
						IF cFormaPago = '1' THEN
							LET mCargoEfectivo = mImporteTotal;
							LET mCargoCuenta = 0;
						ELIF cFormaPago = '2' OR cFormaPago = '4' THEN
							LET mCargoCuenta = mImporteTotal;
							LET mCargoEfectivo = 0;
--HOMOLOGACION GDF
						ELIF cFormaPago = '3' OR cFormaPago = '5' THEN
                            IF dFechaIni >= cCconsmovhis THEN

                                --SELECT {+ INDEX (bdicheq:"informix".sc_movhis idx_movhisnew6) } NVL(SUM(monto_tot), 0) AS totEfectivo
								SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                INTO mCargoEfectivo
                                FROM bdicheq:"informix".sc_movhis
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransEfec
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;

								--SELECT {+ INDEX (bdicheq:"informix".sc_movhis idx_movhisnew6) } NVL(SUM(monto_tot), 0) AS totCargo
                                SELECT NVL(SUM(monto_tot), 0) AS totCargo
                                INTO mCargoCuenta
                                FROM bdicheq:"informix".sc_movhis
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransCargo
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;
								
								
                            ELSE

                                SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                INTO mCargoEfectivo
                                FROM bdicheq:"informix".sc_movhis_old
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransEfec
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;

                                SELECT NVL(SUM(monto_tot), 0) AS totCargo
                                INTO mCargoCuenta
                                FROM bdicheq:"informix".sc_movhis_old
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransCargo
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;

                            END IF;
							--HOMOLOGACION GDF
							--20130109.1030 inicio
							IF cIdConvenio = '08001' THEN
								SELECT NVL(TRIM(valor),'')
								INTO cTranCredPGDF 
								FROM bdisac:"informix".sac_param 
								WHERE cod_param = '87033';
								
								SELECT NVL(SUM(monto_totCargo), 0) AS totCargo
								INTO mCargoCuenta
								FROM TABLE(MULTISET(SELECT CASE WHEN transacc_suc = cTranCredPGDF  
													THEN monto END AS monto_totCargo
													FROM bdicred:"informix".sd_movhis
													WHERE folio_suc = cFolioSuc AND empresa='001'));
							END IF;
							--20130109.1030 fin
							
							--HOMOLOGACION CLUB DE PROTECCION
							--20140902.1358 inicio
							IF cIdConvenio = '01002' THEN
								SELECT NVL(TRIM(valor),'')
								INTO cTranCredPCP 
								FROM bdisac:"informix".sac_param 
								WHERE cod_param = 80;

								SELECT NVL(SUM(monto), 0) AS totCargo
								INTO mCargoCuenta
								FROM bdicred:"informix".sd_movhis
								WHERE folio_suc = cFolioSuc AND empresa='001';
							END IF;
							--20140902.1358 fin				

							--HOMOLOGACION TAE
							--20150120.1506 inicio
							IF	cIdConvenio = '03001' THEN

								SELECT NVL(TRIM(valor),'')
								INTO cTranCredPTAE 
								FROM bdisac:"informix".sac_param 
								WHERE cod_param = 20;

								SELECT NVL(SUM(monto), 0) AS totCargo
								INTO mCargoCuenta
								FROM bdicred:"informix".sd_movdia
								WHERE folio_suc = cFolioSuc AND empresa='001';
							END IF;
							--20150120.1506 FIN
							
							--HOMOLOGACION EDOMEX
							--20150217.1202 inicio
							IF	cIdConvenio = '08002' THEN

								SELECT NVL(TRIM(valor),'')
								INTO cTranCredEDOMEX 
								FROM bdisac:"informix".sac_param 
								WHERE cod_param = 23;

								SELECT NVL(SUM(monto), 0) AS totCargo
								INTO mCargoCuenta
								FROM bdicred:"informix".sd_movdia
								WHERE folio_suc = cFolioSuc AND empresa='001';
							END IF;
							--20150217.1202 FIN
							
							
						END IF;
						
					ELSE		

                    SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia1
					FROM bdisac:"informix".sac_param
					WHERE empresa='001' AND cod_param= '6' || cIdConvenio || '1';
					/*AND SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = '08001'
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '1';*/

                    SELECT {+INDEX (bdisac:"informix".sac_param idxsc_par)} valor
					INTO cIdReferencia2
					FROM bdisac:"informix".sac_param
					WHERE empresa='001' AND cod_param= '6' || cIdConvenio || '2'; 
					/*AND SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = cIdConvenio
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '2';*/

					IF cFormaPago = '1' AND cIdConvenio <> '07001' THEN
					   LET mCargoEfectivo = mImporteTotal;
					   LET mCargoCuenta = 0;
					ELIF cFormaPago = '2' AND cIdConvenio <> '07001' THEN
					   LET mCargoCuenta = mImporteTotal;
					   LET mCargoEfectivo = 0;
					ELIF cFormaPago = '3' OR cIdConvenio = '07001' THEN

---
                    IF dFechaIni >= cCconsmovhis THEN
                    IF cIdConvenio = '01001' THEN

						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
						
                    ELIF cIdConvenio = '02001' THEN

						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
						
					ELIF cIdConvenio = '06001' THEN
								
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecSky
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoSky
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
					
					ELIF cIdConvenio = '07001' THEN
					
						LET mImporteTotal = 0;
							FOREACH
								SELECT {+INDEX (bdisac:"informix".sac_enviosdineroya idxsac_envdinya13_1)} NVL(SUM(importe_total),0) 
								INTO mImporteTotal 
								FROM bdisac:"informix".sac_enviosdineroya
								WHERE no_control = cReferencia1 AND estatus IS NOT NULL
								UNION ALL
								SELECT {+INDEX (bdisac:"informix".sac_enviosdineroyahis idxsac_envdinyahis13_1)} NVL(SUM(importe_total),0)
								FROM bdisac:"informix".sac_enviosdineroyahis
								WHERE no_control = cReferencia1 AND estatus IS NOT NULL 
								ORDER BY 0
												
								IF cFormaPago = '1' THEN
									LET mCargoEfectivo = mImporteTotal;
									LET mCargoCuenta = 0;
								ELIF cFormaPago = '2' THEN
									LET mCargoCuenta = mImporteTotal;
									LET mCargoEfectivo = 0;
								ELIF cFormaPago = '3' THEN

								SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
								INTO mCargoEfectivo
								FROM bdicheq:"informix".sc_movhis
								WHERE empresa = '001'
								AND fech_alt = dFechaIni
								AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
								AND sucursal = cSucursal
								AND folio_suc = cFolioSuc;

								SELECT NVL(SUM(monto_tot), 0) AS totCargo
								INTO mCargoCuenta
								FROM bdicheq:"informix".sc_movhis
								WHERE empresa = '001'
								AND fech_alt = dFechaIni
								AND transacc IN (ctransCargoEnvioOrden, ctransCargoEnvioComision, ctransCargoEnvioIVA)
								AND sucursal = cSucursal
								AND folio_suc = cFolioSuc;

							END IF;
						END FOREACH;
-- MODIFICACION 
				    LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);

					ELIF cIdConvenio = '07002' THEN
		
						LET mCargoCuenta = 0;

						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = ctransEfecPagoOrden
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

					ELIF cIdConvenio = '07003' THEN
					
						LET mCargoCuenta = 0;

						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = ctransEfecCancelacionOrden
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
                    END IF;
                 ELSE
                    IF cIdConvenio = '01001' THEN
 
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

                    ELIF cIdConvenio = '02001' THEN

						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
						
					ELIF cIdConvenio = '06001' THEN
								
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecSky
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoSky
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
					
					ELIF cIdConvenio = '07001' THEN
					
						LET mImporteTotal = 0;
							FOREACH
								SELECT {+INDEX (bdisac:"informix".sac_enviosdineroya idxsac_envdinya13_1)} NVL(SUM(importe_total),0) 
								INTO mImporteTotal 
								FROM bdisac:"informix".sac_enviosdineroya
								WHERE no_control = cReferencia1 AND estatus IS NOT NULL
								UNION ALL
								SELECT {+INDEX (bdisac:"informix".sac_enviosdineroyahis idxsac_envdinyahis13_1)} NVL(SUM(importe_total),0)
								FROM bdisac:"informix".sac_enviosdineroyahis
								WHERE no_control = cReferencia1 AND estatus IS NOT NULL 
								ORDER BY 0
						
						
								IF cFormaPago = '1' THEN
									LET mCargoEfectivo = mImporteTotal;
									LET mCargoCuenta = 0;
								ELIF cFormaPago = '2' OR cFormaPago = '4' THEN
									LET mCargoCuenta = mImporteTotal;
									LET mCargoEfectivo = 0;
								ELIF cFormaPago = '3' THEN

								SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
								INTO mCargoEfectivo
								FROM bdicheq:"informix".sc_movhis_old
								WHERE empresa = '001'
								AND fech_alt = dFechaIni
								AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
								AND sucursal = cSucursal
								AND folio_suc = cFolioSuc;

								SELECT NVL(SUM(monto_tot), 0) AS totCargo
								INTO mCargoCuenta
								FROM bdicheq:"informix".sc_movhis_old
								WHERE empresa = '001'
								AND fech_alt = dFechaIni
								AND transacc IN (ctransCargoEnvioOrden, ctransCargoEnvioComision, ctransCargoEnvioIVA)
								AND sucursal = cSucursal
								AND folio_suc = cFolioSuc;

							END IF;
						END FOREACH;
-- MODIFICACION 
					    LET cReferencia1='********'||SUBSTRING (cReferencia1 FROM 9 FOR 4);

					ELIF cIdConvenio = '07002' THEN
		
						LET mCargoCuenta = 0;

						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = ctransEfecPagoOrden
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

					ELIF cIdConvenio = '07003' THEN
					
						LET mCargoCuenta = 0;

						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = ctransEfecCancelacionOrden
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
                        
                    END IF;
                END IF;
--------
                    IF cIdConvenio = '07001' THEN

                    END IF
			END IF;
					END IF;
                    LET siCiclo = siCiclo + 1;

        -- PAGINACION
                    IF siCiclo <= siRegistros THEN
                        CONTINUE FOREACH;
                    END IF;

                        RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo
                    WITH RESUME;
                END FOREACH;

            END IF
        END IF;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener lo movimientos de la cobranza de pago de servicios para una fecha especifica',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Noviembre 2009',
'VERSION: 20091207.1305',
'BD    : bdisac',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para ordenes de pago',
'VERSION DE CAMBIO: 20100420.1659',
'MODIFICA : Dulce Ramirez',
'DESCRIPCION: Se agrega SUM al campo importe_total, para que no regrese valor nulo en caso de no encontrar registro',
'VERSION DE CAMBIO: 20100507.1245',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Se corrige para que obtenga correctamente los totales de los historicos',
'VERSION DE CAMBIO: 20100512.0838',
'MODIFICA : Dulce Ramirez',
'DESCRIPCION: Se agregan validaciones para que contemple los movimientos para pagos sky',
'VERSION DE CAMBIO: 20100521.1719',
'MODIFICA : Raul Ruiz',
'DESCRIPCION: Junto con la integracion de Pagos MVS se integra la modificacion para los convenios en proceso automatico para su funcionamiento dinamico',
'VERSION DE CAMBIO: 20100923.1843',
'MODIFICA : Dulce Ramírez',
'DESCRIPCION: Se modifica para incluir la forma de pago 4 "Abono en cuenta" para pago de remesas BTS',
'VERSION DE CAMBIO: 20100923.1843',
'                                    ',
'MODIFICA : Martín Eduardo Miranda',
'DESCRIPCION: Se agrega nuevo retorno "cIdConvenio" para ordenar el reporte diario de Servicios por sucursal',
'VERSION DE CAMBIO: 20120830.1629',

'MODIFICA : Martha Aguirre',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 8001',
'             "Pago de Servicios del Gobierno del Distrito Federal',
'VERSION DE CAMBIO: 20130109.1030',
'Folio:1570',
'Autor:95142134 Mario Gallardo',
'Fecha:24/01/2014',
'Modificación: Se modifica referencia1 y referencia2 a 40 carcateres.',
'Sustento: RQI 62 064-Reingeniería_PagoServicios -  (Pagina 2 a 36)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'MODIFICA : Rigoberto Gonzalez Llanes',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 01002',
'             "Pago de Servicios del club de proteccion coppel',
'VERSION DE CAMBIO: 20140902.1358',
'MODIFICA : Jesus Isaias Bueno',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 03001',
'             para el pago de TAE',
'VERSION DE CAMBIO: 20150123.1120',
'MODIFICA : Jesus Isaias Bueno',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 08002',
'             para el pago se servicios EDOMEX',
'VERSION DE CAMBIO: 20150217.1204';

CREATE PROCEDURE "informix".sp_repaudit_ctesidbox(MesAnio CHAR(6))

	RETURNING
		CHAR	(25) as archivo,
		CHAR	(5) as codret,
		CHAR	(100) as mensaje;

	-- DECLARACION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE iSamErr			INTEGER;
	DEFINE cProceso			CHAR(100);
	DEFINE cCodRet			CHAR(5);
	DEFINE cVarError		CHAR(100);
	DEFINE cRuta			CHAR(50);
	DEFINE cNombreArchivo1	CHAR(50);
	DEFINE cNombreArchivo2	CHAR(50);
	DEFINE cNombreArchivo3	CHAR(50);
	DEFINE cSQL 			CHAR(4000);
	DEFINE cAnioMesAct		CHAR(6);
	DEFINE cFechaIni		DATE;
	DEFINE cFechaFin		DATE;
	

	-- INICIALIZAN LAS VARIABLES
	LET cProceso = 'ArchsAuditCtesIDbox';
	LET cCodRet = '00000';
	LET cVarError = 'Ejecucion Exitosa';
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo1 = 'si_cliente_';
	LET cNombreArchivo2 = 'si_ctepf_';
	LET cNombreArchivo3 = 'si_bitacora_ife_';
	LET cSQL = '';
	LET cAnioMesAct='';
	LET cFechaIni = '';
	LET cFechaFin = '';
	

	BEGIN

	-- CONTROL DE ERRORES
	ON EXCEPTION SET iSqlErr, iSamErr, cVarError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cVarError = 'Error No Controlado';

			SET DEBUG FILE TO "/RESPALDOSNEW/sp_repaudit_ctesidbox.out";
			TRACE ON;

			INSERT INTO "informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
  			VALUES(trim(cProceso) || ': ' || iSqlErr, Today, '0', 'informix', current, 1, 'sp_repaudit_ctesidbox', 'Generar Archivos Mensuales Para Auditoria de Clientes y IDBOX');


			RETURN cProceso, cCodRet, cVarError;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/noe/41922/sp_repaudit_ctesidbox.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	
--OBTIENE LOS DIAS INICIO Y FIN DEL MES ANTERIOR
	IF length(MesAnio)=6 THEN
		SELECT first 1 mdy(SUBSTR(MesAnio,1,2),'01',SUBSTR(MesAnio,3,4)) inicio, CAST((mdy(SUBSTR(MesAnio,1,2),'01',SUBSTR(MesAnio,3,4))+01 UNITS MONTH)-1 UNITS DAY AS DATE) fin 
		INTO cFechaIni, cFechaFin
		FROM sac_fechas;
		
		LET cAnioMesAct=MesAnio;
	ELSE
		SELECT first 1 date(LAST_DAY(ADD_MONTHS(today, -2)) + 1), date(LAST_DAY(ADD_MONTHS(today, -1))), TO_CHAR(TODAY-1 UNITS MONTH, '%m%Y')
		INTO cFechaIni, cFechaFin, cAnioMesAct
		FROM systables WHERE tabid = 1;
	END IF;

	
--NOMBRE DEL ARCHIVO
	LET cRuta = '/RESPALDOSNEW/';
	LET cNombreArchivo1 = 'si_cliente_' || cAnioMesAct || '.unl';
	LET cNombreArchivo2 = 'si_ctepf_' || cAnioMesAct || '.unl';
	LET cNombreArchivo3 = 'si_bitacora_ife_' || cAnioMesAct || '.unl';

--BORRA ARCHIVOS SI YA EXISTIERAN
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo1) || '.gz';
	SYSTEM TRIM(cSQL);
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo2) || '.gz';
	SYSTEM TRIM(cSQL);
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || TRIM(cNombreArchivo3) || '.gz';
	SYSTEM TRIM(cSQL);

	
--ARCHIVO 1 (ENCABEZADOS)
	LET cSQL = '';  
	LET cSQL = 'echo "empresa|numcte|status_cte|sucursal|ejecutivo|tpo_persona|tipo_cliente|apell_paterno|apell_materno|nombre1|nombre2|razon_social|rfc|sector|segmento|actividad_princ|grupo|subgrupo|residencia|fecha_alta|apell_casada|distrito|numcte_ref|string1|string2|numeric1|numeric2|money1|date1|puesto_ppes|familiar_ppes|actividad_esp|ejecut_autoriza|user_insert|fecha_insert|rfc_alterno|tpo_biometria|cliente_pros|envio_movtos|" >' || TRIM(cRuta) || TRIM(cNombreArchivo1);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
--ARCHIVO 1 (DESCARGA)
	LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempCL.unl' || ' DELIMITER ' || '''|''' || ' SELECT CL.* FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || ''');" >' || TRIM(cRuta) || 'genArchRepAudit1.sql';
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempCL.unl' || ' DELIMITER ' || '''|''' || ' SELECT CL.* FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and PF.codidentifi=''A'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || ''');" >' || TRIM(cRuta) || 'genArchRepAudit1.sql';
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'genArchRepAudit1.sql' ;
--EJECUTA EL ARCHIVO
	LET cSQL='dbaccess bdinteg ' || TRIM(cRuta) || 'genArchRepAudit1.sql';
	SYSTEM TRIM(cSQL);
--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'genArchRepAudit1.sql';
	SYSTEM TRIM(cSQL);
	LET cSQL = '';
--AGREGA ENCABEZADOS
	LET cSQL = 'tail -n +1 ' || TRIM(cRuta) || 'tempCL.unl >> ' || TRIM(cRuta) || TRIM(cNombreArchivo1);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'tempCL.unl';
	SYSTEM TRIM(cSQL);

	



--ARCHIVO 2 (ENCABEZADOS)
	LET cSQL = '';  
	LET cSQL = 'echo "empresa|numcte|fecha_nac|lugar_nac|nacionalidad|no_fm3|estado_civil|regim_matrimonio|profesion|sexo|curp|codifi|numidentifi|no_imss|dependientes|tutor|nom_conyuge|seguro_defunc|escolaridad|habita_en|anios_habita|nombre_prop|imp_hipo_renta|actividadogiro|numeroife|numerotutor|numeroconyuge|string1|string2|numeric1|numeric2|money1|date1|user_insert|fecha_insert|sms_cel|hora_insert|validacurp|id_pais|" >' || TRIM(cRuta) || TRIM(cNombreArchivo2);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
--ARCHIVO 2 (DESCARGA)
	LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempPF.unl' || ' DELIMITER ' || '''|''' || ' SELECT PF.* FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || ''');" >' || TRIM(cRuta) || 'genArchRepAudit2.sql';
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempPF.unl' || ' DELIMITER ' || '''|''' || ' SELECT PF.* FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and PF.codidentifi=''A'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || ''');" >' || TRIM(cRuta) || 'genArchRepAudit2.sql';
	SYSTEM TRIM(cSQL);
--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'genArchRepAudit2.sql' ;
--EJECUTA EL ARCHIVO
	LET cSQL='dbaccess bdinteg ' || TRIM(cRuta) || 'genArchRepAudit2.sql';
	SYSTEM TRIM(cSQL);
--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'genArchRepAudit2.sql';
	SYSTEM TRIM(cSQL);
	LET cSQL = '';
--AGREGA ENCABEZADOS
	LET cSQL = 'tail -n +1 ' || TRIM(cRuta) || 'tempPF.unl >> ' || TRIM(cRuta) || TRIM(cNombreArchivo2);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'tempPF.unl';
	SYSTEM TRIM(cSQL);


--ARCHIVO 3 (ENCABEZADOS)
	LET cSQL = '';  
	LET cSQL = 'echo "numcte|ejecutivo|sucursal|cadena_anverso|cadena_reverso|flag_idbox|flag_ws|flag_captura|resultado|causa_rechazo|fecha|cod_resp_ife|resp_ife|time_ife|access_ife|stamp_ife|ocr_ife|appat_ife|apmat_ife|nombre_ife|callenum_ife|colcp_ife|mpoent_ife|folional_ife|anioreg_ife|emision_ife|cveelec_ife|curp_ife|localidad_ife|seccion_ife|anioemision_ife|vigencia_ife|edad_ife|sexo_ife|ansi2_ife|ansi7_ife|modelo_ife|actualizado|test_uv_reflec_anv|test_uv_shape_anv|test_ir_ink_anv|test_uv_reflectance_rev|test_ir_ink_rev|" >' || TRIM(cRuta) || TRIM(cNombreArchivo3);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
--ARCHIVO 3 (DESCARGA)
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and length(trim(resp_ife)) > 0 and resp_ife not in(''Consulta no exitosa al procesar peticiÃÂÃÂÃÂÃÂ³n'',''Desconectado'',''No se ha enviado OCR'') AND cod_resp_ife not in (''          '',''00'') AND resp_ife not in ('''') AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂÃÂÃÂ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂÃÂÃÂ³n''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and ((length(trim(resp_ife)) > 0 and trim(modelo_ife) <> ''IDMEXG1'') OR (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) and resp_ife not in(''Consulta no exitosa al procesar peticiÃÂÃÂ³n'',''Desconectado'',''No se ha enviado OCR'') AND ((cod_resp_ife not in (''          '',''00'') and trim(modelo_ife) <> ''IDMEXG1'') OR (cod_resp_ife in (''          '',''00'') and trim(modelo_ife) = ''IDMEXG1'')) AND ((resp_ife not in ('''') and trim(modelo_ife) <> ''IDMEXG1'') OR (resp_ife in ('''') and trim(modelo_ife) = ''IDMEXG1'')) AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂ³n'' or trim(resp_ife)=''Consulta no exitosa al procesar peticion'')) OR (trim(resultado)=''Falso'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) OR (trim(resultado)=''Verdadero'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	--LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and ((length(trim(resp_ife)) > 0 and trim(modelo_ife) <> ''IDMEXG1'') OR (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) and resp_ife not in(''Consulta no exitosa al procesar peticiÃÂÃÂ³n'',''Desconectado'',''No se ha enviado OCR'') AND ((cod_resp_ife not in (''          '',''00'') and trim(modelo_ife) <> ''IDMEXG1'') OR (cod_resp_ife in (''          '',''00'') and trim(modelo_ife) = ''IDMEXG1'')) AND ((resp_ife not in ('''') and trim(modelo_ife) <> ''IDMEXG1'') OR (resp_ife in ('''') and trim(modelo_ife) = ''IDMEXG1'')) AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃÂÃÂ³n'' or trim(resp_ife)=''Consulta no exitosa al procesar peticion'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Falso'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) OR (trim(resultado)=''Verdadero'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
    --LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and ((length(trim(resp_ife)) > 0 and trim(modelo_ife) <> ''IDMEXG1'') OR (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) and resp_ife not in(''Consulta no exitosa al procesar peticiÃ³n'',''Desconectado'',''No se ha enviado OCR'') AND ((cod_resp_ife not in (''          '',''00'') and trim(modelo_ife) <> ''IDMEXG1'') OR (cod_resp_ife in (''          '',''00'') and trim(modelo_ife) = ''IDMEXG1'')) AND ((resp_ife not in ('''') and trim(modelo_ife) <> ''IDMEXG1'') OR (resp_ife in ('''') and trim(modelo_ife) = ''IDMEXG1'')) AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃ³n'' or trim(resp_ife)=''Consulta no exitosa al procesar peticion'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Falso'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) OR (trim(resultado)=''Verdadero'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and PF.codidentifi=''A'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
      LET cSQL = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'tempIFE.unl' || ' DELIMITER ' || '''|''' || ' SELECT numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws, flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, case when trim(resp_ife)=''VALIDACION DUMMY'' then ''La transaccion fue atendida con exito.'' else resp_ife end resp_ife, time_ife, access_ife, stamp_ife, ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, emision_ife, cveelec_ife, curp_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, actualizado, case when test_uv_reflec_anv=''0'' then ''NA'' else test_uv_reflec_anv end test_uv_reflec_anv, case when test_uv_shape_anv=''0'' then ''NA'' else test_uv_shape_anv end test_uv_shape_anv, case when test_ir_ink_anv=''0'' then ''NA'' else test_ir_ink_anv end test_ir_ink_anv, case when test_uv_reflectance_rev=''0'' then ''NA'' else test_uv_reflectance_rev end test_uv_reflectance_rev, case when test_ir_ink_rev=''0'' then ''NA'' else test_ir_ink_rev end test_ir_ink_rev FROM bdinteg:"informix".si_bitacora_ife WHERE fecha BETWEEN EXTEND(mdy(' || month(cFechaIni) || ',' || day(cFechaIni) || ',' || year(cFechaIni) || '), YEAR TO SECOND)+0 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND AND EXTEND(mdy(' || month(cFechaFin) || ',' || day(cFechaFin) || ',' || year(cFechaFin) || '), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND and ((length(trim(causa_rechazo))=0 and resultado = ''Verdadero'') or (length(trim(causa_rechazo)) > 0)) and ((length(trim(resp_ife)) > 0 and trim(modelo_ife) <> ''IDMEXG1'') OR (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) and resp_ife not in(''Consulta no exitosa al procesar peticiÃ³n'',''Desconectado'',''No se ha enviado OCR'') AND ((cod_resp_ife not in (''          '',''00'') and trim(modelo_ife) <> ''IDMEXG1'') OR (cod_resp_ife in (''          '',''00'') and trim(modelo_ife) = ''IDMEXG1'')) AND ((resp_ife not in ('''') and trim(modelo_ife) <> ''IDMEXG1'') OR (resp_ife in ('''') and trim(modelo_ife) = ''IDMEXG1'')) AND ((trim(resultado)=''Falso'' and (trim(resp_ife)=''El OCR no tiene formato adecuado'' or trim(resp_ife)=''OCR No Vigente'' or trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃ³n'' or trim(resp_ife)=''DATOS_NO_ENCONTRADOS'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''VALIDACION DUMMY'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Verdadero'' and (trim(resp_ife)=''OCR Vigente'' or trim(resp_ife)=''Ok, peticion satisfactoria'' or trim(resp_ife)=''Consulta no exitosa al procesar peticiÃ³n'' or trim(resp_ife)=''Consulta no exitosa al procesar peticion'' or trim(resp_ife)=''VALIDACION DUMMY'' or trim(resp_ife)=''La transaccion fue atendida con exito.'')) OR (trim(resultado)=''Falso'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1'')) OR (trim(resultado)=''Verdadero'' and (length(trim(resp_ife)) = 0 and trim(modelo_ife) = ''IDMEXG1''))) AND numcte IN(SELECT CL.numcte FROM bdinteg:"informix".si_ctepf PF, bdinteg:"informix".si_cliente CL WHERE CL.tipo_cliente=''1'' and PF.codidentifi=''A'' and CL.numcte=PF.numcte AND (CL.fecha_insert BETWEEN ''' || cFechaIni || ''' AND ''' || cFechaFin || '''));" >' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	SYSTEM TRIM(cSQL);
--PERMISO PARA LA EJECUCION DEL ARCHIVO.
	LET cSQL = '' ;
	LET cSQL = 'chmod 777 ' || TRIM(cRuta) || 'genArchRepAudit3.sql' ;
--EJECUTA EL ARCHIVO
	LET cSQL='dbaccess bdinteg ' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	SYSTEM TRIM(cSQL);
--SE BORRA ARCHIVO TEMP UNA VEZ GENERADO
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'genArchRepAudit3.sql';
	SYSTEM TRIM(cSQL);
--AGREGA ENCABEZADOS
	LET cSQL = 'tail -n +1 ' || TRIM(cRuta) || 'tempIFE.unl >> ' || TRIM(cRuta) || TRIM(cNombreArchivo3);
	SYSTEM TRIM(cSQL);
	LET cSQL = '';  
	LET cSQL = 'rm -rf ' || TRIM(cRuta) || 'tempIFE.unl';
	SYSTEM TRIM(cSQL);
	

--COMPRIME ARCHIVOS
	LET cSQL = '';
	LET cSQL = 'gzip ' || TRIM(cRuta) || TRIM(cNombreArchivo1);
	SYSTEM TRIM(cSQL);

	LET cSQL = '';  
	LET cSQL = 'gzip ' || TRIM(cRuta) || TRIM(cNombreArchivo2);
	SYSTEM TRIM(cSQL);

	LET cSQL = '';  
	LET cSQL = 'gzip ' || TRIM(cRuta) || TRIM(cNombreArchivo3);
	SYSTEM TRIM(cSQL);



--REGISTRA EN BITACORA
	INSERT INTO "informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
  	VALUES(trim(cProceso) || ': ' || cCodRet, Today, '1', 'informix', current, 1, 'sp_repaudit_ctesidbox', 'Generar Archivos Mensuales Para Auditoria de Clientes y IDBOX');
	
	RETURN cProceso, cCodRet, cVarError;

END;
END PROCEDURE;