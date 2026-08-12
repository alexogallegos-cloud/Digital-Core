CREATE PROCEDURE "informix".sp_trans_bitac_envios_pivote( pFechaBusqInicial DATETIME YEAR TO SECOND, pFechaBusqFinal DATETIME YEAR TO SECOND, pAnio CHAR(4) )
    RETURNING CHAR (5) as rCODIGO_RETORNO, CHAR(120) as rMENSAJE_RESPUESTA;
    
    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);
    
	DEFINE vCODIGO_RETORNO CHAR(5);
    DEFINE vMENSAJE_RETORNO CHAR(120);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(80);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;    
    DEFINE NOMBRE_UNL_ARCHIVO VARCHAR(33);
    DEFINE SCRIPT_EJECUCION VARCHAR(34);
    DEFINE SCRIPT_UPD_STS VARCHAR(40);
    DEFINE PREFIJO_ARCHIVO VARCHAR(13);
    DEFINE NOM_ARCH_REG_CNC_PIV VARCHAR(33);
    DEFINE NOM_ARCH_ERR_CNC_PIV VARCHAR(33);    
    DEFINE vExecuteSQL LVARCHAR(5000);    
    DEFINE vIndicadorProceso CHAR(1);        
    DEFINE vAnio VARCHAR(7);
	  
    LET vCODIGO_RETORNO = '00000';
    LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    
    LET vExecuteSQL = '';
    LET CONTADOR_TRANSACCIONES = 1000;
    
    LET vAnio = pAnio;    
    
    LET NOMBRE_UNL_ARCHIVO = '';
    LET NOM_ARCH_REG_CNC_PIV = '';
    LET NOM_ARCH_ERR_CNC_PIV = '';
    LET PREFIJO_ARCHIVO = 'tran_bit_piv_';
    LET vIndicadorProceso = '0';
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "debug_sp_trans_bitac_envios_pivote.out";                                                
    --TRACE ON;        
	
    BEGIN 		

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excep_sp_trans_bitac_envios_pivote.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current||' '||'vIndicadorProceso =>'||vIndicadorProceso;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;


        LET NOMBRE_UNL_ARCHIVO = PREFIJO_ARCHIVO||'piv_'||vAnio||'.unl';
        LET SCRIPT_EJECUCION = PREFIJO_ARCHIVO||'ejec_piv_'||vAnio||'.sql';
        LET SCRIPT_UPD_STS = PREFIJO_ARCHIVO||'ejec_upd_sts_piv_'||vAnio||'.sql';
        LET NOM_ARCH_REG_CNC_PIV = PREFIJO_ARCHIVO||'reg_piv_'||vAnio||'.txt';
        LET NOM_ARCH_ERR_CNC_PIV = PREFIJO_ARCHIVO||'err_piv_'||vAnio||'.log';           

        TRUNCATE TABLE intercard:"informix".tbl_bit_envios_pivote DROP STORAGE;
        
        LET vIndicadorProceso = '1';
        
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO||
        ' SELECT secuencial, id_proceso, tarjeta, fecha_insert, 0 '  ||
        '    FROM intercard:"informix".bitacoraenvios_tjts_'||vAnio||
        ' WHERE fecha_insert  BETWEEN '''||pFechaBusqInicial||''' AND '''||pFechaBusqFinal||''' '||
         '" >'||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;            
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;

        LET vIndicadorProceso = '2';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO|| "' delimiter '|' "|| '5'||                          
                          "; INSERT INTO tbl_bit_envios_pivote; "||'"'||' > '||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_REG_CNC_PIV;
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_REG_CNC_PIV||" -l "||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_ERR_CNC_PIV||" -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' echo UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".bitacoraenvios_tjts_'||vAnio||' > '||RUTA_UNLOAD_RESPALDOS||SCRIPT_UPD_STS;
        SYSTEM vExecuteSQL;    
         
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_UPD_STS;
        SYSTEM vExecuteSQL;
        
        LET vIndicadorProceso = '3';
            
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
        
        

        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;	
		
	END
END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 19 de abril del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Componente principal para registrar la informacion a la tabla pivote de la bitacora de envios'
;

CREATE PROCEDURE "informix".sp_trans_bitac_envios_unload( pFechaBusqInicial DATETIME YEAR TO SECOND, pFechaBusqFinal DATETIME YEAR TO SECOND, pAnio CHAR(4) )
    RETURNING CHAR (5) as rCODIGO_RETORNO, CHAR(120) as rMENSAJE_RESPUESTA;
    
    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);
    
	DEFINE vCODIGO_RETORNO CHAR(5);
    DEFINE vMENSAJE_RETORNO CHAR(120);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(80);   
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;    
    DEFINE NOMBRE_UNL_ARCHIVO VARCHAR(33);
    DEFINE SCRIPT_EJECUCION VARCHAR(34);
    DEFINE SCRIPT_UPD_STS VARCHAR(40);
    DEFINE PREFIJO_ARCHIVO VARCHAR(13);
    DEFINE NOM_ARCH_REG_BIT_ENV VARCHAR(33);
    DEFINE NOM_ARCH_ERR_BIT_ENV VARCHAR(33);    
    DEFINE vExecuteSQL LVARCHAR(5000);    
    DEFINE vIndicadorProceso CHAR(1);
    DEFINE vAnio VARCHAR(7);
    DEFINE vTotalRegistros INTEGER;
    
 
    LET vCODIGO_RETORNO = '00000';
    LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    
    LET vExecuteSQL = '';
    LET vTotalRegistros = 0;
    LET CONTADOR_TRANSACCIONES = 1000;
    
    LET vAnio = pAnio;    
    
    LET NOMBRE_UNL_ARCHIVO = '';
    LET NOM_ARCH_REG_BIT_ENV = '';
    LET NOM_ARCH_ERR_BIT_ENV = '';
    LET PREFIJO_ARCHIVO = 'tr_bit_';
    LET vIndicadorProceso = '0';
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "debug_sp_trans_bitac_envios_unload.out";                                                
    --TRACE ON;        
	
    BEGIN 		

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excep_sp_trans_bitac_envios_unload.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current||' '||'vIndicadorProceso =>'||vIndicadorProceso;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;
        
        SELECT COUNT(*)
            INTO vTotalRegistros
        FROM intercard:"informix".bitacoraenvios_tjts
            WHERE fecha_insert  BETWEEN pFechaBusqInicial AND pFechaBusqFinal;

        IF ( vTotalRegistros = 0) THEN
            LET vCODIGO_RETORNO = '00001';
            LET vMENSAJE_RETORNO = 'Sin informacion para procesar la tabla de bitacoras';
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
        END IF
        
        
        LET NOMBRE_UNL_ARCHIVO = PREFIJO_ARCHIVO||'bit_env_'||vAnio||'.unl';
        LET SCRIPT_EJECUCION = PREFIJO_ARCHIVO||'ejec_bit_env_'||vAnio||'.sql';
        LET SCRIPT_UPD_STS = PREFIJO_ARCHIVO||'ejec_upd_sts_bit_env_'||vAnio||'.sql';
        LET NOM_ARCH_REG_BIT_ENV = PREFIJO_ARCHIVO||'reg_bit_env_'||vAnio||'.txt';
        LET NOM_ARCH_ERR_BIT_ENV = PREFIJO_ARCHIVO||'err_bit_env_'||vAnio||'.log';           

        LET vIndicadorProceso = '1';
        
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO||
        ' SELECT * '  ||
        '    FROM intercard:"informix".bitacoraenvios_tjts' ||
        ' WHERE fecha_insert  BETWEEN '''||pFechaBusqInicial||''' AND '''||pFechaBusqFinal||''' '||
         '" >'||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;            
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;

        LET vIndicadorProceso = '2';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO|| "' delimiter '|' "|| '8'||                          
                          "; INSERT INTO bitacoraenvios_tjts_"||vAnio|| ";"||'"'||' > '||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_REG_BIT_ENV;
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_REG_BIT_ENV||" -l "||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_ERR_BIT_ENV||" -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' echo UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".bitacoraenvios_tjts_'||vAnio||'>'||RUTA_UNLOAD_RESPALDOS||SCRIPT_UPD_STS;
        SYSTEM vExecuteSQL;    
         
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_UPD_STS;
        SYSTEM vExecuteSQL;
        
        LET vIndicadorProceso = '3';
            
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
        
        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;	
		
	END
END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 19 de abril del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Componente principal para descargar informacion de la tabla bitacoraenvios_tjts'
;

CREATE PROCEDURE "informix".sp_comparar_info_tbl_auth ()
    RETURNING VARCHAR(5) as rCODIGO_RETORNO, VARCHAR (250) as rMENSAJE_RETORNO;
	
    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);    
    DEFINE RUTA_DESTINO VARCHAR(80);
    DEFINE vCodigoRetorno VARCHAR(5);
    DEFINE vMensajeRetorno VARCHAR(250);
    
    DEFINE vPidvalidacionauth VARCHAR(6);
    DEFINE vPdescripcionvalida VARCHAR(80);
    DEFINE vPcodigoiso CHAR(2);
    DEFINE vPflagpermitevalidacion CHAR(1);
    DEFINE vPusuarioultmodif VARCHAR(12);
    DEFINE vPfechaultmodif DATETIME YEAR to FRACTION(5);
    DEFINE vPorden INTEGER;
    DEFINE vPvalidavip CHAR(1);
    DEFINE vPpermiteforzada CHAR(1);
    
    DEFINE vOnidvalidacionauth VARCHAR(6);
    DEFINE vOndescripcionvalida VARCHAR(80);
    DEFINE vOncodigoiso CHAR(2);
    DEFINE vOnflagpermitevalidacion CHAR(1);
    DEFINE vOnusuarioultmodif VARCHAR(12);
    DEFINE vOnfechaultmodif DATETIME YEAR to FRACTION(5);
    DEFINE vOnorden INTEGER;
    DEFINE vOnvalidavip CHAR(1);
    DEFINE vOnpermiteforzada CHAR(1);
    DEFINE vContadorActualizacion INTEGER;

    LET vPidvalidacionauth = '';
    LET vPdescripcionvalida  = '';
    LET vPcodigoiso  = '';
    LET vPflagpermitevalidacion  = '';
    LET vPusuarioultmodif  = '';
    LET vPfechaultmodif  = '';
    LET vPorden  = '';
    LET vPvalidavip  = '';
    LET vPpermiteforzada  = '';

    LET vOnidvalidacionauth = '';
    LET vOndescripcionvalida  = '';
    LET vOncodigoiso  = '';
    LET vOnflagpermitevalidacion  = '';
    LET vOnusuarioultmodif  = '';
    LET vOnfechaultmodif  = '';
    LET vOnorden  = '';
    LET vOnvalidavip  = '';
    LET vOnpermiteforzada  = '';
    LET vContadorActualizacion = 0;
    
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    LET RUTA_DESTINO = '/RESPALDOSNEW/';
    
    LET vCodigoRetorno = '00000';
    LET vMensajeRetorno = 'Sin Datos Modificados Auth';
    
    --SET DEBUG FILE TO RUTA_DESTINO|| 'sp_comparar_info_tbl_auth.out';
    --TRACE ON;
    
	BEGIN
    
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "excep_sp_comparar_info_tbl_auth.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCodigoRetorno = SQLERR;
                LET vMensajeRetorno = ERROR_INFO;                
                RETURN vCodigoRetorno, vMensajeRetorno;
            END IF;
			
        END EXCEPTION;
		
        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;
        
        FOREACH curIterarValidAuth WITH HOLD FOR
            SELECT  {+AVOID_FULL (bditarjeta:respaldo_control_reglas)}
                idvalidacionauth,  descripcionvalida, codigoiso, flagpermitevalidacion,
                usuarioultmodif, fechaultmodif, orden, validavip, permiteforzada   
                    INTO vPidvalidacionauth, vPdescripcionvalida,vPcodigoiso,
                        vPflagpermitevalidacion, vPusuarioultmodif, vPfechaultmodif, vPorden, vPvalidavip, vPpermiteforzada
                FROM bditarjeta:"informix".respaldo_control_reglas
                
                
                
            SELECT 
                idvalidacionauth,  descripcionvalida, codigoiso, flagpermitevalidacion,
                usuarioultmodif, fechaultmodif, orden, validavip, permiteforzada   
                INTO vOnidvalidacionauth, vOndescripcionvalida, vOncodigoiso,
                    vOnflagpermitevalidacion, vOnusuarioultmodif,vOnfechaultmodif, vOnorden, vOnvalidavip, vOnpermiteforzada
                FROM intercard:"informix".validacionauth
                    where idvalidacionauth = vPidvalidacionauth;
                
                
            IF ( vPidvalidacionauth = vOnidvalidacionauth )  THEN            
                IF ( ( vOndescripcionvalida <> vPdescripcionvalida ) OR
                        ( vOncodigoiso <> vPcodigoiso ) OR
                        ( vOnflagpermitevalidacion <> vPflagpermitevalidacion ) OR
                        ( vOnusuarioultmodif <> vPusuarioultmodif ) OR
                        ( vOnfechaultmodif <> vPfechaultmodif ) OR
                        ( vOnorden <> vPorden ) OR
                        ( vOnvalidavip <> vPvalidavip ) OR
                        ( vOnpermiteforzada <> vPpermiteforzada )
                    ) THEN
                
                    UPDATE intercard:"informix".validacionauth
                        SET 
                            descripcionvalida = vPdescripcionvalida,
                            codigoiso = vPcodigoiso,
                            flagpermitevalidacion = vPflagpermitevalidacion,
                            usuarioultmodif = vPusuarioultmodif,
                            fechaultmodif = vPfechaultmodif,
                            orden = vPorden,
                            validavip = vPvalidavip,
                            permiteforzada = vPpermiteforzada
                    WHERE idvalidacionauth = vPidvalidacionauth;                
                
                    LET vContadorActualizacion = vContadorActualizacion + dbinfo("sqlca.sqlerrd2");
                    IF (  vContadorActualizacion >= 1 ) THEN
                        LET vCodigoRetorno = '00000';
                        LET vMensajeRetorno = 'Registros Actualizados Auth #' ||vContadorActualizacion;
                    END IF
                
                END IF
                
                
                
            END IF
        
        END FOREACH
        
        RETURN vCodigoRetorno, vMensajeRetorno;
    END

END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 05 de junio del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Validacion y actualizacion de reglas en tabla principal'
;

CREATE PROCEDURE "informix".sp_monitoreocrecimientotablas ()
RETURNING 
VARCHAR(5) as Cod_ret, VARCHAR(80) as Men_ret, 
char (20) as Nombre_tabla, integer as Total_Registros, 
char (20) as Nombre_tabla2, integer as Total_Registros2, 
DATETIME YEAR to FRACTION(5) as FechaHoraConsulta;

	define  sql_err          		integer;
	define  isam_err         		integer;
	define  error_info       		varchar(80);
	define  ccodret 	       		varchar(5); 
	define  cmensajeretorno    		varchar(80);
	define 	cnombretabla			char (20);
	define 	itotalregistros		 	integer;
	define 	cnombretabla2			char (20);
	define 	itotalregistros2	 	integer;
	define  dtfechahoraconsulta     DATETIME YEAR to FRACTION(5);
		
 -- SET DEBUG FILE TO "/tmp/sp_monitoreocrecimientotablas.out";
 -- TRACE ON;

	let  sql_err          		= 0;
	let  isam_err         		= 0;
	let  error_info       		= '';
	let  ccodret 	       		= '00000';
	let  cmensajeretorno    	= 'Ejecucion sp_monitoreocrecimientotablas exitosa.';
	let  cnombretabla			= 'arqcvalidos';
	let  itotalregistros		= 0;
	let  cnombretabla2			= 'bitacoraatc';
	let  itotalregistros2		= 0;
	let  dtfechahoraconsulta    = current;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET ccodret     	= SQL_ERR;
	LET cmensajeretorno = ERROR_INFO;
    RETURN ccodret, cmensajeretorno, cnombretabla, itotalregistros, cnombretabla2, itotalregistros2, dtfechahoraconsulta;
    END EXCEPTION;
		
	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
	select
		count (*) 
		into itotalregistros
	from "informix".arqcvalidos;
	
	select
		count (*) 
		into itotalregistros2
	from "informix".bitacoraatc;
	
	let  dtfechahoraconsulta    = current;
	
	RETURN ccodret, cmensajeretorno, cnombretabla, itotalregistros, cnombretabla2, itotalregistros2, dtfechahoraconsulta;

END;

END PROCEDURE;