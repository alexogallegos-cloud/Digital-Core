CREATE PROCEDURE "informix".sp_buscar_nac_migrante(pNumCertificado VARCHAR(20))
RETURNING CHAR(5),CHAR(3),CHAR(100);

DEFINE sql_err INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNacionalidad CHAR (3);
DEFINE cCiudad CHAR (100);

LET sql_err = 0;
LET cCodRet = "00001";
LET cNacionalidad = "0";
LET cCiudad = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN cCodRet, NVL(cNacionalidad,''), NVL(cCiudad,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/TMP/sp_buscar_nac_migrante.out";
	--TRACE ON;

		IF NVL(pNumCertificado, '') <> '' THEN
			
			SELECT nacionalidad, ciudad INTO cNacionalidad,cCiudad FROM bdisac:"informix".sac_cardif_migrante
			WHERE num_certificado = pNumCertificado 
			AND estatus in(1,2)
            AND fecha_insert = ( SELECT MAX(fecha_insert) FROM bdisac:"informix".sac_cardif_migrante
                                WHERE num_certificado = pNumCertificado);

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				IF NVL(cNacionalidad, '') <> '' OR cNacionalidad IS NULL THEN
					LET cCodRet = "00002";
				END IF;
            ELSE
				LET cCodRet = "00000";
			END IF;

		ELSE
			LET cCodRet = "00002";
		END IF;
			
		RETURN cCodRet, NVL(cNacionalidad,''), NVL(cCiudad,'');

END;
END PROCEDURE
DOCUMENT
'Folio: 577',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdisac',
'Fecha: 2019-05-23',
'DescripciÃ³n: Se genera Procedimiento Almacenado para regresar la nacionalidad de los asegurados migrantes en la tabla sac_cardif_migrante para la asegurados en Cardiff',
'SolicitÃ³: Abraham Narvaez';

CREATE PROCEDURE "informix".sp_actualiza_estatus_cardif()

RETURNING
CHAR(5)	AS cCodRet;

DEFINE cCodRet	CHAR(5);
DEFINE iSqlErr  INTEGER; 
DEFINE iIsamErr INTEGER; 
DEFINE cInfoErr CHAR(10); 

DEFINE dFechaHoy DATE;
DEFINE dFechaAnt DATE;
DEFINE dFechaDes DATE;
DEFINE iDiasAnt  INTEGER;
DEFINE iDiasDes  INTEGER;

LET cCodRet = "00000";

--SET DEBUG FILE TO "/home/sysifx/MarcoR/bdisac/TraceBdisac/sp_actualiza_estatus_cardif.out";
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)	
				COMMIT WORK;							
	END EXCEPTION WITH RESUME;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	BEGIN WORK;	

	SELECT valor INTO iDiasAnt FROM sac_param WHERE cod_param = 128;
	SELECT valor INTO iDiasDes FROM sac_param WHERE cod_param = 129;

	--LET iDiasAnt = (SELECT valor FROM sac_param WHERE cod_param = 128);
	--LET iDiasDes = (SELECT valor FROM sac_param WHERE cod_param = 129);
	
	--Obtiene fechas para determinar el rango de seguros para actualizar.
	SELECT fecha_hoy - iDiasAnt, fecha_hoy + iDiasDes, fecha_hoy 
	INTO dFechaAnt, dFechaDes, dFechaHoy
	FROM bdisac:"informix".sac_fechas;
	
	--Actualiza estatus de apto para renovacion(2) a cancelado(4)
	UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 4
	WHERE estatus = 2 AND (fecha_vencimiento + iDiasDes) < dFechaHoy;
	
	--Actualiza estatus de activo(1) a apto para renovacion(2)
	UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 2
	WHERE estatus = 1 AND fecha_vencimiento BETWEEN dFechaAnt AND dFechaDes;
	
	--Actualiza estatus de activo(1) a cancelado (5) Cuado se detectan caracteristicas de operacion inconclusa
	UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 5, observ_siniestro = 'Cambio estatus 1 a 5 Operacion Inconclusa'
	WHERE estatus = 1
	AND folio_suc IS NULL
	AND num_certificado = ''
	AND num_poliza = '';
	
	COMMIT WORK;
	RETURN cCodRet;
	
END;
END PROCEDURE;