CREATE PROCEDURE "informix".sp_gs_consultasolicitudusuarioarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdAreaUsuario INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				INTEGER AS id_area_solicitud,
				CHAR(2) AS sistema_suenta,
				CHAR(30) AS desc_sistema_cuenta,
				INTEGER AS id_solicitud,
				CHAR(50) AS desc_solicitud,
				CHAR(1) AS ind_responsable,
				CHAR(1) AS ind_solicitante;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdAreaSolicitud INTEGER;
	DEFINE cSistemaCuenta CHAR(2);
	DEFINE cDescSistemaCuenta CHAR(30);
	DEFINE iIdSolicitud INTEGER;
	DEFINE cDescSolicitud CHAR(50);
	DEFINE cIndResponsable CHAR(1);
	DEFINE cIndSolicitante CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iIdAreaSolicitud = 0;
	LET cSistemaCuenta = '';
	LET cDescSistemaCuenta = '';
	LET iIdSolicitud = '';
	LET cDescSolicitud = '';
	LET cIndResponsable = '';
	LET cIndSolicitante = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gs_consultasolicitudusuarioarea.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdAreaUsuario IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion a.id_area_solicitud, c.id_sistema_cuenta, c.descripcion_sistema_cuenta, b.id_solicitud, b.descripcion_solicitud,
				DECODE(a.ind_responsable, 'f', '0', 't', '1', '0') as es_responsable, DECODE(a.ind_solicitante, 'f', '0', 't', '1', '0') as es_solicitante
			INTO iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante
			FROM "informix".sw_gs_area_solicitudes a, "informix".sw_gs_solicitudes b, "informix".sw_gs_sistema_cuenta c
			WHERE id_area_usuario = pIdAreaUsuario and a.status = 't'
				AND b.id_solicitud = a.id_solicitud
				AND c.id_sistema_cuenta = b.id_sistema_cuenta
			
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante WITH RESUME;			
			LET iNoRegistros = iNoRegistros + 1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdAreaSolicitud, cSistemaCuenta, cDescSistemaCuenta, iIdSolicitud, cDescSolicitud, cIndResponsable, cIndSolicitante;
		END IF;

	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 19/05/2014',
'DESCRIPCION: Consulta el detalle de area/solicitud asiganada a un usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_gs_grabarusuarioarea(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion SMALLINT, pIdx INTEGER, pIdUsuarioC CHAR(8), pIdArea INTEGER, pJefeArea CHAR(1), pStatus CHAR(1), pIpUsuario CHAR(15), pMacUsuario CHAR(12))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS registro_afectados;
				  
	DEFINE cCodRet CHAR(5);
	DEFINE registro_afectados INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE iIdx INTEGER;
	
	LET cCodRet = '00000';
	LET registro_afectados = 0;
	LET iSqlErr = 0;
	LET iIdx = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, registro_afectados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_sw_gs_area_usuario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoOperacion IS NULL OR pIdUsuarioC = '' OR pIdArea IS NULL OR pJefeArea = '' OR pStatus = '' OR pIpUsuario = '' OR pMacUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, registro_afectados; 
		END IF;
		
		IF pTipoOperacion NOT IN (1, 2) THEN
			LET cCodRet = '00148';
			RETURN cCodRet, registro_afectados; 
		END IF;
		
		IF pTipoOperacion = 2 AND pIdx IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, registro_afectados; 
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, registro_afectados;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		IF pTipoOperacion = 1 THEN
			IF EXISTS (SELECT id_area FROM bdicnweb:"informix".sw_gs_area_usuario WHERE id_usuario = pIdUsuarioC) THEN
				LET cCodRet = '00004';
				RETURN cCodRet, registro_afectados;
			ELSE
				INSERT INTO bdicnweb:"informix".sw_gs_area_usuario(id_usuario, id_area, jefe_area, status, user_insert, ip_insert, mac_insert)
				VALUES(pIdUsuarioC, pIdArea, DECODE(pJefeArea, '0', 'f', '1', 't', 'f'), DECODE(pStatus, '0', 'f', '1', 't', 'f'), pUsuario, pIpUsuario, pMacUsuario);
				
				LET registro_afectados = DBINFO('sqlca.sqlerrd2');
				IF registro_afectados = 1 THEN
					LET iIdx = DBINFO('sqlca.sqlerrd1');
				END IF;
				
				RETURN cCodRet, iIdx;

			END IF;
		END IF;
		
		IF pTipoOperacion = 2 THEN
		
			IF NOT EXISTS (SELECT id_area_usuario FROM bdicnweb:"informix".sw_gs_area_usuario WHERE id_area_usuario = pIdx) THEN
				LET cCodRet = '00001';
				RETURN cCodRet, registro_afectados;
			ELSE
				UPDATE bdicnweb:"informix".sw_gs_area_usuario
				SET id_usuario = pIdUsuarioC, 
					id_area = pIdArea, 
					jefe_area = DECODE(pJefeArea, '0', 'f', '1', 't', 'f'),
					status = DECODE(pStatus, '0', 'f', '1', 't', 'f'),
					user_update= pUsuario,
					ip_update= pIpUsuario,
					mac_update = pMacUsuario
				WHERE id_area_usuario = pIdx;
				--WHERE id_usuario = pIdUsuarioC 
				--  AND id_area = pIdArea;	
				
				LET registro_afectados = DBINFO('sqlca.sqlerrd2');
				RETURN cCodRet, registro_afectados;
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 16/05/2014',
'DESCRIPCION: inserta o actualiza el area de usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_evc_borra_repetidosexcluir(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10))

RETURNING CHAR(5) AS codret;
-- Control de Cambios
-----------------------------------------------------------------------------------
----Faviola Martinez
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE vStatusSol       CHAR(2);
DEFINE vHoy             DATE;
define dFechaEnt        DATE;
DEFINE vCausaSol        CHAR(3);
DEFINE P_COD_RET   VARCHAR(5);
DEFINE cNumcte   CHAR(20);
DEFINE cCodRet   CHAR(6);
DEFINE cMensajeRet   CHAR(100);
DEFINE iValido   INTEGER;
DEFINE cSucursal   CHAR(4);
DEFINE cNumProd   CHAR(4);
DEFINE vRegistro   DECIMAL(18,2);
DEFINE vMensajeStatus         CHAR(80);
DEFINE iSqlErr INT;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vStatusSol  = "??";
LET vHoy  = DATE(1);
LET dFechaEnt  =  DATE(1);
LET vCausaSol   = "";
LET P_COD_RET   = "";
LET cNumcte   = "";
LET cCodRet   = "00000";
LET cMensajeRet   = "";
LET iValido   = 0;
LET cSucursal   = "";
LET cNumProd   = "";
LET vRegistro   = 0;
LET vMensajeStatus="";
LET iSqlErr = 0;

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

	EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;

	IF trim(cCodRet) <> "00000" THEN
		RETURN trim(cCodRet);
	END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

----SET DEBUG FILE TO "/informix/marcov/sp_evc_borra_repetidosexcluir.out";
----TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
	IF (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)} 
		COUNT(*)
		from bdicnweb:"informix".sw_evc_excluidos
		where id_registro 
		not in (select {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_cuenta)}  max(id_registro)
						from bdicnweb:"informix".sw_evc_excluidos group by cuenta) 
		and status <> 'P')
		>= 1 THEN

		DELETE {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_status)}
		FROM bdicnweb:"informix".sw_evc_excluidos
		WHERE id_registro
		NOT IN(SELECT {+INDEX (bdicnweb:sw_evc_excluidos idx_evc_cuenta)} MAX(id_registro)
						FROM bdicnweb:"informix".sw_evc_excluidos GROUP BY cuenta)
		AND status <> 'P';
	END IF;
 
RETURN trim(cCodRet);
END;
 
END PROCEDURE;