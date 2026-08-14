CREATE PROCEDURE "informix".sp_obteneremailusuario(pNumCliente VARCHAR(9))
RETURNING CHAR (5), CHAR(100);
	-- Creador: Javier CalderÃ³n
	-- Objetivo: Obtiene el correo electronico del usuario
	-- SolicitÃ³: Diana Castellanos
	-- Fecha: 17/11/2010
	
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vEmail VARCHAR(100);
    DEFINE vTipoCorreo      SMALLINT;
    DEFINE vStatusCorreo    CHAR(1);
	
	--SET DEBUG FILE TO '/tmp/sp_grabaremail.out';
    --TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vEmail;
		  END IF ;
		END EXCEPTION ;
		
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		LET vCod_ret = '00000';
		LET vEmail = '';
        LET vTipoCorreo = 0;
        LET vStatusCorreo = '';

        CALL bdinteg:sp_consulta_correos('001',pNumCliente,1,'0')
        RETURNING vCod_ret, vEmail, vTipoCorreo, vStatusCorreo;

        IF vCod_ret <> '000' THEN
        
           SELECT FIRST 1 correo_elec
			INTO vEmail
          FROM bdinteg:"informix".si_correos
         WHERE numcte = pNumCliente
           AND tipo_correo = 1
           AND status_correo = 'A';
			
			
        END IF;
		
        LET vCod_ret = '00000';
		IF vEmail = "" THEN            
			LET vCod_ret = '00001';
		END IF;

		
		RETURN vCod_ret, vEmail;
	END;
END PROCEDURE
DOCUMENT
'AUTOR.........: Edgar Alarcon Gonzalez',
'FECHA.........: 12-09-2016',
'MODIFICACIÃN..: Se amplia parametro de correo a 100 caracteres.',
'SOLICITA......: Alejandro Vazquez',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_actualizaraccesousuario(pNumCliente VARCHAR(9))
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Registra la fecha del ultimo acceso
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vNumCliente VARCHAR(9);
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;


        SET ISOLATION TO DIRTY READ;
		
		LET vCod_ret = '00000';
		
		SELECT numcliente INTO vNumCliente FROM bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		
		IF NVL(vNumCliente, '') <> '' THEN
			UPDATE bpi_usuario SET f_ultimo_acceso = TODAY WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELSE
			LET vCod_ret = '00001';
		END IF;
		
		RETURN vCod_ret;
		
	END;

END PROCEDURE;