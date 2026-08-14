CREATE PROCEDURE "informix".sp_rpt_mc_obtener_movs_retiros( pNombreCorresponsal VARCHAR(10), pFechaBusqInicial DATETIME YEAR to FRACTION(5), pFechaBusqFinal DATETIME YEAR to FRACTION(5) )
    RETURNING CHAR (5) as rCODIGO_RETORNO, CHAR(120) as rMENSAJE_RESPUESTA;
    
    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);
    
	DEFINE vCODIGO_RETORNO CHAR(5);
    DEFINE vMENSAJE_RETORNO CHAR(120);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(80);
    DEFINE CORRESP_OXXO VARCHAR(7);
    DEFINE CORRESP_SEVEN VARCHAR(7);
    
	  
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;    
    DEFINE NOMBRE_UNL_ARCHIVO VARCHAR(33);
    DEFINE SCRIPT_EJECUCION VARCHAR(34);
    DEFINE PREFIJO_ARCHIVO VARCHAR(13);
    DEFINE NOM_ARCHIVO_REG_CORRESP VARCHAR(33);
    DEFINE NOM_ARCHIVO_ERR_CORRESP VARCHAR(33);    
    DEFINE vExecuteSQL LVARCHAR(5000);    
    DEFINE vCondicionesTipoMov VARCHAR(250);
    
    LET vCODIGO_RETORNO = '00000';
    LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    
    LET vExecuteSQL = '';
    LET CONTADOR_TRANSACCIONES = 1000;
    LET CORRESP_OXXO = 'OXXO';
    LET CORRESP_SEVEN = 'SEVEN';    
    
    LET NOMBRE_UNL_ARCHIVO = '';
    LET NOM_ARCHIVO_REG_CORRESP = '';
    LET NOM_ARCHIVO_ERR_CORRESP = '';
    LET PREFIJO_ARCHIVO = 'rptmc_ret_';
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "debug_sp_rpt_mc_obtener_movs_retiros.out";                                                
    --TRACE ON;        
	
    BEGIN 		

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excep_sp_rpt_mc_obtener_movs_retiros.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ERROR_INFO;                
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;
        
        LET pNombreCorresponsal = TRIM(pNombreCorresponsal);
        
        IF ( pNombreCorresponsal <> CORRESP_OXXO AND pNombreCorresponsal <> CORRESP_SEVEN ) THEN
            LET vCODIGO_RETORNO = '00001';
            LET vMENSAJE_RETORNO = 'El corresponsal no esta registrado para obtener informacion.';                
            RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
        END IF
        
        IF ( pNombreCorresponsal = CORRESP_OXXO ) THEN
            LET CORRESP_OXXO = LOWER(CORRESP_OXXO);            
            LET NOMBRE_UNL_ARCHIVO = PREFIJO_ARCHIVO||'movs_'||CORRESP_OXXO||'.unl';
            LET SCRIPT_EJECUCION = PREFIJO_ARCHIVO||'ejec_movs_'||CORRESP_OXXO||'.sql';            
            LET NOM_ARCHIVO_REG_CORRESP = PREFIJO_ARCHIVO||'movs_'||CORRESP_OXXO||'.txt';
            LET NOM_ARCHIVO_ERR_CORRESP = PREFIJO_ARCHIVO||'movs_'||CORRESP_OXXO||'.log';
            LET vCondicionesTipoMov = " AND transaccionorigen = '1234' AND metodocaptura = '05' AND infreceptor LIKE '%OXX%' ";
        ELIF ( pNombreCorresponsal = CORRESP_SEVEN ) THEN
            LET CORRESP_SEVEN = LOWER(CORRESP_SEVEN);
            LET NOMBRE_UNL_ARCHIVO = PREFIJO_ARCHIVO||'movs_'||CORRESP_SEVEN||'.unl';
            LET SCRIPT_EJECUCION = PREFIJO_ARCHIVO||'ejec_movs_'||CORRESP_SEVEN||'.sql';
            LET NOM_ARCHIVO_REG_CORRESP = PREFIJO_ARCHIVO||'movs_'||CORRESP_SEVEN||'.txt';
            LET NOM_ARCHIVO_ERR_CORRESP = PREFIJO_ARCHIVO||'movs_'||CORRESP_SEVEN||'.log';
            LET vCondicionesTipoMov = " AND transaccionorigen = '1234' AND metodocaptura = '05' AND infreceptor LIKE '7ELEVEN%' ";
           
        END IF

        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO||
        ' SELECT fechahorainauth::DATE as fecha, '''||pNombreCorresponsal||''', transaccionorigen,'  ||
        '    CASE  '  ||
        '       WHEN SUBSTR(numtarjeta, 1, 6) IN (SELECT bin FROM intercard:bines WHERE creditodebito = \"D\") THEN \"D\" '  ||
        '       WHEN SUBSTR(numtarjeta, 1, 6) IN (SELECT bin FROM intercard:bines WHERE creditodebito = \"C\") THEN \"C\" '  ||
        '    END tipo_tarjeta,  '  ||
        ' NVL(montocashback,0) as montocashback ' ||
        '   FROM intercard:movimiento  ' ||
        ' WHERE fechahorainauth  BETWEEN '''||pFechaBusqInicial||''' AND '''||pFechaBusqFinal||''' '||
        '  AND codigoiso = \"00\" ' ||
        '  AND codtran IN( \"00\", \"09\")  ' || vCondicionesTipoMov||        
        '  AND formato = \"0200\" ' ||
        '  AND movreversado = \"F\" '||
        '  AND prodind = \"02\" ' ||        
        '  AND codreversa = \"0\" ' ||        
        '  AND movconciliado = \"V\" '||
        '  AND montocashback > \"0\" '||
         '" >'||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;            
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO|| "' delimiter '|' "|| '5'||                          
                          "; INSERT INTO tbl_mc_movs_tipo_transaccional" || ";"||'"'||' > '||RUTA_UNLOAD_RESPALDOS||NOM_ARCHIVO_REG_CORRESP;
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||RUTA_UNLOAD_RESPALDOS||NOM_ARCHIVO_REG_CORRESP||" -l "||RUTA_UNLOAD_RESPALDOS||NOM_ARCHIVO_ERR_CORRESP||" -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;        

        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
        
        UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".tbl_mc_movs_tipo_transaccional;        

        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;	
		
	END
END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 02 de marzo del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Componente principal ejecutado por los jobs: 711_01 y 711_02, 692_01 y 692_02',
'Obtiene solo la transaccionalidad de cashback o retiro en efectivo registrada para los corresponsales OXXO y 7Eleven',
'#2',
'Base de datos: intercard',
'Fecha de modificación: 30 de septiembre del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Modificación: Se agrega el nuevo valor -09- en la condición codtran para considerar este valor asignado por la nueva normativa de cashback'
;

CREATE PROCEDURE "informix".sp_camp_proceso_principal( pTipoReporte VARCHAR(2), pPeriodo CHAR(1), pNumeroDesfase SMALLINT )
    RETURNING VARCHAR (5) AS rCODIGO_RETORNO, VARCHAR(150) AS rMENSAJE_RESPUESTA, DATE as rFechaIntegralHoy;
	
    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(80);
    
	DEFINE CODIGO_RETORNO VARCHAR(5);
    DEFINE MENSAJE_RESPUESTA VARCHAR(150);
    DEFINE RUTA_ORIGEN  VARCHAR(80);   
    
    DEFINE vFechaInicial DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaFinal DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaIntegralHoy DATE;
    DEFINE vFechaHoy DATE;    
    
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RESPUESTA = 'El proceso es ejecutado exitosamente.';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vFechaInicial = '';
    LET vFechaFinal = '';
    LET vFechaHoy = '';
    LET vFechaIntegralHoy = CURRENT;    
    
    BEGIN 

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_camp_proceso_principal_"||pTipoReporte||".err.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;                
                RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaIntegralHoy;
            END IF;
            
        END EXCEPTION;

        --SET DEBUG FILE TO RUTA_ORIGEN||"debug_sp_camp_proceso_principal.out";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        EXECUTE PROCEDURE "informix".sp_intercard_calcular_periodos( pPeriodo, pNumeroDesfase)
            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaInicial, vFechaFinal, vFechaIntegralHoy;
            
        IF ( CODIGO_RETORNO <> '00000' OR vFechaInicial IS NULL OR vFechaFinal IS NULL OR vFechaIntegralHoy IS NULL) THEN
            LET CODIGO_RETORNO = '00001';
            LET MENSAJE_RESPUESTA = 'Error al obtener el rango de tiempo.';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaIntegralHoy;
        END IF

        EXECUTE PROCEDURE "informix".sp_camp_obtener_movs_transacc( pTipoReporte, vFechaInicial, vFechaFinal)
            INTO CODIGO_RETORNO, MENSAJE_RESPUESTA;
        
        IF ( CODIGO_RETORNO <> '00000') THEN
            LET CODIGO_RETORNO = CODIGO_RETORNO;
            LET MENSAJE_RESPUESTA = 'Error al buscar los movimientos.';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaIntegralHoy;
        END IF

		RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaIntegralHoy;
        
	END
END PROCEDURE
DOCUMENT
'#1 ',
'Base de datos: intercard',
'Autor: Armando Garcia Ortiz',
'Creacion: 10 de julio del 2020',
'Descripcion: Obtener la transaccionalidad de movimientos con tarjeta presente y tarjeta no presente.',
'considerando el rango de fechas de inicio y fin.',
'Los clientes a buscar son con tarjetas de tecnologías: tipo A, B o C, o bien, que no tenga firma electronica activada o cvv dinámico.',
'Este componente es ejecutado por los jobs:',
'843_01_CMP_CARGA_TAR_TP_PRO',
'   843_02_CMP_CARGA_TAR_TNP_PRO',
'Fecha de modificación: 13 de agosto del 2021',
'#2 ',
'Modificación: 27 de septiembre del 2021',
'Se corrige el nombre del archivo creado en el código exception.'
;

CREATE PROCEDURE "informix".sp_carga_ctas_empleados()
RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	--DefiniciÃ³n de variables
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE vNombreArchivo 		VARCHAR(50);
	DEFINE vFecha		 		DATE;
	DEFINE vDia		 			CHAR(2);
	DEFINE vMes					CHAR(2);
	DEFINE vAnio				CHAR(4);
	DEFINE vFechaInicial		DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaFinal			DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaIntegral		DATE;
	DEFINE vCodigoRetornoPeriodos	CHAR(5);
	DEFINE vMensajePeriodos			CHAR(160);
	DEFINE RUTA					VARCHAR(50);
	DEFINE vArchivoDBLOAD		VARCHAR(30);
	DEFINE vIntervaloCommit		INTEGER;
	DEFINE vArchivoEjecLog		VARCHAR(50);
    DEFINE vArchivoLOG			VARCHAR(50);
	DEFINE vExecuteSQL		    LVARCHAR(1000);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
    DEFINE ERROR_INFO 			VARCHAR(80);
	
	--InicializaciÃ³n de variables
	LET vCodigoRetorno = '';
	LET vMensaje = '';
	LET vNombreArchivo = 'colaboradores_';
	LET vFecha=TODAY;
	LET vDia='';
	LET vMes ='';
	LET vAnio='';
	LET vFechaInicial='';
	LET vFechaFinal ='';
	LET vFechaIntegral ='';
	LET vCodigoRetornoPeriodos= '';
	LET vMensajePeriodos = '';	
	LET RUTA = '/RESPALDOSNEW/';
	LET vIntervaloCommit = 1000;
	LET vArchivoEjecLog = 'ejec_colaboradores.log';
	LET vArchivoDBLOAD = 'dbload_carga_archivo.txt';
    LET vArchivoLOG = 'colaboradores.log';
	LET vExecuteSQL	='';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/carga_ctas_empleados.out";
	--TRACE ON;

	BEGIN
	
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
				SET DEBUG FILE TO RUTA || "carga_colaboradores.err.out";
				TRACE ON;
				
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = ERROR_INFO;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Obtiene el rango de fechas del dÃ­a anterior
		EXECUTE PROCEDURE "informix".sp_intercard_calcular_periodos('D', 1)
		INTO vCodigoRetornoPeriodos, vMensajePeriodos, vFechaInicial, vFechaFinal, vFechaIntegral;
		
		IF (vCodigoRetornoPeriodos <> '00000') THEN 
			LET vCodigoRetorno = '00001';
			LET vMensaje = 'Proceso no exitoso';
			RETURN vCodigoRetorno, vMensaje;
		
		END IF
		
		--Obtenemos la fecha
		LET vMes = SUBSTR(vFechaInicial,6,2); 
		LET vDia = SUBSTR(vFechaInicial,9,2); 
		LET vAnio = SUBSTR(vFechaInicial,1,4); 
		LET vNombreArchivo = vNombreArchivo||vDia||vMes||vAnio||".txt";
		
					
		TRUNCATE TABLE "informix".ctas_nomina_empleado DROP STORAGE; 
				
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "FILE '||RUTA||vNombreArchivo||' DELIMITER ''|'' 2; INSERT INTO "informix".ctas_nomina_empleado;" >' ||RUTA||vArchivoDBLOAD;
		SYSTEM vExecuteSQL;
		
		
	    LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbload -d intercard -c '||RUTA||vArchivoDBLOAD||' -l '||RUTA||vArchivoLOG||' -n '||vIntervaloCommit||' -r >' ||RUTA||vArchivoEjecLog;
	   	SYSTEM vExecuteSQL;
		
	
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm -f '||RUTA||vArchivoLOG||' '||RUTA||vArchivoEjecLog||' '||RUTA||vArchivoDBLOAD;
	   	SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm -f '||RUTA||vNombreArchivo||'*';
	   	SYSTEM vExecuteSQL;
				
		
      	UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_nomina_empleado;
		
		LET vCodigoRetorno = '00000';
		LET vMensaje = 'Proceso exitoso';
	
	RETURN vCodigoRetorno, vMensaje;
	END
END PROCEDURE;