CREATE PROCEDURE "informix".sp_consultaalertas(pRegistros SMALLINT)
	RETURNING 	CHAR(5), --cod retorno
				CHAR(10),--solicitud
				CHAR(9), --cte
				CHAR(200), --nombre
				CHAR(200),--comentario
				DATE; --fecha

--*********************************************
--Definición:	Se crea para consultar las alertas.
--Autor: 		Walber Castro
--Fecha:		07 Febrero 2012
--------------------------------------------------------
--Definición:	Se modifica para que retorne todas las alertas en lotes de maximo 20 alertas.
--Autor: 		Manuel Ramos Figueroa
--Fecha:		12 Junio 2015
--*********************************************

DEFINE cCodret			CHAR(5);
DEFINE iSql_Err    		INTEGER;

DEFINE v_solicitud		CHAR(500);
DEFINE v_numcte 		CHAR(9);
DEFINE v_nombre 		CHAR(200);
DEFINE v_comentario		CHAR(200);
DEFINE v_fecha	 		DATE;

LET cCodret 	=	'00000' ;
LET v_solicitud	=	'';
LET v_numcte	=	'';
LET v_nombre	=	'';
LET v_comentario =	'';
LET v_fecha		=	'01-01-1900';

--SET debug FILE TO '/home/sysifx/Ramos/trace/sp_consultaalertas.out';
--Trace ON;

BEGIN
	ON EXCEPTION SET iSql_Err
		LET cCodRet = iSql_Err;	
		RETURN cCodRet,'','','','','01-01-1900';
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	FOREACH        
		SELECT SKIP pRegistros FIRST 20 solicitud, numcte, TRIM(NVL(nombre,'')), TRIM(NVL(comentarios,'')) ,fec_alerta 
		INTO v_solicitud, v_numcte, v_nombre, v_comentario, v_fecha
		FROM bdibpi:"informix".tkn_reporte
		WHERE id_status in ('1','3')
		ORDER BY fec_alerta ASC
		
		RETURN cCodRet, v_solicitud, v_numcte, v_nombre, v_comentario, v_fecha WITH RESUME;
	END FOREACH;	
END;
END PROCEDURE;