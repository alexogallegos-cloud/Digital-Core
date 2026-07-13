CREATE PROCEDURE "informix".sp_actualiza_contacto_exitoso()

RETURNING CHAR(6), CHAR(80);

----Creado: Abril 2014 Guadalupe Espinoza.
----Descripción: Se crea sp para actualizar campo "contaco" de la tabla bdinteg:si_telefonos_actual.
----catalogo de codigo resultado es "informix".cb_cat_tipo_resultado.

----DECLARACION DE VARIABLES
	DEFINE sql_err 			        INTEGER;
	DEFINE isam_err 		        INTEGER;
	DEFINE error_info		        CHAR(150);
	DEFINE cMensaje 		        CHAR(150);
	DEFINE cCod_ret                 CHAR(6);
	DEFINE vempresa                 CHAR(3);
	DEFINE vnumcte                  CHAR(20);
	DEFINE vtelefono                CHAR (13);
	DEFINE vtipo_telefono           INTEGER;
	DEFINE vcodigo_resultado        INTEGER;
	DEFINE cproceso                 CHAR(4);
	DEFINE vvcCod_ret               CHAR(6);
	DEFINE vfecha					DATE;

	--SET DEBUG FILE TO "/RESPALDOS/Carlos/sp_actualiza_contacto_exitoso.out";
	--TRACE ON; 

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
      LET vempresa      = '001';
      LET cproceso      = '3001';
	  LET vfecha		=DATE(1);
	  LET vtipo_telefono = 0;

BEGIN
	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		CALL "informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
		RETURNING vvcCod_ret;
		RETURN cCod_ret, cMensaje;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	CALL "informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
	RETURNING vvcCod_ret;

	SELECT max(date(horainicio)) 
		INTO vfecha
	FROM "informix".cb_cat_movimientos
	WHERE tipologica >= 0;

	FOREACH WITH HOLD
		SELECT a.numcte,a.codigo_resultado,a.telefono,a.tipo_telefono
		INTO vnumcte,vcodigo_resultado,vtelefono,vtipo_telefono
		FROM "informix".cb_registro_llamadas a
		INNER JOIN bdinteg:si_telefonos_actual tel on (tel.numcte = a.numcte AND tel.tipo_tel = a.tipo_telefono AND tel.telefono = a.telefono AND tel.contacto = 0)
		WHERE a.empresa = vempresa
		AND a.fecha_insert = vfecha
		AND a.codigo_resultado IN (1,2,3,4,5)

		BEGIN WORK;
			UPDATE bdinteg:si_telefonos_actual SET contacto = 1
			WHERE numcte = vnumcte 
			AND tipo_tel = vtipo_telefono
			AND telefono = vtelefono;
		COMMIT WORK;
	END FOREACH;

	CALL "informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
	RETURNING vvcCod_ret;

	RETURN cCod_ret, cMensaje;
END;
END PROCEDURE;