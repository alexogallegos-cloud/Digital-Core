CREATE PROCEDURE "informix".sp_busca_producto(pUsuario CHAR(8), pOpcion CHAR(1), pNumeroCliente CHAR(20), pNumeroTarjeta CHAR(20), pNumeroCuenta CHAR(20), pTelefonoCliente CHAR(20))
         RETURNING 	CHAR(5) AS codRet,  
					CHAR(6) AS numeroProducto,
					CHAR(60) AS nombreProducto, 
					CHAR(30) AS numeroCuenta, 
					CHAR(30) AS numeroTarjeta,
					INTEGER AS tipoProducto,
					CHAR(3) AS statusTarjeta;
		
	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
    
	DEFINE cNumeroProducto CHAR(6);
    DEFINE cNombreProducto CHAR(60);
    DEFINE cNumeroCuenta CHAR(30);      
    DEFINE cNumeroTarjeta CHAR(30);   
	DEFINE cStatusTarjeta CHAR(3);	

	DEFINE cNumeroCuentaInversion CHAR(30);	
	DEFINE cTelefonoTransfer CHAR(30); 
	DEFINE cClienteTransfer CHAR(30);	
	DEFINE iRecuperacion INTEGER;
    DEFINE cEmpresa CHAR(3);  
	DEFINE iTipoProducto INTEGER;
    
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
    
	LET cNumeroProducto = '';
    LET cNombreProducto = '';
	LET cNumeroCuenta='';
	LET cNumeroTarjeta='';
	
	LET cNumeroCuentaInversion='';
	LET cTelefonoTransfer='';
	LET cClienteTransfer='';
	LET iRecuperacion = 0;
	LET cEmpresa='001';
	LET iTipoProducto = 0;
	LET cStatusTarjeta = '';
   	
	 BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,iTipoProducto, cStatusTarjeta;
		END EXCEPTION;
                
		--SET DEBUG FILE TO '/tmp/mfinis/sp_busca_producto.out';
		--TRACE ON;
		
		IF  pOpcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,iTipoProducto, cStatusTarjeta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DELETE FROM "informix".productos_cliente_tmp WHERE usuario_consulta = pUsuario;
						
		
		IF pOpcion=1 THEN		--NÃºmero de Cliente
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_cred_cliente(pNumeroCliente, 0)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_cred_cliente_crd(pNumeroCliente, 0)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				
				FOREACH 
						EXECUTE PROCEDURE bdinteg:"informix".sp_busca_producto_deb_inver_cliente(pNumeroCliente, 0)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cNumeroCuentaInversion
						
						LET cStatusTarjeta = ''; --PRODUCTOS DE INVERSION SIN ESTATUS
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_deb_cheq_cliente(pNumeroCliente, 0)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_transfer_cliente(pNumeroCliente, 0)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cTelefonoTransfer,cClienteTransfer, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				
		ELIF pOpcion=2 THEN 	--NÃºmero de Tarjeta
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_cred_tarjeta_crd(pNumeroTarjeta, cEmpresa)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_cred_tarjeta(pNumeroTarjeta, cEmpresa)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_transfer_tarjeta(pNumeroTarjeta, 0)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cTelefonoTransfer,cClienteTransfer, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_deb_cheq_tarjeta(pNumeroTarjeta)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				FOREACH 
						EXECUTE PROCEDURE bdinteg:"informix".sp_busca_producto_deb_inver_tarjeta(pNumeroTarjeta, cEmpresa)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cNumeroCuentaInversion
						
						LET cStatusTarjeta = ''; --PRODUCTOS DE INVERSION SIN ESTATUS
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
		ELIF pOpcion=3 THEN 	--NÃºmero de Cuenta
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_cred_cuenta(pNumeroCuenta, 0, cEmpresa)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
		
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_cred_cuenta_crd(pNumeroCuenta, 0, cEmpresa)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_deb_cheq_cuenta(pNumeroCuenta, 0)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_transfer_cuenta(pNumeroCuenta, 0)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cTelefonoTransfer,cClienteTransfer, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
				
				FOREACH 
						EXECUTE PROCEDURE bdinteg:"informix".sp_busca_producto_deb_inver_cuenta(pNumeroCuenta, cEmpresa)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cNumeroCuentaInversion
						
						LET cStatusTarjeta = ''; --PRODUCTOS DE INVERSION SIN ESTATUS
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
		ELIF pOpcion=4 THEN 	--NÃºmero de TelÃ©fono MÃ³vil.
				FOREACH 
						EXECUTE PROCEDURE "informix".sp_busca_producto_transfer_telefono(pTelefonoCliente, 0)
						INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cTelefonoTransfer,cClienteTransfer, cStatusTarjeta
						
						INSERT INTO "informix".productos_cliente_tmp(usuario_consulta,numero_producto,nombre_producto,numero_cuenta,numero_tarjeta,status_tarjeta) VALUES(pUsuario,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,cStatusTarjeta);
			    END FOREACH;
		END IF;
		
		FOREACH 
			SELECT a.numero_producto, a.nombre_producto,a.numero_cuenta, a.numero_tarjeta, b.pky_tipo_producto, a.status_tarjeta
			INTO cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,iTipoProducto, cStatusTarjeta
			FROM "informix".productos_cliente_tmp a
			INNER JOIN "informix".acl_tipo_producto b ON a.numero_producto = b.producto 
			WHERE a.usuario_consulta = pUsuario
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,iTipoProducto,cStatusTarjeta  WITH RESUME;           
		END FOREACH;
				
		IF iRecuperacion = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cNumeroProducto, cNombreProducto,cNumeroCuenta,cNumeroTarjeta,iTipoProducto, cStatusTarjeta;
		END IF;
		
    END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 08/08/2018',
'PROYECTO: CAT ',
'FUNCIONALIDAD: Busqueda de Productos',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/01/2019',
'DESCRIPCION: Se modifica procedimiento para realizar el cambio de base de bdinteg a bdiaclaracion.',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 11/09/2019',
'DESCRIPCION: Se modifica procedimiento para retornar nuevo campo estatus de tarjeta.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_acl_busca_cliente_sv (p_cCuentaTarjeta CHAR(30))

     RETURNING
        CHAR(20) AS noCliente, 
        CHAR(30) AS primerApellido, 
        CHAR(30) AS segundoApellido, 
        CHAR(30) AS primerNombre,
        CHAR(30) AS segundoNombre;

	--definicion de variables--
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
	DEFINE resultado_primerNombre		CHAR(30);
	DEFINE resultado_segundoNombre		CHAR(30);
	DEFINE iSqlErr                      	INTEGER;

     -- InicializaciÃ³n de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET resultado_numeroCliente = '';
				LET resultado_primerApellido = '';
				LET resultado_segundoApellido = '';
				LET resultado_primerNombre = '';
				LET resultado_segundoNombre = '';
				RETURN resultado_numeroCliente, resultado_primerNombre,
					resultado_segundoNombre, resultado_primerApellido,
					resultado_segundoApellido;
			END IF;
		END EXCEPTION;

		
		SELECT cte.numcte, cte.nombre1,
			cte.nombre2, cte.apell_paterno,
			cte.apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, 
			resultado_segundoNombre, resultado_primerApellido,
			resultado_segundoApellido
		FROM bdinteg:si_credito_sv sv
		INNER JOIN bdinteg:si_cliente cte
			ON sv.numcte = cte.numcte
		WHERE sv.num_tdc = p_cCuentaTarjeta;

        IF ( resultado_numeroCliente IS NULL ) THEN           
			SELECT cte.numcte, cte.nombre1,
				cte.nombre2, cte.apell_paterno,
				cte.apell_materno
			INTO resultado_numeroCliente, resultado_primerNombre, 
				resultado_segundoNombre, resultado_primerApellido,
				resultado_segundoApellido
			FROM bdinteg:si_credito_sv sv
			INNER JOIN bdinteg:si_cliente cte
				ON sv.numcte = cte.numcte
			WHERE sv.num_cuenta_clabe=p_cCuentaTarjeta;
        END IF;

        IF ( resultado_numeroCliente IS NULL ) THEN           
			EXECUTE PROCEDURE bdinteg:sp_buscarclientesportarjeta(p_cCuentaTarjeta)
			INTO resultado_numeroCliente, resultado_primerNombre, 
				resultado_segundoNombre, resultado_primerApellido,
				resultado_segundoApellido;
        END IF;

        IF ( resultado_numeroCliente IS NULL ) THEN           
			EXECUTE PROCEDURE bdinteg:sp_buscarclientesporcuenta(p_cCuentaTarjeta, 0)
			INTO resultado_numeroCliente, resultado_primerNombre, 
				resultado_segundoNombre, resultado_primerApellido,
				resultado_segundoApellido;
        END IF;

        RETURN resultado_numeroCliente, resultado_primerNombre,
			resultado_segundoNombre, resultado_primerApellido,
			resultado_segundoApellido;

	END
END PROCEDURE
DOCUMENT
'Busca el cliente por numero de tarjeta o cuenta, tomando en cuenta la tabla de SV';

CREATE PROCEDURE "informix".sp_acl_montototal_sv(pFoliosuc CHAR(30))

     RETURNING
        CHAR(4) AS code, 
        MONEY AS total;

	--definicion de variables--
	DEFINE returnCode 		CHAR(4);
	DEFINE returnTotal	    MONEY;
	DEFINE counter          INTEGER;
	DEFINE iSqlErr         	INTEGER;

     -- InicializaciÃ³n de las variables.
	LET returnCode = '0000';
	LET returnTotal = 0;
	LET counter = -1;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
--    SET DEBUG FILE TO '/tmp/sp_acl_montototal_sv.out';
--    TRACE ON;
	
	BEGIN

		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN returnCode, returnTotal;
			END IF;
		END EXCEPTION;

        SELECT SUM(COALESCE(monto, 0)), COUNT(folio_suc)
        INTO returnTotal, counter
        FROM bdiaclaracion:acl_movimiento
        WHERE folio_suc = pFoliosuc
        GROUP BY folio_suc;
        
        -- No existen movimientos para el folioSuc proporcionado.        
        IF COALESCE(counter, 0) = 0 THEN
            LET returnTotal = 0;
            LET returnCode = '0001';
        END IF;
        
        RETURN returnCode, returnTotal;
        
	END
END PROCEDURE
DOCUMENT
'Regresa la suma de los movimientos por FolioSuc';

CREATE PROCEDURE "informix".sp_acl_transacc_movs_origen (pky_origen INTEGER)
     RETURNING
		CHAR(6) AS cod,
		CHAR(4) AS transaccion;

	--definicion de variables--
	DEFINE countRows        INTEGER;
	DEFINE codRet           CHAR(6);
	DEFINE transaccionRet	CHAR(4);

     -- InicializaciÃ³n de las variables.
	LET countRows = 0;
    LET codRet = '';
    LET transaccionRet = '';

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

        SELECT '00000' AS cod, mov.transaccion
        FROM bdiaclaracion:acl_tipo_movimiento mov
        INNER JOIN bdiaclaracion:acl_origen_evento ori
            ON mov.fky_origen_evento = ori.pky_origen_evento
        WHERE ori.pky_origen_evento = pky_origen
            AND mov.activo = 1 AND ori.activo = 1
            AND mov.transaccion IS NOT NULL
            AND mov.transaccion <> 'MANU'
        INTO TEMP tmp_transacciones;

        SELECT COUNT(*)
        INTO countRows
        FROM tmp_transacciones;

		IF countRows = 0 THEN
			RETURN '000000', '0000';
        ELSE
            FOREACH
                SELECT DISTINCT cod, transaccion
                INTO codRet, transaccionRet
                FROM tmp_transacciones

               RETURN codRet, transaccionRet WITH RESUME;
            END FOREACH;
		END IF;
        DROP TABLE tmp_transacciones;
	END
END PROCEDURE
DOCUMENT
'Busca trasacciones activas relacionadas a un origen.';

CREATE PROCEDURE "informix".sp_acl_validarpreguntasiniciosesion(p_NumCte CHAR(20))
RETURNING  CHAR(5) as  codretorno, CHAR(30) as fecha_nacimiento, CHAR(40) as num_tarjeta, CHAR(40) as num_celular, CHAR(15) as edad, CHAR(54) as email, CHAR(40) as dominio;

    --definicion de variables--
    DEFINE cResultado_fecha_nacimiento       CHAR(10);
    DEFINE cResultado_tarjeta                CHAR(4);
	DEFINE cTarjeta                          CHAR(16);
    DEFINE cResultado_celular                CHAR(4);
    DEFINE cResultado_edad                   CHAR(2);
    DEFINE cResultado_mail                   CHAR(4);
    DEFINE cResultado_dominio                CHAR(20);
    DEFINE iSqlErr                          INTEGER;
	DEFINE cCodRet 							CHAR(5);
	DEFINE vFecha_nac						DATE;
	DEFINE vCelular							CHAR(13);
	DEFINE vCorreo							CHAR(100);


    -- Inicializacion de las variables.
	
    LET cResultado_fecha_nacimiento = '0';
    LET cResultado_tarjeta = '0';
	LET cTarjeta = NULL;
    LET cResultado_celular = '0';
    LET cResultado_edad = '0';
    LET cResultado_mail = '0';
    LET cResultado_dominio = '0';
	LET iSqlErr =0;
	LET cCodRet='00000';
	LET vFecha_nac = DATE(1);
	LET vCelular= '0';
	LET vCorreo = '0';
	

    SET ISOLATION TO DIRTY READ;

    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cResultado_fecha_nacimiento,cResultado_tarjeta,cResultado_celular,cResultado_edad,cResultado_mail,cResultado_dominio;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/resplogifx/traces/sp_acl_validarpreguntasiniciosesion.out';
		--TRACE ON;
		
		SELECT fecha_nac INTO vFecha_nac
		FROM bdinteg:si_ctepf
		WHERE numcte = p_NumCte;
		
		SELECT telefono INTO vCelular
		FROM bdinteg:si_telefonos_actual
		WHERE numcte = p_NumCte and tipo_tel = '2' and status_tel = 'A';
		
		SELECT correo_elec INTO vCorreo
		FROM bdinteg:si_correos
		WHERE numcte = p_NumCte  and status_correo = 'A' and tipo_correo='1';
		
		IF vFecha_nac IS NULL THEN
			LET cResultado_fecha_nacimiento = '0';
			LET cResultado_edad = '0';
		ELSE
			LET cResultado_fecha_nacimiento = TO_CHAR(vFecha_nac,'%m/%d/%Y');
			LET cResultado_edad = FLOOR((CAST (DATE(current) AS INTEGER) - CAST(DATE(vFecha_nac) AS INTEGER)) / 365.25);			
		END IF;
		
		IF vCelular IS NULL THEN
			LET cResultado_celular = '0';
		ELSE
			LET cResultado_celular = substr(vCelular,length(vCelular)-3,4);
		END IF;	
		
		IF vCorreo IS NULL THEN
			LET cResultado_mail = '0';
			LET cResultado_dominio = '0';
		ELSE
			LET cResultado_mail = substr(trim(vCorreo),1,4);
			LET cResultado_dominio = substr(trim(vCorreo), CHARINDEX('@',vCorreo));
		END IF;		
		
		
		FOREACH
			SELECT tc.numtarjeta
                  --FLOOR((CAST (DATE(current) AS INTEGER) - CAST(DATE(cte.fecha_nac) AS INTEGER)) / 365.25) as edad,
                  --substr(em.correo_elec,1,4) as correo_electronico, 
                  --substr(em.correo_elec, CHARINDEX('@',em.correo_elec)) as dominiocorreo
				INTO cTarjeta
			FROM intercard:tarjeta tc
                 --FROM bdinteg:si_cliente sc
                 --Left Outer Join bdinteg:si_direcciones_actual sd on sc.numcte = sd.numcte and tipo_dir = '1'
                 --Left Outer Join bdinteg:si_estados edo on edo.estado = sd.estado
                 --Left Outer Join bdinteg:si_telefonos st on st.numcte = sc.numcte and st.tipo_tel = '1' and st.status_tel = 'A'
                 --Left Outer Join bdinteg:si_telefonos_actual st1 on st1.numcte = sc.numcte and st1.tipo_tel = '2' and st1.status_tel = 'A'
                 --Left Outer Join bdinteg:si_catcalles ct on ct.numerocalle = sd.numerocalle
                 --Left Outer Join bdinteg:si_catzonas sz on sz.numerociudad = sd.numerociudad and sz.numerocolonia = sd.numerocolonia
                -- Left Outer Join bdinteg:si_correos em on em.numcte = sc.numcte and status_correo = 'A' and em.tipo_correo='1'
				-- Left Outer Join intercard:tarjeta tc on tc.numcliente = sc.numcte and codstatustarjeta = 'ACT'
                 --Left Outer Join bdinteg:si_ctepf cte on cte.numcte = sc.numcte
            where
				tc.numcliente = p_NumCte and tc.codstatustarjeta = 'ACT'
            
			IF cTarjeta is not null THEN
				LET cResultado_tarjeta = substr(cTarjeta,13,4);
			END IF;

           RETURN cCodRet,"5,9,17&#" ||cResultado_fecha_nacimiento,"3,10,11,19,23&#" ||cResultado_tarjeta,"1,7,13,15,20&#"||cResultado_celular,"4,8,18,21&#"|| cResultado_edad,"2,6,12,16,22&#" ||cResultado_mail,"14,24&#" || cResultado_dominio WITH RESUME;
        END FOREACH;

		FOREACH
			SELECT sv.num_tdc
			INTO cTarjeta
			FROM bdinteg:si_credito_sv sv
            where sv.numcte = p_NumCte
            
			IF cTarjeta is not null THEN
				LET cResultado_tarjeta = substr(cTarjeta,13,4);
			END IF;

           RETURN cCodRet,"5,9,17&#" ||cResultado_fecha_nacimiento,"3,10,11,19,23&#" ||cResultado_tarjeta,"1,7,13,15,20&#"||cResultado_celular,"4,8,18,21&#"|| cResultado_edad,"2,6,12,16,22&#" ||cResultado_mail,"14,24&#" || cResultado_dominio WITH RESUME;
        END FOREACH;

        IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
		    LET cResultado_tarjeta = '0';
			RETURN cCodRet,"5,9,17&#" ||cResultado_fecha_nacimiento,"3,10,11,19,23&#" ||cResultado_tarjeta,"1,7,13,15,20&#"||cResultado_celular,"4,8,18,21&#"|| cResultado_edad,"2,6,12,16,22&#" ||cResultado_mail,"14,24&#" || cResultado_dominio;
			--RETURN cCodRet,cResultado_fecha_nacimiento,cResultado_tarjeta,cResultado_celular,cResultado_edad,cResultado_mail,cResultado_dominio;
		END IF;
END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/03/2021', '30/07/2021',
'MODULO: CAT',
'FUNCIONALIDAD: RECUPERA LAS RESPUESTAS DE LAS PREGUNTAS DE INICIO DE SESION',
'DESCRIPCION: Se eliminan consultas a tablas de bdinteg ',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_aplica_credito_smartvista(pEmpresa CHAR(3), pFolioSuac CHAR(10), pDictamen CHAR(2), pCalculaInteres CHAR(1), pEmpleadoAut CHAR (8), pcodigo char(3))
RETURNING CHAR(3);

    DEFINE cCodRet              CHAR(5);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;

    DEFINE CnumCredito          CHAR(20);
    DEFINE CnumTarjeta          CHAR(20);
    DEFINE CmontoAcla           DECIMAL(18,2);
    DEFINE Csucursal            CHAR(4);
    DEFINE pfecha               DATE;
    DEFINE pfechaAux            DATE;
    DEFINE pfechaMov            DATE;
    DEFINE pfechaAcl            DATE;
    DEFINE pIntDev              DECIMAL(18,2);
    DEFINE pIntVig              DECIMAL(18,2);
    DEFINE pIntVenc             DECIMAL(18,2);
    DEFINE pIntCalc             DECIMAL(18,2);
    DEFINE pTasaInt             DECIMAL(18,2);
    DEFINE pIntBoni             DECIMAL(18,2);
    DEFINE pIvaBoni             DECIMAL(18,2);
    DEFINE DiasCalc             SMALLINT;
    DEFINE DiasPeri             SMALLINT;
    DEFINE pIntCap              DECIMAL(18,2);
    DEFINE pIvaCap              DECIMAL(18,2);
    DEFINE CCodret_c            CHAR(5);
    DEFINE CMensaje             CHAR(80);
    DEFINE CSecuencia           INTEGER;
    DEFINE Ctrannopro           CHAR(04);
    DEFINE Ctransinauto         CHAR(04);
    DEFINE Ctranpro             CHAR(04);
    DEFINE Ctranauto            CHAR(04);
    DEFINE Ccargo               SMALLINT;
    DEFINE ptranaplica          CHAR(04);
    DEFINE Ctrans_no_procede    CHAR(04);
    DEFINE Mcosto               DECIMAL(18,2);
    DEFINE Ifky_aclaracion      INTEGER;
    DEFINE Ifky_producto        INTEGER;
    DEFINE Ipky_tipo_movimiento INTEGER;
    DEFINE wBegin               CHAR(1);
    DEFINE Ipky_movimiento      INTEGER;
    DEFINE v_contador           SMALLINT;
    DEFINE pFolioSuacSUC        CHAR(16);
    DEFINE v_fecha_folio        CHAR(10);
	DEFINE CSecuencia_acl_mov   INTEGER;
	DEFINE fecha_captura		DATE;

    DEFINE v_numero_transaccion CHAR(04);
	DEFINE Es_Nacional			CHAR(1);
	DEFINE v_nombre_origen 		CHAR(50);
	DEFINE v_OrigenEvento		INTEGER;
	DEFINE v_NumTarjeta			CHAR(20);
	DEFINE v_FolioSuc			CHAR(20);

--> Variables para duplicidad de movimientos
	DEFINE v_fky_padre          INTEGER;
	DEFINE v_monto				DECIMAL(18,2);
	DEFINE v_montoprocedente    DECIMAL(18,2);
	DEFINE v_fky_tipo_evento    INTEGER;
	DEFINE v_duplicado          SMALLINT;

--> Variable para control de movimientos a afectar
	DEFINE v_tipo_fky_padre     INTEGER;

	DEFINE v_contador_1			INTEGER;
	DEFINE v_contador_2			INTEGER;
	DEFINE v_contador_total		INTEGER;

--> Variables tabla de control
	DEFINE max_control_afect_cred INTEGER;

--> Variable para almacenar nombre de un SP || JLM - 02/06/2022
	DEFINE v_nombre_sp            CHAR(20);
	DEFINE horaActual             DATETIME YEAR TO FRACTION(5);

	---VARIABLES TDC
	DEFINE v_tipo_producto   CHAR(4);
    DEFINE v_descripcion_pro VARCHAR(255);

	--VARIABLES PARA EL RQM 06 919 ABONO INMEDIATO
	DEFINE abono_inmediato				CHAR(2);
	DEFINE dfa						    CHAR(1);
	DEFINE devolucion					CHAR(1);
	DEFINE v_costoAcl 					MONEY;

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,CMensaje
      LET cCodRet = sql_err;
     -- ROLLBACK WORK;
      IF (wBegin = "S") THEN
        -- BEGIN WORK;
      END IF;

      RETURN cCodRet;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      --LET wBegin = "S";
      --ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

   --	SET DEBUG FILE TO "/resplogifx/Rey_David/extra/sp_aplicacredito.out";
   --TRACE ON;
   LET cCodRet      		= '000';
   LET pfechaMov    		= DATE(1);
   LET pfechaAcl    		= DATE(1);
   LET pfechaAux    		= DATE(1);
   LET pfecha       		= DATE(1);
   LET CnumCredito  		= '';
   LET CnumTarjeta  		= '';
   LET CmontoAcla   		= 0;
   LET Csucursal    		= '';
   LET pIntVig      		= 0;
   LET pIntVenc     		= 0;
   LET DiasPeri     		= 0;
   LET pIntBoni     		= 0;
   LET pIntCap      		= 0;
   LET pIvaCap      		= 0;
   LET CCodret_c    		= '';
   LET CMensaje     		= '';
   LET CSecuencia   		= 0;
   LET Ctrannopro   		= '';
   LET Ctransinauto 		= '';
   LET Ctranpro     		= '';
   LET Ctranauto    		= '';
   LET Ccargo       		= 0;
   LET ptranaplica  		= '0000';
   LET Ctrans_no_procede 	= '';
   LET Mcosto       		= 0;
   LET Ifky_aclaracion 		= 0;
   LET Ifky_producto 		= 0;
   LET Ipky_tipo_movimiento = 0;
   LET wBegin 				= 'N';
   LET Ipky_movimiento 		= 0;
   LET v_contador 			= 0;
   LET pFolioSuacSUC 		= '';
   LET v_fecha_folio 		= "";
   LET CSecuencia_acl_mov   = 0;
   LET fecha_captura		=DATE(1);

   LET v_numero_transaccion = '';
   LET Es_Nacional			= '';
   LET v_nombre_origen 		= '';
   LET v_OrigenEvento		= '';
   LET v_NumTarjeta			= '';
   LET v_FolioSuc			= '';

--> Variables para duplicidad de movimientos
   LET v_fky_padre       = 0;
   LET v_monto           = 0;
   LET v_montoprocedente = 0;
   LEt v_fky_tipo_evento = 0;
   LET v_duplicado 	     = 0;
   LET v_contador_1		 = 0;
   LET v_contador_2		 = 0;
   LET v_contador_total	 = 0;

--> Variable para control de movimientos a afectar
   LET v_tipo_fky_padre  = 0;
--> Variables tabla de control
   LET max_control_afect_cred = 0;

--> Variable para almacenar nombre de un SP || JLM - 02/06/2022
   LET v_nombre_sp       = '';
   LET horaActual        = NULL;
   LET v_tipo_producto   = NULL;
   LET v_descripcion_pro = '';

   --VARIABLES PARA EL RQM 06 919 ABONO INMEDIATO
	LET abono_inmediato					='';
	LET dfa						   	 	='';
	LET devolucion						='';
	LET v_costoAcl						= 0;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones
   -- 15/01/2013 sp_aplicaaclaracredito V6 	-> ModificaciÃ³n afectaciones lÃ³gica movimientos duplicados
   --										-> Flujos adicionales a seguir
   -- 										-> Validaciones para que no cargue movimientos sin previamente abonados
   -- 										-> ValidaciÃ³n de flujo AA para cargo de comisiÃ³n, iva de comisiÃ³n y si es el caso el monto previamente abonado.
   -- 										-> Agregar validaciÃ³n para cargos
-- 03/04/2013 sp_aplicaaclaracredito V7 	-> ModificaciÃ³n envÃ­o de num_empleado que autoriza las afectaciones Entrega III, CNBV

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar debug
  --  SET DEBUG FILE TO "/home/e10000263/sp_aplicaaclaracredito"||"_"||""||pFolioSuac||""||"_v13_"||""||pDictamen||".out";
    --SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_aplicaaclaracredito_usr"||pFolioSuac||pDictamen||"_35"||".out";
  --  TRACE ON;


   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   BEGIN WORK;


   -- APLICA VALIDACIÓ DE COPPEL TDC

		SELECT tp.producto, tp.descripcion INTO v_tipo_producto, v_descripcion_pro FROM bdiaclaracion:acl_aclaracion acl
		inner join bdiaclaracion:acl_producto p on acl.fky_producto = p.pky_producto
		inner join bdiaclaracion:acl_tipo_producto tp on p.fky_tipo_producto = tp.pky_tipo_producto
		where acl.folio_csuac = pFolioSuac;


		IF pFolioSuac IS NULL OR pFolioSuac='' THEN
			LET cCodRet='001';
			RETURN cCodRet;
		END IF;

-- 		  IF pNaturaleza IS NULL OR pNaturaleza='' THEN
-- 		     LET cCodRet='006';
-- 		     RETURN cCodRet;
-- 		  END IF;

		IF pDictamen IS NULL OR pDictamen='' THEN
			LET cCodRet='007';
			RETURN cCodRet;
		END IF;

		IF pCalculaInteres IS NULL OR pCalculaInteres='' THEN
			LET cCodRet='008';
			RETURN cCodRet;
		END IF;

			--SELECT valor INTO DiasCalc
			--FROM sd_param
			--WHERE empresa = pEmpresa
			--AND cod_param = "24"; -- Dias Para Calculo de Intereses

			--SELECT fecha_hoy
			--INTO pfecha
			--FROM bdicred:sd_fechas
			--WHERE empresa = pEmpresa;

		----SE INTEGRA VALIDACIÃN PARA EL RQM 06 919 ABONO INMEDIATO-----
		--Se obtiene banderas para validar si es un flujo de abono inmediato
		SELECT ev.acepta_dfa, ev.acepta_devolucion
		INTO dfa, devolucion
		FROM bdiaclaracion:acl_aclaracion acl
		INNER JOIN bdiaclaracion:acl_tipo_evento ev ON acl.fky_tipo_evento = ev.pky_tipo_evento
		WHERE acl.folio_csuac = pFolioSuac;

		--Valida que los campos de DFA o DevoluciÃ³n se encuentren encendidos
		IF (dfa = 1) THEN
			LET abono_inmediato = 1;
		ELIF (devolucion = 1) THEN
			LET abono_inmediato = 1;
		END IF; --fin de validaciÃ³n banderas DFA y DevoluciÃ³n

		-- APLICA VALIDACIÃN DE COPPEL TDC

		IF v_tipo_producto <> '6500' THEN

			IF (pDictamen = 'NP') THEN

---		---------------------------------------------- >> ValidaciÃ³n para creaciÃ³n de movimientos duplicados.
				SELECT fky_padre
				INTO v_fky_padre
				FROM bdiaclaracion:acl_movimiento
				WHERE duplicado = 1
				AND folio_csuac = pFolioSuac;

				IF (v_fky_padre IS NULL) THEN

				IF (pCalculaInteres='0') THEN
					FOREACH WITH hold
						-- >> Insertar movimientos duplicados.
						SELECT a.folio_csuac, a.monto, a.montoprocedente, b.trans_no_procede, a.fky_padre, a.fky_producto, a.fky_tipo_evento, a.fky_tipo_movimiento
						INTO
						pFolioSuac,          -- folio_csuac,  	   			--> Mismo que el padre -- ok
						v_monto,             -- monto, 						--> Mismo que el padre -- para afectaciÃ³n contable
						v_montoprocedente,   -- montoprocedente, 			--> Mismo que el padre -- Breviario cultural
						Ctrans_no_procede,   -- numero_transaccion, 		--> null -- Tran_no_procede para que haga la afectaciÃ³n con esa transacciÃ³n.
						Ipky_movimiento,     -- fky_padre,	 				--> pky del movimiento padre
						Ifky_producto,       -- fky_producto, 				--> Mismo que el padre
						v_fky_tipo_evento,   -- fky_tipo_evento, 			--> Mismo que el padre
						Ipky_tipo_movimiento -- fky_tipo_movimiento, 		--> Mismo que el padre
						FROM bdiaclaracion:acl_movimiento a, bdiaclaracion:acl_tipo_movimiento b
						WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
						AND a.folio_csuac = pFolioSuac
						AND a.cargo = 0
						AND a.exitoso = 1
						-- AND a.procede = 1
						AND a.fecha_afectacion IS NOT NULL
						AND a.duplicado = 0
					--	AND a.fky_tipo_movimiento <> 340 --> ValidaciÃ¿?Ã¿Â³n no duplicar intereses abonados

						SELECT MAX (secuencia)
						INTO CSecuencia_acl_mov
						FROM bdiaclaracion:acl_movimiento
						WHERE folio_csuac = pFolioSuac;

						SELECT duplicado
						INTO v_duplicado
						FROM bdiaclaracion:acl_movimiento a
						WHERE folio_csuac = pFolioSuac
						AND a.duplicado = 1
						AND monto = v_monto;

						IF (v_duplicado IS NULL) THEN

						INSERT INTO bdiaclaracion:acl_movimiento(
							pky_movimiento, calculado, cargo, cargo_ajuste, exitoso, fecha_afectacion, fecha_hora_e_global, fechahora, folio_csuac,
							folio_suc, identificador_adquiriente, iso_37, iso_41, monto, montoprocedente, duplicado, numero_transaccion,
							procede, referencia, referencia23, reversado, secuencia, fky_aclaracion, fky_padre, fky_producto,
							fky_solicitud_e_global, fky_tipo_evento, fky_tipo_movimiento, fky_tipo_catalogo_transaccion,
							ref_comercio, num_sucursal, recuperacion, montorecuperacion
						)
						VALUES (
						-- pky_movimiento                             calculado     cargo  	cargo_ajuste   exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia        referencia23             reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio                              num_sucursal , recuperacion, montorecuperacion
						bdiaclaracion:MOVIMIENTO_SEQ.nextval,     0,            1,        	null,		0,          null,                    null,                  current,                pFolioSuac,     null,             null,                         null,      null,      v_monto,  v_montoprocedente,  1,            Ctrans_no_procede,     1,          '',               '',                      0,            CSecuencia_acl_mov, null,              Ipky_movimiento, Ifky_producto,   null,                      v_fky_tipo_evento,  Ipky_tipo_movimiento,   null,                             null,                                     "9250", null, 0, 0);
						-- VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0, 1, 0, null, null, current, pFolioSuac, null, null, null, null, Mcosto, Mcosto, 0,Ctrans_no_procede, 1, '', '', 0, CSecuencia_acl_mov, null, Ipky_movimiento, Ifky_producto, null, 1, Ipky_tipo_movimiento, null, null, "9250");

						END IF;

					END FOREACH;

				END IF; -- Calculo de interes = 0


				SET ISOLATION TO DIRTY READ;
				IF (pCalculaInteres='1') THEN
							FOREACH WITH hold
						-- >> Insertar movimientos duplicados.
						SELECT a.folio_csuac, a.monto, a.montoprocedente, b.trans_no_procede, a.fky_padre, a.fky_producto, a.fky_tipo_evento, a.fky_tipo_movimiento

						INTO
						pFolioSuac,          -- folio_csuac,  	   			--> Mismo que el padre -- ok
						v_monto,             -- monto, 						--> Mismo que el padre -- para afectaciÃ¿?Ã¿Â³n contable
						v_montoprocedente,   -- montoprocedente, 			--> Mismo que el padre -- Breviario cultural
						Ctrans_no_procede,   -- numero_transaccion, 		--> null -- Tran_no_procede para que haga la afectaciÃ¿?Ã¿Â³n con esa transacciÃ¿?Ã¿Â³n.
						Ipky_movimiento,     -- fky_padre,	 				--> pky del movimiento padre
						Ifky_producto,       -- fky_producto, 				--> Mismo que el padre
						v_fky_tipo_evento,   -- fky_tipo_evento, 			--> Mismo que el padre
						Ipky_tipo_movimiento -- fky_tipo_movimiento, 		--> Mismo que el padre

						FROM bdiaclaracion:acl_movimiento a, bdiaclaracion:acl_tipo_movimiento b
						WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
						AND a.folio_csuac = pFolioSuac
						AND a.cargo = 0
						AND a.exitoso = 1
						-- AND a.procede = 1
						AND a.fecha_afectacion IS NOT NULL
						AND a.duplicado = 0
						--AND a.fky_tipo_movimiento <> 340 --> ValidaciÃ¿?Ã¿Â³n no duplicar intereses abonados

						SELECT MAX (secuencia)
						INTO CSecuencia_acl_mov
						FROM bdiaclaracion:acl_movimiento
						WHERE folio_csuac = pFolioSuac;

						SELECT duplicado
						INTO v_duplicado
						FROM bdiaclaracion:acl_movimiento a

						WHERE folio_csuac = pFolioSuac
						AND a.duplicado = 1
						AND monto = v_monto;

						IF (v_duplicado IS NULL) THEN

							INSERT INTO bdiaclaracion:acl_movimiento(
								pky_movimiento, calculado, cargo, cargo_ajuste, exitoso, fecha_afectacion, fecha_hora_e_global, fechahora, folio_csuac,
								folio_suc, identificador_adquiriente, iso_37, iso_41, monto, montoprocedente, duplicado, numero_transaccion,
								procede, referencia, referencia23, reversado, secuencia, fky_aclaracion, fky_padre, fky_producto,
								fky_solicitud_e_global, fky_tipo_evento, fky_tipo_movimiento, fky_tipo_catalogo_transaccion,
								ref_comercio, num_sucursal, recuperacion, montorecuperacion
							)						
							VALUES (
							-- pky_movimiento                         calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion     fecha_hora_e_global     fechahora     folio_csuac     folio_suc     identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia        referencia23             reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio     num_sucursal
							bdiaclaracion:MOVIMIENTO_SEQ.nextval,     0,            1,        null,			0,          null,                null,                   current,      pFolioSuac,     null,         null,                         null,      null,      v_monto,  v_montoprocedente,  1,            Ctrans_no_procede,     1,          '',               '',                      0,            CSecuencia_acl_mov, null,              Ipky_movimiento, Ifky_producto,   null,                      v_fky_tipo_evento,  Ipky_tipo_movimiento,   null,                             null,            "9250", null,0,0);

						END IF;

					END FOREACH;
				END IF; -- Calculo de interes 1

				END IF;

				--------- >> Determina si el movimiento es Nacional o Internacional
				SET ISOLATION TO DIRTY READ;
				SELECT tipo_movimiento INTO Es_Nacional
				FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = pFolioSuac;
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional ='N') THEN --Deshabilitar cuando se utilice completamente el campo tipo_movimiento de acl_aclaracion
					SELECT te.fky_origen_evento, p.numero_tarjeta
						INTO v_OrigenEvento, v_NumTarjeta
						FROM bdiaclaracion:acl_aclaracion acl
						INNER JOIN bdiaclaracion:acl_tipo_evento te on te.pky_tipo_evento = acl.fky_tipo_evento
						INNER JOIN bdiaclaracion:acl_producto p on p.pky_producto = acl.fky_producto
						WHERE acl.folio_csuac = pFolioSuac;

					SELECT LIMIT 1 SUBSTR(bdiaclaracion:acl_movimiento.folio_suc,2)
						INTO v_FolioSuc
						FROM bdiaclaracion:acl_movimiento
						WHERE bdiaclaracion:acl_movimiento.folio_csuac=pFolioSuac;

					SELECT nombre INTO v_nombre_origen
						FROM bdiaclaracion:acl_origen_evento WHERE pky_origen_evento = v_OrigenEvento;

					--IF v_OrigenEvento = '2' or v_OrigenEvento = '3' or v_OrigenEvento = '6' or v_OrigenEvento = '7' Then
					IF v_nombre_origen = 'POS' or v_nombre_origen = 'ATMS' Then
						LET Es_Nacional = 'V';
					END IF;
				END IF;

				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
					LET Es_Nacional = 'V';
				END IF;

				-------------- >> Inserta movimiento de comisiÃ³n por Aclaacion no procedente
				-- >> Se inactiva para evitar el cobro de comisiÃ³n e iva en crÃ©ditos 09/09/2011
				-- >> Se activa para realizar el cobro de comisiÃ³n e iva en crÃ©ditos 13/02/2011
			--SET ISOLATION TO DIRTY READ;
			SET ISOLATION TO DIRTY READ;
			SELECT d.trans_no_procede,
					nvl(e.costo,0), a.fky_aclaracion, a.fky_producto, d.pky_tipo_movimiento, a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c,
					bdiaclaracion:acl_tipo_movimiento d,
					bdiaclaracion:acl_costo_aclaracion e
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND c.pky_origen_evento = d.fky_origen_evento
				AND c.pky_origen_evento = e.fky_origen_evento
				AND a.fky_padre IS NULL
				AND d.fky_tipo_transaccion = 12
				-- AND a.cargo IS NOT NULL
				AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
				AND duplicado = 0
				AND folio_csuac = pFolioSuac;
				
				IF (Es_Nacional = 'F') THEN
					LET Mcosto = 0;
				END IF;
				
				IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisiÃ³n desde tabla acl_tipo_Evento
				/* Se elimina referencia a tabla acl_tipo_movimiento, transacciÃ³n de no procedencia es fija y se define una trasacciÃ³n fija para comisiones de
				no procedencia, esto para no tener que repetir por cada uno de los Eventos creados, ya que las comisiones ahora son por evento RQM 06 315*/
				SET ISOLATION TO DIRTY READ;
				SELECT '5212',
					nvl(b.costo,0),
					a.fky_aclaracion, a.fky_producto, '143', a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND a.fky_padre IS NULL
				AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
				AND duplicado = 0
				AND folio_csuac = pFolioSuac;

				IF (Es_Nacional = 'F') THEN
					LET Mcosto = 0;
				END IF;

				END IF;  -- comisiÃ³n desde acl_tipo_evento

				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (numero_transaccion)
				INTO v_numero_transaccion
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac
				AND numero_transaccion = Ctrans_no_procede;

				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (secuencia)
				INTO CSecuencia_acl_mov
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac;

				UPDATE bdiaclaracion:acl_movimiento -->> Valida que no existan movimientos como procedentes de forma erronea para que no sean cargados al cliente.
				SET procede = 0
				WHERE folio_csuac = pFolioSuac
				AND cargo = 0
				AND (exitoso = 0 OR exitoso IS NULL);

				IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la comisiÃ¿?Ã¿Â³n de crÃ¿?Ã¿Â©dito, para no duplicarla 24/04/2012
					If Mcosto = '0' Then
						INSERT INTO bdiaclaracion:acl_movimiento(
							pky_movimiento, calculado, cargo, cargo_ajuste, exitoso, fecha_afectacion, fecha_hora_e_global, fechahora, folio_csuac,
							folio_suc, identificador_adquiriente, iso_37, iso_41, monto, montoprocedente, duplicado, numero_transaccion,
							procede, referencia, referencia23, reversado, secuencia, fky_aclaracion, fky_padre, fky_producto,
							fky_solicitud_e_global, fky_tipo_evento, fky_tipo_movimiento, fky_tipo_catalogo_transaccion,
							ref_comercio, num_sucursal, recuperacion, montorecuperacion
						)
						-- pky_movimiento                            calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal  , recuperaciom, monto_recuperacion
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,        null,			0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     0,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250", null,0, 0);
					Else
						INSERT INTO bdiaclaracion:acl_movimiento(
							pky_movimiento, calculado, cargo, cargo_ajuste, exitoso, fecha_afectacion, fecha_hora_e_global, fechahora, folio_csuac,
							folio_suc, identificador_adquiriente, iso_37, iso_41, monto, montoprocedente, duplicado, numero_transaccion,
							procede, referencia, referencia23, reversado, secuencia, fky_aclaracion, fky_padre, fky_producto,
							fky_solicitud_e_global, fky_tipo_evento, fky_tipo_movimiento, fky_tipo_catalogo_transaccion,
							ref_comercio, num_sucursal, recuperacion, montorecuperacion
						)
						--cargo por ajuste
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0, 1, null, 0, null, null, current, pFolioSuac, null, null, null, null, Mcosto, Mcosto, 0,Ctrans_no_procede, 1, '', '', 0, CSecuencia_acl_mov, null, Ipky_movimiento, Ifky_producto, null, 1, Ipky_tipo_movimiento, null, null, "9250", null, 0, 0);
					End If;
				END IF;


			END IF;
---		----------*******************************************************************************************************************************************

-->		> Flujo de aclaraciones: Analizar, No Procede = Sin AfectaciÃ¿?Ã¿Â³n  --> Solo cobro de comision

			IF (pDictamen = 'CM') THEN
				SET ISOLATION TO DIRTY READ;

				--------- >> Determina si el movimiento es Nacional o Internacional
				SELECT tipo_movimiento INTO Es_Nacional
				FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = pFolioSuac;
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN --Deshabilitar cuando se utilice completamente el campo tipo_movimiento de acl_aclaracion
					SELECT te.fky_origen_evento, p.numero_tarjeta
						INTO v_OrigenEvento, v_NumTarjeta
						FROM bdiaclaracion:acl_aclaracion acl
						INNER JOIN bdiaclaracion:acl_tipo_evento te on te.pky_tipo_evento = acl.fky_tipo_evento
						INNER JOIN bdiaclaracion:acl_producto p on p.pky_producto = acl.fky_producto
						WHERE acl.folio_csuac = pFolioSuac;

					SELECT LIMIT 1 SUBSTR(bdiaclaracion:acl_movimiento.folio_suc,2)
						INTO v_FolioSuc
						FROM bdiaclaracion:acl_movimiento
						WHERE bdiaclaracion:acl_movimiento.folio_csuac=pFolioSuac;

					SELECT nombre INTO v_nombre_origen
						FROM bdiaclaracion:acl_origen_evento WHERE pky_origen_evento = v_OrigenEvento;

					--IF v_OrigenEvento = '2' or v_OrigenEvento = '3' or v_OrigenEvento = '6' or v_OrigenEvento = '7' Then
					IF v_nombre_origen = 'POS' or v_nombre_origen = 'ATMS' Then
						LET Es_Nacional = 'V';
					END IF;
				END IF;


				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
					LET Es_Nacional = 'V';
				END IF;
			SET ISOLATION TO DIRTY READ;
			SELECT d.trans_no_procede,
					nvl(e.costo,0), a.fky_aclaracion, a.fky_producto, d.pky_tipo_movimiento, a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c,
					bdiaclaracion:acl_tipo_movimiento d,
					bdiaclaracion:acl_costo_aclaracion e
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND c.pky_origen_evento = d.fky_origen_evento
				AND c.pky_origen_evento = e.fky_origen_evento
				AND a.fky_padre is null
				AND d.fky_tipo_transaccion = 12
				AND a.cargo is  null  -- is not null
				AND folio_csuac = pFolioSuac;

				IF (Es_Nacional = 'F') THEN
					LET Mcosto = 0;
				END IF;

				IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisiÃ³n desde tabla acl_tipo_Evento
				/* Se elimina referencia a tabla acl_tipo_movimiento, transacciÃ³n de no procedencia es fija y se define una trasacciÃ³n fija para comisiones de
				no procedencia, esto para no tener que repetir por cada uno de los Eventos creados, ya que las comisiones ahora son por evento RQM 06 315*/
				SELECT '5212',
					nvl(b.costo,0),
					a.fky_aclaracion, a.fky_producto, '143', a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND a.fky_padre IS NULL
				AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
				AND duplicado = 0
				AND folio_csuac = pFolioSuac;

				IF (Es_Nacional = 'F') THEN
					LET Mcosto = 0;
				END IF;

				END IF;  -- comisiÃ¿?Ã¿Â³n desde acl_tipo_evento


				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (numero_transaccion)
				INTO v_numero_transaccion
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac
				AND numero_transaccion = Ctrans_no_procede;

				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (secuencia)
				INTO CSecuencia_acl_mov
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac;

				UPDATE bdiaclaracion:acl_movimiento -->> Valida que no existan movimientos como procedentes de forma erronea para que no sean cargados al cliente.
				SET procede = 0
				WHERE folio_csuac = pFolioSuac
				AND numero_transaccion IS NULL;

				IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la comision de credito, para no duplicarla 24/04/2012
					If Mcosto = '0' Then
						INSERT INTO bdiaclaracion:acl_movimiento(
							pky_movimiento, calculado, cargo, cargo_ajuste, exitoso, fecha_afectacion, fecha_hora_e_global, fechahora, folio_csuac,
							folio_suc, identificador_adquiriente, iso_37, iso_41, monto, montoprocedente, duplicado, numero_transaccion,
							procede, referencia, referencia23, reversado, secuencia, fky_aclaracion, fky_padre, fky_producto,
							fky_solicitud_e_global, fky_tipo_evento, fky_tipo_movimiento, fky_tipo_catalogo_transaccion,
							ref_comercio, num_sucursal, recuperacion, montorecuperacion
						)
						-- pky_movimiento                            calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal, recuperacion, monto_recuperacion
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,        null,			0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     0,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250", null, 0, 0);
					Else
						INSERT INTO bdiaclaracion:acl_movimiento(
							pky_movimiento, calculado, cargo, cargo_ajuste, exitoso, fecha_afectacion, fecha_hora_e_global, fechahora, folio_csuac,
							folio_suc, identificador_adquiriente, iso_37, iso_41, monto, montoprocedente, duplicado, numero_transaccion,
							procede, referencia, referencia23, reversado, secuencia, fky_aclaracion, fky_padre, fky_producto,
							fky_solicitud_e_global, fky_tipo_evento, fky_tipo_movimiento, fky_tipo_catalogo_transaccion,
							ref_comercio, num_sucursal, recuperacion, montorecuperacion
						)
						--cargo por ajuste
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0, 1, null, 0, null, null, current, pFolioSuac, null, null, null, null, Mcosto, Mcosto, 0,Ctrans_no_procede, 1, '', '', 0, CSecuencia_acl_mov, null, Ipky_movimiento, Ifky_producto, null, 1, Ipky_tipo_movimiento, null, null, "9250", null, 0, 0);
					End If;
				END IF;

				-- Redireccionar la BD para la secuencia
				-- UPDATE bdiaclaracion:acl_movimiento SET exitoso = 1, procede = 1 WHERE folio_csuac = pFolioSuac and numero_transaccion is null;
			END IF;

			IF (pDictamen = 'NP') THEN

				UPDATE bdiaclaracion:acl_movimiento
				SET procede = 0
				WHERE (
				(folio_csuac = pFolioSuac
				AND procede = 1
				AND cargo IS NULL
				AND fecha_afectacion IS NULL)
				--Se anexa validaciÃ³n para abono inmediato
				OR (folio_csuac = pFolioSuac AND abono_inmediato = 1 AND procede IS NULL)
				);

			END IF;
			LET v_contador = 0;

			--SET ISOLATION TO DIRTY READ;
			SELECT fechacaptura
			into fecha_captura
			FROM bdiaclaracion:acl_aclaracion
			WHERE folio_csuac=pFolioSuac;

			SET ISOLATION TO DIRTY READ;

			FOREACH WITH hold

				SELECT pky_movimiento, numero_cuenta, numero_tarjeta, montoprocedente, trans_no_procede, trans_procede, trans_procede_automatico, trans_procede_sin_autorizacion, nvl(cargo,0)
				INTO CSecuencia, CnumCredito, CnumTarjeta, CmontoAcla, Ctrannopro, Ctranpro, Ctranauto, Ctransinauto,Ccargo
				FROM bdiaclaracion:acl_movimiento a
				LEFT OUTER JOIN bdiaclaracion:acl_producto b on (a.fky_producto = b.pky_producto)
				LEFT OUTER JOIN bdiaclaracion:acl_tipo_movimiento c on (a.fky_tipo_movimiento = c.pky_tipo_movimiento)
				WHERE folio_csuac = pFolioSuac
				AND (procede IS NULL OR procede = 1)
				AND (exitoso IS NULL OR exitoso <> '1')
				AND NVL(fky_padre,0) = CASE WHEN ( pDictamen IN ('AA','AS')) THEN 0 ELSE NVL(fky_padre,0) END

				IF CnumCredito IS NULL THEN
					LET cCodRet='003';
					--ROLLBACK WORK;
					--IF (wBegin = "S") THEN
						--BEGIN WORK;
					--END IF;
					RETURN cCodRet;
				END IF;

				IF CmontoAcla IS NULL or CmontoAcla = 0 THEN
					LET cCodRet='004';
					--ROLLBACK WORK;
					--IF (wBegin = "S") THEN
						--BEGIN WORK;
					--END IF;
					RETURN cCodRet;
				END IF;

				IF (CnumTarjeta is null) then
					let CnumTarjeta = '';
				END IF;



--f		alta definir la transaccion
--f		alta definir el centro de costos (sucursal)

				IF (pDictamen = 'PR') THEN --> transaccion procedente
					let ptranaplica = Ctranpro;
				elif (pDictamen = 'NP') THEN --> transaccion no procedente
					let ptranaplica = Ctrannopro;
				elif (pDictamen = 'CM') THEN --> transaccion no procedente sin afectaciÃ³n, solÃ³ comisiÃ³n
					let ptranaplica = Ctrannopro;
				elif (pDictamen = 'AA') THEN --> transaccion abono automatico
					let ptranaplica = Ctranauto;
				elif (pDictamen = 'AS') THEN --> transaccion abono automatico sin autorizacion
					let ptranaplica = Ctransinauto;
				END IF;



						--> Validamos el codigo de retorno del sp_calculaintaclaraciones, si es difernete de "0", guardamos el error en bitacora. JLM - 02/06/2022
						IF( pcodigo = '100' ) THEN

							LET  CCodret_c = pcodigo;
							LET  cCodRet   = CCodret_c;
							--INSERT INTO informix.aplicaaclaracredito_control_errores(cod_retorno, nombre_sp, num_credito, num_tarjeta, folio_csuac, fecha_insert)
							--	VALUES(CCodret_c, v_nombre_sp, CnumCredito, CnumTarjeta, pFolioSuac, horaActual);
						ELSE
							LET  CCodret_c = pcodigo;

						END IF;
						-->



						IF (CCodret_c <> "000") THEN
							--Tabla de control de cÃ³digo de retorno
							LET CMensaje = TRIM(CMensaje)||'|'||v_contador_total;

							SELECT MAX(id_registro) + 1
							INTO max_control_afect_cred
							FROM bdiaclaracion:"informix".acl_control_afectacion_cred;

							IF max_control_afect_cred IS NULL THEN
								LET max_control_afect_cred = 1;
							END IF;

							INSERT INTO bdiaclaracion:"informix".acl_control_afectacion_cred
							VALUES (max_control_afect_cred, pFolioSuac, CURRENT, pDictamen, CCodret_c,TRIM(CMensaje),'sp_aplica_credito_smartvista');
							LET cCodRet='009'; --definir codigo en caso de falla en el cargo o abono
							--ROLLBACK WORK;
							--IF (wBegin = "S") THEN
								--BEGIN WORK;
							--END IF;

							RETURN cCodRet;

						END IF;


---		----------- >> Actualiza tabla de movimientos (acl_movimiento) relacionados a la aclaraciÃ³n para indicar que se aplicarÃ³n

				LET CSecuencia_acl_mov = 0;

				SELECT MAX (secuencia)--, folio_csuac
				INTO CSecuencia_acl_mov
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac;

				-------------- >> ValidaciÃ³n de secuencia

				IF (CSecuencia_acl_mov is null) THEN
						LET CSecuencia_acl_mov = 1;
					ELSE
						LET CSecuencia_acl_mov = (CSecuencia_acl_mov) + 1;
				END IF;

				IF (pDictamen NOT IN ('NP', 'CM')) THEN --> Considerar CM y NP para actualizaciones correctas 14/01/2013

					IF (v_contador_total = 0 ) THEN

						UPDATE bdiaclaracion:acl_movimiento
						SET cargo = 0,
							exitoso = '1',
							fecha_afectacion = CURRENT,
							numero_transaccion = ptranaplica,
							secuencia = CSecuencia_acl_mov
						WHERE pky_movimiento = CSecuencia
						AND folio_csuac = pFolioSuac;

					ELSE

						UPDATE bdiaclaracion:acl_movimiento
						SET cargo = 0,
							fecha_afectacion = CURRENT,
							secuencia = CSecuencia_acl_mov
						WHERE pky_movimiento = CSecuencia
						AND folio_csuac = pFolioSuac;

					END IF;
					-- let v_contador = v_contador + 1;

				ELSE

					UPDATE bdiaclaracion:acl_movimiento
					SET cargo = 1,
						exitoso = '1',
						fecha_afectacion = CURRENT,
						numero_transaccion = ptranaplica,
						secuencia = CSecuencia_acl_mov
					WHERE pky_movimiento = CSecuencia
					AND folio_csuac = pFolioSuac;

					-- let v_contador = v_contador + 1;
				END IF;


			let v_contador = v_contador + 1;



			END FOREACH;
		END IF; -- Fin de validació® ¤e TADC
-- Actualiza tabla de acl_aclaracion con la fecha en que se dictamino

    COMMIT WORK;

   -- IF (wBegin = "S") THEN
       -- BEGIN WORK;
   -- END IF;

 END;

 RETURN cCodRet;

END PROCEDURE;