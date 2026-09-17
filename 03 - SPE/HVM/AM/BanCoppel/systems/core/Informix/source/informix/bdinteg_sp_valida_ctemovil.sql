CREATE PROCEDURE "informix".sp_valida_ctemovil(pNombre1 CHAR(26),pNombre2 CHAR(26),pApell_paterno CHAR(26), pApell_materno CHAR(26),
                                               pFecha_nac CHAR(10),pCte_coppel CHAR(1),pNumcte_coppel CHAR(20),pEjecutivo CHAR(8))
											   
RETURNING CHAR(5) AS CodRet, CHAR(18) AS CteId, CHAR(20) AS Numcte,CHAR(1) AS cte_coppel,CHAR(20) AS Numcte_coppel, CHAR(50) AS Descripcion;
--DEFINE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE iCteId		INTEGER;
DEFINE cNumcte		CHAR(20);
DEFINE cNombres		CHAR(55);
DEFINE cCodRetSp	CHAR(5);
DEFINE cRfc		CHAR(13);
DEFINE cRfc2		CHAR(13);
DEFINE Ccte_coppel	CHAR(1);
DEFINE CNumcte_coppel	CHAR(20);
DEFINE CDesc		CHAR(50);
DEFINE Cfolio_procesado CHAR(1);
DEFINE Cstatus_valua    INTEGER;
DEFINE svt_cuantos      INTEGER;
DEFINE svt_dia          CHAR(2);
DEFINE svt_mes          CHAR(2);
DEFINE svt_year         CHAR(4);
DEFINE svt_rfc          CHAR(13);
DEFINE sFecRFC          CHAR(10);
DEFINE svt_cuantos2     INTEGER;
DEFINE svt_cuantos3     INTEGER;

DEFINE svt_empresa      CHAR(3);
DEFINE svt_num_solicitud CHAR(12);
DEFINE svt_numcte       CHAR(20);
DEFINE svt_num_producto CHAR(4);

DEFINE cCodRetLN	   CHAR(6);
DEFINE sFolio          CHAR(12);
DEFINE sNumcte         CHAR(20);
DEFINE sFechaLN        CHAR(10);

DEFINE sFechaInsert    DATE;
DEFINE sFechaHoy       DATE;

DEFINE SNrows           INTEGER;

--INICIALIZA VARIABLES
LET iSqlErr             = 0;
LET cCodRet             = '00000';
LET iCteId              = 0;
LET cNumcte             = '';
LET cNombres	        = '';
LET cCodRetSp	        = '';
LET cRfc                = '';
LET cRfc2               = '';
LET Ccte_coppel	        = 'N';
LET CNumcte_coppel      = '';
LET CDesc               ='';
LET Cfolio_procesado    = "";
LET Cstatus_valua       = 0;
LET svt_cuantos         = 0;
LET svt_dia             = "";
LET svt_mes             = "";
LET svt_year            = "";
LET svt_rfc             = "";
LET sFecRFC             ="";

LET svt_empresa         = "";
LET svt_num_solicitud   = "";
LET svt_numcte          = "";
LET svt_num_producto    = "";
LET svt_cuantos2        = 0;
LET svt_cuantos3        = 0;

LET cCodRetLN           ='';
LET sFolio              ='';
LET sNumcte             ='';
LET sFechaLN            ='';

LET sFechaInsert        ='';
LET sFechaHoy           ='';
LET SNrows             =0;

BEGIN


-- ERRORES DE INFORMIX
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
		IF iSqlErr IN (-1204,-1205,-1206) THEN
			--RETURN 0,0,'','','','Lectura de IFE invalida. Favor de procesarla nuevamente.';
			RETURN '','','','','','Lectura invalida,Favor de tomar nuevamente la foto';
		END IF;
		LET cCodRet = iSqlErr;
		RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/ztr/sp_valida_ctemovil.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--TRACE '------------------------------------------------------------------------------------------------------------ VALIDA PARAMETROS';
--VALIDA PARAMETROS
IF NVL(pNombre1,'') = '' OR NVL(pApell_paterno,'') = '' OR NVL(pFecha_nac,'') = '' OR NVL(pCte_coppel,'') = '' THEN
	LET cCodRet = '00001';
	LET CDesc = 'Falta introducir algun dato obligatorio';
	RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
END IF;

IF LEN(pNombre1) <=1 AND NVL(pApell_materno,'') = '' THEN
	LET cCodRet = '00009';
	LET CDesc = 'Lectura invalida,Favor de tomar nuevamente la foto';
	RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
END IF;

IF NVL(pNombre1,'') <>'' OR NVL(pNombre2,'') <>'' THEN
	LET cNombres= pNombre1||pNombre2; --CONCATENA LOS NOMBRES
END IF;

--TRACE '------------------------------------------------------------------------------------------------------------ VALIDA FECHA NACIMIENTO';
--Valida formato de la fecha de nacimiento
LET svt_dia = "";
LET svt_mes = "";
LET svt_year = "";
LET svt_dia = pFecha_nac[1,2];
LET svt_mes = pFecha_nac[4,5];
LET svt_year = pFecha_nac[7,10];
IF LENGTH(svt_year)<=2 THEN
    LET svt_year="19"||svt_year;
END IF;
LET sFecRFC = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);


LET pNombre1 = UPPER(pNombre1);
LET pNombre2 = UPPER(pNombre2);
LET pApell_paterno = UPPER(pApell_paterno);
LET pApell_materno = UPPER(pApell_materno);

--TRACE '------------------------------------------------------------------------------------------------------------ VALIDA LISTA NEGRA';
-----VALIDA EN LISTA NEGRA------------------
LET sFechaLN = SUBSTR(pFecha_nac,4,2) ||'/'|| SUBSTR(pFecha_nac,0,2) ||'/'|| SUBSTR(pFecha_nac,7,4);

Execute procedure bdiauditor:"informix".sp_busqueda_cte_listanegra(pNombre1, pNombre2, pApell_paterno, pApell_materno, sFechaLN) INTO cCodRetLN;

IF(cCodRetLN = '000002') THEN
    LET CDesc = 'No es posible continuar con el proceso del cliente';
	LET cCodRet = '00008';
    INSERT INTO si_bitacora_lista_negra(folio, numcliente, apell_paterno, apell_materno, nombre1, nombre2, fecha_nacimiento, fecha)
    VALUES('','',pApell_paterno,pApell_materno,pNombre1,pNombre2,pFecha_nac,TODAY);

	RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
END IF;
IF(cCodRetLN = '000001') THEN
	LET cCodRet = '00008';
    LET CDesc = 'Datos incorrectos, capturar nuevamente';
	RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
END IF;
-------------------------------------------

--TRACE '------------------------------------------------------------------------------------------------------------ EJECUTA sp_calcularrfc';
-- EJECUTA EL sp_calcularrfc PARA GENERAR EL RFC
CALL bdinteg:sp_calcularrfc(pApell_paterno, pApell_materno, cNombres, sFecRFC)
RETURNING cCodRetSp, cRfc;

IF cCodRetSp in ('00221','00222','00223','00224','00225','00226') THEN
    INSERT INTO "informix".si_bitacora_movil (Id_Movil, Ejecutivo, Nombre1, Nombre2, Apell_paterno,  Apell_materno, Fecha_nac, proceso, fecha, hora)
        VALUES(iCteId,pEjecutivo,pNombre1,pNombre2,pApell_paterno,pApell_materno,pFecha_nac,'sp_valida_ctemovil 1',current,current);
	RETURN cCodRetSp,0,'','','','Lectura de IFE invalida';
END IF;

--TRACE '------------------------------------------------------------------------------------------------------------ VALIDA RETORNO sp_calcularrfc';
--VALIDA EL CODIGO DE RETORNO DEL sp_calcularrfc
IF NVL(cCodRetSp,'') = '00000' THEN

	SELECT FIRST 1 rfc INTO cRfc2 FROM si_solicitud_movil WHERE rfc = cRfc AND status_valua = 1;
    LET SNrows = dbinfo("sqlca.sqlerrd2");     
    IF SNrows > 0 THEN
		----VALIDA FECHA-----------------------------------------------
		SELECT MAX(id) INTO iCteId FROM si_solicitud_movil WHERE rfc =cRfc;

		SELECT fecha_insert, status_valua INTO sFechaInsert, Cstatus_valua FROM si_solicitud_movil WHERE id = iCteId;

		SELECT LIMIT 1 fecha_hoy INTO sFechaHoy FROM si_fechas WHERE empresa = '001';

		IF (sFechaHoy - sFechaInsert < 180 AND Cstatus_valua = 1 ) THEN
			LET cCodRet = '00002';
			LET CDesc = 'El Cliente tiene solicitud en Proceso.';
			RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
		ELSE
			UPDATE si_solicitud_movil 
			SET status_valua = 0, folio_procesado = 0, ejecutivo = pEjecutivo, fecha_insert = current, fecha_hora = current
			WHERE id = iCteId;
		END IF;
		---------------------------------------------------------------
	END IF;
	
	--TRACE '------------------------------------------------------------------------------------------------------------ VERRIFICA RFC';
	--VERIFICA EL RCF SI EXISTE EN LA TABLA SI_CLIENTE
	SELECT  FIRST 1 rfc INTO cRfc2 FROM si_cliente WHERE rfc = cRfc;
    LET SNrows = dbinfo("sqlca.sqlerrd2");     
    IF SNrows > 0 THEN
	--TRACE '------------------------------------------------------------------------------------------------------------ ENTRA IF SNrows > 0';
		SELECT numcte INTO cNumcte FROM si_cliente WHERE rfc = cRfc;

		SELECT MAX(id)
		INTO iCteId
		FROM si_solicitud_movil
		WHERE numcte =cNumcte;

		SELECT folio_procesado, status_valua
		INTO Cfolio_procesado, Cstatus_valua
		FROM si_solicitud_movil
		WHERE id = iCteId;

		--SI status_valua=1 y Folio Procesado=0 EL CLIENTE TIENE SOLICITUD EN PROCESO
		IF (Cstatus_valua=1 OR Cstatus_valua=2) AND Cfolio_procesado=0 THEN
			LET cCodRet = '00002';
			LET CDesc = 'El Cliente tiene solicitud en Proceso.';
				INSERT INTO "informix".si_bitacora_movil (Id_Movil, Ejecutivo, Nombre1, Nombre2, Apell_paterno,  Apell_materno, Fecha_nac, proceso, fecha, hora)
				  VALUES(iCteId,pEjecutivo,UPPER(pNombre1),UPPER(pNombre2),UPPER(pApell_paterno),UPPER(pApell_materno),pFecha_nac,'sp_valida_ctemovil 2',current,current);
			RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
		ELIF Cfolio_procesado=0 AND Cstatus_valua IS NULL THEN
			--INSERT INTO "informix".si_bitacora_movil (Id_Movil, Ejecutivo, Nombre1, Nombre2, Apell_paterno,  Apell_materno, Fecha_nac, proceso, fecha, hora)
			--      VALUES(iCteId,pEjecutivo,UPPER(pNombre1),UPPER(pNombre2),UPPER(pApell_paterno),UPPER(pApell_materno),pFecha_nac,'sp_valida_ctemovil 3',current,current);
			UPDATE "informix".si_solicitud_movil SET ejecutivo=pEjecutivo, fecha_insert=current, fecha_hora=current WHERE id=iCteId;
		END IF;

		LET svt_cuantos = 0;
		--Valida que si existe el RFC no se Duplique el Registro.

		SELECT COUNT(*) INTO svt_cuantos
		FROM si_solicitud_movil
		WHERE si_solicitud_movil.rfc = cRfc;


		IF svt_cuantos IS NULL THEN
		   LET svt_cuantos = 0;
		END IF;
		
		
		IF Cfolio_procesado = "1" OR Cfolio_procesado IS NULL AND svt_cuantos = 0 THEN
		--TRACE '------------------------------------------------------------------------------------------------------------ ENTRA IF Cfolio_procesado = "1" OR Cfolio_procesado IS NULL AND svt_cuantos = 0';
			INSERT INTO si_solicitud_movil(numcte,nombre1,nombre2,apell_paterno,apell_materno,fecha_nac,rfc,cte_coppel,numcte_coppel,folio_procesado,status_valua,ejecutivo)
			VALUES (cNumcte,TRIM(UPPER(pNombre1)),TRIM(UPPER(pNombre2)),TRIM(UPPER(pApell_paterno)),TRIM(UPPER(pApell_materno)),pFecha_nac,TRIM(UPPER(cRfc)),TRIM(UPPER(pCte_coppel)),pNumcte_coppel,"0",NULL,pEjecutivo);

			--AGREGADO
			SELECT MAX(id)
			INTO iCteId
			FROM si_solicitud_movil
			WHERE numcte =cNumcte;

			SELECT COUNT(*) INTO svt_cuantos2 FROM si_relacion_ctebcplcpl WHERE numcte_banco = cNumcte and tipo_relacion<>0;

			IF svt_cuantos2>0 THEN
			--TRACE '------------------------------------------------------------------------------------------------------------ ENTRA IF svt_cuantos2>0';

				LET Ccte_coppel="N";
				LET CNumcte_coppel='';
				UPDATE bdinteg:si_solicitud_movil
				SET numcte_coppel=CNumcte_coppel, cte_coppel="S"
				WHERE rfc = cRfc;

				---Valida si ya tiene otros productos.

				SELECT COUNT(*)
				INTO svt_cuantos2
				FROM bdisolic:ss_solicitudes
				WHERE bdisolic:ss_solicitudes.status_solicitud IN ("AT","AP")
				AND bdisolic:ss_solicitudes.num_producto = "6001"
				AND bdisolic:ss_solicitudes.numcte = cNumcte
				AND bdisolic:ss_solicitudes.empresa = "001";

				--SE VALIDA QUE EL CLIENTE NO TENGA SOLICITUD DE COPPEL EN AT O AP
				SELECT COUNT(*)
				INTO svt_cuantos3
				FROM bdisolic:ss_solicitudes
				WHERE bdisolic:ss_solicitudes.status_solicitud IN ("AT","AP")
				AND bdisolic:ss_solicitudes.num_producto = "6500"
				AND bdisolic:ss_solicitudes.numcte = cNumcte
				AND bdisolic:ss_solicitudes.empresa = "001";

				IF CNumcte_coppel<>'' AND svt_cuantos2 > 0 THEN
				   LET Ccte_coppel = "A";
				END IF;

				IF CNumcte_coppel<>'' AND svt_cuantos2 = 0 THEN
				   LET Ccte_coppel = "S";
				END IF;

				IF CNumcte_coppel IS NULL AND svt_cuantos2 > 0 THEN
				   LET Ccte_coppel = "B";
				END IF;

				IF CNumcte_coppel IS NULL AND svt_cuantos2 = 0 THEN
				   LET Ccte_coppel = "N";
				END IF;

				IF CNumcte_coppel IS NULL AND svt_cuantos3 > 0 THEN
				   LET Ccte_coppel = "S";
				END IF;

				IF CNumcte_coppel IS NULL AND (svt_cuantos2 > 0 AND svt_cuantos3 > 0) THEN
					LET Ccte_coppel = "A";
				END IF;

				UPDATE bdinteg:si_solicitud_movil
				SET cte_coppel=Ccte_coppel, numcte_coppel=CNumcte_coppel
				WHERE rfc = cRfc;

			ELSE
			--TRACE '------------------------------------------------------------------------------------------------------------ ENTRA ELSE svt_cuantos2>0';

				LET Ccte_coppel="N";
				LET CNumcte_coppel='';

				SELECT MAX(id)
				INTO iCteId
				FROM si_solicitud_movil
				WHERE rfc = cRfc;

				SELECT cte_coppel, numcte_coppel
				INTO Ccte_coppel,CNumcte_coppel
				FROM si_solicitud_movil
				WHERE id = iCteId;

				SELECT cliente
				INTO CNumcte_coppel
				FROM si_relacion_ctebcplcpl
				WHERE numcte_banco = cNumcte and tipo_relacion<>0;

				SELECT COUNT(*)
				INTO svt_cuantos2
				FROM bdisolic:ss_solicitudes
				WHERE bdisolic:ss_solicitudes.status_solicitud IN ("AT","AP")
				AND bdisolic:ss_solicitudes.num_producto = "6001"
				AND bdisolic:ss_solicitudes.numcte = cNumcte
				AND bdisolic:ss_solicitudes.empresa = "001";

				--SE VALIDA QUE EL CLIENTE NO TENGA SOLICITUD DE COPPEL EN AT O AP
				SELECT COUNT(*)
				INTO svt_cuantos3
				FROM bdisolic:ss_solicitudes
				WHERE bdisolic:ss_solicitudes.status_solicitud IN ("AT","AP")
				AND bdisolic:ss_solicitudes.num_producto = "6500"
				AND bdisolic:ss_solicitudes.numcte = cNumcte
				AND bdisolic:ss_solicitudes.empresa = "001";

				IF CNumcte_coppel<>'' AND svt_cuantos2 > 0 THEN
				   LET Ccte_coppel = "A";
				END IF;

				IF CNumcte_coppel<>'' AND svt_cuantos2 = 0 THEN
				   LET Ccte_coppel = "S";
				END IF;

				IF CNumcte_coppel IS NULL AND svt_cuantos2 > 0 THEN
				   LET Ccte_coppel = "B";
				END IF;

				IF CNumcte_coppel IS NULL AND svt_cuantos2 = 0 THEN
				   LET Ccte_coppel = "N";
				END IF;

				IF CNumcte_coppel IS NULL AND svt_cuantos3 > 0 THEN
				   LET Ccte_coppel = "S";
				END IF;

				IF CNumcte_coppel IS NULL AND (svt_cuantos2 > 0 AND svt_cuantos3 > 0) THEN
					LET Ccte_coppel = "A";
				END IF;

				UPDATE bdinteg:si_solicitud_movil
				SET cte_coppel=Ccte_coppel, numcte_coppel=""
				WHERE rfc = cRfc;

			END IF;
		ELSE
		--TRACE '------------------------------------------------------------------------------------------------------------ ENTRA ELSE Cfolio_procesado = "1" OR Cfolio_procesado IS NULL AND svt_cuantos = 0';
		
			LET Ccte_coppel="N";
			LET CNumcte_coppel='';

			SELECT MAX(id)
			INTO iCteId
			FROM si_solicitud_movil
			WHERE rfc = cRfc;

			SELECT cte_coppel, numcte_coppel
			INTO Ccte_coppel,CNumcte_coppel
			FROM si_solicitud_movil
			WHERE id=iCteId;

			---Valida si ya tiene otros productos.

			SELECT cliente
			INTO CNumcte_coppel
			FROM si_relacion_ctebcplcpl
			WHERE numcte_banco = cNumcte and tipo_relacion<>0;

			SELECT COUNT(*)
			INTO svt_cuantos2
			FROM bdisolic:ss_solicitudes
			WHERE bdisolic:ss_solicitudes.status_solicitud IN ("AT","AP")
			AND bdisolic:ss_solicitudes.num_producto = "6001"
			AND bdisolic:ss_solicitudes.numcte = cNumcte
			AND bdisolic:ss_solicitudes.empresa = "001";

			--SE VALIDA QUE EL CLIENTE NO TENGA SOLICITUD DE COPPEL EN AT O AP
			SELECT COUNT(*)
			INTO svt_cuantos3
			FROM bdisolic:ss_solicitudes
			WHERE bdisolic:ss_solicitudes.status_solicitud IN ("AT","AP")
			AND bdisolic:ss_solicitudes.num_producto = "6500"
			AND bdisolic:ss_solicitudes.numcte = cNumcte
			AND bdisolic:ss_solicitudes.empresa = "001";

			IF CNumcte_coppel<>'' AND svt_cuantos2 > 0 THEN
			LET Ccte_coppel = "A";
			END IF;

			IF CNumcte_coppel<>'' AND svt_cuantos2 = 0 THEN
			LET Ccte_coppel = "S";
			END IF;

			IF CNumcte_coppel IS NULL AND svt_cuantos2 > 0 THEN
			LET Ccte_coppel = "B";
			END IF;

			IF CNumcte_coppel IS NULL AND svt_cuantos2 = 0 THEN
			LET Ccte_coppel = "N";
			END IF;

			IF CNumcte_coppel IS NULL AND svt_cuantos3 > 0 THEN
			LET Ccte_coppel = "S";
			END IF;
			
			--Agrega un nuevo registro en caso de que ya exista uno con los campos folio_procesado = 0 y status_valua = 0
			IF Cfolio_procesado = "0" AND Cstatus_valua = 0 THEN
				INSERT INTO si_solicitud_movil(numcte,nombre1,nombre2,apell_paterno,apell_materno,fecha_nac,rfc,cte_coppel,numcte_coppel,folio_procesado,status_valua,ejecutivo)
				VALUES (cNumcte,TRIM(UPPER(pNombre1)),TRIM(UPPER(pNombre2)),TRIM(UPPER(pApell_paterno)),TRIM(UPPER(pApell_materno)),pFecha_nac,TRIM(UPPER(cRfc)),TRIM(UPPER(Ccte_coppel)),CNumcte_coppel,"0",NULL,pEjecutivo);
				
				--Asigna el nuevo ID del registro generado a la salida del SP
				SELECT MAX(id) INTO iCteId FROM si_solicitud_movil WHERE numcte =cNumcte;
			END IF;

		END IF;
	ELSE
	--TRACE '------------------------------------------------------------------------------------------------------------ ENTRA ELSE SNrows > 0';

		LET svt_cuantos = 0;
		--Valida que si existe el RFC no se Duplique el Registro.

		SELECT COUNT(*) INTO svt_cuantos
		FROM si_solicitud_movil
		WHERE si_solicitud_movil.rfc = cRfc;

		SELECT folio_procesado, status_valua
		INTO Cfolio_procesado, Cstatus_valua
		FROM si_solicitud_movil
		WHERE rfc = cRfc and folio_procesado<>'1';

		IF Cstatus_valua IS NULL THEN
		   LET Cstatus_valua = 0;
		   LET Ccte_coppel="N";
		   LET CNumcte_coppel='';
		   IF Cfolio_procesado=0 THEN
				--INSERT INTO "informix".si_bitacora_movil (Id_Movil, Ejecutivo, Nombre1, Nombre2, Apell_paterno,  Apell_materno, Fecha_nac, proceso, fecha, hora)
				--  VALUES(iCteId,pEjecutivo,UPPER(pNombre1),UPPER(pNombre2),UPPER(pApell_paterno),UPPER(pApell_materno),pFecha_nac,'sp_valida_ctemovil 4',current,current);
				UPDATE "informix".si_solicitud_movil SET ejecutivo=pEjecutivo, fecha_insert=current, fecha_hora=current WHERE id=iCteId;
		   END IF;
		END IF;

		--SI status_valua=1 y Folio Procesado=0 EL CLIENTE TIENE SOLICITUD EN PROCESO
		IF Cstatus_valua=1 AND Cfolio_procesado=0 THEN
			LET cCodRet = '00002';
			LET CDesc = 'El Cliente tiene solicitud en Proceso.';

			INSERT INTO "informix".si_bitacora_movil (Id_Movil, Ejecutivo, Nombre1, Nombre2, Apell_paterno,  Apell_materno, Fecha_nac, proceso, fecha, hora)
				VALUES(iCteId,pEjecutivo,UPPER(pNombre1),UPPER(pNombre2),UPPER(pApell_paterno),UPPER(pApell_materno),pFecha_nac,'sp_valida_ctemovil 5',current,current);

			RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
		END IF;

		IF svt_cuantos IS NULL THEN
		   LET svt_cuantos = 0;
		END IF;

		IF svt_cuantos = 0 THEN

			INSERT INTO si_solicitud_movil(numcte,nombre1,nombre2,apell_paterno,apell_materno,fecha_nac,rfc,cte_coppel,numcte_coppel,folio_procesado,status_valua,ejecutivo)
			VALUES (cNumcte,TRIM(UPPER(pNombre1)),TRIM(UPPER(pNombre2)),TRIM(UPPER(pApell_paterno)),TRIM(UPPER(pApell_materno)),pFecha_nac,TRIM(UPPER(cRfc)),TRIM(UPPER(pCte_coppel)),pNumcte_coppel,"0",NULL,pEjecutivo);

			SELECT MAX(id)
			INTO iCteId
			FROM si_solicitud_movil;

			SELECT COUNT(*) INTO svt_cuantos2 FROM si_relacion_ctebcplcpl WHERE numcte_banco = cNumcte and tipo_relacion<>0;

			IF svt_cuantos2>0 THEN
				LET Ccte_coppel="S";
					UPDATE bdinteg:si_solicitud_movil
					SET numcte_coppel=CNumcte_coppel, cte_coppel="S"
					--WHERE numcte = cNumcte;
					WHERE rfc = cRfc and folio_procesado<>'1';
			ELSE
					UPDATE bdinteg:si_solicitud_movil
					SET cte_coppel="N", numcte_coppel=""
					--WHERE numcte = cNumcte;
					WHERE rfc = cRfc and folio_procesado<>'1';
				LET Ccte_coppel="N";
				LET CNumcte_coppel='';
			END IF;
		ELSE

			 SELECT MAX(id)
			 INTO iCteId
			 FROM si_solicitud_movil
			 WHERE rfc = cRfc;

			LET Ccte_coppel="N";
			LET CNumcte_coppel='';
			
			 SELECT cte_coppel, numcte_coppel
			 INTO Ccte_coppel,CNumcte_coppel
			 FROM si_solicitud_movil
			 WHERE id = iCteId;
		END IF;
	END IF;
ELSE
--TRACE '------------------------------------------------------------------------------------------------------------ ENTRA ELSE NVL(cCodRetSp,) = 00000';
	LET cCodRet = cCodRetSp;	--ERROR AL GENERAR DEL sp_calcularrfc
        INSERT INTO "informix".si_bitacora_movil (Id_Movil, Ejecutivo, Nombre1, Nombre2, Apell_paterno,  Apell_materno, Fecha_nac, proceso, fecha, hora)
               VALUES(iCteId,pEjecutivo,UPPER(pNombre1),UPPER(pNombre2),UPPER(pApell_paterno),UPPER(pApell_materno),pFecha_nac,'sp_valida_ctemovil 6',current,current);
	RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
END IF;

	--TRACE '------------------------------------------------------------------------------------------------------------ ENTRA ULTIMA SECCION';
	LET CDesc = 'Validacion exitosa';
    INSERT INTO "informix".si_bitacora_movil (Id_Movil, Ejecutivo, Nombre1, Nombre2, Apell_paterno,  Apell_materno, Fecha_nac, proceso, fecha, hora)
        VALUES(iCteId,pEjecutivo,UPPER(pNombre1),UPPER(pNombre2),UPPER(pApell_paterno),UPPER(pApell_materno),pFecha_nac,'sp_valida_ctemovil 7',current,current);
RETURN cCodRet,iCteId,cNumcte,Ccte_coppel,CNumcte_coppel,CDesc;
END
END PROCEDURE
DOCUMENT
'AUTOR: 95689966, PEDRO JIMENEZ GUZMAN',
'FOLIO: 1484',
'DESCRIPCION: INSERTA DATOS EN LA TABLA SI_SOLICITUD_MOVIL',
'FECHA: 10/02/2015',
'VERSION: 10022015.1144',
'SUSTENTO: SE DEFINIO CON JAIME GONZALEZ Y VICTOR HUGO SANCHEZ MENDOZA EN EL REQUERIMIENTO',
'RQI 61 116? Alta movil',
'DESCRIPCION: VALIDACION DEL NUEVO NUMERO DE CLIENTE Y SU ID',
'FECHA: 19/03/2015',
'VERSION: 10022015.1145',
'MODIFICADO:ANJ SE AGREGA VALIDACION PARA TOMAR ESTATUS AP Y AT EN SOLICITUDES DE BANCO',
'SE AGREGA ADEMAS LA BUSQUEDA DE UNA SOLICITUD EN AP O AT DE PRODUCTO COPPEL PARA VERIFICAR SI ES CTE COPPEL',
'BD: BDINTEG',
'INC 61 386',
'DESCRIPCION: Update ',
'FECHA: 12/07/2022',
'MODIFICADO: El motivo por el cual se realiza la modificaciÃ³n, es porque hay solicitudes posteriores a la primera en las cuales no se actualizan los datos y las solicitudes quedan atoradas.Se modifica bdinteg:sp_valida_ctemovil.sql y se agrega un update para que se actualicen los siguientes campos fecha_insert, fecha_hora y ejecutivo',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_bitacora_tipocapturadir(pIdentificador CHAR, pNumCte CHAR(20), pSucursal CHAR(4), pEjecutivo CHAR(9))

	RETURNING CHAR(5);

	DEFINE pFecha_insert  DATETIME YEAR TO FRACTION;
	DEFINE cCodret		  CHAR(5);
	DEFINE sql_err 		  INTEGER;
	
/*****************************************
 CREADO POR: JOSÃ DE JESÃS INZUNZA MURO.
 FECHA: 22/04/2022.
 *****************************************/

	--ASIGANACION DE VARIABLES
	LET pFecha_insert  = CURRENT;
	LET sql_err 	   = 0;
	LET cCodret        = '00000';
	
BEGIN
	
	ON EXCEPTION SET sql_err

		RETURN sql_err;

    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
	--SET DEBUG FILE TO "/home/sysifx/JesusI/Domicilio_localizacion/sp_bitacora_tipocapturadir.out";
    --TRACE ON;
	
	INSERT INTO "informix".si_bitacora_capdireccion(identificador, numcte, sucursal, ejecutivo, fecha_insert) VALUES (pIdentificador, pNumCte, pSucursal, pEjecutivo, pFecha_insert);
	LET cCodret = '00000';
	
	RETURN cCodret;
	
END;
END PROCEDURE
DOCUMENT
'CREADO: 90233836 - JosÃ© de JesÃºs Inzunza Muro.',
'Folio: 850',
'RQM: RQM 09 531-2-Adendum Domicilio de localizaciÃ³n de Cliente ',
'DescripcÃ­on: Se crea procedimiento almacenado para insertar registro en la tabla si_bitacora_capdireccion.',
'Fecha: 2022/04/22',
'Solicito: Abraham Narvaez',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_inser_alerta_exlimblo(pEmpresa Char(3),pSucursal Char(4), pEjecutivo Char(8), pMovimiento Char(1), pMonto_exce DECIMAL(19,2), pHora_alerta DATETIME YEAR TO SECOND, pHora_reemb DATETIME YEAR TO SECOND, pImport_reemb DECIMAL(19,2), pBloqueo Char(1))

--DATOS A REGRESAR---												 
RETURNING CHAR(6) AS vCodret;
	  
--DECLARACIONES.
DEFINE iSqlErr         	 INTEGER;
DEFINE vCodret           CHAR(5);
DEFINE iConsecutivo      INTEGER;
DEFINE vFechaHoy         DATE;

---INICIALIZACIONES
LET iSqlErr          = 0;
LET vCodret          = "00001";
LET iConsecutivo     = 0;


BEGIN
    ON EXCEPTION SET iSqlErr	
		IF 	iSqlErr <> 0 THEN
			RETURN iSqlErr;
		END IF;
	END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO  "/home/sysifx/JoseLuis/Folio376/sp_inser_alerta_exlimblo.out";
	--TRACE ON;
	
	--- Verifica recepcion correcta de datos
	IF pMovimiento = '1' THEN 
		IF pEmpresa = '' or pSucursal = '' or pEjecutivo = '' or  pMonto_exce = '' or NVL(pHora_alerta, '' )= '' or pImport_reemb = '' or pBloqueo = '' THEN 
			LET vCodret = '00002';
		ELSE 
			SELECT fecha_hoy 
			INTO   vFechaHoy
			FROM   "informix".si_fechas;
			
			SELECT NVL(MAX(num_alerta::integer),0)
			INTO iConsecutivo
			from "informix".si_fuera_rango where ejecutivo = pEjecutivo
			AND date(hora_alerta) = vFechaHoy; 
			
			IF iConsecutivo IS NULL THEN
				LET iConsecutivo = 1;
			ELSE
				LET iConsecutivo = iConsecutivo + 1; 
			END IF;
			
			INSERT INTO "informix".si_fuera_rango (empresa, sucursal, ejecutivo, num_alerta, movimiento, monto_exce, hora_alerta, hora_reemb, import_reemb, bloqueo)
			VALUES (pEmpresa, pSucursal, pEjecutivo, iConsecutivo::char(3), pMovimiento, pMonto_exce, pHora_alerta, '', '', pBloqueo);

			LET vCodret = '00000';
		END IF;

	ELIF pMovimiento = '2' THEN
		IF pEmpresa = '' or pSucursal = '' or pEjecutivo = '' or  pMonto_exce = '' or NVL(pHora_reemb, '') = '' or pImport_reemb = '' or pBloqueo = '' THEN 
			LET vCodret = '00002';
		ELSE 
			INSERT INTO "informix".si_fuera_rango (empresa, sucursal, ejecutivo, num_alerta, movimiento, monto_exce, hora_alerta, hora_reemb, import_reemb, bloqueo)
		    VALUES (pEmpresa, pSucursal, pEjecutivo, '', pMovimiento, '', '', pHora_reemb, pImport_reemb, '0');
			
			LET vCodret = '00000';
		END IF;
	ELSE
		LET vCodret = '00001';
	END IF;
	
		RETURN vCodret;
END;
END PROCEDURE
DOCUMENT
'Autor: 97839523 - Jose Luis Garcia',
'Folio: 376.1-Asignación de Nuevos Límites de Efectivo en Ventanilla',
'Fecha: 02-03-2018',
'Modificación:  Se crea procedimiento almacenado SP_INSER_ALERTA_EXLIMBLO para insertar las alertas y bloeques en la tabla si_fuera_rango.',
'Solicita: ABRAHAM NERVAEZ', 
'Base de datos: BDINTEG';

CREATE PROCEDURE "informix".sp_validacion_reporte(pNumReporte CHAR(4),
												  pEmpresa CHAR(3),
												  pSucursal CHAR(4), 
												  pFecha DATE, 	   
												  pUsuario CHAR(10), 
												  pcTipo CHAR(1), 
												  pOpcion CHAR(1) 
												  )
RETURNING
	CHAR(5) 	AS codRet,
	CHAR(50) 	AS rMensaje;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_validacion_reporte"
Folio.........: 778 - Fin de dia, sp generico.
Autor.........: 90127902 - Epigmenio Martinez Pedraza
Fecha.........: 11/03/2022
Solicita......: 
BD............: bdinteg
*/

-- 
-- ***************************************************************************
	-- DEFINICION DE VARIABLES.
-- ***************************************************************************
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje VARCHAR(50);
	DEFINE cNumcteTmp VARCHAR(20);
	DEFINE dtFechaHoy DATE;
	DEFINE rsQuery VARCHAR(50);
	DEFINE cNumcte VARCHAR(20);

-- INICIALIZACION DE VARIABLE.
	LET cCodRet 			= '00004';
	LET cMensaje 			= 'Ocurrio un error.';
	LET iSqlErr				= 0;
	LET rsQuery				= '';
	LET cNumcte 			= '';
	LET cNumcteTmp 			= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = 'Ocurrio un error.';
			RETURN cCodRet, cMensaje WITH RESUME;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
	IF ( NVL(pNumReporte, '') != '' ) THEN
		IF (pNumReporte = '756') THEN --REPORTE SPEI                                                     
			--pSucursal = sucursal, pFecha = dtfechacaptura
			IF (NVL(pSucursal, '') <> '' OR NVL(pFecha, '')<>'') THEN
				SELECT LIMIT 1 pago.vchrclaverastreo
				INTO rsQuery
				  FROM bdispei: tblpago pago,
						   bdispei: tbldetranpago det
				 WHERE pago.dtfechacaptura = pFecha
				   AND pago.chrsentidopago = 'E'
				   AND pago.intcvetipopago = 1
				   AND pago.vchrclaverastreo = det.clave_rastreo
				   AND det.transacc = "0274"        
				   AND det.sucursal = pSucursal                
				   AND pago.chrestatusenvio IN ('L','D','C');
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:756, los parametros no pueder ser vacios';
			END IF;
			
		ELIF (pNumReporte = "802") THEN --VALIDAR EL B23  			
				--PARAMETROS: pOpcion CHAR(1), pNumSucursal CHAR(4), pEmpresa CHAR(3),pEjecutivo CHAR(8)
				--opcionales: pUsuario
			IF(NVL(pSucursal, '') <> '' AND NVL(pEmpresa, '') <> '') THEN
				SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas WHERE empresa = pEmpresa;
				
				SELECT LIMIT 1 num_sucursal_retencion INTO rsQuery FROM bdisuc:"informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal	
																		AND empresa_retiene = pEmpresa 
																		AND fecha_insert = dtFechaHoy;
																				
				-- IF pUsuario = '' AND pOpcion = '1' THEN
					-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos WHERE num_sucursal_retencion = pSucursal
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy
				
				-- ELIF pUsuario <> ''  AND pOpcion = '1' THEN
					-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy 
																				-- AND ejecutivo_insert = pUsuario;
				-- ELIF pOpcion = '2' THEN
					-- IF pUsuario = '' THEN
						-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal	
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy;
					-- ELIF pUsuario <> '' THEN
						-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos WHERE num_sucursal_retencion = pSucursal 
																			   -- AND empresa_retiene = pEmpresa 
																			   -- AND fecha_insert = dtFechaHoy
																			   -- AND ejecutivo_insert = pUsuario;
					-- END IF;	
					
				--END IF;
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:802, los parametros no pueder ser vacios';
			END IF;
			
		ELIF (pNumReporte = "763") THEN  --Validar el A38.- REPORTE OPERACIONES TEF
			
				--PARAMETROS: pSucursal CHAR (4), pFechaConsulta DATE
				--opcionales: 
			IF(NVL(pSucursal, '') <> '' AND NVL(pFecha, '') <> '') THEN
				SELECT limit 1 sucursal	
				INTO rsQuery 
				FROM bditef:"informix".tef_operaciones
				WHERE sucursal = pSucursal
					AND cve_status <> '04'
					AND fecha_trans  = pFecha;
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:763, los parametros no pueder ser vacios';
			END IF;
		ELIF (pNumReporte = "751") THEN  --Validar el PS1
			--PARAMETROS: (cSucursal CHAR(4))
			--opcionales: 
			IF (NVL(pSucursal, '')<> '' AND LENGTH(pSucursal) = 4) THEN						
				--Obtension de la fecha actual configurada.
				SELECT fecha_hoy INTO dtFechaHoy FROM bdisac:"informix".sac_fechas;

				SELECT LIMIT 1 id_sucursal
				INTO rsQuery
				FROM bdisac:"informix".sac_movimientos
				WHERE fecha_pago = dtFechaHoy
				AND id_sucursal = pSucursal;
			ELSE
				LET cCodRet = "00001";
				LET cMensaje = 'Rep:751, los parametros no pueder ser vacios';
			
			END IF;
			
		ELIF (pNumReporte = "761") THEN --Validar el TC1.- PAGO TDC OTROS BANCOS
			--PARAMETROS: (pdFecha DATE, pcSucursal CHAR(4),pcTipo CHAR(1))
			--opcionales: 
			--Se valida el tipo de busqueda
			IF (NVL(pcTipo, '')<> '' AND NVL(pFecha, '')<> '' AND NVL(pSucursal, '')<> '' ) THEN
				IF pcTipo = 1 THEN
					SELECT LIMIT 1 sucursal
					INTO rsQuery
					FROM bdicheq:"informix".sc_movdia
					WHERE empresa = '001' AND transacc in('1193' ,'1194') --ARM_NEORIS CAMBIO DE AND transacc = '1193' AND transacc = '1194' POR transacc in('1193' ,'1194')
					AND fech_alt = pFecha
					AND sucursal = pSucursal;
				ELIF pcTipo = 2 THEN
					--EN ESTA SECCION ES PARA LA OBTENCION DE MOVIMIENTOS DEL HISTORICO
					--DE NO SER NECESARIO EL PARAMETRO pcTipo QUEDARIA ELIMINADO U OPCIONAL.
					LET cCodRet				= '00000';
				END IF;
			ELSE
				LET cCodRet = "00001";
				LET cMensaje = 'Rep:761, los parametros no pueder ser vacios';
			END IF;
				
		ELIF (TRIM(pNumReporte) = "107") THEN -- TRIM(pTipoRep)    Validar el RE1.-REVISION DE EXPEDIENTES
				--PARAMETROS: (pdFecha DATE, pcSucursal CHAR(4),pcTipo CHAR(1),piRegistro INTEGER)
				--opcionales:
				-- "informix".sp_revision_expediente_cte_reporte(pEmpresa, pSucursal, pUsuario, '', '', pRegistros)
			SELECT LIMIT 1 scte.numcte
			INTO cNumcte
			FROM bdinteg:"informix".si_cliente scte
				INNER JOIN bdinteg:"informix".si_reporte_expediente srptexp
					ON (scte.numcte = srptexp.numcte)
			WHERE scte.empresa = pEmpresa
			AND srptexp.empresa = pEmpresa
			AND TRIM(scte.numcte) != ''
			AND TRIM(scte.tipo_cliente) = '1'
			AND TRIM(scte.sucursal)  = TRIM(pSucursal)
			AND scte.fecha_insert = pFecha;
			
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				LET cCodRet = '00000';
				LET cMensaje = 'Existen movimientos.';
			ELSE
				SELECT LIMIT 1 scte.numcte
				INTO cNumcte
				FROM bdicheq: "informix".sc_maechq mae
				INNER JOIN bdicheq: "informix".sc_maenoc noc
					ON (noc.cuenta = mae.cuenta)
				INNER JOIN bdinteg: "informix".si_cliente scte
					ON (scte.empresa = pEmpresa AND scte.numcte = mae.num_cte)
				INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
					ON (srptexp.numcte = scte.numcte AND srptexp.empresa = pEmpresa)
				WHERE  mae.status_cta = '1'
				AND noc.fecha_alta = pFecha
				AND mae.empresa = pEmpresa
				AND mae.sucursal = pSucursal
				AND scte.fecha_insert < pFecha
				AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
				
				IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					LET cCodRet = '00000';
					LET cMensaje = 'Existen movimientos.';
				ELSE
					FOREACH WITH HOLD
						SELECT scte.numcte
						INTO cNumcte
						FROM bdisolic:"informix".ss_solicitudes sol
						INNER JOIN bdinteg:"informix".si_cliente scte
							ON (scte.empresa = pEmpresa	AND scte.numcte = sol.numcte)
						INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
							ON (srptexp.numcte = scte.numcte)
						WHERE scte.fecha_insert < sol.fecha_insert
						AND srptexp.empresa = pEmpresa
						AND sol.empresa = pEmpresa
						AND sol.sucursal = pSucursal					
						AND sol.fecha_insert = pFecha					
						AND sol.status_solicitud NOT IN ('PC','AN')
						
						LET cNumcteTmp = '';
						
						SELECT LIMIT 1 mae.num_cte
							INTO cNumcteTmp
						FROM bdicheq:sc_maechq mae
						INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta
						and noc.fecha_alta = pFecha)
						WHERE  mae.status_cta    = '1'
						AND mae.empresa = pEmpresa
						AND mae.num_cte = cNumcte
						AND mae.sucursal = pSucursal
						AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
							
						IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
							LET cCodRet = '00000';
							LET cMensaje = 'Existen movimientos.';
							EXIT FOREACH;
						END IF;
					END FOREACH;
					
					IF cCodRet != '00000' THEN
						FOREACH WITH HOLD
							SELECT scte.numcte
								INTO cNumcte
								FROM bdisolic:"informix".ss_solicitudes sssol
								INNER JOIN bdisolic:"informix".ss_autorizacion ssaut
									ON (ssaut.num_solicitud = sssol.num_solicitud
									AND ssaut.status_solicitud = sssol.status_solicitud)
								INNER JOIN bdinteg:"informix".si_cliente scte
									ON (scte.numcte = sssol.numcte)
								INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
									ON (srptexp.numcte = sssol.numcte)
								WHERE sssol.empresa = pEmpresa
								AND srptexp.empresa = pEmpresa
								AND ssaut.empresa = pEmpresa
								AND ssaut.fecha_insert = pFecha
								AND sssol.status_solicitud = 'AP'
								AND sssol.sucursal = pSucursal
								AND scte.fecha_insert < pFecha
								
								LET cNumcteTmp = '';
								
								SELECT LIMIT 1 mae.num_cte
										INTO cNumcteTmp
									FROM bdicheq:sc_maechq mae
									INNER JOIN bdicheq:sc_maenoc noc
										ON (noc.cuenta = mae.cuenta
											AND noc.fecha_alta = pFecha)
									WHERE  mae.status_cta = '1'
									AND mae.empresa = pEmpresa
									AND mae.num_cte = cNumcte
									AND mae.sucursal = pSucursal
									AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
								
								IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
									SELECT LIMIT 1 sol.numcte
											INTO cNumcteTmp
										FROM bdisolic:"informix".ss_solicitudes sol
										WHERE sol.empresa = pEmpresa
										AND sol.numcte = cNumcte
										AND sol.sucursal = pSucursal
										AND sol.fecha_insert = pFecha
										AND sol.status_solicitud NOT IN ('PC','AN');
										
										IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
											LET cCodRet = '00000';
											LET cMensaje = 'Existen movimientos.';
											EXIT FOREACH;
										END IF;
								END IF;
						END FOREACH;
						
						IF cCodRet != '00000' THEN
							FOREACH WITH HOLD
								SELECT cte5.numcte
									INTO cNumcte
								FROM bdinvers: "informix".sv_maeinv invers
								INNER JOIN bdinteg: "informix".si_cliente cte5
									ON (cte5.empresa = invers.empresa
									AND cte5.numcte = invers.num_cte)
								INNER JOIN 	bdinteg: "informix".si_reporte_expediente srptexp
									ON (srptexp.empresa = cte5.empresa AND srptexp.numcte = cte5.numcte)
								WHERE cte5.empresa = pEmpresa
								AND cte5.fecha_insert < invers.fecha_alta
								AND invers.fecha_alta = pFecha
								AND invers.sucursal = pSucursal
								AND invers.secuencia = 1

								LET cNumcteTmp = '';
								
								SELECT LIMIT 1  Mae.num_cte
									INTO cNumcteTmp
								FROM bdicheq:sc_maechq Mae
								INNER JOIN bdicheq:sc_maenoc noc
								ON (noc.cuenta = mae.cuenta
								AND noc.fecha_alta = pFecha)
								WHERE  Mae.status_cta = '1'
								AND Mae.empresa = pEmpresa
								AND Mae.num_cte = cNumcte
								AND mae.sucursal = pSucursal
								AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
								
								IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
									SELECT LIMIT 1 sol.numcte
										INTO cNumcteTmp 
									FROM bdisolic:"informix".ss_solicitudes   sol
									WHERE sol.empresa = pEmpresa
									AND sol.numcte = cNumcte
									AND sol.sucursal = pSucursal
									AND sol.fecha_insert = pFecha
									AND sol.status_solicitud NOT IN ('PC','AN');
									
									IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
										SELECT LIMIT 1 sol2.numcte
											INTO cNumcteTmp
										FROM bdisolic: "informix".ss_solicitudes sol2
										INNER JOIN bdisolic: "informix".ss_autorizacion aut
										ON (aut.empresa = sol2.empresa 
										AND aut.num_solicitud = sol2.num_solicitud
										AND aut.status_solicitud = sol2.status_solicitud)
										WHERE sol2.empresa = pEmpresa
										AND sol2.numcte = cNumcte
										AND sol2.status_solicitud = 'AP'
										AND sol2.sucursal = pSucursal
										AND aut.fecha_insert = pFecha;
										
										IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
											--LET rsQuery = cNumcte||cNumcteTmp;
											LET cCodRet = '00000';
											LET cMensaje = 'Existen movimientos.';
											EXIT FOREACH;
										END IF;									
									END IF;
								END IF;
							END FOREACH;
						END IF;
					END IF;
				END IF;
			END IF;
			
		ELSE
			LET cCodRet = '00004';
			LET cMensaje = 'No se encontro el reporte.';
		END IF;
		
		--ARM_NEORIS se evalua si el codigo ya viene exitoso. 
		IF (NVL(cCodRet, '') <> '00000') THEN
			IF (NVL(rsQuery, '') <> '') THEN
				LET cCodRet				= '00000';
				LET cMensaje 			= 'Existen movimientos.';
			ELSE
				LET cCodRet = '00003';
				LET cMensaje = 'No existen movimientos.';
			END IF;
		END IF;
		
	ELSE
		LET cCodRet = '00001';
		LET cMensaje = 'Uno de los parametros viene vacio';
		
	END IF; --validacion de pCveReporte en vacio
	RETURN cCodRet, cMensaje;						   
END;
END PROCEDURE
DOCUMENT
'Folio: 778',
'AUTOR : 90127902 - Epigmenio Martinez Pedraza',
'FECHA : 14/03/2022',
'SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_validacion_reporte',
'SOLICITA: ',
'BD: bdinteg',
'MODIFICADO: 18/05/2022 Alejandro Rodriguez Martinez(ARM_NEORIS)-Se agrego validacion de ccoderet antes de validar rsQuery y se cambio un where no procedente por un in ';

CREATE PROCEDURE "informix".sp_validacion_reporte_reing(pNumReporte CHAR(4),
												  pEmpresa CHAR(3),
												  pSucursal CHAR(4), 
												  pFecha DATE, 	   
												  pUsuario CHAR(10), 
												  pcTipo CHAR(1), 
												  pOpcion CHAR(1) 
												  )
RETURNING
	CHAR(5) 	AS codRet,
	CHAR(50) 	AS rMensaje;

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_validacion_reporte"
Folio.........: 778 - Fin de dia, sp generico.
Autor.........: 90127902 - Epigmenio Martinez Pedraza
Fecha.........: 11/03/2022
Solicita......: 
BD............: bdinteg
*/

-- 
-- ***************************************************************************
	-- DEFINICION DE VARIABLES.
-- ***************************************************************************
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje VARCHAR(50);
	DEFINE cNumcteTmp VARCHAR(20);
	DEFINE dtFechaHoy DATE;
	DEFINE rsQuery VARCHAR(50);
	DEFINE cNumcte VARCHAR(20);

-- INICIALIZACION DE VARIABLE.
	LET cCodRet 			= '00004';
	LET cMensaje 			= 'Ocurrio un error.';
	LET iSqlErr				= 0;
	LET rsQuery				= '';
	LET cNumcte 			= '';
	LET cNumcteTmp 			= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF(iSqlErr != 0) THEN
			LET cCodRet = iSqlErr;
			LET cMensaje = 'Ocurrio un error.';
			RETURN cCodRet, cMensaje WITH RESUME;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
			
	IF ( NVL(pNumReporte, '') != '' ) THEN
		IF (pNumReporte = '756') THEN --REPORTE SPEI                                                     
			--pSucursal = sucursal, pFecha = dtfechacaptura
			IF (NVL(pSucursal, '') <> '' OR NVL(pFecha, '')<>'') THEN
				SELECT LIMIT 1 pago.vchrclaverastreo
				INTO rsQuery
				  FROM bdispei: tblpago pago,
						   bdispei: tbldetranpago det
				 WHERE pago.dtfechacaptura = pFecha
				   AND pago.chrsentidopago = 'E'
				   AND pago.intcvetipopago = 1
				   AND pago.vchrclaverastreo = det.clave_rastreo
				   AND det.transacc = "0274"        
				   AND det.sucursal = pSucursal                
				   AND pago.chrestatusenvio IN ('L','D','C');
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:756, los parametros no pueder ser vacios';
			END IF;
			
		ELIF (pNumReporte = "810") THEN --VALIDAR EL B23 REING		
				--PARAMETROS: pOpcion CHAR(1), pNumSucursal CHAR(4), pEmpresa CHAR(3),pEjecutivo CHAR(8)
				--opcionales: pUsuario
			IF(NVL(pSucursal, '') <> '' AND NVL(pEmpresa, '') <> '') THEN
				SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas WHERE empresa = pEmpresa;
				
				SELECT LIMIT 1 num_sucursal_retencion INTO rsQuery FROM bdisuc:"informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal	
																		AND empresa_retiene = pEmpresa 
																		AND fecha_insert = dtFechaHoy;
																				
				-- IF pUsuario = '' AND pOpcion = '1' THEN
					-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos WHERE num_sucursal_retencion = pSucursal
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy
				
				-- ELIF pUsuario <> ''  AND pOpcion = '1' THEN
					-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy 
																				-- AND ejecutivo_insert = pUsuario;
				-- ELIF pOpcion = '2' THEN
					-- IF pUsuario = '' THEN
						-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pSucursal	
																				-- AND empresa_retiene = pEmpresa 
																				-- AND fecha_insert = dtFechaHoy;
					-- ELIF pUsuario <> '' THEN
						-- SELECT LIMIT 1 FROM "informix".ss_recibo_bym_falsos WHERE num_sucursal_retencion = pSucursal 
																			   -- AND empresa_retiene = pEmpresa 
																			   -- AND fecha_insert = dtFechaHoy
																			   -- AND ejecutivo_insert = pUsuario;
					-- END IF;	
					
				--END IF;
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:810, los parametros no pueder ser vacios';
			END IF;
			
		ELIF (pNumReporte = "763") THEN  --Validar el A38.- REPORTE OPERACIONES TEF
			
				--PARAMETROS: pSucursal CHAR (4), pFechaConsulta DATE
				--opcionales: 
			IF(NVL(pSucursal, '') <> '' AND NVL(pFecha, '') <> '') THEN
				SELECT limit 1 sucursal	
				INTO rsQuery 
				FROM bditef:"informix".tef_operaciones
				WHERE sucursal = pSucursal
					AND cve_status <> '04'
					AND fecha_trans  = pFecha;
			ELSE
				LET cCodRet = '00001';
				LET cMensaje = 'Rep:763, los parametros no pueder ser vacios';
			END IF;
		ELIF (pNumReporte = "751") THEN  --Validar el PS1
			--PARAMETROS: (cSucursal CHAR(4))
			--opcionales: 
			IF (NVL(pSucursal, '')<> '' AND LENGTH(pSucursal) = 4) THEN						
				--Obtension de la fecha actual configurada.
				SELECT fecha_hoy INTO dtFechaHoy FROM bdisac:"informix".sac_fechas;

				SELECT LIMIT 1 id_sucursal
				INTO rsQuery
				FROM bdisac:"informix".sac_movimientos
				WHERE fecha_pago = dtFechaHoy
				AND id_sucursal = pSucursal;
			ELSE
				LET cCodRet = "00001";
				LET cMensaje = 'Rep:751, los parametros no pueder ser vacios';
			
			END IF;
			
		ELIF (pNumReporte = "761") THEN --Validar el TC1.- PAGO TDC OTROS BANCOS
			--PARAMETROS: (pdFecha DATE, pcSucursal CHAR(4),pcTipo CHAR(1))
			--opcionales: 
			--Se valida el tipo de busqueda
			IF (NVL(pcTipo, '')<> '' AND NVL(pFecha, '')<> '' AND NVL(pSucursal, '')<> '' ) THEN
				IF pcTipo = 1 THEN
					SELECT LIMIT 1 sucursal
					INTO rsQuery
					FROM bdicheq:"informix".sc_movdia
					WHERE empresa = '001' AND transacc in('1193' ,'1194') --ARM_NEORIS CAMBIO DE AND transacc = '1193' AND transacc = '1194' POR transacc in('1193' ,'1194')
					AND fech_alt = pFecha
					AND sucursal = pSucursal;
				ELIF pcTipo = 2 THEN
					--EN ESTA SECCION ES PARA LA OBTENCION DE MOVIMIENTOS DEL HISTORICO
					--DE NO SER NECESARIO EL PARAMETRO pcTipo QUEDARIA ELIMINADO U OPCIONAL.
					LET cCodRet				= '00000';
				END IF;
			ELSE
				LET cCodRet = "00001";
				LET cMensaje = 'Rep:761, los parametros no pueder ser vacios';
			END IF;
				
		ELIF (TRIM(pNumReporte) = "107") THEN -- TRIM(pTipoRep)    Validar el RE1.-REVISION DE EXPEDIENTES
				--PARAMETROS: (pdFecha DATE, pcSucursal CHAR(4),pcTipo CHAR(1),piRegistro INTEGER)
				--opcionales:
				-- "informix".sp_revision_expediente_cte_reporte(pEmpresa, pSucursal, pUsuario, '', '', pRegistros)
			SELECT LIMIT 1 scte.numcte
			INTO cNumcte
			FROM bdinteg:"informix".si_cliente scte
				INNER JOIN bdinteg:"informix".si_reporte_expediente srptexp
					ON (scte.numcte = srptexp.numcte)
			WHERE scte.empresa = pEmpresa
			AND srptexp.empresa = pEmpresa
			AND TRIM(scte.numcte) != ''
			AND TRIM(scte.tipo_cliente) = '1'
			AND TRIM(scte.sucursal)  = TRIM(pSucursal)
			AND scte.fecha_insert = pFecha;
			
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				LET cCodRet = '00000';
				LET cMensaje = 'Existen movimientos.';
			ELSE
				SELECT LIMIT 1 scte.numcte
				INTO cNumcte
				FROM bdicheq: "informix".sc_maechq mae
				INNER JOIN bdicheq: "informix".sc_maenoc noc
					ON (noc.cuenta = mae.cuenta)
				INNER JOIN bdinteg: "informix".si_cliente scte
					ON (scte.empresa = pEmpresa AND scte.numcte = mae.num_cte)
				INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
					ON (srptexp.numcte = scte.numcte AND srptexp.empresa = pEmpresa)
				WHERE  mae.status_cta = '1'
				AND noc.fecha_alta = pFecha
				AND mae.empresa = pEmpresa
				AND mae.sucursal = pSucursal
				AND scte.fecha_insert < pFecha
				AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
				
				IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					LET cCodRet = '00000';
					LET cMensaje = 'Existen movimientos.';
				ELSE
					FOREACH WITH HOLD
						SELECT scte.numcte
						INTO cNumcte
						FROM bdisolic:"informix".ss_solicitudes sol
						INNER JOIN bdinteg:"informix".si_cliente scte
							ON (scte.empresa = pEmpresa	AND scte.numcte = sol.numcte)
						INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
							ON (srptexp.numcte = scte.numcte)
						WHERE scte.fecha_insert < sol.fecha_insert
						AND srptexp.empresa = pEmpresa
						AND sol.empresa = pEmpresa
						AND sol.sucursal = pSucursal					
						AND sol.fecha_insert = pFecha					
						AND sol.status_solicitud NOT IN ('PC','AN')
						
						LET cNumcteTmp = '';
						
						SELECT LIMIT 1 mae.num_cte
							INTO cNumcteTmp
						FROM bdicheq:sc_maechq mae
						INNER JOIN bdicheq:sc_maenoc noc on (noc.cuenta = mae.cuenta
						and noc.fecha_alta = pFecha)
						WHERE  mae.status_cta    = '1'
						AND mae.empresa = pEmpresa
						AND mae.num_cte = cNumcte
						AND mae.sucursal = pSucursal
						AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
							
						IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
							LET cCodRet = '00000';
							LET cMensaje = 'Existen movimientos.';
							EXIT FOREACH;
						END IF;
					END FOREACH;
					
					IF cCodRet != '00000' THEN
						FOREACH WITH HOLD
							SELECT scte.numcte
								INTO cNumcte
								FROM bdisolic:"informix".ss_solicitudes sssol
								INNER JOIN bdisolic:"informix".ss_autorizacion ssaut
									ON (ssaut.num_solicitud = sssol.num_solicitud
									AND ssaut.status_solicitud = sssol.status_solicitud)
								INNER JOIN bdinteg:"informix".si_cliente scte
									ON (scte.numcte = sssol.numcte)
								INNER JOIN bdinteg: "informix".si_reporte_expediente srptexp
									ON (srptexp.numcte = sssol.numcte)
								WHERE sssol.empresa = pEmpresa
								AND srptexp.empresa = pEmpresa
								AND ssaut.empresa = pEmpresa
								AND ssaut.fecha_insert = pFecha
								AND sssol.status_solicitud = 'AP'
								AND sssol.sucursal = pSucursal
								AND scte.fecha_insert < pFecha
								
								LET cNumcteTmp = '';
								
								SELECT LIMIT 1 mae.num_cte
										INTO cNumcteTmp
									FROM bdicheq:sc_maechq mae
									INNER JOIN bdicheq:sc_maenoc noc
										ON (noc.cuenta = mae.cuenta
											AND noc.fecha_alta = pFecha)
									WHERE  mae.status_cta = '1'
									AND mae.empresa = pEmpresa
									AND mae.num_cte = cNumcte
									AND mae.sucursal = pSucursal
									AND mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
								
								IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
									SELECT LIMIT 1 sol.numcte
											INTO cNumcteTmp
										FROM bdisolic:"informix".ss_solicitudes sol
										WHERE sol.empresa = pEmpresa
										AND sol.numcte = cNumcte
										AND sol.sucursal = pSucursal
										AND sol.fecha_insert = pFecha
										AND sol.status_solicitud NOT IN ('PC','AN');
										
										IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
											LET cCodRet = '00000';
											LET cMensaje = 'Existen movimientos.';
											EXIT FOREACH;
										END IF;
								END IF;
						END FOREACH;
						
						IF cCodRet != '00000' THEN
							FOREACH WITH HOLD
								SELECT cte5.numcte
									INTO cNumcte
								FROM bdinvers: "informix".sv_maeinv invers
								INNER JOIN bdinteg: "informix".si_cliente cte5
									ON (cte5.empresa = invers.empresa
									AND cte5.numcte = invers.num_cte)
								INNER JOIN 	bdinteg: "informix".si_reporte_expediente srptexp
									ON (srptexp.empresa = cte5.empresa AND srptexp.numcte = cte5.numcte)
								WHERE cte5.empresa = pEmpresa
								AND cte5.fecha_insert < invers.fecha_alta
								AND invers.fecha_alta = pFecha
								AND invers.sucursal = pSucursal
								AND invers.secuencia = 1

								LET cNumcteTmp = '';
								
								SELECT LIMIT 1  Mae.num_cte
									INTO cNumcteTmp
								FROM bdicheq:sc_maechq Mae
								INNER JOIN bdicheq:sc_maenoc noc
								ON (noc.cuenta = mae.cuenta
								AND noc.fecha_alta = pFecha)
								WHERE  Mae.status_cta = '1'
								AND Mae.empresa = pEmpresa
								AND Mae.num_cte = cNumcte
								AND mae.sucursal = pSucursal
								AND Mae.producto IN ('1300','1400','1500','1700','1800','1900','2000','1100');
								
								IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
									SELECT LIMIT 1 sol.numcte
										INTO cNumcteTmp 
									FROM bdisolic:"informix".ss_solicitudes   sol
									WHERE sol.empresa = pEmpresa
									AND sol.numcte = cNumcte
									AND sol.sucursal = pSucursal
									AND sol.fecha_insert = pFecha
									AND sol.status_solicitud NOT IN ('PC','AN');
									
									IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
										SELECT LIMIT 1 sol2.numcte
											INTO cNumcteTmp
										FROM bdisolic: "informix".ss_solicitudes sol2
										INNER JOIN bdisolic: "informix".ss_autorizacion aut
										ON (aut.empresa = sol2.empresa 
										AND aut.num_solicitud = sol2.num_solicitud
										AND aut.status_solicitud = sol2.status_solicitud)
										WHERE sol2.empresa = pEmpresa
										AND sol2.numcte = cNumcte
										AND sol2.status_solicitud = 'AP'
										AND sol2.sucursal = pSucursal
										AND aut.fecha_insert = pFecha;
										
										IF NVL(cNumcte, '') != '' AND NVL(cNumcteTmp, '') = '' THEN
											--LET rsQuery = cNumcte||cNumcteTmp;
											LET cCodRet = '00000';
											LET cMensaje = 'Existen movimientos.';
											EXIT FOREACH;
										END IF;									
									END IF;
								END IF;
							END FOREACH;
						END IF;
					END IF;
				END IF;
			END IF;
			
		ELSE
			LET cCodRet = '00004';
			LET cMensaje = 'No se encontro el reporte.';
		END IF;
		
		--ARM_NEORIS se evalua si el codigo ya viene exitoso. 
		IF (NVL(cCodRet, '') <> '00000') THEN
			IF (NVL(rsQuery, '') <> '') THEN
				LET cCodRet				= '00000';
				LET cMensaje 			= 'Existen movimientos.';
			ELSE
				LET cCodRet = '00003';
				LET cMensaje = 'No existen movimientos.';
			END IF;
		END IF;
		
	ELSE
		LET cCodRet = '00001';
		LET cMensaje = 'Uno de los parametros viene vacio';
		
	END IF; --validacion de pCveReporte en vacio
	RETURN cCodRet, cMensaje;						   
END;
END PROCEDURE
DOCUMENT
'AUTOR : 97283169 - Jose Luis Sepulveda Perez',
'FECHA : 22/04/2022',
'se crea clon del procedimiento "sp_validacion_reporte',
'BD: bdinteg',
'MODIFICADO: 18/05/2022 Alejandro Rodriguez Martinez(ARM_NEORIS)-Se agrego validacion de ccoderet antes de validar rsQuery y se cambio un where no procedente por un in ';

CREATE PROCEDURE "informix".sp_sucursal_coordenadas(pClaveBusqueda VARCHAR(18))

RETURNING CHAR(5), CHAR(10), CHAR(11);
-----Variables-----
DEFINE cSeccion 	CHAR(4);
DEFINE cSucursal 	CHAR(5);

DEFINE codret		CHAR(5);
DEFINE cLatitud		CHAR(10);
DEFINE cLongitud	CHAR(11);

DEFINE vsqlerr     	INTEGER;
DEFINE error_info   CHAR(40);
DEFINE isam_err     SMALLINT;

LET codret = '00000';
LET cLatitud = '';
LET cLongitud = '';

LET vsqlerr = 0;
LET error_info = 'Iniciando ejecucion';
LET isam_err = 0;
	
BEGIN
	--LET  latitud = '-15.434821248';
	--LET  longitud = '95.2646215';
	ON EXCEPTION SET vsqlerr, isam_err, error_info
		IF vsqlerr <> 0 THEN
			LET codret = vsqlerr;
			LET isam_err = isam_err;
			LET error_info = error_info;
			
			RETURN codret, '', '';
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	LET cSeccion = LEFT(pClaveBusqueda, 4); --Toma los primeros 4 caracteres del lado izquierdo
	
	SELECT FIRST 1 sucursal INTO cSucursal FROM bdinteg:si_seccion_sucursal WHERE seccion = cSeccion;
	
	SELECT latitud, longitud INTO cLatitud, cLongitud FROM bdinteg:si_ptf WHERE id_ptf = cSucursal AND tipo='S';
	
	IF((cLatitud IS NULL OR cLatitud = '' OR cLatitud='Null') OR (cLongitud IS NULL OR cLongitud = '' OR cLongitud='Null')) THEN
		SELECT latitud, longitud INTO cLatitud, cLongitud FROM bdinteg:si_ptf WHERE id_ptf = '6700' AND tipo='S';
	END IF;
	

    RETURN codret, cLatitud, cLongitud;
	 
END;
END PROCEDURE;