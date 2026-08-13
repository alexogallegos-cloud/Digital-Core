CREATE PROCEDURE "informix".sp_obtmovsprestcoppel()
RETURNING CHAR(5);
      
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vFechaHoy    DATE;
    DEFINE vFechaDes    CHAR(8);
    DEFINE vsql         CHAR(600);
    DEFINE vstmt        CHAR(200);
	DEFINE vmonto       MONEY(14,2);
	DEFINE vmonto_com   MONEY(14,2);
	DEFINE vmonto_iva   MONEY(14,2);
	DEFINE vcuantos     INTEGER;
	DEFINE vchar4       CHAR(4);
	DEFINE vdate        DATE;
	DEFINE vmoney       MONEY(14,2);
	DEFINE vcodret      char(5);
	DEFINE vIvaBase     DECIMAL(5,3);
    DEFINE vReferencia  CHAR(40);
	DEFINE vmonto_tot   MONEY(14,2);
	    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
    LET vCodRet2    = '';
    LET vCodRet3    = '';
    LET vFechaHoy   = '';
    LET vFechaDes   = '';
    LET vsql        = '';
    LET vstmt       = '';
	LET vmonto      = 0;
	LET vmonto_com  = 0;
	LET vmonto_iva  = 0;
    LET vReferencia = 'PRESTAMOS COPPEL';
	LET vmonto_tot  = 0;
    
    BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtmovsprestcoppel.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtmovsprestcoppel.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
    -- // OBTINENE FECHAS DEL SISTEMA
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM sc_fechas
     WHERE empresa = '001';
	 
    SELECT valor 
	  INTO vIvaBase
      FROM bdinteg:si_param
     WHERE empresa = '001'
       AND cod_param = 47;

    IF vIvaBase IS NULL THEN
       LET vIvaBase = 0;
    END IF
 	 
	SELECT sum(monto_tot), count(*)
	  INTO vmonto, vcuantos
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc in('0283', '0410', '0411', '0412', '0413', '0414')
	   AND cancelad <> 'S';
	   
	LET vmonto_com = vcuantos * 1.00;
	LET vmonto_iva = vmonto_com * vIvaBase;
    LET vmonto_tot = vmonto + vmonto_com + vmonto_iva;

	IF vmonto > 0 THEN
        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0270', '0000', '92536921230000', '16000000012', 0, vmonto_tot, '01', vReferencia, ' ', ' ')
        INTO vcodret, vchar4, vdate, vmoney, vmoney;
       
        IF vcodret = '000' THEN
            EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0263', '0000', '92536921230000', '16000000098', 0, vmonto_tot, vmonto_tot, 0, 0, 0, '01', vReferencia, ' ', ' ')
            INTO vcodret;
            
            IF vcodret = '000' THEN
                EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0305', '0000', '92536921230000', '16000000098', 0, vmonto, '01', vReferencia, ' ', ' ')
                INTO vcodret, vchar4, vdate, vmoney, vmoney;
                
                IF vcodret = '000' AND vmonto_com > 0 THEN
                    EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0306', '0000', '92536921230000', '16000000098', 0, vmonto_com, '01', vReferencia, ' ', ' ')
                    INTO vcodret, vchar4, vdate, vmoney, vmoney;
                    
                    IF vcodret = '000' AND vmonto_iva > 0  THEN
                        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0307', '0000', '92536921230000', '16000000098', 0, vmonto_iva, '01', vReferencia, ' ', ' ')
                        INTO vcodret, vchar4, vdate, vmoney, vmoney;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
	
	LET vFechaDes = TO_CHAR(vFechaHoy, '%d%m%Y'); 
     
    -- // DESCARGA DE ARCHIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               ' UNLOAD TO /resplogifx/conciliachq/prestamos_coppel_'||vFechaDes||'.txt '||
               ' SELECT sucursal, fech_alt, cuenta, monto_tot, transacc '||
               ' FROM sc_movdia '||
               ' WHERE fech_alt = '''||vFechaHoy||''' '||
               ' AND transacc in (''0283'', ''0410'', ''0411'', ''0412'', ''0413'', ''0414'') '||
               ' AND cancelad <> ''S'';" > /resplogifx/conciliachq/prestcopp.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/prestcopp.sql';
    SYSTEM vstmt;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;