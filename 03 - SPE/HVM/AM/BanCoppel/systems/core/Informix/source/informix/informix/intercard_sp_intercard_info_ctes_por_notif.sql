CREATE PROCEDURE "informix".sp_intercard_info_ctes_por_notif( pNumCliente VARCHAR(20), pNombreCompleto CHAR(1)) 

    RETURNING VARCHAR(5) AS rCodigoRetorno, VARCHAR (80) as rMensajeRetorno, VARCHAR(20) as rNumeroCliente,
        VARCHAR(26) as rPrimerNombre, VARCHAR(26) as rSegundoNombre, VARCHAR(26) as rPrimerApellido, VARCHAR(26) as rSegundoApellido,
        VARCHAR(13) as rNumTelefono, VARCHAR(100) as rCorreoElect;    

    DEFINE SQL_ERR   INTEGER;
    DEFINE ISAM_ERR   INTEGER;
    DEFINE ERROR_INFO  CHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(30);
    
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRetorno VARCHAR(80);
    
    DEFINE vCteRegistrado SMALLINT;
    
    DEFINE vNumeroCliente VARCHAR(20);
    DEFINE vNumeroTarjeta VARCHAR(16);
    DEFINE vPlantilla VARCHAR(12);
    DEFINE vContrato VARCHAR(10);
    
    DEFINE vTerminacionTarjeta CHAR(4);
    DEFINE vPrimerNombre VARCHAR(26);
    DEFINE vSegundoNombre VARCHAR(26);    
    DEFINE vApellidoPaterno VARCHAR(26);
    DEFINE vApellidoMaterno VARCHAR(26);    
    DEFINE vNumTelefono VARCHAR(13);
    DEFINE vCorreoElect VARCHAR(100);
    DEFINE vNumCliente CHAR(80);
    DEFINE vFechaSistema  DATETIME YEAR TO FRACTION(5);    
    DEFINE VALIDAR_SI CHAR(1);
    DEFINE VALIDAR_NO CHAR(1);
    
    LET SQL_ERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
    
    LET vCodigoRetorno = '00000';
    LET vMensajeRetorno = 'Inicio de ejecucion';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';          
        
    LET vNumeroCliente = TRIM(pNumCliente);    
    LET vCorreoElect = '0';
    
    LET vCteRegistrado = 0;
    LET vPlantilla = NULL;
    LET vContrato = '';
    LET vNumTelefono = '0';    
    LET vPrimerNombre = '0';
    LET vSegundoNombre = '0';    
    LET vApellidoPaterno = '0';
    LET vApellidoMaterno = '0';
    LET vNumCliente = '';
    LET vFechaSistema  = sysdate;    
    LET VALIDAR_SI = 'S';
    LET VALIDAR_NO = 'N';
    
    --SET DEBUG FILE TO RUTA_ORIGEN || "debug_sp_intercard_info_ctes.out";
    --TRACE ON;    
	
	BEGIN

        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excep_sp_intercard_info_ctes.err" WITH APPEND;
            TRACE ON;
            
            IF ( SQL_ERR <> 0 ) THEN
                LET vCodigoRetorno = SQL_ERR;
                LET vMensajeRetorno = ERROR_INFO;                
                    RETURN vCodigoRetorno, vMensajeRetorno, NVL(vNumeroCliente, '0'),  
                            NVL(vPrimerNombre, '0'), NVL(vSegundoNombre, '0'), NVL(vApellidoPaterno, '0'), 
                                NVL(vApellidoMaterno, '0'), NVL(vNumTelefono, '0'), NVL(vCorreoElect, '0');
            END IF
			
        END EXCEPTION

        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;        
        
        
        IF ( ( pNombreCompleto <> VALIDAR_NO AND pNombreCompleto <> VALIDAR_SI) OR              
              ( pNumCliente IS NULL OR pNumCliente = '') ) THEN
              
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Parametros incorrectos sp_intercard_info_ctes_por_notif';           
            RETURN vCodigoRetorno, vMensajeRetorno, NVL(vNumeroCliente, '0'),  
                    NVL(vPrimerNombre, '0'), NVL(vSegundoNombre, '0'), NVL(vApellidoPaterno, '0'), NVL(vApellidoMaterno, '0'), 
                        NVL(vNumTelefono, '0'), NVL(vCorreoElect, '0');
        
        END IF
        
        SELECT telefono as num_telefono
            INTO vNumTelefono
        FROM bdinteg:"informix".si_telefonos_actual	
            WHERE numcte = vNumeroCliente
                AND tipo_tel = '2'
                    AND status_tel = 'A';

        SELECT correo_elec as correo_elec
            INTO vCorreoElect
            FROM bdinteg:"informix".si_correos
        WHERE numcte = vNumeroCliente
            AND tipo_correo = '1'
                AND status_correo = 'A';
                 
         SELECT nombre1, nombre2, apell_paterno, apell_materno
            INTO vPrimerNombre, vSegundoNombre, vApellidoPaterno, vApellidoMaterno
        FROM bdinteg:"informix".si_cliente
            WHERE numcte = vNumeroCliente;
            
        IF (  ( vNumTelefono IS NULL OR vNumTelefono == '' OR LENGTH(TRIM(vNumTelefono))  = 0) AND 
                (vCorreoElect IS NULL OR vCorreoElect == '' OR LENGTH(TRIM(vCorreoElect)) = 0) ) THEN
            
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Sin informacion del cliente';
            LET vNumTelefono = '0';
            LET vCorreoElect = '0';
            RETURN vCodigoRetorno, vMensajeRetorno, NVL(vNumeroCliente, '0'),  
                    NVL(vPrimerNombre, '0'), NVL(vSegundoNombre, '0'), NVL(vApellidoPaterno, '0'), NVL(vApellidoMaterno, '0'), 
                        NVL(vNumTelefono, '0'), NVL(vCorreoElect, '0');
            
        END IF        
        
        --Si la longitud del nombre1 es menor a 3 se utiliza el nombre 2.
        --Implementacion para enviar mensaje personalizado en Latinia.
        IF ( pNombreCompleto == VALIDAR_NO ) THEN
        
            LET vPrimerNombre = TRIM(vPrimerNombre);        
            IF ( LENGTH ( TRIM(vPrimerNombre)) < 3 ) THEN
                LET vPrimerNombre = TRIM(vSegundoNombre);
                LET vSegundoNombre = NULL;
            END IF 
        END IF
        
        LET vCodigoRetorno = '00000';
        LET vMensajeRetorno = 'Informacion obtenida correctamente.';

        RETURN vCodigoRetorno, vMensajeRetorno, NVL(vNumeroCliente, '0'),  
            NVL(vPrimerNombre, '0'), NVL(vSegundoNombre, '0'), NVL(vApellidoPaterno, '0'), NVL(vApellidoMaterno, '0'), NVL(vNumTelefono, '0'), NVL(vCorreoElect, '0');
            
	END
				
END PROCEDURE
DOCUMENT
'Autor: Armando Garcia Ortiz',
'Base de datos: intercard',
'Fecha de creación: 27 de enero del 2021',
'Objetivo: Obtener la informacion del cliente, telefono movil, correo electronico',
'para utilizar los valores en el envio de mensajes hacia Latinia mediante mensajes de texto o correo electronico',
'#2',
'Fecha de modificacion: 07 de marzo del 2022',
'Modificacion: La consulta del nombre de cliente se debe ejecutar aunque no tenga teléfono o correo electrónico asociado',
'y de cualquier manera regresa 00001 si no tiene datos asociados.'
;

CREATE PROCEDURE "informix".sp_rpt_vau()
    
    RETURNING CHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO;

    DEFINE CODIGO_RETORNO 			CHAR(6);
    DEFINE MENSAJE_RETORNO 			VARCHAR(80);        
    DEFINE vTotalRegistros 			INTEGER;
    DEFINE vTotalInterna 			INTEGER;
    DEFINE vRegistrosMaxPorArchivo 	INTEGER;
    DEFINE vExecuteSQL 				CHAR(1150);
    DEFINE vContadorArchivos 		VARCHAR(05);
    DEFINE vNumInicioRegistros	 	INTEGER;    
    DEFINE vNombreScript 			CHAR(30);   
    DEFINE vFechaDia 				DATE;   
    DEFINE vsYear 					VARCHAR(02);   
    DEFINE vsMes 					VARCHAR(02);   
    DEFINE vsDia 					VARCHAR(02);   
    DEFINE vsNumeroArchivo			VARCHAR(05);   
    DEFINE vsNumeroArchivo_2		VARCHAR(05);   
    DEFINE vsRelleno				VARCHAR(54);   
    DEFINE vsRellenoD				VARCHAR(21);   
    DEFINE vsRellenoT				VARCHAR(56);   
    


    DEFINE RUTA_ORIGEN 				VARCHAR(30);
    DEFINE RUTA_UNLOAD 				VARCHAR(30);
    DEFINE TipoPlantilla 			VARCHAR(50);
    DEFINE HEADER		 			VARCHAR(30);
    DEFINE TRAILER		 			VARCHAR(20);
	DEFINE vTotalRegistrosTrailer	VARCHAR(09);
	DEFINE TipoPlantilla_2 			VARCHAR(50);
	DEFINE vsFechaArchivo 			VARCHAR(06);
    
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET vTotalRegistros = 0;
    LET vTotalInterna = 0;
    LET vRegistrosMaxPorArchivo = 1;
    LET vContadorArchivos = '1';
    LET vNumInicioRegistros = 0;
    LET vNombreScript = 'script_rpt_vau_archivos.sql';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET RUTA_UNLOAD = '/RESPALDOSNEW/';
    LET TipoPlantilla = 'REP_VAU_INICIAL';
	LET vFechaDia = CURRENT;
	LET vsYear = '';
	LET vsMes = '';
	LET vsDia = '';
	LET vsNumeroArchivo = '';
	LET vsNumeroArchivo_2 = '';
	LET vsRelleno = '';
	LET vsRellenoD = '';
	LET vsRellenoT = '';
	LET HEADER = 'header.unl';
	LET TRAILER = 'total_tarjetas';
	LET vTotalRegistrosTrailer = '';
	LET TipoPlantilla_2 = '739119-1234.aup.prod.iu7.BCPL_'; -- 
    LET vsFechaArchivo = ''; 

	
    BEGIN    
    
        --SET DEBUG FILE TO RUTA_ORIGEN||"sp_rpt_vau_archivos.out";
        --TRACE ON;    
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		SELECT COUNT(*) conteo_total 
			INTO vTotalRegistros
		FROM tbl_tarjetas_vau_final;
    
        --Obtener el NUMERO MAXIMO DE REGISTROS POR ARCHIVO. 
        --vRegistrosMaxPorArchivo: Valor inicial del requerimiento 200 (29.junio)
        --- bl_inter_parametros

		SELECT valores
			INTO vRegistrosMaxPorArchivo
			FROM tbl_inter_parametros
			WHERE empresa = '001'
		AND cond_busqueda ='rtp_vau_archivo';
        
	
		SELECT valores
			INTO vContadorArchivos
			FROM tbl_inter_parametros
			WHERE empresa = '001'
		AND cond_busqueda ='contador_vau_archivo';
		
		IF ( vContadorArchivos = '99999' ) THEN

		UPDATE tbl_inter_parametros SET valores = '1' WHERE empresa = '001' AND cond_busqueda ='contador_vau_archivo';
		
		LET vContadorArchivos = '1';

		ELSE

		LET vContadorArchivos = vContadorArchivos;

		END IF;
		
		
        -- en el total de registros con el valor cero (0)
        IF (vTotalRegistros = 0) THEN
		
			LET CODIGO_RETORNO  = '00000';
			LET MENSAJE_RETORNO = 'PROCESO EXITOSO, SIN REGISTROS';

            RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
            
        END IF;       
        
		IF ( (SELECT COUNT(*) FROM intercard:systables WHERE tabname = 'tmp_trailer_vau') = 1 ) THEN

		TRUNCATE TABLE tmp_trailer_vau DROP STORAGE;


		END IF;
		
		LET vsYear = SUBSTR(vFechaDia,9,2);
		LET vsMes = SUBSTR(vFechaDia,1,2);
		LET vsDia = SUBSTR(vFechaDia,4,2);
		
		LET vsFechaArchivo = vsDia||vsMes||vsYear;
		
        --La consulta tiene mas de un registro | Creacion de los 'n' archivos resultantes
		
        IF (vTotalRegistros >  0) THEN            
           
            WHILE (vTotalRegistros > 0 ) LOOP
                

                
                LET vTotalInterna = vTotalRegistros - vRegistrosMaxPorArchivo; 

                IF (vTotalInterna <= 0) THEN
                    LET vTotalInterna = vTotalRegistros;
                ELIF (vTotalInterna > 0) THEN
                    LET vTotalInterna = vRegistrosMaxPorArchivo;
                END IF;
				
				LET vsNumeroArchivo = LPAD(vContadorArchivos, 5, 0);
				LET vsNumeroArchivo_2 = LPAD(vContadorArchivos, 5, 0);
				LET vsRelleno = TRIM(vsRelleno);

				LET vsRellenoT = TRIM(vsRellenoT);
				LET vsRelleno = LPAD(NVL(vsRelleno,' '), 54,' ');
				LET vsRellenoD = LPAD(NVL(vsRellenoD,' '), 21,' ');
				LET vsRellenoT = LPAD(NVL(vsRellenoT,' '), 56,' ');

				--- Se realiza Header
              
				LET vExecuteSQL = ''; 	   
				LET vExecuteSQL = 'echo "015022'||vsMes||vsDia||vsYear||vsNumeroArchivo||vsRelleno||'" > '||RUTA_UNLOAD||TipoPlantilla_2||vsFechaArchivo||'_'||vsNumeroArchivo_2;
				system vExecuteSQL;
                
                --Consulta utilizada para ir paginando los registros en cada archivo iniciando
                --del registro 0 hasta la base de la variable vRegistrosMaxPorArchivo en cada ciclo.
                ---SELECT SKIP '||vNumInicioRegistros||' FIRST  vRegistrosMaxPorArchivo                
                
                LET vExecuteSQL = '';
                LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; '||
								  'UNLOAD TO "'||RUTA_UNLOAD||TipoPlantilla||'"_'||vsNumeroArchivo_2||'.unl '||
								  'SELECT SKIP '||vNumInicioRegistros||' FIRST '||vRegistrosMaxPorArchivo||
								  ' \"1\",RPAD(NVL(numtarjeta,\" \"),19,\" \"),RPAD(NVL(fechaexp,\" \"),4,\" \"),'||
								  ' RPAD(NVL(numtarjetasustituta,\" \"),19,\" \"), RPAD(NVL(fechaexpsustituta,\" \"),4,\" \"),'||
								  ' RPAD(NVL(identificadorvau,\" \"),1,\" \"),'||'LPAD(NVL(filerdetalle,\" \"),23,\" \") AS relleno'||
								  ' FROM intercard:tbl_tarjetas_vau_final'||
								  ';">'||RUTA_UNLOAD||vNombreScript; 
                SYSTEM vExecuteSQL;
				

                LET vExecuteSQL ='';
                LET vExecuteSQL= 'dbaccess intercard '||RUTA_UNLOAD||vNombreScript;
                SYSTEM vExecuteSQL;
				
				--- GeneraciÃ³n de Trailer -- INICIO
				---Paso #1
                LET vExecuteSQL ='';
                LET vExecuteSQL = 'wc -l '||RUTA_UNLOAD||TipoPlantilla||'_'||vsNumeroArchivo_2||'.unl '|| 
								  '>'||RUTA_UNLOAD||TRAILER||'.txt';
                SYSTEM vExecuteSQL;
                
				---Paso #2
                LET vExecuteSQL ='';
                LET vExecuteSQL = "sed 's/^ *//' "||RUTA_UNLOAD||TRAILER||".txt > "||RUTA_UNLOAD||TRAILER||"_T.txt";
                SYSTEM vExecuteSQL;
				
                ---Se corta por columnas para pegarlos posteriormente con separaciÃ³n de pipes
                LET vExecuteSQL ='';
                LET vExecuteSQL ='cut -d " " -f1 '||RUTA_UNLOAD||TRAILER||'_T.txt  > '||RUTA_UNLOAD||'vau_num_registros.txt';
                SYSTEM vExecuteSQL;
                
                LET vExecuteSQL ='';
                LET vExecuteSQL ='cut -d " " -f2 '||RUTA_UNLOAD||TRAILER||'_T.txt  > '||RUTA_UNLOAD||'vau_nombre_archivo.txt';
                SYSTEM vExecuteSQL;
                
                --Campo "falso" pero permite eliminar el escaneo secuencial.
                LET vExecuteSQL ='';
                LET vExecuteSQL ='echo "001" > '||RUTA_UNLOAD||'vau_empresa.txt';
                SYSTEM vExecuteSQL;
                
                --Se genera el archivo con columnas separadas con pipes
                LET vExecuteSQL ='';
                LET vExecuteSQL ='paste -d "|" ' ||RUTA_UNLOAD||'vau_empresa.txt  ' ||RUTA_UNLOAD||'vau_num_registros.txt  ' ||RUTA_UNLOAD||'vau_nombre_archivo.txt   > ' ||RUTA_UNLOAD||TRAILER||'_T.txt';
                SYSTEM vExecuteSQL;
                
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = "echo "||'"'|| "file '"|| RUTA_UNLOAD||TRAILER||'_T.txt' || "' delimiter '|' "|| '3'||
							"; insert into tmp_trailer_vau" || ";"||'"'||' > '||RUTA_UNLOAD||'carga_trailer_vau.txt';
					SYSTEM vExecuteSQL;
				
				LET vExecuteSQL = '';
				LET vExecuteSQL = "dbload -d intercard -c "||RUTA_UNLOAD||"carga_trailer_vau.txt -l "||RUTA_UNLOAD||"err_carga.log -n 1000 -r";
				SYSTEM vExecuteSQL;
				
				SELECT total_registros 
					INTO vTotalRegistrosTrailer
				FROM tmp_trailer_vau
                    WHERE empresa = '001';
				
				LET vTotalRegistrosTrailer = LPAD(vTotalRegistrosTrailer,9,0);
				
				
                --- GeneraciÃ³n de Trailer -- FIN
				

            
                --Eliminacion de pipe de cada registro.
                LET vExecuteSQL ='';
                LET vExecuteSQL = "sed 's/|//g' "||RUTA_UNLOAD||TipoPlantilla||"_"||vsNumeroArchivo_2||".unl >> "||RUTA_UNLOAD||TipoPlantilla_2||vsFechaArchivo||'_'||vsNumeroArchivo_2;
                SYSTEM vExecuteSQL;
				
				-- Se Coloca Trailer
				
				LET vExecuteSQL = ''; 	   
				LET vExecuteSQL = 'echo "915022'||vTotalRegistrosTrailer||vsRellenoT||'" >> '||RUTA_UNLOAD||TipoPlantilla_2||vsFechaArchivo||'_'||vsNumeroArchivo_2;
				system vExecuteSQL;
				
			
				--- Eliminacion de Archivos

				LET vExecuteSQL = '';
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||vNombreScript;
                SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||'carga_trailer_vau.txt';
                SYSTEM vExecuteSQL;

				LET vExecuteSQL = '';
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||'err_carga.log';
                SYSTEM vExecuteSQL;
                
                LET vExecuteSQL = '';
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||'vau_*';
                SYSTEM vExecuteSQL;

				LET vExecuteSQL = ''; 
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||TipoPlantilla||'_'||vsNumeroArchivo_2||'.unl';
                SYSTEM vExecuteSQL;

				LET vExecuteSQL = ''; 
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||TRAILER||".txt";
                SYSTEM vExecuteSQL;
				
				LET vExecuteSQL = ''; 
                LET vExecuteSQL ='rm -f  '||RUTA_UNLOAD||TRAILER||"_T.txt";
                SYSTEM vExecuteSQL;

                
                --El numero vRegistrosMaxPorArchivo es la base de registros por archivo
                LET vNumInicioRegistros = vNumInicioRegistros + vRegistrosMaxPorArchivo;
                
                
                --Se realiza una suma de la variable vNumInicioRegistros (cero) mas vRegistrosMaxPorArchivo
                --Para que en ciclo 2 el SKIP comience en el resultado de vNumInicioRegistros
				
				LET vContadorArchivos = vContadorArchivos::INTEGER + 1;
				UPDATE tbl_inter_parametros SET valores = vContadorArchivos WHERE empresa = '001' AND cond_busqueda ='contador_vau_archivo';
               
               --Se actualiza la variable de registros faltantes por ingresar en el archivo.
                LET vTotalRegistros = vTotalRegistros - vTotalInterna;
				
			   -- TRUNCATE de la tabla de trailer
			   TRUNCATE TABLE tmp_trailer_vau DROP STORAGE;
			   
            END LOOP;
            
        END IF;       
       
        RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
    
    END
    
END PROCEDURE;