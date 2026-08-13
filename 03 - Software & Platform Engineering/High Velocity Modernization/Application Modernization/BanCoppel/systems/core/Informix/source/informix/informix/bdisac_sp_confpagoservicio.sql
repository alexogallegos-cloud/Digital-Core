CREATE PROCEDURE "informix".sp_confpagoservicio (cSucursal CHAR (4), cCategoria CHAR (2), cConvenio CHAR(5), cReferencia1 CHAR (40), cReferencia2 CHAR(40),
                                              cFolio_suc CHAR (16))

    RETURNING
    CHAR(5), CHAR(200);

    -- Definicion de Variables
    DEFINE cCodRet      CHAR(5);
    DEFINE iSql_err     INTEGER;
	DEFINE iIsamErr	    INTEGER;
	DEFINE cDescripcion CHAR (200);
	DEFINE vcadena_ent  CHAR (100);
    DEFINE scont        INT8; 
    DEFINE scont2       INT8; 
    DEFINE wBegin       CHAR(1);
	DEFINE vCodRet      CHAR(5);
	DEFINE vRfc			CHAR(13);
	
	
     LET scont	       = 0; 
     LET scont2	       = 0; 
     LET cCodRet       = "00000";
     LET iSql_err      = 0;
	 LET iIsamErr      = 0;
	 LET cDescripcion  = "ACTUALIZACION FLAG-SUCURSAL EXITOSA.";
	 LET vcadena_ent   = cSucursal||'|'||cCategoria||'|'||cConvenio||'|'||TRIM(cReferencia1)||'|'||TRIM(cReferencia2)||'|'||cFolio_suc;
	 LET vCodRet	   = '00000';
	 LET vRfc 	       = '';

		--SET DEBUG FILE TO '/informix/lfp/new/exec_sp_confpagoservicio.out';
		--TRACE ON;
	 

    BEGIN
        ON EXCEPTION SET iSql_err, iIsamErr, cDescripcion
           IF iSql_err <> 0 THEN
              LET cCodRet = iSql_err;

              ROLLBACK WORK;

              IF (wBegin = "S") THEN
                 BEGIN WORK;
              END IF;               

			   INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (cCodRet,iIsamErr,cDescripcion ||' '|| scont||'-'||scont2,'sp_confpagoservicio',today,CURRENT);

			   INSERT INTO bdisac:"informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
						values ('sp_confpagoservicio', cFolio_suc, 0, cCodRet, vcadena_ent, CURRENT, CURRENT);	

               RETURN cCodRet, cDescripcion;

           END IF;
        END EXCEPTION;

       ON EXCEPTION IN (-535)
          LET wBegin = "S";
          ROLLBACK WORK;
          BEGIN WORK;
       END EXCEPTION WITH RESUME;
     SET ISOLATION COMMITTED READ;


--	2014.01.07 FRG-i
	--SET ISOLATION TO DIRTY READ;
	--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	SET LOCK MODE TO WAIT 5;

    LET wBegin = "N";

            IF cSucursal <> "" AND cCategoria <> "" AND cConvenio <> "" AND TRIM(cReferencia1) <> ""  AND cFolio_suc <> "" THEN

                BEGIN WORK;
				
						IF cCategoria = '07' AND (cConvenio = '004' OR cConvenio = '006' OR cConvenio = '007' OR cConvenio = '008' OR cConvenio = '009') THEN
								
							
							EXECUTE PROCEDURE bdisac:"informix".sp_obtienerfcremesa(cCategoria, cConvenio, TRIM(cReferencia1), cFolio_suc)
							INTO vCodRet, vRfc;
							
							UPDATE bdisac:"informix".sac_movimientos
							   SET  flag_confirmacion_sucursal = 1, referencia3 = vRfc
							 WHERE id_sucursal = cSucursal
							   AND numcategoria = cCategoria
							   AND  numconvenio = cConvenio
							   AND referencia1 = TRIM(cReferencia1)
							   AND folio_suc = cFolio_suc;

							LET scont  = dbinfo("sqlca.sqlerrd2");
							LET scont2 = dbinfo("sqlca.sqlerrd1"); 
						
						ELSE

							UPDATE bdisac:"informix".sac_movimientos
							   SET  flag_confirmacion_sucursal = 1
							 WHERE id_sucursal = cSucursal
							   AND numcategoria = cCategoria
							   AND  numconvenio = cConvenio
							   AND referencia1 = TRIM(cReferencia1)
							   AND folio_suc = cFolio_suc;

							LET scont  = dbinfo("sqlca.sqlerrd2");
							LET scont2 = dbinfo("sqlca.sqlerrd1"); 
						
						END IF;

                        IF(scont = 0) THEN
                           ROLLBACK WORK;

                            LET cCodRet = "00002";
                            LET cDescripcion = "No existe registro en Tabla bdisac:sac_movimientos";

                            INSERT INTO bdisac:"informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
                                VALUES ('sp_confpagoservicio', cFolio_suc, 0, cCodRet, vcadena_ent, CURRENT, CURRENT);

                            INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
                                VALUES (cCodRet,iIsamErr,scont||' - '||scont2,'sp_confpagoservicio - dbinfo',today,CURRENT);

                           IF (wBegin = "S") THEN
                              BEGIN WORK;
                           END IF;
                        END IF;

                       IF(cCodRet <> "00000") THEN
                          ROLLBACK WORK;
                       ELSE
                          COMMIT WORK;
                       END IF;

                       IF (wBegin = "S") THEN
                         BEGIN WORK;
                       END IF;

            ELSE
                -- Indica que uno de los campos llave viene vacio
                LET cCodRet = "00001";
			    LET cDescripcion = "Uno de los campos llave esta vacio.";
			   INSERT INTO bdisac:"informix".sac_log_envios (proceso, folio_suc, importe, cod_ret, cadena_ent, fecha_insert, hora_insert)
				values ('sp_confpagoservicio', cFolio_suc, 0, cCodRet, vcadena_ent, CURRENT, CURRENT);	
            END IF;

      RETURN cCodRet, cDescripcion;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : JosÃ© Angel LÃ³pez Adams',
'DESCRIPCION: Se encarga de confirmar el  movimiento para indicar que todo se grabo bien en sucursal',
'EJECUTADO O LLAMADO POR: Caja.exe()',
'FECHA : Septiembre de 2008',
'VERSION: 20080930',
'MODIFICO : Antonio Bastidas',
'DESCRIPCION: Se redimenciona el tamaÃ±o de referencia1 y referencia2 a 20 caracteres',
'EJECUTADO O LLAMADO POR: Procesos - DineroYa',
'FECHA : Diciembre de 2009',
'VERSION: 20091208.1627',
'MODIFICO : FRG',
'DESCRIPCION: Se agrega una tabla-bitacora para guardar los datos de entrada al SP',
'EJECUTADO O LLAMADO POR: Procesos - EjecuciÃ³n ConfirmaciÃ³n de Pago de Servicios',
'FECHA : Septiembre de 2011',
'VERSION: 20110905.1820',
'BD: bdisac',
'MODIFICO: Eduardo LÃ³pez Cuevas',
'EJECUTADO O LLAMADO POR: caja.exe',
'FECHA: 20130809.1721',
'MODIFICO : FRG',
'DESCRIPCION: Se agrega instrucciÃ³n para evitar bloqueos en tabla.',
'EJECUTADO O LLAMADO POR: Procesos - EjecuciÃ³n ConfirmaciÃ³n de Pago de Servicios',
'FECHA : Enero 2014',
'BD: bdisac',
'EJECUTADO O LLAMADO POR: caja.exe',
'FECHA: 20140107.1340',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sac_pldlim_teldom(
	pTipo_remesa VARCHAR(3),
	pDireccion VARCHAR(200),
	pMunicipio VARCHAR(100),
	pEstado VARCHAR(30),
	pCodigo_postal VARCHAR(50),
	pPeriodo VARCHAR(6),
	pUsuario_insert VARCHAR(8),
	pTelefono VARCHAR(10),
	pCelular  VARCHAR(10),
	pFolsuc    VARCHAR (16),
	pSucursal  VARCHAR (4),
	pRefUno    VARCHAR (20),
	pOpcion	   VARCHAR (10))

	--RETURNING CHAR(5), CHAR(80);
	RETURNING CHAR(5);

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr 		INTEGER;
    DEFINE cInfoErr         CHAR(100);
	DEFINE cMensaje			CHAR(80);
		
	DEFINE cConteo 	     		INTEGER;
	DEFINE cConteo2 	     	INTEGER;
	DEFINE cValor 	     		INTEGER;
	DEFINE cValorD 	     		INTEGER;
	DEFINE cValorT 	     		INTEGER;
	DEFINE cFolio 	     		VARCHAR (16);
	DEFINE cValida				INTEGER;
	DEFINE cValidaInsert		INTEGER;
	DEFINE cValidaBTST		INTEGER;



	--SET DEBUG FILE TO '/informix/HMLG/sp_sac_pldlim_teldom.out';
	--TRACE ON; 
	--SET DEBUG FILE TO '/INFORMIXTMP/HMLG/sp_sac_pldlim_teldom.out';
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
			--Manejo de errores, en caso de error, envío codigo de error y guarda evidencia
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
		
		--BUSCA EXCEPCION DE LIMITE POR SUCURSAL
		
		SELECT COUNT(*)
		INTO cValida
		FROM "informix".sac_pldlimite_teldom_excpsuc
		WHERE tipo_remesa = pTipo_remesa
		AND id_sucursal = pSucursal;
		
		IF cValida = 0 THEN 
			SELECT valor 
				INTO cValorD 
				FROM "informix".sac_param
				WHERE empresa = '001'
				AND cod_param = 130;
				
			SELECT valor 
				INTO cValorT
				FROM "informix".sac_param
				WHERE empresa = '001'
				AND cod_param = 131;
		ELSE 
			SELECT limitedom,limitetel
				INTO cValorD,cValorT
				FROM "informix".sac_pldlimite_teldom_excpsuc
				WHERE tipo_remesa = pTipo_remesa
				AND id_sucursal = pSucursal;
		END IF;
		
		
		--INICIA Validacion de Direcciones.
		LET cValida 			= 0;
		
		SELECT conteo
		INTO cConteo
		FROM "informix".sac_pldlimite_domicilios
		WHERE periodo = pPeriodo
			AND tipo_remesa = pTipo_remesa
			AND codigo_postal = pCodigo_postal
			AND direccion = pDireccion
			AND municipio = pMunicipio
			AND estado = pEstado;
		
		
		IF cConteo > 0  THEN
			
			IF cConteo >= cValorD THEN
				LET cValida = 1;
			END IF;
			
		ELIF cConteo is null then
			LET cConteo = 1;
			
			INSERT INTO "informix".sac_pldlimite_domicilios (tipo_remesa,direccion,municipio,estado,codigo_postal,periodo,conteo,usuario_insert,fecha_insert)
				VALUES (pTipo_remesa,pDireccion,pMunicipio,pEstado,pCodigo_postal,pPeriodo,cConteo,pUsuario_insert,CURRENT);
			
			LET cValidaInsert = 1;
	
		END IF;	
		
		
		/*INICIA Validacion de numeros telefonicos ingresados*/
		
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