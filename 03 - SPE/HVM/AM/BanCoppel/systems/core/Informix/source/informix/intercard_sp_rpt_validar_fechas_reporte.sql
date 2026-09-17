CREATE PROCEDURE "informix".sp_rpt_validar_fechas_reporte(pdtFechaIni DATE, pdtFechaFin DATE )
    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(50) AS MENSAJE_RESPUESTA,
    DATETIME YEAR TO FRACTION(5) AS vFechaCompletaInicial, DATETIME YEAR TO FRACTION(5) AS vFechaCompletaFinal;
                   
    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(80);
    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA CHAR(50);
    DEFINE RUTA_ORIGEN VARCHAR(80);

    DEFINE vfecha_hoy DATETIME YEAR TO FRACTION(5);
    DEFINE vult_dia_mes DATE;
    
    DEFINE vFechaCompletaInicial DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaCompletaFinal DATETIME YEAR TO FRACTION(5);
    
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RESPUESTA = 'El proceso se ejecuto exitosamente.';
    --LET RUTA_ORIGEN = '/ifxsif01/_argoz/parametrico/'; --Desarrollo
    LET RUTA_ORIGEN = '/resplogifx/';   -- Procucción
	LET vult_dia_mes ='';
 
    LET vFechaCompletaInicial = '';
    LET vFechaCompletaFinal = '';
    
    BEGIN 

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "sp_rpt_validar_fechas_reporte.err.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;
                 RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaCompletaInicial, vFechaCompletaFinal;
            END IF;
            
        END EXCEPTION;

        --SET DEBUG FILE TO RUTA_ORIGEN||"sp_rpt_validar_fechas_reporte.out";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3; 

        SELECT  fecha_hoy, ult_dia_mes 
            INTO vfecha_hoy, vult_dia_mes 
        FROM  bdinteg:si_fechas 
            WHERE empresa='001';

    IF ((vfecha_hoy::DATE) = (vult_dia_mes)) THEN 
        LET CODIGO_RETORNO = '00001';
        LET MENSAJE_RESPUESTA = 'No es posible ejecutar los últimos días del mes.';
 	 ELIF (DAY(vfecha_hoy) = 15)  THEN 
		LET CODIGO_RETORNO = '00002';
		LET MENSAJE_RESPUESTA = 'No es posible ejecutar los días 15 del mes.';
	 ELIF (DAY(vfecha_hoy) = 20)  THEN 
		LET CODIGO_RETORNO = '00003';
		LET MENSAJE_RESPUESTA = 'No es posible ejecutar los días 20 del mes.';
     ELIF 
		(pdtFechaIni < current::date - 365) OR (pdtFechaIni is null) THEN  
		LET CODIGO_RETORNO = '00004';
		LET MENSAJE_RESPUESTA = 'Fecha-Inicio es Mayor a 365 días. Verificar.';
	 ELIF (pdtFechaFin > current::date) OR (pdtFechaFin is null)  THEN  
		LET CODIGO_RETORNO = '00005';
		LET MENSAJE_RESPUESTA = 'Fecha-Fin es Mayor al día actual. Verificar.';
	 ELIF  ((pdtFechaFin) - (pdtFechaIni))  > 31  THEN 
        LET CODIGO_RETORNO = '00006';
        LET MENSAJE_RESPUESTA = 'Rango supera los 31 días de consulta. Verificar.';
	END IF;
    
    --Construccion de las fechas de inicio y final de busqueda para los 
    ---otros procedimientos almacenados.
    LET vFechaCompletaInicial = CURRENT;
    LET vFechaCompletaFinal = CURRENT;
    LET vFechaCompletaInicial = pdtFechaIni;
    LET vFechaCompletaFinal = pdtFechaFin;
    LET vFechaCompletaInicial = SUBSTRING(vFechaCompletaInicial FROM 1 FOR 10) || ' 00:00:00.0000';
    LET vFechaCompletaFinal = SUBSTRING(vFechaCompletaFinal FROM 1 FOR 10) || ' 23:59:59.9999';

	 RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA, vFechaCompletaInicial, vFechaCompletaFinal;

	END
END PROCEDURE

--Base de datos en intercard
--Valida las fechas correctas para ingresar al reporte parametrico
--y regresa las fechas de inicio y final de busqueda para la busqueda en la tabla de movimiento (intercard)
--Autor: Marcos Ayala
--Fecha de modificacion: 20 de mayo del 2019
;

CREATE PROCEDURE "informix".sp_rpt_obtener_transacciones(pdtFechaIni DATETIME YEAR TO FRACTION(5), pdtFechaFin DATETIME YEAR TO FRACTION(5), pstipocarga CHAR(1) )
    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(50) AS MENSAJE_RESPUESTA;
                   
    DEFINE SQLERR		INTEGER;
    DEFINE ISAM_ERR		INTEGER;
    DEFINE ERROR_INFO	VARCHAR(80);
    
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RESPUESTA CHAR(50);
    DEFINE RUTA_ORIGEN  VARCHAR(80);
	DEFINE vExecuteSQL LVARCHAR(8000);
	DEFINE PREFIJO_SCRIPTS CHAR(11); -- CHAR(8);
	DEFINE NOMBRE_SCRIPT CHAR(50);
	DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(15);
	DEFINE vindicatabla  VARCHAR(25);
	DEFINE vindicatablahist VARCHAR(25);
	DEFINE CONTADOR_TRANSACCIONES SMALLINT;
	DEFINE PREFIJO_ARCH_UNL VARCHAR(14);
	
	DEFINE vfecha_hoy DATETIME YEAR TO FRACTION(5);

	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RESPUESTA = 'El proceso se ejecuto exitosamente.';
    LET RUTA_ORIGEN = '/resplogifx/';
	LET vExecuteSQL = '';
	LET PREFIJO_SCRIPTS = 'transcarga_';
    LET NOMBRE_SCRIPT = '';
	LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
	LET vindicatablahist = '';
    LET CONTADOR_TRANSACCIONES = 1000;

    BEGIN 

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "sp_rpt_obtener_transacciones.err.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RESPUESTA = ERROR_INFO;
                 RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;
            END IF;
            
        END EXCEPTION;

        --SET DEBUG FILE TO RUTA_ORIGEN||"sp_rpt_obtener_transacciones.out";
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
  
     --Preparacion de una proxima ejecucion limpia.
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
    
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
  
        IF ( pstipocarga NOT IN ('M','H','A') ) THEN
            LET CODIGO_RETORNO = '00022';
            LET MENSAJE_RESPUESTA = 'Proceso de carga incorrecto, favor de validar';
            RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;
        END IF;
 
 
    --Por default busca en la tabla de movimiento
    LET vindicatabla    = 'movimiento';
    LET PREFIJO_ARCH_UNL   = 'mov_paso';
    LET pstipocarga = pstipocarga;
    
    IF (pstipocarga = 'H') THEN
        LET vindicatabla = 'movimientohistorico';
    ELIF (pstipocarga = 'A') THEN  -- ambos 
        LET vindicatablahist = 'movimientohistorico';
        LET PREFIJO_ARCH_UNL = 'mov_paso_ambos';
    END IF;

    IF pstipocarga IN ('M','H','A') THEN 
  
        LET vExecuteSQL  = '';
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||PREFIJO_ARCH_UNL||'.unl ' || 
        ' SELECT   secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal, ' ||
		'          montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth, ' ||
		'          codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer ' ||
		"           FROM intercard:"||vindicatabla||" mv  " ||
		'		 WHERE mv.FechaHoraInAuth BETWEEN ''"'||pdtFechaIni||'"'' AND ''"'||pdtFechaFin||'"'' ' ||
		'		 AND mv.formato in (''"'||'0200'||'"'' , ''"'||'0220'||'"'' ,  ''"'||'0221'||'"'' , ''"'||'0420'||'"'')    ' ||         
		'		 AND mv.codtran not in (''"'||'91'||'"'' , ''"'||'92'||'"'' ,  ''"'||'93'||'"'' , ''"'||'94'||'"'', ''"'||'95'||'"'', ''"'||'97'||'"'')  ' ||     
		'		 AND (mv.codreversa = 0 or mv.codreversa = 2)                        ' ||                
		'		 AND mv.movreversado = ''"'||'F'||'"''                               ' ||                 
		'		 AND mv.metodocaptura is not null                                    ' ||
		'		 AND mv.metodocaptura != (''"'||'null'||'"'');"> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_unl.sql';
        SYSTEM vExecuteSQL; 
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_unl.sql';
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||
                          ''||PREFIJO_ARCH_UNL||'.unl' || "' delimiter '|' "|| '25'||
                          "; INSERT INTO rpt_movimientopaso" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_movs.txt';
        SYSTEM vExecuteSQL; 
         
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_movs.txt -l "||PREFIJO_SCRIPTS||"err_tarj_paso.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;   
        
    END IF;
 
    IF pstipocarga = ('A') THEN
    
        LET vExecuteSQL  = '';
        LET vExecuteSQL  = 'echo "UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||PREFIJO_ARCH_UNL||'.unl ' || 
        ' SELECT   secuencia,codigoiso,codgironeg,numtarjeta,prodind,formato,codtran,codreversa,monto,infreceptor,idreceptor,idterminal, ' ||
        '          montorealrevfzda,movreversado,esnacional,metodocaptura,motivo,fechalocaltransaccion,horalocaltransaccion,fechahorainauth, ' ||
        '          codigoretcomision,montosurcharge,montocashback,tipotransaccionposdigitada,idretailer ' ||
        "           FROM intercard:"||vindicatablahist||" mv  " ||
        '		 WHERE mv.FechaHoraInAuth BETWEEN ''"'||pdtFechaIni||'"'' AND ''"'||pdtFechaFin||'"'' ' ||
        '		 AND mv.formato in (''"'||'0200'||'"'' , ''"'||'0220'||'"'' ,  ''"'||'0221'||'"'' , ''"'||'0420'||'"'')    ' ||         
        '		 AND mv.codtran not in (''"'||'91'||'"'' , ''"'||'92'||'"'' ,  ''"'||'93'||'"'' , ''"'||'94'||'"'', ''"'||'95'||'"'', ''"'||'97'||'"'')  ' ||     
        '		 AND (mv.codreversa = 0 or mv.codreversa = 2)                        ' ||                
        '		 AND mv.movreversado = ''"'||'F'||'"''                               ' ||                 
        '		 AND mv.metodocaptura is not null                                    ' ||
        '		 AND mv.metodocaptura != (''"'||'null'||'"'');  "> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_hist_unl.sql';
        SYSTEM vExecuteSQL; 

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_hist_unl.sql';
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||
                          ''||PREFIJO_ARCH_UNL||'.unl' || "' delimiter '|' "|| '25'||
                          "; INSERT INTO rpt_movimientopaso" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_movs_hist.txt';
        SYSTEM vExecuteSQL; 
         
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_movs_hist.txt -l "||PREFIJO_SCRIPTS||"err_tarj_paso_hist.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;      

        END IF;

	 RETURN CODIGO_RETORNO, MENSAJE_RESPUESTA;

	END
    
END PROCEDURE
--Base de datos en intercard
--Obtiene los registros de la tabla de movimiento considerando el rango de fechas enviado en los parametros.
--Autor: Marcos Ayala
--Fecha de modificacion: 20 de mayo del 2019
;

CREATE PROCEDURE "informix".sp_rpt_generar_archivo( pRutaOrigen VARCHAR(80) )
    RETURNING CHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO;

    DEFINE CODIGO_RETORNO CHAR(6);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(100);
    DEFINE RUTA_UNLOAD VARCHAR(40);
    DEFINE vExecuteSQL LVARCHAR(8000);
    DEFINE PREFIJO_ARCHIVO_RPT VARCHAR(50);
    DEFINE NOMBRE_ARCHIVO_RPT VARCHAR(50);
    DEFINE NOMBRE_SCRIPT_RPT VARCHAR(30);
	DEFINE vaniomes VARCHAR(16); 
	DEFINE vfecha_hoy DATETIME YEAR TO FRACTION(5); 
    
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO'; 
    LET RUTA_UNLOAD = '/RESPALDOSNEW/';
    LET RUTA_ORIGEN = pRutaOrigen;
    LET PREFIJO_ARCHIVO_RPT = 'Rpt_Dinamico_';
    LET NOMBRE_ARCHIVO_RPT = '';
    LET NOMBRE_SCRIPT_RPT = 'sc_generar_archivo_rpt.sql';
    LET vExecuteSQL = '';

    BEGIN
    
        --SET DEBUG FILE TO pRutaOrigen||"sp_rpt_generar_archivo.out";
        --TRACE ON;    
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
 	 
        let vfecha_hoy = current; 
	    let vaniomes = REPLACE( year(vfecha_hoy) || LPAD (MONTH(vfecha_hoy),2,"0")||LPAD (day(vfecha_hoy),2,"0")|| extend (vfecha_hoy,hour to SECOND),':','');
	    let vaniomes = vaniomes;
		
		 BEGIN;
		     update rptdinamico set  nombreciudad = ( Select  nombre from bdinteg:si_ciudades where estado= rptdinamico.noestado and ciudad = rptdinamico.nociudad);
		 COMMIT; 
	 	  		  
        LET NOMBRE_ARCHIVO_RPT = PREFIJO_ARCHIVO_RPT||vaniomes||'.txt';
		
        -----------------------------------------------------------------------------------------------------------------------
		LET vExecuteSQL =   ''; 
        LET vExecuteSQL  = 'echo "SET ISOLATION DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_ORIGEN||NOMBRE_ARCHIVO_RPT||
            ' SELECT mv.numcliente, noEstado, nombreEstado as nombreestado,mv.noCiudad as nociudad, mv.nombreCiudad,  ' ||
            '     CASE ' ||
            '         WHEN mv.canal = \"01\" THEN \"ATM\" ' ||
            '         WHEN mv.canal = \"02\" THEN \"POS\" ' ||
            '     END as canal,' ||
            
            '     CASE ' ||
            '         WHEN mv.ChipBanda  = \"V\" THEN \"CHIP\" ' ||
            '         WHEN mv.ChipBanda  = \"F\" THEN \"BANDA\" ' ||
            '     END as ChipBanda, ' ||
            
            '    SUBSTRING (mv.numtarjeta from 1 for 6) as bin, ' ||
            '    SUBSTRING (mv.numtarjeta from 7 for 2) as SubBin,' ||
            '    mv.productointercard as productointercard, ' ||
            
            '    ( ' ||
            '    SELECT descproducto  ' ||
            '        FROM intercard:productotarjeta  ' ||
            '     WHERE codproductotarjeta = mv.productointercard ' ||
            '    ) as descproductoInterCard, ' ||
            
            '     CASE ' ||
            '         WHEN mv.producto = \"C\" THEN \"CREDITO\" ' ||
            '         WHEN mv.producto = \"D\" THEN \"DEBITO\" ' ||
            '     END as producto, ' ||
            
            '     mv.cuentaProducto as CuentaProducto,' ||
            '       mv.metodoCaptura, ' ||
            '     mv.tipotransaccionposdigitada, ' ||
            '       SUBSTRING(mv.numtarjeta from 13 for 4) as terminaTarjeta, ' ||
            '     mv.fechaExpiracion, ' ||
            '       mv.fechaTransaccion as Fecha, ' ||
            
            '     CASE ' ||
            '         WHEN mv.origen = \"V\" THEN \"NAC\" ' ||
            '         WHEN mv.origen = \"F\" THEN \"INT\" ' ||
            '     END as txnOrigen, ' ||
            
            '     mv.nombreComercio as comercio,  ' ||
            
            '     CASE ' ||
            '         WHEN canal = \"01\" THEN mv.idreceptor ' ||
            '         WHEN canal = \"02\" THEN mv.giroComercio ' ||
            '     END as giroComercio, ' ||
            
            '     CASE ' ||
            '         WHEN canal = \"01\" THEN \"CAJERO AUTOMÃTICO\"  ' ||
            '         WHEN canal = \"02\" THEN ' ||
                '  ( ' ||            
                     ' SELECT descgironeg ' ||
                     ' FROM intercard:gironegocio  ' ||
                     ' WHERE codgironeg = mv.giroComercio  ' ||
                     ' AND ( tipotarjeta =  mv.producto OR tipotarjeta = \"A\" )' ||
                '  ) END as descGiroComercio,' ||
                 
            '     CASE ' ||
            '         WHEN canal = \"01\" THEN mv.idterminal   ' ||
            '         WHEN canal = \"02\" THEN mv.idretailer   ' ||
            '     END as afiliacionTerminal,' ||
            
            '   CASE ' ||
            '     WHEN canal = \"01\" AND  codtran = \"01\" THEN  \"Retiro ATM\"     ' ||
            '     WHEN canal = \"01\" AND  codtran = \"31\" THEN  \"Consulta ATM\"   ' ||
            '     WHEN canal = \"02\" THEN \"Compras POS\"    ' ||
            ' END as TipoTransaccion,  ' ||
            
            '   CASE ' ||
            '       WHEN (mv.formato = \"0420\" and mv.codreversa = 2) THEN mv.montorealrevfzda ' ||
            '       WHEN (mv.formato <> \"0420\" and mv.codreversa = 0) THEN mv.monto ' ||
            '  END as monto, ' ||            
            
            '   CASE ' || 
            '       WHEN (mv.formato = \"0420\" and mv.codreversa = 2) THEN mv.montocashback' ||
            '       WHEN (mv.formato <> \"0420\" and mv.codreversa = 0) THEN mv.montocashback ' ||
            '   END as montoCashBack, ' ||
            
            ' mv.montosurcharge as montoSurcharge, ' ||
            ' mv.codigoiso,' ||
            
            '   CASE '||
            '       WHEN mv.codigoiso = \"00\" THEN \"TransacciÃ³n Aprobada\"  '||
            '       WHEN mv.codigoiso <> \"00\" THEN mv.motivoRechazo   '||
            '   END as motivo  '||
            
            ' FROM intercard:rptdinamico mv  '||
            '    ORDER BY mv.numcliente DESC; '||
            ' "> '||RUTA_ORIGEN||NOMBRE_SCRIPT_RPT;
            SYSTEM vExecuteSQL;

            LET vExecuteSQL ='';
            LET vExecuteSQL= 'dbaccess intercard '||RUTA_ORIGEN||NOMBRE_SCRIPT_RPT;
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL ='rm -f '||RUTA_ORIGEN||NOMBRE_SCRIPT_RPT;
            SYSTEM vExecuteSQL;

            LET vExecuteSQL = '';
            LET vExecuteSQL = ' if [ -f '||RUTA_ORIGEN||NOMBRE_ARCHIVO_RPT||' ]; ' ||
             ' then ' ||
            ' gzip -9 '||RUTA_ORIGEN||NOMBRE_ARCHIVO_RPT||';'||
            ' fi ';
            SYSTEM vExecuteSQL;
       
        RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
    
    END
    
END PROCEDURE



;