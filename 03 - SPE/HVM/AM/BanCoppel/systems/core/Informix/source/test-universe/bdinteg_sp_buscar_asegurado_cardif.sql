CREATE PROCEDURE "informix".sp_buscar_asegurado_cardif(sNumcte CHAR(20), sApellPat VARCHAR(26), sApellMat VARCHAR(26), sNombre1 VARCHAR(26), sNombre2 VARCHAR(26),  dFechaNac DATE, sNumCertif VARCHAR(30), sOpcion SMALLINT, iSecuencia INTEGER)
RETURNING CHAR(5),
		CHAR(20),
		CHAR(30),
		CHAR(50),
		CHAR(26),
		CHAR(26),
		CHAR(26),
		CHAR(26),
		CHAR(10),
		CHAR(13);

DEFINE sql_err INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE r_sNumcte VARCHAR(20);
DEFINE r_sNumCertif VARCHAR(30);
DEFINE r_sPoliza VARCHAR(50);
DEFINE r_sNombre1 VARCHAR(26);
DEFINE r_sNombre2 VARCHAR(26);
DEFINE r_sApellPat VARCHAR(26);
DEFINE r_sApellMat VARCHAR(26);
DEFINE r_dFechaNac VARCHAR(10);
DEFINE r_sRFCCodRet VARCHAR(5);
DEFINE r_sRFCMensaje VARCHAR(100);
DEFINE r_sRFC VARCHAR(10);

LET sql_err = 0;
LET cCodRet = "00000";
LET r_sNumcte = "";
LET r_sNumCertif = "";
LET r_sPoliza = "";
LET r_sNombre1  = "";
LET r_sNombre2  = "";
LET r_sApellPat = "";
LET r_sApellMat = "";
LET r_dFechaNac = "";
LET r_sRFCCodRet = "";
LET r_sRFCMensaje = "";
LET r_sRFC = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
		END IF;
	END EXCEPTION;
	
	
--SET DEBUG FILE TO "/tmp/respaldosbd/sp_BuscarAseguradoCardiff.out";
--TRACE ON;
	
	IF sOpcion = 1 OR sOpcion = 2 Then
		IF NVL(sNombre1, '') <> '' AND TRIM(sNombre1) <> '' AND NVL(sApellPat, '') <> '' AND TRIM(sApellPat) <> '' AND dFechaNac IS NOT NULL THEN
			LET sNombre1 = TRIM(UPPER(sNombre1)||'*');
			LET sApellPat = TRIM(UPPER(sApellPat)||'*');			
			LET sNombre2 = TRIM(UPPER(sNombre2)||'*');
			LET sApellMat = TRIM(UPPER(sApellMat)||'*');
			
			IF sOpcion = 1 Then
				IF TRIM(sNumCertif) = "" OR TRIM(sNumCertif) = "0" THEN
					FOREACH
						SELECT SKIP iSecuencia LIMIT 21
							scte.numcte, scont.num_certificado, scont.num_poliza,
							scte.nombre1, scte.nombre2,
							scte.apell_paterno, scte.apell_materno,
							sctepf.fecha_nac, scte.rfc
						  INTO
							r_sNumcte, r_sNumCertif, r_sPoliza,
							r_sNombre1, r_sNombre2,
							r_sApellPat, r_sApellMat,
							r_dFechaNac, r_sRFC
						FROM "informix".si_cliente scte
						INNER JOIN bdisac: "informix".sac_cardif_contratante scont
							ON scte.numcte = scont.numcte
						INNER JOIN "informix".si_ctepf sctepf
							ON sctepf.numcte = scte.numcte
						WHERE scte.apell_paterno MATCHES sApellPat AND
						scte.apell_materno MATCHES sApellMat AND
						scte.nombre1 MATCHES sNombre1 AND
						scte.nombre2 MATCHES sNombre2 AND
						sctepf.fecha_nac = dFechaNac
						ORDER BY apell_paterno, apell_materno, nombre1, nombre2
						
						RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC WITH RESUME;
					END FOREACH;
				ELSE
					SELECT SKIP iSecuencia LIMIT 21
						scte.numcte, scont.num_certificado, scont.num_poliza,
						scte.nombre1, scte.nombre2,
						scte.apell_paterno, scte.apell_materno,
						sctepf.fecha_nac, scte.rfc
					  INTO
						r_sNumcte, r_sNumCertif, r_sPoliza,
						r_sNombre1, r_sNombre2,
						r_sApellPat, r_sApellMat,
						r_dFechaNac, r_sRFC
					FROM "informix".si_cliente scte
					INNER JOIN bdisac: "informix".sac_cardif_contratante scont
						ON scte.numcte = scont.numcte
					INNER JOIN "informix".si_ctepf sctepf
						ON sctepf.numcte = scte.numcte
					WHERE scte.apell_paterno MATCHES sApellPat AND
					scte.apell_materno MATCHES sApellMat AND
					scte.nombre1 MATCHES sNombre1 AND
					scte.nombre2 MATCHES sNombre2 AND
					scont.num_certificado = sNumCertif AND
					sctepf.fecha_nac = dFechaNac;
					
					IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
						RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
					ELSE
						LET r_sNumcte = NVL(r_sNumcte, '');
						LET r_sNumCertif = NVL(r_sNumCertif, '');
						LET r_sPoliza = NVL(r_sPoliza, '');
						LET r_sNombre1 = NVL(r_sNombre1, '');
						LET r_sNombre2 = NVL(r_sNombre2, '');
						LET r_sApellPat = NVL(r_sApellPat, '');
						LET r_sApellMat = NVL(r_sApellMat, '');
						LET r_dFechaNac = NVL(r_dFechaNac, '');
						LET r_sRFC = NVL(r_sRFC, '');
						LET cCodRet = "00002";
					END IF;
					
				END IF
			ELSE
				FOREACH					
					SELECT SKIP iSecuencia LIMIT 21
						numcte, num_certificado, nombre1, num_poliza,
						nombre2, apell_paterno, apell_materno, fechanac
					  INTO 
						r_sNumcte, r_sNumCertif, r_sNombre1, r_sPoliza,
						r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac
					FROM bdisac: "informix".sac_cardif_migrante
					WHERE apell_paterno MATCHES sApellPat AND
					apell_materno MATCHES sApellMat AND
					nombre1 MATCHES sNombre1 AND
					nombre2 MATCHES sNombre2 AND
					fechanac = dFechaNac AND
					estatus IN (1,2)
					ORDER BY apell_paterno, apell_materno, nombre1, nombre2
					
					EXECUTE PROCEDURE "informix".sp_calcularfc('001',r_sApellPat, r_sApellMat, r_sNombre1, r_sNombre2, r_dFechaNac) INTO r_sRFCCodRet, r_sRFCMensaje, r_sRFC;
			
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC WITH RESUME;
				END FOREACH;
			END IF;

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00002";
			END IF;
		ELSE
			LET cCodRet = "00001";
		END IF;
		
	ELIF sOpcion = 3 OR sOpcion = 4 THEN
		IF TRIM(sNumcte) <> "" AND sNumcte IS NOT NULL THEN
			If sOpcion = 3 Then
				SELECT
					scte.numcte, scte.nombre1, scte.nombre2, scte.apell_paterno, scont.num_poliza,
					scte.apell_materno, sctepf.fecha_nac, scont.num_certificado,
					scte.rfc
				INTO
					r_sNumcte, r_sNombre1, r_sNombre2, r_sApellPat, r_sPoliza,
					r_sApellMat, r_dFechaNac, r_sNumCertif,
					r_sRFC
				FROM "informix".si_cliente scte
				INNER JOIN bdisac: "informix".sac_cardif_contratante scont
					ON scte.numcte = scont.numcte
				INNER JOIN "informix".si_ctepf sctepf
					ON sctepf.numcte = scte.numcte
				WHERE scte.numcte = sNumcte;
				
				IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
				ELSE
					LET r_sNumcte = NVL(r_sNumcte, '');
					LET r_sNumCertif = NVL(r_sNumCertif, '');
					LET r_sPoliza = NVL(r_sPoliza, '');
					LET r_sNombre1 = NVL(r_sNombre1, '');
					LET r_sNombre2 = NVL(r_sNombre2, '');
					LET r_sApellPat = NVL(r_sApellPat, '');
					LET r_sApellMat = NVL(r_sApellMat, '');
					LET r_dFechaNac = NVL(r_dFechaNac, '');
					LET r_sRFC = NVL(r_sRFC, '');
					LET cCodRet = "00002";				
				END IF;
			ELSE
				SELECT 
					numcte, num_certificado, nombre1, num_poliza,
					nombre2, apell_paterno, apell_materno, fechanac
				  INTO 
					r_sNumcte, r_sNumCertif, r_sNombre1, r_sPoliza,
					r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac
				FROM bdisac: "informix".sac_cardif_migrante
				WHERE num_certificado = sNumcte;
				
				IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
					EXECUTE PROCEDURE "informix".sp_calcularfc('001',r_sApellPat, r_sApellMat, r_sNombre1, r_sNombre2, r_dFechaNac) INTO r_sRFCCodRet, r_sRFCMensaje, r_sRFC;
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
				ELSE
					LET r_sNumcte = NVL(r_sNumcte, '');
					LET r_sNumCertif = NVL(r_sNumCertif, '');
					LET r_sPoliza = NVL(r_sPoliza, '');
					LET r_sNombre1 = NVL(r_sNombre1, '');
					LET r_sNombre2 = NVL(r_sNombre2, '');
					LET r_sApellPat = NVL(r_sApellPat, '');
					LET r_sApellMat = NVL(r_sApellMat, '');
					LET r_dFechaNac = NVL(r_dFechaNac, '');
					LET r_sRFC = NVL(r_sRFC, '');
					LET cCodRet = "00002";				
				END IF;
			END IF
		ELSE
			LET cCodRet = "00001";
		END IF;
	ELIF sOpcion = 5 Then
		IF NVL(sNombre1, '') <> '' AND TRIM(sNombre1) <> '' AND NVL(sApellPat, '') <> '' AND TRIM(sApellPat) <> '' AND dFechaNac IS NOT NULL THEN
			LET sNombre1 = TRIM(UPPER(sNombre1)||'*');
			LET sApellPat = TRIM(UPPER(sApellPat)||'*');			
			LET sNombre2 = TRIM(UPPER(sNombre2)||'*');
			LET sApellMat = TRIM(UPPER(sApellMat)||'*');
			
			IF TRIM(sNumcte) = "0" OR TRIM(sNumcte) = "" OR sNumcte IS NULL THEN
				FOREACH
					SELECT SKIP iSecuencia LIMIT 21
						scte.numcte, 
						scte.nombre1, scte.nombre2,
						scte.apell_paterno, scte.apell_materno,
						sctepf.fecha_nac, scte.rfc
					  INTO
						r_sNumcte, 
						r_sNombre1, r_sNombre2,
						r_sApellPat, r_sApellMat,
						r_dFechaNac, r_sRFC
					FROM "informix".si_cliente scte
					INNER JOIN "informix".si_ctepf sctepf
						ON sctepf.numcte = scte.numcte
					WHERE scte.apell_paterno MATCHES sApellPat AND
					scte.apell_materno MATCHES sApellMat AND
					scte.nombre1 MATCHES sNombre1 AND
					scte.nombre2 MATCHES sNombre2 AND
					sctepf.fecha_nac = dFechaNac
					ORDER BY apell_paterno, apell_materno, nombre1, nombre2
					
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC WITH RESUME;
				END FOREACH;
					
			else
				FOREACH
					SELECT SKIP iSecuencia LIMIT 21
						scte.numcte, 
						scte.nombre1, scte.nombre2,
						scte.apell_paterno, scte.apell_materno,
						sctepf.fecha_nac, scte.rfc
					  INTO
						r_sNumcte, 
						r_sNombre1, r_sNombre2,
						r_sApellPat, r_sApellMat,
						r_dFechaNac, r_sRFC
					FROM "informix".si_cliente scte
					INNER JOIN "informix".si_ctepf sctepf
						ON sctepf.numcte = scte.numcte
					WHERE scte.numcte = sNumcte 
					ORDER BY apell_paterno, apell_materno, nombre1, nombre2
					
					RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC WITH RESUME;
				END FOREACH;
			end if
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "00002";
			END IF;
		ELSE
			LET cCodRet = "00001";
		END IF;
	ELSE
		LET cCodRet = "00003";
	END IF;
	
	IF cCodRet <> "00000" THEN
		RETURN cCodRet, r_sNumcte, r_sNumCertif, r_sPoliza, r_sNombre1, r_sNombre2, r_sApellPat, r_sApellMat, r_dFechaNac, r_sRFC;
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'Folio: 577',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdinteg',
'Fecha: 2019-05-23',
'DescripciÃ³n: Se genera Procedimiento Almacenado para realizar la bÃºsqueda de los clientes asegurados en Cardiff',
'SolicitÃ³: Abraham Narvaez',
'_______________________________________________________________________________________________________',
'Folio: 664',
'Autor: Alexi HernÃ¡ndez',
'BD: bdinteg',
'Fecha: 2020-04-27',
'DescripciÃ³n: Se genera la Procedimiento Almacenado la opcion 5 para la consulta de clientes titulares asegurados en Cardiff',
'SolicitÃ³: Abraham Narvaez';

CREATE PROCEDURE  "informix".sp_cancelaserviciobasico_bpi()
  RETURNING    CHAR(5);
	
	
------------------------------------
--Cancela el servicio de Banca por Internet para el proceso de cambio de servicio y guarda registros en la si_cambiostct los cambios de status
--Elaboro : Gabriela Aguilar
--FECHA : 13/Julio/2020
--Ver.  : 1.0
--BD    : bdinteg
------------------------------------
 	
  	
    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INT;
    DEFINE cod_ret char(5);
	DEFINE pnumcte      CHAR(10);
	DEFINE pid_status  SMALLINT;
	DEFINE vcomienza        INTEGER;
DEFINE vcuantos  		INTEGER;
DEFINE vregistros INTEGER;
DEFINE vcontador INTEGER;
DEFINE vcuantos1 INTEGER;

    --INICIALIZACION DE VARIABLES--
    LET sql_err = 0;  
	LET pnumcte = '';
	LET pid_status = 0;
	LET cod_ret = "00000";
LET vcontador = -1;
LET vcuantos = 0;
LET vcomienza   = -1;	
LET vregistros = 1000;
 
 --SET DEBUG FILE TO "/informix/gaby/sp_cancelaserviciobasico_bpi.out";
  --TRACE ON;


	Set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;

BEGIN

    

    	
	FOREACH WITH HOLD	
			
			Select numcte, id_status
			into pnumcte, pid_status
			from bdinteg:si_bpiusuarios  where  id_status not in ('30','99') and servicio='1'
			
		
			IF vcomienza = -1 THEN
				BEGIN WORK;
				LET vcontador = 1;
				LET vcomienza = 0;
			END IF;
		

       
				UPDATE 
				bdinteg:si_bpiusuarios 
				SET id_status = '99', servicio='2', f_status = current 
				WHERE numcte = pnumcte and id_status=pid_status ;
			

        
			IF (vcontador = vregistros) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;
			ELSE
				LET vcontador = vcontador + 1 ;						
			END IF;	

        CONTINUE FOREACH;			

				
	END FOREACH;

		
		IF (vcontador > 1) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;							
			END IF;		
	
   

    RETURN cod_ret;

END
END PROCEDURE;