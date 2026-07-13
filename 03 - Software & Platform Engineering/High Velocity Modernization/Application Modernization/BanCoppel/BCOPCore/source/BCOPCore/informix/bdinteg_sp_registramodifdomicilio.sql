CREATE PROCEDURE "informix".sp_registramodifdomicilio(pCliente CHAR(20), 
                                                      pOrigen SMALLINT, 
													  pTipo_dir CHAR(1), 
													  pSecuencia INT,
                                                      pSucursal CHAR(4), 
													  pFecha DATE, 
													  pUsr_captura CHAR(8), 
													  pUsr_autoriza CHAR(8))

--DATOS A REGRESAR---
RETURNING
CHAR(5);      -- Código de Retorno
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr    INTEGER;
DEFINE cCodRet    CHAR(5);
---------------------------

--INICIALIZACION DE VARIABLES--
LET iSqlErr    = 0;
LET cCodRet    = '00000';
--------------------------

	--SET DEBUG FILE TO "/home/informix/sp_RegistraModifDomicilio.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr; 
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--Valida si ha habido modificaicon a la direccion
	IF EXISTS(SELECT 1 FROM bdinteg:si_direcciones WHERE secuencia = pSecuencia AND numcte = pCliente) THEN
		-- Inserta en la tabla los datos que corresponden a la bitácora del registro que se está modificando
		INSERT INTO bdinteg:"informix".si_bitacora_cambiosdom
			(cliente, origen, tipo_dir, secuencia, sucursal, fecha, usr_captura, usr_autoriza)
		VALUES
			(pCliente, pOrigen, pTipo_dir, pSecuencia, pSucursal, pFecha, pUsr_captura, pUsr_autoriza);
	END IF;
	
	RETURN cCodRet;
	
	END
END PROCEDURE
DOCUMENT
'Actualización del domicilio del cliente a través de cualquier canal (Tienda, Sucursal, CAT)',
'se deberá de registrar en la tabla si_bitacora_cambiosdom para llevar un historial de los cambios',
'AUTOR: Nancy Sevilla Camacho',
'FECHA: 20/Abril/2011',
'BD   : bdinteg',
'VER  : 1.0',
'AUTOR: Victor Hugo Nunez',
'FECHA: 21/05/2012',
'Descripcion: Se agrega validacion antes de insertar en la bitacora';

CREATE PROCEDURE "informix".sp_consultarnombrecliente(p_sEmpresa CHAR(3), p_sNumcte CHAR(20))
	RETURNING 	CHAR(6) AS retorno,
				CHAR(3) AS empresa, 
				CHAR(20) AS numcte, 
				CHAR(2) AS status_cte, 
				CHAR(4) AS sucursal, 
				CHAR(2) AS tpo_persona,
				CHAR(1) AS tipo_cliente,
				CHAR(26) AS apell_paterno, 
				CHAR(26) AS apell_materno,
				CHAR(26) AS nombre1, 
				CHAR(26) AS nombre2, 
				CHAR(60) AS razon_social,
				CHAR(13) AS rfc,
				DATE AS fecha_alta,
				CHAR(20) AS numcte_ref;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(6);
	DEFINE v_sEmpresa 		CHAR(3);
	DEFINE v_sNumCte		CHAR(20);
	DEFINE v_sStatusCte		CHAR(2);
	DEFINE v_sSucursal		CHAR(4);
	DEFINE v_sTipoPersona	CHAR(2);
	DEFINE v_sTipoCliente	CHAR(1);
	DEFINE v_sApellPaterno	CHAR(26);
	DEFINE v_sApellMaterno	CHAR(26);
	DEFINE v_sNombre1		CHAR(26);
	DEFINE v_sNombre2		CHAR(26);
	DEFINE v_sRazonSocial	CHAR(60);
	DEFINE v_sRfc			CHAR(13);
	DEFINE v_dFechaAlta		DATE;
	DEFINE v_sNumCteRef		CHAR(20);
	DEFINE v_sRfc_alterno   CHAR(13);
	DEFINE cSufijo          CHAR(60);	--DSB 21/05/2013
	
	------------------------------------------------------------------------------------------
	--Creado por Erick Zamora 03/Agosto/2009
	--Obtiene los datos del cliente especificado, o de todas los clientes del catalogo
	--Caso de uso asociado: PCU-bdinteg\CU-0104-ConsultarNombreCliente-SPL
	--SET DEBUG FILE TO "/tmp/sp_consultarNombreCliente.out"; 
	--TRACE ON;
	------------------------------------------------------------------------------------------	
	
	LET v_sValRetorno = '000001';
	--DSB 21/05/2013
	LET iSqlErr			    = 0;	
	LET v_sEmpresa 		    = '';
	LET v_sNumCte		    = '';
	LET v_sStatusCte		= '';
	LET v_sSucursal		    = '';
	LET v_sTipoPersona	    = '';
	LET v_sTipoCliente	    = '';
	LET v_sApellPaterno     = '';
	LET v_sApellMaterno	    = '';
	LET v_sNombre1		    = '';
	LET v_sNombre2		    = '';
	LET v_sRazonSocial	    = '';
	LET v_sRfc			    = '';
	LET v_dFechaAlta		= DATE(1);
	LET v_sNumCteRef		= '';
	LET v_sRfc_alterno      = '';
	LET cSufijo             = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/sp_consultarNombreCliente.out"; 
		--TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--DEBE PROPORCIONARSE LA EMPRESA
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumcte,'') = '' THEN
			RETURN v_sValRetorno,'','','','','','','','','','','','','','';
		END IF;
		
		LET p_sNumcte = LPAD(TRIM(p_sNumcte),9,'0');
		
		FOREACH
			SELECT empresa, numcte, status_cte, sucursal, tpo_persona, tipo_cliente, apell_paterno,
			apell_materno, nombre1, nombre2, razon_social, rfc, fecha_alta, numcte_ref, rfc_alterno
			INTO v_sEmpresa, v_sNumCte, v_sStatusCte, v_sSucursal, v_sTipoPersona, v_sTipoCliente, v_sApellPaterno,
			v_sApellMaterno, v_sNombre1, v_sNombre2, v_sRazonSocial, v_sRfc, v_dFechaAlta, v_sNumCteRef, v_sRfc_alterno
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = p_sEmpresa AND numcte = p_sNumcte
			
			--DSB 21/05/2013		
			SELECT NVL(descripcion, '')
			INTO cSufijo
			FROM bdinteg:"informix".si_sufijos suf,
			bdinteg:"informix".si_ctepm cte
			WHERE suf.codigo = cte.sufijo
			AND cte.numcte = p_sNumcte;
			LET v_sRazonSocial = TRIM(NVL(v_sRazonSocial,''))||" "||TRIM(NVL(cSufijo,''));

			IF v_sRfc_alterno IS NOT NULL AND v_sRfc_alterno <> "" THEN
               LET v_sRfc = v_sRfc_alterno;
            END IF;	
			
			LET v_sValRetorno = '000000';
			RETURN v_sValRetorno,v_sEmpresa, v_sNumCte, v_sStatusCte, v_sSucursal, v_sTipoPersona, v_sTipoCliente, v_sApellPaterno,
			v_sApellMaterno, v_sNombre1, v_sNombre2, v_sRazonSocial, v_sRfc, v_dFechaAlta, v_sNumCteRef WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
DOCUMENT
'MODIFICO: Jose Luis Polanco B.',
'FECHA: DSB 21/05/2013',
'DESCRIPCION: Se agrega el "sufijo" a la variable de retorno "v_sRazonSocial" para que aparesca en la aplicacion',
'			  al igual ques e agregan la inicializaciones de variables que por regla deben de tener los procedimientos';

CREATE PROCEDURE "informix".sp_obtenerfechaaperturasucursal(p_cSucursal CHAR(4))
	RETURNING 	CHAR(6) AS retorno,
				DATE AS fecha_inicio;
				
				
	DEFINE iSqlErr			INTEGER;
	DEFINE cRetorno			CHAR(6);
	DEFINE dFecha_inicio	DATE;
				
	--SET DEBUG FILE TO "/tmp/sp_obtenerfechaaperturasucursal.out";
	--TRACE ON;
	
	LET isqlerr 	     = 0;
	LET cRetorno         = '000001';
	LET dFecha_inicio	 = '';
	
		BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'';
			END IF;
		END EXCEPTION;
		
		IF NVL(p_cSucursal,'') = '' THEN
			RETURN cRetorno,dFecha_inicio;
		END IF;
		
		 SET ISOLATION TO DIRTY READ;
		 SET LOCK MODE TO WAIT 3;
		 
		 --IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_sucursales WHERE sucursal = p_cSucursal) THEN   
		--	SELECT fecha_insert INTO dFecha_inicio FROM bdinteg:"informix".si_sucursales WHERE sucursal = p_cSucursal;
		--	LET cRetorno = '000000';
		 --END IF;

			LET dFecha_inicio = mdy('05','20','2007');
			LET cRetorno = '000000';
		 
		 RETURN cRetorno, dFecha_inicio; 
 	END;
END PROCEDURE
DOCUMENT
'CREADO: Josue Zepeda',
'FECHA: 25/02/2013',
'DESCRIPCION: Para obtener fecha_inicio para Validación de Fechas (Paquetes Operativos y de Cheques)',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obt_datosempresa_bei(pRfc char(15), pNumCte char(9), pCuenta char(20), pFechaEmpresa date, pIdUsuarioDesignado char(30))
	RETURNING char(5), char(13), char(41), char(2);
	
-- Realizó: Manuel Ramos Figueroa
-- Actividad: Obtiene los datos del cliente de BEI
-- Fecha de Creación: 20/07/2011

-- Se ajusto la longitud de pIdUsuarioDesignado de 13 a 30.
-- Fecha:02/Agosto/2012

--Ajustes para omitir el dato de la fecha de constitución.
--Fecha 30/Mayo/2013
--Berenice Noriega Guevara (BanCoppel).

	DEFINE sql_err integer;
	DEFINE cCod_ret char(5);
	DEFINE cRFC char(13);
	DEFINE cNombre char(41);
	DEFINE cIdStatus char(2);
	
	LET cCod_ret = '00000';
	LET cRFC = '';
	LET cNombre = '';
	LET cIdStatus = '';
	
	--SET debug FILE TO "/home/informix/ivonne/sp_obt_datosempresa_bei.out";
	--Trace ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, cRFC, cNombre, cIdStatus;
			END IF
		END EXCEPTION;

		IF NVL(TRIM(pRfc), '') = '' AND NVL(TRIM(pNumCte), '') = '' AND NVL(TRIM(pCuenta), '') = '' AND NVL(pFechaEmpresa, '') = '' AND NVL(TRIM(pIdUsuarioDesignado), '') = '' THEN
			LET cCod_ret = '00001'; --datos incompletos
		ELSE
		
			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
		
			SELECT rfc INTO cRFC FROM bdinteg:"informix".si_cliente WHERE rfc = pRfc AND numcte = pNumCte AND tpo_persona = '02' AND tipo_cliente = '1';
			IF NVL(cRFC, '') <> '' THEN
				SELECT a.id_status 
				INTO cIdStatus 
				FROM bdinteg:"informix".si_bpiusuariospm a, bdicheq:"informix".sc_maechq c 
				WHERE a.num_cliente = pNumCte 
				AND a.num_cliente = c.num_cte 
				AND a.no_identificacion_oficial = pIdUsuarioDesignado 
				AND c.cuenta = pCuenta;

				IF NVL(cIdStatus, '') = '' THEN
					LET cCod_ret = '00003'; --cliente no existe				
				ELSE
				
					SET LOCK MODE TO WAIT ;
					SET ISOLATION DIRTY READ ;
				
					SELECT nombre_corto 
					INTO cNombre  
					FROM bdinteg:"informix".si_ctepm 
					WHERE numcte = pNumCte; 
					--AND fecha_constitct = pFechaEmpresa;

					IF NVL(TRIM(cNombre), '') = '' THEN
						LET cCod_ret = '00004'; --fecha no existe
					END IF
				END IF
			ELSE
				LET cCod_ret = '00002'; --rfc no existe
			END IF
		END IF
		RETURN cCod_ret, cRFC, cNombre, cIdStatus;

	END
END PROCEDURE;