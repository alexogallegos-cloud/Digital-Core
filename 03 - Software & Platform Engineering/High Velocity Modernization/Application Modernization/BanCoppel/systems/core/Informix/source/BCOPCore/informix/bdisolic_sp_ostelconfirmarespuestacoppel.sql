CREATE PROCEDURE "informix".sp_ostelconfirmarespuestacoppel(pOSTelefonica INTEGER, pRespuesta CHAR(1),pEstadoXml INTEGER)
RETURNING CHAR(5);

-- 30/12/2008
-- Bernardo Carlos Báez González
-- marca como enviadas las OS Telefonicas recibidas en la tabla ss_osclientesupervisartel
-- borra las tramas que llegaron correctamente de la tabla ss_osclientesupervisartel_xml
-- se graba la fecha y hora de respuesta en ss_ostelrefsolicitud_pendientes
---Modificó : Lorenzo Ibarra García
--Fecha: 26-10-2009
--Se agrega validación de los parámetros de entrada.
--Se agrega control de transacciónes.

DEFINE SQL_ERR 				INTEGER;
DEFINE vCod_Ret 			CHAR(5);
DEFINE cBanderaEliminaXml 	CHAR(1);
DEFINE cDescripcion 	 	CHAR(100);
DEFINE iBanderaenvio 		INTEGER;
DEFINE iIntentos 			INTEGER;
DEFINE iCuantos 			INTEGER;

LET SQL_ERR 				= 0;
LET vCod_Ret 				= '000';
LET cBanderaEliminaXml		= '';
LET cDescripcion		= '';
LET iBanderaenvio 				= 0;
LET iIntentos 				= 0;
LET iCuantos 				= 0;

--SET debug FILE TO "/home/sysifx/jesusm/sp_ostelconfirmarespuestacoppel.out";
--trace on;

BEGIN
	ON EXCEPTION SET SQL_ERR
		IF SQL_ERR <> 0 THEN
			LET vCod_Ret = SQL_ERR;
            RETURN vCod_Ret;
		END IF;
	END EXCEPTION;

    IF pOSTelefonica IS NULL OR pOSTelefonica < 1 OR TRIM(pRespuesta) = '' OR pRespuesta IS NULL OR pEstadoXml IS NULL THEN
        LET vCod_Ret = '001';
        RETURN vCod_Ret;
    END IF;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--se realiza consulta para determinar si la trama se debe eliminar y continuar el flujo de la solicitud, asi como en los casos que no se elimine cuantos intentos tiene permitido realizar
	SELECT {+INDEX(bdisolic:ss_ostelcatalogoconfirmaxmlcoppel idx_oscatconf_xml)} eliminaxml,TRIM(descripcion ),intentos
	INTO cBanderaEliminaXml,cDescripcion,iIntentos
	FROM ss_ostelcatalogoconfirmaxmlcoppel
	WHERE estadoxml = pEstadoXml;

	IF  pEstadoXml =  1 THEN   --actualiza a enviada solo cuando la solicitud fue enviada al CAT correctamente
		UPDATE {+INDEX(bdisolic:ss_osclientesupervisartel idx_stcte)} ss_osclientesupervisartel SET enviada = pRespuesta, fechaenvio = CURRENT
		WHERE secuenciaostel = pOSTelefonica;

		UPDATE {+INDEX(bdisolic:ss_ostelrefsolicitud_pendientes idx_secuenciaostel_pend)} ss_ostelrefsolicitud_pendientes SET fecha = CURRENT, hora = CURRENT
		WHERE secuenciaostel = pOSTelefonica;
		LET iBanderaenvio = 1;
	ELSE	--inserta en la bitacora de error cuando por algun motivo no se pudo enviar la trama al CAT
		INSERT INTO ss_ostelbitacoraerrorxml(secuenciaostel,estadoxml,descripcion,fecha,hora)
		VALUES(pOSTelefonica,pEstadoXml,cDescripcion,CURRENT,CURRENT HOUR TO FRACTION (3));
	END IF;

	--se agrega consulta a la bitacora para determinar cuantos intentos lleva la solicitud a enviarse al CAT
		SELECT {+INDEX(bdisolic:ss_ostelbitacoraerrorxml idx_osberr_xml)} COUNT(estadoxml)
			INTO iCuantos
		FROM ss_ostelbitacoraerrorxml
		WHERE secuenciaostel = pOSTelefonica
		AND estadoxml = pEstadoXml;

		IF iCuantos >= iIntentos THEN
			LET cBanderaEliminaXml = 'S';
		END IF

    IF cBanderaEliminaXml = 'S' THEN

		DELETE {+INDEX(bdisolic:ss_osclientesupervisartel_xml idx_stcte_xml)} FROM ss_osclientesupervisartel_xml WHERE secuenciaostel = pOSTelefonica;

		IF iBanderaenvio = 0 THEN
			UPDATE {+INDEX(bdisolic:ss_ostelrefsolicitud secuenciaostel_idx)} bdisolic:ss_ostelrefsolicitud SET automatico = 1 WHERE secuenciaostel = pOSTelefonica;
		END IF;

	END IF;

    RETURN vCod_Ret;
END;
END PROCEDURE
