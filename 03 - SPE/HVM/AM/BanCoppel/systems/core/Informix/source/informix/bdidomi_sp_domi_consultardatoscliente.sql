CREATE PROCEDURE "informix".sp_domi_consultardatoscliente(pNumcte CHAR(20), p_sUserInsert CHAR(8))
	RETURNING 	CHAR(5)   AS cod_ret,  	  -- Codigo de retorno
				CHAR(20)  AS NumCliente,  -- Numero de cliente
				CHAR(200) AS Nombre, 	  -- Nombre completo
				CHAR(18)  AS RFC, 		  -- RFC del cliente
				CHAR(60)  AS RazonSocial, -- Razon Social
				CHAR(13)  AS NumCelular,  -- Numero de telefono celular
				CHAR(100) AS Correo; 	  -- Correo electronico

	---- DECLARACION DE VARIABLES ----
	DEFINE  cSqlerr					INTEGER;
	DEFINE 	iExiste					INTEGER;
	DEFINE  cNumCte					CHAR(20);
	DEFINE  cNombreCte     			CHAR(200);
	DEFINE  cRFC     				CHAR(18);
	DEFINE  cRazon_social			CHAR(60);
	DEFINE  cNumTelefono			CHAR(13);
	DEFINE  cCorreoElect			CHAR(100);
	DEFINE  cCodret     			CHAR(5);
	DEFINE  cCodret2     			CHAR(5);
	DEFINE  cMensajeRespuesta     	CHAR(100);

	---- VALORES INICIALES ----
	LET cSqlerr 		= 0;
	LET iExiste			= 0;
	LET cNumCte			= '';
	LET cNombreCte 		= '';
	LET cRFC 			= '';
	LET cRazon_social	= '';
	LET cNumTelefono	= '';
	LET cCorreoElect	= '';
	LET cCodret 		= '00000';

    --SET DEBUG FILE TO "/tmp/sp_domi_consultardatoscliente.out";
	--TRACE ON;

	BEGIN
		------  Control de Errores no Controlados
		ON EXCEPTION SET cSqlerr
			IF cSqlerr <> 0 THEN
				Let cCodret = cSqlerr;

				--Obtenemos los datos del error ocurrido.
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;

				--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_consultardatoscliente', TRIM(pNumcte), p_sUserInsert, CURRENT);

				RETURN cCodret,cNumCte,cNombreCte,cRFC,cRazon_social,cNumTelefono,cCorreoElect;
			END IF;
		END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		IF pNumcte = '' OR p_sUserInsert = '' THEN
			-- Parametros de entrada estan en blanco.
			LET cCodret = '99972';

			--Obtenemos los datos del error ocurrido.
			EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;

			--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
			INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
			VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_consultardatoscliente', TRIM(pNumcte) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);

			RETURN cCodret,cNumCte,cNombreCte,cRFC,cRazon_social,cNumTelefono,cCorreoElect;
		ELSE
			SELECT numcte, TRIM(nombre1)||' ' || TRIM(nombre2 )||' ' || TRIM(apell_paterno) ||' ' || TRIM(apell_materno),rfc,razon_social
			INTO cNumCte,cNombreCte,cRFC,cRazon_social
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumcte
			AND empresa = '001';

			SELECT FIRST 1 telefono
			INTO cNumTelefono
			FROM bdinteg:"informix".si_telefonos_actual
			WHERE numcte= pNumcte
			AND status_tel = 'A'
			AND tipo_tel = 2
			AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = pNumcte AND status_tel = 'A' AND tipo_tel = 2)
			AND empresa = '001';

			SELECT FIRST 1 correo_elec
			INTO cCorreoElect
			FROM bdinteg:"informix".si_correos
			WHERE numcte= pNumcte
			AND tipo_correo = 1
			AND status_correo = 'A'
			AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE numcte = pNumcte AND status_correo = 'A' AND tipo_correo = 1)
			AND empresa = '001';

			IF cNumCte IS NULL OR cNumCte = '' OR cCorreoElect IS NULL OR cCorreoElect = '' OR cNumTelefono IS NULL OR cNumTelefono = '' THEN
				-- No existen todos los registros en los parametros de retorno
				LET cCodret = '99973';

				--Obtenemos los datos del error ocurrido.
				EXECUTE PROCEDURE bdidomi:"informix".sp_obtenermensajeerror(cCodret) INTO cCodret2, cMensajeRespuesta;

				--Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
				INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
				VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCodret, '', 'sp_domi_consultardatoscliente', TRIM(pNumcte) || '-' || TRIM(cMensajeRespuesta), p_sUserInsert, CURRENT);

				RETURN cCodret,cNumCte,cNombreCte,cRFC,cRazon_social,cNumTelefono,cCorreoElect;
			END IF;

			RETURN cCodret,cNumCte,cNombreCte,cRFC,cRazon_social,cNumTelefono,cCorreoElect;

		END IF

	END;
END PROCEDURE;