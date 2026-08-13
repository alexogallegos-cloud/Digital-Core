CREATE PROCEDURE "informix".sp_consulta_ctesrelacionados(pModo SMALLINT, pPaginacion INTEGER, pTpo_informe SMALLINT, pTpo_consulta CHAR(1), pSucursal CHAR(4), pFecha_Ini DATE, pFecha_Fin DATE)

	--RETORNOS-
	RETURNING
	CHAR(6)   AS codret,
	CHAR(20)  AS num_cte,
	CHAR(20)  AS numcte_ref,
	CHAR(20)  AS numcte_ref_coinc,
	CHAR(4)   AS sucursal,
	CHAR(8)   AS num_emp,
	DATE      AS fecha,
	INTEGER   AS Total_reg;

	--DECLARACION DE VARIABLES--
	DEFINE iSql_err		    INTEGER; 
	DEFINE cCodret		    CHAR(6);
	DEFINE cNumcte          CHAR(20);
	DEFINE cNumcte_Ref      CHAR(20);
	DEFINE cNumcte_RefCoinc CHAR(20);
	DEFINE cSucursal        CHAR(4);
	DEFINE cNumEmp          CHAR(8);
	DEFINE dtFecha          DATE;
	DEFINE dtFechaHoy       DATE;
	DEFINE iTot_reg			INTEGER;

	--INICIALIZACION DE VARIABLES--
	LET iSql_err		     = 0;
	LET cCodret		         = '000000';
	LET cNumcte              = '';
	LET cNumcte_Ref          = '';
	LET cNumcte_RefCoinc     = '';
	LET cSucursal            = '';
	LET cNumEmp              = '';
	LET dtFecha              = DATE(1);
	LET dtFechaHoy           = DATE(1);
	LET iTot_reg		     = 0;

	--INICIO--
	BEGIN
		--CONTROL DE ERRORES--
		ON EXCEPTION SET iSql_err 
			IF iSql_err <> 0 THEN
				LET cCodret = iSql_err;
				RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')) , TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cNumcte_RefCoinc,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0);
			END IF;
		END EXCEPTION;
			
		-- SET DEBUG FILE TO '/dbexportb/carlos/like/sp_consulta_ctesrelacionados.out';
		-- TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SE VALIDA QUE SE MANDEN TODOS LOS PARAMETROS (NO NULOS NI VACIOS) YA QUE SON NECESARIOS TODOS
		IF NVL(pModo,0) NOT IN (1,2) OR NVL(pPaginacion,'') = '' OR NVL(pTpo_informe,0) NOT IN (1,2) OR NVL(pTpo_consulta,'') NOT IN ('1','2','3') THEN
			LET cCodret = '000001';  --ES NECESARIO SELECCIONAR UN TIPO DE INFORME Y DE CONSULTA
			RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')) , TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cNumcte_RefCoinc,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0);
		END IF;
		  
		--SI LA CONSULTA ES POR TODO SE CONSULTA LA FECHA_HOY DE TABLAS
		SELECT fecha_hoy
		INTO dtFechaHoy
		FROM "informix".si_fechas
		WHERE empresa = '001';

		--YA ESTA VALIDADO QUE VENDRA EN 1,2 o 3
		IF pTpo_consulta = '1' THEN  --TODO
			
			--SE LIMPIA EL PARAMETRO SUCURSAL YA QUE NO SE USARA EN EL QUERY
			LET pSucursal = '';
			
			--SE DA COMO FECHA_INI EL DATE(1) Y COMO FECHA FINAL LA FECHA_HOY
			LET pFecha_Ini = DATE(1);
			LET pFecha_Fin = dtFechaHoy;
			
		ELIF pTpo_consulta = '2' THEN --SUCURSAL

			IF NVL(pSucursal,'') = '' THEN
				LET cCodret = '000002';  --NO SE INDICO SUCURSAL
				RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')) , TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cNumcte_RefCoinc,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0);
			END IF;
			
			--SE DA COMO FECHA_INI EL DATE(1) Y COMO FECHA FINAL LA FECHA_HOY
			LET pFecha_Ini = DATE(1);
			LET pFecha_Fin = dtFechaHoy;
			
		ELIF pTpo_consulta = '3' THEN  --FECHA

			IF NVL(pFecha_Ini,DATE(1)) = DATE(1) OR NVL(pFecha_Fin,DATE(1)) = DATE(1) THEN
				LET cCodret = '000003';  --ERROR AL INDICAR RANGO DE FECHA
				RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')) , TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cNumcte_RefCoinc,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0);
			END IF;

			--SE LIMPIA EL PARAMETRO SUCURSAL PARA SEGURARSE QUE NO SEA USADO COMO FILTRO EN LA CONSULTA
			LET pSucursal = '';
		END IF;

		--************************************************************************************
		---------------****************BLOQUE DE CONSULTA*************************************
		--************************************************************************************
		IF pModo = 1 THEN --TODOS
			IF pTpo_informe = 1 THEN
				FOREACH
					--SE SELECCIONA EL NUMERO DE CLIENTE Y CLIENTE REFERENCIA A CONSULTAR Y SE AMARRA CON EL NVL QUE NO VENGA VACIO EL CLIENTE REFERENCIA, OSEA QUE EFECTIVAMENTE EL NUMERO DE CLIENTE TENGA UNA REFERENCIA EN TABLAS
					SELECT {+INDEX("informix".si_bitacora_ctes_rel idxbitdict_cte_ref)} numcte, numcte_ref, numcte_ref_coinc, sucursal, numemp,fecha_insert
					INTO cNumcte,cNumcte_Ref, cNumcte_RefCoinc,cSucursal, cNumEmp, dtFecha
					FROM "informix".si_bitacora_ctes_rel
					WHERE NVL(numcte,'') = numcte --PARA QUE NO TRAIGA VACIOS NI NULOS 
					AND NVL(numcte_ref, '') = ''  --PARA ASEGURAR QUE TENGA REFERENCIA
					AND NVL(numcte_ref_coinc, '') = numcte_ref_coinc --PARA ASEGURAR QUE NO TENGAN MAS DE UNA REFERENCIA
					OR NVL(numcte_ref_coinc, '') = NVL(numcte_ref, '')
					AND sucursal = DECODE (pSucursal,'',sucursal,pSucursal)
					AND fecha_insert BETWEEN pFecha_Ini AND pFecha_Fin
									
					
					RETURN TRIM(cCodret), TRIM(cNumcte), TRIM(cNumcte_RefCoinc), TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0) WITH RESUME ;
						
				END FOREACH;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000004'; --NO HAY RESULTADOS PARA LA CONSULTA
					RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')) , TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cNumcte_RefCoinc,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0);
				END IF;
				
			ELSE --pTpo_informe = 2
				FOREACH
					--SE SELECCIONA EL NUMERO DE CLIENTE Y CLIENTE REFERENCIA A CONSULTAR Y SE AMARRA CON EL NVL QUE NO VENGA VACIO EL CLIENTE REFERENCIA, OSEA QUE EFECTIVAMENTE EL NUMERO DE CLIENTE TENGA UNA REFERENCIA EN TABLAS
					SELECT {+INDEX("informix".si_bitacora_ctes_rel idxbitdict_cte_ref)} numcte, numcte_ref, numcte_ref_coinc, sucursal, numemp,fecha_insert
					INTO cNumcte,cNumcte_Ref, cNumcte_RefCoinc,cSucursal, cNumEmp, dtFecha
					FROM "informix".si_bitacora_ctes_rel
					WHERE NVL(numcte,'') = numcte --PARA QUE NO TRAIGA VACIOS NI NULOS 
					AND NVL(numcte_ref, '') <> ''  --PARA ASEGURAR QUE TENGA REFERENCIA
					AND NVL(numcte_ref_coinc, '') = numcte_ref_coinc -- PARA ASEGURAR QUE TENGAN MAS DE UNA REFERENCIA
					AND sucursal = DECODE (pSucursal,'',sucursal,pSucursal)
					OR  NVL(numcte_ref_coinc, '') = numcte_ref
					AND fecha_insert BETWEEN pFecha_Ini AND pFecha_Fin
					
					
					RETURN TRIM(cCodret), TRIM(cNumcte), TRIM(cNumcte_Ref), TRIM(cNumcte_RefCoinc), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0) WITH RESUME;
						
				END FOREACH;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000004'; --NO HAY RESULTADOS PARA LA CONSULTA
					RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')) , TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cNumcte_RefCoinc,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0);
				END IF;
				
			END IF; --pTpo_informe

		ELIF pModo = 2 THEN --PAGINADO
			IF pTpo_informe = 1 THEN
				
				SELECT {+INDEX("informix".si_bitacora_ctes_rel idxbitdict_cte_ref)}  COUNT(*)
				INTO iTot_reg
				FROM "informix".si_bitacora_ctes_rel
				WHERE NVL(numcte,'') = numcte 
				AND NVL(numcte_ref, '') = ''
				AND NVL(numcte_ref_coinc, '') = numcte_ref_coinc
				AND sucursal = DECODE (pSucursal,'',sucursal,pSucursal)
				AND fecha_insert BETWEEN pFecha_Ini AND pFecha_Fin;
				
				FOREACH
					--SE SELECCIONA EL NUMERO DE CLIENTE Y CLIENTE REFERENCIA A CONSULTAR Y SE AMARRA CON EL NVL QUE NO VENGA VACIO EL CLIENTE REFERENCIA, OSEA QUE EFECTIVAMENTE EL NUMERO DE CLIENTE TENGA UNA REFERENCIA EN TABLAS
					SELECT {+INDEX("informix".si_bitacora_ctes_rel idxbitdict_cte_ref)} SKIP pPaginacion LIMIT 20 numcte, numcte_ref, numcte_ref_coinc, sucursal, numemp,fecha_insert
					INTO cNumcte,cNumcte_Ref, cNumcte_RefCoinc,cSucursal, cNumEmp, dtFecha
					FROM "informix".si_bitacora_ctes_rel
					WHERE NVL(numcte,'') = numcte --PARA QUE NO TRAIGA VACIOS NI NULOS 
					AND NVL(numcte_ref, '') = ''  --PARA ASEGURAR QUE TENGA REFERENCIA
					AND NVL(numcte_ref_coinc, '') = numcte_ref_coinc --PARA ASEGURAR QUE NO TENGAN MAS DE UNA REFERENCIA
					OR NVL(numcte_ref_coinc, '') = NVL(numcte_ref, '')
					AND sucursal = DECODE (pSucursal,'',sucursal,pSucursal)
					AND fecha_insert BETWEEN pFecha_Ini AND pFecha_Fin
									
					
					RETURN TRIM(cCodret), TRIM(cNumcte), TRIM(cNumcte_RefCoinc), TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0) WITH RESUME ;
						
				END FOREACH;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000004'; --NO HAY RESULTADOS PARA LA CONSULTA
					RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')) , TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cNumcte_RefCoinc,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0) ;
				END IF;
				
			ELSE --pTpo_informe = 2
			
				SELECT {+INDEX("informix".si_bitacora_ctes_rel idxbitdict_cte_ref)} COUNT(*)
				INTO iTot_reg
				FROM "informix".si_bitacora_ctes_rel
				WHERE NVL(numcte,'') = numcte 
				AND NVL(numcte_ref, '') <> ''    
				AND NVL(numcte_ref_coinc, '') <> '' 
				AND sucursal = DECODE (pSucursal,'',sucursal,pSucursal);
			
				FOREACH
					--SE SELECCIONA EL NUMERO DE CLIENTE Y CLIENTE REFERENCIA A CONSULTAR Y SE AMARRA CON EL NVL QUE NO VENGA VACIO EL CLIENTE REFERENCIA, OSEA QUE EFECTIVAMENTE EL NUMERO DE CLIENTE TENGA UNA REFERENCIA EN TABLAS
					SELECT {+INDEX("informix".si_bitacora_ctes_rel idxbitdict_cte_ref)} SKIP pPaginacion LIMIT 20 numcte, numcte_ref, numcte_ref_coinc, sucursal, numemp,fecha_insert
					INTO cNumcte,cNumcte_Ref, cNumcte_RefCoinc,cSucursal, cNumEmp, dtFecha
					FROM "informix".si_bitacora_ctes_rel
					WHERE NVL(numcte,'') = numcte --PARA QUE NO TRAIGA VACIOS NI NULOS 
					AND NVL(numcte_ref, '') <> ''  --PARA ASEGURAR QUE TENGA REFERENCIA
					AND NVL(numcte_ref_coinc, '') <> '' -- PARA ASEGURAR QUE TENGAN MAS DE UNA REFERENCIA
					AND NVL(numcte_ref_coinc, '') <> numcte_ref
					AND sucursal = DECODE (pSucursal,'',sucursal,pSucursal)
					AND fecha_insert BETWEEN pFecha_Ini AND pFecha_Fin
					
					
					RETURN TRIM(cCodret), TRIM(cNumcte), TRIM(cNumcte_Ref), TRIM(cNumcte_RefCoinc), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0) WITH RESUME ;
						
				END FOREACH;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000004'; --NO HAY RESULTADOS PARA LA CONSULTA
					RETURN TRIM(cCodret), TRIM(NVL(cNumcte,'')) , TRIM(NVL(cNumcte_Ref,'')), TRIM(NVL(cNumcte_RefCoinc,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmp,'')), NVL(dtFecha,DATE(1)),NVL(iTot_reg,0) ;
				END IF;
			END IF; --pTpo_informe
		END IF;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDIMIENTO QUE RECIBE COMO PARAMETRO TIPO DE INFORME, MODO DE EJECUCION, SUSURSAL (opcional depende del modo de ejecucion) Y RANGO DE FECHA(opcional depende del modo de ejecucion), barre la tabla si_bitacora_ctes_rel y regresa una relacion de el numero de cliente(banco) con cliente_reefrencia(coppel), cliente_referencia_coincidencia (del match), sucursal, numero de empleado y fecha.',
'FECHA DE CREACIÓN: 11 DE NOVIEMBRE DE 2013',
'BASE DE DATOS: BDINTEG',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 20131111.1900';

CREATE PROCEDURE "informix".sp_dicta_consultadictamenescte(pModo SMALLINT,pPaginacion INTEGER,pSitEsp CHAR(1),
									pCausa SMALLINT,pSucursal CHAR(4),pFechaIni DATE,pFechaFin DATE)
	-- RETORNOS DEL PROCEDIMIENTO
	RETURNING 	CHAR(6)  AS  CODIGO_DE_RETORNO,
				VARCHAR(107) AS MENSAJE,
				CHAR(20) AS  NUMERO_DE_CLIENTE,
				CHAR(1)	 AS  SITUACION_ESPECIAL,
				SMALLINT AS  CAUSA,
				CHAR(20) AS  CLIENTE_COINCIDENCIA,
				CHAR(1)  AS  SITUACION_ESPECIAL_CLIENTE_COINCIDENCIA,
				INTEGER  AS  CAUSA_CLIENTE_CONINCIDENCIA,
				CHAR(1)  AS  TIPO,
				CHAR(4)  AS  SUCURSAL,
				CHAR(8)  AS  OPERADOR,
				DATE	 AS  FECHA_INSERT,
				CHAR(75) AS  DESCRIPCION_SITUACION_ESPECIAL_CLIENTE_COINCIDENCIA,
				CHAR(25) AS  DESCRIPCION_EMPRESA,
				CHAR(75) AS  DESCRIPCION_SIT_ESP,
				INTEGER  AS  TOTAL_DE_REGISTROS;   
					
	--DEFINICION DE VARIABLES
	DEFINE iSqlErr INTEGER;
	DEFINE iSamErr INTEGER;
	DEFINE vErrorInfo  VARCHAR(107);
	DEFINE cCodRet CHAR(6);
	DEFINE vMensaje	VARCHAR(107);

	DEFINE cNumcte 		CHAR(20);
	DEFINE cSit			CHAR(1);
	DEFINE sCausa		SMALLINT;
	DEFINE cCteCoinc	CHAR(20); 
	DEFINE cSitCoic		CHAR(1);
	DEFINE iCausacoinc	INTEGER;
	DEFINE cTipo		CHAR(1);
	DEFINE cSucursal	CHAR(4);
	DEFINE cUsuario		CHAR(8);
	DEFINE dtFecha		DATE;
	DEFINE cDes_SitEsp_Coinc    CHAR(75);
	DEFINE cDes_Empresa CHAR(25);
	DEFINE cSit_Esp     CHAR(75);
	DEFINE iTot_reg		INTEGER;

	--INICIALIZACION DE VARIABLES
	LET iSqlErr 	= 0;
	LET iSamErr 	= 0;
	LET vErrorInfo  = "";
	LET cCodRet 	= "000000";
	LET vMensaje 	= "EJECUCION EXITOSA";

	LET cNumcte 	 = "";
	LET cSit		 = "";
	LET sCausa		 = 0;
	LET cCteCoinc	 = ""; 
	LET cSitCoic	 = "";
	LET iCausacoinc	 = 0;
	LET cTipo		 ="";
	LET cSucursal	 ="";
	LET cUsuario	 ="";
	LET dtFecha		 = DATE(1); 
	LET cDes_SitEsp_Coinc    ="";
	LET cDes_Empresa = "";
	LET cSit_Esp     = "";
	LET iTot_reg	 = 0;



	--SET DEBUG FILE TO '/dbexportb/marioolivo/sp_dicta_consultadictamenescte.out';
	--TRACE ON;

	BEGIN 				--CONTROL DE ERRORES DE INFORMIX
		ON EXCEPTION
			SET iSqlErr, iSamErr,vErrorInfo
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET vMensaje = vErrorInfo;
				
				RETURN cCodRet,vMensaje,TRIM(NVL(cNumcte,"")),NVL(cSit,""),NVL(sCausa,0),TRIM(NVL(cCteCoinc,"")),TRIM(NVL(cSitCoic,"")),NVL(iCausacoinc,0),cTipo,TRIM(NVL(cSucursal,"")),TRIM(NVL(cUsuario,"")),dtFecha,TRIM(NVL(cDes_SitEsp_Coinc,"")),TRIM(NVL(cDes_Empresa,"")),TRIM(NVL(cSit_Esp,"")),NVL(iTot_reg,0) ;
		
			END IF;
		END EXCEPTION;	

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- VALIDACION DE PARAMETROS.
		IF NVL(pSitEsp,'') = '' OR NVL(pCausa,0) = 0 OR  NVL(pModo,0) NOT IN (1,2) THEN
			LET cCodRet = '000002';
			LET vMensaje = 'Error en parametros.';
			RETURN cCodRet,vMensaje,TRIM(NVL(cNumcte,"")),NVL(cSit,""),NVL(sCausa,0),TRIM(NVL(cCteCoinc,"")),TRIM(NVL(cSitCoic,"")),NVL(iCausacoinc,0),cTipo,TRIM(NVL(cSucursal,"")),TRIM(NVL(cUsuario,"")),NVL(dtFecha,DATE(1)),TRIM(NVL(cDes_SitEsp_Coinc,"")),TRIM(NVL(cDes_Empresa,"")),TRIM(NVL(cSit_Esp,"")),NVL(iTot_reg,0) ;
		END IF;
		
		--INICIALIZA LAS FECHAS CUANDO VIENEN VACIAS.
		IF NVL(pFechaIni,'')='' AND NVL(pFechaFin,'')= '' THEN  
			LET pFechaIni = DATE(1);
			LET pFechaFin = TODAY;
		END IF
		
		-- SE CAMBIA A MAYUSCULA LA SITUACION DEL CLIENTE
		LET pSitEsp = UPPER(pSitEsp);

		-- SI LA CONSULTA SE MANDARA EXPORTAR
		IF pModo = 1 THEN
		
			-- SE BUSCAN TODOS LOS REGISTROS DE LA SITUACION ESPECIAL Y CAUSA DESEADA DE UNA SUCURSAL EN ESPECIFICO
			FOREACH   
				SELECT {+INDEX("informix".si_bitacora_dictamenes idxbita_suc)} numcte, TRIM(situacion),causa,TRIM(numcte_coinc),TRIM(situacion_coinc),causa_coinc,Tipo,TRIM(sucursal),TRIM(numemp),fecha_insert 
				INTO cNumcte,cSit,sCausa,cCteCoinc,cSitCoic,iCausacoinc,cTipo,cSucursal,cUsuario,dtFecha
				FROM "informix".si_bitacora_dictamenes 
				WHERE situacion = pSitEsp
				AND causa = pCausa
				AND sucursal = DECODE (pSucursal,'',sucursal,pSucursal)
				AND fecha_insert BETWEEN pFechaIni AND pFechaFin
				ORDER BY fecha_insert,numcte		
				
				SELECT TRIM(descripcion) INTO cSit_Esp FROM  bdisitesp: "informix".se_catsitesp WHERE situacion= pSitEsp AND causa = pCausa;
				SELECT TRIM(descripcion) INTO cDes_SitEsp_Coinc FROM  bdisitesp: "informix".se_catsitesp WHERE situacion= cSitCoic AND causa = iCausacoinc;
				
				-- SI LA SITUACION ES DE UN EX-EMPLEADO SE BUSCA LA DESCRIPCION DE LA BAJA Y LA EMPRESA
				IF pSitEsp = "P" AND pCausa = 29 THEN 
					   SELECT TRIM(descripcion) INTO cDes_Empresa FROM "informix".si_empresa_huella WHERE numempresa = cTipo;
					   LET cNumcte = TRIM(NVL(cCteCoinc,""));
				END IF;
				
				RETURN cCodRet,vMensaje,TRIM(NVL(cNumcte,"")),NVL(cSit,""),NVL(sCausa,0),TRIM(NVL(cCteCoinc,"")),TRIM(NVL(cSitCoic,"")),NVL(iCausacoinc,0),cTipo,TRIM(NVL(cSucursal,"")),TRIM(NVL(cUsuario,"")),dtFecha,TRIM(NVL(cDes_SitEsp_Coinc,"")),TRIM(NVL(cDes_Empresa,"")),TRIM(NVL(cSit_Esp,"")),NVL(iTot_reg,0) WITH RESUME;
			END FOREACH
			
			 -- SE VALIDA SI LA CONSULTA NO CONTIENE REGRESA DATOS
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				LET cCodRet = '000001';
				LET vMensaje = 'NO EXISTEN REGISTROS CON LA INFORMACION PROPORCIANDA.';
				RETURN cCodRet,vMensaje,TRIM(NVL(cNumcte,"")),NVL(cSit,""),NVL(sCausa,0),TRIM(NVL(cCteCoinc,"")),TRIM(NVL(cSitCoic,"")),NVL(iCausacoinc,0),cTipo,TRIM(NVL(cSucursal,"")),TRIM(NVL(cUsuario,"")),NVL(dtFecha,DATE(1)),TRIM(NVL(cDes_SitEsp_Coinc,"")),TRIM(NVL(cDes_Empresa,"")),TRIM(NVL(cSit_Esp,"")),NVL(iTot_reg,0);
			END IF;

			
		--- SI LA CONSULTA SE MOSTRARÁ EN PANTALLA (DATOS CON PAGINACION)
		ELIF pModo = 2 THEN  
		
			-- SE INICIALIZA VALOR POR DEFAULTD EN CASO DE NO TRAER VALOR PARA NO AFECTAR PAGINACION.
			LET pPaginacion = NVL(pPaginacion,0);
			
						
			SELECT {+INDEX("informix".si_bitacora_dictamenes idxbita_suc)} COUNT(*)
			INTO iTot_reg
			FROM "informix".si_bitacora_dictamenes 
			WHERE situacion = pSitEsp
			AND causa = pCausa
			AND sucursal = DECODE (pSucursal,'',sucursal,pSucursal)
			AND fecha_insert BETWEEN pFechaIni AND pFechaFin;
			
			-- SE BUSCAN 20 REGISTROS DE LA SITUACION ESPECIAL Y CAUSA DESEADA DE UNA SUCURSAL EN ESPECIFICO
			FOREACH  
				SELECT {+INDEX("informix".si_bitacora_dictamenes idxbita_suc)} SKIP pPaginacion LIMIT 20 numcte, TRIM(situacion),causa,TRIM(numcte_coinc),TRIM(situacion_coinc),causa_coinc,Tipo,TRIM(sucursal),TRIM(numemp),fecha_insert 
				INTO cNumcte,cSit,sCausa,cCteCoinc,cSitCoic,iCausacoinc,cTipo,cSucursal,cUsuario,dtFecha
				FROM "informix".si_bitacora_dictamenes 
				WHERE situacion = pSitEsp
				AND causa = pCausa
				AND sucursal = DECODE (pSucursal,'',sucursal,pSucursal)
				AND fecha_insert BETWEEN pFechaIni AND pFechaFin
				ORDER BY fecha_insert,numcte
				
				
				SELECT TRIM(descripcion) 
				INTO cSit_Esp 
				FROM  bdisitesp: "informix".se_catsitesp 
				WHERE situacion= pSitEsp 
				AND causa = pCausa;
				
				SELECT TRIM(descripcion) 
				INTO cDes_SitEsp_Coinc 
				FROM  bdisitesp: "informix".se_catsitesp 
				WHERE situacion= cSitCoic 
				AND causa = iCausacoinc;
				
				-- SI LA SITUACION ES DE UN EX-EMPLEADO SE BUSCA LA DESCRIPCION DE LA BAJA Y LA EMPRESA
				IF pSitEsp = "P" AND pCausa = 29 THEN 
					   SELECT TRIM(descripcion) 
					   INTO cDes_Empresa 
					   FROM "informix".si_empresa_huella 
					   WHERE numempresa = cTipo;
					   LET cNumcte = TRIM(NVL(cCteCoinc,""));
				END IF;
				
				RETURN cCodRet,vMensaje,TRIM(NVL(cNumcte,"")),NVL(cSit,""),NVL(sCausa,0),TRIM(NVL(cCteCoinc,"")),TRIM(NVL(cSitCoic,"")),NVL(iCausacoinc,0),cTipo,TRIM(NVL(cSucursal,"")),TRIM(NVL(cUsuario,"")),dtFecha,TRIM(NVL(cDes_SitEsp_Coinc,"")),TRIM(NVL(cDes_Empresa,"")),TRIM(NVL(cSit_Esp,"")),NVL(iTot_reg,0) WITH RESUME;
				
			END FOREACH
			
			-- SE VALIDA SI LA CONSULTA NO CONTIENE REGRESA DATOS
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN  
				LET cCodRet = '000001';
				LET vMensaje = 'NO EXISTEN REGISTROS CON LA INFORMACION PROPORCIANDA.';
				RETURN cCodRet,vMensaje,TRIM(NVL(cNumcte,"")),NVL(cSit,""),NVL(sCausa,0),TRIM(NVL(cCteCoinc,"")),TRIM(NVL(cSitCoic,"")),NVL(iCausacoinc,0),cTipo,TRIM(NVL(cSucursal,"")),TRIM(NVL(cUsuario,"")),dtFecha,TRIM(NVL(cDes_SitEsp_Coinc,"")),TRIM(NVL(cDes_Empresa,"")),TRIM(NVL(cSit_Esp,"")),NVL(iTot_reg,0);
			END IF;
		END IF;		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION:PROCEDIMIENTO QUE REGRESA LOS DATOS DE EL CLIENTE DE SU SITUACION ESPECIAL Y CAUSA DE LA TABLA SI_BITACORA_DICTAMENES ',
'LA DESCRIPCION DE ESA SITUACION ASÍ COMO TAMBIÉN LA DESCRIPCION DE LA SITUACION Y CAUSA DE EL CLIENTE COINCIDENCIA, LA',
' FECHA EN QUE SE PRESENTO EL CASO Y LA SUCURSAL EN QUE SE SUCEDIO, Y SI EL CLIENTE ES EMPLEADO O EX - EMPLEADO REGRESA TAMBIÉN LA EMPRESA',
'AUTOR :JOSUE REMBERTO ZAZUETA ACOSTA ',
'FECHA : 1 DE NOVIEMBRE DE EL 2013',
'VERSION: 01112013.1645',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_buscar_movimientos_cheques_his3(p_sNumeroCuenta CHAR(30), p_sFechaInicial DATE, p_sFechaFinal DATE, p_sMonto money(14,2), p_skip INT, p_sTarjeta CHAR(30), ids_transacciones lvarchar, p_sNumeroEmpresa CHAR(3))

     RETURNING	DATE AS fechaMovimiento;
	-- Definicion de variables	    
	DEFINE resultado_fechaMovimiento    DATE;
	DEFINE resultado_monto				money(16,2);
	DEFINE resultado_horaMovimiento		DATETIME HOUR to FRACTION(3);
	DEFINE resultado_folioSuc			CHAR(30);
    DEFINE resultado_sucursal			CHAR(4);
    DEFINE resultado_nombre             CHAR(30);
    DEFINE resultado_claveTipo         	CHAR(5);
    DEFINE resultado_tipo   			CHAR(40);
    DEFINE resultado_reversado          CHAR(1);
	DEFINE resultado_refComercio        CHAR(40);
    DEFINE transacciones 				LIST(CHAR(4) NOT NULL);
    DEFINE iSqlErr                      INTEGER;
     
     -- InicializaciÃ³n de las variables.
	LET resultado_fechaMovimiento 		= '';
	LET resultado_monto 				= '';
	LET resultado_horaMovimiento 		= TO_DATE("00:00","%H:%M");
	LET resultado_folioSuc 				= '';
    LET resultado_sucursal 				= '';
    LET resultado_nombre 				= '';
    LET resultado_claveTipo 			= '';
	LET resultado_tipo 					= '';
    LET resultado_reversado 			= '';
	LET resultado_refComercio 			= '';
	LET transacciones 					= 'LIST{' || ids_transacciones || '}';
    
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones OptimizaciÃ³n de SPÂ´s II 05/03/2013
-- Cambio para que en un sÃ³lo SP se realicen todas las consultas que correspan.
-- Se cambia el nombre para la identificaciÃ³n correcta de los SPÂ´s del sistema.
-- SADVC 
	
-- SET DEBUG FILE TO "/informix/SD/Optimizacion_sps_root_II/sp_buscar_movimientos_cheques_his_old.out";
-- TRACE ON;
	
	RETURN resultado_fechaMovimiento;	
END PROCEDURE;