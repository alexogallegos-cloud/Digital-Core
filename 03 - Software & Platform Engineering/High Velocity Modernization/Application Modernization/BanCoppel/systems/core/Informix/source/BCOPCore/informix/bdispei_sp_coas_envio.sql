CREATE PROCEDURE "informix".sp_coas_envio()
RETURNING   CHAR(5);

DEFINE vsqlerr             INT;
DEFINE vcodret             CHAR(5);

--VARIABLES PROCESO
DEFINE v_vchrvalor         DATE;   
DEFINE v_vchrclaverastreo  VARCHAR(30); 
DEFINE v_consecutivo       SMALLINT;
DEFINE v_consecutivo2      SMALLINT;
DEFINE v_cadena            CHAR(600);
DEFINE v_enc_ide1          INT;
DEFINE v_enc_ide2          INT;
DEFINE v_total_det         INT;
DEFINE v_cade_enca         CHAR(600);  
DEFINE vsql                CHAR(500); 
DEFINE v_con_archi         CHAR(4);
DEFINE v_anio_fin          INTEGER;
DEFINE v_mes_fin           CHAR(2);
DEFINE v_dia_fin           CHAR(2);
DEFINE v_f_fin             VARCHAR(8);
DEFINE v_fecha_arch        CHAR(6);
DEFINE v_identificador     CHAR(50);
 
--ASIGNACION DE PARAMETROS PARA EL ENCABEZADO
LET v_enc_ide1 = 1;
LET v_enc_ide2 = 40137;	 

LET vsqlerr = 0; 
LET vcodret = "000";


BEGIN
	  ON EXCEPTION SET vsqlerr
	     SET DEBUG FILE TO "/resplogifx/conciliachq/spei/coas_envio.err";
	  	   TRACE ON;
             IF vsqlerr <> 0 THEN
                LET vcodret = vsqlerr;
             RETURN vcodret;
             END IF;
      END EXCEPTION;
	
     -- SET DEBUG FILE TO '/resplogifx/conciliachq/spei/coas_env_err.txt';
	 -- TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  	  
      --ARMA LA FECHA		  
      SELECT DATE(SUBSTR (vchrvalor, 4,2)||
	         SUBSTR (vchrvalor, 1,2)||
			 SUBSTR (vchrvalor, 7,4))  
	    INTO v_vchrvalor
        FROM bdispei:tblparametros
       WHERE vchrcveparametro = "FECHA_OPERACION";
	   
	   
	   --TABLA A PARA LAS FECHAS Y CONSECUTIVOS
         IF NOT EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tblfoliocoasenv') THEN
        
		    CREATE TABLE "informix".tblfoliocoasenv ( 
                   fecha      	DATE,
                   consecutivo	INTEGER 
                   )
		    	   EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
         END IF;
	 
		 
		 
		 --TABLA A PARA EL DETALLE Y EL ENCABEZADO
         IF NOT EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tbldetalle') THEN
        
		    CREATE  TABLE "informix".tbldetalle (
                    id      CHAR(50),
                    valor	CHAR(600)
					)
		    	    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
         END IF;
		 
	   
  --VERIFICA LA EXISTENCIA DE LA FECHA  		  
	  SELECT consecutivo
	    INTO v_consecutivo
	    FROM bdispei:tblfoliocoasenv	
	   WHERE fecha = v_vchrvalor;
	   
	      IF v_consecutivo IS NULL THEN 
		     LET v_consecutivo = 1;
		     BEGIN;			 
		     INSERT INTO bdispei:tblfoliocoasenv VALUES(v_vchrvalor, v_consecutivo);
		     COMMIT;
	    ELSE 
		     LET v_consecutivo = v_consecutivo + 1; 
		     BEGIN;
             UPDATE bdispei:tblfoliocoasenv SET consecutivo = v_consecutivo;
             COMMIT; 
         END IF; 	
		  
		  		  
 --INICIALIZA EL CONSECUTIVO
		  LET v_consecutivo2 = 1;
		 

	  
	 --GENERA EL REGISTRO DEL ENCABEZADO
	    BEGIN;
	   INSERT INTO bdispei:tbldetalle VALUES (0,''); 
	   COMMIT; 
		  
		  
	  FOREACH WITH HOLD
	  
			  SELECT v_consecutivo || 
                     "~" ||
                       1 ||
                     "~" ||
                     a.cvecesifbcodest ||
                     "~"||
                     a.mnyimporte ||
                     "~"||
                     v_consecutivo2 ||
                     "~" ||
                     TRIM(a.vchrclaverastreo) ||
                     "~" ||
                     TRIM(a.vchrnombreord) ||
                     "~" ||
                     a.intcvetipoctaord ||
                     "~" ||
                     TRIM(a.vchrcuentaord) ||
                     "~" ||
                     TRIM(a.vchrrfcord) ||
                     "~" ||
                     TRIM(a.vchrnombrebenef) ||
                     "~" ||
                     a.intcvetipoctabene ||
                     "~" ||
                     a.vchrcuentabenef ||
                     "~" ||
                     TRIM(a.vchrrfcbenef) ||
                     "~" ||
                     TRIM(a.vchrconceptopago2) ||
                     "~" ||
                     0.0 ||
                     "~" ||
		             a.intrefnumerica ||
                     "~" ||
		             "" ||
		             "~",
					 a.vchrclaverastreo
				INTO v_cadena,	
                     v_vchrclaverastreo				
                FROM bdispei:tblpago a
               WHERE a.chrsentidopago  = "E"
                 AND a.chrestatusenvio = "N"
                 AND a.vchrclaverastreo IN(SELECT referencia FROM bdicheq:sc_movdia 
                                            WHERE transacc = "0274")
			

											
			   BEGIN;							
			  INSERT INTO bdispei:tbldetalle VALUES (v_consecutivo2,v_cadena);
			  COMMIT;
			    					 
		      --ACTUALIZA EL ESTATUS DE ENVIO							
			   BEGIN;								
			  UPDATE bdispei:tblpago SET  chrestatusenvio = "E" 
			   WHERE vchrclaverastreo = v_vchrclaverastreo;
			  COMMIT;
			  
			     LET v_consecutivo2 = v_consecutivo2 + 1;
			  		  
     END FOREACH;	
	  
	
		    --TOTAL DE REGISTROS DE LA TABLA DETALLE 
			 SELECT COUNT(*) 
			   INTO v_total_det
			   FROM bdispei:tbldetalle; 
			 
			     IF v_total_det > 1 THEN  
			        --SE LE RESTA EL REGISTROS DEL ENCABEZADO
			        LET v_total_det = v_consecutivo2 -1;
			        
							 
					--CONSECUTIVO PARA EL NOMBRE DEL ARCHIVO 
					LET v_con_archi = v_consecutivo;
					 
					IF  LEN (v_con_archi) = 1 THEN 
                        LET  v_con_archi  = '000' || v_con_archi; 
                    END IF; 
					
					IF  LEN (v_con_archi) = 2 THEN 
                        LET  v_con_archi  = '00' || v_con_archi; 
                    END IF; 
					
					IF  LEN (v_con_archi) = 3 THEN 
                        LET  v_con_archi  = '0' || v_con_archi; 
                    END IF;
					
										
					--ARMA LA VARIABLE PARA EL ENCABEZADO
			        LET v_cade_enca =  v_enc_ide1 ||  "~" ||   v_enc_ide2 ||  "~" ||  v_con_archi  ||  "~" || v_total_det;
			        
                    --ACTUALIZA LA VARIABLE DE ENZABEZADO
			        UPDATE bdispei:tbldetalle 
			           SET valor = v_cade_enca
			         WHERE id = 0;
	

                    -- SE OBTIENE LA FECHA PARA EL NOMBRE DEL ARCHIVO
            		LET v_anio_fin = YEAR (v_vchrvalor);
                    LET v_mes_fin  = MONTH(v_vchrvalor);
                    LET v_dia_fin  = DAY  (v_vchrvalor);
            		 
            		IF  LEN (v_mes_fin) = 1 THEN
                        LET  v_mes_fin  = 0 || v_mes_fin;
                    END IF;
            
                    IF  LEN (v_dia_fin) = 1 THEN
                        LET  v_dia_fin  = 0 || v_dia_fin;
                    END IF;
            		  
            		--ARMA LA FECHA PARA EL NOMBRE DEL ARCHIVO         	
                    LET v_f_fin = v_anio_fin || v_mes_fin || v_dia_fin ;
					
					
					--SE OBTIENE LA HORA-MINITO-SEGUNDO PARA EL NOMBRE DEL ARCHIVO 				
	                SELECT SUBSTR(CURRENT,12,2)|| SUBSTR(CURRENT,15,2)|| SUBSTR(CURRENT,18,2) 
					  INTO v_fecha_arch
					  FROM bdicheq:sc_fechas;
			
					
					--PROCESO PARA LA DESCARGA DEL ARCHIVO 
		            LET vsql = '';
                    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
                               'UNLOAD TO  /resplogifx/conciliachq/spei/40137'||v_con_archi||''||v_f_fin||''||v_fecha_arch||'.txt'||
                               ' SELECT valor FROM bdispei:tbldetalle WHERE id  <= '|| v_total_det ||' ORDER BY rowid ; " >  /resplogifx/conciliachq/spei/consulta.sql';
				    	 
	                SYSTEM vsql;
	   
	                --EJECUCION DEL ARCHIVO .SQL
                    LET vsql = '';
                    LET vsql = "dbaccess bdispei  /resplogifx/conciliachq/spei/consulta.sql";
                    SYSTEM vsql; 

					
					--ARMA LA CADENA PARA EL IDENTIFICADOR DE ARCHIVO POR REGISTRO
					LET v_identificador = '40137'||v_con_archi||''|| v_f_fin||''|| v_fecha_arch;
					
					
					--AGREGA EL IDENTIFICADOR A CADA REGISTRO 
					BEGIN;
					UPDATE bdispei:tbldetalle
					   SET id = v_identificador
					 WHERE id  <=v_total_det;
				    COMMIT;
					
				 
                ELSE 
				 
				     --NOSE TIENEN REGISTROS A PROCESAR
				     LET v_consecutivo = v_consecutivo - 1; 
					 BEGIN;
			         UPDATE bdispei:tblfoliocoasenv SET consecutivo = v_consecutivo;
                     COMMIT; 
					 
					 BEGIN;
					 DELETE FROM bdispei:tbldetalle;
					 COMMIT; 
					 
				     LET vcodret  = '001';
			         RETURN vcodret;
				 
			   END IF; 
			 
RETURN  vcodret;
END; 
END PROCEDURE;