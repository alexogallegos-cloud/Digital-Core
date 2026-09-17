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