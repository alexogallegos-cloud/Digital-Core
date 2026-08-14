CREATE PROCEDURE "informix".sp_inserta_huella_dec_web(pEmpresa CHAR(3), pNumcte CHAR(20),pSucursal CHAR(5),pUser_insert CHAR(8),pFecha DATE,
													  cDH1 CHAR(955),cDH2 CHAR(955),cDH3 CHAR(955),cDH4 CHAR(955),cDH5 CHAR(955),cDH6 CHAR(955),
													  cDH7 CHAR(955),cDH8 CHAR(955),cDH9 CHAR(955),cDH10 CHAR(955), cTipo CHAR(2), cEmpleado CHAR(8),
													  cUsuario3 CHAR(8))
	--Retorno
	RETURNING CHAR(5) AS cCodigoRet;

	--Declaracion de variables
	DEFINE sSecuencia    SMALLINT;
	DEFINE sId_template  SMALLINT;
	DEFINE cTemplate     CHAR(942);
	DEFINE sNfiq         SMALLINT;
	DEFINE sMinucias     SMALLINT;
	DEFINE sId_Excepcion SMALLINT;
	DEFINE dFecha   	 DATE;
	DEFINE dFecha_insert DATETIME YEAR TO FRACTION;
	DEFINE iSqlErr       INTEGER;
	DEFINE cCodigoRet    CHAR(5);
	DEFINE iCont    	 SMALLINT ;
	DEFINE iSiguienteSecuencia SMALLINT;

	DEFINE cTp_persona CHAR(2);
	DEFINE cEsfisica   CHAR(1);
	DEFINE cExiste     CHAR(1);
	DEFINE cTemplateD  CHAR(942);
	DEFINE cTemplateI  CHAR(942);

	DEFINE cTemplate1 CHAR(942);
	DEFINE cTemplate2 CHAR(942);
	DEFINE cTemplate3 CHAR(942);
	DEFINE cTemplate4 CHAR(942);
	DEFINE cTemplate5 CHAR(942);
	DEFINE cTemplate6 CHAR(942);
	DEFINE cTemplate7 CHAR(942);
	DEFINE cTemplate8 CHAR(942);
	DEFINE cTemplate9 CHAR(942);
	DEFINE cTemplate10 CHAR(942);
	DEFINE cTipoP 	   CHAR(1);
	DEFINE smSecuenciaMax SMALLINT;

	--inicializacion de variables
	LET iSqlErr    = 0;
	LET cCodigoRet = '00000';
	LET sSecuencia = 0;
	LET sId_template = 0;
	LET cTemplate  = '';
	LET sNfiq      = 0;
	LET sMinucias  = 0;
	LET sId_Excepcion = 0;
	LET dFecha     = pFecha;
	LET iCont      = 1;
	LET iSiguienteSecuencia = 0;

	LET cTemplate1 = '';
	LET cTemplate2 = '';
	LET cTemplate3 = '';
	LET cTemplate4 = '';
	LET cTemplate5 = '';
	LET cTemplate6 = '';
	LET cTemplate7 = '';
	LET cTemplate8 = '';
	LET cTemplate9 = '';
	LET cTemplate10 = '';
	LET cTipoP = '';
	LET smSecuenciaMax = 0;

	--SET DEBUG FILE TO '/home/sysifx/Selene/bdinteg/sp_inserta_huella_dec.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr !=0 THEN
			RETURN (isqlerr);  
		END IF
	END EXCEPTION

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	--VALIDAR DATOS VACIOS
	IF NVL(pNumcte,'') = '' OR NVL(pSucursal, '') = '' OR NVL(pUser_insert, '') = '' OR NVL(dFecha, '') = '' OR NVL(cDH1,'') = '' OR NVL(cDH2,'') = '' OR NVL(cDH3,'') = '' OR NVL(cDH4,'') = '' OR NVL(cDH5,'') = '' OR NVL(cDH6,'') = '' OR NVL(cDH7,'') = '' OR NVL(cDH8,'') = '' OR NVL(cDH9,'') = '' OR NVL(cDH10,'') = '' THEN
		LET cCodigoRet = '00001'; --Datos vacios
		RETURN cCodigoRet;
	ELSE 
		SELECT tpo_persona INTO cTp_persona
		FROM   bdinteg:"informix".si_cliente
		WHERE  numcte = pNumcte;

		SELECT es_fisica INTO cEsfisica
		FROM bdinteg:"informix".si_tipper
		WHERE tpo_persona = cTp_persona;

		IF UPPER(cEsfisica) != "S" THEN
			LET cCodigoRet = '00120';
			RETURN cCodigoRet;
		END IF;

		--3 Validar que exista la sucursal en el sistema, en caso de no existir retornar cCodigoRet = '00111';
		SELECT 1 INTO cExiste
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = pSucursal;

		IF cExiste IS NULL THEN
			LET cCodigoRet = '00111';
			RETURN cCodigoRet;
		END IF;

		--4.- Validar que exista el ejecutivo en el sistema, en caso de no existir retornar cCodigoRet = '00112';
		SELECT 1 INTO cExiste
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pUser_insert;

		IF cExiste IS NULL THEN
			LET cCodigoRet='00112';
			RETURN cCodigoRet;
		END IF;
		
		WHILE (iCont <=10)
			LET cTemplate = '';
			
			--1 
			IF (iCont=1) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH1) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate1;
				LET cTemplate = cTemplate1; 
			END IF;    
			--2   
			IF (iCont=2) THEN      
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH2) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate2;
				LET cTemplate = cTemplate2; 				
			END IF;    
			--3    
			IF (iCont=3) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH3) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate3;
				LET cTemplate = cTemplate3; 
			END IF;
			--4
			IF (iCont=4) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH4) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate4;
				LET cTemplate = cTemplate4; 
			END IF;
			--5
			IF (iCont=5) THEN     
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH5) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate5;
				LET cTemplate = cTemplate5; 
			END IF;
			--6
			IF (iCont=6) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH6) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate6;
				LET cTemplate = cTemplate6; 
			END IF;
			--7
			IF (iCont=7) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH7) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate7; 
				LET cTemplate = cTemplate7;    
			END IF;
			--8
			IF (iCont=8) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH8) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate8;
				LET cTemplate = cTemplate8; 
			END IF;
			--9
			IF (iCont=9) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH9) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate9;
				LET cTemplate = cTemplate9; 
			END IF;    
			--10
			IF (iCont=10) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH10) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate10;
				LET cTemplate = cTemplate10; 
			END IF;

			--CONSULTAR ULTIMA SECUENCIA CON ESTATUS A DE ID_TEMPLATE 
			LET sSecuencia = (SELECT secuencia FROM "informix".si_cte_huella_dec WHERE numcte =  pNumcte AND estatus = 'A' AND id_template = sId_template);

			IF NVL(sSecuencia, '') = ''  THEN
				LET sSecuencia = 1; 
			ELSE 
				LET sSecuencia = sSecuencia + 1;
			END IF;
			
			--ELIMINAR REGISTROS DE TEMPLATES DEL CLIENTE
			DELETE FROM "informix".si_cte_huella_dec_actual WHERE numcte = pNumcte AND id_template = sId_template;

			--INSERTAR LOS NUEVOS TEMPLATES
			INSERT INTO "informix".si_cte_huella_dec_actual(numcte,secuencia,id_template,template,nfiq,minucias,sucursal,id_excepcion,user_insert,fecha,fecha_insert) 
			VALUES(pNumcte,sSecuencia,sId_template,cTemplate,sNfiq,sMinucias,pSucursal,sId_Excepcion,pUser_insert,pFecha,current);

			--ACTUALIZAR EL ESTATUS DE LOS TEMPLATES ANTERIORES CON ESTATUS I= INACTIVO
			UPDATE "informix".si_cte_huella_dec SET estatus = 'I' WHERE numcte = pNumcte AND id_template = sId_template;

			--INSERTAR LOS NUEVOS TEMPLATES CON ESTATUS A= ACTIVO
			INSERT INTO "informix".si_cte_huella_dec(numcte,secuencia,estatus,id_template,template,nfiq,minucias,sucursal,id_excepcion,user_insert,fecha,fecha_insert) 
			VALUES(pNumcte,sSecuencia,'A',sId_template,cTemplate,sNfiq,sMinucias,pSucursal,sId_Excepcion,pUser_insert,pFecha,current);

			LET iCont = iCont + 1;
		END WHILE;

		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET cCodigoRet= '00002';
		END IF;	

		SELECT MAX(secuencia)
        INTO smSecuenciaMax
        FROM bdinteg:si_cte_huella_dec_temp
        WHERE numcte = pNumcte;

		--Actualizar status de la tabla de huellas temporales
		UPDATE si_cte_huella_dec_temp
		SET status = "A", usuario3 = cUsuario3
		WHERE  numcte = pNumcte AND status = "M" AND secuencia = smSecuenciaMax;	
	 
		IF (NVL(cTemplate2, '') = '') THEN
			IF (NVL(cTemplate1, '') = '') THEN
				IF (NVL(cTemplate3, '') = '') THEN
					IF (NVL(cTemplate4, '') = '') THEN
						IF (NVL(cTemplate5, '') = '') THEN
							LET cTemplateD = '';
						ELSE
							LET cTemplateD = cTemplate5;
						END IF;
					ELSE
						LET cTemplateD = cTemplate4;
					END IF;
				ELSE
					LET cTemplateD = cTemplate3;
				END IF;
			ELSE
				LET cTemplateD = cTemplate1;
			END IF;
		ELSE
			LET cTemplateD = cTemplate2;
		END IF;
		
		IF (NVL(cTemplate7, '') = '') THEN
			IF (NVL(cTemplate6, '') = '') THEN
				IF (NVL(cTemplate8, '') = '') THEN
					IF (NVL(cTemplate9, '') = '') THEN
						IF (NVL(cTemplate10, '') = '') THEN
							LET cTemplateI = '';
						ELSE
							LET cTemplateI = cTemplate10;
						END IF;
					ELSE
						LET cTemplateI = cTemplate9;
					END IF;
				ELSE
					LET cTemplateI = cTemplate8;
				END IF;
			ELSE
				LET cTemplateI = cTemplate6;
			END IF;
		ELSE
			LET cTemplateI = cTemplate7;
		END IF;
		
		IF (NVL(cTemplateD, '') = '' OR NVL(cTemplateI, '') = '') THEN
			
			If  NVL(cTemplateD, '') = '' THEN
				
				IF (NVL(cTemplate7, '') = '') THEN					
					IF (NVL(cTemplate6, '') = '') THEN
						IF (NVL(cTemplate8, '') = '') THEN
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = '';
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate9;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							END IF;
						ELSE
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate8;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								LET cTemplateD = cTemplate9 ;
							END IF;
						END IF;
					ELSE
						IF (NVL(cTemplate8, '') = '') THEN
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate6;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								LET cTemplateD = cTemplate9;
							END IF;
						ELSE
							LET cTemplateD = cTemplate8;
						END IF;
					END IF;
				ELSE
					IF (NVL(cTemplate6, '') = '') THEN
						IF (NVL(cTemplate8, '') = '') THEN
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate7;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								LET cTemplateD = cTemplate9;
							END IF;
						ELSE
							LET cTemplateD = cTemplate8;
						END IF;
					ELSE
						LET cTemplateD = cTemplate6;
					END IF;
				END IF;
				
			ELSE			
				IF (NVL(cTemplate2, '') = '') THEN					
					IF (NVL(cTemplate1, '') = '') THEN
						IF (NVL(cTemplate3, '') = '') THEN
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = '';
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate4;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							END IF;
						ELSE
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate3;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								LET cTemplateI = cTemplate4;
							END IF;
						END IF;
					ELSE
						IF (NVL(cTemplate3, '') = '') THEN
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate1;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								LET cTemplateI = cTemplate4;
							END IF;
						ELSE
							LET cTemplateI = cTemplate3;
						END IF;
					END IF;
				ELSE
					IF (NVL(cTemplate1, '') = '') THEN
						IF (NVL(cTemplate3, '') = '') THEN
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate2;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								LET cTemplateI = cTemplate4;
							END IF;
						ELSE
							LET cTemplateI = cTemplate3;
						END IF;
					ELSE
						LET cTemplateI = cTemplate1;
					END IF;
				END IF;
				
			END IF
		END IF;
		
		IF TRIM(cTipo) = 'M' THEN
			LET cTipoP='C';
			
		ELSE		
			LET cTipoP='A';
		END IF;

		EXECUTE PROCEDURE bdinteg:"informix".sp_ctehuella(pEmpresa, pSucursal, pUser_insert, pUser_insert, pFecha, cTipoP, pNumcte, cTemplateD, cTemplateI)
		INTO cCodigoRet,iSiguienteSecuencia;

	END IF;
	
	RETURN LPAD(TRIM(cCodigoRet),5,'0');	
END;
END PROCEDURE

DOCUMENT
'Peticion: 420',
'AutOR : 92473997 Isaac Salomon Quintero Serrano',
'FECHA : 31/08/2018',
'Descripcion: Store Procedure Insertar los datos de las huellas en la tabla si_cte_huella_dec',
'BD : bdinteg';

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