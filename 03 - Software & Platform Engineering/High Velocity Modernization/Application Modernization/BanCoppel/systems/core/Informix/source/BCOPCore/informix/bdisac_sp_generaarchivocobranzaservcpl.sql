CREATE PROCEDURE "informix".sp_generaarchivocobranzaservcpl()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cCategoria			CHAR(2);
DEFINE cConvenio			CHAR(3);
DEFINE cReferencia1			CHAR(40);
DEFINE cRutaArchDet			CHAR(100);
DEFINE cRutaArchCif			CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cStmt2				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE dFecha_Hoy			DATE;
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE dFechaPago			DATE;
DEFINE cMovimiento			CHAR(2);
DEFINE cTipoMovimiento		CHAR(2);
DEFINE iImporte_Pago		INTEGER;
DEFINE dFecha_Pago			DATE;
DEFINE cTienda				CHAR(4);
DEFINE iNum_Empleado		CHAR(8);
DEFINE cEmpresa				CHAR(1);
DEFINE iCiudadCop			INTEGER;
DEFINE cDescripcion			CHAR(50);
DEFINE iCampoFuturo1		INTEGER;
DEFINE iCampoFuturo2		INTEGER;
DEFINE iCampoFuturo3		INTEGER;
DEFINE iCampoFuturo4		INTEGER;
DEFINE cCaja				CHAR(4);
DEFINE iNumeroTicket		CHAR(18);
DEFINE iCantidadMovimientos	BIGINT;
DEFINE cStatus				CHAR(1);
DEFINE cFechaFormato		CHAR(10);
DEFINE cDescripcionSPJ		CHAR(100);

DEFINE dato_cpl				CHAR(4);
DEFINE dato_bcpl			CHAR(4);
DEFINE cOrigen              CHAR(3);
DEFINE dFechaIni			DATE;
DEFINE vDias                INTEGER;
DEFINE iFlagCopp			INTEGER;

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
DEFINE iCuenta INTEGER;

/*VARIABLES PARA ELIMINAR SELECT DE IF*/
DEFINE cvalidaselif INTEGER;
LET cvalidaselif =0;

--INICIALIZACION DE VARIABLES--
LET cCodRet				 = "00000";
LET cMensaje			 = 'PROCESO EXITOSO';
LET iSqlErr				 = 0;
LET cCategoria			 = '';
LET cConvenio			 = '';
LET cReferencia1		 = '';
LET cDia				 = '';
LET cMes				 = '';
LET cAnio				 = '';
LET iImporte_Pago		 = 0;
LET cFolio				 = '';
LET iFlagCen			 = 0;
LET iFlagSuc			 = 0;
LET cRutaArchDet		 = '/home/systelmex/pagoserviciosdetalleaaaammdd.txt';
LET cRutaArchCif		 = '/home/systelmex/pagoservicioscifraAAAAMMDD.txt';
LET iCuantos			 = 0;
LET cStmt				 = '';
LET cStmt2				 ='';
LET dFecha_Hoy			 = DATE(1);
LET dFechaPago			 = DATE(1);
LET cMovimiento			 = '';
LET cTipoMovimiento		 = '';
LET iImporte_Pago		 = 0;
LET dFecha_Pago			 = DATE(1);
LET cTienda				 = '0';
LET iNum_Empleado		 = '';
LET cEmpresa			 = '';
LET iCiudadCop			 = 9999;
LET cDescripcion		 = '';
LET iCampoFuturo1		 = 0;
LET iCampoFuturo2		 = 0;
LET iCampoFuturo3		 = 0;
LET iCampoFuturo4		 = 0;
LET cCaja			  	 = '';
LET iNumeroTicket		 = '';
LET iCantidadMovimientos = 0;
LET cStatus  			 = '0';
LET cFechaFormato		 = '1900-01-01';
LET cDescripcionSPJ		 = 'Genera reportes para carteras con servicios homologados despues de conc.';

LET dato_cpl			 ='';
LET dato_bcpl			 ='';
LET cOrigen              ='';
LET vDias                = 0;
LET dFechaIni			 = DATE(1);
LET iFlagCopp            = 0;

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
LET iCuenta = 0;


	--SET DEBUG FILE TO  '/informix/lfp/new/sp_generaarchivocobranzaservcpl.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";
		
		--OBTENGO VALOR DE DIAS DE GRACIA
		SELECT valor
		INTO   vDias
		FROM   "informix".sac_param
		WHERE  empresa   = '001'
		AND    cod_param = '118';
		
		/*Select modificado para sacarlo del IF que continua el proceso*/
		SELECT COUNT(*) INTO cvalidaselif
		FROM bdisac:"informix".sac_procesos_jobs where proceso='IND_AC_SC' and fecha_proceso = dFecha_Hoy;
		
		IF cvalidaselif = 0 THEN
			--INSERTA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_AC_SC', dFecha_Hoy, '0', 'informix', 'sp_generaarchivocobranzaservcpl', cDescripcionSPJ);
		ELSE
			SELECT status 
			INTO cStatus
			FROM bdisac:"informix".sac_procesos_jobs 
			WHERE proceso='IND_AC_SC' and fecha_proceso = dFecha_Hoy;			
		END IF;
		
		LET cvalidaselif = 0;
		
		IF cStatus = '0' THEN
		
			--ASIGNA VALOR A LAS VARIABLES
			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');			
			
			--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
			LET cRutaArchDet = REPLACE(cRutaArchDet,'aaaa',cAnio);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'mm',cMes);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'dd',cDia);								
			LET cRutaArchCif = REPLACE(cRutaArchCif,'AAAA',cAnio);
			LET cRutaArchCif = REPLACE(cRutaArchCif,'MM',cMes);
			LET cRutaArchCif = REPLACE(cRutaArchCif,'DD',cDia);					

			--SERVICIOS DE COPPEL ACTIVOS EN BANCO O COPPEL
			FOREACH
				
				SELECT  numcategoria, numconvenio, movimiento, tipomovimiento, descripcion
				  INTO  cCategoria, cConvenio, cMovimiento, cTipoMovimiento, cDescripcion
				  FROM  "informix".sac_servicios_cpl
				  WHERE conciliacion = '1'
				  
				/*optimizacion solicitada para vobo de base de datos*/
					LET cMovimiento = trim(cMovimiento);
					LET cTipoMovimiento = trim(cTipoMovimiento);
					LET cDescripcion = trim(cDescripcion);
				/*fin de optimizacion*/
				  
				SELECT trans_cliq_cpl, trans_cen_efectivo_cliente_cpl 
				  INTO dato_cpl, dato_bcpl
			      FROM bdisac:"informix".sac_convenios
			     WHERE numcategoria = cCategoria 
			       AND numconvenio = cConvenio;
				   
				--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
				SELECT fecha_ultimo_archivo
				INTO dFechaIni
				FROM "informix".sac_controlarchivoscobranza
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;

				--Reviso si existe archivo importado correctamente del dÃ?Â­a
				
				SELECT COUNT(*) INTO cvalidaselif
					FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  movimiento = cMovimiento
					AND    tipomovimiento = cTipoMovimiento
					AND    st_conciliado = '1';
				
				
				IF cvalidaselif > 0 THEN
					LET iFlagCopp = 1;
				END IF;
				
				LET cvalidaselif = 0;
		
				--ARCHIVO DETALLE (SAC_MOVIMIENTOS)
				FOREACH
				
					--BANCO
					SELECT origen, NVL(importe_pago,0)::integer,
					fecha_pago, 
					case when origen = 'CPL' then NVL(sucursal_cpl,'0') else NVL(id_sucursal,'0') end,
					usuario,
					case when origen = 'CPL' then 'C' else 'B' end,
					case when origen = 'CPL' then NVL(caja_cpl,'0') else '0' end,
					NVL(folio_suc,''),
					case when origen = 'CPL' then NVL(folio_operacion,'0') else '0' end,
					NVL(referencia1,''),
					NVL(flag_confirmacion_central,0),
					NVL(flag_confirmacion_sucursal,0)
					INTO cOrigen, iImporte_Pago, dFechaPago, cTienda, iNum_Empleado, cEmpresa, cCaja, cFolio, iNumeroTicket, cReferencia1, iFlagCen, iFlagSuc
					FROM "informix".sac_movimientos
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio				
					AND fecha_pago = dFecha_Hoy
					AND status_cancelado <> 'S'
					AND (flag_confirmacion_central = 1
					OR flag_confirmacion_sucursal = 1)
					AND origen != 'CPL'
						
					--OBTENER EL NUMERO DE CIUDAD CATALOGO COPPEL
					execute procedure bdisac:"informix".sp_sac_consucursales(cTienda) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
					IF cSPCodRet != '00000' THEN
						LET iCiudadCop = 9999;
					ELSE
						SELECT NVL(COUNT(*), 0)
						INTO   iCuenta
						FROM bdinteg:"informix".si_catciudades
						WHERE numerociudad = ccve_ciudad;
						
						IF iCuenta > 0 THEN
							SELECT numerociudadcoppel 
							INTO iCiudadCop
							FROM bdinteg:"informix".si_catciudades
							WHERE numerociudad = ccve_ciudad;
						ELSE
							LET iCiudadCop = 9999;
						END IF;
						
					END IF;	

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
                        LET iCuantos = '0';
					END IF;		

					LET cFechaFormato = YEAR(dFechaPago) || '-' || LPAD(MONTH(dFechaPago),2,'0') || '-' || LPAD(DAY(dFechaPago),2,'0');
					
					--SELECT trans_cen_efectivo_cliente_cpl FROM bdisac:"informix".sac_controlconvenios WHERE numcategoria = cCategoria AND numconvenio = cConvenio;
					
					IF dato_cpl = '' AND dato_bcpl <> '' AND cOrigen = 'CPL'  THEN
						--IMPRIME RENGLON DE LAS OPERACIONES
						LET cStmt = 'echo "' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iImporte_Pago || '|' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iNum_Empleado || '|' || TRIM(cEmpresa) || '|' || iCiudadCop || '|' || TRIM(cDescripcion) || '|' || TRIM(cCaja) || '|' || TRIM(cFolio) || '|' || TRIM(iNumeroTicket) || '|' || TRIM (cReferencia1) || '|' ||iCampoFuturo1 || '|' || iCampoFuturo2 || '|' || iCampoFuturo3 || '|' || iCampoFuturo4 || '" >> ' || cRutaArchDet;
						SYSTEM cStmt;
					ELSE 
						IF dato_cpl <> '' AND dato_bcpl <> ''  THEN
							LET cStmt = 'echo "' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iImporte_Pago || '|' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iNum_Empleado || '|' || TRIM(cEmpresa) || '|' || iCiudadCop || '|' || TRIM(cDescripcion) || '|' || TRIM(cCaja) || '|' || TRIM(cFolio) || '|' || TRIM(iNumeroTicket) || '|' || TRIM (cReferencia1) || '|' ||iCampoFuturo1 || '|' || iCampoFuturo2 || '|' || iCampoFuturo3 || '|' || iCampoFuturo4 || '" >> ' || cRutaArchDet;
							SYSTEM cStmt;
						END IF	
					END IF;	
					
				END FOREACH;
				
				--ARCHIVO DETALLE (SAC_MOVIMIENTOS)
				FOREACH
				
					--TIENDA (SOLO LO CONCILIADO)
					SELECT sm.origen, NVL(sm.importe_pago,0)::integer,
					sm.fecha_pago, 
					case when sm.origen = 'CPL' then NVL(sm.sucursal_cpl,'0') else NVL(sm.id_sucursal,'0') end,
					sm.usuario,
					case when sm.origen = 'CPL' then 'C' else 'B' end,
					case when sm.origen = 'CPL' then NVL(sm.caja_cpl,'0') else '0' end,
					NVL(sm.folio_suc,''),
					case when sm.origen = 'CPL' then NVL(sm.folio_operacion,'0') else '0' end,
					NVL(sm.referencia1,''),
					NVL(sm.flag_confirmacion_central,0),
					NVL(sm.flag_confirmacion_sucursal,0)
					INTO cOrigen, iImporte_Pago, dFechaPago, cTienda, iNum_Empleado, cEmpresa, cCaja, cFolio, iNumeroTicket, cReferencia1, iFlagCen, iFlagSuc
					FROM bdisac:"informix".sac_movimientos sm,
					     bdisac:"informix".sac_conciliacion_bcpl_cpl sc
					WHERE    sm.numcategoria               = cCategoria
					AND      sm.numconvenio                = cConvenio				
					AND      sm.fecha_pago                 = dFecha_Hoy
					AND      sm.status_cancelado          <> 'S'
					AND      (sm.flag_confirmacion_central = 1
					OR       sm.flag_confirmacion_sucursal = 1)
					AND      sm.origen                     = 'CPL'
					AND      sm.folio_suc                  = sc.foliosucursal
					ORDER BY sm.fecha_pago DESC						
					
					--OBTENER EL NUMERO DE CIUDAD CATALOGO COPPEL
					execute procedure bdisac:"informix".sp_sac_consucursales(cTienda) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
					IF cSPCodRet != '00000' THEN
						LET iCiudadCop = 9999;
					ELSE
						SELECT NVL(COUNT(*), 0)
						INTO   iCuenta
						FROM bdinteg:"informix".si_catciudades
						WHERE numerociudad = ccve_ciudad;
						
						IF iCuenta > 0 THEN
							SELECT numerociudadcoppel 
							INTO iCiudadCop
							FROM bdinteg:"informix".si_catciudades
							WHERE numerociudad = ccve_ciudad;
						ELSE
							LET iCiudadCop = 9999;
						END IF;
					END IF;

					LET cFechaFormato = YEAR(dFechaPago) || '-' || LPAD(MONTH(dFechaPago),2,'0') || '-' || LPAD(DAY(dFechaPago),2,'0');
					
					IF dato_cpl = '' AND dato_bcpl <> '' AND cOrigen = 'CPL'  THEN
						--IMPRIME RENGLON DE LAS OPERACIONES
						LET cStmt = 'echo "' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iImporte_Pago || '|' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iNum_Empleado || '|' || TRIM(cEmpresa) || '|' || iCiudadCop || '|' || TRIM(cDescripcion) || '|' || TRIM(cCaja) || '|' || TRIM(cFolio) || '|' || TRIM(iNumeroTicket) || '|' || TRIM (cReferencia1) || '|' ||iCampoFuturo1 || '|' || iCampoFuturo2 || '|' || iCampoFuturo3 || '|' || iCampoFuturo4 || '" >> ' || cRutaArchDet;
						SYSTEM cStmt;
					ELSE 
						IF dato_cpl <> '' AND dato_bcpl <> ''  THEN
							LET cStmt = 'echo "' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iImporte_Pago || '|' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iNum_Empleado || '|' || TRIM(cEmpresa) || '|' || iCiudadCop || '|' || TRIM(cDescripcion) || '|' || TRIM(cCaja) || '|' || TRIM(cFolio) || '|' || TRIM(iNumeroTicket) || '|' || TRIM (cReferencia1) || '|' ||iCampoFuturo1 || '|' || iCampoFuturo2 || '|' || iCampoFuturo3 || '|' || iCampoFuturo4 || '" >> ' || cRutaArchDet;
							SYSTEM cStmt;
						END IF	
					END IF;	
					
				END FOREACH;
				
				--ARCHIVO DETALLE (SAC_MOVIMIENTOSHISTORIAL)
				FOREACH
				
					--TIENDA (SOLO LO CONCILIADO)
					SELECT sm.origen, NVL(sm.importe_pago,0)::integer,
					sm.fecha_pago, 
					case when sm.origen = 'CPL' then NVL(sm.sucursal_cpl,'0') else NVL(sm.id_sucursal,'0') end,
					sm.usuario,
					case when sm.origen = 'CPL' then 'C' else 'B' end,
					case when sm.origen = 'CPL' then NVL(sm.caja_cpl,'0') else '0' end,
					NVL(sm.folio_suc,''),
					case when sm.origen = 'CPL' then NVL(sm.folio_operacion,'0') else '0' end,
					NVL(sm.referencia1,''),
					NVL(sm.flag_confirmacion_central,0),
					NVL(sm.flag_confirmacion_sucursal,0)
					INTO cOrigen, iImporte_Pago, dFechaPago, cTienda, iNum_Empleado, cEmpresa, cCaja, cFolio, iNumeroTicket, cReferencia1, iFlagCen, iFlagSuc
					FROM bdisac:"informix".sac_movimientoshistorial sm,
					     bdisac:"informix".sac_conciliacion_bcpl_cpl sc
					WHERE    sm.numcategoria               = cCategoria
					AND      sm.numconvenio                = cConvenio
					AND      sm.fecha_pago                 > dFechaIni - vDias
					AND      sm.fecha_pago                <= dFecha_Hoy
					AND      sm.status_cancelado          <> 'S'
					AND      (sm.flag_confirmacion_central = 1
					OR       sm.flag_confirmacion_sucursal = 1)
					AND      sm.origen                     = 'CPL'
					AND      sm.folio_suc                  = sc.foliosucursal
					ORDER BY sm.fecha_pago DESC
						
					--OBTENER EL NUMERO DE CIUDAD CATALOGO COPPEL
					execute procedure bdisac:"informix".sp_sac_consucursales(cTienda) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
					IF cSPCodRet != '00000' THEN
						LET iCiudadCop = 9999;
					ELSE
						SELECT NVL(COUNT(*), 0)
						INTO   iCuenta
						FROM bdinteg:"informix".si_catciudades
						WHERE numerociudad = ccve_ciudad;
						
						IF iCuenta > 0 THEN
							SELECT numerociudadcoppel 
							INTO iCiudadCop
							FROM bdinteg:"informix".si_catciudades
							WHERE numerociudad = ccve_ciudad;
						ELSE
							LET iCiudadCop = 9999;
						END IF;
					END IF;

					LET cFechaFormato = YEAR(dFechaPago) || '-' || LPAD(MONTH(dFechaPago),2,'0') || '-' || LPAD(DAY(dFechaPago),2,'0');
					
					--SELECT trans_cen_efectivo_cliente_cpl FROM bdisac:"informix".sac_controlconvenios WHERE numcategoria = cCategoria AND numconvenio = cConvenio;
					
					IF dato_cpl = '' AND dato_bcpl <> '' AND cOrigen = 'CPL'  THEN
						--IMPRIME RENGLON DE LAS OPERACIONES
						LET cStmt = 'echo "' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iImporte_Pago || '|' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iNum_Empleado || '|' || TRIM(cEmpresa) || '|' || iCiudadCop || '|' || TRIM(cDescripcion) || '|' || TRIM(cCaja) || '|' || TRIM(cFolio) || '|' || TRIM(iNumeroTicket) || '|' || TRIM (cReferencia1) || '|' ||iCampoFuturo1 || '|' || iCampoFuturo2 || '|' || iCampoFuturo3 || '|' || iCampoFuturo4 || '" >> ' || cRutaArchDet;
						SYSTEM cStmt;
					ELSE 
						IF dato_cpl <> '' AND dato_bcpl <> ''  THEN
							LET cStmt = 'echo "' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iImporte_Pago || '|' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iNum_Empleado || '|' || TRIM(cEmpresa) || '|' || iCiudadCop || '|' || TRIM(cDescripcion) || '|' || TRIM(cCaja) || '|' || TRIM(cFolio) || '|' || TRIM(iNumeroTicket) || '|' || TRIM (cReferencia1) || '|' ||iCampoFuturo1 || '|' || iCampoFuturo2 || '|' || iCampoFuturo3 || '|' || iCampoFuturo4 || '" >> ' || cRutaArchDet;
							SYSTEM cStmt;
						END IF	
					END IF;	
					
				END FOREACH;
				
				--ACTUALIZA FLAG SEGUN BITACORA
				FOREACH
					SELECT referencia, folio_suc, fecha_pago 
					INTO   cReferencia1, cFolio, dFecha_Pago
					FROM   "informix".sac_bitacora_flags 
					WHERE  fecha_insert::DATE = TODAY 
					AND    numcategoria       = cCategoria 
					AND    numconvenio        = cConvenio

					UPDATE bdisac:"informix".sac_movimientos
					SET    flag_confirmacion_sucursal  = '1'
					WHERE  numcategoria                = cCategoria
					AND    numconvenio                 = cConvenio
					AND    fecha_pago                  = dFecha_Pago
					AND    folio_suc                   = cFolio
					AND    referencia1                 = cReferencia1
					AND    status_cancelado           != 'S'
					AND    flag_confirmacion_sucursal  = 0;

				END FOREACH;
				
				--ARCHIVO CIFRA	(SAC_MOVIMIENTOS)
				FOREACH
				
					--BANCO
					SELECT origen, fecha_pago,			
					case when origen = 'CPL' then NVL(sucursal_cpl,'0') else NVL(id_sucursal,'0') end tienda,
					SUM(importe_pago::integer) importe,
					count(*) AS cantidad_movimientos, 
					case when origen = 'CPL' then 'C' else 'B' end empresa								
					INTO cOrigen, dFecha_Pago, cTienda, iImporte_Pago, iCantidadMovimientos, cEmpresa
					FROM "informix".sac_movimientos
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago = dFecha_Hoy
					AND status_cancelado <> 'S'
					AND flag_confirmacion_central = 1
					AND flag_confirmacion_sucursal = 1
					AND origen != 'CPL'
					GROUP BY 1, 2, 6, 3
					
					LET cFechaFormato = YEAR(dFecha_Pago) || '-' || LPAD(MONTH(dFecha_Pago),2,'0') || '-' || LPAD(DAY(dFecha_Pago),2,'0');				
					
					IF dato_cpl = '' AND dato_bcpl <> '' AND cOrigen = 'CPL'  THEN
						--IMPRIME RENGLON DE LAS OPERACIONES
						LET cStmt2 = 'echo "' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iImporte_Pago || '|' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iCantidadMovimientos || '|' || TRIM(cEmpresa) || '" >> ' || cRutaArchCif;
						SYSTEM cStmt2;
					ELSE 
						IF dato_cpl <> '' AND dato_bcpl <> ''  THEN
							LET cStmt2 = 'echo "' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iImporte_Pago || '|' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iCantidadMovimientos || '|' || TRIM(cEmpresa) || '" >> ' || cRutaArchCif;
							SYSTEM cStmt2;	
						END IF	
					END IF;	
					
				END FOREACH;
				
				--ARCHIVO CIFRA	(SAC_MOVIMIENTOS)
				FOREACH
				
					--TIENDA (SOLO LO CONCILIADO)
					SELECT sm.origen, sm.fecha_pago,			
					case when sm.origen = 'CPL' then NVL(sm.sucursal_cpl,'0') else NVL(sm.id_sucursal,'0') end tienda,
					SUM(sm.importe_pago::integer) importe,
					count(*) AS cantidad_movimientos, 
					case when sm.origen = 'CPL' then 'C' else 'B' end empresa								
					INTO cOrigen, dFecha_Pago, cTienda, iImporte_Pago, iCantidadMovimientos, cEmpresa
					FROM bdisac:"informix".sac_movimientos sm,
					     bdisac:"informix".sac_conciliacion_bcpl_cpl sc
					WHERE    sm.numcategoria               = cCategoria
					AND      sm.numconvenio                = cConvenio
					AND      sm.fecha_pago                 = dFecha_Hoy
					AND      sm.status_cancelado          <> 'S'
					AND      sm.flag_confirmacion_central  = 1
					AND      sm.flag_confirmacion_sucursal = 1
					AND      sm.origen                     = 'CPL'
					AND      sm.folio_suc                  = sc.foliosucursal
					GROUP BY 1, 2, 6, 3
					
					LET cFechaFormato = YEAR(dFecha_Pago) || '-' || LPAD(MONTH(dFecha_Pago),2,'0') || '-' || LPAD(DAY(dFecha_Pago),2,'0');				
					
					IF dato_cpl = '' AND dato_bcpl <> '' AND cOrigen = 'CPL'  THEN
						--IMPRIME RENGLON DE LAS OPERACIONES
						LET cStmt2 = 'echo "' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iImporte_Pago || '|' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iCantidadMovimientos || '|' || TRIM(cEmpresa) || '" >> ' || cRutaArchCif;
						SYSTEM cStmt2;
					ELSE 
						IF dato_cpl <> '' AND dato_bcpl <> ''  THEN
							LET cStmt2 = 'echo "' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iImporte_Pago || '|' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iCantidadMovimientos || '|' || TRIM(cEmpresa) || '" >> ' || cRutaArchCif;
							SYSTEM cStmt2;	
						END IF	
					END IF;	
					
				END FOREACH;
				
				--ARCHIVO CIFRA	(SAC_MOVIMIENTOSHISTORIAL)
				FOREACH
				
					--TIENDA (SOLO LO CONCILIADO)
					SELECT sm.origen, sm.fecha_pago,			
					case when sm.origen = 'CPL' then NVL(sm.sucursal_cpl,'0') else NVL(sm.id_sucursal,'0') end tienda,
					SUM(sm.importe_pago::integer) importe,
					count(*) AS cantidad_movimientos, 
					case when sm.origen = 'CPL' then 'C' else 'B' end empresa								
					INTO cOrigen, dFecha_Pago, cTienda, iImporte_Pago, iCantidadMovimientos, cEmpresa
					FROM bdisac:"informix".sac_movimientoshistorial sm,
					     bdisac:"informix".sac_conciliacion_bcpl_cpl sc
					WHERE    sm.numcategoria               = cCategoria
					AND      sm.numconvenio                = cConvenio
					AND      sm.fecha_pago                 > dFechaIni - vDias
					AND      sm.fecha_pago                <= dFecha_Hoy
					AND      sm.status_cancelado          <> 'S'
					AND      sm.flag_confirmacion_central  = 1
					AND      sm.flag_confirmacion_sucursal = 1
					AND      sm.origen                     = 'CPL'
					AND      sm.folio_suc                  = sc.foliosucursal
					GROUP BY 1, 2, 6, 3
					
					LET cFechaFormato = YEAR(dFecha_Pago) || '-' || LPAD(MONTH(dFecha_Pago),2,'0') || '-' || LPAD(DAY(dFecha_Pago),2,'0');				
					
					IF dato_cpl = '' AND dato_bcpl <> '' AND cOrigen = 'CPL'  THEN
						--IMPRIME RENGLON DE LAS OPERACIONES
						LET cStmt2 = 'echo "' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iImporte_Pago || '|' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iCantidadMovimientos || '|' || TRIM(cEmpresa) || '" >> ' || cRutaArchCif;
						SYSTEM cStmt2;
					ELSE 
						IF dato_cpl <> '' AND dato_bcpl <> ''  THEN
							LET cStmt2 = 'echo "' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iImporte_Pago || '|' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iCantidadMovimientos || '|' || TRIM(cEmpresa) || '" >> ' || cRutaArchCif;
							SYSTEM cStmt2;	
						END IF	
					END IF;	
					
				END FOREACH;
				
			END FOREACH;

			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt = 'echo "' || '" >> ' || cRutaArchDet;
			SYSTEM cStmt;			
			
			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt2 = 'echo "' || '" >> ' || cRutaArchCif;
			SYSTEM cStmt2;				
			
		END IF;			
		--ACTUALIZA STATUS EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_AC_SC', dFecha_Hoy, '1', 'informix', 'sp_generaarchivocobranzaservcpl_aia', cDescripcionSPJ);		
		RETURN cCodRet, cMensaje;
	END;	
END PROCEDURE;