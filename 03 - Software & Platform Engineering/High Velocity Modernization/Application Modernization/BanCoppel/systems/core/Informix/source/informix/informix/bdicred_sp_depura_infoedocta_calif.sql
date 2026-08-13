create procedure "informix".sp_depura_infoedocta_calif()
       returning char(5),CHAR(100),char(60);

    DEFINE vcodret          CHAR(5);
	DEFINE iSqlErr      	INTEGER;
	DEFINE iIsamErr         INTEGER;
	DEFINE cErrorInfo       CHAR(100);
	DEFINE cMensajeRet    	CHAR(100);
		
    DEFINE vsql             CHAR(1500);
	DEFINE vsql2            CHAR(1500);
	DEFINE vsh             CHAR(1500);
	
	DEFINE vfecha_depura				DATE;

	DEFINE nom_arch			CHAR(100);
	DEFINE nom_sql			CHAR(100);
	DEFINE nom_sh			CHAR(100);
	DEFINE bandera_arch CHAR(1);
	DEFINE bandera_periodo  CHAR(6);
	DEFINE ruta_archivo		CHAR(100);
	DEFINE ruta_script		CHAR(100);
	DEFINE cred_del   VARCHAR(20);
	DEFINE fec_del 	 	DATE;
	DEFINE v_periodo CHAR(6);
	DEFINE ctas_dep		integer;
	DEFINE cMensajeRet2    	CHAR(60); DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22); 
	
    LET vcodret     = "00111";
	LET cMensajeRet = "Erro:No se realizo la depuracion";
    LET vsql = "";
	LET v_periodo = "";
	LET nom_arch="";
	LET ctas_dep= 0;

BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
	  LET vcodret=  iSqlErr;
	  LET cMensajeRet2 = '';
    RETURN vcodret,cMensajeRet,cMensajeRet2;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOS/ipcb/EDOCTAS/pruebas/sp_depura_infoedocta_calif.out";
--TRACE ON; 

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
  FROM sysmaster:sysshmvals;

	SELECT mdy(month(fecha_hoy),'20',year(fecha_hoy))
	INTO vfecha_depura
	FROM sd_fechas;
	
	LET vfecha_depura = vfecha_depura - 5 units MONTH;
	
	LET v_periodo = lpad(MONTH(vfecha_depura),2,0)||year(vfecha_depura);
	LET ruta_archivo = "/resplogifx/archivoscartera/";
	LET ruta_script = "/resplogifx/archivoscartera/";
	
	
	IF (SELECT count(*) FROM  sd_info_edocta_calif WHERE fecha_emision <= vfecha_depura ) > 0 THEN
			
		SELECT num_credito ,fecha_emision
		FROM sd_info_edocta_calif
		WHERE fecha_emision <= vfecha_depura
		into temp ctas_del with no log;
		
		begin;
		CREATE INDEX idx_ctas_del ON ctas_del (num_credito) ONLINE;
		commit;
	
		FOREACH WITH HOLD
			SELECT num_credito , fecha_emision
			INTO cred_del, fec_del
			FROM ctas_del
			
			BEGIN WORK;
				DELETE FROM sd_info_edocta_calif
	             WHERE fecha_emision  = fec_del
                   AND num_credito = cred_del;		
			COMMIT WORK;
			
			LET ctas_dep = ctas_dep +1;				
		END FOREACH;  
		
		DROP TABLE ctas_del;
		
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_info_edocta_calif;	
		
		LET vcodret     = "00000";
		LET cMensajeRet = "INFORMACION EDOCTA CALIF DEPURADA "||ctas_dep|| " Ok.";	
	END IF;
	
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc 
  FROM sysmaster:sysshmvals;
  
  LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;
	
   RETURN vcodret, cMensajeRet,cMensajeRet2;

END;
END PROCEDURE;