CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_can_iccat(pempresa CHAR(3), pnumcte CHAR(9), pNumRegistros SMALLINT)
RETURNING char(9),char(104),char(16), char(1), char(50), char(4), char(20), char(60), char(1), char(3),char(9),char(9);

--@comment: Declaracion variables para responder
DEFINE ccodret char(9);
DEFINE error_info varchar(104);
DEFINE isam_err integer;
DEFINE isql_err integer;
DEFINE cnomcliente char (104);
DEFINE cnumtarjeta char (16);
DEFINE ctipotar char(1);
DEFINE cestatustar char (50);
DEFINE cproductotar char (4);
DEFINE cnumcuenta char (20);
DEFINE cnumcuentaAux char (20);
DEFINE cstatuscuenta varchar (3);
DEFINE cstatuscuentadesc char (60);
DEFINE ctitular char (1);
DEFINE ccodestatus char (3);
DEFINE cnumCteTitularCuenta char(9);
DEFINE cnumCteTarjeta char(9);
DEFINE iExiste INTEGER;
DEFINE cExisteCta INTEGER;

LET ccodret = "000000000";
LET cnomcliente = "";
LET cnumtarjeta = "";
LET ctipotar = "";
LET cestatustar = "";
LET cproductotar = "";
LET cnumcuenta = "";
LET cnumcuentaAux = "";
LET cstatuscuentadesc = "";
LET ctitular = "";
LET ccodestatus = "";
LET cnumCteTitularCuenta="";
LET cnumCteTarjeta="";
LET iExiste = 0;
LET cExisteCta = 0;

BEGIN

	ON EXCEPTION SET isql_err,isam_err, error_info
		IF isql_err <> 0 THEN
			let ccodret = isql_err;
			LET cnomcliente = error_info;
			
			DROP TABLE IF EXISTS tbl_cuentascliente;
			DROP TABLE IF EXISTS tbl_tarjetascliente;
			
			RETURN ccodret,cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta,cnumCteTarjeta;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/Elmer/713-714/sp_consultartarjetas_debcred_can_iccat.out';
	--TRACE ON;

	DROP TABLE IF EXISTS tbl_cuentascliente;
	CREATE TEMP TABLE tbl_cuentascliente(
		numcte CHAR(20),
		producto CHAR(4),
		statuscta CHAR(3),
		tipotar CHAR(1),
		cuenta CHAR(20)
	) WITH NO LOG;

	DROP TABLE IF EXISTS tbl_tarjetascliente;
	CREATE TEMP TABLE tbl_tarjetascliente(
		numtarjeta CHAR(20),
		cuenta CHAR(20),
		numcte CHAR(20)
	) WITH NO LOG;


	--Se llena tabla de paso con cuentas de debito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq mae1)}
				cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicheq:'informix'.sc_maechq cta
			WHERE cta.num_cte = pnumcte

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con cuentas de credito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)}
				cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicred:'informix'.sd_maecred cta
			WHERE empresa = pempresa AND cta.numcte = pnumcte

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	FOREACH WITH HOLD
		SELECT DISTINCT(cuenta)
		INTO cnumcuenta
		FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'D'
		
		--Se llena tabla de paso con tarjetas de debito del cliente y de los clientes que tienen cuentas relacionadas al cliente titulares o adicionales
		FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta ix_tarjeta4)}
					trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.cuenta = cnumcuenta
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
			
				FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq) } cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
					INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
					FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta
			
						INSERT INTO tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
						VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

		END FOREACH;
	END FOREACH;

	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.cuenta
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
			
				FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq) } cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
					INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
					FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta
			
						INSERT INTO tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
						VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;
	END FOREACH;
			
	--Se llena tabla de paso con tarjetas de debito del cliente y de los credito que tienen cuentas relacionadas al cliente titulares o adicionales
	
	FOREACH WITH HOLD
		SELECT DISTINCT(cuenta)
		INTO cnumcuenta
		FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'C'
		
		FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta pry_tarjeta)}
					trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.num_credito = cnumcuenta
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
			
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta WHERE cta.empresa = pempresa AND cta.num_credito = cnumcuenta
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
			END IF;

		END FOREACH;
	END FOREACH;
		
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.num_credito
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM  bdicred:'informix'.sd_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
			
				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta WHERE cta.empresa = pempresa AND cta.num_credito = cnumcuenta
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
			END IF;

		END FOREACH;
	
	
	
	--Una vez obtenidos los datos anteriores se recorren tarjeta por tarjeta y se obtienen los datos faltantes para regresarlos en el retorno del SPL
	FOREACH WITH HOLD
			SELECT SKIP pNumRegistros FIRST 10
				trjasig.numtarjeta, trjasig.cuenta, trjasig.numcte, cta.numcte, cta.producto, cta.statuscta, cta.tipotar
			INTO cnumtarjeta, cnumcuenta, cnumCteTarjeta, cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar
			FROM 'informix'.tbl_tarjetascliente trjasig INNER JOIN 'informix'.tbl_cuentascliente cta
			ON cta.cuenta = trjasig.cuenta
			WHERE ((cta.numcte = pnumcte)
			OR (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte))
			ORDER BY cta.tipotar DESC, trjasig.numtarjeta ASC

		SELECT trj.nombre, trj.codstatustarjeta, trj.titular, trj.numtarjeta
		INTO cnomcliente, ccodestatus, ctitular, cnumtarjeta
		FROM 'informix'.tarjeta trj
		WHERE trj.numtarjeta = cnumtarjeta AND trj.codstatusasignada = 'SIA';

		SELECT trjest.codstatustarjeta, trjest.descstatustarjeta
		INTO ccodestatus, cestatustar
		FROM 'informix'.statustarjeta trjest
		WHERE trjest.codstatustarjeta = ccodestatus;

		IF ctipotar = 'D' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicheq:'informix'.sc_mae_estatus ctaest WHERE ctaest.cod_estatus = cstatuscuenta;
		ELIF ctipotar = 'C' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicred:'informix'.sd_tipocartera ctaest WHERE ctaest.status_cred = cstatuscuenta;
		END IF;

		IF cnumtarjeta IS NOT NULL THEN -- TARJETA != 'SIA'
			RETURN ccodret, cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta WITH RESUME;
                        --DROP TABLE IF EXISTS tbl_cuentascliente;
                        --DROP TABLE IF EXISTS tbl_tarjetascliente;
		END IF;

		LET iExiste = iExiste + 1;

	END FOREACH
	
	DROP TABLE IF EXISTS tbl_cuentascliente;
	DROP TABLE IF EXISTS tbl_tarjetascliente;

	--En caso de que el cliente no tenga ninguna tarjeta
	IF iExiste = 0 THEN
		RETURN '000000001', 'No tiene tarjetas', cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta;	
	END IF;

END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	consultar todas las tarjetas relacionadas al cliente o su cuenta ',
'AUTOR:		Arturo Astorga',
'FECHA : 	15/08/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se agrega que la relacion del nombre de las tarjetas personalizadas ',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/11/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la cuenta',
'AUTOR:		Arturo Astorga',
'FECHA : 	20/02/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la tarjeta',
'AUTOR:		Arturo Astorga',
'FECHA : 	23/04/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	optimizar las consultas para obtencion de la informacion',
'AUTOR:		Elmer Lopez Valenzuela',
'FECHA : 	24/01/2020',
'SolicitÃ³:  jose luis polanco',
'BD : 		intercard';

CREATE PROCEDURE "informix".sp_camp_registrar_notificaciones( pTipoTransacc VARCHAR(2), pTipoEnvio CHAR(3) )
    RETURNING VARCHAR(5) as rCODIGO_RETORNO, VARCHAR(80) as rMENSAJE_RESPUESTA;

    DEFINE SQL_ERR   INTEGER;
    DEFINE ISAM_ERR   INTEGER;
    DEFINE ERROR_INFO  CHAR(80);
    
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRespuesta VARCHAR(80);
    
    DEFINE vNumCliente VARCHAR(20);
    DEFINE vNumTarjeta VARCHAR(16);
    DEFINE vTipoTarjetaPin_ant CHAR(1);
    DEFINE vTipoChipPinOffline_ant CHAR(1);
    DEFINE vCodEstatusTarj_ant VARCHAR(3);    
    
    DEFINE vCodEstatusTarj_actual VARCHAR(3);
    DEFINE vTipoTarjetaPin_actual CHAR(1);
    DEFINE vTipoChipPinOffline_actual CHAR(1);
    
    
    DEFINE TIPO_TARJETA_A CHAR(1);
    DEFINE TIPO_TARJETA_B CHAR(1);
    DEFINE TIPO_TARJETA_C CHAR(1);
    DEFINE vCVVDinamico CHAR(1);
    DEFINE vCVVDinam_esActivo SMALLINT;
    
    ----Variables para datos actuales

    DEFINE vNumEnvioSMS SMALLINT;
    DEFINE vNumEnvioCorreo SMALLINT;
    DEFINE PROCESO_INICIAL CHAR(1);
    DEFINE PROCESO_TERMINADO CHAR(1);
    DEFINE PROCESO_NOTIFICADO CHAR(1);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(30);
    
    DEFINE NOTIF_SMS CHAR(3);
    DEFINE NOTIF_CORREO_ELEC CHAR(3);
    DEFINE INCREMENTO_CONT_SMS SMALLINT;
    DEFINE INCREMENTO_CONT_CORREO SMALLINT;
    DEFINE vID_Plantilla VARCHAR(12);
    DEFINE vEstatusProceso CHAR(1);
    DEFINE vFechaProceso DATETIME YEAR TO FRACTION(5);
    DEFINE vNumRegPendientes INTEGER;
    DEFINE vTipoTransacc VARCHAR(3);
    DEFINE MOVS_TARJ_PRESENTE VARCHAR(2);
    DEFINE MOVS_TARJ_NO_PRESENTE VARCHAR(2);
    DEFINE TIPO_TRANSACC_T_PRESENTE VARCHAR(3);
    DEFINE TIPO_TRANSACC_TN_PRESENTE VARCHAR(3);
    
    ------Variables usadas como parametros para el registro de mensajes.
    DEFINE vNumTelefono CHAR(13);    
    DEFINE vTerminacionTarjeta CHAR(4);
    DEFINE vCorreoElect CHAR(100);
    DEFINE vTipoCorreo SMALLINT;
    DEFINE vEstatusCorreo CHAR(1);
    
    
    ---proceso de notificacion y conteo de sms o correo electronico
    DEFINE vFechaSistema  DATETIME YEAR TO FRACTION(5);
    DEFINE vContadorTransacciones SMALLINT;
    DEFINE vsFlagEnTransaccion 	VARCHAR(1);
    DEFINE viContadorRegistros 	INTEGER;
    DEFINE vConteo INTEGER;
    DEFINE vContrato VARCHAR(10);
    
    ---Nombre del cliente
    DEFINE vPrimerNombre VARCHAR(26);
    DEFINE vSegundoNombre VARCHAR(26);
    DEFINE vNombreAsignado VARCHAR(26);
    DEFINE vTotalEnvios INTEGER;
    DEFINE vMaxNotificaciones SMALLINT;
    
    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';    
    LET NOTIF_SMS = 'SMS';
    LET NOTIF_CORREO_ELEC = 'CEC';
    LET INCREMENTO_CONT_SMS = 0;
    LET INCREMENTO_CONT_CORREO = 0;
    LET vNumRegPendientes = 0;
    
    LET vTipoTarjetaPin_ant = '';
    LET vTipoChipPinOffline_ant = '';
    LET vCodEstatusTarj_ant = '';
    
    LET TIPO_TARJETA_A = 'A';
    LET TIPO_TARJETA_B = 'B';
    LET TIPO_TARJETA_C = 'C';
    LET vFechaProceso = '';
    
    LET vNumCliente = '';
    LET vCodigoRetorno  = '00000';
    LET vMensajeRespuesta = 'Proceso ejecutado exitosamente.';
    LET vCodEstatusTarj_actual = '';
    LET vNumTarjeta = '';
    
    LET vNumEnvioSMS = 0;
    LET vNumEnvioCorreo = 0;
    LET PROCESO_TERMINADO = 'T';
    LET PROCESO_NOTIFICADO = 'N';
    LET PROCESO_INICIAL = 'I';
    LET vCVVDinamico = '';
    LET vCVVDinam_esActivo = 0;
    LET vID_Plantilla = NULL;
    LET vEstatusProceso = '';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';

    ------Variables usadas como parametros para el registro de mensajes.
    LET vNumTelefono = '0';    
    LET vTerminacionTarjeta = '0000';
    LET vCorreoElect = '0';
    LET vEstatusCorreo = '';
    LET vTipoCorreo = 0;

    LET vTipoTransacc = '';
    LET MOVS_TARJ_PRESENTE = '01';
    LET MOVS_TARJ_NO_PRESENTE = '02';
    LET TIPO_TRANSACC_T_PRESENTE = 'TP';
    LET TIPO_TRANSACC_TN_PRESENTE = 'TNP';
    
    LET vFechaSistema  = sysdate;  
    LET vContadorTransacciones = 1000;    
    LET vsFlagEnTransaccion = 'F';
    LET viContadorRegistros = 0;
    LET vConteo = 0;    
    LET vContrato = '';
     
    LET vPrimerNombre = '';
    LET vSegundoNombre = '';
    LET vNombreAsignado = '';
    LET vTotalEnvios = 0;
    LET vMaxNotificaciones = 0;
    
    BEGIN
    
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO        
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excep_sp_camp_reg_notif.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQL_ERR <> 0 ) THEN
                LET vCodigoRetorno = SQL_ERR;
                LET vMensajeRespuesta = ISAM_ERR|| ERROR_INFO;
                RETURN vCodigoRetorno, vMensajeRespuesta;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS||"debug_sp_camp_registrar_notifi.out" WITH APPEND;
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
        
        DROP TABLE IF EXISTS tmp_reg_pendientes;
        
        SELECT COUNT(*) as reg_pendientes
            FROM intercard:"informix".tbl_campania_notif_tarjeta_ctes
                WHERE estatus_proceso IN ( PROCESO_INICIAL, PROCESO_NOTIFICADO )
            GROUP BY estatus_proceso 
                INTO TEMP tmp_reg_pendientes WITH NO LOG;
        
        SELECT SUM(reg_pendientes) as reg_pendientes
            INTO vNumRegPendientes
        FROM tmp_reg_pendientes;

        IF ( vNumRegPendientes = 0 ) THEN
            LET vCodigoRetorno = '00000';
            LET vMensajeRespuesta = 'No hay informacion pendiente de notificar a nuevos clientes.';
            RETURN vCodigoRetorno, vMensajeRespuesta;
        END IF

        IF ( pTipoTransacc = MOVS_TARJ_PRESENTE ) THEN
            
            LET vTipoTransacc = TIPO_TRANSACC_T_PRESENTE;
            
        ELIF ( pTipoTransacc = MOVS_TARJ_NO_PRESENTE ) THEN
            
            LET vTipoTransacc = TIPO_TRANSACC_TN_PRESENTE;
            
        END IF

        FOREACH cur_buscar_ctes WITH HOLD FOR            
                
            ---Paso 1. 
            ---Iterar todos los registros previamente cargados en el sp_camp_obtener_movs_tnp
            ---y los clientes que todavía no han actualizado su tarjeta de procesos anteriores.
            SELECT DISTINCT num_cliente, numtarjeta, tipo_tarjeta_carga, pin_offline_carga, codestatus_tarjeta_carga
                INTO vNumCliente, vNumTarjeta, vTipoTarjetaPin_ant, vTipoChipPinOffline_ant, vCodEstatusTarj_ant
            FROM intercard:tbl_campania_notif_tarjeta_ctes
                WHERE estatus_proceso IN (PROCESO_INICIAL, PROCESO_NOTIFICADO)
                    AND tipo_transacc_carga = vTipoTransacc
                    
            ---Paso 2.
            ---Buscar el registro que coincida con la iteracion correspondiente
            ---para obtener los datos actuales y comparar si han sufrido algun cambio.
            SELECT DISTINCT a.codstatustarjeta, b.card_type, b.pin_offline
                INTO vCodEstatusTarj_actual, vTipoTarjetaPin_actual, vTipoChipPinOffline_actual
            FROM intercard:tarjeta a INNER JOIN intercard:hsmcard b
                ON(a.numtarjeta = b.card_no)
            WHERE numcliente = vNumCliente
                AND numtarjeta = vNumTarjeta;

            IF (vsFlagEnTransaccion = 'F') THEN
                BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF

            LET vFechaProceso = current;
            
            --Paso 3.
            --Flujos de validación por tipo de transacción: Tarjeta Presente y Tarjeta No Presente.
            --Si la tarjeta es diferente a activada, bloqueada o bloqueo temporal
            --se deja de notificar a dicha tarjeta pero sí al resto de las tarjetas asociadas al cliente.
            IF ( vCodEstatusTarj_actual IN ( 'ACT' , 'BLO', 'BLT' ) ) THEN
                    
                IF ( pTipoTransacc = MOVS_TARJ_PRESENTE ) THEN
                
                    ---Paso 3.1
                    ---Si los valores son iguales entonces la tarjeta NO tiene firma electronica activa.
                    
                    IF ( vTipoTarjetaPin_ant = vTipoTarjetaPin_actual AND 
                            vTipoChipPinOffline_ant = vTipoChipPinOffline_actual ) THEN
                                                                    
                        IF ( pTipoEnvio = NOTIF_SMS ) THEN
                        
                            IF ( vTipoTarjetaPin_ant = TIPO_TARJETA_A ) THEN
                                LET vID_Plantilla = 'CMS_TP_FE_A';
                            END IF
                            
                            IF ( vTipoTarjetaPin_ant IN ( TIPO_TARJETA_B, TIPO_TARJETA_C ) ) THEN
                                LET vID_Plantilla = 'CMS_TP_FE_BC';                                        
                            END IF
                            
                        END IF
                                    
                                    
                        IF (  pTipoEnvio = NOTIF_CORREO_ELEC ) THEN
                            
                            IF ( vTipoTarjetaPin_ant = TIPO_TARJETA_A ) THEN
                                LET vID_Plantilla = 'CMC_TP_FE_A';                                        
                            END IF
                            
                            IF ( vTipoTarjetaPin_ant IN ( TIPO_TARJETA_B, TIPO_TARJETA_C ) ) THEN
                                LET vID_Plantilla = 'CMC_TP_FE_BC';                                        
                            END IF
                            
                        END IF

                        UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                            SET estatus_proceso = PROCESO_NOTIFICADO,                                 
                                    fecha_proceso = vFechaProceso,
                                desc_plantilla = vID_Plantilla
                        WHERE num_cliente = vNumCliente
                            AND numtarjeta = vNumTarjeta
                                AND tipo_transacc_carga = vTipoTransacc;
                                
                        LET vID_Plantilla = NULL;
                    
                    ELSE
                    
                        UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                            SET tipo_tarjeta_proc = vTipoTarjetaPin_actual,
                                    pin_offline_proc = vTipoChipPinOffline_actual,
                                codestatus_tarjeta_proc = vCodEstatusTarj_actual,
                                    estatus_proceso = PROCESO_TERMINADO,                                 
                                fecha_proceso = vFechaProceso,
                                    desc_plantilla = 'FINALIZADO'
                        WHERE num_cliente = vNumCliente
                            AND numtarjeta = vNumTarjeta
                                AND tipo_transacc_carga = vTipoTransacc;
                            
                    END IF
                    
                END IF ---Cierre de tarjeta presente (pTipoTransacc = MOVS_TARJ_PRESENTE)
                    
                --Paso 3.2
                ---Validar si la tarjeta tiene CVV dinamico activo o firma electronica activa
                IF ( pTipoTransacc = MOVS_TARJ_NO_PRESENTE ) THEN                        
                        
                    LET vID_Plantilla = 'FINALIZADO';
                    LET vEstatusProceso = PROCESO_TERMINADO;
                    
                    SELECT cvv2dinamico
                        INTO vCVVDinamico
                    FROM intercard:tarjeta_indicadores
                        WHERE numtarjeta = vNumTarjeta
                            AND cvv2dinamico = 'V';                    
                    
                    LET vCVVDinam_esActivo = dbinfo("sqlca.sqlerrd2");                    

                    --La tarjeta NO tiene CVV Dinamico activo (sin enrolamiento), o bien, ni siquiera hay registro en 
                    --tarjeta indicadores.
                    IF ( vCVVDinam_esActivo = 0 ) THEN
                        
                        LET vEstatusProceso = PROCESO_NOTIFICADO;
                        
                        ---Si los valores son iguales entonces la tarjeta NO tiene firma electronica activa.
                        --IF ( vTipoTarjetaPin_ant = vTipoTarjetaPin_actual AND 
                          --      vTipoChipPinOffline_ant = vTipoChipPinOffline_actual ) THEN
                                
                                IF (  pTipoEnvio = NOTIF_SMS ) THEN
                                    LET vID_Plantilla = 'CMS_TNP_FECD';
                                ELIF (  pTipoEnvio = NOTIF_CORREO_ELEC ) THEN
                                    LET vID_Plantilla = 'CMC_TNP_FECD';
                                END IF
                        --END IF
                        
                    END IF
                                   
                    UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                        SET estatus_proceso = vEstatusProceso, 
                                tipo_tarjeta_proc = vTipoTarjetaPin_actual,
                            pin_offline_proc = vTipoChipPinOffline_actual,
                                codestatus_tarjeta_proc = vCodEstatusTarj_actual,
                            fecha_proceso = vFechaProceso,
                                desc_plantilla = vID_Plantilla
                    WHERE num_cliente = vNumCliente
                        AND numtarjeta = vNumTarjeta
                            AND tipo_transacc_carga = vTipoTransacc;


                END IF ---Cierre de tarjeta NO presente (pTipoTransacc = MOVS_TARJ_NO_PRESENTE)
                    
            ELSE
                
                --El estatus de la tarjeta no cumple con las condiciones
                --y deja de notificarse al cliente solo con esta tarjeta asignada 
                --ya sea Tarjeta Presente o Tarjeta No Presente.
                UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                    SET tipo_tarjeta_proc = vTipoTarjetaPin_actual,
                        pin_offline_proc = vTipoChipPinOffline_actual,
                            codestatus_tarjeta_proc = vCodEstatusTarj_actual,
                        estatus_proceso = PROCESO_TERMINADO,
                        desc_plantilla = 'FINALIZADO',
                        fecha_proceso = vFechaProceso
                WHERE num_cliente = vNumCliente
                    AND numtarjeta = vNumTarjeta
                        AND tipo_transacc_carga = vTipoTransacc;                       
            END IF
        
            LET vConteo = dbinfo("sqlca.sqlerrd2") + vConteo;
            IF (vConteo >= vContadorTransacciones) THEN
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
                LET viContadorRegistros = 0;
                CONTINUE FOREACH;
            END IF
            
            --Reinicio de variable para el siguiente ciclo.
            LET vCVVDinam_esActivo = 0;
            LET vFechaProceso = NULL;
        
        END FOREACH


        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_campania_notif_tarjeta_ctes;

        LET vID_Plantilla = '';
        LET vConteo = 1;
        LET vFechaProceso = NULL;
        
        --Paso 4. Registro y conteo de notificaciones para los clientes.
       
        IF ( pTipoEnvio = NOTIF_SMS ) THEN
            ---Contrato Latinia: Campania SMS por proceso batch.
            LET vContrato = 'CMPS_BATCH';
        END IF
        IF ( pTipoEnvio = NOTIF_CORREO_ELEC ) THEN
            ---Contrato Latinia: Campania Correo electronico por proceso batch.
            LET vContrato = 'CMPC_BATCH';
        END IF
        
        ---Obtener número máximo de notificaciones 
        ---para considerar el envío de mensajes de texto o correo electrónico hacia los clientes.
        SELECT camp_max_notificaciones 
            INTO vMaxNotificaciones
        FROM intercard:parametros;
        
        
        IF ( pTipoEnvio = NOTIF_SMS ) THEN      
    
            FOREACH cur_enviar_notif WITH HOLD FOR        

                SELECT num_cliente, desc_plantilla, numtarjeta, NVL(b.telefono, 0) as num_telefono, 
                    MAX(num_registro_sms) as sms,
                        MAX(num_registro_correo_elec) as correo, 
                            ( MAX(num_registro_sms) + MAX(num_registro_correo_elec) ) as total_envios
                    INTO vNumCliente, vID_Plantilla, vNumTarjeta, vNumTelefono, vNumEnvioSMS, vNumEnvioCorreo, vTotalEnvios
                FROM intercard:"informix".tbl_campania_notif_tarjeta_ctes a 
                    INNER JOIN bdinteg:"informix".si_telefonos_actual b
                        ON (a.num_cliente = b.numcte)
                WHERE a.estatus_proceso = PROCESO_NOTIFICADO
                    AND a.tipo_transacc_carga = vTipoTransacc
                        AND b.tipo_tel = '2' 
                    AND b.status_tel = 'A'                    
                GROUP BY num_cliente, desc_plantilla, numtarjeta, b.telefono                
                
                IF (vsFlagEnTransaccion = 'F') THEN
                    BEGIN WORK;
                    LET vsFlagEnTransaccion = 'V';
                END IF                
                        
                LET vFechaProceso = sysdate;                
                
                IF ( vNumTelefono <> '' AND vNumTelefono <> '0' AND vTotalEnvios < vMaxNotificaciones ) THEN
                    
                    SELECT nombre1, nombre2
                        INTO vPrimerNombre, vSegundoNombre
                    FROM bdinteg:si_cliente
                        WHERE numcte = vNumCliente;
                    
                    LET vNombreAsignado = TRIM(vPrimerNombre);
                    
                    IF ( LENGTH ( TRIM(vPrimerNombre)) < 3 ) THEN
                        LET vNombreAsignado = TRIM(vSegundoNombre);
                    END IF
                    
                    LET vTerminacionTarjeta = SUBSTR( vNumTarjeta, 13, 4 );
                    
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2', vContrato, vID_Plantilla, vNumCliente,'','','2',vNombreAsignado,vTerminacionTarjeta,'','','','','','','','','',vNumTelefono,0,0,0,0,0,vFechaSistema,vFechaSistema)
                        INTO vCodigoRetorno;                        
                    
                    IF ( vCodigoRetorno = '00000' ) THEN
                    
                        LET INCREMENTO_CONT_SMS = 1;
                        
                        INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
                            VALUES ( vID_Plantilla, vNumTarjeta, vFechaProceso, 'V' ,'2', vCodigoRetorno, vTipoTransacc );
                    END IF
                    
                END IF                
        
                UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                    SET num_registro_sms = vNumEnvioSMS + INCREMENTO_CONT_SMS, 
                        num_registro_correo_elec = vNumEnvioCorreo + INCREMENTO_CONT_CORREO,
                        fecha_proceso = vFechaProceso,
                        estatus_proceso = PROCESO_NOTIFICADO
                WHERE num_cliente = vNumCliente
                    AND numtarjeta = vNumTarjeta
                        AND tipo_transacc_carga = vTipoTransacc;
                 
                LET INCREMENTO_CONT_SMS = 0 ;
                LET INCREMENTO_CONT_CORREO = 0;
                LET vID_Plantilla = NULL;
                LET vFechaProceso = NULL;
                LET vTerminacionTarjeta = NULL;
                LET vNumTarjeta = NULL;
                LET vNombreAsignado = NULL;
                
                LET vConteo = dbinfo("sqlca.sqlerrd2") + vConteo;
                
                IF (vConteo >= vContadorTransacciones) THEN
                    COMMIT WORK;
                    LET vsFlagEnTransaccion = 'F';
                    LET viContadorRegistros = 0;
                    LET vConteo = 1; ---reinicio del contador
                    CONTINUE FOREACH;
                END IF;

            END FOREACH
            
        END IF
    
   
                            
        IF ( pTipoEnvio = NOTIF_CORREO_ELEC ) THEN
    
            FOREACH cur_enviar_notif WITH HOLD FOR
        
                SELECT num_cliente, desc_plantilla, numtarjeta,  NVL(c.correo_elec, 0) as correo_elec, 
                        MAX(num_registro_correo_elec) as max_correo,
                            MAX(num_registro_sms) as sms,
                                ( MAX(num_registro_sms) + MAX(num_registro_correo_elec) ) as total_envios
                        INTO vNumCliente, vID_Plantilla, vNumTarjeta, vCorreoElect, vNumEnvioCorreo, vNumEnvioSMS, vTotalEnvios
                    FROM intercard:"informix".tbl_campania_notif_tarjeta_ctes a 
                        INNER JOIN bdinteg:"informix".si_correos c
                            ON (a.num_cliente = c.numcte)		
                WHERE a.estatus_proceso = PROCESO_NOTIFICADO
                    AND a.tipo_transacc_carga = vTipoTransacc
                        AND c.tipo_correo = 1
                    AND c.status_correo = 'A'                    
                GROUP BY num_cliente, desc_plantilla, numtarjeta, c.correo_elec
                
                IF (vsFlagEnTransaccion = 'F') THEN
                    BEGIN WORK;
                    LET vsFlagEnTransaccion = 'V';
                END IF                
            
                LET vFechaProceso = sysdate;
                        
                IF ( vCorreoElect <> '' AND vCorreoElect <> '0' AND vTotalEnvios < vMaxNotificaciones ) THEN                            
                    
                    SELECT nombre1, nombre2
                        INTO vPrimerNombre, vSegundoNombre
                    FROM bdinteg:si_cliente
                        WHERE numcte = vNumCliente;
                    
                    LET vNombreAsignado = TRIM(vPrimerNombre);
                    
                    IF ( LENGTH ( TRIM(vPrimerNombre)) < 3 ) THEN
                        LET vNombreAsignado = TRIM(vSegundoNombre);
                    END IF
                    
                    LET vTerminacionTarjeta = SUBSTR( vNumTarjeta, 13, 4 );
                    
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',vContrato, vID_Plantilla, vNumCliente,'','','2',vNombreAsignado,vTerminacionTarjeta,'','','','','','','','',vCorreoElect,'',0,0,0,0,0,vFechaSistema,vFechaSistema)
                        INTO  vCodigoRetorno;                    
                    
                    IF ( vCodigoRetorno = '00000' ) THEN
                        LET INCREMENTO_CONT_CORREO = 1;
                        
                        INSERT INTO intercard:"informix".bitacoraenvios_tjts (id_proceso, tarjeta, fecha_insert, estatus_envio, tipo_envio, cod_ret, descripcion)
                            VALUES ( vID_Plantilla, vNumTarjeta , vFechaProceso , 'V' ,'2', vCodigoRetorno, vTipoTransacc );
                    END IF
                    
                END IF
                
                UPDATE intercard:"informix".tbl_campania_notif_tarjeta_ctes
                    SET num_registro_sms = vNumEnvioSMS + INCREMENTO_CONT_SMS, 
                        num_registro_correo_elec = vNumEnvioCorreo + INCREMENTO_CONT_CORREO,
                        fecha_proceso = vFechaProceso,
                        estatus_proceso = PROCESO_NOTIFICADO
                WHERE num_cliente = vNumCliente
                    AND numtarjeta = vNumTarjeta
                        AND tipo_transacc_carga = vTipoTransacc;
                 
                LET INCREMENTO_CONT_SMS = 0 ;
                LET INCREMENTO_CONT_CORREO = 0;
                LET vID_Plantilla = NULL;
                LET vFechaProceso = NULL;
                LET vTerminacionTarjeta = NULL;
                LET vNumTarjeta = NULL;
                LET vNombreAsignado = NULL;
                
                LET vConteo = dbinfo("sqlca.sqlerrd2") + vConteo;
                IF (vConteo >= vContadorTransacciones) THEN
                    COMMIT WORK;
                    LET vsFlagEnTransaccion = 'F';
                    LET viContadorRegistros = 0;
                    LET vConteo = 1; ---reinicio del contador
                    CONTINUE FOREACH;
                END IF;        
        
            END FOREACH

        END IF
    
        LET vCodigoRetorno = '00000';
        
        IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';
        END IF;

        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_campania_notif_tarjeta_ctes;
        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".bitacoraenvios_tjts;        
        
        RETURN 	vCodigoRetorno,vMensajeRespuesta; 
        
        
        
    END

END PROCEDURE
---#1
---Base de datos: intercard
---Autor: Armando Garcia Ortiz
---Creacion: 30 de julio del 2020
---Descripcion: Proceso para registrar las notificaciones de mensajes de texto o correo electronico 
---a los numeros de clientes previamente registrados.

---#2
---Modificacion: 17 de septiembre del 2020
---Descripcion: Se agrega el registro en la tabla de bitacora de envio de mensajes 
---considerando los registros para mensajes de texto o correo electronico de la campaña

---#3
---Modificacion: 30 de diciembre del 2020
---Descripcion: Se agrega funcionalidad para personalizar los mensajes de la campaña.
---Y validacion del maximo número de notificaciones.

---Este componente es ejecutado por los jobs:
--=> 843_01_1_CORREO_NOTIF_CTES_TP_PRO
--=> 843_01_2_SMS_NOTIF_CTES_TP_PRO
--=> 843_02_1_CORREO_NOTIF_CTES_TNP_PRO
--=> 843_02_2_SMS_NOTIF_CTES_TNP_PRO
;

CREATE PROCEDURE "informix".sp_tarj_det_vcas_prueba()
RETURNING VARCHAR(10), VARCHAR(255)

DEFINE vfecha DATETIME YEAR TO FRACTION(5);
DEFINE vfechaTime DATETIME YEAR TO FRACTION(5);


DEFINE vstatus_proc 	CHAR(1);
DEFINE vcod_ret         VARCHAR(10);
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(40);

DEFINE v_dia         	CHAR(2);
DEFINE v_mes         	CHAR(2);
DEFINE v_ano         	CHAR(4);
DEFINE v_hora 			DATETIME HOUR TO SECOND;
DEFINE v_hora2 			CHAR(8);
DEFINE v_sql         	CHAR(250);
DEFINE cEncabezado   	CHAR(250);

DEFINE cRuta 			CHAR(250);
DEFINE cRuta2 			CHAR(250);
DEFINE cNombreArchivo 	CHAR(250);
DEFINE cNombreArchivo1 	CHAR(250);
DEFINE cNombreArchivo2 	CHAR(250);

DEFINE var_action 		CHAR(6);
DEFINE var_numtarjeta   VARCHAR(16);
DEFINE var_telefono     CHAR(13);
DEFINE var_correo_elec 	CHAR(100);
DEFINE var_fecha        DATETIME YEAR to SECOND;

DEFINE iContador_pay    SMALLINT;
DEFINE vreg_ins INTEGER;

--MANEJO DEL ERROR.
ON EXCEPTION
SET sql_err, isam_err, error_info

UPDATE intercard:ctrl_info_ctes_vcas
SET status_proc = '0';

IF sql_err <> 0 THEN
	LET vcod_ret=sql_err;
	UPDATE intercard:ctrl_info_ctes_vcas
	SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
    RETURN vcod_ret, isam_err||' ' ||error_info;
END IF;
END EXCEPTION;

--set debug file to "/tmp/sp_tarj_det_vcas.out";
--TRACE ON;

LET vfecha = TODAY;
LET vfechaTime = TODAY;
LET vstatus_proc = '';

LET vcod_ret = '000';          
LET sql_err = 0;          
LET isam_err = 0;        
LET error_info = '';
LET iContador_pay = 0;

LET v_dia           = "";
LET v_mes           = "";
LET v_ano           = "";  
LET v_hora 			= CURRENT;
LET v_hora2 		= "";
LET v_sql           = "";

LET cEncabezado     = "";
LET cRuta 			= "/tmp/";
LET cRuta2 			= "/RESPALDOSNEW/VCAS_resultados/";
LET cNombreArchivo 	= "";
LET cNombreArchivo1 = "";
LET cNombreArchivo2 = "";

LET var_action 		= "";
LET var_numtarjeta  = "";
LET var_telefono    = "";
LET var_correo_elec = "";
LET var_fecha       = CURRENT;
LET vreg_ins 		= 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
 
SELECT status_proc
INTO vstatus_proc
FROM intercard:ctrl_info_ctes_vcas;

IF(vstatus_proc = '1') THEN
UPDATE intercard:ctrl_info_ctes_vcas
SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
RETURN vcod_ret, 'DESCARGA EN PROCESO';
END IF;
   
UPDATE intercard:ctrl_info_ctes_vcas SET status_proc = '1';  
 
SELECT fecha, fecha  - 1 units hour
INTO vfecha, vfechaTime
FROM intercard:ctrl_info_ctes_vcas;

-- ELIMINA REGISTROS DE TABLA DE RESULTADOS EN CASO DE QUE HAYA FALLADO EL SP Y HAYA GENERADO INFORMACION.
   
   TRUNCATE TABLE intercard:ctas_vcas;

  -- CREAR TEMPORALES PARA RESULTADO FINAL
    SELECT {+AVOID_FULL(intercard:info_tarjeta_pyt)} numtarjeta, fechaasignacion
    FROM intercard:info_tarjeta_pyt
    WHERE codstatustarjeta = 'ACT'
    AND fechaasignacion>=vfecha
    INTO temp tmptarj with no log;

    CREATE INDEX "informix".tmp_tartarj_vcas ON tmptarj(numtarjeta) ONLINE;

	SELECT bin
	FROM intercard:bines WHERE (marca  = 'VS' or bin in (510148, 554948 ,559471)) --
	INTO temp BIN_VISA with no log;

    --TARJETAS DE CREDITO
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta)
    INTO temp tmpctestarj with no log;

    CREATE INDEX "informix".tmp_cte_pt ON tmpctestarj(numcte,num_tarjeta) ONLINE;

    -- CREATE INDEX "informix".tmp_tarj_pt ON tmpctestarj(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO
    INSERT INTO tmpctestarj
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta);

    -- TABLA TELEONOS TIPO 2
	SELECT {+AVOID_FULL(bdinteg:si_telefonos_actual)} telefono, numcte, status_tel, fecha_hora
    FROM bdinteg:si_telefonos_actual
    --WHERE (tipo_tel = 2 and  fecha_hora >=vfecha) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))
	WHERE ((fecha_hora >=vfechaTime) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))) and tipo_tel = 2
    INTO temp tmptelefono_tipo2 with no log;

    CREATE INDEX "informix".tmptelefono_tipo2_idx1  ON tmptelefono_tipo2(status_tel,fecha_hora) ONLINE;
    --CREATE INDEX "informix".tmptelefono_tipo2_idx2  ON tmptelefono_tipo2(numcte) ONLINE;


    --TEMPORAL DE TELEONOS
	SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE status_tel = 'A' and fecha_hora >= vfechaTime
    GROUP BY telefono, numcte
    UNION
    SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1) AND status_tel = 'A'
    GROUP BY telefono, numcte
    INTO temp tmptelefono with no log;

    CREATE INDEX "informix".tmptelefono_idx1 ON tmptelefono(numcte,telefono) ONLINE;
    --CREATE INDEX "informix".tmptelefono_idx2 ON tmptelefono(numcte) ONLINE;


    -- TABLA CORREOS  TIPO 1
	SELECT {+AVOID_FULL(bdinteg:si_correos)} tipo_correo, status_correo, secuencia, valido, numcte, correo_elec, fecha_hora
    FROM bdinteg:si_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1 AND C.fecha_hora >= vfechaTime
	INTO temp tmpsi_correos with no log;

	--CREATE INDEX "informix".tmpsi_correos_idx1 ON tmpsi_correos(tipo_correo,status_correo,fecha_hora, valido);
	CREATE INDEX "informix".tmpsi_correos_idx2 ON tmpsi_correos(numcte,tipo_correo,status_correo,valido);

	--TEMPORAL DE CORREOS

	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE numcte IN  (SELECT numcte FROM tmpctestarj WHERE 1=1)
	AND C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1
    GROUP BY correo_elec, numcte
	UNION
	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND fecha_hora >= vfechaTime AND C.valido = 1
	GROUP BY correo_elec, numcte
	INTO temp tmpcorreo with no log;

    CREATE INDEX "informix".tmp_correlec_vcas ON tmpcorreo(numcte,correo_elec) ONLINE;
    --CREATE INDEX "informix".tmp_numctecorr_vcas ON tmpcorreo(numcte) ONLINE;

   --TARJETAS DE CREDITO CTES
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono)
    INTO temp tmpctestarjfin with no log;

    CREATE INDEX "informix".tmp_cte_pts ON tmpctestarjfin(numcte,num_tarjeta) ONLINE;
	--CREATE INDEX "informix".tmp_tarj_pts ON tmpctestarjfin(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO CTES
    INSERT INTO tmpctestarjfin
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono);

	--CTES CON TARJETAS ACTUALIZADAS
    SELECT {+AVOID_FULL(intercard:info_tarjeta_pyt)} numtarjeta, A.fechaasignacion, B.numcte
    FROM intercard:info_tarjeta_pyt A, tmpctestarjfin B
    WHERE A.numtarjeta=B.num_tarjeta AND codstatustarjeta = 'ACT'
    GROUP BY A.numtarjeta, A.fechaasignacion, B.numcte
    INTO temp tmptarjeta with no log;

    CREATE INDEX "informix".tmp_numtarj_vcas ON tmptarjeta(numcte,numtarjeta) ONLINE;
    --CREATE INDEX "informix".tmp_numclient_vcas ON tmptarjeta(numcte) ONLINE;
    CREATE INDEX "informix".tmp_fechasig_vcas ON tmptarjeta(fechaasignacion) ONLINE;
   
-- INFORMACION QUE SE EJECUTARA CADA DETERMINADO TIEMPO.
BEGIN WORK;
FOREACH WITH HOLD
	SELECT CASE WHEN A.fechaasignacion >= vfecha THEN 'ADD' ELSE 'UPDATE' END AS action,
	A.numtarjeta,B.telefono AS telefono,C.correo_elec AS correo_elec,
	CURRENT AS fecha
    INTO var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha
    FROM tmptarjeta A
    LEFT JOIN tmptelefono B ON A.numcte=B.numcte
    LEFT JOIN tmpcorreo C ON A.numcte=C.numcte
    WHERE SUBSTR(A.numtarjeta,1,6) IN (SELECT bin FROM BIN_VISA )
	AND((B.telefono IS NOT NULL)OR(C.correo_elec IS NOT NULL))            
    GROUP BY A.numtarjeta, B.telefono, C.correo_elec,fecha,action

	LET iContador_pay = iContador_pay + 1;

	INSERT INTO "informix".ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha)
    VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha);
       
    IF iContador_pay = 1000 THEN
		COMMIT;
		LET iContador_pay = 0;
		BEGIN WORK;
	END IF;
END FOREACH;
COMMIT;

	-- DESCARGAR ARCHIVO.
	LET v_dia = LPAD(DAY(CURRENT),2,'0');  
	LET v_mes = LPAD(MONTH(CURRENT),2,'0');
	LET v_ano = year(CURRENT);
    LET v_hora2 = v_hora::CHAR(8);
	LET cNombreArchivo = TRIM(cRuta2)||'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';
	LET cNombreArchivo1 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux.csv';
    LET cNombreArchivo2 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux2.csv';
         
	-- DESCARGA DEL ARCHIVO .CSV.
	LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /tmp/queryenc.sql';
    System cEncabezado;

	LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /tmp/queryhist.sql ';
	System v_sql;

    LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo " from intercard:ctas_vcas  where numtarjeta <> ''''" >> /tmp/queryhist.sql';
	System v_sql;

	LET v_sql = "dbaccess intercard /tmp/queryhist.sql";
	System v_sql;

	LET v_sql="";

	--SE AÃÂADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
	LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    LET v_sql="";

	LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    --SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
    LET v_sql = "";
    LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
    SYSTEM v_sql;

	--BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo1);
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo2);
    SYSTEM TRIM(v_sql);

	-- DATOS PARA LA TABLA CONTROL.
	SELECT MAX(fecha::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND )
	INTO vfecha
	FROM intercard:ctas_vcas;

	IF  vfecha  IS NULL THEN
		LET vfecha = CURRENT;
	END IF

	-- CONTEO DE REGISTROS.
	SELECT COUNT(*)
	INTO vreg_ins
	FROM intercard:ctas_vcas;

	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS Y TEMPORALES.
    TRUNCATE TABLE intercard:ctas_vcas;

	DROP TABLE BIN_VISA;
	DROP TABLE tmpctestarj;
    DROP TABLE tmptelefono;
    DROP TABLE tmpcorreo;
	DROP TABLE tmptarjeta;
    DROP TABLE tmptarj;
    DROP TABLE tmpctestarjfin;

	-- ACTUALIZAR TABLA CONTROL.
	UPDATE intercard:ctrl_info_ctes_vcas
	SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados) = ( vfecha, '0', vcod_ret, 'DESCARGA EXITOSA', vreg_ins);

 
    RETURN vcod_ret, 'DESCARGA EXITOSA';
END PROCEDURE;