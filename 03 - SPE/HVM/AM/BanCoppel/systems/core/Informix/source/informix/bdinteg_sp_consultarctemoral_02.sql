CREATE PROCEDURE "informix".sp_consultarctemoral_02(pNumcte CHAR(20))


	RETURNING
	CHAR(6) 		AS COD_RET,
	CHAR(13) 		AS RFC,
	CHAR(26) 		AS APELL_PATER_REP_LEG,
	CHAR(26) 		AS APELL_MATER_REP_LEG,
	CHAR(26) 		AS NOMB1_REP_LEG,
	CHAR(26) 		AS NOMB2_REP_LEG,
	CHAR(40)   		AS CALLE_FISCAL,
	CHAR(10)   		AS NUM_EXT_CALLE_FISCAL,
	CHAR(60)   		AS COL_FISCAL,
	VARCHAR(60,1)  	AS NOM_CIUD_FISCAL,
	CHAR(3)   		AS COD_MUN_FISCAL,
	CHAR(30)    	AS NOM_ESTADO_FISCAL,
	CHAR(20) 		AS NUM_CTE,
	CHAR(30) 		AS NOM_CORTO,
	CHAR(30) 		AS PAG_INTERNET,
	CHAR(25) 		AS SAT_FEA,
	CHAR(15) 		AS TEL_CONTACTO,
	CHAR(20) 		AS GIRO,
	CHAR(40) 		AS NOM_GIRO,
	CHAR(3)         AS ACTIVIDAD_SOC,
	CHAR(30) 		AS DES_ACT_OBJ,
	CHAR(2) 		AS RESP_STATUS,
	CHAR(26) 		AS APELL_PATER_FIRMANTES,
	CHAR(26) 		AS APELL_MATER_FIRMANTES,
	CHAR(26) 		AS NOMB1_FIRMANTES,
	CHAR(26) 		AS NOMB2_FIRMANTES,
	CHAR(20)        AS DES_PODER,
	CHAR(20)        AS DES_ADMIN,
	CHAR(40)        AS DES_ORG,
	DATE            AS FECHA_INS,
	DATE            AS FECHA_CONS,
	CHAR(3)         AS NACIONALIDAD,
	CHAR(15)        AS DESC_NACIONALIDAD,
	CHAR(48)        AS NOMBRE_CONTACTO,
	CHAR(2)         AS SUFIJO,
	CHAR(60)        AS DES_SUFIJO,
	CHAR(30)        AS ESCRITURA,
	CHAR(30)        AS NOMBRE_NOT,
	CHAR(5)         AS NUM_NOT,
	CHAR(30)        AS CDNOTARIO_OCT,
	CHAR(30)        AS DES_NOTARIOCT,
	CHAR(30)        AS ESCRITURA_POD,
	CHAR(30)        AS NOMNOTARIO_PD,
	CHAR(5)         AS NUMNOTARIO_PD,
	CHAR(30)        AS CDNOTARIO_PD,
	CHAR(30)        AS DESC_CDNOTARIOPD,
	CHAR(50)        AS NOMBRESOC,
	DATE            AS FECHAINS_PD,
	CHAR(60)        AS EMAIL_PM,
	CHAR(30)        AS FOLIO_MERCAN,
	CHAR(30)        AS CD_FOLIOMERCA,
	INTEGER         AS ESTATUS_CTE,
	CHAR(1)         AS AUXILIAR1,
	CHAR(1) 		AS AUXILIAR2,
	CHAR(1) 		AS AUXILIAR3,
    CHAR(1)         AS AUXILIAR4,
	CHAR(1)         AS AUXILIAR5,
    CHAR(1)         AS AUXILIAR6,
    CHAR(1)         AS AUXILIAR7,
	CHAR(1)         AS AUXILIAR8,
	CHAR(1)         AS AUXILIAR9,
	CHAR(1)         AS AUXILIAR10,
	CHAR(02)        AS TIPO_PERSONA,
	CHAR(20)        AS NUMCTE_APODERADO,
	CHAR(60)        AS NOMCTE_APODERADO,
	CHAR(100)       AS DESC_DOCONSTITUCION,
	CHAR(4)         AS SUCURSAL,
	DATE            AS FECHA_ALTA,
	CHAR(1)         AS AUXILIAR11,
	CHAR(3)         AS TIPO_PODER,
	CHAR(3)         AS TIPO_ADMON,
	CHAR(3)         AS TIPO_ORGANIZACION,
	CHAR(40)        AS NOMBRE_SUCURSAL,
	CHAR(1)         AS VALORPARAM_MORALGOB;


	--****************************************************************************************************
	-- MODIFICACION: Cuando el servicio del cliente esta cancelado 99 se pasa toda la información a tablas
	--		 historicas y se cambia los id de imagenes, para proceder con una RE-contratación.
	-- MOD. POR: David Picos Carrasco - BanCoppel.
	-- FECHA MOD: 23 Octubre 2014
	--***************************************************************************************************



	---DECLARACIONES
	DEFINE iSqlErr						INTEGER;
	DEFINE cCodRet         				CHAR(6);
	DEFINE cRFC         				CHAR(13);
    DEFINE cSucursal                    CHAR(4);
	DEFINE cApellPaterContactoRepLeg 	CHAR(26);
	DEFINE cApellMaterContactoRepLeg	CHAR(26);
	DEFINE cNomb1ContactoRepLeg         CHAR(26);
	DEFINE cNomb2ContactoRepLeg     	CHAR(26);
	DEFINE cCalleFiscal					CHAR(40);
	DEFINE cNumExtCalleFiscal       	CHAR(10);
	DEFINE cColFiscal         			CHAR(60);
	DEFINE vNomCiudFiscal         		VARCHAR(60,1);
	DEFINE cCodMunFiscal        		CHAR(3);
	DEFINE cNomEstadoFiscal        		CHAR(30);
	DEFINE cNumcte         				CHAR(20);
	DEFINE cNomCorto        			CHAR(30);
	DEFINE cPagInternet        			CHAR(30);
	DEFINE cSatFea        				CHAR(25);
	DEFINE cTelContacto    				CHAR(15);
	DEFINE cGiro      					CHAR(20);
	DEFINE cNomGiro    					CHAR(40);
	DEFINE cActividadSoc                CHAR(3);
	DEFINE cDesActObj  					CHAR(30);
	DEFINE cUsuarioAut    				CHAR(200);
	DEFINE cStatusAlta 					CHAR(1);
	DEFINE cRespStatus 					CHAR(2);
	DEFINE cApellPaterFirmantes 		CHAR(26);
	DEFINE cApellMaterFirmantes 		CHAR(26);
	DEFINE cNomb1Firmantes 				CHAR(26);
	DEFINE cNomb2Firmantes 				CHAR(26);
	DEFINE cCuentaNomina 				CHAR(20);
	DEFINE cPoder                       CHAR(3);
	DEFINE cAdmin                       CHAR(3);
	DEFINE cOrg                         CHAR(3);
	DEFINE cDesPoder                    CHAR(20);
	DEFINE cDesAdmin                    CHAR(20);
	DEFINE cDesOrg                      CHAR(40);
	DEFINE cTpoPersona                  CHAR(2);
	DEFINE dFechaIns                    DATE;
	DEFINE dFechaCons                   DATE;
	DEFINE iNac                         INTEGER;
	DEFINE cNomContacto                 CHAR(48);
	DEFINE cSufijo                      CHAR(2);
	DEFINE cDescSufi                    CHAR(60);
	DEFINE cEscritura                   CHAR(30);
	DEFINE cNombreNot                   CHAR(30);
	DEFINE cNumNot                      CHAR(5);
	DEFINE cCdNotarioct                 CHAR(60);
	DEFINE cDesCdNot                    CHAR(30);
	DEFINE cEscrituraPod                CHAR(30);
	DEFINE cNomNotariopd                CHAR (30);
	DEFINE cNumNotariopd                CHAR(5);
	DEFINE cCdNotariopd                 CHAR(30);
	DEFINE cDesCdNotpd                  CHAR(30);
	DEFINE cNombreSoc                   CHAR(50);
	DEFINE dFechaInspd                  DATE;
	DEFINE cEmailpm                     CHAR(60);
	DEFINE cEsFisica                    CHAR(1);
	DEFINE cNumfoliomerct               CHAR(30);
	DEFINE cCdfoliomerct                CHAR(30);
	DEFINE cAuxiliar1                   CHAR(1);
	DEFINE cAuxiliar2                   CHAR(1);
	DEFINE cAuxiliar3                   CHAR(1);
	DEFINE cAuxiliar4   				CHAR(1);
	DEFINE cAuxiliar5   				CHAR(1);
	DEFINE cAuxiliar6                   CHAR(1);
	DEFINE cAuxiliar7                   CHAR(1);
	DEFINE cAuxiliar8                   CHAR(1);
	DEFINE cAuxiliar9                   CHAR(1);
	DEFINE cAuxiliar10                  CHAR(1);
	DEFINE cAuxiliar11                  CHAR(1);
	DEFINE cNumcteapoder                CHAR(20);
	DEFINE cNomapoder                   CHAR(60);
	DEFINE cDocConst                    CHAR(100);
	DEFINE cDesNacion                   CHAR(15);
	DEFINE cNac                         CHAR(3);
	DEFINE dFechaAlta                   DATE;
	DEFINE cNombreSucursal              CHAR(40);
	DEFINE cPrmTpopersonaGob               CHAR(5);
	DEFINE cValorTpopersonaGop             CHAR(1);
	DEFINE iEstatusCteEmpNet            INTEGER;

	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET cCodRet         			= '000000';
	LET cRFC         				= '';
	LET cApellPaterContactoRepLeg   = '';
	LET cApellMaterContactoRepLeg 	= '';
	LET cNomb1ContactoRepLeg        = '';
	LET cNomb2ContactoRepLeg     	= '';
	LET cCalleFiscal				= '';
	LET cNumExtCalleFiscal       	= '';
	LET cColFiscal         			= '';
	LET vNomCiudFiscal         		= '';
	LET cCodMunFiscal        		= '';
	LET cNomEstadoFiscal        	= '';
	LET cNumcte         			= '';
	LET cNomCorto        			= '';
	LET cPagInternet        		= '';
	LET cSatFea        				= '';
	LET cTelContacto    			= '';
	LET cGiro      					= '';
	LET cNomGiro    				= '';
	LET cDesActObj  				= '';
	LET cUsuarioAut    				= '';
	LET cStatusAlta 				= '';
	LET cRespStatus 				= '';
	LET cApellPaterFirmantes 		= '';
	LET cApellMaterFirmantes 		= '';
	LET cNomb1Firmantes 			= '';
	LET cNomb2Firmantes 			= '';
	LET cCuentaNomina	 			= '';
	LET cPoder                      = '';
	LET cAdmin                      = '';
	LET cOrg                        = '';
	LET cDesPoder                   = '';
	LET cDesAdmin                   = '';
	LET cDesOrg                     = '';
	LET cTpoPersona                 = '';
	LET dFechaIns                   = DATE(1);
	LET dFechaCons                  = DATE(1);
	LET iNac                        = 0;
	LET cNomContacto                = '';
	LET cSufijo                     = '';
	LET cDescSufi                   = '';
	LET cActividadSoc               = '';
	LET cEscritura                  = '';
	LET cNombreNot                  = '';
	LET cNumNot                     = '';
	LET cCdNotarioct                = '';
	LET cDesCdNot                   = '';
	LET cEscrituraPod               = '';
	LET cNomNotariopd               = '';
	LET cNumNotariopd               = '';
	LET cCdNotariopd                = '';
	LET cDesCdNotpd                 = '';
	LET cNombreSoc                  = '';
	LET dFechaInspd                 = DATE(1);
	LET cEmailpm                    = '';
	LET cEsFisica                   = '';
	LET cCdfoliomerct               = '';
	LET cNumfoliomerct              = '';
	LET cAuxiliar1                  = '';
	LET cAuxiliar2                  = '';
	LET cAuxiliar3                  = '';
	LET cAuxiliar4                  = '';
	LET cAuxiliar5                  = '';
	LET cAuxiliar6                  = '';
	LET cAuxiliar7                  = '';
	LET cAuxiliar8                  = '';
	LET cAuxiliar9                  = '';
	LET cAuxiliar10                 = '';
	LET cAuxiliar11                 = '';
	LET cNumcteapoder               = '';
	LET cNomapoder                  = '';
	LET cDocConst                   = '';
	LET cDesNacion                  = '';
	LET cNac                        = '';
	LET cSucursal                   = '';
	LET dFechaAlta                  = DATE(1);
	LET cNombreSucursal             = '';
	LET cPrmTpopersonaGob              = '';
	LET cValorTpopersonaGop            = '';
	LET iEstatusCteEmpNet           = 0;

	
	BEGIN

		ON EXCEPTION SET iSqlErr
		   IF iSqlErr != 0 THEN
			
			  LET cCodRet = iSqlErr;
			  RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,''));

		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		

		IF TRIM(NVL(pNumcte,'')) = '' THEN
			LET cCodRet = '000001'; --PARÁMETRO VACIO

		 	RETURN cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,''));
		END IF;
		--SE CONSULTA EL TIPO PERSONA, RFC Y SUCURSAL REFERENTE AL CLIENTE
		SELECT tpo_persona, rfc, sucursal
		INTO cTpoPersona, cRFC, cSucursal
		FROM "informix".si_cliente
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';


		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		   LET cCodRet = '000002'; --CONSULTA SIN RESULTADOS, AL CONSULTAR PARAMETRO INVÁLIDO

		   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,''));
		END IF;

		--CONSULTA es_fisica OBTENIENDO 'S'= PERSONA FÍSICA, 'N'=PERSONA MORAL
		SELECT es_fisica
		INTO cEsFisica
        FROM "informix".si_tipper
		WHERE tpo_persona = TRIM(cTpoPersona);

		IF cEsFisica = 'S' THEN
		   LET cCodRet = '000003'; --PERSONA FÍSICA
		   LET cRFC = '';

		   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,''));

		END IF;

		--SE OBTIENEN LOS DATOS DE CLIENTE MORAL DE LA TABLA si_ctepm
		SELECT TRIM(NVL(numcte,'')),NVL(nombre_corto,''),NVL(pagina_internet,''),TRIM(NVL(sat_fea,'')),
			   TRIM(NVL(telefono_contacto,'')), TRIM(NVL(giro, '')),TRIM(NVL(tipo_poder,'')),TRIM(NVL(tipo_admon,'')),
			   TRIM(NVL(tipo_org,'')),fecha_inscrip,fecha_constitct,fecha_alta,nacionalidad,TRIM(NVL(nombre_contacto,'')),
			   TRIM(NVL(sufijo,'')),TRIM(NVL(actividadsocial,'')),NVL(escritura_constitutiva,''),
			   TRIM(NVL(nombre_notarioct,'')),TRIM(NVL(numero_notarioct,'')),TRIM(NVL(ciudad_notarioct,'')),
			   TRIM(NVL(numero_foliomercantilct,'')),TRIM(NVL(ciudad_foliomercantilct,'')),TRIM(NVL(escritura_poderes,'')),
			   TRIM(NVL(nombre_notariopd,'')),TRIM(NVL(numero_notariopd,'')), TRIM(NVL(ciudad_notariopd,'')),
			   TRIM(NVL(nombre_sociedad,'')),fecha_inscrippd, TRIM(NVL(emailpm,'')), TRIM(NVL(doc_constitucion,''))
		INTO cNumcte, cNomCorto, cPagInternet, cSatFea,
		     cTelContacto, cGiro, cPoder, cAdmin,
			 cOrg, dFechaIns, dFechaCons,dFechaAlta,iNac, cNomContacto,
			 cSufijo, cActividadSoc, cEscritura,
			 cNombreNot, cNumNot, cCdNotarioct,
			 cNumfoliomerct, cCdfoliomerct, cEscrituraPod,
			 cNomNotariopd, cNumNotariopd, cCdNotariopd,
			 cNombreSoc, dFechaInspd, cEmailpm,cDocConst
		FROM "informix".si_ctepm
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';


	    LET cNac = LPAD(iNac, 3,'0');

		--SE OBTIENE LA DESCRIPCION DE LA NACIONALIDAD
	    SELECT descripcion
		INTO cDesNacion
		FROM "informix".si_nacion
		WHERE nacion = cNac;

		--SE OBTIENE LA DESCRIPCION DEL SUFIJO
		SELECT descripcion
		INTO cDescSufi
		FROM "informix".si_sufijos
		WHERE empresa = '001'
		AND codigo = TRIM(cSufijo);

		--SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotarioct

		SELECT nombre
		INTO cDesCdNot
		FROM "informix".si_estados
		WHERE estado = TRIM(cCdNotarioct);

		-- SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotariopd

		SELECT nombre
		INTO cDesCdNotpd
		FROM "informix".si_estados
		WHERE estado = TRIM(cCdNotariopd);

		LET cPrmTpopersonaGob = 'tpo'||TRIM(cTpoPersona);		                                              --el parámetro en la tabla sc_param.

		SELECT TRIM(valor)
		INTO cValorTpopersonaGop
		FROM bdicheq:"informix".sc_param
		WHERE empresa = '001'
		AND codparam = TRIM(cPrmTpopersonaGob);

		--SE OBTIENE LA DESCRIPCION DE DATOS DE PERSONAS DE GOBIERNO tpo_persona = '05'*
		IF cValorTpopersonaGop = 'S' THEN

			SELECT descripcion
			INTO cDesPoder
			FROM "informix".si_tipo_poder_pm
			WHERE empresa = '001'
			AND codigo = TRIM(cPoder);

			SELECT descripcion
			INTO cDesAdmin
			FROM "informix".si_tipo_admin_pm
			WHERE empresa = '001'
			AND codigo = TRIM(cAdmin);

			SELECT descripcion
			INTO cDesOrg
			FROM "informix".si_tipo_org_pm
			WHERE empresa = '001'
			AND codigo = TRIM(cOrg);

		ELSE

		   LET cDesPoder = "";
		   LET cDesAdmin = "";
		   LET cDesOrg = "";

		END IF;


		--SE OBTIENE LA CUENTA Y EL ESTATUS DE LA EMPRESA CON EL SERVICIO DE NOMINA
		SELECT TRIM(NVL(cuenta,'')), TRIM(NVL(status_alta,''))
		INTO cCuentaNomina, cStatusAlta
		FROM bdicheq:"informix".sc_nominaempresas
		WHERE numcte = TRIM(pNumcte);

		IF TRIM(NVL(cStatusAlta,'')) = '3' THEN
		   LET cRespStatus = 'Si';
		ELSE
		   LET cRespStatus = 'No';
		END IF;

		--SE OBTIENE NOMBRE DEL REPRESENTANTE LEGAL Y RFC.
		SELECT TRIM(NVL(apell_paterno,'')),TRIM(NVL(apell_materno,'')),
	    TRIM(NVL(nombre1,'')),TRIM(NVL(nombre2,''))
		INTO cApellPaterContactoRepLeg,cApellMaterContactoRepLeg,cNomb1ContactoRepLeg,cNomb2ContactoRepLeg
		FROM "informix".si_cliente
		WHERE numcte = TRIM(cNomContacto)
		AND empresa = '001';


		--SE OBTIENE DOMICILIO FISCAL.
		SELECT 	TRIM(NVL(e.nombrecalle,'')),TRIM(NVL(a.numeroextcalle,'')),TRIM(NVL(f.nombrezona,'')),
				TRIM(NVL(g.nombre,'')),TRIM(NVL(c.municipio,'')),TRIM(NVL(b.nombre,''))
		INTO cCalleFiscal,cNumExtCalleFiscal,cColFiscal,vNomCiudFiscal,cCodMunFiscal,cNomEstadoFiscal
		FROM "informix".si_direcciones_actual a
			 LEFT OUTER JOIN "informix".si_estados 	   b ON (a.estado = b.estado)
			 LEFT OUTER JOIN "informix".si_municipios  c ON (a.municipio = c.municipio AND a.estado = c.estado AND a.ciudad = c.ciudad AND a.pais = c.pais)
			 LEFT OUTER JOIN "informix".si_catcalles   e ON (a.numerocalle = e.numerocalle)
			 LEFT OUTER JOIN "informix".si_catzonas    f ON (a.numerociudad = f.numerociudad AND a.numerocolonia = f.numerocolonia)
			 LEFT OUTER JOIN "informix".si_ciudades    g ON (a.estado = g.estado AND a.ciudad = g.ciudad)
		WHERE a.numcte = TRIM(pNumcte)
		AND a.tipo_dir = 1;

		--SE OBTIENE GIRO MERCANTIL.
		SELECT TRIM(NVL(nombre,''))
		INTO cNomGiro
		FROM "informix".si_actecon
		WHERE actividad = TRIM(cGiro);

		--SE OBTIENE ACTIVIDAD U OBJETO SOCIAL.
		SELECT TRIM(NVL(descripcion,''))
		INTO cDesActObj
		FROM "informix".si_actividadsocial
		WHERE codigo = TRIM(cActividadSoc);

	    --SE OBTIENE EL ESTATUS DEL SERVICIO DE EMPRESANET DEL CLIENTE
	    SELECT MAX (NVL(status_contrato, 0))
		INTO iEstatusCteEmpNet
		FROM bdibei:"informix".bei_contratacion
		WHERE empresa = '001'
		AND num_cliente = pNumcte;
		
		--- RECONTRATACION DE SERVICIO DE EMPRESANETPLUS------------------------------------------------------------------------
			
			IF iEstatusCteEmpNet=99 THEN
			
			--EJECUTAR SPL QUE SE ESTA GENERANDO PARA COLOCAR LA INFO EN HISTORICOS
			EXECUTE PROCEDURE bdibei:"informix".sp_gen_hist_servicioplus_bei(pNumcte) into cCodRet;
			
			--MANDAR LLAMAR SPLS PARA REGISTRAR EN HISTORICOS Y BORRAR DE TABLAS
			IF cCodRet <>'00000' THEN
				LET cCodRet='00004'; --Error en el sp_gen_hist_servicioplus_bei
			END IF;
							
			ELSE	
				
				RETURN cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,''));
						
			END IF;
		--FIN RECONTRATACION-----------------------------------------------------------------------------------------------------

		--OBTIENE EL NUMERO DE CTE APODERADO ASI COMO SU NOMBRE
		SELECT numcteapoderado,nombreapoderado
		INTO cNumcteapoder, cNomapoder
		FROM "informix".si_apoderado
		WHERE empresa = '001'
		AND numcte = TRIM(cNumcte)
		AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_apoderado WHERE empresa = '001');

		--SE OBTIENE EL AUTORIZADO PARA MANEJAR LAS CUENTAS DE REGISTRO FIRMAS:
		SELECT TRIM(NVL(b.apell_paterno,'')),TRIM(NVL(b.apell_materno,'')),TRIM(NVL(b.nombre1,'')),TRIM(NVL(b.nombre2,''))
		INTO cApellPaterFirmantes,cApellMaterFirmantes,cNomb1Firmantes,cNomb2Firmantes
		FROM bdicheq:"informix".sc_firmantes a INNER JOIN "informix".si_cliente b ON(a.numcte = b.numcte)
		WHERE a.empresa = '001'
		AND a.cuenta = TRIM(cCuentaNomina)
		AND a.secuencia = 1;

		--SE OBTIENE EL NOMBRE DE LA SUCURSAL
		SELECT nombre
		INTO cNombreSucursal
        FROM "informix".si_sucursales
        WHERE sucursal = TRIM(cSucursal);

		--SE RETORNA INFORMACION.
	   RETURN 	cCodRet,TRIM(NVL(cRFC,'')),TRIM(NVL(cApellPaterContactoRepLeg,'')),TRIM(NVL(cApellMaterContactoRepLeg,'')),TRIM(NVL(cNomb1ContactoRepLeg,'')),
			            TRIM(NVL(cNomb2ContactoRepLeg,'')),TRIM(NVL(cCalleFiscal,'')),TRIM(NVL(cNumExtCalleFiscal,'')),TRIM(NVL(cColFiscal,'')),
						TRIM(NVL(vNomCiudFiscal,'')),TRIM(NVL(cCodMunFiscal,'')),TRIM(NVL(cNomEstadoFiscal,'')),TRIM(NVL(cNumcte,'')),TRIM(NVL(cNomCorto,'')),
						TRIM(NVL(cPagInternet,'')),TRIM(NVL(cSatFea,'')),TRIM(NVL(cTelContacto,'')),TRIM(NVL(cGiro,'')),TRIM(NVL(cNomGiro,'')),
						TRIM(NVL(cActividadSoc,'')),TRIM(NVL(cDesActObj,'')),TRIM(NVL(cRespStatus,'')),TRIM(NVL(cApellPaterFirmantes,'')),
						TRIM(NVL(cApellMaterFirmantes,'')),TRIM(NVL(cNomb1Firmantes,'')),TRIM(NVL(cNomb2Firmantes,'')),TRIM(NVL(cDesPoder,'')),
						TRIM(NVL(cDesAdmin,'')),TRIM(NVL(cDesOrg,'')),NVL(dFechaIns,DATE(1)),NVL(dFechaCons,DATE(1)),TRIM(NVL(cNac,'')),TRIM(NVL(cDesNacion,'')),
						TRIM(NVL(cNomContacto,'')),TRIM(NVL(cSufijo,'')),TRIM(NVL(cDescSufi,'')),TRIM(NVL(cEscritura,'')),TRIM(NVL(cNombreNot,'')),TRIM(NVL(cNumNot,'')),
						TRIM(NVL(cCdNotarioct,'')),TRIM(NVL(cDesCdNot,'')),TRIM(NVL(cEscrituraPod,'')),TRIM(NVL(cNomNotariopd,'')),TRIM(NVL(cNumNotariopd,'')),
						TRIM(NVL(cCdNotariopd,'')),TRIM(NVL(cDesCdNotpd,'')),TRIM(NVL(cNombreSoc,'')),NVL(dFechaInspd,DATE(1)),TRIM(NVL(cEmailpm,'')),
						TRIM(NVL(cCdfoliomerct,'')),TRIM(NVL(cNumfoliomerct,'')),NVL(iEstatusCteEmpNet, 0),TRIM(NVL(cAuxiliar1, '')),TRIM(NVL(cAuxiliar2, '')),
						TRIM(NVL(cAuxiliar3, '')),TRIM(NVL(cAuxiliar4,'')),TRIM(NVL(cAuxiliar5,'')),TRIM(NVL(cAuxiliar6,'')),TRIM(NVL(cAuxiliar7,'')),
						TRIM(NVL(cAuxiliar8,'')),TRIM(NVL(cAuxiliar9,'')),TRIM(NVL(cAuxiliar10,'')), TRIM(NVL(cTpoPersona,'')),TRIM(NVL(cNumcteapoder,'')),
						TRIM(NVL(cNomapoder,'')),TRIM(NVL(cDocConst,'')),TRIM(NVL(cSucursal,'')),NVL(dFechaAlta,DATE(1)),TRIM(NVL(cAuxiliar11,'')),TRIM(NVL(cPoder,'')),
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,''));

	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene la informacion del cliente moral',
'ahora validando de manera general el tipo de persona.',
'AUTOR:  Mireya Reyes',
'FECHA DE CREACION: 22/08/2013',
'VERSION: 20130823.1430',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actualizarfc_dos()
RETURNING CHAR(5) as codret, CHAR(5) as codret2, CHAR(5) as mensaje;

DEFINE vcodret1         char(5); 
DEFINE vcodret2         char(5);
DEFINE vcodret3         char(50);
DEFINE sql_err          integer;
DEFINE isam_err         integer;
DEFINE desc_err         char(50);
DEFINE vnumcte          char(10);
DEFINE vrfc_calculado   char(13);
DEFINE vcomienza        smallint;
DEFINE ven_transacc     smallint;
DEFINE vcontador1       integer;

LET vcodret1            ='00000';
LET vcodret2            ='0000';
LET vcodret3            ='PROCESO CONCLUIDO SATISFACTORIAMENTE';
LET sql_err             =0;
LET isam_err            =0;
LET desc_err            ='';
LET vcomienza           =-1;
LET ven_transacc        = 0;  
LET vnumcte             ='';
LET vrfc_calculado      ='';
LET vcontador1          =0;



BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/arch_sp_actualizarfc.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;

            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH WITH HOLD
        select  numcte, rfc_calculado INTO vnumcte,  vrfc_calculado from resultadosrfc where rfc_duplicado=0
    
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        UPDATE si_cliente set rfc=vrfc_calculado where numcte=vnumcte and fecha_alta<'10/22/2014';

        LET vcontador1 = vcontador1 + 1;
        

        IF (vcontador1 >= 5000) THEN
            LET vcontador1 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
     END FOREACH;

     IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
     END IF;

END;
RETURN vcodret1, vcodret2, vcodret3; 
END PROCEDURE;