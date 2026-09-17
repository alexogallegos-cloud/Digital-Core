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