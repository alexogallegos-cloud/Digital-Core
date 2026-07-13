CREATE PROCEDURE "informix".sp_respaldo_ss_autorizacion(pNum_solicitud CHAR(20))
		RETURNING CHAR(5) AS codret;


DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE cEmpresa          	CHAR(3);
DEFINE cNum_solicitud    	CHAR(20);
DEFINE cEjecutivoAuto         	CHAR(8);
DEFINE cStatus_solicitud 	CHAR(2);
DEFINE cComentario      	VARCHAR(255,1);
DEFINE	cCausa_solicitud 	CHAR(3);
DEFINE	cCliente_pros    	CHAR(1) ;
DEFINE	dFecha_entrada   	DATE ;
DEFINE	dFecha_salida    	DATE;
DEFINE	cUser_insert     	CHAR(8);
DEFINE	dFecha_insert    	DATE;
DEFINE	iRevision_cac    	INTEGER;
DEFINE	dFecha_hora      	DATETIME YEAR to SECOND;

LET cCodRet = '00000';
LET iSqlErr = 0;
LET cEmpresa = '001';
LET cNum_solicitud ='';
LET cEjecutivoAuto        ='';
LET cStatus_solicitud 	='';
LET cComentario = '';
LET cCausa_solicitud = '';
LET cCliente_pros = '';
LET dFecha_entrada = '';
LET dFecha_salida='';
LET cUser_insert= '';
LET dFecha_insert = '';
LET iRevision_cac = 0;
LET dFecha_hora = '';


--SET DEBUG FILE TO "/home/sysifx/JesusTASF/sp_respaldo_ss_autorizacion.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	FOREACH 
		SELECT empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, cliente_pros, fecha_entrada, 
		fecha_salida, user_insert, fecha_insert, revision_cac, fecha_hora
		INTO cEmpresa, cEjecutivoAuto,cNum_solicitud,cStatus_solicitud,cComentario,cCausa_solicitud,cCliente_pros,dFecha_entrada,
		dFecha_salida,cUser_insert,dFecha_insert,iRevision_cac,dFecha_hora
		FROM ss_autorizacion
		WHERE num_solicitud = pNum_solicitud
		
		INSERT INTO bdisolic: "informix".ss_autorizacion_respaldo (empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, cliente_pros, fecha_entrada, 
		fecha_salida, user_insert, fecha_insert, revision_cac, fecha_hora)
		VALUES ( cEmpresa, cEjecutivoAuto,cNum_solicitud,cStatus_solicitud,cComentario,cCausa_solicitud,cCliente_pros,dFecha_entrada,
		dFecha_salida,cUser_insert,dFecha_insert,iRevision_cac,dFecha_hora);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '10001'; -- LA INSERCION NO SE REALIZO
			RETURN cCodRet;
		ELSE
			DELETE FROM bdisolic: "informix".ss_autorizacion WHERE num_solicitud = pNum_solicitud;	
			RETURN cCodRet;
		END IF;
		
	END FOREACH;
	

END;
END PROCEDURE

