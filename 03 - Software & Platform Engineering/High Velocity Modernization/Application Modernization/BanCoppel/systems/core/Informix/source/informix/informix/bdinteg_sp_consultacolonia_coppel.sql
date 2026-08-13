CREATE PROCEDURE "informix".sp_consultacolonia_coppel(pEstado CHAR(2),pNumCiudad CHAR(3), pNumColonia INTEGER)
	RETURNING CHAR(6) AS codigo,
        CHAR(80) AS mensaje,
		CHAR(3)  AS idCiudad,
		CHAR(30) AS desCiudad,
		INTEGER AS codPostal,
		CHAR(1) AS unidadHabitacional;
		          
	DEFINE cCodRet CHAR(6); 
	DEFINE cMensajeRet CHAR(80);
	DEFINE iSqlErr INTEGER;
	DEFINE iIsamErr INTEGER;
	DEFINE cErrorInfo CHAR(80);
	DEFINE iCont INTEGER;
	DEFINE iColonia INTEGER; 
	DEFINE iCodigoPostal INTEGER; 
	DEFINE cNombre CHAR(32); 
	DEFINE cUniHab CHAR(1);
	
	LET iSqlErr = 0;
	LET iIsamErr = 0;
	LET cErrorInfo = '';
	LET cCodRet = '000000';
	LET cMensajeRet = 'Se realizÃ³ la consulta correctamente';
	LET iCont = 0;
	LET cNombre = '';
	LET iColonia = 0; 
	LET iCodigoPostal = 0; 
	LET cNombre = ''; 
	LET cUniHab = '';
 
	BEGIN
 
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet= cErrorInfo;
				RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultacolonia_coppel.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
  	  
		IF pEstado IS NULL OR pEstado = '' OR pNumCiudad IS NULL OR pNumCiudad = '' OR pNumColonia IS NULL THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'El parÃ¡metro numero de estado esta vaciÃ³';
			RETURN cCodRet, cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
		END IF;
		
		SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonass)}  z.numerocolonia,z.nombrezona,codigopostalzona, z.marcaunidadhabitacional
		INTO iColonia, cNombre, iCodigoPostal, cUniHab
		FROM bdinteg:si_catzonas z  
		INNER JOIN bdinteg: si_estados e ON ( e.estado=pEstado)    
		INNER JOIN bdinteg: si_ciudades c ON  c.estado=e.estado AND c.ciudad_coppel = pNumCiudad
		INNER JOIN bdinteg:si_catciudades cat ON (c.ciudad_coppel = cat.numerociudad)       
		WHERE z.numerociudad = c.ciudad_coppel     
		AND z.numerocolonia = pNumColonia
		AND NVL(z.nombrezona,'') <> '';
		
		LET iCont = dbinfo("sqlca.sqlerrd2");
		IF iCont = 0 THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'No se encontraron registros';
			RETURN cCodRet,cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
		END IF;
			
		RETURN cCodRet,cMensajeRet,iColonia,NVL(cNombre,''),NVL(iCodigoPostal,0), trim(cUniHab);
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 11/08/2020',
'DESCRIPCION: Se realiza procedimiento para obtener la descripcion de la colonia del cliente coppel',
'BD:bdinteg';

CREATE PROCEDURE "informix".sp_dicta_registrositespcte (	pCteNvo		CHAR(20),						--CLIENTE NUEVO
															pSitNvo     CHAR(1),						--SITUACION CTENUEVO
															pCausaNvo   SMALLINT,						--CAUSA CTENUEVO
															pCteMat     CHAR(20),						--CLIENTE MATCH
															pSitMat     CHAR(1),						--SITUACION CTEMATCH
															pCausaMat   SMALLINT,						--CAUSA CTE MATCH
															pOrigMat    CHAR(4),						--EMPRESA CON QUIEN SE HIZO MATCH EMPLEADOS, EXEMPLEADO, 
																										--COPPEL, BANCOPPEL 
															pSucursal   CHAR(4),						--DONDE SE ORIGINO LA ALERTA
															pOperador	CHAR(8),						--USUARIO
															pOrigen		CHAR(1),						--CENTRAL O SUCURSAL
															pActivo     SMALLINT,						--BANDERA SI ES EMPLEADO O EXEMPLEADO.
															pBandera    INTEGER, 						--1 MISMA PERSONA,2 DISTINTA PERSONA, 3 FRAUDE.
															
															pFechaDictaINI DATETIME YEAR TO SECOND,		--* FECHA DE INICIO DICTAMEN
															pFechaDictaFIN DATETIME YEAR TO SECOND,		--* FECHA DE FINALIZACION DICTAMEN
															--DATOS PARA CONSULTA A TABLA SI_HUELLA_LINEA_RESULTADO
															pNombreCoincidencia CHAR(104),				--* NOMBRE CTE MATCH
															pFechaNacimiento CHAR(10)					--* FECHA_NAC CTE MATCH
														)
RETURNING 	CHAR (6) 	AS Cod_Ret,				
			CHAR (100) 	AS Mensaje;
			
	-- DECLARACION DE VARIABLES --
	DEFINE cctlhresult              CHAR (6);
	DEFINE cCodRet           		CHAR (6);
	DEFINE cCodRet_val       		CHAR (6);
    DEFINE iSqlErr           		INTEGER;
    DEFINE cSitActual        		CHAR(1);	
    DEFINE sCausaActual      		SMALLINT;  
    DEFINE cMensaje          		CHAR(100);   
    DEFINE cNombre         			 CHAR(45);  
    DEFINE sParentesco       		SMALLINT;  
    DEFINE sTotalMatch       		SMALLINT;  
    DEFINE sMatch       	 		SMALLINT;  
    DEFINE sMatchDicta       		SMALLINT;  
    DEFINE sPondeAct         		SMALLINT;  
    DEFINE sPondeNvo         		SMALLINT;
    DEFINE csctlhresult        		SMALLINT;
    DEFINE cConfpos                 CHAR (2);
	DEFINE cCtesitesp               CHAR (2);
	DEFINE cTicket                   CHAR (20);
	
	--VAR. HIST
	DEFINE cNum_cte  				CHAR(20);  
    DEFINE cSuc		 				CHAR(4); 
    DEFINE cOper     				CHAR(8);
    DEFINE cEmpre    				CHAR(8);
	DEFINE cOrigen   				CHAR(1);
	DEFINE dtFechaDicINI			DATETIME YEAR TO SECOND; --*
	DEFINE dtFechaDicFIN			DATETIME YEAR TO SECOND; 
	DEFINE cNombreCoincidencia		CHAR(104);
	DEFINE cFechaNacimiento			CHAR(10); --*
  -----
    DEFINE cSucursal CHAR (4);
	DEFINE cFechaInsert DATETIME YEAR TO SECOND;
 
	-- INICILIZA VARIABLES --
	LET cCodRet  			= '000000';
	LET cCodRet_val			= '000000';
    LET iSqlErr  			= 0;
    LET cSitActual  		= '';
	--LET cctlhresult  		= '';
    LET sCausaActual		= 0;
    LET cMensaje	  		= 'El proceso de dictamen termino correctamente.';
    LET cNombre	  			= '';
    LET sParentesco	  		= 0;
    LET sTotalMatch	  		= 0;
    LET sMatch     	  		= 0;
    LET sMatchDicta	  		= 0;
    LET sPondeAct	  		= 0;
    LET sPondeNvo	  		= 0;
	LET cctlhresult  		= 0;
	LET cConfpos  		    = 0;
	LET cCtesitesp  		= 0;
	LET cTicket             ='';
	
	
	--VAR. HIST
	LET cNum_cte			= '';
	LET cSuc				= '';
	LET cOper				= '';
	LET cEmpre				= '';
	LET cOrigen				= '';
	LET dtFechaDicINI		= DATE(1); --*
	LET dtFechaDicFIN		= DATE(1);
	LET cNombreCoincidencia = '';
	LET cFechaNacimiento	= DATE(1); --*
	LET cSucursal = ''; 
	LET cFechaInsert = '';
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_dicta_registrositespcte.out';
	--TRACE ON;	
	BEGIN

   
   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = 'Error no controlado.';
				
				RETURN TRIM(cCodRet),TRIM(cMensaje);
			END IF;
		END EXCEPTION;
   
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VALIDACION DE PARAMETROS --
		IF NVL(pCteNvo,'')='' OR NVL(pSitNvo,'')='' OR NVL(pCausaNvo,0)=0 OR NVL(pCteMat,'')='' OR NVL(pOrigMat,'')='' OR NVL(pSucursal,'')='' OR NVL(pOperador,'') = '' OR NVL(pFechaDictaINI,'') = '' OR NVL(pFechaDictaFIN,'') = '' THEN --*
			LET cCodRet = '000001';
			LET cMensaje = 'Falta uno o mas parametros de entrada.';
			RETURN TRIM(cCodRet),TRIM(cMensaje);
		END IF;
		
		IF NVL(pBandera,0) NOT IN(1,2,3,4) OR NVL(pActivo,0) NOT IN (0,1) THEN
			LET cCodRet = '000002';
			LET cMensaje = 'Parametro BANDERA y/o ACTIVO incorrectos.';
			RETURN TRIM(cCodRet),TRIM(cMensaje);
		END IF;
		
		SELECT LIMIT 1 num_huellas, origen
		INTO sMatch, cOrigen
		FROM "informix".si_bitacora_comparaciones
		WHERE numcte = pCteNvo
		AND status_alerta not in ('3','4');
		
		SELECT COUNT (numcte)
		INTO sMatchDicta
		FROM "informix".si_bitacora_dictamenes
		WHERE numcte = pCteNvo;
		
		LET sTotalMatch = sMatch - sMatchDicta;
		
		IF sTotalMatch = 0 THEN
			LET cCodRet = '000003';
			LET cMensaje = 'Total de matches dictaminados.';
			
			RETURN TRIM(cCodRet),TRIM(cMensaje);
		END IF
		
		--Se descarta match misma persona cuando el match el con el mismo numero de cliente 22/07/2015
		IF pBandera = '1' AND  TRIM(pCteNvo) = TRIM(pCteMat) AND pOrigMat = '5' THEN 
			LET pBandera = '2';
		END IF;

		-- PROCEDIMIENTO PARA VALIDAR LAS PONDERACIONES
		EXECUTE PROCEDURE "informix".sp_dicta_validaponderacion_sitespcte(TRIM(pCteNvo),pSitNvo,pCausaNvo,TRIM(pCteMat),pSitMat,NVL(pCausaMat,0),pOrigMat,pActivo,pBandera,pSucursal,TRIM(pOperador))
		INTO cCodRet_val,cSitActual,sCausaActual,sParentesco;
			
		IF cCodRet_val::INTEGER NOT IN  (0,100) THEN
			LET cCodRet = TRIM(cCodRet_val);
			LET cMensaje = 'Error en validar la ponderacion.';
			
			RETURN TRIM(cCodRet),TRIM(cMensaje);
		ELIF cCodRet_val::INTEGER = 100 THEN
		
			LET cCodRet = TRIM(cCodRet_val);
			LET cMensaje = 'La informacion del cliente match presenta errores';
		END IF;
		
		--INSERTA EN LA TABLA SI_BITACORA_DICTAMENES LOS MATCH YA DICTAMINADOS.
		INSERT INTO "informix".si_bitacora_dictamenes (numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,tipo,sucursal,numemp,origen,fecha_insert, tipo_dictamen, fecha_dicta_ini, fecha_dicta_fin) --*
		VALUES (TRIM(pCteNvo),TRIM(cSitActual),sCausaActual,TRIM(pCteMat),TRIM(pSitMat),NVL(pCausaMat,0),TRIM(pOrigMat),TRIM(pSucursal),TRIM(pOperador),TRIM(pOrigen),CURRENT, pBandera, NVL(pFechaDictaINI,DATE(1)), NVL(pFechaDictaFIN,DATE(1))); --*
		
		-- ACTUALIZAMOS EL NOMBRE DEL CLIENTE CON EL QUE HIZO MATCH.
		SELECT (ticket) 
		INTO cTicket 
		FROM "informix".si_huella_linea
		WHERE numcte = pCteNvo;
		
		SELECT count(cliente) 
		INTO cctlhresult 
		FROM "informix".si_huella_linea_resultado 
		WHERE ticket = cTicket and empresa = pOrigMat and cliente = pCteMat;		
		
		IF nvl(cctlhresult,0) > 0 THEN
			
			--UPDATE "informix".si_huella_linea_resultado SET nombre = pNombreCoincidencia, fecha_nac = pFechaNacimiento, situacion = pSitMat, causa = pCausaMat WHERE  cliente = pCteMat; --*
			
			UPDATE {+INDEX  idx_huellalinea_resultado)}si_huella_linea_resultado  SET nombre = pNombreCoincidencia, fecha_nac = pFechaNacimiento, situacion = pSitMat, causa = pCausaMat WHERE  ticket = cTicket and empresa = pOrigMat and cliente = pCteMat; 
		else
		
			--UPDATE "informix".si_huella_linea_resultado_hist SET nombre = pNombreCoincidencia, fecha_nac = pFechaNacimiento, situacion = pSitMat, causa = pCausaMat WHERE  cliente = pCteMat --*
			UPDATE {+INDEX  idx_huellalinea_resulhist)}si_huella_linea_resultado_hist  SET nombre = pNombreCoincidencia, fecha_nac = pFechaNacimiento, situacion = pSitMat, causa = pCausaMat WHERE  ticket = cTicket and empresa = pOrigMat and cliente = pCteMat; 
		END IF;
		
		
				
		-- SI LA COMPARACION PROVIENE DE SUCURSAL SE VALIDARAN LAS SITUACIONES ALTERNAS.
		IF cOrigen::INTEGER = 3 THEN
			-- SE TRASPASA LA INFORMACION DEL CLIENTE A LA TABLA HISTORICA.			
			INSERT INTO bdisitesp: "informix".se_sitespctetmphis(empresa,numcte,situacion,causa,situacion_fin,causa_fin,sucursal,proceso_origen,operador,fecha,fechamovto)
			SELECT empresa, numcte, TRIM(cSitActual),sCausaActual, TRIM(pSitMat),NVL(pCausaMat,0), sucursal, cOrigen, operador, fecha,fechamovto
			FROM bdisitesp: "informix".se_sitespctetmp 
            WHERE numcte = pCteNvo;
			--ELIMINA LA INFORMACION DEL CLIENTE.			
			DELETE FROM bdisitesp:"informix".se_sitespctetmp
			WHERE  numcte = pCteNvo AND situacion = "U"
			AND causa = "61";			
		END IF;
		
		--INSERTA EN LA TABLA DE FALSO POSITIVO CUANDO ES DISTINTA PERSONA Y NO EXISTE PARENTESCO Y EL MATCH ES BANCOPPEL.
		IF pBandera = 2 AND sParentesco = 1 AND pOrigMat = '5' THEN
			
			SELECT count(numcte) 
			INTO cConfpos 
			FROM "informix".si_bitacora_falsopos 
			WHERE numcte=pCteNvo and numcte_coinc = pCteMat;
		
			IF nvl(cConfpos,0) = 0 THEN
			--IF NOT EXISTS(SELECT numcte FROM "informix".si_bitacora_falsopos WHERE numcte=pCteNvo and numcte_coinc = pCteMat) THEN
				INSERT INTO "informix".si_bitacora_falsopos (numcte,numcte_coinc,situacion,causa,empleado,fecha) 
				VALUES (TRIM(pCteNvo),TRIM(pCteMat),TRIM(pSitMat),pCausaMat,TRIM(pOperador),CURRENT);
			END IF;
		END IF;
		
		SELECT nombre 
		INTO cNombre 
		FROM "informix".si_ejecut 
		WHERE ejecutivo = TRIM(pOperador);
		
		
			SELECT count(numcte) 
			INTO cCtesitesp 
			FROM bdisitesp:"informix".se_ctessitespcte
			WHERE numcte = TRIM(pCteNvo);
		
		IF nvl(cCtesitesp,0) > 0 THEN
		--IF EXISTS (SELECT numcte FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte = TRIM(pCteNvo))THEN
			--OBTIENE PONDERACION CLIENTE NUEVO
			SELECT ponderacion
			INTO sPondeNvo
			FROM bdisitesp:"informix".se_catsitesp
			WHERE situacion = pSitNvo
			AND causa = pCausaNvo;
			
			--OBTIENE PONDERACION CLIENTE MATCH
			SELECT ponderacion
			INTO sPondeAct
			FROM bdisitesp:"informix".se_catsitesp
			WHERE situacion = cSitActual
			AND causa = sCausaActual;
			
			IF sPondeAct <= sPondeNvo THEN
				--ACTUALIZA SITUACION ESPECIAL EN LA TABLA BDISITESP:"INFORMIX".SE_CTESSITESPCTE 
				UPDATE bdisitesp:"informix".se_ctessitespcte SET situacion = cSitActual, causa = sCausaActual, empleadoefectuo = TRIM(pOperador) , nombreefectuo = TRIM(cNombre),fechamovto = CURRENT YEAR TO SECOND, usrmodifica= TRIM(pOperador), fchmodifica = CURRENT YEAR TO SECOND WHERE numcte = TRIM(pCteNvo);
			END IF;
		END IF;

		LET sMatchDicta = sMatchDicta + 1;
		LET sTotalMatch = sMatch - sMatchDicta;
		
		IF sTotalMatch = 0 AND pSitNvo  = 'U' AND pCausaNvo = 62 AND cSitActual = 'U' AND sCausaActual = 65 THEN
			UPDATE bdisitesp:"informix".se_ctessitespcte SET situacion = 'U', causa = 65, empleadoefectuo = TRIM(pOperador) , nombreefectuo = TRIM(cNombre),fechamovto = CURRENT YEAR TO SECOND, usrmodifica= TRIM(pOperador), fchmodifica = CURRENT YEAR TO SECOND WHERE numcte = TRIM(pCteNvo);
		END IF;
    
		--- Se obtiene la sucursal y fecha de inserción de la alerta
		--SELECT FIRST 1 TRIM(sucursal), fecha_insert::DATETIME YEAR TO DAY
		--INTO cSucursal, cFechaInsert
		--FROM bdinteg:"informix".si_bitacora_alerta_tmp				
		--WHERE numcte = pCteNvo;
    
		-- Se realiza actualización del estatus 3 "atendido"
		--UPDATE "informix".si_bitacora_alerta_tmp SET status_alerta = '3' WHERE numcte = TRIM(pCteNvo) AND sucursal = TRIM(cSucursal) AND fecha_insert::DATE =  cFechaInsert AND user_analista = TRIM(pOperador);
		--UPDATE "informix".si_bitacora_comparaciones SET status_alerta = '3' WHERE numcte = TRIM(pCteNvo) AND sucursal = TRIM(cSucursal) AND fecha_insert::DATE = cFechaInsert AND analista_fraudes = TRIM(pOperador);
   
		RETURN TRIM(cCodRet),TRIM(cMensaje);
	END;
END PROCEDURE
DOCUMENT
'Autor: Cristo Lugo',
'Fecha: 23/09/2015',
'Descripcion: Se limita la consulta de clientes para evitar error -284 cuando se presenten alertas duplicadas',
'Solicita: Manuel Osuna',
'BD: bdinteg',
'Autor: Johnattan Esquivel',
'Fecha: 08/06/2020',
'Descripcion: Se realiza ajuste a SPL para realizar actualizacion de estatus "3" a tabla si_bitacora_comparaciones',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtiene_entidad_job()
							
				RETURNING CHAR(5)     AS Cod_Retorno;
				
										
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE cNumCte 			CHAR(10);	
DEFINE cCad_Anv 		CHAR(2200);
DEFINE iCad_Anv 		INT;
DEFINE cCad_Entidad		CHAR(20);
DEFINE iCont			SMALLINT;
DEFINE iActualizados	INTEGER;
DEFINE iLugNacAct		INTEGER;
DEFINE dHoraInicio		DATETIME HOUR TO MINUTE;
DEFINE dCurrentTime		DATETIME HOUR TO MINUTE;
DEFINE dMaxTime			INTEGER;
--VARIABLES
DEFINE intervalo 		INTERVAL minute(9) TO MINUTE;
DEFINE cadena 			VARCHAR(12);
DEFINE entero 			INTEGER;
DEFINE dFechaBitIfe		datetime year to fraction(3);
DEFINE dFechaInicio		DATE;
DEFINE dFechaFin		DATE;
DEFINE dFechIniLugNac	DATE;
DEFINE dFechFinLugNac	DATE;
DEFINE bContinuaProc	BOOLEAN;
DEFINE bContinuaProcCurp	BOOLEAN;
DEFINE iMaxActualizar	INTEGER;
DEFINE dFechaAyer		DATETIME YEAR TO SECOND;
DEFINE iExistePf		SMALLINT;
DEFINE iMaxCommit		INTEGER;



--INICIALIZA VARIABLES
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	
LET cNumCte 			= '';	
LET cCad_Anv 	 		= '';
LET iCad_Anv 			= 0;
LET cCad_Entidad		= '';
LET iCont 				= 0;
LET iActualizados 		= 0;
LET iLugNacAct 			= 0;
LET dHoraInicio			= CURRENT hour to minute;
LET dCurrentTime		= NULL;
LET dMaxTime			= 90;
LET dFechaBitIfe		= NULL;
LET dFechaInicio		= NULL;
LET dFechaFin			= NULL;
LET dFechIniLugNac		= NULL;
LET dFechFinLugNac		= NULL;
LET bContinuaProc		= 't';
LET bContinuaProcCurp	= 't';
LET iMaxActualizar		= 200000;
LET dFechaAyer			= CAST(TODAY-2 AS DATETIME YEAR TO SECOND);
LET iExistePf			= 0;
LET iMaxCommit			= 500;


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_obtiene_entidad_job.out";
	--SET DEBUG FILE TO "/ifxsif01/jagl/bdinteg/sp_obtiene_entidad_job.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Se actualiza el campo CURP para los clientes tales que el dÃ­a de ayer se registro un registro en si_bitacora_ife
	LET iCont = 0;
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_ctepf), AVOID_FULL ("informix".si_bitacora_ife)}
		DISTINCT(a.numcte)
		INTO cNumCte
		FROM "informix".si_cliente a
		INNER JOIN "informix".si_ctepf pf ON pf.numcte=a.numcte
		INNER JOIN "informix".si_bitacora_ife btf ON btf.numcte=a.numcte
		WHERE 
		a.tipo_cliente=1
		AND a.tpo_persona='01'
		AND a.fecha_alta < TODAY-2
		AND (pf.curp IS NULL OR pf.curp = '' OR LENGTH(pf.curp) <> 18)
		AND btf.fecha >= dFechaAyer
		AND btf.cadena_anverso IS NOT NULL
		AND btf.cadena_anverso <> ''
		AND btf.cadena_anverso LIKE '%CURP: %'
		AND INSTR(SUBSTRING (btf.cadena_anverso FROM (CHARINDEX('CURP: ',btf.cadena_anverso)) + 6 FOR 18), ' ', 0) = 0
		
		--Se actualiza el campo CURP
		FOREACH WITH HOLD
			--SE OBTIENE LA CADENA DEL CLIENTE PARA EXTRAER EL ID_NUMBER
			SELECT	
			{+AVOID_FULL ("informix".si_bitacora_ife)}
			cadena_anverso, fecha
			INTO cCad_Anv, dFechaBitIfe
			FROM "informix".si_bitacora_ife
			WHERE numcte = cNumCte
			AND cadena_anverso IS NOT NULL
			AND cadena_anverso <> ''
			AND cadena_anverso LIKE '%CURP: %'
			AND INSTR(SUBSTRING (cadena_anverso FROM (CHARINDEX('CURP: ',cadena_anverso)) + 6 FOR 18), ' ', 0) = 0
			ORDER BY fecha DESC
			limit 1
					
			--SE EXTRAE EL CURP: Y SE ACORTA SOLO A OBTIENE LA ENTIDAD		
			LET cCad_Anv = TRIM(cCad_Anv);
			LET iCad_Anv = CHARINDEX('CURP: ',cCad_Anv);
			LET cCad_Entidad = SUBSTRING (cCad_Anv FROM iCad_Anv + 6 FOR 18);
			LET cCad_Entidad = TRIM(cCad_Entidad);
			
			IF LENGTH(cCad_Entidad) <> 18 THEN
				LET cCad_Entidad='';
				CONTINUE FOREACH;
			END IF;
			
			--SE VALIDA QUE NO TRAIGA ESPACIOS EN BLANCO, SI TRAE SE OMITE ESE REGISTRO
			IF CHARINDEX (' ', TRIM(cCad_Entidad)) >= 1 THEN
				LET cCad_Entidad='';
				CONTINUE FOREACH;
			END IF;
			
			--Se fuerza la terminaciÃ³n del segundo for each
			EXIT FOREACH;
		END FOREACH;
		
		IF cCad_Entidad IS NOT NULL AND cCad_Entidad <> '' THEN
			UPDATE "informix".si_ctepf 
			SET curp = cCad_Entidad
			WHERE numcte = cNumCte;
				
			UPDATE "informix".si_bitacora_ife 
			SET actualizado = '2'
			WHERE numcte = cNumCte
			AND fecha = dFechaBitIfe;
			
			LET cCad_Entidad='';

			LET iCont=iCont+2;
				
			IF iCont >= iMaxCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
			LET iActualizados=iActualizados+1;
		END IF;
	END FOREACH;
	COMMIT WORK;
	
	--Se actualiza el campo lugar de nacimiento para los clientes tales que el dÃ­a de ayer se registro un registro en si_bitacora_ife
	LET iCont = 0;
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_ctepf), AVOID_FULL ("informix".si_bitacora_ife)}
		DISTINCT(a.numcte)
		INTO cNumCte
		FROM "informix".si_cliente a
		INNER JOIN "informix".si_ctepf pf ON pf.numcte=a.numcte
		INNER JOIN "informix".si_bitacora_ife btf ON btf.numcte=a.numcte
		WHERE 
		a.tipo_cliente=1
		AND a.tpo_persona='01'
		AND a.fecha_alta < TODAY-2
		AND (pf.lugar_nac IS NULL OR pf.lugar_nac = '' OR pf.lugar_nac = '00')
		AND btf.fecha >= dFechaAyer
		AND btf.cadena_anverso IS NOT NULL
		AND btf.cadena_anverso <> ''
		AND (btf.cadena_anverso LIKE '%ID_NUMBER: %' OR btf.cadena_anverso LIKE '%ELECTOR_ID: %')
		
		--Se actualiza el campo lugar de nacimiento
		FOREACH WITH HOLD
			--SE OBTIENE LA CADENA DEL CLIENTE PARA EXTRAER EL ID_NUMBER
			SELECT	
			{+AVOID_FULL ("informix".si_bitacora_ife)}
			cadena_anverso, fecha
			INTO cCad_Anv, dFechaBitIfe
			FROM "informix".si_bitacora_ife
			WHERE numcte = cNumCte
			AND cadena_anverso IS NOT NULL
			AND cadena_anverso <> ''
			AND (cadena_anverso LIKE '%ID_NUMBER: %' OR cadena_anverso LIKE '%ELECTOR_ID: %')
			ORDER BY fecha DESC
					
			--SE EXTRAE EL ID_NUMBER Y SE ACORTA SOLO A OBTIENE LA ENTIDAD		
			LET cCad_Anv = TRIM(cCad_Anv);
			LET iCad_Anv = CHARINDEX('ID_NUMBER: ',cCad_Anv);
			LET cCad_Entidad = SUBSTRING (cCad_Anv FROM iCad_Anv + 11 FOR 14);
			
			--SE VALIDA QUE NO TRAIGA ESPACIOS EN BLANCO, SI TRAE SE OMITE ESE REGISTRO
			IF CHARINDEX (' ', TRIM(cCad_Entidad)) >= 1 THEN
			
				LET iCad_Anv = CHARINDEX('ELECTOR_ID: ',cCad_Anv);
				LET cCad_Entidad = SUBSTRING (cCad_Anv FROM iCad_Anv + 12 FOR 14);
				
				--SE VALIDA QUE NO TRAIGA ESPACIOS EN BLANCO, SI TRAE SE OMITE ESE REGISTRO	
				IF CHARINDEX (' ', TRIM(cCad_Entidad)) >= 1 THEN
					LET cCad_Entidad='';
					CONTINUE FOREACH;
				END IF;
			END IF;
			LET cCad_Entidad = SUBSTRING (cCad_Entidad FROM 13 FOR 2);
			--Se valida que el valor del lugar de nacimiento se encuentre enntre los valores 01,02,03.... 33
			IF cCad_Entidad NOT IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33')  THEN
				LET cCad_Entidad='';
				CONTINUE FOREACH;
			END IF;			
			--Se fuerza la terminaciÃ³n del segundo for each
			EXIT FOREACH;
		END FOREACH;
		
		IF cCad_Entidad IS NOT NULL AND cCad_Entidad <> '' THEN
			UPDATE "informix".si_ctepf 
			SET lugar_nac = cCad_Entidad
			WHERE numcte = cNumCte;
				
			UPDATE "informix".si_bitacora_ife 
			SET actualizado = '1'
			WHERE numcte = cNumCte
			AND fecha = dFechaBitIfe;
			
			LET cCad_Entidad='';

			LET iCont=iCont+2;
				
			IF iCont >= iMaxCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
			
			LET iLugNacAct=iLugNacAct+1;
		END IF;
	END FOREACH;
	COMMIT WORK;
	
	--Se obtiene el valor de la fecha de inicio para actualizar el campo curp
	SELECT 
	TO_DATE(valor, "%d/%m/%Y")
	INTO dFechaFin
	FROM "informix".si_param
	WHERE descripcion ='Fecha ini act curp SPL sp_obtiene_entidad_job'
	;


	LET iCont = 0;
	BEGIN WORK;
	WHILE (bContinuaProc AND bContinuaProcCurp) LOOP
	
		LET dFechaInicio = dFechaFin;
		LET dFechaFin = dFechaInicio + 30 UNITS DAY;
		
		IF (dFechaFin > TODAY) THEN
			LET dFechaFin =TODAY;
		END IF;

		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL ("informix".si_cliente)}
			a.numcte
			INTO cNumCte
			FROM "informix".si_cliente a
			WHERE 
			a.tipo_cliente=1
			AND a.fecha_alta BETWEEN dFechaInicio AND dFechaFin
			
			SELECT 
			{+AVOID_FULL ("informix".si_ctepf), AVOID_FULL ("informix".si_bitacora_ife)}
			count(1)
			INTO iExistePf
			FROM "informix".si_ctepf pf
			INNER JOIN "informix".si_bitacora_ife btf ON btf.numcte=pf.numcte
			WHERE pf.numcte = cNumCte
			AND (pf.curp IS NULL OR pf.curp = '' OR LENGTH(pf.curp) <> 18)
			AND btf.cadena_anverso IS NOT NULL
			AND btf.cadena_anverso <> ''
			AND btf.cadena_anverso LIKE '%CURP: %'
			AND INSTR(SUBSTRING (btf.cadena_anverso FROM (CHARINDEX('CURP: ',btf.cadena_anverso)) + 6 FOR 18), ' ', 0) = 0
			;
			
			IF (iExistePf IS NULL OR iExistePf=0 ) THEN
				CONTINUE FOREACH;
			END IF;

			--Se actualiza el campo CURP
			FOREACH WITH HOLD
				--SE OBTIENE LA CADENA DEL CLIENTE PARA EXTRAER EL ID_NUMBER
				SELECT	
				{+AVOID_FULL ("informix".si_bitacora_ife)}
				cadena_anverso, fecha
				INTO cCad_Anv, dFechaBitIfe
				FROM "informix".si_bitacora_ife
				WHERE numcte = cNumCte
				AND cadena_anverso IS NOT NULL
				AND cadena_anverso <> ''
				AND cadena_anverso LIKE '%CURP: %'
				AND INSTR(SUBSTRING (cadena_anverso FROM (CHARINDEX('CURP: ',cadena_anverso)) + 6 FOR 18), ' ', 0) = 0
				ORDER BY fecha DESC
				limit 1
						
				--SE EXTRAE EL CURP: Y SE ACORTA SOLO A OBTIENE LA ENTIDAD		
				LET cCad_Anv = TRIM(cCad_Anv);
				LET iCad_Anv = CHARINDEX('CURP: ',cCad_Anv);
				LET cCad_Entidad = SUBSTRING (cCad_Anv FROM iCad_Anv + 6 FOR 18);
				LET cCad_Entidad = TRIM(cCad_Entidad);
				
				IF LENGTH(cCad_Entidad) <> 18 THEN
					LET cCad_Entidad='';
					CONTINUE FOREACH;
				END IF;
				
				--SE VALIDA QUE NO TRAIGA ESPACIOS EN BLANCO, SI TRAE SE OMITE ESE REGISTRO
				IF CHARINDEX (' ', TRIM(cCad_Entidad)) >= 1 THEN
					LET cCad_Entidad='';
					CONTINUE FOREACH;
				END IF;
				
				--Se fuerza la terminaciÃ³n del segundo for each
				EXIT FOREACH;
			END FOREACH;
			
			IF cCad_Entidad IS NOT NULL AND cCad_Entidad <> '' THEN
				UPDATE "informix".si_ctepf 
				SET curp = cCad_Entidad
				WHERE numcte = cNumCte;
					
				UPDATE "informix".si_bitacora_ife 
				SET actualizado = '2'
				WHERE numcte = cNumCte
				AND fecha = dFechaBitIfe;
				
				LET cCad_Entidad='';

				LET iCont=iCont+2;
					
				IF iCont >= iMaxCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
				LET iActualizados=iActualizados+1;
			END IF;
		END FOREACH;
		
		--Se consulta el tiempo que lleva ejecutandose el proceso para detenerlo en caso de que haya llegado al limite establecido
		select 
		DBINFO('utc_to_datetime', sh_curtime) 
		into dCurrentTime
		from sysmaster:"informix".sysshmvals;
		
		LET intervalo= (dCurrentTime - dHoraInicio)::interval minute(9) to minute;
		LET cadena=intervalo::VARCHAR(12);
		LET entero=cadena::INTEGER;
		IF( (entero >= dMaxTime) OR (dFechaFin = TODAY) OR (iActualizados >= iMaxActualizar)) THEN
			LET bContinuaProcCurp = 'f';
			IF( entero >= dMaxTime ) THEN
				LET bContinuaProc = 'f';
			END IF;
			--Se actualiza la fecha donde se quedo el proceso, para que en la siguiente ejecuciÃ³n comience en dicho dÃ­a
			UPDATE 
			"informix".si_param 
			SET valor = TO_CHAR(dFechaFin, '%d/%m/%Y')
			WHERE descripcion ='Fecha ini act curp SPL sp_obtiene_entidad_job'
			;
		END IF;
	END LOOP;
	COMMIT WORK;
	

	--Se obtiene el valor de la fecha de inicio para actualizar el lugar de nacimiento
	SELECT 
	TO_DATE(valor, "%d/%m/%Y")
	INTO dFechFinLugNac
	FROM "informix".si_param
	WHERE descripcion ='Fecha ini act lug nac SPL sp_obtiene_entidad_job'
	;

	LET iCont = 0;
	BEGIN WORK;
	WHILE (bContinuaProc) LOOP
	
		LET dFechIniLugNac = dFechFinLugNac;
		LET dFechFinLugNac = dFechIniLugNac + 30 UNITS DAY;
		
		IF (dFechFinLugNac > TODAY) THEN
			LET dFechFinLugNac =TODAY;
		END IF;

		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL ("informix".si_cliente)}
			a.numcte
			INTO cNumCte
			FROM "informix".si_cliente a
			WHERE 
			a.tipo_cliente=1
			AND a.fecha_alta BETWEEN dFechIniLugNac AND dFechFinLugNac
			
			SELECT 
			{+AVOID_FULL ("informix".si_ctepf), AVOID_FULL ("informix".si_bitacora_ife)}
			count(1)
			INTO iExistePf
			FROM "informix".si_ctepf pf
			INNER JOIN "informix".si_bitacora_ife btf ON btf.numcte=pf.numcte
			WHERE pf.numcte = cNumCte
			AND (pf.lugar_nac IS NULL OR pf.lugar_nac = '' OR pf.lugar_nac = '00')
			AND btf.cadena_anverso IS NOT NULL
			AND btf.cadena_anverso <> ''
			AND (btf.cadena_anverso LIKE '%ID_NUMBER: %' OR btf.cadena_anverso LIKE '%ELECTOR_ID: %')
			;
			
			IF (iExistePf IS NULL OR iExistePf=0 ) THEN
				CONTINUE FOREACH;
			END IF;

			--Se actualiza el campo lugar de nacimiento
			FOREACH WITH HOLD
				--SE OBTIENE LA CADENA DEL CLIENTE PARA EXTRAER EL ID_NUMBER
				SELECT	
				{+AVOID_FULL ("informix".si_bitacora_ife)}
				cadena_anverso, fecha
				INTO cCad_Anv, dFechaBitIfe
				FROM "informix".si_bitacora_ife
				WHERE numcte = cNumCte
				AND cadena_anverso IS NOT NULL
				AND cadena_anverso <> ''
				AND (cadena_anverso LIKE '%ID_NUMBER: %' OR cadena_anverso LIKE '%ELECTOR_ID: %')
				ORDER BY fecha DESC
						
				--SE EXTRAE EL ID_NUMBER Y SE ACORTA SOLO A OBTIENE LA ENTIDAD		
				LET cCad_Anv = TRIM(cCad_Anv);
				LET iCad_Anv = CHARINDEX('ID_NUMBER: ',cCad_Anv);
				LET cCad_Entidad = SUBSTRING (cCad_Anv FROM iCad_Anv + 11 FOR 14);
				
				--SE VALIDA QUE NO TRAIGA ESPACIOS EN BLANCO, SI TRAE SE OMITE ESE REGISTRO
				IF CHARINDEX (' ', TRIM(cCad_Entidad)) >= 1 THEN
				
					LET iCad_Anv = CHARINDEX('ELECTOR_ID: ',cCad_Anv);
					LET cCad_Entidad = SUBSTRING (cCad_Anv FROM iCad_Anv + 12 FOR 14);
					
					--SE VALIDA QUE NO TRAIGA ESPACIOS EN BLANCO, SI TRAE SE OMITE ESE REGISTRO	
					IF CHARINDEX (' ', TRIM(cCad_Entidad)) >= 1 THEN
						LET cCad_Entidad='';
						CONTINUE FOREACH;
					END IF;
				END IF;
				LET cCad_Entidad = SUBSTRING (cCad_Entidad FROM 13 FOR 2);
				--Se valida que el valor del lugar de nacimiento se encuentre enntre los valores 01,02,03.... 33
				IF cCad_Entidad NOT IN ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33')  THEN
					LET cCad_Entidad='';
					CONTINUE FOREACH;
				END IF;			
				--Se fuerza la terminaciÃ³n del segundo for each
				EXIT FOREACH;
			END FOREACH;
			
			IF cCad_Entidad IS NOT NULL AND cCad_Entidad <> '' THEN
				UPDATE "informix".si_ctepf 
				SET lugar_nac = cCad_Entidad
				WHERE numcte = cNumCte;
					
				UPDATE "informix".si_bitacora_ife 
				SET actualizado = '1'
				WHERE numcte = cNumCte
				AND fecha = dFechaBitIfe;
				
				LET cCad_Entidad='';

				LET iCont=iCont+2;
					
				IF iCont >= iMaxCommit THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
				LET iLugNacAct=iLugNacAct+1;
			END IF;
		END FOREACH;
		
		--Se consulta el tiempo que lleva ejecutandose el proceso para detenerlo en casod e que haya llegado al limite establecido
		select 
		DBINFO('utc_to_datetime', sh_curtime) 
		into dCurrentTime
		from sysmaster:"informix".sysshmvals;
		
		LET intervalo= (dCurrentTime - dHoraInicio)::interval minute(9) to minute;
		LET cadena=intervalo::VARCHAR(12);
		LET entero=cadena::INTEGER;
		IF( (entero >= dMaxTime) OR (dFechFinLugNac = TODAY) OR (iLugNacAct >= iMaxActualizar)) THEN
			LET bContinuaProc = 'f';
			--Se actualiza la fecha donde se quedo el proceso, para que en la siguiente ejecuciÃ³n comience en dicho dÃ­a
			UPDATE 
			"informix".si_param 
			SET valor = TO_CHAR(dFechFinLugNac, '%d/%m/%Y')
			WHERE descripcion ='Fecha ini act lug nac SPL sp_obtiene_entidad_job'
			;
		END IF;
	END LOOP;
	COMMIT WORK;
	
	RETURN cCodRet;
	
END;

END PROCEDURE;