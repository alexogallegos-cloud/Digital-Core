CREATE PROCEDURE "informix".sp_actualizavigenciaopt_rst()
	returning char(5);

	-- ==================================================== 
	--  Description: De Procedure que revisa la vigencia de 
	--  las claves y cambia su estado a "Vencido" en caso   
	--  de que asÃ­ sea.									   
	--  													
	--  Author: Mariano Enciso                              
	--  Date: Nov 26, 2020					   			   
	-- ====================================================

	-- Posibles estados de las Claves de Retiro
	-- P: Por Cobrar
	-- V: Vencido
	-- X: Cancelado
	-- R: Rechazado
	-- C: Cobrado

	-- DefiniciÃ³n de variables
	
	DEFINE vFolio BIGINT;
	DEFINE vFechaVigencia DATETIME YEAR TO FRACTION(3);
	DEFINE vCodRet char(5);

	--SET DEBUG FILE TO "/informix/c94796696/sp_actualizavigenciaopt_rst.out";
    --TRACE ON;

	-- InicializaciÃ³n de variables
	LET vCodRet = '00000';
	LET vFolio = 0; 
	LET vFechaVigencia = CURRENT;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- Ciclo que recorre cada uno de los registros "Por Cobrar" de la tabla
	FOREACH 
		SELECT cr_id, cr_vigencia_fecha INTO vFolio, vFechaVigencia FROM informix.claves_retiro WHERE cr_status = 'P'

		-- Se verifica si la vigencia  es igual o menor a la fecha actual
		IF vFechaVigencia <= CURRENT THEN

			-- Se marca como "Vencido" al registro y se actualiza el campo de ultima modificacion con la fecha actual
			UPDATE informix.claves_retiro
			SET cr_status = 'V', cr_canal_final = 'Informix',
			cr_ultima_mod_fecha = CURRENT
			WHERE cr_id = vFolio;

		END IF;

	END FOREACH;

	RETURN vCodRet;

END PROCEDURE;