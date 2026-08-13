CREATE PROCEDURE "informix".sp_reporte_cvv_dinamico( pTipoReporte CHAR(1) )
    
    RETURNING VARCHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO, 
        DATE as vFechaInicio, DATE as vFechaFinal;

    DEFINE CODIGO_RETORNO VARCHAR(6);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_ORIGEN  VARCHAR(80);
    DEFINE RUTA_DESTINO VARCHAR(80);
    DEFINE NOMBRE_REPORTE VARCHAR(15);    
    DEFINE RUTA_UNLOAD VARCHAR(15);
    DEFINE PREFIJO_SCRIPTS CHAR(7);
    DEFINE REPORTE_DIARIO CHAR(1);
    DEFINE REPORTE_MENSUAL CHAR(1);
    DEFINE vSufReporte VARCHAR(6);
    DEFINE vExecuteSQL LVARCHAR(4000);
    
    DEFINE vFechaHoy VARCHAR(10);
    DEFINE vFechaInicio DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaFinal DATETIME YEAR TO FRACTION(5);
    
BEGIN


    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET RUTA_DESTINO = '/resplogifx/';
    LET RUTA_UNLOAD = '/RESPALDOSNEW/';
    LET NOMBRE_REPORTE = 'TxnsCVV';
    LET PREFIJO_SCRIPTS = 'repcvv_';
    LET REPORTE_DIARIO = 'D';
    LET REPORTE_MENSUAL = 'M';
    LET vExecuteSQL = '';
    LET vFechaInicio = '';
    LET vFechaFinal = '';
    LET vFechaHoy = '';
    LET vSufReporte = '000000';
    
    --SET DEBUG FILE TO RUTA_DESTINO||"sp_reporte_cvv_dinamico.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pTipoReporte <> REPORTE_DIARIO AND pTipoReporte <> REPORTE_MENSUAL) THEN
        LET CODIGO_RETORNO = '00001';
        LET MENSAJE_RETORNO = 'El parametro es incorrecto.';
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;
    END IF;
    
    IF ( pTipoReporte =  REPORTE_DIARIO ) THEN
    
        SELECT fecha_hoy, EXTEND(fecha_hoy) , EXTEND(fecha_hoy) + 1 units DAY
            INTO vFechaHoy, vFechaInicio, vFechaFinal
        FROM bdinteg:si_fechas        
            WHERE empresa = '001';
    
        LET vSufReporte = LPAD(DAY(vFechaHoy),2,"0")||LPAD(MONTH(vFechaHoy),2,"0");
        
    END IF;
    
    IF ( pTipoReporte =  REPORTE_MENSUAL ) THEN

        SELECT fecha_hoy, EXTEND(pri_dia_mes) - 1 units MONTH, EXTEND(pri_dia_mes)
            INTO vFechaHoy, vFechaInicio, vFechaFinal
        FROM bdinteg:si_fechas
            WHERE empresa = '001';
            
            LET vSufReporte = LPAD(MONTH(vFechaHoy),2,"0")||YEAR(vFechaHoy);
            
    END IF;

    --Nota: El campo tipotransaccionpos = 'D' --- D es el indicador de CVV2 Dinamico
    LET vExecuteSQL = '';
    LET vExecuteSQL = 'echo "Fecha|Num. de cliente|Bin|Comercio|Codigo ISO|Motivo del rechazo|Tipo de transaccion|"> '||RUTA_ORIGEN||NOMBRE_REPORTE||vSufReporte||'.txt';
    SYSTEM vExecuteSQL;
            
    LET vExecuteSQL  = '';    
    LET vExecuteSQL  = 'echo "SET ISOLATION DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD||PREFIJO_SCRIPTS||'reg_trans.unl' ||       
    ' SELECT mv.fechahorainauth::DATE fecha, ' ||
    '       tj.numcliente, SUBSTR(mv.numtarjeta,1,6) as bin, ' ||
    '       mv.infreceptor as comercio, mv.codigoiso, ' ||
    '  CASE  ' ||
    '        WHEN mv.codigoiso = \"00\" THEN \"Aprobado\"  ' ||
    '        ELSE mv.motivo ' ||
    '  END as Motivo_Respuesta, ' ||
    ' CASE ' ||
    '      WHEN mv.tipotransaccionposdigitada = \"CE\" THEN \"Comercio electronico\" ' ||
    '      WHEN mv.tipotransaccionposdigitada = \"AV\" THEN \"Telefono\" ' ||
    '      WHEN mv.tipotransaccionposdigitada = \"CA\" THEN \"Cargo recurrente\" ' ||
    '      WHEN mv.tipotransaccionposdigitada = \"HO\" THEN \"Hotel\" ' ||
    '      WHEN mv.tipotransaccionposdigitada = \"ND\" THEN \"Digitada Manual\" ' ||
    '      WHEN mv.tipotransaccionposdigitada = \"TG\" THEN \"TAG\" ' ||
    '      ELSE \"Sin valor\" ' ||
	'	END as Descripcion ' ||        
    ' FROM intercard:movimiento mv INNER JOIN intercard:tarjeta tj ' ||
    '   ON (mv.numtarjeta = tj.numtarjeta) ' ||
    " WHERE mv.fechahorainauth BETWEEN  '"||vFechaInicio||"' AND '"||vFechaFinal||"'  "||
    ' AND mv.metodocaptura IN (\"01\",\"81\") ' ||
    ' AND mv.tipotransaccionpos = \"D\" ' ||
    ' AND mv.formato = \"0200\" ' ||
    ' AND mv.prodind = \"02\" ' ||    
    ' GROUP BY 1,2,3,4, 5, 6, 7 ' ||
    ' ORDER BY 1, 2, 3; ' ||
    ' "> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_movs.sql';
    SYSTEM vExecuteSQL;

    LET vExecuteSQL ='';
    LET vExecuteSQL= 'dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_movs.sql';
    SYSTEM vExecuteSQL;
    
    LET vExecuteSQL ='';
    LET vExecuteSQL = "sed -e 's/[|]*$//' "||RUTA_UNLOAD||PREFIJO_SCRIPTS||"reg_trans.unl >> "||RUTA_DESTINO||NOMBRE_REPORTE||vSufReporte||".txt";
    SYSTEM vExecuteSQL;
    
    LET vExecuteSQL = '';
    LET vExecuteSQL ='rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_movs.sql';
    SYSTEM vExecuteSQL;
    
    LET vExecuteSQL = '';
    LET vExecuteSQL ='rm -f '||RUTA_UNLOAD||PREFIJO_SCRIPTS||'reg_trans.unl';
    SYSTEM vExecuteSQL;

    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO, vFechaInicio, vFechaFinal;

END;
END PROCEDURE
/*
Fecha de creacion: 02 de agosto
Fecha de actualizacion: 29 de abril del 2019
Solicitud de implementacion. Rational ID 
RQM 10 1102 Implementar Reporte de CVV2 dinamico.
Ejecucion mediante el job pro_659_repo_transacc_cvv_dinamico_intercard.sh
*/
;

CREATE PROCEDURE "informix".sp_tarjetas_por_caja(pFechaInicio DATETIME YEAR TO FRACTION(5), pFechaFin DATETIME YEAR TO FRACTION(5) )    
    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(120) AS MENSAJE_RETORNO, INTEGER AS vRegistrosAfectados;
	
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(120);
	DEFINE RUTA_ORIGEN VARCHAR(50);
    DEFINE vNumTarjetaIni CHAR(16);
    DEFINE vNumTarjetaFin CHAR(16);    
    DEFINE vNumLote CHAR(12);
    DEFINE vRegistrosAfectados INTEGER;
    
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_ORIGEN = '/resplogifx/';
    LET vNumTarjetaIni = '';
    LET vNumTarjetaFin = '';
    LET vNumLote = '';
    LET vRegistrosAfectados = 0;
    
    --SET DEBUG FILE TO RUTA_ORIGEN || "ejec_sp_tarjetas_por_caja.out";
    --TRACE ON;        
	
    BEGIN 
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
            
        ----Paso 1. ---Cajas recibidas
		DROP TABLE IF EXISTS tmp_rangos_lote;        
        SELECT numlote, tarjetaini, tarjetafin
            FROM intercard:rangos_lote        
        WHERE fecharec >= pFechaInicio
            AND fecharec <= pFechaFin
        INTO TEMP tmp_rangos_lote WITH NO LOG;
            
        ----Paso 2.
        ---Obtenemos los registros de cajas recibidas en sucursal de los lotes
        ---para el conteo respecto al numero solicitado total
        DROP TABLE IF EXISTS tmp_tarjetas_cajas;
        SELECT codstatustarjeta, codstatusasignada, numtarjeta, numerolote
            FROM intercard:tarjeta
        WHERE numerolote IN (SELECT numlote FROM tmp_rangos_lote)
        AND codstatusasignada = 'NOE'
        INTO TEMP tmp_tarjetas_cajas WITH NO LOG;

        ---Paso 3.
        FOREACH cursor1 WITH HOLD FOR
            
            SELECT tarjetaini, tarjetafin, numlote 
                INTO vNumTarjetaIni, vNumTarjetaFin, vNumLote
            FROM tmp_rangos_lote
            
            BEGIN;            
                UPDATE "informix".tarjeta
                    SET codstatusasignada = 'NOA'
                WHERE numerolote = vNumLote
                    AND numtarjeta BETWEEN vNumTarjetaIni AND vNumTarjetaFin
                    AND codstatusasignada = 'NOE';
                    LET vRegistrosAfectados = vRegistrosAfectados + dbinfo("sqlca.sqlerrd2");
            COMMIT;
                
        END FOREACH;

		RETURN CODIGO_RETORNO, MENSAJE_RETORNO, vRegistrosAfectados;
		
	END
END PROCEDURE;