CREATE PROCEDURE "informix".sp_insbitsmsmant_huellarostro_web(pOpcion CHAR(1),pNumTelefono CHAR(10), pEjecutivo CHAR(8), pCodigoGenerado CHAR(4), pCodigoTeclea CHAR(100), pSucursal CHAR(4), pNumCte CHAR(20))
RETURNING CHAR(5);


DEFINE iSqlErr		INTEGER;
DEFINE sCodRet		CHAR(5);
DEFINE cNumCte		CHAR(20);
DEFINE cTelefono	CHAR(10);
DEFINE iExiste      SMALLINT;
DEFINE iMinutos     INTEGER;
DEFINE iReintentos  INTEGER;
DEFINE iEnviados    INTEGER;
DEFINE iMinTrans    INTEGER;
DEFINE sDiferencia	CHAR(30);
DEFINE sCorreo		CHAR(100);
DEFINE cDif			CHAR(4);
DEFINE cNombreCliente VARCHAR(15);
DEFINE cApellidoCliente VARCHAR(15);
DEFINE cNombreCompletoCliente VARCHAR(30);
DEFINE cCodigoExiste CHAR(4);


LET iSqlErr = 0;
LET sCodRet = '00000';
LET cNumCte = '';
LET cTelefono = '';
LET iExiste     =   0;
LET iMinutos    =   0;
LET iReintentos =   0;
LET iEnviados   =   0;
LET iMinTrans   =   0;
LET sDiferencia =   '';
LET cDif 		=	'';
LET cNombreCliente = '';
LET cApellidoCliente = '';
LET cNombreCompletoCliente = '';
LET cCodigoExiste = '';

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET sCodRet = iSqlErr;
			RETURN sCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/home/sysifx/JesusRubio/627/sp_insbitsmsmant_huellarostro_web.out";
	--TRACE ON;
	
		IF pOpcion = '1' THEN
			
			SELECT FIRST 1 numcte INTO cNumCte FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte AND telefono = pNumTelefono AND DATE(fecha) = DATE(CURRENT);
			LET iExiste = dbinfo("sqlca.sqlerrd2");
		
			IF iExiste = 0 THEN
				INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, fecha)
				VALUES(pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, CURRENT);
			ELSE
				SELECT  FIRST 1 codigo_generado INTO cCodigoExiste FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte AND telefono = pNumTelefono AND DATE(fecha) = DATE(CURRENT);
				LET pCodigoGenerado = TRIM(cCodigoExiste);
			END IF;
			
			SELECT nombre1 INTO cNombreCliente FROM bdinteg:"informix".si_cliente where sucursal = pSucursal AND numcte = pNumCte;
			SELECT apell_paterno INTO cApellidoCliente FROM bdinteg:"informix".si_cliente where sucursal = pSucursal AND numcte = pNumCte;
			
			LET cNombreCompletoCliente = TRIM(cNombreCliente) || ' ' || TRIM(cApellidoCliente);
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','HUL_MANTTO','HUE_SMS','000000000','','','1',cNombreCompletoCliente, pCodigoGenerado,'','','','','','','','','',pNumTelefono,1,0,0,0,0,'','')
			INTO sCodRet;
			
			--OBTIENE CORREO DE CLIENTE
			SELECT FIRST 1 correo_elec INTO sCorreo FROM bdinteg:"informix".si_correos WHERE numcte = pNumCte AND status_correo='A';
			IF	NVL(sCorreo,'') <> '' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','HUL_MANT_E','HUE_EMAIL','000000000','','','1',cNombreCompletoCliente, pCodigoGenerado,'','','','','','','','',sCorreo,'',1,0,0,0,0,'','')
				INTO sCodRet;
			END IF;
			
		ELIF pOpcion = '2' THEN
			--INSERTA CODIGO INCORRECTO
			INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, codigo_tecleado, fecha)
			VALUES(pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, pCodigoTeclea, CURRENT);
			
		ELIF pOpcion = '3' THEN
			--ACTUALIZA CODIGO CORRECTO			
			SELECT FIRST 1 numcte INTO cNumCte FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte AND ejecutivo = pEjecutivo AND sucursal = pSucursal AND DATE(fecha) = DATE(CURRENT) AND pCodigoTeclea IS NULL;
			LET iExiste = dbinfo("sqlca.sqlerrd2");
			IF iExiste > 0 THEN
				UPDATE bdinteg:"informix".si_bitsmstels_huellarostro SET codigo_tecleado = pCodigoTeclea, fecha = CURRENT
				WHERE numcte = pNumCte AND ejecutivo = pEjecutivo AND sucursal = pSucursal AND DATE(fecha) = DATE(CURRENT) AND codigo_tecleado IS NULL;
			ELSE
				INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, codigo_tecleado, fecha)
				VALUES (pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, pCodigoTeclea, CURRENT);
			END IF;
		
		ELIF pOpcion = '4' THEN
			--REENVIO DE SMS
			--Minutos maximo para envio de sms
			SELECT TRIM(valor) INTO iMinutos FROM bdinteg:"informix".si_param WHERE cod_param = '382';
			--Intentos  maximos de reenvio de sms
			SELECT TRIM(valor) INTO iReintentos FROM bdinteg:"informix".si_param WHERE cod_param = '383';
			
			--Cantidad de reenvios por cliente al dia
			SELECT COUNT(*) INTO iEnviados 
			FROM bdinteg:"informix".si_bitsmstels_huellarostro 
			WHERE numcte = pNumCte
			AND telefono = pNumTelefono 
			AND TRIM(codigo_tecleado) = 'REENVIO SMS'
			AND DATE(fecha) = DATE(CURRENT);
			
			
			IF	iEnviados >= iReintentos THEN
				RETURN sCodRet;
			END IF;
			
			SELECT CURRENT-MAX(fecha) INTO sDiferencia
			FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte 
			AND telefono = pNumTelefono
			AND DATE(fecha) = DATE(CURRENT);
			
			IF LENGTH (TRIM(sDiferencia)) = 16 THEN
				LET cDif = SUBSTRING ((TRIM(sDiferencia)) FROM 8 FOR 2);
				SELECT cDif INTO iMinTrans FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
			ELIF LENGTH (TRIM(sDiferencia)) = 15 THEN
				LET cDif = SUBSTRING ((TRIM(sDiferencia)) FROM 7 FOR 2);
				SELECT cDif INTO iMinTrans FROM bdinteg:"informix".si_fechas WHERE empresa = '001'; 
			ELSE
				LET cDif = SUBSTRING ((TRIM(sDiferencia)) FROM 6 FOR 2);
				SELECT cDif INTO iMinTrans FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
			END IF;
			
			IF iMinTrans < iMinutos THEN
				RETURN sCodRet;
			END IF;			
			
			SELECT FIRST 1 numcte INTO cNumCte FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte AND telefono = pNumTelefono AND codigo_tecleado IS NULL;
			LET iExiste = dbinfo("sqlca.sqlerrd2");
			IF iExiste > 0 THEN
				UPDATE bdinteg:"informix".si_bitsmstels_huellarostro SET codigo_tecleado = 'REENVIO SMS', fecha = CURRENT
				WHERE numcte = pNumCte AND telefono = pNumTelefono AND codigo_tecleado IS NULL;
			ELSE
				INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, codigo_tecleado, fecha)
				VALUES(pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, 'REENVIO SMS', CURRENT);
			END IF;
			
			INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, fecha)
			VALUES(pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, CURRENT);
			
			SELECT nombre1 INTO cNombreCliente FROM bdinteg:"informix".si_cliente where sucursal = pSucursal AND numcte = pNumCte;
			SELECT apell_paterno INTO cApellidoCliente FROM bdinteg:"informix".si_cliente where sucursal = pSucursal AND numcte = pNumCte;
			
		    LET cNombreCompletoCliente = TRIM(cNombreCliente) || ' ' || TRIM(cApellidoCliente);
           
		    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','HUL_MANTTO','HUE_SMS','000000000','','','1',cNombreCompletoCliente,pCodigoGenerado,'','','','','','','','','',pNumTelefono,1,0,0,0,0,'','')
			INTO sCodRet;
			
			SELECT FIRST 1 correo_elec INTO sCorreo FROM bdinteg:"informix".si_correos WHERE numcte = pNumCte AND status_correo = 'A';
			IF NVL(sCorreo,'')<>'' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','HUL_MANT_E','HUE_EMAIL','000000000','','','1',cNombreCompletoCliente,pCodigoGenerado,'','','','','','','','',sCorreo,'',1,0,0,0,0,'','')
				INTO sCodRet;
            END IF;		
		ELSE
			LET sCodRet = '00001';
		END IF;
	RETURN sCodRet;
END
END PROCEDURE
DOCUMENT
'Se crea SP para insercion de bitacora de envio de sms y correo electronico para mantenimiento de huella y biometria',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 22/10/2019',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_obtenerhistmttodehuella_web(i16Tipo SMALLINT, cSucursal CHAR(4), dFecha DATE, cNumEmpleado CHAR(8),cNumEmpleado2 CHAR(8), i16Registros SMALLINT)
--Se borra el sp con mayusculas y se reemplaza por solo minusculas

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
    DEFINE cfechaini char(20);
    DEFINE cfechafin char(20);

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
    let cfechaini = '';
    let cfechafin = '';

--	SET DEBUG FILE TO "sp_ObtenerHistMttoDeHuella.out";
--	TRACE ON;

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

         let cfechaini = year(dfecha)||'-'||lpad(month(dfecha),2,0)||'-'||lpad(day(dfecha),2,0)||' 00:00:00';
         let cfechafin = year(dfecha)||'-'||lpad(month(dfecha),2,0)||'-'||lpad(day(dfecha),2,0)||' 23:59:59';

		IF i16Tipo = 1 THEN
			IF (SELECT DISTINCT COUNT(*)
				FROM si_huella_temp a, si_cliente b
                WHERE a.fecha_alta >= cfechaini
                  AND a.fecha_alta <= cfechafin
                  AND a.sucursal = cSucursal 
                  AND a.numcte = b.numcte
				  AND a.status = 'A') > 0 THEN
				FOREACH
					SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
						b.nombre2, a.empleado, a.operador, a.usuario3
					INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
						cOperador, cUsuario
					FROM si_huella_temp a, si_cliente b
					WHERE a.fecha_alta >= cfechaini
					  AND a.fecha_alta <= cfechafin
					  AND a.sucursal = cSucursal 
					  AND a.numcte = b.numcte
					  AND a.status = 'A'
					ORDER BY b.apell_paterno

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
			ELSE
				LET  cCodRet = '00001';
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		ELIF i16Tipo = 2 THEN
			IF (SELECT DISTINCT COUNT(*) 
						FROM si_huella_temp a, si_cliente b
						WHERE a.fecha_alta >= cfechaini
						AND a.fecha_alta <= cfechafin
						AND a.sucursal = cSucursal
						AND a.status = 'A'
						AND a.numcte = b.numcte AND a.empleado = cNumEmpleado) > 0 THEN
				FOREACH
					SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
						b.nombre2, a.empleado, a.operador, a.usuario3
					INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
						cOperador, cUsuario
					FROM si_huella_temp a, si_cliente b
					WHERE a.fecha_alta >= cfechaini
					  AND a.fecha_alta <= cfechafin
					  AND a.sucursal = cSucursal
						AND a.status = 'A'
					  AND a.numcte = b.numcte AND a.empleado = cNumEmpleado
					ORDER BY b.apell_paterno

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
			ELSE
				LET  cCodRet = '00001';
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		ELIF i16Tipo = 3 THEN
			IF (SELECT DISTINCT COUNT(*) 
					FROM si_huella_temp a, si_cliente b
					WHERE a.fecha_alta >= cfechaini
					AND a.fecha_alta <= cfechafin
					AND a.sucursal = cSucursal
					AND a.status = 'A'
					AND a.numcte = b.numcte AND a.empleado BETWEEN cNumEmpleado AND cNumEmpleado2) > 0 THEN 
			
				FOREACH
					SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
						b.nombre2, a.empleado, a.operador, a.usuario3
					INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
						cOperador, cUsuario
					FROM si_huella_temp a, si_cliente b
					WHERE a.fecha_alta >= cfechaini
					AND a.fecha_alta <= cfechafin
					AND a.sucursal = cSucursal
					AND a.status = 'A'
					AND a.numcte = b.numcte AND a.empleado BETWEEN cNumEmpleado AND cNumEmpleado2
					ORDER BY b.apell_paterno

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
			ELSE
				LET  cCodRet = '00001';
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		END IF;
	END;
END PROCEDURE;