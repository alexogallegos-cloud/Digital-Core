CREATE PROCEDURE "informix".sp_saccobranzasucursalhis(cSucursal CHAR(4), dFechaIni DATE, siRegistros SMALLINT)

    -- DATOS A REGRESAR
    RETURNING
    CHAR(5)  AS retorno,            --Codigo de Retorno
    CHAR(40) AS nombre,             --Nombre convenio
	CHAR(5)  AS IdConvenio,
    CHAR(16) AS folio_suc,          --Folio de sucursal
    CHAR(20) AS referencia1,        --Num telefono (Telmex), Num cliente(Coppel)
    CHAR(20) AS referencia2,        --DV (Telmex), Recibo(Coppel)
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
    DEFINE cReferencia1             CHAR(20);
    DEFINE cReferencia2             CHAR(20);
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


    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

            IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportecobranzasucursal");
                    RETURN cCodRet, cNomconvenio, cIdConvenio, cFolioSuc, cReferencia1, cReferencia2, cIdReferencia1, cIdReferencia2, mCargoCuenta, mCargoEfectivo,cFormaPago, cRegion, cSucursal, mImporteTotal, cOperador, cCuentaCargo, siCiclo ;
            END IF;

        END EXCEPTION;

	--SET DEBUG FILE TO  "/respaldosbd/Martha/sacreportehis_suc.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 5;
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

			--SET ISOLATION TO DIRTY READ;


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
                --SET ISOLATION TO DIRTY READ;
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
                                --SET ISOLATION TO DIRTY READ;
                                SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                INTO mCargoEfectivo
                                FROM bdicheq:"informix".sc_movhis
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransEfec
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;

                                --SET ISOLATION TO DIRTY READ;
                                SELECT NVL(SUM(monto_tot), 0) AS totCargo
                                INTO mCargoCuenta
                                FROM bdicheq:"informix".sc_movhis
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransCargo
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;
								
								
                            ELSE
                                --SET ISOLATION TO DIRTY READ;
                                SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                INTO mCargoEfectivo
                                FROM bdicheq:"informix".sc_movhis_old
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransEfec
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;

                                --SET ISOLATION TO DIRTY READ;
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
											WHERE  fecha_mov = dFechaIni AND sucursal = cSucursal AND folio_suc = cFolioSuc));
						END IF;
						--20130109.1030 fin	
							
						END IF;
			
					ELSE		

                    --SET ISOLATION TO DIRTY READ;
						SELECT valor
						INTO cIdReferencia1
						FROM bdisac:"informix".sac_param
						WHERE empresa='001' AND cod_param= '6' || cIdConvenio || '1';
						/*AND SUBSTRING(cod_param FROM 1 FOR 1) = '6'
						AND SUBSTRING (cod_param FROM 2 FOR 5) = '08001'
						AND SUBSTRING (cod_param FROM 7 FOR 1) = '1';*/

                    --SET ISOLATION TO DIRTY READ;
                        SELECT valor
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
 
                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
                    ELIF cIdConvenio = '02001' THEN

                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						--SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
					ELIF cIdConvenio = '06001' THEN
								
						--SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecSky
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						--SET ISOLATION TO DIRTY READ;
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
								SELECT NVL(SUM(importe_total),0) 
								INTO mImporteTotal 
								FROM bdisac:"informix".sac_enviosdineroya
								WHERE no_control = cReferencia1 AND estatus IS NOT NULL
								UNION ALL
								SELECT NVL(SUM(importe_total),0)
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

								--SET ISOLATION TO DIRTY READ;
								SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
								INTO mCargoEfectivo
								FROM bdicheq:"informix".sc_movhis
								WHERE empresa = '001'
								AND fech_alt = dFechaIni
								AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
								AND sucursal = cSucursal
								AND folio_suc = cFolioSuc;

								--SET ISOLATION TO DIRTY READ;
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
                        --SET ISOLATION TO DIRTY READ;
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
                        --SET ISOLATION TO DIRTY READ;
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
 
                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

                    ELIF cIdConvenio = '02001' THEN

                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						--SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
					ELIF cIdConvenio = '06001' THEN
								
						--SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecSky
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						--SET ISOLATION TO DIRTY READ;
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
								SELECT NVL(SUM(importe_total),0) 
								INTO mImporteTotal 
								FROM bdisac:"informix".sac_enviosdineroya
								WHERE no_control = cReferencia1 AND estatus IS NOT NULL
								UNION ALL
								SELECT NVL(SUM(importe_total),0)
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

								--SET ISOLATION TO DIRTY READ;
								SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
								INTO mCargoEfectivo
								FROM bdicheq:"informix".sc_movhis_old
								WHERE empresa = '001'
								AND fech_alt = dFechaIni
								AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
								AND sucursal = cSucursal
								AND folio_suc = cFolioSuc;

								--SET ISOLATION TO DIRTY READ;
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
                        --SET ISOLATION TO DIRTY READ;
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
                        --SET ISOLATION TO DIRTY READ;
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
'MODIFICA : Dulce RamÃÂ­rez',
'DESCRIPCION: Se modifica para incluir la forma de pago 4 "Abono en cuenta" para pago de remesas BTS',
'VERSION DE CAMBIO: 20100923.1843',
'                                    ',
'MODIFICA : MartÃÂ­n Eduardo Miranda',
'DESCRIPCION: Se agrega nuevo retorno "cIdConvenio" para ordenar el reporte diario de Servicios por sucursal',
'VERSION DE CAMBIO: 20120830.1629',

'MODIFICA : Martha Aguirre',
'DESCRIPCION: Se agrega bÃÂºsqueda de monto para el movimiento de cargo en cuenta de crÃÂ©dito para el cIdConvenio 8001',
'             "Pago de Servicios del Gobierno del Distrito Federal',
'VERSION DE CAMBIO: 20130109.1030';

CREATE PROCEDURE "informix".sp_saccobranzasucursalhis(cSucursal CHAR(4), dFechaIni DATE, siRegistros SMALLINT,stipo smallint)

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
	
	SET LOCK MODE TO WAIT 5;
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

			--SET ISOLATION TO DIRTY READ;


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
                --SET ISOLATION TO DIRTY READ;
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
                                --SET ISOLATION TO DIRTY READ;
                                SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                INTO mCargoEfectivo
                                FROM bdicheq:"informix".sc_movhis
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransEfec
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;

                                --SET ISOLATION TO DIRTY READ;
                                SELECT NVL(SUM(monto_tot), 0) AS totCargo
                                INTO mCargoCuenta
                                FROM bdicheq:"informix".sc_movhis
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransCargo
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;
								
								
                            ELSE
                                --SET ISOLATION TO DIRTY READ;
                                SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
                                INTO mCargoEfectivo
                                FROM bdicheq:"informix".sc_movhis_old
                                WHERE empresa = '001'
                                AND fech_alt = dFechaIni
                                AND transacc = cTransEfec
                                AND sucursal = cSucursal
                                AND folio_suc = cFolioSuc;

                                --SET ISOLATION TO DIRTY READ;
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
													WHERE fecha_mov= dFechaIni AND sucursal = cSucursal AND folio_suc = cFolioSuc));
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
								WHERE fecha_mov= dFechaIni AND sucursal = cSucursal AND folio_suc = cFolioSuc;
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

                    --SET ISOLATION TO DIRTY READ;
                    SELECT valor
					INTO cIdReferencia1
					FROM bdisac:"informix".sac_param
					WHERE empresa='001' AND cod_param= '6' || cIdConvenio || '1';
					/*AND SUBSTRING(cod_param FROM 1 FOR 1) = '6'
					AND SUBSTRING (cod_param FROM 2 FOR 5) = '08001'
					AND SUBSTRING (cod_param FROM 7 FOR 1) = '1';*/

                    --SET ISOLATION TO DIRTY READ;
                    SELECT valor
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
 
                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
						
                    ELIF cIdConvenio = '02001' THEN

                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						--SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
						
					ELIF cIdConvenio = '06001' THEN
								
						--SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecSky
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						--SET ISOLATION TO DIRTY READ;
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
								SELECT NVL(SUM(importe_total),0) 
								INTO mImporteTotal 
								FROM bdisac:"informix".sac_enviosdineroya
								WHERE no_control = cReferencia1 AND estatus IS NOT NULL
								UNION ALL
								SELECT NVL(SUM(importe_total),0)
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

								--SET ISOLATION TO DIRTY READ;
								SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
								INTO mCargoEfectivo
								FROM bdicheq:"informix".sc_movhis
								WHERE empresa = '001'
								AND fech_alt = dFechaIni
								AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
								AND sucursal = cSucursal
								AND folio_suc = cFolioSuc;

								--SET ISOLATION TO DIRTY READ;
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
                        --SET ISOLATION TO DIRTY READ;
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
                        --SET ISOLATION TO DIRTY READ;
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
 
                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoCoppel
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

                    ELIF cIdConvenio = '02001' THEN

                        --SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						--SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totCargo
						INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransCargoTelmex
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;
						
					ELIF cIdConvenio = '06001' THEN
								
						--SET ISOLATION TO DIRTY READ;
						SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
						INTO mCargoEfectivo
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001'
						AND fech_alt = dFechaIni
						AND transacc = cTransEfecSky
						AND sucursal = cSucursal
						AND folio_suc = cFolioSuc;

						--SET ISOLATION TO DIRTY READ;
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
								SELECT NVL(SUM(importe_total),0) 
								INTO mImporteTotal 
								FROM bdisac:"informix".sac_enviosdineroya
								WHERE no_control = cReferencia1 AND estatus IS NOT NULL
								UNION ALL
								SELECT NVL(SUM(importe_total),0)
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

								--SET ISOLATION TO DIRTY READ;
								SELECT NVL(SUM(monto_tot), 0) AS totEfectivo
								INTO mCargoEfectivo
								FROM bdicheq:"informix".sc_movhis_old
								WHERE empresa = '001'
								AND fech_alt = dFechaIni
								AND transacc IN (ctransEfecEnvioOrden, ctransEfecEnvioComision, ctransEfecEnvioIVA)
								AND sucursal = cSucursal
								AND folio_suc = cFolioSuc;

								--SET ISOLATION TO DIRTY READ;
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
                        --SET ISOLATION TO DIRTY READ;
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
                        --SET ISOLATION TO DIRTY READ;
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
'MODIFICA : Dulce RamÃ­rez',
'DESCRIPCION: Se modifica para incluir la forma de pago 4 "Abono en cuenta" para pago de remesas BTS',
'VERSION DE CAMBIO: 20100923.1843',
'                                    ',
'MODIFICA : MartÃ­n Eduardo Miranda',
'DESCRIPCION: Se agrega nuevo retorno "cIdConvenio" para ordenar el reporte diario de Servicios por sucursal',
'VERSION DE CAMBIO: 20120830.1629',

'MODIFICA : Martha Aguirre',
'DESCRIPCION: Se agrega bÃºsqueda de monto para el movimiento de cargo en cuenta de crÃ©dito para el cIdConvenio 8001',
'             "Pago de Servicios del Gobierno del Distrito Federal',
'VERSION DE CAMBIO: 20130109.1030',
'Folio:1570',
'Autor:95142134 Mario Gallardo',
'Fecha:24/01/2014',
'ModificaciÃ³n: Se modifica referencia1 y referencia2 a 40 carcateres.',
'Sustento: RQI 62 064-ReingenierÃ­a_PagoServicios -  (Pagina 2 a 36)',
'Solicita: Jaime Gonzalez',
'BD: bdisac',
'MODIFICA : Rigoberto Gonzalez Llanes',
'DESCRIPCION: Se agrega bÃºsqueda de monto para el movimiento de cargo en cuenta de crÃ©dito para el cIdConvenio 01002',
'             "Pago de Servicios del club de proteccion coppel',
'VERSION DE CAMBIO: 20140902.1358',
'MODIFICA : Jesus Isaias Bueno',
'DESCRIPCION: Se agrega bÃºsqueda de monto para el movimiento de cargo en cuenta de crÃ©dito para el cIdConvenio 03001',
'             para el pago de TAE',
'VERSION DE CAMBIO: 20150123.1120',
'MODIFICA : Jesus Isaias Bueno',
'DESCRIPCION: Se agrega bÃºsqueda de monto para el movimiento de cargo en cuenta de crÃ©dito para el cIdConvenio 08002',
'             para el pago se servicios EDOMEX',
'VERSION DE CAMBIO: 20150217.1204';

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