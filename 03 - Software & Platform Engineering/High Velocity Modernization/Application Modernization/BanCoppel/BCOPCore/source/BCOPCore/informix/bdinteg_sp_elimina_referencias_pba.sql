CREATE PROCEDURE "informix".sp_elimina_referencias_pba(pEmpresa CHAR(3),
														pNumSolicitudActualbco CHAR(20) ,
														pNumcte CHAR(20),
														pNumSolicitudActualcpl CHAR(20)
														)

--RETORNOS-
RETURNING
CHAR(6)  AS codigo_ret;

--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(6);
DEFINE iSql_err				    INTEGER; 
DEFINE iIsamErr                 INTEGER;
DEFINE iBandera                 INTEGER;
DEFINE iBandera1                 INTEGER;
DEFINE sSecuencia               INTEGER;


--INICIALIZACION DE VARIABLES--
LET cCodret                 = '000000'; --EJECUCION EXITOSA
LET iIsamErr                = 0;
LET iSql_err                = 0; 
LET iBandera                = 0;
LET iBandera1                = 0;
LET sSecuencia				= 0;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret);
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/home/sysifx/Lerma/sp_elimina_referencias_debug.sql';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	 
	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSolicitudActualbco,'')= '' OR  NVL(pNumcte, '') = ''   THEN
		LET cCodret = '000001'; 
		RETURN TRIM(cCodret);
	 END IF;
	 
	 DELETE FROM bdisolic:"informix".ss_refpersonales where  num_solicitud in (pNumSolicitudActualbco, pNumSolicitudActualcpl);
	
	 SELECT COUNT(*) 
	 INTO iBandera
	 FROM bdinteg:"informix".si_refclientes 
	 WHERE numcte = pNumcte 
	 AND num_solicitud = pNumSolicitudActualbco
	 AND empresa = pEmpresa;
	 
	 SELECT COUNT(*) 
	 INTO iBandera1
	 FROM bdinteg:"informix".si_refclientes 
	 WHERE numcte = pNumcte 
	 AND num_solicitud = pNumSolicitudActualcpl
	 AND empresa = pEmpresa;
	 
	  
	If iBandera > 0 THEN	
		
		FOREACH
		
			SELECT secuencia
			INTO sSecuencia
			FROM bdinteg:"informix".si_refclientes 
			WHERE numcte = pNumcte 
			AND num_solicitud = pNumSolicitudActualbco
		
			DELETE FROM bdinteg:"informix".si_refdirecciones WHERE numcte = pNumcte and secuencia = sSecuencia;
			DELETE FROM bdinteg:"informix".si_refclientes WHERE empresa = pEmpresa AND numcte = pNumcte AND secuencia = sSecuencia;
		
		END FOREACH;
	
	ELIF iBandera1 > 0 THEN	
		
		FOREACH
		
			SELECT {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} secuencia
			INTO sSecuencia
			FROM bdinteg:"informix".si_refclientes 
			WHERE numcte = pNumcte 
			AND num_solicitud = pNumSolicitudActualcpl
		
			DELETE FROM bdinteg:"informix".si_refdirecciones WHERE numcte = pNumcte and secuencia = sSecuencia;
			DELETE FROM bdinteg:"informix".si_refclientes WHERE empresa = pEmpresa AND numcte = pNumcte AND sSecuencia = sSecuencia;
		
	
		END FOREACH;
		
	ELSE
		LET cCodret = '000002';  
	END IF;
	
	RETURN TRIM(cCodret) ;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃN: PROCEDIMIENTO PARA OBTENER LA SOLICITUD, VALIDA PARA HEREDAR LA INFORMACION A LA SOLICITUD NUEVA',
'FECHA DE CREACIÃN: 12 DE JULIO DE 2013',
'BASE DE DATOS: BDISOLIC',
'CREADOR: JESUS AGUILAR',
'VERSION: 201307121100';

CREATE PROCEDURE "informix".sp_ws_inyeccion_au(
 pUserName CHAR(8),
 pUserPass CHAR(8),
 pSessionId CHAR(80),
 pIpOrigen CHAR(15),
 pAgentTransTypeCode CHAR(10),
 pAgentCd CHAR(3),
 pProductos CHAR(200),
 pNumCliente CHAR(20),
 pPrimerNombre CHAR(26),
 pSegundoNombre CHAR(26),
 pPrimerApellido CHAR(26),
 pSegundoApellido CHAR(26),
 pGenero CHAR(1),
 pFechNac CHAR(10),
 pRfc CHAR(13),
 pCorreo CHAR(100),
 pTelCasa CHAR(10),
 pTelCel CHAR(10),
 pCarrier CHAR(1),
 pPais CHAR(3),
 pCodPostal CHAR(5),
 pEstado CHAR(2),
 pCiudad CHAR(3),
 pColonia CHAR(10),
 pDeleMcpo CHAR(5),
 pCalle CHAR(10),
 pNumExterior CHAR(10),
 pNumInterior CHAR(10),
 pEntreCalles CHAR(40),
 pComplemento CHAR(80),
 pTarjetaActiva CHAR(1),
 pUltCuatroDigi CHAR(4),
 pCredHipote CHAR(1),
 pCredAutom CHAR(1),
 pAutoBuro CHAR(1),
 pEscolaridad CHAR(2),
 pEdoCivil CHAR(1),
 pTpoEdoCivilA CHAR(2),
 pTpoEdoCivilM CHAR(2),
 pTipoVivienda CHAR(1),
 pTpoDomActual CHAR(2),
 pNumHabitantes CHAR(2),
 pPerTrabajan CHAR(2),
 pPerDepen CHAR(2),
 pEmpresa CHAR(60),
 pTpoEmpActual CHAR(2),
 pTpoEmpAnte CHAR(2),
 pActividad CHAR(2),
 pSubactividad CHAR(2),
 pIngreso CHAR(8),
 pTelOficina CHAR(10),
 pPrimerNombreRef CHAR(26),
 pSegundoNombreRef CHAR(26),
 pPrimerApellRef CHAR(26),
 pSegundoApellRef CHAR(26),
 pFechNacRef CHAR(10),
 pGeneroRef CHAR(1),
 pParentescoRef CHAR(2),
 pTelCelRef CHAR(10),
 pEjecutivo CHAR(8),
 pNumeroControl CHAR (25)
)
RETURNING 
CHAR(4)    AS codRet,
CHAR(120)  AS mensajeResp,
CHAR(2)    AS estatusSolBcpl,
CHAR(40)   AS descEstatusBcpl,
CHAR(255)  AS motivoRechazoBcpl,
CHAR(4)    AS claveProductoBcpl,
CHAR(20)   AS folioSolicitudBcpl,
CHAR(2)    AS estatusSolCpl,
CHAR(40)   AS descEstatusCpl,
CHAR(255)  AS causaSituacionCpl,
CHAR(4)    AS claveProducto,
CHAR(20)   AS folioSolicitudCpl;
         
DEFINE sql_err INTEGER;
DEFINE codRet CHAR(4);
DEFINE mensajeResp CHAR(120);
DEFINE estatusSolBcpl CHAR(2);
DEFINE descEstatusBcpl CHAR(40);
DEFINE motivoRechazoBcpl CHAR(255);
DEFINE claveProductoBcpl CHAR(4);
DEFINE folioSolicitudBcpl CHAR(20);
DEFINE estatusSolCpl CHAR(2);
DEFINE descEstatusCpl CHAR(40);
DEFINE causaSituacionCpl CHAR(255);
DEFINE claveProducto CHAR(4);
DEFINE folioSolicitudCpl CHAR(20);
DEFINE tipoCliente CHAR(1);

LET codRet = '0000';
LET mensajeResp = '';
LET estatusSolBcpl = '';
LET descEstatusBcpl = '';
LET motivoRechazoBcpl = '';
LET claveProductoBcpl = '';
LET folioSolicitudBcpl = '';
LET estatusSolCpl = '';
LET descEstatusCpl = '';
LET causaSituacionCpl = '';
LET claveProducto = '';
LET folioSolicitudCpl = '';
LET tipoCliente = '';
		 

    BEGIN
 
    ON EXCEPTION SET sql_err

		IF sql_err <> 0 THEN
				LET codRet = REPLACE(sql_err,'-','');
				LET mensajeResp = 'Error en base de datos.';
				
				RETURN codRet, mensajeResp, estatusSolBcpl, descEstatusBcpl, motivoRechazoBcpl, claveProductoBcpl, folioSolicitudBcpl, estatusSolCpl, descEstatusCpl, causaSituacionCpl, claveProducto, folioSolicitudCpl;
		END IF;

    END EXCEPTION;

	 --SET DEBUG FILE TO "/tmp/sp_ws_inyeccion_au.out";
	 --TRACE ON;
 
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(TRIM(pUserName),'') <> '' AND NVL(TRIM(pUserPass),'') <> '' AND NVL(TRIM(pSessionId),'') <> '' AND NVL(TRIM(pIpOrigen),'') <> '' AND NVL(TRIM(pAgentTransTypeCode),'') <> '' AND NVL(TRIM(pAgentCd),'') <> ''
	   AND NVL(TRIM(pProductos),'') <> '' AND NVL(TRIM(pNumCliente),'') <> '' AND NVL(TRIM(pPrimerNombre),'') <> '' AND NVL(TRIM(pPrimerApellido),'') <> '' AND NVL(TRIM(pGenero),'') <> '' AND NVL(TRIM(pFechNac),'') <> ''
	   AND NVL(TRIM(pRfc),'') <> '' AND NVL(TRIM(pCorreo),'') <> '' AND NVL(TRIM(pTelCel),'') <> '' AND NVL(TRIM(pCarrier),'') <> '' AND NVL(TRIM(pPais),'') <> '' 
	   AND NVL(TRIM(pCodPostal),'') <> '' AND NVL(TRIM(pEstado),'') <> '' AND NVL(TRIM(pCiudad),'') <> '' AND NVL(TRIM(pColonia),'') <> '' AND NVL(TRIM(pDeleMcpo),'') <> '' AND NVL(TRIM(pCalle),'') <> ''
	   AND NVL(TRIM(pNumExterior),'') <> '' AND NVL(TRIM(pTarjetaActiva),'') <> '' AND NVL(TRIM(pUltCuatroDigi),'') <> '' AND NVL(TRIM(pCredHipote),'') <> '' AND NVL(TRIM(pCredAutom),'') <> '' 
	   AND NVL(TRIM(pAutoBuro),'') <> '' AND NVL(TRIM(pEscolaridad),'') <> '' AND NVL(TRIM(pEdoCivil),'') <> '' AND NVL(TRIM(pTpoEdoCivilA),'') <> '' --AND NVL(TRIM(pTpoEdoCivilM),'') <> ''
	   AND NVL(TRIM(pTipoVivienda),'') <> '' AND NVL(TRIM(pTpoDomActual),'') <> '' AND NVL(TRIM(pNumHabitantes),'') <> '' AND NVL(TRIM(pPerTrabajan),'') <> '' AND NVL(TRIM(pPerDepen),'') <> '' 
	   AND NVL(TRIM(pTpoEmpActual),'') <> '' AND NVL(TRIM(pTpoEmpAnte),'') <> '' AND NVL(TRIM(pActividad),'') <> '' AND NVL(TRIM(pSubactividad),'') <> '' AND NVL(TRIM(pIngreso),'') <> '' AND NVL(TRIM(pPrimerNombreRef),'') <> ''
	   AND NVL(TRIM(pPrimerApellRef),'') <> '' AND NVL(TRIM(pFechNacRef),'') <> '' AND NVL(TRIM(pGeneroRef),'') <> '' AND NVL(TRIM(pParentescoRef),'') <> '' AND NVL(TRIM(pTelCelRef),'') <> '' AND NVL(TRIM(pEjecutivo),'') <> '' THEN
	
		EXECUTE PROCEDURE  bdisac:"informix".sp_valida_session(TRIM(pAgentTransTypeCode), TRIM(pAgentCd), TRIM(pUserName), TRIM(pUserPass), TRIM(pIpOrigen), TRIM(pSessionId) ) INTO codRet, mensajeResp;
		
		IF TRIM(codRet) = '0000' THEN 
	
			SELECT NVL(tipo_cliente,'') INTO estatusSolBcpl FROM bdinteg:si_cliente where numcte = TRIM(pNumCliente);
	
		END IF;		
	ELSE	
		LET codRet= "9996";
		LET mensajeResp = "Uno de los parÃÂ¡metros de seguridad viene vacÃÂ­o";
	END IF;
	
 RETURN codRet, mensajeResp, estatusSolBcpl, descEstatusBcpl, motivoRechazoBcpl, claveProductoBcpl, folioSolicitudBcpl, estatusSolCpl, descEstatusCpl, causaSituacionCpl, claveProducto, folioSolicitudCpl;
 
END;
END PROCEDURE;