CREATE PROCEDURE "informix".sp_actualiza_dominio_correos(ireverso INTEGER,p_ianio_ini INTEGER, p_ianio_fin INTEGER)

    RETURNING
    CHAR(5) AS codret,
	INTEGER AS total_registros,
	DATETIME YEAR TO SECOND AS inicio,  
	DATETIME YEAR TO SECOND AS final
	;

    -- Definicion de variables
    DEFINE cCodRet           	CHAR(5);
    DEFINE iSqlErr           	INTEGER;
	DEFINE iTot_act				INTEGER;
	DEFINE dInicio				DATETIME YEAR TO SECOND;
	DEFINE dFinal				DATETIME YEAR TO SECOND;
	DEFINE dInicio2				DATETIME YEAR TO SECOND;
	DEFINE dFinal2				DATETIME YEAR TO SECOND;
	
    DEFINE iCount_dominio		INTEGER;
    DEFINE iCount           	INTEGER;
	DEFINE vnumcte				CHAR(20);
	DEFINE vcorreo_elec			CHAR(100);
	DEFINE vname_correo_elec	CHAR(100);
	DEFINE vstatus_correo		CHAR(1);
	DEFINE isecuencia			INTEGER;
	DEFINE vfecha_hora			CHAR(23);
	DEFINE vdominio				CHAR(100);
	DEFINE vdominio_ext			CHAR(100);
	DEFINE iactualizado			INTEGER;
	DEFINE vobs_correo_act		CHAR(200);
	DEFINE vobs_detalle_cambio	CHAR(200);
	DEFINE ianio				INTEGER;
	
	-- Asigna valores a variables
	LET cCodRet 		= "00000";
	LET iSqlErr 		= 0;
	LET iTot_act		= 0;
	LET iCount_dominio = 0;
	LET iCount = 0;
	LET vnumcte = '';
	LET vcorreo_elec = '';
	LET vname_correo_elec = '';
	LET vstatus_correo = '';
	LET isecuencia = 0;
	LET vfecha_hora = '';
	LET vdominio = '';
	LET vdominio_ext = '';
	LET iactualizado = 0;
	LET vobs_correo_act = '';
	LET vobs_detalle_cambio = '';
	LET dInicio = CURRENT;
	LET dFinal = CURRENT;
	LET dInicio2 = CURRENT;
	LET dFinal2 = CURRENT;
	LET ianio = 0;
	
    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, iTot_act, dInicio, dFinal;

            END IF;
        END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
        END EXCEPTION WITH RESUME;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		select 
			DBINFO('utc_to_datetime', sh_curtime) 
		into dInicio
		from sysmaster:"informix".sysshmvals;

		BEGIN WORK;
			-- ActualizaciÃ³n de los correos incompletos identificados
			IF ireverso = 1 THEN
				FOREACH WITH HOLD
					Select 
						--count(*)
						numcte, correo_elec, status_correo, secuencia
					Into
						vnumcte, vcorreo_elec, vstatus_correo, isecuencia
					From bdinteg:tmp_correos_incompletos
					where actualizado = 1
									
					IF (select count(*) 
						from informix.si_correos 
						where numcte = vnumcte 
							and status_correo = vstatus_correo 
							and secuencia = isecuencia) > 0 THEN
						
						UPDATE informix.si_correos 
						SET correo_elec = vcorreo_elec
						WHERE numcte = vnumcte 
							and status_correo = vstatus_correo 
							and secuencia = isecuencia;
						
						LET iactualizado = 0;
												
						UPDATE informix.tmp_correos_incompletos 
						SET actualizado = iactualizado, obs_correo_act = 'Se reestablece el correo', fecha_act = CURRENT
						WHERE numcte = vnumcte 
							and status_correo = vstatus_correo 
							and secuencia = isecuencia;
					END IF;
					
					LET iCount = iCount + 1;
					
					IF iCount >= 1000 THEN
						COMMIT WORK;
						BEGIN WORK;
						LET iCount = 0;
					END IF;

					-- Limpiar variables
					LET vnumcte = '';
					LET vcorreo_elec = '';
					LET vname_correo_elec = '';
					LET vstatus_correo = '';
					LET isecuencia = 0;
				END FOREACH;
			ELIF ireverso = 0 THEN
				LET ianio = p_ianio_ini;
			
				WHILE (ianio <= p_ianio_fin)
					-- Ciclo de validaciÃ³n y actualizaciÃ³n de correos con dominios incompletos
					FOREACH WITH HOLD
						Select 
							--count(*)
							numcte, correo_elec, status_correo, secuencia
						Into
							vnumcte, vcorreo_elec, vstatus_correo, isecuencia
						From bdinteg:tmp_correos_incompletos
						where anio = ianio and actualizado = 0
										
						IF (select count(*) 
							from informix.si_correos 
							where numcte = vnumcte 
								and secuencia = isecuencia 
								and status_correo = vstatus_correo) > 0 THEN
							LET iCount_dominio = 0;

							FOREACH WITH HOLD
								Select LTRIM(unnamed_col_1)
								Into vdominio
								From table (function regex_split(trim(vcorreo_elec),'@'))
								
								IF iCount_dominio > 0 THEN
									EXIT FOREACH;
								END IF;
								
								LET iCount_dominio = iCount_dominio + 1;
							END FOREACH;
							
							IF LENGTH(TRIM(vdominio)) > 0 THEN
								LET vobs_detalle_cambio = 'Dominio de correo incompleto o mal escrito';
							ELSE
								LET vobs_detalle_cambio = 'No se detecto dominio de correo';
							END IF;
							
							IF iCount_dominio > 0 THEN
								LET iCount_dominio = 0;
							
								FOREACH WITH HOLD
									Select unnamed_col_1
									Into vdominio_ext
									From table (function regex_split(trim(vdominio),'.'))
									
									IF iCount_dominio > 0 THEN
										EXIT FOREACH;
									END IF;
									
									LET iCount_dominio = iCount_dominio + 1;
								END FOREACH;
							END IF;
							
							IF iCount_dominio > 0 THEN
								IF SUBSTR(vdominio_ext,0,1) = 'c' THEN
									LET vdominio_ext = 'com';
								ELIF SUBSTR(vdominio_ext,0,1) = 'n' THEN
									LET vdominio_ext = 'net';
								ELIF SUBSTR(vdominio_ext,0,1) = 'l' THEN
									LET vdominio_ext = 'live';
								ELIF SUBSTR(vdominio_ext,0,2) = 'or' 
									OR (LENGTH(TRIM(vdominio_ext)) = 1 AND (SUBSTR(vdominio_ext,0,1) = 'o')) THEN
									LET vdominio_ext = 'org';
								ELIF SUBSTR(vdominio_ext,0,2) = 'ou' THEN
									LET vdominio_ext = 'ou';
								ELIF SUBSTR(vdominio_ext,0,1) = 'e' THEN
									LET vdominio_ext = 'es';
								ELIF SUBSTR(vdominio_ext,0,1) = 'C' THEN
									LET vdominio_ext = 'COM';
								ELIF SUBSTR(vdominio_ext,0,1) = 'N' THEN
									LET vdominio_ext = 'NET';
								ELIF SUBSTR(vdominio_ext,0,1) = 'L' THEN
									LET vdominio_ext = 'LIVE';
								ELIF SUBSTR(vdominio_ext,0,2) = 'OR' 
									OR (LENGTH(TRIM(vdominio_ext)) = 1 AND (SUBSTR(vdominio_ext,0,1) = 'O')) THEN
									LET vdominio_ext = 'ORG';
								ELIF SUBSTR(vdominio_ext,0,2) = 'OU' THEN
									LET vdominio_ext = 'OU';
								ELIF SUBSTR(vdominio_ext,0,1) = 'E' THEN
									LET vdominio_ext = 'ES';
								ELSE
									LET vdominio_ext = 'com';
								END IF;
							ELSE
								LET vdominio_ext = 'com';
							END IF;
							
							IF LENGTH(TRIM(vdominio)) > 0 THEN
								LET iactualizado = 1;
								
								IF length(TRIM(vdominio)) = 1 THEN
									IF SUBSTR(vdominio,0,1) = 'h' THEN
										LET vdominio = 'hotmail.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'g' THEN
										LET vdominio = 'gmail.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'y' THEN
										LET vdominio = 'yahoo.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'l' THEN
										LET vdominio = 'live.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'o' THEN
										LET vdominio = 'outlook.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'p' THEN
										LET vdominio = 'prodigy.net';
									ELIF SUBSTR(vdominio,0,1) = 'H' THEN
										LET vdominio = 'HOTMAIL.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'G' THEN
										LET vdominio = 'GMAIL.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'Y' THEN
										LET vdominio = 'YAHOO.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'L' THEN
										LET vdominio = 'LIVE.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'O' THEN
										LET vdominio = 'OUTLOOK.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,1) = 'P' THEN
										LET vdominio = 'PRODIGY.NET';
									ELSE
										LET iactualizado = 2;
										LET vobs_correo_act = 'No se actualiza el correo debido a que no se identifico el dominio con la primer letra.';
									END IF;
								ELSE
									IF SUBSTR(vdominio,0,2) = 'ho' THEN
										LET vdominio = 'hotmail.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'gm' THEN
										LET vdominio = 'gmail.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'ya' THEN
										LET vdominio = 'yahoo.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'li' THEN
										LET vdominio = 'live.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'ou' THEN
										LET vdominio = 'outlook.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'pr' THEN
										LET vdominio = 'prodigy.net';
									ELIF SUBSTR(vdominio,0,2) = 'HO' THEN
										LET vdominio = 'HOTMAIL.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'GM' THEN
										LET vdominio = 'GMAIL.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'YA' THEN
										LET vdominio = 'YAHOO.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'LI' THEN
										LET vdominio = 'LIVE.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'OU' THEN
										LET vdominio = 'OUTLOOK.' || TRIM(vdominio_ext);
									ELIF SUBSTR(vdominio,0,2) = 'PR' THEN
										LET vdominio = 'PRODIGY.NET';
									ELSE
										LET iactualizado = 3;
										LET vobs_correo_act = 'No se actualiza el correo debido a que no se identifico el dominio con las 2 primeras letras.';
									END IF;
								END IF;
								
								IF iactualizado = 1 THEN
									Select Limit 1 unnamed_col_1 
									Into vname_correo_elec
									From table (function regex_split(trim(vcorreo_elec),'@'));
									
									LET vcorreo_elec = trim(vname_correo_elec) || '@' || trim(vdominio);
									LET vobs_correo_act = 'Correo actualizado: ' || trim(vcorreo_elec);
									
									UPDATE informix.si_correos 
									SET correo_elec = vcorreo_elec
									WHERE numcte = vnumcte 
										and secuencia = isecuencia;
								END IF;
								
							ELSE
								LET iactualizado = 4;
								LET vobs_correo_act = 'No se actualiza el correo debido a que no se identifico el dominio.';
							END IF
						ELSE
							LET iactualizado = 5;
							LET vobs_correo_act = 'No se actualiza el correo debido a que el registro a actualizar cambio.';
						END IF;
						
						UPDATE informix.tmp_correos_incompletos 
						SET actualizado = iactualizado, obs_correo_act = vobs_correo_act, obs_detalle_cambio = vobs_detalle_cambio, fecha_act = CURRENT
						WHERE numcte = vnumcte and secuencia = isecuencia;
						
						LET iTot_act = iTot_act + 1;
						LET iCount = iCount + 1;
						
						IF iCount >= 1000 THEN
							COMMIT WORK;
							BEGIN WORK;
							LET iCount = 0;
						END IF;

						-- Limpiar variables
						LET vnumcte = '';
						LET vcorreo_elec = '';
						LET vname_correo_elec = '';
						LET vstatus_correo = '';
						LET isecuencia = 0;
						LET vfecha_hora = '';
						LET vdominio = '';
						LET vdominio_ext = '';
						LET iactualizado = 0;
						LET vobs_correo_act = '';
						LET vobs_detalle_cambio = '';
					
					END FOREACH;
					
					LET ianio = ianio + 1;
				END WHILE;
			END IF;
		
		COMMIT WORK;
		
		select 
			MAX(DBINFO('utc_to_datetime', sh_curtime))
		into dFinal
		from sysmaster:"informix".sysshmvals;

		RETURN cCodRet, iTot_act, dInicio, dFinal;
	
	END
END PROCEDURE
DOCUMENT
'AUTOR: Uriel Amador Islas',
'DESCRIPCION: Se encarga de verificar y de actualizar los dominos de correos mal escritos o incompletos',
'FECHA: 24/01/2025',
'BD: bdisac';

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