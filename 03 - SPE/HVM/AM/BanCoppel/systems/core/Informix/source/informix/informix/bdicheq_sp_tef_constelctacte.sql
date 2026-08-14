CREATE PROCEDURE "informix".sp_tef_constelctacte(pTelefono CHAR(10))

	-- RETORNOS DEL PROCEDIMIENTO
	RETURNING 	CHAR(5)  					AS  CodRet,
				CHAR(20)					AS 	NumCte,
				CHAR(20)					AS 	Cuenta,
				SMALLINT					AS  Canal,
				CHAR(1)						AS	EsTransfer,
				CHAR(8)						AS	UserInsert,
				DATETIME YEAR TO SECOND 	AS 	FechaHoraInsert;
				
	--DEFINICION DE VARIABLES
	DEFINE iSqlErr 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cNumCte 				CHAR(20);
	DEFINE cCuenta 				CHAR(20);
	DEFINE sCanal				SMALLINT;
	DEFINE cEsTransfer			CHAR(1);
	DEFINE cUserInsert			CHAR(8);
	DEFINE dtFechaHoraInsert	DATETIME YEAR TO SECOND;
	
	--INICIALIZACION DE VARIABLES
	LET iSqlErr 			= 0;
	LET cCodRet 			= "00000";
	LET cNumCte 			= "";
	LET cCuenta 			= "";
	LET sCanal				= 0;
	LET cEsTransfer			= "";
	LET cUserInsert			= "";
	LET dtFechaHoraInsert	= DATE(1);
	
	--SET DEBUG FILE TO '/respaldosbd/Benitez/sp_tef_constelctacte.out';
	--TRACE ON;
	
BEGIN 				--CONTROL DE ERRORES DE INFORMIX
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(cCodRet), NVL(cNumCte,''), NVL(cCuenta,''), NVL(sCanal,0), NVL(cEsTransfer,''), NVL(cUserInsert,''), NVL(dtFechaHoraInsert,DATE(1));
			END IF;
		END EXCEPTION;	

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		-- VALIDACION DE PARAMETROS --
		IF NVL(pTelefono,"") = "" OR LENGTH(pTelefono) <> 10 THEN --SE VERIFICA QUE EL PARAMETRO NO LLEGUE VACIO O SEA DIFERENTE DE 10 DIGITOS
			LET cCodRet = '00001';
			RETURN cCodRet, NVL(cNumCte,''), NVL(cCuenta,''), NVL(sCanal,0), NVL(cEsTransfer,''), NVL(cUserInsert,''), NVL(dtFechaHoraInsert,DATE(1));
		END IF;
			
		-- REGRESA LOS REGISTROS DE LA TABLA SC_CUENTA_TELEFONO (CATALOGO DE TELEFONOS)
		SELECT num_cte, cuenta, canal, es_transfer, user_insert, fecha_hora_insert
		INTO cNumCte, cCuenta, sCanal, cEsTransfer, cUserInsert, dtFechaHoraInsert
		FROM "informix".sc_cuenta_telefono
		WHERE telefono = pTelefono;
		
		 -- SE VALIDA SI LA CONSULTA NO REGRESA REGISTROS
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '00002';
			RETURN cCodRet, NVL(cNumCte,''), NVL(cCuenta,''), NVL(sCanal,0), NVL(cEsTransfer,''), NVL(cUserInsert,''), NVL(dtFechaHoraInsert,DATE(1));
		END IF;
		
		RETURN cCodRet, NVL(cNumCte,''), NVL(cCuenta,''), NVL(sCanal,0), NVL(cEsTransfer,''), NVL(cUserInsert,''), NVL(dtFechaHoraInsert,DATE(1)); 	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: PROCEDIMIENTO QUE CONSULTA LOS CAMPOS DE LA TABLA BDICHEQ:SC_CUENTA_TELEFONO ',
'AUTOR: FRANCISCO EDUARDO BENITEZ BAEZ ',
'FECHA: 19 DE SEPTIEMBRE DEL 2014 ',
'VERSION: 201419091600',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_generareportepitdc_web(pdFecha DATE,pcSucursal CHAR(4),pcTipo CHAR(1),piRegistro INTEGER)
RETURNING CHAR(5),CHAR(40),CHAR(40),CHAR(25),CHAR(16),CHAR(16),MONEY(16,2),CHAR(4),CHAR(20),MONEY(16,2),MONEY(16,2),INTEGER;
--Definicion de variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cSucursal CHAR(40);
DEFINE cRegion CHAR(40);
DEFINE cBanco CHAR(25);
DEFINE cNumTarjeta CHAR(16);
DEFINE cSecuencia CHAR(16);
DEFINE mImporte MONEY(16,2);
DEFINE mImpCargo MONEY(16,2);
DEFINE mImpEfectivo MONEY(16,2);
DEFINE cTransaccion CHAR(4);
DEFINE cCuenta CHAR(20);
DEFINE iContEfec INTEGER;
DEFINE iContCargo INTEGER;
DEFINE iContador INTEGER;
DEFINE cReferencia CHAR(6);
DEFINE vconsmovhis      CHAR(10);
DEFINE vconsmovhisold   CHAR(10);

DEFINE iCuantos	INTEGER;
DEFINE vValor	CHAR(100);
DEFINE iiCuantos INTEGER;
DEFINE vValor_2	CHAR(100);
DEFINE iiiCuantos INTEGER;
DEFINE vValor_3	CHAR(100);

--Inicializacion de variables
LET iSqlErr = 0;
LET cCodRet = '00001';
LET cSucursal = '';
LET cRegion = '';
LET cBanco = '';
LET cNumTarjeta = '';
LET cSecuencia = '';
LET mImporte = 0;
LET mImpCargo = 0;
LET mImpEfectivo = 0;
LET cTransaccion = '';
LET cCuenta = '';
LET iContEfec = 0;
LET iContCargo = 0;
LET iContador = 0;
LET cReferencia = '';

LET iCuantos = 0;
LET vValor = '';
LET iiCuantos = 0;
LET vValor_2 = '';
LET iiiCuantos = 0;
LET vValor_3 = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'','','','','',0,'','',0,0,0;
		END IF;
	END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/sp_GeneraReportePITDC.out";
--	TRACE ON;

	--Se obtiene el nombre de la sucursal y de la region.
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT suc.nombre,reg.nombre
	INTO cSucursal,cRegion
	FROM bdinteg:"informix".si_sucursales suc
	INNER JOIN bdinteg:"informix".si_plazas plz ON plz.plaza = suc.plaza
	INNER JOIN bdinteg:"informix".si_regional reg ON reg.regional = plz.regional
	WHERE suc.sucursal = pcSucursal;

    SELECT valor
	INTO vconsmovhis
	FROM sc_param
	WHERE empresa = '001'
	AND codparam = 'fechcon_movhis';

    SELECT valor
	INTO vconsmovhisold
	FROM bdicheq:sc_param
	WHERE empresa = '001'
	AND codparam = 'FechIniCon_movhis_ol';

	--Se valida el tipo de busqueda
	IF pcTipo = 1 THEN
		--Se obtiene el importe y cantidad de movimientos de efectivo
		
		SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
		INTO mImpEfectivo,iContEfec
		FROM bdicheq:"informix".sc_movdia
		WHERE empresa = '001' AND transacc = '1193'
		AND fech_alt = pdFecha
		AND sucursal = pcSucursal;

		--Se obtiene el importe y cantidad de movimientos de cargo
		
		SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
		INTO mImpCargo,iContCargo
		FROM bdicheq:"informix".sc_movdia
		WHERE empresa = '001' AND transacc = '1194'
		AND fech_alt = pdFecha
		AND sucursal = pcSucursal;

		--Contador de movimientos
		LET iContador = iContEfec + iContCargo;
		-- Se reemplaza la consulta para contar los movimientos por la suma de las variables obtenidas previamente
		LET iCuantos = iContEfec + iContCargo;
		
		
		--Se obtiene la informacion diaria.
		-- SELECT count(transacc)  INTO iCuantos
		-- FROM bdicheq:"informix".sc_movdia
		-- WHERE empresa = '001' AND transacc IN ('1193','1194')
		-- AND fech_alt = pdFecha
		-- AND sucursal = pcSucursal;
			
		IF (iCuantos > 0) THEN 	
			
			FOREACH
				SELECT SKIP piRegistro referencia,folio_suc,monto_tot,transacc,cuenta,SUBSTR(referencia,1,6)
				INTO cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,cReferencia
				FROM bdicheq:"informix".sc_movdia
				WHERE empresa = '001' AND transacc IN ('1193','1194')
				AND fech_alt = pdFecha
				AND sucursal = pcSucursal
				ORDER BY folio_suc

				--Se obtiene el banco
				IF LENGTH (cNumTarjeta) = 15 THEN
					LET cReferencia = SUBSTR(cNumTarjeta,1,2);
					
					SELECT valor INTO vValor
					FROM bdisac:sac_param WHERE cod_param = cReferencia;
					
					IF (vValor	 <> '' OR vValor IS NOT NULL) THEN
						SELECT valor INTO cBanco FROM bdisac:sac_param WHERE cod_param = cReferencia;
					ELSE
						LET cCodRet = "00058";
					END IF;
				ELSE
				
				SELECT NVL(banco_prosa,'')
				INTO cBanco
				FROM bdicheq:"informix".sc_bines
				WHERE bin = cReferencia;
				END IF;
				LET cCodRet = '00000';
				RETURN cCodRet,cSucursal,cRegion,cBanco,cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,mImpEfectivo,mImpCargo,iContador WITH RESUME;
			END FOREACH;
		ELSE
			LET cCodRet = '00001';
			RETURN cCodRet,cSucursal,cRegion,cBanco,cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,mImpEfectivo,mImpCargo,iContador;
		END IF;
	ELIF pcTipo = 2 THEN
			--Se obtiene el importe y cantidad de movimientos de efectivo
		IF pdFecha >= vconsmovhis then
			
			SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
			INTO mImpEfectivo,iContEfec
			FROM bdicheq:"informix".sc_movhis
			WHERE empresa = '001' AND transacc = '1193'
			AND fech_alt = pdFecha
			AND CANCELAD <> 'S'
			AND sucursal = pcSucursal;

			--Se obtiene el importe y cantidad de movimientos de cargo
			
			SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
			INTO mImpCargo,iContCargo
			FROM bdicheq:"informix".sc_movhis
			WHERE empresa = '001' AND transacc = '1194'
			AND fech_alt = pdFecha
			AND CANCELAD <> 'S'
			AND sucursal = pcSucursal;

			--Contador de movimientos
			LET iContador = iContEfec + iContCargo;
			-- Se reemplaza la consulta para contar los movimientos por la suma de las variables obtenidas previamente
			LET iiCuantos = iContEfec + iContCargo;
			
			--Se obtiene la informacion historica.
			-- SELECT COUNT(transacc) INTO iiCuantos
			-- FROM bdicheq:"informix".sc_movhis
			-- WHERE empresa = '001' AND transacc IN ('1193','1194')
			-- AND fech_alt = pdFecha
			-- AND sucursal = pcSucursal
			-- AND CANCELAD <> 'S';
			
			IF (iiCuantos > 0) THEN
				
				FOREACH
					SELECT SKIP piRegistro referencia,folio_suc,monto_tot,transacc,cuenta,SUBSTR(referencia,1,6)
					INTO cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,cReferencia
					FROM bdicheq:"informix".sc_movhis
					WHERE empresa = '001' AND transacc IN ('1193','1194')
					AND fech_alt = pdFecha
					AND sucursal = pcSucursal
					AND CANCELAD <> 'S'
					ORDER BY folio_suc

					--Se obtiene el banco					
					IF LENGTH (cNumTarjeta) = 15 THEN
						LET cReferencia = SUBSTR(cNumTarjeta,1,2);
						
						---    IF EXISTS (SELECT valor FROM bdisac:sac_param WHERE cod_param = cReferencia) THEN
						SELECT valor INTO vValor_2
						FROM bdisac:sac_param WHERE cod_param = cReferencia;
						
						IF (vValor_2 <> '' OR vValor_2 IS NOT NULL) THEN						
							SELECT valor INTO cBanco FROM bdisac:sac_param WHERE cod_param = cReferencia;
						ELSE
							LET cCodRet = "00058";
						END IF;
					ELSE
					SELECT NVL(banco_prosa,'')
					INTO cBanco
					FROM bdicheq:"informix".sc_bines
					WHERE bin = cReferencia;
					end if
					LET cCodRet = '00000';
					RETURN cCodRet,cSucursal,cRegion,cBanco,cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,mImpEfectivo,mImpCargo,iContador WITH RESUME;
				END FOREACH;
			ELSE 
				LET cCodRet = '00001';
				RETURN cCodRet,cSucursal,cRegion,cBanco,cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,mImpEfectivo,mImpCargo,iContador;
			END IF;
		ELSE
			
			SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
			INTO mImpEfectivo,iContEfec
			FROM bdicheq:"informix".sc_movhis_old
			WHERE empresa = '001' AND transacc = '1193'
			AND fech_alt = pdFecha
			AND CANCELAD <> 'S'
			AND sucursal = pcSucursal;

			--Se obtiene el importe y cantidad de movimientos de cargo
			
			SELECT NVL(SUM(monto_tot),0), COUNT(transacc)
			INTO mImpCargo,iContCargo
			FROM bdicheq:"informix".sc_movhis_old
			WHERE empresa = '001' AND transacc = '1194'
			AND fech_alt = pdFecha
			AND CANCELAD <> 'S'
			AND sucursal = pcSucursal;

			--Contador de movimientos
			LET iContador = iContEfec + iContCargo;
			-- Se reemplaza la consulta para contar los movimientos por la suma de las variables obtenidas previamente
			LET iiiCuantos = iContEfec + iContCargo;
					
			-- SELECT count(transacc) INTO iiiCuantos
			-- FROM bdicheq:"informix".sc_movhis_old
			-- WHERE empresa = '001' AND transacc IN ('1193','1194')
			-- AND fech_alt = pdFecha
			-- AND sucursal = pcSucursal
			-- AND CANCELAD <> 'S';	
			
			IF (iiiCuantos > 0) THEN
					--Se obtiene la informacion historica.
					
					FOREACH
						SELECT SKIP piRegistro referencia,folio_suc,monto_tot,transacc,cuenta,SUBSTR(referencia,1,6)
						INTO cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,cReferencia
						FROM bdicheq:"informix".sc_movhis_old
						WHERE empresa = '001' AND transacc IN ('1193','1194')
						AND fech_alt = pdFecha
						AND sucursal = pcSucursal
						AND CANCELAD <> 'S'
						ORDER BY folio_suc

						--Se obtiene el banco
						
						IF LENGTH (cNumTarjeta) = 15 THEN
							LET cReferencia = SUBSTR(cNumTarjeta,1,2);
							
							SELECT valor INTO vValor_3
							FROM bdisac:sac_param WHERE cod_param = cReferencia;
							
							IF (vValor_3 <> '' OR vValor_3 IS NOT NULL) THEN								
								SELECT valor INTO cBanco FROM bdisac:sac_param WHERE cod_param = cReferencia;
							ELSE
								LET cCodRet = "00058";
							END IF;
						ELSE
							SELECT NVL(banco_prosa,'')
							INTO cBanco
							FROM bdicheq:"informix".sc_bines
							WHERE bin = cReferencia;
						END IF
						LET cCodRet = '00000';
						RETURN cCodRet,cSucursal,cRegion,cBanco,cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,mImpEfectivo,mImpCargo,iContador WITH RESUME;
					END FOREACH;
			ELSE
				LET cCodRet = '00001';
				RETURN cCodRet,cSucursal,cRegion,cBanco,cNumTarjeta,cSecuencia,mImporte,cTransaccion,cCuenta,mImpEfectivo,mImpCargo,iContador;
			END IF;
		END IF;
	END IF;
END;
END PROCEDURE;