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