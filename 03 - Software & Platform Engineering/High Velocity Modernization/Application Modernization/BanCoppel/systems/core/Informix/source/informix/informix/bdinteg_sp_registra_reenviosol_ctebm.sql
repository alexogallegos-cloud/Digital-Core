CREATE PROCEDURE "informix".sp_registra_reenviosol_ctebm(pNumCliente CHAR(9),pNumCelular CHAR(15), pIdOper CHAR(4), pTipo CHAR (3), pFolio CHAR (40),pCorreo CHAR(70))
RETURNING CHAR(5);
	
	--***************************************************************************
	-- FUNCIONALIDAD: Registra el reenvìo de solicitud de banca móvil
	-- Autor: Francisco Rodrìguez
	-- Solicito: José de Jesús Nevarez
	-- Fecha: 13/09/2011
	--***************************************************************************
	
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  	 	CHAR(5);
	DEFINE vSqlErr   	 	INTEGER;
	DEFINE vTexto	 		VARCHAR(255);
	DEFINE vRegAfectados 	SMALLINT;
	DEFINE vFolioContrato 	CHAR (12);
	DEFINE dFecha			DATETIME YEAR TO FRACTION(3);
	DEFINE iMaxSession       INTEGER;

	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	LET vRegAfectados = 0;
	LET vFolioContrato = '';
	LET dFecha 	 =  CURRENT;
	LET iMaxSession = 0;

	
	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
	            RETURN vsCodRet;
	      END IF;
		END EXCEPTION;
		
		 --SET DEBUG FILE TO "/tmp/reenviabm.out";
		 --TRACE ON;
		
		
		IF (pNumCliente <> '' AND pNumCliente IS NOT NULL) THEN
		
		
			SET LOCK MODE TO WAIT 3;
			SELECT descripcion INTO vTexto FROM bdibpi:"informix".tkn_parametros WHERE id_param=43;
			SELECT folio_contrato INTO vFolioContrato FROM bdinteg:"informix".si_bm_usuarios WHERE numcte = pNumCliente;
		
			IF EXISTS(Select numcte from bdinteg:"informix".si_bm_envsolmsn WHERE numcte = pNumCliente)  THEN			
				UPDATE bdinteg:"informix".si_bm_envsolmsn SET
				numcel = pNumCelular, texto = vTexto, tipo = pTipo, folio_contrato = vFolioContrato
				WHERE numcte = pNumCliente;
			ELSE
				INSERT INTO bdinteg:"informix".si_bm_envsolmsn (numcte, numcel, texto, tipo, folio_contrato) 
				VALUES (pNumCliente, pNumCelular, vTexto, pTipo, vFolioContrato);
			END IF

			LET vRegAfectados = dbinfo("sqlca.sqlerrd2");

			IF vRegAfectados <= 0 THEN
				LET vsCodRet = '00002'; --No se inserto el registro de reenvío.
			
			ELSE --Inserta en bitácora.
				UPDATE bdinteg:"informix".si_bm_usuarios SET e_mail = TRIM(pCorreo) WHERE numcte = pNumCliente;
				
				SELECT MAX(id_session) INTO iMaxSession FROM bdinteg:"informix".si_bm_bitacora;
				
				IF (iMaxSession = 0 OR iMaxSession IS NULL) THEN
					LET iMaxSession = 1;
				ELSE
					LET iMaxSession = iMaxSession + 1;
				END IF;
				
				INSERT INTO bdinteg:"informix".si_bm_bitacora (id_session,fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
				VALUES (iMaxSession,dFecha,pNumCliente,'0',pIdOper,pNumCelular,NULL,pFolio);
			END IF;

		ELSE
			LET vsCodRet = '00001';  --Parametro cliente vacio.
		END IF;
	
		RETURN vsCodRet;
	
	END;
END PROCEDURE;