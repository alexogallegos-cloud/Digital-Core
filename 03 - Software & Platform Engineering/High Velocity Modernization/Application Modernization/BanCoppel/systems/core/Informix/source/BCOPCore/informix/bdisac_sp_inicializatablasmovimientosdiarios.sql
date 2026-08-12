CREATE PROCEDURE "informix".sp_inicializatablasmovimientosdiarios()
RETURNING CHAR(5);
    DEFINE iSqlErr, iIsamErr  INTEGER;
    DEFINE cCodRet            CHAR(5);
    DEFINE cInfoErr           CHAR(100);
    DEFINE dFecha_hoy         DATE;

    LET cCodRet = '00000';
	
	--SET DEBUG FILE TO "/informix/luisBeltran/BDISAC/sp_inicializatablasmovimientosdiarios.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_InicializaTablasMovimientosDiarios");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
--se  cambia la consulta para evitar una busqueda--
     SELECT MIN(fecha_hoy) 
     INTO dFecha_hoy
     FROM bdisac:sac_fechas;




        DELETE{+AVOID_FULL("informix".sac_movimientos)} FROM bdisac:sac_movimientos WHERE fecha_pago = dFecha_hoy;
        DELETE {+AVOID_FULL("c92357113".sac_movimientosdetalle)}  FROM bdisac:sac_movimientosdetalle WHERE fecha = dFecha_hoy;
        UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_movimientos;
        UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_movimientosdetalle;
		UPDATE STATISTICS MEDIUM FOR TABLE sac_movimientoshistorial distributions ONLY;
		UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_movimientoshistorial;
		--ABONOS OMNICANAL 
		DELETE {+AVOID_FULL("informix".sac_movimientos_detalle_td)}  FROM bdisac:sac_movimientos_detalle_td WHERE fecha_abono = dFecha_hoy;
		UPDATE STATISTICS MEDIUM FOR TABLE bdisac:sac_movimientos_detalle_td;
        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jos?ngel L?? Adams',
'DESCRIPCION: Se encarga de limpiar las tablas de movimientos diarios',
'EJECUTADO O LLAMADO POR:',
'sp_CierreSACl()',
'FECHA : Septiembre de 2008',
'VERSION: 20080930',
'BD    : bdisac',
'==========================================================================',
'AUTOR : Luis Alberto Beltran Rodriguez',
'DESCRIPCION: Genera el archivo de cobranza Coppel de acuerdo a Layout proporcionado por carteras y los nuevos servicios omnicanales',
'EJECUTADO O LLAMADO POR:',
'sp_procesocierresac(''Empresa'')',
'FECHA : Marzo de 2022',
'VERSION: 202203',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reverso_remesas_cpl
(
	pempresa  	CHAR(3),
	psucursal 	CHAR(4),
	pusuario  	CHAR(8),
	pfolio    	CHAR(16)
)
RETURNING
CHAR(5)     AS CodErr,
CHAR(2)     AS IdentificadorProceso,
CHAR(80) 	AS descripcion;

	-- Definicion de variables --
	DEFINE cCodErr 						CHAR(5);
	DEFINE cIdentificadorProceso 		CHAR(2);
	DEFINE cDescripcion					CHAR(80);
	DEFINE iSqlErr                     	INTEGER;
	DEFINE vtransaccion					SMALLINT;
	DEFINE cont_exist					INTEGER;

	-- Inicializacion de variables --
	LET cCodErr 					= '00000';
	LET cIdentificadorProceso 		= '00';
	LET cDescripcion 				= '';
	LET	cont_exist					= 0;
	LET pempresa = NVL(pempresa,'');
	LET pSucursal = NVL(pSucursal,'');
	LET pusuario = NVL(pusuario,'');
	LET pfolio = NVL(pfolio,'');
	LET vtransaccion = 0;

	--SET DEBUG FILE TO "/informix/BDHS/homologacionCPL/logs/sp_reverso_remesas_cpl.log";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET cCodErr = iSqlErr;
				RETURN cCodErr, cIdentificadorProceso, cDescripcion;
			END IF;
        END EXCEPTION;

		ON EXCEPTION IN (-535)
			let vtransaccion = 1;
		END EXCEPTION WITH resume;
		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN WORK;
		ELSE
			BEGIN WORK;
		END IF;

		--Validar que los parametros de entrada no vengan vacios o nulos
		IF pempresa = '' OR  psucursal = '' OR pusuario = '' OR pfolio = '' THEN
			LET cCodErr = '00001';
			LET cIdentificadorProceso = '01';
		END IF;

		IF cCodErr = '00000' THEN

			SELECT COUNT (referencia1)
            INTO cont_exist
            FROM bdisac:sac_movimientos
            WHERE folio_suc = pfolio
            AND status_cancelado <> 'S';

			IF cont_exist > 0 THEN

				UPDATE {+INDEX (bdisac:sac_movimientos idxsac_mov114)} bdisac:sac_movimientos
				SET status_cancelado = 'S'
				WHERE folio_suc = pfolio;

				UPDATE bdisac:sac_remesas_estadistica
				SET    status_cancelado = 'S'
				WHERE  folio_suc = pfolio;

			ELSE
				LET cCodErr = '00002';
				LET cIdentificadorProceso = '02';
			END IF;



		END IF;
    RETURN cCodErr, cIdentificadorProceso, cDescripcion;
END
END PROCEDURE
DOCUMENT
'FOLIO.........: HOMOLOGACION COPPEL',
'AUTOR.........: Bryan Daniel Hernandez Santos - Abraham Gonzalez PeÃ±a',
'FECHA.........: 02/11/2023',
'MODIFICACION..: Procedimiento para reversar remesas desde cajas de abono coppel',
'SUSTENTO......: ',
'SOLICITA......: EDGAR NAVARRO',
'BD............: BDISAC';

CREATE PROCEDURE "informix".sp_sac_pldlim_teldom_cpl(
	pTipo_remesa 		VARCHAR(3),
	pDireccion 			VARCHAR(200),
	pMunicipio 			VARCHAR(100),
	pEstado 			VARCHAR(30),
	pCodigo_postal 		VARCHAR(50),
	pPeriodo 			VARCHAR(6),
	pUsuario_insert 	VARCHAR(8),
	pTelefono 			VARCHAR(10),
	pCelular  			VARCHAR(10),
	pFolsuc    			VARCHAR (16),
	pSucursal  			VARCHAR (4),
	pRefUno    			VARCHAR (20),
	pOpcion	   			VARCHAR (10))

	--RETURNING CHAR(5), CHAR(80);
	RETURNING CHAR(5);

	--Definicion de Variables
	DEFINE cCodRet				CHAR(5);
    DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr 			INTEGER;
    DEFINE cInfoErr				CHAR(100);
	DEFINE cMensaje				CHAR(80);
	DEFINE cConteo 	  			INTEGER;
	DEFINE cConteo2 	 		INTEGER;
	DEFINE cValor 	  			INTEGER;
	DEFINE cValorD 	  			INTEGER;
	DEFINE cValorT 	  			INTEGER;
	DEFINE cFolio 	    		VARCHAR(16);
	DEFINE cValida				INTEGER;
	DEFINE cValidaBTST			INTEGER;
	DEFINE cValidaInsert        INTEGER;
	
	--SET DEBUG FILE TO '/informix/BDHS/homologacionCPL/logs/sp_sac_pldlim_teldom_cpl.log';
	--TRACE ON;

	-- Inicializa variables
	LET cCodRet            	= "00000";
	LET cMensaje			= 'PROCESO EXITOSO';
	LET cConteo 			= 0;
	LET cConteo2 			= 0;
	LET cValor 				= 0;
	LET cValorD				= 0;
	LET cValorT 			= 0;
	LET cValida 			= 0;
	LET cValidaInsert 		= 0;
	LET cValidaBTST 		= 0;


    BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envï¿½o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sac_pldlim_teldom");

				LET cMensaje = "ERROR EN LA EJECUCION DEL SP";
                RETURN cCodRet;
            END IF;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

	IF pOpcion = 'NORMAL' THEN
		SELECT valor -- Obtiene el lÃ­mite de 32
			INTO cValorD
			FROM "informix".sac_param
			WHERE empresa = '001'
			AND cod_param = 130;

		SELECT valor -- Obtiene el lÃ­mite de 32
			INTO cValorT
			FROM "informix".sac_param
			WHERE empresa = '001'
			AND cod_param = 131;

		--INICIA Validacion de Direcciones.
		LET cValida 			= 0;

		SELECT conteo --Conteo de operaciones por domicilio
		INTO cConteo
		FROM "informix".sac_pldlimite_domicilios
		WHERE periodo = pPeriodo
			AND tipo_remesa = pTipo_remesa
			AND codigo_postal = pCodigo_postal
			AND direccion = pDireccion
			AND municipio = pMunicipio
			AND estado = pEstado;

		IF cConteo > 0  THEN

			IF cConteo >= cValorD THEN --Conteo mayor a limite permitido por domicilios
				LET cValida = 1;
			END IF;

		ELIF cConteo is null then --No encuentra registro en sac_pldlimite_domicilios, entonces inserta el primero
			LET cConteo = 1;

			INSERT INTO "informix".sac_pldlimite_domicilios (tipo_remesa,direccion,municipio,estado,codigo_postal,periodo,conteo,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pDireccion,pMunicipio,pEstado,pCodigo_postal,pPeriodo,cConteo,pUsuario_insert,CURRENT);

			LET cValidaInsert = 1;

		END IF;

		/*INICIA Validacion de numeros telefonicos ingresados*/
		--SOLO APPRIZA--

		SELECT conteo
		INTO cConteo2
		FROM "informix".sac_pldlimite_telefonos
		WHERE periodo = pPeriodo
		AND tipo_remesa = pTipo_remesa
		AND telefono = pTelefono
		AND celular = pCelular;

		IF cConteo2 > 0  THEN

			IF pTipo_remesa = 'BTS' THEN
				IF pTelefono = '' AND pCelular = '' THEN
					LET cValidaBTST = 1;
				END IF;
			END IF;

			IF cValidaBTST = 0 THEN
				IF cConteo2 >= cValorT THEN
					IF cValida = 1 THEN
						LET cValida = 3;
					ELSE
						LET cValida = 2;
					END IF;
				END IF;
			END IF;

		ELIF cConteo2 IS NULL THEN
			LET cConteo2 = 1;

			INSERT INTO "informix".sac_pldlimite_telefonos (tipo_remesa,telefono,celular,periodo,conteo,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pTelefono,pCelular,pPeriodo,cConteo2,pUsuario_insert,CURRENT);

			IF cValidaInsert = 0 THEN
				LET cValidaInsert = 2;
			ELIF cValidaInsert = 1 THEN
				LET cValidaInsert = 3;
			END IF;

		END IF;

		/*
		cValida =
			0 - Parametros de Domicilio y Telefono Validos
			1 - Domicilio Excede Limite
			2 - Telefonos Excede Limite
			3 - Domicilio y Telefono Excede Limites
		*/


		IF cValida = 1 THEN
			LET cCodRet            	= "00001";
			LET cMensaje			= 'Direccion Excede Limite';

			LET cConteo = cConteo + 1;
			UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
					WHERE periodo = pPeriodo
					AND tipo_remesa = pTipo_remesa
					AND codigo_postal = pCodigo_postal
					AND direccion = pDireccion
					AND municipio = pMunicipio
					AND estado = pEstado;

			INSERT INTO "informix".sac_pldlimite_teldom_rechazos (tipo_remesa,id_sucursal,direccion,municipio,estado,codigo_postal,periodo,conteodom,limitedom,telefono,celular,conteotel,limitetel,tiporechazo,motivorechazo,numremesa,folio_suc,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pSucursal,pDireccion,pMunicipio,pEstado,pCodigo_postal,pPeriodo,cConteo,cValorD,pTelefono,pCelular,cConteo2,cValorT,cValida,'Direccion Excede Limite',pRefUno,pFolsuc,pUsuario_insert,current);

		ELIF cValida = 2 THEN
			LET cCodRet            	= "00002";
			LET cMensaje			= 'Telefono Excede Limite';
			LET cConteo2 = cConteo2 + 1;
			UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
					WHERE periodo = pPeriodo
					AND tipo_remesa = pTipo_remesa
					AND telefono = pTelefono
					AND celular = pCelular;

			INSERT INTO "informix".sac_pldlimite_teldom_rechazos (tipo_remesa,id_sucursal,direccion,municipio,estado,codigo_postal,periodo,conteodom,limitedom,telefono,celular,conteotel,limitetel,tiporechazo,motivorechazo,numremesa,folio_suc,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pSucursal,pDireccion,pMunicipio,pEstado,pCodigo_postal,pPeriodo,cConteo,cValorD,pTelefono,pCelular,cConteo2,cValorT,cValida,'Telefono Excede Limite',pRefUno,pFolsuc,pUsuario_insert,current);

		ELIF cValida = 3 THEN
			LET cCodRet            	= "00003";
			LET cMensaje			= 'Direccion y Telefono Excede Limite';
			LET cConteo = cConteo + 1;
			LET cConteo2 = cConteo2 + 1;
			UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
					WHERE periodo = pPeriodo
					AND tipo_remesa = pTipo_remesa
					AND codigo_postal = pCodigo_postal
					AND direccion = pDireccion
					AND municipio = pMunicipio
					AND estado = pEstado;

			UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
					WHERE periodo = pPeriodo
					AND tipo_remesa = pTipo_remesa
					AND telefono = pTelefono
					AND celular = pCelular;

			INSERT INTO "informix".sac_pldlimite_teldom_rechazos (tipo_remesa,id_sucursal,direccion,municipio,estado,codigo_postal,periodo,conteodom,limitedom,telefono,celular,conteotel,limitetel,tiporechazo,motivorechazo,numremesa,folio_suc,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pSucursal,pDireccion,pMunicipio,pEstado,pCodigo_postal,pPeriodo,cConteo,cValorD,pTelefono,pCelular,cConteo2,cValorT,cValida,'Direccion y Telefono Exceden Limite',pRefUno,pFolsuc,pUsuario_insert,current);
		ELSE

			IF cValidaInsert = 0 THEN

				LET cConteo = cConteo + 1;
				LET cConteo2 = cConteo2 + 1;
				UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
						WHERE periodo = pPeriodo
						AND tipo_remesa = pTipo_remesa
						AND codigo_postal = pCodigo_postal
						AND direccion = pDireccion
						AND municipio = pMunicipio
						AND estado = pEstado;

				UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
						WHERE periodo = pPeriodo
						AND tipo_remesa = pTipo_remesa
						AND telefono = pTelefono
						AND celular = pCelular;

			ELIF  cValidaInsert = 1 THEN
				LET cConteo2 = cConteo2 + 1;
				UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
						WHERE periodo = pPeriodo
						AND tipo_remesa = pTipo_remesa
						AND telefono = pTelefono
						AND celular = pCelular;

			ELIF  cValidaInsert = 2 THEN
				LET cConteo = cConteo + 1;
					UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
						WHERE periodo = pPeriodo
						AND tipo_remesa = pTipo_remesa
						AND codigo_postal = pCodigo_postal
						AND direccion = pDireccion
						AND municipio = pMunicipio
						AND estado = pEstado;

			END IF;

		END IF;

		COMMIT WORK;
		BEGIN WORK;

	ELIF pOpcion = 'REVERSO' THEN

		SELECT conteo
		INTO cConteo
		FROM "informix".sac_pldlimite_domicilios
		WHERE periodo = pPeriodo
			AND tipo_remesa = pTipo_remesa
			AND codigo_postal = pCodigo_postal
			AND direccion = pDireccion
			AND municipio = pMunicipio
			AND estado = pEstado;

		SELECT conteo
			INTO cConteo2
			FROM "informix".sac_pldlimite_telefonos
			WHERE periodo = pPeriodo
			AND tipo_remesa = pTipo_remesa
			AND telefono = pTelefono
			AND celular = pCelular;

		LET cConteo = cConteo - 1;
		LET cConteo2 = cConteo2 - 1;

		UPDATE "informix".sac_pldlimite_domicilios SET conteo = cConteo
				WHERE periodo = pPeriodo
				AND tipo_remesa = pTipo_remesa
				AND codigo_postal = pCodigo_postal
				AND direccion = pDireccion
				AND municipio = pMunicipio
				AND estado = pEstado;

		UPDATE "informix".sac_pldlimite_telefonos SET conteo = cConteo2
				WHERE periodo = pPeriodo
				AND tipo_remesa = pTipo_remesa
				AND telefono = pTelefono
				AND celular = pCelular;


		COMMIT WORK;
		BEGIN WORK;
	END IF;

		RETURN cCodRet;

    END;
END PROCEDURE;