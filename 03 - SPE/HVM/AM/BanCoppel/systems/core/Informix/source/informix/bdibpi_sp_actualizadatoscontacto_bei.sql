CREATE PROCEDURE "informix".sp_actualizadatoscontacto_bei(pNumCliente VARCHAR(9), 
										   pCel VARCHAR(15),
										   pCiaCel INT,
										   pEmail VARCHAR(80))
RETURNING CHAR (5);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Actualiza datos del usuario
	-- Fecha: 16/08/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
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
		
		--SET LOCK MODE TO WAIT 3;
		--UPDATE bdibpi:"informix".bpi_usuariopm SET tel_celular = pCel, cia_cel = pCiaCel, e_mail = pEmail WHERE numcliente = pNumCliente AND st_portal = 'activo';
				
		--inserta registro de teléfono
        IF (pCel <> '') THEN
					IF (SELECT count (telefono) from bdinteg:"informix".si_telefonos_actual where numcte = pNumCliente 
						and telefono = pCel and carrier = pCiaCel and tipo_tel = v_TipoTel) = 0 THEN
            EXECUTE PROCEDURE bdinteg:sp_registra_telefonos(v_Empresa, pNumCliente, pCel, v_TipoTel, v_Extension, pCiaCel, v_Canal,v_UserInsert)
                             INTO v_codret1;
			END IF;				 
        END IF;
		--inserta registro de correo
        IF (pEmail <> '') THEN
			IF (SELECT count (correo_elec) from bdinteg:"informix".si_correos where numcte = pNumCliente and correo_elec = pEmail and status_correo = 'A') = 0 THEN
            EXECUTE PROCEDURE bdinteg:sp_registra_correos(v_Empresa,pNumCliente,pEmail,v_TipoCorreo,v_Canal,v_UserInsert)
                            INTO v_codret2;
			END IF;				
        END IF;
		
		RETURN cCod_ret;
	END;
END PROCEDURE;