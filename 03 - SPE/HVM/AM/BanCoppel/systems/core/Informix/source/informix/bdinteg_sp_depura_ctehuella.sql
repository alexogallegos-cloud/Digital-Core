CREATE PROCEDURE "informix".sp_depura_ctehuella()
	RETURNING 
	CHAR(5) AS cCodRet,
	CHAR(100) AS cMensajeREt; 
	----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
	--DECLARACIÓN DE VARIABLE
	DEFINE cCodRet		CHAR(5);
	DEFINE cMensajeREt	CHAR(100);
	DEFINE cSql         CHAR(6000);
	DEFINE Cnumcte		CHAR(20);
	DEFINE Cnumcred	CHAR(20);
	DEFINE Vexiste		INTEGER;
	DEFINE dAFecha		DATE;
	DEFINE iSqlErr      INTEGER;
	----- ----- -----
	--INICIALIZACIÓN DE VARIABLE
	LET cCodRet ='00000';
	LET cMensajeREt ='Proceso Exitoso';
	LET Cnumcte = '';
	LET Vexiste = 0;
	LET iSqlErr = 0;
	LET dAFecha ='';
	LET cSql = '';
	----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
	/*SET DEBUG FILE TO "/informix/c92962301/respaldo_caso1_depuracion.OUT";
	   TRACE ON;*/
	----- ----- ----- ----- ----- ----- ----- -----
	BEGIN
	----- ----- ----- ----- ----- ----- ----- -----
		ON EXCEPTION SET iSqlErr
			IF iSqlErr !=0 THEN
			  LET cCodRet = iSqlErr;
			  LET cMensajeRet = "Ocurrio un Error";
			ROLLBACK;
			  -- TRUNCATE TABLE  bdidigital:clientes_eliminacion; 
			  RETURN cCodRet,cMensajeRet;
			END IF;
		END EXCEPTION;
		----- ----- ----- ----- ----- ----- ----- -----
		SET ISOLATION TO DIRTY READ; -- Hace consultas "sucias"
		SET LOCK MODE TO WAIT 3; -- Espera 3 segundos si la tabla y/o el registro esta bloqueado
		----- ----- ----- ----- ----- ----- ----- -----
		    --SE VALIDA SI LA TABLA EXISTE Y SI SE ENCUENTRA VACIA--
		    IF EXISTS( SELECT dbsname, tabname FROM sysmASter:systabnames  WHERE tabname = 'cliente_paso_huellas' ) THEN
				----- ----- ----- ----- ----- ----- ----- -----
				select limit 1 numcte INTO Cnumcte from bdinteg:"informix".cliente_paso_huellas;
				----- ----- ----- ----- ----- ----- ----- -----
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN				 
					    ----- ----- ----- -----
						  LET cSql = '';
						  LET cSql = 'echo "SET ISOLATION TO DIRTY READ;'|| ' '||
						  'set lock mode to wait 4;'||' '||
						  'load FROM /resplogifx/archivoscartera/si_cte_huella_aut.unl DELIMITER ''|'' '||' '||
						  'insert INTO cliente_paso_huellas;" > /resplogifx/archivoscartera/cargatemp.sql';											  
						  SYSTEM cSql;
						----- ----- ----- -----
						  LET cSql = '';
						  LET cSql  = "dbaccess bdinteg /resplogifx/archivoscartera/cargatemp.sql"; 
						  SYSTEM cSql;
						  LET cSql = '';
					end if;
			----- ----- ----- ----- ----- ----- ----- -----        
			ELSE     
			----- ----- ----- ----- ----- ----- ----- -----
				  --SE CREA LA TABLA DE PASO  
				  CREATE TABLE bdinteg:"informix".cliente_paso_huellas(numcte char(20));
				  create unique index inx_paso1_cli on cliente_paso_huellas(numcte);
				  update statistics medium for table cliente_paso_huellas;
				  ----- ----- ----- ----- 
				  LET cSql = '';
				  LET cSql = 'echo "SET ISOLATION TO DIRTY READ;'|| ' '||
				  'set lock mode to wait 4;'||' '||
				  'load FROM /resplogifx/archivoscartera/si_cte_huella_aut.unl DELIMITER ''|'' '||' '||
				  'insert INTO bdinteg:cliente_paso_huellas;" > /resplogifx/archivoscartera/cargatemp.sql';  
				  SYSTEM cSql;
				  ----- ----- ----- -----
				  LET cSql = '';
				  LET cSql  = "dbaccess bdinteg /resplogifx/archivoscartera/cargatemp.sql"; 
				  SYSTEM cSql;
				  --LET cSql = '';
				  ----- ----- ----- -----
			end if;
		----- ----- ----- ----- ----- ----- ----- -----
		FOREACH WITH HOLD
		----- ----- ----- ----- ----- ----- ----- -----
			--Se realiza la consulta en la tabla para validar solo clientes de  cuales tenemos respaldada la imagen
			SELECT numcte INTO Cnumcte FROM bdinteg:cliente_paso_huellas
			----- ----- ----- ----- ----- ----- ----- -----    
			 SELECT count(cli.numcte) into Vexiste FROM bdinteg:"informix".si_cliente cli
				INNER JOIN bdinteg:"informix".si_cte_huella hue on cli.numcte = hue.numcte
				LEFT JOIN bdinvers:"informix".sv_maeinv inv ON cli.empresa = inv.empresa AND cli.numcte = inv.num_cte
				LEFT JOIN bdicheq:"informix".sc_maechq che ON cli.empresa = che.empresa AND cli.numcte = che.num_cte
				LEFT JOIN bdicheq:"informix".sc_firmantes fir ON cli.empresa = fir.empresa AND cli.numcte = fir.numcte
				LEFT JOIN bdicheq:"informix".sc_beneficiario benf ON cli.empresa = benf.empresa AND cli.numcte = benf.numcte
				LEFT JOIN bdicred:"informix".sd_maecred maecred ON cli.empresa = maecred.empresa AND cli.numcte = maecred.numcte
				LEFT JOIN bdicred:"informix".sd_maecredcrd maecrd ON cli.empresa = maecrd.empresa AND cli.numcte = maecrd.numcte
				LEFT JOIN bdisolic:"informix".ss_solicitudes sol ON cli.empresa = sol.empresa AND cli.numcte = sol.numcte
				WHERE cli.tipo_cliente = '2'
				AND inv.num_cte is null
				AND che.num_cte is null
				AND fir.numcte is null
				AND benf.numcte is null
				AND maecred.numcte is null
				AND maecrd.numcte is null
				AND sol.numcte is null
				AND cli.numcte = Cnumcte;
			----- ----- ----- ----- ----- ----- ----- -----      
			IF Vexiste > 0 THEN  
				----- ----- -----
				BEGIN;	
				----- ----- -----
					 --Elimina el registro de la huella de la si_cte_huella
					 DELETE FROM bdinteg:"informix".si_cte_huella WHERE numcte = Cnumcte;					 
					----- ----- -----
					 --Se elimina de la tabla clientes_paso
					 DELETE FROM bdinteg:"informix".cliente_paso_huellas WHERE numcte = Cnumcte;
				----- ----- -----					   
			   COMMIT;
				----- ----- -----
			ELSE
				----- ----- -----
				 BEGIN; 
				----- ----- -----
				   DELETE FROM bdinteg:"informix".cliente_paso_huellas WHERE numcte = Cnumcte;
				----- ----- -----
				 COMMIT;
				----- ----- -----
			END IF;
			----- ----- -----     
		END FOREACH;
		----- ----- -----
			DROP TABLE  bdinteg:"informix".cliente_paso_huellas; 
			RETURN cCodRet,cMensajeRet;
			----- ----- -----    
END;
END PROCEDURE
;