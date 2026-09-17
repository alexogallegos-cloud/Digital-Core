CREATE PROCEDURE "informix".sp_catalogociudad(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pEstado CHAR(2), pTipoConsulta SMALLINT, pConsulta CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
   RETURNING CHAR(5) AS codret,
   CHAR(5) AS clave_ciudad,
   CHAR(60) AS nombre_ciudad,
   SMALLINT AS clave_ciudad_coppel;
                
   DEFINE cCodRet CHAR(5);
   DEFINE iSqlErr INTEGER;
   DEFINE cIdCiudad CHAR(5);
   DEFINE cNombreCiudad CHAR(60);
   DEFINE iIdCiudadCoppel SMALLINT;
   DEFINE iExiste INTEGER;
   DEFINE iNoRegistros INTEGER;
   
   LET cCodRet = '00000';
   LET iSqlErr = 0;
   LET cIdCiudad = '';
   LET cNombreCiudad = '';
   LET iIdCiudadCoppel = NULL;
   LET iExiste = 0;
   LET iNoRegistros = 0;
   
   BEGIN
      ON EXCEPTION SET iSqlErr
      LET cCodRet = iSqlErr;
      RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
      END EXCEPTION;
			
       --SET DEBUG FILE TO '/informix/victor/municipios/sp_catalogociudad.out';
       --TRACE ON;
			
      IF pIdUsuario = '' OR pIdFuncion = '' OR pEstado = '' OR pTipoConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
         LET cCodRet = '00003';
	 RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
      END IF;
			
	-- VALIDACIÃ?N DE LOS PARAMETROS DE PAGINACIÃ?N
	IF pRegistros < 0 THEN
		LET cCodRet = '00098';
		RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
	END IF;
			
	IF pTipoConsulta NOT IN (1,2) THEN
		LET cCodRet = '00044';
		RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
	END IF;
			
	IF pTipoConsulta = 2 AND pConsulta = '' THEN
		LET cCodRet = '00003';
		RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
	END IF;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   -- VALIDAMOS QUE LA TABLA TENGA DATOS
	   SELECT COUNT(*)
	   INTO iExiste
	   FROM bdinteg:si_ciudades;

           IF iExiste = 0 THEN
		LET cCodRet = '00017';
		RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
	   END IF;

	IF pTipoConsulta = 1 THEN -- Tipo de consulta general
		FOREACH		  
		   SELECT SKIP pRegistros FIRST pRecuperacion a.ciudad, a.nombre, a.ciudad_coppel
	   	   INTO cIdCiudad, cNombreCiudad, iIdCiudadCoppel
	   	   FROM bdinteg:si_ciudades a
	   	   INNER JOIN bdinteg:SI_CATZONAS b ON b.numerociudad = a.ciudad_coppel AND b.numerocolonia >0
	   	   INNER JOIN bdinteg:SI_CATSEPOMEX c ON c.d_codigo = lpad(b.codigopostalzona,5,'0') AND c.d_asenta = TRIM(b.nomzona_spmx)
	   	   WHERE a.pais = '001' AND a.estado = pEstado AND a.ciudad != '' AND a.elegir is NULL AND nvl(b.mnpio_spmx,'') <>'' AND TRIM(b.mnpio_spmx) = c.d_mnpio
	   	   group by a.ciudad, a.nombre, a.ciudad_coppel ORDER BY a.nombre ASC 
				
		  LET iNoRegistros = iNoRegistros + 1;
		  RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel WITH RESUME;
		END FOREACH;
				
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
		   LET cCodRet = '00017';
		   RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
		END IF;
				
		IF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
		END IF;
	ELIF pTipoConsulta = 2 THEN
   	    FOREACH
			
		SELECT SKIP pRegistros FIRST pRecuperacion d.ciudad, d.nombre, d.ciudad_coppel
		  INTO cIdCiudad, cNombreCiudad, iIdCiudadCoppel
		  FROM bdinteg:SI_CATZONAS a, bdinteg:SI_CATSEPOMEX b, bdinteg:SI_ESTADOS c, bdinteg:SI_CIUDADES d
		  WHERE a.numerociudad = d.ciudad_coppel
						 and c.estado = pEstado
						 and lpad(b.codigopostalzona,5,'0') = c.d_codigo
 						 and c.estado = b.c_estado
 						 and TRIM(a.nomzona_spmx) = b.d_asenta
 						 and TRIM(a.mnpio_spmx) = b.d_mnpio
						 and nombre LIKE '%' || TRIM(pConsulta) || '%' 
 						 and d.elegir IS NULL
 						 and nvl(a.mnpio_spmx,'') <>''
		  GROUP BY d.ciudad, d.nombre, d.ciudad_coppel ORDER BY nombre ASC
				
		LET iNoRegistros = iNoRegistros + 1;
		RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel WITH RESUME;
	    END FOREACH;
				
	    IF iNoRegistros = 0 AND pRegistros = 0 THEN
		LET cCodRet = '00017';
		RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
	    END IF;
				
	    IF iNoRegistros = 0 AND pRegistros > 0 THEN
		LET cCodRet = '1001';
		RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;
    	    END IF;
	END IF;

        RETURN cCodRet, cIdCiudad, cNombreCiudad, iIdCiudadCoppel;

     END;
                
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las ciudades",
"FECHA: 25/09/2014",
"DESCRIPCION: Se cambia el numero de ciudad coppel por el de ciudad para que funcione correctamente el SP";

CREATE PROCEDURE "informix".sp_catalogocalle(pUsuario CHAR(8), pIdFuncion CHAR(10), pConsulta CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS numero_calle,
		CHAR(30) AS nombre_calle;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNumeroCalle INTEGER;
	DEFINE cNombreCalle CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iRegistros = 0;
	LET iNumeroCalle = 0;
	LET cNombreCalle = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocalle.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catcalles;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF LENGTH(TRIM(pConsulta)) < 4 THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle = TRIM(pConsulta)
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		ELSE
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle LIKE '%' || TRIM(pConsulta) || '%' 
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		END IF;
		
		IF iRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		ELIF iRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las calles";

CREATE PROCEDURE "informix".sp_reporte_resultado_aplicacion (pBandera 			CHAR(2),
																pFecha      	DATE,
																pRegistros 		INTEGER, 
																pRecuperacion 	INTEGER,
																pUsuario		CHAR(8),
																pIdFuncion 		CHAR(10))
RETURNING
	CHAR(5) 		AS cod_ret,
    CHAR(3) 		AS banco,
	CHAR(20) 		AS num_cuenta,
	CHAR(7) 		AS num_cheque,
    DECIMAL(16,2) 	AS monto,
	CHAR(20) 		AS cta_deposito,
	CHAR(5) 		AS cod_ret_dev,
    CHAR(2) 		AS motivo,
	CHAR(35) 		AS desc_motivo,
	INTEGER			AS no_registros,
	DATE			AS fecha_habil_anterior,
	CHAR(40)		AS desc_banco,
	CHAR(5) 		AS status,
	CHAR(3)			AS clave_banco,
	CHAR(20) 		AS num_cliente,
	CHAR(60)		AS razon_social,
	CHAR(26) 		AS segundo_nombre,
	CHAR(26)		AS apellido_p,
	CHAR(26) 		AS apellido_m,
	CHAR(26)		AS primer_nombre,
	CHAR(35)		AS descripcion,
	CHAR(50) 		AS des_ret_dev,
	CHAR(60) 		AS sucursal,
	CHAR(4)  		AS sucursales,
	CHAR(40)  		AS des_sucursal,
	CHAR(2)  		AS pld;	

	

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(6);
DEFINE cBanco			CHAR(3);
DEFINE cNumCuenta		CHAR(20);
DEFINE cNumCheque		CHAR(7);
DEFINE dMonto			DECIMAL(16,2);
DEFINE cCta_Deposito	CHAR(20);
DEFINE cCodigoRetDev	CHAR(5);
DEFINE cMotivo			CHAR(2);
DEFINE cDescMotivo		CHAR(35);
DEFINE cEmpresa			CHAR(3);
DEFINE cNo_registros	INTEGER;
DEFINE cFecha_habil_ant DATE;
DEFINE cCodRetDev		CHAR(5);
DEFINE cDescBanco		CHAR(40);
DEFINE cDesRetDev 		CHAR(50);
DEFINE cStatus			CHAR(5);
DEFINE cClaveBanco		CHAR(3);
DEFINE cNumCliente		CHAR(20);
DEFINE cRazonSocial		CHAR(60);
DEFINE cSegundoNombre 	CHAR(26);
DEFINE cApePaterno		CHAR(26);
DEFINE cApeMaterno		CHAR(26);
DEFINE cPrimerNombre	CHAR(26);
DEFINE cDescripcion		CHAR(35);
DEFINE cDesCodRetDev 	CHAR(50);
DEFINE cSucursal 		CHAR(60);
DEFINE cSucursales 		CHAR(4);
DEFINE cDesSucursal   	CHAR(40);	
DEFINE cPld   			CHAR(2);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "00000";

LET cBanco				= "";
LET cNumCuenta			= "";
LET cNumCheque			= "";
LET dMonto				= 0.0;
LET cCta_Deposito		= "";
LET cCodigoRetDev		= "";
LET cMotivo				= "";
LET cDescMotivo			= "";
LET cEmpresa			= '001';
LET cNo_registros		= 0;
LET cFecha_habil_ant	= '';
LET cDescBanco			= '';
LET cDesRetDev			= '';
LET cStatus			= '';
LET cClaveBanco			= '';
LET cNumCliente			= '';
LET cRazonSocial		= '';
LET cSegundoNombre		= '';
LET cApePaterno			= '';
LET cApeMaterno			= '';
LET cPrimerNombre		= '';
LET cDescripcion		= '';
LET cCodRetDev			= '';
LET cSucursal     		= '';
LET cSucursales       	= '';
LET cDesSucursal   		= '';
LET cDesCodRetDev 	    = '';
LET cPld 	    		= '';

	BEGIN
		-- ****************************************************************************
		-- *                        CONTROL DE ERRORES                                *
		-- ****************************************************************************
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
	

		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_reporte_resultado_aplicacion.out';
		--TRACE ON;

		-- ****************************************************************************
		-- *                   VALIDAR LOS PARAMETROS DE ENTRADA                      *
		-- ****************************************************************************
		IF pBandera = '1' THEN
			IF pFecha = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
			END IF;
		ELIF pBandera = '2' THEN
			IF pFecha = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
			END IF;
		ELIF pBandera = '3' THEN
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
			END IF;
		ELIF pBandera = '4' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
			END IF;
		ELIF pBandera = '5' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
			END IF;
		ELIF pBandera = '6' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
			END IF;
		ELIF pBandera = '7' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
			END IF;
		END IF;
		
		IF pBandera = '1' THEN
			FOREACH
			EXECUTE PROCEDURE bditef:"informix".sp_cce_consultar_chequesdev_consdev2(cEmpresa, pFecha, pRegistros, pRecuperacion)
			INTO cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo
			RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld WITH RESUME;
		    END FOREACH
		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE bditef:"informix".sp_cce_consultar_chequesdev_consdev2_totales (cEmpresa, pFecha)
			INTO cCodRet, cNo_registros;
			RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
		ELIF pBandera = '3' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consfechahabilanterior(pUsuario, pIdFuncion)
			INTO cCodRet, cFecha_habil_ant;
			RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
		ELIF pBandera = '4' THEN
			FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_consultamovaplicacion (pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion)
			INTO cCodRet, cBanco, cNumCuenta,cNumCheque,dMonto,cCta_Deposito,cCodRetDev,cMotivo, cDescMotivo, cDescBanco, cDesCodRetDev, cStatus
			RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld WITH RESUME;
			END FOREACH
		ELIF pBandera = '5' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consultamovaplicacion_totales(pUsuario, pIdFuncion, pFecha)	
			INTO cCodRet, cNo_registros;
			RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld;
		ELIF pBandera = '6' THEN
			FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_genreporteaplicaciondev(pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion)
			INTO cCodRet, cClaveBanco,cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cNumCliente, cRazonSocial, cSegundoNombre, 
				cApePaterno, cApeMaterno, cPrimerNombre, cDescripcion, cMotivo, cDesCodRetDev
			RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld WITH RESUME;
			END FOREACH
		ELIF pBandera = '7' THEN
		
			FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_genreportedevpresentado (pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion)
			INTO cCodRet,cClaveBanco, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cNumCliente, cSucursal, cSucursales, cDesSucursal
			RETURN cCodRet, cBanco, cNumCuenta, cNumCheque, dMonto, cCta_Deposito, cCodigoRetDev, cMotivo, cDescMotivo, cNo_registros, cFecha_habil_ant,
					 cDescBanco, cStatus, cClaveBanco, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno,
					cApeMaterno, cPrimerNombre, cDescripcion, cDesCodRetDev, cSucursal, cSucursales, cDesSucursal,cPld WITH RESUME;
			END FOREACH;
		END IF;
	END;
END PROCEDURE
DOCUMENT
"AUTOR : Eduardo Ãvila PÃ©rez Tagle",
'MODULO: CÃ¡maras de compensaciÃ³n',
"FUNCIONAMIENTO:SP padre de camaras de compensaciÃ³n - Reporte resultado aplicaciÃ³n",
"FECHA : 03-03-2023",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_ope_consfechahabilanterior(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
			DATE AS fecha_habil_ant;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE dFecha DATE;
		DEFINE dFechaHabilAnt DATE;
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET dFecha = '';
		LET dFechaHabilAnt = '';
		LET iNoRegistros = 0;
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, dFechaHabilAnt;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consfechahabilanterior.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dFechaHabilAnt;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dFechaHabilAnt;
			END IF;
			
			SELECT fecha_hoy 
			INTO dFecha FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
			
			EXECUTE PROCEDURE bditef:"informix".cal_habil_ant(dFecha)
			INTO cCodRetSp, dFechaHabilAnt;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditef:cal_habil_ant';
			ELIF cCodRetSp::INTEGER = 110 THEN
				LET cCodRet = '00003';
			END IF;
			
			RETURN cCodRet, dFechaHabilAnt;
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 11/12/2015',
'MODULO: Operaciones',
'FUNCIONALIDAD: Reportes Resultado de la AplicaciÃ³n', 
'DESCRIPCION: SPL que se encarga de consultar el dia habil anterior a la fecha consultada.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultamovaplicacion (pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(3)  AS banco,
        CHAR(20) AS num_cuenta,
        CHAR(7)  AS num_cheque,
		DECIMAL(16,2) AS monto,
        CHAR(20) AS cta_deposito,
        CHAR(5)  AS cod_ret_dev,
		CHAR(2)  AS motivo,
        CHAR(35) AS desc_motivo,
		CHAR(40) AS desc_banco,
		CHAR(50) AS des_ret_dev,
		CHAR(5) AS status;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cBanco CHAR(3);
	DEFINE cNumCuenta CHAR(20);
	DEFINE cNumCheque CHAR(7);
	DEFINE dMonto DECIMAL(16,2);
	DEFINE cCtaDeposito CHAR(20);
	DEFINE cCodRetDev CHAR(5);
	DEFINE cMotivo CHAR(2);
	DEFINE cDescMotivo CHAR(35);	
	DEFINE cDesBanco CHAR(40);
	DEFINE cDesRetDev CHAR(50);
	DEFINE cStatus CHAR(5);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;	
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cBanco 			= '';
	LET cNumCuenta 		= '';
	LET cNumCheque		= '';
	LET dMonto 			= 0.00;
	LET cCtaDeposito 	= '';
	LET cCodRetDev	 	= '';
	LET cMotivo 		= '';
	LET cDescMotivo		= '';
	LET cDesBanco		= '';
	LET cDesRetDev		= '';
	LET cStatus 		= '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanco, cNumCuenta,cNumCheque,dMonto,cCtaDeposito,cCodRetDev,cMotivo, cDescMotivo, cDesBanco, cDesRetDev, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultamovaplicacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cBanco, cNumCuenta,cNumCheque,dMonto,cCtaDeposito,cCodRetDev,cMotivo, cDescMotivo, cDesBanco, cDesRetDev, cStatus;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cBanco, cNumCuenta,cNumCheque,dMonto,cCtaDeposito,cCodRetDev,cMotivo, cDescMotivo, cDesBanco, cDesRetDev, cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cBanco, cNumCuenta,cNumCheque,dMonto,cCtaDeposito,cCodRetDev,cMotivo, cDescMotivo, cDesBanco, cDesRetDev, cStatus;
		END IF;
		
		FOREACH
			  EXECUTE PROCEDURE bditef:"informix".sp_cce_consultar_chequesdev_consdev2(cEmpresa, pFecha, pRegistros, pRecuperacion) 
			INTO cCodRetSp,  cBanco, cNumCuenta,cNumCheque,dMonto,cCtaDeposito,cCodRetDev,cMotivo, cDescMotivo 
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_consultar_chequesdev_consdev2';
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00003';
			END IF;	
			
			SELECT descripcion
				INTO cDesBanco
			from bdinteg:"informix".si_bancos
				WHERE banco  = cBanco;
			
			IF TRIM(cCodRetDev) = '000' THEN 
				LET cDesRetDev = 'SI';
				LET cStatus = '1';
			ELSE
				SELECT descripcion 
					INTO cDesRetDev 
				FROM bdinteg:"informix".si_codret 
				WHERE codigo_retorno = cCodRetDev
					AND sistema = '01'; 
				LET cStatus = '2';		
				LET cDesRetDev = TRIM(TRIM(cCodRetDev)|| ' ' ||TRIM(cDesRetDev));
				IF cDesRetDev IS NULL OR cDesRetDev = '' THEN
					LET cDesRetDev = 'NO EXISTE LA DESCRIPCION';
					LET cStatus = '3'; 
				END IF;
			END IF;			
						
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cBanco, cNumCuenta,cNumCheque,dMonto,cCtaDeposito,cCodRetDev,cMotivo, UPPER(TRIM(cDescMotivo)), UPPER(TRIM(cDesBanco)), UPPER(TRIM(cDesRetDev)), cStatus WITH RESUME;
		END FOREACH;
			
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cBanco, cNumCuenta,cNumCheque,dMonto,cCtaDeposito,cCodRetDev,cMotivo, cDescMotivo, cDesBanco, cDesRetDev, cStatus;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cBanco, cNumCuenta,cNumCheque,dMonto,cCtaDeposito,cCodRetDev,cMotivo, cDescMotivo, cDesBanco, cDesRetDev, cStatus;
		END IF;		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 14/12/2015',
'MODULO: CÃMARA COMPENSACIÃN',
'FUNCIONALIDAD: REPORTES RESULTADO DE LA APLICACIÃN',
'DESCRIPCION:SPL que consulta los movimientos resultados de la aplicaciÃ³n.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultamovaplicacion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(10))	
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(80);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultamovaplicacion_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;	
		EXECUTE PROCEDURE bditef:"informix".sp_cce_consultar_chequesdev_consdev2_totales('001',pFecha)
			INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_consultar_chequesdev_consdev2_totales';
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00003';
			END IF;
			
		END;
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;

		RETURN cCodRet, iNumRegistros;		
END PROCEDURE 
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 19/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD:Cheques Devueltos',
'DESCRIPCION: SPL que consulta el total de los cheques devueltos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_genreporteaplicaciondev(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(3)  AS clave_banco,
		CHAR(40) AS des_banco,
		CHAR(20) AS num_cuenta,
		CHAR(7)  AS num_cheque,
		DECIMAL(16,2) AS monto,
		CHAR(20) AS cta_deposito,
		CHAR(20) AS num_cliente,
		CHAR(60) AS razon_social,	
		CHAR(26) AS segundo_nombre,
		CHAR(26) AS apellido_p,
		CHAR(26) AS apellido_m,
		CHAR(26) AS primer_nombre,
		CHAR(35) AS descripcion,
		CHAR(2)  AS motivo,
		CHAR(50) AS des_ret_dev;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE  cClaveBanco CHAR(3);
	DEFINE  cDesBanco CHAR(40);
	DEFINE  cNumCuenta CHAR(20);
	DEFINE  cNumCheque CHAR(7);
	DEFINE  dMonto DECIMAL(16,2);
	DEFINE  cCtaDeposito CHAR(20);
	DEFINE  cNumCliente CHAR(20);
	DEFINE  cRazonSocial CHAR(60);	
	DEFINE  cSegundoNombre CHAR(26);		
	DEFINE  cApePaterno CHAR(26);			
	DEFINE  cApeMaterno CHAR(26);			
	DEFINE  cPrimerNombre CHAR(26);			
	DEFINE  cDescripcion CHAR(35);			
	DEFINE  cMotivo CHAR(2);
	DEFINE cCodRetDev CHAR(5);
	DEFINE cDesCodRetDev CHAR(50);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClaveBanco	= '';
	LET cDesBanco      = '';
	LET cNumCuenta     = '';
	LET cNumCheque     = '';
	LET dMonto         	= 0.00;
	LET cCtaDeposito   = '';
	LET cNumCliente    = '';
	LET cRazonSocial	= '';
	LET cSegundoNombre = '';
	LET cApePaterno     = '';
	LET cApeMaterno     = '';
	LET cPrimerNombre  = '';
	LET cDescripcion    = '';
	LET cMotivo		    = '';
	LET cCodRetDev	 	= '';
	LET cDesCodRetDev	 	= '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno, cApeMaterno, cPrimerNombre, cDescripcion, cMotivo, cDesCodRetDev;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_genreporteaplicaciondev .out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno, cApeMaterno, cPrimerNombre, cDescripcion, cMotivo, cDesCodRetDev;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno, cApeMaterno, cPrimerNombre, cDescripcion, cMotivo, cDesCodRetDev;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno, cApeMaterno, cPrimerNombre, cDescripcion, cMotivo, cDesCodRetDev;
		END IF;
		
		FOREACH 
			
			SELECT cce_cheques_dev.cvebanco, cce_cheques_dev.numcuenta, cce_cheques_dev.numcheque, cce_cheques_dev.monto, cce_cheques_dev.cta_deposito, cce_cheques_dev.numcte, cce_cheques_dev.motivo, cce_cheques_dev.codigo_retorno
			INTO  cClaveBanco,cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cMotivo, cCodRetDev
			FROM bditef:"informix".cce_cheques_dev cce_cheques_dev 
			WHERE cce_cheques_dev.fechapresenta = pFecha
			ORDER BY cce_cheques_dev.sucursal, cce_cheques_dev.cvebanco, cce_cheques_dev.monto, cce_cheques_dev.numcheque

			SELECT FIRST 1 descripcion
			INTO cDesBanco
			FROM bdinteg:"informix".si_bancos 
			WHERE banco = cClaveBanco;

			SELECT FIRST 1 si_cliente.razon_social, si_cliente.nombre2, si_cliente.apell_paterno,si_cliente.apell_materno, si_cliente.nombre1
			INTO cRazonSocial, cSegundoNombre, cApePaterno, cApeMaterno, cPrimerNombre
			FROM bdinteg:"informix".si_cliente si_cliente
			WHERE si_cliente.numcte = cNumCliente;

			SELECT FIRST 1 descripcion
			INTO cDescripcion
			FROM bdinteg:"informix".si_coddevcam
			WHERE codigo = cMotivo;
				
			IF cCodRetDev = '000' THEN 
				LET cDesCodRetDev = 'SI';
			ELSE
				SELECT descripcion 
					INTO cDesCodRetDev 
				FROM bdinteg:"informix".si_codret 
				WHERE codigo_retorno = cCodRetDev
					AND sistema = '01'; 		
				LET cDesCodRetDev = TRIM(TRIM(cCodRetDev)|| ' ' ||TRIM(cDesCodRetDev));
				IF cDesCodRetDev IS NULL OR cDesCodRetDev = '' THEN
					LET cDesCodRetDev = 'NO EXISTE LA DESCRIPCIÃN';
				END IF;
			END IF;								
				
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cClaveBanco, UPPER(TRIM(cDesBanco)), cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, UPPER(TRIM(cRazonSocial)), UPPER(TRIM(cSegundoNombre)), UPPER(TRIM(cApePaterno)), UPPER(TRIM(cApeMaterno)), UPPER(TRIM(cPrimerNombre)), UPPER(TRIM(cDescripcion)), cMotivo, cDesCodRetDev WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno, cApeMaterno, cPrimerNombre, cDescripcion, cMotivo, cDesCodRetDev;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cRazonSocial, cSegundoNombre, cApePaterno, cApeMaterno, cPrimerNombre, cDescripcion, cMotivo, cDesCodRetDev;
		END IF;			
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 14/12/2015',
'MODULO: CÃMARA COMPENSACIÃN',
'FUNCIONALIDAD: REPORTES RESULTADO DE LA APLICACIÃN',
'DESCRIPCION:SPL que genera el reporte de aplicaciÃ²nn de devoluciones .',
'AUTOR: Ing. JosÃ© Antonio RamÃ­rez Franco',
'FECHA MODIFICACIÃN: 17/09/2024',
'DESCRIPCION:Se optimiza la consulta principal y se anexa el parametro fecha.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_genreportedevpresentado(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	    RETURNING CHAR(5) AS codret,
		CHAR(3)  AS clave_banco,
		CHAR(40) AS des_banco,
		CHAR(20) AS num_cuenta,
		CHAR(7)  AS num_cheque,
		DECIMAL(16,2) AS monto,
		CHAR(20) AS cta_deposito,
		CHAR(20) AS num_cliente,
		CHAR(60) AS sucursal,
		CHAR(4)  AS sucursales,
		CHAR(40)  AS des_sucursal;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cClaveBanco	CHAR(3);
	DEFINE cDesBanco CHAR(40);
	DEFINE cNumCuenta CHAR(20);
	DEFINE cNumCheque CHAR(7);
	DEFINE dMonto DECIMAL(16,2);
	DEFINE cCtaDeposito CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cSucursal CHAR(60);
	DEFINE cSucursales CHAR(4);
	DEFINE cDesSucursal   CHAR(40);	
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClaveBanco = '';
	LET cDesBanco      = '';
	LET cNumCuenta     = '';
	LET cNumCheque     = '';
	LET dMonto    	    = 0.00;
	LET cCtaDeposito   = '';
	LET cNumCliente    = '';
	LET cSucursal     = '';
	LET cSucursales       = '';
	LET cDesSucursal   = '';
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cSucursal, cSucursales, cDesSucursal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_genreportedevpresentado.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cSucursal, cSucursales, cDesSucursal;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cSucursal, cSucursales, cDesSucursal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cSucursal, cSucursales, cDesSucursal;
		END IF;
		
		FOREACH 
		
			SELECT {+INDEX(bditef:"informix".cce_cheques_dev idx_cce_cheques_dev_sucursal)}
				  cce_cheques_dev.cvebanco, cce_cheques_dev.numcuenta,cce_cheques_dev.numcheque,cce_cheques_dev.monto, cce_cheques_dev.cta_deposito, cce_cheques_dev.numcte, cce_cheques_dev.sucursal
			INTO cClaveBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cSucursal
			FROM bditef:"informix".cce_cheques_dev cce_cheques_dev 
			WHERE cce_cheques_dev.fechapresenta = pFecha
			ORDER BY cce_cheques_dev.sucursal, cce_cheques_dev.cvebanco, cce_cheques_dev.monto, cce_cheques_dev.numcheque
			
			SELECT FIRST 1 descripcion
			INTO cDesBanco
			FROM bdinteg:"informix".si_bancos 
			WHERE banco = cClaveBanco;

			SELECT FIRST 1 nombre
			INTO cDesSucursal
			FROM bdinteg:"informix".si_sucursales 
			WHERE sucursal = cSucursal;

			LET cSucursales = cSucursal;
	
		
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cClaveBanco, UPPER(TRIM(cDesBanco)), cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cSucursal, cSucursales, UPPER(TRIM(cDesSucursal)) WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cSucursal, cSucursales, cDesSucursal;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cClaveBanco, cDesBanco, cNumCuenta, cNumCheque, dMonto, cCtaDeposito, cNumCliente, cSucursal, cSucursales, cDesSucursal;
		END IF;			
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 14/12/2015',
'MODULO: CÃMARA COMPENSACIÃN',
'FUNCIONALIDAD: REPORTES RESULTADO DE LA APLICACIÃN',
'DESCRIPCION:SPL que genera el reporte de aplicaciÃ²n de devoluciones.',
'AUTOR: Ing. JosÃ© Antonio RamÃ­rez Franco',
'FECHA MODIFICACIÃN: 17/09/2024',
'DESCRIPCION:Se optimiza la consulta principal y se anexa el parametro fecha.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarpolizareasignacion2(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaActual CHAR(10))
		RETURNING CHAR(5) AS codret,
				INTEGER as numeroPoliza
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iNumeroPoliza INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE dFechaActual CHAR(10);
	DEFINE iRegistros 	INTEGER;
	
	LET cCodRet = '00000';
	LET iNumeroPoliza = 1;
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET dFechaActual = '';
	LET iRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet, iNumeroPoliza;

		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/Antonio/sp_ofi_generarpolizareasignacion2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaActual = '' THEN
			LET cCodRet = '00003';
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN

			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 

			RETURN cCodRet, iNumeroPoliza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		DELETE FROM "informix".sw_verificastatuspoliza where usuario_insert = pUsuario;
		INSERT INTO "informix".sw_verificastatuspoliza VALUES (0,pUsuario,'I','0','N','','0');
		
		FOREACH
		EXECUTE PROCEDURE bdirech:"informix".spgenerarpolizareasignacion(TO_DATE(pFechaActual,'%m-%d-%Y'),pUsuario)
		INTO cCodRet, iNumeroPoliza

       IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00017';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet, iNumeroPoliza;
		END IF;
	
        IF cCodRet ='00001' THEN
			LET cCodRet ='00003'; 		
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet, poliza = iNumeroPoliza, total_registros = iRegistros
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet, iNumeroPoliza;
		END IF;
       IF cCodRet ='00002' THEN
			LET cCodRet ='01247';         
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet, poliza = iNumeroPoliza, total_registros = iRegistros
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet, iNumeroPoliza;
		END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01248';         
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet, poliza = iNumeroPoliza, total_registros = iRegistros
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet, iNumeroPoliza;
		END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01244';		
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet, poliza = iNumeroPoliza, total_registros = iRegistros
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet, iNumeroPoliza;         
		END IF;

		LET iRegistros = iRegistros + 1;

		RETURN cCodRet, iNumeroPoliza WITH RESUME;
		END FOREACH;
		
		UPDATE "informix".sw_verificastatuspoliza
		SET status = 'T', error_proceso ='N', error = cCodRet, poliza = iNumeroPoliza, total_registros = iRegistros
		WHERE usuario_insert = pUsuario; 
		RETURN cCodRet, iNumeroPoliza;   
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarpolizareasignacion',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 08/01/2024',
'MODIFICACION: SPL CLON encargado de ejecutar el sp productivo spgenerarpolizareasignacion y registrar el estatus',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ofi_generarpolizareasigquebranto(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaActual DATE, p_Usuario CHAR(8))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS NumeroPoliza
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNumeroPoliza INTEGER;
	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNumeroPoliza=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNumeroPoliza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgenerarpolizareasigquebranto.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaActual ='' OR p_Usuario = ''  THEN
			LET cCodRet = '00003';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNumeroPoliza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DELETE FROM "informix".sw_verificastatuspoliza where usuario_insert = pUsuario;
		INSERT INTO "informix".sw_verificastatuspoliza VALUES (0,pUsuario,'I','0','N','','0');

		EXECUTE PROCEDURE bdirech:"informix".spgenerarpolizareasigquebranto(pFechaActual,p_Usuario)
		INTO  cCodRet,iNumeroPoliza;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, inumeroPoliza;
		END IF;
 
        IF cCodRet ='00001' THEN
			LET cCodRet ='00003';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 		
		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01247';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario;         
		END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01248';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario;         
		END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01244';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario;         
		END IF;

		IF cCodRet = '00000' THEN
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'T', error_proceso ='N', error = cCodRet, poliza = iNumeroPoliza
			WHERE usuario_insert = pUsuario; 
		END IF;

		RETURN cCodRet,iNumeroPoliza;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarpolizareasigquebranto',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardactemoral(pUsuario CHAR(8), 
											  pIdFuncion 		 CHAR(10),
											  pfuncion           CHAR(1),
											  pnumcte            CHAR(20),
											  pstatuscte         CHAR(2),
											  psucursal          CHAR(4),
											  ptp_persona        CHAR(2),
											  ptp_cliente        CHAR(1),
											  prazon_social      CHAR(254),
											  prfc               CHAR(13),
											  pfechaalta         DATE,
											  pnacionalidad      CHAR(2),
											  pnombrecorto       CHAR(60),
											  pnombrecontacto    CHAR(48),
											  ptelefonocontacto  CHAR(13),
											  psufijo            CHAR(2),
											  pgiro              CHAR(20),
											  pactividad_princ   CHAR(3),
											  ppaginainternet    CHAR(30),
                                              pCURP              CHAR(20),
											  pRFCAlt            CHAR(13),
											  pRegimen			 CHAR(3))
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS cNumcte;
					
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumcte CHAR(20);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumcte = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumcte;
		END EXCEPTION;
		
		 --SET DEBUG FILE TO '/tmp/mfinis/sp_guardactemoral.out';
		 --TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumcte;
		END IF;	
				
		IF pfuncion NOT IN('A','B','M') THEN
			LET cCodRet = '00292';
			RETURN cCodRet, cNumcte;
		END IF;			
		
		IF pfuncion IN ('B', 'M') THEN
			IF pnumcte = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumcte;
			END IF;
			IF LENGTH(pnumcte) <> 9 THEN
				LET cCodRet = '00295';
				RETURN cCodRet, cNumcte;
			END IF;
		END IF;
				
		IF pfuncion="A" THEN
			--- Verifica recepcion correcta de datos
			IF psucursal IS NULL  OR ptp_persona IS NULL OR ptp_cliente IS NULL OR prfc IS NULL OR pactividad_princ IS NULL OR pnombrecorto IS NULL OR pgiro IS NULL THEN
					LET cCodRet = "00003";
				   RETURN cCodRet, cNumcte;
			END IF;
		END IF;	
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumcte;
		END IF;		
		
		LET prazon_social = replace(prazon_social,"&#","'");
		LET pnombrecorto = replace(pnombrecorto,"&#","'");

		LET prazon_social = replace(prazon_social,"&+","\\");
		LET pnombrecorto = replace(pnombrecorto,"&+","\\");

		LET prazon_social = replace(prazon_social,"&$"," ");
		LET pnombrecorto = replace(pnombrecorto,"&$"," ");

		LET prazon_social = replace(prazon_social,"&> ","\r ");
		LET pnombrecorto = replace(pnombrecorto,"&> ","\r ");

		LET prazon_social = replace(prazon_social,"&< "," \t");
		LET pnombrecorto = replace(pnombrecorto,"&<"," \t");

		LET prazon_social = replace(prazon_social,"&| "," \b");
		LET pnombrecorto = replace(pnombrecorto,"&| "," \b");

		LET prazon_social = replace(prazon_social,"&% ","\f ");
		LET pnombrecorto = replace(pnombrecorto,"&% ","\f ");

		LET prazon_social = replace(prazon_social,"&.","-");
		LET pnombrecorto = replace(pnombrecorto,"&.","-");
		
		EXECUTE PROCEDURE bdinteg:"informix".ctemoral(cEmpresa, pfuncion, pnumcte, pstatuscte, psucursal, pUsuario, ptp_persona, ptp_cliente, prazon_social, prfc, pfechaalta,
													  pnacionalidad, pnombrecorto, pnombrecontacto, ptelefonocontacto, psufijo, pgiro, pactividad_princ, ppaginainternet, pUsuario,
													  pfechaalta,pCURP,pRFCAlt, pRegimen) INTO cCodRetSp, cNumcte;
													  
		IF cCodRetSp = '12a0' THEN
			LET cCodRet = '00296';
			RETURN cCodRet, cNumcte;												
		END IF;

		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ctemoral';
		ELIF iCodRetSp = 104 THEN
			LET cCodRet = '00022';
			RETURN cCodRet, cNumcte;	
		ELIF iCodRetSp = 105 THEN
			LET cCodRet = '00141';
			RETURN cCodRet, cNumcte;
		ELIF iCodRetSp = 111 THEN
			LET cCodRet = '00161';
			RETURN cCodRet, cNumcte;
		ELIF iCodRetSp = 112 THEN
			LET cCodRet = '00006';
			RETURN cCodRet, cNumcte;				
		ELIF iCodRetSp = 118 THEN
			LET cCodRet = '00293';
			RETURN cCodRet, cNumcte;
		ELIF iCodRetSp = 120 THEN
			LET cCodRet = '00020';
			RETURN cCodRet, cNumcte;			
		END IF;
		RETURN cCodRet, cNumcte;
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 27/05/2014',
'DESCRIPCION:  Se inhibe select a la tabla si_actecon ya que es la tabla del giro',
'			   e intentaba buscar la variable que contiene la actividad',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 25/06/2021',
'DESCRIPCION: Se agrega CURP',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 29/09/2023',
'DESCRIPCION: Se agrega el campo Regimen fiscal y Se amplia el tamaÃ±o del nombre corto a 120 y de razon social a 60',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 25/07/2024',
'DESCRIPCION: Se agrego replace para sustitir los caractes tratados desde front',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_asignacion_usuarios_autorizados(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(2), pOperacion INTEGER,pNumEjecut INTEGER,pNombreEjecut CHAR(100),pFecha DATE)

		RETURNING CHAR(5) AS codret;	
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	
	BEGIN
		-- ****************************************************************************
		-- *                        CONTROL DE ERRORES                                *
		-- ****************************************************************************
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_asignacion_usuarios_autorizados.out';
		--TRACE ON;
		-- ****************************************************************************
		-- *                   VALIDAR LOS PARAMETROS DE ENTRADA                      *
		-- ****************************************************************************
		IF pBandera = '1' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pOperacion IS NULL OR pNumEjecut IS NULL OR pNombreEjecut =  ''  OR pFecha IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
			END IF;
		END IF;
		

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF pBandera = '1' THEN
			EXECUTE PROCEDURE bditef:"informix".sp_cce_controlusuariosaut(pOperacion ,pNumEjecut,pNombreEjecut,pFecha)
				INTO cCodRetSp;
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_controlusuariosaut';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003';
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00776'; --EL USUARIO CAPTURADO YA ESTÃ REGISTRADO EN EL SISTEMA.
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '00716'; --NO EXISTE EL EJECUTIVO QUE DESEA ELIMINAR
			END IF;		
		END IF;
		 
		
			RETURN cCodRet;	
		END ;
END PROCEDURE
DOCUMENT
"AUTOR : Eduardo Ãvila PÃ©rez Tagle",
'MODULO: CÃ¡maras de compensaciÃ³n',
"FUNCIONAMIENTO:SP padre de camaras de compensaciÃ³n - asignaciÃ³n de usuarios autorizados",
"FECHA : 03-03-2023",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_sw_ro_guardaparamsedocta(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int, pTipoOperacion int,
                        pNumCliente char(20), pNumCuenta char(20), pTipoCuenta char(2), pFechaInicio char(10), pFechaFin char(10), pIp char(15), pMacAddress char(12))
        returning char(5) as codret
        
        DEFINE iSqlErr int;
        DEFINE cCodRet char(5);
        DEFINE iRegistros int;
        DEFINE cDiaCorte char(2);
        DEFINE pFechaInicio1 date;
        DEFINE pFechaFin1 date;
		DEFINE iAnioMesApertura INTEGER;
		DEFINE iAnioMesInicio INTEGER;
		DEFINE iExiste SMALLINT;
		DEFINE cProducto CHAR(4);
        
        LET iSqlErr = 0;
        LET cCodRet = '00000';
        LET iRegistros = 0;
		LET cDiaCorte = '';
        LET pFechaInicio1 ='';
        LET pFechaFin1 ='';
		LET iAnioMesApertura = 0;
		LET iAnioMesInicio = 0;
		LET iExiste = 0;
		LET cProducto = '';
        
        begin
			on exception set iSqlErr
				if iSqlErr <> 0 then
						let cCodRet = iSqlErr;
						return cCodRet;
				end if;
			end exception;
							
			--set debug file to '/tmp/mfinis/sp_sw_ro_guardaparamsedocta.out';
			--trace on;
	
			-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
			execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
			
			if cCodRet <> '00000' then
				return cCodRet;
			end if;
	
			if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or
				pTipoOperacion = '' or pNumCliente = '' or pNumCuenta = '' or pTipoCuenta = '' or 
				pFechaInicio = '' or pFechaFin = '' or pIp = '' or pMacAddress = '' then
				
				let cCodRet = '00003';
				return cCodRet;
			end if;
			
			if pTipoOperacion not in('1', '2') then
				let cCodRet = '00005';
				return cCodRet;
			end if;
			
			if pTipoCuenta not in('01', '03', '06') then
				let cCodRet = '00048';
				return cCodRet;
			end if;
			
			-- VALIDACION DE LA FECHA DE APERTURA
			IF pTipoCuenta = '01' THEN
				LET iAnioMesInicio = (SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2))::INTEGER;
				
				SELECT TO_CHAR(fecha_alta, '%Y%m')::INTEGER
				INTO iAnioMesApertura
				FROM bdicheq:sc_maenoc
				WHERE cuenta = pNumCuenta;
				
				IF iAnioMesInicio < iAnioMesApertura THEN
					--LET cCodRet = '00246'; -- LA FECHA DE INICIO DEL PERIODO DE CONSULTA NO PUEDE SER MENOR A LA FECHA DE APERTURA DE LA CUENTA
					--RETURN cCodRet;
				END IF;
			
			ELIF pTipoCuenta = '06' THEN -- CUENTAS DE CREDITO
				LET iAnioMesInicio = (SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2))::INTEGER;
				
				SELECT producto
				INTO cProducto
				FROM sw_ro_ctecta
				WHERE cuenta = pNumCuenta
					AND numcte = pNumCliente
					AND id_oficio = pIdOficio
					AND id_busqueda = pIdBusqueda
					AND id_resulcte = pIdCliente;
					
				IF cProducto = '6001' THEN -- TARJETA DE CREDITO
					SELECT TO_CHAR(fecha_apertura, '%Y%m')::INTEGER
					INTO iAnioMesApertura
					FROM bdicred:sd_maecred
					WHERE num_credito = pNumCuenta and numcte = pNumCliente;
					
					IF iAnioMesInicio < iAnioMesApertura THEN
						--LET cCodRet = '00246'; -- LA FECHA DE INICIO DEL PERIODO DE CONSULTA NO PUEDE SER MENOR A LA FECHA DE APERTURA DE LA CUENTA
						--RETURN cCodRet;
					END IF;
				ELSE
					SELECT TO_CHAR(fecha_apertura, '%Y%m')::INTEGER
					INTO iAnioMesApertura
					FROM bdicred:sd_maecredcrd
					WHERE num_credito = pNumCuenta and numcte = pNumCliente;
					
					IF iAnioMesInicio < iAnioMesApertura THEN
						--LET cCodRet = '00246'; -- LA FECHA DE INICIO DEL PERIODO DE CONSULTA NO PUEDE SER MENOR A LA FECHA DE APERTURA DE LA CUENTA
						--RETURN cCodRet;
					END IF;
				END IF;
				
			END IF;
			
			
			IF pTipoCuenta IN ('03', '06') THEN
			-- Se obtiene el dÃÂ­a de corte de la cuenta
				select 
					case when 
						length(cast(dia_corte as char(2))) = 1 
							then '0' || cast(dia_corte as char(2))
							else cast(dia_corte as char(2))
					end as diaCorte
				into cDiaCorte
				from sw_ro_ctecta
				where id_oficio = pIdOficio
					and id_busqueda = pIdBusqueda
					and id_resulcte = pIdCliente
					and cuenta = pNumCuenta
					and numcte = pNumCliente;
					
				IF pTipoCuenta = '06' THEN

					SELECT producto
					INTO cProducto
					FROM sw_ro_ctecta
					WHERE cuenta = pNumCuenta
						AND numcte = pNumCliente
						AND id_oficio = pIdOficio
						AND id_busqueda = pIdBusqueda
						AND id_resulcte = pIdCliente;
					
					IF cProducto = '6001' THEN -- TARJETA DE CREDITO
						SELECT COUNT(*)
						INTO iExiste
						FROM bdicred:sd_encabezado_edocta
						WHERE TO_CHAR(fecha_emision, '%Y%m') = SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2)
							AND numcte = pNumCliente
							AND num_credito = pNumCuenta;
						
						/*IF iExiste = 0 THEN
							-- No existe informaciÃÂ³n con la fecha de inicio
							--LET cCodRet = '00247'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE INICIO DEL PERIODO DE CONSULTA
							RETURN cCodRet;
						END IF;*/
						
						SELECT COUNT(*)
						INTO iExiste
						FROM bdicred:sd_encabezado_edocta
						WHERE TO_CHAR(fecha_emision, '%Y%m') = SUBSTR(pFechaFin,1,4)||SUBSTR(pFechaFin,6,2)
							AND numcte = pNumCliente
							AND num_credito = pNumCuenta;
							
						/*IF iExiste = 0 THEN
							-- No existe informaciÃÂ³n con la fecha de fin
							--LET cCodRet = '00248'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE FIN DEL PERIODO DE CONSULTA
							RETURN cCodRet;
						END IF;*/
						
					ELSE -- OTROS PRODUCTOS DE CREDITO
						
						SELECT COUNT(*)
						INTO iExiste
						FROM bdicred:sd_encabezado_edoctacrd
						WHERE TO_CHAR(fecha_emision, '%Y%m') = SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2)
							AND numcte = pNumCliente
							AND num_credito = pNumCuenta;
						
						/*IF iExiste = 0 THEN
							-- No existe informaciÃÂ³n con la fecha de inicio
							--LET cCodRet = '00247'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE INICIO DEL PERIODO DE CONSULTA
							RETURN cCodRet;
						END IF;*/
						
						SELECT COUNT(*)
						INTO iExiste
						FROM bdicred:sd_encabezado_edoctacrd
						WHERE TO_CHAR(fecha_emision, '%Y%m') = SUBSTR(pFechaFin,1,4)||SUBSTR(pFechaFin,6,2)
							AND numcte = pNumCliente
							AND num_credito = pNumCuenta;
							
						/*IF iExiste = 0 THEN
							-- No existe informaciÃÂ³n con la fecha de fin
							--LET cCodRet = '00248'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE FIN DEL PERIODO DE CONSULTA
							RETURN cCodRet;
						END IF;*/
						
					END IF;
				
				END IF;
			ELIF pTipoCuenta = '01' THEN
			
				/*SELECT COUNT(aniomes)
				INTO iExiste
				FROM bdicheq:sc_maehis_factelect
				WHERE aniomes = SUBSTR(pFechaInicio,1,4)||SUBSTR(pFechaInicio,6,2)
					and cuenta = pNumCuenta;*/
				
				/*IF iExiste = 0 THEN
					-- No existe informaciÃÂ³n con la fecha de inicio
					--LET cCodRet = '00247'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE INICIO DEL PERIODO DE CONSULTA
					RETURN cCodRet;
				END IF;*/
					
				/*SELECT COUNT(aniomes)
				INTO iExiste
				FROM bdicheq:sc_maehis_factelect
				WHERE aniomes = SUBSTR(pFechaFin,1,4)||SUBSTR(pFechaFin,6,2)
					and cuenta = pNumCuenta;*/
					
				/*IF iExiste = 0 THEN
					-- No existe informaciÃÂ³n con la fecha de fin
					--LET cCodRet = '00248'; -- NO EXISTE INFORMACIÃ?N DE LA FECHA DE FIN DEL PERIODO DE CONSULTA
					RETURN cCodRet;
				END IF;*/
				
				LET cDiaCorte = '01';

			END IF;
			
			let pFechaInicio = substr(pFechaInicio, 1, 8)||cDiaCorte;
			let pFechaFin = substr(pFechaFin, 1, 8)||cDiaCorte;
			
			let pFechaInicio1 = EXTEND(MDY(SUBSTR(pFechaInicio,6,2),SUBSTR(pFechaInicio,9,2),SUBSTR(pFechaInicio,1,4)), YEAR TO SECOND);
			let pFechaFin = SUBSTR(pFechaFin,6,2)||'-'||SUBSTR(pFechaFin,9,2)||'-'||SUBSTR(pFechaFin,1,4);
			EXECUTE PROCEDURE sp_sw_ro_evalua_fecha(pFechaFin) INTO pFechaFin1;
			
			if pTipoOperacion = 1 then -- InserciÃÂ³n de datos
					insert into sw_ro_edocta(id_resulcte, id_busqueda, id_oficio, numcte, cuenta, tipo_cuenta, fecha_inicio, fecha_fin, user_insert, ip_insert, mac_insert)
					values(pIdCliente, pIdBusqueda, pIdOficio, pNumCliente, pNumCuenta, pTipoCuenta, pFechaInicio1, pfechafin1, pUsuario, pIp, pMacAddress);
			elif pTipoOperacion = 2 then -- ActializaciÃÂ³n de datos
					update sw_ro_edocta
					set fecha_inicio = pFechaInicio1,
							fecha_fin = pFechaFin1
					where id_busqueda = pIdBusqueda
							and id_oficio = pIdOficio
							and id_resulcte = pIdCliente
							and numcte = pNumCliente
							and cuenta = pNumCuenta
							and tipo_cuenta = pTipoCuenta
							and user_insert = pUsuario
							and ip_insert = pIp
							and mac_insert = pMacAddress;
			end if;
			
			-- ActualizaciÃÂ³n de las banderas de estatus
			-- En la cuenta
			update sw_ro_ctecta
			set certifica_edocuenta = '1'
			where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente and cuenta = pNumCuenta;
			
			update sw_ro_resulcte
			set certifica_edocuenta = '1'
			where id_oficio = pIdOficio and id_busqueda = pIdBusqueda and id_resulcte = pIdCliente;
			
			update sw_ro_maeoficios
			set certifica_edocuenta = '1'
			where id_oficio = pIdOficio;

			return cCodRet;
        end;
end procedure;