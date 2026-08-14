CREATE PROCEDURE "informix".sp_administra_tarjetas_ppass_web(pEmpresa VARCHAR(3), pNumcte VARCHAR(20), pNumCredito VARCHAR(20),
														pNumTarjeta VARCHAR(20), pProducto VARCHAR(4), pEstatus VARCHAR(3),
														pOpcion SMALLINT, pSecuencia INTEGER, pNumEmpleado VARCHAR(8) DEFAULT "",
														pMotivoCancelacion VARCHAR(1) DEFAULT "")
	RETURNING 	CHAR(5) 	AS cCodRet,
				CHAR(20) 	AS cNumCte,
				CHAR(104)	AS cNombre,
				CHAR(13) 	AS cRFC,
				CHAR(13) 	AS cTelefono,
				CHAR(20) 	AS cNumCredito,
				CHAR(2) 	AS cEstatusCred,
				CHAR(20) 	AS cNumTarjetaPlat,
				CHAR(1) 	AS cEstatusTarPlat,
				CHAR(1) 	AS cEstatusTarPlatTit,
				CHAR(4) 	AS cProductoPlat,
				CHAR(1) 	AS cTipoTarjetaPlat,				
				CHAR(45) 	AS cDescripconPlat,
				CHAR(20)	AS cNumTarjetaPPass,
				CHAR(20)	AS cFechaVencimientoPPass,
				CHAR(1) 	AS cEstatusTarPPass,
				CHAR(16) 	AS cFolioCancelacion,
				CHAR(2) 	AS cCancelacionSecuencia;

DEFINE sql_err INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);
DEFINE cNumCteAnt CHAR(20);
DEFINE cNombre CHAR(104);
DEFINE cRFC CHAR(13);
DEFINE cTelefono CHAR(13);
DEFINE cNumCredito CHAR(20);
DEFINE cNumCreditoAnt CHAR(20);
DEFINE cNumTarjetaPlat CHAR(20);
DEFINE cEstatusTarPlat CHAR(1);
DEFINE cEstatusTarPlatTit CHAR(1);
DEFINE cTipoTarjetaPlat CHAR(1);
DEFINE cProductoPlat CHAR(4);
DEFINE cDescripconPlat CHAR(45);
DEFINE cNumTarjetaPPass CHAR(20);
DEFINE cFechaVencimientoPPass CHAR(20);
DEFINE cEstatusTarPPass CHAR(1);
DEFINE cEstatusCred CHAR(2);
DEFINE cFolioCancelacion CHAR(16);
DEFINE iCancelacionSecuencia INTEGER;								 
DEFINE cCancelacionSecuencia CHAR(2);

LET sql_err = 0;
LET cCodRet = "00000";
LET cNumCte = "";
LET cNumCteAnt = "";
LET cNombre = "";
LET cRFC = "";
LET cTelefono = "";
LET cNumCredito = "";
LET cNumCreditoAnt = "";
LET cNumTarjetaPlat = "";
LET cProductoPlat = "";
LET cDescripconPlat = "";
LET cEstatusTarPlat = "";
LET cEstatusTarPlatTit = "";
LET cTipoTarjetaPlat = "";
LET cNumTarjetaPPass = "";
LET cFechaVencimientoPPass = "";
LET cEstatusTarPPass = "";
LET cEstatusCred = "";
LET cFolioCancelacion = "";
LET iCancelacionSecuencia = 0;
LET cCancelacionSecuencia = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN NVL(cCodRet, ''), NVL(cNumCte, ''), NVL(cNombre, ''), NVL(cRFC, ''),NVL(cTelefono, ''),
				NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
				NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass, ''), NVL(cFechaVencimientoPPass, ''), NVL(cEstatusTarPPass, ''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0');
		END IF;
	END EXCEPTION;


	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_administra_tarjetas_ppass.out";
	--TRACE ON;

	IF pOpcion = 1 AND TRIM(pEmpresa) <> "" AND TRIM(pNumcte) <> "" AND TRIM(pProducto) <> "" THEN
		FOREACH
			SELECT
					tarjeta_plat.num_credito, tarjeta_plat.status_tar, tarjeta_plat.tipo_tarjeta, maecred.status_cred
				INTO
					cNumCredito, cEstatusTarPlat, cTipoTarjetaPlat, cEstatusCred
			FROM "informix".sd_tarjeta tarjeta_plat
			INNER JOIN "informix".sd_maecred maecred
				ON maecred.num_credito = tarjeta_plat.num_credito
			WHERE tarjeta_plat.empresa = pEmpresa
				AND maecred.empresa = pEmpresa
				AND tarjeta_plat.numcte = pNumcte
				AND tarjeta_plat.prodtarjeta = pProducto
				ORDER BY tarjeta_plat.num_credito ASC, tarjeta_plat.status_tar ASC, tarjeta_plat.secuencia DESC,
				maecred.status_cred ASC
				
			LET cCancelacionSecuencia = "0";
			LET cEstatusTarPlatTit = "";
			LET cEstatusTarPPass = "";
			
			IF TRIM(cNumCredito) <> TRIM(cNumCreditoAnt) THEN
			
				FOREACH
					SELECT
							status_tar
						INTO
							cEstatusTarPPass
					FROM "informix".sd_tarjeta_ppass
					WHERE numcte = pNumcte
					AND num_credito = cNumCredito
					ORDER BY status_tar ASC, secuencia DESC
				END FOREACH;
			
				IF TRIM(cTipoTarjetaPlat) = "T" THEN
					LET cEstatusTarPlatTit = cEstatusTarPlat;
				ELSE
					FOREACH
						SELECT 
								LIMIT 1 status_tar
							INTO
								cEstatusTarPlatTit
						FROM "informix".sd_tarjeta
						WHERE prodtarjeta = pProducto
						AND num_credito = cNumCredito
						AND tipo_tarjeta = 'T'
						ORDER BY status_tar ASC, secuencia DESC
					END FOREACH;
				END IF;
				
				SELECT COUNT(*) INTO cCancelacionSecuencia
					FROM (SELECT numcte, num_credito 
							FROM "informix".sd_tarjeta_ppass
								WHERE num_credito = cNumCredito
								AND status_tar IN ('A','C','R','S')
								GROUP BY numcte, num_credito);
					
				RETURN NVL(cCodRet,''), NVL(cNumCte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
					NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
					NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0') WITH RESUME;
			END IF;
				
			LET cNumCreditoAnt = cNumCredito;
		END FOREACH;
	ELIF pOpcion = 2 AND TRIM(pNumCredito) <> "" THEN
		FOREACH
			SELECT 
					tarjeta_plat.numcte, tarjeta_plat.num_credito, tarjeta_plat.num_tarjeta, tarjeta_plat.status_tar, tarjeta_plat.tipo_tarjeta,
					tarjeta_plat.prodtarjeta, maecred.status_cred
				INTO
					cNumCte, cNumCredito, cNumTarjetaPlat, cEstatusTarPlat, cTipoTarjetaPlat,
					cProductoPlat, cEstatusCred
			FROM "informix".sd_tarjeta tarjeta_plat
			INNER JOIN "informix".sd_maecred maecred
				ON maecred.num_credito = tarjeta_plat.num_credito
			WHERE tarjeta_plat.empresa = pEmpresa
			AND maecred.empresa = pEmpresa
			AND tarjeta_plat.num_credito = pNumCredito
			AND tarjeta_plat.prodtarjeta = pProducto
			ORDER BY tarjeta_plat.tipo_tarjeta DESC, tarjeta_plat.numcte ASC, tarjeta_plat.status_tar ASC, tarjeta_plat.secuencia DESC
							
			LET cCodRet = "00000";
			LET cDescripconPlat = "";
			LET cNombre = "";
			LET cRFC = "";			
			LET cTelefono = "";
			LET cNumTarjetaPPass = "";
			LET cFechaVencimientoPPass = "";
			LET cEstatusTarPPass = "";
			LET cEstatusTarPlatTit = "";
			
			IF TRIM(cNumCteAnt) <> TRIM(cNumCte) THEN
			
				FOREACH
					SELECT 
							numtarjeta_ppass, CAST(expiracion AS CHAR(10)), status_tar
						INTO
							cNumTarjetaPPass, cFechaVencimientoPPass, cEstatusTarPPass
					FROM "informix".sd_tarjeta_ppass
					WHERE numcte = cNumCte
					AND num_credito = pNumCredito
					ORDER BY status_tar ASC
				END FOREACH;
			
				IF TRIM(cEstatusTarPlatTit) = "" THEN
					IF TRIM(cTipoTarjetaPlat) = "T" THEN
						LET cEstatusTarPlatTit = cEstatusTarPlat;
					ELSE
						FOREACH
							SELECT 
									LIMIT 1 status_tar
								INTO
									cEstatusTarPlatTit
							FROM "informix".sd_tarjeta
							WHERE prodtarjeta = pProducto
							AND num_credito = cNumCredito
							AND tipo_tarjeta = 'T'
							ORDER BY status_tar ASC, secuencia DESC
						END FOREACH;
					END IF;
				END IF;
			
				SELECT num_producto || ' ' || nombre_prod INTO cDescripconPlat
				FROM "informix".sd_definicion
					WHERE empresa = pEmpresa
					AND num_producto = cProductoPlat;

				SELECT
						REPLACE(TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno), '  ', ' '), rfc
					INTO
						cNombre, cRFC
				FROM bdinteg: "informix".si_cliente WHERE numcte = cNumCte;

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = "00003";
				ELSE				
					SELECT telefono INTO cTelefono FROM bdinteg: "informix".si_telefonos_actual WHERE NUMCTE = cNumCte AND tipo_tel = '1' AND secuencia = (
						SELECT MAX(SECUENCIA) FROM bdinteg: "informix".si_telefonos_actual
							WHERE NUMCTE = cNumCte
							AND tipo_tel = '1');
							
						RETURN NVL(cCodRet,''), NVL(cNumCte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
						NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
						NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0') WITH RESUME;
				END IF;
				
				LET cNumCteAnt = cNumCte;
			END IF;

		END FOREACH;
	ELIF pOpcion = 3 AND TRIM(pEmpresa) <> "" THEN
		IF TRIM(pNumTarjeta) <> "" THEN
			SELECT LIMIT 1 numcte INTO cNumCte
			FROM "informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_tarjeta = pNumTarjeta
				AND prodtarjeta = pProducto;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00002";
			END IF;	
			
		ELIF TRIM(pNumCredito) <> "" THEN
			SELECT LIMIT 1 numcte INTO cNumCte
			FROM "informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_credito = pNumCredito
				AND tipo_tarjeta = 'T'
				AND prodtarjeta = pProducto;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00003";
			END IF;	
		END IF;			
		
	ELIF pOpcion = 4 AND TRIM(pNumTarjeta) <> "" AND TRIM(pEstatus) <> "" THEN
		UPDATE "informix".sd_tarjeta_ppass 
		SET status_tar = pEstatus 
		WHERE numtarjeta_ppass = pNumTarjeta;
		
	ELIF pOpcion = 5 AND TRIM(pNumTarjeta) <> "" THEN
		SELECT {+INDEX(bdicred: sd_tarjeta_ppass idx_sd_tarjeta_ppass)} status_tar INTO cEstatusTarPPass 
		FROM "informix".sd_tarjeta_ppass 
			WHERE num_credito IS NOT NULL AND num_tarjeta IS NOT NULL AND numtarjeta_ppass = pNumTarjeta AND secuencia IS NOT NULL;
			
	ELIF pOpcion = 6 AND TRIM(pNumTarjeta) <> "" AND TRIM(pEstatus) <> "" AND TRIM(pNumEmpleado) <> "" THEN 
			LET cFolioCancelacion = TRIM(pNumEmpleado) || TRIM(TO_CHAR(TODAY,'%d%m%y'));
			
			SELECT COUNT(*) INTO iCancelacionSecuencia
			FROM "informix".sd_tarjeta_ppass
				WHERE SUBSTR(folio_canc, 1,14) = cFolioCancelacion;

			LET iCancelacionSecuencia = iCancelacionSecuencia + 1;
			LET cFolioCancelacion = TRIM(cFolioCancelacion) || LPAD(iCancelacionSecuencia, 2, '0');
			
			UPDATE "informix".sd_tarjeta_ppass 
			SET status_tar = pEstatus, folio_canc = cFolioCancelacion, motivo_canc = pMotivoCancelacion
			WHERE numtarjeta_ppass = pNumTarjeta;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00002";
			ELSE
				UPDATE "informix".sd_inven_tarppass 
				SET status_tar = pEstatus, desc_status = "CANCELADA", fecha_modif = CURRENT
				WHERE numtarjeta_ppass = pNumTarjeta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					UPDATE "informix".sd_tarjeta_ppass 
					SET status_tar = 'A', folio_canc = '', motivo_canc = ''
					WHERE numtarjeta_ppass = pNumTarjeta;
				END IF;
				
			END IF;
	ELIF pOpcion = 7 AND TRIM(pNumCredito) <> "" AND TRIM(pEmpresa) <> "" THEN
		IF pSecuencia = 1 THEN		
			SELECT COUNT(*) INTO cCancelacionSecuencia
			FROM "informix".sd_tarjeta_ppass tarjeta_ppass
			INNER JOIN "informix".sd_tarjeta tarjeta_plat
				ON tarjeta_ppass.numcte = tarjeta_plat.numcte
					AND tarjeta_ppass.num_credito = tarjeta_plat.num_credito
				WHERE tarjeta_ppass.num_credito = pNumCredito
				AND tarjeta_ppass.status_tar IN ('A','C','R','S')
				AND tarjeta_plat.status_tar = 'A';
		ELSE
			SELECT COUNT(*) INTO cCancelacionSecuencia
			FROM "informix".sd_tarjeta_ppass
				WHERE num_credito = pNumCredito
				AND status_tar = 'A';
		END IF;				
	ELIF pOpcion = 8 AND TRIM(pNumCredito) <> "" AND TRIM(pEmpresa) <> "" THEN
		SELECT COUNT(*) INTO cCancelacionSecuencia
		FROM "informix".sd_tarjeta tarjeta_plat
			INNER JOIN "informix".sd_tarjeta_ppass tarjeta_ppass
			ON tarjeta_ppass.num_credito = tarjeta_plat.num_credito
				AND tarjeta_ppass.numcte = tarjeta_plat.numcte
			WHERE tarjeta_plat.num_credito = pNumCredito
			AND tarjeta_plat.tipo_tarjeta <> 'T'
			AND tarjeta_plat.numcte = pNumcte
			AND tarjeta_ppass.tipo_tarjeta <> 'T'
			AND tarjeta_ppass.status_tar IN ('A','C','R','S');
			
	ELIF pOpcion = 9 THEN
		FOREACH
			SELECT
					LIMIT 1 numtarjeta_ppass
				INTO
					cNumTarjetaPPass
			FROM "informix".sd_inven_tarppass
				WHERE status_tar = 'S'
				ORDER BY id_tar_ppass ASC
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00002";
			ELSE
				IF pSecuencia = 1 THEN
					UPDATE "informix".sd_inven_tarppass 
					SET status_tar = 'A', desc_status = 'ACTIVA', fecha_modif = CURRENT
					WHERE numtarjeta_ppass = cNumTarjetaPPass;
				END IF;
			END IF;
		END FOREACH;
	ELIF pOpcion = 10 THEN
		UPDATE "informix".sd_inven_tarppass 
			SET status_tar = 'S', desc_status = 'SIN ASIGNAR', fecha_modif = CURRENT
			WHERE numtarjeta_ppass = pNumTarjeta;
	ELIF pOpcion = 11 AND TRIM(pNumcte) <> "" THEN
	
		SELECT
				REPLACE(TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno), '  ', ' '), rfc
			INTO
				cNombre, cRFC
		FROM bdinteg: "informix".si_cliente WHERE numcte = pNumcte;

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = "00003";
		ELSE				
			SELECT telefono INTO cTelefono FROM bdinteg: "informix".si_telefonos_actual WHERE NUMCTE = pNumcte AND tipo_tel = '1' AND secuencia = (
				SELECT MAX(SECUENCIA) FROM bdinteg: "informix".si_telefonos_actual
					WHERE NUMCTE = pNumcte
					AND tipo_tel = '1');
					
				RETURN NVL(cCodRet,''), NVL(pNumcte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
				NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
				NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0');
		END IF;
	END IF;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 AND pOpcion <> 3 THEN
		LET cCodRet = "00002";
	END IF;

	IF ((pOpcion = 1 OR pOpcion = 2) AND cCodRet != "00000") OR pOpcion > 2 THEN
		RETURN NVL(cCodRet,''), NVL(cNumCte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
			NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
			NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0');
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2019-11-06',
'DescripciÃ³n: Se genera procedimiento para administrar las tarjetas Priority Pass',
'SolicitÃ³: Rodolfo Gomez Hernandez',
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2020-01-27',
'DescripciÃ³n: Se modifica procedimiento almacenado para extraer los datos generales del Cliente desde el aplicativo pl004064.exe',
'SolicitÃ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_catcausapp_web(pSecuencia INTEGER)
	RETURNING 	CHAR(5) 	AS cCodRet,
				CHAR(11)	AS cID,
	            CHAR(1)		AS cCausa,
	            CHAR(25)	AS cDescripcion;

DEFINE sql_err 				INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cID					CHAR(11);
DEFINE cCausa 				CHAR(1);
DEFINE cDescripcion 		CHAR(25);

LET sql_err					= 0;
LET cCodRet 				= "00000";
LET cID						= "";
LET cCausa 					= "";
LET cDescripcion 			= "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_catcausapp.out";
	--TRACE ON;

	FOREACH 
		SELECT SKIP pSecuencia 
				id_causa, causa, descripcion
			INTO
				cID, cCausa, cDescripcion
		FROM "informix".catcausapp
		ORDER BY id_causa ASC
		
		RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'') WITH RESUME;
	END FOREACH;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "00002";
	END IF;

	IF cCodRet <> "00000" THEN
		RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'');
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 Adrian Eduardo Lizarraga Cazares',
'BD: bdicred',
'Fecha: 2019-11-26',
'Descripcion: Se genera procedimiento almacenado para consultar los motivos de cancelacion para las tarjetas Priority Pass',
'SolicitoÂ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_consulta_accesos_ppass_web(pNumTarjeta VARCHAR(20), pMesAcceso VARCHAR(7), pSecuencia INTEGER)
	
	RETURNING CHAR(5)  AS cCodRet,
			  CHAR(10) AS cFechaVisita,
			  CHAR(20) AS cNumTarjetaPPas,
			  CHAR(69) AS cPaisSalon,
			  CHAR(11) AS cTotalVisistasTi,
		      CHAR(11) AS cTotalVisitasAdic,
			  CHAR(11) AS cTotalvisitas,
			  CHAR(11) AS cNumVisitasSCost,
			  CHAR(11) AS cNumVisFact,
			  CHAR(25) AS dTotalAPagar;
	
	DEFINE sql_err 				INTEGER;
	DEFINE cCodRet 				CHAR(5);
	DEFINE cCategoria 			CHAR(1);
	DEFINE iAccGratis 			INTEGER;
	DEFINE cFechaVisita 		CHAR(10);
	DEFINE cNumTarjetaPPass 	CHAR(20);
	DEFINE cPaisSalon 			CHAR(69);
	DEFINE cTotalVisistasTi 	CHAR(11);
	DEFINE cTotalVisitasAdic	CHAR(11);
	DEFINE cTotalvisitas		CHAR(11);
	DEFINE cNumVisitasSCost 	CHAR(11);
	DEFINE cNumVisFact 			CHAR(11);
	DEFINE dTotalAPagar 		DECIMAL(18,4);
	DEFINE cCostoAcceso 		CHAR(3);

	LET sql_err				= 0;
	LET cCodRet 			= '00000';
	LET cCategoria 			= '';
	LET iAccGratis 			= 0;
	LET cFechaVisita 		= '';
	LET cNumTarjetaPPass 	= '';
	LET cPaisSalon 			= '';
	LET cTotalVisistasTi 	= '';
	LET cTotalVisitasAdic 	= '';
	LET cTotalvisitas 		= '';
	LET cNumVisitasSCost 	= '';
	LET cNumVisFact 		= '';
	LET dTotalAPagar 		= 0.0;
	LET cCostoAcceso 		= '';


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN		

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'');
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/sp_consulta_movimientos_ppass.out';
		--TRACE ON;
		
		SELECT FIRST 1 categoria 
		INTO cCategoria
		FROM "informix".sd_tarjeta_ppass
		WHERE numtarjeta_ppass = pNumTarjeta; 	

		SELECT acceso_gratis 
		INTO iAccGratis
		FROM "informix".catcategoriappass
		WHERE id_categoria = cCategoria;		
		
		IF  dbinfo("sqlca.sqlerrd2") = 0 THEN			
			LET cCodRet = '00003';
		ELSE
		
			SELECT valor 
			INTO cCostoAcceso
			FROM "informix".sd_param 
			WHERE cod_param = '074';
			
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN				
				LET cCodRet = '00004';				
			END IF;
		END IF;
		
		IF TRIM(pNumTarjeta) <> "" AND TRIM(pMesAcceso) <> "" THEN
			
			FOREACH
					SELECT SKIP pSecuencia
					TO_CHAR(A.fecha_visita, '%d/%m/%Y') AS fecha_visita,
					TO_CHAR(numtarjeta_ppass) AS num_tarjeta,
					TO_CHAR(id_pais_visita || '  ' || nombre_lounge) AS pais_salon, 
					TO_CHAR(A.totalpp_deslizada) AS vis_titular,
					TO_CHAR(A.total_invitados) AS vis_Adic,
					TO_CHAR(A.total_visitas) AS vis_total, 
					TO_CHAR((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE iAccGratis END)) AS vi_sinc,
					TO_CHAR((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE (A.total_visitas - iAccGratis) END)) AS vi_fact, 
					TO_CHAR(((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE (A.total_visitas - iAccGratis) END) * 
					NVL((SELECT precio_venta FROM bdinteg: "informix".si_histdiv WHERE fecha_tc = A.fecha_visita AND divisa = '02' 
					AND hora_tc = (SELECT MAX(hora_tc) FROM bdinteg: "informix".si_histdiv 
					WHERE fecha_tc = A.fecha_visita AND divisa = '02')), 0) * cCostoAcceso )) AS total_facturable
					
					INTO cFechaVisita, cNumTarjetaPPass, cPaisSalon, cTotalVisistasTi, cTotalVisitasAdic,
					cTotalvisitas, cNumVisitasSCost, cNumVisFact, dTotalAPagar
					
					FROM "informix".sd_movmes_ppass AS A 
					WHERE A.numtarjeta_ppass = pNumTarjeta 
					AND MONTH(A.fecha_visita) = SUBSTRB(pMesAcceso, 1, 2) AND YEAR(A.fecha_visita) = SUBSTRB(pMesAcceso, 4, 4)
					ORDER BY A.fecha_visita ASC
				
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'') WITH RESUME;

			END FOREACH;

		ELSE 
			LET cCodRet = '00001';
		END IF;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 AND cCodRet = '000000' THEN
			LET cCodRet = "00002";
		END IF;

		IF TRIM(cCodRet) <> "00000" THEN
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'');
		END IF;


	END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2019-11-18',
'DescripciÃ³n: Se genera procedimiento almacenado para consultar las visitas que el Cliente ha realizado con su tarjeta Priority Pass en un plazo',
'			  no mayor a 12 meses y con un rango de bÃºsqueda de 32 dÃ­as',
'SolicitÃ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_valiexisttarjcctdebcred_web(pEmpresa CHAR(3), pRFC CHAR(13))

RETURNING CHAR(5), CHAR(1);

   DEFINE cNumCte      VARCHAR(20);
   DEFINE cNumTarjeta  VARCHAR(20);
   DEFINE cTipoCta     CHAR(1);
   DEFINE v_codret     CHAR(5);
   DEFINE sqlerr       INTEGER; 
   
   LET v_codret     = "00000";
   LET sqlerr       = 0;
   LET cNumCte      = "0";
   LET cNumTarjeta  = "0";
   LET cTipoCta     = "";
   
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   
   BEGIN
	  ON EXCEPTION
		  SET sqlerr
		  LET v_codret = sqlerr;
		  RETURN v_codret, cTipoCta;
	  END EXCEPTION;
	   --SET DEBUG FILE TO  '/home/sysifx/Oscar/sp_valiexisttarjcctdebcred_web.out';
       --TRACE ON;
	 IF TRIM(pRFC) = '' OR pRFC IS NULL THEN
		LET v_codret = '00002';
		RETURN v_codret, cTipoCta;
	 END IF
	
	SELECT numcte INTO cNumCte FROM bdinteg:"informix".si_cliente WHERE rfc = pRFC AND empresa = pEmpresa;
	
	IF TRIM(cNumCte) <> '' AND cNumCte IS NOT NULL THEN
			
		SELECT LIMIT 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta 
		WHERE numcte = cNumCte
		AND status_tar = 'A'; -->> Credito
		
		IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
			LET cTipoCta = "C"; 
		ELSE
			SELECT LIMIT 1 num_tarjeta INTO cNumTarjeta FROM bdicheq:"informix".sc_tarjeta 
			WHERE numcte = cNumCte
			AND status_tar = 'A'; -->> Debito
			
			IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
				LET cTipoCta = "D";
			ELSE
				LET v_codret = '00001';
			END IF
		END IF;
	ELSE
		LET v_codret = '00001';
    END IF;
    RETURN v_codret, cTipoCta;
   END;
END PROCEDURE

DOCUMENT
"Spl para saber si el cliente tiene tarjetas activas de credito o debito ",
"obtener la fecha de fechrero por ejemplo",
"base de datos: bdicred",
"AUTOR : Oscar Marquez 98681011",
"FECHA : 25/09/2019";

CREATE PROCEDURE "informix".asigna_numsol_web(o_empresa CHAR(3), o_num_producto CHAR(4), o_numcte CHAR(20))

RETURNING CHAR(5), CHAR(20);
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificion: Se modifica el sp para que calcule el siguiente num de solicitud 
--             de la tarjeta de credito Coppel".
-- Fecha de modificaciÃ³n: 07-01-2009
-- Proyecto: Caja Unica.
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃ³n: Se modifica para que asigne un consecutivo de solicitud para el 
--                producto PrÃ©stamo Personal.
--Fecha de modificaciÃ³n: 09-09-2009
--PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃ³n: Se modifica para parametrizar las consultas que se realizan
--              para generar el nÃºmero de solicitud correspondiente al producto 
--              recibido como parÃ¡metro.
--Fecha de modificaciÃ³n: 03-11-2009
--PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃ³n: Se renombra para que se unifique con el spl productivo.
--		     Se tomÃ³ el spl asigna_numsol_cjunk versiÃ³n que se
--		     tomÃ³ para alta Ãºnica, misma que ahora reemplazarÃ¡
--		     al spl que actualmente existe en producciÃ³n.
--Fecha de modificaciÃ³n: 05-01-2010
--PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal
--------------------------------------------------------------------------------

-- DEFINICION DE VARIABLES
DEFINE vsqlerr INTEGER;
DEFINE vcod_ret CHAR(5);
DEFINE vnum_solicitud CHAR(20);
DEFINE vcuantas SMALLINT;

-- ASIGNACION DE VARIABLES
LET vsqlerr = 0;
LET vcod_ret = "00000";
LET vnum_solicitud ="???????????????";
LET vcuantas = 0;

BEGIN
	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET vcod_ret=vsqlerr;
		  RETURN vcod_ret,vnum_solicitud;
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
-- *********** INICIA PROCESO DE ASIGNACION ******************
	
	SELECT COUNT(*) INTO vcuantas FROM bdisolic:ss_solicitudes
	 WHERE numcte = o_numcte
	   AND num_producto = o_num_producto 
	   AND status_solicitud <>'AP'
	   AND status_solicitud[1,1] <> 'R';

	IF vcuantas > 0 THEN
		LET vcod_ret = "00500";
		RETURN vcod_ret, vnum_solicitud;
	END IF
	
  	CREATE TEMP TABLE signumero
  		(numero CHAR(20));

	INSERT INTO signumero
	SELECT num_credito FROM bdicred:sd_maecred
	WHERE numcte = o_numcte
	   AND num_producto = o_num_producto;

	INSERT INTO signumero
	SELECT num_solicitud FROM bdisolic:ss_solicitudes
	WHERE numcte = o_numcte
	   AND num_producto = o_num_producto 
	   AND status_solicitud <>'AP'
	   AND status_solicitud[1,1] <> 'R';

	SELECT MAX(numero) INTO vnum_solicitud
	  FROM signumero;

	IF vnum_solicitud IS NULL THEN
		LET vnum_solicitud = "000";
		LET vnum_solicitud = TRIM(o_numcte) || TRIM(o_num_producto) || 
			             vnum_solicitud;
	ELSE
		LET vnum_solicitud = SUBSTR(vnum_solicitud, -3) + 1;
		LET vnum_solicitud = TRIM(o_numcte) || TRIM(o_num_producto) || 
			             vnum_solicitud;
	END IF

END

	RETURN vcod_ret, vnum_solicitud;

END PROCEDURE;