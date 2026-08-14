CREATE PROCEDURE "informix".sp_actualizar_tarjetas()
    
    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(120) AS MENSAJE_RETORNO;
	
	DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(120);
	DEFINE RUTA_ORIGEN VARCHAR(50);    
    DEFINE PREFIJO_SCRIPTS CHAR(10);
    DEFINE vCadenaTmp CHAR(50);
    DEFINE vUserInsert VARCHAR(100);
    DEFINE cPlazoSMS_Inv CHAR(20);
    DEFINE cPlazoSMS CHAR(20);
	
    DEFINE vFechaHoy DATE;
    DEFINE vFechaServidor DATE;
    DEFINE vFechaEjecucion DATE;
    DEFINE vTrxsAcumuladas INTEGER;
    DEFINE vExisteRegistro SMALLINT;
    
    DEFINE vFechaInAuth DATE;
    DEFINE vTipoTrx CHAR(2);
    
    DEFINE vNumLote CHAR(8);
    
	LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET PREFIJO_SCRIPTS = 'trx_monit_';	
    LET RUTA_ORIGEN = '/ifxsif01/_argoz/lecciones/';
	
    LET vUserInsert	= '';	
	LET vCadenaTmp = '';	
	LET cPlazoSMS_Inv = '18, 12, 06';	
	LET cPlazoSMS = '';	

    LET vFechaHoy = '';
    LET vFechaServidor = '';
    LET vFechaEjecucion = '';	
    LET vTrxsAcumuladas = 0;	
    LET vExisteRegistro = 0;	
    
    

    ------------------
    LET vFechaInAuth = '';
    LET vTipoTrx = '';
    LET vNumLote = '';

    --SET DEBUG FILE TO RUTA_ORIGEN || "ejec_sp_actualizar_tarjetas.out";
    --TRACE ON;        
	
    BEGIN 
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
            
        drop table if exists tmp_numeros_lote;
        SELECT numerolote 
            FROM intercard:flujolote
        WHERE fecha >= '2019-01-01 00:00:00' AND fecha <= '2019-04-25 00:00:00' 
        and codflujo = 'RES'
        INTO TEMP tmp_numeros_lote WITH NO LOG; ----Lotes recibidos: 2, 287


        FOREACH cursor1 WITH HOLD FOR
            
            SELECT numerolote 
                INTO vNumLote 
                FROM tmp_numeros_lote
            BEGIN;
                update "informix".tarjeta
                set codstatusasignada = 'NOA'
                where numerolote = vNumLote
                and  codstatusasignada = 'NOE';
            COMMIT;
                
        END FOREACH;
    
  
    
		RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
		
	END
END PROCEDURE
;