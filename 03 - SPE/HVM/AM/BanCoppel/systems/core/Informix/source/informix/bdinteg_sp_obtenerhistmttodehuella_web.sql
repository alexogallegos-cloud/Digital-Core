CREATE PROCEDURE "informix".sp_obtenerhistmttodehuella_web(i16Tipo SMALLINT, cSucursal CHAR(4), dFecha DATE, dFechaFin DATE, cNumEmpleado CHAR(8),
											cNumEmpleado2 CHAR(8), i16Registros SMALLINT)
--Se borra el sp con mayúsculas y se reemplaza por solo minusculas

----------------------------------------------------------------------
-- Modificó  : Nancy Sevilla Camacho
-- Actividad : Se realiza búsqueda por un rango de fechas
-- Solicitó  : Rodolfo Gómez
-- Fecha     : 11/Junio/2012
----------------------------------------------------------------------

	RETURNING CHAR(5), CHAR(10), CHAR(5), CHAR(20), CHAR(104), CHAR(8), CHAR(8), CHAR(8);

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFechaHora CHAR(25);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(5);
	DEFINE cNumCte CHAR(20);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cNombreCompleto CHAR(104);
	DEFINE cEmpleado CHAR(8);
	DEFINE cOperador CHAR(8);
	DEFINE cUsuario CHAR(8);
	DEFINE i16Contador SMALLINT;
	DEFINE iContador SMALLINT;
	DEFINE iRegistros SMALLINT;
	--11/Junio/2012	
    --DEFINE cfechaini char(20);
    --DEFINE cfechafin char(20);	
	DEFINE dFechaIni DATETIME YEAR TO SECOND;
	DEFINE dFechaFin2 DATETIME YEAR TO SECOND;	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cFechaHora = '';
	LET cFecha = '';
	LET cHora = '';
	LET cNumCte = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cNombreCompleto = '';
	LET cEmpleado = '';
	LET cOperador = '';
	LET cUsuario = '';
	LET i16Contador = 0;
	LET iContador = 0;
	LET iRegistros = i16Registros;
	--11/Junio/2012	
    --let cfechaini = '';
    --let cfechafin = '';
    LET dFechaIni = '1900-01-01 00:00:00';
    LET dFechaFin2 = '1900-01-01 00:00:00';	

	--SET DEBUG FILE TO "/informix/Aracely/sp_obtenerhistmttodehuella_web.out";
    --TRACE ON;	

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
					NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        LET dFechaIni = YEAR(dFecha)||'-'||LPAD(MONTH(dFecha),2,0)||'-'||LPAD(DAY(dFecha),2,0)||' 00:00:00';
		 --11/Junio/2012		 
         --let cfechafin = year(dfecha)||'-'||lpad(month(dfecha),2,0)||'-'||lpad(day(dfecha),2,0)||' 23:59:59';
        LET dFechaFin2 = YEAR(dFechaFin)||'-'||LPAD(MONTH(dFechaFin),2,0)||'-'||LPAD(DAY(dFechaFin),2,0)||' 23:59:59';		 

		IF i16Tipo = 1 THEN
			IF ( SELECT DISTINCT count(*) FROM bdinteg:"informix".si_huella_temp a
                 WHERE a.fecha_alta >= dFechaIni
                   AND a.fecha_alta <= dFechaFin2	
				   AND a.sucursal = cSucursal 
				   AND a.status = 'A') > 0  THEN 
					FOREACH
						SELECT DISTINCT a.fecha_alta, a.numcte,  a.empleado, a.operador, a.usuario3
						INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
						FROM bdinteg:"informix".si_huella_temp a
						WHERE a.fecha_alta >= dFechaIni
						AND a.fecha_alta <= dFechaFin2	
						AND a.sucursal = cSucursal 
						AND a.status = 'A'
						  
						SELECT b.apell_paterno, b.apell_materno, b.nombre1, b.nombre2
						INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
						FROM bdinteg:"informix".si_cliente b
						WHERE b.numcte = cNumCte;

						LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
						LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
						LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
											TRIM(NVL(cNombre2,'')) || ' ' ||
											TRIM(NVL(cApellPaterno,'')) || ' ' ||
											TRIM(NVL(cApellMaterno,''));

						LET i16Contador = i16Contador + 1;
						IF i16Contador <= i16Registros THEN
							CONTINUE FOREACH;
						END IF;	
						
						RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
						
					END FOREACH;
					--EXISTEN REGISTROS EN LA TABLA DE 2 HUELLAS
					--VALIDAR SI EXISTEN EN LA TABLA DE 10 HUELLAS
					IF ( SELECT DISTINCT count(*) FROM bdinteg:"informix".si_cte_huella_dec_temp c
					WHERE c.fecha >= dFechaIni
					   AND c.fecha <= dFechaFin2	
					   AND c.sucursal = cSucursal 
					   AND c.status = 'A') > 0 THEN 
							FOREACH
							
							SELECT DISTINCT c.fecha, c.numcte, c.empleado, c.user_insert, c.usuario3
							INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
							FROM bdinteg:"informix".si_cte_huella_dec_temp c
							WHERE c.fecha >= dFechaIni
							AND c.fecha <= dFechaFin2	
							AND c.sucursal = cSucursal 
							AND c.status = 'A'
							--OBTENER FECHA_INSERT
							SELECT e.fecha_insert INTO cFechaHora
							FROM bdinteg:"informix".si_cte_huella_dec_temp e
							WHERE e.numcte = cNumCte
							AND e.sucursal = cSucursal 
							AND e.status = 'A' LIMIT 1;
							  
							SELECT d.apell_paterno, d.apell_materno, d.nombre1, d.nombre2
							INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
							FROM bdinteg:"informix".si_cliente d
							WHERE d.numcte = cNumCte;

							LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
							LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
							LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
												TRIM(NVL(cNombre2,'')) || ' ' ||
												TRIM(NVL(cApellPaterno,'')) || ' ' ||
												TRIM(NVL(cApellMaterno,''));

							LET iContador = iContador + 1;
							IF iContador <= iRegistros THEN
								CONTINUE FOREACH;
							END IF;

							RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
								NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
						END FOREACH;							
					END IF;
			ELSE
			--NO EXISTEN REGISTROS EN LA TABLA DE 2 HUELLAS
			--VALIDAR SI EXISTEN REGISTROS EN LA TABLA DE 10 HUELLAS
				IF ( SELECT DISTINCT count (*) FROM bdinteg:"informix".si_cte_huella_dec_temp c
					WHERE c.fecha >= dFechaIni
					   AND c.fecha <= dFechaFin2	
					   AND c.sucursal = cSucursal 
					   AND c.status = 'A') > 0 THEN 
							FOREACH
							SELECT DISTINCT c.fecha, c.numcte,  c.empleado, c.user_insert, c.usuario3
							INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
							FROM bdinteg:"informix".si_cte_huella_dec_temp c
							WHERE c.fecha >= dFechaIni
							AND c.fecha <= dFechaFin2	
							AND c.sucursal = cSucursal 
							AND c.status = 'A'
							
							--OBTENER FECHA_INSERT
							SELECT e.fecha_insert INTO cFechaHora
							FROM bdinteg:"informix".si_cte_huella_dec_temp e
							WHERE e.numcte = cNumCte
							AND e.sucursal = cSucursal 
							AND e.status = 'A' LIMIT 1;
							  
							SELECT d.apell_paterno, d.apell_materno, d.nombre1, d.nombre2
							INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
							FROM bdinteg:"informix".si_cliente d
							WHERE d.numcte = cNumCte;

							LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
							LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
							LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
												TRIM(NVL(cNombre2,'')) || ' ' ||
												TRIM(NVL(cApellPaterno,'')) || ' ' ||
												TRIM(NVL(cApellMaterno,''));

							LET iContador = iContador + 1;
							IF iContador <= iRegistros THEN
								CONTINUE FOREACH;
							END IF;

							RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
								NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
						END FOREACH;
					ELSE
						LET  cCodRet = '00001';
						RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
					END IF;				
			END IF;
			
		ELIF i16Tipo = 2 THEN
			IF (SELECT DISTINCT count(*) FROM bdinteg:"informix".si_huella_temp a 
			WHERE a.fecha_alta >= dFechaIni 
			AND a.fecha_alta <= dFechaFin2 
			AND a.sucursal = cSucursal  
			AND a.status = 'A' 
			AND a.empleado = cNumEmpleado) > 0 THEN
				FOREACH
					SELECT DISTINCT a.fecha_alta, a.numcte, a.empleado, a.operador, a.usuario3
					INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
					FROM bdinteg:"informix".si_huella_temp a
					WHERE a.fecha_alta >= dFechaIni
					AND a.fecha_alta <= dFechaFin2	
					AND a.sucursal = cSucursal 
					AND a.status = 'A'
					AND a.empleado = cNumEmpleado
					
					
					SELECT b.apell_paterno, b.apell_materno, b.nombre1, b.nombre2
					INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
					FROM bdinteg:"informix".si_cliente b
					WHERE b.numcte = cNumCte;				

					LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
					LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
					LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
										TRIM(NVL(cNombre2,'')) || ' ' ||
										TRIM(NVL(cApellPaterno,'')) || ' ' ||
										TRIM(NVL(cApellMaterno,''));

					LET i16Contador = i16Contador + 1;
					IF i16Contador <= i16Registros THEN
						CONTINUE FOREACH;
					END IF;
					
					RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
					NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
					
				END FOREACH;
				
				--EXISTEN REGISTROS EN LA TABLA DE 2 HUELLAS
				--VALIDAR SI EXISTEN EN LA TABLA DE 10 HUELLAS
				IF (SELECT DISTINCT count(*) FROM bdinteg:"informix".si_cte_huella_dec_temp c 
				WHERE c.fecha >= dFechaIni 
				AND c.fecha <= dFechaFin2 
				AND c.sucursal = cSucursal  
				AND c.status = 'A' 
				AND c.empleado = cNumEmpleado) > 0 THEN
					FOREACH
						SELECT DISTINCT c.fecha, c.numcte, c.empleado, c.user_insert, c.usuario3
						INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
						FROM bdinteg:"informix".si_cte_huella_dec_temp c
						WHERE c.fecha >= dFechaIni
						AND c.fecha <= dFechaFin2	
						AND c.sucursal = cSucursal 
						AND c.status = 'A'
						AND c.empleado = cNumEmpleado
						
						--OBTENER FECHA_INSERT
						SELECT e.fecha_insert INTO cFechaHora
						FROM bdinteg:"informix".si_cte_huella_dec_temp e
						WHERE e.numcte = cNumCte
						AND e.sucursal = cSucursal 
						AND e.empleado = cNumEmpleado
						AND e.status = 'A' LIMIT 1;
						
						SELECT d.apell_paterno, d.apell_materno, d.nombre1, d.nombre2
						INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
						FROM bdinteg:"informix".si_cliente d
						WHERE d.numcte = cNumCte;				

						LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
						LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
						LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
											TRIM(NVL(cNombre2,'')) || ' ' ||
											TRIM(NVL(cApellPaterno,'')) || ' ' ||
											TRIM(NVL(cApellMaterno,''));

						LET iContador = iContador + 1;
						IF iContador <= i16Registros THEN
							CONTINUE FOREACH;
						END IF;

						RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
							NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
					END FOREACH;
				END IF;			
			ELSE
			--NO EXISTEN REGISTROS EN LA TABLA DE 2 HUELLAS
			--VALIDAR SI EXISTEN REGISTROS EN LA TABLA DE 10 HUELLAS
				IF (SELECT DISTINCT count (*) FROM bdinteg:"informix".si_cte_huella_dec_temp c 
				WHERE c.fecha >= dFechaIni 
				AND c.fecha <= dFechaFin2 
				AND c.sucursal = cSucursal  
				AND c.status = 'A' 
				AND c.empleado = cNumEmpleado) > 0 THEN
					FOREACH
						SELECT DISTINCT c.fecha, c.numcte, c.empleado, c.user_insert, c.usuario3
						INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
						FROM bdinteg:"informix".si_cte_huella_dec_temp c
						WHERE c.fecha >= dFechaIni
						AND c.fecha <= dFechaFin2	
						AND c.sucursal = cSucursal 
						AND c.status = 'A'
						AND c.empleado = cNumEmpleado
						
						--OBTENER FECHA_INSERT
						SELECT e.fecha_insert INTO cFechaHora
						FROM bdinteg:"informix".si_cte_huella_dec_temp e
						WHERE e.numcte = cNumCte
						AND e.sucursal = cSucursal 
						AND e.empleado = cNumEmpleado
						AND e.status = 'A' LIMIT 1;
						
						SELECT d.apell_paterno, d.apell_materno, d.nombre1, d.nombre2
						INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
						FROM bdinteg:"informix".si_cliente d
						WHERE d.numcte = cNumCte;				

						LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
						LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
						LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
											TRIM(NVL(cNombre2,'')) || ' ' ||
											TRIM(NVL(cApellPaterno,'')) || ' ' ||
											TRIM(NVL(cApellMaterno,''));

						LET iContador = iContador + 1;
						IF iContador <= i16Registros THEN
							CONTINUE FOREACH;
						END IF;

						RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
							NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
					END FOREACH;
				ELSE
					LET  cCodRet = '00001';
					RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
							NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
				END IF;			
			END IF;
		ELIF i16Tipo = 3 THEN
			IF (SELECT DISTINCT count (*) FROM bdinteg:"informix".si_huella_temp a
					WHERE a.fecha_alta >= dFechaIni
					AND a.fecha_alta <= dFechaFin2	
					AND a.sucursal = cSucursal 
					AND a.status = 'A'
					AND a.empleado BETWEEN cNumEmpleado AND cNumEmpleado2) > 0 THEN 
					FOREACH
						SELECT DISTINCT a.fecha_alta, a.numcte, a.empleado, a.operador, a.usuario3
						INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
						FROM bdinteg:"informix".si_huella_temp a
						WHERE a.fecha_alta >= dFechaIni
						AND a.fecha_alta <= dFechaFin2	
						AND a.sucursal = cSucursal 
						AND a.status = 'A'
						AND a.empleado BETWEEN cNumEmpleado AND cNumEmpleado2
						
						SELECT b.apell_paterno, b.apell_materno, b.nombre1, b.nombre2
						INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
						FROM bdinteg:"informix".si_cliente b
						WHERE b.numcte = cNumCte;					

						LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
						LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
						LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
											TRIM(NVL(cNombre2,'')) || ' ' ||
											TRIM(NVL(cApellPaterno,'')) || ' ' ||
											TRIM(NVL(cApellMaterno,''));

						LET i16Contador = i16Contador + 1;
						IF i16Contador <= i16Registros THEN
							CONTINUE FOREACH;
						END IF;

						RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
					END FOREACH;
					--EXISTEN REGISTROS EN LA TABLA DE 2 HUELLAS
					--VALIDAR SI EXISTEN EN LA TABLA DE 10 HUELLAS
					IF (SELECT DISTINCT count (*) FROM bdinteg:"informix".si_cte_huella_dec_temp a
					WHERE c.fecha >= dFechaIni
					AND c.fecha <= dFechaFin2	
					AND c.sucursal = cSucursal 
					AND c.status = 'A'
					AND c.empleado BETWEEN cNumEmpleado AND cNumEmpleado2) > 0 THEN 
						FOREACH
							SELECT DISTINCT c.fecha, c.numcte, c.empleado, c.user_insert, c.usuario3
							INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
							FROM bdinteg:"informix".si_cte_huella_dec_temp a
							WHERE c.fecha >= dFechaIni
							AND c.fecha <= dFechaFin2	
							AND c.sucursal = cSucursal 
							AND c.status = 'A'
							AND c.empleado BETWEEN cNumEmpleado AND cNumEmpleado2
							
							SELECT d.apell_paterno, d.apell_materno, d.nombre1, d.nombre2
							INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
							FROM bdinteg:"informix".si_cliente d
							WHERE d.numcte = cNumCte;					

							LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
							LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
							LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
												TRIM(NVL(cNombre2,'')) || ' ' ||
												TRIM(NVL(cApellPaterno,'')) || ' ' ||
												TRIM(NVL(cApellMaterno,''));

							LET i16Contador = i16Contador + 1;
							IF i16Contador <= i16Registros THEN
								CONTINUE FOREACH;
							END IF;

							RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
								NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
						END FOREACH;
				END IF;					
			ELSE
			--NO EXISTEN REGISTROS EN LA TABLA DE 2 HUELLAS
			--VALIDAR SI EXISTEN REGISTROS EN LA TABLA DE 10 HUELLAS
				IF (SELECT DISTINCT count (*) FROM bdinteg:"informix".si_cte_huella_dec_temp a
					WHERE c.fecha >= dFechaIni
					AND c.fecha <= dFechaFin2	
					AND c.sucursal = cSucursal 
					AND c.status = 'A'
					AND c.empleado BETWEEN cNumEmpleado AND cNumEmpleado2) > 0 THEN 
						FOREACH
							SELECT DISTINCT c.fecha, c.numcte, c.empleado, c.user_insert, c.usuario3
							INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
							FROM bdinteg:"informix".si_cte_huella_dec_temp a
							WHERE c.fecha >= dFechaIni
							AND c.fecha <= dFechaFin2	
							AND c.sucursal = cSucursal 
							AND c.status = 'A'
							AND c.empleado BETWEEN cNumEmpleado AND cNumEmpleado2
							
							SELECT d.apell_paterno, d.apell_materno, d.nombre1, d.nombre2
							INTO cApellPaterno, cApellMaterno, cNombre1, cNombre2
							FROM bdinteg:"informix".si_cliente d
							WHERE d.numcte = cNumCte;					

							LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
							LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
							LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
												TRIM(NVL(cNombre2,'')) || ' ' ||
												TRIM(NVL(cApellPaterno,'')) || ' ' ||
												TRIM(NVL(cApellMaterno,''));

							LET iContador = iContador + 1;
							IF iContador <= i16Registros THEN
								CONTINUE FOREACH;
							END IF;

							RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
								NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
						END FOREACH;
				ELSE
					LET  cCodRet = '00001';
					RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
							NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
				END IF;
			END IF;
		END IF;
	END;

END PROCEDURE;