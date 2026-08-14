CREATE PROCEDURE "informix".sp_cons_sd_cte ( pcuenta_eje CHAR(20))
RETURNING CHAR(5), CHAR(1);

	DEFINE vexistencia						CHAR (1);
   	DEFINE vsqlerr          				INTEGER;
    DEFINE iisamerr         				SMALLINT;
    DEFINE cerrorinfo       				CHAR(80);
	DEFINE verrorinfo       				CHAR(80);
    DEFINE vcodret         					CHAR(5);
	DEFINE vcuenta_eje						CHAR(11);
	DEFINE vcta_exis						SMALLINT;
	DEFINE vproducto						SMALLINT;
	DEFINE vestatus							SMALLINT;
	DEFINE vcant_sd							SMALLINT;

	
	LET vexistencia								= "1";
    LET vsqlerr         					= 0; 
    LET iisamerr         					= 0;
    LET cerrorinfo       					= "";   
   	LET verrorinfo        					= "INICIO DEL PROCESO";
	LET vcodret								= "00000";
	LET vcuenta_eje							= '';
	LET vcta_exis							= 0; 
	LET vproducto							= 0;
	LET vestatus							= 0;
	LET vcant_sd							= 0;
	
    BEGIN
	ON EXCEPTION SET vsqlerr, iisamerr, cerrorinfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cons_sd_cte.txt";
	 	    TRACE ON;
			LET vcodret    = vsqlerr;
            LET verrorinfo = cerrorinfo;
			LET vcuenta_eje= pcuenta_eje;
	        --RETURN vcodret;
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/c90186322/abc.err.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  

 --SE OPTIENE LOS VALORES DE LA CUENTA EJE	
    SELECT TRIM(cuenta), producto,  status_cta
    INTO   vcuenta_eje,  vproducto, vestatus
    FROM   bdicheq:sc_maechq
    WHERE  cuenta = pcuenta_eje;

	--SE VALIDA QUE LA CUENTA EJE EXISTA
    IF    vcuenta_eje IS NOT NULL OR vcuenta_eje <> "" THEN
	
	      --SE VALIDA EL ESTATUS DE LA CUENTA 
	    IF  vestatus =  "1"THEN 
		
		     --SE VALIDA QUE ELPRODUCTO ENTRE DENTRO LOS PARTICIPANTES
		   -- IF  vproducto IN ("1300","1400","1700","1800","1900","2000","2400","2500","2900") THEN 
			IF vproducto in (select producto from sc_prodis_sd) THEN
			
					--Verifica si la cuenta tiene sobres digitales
				SELECT COUNT(cuenta_eje) 
				INTO vcant_sd
				FROM sc_mae_sd
				WHERE cuenta_eje=pcuenta_eje;
	
				IF vcant_sd > '0' THEN
			
					LET vexistencia='0';
					LEt vcodRet='00000';
			
				ELSE
				LET vcodRet='00018'; -- la cuenta no tiene sobres '
				END IF;			
			ELSE 
			LET vcodret='00003'; --producto no participante
			END IF;
		ELSE
		LET vcodret='00002'; --estatus no valido
		END IF;
	ELSE 
	LET vcodret='00001'; -- la cuenta no existe dentro de la BD
	END IF;
	

	RETURN vcodret, vexistencia;
	END;
	END PROCEDURE;