CREATE PROCEDURE "informix".sp_cuentaalertas()
	RETURNING 	CHAR(5), --cod retorno
				CHAR(15),--vigentes
				CHAR(15);
--*********************************************
--Definición:	Se crea para contar las alertas vigentes y las vencidas.
--Autor: 		Walber Castro
--Fecha:		07 Febrero 2012
--*********************************************

DEFINE cCodRet			CHAR(5);
DEFINE iSql_Err    		INTEGER;
DEFINE cVigentes		CHAR(15);
DEFINE cVencidas		CHAR(15);

LET cCodRet 	=	'00000' ;
LET iSql_Err	= 0;
LET cVigentes	=	'0';
LET cVencidas	=	'0';

--SET debug FILE TO "/home/informix/ivonne/sp_consultaalertas.out";
--Trace ON;

BEGIN
	ON EXCEPTION SET iSql_Err
		LET cCodRet = iSql_Err;	
		RETURN cCodRet, '0', '0';
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	SELECT count(solicitud) INTO cVigentes FROM bdibpi:"informix".tkn_reporte WHERE id_status = 1;			
			
	SELECT count(solicitud) INTO cVencidas FROM bdibpi:"informix".tkn_reporte WHERE id_status = 3;
		
	RETURN cCodRet, cVigentes, cVencidas;	
END;
END PROCEDURE;