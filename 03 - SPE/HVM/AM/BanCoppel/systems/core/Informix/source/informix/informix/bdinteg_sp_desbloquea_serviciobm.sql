CREATE PROCEDURE "informix".sp_desbloquea_serviciobm(pNumCliente VARCHAR(9),pStatus SMALLINT, pSucursal CHAR (4), pUsuario CHAR (8))
RETURNING CHAR (5);
	--*****************************************************************
	-- Objetivo: Desbloquea el servicio de banca movil del cliente.
	-- Autor: Francisco Rodrìguez
	-- Solicito: José de Jesús Nevarez
	-- Fecha: 13/09/2011
	--------------------------------------------------------------------
	-- Se agrega el reinicio de intentos de bloqueo
	-- Bibiana Gaxiola Verdugo.
	-- 21/01/2013
	--******************************************************************
	DEFINE sql_err int;
	DEFINE vCod_ret   CHAR (5);
	DEFINE vStatusAnt SMALLINT;
	DEFINE vStatusNvo SMALLINT;
	DEFINE vNumCel    CHAR (15);
	DEFINE vIntentos CHAR (3);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		--SET DEBUG FILE TO "/home/informix/bibiana/desbloqueabm.out";
		--TRACE ON;
		
		LET vCod_ret = '00000';
		LET vNumCel = ''; 
		LET vStatusAnt = 0;
		LET vStatusNvo = 0;
		LET vIntentos = '';
		
		SET LOCK MODE TO WAIT 3;
		
		SELECT id_status, numcel, numintacce INTO vStatusAnt, vNumCel, vIntentos FROM bdinteg:"informix".si_bm_usuarios WHERE numcte= pNumCliente;
		
		IF (vStatusAnt = '30') THEN
			
			LET vStatusNvo = '30';
			LET vIntentos = '0';
			
			UPDATE bdinteg:"informix".si_bm_usuarios SET numintacce = vIntentos WHERE numcte= pNumCliente;
			
			INSERT INTO bdinteg:"informix".si_bm_camestcte (numcte, id_statant, id_statact, numcel, fecha_mod, suc_mod, user_mod)
			VALUES (pNumCliente,vStatusAnt,vStatusNvo,vNumCel,current,pSucursal,pUsuario);
		ELSE
			LET vCod_ret = '00001'; -- Status seleccionado incorrecto.
		END IF;

		RETURN vCod_ret;
	END;
END PROCEDURE;