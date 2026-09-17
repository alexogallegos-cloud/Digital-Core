CREATE PROCEDURE "informix".sp_grabarfcalternobitacoramtto_web(pEmpresa CHAR(4),
														   pNumCte  CHAR(20),
														   pRFCAnt  CHAR(13),
														   pRFCAlt  CHAR(13),
														   pUserInsert CHAR(8))
RETURNING CHAR(5)  AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr 	     INTEGER;
DEFINE cCodRet		 CHAR(5);
DEFINE sSecuencia    SMALLINT;
DEFINE dFechaHoy     DATE;

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET sSecuencia      = '0';
LET dFechaHoy 		= DATE(1);


--SET DEBUG FILE TO '/tmp/sp_grabarfcalternobitacoramtto.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '00373';
			RETURN cCodRet;
	ELIF NVL(pRFCAlt,'') = '' THEN
		LET cCodRet = '00373';
		RETURN cCodRet;
	ELIF NVL(pUserInsert,'')=''THEN
		LET cCodRet = '00373';
		RETURN cCodRet;	
	ELSE
		UPDATE bdinteg:"informix".si_cliente 
		SET rfc_alterno= pRFCAlt
		WHERE empresa = pEmpresa 
		AND numcte = pNumCte;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '00373';
			RETURN cCodRet;
		ELSE
			SELECT fecha_hoy 
			INTO dFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = pEmpresa;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '00373';
				RETURN cCodRet;
			ELSE
				SELECT NVL(MAX(Secuencia),'0')
				INTO sSecuencia
				FROM bdinteg:"informix".si_bitacora_rfcalterno 
				WHERE empresa = pEmpresa 
				AND numcte = pNumCte;

				LET sSecuencia = sSecuencia + 1;
				
				INSERT INTO bdinteg:"informix".si_bitacora_rfcalterno (empresa,numcte,secuencia,rfcalt_org,rfcalt_nvo,usert_insert,fecha_insert) 
				VALUES (pEmpresa,pNumCte,sSecuencia,pRFCAnt,pRFCAlt,pUserInsert,dFechaHoy);
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
					LET cCodRet = '00373';
					RETURN cCodRet;
				ELSE
					RETURN cCodRet;
				END IF;
			END IF;
		END IF;
	END IF;	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para grabar el RFC Alterno en una bitacora, ademÃÂ¡s de actualizarlo en la tabla si_cliente',
'AUTOR : Martin Eduardo Miranda',
'FECHA : 02 Agosto 2012',
'VERSION: 20120802.01',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_insbitformatoimpresion_web(pEmpresa CHAR(3),pNumCte CHAR(20),pNumTel CHAR(13),pEjecutivo CHAR(8),pSucursal CHAR(4))
	RETURNING CHAR(5) AS CodRet;

	DEFINE sCodRet   	CHAR(5);
	DEFINE iSqlErr  	INTEGER;
	DEFINE iContRpte 	SMALLINT;
	DEFINE dFechaMov 	DATETIME YEAR TO FRACTION(3);
	
	LET sCodRet    	= '00000';
	LET iSqlErr    	= 0;
	LET iContRpte   = 0;
	LET dFechaMov   = '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET sCodRet = iSqlErr;
				RETURN sCodRet;
			END IF;
		END EXCEPTION;	
		
		--SET DEBUG FILE TO '/tmp/sp_insbitformatoimpresion.sql';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALIDA ERRORES DE LOS PARAMETROS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pNumTel,'') = '' OR NVL(pEjecutivo,'') = '' OR NVL(pSucursal,'') = '' THEN
			LET sCodRet='00001';
		ELSE
			SELECT cont_rpte, fecha_mov 
			INTO iContRpte, dFechaMov
			FROM "informix".si_bit_intentos_ivr
			WHERE empresa = pEmpresa
			AND numcte = TRIM(pNumCte)
			AND numtel = pNumTel;			
			
			INSERT INTO "informix".si_bit_impresion_ivr (empresa,numcte,numtel,ejecutivo,sucursal,cont_rpte,fecha_insert, fecha_mov)
			VALUES (pEmpresa,TRIM(pNumCte),pNumTel,pEjecutivo,pSucursal,NVL(iContRpte,0),CURRENT,NVL(dFechaMov,''));			
		END IF;

		RETURN sCodRet;

	END;
END PROCEDURE
DOCUMENT
'AUTOR:	ERNESTO AGUILERA',
'FECHA:	29/DIC/2015',
'DESCRIPCION: Bitacora para las impresiones de la caratula de llamada al IVR',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_inserta_huella_dec_web(pEmpresa CHAR(3), pNumcte CHAR(20),pSucursal CHAR(5),pUser_insert CHAR(8),pFecha DATE,cDH1 CHAR(955),cDH2 CHAR(955),cDH3 CHAR(955),cDH4 CHAR(955),cDH5 CHAR(955),cDH6 CHAR(955),cDH7 CHAR(955),cDH8 CHAR(955),cDH9 CHAR(955),cDH10 CHAR(955), cTipo CHAR(2))
--Retorno
RETURNING CHAR(5) AS cCodigoRet;

--Declaracion de variables
DEFINE sSecuencia   SMALLINT;
DEFINE sId_template SMALLINT;
DEFINE cTemplate    CHAR(942);
DEFINE sNfiq        SMALLINT;
DEFINE sMinucias SMALLINT;
DEFINE sId_Excepcion SMALLINT;
DEFINE dFecha   date;
DEFINE dFecha_insert DATETIME YEAR TO FRACTION;
DEFINE iSqlErr   INTEGER;
DEFINE cCodigoRet  char(5);
DEFINE iCont    SMALLINT ;
DEFINE iSiguienteSecuencia SMALLINT;

DEFINE cTp_persona CHAR(2);
DEFINE cEsfisica  CHAR(1);
DEFINE cExiste  CHAR(1);
DEFINE cTemplateD CHAR(942);
DEFINE cTemplateI CHAR(942);

DEFINE cTemplate1 CHAR(942);
DEFINE cTemplate2 CHAR(942);
DEFINE cTemplate3 CHAR(942);
DEFINE cTemplate4 CHAR(942);
DEFINE cTemplate5 CHAR(942);
DEFINE cTemplate6 CHAR(942);
DEFINE cTemplate7 CHAR(942);
DEFINE cTemplate8 CHAR(942);
DEFINE cTemplate9 CHAR(942);
DEFINE cTemplate10 CHAR(942);
DEFINE cTipoP 	   CHAR(1);

--inicializacion de variables
LET iSqlErr=0;
LET cCodigoRet = '00000';
LET sSecuencia = 0;
LET sId_template = 0;
LET cTemplate = '';
LET sNfiq = 0;
LET sMinucias = 0;
LET sId_Excepcion = 0;
LET dFecha = pFecha;
LET iCont = 1;
LET iSiguienteSecuencia = 0;

LET cTemplate1 = '';
LET cTemplate2 = '';
LET cTemplate3 = '';
LET cTemplate4 = '';
LET cTemplate5 = '';
LET cTemplate6 = '';
LET cTemplate7 = '';
LET cTemplate8 = '';
LET cTemplate9 = '';
LET cTemplate10 = '';
LET cTipoP = '';

--SET DEBUG FILE TO '/home/sysifx/Selene/bdinteg/sp_inserta_huella_dec.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr !=0 THEN
			RETURN (isqlerr);  
		END IF
	END EXCEPTION

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	--VALIDAR DATOS VACIOS
	IF NVL(pNumcte,'') = '' OR NVL(pSucursal, '') = '' OR NVL(pUser_insert, '') = '' OR NVL(dFecha, '') = '' OR NVL(cDH1,'') = '' OR NVL(cDH2,'') = '' OR NVL(cDH3,'') = '' OR NVL(cDH4,'') = '' OR NVL(cDH5,'') = '' OR NVL(cDH6,'') = '' OR NVL(cDH7,'') = '' OR NVL(cDH8,'') = '' OR NVL(cDH9,'') = '' OR NVL(cDH10,'') = '' THEN
		LET cCodigoRet = '00001'; --Datos vacios
		RETURN cCodigoRet;
	ELSE 
		SELECT tpo_persona INTO cTp_persona
		FROM   bdinteg:"informix".si_cliente
		WHERE  numcte = pNumcte;

		SELECT es_fisica INTO cEsfisica
		FROM bdinteg:"informix".si_tipper
		WHERE tpo_persona = cTp_persona;

		IF UPPER(cEsfisica) != "S" THEN
			LET cCodigoRet = '00120';
			RETURN cCodigoRet;
		END IF;

		--3 Validar que exista la sucursal en el sistema, en caso de no existir retornar cCodigoRet = '00111';
		SELECT 1 INTO cExiste
		FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = pSucursal;

		IF cExiste IS NULL THEN
			LET cCodigoRet = '00111';
			RETURN cCodigoRet;
		END IF;

		--4.- Validar que exista el ejecutivo en el sistema, en caso de no existir retornar cCodigoRet = '00112';
		SELECT 1 INTO cExiste
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pUser_insert;

		IF cExiste IS NULL THEN
			LET cCodigoRet='00112';
			RETURN cCodigoRet;
		END IF;
		
		WHILE (iCont <=10)
			LET cTemplate = '';
			
			--1 
			IF (iCont=1) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH1) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate1;
				LET cTemplate = cTemplate1; 
			END IF;    
			--2   
			IF (iCont=2) THEN      
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH2) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate2;
				LET cTemplate = cTemplate2; 				
			END IF;    
			--3    
			IF (iCont=3) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH3) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate3;
				LET cTemplate = cTemplate3; 
			END IF;
			--4
			IF (iCont=4) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH4) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate4;
				LET cTemplate = cTemplate4; 
			END IF;
			--5
			IF (iCont=5) THEN     
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH5) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate5;
				LET cTemplate = cTemplate5; 
			END IF;
			--6
			IF (iCont=6) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH6) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate6;
				LET cTemplate = cTemplate6; 
			END IF;
			--7
			IF (iCont=7) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH7) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate7; 
				LET cTemplate = cTemplate7;    
			END IF;
			--8
			IF (iCont=8) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH8) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate8;
				LET cTemplate = cTemplate8; 
			END IF;
			--9
			IF (iCont=9) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH9) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate9;
				LET cTemplate = cTemplate9; 
			END IF;    
			--10
			IF (iCont=10) THEN
				EXECUTE PROCEDURE bdinteg:"informix".sp_split_huella(cDH10) INTO cCodigoRet, sNfiq, sMinucias,sId_Excepcion, sId_template, cTemplate10;
				LET cTemplate = cTemplate10; 
			END IF;

			--CONSULTAR ULTIMA SECUENCIA CON ESTATUS A DE ID_TEMPLATE 
			LET sSecuencia = (SELECT secuencia FROM "informix".si_cte_huella_dec WHERE numcte =  pNumcte AND estatus = 'A' AND id_template = sId_template);

			IF NVL(sSecuencia, '') = ''  THEN
				LET sSecuencia = 1; 
			ELSE 
				LET sSecuencia = sSecuencia + 1;
			END IF;
			
			--ELIMINAR REGISTROS DE TEMPLATES DEL CLIENTE
			DELETE FROM "informix".si_cte_huella_dec_actual WHERE numcte = pNumcte AND id_template = sId_template;

			--INSERTAR LOS NUEVOS TEMPLATES
			INSERT INTO "informix".si_cte_huella_dec_actual(numcte,secuencia,id_template,template,nfiq,minucias,sucursal,id_excepcion,user_insert,fecha,fecha_insert) 
			VALUES(pNumcte,sSecuencia,sId_template,cTemplate,sNfiq,sMinucias,pSucursal,sId_Excepcion,pUser_insert,pFecha,current);

			--ACTUALIZAR EL ESTATUS DE LOS TEMPLATES ANTERIORES CON ESTATUS I= INACTIVO
			UPDATE "informix".si_cte_huella_dec SET estatus = 'I' WHERE numcte = pNumcte AND id_template = sId_template;

			--INSERTAR LOS NUEVOS TEMPLATES CON ESTATUS A= ACTIVO
			INSERT INTO "informix".si_cte_huella_dec(numcte,secuencia,estatus,id_template,template,nfiq,minucias,sucursal,id_excepcion,user_insert,fecha,fecha_insert) 
			VALUES(pNumcte,sSecuencia,'A',sId_template,cTemplate,sNfiq,sMinucias,pSucursal,sId_Excepcion,pUser_insert,pFecha,current);

			LET iCont = iCont + 1;
		END WHILE;

		IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET cCodigoRet= '00002';
		END IF;		
	 
		IF (NVL(cTemplate2, '') = '') THEN
			IF (NVL(cTemplate1, '') = '') THEN
				IF (NVL(cTemplate3, '') = '') THEN
					IF (NVL(cTemplate4, '') = '') THEN
						IF (NVL(cTemplate5, '') = '') THEN
							LET cTemplateD = '';
						ELSE
							LET cTemplateD = cTemplate5;
						END IF;
					ELSE
						LET cTemplateD = cTemplate4;
					END IF;
				ELSE
					LET cTemplateD = cTemplate3;
				END IF;
			ELSE
				LET cTemplateD = cTemplate1;
			END IF;
		ELSE
			LET cTemplateD = cTemplate2;
		END IF;
		
		IF (NVL(cTemplate7, '') = '') THEN
			IF (NVL(cTemplate6, '') = '') THEN
				IF (NVL(cTemplate8, '') = '') THEN
					IF (NVL(cTemplate9, '') = '') THEN
						IF (NVL(cTemplate10, '') = '') THEN
							LET cTemplateI = '';
						ELSE
							LET cTemplateI = cTemplate10;
						END IF;
					ELSE
						LET cTemplateI = cTemplate9;
					END IF;
				ELSE
					LET cTemplateI = cTemplate8;
				END IF;
			ELSE
				LET cTemplateI = cTemplate6;
			END IF;
		ELSE
			LET cTemplateI = cTemplate7;
		END IF;
		
		IF (NVL(cTemplateD, '') = '' OR NVL(cTemplateI, '') = '') THEN
			
			If  NVL(cTemplateD, '') = '' THEN
				
				IF (NVL(cTemplate7, '') = '') THEN					
					IF (NVL(cTemplate6, '') = '') THEN
						IF (NVL(cTemplate8, '') = '') THEN
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = '';
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate9;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							END IF;
						ELSE
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate8;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								LET cTemplateD = cTemplate9 ;
							END IF;
						END IF;
					ELSE
						IF (NVL(cTemplate8, '') = '') THEN
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate6;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								LET cTemplateD = cTemplate9;
							END IF;
						ELSE
							LET cTemplateD = cTemplate8;
						END IF;
					END IF;
				ELSE
					IF (NVL(cTemplate6, '') = '') THEN
						IF (NVL(cTemplate8, '') = '') THEN
							IF (NVL(cTemplate9, '') = '') THEN
								IF (NVL(cTemplate10, '') = '') THEN
									LET cTemplateD = cTemplate7;
								ELSE
									LET cTemplateD = cTemplate10;
								END IF;
							ELSE
								LET cTemplateD = cTemplate9;
							END IF;
						ELSE
							LET cTemplateD = cTemplate8;
						END IF;
					ELSE
						LET cTemplateD = cTemplate6;
					END IF;
				END IF;
				
			ELSE			
				IF (NVL(cTemplate2, '') = '') THEN					
					IF (NVL(cTemplate1, '') = '') THEN
						IF (NVL(cTemplate3, '') = '') THEN
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = '';
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate4;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							END IF;
						ELSE
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate3;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								LET cTemplateI = cTemplate4;
							END IF;
						END IF;
					ELSE
						IF (NVL(cTemplate3, '') = '') THEN
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate1;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								LET cTemplateI = cTemplate4;
							END IF;
						ELSE
							LET cTemplateI = cTemplate3;
						END IF;
					END IF;
				ELSE
					IF (NVL(cTemplate1, '') = '') THEN
						IF (NVL(cTemplate3, '') = '') THEN
							IF (NVL(cTemplate4, '') = '') THEN
								IF (NVL(cTemplate5, '') = '') THEN
									LET cTemplateI = cTemplate2;
								ELSE
									LET cTemplateI = cTemplate5;
								END IF;
							ELSE
								LET cTemplateI = cTemplate4;
							END IF;
						ELSE
							LET cTemplateI = cTemplate3;
						END IF;
					ELSE
						LET cTemplateI = cTemplate1;
					END IF;
				END IF;
				
			END IF
		END IF;
		
		IF TRIM(cTipo) = 'M' THEN
			LET cTipoP='C';
			
		ELSE
		
			LET cTipoP='A';
		END IF;

		EXECUTE PROCEDURE bdinteg:"informix".sp_ctehuella(pEmpresa, pSucursal, pUser_insert, pUser_insert, pFecha, cTipoP, pNumcte, cTemplateD, cTemplateI)
		INTO cCodigoRet,iSiguienteSecuencia;

	END IF;
	
	RETURN LPAD(TRIM(cCodigoRet),5,'0');	
END;
END PROCEDURE

DOCUMENT
'Peticion: 420',
'AutOR : 92473997 Isaac Salomon Quintero Serrano',
'FECHA : 31/08/2018',
'Descripcion: Store Procedure Insertar los datos de las huellas en la tabla si_cte_huella_dec',
'BD : bdinteg';

CREATE PROCEDURE "informix".sp_obtenerfechaaperturasucursal_web(p_cSucursal CHAR(4))
	RETURNING 	CHAR(5) AS retorno,
				DATE AS fecha_inicio;
				
				
	DEFINE iSqlErr			INTEGER;
	DEFINE cRetorno			CHAR(5);
	DEFINE dFecha_inicio	DATE;
				
	--SET DEBUG FILE TO "/tmp/sp_obtenerfechaaperturasucursal.out";
	--TRACE ON;
	
	LET isqlerr 	     = 0;
	LET cRetorno         = '00001';
	LET dFecha_inicio	 = '';
	
		BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'';
			END IF;
		END EXCEPTION;
		
		IF NVL(p_cSucursal,'') = '' THEN
			RETURN cRetorno,dFecha_inicio;
		END IF;
		
		 SET ISOLATION TO DIRTY READ;
		 SET LOCK MODE TO WAIT 3;

			LET dFecha_inicio = mdy('05','20','2007');
			LET cRetorno = '00000';
		 
		 RETURN cRetorno, dFecha_inicio; 
 	END;
END PROCEDURE
DOCUMENT
'CREADO: Josue Zepeda',
'FECHA: 25/02/2013',
'DESCRIPCION: Para obtener fecha_inicio para Validacion de Fechas (Paquetes Operativos y de Cheques)',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_situacionespecialcte_cpl_web(pSituacion CHAR(3), pCausa VARCHAR(4))

RETURNING
	CHAR(5),
	CHAR(5)

--- DECLARACIONES
DEFINE cCodRet 							CHAR(5);
DEFINE iSqlErr                          INTEGER;
DEFINE iSamErr                          INTEGER;
DEFINE cDesErr                          CHAR(60);
         

DEFINE cIdusituacionEspecial            CHAR(5);
--DEFINE iCausaSituacionEspecial          SMALLINT;


--- INICIALIZACIONES
LET cCodRet = '00000';
LET iSqlErr = 0;
LET iSamErr = 0;
LET cDesErr = '';
LET cIdusituacionEspecial = " ";

	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr, cDesErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet, NULL;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;

	--	SET DEBUG FILE TO '/tmp/Yadira/sp_situacionesp_out.sql';
	--	TRACE ON;

		IF (NVL(pSituacion,"") = ""  )  OR  (nvl(pCausa,"") = "") THEN
            RETURN '00003', NVL(cIdusituacionEspecial,"");
		ELSE
			LET pSituacion = TRIM(pSituacion);
			LET pCausa = TRIM(pCausa);
			
			SELECT NVL(idu_situacion,"") INTO  cIdusituacionEspecial FROM bdinteg:"informix".si_relacionsituacionescausasbcpl_cpl 
			WHERE clv_situacion=pSituacion AND num_causasituacion = pCausa;
			
			IF  NVL(cIdusituacionEspecial,"") =  "" THEN
			
			   RETURN '00004', NVL(cIdusituacionEspecial,"");
			   
			END IF
										
		        RETURN '00000', NVL(cIdusituacionEspecial,"");
		END IF;

		RETURN  cCodRet, NVL(cIdusituacionEspecial,"") ;

	END;
END PROCEDURE
DOCUMENT
"Folio: 1743",
"Autor: 96674555 Carolina Verdugo",
"Fecha: 17/08/2015", 
"Detalle: Se crea procedimiento para consultar la sitacion especial del cliente.",
"Solicita:  Rodolfo Gomez ",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_spei_consnumcte_web(pEmpresa CHAR(3),pNumCte CHAR(9),pNumCta CHAR(12),pNumTarjeta CHAR(16),pTipoBusqueda CHAR(1))

--RETORNO--
RETURNING	CHAR(5),	-- Codigo de Retorno
			CHAR(9),	-- Numero de Cliente
			CHAR(107),	-- Nombre del Cliente
			CHAR(10),	-- Fecha de Nac.
			CHAR(13);	-- RFC.

--DEFINICION DE VARIABLES
DEFINE	iSqlErr 		INTEGER;
DEFINE	cCodRet 		CHAR(5);
DEFINE	cNombreCompleto	CHAR(107);
DEFINE	cFechaNac		CHAR(10);
DEFINE	cBin			CHAR(6);
DEFINE	cTipoTarj		CHAR(1);
DEFINE	cStatusTarj		CHAR(1);
DEFINE	cNombre1		CHAR(26);
DEFINE	cNombre2		CHAR(26);
DEFINE	cApellPat		CHAR(26);
DEFINE	cApellMat		CHAR(26);
DEFINE	cRfc			CHAR(13);

--INICIALIZACION DE VARIABLES
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET	cNombreCompleto	= "";
LET	cFechaNac		= "";
LET	cBin			= "";
LET	cTipoTarj		= "";
LET	cStatusTarj		= "";
LET	cNombre1		= "";
LET	cNombre2		= "";
LET	cApellPat		= "";
LET	cApellMat		= "";
LET	cRfc			= "";

	--SET DEBUG FILE TO '/respaldosdb/Benitez/sp_spei_consnumcte.out';
	--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
           RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cFechaNac, cRfc;
		END IF
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
			
	IF (NVL(pEmpresa,'') <> '' AND NVL(pNumCte,'')<> '') OR (NVL(pNumTarjeta,'') <> '' AND NVL(pTipoBusqueda,'')<> '')  OR (NVL(pNumCta,'') <> '' AND NVL(pTipoBusqueda,'')<> '') THEN

		LET pTipoBusqueda =  UPPER(pTipoBusqueda);
		IF NVL(pTipoBusqueda,'') <> "C" AND NVL(pTipoBusqueda,'') <> "D" THEN
			LET cCodRet = '00006';
		ELSE	
			IF NVL(pNumTarjeta,'') <> '' THEN
				LET cBin = SUBSTR(pNumTarjeta,1,6);
				SELECT bin INTO cBin FROM intercard:"informix".bines
				WHERE bin = cBin AND creditodebito = pTipoBusqueda;

				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					IF NVL(pTipoBusqueda,'') = "C" THEN
						LET cCodRet = '00202';
					ELIF NVL(pTipoBusqueda,'') = "D" THEN
						LET cCodRet = '00245';
					END IF
				ELSE
					IF NVL(pTipoBusqueda,'') = "C" THEN
						SELECT numcte,tipo_tarjeta,status_tar INTO pNumCte,cTipoTarj,cStatusTarj
						FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = pNumTarjeta;

						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodRet = '00003';
						ELSE
							IF NVL(cStatusTarj,'') <> "A" THEN
								LET cCodRet = '00398';
							END IF
						END IF
					ELIF NVL(pTipoBusqueda,'') = "D" THEN
						SELECT numcte,tipo_tarjeta,status_tar INTO pNumCte,cTipoTarj,cStatusTarj
						FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = pNumTarjeta;

						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodRet = '00003';
						ELSE
							IF NVL(cStatusTarj,'') <> "A" THEN
								LET cCodRet = '00005';
							END IF
						END IF
					END IF
					IF NVL(cTipoTarj,'') <> "T" AND NVL(cTipoTarj,'') <> '' THEN
						LET cCodRet = '00186';
					END IF
				END IF
			ELIF NVL(pNumCta,'') <> '' THEN

				IF NVL(pTipoBusqueda,'') = "C" THEN
					SELECT numcte INTO pNumCte
					FROM bdicred:"informix".sd_maecred
					WHERE num_credito = pNumCta;

					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00002';
					END IF

				ELIF NVL(pTipoBusqueda,'') = "D" THEN
					SELECT num_cte INTO pNumCte
					FROM bdicheq:"informix".sc_maechq
					WHERE cuenta = pNumCta;

					IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00002';
					END IF
				END IF
			END IF
		END IF

		IF NVL(pNumCte,'') <> '' THEN
			SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
			INTO cNombre1, cNombre2, cApellPat, cApellMat, cRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumCte;

			LET cNombreCompleto = TRIM(cNombre1) || " " || TRIM(cNombre2) || " " || TRIM(cApellPat) ||" " || TRIM(cApellMat);

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00004';
			ELSE
				SELECT LIMIT 1 fecha_nac
				INTO cFechaNac
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte = pNumCte;

				IF  DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00004';
				END IF
			END IF
		END IF
	ELSE
		LET cCodRet = '00001';
	END IF

RETURN cCodRet, NVL(pNumCte,''), TRIM(cNombreCompleto), cFechaNac, cRfc;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Obtiene nombre completo y fecha de nacimiento, buscando por NumCte,Cuenta o Tarjeta',
'REALIZO: Francisco Eduardo Benitez Baez',
'FOLIO: 1463',
'FECHA: 30/10/2014',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_validaproducto_web(pEmpresa CHAR(3), pNumCuenta CHAR(20), pTipo CHAR(1))

RETURNING CHAR(5), CHAR(1), CHAR(1), SMALLINT;

--28/11/2008
--Rodolfo Tortolero Varela
--Valida que el numero de cuenta se le pueda asignar una tarjeta adicional

--02/12/2008
--Rodolfo Tortolero Varela
--Se modifico para tambien recibir tarjetas de crÃÂ©dito.

--14/10/2009
--Rodolfo Tortolero Varela
--Se agrega validaciÃÂ³n para cuando la consulta de producto se haga por nÃÂºmero de tarjeta

--DEFINICION DE VARIABLES--
	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(5);
	DEFINE vProducto CHAR(4);
	DEFINE vFlagAdic CHAR(1);
	DEFINE vFlagTar CHAR(1);
	DEFINE vTotAdic SMALLINT;
	DEFINE vProd CHAR(4);

--Set debug file to '/tmp/sp_consultacuentas.out';
--trace on;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = iSqlErr;
				RETURN vCodRet, vFlagAdic, vFlagTar, vTotAdic;
			END IF;
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
--INICIALIZACION DE VARIABLES--
	LET iSqlErr = 0;
	LET vCodRet = '00000';	--Si Existe el tipo de producto
	LET vProducto = "";
	LEt vFlagAdic = "";
	LET vFlagTar = "";
	LEt vTotAdic = 0;
	LEt vProd = "";
		
	IF pNumCuenta = "" THEN
		LET vCodRet = '99999'; --Falta el parametro nÃÂ¹mero de cuenta
			LET vFlagAdic = NULL;
			LET vFlagTar = NULL;
			LET vTotAdic = NULL;
		RETURN vCodRet, vFlagAdic, vFlagTar, vTotAdic;
	END IF;
	
	--Se selecciona el producto de la cuenta
	IF pTipo = "1" THEN --Productos de DÃÂ©bito
		IF LENGTH(pNumCuenta) = 11 THEN
			SELECT producto INTO vProd FROM bdicheq:sc_maechq 
			 WHERE cuenta = pNumCuenta;
		ELSE
			SELECT b.producto INTO vProd FROM bdicheq:sc_tarjeta a, bdicheq:sc_maechq b
			WHERE a.empresa = pEmpresa 
			  AND a.num_tarjeta = pNumCuenta 
			  AND a.cuenta = b.cuenta;
		END IF;
	ELIF pTipo = "2" THEN --Productos de InversiÃÂ³n
		SELECT cod_instrum INTO vProd FROM bdinvers:sv_maeinv WHERE cuenta = pNumCuenta;
	ELIF pTipo = "3" THEN --Productos de CrÃÂ©dito Bancoppel
		SELECT b.num_producto INTO vProd FROM bdicred:sd_tarjeta a, bdicred:sd_maecred b
		WHERE a.empresa = pEmpresa 
		  AND a.num_tarjeta = pNumCuenta 
		  AND a.empresa = b.empresa
		  AND a.num_credito = b.num_credito;
	ELIF pTipo = "4" THEN --Producto de CrÃÂ©dito Coppel
		LET vProd = "6500";
	END IF;
	
	SELECT producto, flagadicional, flagtarjeta, totadicional
	INTO vProducto, vFlagAdic, vFlagTar, vTotAdic
	FROM si_catvalidaprod
	WHERE empresa = pEmpresa
	AND producto = vProd;
        
	IF vFlagAdic = '0'  THEN
		LET vFlagTar = '0';
		LET vTotAdic = '0';
	END IF;        
        
	IF vProducto IS NULL THEN
		LET  vCodRet = '00001'; --No Existe el producto en la tabla si_catvalidaprod
	END IF;
		
	RETURN vCodRet, vFlagAdic, vFlagTar, vTotAdic;

	END;
END PROCEDURE;