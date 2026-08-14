CREATE PROCEDURE "informix".sp_idetraspasomovtoshistorico()
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
    DEFINE iExisteFecha         INTEGER;
    DEFINE iRegsTot             INTEGER;
    DEFINE iExisteProc          SMALLINT;
    DEFINE vcCodRetParam        CHAR(5);
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
    LET iExisteFecha        = 0;
    LET iRegsTot            = 0;
    LET iExisteProc         = 0;
    LET vcCodRetParam       = '';
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
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_idetraspasomovtoshistorico.err';
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
    
    --- SET DEBUG FILE TO '/home/sysifx/jesusm/costos/sp_idetraspasomovtoshistorico.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
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
    
    -- // GUARDA NUMERO DE REGISTROS TOTALES A TRASPASAR
    SELECT COUNT(*)
      INTO iExisteFecha
      FROM sl_trasp_movefec_movefechis
     WHERE fecha >= dtPriDiaMes;
     
    IF iExisteFecha = 0 THEN
        SELECT COUNT(*)
          INTO iRegsTot
          FROM sl_movefec
         WHERE fecha_mov BETWEEN dtFechaIni AND dtFechaFin
           AND num_serial > 0; 
         
        INSERT INTO sl_trasp_movefec_movefechis(fecha, no_regs)
        VALUES(dtFechaHoy, iRegsTot);
    END IF;
    
    -- // ACTUALIZA BANDERA DE INICIO DE PROCESO
    SELECT COUNT(*) 
      INTO iExisteProc
      FROM bdilide:"informix".sl_procesos	
     WHERE proceso = "traspmovefec" 
       AND fech_proceso = dtFechaHoy; 
       
    IF iExisteProc = 0 THEN
        INSERT INTO bdilide:"informix".sl_procesos
        (proceso, fech_proceso, status, user_insert, fecha_insert)
        VALUES
        ("traspmovefec", dtFechaHoy, '0', cUser, current hour to fraction(3));
    ELSE
        UPDATE sl_procesos
           SET status = '0'
         WHERE proceso = 'traspmovefec'
           AND fech_proceso = dtFechaHoy;
    END IF;
    
    -- // INVOCA PROCESO PARA ACTUALIZAR PARAMETROS DE NUMEROS DE SERIALES
    EXECUTE PROCEDURE "informix".sp_actparamtraspmovefec(dtFechaIni, dtFechaFin)
    INTO vcCodRetParam;
    
    IF vcCodRetParam = '000' THEN
        -- // ACTUALIZA BANDERA DE INICIO DE PROCESO
        UPDATE sl_procesos
           SET status = '1'
         WHERE proceso = 'traspmovefec'
           AND fech_proceso = dtFechaHoy;
    ELSE
        LET cCodRet = '000005';
        LET cMensajeRet = 'FALLO PROCESO DE PARAMETROS. VERIFIQUE.';
        RETURN cCodRet,cMensajeRet;
    END IF;
    
    -- // OBTIENE VALORES PARA RANGO DE SERIALES A PROCESAR
    SELECT valor::integer
      INTO viSerialFinal
      FROM sl_parametros
     WHERE cve_param = 'TrasMov1';
     
    SELECT COUNT(*)
      INTO viRegsxTraspasar
      FROM sl_movefec
     WHERE fecha_mov BETWEEN dtFechaIni AND dtFechaFin
       AND num_serial < viSerialFinal; 
        
    -- // se realiza el traspaso de movimientos del mes a la tabla historica.
    FOREACH WITH HOLD 
        SELECT fecha_mov, num_serial 
          INTO dtFecha_mov, iNum_serial 
          FROM bdilide:"informix".sl_movefec
         WHERE fecha_mov BETWEEN dtFechaIni AND dtFechaFin
           AND num_serial < viSerialFinal
           
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
       AND num_serial < viSerialFinal;
       
    SELECT COUNT(*)
      INTO viRegsSinTraspasar
      FROM bdilide:"informix".sl_movefec
     WHERE fecha_mov BETWEEN dtFechaIni AND dtFechaFin
       AND num_serial < viSerialFinal; 
         
    IF ( ( viRegsxTraspasar <> viRegsTraspasados ) OR viRegsSinTraspasar <> 0) THEN
        LET cCodRet = '000006';
        LET cMensajeRet = 'EL NUMERO DE REGISTROS TRASPASADOS ES INCORRECTO. VERIFIQUE.';
        RETURN cCodRet,cMensajeRet;
    END IF;
    
    RETURN cCodRet,cMensajeRet;
        
    END;
        
END PROCEDURE;