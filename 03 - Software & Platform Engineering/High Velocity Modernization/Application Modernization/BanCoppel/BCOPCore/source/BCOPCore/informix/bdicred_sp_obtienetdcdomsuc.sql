CREATE PROCEDURE "informix".sp_obtienetdcdomsuc()
RETURNING CHAR(6);

DEFINE iSqlErr  		INTEGER;
DEFINE cCodRet  		CHAR(6);
DEFINE cSql				CHAR(1000);
DEFINE cRuta			CHAR(50);
DEFINE cFechaIngreso	CHAR(20);
DEFINE cNumTar			CHAR(16);
DEFINE cNomCliente 		CHAR(200);
DEFINE cNumCte 			CHAR(20); 
DEFINE cNomSuc 			CHAR(40);
DEFINE cSucursal		CHAR(4);
DEFINE cNoCuenta		CHAR(20);
DEFINE cNoLote			CHAR(10);
DEFINE cNoProducto		CHAR(4);
DEFINE cMes				CHAR(2);
DEFINE cDia				CHAR(2);
DEFINE cAnio			CHAR(4);
DEFINE cFechaHoy		CHAR(20);
DEFINE cNomArch			CHAR(100);
DEFINE cRutaArchivo		CHAR(200);
DEFINE cFechaSemana		DATE;

LET iSqlErr			= 0;
LET cCodRet 		= '000000';
LET cSql 			= '';
LET cRuta 			= '';
LET cFechaIngreso	= '';
LET cNumTar			= '';
LET cNomCliente		= '';
LET cNumCte			= '';
LET cNomSuc			= '';
LET	cSucursal		= '';
LET cNoCuenta		= '';
LET cNoLote			= '';
LET cNoProducto		= '';
LET cFechaHoy		= '';
LET cNomArch		= '';
LET cRutaArchivo	= '';
LET cMes			= '';
LET cDia			= '';
LET cAnio			= '';
LET cFechaSemana 	= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Oscar/736/sp_obtienetdcdomsuc.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT valor INTO cRuta FROM bdicred:"informix".sd_param WHERE cod_param = '130' AND empresa = '001';	
	SELECT valor INTO cNomArch FROM bdicred:"informix".sd_param WHERE cod_param = '133' AND empresa = '001';
	
	IF TRIM(NVL(cRuta,'')) != '' AND TRIM(NVL(cNomArch,'')) != '' THEN  
		SELECT fecha_hoy , DATE(fecha_hoy - 6)
		INTO cFechaHoy, cFechaSemana
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = '001';
		
		LET cDia = LPAD(DAY(cFechaHoy::DATE), 2, '0');
		LET cMes = LPAD(MONTH(cFechaHoy::DATE), 2, '0');
		LET cAnio = YEAR(cFechaHoy);
		
		LET cNomArch = REPLACE(cNomArch,'dd',cDia);
		LET cNomArch = REPLACE(cNomArch,'mm',cMes);
		LET cNomArch = REPLACE(cNomArch,'aaaa',cAnio);
		LET cNomArch = TRIM(cNomArch) || '.txt';
		
		LET cRutaArchivo = TRIM(cRuta) || TRIM(cNomArch);
		--Elimina archivo
		LET cSQL = 'rm -rf ' || TRIM(cRutaArchivo);		
		SYSTEM cSQL;	
		--Crea archivo vacio
		LET cSQL = 'touch ' || TRIM(cRutaArchivo);
		SYSTEM cSQL;
		
		FOREACH
			SELECT DATE(lot.fechageneracion) AS fecha, lot.clave_sucursal, lot.numerolote, tar.numtarjeta
			INTO cFechaIngreso, cSucursal, cNoLote, cNumTar
			FROM intercard:"informix".tarjeta tar
			INNER JOIN intercard:"informix".lote lot ON lot.numerolote = tar.numerolote
			WHERE tar.codstatustarjeta = 'INA'
			AND tar.codstatusasignada = 'NOE'
			AND DATE(lot.fechageneracion) >= cFechaSemana
			 
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000001'; --No se encotraron datos
				RETURN cCodRet;
			ELSE
				SELECT sol.numcliente,sol.numcuenta,(TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno) || ' ' || TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2)) AS nombrecte, cred.num_producto
				INTO cNumCte, cNoCuenta, cNomCliente, cNoProducto
				FROM intercard:"informix".detalle_maquila dm
				INNER JOIN intercard:"informix".solicitudtarjeta sol ON dm.idsolicitud = sol.idsolicitud
				INNER JOIN bdinteg:"informix".si_cliente cte ON sol.numcliente = cte.numcte
				INNER JOIN bdicred:"informix".sd_maecred cred ON cred.num_credito = sol.numcuenta
				WHERE cred.status_cred = 'E1'
				AND dm.numtarjeta = cNumTar;
				
				IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
					SELECT nombre  
					INTO cNomSuc
					FROM
					bdinteg:"informix".si_sucursales
					WHERE sucursal = cSucursal;	
					
					--Escribe en archivo
					LET cSQL = 'echo "' || TRIM(cFechaIngreso) || ' | ' || SUBSTR(TRIM(cNumTar),13,4) || ' | ' || TRIM(cNomCliente) || ' | ' || TRIM(cNumCte) || ' | ' || TRIM(cNomSuc) || ' | ' || TRIM(cSucursal) || ' | ' || TRIM(cNoCuenta) || ' | ' || TRIM(cNoLote) || ' | ' || TRIM(cNoProducto) || '" >> ' || cRutaArchivo;
					SYSTEM cSQL;
				END IF;
			END IF;		
		END FOREACH;		
	ELSE
		LET cCodret = '000001';
	END IF;	
	RETURN cCodret;
END;
END PROCEDURE
DOCUMENT
'Se crea SP para la creacion de txt para las tarjetas ingresadas(tarjetas que la mensajerÃ­a no pudo entregar en domicilio', 
'y entregÃ³ en sucursal) en el inventario, esto para le generacion de un reporte.',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 31/03/2021',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_tdcoro(pEmpresa VARCHAR(3), pSucursal VARCHAR(4),pBusquedaSuc VARCHAR(20),pOpcion INTEGER, pSecuencia INTEGER,pNumCliente VARCHAR(20))
	RETURNING 	CHAR(6) 	AS cCodRet,
				CHAR(4)		AS cNumeroSucursal,
	            CHAR(40)	AS cNombreSucursal,
	            CHAR(40)	AS cDireccionSucursal,
	            CHAR(40)	AS cColoniaSucursal,
	            CHAR(30)	AS cEstadoSucursal;

DEFINE sql_err 				INTEGER;
DEFINE cCodRet 				CHAR(6);
DEFINE cNumeroSucursal		CHAR(4);
DEFINE cNombreSucursal		CHAR(40);
DEFINE cDireccionSucursal	CHAR(40);
DEFINE cColoniaSucursal		CHAR(40);
DEFINE cEstadoSucursal		CHAR(30);
DEFINE cBusquedaSuc 		CHAR(22);
DEFINE dFechaHoy 			DATE;
DEFINE cFechaHoy 			CHAR(20);
DEFINE cNombreProd 			CHAR(40);
DEFINE cFlagStatusSol 		CHAR(1);
DEFINE cFchSoli 			CHAR(20);
DEFINE v_sec_ingreso		CHAR(3);
DEFINE v_salario        	DECIMAL(18,2);
DEFINE cNumCte	        	INTEGER;
DEFINE cApellPaterno	    CHAR(26);
DEFINE cApellMaterno	    CHAR(26);
DEFINE cNombre1	        	CHAR(26);
DEFINE cNombre2	        	CHAR(26);
DEFINE cSecuencia	        CHAR(3);
DEFINE cNumeroSolicitud	    CHAR(20);
DEFINE cMesHoy				CHAR(2);
DEFINE cDiaHoy				CHAR(2);
DEFINE cAnioHoy				CHAR(4);
DEFINE cMesSoli				CHAR(2);
DEFINE cDiaSoli				CHAR(2);
DEFINE cAnioSoli			CHAR(4);

LET sql_err					= 0;
LET cCodRet 				= '000000';
LET cNumeroSucursal 		= '';
LET cNombreSucursal 		= '';
LET cDireccionSucursal 		= '';
LET cColoniaSucursal 		= '';
LET cEstadoSucursal 		= '';
LET cBusquedaSuc			= '';
LET dFechaHoy 				= '';
LET cNombreProd				= '';
LET cFlagStatusSol			= '';
LET cFchSoli				= '';
LET v_sec_ingreso 			= '';
LET v_salario     			= 0;
LET cNumCte     			= 0;
LET cApellPaterno 			= '';
LET cApellMaterno 			= '';
LET cNombre1 				= '';
LET cNombre2 				= '';
LET cSecuencia 				= '';
LET cNumeroSolicitud 		= '';
LET cMesHoy 				= '';
LET cDiaHoy 				= '';
LET cAnioHoy 				= '';
LET cMesSoli				= '';
LET cDiaSoli				= '';
LET cAnioSoli				= '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
			TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,''));
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/JesusR/736/sp_tdcoro.out";
	--TRACE ON;

	IF pOpcion = 1 THEN
		IF TRIM(pEmpresa) != "" THEN
			LET cBusquedaSuc = '%' || TRIM(pBusquedaSuc) || '%';
			FOREACH
				SELECT SKIP pSecuencia
							suc.sucursal, suc.nombre, suc.direccion1,  ciu.nombre, est.nombre
					INTO
						cNumeroSucursal, cNombreSucursal, cDireccionSucursal, cColoniaSucursal, cEstadoSucursal
				FROM bdinteg: "informix".si_sucursales suc
				INNER JOIN bdinteg: "informix".si_estados est
				ON est.estado = suc.estado
				INNER JOIN bdinteg: "informix".si_ciudades ciu
				ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
				WHERE (suc.nombre LIKE cBusquedaSuc OR suc.direccion1 LIKE cBusquedaSuc OR  ciu.nombre LIKE cBusquedaSuc OR  suc.sucursal LIKE cBusquedaSuc)
				AND suc.empresa = pEmpresa
				AND suc.tpo_sucursal = 'S'
				ORDER BY est.nombre ASC, suc.nombre ASC

				RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
				TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,'')) WITH RESUME;
			END FOREACH
		ELSE
			LET cCodRet = "000001";
		END IF;

	ELIF pOpcion = 2 THEN
		IF TRIM(pEmpresa) != "" AND TRIM(pSucursal) != "" THEN

				SELECT
					nombre,direccion1, direccion2
				INTO
					cNombreSucursal,cDireccionSucursal, cColoniaSucursal
				FROM bdinteg: "informix".si_sucursales
				WHERE sucursal = pSucursal
				AND empresa = pEmpresa
				AND tpo_sucursal = 'S';

		ELSE
			LET cCodRet = "000001";
		END IF;

	ELIF pOpcion = 3 THEN
		IF TRIM(pEmpresa) != "" AND TRIM(pSucursal) != "" AND TRIM(pBusquedaSuc) != "" THEN

				SELECT fecha_hoy
				INTO dFechaHoy
				FROM bdicred: "informix".sd_fechas;

				SELECT suc.nombre, suc.direccion1,  ciu.nombre, est.nombre
				INTO cNombreSucursal, cDireccionSucursal, cColoniaSucursal, cEstadoSucursal
				FROM bdinteg: "informix".si_sucursales suc
				INNER JOIN bdinteg: "informix".si_estados est
				ON est.estado = suc.estado
				INNER JOIN bdinteg: "informix".si_ciudades ciu
				ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
				WHERE  suc.empresa = pEmpresa
				AND sucursal = pSucursal
				AND suc.tpo_sucursal = 'S';

				SELECT LIMIT 1 numcte
				INTO  cNumCte
				FROM bdicred: "informix".sd_ctesamigrar
				WHERE  num_credito = pBusquedaSuc;

				IF DBINFO("sqlca.sqlerrd2") = 0  THEN
					SELECT LIMIT 1 numero_solicitud
					INTO cNumeroSolicitud
					FROM bdisolic: "informix".ss_solicitudes_tdcoro
					where numero_solicitud_oro = pBusquedaSuc;

					IF DBINFO("sqlca.sqlerrd2") = 0  THEN
						FOREACH
							SELECT LIMIT 1 num_credito
							INTO  cNumeroSolicitud
							FROM bdicred: "informix".sd_ctesamigrar
							WHERE  numcte = pNumCliente ORDER BY fecha_insert DESC
						END FOREACH;
					ELSE
						SELECT LIMIT 1 numcte
						INTO  cNumCte
						FROM bdicred: "informix".sd_ctesamigrar
						WHERE  num_credito = cNumeroSolicitud;

						IF DBINFO("sqlca.sqlerrd2") = 0  THEN
							FOREACH
								SELECT LIMIT 1 num_credito
								INTO  cNumeroSolicitud
								FROM bdicred: "informix".sd_ctesamigrar
								WHERE  numcte = pNumCliente ORDER BY fecha_insert DESC
							END FOREACH;
						END IF
					END IF

					UPDATE bdicred: "informix".sd_ctesamigrar SET flagstatussol=4,
					status ='Entregada',
					fchsoli= TO_CHAR(dFechaHoy,'%Y-%m-%d'),
					sucursal = pSucursal,
					nomsuc = cNombreSucursal,
					domsuc = TRIM(cDireccionSucursal) || ', '|| TRIM(cColoniaSucursal) || ', '|| TRIM(cEstadoSucursal)
					WHERE num_credito = cNumeroSolicitud;

				ELSE
					UPDATE bdicred: "informix".sd_ctesamigrar SET flagstatussol=4,
					status ='Entregada',
					fchsoli= TO_CHAR(dFechaHoy,'%Y-%m-%d'),
					sucursal = pSucursal,
					nomsuc = cNombreSucursal,
					domsuc = TRIM(cDireccionSucursal) || ', '|| TRIM(cColoniaSucursal) || ', '|| TRIM(cEstadoSucursal)
					WHERE num_credito = pBusquedaSuc;
				END IF
		ELSE
			LET cCodRet = "000001";
		END IF;

	ELIF pOpcion = 4 THEN
		IF  TRIM(pSucursal) != "" THEN

			SELECT nombre_prod
			INTO cNombreProd
			FROM bdicred: "informix".sd_definicion
			WHERE num_producto = pSucursal;

			LET cNombreSucursal = cNombreProd;

		ELSE
			LET cCodRet = "000001";
		END IF;

	ELIF pOpcion = 5 THEN
		IF  TRIM(pNumCliente) != "" AND pSecuencia != 0 THEN

			SELECT MAX(sec_ingreso)
			INTO   v_sec_ingreso
			FROM   bdinteg:"informix".si_ingresos
			WHERE  numcte = pNumCliente;

			SELECT NVL(ingreso_mensual,0)
			INTO   v_salario
			FROM   bdinteg: "informix".si_ingresos
			WHERE  numcte = pNumCliente and sec_ingreso = v_sec_ingreso;

			IF v_salario < 9000 THEN
				LET cCodRet = '000004';

				FOREACH
					SELECT  LIMIT 1 flagstatussol,fchsoli
					INTO cFlagStatusSol,cFchSoli
					FROM bdicred: "informix".sd_ctesamigrar
					where numcte = pNumCliente
					ORDER BY fchsoli DESC
				END FOREACH;

				IF (TRIM(cFlagStatusSol) IS NULL OR TRIM(cFlagStatusSol) = '' OR TRIM(cFlagStatusSol) = '1') THEN
					IF DBINFO("sqlca.sqlerrd2") = 0  THEN
						LET cCodRet = '000003';
					END IF;
				END IF;
			ELSE
				FOREACH
					SELECT  LIMIT 1 flagstatussol,fchsoli
					INTO cFlagStatusSol,cFchSoli
					FROM bdicred: "informix".sd_ctesamigrar
					where numcte = pNumCliente
					ORDER BY fchsoli DESC
				END FOREACH;

				IF (TRIM(cFlagStatusSol) IS NULL OR TRIM(cFlagStatusSol) = '' OR TRIM(cFlagStatusSol) = '1') THEN
					IF DBINFO("sqlca.sqlerrd2") = 0  THEN
						LET cCodRet = '000003';
					ELSE
						LET cCodRet = '000000';

					END IF;
				ELSE
					SELECT  DATE(fecha_hoy - pSecuencia)
					INTO dFechaHoy
					FROM bdicred: "informix".sd_fechas;

					LET cDiaHoy = LPAD(DAY(dFechaHoy::DATE), 2, '0');
					LET cMesHoy = LPAD(MONTH(dFechaHoy::DATE), 2, '0');
					LET cAnioHoy = YEAR(dFechaHoy);

					FOREACH
						SELECT LIMIT 1 SUBSTRING(fchsoli FROM 1 FOR 4),SUBSTRING(fchsoli FROM 6 FOR 2),SUBSTRING(fchsoli FROM 9 FOR 2)
						INTO cAnioSoli,cMesSoli,cDiaSoli
						FROM bdicred: "informix".sd_ctesamigrar
						WHERE numcte = pNumCliente
						AND flagstatussol='3'
						ORDER BY fchsoli DESC
					END FOREACH;


					 IF DBINFO("sqlca.sqlerrd2") = 0  THEN
							LET cCodRet = '000005';
					ELSE
						IF cAnioSoli >= cAnioHoy THEN
							IF cMesSoli >= cMesHoy THEN
								IF cDiaSoli > cDiaHoy THEN
									LET cCodRet = '000002';
								ELSE
									LET cCodRet = '000000';
								END IF;
							ELSE
								LET cCodRet = '000000';
							END IF;
						ELSE
							LET cCodRet = '000000';
						END IF;
					END IF;



				END IF
			END IF;

		ELSE
			LET cCodRet = '000001';
		END IF;

	ELIF pOpcion = 6 THEN
		IF TRIM(pEmpresa) != "" OR TRIM(pSucursal) != "" THEN

				SELECT suc.nombre, suc.direccion1,  ciu.nombre, est.nombre
				INTO cNombreSucursal, cDireccionSucursal, cColoniaSucursal, cEstadoSucursal
				FROM bdinteg: "informix".si_sucursales suc
				INNER JOIN bdinteg: "informix".si_estados est
				ON est.estado = suc.estado
				INNER JOIN bdinteg: "informix".si_ciudades ciu
				ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
				WHERE  suc.empresa = pEmpresa
				AND sucursal = pSucursal
				AND suc.tpo_sucursal = 'S';

		ELSE
			LET cCodRet = "000001";
		END IF;
	ELIF pOpcion = 7 THEN
		IF TRIM(pEmpresa) != "" AND TRIM(pSucursal) != "" AND TRIM(pBusquedaSuc) != "" THEN

			SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicred: "informix".sd_fechas;

			IF TRIM(pSucursal)  ="9999" THEN
				SELECT MAX(secuencia)
				INTO cSecuencia
				FROM bdinteg: "informix".si_direcciones_actual
				WHERE  numcte= pNumCliente AND tipo_dir='1';

				SELECT TRIM(f.nombrecalle)||' '||
				TRIM(a.numeroextcalle)||' '||TRIM(a.numerointcalle),
				TRIM(g.nombrezona) ||', '||TRIM(b.nombre),
				UPPER (TRIM(c.descripcion))
				INTO cDireccionSucursal, cColoniaSucursal, cEstadoSucursal
				FROM bdinteg: "informix".si_direcciones_actual as a,
					 bdinteg: "informix".si_ciudades as b,
					 bdisolic: "informix".ss_circulo_edos as c,
					 bdinteg: "informix".si_catcalles f,
					 bdinteg: "informix".si_catzonas g
				WHERE  a.numcte= pNumCliente
				AND a.secuencia= cSecuencia
				AND a.pais = b.pais
				AND a.estado = b.estado
				AND a.ciudad = b.ciudad
				AND a.estado = c.clave
				AND a.numerocolonia = g.numerocolonia
				AND a.numerociudad = g.numerociudad
				AND a.numerocalle = f.numerocalle;

				LET cNombreSucursal = 'CASA';

			ELSE

				SELECT suc.nombre, suc.direccion1,  ciu.nombre, est.nombre
				INTO cNombreSucursal, cDireccionSucursal, cColoniaSucursal, cEstadoSucursal
				FROM bdinteg: "informix".si_sucursales suc
				INNER JOIN bdinteg: "informix".si_estados est
				ON est.estado = suc.estado
				INNER JOIN bdinteg: "informix".si_ciudades ciu
				ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
				WHERE  suc.empresa = pEmpresa
				AND sucursal = pSucursal
				AND suc.tpo_sucursal = 'S';
			END IF;

				SELECT LIMIT 1 numcte
				INTO  cNumCte
				FROM bdicred: "informix".sd_ctesamigrar
				WHERE  num_credito = pBusquedaSuc;

			IF DBINFO("sqlca.sqlerrd2") = 0  THEN
					SELECT LIMIT 1 numero_solicitud
					INTO cNumeroSolicitud
					FROM bdisolic: "informix".ss_solicitudes_tdcoro
					where numero_solicitud_oro = pBusquedaSuc;

					IF DBINFO("sqlca.sqlerrd2") = 0  THEN
						FOREACH
							SELECT LIMIT 1 num_credito
							INTO  cNumeroSolicitud
							FROM bdicred: "informix".sd_ctesamigrar
							WHERE  numcte = pNumCliente ORDER BY fecha_insert DESC
						END FOREACH;
					ELSE
						SELECT LIMIT 1 numcte
						INTO  cNumCte
						FROM bdicred: "informix".sd_ctesamigrar
						WHERE  num_credito = cNumeroSolicitud;

						IF DBINFO("sqlca.sqlerrd2") = 0  THEN
							FOREACH
								SELECT LIMIT 1 num_credito
								INTO  cNumeroSolicitud
								FROM bdicred: "informix".sd_ctesamigrar
								WHERE  numcte = pNumCliente ORDER BY fecha_insert DESC
							END FOREACH;
						END IF
					END IF

					UPDATE bdicred: "informix".sd_ctesamigrar SET flagstatussol=2,
					status ='Pendiente x recoger',
					fchsoli= TO_CHAR(dFechaHoy,'%Y-%m-%d'),
					sucursal = pSucursal,
					nomsuc = cNombreSucursal,
					domsuc = TRIM(cDireccionSucursal) || ', '|| TRIM(cColoniaSucursal) || ', '|| TRIM(cEstadoSucursal)
					WHERE num_credito = cNumeroSolicitud;

				ELSE
					UPDATE bdicred: "informix".sd_ctesamigrar SET flagstatussol=2,
					status ='Pendiente x recoger',
					fchsoli= TO_CHAR(dFechaHoy,'%Y-%m-%d'),
					sucursal = pSucursal,
					nomsuc = cNombreSucursal,
					domsuc = TRIM(cDireccionSucursal) || ', '|| TRIM(cColoniaSucursal) || ', '|| TRIM(cEstadoSucursal)
					WHERE num_credito = pBusquedaSuc;
				END IF
		ELSE
			LET cCodRet = "000001";
		END IF;

		ELIF pOpcion = 8 THEN
		IF TRIM(pBusquedaSuc) != "" OR TRIM(pSucursal) != "" OR TRIM(pNumCliente) != "" THEN

			SELECT LIMIT 1 numero_solicitud
			INTO cNumeroSolicitud
			FROM bdisolic: "informix".ss_solicitudes_tdcoro
			where numero_solicitud_oro = pBusquedaSuc;

			 IF DBINFO("sqlca.sqlerrd2") = 0  THEN
				IF pSucursal = '9999' THEN
					UPDATE bdicred: "informix".sd_credito_upgrade
					SET tipo_dom = '1'
					WHERE  numcte = pNumCliente;
				ELSE
					UPDATE bdicred: "informix".sd_credito_upgrade
					SET tipo_dom = '3'
					WHERE numcte = pNumCliente;
				END IF;
			ELSE
				IF pSucursal = '9999' THEN
					UPDATE bdicred: "informix".sd_credito_upgrade
					SET tipo_dom = '1'
					WHERE  num_credito = cNumeroSolicitud;
				ELSE
					UPDATE bdicred: "informix".sd_credito_upgrade
					SET tipo_dom = '3'
					WHERE  num_credito = cNumeroSolicitud;
				END IF;

			END IF;

		ELSE
			LET cCodRet = "000001";
		END IF;
		
		ELIF pOpcion = 9 THEN
		IF TRIM(pBusquedaSuc) != "" THEN
		
			SELECT LIMIT 1 numero_solicitud
			INTO cNumeroSolicitud
			FROM bdisolic: "informix".ss_solicitudes_tdcoro
			WHERE numero_solicitud_oro = pBusquedaSuc;
			
			LET cNombreSucursal = cNumeroSolicitud;
		ELSE
			LET cCodRet = "000001";
		END IF;

	END IF;

	IF  cCodRet <> "000000" OR pOpcion <> 1 THEN
		RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
		TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,''));
	END IF


END;
END PROCEDURE
DOCUMENT
'Folio: 736',
'RQM 10 1339 - Tarjetas de CrÃ©dito Oro nominadas_ innominadas',
'Crear procedimiento para Tarjetas de CrÃ©dito Oro',
'Autor: 94206041 JesÃºs Rosario LÃ³pez Castro',
'BD: bdicred',
'Fecha: 24-03-2021';

CREATE PROCEDURE "informix".pasecont_ifrs(pempresa     CHAR(3),
                                     wfecha_captura   DATE,
                                     wfecha_valida   DATE,
                                     wifrs     CHAR(1),
                                     pusuario     CHAR(8),
                                     pusuariopase CHAR(8),
                                     pproceso     CHAR(10))
   RETURNING CHAR(5), varchar(80);

   DEFINE wcod_ret                      CHAR(5);
   DEFINE P_MENSAJE                     VARCHAR(80);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);
   DEFINE v_error                       smallint;

   DEFINE wbegin                        CHAR(1);
   DEFINE wusuario                      CHAR(8);
   DEFINE wejecutivo                    CHAR(8);
   DEFINE wfecha_hoy                    DATE;
   DEFINE nrows                         SMALLINT;
   DEFINE wproceso                      CHAR(10);
   DEFINE valor_cambio                  DECIMAL(6,4);
   DEFINE wdivisa_cambio                CHAR(2);
   DEFINE wsecuenciamn                  INTEGER;
   DEFINE wsecuenciadl                  INTEGER;
   DEFINE wnro_auxiliar                 CHAR(9);
   DEFINE wdescripcion_det              CHAR(50);
   DEFINE wnumpolmn                     SMALLINT;
   DEFINE wnumpoldl                     SMALLINT;
   DEFINE wfecha                        CHAR(10);
   DEFINE wbanco                        CHAR(3);

{****************************************************************************
 **         INICIA REGISTRO DE PASE CONTABLE                               **
 ****************************************************************************}

   DEFINE wregional                     CHAR(3);
   DEFINE wsucursal                     CHAR(4);
   DEFINE wdivisa                       CHAR(2);
   DEFINE wcodigo_fun                   CHAR(3);
   DEFINE wcodigo_ref                   SMALLINT;
   DEFINE wnum_cuota                    SMALLINT;
   DEFINE wtransacc                     CHAR(4);
   DEFINE wapell_paterno                CHAR(15);
   DEFINE wapell_materno                CHAR(15);
   DEFINE wnombre1                      CHAR(15);
   DEFINE wnombre2                      CHAR(15);
   DEFINE wrazon_social                 CHAR(40);
   DEFINE wabreviatura                  CHAR(50);
   DEFINE wsecuencia                    SMALLINT;
   DEFINE wvaloriza                     CHAR(1);
   DEFINE wcmayor                       CHAR(4);
   DEFINE wcsub1                        CHAR(3);
   DEFINE wcsub2                        CHAR(3);
   DEFINE wcsub3                        CHAR(3);
   DEFINE wcsub4                        CHAR(3);
   DEFINE wcsector                      CHAR(3);

   DEFINE wamayor                       CHAR(4);
   DEFINE wasub1                        CHAR(3);
   DEFINE wasub2                        CHAR(3);
   DEFINE wasub3                        CHAR(3);
   DEFINE wasub4                        CHAR(3);
   DEFINE wasector                      CHAR(3);
    DEFINE var_cuenta_contable	CHAR(16);

   DEFINE wmonto                        MONEY(14,2);
{****************************************************************************
 **      TERMINA REGISTRO DE PASE CONTABLE                                 **
 **      INICIA REGISTRO DETPOL                                            **
 ****************************************************************************}

   DEFINE detusuario                    CHAR(11);
   DEFINE detcontrol_poliza             SMALLINT;
   DEFINE detfecha_captura              DATE;
   DEFINE detsecuencia                  INTEGER;
   DEFINE detempresa                    CHAR(3);
   DEFINE detmayor                      CHAR(4);
   DEFINE detsub1                       CHAR(3);
   DEFINE detsub2                       CHAR(3);
   DEFINE detsub3                       CHAR(3);
   DEFINE detsub4                       CHAR(3);
   DEFINE detsector                     CHAR(3);
   DEFINE detciudad                     CHAR(3);
   DEFINE detsucursal                   CHAR(4);
   DEFINE detnro_auxiliar               CHAR(9);
   DEFINE detnaturaleza                 CHAR(1);
   DEFINE detmonto                      MONEY(14,2);
   DEFINE detdescripcion_det            CHAR(50);
   DEFINE detfecha_valida               DATE;
   DEFINE detmoneda                     CHAR(2);
   DEFINE detvalor_cambio               MONEY(12,7);
   DEFINE detvalor_div_cambio           MONEY(12,7);
   DEFINE detmca_aplica                 CHAR(1);
   DEFINE detpoliza_usuario             CHAR(11);
   DEFINE dettipo_mov                   CHAR(1);
   
{***************************************************************************
 **   TERMINA REGISTRO DE DETPOL                                          **
 **   INICIA REGISTRO DE ENCABEZADO DE POLIZA                             **
 ***************************************************************************}

   DEFINE polcifra_control              MONEY(14,2);
   DEFINE polcargo                      MONEY(14,2);
   DEFINE polabono                      MONEY(14,2);
{***************************************************************************
 **   TERMINA REGISTRO DE ENCABEZADO DE POLIZA                            **
 ***************************************************************************}

   DEFINE wsectoriza                    CHAR(1);
   DEFINE dsecuencia                    INTEGER;
   DEFINE dcontrol_poliza               SMALLINT;
   DEFINE wsucorigen			CHAR(4);
   DEFINE dccosto_orig			CHAR(4);
   DEFINE icontador INTEGER;
   
   --IFSR se agrega bandera para saber si se encuentra activo el IFSR
   DEFINE cBanderaIFSR 					CHAR(1);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET wcod_ret = sql_err;
      --SET DEBUG FILE TO "/RESPALDOS/PruebasIFSR/pasecont.err";
      --TRACE sql_err||" * "||isam_err|| " * "||error_info;
      IF (wbegin = "S") THEN
         ROLLBACK WORK;
         BEGIN WORK;
      ELSE
         ROLLBACK WORK;
      END IF;
      RETURN wcod_ret, P_MENSAJE;
   END EXCEPTION;


   ON EXCEPTION IN (-535)
      LET wbegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

--SET DEBUG FILE TO '/ifxsif01/aldo/etapas/movdia_ifrs/nuevos/pasecont_ifrs.out'; TRACE ON;


   LET wbegin = "S";
   LET wnum_cuota = 0;
   LET wproceso = ""; --NULL;
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   --LET detusuario = 'credito';
   LET detusuario = pusuariopase;
    LET icontador=1;
	

   BEGIN WORK;
      LET wcod_ret = "000";
      LET wproceso = pproceso;  -- "PaseCont";
 
	--let fecha_pase = fecha_pase;	
	
	-- IFSR se inicializa la bandera de IFSR
	LET cBanderaIFSR = 'A';

      /*IF fecha_pase IS NULL OR fecha_pase = " "THEN
         SELECT fecha_hoy
           INTO wfecha_hoy
           FROM sd_fechas
          WHERE empresa = pempresa;
      ELSE
	      LET wfecha_hoy = fecha_pase;
      END IF*/


      IF pusuariopase IS NULL OR pusuariopase = " " THEN
         LET wcod_ret = "821";
         RETURN wcod_ret, P_MENSAJE;
      END IF


      --borra lo existente en la base de contabilidad
         delete from bdicont:co_poldet
       where empresa = pempresa
         and fecha_captura = wfecha_captura
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_detpol
       where empresa = pempresa
         and fecha_captura = wfecha_captura
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_poliza
       where empresa = pempresa
         and fecha_captura = wfecha_captura
         and usuario = pusuariopase;   --'credito';

      SELECT ejecutivo
        INTO wejecutivo
        FROM bdinteg:si_ejecut
       WHERE empresa = pempresa
         AND ejecutivo = pusuario;

      LET nrows = dbinfo("sqlca.sqlerrd2");

      IF (nrows = 0) THEN
         LET wcod_ret = "090";
         LET P_MENSAJE = 'Usuario no Valido para ejecutar el proceso';
         IF (wbegin = "S") THEN
            ROLLBACK WORK;
            BEGIN WORK;
         ELSE
            ROLLBACK WORK;
         END IF;
         RETURN wcod_ret, P_MENSAJE;
      END IF;

      
   commit work;
   LET wbegin = "N";

{************************************************************************
 ** INICIA CREACION DE TABLAS TEMPORALES Y CARGA DE PARAMETROS         **
 ** NECESARIOS PARA EL PASE CONTABLE                                   **
 ************************************************************************}

      CREATE TEMP TABLE tdetpol
         ( usuario               CHAR(11)  NOT NULL ,
          control_poliza        SMALLINT NOT NULL ,
          fecha_captura         DATE     NOT NULL ,
          secuencia             INTEGER  NOT NULL ,
          empresa               CHAR(3),
          ccmayor               CHAR(4),
          ccsub                 CHAR(3),
          ccsubsub              CHAR(3),
          ccssubsub             CHAR(3),
          ccsssubsub            CHAR(3),
          sector                CHAR(3),
          ciudad                CHAR(3),
          sucursal              CHAR(4),
          nro_auxiliar          CHAR(9),
          naturaleza            CHAR(1),
          monto                 MONEY(19,2),
          descripcion_det       CHAR(50),
          fecha_valida          DATE,
          moneda                CHAR(2),
          valor_cambio          MONEY(12,7),
          valor_div_cambio      MONEY(12,7),
          mca_aplic             CHAR(1),
          poliza_usuario        CHAR(11),
          tipo_mov              CHAR(1),
          ccosto_orig           CHAR(4)) with no log;

      SET ISOLATION TO DIRTY READ;

      SELECT valor
        INTO wbanco
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param = "5";

      SELECT valor
        INTO wdivisa_cambio
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param  = "17";

      SELECT tipo_cpa_mn_div
        INTO valor_cambio
        FROM bdinteg:si_tpcambio
       WHERE empresa = pempresa
         AND divisa = wdivisa_cambio
         AND fecha_tpcambio = wfecha_valida
         AND clase_tpcambio = "O";
		 
		--IFSR se recupera el valor de la bandera para plan IFSR
		SELECT NVL(valor,'I')
        INTO cBanderaIFSR
        FROM bdicred:sd_param
		WHERE empresa = pempresa
         AND cod_param = "700"; 

      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF  (nrows = 0) THEN
      {   SELECT tipo_cpa_mn_div
           INTO valor_cambio
           FROM bdinteg:si_histdiv
          WHERE empresa = pempresa
            AND divisa = wdivisa_cambio
            AND fecha_tc = wfecha_valida
            AND clase_tpcambio = "O";}

         LET nrows = dbinfo("sqlca.sqlerrd2");
--         IF (nrows = 0) THEN
--            LET wcod_ret ="017";
--            IF (wbegin = "S") THEN
--               ROLLBACK WORK;
--               BEGIN WORK;
--            ELSE
--               ROLLBACK WORK;
--            END IF;
--            RETURN wcod_ret, P_MENSAJE;
--         END IF;
      END IF;

      LET wusuario = pusuariopase;   --"credito";  
      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET wnro_auxiliar = " ";
      LET wdescripcion_det = "MOVIMIENTOS DE CREDITO DEL DIA ";
      LET wfecha = wfecha_captura;
      LET wdescripcion_det = TRIM(wdescripcion_det)||" "||TRIM(wfecha);

         SELECT MAX(control_poliza)
         INTO wnumpolmn
         FROM bdicont:co_detpol
         WHERE usuario = wusuario
            AND fecha_captura = wfecha_captura
            AND moneda = "00"
            AND empresa = pempresa;

      IF (wnumpolmn IS NULL or wnumpolmn = 0) THEN
         LET wnumpolmn = 1;
      ELSE
         LET wnumpolmn = wnumpolmn + 1;
      END IF;

      LET wnumpoldl = wnumpolmn + 1;
      IF pusuariopase = "califcar" OR pusuariopase  = "canccart" then
         SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(a.monto) monto, a.sucursal,b.num_producto
           FROM sd_movhis_calif a,sd_maecred b,bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
            AND a.reversado = 'N'
            AND a.folio_suc IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = wfecha_valida
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;
      ELIF (wifrs='A') THEN 
         SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(monto) monto, a.sucursal,b.num_producto
           FROM sd_movdia_ifrs a, sd_maecred b, bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
            AND a.reversado = 'N'
            AND a.folio_suc NOT IN ("CalifCartReserva","CalifCart")
            --AND a.fecha_mov = wfecha_valida
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;

      ELSE
         SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(monto) monto, a.sucursal,b.num_producto
           FROM sd_movhis a, sd_maecred b, bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
            AND a.reversado = 'N'
            AND a.folio_suc NOT IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = wfecha_valida
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;

      END IF

	  -- IFSR se valida si la bandera estÃÂ¡ activa, si no se encuentra activa  sigue su proceso normal y i estÃÂ¡ prendida se crea una tabla temporal con los datos de ifsr
	  IF(cBanderaIFSR = 'I') THEN
		SELECT a.regional, a.sucursal, a.divisa, a.codigo_fun, a.codigo_ref,
                a.suc_origen, c.descripcion, d.secuencia, c.valoriza,
                d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub,
                d.c_ccssssub, d.c_sector, d.a_ccmayor, d.a_ccsub,
                d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, d.a_sector,a.monto
           FROM x a, sd_transfun b,bdinteg:si_transacc c, bdinteg:si_prodtran d
          WHERE b.empresa= pempresa
            AND b.codigo_fun=a.codigo_fun
            AND b.codigo_ref=a.codigo_ref
            AND c.empresa = b.empresa
            AND c.numero = b.transacc
            AND c.sistema = "06"
            AND d.empresa = b.empresa
            AND d.producto = a.num_producto
            AND d.sistema = c.sistema
            AND d.transaccion = b.transacc
            AND d.secuencia>0
          --ORDER BY 1,2,3,4,5,6
		  INTO temp univ_movs WITH NO LOG;
		  
	  ELSE
		SELECT a.regional, a.sucursal, a.divisa, a.codigo_fun, a.codigo_ref,
                a.suc_origen, c.descripcion, d.secuencia, c.valoriza,
                d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub,
                d.c_ccssssub, d.c_sector, d.a_ccmayor, d.a_ccsub,
                d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, d.a_sector,a.monto
           FROM x a, sd_transfun b,bdinteg:si_transacc c, bdinteg:si_prodtran d
          WHERE b.empresa= pempresa
            AND b.codigo_fun=a.codigo_fun
            AND b.codigo_ref=a.codigo_ref
            AND c.empresa = b.empresa
            AND c.numero = b.transacc_ifrs
            AND c.sistema = "06"
            AND d.empresa = b.empresa
            AND d.producto = a.num_producto
            AND d.sistema = c.sistema
            AND d.transaccion = b.transacc_ifrs
            AND d.secuencia>0
          --ORDER BY 1,2,3,4,5,6
		  INTO temp univ_movs WITH NO LOG;
	 END IF;

      FOREACH
         SELECT regional, sucursal, divisa, codigo_fun, codigo_ref,
                suc_origen, descripcion, secuencia, valoriza,
                c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub,
                c_ccssssub, c_sector, a_ccmayor, a_ccsub,
                a_ccsubsub, a_ccsssub, a_ccssssub, a_sector,monto
           INTO wregional, wsucursal, wdivisa, wcodigo_fun,
                wcodigo_ref, wsucorigen, wabreviatura, wsecuencia, wvaloriza, 
	            wcmayor, wcsub1, wcsub2, wcsub3, wcsub4, wcsector,
                wamayor, wasub1, wasub2, wasub3, wasub4, wasector,
                wmonto
           FROM univ_movs
		   ORDER BY 1,2,3,4,5,6

            LET wdescripcion_det = wabreviatura;

            IF (wvaloriza = "S" AND wsecuencia = 2
                AND wdivisa <> "00") THEN
               LET wmonto = wmonto * valor_cambio;
               LET wdivisa = "00";
            END IF;

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;
			
	


   LET wcmayor = trim(wcmayor);
   IF wcmayor[1,2] = "95" THEN

           INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_captura,
                dsecuencia,
                "001",
                wcmayor,
                wcsub1,
                wcsub2,
                wcsub3,
                wcsub4,
                wcsector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "D",
                wmonto,
                wdescripcion_det,
                wfecha_valida,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
                wsucursal 
	--	wsucorigen
               );
   ELSE
     
           INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_captura,
                dsecuencia,
                "001",
                wcmayor,
                wcsub1,
                wcsub2,
                wcsub3,
                wcsub4,
                wcsector,
                wregional,
--                wsucursal,
                wsucorigen,
                wnro_auxiliar,
                "D",
                wmonto,
                wdescripcion_det,
                wfecha_valida,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
--                wsucorigen
                wsucursal
               );
  
   END IF; 

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;

  LET wamayor = trim(wamayor); 
  IF wamayor[1,2] = "95" THEN

            INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_captura,
                dsecuencia,
                "001",
                wamayor,
                wasub1,
                wasub2,
                wasub3,
                wasub4,
                wasector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "C",
                wmonto,
                wdescripcion_det,
                wfecha_valida,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
                wsucursal
	--	wsucorigen
               );
   ELSE
            INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_captura,
                dsecuencia,
                "001",
                wamayor,
                wasub1,
                wasub2,
                wasub3,
                wasub4,
                wasector,
                wregional,
--                wsucursal,
                wsucorigen,
                wnro_auxiliar,
                "C",
                wmonto,
                wdescripcion_det,
                wfecha_valida,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
--                wsucorigen
                wsucursal
               );
   END IF;

      END FOREACH;

      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET detsecuencia = 1;
      LET detvalor_cambio = 0;
      LET detvalor_div_cambio = 0;
      LET detmca_aplica = " ";
      LET dettipo_mov = " ";


      FOREACH with hold
         SELECT usuario, control_poliza, fecha_captura ,
            empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
            sector, ciudad, sucursal, nro_auxiliar, naturaleza, sum(monto),
            descripcion_det, fecha_valida, moneda, ccosto_orig
         INTO detusuario, detcontrol_poliza, detfecha_captura,
            detempresa, detmayor, detsub1, detsub2, detsub3, detsub4,
            detsector, detciudad, detsucursal, detnro_auxiliar,
            detnaturaleza, detmonto, detdescripcion_det, detfecha_valida,
            detmoneda, dccosto_orig
         FROM
            tdetpol
         GROUP BY
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19
         ORDER BY
            11, 12, 5, 6, 7, 8, 9, 10

			
		--Asignacion de Centro de Costos Destinos para corresponsales en cuentas contables afectadas
			--LET var_cuenta_contable = detmayor+detsub1+detsub2+detsub3+detsub4;
			LET var_cuenta_contable = trim(detmayor)||trim(detsub1)||trim(detsub2)||trim(detsub3)||trim(detsub4);
			
			 IF (var_cuenta_contable = "140290141101" OR
				 var_cuenta_contable = "140290141102" OR
				 var_cuenta_contable = "140290140301") THEN
				Select centro_costo
			    INTO detsucursal
				FROM sd_catcentrocosto
				WHERE cuenta_contable = var_cuenta_contable;
            END IF;
			
         IF (detmoneda = "00") THEN
            LET detcontrol_poliza = wnumpolmn;
            LET detsecuencia = wsecuenciamn;
            LET wsecuenciamn = wsecuenciamn + 1;
         ELSE
            LET detcontrol_poliza = wnumpoldl;
            LET detsecuencia = wsecuenciadl;
            LET wsecuenciadl = wsecuenciadl + 1;
         END IF;
        
			
			
        IF icontador=1 then
          BEGIN WORK;
        END IF;
		
				
			
         LET detpoliza_usuario = detusuario;
         INSERT INTO
            bdicont:co_poldet
         VALUES
           (detusuario,
            detfecha_captura,
            detsecuencia,
            detempresa,
            detmayor,
            detsub1,
            detsub2,
            detsub3,
            detsub4,
            detsector,
            detciudad,
            detsucursal,
			detnro_auxiliar,
            detnaturaleza,
            detmonto,
            detdescripcion_det,
            detfecha_valida,
            detmoneda,
	    	dccosto_orig);

    IF icontador>=70000 then
        COMMIT WORK; 
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;

      END FOREACH;

  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;

      DROP TABLE tdetpol;
      DROP TABLE x;

--   IF (wbegin = "S") THEN
--      COMMIT WORK;
--      BEGIN WORK;
--   ELSE
--      COMMIT WORK;
--   END IF;

   --EJECUTA EL PROCESO DE AUDITOR

   EXECUTE PROCEDURE BDICONT:AUDITAPASE(wfecha_captura,PEMPRESA,detusuario)
           INTO WCOD_RET;

    IF wcod_ret = "00000" THEN
       LET wcod_ret = "000";
    END IF	

   let v_error = wcod_ret;

--   commit work;
   RETURN wcod_ret, P_MENSAJE;

END PROCEDURE;