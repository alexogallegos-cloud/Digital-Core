CREATE PROCEDURE "informix".sp_descarga_info_horasazules() 

    RETURNING VARCHAR (5) AS rCodigoRetorno, VARCHAR(150) AS rMensajeRespuesta;

    DEFINE SQL_ERR   	INTEGER;
    DEFINE ISAM_ERR   	INTEGER;
    DEFINE ERROR_INFO  	CHAR(80);
    
    DEFINE rCodigoRetorno 		VARCHAR(5);
    DEFINE rMensajeRespuesta 	VARCHAR(80);
	DEFINE vsRuta_destino 		VARCHAR(30);
 
	DEFINE vFechaEjecucion 			DATE;
	DEFINE vFechaEjecucion_minus4 	DATE;
	DEFINE vFechaEjecucion_datetime DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaAyer 				DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaAyer_ini 			DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaAyer_fin 			DATETIME YEAR TO FRACTION(5);
	
	DEFINE vsNomArch_coppel      VARCHAR(39);
	DEFINE vExecuteSQL 			 LVARCHAR(1500);
	
	/*
    DEFINE valerta               varchar(10);
	DEFINE vIdPlantilla1         varchar(15); 
    DEFINE vIdPlantilla2         varchar(15); 
	DEFINE vestatusenvio         char(1);
	DEFINE vsql					 CHAR(1150);
	
	DEFINE vNumeroCliente        VARCHAR(20);
	DEFINE vExisteRegistro 		SMALLINT;
	DEFINE vNumTarjeta 			VARCHAR(16);
	DEFINE vFecha_Notificacion 	DATETIME YEAR TO FRACTION(5);
	DEFINE vNumProducto 		VARCHAR(20);	
	DEFINE cCodRet      		CHAR(5);
	
	DEFINE vCodigoRetorno 		CHAR(5);
    DEFINE vMensajeRetorno 		CHAR(120);
    DEFINE vPrimerNombre 		VARCHAR(26);
    DEFINE vSegundoNombre 		VARCHAR(26);
    DEFINE vApellidoPaterno 	VARCHAR(26);
    DEFINE vApellidoMaterno 	VARCHAR(26);
    DEFINE vNumTelefono 		VARCHAR(13);    
    DEFINE vCorreoElect 		VARCHAR(100);
	*/
    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
    
    LET rCodigoRetorno = '00000'; --*
    LET rMensajeRespuesta = 'Inicio de ejecucion';    LET vsRuta_destino = '/RESPALDOSNEW/';      --*     

	LET vFechaEjecucion = '';
	LET vFechaEjecucion_minus4 = '';
	LET vFechaEjecucion_datetime = '';
	LET vFechaAyer = '';
	LET vFechaAyer_ini = ''; --*
	LET vFechaAyer_fin = ''; --*

	LET vsNomArch_coppel        = '';
	LET vExecuteSQL				= '';
	
	/*
	--LET vCorreoElect = '0';    
    LET vNumTelefono = '0'; 
	
    LET valerta       ='CMPS_BATCH';    -- alerta sms campaÃÂ±as   
    LET vIdPlantilla1 ='SRCLA_HRAZUL';    -- plantilla sms  TDC  - recordatorio
    LET vIdPlantilla2 ='SRORO_HRAZUL';    -- plantilla sms  ORO  - recordatorio
    LET vestatusenvio           = 'V';		
	LET vsql					= '';
	
	LET vExisteRegistro         = '0';
	LET vNumTarjeta             = '';
	LET vFecha_Notificacion     = '';
	LET vNumProducto            = '';
	LET cCodRet                 = '00000';
	LET vNumeroCliente          = ''; 
    LET vCodigoRetorno          = '';
    LET vMensajeRetorno         = '';
	 
	LET vPrimerNombre = '0';
    LET vSegundoNombre = '0';
    LET vApellidoPaterno = '';
    LET vApellidoMaterno = '';
	LET vNumTelefono = '0';
    LET vCorreoElect = '0';
    */
	
    --SET DEBUG FILE TO vsRuta_destino || "debug_sp_descarga_info_horasazules.out";
    --TRACE ON;    
 
	BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            
            -- SET DEBUG FILE TO vsRuta_destino || "excep_sp_descarga_info_horasazules.err" WITH APPEND;
            -- TRACE ON;
            
            IF ( SQL_ERR <> 0 ) THEN
			    LET rMensajeRespuesta = rCodigoRetorno||' '||ERROR_INFO; 
                LET rCodigoRetorno = SQL_ERR;              
                RETURN rCodigoRetorno, rMensajeRespuesta;
            END IF
			
        END EXCEPTION

		SET ISOLATION TO DIRTY READ; 
		SET LOCK MODE TO WAIT 3;        
		
		SELECT 
			DBINFO('utc_to_datetime', Sh_Curtime)::DATE as fecha_ejecucion,
			DBINFO('utc_to_datetime', Sh_Curtime)::DATE-2 as fecha_ejecucion_menos4,
			DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) as fecha_ejecucion_mov
		INTO vFechaEjecucion, vFechaEjecucion_minus4, vFechaEjecucion_datetime
		FROM sysmaster:"informix".sysshmvals; 

		LET vFechaAyer = (extend(vFechaEjecucion_datetime - 1 units DAY,YEAR TO DAY)); 
		LET vFechaAyer_ini =  SUBSTRING(vFechaAyer FROM 1 FOR 10) || ' 00:00:00.00000';
		LET vFechaAyer_fin =  SUBSTRING(vFechaAyer FROM 1 FOR 10) || ' 23:59:59.99999';
		
		/*
		DROP TABLE IF EXISTS tt_recordartorio;
		DROP TABLE IF EXISTS tt_movdia;
		DROP TABLE IF EXISTS tt_movhis;
		DROP TABLE IF EXISTS tt_final_ventanilla;		

		SELECT numtarjeta,fecha_activacion_tarjeta,fecha_notificacion, 
			   num_producto,telefono,correo_electronico,mensaje_enviado, canal_enviado, numcte, 'F' as flag_valida
		FROM   intercard:"informix".tbl_cmp_horas_azules_bitacora 
		WHERE  fecha_notificacion::DATE < vFechaEjecucion 
		AND    estatus_rec = 'N'  
		AND    mensaje_enviado = 'S'   
		INTO TEMP tt_recordartorio;
			
		FOREACH CurCalculaFecha WITH HOLD FOR 	
	
			SELECT  numtarjeta,fecha_notificacion  
			INTO vNumTarjeta,vFecha_Notificacion 
			FROM tt_recordartorio
		
			IF ( (TODAY) - (vFecha_Notificacion::DATE) )  >= 2  THEN 
				UPDATE  tt_recordartorio SET flag_valida = 'V' WHERE numtarjeta = vNumTarjeta AND fecha_notificacion = vFecha_Notificacion; 		  
			END IF;
		END FOREACH;
			 
		SELECT count(*) into vExisteRegistro FROM tt_recordartorio WHERE flag_valida = 'V'; 
			
		IF vExisteRegistro >=1 THEN 
			 
			--------------------------------------------------------------------------------------------------- Recopila disposiciones en ventanilla 	
			Select distinct numtarjeta  from  tt_recordartorio tt INNER JOIN  bdicred:sd_movdia sd  ON tt.numtarjeta = sd.nro_tarjeta
			WHERE    fecha_mov  = TODAY AND transacc_suc in ('6900','7380') and empresa = '001'  AND flag_valida = 'V'
			INTO TEMP tt_movdia;
			
			Select distinct numtarjeta  from  tt_recordartorio tt INNER JOIN  bdicred:sd_movhis sd  ON tt.numtarjeta = sd.nro_tarjeta
			WHERE  (fecha_mov between vFechaEjecucion_minus4 and vFechaEjecucion) and  transacc_suc in ('6900','7380') and empresa = '001' AND flag_valida = 'V'
			INTO TEMP tt_movhis;
			
			Select * from tt_movdia 
			UNION ALL 
			Select * from tt_movhis 
			into temp tt_final_ventanilla;
			  
			LET vExisteRegistro = 0; 

			FOREACH CurValidaUsoCredito WITH HOLD FOR 	
			 
			    SELECT numtarjeta,fecha_notificacion , num_producto,telefono   
			    into  vNumTarjeta,vFecha_Notificacion,  vNumProducto,vNumTelefono 
				FROM tt_recordartorio WHERE mensaje_enviado = 'S'  AND flag_valida = 'V' AND telefono IS NOT NULL 
			
				Select count(*) into vExisteRegistro from intercard:movimiento 
				where fechahorainauth between vFecha_Notificacion and  vFechaEjecucion_datetime  
				and  numtarjeta = vNumTarjeta  
				AND  prodind in ('01','02')
				AND  codtran in ('00','01','09')
				AND  formato = '0200'
				AND  codreversa = '0'
				AND  codigoiso = '00'
				AND  movreversado = 'F'
				AND  metodocaptura != ('null')
				AND  metodocaptura is not null;

				IF vExisteRegistro <> 0 then   
					--- marca campo de recordatorio como "A" que indica que titular si ha utilizado su tarjeta en los primeros dias
					UPDATE  tbl_cmp_horas_azules_bitacora SET estatus_rec = 'A' WHERE numtarjeta = vNumTarjeta;
				
					CONTINUE FOREACH; 
				END IF;  
 
                Select count(*) into vExisteRegistro from tt_final_ventanilla where numtarjeta = vNumTarjeta;
			   
		        IF vExisteRegistro >=1  then   
					--- marca campo de recordatorio como "A" que indica que titular si ha utilizado su tarjeta en los primeros dias
                    UPDATE  tbl_cmp_horas_azules_bitacora SET estatus_rec = 'A' WHERE numtarjeta = vNumTarjeta;
				ELSE
					IF   vNumProducto = '6001'  THEN -- SMS - TDC						
						EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('2',valerta,vIdPlantilla1,'000000000','','','1','','','','','','','','','','','',vNumTelefono,1,0,0,0,0,'','')					
						INTO 	cCodRet;
					  
						LET vestatusenvio = 'S';	 --- PRODUCCCION 
						
						IF  ( cCodRet <> '00000' )  THEN 
							LET vestatusenvio = 'E';	
						END IF; 	   

						--LET vestatusenvio = 'S';	--- PRUEBAS 
											
						--- marca campo de recordatorio como "S"  indicando que hubo necesidad de enviar recordatorio de uso
						UPDATE  tbl_cmp_horas_azules_bitacora SET estatus_rec = vestatusenvio WHERE numtarjeta = vNumTarjeta;
							
					ELIF  vNumProducto = '8100'  THEN  -- SMS - ORO	
						EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('2',valerta,vIdPlantilla2,'000000000','','','1','','','','','','','','','','','',vNumTelefono,1,0,0,0,0,'','')					
						INTO 	cCodRet;

						LET vestatusenvio = 'S';	 --- PRODUCCCION 
							  
						IF  ( cCodRet <> '00000' )  THEN 
							LET vestatusenvio = 'E';
						END IF; 	   
													
						--LET vestatusenvio = 'S';	--- PRUEBAS  
										
						--- marca campo de recordatorio como "S"  indicando que hubo necesidad de enviar recordatorio de uso
						UPDATE  tbl_cmp_horas_azules_bitacora SET estatus_rec = vestatusenvio WHERE numtarjeta = vNumTarjeta;
							
					ELSE 	   
						UPDATE  tbl_cmp_horas_azules_bitacora SET estatus_rec = 'E' WHERE numtarjeta = vNumTarjeta;
			
					END IF; 
				END IF; 
					 
				-- Libera como Improcedentes el resto de registros
				UPDATE  tbl_cmp_horas_azules_bitacora SET estatus_rec = 'I' 
				WHERE  estatus_rec = 'N' AND numtarjeta  IN ( SELECT numtarjeta FROM tt_recordartorio WHERE flag_valida = 'V' );
			END FOREACH;        
		END IF;       
		*/
	    
		-- Descarga de la informaciÃ³n de las notificaciones enviadas a los clientes REPORTES
		LET rCodigoRetorno = '00001';
			  
		LET vsNomArch_coppel = 'horasazules_notificaciones_'||  LPAD(DAY(vFechaEjecucion),'2',0) ||  LPAD(MONTH(vFechaEjecucion),'2',0)  ||  YEAR(vFechaEjecucion) || '.txt'; 
			   
		LET rCodigoRetorno = '00002';			   			                        
			   
		LET vExecuteSQL = '';  
		LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO '||vsRuta_destino||vsNomArch_coppel||'  '||
						 ' select EXTEND(fecha_asignacion_tarjeta, YEAR TO SECOND),EXTEND(fecha_activacion_tarjeta, YEAR TO SECOND) ,  '|| 
						 ' EXTEND(fecha_notificacion, YEAR TO SECOND), '||
						 ' numcte,TRIM(nombre1) ||''"'||' '||'"''||TRIM(apellido_paterno) as nombre_cliente,'||
						 ' CASE when canal_enviado =''"'||'1'||'"'' then ''"'||'CORREO'||'"'' '||
						 ' when   canal_enviado =''"'||'2'||'"'' then ''"'||'SMS'||'"''  else ''"'||'No enviado'||'"'' end as canal  ,'||
						 ' TRIM(NVL(telefono,''"'||'0'||'"'')),TRIM(NVL(correo_electronico,''"'||'0'||'"'')), '||
						 ' CASE WHEN num_producto = ''"'||'6001'||'"'' then ''"'||'TDC BanCoppel'||'"'' else  ''"'||'TDC BanCoppel Oro'||'"'' end as Producto, '||
						 ' CASE when  mensaje_enviado  =''"'||'S'||'"'' then ''"'||'Exitoso'||'"''  else  ''"'||'No Exitoso'||'"'' end as tipoenvio '||
						 ' FROM tbl_cmp_horas_azules_bitacora where fecha_notificacion BETWEEN ''"'||vFechaAyer_ini||'"''  AND  ''"'||vFechaAyer_fin||'"'' ;" >'||vsRuta_destino||'script_hrs_azules.sql';
		SYSTEM vExecuteSQL; 
				
		LET rCodigoRetorno = '00003';                    
		 
		---Asignacion de permisos del archivo .sql
		let vExecuteSQL ='';			
		let vExecuteSQL= 'chmod 777 ' ||vsRuta_destino||'script_hrs_azules.sql';
		system vExecuteSQL;
		 
		LET rCodigoRetorno = '00004';
		---- Generacion de log para observar errores a detalle en caso de presentarse uno 
		let vExecuteSQL = '';
		--let vExecuteSQL = 'dbaccess intercard '||vsRuta_destino||'script_hrs_azules.sql'||' 2> error_dbaccess_azul.log';
		let vExecuteSQL = '/ifxsif01/bin/dbaccess intercard '||vsRuta_destino||'script_hrs_azules.sql'||' 2> error_dbaccess_azul.log';
		system vExecuteSQL;					
			
		LET rCodigoRetorno = '00005';
			
		--eliminacion de archivos
		let vExecuteSQL = '';
		let vExecuteSQL ='rm -f '||vsRuta_destino||'script_hrs_azules.sql';
		system vExecuteSQL;				   
			  
		LET rCodigoRetorno = '00000';
        LET rMensajeRespuesta = 'Informacion generada correctamente.'; 
  
		RETURN rCodigoRetorno, rMensajeRespuesta;
    END			
END PROCEDURE
DOCUMENT
'Autor: Marcos Ayala',
'Base de datos: intercard',
'Fecha de creaciÃÂ³n: 05 de abril del 2022',
'Fecha de Modificacion: 06 de mayo del 2022, se reduce a 2 dias el recordatorio',
'Objetivo: Generar reporte diario y envio de notificaciones de recordatorio',

'Autor: Maria Fernanda Ortiz Figueroa',
'Base de Datos: intercard',
'Fecha de creacion: 05 de abril de 2022',
'Fecha de modificaciÃ³n: 26 de enero de 2023',
'Objetivo: Deshabilitar la mecÃ¡nica de notificaciones de recordatorio, ya que no son necesarias'
;

CREATE PROCEDURE "informix".sp_horasazules_obtener_tdc_clientes()
    RETURNING VARCHAR (5) AS rCodigoRetorno, VARCHAR(150) AS rMensajeRespuesta;

	-- Base de Datos: intercard
	-- Fecha de modificacion: 30 de enero de 2023
	-- Autor: Maria Fernanda Ortiz Figueroa
	-- Comentario: Se realizo el ajuste en la validacion de los productos, ya que la fecha_activa no era la mejor opciÃ³n para la consideraciÃ³n del funcinamiento de la campaÃ±a
	--             pues generaba que solo se enviara aproximadamente el 20% de la notificaciones de las que realmente se esperaban. AdemÃ¡s, se ajusto el filtro a 6 MESES en 
	--             la validaciÃ³n de un producto anterior, es decir, si en ese tiempo una persona adquiriÃ³ alguno de los productos no se le mandarÃ¡ notificaciÃ³n

    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);
    
    DEFINE vCodigoRetorno 	CHAR(5);
    DEFINE vMensajeRetorno 	CHAR(120);
    DEFINE RUTA_ORIGEN 		VARCHAR(50);

    DEFINE vProcesoIniciado 	CHAR(1);
    DEFINE vProcesoHabilitado 	CHAR(1);
    DEFINE vExisteRegistro 		INTEGER;
    DEFINE vFechaEjecucion 		DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaInicial 		DATETIME YEAR TO SECOND;
	DEFINE vFechaInicial_bita 	DATETIME YEAR TO SECOND;
    DEFINE vFechaFinal 			DATETIME YEAR TO SECOND;
	DEFINE vFechaFinaltoday 	DATETIME YEAR TO SECOND;
 
    DEFINE vFechaAsignacionTarjeta 	DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaActivacionTarjeta 	DATETIME YEAR TO FRACTION(5);
    DEFINE vNumCredito 				VARCHAR(20);
    DEFINE vNumeroCliente 			VARCHAR(20);
    DEFINE vNumProducto 			VARCHAR(20);
    DEFINE vNumTarjeta 				VARCHAR(16);
    
    DEFINE vNumTelefono 		VARCHAR(13);
    DEFINE vTerminacionTarjeta 	CHAR(4);
    DEFINE vPrimerNombre 		VARCHAR(26);
    DEFINE vSegundoNombre 		VARCHAR(26);
    DEFINE vApellidoPaterno 	VARCHAR(26);
    DEFINE vApellidoMaterno 	VARCHAR(26);    
    DEFINE vCorreoElect 		VARCHAR(100);
    
    DEFINE vPlantilla 		VARCHAR(12);
    DEFINE vTextoEnviado 	CHAR(1);    
        
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    
	LET vCodigoRetorno = '00000';
    LET vMensajeRetorno = 'El proceso es ejecutado exitosamente.';
    --LET RUTA_ORIGEN = '/ifxsif01/mgap/blue/'; --pruebas
	LET RUTA_ORIGEN = '/RESPALDOSNEW/'; -- PRODUCCION 
    
    LET vProcesoIniciado = 'N';
    LET vProcesoHabilitado = 'N';
    LET vExisteRegistro = 0;
    LET vFechaEjecucion = '';
    LET vFechaInicial = '';
	LET vFechaInicial_bita = '';
    LET vFechaFinal = '';
	LET vFechaFinaltoday = ''; 

    LET vFechaAsignacionTarjeta ='';
    LET vFechaActivacionTarjeta  ='';
    LET vNumCredito  ='';
    LET vNumProducto  ='';
    LET vNumTarjeta  ='';
    
    LET vPlantilla = NULL;
    LET vNumTelefono = '0';
    LET vTerminacionTarjeta = '0000';
    LET vPrimerNombre = '0';
    LET vSegundoNombre = '0';
    LET vNumeroCliente = '';
    LET vApellidoPaterno = '';
    LET vApellidoMaterno = '';
    LET vCorreoElect = '0';
    LET vTextoEnviado = '';
        
    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_horasazules_obtener_tdc_clientes.out";
    --TRACE ON;

    BEGIN 
        
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            -- SET DEBUG FILE TO RUTA_ORIGEN || "exc_sp_horasazules_obtener_tdc_clientes.err.out" WITH APPEND;
            -- TRACE ON;
            
            UPDATE intercard:tbl_inter_params_cmp_horas_azules 
                SET valores1 = 'N'
            WHERE empresa = '001'
                AND cond_busqueda = 'cmp_azul_proceso_ejecucion';
        
            IF ( SQLERR <> 0 ) THEN
				LET vCodigoRetorno = SQLERR;
                LET vMensajeRetorno = ERROR_INFO;
                RETURN vCodigoRetorno, vMensajeRetorno;
            END IF;

        END EXCEPTION;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        -- Validar si la campaÃ±a estÃ¡ habilitada.
        SELECT valores1 
            INTO vProcesoHabilitado
        FROM intercard:tbl_inter_params_cmp_horas_azules 
        WHERE empresa = '001'
        AND cond_busqueda = 'cmp_azul_activar_proceso';

        IF ( vProcesoHabilitado <> 'S' OR vProcesoHabilitado IS NULL ) THEN
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Proceso Hora Azules No Disponible.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF 
        
        -- Validar el periodo definido para la CampaÃ±a de Horas Azules
        SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) as fecha_ejecucion
			INTO vFechaEjecucion
        FROM sysmaster:"informix".sysshmvals;

        SELECT valores2 
            INTO vFechaInicial
        FROM intercard:tbl_inter_params_cmp_horas_azules
        WHERE empresa = '001' 
        AND cond_busqueda = 'cmp_azul_fecha_inicial';

        SELECT valores2 
            INTO vFechaFinal
        FROM intercard:tbl_inter_params_cmp_horas_azules
        WHERE empresa = '001' 
        AND cond_busqueda = 'cmp_azul_fecha_final';

        IF (  vFechaEjecucion  < vFechaInicial OR vFechaEjecucion > vFechaFinal ) THEN
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Proceso Horas Azules Fechas Finalizadas.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF 
        
		-- *****
        LET vFechaInicial = '';
        LET vFechaFinal = '';
        
        SELECT valores1
            INTO vProcesoIniciado   --- N 
        FROM intercard:tbl_inter_params_cmp_horas_azules 
        WHERE empresa = '001'
        AND cond_busqueda = 'cmp_azul_proceso_ejecucion';

        IF ( vProcesoIniciado <> 'N' OR vProcesoIniciado IS NULL ) THEN
            LET vCodigoRetorno = '00000';
            LET vMensajeRetorno = 'Proceso en Ejecucion.';
            RETURN vCodigoRetorno, vMensajeRetorno;
        END IF          
        
        UPDATE intercard:tbl_inter_params_cmp_horas_azules 
            SET valores1 = 'S' 
        WHERE empresa = '001'
        AND cond_busqueda = 'cmp_azul_proceso_ejecucion';

		LET vFechaInicial = '';
		LET vFechaFinal = '';
		LET vFechaFinaltoday = '';

		SELECT EXTEND(valores2, YEAR TO MINUTE) - 5 UNITS MINUTE   
			INTO vFechaInicial 
		FROM intercard:tbl_inter_params_cmp_horas_azules   
		WHERE empresa = '001' 
		AND cond_busqueda = 'cmp_azul_hr_pvt_inicial';

		SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO SECOND AS tiempo_final 			
			INTO vFechaFinaltoday
		FROM sysmaster:"informix".sysshmvals;

        LET vFechaFinal = EXTEND(vFechaFinaltoday, YEAR TO MINUTE) + 1 UNITS MINUTE; 				
		-- *****

		-- *****
        TRUNCATE TABLE  intercard:"informix".tbl_cmp_horas_azules_creditos DROP STORAGE; 
        
		-- NOTA 
		--     c.fecha_activa: 
		--          Hace referencia a la fecha y hora en la que la persona se acerca a la ventanilla para activar su producto, existe la posibilidad que no llegue a este punto.
		--     c.fecha_asigna: 
		--          Hace referencia a la fecha y hora en la que la persona se acerca con el promotor y comienza a realizar su tramite tal que le asignan el producto
		--			Al consierar esta fecha se tiene un match con fecha de apertura en bdicred:sd_maecred
		
		-- Producto 6001 
        FOREACH curCreditosActivos WITH HOLD FOR 
            SELECT d.fechaasignacion AS fecha_asignacion_tarjeta, c.fecha_activa as fecha_activacion_tarjeta, a.num_credito, a.numcte, a.num_producto, b.numtarjeta
                INTO vFechaAsignacionTarjeta, vFechaActivacionTarjeta, vNumCredito, vNumeroCliente, vNumProducto, vNumTarjeta
            FROM bdicred:sd_maecred a 
            INNER JOIN intercard:tarjetacuenta b
			ON(a.num_credito =  b.numcuenta)
			INNER JOIN bdicred:bitacora_activacion c 
			ON (b.numtarjeta = c.numtarjeta) 
			INNER JOIN intercard:tarjeta d
			ON(b.numtarjeta = d.numtarjeta)
            WHERE c.fecha_asigna BETWEEN vFechaInicial AND vFechaFinal   -- Antes c.fecha_activa
            AND a.num_producto = '6001'  
			AND c.tipo_asignacion = 'A'     
            AND c.empresa = '001' 
			
		    LET vExisteRegistro = 0; 
		    
		    -- Valida que no exista un producto 6001 anterior
			-- SELECT COUNT(*)
			-- 	INTO vExisteRegistro 
			-- FROM bdicred:sd_maecred 
			-- WHERE numcte = vNumeroCliente
			-- AND num_producto = '6001'  
			-- AND empresa = '001'
			
			SELECT COUNT(*)
				INTO vExisteRegistro
			FROM bdicred:sd_tarjeta st
			JOIN bdicred:sd_maecred sm
			ON st.numcte = sm.numcte
			AND st.num_credito = sm.num_credito
			AND st.prodtarjeta = sm.num_producto
			WHERE st.numcte = vNumeroCliente
			AND sm.num_producto = '6001'
			AND 
			(
				st.status_tar <> 'A' OR sm.fecha_apertura >= (TODAY - 183) -- Este caso solo aplica si en los Ãºltimos 6 MESES a adquirido este producto
			); 
			  
			IF ( vExisteRegistro >= 1 ) THEN    
                CONTINUE FOREACH;
            END IF
		
			LET vExisteRegistro = 0; 
             
            SELECT COUNT(*) 
				INTO vExisteRegistro 
            FROM intercard:"informix".tbl_cmp_horas_azules_creditos
            WHERE num_credito = vNumCredito
            AND numcte = vNumeroCliente
            AND numtarjeta = vNumTarjeta;
             
            IF ( vExisteRegistro > 0 ) THEN
                CONTINUE FOREACH;
            END IF
                
            INSERT INTO intercard:"informix".tbl_cmp_horas_azules_creditos ( fecha_asignacion_tarjeta, fecha_activacion_tarjeta, num_credito, numcte, num_producto, numtarjeta)
            VALUES (vFechaAsignacionTarjeta, vFechaActivacionTarjeta, vNumCredito, vNumeroCliente, vNumProducto, vNumTarjeta);
                
        END FOREACH  
        
		-- Producto 8100 Oro
		LET vExisteRegistro = 0; 
		
        FOREACH curCreditosOro WITH HOLD FOR 
            SELECT d.fechaasignacion as fecha_asignacion_tarjeta, c.fecha_activa as fecha_activacion_tarjeta, a.num_credito, a.numcte, num_producto, b.numtarjeta
                INTO vFechaAsignacionTarjeta, vFechaActivacionTarjeta, vNumCredito, vNumeroCliente, vNumProducto, vNumTarjeta
            FROM bdicred:sd_maecred a 
            INNER JOIN intercard:tarjetacuenta b
            ON(a.num_credito =  b.numcuenta)
            INNER JOIN bdicred:bitacora_activacion c 
            ON (b.numtarjeta = c.numtarjeta) 
            INNER JOIN intercard:tarjeta d
            ON(b.numtarjeta = d.numtarjeta)
            WHERE c.fecha_asigna BETWEEN vFechaInicial AND vFechaFinal  -- Antes c.fecha_activa
            AND a.num_producto  = '8100'
			AND c.tipo_asignacion = 'A'    
            AND c.empresa = '001' 

            LET vExisteRegistro = 0; 
				
		    -- Valida que no exista un producto 8100 anterior, se considera la misma validaciÃ³n que en el caso del otro producto
			-- SELECT COUNT(*) 
			-- 	INTO vExisteRegistro 
			-- FROM bdicred:sd_tarjeta 
			-- WHERE numcte = vNumeroCliente
			-- AND prodtarjeta = '8100' 
			-- AND status_tar <> 'A' ; 

			SELECT COUNT(*)
				INTO vExisteRegistro
			FROM bdicred:sd_tarjeta st
			JOIN bdicred:sd_maecred sm
			ON st.numcte = sm.numcte
			AND st.num_credito = sm.num_credito
			AND st.prodtarjeta = sm.num_producto
			WHERE st.numcte = vNumeroCliente
			AND sm.num_producto = '8100'
			AND 
			(
				st.status_tar <> 'A' OR sm.fecha_apertura >= (TODAY - 183) -- Este caso solo aplica si en los Ãºltimos 6 MESES a adquirido este producto
			); 
			  
			IF ( vExisteRegistro >= 1 ) THEN    
				CONTINUE FOREACH;
			END IF
			   
			LET vExisteRegistro = 0; 
 
            SELECT COUNT(*) 
				INTO vExisteRegistro 
            FROM intercard:"informix".tbl_cmp_horas_azules_creditos
            WHERE num_credito = vNumCredito
            AND numcte = vNumeroCliente
            AND numtarjeta = vNumTarjeta;
             
            IF ( vExisteRegistro > 0 ) THEN
                CONTINUE FOREACH; 
            END IF
                
            INSERT INTO intercard:"informix".tbl_cmp_horas_azules_creditos ( fecha_asignacion_tarjeta, fecha_activacion_tarjeta, num_credito, numcte, num_producto, numtarjeta)
            VALUES (vFechaAsignacionTarjeta, vFechaActivacionTarjeta, vNumCredito, vNumeroCliente, vNumProducto, vNumTarjeta);
                
        END FOREACH 
        -- *****
		
        -- Buscar los datos del cliente y enviar mensaje
        FOREACH curBuscarInfoCte WITH HOLD FOR
            SELECT  fecha_asignacion_tarjeta, fecha_activacion_tarjeta, num_credito, numcte, num_producto, numtarjeta
                INTO vFechaAsignacionTarjeta, vFechaActivacionTarjeta, vNumCredito, vNumeroCliente, vNumProducto, vNumTarjeta
            FROM intercard:"informix".tbl_cmp_horas_azules_creditos
            WHERE num_producto IN ('6001', '8100')  

			SELECT COUNT(*)
				INTO vExisteRegistro
			FROM intercard:"informix".tbl_cmp_horas_azules_bitacora
			WHERE num_credito = vNumCredito;
	 
			IF ( vExisteRegistro > 0 ) THEN
				CONTINUE FOREACH;
			END IF
					  
            EXECUTE PROCEDURE intercard:"informix".sp_intercard_info_ctes_por_notif( vNumeroCliente, 'S' )
                INTO vCodigoRetorno,  vMensajeRetorno, vNumeroCliente, vPrimerNombre, vSegundoNombre, 
                        vApellidoPaterno, vApellidoMaterno, vNumTelefono, vCorreoElect;
        
            SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) as fecha_ejecucion
                INTO vFechaEjecucion
            FROM sysmaster:"informix".sysshmvals;
                
            IF ( vNumTelefono = '0' ) THEN 
                LET vNumTelefono = NULL;
            END IF
			
            IF ( vCorreoElect = '0' ) THEN
                LET vCorreoElect = NULL;
            END IF
			
            IF ( vPrimerNombre = '0' ) THEN
                LET vPrimerNombre = NULL;
            END IF
			
            IF ( vSegundoNombre = '0' ) THEN
                LET vSegundoNombre = NULL;
            END IF
			
            IF ( vApellidoPaterno = '0' ) THEN
                LET vApellidoPaterno = NULL;
            END IF
			
            IF ( vApellidoMaterno = '0' ) THEN
                LET vApellidoMaterno = NULL;
            END IF
            
            INSERT INTO intercard:"informix".tbl_cmp_horas_azules_bitacora (
                fecha_asignacion_tarjeta, fecha_activacion_tarjeta, num_credito, numcte, 
                num_producto, numtarjeta, telefono, correo_electronico, nombre1, nombre2, 
                apellido_paterno, apellido_materno, fecha_notificacion)
            VALUES (vFechaAsignacionTarjeta, vFechaActivacionTarjeta, vNumCredito, vNumeroCliente, vNumProducto, vNumTarjeta,vNumTelefono, 
					LOWER(vCorreoElect), vPrimerNombre, vSegundoNombre, vApellidoPaterno, vApellidoMaterno,vFechaEjecucion);
        END FOREACH             
         
        FOREACH curEnviarNotifica WITH HOLD FOR
            SELECT   num_credito, telefono, correo_electronico, num_producto, nombre1, nombre2
                INTO vNumCredito, vNumTelefono, vCorreoElect, vNumProducto,  vPrimerNombre, vSegundoNombre
            FROM intercard:tbl_cmp_horas_azules_bitacora
            WHERE num_producto IN ('6001', '8100') 
            AND mensaje_enviado = 'N'  
            AND canal_enviado   = '0'
                    
            IF ( LENGTH(vPrimerNombre) < 3) THEN
                LET vPrimerNombre = vSegundoNombre;
            END IF 
            
            --TRACE ' #argoz_nombre:  ' || vPrimerNombre;
 
            IF ( ( LENGTH(vNumTelefono) > 0 AND LENGTH(vCorreoElect) > 0 ) OR ( LENGTH(vNumTelefono) > 0  AND vCorreoElect  IS NULL )   ) THEN
                                       
                LET vPlantilla = DECODE ( vNumProducto, '6001', 'SCLA_HR_AZUL', '8100', 'SORO_HR_AZUL');
                
				----SMS
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2', 'CMPS_BATCH', vPlantilla, '000000000',NULL,NULL,'1',vPrimerNombre,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,vNumTelefono,0,0,0,0,0,current,current)
                INTO vCodigoRetorno;	 
                    
                LET vTextoEnviado = 'N';
				
                IF ( vCodigoRetorno = '00000') THEN
					LET vTextoEnviado = 'S';
                END IF 
                
				--let vTextoEnviado = 'S'; -- PRUEBAS 
				
                UPDATE intercard:tbl_cmp_horas_azules_bitacora
					SET  mensaje_enviado = vTextoEnviado, canal_enviado = '2'
                WHERE num_credito = vNumCredito;
                
            END IF

            IF ( LENGTH(vCorreoElect) > 0 AND vNumTelefono IS NULL ) THEN

                LET vPlantilla = DECODE ( vNumProducto, '6001', 'CCLA_HR_AZUL', '8100', 'CORO_HR_AZUL');
                
				--Correo
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1', 'CMPC_BATCH', vPlantilla, '000000000',NULL,NULL,'1',vPrimerNombre,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,vCorreoElect,NULL,0,0,0,0,0,current,current)
                INTO vCodigoRetorno;

				LET vTextoEnviado = 'N';
				
				IF ( vCodigoRetorno = '00000') THEN
					LET vTextoEnviado = 'S';
				END IF 
				
				--let vTextoEnviado = 'S'; -- PRUEBAS 
				
				UPDATE intercard:tbl_cmp_horas_azules_bitacora
					SET  mensaje_enviado = vTextoEnviado, canal_enviado = '1'
				WHERE num_credito = vNumCredito;

            END IF
            
            IF ( (vNumTelefono IS NULL)  AND  (vCorreoElect  IS NULL) ) THEN

				UPDATE intercard:tbl_cmp_horas_azules_bitacora
					SET canal_enviado = '3' -- no se intento enviar ningun msj 
				WHERE num_credito = vNumCredito;
            
            END IF 

        END FOREACH
        
        LET vCodigoRetorno = '00000';
        LET vMensajeRetorno = 'Fin de ejecucion.';
   
	    LET  vFechaFinal   = vFechaFinaltoday;  

        UPDATE intercard:tbl_inter_params_cmp_horas_azules 
			SET valores2 = vFechaFinal  - 1 UNITS MINUTE	
		WHERE empresa = '001' 
		AND  cond_busqueda = 'cmp_azul_hr_pvt_inicial';  
		
        UPDATE intercard:tbl_inter_params_cmp_horas_azules 
        SET valores2 = vFechaFinal  + 0 UNITS MINUTE  
        WHERE empresa = '001' 
		AND  cond_busqueda = 'cmp_azul_hr_pvt_final';

	    --Finalizacion del proceso de campaÃ±a.
        --Preparado para el siguiente ciclo
        UPDATE intercard:tbl_inter_params_cmp_horas_azules 
            SET valores1 = 'N'
        WHERE empresa = '001'
        AND cond_busqueda = 'cmp_azul_proceso_ejecucion';
        
        RETURN vCodigoRetorno, vMensajeRetorno;       
    END
END PROCEDURE

DOCUMENT
'#1',
'Base de datos:intercard',
'Fecha de creacion: 05 de abril del 2022',
'ImplementaciÃ³n para campaÃ±a de horas azules en productos de tarjeta de credito.'
;

CREATE PROCEDURE "informix".sp_consultaregtarjeta(pNumtarjeta VARCHAR(16), pNumLote INTEGER, pOpcion INTEGER)
	RETURNING	CHAR(5) 	AS cCodRet,
				VARCHAR(13) AS vNumCliente,
				VARCHAR(13) AS vNumCuenta,
				VARCHAR(16) AS vNumTarjeta;

DEFINE sql_err 				INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE vNumcliente			VARCHAR(13);
DEFINE vNumcuenta 			VARCHAR(13);
DEFINE vNumtarjeta 			VARCHAR(16);
DEFINE iIdsolicitud			INTEGER;

LET sql_err					= 0;
LET cCodRet 				= '00000';
LET vNumcliente             = ''; 
LET vNumcuenta              = '';
LET vNumtarjeta             = '';
LET iIdsolicitud			= 0;


--SET DEBUG FILE TO "/tmp/sp_consultaregtarjeta.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(vNumcliente,'')), TRIM(NVL(vNumcuenta,'')), TRIM(NVL(vNumtarjeta,''));
		END IF;
	END EXCEPTION;

	IF pOpcion = 1  THEN
		IF pNumtarjeta IS NULL OR pNumtarjeta = '' OR pNumLote is NULL  THEN
			LET cCodRet = "00001";
		ELSE
			SELECT {+INDEX (tarjeta lote) +INDEX (tarjeta 185_574)}
			numTarjeta 
			INTO vNumtarjeta 
			FROM intercard: tarjeta 
			WHERE numerolote = pNumLote 
			AND numTarjeta LIKE  "%" || pNumtarjeta;
			
			IF (NVL(vNumtarjeta,'') = '') THEN
				LET cCodRet = "00002";
			END IF;
		END IF;	
	ELIF pOpcion = 2 THEN
		IF pNumtarjeta IS NULL OR pNumtarjeta = '' THEN
			LET cCodRet = "00001";
		ELSE
			SELECT idsolicitud
			INTO iIdsolicitud		
			FROM intercard: detalle_maquila 
			WHERE numtarjeta =  pNumtarjeta;
			
			IF (NVL(iIdsolicitud,'') = '') THEN
				LET cCodRet = "00002";
			ELSE
				SELECT numcuenta, numcliente
				INTO vNumcuenta, vNumcliente		
				FROM intercard: solicitudtarjeta 
				WHERE idsolicitud = iIdsolicitud;
				
				IF (NVL(vNumcuenta,'') = '') OR (NVL(vNumcliente,'') = '' ) THEN
					LET cCodRet = "00002";
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet = "00001";
	END IF;
	
	RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(vNumcliente,'')), TRIM(NVL(vNumcuenta,'')), TRIM(NVL(vNumtarjeta,''));

END;
END PROCEDURE
DOCUMENT
'consultas para pl004056',
'para proyecto de Tarjetas de CrÃ©dito Oro nominadas_ innominadas',
'AUTOR : Felipe Urias',
'FECHA : 24/03/2022',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_oper_corr_oxxo_eleven_aut()
RETURNING CHAR(5) as cod_ret, VARCHAR(50) as mensaje;

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         VARCHAR(50);
    DEFINE vcodret1         VARCHAR(5);
    DEFINE vcodret2         VARCHAR(65);
    DEFINE vcodret3         VARCHAR(50);
	DEFINE dFecha_inicio_extendida DATETIME YEAR TO FRACTION(5);
	DEFINE dFecha_fin_extendida DATETIME YEAR TO FRACTION(5);
	DEFINE CONTADOR_TRANSACCIONES INTEGER;

	DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(20);

	DEFINE NOMBRE_ARCHIVO_MCO_CONCI_APLI VARCHAR(29);
	DEFINE NOMBRE_ARCHIVO_MOVIMIENTOS VARCHAR(29);
	DEFINE NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN VARCHAR(31);
	DEFINE NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE VARCHAR(36);
	DEFINE RUTA_ORIGEN 		VARCHAR(70);
	DEFINE SCRIPT_EJECUCION_MCO_CONCI_APLI VARCHAR(35);
	DEFINE SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN VARCHAR(37);
	DEFINE SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE VARCHAR(42);
	DEFINE SCRIPT_EJECUCION_MOVIMIENTOS VARCHAR(35);
	DEFINE cRutaInformix 	VARCHAR(100);
	DEFINE PREFIJO_ARCHIVO  VARCHAR(9);
	DEFINE vRutadbload 		VARCHAR (21);
	DEFINE vsql		        LVARCHAR(4000);
	DEFINE vMes_actual 		VARCHAR(2);
	DEFINE iNum_trama		INTEGER;
	DEFINE vUltimo_dia_mes  VARCHAR(2);
	DEFINE dRango_dias_inicio DATE;
	DEFINE dRango_dias_inicio_ext DATETIME YEAR TO FRACTION(5);
	DEFINE dRango_dias_fin DATE;
	DEFINE dRango_dias_fin_ext DATETIME YEAR TO FRACTION(5);
	DEFINE dUltimo_dia_mes DATE;
	DEFINE dUltimo_dia_mes_acum DATE;
	DEFINE dUltimo_dia_mes_acum_ext DATETIME YEAR TO FRACTION(5);
	
	
	DEFINE RUTA_DESTINO 	VARCHAR(14);
	DEFINE TIPO_PLANTILLA   VARCHAR(30);
	DEFINE vExecuteSQL      LVARCHAR(5000);
	
	LET dFecha_inicio_extendida ='';
	LET dFecha_fin_extendida ='';
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    LET vcodret1 = '00000';
    LET vcodret2 = '';
    LET vcodret3 = 'Se generaron archivos corresponsal OXXO y 7Eleven';
	LET CONTADOR_TRANSACCIONES = 1000;
	
	LET RUTA_ORIGEN = '/RESPALDOSNEW/';
	LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
	LET NOMBRE_ARCHIVO_MCO_CONCI_APLI = 'file_registros_mco_conci_apli';
	LET NOMBRE_ARCHIVO_MOVIMIENTOS = 'file_registros_movimientos';
	LET NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN = 'file_registros_cruce_oxxo_seven';
	LET NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE ='file_registros_descuadre_num_cliente';
	LET SCRIPT_EJECUCION_MCO_CONCI_APLI = 'script_registros_mco_conci_apli.sql';
	LET SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN = 'script_registros_cruce_oxxo_seven.sql';
	LET SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE ='script_registros_descuadre_num_cliente.sql';
	LET SCRIPT_EJECUCION_MOVIMIENTOS = 'script_registros_movimientos.sql';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET PREFIJO_ARCHIVO = 'movs_reg_';
	LET vRutadbload = '/ifxsif01/bin/dbload';
	LET iNum_trama = 1;
	LET vUltimo_dia_mes ='';
	LET dRango_dias_inicio ='';
	LET dRango_dias_fin = '';
	LET vsql ='';
    LET RUTA_DESTINO   = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA = 'corr_oxxo_eleven';
	LET dUltimo_dia_mes_acum ='';
	LET dUltimo_dia_mes_acum_ext ='';
	LET vExecuteSQL = '';
	
	
	BEGIN

				ON EXCEPTION SET sql_err, isam_err, desc_err
					SET DEBUG FILE TO RUTA_ORIGEN || "sp_oper_corr_oxxo_eleven.err.out";
					--TRACE ON;
					IF sql_err <> 0 THEN
						LET vcodret1 = sql_err;
						LET vcodret2 = isam_err;
						--LET vcodret3 = desc_err;
						RETURN vcodret1, vcodret2;
					END IF;
				END EXCEPTION;
				
		--SET DEBUG FILE TO "/ifxsif01/ilopez/Corresponsales_OXXO_7ELEVEN/SPL/sp_oper_corr_oxxo_eleven.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	--ARCHIVOS OXXO--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	
	LET dRango_dias_fin = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_fin = dRango_dias_fin -1 UNITS MONTH;
	LET dRango_dias_fin = LPAD(MONTH(dRango_dias_fin),2,0)||'/'||'05'||'/'||YEAR(dRango_dias_fin);
	
	
	
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';
	
	LET dRango_dias_fin_ext = YEAR(dRango_dias_fin) ||'-'|| LPAD ( MONTH(dRango_dias_fin), 2, '0')||'-'||LPAD(DAY(dRango_dias_fin), 2, '0')||' 23:59:59.99999';
			
	
	LET dUltimo_dia_mes = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes = dUltimo_dia_mes -1 UNITS MONTH;
	LET dUltimo_dia_mes = LPAD(MONTH(dUltimo_dia_mes),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes))||'/'||YEAR(dUltimo_dia_mes);
	
	--Para probar otros meses
	--LET dRango_dias_inicio ='10012022';
	--LET dRango_dias_inicio_ext = '2022-10-01 00:00:00.00000';
	--LET dRango_dias_fin_ext = '2022-10-05 23:59:59.99999';
	--LET dRango_dias_fin = '10052022';

	LET iNum_trama = 1;
	WHILE (iNum_trama <= 6) LOOP
		
		    IF iNum_trama < 6 THEN 
				
			let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Fecha_archivo|Id_procesador|Secuencia|Autorizacion|Numtarjeta|Numcuenta|Montomov|Monto_mco|Monto_cheq_cred|Secuenciaextendida|Montorealrevfzda|Codreversa|Tipo_txn|Prodind|Formato|codtran|Metodocaptura|Idterminal|Infreceptor|Esnacional|Pais|Fechahorainauth|Fechaconciliacion|Fecha|Hora|Producto|Tbl_mov|Tbl_mco|tbl_movhis|Resultado_final|Cobro_comision|idreceptor|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dRango_dias_fin),2,0)||'_oxxo'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_oxxo'||'.txt   '||
			           ' SELECT b.numcliente,a.fecha_archivo,a.id_procesador,a.secuencia,a.autorizacion,a.numtarjeta,a.numcuenta,a.montomov,a.monto_mco,a.monto_cheq_cred,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.tipo_txn,a.prodind,a.formato,a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.fechaconciliacion,a.fecha,a.hora,a.producto,a.tbl_mov,a.tbl_mco,a.tbl_movhis,a.resultado_final,a.cobro_comision,a.idreceptor '||
					   ' FROM intercard:mco_conciliacion_aplicativos a '||
					   ' INNER JOIN intercard:tarjeta b ON a.numtarjeta = b.numtarjeta '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dRango_dias_fin_ext||''' '||
					   ' AND idreceptor = \"02\" '||

					   '" >'||RUTA_DESTINO||'script_oxxo_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_oxxo_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_oxxo_reg.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_oxxo'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dRango_dias_fin),2,0)||'_oxxo'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_oxxo_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_oxxo'||'.txt';
		    system vsql;
			
			
			LET dRango_dias_inicio = dRango_dias_fin +1 UNITS DAY;
			LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio) || '-' || LPAD ( MONTH(dRango_dias_inicio), 2, '0') || '-' ||LPAD ( DAY (dRango_dias_inicio), 2, '0') || ' 00:00:00.00000';

			LET dRango_dias_fin = dRango_dias_inicio +4 UNITS DAY;
			LET dRango_dias_fin_ext = YEAR(dRango_dias_fin) || '-' || LPAD ( MONTH(dRango_dias_fin), 2, '0') || '-' ||LPAD ( DAY (dRango_dias_fin), 2, '0') || ' 23:59:59.99999';

			ELSE 
			
			LET dRango_dias_inicio = dRango_dias_inicio;
			LET dRango_dias_fin = dRango_dias_fin;
			LET dRango_dias_inicio_ext = dRango_dias_inicio_ext;
			LET dRango_dias_fin_ext = YEAR(dUltimo_dia_mes) || '-' || LPAD ( MONTH(dUltimo_dia_mes), 2, '0') || '-' ||DAY(dUltimo_dia_mes)|| ' 23:59:59.99999';
			
			let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Fecha_archivo|Id_procesador|Secuencia|Autorizacion|Numtarjeta|Numcuenta|Montomov|Monto_mco|Monto_cheq_cred|Secuenciaextendida|Montorealrevfzda|Codreversa|Tipo_txn|Prodind|Formato|codtran|Metodocaptura|Idterminal|Infreceptor|Esnacional|Pais|Fechahorainauth|Fechaconciliacion|Fecha|Hora|Producto|Tbl_mov|Tbl_mco|tbl_movhis|Resultado_final|Cobro_comision|idreceptor|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dUltimo_dia_mes),2,0)||'_oxxo'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_oxxo'||'.txt   '||
			           ' SELECT b.numcliente,a.fecha_archivo,a.id_procesador,a.secuencia,a.autorizacion,a.numtarjeta,a.numcuenta,a.montomov,a.monto_mco,a.monto_cheq_cred,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.tipo_txn,a.prodind,a.formato,a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.fechaconciliacion,a.fecha,a.hora,a.producto,a.tbl_mov,a.tbl_mco,a.tbl_movhis,a.resultado_final,a.cobro_comision,a.idreceptor '||
					   ' FROM intercard:mco_conciliacion_aplicativos a '||
					   ' INNER JOIN intercard:tarjeta b ON a.numtarjeta = b.numtarjeta '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dRango_dias_fin_ext||''' '||
					   ' AND idreceptor = \"02\" '||

					   '" >'||RUTA_DESTINO||'script_oxxo_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_oxxo_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_oxxo_reg.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_oxxo'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dUltimo_dia_mes),2,0)||'_oxxo'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_oxxo_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_oxxo'||'.txt';
		    system vsql;
			
				
			END IF;
			
			LET iNum_trama = iNum_trama + 1;
			LET iNum_trama = iNum_trama ;
			
	END LOOP;
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--ARCHIVOS 7ELEVEN--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	LET dRango_dias_inicio ='';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	
	LET dRango_dias_fin = '';
	LET dRango_dias_fin = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_fin = dRango_dias_fin -1 UNITS MONTH;
	LET dRango_dias_fin = LPAD(MONTH(dRango_dias_fin),2,0)||'/'||'05'||'/'||YEAR(dRango_dias_fin);
	
	
	LET dRango_dias_inicio_ext ='';
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';
	
	LET dRango_dias_fin_ext = '';
	LET dRango_dias_fin_ext = YEAR(dRango_dias_fin) ||'-'|| LPAD ( MONTH(dRango_dias_fin), 2, '0')||'-'||LPAD(DAY(dRango_dias_fin), 2, '0')||' 23:59:59.99999';
	
	LET dUltimo_dia_mes = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes = dUltimo_dia_mes -1 UNITS MONTH;
	LET dUltimo_dia_mes = LPAD(MONTH(dUltimo_dia_mes),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes))||'/'||YEAR(dUltimo_dia_mes);
	--Para probar otros meses
	--LET dRango_dias_inicio ='10012022';
	--LET dRango_dias_inicio_ext = '2022-10-01 00:00:00.00000';
	--LET dRango_dias_fin_ext = '2022-10-05 23:59:59.99999';
	--LET dRango_dias_fin = '10052022';
	
	
	LET iNum_trama = 1;
	WHILE (iNum_trama <= 6) LOOP
		
		    IF iNum_trama < 6 THEN 
				
			let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Fecha_archivo|Id_procesador|Secuencia|Autorizacion|Numtarjeta|Numcuenta|Montomov|Monto_mco|Monto_cheq_cred|Secuenciaextendida|Montorealrevfzda|Codreversa|Tipo_txn|Prodind|Formato|codtran|Metodocaptura|Idterminal|Infreceptor|Esnacional|Pais|Fechahorainauth|Fechaconciliacion|Fecha|Hora|Producto|Tbl_mov|Tbl_mco|tbl_movhis|Resultado_final|Cobro_comision|idreceptor|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dRango_dias_fin),2,0)||'_eleven'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_eleven'||'.txt   '||
			           ' SELECT b.numcliente,a.fecha_archivo,a.id_procesador,a.secuencia,a.autorizacion,a.numtarjeta,a.numcuenta,a.montomov,a.monto_mco,a.monto_cheq_cred,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.tipo_txn,a.prodind,a.formato,a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.fechaconciliacion,a.fecha,a.hora,a.producto,a.tbl_mov,a.tbl_mco,a.tbl_movhis,a.resultado_final,a.cobro_comision,a.idreceptor '||
					   ' FROM intercard:mco_conciliacion_aplicativos a '||
					   ' INNER JOIN intercard:tarjeta b ON a.numtarjeta = b.numtarjeta '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dRango_dias_fin_ext||''' '||
					   ' AND idreceptor = \"03\" '||

					   '" >'||RUTA_DESTINO||'script_eleven_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_eleven_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_eleven_reg.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_eleven'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dRango_dias_fin),2,0)||'_eleven'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_eleven_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_eleven'||'.txt';
		    system vsql;
			
			
			LET dRango_dias_inicio = dRango_dias_fin +1 UNITS DAY;
			LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio) || '-' || LPAD ( MONTH(dRango_dias_inicio), 2, '0') || '-' ||LPAD ( DAY (dRango_dias_inicio), 2, '0') || ' 00:00:00.00000';

			LET dRango_dias_fin = dRango_dias_inicio +4 UNITS DAY;
			LET dRango_dias_fin_ext = YEAR(dRango_dias_fin) || '-' || LPAD ( MONTH(dRango_dias_fin), 2, '0') || '-' ||LPAD ( DAY (dRango_dias_fin), 2, '0') || ' 23:59:59.99999';

			ELSE 
			
			LET dRango_dias_inicio = dRango_dias_inicio;
			LET dRango_dias_fin = dRango_dias_fin;
			LET dRango_dias_inicio_ext = dRango_dias_inicio_ext;
			LET dRango_dias_fin_ext = YEAR(dUltimo_dia_mes) || '-' || LPAD ( MONTH(dUltimo_dia_mes), 2, '0') || '-' ||DAY(dUltimo_dia_mes)|| ' 23:59:59.99999';
			
			let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Fecha_archivo|Id_procesador|Secuencia|Autorizacion|Numtarjeta|Numcuenta|Montomov|Monto_mco|Monto_cheq_cred|Secuenciaextendida|Montorealrevfzda|Codreversa|Tipo_txn|Prodind|Formato|codtran|Metodocaptura|Idterminal|Infreceptor|Esnacional|Pais|Fechahorainauth|Fechaconciliacion|Fecha|Hora|Producto|Tbl_mov|Tbl_mco|tbl_movhis|Resultado_final|Cobro_comision|idreceptor|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dUltimo_dia_mes),2,0)||'_eleven'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_eleven'||'.txt   '||
			           ' SELECT b.numcliente,a.fecha_archivo,a.id_procesador,a.secuencia,a.autorizacion,a.numtarjeta,a.numcuenta,a.montomov,a.monto_mco,a.monto_cheq_cred,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.tipo_txn,a.prodind,a.formato,a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.fechaconciliacion,a.fecha,a.hora,a.producto,a.tbl_mov,a.tbl_mco,a.tbl_movhis,a.resultado_final,a.cobro_comision,a.idreceptor '||
					   ' FROM intercard:mco_conciliacion_aplicativos a '||
					   ' INNER JOIN intercard:tarjeta b ON a.numtarjeta = b.numtarjeta '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dRango_dias_fin_ext||''' '||
					   ' AND idreceptor = \"03\" '||

					   '" >'||RUTA_DESTINO||'script_eleven_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_eleven_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_eleven_reg.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_eleven'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_'||LPAD(DAY(dRango_dias_inicio),2,0)||'_'||LPAD(DAY(dUltimo_dia_mes),2,0)||'_eleven'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_eleven_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_eleven'||'.txt';
		    system vsql;
			
				
			END IF;
			
			LET iNum_trama = iNum_trama + 1;
			LET iNum_trama = iNum_trama ;
			
	END LOOP;
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	
	LET dRango_dias_inicio_ext = '';
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';

	--ACUMULADO OXXO
	LET dUltimo_dia_mes_acum = '';
	LET dUltimo_dia_mes_acum = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes_acum = dUltimo_dia_mes_acum -1 UNITS MONTH;
	LET dUltimo_dia_mes_acum = LPAD(MONTH(dUltimo_dia_mes_acum),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes_acum))||'/'||YEAR(dUltimo_dia_mes_acum);
	
	LET dUltimo_dia_mes_acum_ext = YEAR(dUltimo_dia_mes_acum) || '-' || LPAD ( MONTH(dUltimo_dia_mes_acum), 2, '0') || '-' ||DAY(LAST_DAY(dUltimo_dia_mes_acum))|| ' 23:59:59.99999';
	--Para probar otros meses
	--LET dRango_dias_inicio ='11012022';
	--LET dRango_dias_inicio_ext = '2022-11-01 00:00:00.00000';
	--LET dUltimo_dia_mes_acum_ext = '2022-11-30 23:59:59.99999';
	
	
	
			let vsql = ''; 	   
			let vsql = 'echo "Fecha_Archivo|Fecha_txn|Total_txn|Monto_total|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_oxxo_acumulado'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_acumulado_oxxo'||'.txt   '||
			           ' SELECT fecha_archivo,SUBSTR(fechahorainauth,1,10),COUNT(*),SUM(montomov)'||
					   ' FROM intercard:mco_conciliacion_aplicativos '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||
					   ' AND idreceptor = \"02\" '||
					   ' GROUP BY 1,2 ORDER BY fecha_archivo '||

					   '" >'||RUTA_DESTINO||'script_reg_oxxo_acum.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_reg_oxxo_acum.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_reg_oxxo_acum.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_acumulado_oxxo'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_oxxo_acumulado'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_reg_oxxo_acum.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_acumulado_oxxo'||'.txt';
		    system vsql;
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';

	--ACUMULADO ELEVEN
	LET dUltimo_dia_mes_acum = '';
	LET dUltimo_dia_mes_acum = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes_acum = dUltimo_dia_mes_acum -1 UNITS MONTH;
	LET dUltimo_dia_mes_acum = LPAD(MONTH(dUltimo_dia_mes_acum),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes_acum))||'/'||YEAR(dUltimo_dia_mes_acum);
	
	LET dUltimo_dia_mes_acum_ext = YEAR(dUltimo_dia_mes_acum) || '-' || LPAD ( MONTH(dUltimo_dia_mes_acum), 2, '0') || '-' ||DAY(LAST_DAY(dUltimo_dia_mes_acum))|| ' 23:59:59.99999';
	
	
	--Para probar otros meses
	--LET dRango_dias_inicio ='11012022';
	--LET dRango_dias_inicio_ext = '2022-11-01 00:00:00.00000';
	--LET dUltimo_dia_mes_acum_ext = '2022-11-30 23:59:59.99999';
	
			let vsql = ''; 	   
			let vsql = 'echo "Fecha_Archivo|Fecha_txn|Total_txn|Monto_total|  ">'||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_eleven_acumulado'||'.txt';
			system vsql;
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_acumulado_eleven'||'.txt   '||
			           ' SELECT fecha_archivo,SUBSTR(fechahorainauth,1,10),COUNT(*),SUM(montomov)'||
					   ' FROM intercard:mco_conciliacion_aplicativos '||
					   ' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||
					   ' AND idreceptor = \"03\" '||
					   ' GROUP BY 1,2 ORDER BY fecha_archivo '||

					   '" >'||RUTA_DESTINO||'script_reg_eleven_acum.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_reg_eleven_acum.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_reg_eleven_acum.sql';
            system vsql;	 
            ---------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_acumulado_eleven'||".txt >> "||RUTA_DESTINO||TO_CHAR(dRango_dias_inicio,"%b")||'_eleven_acumulado'||'.txt';
            system vsql; 
            ----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_reg_eleven_acum.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_acumulado_eleven'||'.txt';
		    system vsql;
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--CREAR INFORMACIÃN DE ACLARACIÃN PARA OPERACIONES
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
		
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';
	
	LET dUltimo_dia_mes_acum = '';
	LET dUltimo_dia_mes_acum = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes_acum = dUltimo_dia_mes_acum -1 UNITS MONTH;
	LET dUltimo_dia_mes_acum = LPAD(MONTH(dUltimo_dia_mes_acum),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes_acum))||'/'||YEAR(dUltimo_dia_mes_acum);
	
	
	LET dUltimo_dia_mes_acum_ext = YEAR(dUltimo_dia_mes_acum) || '-' || LPAD ( MONTH(dUltimo_dia_mes_acum), 2, '0') || '-' ||DAY(LAST_DAY(dUltimo_dia_mes_acum))|| ' 23:59:59.99999';
	
	--Para probar otros meses
	--LET dRango_dias_inicio_ext = '2022-11-01 00:00:00.00000';
	--LET dUltimo_dia_mes_acum_ext = '2022-11-30 23:59:59.99999';
	
	--Cargar tabla tmp_mco_oxxo_seven
	TRUNCATE TABLE tmp_mco_oxxo_seven;
	LET vExecuteSQL ='';
	LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MCO_CONCI_APLI||'.unl'||
			' SELECT fecha_archivo,id_procesador,secuencia,autorizacion,numtarjeta,numcuenta,montomov,monto_mco,monto_cheq_cred,secuenciaextendida,montorealrevfzda,codreversa,tipo_txn,prodind,formato,codtran,'||
			' metodocaptura,idterminal,infreceptor,esnacional,pais,fechahorainauth,fechaconciliacion,fecha,hora,producto,tbl_mov,tbl_mco,tbl_movhis,resultado_final,cobro_comision,idreceptor'||
			' FROM intercard:mco_conciliacion_aplicativos   ' ||            
			' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||

			'" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_MCO_CONCI_APLI;            
		SYSTEM vExecuteSQL;    
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'chmod 755 '||RUTA_ORIGEN||SCRIPT_EJECUCION_MCO_CONCI_APLI;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL   =   '';
		LET vExecuteSQL   = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION_MCO_CONCI_APLI;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';		
		LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MCO_CONCI_APLI||'.unl'|| "' delimiter '|' "|| '32'||                          
						  "; INSERT INTO tmp_mco_oxxo_seven" || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_mco_conci_apli.txt';
		SYSTEM vExecuteSQL;
		
		--Se ejecuta el dbload en intercard con cortes cada 1000 registros
		LET vExecuteSQL = '';
		LET vExecuteSQL = vRutadbload||" -d intercard -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_mco_conci_apli.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_mco_conci_apli.log -n "||CONTADOR_TRANSACCIONES||" -r";
		SYSTEM vExecuteSQL;
		 
		--Borrado de todos los archivos generados en el proceso
		LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_MCO_CONCI_APLI||'*';
		SYSTEM vExecuteSQL;
		
		 LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MCO_CONCI_APLI||'*';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
		
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --Cargar Tabla tmp_mov_oxxo_seven
	
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
		
	LET dRango_dias_inicio_ext = YEAR(dRango_dias_inicio)||'-'||LPAD(MONTH(dRango_dias_inicio), 2, '0')||'-'||LPAD(DAY(dRango_dias_inicio), 2, '0')||' 00:00:00.00000';
	
	LET dUltimo_dia_mes_acum = '';
	LET dUltimo_dia_mes_acum = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dUltimo_dia_mes_acum = dUltimo_dia_mes_acum -1 UNITS MONTH;
	LET dUltimo_dia_mes_acum = LPAD(MONTH(dUltimo_dia_mes_acum),2,0)||'/'||DAY(LAST_DAY(dUltimo_dia_mes_acum))||'/'||YEAR(dUltimo_dia_mes_acum);
	
	LET dUltimo_dia_mes_acum_ext = YEAR(dUltimo_dia_mes_acum) || '-' || LPAD ( MONTH(dUltimo_dia_mes_acum), 2, '0') || '-' ||DAY(LAST_DAY(dUltimo_dia_mes_acum))|| ' 23:59:59.99999';
	
	--Para probar otros meses
	--LET dRango_dias_inicio_ext = '2022-11-01 00:00:00.00000';
	--LET dUltimo_dia_mes_acum_ext = '2022-11-30 23:59:59.99999';

	TRUNCATE TABLE tmp_mov_oxxo_seven;
	LET vExecuteSQL ='';
	LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MOVIMIENTOS||'.unl'||
			' SELECT secuencia, numtarjeta, monto, secuenciaextendida, montorealrevfzda, codreversa, prodind, formato,'||
			' codtran, metodocaptura, idterminal, infreceptor, esnacional, pais, fechahorainauth, idreceptor,'||
			' CASE WHEN idreceptor = ''02'' THEN SUBSTR(infreceptor, 17, 6)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2)'||
			' WHEN idreceptor =''03'' THEN SUBSTR(idterminal, 1, 5)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2)'||
			' END folio_suc_mov'||
			' FROM intercard:movimientohistorico   ' ||            
			' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||
			' AND prodind = \"02\" '||
			' AND formato = \"0200\" '||
			' AND codigoiso = \"00\" '||
			' AND codtran = \"28\" '||
			' AND transaccionorigen = \"2345\" '||
			' AND codreversa = \"0\" '||
			' AND movreversado = \"F\" '||
			
			'UNION ALL '||
			
			' SELECT secuencia, numtarjeta, monto, secuenciaextendida, montorealrevfzda, codreversa, prodind, formato,'||
			' codtran, metodocaptura, idterminal, infreceptor, esnacional, pais, fechahorainauth, idreceptor,'||
			' CASE WHEN idreceptor = ''02'' THEN SUBSTR(infreceptor, 17, 6)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2)'||
			' WHEN idreceptor =''03'' THEN SUBSTR(idterminal, 1, 5)||fechalocaltransaccion||SUBSTR(horalocaltransaccion, 0, 4)||SUBSTR(horamov,5,2)'||
			' END folio_suc_mov'||
			' FROM intercard:movimiento   ' ||            
			' WHERE fechahorainauth BETWEEN '''||dRango_dias_inicio_ext||''' AND '''||dUltimo_dia_mes_acum_ext||''' '||
			' AND prodind = \"02\" '||
			' AND formato = \"0200\" '||
			' AND codigoiso = \"00\" '||
			' AND codtran = \"28\" '||
			' AND transaccionorigen = \"2345\" '||
			' AND codreversa = \"0\" '||
			' AND movreversado = \"F\" '||
		
			'" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_MOVIMIENTOS;            
		SYSTEM vExecuteSQL;    
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'chmod 755 '||RUTA_ORIGEN||SCRIPT_EJECUCION_MOVIMIENTOS;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL   =   '';
		LET vExecuteSQL   = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION_MOVIMIENTOS;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';		
		LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MOVIMIENTOS||'.unl'|| "' delimiter '|' "|| '17'||                          
						  "; INSERT INTO tmp_mov_oxxo_seven " || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_movimientos.txt';
		SYSTEM vExecuteSQL;
		
		--Se ejecuta el dbload en intercard con cortes cada 1000 registros
		LET vExecuteSQL = '';
		LET vExecuteSQL = vRutadbload||" -d intercard -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_movimientos.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_registrar_movimientos.log -n "||CONTADOR_TRANSACCIONES||" -r";
		SYSTEM vExecuteSQL;
		 
		--Borrado de todos los archivos generados en el proceso
		LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_MOVIMIENTOS||'*';
		SYSTEM vExecuteSQL;
		
		 LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_MOVIMIENTOS||'*';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
	
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---Realizar el cruce entre tmp_mov_oxxo_seven vs tmp_mco_oxxo_seven.
	---El resultado obtenido meterlo en una tabla temporal.
	
	TRUNCATE TABLE descuadre_oxxo_seven;

	LET vExecuteSQL ='';
	LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN||'.unl'||
			' SELECT a.secuencia, a.numtarjeta,a.monto,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.prodind,a.formato,'||
			' a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.idreceptor,a.folio_suc_mov'||
			' FROM intercard:tmp_mov_oxxo_seven a LEFT JOIN tmp_mco_oxxo_seven b   ' ||            
			' ON a.numtarjeta = b.numtarjeta   ' ||
			' AND a.monto = b.montomov   ' ||
			' AND a.secuenciaextendida = b.secuenciaextendida  ' ||
			' WHERE b.secuenciaextendida IS NULL'||
					
			'" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN;            
		SYSTEM vExecuteSQL;    
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'chmod 755 '||RUTA_ORIGEN||SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL   =   '';
		LET vExecuteSQL   = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';		
		LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN||'.unl'|| "' delimiter '|' "|| '17'||                          
						  "; INSERT INTO descuadre_oxxo_seven" || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_cruce_oxxo_seven.txt';
		SYSTEM vExecuteSQL;
		
		--Se ejecuta el dbload en intercard con cortes cada 1000 registros
		LET vExecuteSQL = '';
		LET vExecuteSQL = vRutadbload||" -d intercard -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_cruce_oxxo_seven.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_registrar_cruce_oxxo_seven.log -n "||CONTADOR_TRANSACCIONES||" -r";
		SYSTEM vExecuteSQL;
		 
		--Borrado de todos los archivos generados en el proceso
		LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_CRUCE_OXXO_SEVEN||'*';
		SYSTEM vExecuteSQL;
		
		 LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_CRUCE_OXXO_SEVEN||'*';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
		
	--Se obtiene el nÃºmero de cliente-----------------------------------------------------------------------------------------------------------------------------------
	
	TRUNCATE TABLE descuadre_oxxo_seven_num_cliente;

	LET vExecuteSQL ='';
	LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE||'.unl'||
			' SELECT a.numcliente,b.secuencia,b.numtarjeta,b.monto,b.secuenciaextendida,b.montorealrevfzda,b.codreversa,b.prodind,b.formato,'||
				   ' b.codtran,b.metodocaptura,b.idterminal,b.infreceptor,b.esnacional,b.pais,b.fechahorainauth,b.idreceptor,b.folio_suc_mov'||
				   ' FROM descuadre_oxxo_seven b, intercard:tarjeta a '||
				   ' WHERE a.numtarjeta=b.numtarjeta '||
					
			'" >'||RUTA_ORIGEN||SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE;            
		SYSTEM vExecuteSQL;    
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'chmod 755 '||RUTA_ORIGEN||SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE;
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL   =   '';
		LET vExecuteSQL   = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_ORIGEN||SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE;
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';		
		LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE||'.unl'|| "' delimiter '|' "|| '18'||                          
						  "; INSERT INTO descuadre_oxxo_seven_num_cliente" || ";"||'"'||' > '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'registrar_descuadre_num_cliente.txt';
		SYSTEM vExecuteSQL;
		
		--Se ejecuta el dbload en intercard con cortes cada 1000 registros
		LET vExecuteSQL = '';
		LET vExecuteSQL = vRutadbload||" -d intercard -c "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"registrar_descuadre_num_cliente.txt -l "||RUTA_ORIGEN||PREFIJO_ARCHIVO||"err_registrar_descuadre_num_cliente.log -n "||CONTADOR_TRANSACCIONES||" -r";
		SYSTEM vExecuteSQL;
		 
		--Borrado de todos los archivos generados en el proceso
		LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||SCRIPT_EJECUCION_DESCUADRE_NUM_CLIENTE||'*';
		SYSTEM vExecuteSQL;
		
		 LET vExecuteSQL = '';
		LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||NOMBRE_ARCHIVO_DESCUADRE_NUM_CLIENTE||'*';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	LET dRango_dias_inicio = '';
	LET dRango_dias_inicio = LPAD(MONTH(TODAY),2,0)||'/'||'01'||'/'||YEAR(TODAY);
	LET dRango_dias_inicio = dRango_dias_inicio -1 UNITS MONTH;
	--Para probar otro mes
	--LET dRango_dias_inicio = '11012022';
	------------------------------------------------------------------------------------------------------------------------
	--Se genera el archivo de aclaraciÃ³n de descuadre OXXO 7ELEVEN
	 ----------------------------------------------------------------------------------------------------------------------- 
		    let vsql = ''; 	   
			let vsql = 'echo "Numcliente|Secuencia|Num_tarjeta|Num_cuenta|Monto|Secuencia_extendida|Montorealrevfzda|Codreversa|Proind|Formato|Cod_tran|Metodo_captura|Id_terminal|Inf_receptor|Esnacional|Pais|Fechahorainauth|Idreceptor|Folio_suc_mov|  ">'||RUTA_DESTINO||'Aclaracion_oxxo_eleven_'||TO_CHAR(dRango_dias_inicio,"%b")||YEAR(dRango_dias_inicio)||'.txt';
			system vsql;
			
			let vsql = '';
			let vsql=  'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;  UNLOAD TO  '||RUTA_DESTINO||'registros_aclaracion'||'.txt   '||
			           ' SELECT DISTINCT(a.num_cliente),a.secuencia,a.numtarjeta,b.numcuenta,a.monto,a.secuenciaextendida,a.montorealrevfzda,a.codreversa,a.prodind,a.formato, '||
					   ' a.codtran,a.metodocaptura,a.idterminal,a.infreceptor,a.esnacional,a.pais,a.fechahorainauth,a.idreceptor,a.folio_suc_mov '||
					   ' FROM descuadre_oxxo_seven_num_cliente a LEFT JOIN  intercard:mco_conciliacion_aplicativos b '||
					   ' on a.numtarjeta=b.numtarjeta '||
			
					   '" >'||RUTA_DESTINO||'script_claracion_oxxo_eleven_reg.sql';     
			system vsql;
			-----------------------------------------------------------------------------------------------------------------	
		    let vsql ='';			
		    let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_claracion_oxxo_eleven_reg.sql';
		    system vsql;
		    
		    let vsql = '';
			let vsql = TRIM(cRutaInformix)||'dbaccess intercard '||RUTA_DESTINO||'script_claracion_oxxo_eleven_reg.sql';
            system vsql;	 
            -----------------------------------------------------------------------------------------------------------------
		    --Se asigna el contenido al archivo txt
		    let vsql ='';
            let vsql = "sed 's/|$//g' "||RUTA_DESTINO||'registros_aclaracion'||".txt >> "||RUTA_DESTINO||'Aclaracion_oxxo_eleven_'||TO_CHAR(dRango_dias_inicio,"%b")||YEAR(dRango_dias_inicio)||'.txt';
            system vsql; 
            -----------------------------------------------------------------------------------------------------------------
			--Eliminar archivos sobrantes
		 
		    let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_claracion_oxxo_eleven_reg.sql';
            system vsql;
		     
		    let vsql = '';
		    let vsql ='rm -f '||RUTA_DESTINO||'registros_aclaracion'||'.txt';
		    system vsql;
	
	
	
	
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	END;

	RETURN vcodret1, vcodret3;

END PROCEDURE;