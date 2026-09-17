CREATE PROCEDURE "informix".sp_consultausuariocteprocesandomc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(8) AS usuario_procesando,
			CHAR(45) AS nombre_usuario;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumUsuario CHAR(8);
	DEFINE cNombreUsuario CHAR(45);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumUsuario = '';
	LET cNombreUsuario = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumUsuario, cNombreUsuario;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultausuariocteprocesandomc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumUsuario, cNombreUsuario;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumUsuario, cNombreUsuario;
		END IF;
		
		SELECT usuario 
		INTO cNumUsuario
		From bdisolic:ss_cte_procesando
		WHERE numcte = pNumCliente;
		
		IF NVL(TRIM(cNumUsuario), '') = '' THEN
			LET cCodRet = '00000';
			RETURN cCodRet, cNumUsuario, cNombreUsuario;
		END IF;
		
		IF cNumUsuario = pUsuario THEN
			LET cCodRet = '00000';
			RETURN cCodRet, cNumUsuario, cNombreUsuario;
		END IF;
		
		SELECT NVL(nombre, '')
		INTO cNombreUsuario
		FROM bdinteg:si_ejecut
		WHERE ejecutivo = TRIM(cNumUsuario);
		
		LET cCodRet = '90000';
		RETURN cCodRet, cNumUsuario, cNombreUsuario;
		
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 27/01/2014',
'DESCRIPCION: Consulta el usuario que esta atendiendo una solicitud',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtencambiostatusmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pNumSolicitud CHAR(20), pStatusInicial CHAR(2), pStatusFinal CHAR(2))
	RETURNING CHAR(5) AS codret,
			CHAR(2) AS status_cambiado,
			CHAR(40) AS desc_status_cambio,
			CHAR(1) AS valida_huella;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	
	-- VARIABLES DEL PROCEDIMIENTO
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cStatusCambio CHAR(2);
	DEFINE cDescripcionEstatusCambio CHAR(40);
	DEFINE cValidaHuella CHAR(1);
	DEFINE cEmpresa CHAR(3);
	
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	
	-- VARIABLES DEL PROCEDIMIENTO
	LET cMensajeRetorno = '';
	LET cStatusCambio = '';
	LET cDescripcionEstatusCambio = '';
	LET cValidaHuella = '';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatusCambio, cDescripcionEstatusCambio, cValidaHuella;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtencambiostatusmc.out';
		--TRACE ON;
	
		IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud = '' OR pStatusInicial = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatusCambio, cDescripcionEstatusCambio, cValidaHuella;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatusCambio, cDescripcionEstatusCambio, cValidaHuella;
		END IF;
		
		
		FOREACH EXECUTE PROCEDURE bdisolic:'informix'.sp_mc_obtencambiostatus(cEmpresa, pNumCliente, pNumSolicitud, pStatusInicial, pStatusFinal)
			INTO cCodRetSp, cMensajeRetorno, cStatusCambio, cDescripcionEstatusCambio, cValidaHuella
			
			IF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cStatusCambio, cDescripcionEstatusCambio, cValidaHuella;
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cStatusCambio, cDescripcionEstatusCambio, cValidaHuella;
			ELIF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN SP sp_mc_obtencambiostatus';
			END IF;
			
			RETURN cCodRet, cStatusCambio, cDescripcionEstatusCambio, cValidaHuella WITH RESUME;
			
		END FOREACH;
			
	END;
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 14/01/2014',
'DESCRIPCION: Procedimiento para la obtencion del historial de los status de la solicitud',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_obtienecbparamcobranza(pUsuario CHAR(8), pIdFuncion CHAR(10), pCodigoParametro INTEGER)
	RETURNING CHAR(5) AS codret,
			CHAR(100) AS valor_parametro;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRet INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cValorPrametro CHAR(100);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCodRet = 0;
	LET iSqlErr = 0;
	LET cValorPrametro = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValorPrametro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_obtienecbparamcobranza.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodigoParametro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValorPrametro;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValorPrametro;
		END IF;

		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdicobranza:'informix'.sp_obtienecbparam(pCodigoParametro) INTO cCodRetSp, cValorPrametro;
		LET iCodRet = cCodRetSp::INTEGER;
		
		IF iCodRet < 0 THEN
			RAISE EXCEPTION iCodRet, 0, 'ERROR EN LA EJECUCION DEL SP sp_obtienecbparam';
		ELIF iCodRet = 1 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cValorPrametro;
	
	END;
			
			
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 06/03/2014',
'DESCRIPCION: Consulta el valor de un parametro de la base de datos de bdicobranza',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_solicitudprocesandomc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pTipoMotivo SMALLINT)
	RETURNING CHAR(5) AS codret,
			CHAR(80) AS descripcion_msj;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE cMensaje CHAR(80);
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cMensaje = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensaje;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_solicitudprocesandomc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pTipoMotivo IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensaje;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensaje;
		END IF;
	
		IF pTipoMotivo NOT IN (1, 2) THEN
			LET cCodRet = '00108';
			RETURN cCodRet, cMensaje;
		END IF;
		
		EXECUTE PROCEDURE bdisolic:'informix'.sp_mc_sol_procesando(pNumCliente, pUsuario, pTipoMotivo) INTO cCodRetSp, cMensaje;
		
		IF cCodRetSp::INTEGER = 1 THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensaje;
		ELIF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER;
		ELIF cCodRetSp::INTEGER = 0 THEN
			RETURN cCodRet, cMensaje;
		END IF;
	
	END;
			
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 16/12/2013",
"DESCRIPCION: Marca una solicitud que va a ser atendida por el ejecutivo";

CREATE PROCEDURE "informix".sp_validapermisousuariocacmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pSupervisor CHAR(8))
        RETURNING CHAR(5) AS codret;

        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(5);
        DEFINE iSqlErr INTEGER;

        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iSqlErr = 0;
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_validapermisousuariocacmc.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pSupervisor = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                
                -- dbschema -q -f sp_validarpermisousuariocac -d bdicred
                
                EXECUTE PROCEDURE bdicred:'informix'.sp_validarpermisousuariocac(pSupervisor) INTO cCodRetSp;
                IF cCodRetSp::INTEGER = 1 THEN
                        LET cCodRet = '00003';
                ELIF cCodRetSp::INTEGER = 2 THEN
                        LET cCodRet = '00419'; -- EL USUARIO NO CUENTA CON EL PERFIL DE CRÃDITO
                ELIF cCodRetSp::INTEGER = 3 THEN
                        LET cCodRet = '00420'; -- EL USUARIO NO CUENTA CON EL PERIL PARA AUTORIZAR
                END IF;
				
                RETURN cCodRet;
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 27/01/2014',
'DESCRIPCION: Procedimiento para validar los permisos de usuarios',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultainfoctemc(pUsuario CHAR(8), pIdFuncion CHAR(10),pNumSol CHAR(20),pNumcte CHAR(20))
	RETURNING CHAR(5) AS codigoRetorno,
	CHAR(30) AS Estado,
	CHAR(30) AS Ciudad,
	CHAR(27) AS Municipio,
	CHAR(32) AS Colonia,
	CHAR(30) AS Calle,
	CHAR(10) AS NumExt,
	CHAR(10) AS NumInt,
	CHAR(5)  AS CodPostal,
	SMALLINT AS Edificio,
	CHAR(6)  AS Depto,
	CHAR(13) AS TelCasa,
	CHAR(13) AS TelCel,
	CHAR(13) AS TelTrab,
	CHAR(5)  AS Ext,
	CHAR(80) AS Complemento,
	CHAR(60) AS LugarTrabajo,
	CHAR(120) AS Actividad,
	CHAR(120) AS SubActividad,
	CHAR(104) AS NombreCong,
	CHAR(13)  AS TelCong,
	CHAR(104) AS NombreR1,
	CHAR(13)  AS TelR1,
	CHAR(20)  AS ParentestoR1,
	CHAR(104) AS NombreR2,
	CHAR(13)  AS TelR2,
	CHAR(20)  AS ParentestoR2;
	
	DEFINE cCodRet 			CHAR(5);
	DEFINE cCodRetSP		CHAR(6);
	DEFINE cMensajeRet      CHAR(80);
	DEFINE cComentario      CHAR(80);
	DEFINE iSqlErr          INTEGER;
	DEFINE iIsamErr         INTEGER;
	DEFINE cErrorInfo       CHAR(80);
	DEFINE cEstado			CHAR(30);
	DEFINE cCiudad			CHAR(30);
	DEFINE cMunicipio		CHAR(27);
	DEFINE cColonia			CHAR(32);
	DEFINE cCalle			CHAR(30);
	DEFINE cNumExt			CHAR(10);
	DEFINE cNumInt			CHAR(10);
	DEFINE cCodPostal       CHAR(5);
	DEFINE cDepto			CHAR(6);
	DEFINE sEdificio		SMALLINT;
	DEFINE sTipoTel			SMALLINT;
	DEFINE cComplemento		CHAR(80);
	DEFINE cTelCasa         CHAR(13);
	DEFINE cTelCel          CHAR(13);
	DEFINE cTel				CHAR(13);
	DEFINE cTelTrab         CHAR(13);
	DEFINE cExt				CHAR(5);
	DEFINE cLugarTrabajo 	CHAR(60);
	DEFINE iActividad    	INTEGER;
	DEFINE iSubActividad 	INTEGER;
	DEFINE cActividad    	CHAR(120);
	DEFINE cSubActividad 	CHAR(120);
	--referencias
	DEFINE cNombre			CHAR(104);
	DEFINE cParentesco		CHAR(2);
	DEFINE cDescParentesco 	CHAR(20);
	DEFINE cTelRef			CHAR(13);
	DEFINE cNumcteRef		CHAR(20);
	DEFINE cNombreCong		CHAR(104);
	DEFINE cParentestoCong  CHAR(20);
	DEFINE cTelCong			CHAR(13);
	DEFINE cNombreR1		CHAR(104);
	DEFINE cParentestoR1	CHAR(20);
	DEFINE cTelR1			CHAR(13);
	DEFINE cNombreR2		CHAR(104);
	DEFINE cParentestoR2	CHAR(20);
	DEFINE cTelR2			CHAR(13);
	
	
	LET cCodRet				= '00000';
	LET iSqlErr				= 0;
	LET cCodRetSP			= '';
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cMensajeRet         = "Se realizó la consulta correctamente";
	LET cEstado         	= "";
	LET cCiudad         	= "";
	LET cMunicipio          = "";
	LET cColonia            = "";
	LET cCalle         		= "";
	LET cNumExt         	= "";
	LET cNumInt         	= "";
	LET cCodPostal       	= "";
	LET sEdificio        	= "";
	LET cDepto       		= 0;
	LET cComplemento        = "";
	LET cTelCasa            = "";
	LET cTelCel         	= "";
	LET cTel         		= "";
	LET cTelTrab            = "";
	LET cExt         		= "";
	LET cLugarTrabajo  		= "";
	LET iActividad      	= 0;
	LET iSubActividad   	= 0;
	LET cActividad      	= "";
	LET cSubActividad   	= "";
	--referencias
	LET cNombre             = "";
	LET cParentesco     	= "";
	LET cDescParentesco 	= "";
	LET cTelRef             = "";
	LET cNumcteRef     		= "";
	LET cNombreCong         = "";
	LET cParentestoCong 	= "";
	LET cTelCong            = "";
	LET cNombreR1           = "";
	LET cParentestoR1   	= "";
	LET cTelR1              = "";
	LET cNombreR2           = "";
	LET cParentestoR2   	= "";
	LET cTelR2         		= "";
	
	BEGIN
		ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
            cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;
		END IF;
		END EXCEPTION;
		
		IF NVL(pUsuario ,'') = '' OR  NVL(pIdFuncion,'') = '' OR  NVL(pNumSol,'') = '' OR  NVL(pNumcte, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
            cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
            cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;
		END IF;
		
		EXECUTE PROCEDURE bdinteg:sp_mc_obteninfocliente('001',pNumSol, pNumcte) 
			INTO cCodRetSP, cMensajeRet,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
			cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;

		IF	NVL(cEstado, '' ) = ''			AND NVL(cCiudad, '' )  = ''		AND NVL(cMunicipio, '' )  = ''		AND NVL(cColonia , '' ) = ''	AND NVL(cCalle, '' ) = '' 	AND
			NVL(cNumExt, '' ) = '' 			AND NVL(cNumInt , '' ) = ''		AND NVL(cCodPostal , '' ) = '' 		AND NVL(sEdificio, '' ) = ''	AND NVL(cDepto, '' ) = '' 	AND
			NVL(cTelCasa, '' ) = ''			AND NVL(cTelCel, '' )  = ''		AND NVL(cTelTrab, '' )   = '' 		AND NVL(cExt, '' ) 	  = ''		AND NVL(cComplemento, '' ) = '' AND
			NVL(cLugarTrabajo, '' ) = ''	AND NVL(cActividad, '' ) = ''	AND  NVL(cSubActividad, '' ) = '' 	AND NVL(cNombreCong, '' ) = ''	AND NVL(cTelCong, '' ) = '' AND 
			NVL(cNombreR1, '' ) = '' 		AND NVL(cTelR1, '' ) = '' 		AND NVL(cParentestoR1, '' ) = '' 	AND NVL(cNombreR2, '' ) = ''	AND NVL( cTelR2, '' ) = '' 	AND 
			NVL(cParentestoR2, '' ) = '' THEN
			LET cCodRet = '00017';		
			RETURN cCodRet,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
			cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;
		ELSE
			IF cCodRetSP <> '00000' THEN
				RETURN cCodRet,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
				cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;
			ELSE
				RETURN cCodRet,cEstado,cCiudad,cMunicipio,cColonia,cCalle,cNumExt,cNumInt,cCodPostal,sEdificio,cDepto,cTelCasa,cTelCel,cTelTrab,cExt,
				cComplemento,cLugarTrabajo,cActividad,cSubActividad,cNombreCong,cTelCong,cNombreR1,cTelR1,cParentestoR1,cNombreR2,cTelR2,cParentestoR2;
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'Sp intermedio de bdinteg:sp_mc_obteninfocliente procedimiento para la obtencion de los datos del cliente',
'Autor: Esparza Brenis Fernando Martin',
'FECHA : 30/12/2013';

CREATE PROCEDURE "informix".sp_consultas_cac_centralcred(pUsuario CHAR(8), pIdFuncion CHAR(10), pSucursal CHAR(4), pFechaInicio DATE, pFechaFinal DATE, pNumSolicitud CHAR(20), pBanCac CHAR(1), 
														pCac_Opt1_1 DECIMAL(5,2), pCac_Opt3_1 INTEGER, pArea CHAR(2), pStatus CHAR(2), pCausa CHAR(3), pProducto CHAR(4),
														pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
				CHAR(20) AS num_solicitud,
				CHAR(20) AS num_cliente,
				CHAR(104) AS nombre_cliente,
				CHAR(13) AS rfc,
				CHAR(4) AS sucursal,
				DATE AS fecha_solicitud,
				DATE AS fecha_cambio_status,
				DECIMAL(18,2) AS importe_linea,
				DECIMAL(5,2) AS eficiencia,
				INTEGER AS historial,
				DECIMAL(5,2) AS puntos_1a_seccion,
				DECIMAL(5,2) AS puntos_2a_seccion,
				CHAR(2) AS status,
				CHAR(511) AS observaciones_anteriores,
				DECIMAL(8,2) AS suma_secciones,
				CHAR(3) AS causa_status;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE pEmpresa CHAR(3);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	-- VARIABLES DEL SP PRODUCTIVO
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(104);
	DEFINE cRfc CHAR(13);
	DEFINE cSucursal CHAR(4);
	DEFINE dFechaSolicitud DATE;
	DEFINE dFechaCambioStatus DATE;
	DEFINE dImporteLinea DECIMAL(18,2);
	DEFINE dEficiencia DECIMAL(5,2);
	DEFINE iHistorial INTEGER;
	DEFINE dPuntos1Secc DECIMAL(5,2);
	DEFINE dPuntos2Secc DECIMAL(5,2);
	DEFINE cStatus CHAR(2);
	DEFINE cObservacionesAnteriores CHAR(511);
	DEFINE dSumaSecciones DECIMAL(8,2);
	DEFINE cCausaStatus CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET pEmpresa = '001';
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	-- VARIABLES DEL SP PRODUCTIVO
	LET cMensajeRetorno = '';
	LET cNumSolicitud = '';
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET cRfc = '';
	LET cSucursal = '';
	LET dFechaSolicitud = NULL;
	LET dFechaCambioStatus = NULL;
	LET dImporteLinea = NULL;
	LET dEficiencia = NULL;
	LET iHistorial = 0;
	LET dPuntos1Secc = NULL;
	LET dPuntos2Secc = NULL;
	LET cStatus = '';
	LET cObservacionesAnteriores = '';
	LET dSumaSecciones = NULL;
	LET cCausaStatus = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambioStatus, 
					dImporteLinea, dEficiencia, iHistorial, dPuntos1Secc, dPuntos2Secc, cStatus, cObservacionesAnteriores, dSumaSecciones, cCausaStatus;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_cac_centralcred.sql';
		--TRACE ON;
		
		-- VALIDACIÃ?Â?N DE LOS DATOS DE ENTRADA
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambioStatus, 
					dImporteLinea, dEficiencia, iHistorial, dPuntos1Secc, dPuntos2Secc, cStatus, cObservacionesAnteriores, dSumaSecciones, cCausaStatus;
		END IF;
		
		-- VALIDACIÃ?Â?N DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambioStatus, 
					dImporteLinea, dEficiencia, iHistorial, dPuntos1Secc, dPuntos2Secc, cStatus, cObservacionesAnteriores, dSumaSecciones, cCausaStatus;
		END IF;
		
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_consultas_cac_central2(pEmpresa, pSucursal, pFechaInicio, pFechaFinal, pNumSolicitud, pBanCac, pCac_Opt1_1, pCac_Opt3_1, pArea, pStatus, pCausa, pProducto, pUsuario, pRegistros, pRecuperacion)
				INTO cCodRetSp, cMensajeRetorno, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambioStatus, 
					dImporteLinea, dEficiencia, iHistorial, dPuntos1Secc, dPuntos2Secc, cStatus, cObservacionesAnteriores, dSumaSecciones, cCausaStatus
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN SP bdicred:sp_consultas_CAC_central';
			END IF;
			
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambioStatus, 
				dImporteLinea, dEficiencia, iHistorial, dPuntos1Secc, dPuntos2Secc, cStatus, cObservacionesAnteriores, dSumaSecciones, cCausaStatus WITH RESUME;
				
			LET iRecuperacion = iRecuperacion + 1;
				
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambioStatus, 
					dImporteLinea, dEficiencia, iHistorial, dPuntos1Secc, dPuntos2Secc, cStatus, cObservacionesAnteriores, dSumaSecciones, cCausaStatus;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumSolicitud, cNumCliente, cNombreCliente, cRfc, cSucursal, dFechaSolicitud, dFechaCambioStatus, 
					dImporteLinea, dEficiencia, iHistorial, dPuntos1Secc, dPuntos2Secc, cStatus, cObservacionesAnteriores, dSumaSecciones, cCausaStatus;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 11/12/2013",
"BD: bdicnweb",
"DESCRIPCION: SP intermedio que realiza las consultas de las solicitudes por un criterio dado";

CREATE PROCEDURE "informix".sp_guardadireccionesctemoral
                                (pUsuario CHAR(8),
				 pIdFuncion CHAR(10),
				 pfuncion CHAR(1),
				 pnumcte CHAR(20),
				 psecuencia SMALLINT,
				 ptipodir CHAR(1),
				 pcalle CHAR(40),
				 pcolonia CHAR(60),
				 pmunicipio CHAR(5),   
				 pentre_calles CHAR(40),
				 ppais CHAR(3),          -- '001' 
				 pentidad CHAR(2),       -- '15'
				 plocalidad CHAR(3),     -- '110'
				 pcodpostal CHAR(5),
				 ptipotel1 CHAR(1),
				 ptelefono1 CHAR(13),
				 ptipotel2 CHAR(1),
				 ptelefono2 CHAR(13),
				 ptipotel3 CHAR(1),
				 ptelefono3 CHAR(13),
				 pextension CHAR(5),
				 pestado_inegi CHAR(2),
				 pmunicipio_inegi CHAR(3),
				 plocalidad_inegi CHAR(4),
				 pnociudad SMALLINT,   --- aqui va ciudad_coppel 1417
				 pnoext CHAR(10),
				 pnoint CHAR(10),
				 pdepto CHAR(6),
				 pnocalle INTEGER,
				 pnocolonia INTEGER,
				 ppuntocar CHAR(1),
				 punihabi CHAR(1),
				 pmanz SMALLINT,
				 ppotros SMALLINT,
				 pandador SMALLINT,
				 petapa SMALLINT,
				 plote SMALLINT,
				 pedif SMALLINT,
				 pentrada SMALLINT,
				 pobserva CHAR(80),
				 pSucursal CHAR(4))
	RETURNING CHAR(5) AS codret;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
        define v_ciudad_coppel smallint;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

     --  SET DEBUG FILE TO '/tmp/mfinis/sp_guardadireccionesctemoral.out';
     --  TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pnumcte = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		IF pfuncion NOT IN('A','B') THEN
			LET cCodRet = '00292';
			RETURN cCodRet;
		END IF;

		IF pfuncion = 'B' THEN
			LET pfuncion = 'A';
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;

               -- cuando es 15 Estado de Mexico trae la localidad viene en blanco porque localidad es solo para el DF delegaciones.
               -- 15 Estado de Mexico y Provincias.
               IF pentidad <> '09' THEN

                   -- PARA TRAERSE LA CIUDAD COPPEL DE LA TABLA si_ciudades
                   if plocalidad <> '0' then
                      LET pmunicipio  = plocalidad;
                   else
                      let plocalidad = pmunicipio;
                   end if


                   LET v_ciudad_coppel = '';

                   SELECT ciudad_coppel INTO v_ciudad_coppel
                   FROM bdinteg:si_ciudades
                   WHERE pais   = '001' and
                         estado = pentidad and   
                         ciudad = pmunicipio;   

               END IF;

               -- 09 Distrito Federal.
               IF pentidad =  '09' THEN

                   -- descomente este nadamas. para cambio de provincia al DF ya que municipio trae el 017 y localidad 0
                   LET plocalidad = pmunicipio;

                   -- PARA TRAERSE LA CIUDAD COPPEL DE LA TABLA si_ciudades
                   LET v_ciudad_coppel = '';
                   SELECT ciudad_coppel INTO v_ciudad_coppel
                   FROM bdinteg:si_ciudades
                   WHERE pais   = '001'       AND
                         estado = pentidad    AND  
                         ciudad = plocalidad;
               END IF;


               LET pnociudad = v_ciudad_coppel;


 	       EXECUTE PROCEDURE bdinteg:"informix".direcciones_ctemoral(cEmpresa, pfuncion, pnumcte, psecuencia, ptipodir, pcalle, pcolonia, pmunicipio, pentre_calles, ppais,
                                                                         pentidad,
                                                                         plocalidad,
                                                                         pcodpostal, ptipotel1, ptelefono1, ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension,
                                                                         pestado_inegi,pmunicipio_inegi, plocalidad_inegi, pnociudad, pnoext, pnoint, pdepto, pnocalle, pnocolonia,
                                                                         ppuntocar, punihabi,pmanz, ppotros, pandador, petapa, plote, pedif, pentrada, pobserva, pUsuario, CURRENT, pSucursal)
	       INTO cCodRetSp;

		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP direcciones_ctemoral';
		ELIF iCodRetSp = 104 THEN
			LET cCodRet = '00022';
			RETURN cCodRet;
		ELIF iCodRetSp = 110 THEN
			LET cCodRet = '00017';
			RETURN cCodRet;
		ELIF iCodRetSp = 999 THEN
			LET cCodRet = '00294';
			RETURN cCodRet;
		END IF;
		RETURN cCodRet;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 27/05/2014',
'DESCRIPCION: alta de direcciones del cliente',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_guardadireccionescteprospecto(

			pUsuario CHAR(8),
			pIdfuncion CHAR(10),
			pFuncion         CHAR(1),
			pNumCte          CHAR(20),
			pSecuencia       SMALLINT,
			pTipoDir         CHAR(1),
			pCalle           CHAR(40),
			pColonia         CHAR(60),
			pMunicipio       CHAR(5),
			pEntre_Calles    CHAR(40),
			pPais            CHAR(3),
			pEntidad         CHAR(2),
			pLocalidad       CHAR(3),
			pCodPostal       CHAR(5),
			pTipoTel1        CHAR(1),
			pTelefono1       CHAR(13),
			pTipoTel2        CHAR(1),
			pTelefono2       CHAR(13),
			pTipoTel3        CHAR(1),
			pTelefono3       CHAR(13),
			pExtension       CHAR(5),
			pEstado_Inegi    CHAR(2),
			pMunicipio_Inegi CHAR(3),
			pLocalidad_Inegi CHAR(4),
			pNoCiudad        SMALLINT,
			pNoExt           CHAR(10),
			pNoInt           CHAR(10),
			pDepto           CHAR(6),
			pNoCalle         INTEGER,
			pNoColonia       INTEGER,
			pPuntoCar        CHAR(1),
			pUniHabi         CHAR(1),
			pManz            SMALLINT,
			pPOtros          SMALLINT,
			pAndador         SMALLINT,
			pEtapa           SMALLINT,
			pLote            SMALLINT,
			pEdif            SMALLINT,
			pEntrada         SMALLINT,
			pObserva         CHAR(80),
			pUser_Insert     CHAR(8),
			pFecha_Insert    DATE,
			cSucursal        CHAR(4))
	RETURNING CHAR(5) AS cCodigoRet;

	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCarrier INTEGER;
        DEFINE v_ciudad_coppel char (4);

	LET iSqlErr = '0';
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iCarrier = '';
        let v_ciudad_coppel = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		-- SET DEBUG FILE TO '/tmp/mfinis/prospescto/direccionesProspecto.out';
		-- TRACE ON;

		IF NVL(pUsuario, '') = '' OR NVL(pIdFuncion, '') = '' OR NVL(pNumCte, '') = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

                -- PARA EL ESTADO DE MEXICO SE ASIGNA EL MUNICIPIO A LA LOCALIDAD.
                IF pEntidad <> '15' THEN
                   LET pLocalidad = pMunicipio;
                END IF;

                -- PARA TRAERSE LA CIUDAD COPPEL DE LA TABLA si_ciudades
                LET v_ciudad_coppel = '';
                SELECT ciudad_coppel INTO v_ciudad_coppel
                FROM bdinteg:si_ciudades
                WHERE pais   = '001'      AND
                      estado = pentidad   AND   
                      ciudad = pmunicipio;    

                LET pNoCiudad = v_ciudad_coppel;


		EXECUTE PROCEDURE bdinteg:"informix".direcciones('001', pFuncion, pNumCte, pSecuencia, pTipoDir, pCalle,
		pColonia, pMunicipio, pEntre_Calles, pPais, pEntidad, pLocalidad, pCodPostal, pTipoTel1, pTelefono1,
		pTipoTel2, pTelefono2, pTipoTel3, pTelefono3, pExtension, pEstado_Inegi, pMunicipio_Inegi, pLocalidad_Inegi, pNoCiudad, pNoExt, pNoInt, pDepto, pNoCalle,
		pNoColonia, pPuntoCar, pUniHabi, pManz, pPOtros, pAndador, pEtapa, pLote, pEdif, pEntrada, pObserva, pUser_Insert, pFecha_Insert, cSucursal, iCarrier)
		INTO cCodRetSp;
		IF cCodRetSp = '104' THEN
			LET cCodRet = '00022'; --'El NUMERO DE CLIENTE NO EXISTE
			RETURN cCodRet;
		ELIF cCodRetSp <> '000' THEN
			LET cCodRet = cCodRetSp;
			RETURN cCodRet;
		ELSE
			RETURN cCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Esparza Brenis Fernando Martin',
'Descripcion: SP intermedio se optimiza sp guardando sp guardando la direcciÃ³n del cliente en variables',
'Fecha: 10/06/2014';

CREATE PROCEDURE "informix".sp_sw_ro_consultamovtosdiarioscta(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20),pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2), pNumRegistro INTEGER,pRecuperacion INTEGER)

                    returning CHAR(5)  AS Cod_Retorno,
                                DATE     AS Fecha,
                                DATETIME HOUR to FRACTION(3) AS Hora,
                                CHAR(4)  AS CveTransaccion,
                                CHAR(50) AS Desc_Transaccion,
                                CHAR(16) AS Folio,
                                DATE     AS Periodo_Inicial,
                                MONEY(14,2) AS Monto,
                                DATE     AS Periodo_Final,
                                CHAR(20) AS Sistema_Cuenta,
                                CHAR(1)  AS Naturaleza,
                                CHAR(40) AS Referencia,
                                CHAR(1)  AS Reversos,
                                CHAR(4)  AS Sucursal,
                                CHAR(20) AS CveProcedencia,
                                CHAR(50) AS Desc_Procedencia,
                                MONEY(14,2) AS Saldo,
                                CHAR(20) AS Numero_Tarjeta,
                                CHAR(1)  AS Reversados,
                          CHAR(8)  AS Usuario,
                                CHAR(23) AS Referencia23;

DEFINE iexiste                INT;
DEFINE cCodRet                CHAR(5);
DEFINE iSql_err           INT;                                  
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha               DATE;
DEFINE dHora                DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion          CHAR(4);
DEFINE cD_Transaccion     CHAR(50);
DEFINE mMonto               MONEY(14,2);
DEFINE cNaturaleza          CHAR(1);
DEFINE mSaldo                MONEY(14,2);
DEFINE cReferencia           CHAR(40);
DEFINE cReversos          CHAR(1);
DEFINE cReversados          CHAR(1);
DEFINE cSucursal           CHAR(4);
DEFINE cFolio                CHAR(16);
DEFINE cProcedencia          CHAR(20);
DEFINE cD_Procedencia     CHAR(50);
DEFINE dPeriodoI_1          DATE;
DEFINE dPeriodoF_1          DATE;
DEFINE sNUMSERIAL       INT8;
DEFINE sNumSecuencia    INT8;
DEFINE cUsuario         CHAR(8);
DEFINE cReferencia23    CHAR(23);
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta          CHAR(20);
--VARIABLES PARA FECHAS HISTORICAS
DEFINE cconsmovhis      CHAR(10);
DEFINE cconsmovhisold   CHAR(10);
DEFINE cconsmovhisold2  CHAR(10);
DEFINE cconsmovhisold3  CHAR(10);
DEFINE cconsmovhisold4  CHAR(10);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE cCodfun          CHAR(3);
DEFINE cCodref          INTEGER;
--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;    
LET dFecha               = "";
LET dHora                = "";
LET cTransaccion     = "";
LET cD_Transaccion     = "";
LET mMonto               = 0;
LET cNaturaleza          = "";
LET mSaldo                = 0;
LET cReferencia          = "";
LET cReversos          = "";
LET cReversados          = "";
LET cSucursal           = "";
LET cFolio                = "";
LET cProcedencia     = "";
LET cD_Procedencia     = "";
LET dPeriodoI_1          = "";
LET dPeriodoF_1          = "";
LET sNUMSERIAL      =  0;
LET sNumSecuencia     =  0;
LET cUsuario        = "";
LET cReferencia23   = "";
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta     = "";
--VARIABLES PARA FECHAS HISTORICAS
LET cconsmovhis     = '';
LET cconsmovhisold  = '';
LET cconsmovhisold2 = '';
LET cconsmovhisold3 = '';
LET cconsmovhisold4 = '';
--VARIABLES DE PAGINACION
LET iCont       = 0;
LET pEmpresa   = '001';
LET cCodfun               ='';
LET cCodref               =0;

BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;
     END EXCEPTION;
                
     --SET DEBUG FILE TO "/tmp/mfinis/sp_sw_ro_consultamovtosdiarioscta.out";
     --TRACE ON;
              
     IF      cID_USUARIOC = ''      OR
          cID_FUNCIONC = ''      OR
          cNUMCUENTA  = ''     OR
          dPERIODOI   IS NULL OR
          dPERIODOF      IS NULL     OR
          cSISTEMACUENTA = '' THEN
          LET cCodRet = "00036";
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
          cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
     END IF;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
          cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;                        
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
            cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
        END IF;
    END IF; 
     IF cSISTEMACUENTA <> 'CAPTACION' AND cSISTEMACUENTA <> 'CREDITO'  AND cSISTEMACUENTA <> 'INVERSIONES' THEN
          LET cCodRet = "00037";
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
          cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
     END IF;

     --VALIDACION
     IF cSISTEMACUENTA = 'CAPTACION' THEN
          EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
          INTO cCodRet;
     END IF;

     IF cSISTEMACUENTA = 'CREDITO' THEN
          EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
          INTO cCodRet;
     END IF;

     IF cSISTEMACUENTA = 'INVERSIONES' THEN
          EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
          INTO cCodRet;
     END IF;

     IF (cCodRet != '00000')  THEN
          RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
     END IF;
     -- TERMINA VALIDACION
	
	SET ISOLATION TO DIRTY READ;
	SELECT valor
	INTO cconsmovhis
	FROM bdicheq:"informix".sc_param
	WHERE empresa = pEmpresa
	AND codparam = 'fechcon_movhis';
	
	SELECT valor
	INTO cconsmovhisold
	FROM bdicheq:"informix".sc_param
	WHERE empresa = pEmpresa
	AND codparam = 'FechIniCon_movhis_ol';
	
	SELECT valor
	INTO cconsmovhisold2
	FROM bdicheq:"informix".sc_param
	WHERE empresa = pEmpresa
	AND codparam = 'FechaIniMovhisOld2';
	
	SELECT valor
	INTO cconsmovhisold3
	FROM bdicheq:"informix".sc_param
	WHERE empresa = pEmpresa
	AND codparam = 'vfechconmovhisold3';
	
	SELECT valor
	INTO cconsmovhisold4
	FROM bdicheq:"informix".sc_param
	WHERE empresa = pEmpresa
	AND codparam = 'FechaIniMovhisOld4';

                  
    IF cSISTEMACUENTA = 'CAPTACION' THEN
		SET ISOLATION TO DIRTY READ;
		FOREACH
		SELECT FIRST 1 NVL(COUNT(cuenta),0) into iexiste FROM bdicheq:sc_maechq WHERE cuenta  = cNUMCUENTA
		UNION
		SELECT NVL(COUNT(cuenta_tf),0) FROM bditransfer:tf_maecte WHERE cuenta_tf  = cNUMCUENTA
		ORDER BY 1 DESC
		END FOREACH;
          IF iexiste  = 0 THEN
               LET cCodRet = "00009";
               RETURN
               cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;
		  SET ISOLATION TO DIRTY READ;
          SELECT NVL(COUNT(cuenta),0) 
               INTO iexiste
               FROM bdicheq:"informix".sc_movdia
               WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
            AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
            AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
            AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
			AND cancelad <> 'S';  
               IF iexiste  = 0 THEN
					SET ISOLATION TO DIRTY READ;
                    SELECT NVL(COUNT(cuenta),0) 
                    INTO iexiste
                    FROM bdicheq:"informix".sc_movhis
                    WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
                AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
                AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
				AND cancelad <> 'S'; 
                    IF iexiste  = 0 THEN
						 SET ISOLATION TO DIRTY READ;
                         SELECT NVL(COUNT(cuenta),0) 
                         INTO iexiste
                         FROM bdicheq:"informix".sc_movhis_old
                         WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
                    AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
                    AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                    AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
					AND cancelad <> 'S'; 
                        IF iexiste  = 0 THEN
							SET ISOLATION TO DIRTY READ;
							SELECT {+INDEX (bdicheq:sc_movhis_old2 idx_movhis1_old2)} NVL(COUNT(cuenta),0) 
							INTO iexiste
							FROM bdicheq:"informix".sc_movhis_old2
							WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
                        AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
                        AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                        AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
						AND cancelad <> 'S'; 
                            IF iexiste  = 0 THEN
								   SET ISOLATION TO DIRTY READ;
                                   SELECT {+INDEX (bdicheq:sc_movhis_old3 idx_movhis_old3)} NVL(COUNT(cuenta),0) 
                                   INTO iexiste
                                   FROM bdicheq:"informix".sc_movhis_old3
                                   WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
                            AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
                            AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                            AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
							AND cancelad <> 'S'; 
								IF iexiste  = 0 THEN
								   SET ISOLATION TO DIRTY READ;
                                   SELECT {+INDEX (bdicheq:sc_movhis_old4 idx_movhis_old4)} NVL(COUNT(cuenta),0) 
                                   INTO iexiste
                                   FROM bdicheq:"informix".sc_movhis_old4
                                   WHERE empresa='001' AND cuenta  = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
                            AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
                            AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                            AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
							AND cancelad <> 'S'; 
									IF iexiste  = 0 THEN
									   SET ISOLATION TO DIRTY READ;
	                                   SELECT NVL(COUNT(cuenta),0) 
	                                   INTO iexiste
	                                   FROM bditransfer:tf_success_transac
	                                   WHERE cuenta  = cNUMCUENTA AND fecha_alt BETWEEN dPERIODOI AND dPERIODOF
									   AND fecha_alt < to_date('20/03/2015','%d/%m/%Y')
	                            AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END; 
									END IF;
	                            END IF;
                            END IF;
                        END IF;
                    END IF;
               END IF;

               IF iexiste  = 0 THEN
                LET cCodRet = "00039";
                RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
               END IF;

        SET ISOLATION TO DIRTY READ;
        FOREACH               
            SELECT SKIP pNumRegistro FIRST pRecuperacion MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                    MO.sucursal,MO.folio_suc,  
                    dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
            INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
            dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23
            FROM bdicheq:sc_movdia MO
            LEFT JOIN bdinteg:si_transacc TR
            ON MO.transacc = TR.numero
			AND TR.sistema = '01'
            WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
            AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
		AND MO.cancelad <> 'S'					
             UNION
                 SELECT      MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                     MO.sucursal,MO.folio_suc,  
                     dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
             FROM bdicheq:sc_movhis MO
                 LEFT JOIN bdinteg:si_transacc TR
                 ON MO.transacc = TR.numero
				 AND TR.sistema = '01'
                 WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
             AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF    
             AND MO.fech_alt >= cconsmovhis
             AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
             AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
             AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
		AND MO.cancelad <> 'S'
         UNION
             SELECT  MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                     MO.sucursal,MO.folio_suc,  
                     dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
             FROM bdicheq:sc_movhis_old  MO
             LEFT JOIN bdinteg:si_transacc TR
             ON MO.transacc = TR.numero
			 AND TR.sistema = '01'
             WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
             AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
             AND MO.fech_alt >= cconsmovhisold
             AND MO.fech_alt < cconsmovhis
             AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
             AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
             AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
		AND MO.cancelad <> 'S'				
         UNION
             SELECT {+INDEX (bdicheq:sc_movhis_old2 idx_movhis1_old2)} MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                     MO.sucursal,MO.folio_suc,  
                     dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
             FROM bdicheq:sc_movhis_old2  MO
             LEFT JOIN bdinteg:si_transacc TR
             ON MO.transacc = TR.numero
			 AND TR.sistema = '01'
             WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
             AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
             AND MO.fech_alt >= cconsmovhisold2
             AND MO.fech_alt < cconsmovhisold
             AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
             AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
             AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
		AND MO.cancelad <> 'S'				
         UNION
             SELECT  {+INDEX (bdicheq:sc_movhis_old3 idx_movhis_old3)} MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                     MO.sucursal,MO.folio_suc,  
                     dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
             FROM bdicheq:sc_movhis_old3  MO
             LEFT JOIN bdinteg:si_transacc TR
             ON MO.transacc = TR.numero
			 AND TR.sistema = '01'
             WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
             AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
             AND MO.fech_alt >= cconsmovhisold3
             AND MO.fech_alt < cconsmovhisold2
             AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
             AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
             AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
		AND MO.cancelad <> 'S'
		UNION
             SELECT  {+INDEX (bdicheq:sc_movhis_old4 idx_movhis_old4)} MO.fech_alt,MO.fech_hor,MO.transacc,TR.descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
                     MO.sucursal,MO.folio_suc,  
                     dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
             FROM bdicheq:sc_movhis_old4  MO
             LEFT JOIN bdinteg:si_transacc TR
             ON MO.transacc = TR.numero
			 AND TR.sistema = '01'
             WHERE MO.empresa='001' AND MO.cuenta = cNUMCUENTA
             AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
             AND MO.fech_alt >= cconsmovhisold4
             AND MO.fech_alt < cconsmovhisold3
             AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
             AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
             AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
		AND MO.cancelad <> 'S'
	UNION
		SELECT  MO.fecha_alt as fech_alt,extend(MO.fech_hor_fin,HOUR to FRACTION(3)) as fech_hor,MO.transacc,TR.descripcion,MO.monto,DECODE(MO.tpo_mov,"D","A","C","C"),MO.sdo_cuenta_origen,MO.referencia,'',
		'',MO.secuencia,  
		dPERIODOI,dPERIODOF,CAST(MO.id_transacc_mps as FLOAT) as num_serial,'','TRANSFER',''
		FROM bditransfer:tf_success_transac  MO
		LEFT JOIN bditransfer:tf_cat_transac_mps TR
		ON MO.transacc = TR.transac
		WHERE MO.cuenta = cNUMCUENTA
		AND MO.fecha_alt BETWEEN dPERIODOI AND dPERIODOF
		AND MO.fecha_alt < to_date('20/03/2015','%d/%m/%Y')
		AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
		ORDER BY MO.fech_alt DESC,MO.fech_hor DESC

             IF (SELECT NVL(COUNT(*),0) FROM bdinteg:si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
                 SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM bdinteg:si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
             ELIF (SELECT NVL(COUNT(*),0) FROM bdinteg:si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
                 SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM bdinteg:si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
             ELIF (SELECT NVL(COUNT(*),0) FROM bdinteg:si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
                 SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM bdinteg:si_procedencia WHERE sucursal=cSucursal AND transacc='';
             ELSE
                 LET cProcedencia="";
                 LET cD_Procedencia="";
             END IF;
                
                
		LET iCont=iCont+1;
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;                             

            
        END FOREACH;

        IF iCont = 0 THEN
        LET cCodRet = '1001';
            RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
        END IF;
     ELIF cSISTEMACUENTA = 'CREDITO' THEN
		SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito = cNUMCUENTA
            UNION
            SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito = cNUMCUENTA ORDER BY CONT DESC
        END FOREACH;
          IF iexiste  = 0 THEN
               LET cCodRet = "00009";
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;
		  
		  SET ISOLATION TO DIRTY READ;
          SELECT NVL(COUNT(num_credito),0) 
          INTO iexiste
          FROM bdicred:sd_movdia
          WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
        AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
        AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
        AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
		AND reversado <> 'S';
          IF iexiste  = 0 THEN
			   SET ISOLATION TO DIRTY READ;
               SELECT NVL(COUNT(num_credito),0) 
               INTO iexiste
               FROM bdicred:sd_movhis
               WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
            AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
            AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
			AND reversado <> 'S';
               IF iexiste  = 0 THEN
					SET ISOLATION TO DIRTY READ;
                    SELECT NVL(COUNT(num_credito),0) 
                    INTO iexiste
                    FROM bdicred:sd_movhis_new
                    WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
                    AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
                    AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                    AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
					AND reversado <> 'S';
                    IF iexiste  = 0 THEN
						 SET ISOLATION TO DIRTY READ;
                         SELECT NVL(COUNT(num_credito),0) 
                         INTO iexiste
                         FROM bdicred:sd_movdiacrd
                         WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
                         AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
                         AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                         AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
						 AND reversado <> 'S';
                         IF iexiste  = 0 THEN
							  SET ISOLATION TO DIRTY READ;
                              SELECT NVL(COUNT(num_credito),0) 
                              INTO iexiste
                              FROM bdicred:sd_movhiscrd
                              WHERE empresa='001' AND num_credito = cNUMCUENTA AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF
                              AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
                              AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
                              AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
							  AND reversado <> 'S';     
                         END IF;         
                    END IF;
               END IF;
          END IF;

          IF iexiste  = 0 THEN
               LET cCodRet = "00039";
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;

          SET ISOLATION TO DIRTY READ;
          FOREACH
               SELECT SKIP pNumRegistro FIRST pRecuperacion  MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
               INTO          
               cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
               dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
               FROM bdicred:sd_maecred MC
               LEFT JOIN bdicred:sd_movdia MO
               ON MC.num_credito = MO.num_credito
               LEFT JOIN bdicred:sd_transfun TR
               ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
               WHERE MO.num_credito = cNUMCUENTA
               AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			AND MO.reversado <> 'S'			
          UNION
               SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
               FROM bdicred:sd_maecred MC
               LEFT JOIN bdicred:sd_movhis  MO
               ON MC.num_credito = MO.num_credito
               LEFT JOIN bdicred:sd_transfun TR
               ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
               WHERE MO.num_credito = cNUMCUENTA
               AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			AND MO.reversado <> 'S'			
          UNION
               SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
               FROM bdicred:sd_maecred MC
               LEFT JOIN bdicred:sd_movhis_new  MO
               ON MC.num_credito = MO.num_credito
               LEFT JOIN bdicred:sd_transfun TR
               ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
               WHERE MO.num_credito = cNUMCUENTA
               AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			AND MO.reversado <> 'S'			
          UNION      
               SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
               FROM bdicred:sd_maecredcrd MC
               LEFT JOIN bdicred:sd_movdiacrd  MO
               ON MC.num_credito = MO.num_credito
               LEFT JOIN bdicred:sd_transfun TR
               ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
               WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA
               AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			AND MO.reversado <> 'S'
          UNION
               SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
            MO.transacc_suc,TR.descripcion,MO.referencia,
            MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
               FROM bdicred:sd_maecredcrd MC
               LEFT JOIN bdicred:sd_movhiscrd  MO
               ON MC.num_credito = MO.num_credito
               LEFT JOIN bdicred:sd_transfun TR
               ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
               WHERE MO.num_credito = cNUMCUENTA
               AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			AND MO.reversado <> 'S'
            ORDER BY MO.secuencia DESC

            IF (SELECT NVL(COUNT(*),0) FROM bdinteg:si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
                SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM bdinteg:si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
            ELIF (SELECT NVL(COUNT(*),0) FROM bdinteg:si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
                SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM bdinteg:si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
            ELIF (SELECT NVL(COUNT(*),0) FROM bdinteg:si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
                SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM bdinteg:si_procedencia WHERE sucursal=cSucursal AND transacc='';
            ELSE
                LET cProcedencia="";
                LET cD_Procedencia="";
            END IF;
              
                LET iCont=iCont+1;

               IF cCodfun ='001' AND cCodref in (1,2,3) THEN
                    IF iCont>0 THEN
                         LET iCont=iCont - 1;
                    END IF;
               ELIF cCodfun ='002' AND cCodref =1 THEN
                    IF iCont>0 THEN
                         LET iCont=iCont - 1;
                    END IF;
               ELSE
                         RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                         cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
               END IF;

          END FOREACH;

                        
         IF iCont = 0 AND pNumRegistro=0 THEN
               LET cCodRet = '00039';
                    RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                            cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          ELIF iCont = 0 THEN
               LET cCodRet = '1001';
                    RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                            cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF
     ELIF cSISTEMACUENTA = 'INVERSIONES' THEN
		  SET ISOLATION TO DIRTY READ;
          SELECT NVL(COUNT(cuenta),0) INTO iexiste FROM bdinvers:sv_maeinv WHERE cuenta  = cNUMCUENTA;
          IF iexiste  = 0 THEN
               LET cCodRet = "00009";
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;
		
		SET ISOLATION TO DIRTY READ;
        FOREACH
          SELECT LIMIT 1 NVL(COUNT(cuenta),0)  AS CONT
          INTO iexiste
          FROM bdinvers:sv_movdia
          WHERE cuenta = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
        AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
        AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
        AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
		AND cancelad <> 'S'
        UNION
          SELECT NVL(COUNT(cuenta),0) AS CONT 
          FROM bdinvers:sv_movhis
          WHERE cuenta = cNUMCUENTA AND fech_alt BETWEEN dPERIODOI AND dPERIODOF
        AND monto_tot = CASE WHEN mImporte = 0 THEN monto_tot ELSE mImporte END
        AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
        AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END
		AND cancelad <> 'S'
        ORDER BY CONT DESC
        END FOREACH;
          IF iexiste  = 0 THEN
               LET cCodRet = "00039";
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
               cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF;

         SET ISOLATION TO DIRTY READ;
          FOREACH
               SELECT SKIP pNumRegistro FIRST pRecuperacion     
               MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,MO.num_serial
               INTO
               dFecha,dHora,cFolio,cTransaccion,cD_Transaccion,mMonto,cReversados,dPeriodoI_1,dPeriodoF_1,sNumSecuencia,cSucursal,cUsuario, sNUMSERIAL
               FROM bdinvers:sv_maeinv MC
               LEFT JOIN bdinvers:sv_movdia MO
               ON MC.cuenta = MO.cuenta
               LEFT JOIN bdinteg:si_transacc TR
               ON MO.transacc = TR.numero 
               WHERE MO.cuenta = cNUMCUENTA
               AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END
			AND MO.cancelad <> 'S'
               UNION
               SELECT MO.fech_alt,MO.fech_hor,MO.folio_suc,MO.transacc,TR.descripcion,MO.monto_tot,MO.cancelad,dPERIODOI,dPERIODOF,MO.secuencia,MO.sucursal,MO.usuario,MO.num_serial
               FROM bdinvers:sv_maeinv MC
               LEFT JOIN bdinvers:sv_movhis MO
               ON MC.cuenta = MO.cuenta
               LEFT JOIN bdinteg:si_transacc TR
               ON MO.transacc = TR.numero 
               WHERE MO.cuenta = cNUMCUENTA
               AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
            AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
            AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
            AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END 
			AND MO.cancelad <> 'S'
            ORDER BY MO.num_serial DESC

			LET iCont=iCont+1;    
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
                   
          END FOREACH;

          IF iCont = 0 THEN
          LET cCodRet = '1001';
               RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
                       cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
          END IF
     END IF
END

END PROCEDURE

DOCUMENT
"AutOR : ARTURO CERVANTES PEÃ?A",
"FUNCIONAMIENTO:Este sp realizara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 09-02-2012",
"ACTUALIZO: Victor Hugo SÃ¡nchez M.",
"MODIFICACION: Se agregaron los parametros empleado,sucursal e importe para filtrar movimientos",
"FECHA: 04/07/2012",
"ACTUALIZO: Oscar Flores Conde (M-Finis Soluciones y Servicios Financieros)",
"MODIFICACION: Se agregaron el parametro de entrada para filtrar los movimientos reversados, se agrega en los parametros de salida la referencia a 23 posiciones",
"FECHA: 02/12/2013",
"BD    : bdinteg",
"VER   : 3.0";

CREATE PROCEDURE "informix".sp_consultareptoincmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				DATE AS fecha_origen,
				CHAR(20) AS num_solicitud,
				CHAR(1) AS origen,
				CHAR(20) AS num_cliente,
				CHAR(110) AS nombre,
				DECIMAL(18,2) AS lin_cred_actual,
				DECIMAL(18,2) AS lin_cred_sugerida,
				DECIMAL(18,2) AS porcentaje,
				CHAR(2) AS status,
				CHAR(8) AS ejecutivo_uno,     
				CHAR(8) AS ejecutivo_dos,
				CHAR(8) AS ejecutivo_tres,
				CHAR(120) AS motivo,
				INTEGER AS num_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iNoRegistros INTEGER;
	--DEFINE iRegistros INTEGER;
	--DEFINE iRecuperacion INTEGER;
	
	-- VARIABLES DEL SPL Productivo
	DEFINE cMensajeRetorno CHAR(80);
	DEFINE dFechaOrigen DATE;
	DEFINE cNumSolicitud CHAR(20);
	DEFINE cOrigen CHAR(1);
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombre CHAR(110);
	DEFINE dLinCredActual DECIMAL(18,2);
	DEFINE dLinCredSugerida DECIMAL(18,2);
	DEFINE dPorcentaje DECIMAL(18,2);
	DEFINE cStatus CHAR(2);
	DEFINE cEjecutivoUno CHAR(8);
	DEFINE cEjecutivoDos CHAR(8);
	DEFINE cEjecutivoTres CHAR(8);
	DEFINE cMotivo CHAR(120);
	DEFINE iNumRegistros INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iNoRegistros = 0;
	--LET iRegistros = 0;
	--LET iRecuperacion = 0;
	LET cMensajeRetorno = '';
	LET dFechaOrigen = NULL;
	LET cNumSolicitud = '';
	LET cOrigen = '';
	LET cNumCliente = '';
	LET cNombre = '';
	LET dLinCredActual = NULL;
	LET dLinCredSugerida = NULL;
	LET dPorcentaje = NULL;
	LET cStatus = '';
	LET cEjecutivoUno = '';
	LET cEjecutivoDos = '';
	LET cEjecutivoTres = '';
	LET cMotivo = '';
	LET iNumRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
				dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultareptoincmc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
				dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
				dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
				dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdicred:'informix'.sp_repto_inc_mc(cEmpresa, pFechaInicio, pFechaFin, pRegistros, pRecuperacion)
			INTO cCodRetSp, cMensajeRetorno, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
				dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros
		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicred:sp_repto_inc_mc';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003'; -- FALTA PARAMETRO DE EMPRESA
				RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
					dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros;
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00425'; -- EL PERIODI INDICADO NO ES VALIDO
				RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
					dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros;
			ELIF iCodRetSp = 3 THEN
				LET cCodRet = '00426'; -- EL PERIODO INDICADO NO ES EL CORRECTO, LA FECHA INICIAL NO PUEDE SER MAYOR A LA FINAL
				RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
					dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros;
			ELIF iCodRetSp = 4 THEN
				LET cCodRet = '00232';
				RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
					dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros;
			ELIF iCodRetSp = 5 THEN
				IF pRegistros = 0 THEN
					LET cCodRet = '00017';
				ELIF pRegistros > 0 THEN
					LET cCodRet = '1001';
				END IF;
				
				RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
					dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros;
			END IF;
			
			RETURN cCodRet, dFechaOrigen, cNumSolicitud, cOrigen, cNumCliente, cNombre, dLinCredActual, dLinCredSugerida,
				dPorcentaje, cStatus, cEjecutivoUno, cEjecutivoDos, cEjecutivoTres, cMotivo, iNumRegistros WITH RESUME;
		
		END FOREACH;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 05/02/2015',
'DESCRIPCION: Consulta los datos para el reporte mensual de incrementos',
'BD: bdicnweb';

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