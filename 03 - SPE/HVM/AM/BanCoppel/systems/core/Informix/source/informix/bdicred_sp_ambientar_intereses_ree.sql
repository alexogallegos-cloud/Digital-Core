CREATE PROCEDURE "informix".sp_ambientar_intereses_ree() 

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE cEmpresa         CHAR(3);
DEFINE pEmpresa         CHAR(3);
DEFINE cProceso         CHAR(4);
DEFINE cCod_ret         CHAR(6);
DEFINE cCod_retBit      CHAR(6);
DEFINE cMensajeRet      CHAR(125); 
DEFINE vnum_credito      CHAR(12);
DEFINE vcredito_externo  CHAR(12);
DEFINE int_ven_tdc      DECIMAL(16,2);
DEFINE max_fecha_mov    DATE;
DEFINE int_cap2mes_tdc  DECIMAL(16,2);
DEFINE contador_commit  INTEGER;
DEFINE total_indicador  DECIMAL(16,2);

--SET DEBUG FILE TO "/ifxsif01/macf/sp_ambientar_intereses_ree.out";
--TRACE ON;

--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET cEmpresa        = "";
LET pEmpresa        = "";
LET cProceso        = '0024';
LET cCod_Ret        = '000000';
LET cCod_retBit     = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET vnum_credito     = "";
LET vcredito_externo = "";
LET int_ven_tdc     = 0;
LET max_fecha_mov   = DATE(0);
LET int_cap2mes_tdc = 0;
LET contador_commit = 0;
LET total_indicador = 0;


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;        
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

    LET pEmpresa = '001';
	
	
     SELECT a.num_credito, a.credito_externo            
            from bdicred:sd_maecredcrd a inner join bdicred:sd_indicador_cred_crd b
            on a.num_credito = b.num_credito
            where a.status_cred IN ('AA','BA','BT','VP','E1','E2','E3')
            and (b.intereses_ree is null or b.intereses_ree = 0)
		    AND a.num_producto='6011'	 
			into temp univ_ree with no log ;
			
    FOREACH WITH HOLD
		select *
		INTO vnum_credito, vcredito_externo
		FROM univ_ree

            SELECT nvl(sum(monto),0) intereses_vencidos_baja_cred
                INTO int_ven_tdc
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa 
				    AND num_credito = vcredito_externo
                    AND codigo_fun = '338' 
                    AND codigo_ref IN (21)
                    AND reversado = 'N';
 					
            SELECT max(fecha_mov) - 1 UNITS MONTH 
                INTO max_fecha_mov
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa  
				    AND num_credito =  vcredito_externo
                    AND codigo_fun = '605'
                    AND codigo_ref = 2
					AND reversado = 'N';  

            SELECT nvl(sum(monto),0) interes_capitalizado_2_meses_credito 
                INTO int_cap2mes_tdc
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa
				    AND num_credito =  vcredito_externo
                    AND codigo_fun = '605'
                    AND codigo_ref = 2
                    AND fecha_mov >= max_fecha_mov
					AND reversado = 'N';

            LET total_indicador = int_ven_tdc + int_cap2mes_tdc;

            BEGIN WORK;

                UPDATE bdicred:sd_indicador_cred_crd SET intereses_ree = total_indicador WHERE num_credito = vnum_credito;		
				LET contador_commit = contador_commit  + 1;
			
            COMMIT WORK;    
			
			LET total_indicador =0;
			LET int_ven_tdc = 0;
			LET max_fecha_mov = date(1);
			LET int_cap2mes_tdc = 0;
			

    END FOREACH;


    LET cCod_Ret = '000000';
    LET cMensajeRet = 'PROCESO CONCLUIDO, REGISTROS ACTUALIZADOS '||contador_commit;
    
    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;