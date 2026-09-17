CREATE PROCEDURE "informix".sp_inicia_session_bpi (pEmpresa char(3), pUsuario char(50), pPass char(50),pIp char(15))
   returning char(5), char (20), char(26), char(26), char(26), char(26), smallint, integer, char(19),DATETIME YEAR TO SECOND, VARCHAR(11);

   --	Modifico: Manuel Ramos Figueroa
   --	Descripción: Se modifica para en caso login no exitoso retornar el número de cliente y su status para bloquear al usuario 
   --				después de haber realizado 3 intentos fallidos.
   --	Fecha: 2011-11-18
   
    DEFINE cCod_ret char(5);
    DEFINE iSql_err integer ;
    DEFINE cNumCliente char (20);
    DEFINE sIdStatus smallint ;
    DEFINE cNombre1, cNombre2, cApellPaterno, cApellMaterno char (26);
    DEFINE iIdStatusToken integer;
    DEFINE dFecPrimAcceso date;
    DEFINE dFecUltAcceso char(19);
    DEFINE dFecha  DATETIME YEAR TO SECOND;
    DEFINE vIdUsuario VARCHAR(11);
	DEFINE cPass CHAR(50);

    LET cCod_ret  = "000";
    LET cNumCliente  = '';
    LET sIdStatus = 0;
    LET cNombre1 = '';
    LET cNombre2  = '';
    LET cApellPaterno  = '';
    LET cApellMaterno  = '';
    LET iIdStatusToken = 0;
    LET dFecUltAcceso = '';
    LET dFecha=null;
    LET vIdUsuario = '';
	LET cPass = '';

	--SET DEBUG FILE TO "sp_inicia_session_bpi.out";
	--TRACE ON;
	
    Set isolation to dirty read;

  BEGIN

   ON EXCEPTION SET iSql_err
      IF iSql_err <> 0 THEN
            LET cCod_ret = iSql_err;
            RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, iIdStatusToken, dFecUltAcceso,dFecha,vIdUsuario;
      END IF ;
   END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
        SELECT usu.numcte, usu.id_status, usu.fec_primer_acceso,
			CASE WHEN usu.f_ultimo_acceso IS NULL THEN substring (current::varchar(23) from 1 for 19)
			ELSE substring (usu.f_ultimo_acceso::varchar(23)from 1 for 19)
			END f_ultimo_acceso, usu.pass, tk.id_status_token
		INTO cNumCliente, sIdStatus, dFecPrimAcceso, dFecUltAcceso, cPass, iIdStatusToken
		FROM bdinteg:"informix".si_bpiusuarios usu
		LEFT JOIN bdinteg:"informix".si_bpitoken tk ON tk.num_cliente = usu.numcte AND tk.empresa = pEmpresa
		WHERE usu.empresa = pEmpresa AND usu.usuario = pUsuario;
		
		IF NVL(cNumCliente,'') != '' AND TRIM(cPass) == TRIM(pPass) THEN

				SET LOCK MODE TO WAIT 3;
                SELECT si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno
                INTO cNombre1, cNombre2, cApellPaterno, cApellMaterno
                FROM bdinteg:"informix".si_cliente si WHERE si.numcte = cNumCliente;
                            
                IF sIdStatus = '95' or sIdStatus = '10' THEN
                    LET cCod_ret = '000';  -- Usuario inactivo
                    RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, iIdStatusToken, dFecUltAcceso,dFecha,vIdUsuario;
                END IF;

                --Actualiza Ultimo Acceso en si_bpi
                IF sIdStatus = 30 THEN
						SET LOCK MODE TO WAIT 3;
                        UPDATE bdinteg:"informix".si_bpiusuarios SET f_ultimo_acceso = CURRENT  WHERE numcte = cNumCliente;
                        --Actualiza su primer acceso si es la primera vez que ingresa
                        IF dFecPrimAcceso IS NULL THEN
							SET LOCK MODE TO WAIT 3;
                            UPDATE bdinteg:"informix".si_bpiusuarios SET fec_primer_acceso = CURRENT  WHERE numcte = cNumCliente;
                        END IF;
                    --OBTIEN DATOS DEL LOGIN *************************************************************************************
                        SET LOCK MODE TO WAIT 3;
						SELECT id_usuario,current 
                        INTO vIdUsuario,dFecha 
                        FROM bdibpi:"informix".bpi_usuario 
                        WHERE numcliente = cNumCliente 
                        AND st_portal = 'activo';
                --ACTUALIZA ULTIMO ACCESO en bpi_usuario
                        IF NVL(vIdUsuario, '') <> '' THEN
                                SET LOCK MODE TO WAIT 3;
								UPDATE bdibpi:"informix".bpi_usuario SET f_ultimo_acceso = TODAY WHERE numcliente = cNumCliente AND st_portal = 'activo';
                                --GRABA EN BITACORA CON CODIGO DE OPERACION INICIO DE SESSION == '1000'
                                INSERT INTO bdinteg:"informix".si_bpibitacora(fecha_oper, id_operacion, sucursal, id_usuario, ipusuario, fecha_aplic, 
                                        cuenta_origen, destino, monto_oper, sec_transaccion, cgenerico1, cgenerico2, cgenerico3, cgenerico4) 
                                        VALUES (CURRENT, '1000', '5003', vIdUsuario, pIp, CURRENT, 
                                                '', '', 0.00, '1000', '', '', '', '');
                                LET cCod_ret = '000';  -- Sesion iniciada
                        ELSE
                                LET cCod_ret = '001';  
                        END IF;
                END IF;	
        ELSE
				SET LOCK MODE TO WAIT 3;
				SELECT numcte, id_status INTO cNumCliente, sIdStatus FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario;
                LET cCod_ret = '002';  -- Usuario y/o Contraseña incorrecta
        END IF ;

   RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, iIdStatusToken, dFecUltAcceso,dFecha,vIdUsuario;

END
END PROCEDURE;