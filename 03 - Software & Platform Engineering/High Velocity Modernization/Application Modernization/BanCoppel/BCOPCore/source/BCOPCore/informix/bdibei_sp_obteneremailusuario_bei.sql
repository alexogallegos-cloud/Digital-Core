CREATE PROCEDURE "informix".sp_obteneremailusuario_bei(pNumCliente VARCHAR(9), pUsuario INTEGER)
RETURNING CHAR (5), CHAR(100);

	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE vEmail VARCHAR(100);
	
	LET cCod_ret = '00000';
	LET vEmail = '';
	
--****************************************************************************************************
-- DESCRIPCION:  Obtiene el correo del usuario
-- AUTOR : Ismael / BanCoppel
-- FECHA : 29/08/2013
-- BD: bdibei
-- SOLICITO : BanCoppel.
-- LIBERADO A PRODUCCION: Mayo 2014
--***************************************************************************************************

	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, vEmail;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
        IF EXISTS( SELECT * FROM bdibei:"informix".bei_usuario as a, bdibei:"informix".bei_datos_usuario as b
                   WHERE a.id_usuario = pUsuario AND a.num_cliente = pNumCliente AND a.id_usuario = b.id_usuario ) THEN
             
             SELECT TRIM(NVL(e_mail,'')) INTO vEmail FROM bdibei:"informix".bei_datos_usuario
             WHERE id_usuario = pUsuario;
             
             IF vEmail = '' THEN
                LET cCod_ret = '00002';
             ELSE
                LET cCod_ret = '00000';
             END IF;
        ELSE
            LET cCod_ret = '00001';
        END IF;

		RETURN cCod_ret, vEmail;
	END;
	-- Creador: Ismael Hernández
	-- Objetivo: Obtiene el correo electronico del usuario EmpresaNet
	-- Fecha: 29/08/2013
END PROCEDURE;