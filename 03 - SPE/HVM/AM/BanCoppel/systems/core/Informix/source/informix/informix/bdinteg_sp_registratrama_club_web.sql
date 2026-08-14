CREATE PROCEDURE "informix".sp_registratrama_club_web
(
   pEmpresa CHAR(3),
   pNumCte CHAR(20),
   pNumCteCoppel CHAR(20),
   pNumPoliza CHAR(20),
   pTrama CHAR(4000),
   pFecha CHAR(21),
   pEnvio CHAR(1),
   pOpcion CHAR(1)
 )
RETURNING CHAR(5) AS CodRet,
		  CHAR(25) as FechaInsert

DEFINE	cCodRet CHAR(5);
DEFINE	iSql_err INTEGER;
DEFINE	cFechaInsert CHAR(19);

LET cCodRet = '00000';
LET iSql_err = 0;
LET cFechaInsert = '';

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET cCodRet = iSql_err;
           RETURN cCodRet,cFechaInsert;
        END IF;

    END EXCEPTION;

     --SET DEBUG FILE TO "/respaldosbd/obed/sp_registratrama_club.out";
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF NVL(pOpcion,'') <> ''  THEN

		LET pOpcion = TRIM(pOpcion);
		LET pFecha = TRIM(pFecha);
		
		IF pOpcion= '1' THEN
			IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pTrama,'') <> '' THEN
				LET cFechaInsert = CURRENT YEAR TO SECOND;
				LET cFechaInsert= TRIM(cFechaInsert);
				Insert into "informix".si_club_servicio (empresa,numcte,numcte_coppel,num_poliza,trama,fecha,envio)
									                      values(pEmpresa,pNumCte,pNumCteCoppel,pNumPoliza,pTrama,cFechaInsert,'0');
			ELSE
				LET cCodRet = '00001'; 
			END IF;	
		END IF;
		
		IF TRIM(pOpcion)= '2' THEN
			IF NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'') <> '' AND NVL(pFecha,'') <> '' AND NVL(pEnvio,'') <> '' THEN
				LET pNumCte=TRIM(pNumCte);
				LET pEmpresa=TRIM(pEmpresa);
				LET pEnvio=TRIM(pEnvio);
			
				UPDATE "informix".si_club_servicio 
				SET envio = pEnvio 
				WHERE numcte = pNumCte AND
				fecha = pFecha;
				LET cFechaInsert = pFecha;
			ELSE
				LET cCodRet = '00001'; 
			END IF;	
		END IF;
		
	ELSE
		LET cCodRet = '00001'; 
	END IF;	
	
	RETURN cCodRet, cFechaInsert;
END;
END PROCEDURE
DOCUMENT
"Folio:1606",
"Proyecto: ClubDeProteccion",
"Autor:95572503 Obed Vega",
"Fecha:02/Jul/2014",
"Descripcion: Se crea SP para registrar todas las tramas del Club de Proteccion que se envien a Coppel",
"Sustento: RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel_final.pdf",
"Solicita: Rodolfo Gomez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_refdirecciones_cjunk_web(
                                     pEmpresa           CHAR(3),
                                     pTipo              CHAR (1),
                                     pFuncion           CHAR(1),
                                     pNumCte            CHAR(20),
                                     pSecuencia         INTEGER,
                                     pTiipoDir          CHAR(1),
                                     pCalle             CHAR(40),
                                     pColonia           CHAR(60),
                                     pMunicipio         CHAR(5),
                                     pEntreCalles       CHAR(40),
                                     pPais              CHAR(3),
                                     pEntidad           CHAR(2),
                                     pLocalidad         CHAR(3),
                                     pCodPostal         CHAR(5),
                                     pTipoTel1          CHAR(1),
                                     pTelefono1         CHAR(13),
                                     pTipoTel2          CHAR(1),
                                     pTelefono2         CHAR(13),
                                     pTipoTel3          CHAR(1),
                                     pTelefono3         CHAR(13),
                                     pExtension         CHAR(5),
                                     pEstadoInegi       CHAR(2),
                                     pMunicipioInegi    CHAR(3),
                                     pLocalidadInegi    CHAR(4),
                                     pNoCiudad          SMALLINT,
                                     pNoExt             CHAR(10),
                                     pNoInt             CHAR(10),
                                     pDepto             CHAR(6),
                                     pNoCalle           INTEGER,
                                     pNoColonia         INTEGER,
                                     pPuntocar          CHAR(1),
                                     pUniHabi           CHAR(1),
                                     pManz              SMALLINT,
                                     pPotros            SMALLINT,
                                     pAndador           SMALLINT,
                                     pEtapa             SMALLINT,
                                     pLote              SMALLINT,
                                     pEdif              SMALLINT,
                                     pEntrada           SMALLINT,
                                     pObserva           CHAR(80),
                                     pUserInsert        CHAR(8),
                                     pFechaInsert       DATE,
                                     pNumCteBanco       CHAR(20))
	 RETURNING CHAR(5);
	
	--DEFINICION DE VARIABLES
	
	DEFINE cCodRet          CHAR(5);
	DEFINE cNombre          CHAR(40);
	DEFINE cNumcte          CHAR(20);
	DEFINE iSqlErr          INTEGER;
	DEFINE cDescFijoMovil   CHAR(5);
	DEFINE cResulFijoMovil  CHAR(5);
	DEFINE iFijoMovil1      INTEGER;
	DEFINE iFijoMovil2      INTEGER;
	DEFINE iFijoMovil3      INTEGER;
	
	--INICILIZACION DE VARIABLES
	
	LET cCodRet         = '';
	LET cNombre         = '';
	LET cNumcte         = '';
	LET iSqlErr         = 0;
	LET cDescFijoMovil  = '';
	LET cResulFijoMovil = '';
	LET iFijoMovil1     = 0;
	LET iFijoMovil2     = 0;
	LET iFijoMovil3     = 0;
	
	--SET DEBUG FILE TO "/tmp/sp_refdirecciones_cjunk.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet=iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET cCodRet = "00000";
		LET pTipo = pTipo;

		SELECT numcte INTO cNumcte 
		FROM "informix".si_cliente
		WHERE numcte = pNumCte;
		IF cNumcte IS NULL THEN
			LET cCodRet = "00104";
			RETURN cCodRet;
		END IF

		IF pFuncion="A" THEN
		{
			SELECT nombre INTO cNombre
			FROM "informix".si_paises
			WHERE pais = pPais;
			IF cNombre IS NULL THEN
				LET cCodRet="00121";
				RETURN cCodRet;
			END IF;

			SELECT nombre INTO cNombre
			FROM "informix".si_estados
			WHERE pais=pPais AND estado=pEntidad;

			IF cNombre IS NULL THEN
				LET cCodRet="00122";
				RETURN cCodRet;
			END IF;

			SELECT nombre INTO cNombre
			FROM "informix".si_ciudades
			WHERE pais=pPais AND estado=pEntidad AND ciudad=pLocalidad;
			IF cNombre IS NULL THEN
				LET cCodRet="00123";
				RETURN cCodRet;
			END IF;
		}
		 
			IF pTipo = '1' THEN 
				
				IF pTelefono1 <> '' THEN
					-- // VERIFICA SI ES MOVIL O FIJO   
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono1) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil1;
					LET pTipoTel1 = 'P';
					IF cDescFijoMovil = 'FIJO' THEN
						LET iFijoMovil1 = 0;
					ELIF cDescFijoMovil = 'MOVIL' THEN
						LET iFijoMovil1 = 1;
					ELSE
						LET iFijoMovil1 = 0;
					END IF;
				END IF;
				
				IF pTelefono2 <> '' THEN
					-- // VERIFICA SI ES MOVIL O FIJO   
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono2) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil2;
					LET pTipoTel2 = 'C';
					IF cDescFijoMovil = 'FIJO' THEN
						LET iFijoMovil2 = 0;
					ELIF cDescFijoMovil = 'MOVIL' THEN
						LET iFijoMovil2 = 1;
					ELSE
						LET iFijoMovil2 = 0;
					END IF;
				END IF;
				
				IF pTelefono3 <> '' THEN
					-- // VERIFICA SI ES MOVIL O FIJO   
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono3) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil3;
					LET pTipoTel3 = 'O';
					IF cDescFijoMovil = 'FIJO' THEN
						LET iFijoMovil3 = 0;
					ELIF cDescFijoMovil = 'MOVIL' THEN
						LET iFijoMovil3 = 1;
					ELSE
						LET iFijoMovil3 = 0;
					END IF;
				END IF;
				
				UPDATE {+INDEX ("informix".si_refdirecciones idx_si_refdirecciones)} "informix".si_refdirecciones SET
					(calle,colonia,entre_calles,
					pais,estado,ciudad,municipio,cod_postal,apart_postal,
					estado_inegi,municipio_inegi,localidad_inegi,
					numerociudad,numeroextcalle,numerointcalle,departamento,
					numerocalle,numerocolonia,puntocardinal,unidadhabitac,
					manzana,otros,andador,etapa,lote,edIFicio,entrada,observaciones,
					user_insert,fecha_insert,numcte_banco,movil_fijo1,movil_fijo2,movil_fijo3) = 
					(NVL(pCalle,''), NVL(pColonia,''), NVL(pEntreCalles,''),
					NVL(pPais,''),NVL(pEntidad,''),NVL(pLocalidad,''), NVL(pMunicipio,''), NVL(pCodPostal,''),"",
					NVL(pEstadoInegi,''),NVL(pMunicipioInegi,''),NVL(pLocalidadInegi,''),
					NVL(pNoCiudad,0),NVL(pNoExt,''),NVL(pNoInt,''),NVL(pDepto,''),
					NVL(pNoCalle,0),NVL(pNoColonia,0),NVL(pPuntocar,''),NVL(pUniHabi,''),
					NVL(pManz,0),NVL(pPotros,0),NVL(pAndador,0),NVL(pEtapa,0),NVL(pLote,0),NVL(pEdif,0),NVL(pEntrada,0),NVL(pObserva,''),
					NVL(pUserInsert,''),pFechaInsert,NVL(pNumCteBanco,''),iFijoMovil1,iFijoMovil2,iFijoMovil3)
					WHERE numcte = pNumCte
					AND secuencia = pSecuencia;
				
			ELIF pTipo = '0' THEN 
				IF pTelefono1 <> '' THEN
					-- // VERIFICA SI ES MOVIL O FIJO   
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono1) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil1;
					LET pTipoTel1 = 'P';
					IF cDescFijoMovil = 'FIJO' THEN
						LET iFijoMovil1 = 0;
					ELIF cDescFijoMovil = 'MOVIL' THEN
						LET iFijoMovil1 = 1;
					ELSE
						LET iFijoMovil1 = 0;
					END IF;
				END IF;

				IF pTelefono2 <> '' THEN
					-- // VERIFICA SI ES MOVIL O FIJO   
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono2) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil2;
					LET pTipoTel2 = 'C';
					IF cDescFijoMovil = 'FIJO' THEN
						LET iFijoMovil2 = 0;
					ELIF cDescFijoMovil = 'MOVIL' THEN
						LET iFijoMovil2 = 1;
					ELSE
						LET iFijoMovil2 = 0;
					END IF;
				END IF;

				IF pTelefono3 <> '' THEN
					-- // VERIFICA SI ES MOVIL O FIJO   
					EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono3) INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil3;
					LET pTipoTel3 = 'O';
					IF cDescFijoMovil = 'FIJO' THEN
						LET iFijoMovil3 = 0;
					ELIF cDescFijoMovil = 'MOVIL' THEN
						LET iFijoMovil3 = 1;
					ELSE
						LET iFijoMovil3 = 0;
					END IF;
				END IF;

				--INSERT INTO bdinteg:"informix".si_refdirecciones
				--	(numcte,secuencia,tipo_dir,tipo_telef1,telefono1,tipo_telef2, telefono2,tipo_telef3, telefono3, extension)
				--VALUES
				--	(pNumCte,pSecuencia,pTiipoDir,pTipoTel1,pTelefono1,pTipoTel2,pTelefono2,pTipoTel3,pTelefono3,pExtension);				
				

				INSERT INTO "informix".si_refdirecciones
					(numcte, secuencia, tipo_dir, calle, colonia, entre_calles,
					pais, estado, ciudad, municipio, cod_postal, apart_postal,
					tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3,
					extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, 
					numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
					puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, 
					entrada, observaciones, numcte_banco, user_insert, fecha_insert, movil_fijo1, status_stel1, 
					movil_fijo2, status_stel2 , movil_fijo3, status_stel3 )
				VALUES
					(pNumCte, pSecuencia, pTiipoDir, NVL(pCalle,''), NVL(pColonia,''), NVL(pEntreCalles,''), 
					NVL(pPais,''), NVL(pEntidad,''), NVL(pLocalidad,''), NVL(pMunicipio,''), NVL(pCodPostal,''), "", 
					pTipoTel1, pTelefono1, pTipoTel2, pTelefono2, pTipoTel3, pTelefono3, 
					pExtension, NVL(pEstadoInegi,''), NVL(pMunicipioInegi,''), NVL(pLocalidadInegi,''), NVL(pNoCiudad,0), 
					NVL(pNoExt,''), NVL(pNoInt,''), NVL(pDepto,''), NVL(pNoCalle,0), NVL(pNoColonia,0), NVL(pPuntocar,''), 
					NVL(pUniHabi,''), NVL(pManz,0), NVL(pPotros,0), NVL(pAndador,0), NVL(pEtapa,0), NVL(pLote,0), NVL(pEdif,0), 
					NVL(pEntrada,0), NVL(pObserva,''), NVL(pNumCteBanco,''), NVL(pUserInsert,''), CURRENT, iFijoMovil1, '', iFijoMovil2 , '', iFijoMovil3, '');
				
			END IF;
			RETURN cCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'DOCUMENTACION:',
'RealizÃ?Â³: Martha Aguirre',
'Fecha: 31/01/2009',
'Funcionalidad: Inserta en la tabla si_refdirecciones las direcciones de las referencias de los clientes solicitantes de Credito',
'------------------------------------------------------------------------------------------------------------------------------------',
'Realizo: Rodolfo Tortolero Varela',
'Fecha: 28/09/2011',
'Funcionalidad: Cuando el pTipo = 0, Validar los campos para que no se inserten nulos',
'------------------------------------------------------------------------------------------------------------------------------------',
'Modifico: Claudio Almodovar',
'Fecha: 19/04/2013',
'BDD: bdinteg',
'Descripcion: Se modifica UPDATE E INSERT para agregar parametros iFijoMovil1, iFijoMovil2, iFijoMovil3',
'------------------------------------------------------------------------------------------------------------------------------------',
'Modifico: Rodolfo Tortolero Varela',
'Fecha: 10/06/2013',
'BDD: bdinteg',
'Descripcion: Se agrega validacion para validar de acuerdo a la descripcion obtenida: ',
'             Si cDescFijoMovil es "FIJO"  - iFijoMovil1, iFijoMovil2, iFijoMovil3 = 0 ',
'             Si cDescFijoMovil es "MOVIL" - iFijoMovil1, iFijoMovil2, iFijoMovil3 = 1 ';

CREATE PROCEDURE "informix".sp_registra_sitespcte_web(pEmpresa Char(4),pCteNvo CHAR(20),pOperador CHAR(8), pSituacionNva CHAR(1),pCausaNva smallint,pSucursal char(4))
RETURNING 	CHAR (5);

	
	DEFINE cCodRet           		CHAR (5);  
    DEFINE iSqlErr           		INTEGER;
    DEFINE cSitActual        		CHAR(1);
    DEFINE sCausaActual      		SMALLINT;    
    DEFINE cNombre         			CHAR(45);  
    DEFINE sPondeAct         		SMALLINT;  
    DEFINE sPondeNvo         		SMALLINT;
	DEFINE iSitEspCte				INTEGER;

	DEFINE cEmpresa	     		char(3);	
	DEFINE cNumcte			 	char(20);
	DEFINE cSituacion		 	char(1);
	DEFINE sCausa			 	smallint;
	DEFINE cCvesitesporigen 	char(12);
	DEFINE cSucursal	     	char(4);
	DEFINE cTipomovto	     	char(1);
	DEFINE cEmpleadoefectuo 	char(8);
	DEFINE cNombreefectuo	 	char(40);
	DEFINE dFechamovto			datetime year to second;
	DEFINE cUsralta				char(8);
	DEFINE dFchalta				datetime year to second;
	DEFINE cUsrmodifica			char(8);
	DEFINE dFchmodifica			datetime year to second;
	DEFINE cMotivo_desmarcaje	char(100);
	DEFINE cNombreOperador      CHAR(45);
	
	LET cEmpresa	    	='';
	LET cNumcte				='';
	LET cSituacion			='';
	LET sCausa				=0;
	LET cCvesitesporigen	='';
	LET cSucursal	    	='';
	LET cTipomovto	    	='';
	LET cEmpleadoefectuo	='';
	LET cNombreefectuo		='';
	LET dFechamovto			='';
	LET cUsralta	 		='';		
	LET cUsrmodifica		='';		
	LET dFchmodifica		='';
	LET cMotivo_desmarcaje	='';
	LET cNombreOperador     ='';
	                       	
	-- INICILIZA VARIABLES --
	LET cCodRet  			= '00000';
	
    LET iSqlErr  			= 0;
    LET cSitActual  		= '';
    LET sCausaActual		= 0;
    LET cNombre	  			= '';
    LET sPondeAct	  		= 0;
    LET sPondeNvo	  		= 0;
	LET iSitEspCte 			= 0;
	
	
--	SET DEBUG FILE TO '/home/sysifx/viridiana/SP_REGISTRA_SITESPCTE.out';
--	TRACE ON;		
BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;	
				RETURN TRIM(cCodRet);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--consultar el nombre del ejecutivo
		SELECT nombre
		INTO cNombreOperador
		FROM "informix".si_ejecut WHERE ejecutivo = pOperador;
			
		LET pCteNvo = TRIM(pCteNvo);
		
		SELECT COUNT(numcte)
		INTO iSitEspCte		
		FROM bdisitesp:"informix".se_ctessitespcte 
		WHERE numcte = pCteNvo;
		
		IF iSitEspCte > 0 THEN
			
			--OBTIENE PONDERACION CLIENTE NUEVO
			SELECT ponderacion
			INTO sPondeNvo
			FROM bdisitesp:"informix".se_catsitesp
			WHERE situacion = pSituacionNva
			AND causa = pCausaNva;
			
			-- PONDERACION ACTUAL
			SELECT ponderacion
			INTO sPondeAct 
			FROM bdisitesp:"informix".se_catsitesp a inner join bdisitesp:"informix".se_ctessitespcte b
			on a.situacion=b.situacion and a.causa=b.causa 
			WHERE b.numcte=pCteNvo;
			
			--SI LA NUEVA ES MAYOR QUE LA ACTUAL SE QUEDA IGUAL CON EL REGISTRO VIEJO
			-- 
			IF sPondeNvo < sPondeAct THEN  
					
				INSERT INTO bdisitesp:"informix".se_ctessitespcte_his(tipomovto,numcte,empresa,situacion,causa,cvesitesporigen,sucursal,empleadoefectuo,usralta,fchalta,usrmodifica,fchmodifica)
				
				SELECT  tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica
				FROM bdisitesp:"informix".se_ctessitespcte
				WHERE numcte=pCteNvo;
				
				LET pOperador = TRIM(pOperador);
				LET pCteNvo = TRIM(pCteNvo);
				LET cNombre = TRIM(cNombre);
				
				--ACTUALIZA SITUACION ESPECIAL EN LA TABLA BDISITESP:"INFORMIX".SE_CTESSITESPCTE 
				UPDATE bdisitesp:"informix".se_ctessitespcte
				SET situacion = cSitActual, causa = sCausaActual, empleadoefectuo = pOperador , nombreefectuo = cNombre,fechamovto = CURRENT YEAR TO SECOND, usrmodifica= pOperador, fchmodifica = CURRENT YEAR TO SECOND
				WHERE numcte = pCteNvo;
				
			--en caso de que tenga ya una situacion especial y si ambas tienen la misma ponderacion se deja la actual y 
			--la nueva se va al historico
			
				ELIF  sPondeNvo = sPondeAct THEN
					INSERT INTO bdisitesp:"informix".se_ctessitespcte_his (tipomovto,numcte,empresa,situacion,causa,cvesitesporigen,sucursal,empleadoefectuo,usralta,fchalta,usrmodifica,fchmodifica) 
					VALUES ('1',pCteNvo,pEmpresa,pSituacionNva,pCausaNva,'5',pSucursal,pOperador,pOperador,current,pOperador,current);
		
			END IF;
			
		ELSE
		
			-- SE INSERTA EL CLIENTE NUEVO.
			INSERT INTO bdisitesp:"informix".se_ctessitespcte (empresa,numcte,situacion,causa,cvesitesporigen,sucursal,tipomovto,empleadoefectuo,nombreefectuo,fechamovto,usralta,fchalta,usrmodifica,fchmodifica,motivo_desmarcaje)
			VALUES (pEmpresa,pCteNvo,pSituacionNva,pCausaNva,'5',pSucursal,'1',pOperador,cNombreOperador,current,pOperador,current,'',current,'');
			
		END IF;

		RETURN TRIM(cCodRet);
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento encargado de registrar la situacion especial del cliente' ,
'AUTOR: Viridiana Paredes R.',   
'FECHA DE CREACION:01/08/18 ',
'FOLIO: 420',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_registra_telefonos_web( pEmpresa     CHAR(3),
                                                   pNumCte      CHAR(20), 
                                                   pTelefono    CHAR(13),
                                                   pTipoTel     SMALLINT,
                                                   pExtension   CHAR(5),
                                                   pCarrier     SMALLINT,
                                                   pCanal       SMALLINT,
                                                   pUserInsert  CHAR(8) )
	RETURNING CHAR(5) AS cCodRet1;
    
	--DEFINICION DE VARIABLES
    DEFINE cCodRet1 		CHAR(5);
    DEFINE cCodRet2 		CHAR(5);
    DEFINE cCodRet3 		CHAR(50);
    DEFINE iSqlErr  		INTEGER;
    DEFINE iSamErr  		INTEGER;
    DEFINE cDesErr  		CHAR(50);
    DEFINE iExisteCte       INTEGER;
    DEFINE iExisteCanal     INTEGER;
    DEFINE cCodRetValTel    CHAR(5);
    DEFINE cValCasa         CHAR(1);
    DEFINE cValCelular      CHAR(1);
    DEFINE cValOficina      CHAR(1);
    DEFINE cCofetel         CHAR(1);
    DEFINE iExisteCarrier   INTEGER;
    DEFINE dFechaInsert		DATE;
    DEFINE sMaxSecTel       SMALLINT;
    DEFINE sContacto        SMALLINT;
    DEFINE iSecMaxDir       INTEGER;
    DEFINE iExisteTelefono  INTEGER;
    DEFINE iFijoMovil  		INTEGER;
    DEFINE cDescFijoMovil  	CHAR(5);
    DEFINE cResulFijoMovil	CHAR(5);
	DEFINE cVerificado		CHAR(1);
    DEFINE iTelInvalido     INTEGER;
	DEFINE vmarcatel        CHAR(1);
	DEFINE vfecha_actualiza DATE; 
	DEFINE v_tel_confirmado CHAR(1);
	DEFINE vfech_confirmado DATE;
    DEFINE iDiasVerificado  INTEGER;
    DEFINE iDiasPeriodo     INTEGER;
    DEFINE sSucursal        CHAR(4);
    DEFINE iValidaDias      INTEGER;
	DEFINE iValidaDiasTu    INTEGER;
	DEFINE iTelValidado   	INTEGER;
	DEFINE iTelNoValidado   INTEGER;
	DEFINE iDiasDiff        INTEGER;
	DEFINE iDiasDiffTu      INTEGER;
    DEFINE nrows            SMALLINT;
    DEFINE cTelval          CHAR(13);
	DEFINE cCodRetSp        CHAR(5);
	DEFINE sLimitNumFijo    SMALLINT;
	DEFINE sCoincideNumFijo SMALLINT;
	DEFINE iRegistros		SMALLINT;
    DEFINE iRegistrosCanc   SMALLINT;
	DEFINE status_telefono  CHAR(1);
	DEFINE iTelCta          INTEGER;
	DEFINE iSucSMS          INTEGER;
	DEFINE vNumCteSMS       CHAR(20);
	
    DEFINE cCodRetSp2       CHAR(5);
    DEFINE correoCli        CHAR(100);
    DEFINE celularCli       CHAR(13);
	DEFINE contTel          INTEGER;
	DEFINE UserOnline		CHAR(8);
		
	DEFINE iNviejo          SMALLINT; --EPG 021621	
	
	--INICIALIZA VARIABLES
    LET cCodRet1		= '00000';
    LET cCodRet2		= '';
    LET cCodRet3		= '';
    LET iSqlErr			= 0;
    LET iSamErr			= 0;
    LET cDesErr			= '';
    LET iExisteCte		= 0;
    LET iExisteCanal	= 0;
    LET cCodRetValTel	= '';
    LET cValCasa		= '';
    LET cValCelular		= '';
    LET cValOficina		= '';
    LET cCofetel		= '';
    LET iExisteCarrier	= 0;
    LET dFechaInsert	= '';
    LET sMaxSecTel		= 0;
    LET sContacto		= 0;
    LET iSecMaxDir		= 0;
    LET iExisteTelefono	= 0;
    LET iFijoMovil		= 0;
    LET cDescFijoMovil	= '';
    LET cResulFijoMovil	= '';
	LET cVerificado		= 'F';
    LET iTelInvalido    = 0;
	LET vmarcatel       = '';
	LET vfecha_actualiza = ''; 
	LET v_tel_confirmado = '';
	LET vfech_confirmado = '';
    LET iDiasVerificado  = 0;
    LET iDiasPeriodo     = 0;
    LET sSucursal        ='0000';
	LET iValidaDias      = 0;
	LET iValidaDiasTu    = 0;
	LET iDiasDiff        = 0;
	LET iDiasDiffTu      = 0;
	LET iTelValidado	 = 0;
	LET iTelNoValidado   = 0;
    LET nrows            = 0;
    LET cTelval          = '';
    LET cCodRetSp        = '00000';
	LET sLimitNumFijo    = 0;
	LET sCoincideNumFijo = 0;
	LET iRegistros		 = 0;
    LET iRegistrosCanc   = 0;
	LET status_telefono  = '';
	LET iTelCta          = 0;
	LET iSucSMS          = 0;
	LET vNumCteSMS 		 = '';
	
	LET cCodRetSp2     = '00000';
	LET correoCli      ='';
	LET celularCli     ='';
	LET contTel        =0;
	LET UserOnline		="";
	
	LET iNviejo         = '0'; --EPG 021621		
	--SET DEBUG FILE TO "/informix/EPG/sp_registra_telefonos.out";
	--TRACE ON;	
    BEGIN
	    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_telefonos.err";
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;    

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET sSucursal=(select first 1 sucursal from "informix".si_ejecut where ejecutivo=pUserInsert);

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR (pNumCte is null OR pNumCte = '') OR
       (pTelefono is null OR pTelefono = '') OR (pTipoTel is null OR pTipoTel = 0) OR
       (pCarrier is null) OR (pCanal is null OR pCanal = 0) OR
       (pUserInsert is null OR pUserInsert = '') THEN
        LET cCodRet1 = '00110';
        RETURN cCodRet1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO iExisteCte
      FROM "informix".si_cliente
     WHERE numcte = pNumCte;
     
    IF iExisteCte = 0 THEN
        LET cCodRet1 = '00104';
        RETURN cCodRet1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO PARA EL TIPO INDICADO
    SELECT COUNT(*)
      INTO iExisteTelefono
      FROM "informix".si_telefonos_actual
     WHERE numcte = pNumCte
       AND tipo_tel = pTipoTel
       AND telefono = pTelefono;
       
    IF iExisteTelefono > 0 THEN
        LET cCodRet1 = '00999'; 
    END IF;
    
	--Valida que el nÃºmero en cuestion no este registrado para ese cliente, pero con otro tipo de telÃ©fono
	IF pTipoTel IN (1, 2) THEN					   
		SELECT COUNT(*)
		INTO iExisteTelefono
		FROM "informix".si_telefonos
		WHERE numcte = pNumCte
		AND tipo_tel != pTipoTel
		AND telefono = pTelefono
		AND status_tel = 'A'
		AND tipo_tel IN (1,2)
		;

		IF iExisteTelefono > 0 THEN
			LET cCodRet1 = '02861';
			RETURN cCodRet1;
		END IF;
	END IF;
	
    -- // VALIDA EL CANAL DE PROCEDENCIA
    SELECT COUNT(*)
      INTO iExisteCanal
    FROM "informix".si_canal
    WHERE cve_canal = pCanal;
     
    IF iExisteCanal = 0 THEN
        LET cCodRet1 = '00104';
        RETURN cCodRet1;
    END IF;
	
	SELECT valor INTO UserOnline FROM bdinteg:si_param where cod_param = 481;
		
	IF UserOnline=pUserInsert THEN
		LET cVerificado='V';
	END IF;
		
	SELECT telefono  --Obtiene el numero viejo del celular del cliente
	INTO celularCli 
	FROM bdinteg:"informix".si_telefonos 
	WHERE numcte = pNumCte	AND tipo_tel='2' AND status_tel='A'; 
	
	LET iNviejo = dbinfo("sqlca.sqlerrd2");	 --EPG 021621	
	
	SELECT COUNT(*) INTO contTel 
	FROM bdinteg:"informix".si_telefonos 
	WHERE numcte=pNumCte AND tipo_tel=2 AND status_tel='A';

    
    -- // VALIDA EL CARRIER PARA NUMEROS CELULARES
    IF pCarrier > 0 THEN
        SELECT COUNT(*)
          INTO iExisteCarrier
        FROM "informix".si_carriers
        WHERE cve_carrier = pCarrier;
         
        IF iExisteCarrier = 0 THEN
            LET cCodRet1 = '00104';
            RETURN cCodRet1;
        END IF;
    END IF;
    
    -- // VALIDA SI EL TELEFONO ES VALIDO PARA COFETEL
    EXECUTE PROCEDURE "informix".sp_validatelefono(pEmpresa, pTelefono, pTelefono, pTelefono)
    INTO cCodRetValTel, cValCasa, cValCelular, cValOficina;
    
    IF cValCasa = '1' OR cValCelular = '1' OR cValOficina = '1' THEN
        LET cCofetel = 'V';
    ELSE
        LET cCofetel = 'F';
    END IF;
    
    -- // VALIDA EL TELEFONO EN TABLA DE TELEFONOS INVALIDOS
    SELECT COUNT(*)
      INTO iTelInvalido
      FROM "informix".si_telefonos_invalidos
     WHERE telefono = pTelefono;
     
    IF iTelInvalido > 0 THEN
        LET cCodRet1 = '00104'; 
        RETURN cCodRet1;
    END IF; 	
	
	-- //SI ES NUMERO FIJO VALIDA QUE NO EXCEDA EL LIMITE DE REGISTROS PERMITIDOS - LIPC
	IF pTipoTel = '1' THEN
		SELECT valor INTO sLimitNumFijo FROM "informix".si_param WHERE cod_param='462'; 
		SELECT COUNT(telefono) INTO sCoincideNumFijo FROM "informix".si_telefonos_actual WHERE telefono=pTelefono AND tipo_tel='1' AND status_tel='A' AND numcte != pNumCte;
			
		IF sCoincideNumFijo >= sLimitNumFijo THEN
			LET cCodRet1 = '01167'; 
			RETURN cCodRet1;
		END IF;
		
	END IF;
	
	SELECT valor INTO iValidaDias FROM "informix".si_param WHERE cod_param='455';
    SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiff FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND user_insert='transBPI' AND numcte != pNumCte;
	
    IF iDiasDiff<=iValidaDias THEN
        LET cCodRet1 = '01165'; 
        RETURN cCodRet1;
    END IF;

	--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE - LIPC
	IF pTipoTel = '2' THEN
		SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
		SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

		IF iDiasDiffTu<=iValidaDiasTu THEN
			LET iTelValidado = 1;
			LET cCodRet1 = '01168'; 
			RETURN cCodRet1;
		ELSE
			LET iTelValidado = 0;
		END IF;
	END IF;
	
	--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE (CONSIDERANDO CAMPO FECHA_ACTUALIZA) - LIPC
	IF pTipoTel = '2' THEN
		SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
		SELECT DATE(CURRENT) - DATE(MAX(fecha_actualiza)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

		IF iDiasDiffTu<=iValidaDiasTu THEN
			LET iTelValidado = 1;
			LET cCodRet1 = '01168'; 
			RETURN cCodRet1;
		ELSE
			LET iTelValidado = 0;
		END IF;
	END IF;
	
	--SE VALIDA QUE EL TELEFONO ESTA REGISTRADO PERO NO HA SIDO VALIDADO POR OTRO CLIENTE - LIPC
	IF pTipoTel = '2' THEN
		SELECT COUNT(telefono) INTO iTelNoValidado
		FROM "informix".si_telefonos 
		WHERE telefono=pTelefono 
		AND tipo_tel='2' 
		AND status_tel='A' 
		AND verificado != 'V'
		AND numcte != pNumCte;
		   
		IF iTelNoValidado > 0 THEN
			LET cCodRet1 = '01166'; 
			--RETURN cCodRet1;
		END IF;
	END IF;
	
	--EN EL MANTENIMIENTO DE DATOS SE VALIDA SI EL NUMERO CELULAR DEL CLIENTE ESTA CANCELADO - LIPC
	IF pTipoTel = '2' THEN
		SELECT COUNT(telefono) INTO iRegistros
		FROM "informix".si_telefonos 
		WHERE numcte = pNumCte 
		AND tipo_tel = '2' 
		AND telefono = pTelefono
		AND status_tel = 'C'
		AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_telefonos WHERE numcte = pNumCte 
		AND tipo_tel = '2' 
		AND telefono = pTelefono);
			
		IF (iRegistros > 0 AND iTelValidado > 0) THEN
			LET cCodRet1 = '01169';
			RETURN cCodRet1;
		END IF;
	END IF;
	
    LET sSucursal=(select first 1 sucursal from "informix".si_ejecut where ejecutivo=pUserInsert);
			
	SELECT COUNT(*) INTO iSucSMS FROM "informix".si_sucvalidasms WHERE sucursal=sSucursal AND activo='1';
    IF iSucSMS > 0 THEN

        -- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS (PARAMETRO 384 SI_PARAM)
		SELECT valor INTO iDiasVerificado FROM "informix".si_param WHERE cod_param='384';
		SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasPeriodo FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND user_insert='transBPI' AND numcte != pNumCte;

		IF iDiasPeriodo<=iDiasVerificado THEN
			LET cCodRet1 = '01163'; 
			RETURN cCodRet1;
		END IF;
		
		--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE - LIPC
		IF pTipoTel = '2' THEN
			SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
			SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

			IF iDiasDiffTu<=iValidaDiasTu THEN
				LET iTelValidado = 1;
				LET cCodRet1 = '01168'; 
				RETURN cCodRet1;
			ELSE
				LET iTelValidado = 0;
			END IF;
		END IF;
			
		--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE (CONSIDERANDO CAMPO FECHA_ACTUALIZA) - LIPC
		IF pTipoTel = '2' THEN
			SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
			SELECT DATE(CURRENT) - DATE(MAX(fecha_actualiza)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

			IF iDiasDiffTu<=iValidaDiasTu THEN
				LET iTelValidado = 1;
				LET cCodRet1 = '01168'; 
				RETURN cCodRet1;
			ELSE
				LET iTelValidado = 0;
			END IF;
		END IF;

			
		--SE VALIDA QUE EL TELEFONO ESTA REGISTRADO PERO NO HA SIDO VALIDADO POR OTRO CLIENTE - LIPC
		IF pTipoTel = '2' THEN
			SELECT COUNT(telefono) INTO iTelNoValidado
			FROM "informix".si_telefonos
			WHERE telefono=pTelefono 
			AND tipo_tel='2' 
			AND status_tel='A' 
			AND verificado != 'V'
			AND numcte != pNumCte;
		   
			IF iTelNoValidado > 0 THEN
				LET cCodRet1 = '01166'; 
				--RETURN cCodRet1;
			END IF;
		END IF;
			
		--EN EL MANTENIMIENTO DE DATOS SE VALIDA SI EL NUMERO CELULAR DEL CLIENTE ESTA CANCELADO - LIPC
		IF pTipoTel = '2' THEN
			SELECT COUNT(telefono) INTO iRegistros
			FROM "informix".si_telefonos 
			WHERE numcte = pNumCte 
			AND tipo_tel = '2' 
			AND telefono = pTelefono
			AND status_tel = 'C'
			AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_telefonos WHERE numcte = pNumCte 
			AND tipo_tel = '2' 
			AND telefono = pTelefono);
		
			IF (iRegistros > 0 AND iTelValidado > 0) THEN
				LET cCodRet1 = '01169';
				RETURN cCodRet1;
			END IF;
		END IF;
        

	-- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO ASOCIADO A UNA CUENTA, TABLA SC_CUENTA_TELEFONO
		SELECT COUNT(*) INTO iTelCta FROM bdicheq:"informix".sc_cuenta_telefono WHERE telefono=pTelefono and num_cte<>pNumCte;
		IF iTelCta > 0 THEN
			LET cCodRet1 = '01164'; 
			RETURN cCodRet1;
		END IF;
	-- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO ASOCIADO A UNA CUENTA, TABLA SC_CUENTA_TELEFONO
    END IF;

    -- // OBTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO dFechaInsert
    FROM "informix".si_fechas
    WHERE empresa = pEmpresa;
    
    -- // INSERTA EN TABLA DE TELEFONOS
    SELECT MAX(secuencia)
      INTO sMaxSecTel
    FROM "informix".si_telefonos
    WHERE numcte = pNumCte;
             
    IF sMaxSecTel is null OR sMaxSecTel = '' THEN
        LET sMaxSecTel = 0;
    END IF;
    
    LET sMaxSecTel = sMaxSecTel + 1;	
		
	IF(cCodRet1 != '00999') THEN
		UPDATE "informix".si_telefonos
		   SET status_tel = 'C'
		 WHERE numcte = pNumCte
		   AND tipo_tel = pTipoTel;
	END IF;	
	
    -- // VERIFICA SI ES MOVIL O FIJO   
    EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono) 
    INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil;
    
    IF cDescFijoMovil = 'FIJO' THEN
        LET iFijoMovil = 0;
    ELIF cDescFijoMovil = 'MOVIL' THEN
        LET iFijoMovil = 1;
    ELSE
        LET iFijoMovil = 0;
    END IF;
    
    --// Valida si existe mas de un cliente con el mismo celular para enviarle sms
    FOREACH
        SELECT telefono,numcte INTO cTelval,vNumCteSMS FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND numcte<>pNumCte
        LET nrows = dbinfo("sqlca.sqlerrd2");
        IF(nrows > 0) THEN
            --EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_AVSMS','ACT_CEL',vNumCteSMS,'','','1','','','','','','','','','','','',pTelefono,1,0,0,0,0,'','') INTO cCodRetSp;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXIT FOREACH;
        END IF;
    END FOREACH;
    --//
	
	IF(cCodRet1 != '00999') THEN
		INSERT INTO si_telefonos
		( empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza, tel_confirmado, fech_confirmado)
		VALUES
		( pEmpresa, pNumCte, pTelefono, pTipoTel, 'A', sMaxSecTel, pExtension, pCarrier, pCanal, sContacto, cCofetel, CURRENT, pUserInsert, iFijoMovil, '', cVerificado, vmarcatel, vfecha_actualiza, v_tel_confirmado, vfech_confirmado);
		
		IF (sMaxSecTel > 1 AND pTipoTel = 2 AND contTel>=1 AND celularCli <> pTelefono) THEN
			--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,'','') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_registra_telefonos_cub', pTelefono,'Nuevo') INTO cCodRetSp2;--SPL de prueba

			IF (iNviejo > 0) THEN --EPG 021621
				--INFORMAMOS ACTUALIZACION DE TELEFONO SI TIENE UN TELEFONO VIEJO
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(celularCli),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
				--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_registra_telefonos_cub', celularCli,'Viejo') INTO cCodRetSp2; --SPL de prueba
			END IF;              --EPG 021621	
		END IF;	
	ELSE
		LET cCodRet1 = '00000';
	END IF;	
    RETURN cCodRet1;	
	END;    
END PROCEDURE
DOCUMENT
'Modifico: Claudio Almodovar',
'Fecha: 19/04/2013',
'BDD: bdinteg',
'Descripcion: Llamado al sp_tipored para saber si es Fijo o Movil',
'             iFijoMovil = 0 - Si el telefono es Fijo',
'             iFijoMovil = 1 - Si el telefono es Movil',
'',
'Modifico: Rodolfo Tortolero Varela',
'Fecha: 10/06/2013',
'             Si cDescFijoMovil es "FIJO"  - iFijoMovil = 0 ',
'             Si cDescFijoMovil es "MOVIL" - iFijoMovil = 1 ';

CREATE PROCEDURE "informix".sp_elimina_referencias_duplicadas_web(pEmpresa CHAR(3), pNum_solicitud CHAR(20), pNumCte CHAR(20))
RETURNING CHAR(5)  AS cCodRet;
			
--Declaracion de variables-------------------------------------------------------- 
DEFINE iSqlErr				INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE iContador			INTEGER;
DEFINE iSecuencia			INTEGER;
DEFINE cNumSolicitud		CHAR(20);
DEFINE cNumCte				CHAR(20);
DEFINE cNombre				CHAR(26);
DEFINE cNomobreDos			CHAR(26);
DEFINE cApellP				CHAR(26);
DEFINE cApellM				CHAR(26);

--Inicializacion de Variables----------------------------------------------------- 
LET iSqlErr					= 0;
LET cCodRet 				= '00001';
LET iContador 				= 0;
LET iSecuencia 				= 0;
LET cNumSolicitud			= '';
LET cNumCte					= '';
LET cNombre					= '';
LET cNomobreDos				= '';
LET cApellP					= '';
LET cApellM					= '';

	--SET DEBUG FILE TO '/home/sp_elimina_referencias_duplicadas_web.out';
	--TRACE ON;
	BEGIN 

		ON EXCEPTION SET iSqlerr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF TRIM(pEmpresa) <> '' AND TRIM(pNum_solicitud) <> '' AND TRIM(pNumCte) <> '' THEN
			FOREACH
				SELECT num_solicitud, numcte, MAX(secuencia), apell_paterno, apell_materno, nombre1, nombre2, COUNT(*)
					INTO cNumSolicitud, cNumCte, iSecuencia, cApellP, cApellM, cNombre, cNomobreDos, iContador
					FROM "informix".si_refclientes
					WHERE empresa = pEmpresa
						AND num_solicitud = pNum_solicitud
						AND numcte = pNumCte
						GROUP BY num_solicitud, numcte, apell_paterno, apell_materno, nombre1, nombre2
					HAVING COUNT(*) > 1
					
				IF iContador > 1 THEN
					DELETE FROM "informix".si_refclientes
						WHERE empresa = pEmpresa
						AND secuencia = iSecuencia
						AND num_solicitud = pNum_solicitud
						AND numcte = pNumCte;
						
						LET cCodRet	= '00000';
				END IF;				
			END FOREACH
		ELSE
			LET cCodRet	= '00002';
		END IF;		
		RETURN cCodRet;	
	END
END PROCEDURE
DOCUMENT
'ModificÃ³: 97879606 - AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'Folio: 622.1',
'Fecha: 21/10/2019',
'ModificaciÃ³n: Se genera Procedimiento Almacenado para eliminar las referencias repetidas generadas en prospecteo',
'Solicita: Rodolfo GÃ³mez', 
'Base de datos: BDINTEG';

CREATE PROCEDURE "informix".sp_elimina_referencias_web(pEmpresa CHAR(3),
														pNumSolicitudActualbco CHAR(20) ,
														pNumcte CHAR(20),
														pNumSolicitudActualcpl CHAR(20)
														)

--RETORNOS-
RETURNING
CHAR(5)  AS codigo_ret;

--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(5);
DEFINE iSql_err				    INTEGER;
DEFINE iIsamErr                 INTEGER;
DEFINE iBandera                 INTEGER;
DEFINE iBandera1                INTEGER;
DEFINE sSecuencia               INTEGER;


--INICIALIZACION DE VARIABLES--
LET cCodret                 = '00000'; --EJECUCION EXITOSA
LET iIsamErr                = 0;
LET iSql_err                = 0;
LET iBandera                = 0;
LET iBandera1               = 0;
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

	--SET DEBUG FILE TO '/home/sp_elimina_referencias.sql';
	--TRACE ON;

	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;

	
	 IF ( pNumSolicitudActualbco = '' AND pNumSolicitudActualcpl = '') OR NVL(pEmpresa, '' ) = '' OR  NVL(pNumcte, '') = ''   THEN
		LET cCodret = '00001';
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

	 IF pNumSolicitudActualbco = pNumSolicitudActualcpl THEN
		LET iBandera1 = 0;
	 END IF;

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
		LET cCodret = '00002';
	END IF;

	RETURN TRIM(cCodret) ;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: PROCEDIMIENTO PARA OBTENER LA SOLICITUD, VALIDA PARA HEREDAR LA INFORMACION A LA SOLICITUD NUEVA',
'FECHA DE CREACION: 12 DE JULIO DE 2013',
'BASE DE DATOS: BDISOLIC',
'CREADOR: JESUS AGUILAR',
'VERSION: 201307121100';

CREATE PROCEDURE "informix".sp_guardabithbio_web(cNumCte CHAR(20), cSucursal CHAR(4), cNumUsuario CHAR(10), cIPMaquina CHAR(14), cTipoProceso CHAR(1), 
								 cNumGteAutoriza CHAR(10), cTipoIdent CHAR(1), cNumIdent CHAR(30))
RETURNING CHAR(5)    

DEFINE cCodRet  CHAR(5);
DEFINE iSqlErr	INTEGER;

LET cCodRet	= "00000";
LET iSqlErr = 1;

BEGIN	

	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
		--SET DEBUG FILE TO "/home/sysifx/Oscar/sp_guardabithbio_web.out";
		--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	IF (cNumCte = '' OR cNumCte IS NULL) OR (cSucursal = '' OR cSucursal IS NULL) OR (cNumUsuario = '' OR cNumUsuario IS NULL) OR (cIPMaquina = '' OR cIPMaquina IS NULL) 
		OR (cTipoProceso = '' OR cTipoProceso IS NULL) OR (cNumGteAutoriza = '' OR cNumGteAutoriza IS NULL) OR (cTipoIdent = '' OR cTipoIdent IS NULL) THEN
		LET cCodRet = '00001';
	ELSE				
		INSERT INTO bdinteg:"informix".si_bitmant_huellarostro(numcte, sucursal, ejecutivo, ip_maquina, fecha_hora, tipo_proceso, numgte_autoriza, tipo_ident, num_ident)
		VALUES(cNumCte, cSucursal, cNumUsuario, cIPMaquina, CURRENT, cTipoProceso, cNumGteAutoriza, cTipoIdent, cNumIdent);			
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Se crea SP para el guardado de bitacora al realizarce mantenimiento de huella y biometria facial del cliente de manera correcta',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 22/10/2019',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_insbitsmsmant_huellarostro_web(pOpcion CHAR(1),pNumTelefono CHAR(10), pEjecutivo CHAR(8), pCodigoGenerado CHAR(4), pCodigoTeclea CHAR(100), pSucursal CHAR(4), pNumCte CHAR(20))
RETURNING CHAR(5);


DEFINE iSqlErr		INTEGER;
DEFINE sCodRet		CHAR(5);
DEFINE cNumCte		CHAR(20);
DEFINE cTelefono	CHAR(10);
DEFINE iExiste      SMALLINT;
DEFINE iMinutos     INTEGER;
DEFINE iReintentos  INTEGER;
DEFINE iEnviados    INTEGER;
DEFINE iMinTrans    INTEGER;
DEFINE sDiferencia	CHAR(30);
DEFINE sCorreo		CHAR(100);
DEFINE cDif			CHAR(4);
DEFINE cNombreCliente VARCHAR(15);
DEFINE cApellidoCliente VARCHAR(15);
DEFINE cNombreCompletoCliente VARCHAR(30);
DEFINE cCodigoExiste CHAR(4);


LET iSqlErr = 0;
LET sCodRet = '00000';
LET cNumCte = '';
LET cTelefono = '';
LET iExiste     =   0;
LET iMinutos    =   0;
LET iReintentos =   0;
LET iEnviados   =   0;
LET iMinTrans   =   0;
LET sDiferencia =   '';
LET cDif 		=	'';
LET cNombreCliente = '';
LET cApellidoCliente = '';
LET cNombreCompletoCliente = '';
LET cCodigoExiste = '';

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET sCodRet = iSqlErr;
			RETURN sCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/home/sysifx/JesusRubio/627/sp_insbitsmsmant_huellarostro_web.out";
	--TRACE ON;
	
		IF pOpcion = '1' THEN
			
			SELECT FIRST 1 numcte INTO cNumCte FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte AND telefono = pNumTelefono AND DATE(fecha) = DATE(CURRENT);
			LET iExiste = dbinfo("sqlca.sqlerrd2");
		
			IF iExiste = 0 THEN
				INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, fecha)
				VALUES(pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, CURRENT);
			ELSE
				SELECT  FIRST 1 codigo_generado INTO cCodigoExiste FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte AND telefono = pNumTelefono AND DATE(fecha) = DATE(CURRENT);
				LET pCodigoGenerado = TRIM(cCodigoExiste);
			END IF;
			
			SELECT nombre1 INTO cNombreCliente FROM bdinteg:"informix".si_cliente where sucursal = pSucursal AND numcte = pNumCte;
			SELECT apell_paterno INTO cApellidoCliente FROM bdinteg:"informix".si_cliente where sucursal = pSucursal AND numcte = pNumCte;
			
			LET cNombreCompletoCliente = TRIM(cNombreCliente) || ' ' || TRIM(cApellidoCliente);
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','HUL_MANTTO','HUE_SMS','000000000','','','1',cNombreCompletoCliente, pCodigoGenerado,'','','','','','','','','',pNumTelefono,1,0,0,0,0,'','')
			INTO sCodRet;
			
			--OBTIENE CORREO DE CLIENTE
			SELECT FIRST 1 correo_elec INTO sCorreo FROM bdinteg:"informix".si_correos WHERE numcte = pNumCte AND status_correo='A';
			IF	NVL(sCorreo,'') <> '' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','HUL_MANT_E','HUE_EMAIL','000000000','','','1',cNombreCompletoCliente, pCodigoGenerado,'','','','','','','','',sCorreo,'',1,0,0,0,0,'','')
				INTO sCodRet;
			END IF;
			
		ELIF pOpcion = '2' THEN
			--INSERTA CODIGO INCORRECTO
			INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, codigo_tecleado, fecha)
			VALUES(pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, pCodigoTeclea, CURRENT);
			
		ELIF pOpcion = '3' THEN
			--ACTUALIZA CODIGO CORRECTO			
			SELECT FIRST 1 numcte INTO cNumCte FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte AND ejecutivo = pEjecutivo AND sucursal = pSucursal AND DATE(fecha) = DATE(CURRENT) AND pCodigoTeclea IS NULL;
			LET iExiste = dbinfo("sqlca.sqlerrd2");
			IF iExiste > 0 THEN
				UPDATE bdinteg:"informix".si_bitsmstels_huellarostro SET codigo_tecleado = pCodigoTeclea, fecha = CURRENT
				WHERE numcte = pNumCte AND ejecutivo = pEjecutivo AND sucursal = pSucursal AND DATE(fecha) = DATE(CURRENT) AND codigo_tecleado IS NULL;
			ELSE
				INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, codigo_tecleado, fecha)
				VALUES (pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, pCodigoTeclea, CURRENT);
			END IF;
		
		ELIF pOpcion = '4' THEN
			--REENVIO DE SMS
			--Minutos maximo para envio de sms
			SELECT TRIM(valor) INTO iMinutos FROM bdinteg:"informix".si_param WHERE cod_param = '382';
			--Intentos  maximos de reenvio de sms
			SELECT TRIM(valor) INTO iReintentos FROM bdinteg:"informix".si_param WHERE cod_param = '383';
			
			--Cantidad de reenvios por cliente al dia
			SELECT COUNT(*) INTO iEnviados 
			FROM bdinteg:"informix".si_bitsmstels_huellarostro 
			WHERE numcte = pNumCte
			AND telefono = pNumTelefono 
			AND TRIM(codigo_tecleado) = 'REENVIO SMS'
			AND DATE(fecha) = DATE(CURRENT);
			
			
			IF	iEnviados >= iReintentos THEN
				RETURN sCodRet;
			END IF;
			
			SELECT CURRENT-MAX(fecha) INTO sDiferencia
			FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte 
			AND telefono = pNumTelefono
			AND DATE(fecha) = DATE(CURRENT);
			
			IF LENGTH (TRIM(sDiferencia)) = 16 THEN
				LET cDif = SUBSTRING ((TRIM(sDiferencia)) FROM 8 FOR 2);
				SELECT cDif INTO iMinTrans FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
			ELIF LENGTH (TRIM(sDiferencia)) = 15 THEN
				LET cDif = SUBSTRING ((TRIM(sDiferencia)) FROM 7 FOR 2);
				SELECT cDif INTO iMinTrans FROM bdinteg:"informix".si_fechas WHERE empresa = '001'; 
			ELSE
				LET cDif = SUBSTRING ((TRIM(sDiferencia)) FROM 6 FOR 2);
				SELECT cDif INTO iMinTrans FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
			END IF;
			
			IF iMinTrans < iMinutos THEN
				RETURN sCodRet;
			END IF;			
			
			SELECT FIRST 1 numcte INTO cNumCte FROM bdinteg:"informix".si_bitsmstels_huellarostro WHERE numcte = pNumCte AND telefono = pNumTelefono AND codigo_tecleado IS NULL;
			LET iExiste = dbinfo("sqlca.sqlerrd2");
			IF iExiste > 0 THEN
				UPDATE bdinteg:"informix".si_bitsmstels_huellarostro SET codigo_tecleado = 'REENVIO SMS', fecha = CURRENT
				WHERE numcte = pNumCte AND telefono = pNumTelefono AND codigo_tecleado IS NULL;
			ELSE
				INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, codigo_tecleado, fecha)
				VALUES(pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, 'REENVIO SMS', CURRENT);
			END IF;
			
			INSERT INTO bdinteg:"informix".si_bitsmstels_huellarostro (numcte, sucursal, telefono, ejecutivo, codigo_generado, fecha)
			VALUES(pNumCte, pSucursal, pNumTelefono, pEjecutivo, pCodigoGenerado, CURRENT);
			
			SELECT nombre1 INTO cNombreCliente FROM bdinteg:"informix".si_cliente where sucursal = pSucursal AND numcte = pNumCte;
			SELECT apell_paterno INTO cApellidoCliente FROM bdinteg:"informix".si_cliente where sucursal = pSucursal AND numcte = pNumCte;
			
		    LET cNombreCompletoCliente = TRIM(cNombreCliente) || ' ' || TRIM(cApellidoCliente);
           
		    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','HUL_MANTTO','HUE_SMS','000000000','','','1',cNombreCompletoCliente,pCodigoGenerado,'','','','','','','','','',pNumTelefono,1,0,0,0,0,'','')
			INTO sCodRet;
			
			SELECT FIRST 1 correo_elec INTO sCorreo FROM bdinteg:"informix".si_correos WHERE numcte = pNumCte AND status_correo = 'A';
			IF NVL(sCorreo,'')<>'' THEN
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','HUL_MANT_E','HUE_EMAIL','000000000','','','1',cNombreCompletoCliente,pCodigoGenerado,'','','','','','','','',sCorreo,'',1,0,0,0,0,'','')
				INTO sCodRet;
            END IF;		
		ELSE
			LET sCodRet = '00001';
		END IF;
	RETURN sCodRet;
END
END PROCEDURE
DOCUMENT
'Se crea SP para insercion de bitacora de envio de sms y correo electronico para mantenimiento de huella y biometria',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 22/10/2019',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_obtenerhistmttodehuella_web(i16Tipo SMALLINT, cSucursal CHAR(4), dFecha DATE, cNumEmpleado CHAR(8),cNumEmpleado2 CHAR(8), i16Registros SMALLINT)
--Se borra el sp con mayusculas y se reemplaza por solo minusculas

	RETURNING CHAR(5), CHAR(10), CHAR(5), CHAR(20), CHAR(104), CHAR(8), CHAR(8), CHAR(8);

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFechaHora CHAR(25);
	DEFINE cFecha CHAR(10);
	DEFINE cHora CHAR(5);
	DEFINE cNumCte CHAR(20);
	DEFINE cApellPaterno CHAR(26);
	DEFINE cApellMaterno CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cNombreCompleto CHAR(104);
	DEFINE cEmpleado CHAR(8);
	DEFINE cOperador CHAR(8);
	DEFINE cUsuario CHAR(8);
	DEFINE i16Contador SMALLINT;
    DEFINE cfechaini char(20);
    DEFINE cfechafin char(20);

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cFechaHora = '';
	LET cFecha = '';
	LET cHora = '';
	LET cNumCte = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cNombreCompleto = '';
	LET cEmpleado = '';
	LET cOperador = '';
	LET cUsuario = '';
	LET i16Contador = 0;
    let cfechaini = '';
    let cfechafin = '';

--	SET DEBUG FILE TO "sp_ObtenerHistMttoDeHuella.out";
--	TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
					NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

         let cfechaini = year(dfecha)||'-'||lpad(month(dfecha),2,0)||'-'||lpad(day(dfecha),2,0)||' 00:00:00';
         let cfechafin = year(dfecha)||'-'||lpad(month(dfecha),2,0)||'-'||lpad(day(dfecha),2,0)||' 23:59:59';

		IF i16Tipo = 1 THEN
			IF (SELECT DISTINCT COUNT(*)
				FROM si_huella_temp a, si_cliente b
                WHERE a.fecha_alta >= cfechaini
                  AND a.fecha_alta <= cfechafin
                  AND a.sucursal = cSucursal 
                  AND a.numcte = b.numcte
				  AND a.status = 'A') > 0 THEN
				FOREACH
					SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
						b.nombre2, a.empleado, a.operador, a.usuario3
					INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
						cOperador, cUsuario
					FROM si_huella_temp a, si_cliente b
					WHERE a.fecha_alta >= cfechaini
					  AND a.fecha_alta <= cfechafin
					  AND a.sucursal = cSucursal 
					  AND a.numcte = b.numcte
					  AND a.status = 'A'
					ORDER BY b.apell_paterno

					LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
					LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
					LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
										TRIM(NVL(cNombre2,'')) || ' ' ||
										TRIM(NVL(cApellPaterno,'')) || ' ' ||
										TRIM(NVL(cApellMaterno,''));

					LET i16Contador = i16Contador + 1;
					IF i16Contador <= i16Registros THEN
						CONTINUE FOREACH;
					END IF;

					RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
				END FOREACH;
			ELSE
				LET  cCodRet = '00001';
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		ELIF i16Tipo = 2 THEN
			IF (SELECT DISTINCT COUNT(*) 
						FROM si_huella_temp a, si_cliente b
						WHERE a.fecha_alta >= cfechaini
						AND a.fecha_alta <= cfechafin
						AND a.sucursal = cSucursal
						AND a.status = 'A'
						AND a.numcte = b.numcte AND a.empleado = cNumEmpleado) > 0 THEN
				FOREACH
					SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
						b.nombre2, a.empleado, a.operador, a.usuario3
					INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
						cOperador, cUsuario
					FROM si_huella_temp a, si_cliente b
					WHERE a.fecha_alta >= cfechaini
					  AND a.fecha_alta <= cfechafin
					  AND a.sucursal = cSucursal
						AND a.status = 'A'
					  AND a.numcte = b.numcte AND a.empleado = cNumEmpleado
					ORDER BY b.apell_paterno

					LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
					LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
					LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
										TRIM(NVL(cNombre2,'')) || ' ' ||
										TRIM(NVL(cApellPaterno,'')) || ' ' ||
										TRIM(NVL(cApellMaterno,''));

					LET i16Contador = i16Contador + 1;
					IF i16Contador <= i16Registros THEN
						CONTINUE FOREACH;
					END IF;

					RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
				END FOREACH;
			ELSE
				LET  cCodRet = '00001';
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		ELIF i16Tipo = 3 THEN
			IF (SELECT DISTINCT COUNT(*) 
					FROM si_huella_temp a, si_cliente b
					WHERE a.fecha_alta >= cfechaini
					AND a.fecha_alta <= cfechafin
					AND a.sucursal = cSucursal
					AND a.status = 'A'
					AND a.numcte = b.numcte AND a.empleado BETWEEN cNumEmpleado AND cNumEmpleado2) > 0 THEN 
			
				FOREACH
					SELECT DISTINCT a.fecha_alta, a.numcte, b.apell_paterno, b.apell_materno, b.nombre1,
						b.nombre2, a.empleado, a.operador, a.usuario3
					INTO cFechaHora, cNumCte, cApellPaterno, cApellMaterno, cNombre1, cNombre2, cEmpleado,
						cOperador, cUsuario
					FROM si_huella_temp a, si_cliente b
					WHERE a.fecha_alta >= cfechaini
					AND a.fecha_alta <= cfechafin
					AND a.sucursal = cSucursal
					AND a.status = 'A'
					AND a.numcte = b.numcte AND a.empleado BETWEEN cNumEmpleado AND cNumEmpleado2
					ORDER BY b.apell_paterno

					LET cFecha = SUBSTR(TRIM(cFechaHora), 1, 10);
					LET cHora = SUBSTR(TRIM(cFechaHora), 12, 16);
					LET cNombreCompleto = TRIM(NVL(cNombre1,'')) || ' ' ||
										TRIM(NVL(cNombre2,'')) || ' ' ||
										TRIM(NVL(cApellPaterno,'')) || ' ' ||
										TRIM(NVL(cApellMaterno,''));

					LET i16Contador = i16Contador + 1;
					IF i16Contador <= i16Registros THEN
						CONTINUE FOREACH;
					END IF;

					RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '') WITH RESUME;
				END FOREACH;
			ELSE
				LET  cCodRet = '00001';
				RETURN cCodRet, NVL(cFecha, ''), NVL(cHora, ''), NVL(cNumCte, ''), NVL(cNombreCompleto, ''),
						NVL(cEmpleado, ''), NVL(cOperador, ''), NVL(cUsuario, '');
			END IF;
		END IF;
	END;
END PROCEDURE;