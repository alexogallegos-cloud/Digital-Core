CREATE PROCEDURE "informix".sp_sw_ro_guardamovtos(pUsuario CHAR(8), pFunciON CHAR(10), pIdOficio INT, pIdBusqueda INT, 
										pIdCte INT, pNumCliente CHAR(20),pNumCuenta CHAR(20), pNumTarjeta CHAR(20), 
										pTipoCuenta CHAR(2), pFechaMovto CHAR(10), pHora CHAR(15), pFolioSucursal CHAR(16), 
										pTransacciON CHAR(4), pDescTransacciON CHAR(50), pReversado CHAR(1), pMonto decimal(18,2), 
										pSucursal CHAR(4), pNaturaleza CHAR(1), pSaldo money(14,2), pProcedencia CHAR(20),
										pDescProcedencia CHAR(50), pReferencia CHAR(40), pIndOmitir CHAR(1), pIp CHAR(15),
										pMac CHAR(12))	
	RETURNING CHAR(5) AS codret,
				INT AS secuencia
	DEFINE iSqlErr INT;
	DEFINE iSecuencia INT;
	DEFINE cCodRet CHAR(5);
	DEFINE cNombreSucursal CHAR(40);
	DEFINE cEstado CHAR(2);
	DEFINE cCiudad CHAR(3);
	DEFINE cDescEstado CHAR(30);
	DEFINE cDescCiudad CHAR(60);
	DEFINE dFechaMovto date;
	
	DEFINE cCodRetPtf varchar(5); 
	DEFINE cIdptf varchar(5); 
	DEFINE cTipos varchar(1); 
	DEFINE cClavesit char(3); 
	DEFINE cFechasit date; 
	DEFINE cCalles varchar(100); 
	DEFINE cNumext varchar(6); 
	DEFINE cNumint varchar(5); 
	DEFINE cCvecol char(8); 
	DEFINE cColonias varchar(100); 
	DEFINE cCvemun char(5); 
	DEFINE cMunicipio varchar(60); 
	DEFINE cVelocalidades char(14); 
	DEFINE cLocalidades varchar(60); 
	DEFINE cCps char(5);                     
	DEFINE cCiudades char(3); 
	DEFINE cEstados INTEGER; 
	DEFINE cLatitudes varchar(10); 
	DEFINE cLongitudes varchar(11); 
	DEFINE cTels1 varchar(14); 
	DEFINE cTels2 varchar(14); 
	
	LET iSqlErr = 0;
	LET iSecuencia = 0;
	LET cCodRet = '00000';
	LET cNombreSucursal = '';
	LET cEstado = '';
	LET cCiudad = '';
	LET cDescEstado = '';
	LET cDescCiudad = '';
	LET dFechaMovto ='';
	
	LET cCodRetPtf = '';
	LET cIdptf = ''; 
	LET cTipos = ''; 
	LET cClavesit = ''; 
	LET cFechasit = ''; 
	LET cCalles = ''; 
	LET cNumext = ''; 
	LET cNumint = ''; 
	LET cCvecol = ''; 
	LET cColonias = ''; 
	LET cCvemun = ''; 
	LET cMunicipio = ''; 
	LET cVelocalidades = ''; 
	LET cLocalidades = ''; 
	LET cCps = ''; 		
	LET cCiudades = ''; 
	LET cEstados = 0; 
	LET cLatitudes = ''; 
	LET cLongitudes = ''; 
	LET cTels1 = ''; 
	LET cTels2 = ''; 
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iSecuencia;
			END IF;
		END EXCEPTION;	
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pFunciON = ''
				OR pIdOficio = ''
				OR pIdBusqueda = ''
				OR pIdCte = ''
				OR pNumCliente = ''
				OR pFolioSucursal = ''
				OR pNumCuenta = ''
				OR pTipoCuenta = ''
				OR pFechaMovto = ''
				OR pHora = ''
				OR pSucursal = ''
				OR pMonto = ''
				OR pIndOmitir = '' 
			THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iSecuencia;
		END IF;
		IF pIndOmitir NOT IN ('0', '1') THEN
			LET cCodRet = '00077';
			RETURN cCodRet, iSecuencia;
		END IF;
		IF pTipoCuenta NOT IN ('01', '03', '06') THEN
			LET cCodRet = '00077';
			RETURN cCodRet, iSecuencia;
		END IF;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pFunciON) 
		INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iSecuencia;
		END IF;
		-- ValidaciÃ³n de parametro s por sistema cuenta
		IF pTipoCuenta = '01' THEN
			IF pNaturaleza = '' OR pSaldo = '' THEN --or pReferencia = ''OR pProcedencia = ''OR pDescProcedencia = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iSecuencia;
			END IF;
		ELIF pTipoCuenta = '06' THEN
		END IF;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_si_ptf(pSucursal) 
		INTO 
		cCodRetPtf, cIdptf, cTipos, cClavesit, cFechasit, cCalles, cNumext, cNumint, cCvecol, cColonias, cCvemun, cMunicipio, 
		cVelocalidades, cLocalidades, cCps, cCiudades, cEstados, cLatitudes, cLongitudes, cTels1, cTels2;   
						
		-- Buscamos los datos de la sucursal		
		SELECT nombre, cEstados, cCiudades 
		INTO cNombreSucursal, cEstado, cCiudad
		FROM bdinteg:si_sucursales 
		WHERE sucursal = pSucursal;
		-- Obtenemos la descripciON del estado		
		SELECT nombre 
		INTO cDescEstado 
		FROM bdinteg:si_estados 
		WHERE estado = cEstado;
		-- Obtenemos la descripciON de la ciudad		
		SELECT nombre 
		INTO cDescCiudad 
		FROM bdinteg:si_ciudades 
		WHERE estado = cEstado 
			AND ciudad = cCiudad;
		-- Guardamos el registro en la base de datos
		
		let dFechaMovto = EXTEND(MDY(SUBSTR(pFechaMovto,6,2),SUBSTR(pFechaMovto,9,2),SUBSTR(pFechaMovto,1,4)), YEAR TO SECOND);
		INSERT INTO sw_ro_movtos(id_resulcte, id_busqueda, id_oficio, numcte, 
									cuenta, tipo_cuenta, fecha_mov, folio_sucursal, 
									transaccion, descripcion_transaccion, reversado, monto, 
									sucursal, nombre_sucursal, estado, ciudad, 
									estado_nombre, ciudad_nombre, user_INSERT, ip_INSERT, 
									mac_INSERT, hora, naturaleza, saldo, 
									procedencia, descripcion_procedencia, referencia, ind_omitido,
									tarjeta)
			VALUES(pIdCte, pIdBusqueda, pIdOficio, pNumCliente, 
					pNumCuenta, pTipoCuenta, dFechaMovto,pFolioSucursal, 
					pTransaccion, pDescTransaccion, pReversado, pMonto,
					pSucursal, cNombreSucursal, cEstado, cCiudad, 
					cDescEstado, cDescCiudad, pUsuario, pIp, 
					pMac, pHora, pNaturaleza, pSaldo, 
					pProcedencia, pDescProcedencia, pReferencia, pIndOmitir, 
					pNumTarjeta);
		-- Se actualiza en estatus en la tabla de cuentas
		SET LOCK MODE TO WAIT 3;
		UPDATE sw_ro_ctecta 
		SET detalle_movimientos = '1' 
		WHERE id_resulcte = pIdCte 
		AND id_busqueda = pIdBusqueda 
		AND id_oficio = pIdOficio
		AND cuenta = pNumCuenta;
		-- Se actualiza en estatus en la tabla de clientes
		SET LOCK MODE TO WAIT 3;
		UPDATE sw_ro_resulcte 
		SET detalle_movimientos = '1' 
		WHERE id_resulcte = pIdCte 
		AND id_busqueda = pIdBusqueda 
		AND id_oficio = pIdOficio;
		-- Se actualiza en estatus en la tabla de clientes
		SET LOCK MODE TO WAIT 3;
		UPDATE sw_ro_maeoficios 
		SET detalle_movimientos = '1' 
		WHERE id_oficio = pIdOficio;
		LET iSecuencia = dbinfo('sqlca.sqlerrd1');
		RETURN cCodRet, iSecuencia;
	END
END PROCEDURE;