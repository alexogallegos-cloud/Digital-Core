CREATE PROCEDURE "informix".sp_cmp_validar_obligatoriedad_ctes( pNumCliente VARCHAR(20), pNumTarjeta VARCHAR(16),  pTipoTransacc VARCHAR(3), pTipoTarjeta CHAR(1)) 
    RETURNING VARCHAR(5) AS rCodigoRetorno, VARCHAR (80) as rMensajeRetorno;
	
    DEFINE SQL_ERR   INTEGER;
    DEFINE ISAM_ERR   INTEGER;
    DEFINE ERROR_INFO  CHAR(80);
    
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRetorno VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(35);
    DEFINE vValidarCVV SMALLINT;
    DEFINE vValidarFirmaElec SMALLINT;
    DEFINE vTotalRegistros INTEGER;
    DEFINE vCteRegistrado SMALLINT;
    
    DEFINE vNumeroCliente VARCHAR(20);
    DEFINE vNumeroTarjeta VARCHAR(16);
    DEFINE vTipoTransaccion VARCHAR(3);
    DEFINE TIPO_TRANSACC_TJT_PRESENTE VARCHAR(3);
    DEFINE TIPO_TRANSACC_TJT_NO_PRES VARCHAR(3);    
    DEFINE TIPO_TARJETA_A CHAR(1);
    DEFINE TIPO_TARJETA_B CHAR(1);
    DEFINE TIPO_TARJETA_C CHAR(1);
    DEFINE vPlantilla VARCHAR(12);    
    DEFINE vNumTelefono CHAR(13);    
    DEFINE vTerminacionTarjeta CHAR(4);
    DEFINE vPrimerNombre VARCHAR(26);
    DEFINE vSegundoNombre VARCHAR(26);
    DEFINE vApellidoPaterno VARCHAR(26);
    DEFINE vApellidoMaterno VARCHAR(26);    
    DEFINE vCorreoElect VARCHAR(100);
    
    DEFINE vContratoSMS VARCHAR(12);
    DEFINE vPlantillaSMS VARCHAR(12);
    DEFINE vContratoCorreo VARCHAR(12);
    DEFINE vPlantillaCorreo VARCHAR(12);
    
    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
    
    LET vCodigoRetorno = '00000';
    LET vMensajeRetorno = 'Inicio de ejecucion';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vValidarCVV = 0;
    LET vValidarFirmaElec = 0;
    LET vTotalRegistros = 0;            
        
    LET vNumeroCliente = '';
    LET vNumeroTarjeta = '';
    LET vTipoTransaccion = '';
    LET vCteRegistrado = 0;
    
    LET TIPO_TRANSACC_TJT_PRESENTE = 'TP';
    LET TIPO_TRANSACC_TJT_NO_PRES = 'TNP';
    LET TIPO_TARJETA_A = 'A';
    LET TIPO_TARJETA_B = 'B';
    LET TIPO_TARJETA_C = 'C';    
    LET vPlantilla = NULL;    
    LET vNumTelefono = '0';    
    LET vTerminacionTarjeta = '0000';
    LET vPrimerNombre = '0';
    LET vSegundoNombre = '0';
    LET vNumeroCliente = '';
    LET vApellidoPaterno = '';
    LET vApellidoMaterno = '';    
    LET vCorreoElect = '0';    
    LET vContratoSMS = 'CMPS_BATCH';    

    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_cmp_validar_obligatoriedad_ctes.out" WITH APPEND;
    --TRACE ON;
	
	BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excep_sp_cmp_validar_obligatoriedad_ctes.err" WITH APPEND;
            TRACE ON;
            
            IF ( SQL_ERR <> 0 ) THEN
                LET vCodigoRetorno = SQL_ERR;
                LET vMensajeRetorno = ERROR_INFO;                
                RETURN vCodigoRetorno, vMensajeRetorno;
            END IF
			
        END EXCEPTION

        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;

        SELECT COUNT(*) 
            INTO vValidarCVV 
        FROM intercard:validacionauth
            WHERE idvalidacionauth = '0218'
                AND flagpermitevalidacion = 'F';        

        SELECT COUNT(*) 
            INTO vValidarFirmaElec 
        FROM intercard:validacionauth
            WHERE idvalidacionauth = '0219'
                AND flagpermitevalidacion = 'F';
        
        IF ( vValidarCVV == 1 AND vValidarFirmaElec == 1 ) THEN
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'La obligatoriedad esta deshabilitada.';
            RETURN vCodigoRetorno, vMensajeRetorno;            
        END IF
        
        SELECT COUNT(*)
            INTO vTotalRegistros        
        FROM intercard:tbl_campania_ctes_notificados
            WHERE tipo_transaccion IN ( 'TP', 'TNP' );                
        
        IF ( vTotalRegistros = 0 ) THEN            
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'La informacion no esta actualizada para ser consultada.';
            RETURN vCodigoRetorno, vMensajeRetorno;            
        END IF
        
        
        IF ( pTipoTransacc <> TIPO_TRANSACC_TJT_PRESENTE AND  pTipoTransacc <> TIPO_TRANSACC_TJT_NO_PRES ) THEN
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Tipo de Transaccionalidad no permitida.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF        
        
        --Buscar si el cliente previamente ha sido notificado. 
        SELECT numcte, numtarjeta, tipo_transaccion
            INTO vNumeroCliente, vNumeroTarjeta, vTipoTransaccion
        FROM intercard:"informix".tbl_campania_ctes_notificados
            WHERE numcte = pNumCliente
                AND numtarjeta = pNumTarjeta
                  AND  tipo_transaccion = pTipoTransacc;

        LET vCteRegistrado = dbinfo("sqlca.sqlerrd2");        
        
        ---El cliente ya fue notificado en la campanya.
        IF ( vCteRegistrado = 1 ) THEN 
            
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Rechazar la Transaccionalidad. Sin notificacion al cliente.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF
        
        EXECUTE PROCEDURE intercard:"informix".sp_intercard_info_ctes_por_notif( pNumCliente, 'N')        
            INTO vCodigoRetorno,  vMensajeRetorno, vNumeroCliente, vPrimerNombre, vSegundoNombre, vApellidoPaterno, vApellidoMaterno,
                    vNumTelefono, vCorreoElect;            

        ---El Cliente no ha sido previamente notificado en la campanya pero no tiene telefono
        --y debe buscarse su informacion para enviar el correspondiente mensaje.
        IF ( vCteRegistrado = 0 AND LENGTH(vNumTelefono) = 0) THEN
        
            ---El Cliente no ha sido previamente notificado en la campanya  PERO NO tiene telefono para notificarles
            --Registrar en una tabla de clientes para obtener el reporte y darle aviso al CAT            
            
            INSERT INTO intercard:"informix".tbl_campania_ctes_sin_notif  (numtarjeta, num_cliente, tipo_tarjeta_carga, pin_offline_carga, tipo_transacc_carga, fecha_registro)
                    VALUES (vNumeroTarjeta, vNumeroCliente, pTipoTarjeta,'1',pTipoTransacc, current);
                   
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'Continuar Transaccionalidad. Sin notificacion al cliente.';
            RETURN vCodigoRetorno, vMensajeRetorno;            
        END IF
        
        RETURN vCodigoRetorno, vMensajeRetorno;
            
	END
				
END PROCEDURE
DOCUMENT
'#1',
'Armando Garcia Ortiz',
'Base de datos: intercard',
'Fecha: 18 de enero del 2021',
'Descripcion: Ejecucion mediante el autorizador para validar la aceptacion o rechazo',
'de la transaccionalidad con tarjeta presente o tarjeta no presente'
;

CREATE PROCEDURE "informix".sp_registra_ctes_notificados()
RETURNING CHAR(5) AS rCodigoRetorno, CHAR(160) AS mensaje;
    

	DEFINE vNumcte				CHAR(20);
    DEFINE vTarjeta		  		CHAR(16);
    DEFINE vEstatus_proceso		CHAR(1);
	DEFINE vTipo_tarjeta_carga  CHAR(1);
	DEFINE vTipo_transaccion	VARCHAR(5);
	DEFINE vNum_Notif			INTEGER;
    DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE vCuenta_ctes			INTEGER;
	DEFINE vTotal 				INTEGER;
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
    DEFINE ERROR_INFO 			VARCHAR(80);
	DEFINE RUTA					VARCHAR(50);
	
	
	LET vTotal = 0;
	LET vNumcte = '';
	LET vTarjeta = '';
	LET vEstatus_proceso = '';
	LET vTipo_transaccion = '';
	LET vTipo_tarjeta_carga ='';
	LET vNum_Notif = 0;
	LET vCodigoRetorno = '';
	LET vMensaje = '';
	LET vCuenta_ctes = 0;
	LET RUTA = '/RESPALDOSNEW/';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/ctes_notificados.out";
	--TRACE ON;

	BEGIN
	
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
				SET DEBUG FILE TO RUTA || "sp_registra_ctes_notificados.err.out";
				TRACE ON;
				
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		 
		TRUNCATE TABLE intercard:"informix".tbl_campania_ctes_notificados DROP STORAGE;
		
		SELECT COUNT (*)
			INTO vCuenta_ctes
		FROM intercard:"informix".tbl_campania_notif_tarjeta_ctes
			WHERE estatus_proceso = 'N';
			
		--ValidaciÃ³n en caso que no encuentre registros con estatus N
		
		IF (vCuenta_ctes = 0) THEN 
			
			LET vCodigoRetorno = '00000';
			LET vMensaje = 'No se encontraron clientes con estatus N';
			RETURN vCodigoRetorno, vMensaje;
		
		END IF

		
		FOREACH ctes_notificados WITH HOLD FOR
				
			--Extrae a los clientes notificados
							
		    SELECT a.num_cliente, a.numtarjeta, a.tipo_tarjeta_carga, a.tipo_transacc_carga,pt.campanianotif,
					(a.num_registro_sms + a.num_registro_correo_elec) as total
				INTO vNumcte, vTarjeta, vTipo_tarjeta_carga, vTipo_transaccion,vNum_Notif, vTotal
					FROM intercard:"informix".tbl_campania_notif_tarjeta_ctes a 
			INNER JOIN intercard:"informix".tarjeta t
				ON (a.numtarjeta = t.numtarjeta)
			INNER JOIN intercard:"informix".productotarjeta pt
				ON (t.codproductotarjeta = pt.codproductotarjeta)
			WHERE a.estatus_proceso = 'N' 
				AND a.tipo_transacc_carga IN ('TP', 'TNP')
				AND t.codstatustarjeta IN ('ACT','BLO','BLT')
				
							
			IF (vTotal >= vNum_Notif) THEN
				BEGIN WORK;
					INSERT INTO intercard:"informix".tbl_campania_ctes_notificados
						VALUES( vNumcte, vTarjeta, vTipo_tarjeta_carga, vTipo_transaccion);			
				COMMIT WORK;
			END IF
			
			LET vNum_Notif = 0;
			LET vTotal = 0;
			
		END FOREACH
	
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
		RETURN vCodigoRetorno, vMensaje;
			
	END 
END PROCEDURE;