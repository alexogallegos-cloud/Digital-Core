CREATE PROCEDURE "informix".sp_con_consultausokiosko_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
                RETURNING CHAR(5) AS codret,
                INTEGER     AS total_registros;         
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iNoRegistros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iNoRegistros = 0;
        
        BEGIN        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet, iNoRegistros;
			END EXCEPTION;
                
			-- SET DEBUG FILE TO '/tmp/mfinis/sp_con_consultausokiosko_totales.out';
			-- TRACE ON;
			
			IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
					LET cCodRet = '00003';
					RETURN cCodRet, iNoRegistros;
			END IF;
			
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet, iNoRegistros;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			IF pFechaInicio = pFechaFin THEN
					SELECT COUNT(DISTINCT(sucursal))
					INTO iNoRegistros
					FROM bdinteg:"informix".si_indicadores_kiosko 
					WHERE fecha_proceso = pFechaInicio;
																			
			ELSE 
					SELECT COUNT(DISTINCT(sucursal))
					INTO iNoRegistros
					FROM bdinteg:"informix".si_indicadores_kiosko 
					WHERE fecha_proceso  BETWEEN pFechaInicio AND pFechaFin;
			
			END IF;
			IF iNoRegistros = 0  THEN
					LET cCodRet = '00017';
					RETURN cCodRet, iNoRegistros;   
			END IF;
			
			RETURN cCodRet, iNoRegistros;
			
        END;    
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 10/08/2016',
'MODULO: CONSULTAS ',
'FUNCIONALIDAD: REPORTE PROCESOS SUCURSAL',
'DESCRIPCION:SPL que consulta el total del uso del kiosco en el Reporte Procesos Sucursal.',
'BD: bdicnweb',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 22/08/2016',
'DESCRIPCION:Se realiza una modificación para quitar el left join.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoparammc(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			INTEGER AS id_param,
			CHAR(1) AS tipo,
			SMALLINT AS valor,
			CHAR(2) AS marca,
            CHAR(100) AS desc_param;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdParam INTEGER;
	DEFINE cTipo CHAR(1);
	DEFINE sValor SMALLINT;
	DEFINE cMarca CHAR(2);
	DEFINE cDescParam CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdParam = 0;
	LET cTipo = '';
	LET sValor = 0;
	LET cMarca = '';
	LET cDescParam = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdParam, cTipo, sValor, cMarca, cDescParam;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoparammc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdParam, cTipo, sValor, cMarca, cDescParam;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdParam, cTipo, sValor, cMarca, cDescParam;
		END IF;
		
		FOREACH
			SELECT id_param, tipo, valor, marca, descripcion 
			INTO iIdParam, cTipo, sValor, cMarca, cDescParam
			FROM bdireports:'informix'.rpt_mc_param
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdParam, UPPER(cTipo), sValor, UPPER(cMarca), UPPER(cDescParam) WITH RESUME;
		END FOREACH;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdParam, cTipo, sValor, cMarca, cDescParam;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 18/09/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE TRIMESTRAL MASTERCARD', 
'DESCRIPCION: SPL, que hace la consulta para obtener el detalle de la tabla bdireports:rpt_mc_param.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultatrimestralopemc(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		SMALLINT AS trimestre;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE sTrimestre SMALLINT;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET sTrimestre = 0;
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sTrimestre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatrimestralopemc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, sTrimestre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, sTrimestre;
		END IF;
		
		FOREACH SELECT DISTINCT trimestre
				INTO sTrimestre
				FROM bdireports:"informix".rpt_mc_vol_tri 
				
			LET  iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, sTrimestre WITH RESUME;		
		END FOREACH;
	
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, sTrimestre;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 11/09/2015',
'MODULO: OPERACIONES   ',
'FUNCIONALIDAD: REPORTE TRIMESTRAL MASTERCARD',
'DESCRIPCION: Consulta el catálogo trimestral mastercard',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_genreporteinsertaltatrimestremc(pUsuario CHAR(8), pIdFuncion CHAR(10),pBandera CHAR(2), pNumProducto SMALLINT, pTrimestre SMALLINT, pFechaInicio DATE, pFechaFin DATE, pIdCol CHAR (3), pMes SMALLINT, pTotalCompras INTEGER, pMontoCompras MONEY(18,2),pTipoCompras CHAR (60), pTotalTrans INTEGER,pMontoTrans MONEY(18,2),pTipoTrans CHAR (60), pTotalDev INTEGER, pMontoDev MONEY(18,2), pTipoDev CHAR(60), pTotalCta INTEGER, pTipoCuenta CHAR (30), pIdTipo CHAR (1),pIdReporte SMALLINT, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		INTEGER			AS total_compras,
		MONEY (18,2)	AS monto_compras,
		INTEGER			AS total_transacciones,
		MONEY (18,2)	AS monto_transacciones,
		INTEGER			AS total_devolucion, 
		MONEY (18,2)	AS monto_devolucion,
		INTEGER 		AS total_cuenta;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotalCompras	INTEGER;
	DEFINE mMontoCompras	MONEY (18,2);
	DEFINE iTotalTransacciones	INTEGER;
	DEFINE mMontoTransacciones	MONEY (18,2);
	DEFINE iTotalDevolucion	INTEGER;
	DEFINE mMontoDevolucion	MONEY (18,2);
	DEFINE iTotalCuenta INTEGER;
	DEFINE lastSerial  CHAR (100);
	DEFINE pDesTabla CHAR(20);
	define pDestabla1 CHAR(20);
	DEFINE pDesCampo CHAR(20);
	DEFINE pDesCampo1 CHAR(20);
	DEFINE pDesCampo2	CHAR (20);
	DEFINE pDesCampo3	CHAR (20);
	DEFINE pDesCampo4	CHAR (20);
	DEFINE pDesCampo5	CHAR (20);
	DEFINE pDesCampo6	CHAR (20);
	DEFINE cAntTotalCompras INTEGER;
	DEFINE cAntMontoCompras	DECIMAL (18,2);
	DEFINE cAntTotalTransac INTEGER;
	DEFINE cAntMontoTransac DECIMAL (18,2);
	DEFINE cAntTotalDev INTEGER;
	DEFINE cAntMontoDev DECIMAL (18,2);
	DEFINE cAntTotalCta INTEGER;
	DEFINE cAntTotalCta1 INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotalCompras	= 0 ;
	LET mMontoCompras	= 0.0;
	LET iTotalTransacciones	= 0 ;
	LET mMontoTransacciones	= 0.0;
	LET iTotalDevolucion	= 0 ;
	LET mMontoDevolucion	= 0.0;
	LET iTotalCuenta = 0;
	LET lastSerial = '';
	LET pDesTabla = 'rpt_mc_vol_tri';
	LET pDestabla1 = 'rpt_mc_cta_tri';
	LET pDesCampo	= 'total_compras';
	LET pDesCampo1	= 'monto_compras';
	LET pDesCampo2	= 'total_transaciones';
	LET pDesCampo3	= 'monto_transaciones';
	LET pDesCampo4	= 'total_devoluciones';
	LET pDesCampo5	= 'monto_devoluciones';
	LET pDesCampo6	= 'total_cuentas';
	LET cAntTotalCompras = 0; 
	LET cAntMontoCompras = 0;
	LET cAntTotalTransac  = 0; 
	LET cAntMontoTransac  = 0;
	LET cAntTotalDev = 0; 
	LET cAntMontoDev = 0;
	LET	cAntTotalCta = 0;
	LET	cAntTotalCta1 = 0;	
	LET iNoRegistros = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones
			,iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genreporteinsertaltatrimestremc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumProducto IS NULL OR pTrimestre IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones
			,iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones
			,iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
		END IF;
		
		SET LOCK MODE TO  WAIT; 
		SET ISOLATION TO DIRTY READ;
		 
		IF pBandera = '1' THEN --Tarjetas de Credito
			IF  pTotalCompras IS NULL OR  pMontoCompras IS NULL OR pTipoCompras IS NULL THEN 
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta; 
			END IF;		
			IF NOT EXISTS (SELECT total_compras, monto_compras FROM bdireports:'informix'.rpt_mc_vol_tri WHERE num_producto = pNumProducto
				AND trimestre = pTrimestre AND id_col = pIdCol AND tipo_compras = pTipoCompras	) THEN
							
				INSERT INTO bdireports:'informix'.rpt_mc_vol_tri(num_producto,trimestre, id_col, mes, total_compras, monto_compras, tipo_compras, total_transacciones, monto_transacciones, tipo_transaccion, total_devolucion, monto_devolucion, tipo_devolucion)
				VALUES (pNumProducto,pTrimestre, pIdCol,pMes, pTotalCompras, pMontoCompras,pTipoCompras,pTotalTrans,pMontoTrans,pTipoTrans,pTotalDev, pMontoDev,pTipoDev);	
				LET lastSerial = dbinfo('sqlca.sqlerrd1');				
				INSERT INTO  bdireports:'informix'.rpt_mc_log 
					VALUES (pDesTabla,CURRENT , lastSerial, pTrimestre,pDesCampo, 0, pUsuario);
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
					VALUES (pDesTabla,CURRENT + INTERVAL (2) SECOND TO SECOND, lastSerial, pTrimestre,pDesCampo1, 0, pUsuario);
				RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta; 
			ELSE
				SELECT total_compras, monto_compras
				INTO cAntTotalCompras, cAntMontoCompras
				FROM bdireports:"informix".rpt_mc_vol_tri
				WHERE num_producto = pNumProducto
				AND trimestre = pTrimestre 
				AND id_col = pIdCol 
				AND tipo_compras = pTipoCompras;		
				UPDATE bdireports:"informix".rpt_mc_vol_tri 
				SET total_compras = pTotalCompras,
					monto_compras = pMontoCompras
					WHERE num_producto = pNumProducto
					AND trimestre = pTrimestre
					AND id_col = pIdCol
					AND tipo_compras = pTipoCompras; 
				IF(cAntTotalCompras <> pTotalCompras AND cAntMontoCompras <> pMontoCompras)THEN		
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
					VALUES (pDesTabla, CURRENT, pIdReporte, pTrimestre,pDesCampo, cAntTotalCompras, pUsuario);
					INSERT INTO  bdireports:'informix'.rpt_mc_log
					VALUES (pDesTabla, CURRENT + INTERVAL (2) SECOND TO SECOND, pIdReporte, pTrimestre,pDesCampo1, cAntMontoCompras, pUsuario);
					RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;	
				ELIF(cAntTotalCompras <> pTotalCompras)THEN		
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
					VALUES (pDesTabla, CURRENT, pIdReporte, pTrimestre,pDesCampo, cAntTotalCompras, pUsuario);
					RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
				ELIF (cAntMontoCompras <> pMontoCompras)THEN
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
					VALUES (pDesTabla, CURRENT , pIdReporte, pTrimestre,pDesCampo1, cAntMontoCompras, pUsuario);
					RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;					
				END IF;
			END IF;
		ELIF pBandera = '2' THEN --Transaccion de efectivo en ATM's
			IF   pTotalTrans IS NULL OR pMontoTrans IS NULL OR pTipoTrans = '' THEN 
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta; 
			END IF;					
			IF NOT EXISTS (SELECT total_transacciones, monto_transacciones FROM bdireports:'informix'.rpt_mc_vol_tri WHERE num_producto = pNumProducto
				AND trimestre = pTrimestre AND id_col = pIdCol AND tipo_transaccion = pTipoTrans) THEN
				INSERT INTO bdireports:'informix'.rpt_mc_vol_tri(num_producto,trimestre, id_col, mes, total_compras, monto_compras, tipo_compras, total_transacciones, monto_transacciones, tipo_transaccion, total_devolucion, monto_devolucion, tipo_devolucion)
				VALUES (pNumProducto,pTrimestre, pIdCol,pMes, pTotalCompras, pMontoCompras,pTipoCompras,pTotalTrans,pMontoTrans,pTipoTrans,pTotalDev, pMontoDev,pTipoDev);
				LET lastSerial = dbinfo('sqlca.sqlerrd1');
				INSERT INTO  bdireports:'informix'.rpt_mc_log
				VALUES (pDesTabla, CURRENT, lastSerial, pTrimestre,pDesCampo2, 0, pUsuario);
				INSERT INTO  bdireports:'informix'.rpt_mc_log
				VALUES (pDesTabla, CURRENT + INTERVAL (2) SECOND TO SECOND, lastSerial, pTrimestre,pDesCampo3, 0, pUsuario);
				RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
			ELSE
				SELECT total_transacciones, monto_transacciones
				INTO cAntTotalTransac, cAntMontoTransac
				FROM bdireports:'informix'.rpt_mc_vol_tri 
				WHERE num_producto = pNumProducto
				AND trimestre = pTrimestre 
				AND id_col = pIdCol 
				AND tipo_transaccion = pTipoTrans;				
				UPDATE bdireports:'informix'.rpt_mc_vol_tri
				SET total_transacciones = pTotalTrans,
				monto_transacciones = pMontoTrans
					WHERE num_producto = pNumProducto
					AND trimestre = pTrimestre
					AND id_col = pIdCol
					AND tipo_transaccion = pTipoTrans;
				IF (cAntTotalTransac <> pTotalTrans AND cAntMontoTransac <> pMontoTrans) THEN  
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
					VALUES (pDesTabla, CURRENT, pIdReporte, pTrimestre,pDesCampo2, cAntTotalTransac, pUsuario);
					INSERT INTO  bdireports:'informix'.rpt_mc_log
					VALUES (pDesTabla, CURRENT + INTERVAL (2) SECOND TO SECOND, pIdReporte, pTrimestre,pDesCampo3, cAntMontoTransac, pUsuario);
					RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;				
				ELIF (cAntTotalTransac <> pTotalTrans)THEN
					INSERT INTO  bdireports:'informix'.rpt_mc_log
					VALUES (pDesTabla, CURRENT, pIdReporte, pTrimestre,pDesCampo2, cAntTotalTransac, pUsuario);
					RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
				ELIF (cAntMontoTransac <> pMontoTrans)THEN
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
					VALUES (pDesTabla, CURRENT , pIdReporte, pTrimestre,pDesCampo3, cAntMontoTransac, pUsuario);
					RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;				
				 END IF;
			END IF;
		ELIF pBandera = '3' THEN --Cajero automatico  ATM's
			IF   pTotalDev IS NULL OR pMontoDev IS NULL OR pTipoDev = ''  THEN 
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta; 
			END IF;		
			IF NOT EXISTS (SELECT total_devolucion, monto_devolucion FROM bdireports:'informix'.rpt_mc_vol_tri WHERE num_producto = pNumProducto
				AND trimestre = pTrimestre AND id_col = pIdCol AND
				tipo_devolucion = pTipoDev) THEN
				INSERT INTO bdireports:'informix'.rpt_mc_vol_tri(num_producto,trimestre, id_col, mes, total_compras, monto_compras, tipo_compras, total_transacciones, monto_transacciones, tipo_transaccion, total_devolucion, monto_devolucion, tipo_devolucion)
				VALUES (pNumProducto,pTrimestre, pIdCol,pMes, pTotalCompras, pMontoCompras,pTipoCompras,pTotalTrans,pMontoTrans,pTipoTrans,pTotalDev, pMontoDev,pTipoDev);
				LET lastSerial = dbinfo('sqlca.sqlerrd1');
				INSERT INTO  bdireports:'informix'.rpt_mc_log
				VALUES (pDesTabla, CURRENT, lastSerial, pTrimestre,pDesCampo4, 0, pUsuario);				
				INSERT INTO  bdireports:'informix'.rpt_mc_log
				VALUES (pDesTabla, CURRENT + INTERVAL (2) SECOND TO SECOND, lastSerial, pTrimestre,pDesCampo5, 0, pUsuario);
				RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
			ELSE
				SELECT total_devolucion, monto_devolucion 
				INTO  cAntTotalDev, cAntMontoDev 
				FROM bdireports:'informix'.rpt_mc_vol_tri 
				WHERE num_producto = pNumProducto
				AND trimestre = pTrimestre 
				AND id_col = pIdCol 
				AND tipo_devolucion = pTipoDev;				
			
				UPDATE bdireports:'informix'.rpt_mc_vol_tri
				SET total_devolucion = pTotaldev,
				monto_devolucion = pMontoDev
					WHERE num_producto = pNumProducto
					AND trimestre = pTrimestre
					AND id_col = pIdCol
					AND tipo_devolucion = pTipoDev;					
				IF (cAntTotalDev <> pTotaldev AND cAntMontoDev <> pMontoDev) THEN 	
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
					VALUES (pDesTabla, CURRENT , pIdReporte, pTrimestre,pDesCampo4, cAntTotalDev, pUsuario);					
					INSERT INTO  bdireports:'informix'.rpt_mc_log
					VALUES (pDesTabla, CURRENT + INTERVAL (2) SECOND TO SECOND, pIdReporte, pTrimestre,pDesCampo5, cAntMontoDev, pUsuario);
					RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
				ELIF (cAntTotalDev <> pTotaldev)THEN
					INSERT INTO  bdireports:'informix'.rpt_mc_log
					VALUES (pDesTabla, CURRENT, pIdReporte, pTrimestre,pDesCampo4, cAntTotalDev, pUsuario);
					RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
				ELIF (cAntMontoDev <> pMontoDev)THEN
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
					VALUES (pDesTabla, CURRENT , pIdReporte, pTrimestre,pDesCampo5, cAntMontoDev, pUsuario);
				 RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
				 END IF;
			END IF;		
		ELIF pBandera = '4' THEN
			IF pTotalCta IS  NULL OR pTipoCuenta = '' OR pIdTipo = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta; 
			END IF;		
			IF NOT EXISTS(SELECT total_cuentas FROM bdireports:'informix'.rpt_mc_cta_tri 
					WHERE num_producto = pNumProducto
					AND trimestre = pTrimestre
					AND tipo_cuenta = pTipoCuenta
					
					AND id_tipo = pIdTipo) THEN					
			INSERT INTO bdireports:'informix'.rpt_mc_cta_tri (num_producto, trimestre, id_col, mes, fecha_reg, id_tipo, total_cuentas, tipo_cuenta)
			VALUES (pNumProducto,pTrimestre, pIdCol,pMes,CURRENT, pIdTipo, pTotalCta,pTipoCuenta);
			LET lastSerial = dbinfo('sqlca.sqlerrd1');
			INSERT INTO  bdireports:'informix'.rpt_mc_log 
			VALUES (pDesTabla1, CURRENT, lastSerial, pTrimestre,pDesCampo6, 0, pUsuario);
			RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
			ELSE
				SELECT total_cuentas
				INTO cAntTotalCta
				FROM bdireports:'informix'.rpt_mc_cta_tri 
				WHERE num_producto = pNumProducto
					AND trimestre = pTrimestre
					AND tipo_cuenta = pTipoCuenta 
					AND id_tipo = pIdTipo;						
				UPDATE bdireports:'informix'.rpt_mc_cta_tri
					SET total_cuentas = pTotalCta
				WHERE num_producto = pNumProducto
					AND trimestre = pTrimestre
					AND tipo_cuenta = pTipoCuenta
					AND id_tipo = pIdTipo;
				IF (cAntTotalCta <> pTotalCta)THEN	
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
						VALUES (pDesTabla1, CURRENT, pIdReporte, pTrimestre,pDesCampo6, cAntTotalCta, pUsuario);
						RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, cAntTotalCta;
				END IF;
			END IF;
		ELIF pBandera = '5' THEN
			IF pTotalCta IS  NULL OR pTipoCuenta = '' OR pIdTipo = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
			END IF;		
			IF NOT EXISTS (SELECT total_cuentas FROM bdireports:'informix'.rpt_mc_cta_tri 
							WHERE num_producto = pNumProducto
							AND trimestre = pTrimestre
							AND fecha_reg BETWEEN pFechaInicio AND pFechaFin
							AND tipo_cuenta = pTipoCuenta
							AND id_tipo = pIdTipo) THEN
			INSERT INTO bdireports:'informix'.rpt_mc_cta_tri(num_producto, trimestre, id_col, mes, fecha_reg, id_tipo, total_cuentas, tipo_cuenta)
			VALUES (pNumProducto,pTrimestre, pIdCol,pMes, CURRENT, pIdTipo, pTotalCta,pTipoCuenta);
			LET lastSerial = dbinfo('sqlca.sqlerrd1');
			INSERT INTO  bdireports:'informix'.rpt_mc_log 
			VALUES (pDesTabla1, CURRENT , lastSerial, pTrimestre,pDesCampo6, 0, pUsuario);		
			RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta; 		
			ELSE			
				SELECT total_cuentas
				INTO cAntTotalCta1
				FROM bdireports:'informix'.rpt_mc_cta_tri 
				WHERE num_producto = pNumProducto
					AND trimestre = pTrimestre
					AND fecha_reg BETWEEN pFechaInicio AND pFechaFin
					AND tipo_cuenta = pTipoCuenta
					AND id_tipo = pIdTipo;								
				UPDATE bdireports:'informix'.rpt_mc_cta_tri
					SET total_cuentas = pTotalCta
				WHERE num_producto = pNumProducto
					AND trimestre = pTrimestre
					AND fecha_reg BETWEEN pFechaInicio AND pFechaFin
					AND tipo_cuenta = pTipoCuenta
					AND id_tipo = pIdTipo;					
				IF (cAntTotalCta1 <> pTotalCta)THEN	
					INSERT INTO  bdireports:'informix'.rpt_mc_log 
						VALUES (pDesTabla1, CURRENT + INTERVAL (2) SECOND TO SECOND, pIdReporte, pTrimestre,pDesCampo6, cAntTotalCta1, pUsuario);
						RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
				END IF;
			LET iNoRegistros = iNoRegistros + 1;
			END IF; 
		END IF;		
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalCompras,mMontoCompras, iTotalTransacciones,mMontoTransacciones, iTotalDevolucion, mMontoDevolucion, iTotalCuenta;
			END IF;	
		END;
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 26/10/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE TRIMESTRAL MASTERCARD',
'DESCRIPCION: SPL que actualiza e inserta los datos correspondientes para el trimestre de mastercard ',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_imprimecedulas( pFechaConcil DATE, pTipo SMALLINT )
RETURNING CHAR(5), CHAR(40), CHAR(14), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), CHAR(255);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(40);
    DEFINE cCtaContable     CHAR(14);
    DEFINE mSdoCheques      DECIMAL(18,2);
    DEFINE mSdoContab       DECIMAL(18,2);
    DEFINE mDifSaldos       DECIMAL(18,2);
    DEFINE cObservaciones   CHAR(255);
    
    LET cCodRet1       = '000';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    LET iSqlErr	       = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
    LET iExiste        = 0;
    LET cNombre        = '';
    LET cCtaContable   = '';
    LET mSdoCheques    = 0.00;
    LET mSdoContab     = 0.00;
    LET mDifSaldos     = 0.00;
    LET cObservaciones = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_imprimecedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_imprimecedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'CAPITAL'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INTERES'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'SOBREGIRO'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones
                  FROM bdicheq:sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INT PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones;
        END IF;
    END IF;
     
    END;
    
END PROCEDURE;