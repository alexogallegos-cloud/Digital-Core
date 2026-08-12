create procedure "informix".sp_generaarchivosatsegundo(cTipoArchivo CHAR(2), pUsuario CHAR(8),cNomArchivo VARCHAR (20), cArchivoControl VARCHAR (20))
--*******************************************************************************************************
-- Realizo   :Alejandro Osuna
-- Proyecto :  Excencion de personas morales
-- Actividad :Se crean los diferentes archivos de envio al SAT
-- Fecha     :08 de  septiembre de 2008
--*******************************************************************************************************
--Datos de retorno
RETURNING  CHAR(6), CHAR(20), CHAR(1), CHAR(40),CHAR(200), CHAR(1);
--Definicion de variables
DEFINE vsqlerr                     INTEGER;
DEFINE cCodRet                     CHAR(6);
DEFINE pTipoError                  CHAR(1);
DEFINE pSpLlamado                  CHAR(40);
DEFINE pMostrado                   CHAR(1);
DEFINE tHora                       CHAR (25);
DEFINE cHora                       CHAR (2);
DEFINE cNumArchivo                 CHAR(1);
DEFINE cPrefijo                    CHAR(2);
DEFINE cClaveBan                   CHAR(5);
DEFINE cFechaArc                   CHAR(8);
DEFINE cFechaSer                   CHAR(10);
DEFINE cNombre                     CHAR(16);
DEFINE sRuta                       CHAR(90);
DEFINE sRutaFinal                  CHAR(90);
DEFINE vsSQL                       CHAR (1000) ;
DEFINE vsSQL1                      CHAR (300);
DEFINE vsSQL2                      CHAR (400) ;
DEFINE vsSQL3                      CHAR (150);
DEFINE vsSQLC                      CHAR (1000) ;
DEFINE vsSQL1C                     CHAR (300);
DEFINE vsSQL2C                     CHAR (400) ;
DEFINE vsSQL3C                     CHAR (150);
DEFINE cFechaRes                   DATE;
DEFINE cStatus                     CHAR(1);
DEFINE iNoRegistro                 INT;
DEFINE cCodEnvio                   CHAR(1);
DEFINE cNumSele                    CHAR(1);
DEFINE pMensaje                    CHAR(200);
DEFINE cPrefijoControl             CHAR(2);
DEFINE cNombreControl              CHAR(16);
DEFINE cRegistroControl            CHAR(1000);
DEFINE iRegistro                   INT;
DEFINE iRegistroResp               INT;
DEFINE iRegistroTotal              INT;
DEFINE iRegistrosRfcResp           INT;
DEFINE iEstado                     INT;
DEFINE  iretorno                   INTEGER;
DEFINE cRuta_Repositorio 		   CHAR(90);
DEFINE cRuta_Procesos              CHAR(90);
DEFINE cUsuarioRemoto 			   CHAR(20);
DEFINE cPassWord     			   CHAR(15);
DEFINE cIpRuta            		   CHAR(15);
DEFINE cEnviaArchivo  			   CHAR(300);
DEFINE sRutaArchivo                CHAR(30);
DEFINE sRutaCopia                  CHAR(30);
DEFINE cNombreError                CHAR(20);
DEFINE cControlError               CHAR(20);
DEFINE cErrorSP                    CHAR(6);
DEFINE cNombreAcuse                CHAR(20);
DEFINE cNombreControlAcuse         CHAR(20);
DEFINE cPrefijoDatos 			   CHAR(2);
DEFINE cDatoAcuse 				   CHAR(2);
DEFINE cStatusAcuse 			   CHAR(1);
DEFINE cEstado    				   CHAR(1);
DEFINE cRfc 					   CHAR(13);
DEFINE cNombreRechazo              CHAR(20);
DEFINE  cNombreControlstatus       CHAR(20);
DEFINE vIpDest 					   CHAR(30);
DEFINE vUsuarioDestino 			   CHAR(30);
DEFINE sBanderaError               CHAR(2);
DEFINE cClave 					   CHAR(5);
DEFINE cFecha 					   CHAR(8);
DEFINE cClaveRe 				   CHAR(5);
DEFINE cFechaRe 				   CHAR(8);
DEFINE cEliminarNombre 			   CHAR(20);
DEFINE  cEliminarControl 		   CHAR(20);
define iTotalRfcRespuesta          INT;
--- inicializacion de variables
LET cCodRet = "";
LET pTipoError = "";
LET  pSpLlamado  = "";
LET pMostrado = "";
LET cNombre = "";
LET tHora = "";
LET cHora = "";
LET cNumArchivo = "";
LET cPrefijo = "";
LET cClaveBan = '';
LET cFechaSer = "";
LET cFechaArc = "";
LET vsqlerr = "";
LET sRuta  = "";
LET sRutaFinal = "";
LET vsSQL = '' ;
LET vsSQL1 = '' ;
LET vsSQL2 = '' ;
LET vsSQL3 = '' ;
LET vsSQLC = '' ;
LET vsSQL1C = '' ;
LET vsSQL2C = '' ;
LET vsSQL3C = '' ;
LET cStatus = '';
LET iNoRegistro = '0';
LET cCodEnvio   = '';
LET cRegistroControl = '0';
LET cNombreAcuse  = '0';
LET iRegistroTotal = '0';
LET iEstado = '0';
LET  iretorno = '0';
LET cRuta_Repositorio = "";
LET cRuta_Procesos = "";
LET  cUsuarioRemoto = "";
LET cPassWord   = "";
LET cIpRuta = "";
LET cEnviaArchivo = "";
LET sRutaArchivo = "";
LET sRutaCopia    = "";
LET cNombreError = "";
LET cControlError  = "";
LET pMensaje = "";
LET cErrorSP = "";
LET cNombreControlAcuse = "";
LET cPrefijoDatos  = "";
LET cDatoAcuse = "";
LET cStatusAcuse = "";
LET cNombreError = "";
let cEstado = '';
LET cRfc = "";
LET cNombreRechazo = "";
LET cNombreControlstatus = "";
LET iRegistrosRfcResp = "";
LET vIpDest = '';
LET vUsuarioDestino = '';
LET sBanderaError = '';
LET cClave = '';
LET cFecha = '';
LET cClaveRe = '';
LET cFechaRe = '';
LET cEliminarNombre = '';
LET cEliminarControl = '';

	--SET DEBUG FILE TO "/home/informix/sp_generaarchivosat_segunda.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION  SET vsqlerr
            IF vsqlerr <> 0  THEN
                    LET pTipoError = 'P';
                    LET pSpLLamado = 'sp_generaarchivosat';
                    LET pMostrado = 'N';
                    LET  cCodRet  = vsqlerr;
                    IF (cNombreError = '') or (cNombreError is null) THEN
                      LET  cNombreError = 'GENERICO';
                    END IF;
                     IF (pMensaje = '') or (pMensaje is null) THEN
                       LET  pMensaje = 'Error de Informix';
                    END IF;

                    IF cTipoArchivo = '03'THEN
						UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
						Commit work;
						 LET vsSQLC = '';
                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql';
                        SYSTEM vsSQLC;
                        LET vsSQLC = '';
                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
                        SYSTEM vsSQLC;
						execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
						RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                    END IF;
                     IF cTipoArchivo = '04' THEN
                            IF sBanderaError = 1 then
								UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cArchivoControl;
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
                                execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                                LET cTipoArchivo = '06';
                                execute procedure bdilide:sp_eliminaarchivo(cTipoArchivo,pUsuario,cNomArchivo,cArchivoControl) into cErrorSP;
                                Commit work;
                                RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                             END IF;
                             IF sBanderaError  = 3 THEN
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cArchivoControl;
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNombreControl;											
                                execute procedure bdilide:sp_eliminaarchivo(cTipoArchivo,pUsuario,cNomArchivo,cArchivoControl) into cErrorSP;
								Commit work;
								execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
								RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                             END IF;
                              IF sBanderaError  = 4 THEN
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cArchivoControl;
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNombreControl;
								execute procedure bdilide:sp_eliminaarchivo(cTipoArchivo,pUsuario,cNomArchivo,cArchivoControl) into cErrorSP;
								Commit work;
								execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
								RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                             END IF;
                    END IF;
					IF cTipoArchivo = '05' THEN
						execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
						UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
						execute procedure bdilide:sp_eliminaarchivo(cTipoArchivo,pUsuario,cNomArchivo,cArchivoControl) into cErrorSP;
						Commit work;
						RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
					END IF;
					LET pTipoError = 'P';
					LET pSpLLamado = 'sp_generaarchivosat';
					LET pMostrado = 'N';
                    Commit work;
					execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
					RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                   
            END IF;
        END  EXCEPTION;
        LET pTipoError = 'P';
        LET pSpLLamado = 'sp_generaarchivosat';
        LET pMostrado = 'N';
        --Validacion del tipo de archivo
		IF cTipoArchivo = "" or cTipoArchivo is NULL THEN
			LET cCodRet = '001';
			LET pMensaje = 'Validacion de tipo de archivo';
			execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
			Commit work;
			RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
		END IF;
        --Parametros necesarios
        SELECT TRIM(desc_valor) INTO vIpDest FROM bdilide:sl_parametros WHERE cve_param = '25' and valor = '01';
        SELECT  TRIM(desc_valor) INTO vUsuarioDestino FROM bdilide:sl_parametros WHERE cve_param = '25' and valor = '02';
        SELECT trim(desc_valor) INTO sRutaArchivo      FROM bdilide:sl_parametros WHERE cve_param = '25' and valor = '06';
        SELECT TRIM(desc_valor) INTO cClaveBan  FROM bdilide:sl_parametros WHERE cve_param = '25' AND valor = '07';

		--Toma de fecha a la tabla bdinteg, para el archivo
		SELECT  fecha_hoy
		INTO cFechaSer
		FROM bdinteg:si_fechas
		WHERE empresa = '001';

		LET cFechaArc = SUBSTR(cFechaSer,7,10) || SUBSTR(cFechaSer,1,2) || SUBSTR(cFechaSer,4,5);
		-- Se genera el archivo de consulta al SAT
        IF cTipoArchivo = '03' THEN
			Begin WORK;
				IF (cNomArchivo = "") OR (cNomArchivo IS NULL) THEN
					LET cNombreError = '1';
				ELSE
					LET cNombreError = '2';
				END IF;
				IF (cArchivoControl = "") OR (cArchivoControl IS NULL) THEN
					LET cControlError = '1';
				ELSE
					LET cControlError = '2';
				END IF;
				IF (cNombreError = '1') and (cControlError = '2') THEN
						LET cNombreControl   = cArchivoControl;
				END IF;
				IF (cNombreError = '2') and (cControlError = '1') THEN
					LET cNombreControl = cNomArchivo;
				END IF;	
				LET cNombreRechazo = cNombreControl;
				IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
					DELETE bdilide:sl_acuse;
				ELSE
					CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
				END IF;
				LET cNombreRechazo = SUBSTR(cNombreRechazo,1,1);
				IF cNombreRechazo = 'C' THEN
					LET cPrefijoControl = 'CN';
				END IF;
				IF cNombreRechazo = 'R' THEN
					LET cPrefijoControl = 'RN';
				END IF;
				IF cNombreRechazo = 'I' THEN
					LET cPrefijoControl = 'IN';
				END IF;
				LET iEstado = '1';
				LET cNombreControl = SUBSTR(cNombreControl,3,20);
				LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
				LET iNoRegistro = "0";
				LET  cClaveBan = cClaveBan;
				LET  cFechaArc  = "0";
				LET cStatus = '0';
				LET cNombreError = cNombreControl;
				INSERT INTO bdilide:sl_acuse(clave,fecha,registro, estado)
				VALUES (cClaveBan, cFechaArc, iNoRegistro,iEstado );
				IF EXISTS( SELECT status FROM bdilide:sl_procesos  WHERE proceso = cNombreControl  ) THEN
					LET cCodRet = '012';
                    LET pMensaje = 'El proceso ' ||  cNombreControl || 'ya existe en la tabla  sl_procesos';
                    COMMIT WORK;
                    execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;                   
                    RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
				ELSE
					INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
                    VALUES(cNombreControl,cFechaSer,cStatus,pUsuario, current hour to fraction(3));
                    
                    IF EXISTS(select status from bdilide:sl_archsat where nombre_arch = cNombreControl ) THEN
						UPDATE bdilide:sl_archsat SET status = 'E'  where nombre_arch = cNomArchivo;
                        LET cCodRet = '012';
                        LET pMensaje = 'El archivo ' ||  cNombreControl || 'ya existe en la tabla sl_arch_sat';
                        COMMIT WORK;
                        execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;                   
                        RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                    ELSE
                        LET sBanderaError  = '1';
                        LET pMensaje = 'Error en la creacion del archivo   '  ||  TRIM(cNombreControl);
                        LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
                        LET vsSQL2C = ' select clave,fecha,registro,estado from bdilide:sl_acuse;';
                        LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
                        LET vsSQL1C = TRIM(vsSQL1C);
                        LET vsSQL3C = TRIM(vsSQL3C);
                        LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
                        IF ( vsSQLC <> '' ) THEN
							SYSTEM vsSQLC;
                            let vsSQLC = '';
                            let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
                            SYSTEM vsSQLC;
                        END IF;
                        LET vsSQL = '';
					LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM(cNombreControl);
					SYSTEM vsSQL;
                        Insert into bdilide:sl_archsat(nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
                        values(cNombreControl,cFechaSer,cFechaSer,'0',iNoRegistro,'',pUsuario, current hour to fraction(3));
                        LET sBanderaError  = '2';
                        LET pMensaje = 'Error en el envio de AIX a Windows del archivo   '  ||  TRIM(cNombreControl);
                        LET vsSQLC = '';
						LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
						SYSTEM vsSQL;
                        UPDATE bdilide:sl_archsat SET status = 'E'  where nombre_arch = cNomArchivo;
                        execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;                   
                        LET vsSQLC = '';
                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql';
                        SYSTEM vsSQLC;
                        LET vsSQLC = '';
                        LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
                        SYSTEM vsSQLC;

					END IF;
				END IF;
		END IF;	
		IF cTipoArchivo = '04' THEN
            Begin WORK;
                --- se Validan los parametros
				IF (cNomArchivo = "" OR cNomArchivo IS NULL)   OR ( cArchivoControl = "" OR cArchivoControl IS NULL)THEN
					LET cCodRet = '006';
					LET pMensaje = 'Falta Nombre de Archivo';
                    LET cNombreError = cArchivoControl;
                    execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                    commit WORK;
                    RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
				END IF;
                LET cNombre = cNomArchivo;
                LET cNombreControl = cArchivoControl;
                LET cNombreError = cNombre;
                --- se crea el archivo enviado de consulta
                LET sBanderaError  = '1';
                LET pMensaje = 'Error en la carga del archivo  '  ||  TRIM(cNombre);
				IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_archivossatresp') THEN
					delete bdilide:sl_archivossatresp;
				ELSE
					CREATE TABLE bdilide:sl_archivossatresp(rfc CHAR(13), estado CHAR(1));
				END IF;
				--CREA ARCHIOVO DE INSTRUCCION DE CARGA.
				LET vsSQL = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; LOAD FROM '''|| TRIM(sRutaArchivo) || '/' || TRIM(cNombre) || "'" || ' INSERT INTO bdilide:sl_archivossatresp" > ' || TRIM(sRutaArchivo) ||  'load_informe_sat.sql';
				SYSTEM vsSQL;
				--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
				LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) ||  'load_informe_sat.sql';
				SYSTEM vsSQL;
                 LET sBanderaError  = '1';
				LET cNombreError = cNombreControl;
                LET pMensaje = 'Error en la carga del archivo  '  ||  TRIM(cNombreControl);
                IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_archivoscontrolsat') THEN
					delete bdilide:sl_archivoscontrolsat;
                ELSE
                    CREATE TABLE bdilide:sl_archivoscontrolsat(clave CHAR(5), fecha CHAR(8), registro int);
                END IF;
                --CREA ARCHIOVO DE INSTRUCCION DE CARGA.
                LET vsSQL = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; LOAD FROM '''|| TRIM(sRutaArchivo) || '/' || TRIM(cNombreControl) || "'" || ' INSERT INTO bdilide:sl_archivoscontrolsat" > ' || TRIM(sRutaArchivo) ||  'load_control_sat.sql';
                SYSTEM vsSQL;
                --CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
                LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) ||  'load_control_sat.sql';
                 SYSTEM vsSQL;

                SELECT registro,clave,fecha
				INTO iRegistroResp,cClave,cFecha
				FROM bdilide:sl_archivoscontrolsat;
                
                SELECT COUNT(rfc)
                INTO iTotalRfcRespuesta 
                FROM bdilide:sl_archivossatresp;
				UPDATE bdilide:sl_archsat SET no_registros = iTotalRfcRespuesta WHERE nombre_arch = cNomArchivo;
				UPDATE bdilide:sl_archsat SET no_registros = iTotalRfcRespuesta WHERE nombre_arch = cArchivoControl;
                IF(iTotalRfcRespuesta = iRegistroResp) AND (cClave = cClaveBan) THEN
                    SELECT registro
					INTO iRegistro
					FROM bdilide:sl_archivoscontrolsat;
					SELECT COUNT(a.rfc )
					INTO iRegistroTotal
					FROM bdilide:sl_archivossatresp  a
					INNER JOIN bdilide:sl_exentos b ON a.rfc = b.rfc;
					SELECT COUNT(rfc)
					INTO iRegistrosRfcResp
					FROM bdilide:sl_archivossatresp;
					IF (iRegistro = iRegistroTotal) AND (iRegistroTotal = iRegistrosRfcResp) THEN
							SELECT  clave, fecha
							INTO cClaveBan, cFechaArc
							FROM bdilide:sl_archivoscontrolsat;
							IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
								delete bdilide:sl_acuse;
							ELSE
								CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
							END IF;
							LET cNombreRechazo = cNombreControl;
							LET cNombreRechazo = SUBSTR(cNombreRechazo,1,1);
							IF cNombreRechazo = 'I' THEN
								LET cPrefijoControl = 'IA';
							END IF;
							LET iEstado = '0';
							LET cNombreControl = SUBSTR(cNomArchivo,3,20);
							LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
							LET iNoRegistro = iRegistro;
							LET cNombreError = cNombreControl;
							LET cStatus = '';
                            LET sBanderaError  = '3';
                            LET pMensaje = 'Error en la creacion del archivo  '  ||  TRIM(cNombreControl);
							INSERT INTO bdilide:sl_acuse(clave,fecha,registro, estado)
							VALUES (cClaveBan, cFechaArc, iRegistroResp,iEstado );
							IF EXISTS( SELECT status FROM bdilide:sl_procesos  WHERE proceso = cNombreControl ) THEN
							ELSE
								INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
								VALUES(cNombreControl,cFechaSer,'0',pUsuario, current hour to fraction(3));
							END IF;
							Insert into bdilide:sl_archsat(nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
							values(cNombreControl,cFechaSer,'','0',iRegistroResp,'',pUsuario, current hour to fraction(3));

							LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
							LET vsSQL2C = ' select clave,fecha,registro,estado from bdilide:sl_acuse;' ;
							LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
							LET vsSQL1C = TRIM(vsSQL1C);
							LET vsSQL3C = TRIM(vsSQL3C);
							LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
							IF ( vsSQLC <> '' ) THEN
								SYSTEM vsSQLC ;
								let vsSQLC = '' ;
								let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
								SYSTEM vsSQLC ;
							END IF;
							

                                                        COMMIT WORK;
											BEGIN WORK;
											execute procedure bdilide:sp_procesasat(pUsuario,cNomArchivo, cArchivoControl) into cErrorSP;
											IF cErrorSP <> '000' THEN
												ROLLBACK WORK;
												BEGIN WORK;
												LET cCodRet = cErrorSP;
												LET pSpLLamado = 'sp_procesasat';
												LET pMensaje = 'Error en la ejacucion del sp_procesasat';
												LET   cNombreError = cNombreControl;
                                                                                                COMMIT WORK;
												execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
												RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
											END IF;
								LET sBanderaError  = '4';
								LET pMensaje = 'Error en el anvio de AIX a windows del archivo  '  ||  TRIM(cNombreControl);
								LET vsSQL = '';
								LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM(cNombreControl);
								SYSTEM vsSQL;
								LET vsSQLC = '';
								LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
								SYSTEM vsSQL;
								LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cArchivoControl);
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_informe_sat.sql';
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_control_sat.sql';
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql';
					SYSTEM vsSQLC;
                                UPDATE sl_archsat SET status = '5'  WHERE nombre_arch = cArchivoControl;
                                UPDATE sl_archsat SET status = '5'  WHERE nombre_arch = cNomArchivo;
                                UPDATE sl_procesos SET status = '1'  WHERE proceso = cArchivoControl;
                                UPDATE sl_procesos SET status = '1'  WHERE proceso = cNomArchivo;
					ELSE
							SELECT  clave, fecha
							INTO cClaveBan, cFechaArc
							FROM bdilide:sl_archivoscontrolsat;
	
							IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
								delete bdilide:sl_acuse;
							ELSE
								CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
							END IF;

							LET cPrefijoControl = 'IN';
							LET iEstado = '1';
							LET cNombreControl = SUBSTR(cNomArchivo,3,20);
							LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
				
							LET iNoRegistro = iRegistro;
							LET cNombreError = cNombreControl;
							--LET cStatus = "";
                            LET sBanderaError  = '3';
                            LET pMensaje = 'Error en la creacion del archivo  '  ||  TRIM(cNombreControl);
							INSERT INTO bdilide:sl_acuse(clave,fecha,registro, estado)
							VALUES (cClaveBan, cFechaArc, iRegistroResp,iEstado );
							IF EXISTS( SELECT status FROM bdilide:sl_procesos  WHERE proceso = cNombreControl ) THEN
							ELSE
								INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
                               VALUES(cNombreControl,cFechaSer,'0',pUsuario, current hour to fraction(3));
							END IF;
							Insert into bdilide:sl_archsat(nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
							values(cNombreControl,cFechaSer,'','0',iRegistroResp,'',pUsuario, current hour to fraction(3));
							LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
							LET vsSQL2C = ' select clave,fecha,registro,estado from bdilide:sl_acuse;' ;
							LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
							LET vsSQL1C = TRIM(vsSQL1C);
							LET vsSQL3C = TRIM(vsSQL3C);
							LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
							IF ( vsSQLC <> '' ) THEN
								SYSTEM vsSQLC ;
								let vsSQLC = '' ;
								let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
								SYSTEM vsSQLC ;
							END IF;
                                                          UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cArchivoControl;
                                UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
                                                        LET cCodRet = '007';
                    LET pMensaje = 'Los datos del Archivo de  datos  ' || cNomArchivo || ' no concuerda con los datos de la tabla exentos';
                    LET cNombreError = cNomArchivo;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cArchivoControl);
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_informe_sat.sql';
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_control_sat.sql';
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql';
					SYSTEM vsSQLC;
					execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
					
					LET sBanderaError  = '4';
					LET pMensaje = 'Error en el anvio de AIX a windows del archivo  '  ||  TRIM(cNombreControl);
					LET vsSQL = '';
					LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM(cNombreControl);
					SYSTEM vsSQL;
					LET vsSQLC = '';
					LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
					SYSTEM vsSQL; 
					END IF;
                ELSE
                    SELECT  clave, fecha
					INTO cClaveBan, cFechaArc
					FROM bdilide:sl_archivoscontrolsat;

					IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
						delete bdilide:sl_acuse;
					ELSE
						CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
					END IF;

                    LET cPrefijoControl = 'IN';
					LET iEstado = '1';
					LET cNombreControl = SUBSTR(cNomArchivo,3,20);
					LET cNombreControl = cPrefijoControl || TRIM(cNombreControl);
					--LET iNoRegistro = iRegistro;
                    LET cNombreError = cNombreControl;

					INSERT INTO bdilide:sl_acuse(clave,fecha,registro, estado)
					VALUES (cClaveBan, cFechaArc, iRegistroResp,iEstado );
					IF EXISTS( SELECT status FROM bdilide:sl_procesos  WHERE proceso = cNombreControl ) THEN
                    ELSE
                        INSERT INTO bdilide:sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
                        VALUES(cNombreControl,cFechaSer,'0',pUsuario, current hour to fraction(3));
                    END IF;
					Insert into bdilide:sl_archsat(nombre_arch,fecha_genera,fecha_respuesta,status,no_registros,cod_envio,user_insert,fecha_insert)
					values(cNombreControl,cFechaSer,'','0',iRegistroResp,'',pUsuario, current hour to fraction(3));
                    LET sBanderaError  = '3';
                    LET pMensaje = 'Error en la creacion del archivo  '  ||  TRIM(cNombreControl);
					LET vsSQL1C = 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(sRutaArchivo) || TRIM(cNombreControl)  || ' DELIMITER ' || '''|''';
					LET vsSQL2C = ' select clave,fecha,registro,estado from bdilide:sl_acuse;' ;
					LET vsSQL3C = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
					LET vsSQL1C = TRIM(vsSQL1C);
					LET vsSQL3C = TRIM(vsSQL3C);
					LET vsSQLC = TRIM(vsSQL1C) || ' ' ||  TRIM(vsSQL2C) || TRIM(vsSQL3C);
                    IF ( vsSQLC <> '' ) THEN
						SYSTEM vsSQLC ;
						let vsSQLC = '' ;
						let vsSQLC = 'dbaccess bdilide ' || TRIM(sRutaArchivo) || 'tmp_SAT_acuse.sql';
						SYSTEM vsSQLC ;
					END IF;
                    UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cArchivoControl;
                    UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
                    LET cCodRet = '007';
                    LET pMensaje = 'Los datos del Archivo de control  ' || cArchivoControl || ' no son los correctos.';
                    LET cNombreError = cArchivoControl;
                  
                               
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cArchivoControl);
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNombreControl);
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_informe_sat.sql';
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_control_sat.sql';
					SYSTEM vsSQLC;
					LET vsSQLC = '';
					LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT_acuse.sql';
					SYSTEM vsSQLC;
					 execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
					LET sBanderaError  = '4';
					LET pMensaje = 'Error en el anvio de AIX a windows del archivo  '  ||  TRIM(cNombreControl);
					LET vsSQL = '';
					LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || TRIM(cNombreControl);
					SYSTEM vsSQL;
					LET vsSQLC = '';
					LET vsSQL  = 'scp' || ' ' || TRIM(sRutaArchivo) || TRIM( cNombreControl) || ' ' || TRIM(vIpDest) || TRIM(vUsuarioDestino) || TRIM(cNombreControl);
					SYSTEM vsSQL;

                END IF;
              
        END IF;
		IF  cTipoArchivo = '05' THEN
            BEGIN WORK;
                IF (pUsuario  = "" or pUsuario is NULL) OR (cNomArchivo = "" or cNomArchivo IS NULL)  THEN
                    LET cCodRet = '009';
                    LET pMensaje = "Dato en blanco o nulo";
                    execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;
                    commit WORK;
                    RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
                ELSE
                    LET cPrefijo = "CT";
                    LET cNombreControlAcuse = SUBSTR(cNomArchivo,3,20);
                    LET cNombreControlAcuse = TRIM(cNombreControlAcuse);
                    LET cNombreControlAcuse  = cPrefijo || cNombreControlAcuse;
                    LET cPrefijoDatos = "CC";
                    LET cNombreAcuse = SUBSTR(cNomArchivo,3,20);
                    LET cNombreAcuse = TRIM(cNombreAcuse);
                    LET cNombreAcuse  = cPrefijoDatos || cNombreAcuse;
					LET cNombreError = cNomArchivo;
					IF EXISTS(SELECT status FROM bdilide:sl_archsat WHERE nombre_arch = cNombreControlAcuse ) AND  EXISTS(SELECT status FROM bdilide:sl_archsat WHERE nombre_arch = cNombreAcuse) THEN
						LET sBanderaError  = '1';
						LET pMensaje = 'Los datos del Archivo de control  ' || cNomArchivo || ' no son los correctos.';
						IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_archivossatresp') THEN
							delete bdilide:sl_archivossatresp;
						ELSE
							CREATE TABLE bdilide:sl_archivossatresp(rfc CHAR(13), estado CHAR(1));
						END IF;
						--CREA ARCHIOVO DE INSTRUCCION DE CARGA.
						LET vsSQL = 'echo "SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; LOAD FROM '''|| TRIM(sRutaArchivo) ||  TRIM(cNombreAcuse) || "'" || ' INSERT INTO bdilide:sl_archivossatresp" > ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
						SYSTEM vsSQL;
						--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
						LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
						SYSTEM vsSQL;
						IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_archivoscontrolsat') THEN
							DELETE bdilide:sl_archivoscontrolsat;
						ELSE
							CREATE TABLE bdilide:sl_archivoscontrolsat(clave CHAR(5), fecha CHAR(8), registro int);
						END IF;
						--CREA ARCHIOVO DE INSTRUCCION DE CARGA.
						LET vsSQL= 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; LOAD FROM ''' || TRIM(sRutaArchivo) || '/' || TRIM(cNombreControlAcuse) || "'" || ' INSERT INTO sl_archivoscontrolsat" > ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
						--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
						IF ( vsSQL <> '' ) THEN
							SYSTEM vsSQL;
							let vsSQL = '' ;
							LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
							SYSTEM vsSQL;	
						End IF;
						LET vsSQLC = '';
						LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || 'load_archivo_sat.sql';
						SYSTEM vsSQL;
						IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_acuse') THEN
                            DELETE bdilide:sl_acuse;
                        ELSE
                            CREATE TABLE bdilide:sl_acuse(clave CHAR(5), fecha CHAR(8), registro int, estado int);
                        END IF;
						--CREA ARCHIOVO DE INSTRUCCION DE CARGA.
						LET vsSQL= 'echo " SET LOCK MODE TO WAIT; SET ISOLATION TO DIRTY READ; LOAD FROM ''' || TRIM(sRutaArchivo) || '/' || TRIM(cNomArchivo) || "'" || ' INSERT INTO sl_acuse" > ' || TRIM(sRutaArchivo) ||  'load_acuse_sat.sql';
						--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
						IF ( vsSQL <> '' ) THEN
							SYSTEM vsSQL;
							let vsSQL = '' ;
							LET vsSQL = 'dbaccess bdilide ' || TRIM(sRutaArchivo) ||  'load_acuse_sat.sql';
							SYSTEM vsSQL;	
						End IF;
						LET vsSQLC = '';
						LET vsSQL  = 'chmod 666 ' || ' ' || TRIM(sRutaArchivo) || 'load_acuse_sat.sql';
						SYSTEM vsSQL;
						SELECT registro,clave,fecha
						INTO iRegistroResp,cClave,cFecha
						FROM bdilide:sl_archivoscontrolsat;
						SELECT registro,clave,fecha
						INTO iRegistro,cClaveRe,cFechaRe
						FROM sl_acuse;
						
						IF(iRegistroResp = iRegistro) and (cClave = cClaveRe) and (cFecha = cFechaRe) THEN
							UPDATE sl_archsat SET status = '5'  WHERE nombre_arch = cNomArchivo;
							LET cDatoAcuse = SUBSTR(cNomArchivo,1,2);
							IF cDatoAcuse = "CA" THEN
								LET cStatusAcuse = '2';
								UPDATE bdilide:sl_archsat SET status = cStatusAcuse WHERE nombre_arch = cNombreAcuse;
								UPDATE bdilide:sl_archsat SET status = cStatusAcuse WHERE nombre_arch = cNombreControlAcuse;
								update bdilide:sl_procesos SET status  = '1' where proceso  = cNomArchivo;
							END IF;
							IF cDatoAcuse = "CN" THEN
								FOREACH
									SELECT rfc
									INTO cRfc
									FROM bdilide:sl_archivossatresp
									LET cEstado = 'E';
									UPDATE  bdilide:sl_consat  SET estado = cEstado WHERE rfc = cRfc;
								END  FOREACH;
								LET cStatusAcuse = '3';
								UPDATE bdilide:sl_archsat SET status = cStatusAcuse WHERE nombre_arch = cNombreAcuse;
								UPDATE bdilide:sl_archsat SET status = cStatusAcuse   WHERE nombre_arch = cNombreControlAcuse;
								update bdilide:sl_procesos SET status  = '1' where proceso  = cNomArchivo;
								
							END IF;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
							SYSTEM vsSQLC;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
							SYSTEM vsSQLC;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
							SYSTEM vsSQLC;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_acuse_sat.sql';
							SYSTEM vsSQLC;
						ELSE
							LET cCodRet = '008';
							LET pMensaje = 'Los datos del acuse ' || cNomArchivo || 'no concuerda con el contenido del archivo '||  trim(cNombreControlAcuse);
							LET cNombreError = cNomArchivo;
							execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;	
							UPDATE sl_archsat SET status = 'E'  WHERE nombre_arch = cNomArchivo;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
							SYSTEM vsSQLC;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
							SYSTEM vsSQLC;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
							SYSTEM vsSQLC;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_acuse_sat.sql';
							SYSTEM vsSQLC;
							
						END IF;
						
					ELSE
						
						LET cCodRet = '007';
						LET pMensaje = 'No existen los archivos correspondientes para el acuse ' || cNomArchivo;
						LET cNombreError = cNomArchivo;
						execute procedure bdilide:sp_grabarErrores(cNombreError, cCodRet, pTipoError, pSpLLamado, pMensaje, pMostrado)  into cErrorSP;	
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  trim(cNomArchivo);
							SYSTEM vsSQLC;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_sat_resp.sql';
							SYSTEM vsSQLC;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_archivo_sat.sql';
							SYSTEM vsSQLC;
							LET vsSQLC = '';
							LET vsSQLC = 'rm -f ' || TRIM(sRutaArchivo) ||  'load_acuse_sat.sql';
							SYSTEM vsSQLC;
					END IF;
				END IF;
            END IF;	
        LET cCodRet = '000';
        LET pMensaje = 'Proceso realizado satifactoriamente';
        COMMIT WORK;
        RETURN cCodRet, cNombreError,  pTipoError, pSpLLamado, pMensaje, pMostrado;
	END;
END PROCEDURE;