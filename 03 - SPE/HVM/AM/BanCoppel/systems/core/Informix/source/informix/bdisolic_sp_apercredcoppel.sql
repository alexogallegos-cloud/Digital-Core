CREATE PROCEDURE "informix".sp_apercredcoppel(p_Empresa CHAR(3), p_NumCte VARCHAR (20), p_NumRef VARCHAR(20), p_Usuario VARCHAR(20), p_NumSolicitud VARCHAR(20), pUserInsert CHAR (8))
RETURNING
     CHAR(5); ---cod_ret

    DEFINE v_cod_ret      CHAR(5);
    DEFINE iSqlErr        INTEGER;
    DEFINE vFechaHoy	  DATE;
	DEFINE cSucursal      CHAR(4);
	DEFINE cNomPromotor   CHAR(104);

    LET v_cod_ret = '00000';
    LET vFechaHoy = '01/01/1900';
	LET cSucursal = '';

BEGIN

	ON EXCEPTION SET iSqlerr
		IF iSqlErr <> 0 THEN
			LET v_cod_ret = iSqlErr;
			RETURN v_cod_ret;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_AperCredCoppel.out";
	--TRACE ON;

	IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_adiccoppel WHERE numcte =  p_NumCte) THEN
		IF (p_Empresa IS NULL OR p_Empresa = '') OR (p_NumCte IS NULL OR p_NumCte = '') OR (p_NumRef IS NULL OR p_NumRef = '') OR (p_Usuario IS NULL OR p_Usuario = '') OR (p_NumSolicitud IS NULL OR p_NumSolicitud = '') OR (pUserInsert IS NULL OR pUserInsert = '') THEN
			   LET v_cod_ret = '00002';
		ELSE
			--- OBTIENE LA FECHA DEL DIA
			SELECT fecha_hoy
			INTO vFechaHoy
			FROM bdinteg:"informix".si_fechas;

			--Obtiene la Sucursal
			SELECT sucursal
			INTO cSucursal
			FROM bdisolic:"informix".ss_solicitudes
			WHERE num_solicitud = p_NumSolicitud;

			--- ACTUALIZA LA TABLA DE CLIENTES
			UPDATE bdinteg:"informix".si_cliente
			SET numcte_ref = p_NumRef, fecha_alta = vFechaHoy, user_insert = p_Usuario
			WHERE numcte = p_NumCte;

			--- INSERTA EN LA TABLA DE LA RELACION DE LOS CLIENTES Y SUS ADICIONALES
			INSERT INTO bdinteg:"informix".si_adiccoppel (empresa, numctecoppel, secuencia, sucursal, numtarcoppel, numcte, tipotar, status, fechamov, user_insert)
			VALUES (p_Empresa, p_NumRef, 1, cSucursal, p_NumRef, p_NumCte, '1', 'S', vFechaHoy, pUserInsert);

			--REGISTRA LA APERTURA DEL CREDITO EN LA TABLA ss_autorizacion
			SELECT  FIRST 1 nombre INTO cNomPromotor FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pUserInsert;

			LET cNomPromotor = "Apertura de Credito Autorizada por: " || TRIM(cNomPromotor);

			INSERT INTO bdisolic:ss_autorizacion
			(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, causa_solicitud, fecha_entrada, fecha_salida, user_insert, fecha_insert, revision_cac)
			VALUES
			(p_Empresa, pUserInsert, p_NumSolicitud, 'AP', cNomPromotor, '', vFechaHoy, vFechaHoy, USER, vFechaHoy, 0);

			--- ACTUALIZA LA SOLICITUD CON STATUS DE TARJETA ASIGNADA
			UPDATE bdisolic:"informix".ss_solicitudes
			SET status_solicitud = 'AP'
			WHERE empresa = p_Empresa AND num_solicitud = p_NumSolicitud;

		END IF
	ELSE
		LET v_cod_ret = '00001';
	END IF;

  RETURN v_cod_ret;

END;
--##############################################################################
--## Procedimiento   : sp_AperCredCoppel
--## Base de Datos   : bdisolic
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Enero de 2009
--##Descripcion : Actualiza lel numero de tarjeta "numero de referencia" del cliente
--## Version         : 1.1
--## Creado por      : Frank Gaxiola
--## Fecha creacion  : Octubre de 2011
--##Descripcion : Se agrega insert a la tabla ss_autorizacion
--##############################################################################
END PROCEDURE;