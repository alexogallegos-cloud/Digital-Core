CREATE PROCEDURE "informix".sp_grabacompromisosacuerdos_cajcapt(pEmpresa CHAR(3), pSucursal CHAR(4), pOrigen SMALLINT,
pEmpleadoCaptura INTEGER, pNumCliente CHAR(20), pNumCuenta CHAR(20),pPlazo CHAR(2), pImporte INTEGER, pTipo CHAR(1),
pEmpleadoSup INTEGER, pNombreSup CHAR(40), pFechaCompac DATE, pTelParticular CHAR(13), pTelCelular CHAR(13), pCorreoElectronico CHAR(100))

RETURNING CHAR(6);

    DEFINE vDataErr			VARCHAR(64);
    DEFINE iSqlErr			INTEGER;
    DEFINE iSamErr			INTEGER;
    DEFINE cCodRet			CHAR(6);
    DEFINE cNumcliente		CHAR(20);
    DEFINE cNumCuenta		CHAR(20);
    DEFINE cActivo			CHAR(1);
    DEFINE cTipoCompac		CHAR(1);
    DEFINE dtFecha			DATE;
    DEFINE cPlazo			CHAR(2);
    DEFINE sActivo			SMALLINT;
    DEFINE sDiasplazo		SMALLINT;
    DEFINE sDiasfecha		SMALLINT;
    DEFINE c_codret 		CHAR(5);
	DEFINE cCodret_tel 		CHAR(6);
	DEFINE cCodret_cel		CHAR(6);
	DEFINE cCodret_correo	CHAR(100);
	DEFINE cCodRetValTel   	CHAR(3);
	DEFINE cValTelPartic	CHAR(1);
	DEFINE cValTelCelular	CHAR(1);
	DEFINE cValTelOfi		CHAR(1);
	DEFINE iCuenta_cte      INTEGER;
	DEFINE vcantReg		     SMALLINT;

	    --INICIALIZACION DE VARIABLES--
    LET cCodRet				= "000";
    LET dtFecha				= '01-01-1900';
    LET cPlazo				= '';
    LET sActivo				= 0;
    LET sDiasplazo			= 0;
    LET sDiasfecha			= 0;
    LET c_codret			= '000';
	LET cCodret_tel			= '000';
	LET cCodret_cel			= '0000';
	LET cCodret_correo		= '0000';
	LET cCodRetValTel		= '0000';
	LET cValTelPartic		= '0';
	LET cValTelCelular		= '0';
	LET cValTelOfi			= '0';
	LET iCuenta_cte         = 0;
	LET vcantReg            = 0;
BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr;
            Rollback;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/macf/sp_grabacompromisosacuerdos.out";
    --TRACE ON;

IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pOrigen,'') <> 0 AND NVL(pEmpleadoCaptura,0) <> 0
    AND NVL(pNumCliente,'') <> '' AND NVL(pNumCuenta,'') <> ''  AND NVL(pPlazo,'') <> '' AND NVL(pImporte,0) <> 0
    AND  NVL(pTipo,'') <> ''AND NVL(pEmpleadoSup,0) <> 0 AND NVL(pNombreSup,'') <> '' AND NVL(pFechaCompac,'') <> '' THEN
--	AND NVL(pTelParticular,'') <> '' AND NVL(pTelCelular,'') <> ''AND NVL(pCorreoElectronico,'') <> '' THEN


	IF (SUBSTR(pPlazo,1,1) = '0') THEN
		LET pPlazo = SUBSTR(pPlazo,2,1);
	END IF;

	IF pOrigen = '1' THEN
		LET pImporte = pImporte / 100;
	END IF;

	SELECT {+INDEX("informix".cb_compac idx_compac2)} count(*)	into iCuenta_cte
	FROM "informix".cb_compac
	WHERE empresa = pEmpresa AND numcliente = pNumCliente AND numcuenta = pNumCuenta;
	
	    IF iCuenta_cte = 0 THEN
		
	
		--IF NOT EXISTS(SELECT {+INDEX("informix".cb_compac idx_compac2)} numcliente
		--FROM "informix".cb_compac
		--WHERE empresa = pEmpresa AND numcliente = pNumCliente AND numcuenta = pNumCuenta) THEN

			INSERT INTO "informix".cb_compac (empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, importe, tipo_compac,
			activo, flag_pago, efectuo_compac, nombre_efectuo, fecha_compac, fecha_insert, hora_insert)
			VALUES (pEmpresa, pSucursal, pOrigen, pEmpleadoCaptura, pNumCliente, pNumCuenta, pPlazo, pImporte, pTipo, '1', '0', pEmpleadoSup, pNombreSup, pFechaCompac, CURRENT, CURRENT);

            LET cCodRet = "000";   --INSERCION CORRECTA

			UPDATE bdicred:sd_indicador_cred SET num_convenios_hist = nvl(num_convenios_hist,0) + 1
			 WHERE empresa = pempresa AND num_credito = pnumcuenta;
				 
			 LET vCantReg = DBINFO("sqlca.sqlerrd2");

			 if vCantReg = 0 then
				UPDATE bdicred:sd_indicador_cred_crd SET num_convenios_hist = nvl(num_convenios_hist,0) + 1
				WHERE empresa = pempresa AND num_credito = pnumcuenta;
			 end if;
			
			IF pTelParticular != '' OR pTelCelular != '' THEN
				CALL bdinteg:"informix".sp_validatelefono(pEmpresa, pTelParticular, pTelCelular, '')
				RETURNING	cCodRetValTel, cValTelPartic, cValTelCelular, cValTelOfi;

				IF cCodRetValTel = '000' AND cValTelPartic = 0 THEN

					LET cCodRet = "004";   --INSERCION CORRECTA Y TELEFONO PARTICULAR INCORRECTO

				END IF

				IF cCodRetValTel = '000' AND cValTelCelular = 0 THEN

					LET cCodRet = "005";   --INSERCION CORRECTA Y TELEFONO CELULAR INCORRECTO

				END IF

				IF cCodRetValTel = '001' AND cValTelPartic = 0 AND cValTelCelular = 0 THEN

					LET cCodRet = "006";   --INSERCION CORRECTA Y AMBOS TELEFONOS SON INVALIDOS

				END IF

				--SI ALGUNOS DE LOS DOS O AMBOS TELEFONOS SON VALIDOS
				IF cCodRet <> '006' THEN

					IF cCodRet <> '004' THEN --SI EL TELEFONO PARTICULAR FUE INVALIDO Y TELEFONO CELULAR CORRECTO
						CALL  bdinteg:"informix".sp_registra_telefonos( pEmpresa, pNumCliente, pTelParticular, 1, '', 0, 1, pEmpleadoCaptura)
						RETURNING cCodret_tel;
					END IF

					IF cCodRet <> '005' THEN --SI EL TELEFONO CELULAR FUE INVALIDO Y TELEFONO PARTICULAR CORRECTO
						CALL  bdinteg:"informix".sp_registra_telefonos( pEmpresa, pNumCliente, pTelCelular, 2, '', 0, 1, pEmpleadoCaptura)
						RETURNING cCodret_cel;
					END IF

				END IF
			END IF
			
			IF pCorreoElectronico != '' THEN
				CALL bdinteg:"informix".sp_registra_correos(pEmpresa, pNumCliente, pCorreoElectronico, 1, 1, pEmpleadoCaptura)
				RETURNING	cCodret_correo;
			END IF
		ELSE
			
			LET cCodRet = "007"; --EL CLIENTE YA TIENE CONVENIO REGISTRADO EN LA CB_COMPAC
       END IF;
ELSE
    LET cCodRet        = "003";   --FALTA ALGUN PARAMETRO
END IF;

  IF c_codret = '000' THEN
    EXECUTE PROCEDURE bdicred:"informix".sp_graba_indicador(pempresa, pNumCuenta,pImporte,'' , CURRENT, 5) INTO c_codret;
  END IF;
    RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE ACTUALIZA PARA AGREGAR CAMPOS DE RETORNO TELEFONO PARTICULAR, TELEFONO CELULAR Y CORREO ELECTRONICO.',
'AUTOR: HUGO VAZQUEZ ',
'FECHA DE CREACION: 09/10/2013',
'VERSION: 09102013.1026 .',
'BD:BDICOBRANZA',
'MODIFICA: MARCO CARDENAS',
'NUMERO DE EMPLEADO: 97959456',
'SOLICITA: RICARDO SANCHEZ',
'DESCRIPCION: SE MODIFICA SP PARA QUE SOLO SE INSERTEN CONVENIOS Y REGRESE EL CODIGO "007" PARA EL CLIENTE QUE YA TIENE CONVENIO ACTIVO',
'FOLIO: 306-RQM 09 340 CONVENIOS DE PAGO COBRANZA CALLE PARA PP TODAS SUS MODALIDADES, CREDINOMINA Y NVOS PRODUCTOS',
'FECHA: 14/09/2017',
'BD:BDICOBRANZA',
'DESCRIPCION: Actualizar indicadores del TRIAD',
'AUTOR: Marco A. Campos',
'FECHA MODIFICACION: 2018/08/30';

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