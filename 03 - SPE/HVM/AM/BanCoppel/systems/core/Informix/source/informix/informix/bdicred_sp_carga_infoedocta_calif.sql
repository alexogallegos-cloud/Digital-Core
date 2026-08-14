create procedure "informix".sp_carga_infoedocta_calif()
       returning char(5),CHAR(100),char(60);


    DEFINE vcodret          CHAR(5);
	DEFINE iSqlErr      	INTEGER;
	DEFINE iIsamErr         INTEGER;
	DEFINE cErrorInfo       CHAR(100);
	DEFINE cMensajeRet    	CHAR(100);
		
    DEFINE vsql             CHAR(1500);
	DEFINE vsql2            CHAR(1500);
	DEFINE vsh             CHAR(1500);
	
	DEFINE vfecha_carga				DATE;

	DEFINE nom_arch			CHAR(100);
	DEFINE nom_arch_zip		CHAR(100);
	DEFINE nom_sql			CHAR(100);
	DEFINE nom_sh			CHAR(100);
	DEFINE bandera_arch CHAR(1);
	DEFINE bandera_periodo  CHAR(6);
	DEFINE ruta_archivo		CHAR(100);
	DEFINE ruta_script		CHAR(100);
	DEFINE cred_del   VARCHAR(20);
	DEFINE fec_del 	 	DATE;
	DEFINE v_periodo CHAR(6);
	
	DEFINE cMensajeRet2    	CHAR(60); DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22); 	
	
	
	LET vcodret     = "00111";
	LET cMensajeRet = "Erro:No se realizo la carga";
    LET vsql = "";
	LET v_periodo = "";
	LET nom_arch="";
	LET nom_arch_zip ="";

	
BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
	  LET vcodret=  iSqlErr;
	  LET cMensajeRet2 = '';
    RETURN vcodret,cMensajeRet,cMensajeRet2;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOS/INFOSAT/Riesgos/25abr/sp_carga_infoedocta_calif.out";
--TRACE ON; 

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
  FROM sysmaster:sysshmvals;

	SELECT mdy(month(fecha_hoy),'20',year(fecha_hoy))
	INTO vfecha_carga
	FROM sd_fechas;
	
	--let vfecha_carga = mdy('02','20','2019');
		
	LET v_periodo = lpad(MONTH(vfecha_carga),2,0)||year(vfecha_carga);
	LET ruta_archivo = "/resplogifx/archivoscartera/";
	LET ruta_script = "/resplogifx/archivoscartera/";

	
	IF (SELECT count(*) FROM  sd_info_edocta_calif WHERE fecha_emision = vfecha_carga) > 0 THEN
		SELECT num_credito ,fecha_emision
		FROM sd_info_edocta_calif
		WHERE fecha_emision = vfecha_carga
		into temp ctas_del with no log;
		

		CREATE INDEX idx_ctas_del ON ctas_del (num_credito) ONLINE;
	
		FOREACH WITH HOLD
			SELECT num_credito , fecha_emision
			INTO cred_del, fec_del
			FROM ctas_del
			
			BEGIN WORK;
				DELETE FROM sd_info_edocta_calif
	             WHERE fecha_emision  = fec_del
                   AND num_credito = cred_del;		
			COMMIT WORK;
		END FOREACH;  
			
		DROP TABLE ctas_del;
		
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_info_edocta_calif;		
	END IF;
	
	IF (SELECT count(*) FROM  sd_info_edocta_calif WHERE fecha_emision = vfecha_carga) = 0 THEN
--Descomprime el archivo
		LET nom_arch_zip = 'info_edocta_insumos'||trim(v_periodo)||'.unl.gz';	
		LET vsh ='gunzip '||trim(ruta_archivo)||trim(nom_arch_zip);
		SYSTEM vsh;	 	
--Valida existencia del sql de la carga de existir lo borra				
		LET nom_sh ='v_sql_carga_infoedoctacalif.sh';	
		LET vsh = trim(ruta_script)||trim(nom_sh);
		SYSTEM vsh;	
--Crea archivo sql para la carga		
		LET nom_arch ='';
		LET vsql = ''; 
	 
		LET nom_arch = 'info_edocta_insumos'||trim(v_periodo)||'.unl';
		LET nom_sql ='carga_infoedoctacalif_sql.sql'; 
			
		LET vsql = 'echo " FILE '||trim(ruta_archivo)||trim(nom_arch)||" delimiter '|' 9;"||
		' INSERT INTO sd_info_edocta_calif; '||
		'" > '||trim(ruta_script)||trim(nom_sql);
		SYSTEM vsql;
			
		LET vsql2 = '';
		LET vsql2 ='chmod 777 '||trim(ruta_script)||trim(nom_sql);
		SYSTEM vsql2;
		
--Ejecuta shell de carga		
		LET nom_sh ='carga_infoedoctacalif_sh.sh';
		LET vsh = trim(ruta_script)||trim(nom_sh);
		SYSTEM vsh;	 
			
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_info_edocta_calif;	

--Borra archivo cargado		
		LET vsh ='rm '||trim(ruta_archivo)||trim(nom_arch);
		SYSTEM vsh;	 					
		
		LET vcodret     = "00000";
		LET cMensajeRet = "CARGA INFORMACION EDOCTA "||v_periodo|| " Ok.";	
	END IF;	
	
	SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc 
  FROM sysmaster:sysshmvals;
  
  LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;
	
    RETURN vcodret, cMensajeRet,cMensajeRet2;

END;
END PROCEDURE;