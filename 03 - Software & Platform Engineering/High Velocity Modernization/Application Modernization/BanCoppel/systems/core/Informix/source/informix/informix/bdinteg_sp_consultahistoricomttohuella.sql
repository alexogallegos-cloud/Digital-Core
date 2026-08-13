CREATE PROCEDURE "informix".sp_consultahistoricomttohuella( pempresa CHAR(3),pnumcte CHAR(11))
	RETURNING CHAR(5), CHAR(10), CHAR(10), CHAR(4), CHAR(8), CHAR(30), CHAR(8), CHAR(30), CHAR(8), CHAR(30);
	--************************************
	--sp_consultahistoricomttohuella
	--objetivo: Obtener los datos de huella para el reporte histÃÂ³rico del mantenimiento huella
	--Autor: Daniel Ignacio ChÃÂ¡vez Valenzuela
	--Fecha: 05/Mayo/2010
	--
	-- ModificaciÃÂ³n: Se formateÃÂ³ la fecha de movimientos a dd-MM-aaaa;
	-- ModificÃÂ³: Ulises RodrÃÂ­guez.
	-- Fecha: 01/Junio/2010.
	--****************************************
	--Declaracion de Variables
	DEFINE vsCodRet 		CHAR(5);
	DEFINE vSqlErr			INTEGER;
	--Datos histÃÂ³rico del mantenimiento de huella
	DEFINE vfechamtto		CHAR(10);	--Fecha del mantenimiento de huella
	DEFINE vhora			CHAR(10); 	--Hora del mantenimiento de huella
	DEFINE vnumsucursal 	CHAR(4); 	--NÃÂºmero de sucursal en donde se realizÃÂ³ el mantenimiento
	DEFINE vnumempejecuto	CHAR(8);  	--NÃÂºmero de empleado que solicitÃÂ³ el cambio de huella
	DEFINE vnomempejecuto	CHAR(30);	--Empleado que solicitÃÂ³ el cambio de huella
	DEFINE vnumempautorizo	CHAR(8);  	--NÃÂºmero de empleado que autorizÃÂ³ el cambio de huella
	DEFINE vnomempautorizo	CHAR(30);	--Empleado que autorizÃÂ³ el cambio de huella
	DEFINE vnumempcaja		CHAR(8);  	--NÃÂºmero de empleado que realizÃÂ³ el cambio de huella
	DEFINE vnomempcaja		CHAR(30);	--Empleado que realizÃÂ³ el cambio de huella
	DEFINE vfechamttoaux	DATE;
	DEFINE vDia char(2);
	DEFINE vMes char(2);
	DEFINE vAnio char(4);
	
	--AsignaciÃÂ³n de Valores a Variables
	
	LET vsCodRet = '00000';
	LET vSqlErr = 0;

	LET vfechamtto = "1900-01-01";	
	LET vhora = "";
	LET vnumsucursal = "";
	LET vnumempejecuto = "";
	LET vnomempejecuto = "";
	LET vnumempautorizo = "";
	LET vnomempautorizo = "";
	LET vnumempcaja = "";
	LET vnomempcaja = "";
	LET vfechamttoaux = mdy(1, 1, 1900);
	LET vDia = "";
	LET vMes = "";
	LET vAnio = "";
	
	--SET DEBUG FILE TO  "/tmp/vladi/sp_consultahistoricomttohuella.out"; 
	--TRACE ON;
	--SET DEBUG FILE TO "/informix/1170/ORO/SPS/sp_consultahistoricomttohuella.out";
	--TRACE ON;
	BEGIN
	
	--SET LOCK MODE TO WAIT 3;
	--SET ISOLATION TO DIRTY READ;
	
	
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
				--ROLLBACK WORK;
				
	            RETURN vsCodRet, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
	      END IF;		
		
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF (pnumcte<> "" OR pnumcte IS NOT NULL)THEN
        
            DROP TABLE IF EXISTS temp_si_huella_temp;
			
			CREATE TEMP TABLE temp_si_huella_temp
				(numcte     CHAR(20),
				fecha_alta DATETIME YEAR to SECOND,
				sucursal	CHAR(4),
				operador	CHAR(8),
				empleado	CHAR(8),
				usuario3	CHAR(8)) with no log;
				
			CREATE INDEX numcte_2
				ON temp_si_huella_temp(numcte);	

            INSERT INTO temp_si_huella_temp  
                Select * FROM(
                    SELECT  b.numcte, b.fecha_alta, b.sucursal,  b.operador, b.empleado ,b.usuario3 
                    FROM si_cliente a
                    LEFT OUTER JOIN si_huella_temp b ON (a.numcte = b.numcte) 
                    WHERE a.numcte = TRIM(pnumcte)
                );

            INSERT INTO temp_si_huella_temp  
                Select * FROM(
                    SELECT  b.numcte, b.fecha_alta, b.sucursal,  b.operador, b.empleado ,b.usuario3
                    FROM si_cliente a
                    LEFT OUTER JOIN si_huella_temp_hist2018 b ON (a.numcte = b.numcte) 
                    WHERE a.numcte = TRIM(pnumcte)
                );

			
			FOREACH
				
				SELECT fecha_alta AS fecha, SUBSTR (fecha_alta, 11,19) AS  hora, sucursal, operador AS empleado_ejecuto, 
				empleado AS empleado_autoriza, usuario3 AS empleado_caja
				INTO vfechamttoaux, vhora, vnumsucursal, vnumempejecuto, vnumempautorizo,vnumempcaja
				FROM temp_si_huella_temp
				WHERE fecha_alta is not null 
				and SUBSTR (fecha_alta, 11,19) is not null 
				and sucursal is not null 
				and operador is not null 
				and empleado is not null 
				and usuario3 is not null
				and numcte = TRIM(pnumcte)

				IF ( vfechamttoaux IS NOT NULL) THEN
				
					LET vDia = LPAD(day(vfechamttoaux),2,'0');
					LET vMes = LPAD(MONTH(vfechamttoaux),2,'0');
					LET vAnio = YEAR(vfechamttoaux);
					LET vfechamtto = vAnio || '-' || vMes || '-' || vDia;
				
				END IF;
				
				SELECT nombre INTO vnomempautorizo FROM bdinteg:si_ejecut WHERE ejecutivo = vnumempautorizo;
				SELECT nombre INTO vnomempcaja FROM bdinteg:si_ejecut WHERE ejecutivo = vnumempcaja;
				SELECT nombre INTO vnomempejecuto FROM bdinteg:si_ejecut WHERE ejecutivo = vnumempejecuto;
				
				RETURN vsCodRet, vfechamtto, vhora, vnumsucursal, vnumempejecuto, vnomempejecuto, vnumempautorizo, vnomempautorizo, vnumempcaja, 
					   vnomempcaja  WITH RESUME;
				
			END FOREACH
				
		ELSE
			LET vsCodRet='00001';
			RETURN vsCodRet, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
		END IF;
		
	END;
END PROCEDURE;