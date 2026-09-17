CREATE PROCEDURE "informix".sp_obtmovscorresponsales_esp(vFechaHoy DATE)
RETURNING CHAR(5);
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vFechaDes        CHAR(8);
    DEFINE vsql             CHAR(600);
    DEFINE vstmt            CHAR(200);
    DEFINE vmonto           MONEY(14,2);
    DEFINE vmonto_com       MONEY(14,2);
    DEFINE vmonto_iva       MONEY(14,2);
    DEFINE vcuantos         INTEGER;
    DEFINE vmonto_cr        MONEY(14,2);
    DEFINE vmonto_com_cr    MONEY(14,2);
    DEFINE vmonto_iva_cr    MONEY(14,2);
    DEFINE vcuantos_cr      INTEGER;
    DEFINE vchar4           CHAR(4);
    DEFINE vdate            DATE;
    DEFINE vmoney           MONEY(14,2);
    DEFINE vcodret          char(5);
    DEFINE vIvaBase         DECIMAL(5,3);
    DEFINE vReferencia      CHAR(40);
    DEFINE vmonto_tot       MONEY(14,2);
    DEFINE vmonto_tot_cr    MONEY(14,2);
    DEFINE vmonto_total     MONEY(14,2);
    DEFINE vmonto_total_com MONEY(14,2);
    DEFINE vmonto_total_iva MONEY(14,2);
        
    LET Sql_Err	         = 0;
    LET Isam_Err         = 0;
    LET Desc_Err         = '';
    LET vCodRet1         = '000';
    LET vCodRet2         = '';
    LET vCodRet3         = '';
    LET vFechaDes        = '';
    LET vsql             = '';
    LET vstmt            = '';
    LET vmonto           = 0;
    LET vmonto_com       = 0;
    LET vmonto_iva       = 0;
    LET vReferencia      = 'CORRESPONSALES COPPEL';
    LET vmonto_tot       = 0;
    LET vmonto_cr        = 0;
    LET vmonto_com_cr    = 0;
    LET vmonto_iva_cr    = 0;
    LET vmonto_total     = 0;
    LET vmonto_totaL_com = 0;
    LET vmonto_total_iva = 0;
        
    BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtmovscorresponsales.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtmovscorresponsales.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
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
	  FROM sc_movhis
	 WHERE fech_alt = vFechaHoy
	   AND transacc = '0282'
	   AND cancelad <> 'S';
	   
	LET vmonto_com = vcuantos * 1.00;
	LET vmonto_iva = vmonto_com * vIvaBase;
    LET vmonto_tot = vmonto + vmonto_com + vmonto_iva;
	
	SELECT sum(monto), count(*)
	  INTO vmonto_cr, vcuantos_cr
	  FROM bdicred:sd_movhis
	 WHERE fecha_mov = vFechaHoy
	   AND transacc_suc = '6282'
       AND codigo_ref = 1
       AND codigo_fun = '700'
	   AND reversado = 'N';
	
	LET vmonto_com_cr = vcuantos_cr * 1.00;
	LET vmonto_iva_cr = vmonto_com_cr * vIvaBase;
    LET vmonto_tot_cr = vmonto_cr + vmonto_com_cr + vmonto_iva_cr;
	
	LET vmonto_total = vmonto + vmonto_cr;
	LET vmonto_total_com = vmonto_com + vmonto_com_cr;
	LET vmonto_total_iva = vmonto_iva + vmonto_iva_cr;
    
	IF vmonto_total > 0 THEN
        EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0270', '0000', '92536921230100', '16000000012', 0, vmonto_total, '01', vReferencia, ' ', ' ') 
        INTO vcodret, vchar4, vdate, vmoney, vmoney;
       
        IF vcodret = '000' THEN
            EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0263', '0000', '92536921230100', '16000000071', 0, vmonto_total, vmonto_total, 0, 0, 0, '01', vReferencia, ' ', ' ') 
            INTO vcodret;
            
            IF vcodret = '000' AND vmonto_com > 0 THEN
			    EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0264', '0000', '92536921230100', '16000000071', 0, vmonto_com, vmonto_com, 0, 0, 0, '01', vReferencia, ' ', ' ') 
                INTO vcodret;
                                
                IF vcodret = '000' AND vmonto_iva > 0 THEN
				    EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0266', '0000', '92536921230100', '16000000071', 0, vmonto_iva, vmonto_iva, 0, 0, 0, '01', vReferencia, ' ', ' ') 
                    INTO vcodret;
				END IF;
                
                IF vcodret = '000' AND vmonto > 0 THEN
                    EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0259', '0000', '92536921230100', '16000000071', 0, vmonto, '01', vReferencia, ' ', ' ') 
                    INTO vcodret, vchar4, vdate, vmoney, vmoney;
                END IF;
            END IF;
            
            IF vcodret = '000' AND vmonto_com_cr > 0 THEN
			    EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0264', '0000', '92536921230100', '16000000071', 0, vmonto_com_cr, vmonto_com_cr, 0, 0, 0, '01', vReferencia, ' ', ' ') 
                INTO vcodret;
                                
                IF vcodret = '000' AND vmonto_iva_cr > 0 THEN
				    EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0266', '0000', '92536921230100', '16000000071', 0, vmonto_iva_cr, vmonto_iva_cr, 0, 0, 0, '01', vReferencia, ' ', ' ') 
                    INTO vcodret;
				END IF;
                
                IF vcodret = '000' AND vmonto_cr > 0 THEN
                    EXECUTE PROCEDURE cargo_ref('001', '9250', '92536921', '0249', '0000', '92536921230100', '16000000071', 0, vmonto_cr, '01', vReferencia, ' ', ' ') 
                    INTO vcodret, vchar4, vdate, vmoney, vmoney;
                END IF; 
            END IF;
        END IF;
    END IF;
	
	LET vFechaDes = TO_CHAR(vFechaHoy, '%d%m%Y'); 
    
    -- // DESCARGA DE ARCHIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               ' UNLOAD TO /resplogifx/conciliachq/corresponsales_coppel_'||vFechaDes||'.txt '||
               ' SELECT sucursal, fech_alt, cuenta, monto_tot, transacc '||
               ' FROM sc_movhis '||
               ' WHERE fech_alt = '''||vFechaHoy||''' '||
               ' AND transacc = ''0282'' '||
               ' AND cancelad <> ''S'' '||
			   ' UNION ALL ' ||
			   ' SELECT sucursal, fecha_mov, num_credito, monto, transacc_suc '||
			   ' FROM bdicred:sd_movhis '||
			   ' WHERE fecha_mov = '''||vFechaHoy||''' '||
			   ' AND transacc_suc = ''6282'' '||
               ' AND codigo_ref = 1 '||
               ' AND codigo_fun = ''700'' '||
			   ' AND reversado = ''N'';" > /resplogifx/conciliachq/correspcopp.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/correspcopp.sql';
    SYSTEM vstmt;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;