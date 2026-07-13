CREATE PROCEDURE "informix".sp_consultarctemoral_03(pNumcte CHAR(20))

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
	CHAR(60) 		AS NOM_CORTO,
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
	CHAR(1)         AS VALORPARAM_MORALGOB,
	CHAR(254)        AS RAZON_SOCIAL,
    CHAR(20)        AS CURP,
	CHAR(13)		AS RFC_ALT,
	CHAR(50)		AS REG_FISCAL;
	
	
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
	DEFINE cNomCorto        			CHAR(60);				
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
	DEFINE cPrmTpopersonaGob            CHAR(5);
	DEFINE cValorTpopersonaGop          CHAR(1);
	DEFINE iEstatusCteEmpNet            INTEGER;
	DEFINE cRazonSocial					CHAR(254);
    DEFINE cCURP                        CHAR(20);
	DEFINE cRFCAlt						CHAR(13);
	DEFINE cCodRegFiscal				CHAR(3);
	DEFINE cRegimenFiscal				CHAR(50);
	
	
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
	LET cRazonSocial				= '';
    LET cCURP                       = '';
	LET cRFCAlt						= '';
	LET cRegimenFiscal				= '';
	LET cCodRegFiscal				= '';
	
	
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
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
					
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarctemoral02.out';
		--TRACE ON;
		
		IF TRIM(NVL(pNumcte,'')) = '' THEN
			LET cCodRet = '000001'; --PARÃMETRO VACIO
			
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
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		END IF;
		--SE CONSULTA EL TIPO PERSONA, RFC Y SUCURSAL REFERENTE AL CLIENTE
		SELECT tpo_persona, rfc, sucursal,rfc_alterno
		INTO cTpoPersona, cRFC, cSucursal, cRFCAlt
		FROM si_cliente
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';
		
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
		   LET cCodRet = '000002'; --CONSULTA SIN RESULTADOS, AL CONSULTAR PARAMETRO INVÃLIDO
		   
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
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		END IF;
		
		--CONSULTA es_fisica OBTENIENDO 'S'= PERSONA FÃSICA, 'N'=PERSONA MORAL
		SELECT es_fisica
		INTO cEsFisica
        FROM si_tipper
		WHERE tpo_persona = TRIM(cTpoPersona);
		
		IF cEsFisica = 'S' THEN
		   LET cCodRet = '000003'; --PERSONA FÃSICA
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
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
		   
		END IF;
		--CAMBIO
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
		FROM si_ctepm 
		WHERE numcte = TRIM(pNumcte)
		AND empresa = '001';

		--CAMBIO 
		--SE OBTIENEN LAS RAZON SOCIAL DEl CLIENTE MORAL DE LA TABLA si_fiscal
		SELECT LIMIT 1 TRIM(NVL(nom_razon_soc, '')),regim_fiscal
		INTO cRazonSocial, cCodRegFiscal
		FROM bdinteg:si_fiscal
		WHERE empresa = '001' 
		AND numcte = TRIM(pNumcte);

		IF cRazonSocial = '' THEN
			/*--SE OBTIENE LA RAZON SOCIAL;*/
			SELECT razon_social
			INTO cRazonSocial
        	FROM si_cliente
        	WHERE numcte = TRIM(pNumcte)
			AND empresa = '001';
		END IF;
		
	    LET cNac = LPAD(iNac, 3,'0');
		
		--SE OBTIENE LA DESCRIPCION DE LA NACIONALIDAD
	    SELECT descripcion
		INTO cDesNacion
		FROM si_nacion
		WHERE nacion = cNac;
		
		--SE OBTIENE LA DESCRIPCION DEL SUFIJO 
		SELECT descripcion 
		INTO cDescSufi 
		FROM si_sufijos 
		WHERE empresa = '001'
		AND codigo = TRIM(cSufijo);
		
		--SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotarioct
		
		SELECT nombre 
		INTO cDesCdNot 
		FROM si_estados 
		WHERE estado = TRIM(cCdNotarioct);
		
		-- SE OBTIENE LA DESCRIPCION DEL ESTADO DE cCdNotariopd
		
		SELECT nombre 
		INTO cDesCdNotpd 
		FROM si_estados 
		WHERE estado = TRIM(cCdNotariopd);
		
		LET cPrmTpopersonaGob = 'tpo'||TRIM(cTpoPersona);		
		SELECT TRIM(valor)
		INTO cValorTpopersonaGop
		FROM bdicheq:sc_param
		WHERE empresa = '001'
		AND codparam = TRIM(cPrmTpopersonaGob);

		IF cEsFisica = 'N' THEN

			-- SE OBTIENE DESCRIPCIÃN DE EL REGIMEN FISCAL PARA PERSONAS MORALES
			SELECT TRIM(descripcion)
			INTO cRegimenFiscal 
			FROM bdinteg:si_regimen_fiscal
			WHERE c_regimenfiscal = cCodRegFiscal
			AND tipo = 'M';

		ELIF cEsFisica = 'S' THEN

			-- SE OBTIENE DESCRIPCIÃN DE EL REGIMEN FISCAL PARA PERSONAS FISICAS
			SELECT TRIM(descripcion)
			INTO cRegimenFiscal 
			FROM bdinteg:si_regimen_fiscal
			WHERE c_regimenfiscal = cCodRegFiscal
			AND tipo = 'F';
		END IF;

		--SE OBTIENE LA DESCRIPCION DE DATOS DE PERSONAS DE GOBIERNO tpo_persona = '05'*
		IF cValorTpopersonaGop = 'S' THEN
			
			SELECT descripcion
			INTO cDesPoder
			FROM si_tipo_poder_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cPoder);
			
			SELECT descripcion
			INTO cDesAdmin
			FROM si_tipo_admin_pm 
			WHERE empresa = '001'
			AND codigo = TRIM(cAdmin);
			
			SELECT descripcion
			INTO cDesOrg
			FROM si_tipo_org_pm 
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
		FROM bdicheq:sc_nominaempresas
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
		FROM si_cliente 
		WHERE numcte = TRIM(cNomContacto)
		AND empresa = '001';
		
							
		--SE OBTIENE DOMICILIO FISCAL.			
		SELECT 	TRIM(NVL(e.nombrecalle,'')),TRIM(NVL(a.numeroextcalle,'')),TRIM(NVL(f.nombrezona,'')),
				TRIM(NVL(g.nombre,'')),TRIM(NVL(c.municipio,'')),TRIM(NVL(b.nombre,''))			
		INTO cCalleFiscal,cNumExtCalleFiscal,cColFiscal,vNomCiudFiscal,cCodMunFiscal,cNomEstadoFiscal
		FROM si_direcciones_actual a 
			 LEFT OUTER JOIN si_estados 	   b ON (a.estado = b.estado)
			 LEFT OUTER JOIN si_municipios  c ON (a.municipio = c.municipio AND a.estado = c.estado AND a.ciudad = c.ciudad AND a.pais = c.pais)
			 LEFT OUTER JOIN si_catcalles   e ON (a.numerocalle = e.numerocalle)
			 LEFT OUTER JOIN si_catzonas    f ON (a.numerociudad = f.numerociudad AND a.numerocolonia = f.numerocolonia)
			 LEFT OUTER JOIN si_ciudades    g ON (a.estado = g.estado AND a.ciudad = g.ciudad)		 
		WHERE a.numcte = TRIM(pNumcte)
		AND a.tipo_dir = 1;
		
		--SE OBTIENE GIRO MERCANTIL.
		SELECT TRIM(NVL(nombre,'')) 
		INTO cNomGiro
		FROM si_actecon
		WHERE actividad = TRIM(cGiro);
										
		--SE OBTIENE ACTIVIDAD U OBJETO SOCIAL.
		SELECT TRIM(NVL(descripcion,'')) 
		INTO cDesActObj
		FROM si_actividadsocial 
		WHERE codigo = TRIM(cActividadSoc);		
	
	    --SE OBTIENE EL ESTATUS DEL SERVICIO DE EMPRESANET DEL CLIENTE
	    SELECT MAX (NVL(status_contrato, 0))
		INTO iEstatusCteEmpNet
		FROM bdibei:bei_contratacion
		WHERE empresa = '001'
		AND num_cliente = pNumcte;
		
		--OBTIENE EL NUMERO DE CTE APODERADO ASI COMO SU NOMBRE
		SELECT numcteapoderado,nombreapoderado 
		INTO cNumcteapoder, cNomapoder
		FROM si_apoderado
		WHERE empresa = '001'
		AND numcte = TRIM(cNumcte)
		AND secuencia = (SELECT MAX(secuencia) FROM si_apoderado WHERE empresa = '001');

        --OBTIENE LA CLAVE CURP DE CTE APODERADO
		SELECT TRIM(curp)
		INTO cCURP
		FROM si_ctepf
		WHERE empresa = '001'
		AND numcte = TRIM(cNumcteapoder);
        
	
		--SE OBTIENE EL AUTORIZADO PARA MANEJAR LAS CUENTAS DE REGISTRO FIRMAS:
		SELECT TRIM(NVL(b.apell_paterno,'')),TRIM(NVL(b.apell_materno,'')),TRIM(NVL(b.nombre1,'')),TRIM(NVL(b.nombre2,''))
		INTO cApellPaterFirmantes,cApellMaterFirmantes,cNomb1Firmantes,cNomb2Firmantes
		FROM bdicheq:sc_firmantes a INNER JOIN si_cliente b ON(a.numcte = b.numcte)
		WHERE a.empresa = '001'
		AND a.cuenta = TRIM(cCuentaNomina)
		AND a.secuencia = 1;
		
		--SE OBTIENE EL NOMBRE DE LA SUCURSAL
		SELECT nombre 
		INTO cNombreSucursal
        FROM si_sucursales
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
						TRIM(NVL(cAdmin,'')),TRIM(NVL(cOrg,'')),TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cValorTpopersonaGop,'')),TRIM(NVL(cRazonSocial,'')),cCURP,cRFCAlt, cRegimenFiscal;
                    	
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene la informacion del cliente moral',
'ahora validando de manera general el tipo de persona.',
'AUTOR:  Mireya Reyes',   
'FECHA DE CREACION: 22/08/2013',
'AUTOR:  Daniel Reyes Guillen',   
'FECHA: 24/06/2021',
'DESCRIPCION: Se aÃ±ade CURP',
'AUTOR:  Jose Antonio Ramirez Franco',   
'FECHA: 29/09/2023',
'DESCRIPCION: Se aÃ±ade Regimen fiscal',
'AUTOR:  Jose Antonio Ramirez Franco',   
'FECHA: 10/12/2024',
'DESCRIPCION: Se realiza modificaciÃ³n en la consulta para obtener el regimen fiscal filtrando por el tipo de persona',
'VERSION: 20130823.1430',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_depurar_clientes_pyt()
RETURNING INTEGER AS rSqlErr, INTEGER AS IsamErr, CHAR(255) AS DescErr ;

    DEFINE dfecha_inicio DATETIME YEAR TO FRACTION(5);
    DEFINE dfecha_fin DATETIME YEAR TO FRACTION(5);
    DEFINE id_control INT;
    DEFINE contador INT;
    DEFINE secuencia_borrar INT;
	DEFINE total_a_borrar INT;
    DEFINE itotal_borrados INT;
	DEFINE bEnTransaccion BOOLEAN;
	
	--DEFINE rSqlErr CHAR(5);
    --DEFINE DescErr CHAR(255);
	
	DEFINE rSqlErr  			INTEGER;
	DEFINE iIsamErr 			INTEGER;
	DEFINE DescErr 				CHAR(255);
	
	LET rSqlErr	 = 0;
	LET iIsamErr = 0;
	LET DescErr = '';

    -- Inicializar variables
    LET contador = 0;
	LET total_a_borrar = 0;
    LET itotal_borrados = 0;
	LET bEnTransaccion = 'f';

	
BEGIN
	ON EXCEPTION 
		SET rSqlErr, iIsamErr, DescErr
		--SET DEBUG FILE TO "/tmp/pruebas_coordinacion/ambientacion_clientes/debug_log.txt";
		--TRACE ON;

		SET DEBUG FILE TO "/RESPALDOSNEW/prevfraudes/debug_log.txt";
		TRACE ON;
		
        --LET rSqlErr = SQLCODE;
        --LET DescErr = ERRMSG(rSqlErr);
        --ROLLBACK WORK;

        --UPDATE control_ejecucion_sp_depurar_clientes_pyt
        --   SET fecha_fin_ejecucion = CURRENT,
        --       codigo_error = rSqlErr,
        --       descripcion_error = DescErr,
        --       total_registros_borrados = itotal_borrados
        -- WHERE id_control = id_control;
		 
		UPDATE control_ejecucion_sp_depurar_clientes_pyt
		SET
			fecha_fin_ejecucion = CURRENT,
			status = 0,
			codigo_error = rSqlErr,
			descripcion_error = DescErr,
			total_registros_borrados = itotal_borrados
		WHERE id_control = id_control;
		
		--IF itotal_borrados = 0 THEN
        --    ROLLBACK WORK;
        --END IF;
		
		IF bEnTransaccion = 't' THEN
			ROLLBACK WORK;
			LET bEnTransaccion = 'f';
			--LET dFechaCargaini = 0;
			--LET dFechaCargafin = 0;
			--LET iFechaMax_Cargada = 0;
			--LET vreg_insertados = 0;
			
			--UPDATE control_ejecucion_sp_depurar_clientes_pyt
			--SET (fecha_fin_ejecucion, fecha_cargaini, fecha_cargafin, fechamax_cargada, reg_insertados, status_proc, cod_err, descripcion_err)
			--= (dFechaProcesofin, dFechaCargaini, dFechaCargafin, iFechaMax_Cargada, vreg_insertados, vstatus_proc, cCodRet1, cCodRet3)
			--where id_proceso = iId_proceso AND status_proc = '1';
		ELSE
			ROLLBACK WORK;
			LET bEnTransaccion = 'f';
			--INSERT INTO ctrl_info_insert_tde_sendmsgs_tar_hist (id_proceso,fecha_procesoIni, fecha_fin_ejecucion, nombre_proceso,
			--fecha_cargaini, fecha_cargafin, fechamax_cargada, reg_insertados, status_proc, cod_err, descripcion_err)
			--VALUES (iId_proceso,dFechaProcesoini, dFechaProcesofin, NVL(cProceso1,''), dFechaCargaini, dFechaCargafin, iFechaMax_Cargada,
			--		vreg_insertados, vstatus_proc,cCodRet1,cCodRet3);
		END IF

        --RETURN rSqlErr, DescErr;
		RETURN rSqlErr, iIsamErr, DescErr;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/pruebas_coordinacion/ambientacion_clientes/debug_log.txt";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    -- Obtener el rango de fechas
    SELECT fecha_inicio, fecha_fin
      INTO dfecha_inicio, dfecha_fin
      FROM fechas_sp_depurar_clientes_pyt
     WHERE id_configuracion = 1;

    -- Validar que las fechas sean vÃ¡lidas
	IF dfecha_inicio IS NULL OR dfecha_fin IS NULL THEN
		LET rSqlErr = -0001;
		LET DescErr = 'Fechas no configuradas en tabla';
		--RETURN rSqlErr, DescErr;
		RETURN rSqlErr, iIsamErr, DescErr;
	END IF;

	IF dfecha_inicio > dfecha_fin THEN
		LET rSqlErr = -0002;
		LET DescErr = 'Rango de fechas invÃ¡lido';
		--RETURN rSqlErr, DescErr;
		RETURN rSqlErr, iIsamErr, DescErr;
	END IF;
	
	LET rSqlErr = 00001;
	LET DescErr = 'DepuraciÃ³n en ejecuciÃ³n';

	-- Insertar registro inicial en tabla de control
    INSERT INTO control_ejecucion_sp_depurar_clientes_pyt(
        fecha_inicio_ejecucion, fecha_inicio_periodo, fecha_fin_periodo, status, codigo_error, descripcion_error)
    VALUES (
        CURRENT YEAR TO FRACTION(5), dfecha_inicio, dfecha_fin, 1, rSqlErr, DescErr
    );
	
    LET id_control = DBINFO('sqlca.sqlerrd1'); -- Recuperar el id de control
	--SELECT DBINFO('sqlca.sqlerrd1') INTO id_control FROM systables WHERE tabid = 1;
	
    -- 1. Identificar los numcte dentro del rango configurado
    SELECT DISTINCT t.numcte
      FROM info_clientes_pyt t
     WHERE t.fecha_ctrl BETWEEN dfecha_inicio AND dfecha_fin
    INTO TEMP temp_numcte_rango WITH NO LOG;

    CREATE INDEX idx_temp_numcte_rango ON temp_numcte_rango(numcte);
	
	UPDATE STATISTICS MEDIUM FOR TABLE temp_numcte_rango;


    -- 2. Identificar la fecha mÃ¡s reciente para CLI y CPF globalmente
    SELECT t.numcte, t.tbl_orig, MAX(t.fecha_ctrl) AS max_fecha_ctrl
      FROM info_clientes_pyt t
           INNER JOIN temp_numcte_rango tmp
               ON t.numcte = tmp.numcte
     WHERE t.tbl_orig IN ('CLI', 'CPF')
     GROUP BY t.numcte, t.tbl_orig
    INTO TEMP temp_fechas_recientes WITH NO LOG;

    CREATE INDEX idx_temp_fechas_recientes ON temp_fechas_recientes(numcte, tbl_orig);

	UPDATE STATISTICS MEDIUM FOR TABLE temp_fechas_recientes;	
	
    -- 3. Identificar registros a mantener (fecha mÃ¡s reciente global)
    SELECT t.secuencia
      FROM info_clientes_pyt t
           INNER JOIN temp_fechas_recientes tmp
               ON t.numcte = tmp.numcte
              AND t.tbl_orig = tmp.tbl_orig
              AND t.fecha_ctrl = tmp.max_fecha_ctrl
    INTO TEMP temp_registros_a_mantener WITH NO LOG;

    CREATE INDEX idx_temp_mantener ON temp_registros_a_mantener(secuencia);

    UPDATE STATISTICS MEDIUM FOR TABLE temp_registros_a_mantener;


    -- 4. Identificar registros a borrar (excluyendo los registros a mantener)
    SELECT t.secuencia
      FROM info_clientes_pyt t
           INNER JOIN temp_numcte_rango tmp
               ON t.numcte = tmp.numcte
     WHERE t.tbl_orig IN ('CLI', 'CPF')
       AND NOT EXISTS (
           SELECT 1
             FROM temp_registros_a_mantener tmp2
            WHERE tmp2.secuencia = t.secuencia
       )
    INTO TEMP temp_registros_a_borrar WITH NO LOG;

    CREATE INDEX idx_temp_borrar ON temp_registros_a_borrar(secuencia);
	
    UPDATE STATISTICS MEDIUM FOR TABLE temp_registros_a_borrar;


	-- Calcular total de registros a borrar
	SELECT COUNT(*) INTO total_a_borrar FROM temp_registros_a_borrar;
	
	-- Actualizar control con total de registros a borrar
	UPDATE control_ejecucion_sp_depurar_clientes_pyt
	SET total_registros_a_borrar = total_a_borrar
	WHERE id_control = id_control;
	
	DROP TABLE temp_numcte_rango;
	DROP TABLE temp_fechas_recientes;
	DROP TABLE temp_registros_a_mantener;
	
    -- Procesar los registros en bloques
    BEGIN WORK;
		LET bEnTransaccion = 't';
		FOREACH WITH HOLD
			SELECT secuencia
			INTO secuencia_borrar
			FROM temp_registros_a_borrar
			
			insert into bdinteg:info_clientes_pyt_resp
            select * from bdinteg:info_clientes_pyt
            where secuencia = secuencia_borrar;
			
			--secuencia,empresa,numcte,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_insert,fecha_alta,sexo,fecha_nac,accion,fecha_ctrl,tbl_orig     
			
			DELETE FROM info_clientes_pyt
			WHERE secuencia = secuencia_borrar;
			
			-- Confirmar cada 5,000 registros
			IF contador >= 5000 THEN
				COMMIT WORK;
				LET contador = 0;
				BEGIN WORK;
			ELSE
				LET contador = contador + 1;
				LET itotal_borrados = itotal_borrados + 1;
			END IF;

		END FOREACH;
	
    COMMIT WORK;

	LET bEnTransaccion = 'f';

	UPDATE STATISTICS MEDIUM FOR TABLE info_clientes_pyt;
	UPDATE STATISTICS MEDIUM FOR TABLE info_clientes_pyt_resp;
	
	LET rSqlErr = 00000;
	LET DescErr = 'DepuraciÃ³n Exitosa';
	 
	-- Finalizar ejecuciÃ³n del SP
	UPDATE control_ejecucion_sp_depurar_clientes_pyt
	SET
        fecha_fin_ejecucion = CURRENT YEAR TO FRACTION(5),
		status = 0,
		codigo_error = rSqlErr,
		descripcion_error = DescErr,
		total_registros_borrados = itotal_borrados
	WHERE id_control = id_control;
	
	DROP table temp_registros_a_borrar;
	
	--RETURN rSqlErr, DescErr;
	RETURN rSqlErr, iIsamErr, DescErr;
END
END PROCEDURE;