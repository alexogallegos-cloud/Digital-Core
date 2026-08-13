CREATE PROCEDURE "informix".sp_consultacte_web(cOpcion CHAR(1), cTipoTar  CHAR(1), cNumTarjeta  CHAR(16), cNumCliente CHAR(20))
	RETURNING 
	CHAR(5),    -- Codigo de retorno
	CHAR(20),   -- # Cliente
	CHAR(110),  -- Nombre Cliente
	CHAR(13),   -- RFC
	CHAR(10), 	-- Fecha nacimiento
	CHAR(30);   -- Tipo Documento
	
	DEFINE cCodRet  	CHAR(5);
	DEFINE cNumeroCte	CHAR(20);
	DEFINE nombre1 		CHAR(26);
	DEFINE nombre2 	    CHAR(26);
	DEFINE apell_paterno 	CHAR(26);
	DEFINE apell_materno 	CHAR(26);
	DEFINE cNombreCte 	CHAR(110);
	DEFINE cRFC     	CHAR(13);
	DEFINE cFechaNac	CHAR(10);
	DEFINE cNumIdenti	CHAR(30);
	DEFINE iSqlErr  	INTEGER;
	DEFINE iExists		INTEGER;
	DEFINE iSecuencia 	INTEGER;
	
	LET cCodRet  	= "00000";
	LET cNumeroCte 	= "";
	LET nombre1 	= "";
	LET nombre2 	= "";
	LET apell_paterno 	= "";
	LET apell_materno 	= "";
	LET cNombreCte 	= "";
	LET cRFC 		= "";
	LET cFechaNac 	= "";
	LET cNumIdenti 	= "";
	LET iSqlErr 	= 1;
	LET iExists		= 0;
	LET iSecuencia	= 0;
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCodRet = iSqlErr;				
				RETURN cCodRet,cNumeroCte,cNombreCte,cRFC,cFechaNac,cNumIdenti;	
			END IF;
		END EXCEPTION;			
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/home/sysifx/Oscar/sp_consultaCte_web.out";
		--TRACE ON;
		IF (cOpcion = '' OR cOpcion IS NULL) THEN
			LET cCodRet = '00001';
		ELSE
			IF cOpcion = '1' THEN
				IF (cTipoTar = '' OR cTipoTar IS NULL) OR (cNumTarjeta = '' OR cNumTarjeta IS NULL) THEN
					LET cCodRet = '00001';
				ELSE
					IF cTipoTar = 'C' THEN
						SELECT 1 INTO iExists FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = cNumTarjeta;
						IF iExists > 0 THEN
							SELECT cte.numcte, cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.rfc, dcte.fecha_nac, dcte.numidentifi  --Por numero tarjeta bdicred
							INTO cNumeroCte, nombre1, nombre2, apell_paterno, apell_materno, cRFC, cFechaNac, cNumIdenti
							FROM bdinteg:"informix".si_cliente cte 
							INNER JOIN bdinteg:"informix".si_ctepf dcte ON cte.numcte = dcte.numcte
							INNER JOIN bdicred:"informix".sd_tarjeta trj ON cte.numcte = trj.numcte
							WHERE trj.num_tarjeta = cNumTarjeta;
							
							LET cNombreCte = TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno);
						ELSE
							LET cCodRet = '00003';
						END IF;
					ELIF cTipoTar = 'D' THEN	
						SELECT 1 INTO iExists FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = cNumTarjeta;
						IF iExists > 0 THEN
							SELECT cte.numcte, cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.rfc, dcte.fecha_nac, dcte.numidentifi  --Por numero tarjeta bdicheq
							INTO cNumeroCte,  nombre1, nombre2, apell_paterno, apell_materno, cRFC, cFechaNac, cNumIdenti
							FROM bdinteg:"informix".si_cliente cte 
							INNER JOIN bdinteg:"informix".si_ctepf dcte ON cte.numcte = dcte.numcte
							INNER JOIN bdicheq:"informix".sc_tarjeta trj ON cte.numcte = trj.numcte
							WHERE trj.num_tarjeta = cNumTarjeta;
							
							LET cNombreCte = TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno);
						ELSE
							LET cCodRet = '00003';
						END IF;
					END IF;				
				END IF;	
				IF cNumeroCte IS NULL THEN
					LET cCodRet = '00002';
				END IF;	
			ELIF cOpcion = '2' THEN
				IF (cNumCliente = '' OR cNumCliente IS NULL) THEN
					LET cCodRet = '00001';
				ELSE
					SELECT MAX(secuencia) INTO iSecuencia
					FROM bdinteg:"informix".si_huella_temp
					WHERE numcte = cNumCliente;
					
					DELETE FROM bdinteg:"informix".si_huella_temp WHERE numcte = cNumCliente AND secuencia = iSecuencia;
				END IF;
			ELSE
				LET cCodRet = '00004';
			END IF;
		END IF;	
		RETURN cCodRet,cNumeroCte,cNombreCte,cRFC,cFechaNac,NVL(cNumIdenti,'');

END
END PROCEDURE
DOCUMENT
'Se crea SP para la consuta de los datos del cliente por numero de tarjeta. Anexo a eso',
'se incluye la opcion del borrado del template temporal de la huella del cliente en caso de fallar el mantenimiento de huella y biometria',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 22/10/2019',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_consultaingresoscliente_web( pEmpresa CHAR(3), pNumCte CHAR(20))

--DATOS A REGRESAR---
	RETURNING 	CHAR(5)  	 AS CODRET, 
				CHAR(20) 	 AS NUMCTE_PROS,
				CHAR(60) 	 AS EMP_LABORA_CTE, 				
				INTEGER	 	 AS OPCION_PUESTO, 
				INTEGER	 	 AS OPCION_SUBPUESTO,
				MONEY(14,2)  AS INGRESO_MENSUAL, 
				CHAR(1)  	 AS TIPO_INGRESO,
				CHAR(8)  	 AS USUARIO_INSERT, 
				DATE     	 AS FECHA_INSERT,
				CHAR(13)     AS TELE_TRABAJO,
				CHAR(5)      AS EXT_TRABAJO,				
				CHAR(2)      AS ESTADO,
				CHAR(3)      AS CIUDAD,
				SMALLINT     AS NUM_CIUDAD,
				CHAR(5)      AS DELEGACION,
				INTEGER      AS COLONIA,
				INTEGER      AS CALLE,
				CHAR(10)     AS NUM_EXT,
				CHAR(10)     AS NUM_INT,
				CHAR(6)      AS DEPARTAMENTO,
				CHAR(5)      AS CP,
				CHAR(1)      AS UNIDAD_HAB,
				CHAR(1)      AS PUNTO_CARD,
				SMALLINT     AS MANZANA,
				SMALLINT     AS OTROS,
				SMALLINT     AS ANDADOR,
				SMALLINT     AS ETAPA,
				SMALLINT     AS EDIFICIO,
				SMALLINT     AS ENTRADA,
				SMALLINT     AS LOTE,
				CHAR(80)     AS OBSERVACIONES,
				CHAR(40)     AS ENTRE_CALLES;
			
-- DEFINICION DE VARIABLES
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE cEmpres 			CHAR(3);
	DEFINE cNumCte  		CHAR(20);
	DEFINE sSecIng 			SMALLINT;
	DEFINE cTipIng 			CHAR(1);
	DEFINE cNomEmp 			CHAR(60);
	DEFINE cPuesto 			CHAR(3);
	DEFINE cPutEsp 			CHAR(2);
	DEFINE dAntigd 			DECIMAL(4,2);
	DEFINE cNomDep 			CHAR(40);
	DEFINE cJefInm 			CHAR(60);
	DEFINE mIngMen 			MONEY(14,2);
	DEFINE cUsrInt 			CHAR(8);
	DEFINE dFecInt 			DATE;
	DEFINE iCvePst 			INTEGER;
	DEFINE iCveOPt 			INTEGER;
	DEFINE iCveSOP 			INTEGER;
	DEFINE iSisCot 			INTEGER;
	DEFINE iNumELa 			INTEGER;
	DEFINE iPerios 			INTEGER;
	DEFINE iTipIEx 			INTEGER;
	
    DEFINE vcCodRet         CHAR(5);   
    DEFINE vcNumPros        CHAR(20);
    DEFINE vcEstado         CHAR(2);
    DEFINE viCiudad         SMALLINT;
    DEFINE vcMunicipio      CHAR(5);
    DEFINE viColonia        INTEGER;
    DEFINE viCalle          INTEGER;
    DEFINE vcNumExt         CHAR(10);
    DEFINE vcNumInt         CHAR(10);
    DEFINE vcDepto          CHAR(6);
    DEFINE vcCodPos         CHAR(5);
    DEFINE vcPuntoCard      CHAR(1);
    DEFINE viManzana        SMALLINT;
    DEFINE viOtros          SMALLINT;
    DEFINE viAndador        SMALLINT;
    DEFINE viEtapa          SMALLINT;
    DEFINE viEdificio       SMALLINT;
    DEFINE viEntrada        SMALLINT;
    DEFINE viLote           SMALLINT;
    DEFINE vcObservaciones  CHAR(80);
    DEFINE vcEntreCalles    CHAR(40);
    DEFINE vcTelCasa        CHAR(13);
    DEFINE vcTelCelular     CHAR(13);
    DEFINE viCarrier        SMALLINT;
    DEFINE vcTelTrabajo     CHAR(13);
    DEFINE vcExtTrabajo     CHAR(5);
    DEFINE vcCiudad         CHAR(3);
    DEFINE vcUnidadHab      CHAR(1);

--INICIALIZACION DE VARIABLES 
	LET iSqlErr 		= 0;
	LET cCodRet 		= '00000';
	LET cEmpres 		= '';
	LET cNumCte 		= '';
	LET sSecIng 		= 0;
	LET cTipIng 		= '';
	LET cNomEmp 		= '';
	LET cPuesto 		= '';
	LET cPutEsp 		= '';
	LET dAntigd 		= 0;
	LET cNomDep 		= '';
	LET cJefInm 		= '';
	LET mIngMen 		= 0;
	LET cUsrInt 		= '';
	LET dFecInt 		= DATE(1);
	LET iCvePst 		= 0;
	LET iCveOPt 		= 0;
	LET iCveSOP 		= 0;
	LET iSisCot 		= 0;
	LET iNumELa 		= 0;
	LET iPerios 		= 0;
	LET iTipIEx 		= 0;
	
    LET vcCodRet       	= '00000';   
    LET vcNumPros       = '';
    LET vcEstado        = ''; 
    LET viCiudad        = 0; 
    LET vcMunicipio     = ''; 
    LET viColonia       = 0; 
    LET viCalle         = 0; 
    LET vcNumExt        = ''; 
    LET vcNumInt        = ''; 
    LET vcDepto         = ''; 
    LET vcCodPos        = ''; 
    LET vcPuntoCard     = ''; 
    LET viManzana       = 0;  
    LET viOtros         = 0;  
    LET viAndador       = 0;  
    LET viEtapa         = 0;  
    LET viEdificio      = 0;  
    LET viEntrada       = 0;  
    LET viLote          = 0;  
    LET vcObservaciones = '';
    LET vcEntreCalles   = ''; 
    LET vcTelCasa       = ''; 
    LET vcTelCelular    = ''; 
    LET viCarrier       = 0;  
    LET vcTelTrabajo    = '';
    LET vcExtTrabajo    = '';
    LET vcCiudad        = '';
    LET vcUnidadHab     = '';
	
	
	--SET DEBUG FILE TO '/informix/sp_consultaingresoscliente_web.out';
	--TRACE ON;

-- INICIO DEL PROCEDIMIENTO
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	Call bdinteg:"informix".sp_ConsultaIngresosCliente(2, pNumCte, 'T')
		RETURNING cCodRet, cEmpres, cNumCte, sSecIng, cTipIng, cNomEmp, cPuesto, cPutEsp, dAntigd, cNomDep, cJefInm, mIngMen, cUsrInt, dFecInt, 
				  iCvePst, iCveOPt, iCveSOP, iSisCot, iNumELa, iPerios, iTipIEx;
	
	IF cCodRet = "00000" THEN
		Call bdinteg:"informix".sp_consbco_dirtel( pEmpresa, pNumCte, 2)
		RETURNING vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
			
	ELIF cCodRet = "00001" THEN
		LET cCodRet = "00000";
		Call bdinteg:"informix".sp_consbco_dirtel( pEmpresa, pNumCte, 2)
		RETURNING vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
	ELSE
		RETURN cCodRet,pNumCte,cNomEmp,iCveOPt,iCveSOP,mIngMen,cTipIng,cUsrInt,dFecInt,vcTelTrabajo,vcExtTrabajo,vcEstado,vcCiudad,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,vcCodPos,vcUnidadHab,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,vcEntreCalles;	 
	END IF;
	
	IF vcCodRet = "00000" THEN	
		RETURN cCodRet,pNumCte,cNomEmp,iCveOPt,iCveSOP,mIngMen,cTipIng,cUsrInt,dFecInt,vcTelTrabajo,vcExtTrabajo,vcEstado,vcCiudad,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,vcCodPos,vcUnidadHab,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,vcEntreCalles;
	ELIF vcCodRet = "00111" THEN
		RETURN cCodRet,pNumCte,cNomEmp,iCveOPt,iCveSOP,mIngMen,cTipIng,cUsrInt,dFecInt,'','','','','','','','','','','','','','','','','','','','','','','';
	ELSE
		LET cCodRet= vcCodRet;
		RETURN cCodRet,pNumCte,cNomEmp,iCveOPt,iCveSOP,mIngMen,cTipIng,cUsrInt,dFecInt,vcTelTrabajo,vcExtTrabajo,vcEstado,vcCiudad,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,vcCodPos,vcUnidadHab,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,vcEntreCalles;
	END IF;	
END;
END PROCEDURE             
DOCUMENT
"DESCRIPCION: ...",
"REALIZO: Jorge Lara",
"FECHA: 28/Abril/2017",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_conhuella_temp_web_442( cEmpresa CHAR(3),
                                         cSucursal CHAR(4),
                                         cUser_Insert CHAR(8),
                                         cNumCte CHAR(20))
	RETURNING CHAR(5);

	DEFINE cCodRet    CHAR(5);
	DEFINE cExiste    CHAR(1);
	DEFINE cSqlErr    INTEGER;
	DEFINE cIsamErr   INTEGER;
	DEFINE cDHActual  CHAR(955);
	DEFINE cDH1  	  CHAR(955);
	DEFINE cDH2  	  CHAR(955);
	DEFINE cDH3  	  CHAR(955);
	DEFINE cDH4  	  CHAR(955);
	DEFINE cDH5  	  CHAR(955);
	DEFINE cDH6  	  CHAR(955);
	DEFINE cDH7  	  CHAR(955);
	DEFINE cDH8  	  CHAR(955);
	DEFINE cDH9  	  CHAR(955);
	DEFINE cDH10      CHAR(955);
	DEFINE cContador  INTEGER;
	DEFINE iSecuencia SMALLINT;

	LET cCodRet = "00000";
	LET cExiste = 0;
	LET cDHActual = "";
	LET cDH1 = "";
	LET cDH2 = "";
	LET cDH3 = "";
	LET cDH4 = "";
	LET cDH5 = "";
	LET cDH6 = "";
	LET cDH7 = "";
	LET cDH8 = "";
	LET cDH9 = "";
	LET cDH10 = "";
	LET cContador = 1;
	LET iSecuencia = 0;

	BEGIN
		ON EXCEPTION SET cSqlErr,cIsamErr
		IF cSqlErr != 0 THEN
			LET cCodRet=cSqlErr;
			RETURN cCodRet;
		END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--- Verifica recepcion correcta de datos
		IF NVL(cNumCte, '') = '' THEN 
			LET cCodRet = "00110";
			RETURN cCodRet;
		END IF;

		SELECT 1 INTO cExiste
		FROM si_ejecut
		WHERE ejecutivo=cUser_Insert;
		IF cExiste IS NULL THEN
			LET cCodRet="00112";
			RETURN cCodRet;
		END IF;

		SELECT MAX(secuencia) INTO iSecuencia FROM si_cte_huella_dec_temp WHERE numcte = cNumCte;
	   
		FOREACH
			SELECT template 
			INTO cDHActual
			FROM bdinteg:si_cte_huella_dec_temp
			WHERE  numcte = cNumCte
			AND status ="M" AND secuencia = iSecuencia
			ORDER BY id_template ASC
			
			IF (cContador = 1) THEN 
				LET cDH1 = cDHActual;
			END IF;
			
			IF (cContador = 2) THEN 
				LET cDH2 = cDHActual;
			END IF;
			
			IF (cContador = 3) THEN 
				LET cDH3 = cDHActual;
			END IF;
			
			IF (cContador = 4) THEN 
				LET cDH4 = cDHActual;
			END IF;
			
			IF (cContador = 5) THEN 
				LET cDH5 = cDHActual;
			END IF;
			
			IF (cContador = 6) THEN 
				LET cDH6 = cDHActual;
			END IF;
			
			IF (cContador = 7) THEN 
				LET cDH7 = cDHActual;
			END IF;
			
			IF (cContador = 8) THEN 
				LET cDH8 = cDHActual;
			END IF;
			
			IF (cContador = 9) THEN 
				LET cDH9 = cDHActual;
			END IF;
			
			IF (cContador = 10) THEN 
				LET cDH10 = cDHActual;
			END IF;
			
			LET cContador = cContador + 1;
		END FOREACH;
	   
		IF NVL(cDH1, '') = '' or NVL(cDH2, '') = '' or NVL(cDH3, '') = '' or NVL(cDH4, '') = '' or NVL(cDH5, '') = '' or
			NVL(cDH6, '') = '' or NVL(cDH7, '') = '' or NVL(cDH8, '') = '' or NVL(cDH9, '') = '' or NVL(cDH10, '') = '' THEN
			let cCodRet = "00132";
			RETURN cCodRet;
		END IF;
		RETURN cCodRet;
		
	END;
END PROCEDURE;