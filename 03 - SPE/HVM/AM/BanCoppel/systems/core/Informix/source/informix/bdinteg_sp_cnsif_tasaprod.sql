CREATE PROCEDURE "informix".sp_cnsif_tasaprod(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cPRODUCTO CHAR(4))
							
				returning CHAR(5)  AS Cod_Retorno,
						  DECIMAL(14,2) AS Saldo_Minimo,
						  DECIMAL(14,2) AS Saldo_Maximo,
						  DECIMAL(9,6) AS Tasa;
										
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
-- VARIABLES
DEFINE cCveTasa         CHAR(8);
DEFINE cRangoTasa       CHAR(1);
DEFINE decSaldoMinimo  	DECIMAL(14,2);
DEFINE decSaldoMaximo	DECIMAL(14,2);
DEFINE decTasa     		DECIMAL(9,6);
DEFINE cClavep              CHAR(1);




--inicializando variables
LET  iexiste 			 = 0;
LET cCodRet 	         = "00000";
LET iSql_err 			 = 0 ;	

LET decSaldoMinimo 	= 0;
LET decSaldoMaximo	= 0;
LET decTasa         = 0;
LET cClavep         ="";


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_tasaprod.out";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cPRODUCTO  = ''	THEN 
		LET cCodRet = "00054";
		RETURN
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
	END IF;	

	EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
	INTO cCodRet;

	IF cCodRet = '00028' THEN 
		RETURN cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
	END IF;		
	
    LET cClavep=SUBSTR(cPRODUCTO,1,1);
    -- 20062018 AAME RQM 06590 y RQM 06 591 Se contemplan los productos oro y Platino
	IF cClavep IN('6','7','8') THEN
		SELECT NVL(COUNT(num_producto),0) into iexiste FROM bdicred:sd_definicion WHERE num_producto= cPRODUCTO;
		
		IF iexiste  = 0 THEN 
			LET cCodRet = "00057";
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		END IF;

		SELECT cod_tasa_base
		INTO 
		cCveTasa
		FROM bdicred:sd_definicion
		WHERE num_producto = cPRODUCTO;

		SELECT rangofecha
		INTO
		cRangoTasa
		FROM si_tiptasa
		WHERE  tasa = cCveTasa;

		IF cRangoTasa = 'F' THEN
			
        	SELECT valor 
			INTO
			decTasa
			FROM si_fechavalor 
			WHERE tasa = cCveTasa
			AND fecha = (SELECT MAX(fecha) FROM si_fechavalor WHERE tasa = cCveTasa);	
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		ELSE
            SET	ISOLATION TO DIRTY READ;
            FOREACH 		
                SELECT rangomin, rangomax, valor 
				INTO 
				decSaldoMinimo, decSaldoMaximo, decTasa
				FROM si_tasavlor
				WHERE  tasa = cCveTasa
					
				RETURN 
				cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa WITH Resume;
					
			END FOREACH;
				
		END IF;	
    ELIF cClavep='3' THEN    
		SELECT NVL(COUNT(nombre),0) into iexiste FROM bdinvers:sv_instrum Where cod_instrum = cPRODUCTO;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00057";
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		END IF;

       --SELECT mto_min_recom,mto_max_recom INTO decSaldoMinimo, decSaldoMaximo FROM bdinvers:sv_instrum Where cod_instrum = cPRODUCTO;

        FOREACH
        	SELECT valor 
			INTO
			decTasa
			FROM si_fechavalor 
			where tasa LIKE 'P%' ORDER BY valor 

            RETURN 
            cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa WITH Resume;
        END FOREACH;

    ELSE
		SELECT NVL(COUNT(producto),0) into iexiste FROM bdicheq:sc_producto WHERE producto  = cPRODUCTO;
		
		IF iexiste  = 0 THEN 
			LET cCodRet = "00057";
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		END IF;

		SELECT tasa
		INTO 
		cCveTasa
		FROM bdicheq:sc_producto
		WHERE producto = cPRODUCTO;
			
		IF cCveTasa = 'INVCREC' THEN
		--RQM 06 590 -591 Se modifica para que entre indexado 10072018
    		SELECT valor_tasa
			INTO
			decTasa
			FROM si_tasa_mes
			WHERE mes = 13 
            AND tasa = cCveTasa
			AND tipo_tasa = 'P'
			AND fecha = (SELECT MAX(fecha) FROM si_tasa_mes WHERE tasa = cCveTasa AND tipo_tasa = 'P');
				
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
					
		END IF;

		SELECT rangofecha
		INTO
		cRangoTasa
		FROM si_tiptasa
		WHERE  tasa = cCveTasa;

		IF cRangoTasa = 'F' THEN
			
        	SELECT valor 
			INTO
			decTasa
			FROM si_fechavalor 
			WHERE tasa = cCveTasa;
				
			RETURN 
			cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa;
		ELSE
            SET	ISOLATION TO DIRTY READ;
            FOREACH 		
                SELECT rangomin, rangomax, valor 
				INTO 
				decSaldoMinimo, decSaldoMaximo, decTasa
				FROM si_tasavlor
				WHERE  tasa = cCveTasa
					
				RETURN 
				cCodRet, decSaldoMinimo, decSaldoMaximo, decTasa WITH Resume;
					
			END FOREACH;
				
		END IF;	

    END IF;
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de las tasas asociadas a los Productos BanCoppel. ",
"El SP obtiene la información de la Base de Datos central de Informix, enviando como parámetro el  Producto.",
"FECHA : 02-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_ws_consultacoppel (pTipo CHAR(1), -- 1 Consulta todos, 2 Grabar Datos
												  pNumcte CHAR(20),
												  pNombre CHAR(104),
												  pFechaNac CHAR(10),
												  pSituacion CHAR(1),
												  pCausa SMALLINT,
												  pTicket CHAR(20),
												  pActivo CHAR(1))

RETURNING 	CHAR(5)  AS cCodRet, CHAR(20) AS cNumCte, CHAR(1) AS cEmpresa, CHAR(4) AS cSucursal, CHAR(8) AS cEmpleado, CHAR(20) AS cTicket;


--Definicion de Variables
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cNumCte 		CHAR(20);
DEFINE cEmpresa		CHAR(1);
DEFINE cSucursal	CHAR(4);
DEFINE cTicket		CHAR(20);
DEFINE cEmpleado	CHAR(8);


--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cNumCte 		= '';
LET cEmpresa 		= '';
LET cSucursal 		= '0002';
LET cTicket 		= '';
LET cEmpleado		= '';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, '','','','','';
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/cristo/sp_ws_empctes_coppel.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;


	IF 	pTipo = '1' THEN-- Obtener los clientes o empleados a consultar en coppel
		FOREACH WITH HOLD

			SELECT {+AVOID_FULL("informix".si_huella_linea_resultado)} DISTINCT(cliente),empresa, ticket
			INTO cNumCte, cEmpresa, cTicket
			FROM "informix".si_huella_linea_resultado
			WHERE fecha = today
			AND (empresa = '0' OR empresa = '1' OR empresa = '2' OR empresa = '3' OR empresa = '4')
			AND num_mensaje = '602'
			AND nombre = ''
			ORDER BY 1 ASC

			SELECT empleado INTO cEmpleado 
			FROM "informix".si_huella_linea WHERE ticket=cTicket AND status_consulta='3';

			RETURN cCodret , TRIM(cNumCte), TRIM(cEmpresa), TRIM(cSucursal),TRIM(cEmpleado),TRIM(cTicket) WITH RESUME;

		END FOREACH;

	ELIF pTipo = '2' THEN  -- Actualizar registro del cliente 
		IF ((pNumcte IS NULL OR pNumcte = '')) THEN
			LET cCodRet = '00001'; --Valor de parametros nulos o no valido
		ELSE
			
			LET pNombre = REPLACE(pNombre,'  ',' ');
			
			UPDATE "informix".si_huella_linea_resultado
			SET nombre = TRIM(pNombre), fecha_nac = TRIM(pFechaNac), situacion = TRIM(pSituacion), causa = pCausa, activo = pActivo
			WHERE ticket=pTicket AND cliente=pNumcte AND num_mensaje = '602' AND fecha=today;

		END IF;

		RETURN cCodRet, '','','','','';
	ELSE
		LET cCodRet = '00002';	--Valor de parametro pTipo no valido
		RETURN cCodRet, '','','','','';
	END IF;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Obtiene los clientes coppel para ser evaluados por webservice wsBanCoppServ',
'permite registrar datos como son nombre, fecha de nacimiento y situacion especial del cliente',
'dentro de la tabla si_huella_linea_resultado',
'AUTOR : Cristo Lugo',
'FECHA : 30-04-2015',
'VERSION: 20150330',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_valida_folio_sms_coppel_mib2(pEmpresa CHAR(3), pSucursal CHAR(4), pProducto CHAR(8),pNumCte CHAR(20), pEjecutivo CHAR(8))
RETURNING CHAR(6)        AS codigo_retorno,
		  INTEGER        AS flag_bton_sms,
          INTEGER        AS flag_dll,
          INTEGER        AS cont_rpte;

	DEFINE cCodRet		CHAR(6);
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
	DEFINE cVerificado    CHAR(1);
    DEFINE ccampocuatro INTEGER;
	DEFINE cGrupo  CHAR(1);
	DEFINE cNumSolic VARCHAR(20);
	DEFINE dEvaluacion DECIMAL(5,2);
	DEFINE iScorePropietario INTEGER;

	LET cCodRet			= "000000";
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
	LET cVerificado       = '';
    LET ccampocuatro    = "";
	LET cGrupo          = "";
	LET cNumSolic  = "";
	LET dEvaluacion = 0;
	LET iScorePropietario = 0;

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

		IF TRIM(NVL(pEmpresa,"")) = "" OR TRIM(NVL(pSucursal,"")) = "" OR TRIM(NVL(pProducto,"")) = ""  OR  TRIM(NVL(pNumCte,"")) = "" OR TRIM(NVL(pEjecutivo,"")) = "" THEN
			LET cCodRet  = "000001";
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
		End if;



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
			
			
			-- RQI 27 008 20/01/2016 Se agrega validación para relacionar la tabla si_telefonos donde el telefono haya sido verificado JMA
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

CREATE PROCEDURE "informix".sp_generareportepp(pNumSolicitud CHAR(20), pSucursal CHAR(5), cPlazo CHAR(2), iMontoTotal DECIMAL (16,2),cCapacidad_pres DECIMAL(18,2), pProducto CHAR(4),pTipo CHAR(1))
RETURNING	CHAR(5)   		AS Codret,
			CHAR(9) 		AS NumCte,
			CHAR(100) 		AS NOMBRE,
			CHAR(20)  		AS NumCredito,
			CHAR(2)   		AS diasDePago,
			CHAR(12)  		AS cuenta,
			CHAR(10)  		AS Iva,
			DECIMAL (16,2)	AS MontoTotal,
			DECIMAL (16,2)  AS interesOrdinario,
			CHAR(2)   		AS Plazo,
			DECIMAL (16,2) 	AS TasaIntMoratorio,
			CHAR(1)	  		AS PeriodoPlazo,
			CHAR(12)  		AS Fecha,
			CHAR(150) 		AS Direccion,
			CHAR(40)  		AS Ciudad,
			DECIMAL(16,2) 	AS Capacidad_Pres,
			DECIMAL (16,2)	AS cApli_factor,
			DECIMAL (16,2)  AS MontoTotalApagar;

--DEFINICION DE VARIABLES
    DEFINE cCodret 					CHAR(5);
	DEFINE sql_err  				INTEGER;
	DEFINE cNombre   				CHAR(100);
	DEFINE cNumCredito 				CHAR(20);
	DEFINE cDiasPago    			CHAR(12);
	DEFINE cCuenta					CHAR(12);
	DEFINE cIva						DECIMAL(14,2);
	--DEFINE iMontoTotal  			DECIMAL (16,2);
	DEFINE iMontoTotalCredito  		DECIMAL (16,2);
	DEFINE cInteresOrdinario 		DECIMAL (16,2);
	--DEFINE cPlazo 				CHAR(2);
	DEFINE cInteresMoratorio 		DECIMAL (16,2);
	DEFINE cPeriodoPlazo			CHAR(1);
   	DEFINE cFecha	 				DATE;
    DEFINE cDireccion       		CHAR(150);
	DEFINE cCalle           		CHAR(50);
	DEFINE cNumExtCalle     		CHAR(5);
	DEFINE cNumIntCalle     		CHAR(5);
	DEFINE cNombreZona      		CHAR(30);
	DEFINE cMunicipio       		CHAR(30);
	DEFINE cEstado					CHAR(30);
	DEFINE cCodPostal				CHAR(11);
	DEFINE cCiudad					CHAR(40);
	--DEFINE cCapacidad_pres		DECIMAL(18,2);
	DEFINE cNumcte					CHAR(9);
	DEFINE cApli_factor     		DECIMAL (16,2);
	DEFINE cMontoTotales    		DECIMAL(16,2);
	DEFINE Periodo  				INTEGER;
	DEFINE FechaCouta  				DATE;
	DEFINE Fechaaper				DATE;
	DEFINE SaldoInicial  			MONEY(14,2);
	DEFINE Mensualidad  			MONEY(14,2);
	DEFINE Intereses  				MONEY(14,2);
	DEFINE IvaInteres  				MONEY(14,2);
	DEFINE Capital  				MONEY(14,2);
	DEFINE SaldoFinal  				MONEY(14,2);
	DEFINE DiasPeriodo  			SMALLINT;
	DEFINE cSucursal 				CHAR (5);
	DEFINE cDivisa					CHAR (2);
	DEFINE i 						INTEGER;
	DEFINE v_cat 					DECIMAL(14,2);
	
	DEFINE cNumSolCredito 			CHAR(20);
--ASIGNACION DE VARIABLES
    LET cCodret 					= "00000";
	LET sql_err	   					= 0;
	LET cNombre						= "";
	LET cNumCredito					= "";
	LET cDiasPago					= "";
	LET cCuenta						= "";
	LET cIva						= 0;
	LET cInteresOrdinario			= 0.0;
	LET cInteresMoratorio			= 0.0;
	LET cPeriodoPlazo				= "";
    LET cFecha 	    				= "";
	LET cDireccion          		= "";
	LET cCalle              		= "";
	LET cNumExtCalle        		= "";
	LET cNumIntCalle        		= "";
	LET cNombreZona         		= "";
	LET cMunicipio          		= "";
	LET cEstado						= "";
	LET cCodPostal					= "";
	LET cCiudad						= "";
	LET cNumcte						= '';
	LET cApli_factor   				= "";
	LET iMontoTotalCredito 			= 0.00;
	LET cSucursal 					= "";
	LET cDivisa 					= "";
	LET Periodo						= 0;
	LET FechaCouta					= "";
	LET Fechaaper					= "";
	LET SaldoInicial				= 0;
	LET Mensualidad					= 0;
	LET Intereses					= 0;
	LET IvaInteres					= 0;
	LET Capital						= 0;
	LET SaldoFinal					= 0;
	LET DiasPeriodo					= 0;
	LET cMontoTotales   			= 0;
	LET i 							= 0;
	
	LET cNumSolCredito				= "";
	
	BEGIN
	
			--MANEJO DE EXCEPCIONES (ERRORES)
			ON EXCEPTION SET sql_err
				IF sql_err <> 0 THEN
					let cCodret = sql_err;
					RETURN cCodret, '', '','','','','','','','','','','','','','','','';
				END IF;
			END EXCEPTION;

			--SET DEBUG FILE TO "/tmp/sp_GeneraReportePP.out";
			--TRACE ON;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			--VALIDA EL NUMERO DE PRODUCTO
			IF pProducto = "" THEN
					LET cCodret ='00111'; -- PRODUCTO VACIO
					RETURN cCodret,'','','','','','','','','','','','','','','','','';
			END IF
			
			--VALIDA PARAMETROS DE ENTRADA
			IF  (pNumSolicitud IS NULL OR pNumSolicitud = "") OR (pTipo IS NULL OR pTipo = "") OR (pTipo <> 1 AND pTipo <> 2 AND pTipo <> 3) THEN
					LET cCodret ='00110'; -- FALTAN PARAMETROS
					RETURN cCodret,'','','','','','','','','','','','','','','','','';
			END IF;

			SELECT num_solicitud
			INTO cNumSolCredito
			FROM bdisolic:"informix".ss_solicitudes where num_solicitud = pNumSolicitud  AND num_producto = pProducto;
			
			LET cNumSolCredito = NVL(cNumSolCredito,'');
			
			IF( cNumSolCredito IS NULL OR cNumSolCredito = "" ) THEN
					LET cCodret	='00120'; -- EL NÃMERO DE SOLICITUD PARA EL pProducto NO EXISTE
					RETURN cCodret,'','','','','','','','','','','','','','','','','';
			END IF
			
			IF (pTipo = 1 OR pTipo = 2) AND (pSucursal IS NULL OR pSucursal = "")  THEN
					LET cCodret	='00130';  --FALTAN SUCURSAL
					RETURN cCodret,'','','','','','','','','','','','','','','','','';
			END IF;
			--SE OBTIENE LA FECHA  DEL DIA DEL REPORTE
			SELECT fecha_hoy 
			INTO cFecha 
			FROM bdinteg:si_fechas;
			LET cDiasPago = substr(cFecha,4,2);
			-- SE OBTIENE EL IVALOR DEL IVA                                         DSB 12/01/2010 SE MODIFICA POR EL CAT 
			--SELECT NVL(valor,'') 
			--INTO cIva 
			--FROM bdicred:sd_param 
			--WHERE cod_param='037';
			
			--SE OBTIENE FECHA DE APERTURA (PrÃ©stamo Flexible)
			IF pProducto = '6800' THEN
				SELECT LIMIT 1 fecha_apertura
				INTO cFecha
				FROM bdicred:sd_maecredcrd 
				WHERE empresa = '001' 
					AND num_credito = pNumSolicitud;
			END IF

            SELECT cat_caratula INTO cIva FROM bdicred:sd_definicion WHERE num_producto = pProducto;

            SELECT tasa_interes, (tasa_moratorios - tasa_interes) 
            INTO cInteresOrdinario, cInteresMoratorio  
            FROM bdicred:sd_maecredcrd 
            WHERE empresa = '001'
            AND num_credito = pNumSolicitud;

            IF (cInteresOrdinario IS NULL OR cInteresOrdinario = 0) THEN

                --SE OBTIENE EL  VALOR DE LA TASA DE INTERES ORDINARIO
                SELECT a.valor, b.periodo_plazo
                INTO cInteresOrdinario, cPeriodoPlazo 
                FROM bdinteg:si_fechavalor AS a,
                            bdicred:sd_definicion AS b
                WHERE a.tasa = b.cod_tasa_base       
                AND fecha = (SELECT MAX(fecha) 
                FROM bdinteg:si_fechavalor 
                WHERE  tasa=b.cod_tasa_base    -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
                AND b.num_producto = pProducto);

                --SE OBTIENE EL VALOR DE LA TASA DE INTERES MORATORIO
                SELECT a.valor 
                INTO cInteresMoratorio 
                FROM bdinteg:si_fechavalor AS a, bdicred:sd_definicion AS b
                WHERE a.tasa = b.cod_tasa_mora AND fecha = (SELECT MAX(fecha) 
                FROM bdinteg:si_fechavalor
                WHERE  tasa=b.cod_tasa_mora AND b.num_producto = pProducto);  -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
                LET cInteresMoratorio = cInteresMoratorio - cInteresOrdinario;
            ELSE
                SELECT periodo_plazo 
                INTO cPeriodoPlazo 
                FROM bdicred:sd_definicion 
                where empresa = '001'
                AND num_producto = pProducto;
            END IF;

			--SE OBTIENE EL NUMERO DE CLIENTE
			SELECT numcte 
			INTO cNumCte 
			FROM bdisolic:ss_solicitudes 
			WHERE empresa = '001' 
			AND num_solicitud = pNumSolicitud;
			--SE OBTIENE EL DOMICILIO DEL CLIENTE
			SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) ||' '||TRIM( apell_paterno) ||' '|| TRIM(apell_materno) AS Nombre,numcte 
			INTO cNombre,cNumCte
			FROM bdinteg:si_cliente 
			WHERE numcte = cNumCte;	
			--SECCION PARA EL REPORTE TIPO 1 CONTRATO
			IF pTipo = 1 THEN 
					--VALOR DE LA COMISIÃN A COBRAR POR PAGO ANTICIPADO
					SELECT apli_factor 
					INTO cApli_factor 
					FROM bdicred:sd_tpcomis 
					WHERE cod_comis = '6903'; 
					
					--EN ESTE CICLO SE EJECUTA EL PROCEDIMIENTO PROYECTA PRÃSTAMO PARA OBTENER EL VALOR TOTAL A PAGAR
					FOREACH 
						EXECUTE PROCEDURE  sp_proyecta_prestamos(iMontoTotal, '0',cCapacidad_pres,pProducto,pSucursal,'1','0','','')
						INTO cCodRet, Periodo,FechaCouta,SaldoInicial,Mensualidad,Intereses,IvaInteres,Capital,SaldoFinal,DiasPeriodo,Fechaaper
						LET cMontoTotales = cMontoTotales  + Intereses + IvaInteres ;
					END FOREACH;
					LET iMontoTotalCredito= iMontoTotal + cMontoTotales;
					LET cDiasPago=  SubStr(cFecha,4,2);
					RETURN cCodret, cNumCte, cNombre,pNumSolicitud,cDiasPago,cCuenta,cIva,iMontoTotal,cInteresOrdinario,cPlazo,cInteresMoratorio,cPeriodoPlazo,cFecha,cDireccion,cCiudad,cCapacidad_pres,cApli_factor,iMontoTotalCredito   WITH RESUME;
			--SECCION PARA EL PAGARÃ 
			ELIF pTipo = 2 THEN
					--OBTIENE LA CIUDAD
					SELECT NVL(b.nombreciudad,'') 
					INTO cCiudad 
					FROM bdinteg:si_catciudades AS b, bdinteg:si_sucursales AS a
					WHERE a.estado= b.numeroestado AND a.ciudad= b.numerociudad AND a.sucursal= pSucursal;
					--OBTIENE LA DIRECCIÃN DEL CLIENTE
					SELECT TRIM(f.nombrecalle)||' '||TRIM(a.numeroextcalle)||' '||TRIM(a.numerointcalle),TRIM(g.nombrezona),TRIM(g.municipiozona), TRIM(c.estado),a.cod_postal
					INTO cCalle,cNombreZona,cMunicipio,cEstado, cCodPostal 
					FROM bdinteg:si_direcciones AS a,--bdinteg:si_ciudades as b,
					bdisolic:ss_circulo_edos AS c,bdinteg:si_catcalles f, bdinteg:si_catzonas g
					WHERE a.numcte=cNumCte AND a.secuencia=(SELECT MAX(secuencia) 
					FROM bdinteg:si_direcciones 
					WHERE numcte = a.numcte 
					AND tipo_dir = '1')
					AND c.empresa = "001" 
					AND a.estado = c.clave 
					AND a.numerociudad = g.numerociudad 
					AND a.numerocolonia = g.numerocolonia
					AND a.numerocalle = f.numerocalle;

					LET  cDireccion = TRIM(cCalle) || ' '||TRIM(cNombreZona) || ' '||TRIM(cMunicipio) ||', '||TRIM(cEstado) || ' ' || cCodPostal;
					RETURN cCodret, cNumCte, cNombre,pNumSolicitud,cDiasPago,cCuenta,cIva,iMontoTotal,cInteresOrdinario,cPlazo,cInteresMoratorio,cPeriodoPlazo,cFecha,cDireccion,cCiudad,cCapacidad_pres,cApli_factor,iMontoTotalCredito  WITH RESUME;
			--SECCION DE CODIGO PARA EL TIPO 3 (REIMPRESIÃN)
			ELIF pTipo = 3 THEN 
					SELECT num_cta
					INTO cCuenta
					FROM bdicred:sd_ctascarg
					WHERE  empresa = '001'
					AND num_credito = pNumSolicitud;
					
					
					SELECT  cat 
					INTO cIva
					FROM bdicred:"informix".sd_maecredanexocrd 
					WHERE empresa = '001'
					AND num_credito = pNumSolicitud;
					
					IF NVL(cIva,0)=0 THEN
						SELECT cat_caratula INTO cIva
						FROM bdicred:"informix".sd_definicion 
						WHERE num_producto = pProducto;
					END IF
					LET cCapacidad_pres		= 0.00;
					LET iMontoTotal			= "";
					LET cPlazo				= "";
					--SE OBTENIE LA FECHA, LA SUCURSAL Y LA DIVISA, CUANDO ES REIMPRESIÃN
					--OBTIENE EL NUM DE CUENTA CON EL QUE ESTA APERTURADO
					--SE OBTIENE LA FECHA  DEL DIA DE LA APERTURA 
					SELECT fecha_apertura, sucursal,divisa 
					INTO cDiasPago, cSucursal,cDivisa 
					FROM bdicred:sd_maecredcrd 
					WHERE num_credito = pNumSolicitud;
					LET cDiasPago = SUBSTR(cDiasPago,4,2);
					--VALOR DEL IVA A COBRAR
					SELECT apli_factor
					INTO cApli_factor
					FROM bdicred:sd_tpcomis
					WHERE cod_comis = '6903';
					FOREACH
						EXECUTE PROCEDURE  sp_proyecta_prestamos('0', '0','0',pProducto,cSucursal,'2','0',pNumSolicitud,'')
						INTO cCodRet, Periodo,FechaCouta,SaldoInicial,Mensualidad,Intereses,IvaInteres,Capital,SaldoFinal,DiasPeriodo,Fechaaper
						LET cMontoTotales = cMontoTotales  + Intereses + IvaInteres ;
						LET i = i + 1;
						IF i = 1 THEN 
							--SE OBTIENE EL PRIMER RENGLON PARA TOMAR EL MONTO DE LA MENSUALIDAD Y EL SALDO INICIAL 
							LET iMontoTotal = SaldoInicial;
							LET cCapacidad_pres = Mensualidad;
						END IF
						LET cPlazo = i;
					END FOREACH;
					LET iMontoTotalCredito= iMontoTotal + cMontoTotales;
					--CDIVISA RETORNARA EN EL CAMPO CIUDAD, YA QUE PARA LA REIMPRESIÃN DE CARATULA ES NECESARIO LA DIVISA Y NO ASI LA CIUDAD, Y CON EL OBJETIVO DE NO AGREGAR UN PARAMETRO D SALIDA MÃS SE REUTILIZARÃ EL CORRESPONDIENTE A LA CIUDAD.
					RETURN cCodret, cNumCte, cNombre,pNumSolicitud,cDiasPago,cCuenta,cIva,iMontoTotal,cInteresOrdinario,cPlazo,cInteresMoratorio,cPeriodoPlazo,cFecha,cDireccion,cDivisa,cCapacidad_pres,cApli_factor,iMontoTotalCredito   WITH RESUME;
			END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Este procedimiento genera el reporte del contraro de prestamo personal.',
'FECHA      : 21/09/2009',
'VERSION    : 20090921.1634',
'BD         : BDISOLIC',
'Modifico	: Cristian Valentina Aguilar',
'DESCRIPCION: Se agregÃ³ la consulta para el tipo 3 (utilizado para la reimpresiÃ³n de caratula de prÃ©stamo personal,', 
			' Se separÃ³ la consulta a la tabla si_cliente (Donde trae el nombre del cliente) ya que anteriormente se consultaba haciendo un join a esta tabla',
			' Se valido que el nÃºmero de solicitud, ingresado como parametro de entrada exista',
'FECHA		: 2009/10/12',
'VERSION	: 20091012.1039',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se le quito el plazo al sp_proyecta_prestamos para calcularlo (validacion de sp solo acepta dos parametros para calcular el tercero),', 
			' se modifico el sp_proyecta_prestamos para obtener la fecha de reeimpresion se agrega parametro de entrada (num credito y de salida fecha apertura),',
'FECHA		: 2009/10/20',
'VERSION	: 20091020.0825',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se agrega el codigo de producto para consultar el interes ordinario y el periodo plazo,', 
'FECHA		: 2009/10/22',
'VERSION	: 20091022.0444',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se le agregan tres parametros de entrada para calcular los resultados al cliente ,', 
'FECHA		: 2009/10/26',
'VERSION	: 20091026.1114',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se le agregan parametro vacio para la fecha futura al sp_proyecta_prestamos,', 
'FECHA		: 2009/10/27',
'VERSION	: 20091027.0525',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se modifica para que muestre el nombre del cliente,', 
'FECHA		: 2009/11/06',
'VERSION	: 20091106.1229',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Se modifica para la reimpresion obtener los datos aperturados se mandan vacios los parametros mto, plazo y capacidad pres al proyecta,', 
'FECHA		: 2009/11/10',
'VERSION	: 20091110.0118',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: SE PARAMETRIZA EL PRODUCTO,', 
'FECHA		: 2009/12/02',
'VERSION	: 20091202.0225',
'Modifico	: Noel Eleazar Gerardo Garcia',
'DESCRIPCION: SE AGREGA EL CAT DE SD_DEFINICION,', 
'FECHA		: 2010/01/12',
'VERSION	: 1200.0000';

CREATE PROCEDURE "informix".sp_bitacora_ife(pnumcte char(9), pejecutivo char(8), psucursal char(5), pcadena_anverso CHAR(2200), 
                  pcadena_reverso CHAR(2200), pflag_idbox char(1), pflag_ws char(1), pflag_captura char(1), presultado char(50), 
                  pcausa_rechazo char(100),  pCod_Resp_IFE char(10), pResp_IFE char(50), pTime_IFE char(30),  pAccess_IFE char(30),
                  pStamp_IFE char(30), pOCR_IFE char(1), pApPat_IFE char(1), pApMat_IFE char(1), pNombre_IFE char(1), pCalleNum_IFE char(1),
                  pColCp_IFE char(1), pMpoEnt_IFE char(1), pFolioNal_IFE char(1), pAnioReg_IFE char(1), pEmision_IFE char(1), pCveElec_IFE char(1),
                  pCurp_IFE char(1), pEstado char(1), pMpio_IFE char(1), pLocalidad_IFE char(1), pSeccion_IFE char(1), pAnioEmision_IFE char(1),
                  pVigencia_IFE char(1), pEdad_IFE char(1), pSexo_IFE char(1), pANSI2_IFE char(1), pANSI7_IFE char(1), pModelo_IFE char(25))

RETURNING	 VARCHAR(5) --Codigo de Retorno

	DEFINE iSqlErr			INTEGER;
    DEFINE sErrParseo       CHAR(5);
	
	DEFINE cCodRet         CHAR(5);
    DEFINE sPonderacion     SMALLINT;
	DEFINE cSituacionCte        CHAR(1);
    DEFINE sCausaCte            SMALLINT;

    LET iSqlErr = 0;
    LET sErrParseo='';
	LET cCodRet='00000';
	LET sPonderacion = "0";
	LET cSituacionCte   ="";
	LET sCausaCte  = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
       -- SET DEBUG FILE TO '/tmp/cristo/bitacora_ife.sql';
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		
        IF TRIM(pModelo_IFE)<>'' THEN

            INSERT INTO si_bitacora_ife (numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws,
                                         flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife,
                                         ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, 
                                         emision_ife, cveelec_ife, curp_ife, estado, mpio_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, 
                                         edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife)
                                  VALUES(pnumcte, pejecutivo, psucursal, pcadena_anverso, pcadena_reverso, pflag_idbox, pflag_ws, 
                                         pflag_captura, presultado, pcausa_rechazo, current, pCod_Resp_IFE, pResp_IFE, pTime_IFE,  pAccess_IFE, pStamp_IFE, 
                                         pOCR_IFE, pApPat_IFE, pApMat_IFE, pNombre_IFE, pCalleNum_IFE,pColCp_IFE, pMpoEnt_IFE, pFolioNal_IFE, pAnioReg_IFE, 
                                         pEmision_IFE, pCveElec_IFE, pCurp_IFE, pEstado, pMpio_IFE, pLocalidad_IFE, pSeccion_IFE, pAnioEmision_IFE, pVigencia_IFE, 
                                         pEdad_IFE, pSexo_IFE, pANSI2_IFE, pANSI7_IFE, pModelo_IFE);

            EXECUTE PROCEDURE sp_parsea_cadena_idbx (pnumcte) INTO sErrParseo;
			
			IF TRIM(pCod_Resp_IFE) IN ('90','91','92','93','94') THEN
				IF pOCR_IFE='F' OR TRIM(pApPat_IFE)='F' OR TRIM(pApMat_IFE)='F' OR TRIM(pNombre_IFE)='F' THEN
					LET presultado = 'Falso';
					LET pcausa_rechazo = 'Datos NO Validos de Acuerdo al WS del INE';
					UPDATE si_bitacora_ife SET resultado=presultado, causa_rechazo=pcausa_rechazo WHERE numcte=pnumcte and fecha=current;
				END IF;
			END IF;
			
			 IF TRIM(presultado) = 'Verdadero' THEN
			 
				 EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(5,'001',pNumCte,'P',109,'', '','', '', '','','')
				 INTO cCodRet, sPonderacion,cSituacionCte,sCausaCte;
			
			 END IF;
			 
        END IF;

		RETURN '00000';
	END
END PROCEDURE;