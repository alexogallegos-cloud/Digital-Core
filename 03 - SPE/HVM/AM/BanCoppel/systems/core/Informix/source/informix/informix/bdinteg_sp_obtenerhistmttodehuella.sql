CREATE PROCEDURE "informix".sp_obtenerhistmttodehuella(i16Tipo SMALLINT, cSucursal CHAR(4), dFecha DATE, dFechaFin DATE, cNumEmpleado CHAR(8),
											cNumEmpleado2 CHAR(8), i16Registros SMALLINT)
--Se borra el sp con mayÃºsculas y se reemplaza por solo minusculas

----------------------------------------------------------------------
-- ModificÃ³  : Nancy Sevilla Camacho
-- Actividad : Se realiza bÃºsqueda por un rango de fechas
-- SolicitÃ³  : Rodolfo GÃ³mez
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
	--11/Junio/2012	
    --DEFINE cfechaini char(20);
    --DEFINE cfechafin char(20);	
	DEFINE dFechaIni DATETIME YEAR TO SECOND;
	DEFINE dFechaFin2 DATETIME YEAR TO SECOND;	
	DEFINE cSecuencia 	CHAR(2);
	DEFINE dFechaAlta	DATE;


	LET cCodRet = '000';
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
	--11/Junio/2012	
    --let cfechaini = '';
    --let cfechafin = '';
    let dFechaIni = '1900-01-01 00:00:00';
    let dFechaFin2 = '1900-01-01 00:00:00';	
	LET cSecuencia  = 	'';
	LET dFechaAlta = NULL;

	--SET DEBUG FILE TO "/home/sysifx/Nancy/sp_obtenerhistmttodehuella.out";
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_obtenerhistmttodehuella.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
					NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		END EXCEPTION;

         let dFechaIni = YEAR(dFecha)||'-'||LPAD(MONTH(dFecha),2,0)||'-'||LPAD(DAY(dFecha),2,0)||' 00:00:00';
		 --11/Junio/2012		 
         --let cfechafin = year(dfecha)||'-'||lpad(month(dfecha),2,0)||'-'||lpad(day(dfecha),2,0)||' 23:59:59';
         let dFechaFin2 = YEAR(dFechaFin)||'-'||LPAD(MONTH(dFechaFin),2,0)||'-'||LPAD(DAY(dFechaFin),2,0)||' 23:59:59';		 

		IF i16Tipo = 1 THEN
			FOREACH
			
				--11/Junio/2012			
				/*SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
					b.nombre2, a.empleado, a.operador, a.usuario3
				INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
					cOperador, cUsuario
				FROM bdinteg:"informix".si_huella_temp a, bdinteg:"informix".si_cliente b
                WHERE a.fecha_alta >= cfechaini
                  AND a.fecha_alta <= cfechafin			  
                  AND a.sucursal = cSucursal 
                  AND a.numcte = b.numcte
				  AND a.secuencia > 0
				  AND a.status = 'A'
				ORDER BY b.apell_paterno*/			
				  
				/*
				SELECT DISTINCT a.fecha_alta, a.numcte,  a.empleado, a.operador, a.usuario3
				  INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
				  FROM bdinteg:"informix".si_huella_temp a
                 WHERE a.fecha_alta >= dFechaIni
                   AND a.fecha_alta <= dFechaFin2	
				   AND a.sucursal = cSucursal 
				   AND a.status = 'A'*/
				
				SELECT {+AVOID_FULL (bdinteg:"informix".si_huella_linea)} 
					fecha_ult_cambio
					, numcte
					, empleado
					, secuencia
					, fecha_alta_huella
				INTO cFechaHora, cNumCte, cEmpleado, cSecuencia, dFechaAlta
				FROM bdinteg:"informix".si_huella_linea
				WHERE 
				fecha_consulta BETWEEN dFechaIni AND dFechaFin2
				AND secuencia <> 1
				and tipo_mov_huella = 2
				and sucursal = cSucursal
				UNION
				SELECT {+AVOID_FULL (bdinteg:"informix".si_huella_linea_hist)} 
					fecha_ult_cambio
					, numcte
					, empleado
					, secuencia
					, fecha_alta_huella
				FROM bdinteg:"informix".si_huella_linea_hist
				WHERE 
				fecha_consulta BETWEEN dFechaIni AND dFechaFin2
				AND secuencia <> 1
				and tipo_mov_huella = 2
				and sucursal = cSucursal
				
				IF (dFechaAlta IS NULL OR dFechaAlta < dFechaIni) THEN
					CONTINUE FOREACH;
				END IF;


				SELECT {+AVOID_FULL (bdinteg:"informix".si_cte_huella)} 
					h.usuario AS usuario3
				INTO cUsuario
				FROM bdinteg:"informix".si_cte_huella h
				WHERE h.numcte=cNumCte 
				and h.secuencia=cSecuencia
				;
				
				IF (cUsuario IS NULL OR cUsuario = '') THEN
					CONTINUE FOREACH;
				END IF;

				--Se obtiene el nÃºmero de cliente del promotor
				SELECT ex.usuario_alta 
				INTO cOperador
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex
				WHERE ex.cliente = cNumCte 
				and ex.cod_docto = '0231'
				and ex.fecha_alta = dFechaAlta
				and ex.secuencia = (SELECT MAX(secuencia) from bdidigital@coppelimg_tcp:"informix".dg_expediente ex2 where ex2.cliente = cNumCte and ex2.cod_docto = '0231' and ex2.fecha_alta = dFechaAlta)
				;

				IF (cOperador IS NULL OR cOperador = '') THEN
					LET cOperador = cUsuario;
				END IF;
				  
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
		ELIF i16Tipo = 2 THEN
			FOREACH
				--11/Junio/2012				
				/*SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
					b.nombre2, a.empleado, a.operador, a.usuario3
				INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
					cOperador, cUsuario
				FROM bdinteg:"informix".si_huella_temp a, bdinteg:"informix".si_cliente b			
                WHERE a.fecha_alta >= cfechaini
                 AND a.fecha_alta <= cfechafin
                WHERE a.fecha_alta >= dFecha
                  AND a.fecha_alta <= dFechaFin				  
                  AND a.sucursal = cSucursal
		          AND a.status = 'A'
			  	  AND a.numcte = b.numcte AND a.empleado = cNumEmpleado
				ORDER BY b.apell_paterno*/

				/*
				SELECT DISTINCT a.fecha_alta, a.numcte, a.empleado, a.operador, a.usuario3
				  INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
				  FROM bdinteg:"informix".si_huella_temp a
                 WHERE a.fecha_alta >= dFechaIni
                   AND a.fecha_alta <= dFechaFin2	
				   AND a.sucursal = cSucursal 
				   AND a.status = 'A'
				   AND a.empleado = cNumEmpleado*/
				   
				SELECT {+AVOID_FULL (bdinteg:"informix".si_huella_linea)} 
					fecha_ult_cambio
					, numcte
					, empleado
					, secuencia
					, fecha_alta_huella
				INTO cFechaHora, cNumCte, cEmpleado, cSecuencia, dFechaAlta
				FROM bdinteg:"informix".si_huella_linea
				WHERE 
				fecha_consulta BETWEEN dFechaIni AND dFechaFin2
				AND secuencia <> 1
				and tipo_mov_huella = 2
				and sucursal = cSucursal
				and empleado = cNumEmpleado
				UNION
				SELECT {+AVOID_FULL (bdinteg:"informix".si_huella_linea_hist)} 
					fecha_ult_cambio
					, numcte
					, empleado
					, secuencia
					, fecha_alta_huella
				FROM bdinteg:"informix".si_huella_linea_hist
				WHERE 
				fecha_consulta BETWEEN dFechaIni AND dFechaFin2
				AND secuencia <> 1
				and tipo_mov_huella = 2
				and sucursal = cSucursal
				and empleado = cNumEmpleado

				IF (dFechaAlta IS NULL OR dFechaAlta < dFechaIni) THEN
					CONTINUE FOREACH;
				END IF;
				
				SELECT {+AVOID_FULL (bdinteg:"informix".si_cte_huella)} 
					h.usuario AS usuario3
				INTO cUsuario
				FROM bdinteg:"informix".si_cte_huella h
				WHERE h.numcte=cNumCte 
				and h.secuencia=cSecuencia
				;
				
				IF (cUsuario IS NULL OR cUsuario = '') THEN
					CONTINUE FOREACH;
				END IF;

				--Se obtiene el nÃºmero de cliente del promotor
				SELECT ex.usuario_alta 
				INTO cOperador
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex
				WHERE ex.cliente = cNumCte 
				and ex.cod_docto = '0231'
				and ex.fecha_alta = dFechaAlta
				and ex.secuencia = (SELECT MAX(secuencia) from bdidigital@coppelimg_tcp:"informix".dg_expediente ex2 where ex2.cliente = cNumCte and ex2.cod_docto = '0231' and ex2.fecha_alta = dFechaAlta)
				;

				IF (cOperador IS NULL OR cOperador = '') THEN
					LET cOperador = cUsuario;
				END IF;

				
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
		ELIF i16Tipo = 3 THEN
			FOREACH
				--11/Junio/2012				
				/*SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
					b.nombre2, a.empleado, a.operador, a.usuario3
				INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
					cOperador, cUsuario
				FROM bdinteg:"informix".si_huella_temp a, bdinteg:"informix".si_cliente b
                 WHERE a.fecha_alta >= cfechaini
                  AND a.fecha_alta <= cfechafin			  
                  AND a.sucursal = cSucursal
		          AND a.status = 'A'
				  AND a.numcte = b.numcte AND a.empleado BETWEEN cNumEmpleado AND cNumEmpleado2
				ORDER BY b.apell_paterno*/

				/*
				SELECT DISTINCT a.fecha_alta, a.numcte, a.empleado, a.operador, a.usuario3
				  INTO cFechaHora, cNumCte, cEmpleado, cOperador, cUsuario
				  FROM bdinteg:"informix".si_huella_temp a
                 WHERE a.fecha_alta >= dFechaIni
                   AND a.fecha_alta <= dFechaFin2	
				   AND a.sucursal = cSucursal 
				   AND a.status = 'A'
				   AND a.empleado BETWEEN cNumEmpleado AND cNumEmpleado2*/
				   
				SELECT {+AVOID_FULL (bdinteg:"informix".si_huella_linea)} 
					fecha_ult_cambio
					, numcte
					, empleado
					, secuencia
					, fecha_alta_huella
				INTO cFechaHora, cNumCte, cEmpleado, cSecuencia, dFechaAlta
				FROM bdinteg:"informix".si_huella_linea
				WHERE 
				fecha_consulta BETWEEN dFechaIni AND dFechaFin2
				AND secuencia <> 1
				and tipo_mov_huella = 2
				and sucursal = cSucursal
				and empleado BETWEEN cNumEmpleado AND cNumEmpleado2
				UNION
				SELECT {+AVOID_FULL (bdinteg:"informix".si_huella_linea_hist)} 
					fecha_ult_cambio
					, numcte
					, empleado
					, secuencia
					, fecha_alta_huella
				FROM bdinteg:"informix".si_huella_linea_hist
				WHERE 
				fecha_consulta BETWEEN dFechaIni AND dFechaFin2
				AND secuencia <> 1
				and tipo_mov_huella = 2
				and sucursal = cSucursal
				and empleado BETWEEN cNumEmpleado AND cNumEmpleado2
				
				IF (dFechaAlta IS NULL OR dFechaAlta < dFechaIni) THEN
					CONTINUE FOREACH;
				END IF;

				SELECT {+AVOID_FULL (bdinteg:"informix".si_cte_huella)} 
					h.usuario AS usuario3
				INTO cUsuario
				FROM bdinteg:"informix".si_cte_huella h
				WHERE h.numcte=cNumCte 
				and h.secuencia=cSecuencia
				;
				
				IF (cUsuario IS NULL OR cUsuario = '') THEN
					CONTINUE FOREACH;
				END IF;

				--Se obtiene el nÃºmero de cliente del promotor
				SELECT ex.usuario_alta 
				INTO cOperador
				FROM bdidigital@coppelimg_tcp:"informix".dg_expediente ex
				WHERE ex.cliente = cNumCte 
				and ex.cod_docto = '0231'
				and ex.fecha_alta = dFechaAlta
				and ex.secuencia = (SELECT MAX(secuencia) from bdidigital@coppelimg_tcp:"informix".dg_expediente ex2 where ex2.cliente = cNumCte and ex2.cod_docto = '0231' and ex2.fecha_alta = dFechaAlta)
				;

				IF (cOperador IS NULL OR cOperador = '') THEN
					LET cOperador = cUsuario;
				END IF;

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
		END IF;
	END;

END PROCEDURE;