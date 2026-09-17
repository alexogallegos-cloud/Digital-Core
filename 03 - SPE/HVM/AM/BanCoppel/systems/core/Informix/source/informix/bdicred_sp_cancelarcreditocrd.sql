CREATE PROCEDURE "informix".sp_cancelarcreditocrd(pEmpresa CHAR(3), pNumCredito CHAR(20), pMotivoCancel CHAR(3), pEjecutivo CHAR(8),
											   pSupervisor CHAR(8), pTipoCancel CHAR(1), pSucursal CHAR(4) )
RETURNING
	CHAR(5) AS CodRet,
	CHAR(16) AS FolioSuc;
	
	-- DECLARACIONES
    DEFINE cCodRet		   		    CHAR(5);
    DEFINE iSqlErr					INTEGER;
	DEFINE cCodigoCancel			CHAR(3);
	DEFINE cCodigoCancelAux			CHAR(3);
	DEFINE cProducto				CHAR(4);
	DEFINE cSucursal				CHAR(4);
	DEFINE cStaCredito				CHAR(2);
	DEFINE dLineaCredito			DECIMAL(18,2);
	DEFINE cDivisa					CHAR(2);
	DEFINE dSdoRetenido				DECIMAL(18,2);
	DEFINE dCapVig					DECIMAL(18,2);
	DEFINE dMontoSBC				DECIMAL(18,2);
	DEFINE dSdoActTotalCap			DECIMAL(18,2);
	DEFINE dSdoActTotalInt			DECIMAL(18,2);
	DEFINE dSdoActTotalIva			DECIMAL(18,2);
	DEFINE dIva						DECIMAL(5,3);
	DEFINE cCodRetGM				CHAR(10);
	DEFINE cMensaje				    CHAR(80);
	DEFINE cCodRet2				    CHAR(5);
	DEFINE cFolioSuc				CHAR(16);
	DEFINE cFolioSuc2				CHAR(16);
	DEFINE cNumTarjeta				CHAR(20);
	DEFINE mMontoAutTarjeta			MONEY(14,2);
	DEFINE cNumCte					CHAR(20);
	DEFINE cCodProdTarjeta			CHAR(3);
	DEFINE dFechaHoy				DATE;
	DEFINE cBandTrans				CHAR(1);
	DEFINE iUnidadProd				INTEGER;
	DEFINE cCodCaracter				CHAR(3);
	DEFINE cCodCaracter2			CHAR(3);
	DEFINE cCliente                 CHAR(20);
	DEFINE cFolioCan                CHAR(10);
    DEFINE cCodRetDevol             CHAR(5);
    DEFINE cMen_retDevol            CHAR(80);
    DEFINE dMntoDevol               DECIMAL(16,2);
    DEFINE dfh_pre_devol_an         DATE;
    DEFINE dfh_devol_an             DATE;
	DEFINE cFolioSucCancProm 		CHAR(16);
	DEFINE cNumCredito				CHAR(20); --INC 27 116 AAME
	DEFINE cStatusTarjeta			CHAR(3); --INC 27 116 AAME
	
	-- INICIALIZACIONES
	LET cCodRet 				= "00000";
	LET iSqlErr 				= 0;
	LET cCodigoCancel			= "";
	LET cCodigoCancelAux		= "";
	LET cProducto				= "";
	LET cSucursal				= "";
	LET cStaCredito				= "";
	LET dLineaCredito			= 0.0;
	LET cDivisa					= "";
	LET dSdoRetenido			= 0.0;
	LET dCapVig					= 0.0;
	LET dMontoSBC				= 0.0;
	LET dSdoActTotalCap			= 0.0;
	LET dSdoActTotalInt			= 0.0;
	LET dSdoActTotalIva			= 0.0;
	LET dIva					= 0.0;
	LET cCodRetGM				= "";
	LET cMensaje				= "";
	LET cCodRet2				= "";
	LET cFolioSuc				= "";
	LET cFolioSuc2				= "";
	LET cNumTarjeta				= "";
	LET mMontoAutTarjeta		= 0.0;
	LET cNumCte					= "";
	LET cCodProdTarjeta			= "";
	LET dFechaHoy				= MDY(1, 1, 1900);
	LET cBandTrans				= "0";
	LET iUnidadProd				= 0;
	LET cCodCaracter    		= "";
	LET cCodCaracter2   		= "";
	LET cCliente                = "";
	LET cFolioCan               = "";
    LET cCodRetDevol            = "";
    LET cMen_retDevol           = "";
    LET dMntoDevol              = 0;
    LET dfh_pre_devol_an        = DATE(1);
    LET dfh_devol_an            = DATE(1);
	LET cFolioSucCancProm		= '';
	LET cNumCredito             = ''; --INC 27 116 AAME
	LET cStatusTarjeta			= ''; --INC 27 116 AAME	
	
BEGIN

	ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
        END IF;
		IF cBandTrans = '1' THEN
			-- EN CASO DE ERROR DE INFORMIX ABORTA LA TRANSACCION
			ROLLBACK WORK;
		END IF
        RETURN TRIM(cCodRet), TRIM(cFolioSuc);
    END EXCEPTION;
	 
--SET DEBUG FILE TO "/RESPALDOSNEW/ulises/RT_PP/sp_cancelarcredito.out";
--TRACE ON;
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- VALIDA QUE NO ESTEN VACIOS LOS PARAMETROS
    IF TRIM(NVL(pEmpresa, '')) = '' OR TRIM(NVL(pNumCredito, '')) = '' OR TRIM(NVL(pMotivoCancel,'')) = '' OR TRIM(NVL(pEjecutivo, '')) = '' OR TRIM(NVL(pSupervisor, '')) = '' OR TRIM(NVL(pTipoCancel, '')) = '' OR TRIM(NVL(pSucursal,'')) = '' THEN 
		LET cCodRet = '00001';
		RETURN TRIM(cCodRet), TRIM(cFolioSuc);
	END IF
	
	-- SE VALIDA LA EXISTENCIA DEL MOTIVO EN EL CATALOGO DE NO CANCELACIONES
	IF pTipoCancel = "3" THEN -- SI ES POR SUCURSAL CONSULTA POR CODIGO
		SELECT codigo
		INTO cCodigoCancel
		FROM "informix".sd_cat_cancred 
		WHERE codigo = pMotivoCancel;
	ELSE	-- SI ES POR CENTRAL CONSULTA POR LA CLAVE
		SELECT codigo
		INTO cCodigoCancel
		FROM "informix".sd_cat_cancred 
		WHERE clave = pMotivoCancel::SMALLINT;	
	END IF;
 
	IF TRIM(NVL(cCodigoCancel,'')) = '' THEN
		LET cCodRet = '00002'; -- MOTIVO NO EXISTE
		RETURN TRIM(cCodRet), TRIM(cFolioSuc);
	END IF;
	LET cCodigoCancelAux = cCodigoCancel;
	
	-- OBTIENE EL PRODUCTO ,  LA SUCURSAL DEL CREDITO Y EL ESTATUS DEL CREDITO
	SELECT num_producto, sucursal, status_cred, divisa, numcte --id_unidad_prod, cod_caract, cod_caract_2
	INTO cProducto, cSucursal, cStaCredito, cDivisa, cNumCte --iUnidadProd, cCodCaracter, cCodCaracter2
	FROM "informix".sd_maecredcrd
	WHERE num_credito = pNumCredito;

    -- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad
/*    SELECT nvl(date(fecha_pre_devol_anual),date(1)), nvl(date(fecha_devol_anual),date(1)), nvl(cfoliosuc_cancel_suc,'')
	  INTO dfh_pre_devol_an, dfh_devol_an, cFolioSucCancProm
      FROM bdicred:sd_indicador_cred WHERE empresa = pEmpresa AND num_credito = pNumCredito;
*/ --duda

	-- VALIDA QUE EL CREDITO EXISTA
	IF TRIM(NVL(cNumCte,'')) = '' THEN
		LET cCodRet = '00003'; -- CREDITO NO EXISTE
		RETURN cCodRet, cFolioSuc;
	END IF
	-- AAME 31012017 Se agregan los productos de crÃÂ©dito platino y oro para que se contemplen en la cancelaciÃÂ³n de crÃÂ©ditos
	-- VALIDA QUE SEA UN PRODUCTO DE TARJETA DE CREDITO
/*	IF TRIM(cProducto) NOT IN( '7000','8100','6001','7800','8500') THEN--validar si mejor se consulta la tabla donde se encuentran todos los creditos revolventes
		LET cCodRet = '00004';
		RETURN TRIM(cCodRet), TRIM(cFolioSuc);
	END IF
*/	
-- OBTIENE LA FECHA DEL DIA
	SELECT FECHA_HOY
	INTO dFechaHoy
	FROM "informix".sd_fechas
	WHERE empresa = '001';
	
/*	IF cStaCredito = 'FF' THEN 
		SELECT DISTINCT(num_cte) --SE CONSULTA A VER SI EL CREDITO ESTA CANCELADO
		INTO cCliente
		FROM "informix".sd_cred_can
		WHERE num_credito = pNumCredito
		AND folio_cancelacion <> "" ;
		
		IF NVL(cCliente, "") = "" THEN --SI NO HAY REGISTROS DE QUE ESTE CANCELADO ENTRA AQUI
			LET cCodRet = '00017'; -- CREDITO SALDADO NORMAL (NO CANCELADO)
			LET cCodigoCancel = '009';	
		ELSE --SI HAY REGISTROS QUIERE DECIR QUE ESTA CANCELADO
			LET cCodRet = '00011'; -- CREDITO CANCELADO
			LET cCodigoCancel = '002';	
        END IF		
	ELIF cStaCredito = 'CV' THEN
		LET cCodRet = '00012'; -- CREDITO VENCIDO
		LET cCodigoCancel = '003';		
	ELIF cStaCredito = 'BA' THEN
		LET cCodRet = '00013'; -- CREDITO VENCIDO NORMAL
		LET cCodigoCancel = '005';	
	ELIF cStaCredito = 'BT' THEN
		LET cCodRet = '00014'; -- CREDITO VENCIDO TRASPASADO
		LET cCodigoCancel = '006';	
	ELIF cStaCredito = 'FC' THEN
		LET cCodRet = '00015'; -- CREDITO SALDADO RESTRUCTURADO CONSOLIDADO
		LET cCodigoCancel = '007';	
	ELIF iUnidadProd IS NOT NULL OR cCodCaracter <> '' OR cCodCaracter2 <> '' THEN
		LET cCodRet = '00010'; -- CREDITO BLOQUEADO
		LET cCodigoCancel = '004';
       -- Elimina marca para creditos bloqueados por devolucion de anualidad, para que puedan cancelarse esos creditos.
        IF iUnidadProd = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) THEN -- AND nvl(dfh_devol_an,date(1)) = date(1) THEN 
            LET cCodRet = '00000';
            LET cCodigoCancel = cCodigoCancelAux;
        END IF;
	END IF*/
    
	IF cCodRet='00000' THEN 
			-- OBTIENE EL SALDO RETENIDO, EL CAPITAL VIGENTE Y EL CAPITAL INSOLUTO
			SELECT NVL(sdo_retenido,0), NVL(sdo_capital,0), NVL(sdo_cap_insoluto,0)
			INTO dSdoRetenido, dCapVig, dSdoActTotalCap
			FROM "informix".sd_maesdoscrd
			WHERE num_credito = pNumCredito;

			IF dSdoRetenido > 0 THEN
				LET cCodRet = '00016'; -- CREDITO SALDO RETENIDO
				LET cCodigoCancel = '008';	
			END IF

			IF cCodRet = '00000' THEN
				-- VALIDA QUE LOS SALDOS NO ESTEN EN CEROS Y QUE TENGA ESTATUS VIGENTE
				IF dCapVig <> 0 OR dSdoActTotalCap <> 0 THEN
					LET cCodRet = '00005'; -- CREDITO CON SALDO
					LET cCodigoCancel = '001';		
				ELSE		
					-- OBTIENE EL MONTO DE SALVO BUEN COBRO
					SELECT NVL(SUM(monto),0)
					INTO dMontoSBC
					FROM bdicheq:"informix".sc_docret 
					WHERE empresa = pEmpresa
					AND cuenta = pNumCredito
					AND siglas  = 'SD'
					AND cancelado = 'T';

				IF dMontoSBC = 0 THEN
					-- OBTIENE EL SALDO ACTUAL TOTAL INTERES
					SELECT NVL(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)) + 
					SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) 
					+ NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
					INTO dSdoActTotalInt
					FROM "informix".sd_amortiza_creditocrd
					WHERE empresa = pEmpresa
					AND num_credito = pNumCredito
					AND capital_status IN ('2','7','6');

					IF dSdoActTotalInt = 0 THEN
						-- OBTIENE EL IVA DE LA SUCURSAL
						SELECT iva
						INTO dIva
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cSucursal;

						-- OBTIENE EL SALDO ACTUAL TOTAL IVA
						SELECT NVL(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) 
						+ NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)) * dIva,0)
						INTO dSdoActTotalIva
						FROM "informix".sd_amortiza_creditocrd
						WHERE empresa = pEmpresa
						AND num_credito = pNumCredito
						AND capital_status IN ('2','7','6');

						IF dSdoActTotalIva <> 0 THEN
							LET cCodRet = '00005'; -- CREDITO CON SALDO
							LET cCodigoCancel = '001';
						END IF;					
					ELSE
						LET cCodRet = '00005'; -- CREDITO CON SALDO
						LET cCodigoCancel = '001';
					END IF				
				ELSE
					LET cCodRet = '00005'; -- CREDITO CON SALDO
                    LET cCodigoCancel = '001';
				END IF			
			END IF		
	      END IF

			LET cFolioSuc = TRIM(cCodigoCancel);

			IF cCodRet = '00000' THEN

				LET cFolioSuc = '';

				-- PROCESO GENERICO PARA FORMATEAR UN FOLIO POR MEDIO DEL EJECUTIVO
				EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pSupervisor)
				INTO cCodRet2, cFolioSuc2;

				-- VALIDA QUE NO HAYA TENIDO ERROR LA GENERACÃÂN DEL FOLIO NOMINA.
				IF cCodRet2::INTEGER <> 0 THEN
					LET cCodRet = '00006';
					LET cFolioSuc = '';
					RETURN TRIM(cCodRet), TRIM(cFolioSuc);
				END IF

				-- Devolucion anualidad RQM 10 850 INI
				-- Realiza validacion, si al credito le corresponde devolucion de comision por anualidad, termina proceso de cancelacion. 
				--EXECUTE PROCEDURE "informix".sp_comision_anual_devolucion(pEmpresa, pNumCredito, pSupervisor) INTO cCodRetDevol, cMen_retDevol, dMntoDevol;
				IF cCodRetDevol = '00000' AND dMntoDevol != 0 THEN
/*					IF nvl(cFolioSucCancProm, '') = '' THEN
						UPDATE "informix".sd_indicador_cred SET cfoliosuc_cancel_suc = cFolioSuc2 WHERE num_credito = pNumCredito; 
					END IF;
*/					IF cBandTrans = '1' THEN
						-- APLICA LA TRANSACCION
						COMMIT WORK;
					END IF
					LET cCodRet = '1211';  -- Termina proceso de cancelacion. Es necesario realizar retiro en ventanilla de monto de devolucion de anualidad.
					LET cFolioSuc = cFolioSuc2;
					--LET cCodRet = '00000';
					--LET cFolioSuc = 'devolucion';
					RETURN TRIM(cCodRet), TRIM(cFolioSuc);
				ELIF cCodRetDevol = '1208' AND dMntoDevol = 0 THEN		---	Si la cancelacion es desde OFI, no deje pasar, la cancelacion.
					LET cCodRet = '1208';  -- Termina proceso de cancelacion. Es necesario realizar retiro en ventanilla de monto de devolucion de anualidad.
					LET cFolioSuc = cFolioSuc2;
					RETURN TRIM(cCodRet), TRIM(cFolioSuc);
				END IF
				-- Devolucion anualidad RQM 10 850 FIN						

				-- OBTIENE LA LINEA DE CREDITO ANTES DE PONERLA EN CEROS
				SELECT monto_otorgado
				INTO dLineaCredito
				FROM "informix".sd_maesdoscrd
				WHERE num_credito = pNumCredito;

				-- VALIDAMOS LA SESION DE LA CANCELACION SI ES DE CENTRAL O SUCURSAL.
				IF TRIM(NVL(pSucursal,'')) = '9250' THEN
					-- INICIA LA TRANSACCION
					BEGIN WORK;
					LET cBandTrans = '1';
				END IF;

				-- ACTUALIZA LA LINEA DE CREDITO A CERO
				UPDATE "informix".sd_maesdoscrd
				SET monto_otorgado = 0
				WHERE num_credito = pNumCredito;

				-- ACTUALIZA EL STATUS DEL CREDITO A CANCELADO NORMAL DE CENTRAL
				UPDATE "informix".sd_maecredcrd
				SET status_cred = 'FF', -- FC
					credito_externo = 'CANCELADO POR CTE', --PIQV
					fecha_vencim = dFechaHoy --PIQV
				WHERE numcte = cNumCte
				AND num_credito = pNumCredito;
				
				-- GENERA UN MOVIMIENTO POR EL MONTO OTORGADO
				EXECUTE PROCEDURE "informix".genmov(pEmpresa,pNumCredito,cProducto,2,'008',dFechaHoy,dLineaCredito,cFolioSuc2,'9290',cDivisa,'6697')
				INTO cCodRetGM, cMensaje;

				-- VALIDA QUE NO HAYA TENIDO ERROR
				IF cCodRetGM::INTEGER <> 0 THEN
					ROLLBACK WORK;
					LET cCodRet = '00007';
					LET cFolioSuc = '';
					RETURN TRIM(cCodRet), TRIM(cFolioSuc);
				END IF

				-- CICLO PARA OBTENER LAS TARJETAS ASIGNADAS A UN NUMERO DE CREDITO QUE NO ESTAN CANCELADAS		
				--AAME 21032019 INC 27 116 Se considera cancelar todos los plÃÂ¡sticos diferente de CANCELADAS
/*				FOREACH
					SELECT num_tarjeta, numcte, status_tar
					INTO cNumTarjeta, cNumCte, cStatusTarjeta --Se agrega la seleccion del nuevo numero de cliente generado para la tarjeta adicional/CARLOS OCHOA
					FROM "informix".sd_tarjeta 
					WHERE num_credito = pNumCredito
					AND status_tar NOT IN ('C')
					UNION ALL --AAME 21032019 INC 27 116 Se contempla obtener el status de tarjeta
					SELECT numtarjeta,numcliente,codstatustarjeta
					FROM intercard:"informix".tarjeta 
					WHERE numtarjeta = cNumTarjeta
						
			--AAME 21032019 INC 27 116 Se valida que el estatus para cancelar sea A o I
					IF cStatusTarjeta IN('I','A') THEN
						-- PROCESO PARA CANCELAR TARJETA EN CREDITO
						EXECUTE PROCEDURE "informix".cancelatarjeta(pEmpresa,pNumCredito,cNumTarjeta,cNumCte)
						INTO cCodRet2, mMontoAutTarjeta, cFolioCan;

						-- VALIDA QUE NO HAYA TENIDO ERROR
						IF cCodRet2::INTEGER <> 0 AND cCodRet2::INTEGER <> 101 THEN			
							ROLLBACK WORK;
							LET cCodRet = '00008';
							LET cFolioSuc = '';
							RETURN TRIM(cCodRet), TRIM(cFolioSuc);
						END IF;
					END IF;
								
					-- AAME 21032019 INC 27 116 SE VALIDA QUE EL ESTATUS PARA CANCELAR SEA ACT O INA
					IF cStatusTarjeta IN ('ACT','INA') THEN
						-- OBTIENE EL CODIGO DE PRODUCTO DE TARJETA DE INTERCARD
						SELECT codproductotarjeta
						INTO cCodProdTarjeta
						FROM intercard:"informix".tarjeta 
						WHERE numtarjeta = cNumTarjeta;
						
						-- PROCESO PARA CANCELAR TARJETA EN INTERCARD
						EXECUTE PROCEDURE intercard:"informix".sp_cancelacion_tarjeta(cNumTarjeta, cCodProdTarjeta, pEjecutivo)
						INTO cCodRet2, cMensaje;
											
						-- VALIDA QUE NO HAYA TENIDO ERROR
						IF cCodRet2::INTEGER <> 0 AND cCodRet2::INTEGER <> 2 THEN
							ROLLBACK WORK;
							LET cCodRet = '00009';
							LET cFolioSuc = '';
							RETURN TRIM(cCodRet), TRIM(cFolioSuc);
						END IF;
					END IF;
				END FOREACH;
*/				-----------------------------------------------------------------------------------------------------------------------------------------------------------------				
				--INC 27 116 AAME
				--CANCELAR PLASTICO DE CLIENTE CON MARCA PENDIENTE DE UPGRADE, SE CONTEMPLA FOREACH POR SI EL CREDITO TIENE MARCA CON ADICIONALES
/*				FOREACH
					SELECT numcte
					INTO cNumCte 
					FROM "informix".sd_credito_upgrade 
					WHERE num_credito = pNumCredito
					UNION ALL
					SELECT numcte
					FROM "informix".sd_credito_upgrade 
					WHERE numero_credito_upgrade = pNumCredito	

					IF cProducto IN('7000','8100') THEN 
						SELECT num_credito
						INTO cNumCredito 
						FROM "informix".sd_credito_upgrade 
						WHERE numero_credito_upgrade = pNumCredito;	
					END IF;
					
					--Se busca el nÃÂºmero de tarjeta con la marca que se encuentre en estatus INA y se contempla ciclo por que hay casos que tienen mas de un plÃÂ¡stico solicitado en INA
					FOREACH
						-- OBTIENE EL CODIGO DE PRODUCTO DE TARJETA DE INTERCARD
						SELECT t.numtarjeta, t.codproductotarjeta
					    INTO cNumTarjeta, cCodProdTarjeta
						FROM intercard:"informix".tarjeta t
						JOIN intercard:detalle_maquila d ON t.numtarjeta = d.numtarjeta 
						JOIN intercard:solicitudtarjeta s ON d.idsolicitud = s.idsolicitud
						WHERE s.numcuenta IN (pNumCredito,cNumCredito) AND s.numcliente = cNumCte AND t.codstatustarjeta ='INA'						
						
						-- PROCESO PARA CANCELAR TARJETA EN INTERCARD
						EXECUTE PROCEDURE intercard:"informix".sp_cancelacion_tarjeta(cNumTarjeta, cCodProdTarjeta, pEjecutivo)
						INTO cCodRet2, cMensaje;

						-- VALIDA QUE NO HAYA TENIDO ERROR
						IF cCodRet2::INTEGER <> 0 AND cCodRet2::INTEGER <> 2 THEN
							ROLLBACK WORK;
							LET cCodRet = '00009';
							LET cFolioSuc = '';
							RETURN TRIM(cCodRet), TRIM(cFolioSuc);
						END IF
										
					END FOREACH;

				END FOREACH;
*/				-----------------------------------------------------------------------------------------------------------------------------------------------------------------
				END IF

				IF cCodRet <> '00000' THEN
					LET cFolioSuc2 = '';
				ELSE
					LET cFolioSuc = cFolioSuc2;
			END IF
	END IF;
	-- SE GRABA EN LA BITACORA DE LOS CREDITOS CANCELADOS Y LOS NO CANCELADOS.
 	INSERT INTO "informix".sd_cred_can(empresa, num_credito, num_cte, motivo_can, num_producto, ejecutivo, supervisor, fecha_can, tipo_can, sucursal, folio_cancelacion) 
	VALUES (TRIM(pEmpresa), TRIM(pNumCredito), TRIM(cNumCte), TRIM(cCodigoCancel), TRIM(cProducto), TRIM(pEjecutivo), TRIM(pSupervisor), dFechaHoy, TRIM(pTipoCancel), TRIM(pSucursal), TRIM(cFolioSuc2));
	IF pTipoCancel <> "3" THEN
		IF pMotivoCancel::SMALLINT = 2 and cCodRet::INTEGER =0   THEN
			--SE realiza el marcaje del cliente RQI 27 100 JMAH
			EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',4,cNumCte, pEjecutivo)
			INTO cCodRet, cMensaje;
		END IF;
	END IF;
	
		
	IF cBandTrans = '1' THEN
		-- APLICA LA TRANSACCION
		COMMIT WORK;
	END IF
	
	RETURN TRIM(cCodRet), TRIM(cFolioSuc);
	
END  
END PROCEDURE
DOCUMENT
'MODIFICO: Valentin Lopez',
'DESCRIPCION: Se le aplicaron la reglas de informix, se agrego un nuevo parametro, se agrego un nuevo insert ala tabla sd_cred_can contemplando el nuevo campo.', 
'FECHA DE MODIFICACION: 22 de Noviembre del 2011',
'VERSION: 20111122.1726',
'BD: BDICRED',
'MODIFICO: Valentin Lopez',
'DESCRIPCION: Se le agregaron 2 columnas a la tabla bdicred:sd_cred_can sucursal y folio_cancelacion y ',
'			  el parametro de sucursal para guardarlo en la tabla. Se modifico la consulta a la tabla bdicred:sd_tarjeta ',
'			  se quito la condiciÃÂ³n del nÃÂºmero de cliente, para cancelar la tarjeta titular y las tarjetas adicionales',
'FECHA DE MODIFICACION: 17 de Octubre del 2012',
'VERSION: 20121017.1726',
'BD: BDICRED',
'MODIFICA: Carlos Ochoa Valenzuela',
'DESCRIPCION: Se agrega una validaciÃÂ³n para comprobar si los crÃÂ©ditos con estatus FF estan solo saldados o cancelados.',
'             Se agregan cÃÂ³digos de retorno para los estatus BA,BT,FC y FF.',
'             Manejo de errores por saldo retenidos independiente. ',
'FECHA DE MODIFICACION: 11 de Diciembre del 2012',
'VERSION: 20121211.1135',
'BD: BDICRED',
'MODIFICO: Mireya Reyes',
'DESCRIPCION: Se agrego una nueva variable, debido a la modificaciÃÂ³n de los datos de salida del sp: cancelatarjeta.sql.', 
'FECHA DE MODIFICACION: 29 de Julio del 2014',
'VERSION: 20140729.1726',
'BD: BDICRED';

CREATE PROCEDURE "informix".calporcentaje(e_fcuota DATE,
                                          e_Mora   INTEGER,
                                          e_Int    INTEGER)
   RETURNING CHAR(5),MONEY(14,2),MONEY(14,2),MONEY(14,2),MONEY(14,2);

   DEFINE CodRet              CHAR(5);
   DEFINE Mensaje             CHAR(80);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nRows               SMALLINT;

   DEFINE GLOBAL g_Empresa          CHAR(3)     DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito       CHAR(20)    DEFAULT ' ';
   DEFINE GLOBAL g_NumProducto      CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Remanente        MONEY(14,2) DEFAULT 0;
   DEFINE GLOBAL g_Fecha            DATE        DEFAULT '';
   DEFINE GLOBAL g_Folio            CHAR(16)    DEFAULT ' ';
   DEFINE GLOBAL g_Sucursal         CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_Divisa           CHAR(2)     DEFAULT ' ';
   DEFINE GLOBAL g_TRansacc         CHAR(4)     DEFAULT ' ';
   DEFINE GLOBAL g_IvaCte           DECIMAL(9,6) DEFAULT 0;
   DEFINE GLOBAL g_CodigoFun        CHAR(3)     DEFAULT ' ';
   DEFINE dIvaIntMoratorio     DECIMAL(18,2);
   DEFINE dIntMoratorio_d	 DECIMAL(18,2);
   DEFINE vFechaCuota            LIKE sd_amortiza_credito.fecha_cuota;
   DEFINE vMoraDebe              LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraIvaDebe           LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraTotDebe           LIKE sd_amortiza_credito.mora_iva_debe;
---CAS
   DEFINE vMoraPor               DECIMAL(9,6);
   DEFINE vIvaPor                DECIMAL(9,6);
   DEFINE vIntPor                DECIMAL(9,6);
   DEFINE vIvaIntPor             DECIMAL(9,6);
---CAS

 --  DEFINE vMoraPor               LIKE sd_amortiza_credito.mora_iva_debe;
 --  DEFINE vIvaPor                LIKE sd_amortiza_credito.mora_iva_debe;
 --  DEFINE vIntPor                LIKE sd_amortiza_credito.mora_iva_debe;
 --  DEFINE vIvaIntPor             LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraPag               LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vIvaPag                LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vMoraDebeIva           LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vIntPag                LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vIvaiIntPag            LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vIntVenc               LIKE sd_paginter.monto_cuota;
   DEFINE vIvaVenc               LIKE sd_paginter.monto_cuota;
   DEFINE vIntTotDebe            LIKE sd_amortiza_credito.mora_iva_debe;
   DEFINE vStatusCuota           LIKE sd_paginter.status_cuota;
   DEFINE vCodFunIva             CHAR(3);
   DEFINE wCodRefMora            SMALLINT;
   DEFINE vIvaBase               DECIMAL(9,6);
   DEFINE vCodigoRef             SMALLINT;
   DEFINE vReferencia            SMALLINT;

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CobraIva.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet,vIvaPag,vMorapag,vIvaiIntPag,vIntPag;
   END EXCEPTION;

   --SET DEBUG FILE TO "calprocentaje.out";
   --TRACE ON;

   LET CodRet       = "000";
   LET vCodFunIva   = "340";
   LET vCodigoRef   = 2;
   LET vMoraDebe    = 0;
   LET vMoraIvaDebe = 0;
   LET vMoraTotDebe = 0;
   LET vMoraPor     = 0;
   LET vIvaPor      = 0;
   LET vMoraPag     = 0;
   LET vIvaPag      = 0;
   LET vIntVenc     = 0;
   LET vIvaVenc     = 0;
   LET vIntTotDebe  = 0;
   LET vIvaIntPor   = 0;
   LET vIntPor      = 0;
   LET vIvaiIntPag  = 0;
   LET vIntPag      = 0;
   LET vFechaCuota  = '';
   LET vStatusCuota  = '';
   LET vIvaBase      = 0;
   LET vMoraDebeIva  = 0;
   LET g_Remanente   = g_Remanente;
   LET dIvaIntMoratorio         = 0;
   LET dIntMoratorio_d       = 0;	
    -- *****************************
   -- Extrae Iva Base del Sistema *
   -- *****************************
   SELECT valor INTO vIvaBase
     FROM bdinteg:si_param
    WHERE empresa = g_Empresa
      AND cod_param = 47;


    IF vIvaBase <> g_IvaCte THEN
     LET wCodRefMora = 26 ;
    ELSE
     LET wCodRefMora = 25 ;
    END IF


   -- ***************************************************
   -- Calcula Porcentaje DE Iva Y Mora  de Intereses    *
   -- ***************************************************
  IF e_Mora = 1 THEN
  
      SELECT SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))
--             sum(mora_iva_debe - mora_iva_pagado)
      INTO   vMoraDebe
-- , vMoraIvaDebe
      FROM sd_amortiza_credito
      WHERE empresa =  g_empresa
        AND num_credito = g_NumCredito
        --AND capital_status in ('2','7');
        AND capital_status in ('2','7','6'); --Se agrega nuevo estatus para IFRS
        --and mora_status = 1
        --AND (mora_provi_ordi + mora_provi_cope+mora_sdo_ordi+mora_sdo_cope-mora_sdo_ordi_pag-mora_sdo_cope_pag) > 0;

		
		FOREACH
  			SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* vIvaBase ))
  			INTO dIntMoratorio_d
  			FROM sd_amortiza_credito a
  			WHERE a.empresa   = g_empresa
  			AND a.num_credito = g_NumCredito
  			--AND capital_status IN ("2","7")
         AND capital_status in ('2','7','6') --Se agrega nuevo estatus para IFRS
  
  			LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;
  
  		END FOREACH;
		
		
		
	-- LET  vMoraIvaDebe = vMoraDebe * vIvaBase;
	 LET  vMoraIvaDebe =dIvaIntMoratorio;
     LET  vMoraTotDebe = vMoraDebe + vMoraIvaDebe;
     IF vMoraTotDebe > g_Remanente  THEN
        LET vMoraPor = vMoraDebe    / vMoraTotDebe;
        LET vMorapag = round(vMoraPor * g_Remanente,2);
        LET vIvaPag  = g_Remanente - vMorapag;
--        LET vIvaPor  = vMoraIvaDebe / vMoraTotDebe;
--        LET vIvaPag  = vIvaPor * g_Remanente;
--        LET vMorapag = vMoraPor * g_Remanente;
--        let g_Remanente = vMorapag;
     END IF;
  END IF;

   -- ***************************************************
   -- Calcula Porcentaje De Interes                     *
   -- ***************************************************
  IF e_Int  = 2 THEN
     SELECT sum((interes_debe - interes_pagado)),
            sum((iva_debe - iva_pagado))
     INTO  vIntVenc,vIvaVenc
     FROM sd_amortiza_credito
     WHERE empresa = g_Empresa
       AND num_credito = g_NumCredito
       AND interes_status in ('3')
       --AND capital_status in ('2','7')
       AND capital_status in ('2','7','6') --Se agrega nuevo estatus para IFRS
       AND nvl(interes_debe,0) - nvl(interes_pagado,0) > 0;


     LET  vIntTotDebe = vIntVenc + vIvaVenc;
     IF vIntTotDebe > g_Remanente  THEN
        LET vIntPor     = vIntVenc  / vIntTotDebe;
        LET vIntPag     = round(vIntPor    * g_Remanente,2);
        LET vIvaiIntPag = g_Remanente - vIntPag;
--        LET vIvaIntPor  = vIvaVenc / vIntTotDebe;
--        LET vIvaiIntPag = vIvaIntPor * g_Remanente;
--        LET vIntPag     = vIntPor    * g_Remanente;
    END IF;
 END IF;
      RETURN CodRet,vIvaPag,vMorapag,vIvaiIntPag,vIntPag;

END PROCEDURE;