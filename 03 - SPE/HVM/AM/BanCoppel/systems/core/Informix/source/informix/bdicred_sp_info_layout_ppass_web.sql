CREATE PROCEDURE "informix".sp_info_layout_ppass_web(pEmpresa VARCHAR(3), pNumTarPPassAnt VARCHAR(20), pNumTarPPassNue VARCHAR(20), pNumTarPlat VARCHAR(20), pNumCredito VARCHAR(20),
												 pNumCte VARCHAR(20), pSucursal VARCHAR(4), pEstatusLayout VARCHAR(1), pDestino VARCHAR(1), pBusquedaSuc VARCHAR(20),
												 pOpcion INTEGER, pSecuencia INTEGER)
	RETURNING 	CHAR(6) 	AS cCodRet,
				CHAR(4)		AS cNumeroSucursal,
	            CHAR(40)	AS cNombreSucursal,
	            CHAR(40)	AS cDireccionSucursal,
	            CHAR(40)	AS cColoniaSucursal,
	            CHAR(30)	AS cEstadoSucursal;

DEFINE sql_err 				INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cNumeroSucursal		CHAR(4);
DEFINE cNombreSucursal		CHAR(40);
DEFINE cDireccionSucursal	CHAR(40);
DEFINE cColoniaSucursal		CHAR(40);
DEFINE cEstadoSucursal		CHAR(30);
DEFINE iId_Reg				INTEGER;
DEFINE dFechaAperturaCred	DATE;
DEFINE cNombreTarjeta		CHAR(50);
DEFINE cNombre				CHAR(25);
DEFINE cApellidoPat			CHAR(25);
DEFINE dFechaExp			DATE;
DEFINE cDireccion1			CHAR(40);
DEFINE cDireccion2			CHAR(40);
DEFINE cNumCiudad			CHAR(3);
DEFINE cCiudad				CHAR(3);
DEFINE cNumEstado			CHAR(2);
DEFINE cCalle				CHAR(40);
DEFINE cColonia				CHAR(60);
DEFINE cTipoTarjeta			CHAR(1);
DEFINE cDireccionRecepcion  CHAR(150);
DEFINE cNombreEstado 		CHAR(30);
DEFINE cNombreCiudad 		CHAR(60);
DEFINE cBusquedaSuc 		CHAR(22);
DEFINE iNumCalle 			INTEGER;
DEFINE iNumColonia 			INTEGER;
DEFINE iNumeroExtCalle		INTEGER;


LET sql_err					= 0;
LET cCodRet 				= '00000';
LET cNumeroSucursal 		= '';
LET cNombreSucursal 		= '';
LET cDireccionSucursal 		= '';
LET cColoniaSucursal 		= '';
LET cEstadoSucursal 		= '';
LET iId_Reg 				= 0;
LET dFechaAperturaCred 		= NULL;
LET cNombreTarjeta	 		= '';
LET cNombre	 				= '';
LET cApellidoPat	 		= '';
LET dFechaExp		 		= NULL;
LET cDireccion1				= '';
LET cDireccion2				= '';
LET cNumCiudad				= '';
LET cCiudad					= '';
LET cNumEstado				= '';
LET cCalle					= '';
LET cColonia				= '';
LET cTipoTarjeta			= '';
LET cDireccionRecepcion		= '';
LET cNombreEstado			= '';
LET cNombreCiudad			= '';
LET cBusquedaSuc			= '';
LET iNumCalle				= 0;
LET iNumColonia				= 0;
LET iNumeroExtCalle			= 0;

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

	--SET DEBUG FILE TO "/informix/sp_info_layout_ppass.out";
	--TRACE ON;
	
	IF pOpcion = 1 THEN
		IF TRIM(pEmpresa) != "" THEN
			LET cBusquedaSuc = '%' || TRIM(pBusquedaSuc) || '%';
			FOREACH
				SELECT SKIP pSecuencia
							suc.sucursal, suc.nombre, suc.direccion1, suc.direccion2, est.nombre
					INTO
						cNumeroSucursal, cNombreSucursal, cDireccionSucursal, cColoniaSucursal, cEstadoSucursal
				FROM bdinteg: "informix".si_sucursales suc
				INNER JOIN bdinteg: "informix".si_estados est
				ON est.estado = suc.estado
				WHERE (suc.nombre LIKE cBusquedaSuc OR suc.direccion1 LIKE cBusquedaSuc OR suc.direccion2 LIKE cBusquedaSuc)   -- se agregan ()
				AND suc.empresa = pEmpresa
				AND suc.tpo_sucursal = 'S'
				ORDER BY est.nombre ASC, suc.nombre ASC
					
				RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
				TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,'')) WITH RESUME;
			END FOREACH
		ELSE
			LET cCodRet = "00001";
		END IF;
	ELIF pOpcion = 2 THEN
		IF TRIM(pNumCredito) != "" AND TRIM(pNumCte) != "" AND TRIM(pEmpresa) != "" AND TRIM(pNumTarPlat) != "" AND TRIM(pSucursal) != "" THEN
			SELECT
					MAX(id_reg) + 1
				INTO
					iId_Reg
			FROM "informix".sd_info_layout_ppass;
			
			LET iId_Reg = NVL(iId_Reg, 0);
			
			SELECT
					fecha_apertura
				INTO
					dFechaAperturaCred
			FROM "informix".sd_maecred
			WHERE empresa = pEmpresa
			AND num_credito = pNumCredito;
				
			SELECT
					nombretarjeta
				INTO
					cNombreTarjeta
			FROM intercard:"informix".solicitudtarjeta
			WHERE numcliente = pNumCte
			AND numcuenta = pNumCredito;
					
			LET cNombreTarjeta = TRIM(NVL(cNombreTarjeta, ""));
					
			SELECT
					nombre1, apell_paterno
				INTO
					cNombre, cApellidoPat
			FROM bdinteg: "informix".si_cliente
			WHERE empresa = pEmpresa
			AND numcte = pNumCte;
					
			LET cNombre = TRIM(NVL(cNombre, ""));
			LET cApellidoPat = TRIM(NVL(cApellidoPat, ""));
			
			SELECT
					tipo_tarjeta, expiracion
				INTO
					cTipoTarjeta, dFechaExp
			FROM "informix".sd_tarjeta
			WHERE empresa = pEmpresa
			AND num_credito = pNumCredito
			AND num_tarjeta = pNumTarPlat
			AND numcte = pNumCte;
					
			IF pSucursal = '9999' THEN
				FOREACH
					SELECT LIMIT 1
							numeroextcalle, numerocalle, numerocolonia, ciudad, numerociudad, estado
						INTO
							iNumeroExtCalle, iNumCalle, iNumColonia, cCiudad, cNumCiudad, cNumEstado
					FROM bdinteg: "informix".si_direcciones_actual
					WHERE numcte = pNumCte
					AND tipo_dir = 1
					ORDER BY secuencia DESC
						
					SELECT
							nombrezona
						INTO
							cColonia 
					FROM bdinteg: "informix".si_catzonas
					WHERE numerociudad = cNumCiudad 
					AND numerocolonia  = iNumColonia;

					SELECT
							nombrecalle
						INTO
							cCalle
					FROM bdinteg: "informix".si_catcalles
					WHERE numerocalle = iNumCalle;
						
					SELECT
							nombre
						INTO
							cNombreEstado
					FROM bdinteg: "informix".si_estados
					WHERE estado = cNumEstado;
					
					SELECT 
							nombre
						INTO
							cNombreCiudad
					FROM bdinteg: "informix".si_ciudades
					WHERE estado = cNumEstado 
					AND ciudad = cCiudad;
						
					LET cDireccionRecepcion = TRIM(cCalle) || ' ' || iNumeroExtCalle || ', ' || TRIM(cColonia) || ', ' || TRIM(cNombreCiudad) || ', ' || TRIM(cNombreEstado);
				END FOREACH;
			ELSE
				SELECT 
						direccion1, direccion2, ciudad, estado
					INTO
						cDireccion1, cDireccion2, cNumCiudad, cNumEstado
				FROM bdinteg: "informix".si_sucursales
				WHERE sucursal = pSucursal
				AND empresa = pEmpresa
				AND tpo_sucursal = 'S';
					
				SELECT
						nombre
					INTO
						cNombreEstado
				FROM bdinteg: "informix".si_estados
				WHERE estado = cNumEstado;
				
				LET cNombreEstado = TRIM(NVL(cNombreEstado, ""));
				
				SELECT 
						nombre
					INTO
						cNombreCiudad
				FROM bdinteg: "informix".si_ciudades
				WHERE estado = cNumEstado 
				   AND ciudad = cNumCiudad;
				   
				LET cNombreCiudad = TRIM(NVL(cNombreCiudad, ""));	
				LET cDireccionRecepcion = TRIM(cDireccion1) || ', ' || TRIM(cDireccion2) || ', ' || TRIM(cNombreCiudad) || ', ' || TRIM(cNombreEstado);
			END IF;
			
			INSERT INTO "informix".sd_info_layout_ppass (id_reg, pan, miembro_desde, nombrecompleto, nombre_cte, apellido_cte, numcte, fecha_exp, sucursal, direccion, tipo, estatus_layout, destino, fecha_insert, usuario_modif)
			VALUES (iId_Reg, pNumTarPPassNue, dFechaAperturaCred, cNombreTarjeta, cNombre, cApellidoPat, pNumCte, dFechaExp, pSucursal, cDireccionRecepcion, cTipoTarjeta, pEstatusLayout, pDestino, CURRENT, 'informix');
			
			IF dbinfo("sqlca.sqlerrd2") > 0 THEN
				IF TRIM(pDestino) = "C" THEN
					UPDATE sd_tarjeta_ppass
						SET numtarjeta_ppass = pNumTarPPassNue, status_tar = 'A', fecha_modif = CURRENT
						WHERE numcte = pNumCte
						AND numtarjeta_ppass = pNumTarPPassAnt;
				ELSE
					UPDATE sd_tarjeta_ppass
						SET numtarjeta_ppass = pNumTarPPassNue, status_tar = 'S', fecha_modif = CURRENT
						WHERE numcte = pNumCte
						AND numtarjeta_ppass = pNumTarPPassAnt;
				END IF;
			ELSE
				LET cCodRet = "00002";
			END IF;
					
		ELSE
			LET cCodRet = "00001";
		END IF;
	END IF;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 AND cCodRet = '00000' THEN
		LET cCodRet = "00002";
	END IF;

	IF cCodRet <> "00000" OR pOpcion = 2 THEN
		RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
		TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,''));
	END IF;

END;
END PROCEDURE
;