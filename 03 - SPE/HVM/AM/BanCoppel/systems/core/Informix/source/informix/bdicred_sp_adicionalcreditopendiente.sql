CREATE PROCEDURE "informix".sp_adicionalcreditopendiente(pempresa CHAR(3), 
														pNumCteTitular CHAR(20),
														pNumTarjetaTitular CHAR(20),
														pNumCteAdicional CHAR(20),
														pCredito CHAR(20),
														pApell_Paterno CHAR(26),
														pApell_Materno CHAR(26),
														pNombre1 CHAR(26),
														pNombre2 CHAR(26),
														pRfc CHAR(13),
														pFechaNacimiento CHAR(10),
														pProductoCredito CHAR(4),
														pTarjetaReposicion CHAR(20),
														pTipoEjecucion CHAR(1))												
RETURNING 
	CHAR (6) AS codRet,
	CHAR (20) AS NumCteAdicional,
	CHAR (20) AS Credito,
	CHAR (26) AS Apell_Paterno,
	CHAR (26) AS Apell_Materno,
	CHAR (26) AS Nombre1,
	CHAR (26) AS Nombre2,
	CHAR (13) AS Rfc,
	CHAR (10) AS FechaNacimiento,
	CHAR (4) AS ProductoCredito,
	CHAR (20) AS TarjetaReposicion;
	

	DEFINE ccodRet CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCteAdicional CHAR(20);
	DEFINE cCredito CHAR(20);
	DEFINE cApell_Paterno CHAR(26);
	DEFINE cApell_Materno CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cRfc CHAR(13);
	DEFINE cFechaNacimiento CHAR(10);
	DEFINE cProductoCredito CHAR(4);
	DEFINE cTarjetaReposicion CHAR(20);
	DEFINE sConreg SMALLINT;
	
	LET ccodRet = '000000';
	LET iSqlErr = 0;
	LET cNumCteAdicional = '';
	LET cCredito = '';
	LET cApell_Paterno = '';
	LET cApell_Materno = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cRfc = '';
	LET cFechaNacimiento = '';
	LET cProductoCredito = '';
	LET cTarjetaReposicion = '';
	LET sConreg = 0;
	
	
    BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET ccodRet = iSqlErr;
			   RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
			END IF;
		END EXCEPTION;

		 --SET DEBUG FILE TO '/respaldosbd/Alexis/trace1.out';
		 --TRACE ON;	
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
	IF NVL(pTipoEjecucion,'') <> '' THEN
		
		IF NVL(pTipoEjecucion,'') = '1' Then
			---INSERT
			IF NVL(pNumCteTitular,'') <> '' AND
			NVL(pNumTarjetaTitular,'') <> '' AND
			NVL(pNumCteAdicional,'') <> '' AND
			NVL(pCredito,'') <> '' AND
			NVL(pApell_Paterno,'') <> '' AND
			NVL(pNombre1,'') <> '' AND
			NVL(pRfc,'') <> '' AND
			NVL(pFechaNacimiento,'') <> '' AND
			NVL(pProductoCredito,'') <> '' Then
				
				SELECT NumCteAdicional, Credito, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, FechaNacimiento, ProductoCredito,TarjetaReposicion 
				INTO cNumCteAdicional, cCredito, cApell_Paterno, cApell_Materno, cNombre1, cNombre2, cRfc,cFechaNacimiento, cProductoCredito,cTarjetaReposicion
				FROM bdicred:"informix".sd_adicionalespendientes 
				WHERE Credito = pCredito 
				AND NumCteTitular = pNumCteTitular 
				AND NumCteAdicional = pNumCteAdicional;
				
				IF DBINFO('sqlca.sqlerrd2') = 1 THEN
					LET cCodRet = '000000';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;	
				
				INSERT INTO bdicred:"informix".sd_adicionalespendientes(empresa,NumCteTitular,NumTarjetaTitular,NumCteAdicional,Credito,Apell_Paterno,Apell_Materno,Nombre1,Nombre2,Rfc,FechaNacimiento,ProductoCredito,TarjetaReposicion)
				VALUES (pempresa,pNumCteTitular,pNumTarjetaTitular,pNumCteAdicional,pCredito,pApell_Paterno,pApell_Materno,pNombre1,pNombre2,pRfc,pFechaNacimiento,pProductoCredito, pTarjetaReposicion);

			ELSE
				LET ccodRet = "000002";
			END IF;
		END IF;
		
		IF NVL(pTipoEjecucion,'') = '2' Then
			--Obtiene datos del cliente
			IF NVL(pNumCteTitular,'') <> '' AND
			NVL(pNumTarjetaTitular, '') = '' AND
			NVL(pCredito,'') <> '' Then
			
				FOREACH
			
							SELECT NumCteAdicional, Credito, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, FechaNacimiento, ProductoCredito,TarjetaReposicion 
							INTO cNumCteAdicional, cCredito, cApell_Paterno, cApell_Materno, cNombre1, cNombre2, cRfc,cFechaNacimiento, cProductoCredito,cTarjetaReposicion
							FROM bdicred:"informix".sd_adicionalespendientes 
							WHERE Credito = pCredito 
							AND (NumCteTitular = pNumCteTitular 
							OR NumCteAdicional = pNumCteAdicional)
							
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '000004';
								RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
							END IF;	

							LET ccodRet = "000000";
							RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito, cTarjetaReposicion WITH RESUME;
							
				END FOREACH;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '000004';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;	
				
				RETURN;
				
			ELSE
				LET ccodRet = "000003";
			END IF;
			
			IF NVL(pNumTarjetaTitular,'') <> '' AND
			NVL(pNumCteTitular,'') = '' AND
			NVL(pCredito,'') <> '' Then
			
				FOREACH

						SELECT NumCteAdicional,Credito, Apell_Paterno,Apell_Materno,Nombre1,Nombre2,Rfc,FechaNacimiento,ProductoCredito,TarjetaReposicion
						INTO cNumCteAdicional,cCredito, cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion
						FROM bdicred:"informix".sd_adicionalespendientes
						WHERE NumTarjetaTitular = pNumTarjetaTitular
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '000004';
							RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
						END IF;	
						
						LET ccodRet = "000000";
						RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion WITH RESUME;

				END FOREACH;
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '000004';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;
				
				RETURN;
				
			ELSE
				LET ccodRet = "000003";
			END IF;
			

			IF NVL(pCredito,'') <> '' AND
			NVL(pNumTarjetaTitular,'') = '' AND
			NVL(pNumCteTitular,'') = '' Then
				
				FOREACH
				
					SELECT NumCteAdicional,Credito,Apell_Paterno,Apell_Materno,Nombre1,Nombre2,Rfc,FechaNacimiento,ProductoCredito,TarjetaReposicion
					INTO cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion
					FROM bdicred:"informix".sd_adicionalespendientes
					WHERE Credito = pCredito
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '000004';
						RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
					END IF;	
					
					LET ccodRet = "000000";
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion WITH RESUME;

				END FOREACH;
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '000004';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;
				
				RETURN;

			Else
				LET ccodRet = "000003";
			END IF;
				
		END IF;
		
		
		IF NVL(pTipoEjecucion,'') = '3' Then
			--Validar si existe
				SELECT NumCteAdicional, Credito, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, FechaNacimiento, ProductoCredito,TarjetaReposicion
				INTO cNumCteAdicional, cCredito, cApell_Paterno, cApell_Materno, cNombre1, cNombre2, cRfc, cFechaNacimiento, cProductoCredito,cTarjetaReposicion
				FROM bdicred:"informix".sd_adicionalespendientes 
				WHERE empresa = pempresa
				AND NumCteTitular = pNumCteTitular
				AND NumTarjetaTitular = pNumTarjetaTitular
				AND NumCteAdicional = pNumCteAdicional
				AND Credito = pCredito;

				IF DBINFO('sqlca.sqlerrd2') = 1 THEN
					LET cCodRet = '000007';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;	
		END if;
		
		IF NVL(pTipoEjecucion,'') = '4' Then
			--ELIMINA REGISTRO DE sd_adicionalespendientes
			
			DELETE FROM bdicred:"informix".sd_adicionalespendientes
			WHERE empresa = pempresa
			AND NumCteTitular = pNumCteTitular
			AND NumTarjetaTitular = pNumTarjetaTitular
			AND NumCteAdicional = pNumCteAdicional
			AND Credito = pCredito;
			
			LET ccodRet = "000000";
		
		END IF;

		IF NVL(pTipoEjecucion,'') <> '1' AND
		NVL(pTipoEjecucion,'') <> '2' AND
		NVL(pTipoEjecucion,'') <> '3' AND
		NVL(pTipoEjecucion,'') <> '4' Then
				LET ccodRet = "000005";
		End If;

	ELSE
		LET ccodRet = "000001";
	END IF;
	
	RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
	
END;
END PROCEDURE

DOCUMENT
'Folio: 226 - RQM 10 810 Solicitud de Tarjetas Adicionales Tarjeta de Crédito.',
'Autor: 97247642 - Ibarra Verdugo Oscar Alexis',
'BD: bdicred',
'Solicita:	Abraham Narvaez',
'Fecha: 15/11/2017',
'Descripcion: Se crea un procedimiento almacenado el cual guarde y obtenga los datos del cliente que realizó la solicitud de la tarjeta adicional para los productos oro y platino.';

CREATE PROCEDURE "informix".sp_cant_adicionales_pendientes(pEmpresa CHAR(3), 
															pNumCteTitular CHAR(20),
															pCredito CHAR(20))					
	--DATOS A REGRESAR
	RETURNING 
	CHAR (6) AS cCodRet,
	SMALLINT AS iCantAdic;
	
--============= DEFINIR VARIABLES =============	
	DEFINE iSqlErr SMALLINT;
	DEFINE iSamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE cCodRet CHAR(6);
	DEFINE iCantAdic SMALLINT;
	
--============= INICIALIZAR VARIABLES ===========	
	LET iSqlErr = 0;
	LET iSamErr = 0;
	LET cErrorInfo = '';
	LET cCodRet = '000000';
	LET iCantAdic = 0;
	
--============= INICIALIZAR VARIABLES ===========
BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		LET cCodRet = iSqlErr;
		RETURN cCodRet,iCantAdic;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
	-- SET DEBUG FILE TO "/respaldosbd/Bryan/sp_cant_adicionales_pendientes.out";
	-- TRACE ON;
	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCteTitular,'') = '' OR NVL(pCredito,'') = '' THEN
		LET cCodRet = '000001';
	ELSE
		--Consultar la cantidad de adicionales que hay
		SELECT COUNT(credito) 
		INTO iCantAdic 
		FROM bdicred:"informix".sd_adicionalespendientes
		WHERE empresa = pEmpresa
		AND NumCteTitular = pNumCteTitular
		AND Credito = pCredito;
		
		IF iCantAdic = 0 THEN
			LET cCodRet = '000002';
		END IF;
	END IF;
	
	RETURN cCodRet,iCantAdic;
END
END PROCEDURE

DOCUMENT
'Folio: 226 - RQM 10 810 Solicitud de Tarjetas Adicionales Tarjeta de Credito.',
'Autor: 93034687 - Bryan Limon',
'BD: bdicred',
'Solicita:	Abraham Narvaez',
'Fecha: 15/11/2017',
'Descripcion: Se crea un procedimiento almacenado que cuente cuantas solicitudes para adicionales de tarjeta oro o platino existen';

CREATE PROCEDURE "informix".sp_elimina_adicionales_pendientes (pEmpresa char(3),pClienteAdicional char(20),pCredito char(20))
	--DATOS A REGRESAR
	RETURNING 
	CHAR(6) AS cCodRet;
	
--============= DEFINIR VARIABLES =============
	DEFINE cCodRet CHAR(6);
	DEFINE iSqlErr SMALLINT;
	DEFINE iSamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE sClienteTitular CHAR(20);
	
--============= INICIALIZAR VARIABLES ===========
	LET cCodRet = '000000';
	LET sClienteTitular = '';
--==================================================
	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
			LET cCodRet = iSqlErr;
			RETURN  cCodRet;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
				
		-- SET DEBUG FILE TO "/respaldosbd/Bryan/sp_elimina_adicionales_pendientes.out";
		-- TRACE ON;
		
		IF NVL(pEmpresa,'') = '' OR NVL(pClienteAdicional,'') = '' OR NVL(pCredito,'') = '' THEN
			LET cCodRet = '000001';
		ELSE
			--Validar que exista el adicional en la tabla de sd_adicionalespendientes
			SELECT LIMIT 1 numctetitular 
			INTO sClienteTitular
			FROM bdicred:"informix".sd_adicionalespendientes
			WHERE empresa = pEmpresa AND numcteadicional = pClienteAdicional 
			AND credito = pCredito;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				--Registro no existe
				LET cCodRet = '000002';
			ELSE
				-- Existe y se elimina el registro
				DELETE FROM bdicred:"informix".sd_adicionalespendientes
				WHERE empresa = pEmpresa AND numcteadicional = pClienteAdicional 
				AND credito = pCredito;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					-- Si existe el registro pero no se elimino 
					LET cCodRet = '000003';
				END IF;
			END IF
		END IF;

		RETURN  cCodRet;
END
END PROCEDURE

DOCUMENT 
'Folio: 226',
'Autor: 93034687 - Bryan Limon',
'Fecha: 15/11/2017',
'Modificación: Crear procedimiento el cúal consulte si existe el registro en la tabla sd_adicionalespendientes y eliminarlo',
'Sustento: basado en el requerimiento 10 810 Solicitud de Tarjetas Adicionales Tarjeta de Crédito',
'Solicita: Abrham Narvaez',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_obtienecomisionrepo(pEmpresa CHAR(3), 
													pProducto CHAR(4),
													pMotivo CHAR(2))					
	--DATOS A REGRESAR
	RETURNING 
	CHAR (6) AS cCodRet,
	DECIMAL(18,2) AS dMontoRepo;
--============= DEFINIR VARIABLES =============	
	DEFINE isqlErr SMALLINT;
	DEFINE isamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE cCodRet CHAR(6);
	DEFINE dMontoRepo DECIMAL(18,2);
--============= INICIALIZAR VARIABLES ===========	
	LET isqlErr = 0;
	LET isamErr = 0;
	LET cErrorInfo = '';
	LET cCodRet = '000000';
	LET dMontoRepo = 0.00;
--============= INICIALIZAR VARIABLES ===========
BEGIN
	ON EXCEPTION SET isqlErr, isamErr, cErrorInfo
		LET cCodRet = isqlErr;
		RETURN cCodRet,dMontoRepo;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
	-- SET DEBUG FILE TO "/respaldosbd/Alexis/sp_obtienecomisionrepo.out";
	-- TRACE ON;
	
	IF NVL(pEmpresa,'') = '' OR NVL(pProducto,'') = '' OR NVL(pMotivo,'') = '' THEN
		LET cCodRet = '000001';
	ELSE
		--Consultar el monto de reposición
		IF pMotivo = '01' Then				
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_rob AND a.empresa = b.empresa AND  num_producto = pProducto 
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '02' Then
			SELECT 	a.monto 
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_ext AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '03' Then
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_danmal AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '04' Then
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_acl AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '05' Then
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_ven AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		ELIF pMotivo = '06' Then
			SELECT 	a.monto
			INTO 	dMontoRepo
			FROM 	bdicred:"informix".sd_tpcomis a, bdicred:"informix".sd_definicion b 
			WHERE 	a.cod_comis = b.cod_rep_pet AND a.empresa = b.empresa AND num_producto = pProducto
			AND 	a.empresa = pEmpresa;
		END IF;
	
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			-- No Hubo registros
			LET cCodRet = '000001';
		ELSE
			IF dMontoRepo = 0 THEN
				-- Monto 0
				LET cCodRet = '000002';
			END IF
		END IF;
	END IF;
	
	RETURN cCodRet,dMontoRepo;
END
END PROCEDURE

DOCUMENT
'Folio: 226 - RQM 10 810 Solicitud de Tarjetas Adicionales Tarjeta de CrÃ©dito.',
'Autor: 97247642 - Alexis Ibarra',
'BD: bdicred',
'Solicita:	Abraham Narvaez',
'Fecha: 15/11/2017',
'Descripcion: Se crea un procedimiento almacenado que consulte el monto por reposición según la empresa, el producto y el motivo.';

CREATE PROCEDURE "informix".sp_validacteadicional(pEmpresa CHAR(3), pNumCteTitular CHAR(20), pNumCteAdicional CHAR(20), pNumCredito CHAR(20))
RETURNING CHAR(6) AS cCodRet;

DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cResp CHAR(1);


LET iSqlErr = 0;
LET iIsamErr = 0;
LET cCodRet = '000000';
LET cResp = '';


BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	-- SET DEBUG FILE TO '/respaldosbd/Bryan/351/trace.sql';
	-- TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF NVL(pEmpresa,'') = '' OR NVL(pNumCteTitular,'') = '' OR NVL(pNumCteAdicional,'') = '' OR NVL(pNumCredito,'') = '' THEN
		LET cCodRet = '000001';
	ELSE
		SELECT 1 
		INTO cResp
		FROM bdicred:"informix".sd_adicionalespendientes
		WHERE empresa = pEmpresa
		AND numctetitular = pNumCteTitular
		AND numcteadicional = pNumCteAdicional
		AND credito = pNumCredito;		
		
		IF DBINFO('sqlca.sqlerrd2') = 1 THEN
			LET cCodRet = '000002';
		END IF;
	END IF;
	RETURN cCodRet;
END
END PROCEDURE

DOCUMENT
'Descripcion: Se realiza procedimiento para validar que ya exista el cliente como prospecto en la tabla sd_adicionalespendientes',
'AUTOR : 93034687- Bryan Limon',
'FECHA : 05/12/2017',
'Folio : 351 - RQM 10 810 Solicitud de Tarjetas Adicionales Tarjeta de Crédito',
'Solicita : Abraham Narvaez ',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_depura_sd_movhis()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cStatus      CHAR(2);

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET cStatus      = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr
	IF iSqlErr != 0 THEN
		LET cCodRet = iSqlErr;		
		RETURN cCodRet;
	END IF;
END EXCEPTION;

--    SET DEBUG FILE TO '/INFORMIXDUMP/sp_depura_sd_movhis.out';
--    TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

SET LOCK MODE TO WAIT 3;
SET ISOLATION COMMITTED READ;

SELECT num_credito
  INTO vNumCredAux
  FROM "informix".sd_param_movhis_dep
 where proceso = 1;

 IF vNumCredAux IS NULL THEN 
   LET vNumCredAux = ""; 
END IF;

FOREACH WITH HOLD
	
	SELECT TRIM(num_solicitud), TRIM(status_solicitud)
	  INTO vNumCred, cStatus
	  FROM bdisolic:"informix".ss_solicitudes
	 WHERE empresa     = '001' 
	   AND num_solicitud > vNumCredAux
	   AND status_solicitud IN ('CN','AN','PC')
       AND fecha_insert < mdy(01,01,2013)
  ORDER BY num_solicitud ASC
  
	BEGIN WORK;
	
	      DELETE FROM bdisolic:"informix".ss_os_errores 
		        WHERE num_solicitud = vNumCred 
				  AND fechaproceso < mdy(01,01,2013);
		  
		  DELETE FROM bdisolic:"informix".ss_osclientesupervisar 
		        WHERE empresa = '001' 
				  AND num_solicitud = vNumCred 
		          AND (clave IN ('A','D','R') OR (clave = '' AND cStatus = 'CN'))
                  AND fecharespuesta < mdy(01,01,2013);
				  
		  DELETE FROM bdisolic:"informix".ss_solicitud_os 
				WHERE empresa = '001'
				  AND num_solicitud = vNumCred
				  AND (status IN ('A','D','R') OR (status = '' AND cStatus = 'CN')) 
				  AND fecha_respuesta < mdy(01,01,2013);
					
		  DELETE FROM bdisolic:"informix".ss_anexosol
			    WHERE empresa = '001'
				  AND num_solicitud = vNumCred
				  AND fecha_insert < mdy(01,01,2013);
				  
		  DELETE FROM bdisolic:"informix".ss_autorizacion_especial
			    WHERE empresa = '001'
				  AND num_solicitud = vNumCred;

          DELETE FROM bdisolic:"informix".ss_autorizacion
                WHERE empresa = '001'
                  AND num_solicitud = vNumCred;
	
		  DELETE FROM bdisolic:"informix".ss_solicitudes
	            WHERE empresa     = '001' 
				  AND num_solicitud = vNumCred
				  AND status_solicitud IN ('CN','AN','PC')
		          AND fecha_insert < mdy(01,01,2013);
	
		  UPDATE "informix".sd_param_movhis_dep SET num_credito = vNumCred WHERE proceso = 1;
	
	COMMIT WORK;

END FOREACH;

RETURN cCodRet;

END
END PROCEDURE;