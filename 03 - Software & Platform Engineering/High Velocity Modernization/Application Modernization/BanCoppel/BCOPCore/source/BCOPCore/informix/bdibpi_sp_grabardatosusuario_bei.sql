CREATE PROCEDURE "informix".sp_grabardatosusuario_bei(pNumCliente VARCHAR(9),
									   pNumTel VARCHAR(15),
									   pCiaCel INT,
									   pEmail VARCHAR(80))
RETURNING CHAR (5);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Registra datos del usuario
	-- Fecha: 22/07/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE vNumCliente VARCHAR(9);
--variables para registro en nuevas tablas
    DEFINE v_Empresa     CHAR(3); 
    DEFINE v_TipoTel     SMALLINT;
    DEFINE v_Extension   CHAR(5); 
    DEFINE v_Canal       SMALLINT;
    DEFINE v_UserInsert  CHAR(8); 
    DEFINE v_codret1      CHAR(5);
    DEFINE v_codret2      CHAR(5);
    DEFINE v_TipoCorreo  SMALLINT;

	
	LET cCod_ret = '00000';
	LET vNumCliente = '';
	
	LET v_Empresa    = '001';
    LET v_TipoTel    = 2; 
    LET v_Extension  = ''; 
    LET v_Canal      = 3; 
    LET v_UserInsert = 'transBPI';
    LET v_codret1 = '00000';
    LET v_codret2 = '00000';
    LET v_TipoCorreo    = 1; 
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		SELECT numcliente INTO vNumCliente FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		IF NVL(vNumCliente, '') <> '' THEN
			--SET LOCK MODE TO WAIT ;
			--UPDATE bdibpi:"informix".bpi_usuariopm SET tel_celular = pNumTel, cia_cel = pCiaCel, e_mail = pEmail WHERE numcliente = pNumCliente AND st_portal = 'activo';
			IF (pNumTel <> '') THEN
				IF ((SELECT COUNT (telefono) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumCliente AND telefono = pNumTel
						AND tipo_tel = v_TipoTel AND carrier = pCiaCel) = 0) THEN
                EXECUTE PROCEDURE bdinteg:sp_registra_telefonos(v_Empresa, pNumCliente, pNumTel, v_TipoTel,
                                                     v_Extension, pCiaCel, v_Canal,v_UserInsert)
                             INTO v_codret1;
				END IF;
            END IF;
            IF (pEmail <> '') THEN
				IF ((SELECT COUNT (correo_elec) FROM bdinteg:"informix".si_correos WHERE numcte = pNumCliente AND correo_elec = pEmail 
						AND status_correo = 'A') =0) THEN 
                EXECUTE PROCEDURE bdinteg:sp_registra_correos(v_Empresa,pNumCliente,pEmail,v_TipoCorreo,v_Canal,v_UserInsert)
                            INTO v_codret2;
				END IF;			
            END IF;
		
		ELSE
			LET cCod_ret = '00001'; -- Numero de cliente ya registrado
		END IF;
		
		RETURN cCod_ret;
		
	END;

END PROCEDURE;