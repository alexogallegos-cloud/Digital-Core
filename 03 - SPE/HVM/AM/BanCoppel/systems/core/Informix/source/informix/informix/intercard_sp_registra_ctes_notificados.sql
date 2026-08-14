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