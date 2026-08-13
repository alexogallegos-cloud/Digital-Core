CREATE PROCEDURE "informix".sp_dicta_consultalertacomph2_totales(pModo SMALLINT, pSkyp INTEGER, pStatus CHAR (1), pNumctenvo CHAR (20), pUsuario CHAR (20), pFechaIni DATE, pFechaFin DATE)
		RETURNING CHAR (6) AS Cod_Ret,
			INTEGER	AS total_comparaciones;

	-- DECLARACION DE VARIABLES --
	DEFINE cCodRet CHAR (6);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumcte CHAR (20);
	DEFINE dtFecha DATETIME YEAR TO SECOND;
	DEFINE cStatus CHAR (1);
	DEFINE cSucursal CHAR (4);
	DEFINE sMatches SMALLINT;
	DEFINE sDictaminados SMALLINT;
	DEFINE sTotal SMALLINT;
	DEFINE cOrigen CHAR (1);
	DEFINE iTotalReg INTEGER;
	DEFINE sCtes_Afore SMALLINT;
	DEFINE iContador INTEGER;
	DEFINE iPagina INTEGER;
	DEFINE dFechaIni DATE;
	DEFINE dFechaFin DATE;
	DEFINE cHora CHAR(2);
	DEFINE cMinuto CHAR(2);
	DEFINE cHoraAlerta CHAR(5);
	DEFINE cAnalistaFraudes CHAR(8);
	---
	DEFINE cDescripcionOrigen CHAR(30);
	DEFINE iCont INTEGER;

	-- INICILIZA VARIABLES --
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET cNumcte = '';
	LET dtFecha = DATE(1);
	LET cStatus = '';
	LET cSucursal = '';
	LET sMatches = 0;
	LET sDictaminados = 0;
	LET sTotal = 0;
	LET cOrigen = '';
	LET iTotalReg = 1;
	LET sCtes_Afore = 0;
	LET iContador = 0;
	LET iPagina = 0;
	LET dFechaIni = pFechaIni;
	LET dFechaFin = pFechaFin;
	LET cHora = '00';
	LET cMinuto = '00';
	LET cHoraAlerta = '';
	LET cAnalistaFraudes = '';
	LET iCont = 0;
	---
	--LET cDescripcionOrigen = '';

	--SET DEBUG FILE TO '/tmp/masv/monitor/sp_dicta_consultalertacomph2_totales.out';
	--TRACE ON;

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(cCodRet),NVL(iTotalReg, 0);
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		LET cHoraAlerta = LPAD(NVL(cHora,'00'),2,'0') || ":" ||  '00';

		--VALIDACION DE PARAMETROS --
		IF NVL(pModo,0) = 0 OR  pModo NOT IN (1,2) THEN
			LET cCodRet = '000001';
		END IF;
		--INICIALIZA LAS FECHAS CUANDO VIENEN VACIAS.
		IF NVL(dFechaIni,'') = '' AND NVL(dFechaFin,'') = '' THEN
			LET dFechaIni = today - 1;
			LET dFechaFin = today;
		END IF

		IF NVL(pModo,0) = 2 AND NVL(pNumctenvo,'') = '' AND NVL(pUsuario,'') = ''THEN
			LET cCodRet = '000002';
		END IF

		IF cCodRet::INTEGER <> 0 THEN
			RETURN TRIM(cCodRet), NVL(iTotalReg, 0);
		END IF;

		IF pStatus = '' THEN
			LET pStatus = '1';
		END IF

		IF pModo = 1 THEN

			--SI EL PSKYP VIENE EN 0 BORRA LOS DATOS DE LA TABLA PARA MAS ADELANTE INGRESAR LA INFORMACION ACTUALIZADA CON EL NUMERO DE USUARIO.
			IF pSkyp = 0 THEN
            
				--INICIALIZA LA PAGINA UNO.
				LET iPagina = 1;
				DELETE 'informix'.si_bitacora_alerta_tmp WHERE user_analista = pUsuario;
				UPDATE STATISTICS MEDIUM FOR TABLE 'informix'.si_bitacora_alerta_tmp;
            
				--CONSULTA DE INFORMACION Y LLENADO EN LA TABLA DE TRABAJO.
				let pUsuario = TRIM(pUsuario);
				FOREACH
				
										
            
					SELECT {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_status)} DISTINCT (TRIM(numcte)),TRIM(status_alerta),TRIM(sucursal), num_huellas,fecha_insert,origen
					INTO cNumcte,cStatus,cSucursal,sMatches,dtFecha,cOrigen
					FROM 'informix'.si_bitacora_comparaciones
					WHERE numcte = numcte
					AND ((pStatus <> '5' AND  (status_alerta = pStatus OR (status_alerta = '2' AND analista_fraudes = pUsuario))) OR pStatus = '5' AND status_alerta = pStatus)
					AND fecha_insert::DATE BETWEEN dFechaIni AND dFechaFin
					GROUP BY 1,2,3,4,5,6
					ORDER BY 5 DESC, 1
					
            
					--VERIFICA SI CUENTA CON CLIENTES AFORE O EMPRESAS NO VALIDAS.
					SELECT COUNT(*)
					INTO sCtes_Afore
					FROM "informix".si_huella_linea_resultado a,
						 "informix".si_huella_linea b
					WHERE a.ticket = b.ticket
					AND b.numcte = cNumcte
					AND a.num_mensaje = '602'
					AND a.empresa IN ('','6');
					
					IF nvl(sCtes_Afore,'') = '' THEN
						SELECT COUNT(*)
						INTO sCtes_Afore
						FROM "informix".si_huella_linea_resultado_hist a,
							 "informix".si_huella_linea b
						WHERE a.ticket = b.ticket
						AND b.numcte = cNumcte
						AND a.num_mensaje = '602'
						AND a.empresa IN ('','6');
					END IF
            
					-- RESTA EL TOTAL DE MATCHES PARA MOSTRAR EN PANTALLA LAS QUE ELIMINARAN.
					IF sCtes_Afore > 0 THEN
						LET sMatches = sMatches - sCtes_Afore;
					END IF;
            
					-- CUENTA LOS MATCHES YA DICTAMINADOS.
					SELECT COUNT(*)
					INTO sDictaminados
					FROM 'informix'.si_bitacora_dictamenes
					WHERE numcte = cNumcte;
            
					-- SE RESTAN LOS MATCHES YA DICTAMINADOS.
					LET sTotal = sMatches - sDictaminados;
            
					--SI EL TOTAL DE MATCHES YA FUERON DICTAMINADOS Y CONTINUA CON EL SIGUIENTE REGISTRO.
					IF sTotal <= 0 THEN
            
						CONTINUE FOREACH;
					ELSE
					-- GUARDA EL TOTAL DE MATCHES QUE FALTAN POR DICTAMINAR.
						LET	sMatches = sTotal;
					END IF
            
					--INSERTA INFORMACION EN LA TABLA DE TRABAJO.
					SELECT count(numcte) into iCont FROM si_bitacora_alerta_tmp;
					if  iCont <> 0  THEN
					
					DELETE 'informix'.si_bitacora_alerta_tmp WHERE user_analista = pUsuario and numcte = cNumcte ;
				
					--UPDATE STATISTICS MEDIUM FOR TABLE 'informix'.si_bitacora_alerta_tmp;

					INSERT INTO 'informix'.si_bitacora_alerta_tmp (pagina,registro,numcte,origen,sucursal,num_huellas,status_alerta,fecha_insert,user_analista)
					VALUES (iPagina,iTotalReg,cNumcte,cOrigen,cSucursal,sMatches,cStatus,dtFecha,pUsuario);
					
					end if;
            
					LET iTotalReg = iTotalReg + 1; --CONTADOR DE REGISTROS.
					LET iContador = iContador + 1; --CONTADOR PARA ADQUIRIR EL NUMERO DE PAGINA.
            
					-- SE OBTIENE EL NUMERO DE PAGINA.
					IF iContador = 20 THEN
						LET icontador = 0;
						LET iPagina = iPagina +1;
					END IF
            
				END FOREACH
            
				--VALIDA SI ENCUENTRA INFORMACION.
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '000003';
					LET iTotalReg = 0;
					RETURN TRIM(cCodRet),NVL(iTotalReg, 0);
				END IF;
            
            
			END IF;

			-- OBTENER EL TOTAL DE REGISTROS POR NUMERO DE EMPLEADO DEL ANALISTA.
			
			let pUsuario = TRIM(pUsuario);
			
			SELECT COUNT (*)
			INTO iTotalReg
			FROM 'informix'.si_bitacora_alerta_tmp
			WHERE user_analista = pUsuario
			AND numcte = numcte
			AND pagina = pagina
			AND status_alerta = pStatus
			AND fecha_insert::DATE BETWEEN dFechaIni AND dFechaFin;

			--CONSULTA LA TABLA DE TRABAJO PARA REGRESAR LA INFORMACION.
			--FOREACH
			--	--SELECT SKIP pSkyp LIMIT 20 TRIM(numcte),TRIM(status_alerta),TRIM(sucursal), num_huellas,fecha_insert,origen,LPAD(SUBSTR(fecha_insert,12,2),2,'0'),LPAD(SUBSTR(fecha_insert,15,2),2,'0'),user_analista
			--	SELECT SKIP pRegistros FIRST pRecuperacion TRIM(ba.numcte),TRIM(ba.status_alerta),TRIM(ba.sucursal), ba.num_huellas,ba.fecha_insert,ba.origen,LPAD(SUBSTR(ba.fecha_insert,12,2),2,'0'),LPAD(SUBSTR(ba.fecha_insert,15,2),2,'0'),ba.user_analista, co.desc_origen
			--	INTO cNumcte,cStatus,cSucursal,sMatches,dtFecha,cOrigen,cHora,cMinuto,cAnalistaFraudes, cDescripcionOrigen
			--	FROM 'informix'.si_bitacora_alerta_tmp ba
			--	INNER JOIN si_catorigen co ON ba.origen = co.cod_origen
			--	WHERE ba.user_analista = TRIM (pUsuario)
			--	  AND ba.numcte = numcte
			--	  AND ba.pagina = pagina
			--	  AND ba.status_alerta = pStatus
			--	  AND ba.fecha_insert::DATE BETWEEN dFechaIni AND dFechaFin
			--	  ORDER BY ba.fecha_insert DESC, ba.numcte				  				
            --
			--	LET  cHoraAlerta = cHora || ':' || cMinuto;
            --
			--	RETURN TRIM(cCodRet),NVL(cStatus,''),NVL(cSucursal,''),NVL(cNumcte,''),NVL(sMatches,0),NVL(dtFecha,DATE(1)),NVL(cOrigen,''), iTotalReg, NVL(cHoraAlerta, '00:00'),NVL(cAnalistaFraudes,''), NVL(cDescripcionOrigen,'') WITH RESUME;
            --
			--END FOREACH

			--VALIDA SI ENCUENTRA INFORMACION.
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000003';
				LET iTotalReg = 0;
				RETURN TRIM(cCodRet),NVL(iTotalReg, 0);
			END IF;
			
			RETURN TRIM(cCodRet), NVL(iTotalReg, 0);


		ELIF pModo = 2 THEN
		
			let pNumctenvo = TRIM(pNumctenvo);
		
				DELETE 'informix'.si_bitacora_alerta_tmp WHERE user_analista = pUsuario;
				
				UPDATE STATISTICS MEDIUM FOR TABLE 'informix'.si_bitacora_alerta_tmp;
				
			IF pStatus = '5' OR pStatus = '3'THEN
				-- CONSULTA ESPECIFICA POR CLIENTE CON ESTATUS 5  O  3.
				SELECT numcte, origen, sucursal, num_huellas, status_alerta, fecha_insert
				INTO cNumcte, cOrigen, cSucursal, sMatches, cStatus, dtFecha
				FROM "informix".si_bitacora_comparaciones
				WHERE numcte = pNumctenvo
				AND status_alerta = pStatus;
				
				INSERT INTO 'informix'.si_bitacora_alerta_tmp (pagina,registro,numcte,origen,sucursal,num_huellas,status_alerta,fecha_insert,user_analista)
				VALUES (1, 1, cNumcte, cOrigen, cSucursal, sMatches, cStatus, dtFecha, pUsuario);
				
				SELECT COUNT (*)
				INTO iTotalReg
				FROM 'informix'.si_bitacora_alerta_tmp
				WHERE numcte = pNumctenvo
				AND status_alerta = pStatus;
				
			ELSE 
				-- CONSULTA ESPECIFICA POR CLIENTE.
		
                SELECT limit 1 numcte, origen, sucursal, num_huellas, status_alerta, fecha_insert as fecha_insert
				INTO cNumcte, cOrigen, cSucursal, sMatches, cStatus, dtFecha
				FROM "informix".si_bitacora_comparaciones
    			WHERE numcte = pNumctenvo
				AND status_alerta <> '4' AND status_alerta <> '5'
				AND fecha_insert = (select max(fecha_insert) FROM 'informix'.si_bitacora_comparaciones  where numcte = pNumctenvo); 
				
				INSERT INTO 'informix'.si_bitacora_alerta_tmp (pagina,registro,numcte,origen,sucursal,num_huellas,status_alerta,fecha_insert,user_analista)
				VALUES (1, 1, cNumcte, cOrigen, cSucursal, sMatches, cStatus, dtFecha, pUsuario);
				
				SELECT COUNT (*)
				INTO iTotalReg
				FROM 'informix'.si_bitacora_alerta_tmp
				WHERE numcte = pNumctenvo
				AND status_alerta <> '4' AND status_alerta <> '5' and user_analista =pUsuario
                AND fecha_insert = (select max(fecha_insert) FROM 'informix'.si_bitacora_alerta_tmp  where numcte = pNumctenvo); 
				
			END IF;
			
			LET  cHoraAlerta = cHora || ':' || cMinuto;
			--VALIDA SI ENCUENTRA INFORMACION.
			
			IF DBINFO("sqlca.sqlerrd2") = 0  THEN
				LET cCodRet = '000003';
			--END IF;
			--ELSE
			--IF DBINFO("sqlca.sqlerrd2") <> 0  THEN

				--DELETE 'informix'.si_bitacora_alerta_tmp WHERE user_analista = pUsuario;
				
				---UPDATE STATISTICS MEDIUM FOR TABLE 'informix'.si_bitacora_alerta_tmp;

				--INSERT INTO 'informix'.si_bitacora_alerta_tmp (pagina,registro,numcte,origen,sucursal,num_huellas,status_alerta,fecha_insert,user_analista)
				--VALUES (1, 1, cNumcte, cOrigen, cSucursal, sMatches, cStatus, dtFecha, pUsuario);
				
			END IF;
			

			RETURN TRIM(cCodRet), NVL(iTotalReg, 0);
		END IF;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: se le agrego filtro para mostrar clientes con status 5.',
'AUTOR: Luis Alberto Madrid Castro',
'FECHA DE CREACION: 05/02/2016 ',
'VERSION: 20160121.1727',
'FOLIO: 230142-1530-EvaluaciÃÂ³n de Resultados de ComparaciÃÂ³n de Huellas en LÃÂ­nea en Alta de Cliente',
'BD: bdinteg',
'DESCRIPCION: Procedimiento que consulta las alertas que existen en la tabla si_bitacora_comparaciones de la base de datos bdinteg, ya sea global o en especifico.',
'AUTOR: Vazquez Herrera Hugo',
'FECHA DE CREACION: 19 de SEPTIEMBRE DE 2014',
'VERSION: 20130919.1311',
'FOLIO: 1456',
'AUTOR : Johnattan Esquivel SÃÂ¡nchez ',
'FECHA : 01-06-2020',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtfoliocn2(p_empresa char(3))
    RETURNING   CHAR(5)  AS vcodret,
	            CHAR(12) AS vFolio;
 
    DEFINE vsqlerr    INTEGER;
    DEFINE iIsamErr   SMALLINT;
    DEFINE cErrorInfo CHAR(80);
	DEFINE vErrorInfo CHAR(80);
    DEFINE vcodret    CHAR(5);
	DEFINE intFolio   INTEGER;
    DEFINE vCod_param INTEGER;
	DEFINE vFolio     CHAR(12);
	DEFINE vFolioCN2  CHAR(3);
    	
	
    LET vsqlerr       = 0; 
    LET iIsamErr      = 0;
    LET cErrorInfo    = ""; 
	LET vErrorInfo    = "INICIO DEL PROCESO";
    LET vcodret       = "00000";	
    LET intFolio      = 0;	
	LET vCod_param    = 520;
	LET vFolio        = "";
	LET vFolioCN2     = "CN2";

    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/sp_obtfolioCN2.err";
	 	    TRACE ON;
			LET vcodret    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
            RETURN vcodRet,vFolio;
        END IF;
    END EXCEPTION;
	
	--SET   DEBUG FILE TO '/resplogifx/conciliachq/comision.txt';
    --TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   
	
	--OBTIENE EL VALOR DEL FOLIO
	SELECT valor
    INTO   intFolio
    FROM   bdinteg:si_param
    WHERE  cod_param = vCod_param;
	
	--VALIDA QUE EXISTA EL PARAMETRO
	IF intFolio IS NULL OR intFolio = '' THEN 
	   LET vcodret    = 00001;
       LET vErrorInfo = 'SIN VALOR';
	    RETURN vcodRet,vErrorInfo;
	ELSE 
	   -- INCREMENTA EL FOLIO + 1 
	   LET  intFolio = intFolio + 1;
	END IF;
	
	--ACTUALIZA EL FOLIO PARA LA SIGUIENTE FOLIO
	UPDATE bdinteg:si_param 
	SET    valor = intFolio
	WHERE  cod_param = vCod_param;
	
	--ARMA LA CADENA DEL FOLIO FINAL
	LET vFolio = vFolioCN2||LPAD(intFolio,9,'0');

RETURN vcodRet,vFolio;
END; 
END PROCEDURE;