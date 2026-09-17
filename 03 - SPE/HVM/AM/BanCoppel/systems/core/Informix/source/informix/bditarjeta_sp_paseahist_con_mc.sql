CREATE PROCEDURE "informix".sp_paseahist_con_mc(psCve_Usuario VARCHAR(10))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret,
		  VARCHAR(6) as Cod_ret1,VARCHAR(80) as Men_ret1,
		  VARCHAR(6) as Cod_ret2,VARCHAR(80) as Men_ret2;

	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(90);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(100);
	DEFINE  iValor           CHAR (1);
	DEFINE  dFechaFin        DATE;	


	DEFINE  P_COD_RET1        VARCHAR(6);
	DEFINE  P_MENSAJE1        VARCHAR(90);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE2        VARCHAR(90);
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/case/ss_conciliacionautomatica_mc/bit_mc_to_hist2.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET    = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;
		LET P_COD_RET1    = SQL_ERR;
		LET P_MENSAJE1  = ERROR_INFO;
		LET P_COD_RET2    = SQL_ERR;
		LET P_MENSAJE2  = ERROR_INFO;
	  
      RETURN 	P_COD_RET,P_MENSAJE,
			P_COD_RET1, P_MENSAJE1,
			P_COD_RET2, P_MENSAJE2;
   END EXCEPTION;

--************************************************************
-- Creado por Softtek case3 
-- fecha : Marzo/2024
-- Funcion: Concentrador de SP's de transferencia a historicos conciliaciÃ³n MasterCard 
--************************************************************

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   LET iValor = '';
   
   LET P_COD_RET1 = '';
   LET P_MENSAJE1 = '';
   LET P_COD_RET2 = '';
   LET P_MENSAJE2 = '';

   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
    SELECT VALOR INTO iValor FROM BdiTarjeta:"informix".td_param_conciliacion_mc WHERE Codigo = '001';	
		
	IF (iValor == 'V' ) THEN
	   LET P_COD_RET = '00001';
	   LET P_MENSAJE = 'LA CONCILIACION MASTERCARD SE ENCUENTRA EN EJECUCION,PROCESO NO EJECUTADO';	
	ELSE
		IF P_COD_RET = '00000' THEN
				EXECUTE PROCEDURE bditarjeta:"informix".sp_paseahist_bitacora_con_mc(psCve_Usuario) INTO P_COD_RET1, P_MENSAJE1;

				EXECUTE PROCEDURE bditarjeta:"informix".sp_paseahist_movimientos_con_mc(psCve_Usuario) INTO P_COD_RET2, P_MENSAJE2;				
		END IF;
	END IF;
     
	RETURN 	P_COD_RET,P_MENSAJE,
			P_COD_RET1, P_MENSAJE1,
			P_COD_RET2, P_MENSAJE2;
  
END;
END PROCEDURE;