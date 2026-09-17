CREATE PROCEDURE "informix".sp_tarj_det_vcas()
	RETURNING VARCHAR(10), VARCHAR(255)

    DEFINE vfecha 		DATETIME YEAR TO FRACTION(5);

	DEFINE cCodRet					CHAR(5);
	DEFINE cEstatus					CHAR(100);
	
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
    DEFINE cNombreArchivo3  CHAR(250);
	DEFINE cNombreArchivo_entrada CHAR(250);

    DEFINE var_action 		CHAR(6);
    DEFINE var_numtarjeta   VARCHAR(16);
    DEFINE var_telefono     CHAR(13);
    DEFINE var_correo_elec 	CHAR(100);
    DEFINE var_fecha        DATETIME YEAR to SECOND;

    -- JUNIO 2024 - Variables para la generacion del reporte respuestas VCAS
    DEFINE var_user_insert_tel    	CHAR(8);
    DEFINE var_fecha_hora_tel     	DATETIME YEAR to SECOND;
    DEFINE var_user_insert_correo 	CHAR(8);
    DEFINE var_fecha_hora_correo  	DATETIME YEAR to SECOND;
    DEFINE var_numcte             	CHAR(13);
    DEFINE fecha_reg              	DATETIME YEAR to SECOND;
	DEFINE var_fecha_hora_correo1 	CHAR (23);
	
	DEFINE respuestaaevaluar CHAR(50);

    DEFINE iContador_pay    		SMALLINT;
	DEFINE iContador_pay1 			SMALLINT;
    DEFINE vreg_ins 				INTEGER;
	
	DEFINE vFlasTransaccion			CHAR(1);
	
	BEGIN

    -- MANEJO DEL ERROR.
    ON EXCEPTION SET sql_err, isam_err, error_info
            
        -- SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_tarj_det_vcas.err.out" WITH APPEND;
        -- TRACE ON;
        
		IF vFlasTransaccion = 'V' THEN
			COMMIT;
			LET vFlasTransaccion = 'F';
		END IF;
		
		-- NOVIEMBRE 2023 - No se crea indice ya que es una tabla de control que solo tiene un registro y no se emplea para realizar JOIN
        UPDATE intercard:ctrl_info_ctes_vcas 
        SET status_proc = '0';

        IF sql_err <> 0 THEN
            LET vcod_ret = sql_err;
			
            UPDATE intercard:ctrl_info_ctes_vcas 
            SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
			
            RETURN vcod_ret, isam_err||' ' ||error_info;
        END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/c90243345/sp_tarj_det_vcas.out";
    --TRACE ON;
	LET cCodRet			= '000';
	LET cEstatus		= 'PROCESO EXITOSO';	
        
    LET vfecha 			= TODAY;
    
	LET vstatus_proc 	= '';
    LET vcod_ret 		= '000';          
    LET sql_err 		= 0;          
    LET isam_err 		= 0;        
    LET error_info 		= '';
    LET iContador_pay 	= 0;
	LET iContador_pay1  = 0;

    LET v_dia           = "";
    LET v_mes           = "";
    LET v_ano           = "";  
    LET v_hora 			= CURRENT;
    LET v_hora2 		= "";
    LET v_sql           = "";

    LET cEncabezado				= "";
    LET cRuta					= "/RESPALDOSNEW/";
    LET cRuta2					= "/RESPALDOSNEW/VCAS_resultados/";
    LET cNombreArchivo			= "";
    LET cNombreArchivo1			= "";
    LET cNombreArchivo2			= "";
    LET cNombreArchivo3			= "";
	LET cNombreArchivo_entrada	= "";

    LET var_action 		= "";
    LET var_numtarjeta  = "";
    LET var_telefono    = "";
    LET var_correo_elec = "";
    LET var_fecha       = CURRENT;
    LET vreg_ins 		= 0;

    -- JUNIO 2024 - Variables para la generacion del reporte respuestas VCAS
    LET var_user_insert_tel    	= "";
    LET var_fecha_hora_tel     	= CURRENT;
    LET var_user_insert_correo 	= "";
    LET var_fecha_hora_correo  	= CURRENT;
    LET var_numcte             	= "";
    LET fecha_reg              	= CURRENT;
	LET var_fecha_hora_correo1  = "";
	LET respuestaaevaluar	   = "";

	LET vFlasTransaccion = 'F';

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--------MARZO 2025 - Se agrega dropeo de tablas temporales en caso de que el proceso se interrumpa de manera extraordinaria en medio del proceso
	
	DROP TABLE IF EXISTS binVISA;
	DROP TABLE IF EXISTS tmpctestarj;
    DROP TABLE IF EXISTS tmptelefono;
    DROP TABLE IF EXISTS tmpcorreo;
	DROP TABLE IF EXISTS tmptarjeta;
    DROP TABLE IF EXISTS tmptarj;
    DROP TABLE IF EXISTS tmpctestarjfin;
	DROP TABLE IF EXISTS temprespuestas;
    
	-- NOVIEMBRE 2023 - No se crea indice ya que es una tabla de control que solo tiene un registro y no se emplea para realizar JOIN
    SELECT status_proc	
        INTO vstatus_proc
    FROM intercard:ctrl_info_ctes_vcas;
	
    IF(vstatus_proc = '1') THEN
		
		-- NOVIEMBRE 2023 - No se crea indice ya que es una tabla de control que solo tiene un registro y no se emplea para realizar JOIN
        UPDATE intercard:ctrl_info_ctes_vcas
        SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
        
        RETURN vcod_ret, 'DESCARGA EN PROCESO';
		
    END IF;
    
	-- NOVIEMBRE 2023 - No se crea indice ya que es una tabla de control que solo tiene un registro y no se emplea para realizar JOIN
    UPDATE intercard:ctrl_info_ctes_vcas 
	SET status_proc = '1';  
    
	-- NOVIEMBRE 2023 - No se crea incide ya que es una tabla de control que solo tiene un registro y no se emplea para realizar JOIN
    SELECT fecha
        INTO vfecha
    FROM intercard:ctrl_info_ctes_vcas;

	-- Se eliminan registros de la tabla de resultado en caso de que haya fallado del SP y haya generado informacion.
	TRUNCATE TABLE intercard:ctas_vcas;

	-- Se crean tablas temporales para poder llegar al resultado final
	-- Considerando que vamos a traer informacion de la ultima hora es que se especifica la volumetria en las respectivas tablas temporales
	
	-- El maximo de registros que se esperan traer es de 1 a 10000 registros, correspondiente a la asignacion de TDD/TDC que 
	-- puede haber en un dia o cada hora dependiendo del tipo de ejecucion que se realice
	-- JUNIO 2024 - Se cambia dependencia de la tabla intercard:info_tarjeta_pyt
	SELECT numtarjeta, fechaasignacion
    FROM intercard:info_tarjeta_vcas
	WHERE fechaasignacion >= vfecha
	INTO temp tmptarj WITH NO LOG;

    CREATE INDEX tmp_tartarj_vcas ON tmptarj(numtarjeta) ONLINE;
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmptarj; 

	-- Indice ya existe
	-- La tabla temporal no requiere indice ya que solo se usa para validar bines en general
    SELECT bin 
    FROM intercard:bines 
    WHERE bin IN ('400819', '426807', '559471', '554948', '510148', '416916')
    INTO temp binVISA WITH NO LOG;
    
    -- Se traen datos de Tarjetas de Credito
	-- El maximo de registros que se esperan traer es de 1000 a 2000 registros 
    SELECT {+INDEX(bdicred:sd_tarjeta idx_tarjeta1)} -- Indice ya existe
		numcte, num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE num_tarjeta IN 
	(
		SELECT numtarjeta 
		FROM tmptarj 
	)
	AND empresa= '001'  
    INTO temp tmpctestarj WITH NO LOG;

    -- Se traen datos de Tarjetas de Debito
	-- El maximo de registros que se esperan traer es de 1000 a 2000 registros  
    INSERT INTO tmpctestarj
    SELECT {+INDEX(bdicheq:sc_tarjeta ix_tarjeta2)} -- Indice ya existe
		numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' 
	AND num_tarjeta IN (
		SELECT numtarjeta 
		FROM tmptarj 
	);
	
	CREATE INDEX tmp_cte_pt ON tmpctestarj(numcte, num_tarjeta) ONLINE;
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmpctestarj; 

	-- Se traen los datos de telefonos tipo 2
	-- Se cambia indice idx_telact_ctetipo por idx_telact_cte_cons
	-- JUNIO 2024 - Se actualiza query para obtener los campos user_insert, fecha_hora de clientes
	SELECT {+INDEX(bdinteg:si_telefonos_actual idx_telact_cte_cons)} -- Indice ya existe
		numcte, telefono, user_insert, fecha_hora
    FROM bdinteg:si_telefonos_actual
	WHERE numcte IN 
	(
		SELECT numcte 
		FROM tmpctestarj 
	)
	AND tipo_tel = 2
	AND status_tel = 'A' 
    INTO temp tmptelefono WITH NO LOG;

    CREATE INDEX tmptelefono_idx1 ON tmptelefono(numcte, telefono) ONLINE;
    CREATE INDEX tmptelefono_idx2 ON tmptelefono(numcte) ONLINE;
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmptelefono; 

    -- Se traen los datos de los correos tipo 1
    -- Se actualiza query para obtener los campos user_insert, fecha_hora de correos
	-- NOVIEMBRE 2023 - Por indicacion de prevencion de fraudes se quita la validacion del campo valido con el fin de obtener todos los correos de los clientes que esten registrados
	SELECT {+INDEX(bdinteg:si_correos idx_corr_cte_cons)} -- Indice ya existe
		numcte, correo_elec, user_insert, fecha_hora
    FROM bdinteg:si_correos
	WHERE numcte IN 
	(
		SELECT numcte 
		FROM tmpctestarj
	)
	AND tipo_correo = 1 
	AND status_correo = 'A'
	INTO temp tmpcorreo WITH NO LOG;
	
    CREATE INDEX tmp_correlec_vcas ON tmpcorreo(numcte, correo_elec) ONLINE;
    CREATE INDEX tmp_numctecorr_vcas ON tmpcorreo(numcte) ONLINE;
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmpcorreo; 

    -- Se crea tabla con el numero de cuentas y numero de tarjeta tipo credito 
    SELECT {+INDEX(bdicred:sd_tarjeta idx_sd_tarjeta_03)}
		numcte, num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' 
	AND numcte IN 
	(
		SELECT numcte
		FROM tmpcorreo 
		UNION ALL 
		SELECT numcte 
		FROM tmptelefono
	)
    INTO temp tmpctestarjfin WITH NO LOG; 

    -- Se crea tabla con el numero de cuentas y numero de tarjeta tipo debito 
    INSERT INTO tmpctestarjfin
    SELECT {+INDEX(sc_tarjeta idx_sc_tarjeta_01)}
		numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa = '001' 
	AND numcte IN 
	(
		SELECT numcte
		FROM tmpcorreo 
		UNION ALL 
		SELECT numcte 
		FROM tmptelefono
	);
	
	CREATE INDEX tmp_cte_pts ON tmpctestarjfin(numcte,num_tarjeta) ONLINE;
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmpctestarjfin;
	
	-- Se crea tabla con las cuentas full 
	-- JUNIO 2024 - Se cambia dependencia de la tabla intercard:info_tarjeta_pyt
    SELECT {+INDEX(intercard:info_tarjeta_vcas idx_info_tarjeta_vcas_01)}
		A.numtarjeta, A.fechaasignacion, B.numcte
    FROM intercard:info_tarjeta_vcas A, tmpctestarjfin B
    WHERE A.numtarjeta = B.num_tarjeta
    GROUP BY A.numtarjeta, A.fechaasignacion, B.numcte
    INTO temp tmptarjeta WITH NO LOG; 

    CREATE INDEX tmp_numtarj_vcas ON tmptarjeta(numcte,numtarjeta) ONLINE;
    CREATE INDEX tmp_fechasig_vcas ON tmptarjeta(fechaasignacion) ONLINE;
	
	UPDATE STATISTICS MEDIUM FOR TABLE tmptarjeta;
	
	---Generacion de archivo para llenado de tabla info_credenciales_vcas
    LET v_dia = LPAD(DAY(CURRENT),2,'0');  
	LET v_mes = LPAD(MONTH(CURRENT),2,'0');
	LET v_ano = YEAR(CURRENT);
    LET v_hora2 = v_hora::CHAR(8);
	LET cNombreArchivo = 'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';

    -- Generacion de infomacion para el reporte de VCAS, en este caso cada hora desde las 10:00 hasta las 23:00 
    BEGIN WORK;
	LET vFlasTransaccion = 'V';
	
        FOREACH WITH HOLD
            SELECT 
                CASE 
                    WHEN A.fechaasignacion >= vfecha THEN 'ADD' 
					ELSE 'UPDATE' 
				END AS action,
                A.numtarjeta,
                A.numcte,
				B.telefono AS telefono,
				B.user_insert AS usuario_alta_telefono,
				B.fecha_hora AS  fecha_alta_telefono,
                C.correo_elec AS correo_elec,
                CURRENT AS fecha,
                C.user_insert AS usuario_alta_correo,
                C.fecha_hora AS fecha_alta_correo
                INTO var_action, var_numtarjeta, var_numcte, var_telefono,  var_user_insert_tel, var_fecha_hora_tel,
                     var_correo_elec, var_fecha, var_user_insert_correo, var_fecha_hora_correo1
            FROM tmptarjeta A
            LEFT JOIN tmptelefono B 
			ON A.numcte	= B.numcte
            LEFT JOIN tmpcorreo C 
			ON A.numcte = C.numcte
            WHERE SUBSTR(A.numtarjeta,1,6) IN 
			( 
				SELECT bin 
				FROM binVISA 
			)
            AND( (B.telefono IS NOT NULL) OR (C.correo_elec IS NOT NULL) )            
            GROUP BY A.numtarjeta, B.telefono, C.correo_elec, fecha, action, A.numcte, usuario_alta_telefono, fecha_alta_telefono, usuario_alta_correo, fecha_alta_correo
            ORDER BY A.numtarjeta

            LET iContador_pay = iContador_pay + 1;
			LET iContador_pay1 = iContador_pay1 + 1;
			
			LET var_fecha = var_fecha;
			LET var_action = TRIM(var_action);
			LET var_numtarjeta = TRIM(var_numtarjeta);
			LET var_numcte = TRIM(var_numcte);
			LET var_telefono = TRIM(var_telefono);
			LET var_user_insert_tel = TRIM(var_user_insert_tel);
			LET var_fecha_hora_tel = var_fecha_hora_tel;
			LET var_correo_elec = TRIM(var_correo_elec);
			LET var_user_insert_correo = TRIM(var_user_insert_correo);
			LET var_fecha_hora_correo1 = var_fecha_hora_correo1;
			
			-- ENERO 2025 Se agrega validacion para crear archivo con los datos que tengan esa etiqueta y guardar en ctas_vcas para su reenvio 06/11/2024
			
			SELECT TRIM(respuesta) AS respuesta, fecha_registro
			FROM info_credenciales_vcas
			WHERE numero_tarjeta = var_numtarjeta
			ORDER BY fecha_registro DESC
			INTO temp temprespuestas with no log;
			
			SELECT FIRST 1 respuesta
			INTO respuestaaevaluar
			FROM temprespuestas;
			

			IF respuestaaevaluar like '%NO_CONSUMER_ACCOUNT_FOUND_FOR_PAN%' THEN
				LET var_action='ADD';
			END IF;
				
            INSERT INTO ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha, linea)
            VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha, iContador_pay1);

            --Se guarda informacion en la tabla info_credenciales_vcas
			--Se valida que el registro correo no sea nulo para poder castear la valor de fecha
			IF var_fecha_hora_correo1 IS NULL THEN
				LET var_fecha_hora_correo = var_fecha_hora_correo1;
			ELSE             			
				LET var_fecha_hora_correo = TO_DATE(var_fecha_hora_correo1[1,19],'%Y-%m-%d %H:%M:%S');
			END IF
			
            LET fecha_reg = CURRENT;
			
			-- Se guarda informacion en la tabla info_credenciales_vcas
            INSERT INTO info_credenciales_vcas
			(
				fecha_alta_correo, usuario_alta_correo, correo, fecha_alta_telefono, usuario_alta_telefono,telefono,
				numero_cliente, numero_tarjeta, nombre_archivo, linea_dato, respuesta, fecha_registro
			) VALUES 
			(         
			   var_fecha_hora_correo, var_user_insert_correo,var_correo_elec, var_fecha_hora_tel, var_user_insert_tel,
			   var_telefono, var_numcte, var_numtarjeta, cNombreArchivo, iContador_pay1,"",fecha_reg
            );
               
            IF iContador_pay = 1000 THEN
                COMMIT;
				LET vFlasTransaccion = 'F';
                LET iContador_pay = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE ctas_vcas;
                BEGIN WORK;
				LET vFlasTransaccion = 'V';
            END IF;
			
		DROP TABLE IF EXISTS temprespuestas;
		
        END FOREACH;
    COMMIT;
	LET vFlasTransaccion = 'F';

    UPDATE STATISTICS MEDIUM FOR TABLE ctas_vcas;
	
	
	-- ENERO 2025 Todos los SP de VCAS descargan informacion de la tabla de paso por lo que se genera un proceso comun para todos y asi reducir y reutilizar codigo
		-- Por tanto, si la tabla de paso tiene registros se procede a descargar el reporte para su envio a VISA
	IF (( SELECT COUNT(*) FROM intercard:ctas_vcas) > 0 ) THEN 		
		EXECUTE PROCEDURE intercard:sp_descarga_credenciales_vcas(TRIM(cNombreArchivo)) INTO cCodRet, cEstatus;
	ELSE
		LET cEstatus = 'SIN INFORMACION A DESCARGAR';
	END IF;
	
	-- Se eliminan los registros de las tablas temporales
	DROP TABLE IF EXISTS binVISA;
	DROP TABLE IF EXISTS tmpctestarj;
    DROP TABLE IF EXISTS tmptelefono;
    DROP TABLE IF EXISTS tmpcorreo;
	DROP TABLE IF EXISTS tmptarjeta;
    DROP TABLE IF EXISTS tmptarj;
    DROP TABLE IF EXISTS tmpctestarjfin;
	DROP TABLE IF EXISTS temprespuestas;
	
	TRUNCATE TABLE ctas_vcas drop storage;
	
	------------MARZO 2025 - Se agrega la actualizacion correcta para la fecha de la tabla control
	
	SELECT MAX(fecha::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND )
	into vfecha
    FROM intercard:ctas_vcas;

	IF vfecha IS NULL THEN
		LET vfecha = CURRENT;
	END IF;
	
	UPDATE intercard:ctrl_info_ctes_vcas
	SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados ) = ( vfecha, '0', 'DESCARGA EN PROCESO', 'DESCARGA EXITOSA', iContador_pay1);	
	
	UPDATE intercard:ctrl_info_ctes_vcas 
	SET status_proc = '0';  
	
    RETURN cCodRet, cEstatus;
	
	END;

END PROCEDURE
DOCUMENT
'Modificacion: 15/11/2023',
'Autor: Humberto Daniel Reza Teran',
'Descripcion: SP que genera un reporte para VISA con las nuevas tarjetas asignadas, con el numero telefonico y/o correo actual.',
'Modificacion: 11/06/2024',
'Autor: Eduardo Mozo Flores - Maria Fernanda Ortiz Figueroa',
'Descripcion: Se ajusta la referencia de rutas de paso, asi como la adicion de consideraciones para la generacion del reporte con la respuesta de lo enviado a VISA',
'Modificacion: 21/01/2025',
'Autor: Estefania Obregon Catillo - Christopher Jose Leyva Castro',
'Descripcion: Se realiza el ajuste para manejar el error de envio de actualizacion de informacion siendo que deberia agregarse la informacion NO_CONSUMER_ACCOUNT_FOUND_FOR_PAN dada la confirmacion de PDF';

CREATE PROCEDURE "informix".sp_tarj_det_vcas_ext()
	RETURNING VARCHAR(10) AS CODIGO_RETORNO, VARCHAR(255) AS MENSAJE_RETORNO;

    DEFINE vfecha 			DATETIME YEAR TO FRACTION(5);
    DEFINE vfechaAnterior 	DATETIME YEAR TO FRACTION(5);
	
	DEFINE cCodRet					CHAR(5);
	DEFINE cEstatus					CHAR(100);

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
    DEFINE cNombreArchivo3  CHAR(250);
	DEFINE cnombrearchivo_entrada CHAR(250);

    DEFINE var_action 		CHAR(6);
    DEFINE var_numtarjeta   VARCHAR(16);
    DEFINE var_telefono     CHAR(13);
    DEFINE var_correo_elec 	CHAR(100);
    DEFINE var_fecha        DATETIME YEAR TO SECOND;


    -- JUNIO 2024 - Variables para la generacion del reporte respuestas VCAS
    DEFINE var_user_insert_tel    CHAR(8);
    DEFINE var_fecha_hora_tel     DATETIME YEAR to SECOND;
    DEFINE var_user_insert_correo CHAR(8);
    DEFINE var_fecha_hora_correo  DATETIME YEAR to SECOND;
    DEFINE var_numcte             CHAR(13);
    DEFINE fecha_reg              DATETIME YEAR to SECOND;
    DEFINE var_fecha_hora_correo1 CHAR (23);
	
	DEFINE respuestaaevaluar CHAR(50);

    DEFINE iContador_pay    SMALLINT;
    DEFINE iContador_pay1	SMALLINT;
    DEFINE vreg_ins 		INTEGER;
	
	DEFINE vFlasTransaccion	CHAR(1);

    LET vfecha 			= TODAY;
    LET vfechaAnterior 	= TODAY;
    LET vstatus_proc 	= '';
	
	LET cCodRet = '000';
	LET cEstatus= 'PROCESO EXITOSO';

    LET vcod_ret 		= '000';          
    LET sql_err 		= 0;          
    LET isam_err 		= 0;        
    LET error_info 		= '';
    LET iContador_pay 	= 0;
    LET iContador_pay1  = 0;

    LET v_dia           = "";
    LET v_mes           = "";
    LET v_ano           = "";  
    LET v_hora 			= CURRENT;
    LET v_hora2 		= "";
    LET v_sql           = "";

    LET cEncabezado     = "";
    LET cRuta 			= "/RESPALDOSNEW/";
    LET cRuta2 			= "/RESPALDOSNEW/VCAS_resultados/";
    LET cNombreArchivo 	= "";
    LET cNombreArchivo1 = "";
    LET cNombreArchivo2 = "";
    LET cNombreArchivo3 = "";
	LET cNombreArchivo_entrada = "";

    LET var_action 		= "";
    LET var_numtarjeta  = "";
    LET var_telefono    = "";
    LET var_correo_elec = "";
    LET var_fecha       = CURRENT;
    LET vreg_ins 		= 0;

    -- JUNIO 2024 - Variables para la generacion del reporte respuestas VCAS
    LET var_user_insert_tel    = "";
    LET var_fecha_hora_tel     = CURRENT;
    LET var_user_insert_correo = "";
    LET var_fecha_hora_correo  = CURRENT;
    LET var_numcte             = "";
    LET fecha_reg              = CURRENT;
    LET var_fecha_hora_correo1 ="";
	LET respuestaaevaluar	   = "";
	
	LET vFlasTransaccion = 'F';

	BEGIN

		-- MANEJO DEL ERROR
		ON EXCEPTION SET sql_err, isam_err, error_info
				
        --SET DEBUG FILE TO "/RESPALDOSNEW/sp_tarj_det_vcas_err.out" WITH APPEND;
        --TRACE ON;
			
			IF vFlasTransaccion = 'V' THEN
				COMMIT;
				LET vFlasTransaccion = 'F';
			END IF;
			
			-- NOVIEMBRE 2023 - No se crea indice ya que es una tabla de control que solo tiene un registro y no se emplea para realizar JOIN
			UPDATE intercard:ctrl_info_ctes_vcas_ext 
			SET status_proc = '0';
	
			IF sql_err <> 0 THEN
				LET vcod_ret = sql_err;
				
				UPDATE intercard:ctrl_info_ctes_vcas_ext 
				SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
				
				RETURN vcod_ret, isam_err|| ' ' ||error_info;
			END IF;
			
		END EXCEPTION;
	
		SET DEBUG FILE TO "/RESPALDOSNEW/debug_sp_tarj_det_vcas.out";
        TRACE ON;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--------MARZO 2025 - Se agrega dropeo de tablas temporales en caso de que el proceso se interrumpa de manera extraordinaria en medio del proceso
		
		DROP TABLE IF EXISTS binVISA;
		DROP TABLE IF EXISTS tmptelefono;
		DROP TABLE IF EXISTS tmpcorreo;
		DROP TABLE IF EXISTS tmptarjeta_aux;
		DROP TABLE IF EXISTS tmptarjeta;
		DROP TABLE IF EXISTS tmpctestarjfin;
		DROP TABLE IF EXISTS tmpcorreo_2;
		DROP TABLE IF EXISTS temprespuestas;
		
		-- NOVIEMBRE 2023 - No se crea indice ya que es una tabla de control que solo tiene un registro y no se emplea para realizar JOIN
		SELECT status_proc
			INTO vstatus_proc
		FROM intercard:ctrl_info_ctes_vcas_ext;
		
		IF (vstatus_proc = '1') THEN
			-- NOVIEMBRE 2023 - No se crea indice ya que es una tabla de control que solo tiene un registro y no se emplea para realizar JOIN
			UPDATE intercard:ctrl_info_ctes_vcas_ext
			SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
			
			RETURN vcod_ret, 'DESCARGA EN PROCESO';
		END IF;
		
		-- NOVIEMBRE 2023 - No se crea indice ya que es una tabla de control que solo tiene un registro y no se emplea para realizar JOIN
		UPDATE intercard:ctrl_info_ctes_vcas_ext 
		SET status_proc = '1';  
		
		-- Se obtienen los rangos de fecha para la ejecucion del proceso
		SELECT fecha, fecha_anterior
			INTO vfecha, vfechaAnterior
		FROM intercard:ctrl_info_ctes_vcas_ext;
	
		-- Se eliminan registros de la tabla de resultado en caso de que haya fallado el SP y haya generado informacion
		TRUNCATE TABLE intercard:ctas_vcas;
	
		-- Se crean tablas temporales para poder llegar al resultado final
		-- Considerando que vamos a traer informacion de la ultima hora es que se especifica la volumetria en las respectivas tablas temporales
		
		-- La tabla temporal no requiere indice ya que solo se usa para validar bines en general
		SELECT bin 
		FROM intercard:bines 
		WHERE bin IN ('400819', '426807', '559471', '554948', '510148', '416916')
		INTO temp binVISA WITH NO LOG;
				
		-- Se traen los datos de telefonos tipo 2 actualizados por dia
		-- Se retira directiva por costos altos 06/12/2023
		-- JUNIO 2024 - Se actualiza query para obtener los campos user_insert, fecha_hora
		SELECT /*{+INDEX(bdinteg:si_telefonos_actual idx_tel_act)}*/ -- Indice ya existe
			numcte, telefono, user_insert, fecha_hora
		FROM bdinteg:si_telefonos_actual
		WHERE numcte IS NOT NULL
		AND fecha_hora >= vfechaAnterior AND fecha_hora <= vfecha
		AND tipo_tel = 2
		AND status_tel = 'A'
		INTO temp tmptelefono WITH NO LOG;
		
		CREATE INDEX tmptelefono_idx1 ON tmptelefono(numcte, telefono) ONLINE;
		CREATE INDEX tmptelefono_idx2 ON tmptelefono(numcte) ONLINE;
		
		UPDATE STATISTICS MEDIUM FOR TABLE tmptelefono; 
	
		-- Se traen los datos de los correos tipo 1 actualizados por dia
		-- Se retira directiva por costos altos 06/12/2023
		-- JUNIO 2024 - Se actualiza query para obtener los campos user_insert, fecha_hora
		-- ENERO 2025 - Se retira la validacion del numero de cuenta para que filtre directamente por fecha
		SELECT /*{+INDEX(bdinteg:si_correos idx_si_correos8)}*/ -- Indice ya existe
			numcte, correo_elec, user_insert, fecha_hora
		FROM bdinteg:si_correos
		WHERE fecha_hora >= vfechaAnterior AND fecha_hora <= vfecha
		AND status_correo = 'A'
		AND tipo_correo = 1 
		INTO temp tmpcorreo WITH NO LOG;
		
		CREATE INDEX tmp_correlec_vcas ON tmpcorreo(numcte, correo_elec) ONLINE;
		CREATE INDEX tmp_numctecorr_vcas ON tmpcorreo(numcte) ONLINE;
		
		UPDATE STATISTICS MEDIUM FOR TABLE tmpcorreo; 
	
		-- Se crea tabla con el numero de cuentas y numero de tarjeta tipo credito 
		SELECT {+INDEX(bdicred:sd_tarjeta idx_sd_tarjeta_03)}
			numcte, num_tarjeta
		FROM bdicred:sd_tarjeta
		WHERE empresa= '001' 
		AND numcte IN 
		(
			SELECT numcte
			FROM tmpcorreo 
			UNION 
			SELECT numcte 
			FROM tmptelefono
		)
		INTO temp tmpctestarjfin WITH NO LOG; 
	
		-- Se crea tabla con el numero de cuentas y numero de tarjeta tipo debito 
		INSERT INTO tmpctestarjfin
		SELECT {+INDEX(sc_tarjeta idx_sc_tarjeta_01)}
			numcte, num_tarjeta
		FROM bdicheq:sc_tarjeta
		WHERE empresa = '001' 
		AND numcte IN 
		(
			SELECT numcte
			FROM tmpcorreo 
			UNION 
			SELECT numcte 
			FROM tmptelefono
		);
		
		CREATE INDEX tmp_cte_pts ON tmpctestarjfin(numcte,num_tarjeta) ONLINE;
		
		UPDATE STATISTICS MEDIUM FOR TABLE tmpctestarjfin;
		
		-- Se crea tabla con las cuentas full
		-- JUNIO 2024 - Se cambia dependencia de la tabla intercard:info_tarjeta_pyt
		SELECT {+INDEX(intercard:info_tarjeta_vcas idx_info_tarjeta_vcas_01)}
			A.numtarjeta, A.fechaasignacion, B.numcte
		FROM intercard:info_tarjeta_vcas AS A 
		INNER JOIN tmpctestarjfin AS B 
		ON A.numtarjeta = B.num_tarjeta 
		GROUP BY A.numtarjeta, A.fechaasignacion, B.numcte
		INTO temp tmptarjeta_aux WITH NO LOG;
		
		CREATE INDEX tmp_fechasig_vcas_aux ON tmptarjeta_aux(fechaasignacion) ONLINE; 

		UPDATE STATISTICS MEDIUM FOR TABLE tmptarjeta_aux;

		SELECT numtarjeta, fechaasignacion, numcte
		FROM tmptarjeta_aux 
		WHERE fechaasignacion < vfechaAnterior
		INTO temp tmptarjeta WITH NO LOG;

		CREATE INDEX tmp_numtarj_vcas ON tmptarjeta(numcte,numtarjeta) ONLINE;
		CREATE INDEX tmp_fechasig_vcas ON tmptarjeta(fechaasignacion) ONLINE; 
		
		UPDATE STATISTICS MEDIUM FOR TABLE tmptarjeta;
		
		-- ENERO 2025 Se crea tabla de paso que contendra de 1 a 10 registros para realizar la valdiacion demas de un correo valido hacia un cliente y evitar error en el proceso
		CREATE TABLE IF NOT EXISTS tmpcorreo_2
		(
			correo_elec		CHAR(100),
			secuencia		SMALLINT
		);

		-- Generacion de nuevo archivo
   		LET v_dia = LPAD(DAY(CURRENT),2,'0');  
		LET v_mes = LPAD(MONTH(CURRENT),2,'0');
		LET v_ano = year(CURRENT);
    	LET v_hora2 = v_hora::CHAR(8);
		LET cNombreArchivo = 'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';

		-- Generacion de infomacion para el reporte de VCAS, una vez al dia a las 03:30
		BEGIN WORK;
		LET vFlasTransaccion = 'V';
		
			FOREACH WITH HOLD
				SELECT 
					CASE 
						WHEN A.fechaasignacion >= vfecha THEN 'ADD' 
						ELSE 'UPDATE' 
					END AS action,
					A.numtarjeta,
					A.numcte,
					B.telefono AS telefono,
					B.user_insert AS usuario_alta_telefono,
				    B.fecha_hora AS  fecha_alta_telefono,
					C.correo_elec AS correo_elec,
					CURRENT AS fecha,
					C.user_insert AS usuario_alta_correo,
                    C.fecha_hora AS fecha_alta_correo
					INTO var_action, var_numtarjeta, var_numcte, var_telefono,  var_user_insert_tel, var_fecha_hora_tel,
                     var_correo_elec, var_fecha, var_user_insert_correo, var_fecha_hora_correo1
				FROM tmptarjeta A
				LEFT JOIN tmptelefono B 
				ON A.numcte	= B.numcte
				LEFT JOIN tmpcorreo C 
				ON A.numcte = C.numcte
				WHERE SUBSTR(A.numtarjeta,1,6) IN 
				( 
					SELECT bin 
					FROM binVISA 
				)
				AND( (B.telefono IS NOT NULL) OR (C.correo_elec IS NOT NULL) )            
				GROUP BY A.numtarjeta, B.telefono, C.correo_elec, fecha, action, A.numcte,usuario_alta_telefono,fecha_alta_telefono,usuario_alta_correo,fecha_alta_correo
				ORDER BY A.numtarjeta,A.numcte
				
				IF var_telefono IS NULL THEN
				
					SELECT {+INDEX(bdinteg:si_telefonos_actual idx_telact_cte_cons)}
						telefono
					INTO var_telefono
					FROM bdinteg:si_telefonos_actual
					WHERE numcte = var_numcte
					AND tipo_tel = 2
					AND status_tel = 'A';
				
				END IF;
				
				IF var_correo_elec IS NULL THEN
				
					DELETE FROM tmpcorreo_2;

					INSERT INTO tmpcorreo_2
					SELECT {+INDEX(bdinteg:si_correos idx_corr_cte_cons)}
						correo_elec, secuencia
					FROM bdinteg:si_correos
					WHERE numcte = var_numcte
					AND tipo_correo = 1 
					AND status_correo = 'A';

					SELECT correo_elec
					INTO var_correo_elec
					FROM tmpcorreo_2
					WHERE secuencia = 
					(
						SELECT MAX(secuencia)
						FROM tmpcorreo_2
					);
							
				END IF;
					
				LET iContador_pay = iContador_pay + 1;
				LET iContador_pay1 = iContador_pay1 + 1;
				
				LET var_fecha				= var_fecha;
				LET var_action				= TRIM(var_action);
				LET var_numtarjeta			= TRIM(var_numtarjeta);
				LET var_numcte				= TRIM(var_numcte);
				LET var_telefono			= TRIM(var_telefono);
				LET var_user_insert_tel		= TRIM(var_user_insert_tel);
				LET var_fecha_hora_tel		= var_fecha_hora_tel;
				LET var_correo_elec			= TRIM(var_correo_elec);
				LET var_user_insert_correo	= TRIM(var_user_insert_correo);
				LET var_fecha_hora_correo1	= var_fecha_hora_correo1;
				
				-- ENERO 2025 Se agrega validacion para crear archivo con los datos que tengan esa etiqueta y guardar en ctas_vcas para su reenvio 06/11/2024
					
				SELECT TRIM(respuesta) AS respuesta, fecha_registro
				FROM info_credenciales_vcas
				WHERE numero_tarjeta = var_numtarjeta
				ORDER BY fecha_registro DESC
				INTO temp temprespuestas with no log;
				
				SELECT FIRST 1 respuesta
				INTO respuestaaevaluar
				FROM temprespuestas;
				

				IF respuestaaevaluar like '%NO_CONSUMER_ACCOUNT_FOUND_FOR_PAN%' THEN
					LET var_action='ADD';
				END IF;
			
				INSERT INTO ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha, linea)
				VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha, iContador_pay1);

                IF var_fecha_hora_correo1 IS NULL THEN
			  		LET var_fecha_hora_correo = var_fecha_hora_correo1;
				ELSE             			
            		Let var_fecha_hora_correo = to_date(var_fecha_hora_correo1[1,19],'%Y-%m-%d %H:%M:%S');
				END IF
                
                LET fecha_reg = CURRENT;
                
                -- Se guarda informacion en la tabla info_credenciales_vcas
                INSERT INTO info_credenciales_vcas
				(
					fecha_alta_correo, usuario_alta_correo, correo, 
            		fecha_alta_telefono, usuario_alta_telefono,telefono,
            		numero_cliente, numero_tarjeta, nombre_archivo,
            	    linea_dato, respuesta, fecha_registro
				)
                VALUES 
				(         
					var_fecha_hora_correo, var_user_insert_correo, var_correo_elec,
                    var_fecha_hora_tel, var_user_insert_tel, var_telefono,
                    var_numcte, var_numtarjeta, cNombreArchivo, iContador_pay1,"",fecha_reg
                );
				
				IF iContador_pay = 1000 THEN
					COMMIT;
					LET vFlasTransaccion = 'F';
					LET iContador_pay = 0;
					UPDATE STATISTICS MEDIUM FOR TABLE ctas_vcas;
					BEGIN WORK;
					LET vFlasTransaccion = 'V';
				END IF;
				
			DROP TABLE temprespuestas;
			END FOREACH;
		COMMIT;
		LET vFlasTransaccion = 'F';
	
		UPDATE STATISTICS MEDIUM FOR TABLE ctas_vcas;
		
		
		-- ENERO 2025 Todos los SP de VCAS descargan informacion de la tabla de paso por lo que se genera un proceso comun para todos y asi reducir y reutilizar codigo
		-- Por tanto, si la tabla de paso tiene registros se procede a descargar el reporte para su envio a VISA
		IF (( SELECT COUNT(*) FROM intercard:ctas_vcas) > 0 ) THEN 		
			EXECUTE PROCEDURE intercard:sp_descarga_credenciales_vcas(TRIM(cNombreArchivo)) INTO cCodRet, cEstatus;
		ELSE
			LET cEstatus = 'SIN INFORMACION A DESCARGAR';
		END IF;
		
		-- Se eliminan los registros de las tablas temporales
		DROP TABLE binVISA;
		DROP TABLE tmptelefono;
		DROP TABLE tmpcorreo;
		DROP TABLE tmptarjeta_aux;
		DROP TABLE tmptarjeta;
		DROP TABLE tmpctestarjfin;
		DROP TABLE tmpcorreo_2;
		
		TRUNCATE TABLE ctas_vcas drop storage;
		
		-- DATOS PARA LA TABLA CONTROL.
        LET vfecha = vfecha + 1 UNITS DAY;
        LET vfechaAnterior = vfechaAnterior + 1 UNITS DAY;
		
        -- ACTUALIZAR TABLA CONTROL.
        UPDATE intercard:ctrl_info_ctes_vcas_ext
        SET ( fecha, fecha_anterior, status_proc, cod_err, descripcion_err, reg_insertados ) = ( vfecha, vfechaAnterior, '0', vcod_ret, 'DESCARGA EXITOSA', iContador_pay1 );

		UPDATE intercard:ctrl_info_ctes_vcas_ext 
		SET status_proc = '0';  

		RETURN cCodRet, cEstatus;

	END;
	
END PROCEDURE
DOCUMENT
'Creacion: 15/11/2023',
'Autor: Humberto Daniel Reza Teran, Maria Fernanda Ortiz Figueroa',
'Descripcion: SP que genera un reporte para VISA con las tarjetas de los clientes que actualizaron su numero telefonicos y/o correo en el ultimo dia.',
'Modificacion: 11/05/2024',
'Autor: Eduardo Mozo Flores, Maria Fernanda Ortiz Figueroa',
'Descripcion: Se ajusta la referencia de rutas de paso, asi como la adicion de consideraciones para la generacion del reporte con la respuesta de lo enviado a VISA',
'Modificacion: 21/01/2025',
'Autor: Estefania Obregon Catillo - Christopher Jose Leyva Castro',
'Descripcion: Se realiza el ajuste para manejar el error de envio de actualizacion de informacion siendo que deberia agregarse la informacion NO_CONSUMER_ACCOUNT_FOUND_FOR_PAN dada la confirmacion de PDF';

CREATE PROCEDURE "informix".sp_cierre_sucursal(inClaveSucursalOrigen VARCHAR(5), inClaveSucursalDestino VARCHAR(5), tipoProceso CHAR(1))
--	tipoProceso 
--		N = Proceso de aplicacion normal
--		R = Reverso 

RETURNING CHAR(5) AS outCodigoRetorno, CHAR(100) AS outMensajeRetorno;

	-- Variables manejo de errores
	DEFINE iIsamErr						INTEGER;
	DEFINE iErrorInfo					CHAR(40);
	DEFINE iSqlErr						INTEGER;
	DEFINE cCodigoRetorno				CHAR(5);
	DEFINE cMensajeRetorno				CHAR(100);
	
	-- Variables usadas en el proceso
	DEFINE vFlagTransaccion					CHAR(1);
	DEFINE vCommit							INTEGER;
	DEFINE vContadorCommit					INTEGER;
	DEFINE vClaveSucursalOrigen				VARCHAR(5);
	DEFINE vLote							INTEGER;
	DEFINE vConsecutivoSolicitud			INTEGER;
	DEFINE vCantidadTarjetasOrigen			INTEGER;
	DEFINE vCantidadTarjetasEncontradas		INTEGER;
	DEFINE vFecha							DATETIME YEAR to FRACTION(5);


	-- Inicializacion de variables manejo de error
	LET iIsamErr						= 0;
	LET iErrorInfo						= '';
	LET iSqlErr							= 0;
	LET cCodigoRetorno					= '00000';
	LET cMensajeRetorno					= 'PROCESO EXITOSO';

	-- Inicializacion de variables usadas en el proceso
	LET vFlagTransaccion				= 'F';
	LET vCommit							= 1000;
	LET vContadorCommit					= 0;
	LET vClaveSucursalOrigen			= '';
	LET vLote							= 0;
	LET vConsecutivoSolicitud			= 0;
	LET vCantidadTarjetasOrigen 		= 0;
	LET vCantidadTarjetasEncontradas	= 0;
	LET vFecha							= CURRENT;
	
	--SET DEBUG FILE TO "/home/c90265232/trace_manual_err_" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
	--TRACE ON;
	
	BEGIN
	
		-- Manejo de error
		ON EXCEPTION SET iSqlErr, iIsamErr, iErrorInfo
			
			-- SET DEBUG FILE TO "/home/c90265232/trace_manual_err_" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
			-- TRACE ON;


			-- En caso de error se certifica cerrar/terminar la transaccion iniciada a fin de no deja run proceso colgado
			IF vFlagTransaccion = 'V' THEN
				COMMIT;
				LET vFlagTransaccion = 'F';
			END IF;
			
			IF iSqlErr <> 0 THEN
				LET cCodigoRetorno = iSqlErr;
				LET cMensajeRetorno = 'ERROR EN EL PROCESO ' || iIsamErr || ' ' || iErrorInfo;
				RETURN cCodigoRetorno, cMensajeRetorno;
			END IF;
			
		END EXCEPTION;	
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF tipoProceso = 'N' THEN 
		
			BEGIN WORK;
			LET vFlagTransaccion = 'V';
			
			FOREACH WITH HOLD
				SELECT clave_sucursal, numlote, idsolmaquila
				INTO vClaveSucursalOrigen, vLote, vConsecutivoSolicitud
				FROM intercard:detalle_maquila
				WHERE clave_sucursal = inClaveSucursalOrigen
				GROUP BY 1, 2, 3


				UPDATE intercard:detalle_maquila
				SET clave_sucursal = inClaveSucursalDestino
				WHERE numlote = vLote;
				
				INSERT INTO bitacora_cierre_sucursal ( fecha, sucursalOrigen, sucursalDestino, tablaRegistro, numeroLote, consecutivoSolicitud, codigoRetorno, mensajeRetorno )
				VALUES(vFecha, inClaveSucursalOrigen, inClaveSucursalDestino, 'detalle_maquila', vLote, vConsecutivoSolicitud, '00000', 'Cambio exitoso lote');
			
				LET vContadorCommit = vContadorCommit + 1;
				
				IF vContadorCommit = vCommit THEN
					COMMIT;
					LET vFlagTransaccion = 'F';
					LET vContadorCommit = 0;
					BEGIN WORK;
					LET vFlagTransaccion = 'V';
				END IF;
				
			END FOREACH;
			
			IF vFlagTransaccion = 'V' THEN 
				COMMIT;
				LET vFlagTransaccion = 'F';
			END IF;
			
			FOREACH WITH HOLD
				SELECT a.numerolote, b.cantidadtarjetassol,  COUNT(*) as numero_tarjetas
				INTO vLote, vCantidadTarjetasOrigen, vCantidadTarjetasEncontradas
				FROM intercard:tarjeta a
				JOIN intercard:lote b
				ON a.numerolote = b.numerolote
				WHERE b.clave_sucursal = inClaveSucursalOrigen
				AND a.codstatustarjeta = 'INA'
				AND a.codstatusasignada = 'NOA'
				GROUP BY 1, 2


				EXECUTE PROCEDURE sp_move_lotedesucursal (vLote, inClaveSucursalOrigen, inClaveSucursalDestino) INTO cCodigoRetorno, cMensajeRetorno;
				
				INSERT INTO bitacora_cierre_sucursal 
				( fecha, sucursalOrigen, sucursalDestino, tablaRegistro, numeroLote, consecutivoSolicitud, codigoRetorno, mensajeRetorno )
				VALUES (vFecha, inClaveSucursalOrigen, inClaveSucursalDestino, 'lote', vLote, 0, cCodigoRetorno, TRIM(cMensajeRetorno) || ' - Cantidad tarjetas lote: ' || vCantidadTarjetasOrigen || ' Cantidad tarjetas encontradas: ' ||vCantidadTarjetasEncontradas);

			END FOREACH;

		END IF;
		
		IF tipoProceso = 'R' THEN 
		
			SELECT MAX(fecha)
			INTO vFecha
			FROM intercard:bitacora_cierre_sucursal
			WHERE sucursalDestino = inClaveSucursalOrigen;
			
			IF vFecha IS NULL THEN 
			
				LET cCodigoRetorno	= '00000';
				LET cMensajeRetorno	= 'PROCESO EXITOSO. NO EXISTEN DATOS RECIENTES A REVERSAR';
		
				RETURN cCodigoRetorno, cMensajeRetorno;
			
			ELSE 
				
				BEGIN WORK;
				LET vFlagTransaccion = 'V';


				FOREACH WITH HOLD
					SELECT numeroLote, consecutivoSolicitud
					INTO vLote, vConsecutivoSolicitud
					FROM intercard:bitacora_cierre_sucursal
					WHERE sucursalDestino = inClaveSucursalOrigen
					AND fecha = vFecha
					AND tablaRegistro LIKE 'detalle_maquila%'
					GROUP BY 1, 2
					
					UPDATE intercard:detalle_maquila
					SET clave_sucursal = inClaveSucursalDestino
					WHERE numlote = vLote;
					
					INSERT INTO bitacora_cierre_sucursal ( fecha, sucursalOrigen, sucursalDestino, tablaRegistro, numeroLote, consecutivoSolicitud, codigoRetorno, mensajeRetorno )
					VALUES(CURRENT, inClaveSucursalOrigen, inClaveSucursalDestino, 'detalle_maquila', vLote, vConsecutivoSolicitud, '00000', 'Cambio exitoso reverso lote');
				
					LET vContadorCommit = vContadorCommit + 1;
					
					IF vContadorCommit = vCommit THEN
						COMMIT;
						LET vFlagTransaccion = 'F';
						LET vContadorCommit = 0;
						BEGIN WORK;
						LET vFlagTransaccion = 'V';
					END IF;


				END FOREACH;
				
				IF vFlagTransaccion = 'V' THEN 
					COMMIT;
					LET vFlagTransaccion = 'F';
				END IF;

				FOREACH WITH HOLD
					SELECT numeroLote
					INTO vLote
					FROM intercard:bitacora_cierre_sucursal
					WHERE sucursalDestino = inClaveSucursalOrigen
					AND fecha = vFecha
					AND tablaRegistro LIKE 'lote%'
					GROUP BY 1
					
					EXECUTE PROCEDURE sp_move_lotedesucursal (vLote, inClaveSucursalOrigen, inClaveSucursalDestino) INTO cCodigoRetorno, cMensajeRetorno;
					
					INSERT INTO bitacora_cierre_sucursal ( fecha, sucursalOrigen, sucursalDestino, tablaRegistro, numeroLote, consecutivoSolicitud, codigoRetorno, mensajeRetorno )
					VALUES (CURRENT, inClaveSucursalOrigen, inClaveSucursalDestino, 'lote', vLote, 0, cCodigoRetorno, 'Reverso: ' || TRIM(cMensajeRetorno) );

				END FOREACH;

			END IF;
		
		END IF;
		
		LET cCodigoRetorno	= '00000';
		LET cMensajeRetorno	= 'PROCESO EXITOSO';
		
		RETURN cCodigoRetorno, cMensajeRetorno;
								
	END
	
END PROCEDURE;