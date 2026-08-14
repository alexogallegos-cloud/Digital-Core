CREATE PROCEDURE "informix".sp_migrar_bpi_cat_operaciones(pId_oper CHAR(4),
											   pId_tran CHAR(8),
											   pDesc_oper CHAR(50),
											   pComision MONEY(14,2),
											   pActivo BOOLEAN,
											   pUltima_mod DATE,
											   pUsuario_ult_mod CHAR(8),
											   pH_ini_baja DATETIME HOUR TO SECOND,
											   pH_fin_baja DATETIME HOUR TO SECOND,
											   pFecha_baja CHAR(10),
											   pMsn_timeout VARCHAR(150),
											   pCve_pago CHAR(2))
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Insertar registros a la tabla bpi_cat_operaciones, como proceso de la migrasion de postgres a informix
	-- Solicitó: Diana Castellanos
	-- Fecha: 20/10/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR(5);
	DEFINE vId_oper CHAR(4);
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		
		SELECT id_oper INTO vId_oper FROM bpi_cat_operaciones WHERE id_oper = pId_oper;
		
		IF NVL(vId_oper, '') = '' THEN
			INSERT INTO bpi_cat_operaciones (id_oper, id_tran, desc_oper, comision, activo, ultima_mod, usuario_ult_mod, h_ini_baja, h_fin_baja, fecha_baja, msn_timeout, cve_pago) 
			VALUES (pId_oper, pId_tran, pDesc_oper, pComision, pActivo, pUltima_mod, pUsuario_ult_mod, pH_ini_baja, pH_fin_baja, pFecha_baja, pMsn_timeout, pCve_pago);
		ELSE
			LET vCod_ret = '00001'; -- Ya existe el registro
		END IF;
		RETURN vCod_ret;
	END;

END PROCEDURE;