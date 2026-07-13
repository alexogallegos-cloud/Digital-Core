CREATE PROCEDURE "informix".sp_valida_celular_cancelado_web(pTipoOper	 SMALLINT, 
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

	LET cCodRet1		= '00000';
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
	
	--SET DEBUG FILE TO "/informix/sp_valida_celular_cancelado.out";
        --TRACE ON;	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pTipoOper is null OR pTipoOper = 0) OR (pEmpresa is null OR pEmpresa = '') OR 
	   (pNumCte is null OR pNumCte = '') OR (pTipoTel is null OR pTipoTel = 0) OR 
	   (pUserInsert is null OR pUserInsert = '') THEN
        LET cCodRet1 = '01110';
        RETURN cCodRet1;
    END IF;

	LET sSucursal=(select first 1 sucursal from "informix".si_ejecut where ejecutivo=pUserInsert);
	
	IF(pTipoOper = 1) THEN
	
		IF(pTelefono is null OR pTelefono = '') THEN 
			LET cCodRet1 = '01110';
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
'Modifico: Aracely ',
'Fecha: 02/04/2018',
'BD: bdinteg',
'Descripcion: Se crea sp para cancelacion de telefonos asociados a otros clientes,',
' despues de la verificacion por medio del sms',
'Peticion: 377 - RQM 06 604 TelÃ©fono Ãnico';

CREATE PROCEDURE "informix".sp_actualizactecpl_club_web
(
	pEmpresa 			CHAR(03),
	pCteBanCpl			CHAR(20),
	pCteCplProspecto	CHAR(20),
	pCteCplTitular		CHAR(20)
)

	RETURNING
	CHAR(05) AS cCodRet;

	--VARIABLES
	DEFINE vcCodRet		CHAR(05);
	DEFINE iSql_err		INTEGER;

	--INICIALIZACION DE VARIABLES
	LET vcCodRet = '00000';
	LET iSql_err = 0;

	--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_actualizactecpl_club_out.sql';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET vcCodRet = iSql_err;
				RETURN vcCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDAR PARAMETROS VACIOS Y NULOS
		IF NVL(TRIM(pEmpresa), '') = '' OR NVL(TRIM(pCteBanCpl), '') = '' OR NVL(TRIM(pCteCplProspecto), '') = '' OR NVL(TRIM(pCteCplTitular), '') = '' THEN
			LET vcCodRet = '00001';
			RETURN vcCodRet;
		END IF;
		
		--BUSQUEDA DE DATOS
		UPDATE "informix".si_club_proteccion
		SET numcte_coppel = pCteCplTitular
		WHERE empresa = pEmpresa AND numcte = pCteBanCpl AND numcte_coppel = pCteCplProspecto;
		
		UPDATE "informix".si_club_beneficiario
		SET numcte_coppel = pCteCplTitular
		WHERE empresa = pEmpresa AND numcte = pCteBanCpl AND numcte_coppel = pCteCplProspecto;
		
		UPDATE "informix".si_club_servicio
		SET numcte_coppel = pCteCplTitular
		WHERE empresa = pEmpresa AND numcte = pCteBanCpl AND numcte_coppel = pCteCplProspecto;
		
		UPDATE "informix".si_club_bitacora
		SET numcte_coppel = pCteCplTitular
		WHERE empresa = pEmpresa AND numcte = pCteBanCpl AND numcte_coppel = pCteCplProspecto;
		
		RETURN vcCodRet;
	END;
END PROCEDURE
DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - JosÃ© Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'DescripciÃ³n:	Actualiza el cliente prospecto por el cliente titular Coppel en todas las tablas del club de protecciÃ³n',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_valida_folio_sms_coppel_web(pEmpresa CHAR(3), pSucursal CHAR(4), pProducto CHAR(8),pNumCte CHAR(20), pEjecutivo CHAR(8))
RETURNING CHAR(5)        AS codigo_retorno,
		  INTEGER        AS flag_bton_sms,
          INTEGER        AS flag_dll,
          INTEGER        AS cont_rpte;

	DEFINE cCodRet		CHAR(5);
	DEFINE iSqlErr		INTEGER;
	DEFINE iSamErr		INTEGER;
	DEFINE cErrorInfo	VARCHAR(80,1);
	DEFINE iReqVal      INTEGER; 
	DEFINE iFlag        INTEGER;   
	DEFINE cTelefono    CHAR(13);
	DEFINE iFlagSMS    	INTEGER;
	DEFINE iContador	INTEGER;
	DEFINE iParamCont	INTEGER;
	DEFINE iTotTel		INTEGER;
	DEFINE iFlagDll		INTEGER;
	DEFINE iContRepte	INTEGER;
	DEFINE cVerificado  CHAR(1);
    DEFINE ccampocuatro INTEGER;
	DEFINE cGrupo       CHAR(1);
	DEFINE cNumSolic    VARCHAR(20);
	DEFINE dEvaluacion  DECIMAL(5,2);
	DEFINE iScorePropietario INTEGER;
	DEFINE sParamSMS    CHAR(1);
	DEFINE cProducto    CHAR(4);
	DEFINE cValSms      CHAR(1);

	LET cCodRet			= "00000";
	LET iSqlErr			= 0;
	LET iSamErr			= 0;
	LET cErrorInfo		= "";
	LET iReqVal         = 0;
	LET iFlag           = 0;
	LET cTelefono       = '';
	LET iFlagSMS       	= 0;
	LET iContador       = 0;
	LET iParamCont      = 0;
	LET iTotTel      	= 0;
	LET iFlagDll      	= 0;
	LET iContRepte      = 0;
	LET cVerificado     = '';
    LET ccampocuatro    = "";
	LET cGrupo          = "";
	LET cNumSolic  		= "";
	LET dEvaluacion 	= 0;
	LET iScorePropietario = 0;
	LET sParamSMS 		= "0";
	LET cProducto       ='0000';
	LET cValSms         = "";

	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);
			END IF;
		END EXCEPTION; 	

		--SET DEBUG FILE TO "/tmp/sp_valida_folio_sms.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		--VALIDANDO EL PARAMETRO POR CONTINGENCIA -- ANJ
		  --SELECT valor INTO sParamSMS FROM bdinteg:si_param WHERE cod_param='469';
		  --IF sParamSMS = "1" THEN
			-- RETURN NVL(cCodRet,''),0,0,0;
		  --END IF;	
		--VALIDANDO EL PARAMETRO POR CONTINGENCIA -- ANJ		
		
		--RQI 23 496 
		SELECT num_producto, valida_sms
		INTO cProducto, cValSms
		FROM bdicred:sd_definicion 
		WHERE num_producto = pProducto;
			
		IF cProducto = '' or cProducto is null THEN			
			SELECT producto, valida_sms
			INTO cProducto, cValSms
			FROM bdicheq:sc_producto
			WHERE producto = pProducto;
		END IF;
			
		IF cValSms = 0 THEN
			RETURN NVL(cCodRet,''),0,0,0;
		END IF;		
		
		--Fin RQI 23 496		

		IF TRIM(NVL(pEmpresa,"")) = "" OR TRIM(NVL(pSucursal,"")) = "" OR TRIM(NVL(pProducto,"")) = ""  OR  TRIM(NVL(pNumCte,"")) = "" OR TRIM(NVL(pEjecutivo,"")) = "" THEN
			LET cCodRet  = "00001";
			RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);
		END IF;
				
		IF pProducto='6500' THEN
            SELECT nvl(b.campo_4,'0')
                INTO  ccampocuatro
			FROM  bdisolic: ss_solicitudes a inner join 
				  bdisolic: ss_nuevo_parametrico b 
				  on a.num_solicitud=b.num_solicitud
			WHERE a.empresa=pEmpresa
				and a.numcte=pNumCte
				and a.sucursal=pSucursal
				and a.num_producto = '6500'
				and a.status_solicitud='AP';
            IF (ccampocuatro = "1") THEN
        			LET iFlagDll=0;
            	RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);	 
             END IF;
		END IF;		

		SELECT LIMIT 1 1 
		INTO iReqVal
		FROM "informix".si_prod_sucursal_sms
		WHERE empresa = pEmpresa
		AND num_producto = pProducto
		AND sucursal = pSucursal;
		 
		IF NVL(iReqVal,0) = 0 THEN	

			SELECT count(telefono)
			INTO iTotTel
			FROM "informix".si_telefonos
			WHERE numcte = pNumCte
			AND status_tel = 'A'
			AND tipo_tel IN (1,2);
				
			IF NVL(iTotTel,0) = 1 THEN
				SELECT NVL(telefono ,'')
				INTO cTelefono
				FROM "informix".si_telefonos
				WHERE numcte = pNumCte AND tipo_tel = 1 
				AND status_tel = 'A' AND NVL(verificado,'F') = 'F';

				IF NVL(cTelefono,'') <> '' THEN
					LET iFlagDll = 1;

					SELECT NVL(cont_rpte,0) INTO iContRepte
					FROM "informix".si_bit_intentos_ivr
					WHERE numcte = pNumCte
					AND numtel = TRIM(cTelefono)
					AND empresa = pEmpresa;
				END IF;
			END IF;
			
			IF NVL(iFlagDll,0) = 0 THEN
			
			
			-- RQI 27 008 20/01/2016 Se agrega validaciÃ³n para relacionar la tabla si_telefonos donde el telefono haya sido verificado JMA
				SELECT LIMIT 1 a.telefono
				  INTO cTelefono
				FROM "informix".si_telefonos_actual a
				  INNER JOIN  "informix".si_telefonos b on (b.numcte     = a.numcte 
														   AND b.tipo_tel   = a.tipo_tel
														   AND b.status_tel = a.status_tel
														   AND b.telefono = a.telefono 
														   AND b.verificado = 'V')
				WHERE a.numcte     = pNumCte
				   AND a.tipo_tel   = 1
				   AND a.status_tel = 'A';
				   
				IF NVL(cTelefono,'') = '' THEN
					LET iFlag = 0;
				ELSE		
					LET iFlag = 1;	   
				END IF;
			
				IF iFlag = 0 THEN
					SELECT LIMIT 1 a.telefono, b.verificado 
					  INTO cTelefono,cVerificado 
					FROM "informix".si_telefonos_actual a
					  LEFT JOIN  "informix".si_telefonos b on (b.numcte     = a.numcte 
														   AND b.tipo_tel   = a.tipo_tel
														   AND b.status_tel = a.status_tel
														   AND b.telefono = a.telefono 
														   )
					WHERE a.numcte     = pNumCte
					   AND a.tipo_tel   = 2
					   AND a.status_tel = 'A';
					   
					IF NVL(cTelefono,'') = '' or  cVerificado = 'V' THEN
						LET iFlag = 1;
					END IF;
				END IF;	   
				IF iFlag = 0 THEN
					FOREACH 
						SELECT LIMIT 1 1
						   INTO iFlag
						   FROM "informix".si_bitsmstels b
						  WHERE b.numcte     = pNumCte
						   AND b.telefono   = cTelefono
						   AND b.bandera    = 't'
					  ORDER BY b.fecha DESC
					END FOREACH
				END IF;
				
				IF NVL(iReqVal,0) = 0 AND NVL(iFlag,0) = 0 THEN
					LET iFlagDll = 2;
				END IF;
			END IF;

			IF NVL(iFlagDll,0) = 2 THEN
				IF NVL(cTelefono,'') <> '' THEN
					
					SELECT NVL(valor,0)::integer INTO iParamCont
					FROM "informix".si_param
					WHERE cod_param = 404;
						
					SELECT NVL(cont_sms,0) INTO iContador
					FROM "informix".si_bit_intentos_ivr
					WHERE empresa = pEmpresa
					AND numcte = pNumCte
					AND numtel = TRIM(cTelefono);
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET iContador = 0; --No se encontraron registros
					END IF;
					
					IF NVL(iContador,0) < NVL(iParamCont,0) THEN
						LET iFlagSMS = 1;
					END IF;
					
				ELSE
					LET iFlagSMS = 1;
				END IF;
			END IF;
		END IF;
		
		IF iFlagDll <> 0 THEN 
			IF pProducto = '6001' THEN
				SELECT b.grupo, a.num_solicitud
				  INTO cGrupo, cNumSolic
				FROM bdisolic:"informix".ss_solicitudes a, bdisolic:"informix".ss_resum_scor_fin b
				WHERE a.empresa = b.empresa
					  AND a.num_solicitud = b.num_solicitud
					  and a.numcte = pNumCte
					  --and a.sucursal = pSucursal
					  and a.num_producto = '6001'
					  and a.status_solicitud = 'AT';
					  
				IF NVL(cGrupo,'') IN ('1','2','A') THEN
				  
					SELECT valor 
					  INTO iScorePropietario 
					FROM bdisolic:"informix".ss_param 
					WHERE empresa = pEmpresa 
					   AND secuencia = 385;
					
					SELECT evaluacion
						 INTO dEvaluacion
					FROM bdisolic:"informix".ss_resumen_scoring 
					WHERE empresa = pEmpresa
						  and num_solicitud = cNumSolic
						  and seccion = 2;						  
						  
					IF NVL(dEvaluacion,0) >= iScorePropietario THEN
					    UPDATE bdisolic:"informix".ss_revision_determinacion
						 SET excluye_validacion = 1
					    WHERE empresa = pEmpresa
						 AND num_solicitud = cNumSolic;
							 
						LET iFlagDll=0;
						RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);	 													  
					END IF;
				END IF;		
			END IF;
		END IF;	
		
		RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para revisar si el folio sms ya fue validado',
'FECHA: 12/NOV/2015',
'BD: bdinteg',
'AUTOR: PAUL IVAN QUINTERO VARELA',
'MODIFICACION: Se agrega bandera para saber si el reenvio del sms ya alcanzo el limite permitido',
'FECHA: 29/DIC/2015',
'AUTOR: ERNESTO AGUILERA';

CREATE PROCEDURE "informix".sp_consultabenef_inver_web(pEmpresa CHAR(3), pCuenta CHAR(20),pOpcion CHAR(1))
	RETURNING CHAR(5) AS cCodRet, CHAR(20) AS cNumcte, CHAR(104) AS cNombreCompleto, CHAR(1) AS cCodParentesco,CHAR(20) AS cDesParentesco, SMALLINT AS sPorcentaje;

	--DEFINICION DE VARIABLES
	DEFINE cCodRet  CHAR(5);
	DEFINE cNumcte CHAR(20);
	DEFINE cNombreCompleto CHAR(104);
	DEFINE cCodParentesco CHAR(1);
	DEFINE cDesParentesco CHAR(20);
	DEFINE sPorcentaje 	SMALLINT;
	DEFINE iSqlErr INTEGER;

	--INICIALIZACION DE VARIABLES 
	LET cCodret	= "00000";
	LET cNumCte ="";
	LET cNombreCompleto ="";
	LET cCodParentesco="";
	LET cDesParentesco="";
	LET sPorcentaje=0;
	LET iSqlErr = 0;

	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultabenef_inver.out';
    --TRACE ON;
	
BEGIN
    
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodret = iSqlErr;
			RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
		END IF;
	END EXCEPTION;
	
	LET pCuenta = TRIM(pCuenta);
	LET pEmpresa = TRIM(pEmpresa);
	LET cNumcte = TRIM(cNumcte);
	LET cCodParentesco = TRIM(cCodParentesco);

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;
	
	IF NVL(pEmpresa,'')='' OR NVL(pCuenta,'') ='' OR TRIM(NVL(pOpcion,''))='' THEN
		LET cCodret = '00001'; --ParÃ¡metros de entrada vacÃ­os
		RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
	ELSE
	
		IF TRIM(NVL(pOpcion,''))='1' THEN
			FOREACH
				SELECT parentesco, porcentaje,numcte
				INTO   cCodParentesco,sPorcentaje,cNumcte
				FROM bdicheq:"informix".sc_beneficiario
				WHERE cuenta=(NVL(pCuenta,''))
				AND empresa=(NVL(pEmpresa,''))
				
				SELECT TRIM(nombre1)||' ' || TRIM(NVL(nombre2,'')) ||' ' || TRIM(apell_paterno) ||' ' || TRIM(NVL(apell_materno,''))
				INTO cNombreCompleto
				FROM bdinteg:"informix".si_cliente
				WHERE numcte=(NVL(cNumcte,'')) 
				AND empresa=(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '00002'; --No se encontraron registros
					LET cNumCte ="";
					LET cNombreCompleto ="";
					LET cCodParentesco="";
					LET cDesParentesco="";
					LET sPorcentaje=0;
				ELSE
					SELECT descripcion
					INTO cDesParentesco
					FROM bdinteg:"informix".si_parentesco
					WHERE parentesco= (NVL(cCodParentesco,''))
					AND empresa=(NVL(pEmpresa,''));
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '00002'; --No se encontraron registros
						LET cNumCte ="";
						LET cNombreCompleto ="";
						LET cCodParentesco="";
						LET cDesParentesco="";
						LET sPorcentaje=0;
					END IF
				END IF
				RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje WITH RESUME;
			END FOREACH;
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '00002'; --No se encontraron registros
					LET cNumCte ="";
					LET cNombreCompleto ="";
					LET cCodParentesco="";
					LET cDesParentesco="";
					LET sPorcentaje=0;
					RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
			END IF
		ELIF TRIM(NVL(pOpcion,''))='2' THEN
			FOREACH
				SELECT parentesco, porcentaje,numcte
				INTO   cCodParentesco,sPorcentaje,cNumcte
				FROM bdinvers:"informix".sv_benefic
				WHERE cuenta=(NVL(pCuenta,''))
				AND empresa=(NVL(pEmpresa,''))
		
				SELECT TRIM(nombre1)||' ' || TRIM(NVL(nombre2,'')) ||' ' || TRIM(apell_paterno) ||' ' || TRIM(NVL(apell_materno,''))
				INTO cNombreCompleto
				FROM bdinteg:"informix".si_cliente
				WHERE numcte=(NVL(cNumcte,'')) 
				AND empresa=(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret = '00002'; --No se encontraron registros
					LET cNumCte ="";
					LET cNombreCompleto ="";
					LET cCodParentesco="";
					LET cDesParentesco="";
					LET sPorcentaje=0;
				ELSE
					SELECT descripcion
					INTO cDesParentesco
					FROM bdinteg:"informix".si_parentesco
					WHERE parentesco= (NVL(cCodParentesco,''))
					AND empresa=(NVL(pEmpresa,''));
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodret = '00002'; --No se encontraron registros
						LET cNumCte ="";
						LET cNombreCompleto ="";
						LET cCodParentesco="";
						LET cDesParentesco="";
						LET sPorcentaje=0;
					END IF
				END IF
				RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje WITH RESUME;
			END FOREACH;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret = '00002'; --No se encontraron registros
				LET cNumCte ="";
				LET cNombreCompleto ="";
				LET cCodParentesco="";
				LET cDesParentesco="";
				LET sPorcentaje=0;
				RETURN  cCodRet,cNumcte,cNombreCompleto,cCodParentesco,cDesParentesco,sPorcentaje;
			END IF
		END IF
	END IF
END
END PROCEDURE
DOCUMENT
"DescripciÃ³n: Consulta datos de los beneficiarios de una cuenta de InversiÃ³n Creciente o PagarÃ©",
"Autor : Leslie RendÃ³n",
"FECHA : 27/10/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_datoscte_ivr_web(pEmpresa CHAR(3),pNumCte CHAR(20))
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(110) AS NomCte,
				DATE AS	FechaNacimiento,
				CHAR(13) AS Telefono;


	DEFINE sCodRet   	CHAR(5);
	DEFINE iSqlErr  	INTEGER;
	DEFINE sNom1   		CHAR(26);
	DEFINE sNom2   		CHAR(26);
	DEFINE sApellPat   	CHAR(26);
	DEFINE sApellMat   	CHAR(26);
	DEFINE sNomCte   	CHAR(110);
	DEFINE sFechNac   	DATE;
	DEFINE sNumTel   	CHAR(13);

	LET sCodRet    	= '00000';
	LET iSqlErr  	= 0;
	LET sNom1    	= '';
	LET sNom2    	= '';
	LET sApellPat  	= '';
	LET sApellMat   = '';
	LET sNomCte    	= '';
	LET sFechNac   	= '';
	LET sNumTel    	= '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET sCodRet = iSqlErr;
				RETURN sCodRet, TRIM(sNomCte), sFechNac, sNumTel;
			END IF;
		END EXCEPTION;	
		
		--SET DEBUG FILE TO '/tmp/sp_datoscte_ivr.sql';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALIDA ERRORES DE LOS PARAMETROS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' THEN
			LET sCodRet='00001';
		ELSE
			SELECT NVL(cte.nombre1,''),NVL(cte.nombre2,''),NVL(cte.apell_paterno,''),NVL(cte.apell_materno,''), NVL(pf.fecha_nac,''), NVL(tel.telefono,'')
			INTO sNom1, sNom2, sApellPat, sApellMat, sFechNac, sNumTel
			FROM "informix".si_cliente cte, "informix".si_ctepf pf, "informix".si_telefonos tel
			WHERE cte.empresa = pEmpresa
			AND cte.empresa = tel.empresa
			AND cte.empresa = pf.empresa
			AND cte.numcte = TRIM(pNumCte)
			AND cte.numcte = pf.numcte
			AND cte.numcte = tel.numcte
			AND tel.status_tel = 'A'
			AND tel.tipo_tel = 1;
			
			IF dbinfo("sqlca.sqlerrd2") <> 0 THEN
				LET sNomCte = TRIM(NVL(sNom1,''))||' '||TRIM(NVL(sNom2,''))||' '||TRIM(NVL(sApellPat,''))||' '||TRIM(NVL(sApellMat,''));
			END IF;			
		END IF;
		RETURN sCodRet, TRIM(NVL(sNomCte,0)), NVL(sFechNac,''), NVL(sNumTel,'');
	END;
END PROCEDURE
DOCUMENT
'AUTOR:	ERNESTO AGUILERA',
'FECHA:	29/DIC/2015',
'DESCRIPCION: Obtener los datos del cliente',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_guardacteprospecto_club_web
(
	pEmpresa 			CHAR(03),
	pCteBanCpl			CHAR(20),
	pCteCplTitular		CHAR(20),
	pCteCplProspecto	CHAR(20)
)

	RETURNING
	CHAR(05) AS cCodRet

	--VARIABLES
	DEFINE vcCodRet		CHAR(05);
	DEFINE vcCteBanCpl	CHAR(20);
	DEFINE iSql_err		INTEGER;

	--INICIALIZACIÃ?N
	LET vcCodRet	= '00000';
	LET vcCteBanCpl	= '';
	LET iSql_err 	= 0;

	--SET DEBUG FILE TO '/respaldosbd/Ernesto/out/sp_guardacteprospecto_club_out.sql';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET vcCodRet = iSql_err;
				RETURN vcCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDAR PARAMETROS VACIOS Y NULOS
		IF NVL(TRIM(pEmpresa), '') = '' OR NVL(TRIM(pCteBanCpl), '') = '' OR NVL(TRIM(pCteCplTitular), '') = '' THEN
			LET vcCodRet = '00001';
			RETURN vcCodRet;
		END IF;
		
		--BUSQUEDA DE DATOS
		SELECT ctebancpl
		INTO vcCteBanCpl
		FROM "informix".si_club_hiscteprospecto
		WHERE empresa = pEmpresa AND ctebancpl = pCteBanCpl;
		
		--SI NO REGRESA DATOS
		--IF DBINFO("sqlca.sqlerrd2") = 1 THEN
		IF TRIM(vcCteBanCpl) = '' OR vcCteBanCpl IS NULL THEN
			INSERT INTO "informix".si_club_hiscteprospecto(empresa, ctebancpl, ctecpltitular, ctecplprospecto)
			VALUES (pEmpresa, pCteBanCpl, pCteCplTitular, pCteCplProspecto);
			RETURN vcCodRet;
		ELSE
			LET vcCodRet = '00002';
			RETURN vcCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'Folio:			1630',
'Autor: 		95579737 - JosÃ© Ernesto Raygoza Villa',
'Fecha: 		08/08/2014',
'Sustento:		Anexo al RQM 10 297 Venta de Club de Proteccion Coppel en BanCoppel',
'Solicita		Rodolfo Gomez',
'Descripcion:	Guarda la relacion del cliente bancoppel con el clinente Coppel titular y prospecto',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_guardarhistcomphuellas_web(p_sNoEmpleado CHAR(8), p_sSucursal CHAR(4), p_sNoCteBancoppel CHAR(20), p_sTipoProducto CHAR(4))
RETURNING	 VARCHAR(5) --Codigo de Retorno

	DEFINE iSqlErr			INTEGER;

	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Erick Zamora
	-- FECHA: 13-03-2009
	-- Guarda en la tabla bdinteg:si_histcomhuellas los datos los empleados que hayan 
	--	validado un cliente con su propia huella
	-- SET DEBUG FILE TO "/tmp/sp_guardarhistcomphuellas.out;
	-- TRACE ON;
	------------------------------------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO bdinteg:si_histcomphuellas VALUES(p_sNoEmpleado, p_sSucursal, CURRENT, LPAD(TRIM(p_sNoCteBancoppel),9,'0'), p_sTipoProducto);
		RETURN '00000';
	END
END PROCEDURE;