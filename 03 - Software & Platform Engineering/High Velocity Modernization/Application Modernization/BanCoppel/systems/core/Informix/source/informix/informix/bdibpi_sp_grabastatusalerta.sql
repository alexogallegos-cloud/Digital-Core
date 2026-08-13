CREATE PROCEDURE "informix".sp_grabastatusalerta(pSolicitud CHAR(10), pStatus CHAR(1), pComentarios CHAR(200))
	RETURNING 	CHAR(5); --cod retorno				

--*********************************************
--Definición:	Se crea para grabar el status de las alertas asi como los comentarios.
--Autor: 		Walber Castro
--Fecha:		07 Febrero 2012
--*********************************************
--pStatus: 1-Atendida, 2-Solo comentarios, 3-Cancelada

DEFINE cCodRet			CHAR(5);
DEFINE iSql_Err    		INTEGER;
DEFINE cComentarios		CHAR(200);

LET cCodRet 	=	'00000' ;
LET cComentarios=	'';
LET iSql_Err	= 0;

--SET debug FILE TO "/home/informix/ivonne/sp_consultaalertas.out";
--Trace ON;

BEGIN
	ON EXCEPTION SET iSql_Err
		LET cCodRet = iSql_Err;	
		RETURN cCodRet;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pSolicitud,'')) == '' OR TRIM(NVL(pStatus,'')) == '' THEN
		LET cCodRet = '00001';
	ELSE
	
		LET cComentarios = TRIM(NVL(pComentarios,''));
	
		IF TRIM(NVL(pStatus,'')) == '1' THEN	--Se atiende
		
			UPDATE bdibpi:"informix".tkn_reporte SET id_status = 2, comentarios = cComentarios, fecstatus=TODAY WHERE solicitud = pSolicitud;
			
		ELIF TRIM(NVL(pStatus,'')) == '2' THEN --Se graban comentarios
			
			UPDATE bdibpi:"informix".tkn_reporte SET comentarios = cComentarios WHERE solicitud = pSolicitud;
		
		ELIF TRIM(NVL(pStatus,'')) == '3' THEN --Se cancelada
		
			UPDATE bdibpi:"informix".tkn_reporte SET id_status = 4, fecstatus=TODAY WHERE solicitud = pSolicitud;
			
		END IF;
		
	END IF;
		
	RETURN cCodRet;	
END;
END PROCEDURE;