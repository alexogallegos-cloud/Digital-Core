CREATE PROCEDURE "informix".sp_actualizacomprasdepositoscaja(pUsuario CHAR(8), pIdFuncion CHAR(10), 
	pIdProvCaja CHAR(4), pIdOperacion CHAR(4), pDivisa CHAR(2), pIdProcedencia CHAR(4), pMontoTotalSolCap MONEY(14,2), pMonto MONEY(14,2), 
	pDenominacion1 CHAR(18), pDenominacion2 CHAR(18), pDenominacion3 CHAR(18), pDenominacion4 CHAR(18), pDenominacion5 CHAR(18),	
	pDenominacion6 CHAR(18), pDenominacion7 CHAR(18), pDenominacion8 CHAR(18), pDenominacion9 CHAR(18), pDenominacion10 CHAR(18), 
	pDenominacion11 CHAR(18), pDenominacion12 CHAR(18), pDenominacion13 CHAR(18), pDenominacion14 CHAR(18), pDenominacion15 CHAR(18), 
	pCantidad1 FLOAT(8), pCantidad2 FLOAT(8), pCantidad3 FLOAT(8), pCantidad4 FLOAT(8), pCantidad5 FLOAT(8), 
	pCantidad6 FLOAT(8), pCantidad7 FLOAT(8), pCantidad8 FLOAT(8), pCantidad9 FLOAT(8), pCantidad10 FLOAT(8), 
	pCantidad11 FLOAT(8), pCantidad12 FLOAT(8), pCantidad13 FLOAT(8), pCantidad14 FLOAT(8), pCantidad15 FLOAT(8))
			
		RETURNING CHAR(5) AS codret, 
			CHAR(8) AS no_folio;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cCodTrans CHAR(4);
		DEFINE cSigno CHAR(1);
		DEFINE iNoFolio INTEGER;
		DEFINE cNoFolio CHAR(8);
		DEFINE cSucursal CHAR(4);
		DEFINE cFolioSucursal  CHAR(16);
		DEFINE cFolio CHAR(8);
        DEFINE iNoRegistros INTEGER; 
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cCodTrans = '';
		LET cSigno = '';
		LET iNoFolio = 0;
		LET cNoFolio = '';
		LET cSucursal = '';
		LET cFolioSucursal  = '';
		LET cFolio = '';
        LET iNoRegistros = 0; 
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cFolio;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_actualizacomprasdepositoscaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pIdProvCaja = '' OR pIdOperacion = '' OR pDivisa = '' OR pIdProcedencia = '' OR pMonto IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFolio;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cFolio;
			END IF;
		
			SET ISOLATION TO DIRTY READ;

			SELECT codigo INTO cCodTrans 
			FROM bdisuc:'informix'.ss_param_cajagen WHERE valor = pIdOperacion; 
		
			SELECT valor INTO iNoFolio 
			FROM bdisuc:'informix'.ss_param_cajagen WHERE codigo = '0005';       
			
			LET cNoFolio = LPAD(iNoFolio, 8, 0);
			LET cSucursal = '9250';
			LET cFolioSucursal = pUsuario || cNoFolio;

			FOREACH	
				EXECUTE PROCEDURE bdisuc:'informix'.sp_solic_con_terc('001', pIdProvCaja, cSucursal, pIdProvCaja, pUsuario, 
					cFolioSucursal, pIdOperacion, pDivisa, pIdProcedencia, pMontoTotalSolCap, pMontoTotalSolCap, pMonto, CURRENT,
					pDenominacion1, pDenominacion2, pDenominacion3, pDenominacion4, pDenominacion5,	pDenominacion6, pDenominacion7, 
					pDenominacion8, pDenominacion9, pDenominacion10, pDenominacion11, pDenominacion12, pDenominacion13, pDenominacion14, 
					pDenominacion15, pCantidad1, pCantidad2, pCantidad3, pCantidad4, pCantidad5, pCantidad6, pCantidad7, 
					pCantidad8, pCantidad9, pCantidad10, pCantidad11, pCantidad12, pCantidad13, pCantidad14, pCantidad15, cNoFolio)
				
				INTO cCodRetSp, cFolio
				
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_solic_con_terc';
				ELIF cCodRetSp::INTEGER = 110 THEN
					LET cCodRet = '00003'; 
					RETURN cCodRet, cFolio;
				ELSE
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cFolio WITH RESUME;
				END IF;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cFolio;
			END IF;

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/02/2015',
'DESCRIPCION: SPL que realiza la inserciÃ³n de nuevos registros a las tablas bdisuc:ss_operaciones y bdisuc:ss_mae_entradasalida, asÃ­ como la actualizaciÃ³n',
'de datos a la tabla bdisuc:ss_operaciones cuando se aplica una compra y/o depÃ³sito de la caja general consultada',
'FUNCIONALIDAD: Compras y DepÃ³sitos Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizaregistrocaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1),
		pCodigo CHAR(4), pDescripcion CHAR(30), pIdDivisa CHAR(2), pIdPlaza CHAR(3))
					
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;		
		DEFINE dCantidad_1 MONEY(14,2);
		DEFINE dCantidad_2 MONEY(14,2);
		DEFINE dCantidad_3 MONEY(14,2);
		DEFINE dCantidad_4 MONEY(14,2);
		DEFINE dCantidad_5 MONEY(14,2);
		DEFINE dCantidad_6 MONEY(14,2);
		DEFINE dCantidad_7 MONEY(14,2);
		DEFINE dCantidad_8 MONEY(14,2);
		DEFINE dCantidad_9 MONEY(14,2);
		DEFINE dCantidad_10 MONEY(14,2);
		DEFINE dCantidad_11 MONEY(14,2);
		DEFINE dCantidad_12 MONEY(14,2);
		DEFINE dCantidad_13 MONEY(14,2);
		DEFINE dCantidad_14 MONEY(14,2);
		DEFINE dCantidad_15 MONEY(14,2);
		DEFINE cEmpresa CHAR(3);
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET dCantidad_1 = 0.00;
		LET dCantidad_2 = 0.00;
		LET dCantidad_3 = 0.00;
		LET dCantidad_4 = 0.00;
		LET dCantidad_5 = 0.00;
		LET dCantidad_6 = 0.00;
		LET dCantidad_7 = 0.00;
		LET dCantidad_8 = 0.00;
		LET dCantidad_9 = 0.00;
		LET dCantidad_10 = 0.00;
		LET dCantidad_11 = 0.00;
		LET dCantidad_12 = 0.00;
		LET dCantidad_13 = 0.00;
		LET dCantidad_14 = 0.00;
		LET dCantidad_15 = 0.00;
		LET cEmpresa = '001';
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet; 
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_actualizaregistrocaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion = '' OR pCodigo = '' OR pDescripcion = '' OR pIdDivisa = '' OR pIdPlaza = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet; 
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet; 
			END IF;
			
			IF pTipoOperacion = '3' THEN
				SELECT cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,
					   cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,
					   cantidad_11,cantidad_12,cantidad_13,cantidad_14,cantidad_15 	
					   
				INTO dCantidad_1, dCantidad_2, dCantidad_3, dCantidad_4, dCantidad_5, 
					 dCantidad_6, dCantidad_7, dCantidad_8, dCantidad_9, dCantidad_10, 
					 dCantidad_11, dCantidad_12, dCantidad_13, dCantidad_14, dCantidad_15 
	
			    FROM bdisuc:'informix'.ss_cajageneral WHERE cod_proveedor = pCodigo;  
				
				IF dCantidad_1 <> 0 AND dCantidad_2 <> 0 AND dCantidad_3 <> 0 AND dCantidad_4 <> 0 AND dCantidad_5 <> 0 AND 
				   dCantidad_6 <> 0 AND dCantidad_7 <> 0 AND dCantidad_8 <> 0 AND dCantidad_9 <> 0 AND dCantidad_10 <> 0 AND 
				   dCantidad_11 <> 0 AND dCantidad_12 <> 0 AND dCantidad_13 <> 0 AND dCantidad_14 <> 0 AND dCantidad_15  <> 0 THEN
					 
				    LET cCodRet = '00467'; --NO SE PUEDE ELIMINAR LA CAJA GENERAL PORQUE TIENE EFECTIVO
					RETURN cCodRet;
				END IF;
			END IF;
		
			EXECUTE PROCEDURE bdisuc:'informix'.manejacajageneral(pTipoOperacion, '001', pCodigo, pDescripcion, pIdDivisa, pIdPlaza)
			INTO cCodRetSp;

			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:manejacajageneral';
			ELIF cCodRetSp::INTEGER = 102 THEN
				LET cCodRet = '00463'; --LA CAJA GENERAL NO PUDO SER MODIFICADA
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 103 THEN
				LET cCodRet = '00464'; --LA CAJA GENERAL YA TIENE ASIGNADA UNA PLAZA
				RETURN cCodRet;
			ELIF cCodRetSp::INTEGER = 104 THEN
				LET cCodRet = '00465'; --LA CAJA GENERAL TIENE SALDOS U OPERACIONES PENDIENTES
				RETURN cCodRet;
			END IF;	
			
			RETURN cCodRet;

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/03/2015',
'DESCRIPCION: SPL que hace la actualizacion (insert, update, delete) del catalogo de caja general.',
'FUNCIONALIDAD: Mantenimiento CatÃ¡logo Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizasdosucursalcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta DATE)
	
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE dFechaAnterior DATE;
		DEFINE sEmpresa CHAR(3);
		DEFINE sSucursal CHAR(4);
		DEFINE sDivisa CHAR(2);
		DEFINE sSaldoTotal MONEY(14,2);
		DEFINE sFecha DATE;
		DEFINE sCajeroPrincipal CHAR(8);
		DEFINE sDeno1 CHAR(18);
		DEFINE sDeno2 CHAR(18);
		DEFINE sDeno3 CHAR(18);
		DEFINE sDeno4 CHAR(18);
		DEFINE sDeno5 CHAR(18);
		DEFINE sDeno6 CHAR(18);
		DEFINE sDeno7 CHAR(18);
		DEFINE sDeno8 CHAR(18);
		DEFINE sDeno9 CHAR(18);
		DEFINE sDeno10 CHAR(18);
		DEFINE sDeno11 CHAR(18);
		DEFINE sDeno12 CHAR(18);
		DEFINE sDeno13 CHAR(18);
		DEFINE sDeno14 CHAR(18);
		DEFINE sDeno15 CHAR(18);
		DEFINE sCant1 DECIMAL(10,2);
		DEFINE sCant2 DECIMAL(10,2);
		DEFINE sCant3 DECIMAL(10,2);
		DEFINE sCant4 DECIMAL(10,2);
		DEFINE sCant5 DECIMAL(10,2);
		DEFINE sCant6 DECIMAL(10,2);
		DEFINE sCant7 DECIMAL(10,2);
		DEFINE sCant8 DECIMAL(10,2);
		DEFINE sCant9 DECIMAL(10,2);
		DEFINE sCant10 DECIMAL(10,2);
		DEFINE sCant11 DECIMAL(10,2);
		DEFINE sCant12 DECIMAL(10,2);
		DEFINE sCant13 DECIMAL(10,2);
		DEFINE sCant14 DECIMAL(10,2);
		DEFINE sCant15 DECIMAL(10,2);
		DEFINE dFechaPase DATE;
		DEFINE iContSaldosSuc INTEGER; 
		DEFINE iContPaseSuc INTEGER;
        DEFINE iRegistrosAfectados INTEGER; 
		DEFINE iContPase INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET dFechaAnterior = '';
		LET sEmpresa = '';
		LET sSucursal = '';
		LET sDivisa = '';
		LET sSaldoTotal = NULL;
		LET sFecha = '';
		LET sCajeroPrincipal = '';
		LET sDeno1 = '';
		LET sDeno2 = '';
		LET sDeno3 = '';
		LET sDeno4 = '';
		LET sDeno5 = '';
		LET sDeno6 = '';
		LET sDeno7 = '';
		LET sDeno8 = '';
		LET sDeno9 = '';
		LET sDeno10 = '';
		LET sDeno11 = '';
		LET sDeno12 = '';
		LET sDeno13 = '';
		LET sDeno14 = '';
		LET sDeno15 = '';
		LET sCant1 = 0.00;
		LET sCant2 = 0.00;
		LET sCant3 = 0.00;
		LET sCant4 = 0.00;
		LET sCant5 = 0.00;
		LET sCant6 = 0.00;
		LET sCant7 = 0.00;
		LET sCant8 = 0.00;
		LET sCant9 = 0.00;
		LET sCant10 = 0.00;
		LET sCant11 = 0.00;
		LET sCant12 = 0.00;
		LET sCant13 = 0.00;
		LET sCant14 = 0.00;
		LET sCant15 = 0.00;
		LET dFechaPase = '';
		LET iContSaldosSuc = 0; 
		LET iContPaseSuc = 0;
        LET iRegistrosAfectados = 0; 
		LET iContPase = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_actualizasdosucursalcaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta = '' OR pFechaConsulta IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
		
			-- SE CALCULA LA FECHA ANTERIOR
			LET dFechaAnterior = DATE(pFechaConsulta) -1;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH SELECT DISTINCT NVL(sal.empresa,''),NVL(sal.sucursal,''),NVL(sal.divisa,''),NVL(sal.saldo_total,''),NVL(sal.fecha,''),NVL(sal.cajero_principal,''),
							sal.denominacion_1,sal.denominacion_2,sal.denominacion_3,sal.denominacion_4,sal.denominacion_5,
							sal.denominacion_6,sal.denominacion_7,sal.denominacion_8,sal.denominacion_9,sal.denominacion_10,
							sal.denominacion_11,sal.denominacion_12,sal.denominacion_13,sal.denominacion_14,sal.denominacion_15,
							NVL(sal.cantidad_1,''),NVL(sal.cantidad_2,''),NVL(sal.cantidad_3,''),NVL(sal.cantidad_4,''),NVL(sal.cantidad_5,''),
							NVL(sal.cantidad_6,''),NVL(sal.cantidad_7,''),NVL(sal.cantidad_8,''),NVL(sal.cantidad_9,''),NVL(sal.cantidad_10,''),
							NVL(sal.cantidad_11,''),NVL(sal.cantidad_12,''),NVL(sal.cantidad_13,''),NVL(sal.cantidad_14,''),NVL(sal.cantidad_15,'') 
			INTO sEmpresa,sSucursal,sDivisa,sSaldoTotal,sFecha,sCajeroPrincipal,sDeno1,sDeno2,sDeno3,sDeno4,sDeno5,
			sDeno6,sDeno7,sDeno8,sDeno9,sDeno10,sDeno11,sDeno12,sDeno13,sDeno14,sDeno15,sCant1,sCant2,sCant3,sCant4,sCant5,
			sCant6,sCant7,sCant8,sCant9,sCant10,sCant11,sCant12,sCant13,sCant14,sCant15
			FROM bdisuc:'informix'.ss_saldossuc AS sal INNER JOIN bdinteg:'informix'.si_sucursales AS suc 
			ON sal.sucursal = suc.sucursal AND suc.tpo_sucursal = 'S' AND sal.fecha = dFechaAnterior
			
			SELECT COUNT (*) INTO iContPase
			FROM bdisuc:ss_pase_sucursal WHERE fecha_pase = pFechaConsulta AND sucursal = sSucursal;
			
			IF iContPase = 0 THEN	
				SELECT COUNT (*) INTO iContSaldosSuc
				FROM bdisuc:'informix'.ss_saldossuc WHERE fecha = pFechaConsulta AND sucursal = sSucursal;
				
				IF iContSaldosSuc = 0 THEN
					
					INSERT INTO bdisuc:'informix'.ss_saldossuc (empresa,sucursal,divisa,saldo_total,fecha,cajero_principal,
								denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
								denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,
								denominacion_11,denominacion_12,denominacion_13,denominacion_14,denominacion_15,
								cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,
								cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,
								cantidad_11,cantidad_12,cantidad_13,cantidad_14,cantidad_15)
					VALUES (sEmpresa,sSucursal,sDivisa,sSaldoTotal,pFechaConsulta,pUsuario,sDeno1,sDeno2,sDeno3,sDeno4,sDeno5,
							sDeno6,sDeno7,sDeno8,sDeno9,sDeno10,sDeno11,sDeno12,sDeno13,sDeno14,sDeno15,sCant1,sCant2,sCant3,sCant4,sCant5,
							sCant6,sCant7,sCant8,sCant9,sCant10,sCant11,sCant12,sCant13,sCant14,sCant15);
					
					INSERT INTO bdisuc:'informix'.ss_pase_sucursal (sucursal,suc_abrio,suc_cerro,fecha_pase,usuario)
					VALUES (sSucursal,'0','0',pFechaConsulta,pUsuario);
				
					LET iRegistrosAfectados = iRegistrosAfectados + 1;
				
				ELSE
				
					SELECT COUNT (*) INTO iContPaseSuc
					FROM bdisuc:'informix'.ss_pase_sucursal WHERE fecha_pase = pFechaConsulta AND sucursal = sSucursal;
					
					IF iContPaseSuc = 0 THEN
					
						INSERT INTO bdisuc:'informix'.ss_pase_sucursal (sucursal,suc_abrio,suc_cerro,fecha_pase,usuario)
						VALUES (sSucursal,'0','0',pFechaConsulta,pUsuario);
			
						LET iRegistrosAfectados = iRegistrosAfectados + 1;
						
					END IF;				
			
				END IF;
			END IF;
			END FOREACH	
				
			IF iRegistrosAfectados = 0 THEN
				LET cCodRet = '00283';
			END IF;

			RETURN cCodRet;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/03/2015',
'DESCRIPCION: SPL que realiza la actualizaciÃ³n de saldos de las sucursales consultadas', 
'haciendo la inserciÃ³n de nuevos registros a las tablas bdisuc:ss_saldossuc y bdisuc:ss_pase_sucursal',
'FUNCIONALIDAD: Sucursales No Abiertas Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoaniocaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSaldo CHAR(1))
		RETURNING CHAR(5) AS codret,
			DATE AS anio_min_max;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dAnioMinMax DATE;
	DEFINE dAnioMin DATE;
	DEFINE dFechaMin DATE;
	DEFINE dFechaMax DATE;
	DEFINE iNoRegistros INTEGER;
	DEFINE iBandera INTEGER;
	DEFINE iTotalAnios INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dAnioMinMax = '';
	LET dAnioMin = '';
	LET dFechaMin = '';
	LET dFechaMax = '';
	LET iNoRegistros = 0;
	LET iBandera = 0;
	LET iTotalAnios = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dAnioMinMax;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoaniocaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSaldo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dAnioMinMax;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dAnioMinMax;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		IF pTipoSaldo = 'C' THEN
			
			SELECT MDY(MONTH(f.fecha_hoy - meses_saldos UNITS MONTH),1,YEAR(f.fecha_hoy - meses_saldos UNITS MONTH)) AS fecmin,
				   MDY(MONTH(fecha_hoy - 1 UNITS DAY),DAY(fecha_hoy - 1 UNITS DAY),YEAR(fecha_hoy - 1 UNITS DAY)) AS fecMax
			INTO dFechaMin, dFechaMax
			FROM bdicont:'informix'.co_fechas AS f, bdicont:'informix'.co_param AS p
			WHERE f.empresa = p.empresa AND p.empresa = f.empresa; 			
		
		ELIF pTipoSaldo = 'F' THEN
		
			SELECT min(fecha) AS fecmin, max(fecha) AS fecmax 
			INTO dFechaMin, dFechaMax
			FROM bdisuc:'informix'.ss_saldossuc;
	
		END IF;
	
		LET dAnioMin = dFechaMin - 1 UNITS YEAR;
		LET iTotalAnios = YEAR(dFechaMax) - YEAR(dFechaMin);
		
		WHILE(YEAR(dAnioMin) < YEAR(dFechaMax)) LOOP
			IF iBandera = 0 THEN 				 
				LET dAnioMin = dFechaMin;
				LET iBandera = iBandera + 1;				
				
			ELIF iBandera = iTotalAnios THEN    
				LET dAnioMin = dFechaMax;
				LET iBandera = iBandera + 1;
			ELSE								
				LET dAnioMin = TO_DATE(1||'/'||1||'/'||YEAR(dAnioMin + 1 UNITS YEAR),'%d/%m/%Y'); 
				LET iBandera = iBandera + 1;
			END IF;
			
			LET dAnioMinMax = dAnioMin;
			RETURN cCodRet, dAnioMinMax WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;
		END LOOP;
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dAnioMinMax;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 01/04/2015',
'DESCRIPCION: SPL, que obteniene un listado de fechas dependiendo del tipo de saldo consultado',
'FUNCIONALIDAD: HistÃ³rico de Saldos Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoctascontablecaja(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(20) AS cIdCuenta;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdCuenta CHAR(20);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdCuenta = '';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdCuenta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoctascontablecaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdCuenta;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdCuenta;
		END IF;
			
		FOREACH
			SELECT valor INTO cIdCuenta 
			FROM bdisuc:'informix'.ss_param_cajagen 
			WHERE descripcion = 'Cuentas Historico Saldos' ORDER BY valor ASC
			RETURN cCodRet, cIdCuenta WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdCuenta;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 01/04/2015',
'DESCRIPCION: SPL, que genera una catÃ¡logo de cuentas a partir de una consulta realizada a la tabla bdisuc:ss_param_cajagen',
'FUNCIONALIDAD: HistÃ³rico de Saldos Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogomesaniocaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pIndicador CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS mes_recepcion,
			CHAR(4) AS anio_recepcion;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dMesRecepcion CHAR(2);
	DEFINE dAnioRecepcion CHAR(4);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dMesRecepcion = '';
	LET dAnioRecepcion = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dMesRecepcion, dAnioRecepcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogomesaniocaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIndicador = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dMesRecepcion, dAnioRecepcion;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dMesRecepcion, dAnioRecepcion;
		END IF;
		
		--SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		 
		IF pIndicador = '1' THEN
		
			-- COMBOBOX MES 
			FOREACH	 				
				SELECT DISTINCT MONTH(fecha_recepcion) 
				INTO dMesRecepcion
				FROM bdisuc:'informix'.ss_mae_entradasalida 
				WHERE MONTH(fecha_recepcion) IS NOT NULL ORDER BY MONTH(fecha_recepcion)
				RETURN cCodRet, dMesRecepcion, dAnioRecepcion WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		ELIF pIndicador = '2' THEN
		
			-- COMBOBOX AÃO 
			FOREACH	 				
				SELECT DISTINCT YEAR(fecha_recepcion) 
				INTO dAnioRecepcion
				FROM bdisuc:'informix'.ss_mae_entradasalida 
				WHERE YEAR(fecha_recepcion) IS NOT NULL ORDER BY YEAR(fecha_recepcion)
				RETURN cCodRet, dMesRecepcion, dAnioRecepcion WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, dMesRecepcion, dAnioRecepcion;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/01/2015',
'DESCRIPCION: SPL, que hace la consulta para obtener el mes y aÃ±o de recepcion, Consultas Entrada Salida Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoplazadivisacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1))
			
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS id_divisa,
            CHAR(30) AS desc_divisa,
			CHAR(3) AS id_plaza,
            CHAR(40) AS desc_plaza;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdDivisa CHAR(2);
	DEFINE cDescDivisa CHAR(30);
	DEFINE cIdPlaza CHAR(3);
	DEFINE cDescPlaza CHAR(40);

	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdDivisa = '';
	LET cDescDivisa = '';
	LET cIdPlaza = '';
	LET cDescPlaza = '';

	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdDivisa, cDescDivisa, cIdPlaza, cDescPlaza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoplazadivisacaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdDivisa, cDescDivisa, cIdPlaza, cDescPlaza;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdDivisa, cDescDivisa, cIdPlaza, cDescPlaza;
		END IF;
		
		SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		 
		IF pIdConsulta = '1' THEN 
		
			FOREACH
				SELECT divisa, descripcion INTO cIdDivisa, cDescDivisa
				FROM bdinteg:'informix'.si_divisas
				
				RETURN cCodRet, cIdDivisa, UPPER(cDescDivisa), cIdPlaza, UPPER(cDescPlaza) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		ELIF pIdConsulta = '2' THEN
		
			FOREACH
				SELECT codigo_plaza, descripcion INTO cIdPlaza, cDescPlaza
				FROM bdinteg:'informix'.si_plazas_cajagen ORDER BY codigo_plaza
				
				RETURN cCodRet, cIdDivisa, UPPER(cDescDivisa), cIdPlaza, UPPER(cDescPlaza) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;			
			
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdDivisa, cDescDivisa, cIdPlaza, cDescPlaza;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/03/2015',
'DESCRIPCION: SPL, que hace la consulta para obtener el id y la descripciÃ³n de dos catÃ¡logos, dependiendo del tipo de consulta que desea ejecutar', 
'con indicador pIdConsulta = 1 nos referimos al catÃ¡logo Divisa, con pIdConsulta = 2 al catÃ¡logo Plaza.',
'FUNCIONALIDAD: Mantenimiento CatÃ¡logo Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogoprocedenciacaja(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS id_procedencia, 
			CHAR(30) AS desc_procedencia;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdProcedencia CHAR(4);
	DEFINE cDescProcedencia CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdProcedencia = '';
	LET cDescProcedencia = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdProcedencia, cDescProcedencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogoprocedenciacaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdProcedencia, cDescProcedencia;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdProcedencia, cDescProcedencia;
		END IF;
		
		--SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		
		-- COMBOBOX PROCEDENCIA
		FOREACH
			SELECT codigo, descripcion INTO cIdProcedencia, cDescProcedencia 
			FROM bdisuc:'informix'.ss_cat_proveedor ORDER BY codigo
			RETURN cCodret, cIdProcedencia, UPPER(cDescProcedencia) WITH RESUME;
			LET iNoRegistros = iNoRegistros + 1;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdProcedencia, UPPER(cDescProcedencia);
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 19/01/2015',
'DESCRIPCION: SPL, que hace la consulta para obtener el codigo de procedencia y su descripcion, Cambio Billetes Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogostatuscaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(2))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS id_status, 
			CHAR(30) AS desc_status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdStatus CHAR(2); 
	DEFINE cDescStatus CHAR(30);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdStatus = ''; 
	LET cDescStatus = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdStatus, cDescStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogostatuscaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdStatus, cDescStatus;
		END IF;
		
		SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		
		-- COMBOBOX STATUS
		IF pTipoSucursal = 'S' THEN    -- RADIO SUCURSAL
		
			FOREACH
				SELECT status, descripcion 
				INTO cIdStatus, cDescStatus
				FROM bdisuc:'informix'.ss_catstatus
				WHERE tpo_sucursal != 'C' 
				RETURN cCodRet, cIdStatus, UPPER(cDescStatus) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
			
		ELIF pTipoSucursal = 'C' THEN  -- RADIO ATM
		
			FOREACH
				SELECT status, descripcion 
				INTO cIdStatus, cDescStatus
				FROM bdisuc:'informix'.ss_catstatus
				WHERE tpo_sucursal != 'S' 
				RETURN cCodRet, cIdStatus, UPPER(cDescStatus) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		ELIF pTipoSucursal = 'A' THEN  -- RADIO AMBOS
		
			FOREACH
				SELECT status, descripcion 
				INTO cIdStatus, cDescStatus
				FROM bdisuc:'informix'.ss_catstatus
				
				RETURN cCodRet, cIdStatus, UPPER(cDescStatus) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		END IF;	
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdStatus, UPPER(cDescStatus);
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 22/01/2015',
'DESCRIPCION: SPL, que hace la consulta para obtener el id y la descripciÃ³n del catÃ¡logo status, Consultas Entrada Salida Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogotipoperacioncaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(2))
		RETURNING CHAR(5) AS codret,
			CHAR(2) AS cIdMostrar,
			CHAR(25) AS cDescMostrar;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdMostrar CHAR(2);
	DEFINE cDescMostrar CHAR(25);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdMostrar = '';
	LET cDescMostrar = '';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdMostrar, cDescMostrar;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogotipoperacioncaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdMostrar, cDescMostrar;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdMostrar, cDescMostrar;
		END IF;
		
		--SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
			
			FOREACH
				SELECT id_mostrar, desc_mostrar INTO cIdMostrar, cDescMostrar FROM bdicnweb:'informix'.sw_tr_catalogo_consultaoperacion_caja WHERE id_operacion = pTipoSucursal
				RETURN cCodret, cIdMostrar, UPPER(cDescMostrar) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdMostrar, cDescMostrar;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 13/02/2015',
'DESCRIPCION: SPL, que genera una lista de datos que contiene un id y una descripciÃ³n para el llenado del combobox mostrar por',
'MODULO: Caja general',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catseleccionarchivodotacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(1))
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS id_valor,
            CHAR(35) AS descripcion;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdValor CHAR(4);
    DEFINE cDescripcion CHAR(35);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdValor = '';
	LET cDescripcion = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdValor, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catseleccionarchivodotacaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdValor, cDescripcion;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdValor, cDescripcion;
		END IF;
		
		SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		
		IF pTipoSucursal = 'S' THEN
		
			FOREACH
				SELECT SUBSTRING(valor FROM 1 FOR 4) AS valor, descripcion INTO cIdValor, cDescripcion
				FROM bdisuc:'informix'.ss_param_cajagen WHERE codigo = '0001'  
				
				IF SUBSTRING(cIdValor FROM 1 FOR 3) = '000' THEN 
					RETURN cCodRet, cIdValor, UPPER(cDescripcion) WITH RESUME;
					LET iNoRegistros = iNoRegistros + 1;
				END IF;
			END FOREACH;
		
		ELIF pTipoSucursal = 'C' THEN
		
			FOREACH
				SELECT SUBSTRING(valor FROM 1 FOR 4) AS valor, descripcion INTO cIdValor, cDescripcion
				FROM bdisuc:'informix'.ss_param_cajagen WHERE codigo = '0036'  
				RETURN cCodRet, cIdValor, UPPER(cDescripcion) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cIdValor, cDescripcion;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 13/02/2015',
'DESCRIPCION: SPL, que hace la consulta para obtener el id y la descripciÃ³n del catÃ¡logo selecciÃ³n.',
'FUNCIONALIDAD: EnvÃ­o de Archivos Dotaciones Sucursales Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_reporteenviodotaciones (pUsuario CHAR(8), 
                                                          pIdFuncion CHAR(10), 
                                                          pTipo CHAR(1), 
                                                          pCodProveedor CHAR(4), 
                                                          pSucursal CHAR(4), 
                                                          pFechaInicio DATE, 
                                                          pFechaFin DATE, 
                                                          pArchDescarga CHAR(150))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cCmdSelect CHAR(2500);
	DEFINE cCmdFrom CHAR(2500);
	DEFINE cCmdWhere CHAR(2500);
	DEFINE cCmdCount CHAR(2500);
	DEFINE cStatus CHAR(2);
	DEFINE iRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cCmdSelect = '';
	LET cCmdFrom = '';
	LET cCmdWhere = '';
	LET cCmdCount='';
	LET cStatus = '';
	LET iRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_reporteenviodotaciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' OR pArchDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		IF pFechaInicio IS NULL THEN
			LET pFechaInicio = MDY(1, 1, 2007);
		END IF;
		
		IF pFechaFin IS NULL THEN
			LET pFechaFin = CURRENT;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pTipo = 'S' THEN
			LET cStatus = '01';
		ELIF pTipo = 'C' THEN
			LET cStatus = '12';
		END IF;
		
		-- SELECCION DE LOS ATRIBUTOS A PROYECTAR
		LET cCmdSelect = " SELECT TRIM(sucursal) AS sucursal, TRIM(caja_general) AS caja_general, TRIM(TO_CHAR(fecha, '%d/%m/%Y')) AS fecha, TRIM(desc_status) AS operacion, TRIM(folio_operacion) AS folio_operacion, TRIM(TO_CHAR(monto, '#,###,###,###,###,###,###,###,##&.&&')) AS monto, NVL(TRIM(id_usuario)||' '||trim(usuario), '') AS usuario, DECODE(status, 'T', 'ENVIO DOTACION', 'R', 'REVERSADO', '') AS operacion, DECODE(cod_retorno::INTEGER, 0, 'APLICADO', 'NO APLICADO') AS resultado_aplicacion, NVL(cod_retorno, '') AS cod_retorno, TRIM(NVL(mensaje, '')) AS mensaje";
		LET cCmdFrom = " FROM bdicnweb:'informix'.sw_cg_enviodotaciones_hist";
		LET cCmdWhere = " WHERE fecha between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
		
		IF pCodProveedor <> '' and pSucursal = '' THEN   -- POR PROVEEDOR
			LET cCmdWhere =""||TRIM(cCmdWhere)||" AND tpo_sucursal = '"||pTipo||"' AND cod_proveedor = '"||pCodProveedor||"' AND id_status = '"||cStatus||"'";
		ELIF pCodProveedor <> '' and pSucursal <> ''  THEN   -- POR SUCURSAL
			LET cCmdWhere =""||TRIM(cCmdWhere)||" AND id_sucursal = '"||pSucursal||"' AND id_status = '"||cStatus||"'";
		ELSE -- TODOS
			LET cCmdWhere =""||TRIM(cCmdWhere)||" AND tpo_sucursal = '"||pTipo||"' AND id_status = '"||cStatus||"'";
		END IF;
		
		LET cCmdCount = "SELECT COUNT(*)"||" "||TRIM(cCmdFrom)||" "||TRIM(cCmdWhere);
		
		PREPARE reporteQry FROM TRIM(cCmdCount);
		DECLARE reporteCur CURSOR FOR reporteQry;
		
		OPEN reporteCur;
		FETCH reporteCur INTO iRegistros;
		CLOSE reporteCur;
		FREE reporteCur;
		FREE reporteQry;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
		
		SYSTEM TRIM('/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||' '||TRIM(cCmdSelect)||' '||TRIM(cCmdFrom)||' '||TRIM(cCmdWhere)||' " | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1');
		
		-- SE COLOCA EL ENCABEZADO
		EXECUTE PROCEDURE bdicnweb:'informix'.sp_obtieneencabezadomasivo(pIdFuncion, pArchDescarga) INTO cCodRetSp;
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, '';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 11/02/2015',
'DESCRIPCION: Genera el reporte de las dotaciones enviadas',
'MODULO: Caja general',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_reversodotacionmasivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INTEGER, pIdPlantilla CHAR(25), pTituloPlantilla CHAR(255))
		RETURNING CHAR(5) AS codret,
				INTEGER AS registros_procesados;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegsProcesados INTEGER;
	DEFINE cFolioOperacion CHAR(8);
	DEFINE iIdRegistro INTEGER;
	DEFINE iNoRegsAfectados INTEGER;
	DEFINE cCodRetorno CHAR(5);
	DEFINE cMensaje CHAR(150);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCodRetSp CHAR(6);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRegsProcesados = 0;
	LET cFolioOperacion = '';
	LET iIdRegistro = 0;
	LET iNoRegsAfectados = 0;
	LET cCodRetorno = '';
	LET cMensaje = '';
	LET iCodRetSp = 0;
	LET cCodRetSp = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegsProcesados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_reversodotacionmasivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegsProcesados;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iRegsProcesados;
		END IF;
		
		FOREACH SELECT folio_operacion, id_registro
				INTO cFolioOperacion, iIdRegistro
				FROM bdicnweb:'informix'.sw_cg_enviodotaciones
				WHERE id_lote = pLote
					AND status = 'P'
					
			LET cCodRetorno = '00000';
			LET cMensaje = 'OPERACION EXITOSA';
			
			UPDATE bdisuc:'informix'.ss_operaciones
			SET reversado = '1'
			WHERE folio_oper = cFolioOperacion;
			
			LET iNoRegsAfectados = DBINFO('sqlca.sqlerrd2');
			
			IF iNoRegsAfectados = 0 THEN
				LET cCodRetorno = '00001';
				LET cMensaje = 'NO SE ENCONTRO EL FOLIO EN LA TABLA ss_operaciones';
			ELIF iNoRegsAfectados > 1 THEN
				LET cCodRetorno = '00000';
				LET cMensaje = 'SE ACTUALIZO MAS DE UN REGISTRO CON ESE FOLIO EN LA TABLA ss_operaciones';
			ELSE
				UPDATE bdisuc:'informix'.ss_mae_entradasalida
				SET hora_reversion = TO_CHAR(CURRENT, 'HH:mm'),
					fecha_reversion = CURRENT,
					usuario_reversion = pUsuario,
					status = '08'
				WHERE folio_oper = cFolioOperacion;
				
				LET iNoRegsAfectados = DBINFO('sqlca.sqlerrd2');
				IF iNoRegsAfectados = 0 THEN
					LET cCodRetorno = '00002';
					LET cMensaje = 'NO SE ENCONTRO EL FOLIO EN LA TABLA ss_mae_entradasalida';
				ELIF iNoRegsAfectados > 1 THEN
					LET cCodRetorno = '00000';
					LET cMensaje = 'SE ACTUALIZO MAS DE UN REGISTRO CON ESE FOLIO EN LA TABLA ss_mae_entradasalida';
				END IF;
				
			END IF;
			
			UPDATE bdicnweb:'informix'.sw_cg_enviodotaciones
			SET mensaje = cMensaje,
				fecha_proceso = CURRENT,
				cod_retorno = cCodRetorno
			WHERE id_registro = iIdRegistro;
			
			LET iRegsProcesados = iRegsProcesados + 1;
			
		END FOREACH;
		
		-- ACTUALIZACION DEL ESTATUS A REVERSADO
		UPDATE bdicnweb:'informix'.sw_cg_enviodotaciones
		SET status = 'R'
		WHERE id_lote = pLote
			AND fecha_proceso IS NOT NULL;
		
		-- SE MUEVE TODO EL LOTE AL HISTORICO
		INSERT INTO bdicnweb:'informix'.sw_cg_enviodotaciones_hist
		SELECT *
		FROM bdicnweb:'informix'.sw_cg_enviodotaciones
		WHERE id_lote = pLote
			AND fecha_proceso IS NOT NULL;
		
		DELETE FROM bdicnweb:'informix'.sw_cg_enviodotaciones
		WHERE id_lote = pLote;
		
		
		-- ENVIO DE LA INFORMACIÃN POR CORREO ELECTRONICO
		EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento(
																'1', 
																TRIM(pIdPlantilla), 
																TRIM(pIdPlantilla), 
																pUsuario, 
																'', 
																'', 
																'1', 
																'', 
																'', 
																'', 
																'', 
																'', 
																TRIM(pTituloPlantilla), 
																'ENVIO DE DOTACIONES CAJA GENERAL ', 
																'', 
																'', 
																'', 
																'', 
																'',
																'0', 
																'0', 
																'0', 
																'0', 
																'0', 
																CURRENT, 
																CURRENT) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet , iRegsProcesados;
					END IF;
		
		RETURN cCodRet, iRegsProcesados;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 11/02/2015',
'DESCRIPCION: Reversa las dotaciones solicitadas a enviar en un lote',
'MODULO: Caja general',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_validasaldoarqueosucucaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdPlaza CHAR(3), pIdSucursal CHAR(4), 
		pIdCajeroPrincArq CHAR(8), pFechaArq DATE)
		
		RETURNING CHAR(5) AS codret,
			MONEY(14,2) AS mTotalDiferencia;
			

		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE mSaldoTot MONEY(14,2); 
		DEFINE mMontoMin MONEY(14,2); 
		DEFINE mMontoMax MONEY(14,2);
		DEFINE mTotalDiferenciaArq MONEY(14,2);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET mSaldoTot = 0.00; 
		LET mMontoMin = 0.00; 
		LET mMontoMax = 0.00;
		LET mTotalDiferenciaArq = 0.00;
		LET iNoRegistros = 0;

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, mTotalDiferenciaArq;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_cg_validasaldoarqueosucucaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, mTotalDiferenciaArq;
            END IF;
                       
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, mTotalDiferenciaArq;
			END IF;
			
			-- VALIDA SALDO	
			FOREACH 
				SELECT sal.saldo_total, suc.mto_min_efect, suc.mto_max_efect INTO mSaldoTot, mMontoMin, mMontoMax
				FROM bdisuc:'informix'.ss_saldossuc sal INNER JOIN bdinteg:'informix'.si_sucursales suc 
				ON sal.cajero_principal = pIdCajeroPrincArq AND suc.sucursal = sal.sucursal
				AND suc.plaza_cajagen = (CASE WHEN pIdPlaza = '000' OR pIdPlaza = '' THEN suc.plaza_cajagen ELSE pIdPlaza END)
				AND	sal.fecha = (CASE WHEN pIdPlaza = '000' OR pIdPlaza = '' THEN sal.fecha ELSE pFechaArq END)
				AND sal.sucursal = (CASE WHEN pIdSucursal = '0000' OR pIdSucursal = '' THEN sal.sucursal ELSE pIdSucursal END)
				AND sal.fecha = (CASE WHEN pIdSucursal = '0000' OR pIdSucursal = '' THEN sal.fecha ELSE pFechaArq END)
			
				IF mSaldoTot IS NULL OR mMontoMin IS NULL OR mMontoMax IS NULL THEN
					LET cCodRet = '00430'; -- Los parÃ¡metros de las sucursales son incorrectos o no existen
					RETURN cCodRet, '';
				ELSE
					IF mSaldoTot < mMontoMin THEN
						LET mTotalDiferenciaArq = mMontoMin - mSaldoTot;
					ELSE 
						IF mSaldoTot > mMontoMax THEN
							LET mTotalDiferenciaArq = mMontoMax - mSaldoTot;
						ELSE
							LET mTotalDiferenciaArq = 0;
						END IF;
					END IF;
					
					LET iNoRegistros = iNoRegistros + 1;
					
				END IF;
			END FOREACH;
				
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, mTotalDiferenciaArq;
			END IF;
			
			RETURN cCodRet, mTotalDiferenciaArq;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 19/03/2015',
'DESCRIPCION: SPL que realiza la consulta para obtener la diferencia del saldo total.',
'MODULO: Caja General',
'FUNCIONALIDAD: Arqueo de Sucursales Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consmantolineasmasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pRegistros INT, pRecuperacion INT)
	RETURNING CHAR(5) AS codret,
			INT AS id,
			CHAR(20) AS no_credito,
			CHAR(15) AS resultado,
			CHAR(6) AS codretsp,
			CHAR(80) AS motivo_rechazo,
			CHAR(20) AS no_cliente,
			CHAR(107) AS nombre_cliente,
			MONEY(18,2) AS monto_linea_actual,
			MONEY(18,2) AS monto_nueva_linea,
			DATE AS fecha_movimiento, -- Fecha de proceso del registro
			CHAR(1) AS status;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdRegistro INTEGER;
	DEFINE cNoCuenta CHAR(20);
	DEFINE cResultado CHAR(15);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cMotivoRechazo CHAR(80);
	DEFINE cNoCliente CHAR(20);
	DEFINE cNombreCliente CHAR(107);
	DEFINE mMontoLineaActual MONEY(18,2);
	DEFINE mMontoNuevaLinea MONEY(18,2);
	DEFINE dFechaMovimiento DATE;
	DEFINE cStatusRegistro CHAR(1);
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdRegistro = 0;
	LET cNoCuenta = '';
	LET cResultado = '';
	LET cCodRetSp = '';
	LET cMotivoRechazo = '';
	LET cNoCliente = '';
	LET cNombreCliente = '';
	LET mMontoLineaActual = NULL;
	LET mMontoNuevaLinea = NULL;
	LET dFechaMovimiento = NULL;
	LET cStatusRegistro = '';
	LET iExiste = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdRegistro, cNoCuenta, cResultado, cCodRetSp, cMotivoRechazo, cNoCliente, cNombreCliente, 
					mMontoLineaActual, mMontoNuevaLinea, dFechaMovimiento, cStatusRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consmantolineasmasivocre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdRegistro, cNoCuenta, cResultado, cCodRetSp, cMotivoRechazo, cNoCliente, cNombreCliente, 
					mMontoLineaActual, mMontoNuevaLinea, dFechaMovimiento, cStatusRegistro;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdRegistro, cNoCuenta, cResultado, cCodRetSp, cMotivoRechazo, cNoCliente, cNombreCliente, 
					mMontoLineaActual, mMontoNuevaLinea, dFechaMovimiento, cStatusRegistro;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdRegistro, cNoCuenta, cResultado, cCodRetSp, cMotivoRechazo, cNoCliente, cNombreCliente, 
					mMontoLineaActual, mMontoNuevaLinea, dFechaMovimiento, cStatusRegistro;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iExiste
		FROM 
			(SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito
			WHERE lote = pLote
			UNION
			SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito_hist
			WHERE lote = pLote);
		
		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet, iIdRegistro, cNoCuenta, cResultado, cCodRetSp, cMotivoRechazo, cNoCliente, cNombreCliente, 
					mMontoLineaActual, mMontoNuevaLinea, dFechaMovimiento, cStatusRegistro;
		END IF;
		
		-- ACTUALIZACIÃN DEL ESTATUS POR VALIDACION
		UPDATE bdicnweb:sw_tr_cargamasiva_mantolineascredito
		SET resultado = 'NO APLICADO',
			motivo_rechazo = 'ERROR POR VALIDACION'
		WHERE lote = pLote AND status = 'E';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion id_registro, cuenta, resultado, codret_proceso, motivo_rechazo, numcte, nombre_cliente, monto_linea_actual, monto_linea_nuevo, fecha_proceso, status
			INTO iIdRegistro, cNoCuenta, cResultado, cCodRetSp, cMotivoRechazo, cNoCliente, cNombreCliente, 
					mMontoLineaActual, mMontoNuevaLinea, dFechaMovimiento, cStatusRegistro
			FROM (
				SELECT id_registro, cuenta, resultado, codret_proceso, motivo_rechazo, numcte, nombre_cliente, monto_linea_actual, monto_linea_nuevo, fecha_proceso, status
				FROM sw_tr_cargamasiva_mantolineascredito
				WHERE lote = pLote AND usuario = pUsuario
				UNION
				SELECT id_registro, cuenta, resultado, codret_proceso, motivo_rechazo, numcte, nombre_cliente, monto_linea_actual, monto_linea_nuevo, fecha_proceso, status
				FROM sw_tr_cargamasiva_mantolineascredito_hist
				WHERE lote = pLote AND usuario = pUsuario)
			ORDER BY id_registro
			
			IF cNoCliente IS NULL OR cNoCliente = '' THEN
				SELECT NVL(a.numcte, '')
				INTO cNoCliente
				FROM bdicred:sd_maecred a
				WHERE num_credito = cNoCuenta;
				
				IF cNoCliente IS NOT NULL OR TRIM(cNoCliente) <> '' THEN
					SELECT NVL(TRIM(TRIM(TRIM(b.nombre1)||' '||TRIM(b.nombre2))||' '||TRIM(TRIM(b.apell_paterno)||' '||TRIM(b.apell_materno))), '') as nombre
					INTO cNombreCliente
					FROM bdinteg:si_cliente b
					WHERE numcte = cNoCliente;
				END IF;
				
				UPDATE bdicnweb:'informix'.sw_tr_cargamasiva_mantolineascredito
				SET numcte = cNoCliente,
					nombre_cliente = cNombreCliente
				WHERE id_registro = iIdRegistro;
				
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					UPDATE bdicnweb:'informix'.sw_tr_cargamasiva_mantolineascredito_hist
					SET numcte = cNoCliente,
						nombre_cliente = cNombreCliente
					WHERE id_registro = iIdRegistro;
				END IF;
				
			END IF;
			
			-- Se obtiene el monto de la lÃ­nea actual
			IF NVL(mMontoLineaActual, 0) = 0 THEN 
				SELECT monto_otorgado
				INTO mMontoLineaActual
				FROM bdicred:'informix'.sd_maesdos
				WHERE num_credito = cNoCuenta;
				
				UPDATE bdicnweb:'informix'.sw_tr_cargamasiva_mantolineascredito
				SET monto_linea_actual = mMontoLineaActual
				WHERE id_registro = iIdRegistro;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					UPDATE bdicnweb:'informix'.sw_tr_cargamasiva_mantolineascredito_hist
					SET monto_linea_actual = mMontoLineaActual
					WHERE id_registro = iIdRegistro;
				END IF;
				
			END IF;
			
			RETURN cCodRet, iIdRegistro, cNoCuenta, cResultado, cCodRetSp, cMotivoRechazo, cNoCliente, cNombreCliente, 
					mMontoLineaActual, mMontoNuevaLinea, dFechaMovimiento, cStatusRegistro WITH RESUME;
				   
			LET iNoRegistros = iNoRegistros + 1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdRegistro, cNoCuenta, cResultado, cCodRetSp, cMotivoRechazo, cNoCliente, cNombreCliente, 
					mMontoLineaActual, mMontoNuevaLinea, dFechaMovimiento, cStatusRegistro;
		ELIF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdRegistro, cNoCuenta, cResultado, cCodRetSp, cMotivoRechazo, cNoCliente, cNombreCliente, 
					mMontoLineaActual, mMontoNuevaLinea, dFechaMovimiento, cStatusRegistro;
		END IF;
		
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 30/04/2014',
'DESCRIPCION: Consulta de los registros de un lote masivo de mantenimiento a lineas de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_constotalmantolineasmasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT)
	RETURNING CHAR(5) AS codret,
			INT AS numero_registros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iExiste = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_constotalmantolineasmasivocre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iExiste
		FROM 
			(SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito
			WHERE lote = pLote
			UNION
			SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito_hist
			WHERE lote = pLote);
		
		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT COUNT(id_registro)
		INTO iNoRegistros
		FROM (
			SELECT id_registro
			FROM sw_tr_cargamasiva_mantolineascredito
			WHERE lote = pLote AND usuario = pUsuario
			UNION
			SELECT id_registro
			FROM sw_tr_cargamasiva_mantolineascredito_hist
			WHERE lote = pLote AND usuario = pUsuario);
			
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
		
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 30/04/2014',
'DESCRIPCION: Consulta el total de los registros de un lote masivo de mantenimiento a lineas de credito',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadenominacionescaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdProvCaja CHAR(4))
		RETURNING CHAR(5) AS codret, 
			INTEGER AS disponible1,
			CHAR(18) AS denominacion1,
			INTEGER AS disponible2,			
			CHAR(18) AS denominacion2,
			INTEGER AS disponible3,
			CHAR(18) AS denominacion3, 
			INTEGER AS disponible4,
			CHAR(18) AS denominacion4,
			INTEGER AS disponible5,
			CHAR(18) AS denominacion5, 
			INTEGER AS disponible6,
			CHAR(18) AS denominacion6,
			INTEGER AS cant_totalmorralla,
			INTEGER AS disp_morralla,
			CHAR(10) AS den_morralla,
			MONEY(14,2) AS total_morralla,
			INTEGER AS disponible7,
			CHAR(18) AS denominacion7,
			INTEGER AS disponible8,
			CHAR(18) AS denominacion8,
			INTEGER AS disponible9,
			CHAR(18) AS denominacion9,
			INTEGER AS disponible10,
			CHAR(18) AS denominacion10,
			INTEGER AS disponible11,
			CHAR(18) AS denominacion11,
			INTEGER AS disponible12,
			CHAR(18) AS denominacion12,
			INTEGER AS disponible13,
			CHAR(18) AS denominacion13,
			INTEGER AS disponible14,
			CHAR(18) AS denominacion14,
			INTEGER AS disponible15,
			CHAR(18) AS denominacion15;	
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE mSaldoAnterior MONEY(14,2);
		DEFINE mSaldoTotal MONEY(14,2);
		DEFINE dDisponible1 INTEGER; 
		DEFINE cDenominacion1 CHAR(18); 
		DEFINE dDisponible2 INTEGER; 
		DEFINE cDenominacion2 CHAR(18);
		DEFINE dDisponible3 INTEGER; 
		DEFINE cDenominacion3 CHAR(18); 
		DEFINE dDisponible4 INTEGER; 
		DEFINE cDenominacion4 CHAR(18); 
		DEFINE dDisponible5 INTEGER; 
		DEFINE cDenominacion5 CHAR(18); 
		DEFINE dDisponible6 INTEGER; 		
		DEFINE cDenominacion6 CHAR(18);
		DEFINE dDisponible7 INTEGER; 
		DEFINE cDenominacion7 CHAR(18);  
		DEFINE dDisponible8 INTEGER; 
		DEFINE cDenominacion8 CHAR(18); 
		DEFINE dDisponible9 INTEGER; 
		DEFINE cDenominacion9 CHAR(18); 
		DEFINE dDisponible10 INTEGER; 
		DEFINE cDenominacion10 CHAR(18);
		DEFINE dDisponible11 INTEGER; 
		DEFINE cDenominacion11 CHAR(18);
		DEFINE dDisponible12 INTEGER; 
		DEFINE cDenominacion12 CHAR(18);
		DEFINE dDisponible13 INTEGER; 
		DEFINE cDenominacion13 CHAR(18);
		DEFINE dDisponible14 INTEGER; 
		DEFINE cDenominacion14 CHAR(18); 
		DEFINE dDisponible15 INTEGER; 
		DEFINE cDenominacion15 CHAR(18);		
		DEFINE iCantTotalmorralla INTEGER;
		DEFINE dDispMorralla INTEGER;
		DEFINE cDenMorralla CHAR(10);
		DEFINE mTotalMorralla MONEY(14,2);	
        DEFINE iNoRegistros INTEGER; 
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET mSaldoAnterior = NULL;
		LET mSaldoTotal = NULL;
		LET dDisponible1 = 0; 
		LET cDenominacion1 = '';
		LET dDisponible2 = 0; 
		LET cDenominacion2 = '';
		LET dDisponible3 = 0; 
		LET cDenominacion3 = ''; 
		LET dDisponible4 = 0; 
		LET cDenominacion4 = '';
		LET dDisponible5 = 0; 
		LET cDenominacion5 = '';  
		LET dDisponible6 = 0; 
		LET cDenominacion6 = '';  
		LET dDisponible7 = 0; 
		LET cDenominacion7 = '';  
		LET dDisponible8 = 0; 
		LET cDenominacion8 = '';
		LET dDisponible9 = 0; 
		LET cDenominacion9 = '';
		LET dDisponible10 = 0; 
		LET cDenominacion10 = '';
		LET dDisponible11 = 0; 
		LET cDenominacion11 = '';
		LET dDisponible12 = 0; 
		LET cDenominacion12 = '';
		LET dDisponible13 = 0; 
		LET cDenominacion13 = '';
		LET dDisponible14 = 0; 		
		LET cDenominacion14 = ''; 
		LET dDisponible15 = 0; 
		LET cDenominacion15 = '';		
		LET iCantTotalmorralla = 1;
		LET dDispMorralla = 0;
		LET cDenMorralla = 'MORRALLA';
		LET mTotalMorralla = NULL;	
        LET iNoRegistros = 0; 
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, dDisponible1, cDenominacion1, dDisponible2, cDenominacion2, dDisponible3, cDenominacion3, dDisponible4, cDenominacion4, dDisponible5, cDenominacion5, 
				dDisponible6, cDenominacion6, iCantTotalmorralla, dDispMorralla, cDenMorralla, mTotalMorralla, dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, 
				dDisponible11, cDenominacion11, dDisponible12, cDenominacion12, dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultadenominacionescaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pIdProvCaja = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dDisponible1, cDenominacion1, dDisponible2, cDenominacion2, dDisponible3, cDenominacion3, dDisponible4, cDenominacion4, dDisponible5, cDenominacion5, 
				dDisponible6, cDenominacion6, iCantTotalmorralla, dDispMorralla, cDenMorralla, mTotalMorralla, dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, 
				dDisponible11, cDenominacion11, dDisponible12, cDenominacion12, dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dDisponible1, cDenominacion1, dDisponible2, cDenominacion2, dDisponible3, cDenominacion3, dDisponible4, cDenominacion4, dDisponible5, cDenominacion5, 
				dDisponible6, cDenominacion6, iCantTotalmorralla, dDispMorralla, cDenMorralla, mTotalMorralla, dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, 
				dDisponible11, cDenominacion11, dDisponible12, cDenominacion12, dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
			END IF;
			
			--SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;
			
			-- VALIDA NÃMERO DE CAJA GENERAL
			IF NOT EXISTS(SELECT * FROM bdisuc:'informix'.ss_cajageneral WHERE cod_proveedor = pIdProvCaja) THEN
				LET cCodRet = '90000'; -- La caja general nÃºmero ËnumeroË no existe. Por favor verifique 
				RETURN cCodRet, dDisponible1, cDenominacion1, dDisponible2, cDenominacion2, dDisponible3, cDenominacion3, dDisponible4, cDenominacion4, dDisponible5, cDenominacion5, 
				dDisponible6, cDenominacion6, iCantTotalmorralla, dDispMorralla, cDenMorralla, mTotalMorralla, dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, 
				dDisponible11, cDenominacion11, dDisponible12, cDenominacion12, dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
			END IF;
			
			-- VALIDA EFECTIVO DE CAJA GENERAL
			SELECT saldo_total, saldo_anterior INTO mSaldoTotal, mSaldoAnterior
			FROM bdisuc:'informix'.ss_cajageneral WHERE cod_proveedor = pIdProvCaja;	
			
			IF mSaldoTotal IS NULL THEN 
				LET mSaldoTotal = 0;
			END IF;
			IF mSaldoAnterior IS NULL THEN 
				LET mSaldoAnterior = 0; 
			END IF;
			
			IF (mSaldoTotal + mSaldoAnterior = 0) THEN
				LET cCodRet = '00423'; -- La caja no tiene efectivo. Por favor verifique 
				RETURN cCodRet, dDisponible1, cDenominacion1, dDisponible2, cDenominacion2, dDisponible3, cDenominacion3, dDisponible4, cDenominacion4, dDisponible5, cDenominacion5, 
				dDisponible6, cDenominacion6, iCantTotalmorralla, dDispMorralla, cDenMorralla, mTotalMorralla, dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, 
				dDisponible11, cDenominacion11, dDisponible12, cDenominacion12, dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
			END IF;
			
			-- CONSULTA DE PÃNELES
			FOREACH			
				SELECT cantidad_1, denominacion_1, 
					   cantidad_2, denominacion_2, 
					   cantidad_3, denominacion_3, 
					   cantidad_4, denominacion_4, 
					   cantidad_5, denominacion_5, 
					   cantidad_6, denominacion_6, 	
					   cantidad_7, denominacion_7, 
					   cantidad_8, denominacion_8, 
					   cantidad_9, denominacion_9, 
					   cantidad_10, denominacion_10,
					   cantidad_11, denominacion_11,
					   cantidad_12, denominacion_12,
					   cantidad_13, denominacion_13,
					   cantidad_14, denominacion_14,
					   cantidad_15, denominacion_15,
					  (NVL(cantidad_7,0) + NVL(cantidad_8,0) + NVL(cantidad_9,0) + NVL(cantidad_10,0) + NVL(cantidad_11,0) +
					    NVL(cantidad_12,0) + NVL(cantidad_12,0) + NVL(cantidad_13,0) + NVL(cantidad_14,0) + NVL(cantidad_15,0)
					   ) AS disponible_morralla
					 
				INTO dDisponible1, cDenominacion1, 
					 dDisponible2, cDenominacion2, 
					 dDisponible3, cDenominacion3, 
					 dDisponible4, cDenominacion4, 
					 dDisponible5, cDenominacion5, 
					 dDisponible6, cDenominacion6, 
					 dDisponible7, cDenominacion7, 
					 dDisponible8, cDenominacion8, 
					 dDisponible9, cDenominacion9, 
					 dDisponible10, cDenominacion10, 
					 dDisponible11, cDenominacion11, 
					 dDisponible12, cDenominacion12, 
					 dDisponible13, cDenominacion13, 
					 dDisponible14, cDenominacion14, 
					 dDisponible15, cDenominacion15, 
					 dDispMorralla
								
				FROM bdisuc:'informix'.ss_cajageneral WHERE cod_proveedor = pIdProvCaja
				
				RETURN cCodRet, dDisponible1, cDenominacion1, dDisponible2, cDenominacion2, dDisponible3, cDenominacion3, dDisponible4, cDenominacion4, dDisponible5, cDenominacion5, 
				dDisponible6, cDenominacion6, iCantTotalmorralla, dDispMorralla, cDenMorralla, mTotalMorralla, dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, 
				dDisponible11, cDenominacion11, dDisponible12, cDenominacion12, dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15 WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;			
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dDisponible1, cDenominacion1, dDisponible2, cDenominacion2, dDisponible3, cDenominacion3, dDisponible4, cDenominacion4, dDisponible5, cDenominacion5, 
				dDisponible6, cDenominacion6, iCantTotalmorralla, dDispMorralla, cDenMorralla, mTotalMorralla, dDisponible7, cDenominacion7, dDisponible8, cDenominacion8, dDisponible9, cDenominacion9, dDisponible10, cDenominacion10, 
				dDisponible11, cDenominacion11, dDisponible12, cDenominacion12, dDisponible13, cDenominacion13, dDisponible14, cDenominacion14, dDisponible15, cDenominacion15;
			END IF;

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/01/2015',
'DESCRIPCION: SPL que realiza la consulta de la cantidad y las denominaciones de la tabla ss_cajageneral, Cambio Billetes Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadetallecatalogocaja(pUsuario CHAR(8), pIdFuncion CHAR(10))
					
		RETURNING CHAR(5) AS codret,
			CHAR(4) AS cod_proveedor,
			CHAR(30) AS desc_proveedor,
			CHAR(2) AS id_divisa,
			CHAR(30) AS desc_divisa,
			CHAR(3) AS id_plaza,
			CHAR(40) AS desc_plaza;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		DEFINE cCodProveedor CHAR(4);
		DEFINE cDescProveedor CHAR(30);
		DEFINE cIdDivisa CHAR(2);
		DEFINE cDescDivisa CHAR(30);
		DEFINE cIdPlaza CHAR(3);
		DEFINE cDescPlaza CHAR(40);
		DEFINE cEmpresa CHAR(3);
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		LET cCodProveedor = '';
		LET cDescProveedor = '';
		LET cIdDivisa = '';
		LET cDescDivisa = '';
		LET cIdPlaza = '';
		LET cDescPlaza = '';
		LET cEmpresa = '001';
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, cCodProveedor, cDescProveedor, cIdDivisa, cDescDivisa, cIdPlaza, cDescPlaza;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetallecatalogocaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCodProveedor, cDescProveedor, cIdDivisa, cDescDivisa, cIdPlaza, cDescPlaza;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cCodProveedor, cDescProveedor, cIdDivisa, cDescDivisa, cIdPlaza, cDescPlaza; 
			END IF;
			
			SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;
		 
			FOREACH
				SELECT cod_proveedor, divisa INTO cCodProveedor, cIdDivisa
				FROM bdisuc:'informix'.ss_cajageneral ORDER BY cod_proveedor
				
				SELECT descripcion, plaza INTO cDescProveedor, cIdPlaza
				FROM bdisuc:'informix'.ss_proveedores WHERE cod_proveedor = cCodProveedor;
			
				SELECT descripcion INTO cDescDivisa
				FROM bdinteg:'informix'.si_divisas WHERE divisa = cIdDivisa;
			
				SELECT descripcion INTO cDescPlaza
				FROM bdinteg:'informix'.si_plazas_cajagen WHERE codigo_plaza = cIdPlaza;
			
				RETURN cCodRet, cCodProveedor, UPPER(cDescProveedor), cIdDivisa, UPPER(cDescDivisa), cIdPlaza, UPPER(cDescPlaza) WITH RESUME;
				LET iRecuperacion = iRecuperacion + 1;
			END FOREACH;

			IF iRecuperacion = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cCodProveedor, cDescProveedor, cIdDivisa, cDescDivisa, cIdPlaza, cDescPlaza;
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/03/2015',
'DESCRIPCION: SPL que hace la consulta a la tabla ss_cajageneral para obtener codigo proveedor, descripciÃ³n, divisa y plaza.',
'FUNCIONALIDAD: Mantenimiento CatÃ¡logo Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadetalledotacioncaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFolioOperacion CHAR(8), pCodTrans CHAR(4), pStatus CHAR(2))
		RETURNING CHAR(5) AS codret,
			DECIMAL(10,2) AS fCant1, 
			CHAR(18) AS cDenominacion1, 
			MONEY(14,2) AS mTotal1, 
			DECIMAL(10,2) AS fCant2, 
			CHAR(18) AS cDenominacion2,
			MONEY(14,2) AS mTotal2,
			DECIMAL(10,2) AS fCant3,
			CHAR(18) AS cDenominacion3, 
			MONEY(14,2) AS mTotal3,
			DECIMAL(10,2) AS fCant4, 
			CHAR(18) AS cDenominacion4, 
			MONEY(14,2) AS mTotal4,
			DECIMAL(10,2) AS fCant5,
			CHAR(18) AS cDenominacion5,
			MONEY(14,2) AS mTotal5,
			DECIMAL(10,2) AS fCant6, 
			CHAR(18) AS cDenominacion6,
			MONEY(14,2) AS mTotal6,
			CHAR(2) AS cDenMorralla,
			MONEY(14,2) AS mTotalMorralla, 
			MONEY(14,2) AS mTotalDotSolicitada,
			DECIMAL(10,2) AS fCantEnv_1, 
			CHAR(18) AS cDenEnv_1,
			DECIMAL(10,2) AS fCantEnv_2, 
			CHAR(18) AS cDenEnv_2,
			DECIMAL(10,2) AS fCantEnv_3, 
			CHAR(18) AS cDenEnv_3,
			DECIMAL(10,2) AS fCantEnv_4, 
			CHAR(18) AS cDenEnv_4,
			DECIMAL(10,2) AS fCantEnv_5, 
			CHAR(18) AS cDenEnv_5,
			DECIMAL(10,2) AS fCantEnv_6, 
			CHAR(18) AS cDenEnv_6,
			MONEY(14,2) AS mTotalMorrallaEnv,
			CHAR(8) AS cDenMorrallaEnv,
			MONEY(14,2) AS mSaldoDisponible;
			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE fCant1 DECIMAL(10,2); 
	DEFINE cDenominacion1 CHAR(18); 
	DEFINE mTotal1 MONEY(14,2);
	DEFINE fCant2 DECIMAL(10,2); 
	DEFINE cDenominacion2 CHAR(18);
	DEFINE mTotal2 MONEY(14,2);
	DEFINE fCant3 DECIMAL(10,2); 
	DEFINE cDenominacion3 CHAR(18); 
	DEFINE mTotal3 MONEY(14,2);
	DEFINE fCant4 DECIMAL(10,2); 
	DEFINE cDenominacion4 CHAR(18);
	DEFINE mTotal4 MONEY(14,2);
	DEFINE fCant5 DECIMAL(10,2); 
	DEFINE cDenominacion5 CHAR(18); 
	DEFINE mTotal5 MONEY(14,2);
	DEFINE fCant6 DECIMAL(10,2); 
	DEFINE cDenominacion6 CHAR(18); 
	DEFINE mTotal6 MONEY(14,2);
	DEFINE fCant7 DECIMAL(10,2); 
	DEFINE cDenominacion7 CHAR(18); 
	DEFINE mTotal7 MONEY(14,2);
	DEFINE fCant8 DECIMAL(10,2); 
	DEFINE cDenominacion8 CHAR(18);
	DEFINE mTotal8 MONEY(14,2);	
	DEFINE fCant9 DECIMAL(10,2); 
	DEFINE cDenominacion9 CHAR(18);
	DEFINE mTotal9 MONEY(14,2);
	DEFINE fCant10 DECIMAL(10,2); 
	DEFINE cDenominacion10 CHAR(18);
	DEFINE mTotal10 MONEY(14,2);
	DEFINE fCant11 DECIMAL(10,2); 
	DEFINE cDenominacion11 CHAR(18);
	DEFINE mTotal11 MONEY(14,2);
	DEFINE fCant12 DECIMAL(10,2); 
	DEFINE cDenominacion12 CHAR(18);
	DEFINE mTotal12 MONEY(14,2);
	DEFINE fCant13 DECIMAL(10,2); 
	DEFINE cDenominacion13 CHAR(18);
	DEFINE mTotal13 MONEY(14,2);
	DEFINE fCant14 DECIMAL(10,2); 
	DEFINE cDenominacion14 CHAR(18);
	DEFINE mTotal14 MONEY(14,2);
	DEFINE fCant15 DECIMAL(10,2); 
	DEFINE cDenominacion15 CHAR(18);
	DEFINE mTotal15 MONEY(14,2);
	DEFINE cDenMorralla CHAR(2);	      
	DEFINE mTotalMorralla MONEY(14,2); 
	DEFINE mTotalDotSolicitada MONEY(14,2);
	DEFINE fCantEnv_1 DECIMAL(10,2); 
	DEFINE cDenEnv_1 CHAR(18);
	DEFINE fCantEnv_2 DECIMAL(10,2); 
	DEFINE cDenEnv_2 CHAR(18);
	DEFINE fCantEnv_3 DECIMAL(10,2); 
	DEFINE cDenEnv_3 CHAR(18);
	DEFINE fCantEnv_4 DECIMAL(10,2); 
	DEFINE cDenEnv_4 CHAR(18);
	DEFINE fCantEnv_5 DECIMAL(10,2); 
	DEFINE cDenEnv_5 CHAR(18);
	DEFINE fCantEnv_6 DECIMAL(10,2); 
	DEFINE cDenEnv_6 CHAR(18);
	DEFINE mTotalMorrallaEnv MONEY(14,2);
	DEFINE cDenMorrallaEnv CHAR(8);
	DEFINE mSaldoDisponible MONEY(14,2);
	
	DEFINE cCodTrans CHAR(4);
	DEFINE cReversado CHAR(1);
	DEFINE cUsuario CHAR(8);
	DEFINE cCodProvedor CHAR(4);
	DEFINE cStatus CHAR(2);
	DEFINE dFechReversion DATE;
	DEFINE dHoReversion CHAR(5);
	DEFINE cUsReversion CHAR(8);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET fCant1 = 0.00; 
	LET cDenominacion1 = ''; 
	LET mTotal1 = NULL;
	LET fCant2 = 0.00; 
	LET cDenominacion2 = ''; 
	LET mTotal2 = NULL;
	LET fCant3 = 0.00; 
	LET cDenominacion3 = '';
	LET mTotal3 = NULL;
	LET fCant4 = 0.00; 
	LET cDenominacion4 = '';
	LET mTotal4 = NULL;
	LET fCant5 = 0.00; 
	LET cDenominacion5 = '';
	LET mTotal5 = NULL;
	LET fCant6 = 0.00; 
	LET cDenominacion6 = ''; 
	LET mTotal6 = NULL; 
	LET fCant7 = 0.00; 
	LET cDenominacion7 = ''; 
	LET mTotal7 = NULL;
	LET fCant8 = 0.00; 
	LET cDenominacion8 = ''; 
	LET mTotal8 = NULL;
	LET fCant9 = 0.00; 
	LET cDenominacion9 = '';
	LET mTotal9 = NULL;
	LET fCant10 = 0.00; 
	LET cDenominacion10 = '';
	LET mTotal10 = NULL;
	LET fCant11 = 0.00; 
	LET cDenominacion11 = '';
	LET mTotal11 = NULL;
	LET fCant12 = 0.00; 
	LET cDenominacion12 = '';
	LET mTotal12 = NULL;
	LET fCant13 = 0.00; 
	LET cDenominacion13 = '';
	LET mTotal13 = NULL;
	LET fCant14 = 0.00; 
	LET cDenominacion14 = '';
	LET mTotal14 = NULL;
	LET fCant15 = 0.00; 
	LET cDenominacion15 = '';
	LET mTotal15 = NULL;
	LET cDenMorralla = '1';  			
	LET mTotalMorralla = NULL;  
	LET mTotalDotSolicitada = NULL;
	LET fCantEnv_1 = 0.00; 
	LET cDenEnv_1 = '';
	LET fCantEnv_2 = 0.00; 
	LET cDenEnv_2 = '';
	LET fCantEnv_3 = 0.00; 
	LET cDenEnv_3 = '';
	LET fCantEnv_4 = 0.00; 
	LET cDenEnv_4 = '';
	LET fCantEnv_5 = 0.00; 
	LET cDenEnv_5 = '';
	LET fCantEnv_6 = 0.00; 
	LET cDenEnv_6 = '';
	LET mTotalMorrallaEnv = NULL;
	LET cDenMorrallaEnv = 'MORRALLA';
	LET mSaldoDisponible = NULL;
	
	LET cCodTrans = '';
	LET cReversado = '';
	LET cUsuario = '';
	LET cCodProvedor = '';
	LET cStatus = '';
	LET dFechReversion = '';
	LET dHoReversion = '';
	LET cUsReversion = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr; 
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, 
				   fCant5, cDenominacion5, mTotal5, fCant6, cDenominacion6, mTotal6, cDenMorralla, mTotalMorralla, mTotalDotSolicitada,
				   fCantEnv_1, cDenEnv_1, fCantEnv_2, cDenEnv_2, fCantEnv_3, cDenEnv_3, fCantEnv_4, cDenEnv_4, fCantEnv_5, cDenEnv_5, fCantEnv_6, cDenEnv_6, 
				   mTotalMorrallaEnv, cDenMorrallaEnv, mSaldoDisponible;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetalledotacioncaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFolioOperacion = '' OR pCodTrans = '' OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, 
				   fCant5, cDenominacion5, mTotal5, fCant6, cDenominacion6, mTotal6, cDenMorralla, mTotalMorralla, mTotalDotSolicitada,
				   fCantEnv_1, cDenEnv_1, fCantEnv_2, cDenEnv_2, fCantEnv_3, cDenEnv_3, fCantEnv_4, cDenEnv_4, fCantEnv_5, cDenEnv_5, fCantEnv_6, cDenEnv_6, 
				   mTotalMorrallaEnv, cDenMorrallaEnv, mSaldoDisponible; 
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, 
				   fCant5, cDenominacion5, mTotal5, fCant6, cDenominacion6, mTotal6, cDenMorralla, mTotalMorralla, mTotalDotSolicitada,
				   fCantEnv_1, cDenEnv_1, fCantEnv_2, cDenEnv_2, fCantEnv_3, cDenEnv_3, fCantEnv_4, cDenEnv_4, fCantEnv_5, cDenEnv_5, fCantEnv_6, cDenEnv_6, 
				   mTotalMorrallaEnv, cDenMorrallaEnv, mSaldoDisponible; 
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF ((pCodTrans = '0001' AND pStatus = '01') OR (pCodTrans = '0010' AND pStatus = '01') OR (pCodTrans = '0036' AND pStatus = '12')) THEN
			
			-- Valida Folio OperaciÃ³n
			IF NOT EXISTS (SELECT * FROM bdisuc:'informix'.ss_operaciones WHERE folio_oper = pFolioOperacion) THEN
						   LET cCodRet = '00427'; -- El folio de operaciÃ³n no existe. Por favor verifique
						   RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, 
								  fCant5, cDenominacion5, mTotal5, fCant6, cDenominacion6, mTotal6, cDenMorralla, mTotalMorralla, mTotalDotSolicitada,
								  fCantEnv_1, cDenEnv_1, fCantEnv_2, cDenEnv_2, fCantEnv_3, cDenEnv_3, fCantEnv_4, cDenEnv_4, fCantEnv_5, cDenEnv_5, fCantEnv_6, cDenEnv_6, 
								  mTotalMorrallaEnv, cDenMorrallaEnv, mSaldoDisponible;
			END IF;

			-- DotaciÃ³n Solicitada 	
			SELECT cod_trans, reversado, usuario, monto,
				   NVL(cantidad_1,0), NVL(denominacion_1,''), NVL((cantidad_1 * denominacion_1::INTEGER),0) AS total_1,
				   NVL(cantidad_2,0), NVL(denominacion_2,''), NVL((cantidad_2 * denominacion_2::INTEGER),0) AS total_2,
				   NVL(cantidad_3,0), NVL(denominacion_3,''), NVL((cantidad_3 * denominacion_3::INTEGER),0) AS total_3,
				   NVL(cantidad_4,0), NVL(denominacion_4,''), NVL((cantidad_4 * denominacion_4::INTEGER),0) AS total_4,
				   NVL(cantidad_5,0), NVL(denominacion_5,''), NVL((cantidad_5 * denominacion_5::INTEGER),0) AS total_5,
				   NVL(cantidad_6,0), NVL(denominacion_6,''), NVL((cantidad_6 * denominacion_6::INTEGER),0) AS total_6,			
				   
				  (NVL(cantidad_7,0) + NVL((cantidad_8 * denominacion_8::INTEGER),0) + NVL((cantidad_9 * denominacion_9::INTEGER),0) +
				   NVL((cantidad_10 * denominacion_10::INTEGER),0) + NVL((cantidad_11 * denominacion_11::INTEGER),0) + NVL((cantidad_12 * denominacion_12::INTEGER),0) +
				   NVL((cantidad_13 * denominacion_13::INTEGER),0) + NVL((cantidad_14 * denominacion_14::INTEGER),0) + NVL((cantidad_15 * denominacion_15::INTEGER),0)
				   ) AS suma_totalMorralla 
			
		    INTO cCodTrans, cReversado, cUsuario, mTotalDotSolicitada,
		 		fCant1, cDenominacion1, mTotal1,
		 		fCant2, cDenominacion2, mTotal2,
		 		fCant3, cDenominacion3, mTotal3,
		 		fCant4, cDenominacion4, mTotal4,
		 		fCant5, cDenominacion5, mTotal5,
		 		fCant6, cDenominacion6, mTotal6,  
		 		mTotalMorralla

			FROM bdisuc:'informix'.ss_operaciones WHERE folio_oper = pFolioOperacion;
			
			SET LOCK MODE TO WAIT 3;
			-- Obtiene Codigo Proveedor
			SELECT cod_proveedor, status, fecha_reversion, hora_reversion, usuario_reversion
			INTO cCodProvedor, cStatus, dFechReversion, dHoReversion, cUsReversion
			FROM bdisuc:'informix'.ss_mae_entradasalida WHERE folio_oper = pFolioOperacion;
			
			SET LOCK MODE TO WAIT 3;
			
			-- DotaciÃ³n Enviada
			SELECT saldo_total,
				   NVL(cantidad_1,0), NVL(denominacion_1,''), 
				   NVL(cantidad_2,0), NVL(denominacion_2,''), 
				   NVL(cantidad_3,0), NVL(denominacion_3,''), 
				   NVL(cantidad_4,0), NVL(denominacion_4,''), 
				   NVL(cantidad_5,0), NVL(denominacion_5,''), 
				   NVL(cantidad_6,0), NVL(denominacion_6,''), 			
				   
				   (NVL(cantidad_7,0) + NVL((cantidad_8 * denominacion_8::INTEGER),0) + NVL((cantidad_9 * denominacion_9::INTEGER),0) +
					NVL((cantidad_10 * denominacion_10::INTEGER),0) + NVL((cantidad_11 * denominacion_11::INTEGER),0) + NVL((cantidad_12 * denominacion_12::INTEGER),0) +
					NVL((cantidad_13 * denominacion_13::INTEGER),0) + NVL((cantidad_14 * denominacion_14::INTEGER),0) + NVL((cantidad_15 * denominacion_15::INTEGER),0)
				    ) AS suma_totalMorrallaEnv 
			
			INTO mSaldoDisponible,
				 fCantEnv_1, cDenEnv_1, 
				 fCantEnv_2, cDenEnv_2, 
				 fCantEnv_3, cDenEnv_3, 
				 fCantEnv_4, cDenEnv_4, 
				 fCantEnv_5, cDenEnv_5, 
				 fCantEnv_6, cDenEnv_6,  
				 mTotalMorrallaEnv
				   
			FROM bdisuc:ss_cajageneral WHERE cod_proveedor = cCodProvedor;
			
			-- Valida DotaciÃ³n Solicitada
			IF mTotalDotSolicitada > mSaldoDisponible THEN
				LET cCodRet = '90000'; -- La DotaciÃ³n solicitada <folio operaciÃ³n> es mayor al saldo disponible en caja. Por favor verifique.
				RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
					   '', '', '', '', '', '', '', '', '', '', '', '', '', '', '';
			ELSE
				RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, 
					   fCant5, cDenominacion5, mTotal5, fCant6, cDenominacion6, mTotal6, cDenMorralla, mTotalMorralla, mTotalDotSolicitada,
					   fCantEnv_1, cDenEnv_1, fCantEnv_2, cDenEnv_2, fCantEnv_3, cDenEnv_3, fCantEnv_4, cDenEnv_4, fCantEnv_5, cDenEnv_5, fCantEnv_6, cDenEnv_6, 
					   mTotalMorrallaEnv, cDenMorrallaEnv, mSaldoDisponible;
					   
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
			
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, 
				   fCant5, cDenominacion5, mTotal5, fCant6, cDenominacion6, mTotal6, cDenMorralla, mTotalMorralla, mTotalDotSolicitada,
				   fCantEnv_1, cDenEnv_1, fCantEnv_2, cDenEnv_2, fCantEnv_3, cDenEnv_3, fCantEnv_4, cDenEnv_4, fCantEnv_5, cDenEnv_5, fCantEnv_6, cDenEnv_6, 
				   mTotalMorrallaEnv, cDenMorrallaEnv, mSaldoDisponible;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 05/02/2015',
'DESCRIPCION: SPL, que hace la consulta para el llenado de la pantalla modal Detalle DotaciÃ³n, EnvÃ­o Dotaciones Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultadetallemonitorefectivocaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodProveedor CHAR(4))
					
		RETURNING CHAR(5) AS codret, 
			CHAR(18) AS cDenominacion_1,
			CHAR(18) AS cDenominacion_2,
			CHAR(18) AS cDenominacion_3,
			CHAR(18) AS cDenominacion_4,
			CHAR(18) AS cDenominacion_5,
			CHAR(18) AS cDenominacion_6,
			CHAR(8) AS cDenMorralla,
			MONEY(14,2) AS dCantidad_1,     
			MONEY(14,2) AS dCantidad_2,     
			MONEY(14,2) AS dCantidad_3,     
			MONEY(14,2) AS dCantidad_4,     
			MONEY(14,2) AS dCantidad_5,     
			MONEY(14,2) AS dCantidad_6,     
			MONEY(14,2) AS dCantMorralla,   
			MONEY(14,2) AS mMontoTotal1,
			MONEY(14,2) AS mMontoTotal2,
			MONEY(14,2) AS mMontoTotal3,
			MONEY(14,2) AS mMontoTotal4,
			MONEY(14,2) AS mMontoTotal5,
			MONEY(14,2) AS mMontoTotal6,
			MONEY(14,2) AS mTotal;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE cCodProveedor CHAR(4);
		DEFINE cDescProveedor CHAR(30);
		DEFINE cPlaza CHAR(3);
		DEFINE cDescPlaza CHAR(40);
		DEFINE mSaldoAnterior MONEY(14);
		DEFINE mSaldoTotal MONEY(14);
		DEFINE mSaldoAsignado MONEY(14);
		DEFINE mTotalBillDet FLOAT(8);
		DEFINE mSaldoDisponible FLOAT(8);
		DEFINE cDivisa CHAR(2);
		DEFINE cDescDivisa CHAR(30);
		DEFINE cDenominacion_1 CHAR(18);
		DEFINE cDenominacion_2 CHAR(18);
		DEFINE cDenominacion_3 CHAR(18);
		DEFINE cDenominacion_4 CHAR(18);
		DEFINE cDenominacion_5 CHAR(18);
		DEFINE cDenominacion_6 CHAR(18);
		DEFINE cDenominacion_7 CHAR(18);
		DEFINE cDenominacion_8 CHAR(18);
		DEFINE cDenominacion_9 CHAR(18);
		DEFINE cDenominacion_10 CHAR(18);
		DEFINE cDenominacion_11 CHAR(18);
		DEFINE cDenominacion_12 CHAR(18);
		DEFINE cDenominacion_13 CHAR(18);
		DEFINE cDenominacion_14 CHAR(18);
		DEFINE cDenominacion_15 CHAR(18);
		DEFINE cDenMorralla CHAR(8);
		DEFINE dCantidad_1 MONEY(14,2);
		DEFINE dCantidad_2 MONEY(14,2);
		DEFINE dCantidad_3 MONEY(14,2);
		DEFINE dCantidad_4 MONEY(14,2);
		DEFINE dCantidad_5 MONEY(14,2);
		DEFINE dCantidad_6 MONEY(14,2);
		DEFINE dCantidad_7 MONEY(14,2);
		DEFINE dCantidad_8 MONEY(14,2);
		DEFINE dCantidad_9 MONEY(14,2);
		DEFINE dCantidad_10 MONEY(14,2);
		DEFINE dCantidad_11 MONEY(14,2);
		DEFINE dCantidad_12 MONEY(14,2);
		DEFINE dCantidad_13 MONEY(14,2);
		DEFINE dCantidad_14 MONEY(14,2);
		DEFINE dCantidad_15 MONEY(14,2);
		DEFINE dCantMorralla MONEY(14,2);
		DEFINE mMontoTotal1 MONEY(14,2);
		DEFINE mMontoTotal2 MONEY(14,2);
		DEFINE mMontoTotal3 MONEY(14,2);
		DEFINE mMontoTotal4 MONEY(14,2);
		DEFINE mMontoTotal5 MONEY(14,2);
		DEFINE mMontoTotal6 MONEY(14,2);
		DEFINE mTotal MONEY(14,2);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        	LET cCodRetSp = '';
		LET iCodRetSp = 0;
        	LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET cCodProveedor = '';
		LET cDescProveedor = '';
		LET cPlaza = '';
		LET cDescPlaza = '';
		LET mSaldoAnterior = NULL;
		LET mSaldoTotal = NULL;
		LET mSaldoAsignado = NULL;
		LET mTotalBillDet = 0;
		LET mSaldoDisponible = 0;
		LET cDivisa = '';
		LET cDescDivisa = '';
		LET cDenominacion_1 = '';
		LET cDenominacion_2 = '';
		LET cDenominacion_3 = '';
		LET cDenominacion_4 = '';
		LET cDenominacion_5 = '';
		LET cDenominacion_6 = '';
		LET cDenominacion_7 = '';
		LET cDenominacion_8 = '';
		LET cDenominacion_9 = '';
		LET cDenominacion_10 = '';
		LET cDenominacion_11 = '';
		LET cDenominacion_12 = '';
		LET cDenominacion_13 = '';
		LET cDenominacion_14 = '';
		LET cDenominacion_15 = '';
		LET cDenMorralla = 'MORRALLA';
		LET dCantidad_1 = 0.00;
		LET dCantidad_2 = 0.00;
		LET dCantidad_3 = 0.00;
		LET dCantidad_4 = 0.00;
		LET dCantidad_5 = 0.00;
		LET dCantidad_6 = 0.00;
		LET dCantidad_7 = 0.00;
		LET dCantidad_8 = 0.00;
		LET dCantidad_9 = 0.00;
		LET dCantidad_10 = 0.00;
		LET dCantidad_11 = 0.00;
		LET dCantidad_12 = 0.00;
		LET dCantidad_13 = 0.00;
		LET dCantidad_14 = 0.00;
		LET dCantidad_15 = 0.00;
		LET dCantMorralla = 0.00;
		LET mMontoTotal1 = 0.00;
		LET mMontoTotal2 = 0.00;
		LET mMontoTotal3 = 0.00;
		LET mMontoTotal4 = 0.00;
		LET mMontoTotal5 = 0.00;
		LET mMontoTotal6 = 0.00; 
		LET mTotal = 0.00;		
		LET iNoRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;				
				RETURN cCodRet, cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, cDenominacion_6, cDenMorralla,
					   dCantidad_1, dCantidad_2, dCantidad_3, dCantidad_4, dCantidad_5, dCantidad_6, dCantMorralla, 
					   mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal; 
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultadetallemonitorefectivocaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pCodProveedor = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, cDenominacion_6, cDenMorralla,
					   dCantidad_1, dCantidad_2, dCantidad_3, dCantidad_4, dCantidad_5, dCantidad_6, dCantMorralla, 
					   mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, cDenominacion_6, cDenMorralla,
					   dCantidad_1, dCantidad_2, dCantidad_3, dCantidad_4, dCantidad_5, dCantidad_6, dCantMorralla, 
					   mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal;
			END IF;
			
			SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;
			
			FOREACH
				EXECUTE PROCEDURE bdisuc:'informix'.consultacajageneral ('001', pCodProveedor)
				INTO cCodRetSp, cEmpresa, cCodProveedor, cDivisa, mSaldoAnterior, mSaldoAsignado, mSaldoTotal, 
					 cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, 
					 cDenominacion_6, cDenominacion_7, cDenominacion_8, cDenominacion_9, cDenominacion_10, 
					 cDenominacion_11, cDenominacion_12, cDenominacion_13, cDenominacion_14, cDenominacion_15, 
					 dCantidad_1, dCantidad_2, dCantidad_3, dCantidad_4, dCantidad_5, 
					 dCantidad_6, dCantidad_7, dCantidad_8, dCantidad_9, dCantidad_10, 
					 dCantidad_11, dCantidad_12, dCantidad_13, dCantidad_14, dCantidad_15, 
					 cDescProveedor, cDescDivisa, cPlaza, cDescPlaza, mSaldoDisponible, mTotalBillDet
					 
				LET mMontoTotal1 = NVL(cDenominacion_1::INTEGER * dCantidad_1,0);
				LET mMontoTotal2 = NVL(cDenominacion_2::INTEGER * dCantidad_2,0);
				LET mMontoTotal3 = NVL(cDenominacion_3::INTEGER * dCantidad_3,0);				
				LET mMontoTotal4 = NVL(cDenominacion_4::INTEGER * dCantidad_4,0);
			    LET mMontoTotal5 = NVL(cDenominacion_5::INTEGER * dCantidad_5,0);				
				LET mMontoTotal6 = NVL(cDenominacion_6::INTEGER * dCantidad_6,0);
				LET dCantMorralla = NVL(dCantidad_7,0);
				LET mTotal = mMontoTotal1 + mMontoTotal2 + mMontoTotal3 + mMontoTotal4 + mMontoTotal5 + mMontoTotal6 + dCantMorralla;
					 
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:consultacajageneral';
				ELIF cCodRetSp::INTEGER = 101 THEN
					LET cCodRet = '00017'; 
					RETURN cCodRet, cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, cDenominacion_6, cDenMorralla,
					       dCantidad_1, dCantidad_2, dCantidad_3, dCantidad_4, dCantidad_5, dCantidad_6, dCantMorralla, 
					       mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal;
				ELSE
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, cDenominacion_6, cDenMorralla,
					       dCantidad_1, dCantidad_2, dCantidad_3, dCantidad_4, dCantidad_5, dCantidad_6, dCantMorralla, 
					       mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal WITH RESUME;
				END IF;
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cDenominacion_1, cDenominacion_2, cDenominacion_3, cDenominacion_4, cDenominacion_5, cDenominacion_6, cDenMorralla,
					   dCantidad_1, dCantidad_2, dCantidad_3, dCantidad_4, dCantidad_5, dCantidad_6, dCantMorralla, 
					   mMontoTotal1, mMontoTotal2, mMontoTotal3, mMontoTotal4, mMontoTotal5, mMontoTotal6, mTotal;
			END IF;	

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 27/03/2015',
'DESCRIPCION: SPL que obtiene el detalle de las cantidades (denominaciÃ³n, cantidad y monto total) de la caja general consultada.',
'FUNCIONALIDAD: Monitor de Efectivo Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfmonitoroperacionescaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(2), pIdSucursal CHAR(4), 
			pIdMostrar CHAR(4), pFechaInic DATE, pFechaFin DATE, pIdProvCaja CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		
		RETURNING CHAR(5) AS codret,
			CHAR(50) AS desc_sucursal,
            DATE AS fecha_operacion,
			CHAR(50) AS desc_status,
            CHAR(8) AS folio_operacion,
            MONEY(14,2) AS importe,
			CHAR(50) AS operacion,
			CHAR(4) AS cod_proveedor,
			CHAR(50) AS terceros, --
			CHAR(16) AS papeleta,
			CHAR(40) AS usuario,
			CHAR(2) AS cod_status,
			CHAR(6) AS id_atm,
			INTEGER AS billete1000,
			INTEGER AS billete500, 
			INTEGER AS billete200, 
			INTEGER AS billete100, 
			INTEGER AS billete50,  
			INTEGER AS billete20,  
			INTEGER AS billete10,  
			INTEGER AS billete5,   
			INTEGER AS billete2,   
			INTEGER AS billete1,   
			INTEGER AS billete_c50, 
			CHAR(40) AS desc_caja,
			INTEGER AS posicion_rep,
			MONEY(18,2) AS saldo_caja,
			CHAR(4) AS cc_atm;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cDescSucursal CHAR(50);
		DEFINE dFechaOperacion DATE;
		DEFINE cDescStatus CHAR(50);
        DEFINE cFolioOperacion CHAR(8);
        DEFINE mImporte MONEY(14,2);
		DEFINE cOperacion CHAR(50);
		DEFINE cCodProveedor CHAR(4);
		DEFINE cTerceros CHAR(50);
		DEFINE cPapeleta CHAR(16);
		DEFINE cUsuario CHAR(40);
		DEFINE cCodStatus CHAR(2);    
		DEFINE iIdATM CHAR(6);
		DEFINE iBillete1000 INTEGER;      
		DEFINE iBillete500  INTEGER;      
		DEFINE iBillete200  INTEGER;      
		DEFINE iBillete100  INTEGER;      
		DEFINE iBillete50   INTEGER;      
		DEFINE iBillete20   INTEGER;      
		DEFINE iBillete10   INTEGER;      
		DEFINE iBillete5    INTEGER;      
		DEFINE iBillete2    INTEGER;      
		DEFINE iBillete1    INTEGER;      
		DEFINE iBillete_c50  INTEGER;
        DEFINE cDescCaja CHAR(40);
        DEFINE iPosicionRep INTEGER;    
		DEFINE mSaldoCaja   MONEY(18,2); 
		DEFINE cCcATM CHAR(4);
        DEFINE cEmpresa CHAR(3);
        DEFINE iNoRegistros INTEGER; 
        DEFINE iRecuperacion INTEGER;
        DEFINE iRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cDescSucursal = '';
		LET dFechaOperacion = NULL;
		LET cDescStatus = '';
        LET cFolioOperacion = '';
        LET mImporte = NULL;
		LET cOperacion = '';
		LET cCodProveedor = '';
		LET cTerceros = '';
		LET cPapeleta = '';
		LET cUsuario = '';
		LET cCodStatus = '';   
		LET iIdATM = 0; 
		LET iBillete1000 = 0;      
		LET iBillete500  = 0;      
		LET iBillete200  = 0;      
		LET iBillete100  = 0;      
		LET iBillete50   = 0;      
		LET iBillete20   = 0;      
		LET iBillete10   = 0;      
		LET iBillete5    = 0;      
		LET iBillete2    = 0;      
		LET iBillete1    = 0;      
		LET iBillete_c50  = 0; 
        LET cDescCaja = '';
        LET iPosicionRep = 0;    
		LET mSaldoCaja   = NULL; 
		LET cCcATM = '';
        LET cEmpresa = '001';
        LET iNoRegistros = 0; 
        LET iRecuperacion = 0;
        LET iRegistros = 0;
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfmonitoroperacionescaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' OR pFechaInic IS NULL OR pFechaFin IS NULL OR pIdProvCaja = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM;
            END IF;
            
            -- VALIDACIÃN DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
			FOREACH	EXECUTE PROCEDURE bdisuc:'informix'.sp_monitor_operaciones2(cEmpresa, pTipoSucursal, pIdSucursal, pIdMostrar, pFechaInic, pFechaFin, pIdProvCaja, pRegistros, pRecuperacion)
					INTO cCodRetSp, cDescSucursal, dFechaOperacion, cDescStatus, cFolioOperacion, mImporte, cOperacion, cCodProveedor, cTerceros, cPapeleta, cUsuario, cCodStatus, iIdATM, 
					iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, cDescCaja, iPosicionRep, mSaldoCaja, cCcATM
					
					IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_monitor_operaciones2';
					ELIF cCodRetSp::INTEGER = 1 THEN
						IF pRegistros = 0 THEN
                        LET cCodRet = '00017'; --'00151'
						ELSE 
						LET cCodRet = '1001';
						END IF;
						RETURN cCodRet, UPPER(cDescSucursal), dFechaOperacion, UPPER(cDescStatus), cFolioOperacion, mImporte, UPPER(cOperacion), cCodProveedor, UPPER(cTerceros), cPapeleta, UPPER(cUsuario), cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, UPPER(cDescCaja), iPosicionRep, mSaldoCaja, cCcATM;
					ELSE
						LET iRecuperacion = iRecuperacion + 1;
						LET iNoRegistros = iNoRegistros + 1;
						RETURN cCodRet, UPPER(cDescSucursal), dFechaOperacion, UPPER(cDescStatus), cFolioOperacion, mImporte, UPPER(cOperacion), cCodProveedor, UPPER(cTerceros), cPapeleta, UPPER(cUsuario), cCodStatus, iIdATM, 
						iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, UPPER(cDescCaja), iPosicionRep, mSaldoCaja, cCcATM WITH RESUME;
					END IF;
					
			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00151'; --'00017'
				RETURN cCodRet, UPPER(cDescSucursal), dFechaOperacion, UPPER(cDescStatus), cFolioOperacion, mImporte, UPPER(cOperacion), cCodProveedor, UPPER(cTerceros), cPapeleta, UPPER(cUsuario), cCodStatus, iIdATM, 
				iBillete1000, iBillete500, iBillete200, iBillete100, iBillete50, iBillete20, iBillete10, iBillete5, iBillete2, iBillete1, iBillete_c50, UPPER(cDescCaja), iPosicionRep, mSaldoCaja, cCcATM;
			END IF;
				
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 12/01/2015',
'DESCRIPCION: SPL que realiza la consulta para el llenado del grid Transacciones, Monitor de Operaciones Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfoperacionescaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoFolio CHAR(8), pIdSucursal CHAR(4), pCodTransaccion CHAR(4), 
			pTipoConsulta CHAR(1), pIdCajaGen CHAR(4), pTipoSucursal CHAR(1), pFechaInic DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		
		RETURNING CHAR(5) AS codret,               
			CHAR(50) AS sucursal,                  
			DATE AS fecha,                         
			CHAR(4) AS cod_trans,                  
			CHAR(2) AS reversado,                  
			CHAR(40) AS usuario,                   
			CHAR(40) AS divisa,                    
			MONEY(14,2) AS importe,                
			DECIMAL(10,2) AS cantidad1,            
			DECIMAL(10,2) AS cantidad2,            
			DECIMAL(10,2) AS cantidad3,            
			DECIMAL(10,2) AS cantidad4,            
			DECIMAL(10,2) AS cantidad5,            
			DECIMAL(10,2) AS cantidad6,            
			DECIMAL(10,2) AS cantidad7,            
			DECIMAL(10,2) AS cantidad8,            
			DECIMAL(10,2) AS cantidad9,            
			DECIMAL(10,2) AS cantidad10,           
			DECIMAL(10,2) AS cantidad11,           
			DECIMAL(10,2) AS cantidad12,           
			DECIMAL(10,2) AS cantidad13,           
			DECIMAL(10,2) AS cantidad14,           
			DECIMAL(10,2) AS cantidad15,           
			CHAR(16) AS folio_suc_papeleta,        
			CHAR(8) AS folio_operacion,            
			CHAR(4) AS procedencia,                
			CHAR(40) AS caja_general,              
			CHAR(40) AS operacion,                 
			CHAR(8) AS id_usuario;					
			
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cSucursal CHAR(50);
		DEFINE dFecha DATE;
		DEFINE cCodTrans CHAR(4);
		DEFINE cDatoReversado CHAR(2);
		DEFINE cReversado CHAR(2);
		DEFINE cUsuario CHAR(40);
		DEFINE cDivisa CHAR(40);
		DEFINE mImporte MONEY(14,2);
		DEFINE dCantidad1 DECIMAL(10,2); 	        
		DEFINE dCantidad2 DECIMAL(10,2);		        
		DEFINE dCantidad3 DECIMAL(10,2);		        
		DEFINE dCantidad4 DECIMAL(10,2);		        
		DEFINE dCantidad5 DECIMAL(10,2);	        
		DEFINE dCantidad6 DECIMAL(10,2);        	
		DEFINE dCantidad7 DECIMAL(10,2);        	
		DEFINE dCantidad8 DECIMAL(10,2);        	
		DEFINE dCantidad9 DECIMAL(10,2);        	
		DEFINE dCantidad10 DECIMAL(10,2);        	
		DEFINE dCantidad11 DECIMAL(10,2);        	
		DEFINE dCantidad12 DECIMAL(10,2);        	
		DEFINE dCantidad13 DECIMAL(10,2);        	
		DEFINE dCantidad14 DECIMAL(10,2);        	
		DEFINE dCantidad15 DECIMAL(10,2);        	
		DEFINE cFolioSucPapeleta CHAR(16); 
		DEFINE cFolioOperacion CHAR(8);	
		DEFINE cProcedencia CHAR(4);         	
		DEFINE cCajageneral CHAR(40);		
		DEFINE cOperacion CHAR(40);	
		DEFINE cIdUsuario CHAR(8);		
        DEFINE cEmpresa CHAR(3);	
        DEFINE iNoRegistros INTEGER;	 
        DEFINE iRecuperacion INTEGER;
        DEFINE iRegistros INTEGER;	
			
		LET cCodRet = '00000';	
        LET cCodRetSp = '';	
		LET iCodRetSp = 0;	
        LET iSqlErr = 0;	
		LET cSucursal = '';	
		LET dFecha = NULL;	
		LET cCodTrans = '';	
		LET cDatoReversado = '';
		LET cReversado = '';	
		LET cUsuario = '';	
		LET cDivisa = '';	
		LET mImporte = NULL;	
		LET dCantidad1 = 0.00; 		
		LET dCantidad2 = 0.00;		
		LET dCantidad3 = 0.00;		
		LET dCantidad4 = 0.00;		
		LET dCantidad5 = 0.00;		
		LET dCantidad6 = 0.00;    	
		LET dCantidad7 = 0.00;    	
		LET dCantidad8 = 0.00;    	
		LET dCantidad9 = 0.00;    	
		LET dCantidad10 = 0.00;   	
		LET dCantidad11 = 0.00;   	
		LET dCantidad12 = 0.00;   	
		LET dCantidad13 = 0.00;   	
		LET dCantidad14 = 0.00;   	
		LET dCantidad15 = 0.00;   	
		LET cFolioSucPapeleta = ''; 	
		LET cFolioOperacion = '';		
		LET cProcedencia = '';      	 
		LET cCajageneral = '';			
		LET cOperacion = '';	
		LET cIdUsuario = '';			
        LET cEmpresa = '001';
        LET iNoRegistros = 0; 
        LET iRecuperacion = 0;
        LET iRegistros = 0;

		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cSucursal, dFecha, cCodTrans, cReversado, cUsuario, cDivisa, mImporte, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5,	
					   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
					   cFolioSucPapeleta, cFolioOperacion, cProcedencia, cCajageneral, cOperacion, cIdUsuario;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfoperacionescaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' OR pTipoConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cSucursal, dFecha, cCodTrans, cReversado, cUsuario, cDivisa, mImporte, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5,	
					   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
					   cFolioSucPapeleta, cFolioOperacion, cProcedencia, cCajageneral, cOperacion, cIdUsuario;
            END IF;
            
            -- VALIDACIÃN DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cSucursal, dFecha, cCodTrans, cReversado, cUsuario, cDivisa, mImporte, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5,	
					   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
					   cFolioSucPapeleta, cFolioOperacion, cProcedencia, cCajageneral, cOperacion, cIdUsuario;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cSucursal, dFecha, cCodTrans, cReversado, cUsuario, cDivisa, mImporte, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5,	
					   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
					   cFolioSucPapeleta, cFolioOperacion, cProcedencia, cCajageneral, cOperacion, cIdUsuario;
			END IF;
			
			SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;
		
			IF pIdCajaGen = '0000' AND pTipoConsulta = '5' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cSucursal, dFecha, cCodTrans, cReversado, cUsuario, cDivisa, mImporte, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5,	
					   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
					   cFolioSucPapeleta, cFolioOperacion, cProcedencia, cCajageneral, cOperacion, cIdUsuario;
			END IF;
		
			FOREACH	EXECUTE PROCEDURE bdisuc:'informix'.sp_consul_operaciones2(cEmpresa, pFechaInic, pFechaFin, pNoFolio, pIdSucursal, pCodTransaccion, pTipoConsulta, pIdCajaGen, pTipoSucursal, pRegistros, pRecuperacion)
				INTO cCodRetSp, cSucursal, dFecha, cCodTrans, cDatoReversado, cUsuario, cDivisa, mImporte, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5,	
					   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
					   cFolioSucPapeleta, cFolioOperacion, cProcedencia, cCajageneral, cOperacion	
				
				IF cDatoReversado = '0' THEN
					LET cReversado = 'NO';
				ELSE
					LET cReversado = 'SI';
				END IF;
				
				-- Obtenemos no. Usuario
				SELECT usuario INTO cIdUsuario
				FROM bdisuc:'informix'.ss_operaciones
				WHERE folio_oper = cFolioOperacion;
				
				IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_consul_operaciones2';
				ELIF cCodRetSp::INTEGER = 001 THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cSucursal, dFecha, cCodTrans, cReversado, cUsuario, cDivisa, mImporte, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5,	
						   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
						   cFolioSucPapeleta, cFolioOperacion, cProcedencia, cCajageneral, cOperacion, cIdUsuario;
				ELSE
					LET iNoRegistros = iNoRegistros + 1;					
					RETURN cCodRet, NVL(UPPER(cSucursal),''), NVL(dFecha,''), cCodTrans, NVL(UPPER(cReversado),''), NVL(UPPER(cUsuario),''), NVL(UPPER(cDivisa),''), NVL(mImporte,''), NVL(dCantidad1,0), NVL(dCantidad2,0), NVL(dCantidad3,0), NVL(dCantidad4,0), NVL(dCantidad5,0),	
					   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
					   cFolioSucPapeleta, cFolioOperacion, cProcedencia, NVL(UPPER(cCajageneral),''), NVL(UPPER(cOperacion),''), NVL(cIdUsuario,'') WITH RESUME;
				END IF;
					
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cSucursal, dFecha, cCodTrans, cReversado, cUsuario, cDivisa, mImporte, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5,	
					   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
					   cFolioSucPapeleta, cFolioOperacion, cProcedencia, cCajageneral, cOperacion, cIdUsuario;	
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cSucursal, dFecha, cCodTrans, cReversado, cUsuario, cDivisa, mImporte, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5,	
					   dCantidad6, dCantidad7, dCantidad8, dCantidad9, dCantidad10, dCantidad11, dCantidad12, dCantidad13, dCantidad14, dCantidad15,  
					   cFolioSucPapeleta, cFolioOperacion, cProcedencia, cCajageneral, cOperacion, cIdUsuario;
			END IF;	
				
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 11/02/2015',
'DESCRIPCION: SPL que realiza la consulta para el llenado del grid Operaciones Realizadas, Consulta Operaciones Caja General',
'MODULO: Caja general',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfsdohistoricocaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSaldo CHAR(1), 
		pCcMayor CHAR(4), pCcSub CHAR(2), pCcsubsub CHAR(2), pCcssubsub CHAR(2), pCcsssubsub CHAR(2), pSector CHAR(2),
		pFechaMes CHAR(2), pFechaAnio CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
					
		RETURNING CHAR(5) AS codret, 
			CHAR(4) AS cSucursal,       
			CHAR(40) AS cNombre, 
			MONEY(14,2) AS mDia1,     
			MONEY(14,2) AS mDia2,     
			MONEY(14,2) AS mDia3,     
			MONEY(14,2) AS mDia4,     
			MONEY(14,2) AS mDia5,     
			MONEY(14,2) AS mDia6,     
			MONEY(14,2) AS mDia7,     
			MONEY(14,2) AS mDia8,     
			MONEY(14,2) AS mDia9,     
			MONEY(14,2) AS mDia10,     
			MONEY(14,2) AS mDia11,     
			MONEY(14,2) AS mDia12,     
			MONEY(14,2) AS mDia13,     
			MONEY(14,2) AS mDia14,     
			MONEY(14,2) AS mDia15,     
			MONEY(14,2) AS mDia16,     
			MONEY(14,2) AS mDia17,     
			MONEY(14,2) AS mDia18,     
			MONEY(14,2) AS mDia19,     
			MONEY(14,2) AS mDia20,     
			MONEY(14,2) AS mDia21,     
			MONEY(14,2) AS mDia22,     
			MONEY(14,2) AS mDia23,     
			MONEY(14,2) AS mDia24,     
			MONEY(14,2) AS mDia25,     
			MONEY(14,2) AS mDia26,     
			MONEY(14,2) AS mDia27,     
			MONEY(14,2) AS mDia28,     
			MONEY(14,2) AS mDia29,     
			MONEY(14,2) AS mDia30,     
			MONEY(14,2) AS mDia31;    
		  
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE sTipo SMALLINT;
		DEFINE dFechaMinSel DATE;
		DEFINE dFechaMaxSel DATE;
		DEFINE dFechaMaxima DATE;
		DEFINE cSucursal   CHAR(4);
		DEFINE cNombre     CHAR(40); 
		DEFINE mDia1       MONEY(14,2);
		DEFINE mDia2       MONEY(14,2);
		DEFINE mDia3       MONEY(14,2);
		DEFINE mDia4       MONEY(14,2);
		DEFINE mDia5       MONEY(14,2);
		DEFINE mDia6       MONEY(14,2);
		DEFINE mDia7       MONEY(14,2);
		DEFINE mDia8       MONEY(14,2);
		DEFINE mDia9       MONEY(14,2);
		DEFINE mDia10      MONEY(14,2);
		DEFINE mDia11      MONEY(14,2);
		DEFINE mDia12      MONEY(14,2);
		DEFINE mDia13      MONEY(14,2);
		DEFINE mDia14      MONEY(14,2);
		DEFINE mDia15      MONEY(14,2);
		DEFINE mDia16      MONEY(14,2);
		DEFINE mDia17      MONEY(14,2);
		DEFINE mDia18      MONEY(14,2);
		DEFINE mDia19      MONEY(14,2);
		DEFINE mDia20      MONEY(14,2);
		DEFINE mDia21      MONEY(14,2);
		DEFINE mDia22      MONEY(14,2);
		DEFINE mDia23      MONEY(14,2);
		DEFINE mDia24      MONEY(14,2);
		DEFINE mDia25      MONEY(14,2);
		DEFINE mDia26      MONEY(14,2);
		DEFINE mDia27      MONEY(14,2);
		DEFINE mDia28      MONEY(14,2);
		DEFINE mDia29      MONEY(14,2);
		DEFINE mDia30      MONEY(14,2);
		DEFINE mDia31      MONEY(14,2);
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET sTipo = 0;
		LET dFechaMinSel = '';
		LET dFechaMaxSel = '';
		LET dFechaMaxima = '';
		LET cSucursal   = '';
		LET cNombre     = '';
		LET mDia1       = '';
		LET mDia2       = '';
		LET mDia3       = '';
		LET mDia4       = '';
		LET mDia5       = '';
		LET mDia6       = '';
		LET mDia7       = '';
		LET mDia8       = '';
		LET mDia9       = '';
		LET mDia10      = '';
		LET mDia11      = '';
		LET mDia12      = '';
		LET mDia13      = '';
		LET mDia14      = '';
		LET mDia15      = '';
		LET mDia16      = '';
		LET mDia17      = '';
		LET mDia18      = '';
		LET mDia19      = '';
		LET mDia20      = '';
		LET mDia21      = '';
		LET mDia22      = '';
		LET mDia23      = '';
		LET mDia24      = '';
		LET mDia25      = '';
		LET mDia26      = '';
		LET mDia27      = '';
		LET mDia28      = '';
		LET mDia29      = '';
		LET mDia30      = '';
		LET mDia31      = '';
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,cSucursal,cNombre,
					   mDia1,mDia2,mDia3,mDia4,mDia5,mDia6,mDia7,mDia8,mDia9,mDia10,
					   mDia11,mDia12,mDia13,mDia14,mDia15,mDia16,mDia17,mDia18,mDia19,mDia20,
					   mDia21,mDia22,mDia23,mDia24,mDia25,mDia26,mDia27,mDia28,mDia29,mDia30,mDia31; 
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfsdohistoricocaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoSaldo = '' OR pFechaMes = '' OR pFechaAnio = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cSucursal,cNombre,
					   mDia1,mDia2,mDia3,mDia4,mDia5,mDia6,mDia7,mDia8,mDia9,mDia10,
					   mDia11,mDia12,mDia13,mDia14,mDia15,mDia16,mDia17,mDia18,mDia19,mDia20,
					   mDia21,mDia22,mDia23,mDia24,mDia25,mDia26,mDia27,mDia28,mDia29,mDia30,mDia31; 
            END IF;
            
			-- VALIDACIÃN DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet,cSucursal,cNombre,
					   mDia1,mDia2,mDia3,mDia4,mDia5,mDia6,mDia7,mDia8,mDia9,mDia10,
					   mDia11,mDia12,mDia13,mDia14,mDia15,mDia16,mDia17,mDia18,mDia19,mDia20,
					   mDia21,mDia22,mDia23,mDia24,mDia25,mDia26,mDia27,mDia28,mDia29,mDia30,mDia31; 
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,cSucursal,cNombre,
					   mDia1,mDia2,mDia3,mDia4,mDia5,mDia6,mDia7,mDia8,mDia9,mDia10,
					   mDia11,mDia12,mDia13,mDia14,mDia15,mDia16,mDia17,mDia18,mDia19,mDia20,
					   mDia21,mDia22,mDia23,mDia24,mDia25,mDia26,mDia27,mDia28,mDia29,mDia30,mDia31; 
			END IF;
			
			-- DEFINE CONSULTA 
			IF pTipoSaldo = 'F' THEN
				LET sTipo = 1;		
			ELIF pTipoSaldo = 'C' THEN
				LET sTipo = 0;
			END IF;
	
			-- ARMADO DE FECHAS			
			LET dFechaMinSel = TO_DATE(1||'/'||(pFechaMes::INTEGER)||'/'||(pFechaAnio::INTEGER),'%d/%m/%Y');
			LET dFechaMaxima = dFechaMinSel + 1 UNITS MONTH;
			LET dFechaMaxSel = dFechaMaxima - 1 UNITS DAY;
				
			FOREACH
				EXECUTE PROCEDURE bdisuc:'informix'.sp_sel_sdohistorico2(cEmpresa,sTipo,pCcMayor,pCcSub,pCcsubsub,pCcssubsub,pCcsssubsub,pSector,dFechaMinSel,dFechaMaxSel,pRegistros,pRecuperacion)
				INTO cCodRetSp,cSucursal,cNombre,
					 mDia1,mDia2,mDia3,mDia4,mDia5,mDia6,mDia7,mDia8,mDia9,mDia10,
					 mDia11,mDia12,mDia13,mDia14,mDia15,mDia16,mDia17,mDia18,mDia19,mDia20,
					 mDia21,mDia22,mDia23,mDia24,mDia25,mDia26,mDia27,mDia28,mDia29,mDia30,mDia31				 
					 
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_sel_sdohistorico2';
				ELSE
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet,NVL(cSucursal,''),NVL(UPPER(cNombre),''),
						   NVL(mDia1,0),NVL(mDia2,0),NVL(mDia3,0),NVL(mDia4,0),NVL(mDia5,0),NVL(mDia6,0),NVL(mDia7,0),NVL(mDia8,0),NVL(mDia9,0),NVL(mDia10,0),
						   NVL(mDia11,0),NVL(mDia12,0),NVL(mDia13,0),NVL(mDia14,0),NVL(mDia15,0),NVL(mDia16,0),NVL(mDia17,0),NVL(mDia18,0),NVL(mDia19,0),NVL(mDia20,0),
						   NVL(mDia21,0),NVL(mDia22,0),NVL(mDia23,0),NVL(mDia24,0),NVL(mDia25,0),NVL(mDia26,0),NVL(mDia27,0),NVL(mDia28,0),NVL(mDia29,0),NVL(mDia30,0),NVL(mDia31,0) WITH RESUME;
				END IF;
			END FOREACH;
				
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet,cSucursal,cNombre,
					   mDia1,mDia2,mDia3,mDia4,mDia5,mDia6,mDia7,mDia8,mDia9,mDia10,
					   mDia11,mDia12,mDia13,mDia14,mDia15,mDia16,mDia17,mDia18,mDia19,mDia20,
					   mDia21,mDia22,mDia23,mDia24,mDia25,mDia26,mDia27,mDia28,mDia29,mDia30,mDia31; 
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cSucursal,cNombre,
					   mDia1,mDia2,mDia3,mDia4,mDia5,mDia6,mDia7,mDia8,mDia9,mDia10,
					   mDia11,mDia12,mDia13,mDia14,mDia15,mDia16,mDia17,mDia18,mDia19,mDia20,
					   mDia21,mDia22,mDia23,mDia24,mDia25,mDia26,mDia27,mDia28,mDia29,mDia30,mDia31; 		
			END IF;	

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 01/04/2015',
'DESCRIPCION: SPL que obtiene el detalle de los saldos (fÃ­sicos o contables, dependiendo del tipo de consulta).',
'FUNCIONALIDAD: HistÃ³rico de Saldos Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfsucabrieroncaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta DATE,
			pRegistros INTEGER, pRecuperacion INTEGER)
		
		RETURNING CHAR(5) AS codret,
			DATE AS fecha_abrio,
			CHAR(4) AS id_suc_abrio,
			CHAR(40) AS desc_suc_abrio,
			CHAR(30) AS desc_cg_abrio,
			CHAR(1) AS suc_abrio;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cFechaAbrio DATE;
		DEFINE cIdSuc CHAR(4);
		DEFINE cIdSucursalAbrio CHAR(4);
		DEFINE cDescSuc CHAR(40);
		DEFINE cDescSucursalAbrio CHAR(40);
		DEFINE cDescCaja CHAR(30);
		DEFINE cNombreCajaAbrio CHAR(30);
		DEFINE cSucAbrio CHAR(1);
		DEFINE iRecuperacion INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cFechaAbrio = '';
		LET cIdSuc = '';
		LET cIdSucursalAbrio = '';
		LET cDescSuc = '';
		LET cDescSucursalAbrio = '';
		LET cDescCaja = '';
		LET cNombreCajaAbrio = '';
		LET cSucAbrio = '';
        LET iRecuperacion = 0;
		
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cFechaAbrio, cIdSucursalAbrio, cDescSucursalAbrio, cNombreCajaAbrio, cSucAbrio;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfsucabrieroncaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta = '' OR pFechaConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFechaAbrio, cIdSucursalAbrio, cDescSucursalAbrio, cNombreCajaAbrio, cSucAbrio;
            END IF;
            
            -- VALIDACIÃN DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cFechaAbrio, cIdSucursalAbrio, cDescSucursalAbrio, cNombreCajaAbrio, cSucAbrio;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, cFechaAbrio, cIdSucursalAbrio, cDescSucursalAbrio, cNombreCajaAbrio, cSucAbrio;
			END IF;
			
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion
				DISTINCT sal.sucursal, suc.nombre, prov.descripcion INTO cIdSuc, cDescSuc, cDescCaja
				FROM bdisuc:'informix'.ss_pase_sucursal AS sal INNER JOIN bdinteg:'informix'.si_sucursales AS suc 
				ON sal.sucursal = suc.sucursal AND suc.tpo_sucursal = 'S' AND sal.fecha_pase = pFechaConsulta 
				INNER JOIN bdisuc:'informix'.ss_proveedores AS prov ON prov.plaza = suc.plaza_cajagen 
				ORDER BY prov.descripcion
				
				IF cIdSuc IS NULL OR cIdSuc = '' THEN
					LET cFechaAbrio = '';
					LET cIdSucursalAbrio = '';
					LET cDescSucursalAbrio = '';
					LET cNombreCajaAbrio = '';
					LET cSucAbrio = '';
				ELSE	
					LET cFechaAbrio = pFechaConsulta;
					LET cIdSucursalAbrio = cIdSuc;
					LET cDescSucursalAbrio = cDescSuc;
					LET cNombreCajaAbrio = cDescCaja;
					
					SELECT suc_abrio INTO cSucAbrio 
					FROM bdisuc:'informix'.ss_pase_sucursal WHERE sucursal = cIdSuc AND fecha_pase = pFechaConsulta;
					
					RETURN cCodRet, cFechaAbrio, cIdSucursalAbrio, UPPER(cDescSucursalAbrio), UPPER(cNombreCajaAbrio), cSucAbrio WITH RESUME;
					LET iRecuperacion = iRecuperacion + 1;
				END IF;
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, cFechaAbrio, cIdSucursalAbrio, cDescSucursalAbrio, cNombreCajaAbrio, cSucAbrio;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cFechaAbrio, cIdSucursalAbrio, cDescSucursalAbrio, cNombreCajaAbrio, cSucAbrio;	
			END IF;	
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/03/2015',
'DESCRIPCION: SPL que realiza la consulta para obtener el detalle de las sucursales que abrieron.',
'FUNCIONALIDAD: Sucursales No Abiertas Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfsucnoabrieroncaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta DATE,
			pRegistros INTEGER, pRecuperacion INTEGER)
		
		RETURNING CHAR(5) AS codret,
			DATE AS ultima_fecha_abrio,
			CHAR(4) AS id_suc_noabrio,
			CHAR(40) AS desc_suc_noabrio,
			CHAR(30) AS desc_divisa,
			MONEY(14,2) AS ultimo_monto,
			DECIMAL(10,2) AS cantidad_1,
			DECIMAL(10,2) AS cantidad_2,
			DECIMAL(10,2) AS cantidad_3,
			DECIMAL(10,2) AS cantidad_4,
			DECIMAL(10,2) AS cantidad_5,
			DECIMAL(10,2) AS cantidad_6,
			DECIMAL(10,2) AS cantidad_7,
			DECIMAL(10,2) AS cantidad_8,
			DECIMAL(10,2) AS cantidad_9,
			DECIMAL(10,2) AS cantidad_10,
			DECIMAL(10,2) AS cantidad_11,
			DECIMAL(10,2) AS cantidad_12,
			DECIMAL(10,2) AS cantidad_13,
			DECIMAL(10,2) AS cantidad_14,
			DECIMAL(10,2) AS cantidad_15,
			DECIMAL(10,2) AS cantidad_16;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE sFecha DATE;
		DEFINE sSucursal CHAR(4);
		DEFINE cDescSucursal CHAR(40);
		DEFINE cDescDivisa CHAR(30);
		DEFINE sSaldoTotal MONEY(14,2);
		DEFINE sCant1 DECIMAL(10,2);
		DEFINE sCant2 DECIMAL(10,2);
		DEFINE sCant3 DECIMAL(10,2);
		DEFINE sCant4 DECIMAL(10,2);
		DEFINE sCant5 DECIMAL(10,2);
		DEFINE sCant6 DECIMAL(10,2);
		DEFINE sCant7 DECIMAL(10,2);
		DEFINE sCant8 DECIMAL(10,2);
		DEFINE sCant9 DECIMAL(10,2);
		DEFINE sCant10 DECIMAL(10,2);
		DEFINE sCant11 DECIMAL(10,2);
		DEFINE sCant12 DECIMAL(10,2);
		DEFINE sCant13 DECIMAL(10,2);
		DEFINE sCant14 DECIMAL(10,2);
		DEFINE sCant15 DECIMAL(10,2);
		DEFINE sCant16 DECIMAL(10,2);
		DEFINE iRecuperacion INTEGER;
		DEFINE dFechaAnterior DATE;
		DEFINE dFechaPase DATE;
		DEFINE sEmpresa CHAR(3); 
		DEFINE sDivisa CHAR(2);
		DEFINE sCajeroPrincipal CHAR(8);
		DEFINE iContPase INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET sFecha = '';
		LET sSucursal = '';
		LET cDescSucursal = '';
		LET cDescDivisa = '';
		LET sSaldoTotal = NULL;
		LET sCant1  = 0.00;
		LET sCant2 = 0.00;
		LET sCant3 = 0.00;
		LET sCant4 = 0.00;
		LET sCant5 = 0.00;
		LET sCant6 = 0.00;
		LET sCant7 = 0.00;
		LET sCant8 = 0.00;
		LET sCant9 = 0.00;
		LET sCant10 = 0.00;
		LET sCant11 = 0.00;
		LET sCant12 = 0.00;
		LET sCant13 = 0.00;
		LET sCant14 = 0.00;
		LET sCant15 = 0.00;
		LET sCant16 = 0.00;
        LET iRecuperacion = 0;
		LET dFechaAnterior = '';
		LET dFechaPase = '';
		LET sEmpresa = ''; 
		LET sDivisa = '';
		LET sCajeroPrincipal = '';
		LET iContPase = 0;
		
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, sFecha, sSucursal, cDescSucursal, cDescDivisa, sSaldoTotal,
					   sCant1, sCant2, sCant3, sCant4, sCant5, sCant6, sCant7, sCant8, sCant9, sCant10,
					   sCant11, sCant12, sCant13, sCant14, sCant15, sCant16;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfsucnoabrieroncaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta = '' OR pFechaConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, sFecha, sSucursal, cDescSucursal, cDescDivisa, sSaldoTotal,
					   sCant1, sCant2, sCant3, sCant4, sCant5, sCant6, sCant7, sCant8, sCant9, sCant10,
					   sCant11, sCant12, sCant13, sCant14, sCant15, sCant16;
            END IF;
            
            -- VALIDACIÃN DE LOS DATOS DE PAGINACION
            IF pRegistros < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, sFecha, sSucursal, cDescSucursal, cDescDivisa, sSaldoTotal,
					   sCant1, sCant2, sCant3, sCant4, sCant5, sCant6, sCant7, sCant8, sCant9, sCant10,
					   sCant11, sCant12, sCant13, sCant14, sCant15, sCant16;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, sFecha, sSucursal, cDescSucursal, cDescDivisa, sSaldoTotal,
					   sCant1, sCant2, sCant3, sCant4, sCant5, sCant6, sCant7, sCant8, sCant9, sCant10,
					   sCant11, sCant12, sCant13, sCant14, sCant15, sCant16;
			END IF;
			
			-- SE CALCULA LA FECHA ANTERIOR
			LET dFechaAnterior = DATE(pFechaConsulta) -1;
			
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion
				DISTINCT NVL(sal.empresa,''),NVL(sal.sucursal,''),NVL(sal.divisa,''),NVL(sal.saldo_total,''),NVL(sal.fecha,''),NVL(sal.cajero_principal,''),
							NVL(sal.cantidad_1,''),NVL(sal.cantidad_2,''),NVL(sal.cantidad_3,''),NVL(sal.cantidad_4,''),NVL(sal.cantidad_5,''),
							NVL(sal.cantidad_6,''),NVL(sal.cantidad_7,''),NVL(sal.cantidad_8,''),NVL(sal.cantidad_9,''),NVL(sal.cantidad_10,''),
							NVL(sal.cantidad_11,''),NVL(sal.cantidad_12,''),NVL(sal.cantidad_13,''),NVL(sal.cantidad_14,''),NVL(sal.cantidad_15,'') 
				INTO sEmpresa,sSucursal,sDivisa,sSaldoTotal,sFecha,sCajeroPrincipal,sCant1,sCant2,sCant3,sCant4,sCant5,
				sCant6,sCant7,sCant8,sCant9,sCant10,sCant11,sCant12,sCant13,sCant14,sCant15
				FROM bdisuc:'informix'.ss_saldossuc AS sal INNER JOIN bdinteg:'informix'.si_sucursales AS suc 
				ON sal.sucursal = suc.sucursal AND suc.tpo_sucursal = 'S' AND sal.fecha = dFechaAnterior
				
				SELECT COUNT (*) INTO iContPase
				FROM bdisuc:ss_pase_sucursal WHERE fecha_pase = pFechaConsulta AND sucursal = sSucursal;
				
				IF iContPase = 0 THEN
						SELECT nombre INTO cDescSucursal
						FROM bdinteg:'informix'.si_sucursales AS suc, bdisuc:'informix'.ss_proveedores AS prov
						WHERE suc.sucursal = sSucursal AND suc.plaza_cajagen = prov.plaza;

						SELECT descripcion INTO cDescDivisa 
						FROM bdinteg:si_divisas WHERE divisa = sDivisa;
							
						RETURN cCodRet, sFecha, sSucursal, UPPER(cDescSucursal), UPPER(cDescDivisa), sSaldoTotal,
							   sCant1, sCant2, sCant3, sCant4, sCant5, sCant6, sCant7, sCant8, sCant9, sCant10,
							   sCant11, sCant12, sCant13, sCant14, sCant15, sCant16 WITH RESUME;
						LET iRecuperacion = iRecuperacion + 1;
				END IF;
			END FOREACH;
			
			IF iRecuperacion = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet, sFecha, sSucursal, cDescSucursal, cDescDivisa, sSaldoTotal,
					   sCant1, sCant2, sCant3, sCant4, sCant5, sCant6, sCant7, sCant8, sCant9, sCant10,
					   sCant11, sCant12, sCant13, sCant14, sCant15, sCant16;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, sFecha, sSucursal, cDescSucursal, cDescDivisa, sSaldoTotal,
					   sCant1, sCant2, sCant3, sCant4, sCant5, sCant6, sCant7, sCant8, sCant9, sCant10,
					   sCant11, sCant12, sCant13, sCant14, sCant15, sCant16;
			END IF;	
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/03/2015',
'DESCRIPCION: SPL que realiza la consulta para obtener el detalle de las sucursales que no abrieron.',
'FUNCIONALIDAD: Sucursales No Abiertas Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultamontocreditocentral(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoCredito CHAR(20))
		RETURNING CHAR(5) AS codret,
				DECIMAL(18,2) AS monto_linea;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cNoCliente CHAR(20);
	DEFINE cNombreCliente CHAR(104);
	DEFINE dMontoLinea DECIMAL(18,2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cMensajeRetorno = '';
	LET cNoCliente = '';
	LET cNombreCliente = '';
	LET dMontoLinea = NULL;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dMontoLinea;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultamontocreditocentral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNoCredito = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dMontoLinea;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNoCredito, '06', '1') INTO cCodRet;
		--EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dMontoLinea;
		END IF;
		
		EXECUTE PROCEDURE bdicred:'informix'.sp_consultacredito_central(cEmpresa, pNoCredito)
		INTO cCodRetSp, cMensajeRetorno, cNoCliente, cNombreCliente, dMontoLinea;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultacredito_central';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00046';
		END IF;
		
		RETURN cCodRet, dMontoLinea;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 22/04/2014',
'DESCRIPCION: Consulta el monto actual de la lÃ­nea de crÃ©dito para el aumento o disminuciÃ³n',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detallearchivodotacioncaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoFolio CHAR(8))
		RETURNING CHAR(5) AS codret,
			DECIMAL(10,2) AS fCant1, 
			CHAR(18) AS cDenominacion1, 
			MONEY(14,2) AS mTotal1, 
			DECIMAL(10,2) AS fCant2, 
			CHAR(18) AS cDenominacion2,
			MONEY(14,2) AS mTotal2,
			DECIMAL(10,2) AS fCant3,
			CHAR(18) AS cDenominacion3, 
			MONEY(14,2) AS mTotal3,
			DECIMAL(10,2) AS fCant4, 
			CHAR(18) AS cDenominacion4, 
			MONEY(14,2) AS mTotal4,
			DECIMAL(10,2) AS fCant5,
			CHAR(18) AS cDenominacion5,
			MONEY(14,2) AS mTotal5,
			DECIMAL(10,2) AS fCant6, 
			CHAR(18) AS cDenominacion6,
			MONEY(14,2) AS mTotal6,		
			CHAR(10) AS cMorralla,
			CHAR(18) AS cDenMorralla,
			MONEY(14,2) AS mTotalMorralla, 
			MONEY (14,2) AS monto_tot,
			CHAR(30) AS desc_moneda,
			CHAR(30) AS desc_status,
			DATE AS fech_solicitud, 
			CHAR(5) AS ho_solicitud, 
			CHAR(8) AS us_solicitud,
			DATE AS fech_envio,
			CHAR(5) AS ho_envio, 
			CHAR(8) AS us_envio,
			DATE AS fech_recepcion, 
			CHAR(5) AS ho_recepcion, 
			CHAR(8) AS us_recepcion,
			CHAR(2) AS id_status,
			CHAR(45) AS nom_solicitud,
			CHAR(45) AS nom_envio,
		    CHAR(45) AS nom_recepcion,
			DATE AS fech_reversion, 
			CHAR(5) AS ho_reversion, 
			CHAR(8) AS us_reversion,
			CHAR(45) AS nom_reversion,
			CHAR(1) AS indicador_usuario;			
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE fCant1 DECIMAL(10,2); 
	DEFINE cDenominacion1 CHAR(18); 
	DEFINE mTotal1 MONEY(14,2);
	DEFINE fCant2 DECIMAL(10,2); 
	DEFINE cDenominacion2 CHAR(18);
	DEFINE mTotal2 MONEY(14,2);
	DEFINE fCant3 DECIMAL(10,2); 
	DEFINE cDenominacion3 CHAR(18); 
	DEFINE mTotal3 MONEY(14,2);
	DEFINE fCant4 DECIMAL(10,2); 
	DEFINE cDenominacion4 CHAR(18);
	DEFINE mTotal4 MONEY(14,2);
	DEFINE fCant5 DECIMAL(10,2); 
	DEFINE cDenominacion5 CHAR(18); 
	DEFINE mTotal5 MONEY(14,2);
	DEFINE fCant6 DECIMAL(10,2); 
	DEFINE cDenominacion6 CHAR(18); 
	DEFINE mTotal6 MONEY(14,2);
	DEFINE fCant7 DECIMAL(10,2); 
	DEFINE cDenominacion7 CHAR(18); 
	DEFINE mTotal7 MONEY(14,2);
	DEFINE fCant8 DECIMAL(10,2); 
	DEFINE cDenominacion8 CHAR(18);
	DEFINE mTotal8 MONEY(14,2);	
	DEFINE fCant9 DECIMAL(10,2); 
	DEFINE cDenominacion9 CHAR(18);
	DEFINE mTotal9 MONEY(14,2);
	DEFINE fCant10 DECIMAL(10,2); 
	DEFINE cDenominacion10 CHAR(18);
	DEFINE mTotal10 MONEY(14,2);
	DEFINE fCant11 DECIMAL(10,2); 
	DEFINE cDenominacion11 CHAR(18);
	DEFINE mTotal11 MONEY(14,2);
	DEFINE fCant12 DECIMAL(10,2); 
	DEFINE cDenominacion12 CHAR(18);
	DEFINE mTotal12 MONEY(14,2);
	DEFINE fCant13 DECIMAL(10,2); 
	DEFINE cDenominacion13 CHAR(18);
	DEFINE mTotal13 MONEY(14,2);
	DEFINE fCant14 DECIMAL(10,2); 
	DEFINE cDenominacion14 CHAR(18);
	DEFINE mTotal14 MONEY(14,2);
	DEFINE fCant15 DECIMAL(10,2); 
	DEFINE cDenominacion15 CHAR(18);
	DEFINE mTotal15 MONEY(14,2);
	DEFINE cMorralla CHAR(10);		   
	DEFINE cDenMorralla CHAR(18);      
	DEFINE mTotalMorralla MONEY(14,2); 
	DEFINE mMontoTot MONEY(14,2);
	DEFINE cDivisa CHAR(2);
	DEFINE cDescMoneda CHAR(30);
	DEFINE cDescStatus CHAR(30);
	DEFINE dFechSolicitud DATE;
	DEFINE cHoSolicitud CHAR(5);
	DEFINE cUsSolicitud CHAR(8);
	DEFINE dFechEnvio DATE;
	DEFINE cHoEnvio CHAR(5);
	DEFINE cUsEnvio CHAR(8);
	DEFINE dFechRecepcion DATE;
	DEFINE cHoRecepcion CHAR(5);
	DEFINE cUsRecepcion CHAR(8);
	DEFINE cIdStatus CHAR(2);
	DEFINE dFechReversion DATE;
	DEFINE cHoReversion CHAR(5); 
	DEFINE cUsReversion CHAR(8);	
	DEFINE cNomSolicitud CHAR(45);
	DEFINE cNomEnvio CHAR(45);
	DEFINE cNomRecepcion CHAR(45);
	DEFINE cNomReversion CHAR(45);
	DEFINE cIndicadorUs CHAR(1);
	DEFINE cCodTrans CHAR(4);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET fCant1 = 0.00; 
	LET cDenominacion1 = ''; 
	LET mTotal1 = NULL;
	LET fCant2 = 0.00; 
	LET cDenominacion2 = ''; 
	LET mTotal2 = NULL;
	LET fCant3 = 0.00; 
	LET cDenominacion3 = '';
	LET mTotal3 = NULL;
	LET fCant4 = 0.00; 
	LET cDenominacion4 = '';
	LET mTotal4 = NULL;
	LET fCant5 = 0.00; 
	LET cDenominacion5 = '';
	LET mTotal5 = NULL;
	LET fCant6 = 0.00; 
	LET cDenominacion6 = ''; 
	LET mTotal6 = NULL; 
	LET fCant7 = 0.00; 
	LET cDenominacion7 = ''; 
	LET mTotal7 = NULL;
	LET fCant8 = 0.00; 
	LET cDenominacion8 = ''; 
	LET mTotal8 = NULL;
	LET fCant9 = 0.00; 
	LET cDenominacion9 = '';
	LET mTotal9 = NULL;
	LET fCant10 = 0.00; 
	LET cDenominacion10 = '';
	LET mTotal10 = NULL;
	LET fCant11 = 0.00; 
	LET cDenominacion11 = '';
	LET mTotal11 = NULL;
	LET fCant12 = 0.00; 
	LET cDenominacion12 = '';
	LET mTotal12 = NULL;
	LET fCant13 = 0.00; 
	LET cDenominacion13 = '';
	LET mTotal13 = NULL;
	LET fCant14 = 0.00; 
	LET cDenominacion14 = '';
	LET mTotal14 = NULL;
	LET fCant15 = 0.00; 
	LET cDenominacion15 = '';
	LET mTotal15 = NULL;
	LET cMorralla = 'MORRALLA';   
	LET cDenMorralla = '';			
	LET mTotalMorralla = NULL;    
	LET mMontoTot = NULL;
	LET cDivisa = '';
	LET cDescMoneda = '';
	LET cDescStatus = '';
	LET dFechSolicitud = ''; 
	LET cHoSolicitud = '';
	LET cUsSolicitud = '';
	LET dFechEnvio = ''; 
	LET cHoEnvio = '';
	LET cUsEnvio = '';
	LET dFechRecepcion = ''; 
	LET cHoRecepcion = '';
	LET cUsRecepcion = '';
	LET cIdStatus = ''; 
	LET dFechReversion = '';
	LET cHoReversion = ''; 
	LET cUsReversion = '';
	LET cNomSolicitud = '';
	LET cNomEnvio = '';
	LET cNomRecepcion = '';
	LET cNomReversion = '';
	LET cIndicadorUs = '';
	LET cCodTrans = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, fCant5, cDenominacion5, mTotal5, 
			fCant6, cDenominacion6, mTotal6, cMorralla, cDenMorralla, mTotalMorralla, mMontoTot, cDescMoneda, cDescStatus, dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio,
			dFechRecepcion, cHoRecepcion, cUsRecepcion, cIdStatus, cNomSolicitud, cNomEnvio, cNomRecepcion, dFechReversion, cHoReversion, cUsReversion, cNomReversion, cIndicadorUs;
		END EXCEPTION;
		
		---SET DEBUG FILE TO '/tmp/mfinis/sp_detallearchivodotacioncaja.out';
		---TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNoFolio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, fCant5, cDenominacion5, mTotal5, 
			fCant6, cDenominacion6, mTotal6, cMorralla, cDenMorralla, mTotalMorralla, mMontoTot, cDescMoneda, cDescStatus, dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio,
			dFechRecepcion, cHoRecepcion, cUsRecepcion, cIdStatus, cNomSolicitud, cNomEnvio, cNomRecepcion, dFechReversion, cHoReversion, cUsReversion, cNomReversion, cIndicadorUs;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, fCant5, cDenominacion5, mTotal5, 
			fCant6, cDenominacion6, mTotal6, cMorralla, cDenMorralla, mTotalMorralla, mMontoTot, cDescMoneda, cDescStatus, dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio,
			dFechRecepcion, cHoRecepcion, cUsRecepcion, cIdStatus, cNomSolicitud, cNomEnvio, cNomRecepcion, dFechReversion, cHoReversion, cUsReversion, cNomReversion, cIndicadorUs;
		END IF;
		
		SET LOCK MODE TO WAIT 6;

		-- Valida Folio OperaciÃ³n
		IF NOT EXISTS (SELECT * FROM bdisuc:'informix'.ss_operaciones WHERE folio_oper = pNoFolio) THEN
					   LET cCodRet = '00427'; -- El folio de operaciÃ³n no existe. Por favor verifique
					   RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, fCant5, cDenominacion5, mTotal5, 
					   fCant6, cDenominacion6, mTotal6, cMorralla, cDenMorralla, mTotalMorralla, mMontoTot, cDescMoneda, cDescStatus, dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio,
					   dFechRecepcion, cHoRecepcion, cUsRecepcion, cIdStatus, cNomSolicitud, cNomEnvio, cNomRecepcion, dFechReversion, cHoReversion, cUsReversion, cNomReversion, cIndicadorUs;
		END IF;
		
		SELECT NVL(cantidad_1,''), NVL(denominacion_1,''), NVL((cantidad_1 * denominacion_1::INTEGER),'') AS total_1,
			   NVL(cantidad_2,''), NVL(denominacion_2,''), NVL((cantidad_2 * denominacion_2::INTEGER),'') AS total_2,
			   NVL(cantidad_3,''), NVL(denominacion_3,''), NVL((cantidad_3 * denominacion_3::INTEGER),'') AS total_3,
			   NVL(cantidad_4,''), NVL(denominacion_4,''), NVL((cantidad_4 * denominacion_4::INTEGER),'') AS total_4,
			   NVL(cantidad_5,''), NVL(denominacion_5,''), NVL((cantidad_5 * denominacion_5::INTEGER),'') AS total_5,
			   NVL(cantidad_6,''), NVL(denominacion_6,''), NVL((cantidad_6 * denominacion_6::INTEGER),'') AS total_6,			
			   		
			   (NVL((cantidad_7 * denominacion_7::INTEGER),0) + NVL((cantidad_8 * denominacion_8::INTEGER),0) + NVL((cantidad_9 * denominacion_9::INTEGER),0) +
			   	NVL((cantidad_10 * denominacion_10::INTEGER),0) + NVL((cantidad_11 * denominacion_11::INTEGER),0) + NVL((cantidad_12 * denominacion_12::INTEGER),0) +
			   	NVL((cantidad_13 * denominacion_13::INTEGER),0) + NVL((cantidad_14 * denominacion_14::INTEGER),0) + NVL((cantidad_15 * denominacion_15::INTEGER),0)
			   	) AS suma_total, monto, divisa, cod_trans 		
		INTO fCant1, cDenominacion1, mTotal1,
			 fCant2, cDenominacion2, mTotal2,
			 fCant3, cDenominacion3, mTotal3,
			 fCant4, cDenominacion4, mTotal4,
			 fCant5, cDenominacion5, mTotal5,
			 fCant6, cDenominacion6, mTotal6,
			 mTotalMorralla, mMontoTot, cDivisa, cCodTrans
		FROM bdisuc:'informix'.ss_operaciones 
		WHERE folio_oper = pNoFolio;
		
		-- Asigna Morralla
		IF mTotalMorralla > 0 THEN
			LET cDenMorralla = '1';
		END IF;
		
		SELECT descripcion INTO cDescMoneda FROM bdinteg:'informix'.si_divisas WHERE divisa = cDivisa;
		
		SELECT fecha_solicitud, hora_solicitud, usuario_solicitud, fecha_envio, hora_envio, usuario_envio, fecha_recepcion, hora_recepcion, usuario_recepcion, status, fecha_reversion, hora_reversion, usuario_reversion
		INTO dFechSolicitud, cHoSolicitud, cUsSolicitud, dFechEnvio, cHoEnvio, cUsEnvio, dFechRecepcion, cHoRecepcion, cUsRecepcion, cIdStatus, dFechReversion, cHoReversion, cUsReversion
		FROM bdisuc:'informix'.ss_mae_entradasalida where folio_oper = pNoFolio;
	
		-- Valida Recepcion
		IF dFechRecepcion IS NULL AND cHoRecepcion IS NULL AND cUsRecepcion IS NULL THEN
			IF dFechReversion IS NULL AND cHoReversion IS NULL AND cUsReversion IS NULL THEN
				LET cIndicadorUs = '0'; --Muestra Ninguno
			ELSE 
				LET cIndicadorUs = '2'; --Muestra ReversiÃ³n
			END IF;
		ELSE 
			LET cIndicadorUs = '1';     --Muestra RecepciÃ³n
		END IF;	
	
		SELECT descripcion INTO cDescStatus FROM bdisuc:'informix'.ss_catstatus WHERE status = cIdStatus;
	
		SELECT nombre INTO cNomSolicitud FROM bdinteg:'informix'.si_ejecut WHERE ejecutivo = cUsSolicitud;
		SELECT nombre INTO cNomEnvio FROM bdinteg:'informix'.si_ejecut WHERE ejecutivo = cUsEnvio;
		SELECT nombre INTO cNomRecepcion FROM bdinteg:'informix'.si_ejecut WHERE ejecutivo = cUsRecepcion;
		SELECT nombre INTO cNomReversion FROM bdinteg:'informix'.si_ejecut WHERE ejecutivo = cUsReversion;
			
		RETURN cCodRet, fCant1, cDenominacion1, mTotal1, fCant2, cDenominacion2, mTotal2, fCant3, cDenominacion3, mTotal3, fCant4, cDenominacion4, mTotal4, fCant5, cDenominacion5, mTotal5, 
		fCant6, cDenominacion6, mTotal6, UPPER(cMorralla), cDenMorralla, mTotalMorralla, mMontoTot, NVL(UPPER(cDescMoneda),''), UPPER(cDescStatus), NVL(dFechSolicitud,''), NVL(cHoSolicitud,''), NVL(cUsSolicitud,''), NVL(dFechEnvio,''), NVL(cHoEnvio,''), NVL(cUsEnvio,''),
		NVL(dFechRecepcion,''), NVL(cHoRecepcion,''), NVL(cUsRecepcion,''), NVL(cIdStatus,''), UPPER(cNomSolicitud), UPPER(cNomEnvio), UPPER(cNomRecepcion), NVL(dFechReversion,''), NVL(cHoReversion,''), NVL(cUsReversion,''), UPPER(cNomReversion), cIndicadorUs;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 18/02/2015',
'DESCRIPCION: SPL, que hace la consulta para el llenado de la pantalla modal Detalle de la OperaciÃ³n, EnvÃ­o de Archivos Dotaciones Sucursales Caja General',
'FUNCIONALIDAD: EnvÃ­o de Archivos Dotaciones Sucursales Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_detalledenoarqueosucaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdPlazaArq CHAR(3), pIdSucursalArq CHAR(4), pFechaArq DATE, pIdCajeroPrincArq CHAR(8))
		
		RETURNING CHAR(5) AS codret,
			DECIMAL(10,2) AS dCantidad1,
			DECIMAL(10,2) AS dCantidad2,
			DECIMAL(10,2) AS dCantidad3,
			DECIMAL(10,2) AS dCantidad4,
			DECIMAL(10,2) AS dCantidad5,
			DECIMAL(10,2) AS dCantidad6,
			DECIMAL(10,2) AS dCantidad7,
			MONEY(14,2) AS mCantTotal1,
			MONEY(14,2) AS mCantTotal2,
			MONEY(14,2) AS mCantTotal3,
			MONEY(14,2) AS mCantTotal4,
			MONEY(14,2) AS mCantTotal5,
			MONEY(14,2) AS mCantTotal6,
			MONEY(14,2) AS mCantTotal7,
			MONEY(14,2) AS mMontoTotal;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		
		DEFINE dCantidad1 DECIMAL(10,2);
		DEFINE dCantidad2 DECIMAL(10,2);
		DEFINE dCantidad3 DECIMAL(10,2);
		DEFINE dCantidad4 DECIMAL(10,2);
		DEFINE dCantidad5 DECIMAL(10,2);
		DEFINE dCantidad6 DECIMAL(10,2);
		DEFINE dCantidad7 DECIMAL(10,2);
		DEFINE mCantTotal1 MONEY(14,2);
		DEFINE mCantTotal2 MONEY(14,2);
		DEFINE mCantTotal3 MONEY(14,2);
		DEFINE mCantTotal4 MONEY(14,2);
		DEFINE mCantTotal5 MONEY(14,2);
		DEFINE mCantTotal6 MONEY(14,2);
		DEFINE mCantTotal7 MONEY(14,2);
		DEFINE mMontoTotal MONEY(14,2); 
        DEFINE iNoRegistros INTEGER; 
		DEFINE cCmd1 CHAR(1000);
		DEFINE cCmd2 CHAR(500);
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		
		LET dCantidad1 = 0.00;
		LET dCantidad2 = 0.00;
		LET dCantidad3 = 0.00;
		LET dCantidad4 = 0.00;
		LET dCantidad5 = 0.00;
		LET dCantidad6 = 0.00;
		LET dCantidad7 = 0.00;
		LET mCantTotal1 = NULL;
		LET mCantTotal2 = NULL;
		LET mCantTotal3 = NULL;
		LET mCantTotal4 = NULL;
		LET mCantTotal5 = NULL;
		LET mCantTotal6 = NULL;
		LET mCantTotal7 = NULL;
		LET mMontoTotal = NULL;
        LET iNoRegistros = 0; 
		LET cCmd1 = '';
		LET cCmd2 = '';
		
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5, dCantidad6, dCantidad7, 
					   mCantTotal1, mCantTotal2, mCantTotal3, mCantTotal4, mCantTotal5, mCantTotal6, mCantTotal7, mMontoTotal;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_detalledenoarqueosucaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pIdPlazaArq = '' OR pFechaArq IS NULL OR pIdCajeroPrincArq = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5, dCantidad6, dCantidad7, 
					   mCantTotal1, mCantTotal2, mCantTotal3, mCantTotal4, mCantTotal5, mCantTotal6, mCantTotal7, mMontoTotal;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5, dCantidad6, dCantidad7, 
					   mCantTotal1, mCantTotal2, mCantTotal3, mCantTotal4, mCantTotal5, mCantTotal6, mCantTotal7, mMontoTotal;
			END IF;
			
			-- OBTIENE DETALLE
			IF pIdPlazaArq <> '000' AND pIdPlazaArq <> '' THEN	
				LET cCmd2 = " AND plaza_cajagen = '"|| pIdPlazaArq ||"')";
			ELSE
				LET cCmd2 = ") AND sal.fecha = '"|| pFechaArq ||"'";
			END IF;
			
			IF pIdSucursalArq <> '0000' AND pIdSucursalArq <> '' THEN
				LET cCmd2 = ""||TRIM(cCmd2)||" AND sal.sucursal = '"|| pIdSucursalArq ||"'";
				LET cCmd2 = ""||TRIM(cCmd2)||" AND sal.fecha = '"|| pFechaArq ||"';";
			ELSE
				LET cCmd2 = ""||TRIM(cCmd2)||" AND sal.fecha = '"|| pFechaArq ||"';";
			END IF;	
			
			LET cCmd1="SELECT SUM(sal.cantidad_1) cant_1, SUM(sal.cantidad_2) cant_2, SUM(sal.cantidad_3) cant_3, SUM(sal.cantidad_4) cant_4,";
			LET cCmd1=""||TRIM(cCmd1)||" SUM(sal.cantidad_5) cant_5, SUM(sal.cantidad_6) cant_6, SUM(sal.cantidad_7) cant_7 FROM bdisuc:'informix'.ss_saldossuc sal ";
			LET cCmd1=""||TRIM(cCmd1)||" INNER JOIN bdinteg:'informix'.si_sucursales suc ON sal.sucursal = suc.sucursal";
			LET cCmd1=""||TRIM(cCmd1)||" INNER JOIN bdinteg:'informix'.si_plazas_cajagen pla ON suc.plaza_cajagen = pla.codigo_plaza";
			LET cCmd1=""||TRIM(cCmd1)||" AND sal.cajero_principal = '"|| pIdCajeroPrincArq ||"'";
			LET cCmd1=""||TRIM(cCmd1)||" AND sal.sucursal IN (SELECT sucursal FROM bdinteg:'informix'.si_sucursales WHERE empresa = '001'"||TRIM(cCmd2);
			
			PREPARE stmtId FROM TRIM(cCmd1);
			DECLARE selectQryCur CURSOR FOR stmtId;
			OPEN selectQryCur;
			FETCH selectQryCur INTO dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5, dCantidad6, dCantidad7;
			
			LET mCantTotal1 = NVL(dCantidad1,0) * 1000;
			LET mCantTotal2 = NVL(dCantidad2,0) *  500;
			LET mCantTotal3 = NVL(dCantidad3,0) *  200;
			LET mCantTotal4 = NVL(dCantidad4,0) *  100;
			LET mCantTotal5 = NVL(dCantidad5,0) *   50;
			LET mCantTotal6 = NVL(dCantidad6,0) *   20;
			LET mCantTotal7 = NVL(dCantidad7,0) *    1;
			
			LET mMontoTotal = mCantTotal1 + mCantTotal2 + mCantTotal3 + mCantTotal4 + mCantTotal5 + mCantTotal6 + mCantTotal7;
			
			WHILE(SQLCODE == 0)	
				RETURN cCodRet, NVL(dCantidad1,0), NVL(dCantidad2,0), NVL(dCantidad3,0), NVL(dCantidad4,0), NVL(dCantidad5,0), NVL(dCantidad6,0), NVL(dCantidad7,0), 
					   mCantTotal1, mCantTotal2, mCantTotal3, mCantTotal4, mCantTotal5, mCantTotal6, mCantTotal7, mMontoTotal WITH RESUME;
					   LET iNoRegistros = iNoRegistros + 1;
				FETCH selectQryCur INTO dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5, dCantidad6, dCantidad7;
			END WHILE;
			
			CLOSE selectQryCur;
			FREE selectQryCur;
			FREE stmtId;
			
			LET cCmd1 = '';
			LET cCmd2 = '';	
			
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, dCantidad1, dCantidad2, dCantidad3, dCantidad4, dCantidad5, dCantidad6, dCantidad7, 
					   mCantTotal1, mCantTotal2, mCantTotal3, mCantTotal4, mCantTotal5, mCantTotal6, mCantTotal7, mMontoTotal;
			END IF;
				
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 25/02/2015',
'DESCRIPCION: SPL que de acuerdo al id plaza y al id sucursal, realiza una consulta para obtener la cantidad disponible de cada denominaciÃ³n', 
'asÃ­ como la cantidad total correspondiente a cada una.', 
'FUNCIONALIDAD: Arqueo de Sucursales Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_generarchivodotacionescaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pArchDescarga CHAR(150), pSelectAll CHAR(1), pTipoSuc CHAR(1), pConsecutivo CHAR (30))
				
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cFolioOperacion CHAR(8);
	DEFINE cTotalRegistros CHAR(8);	
	DEFINE cSelect CHAR(1500);
	DEFINE cFrom CHAR(1500);
	DEFINE cWhere CHAR(1500);
	DEFINE cCmdSelect CHAR(6000);
	DEFINE cCmdFrom CHAR(4000);
	DEFINE cCmdWhere CHAR(2000);
	DEFINE cCmndSelect CHAR(1500);
	DEFINE cCmndFrom CHAR(1500); 
	DEFINE cCmndWhere CHAR(1500);
	DEFINE iNoRegistros INTEGER;
	
	DEFINE cValor CHAR(30);
	DEFINE d_datm CHAR(4);
	DEFINE fecha_enc CHAR(8);
	DEFINE no_consec CHAR(2);
	DEFINE no_registros CHAR(8);
	DEFINE cEncabezados CHAR(1500);
	DEFINE bInTransaction CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cFolioOperacion = '';
	LET cTotalRegistros = '';
	LET cSelect = '';
	LET cFrom = '';
	LET cWhere = '';
	LET cCmdSelect = '';
	LET cCmdFrom = '';
	LET cCmdWhere = '';
	LET cCmndSelect = '';
	LET cCmndFrom = ''; 
	LET cCmndWhere = '';
	LET iNoRegistros = 0;
	
	LET cValor = '';
	LET d_datm = '';
	LET fecha_enc = '';
	LET no_consec = '';
	LET no_registros = '';
	LET cEncabezados = '';
	LET bInTransaction = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr; 
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		---SET DEBUG FILE TO '/tmp/mfinis/sp_generarchivodotacionescaja.out';
		---TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pArchDescarga = '' OR pSelectAll = '' OR pTipoSuc = '' OR pConsecutivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		
		IF pSelectAll = '1' THEN
			UPDATE bdicnweb:'informix'.sw_cg_envioarchivos SET status = 'R' WHERE status = 'E';
		END IF;
		
		-- BUSCAMOS EL NUMERO DE REGISTROS
		LET cSelect = "SELECT COUNT(*)";
		LET cFrom = "FROM bdicnweb:'informix'.sw_cg_envioarchivos";
		LET cWhere = "WHERE status = 'R'";
		
		PREPARE reporteQry FROM TRIM(TRIM(cSelect)||" "||TRIM(cFrom)||" "||TRIM(cWhere));
		DECLARE selectCur CURSOR FOR reporteQry;
		OPEN selectCur;
		
		FETCH selectCur INTO iNoRegistros;
		
		LET cTotalRegistros = LPAD(iNoRegistros, 8, 0);
		
		CLOSE selectCur;
		FREE selectCur;
		FREE reporteQry;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		END IF;
		
		-- SE INICIA EL ARMADO DEL ENCABEZADO
		IF pTipoSuc = 'S' THEN
			LET d_datm = 'D';
		ELSE
			LET d_datm = 'DATM';
		END IF;
		
		SELECT TO_CHAR(fecha_hoy,'%d%m%Y') INTO fecha_enc FROM bdinteg:'informix'.si_fechas WHERE empresa = '001';
		
		LET cEncabezados =''||TRIM(TRIM(d_datm)||'|'||TRIM(fecha_enc)||'|'||TRIM(pConsecutivo)||'|'||TRIM(cTotalRegistros));
		
		BEGIN WORK;
		
		-- SE ACTUALIZA EL ENCABEZADO
		UPDATE bdicnweb:'informix'.sw_tr_encabezados_columnas_masivos SET encabezados = TRIM(cEncabezados)
		WHERE id_funcion = pIdFuncion;
		
		IF DBINFO('sqlca.sqlerrd2')	= 0 THEN
			ROLLBACK WORK;
			LET cCodRet = '00236'; -- 'ERROR AL PROCESAR LA SOLICITUD'
			RETURN cCodRet;
		END IF;
		
		COMMIT;

		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		FOREACH SELECT folio_operacion INTO cFolioOperacion FROM bdicnweb:'informix'.sw_cg_envioarchivos WHERE status = 'R'
			SELECT valor INTO cValor FROM bdisuc:'informix'.ss_param_cajagen WHERE codigo = '0033';
			UPDATE bdicnweb:'informix'.sw_cg_envioarchivos SET consecutivo = cValor WHERE folio_operacion = cFolioOperacion;
			UPDATE bdisuc:'informix'.ss_param_cajagen SET valor = valor + 1 WHERE codigo = '0033';
		END FOREACH;
		
		-- CONSULTA REGISTROS 	
		LET cCmdSelect =""||TRIM(cCmdSelect)||"SELECT LPAD(plazasCg.cve_sucursal, 2, '0') AS clavSucursal, LPAD(ssParamCg.consecutivo::INTEGER,10,'0') AS cValorConsecutivo,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" TO_CHAR(f.prox_fecha,'%d%m%Y') AS fecha,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" '0000000000000000' AS valor_fijo, CASE WHEN a.divisa = 'MR' THEN p.valor ELSE a.divisa END AS divisa,";							
		LET cCmdSelect =""||TRIM(cCmdSelect)||" LPAD(a.sucursal::INTEGER, 10, '0') AS sucursal, TO_CHAR((a.monto * 100), '&&&&&&&&&&&&&&&&') AS monto,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" 'N' AS diferencia, '0000000000000000' AS monto_diferencia,";				
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_1 > 0 THEN '1' ELSE '' END AS tipo_dotacion_1,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_1 > 0 THEN TO_CHAR((a.denominacion_1 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_1,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_1 > 0 THEN TO_CHAR((a.cantidad_1 * a.denominacion_1 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_1,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_2 > 0 THEN '1' ELSE '' END AS tipo_dotacion_2,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_2 > 0 THEN TO_CHAR((a.denominacion_2 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_2,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_2 > 0 THEN TO_CHAR((a.cantidad_2 * a.denominacion_2 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_2,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_3 > 0 THEN '1' ELSE '' END AS tipo_dotacion_3,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_3 > 0 THEN TO_CHAR((a.denominacion_3 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_3,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_3 > 0 THEN TO_CHAR((a.cantidad_3 * a.denominacion_3 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_3,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_4 > 0 THEN '1' ELSE '' END AS tipo_dotacion_4,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_4 > 0 THEN TO_CHAR((a.denominacion_4 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_4,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_4 > 0 THEN TO_CHAR((a.cantidad_4 * a.denominacion_4 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_4,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_5 > 0 THEN '1' ELSE '' END AS tipo_dotacion_5,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_5 > 0 THEN TO_CHAR((a.denominacion_5 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_5,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_5 > 0 THEN TO_CHAR((a.cantidad_5 * a.denominacion_5 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_5,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_6 > 0 THEN '1' ELSE '' END AS tipo_dotacion_6,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_6 > 0 THEN TO_CHAR((a.denominacion_6 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_6,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_6 > 0 THEN TO_CHAR((a.cantidad_6 * a.denominacion_6 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_6,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_7 > 0 THEN '1' ELSE '' END AS tipo_dotacion_7,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_7 > 0 THEN TO_CHAR((a.denominacion_7 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_7,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_7 > 0 THEN TO_CHAR((a.cantidad_7 * a.denominacion_7 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_7,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_8 > 0 THEN '1' ELSE '' END AS tipo_dotacion_8,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_8 > 0 THEN TO_CHAR((a.denominacion_8 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_8,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_8 > 0 THEN TO_CHAR((a.cantidad_8 * a.denominacion_8 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_8,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_9 > 0 THEN '1' ELSE '' END AS tipo_dotacion_9,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_9 > 0 THEN TO_CHAR((a.denominacion_9 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_9,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_9 > 0 THEN TO_CHAR((a.cantidad_9 * a.denominacion_9 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_9,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_10 > 0 THEN '1' ELSE '' END AS tipo_dotacion_10,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_10 > 0 THEN TO_CHAR((a.denominacion_10 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_10,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_10 > 0 THEN TO_CHAR((a.cantidad_10 * a.denominacion_10 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_10,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_11 > 0 THEN '1' ELSE '' END AS tipo_dotacion_11,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_11 > 0 THEN TO_CHAR((a.denominacion_11 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_11,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_11 > 0 THEN TO_CHAR((a.cantidad_11 * a.denominacion_11 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_11,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_12 > 0 THEN '1' ELSE '' END AS tipo_dotacion_12,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_12 > 0 THEN TO_CHAR((a.denominacion_12 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_12,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_12 > 0 THEN TO_CHAR((a.cantidad_12 * a.denominacion_12 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_12,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_13 > 0 THEN '1' ELSE '' END AS tipo_dotacion_13,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_13 > 0 THEN TO_CHAR((a.denominacion_13 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_13,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_13 > 0 THEN TO_CHAR((a.cantidad_13 * a.denominacion_13 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_13,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_14 > 0 THEN '1' ELSE '' END AS tipo_dotacion_14,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_14 > 0 THEN TO_CHAR((a.denominacion_14 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_14,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_14 > 0 THEN TO_CHAR((a.cantidad_14 * a.denominacion_14 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_14,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_15 > 0 THEN '1' ELSE '' END AS tipo_dotacion_15,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_15 > 0 THEN TO_CHAR((a.denominacion_15 * 100), '&&&&&&&') ELSE '' END AS denominacion_dotacion_15,";
		LET cCmdSelect =""||TRIM(cCmdSelect)||" CASE WHEN a.cantidad_15 > 0 THEN TO_CHAR((a.cantidad_15 * a.denominacion_15 * 100), '&&&&&&&&&&&&&&&&') ELSE '' END AS monto_denominacion_15";	
		
		LET cCmdFrom = " FROM bdisuc:'informix'.ss_operaciones AS a ";
		LET cCmdFrom =""||TRIM(cCmdFrom)||" INNER JOIN bdinteg:'informix'.si_sucursales AS b ON a.sucursal = b.sucursal ";
		LET cCmdFrom =""||TRIM(cCmdFrom)||" INNER JOIN bdinteg:'informix'.si_fechas AS f ";
		LET cCmdFrom =""||TRIM(cCmdFrom)||" INNER JOIN bdinteg:'informix'.si_param AS p ON p.cod_param = '15' ";
		LET cCmdFrom =""||TRIM(cCmdFrom)||" ON a.folio_oper IN (SELECT folio_operacion FROM bdicnweb:'informix'.sw_cg_envioarchivos WHERE status = 'R') ";
		LET cCmdFrom =""||TRIM(cCmdFrom)||" INNER JOIN bdinteg:'informix'.si_plazas_cajagen AS plazasCg ON plazasCg.codigo_plaza =  b.plaza_cajagen ";
		LET cCmdFrom =""||TRIM(cCmdFrom)||" INNER JOIN bdicnweb:'informix'.sw_cg_envioarchivos AS ssParamCg ON ssParamCg.folio_operacion = a.folio_oper; "; 
		
		UPDATE bdisuc:'informix'.ss_mae_entradasalida SET status = '11' WHERE folio_oper IN (SELECT folio_operacion FROM bdicnweb:'informix'.sw_cg_envioarchivos WHERE status = 'R');
		
		SYSTEM TRIM('/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||' '||TRIM(cCmdSelect)||' '||TRIM(cCmdFrom)||' " | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1');
		
		-- SE COLOCA EL ENCABEZADO
		EXECUTE PROCEDURE bdicnweb:'informix'.sp_obtieneencabezadomasivo(pIdFuncion, pArchDescarga) INTO cCodRetSp;
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, '';
		END IF;
		
		RETURN cCodRet;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 02/03/2015',
'DESCRIPCION: SPL, que genera el reporte de envio de archivo dotaciones sucursales',
'FUNCIONALIDAD: EnvÃ­o de Archivos Dotaciones Sucursales Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mantolineacre_masivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INTEGER, pIdPlantilla CHAR(25), pTituloPlantilla CHAR(255))
	RETURNING CHAR(5) AS codret,
			INTEGER AS registros_procesados;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE iNoRegistros INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE iRegistrosExitosos INTEGER;
	DEFINE iRegistrosFallidos INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCuenta CHAR(20);
	DEFINE mMontoNuevaLinea MONEY(18,2);
	DEFINE cResultado CHAR(15);
	DEFINE cStatus CHAR(1);
	DEFINE cMotivoRechazo CHAR(80);
	DEFINE mSaldoCuenta MONEY(14,2);
	DEFINE cCodRetSpSal CHAR(5);
	DEFINE dFechaProceso DATETIME YEAR TO FRACTION(3);
	DEFINE iIdRegistro INTEGER;
	DEFINE cFechaCargaLote DATE;
	DEFINE iTotalRegsLote INTEGER;
	DEFINE mMontoLote MONEY(14, 2);
	DEFINE iRegsAceptadosLote INTEGER;
	DEFINE iRegsRechazoLote INTEGER;
	DEFINE cArchivo CHAR(150);
	DEFINE cStatusLote CHAR(1);
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cMensajeRetorno = '';
	LET iNoRegistros = 0;
	LET iExiste = 0;
	LET iCodRetSp = 0;
	LET iRegistrosExitosos = 0;
	LET iRegistrosFallidos = 0;
	LET cEmpresa = '001';
	LET cCuenta = '';
	LET mMontoNuevaLinea = NULL;
	LET cResultado = '';
	LET cStatus = '';
	LET cMotivoRechazo = '';
	LET mSaldoCuenta = NULL;
	LET cCodRetSpSal = '';
	LET dFechaProceso = NULL;
	LET iIdRegistro = 0;
	LET cFechaCargaLote = NULL;
	LET iTotalRegsLote = 0;
	LET mMontoLote = NULL;
	LET iRegsAceptadosLote = 0;
	LET iRegsRechazoLote = 0;
	LET cArchivo = '';
	LET cStatusLote = '';
	LET dHoy = NULL;
	LET bInTransaction = 'f';
	

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
				
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mantolineacre_masivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACIION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- BUSQUEDA DEL LOTE		
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(id_registro)
		INTO iExiste
		FROM 
			(SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito
			WHERE lote = pLote
			UNION
			SELECT id_registro
			FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito_hist
			WHERE lote = pLote);
			
		IF iExiste = 0 THEN
			LET cCodRet = '00200';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- Se actualiza el estatus de los registros
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_mantolineascredito
			SET status = 'P',
				fecha_proceso = current
			WHERE lote = pLote AND status = 'C';
		COMMIT;
			
		-- ACTUALIZACIÃN DEL ESTATUS DEL LOTE
		BEGIN WORK;
			UPDATE bdicnweb:'informix'.sw_tr_totales_masivo
			SET status_lote = 'P'
			WHERE id_lote = pLote AND id_funcion = pIdFuncion AND usuario = pIdFuncion;
		COMMIT;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH WITH HOLD SELECT id_registro, cuenta, monto_linea_nuevo
			INTO iIdRegistro, cCuenta, mMontoNuevaLinea
			FROM bdicnweb:'informix'.sw_tr_cargamasiva_mantolineascredito
			WHERE lote = pLote
				AND usuario = pUsuario
				AND status = 'P'
                        BEGIN
			ON EXCEPTION IN (-255)
			END EXCEPTION WITH RESUME;
			
				EXECUTE PROCEDURE bdicred:"informix".sp_actualiza_lincred_central(cEmpresa, cCuenta, mMontoNuevaLinea, 'A', '1', pUsuario)
				INTO cCodRetSp, cMensajeRetorno;
			
			COMMIT;
			END;

			BEGIN WORK;
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_actualiza_lincred_central (PROC MASIVO)';
				ELIF iCodRetSp = 0 THEN
					LET cResultado = 'APLICADO';
					LET cStatus = 'S';
					LET iRegistrosExitosos = iRegistrosExitosos + 1;
					LET cMotivoRechazo = NULL;
				ELIF iCodRetSp <> 0 THEN
					LET cResultado = 'NO APLICADO';
					LET cStatus = 'P';
					LET iRegistrosFallidos = iRegistrosFallidos + 1;
					LET cMotivoRechazo = cMensajeRetorno;
				END IF;
				
				LET dFechaProceso = CURRENT;
			
				-- ACTUALIZACIÃN DE LA TABLA
				UPDATE 'informix'.sw_tr_cargamasiva_mantolineascredito
				SET fecha_proceso = dFechaProceso,
					status = cStatus,
					resultado = UPPER(cResultado),
					codret_proceso = cCodRetSp,
					motivo_rechazo = UPPER(NVL(cMotivoRechazo, ''))
				WHERE id_registro = iIdRegistro;
				
				IF iCodRetSp = 0 THEN
					INSERT INTO bdicnweb:'informix'.sw_tr_cargamasiva_mantolineascredito_hist
					SELECT * FROM bdicnweb:'informix'.sw_tr_cargamasiva_mantolineascredito WHERE id_registro = iIdRegistro;
				END IF;
				
				LET iNoRegistros = iNoRegistros + 1;
			COMMIT WORK;
			
			CONTINUE FOREACH;
			
		END FOREACH;
		
		-- Actualizamos el estatus en la tabla de los resumenes masivos
		EXECUTE PROCEDURE "informix".sp_totaleslineascredito(pUsuario, pIdFuncion, pLote)
		INTO cCodRetSp, cFechaCargaLote, iTotalRegsLote, mMontoLote, iRegsAceptadosLote, iRegsRechazoLote, cArchivo, cStatusLote;
		
		SELECT COUNT(id_registro)
		INTO iRegsRechazoLote
		FROM bdicnweb:sw_tr_cargamasiva_mantolineascredito 
		WHERE lote = pLote AND (codret_proceso::INTEGER <> 0 OR status = 'E');
		
		BEGIN WORK;

			UPDATE bdicnweb:"informix".sw_tr_totales_masivo
			SET status_lote = 'T',
				registros_rechazados = iRegsRechazoLote,
				registros_aceptados = iTotalRegsLote - (iRegsRechazoLote)
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
			
		COMMIT WORK;
			
		BEGIN WORK;
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			DELETE FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito WHERE status = 'S' and lote = pLote and codret_proceso::INTEGER = 0;
		COMMIT WORK;
		
		BEGIN;
			UPDATE bdicnweb:sw_tr_cargamasiva_mantolineascredito
			SET status = 'C'
			WHERE lote = pLote AND status = 'U';
		COMMIT;
		
		-- NotificaciÃ³n de correo electrÃ³nico
		-- Se llama al procedimiento del registro del event
		LET dHoy = current;
		EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
			'1', 
			TRIM(pIdPlantilla), 
			pUsuario, 
			'',
			'', 
			'1', 
			pLote,
			NVL(iTotalRegsLote, 0),
			TRIM(TO_CHAR(NVL(mMontoLote, 0.00), "#,###,###,###,###.##")),
			'',
			'',
			'',
			'',
			'',
			'',
			TRIM(pTituloPlantilla),
			'',
			'',
			'0',
			'0',
			'0',
			'0',
			'0',
			dHoy,
			dHoy) INTO cCodRetSp;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 30/04/2014',
'DESCRIPCION: Aumento/DisminuciÃ³n de lineas de credito, proceso masivo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reportemantolineasmasivocre(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre char(10), pFechaInicio date, pFechaFin date, 
        pArchDescarga CHAR(150), pLote int, pUsuarioC char(8))
        returning CHAR(5) as codret;
        
        DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iExiste INT;
        DEFINE cCmd1 CHAR(1500);
        DEFINE cCmd2 CHAR(1500);
        DEFINE cCmd3 CHAR(1500);
        DEFINE cCmd4 CHAR(1500);
        DEFINE cUser CHAR(8);
        
        LET cCodRet = '00000';
		LET cCodRet = '';
        LET iSqlErr = 0;
        LET iExiste = 0;
        LET cCmd1 = '';
        LET cCmd2 = '';
        LET cCmd3 = '';
        LET cCmd4 = '';
        LET cUser = pIdUsuario;
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet;
			END EXCEPTION;
			
			--SET DEBUG FILE TO '/tmp/mfinis/sp_reportemantolineasmasivocre.out';
			--TRACE ON;
			
			IF pIdUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pArchDescarga = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet;
			END IF;
			
			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet;
			END IF;
			
			LET cCmd1 = "select id_registro";
			LET cCmd2 = " from (((bdicnweb:sw_tr_cargamasiva_mantolineascredito a left join bdicred:sd_maecred b on b.num_credito = a.cuenta) left join bdinteg:si_sucursales c on c.sucursal = b.sucursal) left join bdicred:sd_definicion d on d.num_producto = b.num_producto) left join bdicred:sd_tipocartera e on e.status_cred = b.status_cred left join bdicred:sd_indicador_cred f on f.num_credito = b.num_credito where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(a.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
			IF pLote IS NOT NULL THEN
					LET cCmd2 = " "||TRIM(cCmd2)||" AND lote = "||pLote;
			END IF;
			IF pUsuarioC <> '' THEN
					LET cCmd2 = " "||TRIM(cCmd2)||" AND usuario = '"||TRIM(pUsuarioC)||"'";
					LET cUser = pUsuarioC;
			END IF;
			IF pLote IS NULL OR pUsuarioC = '' THEN
					LET cCmd2 = " "||TRIM(cCmd2)||" AND lote in (select id_lote from bdicnweb:sw_tr_totales_masivo where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(fecha_carga) between '"||pFechaInicio||"' and '"||pFechaFin||"' and usuario = '"||TRIM(cUser)||"')";
			END IF;
			
			LET cCmd3 = "select id_registro";
			LET cCmd4 = " from (((bdicnweb:sw_tr_cargamasiva_mantolineascredito_hist a left join bdicred:sd_maecred b on b.num_credito = a.cuenta) left join bdinteg:si_sucursales c on c.sucursal = b.sucursal) left join bdicred:sd_definicion d on d.num_producto = b.num_producto) left join bdicred:sd_tipocartera e on e.status_cred = b.status_cred left join bdicred:sd_indicador_cred f on f.num_credito = b.num_credito where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(a.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
			IF pLote IS NOT NULL THEN
					LET cCmd4 = " "||TRIM(cCmd4)||" AND lote = "||pLote;
			END IF;
			IF pUsuarioC <> '' THEN
					LET cCmd4 = " "||TRIM(cCmd4)||" AND usuario = '"||TRIM(pUsuarioC)||"'";
					LET cUser = pUsuarioC;
			END IF;
			IF pLote IS NULL OR pUsuarioC = '' THEN
					LET cCmd4 = " "||TRIM(cCmd4)||" AND lote in (select id_lote from bdicnweb:sw_tr_totales_masivo where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(fecha_carga) between '"||pFechaInicio||"' and '"||pFechaFin||"' and usuario = '"||TRIM(cUser)||"')";
			END IF;
			
			PREPARE lotesQry FROM "select count(*) from ("||TRIM(TRIM(cCmd1)||cCmd2)||" UNION "||TRIM(TRIM(cCmd3)||cCmd4)||")";
			DECLARE lotesCur CURSOR FOR lotesQry;
			OPEN lotesCur;
			
			FETCH lotesCur INTO iExiste;
			
			CLOSE lotesCur;
			FREE lotesCur;
			FREE lotesQry;
			
			IF iExiste = 0 THEN
					LET cCodRet = '00151';
					RETURN cCodRet;
			END IF;
			
			LET cCmd1 = "select a.id_registro, a.lote, nvl(a.numcte, '') as numcte, nvl(a.nombre_cliente, '') as nombre_cliente, a.cuenta, TRIM(TRIM(b.sucursal)||' '||TRIM(c.nombre)) as sucursal, TRIM(TRIM(b.num_producto)||' '||TRIM(d.nombre_prod)) as producto, TRIM(NVL(e.descripcion, '')) as status_cuenta, NVL(TO_CHAR(fecha_ultimo_pago, '%d/%m/%Y'), '') AS fecha_ult_movto, NVL(a.resultado, '') AS resultado, NVL(a.codret_proceso, '') as cod_retorno, UPPER(NVL(motivo_rechazo, '')) as motivo_rechazo, NVL(TO_CHAR(monto_linea_actual, '#,###,###,###,###,##&.&&'), '') as monto_linea_actual, NVL(TO_CHAR(monto_linea_nuevo, '#,###,###,###,###,##&.&&'), '') as monto_linea_nuevo, NVL(TO_CHAR(fecha_proceso, '%d/%m/%Y'), '') as fecha_movimiento, NVL(TO_CHAR(fecha_carga, '%d/%m/%Y'), '') as fecha_operacion";
			LET cCmd3 = "lote, trim(numcte), trim(nombre_cliente), trim(cuenta), trim(sucursal), trim(producto), trim(status_cuenta), fecha_ult_movto, trim(resultado), trim(cod_retorno), trim(motivo_rechazo), monto_linea_actual, monto_linea_nuevo, fecha_movimiento, fecha_operacion";
			
			SYSTEM TRIM('/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||' select '||TRIM(cCmd3)||' from ('||TRIM(TRIM(cCmd1)||cCmd2)||' UNION '||TRIM(TRIM(cCmd1)||cCmd4)||') order by id_registro;" | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1');
			
			-- EjecuciÃ³n del SP para la carga de los encabezados
			EXECUTE PROCEDURE bdicnweb:'informix'.sp_obtieneencabezadomasivo(pIdFuncionPadre, pArchDescarga) INTO cCodRetSp;
			IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, '';
			END IF;
			
			RETURN cCodRet;
        END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Generacion del reporte del aumento/disminuciÃ³n de lineas de credito de la aplicacion CNWEB",
"FECHA: 23/03/2014",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_reversardotacioncaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFolioOperacion CHAR(8), pRespuesta CHAR(1))
				
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistrosAfectados INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRegistrosAfectados = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr; 
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reversardotacioncaja.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFolioOperacion = '' OR pRespuesta = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet; 
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet; 
		END IF;
	
		IF pRespuesta = 'S' THEN
			-- Actualiza tablas
			UPDATE bdisuc:'informix'.ss_operaciones SET reversado = '1' WHERE folio_oper = pFolioOperacion;
			
			UPDATE bdisuc:'informix'.ss_mae_entradasalida SET hora_reversion = to_char(CURRENT, '%H:%m'), fecha_reversion = date(CURRENT), 
			usuario_reversion = pUsuario, status = '08' WHERE folio_oper = pFolioOperacion;
			
			LET iRegistrosAfectados = DBINFO('sqlca.sqlerrd2');
		ELSE 
			-- Regresa foco a pantalla
			LET iRegistrosAfectados = DBINFO('sqlca.sqlerrd2');
		END IF;
             
		-- ERROR AL ACTUALIZAR EL REGISTRO
		IF iRegistrosAfectados = 0 THEN
				LET cCodRet = '00283';
		END IF;

		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 09/02/2015',
'DESCRIPCION: SPL, que hace la actualizaciÃ³n de datos a las tablas ss_operaciones y ss_mae_entradasalida cuando se aplica la reversiÃ³n, EnvÃ­o Dotaciones Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesentradasalidacaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(1), pIdSucursal CHAR(4), 
			pIdPlaza CHAR(3), pFechaInic DATE, pFechaFin DATE, pMes CHAR(2), pAnio CHAR(4), pIdStatus CHAR(2))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS totalRegistros;

		DEFINE cCodRet CHAR(5);
		DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE cEmpresa CHAR(3);
		DEFINE iTotalRegistros_S INTEGER;
		DEFINE iTotalRegistros_C INTEGER;
		DEFINE iTotalRegistros INTEGER;
			
		LET cCodRet = '00000';
		LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cEmpresa = '001';
		LET iTotalRegistros_S = 0;
		LET iTotalRegistros_C = 0;
		LET iTotalRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, iTotalRegistros;
            END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesentradasalidacaja.out';
            --TRACE ON;
			
            IF pUsuario = '' OR pIdFuncion = '' OR pIdPlaza = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
            END IF;
                        
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros;
            END IF;
			
			IF pTipoSucursal = 'S' OR pTipoSucursal = 'C' THEN
			
				FOREACH	EXECUTE PROCEDURE bdisuc:'informix'.sp_entrada_salida2_total(cEmpresa, pTipoSucursal, pIdSucursal, pIdPlaza, pFechaInic, pFechaFin, pMes, pAnio, pIdStatus)
					INTO cCodRetSp, iTotalRegistros
					
					IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_entrada_salida2_total';
					ELIF cCodRetSp::INTEGER = 0 THEN 
						RETURN cCodRet, iTotalRegistros;
					END IF;
				END FOREACH;
			
			ELIF pTipoSucursal = 'A' THEN
			
				LET pTipoSucursal = 'S';
				IF pTipoSucursal = 'S' THEN
					FOREACH	EXECUTE PROCEDURE bdisuc:'informix'.sp_entrada_salida2_total(cEmpresa, pTipoSucursal, pIdSucursal, pIdPlaza, pFechaInic, pFechaFin, pMes, pAnio, pIdStatus)
						INTO cCodRetSp, iTotalRegistros_S
						
						IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
							RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_entrada_salida2_total';
						END IF;
					END FOREACH;
						
				END IF;
				
				LET pTipoSucursal = 'C';
				IF pTipoSucursal = 'C' THEN
					FOREACH	EXECUTE PROCEDURE bdisuc:'informix'.sp_entrada_salida2_total(cEmpresa, pTipoSucursal, pIdSucursal, pIdPlaza, pFechaInic, pFechaFin, pMes, pAnio, pIdStatus)
						INTO cCodRetSp, iTotalRegistros_C
						
						IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
							RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_entrada_salida2_total';
						END IF;
					END FOREACH;
						
				END IF;
				
				LET iTotalRegistros = (iTotalRegistros_S + iTotalRegistros_C);		
				RETURN cCodRet, iTotalRegistros;
			
			END IF;
			
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			END IF;
		
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 23/01/2015',
'DESCRIPCION: SPL que consulta el total de registros para el llenado del grid Listado de registros y detalle de saldo por plaza, Consultas Entrada Salida Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totaleslineascredito(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT)
	RETURNING CHAR(5) AS codret,
			DATE AS fecha_carga,
			INT AS total_registros,
			MONEY(14,2) AS total_monto,
			INT AS registros_aceptados,
			INT AS registros_rechazados,
			CHAR(150) AS nombre_archivo,
			CHAR(1) AS status_lote;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE dFechaCarga DATETIME YEAR TO FRACTION(3);
	DEFINE iTotalRegistros INT;
	DEFINE mTotalMonto money(14,2);
	DEFINE iTotalRegistrosAceptados INT;
	DEFINE iTotalRegistrosRechazados INT;
	DEFINE iExiste int;
	DEFINE cNombreEjecutivo char(45);
	DEFINE cNombreArchivoCarga char(150);
	DEFINE cSistemaCuenta char(2);
	DEFINE cStatusLote CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dFechaCarga = NULL;
	LET iTotalRegistros = 0;
	LET mTotalMonto = NULL;
	LET iTotalRegistrosAceptados = 0;
	LET iTotalRegistrosRechazados = 0;
	LET iExiste = 0;
	LET cNombreEjecutivo = '';
	LET cNombreArchivoCarga = '';
	LET cSistemaCuenta = '';
	LET cStatusLote = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END EXCEPTION;
		
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_totalesdesbloqueocre.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pLote = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
		
		-- Buscamos en la tabla de lotes
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(*)
		INTO iExiste
		FROM bdicnweb:"informix".sw_tr_totales_masivo
		WHERE id_lote = pLote AND id_funcion = pIdFuncion;
		
		-- Buscamos el lote en la tabla de las cargas masivas
		IF iExiste = 0 THEN
			SELECT COUNT(id_registro)
			INTO iExiste
			FROM 
				(SELECT id_registro
				FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito
				WHERE lote = pLote
				UNION
				SELECT id_registro
				FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito_hist
				WHERE lote = pLote);
			
			IF iExiste = 0 THEN
				let cCodRet = '00200';
				RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
			END IF;
			
			LET iExiste = 0;
		END IF;
		
		IF iExiste = 0 THEN
			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(id_funcion) 
			INTO iTotalRegistrosAceptados
			FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito
			WHERE lote = pLote AND status = 'C';

			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(id_funcion)
			INTO iTotalRegistrosRechazados
			FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito
			WHERE lote = pLote AND status <> 'C';

			SET ISOLATION TO DIRTY READ;
			
			SELECT cm.archivo, cm.fecha_carga
				, COUNT(cm.fecha_carga) AS total_registros
				, SUM(monto_linea_nuevo) AS total_monto
			INTO cNombreArchivoCarga, dFechaCarga, iTotalRegistros, mTotalMonto
			FROM bdicnweb:"informix".sw_tr_cargamasiva_mantolineascredito cm
			WHERE cm.lote = pLote		
			GROUP BY cm.archivo, cm.fecha_carga;
			
			-- GUARDAMOS LOS DATOS DEL LOTE EN LA TABLA DE LOTES
			-- Busqueda del nombre del ejecutivo
			SET ISOLATION TO DIRTY READ;
			SELECT nombre
			INTO cNombreEjecutivo
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = pIdUsuario;
			
			LET cSistemaCuenta = '06';
			LET cStatusLote = 'C';
			INSERT INTO bdicnweb:"informix".sw_tr_totales_masivo (id_lote, usuario, nombre_ejecutivo, nombre_archivo, fecha_carga, sistema_cuenta, total_registros, 
																total_monto, registros_aceptados, registros_rechazados, id_funcion)
			VALUES (pLote, pIdUsuario, cNombreEjecutivo, cNombreArchivoCarga, dFechaCarga, cSistemaCuenta, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, pIdFuncion);
			
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		ELSE
			SELECT fecha_carga, total_registros, total_monto, registros_aceptados, registros_rechazados, nombre_archivo, sistema_cuenta, status_lote
			INTO dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cSistemaCuenta, cStatusLote
			FROM bdicnweb:"informix".sw_tr_totales_masivo
			WHERE id_lote = pLote AND id_funcion = pIdFuncion;
			
			RETURN cCodRet, dFechaCarga, iTotalRegistros, mTotalMonto, iTotalRegistrosAceptados, iTotalRegistrosRechazados, cNombreArchivoCarga, cStatusLote;
		END IF;
	
	END;
END PROCEDURE
DOCUMENT "Autor: M.C. Oscar Flores Conde",
"Fecha de creaciÃ³n: 11/07/2013",
"DescripciÃ³n: Procedimiento que consulta el total de registros de un lote cargado, asÃ­ como el nÃºmero de registros cargados correctamente,",
"             el nÃºmero de regitros erroneos, el monto total de la cargas y la fecha de carga, el SP funciona para el masivo de deposito y retiro de captaciÃ³n";

CREATE PROCEDURE "informix".sp_totalesmonitorefectivocaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodProveedor CHAR(4))
					
		RETURNING CHAR(5) AS codret, 
			INTEGER AS totalRegistros;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;		
		DEFINE cEmpresa CHAR(3);
		DEFINE iTotalRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET iTotalRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, iTotalRegistros;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesmonitorefectivocaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pCodProveedor = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros; 
			END IF;
			
			SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;			
			
			FOREACH
				EXECUTE PROCEDURE bdisuc:'informix'.consultacajageneral2_totales('001', pCodProveedor)
				INTO cCodRetSp, iTotalRegistros					 
					 
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:consultacajageneral2_totales';
				ELIF cCodRetSp::INTEGER = 101 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, iTotalRegistros; 
				END IF;
			END FOREACH;
			
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			ELSE
				RETURN cCodRet, iTotalRegistros;
			END IF;

		END;		

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 30/03/2015',
'DESCRIPCION: SPL que obtiene el nÃºmero total de registros del detalle de las cajas generales consultadas.',
'FUNCIONALIDAD: Monitor de Efectivo Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesmonitoroperacionescaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSucursal CHAR(2), pIdSucursal CHAR(4), 
			pIdMostrar CHAR(4), pFechaInic DATE, pFechaFin DATE, pIdProvCaja CHAR(4))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS totalRegistros;

		DEFINE cCodRet CHAR(5);
		DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE cEmpresa CHAR(3);
		DEFINE iTotalRegistros INTEGER;
			
		LET cCodRet = '00000';
		LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cEmpresa = '001';
		LET iTotalRegistros = 0;
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, iTotalRegistros;
            END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesmonitoroperacionescaja.out';
            --TRACE ON;
			
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' OR pFechaInic IS NULL OR pFechaFin IS NULL  OR pIdProvCaja = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
            END IF;
                        
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros;
            END IF;
			
			--SET ISOLATION TO DIRTY READ;	
			FOREACH EXECUTE PROCEDURE bdisuc:'informix'.sp_monitor_operaciones2_total(cEmpresa, pTipoSucursal, pIdSucursal, pIdMostrar, pFechaInic, pFechaFin, pIdProvCaja)
					INTO cCodRetSp, iTotalRegistros
					
					IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_monitor_operaciones2_total';
					ELIF cCodRetSp::INTEGER = 0 THEN 
						RETURN cCodRet, iTotalRegistros;
					END IF;
			END FOREACH;
			
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			END IF;
		
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 12/01/2015',
'DESCRIPCION: SPL que consulta el total de registros para el llenado del grid Transacciones, Monitor de Operaciones Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesoperacionescaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pNoFolio CHAR(8), pIdSucursal CHAR(4), pCodTransaccion CHAR(4), 
			pTipoConsulta CHAR(1), pIdCajaGen CHAR(4), pTipoSucursal CHAR(1), pFechaInic DATE, pFechaFin DATE)
		
		RETURNING CHAR(5) AS codret,               		
			INTEGER AS totalRegistros;	
			
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
        DEFINE cEmpresa CHAR(3);
		DEFINE iTotalRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
        LET cEmpresa = '001';
        LET iTotalRegistros = 0;

		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, iTotalRegistros;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesoperacionescaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoSucursal = '' OR pTipoConsulta = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros;
			END IF;
			
			SET LOCK MODE TO WAIT 6;
			SET ISOLATION TO DIRTY READ;
		
			IF pIdCajaGen = '0000' AND pTipoConsulta = '5' THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			END IF;
		
			FOREACH	EXECUTE PROCEDURE bdisuc:'informix'.sp_consul_operaciones2_totales(cEmpresa, pFechaInic, pFechaFin, pNoFolio, pIdSucursal, pCodTransaccion, pTipoConsulta, pIdCajaGen, pTipoSucursal)
				INTO cCodRetSp, iTotalRegistros		
				
				IF cCodRetSp::INTEGER < 0 THEN -- Hubo una excepcion
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_consul_operaciones2_totales';
				ELIF cCodRetSp::INTEGER = 001 THEN
					LET cCodRet = '00003';
					RETURN cCodRet, iTotalRegistros;
				ELSE
					RETURN cCodRet, iTotalRegistros;	
				END IF;
			END FOREACH;
			
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			END IF;	
				
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 11/02/2015',
'DESCRIPCION: SPL que consulta el total de registros para el llenado del grid Operaciones Realizadas, Consulta Operaciones Caja General',
'MODULO: Caja general',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesucabrieroncaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta DATE)
		
		RETURNING CHAR(5) AS codret,
			INTEGER AS totalRegistros;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE iTotalRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET iTotalRegistros = 0;
		
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, iTotalRegistros;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesucabrieroncaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta = '' OR pFechaConsulta IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros;
			END IF;
			
			SELECT COUNT(*) INTO iTotalRegistros
			FROM bdisuc:'informix'.ss_pase_sucursal AS sal, bdinteg:'informix'.si_sucursales AS suc 
			WHERE sal.sucursal = suc.sucursal AND suc.tpo_sucursal = 'S' AND sal.fecha_pase = pFechaConsulta;
			
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			ELSE 
				RETURN cCodRet, iTotalRegistros;
			END IF;
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/03/2015',
'DESCRIPCION: SPL que consulta el nÃºmero total de registros de las sucursales que abrieron.',
'FUNCIONALIDAD: Sucursales No Abiertas Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesucnoabrieroncaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaConsulta DATE)
		
		RETURNING CHAR(5) AS codret,
			INTEGER AS totalRegistros;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE dFechaAnterior DATE;
		DEFINE sSucursal CHAR(4);
		DEFINE iContPase INTEGER;
		DEFINE iTotalRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET dFechaAnterior = '';
		LET sSucursal = '';
		LET iContPase = 0;
		LET iTotalRegistros = 0;
		
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, iTotalRegistros;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesucnoabrieroncaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFechaConsulta = '' OR pFechaConsulta IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros;
			END IF;
			
			-- SE CALCULA LA FECHA ANTERIOR
			LET dFechaAnterior = DATE(pFechaConsulta) -1;
		 
			FOREACH 
				SELECT DISTINCT NVL(sal.sucursal,'') INTO sSucursal
				FROM bdisuc:'informix'.ss_saldossuc AS sal INNER JOIN bdinteg:'informix'.si_sucursales AS suc 
				ON sal.sucursal = suc.sucursal AND suc.tpo_sucursal = 'S' AND sal.fecha = dFechaAnterior
			
				SELECT COUNT (*) INTO iContPase
				FROM bdisuc:ss_pase_sucursal WHERE fecha_pase = pFechaConsulta AND sucursal = sSucursal;
				
				IF iContPase = 0 THEN
					SELECT COUNT(*) INTO iTotalRegistros
					FROM bdisuc:'informix'.ss_saldossuc AS sal INNER JOIN bdinteg:'informix'.si_sucursales AS suc 
					ON sal.sucursal = suc.sucursal AND suc.tpo_sucursal = 'S' AND sal.fecha = dFechaAnterior;
				END IF;
			END FOREACH;
		
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			ELSE 
				RETURN cCodRet, iTotalRegistros;
			END IF;
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/03/2015',
'DESCRIPCION: SPL que consulta el nÃºmero total de registros de las sucursales que no abrieron.',
'FUNCIONALIDAD: Sucursales No Abiertas Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalsdohistoricocaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoSaldo CHAR(1), 
		pCcMayor CHAR(4), pCcSub CHAR(2), pCcsubsub CHAR(2), pCcssubsub CHAR(2), pCcsssubsub CHAR(2), pSector CHAR(2),
		pFechaMes CHAR(2), pFechaAnio CHAR(4))
					
		RETURNING CHAR(5) AS codret, 
			INTEGER AS totalRegistros;   
		  
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE sTipo SMALLINT;
		DEFINE dFechaMinSel DATE;
		DEFINE dFechaMaxSel DATE;
		DEFINE dFechaMaxima DATE;
		DEFINE iTotalRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET sTipo = 0;
		LET dFechaMinSel = '';
		LET dFechaMaxSel = '';
		LET dFechaMaxima = '';		
		LET iTotalRegistros = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, iTotalRegistros; 
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalsdohistoricocaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pTipoSaldo = '' OR pFechaMes = '' OR pFechaAnio = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros; 
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros; 
			END IF;
			
			-- DEFINE CONSULTA 
			IF pTipoSaldo = 'F' THEN
				LET sTipo = 1;		
			ELIF pTipoSaldo = 'C' THEN
				LET sTipo = 0;
			END IF;
			 
			-- ARMADO DE FECHAS
			LET dFechaMinSel = TO_DATE(1||'/'||(pFechaMes::INTEGER)||'/'||(pFechaAnio::INTEGER),'%d/%m/%Y');
			LET dFechaMaxima = dFechaMinSel + 1 UNITS MONTH;
			LET dFechaMaxSel = dFechaMaxima - 1 UNITS DAY;			
				
			FOREACH
				EXECUTE PROCEDURE bdisuc:'informix'.sp_sel_sdohistorico2_totales(cEmpresa,sTipo,pCcMayor,pCcSub,pCcsubsub,pCcssubsub,pCcsssubsub,pSector,dFechaMinSel,dFechaMaxSel)
				INTO cCodRetSp, iTotalRegistros				 
					 
				IF cCodRetSp::INTEGER < 0 THEN 
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisuc:sp_sel_sdohistorico2_totales'; 
				END IF;
			END FOREACH;
				
			
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			ELSE
				RETURN cCodRet, iTotalRegistros;
			END IF;	

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 01/04/2015',
'DESCRIPCION: SPL que obtiene el nÃºmero total de registros de los saldos (fÃ­sicos o contables consultados).',
'FUNCIONALIDAD: HistÃ³rico de Saldos Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tr_actualizastatuslotemasivo(pUsuario CHAR(8), pIdFuncion CHAR(10), pStatus CHAR(2), pIdLote INTEGER, pUsarHistorico CHAR(1))
        RETURNING
                CHAR(5) AS codret,
                INT AS exitosos;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iExitosos INT;
        DEFINE cBaseDatos CHAR(50);
        DEFINE cTablaDst CHAR(50);

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iExitosos = 0;
        LET cBaseDatos = '';
        LET cTablaDst = '';

        BEGIN
			ON EXCEPTION SET iSqlErr
				IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
					RETURN cCodRet, iExitosos;
				END IF;
			END EXCEPTION;

			IF pUsuario = '' OR pIdFunciON = '' OR pStatus = '' OR pIdLote IS NULL OR pUsarHistorico = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iExitosos;
			END IF;
			
			IF pUsarHistorico NOT IN ('0', '1') THEN
				LET cCodRet = '00102';
				RETURN cCodRet, iExitosos;
			END IF;

			EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, iExitosos;
			END IF;

			SET ISOLATION TO DIRTY READ;
			SELECT base_datos, tabla
			INTO cBaseDatos, cTablaDst
			FROM sw_tr_info_tablas WHERE id_funcion = pIdFuncion;           

			IF cBaseDatos IS NULL OR cBaseDatos = '' THEN
				LET cCodRet = '00154';
				RETURN cCodRet, iExitosos;
			END IF;
			
			IF pUsarHistorico = '1' THEN
				LET cTablaDst = TRIM(cTablaDst)||'_hist';
			END IF;
			
			EXECUTE IMMEDIATE "UPDATE " || TRIM(cBaseDatos) || ":" || TRIM(cTablaDst) || " SET status = '"|| TRIM(pStatus) ||"' WHERE id_lote = " || pIdLote;
			LET iExitosos = DBINFO('sqlca.sqlerrd2');
			
			RETURN cCodRet, iExitosos;
        END

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 10/02/2015',
'DESCRIPCION: Actualiza el estatus de un lote completo, para el uso en procesos masivos';

CREATE PROCEDURE "informix".sp_validacodigoproveedorcaja(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodProveedor CHAR(4))
					
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;	
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;	
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_validacodigoproveedorcaja.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pCodProveedor = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet; 
			END IF;
		 
			-- VALIDA CÃDIGO
			IF EXISTS (SELECT cod_proveedor FROM bdisuc:'informix'.ss_cajageneral WHERE cod_proveedor = pCodProveedor) THEN
				LET cCodRet = '00466'; --NO SE PERMITEN CÃDIGOS DE CAJA GENERAL DUPLICADOS EN UNA MISMA PLAZA
				RETURN cCodRet;		
			ELSE 
				RETURN cCodRet;	
			END IF;
			
		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 31/03/2015',
'DESCRIPCION: SPL que valida que el cÃ³digo de proveedor no se encuentre duplicado dentro de una misma plaza.',
'FUNCIONALIDAD: Mantenimiento CatÃ¡logo Caja General', 
'MODULO: Caja General',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reportemensualremesasac(pUsuario CHAR(8), pIdFuncion CHAR(10), pPeriodo DATE, pConvenio CHAR(5))
	RETURNING
		CHAR(5) AS codigoRetorno,
		INTEGER AS dia,
		INTEGER AS totOperaciones, 
		MONEY(16,2) AS monto;

	DEFINE cCodRet CHAR(5);
	DEFINE iDia INTEGER;
	DEFINE iTotOperaciones INTEGER;
	DEFINE mMonto MONEY(16,2);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE cNumConvenio CHAR(3);
	DEFINE iNumRows INTEGER;
	
	LET cCodRet = '00000';
	LET iDia = 0;
	LET iTotOperaciones = 0;
	LET mMonto = 0;
	LET iRegistros = 0;
	LET cNumConvenio = '';
	LET iNumRows = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iDia, iTotOperaciones, mMonto;
		END EXCEPTION;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportemensualremesasac.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pPeriodo = '' OR pConvenio = ''  THEN 
			LET cCodRet = '00003';
			RETURN cCodRet, iDia, iTotOperaciones, mMonto;
		END IF;
			
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, iDia, iTotOperaciones, mMonto;
			END IF;
		
		IF pConvenio = '07004' THEN
			LET cNumConvenio = '004';
		ELIF pConvenio = '07006' THEN
			LET cNumConvenio = '006';
		ELIF pConvenio = '07007' THEN
			LET cNumConvenio = '007';
		ELIF pConvenio = '07008' THEN
			LET cNumConvenio = '008';
		END IF;		
		
		SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_movimientoshistorial
		WHERE MONTH(Fecha_Pago) = MONTH(pPeriodo)
		AND YEAR(Fecha_Pago) = YEAR(pPeriodo)
		AND NumConvenio = cNumConvenio
		AND status_cancelado = 'N';
		IF iNumRows <> 0 THEN
			IF pConvenio = '07004' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reportebts_mensual(pPeriodo)
					INTO iDia, iTotOperaciones, mMonto
					RETURN cCodRet, iDia, iTotOperaciones, mMonto WITH RESUME;
				END FOREACH;
			ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN
				FOREACH EXECUTE PROCEDURE bdisac:sp_reportewu_mensual(pPeriodo, pConvenio)
					INTO iDia, iTotOperaciones, mMonto
					RETURN cCodRet, iDia, iTotOperaciones, mMonto WITH RESUME;
				END FOREACH;
			END IF;
		ELSE
			LET cCodRet = '00017';
			RETURN cCodRet, iDia, iTotOperaciones, mMonto;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR Esparza Brenis Fernando Martin';

CREATE PROCEDURE "informix".sp_procesarsolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pTipoMotivo SMALLINT)
		RETURNING CHAR(5) AS codret,
				CHAR(80) AS nombre_atiende;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreAtiende CHAR(80);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cNombreAtiende = '';
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreAtiende;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		ON EXCEPTION IN (-255)
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_procesarsolicitudmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pTipoMotivo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreAtiende;
		END IF;
		
		
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreAtiende;
		END IF;
		
		BEGIN WORK;
		-- BLOQUEO DE TABLA
		SET LOCK MODE TO WAIT;
		SET ISOLATION TO COMMITTED READ;
		
--		-- SE CONSULTA LA SOLICITUD
		EXECUTE FUNCTION bdicnweb:'informix'.sp_consultasolicitudprocesomc (pUsuario, pIdFuncion, pNumCliente)
		INTO cCodRetSp, cNombreAtiende;
        
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_solicitudprocesandomc';
		ELIF iCodRetSp = 0 THEN
		
			SET LOCK MODE TO WAIT;
			EXECUTE PROCEDURE bdicnweb:'informix'.sp_solicitudprocesandomc(pUsuario, pIdFuncion, pNumCliente, pTipoMotivo)
			INTO cCodRetSp, cNombreAtiende;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				IF iCodRetSp = -268 THEN
					SELECT nombre
					INTO cNombreAtiende
					FROM bdinteg:'informix'.si_ejecut
					WHERE ejecutivo = (SELECT usuario FROM bdisolic:ss_cte_procesando WHERE numcte = pNumCliente);
					
					LET cCodRet = '90000';
				ELSE
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_solicitudprocesandomc';
				END IF;
			ELSE
				LET cCodRet = cCodRetSp;
			END IF;
		ELSE
			LET cCodRet = cCodRetSp;
		END IF;
		
		COMMIT WORK;
		
		IF bInTransaction THEN
			COMMIT WORK;
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, cNombreAtiende;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 20/05/2015',
'MODULO: Mesa de Control',
'FUNCIONALIDAD: Monior de solicitudes/Cambio de estatus',
'DESCRIPCION: Consulta y bloquea la solicitud para un usuario',
'FECHA: 16/06/2015',
'DESCRIPCION: Se establecen un modo de bloqueo de las tablas hasta que los datos sean comprometidos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultasolicitudprocesomc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20))
        RETURNING CHAR(5) AS codret,
                        CHAR(45) AS nombre_ejecutivo;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cEjecutivo CHAR(8);
        DEFINE cNombreEjecutivo CHAR(45);
        DEFINE iNoRegistros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cEjecutivo = '';
        LET cNombreEjecutivo = '';
        LET iNoRegistros = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cNombreEjecutivo;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consultasolicitudprocesomc.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cNombreEjecutivo;
                END IF;
                
                -- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNombreEjecutivo;
                END IF;
                
                -- BORRA REGISTROS DEL USUARIO
                DELETE FROM bdisolic:ss_cte_procesando where usuario = pUsuario;
                
                -- DESBLOQUEO DE LAS SOLICITUDES TRABAJADAS POR EL ANALISTA QUE QUEDAON BLOQUEADAS POR ERRROR
                UPDATE bdisolic:ss_solicitudes_mc
                SET ejecutivo_atiende = ''
                WHERE ejecutivo_atiende = pUsuario
                        AND status_fin = ''
                        AND revisado <> 'S';
                
                -- CONSULTAMOS EL NUMERO DE SOLICITUD
                SELECT usuario
                INTO cEjecutivo
                FROM bdisolic:ss_cte_procesando
                WHERE numcte = pNumCliente;
                
                LET iNoRegistros = dbinfo('sqlca.sqlerrd2');
                IF iNoRegistros > 0 THEN
                        SELECT nombre
                        INTO cNombreEjecutivo
                        FROM bdinteg:'informix'.si_ejecut
                        WHERE ejecutivo = cEjecutivo;
                        
                        LET cCodRet = '90000';
                        RETURN cCodRet, cNombreEjecutivo;
                END IF;
                
                RETURN cCodRet, cNombreEjecutivo;
                
        END;
        
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 18/12/2013",
"DESCRIPCION: Revisa que una solicitud no este siendo ya atendida por otro ejecutivo",
"AUTOR: Oscar Flores Conde",
"FECHA: 16/06/2015",
"DESCRIPCION: Se elimina la lectura sucia para manejo de la concurrencia",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_reportetraspasoctabeneficencia( pUsuario         CHAR(8), 
                                                               pIdFuncion       CHAR(10), 
                                                               pIdFuncionPadre  CHAR(10), 
                                                               pFechaInicio     DATE, 
                                                               pFechaFin        DATE, 
                                                               pArchivoDescarga CHAR(255) )
RETURNING CHAR(5) AS codret,
          INTEGER AS no_registros;
    
    DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
    DEFINE cCodRetSp CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(50);
    DEFINE iNoRegistros INTEGER;
    DEFINE vsql CHAR(500);
    DEFINE vstmt CHAR(300);

    LET cCodRet = '00000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET cCodRetSp = '';
    LET iSqlErr = 0;
    LET iSamErr = 0;
    LET cDesErr = '';
    LET iNoRegistros = 0;
    LET vsql = '';
    LET vstmt = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/tmp/sp_reportetraspasoctabeneficencia.err'; 
        TRACE ON;
        LET cCodRet = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        RETURN cCodRet, iNoRegistros;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/tmp/sp_reportetraspasoctabeneficencia.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pArchivoDescarga = '' THEN
        LET cCodRet = '00003';
        RETURN cCodRet, iNoRegistros;
    END IF;
    
    -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
    EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
    INTO cCodRet;
    
    IF cCodRet <> '00000' THEN
        RETURN cCodRet, iNoRegistros;
    END IF;
    
    -- // VALIDA QUE HAYA REGISTROS POR DESCARGAR
    SELECT COUNT(*)
      INTO iNoRegistros
      FROM bdicheq:sc_cuentas_traspbenef
     WHERE fecha_traspaso BETWEEN pFechaInicio AND pFechaFin;
     
    IF iNoRegistros = 0 THEN
        LET cCodRet = '00017';
        RETURN cCodRet, iNoRegistros;
    END IF;
    
    -- // GENERA ARCHIVO DE DESCARGA
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchivoDescarga)||' '||
               'SELECT * FROM sc_cuentas_traspbenef WHERE fecha_traspaso BETWEEN '''||pFechaInicio||''' AND '''||pFechaFin||''';" > /tmp/ctastraspbenef.sql';
    SYSTEM vsql;
    
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /tmp/ctastraspbenef.sql"; 
    SYSTEM vstmt;    
    
    -- Ejecución del SP para la carga de los encabezados
    EXECUTE PROCEDURE bdicnweb:sp_obtieneencabezadomasivo(pIdFuncionPadre, pArchivoDescarga) 
    INTO cCodRetSp;
    
    IF cCodRetSp::INTEGER < 0 THEN
        RAISE EXCEPTION cCodRetSp::INTEGER, 0, '';
    END IF;
    
    IF cCodRetSp::INTEGER > 0 THEN
        RETURN cCodRetSp, iNoRegistros;
    END IF;
    
    RETURN cCodRet, iNoRegistros;
            
    END;
        
END PROCEDURE 
    
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 02/03/2015',
'DESCRIPCION: Generacion de reporte de cuentas transferidas a la beneficencia publica',
'MODULO: Debito',
'FUNCIONALIDAD: Traspaso a beneficencia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_valida_bancoctaclabe( pUsuario CHAR(8), pIdFuncion CHAR(10), pCtaClabe CHAR(18) )
RETURNING CHAR(5) AS codret,
		  CHAR(25) AS descCortaBanco,
		  INTEGER AS cvecesif;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreCorto CHAR(25);
	DEFINE iCveCeSif INTEGER; 
	DEFINE cCodCtaCbe CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET cNombreCorto = '';
	LET iCveCeSif = 0;
	LET cCodCtaCbe ='';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr
        LET cCodRet = iSqlErr;
        RETURN cCodRet, cNombreCorto, iCveCeSif;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/tmp/mfinis/sp_valida_bancoctaclabe.out';
    --- TRACE ON;
    
    IF pUsuario = '' OR pIdFuncion = '' OR  pCtaClabe = '' THEN
        LET cCodRet = '00003';
        RETURN cCodRet, cNombreCorto, iCveCeSif;
    END IF;
    
    EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
    INTO cCodRet;
    
    IF cCodRet <> '00000' THEN
        RETURN cCodRet, cNombreCorto, iCveCeSif;
    END IF;
    
    LET cCodCtaCbe = SUBSTRING(pCtaClabe FROM 1 FOR 3);
    
    SELECT vchrnombrecorto, cvecesif 
      INTO cNombreCorto, iCveCeSif 
      FROM bdinteg:si_bancos 
     WHERE banco = cCodCtaCbe;
    
    IF DBINFO('sqlca.sqlerrd2')= 0 THEN
        LET cCodRet = '00431';
    END IF;
    
    RETURN cCodRet, cNombreCorto, iCveCeSif;
    
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 23/02/2014',
'DESCRIPCION: valida si existe el banco en tabla respecto a la cuenta clabe',
'MODULO: Traspaso a Cta Beneficiencia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reporteestadocuentasac_pba(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaIni DATE, pFechaFin DATE, pConvenio CHAR(5), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING
		CHAR(5)  AS codRetorno,
		CHAR(10) AS fecha, 
		CHAR(14) AS saldoInicial,
		CHAR(10) AS totalAbonos,
		CHAR(14) AS montoTotalAbonos,
		CHAR(10) AS totalCargos,
		CHAR(14) AS montoTotalCargos,
		CHAR(14) AS saldoFinal,
		CHAR(20) AS cuentaConcentradora,
		CHAR(18) AS cuentaClabe;
		
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFecha CHAR(10);
	DEFINE cSaldoInicial CHAR(14);
	DEFINE cTotalAbonos CHAR(10);
	DEFINE cMontoTotalAbonos CHAR(14);
	DEFINE cTotalCargos CHAR(10);
	DEFINE cMontoTotalCargos CHAR(14);
	DEFINE cSaldoFinal CHAR(14);
	DEFINE cCtaConcentradora CHAR(20);
	DEFINE cCtaClabe CHAR(20);
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio CHAR(3);
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs INTEGER;
	DEFINE iRecuperacion INTEGER;

	LET cCodRet = "00000";
	LET cCodRetSp = "";
	LET iSqlErr = 0;
	LET cFecha = "";
	LET cSaldoInicial = "";
	LET cTotalAbonos = "";
	LET cMontoTotalAbonos = "";
	LET cTotalCargos = "";
	LET cMontoTotalCargos = "";
	LET cSaldoFinal = "";
	LET cCtaConcentradora = "";
	LET cCtaClabe = "";	
	LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
	LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;

	BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
        END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/mfinis/bdicnweb/sac/sp_reporteestadocuentasac2.out";
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pFechaIni = '' OR pFechaFin = '' OR pConvenio = '' OR pRegistros = '' OR pRecuperacion = ''  THEN 
			LET cCodRet = '00003';
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
		END IF;
		
		IF pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
		END IF;
			
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
		END IF;
		
		IF pConvenio = '07004' THEN
			SET ISOLATION TO DIRTY READ;
			FOREACH EXECUTE PROCEDURE bdisac:sp_reportebts_edocta(pFechaIni, pFechaFin)
			INTO cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe, cCodRetSp
				IF cCodRetSp = '0' THEN
					IF iRegistros >=  pRegistros THEN
						IF  iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							RETURN  cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
					LET iRegistros = iRegistros + 1;
				ELSE
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
				END IF;
			END FOREACH;
		ELIF pConvenio = '07006' OR pConvenio = '07007' OR pConvenio = '07008' THEN  -- CONVENIO
			FOREACH EXECUTE PROCEDURE bdisac:sp_reportewu_edocta(pFechaIni, pFechaFin,  pConvenio)
			INTO cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe, cCodRetSp
				IF cCodRetSp = '0' THEN
					IF iRegistros >=  pRegistros THEN
						IF  iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
					LET iRegistros = iRegistros + 1;
				ELSE
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
				END IF ;
			END FOREACH;
		END IF;
		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cFecha, cSaldoInicial, cTotalAbonos, cMontoTotalAbonos, cTotalCargos, cMontoTotalCargos, cSaldoFinal, cCtaConcentradora, cCtaClabe;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', '', '', '', '', '', '';
		END IF;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin',
'Descripcion: Convenios 07004 GENERA REPORTE DE ESTADO DE CUENTA, 707006,07007,07008 GENERA REPORTE DE ESTADO DE CUENTA PARA WU',
'Fecha: 2013/12/12';

CREATE PROCEDURE "informix".sp_gs_notificacioncorreoelectronico(pUsuario CHAR(8), pIdFuncion CHAR(10), pOpcionEnvio CHAR(1), pTipoOperacion SMALLINT, pIdSolicitud INTEGER, pPlantilla CHAR(10), pTitulo CHAR(60))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cJefeAreaUsuarioSolic CHAR(8);
	DEFINE cUsuarioSolic CHAR(8);
	DEFINE cUsuarioResponsable CHAR(8);
	DEFINE iIdAreaResponsable INTEGER;
	DEFINE cJefeUsuarioResponsable CHAR(8);
	DEFINE iIdSolicitudAnterior INTEGER;
	
	-- VARIABLES PARA EL SP DE NOTIFICACIÃ?N
	DEFINE cTipoMsj CHAR(1);
	DEFINE cIdMsj CHAR(10);
	DEFINE cNumclt CHAR(20);
	DEFINE cNumcta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cTipoproc CHAR(1);
	DEFINE cStr1 CHAR(30);
	DEFINE cStr2 CHAR(30);
	DEFINE cStr3 CHAR(30);
	DEFINE cStr4 CHAR(30);
	DEFINE cStr5 CHAR(150);
	DEFINE cStr6 CHAR(100);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);
	DEFINE cStr9 CHAR(15);
	DEFINE cStr10 CHAR(100);
	DEFINE cCorreoAlterno CHAR(100);
	DEFINE cCelularAlterno CHAR(10);
	DEFINE mImporte1 MONEY(16,2);
	DEFINE mImporte2 MONEY(16,2);
	DEFINE mImporte3 MONEY(16,2);
	DEFINE mImporte4 MONEY(16,2);
	DEFINE mImporte5 MONEY(16,2);
	DEFINE dFecha1 DATETIME YEAR TO FRACTION(3);
	DEFINE dFecha2 DATETIME YEAR TO FRACTION(3);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cJefeAreaUsuarioSolic = '';
	LET cUsuarioSolic = '';
	LET cUsuarioResponsable = '';
	LET iIdAreaResponsable = 0;
	LET cJefeUsuarioResponsable = '';
	LET iIdSolicitudAnterior = 0;
	-- VARIABLES DEL SP DE NOTIFICACIÃ?N
	LET cTipoMsj = '1';
	LET cIdMsj = pPlantilla;
	LET cNumclt = '';
	LET cNumcta = '';
	LET cNumTarjeta = '';
	LET cTipoproc = '1';
	LET cStr1 = '';
	LET cStr2 = '';
	LET cStr3 = '';
	LET cStr4 = '';
	LET cStr5 = '';
	LET cStr6 = '';
	LET cStr7 = pTitulo;
	LET cStr8 = '';
	LET cStr9 = '';
	LET cStr10 = '';
	LET cCorreoAlterno = '';
	LET cCelularAlterno = '';
	LET mImporte1 = 1;
	LET mImporte2 = 0.00;
	LET mImporte3 = 0.00;
	LET mImporte4 = 0.00;
	LET mImporte5 = 0.00;
	LET dFecha1 = NULL;
	LET dFecha2 = NULL;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_notificacioncorreoelectronico.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pPlantilla = '' OR pIdSolicitud IS NULL OR pTitulo = '' OR pOpcionEnvio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pOpcionEnvio NOT IN ('S', 'R') THEN
			LET cCodRet = '00148';
			RETURN cCodRet;
		END IF;
		
		IF pTipoOperacion NOT IN (1, 2, 3, 4, 5) THEN
			LET cCodRet = '00148';
			RETURN cCodRet;
		END IF;
		
		
		IF pOpcionEnvio = 'S' THEN
			IF pTipoOperacion IN (1, 3, 4) THEN -- ENVIO DE SOLICITUD, REINTENTO, CANCELACIÃ?N
				SET ISOLATION TO DIRTY READ;
			
				-- CONSULTA DE DATOS PARA EL CORREO
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					d.desc_status_solicitud,
					(SELECT ejecutivo||' '||nombre FROM bdinteg:si_ejecut WHERE ejecutivo = a.usuario_responsable) AS usuario_responsable,
					(SELECT descripcion_area FROM sw_gs_area WHERE id_area = a.id_area_responsable) AS area_responable,
					fecha_solicitud as fecha_solicitud,
					EXTEND(fecha_solicitud, hour to second) as hora_solicitud
				INTO cStr8,
					cStr5,
					cStr9, 
					cStr6, 
					cStr3, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c,
					bdicnweb:sw_gs_catstatussolicitud d
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante
					AND d.id_status_solicitud = a.id_status_solicitud;
					
			ELIF pTipoOperacion = 2 THEN -- ES UNA REASIGNACION
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					fecha_solicitud as fecha_solicitud,
					fecha_solicitud as hora_solicitud
				INTO cStr8, 
					cStr5, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante;
				
				-- BUSQUEDA DE LA SOLICITUD ANTERIOR
				SELECT MAX(id_registro_solicitud)
				INTO iIdSolicitudAnterior
				FROM bdicnweb:sw_gs_registrosolicitud
				WHERE folio_solicitud = (SELECT folio_solicitud FROM bdicnweb:sw_gs_registrosolicitud WHERE id_registro_solicitud = pIdSolicitud)
					AND id_registro_solicitud <> pIdSolicitud;
				
				-- RESPONSABLE ANTERIOR
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr6, cStr3
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = iIdSolicitudAnterior
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;

				-- RESPONSABLE ACTUAL
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr10, cStr4
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;
				
			END IF;
			
			IF pTipoOperacion IN (1, 3, 4) THEN
			
				FOREACH SELECT usuario_responsable
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a   
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT c.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud b,
							bdicnweb:sw_gs_area_usuario c
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND c.id_area = b.id_area_responsable
							AND c.jefe_area = 't'
							AND c.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
						
						
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	

				END FOREACH;
				
				RETURN cCodRet;
			
			ELIF pTipoOperacion = 2 THEN -- REASIGNACIÃ?N
				
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT a.usuario_responsable
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = iIdSolicitudAnterior
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = iIdSolicitudAnterior
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT a.usuario_responsable
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
							
							
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	
						
				END FOREACH;
				
				RETURN cCodRet;
			
			END IF;
			
		ELIF pOpcionEnvio = 'R' THEN
			IF pTipoOperacion IN (4,5) THEN -- CANCELACIÃ?N O ATENCIÃ?N
				SET ISOLATION TO DIRTY READ;
			
				-- CONSULTA DE DATOS PARA EL CORREO
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					d.desc_status_solicitud,
					(SELECT ejecutivo||' '||nombre FROM bdinteg:si_ejecut WHERE ejecutivo = a.usuario_responsable) AS usuario_responsable,
					(SELECT descripcion_area FROM sw_gs_area WHERE id_area = a.id_area_responsable) AS area_responable,
					fecha_solicitud as fecha_solicitud,
					fecha_solicitud as hora_solicitud
				INTO cStr8,
					cStr5,
					cStr9, 
					cStr6, 
					cStr3, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c,
					bdicnweb:sw_gs_catstatussolicitud d
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante
					AND d.id_status_solicitud = a.id_status_solicitud;
					
			ELIF pTipoOperacion = 2 THEN -- ES UNA REASIGNACION
				SELECT TRIM(a.folio_solicitud||' '||b.descripcion_solicitud) AS solicitud,
					TRIM(a.usuario_solicitante)||' '||c.nombre AS usuario_solicitante,
					fecha_solicitud as fecha_solicitud,
					fecha_solicitud as hora_solicitud
				INTO cStr8, 
					cStr5, 
					dFecha1, 
					dFecha2
				FROM bdicnweb:sw_gs_registrosolicitud a, 
					bdicnweb:sw_gs_solicitudes b,
					bdinteg:si_ejecut c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.id_solicitud = a.id_solicitud
					AND c.ejecutivo = a.usuario_solicitante;
				
				-- BUSQUEDA DE LA SOLICITUD ANTERIOR
				SELECT MAX(id_registro_solicitud)
				INTO iIdSolicitudAnterior
				FROM bdicnweb:sw_gs_registrosolicitud
				WHERE folio_solicitud = (SELECT folio_solicitud FROM bdicnweb:sw_gs_registrosolicitud WHERE id_registro_solicitud = pIdSolicitud)
					AND id_registro_solicitud <> pIdSolicitud;
				
				-- RESPONSABLE ANTERIOR
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr6, cStr3
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = iIdSolicitudAnterior
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;

				-- RESPONSABLE ACTUAL
				SELECT TRIM(TRIM(a.usuario_responsable)||' '||b.nombre), c.descripcion_area
				INTO cStr10, cStr4
				FROM bdicnweb:sw_gs_registrosolicitud a,
					bdinteg:si_ejecut b,
					bdicnweb:sw_gs_area c
				WHERE a.id_registro_solicitud = pIdSolicitud
					AND b.ejecutivo = a.usuario_responsable
					AND c.id_area = a.id_area_responsable;
				
			END IF;
			
			IF pTipoOperacion IN (4,5) THEN
			
				FOREACH SELECT usuario_solicitante
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a   
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT c.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud b,
							bdicnweb:sw_gs_area_usuario c
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND c.id_area = b.id_area_responsable
							AND c.jefe_area = 't'
							AND c.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
						
						
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	

				END FOREACH;
				
				RETURN cCodRet;
			
			ELIF pTipoOperacion = 2 THEN -- REASIGNACIÃ?N
				
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT a.usuario_solicitante
						INTO cNumclt
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = iIdSolicitudAnterior
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = iIdSolicitudAnterior
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT a.usuario_responsable
						FROM bdicnweb:sw_gs_registrosolicitud a
						WHERE a.id_registro_solicitud = pIdSolicitud
						UNION
						SELECT a.id_usuario
						FROM sw_gs_area_usuario a, 
							bdicnweb:sw_gs_registrosolicitud b
						WHERE b.id_registro_solicitud = pIdSolicitud
							AND a.id_area = b.id_area_responsable
							AND a.jefe_area = 't'
							AND a.status = 't'
						UNION
						SELECT e.id_usuario 
						FROM bdicnweb:sw_gs_registrosolicitud d,
							bdicnweb:sw_gs_area_usuario e
						WHERE d.id_registro_solicitud = pIdSolicitud
							AND e.id_area = d.id_area_solicitante
							AND e.jefe_area = 't'
							AND e.status = 't'
							
					EXECUTE PROCEDURE bdimnsj:sp_registra_evento(
																	cTipoMsj, 
																	cIdMsj, 
																	cNumclt, 
																	cNumcta, 
																	cNumTarjeta, 
																	cTipoproc, 
																	cStr1, 
																	cStr2, 
																	cStr3, 
																	cStr4, 
																	cStr5, 
																	cStr6, 
																	cStr7, 
																	cStr8, 
																	cStr9, 
																	cStr10, 
																	cCorreoAlterno, 
																	cCelularAlterno, 
																	mImporte1, 
																	mImporte2, 
																	mImporte3, 
																	mImporte4, 
																	mImporte5, 
																	dFecha1, 
																	dFecha2) INTO cCodRetSp;
				
					LET iCodRetSp = cCodRetSp::INTEGER;
					IF iCodRetSp < 0 THEN
						RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_registra_evento';
					ELIF iCodRetSp > 0 THEN
						LET cCodRet = LPAD(iCodRetSp, 5, '0');
						RETURN cCodRet;
					END IF;	
						
				END FOREACH;
				
				RETURN cCodRet;
			
			END IF;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/08/2014',
'DESCRIPCION: pTipoOperacion = 1: Envio de solicitud; 2: ReasignaciÃ³n de solicitud, 3: Reintento, 4: Cancelacion, 5: Atencion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reporteconciliacionconveniosucursal_pba(pUsuario CHAR(8), pIdfuncion CHAR(10), pConvenio CHAR(5), pSucursal CHAR(4), pFechaIni DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codigoretorno,
	CHAR(4) AS idsucursal,
	INTEGER AS numpagos, 
	CHAR(40) AS nomconvenio, 
	MONEY(16,2) AS importepago, 
	MONEY(16,2) AS importecomisionconvenio,
	MONEY(16,2) AS ivacomisionconvenio, 
	MONEY(16,2) AS importecomisioncte,
	MONEY(16,2) AS iva_comisioncte,
	INTEGER AS flagconfirmacioncentral,
	INTEGER AS flagconfirmacionsucursal;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cIdSucursal CHAR(5);
	DEFINE cNumPagos INTEGER; 
	DEFINE cNomconvenio CHAR(40); 
	DEFINE mImportePago MONEY(16,2); 
	DEFINE mImporteComisionConvenio MONEY(16,2);
	DEFINE mIvaComisionConvenio MONEY(16,2);
	DEFINE mImporteComisionCte MONEY(16,2);
	DEFINE mIvaComisionCte MONEY(16,2);
	DEFINE iFlagConfirmacionCentral INTEGER;
	DEFINE iFlagConfirmacionSucursal INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cIdSucursal = '';
	LET cNumPagos = 0;
	LET cNomconvenio = '';
	LET mImportePago = 0;
	LET mImporteComisionConvenio = 0;
	LET mIvaComisionConvenio = 0;
	LET mImporteComisionCte = 0;
	LET mIvaComisionCte = 0;
	LET iFlagConfirmacionCentral = 0;
	LET iFlagConfirmacionSucursal = 0;
	LET iRegistros = 0;
	LET iNoRegs = 0;
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodret = iSqlErr;
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reporteconciliacionconveniosucursal.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdfuncion = '' OR LENGTH(pConvenio) <> 5 OR LENGTH(pSucursal) <> 4 OR pFechaIni = '' OR pFechaFin = '' OR pRegistros = '' OR pRecuperacion = ''THEN
			LET cCodret = '00003';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		IF pRecuperacion < 0 THEN
			LET cCodret = '00098';
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdisac:sp_sacreporteconciliacionconveniosucursal(pConvenio, pSucursal, pFechaIni, pFechaFin) INTO
			cCodRetSp, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio,
			mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal

			IF 	NVL(cIdSucursal, '') = '' AND 
				NVL(cNumPagos, '') = '' AND 
				NVL(cNomconvenio, '')  = '' AND 
				NVL(mImportePago, '') = ''  AND 
				NVL(mImporteComisionConvenio, '') = '' AND
				NVL(mIvaComisionConvenio, '') = '' AND 
				NVL(mImporteComisionCte, '') = '' AND 
				NVL(mIvaComisionCte,'') = '' AND 
				NVL(iFlagConfirmacionCentral,'') = '' AND 
				NVL(iFlagConfirmacionSucursal,'') = '' THEN
				
				LET cCodRet = '00017';
				RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
			ELSE
				IF cCodRetSp <> '00000' THEN
					LET cCodRet = cCodRetSp;
					RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio, mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte,
					iFlagConfirmacionCentral, iFlagConfirmacionSucursal;
				ELSE
					IF iRegistros >= pRegistros THEN
						IF iRecuperacion < pRecuperacion THEN
							LET iRecuperacion = iRecuperacion + 1;
							RETURN cCodRet, cIdSucursal, cNumPagos, cNomconvenio, mImportePago, mImporteComisionConvenio,
							mIvaComisionConvenio, mImporteComisionCte, mIvaComisionCte, iFlagConfirmacionCentral, iFlagConfirmacionSucursal WITH RESUME;
							LET iNoRegs = iNoRegs + 1;
						END IF;
					END IF;
						LET iRegistros = iRegistros + 1;
				END IF;
			END IF;
		END FOREACH;
		 IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		ELIF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', 0, 0, 0, 0, 0, 0, 0;
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR:Esparza Brenis Fernando Martin",
"FECHA: 12/12/2013",
"DESCRIPCION: SP para el reporte de conciliaciÃ³n por convenios",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_reversioncap_pba(pUsuario char(10), 
					    pIdFuncion char(10), 
					    pFolioMovimiento char(16), 
					    pSucursalFolio char(4),
						pTransacc char(4))
       RETURNING char(5) as codret;
	
DEFINE cCodRet char(5);
DEFINE cConstante char(1);
DEFINE cEmpresa char(3);
DEFINE iSqlErr int;
DEFINE cReversable char(1);
	
LET cCodRet = '00000';
LET cConstante = 'M';
LET cEmpresa = '001';
LET iSqlErr = 0;
LET cReversable = '';
	
BEGIN
		
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;


	IF pUsuario = ''
	 OR pIdFuncion = '' 
	 OR pFolioMovimiento = '' 
	 OR pSucursalFolio = ''  
	 OR pTransacc = ''
	THEN
		LET cCodRet = '00003';
		RETURN cCodRet;
	END IF;
		
	-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
	EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, 
							               pIdFuncion) 
		INTO cCodRet;
	IF cCodRet <> '00000' THEN
		RETURN cCodRet;
	END IF;
	
	-- Validacion de la transaccion para ver si puede ser reversable
	SELECT reversable
	INTO cReversable
	FROM bdinteg:"informix".si_transacc
	WHERE numero = pTransacc;

	IF cReversable IS NULL OR cReversable='' THEN
		LET cReversable='N';
	END IF;
	
	IF cReversable <> "S" THEN
		LET cCodRet = '00152'; -- No se permite realizar un reverso de esta transaccion
		RETURN cCodRet;
	END IF;
		
	EXECUTE PROCEDURE bdicheq:"informix".reversion(cEmpresa, 
					    		pSucursalFolio, 
					    		pUsuario, 
					    		pFolioMovimiento, 
					    		cConstante) 
		INTO cCodRet;
		
	IF cCodRet = '000' THEN
                LET cCodRet = '00000';
        END IF;
        IF cCodRet = '170' THEN
		LET cCodRet = '00112';
	END IF;
	IF cCodRet = '413' THEN
		LET cCodRet = '00113';
	END IF;
	IF cCodRet = '00036' THEN
		LET cCodRet = '00003';
	END IF;
	IF cCodRet = '00030' THEN
		LET cCodRet = '00114';
	END IF;
	IF cCodRet = '00037' THEN
		LET cCodRet = '00115';
	END IF;
	IF cCodRet = '00035' THEN
		LET cCodRet = '00116';
	END IF;
	IF cCodRet = '001' THEN
		LET cCodRet = '00117';
	END IF;
		
	RETURN cCodRet;
		
END;

END PROCEDURE;