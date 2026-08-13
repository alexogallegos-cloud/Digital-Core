CREATE PROCEDURE "informix".sp_whatscoppel_consdos( pCteCoppel CHAR(9) ) --- NO CLIENTE COPPEL
RETURNING CHAR(5),       --- CODIGO DE RETORNO 
          CHAR(20),      --- NO CLIENTE COPPEL
          CHAR(4),       --- 4 ULTIMOS DIGITOS TARJETA
          DECIMAL(14,2); --- SALDO DISPONIBLE
       
    DEFINE Sql_Err     		INTEGER;
    DEFINE Isam_Err    		INTEGER;
    DEFINE Desc_Err    		CHAR(80);
    DEFINE vCodRet1    		CHAR(5);
    DEFINE vCodRet2    		CHAR(5);
    DEFINE vCodRet3    		CHAR(80);
    DEFINE vUltDigTrj  		CHAR(4);
    DEFINE vSdoDisp    		DECIMAL(14,2);
    DEFINE vNoCteBanco		CHAR(9);
	DEFINE vCountRegistros  SMALLINT;
    
    LET Sql_Err	    	= 0;
    LET Isam_Err    	= 0;
    LET Desc_Err    	= '';
    LET vCodRet1    	= '00000';
    LET vCodRet2    	= '';
    LET vCodRet3    	= '';
    LET vUltDigTrj  	= '';
    LET vSdoDisp    	= 0.00;
    LET vNoCteBanco 	= '';
	LET vCountRegistros = 0;
	
	BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_consdos.err";
        --TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, pCteCoppel, vUltDigTrj, vSdoDisp;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/informix/ids_10UC11/jivan/whatscoppel/sp_whatscoppel_consdos.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pCteCoppel is null OR pCteCoppel = '' THEN
        LET vCodRet1 = '00110';
        LET vUltDigTrj = '';
        LET vSdoDisp = '';
        RETURN vCodRet1, pCteCoppel, vUltDigTrj, vSdoDisp;
    END IF;
    
    SELECT numctebco
      INTO vNoCteBanco
      FROM bdinteg:si_enrol_cplbot
    WHERE numctecpl = pCteCoppel;
    
    IF vNoCteBanco is null OR vNoCteBanco = '' THEN 
        LET vCodRet1 = '00111';
        LET vUltDigTrj = '';
        LET vSdoDisp = '';
        RETURN vCodRet1, pCteCoppel, vUltDigTrj, vSdoDisp;
    END IF;
    --RQM 09 704 Se realiza la modifciacion del saldo actual agregando la resta del saldo sbc OACM
    FOREACH 
        SELECT SUBSTR(trj.num_tarjeta, -8, 4), mae.sdo_actual - ( mae.sdo_retenido + mae.sdo_cong + mae.imp_chq_sbg  + mae.saldo_sbc)
          INTO vUltDigTrj, vSdoDisp
          FROM bdicheq:sc_tarjeta trj,
               bdicheq:sc_maechq mae
         WHERE trj.cuenta = mae.cuenta
           AND trj.numcte = mae.num_cte
           AND trj.tipo_tarjeta = 'T'
           AND trj.status_tar = 'A'
           AND mae.status_cta IN('1','3','4','5')
           --- AND ( mae.sdo_actual - ( mae.sdo_retenido + mae.sdo_cong + mae.imp_chq_sbg ) ) > 0.00 se quito para que pudera entrar a mÃ¡s condiciones
           AND mae.num_cte = vNoCteBanco
				 
        IF(vSdoDisp <= 0.00) then
            LET vSdoDisp = '';
            LET vUltDigTrj = '';
            LET vCodRet1 = '00116';
        ELIF(vSdoDisp > 0.00) then
            LET vSdoDisp = vSdoDisp;
            LET vCodRet1 = '00000';
        END IF
        
        RETURN vCodRet1, pCteCoppel, vUltDigTrj, vSdoDisp WITH RESUME;
		
        -- // Si esta variable regresa cero es porque la consulta no regresa datos y no tiene tarjetas registradas         
        LET vCountRegistros = dbinfo("sqlca.sqlerrd2");
    END FOREACH;
    
    IF (vCountRegistros = 0 ) THEN
        LET vSdoDisp = '';
        LET vCodRet1 = '00115';
        RETURN vCodRet1, pCteCoppel, vUltDigTrj, vSdoDisp;			
    END IF;
    
    END; 
    
END PROCEDURE
DOCUMENT
'AUTOR: Osiel Alfredo Camacho Mendoza',
'FOLIO: RQM 09 704 Cobranza automatica en cuentas de captacion',
'VERSION: 1.1',
'MODIFICACION : Se agrega en la formula del saldo actual la resta del saldo sbc',
'FECHA: 05/06/2025',
'BD: bdicplbot';


grant  execute on function "informix".sp_whatscoppel_enrola (char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_whatscoppel_envotp (char,char) to "public" as "informix";
grant  execute on function "informix".sp_whatscoppel_genotp (char,char) to "public" as "informix";
grant  execute on function "informix".sp_whatscoppel_valotp (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_whatscoppel_realizacargo (char,char,char,char,date,char,char,decimal) to "public" as "informix";
grant  execute on function "informix".sp_whatscoppel_reversion (char,char) to "public" as "informix";
grant  execute on function "informix".sp_whatscoppel_conscorreocel (char) to "public" as "informix";
grant  execute on function "informix".sp_whatscoppel_consdos (char) to "public" as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to public ;

grant usage on language SPL to ifxcons ;

grant usage on language SPL to ifxdesaa ;

grant usage on language SPL to ifxprod ;

grant usage on language SPL to ifxconsacc ;

grant usage on language SPL to ifxsopsuc ;