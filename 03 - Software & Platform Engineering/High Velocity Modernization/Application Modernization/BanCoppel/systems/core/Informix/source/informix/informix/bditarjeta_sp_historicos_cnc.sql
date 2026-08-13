CREATE PROCEDURE "informix".sp_historicos_cnc(cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret,
		  VARCHAR(6) as Cod_ret1,VARCHAR(80) as Men_ret1,
		  VARCHAR(6) as Cod_ret2,VARCHAR(80) as Men_ret2,
		  VARCHAR(6) as Cod_ret3,VARCHAR(80) as Men_ret3,
		  VARCHAR(6) as Cod_ret4,VARCHAR(80) as Men_ret4;

	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  iValor           CHAR (1);
	DEFINE  dFechaFin        DATE;	


	DEFINE  P_COD_RET1        VARCHAR(6);
	DEFINE  P_MENSAJE1        VARCHAR(80);
	DEFINE  P_COD_RET2        VARCHAR(6);
	DEFINE  P_MENSAJE2        VARCHAR(80);
	DEFINE  P_COD_RET3        VARCHAR(6);
	DEFINE  P_MENSAJE3        VARCHAR(80);
	DEFINE  P_COD_RET4        VARCHAR(6);
	DEFINE  P_MENSAJE4        VARCHAR(80);	
	
	--SET DEBUG FILE TO "/informix/HomeInformix/rrm/fullhis.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET    = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;
		LET P_COD_RET1    = SQL_ERR;
		LET P_MENSAJE1  = ERROR_INFO;
		LET P_COD_RET2    = SQL_ERR;
		LET P_MENSAJE2  = ERROR_INFO;
		LET P_COD_RET3    = SQL_ERR;
		LET P_MENSAJE3  = ERROR_INFO;
		LET P_COD_RET4    = SQL_ERR;
		LET P_MENSAJE4  = ERROR_INFO;
	  
      RETURN 	P_COD_RET,P_MENSAJE,
			P_COD_RET1, P_MENSAJE1,
			P_COD_RET2, P_MENSAJE2,
			P_COD_RET3, P_MENSAJE3,
			P_COD_RET4, P_MENSAJE4;	  
   END EXCEPTION;

--************************************************************
-- Creado por Ricardo Reséndiz Martinez 
-- fecha : Nov/2012
-- Funcion: Concentrador de SP's de transferencia a historicos  
--************************************************************

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   LET iValor = '';
   
   LET P_COD_RET1 = '';
   LET P_MENSAJE1 = '';
   LET P_COD_RET2 = '';
   LET P_MENSAJE2 = '';
   LET P_COD_RET3 = '';
   LET P_MENSAJE3 = '';
   LET P_COD_RET4 = '';
   LET P_MENSAJE4 = '';

   
   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT valor  INTO iValor FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '001';
	
		
	IF (iValor == 'V' ) THEN
	   LET P_COD_RET = '00001';
	   LET P_MENSAJE = 'LA CONCILIACION SE ENCUENTRA EN EJECUCION, EL PROCESO NO PUEDE SER REALIZADO';	
	ELSE
		IF P_COD_RET = '00000' THEN
				
				EXECUTE PROCEDURE bditarjeta:"informix".sp_tras_bitacorahis_con(cNumEmpl) INTO P_COD_RET1, P_MENSAJE1;
			
				EXECUTE PROCEDURE bditarjeta:"informix".sp_tras_movhis_con(cNumEmpl) INTO P_COD_RET2, P_MENSAJE2;
			
				EXECUTE PROCEDURE intercard:"informix".sp_tras_conadminhis_con(cNumEmpl) INTO P_COD_RET3, P_MENSAJE3;
		
				EXECUTE PROCEDURE bditarjeta:"informix".sp_tras_archivoshis_con(cNumEmpl) INTO P_COD_RET4, P_MENSAJE4;

		END IF;
	END IF;
     
	RETURN 	P_COD_RET,P_MENSAJE,
			P_COD_RET1, P_MENSAJE1,
			P_COD_RET2, P_MENSAJE2,
			P_COD_RET3, P_MENSAJE3,
			P_COD_RET4, P_MENSAJE4;
  
END;
END PROCEDURE;