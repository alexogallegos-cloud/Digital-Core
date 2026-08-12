CREATE PROCEDURE "informix".sp_idetraspasomovtoshistoricocomp2()
RETURNING CHAR(6)  AS codigo_retorno,
		  CHAR(80) AS Mensaje_retorno;
    
    DEFINE cCodRet              CHAR(6);
    DEFINE cCodRet2             CHAR(6);
    DEFINE cCodRet3             CHAR(60);
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cErrorInfo           CHAR(80);
    DEFINE cMensajeRet          CHAR(80);
    DEFINE cUser		        CHAR(10);
    DEFINE dtFechaHoy           DATE;
    DEFINE dtFechaAnt	        DATE;
    DEFINE dtPriDiaMes          DATE;
    DEFINE dtUltDiaMes          DATE;
    DEFINE dtFechaIni           DATE;
    DEFINE dtFechaFin           DATE;
    DEFINE viRegsTotxTrasp      INTEGER;
    DEFINE iExisteGenCons       INTEGER;
    DEFINE iInicioProc          SMALLINT;
    DEFINE iExisteFecha         INTEGER;
    DEFINE iRegsTot             INTEGER;
    DEFINE viSerialInicial      INTEGER;
    DEFINE viSerialFinal        INTEGER;
    DEFINE viRegsxTraspasar     INTEGER;
    DEFINE dtFecha_mov          DATE;
    DEFINE iNum_serial          INTEGER;
    DEFINE iCont		        INTEGER;
    DEFINE cCommit		        CHAR(1);
    DEFINE viRegsTraspasados    INTEGER;
    DEFINE viRegsSinTraspasar   INTEGER;
    
    LET cCodRet  			= "000000";
    LET cCodRet2  			= "";
    LET cCodRet3  			= "";
    LET iSqlErr 			= 0;
    LET iIsamErr            = 0;
    LET cErrorInfo          = '';
    LET cMensajeRet  		= "PROCESO EXITOSO";
    LET cUser	 			= USER;
    LET dtFechaHoy          = '';
    LET dtFechaAnt	        = '';
    LET dtPriDiaMes         = '';
    LET dtUltDiaMes	        = '';
    LET dtFechaIni          = '';
    LET dtFechaFin          = '';
    LET viRegsTotxTrasp     = 0;
    LET iExisteGenCons      = 0;
    LET iInicioProc         = 0;
    LET iExisteFecha        = 0;
    LET iRegsTot            = 0;
    LET viSerialInicial     = 0;
    LET viSerialFinal       = 0;
    LET viRegsxTraspasar    = 0;
    LET dtFecha_mov         = '';
    LET iNum_serial         = 0;
    LET iCont               = 0;
    LET cCommit             = "N";
    LET viRegsTraspasados   = 0;
    LET viRegsSinTraspasar  = 0;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_idetraspasomovtoshistoricocomp2.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iIsamErr;
        LET cCodRet3 = cErrorInfo;
        IF cCommit = "S" THEN
            ROLLBACK WORK;
        END IF;
        LET cMensajeRet = 'ERROR DE INFORMIX. VERIFIQUE BITACORA DE ERROR.';
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- SET DEBUG FILE TO '/home/sysifx/jesusm/costos/sp_idetraspasomovtoshistoricocomp2.out';
    --- TRACE ON;
    
    SELECT fecha_hoy, fecha_ant, pri_dia_mes, ult_dia_mes
      INTO dtFechaHoy, dtFechaAnt, dtPriDiaMes, dtUltDiaMes
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = '001';
     
    LET dtFechaIni = dtPriDiaMes - 1 UNITS MONTH;
    LET dtFechaFin = dtPriDiaMes - 1 UNITS DAY;
    
    -- // VALIDA QUE EXISTAN REGISTROS PARA TRASPASAR
    SELECT COUNT(*)
      INTO viRegsTotxTrasp
      FROM bdilide:"informix".sl_movefec
     WHERE tipo_cta IN('D','C')
       AND fecha_mov BETWEEN dtFechaIni AND dtFechaFin;
       
    IF viRegsTotxTrasp = 0 THEN
        LET cCodRet = "000004";
        LET cMensajeRet = 'NO HAY REGISTROS PARA TRASPASAR. VERIFIQUE.'; 
        RETURN cCodRet, cMensajeRet;
    END IF;
    
    -- // valida que el proceso mensual de generacion de constancias ya se haya ejecutado
    SELECT COUNT(*)
      INTO iExisteGenCons
      FROM bdilide:"informix".sl_procesos 
     WHERE proceso = "conmensual" 
       AND fech_proceso = dtFechaAnt 
       AND status = '1';
    
    IF iExisteGenCons = 0 THEN
        LET cCodRet = "000002";
        LET cMensajeRet = 'NO SE HA EFECUTADO LA GENERACION DE CONSTANCIAS MENSUALES'; 
        RETURN cCodRet, cMensajeRet;
    END IF;
       
    -- // VALIDA QUE YA SE HAYAN ACTUALIZADO LOS PARAMETROS DE SERIALES
    WHILE iInicioProc = 0 
        SELECT COUNT(*)
          INTO iInicioProc
          FROM sl_procesos
         WHERE proceso = 'traspmovefec'
           AND fech_proceso = dtFechaHoy
           AND status = '1';
    END WHILE;
    
    -- // OBTIENE VALORES PARA RANGO DE SERIALES A PROCESAR
    SELECT valor::integer
      INTO viSerialInicial
      FROM sl_parametros
     WHERE cve_param = 'TrasMov2';
    
    -- // VALIDA QUE EXISTAN REGISTROS PARA TRASPASAR
    SELECT COUNT(*)
      INTO viRegsxTraspasar
      FROM bdilide:"informix".sl_movefec
     WHERE fecha_mov BETWEEN dtFechaIni AND dtFechaFin
       AND num_serial >= viSerialInicial;
       
    IF viRegsxTraspasar = 0 THEN
        LET cCodRet = "000004";
        LET cMensajeRet = 'NO HAY REGISTROS PARA TRASPASAR. VERIFIQUE.'; 
        RETURN cCodRet, cMensajeRet;
    END IF;
    
    -- // se realiza el traspaso de movimientos del mes a la tabla historica.
    FOREACH WITH HOLD 
        SELECT fecha_mov, num_serial 
          INTO dtFecha_mov, iNum_serial 
          FROM bdilide:"informix".sl_movefec
         WHERE fecha_mov BETWEEN dtFechaIni AND dtFechaFin
           AND num_serial >= viSerialInicial
           
        BEGIN WORK;
        LET cCommit = "S";
        
        -- // se agrea la informacion a la tabla historica.
        INSERT INTO bdilide:"informix".sl_movefec_his 
        SELECT *
          FROM sl_movefec
         WHERE fecha_mov = dtFecha_mov
           AND num_serial = iNum_serial;
        
        -- // se borra el registro que se inserto en la historica
        DELETE FROM bdilide:"informix".sl_movefec 
         WHERE fecha_mov = dtFecha_mov
           AND num_serial = iNum_serial;
        
        LET iCont = iCont +1;
        
        COMMIT WORK;
        LET cCommit = "N"; 
    END FOREACH;
    
    SELECT COUNT(*)
      INTO viRegsTraspasados
      FROM bdilide:"informix".sl_movefec_his 
     WHERE fecha_mov BETWEEN dtFechaIni AND dtFechaFin
       AND num_serial >= viSerialInicial;
       
    SELECT COUNT(*)
      INTO viRegsSinTraspasar
      FROM bdilide:"informix".sl_movefec
     WHERE fecha_mov BETWEEN dtFechaIni AND dtFechaFin
       AND num_serial >= viSerialInicial;
       
    IF ( ( viRegsxTraspasar <> viRegsTraspasados ) OR viRegsSinTraspasar <> 0 ) THEN
        LET cCodRet = '000006';
        LET cMensajeRet = 'EL NUMERO DE REGISTROS TRASPASADOS ES INCORRECTO. VERIFIQUE.';
        RETURN cCodRet,cMensajeRet;
    END IF;
    
    RETURN cCodRet,cMensajeRet;
        
    END;
        
END PROCEDURE;