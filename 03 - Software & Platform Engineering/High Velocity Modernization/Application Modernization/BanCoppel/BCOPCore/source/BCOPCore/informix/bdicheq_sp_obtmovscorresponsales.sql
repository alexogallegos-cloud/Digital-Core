CREATE PROCEDURE "informix".sp_obtmovscorresponsales()
RETURNING CHAR(5);
    
    DEFINE Sql_Err          	INTEGER;
    DEFINE Isam_Err         	INTEGER;
    DEFINE Desc_Err         	CHAR(50);
    DEFINE vCodRet1         	CHAR(5);
    DEFINE vCodRet2         	CHAR(5);
    DEFINE vCodRet3         	CHAR(50);
    DEFINE vFechaHoy        	DATE;
    DEFINE vFechaDes        	CHAR(8);
    DEFINE vsql             	CHAR(1000);
    DEFINE vstmt            	CHAR(200);
    DEFINE vmonto           	MONEY(14,2);
    DEFINE vmonto_com       	MONEY(14,2);
    DEFINE vmonto_iva       	MONEY(14,2);
    DEFINE vcuantos         	INTEGER;
    DEFINE vmonto_cr        	MONEY(14,2);
    DEFINE vmonto_com_cr    	MONEY(14,2);
    DEFINE vmonto_iva_cr    	MONEY(14,2);
    DEFINE vcuantos_cr      	INTEGER;
    DEFINE vchar4           	CHAR(4);
    DEFINE vdate            	DATE;
    DEFINE vmoney           	MONEY(14,2);
    DEFINE vcodret          	char(5);
    DEFINE vIvaBase         	DECIMAL(5,3);
    DEFINE vReferencia      	CHAR(40);
    DEFINE vmonto_tot       	MONEY(14,2);
    DEFINE vmonto_tot_cr    	MONEY(14,2);
    DEFINE vmonto_total     	MONEY(14,2);
    DEFINE vmonto_total_com 	MONEY(14,2);
    DEFINE vmonto_total_iva 	MONEY(14,2);
	DEFINE vmonto_tot_0402  	MONEY(14,2);
	DEFINE vmonto_tot_disp_cr  	MONEY(14,2);
    DEFINE vcuantos_0402      	INTEGER;
    DEFINE vcuantos_disp_cr    	INTEGER;
	DEFINE vcuantos_1197		INTEGER;
	DEFINE vmonto_tot_1197  	MONEY(14,2);	
	DEFINE vmonto_tot_0401  	MONEY(14,2);
	DEFINE vcuantos_0401		INTEGER;
	DEFINE vmonto_tot_0403  	MONEY(14,2);
	DEFINE vcuantos_0403		INTEGER;
    --- DEFINE vmonto_tot_0404  	MONEY(14,2);
	--- DEFINE vcuantos_0404		INTEGER;
	--- DEFINE vmonto_tot_0405  	MONEY(14,2);
	--- DEFINE vcuantos_0405		INTEGER;
	DEFINE vmonto_tot_0406  	MONEY(14,2);
	DEFINE vcuantos_0406		INTEGER;
	DEFINE vmonto_tot_8106  	MONEY(14,2);
	DEFINE vcuantos_8106		INTEGER;
	DEFINE vmonto_tot_1196  	MONEY(14,2);
	DEFINE vcuantos_1196		INTEGER;
    DEFINE vComCorrespCoppel    DECIMAL(14,2);
	
    LET Sql_Err	         		= 0;
    LET Isam_Err         		= 0;
    LET Desc_Err         		= '';
    LET vCodRet1         		= '000';
    LET vCodRet2         		= '';
    LET vCodRet3         		= '';
    LET vFechaHoy        		= '';
    LET vFechaDes        		= '';
    LET vsql             		= '';
    LET vstmt            		= '';
    LET vmonto           		= 0;
    LET vmonto_com       		= 0;
    LET vmonto_iva       		= 0;
    LET vReferencia      		= 'CORRESPONSALES COPPEL';
    LET vmonto_tot       		= 0;
    LET vmonto_cr        		= 0;
    LET vmonto_com_cr    		= 0;
    LET vmonto_iva_cr    		= 0;
    LET vmonto_total     		= 0;
    LET vmonto_totaL_com 		= 0;
    LET vmonto_total_iva 		= 0;
	LET vmonto_tot_0402  		= 0;
	LET vmonto_tot_disp_cr		= 0;
	LET vmonto_tot_1197			= 0;
	LET vmonto_tot_0401         = 0;
	LET vmonto_tot_0403         = 0;
	--- LET vmonto_tot_0404         = 0;
	--- LET vmonto_tot_0405         = 0;
	LET vmonto_tot_0406         = 0;
	LET vmonto_tot_8106         = 0;
	LET vmonto_tot_1196         = 0;
    LET vComCorrespCoppel       = 0.00;
        
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
    
    SELECT valor
      INTO vComCorrespCoppel
      FROM sc_param
     WHERE codparam = 'MtoComCorrespCoppel';
 	
	SELECT nvl(sum(monto_tot), 0), count(*)
	  INTO vmonto, vcuantos
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc in('0282')
	   AND cancelad <> 'S';
	   
	SELECT nvl(sum(monto), 0), count(*)
	  INTO vmonto_cr, vcuantos_cr
	  FROM bdicred:sd_movdia
	 WHERE fecha_mov = vFechaHoy
	   AND transacc_suc = '6282'
       AND codigo_ref = 1
       AND codigo_fun = '700'
	   AND reversado = 'N';
	
	SELECT nvl(sum(monto_tot), 0), count(*)
	  INTO vmonto_tot_0402, vcuantos_0402
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc = '0402'
	   AND cancelad <> 'S';
	   
	SELECT nvl(sum(monto_tot), 0), count(*)
	  INTO vmonto_tot_1197, vcuantos_1197
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc in('1197')
	   AND cancelad <> 'S';
	   
	SELECT nvl(sum(monto), 0), count(*)
	  INTO vmonto_tot_disp_cr, vcuantos_disp_cr
	  FROM bdicred:sd_movdia
	 WHERE fecha_mov = vFechaHoy
	   AND ((transacc_suc = '8105' AND codigo_ref = 109 AND codigo_fun = '002' AND reversado = 'N') 
	    OR  (transacc_suc = '8112' AND codigo_ref = 110 AND codigo_fun = '002' AND reversado = 'N'));
			
	SELECT nvl(sum(monto_tot), 0), count(*)
	  INTO vmonto_tot_0401, vcuantos_0401
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc in('0401')
	   AND cancelad <> 'S';
	   
	SELECT nvl(sum(monto_tot), 0), count(*)
	  INTO vmonto_tot_0403, vcuantos_0403
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc in('0403')
	   AND cancelad <> 'S';
	    
    /* #########################################
	SELECT nvl(sum(monto_tot), 0), count(*)
	  INTO vmonto_tot_0404, vcuantos_0404
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc in('0404')
	   AND cancelad <> 'S';
    ######################################### */
	
    /* #########################################
	SELECT nvl(sum(monto_tot), 0), count(*)
	  INTO vmonto_tot_0405, vcuantos_0405
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc in('0405')
	   AND cancelad <> 'S';
    ######################################### */
	   
	SELECT nvl(sum(monto_tot), 0), count(*)
	  INTO vmonto_tot_0406, vcuantos_0406
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc in('0406')
	   AND cancelad <> 'S';
	   
	SELECT nvl(sum(monto), 0), count(*)
	  INTO vmonto_tot_8106, vcuantos_8106
	  FROM bdicred:sd_movdia
	 WHERE fecha_mov = vFechaHoy
	   AND (transacc_suc = '8106' AND codigo_ref = 0 AND codigo_fun = '000' AND reversado = 'N'); 
	   
	SELECT nvl(sum(monto_tot), 0), count(*)
	  INTO vmonto_tot_1196, vcuantos_1196
	  FROM sc_movdia
	 WHERE fech_alt = vFechaHoy
	   AND transacc in('1196')
	   AND cancelad <> 'S';
	   
	--- LET vmonto_com = (vcuantos + vcuantos_0402 + vcuantos_0401 + vcuantos_0403 + vcuantos_0404 + vcuantos_0405 ) * 1.00;
    --- LET vmonto_com = (vcuantos + vcuantos_0402 + vcuantos_0401 + vcuantos_0403 + vcuantos_0404 + vcuantos_0405 ) * vComCorrespCoppel;
    --- LET vmonto_com = (vcuantos + vcuantos_0402 + vcuantos_0401 + vcuantos_0403 + vcuantos_0405 ) * vComCorrespCoppel;
    LET vmonto_com = (vcuantos + vcuantos_0402 + vcuantos_0401 + vcuantos_0403 ) * vComCorrespCoppel;
    
	LET vmonto_iva = vmonto_com * vIvaBase;
    --- LET vmonto_tot = vmonto + vmonto_com + vmonto_iva;

	--- LET vmonto_com_cr = (vcuantos_cr + vcuantos_1197 + vcuantos_disp_cr + vcuantos_0406 + vcuantos_8106 + vcuantos_1196 ) * 1.00;
    LET vmonto_com_cr = (vcuantos_cr + vcuantos_1197 + vcuantos_disp_cr + vcuantos_0406 + vcuantos_8106 + vcuantos_1196 ) * vComCorrespCoppel;
	LET vmonto_iva_cr = vmonto_com_cr * vIvaBase;
    --- LET vmonto_tot_cr = vmonto_cr + vmonto_com_cr + vmonto_iva_cr;
	
	LET vmonto_total = vmonto + vmonto_cr + vmonto_tot_1197;
	LET vmonto_total_com = vmonto_com + vmonto_com_cr;
	--- LET vmonto_total_iva = vmonto_iva + vmonto_iva_cr;	
	
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
	
    IF vmonto_tot_0402 > 0 THEN 
	   EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0258', '0000', '92536921230100', '16000000071', 0, vmonto_tot_0402, vmonto_tot_0402, 0, 0, 0, '01', vReferencia, ' ', ' ') 
       INTO vcodret;
	END IF;
	
	IF vmonto_tot_disp_cr > 0 THEN 
	   EXECUTE PROCEDURE abono_ref('001', '9250', '92536921', '0248', '0000', '92536921230100', '16000000071', 0, vmonto_tot_disp_cr, vmonto_tot_disp_cr, 0, 0, 0, '01', vReferencia, ' ', ' ') 
       INTO vcodret;
	END IF;
	
	LET vFechaDes = TO_CHAR(vFechaHoy, '%d%m%Y'); 
    
    -- // DESCARGA DE ARCHIVOS
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
               ' UNLOAD TO /resplogifx/conciliachq/corresponsales_coppel_'||vFechaDes||'.txt '||
               ' SELECT sucursal, fech_alt, cuenta, monto_tot, transacc '||
               ' FROM sc_movdia '||
               ' WHERE fech_alt = '''||vFechaHoy||''' '||
               ' AND transacc IN(''0282'',''0402'',''0403'',''0404'',''0405'',''0406'',''1196'',''1197'') '||
               ' AND cancelad <> ''S'' '||
			   ' UNION ALL ' ||
			   ' SELECT sucursal, fecha_mov, num_credito, monto, transacc_suc '||
			   ' FROM bdicred:sd_movdia '||
			   ' WHERE fecha_mov = '''||vFechaHoy||''' '||
			   ' AND (( transacc_suc = ''6282'' AND codigo_ref = 1 AND codigo_fun = ''700'' AND reversado = ''N'' ) '||
               ' OR  (transacc_suc = ''8104'' AND codigo_ref = 1 AND codigo_fun = ''068'' AND reversado = ''N'') '||
               ' OR  (transacc_suc = ''8112'' AND codigo_ref = 110 AND codigo_fun = ''002'' AND reversado = ''N'') '||			   
               ' OR  (transacc_suc = ''8105'' AND codigo_ref = 109 AND codigo_fun = ''002'' AND reversado = ''N'')); '||
			   '" > /resplogifx/conciliachq/correspcopp.sql';
    SYSTEM vsql;
    
    LET vstmt = '';
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/correspcopp.sql';
    SYSTEM vstmt;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;