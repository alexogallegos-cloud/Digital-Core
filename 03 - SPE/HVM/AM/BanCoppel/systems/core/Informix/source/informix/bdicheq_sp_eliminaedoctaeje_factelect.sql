CREATE PROCEDURE "informix".sp_eliminaedoctaeje_factelect (dFechaEmision date)
RETURNING   CHAR(5);
            

DEFINE vsqlerr           INTEGER;
DEFINE vcodret           CHAR(5);
DEFINE v_cuenta          CHAR(20); 

DEFINE v_fecha_concentra DATE;
DEFINE v_exi_registro    INTEGER; 
DEFINE vsql              CHAR(500);


LET vsqlerr              = 0; 
LET vcodret              = "000";
LET v_cuenta             = '';
LET vsql                 = '';

BEGIN
	 ON EXCEPTION SET vsqlerr
	    SET DEBUG FILE TO "/resplogifx/conciliachq/elimina.err";
	 	    TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
	        RETURN vcodret;
            END IF;
     END EXCEPTION;
	 
    -- SET DEBUG FILE TO '/informix/rsv/avance_sorteo_efectivo/sorteo.txt';
	--SET DEBUG FILE TO '/informix/rsv/borra/borra.out';
	---TRACE ON;
	 
	 
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
		
	CREATE TABLE "informix".ctasxprocesar_elimina( cuenta char(20) not null )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasxprocesar_elimina ON "informix".ctasxprocesar_elimina(cuenta) USING BTREE;
	
	LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentasxprocesar.unl INSERT INTO ctasxprocesar_elimina" > /resplogifx/conciliachq/ctasxproc_eli.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxproc_eli.sql'; 
    SYSTEM vsql;
    LET vsql = '';
	
	UPDATE STATISTICS HIGH FOR TABLE ctasxprocesar_elimina;
		
	
    FOREACH WITH HOLD
	
          SELECT cuenta
            INTO v_cuenta	  
	    	FROM ctasxprocesar_elimina
			 			 

           BEGIN WORK;
 
		  SELECT COUNT(*)
		    INTO v_exi_registro
		    FROM sc_encabezado_edocta_factelect
		   WHERE fecha_emision = dFechaEmision
			 AND num_cuenta    = v_cuenta; 
			 
			 
			 IF v_exi_registro > 0 THEN 
			 
			    DELETE FROM sc_encabezado_edocta_factelect  WHERE fecha_emision = dFechaEmision  AND num_cuenta = v_cuenta; 
				DELETE FROM sc_encabezado2_edocta_factelect WHERE fecha_emision = dFechaEmision  AND num_cuenta = v_cuenta; 
				DELETE FROM sc_piepagina_edocta_factelect   WHERE fecha_emision = dFechaEmision  AND num_cuenta = v_cuenta; 
				DELETE FROM sc_mensajes_edocta_factelect    WHERE fecha_emision = dFechaEmision  AND num_cuenta = v_cuenta; 
		        DELETE FROM sc_grafica_fe                   WHERE fecha_emision = dFechaEmision  AND num_cuenta = v_cuenta; 
			    DELETE FROM sc_detalle_edocta_factelect     WHERE fecha_emision = dFechaEmision  AND num_cuenta = v_cuenta; 
			END IF 

         COMMIT WORK;
         			 
	END FOREACH; 
			
		  DROP TABLE  "informix".ctasxprocesar_elimina;
	
RETURN  vcodret;
END; 
END PROCEDURE;