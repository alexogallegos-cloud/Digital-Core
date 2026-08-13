CREATE PROCEDURE "informix".sp_guarda_tenedor_bym(pAp_paterno CHAR(40), pAp_materno CHAR(40), pNombre_1 CHAR(40) ,pNombre_2 CHAR(40), pFecha_nac CHAR(10), pRfc CHAR(13), pIdentificacion CHAR(20), pNum_identificacion CHAR(40), pCalle CHAR(40), pNumero_calle CHAR(10), pColonia CHAR(6), pDelegacion_poblacion  CHAR(3), pCod_postal  CHAR(5), pCiudad  CHAR(3), pEstado CHAR(2),  pTelefono CHAR(13), pTipo_tel CHAR(10), pEmail CHAR(30), pEjecutivo_insert CHAR(8))
RETURNING   CHAR(6) AS CodRet,
            INTEGER AS IdTenedor ;

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE cCodRet              CHAR(6);
DEFINE iIdTenedor           INTEGER;

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '000000';
LET iIdTenedor          = 0;



SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_guarda_tenedor_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			RETURN cCodRet, iIdTenedor;
		END IF;
	END EXCEPTION; 
	
	IF TRIM(NVL(pAp_paterno,'')) <> '' AND TRIM(NVL(pNombre_1,'')) <> '' AND TRIM(NVL(pFecha_nac,'')) <> ''  AND  TRIM(NVL(pRfc,'')) <> '' AND TRIM(NVL(pCalle,'')) <> '' AND TRIM(NVL(pNumero_calle,'')) <> '' AND TRIM(NVL(pColonia,'')) <> '' AND TRIM(NVL(pCod_postal,'')) <> '' AND TRIM(NVL(pEstado,'')) <> '' AND TRIM(NVL(pTelefono,'')) <> '' AND  TRIM(NVL(pTipo_tel,'')) <> '' AND TRIM(NVL(pEjecutivo_insert,'')) <> '' THEN 
		IF CAST(TRIM(pEstado) AS INTEGER) = 9 THEN 
			IF TRIM(NVL(pDelegacion_poblacion,'')) = '' THEN  	
				LET cCodRet  = '000001';
			ELSE
				IF TRIM(NVL(pCiudad,'')) = '' THEN  	
					LET pCiudad  = ' ';
				END IF;
			END IF;
		ELSE
			IF TRIM(NVL(pCiudad,'')) = '' THEN  	
				LET cCodRet  = '000001';
			ELSE
				IF TRIM(NVL(pDelegacion_poblacion,'')) = '' THEN  	
					LET pDelegacion_poblacion  = ' ';
				END IF;
			END IF;
			
		END IF;
		
		IF cCodRet  = '000000' THEN
		
			INSERT INTO bdisuc:"informix".ss_tenedor_pieza(ap_paterno,ap_materno,nombre_1,nombre_2,fecha_nac,rfc,identificacion,num_identificacion,calle,numero_calle,colonia,delegacion_poblacion,cod_postal,ciudad,estado,telefono,tipo_tel,email,ejecutivo_insert,fecha_insert) 
			VALUES(pAp_paterno,pAp_materno,pNombre_1,pNombre_2,pFecha_nac,pRfc,pIdentificacion,pNum_identificacion,pCalle,pNumero_calle,pColonia,pDelegacion_poblacion,pCod_postal,pCiudad,pEstado,pTelefono,pTipo_tel,pEmail,pEjecutivo_insert,CURRENT);
			
			SELECT MAX(id_tenedor)
			INTO iIdTenedor
			FROM bdisuc:"informix".ss_tenedor_pieza
			WHERE ap_paterno = pAp_paterno
			AND ap_materno = pAp_materno
			AND nombre_1 = pNombre_1
			AND nombre_2 = pNombre_2
			AND fecha_nac = pFecha_nac
			AND rfc = pRfc;
			
			IF NVL(iIdTenedor,0) = 0 THEN
				LET cCodRet  = '000001'; -- luego pregunto
			END IF;
			
		END IF;
	
	ELSE
		LET cCodRet  = '000001';
	END IF;
	
	RETURN cCodRet, iIdTenedor;

END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 03/02/2015',
'DESCRIPCION: Guarda los datos del cliente que presenta un billete presuntamente falso.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consulta_nombre_bym(pNombre1 CHAR(20), pNombre2 CHAR(20), pPaterno CHAR(20), pMaterno CHAR(20), pFechaNac CHAR(10), pSecuencia INTEGER)
RETURNING   CHAR(6)  AS CodRet,
			CHAR(40) AS Nombre1,
			CHAR(40) AS Nombre2,
			CHAR(40) AS ApPaterno,
			CHAR(40) AS ApMaterno,
			CHAR(13) AS RFC,
			CHAR(10) AS NumRecibo,
			INTEGER  AS Registros,
			INTEGER  AS Termino;
			

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE cCodRet              CHAR(6);
DEFINE cNombre1             CHAR(40);
DEFINE cNombre2             CHAR(40);
DEFINE cApPaterno           CHAR(40);
DEFINE cApMaterno           CHAR(40);
DEFINE cRFC                 CHAR(13);
DEFINE cNumRecibo           CHAR(10);
DEFINE sSecuencia           INTEGER;
DEFINE sTermino             INTEGER;
DEFINE iTenedor             INTEGER;
DEFINE iRegistros           INTEGER;
DEFINE iBandRegistros       INTEGER;

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '000000';
LET cNombre1            = '';
LET cNombre2            = '';
LET cApPaterno          = '';
LET cApMaterno          = '';
LET cRFC                = '';
LET cNumRecibo          = '';
LET sSecuencia          = 0;
LET sTermino            = 0;
LET iTenedor            = 0;
LET iRegistros          = 0;
LET iBandRegistros      = 0;

SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_consulta_nombre_bym.out";
-- TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cRFC, cNumRecibo, sSecuencia, sTermino WITH RESUME;
		END IF;
	END EXCEPTION;
	        
	IF TRIM(NVL(pNombre1,'')) <> '' AND TRIM(NVL(pPaterno,'')) <> '' AND TRIM(NVL(pFechaNac,'')) <> '' AND  NVL(pSecuencia,-1)>= 0   THEN 
		
		LET sSecuencia = pSecuencia;
		
		SELECT {+INDEX (bdisuc:"informix".ss_tenedor_pieza idx_tenedornomfechaComta)} COUNT (id_tenedor)
		INTO iRegistros
		FROM bdisuc:"informix".ss_tenedor_pieza
		WHERE nombre_1 MATCHES TRIM(pNombre1)
		AND nombre_2 MATCHES TRIM(pNombre2)
		AND ap_paterno = TRIM(pPaterno)
		AND ap_materno = TRIM(pMaterno)
		AND fecha_nac = pFechaNac;
		
		FOREACH
			SELECT {+INDEX (bdisuc:"informix".ss_tenedor_pieza idx_tenedornomfechaComta)} SKIP pSecuencia LIMIT 20 id_tenedor, nombre_1, nombre_2, ap_paterno, ap_materno, rfc 
			INTO iTenedor, cNombre1, cNombre2, cApPaterno, cApMaterno, cRFC
			FROM bdisuc:"informix".ss_tenedor_pieza
			WHERE nombre_1 MATCHES TRIM(pNombre1)
			AND nombre_2 MATCHES TRIM(pNombre2)
			AND ap_paterno = TRIM(pPaterno)
			AND ap_materno = TRIM(pMaterno)
			AND fecha_nac =  pFechaNac
			ORDER BY id_tenedor
			
			LET iBandRegistros = 1;
			
			SELECT num_recibo
			INTO cNumRecibo
			FROM bdisuc:"informix".ss_recibo_bym_falsos
			WHERE id_tenedor= iTenedor;
		
			LET sSecuencia = sSecuencia + 1;
			
			IF iRegistros = sSecuencia THEN
				LET sTermino = 1;
			END IF;
			
			RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cRFC, cNumRecibo, sSecuencia, sTermino WITH RESUME;
		
		END FOREACH;
		
		IF NVL(iRegistros,0) = 0 THEN
			LET cCodRet = '000004';
		ELSE
			IF iBandRegistros = 0 THEN
				LET cCodRet = '000004';
			END IF;
		END IF;
	ELSE	
		IF TRIM(NVL(pPaterno ,'')) = '' THEN
			LET cCodRet = '000001';
		ELIF TRIM(NVL(pNombre1,'')) = '' THEN
			LET cCodRet = '000002';
		ELIF TRIM(NVL(pFechaNac,'')) = '' THEN
			LET cCodRet = '000003';
		END IF;
	END IF;
	
	IF cCodRet <> '000000' THEN
		RETURN cCodRet, cNombre1, cNombre2, cApPaterno, cApMaterno, cRFC, cNumRecibo, sSecuencia, sTermino WITH RESUME;
	END IF
	
END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 03/02/2015',
'DESCRIPCION: Consulta por nombre y fecha de nacimiento en la tabla ss_tenedor_pieza',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consultacat_piezas_bym(pOpcion CHAR(1), pDato CHAR(1))
RETURNING   CHAR(6) AS CodRet,
			INTEGER AS IdTipoPieza,
			CHAR(1) AS CveTipoPieza,
			CHAR(7) AS TipoPieza;
			
			

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE cCodRet              CHAR(6);
DEFINE iIdTipoPieza         INTEGER;
DEFINE cCveTipoPieza        CHAR(1);
DEFINE cTipoPieza           CHAR(7);
DEFINE iBandera             INTEGER;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '000000';
LET iIdTipoPieza		= 0;
LET cCveTipoPieza       = '';
LET cTipoPieza          = '';
LET iBandera            = 0;


SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_consultacat_piezas_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			RETURN cCodRet, iIdTipoPieza, cCveTipoPieza, cTipoPieza WITH RESUME;
		END IF;
	END EXCEPTION;
	        
	IF TRIM(NVL(pOpcion,'')) = '1' OR TRIM(NVL(pOpcion,'')) = '2' THEN
		IF pOpcion= '2' AND TRIM(NVL(pDato,'' )) = '' THEN
			LET cCodRet = '000001';
		ELSE
			FOREACH	
				SELECT  id_tipo_pieza, clave_tipo_pieza, tipo_pieza 
				INTO iIdTipoPieza, cCveTipoPieza, cTipoPieza
				FROM bdisuc:"informix".ss_cat_tipo_pieza_bym_falsos
				WHERE empresa = '001' 
				AND clave_tipo_pieza = CASE WHEN pOpcion= '2' THEN NVL(pDato,'') ELSE clave_tipo_pieza END
			
				LET iBandera =  1;
				
				RETURN cCodRet, iIdTipoPieza, cCveTipoPieza, cTipoPieza WITH RESUME;
				
			END FOREACH;
		
			IF iBandera = 0 THEN
				LET cCodRet = '000002';
			END IF;
		END IF;
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	IF cCodRet <> '000000' THEN
		RETURN cCodRet, iIdTipoPieza, cCveTipoPieza, cTipoPieza WITH RESUME;
	END IF;
	
END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 03/02/2015',
'DESCRIPCION: Consulta el catálogo de de la tabla ss_cat_tipo_pieza_bym_falsos.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consulta_catdenominacion_bym(pOpcion CHAR(1), pDato CHAR(1))
RETURNING   CHAR(6)  AS CodRet,
			INTEGER  AS IdDenominacion,
			CHAR(1)  AS CvePieza,
			CHAR(7)  AS TipoPieza,
			CHAR(10) AS Denominacion;
			
-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE cCodRet              CHAR(6);
DEFINE iIdDenominacion      INTEGER;
DEFINE cCvePieza        	CHAR(1);
DEFINE cTipoPieza           CHAR(7);
DEFINE cDenominacion        CHAR(10);
DEFINE iBandera             INTEGER;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '000000';
LET iIdDenominacion		= 0;
LET cCvePieza           = '';
LET cTipoPieza          = '';
LET cDenominacion       = '';
LET iBandera            = 0;


SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_consulta_catdenominacion_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			RETURN cCodRet, iIdDenominacion, cCvePieza, cTipoPieza, cDenominacion WITH RESUME;
		END IF;
	END EXCEPTION;
	
	IF TRIM(NVL(pOpcion,''))= '1' OR TRIM(NVL(pOpcion,''))= '2' THEN
	
		IF TRIM(pOpcion) = '2' AND  TRIM(NVL(pDato,'')) = '' THEN
			LET cCodRet = '000001';
		ELSE
			FOREACH
				SELECT id_denominacion, clave_pieza, tipo_pieza, denominacion
				INTO  iIdDenominacion, cCvePieza, cTipoPieza, cDenominacion  
				FROM bdisuc:"informix".ss_denominacion_bym_falsos
				WHERE empresa = '001'
				AND	clave_pieza = CASE WHEN TRIM( pOpcion) = '2' THEN NVL(pDato,'') ELSE clave_pieza END
				
				LET iBandera =  1;
			
				RETURN cCodRet, iIdDenominacion, cCvePieza, cTipoPieza, cDenominacion WITH RESUME;
			END FOREACH;
			
			IF iBandera = 0 THEN
				LET cCodRet = '000002';
			END IF;
		END IF;
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	IF cCodRet <>  '000000' THEN
		RETURN cCodRet, iIdDenominacion, cCvePieza, cTipoPieza, cDenominacion WITH RESUME;
	END IF;
	
END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 03/02/2015',
'DESCRIPCION: Consulta el catálogo de la tabla ss_denominacion_bym_falsos.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consultarpt_bym(pOpcion CHAR(1), pFechaIni DATE, pFechaFin DATE,pNumSucursal CHAR(4), pEmpresa CHAR(3),pEjecutivo CHAR(8),pRegistros SMALLINT)

	RETURNING
		CHAR(6) 	AS cCodRet,
		INTEGER		AS iNum_Piezas,
		CHAR(10)	AS cNumRecibo,
		CHAR(8) 	AS cNumUsuario,
		CHAR(45) 	AS cNombre,
		CHAR(10) 	AS cDenominacion,
		CHAR(40) 	AS cNumSerie,
		INTEGER		AS iCantidad,
		CHAR(160) 	AS cNombreCte,
		CHAR(40) 	AS cFolioBanxico,
		INTEGER 	AS iSumCantidad;

--DECLARACION DE VARIABLES
	DEFINE cCodRet 				CHAR(6);
	DEFINE cNumUsuario 			CHAR(8);
	DEFINE cNombre 				CHAR(100);
	DEFINE cDenominacion 		CHAR(10);
	DEFINE cNumSerie 			CHAR(40);
	DEFINE iCantidad 			INTEGER;
	DEFINE cNombreCte 			CHAR(160);
	DEFINE cFolioBanxico 		CHAR(40);
	DEFINE iSqlErr				INTEGER;
	DEFINE dtFechaHoy			DATE;
	DEFINE cNumRecibo			CHAR(10);
	DEFINE sContNumRecib    	SMALLINT;
	DEFINE iDenom 				INTEGER;
	DEFINE iNum_Piezas 			INTEGER;
	DEFINE cNumRecibo2 			CHAR(10);
	--Denomicacion
	DEFINE cDenominacion2  		CHAR(10);
	DEFINE iContDenom			SMALLINT;
	--id_tenedor
	DEFINE iTenedor				INTEGER;
	--nombre_completo			
	DEFINE iSumCantidad 		INTEGER;	
	DEFINE iOpcion1  			INTEGER;
	DEFINE iOpcion2  			INTEGER;
	DEFINE vDia 				CHAR(2);
	DEFINE vMes					CHAR(2);
	DEFINE vAnio 				CHAR(4);
	DEFINE vFechaFinal 			CHAR(10);
	DEFINE vFechaInicial  		CHAR(10);

--INICIALIZACION DE VARIABLES
	LET cNombre 				= '';
	LET cNumUsuario 			= '';
	LET cCodRet 				= '000000';
	LET cDenominacion 			= '';
	LET cNumSerie 				= '';
	LET vDia 					= '';
	LET vMes 					= '';
	LET vAnio 					= '';
	LET cNombreCte 				= '';
	LET cFolioBanxico 			= '';
	LET iCantidad 				= 0 ;
	LET cNumRecibo 				= '';
	LET dtFechaHoy 				= '';
	LET sContNumRecib 			= 0;
	LET iSqlErr 				= 0;
	LET iDenom 					= 0;
	LET iNum_Piezas 			= 0;
	LET cNumRecibo2				='';
	LET iContDenom 				= 0;
	LET iTenedor 				= 0;
	LET cDenominacion2 			= 0;
	LET iSumCantidad 			= 0;
	LET iOpcion1 				= 0;
	LET iOpcion2 				= 0;
	LET vFechaFinal             ='';
	LET vFechaInicial           ='';
	--CÃ³digo de Retorno
	--000000 = EjecuciÃ³n Exitosa
	--000001 = ParÃ¡metros de Entrada VacÃ­os
	--000002 = No se encontraron registros
	
	
	-----------------------------------------------------------------------	
	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_consultarpt_bym.out";
	--TRACE ON;
	-----------------------------------------------------------------------
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				RETURN NVL(cCodRet,''),iNum_Piezas, NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''), NVL(iCantidad,0), 
				NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
			END IF;
		END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy INTO dtFechaHoy FROM bdinteg: "informix".si_fechas WHERE empresa = pEmpresa;
		
		
		LET vDia = LPAD(day(pFechaIni),2,'0');
		LET vMes = LPAD(MONTH(pFechaIni),2,'0');
		LET vAnio = YEAR(pFechaIni);
		LET vFechaInicial = LPAD(vMes,2,'0')||'-'||LPAD(vDia,2,'0')||'-'|| vAnio;
		LET vDia = LPAD(day(pFechaFin),2,'0');
		LET vMes = LPAD(MONTH(pFechaFin),2,'0');
		LET vAnio = YEAR(pFechaFin);
		LET vFechaFinal = LPAD(vMes,2,'0')||'-'||LPAD(vDia,2,'0')||'-'|| vAnio;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF TRIM(NVL(pOpcion,''))=''THEN
			LET cCodRet = '000001';
			RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''), NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''), NVL(iCantidad,0), 
			NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
		END IF;	
		
		--OPCION 1 REPORTE DIARIO
		--TODO LOS USUARIOS
		IF pEjecutivo = '' AND pOpcion = '1' THEN
			
			IF(SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pNumSucursal
				AND empresa_retiene = pEmpresa AND fecha_insert = dtFechaHoy ) > 0 THEN--6
				LET iOpcion1 = 1;
			ELSE
				LET cCodRet = '000002';
				LET cNumRecibo = '1';
				RETURN NVL(cCodRet,''),iNum_Piezas, nVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
							NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);	
			END IF;		--UN SOLO USUARIO	
		ELIF pEjecutivo <> ''  AND pOpcion = '1' THEN
			
			IF(SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pNumSucursal
				AND empresa_retiene = pEmpresa AND fecha_insert = dtFechaHoy AND ejecutivo_insert = pEjecutivo) > 0 THEN
				LET iOpcion1 = 1;
			ELSE
				LET cCodRet = '000002';
				LET cNumRecibo = '2';
				RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''), NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''), NVL(iCantidad,0), 
				NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
			END IF;	
		--OPCION 2 REPORTE HISTORICO	
		ELIF pOpcion = '2'  THEN
			IF TRIM(NVL(pFechaIni,''))='' OR TRIM(NVL(pFechaFin,''))='' THEN	
				LET cCodRet = '000001';
				RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''), NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''), NVL(iCantidad,0), 
				NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
			ELSE
				--TODO LOS USUARIOS
				IF  pEjecutivo = '' THEN
				
					IF(SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pNumSucursal	AND empresa_retiene = pEmpresa AND fecha_insert BETWEEN vFechaInicial AND vFechafinal) > 0 THEN
						LET iOpcion2 = 1;
					ELSE
						LET cCodRet = '000002';
						LET cNumRecibo = '3';
						RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
								NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
					END IF;
				--UN SOLO USUARIO	
				ELIF pEjecutivo <> ''THEN
					IF(SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos  WHERE num_sucursal_retencion = pNumSucursal	AND empresa_retiene = pEmpresa AND fecha_insert BETWEEN pFechaIni AND pFechaFin
					AND ejecutivo_insert = pEjecutivo) > 0 THEN
						LET iOpcion2 = 1;
					ELSE
						LET cCodRet = '000002';
						LET cNumRecibo = '4';
						RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
								NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);	
					END IF;	
				END IF;
			END IF;	
		END IF;

		IF iOpcion1 = 1 THEN
			FOREACH 	
				SELECT FIRST 10 TRIM(NVL(num_recibo,'')) INTO cNumRecibo
				FROM "informix".ss_recibo_bym_falsos 
				WHERE num_sucursal_retencion = pNumSucursal
				AND empresa_retiene = pEmpresa
				AND ejecutivo_insert = DECODE(pEjecutivo,'',ejecutivo_insert,pEjecutivo)
				AND fecha_insert = dtFechaHoy
				
				IF(SELECT COUNT(*) FROM "informix". ss_piezas_bym_falsos WHERE num_recibo = cNumRecibo) > 0 THEN
					FOREACH
						SELECT NVL(id_pieza,0),TRIM(NVL(ejecutivo_insert,'')), NVL(id_denominacion,0), TRIM(NVL(serie,'')), NVL(num_piezas,0), 
							TRIM(NVL(num_recibo,'')), TRIM(NVL(folio_banxico,''))
						INTO iNum_Piezas,cNumUsuario,iDenom,cNumSerie,iCantidad,cNumRecibo2,cFolioBanxico
						FROM "informix". ss_piezas_bym_falsos
						WHERE num_recibo = cNumRecibo
				
						LET cDenominacion = CAST(iDenom AS CHAR(10));
						Let iSumCantidad = iSumCantidad + iCantidad;

						IF(SELECT COUNT(*) FROM "informix".ss_denominacion_bym_falsos WHERE id_denominacion = iDenom AND empresa=TRIM(NVL(pEmpresa,''))) > 0 THEN
							SELECT TRIM(NVL(denominacion,'')) INTO cDenominacion2 FROM "informix".ss_denominacion_bym_falsos
							WHERE id_denominacion = iDenom AND empresa=TRIM(NVL(pEmpresa,''));
					
							IF (SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos WHERE num_recibo = cNumRecibo2) >  0 THEN

								SELECT NVL(id_tenedor,0) INTO iTenedor  FROM "informix".ss_recibo_bym_falsos
								WHERE num_recibo = cNumRecibo;
								---
								IF(SELECT COUNT(*) FROM "informix".ss_tenedor_pieza  WHERE id_tenedor = iTenedor) > 0 THEN 
									SELECT TRIM(NVL(nombre_1,"")) || " " || TRIM(NVL(nombre_2,"")) || " " || TRIM(NVL(ap_paterno,"")) || " " || TRIM(NVL(ap_materno,""))
									INTO cNombreCte
									FROM "informix".ss_tenedor_pieza 
									WHERE id_tenedor = iTenedor;
									
									IF(SELECT COUNT(*) FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = cNumUsuario) > 0 THEN
										SELECT nombre INTO cNOmbre FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = cNumUsuario;
									ELSE
										LET sContNumRecib = 1;
									END IF;	
								ELSE
									LET sContNumRecib = 1;
								END IF;
							ELSE
								LET sContNumRecib = 1;
							END IF;
						ELSE
							LET sContNumRecib = 1;
						END IF
				
						LET iContDenom = iContDenom + 1;
				
						IF iContDenom <= pRegistros THEN
							CONTINUE FOREACH;
						END IF;
						
						RETURN NVL(cCodRet,''), iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion2,''), NVL(cNumSerie,''), NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0) WITH RESUME;
				
					END FOREACH	

				ELSE
					LET sContNumRecib = 1;
				END IF;

				IF sContNumRecib = 1 THEN
					LET cCodRet = '000002';
					LET cNumRecibo = '5';
					RETURN NVL(cCodRet,''), iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
					NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
				END IF; 
			END FOREACH	
			
		ELIF iOpcion2 = 1 THEN
			FOREACH 
				SELECT FIRST 10 TRIM(NVL(num_recibo,'')) INTO cNumRecibo
				FROM "informix".ss_recibo_bym_falsos 
				WHERE num_sucursal_retencion = pNumSucursal
				AND fecha_insert >=vFechaInicial
				AND fecha_insert <=vFechafinal
				AND empresa_retiene = pEmpresa
				AND ejecutivo_insert = CASE WHEN TRIM(NVL(pEjecutivo,''))<>'' THEN TRIM(NVL(pEjecutivo,''))
										ELSE ejecutivo_insert END--DECODE(pEjecutivo,'',ejecutivo_insert,pEjecutivo)
				
				IF(SELECT COUNT(*) FROM "informix". ss_piezas_bym_falsos WHERE num_recibo = cNumRecibo) > 0 THEN
					FOREACH
						SELECT NVL(id_pieza,0),TRIM(NVL(ejecutivo_insert,'')), NVL(id_denominacion,0), TRIM(NVL(serie,'')), NVL(num_piezas,0), 
							TRIM(NVL(num_recibo,'')), TRIM(NVL(folio_banxico,''))
						INTO iNum_Piezas,cNumUsuario,iDenom,cNumSerie,iCantidad,cNumRecibo2,cFolioBanxico
						FROM "informix". ss_piezas_bym_falsos
						WHERE num_recibo = cNumRecibo
				
						LET cDenominacion = CAST(iDenom AS CHAR(10));
						Let iSumCantidad = iSumCantidad + iCantidad;

						IF(SELECT COUNT(*) FROM "informix".ss_denominacion_bym_falsos WHERE id_denominacion = iDenom AND empresa=TRIM(NVL(pEmpresa,''))) > 0 THEN
							SELECT TRIM(NVL(denominacion,'')) INTO cDenominacion2 FROM "informix".ss_denominacion_bym_falsos
							WHERE id_denominacion = iDenom AND empresa=TRIM(NVL(pEmpresa,''));
					
							IF (SELECT COUNT(*) FROM "informix".ss_recibo_bym_falsos WHERE num_recibo = cNumRecibo2) >  0 THEN

								SELECT NVL(id_tenedor,0) INTO iTenedor  FROM "informix".ss_recibo_bym_falsos
								WHERE num_recibo = cNumRecibo;
								---
								IF(SELECT COUNT(*) FROM "informix".ss_tenedor_pieza  WHERE id_tenedor = iTenedor) > 0 THEN 
									SELECT TRIM(NVL(nombre_1,"")) || " " || TRIM(NVL(nombre_2,"")) || " " || TRIM(NVL(ap_paterno,"")) || " " || TRIM(NVL(ap_materno,""))
									INTO cNombreCte
									FROM "informix".ss_tenedor_pieza 
									WHERE id_tenedor = iTenedor;
									
									IF(SELECT COUNT(*) FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = cNumUsuario) > 0 THEN
										SELECT nombre INTO cNOmbre FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = cNumUsuario;
									ELSE
										LET sContNumRecib = 1;
									END IF;	
								ELSE
									LET sContNumRecib = 1;
								END IF;
							ELSE
								LET sContNumRecib = 1;
							END IF;
						ELSE
							LET sContNumRecib = 1;
						END IF
				
						LET iContDenom = iContDenom + 1;
				
						IF iContDenom <= pRegistros THEN
							CONTINUE FOREACH;
						END IF;
						
						RETURN NVL(cCodRet,''),iNum_Piezas, NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion2,''), NVL(cNumSerie,''), NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0) WITH RESUME;
				
					END FOREACH	

				ELSE
					LET sContNumRecib = 1;
				END IF;


				IF sContNumRecib = 1 THEN
					LET cCodRet = '000002';
					LET cNumRecibo = '6';
					RETURN NVL(cCodRet,''),iNum_Piezas,NVL(cNumRecibo,''),NVL(cNumUsuario,''), NVL(cNombre,''), NVL(cDenominacion,''), NVL(cNumSerie,''),
					NVL(iCantidad,0), NVL(cNombreCte,''), NVL(cFolioBanxico,''),NVL(iSumCantidad,0);
				END IF; 

			END FOREACH	
		END IF;
	END;
END PROCEDURE
DOCUMENT
'Fecha: 25/03/2015',
'Folio :1706',
'Proyecto: BilletesFalsosEnOFI',
'Descripcion: Se modifica el aplicativo de generepo para agregar el llamado de los reportes B23 Captura de billetes falsos diario y B24 captura de billetes falsos', 'historico. Ademas de modificar el reporte de la tira auditora para que se reflejen los movimientos de las transacciones 51 Pago de billete autentico en efectivo',
'y 52 Pago de billete autentico abono a cuenta.',
'Autor: 95358897-Isarai Bojorquez',
'Modifico: Leslie RendÃ³n',
'Folio: 1725',
'Proyecto: OptBilletesFalsosEnOfi',
'DescripciÃ³n: Se modifica sp para indexar consultas y se corrige reporte por rango de fechas y reporte diario',
'Fecha: 21/05/2015';

CREATE PROCEDURE "informix".sp_consultapiezas_bym(pNumRecibo CHAR(10))
RETURNING CHAR(6) AS cCodRet,INTEGER AS iImporteFinal;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE iImporte INTEGER;
DEFINE iImporteFinal INTEGER;
--INICIALIZACION DE VARIABLES 
LET cCodRet	= "000000";
LET iSqlErr = 0;
LET iImporte=0;
LET iImporteFinal=0;

	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultapiezas_bym.out';
	--TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN  cCodRet,iImporte;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pNumRecibo,''))='' THEN
			LET cCodRet = '000001'; --ParÃ¡metros de entrada vacÃ­os
		ELSE
			IF(SELECT COUNT(num_recibo) FROM bdisuc:"informix".ss_piezas_bym_falsos WHERE num_recibo=pNumRecibo)>0 THEN
				FOREACH
				
					SELECT (NVL(pzs.num_piezas,0) * NVL(denom.denominacion,0)) 
					INTO iImporte
					FROM bdisuc:"informix".ss_piezas_bym_falsos pzs INNER JOIN bdisuc:"informix".ss_denominacion_bym_falsos denom ON denom.id_denominacion = pzs.id_denominacion
					WHERE num_recibo=TRIM(NVL(pNumRecibo,''))
					AND pzs.estatus= 3
					AND pzs.dictamen_banxico= 1
					AND pzs.empresa=denom.empresa
					
					LET iImporteFinal = iImporte + iImporteFinal ;
					
				END FOREACH;
			ELSE
				LET cCodRet = '000002'; --No se encontraron registros
			END IF;
			IF iImporteFinal = 0 THEN						
				LET cCodRet = '000003'; --No se encontraron registros
			END IF;
		END IF;
	
	RETURN  cCodRet,iImporteFinal;
END;
END PROCEDURE
DOCUMENT
"DescripciÃ³n: Consulta de importe a pagar de elementos dictaminados como autÃ©nticos.",
"Autor : Leslie RendÃ³n",
"FECHA : 06/03/2015",
"BD    : bdisuc";

CREATE PROCEDURE "informix".sp_actualizapieza_bym(pOpcion CHAR(1), pNumRecibo CHAR(10), pEstatus INTEGER, pTipoPago INTEGER, pNumCuenta CHAR(11), pEjecutivo CHAR(8))
RETURNING CHAR(6) AS cCodRet;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE iSqlErr INTEGER;

--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET iSqlErr = 0;

	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_actualizapieza_bym.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		-- pOpcion = 1 ---> Actualizacion de datos en Caja
		-- pOpcion = 2 ---> Reversion de los datos en Reversio
		-- pTipoPago = 1 --> Pago en Efectivo
		-- pTipoPago = 2 --> Pago en Abono a Cuenta de Captación
		IF TRIM(NVL(pOpcion,''))=1 OR TRIM(NVL(pOpcion,''))=2 THEN
			IF TRIM(NVL(pOpcion,''))=1 THEN
				IF TRIM(NVL(pNumRecibo,''))<>'' AND  NVL(pEstatus,0)>0 AND NVL(pTipoPago,0)>0 AND TRIM(NVL(pEjecutivo,''))<>'' THEN
					IF NVL(pTipoPago,0)=2 THEN
						IF TRIM(NVL(pNumCuenta,''))='' THEN
							LET cCodret = '000001';
							RETURN cCodRet;
						END IF;
					END IF;
						IF (SELECT COUNT(num_recibo) FROM bdisuc:"informix".ss_piezas_bym_falsos WHERE num_recibo=TRIM(NVL(pNumRecibo,'')))>0 THEN
							UPDATE bdisuc:"informix".ss_piezas_bym_falsos
							SET fecha_pago=CURRENT, tipo_pago=NVL(pTipoPago,0), num_cta_cliente=TRIM(NVL(pNumCuenta,'')), 
								estatus=NVL(pEstatus,0), ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
							WHERE num_recibo=TRIM(NVL(pNumRecibo,''))
							AND estatus= 3
							AND dictamen_banxico= 1;
							
							RETURN cCodRet;
						ELSE
							LET cCodret = '000002';
							RETURN cCodRet;
						END IF;
				
				ELSE
					LET cCodret = '000001';
					RETURN cCodRet;
				END IF;
			ELIF TRIM(NVL(pOpcion,''))=2 THEN
				IF TRIM(NVL(pNumRecibo,''))<>'' AND  NVL(pEstatus,0)>0 AND TRIM(NVL(pEjecutivo,''))<>'' THEN
							UPDATE bdisuc:"informix".ss_piezas_bym_falsos
							SET fecha_pago='', tipo_pago='', num_cta_cliente='', 
								estatus=NVL(pEstatus,0), ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
							WHERE num_recibo=TRIM(NVL(pNumRecibo,''))
							AND estatus=4
							AND dictamen_banxico= 1;
							
							RETURN cCodRet;
				ELSE
					LET cCodret = '000001';
					RETURN cCodRet;
				END IF;
			END IF;
		ELSE
			LET cCodret = '000001';
			RETURN cCodRet;
		END IF;


END
END PROCEDURE
DOCUMENT
"Descripción: Actualizá los campos de la tabla ss_piezas_bym_falsos en caja y reversio",
"Autor : Leslie Rendón",
"FECHA : 09/03/2015",
"BD    : bdisuc";

CREATE PROCEDURE "informix".sp_consultacat_estatus_bym(pOpcion CHAR(1), pDato INTEGER)
RETURNING CHAR(6) AS cCodRet,CHAR(80) AS cMensaje,INTEGER AS iCveEstatus,CHAR(20) AS cDescripcion;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cMensaje CHAR(80);
DEFINE cDescripcion CHAR(20);
DEFINE iCveEstatus INTEGER;
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET cMensaje ="Ejecución Exitosa";
LET iSqlErr = 0;
LET cDescripcion="";
LET iCveEstatus=0;
--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacat_estatus_bym.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet,cMensaje,iCveEstatus,cDescripcion;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret	= "000001";
			LET cMensaje ="Parámetros de Entrada Vacíos";
			RETURN cCodRet,cMensaje,iCveEstatus,cDescripcion;
		ELSE
			IF TRIM(NVL(pOpcion,''))='1' OR  TRIM(NVL(pOpcion,''))='2' THEN
				IF TRIM(NVL(pOpcion,''))='1' THEN
					FOREACH
						SELECT id_estatus, desc_estatus 
						INTO iCveEstatus, cDescripcion
						FROM bdisuc:"informix".ss_cat_estatus_bym_falsos
						WHERE empresa = '001'
						
						RETURN cCodRet,cMensaje,iCveEstatus,cDescripcion WITH RESUME;
					END FOREACH;
				ELIF TRIM(NVL(pOpcion,''))='2' THEN
					IF NVL(pDato,0)>0 THEN
						FOREACH
							SELECT id_estatus, desc_estatus 
							INTO iCveEstatus, cDescripcion
							FROM bdisuc:"informix".ss_cat_estatus_bym_falsos
							WHERE empresa = '001' 
							AND id_estatus=pDato
							
							RETURN cCodRet,cMensaje,iCveEstatus,cDescripcion WITH RESUME;
						END FOREACH;
					ELSE
						LET cCodret	= "000001";
						LET cMensaje ="Parámetros de Entrada Vacíos";
						RETURN cCodRet,cMensaje,iCveEstatus,cDescripcion WITH RESUME;
					END IF
				END IF
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret	= "000002";
					SELECT descripcion
					INTO cMensaje
					FROM bdinteg:"informix".si_codret
					WHERE codigo_retorno='256'
					AND sistema='11';
					
					RETURN cCodRet,cMensaje,iCveEstatus,cDescripcion;
				END IF
			ELSE
				LET cCodret	= "000003";
				LET cMensaje ="Número de opción incorrecto.";
				RETURN cCodRet,cMensaje,iCveEstatus,cDescripcion;
			END IF
		END IF
		
END;    
END PROCEDURE
DOCUMENT
'REALIZO: Leslie Rendón',
'FECHA: 09/03/2015',
'DESCRIPCION: Se consultan los datos del catálogo ss_cat_estatus_bym_falsos',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consutacat_dictamen_bym(pOpcion CHAR(1), pDato INTEGER)
RETURNING CHAR(6) AS cCodRet,CHAR(80) AS cMensaje,INTEGER AS iCveDictamen,CHAR(20) AS cDescripcion;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cMensaje CHAR(80);
DEFINE iCveDictamen INTEGER;
DEFINE cDescripcion CHAR(20);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET cMensaje ="Ejecución Exitosa";
LET iSqlErr = 0;
LET iCveDictamen=0;
LET cDescripcion="";
--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacat_dictamen_bym.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet,cMensaje,iCveDictamen,cDescripcion;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret	= "000001";
			LET cMensaje ="Parámetros de Entrada Vacíos";
			RETURN cCodRet,cMensaje,iCveDictamen,cDescripcion;
		ELSE
			IF TRIM(NVL(pOpcion,''))='1' OR  TRIM(NVL(pOpcion,''))='2' THEN
				IF TRIM(NVL(pOpcion,''))='1' THEN
					FOREACH
						SELECT id_dictamen, desc_dictamen 
						INTO iCveDictamen, cDescripcion
						FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
						WHERE Empresa = '001'
						
						RETURN cCodRet,cMensaje,iCveDictamen,cDescripcion WITH RESUME;
					END FOREACH;
				ELIF TRIM(NVL(pOpcion,''))='2' THEN
					IF NVL(pDato,0)>0 THEN
						FOREACH
							SELECT id_dictamen, desc_dictamen 
							INTO iCveDictamen, cDescripcion
							FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
							WHERE Empresa = '001'
							AND id_dictamen = pDato
							
							RETURN cCodRet,cMensaje,iCveDictamen,cDescripcion WITH RESUME;
						END FOREACH;
					ELSE
						LET cCodret	= "000001";
						LET cMensaje ="Parámetros de Entrada Vacíos";
						RETURN cCodRet,cMensaje,iCveDictamen,cDescripcion;
					END IF
				END IF
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret	= "000002";
					SELECT descripcion
					INTO cMensaje
					FROM bdinteg:"informix".si_codret
					WHERE codigo_retorno='256'
					AND sistema='11';
					
					RETURN cCodRet,cMensaje,iCveDictamen,cDescripcion;
				END IF
			ELSE
				LET cCodret	= "000003";
				LET cMensaje ="Número de opción incorrecto.";
				RETURN cCodRet,cMensaje,iCveDictamen,cDescripcion;
			END IF
		END IF
		
END;    
END PROCEDURE
DOCUMENT
'REALIZO: Leslie Rendón',
'FECHA: 09/03/2015',
'DESCRIPCION: Se consultan los datos del catálogo ss_cat_dictamen_bym_falsos',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_sel_sdohistorico2( pEmpresa CHAR(3), ptipo SMALLINT, pccmayor CHAR(4), pccsub CHAR(2), pccsubsub CHAR(2), pccssubsub CHAR(2), pccsssubsub CHAR(2), psector CHAR(2), pFechaIni DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER )
RETURNING VARCHAR(5), 
                  CHAR(4), 
              VARCHAR(40),
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2), 
                  MONEY(14,2),
                  MONEY(14,2)
        --Variables Exception
        DEFINE cVarDataErr                                                      VARCHAR(64);
        DEFINE iSqlErr                                                          INTEGER;
        DEFINE iSamErr                                                          INTEGER;
        DEFINE vCodret                                                          CHAR(5);
        DEFINE vfecha_hoy  DATE;
        DEFINE vsucursal   CHAR(4);
        DEFINE vnombre     VARCHAR(40);
        DEFINE vdia_1      MONEY(14,2);
        DEFINE vdia_2      MONEY(14,2);
        DEFINE vdia_3      MONEY(14,2);
        DEFINE vdia_4      MONEY(14,2);
        DEFINE vdia_5      MONEY(14,2);
        DEFINE vdia_6      MONEY(14,2);
        DEFINE vdia_7      MONEY(14,2);
        DEFINE vdia_8      MONEY(14,2);
        DEFINE vdia_9      MONEY(14,2);
        DEFINE vdia_10     MONEY(14,2);
        DEFINE vdia_11     MONEY(14,2);
        DEFINE vdia_12     MONEY(14,2);
        DEFINE vdia_13     MONEY(14,2);
        DEFINE vdia_14     MONEY(14,2);
        DEFINE vdia_15     MONEY(14,2);
        DEFINE vdia_16     MONEY(14,2);
        DEFINE vdia_17     MONEY(14,2);
        DEFINE vdia_18     MONEY(14,2);
        DEFINE vdia_19     MONEY(14,2);
        DEFINE vdia_20     MONEY(14,2);
        DEFINE vdia_21     MONEY(14,2);
        DEFINE vdia_22     MONEY(14,2);
        DEFINE vdia_23     MONEY(14,2);
        DEFINE vdia_24     MONEY(14,2);
        DEFINE vdia_25     MONEY(14,2);
        DEFINE vdia_26     MONEY(14,2);
        DEFINE vdia_27     MONEY(14,2);
        DEFINE vdia_28     MONEY(14,2);
        DEFINE vdia_29     MONEY(14,2);
        DEFINE vdia_30     MONEY(14,2);
        DEFINE vdia_31     MONEY(14,2);
    --Manejo del error
                ON EXCEPTION
                        SET iSqlErr, iSamErr, cVarDataErr
                        IF iSqlErr <> 0 THEN
                                LET vCodret=iSqlErr;
                                RETURN vCodret, vsucursal, iSamErr || ' ' ||cVarDataErr,
                                           vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                           vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,                
                                           vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,             
                                           vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                           vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31 ;   
                        END IF;
                END EXCEPTION;
    --set debug file to "/tmp/sp_sel_sdohistorico2.out";
    --trace on;
        SET LOCK MODE TO WAIT 4;
        SET ISOLATION TO DIRTY READ;
        LET vCodRet = '000';
        LET vsucursal = '';
        LET vnombre = ''; 
        LET vdia_1  = 0.0;  
        LET vdia_2  = 0.0;    
        LET vdia_3  = 0.0;    
        LET vdia_4  = 0.0;    
        LET vdia_5  = 0.0;    
        LET vdia_6  = 0.0;    
        LET vdia_7  = 0.0;    
        LET vdia_8  = 0.0;    
        LET vdia_9  = 0.0;    
        LET vdia_10 = 0.0;    
        LET vdia_11 = 0.0;    
        LET vdia_12 = 0.0;    
        LET vdia_13 = 0.0;    
        LET vdia_14 = 0.0;    
        LET vdia_15 = 0.0;    
        LET vdia_16 = 0.0;    
        LET vdia_17 = 0.0;    
        LET vdia_18 = 0.0;    
        LET vdia_19 = 0.0;    
        LET vdia_20 = 0.0;    
        LET vdia_21 = 0.0;    
        LET vdia_22 = 0.0;    
        LET vdia_23 = 0.0;    
        LET vdia_24 = 0.0;    
        LET vdia_25 = 0.0;    
        LET vdia_26 = 0.0;    
        LET vdia_27 = 0.0;    
        LET vdia_28 = 0.0;    
        LET vdia_29 = 0.0;    
        LET vdia_30 = 0.0;    
        LET vdia_31 = 0.0;   
        IF ptipo = 0 THEN
                SELECT fecha_hoy 
                  INTO vfecha_hoy 
              FROM bdicont:co_fechas;
                IF MONTH(pFechaIni) = MONTH(vfecha_hoy)  AND  MONTH(pFechaFin) = MONTH(vfecha_hoy) THEN
                        FOREACH
                                SELECT SKIP pRegistros FIRST pRecuperacion s.sucursal,
                                           u.nombre,
                                       SUM(CASE WHEN DAY(mes_dia) = 1 THEN saldo_fin_de_dia ELSE 0 END) AS dia_1, 
                                       SUM(CASE WHEN DAY(mes_dia) = 2 THEN saldo_fin_de_dia ELSE 0 END) AS dia_2,
                                       SUM(CASE WHEN DAY(mes_dia) = 3 THEN saldo_fin_de_dia ELSE 0 END) AS dia_3,
                                       SUM(CASE WHEN DAY(mes_dia) = 4 THEN saldo_fin_de_dia ELSE 0 END) AS dia_4,
                                       SUM(CASE WHEN DAY(mes_dia) = 5 THEN saldo_fin_de_dia ELSE 0 END) AS dia_5,
                                       SUM(CASE WHEN DAY(mes_dia) = 6 THEN saldo_fin_de_dia ELSE 0 END) AS dia_6,
                                       SUM(CASE WHEN DAY(mes_dia) = 7 THEN saldo_fin_de_dia ELSE 0 END) AS dia_7,
                                       SUM(CASE WHEN DAY(mes_dia) = 8 THEN saldo_fin_de_dia ELSE 0 END) AS dia_8,
                                       SUM(CASE WHEN DAY(mes_dia) = 9 THEN saldo_fin_de_dia ELSE 0 END) AS dia_9,
                                       SUM(CASE WHEN DAY(mes_dia) = 10 THEN saldo_fin_de_dia ELSE 0 END) AS dia_10,
                                       SUM(CASE WHEN DAY(mes_dia) = 11 THEN saldo_fin_de_dia ELSE 0 END) AS dia_11,
                                       SUM(CASE WHEN DAY(mes_dia) = 12 THEN saldo_fin_de_dia ELSE 0 END) AS dia_12,
                                       SUM(CASE WHEN DAY(mes_dia) = 13 THEN saldo_fin_de_dia ELSE 0 END) AS dia_13,
                                       SUM(CASE WHEN DAY(mes_dia) = 14 THEN saldo_fin_de_dia ELSE 0 END) AS dia_14,
                                       SUM(CASE WHEN DAY(mes_dia) = 15 THEN saldo_fin_de_dia ELSE 0 END) AS dia_15,
                                       SUM(CASE WHEN DAY(mes_dia) = 16 THEN saldo_fin_de_dia ELSE 0 END) AS dia_16,
                                       SUM(CASE WHEN DAY(mes_dia) = 17 THEN saldo_fin_de_dia ELSE 0 END) AS dia_17,
                                       SUM(CASE WHEN DAY(mes_dia) = 18 THEN saldo_fin_de_dia ELSE 0 END) AS dia_18,
                                       SUM(CASE WHEN DAY(mes_dia) = 19 THEN saldo_fin_de_dia ELSE 0 END) AS dia_19,
                                       SUM(CASE WHEN DAY(mes_dia) = 20 THEN saldo_fin_de_dia ELSE 0 END) AS dia_20,
                                       SUM(CASE WHEN DAY(mes_dia) = 21 THEN saldo_fin_de_dia ELSE 0 END) AS dia_21,
                                       SUM(CASE WHEN DAY(mes_dia) = 22 THEN saldo_fin_de_dia ELSE 0 END) AS dia_22,
                                       SUM(CASE WHEN DAY(mes_dia) = 23 THEN saldo_fin_de_dia ELSE 0 END) AS dia_23,
                                       SUM(CASE WHEN DAY(mes_dia) = 24 THEN saldo_fin_de_dia ELSE 0 END) AS dia_24,
                                       SUM(CASE WHEN DAY(mes_dia) = 25 THEN saldo_fin_de_dia ELSE 0 END) AS dia_25,
                                       SUM(CASE WHEN DAY(mes_dia) = 26 THEN saldo_fin_de_dia ELSE 0 END) AS dia_26,
                                       SUM(CASE WHEN DAY(mes_dia) = 27 THEN saldo_fin_de_dia ELSE 0 END) AS dia_27,
                                       SUM(CASE WHEN DAY(mes_dia) = 28 THEN saldo_fin_de_dia ELSE 0 END) AS dia_28,
                                       SUM(CASE WHEN DAY(mes_dia) = 29 THEN saldo_fin_de_dia ELSE 0 END) AS dia_29,
                                       SUM(CASE WHEN DAY(mes_dia) = 30 THEN saldo_fin_de_dia ELSE 0 END) AS dia_30,
                                       SUM(CASE WHEN DAY(mes_dia) = 31 THEN saldo_fin_de_dia ELSE 0 END) AS dia_31
                                  INTO vsucursal,vnombre,
                                           vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                           vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                           vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                           vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                       vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31
                                  FROM bdicont:co_sdodias s, bdinteg:si_sucursales u 
                                 WHERE s.empresa= pEmpresa
                                   AND s.mes_dia BETWEEN pFechaIni and pFechaFin
                                   AND s.ccmayor    = pccmayor
                                   AND s.ccsub      = pccsub
                                   AND s.ccsubsub   = pccsubsub
                                   AND s.ccssubsub  = pccssubsub
                                   AND s.ccsssubsub = pccsssubsub
                                   AND s.sector     = psector
                                   AND u.sucursal = s.sucursal
                                   AND u.empresa =s.empresa
                                 GROUP BY s.sucursal,u.nombre
                             ORDER BY s.sucursal ASC
                         RETURN vCodRet,vsucursal,vnombre,
                                                vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                                vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                                vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                                vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                            vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31 WITH RESUME;
                END FOREACH;
                ELSE
                        FOREACH
                                SELECT SKIP pRegistros FIRST pRecuperacion h.sucursal,
                                           u.nombre,
                                       SUM(CASE WHEN DAY(mes_dia) = 1 THEN saldo_fin_de_dia ELSE 0 END) AS dia_1, 
                                       SUM(CASE WHEN DAY(mes_dia) = 2 THEN saldo_fin_de_dia ELSE 0 END) AS dia_2,
                                       SUM(CASE WHEN DAY(mes_dia) = 3 THEN saldo_fin_de_dia ELSE 0 END) AS dia_3,
                                       SUM(CASE WHEN DAY(mes_dia) = 4 THEN saldo_fin_de_dia ELSE 0 END) AS dia_4,
                                       SUM(CASE WHEN DAY(mes_dia) = 5 THEN saldo_fin_de_dia ELSE 0 END) AS dia_5,
                                       SUM(CASE WHEN DAY(mes_dia) = 6 THEN saldo_fin_de_dia ELSE 0 END) AS dia_6,
                                       SUM(CASE WHEN DAY(mes_dia) = 7 THEN saldo_fin_de_dia ELSE 0 END) AS dia_7,
                                       SUM(CASE WHEN DAY(mes_dia) = 8 THEN saldo_fin_de_dia ELSE 0 END) AS dia_8,
                                       SUM(CASE WHEN DAY(mes_dia) = 9 THEN saldo_fin_de_dia ELSE 0 END) AS dia_9,
                                       SUM(CASE WHEN DAY(mes_dia) = 10 THEN saldo_fin_de_dia ELSE 0 END) AS dia_10,
                                       SUM(CASE WHEN DAY(mes_dia) = 11 THEN saldo_fin_de_dia ELSE 0 END) AS dia_11,
                                       SUM(CASE WHEN DAY(mes_dia) = 12 THEN saldo_fin_de_dia ELSE 0 END) AS dia_12,
                                       SUM(CASE WHEN DAY(mes_dia) = 13 THEN saldo_fin_de_dia ELSE 0 END) AS dia_13,
                                       SUM(CASE WHEN DAY(mes_dia) = 14 THEN saldo_fin_de_dia ELSE 0 END) AS dia_14,
                                       SUM(CASE WHEN DAY(mes_dia) = 15 THEN saldo_fin_de_dia ELSE 0 END) AS dia_15,
                                       SUM(CASE WHEN DAY(mes_dia) = 16 THEN saldo_fin_de_dia ELSE 0 END) AS dia_16,
                                       SUM(CASE WHEN DAY(mes_dia) = 17 THEN saldo_fin_de_dia ELSE 0 END) AS dia_17,
                                       SUM(CASE WHEN DAY(mes_dia) = 18 THEN saldo_fin_de_dia ELSE 0 END) AS dia_18,
                                       SUM(CASE WHEN DAY(mes_dia) = 19 THEN saldo_fin_de_dia ELSE 0 END) AS dia_19,
                                       SUM(CASE WHEN DAY(mes_dia) = 20 THEN saldo_fin_de_dia ELSE 0 END) AS dia_20,
                                       SUM(CASE WHEN DAY(mes_dia) = 21 THEN saldo_fin_de_dia ELSE 0 END) AS dia_21,
                                       SUM(CASE WHEN DAY(mes_dia) = 22 THEN saldo_fin_de_dia ELSE 0 END) AS dia_22,
                                       SUM(CASE WHEN DAY(mes_dia) = 23 THEN saldo_fin_de_dia ELSE 0 END) AS dia_23,
                                       SUM(CASE WHEN DAY(mes_dia) = 24 THEN saldo_fin_de_dia ELSE 0 END) AS dia_24,
                                       SUM(CASE WHEN DAY(mes_dia) = 25 THEN saldo_fin_de_dia ELSE 0 END) AS dia_25,
                                       SUM(CASE WHEN DAY(mes_dia) = 26 THEN saldo_fin_de_dia ELSE 0 END) AS dia_26,
                                       SUM(CASE WHEN DAY(mes_dia) = 27 THEN saldo_fin_de_dia ELSE 0 END) AS dia_27,
                                       SUM(CASE WHEN DAY(mes_dia) = 28 THEN saldo_fin_de_dia ELSE 0 END) AS dia_28,
                                       SUM(CASE WHEN DAY(mes_dia) = 29 THEN saldo_fin_de_dia ELSE 0 END) AS dia_29,
                                       SUM(CASE WHEN DAY(mes_dia) = 30 THEN saldo_fin_de_dia ELSE 0 END) AS dia_30,
                                       SUM(CASE WHEN DAY(mes_dia) = 31 THEN saldo_fin_de_dia ELSE 0 END) AS dia_31
                                  INTO vsucursal,vnombre,
                                           vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                           vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                           vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                           vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                       vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31
                                FROM bdicont:co_histsdodias h, bdinteg:si_sucursales u 
                           WHERE h.empresa = pEmpresa
                             AND h.mes_dia between pFechaIni and pFechaFin
                                 AND h.ccmayor    = pccmayor
                                 AND h.ccsub      = pccsub
                                 AND h.ccsubsub   = pccsubsub
                                 AND h.ccssubsub  = pccssubsub
                                 AND h.ccsssubsub = pccsssubsub
                                 AND h.sector     = psector
                                 AND u.sucursal = h.sucursal
                                 AND u.empresa =h.empresa
                                GROUP BY h.sucursal,u.nombre
                            ORDER BY h.sucursal ASC
                     RETURN vCodRet,vsucursal,vnombre,
                                    vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                            vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                            vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                            vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                        vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31 WITH RESUME;
                END FOREACH;
                END IF
        ELIF ptipo = 1 THEN
                FOREACH
                        SELECT SKIP pRegistros FIRST pRecuperacion s.sucursal,
                                   u.nombre,
                               SUM(CASE WHEN DAY(fecha) = 1 THEN saldo_total ELSE 0 END) AS dia_1,
                               SUM(CASE WHEN DAY(fecha) = 2 THEN saldo_total ELSE 0 END) AS dia_2,
                               SUM(CASE WHEN DAY(fecha) = 3 THEN saldo_total ELSE 0 END) AS dia_3,
                               SUM(CASE WHEN DAY(fecha) = 4 THEN saldo_total ELSE 0 END) AS dia_4,
                               SUM(CASE WHEN DAY(fecha) = 5 THEN saldo_total ELSE 0 END) AS dia_5,
                               SUM(CASE WHEN DAY(fecha) = 6 THEN saldo_total ELSE 0 END) AS dia_6,
                               SUM(CASE WHEN DAY(fecha) = 7 THEN saldo_total ELSE 0 END) AS dia_7,
                               SUM(CASE WHEN DAY(fecha) = 8 THEN saldo_total ELSE 0 END) AS dia_8,
                               SUM(CASE WHEN DAY(fecha) = 9 THEN saldo_total ELSE 0 END) AS dia_9,
                               SUM(CASE WHEN DAY(fecha) = 10 THEN saldo_total ELSE 0 END) AS dia_10,
                               SUM(CASE WHEN DAY(fecha) = 11 THEN saldo_total ELSE 0 END) AS dia_11,
                               SUM(CASE WHEN DAY(fecha) = 12 THEN saldo_total ELSE 0 END) AS dia_12,
                               SUM(CASE WHEN DAY(fecha) = 13 THEN saldo_total ELSE 0 END) AS dia_13,
                               SUM(CASE WHEN DAY(fecha) = 14 THEN saldo_total ELSE 0 END) AS dia_14,
                               SUM(CASE WHEN DAY(fecha) = 15 THEN saldo_total ELSE 0 END) AS dia_15,
                               SUM(CASE WHEN DAY(fecha) = 16 THEN saldo_total ELSE 0 END) AS dia_16,
                               SUM(CASE WHEN DAY(fecha) = 17 THEN saldo_total ELSE 0 END) AS dia_17,
                               SUM(CASE WHEN DAY(fecha) = 18 THEN saldo_total ELSE 0 END) AS dia_18,
                               SUM(CASE WHEN DAY(fecha) = 19 THEN saldo_total ELSE 0 END) AS dia_19,
                               SUM(CASE WHEN DAY(fecha) = 20 THEN saldo_total ELSE 0 END) AS dia_20,
                               SUM(CASE WHEN DAY(fecha) = 21 THEN saldo_total ELSE 0 END) AS dia_21,
                               SUM(CASE WHEN DAY(fecha) = 22 THEN saldo_total ELSE 0 END) AS dia_22,
                               SUM(CASE WHEN DAY(fecha) = 23 THEN saldo_total ELSE 0 END) AS dia_23,
                               SUM(CASE WHEN DAY(fecha) = 24 THEN saldo_total ELSE 0 END) AS dia_24,
                               SUM(CASE WHEN DAY(fecha) = 25 THEN saldo_total ELSE 0 END) AS dia_25,
                               SUM(CASE WHEN DAY(fecha) = 26 THEN saldo_total ELSE 0 END) AS dia_26,
                               SUM(CASE WHEN DAY(fecha) = 27 THEN saldo_total ELSE 0 END) AS dia_27,
                               SUM(CASE WHEN DAY(fecha) = 28 THEN saldo_total ELSE 0 END) AS dia_28,
                               SUM(CASE WHEN DAY(fecha) = 29 THEN saldo_total ELSE 0 END) AS dia_29,
                               SUM(CASE WHEN DAY(fecha) = 30 THEN saldo_total ELSE 0 END) AS dia_30,
                               SUM(CASE WHEN DAY(fecha) = 31 THEN saldo_total ELSE 0 END) AS dia_31
                          INTO vsucursal,vnombre,
                                   vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                   vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                   vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                   vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                   vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31
                           FROM bdisuc:ss_saldossuc s, bdinteg:si_sucursales u 
                          WHERE s.empresa = pEmpresa
                                AND s.sucursal IS NOT NULL
                                AND s.fecha BETWEEN pFechaIni AND pFechaFin
                                AND u.sucursal = s.sucursal
                                AND u.empresa = s.empresa
                      GROUP BY s.sucursal,u.nombre
                          ORDER BY s.sucursal ASC
                 RETURN vCodRet,vsucursal,vnombre,
                                        vdia_1,vdia_2,vdia_3,vdia_4,vdia_5,vdia_6, 
                                        vdia_7,vdia_8,vdia_9,vdia_10,vdia_11,vdia_12,
                                        vdia_13,vdia_14,vdia_15,vdia_16,vdia_17,vdia_18,
                                        vdia_19,vdia_20,vdia_21,vdia_22,vdia_23,vdia_24,
                                    vdia_25,vdia_26,vdia_27,vdia_28,vdia_29,vdia_30,vdia_31 WITH RESUME;
                END FOREACH;
        END IF
END PROCEDURE;