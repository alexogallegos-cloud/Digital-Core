CREATE PROCEDURE "informix".sp_depuracion_historica()
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
    
	--  Variables para datos de primary key
	define  vfechacargaini      DATE;
	define  vfechacargafin      DATE;
	define  vfechacargainihora  DATETIME YEAR to FRACTION(5);
	define  vfechacargafinhora  DATETIME YEAR to FRACTION(5);	
	define  vfechahorabase      DATETIME YEAR to FRACTION(5);
	DEFINE   RUTA_ORIGEN  VARCHAR(80);      
    DEFINE vExecuteSQL LVARCHAR(8000);	 
    DEFINE PREFIJO_SCRIPTS CHAR(18);
	DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(15);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;

	let     vfechahorabase = '';
    let     vfechacargaini = '';
	let     vfechacargafin = '';
    let     vfechacargainihora  = '';
	let     vfechacargafinhora  = '';
	let     p_cod_ret = '00000';
	let     p_mensaje = 'Proceso Exitoso';

	LET vExecuteSQL = '';
	LET PREFIJO_SCRIPTS = 'movimientohis_resp';
	LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET CONTADOR_TRANSACCIONES = 1000;
		 
    --LET RUTA_ORIGEN = '/resplogifx/';  -- Alternativa 1  	
	--LET RUTA_ORIGEN = '/pisa/pisabanco/pisa_ftes/syndein/coppel/InterActSW/bin/authorizerj/cron/'; -- Pruebas
      LET RUTA_ORIGEN = '/RESPALDOSNEW/'; 
	 	 
    --SET DEBUG FILE TO RUTA_ORIGEN || "inidep.out";
    --TRACE ON;
 
 BEGIN
 
          ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_depuracion_historica.err.out";
            TRACE ON;
            
            IF ( SQL_ERR <> 0 ) THEN
                LET P_COD_RET = SQL_ERR;
                LET P_MENSAJE = ERROR_INFO;
                 RETURN P_COD_RET, P_MENSAJE;
            END IF;
            
           END EXCEPTION;
--------------------------------------------------------------	
	
SET ISOLATION TO DIRTY READ;	
SET LOCK MODE TO WAIT 3;

        SELECT MIN(fechahorainauth)  
        INTO vfechahorabase
		FROM intercard:"informix".MovimientoHistorico; 
 
 		LET vfechacargainihora = SUBSTRING(vfechahorabase FROM  1 FOR 10) || ' 00:00:00.00000';
		--LET vfechacargafinhora = SUBSTRING(vfechahorabase FROM  1 FOR 10) || ' 10:00:00.00000'; --   Pruebas	 
        LET vfechacargafinhora = SUBSTRING(vfechahorabase FROM  1 FOR 10) || ' 23:59:59.99999'; -- Productivo	 
 
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
 
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'*';		
        SYSTEM vExecuteSQL;
 
        LET vExecuteSQL  = '';
		LET vExecuteSQL = 'echo "SET ISOLATION DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'.unl '  ||         		 
		' SELECT * FROM intercard:movimientohistorico  where fechahorainauth  ' ||
        ' between  ''"'||vfechacargainihora||'"'' and ''"'||vfechacargafinhora||'"'' ;"> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_unl.sql';
        SYSTEM vExecuteSQL;
 
  		LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_unl.sql';
        SYSTEM vExecuteSQL;
        ----------------------
	    -- Ejecuta Shell para la generaciÃ³n del Script con las tarjetas a eliminar. 
        LET vExecuteSQL = ''; 
	    LET vExecuteSQL = 'cd '||RUTA_ORIGEN||''; 		
		SYSTEM vExecuteSQL;
		
		LET  vExecuteSQL = ''; 
		LET  vExecuteSQL = 'chmod 777 gen_depuracion_his.sh';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = ''; 
		LET vExecuteSQL = 'sh gen_depuracion_his.sh';
        SYSTEM vExecuteSQL;
	    ----------------------
		---Elimina los registros de la tabla origen 
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||'delete_depuracion_his.sql';
        SYSTEM vExecuteSQL;				
		---------------------
        --- Genera dbload para la carga de registros a la tabla historica destino
 	    LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'.unl' || "' delimiter '|' "|| '81'||                          
                          "; INSERT INTO movimientohistorico_dep" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_movs.txt';
        SYSTEM vExecuteSQL; 

        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_movs.txt -l "||PREFIJO_SCRIPTS||"err_tarj_paso.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;  
 
  
        RETURN 	P_COD_RET,P_MENSAJE;
 END;

END PROCEDURE;