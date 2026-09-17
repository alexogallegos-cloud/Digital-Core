CREATE PROCEDURE "informix".sp_cancelatarjeta_chequera()
							
				returning CHAR(5)  AS Cod_Retorno;
										
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE cNumtarj		CHAR(20);	
DEFINE cNumcte		CHAR(20);			

--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	   = "00000";
LET iSql_err 			= 0 ;	
LET cNumtarj			='';
LET cNumcte				='';


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/informix/VH/chequeras/sp_cancelatarjeta_chequeras.out";
	--TRACE ON;

	FOREACH
		 SELECT num_tarjeta,numcte INTO cNumtarj,cNumcte FROM sc_tarjeta
		 WHERE empresa = '001'
		 AND cuenta IN (SELECT cuenta FROM sc_maechq WHERE empresa='001' AND producto='1900'AND status_cta=2)
		 AND status_tar='A'

		 UPDATE intercard:tarjeta SET codstatustarjeta='CAN',fechaultmodif=CURRENT,usuarioultmodif='informix'
		 WHERE numcliente=cNumcte AND numtarjeta=cNumtarj AND codstatustarjeta='ACT';

		 INSERT INTO intercard:bitacoracancelaciontarjetas (tarjeta,codigoproductotarjeta,fecha,resultado,descripcion,usuario)
		 VALUES (cNumtarj,'501',CURRENT,0,'CANCELACION DE TARJETA','CIERRECH');

		 UPDATE sc_tarjeta SET status_tar='C' WHERE empresa = '001' AND num_tarjeta = cNumtarj and status_tar='A';

	END FOREACH;	
	
	RETURN cCodRet;

END

END PROCEDURE
;