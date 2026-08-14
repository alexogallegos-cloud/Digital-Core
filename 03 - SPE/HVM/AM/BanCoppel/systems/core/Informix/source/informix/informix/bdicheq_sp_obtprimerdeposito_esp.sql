CREATE PROCEDURE "informix".sp_obtprimerdeposito_esp(  )
RETURNING CHAR(6)  AS cod_ret,
          CHAR(80) AS desc_ret,
          INTEGER  AS procesados;
    
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
    DEFINE cCodRet2         CHAR(6);
	DEFINE cDescRet			CHAR(80);
	DEFINE vcomienza1       SMALLINT;
	DEFINE vabierto     	SMALLINT;
    DEFINE vcontador1   	INTEGER;
	DEFINE vcontador2   	INTEGER;
	DEFINE cCuenta     		CHAR(20);
	DEFINE dFech_alt   		DATE;
	DEFINE mMonto_tot   	MONEY;
    DEFINE dFechIniMovHis   DATE;
	
	LET iSqlErr      = 0;
	LET iIsamErr     = 0;
	LET cErrorInfo   = '';
	LET cCodRet      = '000000';
    LET cCodRet2     = '';
	LET cDescRet	 = 'PROCESO EXITOSO';
    LET vcomienza1   = -1;
	LET vabierto   	 = 0;
    LET vcontador1 	 = 0;
	LET vcontador2 	 = 0;
	LET cCuenta    	 = '';
	LET dFech_alt  	 = '';
	LET mMonto_tot   = 0.0;
    LET dFechIniMovHis = '';
	
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        SET DEBUG FILE TO '/resplogifx/conciliachq/sp_obtprimerdeposito_esp.err';
        TRACE ON;
        IF iSqlErr != 0 THEN
			LET cCodRet  = iSqlErr;
            LET cCodRet2 = iIsamErr;
			LET cDescRet = cErrorInfo;
            IF vabierto = 1 THEN
                ROLLBACK WORK;
            END IF;
			RETURN cCodRet, cDescRet, vcontador1;
		END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_obtprimerdeposito_esp.out';
	--- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor
      INTO dFechIniMovHis
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = 'fechcon_movhis';
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO cCuenta
          FROM sc_indicadores
         WHERE anio_mes = '201403'
           AND cuenta >= '10000005016'
         
        IF vcomienza1 = -1 THEN
            LET vcomienza1 = 0;
			BEGIN WORK;
			LET vabierto = 1; 
		END IF;
        
        SELECT fec_prim_deposito_orig, imp_prim_deposito_orig
          INTO dFech_alt, mMonto_tot
          FROM sc_indicadores_esp
         WHERE cuenta = cCuenta;
         
        IF dFech_alt <> '01/01/1900' THEN
            UPDATE sc_indicadores
               SET fec_prim_deposito_orig = dFech_alt, 
                   imp_prim_deposito_orig = mMonto_tot,
                   anio_mes = '201404'
             WHERE cuenta = cCuenta;
        ELSE                                                  
            FOREACH
                SELECT FIRST 1 mov.fech_alt, mov.monto_tot
                  INTO dFech_alt, mMonto_tot
                  FROM sc_movhis mov,   
                       bdinteg:si_transacc trx
                 WHERE mov.empresa = trx.empresa
                   AND mov.cuenta = cCuenta
                   AND mov.fech_alt >= dFechIniMovHis
                   AND mov.cancelad <> 'S'   
                   AND mov.transacc = trx.numero
                   AND trx.naturaleza = 'A'  
                   AND trx.se_emite_edocta = 'S'
                 ORDER BY mov.num_serial
                 
                IF dFech_alt is not null AND mMonto_tot is not null THEN
                    UPDATE sc_indicadores
                       SET fec_prim_deposito_orig = dFech_alt, 
                           imp_prim_deposito_orig = mMonto_tot,
                           anio_mes = '201404'
                     WHERE cuenta = cCuenta;
                    
                    EXIT FOREACH;
                ELSE
                    UPDATE sc_indicadores
                       SET anio_mes = '201404'
                     WHERE cuenta = cCuenta;
                     
                    EXIT FOREACH;
                END IF;
            END FOREACH;
        END IF;
                                 
        LET vcontador1 = vcontador1 + 1;
		LET vcontador2 = vcontador2 + 1;
		
		IF vcontador2 >= 1000 THEN
			LET vcontador2 = 0;			
			COMMIT WORK;
            BEGIN WORK;
		END IF;
	END FOREACH;
    
    IF vabierto = 1 THEN
		COMMIT WORK;
        LET vabierto = 0;
	END IF;
    
	RETURN cCodRet, cDescRet, vcontador1;
    
    END;
    
END PROCEDURE;