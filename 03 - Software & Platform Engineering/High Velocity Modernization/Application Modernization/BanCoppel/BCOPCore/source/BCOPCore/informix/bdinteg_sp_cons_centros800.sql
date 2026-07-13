CREATE PROCEDURE "informix".sp_cons_centros800(pCentro CHAR(4))
RETURNING CHAR(5),CHAR(4),CHAR(1); 

    DEFINE Sql_Err  INTEGER;
	DEFINE vCodRet CHAR(5);
	DEFINE vCancelado CHAR(1);  
	DEFINE vCentro800 CHAR(4);

    LET Sql_Err	 = 0;
	LET vCodRet = '00000';
	LET vCancelado = '';
	LET vCentro800 = '';

    BEGIN

		ON EXCEPTION SET Sql_Err
        --- SET DEBUG FILE TO "/tmp/sp_cons_centros800.err";
        --- TRACE ON;
			IF Sql_Err <> 0 THEN
				LET vCodRet = Sql_Err;
				RETURN vCodRet,vCentro800,vCancelado;
			END IF;
		END EXCEPTION;

		--- SET DEBUG FILE TO "/tmp/sp_cons_centros800.out";
		--- TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	IF pCentro <> '' THEN
	
		SELECT sucursal800, cancelado
		INTO vCentro800, vCancelado
		FROM bdinteg:"informix".si_cargacentros800
		WHERE sucursal800 = pCentro;	
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET vCodRet = "00001";			
		END IF;
		
		RETURN vCodRet,vCentro800,vCancelado;
	
	ELSE
	
		FOREACH
			SELECT sucursal800, cancelado
			INTO vCentro800, vCancelado
			FROM bdinteg:"informix".si_cargacentros800
		
		RETURN vCodRet,vCentro800,vCancelado WITH RESUME;	
			
		END FOREACH;
	
	END IF;

	END;

END PROCEDURE
DOCUMENT
'Consulta de sucursales de centros 0800',
'AUTOR : Hever Barraza',
'FECHA : 16/04/19',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_cons_puesto_coppel(pPuesto CHAR(3))
RETURNING CHAR(5),CHAR(3),CHAR(3),CHAR(30); 

    DEFINE Sql_Err  INTEGER;
    DEFINE Isam_Err INTEGER;
    DEFINE Desc_Err CHAR(50);
	DEFINE vCodRet1 CHAR(5);
	DEFINE vCodRet2 CHAR(5);
	DEFINE vCodRet3 CHAR(50);
	DEFINE vPuesto_coppel CHAR(3);  
	DEFINE vPuesto_bancoppel CHAR(3);
	DEFINE vNombramiento CHAR(30);
 
    LET Sql_Err	 = 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
	LET vCodRet1 = '00000';
	LET vCodRet2 = '';
	LET vCodRet3 = '';
	LET vPuesto_coppel = '';
	LET vPuesto_bancoppel = '';
	LET vNombramiento = '';

    BEGIN

		ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        -- SET DEBUG FILE TO "/tmp/sp_cons_puesto_coppel.err";
        -- TRACE ON;
			IF Sql_Err <> 0 THEN
				LET vCodRet1 = Sql_Err;
				LET vCodRet2 = Isam_Err;
				LET vCodRet3 = Desc_Err;
				RETURN vCodRet1,vPuesto_coppel,vPuesto_bancoppel,vNombramiento;
			END IF;
		END EXCEPTION;

		-- SET DEBUG FILE TO "/tmp/sp_cons_puesto_coppel.out";
		-- TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

	IF pPuesto <> '' THEN
	
		SELECT puesto_bancoppel, nombramiento
		INTO vPuesto_bancoppel, vNombramiento
		FROM bdinteg:"informix".si_puestosrelacion
		WHERE puesto_coppel = pPuesto;	
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET vCodRet1 = "00001";			
		END IF;
		
		RETURN vCodRet1,vPuesto_coppel,vPuesto_bancoppel,vNombramiento;
	
	ELSE
	
		FOREACH
			SELECT puesto_coppel, puesto_bancoppel, nombramiento
			INTO vPuesto_coppel, vPuesto_bancoppel, vNombramiento
			FROM bdinteg:"informix".si_puestosrelacion
		
		RETURN vCodRet1,vPuesto_coppel,vPuesto_bancoppel,vNombramiento WITH RESUME;	
			
		END FOREACH;
	
	END IF;
	
	END;

END PROCEDURE
DOCUMENT
'Consulta de puestos coppel',
'AUTOR : Hever Barraza',
'FECHA : 16/04/19',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_inserta_huella_dec(pEmpresa CHAR(3), pNumcte CHAR(20),pSucursal CHAR(5),pUser_insert CHAR(8),pFecha DATE,cDH1 CHAR(955),cDH2 CHAR(955),cDH3 CHAR(955),cDH4 CHAR(955),cDH5 CHAR(955),cDH6 CHAR(955),cDH7 CHAR(955),cDH8 CHAR(955),cDH9 CHAR(955),cDH10 CHAR(955))
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

--SET DEBUG FILE TO '/home/sysifx/Aracely/bdinteg/sp_inserta_huella_dec.out';
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

		EXECUTE PROCEDURE bdinteg:"informix".sp_ctehuella(pEmpresa, pSucursal, pUser_insert, pFecha, 'A', pNumcte, cTemplateD, cTemplateI)
		INTO cCodigoRet,iSiguienteSecuencia;

	END IF;
	
	RETURN cCodigoRet;	
	
END;
END PROCEDURE

DOCUMENT
'Peticion: 420',
'AutOR : 92473997 Isaac Salomon Quintero Serrano',
'FECHA : 31/08/2018',
'Descripcion: Store Procedure Insertar los datos de las huellas en la tabla si_cte_huella_dec',
'BD : bdinteg';

CREATE PROCEDURE "informix".sp_valida_celular_cancelado(pTipoOper	 SMALLINT, 
														pEmpresa     CHAR(3), 
														pNumCte      CHAR(20), 
														pTelefono    CHAR(13),
														pTipoTel     SMALLINT,
														pUserInsert  CHAR(8) )
	RETURNING CHAR(5) AS cCodRet1;
	
	DEFINE cCodRet1 		CHAR(5);
    DEFINE cCodRet2 		CHAR(5);
    DEFINE cCodRet3 		CHAR(50);
	DEFINE iSqlErr  		INTEGER;
    DEFINE iSamErr  		INTEGER;
    DEFINE cDesErr  		CHAR(50);
	DEFINE iRegistros		INTEGER;
	DEFINE vFechaMaxima 	DATETIME YEAR TO SECOND;
    DEFINE sSucursal        CHAR(4);
	DEFINE vNumcte			CHAR(20);
	DEFINE vSecuencia		SMALLINT;

	
	LET cCodRet1		= '0000';
    LET cCodRet2		= '';
    LET cCodRet3		= '';
	LET iSqlErr			= 0;
    LET iSamErr			= 0;
    LET cDesErr			= '';
	LET iRegistros		= 0;
	LET vFechaMaxima    ='';
    LET sSucursal       ='0000';
	LET vNumcte 		='0000';
	LET vSecuencia		='0';

														
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
	
	--SET DEBUG FILE TO "/informix/LIP/sp_valida_celular_cancelado.out";
        --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pTipoOper is null OR pTipoOper = 0) OR (pEmpresa is null OR pEmpresa = '') OR 
	   (pNumCte is null OR pNumCte = '') OR (pTipoTel is null OR pTipoTel = 0) OR 
	   (pUserInsert is null OR pUserInsert = '') THEN
        LET cCodRet1 = '1110';
        RETURN cCodRet1;
    END IF;

	LET sSucursal=(select first 1 sucursal from "informix".si_ejecut where ejecutivo=pUserInsert);
	
	IF(pTipoOper = 1) THEN
	
		IF(pTelefono is null OR pTelefono = '') THEN 
			LET cCodRet1 = '1110';
			RETURN cCodRet1;
		END IF;
		
		SELECT COUNT (*)
		INTO iRegistros
		FROM bdinteg:"informix".si_telefonos
		WHERE telefono=pTelefono
		AND tipo_tel=pTipoTel
		AND status_tel = 'A'
		AND numcte != pNumCte;
		
		IF(iRegistros > 0) THEN
			
			FOREACH
				SELECT numcte,secuencia INTO vNumcte,vSecuencia FROM bdinteg:"informix".si_telefonos_actual WHERE telefono=pTelefono AND tipo_tel=pTipoTel AND status_tel = 'A' AND numcte != pNumCte
					
				DELETE bdinteg:"informix".si_telefonos_actual
				WHERE telefono=pTelefono
				AND tipo_tel=pTipoTel
				AND status_tel = 'A'
				AND secuencia = vSecuencia
				AND numcte = vNumcte;
					
			END FOREACH;
			
			FOREACH
				SELECT numcte,secuencia INTO vNumcte,vSecuencia FROM bdinteg:"informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel=pTipoTel AND status_tel = 'A' AND numcte != pNumCte

				UPDATE bdinteg:"informix".si_telefonos
				SET status_tel = 'C',
				fecha_actualiza = CURRENT::DATE
				WHERE telefono=pTelefono
				AND tipo_tel=pTipoTel
				AND status_tel = 'A'
				AND secuencia = vSecuencia
				AND numcte = vNumcte;
					
			END FOREACH;
			
			
				
		END IF;
		
	END IF;
	
	RETURN cCodRet1;
	
END;
    
END PROCEDURE

DOCUMENT
'Modifico: Aracely UreÃÂÃÂ±a',
'Fecha: 02/04/2018',
'BD: bdinteg',
'Descripcion: Se crea sp para cancelacion de telefonos asociados a otros clientes,',
' despues de la verificacion por medio del sms',
'PeticiÃÂÃÂ³n: 377 - RQM 06 604 TelÃÂÃÂ©fono ÃÂÃÂnico';

CREATE PROCEDURE "informix".sp_bit_dictamenes(pNumCte CHAR(20), 
											  pSitEsp CHAR(1), 
											  pCausaSit SMALLINT, 
											  pNumCteCoin CHAR(20), 
											  pSitAsig CHAR(1),
                                              pCausaasig SMALLINT, 
											  pTipoCoin CHAR(1), 
											  pSucursal CHAR(4), 
											  pNumEmp CHAR(8), 
											  pOrigen CHAR(1)) 
RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);


--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';

--SET DEBUG FILE TO '/informix/cristo/sp_bit_dictamenes.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
			INSERT INTO bdinteg:"informix".si_bitacora_dictamenes
		(numcte, situacion, causa, numcte_coinc, situacion_coinc, causa_coinc, tipo, sucursal,numemp,origen,fecha_insert,tipo_dictamen,fecha_dicta_ini,fecha_dicta_fin)
		VALUES( pNumCte, pSitEsp , pCausaSit , pNumCteCoin , pSitAsig , pCausaasig, pTipoCoin, pSucursal, 'informix','1', current,'1',CURRENT,CURRENT);
	
	RETURN cCodRet;	
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION:Se adapta a la nueva estructura de la tabla si_bitacora_dictamenes',
'AUTOR : Cristo Javier Lugo Sanchez',
'FECHA : 24/10/2014',
'VERSION: ',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_buscacterfc(pUsuario CHAR(8), pIdFuncion CHAR(10), pTpoPersona CHAR(1), pRfc CHAR(13), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(20) AS Numero_Cliente,
		CHAR(13) AS RFC_Alt,
		CHAR(1)  AS Id_Num_Consulta,
		CHAR(26) AS Nombre_1,
		CHAR(26) AS Nombre_2,
		CHAR(26) AS Apellido_Paterno,
		CHAR(26) AS Apellido_Materno,
		CHAR(60) AS Razon_Social,
		CHAR(13) AS RFC;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cNumero_cliente CHAR(20);
	DEFINE cRFC1_Alt CHAR(13);
	DEFINE cId_Nconsulta_cliente CHAR(1);
	DEFINE cNombre1_salida CHAR(26);
	DEFINE cNombre2_salida CHAR(26);
	DEFINE cAPaterno1 CHAR(26);
	DEFINE cAMaterno1 CHAR(26);
	DEFINE cRSocial1 CHAR(60);
	DEFINE cRFC CHAR(13);
    DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cNumero_cliente = '';
	LET cRFC1_Alt = '';
	LET cId_Nconsulta_cliente = '1';
	LET cNombre1_salida = '';
	LET cNombre2_salida = '';
	LET cAPaterno1 = '';
	LET cAMaterno1 = '';
	LET cRSocial1 = '';
	LET cRFC = '';
    LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cNumero_cliente,cRFC1_Alt,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_buscacterfc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTpoPersona = '' OR pRfc = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumero_cliente,cRFC1_Alt,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumero_cliente,cRFC1_Alt,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumero_cliente,cRFC1_Alt,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		FOREACH
			
			--SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc)} SKIP pRegistros FIRST pRecuperacion 
			SELECT SKIP pRegistros FIRST pRecuperacion 
			CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno,CL.rfc
			INTO cNumero_cliente, cNombre1_salida, cNombre2_salida, cAPaterno1, cAMaterno1, cRSocial1, cRFC1_Alt, cRFC 
			FROM bdinteg:"informix".si_cliente CL
			WHERE CL.rfc = pRfc
			ORDER BY 1
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cNumero_cliente,cRFC1_Alt,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC WITH RESUME;
			
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			
			FOREACH
			
				--SELECT {+INDEX (bdinteg:si_cliente idx_cliente_rfc_alterno)} SKIP pRegistros FIRST pRecuperacion 
				SELECT SKIP pRegistros FIRST pRecuperacion 
				CL.numcte,CL.nombre1,CL.nombre2,CL.apell_paterno,CL.apell_materno,CL.razon_social,CL.rfc_alterno,CL.rfc
				INTO cNumero_cliente, cNombre1_salida, cNombre2_salida, cAPaterno1, cAMaterno1, cRSocial1, cRFC1_Alt, cRFC 
				FROM bdinteg:"informix".si_cliente CL
				WHERE CL.rfc_alterno = pRfc
				ORDER BY 1
				
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,cNumero_cliente,cRFC1_Alt,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC WITH RESUME;
			
			END FOREACH;
			
		END IF;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '99999'; --EL CLIENTE NO EXISTE CON EL R.F.C. CAPTURADO
			RETURN cCodRet,cNumero_cliente,cRFC1_Alt,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cNumero_cliente,cRFC1_Alt,cId_Nconsulta_cliente,cNombre1_salida,cNombre2_salida,cAPaterno1,cAMaterno1,cRSocial1,cRFC;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Juan Román Velázquez',
'FECHA 17/05/2019',
'MODULO: ',
'FUNCIONALIDAD: ',
'DESCRIPCION: Spl encargado de hacer la busqueda de cliente por RFC.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_telefonosmovilrel(pUsuario CHAR(8), pIdFuncion CHAR(10), pTelefono CHAR(13), pNumCliente CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(5) AS codRet,
		CHAR(26) AS nombre1,
		CHAR(26) AS nombre2,
		CHAR(26) AS apell_paterno,
		CHAR(26) AS apell_materno,
		CHAR(20) AS no_cliente,
		DATETIME YEAR TO FRACTION(3) AS fecha,
		INTEGER AS dias,
		INTEGER AS total;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFechaHoy DATE;
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApPaterno CHAR(26);
	DEFINE cApMaterno CHAR(26);
	DEFINE cNumCliente CHAR(20);
	DEFINE dFecha DATETIME YEAR TO FRACTION(3);
	DEFINE iDias INTEGER;
	DEFINE cTelefono CHAR(13);
	DEFINE cTelefonos CHAR(500);
	DEFINE iTotal INTEGER;
    DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET dFechaHoy = CURRENT;
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApPaterno = '';
	LET cApMaterno = '';
	LET cNumCliente = '';
	LET dFecha = '';
	LET iDias = 0;
	LET cTelefono = '';
	LET cTelefonos = '';
	LET iTotal = 0;
    LET iRecuperacion = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cNumCliente, dFecha, iDias, iTotal;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_telefonosmovilrel.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cNumCliente, dFecha, iDias, iTotal;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cNumCliente, dFecha, iDias, iTotal;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cNumCliente, dFecha, iDias, iTotal;
		END IF;
		
		--LIMPIA TABLA DE PASO
		DELETE FROM "informix".ws_telefonos_movil WHERE usuario_insert = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		FOREACH
		
			SELECT telefono INTO cTelefono
			FROM bdinteg:"informix".si_telefonos
			WHERE numcte = pNumCliente AND UPPER(verificado) = 'V' AND UPPER(status_tel) = 'A'
			ORDER BY secuencia DESC
			
			FOREACH
					
				SELECT SKIP pRegistros FIRST pRecuperacion 
				b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, a.numcte
				INTO cNombre1, cNombre2, cApPaterno, cApMaterno, cNumCliente
				FROM bdinteg:"informix".si_telefonos AS a
				INNER JOIN bdinteg:"informix".si_cliente AS b ON (a.numcte = b.numcte)
				AND a.telefono = cTelefono AND a.numcte <> pNumCliente
				AND UPPER(a.verificado) = 'V' AND UPPER(a.status_tel) = 'A'
				ORDER BY secuencia DESC
				
				LET dFecha = NULL;
				LET iDias = 0;
				FOREACH
					SELECT FIRST 1 fecha INTO dFecha 
					FROM bdinteg:"informix".si_bitsmstels WHERE telefono = cTelefono AND numcte = cNumCliente 
					ORDER BY fecha DESC
				END FOREACH;
				 
				IF dFecha IS NOT NULL THEN
					LET iDias = dFechaHoy - DATE(dFecha);
				END IF;
			
				LET iRecuperacion = iRecuperacion + 1;
				--RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cNumCliente, dFecha, iDias, iTotal WITH RESUME;
				INSERT INTO "informix".ws_telefonos_movil (nombre1,nombre2,ap_paterno,ap_materno,num_cliente,fecha,dias,total_reg,usuario_insert,fecha_insert)
				VALUES (cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCliente,dFecha,iDias,iTotal,pUsuario,CURRENT);
				
			END FOREACH;
			
		END FOREACH;
		
		SELECT COUNT(*) INTO iTotal
		FROM "informix".ws_telefonos_movil WHERE usuario_insert = pUsuario;
		
		FOREACH
						
			SELECT SKIP pRegistros FIRST pRecuperacion 
			nombre1,nombre2,ap_paterno,ap_materno,num_cliente,fecha,dias
			INTO cNombre1,cNombre2,cApPaterno,cApMaterno,cNumCliente,dFecha,iDias
			FROM "informix".ws_telefonos_movil WHERE usuario_insert = pUsuario
			ORDER BY id_serial ASC
						
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cNumCliente, dFecha, iDias, iTotal WITH RESUME;
			
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '01125'; --NO EXISTEN TELÉFONOS MOVILES RELACIONADOS
			RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cNumCliente, dFecha, iDias, iTotal;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cNumCliente, dFecha, iDias, iTotal;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA 17/05/2019',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: DOMICILIOS DEL CLIENTE',
'DESCRIPCION: Spl encargado de consultar los teléfonos moviles relacionados.',
'AUTOR: L. Montserrat León Amador',
'FECHA 27/05/2019',
'DESCRIPCION: Se modifica spl para recuperar todos los teléfonis moviles registrados por el cliente.',
'AUTOR: L. Montserrat León Amador',
'FECHA 14/06/2019',
'DESCRIPCION: Se modifica spl para recuperar fechas por el cliente.',
'BD: bdinteg';

CREATE PROCEDURE  "informix".sp_cnsif_consulta_telefonos3(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCTE CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
RETURNING CHAR(5),CHAR(20),SMALLINT,CHAR(13),CHAR(5),CHAR(1),DATETIME YEAR TO FRACTION(3),CHAR(1),CHAR(1),CHAR(4),CHAR(8),DATETIME YEAR TO SECOND;
          
    DEFINE iexiste 			INT;
    DEFINE cCodRet 			CHAR(5);
    DEFINE iSql_err 		INT;	
 
    DEFINE cTipoTel         CHAR(20);   
    DEFINE sSecuencia       SMALLINT;
    DEFINE vTelefono        CHAR(13);
    DEFINE vExtension       CHAR(5);
    DEFINE iCont INTEGER;
	DEFINE cVerificado CHAR(1);
	DEFINE dFecha DATETIME YEAR TO FRACTION(3);
	DEFINE cCofetel CHAR(1);
	DEFINE cStatus CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cEmpleado CHAR(8);
	DEFINE dFechaHora DATETIME YEAR TO SECOND; 
	
    LET  iexiste = 0;
    LET cCodRet = "00000";
    LET iSql_err = 0 ;	
    LET cTipoTel       = '';
    LET sSecuencia        =0;
    LET vTelefono         = '';
    LET vExtension      = '';
    LET iCont=0;
    LET cVerificado = '';
	LET dFecha = '';
	LET cCofetel = '';
	LET cStatus = '';
	LET cSucursal = '';
	LET cEmpleado = '';
	LET dFechaHora = ''; 
	
    BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension, cVerificado, dFecha, cCofetel, cStatus, cSucursal, cEmpleado, dFechaHora;
		END IF;
	END EXCEPTION;
    
    --SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_consulta_telefonos3.out";
    --TRACE ON;

    -- // VALIDA PARAMETROS DE ENTRADA
	IF 	cID_USUARIOC = '' OR
		cID_FUNCIONC = '' OR
		cNUMCTE  = ''     THEN 
        LET cCodRet = "00054";
        RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension, cVerificado, dFecha, cCofetel, cStatus, cSucursal, cEmpleado, dFechaHora;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension, cVerificado, dFecha, cCofetel, cStatus, cSucursal, cEmpleado, dFechaHora;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension, cVerificado, dFecha, cCofetel, cStatus, cSucursal, cEmpleado, dFechaHora;
        END IF;
    END IF;  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCTE,'11','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension, cVerificado, dFecha, cCofetel, cStatus, cSucursal, cEmpleado, dFechaHora;
	END IF;
	-- TERMINA VALIDACION
    SELECT NVL(COUNT(numcte),0)  INTO iexiste FROM si_telefonos WHERE numcte = cNUMCTE;
    IF iexiste = 0 THEN 
        --LET cCodRet = "00096";
		LET cCodRet = "01124"; --EL CLIENTE NO TIENE TELÉFONOS REGISTRADOS
        RETURN cCodRet, cTipoTel, sSecuencia, vTelefono, vExtension, cVerificado, dFecha, cCofetel, cStatus, cSucursal, cEmpleado, dFechaHora;
    END IF;	    
    SET ISOLATION TO DIRTY READ;
    
        FOREACH
            SELECT SKIP pNumRegistro FIRST pRecuperacion 
			   CASE
			   WHEN tipo_tel = 1 THEN 
				'TEL. PARTICULAR'
			   WHEN tipo_tel = 2 THEN 
				'TEL. MOVIL'
			   WHEN tipo_tel = 3 THEN 
				'TEL. TRABAJO'
			   WHEN tipo_tel = 4 THEN 
				'OTRO'
			   ELSE 
				' '
			   END AS tipo_TEL,secuencia,telefono, extension,
			   verificado,cofetel,status_tel,user_insert,fecha_hora
               INTO cTipoTel, sSecuencia, vTelefono, vExtension,
			   cVerificado,cCofetel,cStatus,cEmpleado,dFechaHora
             FROM si_telefonos
             WHERE numcte = cNUMCTE
             ORDER BY secuencia DESC
             
			 IF cTipoTel <> 'TEL. MOVIL' THEN
				LET cVerificado = '';
				LET dFecha = '';
			 ELIF cTipoTel = 'TEL. MOVIL' THEN
				FOREACH
					SELECT FIRST 1 fecha INTO dFecha 
					FROM bdinteg:"informix".si_bitsmstels WHERE telefono = vTelefono AND numcte = cNUMCTE ORDER BY fecha DESC
				 END FOREACH;
			 END IF;
			 
			 SELECT sucursal INTO cSucursal FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = cEmpleado;
			 
            LET iCont=iCont+1;  
            RETURN cCodRet,cTipoTel, sSecuencia, vTelefono, vExtension, cVerificado, dFecha, cCofetel, cStatus, cSucursal, cEmpleado, dFechaHora WITH RESUME;
			
			LET cTipoTel = '';
			LET sSecuencia = 0;
			LET vTelefono = '';
			LET vExtension = '';
			LET cVerificado = '';
			LET dFecha = '';
			LET cCofetel = '';
			LET cStatus = '';
			LET cSucursal = '';
			LET cEmpleado = '';
			LET dFechaHora = ''; 
			
        END FOREACH;
        IF iCont = 0 THEN
            LET cCodRet = '1001'; 
            RETURN cCodRet,cTipoTel, sSecuencia, vTelefono, vExtension, cVerificado, dFecha, cCofetel, cStatus, cSucursal, cEmpleado, dFechaHora;
        END IF 	
END
END PROCEDURE
DOCUMENT
"Autor : L. Montserrat León Amador",
"FECHA : 17/05/2019",
"MODIFICACIÓN: Se realiza clonación de SPL sp_cnsif_consulta_telefonos para agregar nuevos campos de retorno (cVerificado, dFecha, cCofetel, cStatus, cSucursal, cEmpleado, dFechaHora).",
"Autor : L. Montserrat León Amador",
"FECHA : 27/05/2019",
"MODIFICACIÓN: Se actualiza el mapeo del tipo de dato para el campo fecha de la tabla bdinteg:si_bitsmstels.",
"Autor : L. Montserrat León Amador",
"FECHA : 14/06/2019",
"MODIFICACIÓN: Se modifica SPL para limpiar variables.";

CREATE PROCEDURE "informix".sp_archivoconsultafolioafore(pFechaDia DATE)

RETURNING
	CHAR(6)	 AS 	Codigo_retorno;

	--DECLARA VARIABLES
	DEFINE	iSqlErr			INTEGER;
	DEFINE	cCodRet			CHAR(6);
	DEFINE 	cFecha			CHAR(8);
	DEFINE cFecha2			CHAR(10);
	DEFINE 	cRuta			CHAR(100);
	DEFINE	cNombreArchivo	CHAR(100);
	DEFINE	cNomArchAux		CHAR(100);
	DEFINE	cSql			CHAR(2500);
	DEFINE 	cConsulta		CHAR(2200);
	
	DEFINE cFecha_Tran char(8);
	DEFINE vCurp char(18);
	DEFINE vPlastico char(4);
	DEFINE vApellidopaterno char(26);
	DEFINE vApellidomaterno char(26);
	DEFINE vNombres char(52);
	DEFINE vFechanacimiento char(8);
	DEFINE vNumtarjeta char(16);
	DEFINE vSexo char(1);
	DEFINE vRfc CHAR(13);
	DEFINE vclvEstado char(2);
	DEFINE vMunicipio char(27);
	DEFINE vCiudad char(60);
	DEFINE vColonia char(32);
	DEFINE vCalle char(30);
	DEFINE vNumExt char(10);
	DEFINE vNumInt char(10);
	DEFINE vTcasa char(1);
	DEFINE vtelefonocasa char(13);
	DEFINE vcompaniatelcasa char(30);
	DEFINE vTcel char(1);
	DEFINE vtelefonoper char(13);
	DEFINE vcompaniatelper char(30);
	DEFINE vToficina char(1);
	DEFINE vtelefonooficina char(13);
	DEFINE vcompaniateloficina char(30);
	DEFINE vPuesto char(60);
	DEFINE vCorreo CHAR(100); 
	DEFINE vNacionalidad CHAR(15);
	DEFINE vPais CHAR(3);
	DEFINE Vnumcte CHAR(20);
	DEFINE vCod_postal CHAR(5);
	DEFINE Vproductoligado CHAR(4);
	DEFINE cvegiroempresa CHAR(3);
	DEFINE dFechaApertcta char(8);
	DEFINE vCod_resp CHAR(3);
	DEFINE vfolioafore CHAR(2);
	--IDB20190620	{
	DEFINE dFechaIni DATETIME YEAR TO SECOND;
	DEFINE dFechaFin DATETIME YEAR TO SECOND;
	--				}


	--INICIALIZA VARIABLES
	LET		iSqlErr			=0;
	LET		cCodRet			='000000';
	LET		cFecha			='';
	LET   	cRuta			='';
	LET   	cNombreArchivo	='';
	LET 	cNomArchAux		='';
	LET   	cSql			='';
	LET     cConsulta		='';
	LET		cvegiroempresa	='';
	--IDB20190620	{
	LET dFechaIni = CURRENT;
	LET dFechaFin = CURRENT;
	--				}
	
	
	

	--INICIO
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;	
		
--	SET DEBUG FILE TO '/informix/c92962301/afore/respuestaAFORE.out';
--		TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
					
						
		IF EXISTS( SELECT dbsname, tabname FROM sysmASter:systabnames  WHERE tabname = 'paso_folioafore' ) THEN
				
				DROP TABLE bdinteg:"informix".paso_folioafore;
				
		END IF;
				
		CREATE TABLE  bdinteg:"informix".paso_folioafore
		( fecha_consulta char(8),
		curp char(18),
		plastico char(4),
		apell_parterno char(26),
		apell_materno char(26),
		nombres char(52),
		fecha_nacimiento char(8),
		sexo char(1),
		rfc char(13),
		cveerror char(3),
		cveestado char(2),
		municipio_delegacion char(27),
		ciudad char(60),
		colonia char(32),
		calle char(30),
		numexterior CHAR(10) ,
		numinterior CHAR(10) ,
		tel_casa char(1) DEFAULT '' NOT NULL,
		num_tel_casa char(13) DEFAULT '' NOT NULL,
		compania_tel_casa CHAR(30) DEFAULT '' NOT NULL,
		tel_oficina char(1) DEFAULT '' NOT NULL,
		num_tel_oficina char(13) DEFAULT '' NOT NULL,
		compania_tel_oficina CHAR(30) DEFAULT '' NOT NULL,
		tel_celular char(1) DEFAULT '' NOT NULL,
		num_tel_cel char(13) DEFAULT '' NOT NULL,
		compania_tel_cel CHAR(30) DEFAULT '' NOT NULL,
		ocupacion char(60),
		email CHAR(100),
		nacionalidad char(15),
		cvepais char(3),
		numcte char(20),
		codigopostal char(5),
		cveproductoligado char(4),
		cvegiroempresa CHAR(3),
		fecha_apercta char(8),
		folio_operacion char(2)
		);								
						
					
					
					
					
		LET cFecha2 = SUBSTR(pFechaDia,1,2)||'-'||SUBSTR(pFechaDia,4,2)||'-'||SUBSTR(pFechaDia,7,4);
		LET cFecha = SUBSTR(pFechaDia,7,4)||SUBSTR(pFechaDia,1,2)||SUBSTR(pFechaDia,4,2);
		
		--IDB20190620 	{
		LET dFechaIni = TO_DATE(cFecha || '00:00:00', "%Y%m%d %H:%M:%S");
		LET dFechaFin= TO_DATE(cFecha || '23:59:59', "%Y%m%d %H:%M:%S");
		--				}
		
		--CONSULTA LA INFORMACION
		FOREACH WITH HOLD
		
		--Datos de la tabla si_folioafore
		SELECT TRIM(fecha_transac),curp_resp,num_tarjeta,SUBSTR(num_tarjeta,13,4),codigo_resp, nvl(numcliente,''),folio_resp
		INTO cFecha_Tran,vCurp,vNumtarjeta,vPlastico,vCod_resp,Vnumcte,vfolioafore
		FROM 	"informix".si_folioafore as A
		INNER JOIN intercard:"informix".tarjeta as B on (a.num_tarjeta = b.numtarjeta)
		--WHERE	TO_CHAR(fecha_insert,'%Y%m%d') = cFecha --IDB20190620 Se modifica el filtro de fecha_insert
		WHERE  a.num_tarjeta not in('4008190000000821') 
		and a.fecha_insert between dFechaIni and dFechaFin
        AND a.codigo_resp='01'
		
		IF Vnumcte <>'' THEN
		
				--Datos	del cliente	
				SELECT apell_paterno ,apell_materno ,nombre1||''||nombre2,rfc,TO_CHAR(fecha_nac,'%Y%m%d')  ,sexo,c.descripcion 
				INTO vApellidopaterno, vApellidomaterno,vNombres,vRfc,vFechanacimiento,vSexo,vNacionalidad
				FROM bdinteg:"informix".si_cliente a
				INNER JOIN bdinteg:"informix".si_ctepf b on a.numcte = b.numcte
				INNER JOIN bdinteg:"informix".si_nacion c on b.nacionalidad = c.nacion
				WHERE a.numcte = Vnumcte;
				
				--DirecciÃ³n del cliente
				SELECT nvl(b.estado,''),nvl(e.municipiozona,''),nvl(d.nombre,''),nvl(e.nombrezona,''),nvl(f.nombrecalle,''),
				nvl(numeroextcalle,''),nvl(numerointcalle,''),nvl(cod_postal,''),nvl(b.pais,'')
				INTO vclvEstado,vMunicipio,vCiudad,vColonia,vCalle,vNumExt,vNumInt,vCod_postal,vPais
				FROM "informix".si_cliente a
				INNER JOIN "informix".si_direcciones_actual b ON a.numcte = b.numcte
				LEFT JOIN "informix".si_estados c on  b.estado = c.estado
				LEFT JOIN "informix".si_ciudades d on b.estado = d.estado AND b.ciudad = d.ciudad
				LEFT JOIN "informix".si_catzonas e on e.numerocolonia =b.numerocolonia AND e.numerociudad = b.numerociudad
				LEFT JOIN "informix".si_catcalles f on b.numerocalle = f.numerocalle
				WHERE a.numcte = Vnumcte
				AND b.tipo_dir = '1';
				
				--Telefonos del cliente
					--telefono de casa del cliente
				SELECT nvl(tipo_tel,''),nvl(telefono,''),nvl(nombre_carrier,'')
				INTO  vTcasa , vtelefonocasa, vcompaniatelcasa 
				FROM si_cliente a
				INNER JOIN "informix".si_telefonos b ON a.numcte = b.numcte
				LEFT JOIN "informix".si_carriers c ON b.carrier = c.cve_carrier
				WHERE a.numcte =Vnumcte
				AND status_tel='A'
				AND tipo_tel ='1'
				AND secuencia in(select max(secuencia) from bdinteg:si_telefonos where numcte =Vnumcte AND status_tel='A'
				AND tipo_tel ='1');
				
				IF vTcasa IS NULL THEN
				LET vTcasa ='';
				LET vtelefonocasa ='';
				LET vcompaniatelcasa='';
				END IF;
				
					--telefono de casa del personal
				SELECT nvl(tipo_tel,''),nvl(telefono,''),nvl(nombre_carrier,'')
				INTO  vTcel , vtelefonoper, vcompaniatelper
				FROM "informix".si_cliente a
				INNER JOIN "informix".si_telefonos b ON a.numcte = b.numcte
				LEFT JOIN "informix".si_carriers c ON b.carrier = c.cve_carrier
				WHERE a.numcte =Vnumcte
				AND status_tel='A'
				AND tipo_tel ='3'
				AND secuencia in(select max(secuencia) from bdinteg:si_telefonos where numcte =Vnumcte AND status_tel='A'
				AND tipo_tel ='3');
				
				IF vTcel IS NULL THEN
				LET vTcel ='';
				LET vtelefonoper ='';
				LET vcompaniatelper='';
				END IF;
				
				
					--telefono de casa del oficina
				SELECT nvl(tipo_tel,''),nvl(telefono,''),nvl(nombre_carrier,'')
				INTO  vToficina , vtelefonooficina, vcompaniateloficina
				FROM "informix".si_cliente a
				INNER JOIN "informix".si_telefonos b ON a.numcte = b.numcte
				LEFT JOIN "informix".si_carriers c ON b.carrier = c.cve_carrier
				WHERE a.numcte =Vnumcte
				AND status_tel='A'
				AND tipo_tel ='2'
				AND secuencia in(select max(secuencia) from bdinteg:si_telefonos where numcte =Vnumcte AND status_tel='A'
				AND tipo_tel ='2');
				
				IF vToficina IS NULL THEN
				LET vToficina ='';
				LET vtelefonooficina ='';
				LET vcompaniateloficina='';
				END IF;
				
					--puesto del cliente
				SELECT UNIQUE nvl(b.descrip,'')
				INTO vPuesto
				FROM "informix".si_bitacoraapertura a
				INNER JOIN "informix".si_actsubact b on  b.id_act =a.id_act and  b.id_subact =a.id_subact
				WHERE numcte = Vnumcte AND id_secuencia IN(SELECT MAX(id_secuencia) FROM si_bitacoraapertura WHERE numcte =Vnumcte AND id_pregunta ='6');
				
				IF vPuesto IS NULL THEN
				LET vPuesto ='';
			
				END IF;
				
			
				--Correo del cliente
				
				SELECT nvl(correo_elec,'') 
				INTO vCorreo
				FROM si_correos
				WHERE numcte =Vnumcte AND status_correo ='A' 
				AND secuencia in (SELECT MAX(secuencia) FROM  si_correos
				WHERE numcte =Vnumcte AND status_correo ='A');
				IF vCorreo is null THEN
				
				LET vCorreo ='';
				END IF;
				-- Datos de la cuenta
						--CaptaciÃ³n
				SELECT producto, TO_CHAR(fecha_alta,'%Y%m%d')
				INTO Vproductoligado,dFechaApertcta 
				FROM bdicheq:"informix".sc_maechq a
				INNER JOIN bdicheq:sc_maenoc b ON a.cuenta = b.cuenta  
				WHERE a.cuenta IN(select  numcuenta FROM intercard:tarjetacuenta WHERE numtarjeta = vNumtarjeta);
						--Credito
				IF Vproductoligado is null THEN
				
				SELECT num_producto , TO_CHAR(fecha_apertura,'%Y%m%d') 
				INTO Vproductoligado,dFechaApertcta 
				from bdicred:"informix".sd_maecred
				WHERE num_credito IN(SELECT  numcuenta from intercard:tarjetacuenta WHERE numtarjeta = vNumtarjeta);		
				
				END IF;
			
			--IDB20190528 { Se agregan NVL a todas las variables para que ninguna se inserte en NULL
			 INSERT INTO "informix".paso_folioafore(fecha_consulta,curp,plastico,apell_parterno,apell_materno,nombres,fecha_nacimiento,sexo,rfc,cveerror,
			cveestado,municipio_delegacion,ciudad,colonia,calle,numexterior,numinterior,tel_casa,num_tel_casa ,compania_tel_casa ,tel_oficina,num_tel_oficina ,compania_tel_oficina ,
			tel_celular,num_tel_cel,compania_tel_cel ,ocupacion ,email ,nacionalidad,cvepais ,numcte,codigopostal,cveproductoligado,cvegiroempresa ,fecha_apercta,
			folio_operacion) VALUES(NVL(cFecha_Tran,''), 		NVL(vCurp,''), 				NVL(vPlastico,''),
									NVL(vApellidopaterno,''),	NVL(vApellidomaterno,''),	NVL(vNombres,''),
									NVL(vFechanacimiento,''),	NVL(vSexo,''),				NVL(vRfc,''),
									NVL(vCod_resp,''),			NVL(vclvEstado,''),			NVL(vMunicipio,''),
									NVL(vCiudad,''),			NVL(vColonia,''),			NVL(vCalle,''),
									NVL(vNumExt,''),			NVL(vNumInt,''),			NVL(vTcasa,''),
									NVL(vtelefonocasa,''),		NVL(vcompaniatelcasa,''),	NVL(vToficina,''),
									NVL(vtelefonooficina,''),	NVL(vcompaniateloficina,''),NVL(vTcel,''),
									NVL(vtelefonoper,''),		NVL(vcompaniatelper,''),	NVL(vPuesto,''),
									NVL(vCorreo,''),			NVL(vNacionalidad,''),		NVL(vPais,''),
									NVL(Vnumcte,''),			NVL(vCod_postal,''),		NVL(Vproductoligado,''),
									NVL(cvegiroempresa,''),		NVL(dFechaApertcta,''),		NVL(vfolioafore,'')
									); 
			--IDB20190528
		END IF;	 
			 
		END foreach;
--		LET cConsulta =	"select * from bdinteg:paso_folioafore;";
		--IDB20190528 { Se agregan RPAD y TRIM a los campos que no lo tenian, ademas se agrega REPLACE en los numero de casa int y ext
		LET cConsulta =	"select RPAD(TRIM(fecha_consulta),8,' '),	RPAD(TRIM(curp),18,' '),				RPAD(TRIM(plastico),4,' '), " ||
								"RPAD(trim(apell_parterno),26,' '),	RPAD(trim(apell_materno),26,' '),		RPAD(trim(nombres),52,' '), " ||
								"RPAD(TRIM(fecha_nacimiento),8,' '),RPAD(TRIM(sexo), 1, ' '),				RPAD(trim(rfc),13,' ')," ||
								"RPAD(trim(cveestado),2,' '),		RPAD(trim(municipio_delegacion),27,' '),RPAD(trim(ciudad),60,' ')," ||
								"RPAD(trim(colonia),32,' '),		RPAD(trim(calle),30,' ')," ||
								"RPAD(REPLACE(trim(numexterior),'\',''),10,' ')," ||
								"RPAD(REPLACE(trim(numinterior),'\',''),10,' ')," ||
								"RPAD(trim(tel_casa),1,' '),		RPAD(trim(num_tel_casa),13,' '),	 RPAD(trim(compania_tel_casa),30,' ')," ||
								"RPAD(trim(tel_oficina),1,' '),		RPAD(trim(num_tel_oficina),13,' '),	 RPAD(trim(compania_tel_oficina),30,' '),"||
								"RPAD(trim(tel_celular),1,' '),		RPAD(trim(num_tel_cel),13,' '),		 RPAD(trim(compania_tel_cel),30,' ')," ||
								"RPAD(trim(ocupacion),60,' '),		RPAD(trim(email),100,' '),			 RPAD(trim(nacionalidad),15,' ')," ||
								"RPAD(trim(cvepais),3,' '),			RPAD(trim(numcte),20,' '),			 RPAD(trim(codigopostal),5,' ')," ||
								"RPAD(trim(cveproductoligado),4,' '),RPAD(trim(cvegiroempresa),3,' '),	 RPAD(TRIM(fecha_apercta),8,' ')," ||
								"RPAD(TRIM(folio_operacion),2,' ') " ||
						"from bdinteg:paso_folioafore;"; 
		--IDB20190528 }
		
--		LET cConsulta =	"select TRIM(fecha_consulta)||TRIM(curp)||TRIM(plastico)||TRIM(apell_parterno)||TRIM(apell_materno)||nombres||TRIM(fecha_nacimiento)||TRIM(sexo)||TRIM(rfc)||TRIM(cveerror)||TRIM(cveestado)||TRIM(municipio_delegacion)||TRIM(ciudad)||TRIM(colonia)||TRIM(calle)||TRIM(numexterior)||TRIM(numinterior)||TRIM(tel_casa)||TRIM(num_tel_casa)||TRIM(compania_tel_casa)||TRIM(tel_oficina)||TRIM(num_tel_oficina)||TRIM(compania_tel_oficina)||TRIM(tel_celular)||TRIM(num_tel_cel)||TRIM(compania_tel_cel)||TRIM(ocupacion)||TRIM(email)||TRIM(nacionalidad)||TRIM(cvepais)||TRIM(numcte)||TRIM(codigopostal)||TRIM(cveproductoligado)||TRIM(cvegiroempresa)||TRIM(fecha_apercta)||TRIM(folio_operacion) AS descripcion from bdinteg:paso_folioafore;";		
		--CREACION DE REPORTE EN ARCHIVO .TXT	
		--RUTA PARA GENERAR EL ARCHIVO
				
		SELECT valor
		INTO cRuta
		FROM "informix".si_param  
		WHERE empresa = '001' 
		AND cod_param=250;
		
		--SINO EXISTE LA RUTA DEL ARCHIVO	
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000001';
			RETURN cCodRet;
		END IF;	
			
		--GENERA EL NOMBRE DEL ARCHIVO
		LET cNombreArchivo = TRIM('AFO_DATOS')||'_'||TRIM(cFecha)||'.log';
		LET cNomArchAux = TRIM('AFO_DATOS_CONCILIAX')||'_'||TRIM(cFecha)||'.log';
			
		--CREACION DE TEMPORALESS USADOS PARA LA CREACION DE ARCHIVO
		LET cSql = 'echo "unload to ' || TRIM(cRuta) ||   TRIM(cNomArchAux) ||  ' DELIMITER ' || '''|''' ||' '|| TRIM(cConsulta)||'" >' || TRIM(cRuta) || 'query1.sql';
		SYSTEM cSql;

		LET cSql = 'dbaccess bdinteg ' || TRIM(cRuta) || 'query1.sql';
		SYSTEM TRIM(cSql);
		
		-- ELIMINAR EL PIPE "|" DEL ARCHIVO DE TRABAJO
		LET cSql = "sed 's/|//g' "|| TRIM(cRuta) || TRIM(cNomArchAux) || " >> " ||  TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;
		
		

		--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
		LET cSql = 'rm ' || TRIM(cRuta) || 'query1.sql';
		SYSTEM cSql;   

		LET cSql = 'rm ' || TRIM(cRuta) || TRIM(cNomArchAux );
		SYSTEM cSql; 
		DROP TABLE bdinteg:"informix".paso_folioafore;
		--RETURN PRINCIPAL
		RETURN cCodRet;
	END
END PROCEDURE
DOCUMENT
'AUTOR: Jesus Ernesto Aguilera Inda.',
'DESCRIPCIÃN: SP que genera un archivo .txt donde se guardan las consultas efectivas de folio afore.',
'FOLIO:1420',
'FECHA:27/03/2014',
'VERSIÃN: 20140327.1606',
'BASE DE DATOS: bdinteg',
'Folio.........: 1920-INC_DESFASE_ARCHIVOAFORE',
'Autor.........: 95526749 - JesÃºs Horacio LÃ³pez GonzÃ¡lez',
'Fecha.........: 28/05/2019 - IDB20190528',
'..............: 20/06/2019 - IDB20190620',
'ModificaciÃ³n..: IDB20190528: Se modifica para que no se guarden valores en NULL y remplazar el caracter \ en los num de casa para que no haya desfase.',
'..............: IDB20190620: Se modifica para bajar los costos de la consulta principal',
'Sustento......: IDB20190528: Se definiÃ³ por correo, el dÃ­a 21/05/2019, correo enviado por Jose Angel Gaxiola Gaxiola.',
'..............: IDB20190620: Se definiÃ³ por correo, el dia 18/06/2019, correo enviado por Cutberto Gonzalez Perez.',
'Solicita......: Cutberto Gonzalez',
'BD............: bdinteg';

CREATE PROCEDURE "informix".sp_obtieneinfprod(Tipot CHAR(1), pBin CHAR(6),pSubBin CHAR(2), pCodProdCta CHAR(4), pClavetp CHAR(3))
   RETURNING CHAR(5), CHAR(2), CHAR(6), CHAR(2), CHAR(3), CHAR(4), CHAR(3);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cIdBin              CHAR(2);
   DEFINE cCodBin             CHAR(6);
   DEFINE cProd               CHAR(2);
   DEFINE cCodProd            CHAR(3);
   DEFINE cCodProdCta		  CHAR(4);
   DEFINE cClavetp            CHAR(3);
     
   LET cCodRet        ='00000';   
   LET cIdBin		  ='00';
   LET cCodBin        ='000000';
   LET cProd		  ='00';
   LET cCodProd       ='000';
   LET cCodProdCta    ='0000';
   LET cClavetp       ='000';
         
BEGIN
                  ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp;
                      END IF;
                  END EXCEPTION;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;

           /*SELECT DISTINCT idbinproducto, a.bin, producto, a.codproductotarjeta, codprodcta, clave
		   INTO cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp
		   FROM intercard:binproducto a, intercard:tipotarjeta b
		   WHERE a.codproductotarjeta = b.codproductotarjeta 
           AND producto = pSubBin
           AND codprodcta = pCodProdCta
		   AND Tipo = Tipot 
		   AND a.bin = pBin
           AND clave = pClavetp;    */
            
           IF EXISTS (SELECT DISTINCT codprodcta 
                     FROM intercard:binproducto a INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                     WHERE a.bin= pBin AND codprodcta = pCodProdCta) THEN 

                SELECT DISTINCT idbinproducto, a.bin, producto, a.codproductotarjeta, codprodcta, clave 
                INTO cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp
                FROM intercard:binproducto a
                INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
                WHERE a.bin = pBin 
                AND a.producto= pSubBin 
                AND b.clave = pClavetp
                AND a.codprodcta = pCodProdCta;
           ELSE
				--RETURN '00002';
                 LET  cCodRet = '00001';
		   END IF;         

           IF cCodBin IS NULL or cCodProd IS NULL THEN
                      LET  cCodRet = '00001';
           END IF;

           RETURN cCodRet, cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Dr. Rorro Mendoza',
'FECHA: 20/10/2017',
'BD: Intercard',
'Objetivo: Se crea procedimiento para obtener información del producto de la cuenta.';

CREATE PROCEDURE "informix".sp_dicta_modificaciondictamen(pNumcte CHAR(20), pSituacion CHAR(4), pCausa SMALLINT, pUsuario CHAR (20))


	--RETORNOS -
	RETURNING
	CHAR(6) AS codret;


	--DECLARACION DE LAS VARIABLES--
	DEFINE iSql_err		    INTEGER; 
	DEFINE cCodret		    CHAR(6);



	--INICIALIZACION DE VARIABLES--
	LET iSql_err		     = 0;
	LET cCodret		         = '000000';


	--INICIO--
	BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
	IF iSql_err <> 0 THEN
		LET cCodret = iSql_err;
		RETURN TRIM(cCodret);
	END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/LuisMadrid/sp_consultaempleadowu.out';
	--TRACE ON;	 
	
	SET ISOLATION TO DIRTY READ;		
	SET LOCK MODE TO WAIT 3;

	--SE VALIDA QUE SE MANDEN TODOS LOS PARAMETROS (NO NULOS NI VACIOS) YA QUE SON NECESARIOS TODOS
	IF NVL(pNumcte,'') = '' OR NVL(pSituacion,'')  = '' OR NVL(pCausa,'') = '' OR NVL(pUsuario,'') = '' THEN
	    LET cCodret = '000001'; 
	RETURN TRIM(cCodret);

	END IF;		  

	--************************************************************************************
	---------------****************BLOQUE DE CONSULTA*************************************
	--************************************************************************************
	UPDATE bdisitesp: "informix".se_ctessitespcte
			SET situacion = pSituacion, causa = pCausa, usrmodifica = pUsuario, fchmodifica = CURRENT
			WHERE numcte = pNumcte;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000002'; 
	RETURN TRIM(cCodret);
	END IF;

	DELETE FROM "informix".si_bitacora_dictamenes  WHERE numcte = pNumcte;

	
	RETURN TRIM(cCodret);					
			
END;
END PROCEDURE
DOCUMENT
'AUTOR: 97122114, Luis Alberto Madrid Castro',
'FOLIO: 230142 - 1530  - EvaluaciÃ³n de Resultados de ComparaciÃ³n de Huellas en LÃ­nea en Alta de Cliente ',
'DESCRIPCION: creacion de sp_dicta_ModificacionDictamen para poder modificar dictamines.',
'FECHA: 01/01/2015',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_desfusion_ctesdigital(pCteTit CHAR(20), pTramaDetalle CHAR(200), pIdentificador CHAR(1))
--RETORNOS-
RETURNING
CHAR(6) AS codret,
CHAR (30) AS Descripcion,
CHAR (30) AS Tabla1,
CHAR (30) AS Tabla2,
CHAR (30) AS Tabla3;

--DECLARACION DE VARIABLES--
DEFINE iSql_err		INTEGER;
DEFINE cDescErr		CHAR(30);
DEFINE cCodret		CHAR(6);
DEFINE cBandVal		CHAR(1);
DEFINE iFin			INTEGER;
DEFINE iIni			INTEGER;
DEFINE cNumcteInco	CHAR(20);
DEFINE cCodigoDig	CHAR(5);
DEFINE cSecuencia	CHAR(5);
DEFINE cSecActual	CHAR(5);
DEFINE cCuenta 		CHAR(20);
DEFINE cProducto	CHAR(5);
DEFINE cTabla		CHAR(25);
DEFINE cTabla1		CHAR(25);
DEFINE cTabla2		CHAR(25);
DEFINE iExiste		INTEGER;

DEFINE v_ruta       CHAR(50);
DEFINE v_nomarch    CHAR(20);
DEFINE vc_CodRet    CHAR(5);
DEFINE isam_err  	INT;

--INICIALIZACION DE VARIABLES--
LET iSql_err		= 0;
LET cDescErr    	= '';
LET cCodret			= '000000';
LET cBandVal		 = '';
LET iFin			= 0;
LET iIni			= 0;
LET cNumcteInco 		= '';
LET cCodigoDig		= '';
LET cSecuencia		= '';
LET cSecActual		= '';
LET cCuenta			= '';
LET cProducto		= '';
LET cTabla			= '';
LET cTabla1			= '';
LET cTabla2			= '';
LET iExiste			= 0;

LET v_ruta			= "";
LET v_nomarch		= "";
LET vc_CodRet 		= "00000";
--LET isam_err="0"; es cCodret

--INICIO--
BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN NVL(TRIM(cCodret),''), cDescErr, cTabla, cTabla1, cTabla2;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/josea/sp_desfusion_ctesdigital.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF pIdentificador = '1' THEN

		LET cBandVal = '1';
		LET iIni = 1;

		LET cNumcteInco = '';
		LET cCodigoDig = '';
		LET cSecuencia = '';
		LET cSecActual = '';
		LET iFin = 0;

		SELECT TRIM(valor) INTO v_ruta FROM bdinteg@coppel_tcp:si_param WHERE cod_param=122;
		--SE EXTRAE EL NUMERO DE CTE INCORRECTO DE LA TRAMA
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cNumcteInco = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - 1));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';
		--SE EXTRAE EL CODIGO DE DIGITALIZACION
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cCodigoDig = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1 ;
			END IF;
		END WHILE

		LET cBandVal = '1';
		--SE EXTRAE LA SECUENCIA QUE CONTABA CTE ANTES DE LA FUSION
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cSecuencia = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';
		--SE EXTRAE LA SECUENCIA ACTUAL
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cSecActual = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		--DG_EXPEDIENTE
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente';
			LET cTabla = 'dg_expediente';
			UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			WHERE cliente = TRIM(pCteTit)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecActual;
		END IF;


		--dg_expediente_img1
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img1 WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente_img1';
			LET cTabla1 = 'dg_expediente_img1';
			UPDATE bdidigital@coppelimg_tcp:"informix".dg_expediente_img1 SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			WHERE cliente = TRIM(pCteTit)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecActual;
		END IF;

        --DG_EXPEDIENTE_IMG
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente_img';
			LET cTabla2 = 'dg_expediente_img';
			UPDATE bdidigital@coppelimghis_tcp:"informix".dg_expediente_img SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			WHERE cliente = TRIM(pCteTit)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecActual;
		END IF;

		--DG_EXPEDIENTE_IMG_HIS
		--SELECT NVL(COUNT(*),0) INTO iExiste FROM "informix".dg_expediente_img_his WHERE cliente = TRIM(pCteTit);
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente_img_his';
			LET cTabla2 = 'dg_expediente_img_his';
			--UPDATE "informix".dg_expediente_img_his SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			UPDATE bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his SET cliente = TRIM(cNumcteInco), secuencia = TRIM(cSecuencia)
			WHERE cliente = TRIM(pCteTit)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecActual;
		END IF;


	ELIF pIdentificador = '2' THEN

		LET cBandVal = '1';
		LET iIni = 1;

		LET cNumcteInco = '';
		LET cCuenta = '';
		LET cProducto = '';
		LET cCodigoDig = '';
		LET cSecuencia = '';
		LET iFin = 0;

		--SE EXTRAE EL NUMERO DE CLIENTE INCORRECTO DE LA TRAMA.
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cNumcteInco = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - 1));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';

		--SE EXTRAE EL NUMERO DE CUENTA DE LA TRAMA.
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cCuenta = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1 ;
			END IF;
		END WHILE

		LET cBandVal = '1';

		--SE EXTRAE EL PRODUCTO DE LA TRAMA.
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cProducto = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';

		--SE EXTRAE EL CODIGO DE DIGITALIZACION.
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cCodigoDig = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		LET cBandVal = '1';

		--SE EXTRAE SECUENCIA  DE LA TRAMA
		WHILE cBandVal = '1'
			LET iFin = iFin + 1;
			IF SUBSTR(pTramaDetalle,iFin,1) = '|' THEN
				LET cBandVal = '0';
				LET cSecuencia = TRIM(SUBSTR(pTramaDetalle,iIni,iFin - iIni));
				LET iIni = iFin + 1;
			END IF;
		END WHILE

		---DG_EXPEDIENTE
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimg_tcp:"informix".dg_expediente WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente';
			LET cTabla = 'dg_expediente';
			INSERT INTO bdidigital@coppelimg_tcp:"informix".dg_expediente (empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif)
			SELECT empresa, cliente, cuenta, producto, cod_docto, secuencia, prod_nombre, descrip2, usuario_alta, fecha_alta, usuario_modif, fecha_modif 
			FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_fus
			WHERE cliente = TRIM(cNumcteInco)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecuencia;
		END IF;

		----dg_expediente_img1
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img1 WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
			LET cDescErr = 'dg_expediente_img1';
			LET cTabla1 = 'dg_expediente_img1';
			INSERT INTO bdidigital@coppelimg_tcp:"informix".dg_expediente_img1 (empresa, cliente, cod_docto, secuencia, imagen,	imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif)
			SELECT {+INDEX ("informix".dg_expediente_img1_fus idx_expediente_img_fus)} empresa, cliente, cod_docto, secuencia, imagen, imagen_formato, observaciones, usuario_alta, fecha_alta, usuario_modif, fecha_modif 
			FROM bdidigital@coppelimg_tcp:"informix".dg_expediente_img1_fus
			WHERE cliente = TRIM(cNumcteInco)
			AND cod_docto = cCodigoDig
			AND secuencia = cSecuencia;
		END IF;
		
		--DG_EXPEDIENTE_IMG
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
		
			SELECT COUNT (*)
			INTO iExiste 
			FROM bdidigital@coppelimg_tcp:dg_expediente_img_fus WHERE cliente = cNumcteInco; 
			
			IF iExiste >= 1 THEN
				LET cDescErr = 'dg_expediente_img';
				LET cTabla2 = 'dg_expediente_img';
				LET v_nomarch=TRIM(cNumcteInco)||'.unl';
				CALL bdidigital@coppelimg_tcp:sp_respalda_imgfus(cNumcteInco,v_nomarch,v_ruta) RETURNING vc_CodRet,cCodret,cDescErr;
				IF vc_CodRet="00000" THEN
					CALL bdidigital@coppelimghis_tcp:sp_carga_imgfus(cNumcteInco,v_nomarch,v_ruta) RETURNING vc_CodRet,cCodret,cDescErr;
				END IF;
			END IF;
		END IF;
		
		
		----DG_EXPEDIENTE_IMG_HIS
		--SELECT NVL(COUNT(*),0) INTO iExiste FROM "informix".dg_expediente_img_his WHERE cliente = TRIM(pCteTit);
		SELECT NVL(COUNT(*),0) INTO iExiste FROM bdidigital@coppelimghis_tcp:"informix".dg_expediente_img_his WHERE cliente = TRIM(pCteTit);
		IF iExiste > 0 THEN
		
			SELECT COUNT (*)
			INTO iExiste 
			FROM bdidigital@coppelimg_tcp:dg_expediente_img_fus_his WHERE cliente = cNumcteInco; 
		
			IF iExiste >= 1 THEN
				LET cDescErr = 'dg_expediente_img_his';
				LET cTabla2 = 'dg_expediente_img_his';
				LET v_nomarch=TRIM(cNumcteInco)||'.unl';
				CALL bdidigital@coppelimg_tcp:sp_respalda_imgfus_his(cNumcteInco,v_nomarch,v_ruta) RETURNING vc_CodRet,cCodret,cDescErr;
				IF vc_CodRet="00000" THEN
					CALL bdidigital@coppelimghis_tcp:sp_carga_imgfus_his(cNumcteInco,v_nomarch,v_ruta) RETURNING vc_CodRet,cCodret,cDescErr;
				END IF;
			END IF;
		END IF;

	END IF

	RETURN NVL(TRIM(cCodret),''), cDescErr, cTabla, cTabla1, cTabla2;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: ',
'FECHA: 16/01/2014',
'BASE DE DATOS: bdinteg OLTP',
'Sustento: Desfusion de Clientes v1.4.doc',
'CREADOR:Vazquez Herrera Hugo ',
'VERSION:1043 ',
'RQI64093',
'FECHA: 20/05/2015',
'Se agrega filtro por campo secuencia al realizar las consultas por las tablas dg_expediente_fus, dg_expediente_img_fus y dg_expediente_img_fus_his',
'para que inserte la informaciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n en las tablas dg_expediente, dg_expediente_img1 y dg_expediente_img_his',
'Autor: Rocio MÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¡rquez',
'---------------------',
'SUSTENTA: RQI 64 127',
'FECHA: 09/11/2015',
'MODIFICACIÃÂÃÂÃÂÃÂ?N: Se modifica para especificar instancia de imagenes correcta de acuerdo al tipo de imagen (historica o actual)',
'NOTA: Este SP se debe instalar en la instancia PRIMARIA de imagenes',
'----------------------------------------------',
'SUSTENTA: RQI 64 132',
'FECHA: 08/12/2015',
'AUTOR: Brenda Kareli Camargo Preciado',
'MODIFICACION: La modificacion consiste en tomar en cuenta la tabla: dg_expediente_img';

CREATE PROCEDURE "informix".sp_altas_idbox2_totales_exp3(
                                        pFechIni DATE, 
                                        pFechFin DATE,
                                        pUsuario CHAR(8))
        
		RETURNING  INTEGER as CodErr, 
		INTEGER as total_registros;
        
        DEFINE iSqlErr 			INTEGER;
        DEFINE  i_NoRegistros   INTEGER;
        
        LEt iSqlErr          = 0;
        LET i_NoRegistros    = 0;

        BEGIN
			ON EXCEPTION SET iSqlErr
				IF iSqlErr <> 0 THEN
					RETURN iSqlErr, i_NoRegistros;          
				END IF;
			END EXCEPTION;                                                                         
			
			-- TOTAL DE ALTAS CON IDBOX
			SET ISOLATION TO DIRTY READ;
			INSERT INTO bdicnweb:"informix".sw_tmp_idbx 
			SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_sucursal2)} 0, a.sucursal, nvl(c.total,0) as Altas_Total, nvl(b.total,0) as Tot_Idb, pUsuario as usuario
			FROM "informix".si_sucursales a
			LEFT JOIN(  --OBTENIENDO TODOS LOS CLIENTES TITULARES DE LA TABLA DE SI_CLIENTE EN UN RANGO DE FECHAS
						SELECT clientes.sucursal AS sucursal, count(DISTINCT(clientes.numcte)) AS total FROM 
								(SELECT distinct (si_cliente.numcte), sucursal 
								FROM "informix".si_cliente   
                                    INNER JOIN "informix".si_ctepf si_ctepf 
                                            ON si_cliente.numcte = si_ctepf.numcte  
								WHERE tipo_cliente='1' AND si_cliente.fecha_insert BETWEEN pFechIni AND pFechFin ) clientes
						INNER JOIN
						-- OBTENIENDO LOS DATOS DE LA BITACORA DE IDBOX
								(SELECT numcte, sucursal 
								FROM "informix".si_bitacora_ife
								WHERE date(fecha) BETWEEN pFechIni AND pFechFin AND modelo_ife<>'') bitacora
						ON clientes.numcte=bitacora.numcte AND clientes.sucursal=bitacora.sucursal
						GROUP BY clientes.sucursal
					) b ON a.sucursal=b.sucursal
			LEFT JOIN ( --OBTENIENDO ALTAS POR SUCURSAL
						SELECT sucursal, COUNT(DISTINCT (si_cliente.numcte)) AS total
						FROM "informix".si_cliente
                        INNER JOIN "informix".si_ctepf si_ctepf 
                                ON si_cliente.numcte = si_ctepf.numcte  
						WHERE tipo_cliente='1' AND si_cliente.fecha_insert BETWEEN pFechIni AND pFechFin
						GROUP BY sucursal
					)C ON a.sucursal=C.sucursal
			WHERE a.empresa ='001'
			AND a.sucursal IN (SELECT DISTINCT(sucursal) FROM "informix".si_bitacora_ife);                                

			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(*) 
			INTO i_NoRegistros
			FROM bdicnweb:"informix".sw_tmp_idbx 
			WHERE usuario=pUsuario;                                                                  
	
			RETURN iSqlErr, i_NoRegistros;                                          
		END
END PROCEDURE
DOCUMENT 'AUTOR: Lic Miguel Huitzil Cuachayo',
'FECHA: 20/10/2016',
'DESCRIPCION: Se realizo la modificacion para insertar datos a tabla fisica',
'BD: bdinteg',
'AUTOR: Luis Ignacio PÃ©rez Cano',
'FECHA: 13/07/2017',
'DESCRIPCION: Se ajusta la consulta agregando INNER JOIN con la tabla si_ctepf y la condiciÃ³n modelo_ife<>''',
'se elimina ademas la condiciÃ³n sucursal=S',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_sorteobancoppel(p_canal INT,
												p_tpoper INT,
												p_producto INT,
												p_numcte CHAR(9),
												p_sucursal CHAR(4),
												p_foliosuc CHAR(16),
												p_importe MONEY(16,2),
												p_fecha DATE)
RETURNING CHAR(6) AS cod_Ret,CHAR(80) AS mensaje,INTEGER AS rango_ini,INTEGER AS rango_fin;

DEFINE  SQL_ERR			INTEGER;
DEFINE  ISAM_ERR		INTEGER;
DEFINE  ERROR_INFO		VARCHAR(80);
DEFINE  P_COD_RET		VARCHAR(6);
DEFINE  P_MENSAJE		VARCHAR(80);
DEFINE  v_RangoIni		INTEGER;
DEFINE  v_RangoFin		INTEGER;
DEFINE  v_cvesorteo		VARCHAR(6);
DEFINE  v_part1			INTEGER;
DEFINE  v_part2			INTEGER;
DEFINE  v_part3			INTEGER;
DEFINE  v_part4			INTEGER;
DEFINE  v_numbol		INTEGER;
DEFINE  v_persona		INTEGER;
DEFINE  ciclo			INTEGER;
DEFINE  boleto			INTEGER;
DEFINE  boleto_ini		INTEGER;  	 --FMV 24-AGO-10
DEFINE  boleto_fin		INTEGER;
DEFINE v_cltemoral		VARCHAR(10); --FMV 25-AGO-10
DEFINE v_param			CHAR(5);  	 --BGM 14-Sep: se incorpora uso de parÃ¡metro para traer clave de sorteo normal 2010.
DEFINE Vnumcte			CHAR(10);    --RRG
DEFINE Vtpo_persona		CHAR(2);     --RRG
--dsb-10/10/2012
DEFINE cFolio			CHAR(16);
DEFINE cFolio_cupon		CHAR(20);
DEFINE cTicket			CHAR(2);
DEFINE cFecha			CHAR(19);
DEFINE vNumcteParticipa	INTEGER;     --IREB 26-JUL-19 CAMBIO DE TIPO DE CHAR(20) A INTEGER PARA EL CAMBIO DE LA CONSULTA
DEFINE vProd 			INTEGER;

--*********************************************************--

-- Modificado por: Francisco Martinez Viveros	
-- Fecha Modifica: 24/SEPTIEMBRE/2010 
-- Objetivo: Asignacion del Rango de boletos por transaccion mayor a $650
-- MODIFICADO POR: RaÃºl RamÃ­rez Galindo
-- Fecha ModificaciÃ³n: 05/Diciembre/2011
-- Objetivo:Agilizar la Consulta en Corresponsales.

--*********************************************************--

LET P_COD_RET 		 = '00000';
LET P_MENSAJE 		 = 'PROCESO EXITOSO';
LET v_RangoIni 		 = 0;
LET v_RangoFin 		 = 0;
LET v_part1 		 = 0;
LET v_part2			 = 0;
LET v_part3			 = 0;
LET v_part4			 = 0;
LET v_persona		 = 1;  --FMV 18-AGO-10: Todas los clientes son fisicos 01, se controla a los morales en si_cltenoparticipa
LET v_cvesorteo		 = '';
LET SQL_ERR          = 0;
LET ISAM_ERR         = 0;
LET ERROR_INFO       = '';
LET v_numbol         = 0;
LET ciclo            = 1;
LET boleto           = 0;
LET boleto_ini       = 0;  	--FMV 24-AGO-10
LET boleto_fin       = 0;
LET v_cltemoral      = ''; 	--FMV 25-AGO-10
LET Vnumcte          = '';  --RRG
LET Vtpo_persona     = '';  --RRG
--dsb-10/10/2012
LET cFolio			 = '';
LET cFolio_cupon	 = '';
LET cTicket			 = '';
LET cFecha			 = YEAR(p_fecha)||'-'||MONTH(p_fecha)||"-"||DAY(p_fecha)||" "||CURRENT HOUR TO SECOND;
LET vNumcteParticipa = 0;
LET vProd			 = 0;


BEGIN

	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET    = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO;
		RETURN P_COD_RET, P_MENSAJE,v_RangoIni,v_RangoFin;
	END EXCEPTION;

  --SET DEBUG FILE TO "/home/JA/JA-Sorteo-Clases-2013/sorteobancoppel.out";
  --TRACE ON;   

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

	-- BGM 14-Sep: se incorpora uso de parÃ¡metro para traer clave de sorteo normal 2010.
	SELECT valor INTO v_param 
	FROM bdinteg:"informix".si_param
	WHERE cod_param = 118;

-- jom	FOREACH
	SELECT {+INDEX (si_sorteo idx_si_sorteo)}
	cve_sorteo
	INTO v_cvesorteo
	FROM bdinteg:"informix".si_sorteo
	WHERE  p_fecha  BETWEEN f_ini AND f_fin
	AND cve_sorteo = v_param; 	-- BGM 14-Sep: se incorpora uso de parÃ¡metro para traer clave de sorteo normal 2010.

	IF v_cvesorteo = '' OR v_cvesorteo IS NULL THEN
		LET P_COD_RET = '116';   -- FMV 24sep10 Se adiciona codigo
		LET P_MENSAJE = 'NO EXISTE SORTEOS ACTIVOS EN ESTA FECHA';
	ELSE                
		IF p_tpoper = 12 THEN  
			LET v_persona = 1;
			LET p_producto = 9999;
		ELSE
				----- SE MODIFICA PARA AGILIZAR LA CONSULTA EN CORRESPONSALES
			   SELECT {+INDEX (si_cltenoparticipa idx_si_cltenoparticipa)}numcte, tpo_persona
				 INTO Vnumcte, Vtpo_persona
				 FROM bdinteg:"informix".si_cltenoparticipa 
				WHERE numcte = p_numcte;
					
				IF Vnumcte <> '' THEN
				   IF Vnumcte IS NOT NULL THEN						
					  LET v_persona  = 0;                      
					  LET v_cltemoral = p_numcte;
				   END IF;
			   END IF;
		END IF;
		
		IF (p_tpoper = 10 OR  p_tpoper = 11) AND v_cltemoral = p_numcte
										  THEN -- FMV 19-AGO-10: SE ADICIONA CANDADO
			LET v_persona = 0;                                     
		END IF;
		IF (p_tpoper = 10 OR  p_tpoper = 11) AND v_cltemoral <> p_numcte
										  THEN -- FMV 19-AGO-10: SE ADICIONA CANDADO
			LET v_persona = 1;                                     
		END IF;
		
		SELECT {+INDEX (si_participa idx_si_participa)}
		SUM(CASE WHEN tipo_participa = '1' AND id_elemento = p_producto THEN 1 ELSE 0 END) prod,
		SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper THEN 1 ELSE 0 END) trans,
		SUM(CASE WHEN tipo_participa = '3' AND id_elemento = p_canal THEN 1 ELSE 0 END) canal,
		SUM(CASE WHEN tipo_participa = '4' AND id_elemento = v_persona THEN 1 ELSE 0 END) tpo_per,
		SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper  THEN (p_importe / val_min)::INT  ELSE 0 END) numbol
		--SUM(CASE WHEN tipo_participa = '2' AND id_elemento = p_tpoper AND p_importe  >= val_min THEN 1 ELSE 0 END) numbol --cumple con el minimo para entregarle boleto
		INTO v_part1,v_part2,v_part3,v_part4,v_numbol
		FROM bdinteg:"informix".si_participa
		WHERE cve_sorteo = v_cvesorteo;

		IF v_part1 = 1 AND v_part2 = 1 AND v_part3 = 1 AND v_part4 = 1 AND v_numbol > 0 THEN
			
			----- SE AGREGA PARA CONSULTAR EN TABLA DE CLIENTES Y EMPLEADOS.
			
			
			--SELECT {+INDEX (bdinteg:"informix".si_empleado_cliente_coppel idx_cte_emp2)} numcte
			--INTO vNumcteParticipa
			--FROM bdinteg:"informix".si_empleado_cliente_coppel
			--WHERE numcte = p_numcte
			--AND status = '1';
			
			--IF vNumcteParticipa <> '' OR vNumcteParticipa IS NOT NULL THEN
			
			
			SELECT COUNT(numcte)
			INTO vNumcteParticipa
			FROM bdinteg:"informix".si_empleado_cliente_coppel
			WHERE numcte = p_numcte
			AND status = '1';
			
			IF vNumcteParticipa > '0' THEN
				LET P_MENSAJE  = 'CLIENTE NO PARTICIPA';
			ELSE			
				-- SORTEO DF 
				
				
				SELECT COUNT(producto)
				INTO vProd
				FROM bdicheq:"informix".sc_maechq 
				WHERE num_cte = p_numcte AND producto = '1300' AND empresa = '001';
				
				IF vProd > 0 THEN 
				--IF EXISTS(SELECT producto FROM bdicheq:"informix".sc_maechq WHERE num_cte = p_numcte AND producto = '1300' AND empresa = '001') THEN
					--'ES EMPLEADO';
				ELSE
					--PIDE BOLETOS
					EXECUTE PROCEDURE bdinteg:"informix".sp_asigna_boletos(v_cvesorteo, v_numbol, p_fecha)
					INTO P_COD_RET,P_MENSAJE, v_RangoIni, v_RangoFin;

					/*--INSERTA BOLETOS*/
					IF P_COD_RET = '00000' THEN
						--LET boleto_ini = v_RangoIni;
						--LET boleto_fin = v_RangoFin;
						--for   FMV: 24-AGO-10
							LET boleto_ini = v_RangoIni;  
							LET boleto_fin = v_RangoFin;
						INSERT INTO {+INDEX (si_boleto idx_si_boleto_cte)}
						bdinteg:"informix".si_boleto VALUES(v_cvesorteo,boleto_ini, boleto_fin, CURRENT,p_numcte,'2',p_sucursal,'B','1',p_tpoper,
						p_foliosuc,p_importe,'','','','','',p_fecha,'0200000',ciclo, '');
						  --  LET ciclo = ciclo + 1; FMV:31-AGO-10
						--END for; FMV: 24-AGO-10

						--dsb-10/10/2012
						--Se manda a llamar sp_premios_instantaneos en caso de canal = 4
						IF p_canal = 4 THEN
							--MARCAR LOS BOLETOS EN CASO DE QUE HAYA
							EXECUTE PROCEDURE bdinteg:"informix".sp_premios_instantaneos(p_canal, p_tpoper, p_producto,p_numcte,p_sucursal, p_foliosuc, p_importe, cFecha,boleto_ini,boleto_fin)
							INTO P_COD_RET, cFolio, cFolio_cupon, cTicket;
							LET P_COD_RET = '00000';
						END IF
					ELSE
						LET v_RangoIni = 0;
						LET v_RangoFin = 0;
						LET ciclo = 1;
						LET P_COD_RET = '00000';
					END IF;
				END IF;
			END IF;
		ELSE
			LET v_RangoIni = 0;
			LET v_RangoFin = 0;
			LET P_COD_RET = '117';  -- FMV 24sep10 Se adiciona codigo
			LET P_MENSAJE = 'NO CUMPLE CON PARAMETROS';
		END IF;
	END IF;
	
		RETURN P_COD_RET, P_MENSAJE, v_RangoIni, v_RangoFin;
	
--jom	END FOREACH;

END;
END PROCEDURE
DOCUMENT
'Modifico: Victor Hugo NuÃ±ez',
'FECHA: 10/10/2012',
'Modificacion: Se agrega llamado a sp_premios_instantaneos para marcar los boletos si viene desde corresponsales',
'Objetivo: Sorteo Instantaneo Navidad Millonaria',
'MODIFICO: JOSE ANGEL GAXIOLA GAXIOLA',
'FECHA: 10/07/2013',
'Modificacion: Se agraga condicion para que valide y solo entregue un boleto del sorteo si el importe de la transaccion es mayor o igual a 650.',
'BD: bdinteg',
'Autor: 94565457',
'Fecha: 03/10/2013',
'ModificaciÃ³n: Se adecua sp agregando condicion para que se entreguen rangos de boletos por cada 650 pesos, tambien se agrego validacion para verificar  ', 
'              si el cliente es empleado(Que se encuentre en la tabla:si_empleado_cliente_coppel).',
'              si se cumple dicha condicion no se le asigna boleto para el sorteo. ',
'Sustento:    ',
'Solicita: Israel Flores GonzÃ¡lez',
'Autor: IREB',
'Fecha: 26/07/2019',
'ModificaciÃ³n: Se realiza el ajuste de la consulta de la tabla de empleados',
'BD: BDINTEG';

CREATE PROCEDURE "informix".valor_divisa_pesos(pEmpresa CHAR(3), pFecha   DATE, tipo_div char(2), vClaseDiv CHAR(1),vTipoCons CHAR(1))
RETURNING CHAR(5), DECIMAL(14,6);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret       CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE isam_err      SMALLINT;
   DEFINE error_info    CHAR(40);
   DEFINE vValor1	    DECIMAL(14,6);
   DEFINE vDivisaCorr   INTEGER;
   DEFINE vMaxFecha     DATE;
 
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, vValor1;
   END EXCEPTION;

-- SET DEBUG FILE TO "valor_udi.out";
-- TRACE ON;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "00000";
   LET vValor1	  = 0;
   LET vDivisaCorr= 0;



-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

      -- ******************************************
      --   Valida Parametro de Codigo de Divisa   *
      -- ******************************************
      SELECT count(*) 
        INTO vDivisaCorr
	    FROM bdinteg:si_divisas
       WHERE empresa = pEmpresa
	     AND divisa = tipo_div;

        IF vDivisaCorr=0 THEN
           LET cod_ret = "901";
           RETURN cod_ret, vValor1;
        END IF;

      -- *****************************************
      --      Valida Clase de Tipo de Cmabio     *
      -- *****************************************

      SELECT count(*) 
        INTO vDivisaCorr
	    FROM bdinteg:si_clase_tc
       WHERE clase_tpcambio = vClaseDiv;

        IF vDivisaCorr=0 THEN
           LET cod_ret = "902";
           RETURN cod_ret, vValor1;
        END IF;


      -- **************
      -- Precio Inicio*
      -- **************

      
      SELECT precio_compra INTO vValor1
       	FROM bdinteg:si_tpcambio
        WHERE empresa = pEmpresa
       	 AND divisa = tipo_div
       	 AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	      AND divisa = tipo_div
                                  AND fecha_tpcambio = pFecha
								  AND clase_tpcambio = vClaseDiv)
         AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	  AND divisa = tipo_div
                              AND fecha_tpcambio = pFecha
							  AND clase_tpcambio = vClaseDiv)
         AND clase_tpcambio = vClaseDiv;

	  IF vValor1 IS NULL and vTipoCons<>'1' THEN
		SELECT precio_compra INTO vValor1
		  FROM bdinteg:si_histdiv
		 WHERE empresa = pEmpresa
		   AND divisa = tipo_div
		   AND fecha_tc = pFecha
		   AND hora_tc =(SELECT MAX(hora_tc)
					       FROM bdinteg:si_histdiv
						  WHERE empresa = pEmpresa
							AND divisa = tipo_div
							AND fecha_tc = pFecha
							AND clase_tpcambio = vClaseDiv)                 
		AND clase_tpcambio = vClaseDiv;

		IF vValor1 IS NULL THEN
			LET cod_ret = "900";
			RETURN cod_ret, vValor1;
		END IF;
      END IF;

      IF vValor1 IS NULL and vTipoCons='1' THEN
		SELECT MAX(fecha_tc)
		  INTO vMaxFecha
		  FROM bdinteg:si_histdiv
		 WHERE empresa = pEmpresa
		   AND divisa = tipo_div
		   AND fecha_tc <= pFecha
		   AND clase_tpcambio = vClaseDiv;

	    SELECT precio_compra INTO vValor1
		  FROM bdinteg:si_histdiv
		 WHERE empresa = pEmpresa
		   AND divisa = tipo_div
		   AND fecha_tc = vMaxFecha
		   AND hora_tc=(SELECT MAX(hora_tc)
			   		      FROM bdinteg:si_histdiv
					     WHERE empresa = pEmpresa
					       AND divisa = tipo_div
					       AND fecha_tc = vMaxFecha
					       AND clase_tpcambio = vClaseDiv)                 
		   AND clase_tpcambio = vClaseDiv;

		 IF vValor1 IS NULL THEN
			LET cod_ret = "900";
			RETURN cod_ret, vValor1;
		 END IF;
      END IF;
END
RETURN cod_ret, vValor1;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_cifra_archivo_chq_2( pCodigo CHAR(20) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3	        CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr	        CHAR(150);
    DEFINE vUsuario         CHAR(20);
    DEFINE vLLave           CHAR(200);
    DEFINE vNomarch         CHAR(100);
    DEFINE vRutaOrigen      CHAR(100);
    DEFINE vRutaDestino     CHAR(100);
    DEFINE vNomarchSalida   CHAR(100);
    DEFINE vRutaOriginales  CHAR(100);
    DEFINE vNomarch_salida  CHAR(100);
    
    
    LET cCodRet         = '';
    LET cCodRet2        = 0;
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_chq.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_chq.out";
    TRACE ON;
    
    FOREACH
        SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida), TRIM(ruta_destino), TRIM(ruta_originales)
          INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales    
          FROM bdinteg:si_configura_pgp_chq
         WHERE codigo = pCodigo
         ORDER BY secuencia
        
        IF vUsuario <> user THEN
            LET cCodRet = '200';
            RETURN cCodRet;
        END IF;
        
        SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/'||TRIM(vUsuario)||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin" > '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM 'echo "export HOME=/home/'||TRIM(vUsuario)||'" >> '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' -r '||''''||TRIM(vLLave)||''''||" --armor --compression --output "||TRIM(vRutaDestino)||TRIM(vNomarch_salida)||'" >> '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM '/usr/bin/chmod 777 '||TRIM(vRutaOrigen)||'blinda_archivo.sh';   
        SYSTEM '/usr/bin/sh '||TRIM(vRutaOrigen)||'blinda_archivo.sh';
        SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' '||vRutaOriginales; 
    END FOREACH;
    
    LET cCodRet = '000';
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;