CREATE PROCEDURE "informix".sp_ambientar_intereses_ree_pp() 

RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE pEmpresa         CHAR(3);

DEFINE cCod_ret         CHAR(6);
DEFINE cMensajeRet      CHAR(125); 
DEFINE vnum_credito      CHAR(12);
DEFINE vcredito_externo  CHAR(12);
DEFINE int_ven_bal      DECIMAL(16,2);

DEFINE contador_commit  INTEGER;
DEFINE total_indicador,vinteres_ree  DECIMAL(16,2);
DEFINE pfecha, pfecha_ini         DATE;

--SET DEBUG FILE TO "/RESPALDOSNEW/CUB_IFRS_Pruebas/IPCB/migracion_cony/sp_ambientar_indicador.out";
--TRACE ON;

--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";

LET cCod_Ret        = '000000';

LET cMensajeRet     = 'PROCESO EXITOSO';
LET vnum_credito     = "";
LET vcredito_externo = "";
LET int_ven_bal     = 0;


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
	
	select pri_dia_mes-1, pri_dia_mes - 1 units month INTO pfecha , pfecha_ini from bdicred:sd_fechas;

	
	/*
     SELECT a.num_credito, credito_externo            
            from bdicred:sd_maecredCONTcrd a inner join bdicred:sd_indicador_cred_crd b
            on a.num_credito = b.num_credito
            where  fecha = mdy('06','30','2021')
			and status_cred IN ('AA','BA','BT','VP','E1','E2','E3')
            and (intereses_ree is null or intereses_ree = 0)
			--where fecha = mdy('09','30','2019')
		    --AND num_producto='6011'
And			num_producto='8600'
			--and a.num_credito in ('860000000023','860000000031')        
			into temp univ_ree with no log ;
			*/
		     
	SELECT a.num_credito, credito_externo-- ,intereses_ree           
	from bdicred:sd_maecredCONTcrd a  inner join bdicred:sd_indicador_cred_crd b
    on b.empresa = a.empresa and a.num_credito = b.num_credito
    where a.fecha = pfecha
	and num_producto='8600'
  --  and fecha_apertura >= pri_dia_mes and fecha_apertura <= pfecha
	into temp univ_ree with no log ;
			
    FOREACH WITH HOLD
		select *
		INTO vnum_credito, vcredito_externo
		FROM univ_ree
		--where vinteres_ree is null
		
		
		  SELECT nvl(sum(monto),0) intereses_vencidos_baja_cred -- BAJA DE LOS INTERESES DE BALANZA VENCIDO
                INTO int_ven_bal
                FROM bdicred:sd_movhiscrd
                WHERE empresa = '001' 
                    AND codigo_fun = '124' 
                    AND codigo_ref IN (5,25,962)
                    AND reversado = 'N'
                    AND num_credito = vcredito_externo; 
					
            LET total_indicador = int_ven_bal;

            BEGIN WORK;

                UPDATE bdicred:sd_indicador_cred_crd SET intereses_ree = total_indicador WHERE num_credito = vnum_credito;		
				LET contador_commit = contador_commit  + 1;
			
            COMMIT WORK;    
			
			LET total_indicador =0;
			LET int_ven_bal = 0;
			LET vinteres_ree = 0;
		
    END FOREACH;


    LET cCod_Ret = '000000';
    LET cMensajeRet = 'PROCESO CONCLUIDO, REGISTROS ACTUALIZADOS '||contador_commit;
    
    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;