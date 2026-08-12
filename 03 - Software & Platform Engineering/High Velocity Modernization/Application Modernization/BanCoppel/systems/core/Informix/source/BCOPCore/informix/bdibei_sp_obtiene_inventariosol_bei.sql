CREATE PROCEDURE "informix".sp_obtiene_inventariosol_bei()
   RETURNING CHAR(5),CHAR(100);  
	--*************************************************************
	--Objetivo:Obtiene datos para el panel de control personas moral.
	--SolicitÃ³: JosÃ© de JesÃºs Nevarez.
	--ElaborÃ³ Jose Ruben Lopez.
	--Fecha: 2013-08-14.
	--BD:bdibei.
	--ModificÃ³:              Fecha          DescripciÃ³n
	--Juan Daniel Lazalde    20-sep-2013    Se cambio en el resultado En proceso por Enviado
	--*************************************************************  
	--Fecha: 2017-05-05.
	--Gabriela Aguilar    Se cambian los tipos SMALLINT por INTEGER
	--*************************************************************	
   

   -- DEFINE
	
    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
	DEFINE vRecibidasM  INTEGER;
	DEFINE vEnProcesoM INTEGER;
	DEFINE vAtendidasM INTEGER;
	DEFINE vDevueltasM  INTEGER;
	DEFINE vReactivadasM  INTEGER;
	DEFINE vRechazadasM INTEGER;
	DEFINE vRecibidasF  INTEGER;
	DEFINE vEnProcesoF INTEGER;
	DEFINE vAtendidasF INTEGER;
	DEFINE vDevueltasF  INTEGER;
	DEFINE vReactivadasF  INTEGER;
	DEFINE vRechazadasF INTEGER;
	DEFINE vTramaRet CHAR(36);
	DEFINE vEnviadaM INTEGER;
	DEFINE vEnviadaF INTEGER;
	
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vTramaRet='';
	LET vRecibidasM=0;
	LET vEnProcesoM=0;
	LET vAtendidasM=0;
	LET vDevueltasM=0;
	LET vReactivadasM=0;
	LET vRechazadasM=0;
	LET vRecibidasF=0;
	LET vEnProcesoF=0;
	LET vAtendidasF=0;
	LET vDevueltasF=0;
	LET vReactivadasF=0;
	LET vRechazadasF=0;
	LET vEnviadaM=0;
	LET vEnviadaF=0;
	
	--SET DEBUG FILE TO '/tmp/sp_obtiene_inventariosol_bei.out';
	--TRACE ON;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret,vTramaRet;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		--Datos panel de control PM
		--Recibidas
		SELECT COUNT(*) as contador 
		INTO vRecibidasM
		FROM "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si WHERE  id_status='100' AND si.numcte = tk.numcte;
		--En proceso
		SELECT COUNT(*)as contador  
		INTO vEnProcesoM
		FROM "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si  WHERE id_status='110' AND si.numcte = tk.numcte;
		--Enviada
		SELECT COUNT(*)as contador  
		INTO vEnviadaM
		FROM bdibei:"informix".bei_solicitudtoken WHERE id_status='120';
		--Atendidas
		SELECT COUNT(*)as contador  
		INTO vAtendidasM
		FROM "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si WHERE id_status='130' AND si.numcte = tk.numcte;
		--Devueltas
		SELECT COUNT(*) as contador 
		INTO vDevueltasM
		FROM "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si WHERE id_status='170' AND si.numcte = tk.numcte;
		--Reactivadas
		SELECT COUNT(*)as contador  
		INTO vReactivadasM
		FROM "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si WHERE id_status='180' AND si.numcte = tk.numcte;
		--Rechazadas
		SELECT COUNT(*) as contador 
		INTO vRechazadasM
		FROM "informix".bei_solicitudtoken tk, bdinteg:"informix".si_cliente si WHERE id_status='190' AND si.numcte = tk.numcte;
		
		--Datos panel de control PF
		--Recibidas
		SELECT COUNT(*) as contador 
		INTO vRecibidasF
		FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si  WHERE id_status='100' AND si.numcte = tk.numcte;
		--En proceso
		SELECT COUNT(*)as contador  
		INTO vEnProcesoF
		FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si  WHERE id_status='110' AND si.numcte = tk.numcte;
		--Enviada
		SELECT COUNT(*)as contador  
		INTO vEnviadaF
		FROM bdibpi:"informix".bpi_tokensolicitud WHERE id_status='120';
		--Atendidas
		SELECT COUNT(*)as contador  
		INTO vAtendidasF
		FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si  WHERE id_status='130' AND si.numcte = tk.numcte;
		--Devueltas
		SELECT COUNT(*) as contador 
		INTO vDevueltasF
		FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si  WHERE id_status='170' AND si.numcte = tk.numcte;
		--Reactivadas
		SELECT COUNT(*)as contador  
		INTO vReactivadasF
		FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si  WHERE id_status='180' AND si.numcte = tk.numcte;
		--Rechazadas
		SELECT COUNT(*) as contador 
		INTO vRechazadasF
		FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si  WHERE id_status='190' AND si.numcte = tk.numcte;
		
		  LET vTramaRet=vRecibidasM|| '|'|| vEnviadaM|| '|'||vAtendidasM|| '|'|| vDevueltasM|| '|'||vReactivadasM|| '|'||vRechazadasM||'|'||vRecibidasF|| '|'|| vEnviadaF|| '|'||vAtendidasF|| '|'|| vDevueltasF|| '|'||vReactivadasF|| '|'||vRechazadasF;
		RETURN cod_ret,vTramaRet;
		
	END;	
END PROCEDURE;