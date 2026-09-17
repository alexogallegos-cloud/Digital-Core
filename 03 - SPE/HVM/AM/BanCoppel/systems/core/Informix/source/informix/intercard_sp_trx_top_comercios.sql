CREATE PROCEDURE "informix".sp_trx_top_comercios(pFechaInicio DATETIME YEAR TO FRACTION(5), pFechaFin DATETIME YEAR TO FRACTION(5))
    
    RETURNING CHAR (5) as CODIGO_RETORNO, VARCHAR(40) as MENSAJE_RETORNO;
	
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(40);
	DEFINE RUTA_ORIGEN VARCHAR(50); 
    DEFINE RUTA_UNLOAD VARCHAR(15); 
    DEFINE PREFIJO_SCRIPTS CHAR(11);
    DEFINE NOMBRE_REPORTE VARCHAR(27);
	DEFINE NOMBRE_ARCH_UNL VARCHAR(18);
	DEFINE vExecuteSQL LVARCHAR(4000);
    
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_ORIGEN = '/resplogifx/mon_trans_categoria/';
    LET RUTA_UNLOAD = '/RESPALDOSNEW/';
    LET PREFIJO_SCRIPTS = 'script_mon_';
    LET NOMBRE_ARCH_UNL = 'trx_top_comercios';
    LET NOMBRE_REPORTE = 'arch_trx_top_comercios';
    LET vExecuteSQL = '';
    
    SET DEBUG FILE TO RUTA_ORIGEN || "ejec_sp_trx_top_comercios.out";
    TRACE ON;        
	
	BEGIN 
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        LET vExecuteSQL  = '';
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_UNLOAD||PREFIJO_SCRIPTS||NOMBRE_ARCH_UNL||'.unl' ||
        ' SELECT codigoiso as autorizacion, infreceptor as comercio, COUNT(*)::INTEGER as cantidad ' ||
        '     FROM intercard:movimiento mov ' ||
        '  WHERE mov.fechahorainauth BETWEEN \"'||pFechaInicio||'\"  AND  \"'||pFechaFin||'\" ' ||
        '    AND mov.transaccionorigen = \"1234\" ' ||
        '    AND codigoiso = \"00\" ' ||
        '    GROUP BY 1,2 ' ||
        ' ORDER BY 3 DESC; ' ||
        ' "> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'top_comercios.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'top_comercios.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "Autorizacion|Comercio|Cantidad|" > '||RUTA_ORIGEN||NOMBRE_REPORTE||'.txt';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'cat '||RUTA_UNLOAD||PREFIJO_SCRIPTS||NOMBRE_ARCH_UNL||'.unl'|| '>>' ||RUTA_ORIGEN||NOMBRE_REPORTE||'.txt';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'top_comercios.sql';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f '||RUTA_UNLOAD||PREFIJO_SCRIPTS||NOMBRE_ARCH_UNL||'.unl';
        SYSTEM vExecuteSQL;
        
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO;

		
	END
END PROCEDURE;