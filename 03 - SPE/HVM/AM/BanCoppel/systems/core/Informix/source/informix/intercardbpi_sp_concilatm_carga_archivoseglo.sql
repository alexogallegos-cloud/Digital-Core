CREATE PROCEDURE "informix".sp_concilatm_carga_archivoseglo(pempresa char(3),psFechaconciliacion DATE)                            
			RETURNING VARCHAR(5), VARCHAR(255);
	--conciliacion_atm_es  NUEVA TABLA DONDE SE GUARDA INF ATM
	--conciladm_eglopos    ANTIGUA TABLA DONDE SE GUARDA E-S ADM
	--conciladm_archegloposacum ANTIGUA TABLA DONDE se guarda acumulado AMD

	--****************************************************************************************************
	-- DESCRIPCION: CARGA LOS ARCHIVOS PROPORCIONADOS POR EGLOBAL,  A LAS TABLAS CORRESPONDIENTES 
	-- PARA SER PROCESADOS POR LA CONCILIACION DE ATM
	-- AUTOR : René Aldana 
	-- FECHA : 08/07/2011
	-- BD: Intercard
	-- SISTEMA : Conciliacion ATM vs SIF
	--***************************************************************************************************
				
		--Definicion de variables
		DEFINE chrcodret               CHAR(6);
		DEFINE intcodret               INT;
		DEFINE iSamErr		           INTEGER;
		DEFINE cVarDataErr	           VARCHAR(64);

		DEFINE vsql                    CHAR(210);

		DEFINE vs_Nomarchivo           VARCHAR(50);
		DEFINE vs_Nomarchivo_prs       VARCHAR(50);
		DEFINE expresion               CHAR(5);
		DEFINE expresion1              CHAR(5);
		DEFINE expresion2              VARCHAR(255);
		DEFINE vpath                   VARCHAR(90);
		DEFINE v_numcuenta             VARCHAR(13);
		DEFINE v_numtarjeta            VARCHAR(16);
		DEFINE fecha_archivo           DATE;
		DEFINE vfecha_depura 		   DATE;
	-- variables para fecha archivo eglobal
		DEFINE v_idia            	   SMALLINT;
		DEFINE v_iMes            	   SMALLINT;
		DEFINE v_iAnio           	   SMALLINT;
		DEFINE vfecha_param      	   CHAR(8);
		DEFINE vfechaconciliacion_min  CHAR(8);
		DEFINE vfechaconciliacion      CHAR(8);

		DEFINE vfechaconciliacion_min_d  DATE;
		DEFINE vfechaconciliacion_d      DATE;	
		


		--Inicializacion de variables
		LET chrcodret  = '000';
		LET vsql = '';

		LET vs_Nomarchivo='';
		LET vs_Nomarchivo_prs='';	
		LET expresion ='';
		LET expresion1 ='';
		LET expresion2 ='';
		LET vpath = '';
		LET v_numcuenta = '';
		LET v_numtarjeta = '';
		
		LET v_idia      = 0;  
		LET v_iMes      = 0; 
		LET v_iAnio     = 0; 
		LET vfechaconciliacion_min	 = '';
		LET vfechaconciliacion  	 = '';
		LET vfechaconciliacion_min_d = '';
		LET vfechaconciliacion_d     = '';	
		
		LET v_idia      = DAY(psFechaconciliacion)::SMALLINT;
		LET v_iMes      = MONTH(psFechaconciliacion)::SMALLINT;
		LET v_iAnio     = (SUBSTR(YEAR(psFechaconciliacion ),3,2))::SMALLINT;
		
	BEGIN

		ON EXCEPTION SET intcodret,iSamErr, cVarDataErr
			IF intcodret <> 0 THEN
				LET chrcodret = intcodret;
				RETURN chrcodret, iSamErr || ' ' ||cVarDataErr;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_concilatm_carga_archivoseglo.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;

		LET vfecha_param = LPAD(v_idia,2,0)||"/"||LPAD(v_iMes,2,0)||"/"||LPAD(v_iAnio,2,0);
		--||MONTH(psFechaconciliacion)||'''/'''||SUBSTR(YEAR(psFechaconciliacion),3,2);
		
		
		--SELECT nvl(fecha_hoy,'01/01/1999')::DATE - 3 units MONTH 
		--  INTO vfecha_depura
		--  FROM bdinteg:si_fechas; 
		
		
		IF DAY(psFechaconciliacion) = 01 AND MONTH(psFechaconciliacion) = 01 THEN 
			LET vfechaconciliacion_min = LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||LPAD(MONTH(psFechaconciliacion) -1,2,0)||"/"||SUBSTR(YEAR(psFechaconciliacion) -1 ,3,4);   						                                 
			LET vfechaconciliacion     = LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||LPAD(MONTH(psFechaconciliacion) -1,2,0)||"/"||SUBSTR(YEAR(psFechaconciliacion) -1 ,3,4);   					
						
		ELIF DAY(psFechaconciliacion) = 01 AND MONTH(psFechaconciliacion) <> 01 THEN 		
			LET vfechaconciliacion_min = LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||LPAD(MONTH(psFechaconciliacion) -1,2,0)||"/"||SUBSTR(YEAR(psFechaconciliacion),3,4);   
			LET vfechaconciliacion     = LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||LPAD(MONTH(psFechaconciliacion) -1,2,0)||"/"||SUBSTR(YEAR(psFechaconciliacion),3,4);
		ELIF DAY(psFechaconciliacion) = 02 AND MONTH(psFechaconciliacion) = 01 THEN 		
			LET vfechaconciliacion_min = LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||12||"/"||SUBSTR(YEAR(psFechaconciliacion) -1,3,4);   
			LET vfechaconciliacion     = LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||LPAD(MONTH(psFechaconciliacion),2,0)||"/"||SUBSTR(YEAR(psFechaconciliacion),3,4);			
		ELSE 
			LET vfechaconciliacion_min = LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||LPAD(MONTH(psFechaconciliacion),2,0)||"/"||SUBSTR(YEAR(psFechaconciliacion),3,4);   
			LET vfechaconciliacion     = LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||LPAD(MONTH(psFechaconciliacion),2,0)||"/"||SUBSTR(YEAR(psFechaconciliacion),3,4);   	
		END IF 
		
		DELETE FROM intercard:conciliacion_atm_es WHERE fecha_e < vfecha_param	OR fecha_s < vfecha_param; --TABLA E-S ES DONDE GENERA LA CONCILIACION
		
		DELETE FROM intercard:concilatm_archegloposacum WHERE fecha_mov > vfechaconciliacion_min AND fecha_mov < vfechaconciliacion; -- TABLA DONDE SE REALIZAN ACUMULADOS
		
		DELETE FROM intercard:concilatm_sifegloposacum  WHERE fecha_mov > vfechaconciliacion_min AND fecha_mov < vfechaconciliacion;  -- NUMERO DE REGISTROS ECONTRADOS EN SIF

		DELETE FROM intercard:conciliacion_atm_es WHERE fecha_e > vfechaconciliacion_min AND fecha_e < vfechaconciliacion;
		DELETE FROM intercard:conciliacion_atm_es WHERE fecha_s > vfechaconciliacion_min AND fecha_s < vfechaconciliacion;
		
		SELECT TRIM(valor) INTO vpath FROM intercard:param_conciliacionauto WHERE keyx= 1; --'REP_EGLOBAL_AIX'
		
		

		CREATE TEMP TABLE tmp_archivos_ant(		
			nom_archivo           CHAR(30),		 
			archivoorigen 		  CHAR(3)		
			);

			
		IF DAY(psFechaconciliacion) = 01 AND MONTH(psFechaconciliacion) = 01 THEN 			
		
			INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
						 VALUES("BCPL_ATMC_" ||LPAD(DAY(psFechaconciliacion -1),2,0)||12||SUBSTR(YEAR(psFechaconciliacion) -1,3,4)|| "",'TMC');
			INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
						 VALUES("BCPL_ATMD_" ||LPAD(DAY(psFechaconciliacion -1),2,0)||12||SUBSTR(YEAR(psFechaconciliacion) -1,3,4)|| "",'TMD'); 
						 
		ELIF DAY(psFechaconciliacion) = 01 AND MONTH(psFechaconciliacion) <> 01 THEN 
		
			INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
						 VALUES("BCPL_ATMC_" ||LPAD(DAY(psFechaconciliacion -1),2,0)||LPAD(MONTH(psFechaconciliacion) -1,2,0)||SUBSTR(YEAR(psFechaconciliacion),3,4)|| "",'TMC');
			INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
						 VALUES("BCPL_ATMD_" ||LPAD(DAY(psFechaconciliacion -1),2,0)||LPAD(MONTH(psFechaconciliacion) -1,2,0)||SUBSTR(YEAR(psFechaconciliacion),3,4)|| "",'TMD'); 		
		ELSE 
		
			INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
						 VALUES("BCPL_ATMC_" ||LPAD(DAY(psFechaconciliacion -1),2,0)||LPAD(MONTH(psFechaconciliacion),2,0)||SUBSTR(YEAR(psFechaconciliacion),3,4)|| "",'TMC');
			INSERT INTO  tmp_archivos_ant  (nom_archivo,archivoorigen)
						 VALUES("BCPL_ATMD_" ||LPAD(DAY(psFechaconciliacion -1),2,0)||LPAD(MONTH(psFechaconciliacion),2,0)||SUBSTR(YEAR(psFechaconciliacion),3,4)|| "",'TMD'); 				
		
		END IF
						 
		FOREACH
		 SELECT nom_archivo 
		   INTO vs_Nomarchivo 
		   FROM tmp_archivos_ant
		  ORDER BY nom_archivo DESC
		   
			LET vs_Nomarchivo = TRIM(vs_Nomarchivo) ||'.txt';
			
			DELETE FROM intercard:concilatm_archeglo; 
				 
			EXECUTE  PROCEDURE sp_conciladm_paserarchivo (vpath,trim(vs_Nomarchivo)) INTO expresion,expresion1;
			
			IF TRIM(expresion) <> '00000' THEN
				
				IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'tmp_archivos_ant') THEN	
					DROP TABLE tmp_archivos_ant;
				END IF
				
				LET vsql = 'rm -f ' || TRIM(vpath) || "/*.prst" ;
				SYSTEM vsql;			
				
				RETURN expresion,'El Archivo: ' || vs_Nomarchivo || ' No Existe';
				
			ELSE
				LET vs_Nomarchivo_prs = TRIM(vs_Nomarchivo) || '.prst';
			END IF
			
			--EXECUTE PROCEDURE sp_con_buscararchivo(vpath,trim(vs_Nomarchivo_prs)) INTO expresion,expresion1;
				 
			--LET expresion1 = TRIM(expresion1);
				 
			IF TRIM(expresion1) <> 'F' THEN

				LET chrcodret = '000'; -- NO HABIA INFORMACION Y SE CARGO LA INFORMACION

				LET vsql = 'echo "LOAD FROM ''' || vpath || '/' || TRIM(vs_Nomarchivo_prs) || ''' DELIMITER ' || '''|''' || ' INSERT INTO concilatm_archeglo" >' || vpath || '/cargaarchivosatm.sql';
				SYSTEM vsql;

				LET vsql = '';

				LET vsql = 'dbaccess intercard ' || vpath || '/cargaarchivosatm.sql';
				SYSTEM vsql;

				DELETE FROM intercard:concilatm_archeglo WHERE registro  matches 'HEADER*' or registro  matches 'TRAILER 0*' ;
				DELETE FROM intercard:concilatm_archeglo WHERE registro  matches '*TRANSACCIONES*';
				DELETE FROM intercard:concilatm_archeglo WHERE registro  matches '*CREDITOCOPPEL*';
				DELETE FROM intercard:concilatm_archeglo WHERE registro  LIKE '       %';
				DELETE FROM intercard:concilatm_archegloposacum WHERE nomarchivo = UPPER(TRIM(vs_Nomarchivo));
				DELETE FROM intercard:conciliacion_atm_es WHERE nombre_arc = UPPER(TRIM(vs_Nomarchivo));

				IF vs_Nomarchivo LIKE '%TMC_%' OR vs_Nomarchivo LIKE '%TMD_%'  THEN

					INSERT INTO intercard:conciliacion_atm_es(nombre_arc,fechaconciliacion_e,adquiriente_e,secuenciaut_e,numtarjeta_e,numcuenta_e,descripcion_e,indicadordereversa_e,codigoiso_e,monto_e
															 ,montosurcharge_e,fecha_e,hora_e,numcajero_e,monto_loyaltyfee_e,banderaadquiriente_e)				
					SELECT UPPER(TRIM(vs_Nomarchivo)) as nombrearch,
						   CURRENT, 					   					   
						   TRIM(SUBSTRING (Registro FROM 3 FOR 4 ))    as adquiriente,                
						   '1'||TRIM(SUBSTRING (Registro FROM 10 FOR 6 ))   as secuenciaut,  					   
						   TRIM(SUBSTRING (Registro FROM 25 FOR 16 ))  as numtarjeta,                                                        
						   TRIM(SUBSTRING (Registro FROM 48 FOR 20 ))  as numcuenta,                                                        
						   TRIM(SUBSTRING (Registro FROM 91 FOR 15 ))  as descripcion,                                                        
						   TRIM(SUBSTRING (Registro FROM 70 FOR 19 ))  as indicadordereversa,                                                        
						   TRIM(SUBSTRING (Registro FROM 115 FOR 3 ))  as codigoiso,  	              
						   (SUBSTRING (Registro FROM 183 FOR 8 )||'.'|| SUBSTRING (Registro FROM 191 FOR 2))::DECIMAL(18,2) as monto,
						   (SUBSTRING (Registro FROM 200 FOR 8 )||'.'|| SUBSTRING (Registro FROM 208 FOR 2))::DECIMAL(18,2) as montosurcharge,
						   TRIM(SUBSTRING (Registro FROM 150 FOR 8 ))  as fecha,  						                                 
						   TRIM(SUBSTRING (Registro FROM 159 FOR 8 ))  as hora,                                                        
						   TRIM(SUBSTRING (Registro FROM 136 FOR 14 )) as numcajero,                                                       
						   (SUBSTRING (Registro FROM 210 FOR 8 )||'.'|| SUBSTRING (Registro FROM 218 FOR 2))::DECIMAL(18,2) as monto_loyaltyfee,
						   TRIM(SUBSTRING (Registro FROM 240 FOR 1 )) as banderaadquiriente                                                           
					 FROM intercard:concilatm_archeglo a LEFT JOIN intercard:tarjetacuenta b
					   ON b.numtarjeta = TRIM(SUBSTRING (Registro FROM 25 FOR 16 ))
					 WHERE   TRIM(SUBSTRING (Registro FROM 10 FOR 6 )) <> '000000';

				END IF
				
				INSERT INTO intercard:concilatm_archegloposacum
						   (nomarchivo,num_reg_ins,importe,fecha_archivo,fecha_mov) 
				SELECT nombre_arc,COUNT(*) as numregistro,SUM(monto_e) as importe,fechaconciliacion_e, fecha_e
				  FROM intercard:conciliacion_atm_es
				 WHERE nombre_arc = UPPER(TRIM(vs_Nomarchivo))
				 AND codigoiso_e = '00' 
				 GROUP BY 1,4,5;			
				 
			END IF;

			UPDATE STATISTICS MEDIUM FOR TABLE intercard:conciliacion_atm_es;

		END FOREACH;
			

		 IF (DAY(psFechaconciliacion) = 01 AND MONTH(psFechaconciliacion) = 01) THEN
			LET vfechaconciliacion_min_d = 12||"/"||LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||YEAR(psFechaconciliacion) -1;			
			LET vfechaconciliacion_d     = 12||"/"||LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||YEAR(psFechaconciliacion) -1;						
		 ELIF (DAY(psFechaconciliacion) = 01 AND MONTH(psFechaconciliacion) <> 01) THEN
			LET vfechaconciliacion_min_d = LPAD(MONTH(psFechaconciliacion) -1,2,0)||"/"||LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||YEAR(psFechaconciliacion);
	       LET vfechaconciliacion_d     = LPAD(MONTH(psFechaconciliacion) -1,2,0)||"/"||LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||YEAR(psFechaconciliacion);   				
		 ELIF (DAY(psFechaconciliacion) = 02 AND MONTH(psFechaconciliacion) = 01) THEN
			LET vfechaconciliacion_min_d = 12||"/"||LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||YEAR(psFechaconciliacion) -1;
			LET vfechaconciliacion_d     = LPAD(MONTH(psFechaconciliacion),2,0)||"/"||LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||YEAR(psFechaconciliacion); 			
		 ELIF (DAY(psFechaconciliacion) = 02 AND MONTH(psFechaconciliacion) <> 01) THEN
			LET vfechaconciliacion_min_d = LPAD(MONTH(psFechaconciliacion) -1,2,0)||"/"||LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||YEAR(psFechaconciliacion);
			LET vfechaconciliacion_d     = LPAD(MONTH(psFechaconciliacion),2,0)||"/"||LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||YEAR(psFechaconciliacion); 
		 ELSE 
			LET vfechaconciliacion_min_d = LPAD(MONTH(psFechaconciliacion),2,0)||"/"||LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||YEAR(psFechaconciliacion);
			LET vfechaconciliacion_d     = LPAD(MONTH(psFechaconciliacion),2,0)||"/"||LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||YEAR(psFechaconciliacion);   	
		 END IF;
		 
		 
		  --LET vfechaconciliacion_min_d = LPAD(MONTH(psFechaconciliacion),2,0)||"/"||LPAD(DAY(psFechaconciliacion -2),2,0)||"/"||YEAR(psFechaconciliacion);
		EXECUTE PROCEDURE "informix".sp_concilatm_concileglo(pempresa,vfechaconciliacion_min_d) INTO chrcodret,expresion2;

		IF TRIM(chrcodret) = '000' THEN 	

		   --LET vfechaconciliacion_d     = LPAD(MONTH(psFechaconciliacion),2,0)||"/"||LPAD(DAY(psFechaconciliacion -1),2,0)||"/"||YEAR(psFechaconciliacion);   	
		   EXECUTE PROCEDURE "informix".sp_concilatm_concileglounl(pempresa,vfechaconciliacion_d) INTO chrcodret,expresion2;
		END IF

		DROP TABLE tmp_archivos_ant;
	RETURN chrcodret,expresion2;
	END;
	END PROCEDURE;