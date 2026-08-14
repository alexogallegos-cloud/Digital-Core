CREATE PROCEDURE "informix".sp_pos_verificastatusrepbitacora(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(50) AS nombre_archivo,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,		
		CHAR(15) AS proceso;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cProceso CHAR(15);
	DEFINE cNombre_archivo CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cProceso='';
	LET cNombre_archivo=0;
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_pos_verificastatusrepbitacora.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+INDEX (bdicnweb:sw_verificastatusrepposbitacora idx_sw_verificastatusrepposbitacora)} status,nombre_archivo,error_proceso,error,tipo_proceso
		INTO cStatus,cNombre_archivo,cErrorProceso,cError,cProceso
		FROM "informix".sw_verificastatusrepposbitacora
		WHERE usuario_insert = TRIM(pUsuario);
				
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'','','I','','';
		ELSE 			
			RETURN cCodRet,cNombre_archivo,cStatus,cErrorProceso,cError,cProceso;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 25/11/2021',
'DESCRIPCION: SPL encargado de hacer la validacion del reporte bitacora pos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_procesaarchivodepositocoppel(pUsuario CHAR(8), pIdFuncion CHAR(10))
      RETURNING CHAR(5) AS codRet,
                CHAR(60) AS cMensaje;

	DEFINE cCodRet 				CHAR(5);
	DEFINE cClave_transaccion 	CHAR(4);
	DEFINE cDesc_transaccion 	CHAR(50);
	DEFINE iSqlErr 				INTEGER;
	DEFINE cEmpresa 			CHAR(3);
	DEFINE iRecuperacion 		INTEGER;
	DEFINE dFecha				DATE;
	DEFINE cComprobante			CHAR(10);
	DEFINE cSucCoppel			CHAR(10);
	DEFINE cNombreSuc			CHAR(40);
	DEFINE cCajaGeneral			CHAR(4);
	DEFINE cPlaza				CHAR(20);
	DEFINE mImpComprobante		MONEY(14,2);
	DEFINE mImpFicha			MONEY(14,2);
	DEFINE iCantidad1			INTEGER;
	DEFINE iCantidad2			INTEGER;
	DEFINE iCantidad3			INTEGER;
	DEFINE iCantidad4			INTEGER;
	DEFINE iCantidad5			INTEGER;
	DEFINE iCantidad6			INTEGER;
	DEFINE iCantidad7			MONEY(14,2);
	DEFINE mFaltante			MONEY(14,2);
	DEFINE mSobrante			MONEY(14,2);
	DEFINE iTotReg				INTEGER;
	DEFINE cMensaje				CHAR(60);
	DEFINE iConsecutivo			INTEGER;
	DEFINE iCalculo				INTEGER;
	DEFINE iResto				MONEY(14,2);
	DEFINE vnum 				INTEGER;
	DEFINE cCajaFalta			CHAR(300);
	DEFINE i					INTEGER;
	DEFINE cCajaFaltaAux		CHAR(300);
	DEFINE iCajasFalta			INTEGER;
	
	LET cCodRet 				= '00000';
	LET iSqlErr 				= 0;
	LET cEmpresa 				= '001';
	LET cClave_transaccion 		= '';
	LET cDesc_transaccion 		= '';
	LET iRecuperacion 			= 0;
	LET dFecha					= DATE(1);
	LET cComprobante			= '';
	LET cSucCoppel				= '';
	LET cNombreSuc				= '';
	LET cCajaGeneral			= '';
	LET cPlaza					= '';
	LET mImpComprobante			= 0;
	LET mImpFicha				= 0;
	LET iCantidad1				= 0;
	LET iCantidad2				= 0;
	LET iCantidad3				= 0;
	LET iCantidad4				= 0;
	LET iCantidad5				= 0;
	LET iCantidad6				= 0;
	LET iCantidad7				= 0;
	LET mFaltante				= 0;
	LET mSobrante				= 0;
	LET iTotReg					= 0;
	LET iConsecutivo			= 0;
	LET cMensaje				= '';
	LET iCalculo				= 0;
	LET iResto					= 0;
	LET vnum 					= 0;
	LET cCajaFalta				= '';
	LET i                       = 0;
	LET cCajaFaltaAux			= '';
	LET iCajasFalta             = 0;

	BEGIN

        ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				UPDATE "informix".sw_verificastatuscargaarchivocoppel
				SET status = 'E', error = cCodRet,faltacaja = 0, cajafaltante = ''
				WHERE usuario_insert = pUsuario;
				
				RETURN cCodRet, cMensaje;
			END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_procesaarchivodepositocoppel.out';   
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DELETE {+INDEX (bdicnweb:sw_verificastatuscargaarchivocoppel idx_sw_verificastatuscargaarchivocoppel)} FROM "informix".sw_verificastatuscargaarchivocoppel WHERE usuario_insert = pUsuario;
		
		INSERT INTO "informix".sw_verificastatuscargaarchivocoppel(usuario_insert, status,	error_proceso, error) VALUES(pUsuario,'I','','');
		

        IF  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			
			UPDATE {+INDEX (bdicnweb:sw_verificastatuscargaarchivocoppel idx_sw_verificastatuscargaarchivocoppel)} "informix".sw_verificastatuscargaarchivocoppel
			SET status = 'E', error = cCodRet,faltacaja = 0, cajafaltante = ''
			WHERE usuario_insert = pUsuario;
				
			RETURN  cCodRet, cMensaje;
        END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
		INTO cCodRet;
		
        IF cCodRet <> '00000' THEN
			
			UPDATE {+INDEX (bdicnweb:sw_verificastatuscargaarchivocoppel idx_sw_verificastatuscargaarchivocoppel)} "informix".sw_verificastatuscargaarchivocoppel
			SET status = 'E', error = cCodRet,faltacaja = 0, cajafaltante = ''
			WHERE usuario_insert = pUsuario;
				
			RETURN cCodRet, cMensaje;
        END IF;
		
		FOREACH --VALIDACION CAJA GENERAL
                SELECT  {+INDEX (bdicnweb:sw_cargatmpdepositoscoppel idx_sw_cargatmpdepositoscoppel)}   
				DISTINCT (caja_general)
                INTO cCajaGeneral
                FROM bdicnweb:"informix".sw_cargatmpdepositoscoppel 

				SELECT COUNT(*) 
				INTO iTotReg 
				FROM bdisuc:"informix".ss_cajageneral 
				WHERE empresa = cEmpresa AND cod_proveedor = cCajaGeneral; 
				
				IF iTotReg = 0 THEN
					IF LENGTH(TRIM(cCajaFalta))=0 THEN 
						LET cCajaFalta =cCajaGeneral;
                        CONTINUE FOREACH;
					ELSE
						LET cCajaFalta = TRIM(cCajaFalta) ||','||cCajaGeneral;
                        CONTINUE FOREACH;
					END IF;
				END IF;
				
				SELECT COUNT(*) 
				INTO iTotReg
				FROM bdisuc:"informix".ss_proveedores 
				WHERE cod_proveedor = cCajaGeneral; 
				
				IF iTotReg = 0 THEN					
                    IF LENGTH(TRIM(cCajaFalta))=0 THEN 
						LET cCajaFalta =cCajaGeneral;
					ELSE
						LET cCajaFalta = TRIM(cCajaFalta) ||','||cCajaGeneral;
					END IF;
				END IF;
		
		END FOREACH;

		IF   cCajaFalta<>'' THEN 
			   
			LET iCajasFalta =1;
			FOR i = 1 TO LENGTH(TRIM(cCajaFalta)) 
			IF SUBSTR(TRIM(cCajaFalta), i, 1) = ',' THEN
				LET iCajasFalta = iCajasFalta +1;
			END IF;
			END FOR;
			 
			IF iCajasFalta = 1 THEN --FALTA 1 CAJA GENERAL 
			 
			UPDATE {+INDEX (bdicnweb:sw_verificastatuscargaarchivocoppel idx_sw_verificastatuscargaarchivocoppel)} "informix".sw_verificastatuscargaarchivocoppel
			SET status = 'E', error = cCodRet, faltacaja = iCajasFalta, cajafaltante = cCajaFalta
			WHERE usuario_insert = pUsuario;
	 
			END IF;
			
			IF iCajasFalta > 1 THEN --FALTA MAS DE UNA CAJA GENERAL 
			 
			UPDATE {+INDEX (bdicnweb:sw_verificastatuscargaarchivocoppel idx_sw_verificastatuscargaarchivocoppel)} "informix".sw_verificastatuscargaarchivocoppel
			SET status = 'E', error = cCodRet,faltacaja = iCajasFalta, cajafaltante = ''
			WHERE usuario_insert = pUsuario;
	 
			END IF;
		
			DELETE {+INDEX (bdicnweb:sw_cargatmpdepositoscoppel idx_sw_cargatmpdepositoscoppel)}   
			FROM bdicnweb:"informix".sw_cargatmpdepositoscoppel;
			
		ELSE 

        FOREACH
                SELECT {+INDEX (bdicnweb:sw_cargatmpdepositoscoppel idx_sw_cargatmpdepositoscoppel)}   
				fecha, comprobante, suc_coppel, nombre_suc, caja_general, plaza, imp_comprobante, imp_ficha, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, faltante, sobrante
                INTO dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante
                FROM bdicnweb:"informix".sw_cargatmpdepositoscoppel 
				
				LET cMensaje = '';
				
				SELECT {+INDEX (bdisuc:ss_temp_deposito_coppel idx_ss_temp_deposito_coppel)} COUNT(*) 
				INTO iTotReg
				FROM bdisuc:"informix".ss_temp_deposito_coppel 
				WHERE comprobante = cComprobante; 
				
				IF iTotReg > 0 THEN
					LET cMensaje = 'Deposito duplicado';
				END IF;
				
				SELECT {+INDEX (bdisuc:ss_bitacora_deposito_coppel idx_ss_bitacora_deposito_coppel)} COUNT(*) 
				INTO iTotReg
				FROM bdisuc:"informix".ss_bitacora_deposito_coppel 
				WHERE comprobante = cComprobante; 
				
				IF iTotReg > 0 THEN
					LET cMensaje = 'XXXXX Deposito duplicado en historicos';
				END IF;
				
				IF mFaltante > 0 THEN
					LET iCalculo = mFaltante / 100; 
					LET iCantidad4 = iCantidad4 + iCalculo;
					LET iResto = MOD(mFaltante,100);
					LET iCantidad7 = iCantidad7 + iResto;
				END IF;
				
				IF mSobrante > 0 THEN
					LET iCalculo = mSobrante / 100;
					LET iCantidad4 = iCantidad4 - iCalculo;
					LET iResto = MOD(mSobrante,100);
					LET iCantidad7 = iCantidad7 - iResto;
				END IF;
				
				-----TRAE EL VALOR DEL FOLIO
				SELECT valor
				INTO vnum
				FROM bdisuc:"informix".ss_param_cajagen
				WHERE codigo = '0005';

				----ACTUALIXA VALOR DEL FOLIO A + 1
				UPDATE bdisuc:"informix".ss_param_cajagen
				SET valor = valor + 1
				WHERE  codigo = '0005'; 
				
				LET iConsecutivo = LPAD(ROUND(vnum),8,"0");
				
				IF cMensaje = '' THEN
					LET cMensaje = '00000 Operacion Exitosa';
				END IF;
				
				INSERT INTO bdisuc:"informix".ss_temp_deposito_coppel(folio_oper, fecha, comprobante, suc_coppel, nombre_suc, caja_general, plaza, imp_comprobante, imp_ficha, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, faltante, sobrante, estatus) 
				VALUES(iConsecutivo, dFecha, cComprobante, cSucCoppel, cNombreSuc, cCajaGeneral, cPlaza, mImpComprobante, mImpFicha, iCantidad1, iCantidad2, iCantidad3, iCantidad4, iCantidad5, iCantidad6, iCantidad7, mFaltante, mSobrante, cMensaje);
				
        END FOREACH;
		
		DELETE {+INDEX (bdicnweb:sw_cargatmpdepositoscoppel idx_sw_cargatmpdepositoscoppel)}   
		FROM bdicnweb:"informix".sw_cargatmpdepositoscoppel;
		
		UPDATE {+INDEX (bdicnweb:sw_verificastatuscargaarchivocoppel idx_sw_verificastatuscargaarchivocoppel)} "informix".sw_verificastatuscargaarchivocoppel
		SET status = 'T', error = cCodRet,faltacaja = 0, cajafaltante = ''
		WHERE usuario_insert = pUsuario;
		
		END IF;
		
		RETURN cCodRet, '';
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA 10/09/2020',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: DEPOSITOS COPPEL',
'DESCRIPCION: SPL encargado de procesar el archivo cargado.',
'AUTOR: Daniel Reyes Guillen',
'FECHA 15/03/2022',
'DESCRIPCION: Se agrega validacion de caja general.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusprocesarchcoppel(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS faltacaja,
		CHAR(4) AS cajafaltante;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iFaltaCaja INTEGER;
	DEFINE cCajaFaltante CHAR(4);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iFaltaCaja = 0;
	LET cCajaFaltante ='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cErrorProceso,cError,iFaltaCaja,cCajaFaltante;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusprocesarchcoppel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError,iFaltaCaja,cCajaFaltante;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError,iFaltaCaja,cCajaFaltante;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT {+AVOID_FULL("informix".sw_verificastatuscargaarchivocoppel)} status,error_proceso,error,faltacaja,cajafaltante
		INTO cStatus, cErrorProceso, cError, iFaltaCaja, cCajaFaltante
		FROM "informix".sw_verificastatuscargaarchivocoppel WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',0,''; 
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError,iFaltaCaja,cCajaFaltante;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/09/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: DEPOSITOS COPPEL',
'DESCRIPCION: SPL encargado verificar el status del proceso de carga de archivo coppel.',
'AUTOR: Daniel Reyes Guillen',
'FECHA 15/03/2022',
'DESCRIPCION: Se agregan retornos de caja general.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargarchivodepositoscoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaCarga CHAR(100), pArchivoProcesar CHAR(100))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cCmd CHAR(2000);
	DEFINE cScriptCarga CHAR(600);
	DEFINE cRutaInformix CHAR(100);
	--DEFINE cNombreArchivoTmp CHAR(50);
	DEFINE ven_transacc SMALLINT;
	DEFINE bInTransaction BOOLEAN;
	DEFINE cCampos CHAR(1024);
	DEFINE cTablaDst CHAR(150);
	DEFINE cBaseDatos CHAR(50);
	DEFINE cUsrBin CHAR(15);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cCmd = '';
	LET cScriptCarga = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cCampos = '';
	LET cTablaDst = 'sw_cargatmpdepositoscoppel';
	LET cBaseDatos = 'bdicnweb';
	LET cUsrBin = '/usr/bin/';
	
	BEGIN		
	
		ON EXCEPTION SET iSqlErr, cIsamErr, cDescErr  
			IF iSqlErr <> 0 THEN
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668,-535,-255)			
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cargarchivodepositoscoppel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaCarga = '' OR  pArchivoProcesar = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		DELETE {+AVOID_FULL(bdicnweb:"informix".sw_cargatmpdepositoscoppel)} FROM bdicnweb:"informix".sw_cargatmpdepositoscoppel;
		DELETE {+AVOID_FULL(bdisuc:"informix".ss_temp_deposito_coppel)} FROM bdisuc:"informix".ss_temp_deposito_coppel;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;

		LET ven_transacc = 1;	
		
        LET pRutaCarga = TRIM(pRutaCarga) || '/';
		
		-- Se convierte el archivo de FORMATO UTF-8 a IBM-1252
		LET cCmd = "iconv -s -f UTF-8 -t IBM-1252 "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" > "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv';
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/mv "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv';
		SYSTEM TRIM(cCmd);
		
		-- Se eliminan caracteres de retorno de carro (DOS)
		LET cCmd = '/usr/bin/tr "\r" " " < '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||' > '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr';
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		-- Se eliminan caracteres de tabuladores
		LET cCmd = '/usr/bin/tr "\t" " " < '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||' > '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr';
		SYSTEM TRIM(cCmd);
		
		LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		LET cCampos = 'fecha,comprobante,suc_coppel,caja_general,plaza,imp_comprobante,imp_ficha,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,faltante,sobrante';
				
		LET cScriptCarga = TRIM(cUsrBin)||"echo "||'"'||"LOAD FROM "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" DELIMITER '|' INSERT INTO "||TRIM(cBaseDatos)||":"||TRIM(cTablaDst)||"(";
		LET cScriptCarga = TRIM(cScriptCarga)||TRIM(cCampos)||");"||'"'||" > "||TRIM(pRutaCarga)||TRIM("data.sql");
		SYSTEM TRIM(cScriptCarga);

		LET cCmd = TRIM(cRutaInformix)||'dbaccess bdicnweb < '||TRIM(pRutaCarga)||TRIM("data.sql");
		SYSTEM TRIM(cCmd);
		
		--COMMIT WORK;
		
		UPDATE STATISTICS MEDIUM FOR TABLE bdicnweb:"informix".sw_cargatmpdepositoscoppel;
		
		-- SE ELIMINA EL ARCHIVO SUBIDO
		LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
		SYSTEM TRIM(cCmd);
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 31/08/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Alta Baja de Bines',
'DESCRIPCION: SPL que inserta el archivo de Bines a BD para realizar la comparaciÃ³n de los mismos',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 31/08/2018',
'DESCRIPCION: Se amplia tamaÃ±o de parametro de entrada pNombreArchivo de CHAR(35) a CHAR(100)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultaenviospagodinya(pUsuario CHAR(8), pIdFuncion CHAR(10), pConvenio CHAR(3),
					pImporte1 CHAR(16), pImporte2 CHAR (16), pSucursalOrigen CHAR(4), pNombre1Remitente CHAR(26),
					pNombre2Remitente CHAR(26), pApellido1Remitente CHAR(26), pApellido2Remitente CHAR(26), pFechaEnvio1 DATE,
					pFechaEnvio2 DATE, pNombre1Beneficiario CHAR(26), pNombre2Beneneficiario CHAR(26), 
					pApellido1Beneneficiario CHAR(26), pApellido2Beneneficiario CHAR(26), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			CHAR(12) AS cNoControl,
			DATE AS dFechaEnvio,
			CHAR(4) AS cSucursalOrigen,
			CHAR(26) AS cNombre1Remitente,
			CHAR(26) AS cNombre2Remitente,
			CHAR(26) AS cApellido1Remitente,
			CHAR(26) AS cApellido2Remitente,
			MONEY(16,2) AS mImporteEnviado,
			CHAR(20) AS cStatus;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	-- VARIABLES DEL SP PRODUCTIVO
	DEFINE cNoControl CHAR(12);
	DEFINE dFechaEnvio DATE;
	DEFINE cSucursalOrigen CHAR(4);
	DEFINE cNombre1Remitente CHAR(26);
	DEFINE cNombre2Remitente CHAR(26);
	DEFINE cApellido1Remitente CHAR(26);
	DEFINE cApellido2Remitente CHAR(26);
	DEFINE mImporteEnviado MONEY (16,2);
	DEFINE cStatus CHAR(20);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	-- VARIABLES DEL SP PRODUCTIVO
	LET cNoControl = '';
	LET dFechaEnvio = NULL;
	LET cSucursalOrigen = '';
	LET cNombre1Remitente = '';
	LET cNombre2Remitente = '';
	LET cApellido1Remitente = '';
	LET cApellido2Remitente = '';
	LET mImporteEnviado = NULL;
	LET cStatus = '';

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, 
				cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaenviospagodinya.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, 
				cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, 
				cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, 
				cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdisac:sp_dinya_obtenerenviospagos(pConvenio, pImporte1, pImporte2, pSucursalOrigen,
													pNombre1Remitente, pNombre2Remitente, pApellido1Remitente, pApellido2Remitente,
													pFechaEnvio1, pFechaEnvio2,
													pNombre1Beneficiario, pNombre2Beneneficiario, pApellido1Beneneficiario, pApellido2Beneneficiario)
			INTO cCodRetSp, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP PRODUCTIVO sp_dinya_obtenerenviospagos';
			END IF;
			
			IF iRegistros >= pRegistros THEN
				IF iRecuperacion < pRecuperacion THEN
					RETURN cCodRet, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, 
						cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus WITH RESUME;
					LET iNoRegistros = iNoRegistros + 1;
					LET iRecuperacion = iRecuperacion + 1;
				END IF;
			END IF;
			LET iRegistros = iRegistros + 1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, 
				cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNoControl, dFechaEnvio, cSucursalOrigen, cNombre1Remitente, 
				cNombre2Remitente, cApellido1Remitente, cApellido2Remitente, mImporteEnviado, cStatus;
		END IF;
		
	END;
				
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/02/2014',
'DESCRIPCION: Consulta los envios de ordenes de pago',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacatalogocausastatusmc_oro(pUsuario CHAR(8), pIdFuncion CHAR(10),pStatus CHAR(2))
        RETURNING CHAR(5) AS codret,
                        CHAR(2) AS status,
                        CHAR(40) AS descripcion_status,
                        CHAR(3) AS causa,
                        CHAR(100) AS descripcion_causa,
						CHAR(100) AS justificacion;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(5);
        DEFINE cStatus CHAR(2);
        DEFINE cDescripcionStatus CHAR(40);
        DEFINE cCausa CHAR(3);
        DEFINE cDescripcionCausa CHAR(100);
		DEFINE cJustificacion CHAR(100);
		DEFINE iNoRegitros INTEGER;
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET cStatus = '';
        LET cDescripcionStatus = '';
        LET cCausa = '';
        LET cDescripcionCausa = '';
		LET cJustificacion = '';
		LET iNoRegitros = 0;
        
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
                END EXCEPTION;

                -- SET DEBUG FILE TO '/tmp/mfinis/sp_consultacatalogocausastatusmc_oro.out';
                -- TRACE ON;
				
				IF pUsuario ='' OR pIdFuncion='' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
				END IF;
				
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3; 
				
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
				END IF;
 
				FOREACH SELECT codret, status, descripcion_status, causa, descripcion_causa, justificacion
						INTO cCodRetSp, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion
						FROM TABLE(PROCEDURE bdicred:'informix'.sp_consultarcausastatussoc(TRIM(pStatus)))
							AS consultarcausastatus_tmp(codret, status, descripcion_status, causa, descripcion_causa, justificacion)
						WHERE status IN ('AP','AT')
					IF cCodRetSp::SMALLINT = 1 THEN
						LET cCodRet = '00017';
						RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
					ELSE
						RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion WITH RESUME;
						LET iNoRegitros = iNoRegitros + 1;
					END IF;
				END FOREACH;
				
				IF iNoRegitros = 0 THEN
					LET cCodRet = '00017';
					RETURN cCodRet, cStatus, cDescripcionStatus, cCausa, cDescripcionCausa, cJustificacion;
				END IF;
				
        END;
        
END PROCEDURE
DOCUMENT 
"AUTOR: Daniel Reyes Guillen",
"FECHA: 01/03/2022",
"DESCRIPCION: SP que ejecuta el sp productivo sp_consultarcausastatussoc para recuperar los registros con status AP y AT",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_consdesbloqueomasivocre_exp(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pRegistros INT, pRecuperacion INT)
        RETURNING CHAR(5) AS codret,
                        INT AS id,
                        CHAR(20) AS no_credito,
                        CHAR(20) AS no_cliente,
                        CHAR(15) AS resultado,
                        CHAR(6) AS codretsp,
                        CHAR(80) AS motivo_rechazo,
                        MONEY(14,2) AS saldo,
                        CHAR(107) AS nombre_cliente,
                        DATE AS fecha_desbloqueo,
                        CHAR(8) AS empleado,
                        CHAR(45) AS nombre_empleado,
                        CHAR(1) AS status,
						CHAR(150) AS area_solicita,
						CHAR(150) AS justificacion,
						DECIMAL(18,2) AS saldo_capital;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iIdRegistro INTEGER;
        DEFINE cNoCuenta CHAR(20);
        DEFINE cNoCliente CHAR(20);
        DEFINE cResultado CHAR(15);
        DEFINE cCodRetSp CHAR(6);
        DEFINE cMotivoRechazo CHAR(80);
        DEFINE mSaldo MONEY(14,2);
        DEFINE cNombreCliente CHAR(107);
        DEFINE dFechaDesbloqueo DATE;
        DEFINE cEmpleado CHAR(8);
        DEFINE cNombreEmpleado CHAR(45);
        DEFINE cStatusRegistro CHAR(1);
        DEFINE iExiste INTEGER;
        DEFINE iNoRegistros INTEGER;
		DEFINE cAreaSolicitante CHAR(150);
		DEFINE cJustificacion CHAR(150);
		DEFINE dSaldoCapital DECIMAL(18,2);
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iIdRegistro = 0;
        LET cNoCuenta = '';
        LET cNoCliente = '';
        LET cResultado = '';
        LET cCodRetSp = '';
        LET cMotivoRechazo = '';
        LET mSaldo = NULL;
        LET cNombreCliente = '';
        LET dFechaDesbloqueo = NULL;
        LET cEmpleado = '';
        LET cNombreEmpleado = '';
        LET cStatusRegistro = '';
        LET iExiste = 0;
        LET iNoRegistros = 0;
		LET cAreaSolicitante = '';
		LET cJustificacion = '';
		LET dSaldoCapital = 0;
		
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consdesbloqueomasivocre.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
                IF pRegistros < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
                -- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                SELECT COUNT(id_registro)
                INTO iExiste
                FROM 
                        (SELECT id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre
                        WHERE lote = pLote
                        UNION
                        SELECT id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre_hist
                        WHERE lote = pLote);
                
                IF iExiste = 0 THEN
                        LET cCodRet = '00200';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
                -- ACTUALIZACIÃN DEL ESTATUS POR VALIDACION
                UPDATE bdicnweb:sw_tr_cargamasiva_desbloqueocre
                SET resultado = 'NO APLICADO',
                        motivo_rechazo = 'ERROR POR VALIDACION'
                WHERE lote = pLote AND status = 'E';
                
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, fecha_desbloqueo, usuario, status,
																	area_solicita, justificacion, saldo_capital
                        INTO iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, dFechaDesbloqueo, cEmpleado, cStatusRegistro,
							cAreaSolicitante, cJustificacion, dSaldoCapital
                        FROM
                                (SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, fecha_desbloqueo, usuario, usuario, status,
										area_solicita, justificacion, saldo_capital
                                FROM bdicnweb:sw_tr_cargamasiva_desbloqueocre
                                WHERE usuario = pUsuario
                                        AND lote = pLote
                                UNION
                                SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, fecha_desbloqueo, usuario, usuario, status,
										area_solicita, justificacion, saldo_capital
                                FROM bdicnweb:sw_tr_cargamasiva_desbloqueocre_hist
                                WHERE usuario = pUsuario
                                        AND lote = pLote)
                        ORDER BY id_registro
                        
                        
                        IF cNoCliente IS NULL OR cNoCliente = '' THEN
                                SELECT NVL(a.numcte, '')
                                INTO cNoCliente
                                FROM bdicred:sd_maecred a
                                WHERE num_credito = cNoCuenta;
                                
                                UPDATE bdicnweb:'informix'.sw_tr_cargamasiva_desbloqueocre
                                SET numcte = cNoCliente
                                WHERE id_registro = iIdRegistro;
                                
                                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                                        UPDATE bdicnweb:'informix'.sw_tr_cargamasiva_desbloqueocre_hist
                                        SET numcte = cNoCliente
                                        WHERE id_registro = iIdRegistro;
                                END IF;
                        END IF;
                        
                        SELECT NVL(TRIM(TRIM(TRIM(b.nombre1)||' '||TRIM(b.nombre2))||' '||TRIM(TRIM(b.apell_paterno)||' '||TRIM(b.apell_materno))), '') as nombre
                        INTO cNombreCliente
                        FROM bdinteg:si_cliente b
                        WHERE numcte = cNoCliente;
                        
                        SELECT NVL(nombre, '')
                        INTO cNombreEmpleado
                        FROM bdinteg:si_ejecut
                        WHERE ejecutivo = cEmpleado;
                        
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, UPPER(cMotivoRechazo), mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital WITH RESUME;
                                   
                        LET iNoRegistros = iNoRegistros + 1;
                        
                END FOREACH;
                
                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                ELIF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
        END;
                        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/07/2014',
'DESCRIPCION: Consulta de los registros de un lote masivo de cuentas a ser bloqueadas',
'AUTOR: Oscar Flores Conde',
'FECHA: 12/02/2015',
'DESCRIPCION: Se agrega a la salida la justificaciÃ³n, area que solicita y el saldo capital',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecaccompingreso_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
		
	DEFINE cDescripcion CHAR(80);
	DEFINE cCod_docto CHAR(4);
	DEFINE cDescripcion_grupo CHAR(50);	
	DEFINE iNumero_doctos INTEGER;
	DEFINE dPorcentaje_total_grupos DECIMAL(5,2);
	DEFINE iValidos_grupo INTEGER;
	DEFINE dPorcentaje_validos_grupo DECIMAL(5,2);
	DEFINE iInvalidos_grupo INTEGER;
	DEFINE dPorcentaje_invalidos_grupo DECIMAL(5,2);
	DEFINE dPorcentaje_final_grupo DECIMAL(5,2);
	DEFINE iIndice_grupo INTEGER;	
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	LET cDescripcion = '';
	LET cCod_docto = '';
	LET cDescripcion_grupo = '';	
	LET iNumero_doctos = 0;
	LET dPorcentaje_total_grupos = 0.00;
	LET iValidos_grupo = 0;
	LET dPorcentaje_validos_grupo = 0.00;
	LET iInvalidos_grupo = 0;
	LET dPorcentaje_invalidos_grupo = 0.00;
	LET dPorcentaje_final_grupo = 0.00;
	LET iIndice_grupo = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".status_rep_compingreso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecaccompingreso_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_rep_compingreso WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".status_rep_compingreso(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			UPDATE "informix".status_rep_compingreso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".status_rep_compingreso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		
		
		DELETE FROM "informix".sw_mc_rep_cac_compingreso WHERE usuario = pUsuario;
		
		FOREACH
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_reporte_cac_compingreso(pFechaInicio,pFechaFin)
			INTO cCodRetSp, cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÓN DEL SP bdisolic:sp_reporte_cac_compingreso';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003'; 
				UPDATE "informix".status_rep_compingreso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00154'; 
				UPDATE "informix".status_rep_compingreso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
				UPDATE "informix".status_rep_compingreso
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet,iNumRegistros;
			END IF;
			
			INSERT INTO "informix".sw_mc_rep_cac_compingreso VALUES(cDescripcion, cCod_docto, cDescripcion_grupo, iNumero_doctos, dPorcentaje_total_grupos, iValidos_grupo, dPorcentaje_validos_grupo, iInvalidos_grupo, dPorcentaje_invalidos_grupo, dPorcentaje_final_grupo, iIndice_grupo, pUsuario);
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iNumRegistros FROM "informix".sw_mc_rep_cac_compingreso WHERE usuario = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÓN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			UPDATE "informix".status_rep_compingreso
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		UPDATE "informix".status_rep_compingreso
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;  
		
		RETURN cCodRet,iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/08/2018',
'MODULO: CRÉDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'Descripcion: SPL encargado de consultar el número total de registros del reporte comprobante de ingresos de solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_altadministradorespmempnet(pUsuario CHAR(8), pIdFuncion CHAR(10), 
				pNumCliente CHAR(9), pCodIden CHAR(3), pNumIden CHAR(30), 
				pApellPat CHAR(30), pApellMat CHAR(30), pNombre1 CHAR(30), pNombre2 CHAR(30), pRepLegal CHAR(1), pBandera CHAR(1))
					
		RETURNING CHAR(5) AS codret, 					
			CHAR(20) AS numero_cliente,           
            CHAR(12) AS folio_token;
			
		DEFINE cCodRet 				CHAR(5);
        DEFINE cCodRetSp 			CHAR(6);
		DEFINE iCodRetSp 			INTEGER;
        DEFINE iSqlErr 				INTEGER;
		DEFINE cNumCliente  		CHAR(20); 
		DEFINE cFolioToken  		CHAR(12); 
		DEFINE MensajeRet			CHAR(50);
		DEFINE iRecuperacion	    INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cNumCliente = ''; 	
		LET cFolioToken = ''; 
		LET MensajeRet = '';
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,cNumCliente,cFolioToken; 
			END EXCEPTION;
            
--            SET DEBUG FILE TO '/tmp/mfinis/sp_altadministradorespmempnet.out';
--            TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cNumCliente,cFolioToken;
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,cNumCliente,cFolioToken;
			END IF;				
			
			IF pBandera = '1' THEN
				INSERT INTO bdicnweb:"informix".sw_regbitacora_empresanet (usuario_insert, num_cliente, operacion, fecha) 
				VALUES (pUsuario, pNumCliente, 'ALTA ADMO.', CURRENT);
				FOREACH
					EXECUTE PROCEDURE bdibei:"informix".sp_administradorespm(pNumCliente,'',pCodIden,pNumIden,pApellPat,pApellMat,pNombre1,pNombre2,pRepLegal)
					INTO cCodRetSp,MensajeRet,cNumCliente,cFolioToken
					
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdibei:sp_administradorespm';
					ELIF cCodRetSp::INTEGER = 1 THEN
						LET cCodRet = '00003'; 
						RETURN cCodRet,cNumCliente,cFolioToken; 
					ELSE
						LET iRecuperacion = iRecuperacion + 1;					 
						RETURN cCodRet,cNumCliente,cFolioToken WITH RESUME;
					END IF;
					
				END FOREACH;
			ELSE 
				INSERT INTO bdicnweb:"informix".sw_regbitacora_empresanet (usuario_insert, num_cliente, operacion, fecha) 
				VALUES (pUsuario, pNumCliente, 'MODIFICACION ADMO.', CURRENT);
				FOREACH							
					EXECUTE PROCEDURE bdibei:"informix".sp_mod_administradorespm(pNumCliente,pCodIden,pNumIden,pApellPat,pApellMat,pNombre1,pNombre2,pRepLegal)
					INTO cCodRetSp,MensajeRet,cNumCliente,cFolioToken
				
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdibei:sp_administradorespm';
					ELIF cCodRetSp::INTEGER = 1 THEN
						LET cCodRet = '00003'; 
						RETURN cCodRet,cNumCliente,cFolioToken; 
					ELSE
						LET iRecuperacion = iRecuperacion + 1;					 
						RETURN cCodRet,cNumCliente,cFolioToken WITH RESUME;
					END IF;
				END FOREACH;
			
			END IF;
				
			IF iRecuperacion = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet,cNumCliente,cFolioToken;
			END IF;	

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/04/2015',
'DESCRIPCION: SPL que agrega los administradores a la tabla bdibei:bei_servicio.',
'Se ejecuta una o dos veces por empresa, segÃºn el nÃºmero de administradores.',
'FUNCIONALIDAD: Alta del Servicio de Empresa Net', 
'MODULO: Clientes',
'BD: bdicnweb',
'DESCRIPCION: Se modifica SP para realizar el llamado al nuevo SP encargado de realizar la actualizacion de datos, ademÃ¡s de',
'realizar la inserciÃ³n a bitacora.',
'AUTOR:  Veronica Sanchez Tlacomulco',   
'FECHA DE CREACION: 08/07/2022';

CREATE PROCEDURE "informix".sp_consultainfctepmsempnet(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20))
					
		RETURNING CHAR(5) AS codret, 					
			CHAR(60) AS cRazonSocial,
			CHAR(2)  AS cTipoPersona,
			CHAR(12) AS cFolioActiva1,
			CHAR(12) AS cFolioActiva2,
			INTEGER  AS iContrato1,
			INTEGER  AS iContrato2,
			CHAR(30) AS cCodigoIdent1,
			CHAR(30) AS cCodigoIdent2,
			CHAR(50) AS cDescIdent1,
			CHAR(50) AS cDescIdent2,
			CHAR(2)  AS cNoIdent1,
			CHAR(2)  AS cNoIdent2,
			SMALLINT AS iNoTokens,
			SMALLINT AS iNoAdmins,
			CHAR(50) AS cUsAut1Nombre1,
			CHAR(50) AS cUsAut1Nombre2,
			CHAR(50) AS cUsAut1ApPaterno,
			CHAR(50) AS cUsAut1ApMaterno,
			CHAR(50) AS cUsAut2Nombre1,
			CHAR(50) AS cUsAut2Nombre2,
			CHAR(50) AS cUsAut2ApPaterno,
			CHAR(50) AS cUsAut2ApMaterno,
			INTEGER  AS iFolioEmpresaNet;
			
		DEFINE cCodRet 				CHAR(5);
        DEFINE cCodRetSp 			CHAR(6);
		DEFINE iCodRetSp 			INTEGER;
        DEFINE iSqlErr 				INTEGER;
		DEFINE cRazonSocial 		CHAR(60); 
		DEFINE cTipoPersona 		CHAR(2); 
		DEFINE cFolioActiva1 		CHAR(12); 
		DEFINE cFolioActiva2 		CHAR(12); 
		DEFINE iContrato1 			INTEGER; 
		DEFINE iContrato2 			INTEGER; 
		DEFINE cCodigoIdent1 		CHAR(30); 
		DEFINE cCodigoIdent2 		CHAR(30); 
		DEFINE cDescIdent1 			CHAR(50); 
		DEFINE cDescIdent2 			CHAR(50); 
		DEFINE cNoIdent1 			CHAR(2); 
		DEFINE cNoIdent2 			CHAR(2); 
		DEFINE iNoTokens 			SMALLINT; 
		DEFINE iNoAdmins 			SMALLINT; 
		DEFINE cUsAut1Nombre1 		CHAR(50); 
		DEFINE cUsAut1Nombre2 		CHAR(50); 
		DEFINE cUsAut1ApPaterno 	CHAR(50); 
		DEFINE cUsAut1ApMaterno 	CHAR(50); 
		DEFINE cUsAut2Nombre1 		CHAR(50); 
		DEFINE cUsAut2Nombre2 		CHAR(50); 
		DEFINE cUsAut2ApPaterno 	CHAR(50); 
		DEFINE cUsAut2ApMaterno 	CHAR(50); 
		DEFINE iFolioEmpresaNet 	INTEGER; 
		DEFINE iRecuperacion	    INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cRazonSocial = ''; 	
		LET cTipoPersona = ''; 	
		LET cFolioActiva1 = ''; 	
		LET cFolioActiva2 = ''; 	
		LET iContrato1 = 0; 		
		LET iContrato2 = 0; 		
		LET cCodigoIdent1 = ''; 	
		LET cCodigoIdent2 = ''; 	
		LET cDescIdent1 = ''; 		
		LET cDescIdent2 = ''; 		
		LET cNoIdent1 = ''; 		
		LET cNoIdent2 = ''; 		
		LET iNoTokens = 0; 		
		LET iNoAdmins = 0; 		
		LET cUsAut1Nombre1 = ''; 	
		LET cUsAut1Nombre2 = ''; 	
		LET cUsAut1ApPaterno = ''; 
		LET cUsAut1ApMaterno = ''; 
		LET cUsAut2Nombre1 = ''; 	
		LET cUsAut2Nombre2 = ''; 	
		LET cUsAut2ApPaterno = ''; 
		LET cUsAut2ApMaterno = ''; 
		LET iFolioEmpresaNet = 0;
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet; 
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_consultainfctepmsempnet.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet;
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet;
			END IF;
				
			FOREACH
				EXECUTE PROCEDURE bdibei:"informix".sp_consultarctepmempresanet_clon(pNumCliente)
				INTO cCodRetSp,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					 cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					 cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					 cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					 iFolioEmpresaNet
				
				IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdibei:sp_consultarctepmempresanet_clon';
				ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00003'; 
					RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet;  
				ELIF cCodRetSp::INTEGER = 2 THEN
					LET cCodRet = '00017'; 
					RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet;
				ELIF cCodRetSp::INTEGER = 3 THEN
					LET cCodRet = '00473'; --EL CLIENTE NO ES UNA PERSONA MORAL
					RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet;  
				ELIF cCodRetSp::INTEGER = 4 OR cCodRetSp::INTEGER = 6 THEN
					LET cCodRet = '00017'; 
					RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet;
				ELIF cCodRetSp::INTEGER = 5 THEN
					LET cCodRet = '00474'; --NÃMERO INVALIDO DE ADMINISTRADORES 
					RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet;  
				/*ELIF cCodRetSp::INTEGER = 7 THEN
					LET cCodRet = '00275'; 
					RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet;*/
				ELSE
					LET iRecuperacion = iRecuperacion + 1;					 
					RETURN cCodRet,UPPER(cRazonSocial),UPPER(cTipoPersona),UPPER(cFolioActiva1),UPPER(cFolioActiva2),iContrato1,iContrato2,
					   UPPER(cCodigoIdent1),UPPER(cCodigoIdent2),UPPER(cDescIdent1),UPPER(cDescIdent2),UPPER(cNoIdent1),UPPER(cNoIdent2),iNoTokens,iNoAdmins,
					   UPPER(cUsAut1Nombre1),UPPER(cUsAut1Nombre2),UPPER(cUsAut1ApPaterno),UPPER(cUsAut1ApMaterno),
					   UPPER(cUsAut2Nombre1),UPPER(cUsAut2Nombre2),UPPER(cUsAut2ApPaterno),UPPER(cUsAut2ApMaterno),
					   iFolioEmpresaNet WITH RESUME;
				END IF;
			END FOREACH;
				
			IF iRecuperacion = 0 THEN
				LET cCodRet = '00017'; 
				RETURN cCodRet,cRazonSocial,cTipoPersona,cFolioActiva1,cFolioActiva2,iContrato1,iContrato2,
					   cCodigoIdent1,cCodigoIdent2,cDescIdent1,cDescIdent2,cNoIdent1,cNoIdent2,iNoTokens,iNoAdmins,
					   cUsAut1Nombre1,cUsAut1Nombre2,cUsAut1ApPaterno,cUsAut1ApMaterno,
					   cUsAut2Nombre1,cUsAut2Nombre2,cUsAut2ApPaterno,cUsAut2ApMaterno,
					   iFolioEmpresaNet;
			END IF;	

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 23/04/2015',
'DESCRIPCION: SPL que consulta los datos del cliente que tiene activo el servicio de EmpresaNet.',
'FUNCIONALIDAD: Alta del Servicio de Empresa Net', 
'MODULO: Clientes',
'BD: bdicnweb',
'DESCRIPCION: Se modifica SP para ejecutar nuevo procedimiento almacenado',
'AUTOR:  Veronica Sanchez Tlacomulco',   
'FECHA DE CREACION: 08/07/2022';

CREATE PROCEDURE "informix".sp_altaservicioempnet(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pCantTokens SMALLINT, pBandera CHAR(1))
					
		RETURNING CHAR(5) AS codret;
			
		DEFINE cCodRet 				CHAR(5);
        DEFINE cCodRetSp 			CHAR(6);
		DEFINE iCodRetSp 			INTEGER;
        DEFINE iSqlErr 				INTEGER;
		DEFINE MensajeRet			CHAR(100);
		DEFINE iRecuperacion	    INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET MensajeRet = '';
		LET iRecuperacion = 0;
		

		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet; 
			END EXCEPTION;
            
--            SET DEBUG FILE TO '/tmp/mfinis/sp_altaservicioempnet.out';
--            TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pCantTokens = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet;
            END IF;
			
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;
			
			IF pBandera = '1' THEN
				INSERT INTO bdicnweb:"informix".sw_regbitacora_empresanet (usuario_insert, num_cliente, operacion, fecha) 
				VALUES (pUsuario, pNumCliente, 'ALTA SERV. EMP.', CURRENT);
				FOREACH
					EXECUTE PROCEDURE bdibei:"informix".sp_senet_altaservicioempresanet(pNumCliente,'30',pUsuario,pCantTokens,'5001')
					INTO cCodRetSp,MensajeRet
					
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdibei:sp_senet_altaservicioempresanet';
					ELIF cCodRetSp::INTEGER = 1 THEN
						LET cCodRet = '00003'; 
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 2 THEN
						LET cCodRet = '00475'; --EL TOTAL DE DISPOSITIVOS DE SEGURIDAD SOLICITADOS NO ESTÃ EN EL RANGO PERMITIDO
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 3 THEN
						LET cCodRet = '00476'; --EL ESTATUS DEL SERVICIO NO ES VALIDO PARA EL SERVICIO
						RETURN cCodRet;
					END IF;
				END FOREACH;
			ELSE	
				INSERT INTO bdicnweb:"informix".sw_regbitacora_empresanet (usuario_insert, num_cliente, operacion, fecha) 
				VALUES (pUsuario, pNumCliente, 'MODIFICACION SERV.', CURRENT);
				FOREACH
					EXECUTE PROCEDURE bdibei:"informix".sp_mod_senet_altaservicioempresanet(pNumCliente, pUsuario, pCantTokens)
					INTO cCodRetSp
					
					IF cCodRetSp::INTEGER < 0 THEN
						RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdibei:sp_senet_altaservicioempresanet';
					ELIF cCodRetSp::INTEGER = 1 THEN
						LET cCodRet = '00003'; 
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 2 THEN
						LET cCodRet = '00475'; --EL TOTAL DE DISPOSITIVOS DE SEGURIDAD SOLICITADOS NO ESTÃ EN EL RANGO PERMITIDO
						RETURN cCodRet;
					ELIF cCodRetSp::INTEGER = 3 THEN
						LET cCodRet = '00476'; --EL ESTATUS DEL SERVICIO NO ES VALIDO PARA EL SERVICIO
						RETURN cCodRet;
					END IF;
				END FOREACH;
			END IF;
				
			RETURN cCodRet;	

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/04/2015',
'DESCRIPCION: SPL que realiza el guardado del servicio de empresa net en la tabla bdibei:bei_contratacion.',
'FUNCIONALIDAD: Alta del Servicio de Empresa Net', 
'MODULO: Clientes',
'BD: bdicnweb',
'DESCRIPCION: Se modifica SP para realizar el llamado al nuevo SP encargado de realizar la actualizacion de datos, ademÃ¡s de',
'realizar la inserciÃ³n a bitacora.',
'AUTOR:  Veronica Sanchez Tlacomulco',   
'FECHA DE CREACION: 08/07/2022';

CREATE PROCEDURE "informix".sp_verificastatusprocesrepantad(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		CHAR(100) AS rutaifx;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cRutaIfx CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cRutaIfx ='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cErrorProceso,cError,cRutaIfx;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusprocesrepantad.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError,cRutaIfx;
		END IF;		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError,cRutaIfx;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status, error_proceso, error, ruta_ifx
		INTO cStatus, cErrorProceso, cError, cRutaIfx
		FROM "informix".sw_verificastatusrepantad WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN		
			RETURN cCodRet,'I','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError,cRutaIfx;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 10/06/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE ESPECIAL ANTAD',
'DESCRIPCION: SPL encargado verificar el status del proceso';

CREATE PROCEDURE "informix".sp_ope_generareporteespantad(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCmd1 CHAR(3500);
	DEFINE cSql CHAR(3500);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreReporte CHAR(100);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	--LET cRutaInformix = '/informix/bin/';--Desarollo
	LET cRutaInformix = '/ifxsif01/bin/';	LET cRutaGral = '';
	LET cNombreReporte = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET iTotal = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			UPDATE "informix".sw_verificastatusrepantad
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_generareporteespantad.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN	
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_verificastatusrepantad WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".sw_verificastatusrepantad(usuario_insert,status,error_proceso,error,ruta_ifx) VALUES(pUsuario,'I','',cCodRet, '');
		
		
		-- SE ASIGNAN VALORES PARA LA GENERACION DEL REPORTE
		LET cNombreReporte = 'REPORTE_ANTAD_CON_AUTORIZACION_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y_%H%M%S')||'.csv';

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DELETE FROM bdicnweb:"informix".sw_consdetallereportesolsupmc WHERE usuario_insert = pUsuario;
		
		
		SELECT COUNT(*)
		INTO iTotal	
		FROM bdisac:informix.sac_movimientoshistorial AS A 
		INNER JOIN bdisac:informix.sac_convenios AS B ON B.numcategoria = A.numcategoria AND B.numconvenio = A.numconvenio 
		INNER JOIN bdisac:informix.sac_msw_respuesta AS C ON C.folio_suc = A.folio_suc 
		--WHERE A.numconvenio IN (SELECT numconvenio FROM bdisac:informix.sac_convenios WHERE nomconvenio LIKE '%ANTAD%' AND statusconvenio='A')
		WHERE trim(a.numcategoria) || trim(A.numconvenio) IN (SELECT trim(numcategoria) || trim(numconvenio) FROM bdisac:informix.sac_convenios WHERE nomconvenio LIKE '%ANTAD%')
		AND A.status_cancelado <> 'S' 
		AND A.flag_confirmacion_central = '1' 
		AND A.flag_confirmacion_sucursal = '1' 
		AND A.fecha_pago >= pFechaInicio AND A.fecha_pago <= pFechaFin;
		
		IF iTotal = 0 THEN
			LET cCodRet = '00017';
			
			UPDATE "informix".sw_verificastatusrepantad
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			RETURN cCodRet;
		END IF;
		
		LET cCmd1 ="";
		LET cCmd1 ="SELECT 'SISTEMA DE ADMINISTRACION DE CONVENIOS',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT 'DETALLE DE COBRANZA POR OPERACION - CONCILIACION DE PAGOS DE SERVICIOS REFERENCIADOS',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT 'REPORTE DE PAGOS ANTAD',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL  SELECT 'Periodo del : " || TO_CHAR( pFechaInicio, "%d-%m-%Y") || "', 'Al : " || TO_CHAR( pFechaFin, "%d-%m-%Y") || "',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ' FROM systables WHERE tabid = 1 UNION ALL";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'SUCURSAL','PAGOS','CONVENIO','IMPORTE SUCURSAL','COMISION CONVENIO','IVA COMISION CONVENIO','COMISION CLIENTE','IVA COMISION CLIENTE','STATUS SUCURSAL','STATUS CENTRAL','FOLIO SUC.','IMPORTE','AUTORIZACION' FROM systables WHERE tabid = 1";
		LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT ''''|| CAST(A.id_sucursal AS CHAR(50)), '1', CAST(B.nomconvenio AS CHAR(100)), CAST(A.importe_pago AS CHAR(50)), CAST(A.importe_comision_convenio AS CHAR(50)), CAST(A.iva_comision_convenio AS CHAR(50)), CAST(A.importe_comision_cte AS CHAR(50)), CAST(A.iva_comision_cte AS CHAR(50)), CAST(A.flag_confirmacion_sucursal AS CHAR(50)), CAST(A.flag_confirmacion_central AS CHAR(50)), ''''|| CAST(A.folio_suc AS CHAR(50)), CAST(A.importe_pago AS CHAR(50)), ''''||CAST(C.campo8 AS CHAR(50))";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdisac:""informix"".sac_movimientoshistorial AS A";
		LET cCmd1 =""||TRIM(cCmd1)||" INNER JOIN bdisac:""informix"".sac_convenios AS B ON B.numcategoria = A.numcategoria AND B.numconvenio = A.numconvenio";
		LET cCmd1 =""||TRIM(cCmd1)||" INNER JOIN bdisac:""informix"".sac_msw_respuesta AS C ON C.folio_suc = A.folio_suc";
		--LET cCmd1 =""||TRIM(cCmd1)||" WHERE A.numconvenio IN (SELECT numconvenio FROM bdisac:""informix"".sac_convenios WHERE nomconvenio LIKE '%ANTAD%' AND statusconvenio='A') ";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE trim(a.numcategoria) || trim(A.numconvenio) IN (SELECT trim(numcategoria) || trim(numconvenio) FROM bdisac:informix.sac_convenios WHERE nomconvenio LIKE '%ANTAD%') ";
		LET cCmd1 =""||TRIM(cCmd1)||" AND status_cancelado <> 'S' ";
		LET cCmd1 =""||TRIM(cCmd1)||" AND flag_confirmacion_central = '1' ";
		LET cCmd1 =""||TRIM(cCmd1)||" AND flag_confirmacion_sucursal = '1' ";
		LET cCmd1 =""||TRIM(cCmd1)||" AND A.fecha_pago >= '"|| pFechaInicio ||"' AND A.fecha_pago <= '"|| pFechaFin ||"'";	
		LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY A.id_sucursal ASC) AS TB";
		
		--SET ISOLATION TO DIRTY READ;
		--SET LOCK MODE TO WAIT 3;
			
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreReporte);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '','' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		UPDATE "informix".sw_verificastatusrepantad
		SET status = 'T', error_proceso = 'N', ruta_ifx = cNombreReporte WHERE usuario_insert = pUsuario;  
		
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 10/06/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE ESPECIAL ANTAD',
'DESCRIPCION: SPL encargado generar el Reporte Especial Antad';

CREATE PROCEDURE "informix".sp_consulta_usuario_movil(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecutivo CHAR(8), pImei CHAR(60))
	RETURNING CHAR(5) AS codret,
		  CHAR(20) AS cPassword,         
		  CHAR(60) AS cImei,         
		  CHAR(1) AS cActivo,       
		  CHAR(60) AS cNombre,       
		  CHAR(8) AS cCentro_costos,
		  CHAR(10) AS cNo_telefono,  
		  CHAR(20) AS cGenerico1,    
		  CHAR(30) AS cGenerico2,    
		  CHAR(40) AS cGenerico3,    
		  CHAR(4)  AS cSucursal,         
		  CHAR(40) AS cNombreSuc,        
		  SMALLINT AS perfil,
		  CHAR(20) AS deviceId;
            
    DEFINE cCodRet 			CHAR(5);
    DEFINE iSqlErr 			INTEGER;
    DEFINE iCodRetSp 		INTEGER;
    DEFINE iNoRegistros 	INTEGER;
    DEFINE cPassword        CHAR(20);
    DEFINE cImei          	CHAR(60);
    DEFINE cActivo        	CHAR(1); 
    DEFINE cNombre        	CHAR(60);
    DEFINE cCentro_costos 	CHAR(8); 
    DEFINE cNo_telefono   	CHAR(10);
    DEFINE cGenerico1     	CHAR(20);
    DEFINE cGenerico2     	CHAR(30);
    DEFINE cGenerico3     	CHAR(40);
    DEFINE cSucursal        CHAR(4);
    --DEFINE cNombreSuc         CHAR(40);
    DEFINE cNombreSuc       CHAR(30);
	DEFINE sPerfil         	SMALLINT;
	DEFINE cDeviceId        CHAR(20);
    
	
    LET cCodRet 		= '00000';
    LET iSqlErr 		= 0;
    LET iCodRetSp 		= 0;
    LET iNoRegistros 	= 0;
    LET cPassword 		= '';
    LET cImei  			= '';
    LET cActivo 		= '';
    LET cNombre  		= '';
    LET cCentro_costos 	= '';
    LET cNo_telefono 	= '';
    LET cGenerico1 		= '';
    LET cGenerico2 		= '';
    LET cGenerico3 		= '';
    LET cSucursal  		= '';
    LET cNombreSuc 		= '';
	LET sPerfil 		= 0;
	LET cDeviceId 		= '';
    
    BEGIN
	
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc, sPerfil, cDeviceId; 
        END EXCEPTION;
        
        --SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_usuario_movil.out';
        --TRACE ON;
        
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

        IF pUsuario = '' OR pIdFuncion = '' OR pEjecutivo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc, sPerfil, cDeviceId; 
        END IF;
        
        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc, sPerfil, cDeviceId; 
        END IF;

        IF(pImei = '') THEN                                                                          
			SELECT COUNT(*)
			INTO iNoRegistros
			FROM bdinteg:"informix".si_usuario_movil WHERE ejecutivo = pEjecutivo;
							
			IF iNoRegistros > 1 THEN
				LET cCodRet = '00478';
				RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc, sPerfil, cDeviceId; 
			ELIF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc, sPerfil, cDeviceId; 
			ELIF iNoRegistros = 1 THEN
				SELECT password, imei, activo, nombre, centro_costos, no_telefono, generico1, generico2, generico3, sucursal, perfil, device_id
				INTO cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3, cSucursal, sPerfil, cDeviceId  
				FROM bdinteg:"informix".si_usuario_movil WHERE ejecutivo = pEjecutivo;
				
				SELECT nombre INTO cNombreSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal; 
				
				RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc, sPerfil, cDeviceId; 
			END IF;
		ELSE
			SELECT password, imei, activo, nombre, centro_costos, no_telefono, generico1, generico2, generico3, sucursal, perfil, device_id
			INTO cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3, cSucursal, sPerfil, cDeviceId
			FROM bdinteg:"informix".si_usuario_movil WHERE ejecutivo = pEjecutivo AND imei = pImei;
			
			LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
			IF iNoRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc, sPerfil, cDeviceId; 
			END IF;	
			
			
			SELECT nombre INTO cNombreSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursal; 
			
			RETURN cCodRet,cPassword, cImei, cActivo, cNombre, cCentro_costos, cNo_telefono, cGenerico1, cGenerico2, cGenerico3,cSucursal, cNombreSuc, sPerfil, cDeviceId; 
		END IF;
	
	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 15/04/2015',
'DESCRIPCION: consulta un usuario en la tabla si_usuario_movil',
'FECHA: 28/04/2015',
'DESCRIPCION: Se retorna el nombre de la sucursal a 30 caracteres (el spl de consulta de sucursales solo devuelve 30 - sp_cnsif_consultasucursal)',
'AUTOR: Oscar Flores Conde',
'FECHA: 05/05/2015',
'DESCRIPCION: Se agrega validacion para determinar cuantas ocurrencias tiene el usuario',
'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 06/05/2015',
'DESCRIPCION: Se agrega parametro imei para devolver un usurio en particular',
'MODULO: Alta de usuario App',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/02/2018',
'DESCRIPCION: Se realiza modificaciÃ³n de SPL para hacer el ajuste del tamaÃ±o de los campos pImei y cImei.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 18/05/2020',
'DESCRIPCION: Se realiza modificaciÃ³n de SPL para agregar el campo perfil.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_usuario_movil(pUsuario CHAR(8), pIdFuncion CHAR(10), pEjecutivoAlta CHAR(8), pPassword  CHAR(20), pImei CHAR(60),pImeiAnt CHAR(60),
											 pActivo CHAR(1), pNombre CHAR(60), pCentro_costos CHAR(8), pSucursal CHAR(4),
											 pNo_telefono CHAR(10), pGenerico1 CHAR(20), pGenerico2 CHAR(30), 
											 pGenerico3 CHAR(40), ptipoOperacion INTEGER, pPerfil SMALLINT, pDeviceId CHAR(20))
	RETURNING CHAR(5) AS codret,INTEGER AS iNoRegistros;
                
                
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE bExisteUsuario BOOLEAN;
	DEFINE inoImei INTEGER;
	DEFINE bInTransaction BOOLEAN;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET bExisteUsuario = 'f';
	LET inoImei = 0;
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_usuario_movil.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pPassword = '' OR   pImei = '' OR pActivo= '' OR pNombre = '' OR
		pSucursal = '' OR pNo_telefono = '' OR ptipoOperacion IS NULL OR pPerfil = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;

		IF ptipoOperacion = 1 THEN
			-- Se valida que el ejecutivo no exista en la tabla
			SET ISOLATION TO DIRTY READ;
			
			IF EXISTS(SELECT ejecutivo FROM bdinteg:"informix".si_usuario_movil WHERE  ejecutivo = pEjecutivoAlta AND imei = pImei)THEN
				LET cCodRet = '00479';
			ELSE	
				INSERT INTO bdinteg:"informix".si_usuario_movil (ejecutivo, password, imei, activo, nombre,centro_costos,
																no_telefono, generico1, generico2, generico3, fecha_insert,
																user_insert, fecha_baja, user_baja, sucursal, perfil, device_id) 
				VALUES (pEjecutivoAlta, pPassword, pImei, pActivo, pNombre, pCentro_costos, pNo_telefono, pGenerico1,
												pGenerico2, pGenerico3, CURRENT, pUsuario, NULL, NULL, pSucursal, pPerfil, pDeviceId);
												
				LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
				IF iNoRegistros = 0 THEN -- 
					LET cCodRet = '00282';
				END IF;
					
			END IF;
			
			RETURN cCodRet, iNoRegistros;
		
		END IF;

		IF  ptipoOperacion = 2 THEN 	
		
			IF pImei = pImeiAnt THEN
				UPDATE bdinteg:"informix".si_usuario_movil SET
				password= pPassword,
				imei= pImei,
				activo= pActivo,
				nombre = pNombre,
				centro_costos=pCentro_costos,
				no_telefono= pNo_telefono, 
				generico1= pGenerico1, 
				generico2= pGenerico2, 
				generico3= pGenerico3, 
				fecha_baja= CURRENT, 
				user_baja= pUsuario, 
				sucursal=pSucursal,
				perfil = pPerfil,
				device_id = pDeviceId
				WHERE
				ejecutivo=pEjecutivoAlta
				AND imei= pImeiAnt;
				
				LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
				IF iNoRegistros = 0 THEN
						LET cCodRet = '00001';
				ELIF iNoRegistros > 1 THEN
						LET cCodRet = '00283'; -- Se actulizaron mas de 1 registro
				END IF;
				RETURN cCodRet, iNoRegistros;
			ELSE
				BEGIN
					ON EXCEPTION IN (-535)
						COMMIT; -- Transaccion del interact
						BEGIN WORK;
						LET bInTransaction = 't';
					END EXCEPTION WITH RESUME;
				
					BEGIN WORK;
					UPDATE bdinteg:"informix".si_usuario_movil SET
					password= pPassword,
					imei= pImei,
					activo= pActivo,
					nombre = pNombre,
					centro_costos=pCentro_costos,
					no_telefono= pNo_telefono, 
					generico1= pGenerico1, 
					generico2= pGenerico2, 
					generico3= pGenerico3, 
					fecha_baja= CURRENT, 
					user_baja= pUsuario, 
					sucursal=pSucursal,
					perfil = pPerfil,
					device_id = pDeviceId
					WHERE
					ejecutivo=pEjecutivoAlta
					AND imei= pImeiAnt;
					
					
					SELECT COUNT(imei) INTO inoImei FROM bdinteg:"informix".si_usuario_movil WHERE imei= pImei AND ejecutivo = pEjecutivoAlta;
					IF inoImei = 1 THEN
						COMMIT WORK;
					ELSE
						ROLLBACK WORK;
						LET cCodRet = '00480'; -- El imei ya fue asignado anteriormente a este usuario
					END IF;
					
					IF bInTransaction THEN
						BEGIN WORK; -- APERTURA DE LA TRANSACCIÃ?N DEL INTERACT
					END IF;
					
					RETURN cCodRet, iNoRegistros;
				END;
			END IF;
			
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 14/04/2015',
'DESCRIPCION: inserta  y actualiza un usuario en la tabla si_usuario_movil',
'AUTOR: Oscar Flores Conde',
'FECHA: 28/04/2015',
'DESCRIPCION: Se agrega validacion para determinar si el ejecutivo ya existe o no en la tabla',
'AUTOR: Oscar Flores Conde',
'FECHA: 05/05/2015',
'DESCRIPCION: Se elimina validacion para determinar si el ejecutivo ya existe o no en la tabla',
'AUTOR: Saul Ortiz Baeza',
'FECHA: 20/05/2015',
'DESCRIPCION: Se realiza la validacion  para determinar si el imei ya fue asignado anteriormente al usuario',
'MODULO: Alta de usuario App',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/02/2018',
'DESCRIPCION: Se realiza modificaciÃ³n de SPL para hacer el ajuste del tamaÃ±o de los campos pImei y pImeiAnt.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 18/05/2020',
'DESCRIPCION: Se realiza modificaciÃ³n de SPL para agregar el campo perfil.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ctes_consultahuellaactual(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumcte CHAR(20))
		RETURNING CHAR(5) AS codret,
				CHAR(942) AS  cTemplate1,
				CHAR(942) AS  cTemplate2,
				CHAR(942) AS  cTemplate3,
				CHAR(942) AS  cTemplate4,
				CHAR(942) AS  cTemplate5,
				CHAR(942) AS  cTemplate6,
				CHAR(942) AS  cTemplate7,
				CHAR(942) AS  cTemplate8,
				CHAR(942) AS  cTemplate9,
				CHAR(942) AS  cTemplate10,
				SMALLINT AS sNfiq1,
				SMALLINT AS sNfiq2, 
				SMALLINT AS sNfiq3, 
				SMALLINT AS sNfiq4, 
				SMALLINT AS sNfiq5, 
				SMALLINT AS sNfiq6, 
				SMALLINT AS sNfiq7, 
				SMALLINT AS sNfiq8, 
				SMALLINT AS sNfiq9, 
				SMALLINT AS sNfiq10,
				SMALLINT AS sMinucias1,
				SMALLINT AS sMinucias2,
				SMALLINT AS sMinucias3,
				SMALLINT AS sMinucias4,
				SMALLINT AS sMinucias5,
				SMALLINT AS sMinucias6,
				SMALLINT AS sMinucias7,
				SMALLINT AS sMinucias8,
				SMALLINT AS sMinucias9,
				SMALLINT AS sMinucias10,
				SMALLINT AS sSecuencia;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTemplate1  CHAR(942);
	DEFINE cTemplate2  CHAR(942);
	DEFINE cTemplate3  CHAR(942);
	DEFINE cTemplate4  CHAR(942);
	DEFINE cTemplate5  CHAR(942);
	DEFINE cTemplate6  CHAR(942);
	DEFINE cTemplate7  CHAR(942);
	DEFINE cTemplate8  CHAR(942);
	DEFINE cTemplate9  CHAR(942);
	DEFINE cTemplate10 CHAR(942);
	DEFINE sNfiq1  SMALLINT;
	DEFINE sNfiq2  SMALLINT;
	DEFINE sNfiq3  SMALLINT;
	DEFINE sNfiq4  SMALLINT;
	DEFINE sNfiq5  SMALLINT;
	DEFINE sNfiq6  SMALLINT;
	DEFINE sNfiq7  SMALLINT;
	DEFINE sNfiq8  SMALLINT;
	DEFINE sNfiq9  SMALLINT;
	DEFINE sNfiq10 SMALLINT;
	DEFINE sMinucias1 SMALLINT;
	DEFINE sMinucias2 SMALLINT;
	DEFINE sMinucias3 SMALLINT;
	DEFINE sMinucias4 SMALLINT;
	DEFINE sMinucias5 SMALLINT;
	DEFINE sMinucias6 SMALLINT;
	DEFINE sMinucias7 SMALLINT;
	DEFINE sMinucias8 SMALLINT;
	DEFINE sMinucias9 SMALLINT;
	DEFINE sMinucias10 SMALLINT;
	DEFINE sSecuencia SMALLINT;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	LET cTemplate1  = '';
	LET cTemplate2  = '';
	LET cTemplate3  = '';
	LET cTemplate4  = '';
	LET cTemplate5  = '';
	LET cTemplate6  = '';
	LET cTemplate7  = '';
	LET cTemplate8  = '';
	LET cTemplate9  = '';
    LET cTemplate10 = '';
	
	LET sNfiq1  = 0;
	LET sNfiq2  = 0;
	LET sNfiq3  = 0;
	LET sNfiq4  = 0;
	LET sNfiq5  = 0;
	LET sNfiq6  = 0;
	LET sNfiq7  = 0;
	LET sNfiq8  = 0;
	LET sNfiq9  = 0;
	LET sNfiq10 = 0;
		 
	LET sMinucias1 = 0; 
	LET sMinucias2 = 0; 
	LET sMinucias3 = 0; 
	LET sMinucias4 = 0; 
	LET sMinucias5 = 0; 
	LET sMinucias6 = 0; 
	LET sMinucias7 = 0; 
	LET sMinucias8 = 0; 
	LET sMinucias9 = 0; 
	LET sMinucias10 = 0;
	LET sSecuencia = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ctes_consultahuellaactual.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumcte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_huella_actual(pNumcte)
		INTO cCodRetSp,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP";
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 02/08/2022',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Fusion Manual de Clientes',
'DESCRIPCION: SPL encargado de consultar las huellas actuales de cliente (10 huellas)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ctes_obthuellasctes(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCteCorr CHAR(20), pNumCteInc CHAR(20))
		RETURNING CHAR(5) AS codret,
				CHAR(942) AS cTrama,
				CHAR(942) AS cTrama2,
				CHAR(942) AS cTramaInc,
				CHAR(942) AS cTramaInc2;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTrama CHAR(942);
	DEFINE cTrama2 CHAR(942);
	DEFINE cTramaInc CHAR(942);
	DEFINE cTramaInc2 CHAR(942);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cTrama = '';
	LET cTrama2 = '';
	LET cTramaInc = '';
	LET cTramaInc2 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTrama, cTrama2, cTramaInc, cTramaInc2;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ctes_obthuellasctes.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCteCorr  = '' OR pNumCteInc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTrama, cTrama2, cTramaInc, cTramaInc2;
		END IF;

		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTrama, cTrama2, cTramaInc, cTramaInc2;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_obthuellasactes2(pNumCteCorr, pNumCteInc)
		INTO cCodRetSp, cTrama, cTrama2, cTramaInc, cTramaInc2;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP";
		ELIF iCodRetSp = 2  THEN
			LET cCodRet = '01277';
		ELIF iCodRetSp = 3  THEN
			LET cCodRet = '01278';
		ELIF iCodRetSp = 6  THEN
			LET cCodRet = '01279';
		END IF;
		
		RETURN cCodRet, cTrama, cTrama2, cTramaInc, cTramaInc2;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 02/08/2022',
'MODULO: CLIENTES',
'FUNCIONALIDAD: Fusion Manual de Clientes',
'DESCRIPCION: SPL encargado de consultar la tabla si_cte_huella para traer la informacion de la huella derecha del cliente por su maxima secuencia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_finalizarrevisioncac(pUsuario CHAR(8), pIdFuncion CHAR(10), 
pNumSolicitud CHAR(20), pEjecutivo CHAR(8), pLincredSugCAC DECIMAL(18,2), pComprobante CHAR(1), pObservaciones CHAR(200))
    RETURNING CHAR(5) AS codret;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(100);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iRecuperacion INTEGER;
	--INC 27 195	
	DEFINE v_capacidad_pago    MONEY(14,2);
	DEFINE iPlazo  INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iRecuperacion = 0;
	--INC 27 195	
	LET v_capacidad_pago = 0;
	LET iPlazo = 0; 
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_finalizarrevisioncac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pEjecutivo = '' OR pNumSolicitud = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

		--Se actualiza la informacion de determinacion de linea para el nuevo credito TDC Oro
		EXECUTE PROCEDURE bdisolic:"informix".determina_lincred_tc_cjunk(cEmpresa, pNumSolicitud,'')
		INTO cCodRetSp, pLincredSugCAC,v_capacidad_pago,iPlazo;		
	
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisolic:determina_lincred_tc_cjunk';
		END IF;
		
		EXECUTE PROCEDURE bdisolic:"informix".sp_finalizar_revision_cac(cEmpresa,pNumSolicitud,pEjecutivo,pLincredSugCAC,pComprobante,pObservaciones)
		INTO cCodRetSp,cDescCodRetSp;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisolic:sp_finalizar_revision_cac';
		ELIF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
		ELIF cCodRetSp::INTEGER = 2 THEN
			LET cCodRet = '01087'; --VERIFIQUE LA INFORMACIÃN PROPORCIONADA
		ELIF cCodRetSp::INTEGER = 6 THEN
			LET cCodRet = '01088'; --OCURRIÃ UN ERROR AL EJECUTAR EL PROCEDIMIENTO: bdisolic:sp_actualiza_status_sol
		END IF;
		
		RETURN cCodRet;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 20/08/2018',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: Mesa de Control',
'DESCRIPCION: SPL encargado de continuar el flujo de la solicitud una vez finalizada la revision de la solicitud.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consdetallemovimientos(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20), 
pFechaInicial DATE, pFechaFinal DATE, pNumCuenta CHAR(20), pEjecutivo CHAR(8), pSucursal CHAR(4), pImporte MONEY(14,2), pClaveMov CHAR(50),
pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codret,
		DATE     	AS fecha,
		DATETIME HOUR TO FRACTION(3) AS hora,
		CHAR(4)  	AS cve_transaccion,
		CHAR(50) 	AS desc_transaccion,
		CHAR(16) 	AS folio,
		DATE     	AS periodo_inicial,
		MONEY(14,2) AS monto,
		DATE     	AS periodo_final,
		CHAR(20) 	AS sistema_cuenta,
		CHAR(1)  	AS naturaleza,
		CHAR(40) 	AS referencia,
		CHAR(1)  	AS reversos,
		CHAR(4)  	AS sucursal,
		CHAR(20) 	AS cve_procedencia,
		CHAR(50) 	AS desc_procedencia,
		MONEY(14,2) AS saldo,
		CHAR(20) 	AS numero_tarjeta,
		CHAR(1)  	AS reversados,
		CHAR(8)  	AS usuario,
		CHAR(23) 	AS referencia23;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE iRecuperacion INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cCveTransacc CHAR(4);
	DEFINE cDescTransacc CHAR(50);
	DEFINE cFolio CHAR(16);
	DEFINE dPeriodoInicial DATE;
	DEFINE mMonto MONEY(14,2);
	DEFINE dPeriodoFinal DATE;
	DEFINE cSisCuenta CHAR(20);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cReferencia CHAR(40);
	DEFINE cReversos CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cCveProc CHAR(20);
	DEFINE cDescProc CHAR(50);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cReversados CHAR(1);
	DEFINE cUsuario CHAR(8);
	DEFINE cReferencia23 CHAR(23);
	DEFINE iContReg INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicial  DATE;
	DEFINE dFechaFinal  DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iRecuperacion = 0;
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFecha = '';
	LET dHora = '';
	LET cCveTransacc = '';
	LET cDescTransacc = '';
	LET cFolio = '';
	LET dPeriodoInicial = '';
	LET mMonto = 0.00;
	LET dPeriodoFinal = '';
	LET cSisCuenta = '';
	LET cNaturaleza = '';
	LET cReferencia = '';
	LET cReversos = '';
	LET cSucursal = '';
	LET cCveProc = '';
	LET cDescProc = '';
	LET mSaldo = 0.00;
	LET cNumTarjeta = '';
	LET cReversados = '';
	LET cUsuario = '';
	LET cReferencia23 = '';
	LET iContReg = 0;
	LET iNumRegistros = 0;
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET dFechaInicial =null;
	LET dFechaFinal   =null;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_consdetallemovimientos.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pNumCuenta = '' OR 
		pClaveMov = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACIÓN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET dFechaInicial=LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial);
		LET dFechaFinal  =LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal);

		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion fecha,hora,cve_transacc,desc_transacc,folio,periodo_inicial,monto,periodo_final,sis_cuenta,naturaleza,referencia,reversos,sucursal,cve_proc,desc_proc,saldo,num_tarjeta,reversados,usuario,referencia23
			INTO dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23
			FROM bdicnweb:"informix".sw_cons_movimientos
			WHERE clave_mov = pClaveMov
			AND sis_cuenta = pSistemaCuenta
			AND periodo_inicial = dFechaInicial
			AND periodo_final = dFechaFinal
			ORDER BY fecha,hora,folio,cve_transacc ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23 WITH RESUME;
		END FOREACH;				
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 24/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIÓN/CRÉDITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el detalle de los registros que regresará la búsqueda por sistema de cuenta ingresado (CAPTACION/CREDITO/INVERSIONES).',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 27/11/2017',
'DESCRIPCION MODIFICACION :  Se agregan variables cFechaInicial  y  cFechaFinal, para tratar la fecha como MM/DD/YYYY ',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 30/11/2017',
'DESCRIPCION MODIFICACION :  Se cambian variables cFechaInicial  y  cFechaFinal a Date ',
'MODIFICACION: L. Montserrat León Amador',
'FECHA MODIFICACION: 08/01/2018',
'DESCRIPCION MODIFICACION :  Se implementa nuevo filtro de consulta pClaveMov.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se elimina filtro usuario_insert de la tabla bdicnweb:sw_cons_movimientos.',
'AUTOR: Daniel Reyes Guillen',
'FECHA 06/02/2022',
'DESCRIPCION MODIFICACION: Se actualiza order by de la consulta.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultageneralizadamsi(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30))
	RETURNING 	CHAR(5) AS codret,
				INTEGER AS plazo,
				DECIMAL(18,2) AS pago,
				DECIMAL(18,2) AS pagomasmsi;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSP CHAR(6);
    DEFINE cMensajeRet CHAR(80);    
	DEFINE cNumCredito CHAR(20);
    DEFINE cCodTipCred CHAR(2);
	DEFINE cDescStatusCred CHAR(60);     
    DEFINE iIdUnidadProd INTEGER;
    DEFINE cCodCaract2 CHAR(3);
    DEFINE dtFechaOrigen DATE;
    DEFINE dtFechaProxPago DATE;
    DEFINE dPagoMinimo DECIMAL(18,2);
    DEFINE dtFechaUltPago DATE;
    DEFINE iPlazo INTEGER;
    DEFINE iPagosRealizados INTEGER;
    DEFINE dLineaOtorgada DECIMAL(18,2);    
    DEFINE dTasaInteres DECIMAL(9,6);
    DEFINE dTasaMoratorios DECIMAL(9,6);
    DEFINE dMontoSBC DECIMAL(14,2);    
    DEFINE dCapVig DECIMAL(18,2);
    DEFINE dCapTrans DECIMAL(18,2);
    DEFINE dCapVdoExig DECIMAL(18,2);
    DEFINE dCapVdoNoExig DECIMAL(18,2);
    DEFINE dSdoActCap DECIMAL(18,2);        
	DEFINE dIntVdo DECIMAL(18,2);
    DEFINE dIntMoratorio DECIMAL(18,2);
    DEFINE dIntMes DECIMAL(18,2);
    DEFINE dSdoActInt DECIMAL(18,2);    
	DEFINE dIntVig DECIMAL(18,2);
    DEFINE dIvaIntVig DECIMAL(18,2);
    DEFINE dIvaIntVdo DECIMAL(18,2);
    DEFINE dIvaIntMoratorio DECIMAL(18,2);
    DEFINE dIvaIntMes DECIMAL(18,2);
    DEFINE dSdoActIvaInt DECIMAL(18,2);    
    DEFINE dComPend DECIMAL(18,2);
    DEFINE dIvaCom DECIMAL(18,2);
    DEFINE dSdoRetenido DECIMAL(18,2);
    DEFINE dSdoTotalLiq DECIMAL(18,2);    
    DEFINE dIntDevengado DECIMAL(18,2);
    DEFINE dIvaIntDevengado DECIMAL(18,2);
    DEFINE dLineaDisponible DECIMAL(18,2);
    DEFINE dPagosVdos DECIMAL(18,2);
    DEFINE cDescBloqueoCta CHAR(60);
    DEFINE cDescCausaBloqueoCta CHAR(50);
    DEFINE cSitCte CHAR(1);
    DEFINE cCausaCte INTEGER;
    DEFINE cDescSitEspCte CHAR(75);
    DEFINE cSitCred CHAR(1);
    DEFINE cCausaCred INTEGER;
    DEFINE cDescSitEspCred CHAR(75);
	DEFINE dSaldo_pagar DECIMAL(18,2);
	
	DEFINE dPago DECIMAL(18,2);
	DEFINE dPagoMasMSI DECIMAL(18,2);
	DEFINE dPagoMinimoAux DECIMAL(18,2);
	DEFINE cNumCreditoAux CHAR(20);
	DEFINE iPlazoAux INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSP ='';
    LET cMensajeRet ='';
	LET cNumCredito ='';
    LET cCodTipCred ='';
	LET cDescStatusCred ='';   
    LET iIdUnidadProd =0;
    LET cCodCaract2 ='';
    LET dtFechaOrigen ='';
    LET dtFechaProxPago ='';
    LET dPagoMinimo =0;
    LET dtFechaUltPago ='';
    LET iPlazo =0;
    LET iPagosRealizados =0;
    LET dLineaOtorgada =0;
    LET dTasaInteres =0;
    LET dTasaMoratorios =0;
    LET dMontoSBC =0;
    LET dCapVig  =0;
    LET dCapTrans  =0;
    LET dCapVdoExig  =0;
    LET dCapVdoNoExig  =0;
    LET dSdoActCap  =0;        
	LET dIntVdo  =0;
    LET dIntMoratorio  =0;
    LET dIntMes  =0;
    LET dSdoActInt  =0;    
	LET dIntVig  =0;
    LET dIvaIntVig  =0;
    LET dIvaIntVdo  =0;
    LET dIvaIntMoratorio  =0;
    LET dIvaIntMes  =0;
    LET dSdoActIvaInt  =0;    
    LET dComPend  =0;
    LET dIvaCom  =0;
    LET dSdoRetenido  =0;
    LET dSdoTotalLiq  =0;    
    LET dIntDevengado  =0;
    LET dIvaIntDevengado  =0;
    LET dLineaDisponible  =0;
    LET dPagosVdos  =0;
    LET cDescBloqueoCta ='';
    LET cDescCausaBloqueoCta ='';
    LET cSitCte ='';
    LET cCausaCte =0;
    LET cDescSitEspCte ='';
    LET cSitCred ='';
    LET cCausaCred =0;
    LET cDescSitEspCred ='';
	LET dSaldo_pagar  =0;

	LET dPago = 0;
	LET dPagoMasMSI = 0;
	LET dPagoMinimoAux = 0;
	LET cNumCreditoAux ='';
	LET iPlazoAux =0;

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iPlazo, dPago, dPagoMinimo;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_msi_consultageneralizadamsi.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iPlazo, dPago, dPagoMinimo;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
			EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',pNumCred) INTO 
				cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
				dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
				dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
				dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
				dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
				cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
				cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 

		LET dPago = NVL(dPagoMinimo,0);
		
		FOREACH  
		
			select a.num_credito INTO cNumCreditoAux from bdicred:"informix".sd_promocion_credito a 
			inner join bdicred:"informix".sd_maecredcrd f on a.num_sol_prestamo = f.num_credito 
			where a.num_sol_prestamo= pNumCred and f.status_cred IN ('AA','BA','BT','E1','E2','E3')
				
			EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',cNumCreditoAux) INTO 
			cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
			dPagoMinimoAux,dtFechaUltPago,iPlazoAux,iPagosRealizados,dLineaOtorgada,dTasaInteres,
			dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
			dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
			dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
			dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
			cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
			cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 
			
			LET dPagoMinimo = dPagoMinimo + dPagoMinimoAux;

		END FOREACH

		RETURN cCodRet, iPlazo, dPago, dPagoMinimo;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2022',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de los pagos y plazo para MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultamsi(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING 	CHAR(5) AS codret,
				CHAR(10) AS fecha,
				CHAR(10) AS hora,
				CHAR(16) AS tarjeta,
				CHAR(16) AS folio, 
				CHAR(3) AS codfun,
				CHAR(100) AS descripcion,
				CHAR(40) AS infreceptor,
				CHAR(40) AS referencia,
				DECIMAL(18,2) AS monto,
				INTEGER AS plazo,
				CHAR(60) AS status,
				DECIMAL(18,2) AS saldoliq,
				DECIMAL(18,2) AS saldopag,
				INTEGER AS llave;

	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
    DEFINE dSdoTotalLiq DECIMAL(18,2);  
	DEFINE dSaldo_pagar DECIMAL(18,2);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(10);
	DEFINE cTarjeta CHAR(16);
	DEFINE cFolio CHAR(16);
	DEFINE cCodFun CHAR(3);
	DEFINE cDescripcion CHAR(100);
	DEFINE cInfReceptor CHAR(40);
	DEFINE cReferencia CHAR(40);
	DEFINE dMontoOtorgado DECIMAL(18,2);
	DEFINE cStatus CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE iLlave INTEGER;
    DEFINE iPlazo INTEGER;
	
	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET dSdoTotalLiq =0;
	LET dSaldo_pagar  =0;
	LET cFecha ='';
	LET cHora ='';
	LET cTarjeta ='';
	LET cFolio ='';
	LET cCodFun ='';
	LET cDescripcion ='';
	LET cInfReceptor ='';
	LET cReferencia ='';
	LET dMontoOtorgado  =0;
	LET cStatus ='';
	LET iNoRegistros =0;
	LET iLlave = 0;
    LET iPlazo =0;

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_msi_cconsultamsi.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		FOREACH SELECT 
				SKIP pRegistros FIRST pRecuperacion 
				TO_CHAR(fecha,'%d/%m/%Y') as fecha, hora, tarjeta, folio,cod_fun,descripcion,infreceptor,referencia,montootorgado,plazo,status,saldoliq,saldopag,llave
				INTO cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave
				FROM
				"informix".sw_msi_consultagrid
				WHERE usuario = pUsuario and id = 'C' ORDER BY fecha,hora
				LET iNoRegistros = iNoRegistros +1;
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave WITH RESUME;
		END FOREACH

		IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '01276';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iLlave;
		END IF;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2021',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de las transaciones a MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultamsi_detalle_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30))
	RETURNING 	CHAR(5) AS codret,
				INTEGER AS total;

	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet 			= '00000';
	LET iSqlErr 			= 0;
	LET iNoRegistros =0;

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNoRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_msi_consultamsi_detalle_totales.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
		END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		  SELECT 
				COUNT(*)
				INTO iNoRegistros
				FROM
				"informix".sw_msi_consultagrid where llave = pNumCred and id = 'D' and usuario = pUsuario;

            IF iNoRegistros= 0 THEN 
                LET cCodret='01276';
            END IF;
			
			RETURN cCodRet, iNoRegistros;
	
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2021',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de las transaciones a MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultamsicancel(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING 	CHAR(5) AS codret,
				CHAR(10) AS fecha,
				CHAR(40) AS infreceptor,
				CHAR(16) AS folio,
				DECIMAL(18,2) AS monto,
				CHAR(10) AS plazopago,
				CHAR(16) AS tarjeta,
				INTEGER AS promo,
				CHAR(1) AS canal,
				CHAR(4) AS sucursal,
				DECIMAL(18,2) AS saldopag,
				DECIMAL(18,2) AS saldototal,
				CHAR(20) AS numcredito;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dSaldo_pagar DECIMAL(18,2);
	DEFINE dSdoTotalLiq DECIMAL(18,2);  
	DEFINE cFecha CHAR(10);
	DEFINE cPlazo CHAR(10);
	DEFINE cTarjeta CHAR(16);
	DEFINE cFolio CHAR(16);
	DEFINE cInfReceptor CHAR(40);
	DEFINE dMontoOtorgado DECIMAL(18,2);
	DEFINE iPromo INTEGER;
	DEFINE cCanal CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNumCredito CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dSaldo_pagar  =0;
	LET dSdoTotalLiq =0;
	LET cFecha ='';
	LET cPlazo ='';
	LET cTarjeta ='';
	LET cFolio ='';
	LET cInfReceptor ='';
	LET dMontoOtorgado  =0;
	LET iPromo =0;
	LET cCanal ='';
	LET cSucursal ='';
	LET iNoRegistros =0;
	LET cNumCredito ='';


	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSaldo_pagar,dSdoTotalLiq,cNumCredito;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_msi_consultamsicancel.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSaldo_pagar,dSdoTotalLiq,cNumCredito;
		END IF;

		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSaldo_pagar,dSdoTotalLiq,cNumCredito;
		END IF;
		
        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 RETURN cCodRet, cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSaldo_pagar,dSdoTotalLiq,cNumCredito;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	 
	   FOREACH SELECT 
				SKIP pRegistros FIRST pRecuperacion 
				fecha,infreceptor,folio,montootorgado,plazo,tarjeta,promo,canal,sucursal,saldoliq,saldopag,numcredito
				INTO cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSdoTotalLiq,dSaldo_pagar,cNumCredito
				FROM
				"informix".sw_msi_consultagridcancel
				WHERE usuario = pUsuario 
				LET iNoRegistros = iNoRegistros +1;
				RETURN cCodRet, cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSaldo_pagar,dSdoTotalLiq,cNumCredito WITH RESUME;
		END FOREACH
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '01278';
				RETURN cCodRet, cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSaldo_pagar,dSdoTotalLiq,cNumCredito;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSaldo_pagar,dSdoTotalLiq,cNumCredito;
		END IF;
	

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 26/04/2022',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de las transaciones a MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_verificastatusmsigrid(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
        INTEGER AS total,
		CHAR(15) AS proceso;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE cProceso CHAR(15);
    DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET cProceso='';
    LET iTotal = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_msi_verificastatusmsigrid.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,error_proceso,error,tipo_proceso,total
		INTO cStatus,cErrorProceso,cError,cProceso,iTotal
		FROM "informix".sw_verificastatusconsmsi
		WHERE usuario_insert = TRIM(pUsuario);
				
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'','I','',0,'';
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2022',
'DESCRIPCION: SPL encargado de hacer la validacion del reporte msi',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consdesbloqueomasivocre(pUsuario CHAR(8), pIdFuncion CHAR(10), pLote INT, pRegistros INT, pRecuperacion INT)
        RETURNING CHAR(5) AS codret,
                        INT AS id,
                        CHAR(20) AS no_credito,
                        CHAR(20) AS no_cliente,
                        CHAR(15) AS resultado,
                        CHAR(6) AS codretsp,
                        CHAR(80) AS motivo_rechazo,
                        MONEY(14,2) AS saldo,
                        CHAR(107) AS nombre_cliente,
                        DATE AS fecha_desbloqueo,
                        CHAR(8) AS empleado,
                        CHAR(45) AS nombre_empleado,
                        CHAR(1) AS status,
						CHAR(150) AS area_solicita,
						CHAR(150) AS justificacion,
						DECIMAL(18,2) AS saldo_capital;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE iIdRegistro INTEGER;
        DEFINE cNoCuenta CHAR(20);
        DEFINE cNoCliente CHAR(20);
        DEFINE cResultado CHAR(15);
        DEFINE cCodRetSp CHAR(6);
        DEFINE cMotivoRechazo CHAR(80);
        DEFINE mSaldo MONEY(14,2);
        DEFINE cNombreCliente CHAR(107);
        DEFINE dFechaDesbloqueo DATE;
        DEFINE cEmpleado CHAR(8);
        DEFINE cNombreEmpleado CHAR(45);
        DEFINE cStatusRegistro CHAR(1);
        DEFINE iExiste INTEGER;
        DEFINE iNoRegistros INTEGER;
		DEFINE cAreaSolicitante CHAR(150);
		DEFINE cJustificacion CHAR(150);
		DEFINE dSaldoCapital DECIMAL(18,2);
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET iIdRegistro = 0;
        LET cNoCuenta = '';
        LET cNoCliente = '';
        LET cResultado = '';
        LET cCodRetSp = '';
        LET cMotivoRechazo = '';
        LET mSaldo = NULL;
        LET cNombreCliente = '';
        LET dFechaDesbloqueo = NULL;
        LET cEmpleado = '';
        LET cNombreEmpleado = '';
        LET cStatusRegistro = '';
        LET iExiste = 0;
        LET iNoRegistros = 0;
		LET cAreaSolicitante = '';
		LET cJustificacion = '';
		LET dSaldoCapital = 0;
		
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_consdesbloqueomasivocre.out';
                --TRACE ON;
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pLote IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
                IF pRegistros < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
                -- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
                SELECT COUNT(id_registro)
                INTO iExiste
                FROM 
                        (SELECT id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre
                        WHERE lote = pLote
                        UNION
                        SELECT id_registro
                        FROM bdicnweb:"informix".sw_tr_cargamasiva_desbloqueocre_hist
                        WHERE lote = pLote);
                
                IF iExiste = 0 THEN
                        LET cCodRet = '00200';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
                -- ACTUALIZACIÃN DEL ESTATUS POR VALIDACION
                UPDATE bdicnweb:sw_tr_cargamasiva_desbloqueocre
                SET resultado = 'NO APLICADO',
                        motivo_rechazo = 'ERROR POR VALIDACION'
                WHERE lote = pLote AND status = 'E';
                
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, fecha_desbloqueo, usuario, status,
																	area_solicita, justificacion, saldo_capital
                        INTO iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, dFechaDesbloqueo, cEmpleado, cStatusRegistro,
							cAreaSolicitante, cJustificacion, dSaldoCapital
                        FROM
                                (SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, fecha_desbloqueo, usuario, usuario, status,
										area_solicita, justificacion, saldo_capital
                                FROM bdicnweb:sw_tr_cargamasiva_desbloqueocre
                                WHERE usuario = pUsuario
                                        AND lote = pLote
                                UNION
                                SELECT id_registro, cuenta, numcte, resultado, codret_proceso, motivo_rechazo, saldo_cuenta, fecha_desbloqueo, usuario, usuario, status,
										area_solicita, justificacion, saldo_capital
                                FROM bdicnweb:sw_tr_cargamasiva_desbloqueocre_hist
                                WHERE usuario = pUsuario
                                        AND lote = pLote)
                        ORDER BY id_registro
                        
                        
                        IF cNoCliente IS NULL OR cNoCliente = '' THEN
                                SELECT NVL(a.numcte, '')
                                INTO cNoCliente
                                FROM bdicred:sd_maecred a
                                WHERE num_credito = cNoCuenta;
                                
                                UPDATE bdicnweb:'informix'.sw_tr_cargamasiva_desbloqueocre
                                SET numcte = cNoCliente
                                WHERE id_registro = iIdRegistro;
                                
                                IF DBINFO('sqlca.sqlerrd2') = 0 THEN
                                        UPDATE bdicnweb:'informix'.sw_tr_cargamasiva_desbloqueocre_hist
                                        SET numcte = cNoCliente
                                        WHERE id_registro = iIdRegistro;
                                END IF;
                        END IF;
                        
                        SELECT NVL(TRIM(TRIM(TRIM(b.nombre1)||' '||TRIM(b.nombre2))||' '||TRIM(TRIM(b.apell_paterno)||' '||TRIM(b.apell_materno))), '') as nombre
                        INTO cNombreCliente
                        FROM bdinteg:si_cliente b
                        WHERE numcte = cNoCliente;
                        
                        SELECT NVL(nombre, '')
                        INTO cNombreEmpleado
                        FROM bdinteg:si_ejecut
                        WHERE ejecutivo = cEmpleado;
                        
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, UPPER(cMotivoRechazo), mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital WITH RESUME;
                                   
                        LET iNoRegistros = iNoRegistros + 1;
                        
                END FOREACH;
                
                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                ELIF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, iIdRegistro, cNoCuenta, cNoCliente, cResultado, cCodRetSp, cMotivoRechazo, mSaldo, cNombreCliente,
                               dFechaDesbloqueo, cEmpleado, cNombreEmpleado, cStatusRegistro, cAreaSolicitante, cJustificacion, dSaldoCapital;
                END IF;
                
        END;
                        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 23/07/2014',
'DESCRIPCION: Consulta de los registros de un lote masivo de cuentas a ser bloqueadas',
'AUTOR: Oscar Flores Conde',
'FECHA: 12/02/2015',
'DESCRIPCION: Se agrega a la salida la justificaciÃ³n, area que solicita y el saldo capital',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_actualizacccajagen(pUsuario CHAR(8), pIdFuncion CHAR(10), pCentroC Char(4),pMontoMin FLOAT, pMontoMax FLOAT, pPlazaCG CHAR(3), pPlazaCB INTEGER)
		RETURNING CHAR(5) AS codret,		
				  CHAR(30) AS status
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cStatus CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cStatus = '';

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_actualizacccajagen.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCentroC ='' OR pMontoMin ='' OR pMontoMax ='' OR pPlazaCG ='' OR pPlazaCB='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
        FOREACH
		EXECUTE PROCEDURE bdinteg:"informix".sp_actualizacccajagen(pCentroC,pMontoMin, pMontoMax, pPlazaCG, pPlazaCB)
		INTO cCodRet, cStatus
        END FOREACH;
       
		RETURN cCodRet, cStatus;
		 
		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_actualizacccajagen',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_actualizasucursal1(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdSucursal_a CHAR(4), pIdSucursal CHAR(4),
	pNomSucur CHAR(40), pTipo CHAR(1),pTpoSuc CHAR(2),pGerente CHAR(40),pPlaza CHAR(3),
	pSubGer CHAR(40), pTipoAcc CHAR(1),pTelex CHAR(20),pCorreo CHAR(120), pTel1 CHAR(14),pTel2 CHAR(14),pUserIns CHAR(30),pFechaIns DATE,
	pServCanj CHAR(1), pDispBaja CHAR(1), pComRet DECIMAL(5,2),pComConsul DECIMAL(5,2),pTipoBovSuc CHAR(3), pHorario CHAR(60))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cIdSucursal CHAR(4);
	DEFINE iTotal INTEGER;
  	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cIdSucursal='';
	LET iTotal = 0;   
 
	BEGIN
				
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

         --SET DEBUG FILE TO '/tmp/mfinis/sp_cc_actualizasucursal1.out';
		 --TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

      IF pIdSucursal_a ='' THEN
       
		SELECT COUNT(*)
		INTO iTotal
		FROM bdinteg:"informix".si_sucursales
        WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
		
		IF (iTotal > 0) THEN 
		
			IF pIdSucursal_a <> pIdSucursal THEN 
			
			SELECT sucursal
			INTO cIdSucursal
			FROM bdinteg:"informix".si_sucursales
            WHERE TRIM(sucursal)=TRIM(pIdSucursal);
			
			IF (cIdSucursal = pIdSucursal) THEN
					LET cCodRet = '01272';
			ELSE
                IF TRIM(pIdSucursal) ='' THEN
                LET pIdSucursal = pIdSucursal_a;
                END IF;

                SELECT COUNT(*)
                INTO iTotal
                FROM bdinteg:"informix".si_ptf
                WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);
		
			   IF (iTotal = 0) THEN 
               INSERT INTO bdinteg:"informix".si_ptf(id_ptf,tipo,tipo_acceso,correo,servicio_canje,tipo_bovsuc,horario,dispensa_baja,com_retiro,com_consulta,criterio_com,cp,cve_mun,cve_localidad,latitud,longitud,cve_col,calle,num_ext,num_int,referencia,clave_sit,fecha_sit,tel1,tel2) 
			   VALUES(pIdSucursal,pTipo,pTipoAcc,pCorreo,pServCanj,pTipoBovSuc,pHorario,pDispBaja,pComRet,pComConsul,'','','','','','','','','','','','','',pTel1,pTel2);
               END IF;
                
				UPDATE bdinteg:"informix".si_sucursales SET  
				sucursal = pIdSucursal,
				nombre = UPPER(pNomSucur),
				tipo = ptipo,
				telex = pTelex,
				telefono1 = pTel1,
				telefono2 = pTel2,
				tpo_sucursal = pTpoSuc,
				user_insert = pUserIns,
				fecha_insert = pFechaIns,
				gerente = pGerente,	
				subger = pSubGer,
				plaza = pPlaza
				WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
				
			    UPDATE bdinteg:"informix".si_ptf SET  
				id_ptf = pIdSucursal,	
                tipo = ptipo,
				tipo_bovsuc = pTipoBovSuc,
				horario = pHorario,
				tipo_acceso = pTipoAcc,
				servicio_canje = pServCanj,				
				dispensa_baja = pDispBaja,
				com_retiro =pComRet,
				com_consulta = pComConsul,
                tel1 = pTel1,
				tel2 = pTel2,
				correo = pCorreo
				WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);
					
			END IF;
			ELSE

              SELECT COUNT(*)
                INTO iTotal
                FROM bdinteg:"informix".si_ptf
                WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);
		
			   IF (iTotal = 0) THEN 
               INSERT INTO bdinteg:"informix".si_ptf(id_ptf,tipo,tipo_acceso,correo,servicio_canje,tipo_bovsuc,horario,dispensa_baja,com_retiro,com_consulta,criterio_com,cp,cve_mun,cve_localidad,latitud,longitud,cve_col,calle,num_ext,num_int,referencia,clave_sit,fecha_sit,tel1,tel2) 
			   VALUES(pIdSucursal,pTipo,pTipoAcc,pCorreo,pServCanj,pTipoBovSuc,pHorario,pDispBaja,pComRet,pComConsul,'','','','','','','','','','','','','',pTel1,pTel2);
               END IF;
                
			UPDATE bdinteg:"informix".si_sucursales SET  
				sucursal = pIdSucursal,
				nombre = UPPER(pNomSucur),
				tipo = ptipo,
				telex = pTelex,
				telefono1 = pTel1,
				telefono2 = pTel2,
				tpo_sucursal = pTpoSuc,
				user_insert = pUserIns,
				fecha_insert = pFechaIns,
				gerente = pGerente,	
				subger = pSubGer,
				plaza = pPlaza
				WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
				
			    UPDATE bdinteg:"informix".si_ptf SET  
				id_ptf = pIdSucursal,	
                tipo = ptipo,
				tipo_bovsuc = pTipoBovSuc,
				horario = pHorario,
				tipo_acceso = pTipoAcc,
				servicio_canje = pServCanj,				
				dispensa_baja = pDispBaja,
				com_retiro =pComRet,
				com_consulta = pComConsul,
                tel1 = pTel1,
				tel2 = pTel2,
				correo = pCorreo
				WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);
			END IF;
		ELSE
			
			LET pIdSucursal = pIdSucursal;
		    LET pIdSucursal_a = pIdSucursal_a;
			
			SELECT sucursal
			INTO cIdSucursal
			FROM bdinteg:"informix".si_sucursales
            WHERE TRIM(sucursal)=TRIM(pIdSucursal);
			
			IF (cIdSucursal = pIdSucursal) THEN
					LET cCodRet = '01272';
			ELSE

           IF pUsuario = '' OR pIdFuncion = ''  OR pNomSucur ='' OR pTipo='' OR pTpoSuc ='' OR pGerente ='' OR pPlaza='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		  END IF;
            
			INSERT INTO bdinteg:"informix".si_sucursales(sucursal,empresa,nombre,tipo,telex,telefono1,telefono2,tpo_sucursal,user_insert,fecha_insert,gerente,subger,pais,estado,ciudad,plaza,monto_minimo,mto_min_efect,mto_max_efect,monto_min_sbc,sal_min_pza,dias_laborables,factor_remesas,factor_rem_sbc,iva,plaza_cajagen,id_plazaclabe) 
			VALUES(pIdSucursal,'001',UPPER(pNomSucur),pTipo,pTelex,pTel1,pTel2,pTpoSuc,pUserIns,pFechaIns,UPPER(pGerente),UPPER(pSubGer),'','','',pPlaza,'','','','','','','','','','','');
			INSERT INTO bdinteg:"informix".si_ptf(id_ptf,tipo,tipo_acceso,correo,servicio_canje,tipo_bovsuc,horario,dispensa_baja,com_retiro,com_consulta,criterio_com,cp,cve_mun,cve_localidad,latitud,longitud,cve_col,calle,num_ext,num_int,referencia,clave_sit,fecha_sit,tel1,tel2) 
			VALUES(pIdSucursal,pTipo,pTipoAcc,pCorreo,pServCanj,pTipoBovSuc,pHorario,pDispBaja,pComRet,pComConsul,'','','','','','','','','','','','','',pTel1,pTel2);
			END IF;
		END IF;
ELSE 

  SELECT COUNT(*)
                INTO iTotal
                FROM bdinteg:"informix".si_ptf
                WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);
		
			   IF (iTotal = 0) THEN 
               INSERT INTO bdinteg:"informix".si_ptf(id_ptf,tipo,tipo_acceso,correo,servicio_canje,tipo_bovsuc,horario,dispensa_baja,com_retiro,com_consulta,criterio_com,cp,cve_mun,cve_localidad,latitud,longitud,cve_col,calle,num_ext,num_int,referencia,clave_sit,fecha_sit,tel1,tel2) 
			   VALUES(pIdSucursal,pTipo,pTipoAcc,pCorreo,pServCanj,pTipoBovSuc,pHorario,pDispBaja,pComRet,pComConsul,'','','','','','','','','','','','','',pTel1,pTel2);
               END IF;

UPDATE bdinteg:"informix".si_sucursales SET  
				sucursal = pIdSucursal,
				nombre = UPPER(pNomSucur),
				tipo = ptipo,
				telex = pTelex,
				telefono1 = pTel1,
				telefono2 = pTel2,
				tpo_sucursal = pTpoSuc,
				user_insert = pUserIns,
				fecha_insert = pFechaIns,
				gerente = pGerente,	
				subger = pSubGer,
				plaza = pPlaza
				WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
				
			    UPDATE bdinteg:"informix".si_ptf SET  
				id_ptf = pIdSucursal,	
                tipo = ptipo,
				tipo_bovsuc = pTipoBovSuc,
				horario = pHorario,
				tipo_acceso = pTipoAcc,
				servicio_canje = pServCanj,				
				dispensa_baja = pDispBaja,
				com_retiro =pComRet,
				com_consulta = pComConsul,
                tel1 = pTel1,
				tel2 = pTel2,
				correo = pCorreo
				WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);
END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'DESCRIPCION: INSERTA O ACTUALIZA LOS VALORES DE LA TABLA si_sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_actualizasucursal2(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdSucursal_a CHAR(4), pIdSucursal CHAR(4),	
	pCritCom CHAR(5), pCvePais CHAR(3),pCveEst CHAR(2),pCveCiu CHAR(3),pCp CHAR(5),
	pCveMun CHAR(3),pCveLocal CHAR(14),pCveCol CHAR(8),pLatitud CHAR(10), pLongitud CHAR(11))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cIdSucursal CHAR(4);
	DEFINE iTotal INTEGER;
  	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cIdSucursal='';
	LET iTotal = 0;   

   
	BEGIN
				
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

         --SET DEBUG FILE TO '/tmp/mfinis/sp_cc_actualizasucursal2.out';
		 --TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        
        IF pIdSucursal_a ='' THEN
        LET pIdSucursal_a = pIdSucursal;
        END IF;

IF pIdSucursal_a <> pIdSucursal THEN 
		
		SELECT COUNT(*)
		INTO iTotal
		FROM bdinteg:"informix".si_sucursales
        WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
		
		IF (iTotal > 0) THEN 
		
			SELECT sucursal
			INTO cIdSucursal
			FROM bdinteg:"informix".si_sucursales
            WHERE TRIM(sucursal)=TRIM(pIdSucursal);
			
			IF (cIdSucursal = pIdSucursal) THEN
					LET cCodRet = '01272';
			ELSE
                IF TRIM(pIdSucursal) ='' THEN
                LET pIdSucursal = pIdSucursal_a;
                END IF;
				
				UPDATE bdinteg:"informix".si_sucursales SET  							
				pais = pCvePais,
				estado = pCveEst,
				ciudad = pCveCiu			 		
				WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
				
			    UPDATE bdinteg:"informix".si_ptf SET  		                  
				criterio_com = pCritCom,
				cp = pCp,
				cve_mun = pCveMun,
				cve_localidad = pCveLocal,
				latitud = pLatitud,
				longitud=pLongitud,
				cve_col = pCveCol	
				WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);
					
			END IF;
		ELSE
			
			LET pIdSucursal = pIdSucursal;
		    LET pIdSucursal_a = pIdSucursal_a;
			
			SELECT sucursal
			INTO cIdSucursal
			FROM bdinteg:"informix".si_sucursales
            WHERE TRIM(sucursal)=TRIM(pIdSucursal);
			
			IF (cIdSucursal = pIdSucursal) THEN
					LET cCodRet = '01272';
			ELSE			
			END IF;
		END IF;
ELSE 

UPDATE bdinteg:"informix".si_sucursales SET  							
				pais = pCvePais,
				estado = pCveEst,
				ciudad = pCveCiu			 		
				WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
				
			    UPDATE bdinteg:"informix".si_ptf SET  		               
				criterio_com = pCritCom,
				cp = pCp,
				cve_mun = pCveMun,
				cve_localidad = pCveLocal,
				latitud = pLatitud,
				longitud=pLongitud,
				cve_col = pCveCol	
				WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);

END IF;	
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'DESCRIPCION: INSERTA O ACTUALIZA LOS VALORES DE LA TABLA si_sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_actualizasucursal3(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdSucursal_a CHAR(4), pIdSucursal CHAR(4),
    pCalle CHAR (100), pNumExt CHAR(6), pNumInt CHAR(5), pReferencia CHAR(120),pMonMin DECIMAL(10,2),
	pMonMinEfe MONEY(16,2),pMonMaxEfe MONEY(16,2), pMonMinSBC DECIMAL(14,2), pSalMinPlz DECIMAL(14,2),pDiasLab INTEGER, 
	pFactorRem DECIMAL(9,6),pFactorRemSBC DECIMAL(10,5),pIva DECIMAL(5,3), pIdPlazaCG CHAR(3),pIdPlazaClabe INTEGER,pClaveSit CHAR(3),pFechaSit DATE)
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cIdSucursal CHAR(4);
	DEFINE iTotal INTEGER;
  	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cIdSucursal='';
	LET iTotal = 0;   

   
	BEGIN
				
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

         --SET DEBUG FILE TO '/tmp/mfinis/sp_cc_actualizasucursal3.out';
		 --TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        
        IF pIdSucursal_a ='' THEN
        LET pIdSucursal_a = pIdSucursal;
        END IF;

    
IF pIdSucursal_a <> pIdSucursal THEN 
		
		SELECT COUNT(*)
		INTO iTotal
		FROM bdinteg:"informix".si_sucursales
        WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
		
		IF (iTotal > 0) THEN 
		
			SELECT sucursal
			INTO cIdSucursal
			FROM bdinteg:"informix".si_sucursales
            WHERE TRIM(sucursal)=TRIM(pIdSucursal);
			
			IF (cIdSucursal = pIdSucursal) THEN
					LET cCodRet = '01272';
			ELSE
                IF TRIM(pIdSucursal) ='' THEN
                LET pIdSucursal = pIdSucursal_a;
                END IF;
				
				UPDATE bdinteg:"informix".si_sucursales SET  							 
			    monto_minimo = pMonMin,
				mto_min_efect = pMonMinEfe,
				mto_max_efect = pMonMaxEfe,
				monto_min_sbc = pMonMinSBC,
				sal_min_pza=pSalMinPlz,
				dias_laborables = pDiasLab,
				factor_remesas = pFactorRem,
				factor_rem_sbc = pFactorRemSBC,
				iva = pIva,
				plaza_cajagen = pIdPlazaCG,
				id_plazaclabe = pIdPlazaClabe			
				WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
				
			    UPDATE bdinteg:"informix".si_ptf SET  			               
				calle = UPPER(pCalle),
				num_ext = pNumExt,
				num_int = pNumInt,
				referencia = UPPER(pReferencia),
				clave_sit = pClaveSit,
				fecha_sit = pFechaSit
				WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);
					
			END IF;
		ELSE
			
			LET pIdSucursal = pIdSucursal;
		    LET pIdSucursal_a = pIdSucursal_a;
			
			SELECT sucursal
			INTO cIdSucursal
			FROM bdinteg:"informix".si_sucursales
            WHERE TRIM(sucursal)=TRIM(pIdSucursal);
			
			IF (cIdSucursal = pIdSucursal) THEN
					LET cCodRet = '01272';
			ELSE			
			END IF;
		END IF;

ELSE 

UPDATE bdinteg:"informix".si_sucursales SET  			
			    monto_minimo = pMonMin,
				mto_min_efect = pMonMinEfe,
				mto_max_efect = pMonMaxEfe,
				monto_min_sbc = pMonMinSBC,
				sal_min_pza=pSalMinPlz,
				dias_laborables = pDiasLab,
				factor_remesas = pFactorRem,
				factor_rem_sbc = pFactorRemSBC,
				iva = pIva,
				plaza_cajagen = pIdPlazaCG,
				id_plazaclabe = pIdPlazaClabe			
				WHERE TRIM(sucursal)=TRIM(pIdSucursal_a);
				
			    UPDATE bdinteg:"informix".si_ptf SET  			            
				calle = UPPER(pCalle),
				num_ext = pNumExt,
				num_int = pNumInt,
				referencia = UPPER(pReferencia),
				clave_sit = pClaveSit,
				fecha_sit = pFechaSit
				WHERE TRIM(id_ptf)=TRIM(pIdSucursal_a);

END IF;		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'DESCRIPCION: INSERTA O ACTUALIZA LOS VALORES DE LA TABLA si_sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consulta_gral_direccion(pUsuario CHAR(8), pIdFuncion CHAR(10), pPais CHAR(3), pEstado CHAR (3), pCiudad CHAR (3),pNomCiudad CHAR(40),pCodigo CHAR(5),pMunicipio CHAR(5),pLocalidad CHAR(14), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20)	AS clave,
				  CHAR(100)	AS descripcion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cClave CHAR(20);
	DEFINE cDescripcion CHAR(100);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClave = '';
	LET cDescripcion = '';
    LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consulta_gral_direccion.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;

        IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cClave, cDescripcion;
        END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave,cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF(pRegistros == 0) THEN
            DELETE FROM bdicnweb:"informix".sw_cons_gral_direcciones WHERE usuario = pUsuario;

            FOREACH
                EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_gral_direccion(pPais,pEstado, pCiudad,pNomCiudad,pCodigo,pMunicipio,pLocalidad)
                INTO cCodRet, cClave,cDescripcion

                INSERT INTO bdicnweb:"informix".sw_cons_gral_direcciones VALUES(pUsuario, cClave,cDescripcion);
            END FOREACH;
        END IF;

        FOREACH
            SELECT SKIP pRegistros FIRST pRecuperacion
			clave, descripcion
            INTO cClave, cDescripcion FROM bdicnweb:"informix".sw_cons_gral_direcciones
            WHERE usuario = pUsuario
            ORDER BY clave
            LET iNoRegistros = iNoRegistros + 1;

            RETURN cCodRet, cClave, cDescripcion WITH RESUME;

        END FOREACH;

        IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet, cClave, cDescripcion;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_consultaperfil',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultacajagen(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,					
				  CHAR(3) AS codplaza,
				  CHAR(40) AS descripcion
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodPlaza CHAR(3);
	DEFINE cNombre CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodPlaza='';
	LET cNombre='';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodPlaza,cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultacajagen.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodPlaza,cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodPlaza,cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	
		SELECT codigo_plaza,descripcion INTO cCodPlaza,cNombre 
		FROM bdinteg:"informix".si_plazas_cajagen  
		WHERE codigo_plaza=(SELECT plaza_cajagen FROM bdinteg:"informix".si_sucursales WHERE empresa ='001' AND sucursal =pSucursal);	
        
        IF NVL(cCodPlaza,0)= 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCodPlaza,cNombre;
		END IF;	
		      
		RETURN cCodRet, cCodPlaza,cNombre;
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'DESCRIPCION: SPL encargado de recuperar los datos de la caja general',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultacajagencombo(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,					
				  CHAR(3) as caja,
			      CHAR(60) as nomcaja 
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodPlaza CHAR(3);
	DEFINE cNombre CHAR(40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodPlaza='';
	LET cNombre='';
	LET iNoRegistros=0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodPlaza,cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultacajagencombo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodPlaza,cNombre;
		END IF;
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCodPlaza, cNombre;
        END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodPlaza,cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
			
		IF(pRegistros == 0) THEN
            DELETE FROM "informix".sw_cons_gral_cajagen WHERE usuario = pUsuario;

            FOREACH 
                EXECUTE PROCEDURE  bdinteg:"informix".sp_consultacajagen() 
				INTO cCodRet,cCodPlaza,cNombre

                INSERT INTO "informix".sw_cons_gral_cajagen VALUES(pUsuario, cCodPlaza,cNombre); 
            END FOREACH;	
        END IF;

        FOREACH 
            SELECT SKIP pRegistros FIRST pRecuperacion 
			caja, descripcion 
            INTO cCodPlaza, cNombre FROM "informix".sw_cons_gral_cajagen 
            WHERE usuario = pUsuario
            
            LET iNoRegistros = iNoRegistros + 1;
						
            RETURN cCodRet, cCodPlaza, cNombre WITH RESUME;

        END FOREACH;
        
        IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet, cCodPlaza,cNombre;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCodPlaza,cNombre;
		END IF;   
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar ejecutar el sp productivo sp_consultacajagen',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultaimpre(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,					
				  CHAR(4) as plaza,
			      CHAR(60) as nomPlaza 
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodImp CHAR(4);
	DEFINE cNombre CHAR(60);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodImp='';
	LET cNombre='';
	LET iNoRegistros=0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodImp,cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultaimpre.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodImp,cNombre;
		END IF;
		
		 IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCodImp, cNombre;
        END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodImp,cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF(pRegistros == 0) THEN
            DELETE FROM "informix".sw_cons_gral_impresora WHERE usuario = pUsuario;

            FOREACH 
                SELECT clave,descripcion
                INTO  cCodImp,cNombre
				FROM bdinteg:"informix".si_impresoras
                INSERT INTO "informix".sw_cons_gral_impresora VALUES(pUsuario, cCodImp,cNombre); 
            END FOREACH;	
        END IF;

        FOREACH 
            SELECT SKIP pRegistros FIRST pRecuperacion 
			impresora, descripcion 
            INTO cCodImp, cNombre FROM "informix".sw_cons_gral_impresora 
            WHERE usuario = pUsuario
            
            LET iNoRegistros = iNoRegistros + 1;
						
            RETURN cCodRet, cCodImp, cNombre WITH RESUME;

        END FOREACH;
        
        IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet, cCodImp,cNombre;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCodImp,cNombre;
		END IF;   
	
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar los datos de la tabla si_impresoras',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultanumvbparam(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,							
				  CHAR(5) AS exitoso;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE bExitoso BOOLEAN;
	DEFINE cDescrip CHAR(20);
	DEFINE cValor CHAR(50);
    DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET bExitoso = 't';
	LET cDescrip = '';
	LET cValor = '';
    LET iTotal = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,bExitoso;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultanumvbparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,bExitoso;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,bExitoso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		FOREACH 
		Select desc_campo,valor 
		INTO cDescrip,cValor
		from bdinteg:"informix".si_vbparam 
		
		IF NVL(cValor,'')='' THEN
            LET bExitoso ='f';
            LET cCodRet ='00017';
		END IF;
		LET iTotal = iTotal+1;
		END FOREACH;

        IF iTotal = 0 THEN
            LET cCodRet ='00017';
            LET bExitoso ='f';
            RETURN cCodRet,bExitoso;
		END IF;

		RETURN cCodRet,bExitoso;
		 				 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar el número de valores de la tabla si_vbparam',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultaperfil(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEmpleado CHAR(8))
		RETURNING CHAR(5) AS codret,		
				  INTEGER as perf
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE ivPerfil INTEGER;
	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET ivPerfil = 0;

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, ivPerfil;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultaperfil.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumEmpleado = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, ivPerfil;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, ivPerfil;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		 
		EXECUTE PROCEDURE bdinteg:"informix".sp_consultaperfil(pNumEmpleado)
		INTO cCodRet, ivPerfil;
       
		RETURN cCodRet, ivPerfil;
		 
		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_consultaperfil',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultaplazaclabecc(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,		
			      INTEGER AS idplazaClabe, 
			      CHAR(60) AS NomPlaza  
			 ;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iIdplazaClabe INTEGER;
	DEFINE cNomPlaza CHAR(60);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iIdplazaClabe=0;
	LET cNomPlaza='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdplazaClabe,cNomPlaza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultaplazaclabecc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdplazaClabe,cNomPlaza;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdplazaClabe,cNomPlaza;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		 
		EXECUTE PROCEDURE bdinteg:"informix".sp_consultaplazaclabecc(pSucursal)
		INTO cCodRet, iIdplazaClabe,cNomPlaza;

        IF cCodRet ='0000' OR cCodRet ='0001' THEN
        LET cCodRet ='00000';
        END IF;
       
		RETURN cCodRet, iIdplazaClabe,cNomPlaza;
		 
		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_consultaplazaclabecc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultaplazaclavecombo(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,					
				  CHAR(3) as plaza,
			      CHAR(60) as nomPlaza 
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodPlaza CHAR(3);
	DEFINE cNombre CHAR(40);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodPlaza='';
	LET cNombre='';
	LET iNoRegistros=0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodPlaza,cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultaplazaclavecombo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodPlaza,cNombre;
		END IF;
		
		 IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cCodPlaza, cNombre;
        END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodPlaza,cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF(pRegistros == 0) THEN
            DELETE FROM "informix".sw_cons_gral_plazas WHERE usuario = pUsuario;

            FOREACH 
                EXECUTE PROCEDURE  bdinteg:"informix".sp_consultaplazaclabe() 
               INTO cCodRet,cCodPlaza,cNombre

                INSERT INTO "informix".sw_cons_gral_plazas VALUES(pUsuario, cCodPlaza,cNombre); 
            END FOREACH;	
        END IF;

        FOREACH 
            SELECT SKIP pRegistros FIRST pRecuperacion 
			plaza, descripcion 
            INTO cCodPlaza, cNombre FROM "informix".sw_cons_gral_plazas 
            WHERE usuario = pUsuario
            
            LET iNoRegistros = iNoRegistros + 1;
						
            RETURN cCodRet, cCodPlaza, cNombre WITH RESUME;

        END FOREACH;
        
        IF iNoRegistros = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet, cCodPlaza,cNombre;
		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cCodPlaza,cNombre;
		END IF;   
	
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar los datos de la plaza',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultaplazacmb(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(3)	AS clave,
				  CHAR(40)	AS descripcion;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cClave CHAR(3);
	DEFINE cDescripcion CHAR(40);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClave = '';
	LET cDescripcion = '';
    LET iNoRegistros = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClave, cDescripcion;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultaplazacmb.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;

		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave,cDescripcion;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


        FOREACH
            SELECT plaza, nombre
			INTO cClave, cDescripcion FROM bdinteg:"informix".si_plazas
            ORDER BY plaza
			LET iNoRegistros = iNoRegistros + 1;

			RETURN cCodRet, cClave, cDescripcion WITH RESUME;
        END FOREACH;


        IF iNoRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet, cClave, cDescripcion;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Johanttan Esquivel Sanchez',
'FECHA: 17/08/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: Ubicacion Centro de Costos',
'DESCRIPCION: SPL encargado de consultar las plazas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultarazsoc(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(3) AS empresa,
				  CHAR(30) AS razon
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cStatus CHAR(30);
	DEFINE cEmpresa CHAR(3);
	DEFINE cRazon CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cStatus = '';
	LET cEmpresa ='';
	LET cRazon ='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa,cRazon;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultarazsoc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEmpresa,cRazon;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEmpresa,cRazon;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
        SELECT empresa,razon_social INTO cEmpresa,cRazon FROM bdinteg:"informix".si_empresas where empresa ='001';
        
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cEmpresa,cRazon;
		END IF;		
       
		RETURN cCodRet, cEmpresa,cRazon;
		 		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de consultar la razon social',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultaregional(pUsuario CHAR(8), pIdFuncion CHAR(10), pPlaza CHAR(4))
		RETURNING CHAR(5) AS codret,					
				  CHAR(3) AS regional,
				  CHAR(40) AS nombre
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cRegional CHAR(3);
	DEFINE cNombre CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cRegional='';
	LET cNombre='';
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cRegional,cNombre;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultaregional.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cRegional,cNombre;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cRegional,cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		 
		SELECT regional,nombre INTO cRegional,cNombre 
		FROM bdinteg:"informix".si_regional  
		WHERE regional=(SELECT regional FROM bdinteg:"informix".si_plazas WHERE empresa ='001' AND plaza =pPlaza) 
		AND empresa='001';

        IF NVL(cRegional,0)=0 THEN
        LET cCodRet ='00017';
        END IF
 
		RETURN cCodRet, cRegional,cNombre;
		 
		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar los datos del regional',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultarepsucursales(pUsuario CHAR(8), pIdFuncion CHAR(10),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,					
				  CHAR(4) AS sucursal,	
				  CHAR(40) AS nombre,
				  CHAR(100) AS calle, 
                  CHAR(6) AS numero, 
                  CHAR(100) AS colonia,
                  CHAR(60) AS ciudad,
				  CHAR(5) AS cp,	
				  CHAR(30) AS estado,
				  CHAR(14) AS telefono, 
				  CHAR(20) AS tipo,	
                  CHAR(30) AS tipoS,
				  CHAR(80) AS responsable,
				  CHAR(20) AS actest
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cSucursal CHAR(4);
    DEFINE cNombre   CHAR(40);
    DEFINE cCalle    CHAR(100);
    DEFINE cNumExt   CHAR(6);
    DEFINE cColonia  CHAR(100);
    DEFINE cCiudad   CHAR(60);
	DEFINE cCp  	 CHAR(5);
    DEFINE cEstado   CHAR(30);
	DEFINE cTel   	 CHAR(14);
    DEFINE cTipo     CHAR(20);
    DEFINE cTipoS    CHAR(30);
	DEFINE cResponsable  CHAR(80);
    DEFINE cActEst   CHAR(20);
	DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = '';
	LET cSucursal = '';
	LET cNombre ='';
	LET cCp = '';
	LET cEstado = '';
	LET cTel = '';
	LET cTipo ='';
	LET cResponsable = '';
	LET cActEst = '';
	LET iTotal= 0;
	
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSucursal,cNombre,cCalle,cNumExt,cColonia,cCiudad,cCp,cEstado,cTel,cTipo,cTipoS,cResponsable,cActEst;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultarepsucursales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
		    RETURN cCodRet,cSucursal,cNombre,cCalle,cNumExt,cColonia,cCiudad,cCp,cEstado,cTel,cTipo,cTipoS,cResponsable,cActEst;
		END IF;
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cSucursal,cNombre,cCalle,cNumExt,cColonia,cCiudad,cCp,cEstado,cTel,cTipo,cTipoS,cResponsable,cActEst;
        END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSucursal,cNombre,cCalle,cNumExt,cColonia,cCiudad,cCp,cEstado,cTel,cTipo,cTipoS,cResponsable,cActEst;
		END IF;
       
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		FOREACH		
		SELECT SKIP pRegistros FIRST pRecuperacion  a.sucursal,TRIM(a.nombre),  UPPER( NVL(TRIM (b.calle),'N/A')), NVL(TRIM(b.num_ext),'N/A'), NVL(TRIM(UPPER(f.desc_colonia)),'N/A'),NVL(TRIM(UPPER(g.nombre)),'N/A'),nvl(b.cp,' '),nvl(REPLACE(c.nombre,'Null',' '),' '),nvl(REPLACE(REPLACE(TRIM(b.tel1),'','Null'),'Null',' '),' '),TRIM(nvl(a.tipo,' ') ||' '||UPPER(nvl(e.descripparam,' '))),TRIM(nvl(a.tpo_sucursal,' ') ||' '||UPPER(nvl(h.descripparam,' '))),TRIM(nvl( a.gerente,' ')),UPPER(nvl(TRIM(d.descripparam),' ')) 
		INTO cSucursal,cNombre,cCalle,cNumExt,cColonia,cCiudad,cCp,cEstado,cTel,cTipo,cTipoS,cResponsable,cActEst
		FROM bdinteg:"informix".si_sucursales a 
		LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf  
		LEFT JOIN bdinteg:"informix".si_estados c ON a.estado = c.estado
		LEFT JOIN bdinteg:"informix".si_paramptf d ON b.clave_sit = d.valorparam AND d.claveparam='2'
		LEFT JOIN bdinteg:"informix".si_paramptf e ON a.tipo = e.valorparam AND e.claveparam='1'
        LEFT JOIN bdinteg:"informix".si_ciudades g ON a.ciudad = g.ciudad  AND a.estado = g.estado AND b.cve_localidad = g.localidad_inegi 
        LEFT JOIN bdinteg:"informix".si_localidades f ON a.estado = f.cve_estado AND b.cve_mun = f.cve_mun AND b.cve_localidad = f.cve_localidad_cnbv AND b.cp=f.cp AND b.cve_col=f.cve_col
        LEFT JOIN bdinteg:"informix".si_paramptf h ON a.tpo_sucursal =h.valorparam AND h.claveparam='8' 
		WHERE b.tipo IN ('A','B','I','O','S','X') 
		ORDER BY a.sucursal
 		LET iTotal = iTotal+1;
		RETURN cCodRet,cSucursal,cNombre,cCalle,cNumExt,cColonia,cCiudad,cCp,cEstado,cTel,cTipo,cTipoS,cResponsable,cActEst WITH RESUME;
		END FOREACH;
		
		IF iTotal = 0 AND pRegistros = 0 THEN
            LET cCodRet = '00017';
			RETURN cCodRet,cSucursal,cNombre,cCalle,cNumExt,cColonia,cCiudad,cCp,cEstado,cTel,cTipo,cTipoS,cResponsable,cActEst;
		ELIF iTotal = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cSucursal,cNombre,cCalle,cNumExt,cColonia,cCiudad,cCp,cEstado,cTel,cTipo,cTipoS,cResponsable,cActEst;
		END IF;
		 		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'DESCRIPCION: SPL encargado de recuperar datos dela tabla sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultarepsucursales_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,					
				 INTEGER AS total
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal=0;
	 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultarepsucursales_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
		    RETURN cCodRet,iTotal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotal;
		END IF;
       
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		 
		SELECT COUNT(*)
		INTO iTotal
		FROM bdinteg:"informix".si_sucursales a 
		LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf  
		LEFT JOIN bdinteg:"informix".si_estados c ON a.estado = c.estado
		LEFT JOIN bdinteg:"informix".si_paramptf d ON b.clave_sit = d.valorparam AND d.claveparam='2'
		LEFT JOIN bdinteg:"informix".si_paramptf e ON a.tipo = e.valorparam AND e.claveparam='1'
        LEFT JOIN bdinteg:"informix".si_ciudades g ON a.ciudad = g.ciudad  AND a.estado = g.estado AND b.cve_localidad = g.localidad_inegi 
        LEFT JOIN bdinteg:"informix".si_localidades f ON a.estado = f.cve_estado AND b.cve_mun = f.cve_mun AND b.cve_localidad = f.cve_localidad_cnbv AND b.cp=f.cp AND b.cve_col=f.cve_col
		LEFT JOIN bdinteg:"informix".si_paramptf h ON a.tpo_sucursal =h.valorparam AND h.claveparam='8' 
		WHERE b.tipo IN ('A','B','I','O','S','X') ;
 		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,iTotal;
		END IF;		
		
		RETURN cCodRet,iTotal;
		 		 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'DESCRIPCION: SPL encargado de recuperar el total de datos dela tabla sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultarutareporte(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,		
				  CHAR(100) as valor
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(100);
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cValor ='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultarutareporte.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValor;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			 
		SELECT valor INTO cValor FROM bdinteg:"informix".si_param WHERE cod_param ='503' AND empresa='001';		
       
		RETURN cCodRet, cValor;
		 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar la ruta para el reporte de la tabla si_param',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultasuc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSuc CHAR(4))
		RETURNING CHAR(5) AS codret,		
				  CHAR(3) AS empresa,
				  CHAR(4) AS sucursal,
				  CHAR(40) AS nombre,
				  CHAR(1) AS tipo,
				  CHAR(1) AS tipo_acc,
				  CHAR(20) AS telex,
				  CHAR(120) AS correo,
				  CHAR(14) AS tel1,
				  CHAR(14) AS tel2,
				  CHAR(1) AS tipoS,
				  CHAR(1) AS serv_canj,
				  CHAR(2) AS tpo_suc,
				  CHAR(12) AS horario,
				  CHAR(1) AS dispensabaja,
				  DECIMAL(5,2) AS comretiro,
				  DECIMAL(5,2) AS comconsulta,
				  CHAR(5) AS critcom,
				  CHAR(3) AS tipobovsuc,
				  CHAR(30) AS user_insert,
				  DATE AS fecha_insert,
				  CHAR(40) AS direccion,
                  CHAR(30) AS razon
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE cNombre CHAR(40);
	DEFINE cTipo CHAR(1);
	DEFINE cTipo_acceso CHAR(1);
	DEFINE cTelex CHAR(20);
	DEFINE cCorreo CHAR(120);
	DEFINE cTel1 CHAR(14);
	DEFINE cTel2 CHAR(14);
	DEFINE cTipoS CHAR(1);
	DEFINE cServCanj CHAR(1);
	DEFINE cTpoSuc CHAR(2);
	DEFINE cHorario CHAR(12);
	DEFINE cDispensabaja CHAR(1);
	DEFINE dComRetiro DECIMAL(5,2);
	DEFINE dComConsulta DECIMAL(5,2);
	DEFINE cComCrit CHAR(5);
	DEFINE cTipoBovsuc CHAR(3);
	DEFINE cUserInsert CHAR(30);
	DEFINE dFechaInsert DATE;
	DEFINE cDir CHAR(40);
    DEFINE cRazon CHAR(30);
	DEFINE ivPerfil INTEGER;
    DEFINE iExiste INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa='';
	LET cSucursal='';
	LET cNombre='';
	LET cTipo = '';
	LET cTipo_acceso = '';
	LET cTelex='';
	LET cCorreo ='';
	LET cTel1 ='';
	LET cTel2='';
	LET cTipoS='';
	LET cServCanj='';
	LET cTpoSuc = '';
	LET cHorario='';
	LET cDispensabaja ='';
	LET dComRetiro =0;
	LET dComConsulta =0;
	LET cComCrit='';
	LET cTipoBovsuc='';
	LET cUserInsert ='';
	LET dFechaInsert = DATE(1);
	LET cDir ='';
    LET cRazon ='';
	LET ivPerfil =0;
    LET iExiste =0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cTipo,cTipo_acceso,cTelex,cCorreo,cTel1,cTel2,cTipoS,cServCanj,cTpoSuc,cHorario,cDispensabaja,dComRetiro,dComConsulta,cComCrit,cTipoBovsuc,cUserInsert,dFechaInsert,cDir,cRazon;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultasuc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cTipo,cTipo_acceso,cTelex,cCorreo,cTel1,cTel2,cTipoS,cServCanj,cTpoSuc,cHorario,cDispensabaja,dComRetiro,dComConsulta,cComCrit,cTipoBovsuc,cUserInsert,dFechaInsert,cDir,cRazon;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cTipo,cTipo_acceso,cTelex,cCorreo,cTel1,cTel2,cTipoS,cServCanj,cTpoSuc,cHorario,cDispensabaja,dComRetiro,dComConsulta,cComCrit,cTipoBovsuc,cUserInsert,dFechaInsert,cDir,cRazon;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			 
		EXECUTE PROCEDURE bdinteg:"informix".sp_consultaperfil(pUsuario)
		INTO cCodRet, ivPerfil; 

        SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_sucursales a WHERE a.sucursal=pNumSuc AND a.empresa='001';

        IF iExiste =1 THEN		 				
		IF ivPerfil = 201 THEN 
		
		SELECT a.empresa,a.sucursal, a.nombre, b.tipo, b.tipo_acceso, a.telex,b.correo, a.telefono1,a.telefono2,a.tipo,b.servicio_canje,a.tpo_sucursal,b.horario,b.dispensa_baja,b.com_retiro,b.com_consulta, b.criterio_com,b.tipo_bovsuc,a.user_insert,a.fecha_insert,a.direccion1  
		INTO cEmpresa, cSucursal,cNombre,cTipo,cTipo_acceso,cTelex,cCorreo,cTel1,cTel2,cTipoS,cServCanj,cTpoSuc,cHorario,cDispensabaja,dComRetiro,dComConsulta,cComCrit,cTipoBovsuc,cUserInsert,dFechaInsert,cDir
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001' AND tpo_sucursal='S'; 	
		        
        SELECT razon_social INTO cRazon FROM bdinteg:"informix".si_empresas where empresa =cEmpresa;
        
         IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cTipo,cTipo_acceso,cTelex,cCorreo,cTel1,cTel2,cTipoS,cServCanj,cTpoSuc,cHorario,cDispensabaja,dComRetiro,dComConsulta,cComCrit,cTipoBovsuc,cUserInsert,dFechaInsert,cDir,cRazon;
		END IF;
	
		ELSE 
		       
		SELECT a.empresa,a.sucursal, a.nombre, b.tipo, b.tipo_acceso, a.telex,b.correo, a.telefono1,a.telefono2,a.tipo,b.servicio_canje,a.tpo_sucursal,b.horario,b.dispensa_baja,b.com_retiro,b.com_consulta, b.criterio_com,b.tipo_bovsuc,a.user_insert,a.fecha_insert,a.direccion1  
		INTO cEmpresa, cSucursal,cNombre,cTipo,cTipo_acceso,cTelex,cCorreo,cTel1,cTel2,cTipoS,cServCanj,cTpoSuc,cHorario,cDispensabaja,dComRetiro,dComConsulta,cComCrit,cTipoBovsuc,cUserInsert,dFechaInsert,cDir
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001'; 	   
			   		        
        SELECT razon_social INTO cRazon FROM bdinteg:"informix".si_empresas where empresa =cEmpresa;
        
         IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cEmpresa,cSucursal,cNombre,cTipo,cTipo_acceso,cTelex,cCorreo,cTel1,cTel2,cTipoS,cServCanj,cTpoSuc,cHorario,cDispensabaja,dComRetiro,dComConsulta,cComCrit,cTipoBovsuc,cUserInsert,dFechaInsert,cDir,cRazon;
		END IF;		
		END IF;
				   
		RETURN cCodRet, cEmpresa,cSucursal,cNombre,cTipo,cTipo_acceso,cTelex,cCorreo,cTel1,cTel2,cTipoS,cServCanj,cTpoSuc,cHorario,cDispensabaja,dComRetiro,dComConsulta,cComCrit,cTipoBovsuc,cUserInsert,dFechaInsert,cDir,cRazon;
		 		      
        ELSE

        LET cCodRet = '00017';
		RETURN cCodRet, cEmpresa,cSucursal,cNombre,cTipo,cTipo_acceso,cTelex,cCorreo,cTel1,cTel2,cTipoS,cServCanj,cTpoSuc,cHorario,cDispensabaja,dComRetiro,dComConsulta,cComCrit,cTipoBovsuc,cUserInsert,dFechaInsert,cDir,cRazon;

        END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar los datos de la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultasucactest(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSuc CHAR(4))
		RETURNING CHAR(5) AS codret,							
				  CHAR(3) AS clavesit,
				  DATE AS fechasit;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cClaveSit CHAR(3);
	DEFINE dFechaSit DATE;
	DEFINE ivPerfil INTEGER;
    DEFINE iExiste INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cClaveSit = '';
	LET dFechaSit = DATE(1);
	LET ivPerfil =0;
    LET iExiste = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClaveSit,dFechaSit;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultasucactest.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClaveSit,dFechaSit;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClaveSit,dFechaSit;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        EXECUTE PROCEDURE bdinteg:"informix".sp_consultaperfil(pUsuario)
		INTO cCodRet, ivPerfil; 

        SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_sucursales a WHERE a.sucursal=pNumSuc AND a.empresa='001';

        IF iExiste =1 THEN		 						 				
		IF ivPerfil = 201 THEN 

        Select b.clave_sit,b.fecha_sit 
		INTO cClaveSit,dFechaSit
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001' AND tpo_sucursal='S';	

         IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, cClaveSit,dFechaSit;
		END IF;

        ELSE
					
		Select b.clave_sit,b.fecha_sit 
		INTO cClaveSit,dFechaSit
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001';	

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, cClaveSit,dFechaSit;
		END IF;
        
        END IF;
		 
		RETURN cCodRet, cClaveSit,dFechaSit;

        ELSE

        LET cCodRet = '00017';
		RETURN cCodRet, cClaveSit,dFechaSit;

        END IF;
		 				 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar los valores de la tabla si_ptf',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultasucelim(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,							
				  INTEGER AS total;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotal INTEGER;
	DEFINE iExiste INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotal = 0;
	LET iExiste = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotal;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultasucelim.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotal;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		 
		SELECT COUNT(*) INTO iExiste
		FROM bdinteg:"informix".si_feriadsuc   
		WHERE sucursal = pSucursal;
		
		LET iTotal = iTotal+iExiste;

		SELECT COUNT(*) INTO iExiste
		FROM bdinteg:"informix".si_sucgpo    
		WHERE sucursal = pSucursal;
		
		LET iTotal = iTotal+iExiste;
		
		SELECT COUNT(*) INTO iExiste
		FROM bdinteg:"informix".si_tcsuc    
		WHERE sucursal = pSucursal;
		
		LET iTotal = iTotal+iExiste;
		       
		RETURN cCodRet, iTotal;
		 
		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar si la sucursal tiene dependencias',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultasucfunc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSuc CHAR(4))
		RETURNING CHAR(5) AS codret,							
				  CHAR(40) AS gerente,
				  CHAR(40) AS subger;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cGerente CHAR(40);
	DEFINE cSubGer CHAR(40);
	DEFINE ivPerfil INTEGER;
    DEFINE iExiste INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cGerente = '';
	LET cSubGer = '';
	LET ivPerfil =0;
    LET iExiste = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cGerente,cSubGer;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultasucfunc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cGerente,cSubGer;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cGerente,cSubGer;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        EXECUTE PROCEDURE bdinteg:"informix".sp_consultaperfil(pUsuario)
		INTO cCodRet, ivPerfil; 

        SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_sucursales a WHERE a.sucursal=pNumSuc AND a.empresa='001';

        IF iExiste =1 THEN		 				
        IF ivPerfil = 201 THEN 

        SELECT a.gerente,a.subger 
		INTO cGerente,cSubGer
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001' AND tpo_sucursal='S';	

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, cGerente,cSubGer;
		END IF;
        
        ELSE
        
        SELECT a.gerente,a.subger 
		INTO cGerente,cSubGer
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001';	

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, cGerente,cSubGer;
		END IF;

        END IF;

		RETURN cCodRet, cGerente,cSubGer;
        
        LET cCodRet = '00017';
		RETURN cCodRet, cGerente,cSubGer;

        END IF;
		 				 		     
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar los valores de la tabla si_sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultasucparam(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSuc CHAR(4))
		RETURNING CHAR(5) AS codret,		
				  DECIMAL(10,2) AS montomin,
				  MONEY(16,2) AS montominefe,
				  MONEY(16,2) AS montomaxefe,
				  DECIMAL(14,2) AS monminsbc,
				  DECIMAL(14,2) AS salminplaza,
				  INTEGER AS diaslab,
				  DECIMAL(9,2) AS factorrem,
				  DECIMAL(10,2) AS factorremsbc,
				  DECIMAL(5,2) AS iva,
				  CHAR(3) AS plazacg,
				  INTEGER AS plazaclabe				
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dmontomin DECIMAL(10,2);
	DEFINE mmontominefe MONEY(16,2);
    DEFINE mmontomaxefe MONEY(16,2);
    DEFINE dmonminsbc DECIMAL(14,2);
    DEFINE dsalminplaza DECIMAL(14,2);
    DEFINE idiaslab INTEGER;
	DEFINE dfactorrem DECIMAL(9,2);
	DEFINE dfactorremsbc DECIMAL(10,2);
	DEFINE diva DECIMAL(5,2);
	DEFINE cplazacg CHAR(3); 
	DEFINE iplazaclabe INTEGER;
	DEFINE ivPerfil INTEGER;
    DEFINE iExiste INTEGER;

	LET cCodRet='';
	LET iSqlErr='';
	LET dmontomin=0;
	LET mmontominefe=0; 
	LET mmontomaxefe=0;
	LET dmonminsbc=0;
	LET dsalminplaza =0;
	LET idiaslab =0;
	LET dfactorrem =0;
	LET dfactorremsbc=0;
	LET diva =0;
	LET cplazacg ='';
	LET iplazaclabe =0;
	LET ivPerfil =0;
    LET iExiste = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dmontomin,mmontominefe,mmontomaxefe,dmonminsbc,dsalminplaza,idiaslab,dfactorrem,dfactorremsbc,diva,cplazacg,iplazaclabe;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultasucparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dmontomin,mmontominefe,mmontomaxefe,dmonminsbc,dsalminplaza,idiaslab,dfactorrem,dfactorremsbc,diva,cplazacg,iplazaclabe;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dmontomin,mmontominefe,mmontomaxefe,dmonminsbc,dsalminplaza,idiaslab,dfactorrem,dfactorremsbc,diva,cplazacg,iplazaclabe;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
        EXECUTE PROCEDURE bdinteg:"informix".sp_consultaperfil(pUsuario)
		INTO cCodRet, ivPerfil; 
        
        SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_sucursales a WHERE a.sucursal=pNumSuc AND a.empresa='001';

        IF iExiste =1 THEN		 						 				
		IF ivPerfil = 201 THEN 

		SELECT a.monto_minimo,a.mto_min_efect, a.mto_max_efect, a.monto_min_sbc, a.sal_min_pza, a.dias_laborables,a.factor_remesas, a.factor_rem_sbc,a.iva,a.plaza_cajagen,a.id_plazaclabe
		INTO dmontomin,mmontominefe,mmontomaxefe,dmonminsbc,dsalminplaza,idiaslab,dfactorrem,dfactorremsbc,diva,cplazacg,iplazaclabe
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001' AND tpo_sucursal='S';	

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, dmontomin,mmontominefe,mmontomaxefe,dmonminsbc,dsalminplaza,idiaslab,dfactorrem,dfactorremsbc,diva,cplazacg,iplazaclabe;
		END IF; 

        ELSE 

		SELECT a.monto_minimo,a.mto_min_efect, a.mto_max_efect, a.monto_min_sbc, a.sal_min_pza, a.dias_laborables,a.factor_remesas, a.factor_rem_sbc,a.iva,a.plaza_cajagen,a.id_plazaclabe
		INTO dmontomin,mmontominefe,mmontomaxefe,dmonminsbc,dsalminplaza,idiaslab,dfactorrem,dfactorremsbc,diva,cplazacg,iplazaclabe
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001';

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, dmontomin,mmontominefe,mmontomaxefe,dmonminsbc,dsalminplaza,idiaslab,dfactorrem,dfactorremsbc,diva,cplazacg,iplazaclabe;
		END IF;
        END IF;
		       
		RETURN cCodRet, dmontomin,mmontominefe,mmontomaxefe,dmonminsbc,dsalminplaza,idiaslab,dfactorrem,dfactorremsbc,diva,cplazacg,iplazaclabe;
		 
        ELSE

        LET cCodRet = '00017';
		RETURN cCodRet, dmontomin,mmontominefe,mmontomaxefe,dmonminsbc,dsalminplaza,idiaslab,dfactorrem,dfactorremsbc,diva,cplazacg,iplazaclabe;

        END IF;
		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar los datos de la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultasucubica(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSuc CHAR(4))
		RETURNING CHAR(5) AS codret,		
				  CHAR(3) AS cvepais,
				  CHAR(2) AS cveestado,
				  CHAR(3) AS cveciudad,
				  CHAR(5) AS cp,
				  CHAR(3) AS plaza,
				  CHAR(3) AS cvemunicipio,
				  CHAR(14) AS cvelocalidad,
				  CHAR(8) AS cvecolonia,
				  CHAR(10) AS latitud,
				  CHAR(11) AS longitud,
				  CHAR(100) AS calle,
				  CHAR(6) AS numext,
				  CHAR(5) AS numint,
				  CHAR(120) AS referencia
			;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE ccvepais CHAR(3);
	DEFINE ccveestado CHAR(2);
	DEFINE ccveciudad CHAR(3);
	DEFINE ccp CHAR(5);
	DEFINE cplaza CHAR(3);
	DEFINE ccvemunicipio CHAR(3);
	DEFINE ccvelocalidad CHAR(14);
	DEFINE ccvecolonia CHAR(8);
	DEFINE clatitud CHAR(10);
	DEFINE clongitud CHAR(11);
	DEFINE ccalle CHAR(100);
	DEFINE cnumext CHAR(6);
	DEFINE cnumint CHAR(5);
	DEFINE creferencia CHAR(120);
	DEFINE ivPerfil INTEGER;
    DEFINE iExiste INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET ccvepais ='';
	LET ccveestado ='';
	LET ccveciudad ='';
	LET ccp ='';
	LET cplaza ='';
	LET ccvemunicipio ='';
	LET ccvelocalidad ='';
	LET ccvecolonia ='';
	LET clatitud ='';
	LET clongitud ='';
	LET ccalle ='';
	LET cnumext ='';
	LET cnumint ='';
	LET creferencia ='';
	LET ivPerfil =0;
    LET iExiste =0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, ccvepais,ccveestado,ccveciudad,ccp,cplaza,ccvemunicipio,ccvelocalidad,ccvecolonia,clatitud,clongitud,ccalle,cnumext,cnumint,creferencia;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultasucubica.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, ccvepais,ccveestado,ccveciudad,ccp,cplaza,ccvemunicipio,ccvelocalidad,ccvecolonia,clatitud,clongitud,ccalle,cnumext,cnumint,creferencia;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, ccvepais,ccveestado,ccveciudad,ccp,cplaza,ccvemunicipio,ccvelocalidad,ccvecolonia,clatitud,clongitud,ccalle,cnumext,cnumint,creferencia;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
        EXECUTE PROCEDURE bdinteg:"informix".sp_consultaperfil(pUsuario)
		INTO cCodRet, ivPerfil; 
        
        SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_sucursales a WHERE a.sucursal=pNumSuc AND a.empresa='001';

        IF iExiste =1 THEN		 	
		IF ivPerfil = 201 THEN 

        SELECT a.pais,a.estado, a.ciudad, b.cp, a.plaza, b.cve_mun,b.cve_localidad, b.cve_col,b.latitud,b.longitud,b.calle,b.num_ext,b.num_int,b.referencia
		INTO ccvepais,ccveestado,ccveciudad,ccp,cplaza,ccvemunicipio,ccvelocalidad,ccvecolonia,clatitud,clongitud,ccalle,cnumext,cnumint,creferencia
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001' AND tpo_sucursal='S';	

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
            LET cCodRet = '00017';
		RETURN cCodRet, ccvepais,ccveestado,ccveciudad,ccp,cplaza,ccvemunicipio,ccvelocalidad,ccvecolonia,clatitud,clongitud,ccalle,cnumext,cnumint,creferencia;
		END IF;

        ELSE

		SELECT a.pais,a.estado, a.ciudad, b.cp, a.plaza, b.cve_mun,b.cve_localidad, b.cve_col,b.latitud,b.longitud,b.calle,b.num_ext,b.num_int,b.referencia
		INTO ccvepais,ccveestado,ccveciudad,ccp,cplaza,ccvemunicipio,ccvelocalidad,ccvecolonia,clatitud,clongitud,ccalle,cnumext,cnumint,creferencia
		FROM bdinteg:"informix".si_sucursales a LEFT JOIN bdinteg:"informix".si_ptf b ON a.sucursal = b.id_ptf AND a.tipo = b.tipo 
		WHERE a.sucursal=pNumSuc AND a.empresa='001';

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
		RETURN cCodRet, ccvepais,ccveestado,ccveciudad,ccp,cplaza,ccvemunicipio,ccvelocalidad,ccvecolonia,clatitud,clongitud,ccalle,cnumext,cnumint,creferencia;
		END IF;
        END IF;
        
		RETURN cCodRet, ccvepais,ccveestado,ccveciudad,ccp,cplaza,ccvemunicipio,ccvelocalidad,ccvecolonia,clatitud,clongitud,ccalle,cnumext,cnumint,creferencia;
		
        ELSE

        LET cCodRet = '00017';
		RETURN cCodRet, ccvepais,ccveestado,ccveciudad,ccp,cplaza,ccvemunicipio,ccvelocalidad,ccvecolonia,clatitud,clongitud,ccalle,cnumext,cnumint,creferencia;

        END IF;
		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar los datos de la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultatiposuc(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,		
				  CHAR(1) AS tipo
			 ;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cTipo CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cTipo='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTipo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultatiposuc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSucursal='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cTipo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cTipo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		 
		SELECT tipo INTO cTipo FROM bdinteg:"informix".si_sucursales  WHERE sucursal=pSucursal AND empresa='001';
	
		
		IF cTipo = '' THEN		
			LET cTipo ='S';
		END IF;	
       
		RETURN cCodRet, cTipo;
		 
		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de consultar el tipo de sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_consultavbparam(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,							
				  CHAR(20) AS descrip,
				  CHAR(50) AS valor;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cDescrip CHAR(20);
	DEFINE cValor CHAR(50);
    DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDescrip = '';
	LET cValor = '';
    LET iTotal = 0 ;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescrip,cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_consultavbparam.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cDescrip,cValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cDescrip,cValor;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		FOREACH 
		Select desc_campo,valor 
		INTO cDescrip,cValor
		from bdinteg:"informix".si_vbparam 
		where desc_campo in ('monto_miniefect','monto_maxefect')	
        LET iTotal = iTotal +1;
		RETURN cCodRet, cDescrip,cValor WITH RESUME;
		
		END FOREACH;

        IF iTotal =0 THEN
        LET cCodRet='00017';
        RETURN cCodRet, cDescrip,cValor;
        END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de recuperar los valores de la tabla si_vbparam',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_eliminasuc(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_eliminasuc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		DELETE FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = pSucursal;
		
		DELETE FROM bdinteg:"informix".si_ptf
		WHERE id_ptf = pSucursal;
	 
		RETURN cCodRet;
		 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de eliminar la sucursal',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_recsiparamptf(pUsuario CHAR(8), pIdFuncion CHAR(10), pParametro CHAR(1))
		RETURNING CHAR(5) AS codret,		
				  CHAR(4) AS clave,
		          CHAR(100) AS descripcion
			;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE cDesparam CHAR(100);
    DEFINE cValorparam CHAR(4);
    DEFINE iTotal INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cDesparam = '';
	LET cValorparam = '';
    LEt iTotal =0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cValorparam,cDesparam;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_recsiparamptf.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pParametro='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cValorparam,cDesparam;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cValorparam,cDesparam;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
        FOREACH
		EXECUTE PROCEDURE bdinteg:"informix".sp_recsi_paramptf(pParametro)
		INTO cCodRet,cValorparam,cDesparam
        LET iTotal =iTotal+1;
		RETURN cCodRet,cValorparam,cDesparam WITH RESUME;
		END FOREACH;

        IF iTotal =0 THEN
        LET cCodRet='00017';
        RETURN cCodRet,cValorparam,cDesparam;
        END IF;
		      
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'MODULO: Centro de costos',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo sp_recsi_paramptf',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_repsucursales(pUsuario CHAR(8), pIdFuncion CHAR(10),pRutaDescarga CHAR(100))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE cBanDetError CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHoy = '';
	LET cFechaHoraArchivo = '';
	LET cBanDetError = 'f';

	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_repsucursales.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' THEN
			LET cCodRet = '00003';			
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		LET cCmd1 ="";
        LET cCmd1 ="SELECT * FROM (SELECT 'NUMERO CENTRO','NOMBRE CENTRO','CALLE','NO. EXTERIOR','COLONIA','CIUDAD','CODIGO POSTAL','ESTADO','TELEFONO','TIPO PTF','TIPO CENTRO COSTOS','RESPONSABLE','ACT. ESTADO PTF' FROM systables  WHERE tabid = 1) ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT * FROM (select a.sucursal,TRIM(a.nombre),  UPPER( NVL(TRIM (b.calle),'N/A')), NVL(TRIM(b.num_ext),'N/A'), NVL(TRIM(f.desc_colonia),'N/A'),NVL(TRIM(g.nombre),'N/A'),nvl(b.cp,' '),nvl(REPLACE(c.nombre,'Null',' '),' '),nvl(REPLACE(REPLACE(TRIM(b.tel1),'','Null'),'Null',' '),' '),TRIM(nvl(a.tipo,' ') ||' '||UPPER(nvl(e.descripparam,' '))),TRIM(nvl(a.tpo_sucursal,' ') ||' '||UPPER(nvl(h.descripparam,' '))),TRIM(nvl( a.gerente,' ')),UPPER(nvl(TRIM(d.descripparam),' ')) ";        
        LET cCmd1 =""||TRIM(cCmd1)||" FROM bdinteg:""informix"".si_sucursales a LEFT join bdinteg:""informix"".si_ptf b on a.sucursal = b.id_ptf  LEFT join bdinteg:""informix"".si_estados c on a.estado = c.estado LEFT JOIN bdinteg:""informix"".si_paramptf d on b.clave_sit = d.valorparam and d.claveparam='2' LEFT JOIN bdinteg:""informix"".si_paramptf e on a.tipo = e.valorparam and e.claveparam='1' LEFT JOIN bdinteg:""informix"".si_ciudades g ON a.ciudad = g.ciudad  AND a.estado = g.estado AND b.cve_localidad = g.localidad_inegi  LEFT JOIN bdinteg:""informix"".si_localidades f ON a.estado = f.cve_estado AND b.cve_mun = f.cve_mun AND b.cve_localidad = f.cve_localidad_cnbv AND b.cp=f.cp AND b.cve_col=f.cve_col LEFT JOIN bdinteg:""informix"".si_paramptf h ON a.tpo_sucursal =h.valorparam AND h.claveparam='8' ";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE b.tipo IN ('A','B','I','O','S','X') ORDER BY a.sucursal )" ;

		LET dFechaHoy = CURRENT;
		LET cFechaHoraArchivo = YEAR(dFechaHoy)||LPAD(MONTH(dFechaHoy),2,0)||LPAD(DAY(dFechaHoy),2,0);
		
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR		
		
		LET cNombreArchivo = 'REPORTE_CENTRO_COSTOS_'||TRIM(cFechaHoraArchivo)||'.txt';
		
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
                      
                        LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
                        
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de línea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el archivo original
                        LET cSql = '';
                        LET cSql = "rm -rf "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el caracter delimitador ';' al final de la línea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de línea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);


                       
        LET cBanDetError = 't';


				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
					
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Daniel Reyes Guillen',
'FECHA: 01/07/2021',
'DESCRIPCION: SPL que genera el Reporte sucursales',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_fc_traspasoctascap(pUsuario CHAR(8),pIdFuncion CHAR(10),pCteTitular CHAR(20),pCteTraspasaCtas CHAR(20),pUsEjecuta CHAR(8))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRetSp CHAR(100);
	DEFINE cEmpresa CHAR(3);
	DEFINE cValor CHAR(100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRetSp = '';
	LET cEmpresa = '001';
	LET cValor = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_fc_traspasoctascap.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_traspasocuentas_cap_soc(pCteTitular,pCteTraspasaCtas,pUsEjecuta) 
		INTO cCodRetSp,cDescCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION cCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdinteg:sp_traspasocuentas_cap_soc';
		ELIF iCodRetSp = 99999 THEN
			LET cCodRet = '01195'; --PARÃMETROS INVÃLIDOS
		ELIF iCodRetSp = 100 THEN
			LET cCodRet = '01196'; --CLIENTE TITULAR/CLIENTE TRASPASAR ES UN CLIENTE MORAL
		ELIF iCodRetSp = 200 THEN
			LET cCodRet = '01197'; --CLIENTE A TRASPASAR CON ADEUDO IDE, NO SE PUEDE EFECTUAR LA FUSIÃN
		ELIF iCodRetSp = 300 THEN
			LET cCodRet = '01198'; --CLIENTE CON BANCA EN INTERNET, NO SE PUEDE EFECTUAR LA FUSIÃN
		ELIF iCodRetSp = 400 THEN
			LET cCodRet = '01199'; --CLIENTE FUSIONADO, NO SE PUEDE EFECTUAR LA FUSIÃN
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/05/2020',
'MODULO: CLIENTES',
'FUNCIONALIDAD: FUSION MANUAL DE CLIENTES',
'DESCRIPCION: SPL encargado de realizar el traspaso de cuentas cap.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_genrepaltactesacum()
    RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cStr8 CHAR(60);
	DEFINE dFecha DATE;
	DEFINE dFecha_insert DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cPromotor CHAR(8);
	DEFINE cNumcte CHAR(20);	
	DEFINE cNumcte_coppel CHAR(20);	
	DEFINE cTipoCte CHAR(20);	
	DEFINE cTpo_biometria CHAR(1);
	DEFINE cTpo_biometria_desc CHAR(10);
	DEFINE iCont INTEGER;
	DEFINE iRegCommit INTEGER;
	DEFINE cSituacion CHAR(1);
	DEFINE cPaso_por_id_box CHAR(10);
	DEFINE cCapturo_huellas_morpho CHAR(10);
	DEFINE cCodidentifi CHAR(2);
	DEFINE cDescidentifi CHAR(50);
	DEFINE cSit_esp_desc CHAR(75);
	DEFINE sCausa SMALLINT;
	DEFINE sCountPaso_por_id_box SMALLINT;
	DEFINE sCountCapturo_huellas_morpho SMALLINT;
	DEFINE cTel_cel CHAR(13);
	DEFINE cEst_tel_cel CHAR(15);
	DEFINE cTel_cas CHAR(13);
	DEFINE cEst_tel_cas CHAR(15);
	DEFINE pRutaDescarga CHAR(100);

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cStr8 = ''; 
	LET dFecha = '';
	LET dFecha_insert = '';
	LET cSucursal = '';
	LET cPromotor	= '';			
	LET cNumcte	= '';				
	LET cNumcte_coppel = '';
	LET cTipoCte	= '';
	LET cTpo_biometria = '';	
	LET cTpo_biometria_desc = '';
	LET iCont = 0;
	LET iRegCommit = 500;
	LET cSituacion = '';
	LET cPaso_por_id_box = 'NO';
	LET cCapturo_huellas_morpho = 'NO';
	LET cCodidentifi = '';
	LET cDescidentifi = '';
	LET cSit_esp_desc = '';
	LET sCausa = 0;
	LET sCountPaso_por_id_box = 0;
	LET sCountCapturo_huellas_morpho = 0;
	LET cTel_cel = '';
	LET cEst_tel_cel = '';
	LET cTel_cas = '';
	LET cEst_tel_cas = '';
	LET pRutaDescarga = '/RESPALDOSNEW';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/ifxsif01/Control-M/sp_cnsif_genrepaltactesacum.out';
		--SET DEBUG FILE TO '/informix/jagl/bdicnweb/sp_cnsif_genrepaltactesacum.out';
		--TRACE ON;
		
		IF pRutaDescarga = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		LET cStr8 = 'ALTA_CLIENTES_ACUMULADO';   
		LET dFechaHoy = TODAY-1;		LET dHoraHoy = TODAY-1;		LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
		LET cNombreArchivo = 'ALTA_CLIENTES_ACUMULADO_'||TRIM(cFechaHoraArchivo)||'.xls';
		
		--- Depuracion tablas
		TRUNCATE TABLE "informix".sw_alta_clientes_acumulado;


		---Extraccion de informacion
		
		--Clientes tipo Upgrade
		LET iCont = 0;
		BEGIN WORK;				
		FOREACH WITH HOLD
					
			SELECT 
			DISTINCT cliente
			INTO cNumcte
			FROM bdidigital@coppelimg_tcp:dg_expediente ex
			INNER JOIN bdinteg:"informix".si_cliente cte
				ON ex.cliente = cte.numcte
			WHERE ex.empresa = cEmpresa
			AND ex.cod_docto IN ('0012','0015','0016','0017','0018','0031','0032','0033','0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')
			AND ex.secuencia = 1
			AND ex.fecha_alta = TODAY-1
			AND ex.prod_nombre IN ('ALTA CLIENTES', 'ALTA CLIENTES MENORES DE EDAD')
			AND ex.cuenta = '99999999999'
			AND cte.tipo_cliente = '1'
			AND cte.tpo_persona='01'
			AND cte.fecha_alta = TODAY-1
			AND cte.fecha_insert <> TODAY-1
			AND NOT EXISTS
			(
				SELECT 1 FROM bdidigital@coppelimg_tcp:dg_expediente ex2
				WHERE ex2.cliente = ex.cliente
				AND ex2.empresa = cEmpresa
				AND ex2.cod_docto IN ('0012','0015','0016','0017','0018','0031','0032','0033','0001','0003','0013','0014','0022','0027','0028','0029','0030','0939','0940','0047','0048','0049','0050','0061','0083','0084','0085','0086','0087','0088','0089','0090','0091','0092','0938')
				AND ex2.secuencia = 1
				AND ex2.fecha_alta < TODAY-1
				AND ex2.prod_nombre IN ('ALTA CLIENTES', 'ALTA CLIENTES MENORES DE EDAD')
				AND ex2.cuenta = '99999999999'
			)
			
			
			SELECT 
				  a.fecha_insert
				, a.fecha_alta
				, a.sucursal
				, a.ejecutivo
				, a.numcte
				, 'Upgrade'
				, a.tpo_biometria
				, pf.codidentifi
			INTO 
				  dFecha_insert
				, dFecha
				, cSucursal
				, cPromotor
				, cNumcte
				, cTipoCte 
				, cTpo_biometria
				, cCodidentifi
			FROM  
				bdinteg:"informix".si_cliente AS a
				LEFT JOIN bdinteg:"informix".si_ctepf AS pf ON a.numcte = pf.numcte
			WHERE 
				a.numcte = cNumcte
			;
			
			--Se obtiene cTpo_biometria_desc
			IF cTpo_biometria IS NOT NULL AND cTpo_biometria != '' THEN
				IF cTpo_biometria = '1' THEN
					LET cTpo_biometria_desc = 'SI';
				ELIF cTpo_biometria = '0' THEN
					LET cTpo_biometria_desc = 'NO';
				ELSE
					LET cTpo_biometria_desc = 'N/A';
				END IF;
			ELSE
				LET cTpo_biometria_desc = 'N/A';
			END IF;
			
			--Se obtiene cNumcte_coppel
			SELECT 
				cliente
			INTO 
				cNumcte_coppel
			FROM
				bdinteg:"informix".si_relacion_ctebcplcpl
				where numcte_banco = cNumcte--'000006810'
				AND empresa='001'
			;

			--Se obtiene cSituacion y sCausa
			SELECT 
			      situacion
				, causa
			INTO
				  cSituacion
				, sCausa
			FROM 
				bdisitesp:"informix".se_ctessitespcte
			WHERE 
				numcte = cNumcte--'000452722'
			;

			--Se obtiene cSit_esp_desc 
			IF cSituacion IS NOT NULL AND cSituacion != '' AND sCausa IS NOT NULL AND sCausa!=0 THEN
				SELECT 
					descripcion
				INTO
					cSit_esp_desc
				FROM 
					bdisitesp:"informix".se_catsitesp
				WHERE
					situacion = cSituacion--'A'
					AND causa = sCausa--1
				;
			END IF;
			
			--Se obtiene cDescidentifi
			IF cCodidentifi IS NOT NULL AND cCodidentifi != '' THEN
				SELECT
					descripcion
				INTO
					cDescidentifi
				FROM
					bdinteg:"informix".si_tipoidentif
				WHERE
					codidentif = cCodidentifi--'A'
				;
			END IF;

			IF cCodidentifi IS NOT NULL AND cCodidentifi=='A' THEN
				--Se obtiene cPaso_por_id_box
				SELECT 
					{+INDEX (bdinteg:"informix".si_bitacora_ife "informix".idx_bitife)}
					COUNT(*)
				INTO
					sCountPaso_por_id_box
				FROM
					bdinteg:"informix".si_bitacora_ife
				WHERE 
					numcte=cNumcte--'074740258'
				;
				IF sCountPaso_por_id_box IS NOT NULL AND sCountPaso_por_id_box >0 THEN
					LET cPaso_por_id_box = 'SI';
				END IF;
			END IF;
			
			--Se obtiene cCapturo_huellas_morpho
			SELECT 
				{+AVOID_FULL (bdinteg:"informix".si_cte_huella_dec)}
				COUNT(*)
			INTO
				sCountCapturo_huellas_morpho
			FROM
				bdinteg:"informix".si_cte_huella_dec
			WHERE 
				numcte=cNumcte--'072622355'
			;
			IF sCountCapturo_huellas_morpho IS NOT NULL AND sCountCapturo_huellas_morpho >0 THEN
				LET cCapturo_huellas_morpho = 'SI';
			END IF;
			
			--Se obtiene cTel_cel y cEst_tel_cel
			FOREACH
				SELECT FIRST 1 telefono, verificado 
				INTO cTel_cel, cEst_tel_cel
				FROM bdinteg:"informix".si_telefonos WHERE tipo_tel = 2 AND numcte = cNumcte AND status_tel='A' ORDER BY secuencia DESC
				
				IF (cEst_tel_cel IS NULL OR (NVL(cEst_tel_cel,'') = '') OR cEst_tel_cel = 'F') THEN
					LET cEst_tel_cel = 'NO CONFIRMADO';
				ELIF (cEst_tel_cel = 'V') THEN
					LET cEst_tel_cel = 'CONFIRMADO';
				END IF;
			END FOREACH;

			--Se obtiene cTel_cas y cEst_tel_cas
			FOREACH
				SELECT FIRST 1 telefono, verificado 
				INTO cTel_cas, cEst_tel_cas
				FROM bdinteg:"informix".si_telefonos WHERE tipo_tel = 1 AND numcte = cNumcte AND status_tel='A' ORDER BY secuencia DESC
				
				IF (cEst_tel_cas IS NULL OR (NVL(cEst_tel_cas,'') = '') OR cEst_tel_cas = 'F') THEN
					LET cEst_tel_cas = 'NO CONFIRMADO';
				ELIF (cEst_tel_cas = 'V') THEN
					LET cEst_tel_cas = 'CONFIRMADO';
				END IF;
			END FOREACH;
			
			
			LET iCont = iCont + 1;
			IF (TRIM(cSituacion)||TRIM(TO_CHAR(sCausa))) <> "R1" THEN
				INSERT INTO "informix".sw_alta_clientes_acumulado
					(fecha_insert, fecha_alta, sucursal, ejecutivo, numcte, numcte_coppel, tipo_cliente, situacion, causa, sit_esp_desc, tpo_biometria, tpo_biometria_desc, codidentifi, descidentifi, paso_por_id_box, capturo_huellas_morpho, tel_cel, est_tel_cel, tel_cas, est_tel_cas)
				VALUES
					(dFecha_insert, dFecha, cSucursal, cPromotor, cNumcte, cNumcte_coppel, cTipoCte, cSituacion, sCausa, cSit_esp_desc, cTpo_biometria, cTpo_biometria_desc, cCodidentifi, cDescidentifi, cPaso_por_id_box, cCapturo_huellas_morpho, cTel_cel, cEst_tel_cel, cTel_cas, cEst_tel_cas);
			END IF;
			
			LET dFecha =  '';
			LET dFecha_insert =  '';
			LET cSucursal =  '';
			LET cPromotor =  '';
			LET cNumcte =  '';
			LET cNumcte_coppel =  '';
			LET cTipoCte =  '';
			LET cSituacion = '';
			LET cSit_esp_desc = '';
			LET sCausa = 0;
			LET cTpo_biometria = '';	
			LET cTpo_biometria_desc = '';
			LET cCodidentifi = '';
			LET cDescidentifi = '';
			LET cPaso_por_id_box = 'NO';
			LET cCapturo_huellas_morpho = 'NO';
			LET sCountPaso_por_id_box = 0;
			LET sCountCapturo_huellas_morpho = 0;
			LET cTel_cel = '';
			LET cEst_tel_cel = '';
			LET cTel_cas = '';
			LET cEst_tel_cas = '';

			
			IF iCont >= iRegCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
		END FOREACH;
		COMMIT WORK;
		
		--Clientes tipo 1 y tipo 2
		LET iCont = 0;
		BEGIN WORK;				
		FOREACH WITH HOLD
												
			SELECT 
				  a.fecha_insert
				, a.fecha_alta
				, a.sucursal
				, a.ejecutivo
				, a.numcte
				, a.tipo_cliente
				, a.tpo_biometria
				, pf.codidentifi
			INTO 
				  dFecha_insert
				, dFecha
				, cSucursal
				, cPromotor
				, cNumcte
				, cTipoCte 
				, cTpo_biometria
				, cCodidentifi
			FROM  bdinteg:"informix".si_cliente AS a
			LEFT JOIN bdinteg:"informix".si_ctepf AS pf ON a.numcte = pf.numcte
			WHERE a.fecha_insert = TODAY-1
			AND a.tpo_persona='01'
	
			--Se obtiene cTpo_biometria_desc
			IF cTpo_biometria IS NOT NULL AND cTpo_biometria != '' THEN
				IF cTpo_biometria = '1' THEN
					LET cTpo_biometria_desc = 'SI';
				ELIF cTpo_biometria = '0' THEN
					LET cTpo_biometria_desc = 'NO';
				ELSE
					LET cTpo_biometria_desc = 'N/A';
				END IF;
			ELSE
				LET cTpo_biometria_desc = 'N/A';
			END IF;

			--Se obtiene cNumcte_coppel
			SELECT 
				cliente
			INTO 
				cNumcte_coppel
			FROM
				bdinteg:"informix".si_relacion_ctebcplcpl
				where numcte_banco = cNumcte--'000006810'
				AND empresa='001'
			;

			--Se obtiene cSituacion y sCausa
			SELECT 
			      situacion
				, causa
			INTO
				  cSituacion
				, sCausa
			FROM 
				bdisitesp:"informix".se_ctessitespcte
			WHERE 
				numcte = cNumcte--'000452722'
			;

			--Se obtiene cSit_esp_desc 
			IF cSituacion IS NOT NULL AND cSituacion != '' AND sCausa IS NOT NULL AND sCausa!=0 THEN
				SELECT 
					descripcion
				INTO
					cSit_esp_desc
				FROM 
					bdisitesp:"informix".se_catsitesp
				WHERE
					situacion = cSituacion--'A'
					AND causa = sCausa--1
				;
			END IF;
			
			--Se obtiene cDescidentifi
			IF cCodidentifi IS NOT NULL AND cCodidentifi != '' THEN
				SELECT
					descripcion
				INTO
					cDescidentifi
				FROM
					bdinteg:"informix".si_tipoidentif
				WHERE
					codidentif = cCodidentifi--'A'
				;
			END IF;

			IF cCodidentifi IS NOT NULL AND cCodidentifi=='A' THEN
				--Se obtiene cPaso_por_id_box
				SELECT 
					{+INDEX (bdinteg:"informix".si_bitacora_ife "informix".idx_bitife)}
					COUNT(*)
				INTO
					sCountPaso_por_id_box
				FROM
					bdinteg:"informix".si_bitacora_ife
				WHERE 
					numcte=cNumcte--'074740258'
				;
				IF sCountPaso_por_id_box IS NOT NULL AND sCountPaso_por_id_box >0 THEN
					LET cPaso_por_id_box = 'SI';
				END IF;
			END IF;
			
			--Se obtiene cCapturo_huellas_morpho
			SELECT 
				{+AVOID_FULL (bdinteg:"informix".si_cte_huella_dec)}
				COUNT(*)
			INTO
				sCountCapturo_huellas_morpho
			FROM
				bdinteg:"informix".si_cte_huella_dec
			WHERE 
				numcte=cNumcte--'072622355'
			;
			IF sCountCapturo_huellas_morpho IS NOT NULL AND sCountCapturo_huellas_morpho >0 THEN
				LET cCapturo_huellas_morpho = 'SI';
			END IF;

			--Se obtiene cTel_cel y cEst_tel_cel
			FOREACH
				SELECT FIRST 1 telefono, verificado 
				INTO cTel_cel, cEst_tel_cel
				FROM bdinteg:"informix".si_telefonos WHERE tipo_tel = 2 AND numcte = cNumcte AND status_tel='A' ORDER BY secuencia DESC
				
				IF (cEst_tel_cel IS NULL OR (NVL(cEst_tel_cel,'') = '') OR cEst_tel_cel = 'F') THEN
					LET cEst_tel_cel = 'NO CONFIRMADO';
				ELIF (cEst_tel_cel = 'V') THEN
					LET cEst_tel_cel = 'CONFIRMADO';
				END IF;
			END FOREACH;

			--Se obtiene cTel_cas y cEst_tel_cas
			FOREACH
				SELECT FIRST 1 telefono, verificado 
				INTO cTel_cas, cEst_tel_cas
				FROM bdinteg:"informix".si_telefonos WHERE tipo_tel = 1 AND numcte = cNumcte AND status_tel='A' ORDER BY secuencia DESC
				
				IF (cEst_tel_cas IS NULL OR (NVL(cEst_tel_cas,'') = '') OR cEst_tel_cas = 'F') THEN
					LET cEst_tel_cas = 'NO CONFIRMADO';
				ELIF (cEst_tel_cas = 'V') THEN
					LET cEst_tel_cas = 'CONFIRMADO';
				END IF;
			END FOREACH;

			LET iCont = iCont + 1;

			IF (TRIM(cSituacion)||TRIM(TO_CHAR(sCausa))) <> "R1" THEN
				INSERT INTO "informix".sw_alta_clientes_acumulado
					(fecha_insert, fecha_alta, sucursal, ejecutivo, numcte, numcte_coppel, tipo_cliente, situacion, causa, sit_esp_desc, tpo_biometria, tpo_biometria_desc, codidentifi, descidentifi, paso_por_id_box, capturo_huellas_morpho, tel_cel, est_tel_cel, tel_cas, est_tel_cas)
				VALUES
					(dFecha_insert, dFecha, cSucursal, cPromotor, cNumcte, cNumcte_coppel, cTipoCte, cSituacion, sCausa, cSit_esp_desc, cTpo_biometria, cTpo_biometria_desc, cCodidentifi, cDescidentifi, cPaso_por_id_box, cCapturo_huellas_morpho, cTel_cel, cEst_tel_cel, cTel_cas, cEst_tel_cas);
			END IF;
			
			LET dFecha =  '';
			LET dFecha_insert =  '';
			LET cSucursal =  '';
			LET cPromotor =  '';
			LET cNumcte =  '';
			LET cNumcte_coppel =  '';
			LET cTipoCte =  '';
			LET cSituacion = '';
			LET cSit_esp_desc = '';
			LET sCausa = 0;
			LET cTpo_biometria = '';	
			LET cTpo_biometria_desc = '';
			LET cCodidentifi = '';
			LET cDescidentifi = '';
			LET cPaso_por_id_box = 'NO';
			LET cCapturo_huellas_morpho = 'NO';
			LET sCountPaso_por_id_box = 0;
			LET sCountCapturo_huellas_morpho = 0;
			LET cTel_cel = '';
			LET cEst_tel_cel = '';
			LET cTel_cas = '';
			LET cEst_tel_cas = '';

			
			IF iCont >= iRegCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
		END FOREACH;
		COMMIT WORK;


		--Clientes tipo 3
		LET iCont = 0;
		BEGIN WORK;				
		FOREACH WITH HOLD

			SELECT 
				  a.fecha_insert
				, a.fecha_alta
				, a.sucursal
				, a.ejecutivo
				, a.numcte_pros
				, a.tipo_cliente
				, ''--tpo_biometria
				, ''--codidentifi
			INTO 
				  dFecha_insert
				, dFecha
				, cSucursal
				, cPromotor
				, cNumcte
				, cTipoCte 
				, cTpo_biometria
				, cCodidentifi
			FROM  
				bdiprospectos:"informix".pr_cliente AS a
			WHERE
				a.fecha_insert = TODAY-1
				and a.numcte =''
				and a.tpo_persona='01'
			
			LET iCont = iCont + 1;

			INSERT INTO "informix".sw_alta_clientes_acumulado
				(fecha_insert, fecha_alta, sucursal, ejecutivo, numcte, numcte_coppel, tipo_cliente, situacion, causa, sit_esp_desc, tpo_biometria, tpo_biometria_desc, codidentifi, descidentifi, paso_por_id_box, capturo_huellas_morpho, tel_cel, est_tel_cel, tel_cas, est_tel_cas)
			VALUES
				(dFecha_insert, dFecha, cSucursal, cPromotor, cNumcte, cNumcte_coppel, cTipoCte, cSituacion, sCausa, cSit_esp_desc, cTpo_biometria, cTpo_biometria_desc, cCodidentifi, cDescidentifi, cPaso_por_id_box, cCapturo_huellas_morpho, cTel_cel, cEst_tel_cel, cTel_cas, cEst_tel_cas);
		  
			LET dFecha =  '';
			LET dFecha_insert =  '';
			LET cSucursal =  '';
			LET cPromotor =  '';
			LET cNumcte =  '';
			LET cNumcte_coppel =  '';
			LET cTipoCte =  '';
			LET cSituacion = '';
			LET cSit_esp_desc = '';
			LET sCausa = 0;
			LET cTpo_biometria = '';	
			LET cTpo_biometria_desc = '';
			LET cCodidentifi = '';
			LET cDescidentifi = '';
			LET cPaso_por_id_box = 'NO';
			LET cCapturo_huellas_morpho = 'NO';
			LET sCountPaso_por_id_box = 0;
			LET sCountCapturo_huellas_morpho = 0;
			LET cTel_cel = '';
			LET cEst_tel_cel = '';
			LET cTel_cas = '';
			LET cEst_tel_cas = '';
			
			
			IF iCont >= iRegCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
		END FOREACH;
		COMMIT WORK;
		
		LET cCmd1 = " SELECT 'FECHA DE ALTA','SUCURSAL MATRIZ','NO PROMOTOR','NO CLIENTE BANCO','NO CLIENTE COPPEL','TIPO DE CLIENTE','SITUACION ESPECIAL','BIOMETRIA','TIPO DE ID','PASO POR ID BOX','CAPTURA DE HUELLAS CON MORPHO', 'TELEFONO CASA', 'ESTATUS TELEFONO DE CASA','TELEFONO CELULAR','ESTATUS TELEFONO CELULAR'"
					|| " FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "
					|| " SELECT TO_CHAR(fecha_alta, '%d/%m/%Y'), ''''||sucursal, ejecutivo, ''''||numcte, numcte_coppel, tipo_cliente, sit_esp_desc, tpo_biometria_desc, descidentifi, paso_por_id_box, capturo_huellas_morpho, tel_cas, est_tel_cas, tel_cel, est_tel_cel"
					|| " FROM bdicnweb:""informix"".sw_alta_clientes_acumulado"
					|| " ORDER BY id_serial ASC)";
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query_reporte_alta_clientes_acumulado.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query_reporte_alta_clientes_acumulado.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query_reporte_alta_clientes_acumulado.sql';
--			LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query_reporte_alta_clientes_acumulado.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query_reporte_alta_clientes_acumulado.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la linea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de linea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			
		COMMIT WORK;
		
		
		LET ven_transacc = 0;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 21/07/2020',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: EXTRACCION DE REPORTES',
'DESCRIPCION: SPL encargado generar el reporte \\fscdmx.banco.int\SopPorSuc\ALTA_CLIENTES_ACUMULADO_DDMMYYYY_HHMM.xls',
'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 24/07/2020',
'Modificacion: Se modifica logica para obtener los numeros telefonicos y si estan confirmados mediante la tabla si_telefonos y mediante el campo verificado de dicha tabla',
'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 25/08/2020',
'Modificacion: Se agrega validacion para solo contemplar personas fisicas y se agrega validacion para solo tomar en cuenta telefonos activos',
'BD: bdicnweb',
'AUTOR: Paul Antonio Garcia Gastelum',
'FECHA 21/02/2022',
'Modificacion: Se agrega validacion para contemplar las situaciones especiales de biometria facial a exepcion de "R1 Rostro pendiente de comparacion"',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consdatahorros(pUsuario char(8),pIdFuncion CHAR(10),pcuenta_eje CHAR(20),pcuenta_sd CHAR(20))
RETURNING 	     	CHAR(5)  AS Cod_Retorno,
					DATE AS Fecha_creacion,
					DATE AS Fecha_finalizacion,
					CHAR(10) AS Periodicidad;


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
DEFINE vcuenta_eje		CHAR(11);
DEFINE vproducto		SMALLINT;
DEFINE vestatus			SMALLINT;

DEFINE cCuenta_relacionada	CHAR(20);
DEFINE cNombre_ahorro  	CHAR(18);
DEFINE cEstatus_ahorro	CHAR(12);
DEFINE cMonto_objetivo	MONEY (14,2);
DEFINE cFecha_creacion	DATE;
DEFINE cFecha_finalizacion	DATE;
DEFINE cPeriodicidad	CHAR(10);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vsqlerr    = 0;
LET scod_ret = "00000";
LET cCuenta_relacionada	="";
LET cNombre_ahorro  ="";
LET cEstatus_ahorro	="";
LET cMonto_objetivo	="";
LET cFecha_creacion ="";
LET cFecha_finalizacion="";
LET cPeriodicidad="";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,cFecha_creacion,cFecha_finalizacion,cPeriodicidad;
	END IF;
END EXCEPTION;

 -- Valida Parametros de Entrada

  IF pUsuario 	='' OR pIdFuncion	='' OR pcuenta_eje = "" OR pcuenta_sd="" THEN
     LET scod_ret = "00003";
     RETURN scod_ret,cFecha_creacion,cFecha_finalizacion,cPeriodicidad;
  END IF;

 -- Valida Parametros de Entrada
 
--VALIDACION
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario,pIdFuncion)
	INTO
	scod_ret;
	IF (scod_ret != '00000')  THEN
		RETURN scod_ret,cFecha_creacion,cFecha_finalizacion,cPeriodicidad;
	END IF;
-- TERMINA VALIDACION	
  
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

    
		select 
			sd.cuenta_eje cuenta_relacionada,
			sd.nombre_sd nombre_ahorro,
			INITCAP(est.descripcion) estatus_ahorro,
			sd.monto_meta monto_objetivo,
			sd.fecha_creacion,
			sd.fecha_meta fecha_finalizacion,
			INITCAP(per.descripcion) periodicidad
		into cCuenta_relacionada,cNombre_ahorro,cEstatus_ahorro,cMonto_objetivo,cFecha_creacion,cFecha_finalizacion,cPeriodicidad
		from bdicheq:"informix".sc_mae_sd sd
		inner join bdicheq:"informix".sc_est_sd est on sd.estatus=est.id
		inner join bdicheq:"informix".sc_peri_sd per on sd.periodicidad=per.id
		where sd.estatus=1
			and TRIM(sd.cuenta_eje)=pcuenta_eje and TRIM(sd.cuenta_sd)=pCuenta_sd;

	IF cCuenta_relacionada IS NULL OR cCuenta_relacionada = "" THEN
		LET scod_ret='00017'; --Sin resultados
	END IF;
	RETURN scod_ret,cFecha_creacion,cFecha_finalizacion,cPeriodicidad;
END	
END PROCEDURE
DOCUMENT
"AUTOR : Eder Solis Lopez",
"FUNCIONAMIENTO:Este SP regresa los datos del Ahorro+",
"FECHA : 04-11-2022",
"BD    : bdicnweb";

CREATE PROCEDURE "informix".sp_ope_consmovahorro(pUsuario char(8),pIdFuncion CHAR(10),pcuenta_eje CHAR(20),pcuenta_sd CHAR(20),pfechadel DATE,pfechaal DATE,pRegistros INTEGER,pRecuperacion INTEGER)
RETURNING 	     	CHAR(5)  AS Cod_Retorno,
					DATE AS Fecha,
					CHAR(10)  AS Folio,
					MONEY (14,2) AS Importe,
					CHAR(19) AS Referencia;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
DEFINE vcuenta_eje		CHAR(11);
DEFINE vproducto		SMALLINT;
DEFINE vestatus			SMALLINT;
DEFINE iTotalRegistros	INTEGER;

DEFINE cFecha			DATE;
DEFINE cFolio			CHAR(10);
DEFINE cImporte			MONEY (14,2);
DEFINE cReferencia  	CHAR(19);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vsqlerr    = 0;
LET scod_ret = "00000";
LET iTotalRegistros = 0;
LET cFecha	="";
LET cFolio  ="";
LET cImporte	="";
LET cReferencia	="";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,cFecha,cFolio,cImporte,cReferencia;
	END IF;
END EXCEPTION;

 -- Valida Parametros de Entrada
  IF pUsuario 	='' OR pIdFuncion	='' OR pcuenta_eje = "" OR pcuenta_sd="" OR pfechadel="" OR pfechaal="" OR pRegistros="" OR pRecuperacion="" THEN
     LET scod_ret = "00003";
     RETURN scod_ret,cFecha,cFolio,cImporte,cReferencia;
  END IF;
  
	IF pRegistros<0 OR pRecuperacion<=0 THEN
        LET scod_ret='00098';
        RETURN scod_ret,cFecha,cFolio,cImporte,cReferencia;
    END IF;  

 -- Valida Parametros de Entrada
 
  --VALIDACION
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
	INTO
	scod_ret;
	IF (scod_ret != '00000')  THEN
		RETURN scod_ret,cFecha,cFolio,cImporte,cReferencia;
	END IF;
-- TERMINA VALIDACION	
  
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 


	FOREACH
		select SKIP pRegistros FIRST pRecuperacion
			mov.fecha_operacion fecha,
			mov.folio,
			CAST(mov.monto as MONEY(14,2)) importe,
			TRIM(tmov.descripcion)||' '||LOWER(taho.descripcion) referencia
		into cFecha,cFolio,cImporte,cReferencia
		from bdicheq:"informix".sc_mae_sd sd
		inner join bdicheq:"informix".sc_mov_sd mov on sd.cuenta_eje=mov.cuenta_eje and sd.cuenta_sd=mov.cuenta_sobre
		inner join bdicheq:"informix".sc_tmov_sd tmov on mov.tipo_movimiento=tmov.id
		inner join bdicheq:"informix".sc_tipo_ahor taho on mov.canal=taho.id
		where TRIM(sd.cuenta_eje)=pcuenta_eje and TRIM(sd.cuenta_sd)=pcuenta_sd
			and mov.fecha_operacion>=pfechadel and mov.fecha_operacion<=pfechaal
		order by mov.fecha_operacion,mov.folio
		
		LET iTotalRegistros = iTotalRegistros+1;
		RETURN scod_ret,cFecha,cFolio,cImporte,cReferencia WITH RESUME;
	END FOREACH;

	IF iTotalRegistros=0 AND pRegistros=0 THEN
		LET scod_ret='00017'; -- El sobre no tiene movimientos
		RETURN scod_ret,cFecha,cFolio,cImporte,cReferencia;
	ELIF iTotalRegistros=0 AND pRegistros>0 THEN
		LET scod_ret='1001'; 
		RETURN scod_ret,cFecha,cFolio,cImporte,cReferencia;
	END iF;
	
END
END PROCEDURE
DOCUMENT
"AUTOR : Eder Solis Lopez",
"FUNCIONAMIENTO:Este SP regresa los movimientos del Ahorro+",
"FECHA : 04-11-2022",
"BD    : bdicnweb";

CREATE PROCEDURE "informix".sp_ope_consmovahorro_totales(pUsuario char(8),pIdFuncion CHAR(10),pcuenta_eje CHAR(20),pcuenta_sd CHAR(20),pfechadel DATE,pfechaal DATE)
RETURNING 	     	CHAR(5)  AS Cod_Retorno,
					INTEGER AS Total;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
DEFINE cTotal		SMALLINT;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vsqlerr    = 0;
LET scod_ret = "00000";
LET cTotal = -1;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,cTotal;
	END IF;
END EXCEPTION;

 -- Valida Parametros de Entrada
  IF pUsuario 	='' OR pIdFuncion	='' OR pcuenta_eje = "" OR pcuenta_sd="" OR pfechadel="" OR pfechaal="" THEN
     LET scod_ret = "00003";
     RETURN scod_ret,cTotal;
  END IF;
  
 -- Valida Parametros de Entrada
 
  --VALIDACION
	EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion)
	INTO
	scod_ret;
	IF (scod_ret != '00000')  THEN
		RETURN scod_ret,cTotal;
	END IF;
-- TERMINA VALIDACION	
  
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

		select count(*) as total
		into cTotal
		from bdicheq:"informix".sc_mae_sd sd
		inner join bdicheq:"informix".sc_mov_sd mov on sd.cuenta_eje=mov.cuenta_eje and sd.cuenta_sd=mov.cuenta_sobre
		inner join bdicheq:"informix".sc_tmov_sd tmov on mov.tipo_movimiento=tmov.id
		inner join bdicheq:"informix".sc_tipo_ahor taho on mov.canal=taho.id
		where TRIM(sd.cuenta_eje)=pcuenta_eje and TRIM(sd.cuenta_sd)=pcuenta_sd
			and mov.fecha_operacion>=pfechadel and mov.fecha_operacion<=pfechaal;

	IF cTotal = 0 THEN
		LET scod_ret='00017'; -- El sobre no tiene movimientos
		LET cTotal = 0;
	END iF;
	RETURN scod_ret,cTotal;
END
END PROCEDURE
DOCUMENT
"AUTOR : Eder Solis Lopez",
"FUNCIONAMIENTO:Este SP regresa el total de los movimientos a regresar del Ahorro+",
"FECHA : 04-11-2022",
"BD    : bdicnweb";

CREATE PROCEDURE "informix".sp_ope_consultacomprobante(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pRemesadora CHAR(10), pFechaInicio DATE, pFechaFin DATE, pCveRemesa CHAR(20),
													pNumCliente CHAR(9), pRegistros INTEGER, pRecuperacion INTEGER, pFolioSuc CHAR(16), pHuella CHAR(1), cParam1 CHAR(50), cParam2 CHAR(100), 
													cParam3 CHAR(150))
    RETURNING CHAR(5)	AS codret,
	CHAR(3) AS numconvenio,
	CHAR(40) AS nomconvenio,
	CHAR(2) AS numcategoria,
	CHAR(20) AS num_cte,
	DATE AS fech_oper,
	CHAR(4) AS sucursal,
	CHAR(16) AS folio_suc,
	CHAR(40) AS referencia1,
	INTEGER AS totRegistros,
    CHAR(1) AS formaPago,
    MONEY AS importePago,
    CHAR(10) AS fechaInsert,
    CHAR(8) AS usuario,
    CHAR(16) AS folioSuc,
    CHAR(20) AS numCuenta,
    CHAR(16) AS numTarjeta,
    CHAR(40) AS nomSucursal,
    CHAR(40) AS nombre1Ben,
    CHAR(40) AS nombre2Ben,
    CHAR(40) AS apPaternoBen,
    CHAR(40) AS apMaternoBen,
    CHAR(20) AS numCteBen,
    CHAR(20) AS numcliente,
    CHAR(942) AS cadenaTran,
    CHAR(3) AS plaza,
    CHAR(40) AS nomPlaza,
	VARCHAR(250) AS dirCompleta,
	CHAR(100) AS nomCliente,
	CHAR(50) AS retorno1,
	CHAR(100) AS retorno2,
	CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotalReg INTEGER;
	DEFINE cNumconvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE cNumcategoria CHAR(2);
	DEFINE cNum_cte CHAR(20);
	DEFINE dFech_oper DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cFolio_suc CHAR(16);
	DEFINE cReferencia1 CHAR(40);
	DEFINE iTotRegistros INTEGER;
    DEFINE cFormaPago CHAR(1);
    DEFINE mImportePago MONEY;
    DEFINE cFechaInsert CHAR(10);
    DEFINE cUsuario CHAR(8);
    DEFINE cFolioSuc CHAR(16);
    DEFINE cNombre1Ben CHAR(40);
    DEFINE cNombre2Ben CHAR(40);
    DEFINE cApPaternoBen CHAR(40);
    DEFINE cApMaternoBen CHAR(40);
    DEFINE cNumCteBen CHAR(20);
    DEFINE cNumcliente CHAR(20);
    DEFINE cCadenaTran CHAR(942);
    DEFINE cNomSucursal CHAR(40);
    DEFINE cPlaza CHAR(3);
    DEFINE cNomPlaza CHAR(40);
    DEFINE cNumcuenta CHAR(20);
    DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cNomCliente CHAR(100);
	DEFINE cRetorno1 CHAR(50);
	DEFINE cRetorno2 CHAR(100);
	DEFINE cRetorno3 CHAR(150);

	LET cCodRet			= '00000';
	LET iSqlErr			= 0;
	LET iTotalReg = 0;
	
	LET cNumconvenio = '';
	LET cNomconvenio = '';
	LET cNumcategoria = '';
	LET cNum_cte = '';
	LET dFech_oper = '';
	LET cSucursal = '';
	LET cFolio_suc = '';
	LET cReferencia1 = '';
	LET iTotRegistros = 0;
	
    LET cFormaPago = '';
    LET mImportePago = 0;
    LET cFechaInsert = '';
    LET cUsuario = '';
    LET cFolioSuc = '';
    LET cNombre1Ben = '';
    LET cNombre2Ben = '';
    LET cApPaternoBen = '';
    LET cApMaternoBen = '';
    LET cNumCteBen = '';
    LET cNumcliente = '';
    LET cCadenaTran = '';
    LET cNomSucursal = '';
    LET cPlaza = '';
    LET cNomPlaza = '';
    LET cNumcuenta = '';
    LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cNomCliente = '';
	LET cRetorno1 = '';
	LET cRetorno2 = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
			
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacomprobante.out';
		--TRACE ON;
		
		IF pBandera = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--Realiza la consulta para el llenado del combo
		IF pBandera = '1' THEN 
		FOREACH 
		
			EXECUTE PROCEDURE bdicnweb:"informix".sp_tk_consultaremesadoras(pUsuario, pIdFuncion) 
			INTO cCodRet, cNumconvenio, cNomconvenio, cNumcategoria
							
			LET iTotalReg = iTotalReg + 1;
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3 WITH RESUME;
			
		END FOREACH;
		IF iTotalReg = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		END IF;
		
		--Reliza la consulta para obtener datos para el llenado del grid
		ELIF pBandera = '2' THEN
			FOREACH 
		
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_consmovimientos(pUsuario, pIdFuncion, pRemesadora, pFechaInicio, pFechaFin, pCveRemesa, pNumCliente, pRegistros, pRecuperacion) 
			INTO cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
				
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3 WITH RESUME;
			
		END FOREACH;
		
		ELIF pBandera = '4' THEN -- Formato Abono Ventanilla
			
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_cons_ticketAbonoVent(pUsuario, pIdFuncion, pCveRemesa, pHuella, pNumCliente) 
			INTO cCodRet, cNumconvenio, cNomconvenio, dFech_oper, cReferencia1, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolio_suc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal,
			cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		
		ELIF pBandera = '5' THEN -- Formato Efectivo Ventanilla
			
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_cons_ticketEfectivoVent(pUsuario, pIdFuncion, pCveRemesa, pHuella) 
			INTO cCodRet, cNumconvenio, cNomconvenio, dFech_oper, cReferencia1, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolio_suc, cSucursal, cNomSucursal,
			cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cNumcuenta, cNumTarjeta, cRetorno3;
			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
			
		ELIF pBandera = '6' THEN -- Formato Abono APP
			
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_cons_ticketAbonoApp(pUsuario, pIdFuncion, pCveRemesa, pFolioSuc, pHuella, pNumCliente) 
			INTO cCodRet, cNumconvenio, cNomconvenio, dFech_oper, cReferencia1, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolio_suc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal,
			cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, iTotRegistros, cFormaPago,
			mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNomSucursal, cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran,
			cPlaza, cNomPlaza, cDirCompleta, cNomCliente, cRetorno1, cRetorno2, cRetorno3;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Antonio Contreras Sanchez',
'FECHA: 03/10/2022',
'MODULO: Ticket Digital',
'FUNCIONALIDAD: Ticket Digital - Consulta Comprobante',
'DESCRIPCION: SPL Maestro encargado de ejecutar los procedimientos para la funcionalidad consulta comprbante de ticket digital';

CREATE PROCEDURE "informix".sp_tk_consultaremesadoras(pUsuario CHAR(8), pIdFuncion CHAR(10))

	RETURNING CHAR(5) AS codret,
			  CHAR(3) AS numconvenio,
			  CHAR(40) AS nomconvenio,
			  CHAR(2) AS numcategoria;
			  
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	DEFINE cNumconvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE cNumcategoria CHAR(2);

	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	LET cNumconvenio = '';
	LET cNomconvenio = '';
	LET cNumcategoria = '';
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cont_cons_retroact.out';
		--TRACE ON;
		
		IF pUsuario IS NULL OR pIdFuncion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria;
			
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria;
		END IF;
        		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT numconvenio, nomconvenio, numcategoria
			INTO cNumconvenio, cNomconvenio, cNumcategoria
			FROM bdisac:informix.sac_convenios
			WHERE numcategoria = 07 AND numconvenio IN ('004', '006', '007', '008', '009')
			
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNumcategoria WITH RESUME;
		END FOREACH;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Antonio Contreras Sanchez',
'FECHA: 27/09/2022',
'MODULO: Ticket Digital',
'FUNCIONALIDAD: Consulta',
'DESCRIPCION: SPL encargado de recuperar el listado de remesas';

CREATE PROCEDURE "informix".sp_detallestatussol_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, 
pSucursal CHAR(4), pStatus CHAR(2))
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;	
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(80);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNum_solicitud CHAR(20);
	DEFINE cSucursal CHAR(4); 
	DEFINE cNom_sucursal CHAR(40);  
	DEFINE cNom_cliente CHAR(104);
	DEFINE cStatus_solicitud CHAR(2);
	DEFINE mMonto_solicitud MONEY(14,2);  
	DEFINE mMonto_otorgado MONEY(14,2);  
	DEFINE dFecha_alta DATE;
	DEFINE dFecha_cambio_status DATE;
	DEFINE dEficiencia_pago DECIMAL(10,2);
	DEFINE iMeses_historial SMALLINT;
	DEFINE iScoring_1 SMALLINT;
	DEFINE iScoring_2 SMALLINT;
	DEFINE iTotal_scoring SMALLINT;
	DEFINE cCausa_rechazo CHAR(10);
	DEFINE iNumRegistros INTEGER;
	
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNum_solicitud = '';
	LET cSucursal = ''; 
	LET cNom_sucursal = ''; 
	LET cNom_cliente = '';
	LET cStatus_solicitud = '';
	LET mMonto_solicitud = 0.00; 
	LET mMonto_otorgado = 0.00; 
	LET dFecha_alta = '';
	LET dFecha_cambio_status = '';
	LET dEficiencia_pago = 0.00; 
	LET iMeses_historial = 0;
	LET iScoring_1 = 0;
	LET iScoring_2 = 0;
	LET iTotal_scoring = 0;
	LET cCausa_rechazo = '';
	LET iNumRegistros = 0;
	
    BEGIN
        
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
            --BEGIN;
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			COMMIT;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
  
	SET ISOLATION TO DIRTY READ;
     SET LOCK MODE TO WAIT 3;
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_detallestatussol_totales.out';
		-- TRACE ON;
		
		BEGIN;
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_verificastatusrep WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".sw_verificastatusrep(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		DELETE FROM bdicnweb:"informix".sw_detstatussol WHERE usuario_insert = pUsuario;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL OR 
		pStatus  = '' THEN
			LET cCodRet = '00003';
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			COMMIT;
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			COMMIT;
			RETURN cCodRet, iNumRegistros;
		END IF;
        COMMIT;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN;
		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".status_sol(cEmpresa,pSucursal,pFechaFin,pFechaInicio,pStatus)			
			INTO cCodRetSp, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status,  
			dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdicred:status_sol';
			END IF;
			
			LET iNumRegistros = iNumRegistros + 1;
			INSERT INTO bdicnweb:"informix".sw_detstatussol(id_registro,num_solicitud,sucursal,nom_sucursal,nom_cliente,status_solicitud,
			monto_solicitud,monto_otorgado,fecha_alta,fecha_cambio_status,eficiencia_pago,meses_historial,scoring_1,scoring_2,total_scoring,causa_rechazo,usuario_insert)
			VALUES(iNumRegistros, cNum_solicitud, cSucursal, cNom_sucursal, cNom_cliente, cStatus_solicitud, 
			mMonto_solicitud, mMonto_otorgado, dFecha_alta, dFecha_cambio_status, dEficiencia_pago, iMeses_historial, iScoring_1, iScoring_2, iTotal_scoring, cCausa_rechazo, pUsuario);	
		END FOREACH;		
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".sw_verificastatusrep
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			COMMIT;
			RETURN cCodRet, iNumRegistros;
		END IF;	
		
		UPDATE "informix".sw_verificastatusrep
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;
		COMMIT;
		RETURN cCodRet, iNumRegistros;
		
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Lucrecia Montserrat LeÃ³n Amador',
'FECHA: 03/08/2020',
'MODULO: CREDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'DESCRIPCION: SPL encargado de consultar el numero total de registros del status de la solicitud.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2020',
'DESCRIPCION: Se realiza la modificaciÃ³n a SP para quitar el parametro Sucursal como requerido.';

CREATE PROCEDURE "informix".sp_rem_generarepremesasnopagadas_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1),
pIdLimite SMALLINT, pFechaInicio DATE, pFechaFin DATE)
    RETURNING CHAR(5) AS codRet,
		INTEGER AS num_registros,
		CHAR(100) AS clave_id;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	DEFINE cAutoridad CHAR(8);
	DEFINE cReporte CHAR(35);
	DEFINE cDescripcion CHAR(100);
	DEFINE cStatus CHAR(1);
	DEFINE cDescStatus CHAR(10);
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	
	DEFINE iRegistros INTEGER;
	DEFINE iGraba INTEGER;
	DEFINE iFormatoAnt INTEGER;
	DEFINE cDato CHAR(25);
	DEFINE cDatoFormat CHAR(20);
	DEFINE cRenglon CHAR(255);
	DEFINE cFormat CHAR(11);
	DEFINE cSeleccion CHAR(255);
	DEFINE cQuery CHAR(255);
	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFechaEnv DATE;
	DEFINE cNombre1Ord CHAR(40);
	DEFINE cNombre2Ord CHAR(40);
	DEFINE cApPaternoOrd CHAR(40);
	DEFINE cApMaternoOrd CHAR(40);
	DEFINE cDireccionOrd CHAR(80);		
	DEFINE cColoniaOrd CHAR(80);    	
	DEFINE cCiudadOrd CHAR(40);			
	DEFINE cEstadoOrd CHAR(3);	
	DEFINE cPaisOrd CHAR(3);	
	DEFINE cTipoIdOrd CHAR(3);	
	DEFINE cNumeroIdOrd CHAR(20);	
	DEFINE cCiudadIdOrd CHAR(3);	
	DEFINE cPaisIdOrd CHAR(3);	
	DEFINE cMonedaOrd CHAR(3);	
	DEFINE cMontoOrigen CHAR(20);		
	DEFINE cMontoPesos CHAR(20);		
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cFechaNacimientoBen CHAR(8);
	DEFINE cDireccionBen CHAR(80);		
	DEFINE cColoniaBen CHAR(80);    	
	DEFINE cCiudadBen CHAR(40);	    	
	DEFINE cEstadoBen CHAR(40);     	
	DEFINE cTelefonoBen CHAR(15);	
	DEFINE cTipoIdBen CHAR(3);      	
	DEFINE cNumeroIdBen CHAR(20);   	
	DEFINE cNumeroIdSuc CHAR(4);
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cClaveId CHAR(100);
	DEFINE cLimite CHAR(100);
	DEFINE iNumRegistros INTEGER;
	DEFINE vtotregshist INTEGER;
	DEFINE cUsuario CHAR(8);
	DEFINE iContBorra INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	LET cAutoridad = '';
	LET cReporte = '';
	LET cDescripcion = '';
	LET cStatus = '';
	LET cDescStatus = '';
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	
	LET iRegistros = 0;
	LET iGraba = 0;
	LET iFormatoAnt = 0;
	LET cDato = '';
	LET cDatoFormat = '';
	LET cRenglon = '';
	LET cFormat = '';
	LET cSeleccion = '';
	LET cQuery = '';
	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/informix/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;

	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFechaEnv = '';
	LET cNombre1Ord = '';
	LET cNombre2Ord = '';
	LET cApPaternoOrd = '';
	LET cApMaternoOrd = '';
	LET cDireccionOrd = '';
	LET cColoniaOrd = '';
	LET cCiudadOrd = '';
	LET cEstadoOrd = '';
	LET cPaisOrd = '';
	LET cTipoIdOrd = '';
	LET cNumeroIdOrd = '';
	LET cCiudadIdOrd = '';
	LET cPaisIdOrd = '';
	LET cMonedaOrd = '';
	LET cMontoOrigen = '';
	LET cMontoPesos = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cFechaNacimientoBen = '';
	LET cDireccionBen = '';
	LET cColoniaBen = '';
	LET cCiudadBen = '';
	LET cEstadoBen = '';
	LET cTelefonoBen = '';
	LET cTipoIdBen = '';
	LET cNumeroIdBen = '';
	LET cNumeroIdSuc = '';
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cClaveId = 'REMNOPAGADAS'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cLimite = '';
	LET iNumRegistros = 0;
	LET vtotregshist = 0;
	LET cUsuario = '';
	LET iContBorra = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;		
				END IF;
				UPDATE bdicnweb:"informix".sw_statusprocesoremnopag
				SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario_insert = TRIM(pUsuario);
				
				RETURN cCodRet,NVL(iNumRegistros,0),TRIM(cClaveId);
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_generarepremesasnopagadas_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".sw_statusprocesoremnopag WHERE usuario_insert = TRIM(pUsuario);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO bdicnweb:"informix".sw_statusprocesoremnopag(clave_id,status,num_registros,error_proceso,error,usuario_insert,fechahr_insert)
		VALUES(cClaveId,'I',iNumRegistros,'N',TRIM(cCodRet),pUsuario,dFechaHora);  
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pIdLimite IS NULL OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			
			UPDATE bdicnweb:"informix".sw_statusprocesoremnopag
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario_insert = TRIM(pUsuario);
			
			RETURN cCodRet,NVL(iNumRegistros,0),TRIM(cClaveId);
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			UPDATE bdicnweb:"informix".sw_statusprocesoremnopag
			SET status = 'E', error_proceso = 'S', error = TRIM(cCodRet) WHERE usuario_insert = TRIM(pUsuario);
			
			RETURN cCodRet,NVL(iNumRegistros,0),TRIM(cClaveId);
		END IF;
		
		LET vtotregshist = 0;
		LET iContBorra = 0;
		
		-- SE LIMPIA TABLA POR USUARIO
		SELECT COUNT(*)
		INTO   vtotregshist
		FROM   bdicnweb:"informix".sw_detalleremesasnopagadas
		WHERE  usuario_insert = TRIM(pUsuario);
		
		FOREACH cursor_borra_a WITH HOLD FOR
		
			SELECT usuario_insert
			INTO   cUsuario
			FROM   bdicnweb:"informix".sw_detalleremesasnopagadas
			WHERE  usuario_insert = TRIM(pUsuario)
		
			IF iContBorra = 0 THEN
				BEGIN WORK;
			END IF;
				
			DELETE FROM "informix".sw_detalleremesasnopagadas WHERE CURRENT OF cursor_borra_a;
			LET iContBorra = iContBorra + 1;
			
			IF iContBorra = 1000 THEN
				COMMIT WORK;
				LET iContBorra = 0;
			END IF;
			
		END FOREACH;
		
		IF iContBorra < 1000 and vtotregshist > 0 THEN
			COMMIT WORK;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
		LET ven_transacc = 1;
			
		IF pIdLimite = 1 THEN
		
			LET cLimite = 'ESTADO';
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_DIA_EDO_USD','APP_DIA_EDO_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_DIA_EDO_USD','BTS_DIA_EDO_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_DIA_EDO_USD','WU_DIA_EDO_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);
			
		ELIF pIdLimite = 2 THEN
		
			LET cLimite = 'SUCURSAL';
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_DIA_SUC_USD','APP_DIA_SUC_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora 
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_DIA_SUC_USD','BTS_DIA_SUC_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_DIA_SUC_USD','WU_DIA_SUC_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);
			
		ELIF pIdLimite = 3 THEN
		
			LET cLimite = 'NO. DE TRANSACCIONES';
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_MES_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_MES_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_MES_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.firstnamesender,app.middlenamesender,app.lastnamesender,app.mothermaidennamesender,
			app.addresssender,'',app.citysender,app.statecodesender,app.countrycodesender,app.typecodesender,app.numbersender,app.issuerstatecodesender,app.issuercountrycodesender,app.currencycodeorigin,app.originamount,app.destinationamount,
			app.firstnamebenefi,app.middlenamebenefi,app.lastnamebenefi,app.mothermaidennamebenefi,rem.fechanacimiento,app.addressbenefi,'',app.citybenefi,app.statecodebenefi,
			app.homephonenumber,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_getorder AS app
			WHERE rem.numconfirmacion = app.uniquereferencenumber
			AND rem.codigo IN ('APP_MES_AUT_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha_insert = (SELECT MAX(app2.fecha_insert) FROM bdisac:"informix".sac_app_getorder AS app2 WHERE app2.uniquereferencenumber = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.nombre1_remitente,bts.nombre2_remitente,bts.ap_paterno_remitente,bts.ap_materno_remitente,
			bts.dir_remitente,'',bts.cd_remitente,bts.cod_edo_remitente,bts.cod_pais_remitente,'','','','',bts.cod_moneda_origen,bts.monto_origen,bts.monto_destino,
			bts.nombre1_benef,bts.nombre2_benef,bts.ap_paterno_benef,bts.ap_materno_benef,rem.fechanacimiento,bts.dir_benef,'',bts.ciudad_benef,bts.cod_edo_benef,
			bts.tel_benef,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_sdep AS bts
			WHERE rem.numconfirmacion = bts.num_confirmacion
			AND rem.codigo IN ('BTS_MES_AUT_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_sdep AS bts2 WHERE bts2.num_confirmacion = rem.numconfirmacion);
			
		ELIF pIdLimite = 4 THEN
		
			LET cLimite = 'MONTO DIARIO';
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_DIA_USD','APP_DIA_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_DIA_USD', 'BTS_DIA_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_DIA_USD','WU_DIA_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.firstnamesender,app.middlenamesender,app.lastnamesender,app.mothermaidennamesender,
			app.addresssender,'',app.citysender,app.statecodesender,app.countrycodesender,app.typecodesender,app.numbersender,app.issuerstatecodesender,app.issuercountrycodesender,app.currencycodeorigin,app.originamount,app.destinationamount,
			app.firstnamebenefi,app.middlenamebenefi,app.lastnamebenefi,app.mothermaidennamebenefi,rem.fechanacimiento,app.addressbenefi,'',app.citybenefi,app.statecodebenefi,
			app.homephonenumber,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_getorder AS app
			WHERE rem.numconfirmacion = app.uniquereferencenumber
			AND rem.codigo IN ('APP_DIA_AUT_USD','APP_DIA_AUT_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha_insert = (SELECT MAX(app2.fecha_insert) FROM bdisac:"informix".sac_app_getorder AS app2 WHERE app2.uniquereferencenumber = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.nombre1_remitente,bts.nombre2_remitente,bts.ap_paterno_remitente,bts.ap_materno_remitente,
			bts.dir_remitente,'',bts.cd_remitente,bts.cod_edo_remitente,bts.cod_pais_remitente,'','','','',bts.cod_moneda_origen,bts.monto_origen,bts.monto_destino,
			bts.nombre1_benef,bts.nombre2_benef,bts.ap_paterno_benef,bts.ap_materno_benef,rem.fechanacimiento,bts.dir_benef,'',bts.ciudad_benef,bts.cod_edo_benef,
			bts.tel_benef,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_sdep AS bts
			WHERE rem.numconfirmacion = bts.num_confirmacion
			AND rem.codigo IN ('BTS_DIA_AUT_USD', 'BTS_DIA_AUT_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_sdep AS bts2 WHERE bts2.num_confirmacion = rem.numconfirmacion);

		ELIF pIdLimite = 5 THEN
		
			LET cLimite = 'MONTO MENSUAL';
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_MES_USD','APP_MES_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_MES_USD', 'BTS_MES_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_MES_USD','WU_MES_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.firstnamesender,app.middlenamesender,app.lastnamesender,app.mothermaidennamesender,
			app.addresssender,'',app.citysender,app.statecodesender,app.countrycodesender,app.typecodesender,app.numbersender,app.issuerstatecodesender,app.issuercountrycodesender,app.currencycodeorigin,app.originamount,app.destinationamount,
			app.firstnamebenefi,app.middlenamebenefi,app.lastnamebenefi,app.mothermaidennamebenefi,rem.fechanacimiento,app.addressbenefi,'',app.citybenefi,app.statecodebenefi,
			app.homephonenumber,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_getorder AS app
			WHERE rem.numconfirmacion = app.uniquereferencenumber
			AND rem.codigo IN ('APP_MES_AUT_USD','APP_MES_AUT_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha_insert = (SELECT MAX(app2.fecha_insert) FROM bdisac:"informix".sac_app_getorder AS app2 WHERE app2.uniquereferencenumber = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.nombre1_remitente,bts.nombre2_remitente,bts.ap_paterno_remitente,bts.ap_materno_remitente,
			bts.dir_remitente,'',bts.cd_remitente,bts.cod_edo_remitente,bts.cod_pais_remitente,'','','','',bts.cod_moneda_origen,bts.monto_origen,bts.monto_destino,
			bts.nombre1_benef,bts.nombre2_benef,bts.ap_paterno_benef,bts.ap_materno_benef,rem.fechanacimiento,bts.dir_benef,'',bts.ciudad_benef,bts.cod_edo_benef,
			bts.tel_benef,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_sdep AS bts
			WHERE rem.numconfirmacion = bts.num_confirmacion
			AND rem.codigo IN ('BTS_MES_AUT_USD', 'BTS_MES_AUT_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_sdep AS bts2 WHERE bts2.num_confirmacion = rem.numconfirmacion);
			
		ELIF pIdLimite = 6 THEN
		
			LET cLimite = 'TODAS LAS REMESADORAS (ACUMULADO)';
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_TODAS_USD','APP_TODAS_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_TODAS_USD','BTS_TODAS_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_TODAS_USD','WU_TODAS_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);
			
		ELIF pIdLimite = 7 THEN
		
			LET cLimite = 'LISTAS NEGRAS';
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_LISTA')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_LISTA')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_LISTA')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,app.firstnamesender,app.middlenamesender,app.lastnamesender,app.mothermaidennamesender,
			app.addresssender,'',app.citysender,app.statecodesender,app.countrycodesender,app.typecodesender,app.numbersender,app.issuerstatecodesender,app.issuercountrycodesender,app.currencycodeorigin,app.originamount,app.destinationamount,
			app.firstnamebenefi,app.middlenamebenefi,app.lastnamebenefi,app.mothermaidennamebenefi,rem.fechanacimiento,app.addressbenefi,'',app.citybenefi,app.statecodebenefi,
			app.homephonenumber,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_getorder AS app
			WHERE rem.numconfirmacion = app.uniquereferencenumber
			AND rem.codigo IN ('APP_LISTA_AUT')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha_insert = (SELECT MAX(app2.fecha_insert) FROM bdisac:"informix".sac_app_getorder AS app2 WHERE app2.uniquereferencenumber = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),pIdLimite,TRIM(cLimite),rem.fecha,rem.fecha,bts.nombre1_remitente,bts.nombre2_remitente,bts.ap_paterno_remitente,bts.ap_materno_remitente,
			bts.dir_remitente,'',bts.cd_remitente,bts.cod_edo_remitente,bts.cod_pais_remitente,'','','','',bts.cod_moneda_origen,bts.monto_origen,bts.monto_destino,
			bts.nombre1_benef,bts.nombre2_benef,bts.ap_paterno_benef,bts.ap_materno_benef,rem.fechanacimiento,bts.dir_benef,'',bts.ciudad_benef,bts.cod_edo_benef,
			bts.tel_benef,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_sdep AS bts
			WHERE rem.numconfirmacion = bts.num_confirmacion
			AND rem.codigo IN ('BTS_LISTA_AUT')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_sdep AS bts2 WHERE bts2.num_confirmacion = rem.numconfirmacion);
			
		--TODOS LOS LÍMITES
		ELIF pIdLimite = 8 THEN
			
			/* ESTADO */
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),1,'ESTADO',rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_DIA_EDO_USD','APP_DIA_EDO_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),1,'ESTADO',rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_DIA_EDO_USD','BTS_DIA_EDO_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),1,'ESTADO',rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_DIA_EDO_USD','WU_DIA_EDO_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);
			
			/* SUCURSAL */
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),2,'SUCURSAL',rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_DIA_SUC_USD','APP_DIA_SUC_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),2,'SUCURSAL',rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora 
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_DIA_SUC_USD','BTS_DIA_SUC_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),2,'SUCURSAL',rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_DIA_SUC_USD','WU_DIA_SUC_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);
			
			/* NO. DE TRANSACCIONES */
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),3,'NO. DE TRANSACCIONES',rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_MES_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),3,'NO. DE TRANSACCIONES',rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_MES_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),3,'NO. DE TRANSACCIONES',rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_MES_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),3,'NO. DE TRANSACCIONES',rem.fecha,rem.fecha,app.firstnamesender,app.middlenamesender,app.lastnamesender,app.mothermaidennamesender,
			app.addresssender,'',app.citysender,app.statecodesender,app.countrycodesender,app.typecodesender,app.numbersender,app.issuerstatecodesender,app.issuercountrycodesender,app.currencycodeorigin,app.originamount,app.destinationamount,
			app.firstnamebenefi,app.middlenamebenefi,app.lastnamebenefi,app.mothermaidennamebenefi,rem.fechanacimiento,app.addressbenefi,'',app.citybenefi,app.statecodebenefi,
			app.homephonenumber,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_getorder AS app
			WHERE rem.numconfirmacion = app.uniquereferencenumber
			AND rem.codigo IN ('APP_MES_AUT_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha_insert = (SELECT MAX(app2.fecha_insert) FROM bdisac:"informix".sac_app_getorder AS app2 WHERE app2.uniquereferencenumber = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),3,'NO. DE TRANSACCIONES',rem.fecha,rem.fecha,bts.nombre1_remitente,bts.nombre2_remitente,bts.ap_paterno_remitente,bts.ap_materno_remitente,
			bts.dir_remitente,'',bts.cd_remitente,bts.cod_edo_remitente,bts.cod_pais_remitente,'','','','',bts.cod_moneda_origen,bts.monto_origen,bts.monto_destino,
			bts.nombre1_benef,bts.nombre2_benef,bts.ap_paterno_benef,bts.ap_materno_benef,rem.fechanacimiento,bts.dir_benef,'',bts.ciudad_benef,bts.cod_edo_benef,
			bts.tel_benef,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_sdep AS bts
			WHERE rem.numconfirmacion = bts.num_confirmacion
			AND rem.codigo IN ('BTS_MES_AUT_OPE')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_sdep AS bts2 WHERE bts2.num_confirmacion = rem.numconfirmacion);
			
			/* MONTO DIARIO */
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),4,'MONTO DIARIO',rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_DIA_USD','APP_DIA_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),4,'MONTO DIARIO',rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_DIA_USD', 'BTS_DIA_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),4,'MONTO DIARIO',rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_DIA_USD','WU_DIA_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),4,'MONTO DIARIO',rem.fecha,rem.fecha,app.firstnamesender,app.middlenamesender,app.lastnamesender,app.mothermaidennamesender,
			app.addresssender,'',app.citysender,app.statecodesender,app.countrycodesender,app.typecodesender,app.numbersender,app.issuerstatecodesender,app.issuercountrycodesender,app.currencycodeorigin,app.originamount,app.destinationamount,
			app.firstnamebenefi,app.middlenamebenefi,app.lastnamebenefi,app.mothermaidennamebenefi,rem.fechanacimiento,app.addressbenefi,'',app.citybenefi,app.statecodebenefi,
			app.homephonenumber,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_getorder AS app
			WHERE rem.numconfirmacion = app.uniquereferencenumber
			AND rem.codigo IN ('APP_DIA_AUT_USD','APP_DIA_AUT_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha_insert = (SELECT MAX(app2.fecha_insert) FROM bdisac:"informix".sac_app_getorder AS app2 WHERE app2.uniquereferencenumber = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),4,'MONTO DIARIO',rem.fecha,rem.fecha,bts.nombre1_remitente,bts.nombre2_remitente,bts.ap_paterno_remitente,bts.ap_materno_remitente,
			bts.dir_remitente,'',bts.cd_remitente,bts.cod_edo_remitente,bts.cod_pais_remitente,'','','','',bts.cod_moneda_origen,bts.monto_origen,bts.monto_destino,
			bts.nombre1_benef,bts.nombre2_benef,bts.ap_paterno_benef,bts.ap_materno_benef,rem.fechanacimiento,bts.dir_benef,'',bts.ciudad_benef,bts.cod_edo_benef,
			bts.tel_benef,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_sdep AS bts
			WHERE rem.numconfirmacion = bts.num_confirmacion
			AND rem.codigo IN ('BTS_DIA_AUT_USD', 'BTS_DIA_AUT_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_sdep AS bts2 WHERE bts2.num_confirmacion = rem.numconfirmacion);

			/* MONTO MENSUAL */
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),5,'MONTO MENSUAL',rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_MES_USD','APP_MES_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),5,'MONTO MENSUAL',rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_MES_USD', 'BTS_MES_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),5,'MONTO MENSUAL',rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_MES_USD','WU_MES_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),5,'MONTO MENSUAL',rem.fecha,rem.fecha,app.firstnamesender,app.middlenamesender,app.lastnamesender,app.mothermaidennamesender,
			app.addresssender,'',app.citysender,app.statecodesender,app.countrycodesender,app.typecodesender,app.numbersender,app.issuerstatecodesender,app.issuercountrycodesender,app.currencycodeorigin,app.originamount,app.destinationamount,
			app.firstnamebenefi,app.middlenamebenefi,app.lastnamebenefi,app.mothermaidennamebenefi,rem.fechanacimiento,app.addressbenefi,'',app.citybenefi,app.statecodebenefi,
			app.homephonenumber,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_getorder AS app
			WHERE rem.numconfirmacion = app.uniquereferencenumber
			AND rem.codigo IN ('APP_MES_AUT_USD','APP_MES_AUT_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha_insert = (SELECT MAX(app2.fecha_insert) FROM bdisac:"informix".sac_app_getorder AS app2 WHERE app2.uniquereferencenumber = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),5,'MONTO MENSUAL',rem.fecha,rem.fecha,bts.nombre1_remitente,bts.nombre2_remitente,bts.ap_paterno_remitente,bts.ap_materno_remitente,
			bts.dir_remitente,'',bts.cd_remitente,bts.cod_edo_remitente,bts.cod_pais_remitente,'','','','',bts.cod_moneda_origen,bts.monto_origen,bts.monto_destino,
			bts.nombre1_benef,bts.nombre2_benef,bts.ap_paterno_benef,bts.ap_materno_benef,rem.fechanacimiento,bts.dir_benef,'',bts.ciudad_benef,bts.cod_edo_benef,
			bts.tel_benef,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_sdep AS bts
			WHERE rem.numconfirmacion = bts.num_confirmacion
			AND rem.codigo IN ('BTS_MES_AUT_USD', 'BTS_MES_AUT_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_sdep AS bts2 WHERE bts2.num_confirmacion = rem.numconfirmacion);
			
			/* TODAS LAS REMESADORAS (ACUMULADO) */
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),6,'TODAS LAS REMESADORAS (ACUMULADO)',rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_TODAS_USD','APP_TODAS_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),6,'TODAS LAS REMESADORAS (ACUMULADO)',rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_TODAS_USD','BTS_TODAS_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),6,'TODAS LAS REMESADORAS (ACUMULADO)',rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_TODAS_USD','WU_TODAS_MN')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);
			
			/* LISTAS NEGRAS */
			
			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),7,'LISTAS NEGRAS',rem.fecha,rem.fecha,app.r_firstname,app.r_middlename,app.r_lastname,app.r_mommaidenname,
			app.r_address,'',app.r_city,app.r_statecode,app.r_countrycode,app.r_typecode_i,app.r_number,app.r_issstatecode,app.r_isscontrycode,app.r_currencycode,app.r_originamount,app.r_destinamount,
			app.r_firstname_b,app.r_middlename_b,app.r_lastname_b,app.r_mommaidenna_b,rem.fechanacimiento,app.r_address_b,'',app.r_city_b,app.r_statecode_b,
			app.r_homephonenum,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_qryi AS app
			WHERE rem.numconfirmacion = app.unirefnum
			AND rem.codigo IN ('APP_LISTA')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha = (SELECT MAX(app2.fecha) FROM bdisac:"informix".sac_app_qryi AS app2 WHERE app2.unirefnum = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),7,'LISTAS NEGRAS',rem.fecha,rem.fecha,bts.s_first_name,bts.s_middle_name,bts.s_last_name,bts.s_mother_m_name,
			bts.s_address,'',bts.s_city,bts.s_state_cd,bts.s_country_cd,'','','','',bts.orig_currency_cd,bts.origin_am,bts.destination_am,
			bts.r_first_name,bts.r_middle_name,bts.r_last_name,bts.r_mother_m_name,rem.fechanacimiento,bts.r_address,'',bts.r_city,bts.r_state_cd,
			bts.r_phone,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_qryi AS bts
			WHERE rem.numconfirmacion = bts.confirmation_nm
			AND rem.codigo IN ('BTS_LISTA')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_qryi AS bts2 WHERE bts2.confirmation_nm = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (WU)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),7,'LISTAS NEGRAS',rem.fecha,rem.fecha,wu.emisor_nombre1,wu.emisor_nombre2,wu.emisor_appaterno,wu.emisor_apmaterno,
			wu.emisor_calle,'',wu.emisor_ciudad,wu.emisor_edo,wu.emisor_cod_pais,'','','','',wu.emisor_cod_moneda,wu.monto_total_origen,wu.monto_total_destino,
			wu.benef_nombre1,wu.benef_nombre2,wu.benef_appaterno,wu.benef_apmaterno,--rem.fechanacimiento,
			SUBSTR(rem.fechanacimiento,5,4)||SUBSTR(rem.fechanacimiento,3,2)||SUBSTR(rem.fechanacimiento,1,2),wu.benef_calle,'',wu.benef_ciudad,wu.benef_edo,
			wu.benef_tel_part,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_wu AS rem, bdisac:"informix".sac_wu_search AS wu
			WHERE rem.numconfirmacion = wu.mtcn
			AND rem.codigo IN ('WU_LISTA')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND wu.fecha_insert = (SELECT MAX(wu2.fecha_insert) FROM bdisac:"informix".sac_wu_search AS wu2 WHERE wu2.mtcn = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (APP AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),7,'LISTAS NEGRAS',rem.fecha,rem.fecha,app.firstnamesender,app.middlenamesender,app.lastnamesender,app.mothermaidennamesender,
			app.addresssender,'',app.citysender,app.statecodesender,app.countrycodesender,app.typecodesender,app.numbersender,app.issuerstatecodesender,app.issuercountrycodesender,app.currencycodeorigin,app.originamount,app.destinationamount,
			app.firstnamebenefi,app.middlenamebenefi,app.lastnamebenefi,app.mothermaidennamebenefi,rem.fechanacimiento,app.addressbenefi,'',app.citybenefi,app.statecodebenefi,
			app.homephonenumber,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_app AS rem, bdisac:"informix".sac_app_getorder AS app
			WHERE rem.numconfirmacion = app.uniquereferencenumber
			AND rem.codigo IN ('APP_LISTA_AUT')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND app.fecha_insert = (SELECT MAX(app2.fecha_insert) FROM bdisac:"informix".sac_app_getorder AS app2 WHERE app2.uniquereferencenumber = rem.numconfirmacion);

			-- SE REALIZA EL LLENADO DE LA TABLA DESTINO (BTS AUT)
			INSERT INTO bdicnweb:"informix".sw_detalleremesasnopagadas(clave_id,id_limite,limite,fecha_env,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,
			direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,monto_origen,monto_pesos,
			nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,fechanacimiento_ben,direccion_ben,colonia_ben,ciudad_ben,estado_ben,
			telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc,usuario_insert,fechahr_insert)
			SELECT TRIM(cClaveId),7,'LISTAS NEGRAS',rem.fecha,rem.fecha,bts.nombre1_remitente,bts.nombre2_remitente,bts.ap_paterno_remitente,bts.ap_materno_remitente,
			bts.dir_remitente,'',bts.cd_remitente,bts.cod_edo_remitente,bts.cod_pais_remitente,'','','','',bts.cod_moneda_origen,bts.monto_origen,bts.monto_destino,
			bts.nombre1_benef,bts.nombre2_benef,bts.ap_paterno_benef,bts.ap_materno_benef,rem.fechanacimiento,bts.dir_benef,'',bts.ciudad_benef,bts.cod_edo_benef,
			bts.tel_benef,'','',rem.sucursal,pUsuario,dFechaHora
			FROM bdisac:"informix".sac_remesaslimitepld_bts AS rem, bdisac:"informix".sac_bts_sdep AS bts
			WHERE rem.numconfirmacion = bts.num_confirmacion
			AND rem.codigo IN ('BTS_LISTA_AUT')
			AND rem.fecha BETWEEN pFechaInicio AND pFechaFin
			AND bts.fecha_insert = (SELECT MAX(bts2.fecha_insert) FROM bdisac:"informix".sac_bts_sdep AS bts2 WHERE bts2.num_confirmacion = rem.numconfirmacion);
			
		END IF;
				
		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdicnweb:"informix".sw_detalleremesasnopagadas 
		WHERE clave_id = TRIM(cClaveId) 
		AND	usuario_insert = pUsuario 
		AND fechahr_insert = dFechaHora;

		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		IF NVL(iNumRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			UPDATE bdicnweb:"informix".sw_statusprocesoremnopag
			SET status = 'E', error_proceso = 'S', num_registros = NVL(iNumRegistros,0), error = TRIM(cCodRet) WHERE usuario_insert = TRIM(pUsuario);
		ELSE 
			UPDATE bdicnweb:"informix".sw_statusprocesoremnopag
			SET status = 'T', error_proceso = 'N', num_registros = NVL(iNumRegistros,0), error = TRIM(cCodRet) WHERE usuario_insert = TRIM(pUsuario);
		END IF;
			
		RETURN cCodRet,NVL(iNumRegistros,0),TRIM(cClaveId);
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 28/12/2017',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA DE REMESAS NO PAGADAS',
'DESCRIPCION: Spl encargado de consultar el número total de remesas no pagadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consmovimientos(pUsuario CHAR(8), pIdFuncion CHAR(10), pRemesadora CHAR(10), pFechaInicio DATE, pFechaFin DATE, pCveRemesa CHAR(20),
													pNumCliente CHAR(9), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  CHAR(3) AS numconvenio,
			  CHAR(40) AS nomconvenio,
			  CHAR(20) AS num_cte,
			  DATE AS fech_oper,
			  CHAR(4) AS sucursal,
			  CHAR(16) AS folio_suc,
			  CHAR(40) AS referencia1,
			  CHAR(100) AS nomCliente,
			  CHAR(150) AS retorno3,
			  CHAR(1) AS formaPago,
			  CHAR(8) AS usuario;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumconvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE cNum_cte CHAR(20);
	DEFINE dFech_oper DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cFolio_suc CHAR(16);
	DEFINE iTotRegistros INTEGER;
	DEFINE iTotRegistros2 INTEGER;
	DEFINE cReferencia1 CHAR(40);
	DEFINE cNomCliente CHAR(100);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cAppPaterno CHAR(26);
	DEFINE cAppMaterno CHAR(26);
	DEFINE cRetorno3 CHAR(150);
	DEFINE cFormaPago CHAR(1);
	DEFINE cUsuario CHAR(8);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumconvenio = '';
	LET cNomconvenio = '';
	LET cNum_cte = '';
	LET dFech_oper = '';
	LET cSucursal = '';
	LET cFolio_suc = '';
	LET iTotRegistros = 0;
	LET iTotRegistros2 = 0;
	LET cReferencia1 = '';
	LET cNomCliente = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cAppPaterno = '';
	LET cAppMaterno = '';
	LET cRetorno3 = '';
	LET cFormaPago = '';
	LET cUsuario = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END EXCEPTION;
	 
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consmovimientos.out';
		-- TRACE ON;
		-- SET DEBUG FILE TO '/informix/ENP/TicketDigital/informix/bdicnweb/spls/sp_ope_consmovimientos.out';
		 --TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRecuperacion IS NULL OR pRegistros IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END IF;		
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
				
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END IF;

			SELECT count(e.folio_suc)
			INTO iTotRegistros2
			FROM bdisac:"informix".sac_movimientoshistorial AS a
			INNER JOIN bdisac:"informix".sac_remesas_estadistica AS e ON a.folio_suc = e.folio_suc 
			WHERE a.referencia1 = CASE WHEN pCveRemesa = '' THEN a.referencia1 ELSE pCveRemesa END;
			
			IF iTotRegistros2 = 0 THEN

					FOREACH
						SELECT a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
						INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
						FROM bdisac:"informix".sac_movimientoshistorial AS a
						INNER JOIN bdicheq:"informix".sc_movhis AS b ON a.folio_suc = b.folio_suc 
						INNER JOIN bdisac:"informix".sac_convenios AS c ON c.numconvenio = a.numconvenio 
						INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = b.cuenta
						LEFT JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
						WHERE a.forma_pago IN (4 , 1) AND b.sucursal NOT IN ('9250','9764') 
						AND b.fech_oper BETWEEN pFechaInicio AND pFechaFin
						AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521')
						AND c.numcategoria = '07' 
						AND b.cancelad <> 'S' 
						AND a.numconvenio IN ('004','006','007','008','009') 
						AND a.numconvenio = CASE WHEN pRemesadora = '' THEN a.numconvenio ELSE pRemesadora END 
						AND d.num_cte = CASE WHEN pNumCliente = '' THEN d.num_cte ELSE pNumCliente END 
						AND a.referencia1 = CASE WHEN pCveRemesa = '' THEN a.referencia1 ELSE pCveRemesa END
						
						LET iTotRegistros = iTotRegistros + 1;
						
						RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario WITH RESUME;
					END FOREACH;

				ELSE
					FOREACH
						SELECT a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
						INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
						FROM bdisac:"informix".sac_movimientoshistorial AS a
						INNER JOIN bdicheq:"informix".sc_movhis AS b ON a.folio_suc = b.folio_suc 
						INNER JOIN bdisac:"informix".sac_remesas_estadistica AS e ON e.folio_suc = b.folio_suc 
						INNER JOIN bdisac:"informix".sac_convenios AS c ON c.numconvenio = a.numconvenio 
						INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = b.cuenta
						LEFT JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
						WHERE a.forma_pago IN (4 , 1) AND b.sucursal NOT IN ('9250','9764') 
						AND b.fech_oper BETWEEN pFechaInicio AND pFechaFin
						AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521')
						AND c.numcategoria = '07' 
						AND b.cancelad <> 'S' 
						AND e.origen <> 'A'
						AND a.numconvenio IN ('004','006','007','008','009') 
						AND a.numconvenio = CASE WHEN pRemesadora = '' THEN a.numconvenio ELSE pRemesadora END 
						AND d.num_cte = CASE WHEN pNumCliente = '' THEN d.num_cte ELSE pNumCliente END 
						AND a.referencia1 = CASE WHEN pCveRemesa = '' THEN a.referencia1 ELSE pCveRemesa END
						
						LET iTotRegistros = iTotRegistros + 1;
						
						RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario WITH RESUME;
					END FOREACH;
			END IF;

			IF iTotRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
				ELIF iTotRegistros = 0 AND pRegistros > 0 THEN
					LET cCodRet = '1001';
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario; 
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2022',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para grid de datos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_totalesmovpendientesccl(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)				
		RETURNING CHAR(5) AS codret,  
			INTEGER AS totalRegistros; 		  
			
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE iTotalRegistros INTEGER;
		DEFINE iContador INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET iTotalRegistros = 0;
		LET iContador = 0;
		
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				RETURN cCodRet, iTotalRegistros; 
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_totalesmovpendientesccl.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' OR pFecha IS NULL THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iTotalRegistros; 
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, iTotalRegistros;  
			END IF;
				
			EXECUTE PROCEDURE bditarjeta:'informix'.sp_concreing_consultamovpendientes2_totales (pUsuario, pFecha)
			INTO cCodRetSp,iTotalRegistros;				 
				 
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bditarjeta:sp_concreing_consultamovpendientes2_totales';
			END IF;
				
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iTotalRegistros;
			ELSE
				RETURN cCodRet, iTotalRegistros;
			END IF;

		END;

END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 10/08/2015',
'DESCRIPCION: SPL que obtiene el numero total de los movimientos pendientes de aplicar.',
'FUNCIONALIDAD: Consulta de Movimientos Pendientes de Aplicar', 
'MODULO: CONCILIACIONES',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketabonoapp(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pFolioSuc CHAR(16), pHuella CHAR(1), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
				CHAR(5) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(20) AS numCuenta,
				CHAR(16) AS numTarjeta,
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(150) AS retorno3;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(5);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cNumcuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cRetorno3 CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cNumcuenta = '';
	LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketAbonoApp.out';
		--TRACE ON;

		--SET DEBUG FILE TO '/informix/ENP/TicketDigital/Febrero/out/sp_ope_cons_ticketabonoapp.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' OR pFolioSuc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END IF;
		
		SELECT  FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, c.cuenta, c.num_tarjeta, f.numcte
		INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNumcliente
		FROM bdisac:"informix".sac_movimientoshistorial AS a
		INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio 
		INNER JOIN bdicheq:"informix".sc_movhis AS c ON c.folio_suc =  a.folio_suc 
		INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta
		LEFT JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
		WHERE b.numcategoria = '07' AND a.forma_pago = '4' AND c.sucursal = '5011' AND a.status_cancelado <> 'S'
		AND d.num_cte = pNumCliente AND a.referencia1 = pReferencia AND a.folio_suc = pFolioSuc;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00017';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END IF;
		
		SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
		TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
		INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
		FROM bdisac:"informix".sac_pld_remesas
		WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia;
		
		SELECT MAX(secuencia) 
			INTO cSecuenciaMax 
		FROM bdinteg:"informix".si_cte_huella 
		WHERE numcte = cNumcliente
		AND estado = 'A';

		SELECT dmapa 
			INTO cCadenaTran
		FROM bdinteg:"informix".si_cte_huella 
		WHERE numcte = cNumcliente
		AND secuencia = cSecuenciaMax;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCadenaTran = '';
		END IF;
		
		SELECT nombre, plaza 
		INTO cNomSucursal, cPlaza 
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = cSucursal;
		
		SELECT nombre 
		INTO cNomPlaza 
		FROM bdinteg:"informix".si_plazas
		WHERE plaza = cPlaza;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cNomPlaza = '';
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') > 0 THEN
			EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
			INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
			cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;
			
			LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
				
		END IF;
		
		RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
				cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2022',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informacion para formato Abono App',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketabonovent(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
				CHAR(3) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(20) AS numCuenta,
				CHAR(16) AS numTarjeta,
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cNumcuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cRetorno3 CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cNumcuenta = '';
	LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketAbonoVent.out';
		--TRACE ON;

		--SET DEBUG FILE TO '/informix/ENP/TicketDigital/Febrero/out/sp_ope_cons_ticketabonovent.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END IF;
		
		SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, CASE WHEN c.sucursal = '5011' THEN a.sucursal_cpl ELSE a.id_sucursal END , TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, c.cuenta, c.num_tarjeta, f.numcte
		INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cNumcliente
		FROM bdisac:"informix".sac_movimientoshistorial AS a
		INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio 
		INNER JOIN bdicheq:"informix".sc_movhis AS c ON c.folio_suc =  a.folio_suc
		INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta
		LEFT JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
		WHERE b.numcategoria = '07' AND a.forma_pago = '4' AND c.sucursal NOT IN ('9250','9764') 
		AND d.num_cte = pNumCliente AND a.referencia1 = pReferencia;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00017';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		ELSE
		
		SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
		TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
		INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
		FROM bdisac:"informix".sac_pld_remesas
		WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
			
		SELECT MAX(secuencia) 
			INTO cSecuenciaMax 
		FROM bdinteg:"informix".si_cte_huella 
		WHERE numcte = cNumcliente
		AND estado = 'A';

		SELECT dmapa 
			INTO cCadenaTran
		FROM bdinteg:"informix".si_cte_huella 
		WHERE numcte = cNumcliente
		AND secuencia = cSecuenciaMax;
			
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCadenaTran = '';
		END IF;

		SELECT nombre, plaza 
		INTO cNomSucursal, cPlaza 
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = cSucursal;
		
		SELECT nombre 
		INTO cNomPlaza 
		FROM bdinteg:"informix".si_plazas
		WHERE plaza = cPlaza;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cNomPlaza = '';
		END IF;
			
		IF DBINFO('sqlca.sqlerrd2') > 0 THEN
			
			EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
			INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
			cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;
				
			LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
						
		END IF;
			
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno3;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2022',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Abono por Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_generareptxtremesasnopagadas(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdEjecucion CHAR(1), pRuta CHAR(100),
pIdLimite SMALLINT, pFechaInicio DATE, pFechaFin DATE, pClaveId CHAR(100))
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS archivo_generado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	DEFINE cAutoridad CHAR(8);
	DEFINE cReporte CHAR(35);
	DEFINE cDescripcion CHAR(100);
	DEFINE cStatus CHAR(1);
	DEFINE cDescStatus CHAR(10);
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	
	DEFINE iRegistros INTEGER;
	DEFINE iGraba INTEGER;
	DEFINE iFormatoAnt INTEGER;
	DEFINE cDato CHAR(25);
	DEFINE cDatoFormat CHAR(20);
	DEFINE cRenglon CHAR(255);
	DEFINE cFormat CHAR(11);
	DEFINE cSeleccion CHAR(255);
	DEFINE cQuery CHAR(255);
	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFechaEnv DATE;
	DEFINE cNombre1Ord CHAR(40);
	DEFINE cNombre2Ord CHAR(40);
	DEFINE cApPaternoOrd CHAR(40);
	DEFINE cApMaternoOrd CHAR(40);
	DEFINE cDireccionOrd CHAR(80);		
	DEFINE cColoniaOrd CHAR(80);    	
	DEFINE cCiudadOrd CHAR(40);			
	DEFINE cEstadoOrd CHAR(3);	
	DEFINE cPaisOrd CHAR(3);	
	DEFINE cTipoIdOrd CHAR(3);	
	DEFINE cNumeroIdOrd CHAR(20);	
	DEFINE cCiudadIdOrd CHAR(3);	
	DEFINE cPaisIdOrd CHAR(3);	
	DEFINE cMonedaOrd CHAR(3);	
	DEFINE cMontoOrigen CHAR(20);		
	DEFINE cMontoPesos CHAR(20);		
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cFechaNacimientoBen CHAR(8);
	DEFINE cDireccionBen CHAR(80);		
	DEFINE cColoniaBen CHAR(80);    	
	DEFINE cCiudadBen CHAR(40);	    	
	DEFINE cEstadoBen CHAR(40);     	
	DEFINE cTelefonoBen CHAR(15);	
	DEFINE cTipoIdBen CHAR(3);      	
	DEFINE cNumeroIdBen CHAR(20);   	
	DEFINE cNumeroIdSuc CHAR(4);
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cClaveId CHAR(100);
	DEFINE cLimite CHAR(100);
	DEFINE iRecuperacion INTEGER;
	DEFINE cNombreArchivo CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	LET cAutoridad = '';
	LET cReporte = '';
	LET cDescripcion = '';
	LET cStatus = '';
	LET cDescStatus = '';
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	
	LET iRegistros = 0;
	LET iGraba = 0;
	LET iFormatoAnt = 0;
	LET cDato = '';
	LET cDatoFormat = '';
	LET cRenglon = '';
	LET cFormat = '';
	LET cSeleccion = '';
	LET cQuery = '';
	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	--LET cRutaInformix = '/informix/bin/';
	LET cRutaInformix  = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;

	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFechaEnv = '';
	LET cNombre1Ord = '';
	LET cNombre2Ord = '';
	LET cApPaternoOrd = '';
	LET cApMaternoOrd = '';
	LET cDireccionOrd = '';
	LET cColoniaOrd = '';
	LET cCiudadOrd = '';
	LET cEstadoOrd = '';
	LET cPaisOrd = '';
	LET cTipoIdOrd = '';
	LET cNumeroIdOrd = '';
	LET cCiudadIdOrd = '';
	LET cPaisIdOrd = '';
	LET cMonedaOrd = '';
	LET cMontoOrigen = '';
	LET cMontoPesos = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cFechaNacimientoBen = '';
	LET cDireccionBen = '';
	LET cColoniaBen = '';
	LET cCiudadBen = '';
	LET cEstadoBen = '';
	LET cTelefonoBen = '';
	LET cTipoIdBen = '';
	LET cNumeroIdBen = '';
	LET cNumeroIdSuc = '';
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cClaveId = 'REMNOPAGADAS'||TRIM(pUsuario)||TO_CHAR(CURRENT, '%Y%m%d%H%M%S');
	LET cLimite = '';
	LET iRecuperacion = 0;
	LET cNombreArchivo = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				IF ven_transacc = 1 THEN
					ROLLBACK WORK; --		
				END IF;
				
				RETURN cCodRet,cNombreArchivo;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_generareptxtremesasnopagadas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdEjecucion = '' OR pRuta = '' OR 
		pIdLimite IS NULL OR pFechaInicio IS NULL OR pFechaFin IS NULL OR pClaveId IS NULL THEN
			LET cCodRet = '00003';
			
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE
		LET pRuta = TRIM(pRuta) || '/';
		
		IF pIdLimite = 1 THEN
			LET cReporte = 'REMESASNOPAGADAS_ESTADO';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 2 THEN
			LET cReporte = 'REMESASNOPAGADAS_SUCURSAL';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 3 THEN
			LET cReporte = 'REMESASNOPAGADAS_TRANSACCIONES';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 4 THEN
			LET cReporte = 'REMESASNOPAGADAS_MDIARIO';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 5 THEN
			LET cReporte = 'REMESASNOPAGADAS_MMENSUAL';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 6 THEN
			LET cReporte = 'REMESASNOPAGADAS_ACUMULADO';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 7 THEN
			LET cReporte = 'REMESASNOPAGADAS_LISTAS';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		ELIF pIdLimite = 8 THEN
			LET cReporte = 'REMESASNOPAGADAS_TODOS';
			LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.txt';
		END IF;
		
		LET cNombreArchivo = TRIM(cReporte)||'.txt';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			IF pIdLimite IN (1,2,3,4,5,6,7) THEN
				
				LET cCmd1 ="";
				LET cCmd1 = "SELECT 'TIPO LÍMITE','FECHA ENVÍO','NOMBRE','SEGUNDO NOMBRE','APELLIDO PATERNO','APELLIDO MATERNO','DIRECCIÓN','COLONIA','CIUDAD','ESTADO','PAÍS',";	
				LET cCmd1 =""||TRIM(cCmd1)||"'TIPO','NÚMERO','CIUDAD','PAÍS','MONEDA ORDENANTE','MONTO ORIGEN','MONTO EN PESOS','NOMBRE','SEGUNDO NOMBRE','APELLIDO PATERNO','APELLIDO MATERNO',";
				LET cCmd1 =""||TRIM(cCmd1)||"'FECHA NACIMIENTO','DIRECCIÓN','COLONIA','CIUDAD','ESTADO','TELÉFONO','TIPO ID','NÚMERO ID','SUCURSAL'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM (SELECT limite,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,";
				LET cCmd1 =""||TRIM(cCmd1)||"tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,SUBSTR(monto_origen, 1, CHARINDEX('.', monto_origen) + 2),SUBSTR(monto_pesos, 1, CHARINDEX('.', monto_pesos) + 2),nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,";	
				LET cCmd1 =""||TRIM(cCmd1)||"SUBSTR(fechanacimiento_ben,7,2)||'/'||SUBSTR(fechanacimiento_ben,5,2)||'/'||SUBSTR(fechanacimiento_ben,1,4),direccion_ben,colonia_ben,ciudad_ben,estado_ben,telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_detalleremesasnopagadas";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE id_limite = (CASE WHEN "||pIdLimite||" IS NULL THEN id_limite ELSE "||pIdLimite||" END)";
				LET cCmd1 =""||TRIM(cCmd1)||" AND fecha_env BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND usuario_insert = '"||pUsuario||"' AND clave_id = '"||TRIM(pClaveId)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY 1,2 ASC)";
				
			ELIF pIdLimite = 8 THEN
			
				LET cCmd1 ="";
				LET cCmd1 = "SELECT 'TIPO LÍMITE','FECHA ENVÍO','NOMBRE','SEGUNDO NOMBRE','APELLIDO PATERNO','APELLIDO MATERNO','DIRECCIÓN','COLONIA','CIUDAD','ESTADO','PAÍS',";	
				LET cCmd1 =""||TRIM(cCmd1)||"'TIPO','NÚMERO','CIUDAD','PAÍS','MONEDA ORDENANTE','MONTO ORIGEN','MONTO EN PESOS','NOMBRE','SEGUNDO NOMBRE','APELLIDO PATERNO','APELLIDO MATERNO',";
				LET cCmd1 =""||TRIM(cCmd1)||"'FECHA NACIMIENTO','DIRECCIÓN','COLONIA','CIUDAD','ESTADO','TELÉFONO','TIPO ID','NÚMERO ID','SUCURSAL'";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM (SELECT limite,fecha_env_format,nombre1_ord,nombre2_ord,appaterno_ord,apmaterno_ord,direccion_ord,colonia_ord,ciudad_ord,estado_ord,pais_ord,";
				LET cCmd1 =""||TRIM(cCmd1)||"tipoid_ord,numeroid_ord,ciudadid_ord,paisid_ord,moneda_ord,SUBSTR(monto_origen, 1, CHARINDEX('.', monto_origen) + 2),SUBSTR(monto_pesos, 1, CHARINDEX('.', monto_pesos) + 2),nombre1_ben,nombre2_ben,appaterno_ben,apmaterno_ben,";	
				LET cCmd1 =""||TRIM(cCmd1)||"SUBSTR(fechanacimiento_ben,7,2)||'/'||SUBSTR(fechanacimiento_ben,5,2)||'/'||SUBSTR(fechanacimiento_ben,1,4),direccion_ben,colonia_ben,ciudad_ben,estado_ben,telefono_ben,tipoid_ben,numeroid_ben,numeroid_suc";
				LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_detalleremesasnopagadas";
				LET cCmd1 =""||TRIM(cCmd1)||" WHERE fecha_env BETWEEN '"||pFechaInicio||"' AND '"||pFechaFin||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" AND usuario_insert = '"||pUsuario||"' AND clave_id = '"||TRIM(pClaveId)||"'";
				LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY 1,2 ASC)";
				
			END IF;
			
			LET cSql = '';
			LET cSql = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'queryRemesas.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(pRuta)||'queryRemesas.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicnweb '||TRIM(pRuta)||'queryRemesas.sql';
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo query.sql
			LET cSql = '';
			LET cSql = 'rm -rf '||TRIM(pRuta)||'queryRemesas.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			--LET cSql = '';
			--LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			--SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador '\t'.
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);

			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Se renombra el archivo temporal por el nombre original
			LET cSql = '';
			LET cSql = "mv "||TRIM(cRutaGral)||".tmp  "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,cNombreArchivo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/01/2018',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: CONSULTA DE REMESAS NO PAGADAS',
'DESCRIPCION: Spl encargado de generar los reportes txt de las remesas no pagadas.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketefectivovent(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1))
	RETURNING CHAR(5) AS codret,
				CHAR(5) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(20) AS cuenta,
				CHAR(16) AS tarjeta,
				CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(5);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	DEFINE cRetorno3 CHAR(150);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cCuenta VARCHAR(20);
	DEFINE cTarjeta VARCHAR(16);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketEfectivoVent.out';
		--TRACE ON;
		--SET DEBUG FILE TO '/informix/ENP/TicketDigital/Febrero/out/sp_ope_cons_ticketefectivovent.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno3;
			END IF;
		
		
			SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc
			FROM bdisac:"informix".sac_movimientoshistorial AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio
			WHERE b.numcategoria = '07' 
			--AND forma_pago='1'
			AND a.referencia1 = pReferencia;

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet= '00017';
					RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno3;

					ELSE
						IF
					--/////////WESTERN UNION/////////--
							cNumConvenio = '006' OR cNumConvenio = '007' OR cNumConvenio = '008'  THEN

							SELECT
								wu.benef_nombre1,
								wu.benef_nombre2,
								wu.benef_appaterno,
								wu.benef_apmaterno,
								wu.benef_id_number,
								wu.numcte,
								TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
								TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno)

								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3  
							FROM
								bdisac:"informix".sac_wu_pay AS wu 
									INNER JOIN bdisac:"informix".sac_pld_remesas AS pld 
									ON wu.mtcn = pld.num_confirmacion AND
									wu.foreign_rs_refnum_rp= pld.folio_sucursal 
							WHERE
								wu.mtcn= cReferencia AND
								wu.foreign_rs_refnum_rp =cFolioSuc;

							--/////////si los datos vienen vacios se consulta los datos en las tablas QRY--
							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cNumcliente) 	IS NULL OR 
								TRIM(cRetorno3) 	IS NULL THEN
									
								SELECT
									wu.benef_nombre1,
									wu.benef_nombre2,
									wu.benef_appaterno,
									wu.benef_apmaterno,
									wu.benef_id_number,
									wu.numcte,
									TRIM(s.emisor_nombre1) || ' ' || TRIM(s.emisor_nombre2) || ' ' || 
									TRIM(s.emisor_appaterno) || ' ' || TRIM(s.emisor_apmaterno)

								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3  

								FROM
									bdisac:"informix".sac_wu_pay AS wu 
										INNER JOIN bdisac:"informix".sac_wu_search AS s 
										ON wu.mtcn = s.mtcn --num remesa
										
								WHERE
									s.mtcn = cReferencia AND
									s.foreign_rs_refnum_rp = cFolioSuc;
							END IF;


							--/////////BTS/////////--
							ELIF cNumConvenio = '004' THEN

								SELECT
									bts.r_first_name,
									bts.r_middle_name,
									bts.r_last_name,
									bts.r_mother_m_name,
									bts.r_identif_nm,
									bts.numcte,
									TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
									TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 

								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3

								FROM
									bdisac:"informix".sac_bts_payi AS bts 
										INNER JOIN bdisac:"informix".sac_pld_remesas AS pld 
										ON bts.confirmation_nm = pld.num_confirmacion AND
										bts.bank_ref_nm = pld.folio_sucursal 
								WHERE
									bts.confirmation_nm= cReferencia AND
									bts.bank_ref_nm= cFolioSuc;

								-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
								IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
									TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cNumcliente) 	IS NULL OR 
									TRIM(cRetorno3) 	IS NULL THEN
									
									SELECT
										bts.r_first_name,
										bts.r_middle_name,
										bts.r_last_name,
										bts.r_mother_m_name,
										bts.r_identif_nm,
										bts.numcte,
										TRIM(s.s_first_name) || ' ' || TRIM(s.s_middle_name) || ' ' || 
										TRIM(s.s_last_name) || ' ' || TRIM(s.s_mother_m_name)

									INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3  

									FROM
										bdisac:"informix".sac_bts_payi AS bts 
											INNER JOIN bdisac:"informix".sac_bts_qryi AS s 
											ON bts.confirmation_nm = s.confirmation_nm --num remesa
											
									WHERE
										bts.confirmation_nm = cReferencia AND
										bts.bank_ref_nm= cFolioSuc;
								END IF;

									--/////////APPRIZA/////////--
									ELIF cNumConvenio = '009' THEN
										SELECT
											app.firstname,
											app.middlename,
											app.lastname,
											app.mommaidenname,
											app.numberci,
											app.numcte,
											TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
											TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 

										INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3

										FROM
											bdisac:"informix".sac_app_payi AS app 
												INNER JOIN bdisac:"informix".sac_pld_remesas AS pld 
												ON app.unirefnum = pld.num_confirmacion AND
												app.refnum = pld.folio_sucursal 
										WHERE
											app.unirefnum = cReferencia AND
											app.refnum=cFolioSuc;
							
										-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
										IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
											TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cNumcliente) 	IS NULL OR 
											TRIM(cRetorno3) 	IS NULL THEN
											
											SELECT
												app.firstname,
												app.middlename,
												app.lastname,
												app.mommaidenname,
												app.numberci,
												app.numcte,
												TRIM(s.r_firstname) || ' ' || TRIM(s.r_middlename) || ' ' || 
												TRIM(s.r_lastname) || ' ' || TRIM(s.r_mommaidenname)

											INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cNumcliente,cRetorno3  

											FROM
												bdisac:"informix".sac_app_payi AS app 
													INNER JOIN bdisac:"informix".sac_app_qryi AS s 
													ON app.unirefnum = s.unirefnum 
													
											WHERE
												s.unirefnum = cReferencia AND
												app.refnum = cFolioSuc;
										END IF;

					END IF;
					/*SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, numero_de_cliente_benef, 
					TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
					INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cRetorno3
					FROM bdisac:"informix".sac_pld_remesas
					WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; */
				
					SELECT MAX(secuencia) 
						INTO cSecuenciaMax 
					FROM bdinteg:"informix".si_cte_huella 
					WHERE numcte = cNumcliente
					AND estado = 'A';

					SELECT dmapa 
					INTO cCadenaTran
					FROM bdinteg:"informix".si_cte_huella 
					WHERE numcte = cNumcliente
					AND secuencia = cSecuenciaMax;
							
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCadenaTran = '';
						END IF;

							SELECT nombre, plaza 
								INTO cNomSucursal, cPlaza 
							FROM bdinteg:"informix".si_sucursales
							WHERE sucursal = cSucursal;
								
							SELECT nombre 
								INTO cNomPlaza 
							FROM bdinteg:"informix".si_plazas
							WHERE plaza = cPlaza;
					
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cNomPlaza = '';
							END IF;
						
								IF DBINFO('sqlca.sqlerrd2') > 0 THEN
									EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
									INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
									cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;	
									LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
										
								END IF;
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, 
								cFechaInsert, cUsuario, cFolioSuc, cSucursal, cNomSucursal,cNombre1Ben, cNombre2Ben, cApPaternoBen,
								cApMaternoBen, cNumCteBen, cNumcliente, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, 
								cTarjeta, cRetorno3;
				END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 28/09/2022',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Efevtico Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ac_actualizactas(pUsuario CHAR(8), pIdFuncion CHAR(10), pId INTEGER)
                RETURNING CHAR(5) AS codret;          
						  
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;  
		DEFINE cNombre CHAR(45);

        LET cCodRet = '00000';
        LET iSqlErr = 0; 
		LET cNombre = '';

        BEGIN   
                ON EXCEPTION SET iSqlErr
                    LET cCodRet = iSqlErr;
                    RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_ac_actualizactas.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pId = '' THEN
                    LET cCodRet = '00003';
					RETURN cCodRet;
                END IF;
				
				-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
				EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
					IF cCodRet <> '00000' THEN
					RETURN cCodRet;
				END IF;
                
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;

				UPDATE bdicheq:"informix".sc_cuentas_retiro SET estatus = 'R',no_empleado =pUsuario WHERE rowid = pId;
				
				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
				LET cCodRet = '-0001';
				END IF;

		RETURN cCodRet;
		
        END;
END PROCEDURE
DOCUMENT 
'AUTOR: Daniel Reyes Guillen',
'FECHA: 22/03/2022',
'DESCRIPCION: Sp encargado de actualizar la tabla sc_cuentas_retiro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ac_busquedacuentas(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha DATE,pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
						  CHAR(20) AS cuenta,
						  MONEY(18,2) AS sdo_calculado,
						  MONEY(18,2) AS sdo_actual,
						  INTEGER AS id,
						  MONEY(18,2) AS sdo_incial, 
						  MONEY(18,2) AS retiro, 
						  MONEY(18,2) AS deposito,
						  CHAR(10) AS tipoReporte;
						  
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;   
		DEFINE cCuenta CHAR(20);
		DEFINE mSdoCalc MONEY(18,2);
		DEFINE mSdoAct MONEY(18,2);
		DEFINE iRecuperacion INTEGER;
		DEFINE iId INTEGER;
		DEFINE mRetiro MONEY(18,2);
		DEFINE mDeposito MONEY(18,2);
		DEFINE cTipoReporte CHAR(10);
		DEFINE mSdoInicial MONEY(18,2);
		
        LET cCodRet = '00000';
        LET iSqlErr = 0;  
		LET cCuenta = '';
		LET mSdoCalc = '';
		LET mSdoAct = 0;
		LET iRecuperacion = 0;
		LET iId = 0;
		LET mRetiro = 0;
		LET mDeposito = 0;
		LET cTipoReporte = '';
		LET mSdoInicial = 0;

    BEGIN   
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		END EXCEPTION;
			
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ac_busquedacuentas.out';
		-- TRACE ON;
			
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha ='' OR pRegistros = '' OR pRecuperacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		END IF;
			
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
		
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion 
			a.cuenta, a.saldo_calculado, a.saldo_actual, a.rowid, b.sdo_dia_ant
			INTO cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial
			FROM bdicheq:"informix".sc_cuentas_retiro AS a
			INNER JOIN bdicheq:"informix".sc_maechq AS b ON b.cuenta = a.cuenta 
			WHERE a.fecha = pFecha AND a.estatus ='A'
			ORDER BY cuenta
			
			SELECT NVL(SUM(monto_tot), 0) 
			INTO mRetiro 
			FROM bdicheq:"informix".sc_movdia, bdinteg:"informix".si_transacc
			WHERE cuenta = cCuenta
			AND naturaleza = 'C'
			AND se_contabiliza = 'S'
			AND transacc = numero
			AND sistema = '01'
			AND fech_alt = pFecha
			AND cancelad <> 'S'
			AND transacc <> '0232';
			
			SELECT NVL(SUM(monto_tot), 0) 
			INTO mDeposito 
			FROM bdicheq:"informix".sc_movdia, bdinteg:"informix".si_transacc
			WHERE cuenta = cCuenta
			AND naturaleza = 'A'
			AND se_contabiliza = 'S'
			AND transacc = numero
			AND sistema = '01'
			AND fech_alt = pFecha
			AND cancelad <> 'S'; 
   
			LET cTipoReporte = 'RETIRO';
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte WITH RESUME;
			
		END FOREACH;
		
		LET cTipoReporte = '';
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01279'; 
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cCuenta,mSdoCalc,mSdoAct,iId, mSdoInicial, mRetiro, mDeposito, cTipoReporte;
		END IF;	


    END;
END PROCEDURE
DOCUMENT 
'AUTOR: Daniel Reyes Guillen',
'FECHA: 22/03/2022',
'DESCRIPCION: Sp encargado de consultar datos de la tabla sc_cuentas_retiro',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 06/10/2022',
'DESCRIPCION: Se modifica SP para agregar los siguientes retornos, saldo inicial, retiros, depositos, tipo reporte',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ac_busquedacuentas_total(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)
                RETURNING CHAR(5) AS codret,
						  INTEGER AS total;
						  
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;   
		DEFINE iTotal INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;  
		LET iTotal = 0;
		
        BEGIN   
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iTotal;
		END EXCEPTION;
			
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ac_busquedacuentas_total.out';
		-- TRACE ON;
			
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha ='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iTotal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			RETURN cCodRet,iTotal;
		END IF;
			
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
		
		
		SELECT COUNT(*) INTO iTotal			
		FROM bdicheq:"informix".sc_cuentas_retiro AS a
		INNER JOIN bdicheq:"informix".sc_maechq AS b ON b.cuenta = a.cuenta 
		WHERE a.fecha = pFecha AND a.estatus ='A';

		IF iTotal = 0 THEN 
			LET cCodRet ='01279';
		END IF;
	
		RETURN cCodRet,iTotal;
		
        END;
END PROCEDURE
DOCUMENT 
'AUTOR: Daniel Reyes Guillen',
'FECHA: 22/03/2022',
'DESCRIPCION: Sp encargado de consultar datos de la tabla sc_cuentas_retiro',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 06/10/2022',
'DESCRIPCION: Se modifica SP para agrega la relaciÃ³n a la tabla sc_maechq',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ac_desbloquoctas(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pFechaDesb DATE)
                RETURNING CHAR(5) AS codret,
						  char(5) AS clave;          
						  
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;  
	DEFINE cCodRetSp CHAR(3);
	DEFINE cNombre CHAR(45);
	DEFINE cEmpresa CHAR(3);
	DEFINE cClave CHAR(5);

    LET cCodRet = '00000';
    LET iSqlErr = 0; 
	LET cCodRetSp = '';
	LET cNombre = '';
	LET cEmpresa = '001';
	LET cClave = '';

    BEGIN   
        ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cClave;
        END EXCEPTION;
                
        --SET DEBUG FILE TO '/tmp/mfinis/sp_ac_desbloquoctas.out';
        --TRACE ON;
                
        IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' THEN
            LET cCodRet = '00003';
			RETURN cCodRet, cClave;
        END IF;
				
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClave;
		END IF;
               
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(cEmpresa, pCuenta, '0', '00', 0, pFechaDesb, pUsuario, '', '', '', '', '')
		INTO cCodRetSp, cClave;
		
		IF cCodRetSp <> '000' THEN
            LET cCodRet = '99999';
        END IF;
		
		RETURN cCodRet, cClave;
		
    END;
END PROCEDURE
DOCUMENT 
'AUTOR: VerÃ³nica SÃ¡nchez Tlacomulco',
'FECHA: 06/10/2022',
'DESCRIPCION: Sp encargado de realizar el desbloqueo de cuentas revisadas',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultamsi_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30),pFechaIni DATE,pFechaFin DATE, pProducto CHAR(4))
	RETURNING 	CHAR(5) AS codret,
				INTEGER AS total;

	DEFINE cCodRet 	CHAR(5);
	DEFINE iSqlErr 	INTEGER;
	DEFINE cCodRetSP CHAR(6);
    DEFINE cMensajeRet CHAR(80);    
	DEFINE cNumCredito CHAR(20);
    DEFINE cCodTipCred CHAR(2);
	DEFINE cDescStatusCred CHAR(60);     
    DEFINE iIdUnidadProd INTEGER;
    DEFINE cCodCaract2 CHAR(3);
    DEFINE dtFechaOrigen DATE;
    DEFINE dtFechaProxPago DATE;
    DEFINE dPagoMinimo DECIMAL(18,2);
    DEFINE dtFechaUltPago DATE;
    DEFINE iPlazo INTEGER;
    DEFINE iPlazoAux INTEGER;
    DEFINE iPagosRealizados INTEGER;
    DEFINE dLineaOtorgada DECIMAL(18,2);    
    DEFINE dTasaInteres DECIMAL(9,6);
    DEFINE dTasaMoratorios DECIMAL(9,6);
    DEFINE dMontoSBC DECIMAL(14,2);    
    DEFINE dCapVig DECIMAL(18,2);
    DEFINE dCapTrans DECIMAL(18,2);
    DEFINE dCapVdoExig DECIMAL(18,2);
    DEFINE dCapVdoNoExig DECIMAL(18,2);
    DEFINE dSdoActCap DECIMAL(18,2);        
	DEFINE dIntVdo DECIMAL(18,2);
    DEFINE dIntMoratorio DECIMAL(18,2);
    DEFINE dIntMes DECIMAL(18,2);
    DEFINE dSdoActInt DECIMAL(18,2);    
	DEFINE dIntVig DECIMAL(18,2);
    DEFINE dIvaIntVig DECIMAL(18,2);
    DEFINE dIvaIntVdo DECIMAL(18,2);
    DEFINE dIvaIntMoratorio DECIMAL(18,2);
    DEFINE dIvaIntMes DECIMAL(18,2);
    DEFINE dSdoActIvaInt DECIMAL(18,2);    
    DEFINE dComPend DECIMAL(18,2);
    DEFINE dIvaCom DECIMAL(18,2);
    DEFINE dSdoRetenido DECIMAL(18,2);
    DEFINE dSdoTotalLiq DECIMAL(18,2);    
    DEFINE dIntDevengado DECIMAL(18,2);
    DEFINE dIvaIntDevengado DECIMAL(18,2);
    DEFINE dLineaDisponible DECIMAL(18,2);
    DEFINE dPagosVdos DECIMAL(18,2);
    DEFINE cDescBloqueoCta CHAR(60);
    DEFINE cDescCausaBloqueoCta CHAR(50);
    DEFINE cSitCte CHAR(1);
    DEFINE cCausaCte INTEGER;
    DEFINE cDescSitEspCte CHAR(75);
    DEFINE cSitCred CHAR(1);
    DEFINE cCausaCred INTEGER;
    DEFINE cDescSitEspCred CHAR(75);
	DEFINE dSaldo_pagar DECIMAL(18,2);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(10);
	DEFINE cTarjeta CHAR(16);
	DEFINE cFolio CHAR(16);
	DEFINE cCodFun CHAR(3);
	DEFINE cDescripcion CHAR(100);
	DEFINE cInfReceptor CHAR(40);
	DEFINE cReferencia CHAR(40);
	DEFINE dMontoOtorgado DECIMAL(18,2);
	DEFINE cStatus CHAR(60);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNumPago CHAR(5);
	DEFINE cPlazo CHAR(5);
    DEFINE dMontoAux DECIMAL(18,2);	
	DEFINE cStat CHAR(2);
	DEFINE cNumSol CHAR(20);
    DEFINE cCab CHAR(1);
    DEFINE cNumCred CHAR(20);
	DEFINE iProd INTEGER;
	DEFINE cTipoConsulta CHAR(4);
    DEFINE cSol CHAR(20);
    DEFINE iAuxCab INTEGER;
	DEFINE cTarjetaAux CHAR(16);
	DEFINE iCancelado INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSP ='';
    LET cMensajeRet ='';
	LET cNumCredito ='';
    LET cCodTipCred ='';
	LET cDescStatusCred ='';   
    LET iIdUnidadProd =0;
    LET cCodCaract2 ='';
    LET dtFechaOrigen ='';
    LET dtFechaProxPago ='';
    LET dPagoMinimo =0;
    LET dtFechaUltPago ='';
    LET iPlazo =0;
    LET iPlazoAux = 0;
    LET iPagosRealizados =0;
    LET dLineaOtorgada =0;
    LET dTasaInteres =0;
    LET dTasaMoratorios =0;
    LET dMontoSBC =0;
    LET dCapVig  =0;
    LET dCapTrans  =0;
    LET dCapVdoExig  =0;
    LET dCapVdoNoExig  =0;
    LET dSdoActCap  =0;        
	LET dIntVdo  =0;
    LET dIntMoratorio  =0;
    LET dIntMes  =0;
    LET dSdoActInt  =0;    
	LET dIntVig  =0;
    LET dIvaIntVig  =0;
    LET dIvaIntVdo  =0;
    LET dIvaIntMoratorio  =0;
    LET dIvaIntMes  =0;
    LET dSdoActIvaInt  =0;    
    LET dComPend  =0;
    LET dIvaCom  =0;
    LET dSdoRetenido  =0;
    LET dSdoTotalLiq  =0;    
    LET dIntDevengado  =0;
    LET dIvaIntDevengado  =0;
    LET dLineaDisponible  =0;
    LET dPagosVdos  =0;
    LET cDescBloqueoCta ='';
    LET cDescCausaBloqueoCta ='';
    LET cSitCte ='';
    LET cCausaCte =0;
    LET cDescSitEspCte ='';
    LET cSitCred ='';
    LET cCausaCred =0;
    LET cDescSitEspCred ='';
	LET dSaldo_pagar  =0;
	LET cFecha ='';
	LET cHora ='';
	LET cTarjeta ='';
	LET cFolio ='';
	LET cCodFun ='';
	LET cDescripcion ='';
	LET cInfReceptor ='';
	LET cReferencia ='';
	LET dMontoOtorgado  =0;
	LET cStatus ='';
	LET iNoRegistros =0;
	LET cNumPago='';
	LET cPlazo ='';
    LET dMontoAux = 0;
	LET cStat ='';
	LET cNumSol ='';
    LET cCab='';
    LET cNumCred='';
	LET iProd = 0;
	LET cTipoConsulta ='';
    LET cSol = '';
    LET iAuxCab =0;
	LET cTarjetaAux = '';
	LET iCancelado = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				UPDATE "informix".sw_verificastatusconsmsi
				SET  status = 'E', error_proceso = 'S', error = cCodRet
				WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
				RETURN cCodRet, iNoRegistros;
				
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/Daniel/sp_msi_consultamsi_totales.out';
		--TRACE ON;

 
		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' OR pFechaIni = '' OR pFechaFin='' THEN
				LET cCodRet = '00003';
				UPDATE "informix".sw_verificastatusconsmsi
				SET  status = 'E', error_proceso = 'S', error = cCodRet
				WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
				RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			 UPDATE "informix".sw_verificastatusconsmsi
			 SET  status = 'E', error_proceso = 'S', error = cCodRet
			 WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';			     
			 RETURN cCodRet, iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		 -- SE LIMPIA TABLA POR USUARIO
         
        DELETE FROM "informix".sw_msi_consultagrid WHERE usuario = pUsuario;
		DELETE FROM "informix".sw_verificastatusconsmsi
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA'; 
 
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		INSERT INTO "informix".sw_verificastatusconsmsi(usuario_insert, nombre_archivo, status,  error_proceso, tipo_proceso, error,total) 
		VALUES(pUsuario,'','I','','LECTURA','',0);
		
		SELECT COUNT(*) INTO iProd FROM bdicred:"informix".sd_definicion WHERE edocta_param= 'tdc' and num_producto=pProducto;
		
		LET  cTipoConsulta = SUBSTR(pNumCred,1,4);
		
		IF  iProd = 0 AND cTipoConsulta='8900' THEN --Busca por promo msi 
		
		
		SELECT /*{+INDEX(bdicred:sd_movdiacrd idx_sd_movdiacrd1)}*/ fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref  FROM bdicred:"informix".sd_movdiacrd WHERE reversado= 'N' AND fecha_mov >= pFechaIni AND fecha_mov<= pFechaFin and num_credito = pNumCred INTO TEMP sd_movdiacrd_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_promocion_credito idx_sd_promocion_credito)}*/  num_tarjeta,num_sol_prestamo,num_credito,SUBSTR(folio_suc,2,LENGTH(folio_suc)) as folio_suc,plazo FROM bdicred:"informix".sd_promocion_credito WHERE empresa = '001' AND num_sol_prestamo= pNumCred and num_pro_prestamo = '8900'  INTO TEMP sd_promocion_credito_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_maesdoscrd idx_maesdoscrd1)}*/  monto_otorgado,num_credito FROM bdicred:"informix".sd_maesdoscrd WHERE num_credito= pNumCred INTO TEMP sd_maesdoscrd_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_maecredcrd idx_maecrd)}*/ status_cred,num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_credito= pNumCred INTO TEMP sd_maecredcrd_temp with no log;

		SELECT /*{+INDEX(bdicred:sd_movhiscrd idx_movhiscrd2)}*/  fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref FROM bdicred:"informix".sd_movhiscrd WHERE empresa = '001' AND reversado= 'N' AND fecha_mov >= pFechaIni AND fecha_mov<= pFechaFin and num_credito = pNumCred INTO TEMP sd_movhiscrd_temp with no log;

		FOREACH 

			   SELECT num_tarjeta INTO cTarjetaAux FROM (
				select 
				b.num_tarjeta  		from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				UNION 
				select b.num_tarjeta  		from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
			)
				group by num_tarjeta


			FOREACH WITH HOLD 
					SELECT 
				 * 
				INTO cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazoAux,cStatus,cStat,cNumSol,cNumCred
				FROM
				(select 
						/*{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}*/
		
				a.fecha_mov, TO_CHAR(a.hora_mov,"%H:%M:%S") as hora_mov,b.num_tarjeta,a.folio_suc,a.codigo_fun, c.descripcion,d.infreceptor,a.referencia,
				e.monto_otorgado, b.plazo,h.descripcion,
				f.status_cred,
				b.num_sol_prestamo,
                b.num_credito
				from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX(intercard:movimiento idx_movimientonew1a)}  secuenciaextendida,infreceptor from intercard:"informix".movimiento where numtarjeta= cTarjetaAux)d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				inner join bdicred:"informix".sd_maecredcrd_temp f on a.num_credito = f.num_credito 
				inner join bdicred:"informix".sd_tipocartera h on h.status_cred =f.status_cred

				UNION 
				select 
						/*{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}*/
				
				a.fecha_mov, TO_CHAR(a.hora_mov,"%H:%M:%S") as hora_mov,b.num_tarjeta,a.folio_suc,a.codigo_fun, c.descripcion,d.infreceptor,a.referencia,
				e.monto_otorgado, b.plazo,h.descripcion,
				f.status_cred,
                b.num_sol_prestamo,
                b.num_credito
				from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX( intercard:"informix".movimientohistorico idx_movimiento1)}   secuenciaextendida,infreceptor from intercard:"informix".movimientohistorico where numtarjeta= cTarjetaAux) d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				inner join bdicred:"informix".sd_maecredcrd_temp f on a.num_credito = f.num_credito 
				inner join bdicred:"informix".sd_tipocartera h on h.status_cred =f.status_cred 

				)
				
				IF cStat = 'FF' THEN 
				
				select count(*) INTO iCancelado from bdicred:"informix".sd_msi_cancela_credito_msi where num_credito = cSol;
				
					IF iCancelado > 0 THEN 
						LET cStatus ='CANCELADO';
					ELSE 
						LET cStatus ='LIQUIDADO';
					END IF;
				END IF;		

				
				EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',cNumSol) INTO 
				cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
				dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
				dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
				dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
				dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
				cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
				cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 

				select  capital_mto_cuota,num_pago INTO dSaldo_pagar,cNumPago FROM (SELECT FIRST 1capital_mto_cuota,num_pago from bdicred:"informix".sd_amortiza_creditocrd where num_credito = cNumSol AND fecha_cuota = cFecha ORDER BY fecha_cuota);

				IF dSaldo_pagar is null THEN
				  LET dSaldo_pagar = 0;
				END IF;
				
				IF cNumPago is null THEN
				  LET cNumPago = '0';
				END IF;
				
                IF iAuxCab =0 THEN --Se asigna el primer registro encontrado como encabezado  
                    LET cCab ='C';
                    LET iNoRegistros = iNoRegistros + 1;
                    LET iAuxCab = iAuxCab+1;
                ELSE
                    LET cCab ='D';
                END IF;

                LET cPlazo = TRIM(cNumPago) ||'/'|| TRIM(iPlazoAux::CHAR(5));

				INSERT INTO "informix".sw_msi_consultagrid(usuario, fecha, hora, tarjeta, folio,cod_fun,descripcion,infreceptor,referencia,montootorgado,plazo,cplazo,status,saldoliq,saldopag,llave,id) 
				VALUES(pUsuario,cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazoAux,cPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iNoRegistros,cCab);

			END FOREACH;
		END FOREACH;
		
		DROP TABLE IF EXISTS sd_movdiacrd_temp;
		DROP TABLE IF EXISTS sd_promocion_credito_temp;
		DROP TABLE IF EXISTS sd_maesdoscrd_temp;
		DROP TABLE IF EXISTS sd_maecredcrd_temp;
		DROP TABLE IF EXISTS sd_movhiscrd_temp;
		
		ELIF iProd = 1 THEN --Busca por num_credito todas las promociones de msi asociadas

        FOREACH 
        select num_sol_prestamo INTO cSol FROM bdicred:"informix".sd_promocion_credito 
        WHERE num_credito =pNumCred AND num_pro_prestamo = '8900'
		
		SELECT /*{+INDEX(bdicred:sd_movdiacrd idx_sd_movdiacrd1)}*/ fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref  FROM bdicred:"informix".sd_movdiacrd WHERE  reversado= 'N' AND fecha_mov >= pFechaIni AND fecha_mov<= pFechaFin and num_credito = cSol INTO TEMP sd_movdiacrd_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_promocion_credito idx_sd_promocion_credito)}*/  num_tarjeta,num_sol_prestamo,num_credito,SUBSTR(folio_suc,2,LENGTH(folio_suc)) as folio_suc,plazo FROM bdicred:"informix".sd_promocion_credito WHERE num_pro_prestamo = '8900' AND num_sol_prestamo= cSol INTO TEMP sd_promocion_credito_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_maesdoscrd idx_maesdoscrd1)}*/  monto_otorgado,num_credito FROM bdicred:"informix".sd_maesdoscrd WHERE num_credito= cSol INTO TEMP sd_maesdoscrd_temp with no log;
		SELECT /*{+INDEX(bdicred:sd_maecredcrd idx_maecrd)}*/ status_cred,num_credito FROM bdicred:"informix".sd_maecredcrd WHERE num_credito= cSol INTO TEMP sd_maecredcrd_temp with no log;

		SELECT /*{+INDEX(bdicred:sd_movhiscrd idx_movhiscrd2)}*/  fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref FROM bdicred:"informix".sd_movhiscrd WHERE empresa = '001' AND reversado= 'N' AND fecha_mov >= pFechaIni AND fecha_mov<= pFechaFin and num_credito = cSol INTO TEMP sd_movhiscrd_temp with no log;	
		
        LET iAuxCab =0;
		
		FOREACH 

			   SELECT num_tarjeta INTO cTarjetaAux FROM (
				select 
					
				b.num_tarjeta  		from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				UNION 
				select b.num_tarjeta  		from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				)
				group by num_tarjeta
		
		
		FOREACH WITH HOLD 
				SELECT 
				 * 
				INTO cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazoAux,cStatus,cStat,cNumSol,cNumCred
				FROM
				(select  
						/*{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}*/
				
				a.fecha_mov, TO_CHAR(a.hora_mov,"%H:%M:%S") as hora_mov,b.num_tarjeta,a.folio_suc,a.codigo_fun, c.descripcion,d.infreceptor,a.referencia,
				e.monto_otorgado, b.plazo,h.descripcion,
				f.status_cred,
				b.num_sol_prestamo,
                b.num_credito
				from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select /*{+INDEX(intercard:movimiento idx_movimientonew1a)}*/  secuenciaextendida,infreceptor from intercard:"informix".movimiento where numtarjeta= cTarjetaAux)d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				inner join bdicred:"informix".sd_maecredcrd_temp f on a.num_credito = f.num_credito 
				inner join bdicred:"informix".sd_tipocartera h on h.status_cred =f.status_cred

				UNION 
				select 
						/*{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}*/
				
				a.fecha_mov, TO_CHAR(a.hora_mov,"%H:%M:%S") as hora_mov,b.num_tarjeta,a.folio_suc,a.codigo_fun, c.descripcion,d.infreceptor,a.referencia,
				e.monto_otorgado, b.plazo,h.descripcion,
				f.status_cred,
                b.num_sol_prestamo,
                b.num_credito
				from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select /*{+INDEX( intercard:"informix".movimientohistorico idx_movimiento1)}*/   secuenciaextendida,infreceptor from intercard:"informix".movimientohistorico where numtarjeta= cTarjetaAux) d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				inner join bdicred:"informix".sd_maecredcrd_temp f on a.num_credito = f.num_credito 
				inner join bdicred:"informix".sd_tipocartera h on h.status_cred =f.status_cred

			)
				
				IF cStat = 'FF' THEN 
				
				select count(*) INTO iCancelado from bdicred:"informix".sd_msi_cancela_credito_msi where num_credito = cSol;
				
					IF iCancelado > 0 THEN 
						LET cStatus ='CANCELADO';
					ELSE 
						LET cStatus ='LIQUIDADO';
					END IF;
				END IF;		


				
				EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',cSol) INTO 
				cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
				dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
				dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
				dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
				dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
				cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
				cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 

				select  capital_mto_cuota,num_pago INTO dSaldo_pagar,cNumPago FROM (SELECT FIRST 1 capital_mto_cuota,num_pago from bdicred:"informix".sd_amortiza_creditocrd where num_credito = cSol AND fecha_cuota = cFecha ORDER BY fecha_cuota);

				IF dSaldo_pagar is null THEN
				  LET dSaldo_pagar = 0;
				END IF;
				
				IF cNumPago is null THEN
				  LET cNumPago = '0';
				END IF;

                IF iAuxCab =0 THEN --Se asigna el primer registro como encabezado  
                    LET cCab ='C';
                    LET iNoRegistros = iNoRegistros + 1;
                    LET iAuxCab = iAuxCab+1;
                ELSE
                    LET cCab ='D';
                END IF;

                LET cPlazo = TRIM(cNumPago) ||'/'|| TRIM(iPlazoAux::CHAR(5));

				INSERT INTO "informix".sw_msi_consultagrid(usuario, fecha, hora, tarjeta, folio,cod_fun,descripcion,infreceptor,referencia,montootorgado,plazo,cplazo,status,saldoliq,saldopag,llave,id) 
				VALUES(pUsuario,cFecha, cHora, cTarjeta,cFolio, cCodFun, cDescripcion,cInfReceptor,cReferencia,dMontoOtorgado,iPlazoAux,cPlazo,cStatus,dSdoTotalLiq,dSaldo_pagar,iNoRegistros,cCab);
				
				
		END FOREACH;
    
        END FOREACH;
		
		DROP TABLE IF EXISTS sd_movdiacrd_temp;
		DROP TABLE IF EXISTS sd_promocion_credito_temp;
		DROP TABLE IF EXISTS sd_maesdoscrd_temp;
		DROP TABLE IF EXISTS sd_maecredcrd_temp;
		DROP TABLE IF EXISTS sd_movhiscrd_temp;
	
		END FOREACH;
		
		ELSE  
			LET cCodRet ='01276';	
			UPDATE "informix".sw_verificastatusconsmsi
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';		
			RETURN cCodRet, iNoRegistros;
		
		END IF;
	
		SELECT COUNT(*) INTO iNoRegistros FROM "informix".sw_msi_consultagrid WHERE usuario = pUsuario and id='C';
		
		IF iNoRegistros = 0 THEN			
			LET cCodRet ='01276';	
			UPDATE "informix".sw_verificastatusconsmsi
			SET  status = 'E', error_proceso = 'S', error = cCodRet
			WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';		
			RETURN cCodRet, iNoRegistros;
		END IF;
		
	    UPDATE "informix".sw_verificastatusconsmsi 
		SET  status = 'T', error_proceso = 'N', total = iNoRegistros
		WHERE usuario_insert = pUsuario AND tipo_proceso = 'LECTURA';
		
		RETURN cCodRet, iNoRegistros;

	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 15/02/2021',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de las transaciones a MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_msi_consultamsicancel_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumCred CHAR(30),pProducto CHAR(4))
	RETURNING 	CHAR(5) AS codret,
				INTEGER AS total;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSP CHAR(6);
    DEFINE cMensajeRet CHAR(80);    
	DEFINE cNumCredito CHAR(20);
    DEFINE cCodTipCred CHAR(2);
	DEFINE cDescStatusCred CHAR(60);     
    DEFINE iIdUnidadProd INTEGER;
    DEFINE cCodCaract2 CHAR(3);
    DEFINE dtFechaOrigen DATE;
    DEFINE dtFechaProxPago DATE;
    DEFINE dPagoMinimo DECIMAL(18,2);
    DEFINE dtFechaUltPago DATE;
    DEFINE iPlazo INTEGER;
    DEFINE iPagosRealizados INTEGER;
    DEFINE dLineaOtorgada DECIMAL(18,2);    
    DEFINE dTasaInteres DECIMAL(9,6);
    DEFINE dTasaMoratorios DECIMAL(9,6);
    DEFINE dMontoSBC DECIMAL(14,2);    
    DEFINE dCapVig DECIMAL(18,2);
    DEFINE dCapTrans DECIMAL(18,2);
    DEFINE dCapVdoExig DECIMAL(18,2);
    DEFINE dCapVdoNoExig DECIMAL(18,2);
    DEFINE dSdoActCap DECIMAL(18,2);        
	DEFINE dIntVdo DECIMAL(18,2);
    DEFINE dIntMoratorio DECIMAL(18,2);
    DEFINE dIntMes DECIMAL(18,2);
    DEFINE dSdoActInt DECIMAL(18,2);    
	DEFINE dIntVig DECIMAL(18,2);
    DEFINE dIvaIntVig DECIMAL(18,2);
    DEFINE dIvaIntVdo DECIMAL(18,2);
    DEFINE dIvaIntMoratorio DECIMAL(18,2);
    DEFINE dIvaIntMes DECIMAL(18,2);
    DEFINE dSdoActIvaInt DECIMAL(18,2);    
    DEFINE dComPend DECIMAL(18,2);
    DEFINE dIvaCom DECIMAL(18,2);
    DEFINE dSdoRetenido DECIMAL(18,2);
    DEFINE dSdoTotalLiq DECIMAL(18,2);    
    DEFINE dIntDevengado DECIMAL(18,2);
    DEFINE dIvaIntDevengado DECIMAL(18,2);
    DEFINE dLineaDisponible DECIMAL(18,2);
    DEFINE dPagosVdos DECIMAL(18,2);
    DEFINE cDescBloqueoCta CHAR(60);
    DEFINE cDescCausaBloqueoCta CHAR(50);
    DEFINE cSitCte CHAR(1);
    DEFINE cCausaCte INTEGER;
    DEFINE cDescSitEspCte CHAR(75);
    DEFINE cSitCred CHAR(1);
    DEFINE cCausaCred INTEGER;
    DEFINE cDescSitEspCred CHAR(75);
	DEFINE dSaldo_pagar DECIMAL(18,2);
	DEFINE cFecha CHAR(10);
	DEFINE cPlazo CHAR(5);
	DEFINE cTarjeta CHAR(16);
	DEFINE cFolio CHAR(16);
	DEFINE cInfReceptor CHAR(40);
	DEFINE dMontoOtorgado DECIMAL(18,2);
	DEFINE iPromo INTEGER;
	DEFINE cCanal CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE iNoRegistros INTEGER;
	DEFINE cNumPago CHAR(5);
	DEFINE cNumSol CHAR(20);
	DEFINE iProd INTEGER;
	DEFINE cTipoConsulta CHAR(4);
	DEFINE cSol CHAR(20);
	DEFINE cTarjetaAux CHAR(16);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSP ='';
    LET cMensajeRet ='';
	LET cNumCredito ='';
    LET cCodTipCred ='';
	LET cDescStatusCred ='';   
    LET iIdUnidadProd =0;
    LET cCodCaract2 ='';
    LET dtFechaOrigen ='';
    LET dtFechaProxPago ='';
    LET dPagoMinimo =0;
    LET dtFechaUltPago ='';
    LET iPlazo =0;
    LET iPagosRealizados =0;
    LET dLineaOtorgada =0;
    LET dTasaInteres =0;
    LET dTasaMoratorios =0;
    LET dMontoSBC =0;
    LET dCapVig  =0;
    LET dCapTrans  =0;
    LET dCapVdoExig  =0;
    LET dCapVdoNoExig  =0;
    LET dSdoActCap  =0;        
	LET dIntVdo  =0;
    LET dIntMoratorio  =0;
    LET dIntMes  =0;
    LET dSdoActInt  =0;    
	LET dIntVig  =0;
    LET dIvaIntVig  =0;
    LET dIvaIntVdo  =0;
    LET dIvaIntMoratorio  =0;
    LET dIvaIntMes  =0;
    LET dSdoActIvaInt  =0;    
    LET dComPend  =0;
    LET dIvaCom  =0;
    LET dSdoRetenido  =0;
    LET dSdoTotalLiq  =0;    
    LET dIntDevengado  =0;
    LET dIvaIntDevengado  =0;
    LET dLineaDisponible  =0;
    LET dPagosVdos  =0;
    LET cDescBloqueoCta ='';
    LET cDescCausaBloqueoCta ='';
    LET cSitCte ='';
    LET cCausaCte =0;
    LET cDescSitEspCte ='';
    LET cSitCred ='';
    LET cCausaCred =0;
    LET cDescSitEspCred ='';
	LET dSaldo_pagar  =0;
	LET cFecha ='';
	LET cPlazo ='';
	LET cTarjeta ='';
	LET cFolio ='';
	LET cInfReceptor ='';
	LET dMontoOtorgado  =0;
	LET iPromo =0;
	LET cCanal ='';
	LET cSucursal ='';
	LET iNoRegistros =0;
	LET cNumPago ='';
	LET cNumSol ='';
	LET iProd =0;
	LET cTipoConsulta = '';
	LET cSol ='';
	LET cTarjetaAux = '';

	BEGIN

		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iNoRegistros;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/Daniel/sp_msi_consultamsicancel_totales.out';
		--TRACE ON;

		IF pUsuario ='' OR pIdFuncion='' OR pNumCred='' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        DELETE FROM "informix".sw_msi_consultagridcancel WHERE usuario = pUsuario;
		
		SELECT COUNT(*) INTO iProd FROM bdicred:"informix".sd_definicion WHERE edocta_param= 'tdc' and num_producto=pProducto;
		
		LET  cTipoConsulta = SUBSTR(pNumCred,1,4);
		
		IF  iProd = 0 AND cTipoConsulta='8900' THEN --Busca por promo msi 
				
		SELECT {+INDEX(bdicred:sd_movdiacrd idx_sd_movdiacrd1)} sucursal,fecha_mov,codigo_fun,num_credito,codigo_ref  FROM bdicred:"informix".sd_movdiacrd WHERE codigo_fun ='001' AND reversado= 'N' and num_credito = pNumCred INTO TEMP sd_movdiacrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_promocion_credito idx_sd_promocion_credito)}  num_tarjeta,num_sol_prestamo,folio_movto,num_promo,num_credito,SUBSTR(folio_suc,2,LENGTH(folio_suc)) as folio_suc,plazo FROM bdicred:"informix".sd_promocion_credito WHERE num_pro_prestamo = '8900' AND num_sol_prestamo= pNumCred INTO TEMP sd_promocion_credito_temp with no log;
		SELECT {+INDEX(bdicred:sd_maesdoscrd idx_maesdoscrd1)}  monto_otorgado,num_credito FROM bdicred:"informix".sd_maesdoscrd WHERE num_credito= pNumCred INTO TEMP sd_maesdoscrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_movhiscrd movhistocrd)}  sucursal,fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref FROM bdicred:"informix".sd_movhiscrd WHERE empresa = '001' AND codigo_fun ='001' AND reversado= 'N' and num_credito = pNumCred INTO TEMP sd_movhiscrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_msi_cancela_credito_msi idx_can_msi1)}  num_credito FROM bdicred:"informix".sd_msi_cancela_credito_msi WHERE num_credito = pNumCred INTO TEMP sd_msi_cancela_credito_msi_temp with no log;
		
		FOREACH 

			   SELECT num_tarjeta INTO cTarjetaAux FROM (
				select 
				
				b.num_tarjeta from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
		
				UNION 

				select b.num_tarjeta from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				)
				group by num_tarjeta

		FOREACH WITH HOLD 		
				SELECT * 
				INTO cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,cNumSol
				FROM
				(select 
						{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}
				
				TO_CHAR(a.fecha_mov,"%d/%m/%Y"), d.infreceptor,b.folio_movto,e.monto_otorgado, b.plazo,b.num_tarjeta, b.num_promo,c.canal,a.sucursal,b.num_sol_prestamo				
				from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX(intercard:movimiento idx_movimientonew1a)}  secuenciaextendida,infreceptor from intercard:"informix".movimiento where numtarjeta= cTarjetaAux)d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				left outer join bdicred:"informix".sd_msi_cancela_credito_msi_temp g ON g.num_credito = b.num_sol_prestamo
				WHERE g.num_credito is null
				UNION 
				select  
						{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}
				
				TO_CHAR(a.fecha_mov,"%d/%m/%Y"), d.infreceptor,b.folio_movto,e.monto_otorgado, b.plazo,b.num_tarjeta, b.num_promo,c.canal,a.sucursal,b.num_sol_prestamo				
				from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX( intercard:"informix".movimientohistorico idx_movimiento1)}   secuenciaextendida,infreceptor from intercard:"informix".movimientohistorico where numtarjeta= cTarjetaAux) d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				left outer join bdicred:"informix".sd_msi_cancela_credito_msi_temp g ON g.num_credito = b.num_sol_prestamo
				WHERE g.num_credito is null)
				
				EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',cNumSol) INTO 
				cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
				dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
				dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
				dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
				dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
				cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
				cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 

				select capital_mto_cuota,num_pago INTO dSaldo_pagar,cNumPago FROM (SELECT FIRST 1 capital_mto_cuota,num_pago from bdicred:"informix".sd_amortiza_creditocrd where num_credito =cNumSol  AND capital_fecha_pago IS NOT NULL ORDER BY fecha_cuota DESC);
				
				IF dSaldo_pagar is null THEN
				  LET dSaldo_pagar = 0;
				END IF;
				
				IF cNumPago is null THEN
				  LET cNumPago = '0';
				END IF;
				
				LET cPlazo =TRIM(iPlazo::CHAR(5))  ||'/'|| TRIM(cNumPago);
				
				INSERT INTO "informix".sw_msi_consultagridcancel(usuario,fecha,infreceptor,folio,montootorgado,plazo,tarjeta,promo,canal,sucursal,saldoliq,saldopag,numcredito)
				VALUES (pUsuario,cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSdoTotalLiq,dSaldo_pagar,cNumSol);
				
		END FOREACH;
		END FOREACH;
		
		DROP TABLE IF EXISTS sd_movdiacrd_temp;
		DROP TABLE IF EXISTS sd_promocion_credito_temp;
		DROP TABLE IF EXISTS sd_maesdoscrd_temp;
		DROP TABLE IF EXISTS sd_movhiscrd_temp;
		DROP TABLE IF EXISTS sd_msi_cancela_credito_msi_temp;
		
		ELIF iProd = 1 THEN --Busca por num_credito todas las promociones de msi asociadas

        FOREACH 
        select num_sol_prestamo INTO cSol FROM bdicred:"informix".sd_promocion_credito 
        WHERE num_credito =pNumCred AND num_pro_prestamo = '8900'
		
		SELECT {+INDEX(bdicred:sd_movdiacrd idx_sd_movdiacrd1)} sucursal,fecha_mov,codigo_fun,num_credito,codigo_ref  FROM bdicred:"informix".sd_movdiacrd WHERE codigo_fun ='001' AND reversado= 'N' and num_credito = cSol INTO TEMP sd_movdiacrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_promocion_credito idx_sd_promocion_credito)}  num_tarjeta,num_sol_prestamo,folio_movto,num_promo,num_credito,SUBSTR(folio_suc,2,LENGTH(folio_suc)) as folio_suc,plazo FROM bdicred:"informix".sd_promocion_credito WHERE num_pro_prestamo = '8900' AND num_sol_prestamo= cSol INTO TEMP sd_promocion_credito_temp with no log;
		SELECT {+INDEX(bdicred:sd_maesdoscrd idx_maesdoscrd1)}  monto_otorgado,num_credito FROM bdicred:"informix".sd_maesdoscrd WHERE num_credito= cSol INTO TEMP sd_maesdoscrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_movhiscrd movhistocrd)}  sucursal,fecha_mov,hora_mov,folio_suc,codigo_fun,referencia,num_credito,codigo_ref FROM bdicred:"informix".sd_movhiscrd WHERE empresa = '001' AND codigo_fun ='001' AND reversado= 'N' and num_credito = cSol INTO TEMP sd_movhiscrd_temp with no log;
		SELECT {+INDEX(bdicred:sd_msi_cancela_credito_msi idx_can_msi1)}  num_credito FROM bdicred:"informix".sd_msi_cancela_credito_msi WHERE num_credito = cSol INTO TEMP sd_msi_cancela_credito_msi_temp with no log;
		
		FOREACH 

			   SELECT num_tarjeta INTO cTarjetaAux FROM (
				select 
					
				b.num_tarjeta from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo

				UNION 
					
				select b.num_tarjeta from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				)
				group by num_tarjeta
     
			FOREACH WITH HOLD 		
				SELECT * 
				INTO cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,cNumSol
				FROM
				(select
						{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}
				
				TO_CHAR(a.fecha_mov,"%d/%m/%Y"), d.infreceptor,b.folio_movto,e.monto_otorgado, b.plazo,b.num_tarjeta, b.num_promo,c.canal,a.sucursal,b.num_sol_prestamo				
				from bdicred:"informix".sd_movdiacrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX(intercard:movimiento idx_movimientonew1a)}  secuenciaextendida,infreceptor from intercard:"informix".movimiento where numtarjeta= cTarjetaAux)d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				left outer join bdicred:"informix".sd_msi_cancela_credito_msi_temp g ON g.num_credito = b.num_sol_prestamo				
				WHERE g.num_credito is null
				UNION 
				select  
						{+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}

				TO_CHAR(a.fecha_mov,"%d/%m/%Y"), d.infreceptor,b.folio_movto,e.monto_otorgado, b.plazo,b.num_tarjeta, b.num_promo,c.canal,a.sucursal,b.num_sol_prestamo				
				from bdicred:"informix".sd_movhiscrd_temp a 
				inner join bdicred:"informix".sd_promocion_credito_temp b on a.num_credito = b.num_sol_prestamo
				inner join bdicred:"informix".sd_transfun c on a.codigo_fun=c.codigo_fun and a.codigo_ref = c.codigo_ref
				inner join (select {+INDEX( intercard:"informix".movimientohistorico idx_movimiento1)}   secuenciaextendida,infreceptor from intercard:"informix".movimientohistorico where numtarjeta= cTarjetaAux) d on b.folio_suc = d.secuenciaextendida
				inner join bdicred:"informix".sd_maesdoscrd_temp e on a.num_credito = e.num_credito 
				left outer join bdicred:"informix".sd_msi_cancela_credito_msi_temp g ON g.num_credito = b.num_sol_prestamo
				WHERE g.num_credito is null)
				
				EXECUTE PROCEDURE bdicred:sp_consulta_saldos_general ('001',cSol) INTO 
				cCodRetSP,cMensajeRet,cNumCredito,cCodTipCred,dtFechaOrigen,dtFechaProxPago,
				dPagoMinimo,dtFechaUltPago,iPlazo,iPagosRealizados,dLineaOtorgada,dTasaInteres,
				dTasaMoratorios,dMontoSBC,dCapVig,dCapTrans, dCapVdoExig, dCapVdoNoExig,dSdoActCap,
				dIntVig,dIntVdo,dIntMoratorio, dIntMes, dSdoActInt,dIvaIntVig,dIvaIntVdo,
				dIvaIntMoratorio,dIvaIntMes,dSdoActIvaInt, dComPend,dIvaCom, dSdoRetenido,
				dSdoTotalLiq, dIntDevengado,dIvaIntDevengado,dLineaDisponible,dPagosVdos,
				cDescStatusCred,iIdUnidadProd, cDescBloqueoCta,cCodCaract2, cDescCausaBloqueoCta,
				cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred; 

				select capital_mto_cuota,num_pago INTO dSaldo_pagar,cNumPago FROM (SELECT FIRST 1 capital_mto_cuota, num_pago from bdicred:"informix".sd_amortiza_creditocrd where num_credito =cSol  AND capital_fecha_pago IS NOT NULL ORDER BY fecha_cuota DESC);
				
				IF dSaldo_pagar is null THEN
				  LET dSaldo_pagar = 0;
				END IF;
				
				IF cNumPago is null THEN
				  LET cNumPago = '0';
				END IF;
				
				LET cPlazo =   TRIM(iPlazo::CHAR(5))||'/'||TRIM(cNumPago);
				
				INSERT INTO "informix".sw_msi_consultagridcancel(usuario,fecha,infreceptor,folio,montootorgado,plazo,tarjeta,promo,canal,sucursal,saldoliq,saldopag,numcredito)
				VALUES (pUsuario,cFecha,cInfReceptor,cFolio,dMontoOtorgado,cPlazo, cTarjeta, iPromo, cCanal, cSucursal,dSdoTotalLiq,dSaldo_pagar,cNumSol);
				
			END FOREACH;
    
        END FOREACH;
		
		DROP TABLE IF EXISTS sd_movdiacrd_temp;
		DROP TABLE IF EXISTS sd_promocion_credito_temp;
		DROP TABLE IF EXISTS sd_maesdoscrd_temp;
		DROP TABLE IF EXISTS sd_movhiscrd_temp;
		DROP TABLE IF EXISTS sd_msi_cancela_credito_msi_temp;
		
		END FOREACH;
		
		ELSE  
			LET cCodRet ='01278';				
			RETURN cCodRet, iNoRegistros;
		
		END IF;
		
		SELECT COUNT(*) INTO iNoRegistros FROM "informix".sw_msi_consultagridcancel WHERE usuario = pUsuario;
		
		IF iNoRegistros = 0 THEN 
			LET cCodRet = '01278';
		END IF;
		
		RETURN cCodRet, iNoRegistros;
 
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 26/04/2021',
'FUNCIONALIDAD: CONSULTA MSI',
'DESCRIPCION: SPL que realiza la consulta de las transaciones a MSI',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_bloqueoctacap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pImporte MONEY(14,2), pFechaProceso DATE, pClaveBloq CHAR(2), pOpcBloque INTEGER, pAreaSolic CHAR(2), pMotivoBloq CHAR(2))
	RETURNING CHAR(5) AS codret,
                CHAR(5) as clave;
                
        DEFINE cEmpresa CHAR(3);
        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(3);
        DEFINE iSqlErr INTEGER;
        DEFINE cClaveAreaSolic CHAR(1);
        DEFINE cTipoBloqueo CHAR(1);
        DEFINE cClave CHAR(5);
        
        LET cEmpresa = '001';
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iSqlErr = 0;
        LET cClaveAreaSolic = '';
        LET cTipoBloqueo = '';
        LET cClave = '';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cClave;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_bloqueoctacap.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pFechaProceso = '' OR pCuenta = '' OR pImporte = '' OR pOpcBloque = '' OR pClaveBloq = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cClave;
                END IF;
                
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cClave;
                END IF;
                

                -- Obtenemos el codigo de area solicitante
                IF pAreaSolic = '' or pAreaSolic  is null THEN 
                        SELECT cod_area
                        INTO cClaveAreaSolic
                        FROM bdicheq:"informix".sc_ctabloqueo
                        WHERE cuenta = pCuenta;
                ELSE
                        SELECT codigo
                        INTO cClaveAreaSolic
                        FROM bdicheq:"informix".sc_areabloqueo
                        WHERE TRIM(clave) = TRIM(pAreaSolic);
                END IF;
                
                -- Obtenemos la opcion de motivo de bloqueo
                
                SELECT codigo
                INTO cTipoBloqueo
                FROM bdicheq:"informix".sc_tipobloqueo
                WHERE TRIM(clave) = TRIM(pMotivoBloq);
                
                -- Se ejecuta el bloqueo
                EXECUTE PROCEDURE bdicheq:"informix".bloqueo_cta(cEmpresa, pCuenta, pImporte, pClaveBloq, pOpcBloque, 
                                                      pFechaProceso, pUsuario, ' ', pAreaSolic, cClaveAreaSolic, pMotivoBloq, cTipoBloqueo)
                INTO cCodRetSp, cClave;

                IF cCodRetSp = '110' THEN
                        LET cCodRet = '00003';
                ELIF cCodRetSp = '162' THEN -- Verifica el saldo a congelar
                        LET cCodRet = '00101';
                ELIF cCodRetSp = '163' THEN -- Verifica el saldo a desbloquear de la cuenta
                        LET cCodRet = '00102';
                ELIF cCodRetSp = '100' THEN -- Verifica que la cuenta existe
                        LET cCodRet = '00009';
                ELIF cCodRetSp = '302' THEN -- Cuenta activa y no bloqueada
                        LET cCodRet = '00103';
                ELIF cCodRetSp = '200' THEN -- Cuenta no cancelada
                        LET cCodRet = '00104';
                ELIF cCodRetSp = '303' THEN -- pmonto >  sdoa_w - sdoc_w
                        LET cCodRet = '00105';
                END IF;
				
                --ACTUALIZACION DE ESTATUS 
				IF cCodRet = '00000' AND pIdFuncion = 'DBD304' THEN 
					UPDATE bdicheq:"informix".sc_cuentas_retiro SET estatus = 'R', no_empleado = pUsuario 
					WHERE cuenta = pCuenta;
				END IF;
				
                RETURN cCodRet, cClave;
                
        END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 21/08/2013",
"DESCRIPCION: Realiza el bloqueo o desbloqueo de una cuenta de captacion para la aplicacion CNSIFWEB",
"AUTOR: Veronica Sanchez Tlacomulco",
"FECHA: 25/03/2023",
"DESCRIPCION: Se realizo ajuste a SP para realizar el cambio de estatus en la tabla sc_cuentas_retiro cuando se reaiza un desbloqueo";

CREATE PROCEDURE "informix".sp_consultatotalreportedetallesolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pProducto CHAR(4), pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5) AS codret, 
        INTEGER AS total_registros;
                        
    DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cNumSolicitud CHAR(20);     
	DEFINE cSucursal CHAR(4);      
	DEFINE vNombreCte VARCHAR(100); 
	DEFINE dFechaSol DATE;         
	DEFINE dFechaCambio     DATE;         
	DEFINE cRevaluada CHAR(2);      
	DEFINE cReferenciaCoppel CHAR(20);     
	DEFINE dcEficienciaCoppel DECIMAL(18,2);
	DEFINE sMesesCoppel     SMALLINT;        
	DEFINE dcVencidoCoppel DECIMAL(18,2);
	DEFINE iVencidoCoppeludis INTEGER;      
	DEFINE cPuntualidad CHAR(2);      
	DEFINE iScoring1        INTEGER;      
	DEFINE iScoring2 INTEGER;      
	DEFINE cDescStatus CHAR(40);     
	DEFINE cCausaSolic CHAR(3);      
	DEFINE vComentario VARCHAR(100); 
	DEFINE cAnalista CHAR(45);     
	DEFINE cTipoMovto CHAR(10);     
	DEFINE cNombreProducto CHAR(50);     
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE dHoraInicio DATETIME HOUR TO SECOND;
	DEFINE dHoraFin DATETIME HOUR TO SECOND;
	DEFINE iSolicitudesProcesadas	INTEGER;
	DEFINE cBeginWork	CHAR(01);
	DEFINE bandera CHAR(2);
	
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		ROLLBACK WORK;
		IF (bandera = "S") THEN
			BEGIN WORK;
		END IF;
		UPDATE "informix".status_repsolicitudmc
		SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
		RETURN cCodRet, iRegistros;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		LET bandera = "S";
		ROLLBACK WORK;
        BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    LET bandera = "N";

   BEGIN WORK;
   
   
		LET cCodRet = '00000';
		LET cCodRetSp = '';
		LET iCodRet = 0;
		LET iSqlErr = 0;
		LET cNumSolicitud = '';     
		LET cSucursal = '';      
		LET vNombreCte = ''; 
		LET dFechaSol = DATE(1);
		LET dFechaCambio = DATE(1);         
		LET cRevaluada = '';      
		LET cReferenciaCoppel = '';     
		LET dcEficienciaCoppel = NULL;
		LET sMesesCoppel = 0;    
		LET dcVencidoCoppel = NULL;
		LET iVencidoCoppeludis = 0;      
		LET cPuntualidad = '';      
		LET iScoring1 = 0;      
		LET iScoring2 = 0;     
		LET cDescStatus = '';     
		LET cCausaSolic = '';      
		LET vComentario = '';
		LET cAnalista = '';     
		LET cTipoMovto = '';    
		LET cNombreProducto = '';    
		LET iRegistros = 0;
		LET iRecuperacion = 0;
		LET dHoraInicio = NULL;
		LET dHoraFin = NULL;
		LET iSolicitudesProcesadas = 0;
		LET cBeginWork	= '0';
		LET bandera = 'N';
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultatotalreportedetallesolicitudmc.out';
		--SET DEBUG FILE TO '/informix/c90235391/sp_consultatotalreportedetallesolicitudmc.out';
		--TRACE ON;

		
		-- SE LIMPIA TABLA POR USUARIO
		--BEGIN;
			DELETE FROM "informix".status_repsolicitudmc WHERE usuario_insert = TRIM(pUsuario);
			INSERT INTO "informix".status_repsolicitudmc(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		--COMMIT;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			--BEGIN;
			UPDATE "informix".status_repsolicitudmc
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF (bandera = "S") THEN
				BEGIN WORK;
			END IF;

			RETURN cCodRet, iRegistros;
		END IF;
			
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			UPDATE "informix".status_repsolicitudmc
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF (bandera = "S") THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet, iRegistros;
		END IF;         
		
		--BEGIN ;
			DELETE FROM bdicnweb:"informix".sw_reportesolicitudmc WHERE usuario = pUsuario;
		--COMMIT;
		
		FOREACH
			
			EXECUTE PROCEDURE bdicred:"informix".sp_consultadetallesolicitudmc(pFechaInicio, pFechaFin, pProducto)
			INTO cCodRetSp, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto
			
			LET iCodRet = cCodRetSp::INTEGER;
			IF iCodRet < 0 THEN
				RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultadetallesolicitudmc';
			ELIF iCodRet = 3 THEN
				LET cCodRet = '00017';
				UPDATE "informix".status_repsolicitudmc
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;

				IF (bandera = "S") THEN
					BEGIN WORK;
				END IF;
				
				RETURN cCodRet, iRegistros;
			END IF;
			
			
			INSERT INTO bdicnweb:"informix".sw_reportesolicitudmc 
			VALUES(cCodRetSp, cNumSolicitud, cSucursal, vNombreCte, dFechaSol, dFechaCambio, cRevaluada,
			cReferenciaCoppel, dcEficienciaCoppel, sMesesCoppel, dcVencidoCoppel, iVencidoCoppeludis,      
			cPuntualidad, iScoring1, iScoring2, cDescStatus, cCausaSolic, vComentario, cAnalista,     
			cTipoMovto, cNombreProducto, dHoraInicio, dHoraFin, pUsuario);

			COMMIT;
			BEGIN;

		END FOREACH;
		
		SELECT COUNT(*) INTO iRegistros FROM bdicnweb:"informix".sw_reportesolicitudmc WHERE usuario = pUsuario;
		
		IF iRegistros = 0 THEN
			LET cCodRet = '00017';

			UPDATE "informix".status_repsolicitudmc
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF (bandera = "S") THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet,iRegistros;
		END IF;

		--BEGIN ;
			UPDATE "informix".status_repsolicitudmc
			SET status = 'T', error_proceso = 'N', num_registros = iRegistros WHERE usuario_insert = pUsuario;
		--COMMIT ;
		
		IF bandera = "S" THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet, iRegistros;
			
--END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 06/03/2014',
'DESCRIPCION: Genera un conteo del detalle de todas las solicitudes de credito que fueron analizadas por Mesa de Control Estatus = MC',
'AUTOR: Oscar Flores Conde',
'FECHA: 11/01/2016',
'DESCRIPCION: Se agrega la hora de inicio de atenciÃ³n de la solicitud y la hora de finalizaciÃ³n',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 07/09/2018',
'DESCRIPCION: Se implementa tratado de volumetrÃ­a.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 25/09/2018',
'DESCRIPCION: Se implementa tratado de codigo de error 00003 del spl sp_consultadetallesolicitudmc.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 03/10/2018',
'DESCRIPCION: Se actualiza ejecuciÃ³n de spl productivo sp_consultadetallesolicitudmc (se eliminan los retornos dHoraInicio y dHoraFin).',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_mc_reportecacdetallado_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE)
    RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
	
    DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRetSp CHAR(150);
    DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNumRegistros INTEGER;
			
	DEFINE cDescripcion CHAR(80);
	DEFINE cFecha_autorizacion CHAR(10);
	DEFINE cNum_solicitud CHAR(20);
	DEFINE cNum_sucursal CHAR(4);
	DEFINE cNum_cliente CHAR(20);
	DEFINE cNombre_cte CHAR(104);
	DEFINE cComp_ingreso_valido CHAR(2);
	DEFINE cGrupo_cte CHAR(1);
	DEFINE dIngreso_declarado DECIMAL(20,2);
	DEFINE dCompromisos_sic DECIMAL(20,2);
	DEFINE dCompromisos_bco DECIMAL(20,2);
	DEFINE dCompromisos_cop DECIMAL(20,2);
	DEFINE dLinea_coppel DECIMAL(20,2);
	DEFINE dLinea_sug DECIMAL(20,2);
	DEFINE dIngreso_valido_mc DECIMAL(20,2);
	DEFINE dLinea_sug_mc DECIMAL(20,2);
	DEFINE cStatus_final CHAR(20);
	DEFINE cAnalista_cac_atend CHAR(45);
	DEFINE cObservaciones CHAR(300);
	DEFINE iSolicitudesProcesadas INTEGER;
	DEFINE cBeginWork	CHAR(01);
	DEFINE bandera CHAR(2);
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			IF bandera = 'S' THEN
				BEGIN WORK;
			END IF;
			
			UPDATE "informix".status_rep_detallado SET status = 'E', error_proceso = 'S', error = cCodRet 
			WHERE usuario_insert = pUsuario;
			--COMMIT WORK;
			
			RETURN cCodRet,iNumRegistros;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)
		LET bandera = "S";
		ROLLBACK WORK;
        BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	LET bandera = "N";
	
    BEGIN WORK;
		
	LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '';
	LET cDescCodRetSp = '';
    LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNumRegistros = 0;

	LET cDescripcion = '';
	LET cFecha_autorizacion = '';
	LET cNum_solicitud = '';
	LET cNum_sucursal = '';
	LET cNum_cliente = '';
	LET cNombre_cte = '';
	LET cComp_ingreso_valido = '';
	LET cGrupo_cte = '';
	LET dIngreso_declarado = 0.00;
	LET dCompromisos_sic = 0.00;
	LET dCompromisos_bco = 0.00;
	LET dCompromisos_cop = 0.00;
	LET dLinea_coppel = 0.00;
	LET dLinea_sug = 0.00;
	LET dIngreso_valido_mc = 0.00;
	LET dLinea_sug_mc = 0.00;
	LET cStatus_final = '';
	LET cAnalista_cac_atend = '';
	LET cObservaciones = '';
	LET iSolicitudesProcesadas = 0;
	LET cBeginWork	= '0';	
	LET bandera = 'N';
	
		--SET DEBUG FILE TO '/tmp/mfinis/sp_mc_reportecacdetallado_totales.out';
		--TRACE ON;
		
		-- SE LIMPIA TABLA POR USUARIO
		DELETE FROM "informix".status_rep_detallado WHERE usuario_insert = TRIM(pUsuario);
		INSERT INTO "informix".status_rep_detallado(usuario_insert,status,num_registros,error_proceso,error) VALUES(pUsuario,'I',0,'',cCodRet);
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio IS NULL OR pFechaFin IS NULL THEN
			LET cCodRet = '00003';
			--BEGIN WORK;
				UPDATE "informix".status_rep_detallado
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF bandera = "S" THEN
				COMMIT;
			END IF;
			
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			UPDATE "informix".status_rep_detallado
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF bandera = "S" THEN
				COMMIT;
			END IF;
			
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		--BEGIN WORK;
			DELETE FROM "informix".sw_mc_rep_cac_detallado WHERE usuario = pUsuario;
		--COMMIT WORK;
		
		FOREACH
		
			EXECUTE PROCEDURE bdisolic:"informix".sp_reporte_cac_detallado(pFechaInicio,pFechaFin)
			INTO cCodRetSp, cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisolic:sp_reporte_cac_detallado';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003'; 
				
				UPDATE "informix".status_rep_detallado
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;		
				
				IF (bandera = "S") THEN
					BEGIN WORK;
				END IF;
				
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00154'; 
				
				UPDATE "informix".status_rep_detallado
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				
				IF (bandera = "S") THEN
					BEGIN WORK;
				END IF;
				
				RETURN cCodRet,iNumRegistros;
			ELIF cCodRetSp::INTEGER = 3 THEN
				LET cCodRet = '01096'; --NO EXISTE INFORMACIÃN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
				
				UPDATE "informix".status_rep_detallado
				SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				
				IF (bandera = "S") THEN
					BEGIN WORK;
				END IF;
				
				RETURN cCodRet,iNumRegistros;
			END IF;
		
			INSERT INTO "informix".sw_mc_rep_cac_detallado VALUES(cDescripcion, cFecha_autorizacion, cNum_solicitud, cNum_sucursal, cNum_cliente, cNombre_cte, cComp_ingreso_valido, cGrupo_cte, 
			dIngreso_declarado, dCompromisos_sic, dCompromisos_bco, dCompromisos_cop, dLinea_coppel, dLinea_sug, dIngreso_valido_mc, dLinea_sug_mc, cStatus_final, cAnalista_cac_atend, cObservaciones, pUsuario);

			COMMIT;
			BEGIN;
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iNumRegistros FROM "informix".sw_mc_rep_cac_detallado WHERE usuario = pUsuario;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '01096'; --NO EXISTE INFORMACIÃN PARA EL TIPO DE REPORTE SELECCIONADO, VERIFIQUE
			
			UPDATE "informix".status_rep_detallado
			SET status = 'E', error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
			
			IF bandera = "S" THEN
				BEGIN WORK;
			END IF;
			
			RETURN cCodRet,iNumRegistros;
		END IF;
		
		UPDATE "informix".status_rep_detallado
		SET status = 'T', error_proceso = 'N', num_registros = iNumRegistros WHERE usuario_insert = pUsuario;  
		
		IF bandera = "S" THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,iNumRegistros;
		
    --END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 28/08/2018',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: REPORTE DE ESTATUS DE SOLICITUDES',
'Descripcion: SPL encargado de consultar el nÃºmero total de registros del reporte detallado de las solicitudes de credito.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cre_capturactecreditocoppel(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pNumCte CHAR(20), pNombre CHAR(104), pSucursal CHAR(4), pFechaSolicitud  CHAR(20), pNumAut1 CHAR(8), pNumAut2 CHAR(8), pStatus CHAR(1))
		RETURNING CHAR(5) AS codret;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE vNomAut1 CHAR(80);
	DEFINE vNomAut2 CHAR(80);
	DEFINE iNoRegistros INTEGER;
	DEFINE DfechaSol DATE; 	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET vNomAut1  = '';
	LET vNomAut2  = '';
	LET iNoRegistros = 0;
	LET DfechaSol = DATE(1);
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268)
			LET cCodRet = '00284';
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/ifxsif01/roman/ambientacion/TDC_INFINITE/Spl/sp_cre_capturactecreditocoppel.out';
		--TRACE ON;
		
		--IF pUsuario = '' OR pIdFuncion = '' OR  pNumSolicitud = '' OR  pNumCte = '' OR  pNombre = '' OR  pSucursal = '' OR pFechaSolicitud IS NULL OR  pNumAut1 = '' OR  pNumAut1 = '' OR  pNumAut2 = '' OR  pNumAut2 = '' OR  pStatus= ''  THEN
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pNombre = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		


		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pNumSolicitud <> '' THEN 
		
			--Extraer la fecha de la solicitud de credito--
		 
			select fecha_insert 
			INTO DfechaSol 
			from bdisolic:"informix".ss_solicitudes 
			where empresa ='001' 
			AND num_solicitud = pNumSolicitud;
		END IF;
		
		IF pNumAut1 <> '' THEN
			SELECT nombre
			INTO  vNomAut1
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pNumAut1;		
		END IF;
		
		IF pNumAut2 <> '' THEN
			SELECT nombre
			INTO  vNomAut2
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pNumAut2;		
		END IF;
		
		INSERT INTO bdisolic:"informix".ss_clientes_exentos_rgc(fecha_insert, num_solicitud, numcte, nombre_cte, sucursal, fecha_sol, num_autorizador1, nombre_autorizador1, num_autorizador2, nombre_autorizador2, activo)
		VALUES (CURRENT, pNumSolicitud, pNumCte, pNombre, pSucursal, DfechaSol, pNumAut1, vNomAut1, pNumAut2, vNomAut2, pStatus);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            LET cCodRet = '00282';
            RETURN cCodRet;
        END IF;         
        RETURN cCodRet;
    END;    
END PROCEDURE           
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/05/2016',
'MODULO: CREDITO',
'FUNCIONALIDAD: CREDITO GRUPO COPPEL',
'DESCRIPCION:SPL que realiza la captura de los clientes que aceptados o rechazados en el crÃÂ©dito de grupo coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_repctasinactivasart61(pUsuario CHAR(8), pIdFuncion CHAR(10), pReporte CHAR(2), pRutaDescarga CHAR(100), pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60), pIdReporte CHAR(20))
RETURNING CHAR(5) AS codret;		

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCmd1 CHAR(3000);
	DEFINE cSql CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE iCont INTEGER;
    DEFINE sCommit SMALLINT;
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE dFechaConsulta DATE;
	DEFINE dFechaMax DATE;
	DEFINE dFechaMin DATE;
	DEFINE cReporte CHAR(100);
	DEFINE cRutaGral CHAR(100);
	DEFINE iNumRegistros INTEGER;
	DEFINE cNombreReporte CHAR(100);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	
	DEFINE cEstatus CHAR(1);
	DEFINE cDescEstatus CHAR(30);
	DEFINE cNum_cuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cNum_cliente CHAR(20);
	DEFINE dFech_ult_dep DATE;
	DEFINE dFech_ult_ret DATE;
	DEFINE dFecha_inf DATE;
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApell_paterno CHAR(26);
	DEFINE cApell_materno CHAR(26);
	DEFINE cSucursal CHAR(4);
	DEFINE cDescSucursal CHAR(40);
	DEFINE cEstado CHAR(2);
	DEFINE cDescEstado CHAR(30);
	DEFINE cDescProducto CHAR(30);
	DEFINE dFechaAlta DATE;
	DEFINE dFecha_ult_mov DATE;
	
	DEFINE cDescProducto_con CHAR(40);
	DEFINE cNom_cliente CHAR(107);
	DEFINE dFecha_con DATE;
	DEFINE cImporte_con CHAR(20);
	DEFINE cInteres_gen CHAR(16);
	
	DEFINE dFecha_des DATE;
	DEFINE cInteres_gen_des DECIMAL(14,2);
	DEFINE cPago_sdo_concentra DECIMAL(18,2);
	
	DEFINE dFecha_tra DATE;
	DEFINE cInteres_gen_can DECIMAL(14,2);
	DEFINE cSdo_trasp_beneficiencia DECIMAL(18,2);
	
	DEFINE v_producto CHAR(4);
	DEFINE v_nombre   CHAR(40);
	
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);
	DEFINE cStr9 CHAR(60);
	DEFINE cStr10 CHAR(60);
	DEFINE cStr11 CHAR(60);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCmd1 = '';
	LET cSql = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET iCont = 0;
    LET sCommit = 0;
	LET cRutaInformix = '/ifxsif01/bin/';
	--LET cRutaInformix = '/informix/bin/';
	LET cUsrBin = '/usr/bin/';
	LET dFechaConsulta = '';
	LET dFechaMax = '';
	LET dFechaMin = '';
	LET cReporte = '';
	LET cRutaGral = '';
	LET iNumRegistros = 0;
	LET cNombreReporte = '';
	LET cNombreReporteHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	
	LET cEstatus = '';
	LET cDescEstatus = '';
	LET cNum_cuenta = '';
	LET cProducto = '';
	LET cNum_cliente = '';
	LET dFech_ult_dep = '';
	LET dFech_ult_ret = '';
	LET dFecha_inf = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApell_paterno = '';
	LET cApell_materno = '';
	LET cSucursal = '';
	LET cDescSucursal = '';
	LET cEstado = '';
	LET cDescEstado = '';
	LET cDescProducto = '';
	LET dFechaAlta = '';
	LET dFecha_ult_mov = '';
	
	LET cDescProducto_con = '';
	LET cNom_cliente = '';
	LET dFecha_con = '';
	LET cImporte_con = '';
	LET cInteres_gen = '';
	
	LET dFecha_des = '';
	LET cInteres_gen_des = 0.00;
	LET cPago_sdo_concentra = 0.00;
	
	LET dFecha_tra = '';
	LET cInteres_gen_can = 0.00;
	LET cSdo_trasp_beneficiencia = 0.00;
	
	LET dHoy = '';
	LET cStr7 = ''; 
	LET cStr8 = ''; 
	LET cStr9 = '';
	LET cStr10 = '';
	LET cStr11 = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
		
	BEGIN

		ON EXCEPTION SET iSqlErr
		
			SET DEBUG FILE TO '/resplogifx/conciliachq/sp_repctasinactivasart61.out';
			TRACE ON;
			
			LET cCodRet = iSqlErr;
						
			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			TRACE OFF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_repctasinactivasart61.out';
		--SET DEBUG FILE TO '/informix/rsv/ART61/TASF/bdicnweb/sp_repctasinactivasart61.out';

		IF pUsuario = '' OR pIdFuncion = '' OR pReporte = '' OR pRutaDescarga = ''  OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';			
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		LET cNombreReporte = TRIM(pIdReporte)||'_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y')||'.csv';
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		-- OBTIENE LA FECHA HOY Y DEFINE PERIODO DE CONSULTA
		SELECT fecha_hoy INTO dFechaConsulta FROM bdicheq:"informix".sc_fechas WHERE empresa = cEmpresa;		
		
		LET dFechaMax = LAST_DAY(dFechaConsulta - 1 UNITS MONTH);
		LET dFechaMin = TO_DATE(1||'/'||MONTH(dFechaMax)||'/'||YEAR(dFechaMax),'%d/%m/%Y');
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- CUENTAS INFORMADAS
		IF pReporte = '1' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctasinformadas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctasinformadas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'INFORMADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '5';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
			SELECT  inf.cuenta,inf.producto,inf.num_cte,inf.fech_ult_dep,inf.fech_ult_ret,inf.fecha_marc
			FROM    bdicheq:sc_ctasinformadas AS inf 
			WHERE   inf.fecha_marc BETWEEN dFechaMin AND dFechaMax
			INTO    TEMP tmp_infdas WITH NO LOG;
				
			CREATE INDEX idx_tmp_infdas 
            ON tmp_infdas (cuenta,fecha_marc);

			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH
			FOREACH WITH HOLD

			    SELECT a.cuenta,   a.producto, a.num_cte,    a.fech_ult_dep, a.fech_ult_ret, a.fecha_marc
				INTO   cNum_cuenta,cProducto,  cNum_cliente, dFech_ult_dep,  dFech_ult_ret,  dFecha_inf
				FROM   tmp_infdas as a, 
				       bdicheq:sc_ctasinformadas as b
                where  a.cuenta     = b.cuenta 
                and    a.fecha_marc = b.fecha_marc				
				AND    a.fecha_marc = (SELECT MIN(b.fecha_marc) 
				                          FROM   bdicheq:sc_ctasinformadas b 
			  	                          WHERE  b.cuenta = a.cuenta)
				
				SELECT nombre1,nombre2,apell_paterno,apell_materno
				INTO   cNombre1,cNombre2,cApell_paterno,cApell_materno
				FROM   bdinteg:"informix".si_cliente WHERE numcte = cNum_cliente;
				
				SELECT sucursal INTO cSucursal FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNum_cuenta AND producto = cProducto;
				
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				SELECT fecha_alta INTO dFechaAlta FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;
								
				INSERT INTO bdicnweb:"informix".sw_det_ctasinformadas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(cProducto)||' '||TRIM(cDescProducto),cNum_cliente,TRIM(TRIM(cNombre1)||' '||TRIM(cNombre2))||' '||TRIM(cApell_paterno)||' '||TRIM(cApell_materno),
				TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),dFecha_inf,UPPER(cDescEstatus),CURRENT,pUsuario);
				
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF; 
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				
			END FOREACH;
			COMMIT WORK;			

			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
			
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf::CHAR(10),estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctasinformadas "||
			"WHERE usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
							
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		-- CUENTAS CONCENTRADAS
		ELIF pReporte = '2' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctasconcentradas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctasconcentradas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'CONCENTRADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '6';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
								
	       --OBTIENE EL PRODUCTO  5000 PARA LA CONCENTRACION  - RSV 
	       SELECT producto,   nombre
	         INTO v_producto, v_nombre
	         FROM bdicheq:sc_producto
	        WHERE producto = '5000'; 
									
			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH

			SELECT  b.cuenta,b.producto as nom_producto,b.num_cte,b.cliente,b.fech_ult_dep,
                    b.fech_ult_ret,b.fecha_concentra,b.sdo_concentrado,a.sucursal,
					a.producto,b.ints_prov_acum
            FROM    bdicheq:sc_maechq AS a,
                    bdicheq:sc_cuentas_concentradas as b
            WHERE   a.cuenta     = b.cuenta
            AND     a.status_cta = "6"
            and     a.sdo_actual = b.sdo_concentrado
            and     b.fecha_concentra BETWEEN dFechaMin AND dFechaMax
            and     b.fecha_pago_concentra IS NULL
            INTO    TEMP tmp_ctas_concentra WITH NO LOG;
			
			
			CREATE INDEX idx_tmp_ctas_concentra 
			ON tmp_ctas_concentra(cuenta);
			
		    SELECT  a.cuenta,a.nom_producto,a.num_cte,a.cliente,a.fech_ult_dep,a.fech_ult_ret,
				    a.fecha_concentra,a.sdo_concentrado,a.sucursal,a.producto,a.ints_prov_acum,c.fecha_marc	
			FROM    tmp_ctas_concentra AS a, 
					bdicheq:sc_ctasinformadas  AS c
			WHERE   a.cuenta = c.cuenta
			AND     c.fecha_marc = (SELECT MIN(d.fecha_marc) 
				                    FROM   bdicheq:sc_ctasinformadas d 
			  	                    WHERE  d.cuenta = a.cuenta)
			INTO TEMP tmp_ctas_concentra_fin WITH NO LOG;
						
			FOREACH WITH HOLD
					    
				SELECT cuenta,nom_producto,num_cte,cliente,fech_ult_dep,fech_ult_ret,fecha_concentra,sdo_concentrado,
				       sucursal,producto,ints_prov_acum,fecha_marc
				INTO   cNum_cuenta,cDescProducto_con,cNum_cliente,cNom_cliente,dFech_ult_dep,dFech_ult_ret,
				       dFecha_con,cImporte_con,cSucursal,cProducto,cInteres_gen,dFecha_inf
				FROM   tmp_ctas_concentra_fin
			
							
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				--SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				
				SELECT fecha_alta 
				INTO dFechaAlta
				FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
					
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;				
			
								
				INSERT INTO bdicnweb:"informix".sw_det_ctasconcentradas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,fecha_con,importe_con,interes_gen,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(v_producto)||' '||TRIM(v_nombre),cNum_cliente,cNom_cliente,TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),
				TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),dFecha_inf,TO_CHAR(dFecha_con, '%d/%m/%Y'),cImporte_con,NVL(cInteres_gen,0),UPPER(cDescEstatus),CURRENT,pUsuario);
				
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				LET cDescProducto_con = '';
				LET cNom_cliente = '';
				LET dFecha_con = '';
				LET cImporte_con = '';
				LET cInteres_gen = '';
				
			END FOREACH;
			COMMIT WORK;
			
			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
						
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','FECHA DE CONCENTRACION','IMPORTE CONCENTRADO','INTERES GENERADO','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT a.fecha_consulta,a.num_cuenta,a.producto,a.num_cliente,a.nom_cliente,a.sucursal,a.fecha_alta,a.fecha_ult_mov,a.fecha_inf::CHAR(10),a.fecha_con,a.importe_con,a.interes_gen,a.estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctasconcentradas as a, bdicheq:sc_maechq as b where a.num_cuenta = b.cuenta and a.fecha_inf = (select max(fecha_inf) from bdicnweb:sw_det_ctasconcentradas as c where c.num_cuenta = b.cuenta) "||
			"AND usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		-- CUENTAS DESCONCENTRADAS/ACTIVAS
		ELIF pReporte = '3' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctasdesconcentradas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctasdesconcentradas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'DESCONCENTRADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '1';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH
			FOREACH WITH HOLD
				
				SELECT con.cuenta,con.producto,con.num_cte,con.cliente,con.fech_ult_dep,con.fech_ult_ret,--con.fecha_concentra,
				(SELECT MAX(a.fecha_concentra) FROM bdicheq:"informix".sc_cuentas_concentradas a WHERE a.cuenta = con.cuenta AND a.fecha_pago_concentra BETWEEN dFechaMin AND dFechaMax),
				con.sdo_concentrado,con.int_sdo_concentra,con.fecha_pago_concentra,con.pago_sdo_concentra,mae.sucursal,mae.producto,inf.fecha_marc
				INTO cNum_cuenta,cDescProducto_con,cNum_cliente,cNom_cliente,dFech_ult_dep,dFech_ult_ret,dFecha_con,
				cImporte_con,cInteres_gen_des,dFecha_des,cPago_sdo_concentra,cSucursal,cProducto,dFecha_inf
				FROM bdicheq:"informix".sc_cuentas_concentradas AS con, 
				     bdicheq:"informix".sc_maechq AS mae,
					 bdicheq:"informix".sc_ctasinformadas as inf
			    WHERE con.cuenta = mae.cuenta
				AND   con.cuenta = inf.cuenta
                 --  AND con.num_cte = inf.num_cte
				AND   con.fecha_pago_concentra BETWEEN dFechaMin AND dFechaMax
				AND   inf.fecha_marc = (SELECT MIN(c.fecha_marc) 
				                        FROM   bdicheq:sc_ctasinformadas c 
			  	                        WHERE  c.cuenta = mae.cuenta)
			---	AND mae.status_cta = cEstatus
				---ORDER BY con.fecha_pago_concentra ASC
				
			--	FOREACH
			---		SELECT FIRST 1 fecha_marc 
			---		INTO dFecha_inf
			---		FROM bdicheq:"informix".sc_ctasinformadas 
			---		WHERE cuenta = cNum_cuenta ORDER BY fecha_marc DESC
			--	END FOREACH;
				
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				--SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				
				SELECT fecha_alta INTO dFechaAlta FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;	
								
				INSERT INTO bdicnweb:"informix".sw_det_ctasdesconcentradas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,fecha_con,importe_con,interes_gen,fecha_des,importe_des,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(cProducto)||' '||TRIM(cDescProducto_con),cNum_cliente,cNom_cliente,TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),
				dFecha_inf,TO_CHAR(dFecha_con, '%d/%m/%Y'),cImporte_con,cInteres_gen_des,TO_CHAR(dFecha_des, '%d/%m/%Y'),TRUNC(NVL(cInteres_gen_des,0) + NVL(cImporte_con,0),2),UPPER(cDescEstatus),CURRENT,pUsuario);
				 
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF; 
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				LET cDescProducto_con = '';
				LET cNom_cliente = '';
				LET dFecha_con = '';
				LET cImporte_con = '';
				LET cInteres_gen = '';
				LET dFecha_des = '';
				LET cInteres_gen_des = 0.00;
				LET cPago_sdo_concentra = 0.00;
				
			END FOREACH;
			COMMIT WORK;
			
			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
						
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','FECHA DE CONCENTRACION','IMPORTE CONCENTRADO','INTERES GENERADO','FECHA DESCONCENTRACION/ACTIVA','IMPORTE DESCONCENTRADO','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT a.fecha_consulta, a.num_cuenta,a.producto,a.num_cliente,a.nom_cliente,a.sucursal,a.fecha_alta,a.fecha_ult_mov,a.fecha_inf::CHAR(10),a.fecha_con,a.importe_con,a.interes_gen,a.fecha_des,a.importe_des,a.estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctasdesconcentradas as a, bdicheq:sc_maechq as b where a.num_cuenta = b.cuenta and a.fecha_inf = (select max(fecha_inf) from bdicnweb:sw_det_ctasdesconcentradas as c where c.num_cuenta = b.cuenta) "|| 
			"AND usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
		
		-- CUENTAS CANCELADAS
		ELIF pReporte = '4' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctascanceladas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctascanceladas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'CANCELADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '2';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
			
		  --OBTIENE EL PRODUCTO  5000 PARA LA CONCENTRACION 
	       SELECT producto,   nombre
	         INTO v_producto, v_nombre
	         FROM bdicheq:sc_producto
	        WHERE producto = '5000'; 
									
					
			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH
			FOREACH WITH HOLD
				
				 SELECT con.cuenta,con.producto,con.num_cte,con.cliente,con.fech_ult_dep,con.fech_ult_ret,--con.fecha_concentra,
				(SELECT MAX(a.fecha_concentra) FROM bdicheq:"informix".sc_cuentas_concentradas a WHERE a.cuenta = con.cuenta AND a.fecha_trasp_benefic BETWEEN dFechaMin AND dFechaMax),
				con.sdo_concentrado,con.int_trasp_beneficiencia,con.fecha_trasp_benefic,con.sdo_trasp_beneficiencia,mae.sucursal,mae.producto,inf.fecha_marc
				INTO cNum_cuenta,cDescProducto_con,cNum_cliente,cNom_cliente,dFech_ult_dep,dFech_ult_ret,dFecha_con,
				cImporte_con,cInteres_gen_can,dFecha_tra,cSdo_trasp_beneficiencia,cSucursal,cProducto,dFecha_inf
				FROM bdicheq:"informix".sc_cuentas_concentradas AS con, 
				                   bdicheq:"informix".sc_maechq AS mae,
								   bdicheq:"informix".sc_ctasinformadas as inf
				WHERE con.cuenta  = mae.cuenta
				AND   con.cuenta  = inf.cuenta
                AND   con.num_cte = inf.num_cte			   
				AND   con.fecha_trasp_benefic BETWEEN dFechaMin AND dFechaMax
				AND   mae.motivo = '14'
				AND   mae.status_cta = cEstatus
				AND   inf.fecha_marc = (SELECT MIN(c.fecha_marc) 
				                        FROM   bdicheq:sc_ctasinformadas c 
			  	                        WHERE  c.cuenta = mae.cuenta)
				-- ORDER BY con.fecha_trasp_benefic ASC
				
				--FOREACH
				--	SELECT FIRST 1 fecha_marc 
				--	INTO dFecha_inf
				--	FROM bdicheq:"informix".sc_ctasinformadas 
				--	WHERE cuenta = cNum_cuenta ORDER BY fecha_marc DESC
				--END FOREACH;
				
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				--SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				
				SELECT fecha_alta INTO dFechaAlta FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;	
								
				INSERT INTO bdicnweb:"informix".sw_det_ctascanceladas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,fecha_con,importe_con,interes_gen,fecha_tras,importe_envben,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(v_producto)||' '||TRIM(v_nombre),cNum_cliente,cNom_cliente,TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),
				dFecha_inf,TO_CHAR(dFecha_con, '%d/%m/%Y'),cImporte_con,cInteres_gen_can,TO_CHAR(dFecha_tra, '%d/%m/%Y'),NVL(cInteres_gen_can,0) + NVL(cSdo_trasp_beneficiencia,0),UPPER(cDescEstatus),CURRENT,pUsuario);
				
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				LET cDescProducto_con = '';
				LET cNom_cliente = '';
				LET dFecha_con = '';
				LET cImporte_con = '';
				LET cInteres_gen = '';
				LET dFecha_des = '';
				LET cInteres_gen_des = 0.00;
				LET cPago_sdo_concentra = 0.00;
				LET dFecha_tra = '';
				LET cInteres_gen_can = 0.00;
				LET cSdo_trasp_beneficiencia = 0.00;
				
			END FOREACH;
			COMMIT WORK;
			
			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
						
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','FECHA DE CONCENTRACION','IMPORTE CONCENTRADO','INTERES GENERADO','FECHA TRASPASO','IMPORTE ENVIADO A LA BENEFICENCIA PUBLICA','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT a.fecha_consulta,a.num_cuenta,a.producto,a.num_cliente,a.nom_cliente,a.sucursal,a.fecha_alta,a.fecha_ult_mov,a.fecha_inf::CHAR(10),a.fecha_con,a.importe_con,a.interes_gen,a.fecha_tras,a.importe_envben,a.estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctascanceladas as a, bdicheq:sc_maechq as b where a.num_cuenta = b.cuenta and a.fecha_inf = (select max(fecha_inf) from bdicnweb:sw_det_ctascanceladas as c where c.num_cuenta = b.cuenta) "|| 
			"AND usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
		
		END IF;
		
		-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
		FOREACH
		
			SELECT nombre_reporte
			INTO cNombreReporteHist
			FROM bdicnweb:"informix".sw_ctrlgenreportesart61 
			WHERE usuario_insert = pUsuario --AND nombre_reporte = TRIM(cNombreReporte) 
			AND fecha_reporte < dFechaHoy
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
			SYSTEM TRIM(cSql);
			
			DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesart61 WHERE nombre_reporte = TRIM(cNombreReporteHist);
			
		END FOREACH;
		
		DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesart61 WHERE nombre_reporte = TRIM(cReporte);
		INSERT INTO bdicnweb:"informix".sw_ctrlgenreportesart61(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
		VALUES(TRIM(cReporte),dFechaHoy,dHoraHoy,pUsuario);		
		
		
		-- NOTIFICACION VIA CORREO ELECTRONICO
		LET cStr7 = 'GENERACION DEL ARCHIVO TXT';
		LET cStr8 = 'SOLICITUD DE CUENTAS INACTIVAS ART. 61';
		LET cStr9 = '000000000';
		LET cStr10 = 'MAIL_ART61';
		LET cStr11 = 'operaciones_art61@bancoppel.com';
		LET dHoy = CURRENT;
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
		'1', 
		'WEB_PLAGEN',
		TRIM(cStr10), 
		TRIM(cStr9),
		'',
		'', 
		'1', 
		'',
		'',
		'',
		'',
		'',
		TRIM(pTituloPlantilla),
		TRIM(cStr7),
		TRIM(cStr8),
		'',		
		'',
		TRIM(cStr11),
		'',
		'1',
		'0',
		'0',
		'0',
		'0',
		dHoy,
		''
		) INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCION DEL SP bdimnsj:"informix".sp_registra_evento, 
		END IF; 
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 23/05/2017',
'MODULO: DEBITO',
'FUNCIONALIDAD: REPORTE CUENTAS INACTIVAS (ART 61)',
'DESCRIPCION: SPL que genera reporte txt de las Cuentas Inactivas (Art 61)',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/06/2017',
'DESCRIPCION: Se actualiza para obtener campo saldo de la tabla bdicheq:sc_cuentas_concentradas.sdo_concentrado',
'en lugar de bdicheq:sc_maechq.imp_cgos_mes cuando las cuentas tienen estatus CANCELADO',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 11/07/2017',
'DESCRIPCION: Se modifica spl para la reasignacion de tablas utilizadas en la recuperacion del detalle de las fechas,',
'se reemplaza el NUMERO del estatus por su descripcion.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 21/01/2019',
'DESCRIPCION: Se modifica spl para establecer nuevas reglas de negocio solicitadas por el cliente.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 17/07/2019',
'DESCRIPCION: Se modifica spl para control de tiemeout en SOC.',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 05/08/2019',
'DESCRIPCION:  Se modifica spl para activar y desactivar trace cuando ocurre un error no controlado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_actualizatransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdActualiza CHAR(1),
pSucursal CHAR(4), pFecha DATE, pFolio CHAR(8), pOperacion CHAR(4), pMonto MONEY(16,2))
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipoOperacion CHAR(25);
	DEFINE cDescActualiza CHAR(20);
	DEFINE iRecuperacion INTEGER;
	DEFINE cStatus CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cTipoOperacion = '';
	LET cDescActualiza = '';
	LET iRecuperacion = 0;	
	LET cStatus = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_actualizatransacciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdActualiza = '' OR pSucursal = '' OR pFecha IS NULL OR pFolio = '' OR pOperacion = '' OR pMonto IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--REVERSO
		IF pIdActualiza = '1' THEN
			
			UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '08' 
			WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
			UPDATE bdisuc:"informix".ss_operaciones SET reversado = '1' 
			WHERE sucursal = pSucursal AND fecha_operacion = pFecha AND folio_oper = pFolio;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
			LET cDescActualiza = 'REVERSO';
			
		END IF;
		
		--CAMBIO ESTATUS
		IF pIdActualiza = '2' THEN
			
			SELECT status 
			INTO cStatus 
			FROM bdisuc:"informix".ss_mae_entradasalida WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
			IF cStatus = '08' THEN
				UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '01' 
				WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			
				UPDATE bdisuc:"informix".ss_operaciones SET reversado = '0' 
				WHERE sucursal = pSucursal AND fecha_operacion = pFecha AND folio_oper = pFolio;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
				
			ELSE
				UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '11' 
				WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			END IF;
			
			LET cDescActualiza = 'CAMBIO ESTATUS';
			
		END IF;
		
		IF pOperacion IN ('0001','0010','0036') THEN
			LET cTipoOperacion = 'DOTACION';
		ELIF pOperacion IN ('0002','0041') THEN
			LET cTipoOperacion = 'CONCENTRACION';
		ELIF pOperacion = '0026' THEN
			LET cTipoOperacion = 'RECOLECCION';
		END IF;
		
		--SE REGISTRA EN BITÁCORA
		INSERT INTO bdisuc:"informix".ss_bitacora_reversoscg (fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio)
		VALUES(CURRENT,pSucursal,pFolio,cTipoOperacion,pMonto,pUsuario,cDescActualiza);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00282';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de actualizar los campos correspondientes al reverso y cambio de estatus de las Operaciones de Caja General.',
'BD: bdicnweb','AUTOR: Veronica Sanchez',
'FECHA: 04/05/2023',
'DESCRIPCION: se modifica SPL para realizar la actualizacion del campo estatus a 01 en tabla ss_mae_entradasalida y campo reversado a 0 de la tabla ss_operaciones ',
' solo para las transacciones 0002, 0026, 0041 y se agrega transaccion 0041 para indicar el tipo de operacion - Concentracion',
'AUTOR: Veronica Sanchez',
'FECHA: 09/05/2023',
'DESCRIPCION: Se modifica SPL para realizar la actualizacion del campo estatus a 01 en tabla ss_mae_entradasalida y campo reversado a 0 de la tabla ss_operaciones ',
' solo para las transacciones 0001 y 0010';

CREATE PROCEDURE "informix".sp_cg_detalletransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1),
pSucursal CHAR(4), pFecha DATE, pFolio CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha_solicitud,
			CHAR(8) AS folio_oper,
			MONEY(16,2) AS monto,
			CHAR(4) AS sucursal,
			CHAR(4) AS cod_proveedor,
			CHAR(16) AS folio_servicio,
			CHAR(2) AS status,
			CHAR(4) AS operacion,
			CHAR(35) AS desc_operacion;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha_solicitud DATE;
	DEFINE cFolio_oper CHAR(8);
	DEFINE mMonto MONEY(16,2);
	DEFINE cSucursal CHAR(4);
	DEFINE cCod_proveedor CHAR(4);
	DEFINE cFolio_servicio CHAR(16);
	DEFINE cStatus CHAR(2);
	DEFINE cOperacion CHAR(4);
	DEFINE cDescOperacion CHAR(35);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha_solicitud = '';
	LET cFolio_oper = '';
	LET mMonto = 0.00;
	LET cSucursal = '';
	LET cCod_proveedor = '';
	LET cFolio_servicio = '';
	LET cStatus = '';
	LET cOperacion = '';
	LET cDescOperacion = '';
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detalletransacciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pSucursal = '' OR pFecha IS NULL OR pFolio = '' OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion 
			a.fecha_solicitud,a.folio_oper,a.monto,a.sucursal,a.cod_proveedor,a.folio_servicio,a.status,b.cod_trans,c.descripcion
			INTO dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion
			FROM bdisuc:"informix".ss_mae_entradasalida AS a, bdisuc:"informix".ss_operaciones AS b, bdisuc:"informix".ss_param_cajagen AS c
			WHERE a.folio_oper = b.folio_oper AND b.cod_trans = c.codigo 
			AND a.sucursal = pSucursal 
			AND a.fecha_solicitud = pFecha
			AND a.folio_oper = pFolio
			AND b.cod_trans IN ('0001','0002','0010','0026','0036','0041')
			ORDER BY a.folio_oper ASC
			
			--REVERSO
			IF pIdConsulta = '1' OR pIdConsulta = '2' THEN
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion WITH RESUME;
			END IF;
			
			--CAMBIO ESTATUS
			IF pIdConsulta = '2' THEN
				IF cOperacion IN ('0001','0010','0036') THEN
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion WITH RESUME;
				END IF;
			END IF;
			
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el detalle de las Operaciones de Caja General.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 04/05/2023',
'DESCRIPCION: Se modifica SPL para quitar validación de tipo operación en la opcion cambio de estatus para recuperar todosa los datos',
'AUTOR: Veronica Sanchez',
'FECHA: 09/05/2023',
'DESCRIPCION: Se modifica SPL para regresar validaciones de recuperación de información para la opción de Cambio de Estatus';

CREATE PROCEDURE "informix".sp_cg_detalletransacciones_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1),
pSucursal CHAR(4), pFecha DATE, pFolio CHAR(8))
		RETURNING CHAR(5) AS codret,
			INTEGER AS no_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cFolio_oper CHAR(8);
	DEFINE cOperacion CHAR(4);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cFolio_oper = '';
	LET cOperacion = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detalletransacciones_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pSucursal = '' OR pFecha IS NULL OR pFolio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT a.folio_oper,b.cod_trans
			INTO cFolio_oper,cOperacion
			FROM bdisuc:"informix".ss_mae_entradasalida AS a, bdisuc:"informix".ss_operaciones AS b, bdisuc:"informix".ss_param_cajagen AS c
			WHERE a.folio_oper = b.folio_oper AND b.cod_trans = c.codigo 
			AND a.sucursal = pSucursal 
			AND a.fecha_solicitud = pFecha
			AND a.folio_oper = pFolio
			AND b.cod_trans IN ('0001','0002','0010','0026','0036','0041')
			ORDER BY a.folio_oper ASC
			
			--REVERSO 
			IF pIdConsulta = '1' OR pIdConsulta = '2' THEN
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
			
			--CAMBIO ESTATUS
			IF pIdConsulta = '2' THEN
				IF cOperacion IN ('0001','0010','0036') THEN
					LET iNoRegistros = iNoRegistros + 1;
				END IF;
			END IF;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el número total de las Operaciones de Caja General.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 04/05/2023',
'DESCRIPCION: Se modifica SPL para quitar validación de tipo operación en la opcion cambio de estatus para recuperar todosa los datos',
'AUTOR: Veronica Sanchez',
'FECHA: 09/05/2023',
'DESCRIPCION: Se modifica SPL para regresar validaciones de recuperación de información para la opción de Cambio de Estatus';

CREATE PROCEDURE "informix".sp_consultas_cac_central_total2(pEmpresa CHAR(3),pSucursal CHAR(4), pFechaInicial DATE, pFechaFinal DATE, pNumSol CHAR(20), pBanCac CHAR(1), pCac_Opt1_1 DECIMAL(5,2), pCac_Opt3_1 INTEGER, pArea CHAR(2), pStatus CHAR(2), pCausa CHAR(3), pProducto CHAR(4), pUsuario CHAR(10))
RETURNING
          CHAR(6),          -- Codigo de Retorno
          INTEGER           -- Total de Registros

DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);
DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;
DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);
DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);
DEFINE cFecha                  CHAR(10);
DEFINE cCausa				   CHAR(3);
DEFINE dECValor1			   DECIMAL(5,2);
DEFINE dECValor2			   DECIMAL(5,2);
DEFINE dMACValor1			   DECIMAL(5,2);
DEFINE dMACValor2			   DECIMAL(5,2);
DEFINE dPSValor1			   DECIMAL(5,2);
DEFINE dPSValor2			   DECIMAL(5,2);

DEFINE iMeseshist              INTEGER;
DEFINE cProducto               CHAR(4);
DEFINE iNumRegistros    	   INTEGER;


LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET cFecha                     = '';
LET cCausa					   = '';
LET dECValor1				   = 0.0;
LET dECValor2				   = 0.0;
LET dMACValor1				   = 0.0;
LET dMACValor2				   = 0.0;
LET dPSValor1				   = 0.0;
LET dPSValor2				   = 0.0;
LET iMeseshist                 = 0;
LET cProducto                  = "";
LET iNumRegistros         	   = 0;

-- ** HISTORIAL DE CAMBIOS ** --
--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.
-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la seleccion principal los 3 tipos de consulta
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed Carreon
--07/06/ 2010
--Comentarios: se agrego la causa del status y los filtros para los criterios del cac y mc.
--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validacion de eficiencia, meses de historia y puntuacion scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

--AUTOR: L. Montserrat LeÃ³n Amador
--FECHA: 19/09/2019
--DESCRIPCION: Se modifica SPL para implementar la eliminaciÃ³n de registros de la tabla paso1 (que ahora es fÃ­sica) a partir del indice id_registro.

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, iNumRegistros;
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!

--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_CAC_central.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizÃ³ la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor
           INTO cFecha
           FROM bdicred:"informix".sd_param
          WHERE cod_param='030';
     LET pFechaInicial=DATE(cFecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;

--IF pArea <> '' THEN
--- >>> POR CAC O MC <<< ---
---  OBTIENE LOS CRITERIOS DE EFICIENCIA COPPEL

  --  SELECT valor1,valor2
    --  INTO dECValor1,dECValor2
      --FROM bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "01";

---  OBTIENE LOS CRITERIOS DE MESES DE HISTORIA COPPEL
    --SELECT valor1,valor2
    --  INTO dMACValor1,dMACValor2
      --FROM  bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "02";

---  OBTIENE LOS CRITERIOS DE PUNTUACION DE SCORING
  --  SELECT valor1,valor2
      --INTO dPSValor1,dPSValor2
      --FROM  bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "03";
--END IF;
	
	-- SE LIMPIA TABLA POR USUARIO Y PROCESO
	SET LOCK MODE TO WAIT 3;
	DELETE FROM bdicnweb:"informix".paso1
	WHERE usuario = TRIM(pUsuario);

IF NVL(pNumSol,"")  <> "" THEN 
	FOREACH
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- NÃºmero de Solicitud
				sol.numcte,                -- NÃºmero Cte
				sol.sucursal,              -- Sucursal
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.monto_solicitado,      -- Monto Solicitado
				sol.fecha_insert,          -- Fecha Insert
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima AutorizaciÃ³n
					 THEN NVL(aut.fecha_entrada,date(1))
					 ELSE NVL(esp.fecha_modif,date(1))
				END),
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de AutorizaciÃ³n
					 THEN NVL(aut.comentario,"")
					 ELSE NVL(esp.comentario,"")
				END),
				NVL(aut.revision_cac,0),
			aut.causa_solicitud,
			sol.num_producto
		   INTO cNumSolicitud,
				cNumCte,
				cSucursal,
				cStatusSol,
				cTipoSolicitud,
				dMontoSolicitado,
				dtFechaInsert,
				dtFechaModificacion,
				cComentarioAut,
				iRevisionCac,
				cCausa,
				cProducto
		  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON aut.num_solicitud= sol.num_solicitud
															  AND aut.empresa= sol.empresa
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.rowid=(SELECT MAX(aut_aux.rowid)
																					   FROM bdisolic:"informix".ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa
																					   AND aut_aux.num_solicitud= sol.num_solicitud
																					   AND aut_aux.status_solicitud= sol.status_solicitud)
															  AND aut.ejecutivo_auto= aut.ejecutivo_auto
															  AND aut.revision_cac = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
															  AND aut.status_solicitud = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
															  AND aut.causa_solicitud = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
																	   AND esp.num_solicitud= sol.num_solicitud
																	   AND esp.numcte=sol.numcte
																	   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
																							 FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
																							WHERE esp_aux.empresa= sol.empresa
																							  AND esp_aux.num_solicitud= sol.num_solicitud
																							  AND esp_aux.numcte= sol.numcte)
																	   AND sol.status_solicitud= esp.status_nvo)
		  ---Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
		--LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
		 WHERE sol.num_solicitud=  pNumSol
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opciÃ³n de la consulta es CAC, si es asi tendrian que ser solo status "RT"
		   AND sol.status_solicitud NOT IN ("PC","AN")
--		   AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
		   AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
		   AND (sol.fecha_insert >= (CASE WHEN pFechaInicial IS NULL THEN sol.fecha_insert ELSE pFechaInicial END)
				AND  sol.fecha_insert <= (CASE WHEN pFechaFinal IS NULL THEN sol.fecha_insert ELSE pFechaFinal END))
			--AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)
--			AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
			AND sol.num_producto = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
--			AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)			
--			AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

		-- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
		-- En caso contrario no se mostraria en la consulta.

		   IF cStatusSol IN ('CC','BC') THEN
				SELECT COUNT(*)
				  INTO iInfoBuro
				  FROM bdiburo:"informix".br_traslado AS tras
				  INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
				  WHERE tras.num_solicitud = cNumSolicitud;
				  
				IF NVL(iInfoBuro,0) = 0 THEN
					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras 
					INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS res ON (tras.num_solicitud = res.num_solicitud) 
					WHERE tras.num_solicitud = cNumSolicitud;
				  
					IF NVL(iInfoBuro,0) = 0 THEN
						SELECT COUNT(*)
						INTO iInfoBuro
						FROM bdiburo:"informix".br_traslado AS tras 
						INNER JOIN bdiburo:"informix".sb_regreso_2013 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud) 
						WHERE tras.num_solicitud = cNumSolicitud;

						IF NVL(iInfoBuro,0) = 0 THEN
						   CONTINUE FOREACH;
						END IF;

					END IF;
				END IF;

				 IF NVL(iInfoBuro,0) = 0 THEN

					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras
					INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
					WHERE tras.num_solicitud = cNumSolicitud;

					IF NVL(iInfoBuro,0) = 0 THEN
					   CONTINUE FOREACH;
					END IF;

				 END IF;

		   END IF;

		-- Se obtienen los datos de la informaciÃ³n crediticia en COPPEL/BANCOPPEL.

				   SELECT ef.situacion_pago,         -- Situacion Pago
						   ef.meses_historia          -- Meses Historia
					  INTO dSituacionPago,
						   iMesesHistoria
					  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
					 WHERE ef.empresa= pEmpresa
					   AND ef.num_solicitud= cNumSolicitud;
					   
					   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÃDITO

					--  IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
						--CONTINUE FOREACH;
					  --END IF;

					--IF NVL(pArea, "") <> "" THEN
						  --IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
								   --(iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

								--CONTINUE FOREACH;
					  --END IF;

					--END IF;
		-- Se obtiene las puntuaciones del scoring que se le realizÃ³ al cliente.
		SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
			   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
			   NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
			   COUNT(num_solicitud) AS cantidad
		  INTO dSeccion1,    
			   dSeccion2,
			   dSumaSecciones,
			   iCantidad
		  FROM bdisolic:"informix".ss_resumen_scoring
		 WHERE empresa= pEmpresa
		   AND num_solicitud = cNumSolicitud
		   AND seccion IN ('1','2');

		IF iCantidad <> 2 THEN

			   LET dSeccion1= 0;
			   LET dSeccion2= 0;
			   LET dSumaSecciones= 0;

			SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
				   COUNT(*) AS cuantos
			  INTO dSeccion1, icuantos
			  FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
			 WHERE rsf.empresa = pEmpresa
			   AND rsf.num_solicitud = cNumSolicitud
			   AND rsf.empresa = sf.empresa
			   AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
			   AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
			   AND sf.min_mes_hist <= rsf.meses_historia
			   AND sf.max_mes_hist >= rsf.meses_historia
			   AND sf.min_porc_pago <= rsf.situacion_pago
			   AND sf.max_porc_pago >= rsf.situacion_pago;

		   FOREACH
				SELECT sg.empresa, sg.seccion,
					   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
				  INTO cEmpAux, iSecAux, dSeccionAux
				  FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
				 WHERE sg.empresa = dc.empresa
				   AND sg.grupo = dc.grupo
				   AND sg.seccion = dc.seccion
				   AND dc.num_solicitud = cNumSolicitud
				   AND dc.seccion = '2'
				   AND dc.empresa = pEmpresa
			  GROUP BY sg.empresa, sg.seccion, sg.agrupar

				LET dSeccion2= dSeccion2 + dSeccionAux;
				LET dSumaSecciones= dSeccion1 + dSeccion2;
	   END FOREACH;

	   END IF;

	   --IF NVL(pArea,"") <> "" THEN
			--IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
					--CONTINUE FOREACH;
			--END IF;
	   --END IF;

	 -- Se obtiene el nombre del cliente
		SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
												  TRIM(nvl(a.nombre2,'')) ||' '||
												  TRIM(nvl(a.apell_paterno,'')) ||' '||
												  TRIM(nvl(a.apell_materno,'')),
												  TRIM(a.razon_social)),
			   rfc
		  INTO cNombreCte, cRFC
		  FROM bdinteg:"informix".si_cliente a
		 WHERE a.numcte = cNumCte;

			--RQM 08 008 JMAH
	IF TRIM(cStatusSol) = "AT"  THEN
		
		IF EXISTS (SELECT num_credito FROM bdisolic:"informix".ss_solautorizadasgte WHERE num_credito =cNumSolicitud) THEN
			LET cComentarioAut = "Solicitud Autorizada GTE"||"-"||TRIM(cComentarioAut);
		END IF	
	END IF
		INSERT INTO bdicnweb:"informix".paso1(num_solicitud, num_cte, nombre_cte, rfc, sucursal, fecha_solic, fecha_cambio_stsuts, importe_linea, eficiencia, historial, puntos_seccion, puntos_2da_seccion, status_solicitud, observaciones_ant, suma_secciones, causas_status, usuario) 
			VALUES(NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
			   NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,''), pUsuario);

	END FOREACH;

ELSE
	FOREACH
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- NÃºmero de Solicitud
				sol.numcte,                -- NÃºmero Cte
				sol.sucursal,              -- Sucursal
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.monto_solicitado,      -- Monto Solicitado
				sol.fecha_insert,          -- Fecha Insert
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima AutorizaciÃ³n
					 THEN NVL(aut.fecha_entrada,date(1))
					 ELSE NVL(esp.fecha_modif,date(1))
				END),
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de AutorizaciÃ³n
					 THEN NVL(aut.comentario,"")
					 ELSE NVL(esp.comentario,"")
				END),
				NVL(aut.revision_cac,0),
			aut.causa_solicitud,
			sol.num_producto
		   INTO cNumSolicitud,
				cNumCte,
				cSucursal,
				cStatusSol,
				cTipoSolicitud,
				dMontoSolicitado,
				dtFechaInsert,
				dtFechaModificacion,
				cComentarioAut,
				iRevisionCac,
				cCausa,
				cProducto
		  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud
															  AND aut.empresa= sol.empresa
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.rowid=(SELECT MAX(aut_aux.rowid)
																					   FROM bdisolic:"informix".ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa
																					   AND aut_aux.num_solicitud= sol.num_solicitud
																					   AND aut_aux.status_solicitud= sol.status_solicitud)
															  AND aut.ejecutivo_auto= aut.ejecutivo_auto)
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
																	   AND esp.num_solicitud= sol.num_solicitud
																	   AND esp.numcte=sol.numcte
																	   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
																							 FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
																							WHERE esp_aux.empresa= sol.empresa
																							  AND esp_aux.num_solicitud= sol.num_solicitud
																							  AND esp_aux.numcte= sol.numcte)
																	   AND sol.status_solicitud= esp.status_nvo)
		  --Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
		--LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
		 WHERE sol.num_solicitud=  sol.num_solicitud 
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opciÃ³n de la consulta es CAC, si es asi tendrian que ser solo status "RT"
		   AND sol.status_solicitud NOT IN ("PC","AN")
		   AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
		   AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
		   AND (sol.fecha_insert >= pFechaInicial AND  sol.fecha_insert <= pFechaFinal )
			--AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)

			AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
			AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
			AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

		-- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
		-- En caso contrario no se mostraria en la consulta.

		   IF cStatusSol IN ('CC','BC') THEN
				SELECT COUNT(*)
				  INTO iInfoBuro
				  FROM bdiburo:"informix".br_traslado AS tras
				  INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
				  WHERE tras.num_solicitud = cNumSolicitud;

				IF NVL(iInfoBuro,0) = 0 THEN
					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras 
					INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS res ON (tras.num_solicitud = res.num_solicitud) 
					WHERE tras.num_solicitud = cNumSolicitud;
					
					IF NVL(iInfoBuro,0) = 0 THEN

						SELECT COUNT(*)
						INTO iInfoBuro
						FROM bdiburo:"informix".br_traslado AS tras 
						INNER JOIN bdiburo:"informix".sb_regreso_2013 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud) 
						WHERE tras.num_solicitud = cNumSolicitud;

						IF NVL(iInfoBuro,0) = 0 THEN
						   CONTINUE FOREACH;
						END IF;

					END IF;
				END IF;
				
				 IF NVL(iInfoBuro,0) = 0 THEN

					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras
					INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
					WHERE tras.num_solicitud = cNumSolicitud;

					IF NVL(iInfoBuro,0) = 0 THEN
					   CONTINUE FOREACH;
					END IF;

				 END IF;

		   END IF;

		-- Se obtienen los datos de la informaciÃ³n crediticia en COPPEL/BANCOPPEL.

				   SELECT ef.situacion_pago,         -- Situacion Pago
						   ef.meses_historia          -- Meses Historia
					  INTO dSituacionPago,
						   iMesesHistoria
					  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
					 WHERE ef.empresa= pEmpresa
					   AND ef.num_solicitud= cNumSolicitud;
					   
					   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÃDITO

					 -- IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
						--CONTINUE FOREACH;
					  --END IF;

					--IF NVL(pArea, "") <> "" THEN

						--  IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
							--	   (iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

								--CONTINUE FOREACH;
					  --END IF;

					--END IF;
		-- Se obtiene las puntuaciones del scoring que se le realizÃ³ al cliente.
		SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
			   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
			   NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
			   COUNT(num_solicitud) AS cantidad
		  INTO dSeccion1,    
			   dSeccion2,
			   dSumaSecciones,
			   iCantidad
		  FROM bdisolic:"informix".ss_resumen_scoring
		 WHERE empresa= pEmpresa
		   AND num_solicitud = cNumSolicitud
		   AND seccion IN ('1','2');

		IF iCantidad <> 2 THEN

			   LET dSeccion1= 0;
			   LET dSeccion2= 0;
			   LET dSumaSecciones= 0;

			SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
				   COUNT(*) AS cuantos
			  INTO dSeccion1, icuantos
			  FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
			 WHERE rsf.empresa = pEmpresa
			   AND rsf.num_solicitud = cNumSolicitud
			   AND rsf.empresa = sf.empresa
			   AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
			   AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
			   AND sf.min_mes_hist <= rsf.meses_historia
			   AND sf.max_mes_hist >= rsf.meses_historia
			   AND sf.min_porc_pago <= rsf.situacion_pago
			   AND sf.max_porc_pago >= rsf.situacion_pago;

		   FOREACH
				SELECT sg.empresa, sg.seccion,
					   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
				  INTO cEmpAux, iSecAux, dSeccionAux
				  FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
				 WHERE sg.empresa = dc.empresa
				   AND sg.grupo = dc.grupo
				   AND sg.seccion = dc.seccion
				   AND dc.num_solicitud = cNumSolicitud
				   AND dc.seccion = '2'
				   AND dc.empresa = pEmpresa
			  GROUP BY sg.empresa, sg.seccion, sg.agrupar

				LET dSeccion2= dSeccion2 + dSeccionAux;
				LET dSumaSecciones= dSeccion1 + dSeccion2;
	   END FOREACH;

	   END IF;

	   --IF NVL(pArea,"") <> "" THEN
		--	IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
					--CONTINUE FOREACH;
			--END IF;
	   ---END IF;

	 -- Se obtiene el nombre del cliente
		SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
												  TRIM(nvl(a.nombre2,'')) ||' '||
												  TRIM(nvl(a.apell_paterno,'')) ||' '||
												  TRIM(nvl(a.apell_materno,'')),
												  TRIM(a.razon_social)),
			   rfc
		  INTO cNombreCte, cRFC
		  FROM bdinteg:"informix".si_cliente a
		 WHERE a.numcte = cNumCte;

			--RQM 08 008 JMAH
	IF TRIM(cStatusSol) = "AT"  THEN
		
		IF EXISTS (SELECT num_credito FROM bdisolic:"informix".ss_solautorizadasgte WHERE num_credito =cNumSolicitud) THEN
			LET cComentarioAut = "Solicitud Autorizada GTE"||"-"||TRIM(cComentarioAut);
		END IF	
	END IF
	
		INSERT INTO bdicnweb:"informix".paso1(num_solicitud, num_cte, nombre_cte, rfc, sucursal, fecha_solic, fecha_cambio_stsuts, importe_linea, eficiencia, historial, puntos_seccion, puntos_2da_seccion, status_solicitud, observaciones_ant, suma_secciones, causas_status, usuario) 
			VALUES(NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
			   NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,''), pUsuario);

	END FOREACH;
END IF

	SELECT COUNT (*) 
	INTO iNumRegistros
	FROM bdicnweb:"informix".paso1 
	WHERE usuario = pUsuario;

	RETURN NVL(cCodRet,''), NVL(iNumRegistros,0);

END
END PROCEDURE;