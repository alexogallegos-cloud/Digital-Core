CREATE PROCEDURE "informix".sp_automasolcobranza() 
												 
   returning CHAR(5);

--******************************************************************************************
-- Define variables
--******************************************************************************************
	DEFINE cod_ret       CHAR(5);
	DEFINE sql_err       INTEGER;
	DEFINE vIdEmp		 INTEGER;
	DEFINE vEmpleadoCob  CHAR(8); 
	DEFINE vNombreEmpCob CHAR(78);
	DEFINE vPendientes	 INTEGER;
	DEFINE vRechazadas	 INTEGER;
    DEFINE cValor        CHAR(20);
	
	
--******************************************************************************************
-- Inicializa variables
--******************************************************************************************
   LET cod_ret		 = '00000';
   LET sql_err		 = 0;
   LET vIdEmp		 = 0;
   LET vEmpleadoCob  = '';
   LET vNombreEmpCob = '';
   LET vPendientes	 = 0;
   LET vRechazadas	 = 0;
   LET cValor        = '';

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
   
	--SET DEBUG FILE TO 'sp_AutomaSolCobranza.out';
	--TRACE ON ;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    SELECT valor 
    INTO cValor
    FROM bdisolic:ss_param
    WHERE secuencia = 393;
	
	FOREACH 
		
		SELECT empleado_cob, nombre, (sol_entregadas - sol_capturadas - sol_rechazadas), sol_rechazadas
			INTO vEmpleadoCob,vNombreEmpCob, vPendientes, vRechazadas
			FROM "informix".pr_monitorconcilia
			WHERE sucursal = '0800' AND fecha_solmasivas = TODAY-1		
		
			UPDATE "informix".pr_monitorconcilia 
			SET sol_rechazadas = (vPendientes + vRechazadas)
			WHERE empleado_cob = vEmpleadoCob AND fecha_solmasivas = TODAY-1;
			
			-- Se agrega validaciÃ²n para los dÃ­as no laborables en el banco JLM 30/12/2019
			IF (SELECT COUNT(*) FROM bdinteg:si_feriado WHERE fecha = today and laborable = 'N') >  0 THEN
		
			INSERT INTO "informix".pr_monitorconcilia (empleado_cob, nombre, fecha_solmasivas, ejecutivo,fecha_insert, sucursal,sol_entregadas)
				VALUES (vEmpleadoCob, vNombreEmpCob, TODAY, '0', CURRENT, '0800', cValor);
				
			INSERT INTO "informix".pr_monitorconcilia (empleado_cob, nombre, fecha_solmasivas, ejecutivo,fecha_insert, sucursal,sol_entregadas)
				VALUES (vEmpleadoCob, vNombreEmpCob, TODAY+1, '0', CURRENT, '0800', cValor);
				
			ELSE 
					INSERT INTO "informix".pr_monitorconcilia (empleado_cob, nombre, fecha_solmasivas, ejecutivo,fecha_insert, sucursal,sol_entregadas)
						VALUES (vEmpleadoCob, vNombreEmpCob, TODAY, '0', CURRENT, '0800', cValor);
			END IF;
		
		
    END FOREACH;

    END
    
    RETURN cod_ret;
    
END PROCEDURE;