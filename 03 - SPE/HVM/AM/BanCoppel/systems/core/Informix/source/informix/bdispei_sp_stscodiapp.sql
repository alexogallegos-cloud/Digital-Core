CREATE PROCEDURE "informix".sp_stscodiapp( vchridtpa       CHAR(2),   -- Identificador de Tipo de Aviso       
                                           vchridmjc       CHAR(20),      -- Identificador del mensaje de cobro
                                           vchrfchmjc      CHAR(20),      -- Estampa de tiempo del cobro 
                                           vchrconcepto    CHAR(50),      -- Concepto
                                           mnyimporte      DECIMAL(12,2), -- Monto
                                           vchrcveras      CHAR(30),      -- Clave de rastreo    
                                           vchrrefnum      CHAR(7),       -- Referencia NumÃ©rica                                                  
                                           vchrcelord      CHAR(10),      -- NÃºmero de celular  ordenante 
                                           vchrdiveord     CHAR(3),       -- Digito verificador 
                                           vchrbancoord    CHAR(5),       -- Banco ord   
                                           vchrtpoctaord   CHAR(2),       -- Tipo de cuenta ordenante
                                           vchrctaord      CHAR(20),      -- Cuenta ordenante
                                           vchrnomord      CHAR(40),      -- Nombre ordenante
                                           vchrcelbenf     CHAR(20),      -- NÃºmero celular beneficiario
                                           vchrdivebenf    CHAR(3),       -- Digito verificador beneficiario
                                           vchrbancobenf   CHAR(5),       -- Banco beneficiario
                                           vchrtpoctabenf  CHAR(2),       -- Tipo de cuenta beneficiario
                                           vchrctabenf     CHAR(20),      -- Cuenta  beneficiario
                                           vhrnombenf      CHAR(40))      -- Nombre Beneficiario 
RETURNING char(5);
    
    DEFINE vcodret      char(5);
    DEFINE vcodret2     char(5);
    DEFINE vcodret3     char(50);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE desc_err     char(80);
    
    DEFINE vchrcode         CHAR(2);
    DEFINE vchrfchfinpro    CHAR(23);
    DEFINE vchrcvespeienva  CHAR(5);
    DEFINE vchrfchenvpro    CHAR(23);
    DEFINE vtimestamp       CHAR(13);
	DEFINE longctaord       INTEGER;
	DEFINE longctaben       INTEGER;
	DEFINE wmnyimpo          CHAR(1);
	-- // FIRMA
	DEFINE ret						INTEGER;
	DEFINE wvchrfirma 			    CHAR(512);
	DEFINE wchrcadena_00			CHAR(3000);
	DEFINE wchrcadena_01			CHAR(200);
	DEFINE wchrcadena_02			CHAR(200);
	DEFINE wchrcadena_03			CHAR(200);
	
    
    LET vcodret  = '00000';
    LET vcodret2 = '';
    LET vcodret3 = '';
    LET sql_err  = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vchrcode = '';
    LET vchrfchfinpro = '';
    LET vchrcvespeienva = '';
    LET vchrfchenvpro = '';
    LET vtimestamp = '';
	LET longctaord = LENGTH(vchrctaord);
	LET longctaben = LENGTH(vchrctabenf);
	
	-- // FIRMA
	LET ret           = 0;
	LET wvchrfirma    = '';
	LET wchrcadena_00 = '';
	LET wchrcadena_01 = '';
	LET wchrcadena_02 = '';
	LET wchrcadena_03 = '';
	
    
	BEGIN
    
	ON EXCEPTION SET sql_err, isam_err, desc_err
       --SET DEBUG FILE TO "/informix/ifg/sp_stscodiapp.out";
       SET DEBUG FILE TO "/RESPALDOSNEW/sp_stscodiapp_err.out";
       TRACE ON;
		IF sql_err <> 0 THEN
            LET vcodret  = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
			RETURN vcodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/ifg/sp_stscodiapp.out";
    --SET DEBUG FILE TO "/informix/Priscilla/sp_stscodiapp.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    IF (vchridtpa is null OR vchridtpa = '')   OR
       (vchridmjc is null OR LENGTH(vchridmjc) <> 20) OR
       (vchrcelord is null OR vchrcelord = '') OR
       (vchrbancoord is null OR vchrbancoord = '') OR
       (vchrtpoctaord is null OR vchrtpoctaord = '') OR
       (vchrctaord is null OR vchrctaord = '') OR
       (vchrcelbenf is null OR  vchrcelbenf = '') OR
       (vchrbancobenf is null OR vchrbancobenf = '') OR
       (vchrtpoctabenf is null OR vchrtpoctabenf = '') OR
       (vchrctabenf is null OR vchrctabenf = '') THEN
        LET vcodret = '110';
        LET vchrcode = '8';
    END IF;
    
    IF vchridtpa IN ('1','2','4') THEN
        LET vcodret = '000';
        LET vchrcode = '0';
    END IF;
   
    --//ValidaciÃ³n para el aviso de procesamiento y cadena  para que no lleve blancos o nulos
    IF vchrconcepto IS NULL OR vchrconcepto = '' THEN
       LET vchrconcepto = '-';
    END IF;
	
	IF vchrfchmjc IS NULL OR vchrfchmjc = ',' THEN --- solo pruebas quitarr este if
       LET vchrfchmjc = '';
    END IF;
	
    IF vchrcveras IS NULL OR vchrcveras = '' THEN
       LET vchrcveras = '-';
    END IF;

    IF vchrrefnum IS NULL OR vchrrefnum = '' OR vchrrefnum = '-'  OR vchrrefnum = 'null'  OR vchrrefnum = 'NULL'THEN
       LET vchrrefnum = '0';
    END IF;

    IF vchrcelord IS NULL OR vchrcelord = '' THEN
       LET vchrcelord = '-';
    END IF;

    IF vchrdiveord IS NULL OR vchrdiveord = '' THEN
       LET vchrdiveord = '-';
    END IF;

    IF vchrbancoord IS NULL  THEN
       LET vchrbancoord = 0;
    END IF;

    IF vchrtpoctaord IS NULL OR vchrtpoctaord = '' THEN
       LET vchrtpoctaord = '-';
    END IF;

    IF vchrctaord IS NULL OR vchrctaord = '' THEN
       LET vchrctaord = '-';
    END IF;

    IF vchrnomord IS NULL OR vchrnomord = '' THEN
       LET vchrnomord = '-';
    END IF;

    IF vchrcelbenf IS NULL OR vchrcelbenf = '' THEN
       LET vchrcelbenf = '-';
    END IF;

    IF vchrdivebenf IS NULL OR vchrdivebenf = '' THEN
       LET vchrdivebenf = '-';
    END IF;

    IF vchrbancobenf IS NULL  THEN
       LET vchrbancobenf = 0;
    END IF;

    IF vchrtpoctabenf IS NULL OR vchrtpoctabenf = '' THEN
       LET vchrtpoctabenf = '-';
    END IF;

    IF vchrctabenf IS NULL OR vchrctabenf = '' THEN
       LET vchrctabenf = '-';
    END IF;

    IF vhrnombenf IS NULL OR vhrnombenf = '' THEN
       LET vhrnombenf = '-';
    END IF;	
   
	--LET vchrrefnum =  TO_CHAR(current, '%d%m%y') ;
	
    LET vchrfchfinpro = CURRENT;
    LET vtimestamp  = dbinfo('utc_current') * 1000;
    
	--//Se valida si el importe es cero para enviar un '-'  en el aviso
	IF mnyimporte = 0 THEN
		LET wmnyimpo = '-';
		/*generaciÃ³n de firma*/
		LET wchrcadena_01 = TRIM(vchridtpa)||'|'||TRIM(vchrcode)||'|'|| TRIM(vchridmjc)||'|'||TRIM(vchrfchmjc)||'|'|| TRIM(vchrconcepto)||'|'|| wmnyimpo||'|'|| TRIM(vtimestamp);
		LET wchrcadena_02 = '|'||TRIM(vchrcveras)||'|'|| TRIM(vchrrefnum)||'|'||vchrcelord||'|'||TRIM(vchrdiveord)||'|'|| vchrbancoord||'|'||TRIM(vchrtpoctaord)||'|'||TRIM(vchrctaord);
		LET wchrcadena_03 = '|'||TRIM(vchrnomord)||'|'||TRIM(vchrcelbenf)||'|'||TRIM(vchrdivebenf)||'|'||vchrbancobenf||'|'||TRIM(vchrtpoctabenf)||'|'|| TRIM(vchrctabenf)||'|'|| vhrnombenf;
		LET wchrcadena_00 = TRIM(wchrcadena_01)||TRIM(wchrcadena_02)||TRIM(wchrcadena_03);
	ELSE	
		/*generaciÃ³n de firma*/
		LET wchrcadena_01 = TRIM(vchridtpa)||'|'||TRIM(vchrcode)||'|'|| TRIM(vchridmjc)||'|'||TRIM(vchrfchmjc)||'|'|| TRIM(vchrconcepto)||'|'|| mnyimporte||'|'|| TRIM(vtimestamp);
		LET wchrcadena_02 = '|'||TRIM(vchrcveras)||'|'|| TRIM(vchrrefnum)||'|'||vchrcelord||'|'||TRIM(vchrdiveord)||'|'|| vchrbancoord||'|'||TRIM(vchrtpoctaord)||'|'||TRIM(vchrctaord);
		LET wchrcadena_03 = '|'||TRIM(vchrnomord)||'|'||TRIM(vchrcelbenf)||'|'||TRIM(vchrdivebenf)||'|'||vchrbancobenf||'|'||TRIM(vchrtpoctabenf)||'|'|| TRIM(vchrctabenf)||'|'|| vhrnombenf;
		LET wchrcadena_00 = TRIM(wchrcadena_01)||TRIM(wchrcadena_02)||TRIM(wchrcadena_03);
		
	END IF;
	
	LET wvchrfirma = space(512);
	
	EXECUTE function bdispei:syn_sign(TRIM(wchrcadena_00), wvchrfirma, 20) 
	INTO ret;
	
	LET wvchrfirma = wvchrfirma;
	
    INSERT INTO tbl_stsprocodi VALUES( 
        0, 'N', vchridtpa, vchrcode, vchridmjc, vchrfchmjc, vchrconcepto, mnyimporte, vtimestamp, vchrcveras, vchrrefnum,             
        vchrcelord, vchrdiveord, vchrbancoord, vchrtpoctaord, vchrctaord, vchrnomord, vchrcelbenf, vchrdivebenf,   
        vchrbancobenf, vchrtpoctabenf, vchrctabenf, vhrnombenf, NULL,wvchrfirma,current);
    
    END;
    
    RETURN vcodret;
    
END PROCEDURE
DOCUMENT
'CREADO POR: PRISCILLA BENITO',
'OBJETIVO: GENERAR Y GUARDAR LA ESTRUCTURA DEL AVISO DE PROCESAMIENTO (RECHAZAR/POSPONER)',
'BD: BDISPEI';

CREATE PROCEDURE "informix".spei_concilia_cargos_ef( pEmpresa CHAR(3) )
RETURNING CHAR(5);

    DEFINE cCodRet1    CHAR(5);
    DEFINE cCodRet2    CHAR(5);
    DEFINE cCodRet3    CHAR(50);
    DEFINE iSqlErr     INTEGER;
    DEFINE iSamErr     INTEGER;
    DEFINE iDesErr     CHAR(50);
    DEFINE iTransacc   SMALLINT;
    DEFINE iExisteTbl  SMALLINT;
    DEFINE cSQL        CHAR(500);
    DEFINE dFechaHoy   DATE;
    DEFINE dFechaAnt   DATE;
    DEFINE cCveRastreo VARCHAR(40);
    DEFINE cCuentaOrd  VARCHAR(20);
    DEFINE dMonto      DECIMAL(19,2);
    DEFINE cCuentaChq  VARCHAR(20);    
    DEFINE iExisteTrx  SMALLINT;
    DEFINE i           INTEGER;
    DEFINE j           INTEGER;
    DEFINE iExisteFer  SMALLINT;
    DEFINE dFechaValor DATE;
    DEFINE dFechaCaptu DATE;
    DEFINE cTrxOpera   CHAR(4);
    
    LET cCodRet1    = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr	    = 0;
    LET iSamErr     = 0;
    LET iDesErr     = 0;
    LET iTransacc   = 0;
    LET iExisteTbl  = 0;
    LET cSQL        = '';
    LET dFechaHoy   = '';
    LET dFechaAnt   = '';
    LET cCveRastreo = '';
    LET cCuentaOrd  = '';
    LET dMonto      = 0.00;
    LET cCuentaChq  = '';
    LET iExisteTrx  = 0;
    LET i           = 0;
    LET j           = 0;
    LET iExisteFer  = 0;
    LET dFechaValor = '';
    LET dFechaCaptu = '';
    LET cTrxOpera   = '';
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_concilia_cargos_ef.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = iDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_concilia_cargos_ef.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // CARGA REGISTROS POR VALIDAR
    SELECT COUNT(*) 
      INTO iExisteTbl
      FROM sysmaster:systabnames 
     WHERE partnum > 0 
       AND tabname = 'cargos_spei';
    
    IF iExisteTbl > 0 THEN
        DROP TABLE "informix".cargos_spei;
    END IF;
    
    CREATE TABLE "informix".cargos_spei
      ( 
        clave_rastreo VARCHAR(40)
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_cargos_spei ON "informix".cargos_spei(clave_rastreo) ONLINE;
      
    LET cSQL = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_pago_spei.txt INSERT INTO cargos_spei;" > /resplogifx/conciliachq/cargos_spei.sql';
    SYSTEM cSQL;
    
    LET cSQL = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/cargos_spei.sql';
    SYSTEM cSQL;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cargos_spei;
    
    -- // CALCULA FECHAS OPERATIVAS DEL SPEI
    SELECT fecha_hoy
      INTO dFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = pEmpresa;
     
    LET i = 1;
    LET j = 1;
    
    WHILE i <= j
        LET dFechaAnt = dFechaHoy - j;

        IF (WEEKDAY(dFechaAnt) >= 1 AND WEEKDAY(dFechaAnt) <= 5) THEN
            SELECT COUNT(*) 
              INTO iExisteFer
              FROM bdinteg:si_feriado 
             WHERE empresa = pEmpresa 
               AND fecha = dFechaAnt;
               
            IF iExisteFer = 0 THEN
                EXIT WHILE;
            END IF;
        END IF;
        
        LET j = j + 1;
    END WHILE;
    
    -- // PROCESA REGISTROS
    FOREACH WITH HOLD
        SELECT vchrclaverastreo, vchrcuentaord, mnyimporte, dtfechavalor, dtfechacaptura, chrtxop
          INTO cCveRastreo, cCuentaOrd, dMonto, dFechaValor, dFechaCaptu, cTrxOpera
          FROM tblpago
         WHERE chrestatusenvio = 'E'
           AND vchrclaverastreo NOT IN(SELECT clave_rastreo FROM cargos_spei)
        
        BEGIN WORK;
        LET iTransacc = 1;
        
        IF LENGTH(cCuentaOrd) = 10 THEN
            SELECT cuenta
              INTO cCuentaChq
              FROM bdicheq:sc_cuenta_telefono
             WHERE telefono = cCuentaOrd;
        ELIF LENGTH(cCuentaOrd) = 11 THEN
            SELECT cuenta
              INTO cCuentaChq
              FROM bdicheq:sc_maechq
             WHERE cuenta = cCuentaOrd;
        ELIF LENGTH(cCuentaOrd) = 16 THEN
            SELECT cuenta
              INTO cCuentaChq
              FROM bdicheq:sc_tarjeta
             WHERE num_tarjeta = cCuentaOrd;
        ELIF LENGTH(cCuentaOrd) = 18 THEN
            SELECT cuenta
              INTO cCuentaChq
              FROM bdicheq:sc_maechq
             WHERE cuenta_clabe = cCuentaOrd;
        END IF;
        
        IF cCuentaChq is null OR cCuentaChq = '' THEN
            ROLLBACK WORK;
            LET iTransacc = 0;
            CONTINUE FOREACH;
        END IF;
        
        SELECT COUNT(*)
          INTO iExisteTrx
          FROM bdicheq:sc_movdia
         WHERE transacc IN('0274','0447')
           AND fech_val = dFechaHoy
           AND cancelad <> 'S'
           AND referencia = cCveRastreo
           AND cuenta = cCuentaChq
           AND monto_tot = dMonto;
           
        IF iExisteTrx = 0 THEN
            SELECT COUNT(*)
              INTO iExisteTrx
              FROM bdicheq:sc_movhis
             WHERE transacc IN('0274','0447')
               AND fech_val >= dFechaAnt
               AND cancelad <> 'S'
               AND referencia = cCveRastreo
               AND cuenta = cCuentaChq
               AND monto_tot = dMonto;
            
            IF iExisteTrx = 0 THEN
                ROLLBACK WORK;
                LET iTransacc = 0;
                CONTINUE FOREACH;
            END IF;
        END IF;
                
        SELECT COUNT(*)
          INTO iExisteTrx
          FROM bdicheq:sc_movdia
         WHERE transacc = '0276'
           AND fech_val = dFechaHoy
           AND cancelad <> 'S'
           AND referencia = cCveRastreo
           AND cuenta = cCuentaChq
           AND monto_tot = dMonto;
           
        IF iExisteTrx = 0 THEN
            SELECT COUNT(*)
              INTO iExisteTrx
              FROM bdicheq:sc_movhis
             WHERE transacc = '0276'
               AND fech_val >= dFechaAnt
               AND cancelad <> 'S'
               AND referencia = cCveRastreo
               AND cuenta = cCuentaChq
               AND monto_tot = dMonto;
            
            IF iExisteTrx = 0 THEN
                UPDATE tblpago
                   SET chrestatusenvio = 'N'
                 WHERE vchrclaverastreo = cCveRastreo;
                   
                IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                    INSERT INTO tblconciliacargos 
                    ( vchrclaverastreo, vchrcuentaord, mnyimporte, dtfechavalor, dtfechacaptura, chrtxop, chrcuentachq, dtfechaopera )
                    VALUES
                    ( cCveRastreo, cCuentaOrd, dMonto, dFechaValor, dFechaCaptu, cTrxOpera, cCuentaChq, current );
                    
                    IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                        COMMIT WORK;
                        LET iTransacc = 0;
                    END IF;
                ELSE
                    ROLLBACK WORK;
                    LET iTransacc = 0;
                END IF;
            END IF;
        END IF;
        
        LET cCveRastreo = '';
        LET cCuentaOrd  = '';
        LET dMonto      = 0.00;
        LET cCuentaChq  = '';
        LET iExisteTrx  = 0;
        LET dFechaValor = '';
        LET dFechaCaptu = '';
        LET cTrxOpera   = '';
    END FOREACH;
    
    END;

    RETURN cCodRet1;

END PROCEDURE;