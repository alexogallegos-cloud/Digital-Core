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