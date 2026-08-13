CREATE PROCEDURE "informix".sp_valida_servicio_ctebm(pNumCliente VARCHAR(9))
RETURNING CHAR (5), VARCHAR(15), SMALLINT;
	--*********************************************************************************************************************************
	-- Objetivo: Valida que el cliente disponga del servicio de banca móvil y obtiene los datos numero celular y estatus del sevicio. 
	-- Autor: Francisco Rodrìguez
	-- Solicito: José de Jesús Nevarez
	-- Fecha: 13/09/2011
	--------------------------------------------------------------------------------------------
	-- Se agrega la validación de los intentos de ingreso
	-- Bibiana Gaxiola Verdugo.
	-- 21/01/2013
	--**********************************************************************************************************************************
	DEFINE sql_err INT;
	DEFINE vCod_ret CHAR (5);
	DEFINE vNumCel VARCHAR (15);
	DEFINE vStatus SMALLINT;
	DEFINE vIntentos CHAR(3);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vNumCel, vStatus;
		  END IF ;
		END EXCEPTION ;
		
		--SET DEBUG FILE TO "/home/informix/bibiana/validabm.out";
		--TRACE ON;
		
		LET vCod_ret = '00000';
		LET vNumCel = '';
		LET vStatus= 0;
		LET vIntentos = '';
		
		SET LOCK MODE TO WAIT 3;
		
		IF  EXISTS (SELECT {+index (bdinteg:"informix"si_bm_usuarios "informix".idx_ctebmusuario)} numcte 
					FROM bdinteg:"informix".si_bm_usuarios WHERE numcte= pNumCliente) THEN
			SELECT numcel, id_status, numintacce INTO vNumCel,vStatus,vIntentos FROM bdinteg:"informix".si_bm_usuarios WHERE numcte= pNumCliente;
			LET vNumCel = TRIM(vNumCel);
			
			IF (vStatus = '30' AND vIntentos = '3') THEN
				LET vStatus = '50';
			END IF;
		ELSE
			LET vCod_ret = '00001'; -- Cliente no tiene el servicio de banca móvil.
		END IF;
		
		RETURN vCod_ret, vNumCel, vStatus;
	END;
END PROCEDURE;