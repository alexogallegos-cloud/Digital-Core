CREATE PROCEDURE "informix".sp_guardaapoderadosctemoral(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20), pSecuencia INTEGER, pNumCteApode CHAR(20), pNomApodera CHAR(60), pFecha DATE)
	RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iSecReal INT;
	DEFINE cNumCteAp CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iSecReal = 0;
	LET cNumCteAp = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/CHVN/sp_guardaapoderadosctemoral.out';
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
		
		SELECT FIRST 1 numcteapoderado
		INTO cNumCteAp
		FROM bdinteg:si_apoderado
		WHERE numcte = pNumCte;
		
		IF cNumCteAp <> pNumCteApode OR cNumCteAp IS NULL THEN
			EXECUTE PROCEDURE bdinteg:"informix".ctemoralapoderados(cEmpresa, pNumCte, pSecuencia, pNumCteApode, pNomApodera, pUsuario, pFecha)
			INTO cCodRetSp;
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ctemoralapoderados';
			END IF;
		END IF;
		
		UPDATE bdinteg:si_ctepm SET nombre_contacto = pNumCteApode WHERE numcte = pNumCte;
		
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 28/05/2014',
'DESCRIPCION: realiza alta y actualiza un cliente moral apoderado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actinfosolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud CHAR(20), pNumCliente CHAR(20), pNumClienteReferencia CHAR(20))
                RETURNING CHAR(5) AS codret;
                
                DEFINE cCodRet CHAR(5);
                DEFINE cCodRetSp CHAR(5);
                DEFINE iSqlErr INTEGER;
                DEFINE cMensaje CHAR(80);
                DEFINE cEmpresa CHAR(3);
                
                LET cCodRet = '00000';
                LET cCodRetSp = '';
                LET iSqlErr = 0;
                LET cMensaje = '';
                LET cEmpresa = '001';
                
                BEGIN
                
                        ON EXCEPTION SET iSqlErr
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet;
                        END EXCEPTION;
                        
                        --SET DEBUG FILE TO '/tmp/mfinis/sp_actinfosolicitudmc.out';
                        --TRACE ON;
                        
                        IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' THEN
                                LET cCodRet = '00003';
                                RETURN cCodRet;
                        END IF;
                        
                        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                        IF cCodRet <> '00000' THEN
                                RETURN cCodRet;
                        END IF;
                        
                        SET LOCK MODE TO WAIT 3;
                        EXECUTE PROCEDURE bdisolic:"informix".sp_mc_actinfosol(cEmpresa, pNumSolicitud, pNumCliente, pNumClienteReferencia) INTO cCodRetSp, cMensaje;
                        
                        IF cCodRetSp::INTEGER = 1 THEN
                                LET cCodRet = '00003';
                        ELIF cCodRetSp::INTEGER < 0 THEN
                                RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdisolic:sp_mc_actinfosol';
                        END IF;
                        
                        RETURN cCodRet;
                
                END;
                
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 22/01/2014',
'DESCRIPCION: Actualiza la informaciÃÂ³n de una solicitud con el cliente coppel-bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogocoloniacp(pUsuario CHAR(8), pIdFuncion CHAR(10), pEstado CHAR(2), pNumCiudad CHAR(5), pNumColonia INTEGER, pNomZona CHAR(32), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5)  AS codret,
                                  INTEGER  AS iColonia,
                  CHAR(32) AS cNombre,
                  INTEGER  AS iCodigoPostal,
                  CHAR(1)  AS cUnidadHabitacional; 
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE iNoRegistros INTEGER;
        DEFINE iRegistros INTEGER;
        DEFINE iRecuperacion INTEGER;
        DEFINE cMensajeRet CHAR(80); 
        DEFINE iColonia INTEGER;
        DEFINE cNombre CHAR(32);
        DEFINE iCodigoPostal INTEGER;
        DEFINE cUnidadHabitacional CHAR(1);
        DEFINE cTmpTable CHAR(500);
        DEFINE iPid INTEGER;
		
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET iNoRegistros = 0;
        LET iRegistros = 0;
        LET iRecuperacion = 0;
        LET cMensajeRet = '';
        LET iColonia = 0;
        LET cNombre = '';
        LET iCodigoPostal = 0;
        LET cUnidadHabitacional = '';
        LET cTmpTable = '';
        LET iPid = DBINFO('sessionid');
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocoloniacp.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
                END IF;
                
                -- VALIDACION DE LA PAGINACION
                IF pRegistros < 0 OR pRecuperacion < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                --EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pNumSolicitud, '06', '1') INTO cCodRet;
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
                END IF;
                
                SET ISOLATION TO DIRTY READ;
                -- Consulta del numero 
                SELECT valor::INTEGER
                INTO iRegistros
				FROM bdicobranza:cb_param 
				WHERE empresa = '001' 
				AND cod_param = '32';
		
                IF pNumColonia > 0 THEN
                        EXECUTE PROCEDURE bdinteg:"informix".sp_consultacoloniascp(pEstado, pNumCiudad, pNumColonia, pNomZona, iRecuperacion)
                                INTO cCodRetSp, cMensajeRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
                        
                        LET iCodRetSp = cCodRetSp::INTEGER;
                                IF iCodRetSp < 0 THEN
                                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultacoloniascp';
                                ELIF iCodRetSp = 3 THEN
                                        LET cCodRet = '00017';
                                END IF; 
                        RETURN cCodRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
                END IF;
                -- CREACIÃ?N DE LA TABLA TEMPORAL
                LET cTmpTable = "CREATE TEMP TABLE tmpcatalog_"||iPid||" (colonia INTEGER, nombre CHAR(32), cod_postal INTEGER, unidad_hab CHAR(1)) WITH NO LOG;";
                EXECUTE IMMEDIATE cTmpTable;

                WHILE 1=1
                        FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultacoloniascp(pEstado, pNumCiudad, pNumColonia, pNomZona, iRecuperacion)
                                INTO cCodRetSp, cMensajeRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional
                                
                                LET iCodRetSp = cCodRetSp::INTEGER;
                                IF iCodRetSp < 0 THEN
                                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultacoloniascp';
                                ELIF iCodRetSp = 3 THEN
                                        EXIT WHILE;
                                END IF;
                                
                                LET cTmpTable = "INSERT INTO tmpcatalog_"||iPid||" VALUES('";
                                LET cTmpTable = TRIM(cTmpTable)||iColonia||"', '"||NVL(cNombre,'')||"', '"||iCodigoPostal||"', '"||NVL(cUnidadHabitacional,'')||"');";
                                EXECUTE IMMEDIATE cTmpTable;
                                LET iNoRegistros = iNoRegistros + DBINFO('sqlca.sqlerrd2');
                        END FOREACH;
                        
                        IF iNoRegistros = 0 THEN
                                EXIT WHILE;
                        END IF;
                        
                        LET iRecuperacion = iRecuperacion + iRegistros;
                END WHILE;
                
                IF iNoRegistros = 0 THEN
                        LET cTmpTable = "DROP TABLE tmpcatalog_"||iPid;
                        EXECUTE IMMEDIATE cTmpTable;
                        
                        LET cCodRet = '00017';
                        RETURN cCodRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
                END IF;
                
                -- SELECCION DE LOS DATOS DE LA TABLA TEMPORAL
                LET cTmpTable = "SELECT SKIP "||pRegistros||" FIRST "||pRecuperacion||" colonia, nombre, cod_postal, unidad_hab FROM tmpcatalog_"||iPid;
                PREPARE stmtId FROM TRIM(cTmpTable);
                DECLARE selectQryCur CURSOR FOR stmtId;
                OPEN selectQryCur;
                
                LET iNoRegistros = 0;
                FETCH selectQryCur INTO iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
                WHILE(SQLCODE == 0)
                        RETURN cCodRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional WITH RESUME;
                        LET iNoRegistros = iNoRegistros + 1;
                        FETCH selectQryCur INTO iColonia, cNombre, iCodigoPostal, cUnidadHabitacional;
                END WHILE;
                
                CLOSE selectQryCur;
                FREE selectQryCur;
                FREE stmtId;
                
                IF iNoRegistros = 0 AND pRegistros = 0 THEN
                        LET cCodRet = '00017';
                        RETURN cCodRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional WITH RESUME;
                ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
                        LET cCodRet = '1001';
                        RETURN cCodRet, iColonia, cNombre, iCodigoPostal, cUnidadHabitacional WITH RESUME;
                END IF;
                
                LET cTmpTable = "DROP TABLE tmpcatalog_"||iPid;
                EXECUTE IMMEDIATE cTmpTable;
                
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'DESCRIPCION: Consulta los codigos postales de una colonia',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tpoaire_transfer()
				returning 
				CHAR(5)     AS Cod_Retorno,
				CHAR(100)   AS Msj_Retorno;
				
DEFINE cCodRet		CHAR(5);
DEFINE cMsjRetorno	CHAR(100);
DEFINE iSql_err     INT; 
DEFINE iRegistros   INT; 
DEFINE dFecha		DATE;
DEFINE iConsecutivo	INT;
DEFINE mMonto		MONEY(6);
DEFINE cTelefono	CHAR(12);
DEFINE cTransaccion	CHAR(4);
DEFINE cFolioSuc	CHAR(16);
DEFINE cIntegridad	CHAR(1);
DEFINE cAplicacion	CHAR(1);
DEFINE cCuenta		CHAR(20);
DEFINE cReferencia2	CHAR(40);
DEFINE cStatus		CHAR(1);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComision			   MONEY(16,2);
DEFINE mIVAComisionConv		   MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mComisionCte			   MONEY(16,2);
DEFINE mIVAComisionCte		   MONEY(16,2);
DEFINE dFechaAyer	DATE;


LET cCodRet = "00000";
LET cMsjRetorno = "PROCESO EXITOSO";
LET iSql_err = 0 ; 
LET iRegistros = 0 ; 
LET mMonto = 0;
LET cTelefono = '';
LET cTransaccion = '';
LET cFolioSuc = '';
LET cIntegridad	= '1';
LET cAplicacion	= '1';
LET cCuenta = '';
LET cStatus = 'N';
LET mImpComisionConvenio = 0;
LET mIVAComision = 0;
LET mIVAComisionConv = 0;
LET mImpComisionCte = 0;
LET mComisionCte = 0;
LET mIVAComisionCte = 0;
LET iConsecutivo = 0;
LET cReferencia2 = '';
LET dFechaAyer = '';



BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
			   LET cMsjRetorno = "ERROR DE BASE DE DATOS";
               RETURN cCodRet, cMsjRetorno;
          END IF;
     END EXCEPTION;
	 
	 --SET DEBUG FILE TO "/informix/CHVN/sp_tpoaire_transfer.out";
	 --TRACE ON;
	 
	 SET ISOLATION TO DIRTY READ;
	 SELECT imp_com_trans_conv, iva_convenio, imp_com_trans_cte 
	 INTO mImpComisionConvenio, mIVAComision, mImpComisionCte
	 FROM bdisac:sac_convenios
	 WHERE numcategoria = '02'
	 AND numconvenio = '002';
	 
	 SET ISOLATION TO DIRTY READ;
	 SELECT imp_com_trans_conv, iva_convenio, imp_com_trans_cte 
	 INTO mImpComisionConvenio, mIVAComision, mImpComisionCte
	 FROM bdisac:sac_convenios
	 WHERE numcategoria = '02'
	 AND numconvenio = '002';
	 
	 SET ISOLATION TO DIRTY READ;
	 SELECT fecha_ant
	 INTO dFechaAyer
	 FROM bdinteg:si_fechas;
	 
	 
	 SET ISOLATION TO DIRTY READ;
	 SELECT count(*)
	 INTO iRegistros
	 FROM bdicheq:sc_movhis
	 WHERE fech_alt = dFechaAyer
	 AND transacc = '8006'
	 AND usuario = 'systrans'
	 AND producto = '8000';
	 	 
	 IF iRegistros > 0 THEN
		 SET ISOLATION TO DIRTY READ;
		 FOREACH
		 SELECT fech_alt, monto_tot, cuenta, folio_suc, transacc, referencia
		 INTO dFecha, mMonto, cCuenta, cFolioSuc, cTransaccion, cReferencia2
		 FROM bdicheq:sc_movhis
		 WHERE fech_alt = dFechaAyer
		 AND transacc = '8006'
		 AND usuario = 'systrans'
		 AND producto = '8000'
		 
		 SELECT telefono 
		 INTO cTelefono
		 FROM bditransfer:tf_maecte
		 WHERE cuenta_tf = cCuenta;
		 
		 LET mIVAComisionConv = mImpComisionConvenio * (mIVAComision/100);
		 LET mComisionCte = mMonto * (mImpComisionCte/100);
		 LET mIVAComisionCte = mComisionCte * (mIVAComision/100);
		 
		 SET ISOLATION TO DIRTY READ;
		 INSERT INTO bdisac:sac_movimientoshistorial (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado)
		 VALUES ('5001', '02', '002', cTelefono, cReferencia2, 2, mMonto, mImpComisionConvenio, mIVAComisionConv, mComisionCte, mIVAComisionCte, cCuenta, 'TRANSFER', cFolioSuc, cTransaccion, cIntegridad, cAplicacion, dFecha, CURRENT, cStatus);
		 
		 END FOREACH;

		 RETURN cCodRet,cMsjRetorno;
	 ELSE
		LET cCodRet = '00003';
		LET cMsjRetorno = 'NO SE ENCONTRARON REGISTROS A CARGAR';
		RETURN cCodRet,cMsjRetorno;
	 END IF;
END
END PROCEDURE;