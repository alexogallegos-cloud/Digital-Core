CREATE PROCEDURE "informix".sp_generaarchivocobranzacablemas(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia		        	CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(2);
DEFINE cAnio2				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cMovimiento			CHAR(2);
DEFINE cTipoMovimiento		CHAR(2);
DEFINE cReferencia1			CHAR(32);
DEFINE cRutaArchCablemas		CHAR(100);
DEFINE cNombreArchCablemas 		CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE cTpoOperacion			CHAR(1);
DEFINE dFechaIni				DATE;
DEFINE dFecha_Hoy				DATE;
DEFINE iSumaImporte_IVA_Comision	DECIMAL(11,0);
DEFINE iImporte_Pago			DECIMAL(9,0);
DEFINE iTotal_Pago			DECIMAL(11,0);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos				INTEGER;
DEFINE cSucursal				CHAR(4);
DEFINE dFechaPago				DATE;
DEFINE cNombreSuc			CHAR(25);
DEFINE cEstado				CHAR(2);
DEFINE cNombreCiu			CHAR(25);
DEFINE iFlagCopp			INTEGER;
DEFINE vDias                INTEGER;
DEFINE cCiudad				CHAR(3);

DEFINE cSPCodRet CHAR(5); 
DEFINE iMensaje CHAR(50);
DEFINE cid_ptf CHAR(5); 
DEFINE ccve_pais CHAR(3);
DEFINE cnompais CHAR(20);
DEFINE ccalle VARCHAR(100); 
DEFINE cnum_ext VARCHAR(6); 
DEFINE cnum_int VARCHAR(5); 
DEFINE ccve_col CHAR(8);
DEFINE cnomcol VARCHAR(100);
DEFINE ccve_mun CHAR(3);
DEFINE cnommunicipio VARCHAR(60);
DEFINE ccve_localidad CHAR(14);
DEFINE cnomlocalidad VARCHAR(60);
DEFINE ccp CHAR(5); 
DEFINE ccve_ciudad CHAR(3);
DEFINE cnomciudad VARCHAR(60);
DEFINE ccve_estado CHAR(2); 
DEFINE cnomestado VARCHAR(30);
DEFINE ctel1 VARCHAR(14); 
DEFINE ctel2 VARCHAR(14);
DEFINE ctipo VARCHAR(5);

/*VARIABLES PARA ELIMINAR SELECT DE IF*/
DEFINE cvalidaselif INTEGER;
LET cvalidaselif =0;

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3 FOR 3);
LET cMovimiento				= '';
LET cTipoMovimiento			= '';
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cAnio2					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago				= 0;
LET iSumaImporte_IVA_Comision		= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchCablemas			= '';
LET cNombreArchCablemas			= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET cTpoOperacion				= 'H';
LET iNumPagos				= 0;
LET cSucursal				= '';
LET dFechaPago				= DATE(1);
LET cNombreSuc				= '';
LET cEstado					= '';
LET cCiudad					= '';
LET cNombreCiu				= '';
LET iFlagCopp           	= 0;
LET vDias               	= 0;

LET cSPCodRet = '00000';
LET iMensaje = '';
LET cid_ptf = '';
LET ccve_pais = '';
LET cnompais = '';
LET ccalle = '';
LET cnum_ext = ''; 
LET cnum_int = '';
LET ccve_col = '';
LET cnomcol = '';
LET ccve_mun = '';
LET cnommunicipio = '';
LET ccve_localidad = '';
LET cnomlocalidad = '';
LET ccp = '';
LET ccve_ciudad = '';
LET cnomciudad = '';
LET ccve_estado = ''; 
LET cnomestado = '';
LET ctel1 = '';
LET ctel2 = '';
LET ctipo = '';	

	---SET DEBUG FILE TO  '/informix/rer/sp_generaarchivocobranzacablemas_aia.out';
	---TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND   numconvenio = cConvenio;
			END IF;
		END EXCEPTION;

		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";		
		
		--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		SELECT fecha_ultimo_archivo
		INTO dFechaIni
		FROM "informix".sac_controlarchivoscobranza
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		--ASIGNA VALOR A LAS VARIABLES
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		LET cAnio2 = YEAR(dFecha_Hoy ::DATE); 				
		
		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT ruta_archivo_cobranza,nombre_archivo_cobranza
		INTO cRutaArchCablemas,cNombreArchCablemas
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		
		LET cRutaArchCablemas = TRIM(cRutaArchCablemas)||TRIM(cNombreArchCablemas);
		
		LET cRutaArchCablemas = REPLACE(cRutaArchCablemas,'AA',cAnio);
		LET cRutaArchCablemas = REPLACE(cRutaArchCablemas,'MM',cMes);
		LET cRutaArchCablemas = REPLACE(cRutaArchCablemas,'DD',cDia);
		
		--Borramos evidencia de archivo generado anteriormente (En caso de existir)
		LET cStmt = 'rm -f ' || cRutaArchCablemas;
		SYSTEM cStmt;
		
		--OBTENGO VALOR DE DIAS DE GRACIA
		SELECT valor
		INTO   vDias
		FROM   "informix".sac_param
		WHERE  empresa   = '001'
		AND    cod_param = '118';
		
		--OBTENGO EL TIPO DE MOVIMIENTO
		SELECT movimiento, tipomovimiento
		INTO   cMovimiento, cTipoMovimiento
		FROM   sac_servicios_cpl
		WHERE  numcategoria = cCategoria
		AND    numconvenio  = cConvenio;
		
		



			SELECT COUNT(*) INTO cvalidaselif
			FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
			WHERE  movimiento = cMovimiento
			AND    tipomovimiento = cTipoMovimiento
			AND    st_conciliado = '1';


		--Reviso si existe archivo importado correctamente del dÃ­a
		IF cvalidaselif > 0 THEN
			LET iFlagCopp = 1;
		END IF;
		
		LET cvalidaselif = 0;
		
		
		--TOTAL		
		FOREACH
			SELECT fecha_pago,			
			NVL(folio_suc,''),
			NVL(referencia1,''),
			NVL(importe_pago*100,0),
			NVL(flag_confirmacion_central,0),
			NVL(flag_confirmacion_sucursal,0)
			INTO dFechaPago,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
			FROM "informix".sac_movimientoshistorial
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio
			AND fecha_pago > dFechaIni
			AND fecha_pago <= dFecha_Hoy
			AND status_cancelado <> 'S'
			AND (flag_confirmacion_central = 1
			OR flag_confirmacion_sucursal = 1)
			AND origen                    != "CPL"

			--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
			IF iFlagCen = 0 OR iFlagSuc = 0 THEN
				SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
				IF iCuantos = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;

			IF iCuantos > 0 THEN
				INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
				VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
			END IF;

			LET iNumPagos = iNumPagos + 1;
			LET iTotal_Pago = iTotal_Pago + iImporte_Pago;
			
		END FOREACH;
		
		IF iFlagCopp = 1 THEN
		
			--Detalle Coppel
			FOREACH
				--Solo obtengo aquellos registros que estÃ¡n conciliados
				SELECT sm.fecha_pago,
				NVL(sm.folio_suc,''),
				NVL(sm.referencia1,''),
				NVL(sm.importe_pago*100,0),
				NVL(sm.flag_confirmacion_central,0),
				NVL(sm.flag_confirmacion_sucursal,0)
				INTO dFechaPago,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM bdisac:"informix".sac_movimientoshistorial sm,
					 bdisac:"informix".sac_conciliacion_bcpl_cpl sc
				WHERE    sm.numcategoria     = cCategoria 
				AND	     sm.numconvenio      = cConvenio
				AND      sm.fecha_pago       > dFechaIni - vDias
				AND      sm.fecha_pago       <= dFecha_Hoy
				AND      sm.status_cancelado <> 'S'
				AND      sm.origen           = "CPL"
				AND      sm.folio_suc        = sc.foliosucursal
				AND      (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
				AND      sc.st_conciliado           = 1
				ORDER BY sm.fecha_pago DESC

				--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
				IF iFlagCen = 0 OR iFlagSuc = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
					IF iCuantos = 0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
						IF iCuantos = 0 THEN
							CONTINUE FOREACH;
						END IF;
					END IF;
				END IF;

				IF iCuantos > 0 THEN
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
				END IF;
				
				LET iNumPagos = iNumPagos + 1;
				LET iTotal_Pago = iTotal_Pago + iImporte_Pago;

			END FOREACH;
			
		END IF;
		
		--Busco todos los registros de la tabla sac_bitacora_flags para actualizar en sac_movimientoshistorial
		FOREACH
			SELECT referencia, folio_suc, fecha_pago
			INTO   cReferencia1, cFolio, dFechaPago
			FROM   bdisac:"informix".sac_bitacora_flags
			WHERE  numcategoria       = cCategoria
			AND    numconvenio        = cConvenio
			AND    fecha_insert::DATE = TODAY
			
			LET cReferencia1 = TRIM (cReferencia1);
			
			--Actualizo bandera de 0 a 1
			UPDATE bdisac:sac_movimientoshistorial
			SET    flag_confirmacion_sucursal = '1'
			WHERE  numcategoria               = cCategoria
			AND    numconvenio                = cConvenio
			AND    fecha_pago                 = dFechaPago
			AND    folio_suc                  = cFolio
			AND    referencia1                = cReferencia1
			AND    status_cancelado           <> 'S'
			AND    flag_confirmacion_sucursal = 0;
			
		END FOREACH;
		
		--IMPRIME EL ENCABEZADO DEL ARCHIVO
		LET cStmt='echo "' || cTpoOperacion || ',' || cAnio || cMes || cDia || ',' || LPAD(iNumPagos,6,0) || ',' || LPAD(iTotal_Pago,11,0) || '" >> ' || cRutaArchCablemas;
		SYSTEM cStmt;	
			
		--DETALLE
		FOREACH

			SELECT fecha_pago,
			LPAD(DAY(fecha_pago::DATE), 2, '0'),
			LPAD(MONTH(fecha_pago::DATE), 2, '0'),
			LPAD(YEAR(fecha_pago::DATE), 4, '0'),
			case when origen = 'CPL' then NVL(sucursal_cpl,'') else NVL(id_sucursal,'') end,
			NVL(folio_suc,''),
			NVL(referencia1,''),
			NVL(importe_pago*100,0),
			NVL(flag_confirmacion_central,0),
			NVL(flag_confirmacion_sucursal,0)
			INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
			FROM "informix".sac_movimientoshistorial
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio
			AND fecha_pago > dFechaIni
			AND fecha_pago <= dFecha_Hoy
			AND status_cancelado <> 'S'
			AND (flag_confirmacion_central = 1
			OR flag_confirmacion_sucursal = 1)
			AND origen                    != "CPL"

			IF iFlagCen = 0 OR iFlagSuc = 0 THEN
				SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
				IF iCuantos = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;

			IF iCuantos > 0 THEN
				UPDATE "informix".sac_movimientoshistorial SET flag_confirmacion_sucursal = '1'
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago = dFechaPago
				AND folio_suc = cFolio
				AND referencia1 = cReferencia1
				AND status_cancelado <> 'S'
				AND flag_confirmacion_sucursal = 0;
			END IF;				
				
				
			SELECT COUNT(*)	INTO cvalidaselif
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = cSucursal;
			
			IF cvalidaselif > 0 THEN				
				SELECT NVL(REPLACE(nombre,',',' '),'')			
				INTO cNombreSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = cSucursal;				
			ELSE			
				LET cNombreSuc = '';			
			END IF;
			
			LET cvalidaselif = 0;
			
			execute procedure bdisac:"informix".sp_sac_consucursales(cSucursal) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
			
			IF cSPCodRet != '00000' THEN
				LET cNombreCiu = '';	
			ELSE
				LET cNombreCiu = cnomciudad;
			END IF;		
			
			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "' || 'D' || ',' || LPAD(cNombreCiu,25,' ') || ',' || LPAD(cNombreSuc,25,' ') || ',' || cAnioPago || cMesPago || cDiaPago || ',' || '09:00' || ',' || cReferencia1 || ',' || LPAD(iImporte_Pago,9,0) || '" >> ' || cRutaArchCablemas;
			SYSTEM cStmt;
		END FOREACH;
		
		IF iFlagCopp = 1 THEN
		
			--Detalle Coppel
			FOREACH
				--Solo obtengo aquellos registros que estÃ¡n conciliados
				SELECT sm.fecha_pago,
				LPAD(DAY(sm.fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(sm.fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(sm.fecha_pago::DATE), 4, '0'),
				case when origen = 'CPL' then NVL(sm.sucursal_cpl,'') else NVL(sm.id_sucursal,'') end,
				NVL(sm.folio_suc,''),
				NVL(sm.referencia1,''),
				NVL(sm.importe_pago*100,0),
				NVL(sm.flag_confirmacion_central,0),
				NVL(sm.flag_confirmacion_sucursal,0)
				INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM bdisac:"informix".sac_movimientoshistorial sm,
					 bdisac:"informix".sac_conciliacion_bcpl_cpl sc
				WHERE    sm.numcategoria     = cCategoria 
				AND	     sm.numconvenio      = cConvenio
				AND      sm.fecha_pago       > dFechaIni - vDias
				AND      sm.fecha_pago       <= dFecha_Hoy
				AND      sm.status_cancelado <> 'S'
				AND      sm.origen           = "CPL"
				AND      sm.folio_suc        = sc.foliosucursal
				AND      (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
				AND      sc.st_conciliado           = 1
				ORDER BY sm.fecha_pago DESC

				--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
				IF iFlagCen = 0 OR iFlagSuc = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
					IF iCuantos = 0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
						IF iCuantos = 0 THEN
							CONTINUE FOREACH;
						END IF;
					END IF;
				END IF;

				IF iCuantos > 0 THEN
					UPDATE "informix".sac_movimientoshistorial SET flag_confirmacion_sucursal = '1'
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago = dFechaPago
					AND folio_suc = cFolio
					AND referencia1 = cReferencia1
					AND status_cancelado <> 'S'
					AND flag_confirmacion_sucursal = 0;
				END IF;
				
				SELECT COUNT (*) INTO cvalidaselif 
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = cSucursal;
				
				IF cvalidaselif > 0 THEN				
					SELECT NVL(estado,''), NVL(ciudad,''), NVL(REPLACE(nombre,',',' '),'')
					INTO cEstado, cCiudad, cNombreSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal; 
					
					SELECT REPLACE(NVL(nombre,''),',',' ')
					INTO cNombreCiu
					FROM bdinteg:"informix".si_ciudades 
					WHERE estado = cEstado AND ciudad = cCiudad;
					
				ELSE				
					LET cNombreCiu = '';
					LET cNombreSuc = '';
				END IF;
				
				LET cvalidaselif = 0;
				
				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || 'D' || ',' || LPAD(cNombreCiu,25,' ') || ',' || LPAD(cNombreSuc,25,' ') || ',' || cAnioPago || cMesPago || cDiaPago || ',' || '09:00' || ',' || cReferencia1 || ',' || LPAD(iImporte_Pago,9,0) || '" >> ' || cRutaArchCablemas;
				SYSTEM cStmt;

			END FOREACH;
			
		END IF;
		
		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE;