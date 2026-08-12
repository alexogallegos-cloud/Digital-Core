CREATE PROCEDURE "informix".sp_tarjetas_lotes_recibidos(pFechaInicio DATETIME YEAR TO FRACTION(5), pFechaFin DATETIME YEAR TO FRACTION(5) )    
    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(120) AS MENSAJE_RETORNO;
	
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(120);
	DEFINE RUTA_ORIGEN VARCHAR(50);    
    DEFINE PREFIJO_SCRIPTS CHAR(10);
    DEFINE vCadenaTmp CHAR(50);
    DEFINE vUserInsert VARCHAR(100);


    DEFINE vFechaInAuth DATE;
    DEFINE vTipoTrx CHAR(2);
    
    DEFINE vNumLote CHAR(12);
    
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET PREFIJO_SCRIPTS = 'trx_monit_';	
    LET RUTA_ORIGEN = '/ifxsif01/_argoz/lecciones/';
	


    ------------------
    LET vFechaInAuth = '';
    LET vTipoTrx = '';
    LET vNumLote = '';

    ---SET DEBUG FILE TO RUTA_ORIGEN || "ejec_sp_tarjetas_lotes_recibidos.out";
    --TRACE ON;        
	
    BEGIN 
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
            
        ----Paso 1. ---Lotes generados
        DROP TABLE IF EXISTS tmp_lotes_cantidad_total;        
        SELECT cantidadtarjetassol, numerolote 
            FROM intercard:lote
        WHERE fechageneracion >= pFechaInicio
            AND fechageneracion <= pFechaFin            
        --WHERE fechageneracion >= '2018-10-01 00:00:00'
          --  AND fechageneracion <= today
        INTO TEMP tmp_lotes_cantidad_total WITH NO LOG; -- 9 214

        ----Paso 2.
        ---Obtenemos los registros de cajas recibidas en sucursal de los lotes
        ---para el conteo respecto al nÃºmero solicitado total
        DROP TABLE IF EXISTS tmp_rangos_lote;        
        SELECT * 
            FROM intercard:rangos_lote
        --WHERE fecharec >= '2018-10-01 00:00:00'
          --  AND fecharec <= today
        WHERE fecharec >= pFechaInicio
            AND fecharec <= pFechaFin
        INTO TEMP tmp_rangos_lote WITH NO LOG; --14 772

        ---Paso 3.
        --- Cada nÃºmero de caja lo multiplicamos por 250
        ---dejando a un lado las tarjetas personalizadas
        DROP TABLE IF EXISTS rangos_lote_agrupado;
        SELECT numlote, ( COUNT(*) * 250) as numero_cajas
            FROM tmp_rangos_lote
        GROUP BY 1
        INTO TEMP rangos_lote_agrupado WITH NO LOG; --- 6373
        
        --Paso 4.
        ---El total del numero de cajas (250) igual al numero de tarjetas solicitadas por lote del paso 1
        DROP TABLE IF EXISTS tmp_lotes_iguales;
        SELECT b.numerolote
            FROM rangos_lote_agrupado a, tmp_lotes_cantidad_total b
        WHERE a.numlote = b.numerolote
            AND a.numero_cajas = b.cantidadtarjetassol        
        INTO TEMP tmp_lotes_iguales WITH NO LOG; --3, 592
        
        DROP TABLE IF EXISTS tmp_numeros_lote_resultantes;
        SELECT DISTINCT numerolote
            FROM intercard:tarjeta 
        WHERE numerolote IN (SELECT numerolote FROM tmp_lotes_iguales)
            AND codstatusasignada = 'NOE'
        INTO TEMP tmp_numeros_lote_resultantes WITH NO LOG;


        FOREACH cursor1 WITH HOLD FOR
            
            SELECT numerolote 
                INTO vNumLote 
            FROM tmp_numeros_lote_resultantes
            
            BEGIN;            
                UPDATE "informix".tarjeta
                    SET codstatusasignada = 'NOA'
                WHERE numerolote = vNumLote
                    AND codstatusasignada = 'NOE';            
            COMMIT;
                
        END FOREACH;

  
    
		RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
		
	END
END PROCEDURE;