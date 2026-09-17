CREATE PROCEDURE "informix".sp_soe_autenticacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(13))
	RETURNING CHAR(5) AS codret,
			CHAR(50) AS mensaje,
			CHAR(13) AS rfc_empresa,
			CHAR(3) AS numero_empresa,
			CHAR(40) AS nombre_empresa,
			CHAR(20) AS numcte,
			CHAR(50) AS nombre1,
			CHAR(50) AS nombre2,
			CHAR(50) AS apellido_paterno,
			CHAR(50) AS apellido_materno,
			CHAR(30) AS numero_identificacion,
			CHAR(1) AS tipo_usuario,
			CHAR(12) AS folio_activacion,
			INTEGER AS id_usuario,
			CHAR(50) AS correo,
			CHAR(10) AS no_serie_token,
			CHAR(4) AS sucursal,
			SMALLINT AS id_tipo_usuario,
			SMALLINT AS id_status;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCte CHAR(20);
	DEFINE cEmpresa CHAR(3);
	DEFINE iExiste INTEGER;
	DEFINE cRazon_Social CHAR(40);
	DEFINE cNombre1 CHAR(50); 
	DEFINE cNombre2 CHAR(50); 
	DEFINE cApPaterno CHAR(50); 
	DEFINE cApMaterno CHAR(50); 
	DEFINE cIdentificacion CHAR(30); 
	DEFINE cFolioActivacion CHAR(12); 
	DEFINE cTipoUsuario CHAR(1); 
	DEFINE iIdStatus SMALLINT; 
	DEFINE iIdUsuario INTEGER; 
	DEFINE cCorreo CHAR(50); 
	DEFINE cNsToken CHAR(10); 
	DEFINE cNumSucursal CHAR(4);
	DEFINE cMensaje CHAR(50);
	DEFINE iNoRegs SMALLINT;
	DEFINE iValidacion1 SMALLINT;
	DEFINE iValidacion2 SMALLINT;
	DEFINE iIdTipoUsuario SMALLINT;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCte = '';
	LET cEmpresa = '';
	LET cRazon_Social = '';
	LET iExiste = 0;
	LET cNombre1 = ''; 
	LET cNombre2 = ''; 
	LET cApPaterno = ''; 
	LET cApMaterno = ''; 
	LET cIdentificacion = ''; 
	LET cFolioActivacion = ''; 
	LET cTipoUsuario = ''; 
	LET iIdStatus = NULL; 
	LET iIdUsuario = NULL; 
	LET cCorreo = ''; 
	LET cNsToken = ''; 
	LET cNumSucursal = '';
	LET cMensaje = '';
	LET iNoRegs = 0;
	LET iValidacion1 = 0;
	LET iValidacion2 = 0;
	LET iIdTipoUsuario = 0;

	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensaje, pRfc, cEmpresa, cRazon_Social, cNumCte, cNombre1, cNombre2, cApPaterno, cApMaterno, cIdentificacion, 
				cTipoUsuario, cFolioActivacion, iIdUsuario, cCorreo, cNsToken, cNumSucursal, iIdTipoUsuario, iIdStatus;
		END EXCEPTION;
		
		--SET	DEBUG FILE TO '/informix/Berenice/sp_soe_autenticacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRfc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cMensaje, pRfc, cEmpresa, cRazon_Social, cNumCte, cNombre1, cNombre2, cApPaterno, cApMaterno, cIdentificacion, 
				cTipoUsuario, cFolioActivacion, iIdUsuario, cCorreo, cNsToken, cNumSucursal, iIdTipoUsuario, iIdStatus;
		END IF;
		
		-- ValidaciÃ³n del acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cMensaje, pRfc, cEmpresa, cRazon_Social, cNumCte, cNombre1, cNombre2, cApPaterno, cApMaterno, cIdentificacion, 
				cTipoUsuario, cFolioActivacion, iIdUsuario, cCorreo, cNsToken, cNumSucursal, iIdTipoUsuario, iIdStatus;
		END IF;
		
		-- Buscamos el RFC
		SET ISOLATION TO DIRTY READ;
		SELECT count(*)
		INTO iExiste
		FROM bdinteg:"informix".si_cliente
		WHERE rfc = TRIM(pRfc) AND tpo_persona IN ('02', '04', '05') AND tipo_cliente = '1';
		
		IF iExiste = 0 THEN
			LET cCodRet = '00035'; -- No existe el rfc en la tabla si_cliente
			RETURN cCodRet, cMensaje, pRfc, cEmpresa, cRazon_Social, cNumCte, cNombre1, cNombre2, cApPaterno, cApMaterno, cIdentificacion, 
				cTipoUsuario, cFolioActivacion, iIdUsuario, cCorreo, cNsToken, cNumSucursal, iIdTipoUsuario, iIdStatus;
		END IF;
		
		-- Buscamos los datos del cliente
		SET ISOLATION TO DIRTY READ;
		SELECT c.numcte, c.razon_social, cpm.empresa
		INTO cNumCte, cRazon_Social, cEmpresa
		FROM bdinteg:"informix".si_cliente c LEFT JOIN bdinteg:"informix".si_ctepm cpm ON cpm.numcte = c.numcte
		WHERE c.rfc = TRIM(pRfc) AND c.tpo_persona IN ('02', '04', '05') AND c.tipo_cliente = '1';
			
		IF cNumCte IS NULL OR cRazon_Social IS NULL OR cEmpresa IS NULL 
			OR TRIM(cNumCte) = '' OR TRIM(cRazon_Social) = '' OR TRIM(cEmpresa) = '' THEN
			LET cCodRet = '00177';
			RETURN cCodRet, cMensaje, pRfc, cEmpresa, cRazon_Social, cNumCte, cNombre1, cNombre2, cApPaterno, cApMaterno, cIdentificacion, 
				cTipoUsuario, cFolioActivacion, iIdUsuario, cCorreo, cNsToken, cNumSucursal, iIdTipoUsuario, iIdStatus;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH SELECT bs.nombre1, bs.nombre2, bs.apell_paterno, bs.apell_materno, bs.identificacion_admin, bs.folio_activa, bs.es_replegal,
			bu.id_status, bu.id_usuario, bdu.e_mail, bs.ns_token, bt.suc_registro, bu.id_tipo_usuario
			INTO cNombre1, cNombre2, cApPaterno, cApMaterno, cIdentificacion, cFolioActivacion, cTipoUsuario, 
				iIdStatus, iIdUsuario, cCorreo, cNsToken, cNumSucursal, iIdTipoUsuario
			FROM ((bdibei:"informix".bei_servicio bs left join bdibei:"informix".bei_usuario bu on bu.num_cliente = bs.num_cliente and bu.id_usuario = bs.id_usuario)
				LEFT JOIN bdibei:"informix".bei_datos_usuario bdu on bdu.id_usuario = bu.id_usuario)
				--LEFT JOIN bdibei:"informix".bei_token bt on bt.ns_token = bs.ns_token
				LEFT JOIN bdibei:"informix".bei_contratacion bt on bt.num_cliente = bs.num_cliente
			WHERE bs.num_cliente = cNumCte
			
			LET iNoRegs = iNoRegs + 1;
			
			RETURN cCodRet, cMensaje, pRfc, cEmpresa, cRazon_Social, cNumCte, cNombre1, cNombre2, cApPaterno, cApMaterno, cIdentificacion, 
				cTipoUsuario, cFolioActivacion, iIdUsuario, cCorreo, cNsToken, cNumSucursal, iIdTipoUsuario, iIdStatus WITH RESUME;

		END FOREACH;
		
		IF iNoRegs = 0 THEN
			LET cCodRet = '00035';
				CALL bdibpi:"informix".sp_soe_autenticacion_bpi(pUsuario, pIdFuncion, pRfc ) 
				RETURNING cCodRet, cMensaje, pRfc, cEmpresa, cRazon_Social, cNumCte, cNombre1, cNombre2, cApPaterno, cApMaterno, cIdentificacion, 
				cTipoUsuario, cFolioActivacion, iIdUsuario, cCorreo, cNsToken, cNumSucursal, iIdTipoUsuario, iIdStatus;
					
			RETURN cCodRet, cMensaje, pRfc, cEmpresa, cRazon_Social, cNumCte, cNombre1, cNombre2, cApPaterno, cApMaterno, cIdentificacion, 
				cTipoUsuario, cFolioActivacion, iIdUsuario, cCorreo, cNsToken, cNumSucursal, iIdTipoUsuario, iIdStatus;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 28/08/2013",
"DESCRIPCION: FunciÃ³n que realiza la autenticaciÃ³n del cliente por medio de su RFC para el mosulo de SOE en CNWEB";

CREATE PROCEDURE "informix".sp_consultarctepmempresanet_clon(pNumcte CHAR(20))

RETURNING
	CHAR(6) 		AS COD_RET,	
	CHAR(60)        AS RAZON_SOCIAL,
	CHAR(2)         AS TIPO_PERSONA,
	CHAR(12)        AS FOLIO_ACTIVA1,
	CHAR(12)        AS FOLIO_ACTIVA2,
	INTEGER 		AS FOL_CONTRATO1,
	INTEGER 		AS FOL_CONTRATO2,
    CHAR(30)        AS CODIGO_IDENTIF1,	
	CHAR(30)        AS CODIGO_IDENTIF2,
    CHAR(50)        AS IDENTIF_DESCRIPCION1,
    CHAR(50)        AS IDENTIF_DESCRIPCION2,
	CHAR(2)         AS NOIDENTIF_OFICIAL1,
	CHAR(2)         AS NOIDENTIF_OFICIAL2,
	SMALLINT        AS NUM_TOKENS,
	SMALLINT        AS NUM_ADMINISTRADORES,
	CHAR(50)        AS USUARIOAUT1_NOMBRE1,
	CHAR(50)        AS USUARIOAUT1_NOMBRE2,
	CHAR(50)        AS USUARIOAUT1_APELLPAT,
	CHAR(50)        AS USUARIOAUT1_APELLMAT,
	CHAR(50)        AS USUARIOAUT2_NOMBRE1,
	CHAR(50)        AS USUARIOAUT2_NOMBRE2,
	CHAR(50)        AS USUARIOAUT2_APELLPAT,
	CHAR(50)        AS USUARIOAUT2_APELLMAT,
	INTEGER         AS FOLIO_CONTRATOEMPNET;
	
	
	---DECLARACIONES
	DEFINE iSqlErr						INTEGER;    		
	DEFINE cCodRet         				CHAR(6);				
	DEFINE cNumcte         				CHAR(20);	
	DEFINE cEsFisica                    CHAR(1);
	DEFINE cTpoPersona                  CHAR(2);
	DEFINE sNumAdmon                    SMALLINT;
	DEFINE cFolioactiva  				CHAR(12);
	DEFINE cFolioActiva1                CHAR(12);
	DEFINE cFolioActiva2                CHAR(12);
	DEFINE iFolContrato1   				INTEGER;
	DEFINE iFolContrato2   				INTEGER;
	DEFINE cNumIdent					CHAR(2);
	DEFINE cCodIndentif                 CHAR(30);
	DEFINE cDescripcion                 CHAR(50);
	DEFINE cCodIndentifusu1             CHAR(30);
	DEFINE cCodIndentifusu2             CHAR(30);
	DEFINE cDescUsu1                    CHAR(50);
	DEFINE cDescUsu2                    CHAR(50);
	DEFINE cNumIdentUsuar1              CHAR(2);
	DEFINE cNumIdentUsuar2              CHAR(2);
	DEFINE sNumToken                    SMALLINT;
	DEFINE sFolio                       INTEGER;
	DEFINE cUsuarioAut1Nombre1          CHAR(50);
	DEFINE cUsuarioAut1Nombre2          CHAR(50);
    DEFINE cUsuarioAut1ApellPat         CHAR(50);
    DEFINE cUsuarioAut1ApellMat         CHAR(50);
    DEFINE cUsuarioAut2Nombre1          CHAR(50);
	DEFINE cUsuarioAut2Nombre2          CHAR(50);
    DEFINE cUsuarioAut2ApellPat         CHAR(50);
    DEFINE cUsuarioAut2ApellMat         CHAR(50);
	DEFINE cUsuAutNombre1               CHAR(50); 
	DEFINE cUsuAutNombre2               CHAR(50);
    DEFINE cUsuAutApellPat              CHAR(50);
    DEFINE cUsuAutApellMat              CHAR(50);
	DEFINE sEstatusCteEmpNet            SMALLINT;
	DEFINE cParamEstatusEmpNet          CHAR(2);
	DEFINE iFolioContratoEmpNet         INTEGER;
	DEFINE cRazonSocial                 CHAR(60);
	
	---INICIALIZACIONES
	LET iSqlErr						= 0;    		
	LET cCodRet         			= '000000';				
	LET cNumcte         			= '';
	LET cEsFisica                   = '';
	LET cTpoPersona                 = '';
	LET sNumAdmon                   = 0;
	LET iFolContrato1               = 0;
	LET iFolContrato2               = 0;
	LET cFolioactiva                = '';
	LET cFolioActiva1               = '';
	LET cFolioActiva2               = '';
	LET cNumIdent                   = '';
	LET cCodIndentif                = '';
	LET cDescripcion                = '';
	LET cCodIndentifusu1            = '';
	LET cCodIndentifusu2            = '';
	LET cDescUsu1                   = '';
	LET cDescUsu2                   = '';
	LET cNumIdentUsuar1             = '';
	LET cNumIdentUsuar2             = '';
	LET sNumToken                   = 0;	
	LET sFolio                      = 0;
	LET cUsuarioAut1Nombre1         = '';
	LET cUsuarioAut1Nombre2         = '';
    LET cUsuarioAut1ApellPat        = '';
    LET cUsuarioAut1ApellMat        = '';
    LET cUsuarioAut2Nombre1         = '';
	LET cUsuarioAut2Nombre2         = '';
    LET cUsuarioAut2ApellPat        = '';
    LET cUsuarioAut2ApellMat        = '';
	LET cUsuAutNombre1              = '';
	LET cUsuAutNombre2              = '';
    LET cUsuAutApellPat             = '';
    LET cUsuAutApellMat             = '';
	LET sEstatusCteEmpNet           = 0;
	LET cParamEstatusEmpNet         = '';
	LET iFolioContratoEmpNet        = 0;
	LET cRazonSocial                = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  RETURN 	cCodRet,TRIM(NVL(cRazonSocial, '')), TRIM(NVL(cTpoPersona,'')), TRIM(NVL(cFolioActiva1, '')),TRIM(NVL(cFolioActiva2, '')),
		                NVL(iFolContrato1, 0),NVL(iFolContrato2, 0),TRIM(NVL(cCodIndentifusu1,'')),TRIM(NVL(cCodIndentifusu2,'')),
						TRIM(NVL(cDescUsu1,'')),TRIM(NVL(cDescUsu2,'')),TRIM(NVL(cNumIdentUsuar1,'')),TRIM(NVL(cNumIdentUsuar2,'')),
						NVL(sNumToken,0), NVL(sNumAdmon,0), TRIM(NVL(cUsuarioAut1Nombre1, '')), TRIM(NVL(cUsuarioAut1Nombre2, '')), 
						TRIM(NVL(cUsuarioAut1ApellPat, '')),TRIM(NVL(cUsuarioAut1ApellMat, '')), TRIM(NVL(cUsuarioAut2Nombre1, '')), 
						TRIM(NVL(cUsuarioAut2Nombre2, '')), TRIM(NVL(cUsuarioAut2ApellPat, '')),TRIM(NVL(cUsuarioAut2ApellMat, '')),
						NVL(iFolioContratoEmpNet, 0); 
					
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarctepmempresanet_clon.out';
		--TRACE ON;
		
		IF TRIM(NVL(pNumcte,'')) = '' THEN
			LET cCodRet = '000001'; --PARÁMETRO VACIO
			
		 	RETURN  cCodRet,TRIM(NVL(cRazonSocial, '')), TRIM(NVL(cTpoPersona,'')), TRIM(NVL(cFolioActiva1, '')),TRIM(NVL(cFolioActiva2, '')),
		                NVL(iFolContrato1, 0),NVL(iFolContrato2, 0),TRIM(NVL(cCodIndentifusu1,'')),TRIM(NVL(cCodIndentifusu2,'')),
						TRIM(NVL(cDescUsu1,'')),TRIM(NVL(cDescUsu2,'')),TRIM(NVL(cNumIdentUsuar1,'')),TRIM(NVL(cNumIdentUsuar2,'')),
						NVL(sNumToken,0), NVL(sNumAdmon,0), TRIM(NVL(cUsuarioAut1Nombre1, '')), TRIM(NVL(cUsuarioAut1Nombre2, '')), 
						TRIM(NVL(cUsuarioAut1ApellPat, '')),TRIM(NVL(cUsuarioAut1ApellMat, '')), TRIM(NVL(cUsuarioAut2Nombre1, '')), 
						TRIM(NVL(cUsuarioAut2Nombre2, '')), TRIM(NVL(cUsuarioAut2ApellPat, '')),TRIM(NVL(cUsuarioAut2ApellMat, '')),
						NVL(iFolioContratoEmpNet, 0); 
		END IF;
		--SE CONSULTA EL TIPO PERSONA
		SELECT TRIM(NVL(tpo_persona, '')), TRIM(NVL(razon_social, ''))
		INTO cTpoPersona, cRazonSocial
		FROM bdinteg: "informix".si_cliente
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';
		
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
		   LET cCodRet = '000002'; --CONSULTA SIN RESULTADOS, AL CONSULTAR PARAMETRO INVÁLIDO
		   
		   RETURN 	cCodRet,TRIM(NVL(cRazonSocial, '')), TRIM(NVL(cTpoPersona,'')), TRIM(NVL(cFolioActiva1, '')),TRIM(NVL(cFolioActiva2, '')),
		                NVL(iFolContrato1, 0),NVL(iFolContrato2, 0),TRIM(NVL(cCodIndentifusu1,'')),TRIM(NVL(cCodIndentifusu2,'')),
						TRIM(NVL(cDescUsu1,'')),TRIM(NVL(cDescUsu2,'')),TRIM(NVL(cNumIdentUsuar1,'')),TRIM(NVL(cNumIdentUsuar2,'')),
						NVL(sNumToken,0), NVL(sNumAdmon,0), TRIM(NVL(cUsuarioAut1Nombre1, '')), TRIM(NVL(cUsuarioAut1Nombre2, '')), 
						TRIM(NVL(cUsuarioAut1ApellPat, '')),TRIM(NVL(cUsuarioAut1ApellMat, '')), TRIM(NVL(cUsuarioAut2Nombre1, '')), 
						TRIM(NVL(cUsuarioAut2Nombre2, '')), TRIM(NVL(cUsuarioAut2ApellPat, '')),TRIM(NVL(cUsuarioAut2ApellMat, '')),
						NVL(iFolioContratoEmpNet, 0); 
					
		END IF;
		
		--CONSULTA es_fisica OBTENIENDO 'S'= PERSONA FÍSICA, 'N'=PERSONA MORAL
		SELECT TRIM(NVL(es_fisica, ''))
		INTO cEsFisica
        FROM bdinteg: "informix".si_tipper
		WHERE tpo_persona = TRIM(cTpoPersona);
		
		IF cEsFisica = 'S' THEN
		   LET cCodRet = '000003'; --PERSONA FÍSICA
		   
		   RETURN cCodRet,TRIM(NVL(cRazonSocial, '')), TRIM(NVL(cTpoPersona,'')), TRIM(NVL(cFolioActiva1, '')),TRIM(NVL(cFolioActiva2, '')),
		                NVL(iFolContrato1, 0),NVL(iFolContrato2, 0),TRIM(NVL(cCodIndentifusu1,'')),TRIM(NVL(cCodIndentifusu2,'')),
						TRIM(NVL(cDescUsu1,'')),TRIM(NVL(cDescUsu2,'')),TRIM(NVL(cNumIdentUsuar1,'')),TRIM(NVL(cNumIdentUsuar2,'')),
						NVL(sNumToken,0), NVL(sNumAdmon,0), TRIM(NVL(cUsuarioAut1Nombre1, '')), TRIM(NVL(cUsuarioAut1Nombre2, '')), 
						TRIM(NVL(cUsuarioAut1ApellPat, '')),TRIM(NVL(cUsuarioAut1ApellMat, '')), TRIM(NVL(cUsuarioAut2Nombre1, '')), 
						TRIM(NVL(cUsuarioAut2Nombre2, '')), TRIM(NVL(cUsuarioAut2ApellPat, '')),TRIM(NVL(cUsuarioAut2ApellMat, '')),
						NVL(iFolioContratoEmpNet, 0); 
		   
		END IF;

		--CONSULTA EL ESTATUS DEL CLIENTE EN EMPRESANET
		
        SELECT NVL(status_contrato, 0), NVL(oper_no_token, 0), NVL(folio_contrato, 0)
		INTO sEstatusCteEmpNet, sNumToken, iFolioContratoEmpNet
		FROM "informix".bei_contratacion
		WHERE num_cliente = pNumcte
		AND folio_contrato = (SELECT MAX(folio_contrato) 
		                       FROM "informix".bei_contratacion 
							   WHERE num_cliente = pNumcte);
        
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
		   LET cCodRet = '000004'; --CONSULTA SIN RESULTADOS
		   
		   RETURN 	cCodRet,TRIM(NVL(cRazonSocial, '')), TRIM(NVL(cTpoPersona,'')), TRIM(NVL(cFolioActiva1, '')),TRIM(NVL(cFolioActiva2, '')),
		                NVL(iFolContrato1, 0),NVL(iFolContrato2, 0),TRIM(NVL(cCodIndentifusu1,'')),TRIM(NVL(cCodIndentifusu2,'')),
						TRIM(NVL(cDescUsu1,'')),TRIM(NVL(cDescUsu2,'')),TRIM(NVL(cNumIdentUsuar1,'')),TRIM(NVL(cNumIdentUsuar2,'')),
						NVL(sNumToken,0), NVL(sNumAdmon,0), TRIM(NVL(cUsuarioAut1Nombre1, '')), TRIM(NVL(cUsuarioAut1Nombre2, '')), 
						TRIM(NVL(cUsuarioAut1ApellPat, '')),TRIM(NVL(cUsuarioAut1ApellMat, '')), TRIM(NVL(cUsuarioAut2Nombre1, '')), 
						TRIM(NVL(cUsuarioAut2Nombre2, '')), TRIM(NVL(cUsuarioAut2ApellPat, '')),TRIM(NVL(cUsuarioAut2ApellMat, '')),
						NVL(iFolioContratoEmpNet, 0); 
					
		END IF;
		
		--CONSULTA EN LA TABLA si_param PARA OBTENER EL PARAMETRO DEL ESTATUS cParamEstatusEmpNet
		SELECT TRIM(NVL(valor,''))
		INTO cParamEstatusEmpNet
		FROM bdinteg: "informix".si_param
		WHERE cod_param = '303';
		
		
		--VALIDA QUE EL ESTATUS SEA 30 PARA CONSULTAR LOS DATOS DE ADMINISTRADOR/ES
		IF  sEstatusCteEmpNet = cParamEstatusEmpNet::INTEGER THEN
		
			FOREACH 
			
				--SE OBTIENE USUARIOS AUTORIZADOS, SU NUMERO DE IDENTIFICACION, FOLIO DE CONTRATO.
				SELECT NVL(a.folio_contrato, 0), TRIM(NVL(a.folio_activa, '')), TRIM(NVL(a.nombre1,'')),TRIM(NVL(a.nombre2,'')),TRIM(NVL(a.apell_paterno,'')),
				TRIM(NVL(a.apell_materno,'')),TRIM(NVL(a.codidentif, '')), TRIM(NVL(a.identificacion_admin,'')),TRIM(NVL(b.descripcion,''))
				INTO sFolio, cFolioactiva, cUsuAutNombre1, cUsuAutNombre2, cUsuAutApellPat, cUsuAutApellMat, cNumIdent, cCodIndentif, cDescripcion
				FROM "informix".bei_servicio a
				INNER JOIN bdinteg: "informix".si_tipoidentif b ON (b.codidentif = a.codidentif)
				WHERE num_cliente = pNumcte AND a.id_status <> '60'
				ORDER BY id_servicio				
			    
				
				LET sNumAdmon = sNumAdmon + 1; --LLEVA UN CONTEO PARA ASIGNAR ADMINISTRADOR 1 O 2.
				
				--SI NO EXISTE FOLIO DE CONTRATO Y EXISTE USUARIO ASIGNADO AUTORIZADO, FOLIO DE CONTRATO SERA = 'Sin Activar'
				IF TRIM(NVL(cFolioactiva,'')) = '' THEN
				   LET cFolioactiva = 'Sin Activar';  
				END IF;
					
				--DATOS PARA UN ADMINISTRADOR
				IF sNumAdmon = 1 THEN
					
					LET cUsuarioAut1Nombre1 = cUsuAutNombre1;
					
					LET cUsuarioAut1Nombre2 = cUsuAutNombre2;
					
					LET cUsuarioAut1ApellPat = cUsuAutApellPat;
					
					LET cUsuarioAut1ApellMat = cUsuAutApellMat;
					
					LET cFolioActiva1 = cFolioactiva;
					
					LET cCodIndentifusu1 = cCodIndentif;
					
					LET cDescUsu1 = cDescripcion;
					
					LET cNumIdentUsuar1 = cNumIdent;
					
					LET iFolContrato1 = sFolio;
					
								
			    ELIF sNumAdmon = 2 THEN --DATOS PARA UN SEGUNDO ADMINISTRADOR
				
					LET cUsuarioAut2Nombre1 = cUsuAutNombre1;
					
					LET cUsuarioAut2Nombre2 = cUsuAutNombre2;
					
					LET cUsuarioAut2ApellPat = cUsuAutApellPat;
					
					LET cUsuarioAut2ApellMat = cUsuAutApellMat;
					
					LET cFolioActiva2 = cFolioactiva;
					
					LET cCodIndentifusu2 = cCodIndentif;
					
					LET cDescUsu2 = cDescripcion;
					
					LET cNumIdentUsuar2 = cNumIdent;
					
					LET iFolContrato2 = sFolio;
				 ELSE
					LET cCodRet = '000005'; --NUM INVALIDO DE ADMINISTRADORES
				 END IF;	
				
			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
		            LET cCodRet = '000006'; --CONSULTA SIN RESULTADOS
			END IF;
			
		ELSE
			FOREACH 
			
				--SE OBTIENE USUARIOS AUTORIZADOS, SU NUMERO DE IDENTIFICACION, FOLIO DE CONTRATO.
				SELECT NVL(a.folio_contrato, 0), TRIM(NVL(a.folio_activa, '')), TRIM(NVL(a.nombre1,'')),TRIM(NVL(a.nombre2,'')),TRIM(NVL(a.apell_paterno,'')),
				TRIM(NVL(a.apell_materno,'')),TRIM(NVL(a.codidentif, '')), TRIM(NVL(a.identificacion_admin,'')),TRIM(NVL(b.descripcion,''))
				INTO sFolio, cFolioactiva, cUsuAutNombre1, cUsuAutNombre2, cUsuAutApellPat, cUsuAutApellMat, cNumIdent, cCodIndentif, cDescripcion
				FROM "informix".bei_servicio a
				INNER JOIN bdinteg: "informix".si_tipoidentif b ON (b.codidentif = a.codidentif)
				WHERE num_cliente = pNumcte AND a.id_status <> '60'
				ORDER BY id_servicio				
			    
				
				LET sNumAdmon = sNumAdmon + 1; --LLEVA UN CONTEO PARA ASIGNAR ADMINISTRADOR 1 O 2.
				
				--SI NO EXISTE FOLIO DE CONTRATO Y EXISTE USUARIO ASIGNADO AUTORIZADO, FOLIO DE CONTRATO SERA = 'Sin Activar'
				IF TRIM(NVL(cFolioactiva,'')) = '' THEN
				   LET cFolioactiva = 'Sin Activar';  
				END IF;
					
				--DATOS PARA UN ADMINISTRADOR
				IF sNumAdmon = 1 THEN
					
					LET cUsuarioAut1Nombre1 = cUsuAutNombre1;
					
					LET cUsuarioAut1Nombre2 = cUsuAutNombre2;
					
					LET cUsuarioAut1ApellPat = cUsuAutApellPat;
					
					LET cUsuarioAut1ApellMat = cUsuAutApellMat;
					
					LET cFolioActiva1 = cFolioactiva;
					
					LET cCodIndentifusu1 = cCodIndentif;
					
					LET cDescUsu1 = cDescripcion;
					
					LET cNumIdentUsuar1 = cNumIdent;
					
					LET iFolContrato1 = sFolio;
					
								
			    ELIF sNumAdmon = 2 THEN --DATOS PARA UN SEGUNDO ADMINISTRADOR
				
					LET cUsuarioAut2Nombre1 = cUsuAutNombre1;
					
					LET cUsuarioAut2Nombre2 = cUsuAutNombre2;
					
					LET cUsuarioAut2ApellPat = cUsuAutApellPat;
					
					LET cUsuarioAut2ApellMat = cUsuAutApellMat;
					
					LET cFolioActiva2 = cFolioactiva;
					
					LET cCodIndentifusu2 = cCodIndentif;
					
					LET cDescUsu2 = cDescripcion;
					
					LET cNumIdentUsuar2 = cNumIdent;
					
					LET iFolContrato2 = sFolio;
				ELSE
					LET cCodRet = '000005'; --NUM INVALIDO DE ADMINISTRADORES
				END IF;	
				
			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
		            LET cCodRet = '000006'; --CONSULTA SIN RESULTADOS
			END IF;
		END IF; 
		
		--SE RETORNA INFORMACION.
		RETURN 	cCodRet,TRIM(NVL(cRazonSocial, '')), TRIM(NVL(cTpoPersona,'')), TRIM(NVL(cFolioActiva1, '')),TRIM(NVL(cFolioActiva2, '')),
		                NVL(iFolContrato1, 0),NVL(iFolContrato2, 0),TRIM(NVL(cCodIndentifusu1,'')),TRIM(NVL(cCodIndentifusu2,'')),
						TRIM(NVL(cDescUsu1,'')),TRIM(NVL(cDescUsu2,'')),TRIM(NVL(cNumIdentUsuar1,'')),TRIM(NVL(cNumIdentUsuar2,'')),
						NVL(sNumToken,0), NVL(sNumAdmon,0), TRIM(NVL(cUsuarioAut1Nombre1, '')), TRIM(NVL(cUsuarioAut1Nombre2, '')), 
						TRIM(NVL(cUsuarioAut1ApellPat, '')),TRIM(NVL(cUsuarioAut1ApellMat, '')), TRIM(NVL(cUsuarioAut2Nombre1, '')), 
						TRIM(NVL(cUsuarioAut2Nombre2, '')), TRIM(NVL(cUsuarioAut2ApellPat, '')),TRIM(NVL(cUsuarioAut2ApellMat, '')),
						NVL(iFolioContratoEmpNet, 0); 	
	END;
END PROCEDURE 
DOCUMENT
'DESCRIPCION: Se clona procedimiento almacenado',
'AUTOR:  Veronica Sanchez Tlacomulco',   
'FECHA DE CREACION: 08/07/2022',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_mod_senet_altaservicioempresanet(pNumCte CHAR(20), pUsuario CHAR(8), pNoTokens smallint)

	RETURNING CHAR(5) AS cCodRet;

	
    -- DEFINICIONES
    DEFINE iSql_Err         INTEGER;
    DEFINE cCodRet          CHAR(5);
    DEFINE sSecuencia       SMALLINT;
    DEFINE cSolicitud       CHAR(10);
    DEFINE cFolioSucursal   CHAR(16);
    DEFINE cRandon1         CHAR(6);
    DEFINE cRandon2         CHAR(2);
    DEFINE cRepLegal		CHAR(104);
	DEFINE vTotal_admin		SMALLINT;
	DEFINE vNoTokens_oper	SMALLINT;
	DEFINE dMonto			DECIMAL(12,2);
	DEFINE cEstatus 		SMALLINT;
	
    -- INICIALIZACIONES
    LET iSql_Err           	= 0;
    LET cCodRet           	= '000000';
    LET sSecuencia        	= 0;
    LET cSolicitud        	= '';
    LET cFolioSucursal    	= '';
    LET cRandon1          	= '';
    LET cRandon2         	= '';
	LET cRepLegal			= '';
	LET vTotal_admin		= 0;
   	LET vNoTokens_oper		= 0;
	LET dMonto				= 0.00;
	LET cEstatus			= 0;

    BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        RETURN cCodRet;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_senet_altaservicioempresanet.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Valida los parametros de entrada.
	IF NVL(pNumCte,'') = '' OR NVL(pUsuario,'') = '' OR NVL(pNoTokens,0) = 0 THEN
        LET cCodRet = '00001';
        RETURN cCodRet;
    END IF;

	--validamos que el número de tokens sea correcto
	IF pNoTokens < 2 OR pNoTokens > 10 THEN
	    LET cCodRet = '00002';
        RETURN cCodRet;
	END IF;	
	
	---------------------------------------------------------------------------------------------------------------------------------
	--Se resta al total de tokens la cantidad de administradores -------------------------------------------
	--Consulta el numero de administradores---
	SELECT COUNT(num_cliente) 
	INTO vTotal_admin
	FROM bdibei:bei_servicio 
	WHERE num_cliente=pNumCte;
	--Actualiza el parametros de total de tokens para operadores--
	LET vNoTokens_oper = pNoTokens - vTotal_admin;
	
	SELECT status_contrato
	INTO cEstatus
	FROM bdibei:"informix".bei_contratacion
	WHERE num_cliente = pNumCte;
	
	-- Actualizacion solicitud de token 
	UPDATE bdibei:"informix".bei_contratacion SET oper_no_token = vNoTokens_oper, rep_legal = cRepLegal, f_registro = TODAY, num_empleado = pUsuario, 
	fecha_movto = CURRENT, usuario_atiende = pUsuario, status_contrato = (CASE cEstatus WHEN 99 THEN 30 ELSE status_contrato END) 
	WHERE num_cliente = pNumCte;
	
	-- Consultamos la maxima secuencia del domicilio del cliente.
    SELECT secuencia 
      INTO sSecuencia
      FROM bdinteg:"informix".si_direcciones_actual 
     WHERE numcte = pNumCte
       AND tipo_dir = 1;

    IF sSecuencia IS NULL THEN
        SELECT MAX(secuencia) 
          INTO sSecuencia 
          FROM bdinteg:"informix".si_direcciones
         WHERE numcte = pNumCte
           AND tipo_dir = 1;
    END IF

    -- Consulta el maximo regitro + 1
    SELECT (NVL(MAX(solicitud),'0')::INTEGER + 1) 
      INTO cSolicitud
      FROM bdibei:"informix".bei_solicitudtoken;

    IF cSolicitud IS NULL THEN
        LET cSolicitud = '1';
    END IF;

    LET cSolicitud = LPAD(TRIM(cSolicitud), 10, '0');	
	
    -- Consultamos la hora para generar el folio.
    SELECT SUBSTR(DBINFO('utc_to_datetime', sh_curtime),12,2) || SUBSTR(DBINFO('utc_to_datetime', sh_curtime),15,2) || SUBSTR(DBINFO('utc_to_datetime', sh_curtime),18,2)
      INTO cRandon1
      FROM sysmaster:sysshmvals;

    -- Generamos un Randon para completar el valor del folio.
    EXECUTE PROCEDURE bdicheq:"informix".sp_random()
    INTO cRandon2;

    LET cFolioSucursal = 'SINCOMIS'||cRandon1||LPAD(TRIM(cRandon2), 2, '0');
	
    UPDATE bdibei:"informix".bei_solicitudtoken SET solicitud = cSolicitud, id_status = '100', unidades = pNoTokens, 
	folio_suc = cFolioSucursal, usr_solicita = pUsuario, sec_domicilio = sSecuencia, f_solicitud = CURRENT
	WHERE numcte = pNumCte;

	INSERT INTO bdibei:"informix".bei_stasolicitud (solicitud, anterior, actual, f_registro)
	VALUES (cSolicitud, '100', '100', CURRENT);
	
	-- Obtiene datos faltantes para el registro de conciliación	
	IF TRIM(SUBSTR(cFolioSucursal,1,8)) = 'SINCOMIS' THEN
		LET dMonto = 0.00;
	END IF;
	
	-- Inserta el registro de conciliación
	UPDATE bdibpi: "informix".tkn_solcobranza SET solicitud = cSolicitud, id_status = '100', f_solicitud = CURRENT, folio_suc = cFolioSucursal, 
	f_cobro = dMonto
	WHERE Numcte = pNumCte;
	
	INSERT INTO bdicnweb:"informix".sw_regbitacora_empresanet (usuario_insert, num_cliente, operacion, fecha) 
	VALUES (pUsuario, pNumCte, 'MODIFICACION ADMO.', CURRENT);
	
    RETURN cCodRet;

 END;    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se desarrollo SP para realizar la actualización de información del Servicio de Empresa NET',
'AUTOR:  Veronica Sanchez Tlacomulco',   
'FECHA DE CREACION: 08/07/2022',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_consulta_dynatrace ()
RETURNING CHAR(5);
    DEFINE codRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE fechaMonitoreo CHAR(50);

    LET codRet = '00000';
    LET viSqlErr = 0;
    LET fechaMonitoreo = CURRENT;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION SET viSqlErr
            IF viSqlErr <> 0 then
                LET codRet = viSqlErr;
                RETURN codRet;
            END IF;	
        END EXCEPTION;


        SELECT fecha INTO fechaMonitoreo FROM bdibei:"informix".bei_monitoreo_dynatrace;
        IF fechaMonitoreo  <> '' AND fechaMonitoreo <> 'NULL' THEN
            UPDATE bdibei:"informix".bei_monitoreo_dynatrace SET fecha = CURRENT;
        ELSE
            INSERT INTO bdibei:"informix".bei_monitoreo_dynatrace(fecha)
            VALUES(CURRENT);
        END IF;


        RETURN codRet;
    END;
END PROCEDURE
;