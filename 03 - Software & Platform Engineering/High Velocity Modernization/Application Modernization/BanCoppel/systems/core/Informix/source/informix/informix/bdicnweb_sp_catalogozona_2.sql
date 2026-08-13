CREATE PROCEDURE "informix".sp_catalogozona_2(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pTipoConsulta SMALLINT, pConsulta CHAR(30), pCliente CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS numero_colonia,
		CHAR(32) AS nombre_zona,
		CHAR(27) AS nombre_municipio_zona;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdNumeroColonia SMALLINT;
	DEFINE cNombreZona CHAR(32);
	DEFINE cNombreMunicipio CHAR(27);
	DEFINE iTotalReg INTEGER;
	DEFINE cCiudad INTEGER; 
	DEFINE cNumColonia INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET iIdNumeroColonia = 0;
	LET cNombreZona = '';
	LET cNombreMunicipio = '';
	LET iTotalReg = 0;
	LET cCiudad = 0; 
	LET cNumColonia = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogozona_2.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdCiudadCoppel IS NULL OR pTipoConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		-- VALIDACIÃN DE LOS PARAMETROS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta NOT IN (1,2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta = 2 AND pConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pRegistros >= 0 AND pRegistros < 100 THEN
			IF pRecuperacion = pRegistros THEN
				LET iTotalReg = 100 - pRecuperacion;
				IF iTotalReg < pRecuperacion THEN
					LET pRecuperacion = iTotalReg;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '1001';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- VALIDAMOS QUE LA TABLA TENGA DATOS
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catzonas;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		--CONSULTA CIUDAD Y COLONIA
		SELECT numerociudad, numerocolonia 
		INTO  cCiudad, cNumColonia
		FROM bdinteg:"informix".si_direcciones_actual
		WHERE numcte = pCliente
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pCliente AND tipo_dir = '1');
		
		IF pTipoConsulta = 1 THEN -- Tipo de consulta general
			FOREACH	
			
                    SELECT  a.numerocolonia, a.nombrezona,a.municipiozona 
                     INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                      FROM (
					   SELECT numerocolonia, nombrezona,municipiozona
                       FROM bdinteg:"informix".si_catzonas
                       WHERE numerociudad = cCiudad 
                       AND numerocolonia = cNumColonia) a
				     UNION ALL
					  SELECT   b.numerocolonia, b.nombrezona,b.municipiozona 
					  FROM (
					   SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                       FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                       WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					   and lpad(a.codigopostalzona,5,'0') = b.d_codigo
                       and TRIM(a.nomzona_spmx) = b.d_asenta
                       and TRIM(a.mnpio_spmx) = b.d_mnpio
                       GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC ) b
					
					LET iNoRegistros = iNoRegistros + 1;
					
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
		ELIF pTipoConsulta = 2 THEN
			FOREACH					
					SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                    INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                    FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                    WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					 and lpad(a.codigopostalzona,5,'0') = b.d_codigo
					 and nombrezona LIKE '%' || TRIM(pConsulta) || '%'
                     and TRIM(a.nomzona_spmx) = b.d_asenta
                     and TRIM(a.mnpio_spmx) = b.d_mnpio
                    GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC
					
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
		END IF;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las ciudades",
"FECHA: 04/02/2025",
"AUTOR: Veronica Sanchez",
"DESCRIPCION: Se clona procedimiento almacenado para limitar la consulta a 100 registros",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_consaldodisp(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pSistemaCuenta CHAR(2))
        RETURNING 
                CHAR(5) AS codret,
                DECIMAL(14,2) AS saldo_disponible;
        
        DEFINE cCodRet CHAR(5);
        DEFINE dSaldoDisponible DECIMAL(14,2);
        DEFINE iSqlErr INTEGER;
        DEFINE cNumProductoCred CHAR(4);
        DEFINE cCodTipoCred CHAR(2);
        
        LET dSaldoDisponible = 0;
        LET iSqlErr = 0;
        LET cCodRet = '00000';
        LET cNumProductoCred = '';
        LET cCodTipoCred = '';
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, dSaldoDisponible;
                        
                        END IF;
                END EXCEPTION;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, dSaldoDisponible;
                END IF;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pSistemaCuenta = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, dSaldoDisponible;
                END IF;
                
                IF pSistemaCuenta NOT IN ('01', '03', '06') THEN
                        LET cCodRet = '00037';
                END IF;
                
                IF pSistemaCuenta = '01' THEN
                        
                        --SET ISOLATION TO DIRTY READ;
                        --RQM 09 704. Se agrega el valor del campo saldo_sbc al calculo de saldo disponible. DHG
                        SELECT  sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc) AS saldo_disponible
                        INTO dSaldoDisponible
                        FROM  bdicheq:"informix".sc_maechq
                        WHERE cuenta = pCuenta AND empresa='001';
                        
                        RETURN cCodRet, dSaldoDisponible;
                        
                ELIF pSistemaCuenta = '03' THEN
                        
                        --SET ISOLATION TO DIRTY READ;
                        
                        SELECT NVL(mi.capital, 0)
                        INTO dSaldoDisponible
                        FROM bdinvers:sv_maeinv mi
                        WHERE mi.cuenta = pCuenta
                                AND mi.secuencia = (SELECT NVL(MAX(secuencia),0) FROM bdinvers:sv_maeinv WHERE empresa = mi.empresa and cuenta = mi.cuenta);
                
                        RETURN cCodRet, dSaldoDisponible;
                ELIF pSistemaCuenta = '06' THEN
                        
                        --SET ISOLATION TO DIRTY READ;
                        
                        SELECT d.num_producto, d.cod_tipcred
                        INTO cNumProductoCred, cCodTipoCred
                        FROM bdicred:"informix".sd_maecred c, bdicred:"informix".sd_definicion d
                        WHERE c.empresa ='001'  
								AND c.num_credito = pCuenta
                                AND d.empresa = c.empresa
                                AND d.num_producto = c.num_producto;
                                
                        
                        IF cNumProductoCred IN ('6001','8100','7000','8500', '5400') THEN -- Tarjeta de Credito Bancoppel Visa, ORO Y PLATINO , Se agrega TDC GC
                                --SET ISOLATION TO DIRTY READ;
                                
                                --SELECT (NVL(m2.monto_otorgado,0) - NVL(m2.sdo_cap_insoluto,0) - NVL(m2.sdo_retenido,0))
								SELECT NVL(m2.sdo_capital,0)
                                INTO dSaldoDisponible
                                FROM bdicred:"informix".sd_maesdos m2
                                WHERE num_credito = pCuenta AND empresa='001';
                        ELIF cCodTipoCred = '05' THEN -- Prestamo Personal
                                --SET ISOLATION TO DIRTY READ;
                                
                                SELECT m2c.sdo_capital
                                INTO dSaldoDisponible
                                FROM bdicred:"informix".sd_maesdoscrd m2c
                                WHERE m2c.num_credito = pCuenta;
                        END IF;
                        
                        RETURN cCodRet, dSaldoDisponible;
                END IF;
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 14/04/2014',
'DESCRIPCION: Consulta el saldo disponible de una cuenta de captacion/inversion/credito',
'BD: bdicnweb',
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 05-06-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicnweb',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_ope_cons_ticketabonoapp_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pFolioSuc CHAR(16), pHuella CHAR(1), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
				CHAR(5) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(15) AS origen,  
				CHAR(20) AS numCuenta,
				CHAR(16) AS numTarjeta,
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(10) AS telefono, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(100) AS retorno2,
				CHAR(150) AS retorno3;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(5);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(15);  
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cNumcuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cRetorno2 CHAR(100);
	DEFINE cRetorno3 CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cOrigen = ''; 
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cTelefono = ''; 
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cNumcuenta = '';
	LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cRetorno2 = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketAbonoApp_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' OR pFolioSuc = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END IF;

		IF ((SELECT COUNT(referencia1) FROM bdisac:"informix".sac_movimientoshistorial WHERE referencia1 = pReferencia AND numconvenio IN ('004','006','007','008','009')) <> 0) THEN

			SELECT  FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis AS c ON c.folio_suc =  a.folio_suc AND c.sucursal = '5011'
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte   
			INNER JOIN bdinteg:"informix".si_telefonos_actual as g ON g.numcte = f.numcte
			WHERE a.referencia1 = pReferencia 
			  AND a.folio_suc = pFolioSuc 
			  AND a.forma_pago = '4'			 
			  AND a.status_cancelado <> 'S';

		ELSE
			--REMESAS DE MAS DE 3 MESES
			SELECT  FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial_old AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis_old AS c ON c.folio_suc =  a.folio_suc AND c.sucursal = '5011'
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte   
			INNER JOIN bdinteg:"informix".si_telefonos as g ON g.numcte = f.numcte
			WHERE a.referencia1 = pReferencia 
			  AND a.folio_suc = pFolioSuc 
			  AND a.forma_pago = '4' 
			  AND a.status_cancelado <> 'S';
		END IF;

		IF LEN(cOrigen) = 0 THEN
				LET cOrigen = 'BCL';
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00029';
			LET cRetorno3 = 'B6 - No se encontro informacion del cliente';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		ELSE
			IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas WHERE num_confirmacion = pReferencia) <> 0) THEN 

				SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
				TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
				INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
				FROM bdisac:"informix".sac_pld_remesas
				WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
			ELSE
				IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas_old WHERE num_confirmacion = pReferencia) <> 0 ) THEN  

					SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
					TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
					INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
					FROM bdisac:"informix".sac_pld_remesas_old
					WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
				ELSE
					LET cCodRet= '00034';
					LET cRetorno3 = 'B6 - No se encontro informacion relacionada';
					RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
						cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
				END IF;			
			END IF;
		
			SELECT MAX(secuencia) 
				INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND estado = 'A';

			SELECT dmapa 
				INTO cCadenaTran
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND secuencia = cSecuenciaMax;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCadenaTran = '';
			END IF;
			
			SELECT nombre, plaza 
				INTO cNomSucursal, cPlaza 
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = cSucursal;
			
			SELECT nombre 
				INTO cNomPlaza 
			FROM bdinteg:"informix".si_plazas
			WHERE plaza = cPlaza;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cNomPlaza = '';
			END IF;
		
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
				INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
				cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;
				
				LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
					
			END IF;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'MODIFICACION: FG',
'FECHA: 28/09/2025',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informacion para formato Abono App',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketabonovent_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1), pNumCliente CHAR(20))
	RETURNING   CHAR(5) AS codret,
				CHAR(3) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc,
				CHAR(15) AS origen, 
				CHAR(20) AS numCuenta,
				CHAR(16) AS numTarjeta,
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(10) AS telefono, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(100) AS retorno2,
				CHAR(150) AS retorno3;
				
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(15); 
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cNumcuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cRetorno2 CHAR(100); 
	DEFINE cRetorno3 CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cOrigen = ''; 

	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cTelefono = ''; 
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cNumcuenta = '';
	LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cRetorno2 = '';  
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketAbonoVent_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END IF;
		
		IF ((SELECT COUNT(referencia1) FROM bdisac:"informix".sac_movimientoshistorial WHERE referencia1 = pReferencia AND numconvenio IN ('004','006','007','008','009')) <> 0 ) THEN

			SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, 
			CASE WHEN c.sucursal = '5011' THEN a.sucursal_cpl ELSE a.id_sucursal END, 
			TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis AS c ON c.folio_suc =  a.folio_suc AND c.sucursal NOT IN ('9250','9764') 
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
			INNER JOIN bdinteg:"informix".si_telefonos_actual as g ON g.numcte = f.numcte
			WHERE a.referencia1 = pReferencia 
			  AND a.forma_pago = '4';

		ELSE 
			--REMESAS DE MAS DE 3 MESES
			SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, 
			CASE WHEN c.sucursal = '5011' THEN a.sucursal_cpl ELSE a.id_sucursal END, 
			TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial_old AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND  b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis_old AS c ON c.folio_suc =  a.folio_suc AND c.sucursal NOT IN ('9250','9764')
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
			INNER JOIN bdinteg:"informix".si_telefonos_actual as g ON g.numcte = f.numcte 
			WHERE a.referencia1 = pReferencia 
			AND a.forma_pago = '4';
		END IF;

		IF LEN(cOrigen) = 0 THEN
			LET cOrigen = 'BCL';
		END IF;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00021';
			LET cRetorno3 = 'B4 - No se encontro informacion del cliente';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		ELSE

			IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas WHERE num_confirmacion = pReferencia) <> 0) THEN 

				SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
				TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
				INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
				FROM bdisac:"informix".sac_pld_remesas
				WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
			ELSE
				IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas_old WHERE num_confirmacion = pReferencia) <> 0 ) THEN 

					SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
					TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
					INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
					FROM bdisac:"informix".sac_pld_remesas_old  
					WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
				ELSE
					LET cCodRet= '00033';
					LET cRetorno3 = 'B4 - No se encontro informacion relacionada';
					RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
				END IF;			
			END IF;	
					
			SELECT MAX(secuencia) 
				INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella 
			WHERE numcte = cNumcliente
			AND estado = 'A';

			SELECT dmapa 
				INTO cCadenaTran
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND secuencia = cSecuenciaMax;
				
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCadenaTran = '';
			END IF;

			SELECT nombre, plaza 
				INTO cNomSucursal, cPlaza 
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = cSucursal;
			
			SELECT nombre 
				INTO cNomPlaza 
			FROM bdinteg:"informix".si_plazas
			WHERE plaza = cPlaza;
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cNomPlaza = '';
			END IF;
				
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				
				EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
				INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
				cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;
					
				LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
							
			END IF;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
				   cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'MODIFICACION: FG',
'FECHA: 28/09/2025',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Abono por Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketefectivovent_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1))
	RETURNING CHAR(5) AS codret,
				CHAR(5) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(15) AS origen,  
				CHAR(4) AS sucursal,  
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(10) AS telefono,  
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(20) AS cuenta,
				CHAR(16) AS tarjeta,
				CHAR(100) AS retorno2,
				CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(5);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(15); 
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	DEFINE cRetorno2 CHAR(100);
	DEFINE cRetorno3 CHAR(150);

	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cCuenta VARCHAR(20);
	DEFINE cTarjeta VARCHAR(16);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cOrigen = ''; 
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cTelefono = ''; 
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET cRetorno2 = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketEfectivoVent_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
			END IF;

			IF ((SELECT COUNT(referencia1) FROM bdisac:"informix".sac_movimientoshistorial WHERE referencia1 = pReferencia AND numconvenio IN ('004','006','007','008','009')) <> 0) THEN 

				SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen
				INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen
				FROM bdisac:"informix".sac_movimientoshistorial AS a
				INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio
				WHERE b.numcategoria = '07' 
				  AND a.referencia1 = pReferencia;

			ELSE 
				--REMESAS DE MAS DE 3 MESES
				SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen
				INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen
				FROM bdisac:"informix".sac_movimientoshistorial_old AS a
				INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio
				WHERE b.numcategoria = '07' 
				  AND a.referencia1 = pReferencia;

			END IF; 

			IF LEN(cOrigen) = 0 THEN
				LET cOrigen = 'BCL';
			END IF;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN 
				LET cCodRet= '00022';
				LET cRetorno3 = 'B5 - No se encontro informacion del cliente';
				RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
			ELSE
				--/////////WESTERN UNION/////////
				IF cNumConvenio = '006' OR cNumConvenio = '007' OR cNumConvenio = '008'  THEN 

					IF ((SELECT COUNT(mtcn) FROM bdisac:"informix".sac_wu_pay WHERE mtcn = cReferencia) <> 0 ) THEN 

						SELECT
							wu.benef_nombre1,
							wu.benef_nombre2,
							wu.benef_appaterno,
							wu.benef_apmaterno,
							wu.benef_id_number,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno)
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
						FROM bdisac:"informix".sac_wu_pay AS wu 
						INNER JOIN bdisac:"informix".sac_pld_remesas AS pld ON wu.mtcn = pld.num_confirmacion AND wu.foreign_rs_refnum_rp= pld.folio_sucursal 
						WHERE wu.mtcn = cReferencia 
						  AND wu.foreign_rs_refnum_rp = cFolioSuc;

						--/////////si los datos vienen vacios se consulta los datos en las tablas QRY--
						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
								
							SELECT
								wu.benef_nombre1,
								wu.benef_nombre2,
								wu.benef_appaterno,
								wu.benef_apmaterno,
								wu.benef_id_number,
								TRIM(s.emisor_nombre1) || ' ' || TRIM(s.emisor_nombre2) || ' ' || 
								TRIM(s.emisor_appaterno) || ' ' || TRIM(s.emisor_apmaterno)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_wu_pay AS wu 
							INNER JOIN bdisac:"informix".sac_wu_search AS s ON wu.mtcn = s.mtcn 	
							WHERE s.mtcn = cReferencia 
							  AND s.foreign_rs_refnum_rp = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00023';
								LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					ELSE 
						--REMESAS DE MAS DE 3 MESES
						IF ((SELECT COUNT(mtcn) FROM bdisac:"informix".sac_wu_pay_old WHERE mtcn = cReferencia) <> 0 ) THEN
							
							SELECT
									wu.benef_nombre1,
									wu.benef_nombre2,
									wu.benef_appaterno,
									wu.benef_apmaterno,
									wu.benef_id_number,
									TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
									TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno)
								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
								FROM bdisac:"informix".sac_wu_pay_old AS wu 
								INNER JOIN bdisac:"informix".sac_pld_remesas_old AS pld ON wu.mtcn = pld.num_confirmacion AND wu.foreign_rs_refnum_rp= pld.folio_sucursal  
								WHERE wu.mtcn = cReferencia 
								  AND wu.foreign_rs_refnum_rp = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
										
								SELECT
									wu.benef_nombre1,
									wu.benef_nombre2,
									wu.benef_appaterno,
									wu.benef_apmaterno,
									wu.benef_id_number,
									TRIM(s.emisor_nombre1) || ' ' || TRIM(s.emisor_nombre2) || ' ' || 
									TRIM(s.emisor_appaterno) || ' ' || TRIM(s.emisor_apmaterno)
								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
								FROM bdisac:"informix".sac_wu_pay_old AS wu 
								INNER JOIN bdisac:"informix".sac_wu_search_old AS s ON wu.mtcn = s.mtcn 
								WHERE s.mtcn = cReferencia 
								  AND s.foreign_rs_refnum_rp = cFolioSuc;

								IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
									TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

									LET cCodRet= '00024';
									LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
									RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
										cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
								END IF;
							END IF;
						END IF;
					END IF;

				--/////////BTS/////////
				ELIF cNumConvenio = '004' THEN

					IF ((SELECT COUNT(confirmation_nm) FROM bdisac:"informix".sac_bts_payi WHERE confirmation_nm = cReferencia) <>0) THEN

						SELECT
							bts.r_first_name,
							bts.r_middle_name,
							bts.r_last_name,
							bts.r_mother_m_name,
							bts.r_identif_nm,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
						FROM bdisac:"informix".sac_bts_payi AS bts 
						INNER JOIN bdisac:"informix".sac_pld_remesas AS pld ON bts.confirmation_nm = pld.num_confirmacion AND bts.bank_ref_nm = pld.folio_sucursal 
						WHERE bts.confirmation_nm = cReferencia 
						  AND bts.bank_ref_nm = cFolioSuc;

						-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
				
							SELECT
								bts.r_first_name,
								bts.r_middle_name,
								bts.r_last_name,
								bts.r_mother_m_name,
								bts.r_identif_nm,
								TRIM(s.s_first_name) || ' ' || TRIM(s.s_middle_name) || ' ' || 
								TRIM(s.s_last_name) || ' ' || TRIM(s.s_mother_m_name)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_bts_payi AS bts 
							INNER JOIN bdisac:"informix".sac_bts_qryi AS s ON bts.confirmation_nm = s.confirmation_nm 	
							WHERE bts.confirmation_nm = cReferencia 
							  AND bts.bank_ref_nm = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00025';
								LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					ELSE 
						--REMESAS DE MAS DE 3 MESES
						IF ((SELECT COUNT(confirmation_nm) FROM bdisac:"informix".sac_bts_payi_old WHERE confirmation_nm = cReferencia) <>0) THEN

							SELECT
								bts.r_first_name,
								bts.r_middle_name,
								bts.r_last_name,
								bts.r_mother_m_name,
								bts.r_identif_nm,
								TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
								TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
							FROM bdisac:"informix".sac_bts_payi_old AS bts 
							INNER JOIN bdisac:"informix".sac_pld_remesas_old AS pld ON bts.confirmation_nm = pld.num_confirmacion AND bts.bank_ref_nm = pld.folio_sucursal 
							WHERE bts.confirmation_nm = cReferencia 
							  AND bts.bank_ref_nm = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
				
								SELECT
									bts.r_first_name,
									bts.r_middle_name,
									bts.r_last_name,
									bts.r_mother_m_name,
									bts.r_identif_nm,
									TRIM(s.s_first_name) || ' ' || TRIM(s.s_middle_name) || ' ' || 
									TRIM(s.s_last_name) || ' ' || TRIM(s.s_mother_m_name)
								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
								FROM bdisac:"informix".sac_bts_payi_old AS bts 
								INNER JOIN bdisac:"informix".sac_bts_qryi_old AS s ON bts.confirmation_nm = s.confirmation_nm	
								WHERE bts.confirmation_nm = cReferencia 
								  AND bts.bank_ref_nm = cFolioSuc;

								IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
									TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

									LET cCodRet= '00026';
									LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
									RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
										cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
								END IF;
							END IF;
						END IF;
					END IF;

				--/////////APP/////////
				ELIF cNumConvenio = '009' THEN

					IF ((SELECT COUNT(unirefnum) FROM bdisac:"informix".sac_app_payi WHERE unirefnum = cReferencia) <> 0) THEN
	
						SELECT FIRST 1
							app.firstname,
							app.middlename,
							app.lastname,
							app.mommaidenname,
							app.numberci,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
						FROM bdisac:"informix".sac_app_payi AS app 
						INNER JOIN bdisac:"informix".sac_pld_remesas AS pld 
						ON app.unirefnum = pld.num_confirmacion AND
						app.refnum = pld.folio_sucursal 
						WHERE app.unirefnum = cReferencia AND
						app.refnum=cFolioSuc;

					-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
							
							SELECT FIRST 1
								app.firstname,
								app.middlename,
								app.lastname,
								app.mommaidenname,
								app.numberci,
								TRIM(s.r_firstname) || ' ' || TRIM(s.r_middlename) || ' ' || 
								TRIM(s.r_lastname) || ' ' || TRIM(s.r_mommaidenname)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_app_payi AS app 
							INNER JOIN bdisac:"informix".sac_app_qryi AS s ON app.unirefnum = s.unirefnum 
							WHERE s.unirefnum = cReferencia 
							  AND app.refnum = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00027';
								LET cRetorno3 = 'No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					ELSE 
					--REMESAS DE MAS DE 3 MESES
					IF ((SELECT COUNT(unirefnum) FROM bdisac:"informix".sac_app_payi_old WHERE unirefnum = cReferencia) <> 0) THEN

						SELECT
							app.firstname,
							app.middlename,
							app.lastname,
							app.mommaidenname,
							app.numberci,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
						FROM bdisac:"informix".sac_app_payi_old AS app 
						INNER JOIN bdisac:"informix".sac_pld_remesas_old AS pld ON app.unirefnum = pld.num_confirmacion AND app.refnum = pld.folio_sucursal 
						WHERE app.unirefnum = cReferencia 
						  AND app.refnum = cFolioSuc;

						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
				
							SELECT
								app.firstname,
								app.middlename,
								app.lastname,
								app.mommaidenname,
								app.numberci,
								TRIM(s.r_firstname) || ' ' || TRIM(s.r_middlename) || ' ' || 
								TRIM(s.r_lastname) || ' ' || TRIM(s.r_mommaidenname)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_app_payi_old AS app 
							INNER JOIN bdisac:"informix".sac_app_qryi_old AS s ON app.unirefnum = s.unirefnum 
							WHERE s.unirefnum = cReferencia 
							  AND app.refnum = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00028';
								LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					END IF;
				END IF; 
			END IF;  


			SELECT numcte
			INTO cNumcliente 
			FROM bdinteg:"informix".si_cliente 
			WHERE apell_paterno	= cApPaternoBen
			  AND apell_materno = cApMaternoBen
			  AND nombre1 = cNombre1Ben
			  AND nombre2 = cNombre2Ben;


			SELECT FIRST 1 telefono
			INTO cTelefono 
			FROM bdinteg:"informix".si_telefonos_actual
			WHERE numcte = cNumcliente
			  AND status_tel = 'A';
			

			SELECT MAX(secuencia) 
			INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND estado = 'A';

			SELECT dmapa 
			INTO cCadenaTran
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND secuencia = cSecuenciaMax;
						
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCadenaTran = '';
					END IF;

						SELECT nombre, plaza 
						INTO cNomSucursal, cPlaza 
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cSucursal;
							
						SELECT nombre 
						INTO cNomPlaza 
						FROM bdinteg:"informix".si_plazas
						WHERE plaza = cPlaza;
				
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cNomPlaza = '';
						END IF;
					
							IF DBINFO('sqlca.sqlerrd2') > 0 THEN
								EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
								INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
								cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;	
								LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
							END IF;

							RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					               cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
				END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: FG',
'FECHA: 28/09/2025',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Efectivo Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consmovimientos_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pRemesadora CHAR(10), pFechaInicio DATE, pFechaFin DATE, pCveRemesa CHAR(20),
													pNumCliente CHAR(9), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  CHAR(3) AS numconvenio,
			  CHAR(40) AS nomconvenio,
			  CHAR(20) AS num_cte,
			  DATE AS fech_oper,
			  CHAR(4) AS sucursal,
			  CHAR(16) AS folio_suc,
			  CHAR(40) AS referencia1,
			  CHAR(100) AS nomCliente,
			  CHAR(150) AS retorno3,
			  CHAR(1) AS formaPago,
			  CHAR(8) AS usuario;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumconvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE cNum_cte CHAR(20);
	DEFINE dFech_oper DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cFolio_suc CHAR(16);
	DEFINE iTotRegistros INTEGER;
	DEFINE iTotRegistros2 INTEGER;
	DEFINE cReferencia1 CHAR(40);
	DEFINE cNomCliente CHAR(100);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cAppPaterno CHAR(26);
	DEFINE cAppMaterno CHAR(26);
	DEFINE cRetorno3 CHAR(150);
	DEFINE cFormaPago CHAR(1);
	DEFINE cUsuario CHAR(8);


	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumconvenio = '';
	LET cNomconvenio = '';
	LET cNum_cte = '';
	LET dFech_oper = '';
	LET cSucursal = '';
	LET cFolio_suc = '';
	LET iTotRegistros = 0;
	LET iTotRegistros2 = 0;
	LET cReferencia1 = '';
	LET cNomCliente = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cAppPaterno = '';
	LET cAppMaterno = '';
	LET cRetorno3 = '';
	LET cFormaPago = '';
	LET cUsuario = '';


	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END EXCEPTION;
	 
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consmovimientos_web.out';
		-- TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCveRemesa = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END IF;		
		
		--VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END IF;


		IF ((SELECT COUNT(referencia1) FROM bdisac:sac_movimientoshistorial WHERE referencia1 = pCveRemesa) <> 0) THEN   
								
			IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial AS a INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN 
									
				SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
				INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
				FROM bdisac:sac_movimientoshistorial AS a
				INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc 
				INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
				INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
				LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
				WHERE a.forma_pago IN (4 , 1) 
				AND b.sucursal NOT IN ('9250','9764','9251') 
				AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
				AND c.numcategoria = '07' 
				AND b.cancelad <> 'S' 
				AND a.status_cancelado <> 'S'
				AND a.numconvenio IN ('004','006','007','008','009') 
				AND a.referencia1 = pCveRemesa; 

					IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
						TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

							LET cCodRet= '00017';
							LET cRetorno3 = 'No se encontro informacion del cliente';
							RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
					END IF; 
				RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
			ELSE
				IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial AS a INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN
			
					SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
					INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
					FROM bdisac:sac_movimientoshistorial AS a
					INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc 
					INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
					INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
					LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
					WHERE a.forma_pago IN (4 , 1) 
					AND b.sucursal NOT IN ('9250','9764','9251') 
					AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
					AND c.numcategoria = '07' 
					AND b.cancelad <> 'S' 
					AND a.status_cancelado <> 'S'
					AND a.numconvenio IN ('004','006','007','008','009') 
					AND a.referencia1 = pCveRemesa; 

						IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
							TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

								LET cCodRet= '00017';
								LET cRetorno3 = 'No se encontro informacion del cliente';
								RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
						END IF; 	
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
				ELSE 	
					LET cCodRet= '00018';
					LET cRetorno3 = 'No se encontro informacion relacionada';
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;			
				END IF;
			END IF;
		ELSE	
			IF ((SELECT COUNT(referencia1) FROM bdisac:sac_movimientoshistorial_old WHERE referencia1 = pCveRemesa) <> 0) THEN		

				IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial_old AS a INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN

					SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
					INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
					FROM bdisac:sac_movimientoshistorial_old AS a
					INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc 
					INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
					INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
					LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
					WHERE a.forma_pago IN (4 , 1) 
					AND b.sucursal NOT IN ('9250','9764','9251') 
					AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
					AND c.numcategoria = '07' 
					AND b.cancelad <> 'S' 
					AND a.status_cancelado <> 'S'
					AND a.numconvenio IN ('004','006','007','008','009') 
					AND a.referencia1 = pCveRemesa; 

						IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
							TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

								LET cCodRet= '00017';
								LET cRetorno3 = 'No se encontro informacion del cliente';
								RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
						END IF; 	
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
				ELSE 
					IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial_old AS a INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN

						SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
						INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
						FROM bdisac:sac_movimientoshistorial_old AS a
						INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc 
						INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
						INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
						LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
						WHERE a.forma_pago IN (4 , 1) 
						AND b.sucursal NOT IN ('9250','9764','9251') 
						AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
						AND c.numcategoria = '07' 
						AND b.cancelad <> 'S' 
						AND a.status_cancelado <> 'S'
						AND a.numconvenio IN ('004','006','007','008','009') 
						AND a.referencia1 = pCveRemesa; 

							IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
								TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

									LET cCodRet= '00017';
									LET cRetorno3 = 'No se encontro informacion del cliente';
									RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
							END IF; 	
						RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
					ELSE 	
						LET cCodRet= '00018';
						LET cRetorno3 = 'No se encontro informacion relacionada';
						RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
					END IF;
				END IF;	
			END IF;
		END IF; 												
	END
END PROCEDURE
DOCUMENT 'AUTOR: FG ',
'FECHA: 29/07/2024',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃÂ³n para grid de datos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogocajageneral(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING 	CHAR(5) AS codret,
					CHAR(4) AS cIdProvCaja,
            		CHAR(30) AS cDescCaja;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdProvCaja CHAR(4);
    DEFINE cDescCaja CHAR(30);
	DEFINE cPlazaCaja CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdProvCaja = '';
	LET cDescCaja = '';
	LET cPlazaCaja = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocajageneral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;
		
		--SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		
		-- COMBOBOX CAJA GENERAL 
		IF pTipo = '1' THEN --Por codigo
		
			FOREACH		
				SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor, descripcion, plaza 
				INTO cIdProvCaja, cDescCaja, cPlazaCaja FROM bdisuc:'informix'.ss_proveedores ORDER BY descripcion
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		ELIF pTipo = '2' THEN --Por descripcion
		
			FOREACH	 
				SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor, descripcion, plaza
				INTO cIdProvCaja, cDescCaja, cPlazaCaja FROM bdisuc:'informix'.ss_proveedores ORDER BY descripcion
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		END IF;

		IF pRegistros = 0 AND iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);

		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ¯Â¿Â½n Amador',
'FECHA: 07/01/2015',
'DESCRIPCION: SPL, que hace la consulta para el llenado del combobox caja general, Monitor de Operaciones Caja General',
'AUTOR: Jose Antonio Ramirez Franco',
'FECHA MODIFICACION: 17/07/2023',
'DESCRIPCION: Se aÃÂ±adio paginado para cada una de las opciones del SP',
'AUTOR: Veronica Sanchez Tlacomulco TASF',
'FECHA MODIFICACION: 28/08/2025',
'DESCRIPCION: Se realizo un mantenimiento para aplicar de forma correcta el tratamiento del paginado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargacod41_ccep(pUsuario CHAR(8), pIdFuncion CHAR(10),pnombrearchivo CHAR(30), pRutaArchivo CHAR(60), pDireccionMac CHAR(15))
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS bBanDetalle,
				  DECIMAL(20,2) AS	importeTotal; 
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE cNumSecuencia CHAR(7); 
	DEFINE cCodOperacion  CHAR(2);
	DEFINE cFechatrasnfer  CHAR(8);
	DEFINE cBancoCedente  CHAR(3);
	DEFINE cBancoLibrado  CHAR(3);
	DEFINE cImporte  CHAR(15);
	DEFINE cLoteEntrada  CHAR(7);
	DEFINE cSecEntrada  CHAR(4);
	DEFINE cLoteSAlida  CHAR(7);
	DEFINE cSecSalida  CHAR(4);
	DEFINE cTransaccion  CHAR(2);
	DEFINE cChqCompensacion CHAR(3);
	DEFINE cCuentaReferencia CHAR(13);
	DEFINE cNumCheque CHAR(10);
	DEFINE cChqDigVerInter CHAR(1);
	DEFINE cChqDigVerPre CHAR(1);
	DEFINE cChqCodSeguridad CHAR(3);
	DEFINE cUbicFis CHAR(8);
	DEFINE cTruncado CHAR(1);
	DEFINE cMotivoDevol CHAR(2);
	DEFINE cFechaInicial CHAR(8);
	DEFINE cPlazaIntercam CHAR(2);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(18);
	DEFINE cTipoCuentaDep CHAR(2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cNombreCte CHAR(40);
	DEFINE cCtaAlertamiento CHAR(2);
	DEFINE cFolioSeguro CHAR(12);
	DEFINE cUsoFuturo CHAR(120);	
	DEFINE dImporte DECIMAL(16,2);
	DEFINE dImporte2 DECIMAL(16,2);
	DEFINE cMonto CHAR(12);
	DEFINE cCents CHAR(2);
	DEFINE mImporte CHAR(15);
	DEFINE importeTotal DECIMAL(20,2);	
	DEFINE cDescbancoLibrado CHAR(30);
	DEFINE cMotivoDevolucion CHAR(30);
	DEFINE cObservaciones CHAR(50);
	DEFINE bBanderaError CHAR(1);
	DEFINE cMiBanco CHAR(4);
	DEFINE cprocesar CHAR(2);
	DEFINE cFechaformat CHAR(8);
	DEFINE cValidaPresentado CHAR(50);
	DEFINE cFechaDevol CHAR(10);
	DEFINE cFechaHoy CHAR(10);
	DEFINE iNoPresentado INTEGER;
	DEFINE cValidaProceso CHAR(30);
	DEFINE bBanDet CHAR(1);
	DEFINE ven_transacc SMALLINT;
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cSQL CHAR(250);
	DEFINE iNoProcesado INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE cPathdbaccess CHAR(20);
	DEFINE cMotivoDevCompleto CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET cNumSecuencia = '';
	LET cCodOperacion  = '';
	LET cFechatrasnfer  = '';
	LET cBancoCedente  = '';
	LET cBancoLibrado  = '';
	LET cImporte  = '';
	LET cLoteEntrada  = '';
	LET cSecEntrada  = '';
	LET cLoteSAlida  = '';
	LET cSecSalida  = '';
	LET cTransaccion  = '';
	LET cChqCompensacion = '';
	LET cCuentaReferencia = '';
	LET cNumCheque = '';
	LET cChqDigVerInter = '';
	LET cChqDigVerPre = '';
	LET cChqCodSeguridad = '';
	LET cUbicFis = '';
	LET cTruncado = '';
	LET cMotivoDevol = '';
	LET cFechaInicial = '';
	LET cPlazaIntercam = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET cTipoCuentaDep = '';
	LET cCuentaDeposito = '';
	LET cNombreCte = '';
	LET cCtaAlertamiento = '';
	LET cFolioSeguro = '';
	LET cUsoFuturo = '';
	LET dImporte= 0.00;
	LET dImporte2= 0.00;
	LET cMonto = '';
	LET cCents = '';
	LET mImporte = '';
	LET importeTotal = 0.00;
	LET cDescbancoLibrado = '';
	LET cMotivoDevolucion = '';
	LET cObservaciones = '';
	LET bBanderaError = 'f';
	LET cMiBanco = '';
	LET cprocesar = '';
	LET cFechaformat = '';
	LET cValidaPresentado = '';
	LET cFechaDevol = '';
	LET cFechaHoy ='';
	LET iNoPresentado = 0;
	LET cValidaProceso = '';
	LET bBanDet = '';
	LET ven_transacc = 0;
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';	
	LET cSQL = '';
	LET iNoProcesado = '';
	LET bInTransaction = 'f';
	LET cPathdbaccess = '/ifxsif01/bin/';
	LET cMotivoDevCompleto = '';
	
	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				Let cCodret = cSqlerr;      
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;			
				END IF;
			   RETURN cCodRet,bBanDet,importeTotal; 
			END IF;
		END EXCEPTION;		
		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cargacod41_ccep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pnombrearchivo = '' OR pRutaArchivo = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,bBanDet,importeTotal; 
		END IF;
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,bBanDet,importeTotal; 
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			--- CREAR LA TABLA DE TEMPORAL
			DELETE FROM bdicnweb:"informix".ccep_generacioncod41_tmp;
			
			DELETE FROM bdicnweb:"informix".ccep_procesacod41detalle_tmp;																	
			
			LET cSQL = '';
			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
			LET cSQL = 'echo "SET ISOLATION TO DIRTY READ; LOAD FROM '  ||trim(pRutaArchivo) || pnombrearchivo || ' INSERT INTO bdicnweb:"informix".ccep_generacioncod41_tmp(linea)" > '|| trim(pRutaArchivo) || 'Temporal.sql';
			SYSTEM cSQL;

			LET cSQL = '';
			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			Let cSQL = TRIM(cPathdbaccess)||'dbaccess bdicnweb ' ||trim(pRutaArchivo)|| 'Temporal.sql'; --Se activa para desarrollo 
			COMMIT WORK;
			SYSTEM cSQL;
			BEGIN WORK;
			
			-- fecha habil actual
			SELECT fecha_hoy INTO cFechaHoy FROM bdicheq:sc_fechas WHERE empresa = cEmpresa;
			
			--03/04/2016 calcula fecha de devolucion habilm ant
			EXECUTE PROCEDURE bditef:cal_habil_ant(cFechaHoy) INTO cCodRetsp, cFechaDevol;
			LET iCodRetSp = cCodRetSp::INTEGER;
	
			IF  iCodRetSp <> '000' THEN													  
				ROLLBACK WORK;
				LET ven_transacc = 0;
				let cCodret = '666';
				RETURN cCodRet,bBanDet,importeTotal;
			END IF;
			
		COMMIT WORK;
		
		BEGIN WORK;
			--consulta banco propietario
			SELECT valor INTO cMiBanco FROM bdinteg:si_param WHERE empresa = cEmpresa AND cod_param = '5';
			
			FOREACH SELECT linea INTO cRenglon FROM bdicnweb:"informix".ccep_generacioncod41_tmp ORDER BY(id_serial)
				IF SUBSTR(cRenglon,1,2) = "02" THEN
					LET cNumSecuencia = SUBSTR(cRenglon,3,7);
					LET cCodOperacion = SUBSTR(cRenglon,10,2);
					LET cFechatrasnfer =SUBSTR(cRenglon,12,8); 
					LET cBancoCedente = SUBSTR(cRenglon,20,3);
					LET cBancoLibrado = SUBSTR(cRenglon,23,3);
					LET cImporte = SUBSTR(cRenglon,26,15);
					LET cLoteEntrada = SUBSTR(cRenglon,41,7);
					LET cSecEntrada = SUBSTR(cRenglon,48,4);
					LET cLoteSAlida = SUBSTR(cRenglon,52,7);
					LET cSecSalida = SUBSTR(cRenglon,59,4);
					LET cTransaccion = SUBSTR(cRenglon,63,2);
					LET cChqCompensacion = SUBSTR(cRenglon,65,3);
					LET cCuentaReferencia = SUBSTR(cRenglon,68,13);
					LET cNumCheque = SUBSTR(cRenglon,81,10);
					LET cChqDigVerInter = SUBSTR(cRenglon,91,1);
					LET cChqDigVerPre = SUBSTR(cRenglon,92,1);
					LET cChqCodSeguridad = SUBSTR(cRenglon,93,3);
					LET cUbicFis = SUBSTR(cRenglon,96,8);
					LET cTruncado = SUBSTR(cRenglon,104,1);
					LET cMotivoDevol = SUBSTR(cRenglon,105,2);
					LET cFechaInicial = SUBSTR(cRenglon,107,8);
					LET cPlazaIntercam = SUBSTR(cRenglon,115,2);
					LET cRfcCte = SUBSTR(cRenglon,117,13);
					LET cCurpCte = SUBSTR(cRenglon,130,18);
					LET cTipoCuentaDep = SUBSTR(cRenglon,148,2);
					LET cCuentaDeposito = SUBSTR(cRenglon,150,20);
					LET cNombreCte = SUBSTR(cRenglon,170,40);
					LEt cCtaAlertamiento = SUBSTR(cRenglon,210,2);
					LET cFolioSeguro = SUBSTR(cRenglon,212,12);
					LET cUsoFuturo = SUBSTR(cRenglon,224,120);
					LET mImporte = TO_CHAR(cImporte);
					LET mimporte = substr(mImporte, 1, 13) || '.' || substr(mImporte, 14, 2) ;
					LET dImporte = substr(cImporte, 1, 13) :: DECIMAL(16,2);
					LET dImporte2 = ('0.' || substr(cImporte, 14, 2)):: DECIMAL(16,2);
					LET dImporte = dImporte + dImporte2;
					LET importeTotal = importeTotal + dImporte;
					--obtiene descricion de banco
					LET cDescbancoLibrado = 'No Existe en el catalogo';						
					SELECT descripcion INTO cDescbancoLibrado FROM bdinteg:si_bancos WHERE banco = cBancoLibrado;
					
					LET cCuentaDeposito = LTRIM(cCuentaDeposito,'0');
					
					--obtiene motivo de devolucion
					LET cMotivoDevolucion = 'No Existe en el catalogo';
					SELECT descripcion INTO cMotivoDevolucion FROM bdinteg:si_coddevcam WHERE codigo = cMotivoDevol;
					LET cMotivoDevCompleto = TRIM(cMotivoDevol)||' '||TRIM(cMotivoDevolucion);
					LET cprocesar = 'f';
					
					--valida si existe alguna observacion a gregar
					LET cObservaciones = '';
					LET bBanderaError = 'f';
					
					IF cCodOperacion <> '41'THEN
						LET cObservaciones = 'Registro no en fase de devolucion';
						LET bBanderaError = 't';
					END IF;
					
					-- valida banco
					IF 	bBanderaError= 'f' THEN
						IF cBancoCedente <> cMiBanco THEN
								LET cObservaciones = 'Documento no compensado por el banco';
								LET bBanderaError = 't';
						END IF;
					END IF;
					
					--03/07/2016 validacion de fecha habil
					IF 	bBanderaError= 'f' THEN							
						LET cFechaformat = SUBSTR(cFechaDevol, 7, 4) || SUBSTR(cFechaDevol, 1, 2) || SUBSTR(cFechaDevol, 4, 2);
						IF cFechaInicial <> cFechaformat THEN
								LET cObservaciones = 'La fecha de presentacion inicial no corresponde';
								LET bBanderaError = 't';
						END IF;
					END IF;
					
					--validacion si el cheque ya fue presentado
					IF 	bBanderaError= 'f' THEN	
						LET cValidaPresentado = 'Este documento no esta registrado como presentado';
						
						SELECT COUNT(*) INTO iNoPresentado FROM bditef:cce_detalle	
						WHERE bco_receptor = cBancoLibrado AND
						LPAD(TRIM(num_cuenta) , 13, '0') = cCuentaReferencia AND
						num_cheque = cNumCheque AND
						importe = dImporte AND
						fecha_presini = cFechaInicial AND
						cod_operacion = '40';
						
						IF iNoPresentado <> 0 THEN
							LET cValidaPresentado = '';
						ELSE
							LET bBanderaError = 't';
						END IF;
					
						LET cObservaciones = cValidaPresentado;
						END IF;
					
					--valida si el cheque ya fue procesado
					IF 	bBanderaError= 'f' THEN	
						LET cValidaProceso = '';
						
						SELECT COUNT(*) INTO iNoProcesado from bditef:cce_cheques_dev
						where cvebanco = cBancoLibrado AND
						LPAD(TRIM(numcuenta) , 13, 0) = cCuentaReferencia AND
						LPAD(TRIM(numcheque) , 10, 0) = cNumCheque AND
						fechapresenta = cFechaDevol;
						
						IF iNoProcesado <> 0 THEN
							LET cValidaProceso = 'este documento ya fue procesado';
							LET bBanderaError = 't';
						END IF;
						
						LET cObservaciones = cValidaProceso;
					END IF;
					
					IF 	bBanderaError= 'f' THEN	
						LET cprocesar = 't'; --SI
					END IF;
					
					INSERT INTO bdicnweb:"informix".ccep_procesacod41detalle_tmp
					(usuario,direccionMac,bancoLibrado,descbancoLibrado,importe,cuentaReferencia,numCheque,CuentaDeposito,observaciones,motivoDevolucion,procesar)
					VALUES
					(pUsuario,pDireccionMac,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevCompleto,cprocesar);
					
				END IF;
			END FOREACH;	
			
		COMMIT WORK;
		
		LET bBanDet  = 't';
		LET ven_transacc = 0;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,bBanDet,importeTotal; 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 07/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos',
'DESCRIPCION: Carga datos del archivo de devoluciones a tablas temporales  y se valida la informacion.',
'AUTOR: JOSÃ ANTONIO RAMIREZ FRANCO',
'FECHA MODIFICACION: 06/05/2024',
'MODIFICACION: Se ajusta el importe para los centavos y se aÃ±aden los ceros a las numeros de cuentas.',
'AUTOR: VERONICA SANCHEZ',
'FECHA MODIFICACION: 26/08/2025',
'MODIFICACION: Se ajusta SPS para contatenar el cdigo y descripcion de la devolucion, variable cMotivoDevCompleto.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_valida_correo_ob(pRFC CHAR(13) 
                                    ,pCorreoElec CHAR(100))
RETURNING CHAR(5) AS vcodret1,
		  CHAR(100) AS vMensaje;
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vExisteCorreo    SMALLINT;
	DEFINE vExisteCteCorreo INTEGER;
	DEFINE vCorreoNoValido  INTEGER;
	DEFINE vNumCte			CHAR(20);
	DEFINE vMensaje         CHAR(50);
	DEFINE vRfc		        CHAR(50);
    
    LET vcodret1 = '00000';
    LET vcodret2 = '00000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte    = 0;
    LET vExisteCorreo = 0;
	LET vExisteCteCorreo = 0;
    LET vCorreoNoValido  = 0;
	LET vNumCte = '0';
    LET vMensaje = 'SE EJECUTO CORRECTAMENTE';
    LET vRfc = '';
	
	BEGIN
		
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/tmp/IFR/sp_valida_correo_ob.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcodret2 = isam_err;
				LET vcodret3 = desc_err;
				LET vMensaje = 'ERROR AL EJECUTAR EL SP';
				RETURN vcodret1, vMensaje;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/IFR/sp_valida_correo_ob.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- // VALIDA PARAMETROS DE ENTRADA
		IF (pRFC is null OR pRFC = '') OR
		   (pCorreoElec is null OR pCorreoElec = '') THEN
			LET vcodret1 = '00003';
			LET vMensaje = 'FALTAN PARÃMETROS DE ENTRADA.';
			RETURN vcodret1, vMensaje;
		END IF;
		
		-- // VALIDA QUE EL CORREO POR INSERTAR NO SE ENCUENTRE EN LA LISTA DE CORREOS NO VALIDOS
		SELECT COUNT(id)
		  INTO vCorreoNoValido
		  FROM bdinteg:"informix".si_cat_correos_novalidos
		 WHERE correo = TRIM(pCorreoElec);
		
		IF vCorreoNoValido > 0 THEN
			LET vcodret1 = '00120';
			LET vMensaje = 'EL CORREO SE ENCUENTRA EN LA LISTA DE CORREOS NO VÃLIDOS';
			RETURN vcodret1, vMensaje;
		END IF;
		
		-- // VALIDA SI EL CORREO YA ESTA REGISTRADO		
		SELECT COUNT(*)
		  INTO vExisteCorreo
		  FROM bdinteg:"informix".si_correos
		 WHERE UPPER(correo_elec) = UPPER(pCorreoElec)
		   AND status_correo = 'A';
		   
		IF vExisteCorreo > 1 THEN
			LET vcodret1 = '00999';
			LET vMensaje = 'EL CORREO YA EXISTE, VERIFIQUE.';
			RETURN vcodret1, vMensaje;
		END IF;
		
		IF vExisteCorreo = 0 THEN
			RETURN vcodret1, vMensaje;
		END IF;
		
		IF vExisteCorreo = 1 THEN
			SELECT numcte
			INTO vNumCte
			FROM bdinteg:"informix".si_correos
			WHERE UPPER(correo_elec) = UPPER(pCorreoElec)
				AND status_correo = 'A';
		
			SELECT rfc
			INTO vRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = vNumCte;
			
			IF vRfc != pRFC THEN
				LET vcodret1 = '00999';
				LET vMensaje = 'EL CORREO YA EXISTE, VERIFIQUE.';
				RETURN vcodret1, vMensaje;
			END IF;
		END IF;
   END;

   RETURN vcodret1, vMensaje;
END PROCEDURE;