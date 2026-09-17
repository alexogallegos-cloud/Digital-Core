create procedure "informix".sp_reenvio_sols_bccc9()
       returning char(5); -- ,CHAR(100);
DEFINE iSqlErr      					INTEGER;
DEFINE iIsamErr         				INTEGER;
DEFINE cErrorInfo       				CHAR(100);
DEFINE cCodRet          				CHAR(6);
DEFINE cMensajeRet    					CHAR(100);
DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22); DEFINE cMensajeRet2    	CHAR(60);
DEFINE contador_commit	 INTEGER;	DEFINE val_trans_Commit   SMALLINT;
DEFINE v_num_solicitud  char(25);
 DEFINE v_institucion char(2);

LET iSqlErr                         = 0;
LET iIsamErr         				= 0;
LET cErrorInfo       				= "";
LET cCodRet          				= "00000";
LET cMensajeRet    					= "";
LET contador_commit = 	0;	LET val_trans_Commit = 	0;

BEGIN
--Errores no controlados.
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		LET cCodRet= iSqlErr;
		LET cMensajeRet= cErrorInfo;
		LET cMensajeRet2 = '';
				
		RETURN cCodRet; --,v_num_solicitud;
	END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOSNEW/IPCB/Reenvio9/sp_reenvio_sols_bccc9.out";
--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	--SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 	FROM sysmaster:sysshmvals;

	SELECT  num_solicitud, institucion
	FROM  bdiburo:br_traslado
	--where institucion = 'BC'         and
	where status = '9' and fecha_insert >= today
	into temp univ_reenvio_st9 with no log;


	FOREACH WITH HOLD
		select num_solicitud, institucion
		into v_num_solicitud, v_institucion
		from univ_reenvio_st9


		begin; 
		update bdiburo:br_Traslado set status = 0, fecha_insert = today  where institucion = v_institucion and num_solicitud = v_num_solicitud and status = 9;
		commit;

		LET contador_commit = contador_commit  + 1;
	END FOREACH

	--SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc 	FROM sysmaster:sysshmvals;

	LET cCodRet     = "00000";
	LET cMensajeRet = "Reenvio status 9 OK Total: "||contador_commit ;
	--LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;	

	--RETURN cCodRet, cMensajeRet, cMensajeRet2;
	RETURN cCodRet; --, cMensajeRet;
	END
END PROCEDURE
;