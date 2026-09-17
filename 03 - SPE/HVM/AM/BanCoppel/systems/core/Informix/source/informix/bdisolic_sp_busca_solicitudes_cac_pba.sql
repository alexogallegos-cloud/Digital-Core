CREATE PROCEDURE "informix".sp_busca_solicitudes_cac_pba(pEmpresa		CHAR(3),
													pNumSolicitud   CHAR(20),
													pEjecutivo      CHAR(8),
													pNumPag         INTEGER,
													pDesplazar      INTEGER,
													pBuscaSolic     INTEGER)


RETURNING CHAR(6)           AS cod_ret,
          CHAR(80)          AS mensaje_ret,
          CHAR(20)          AS num_cred,
          CHAR(4)           AS num_suc,
		  CHAR(107)         AS nombre_cte,
		  CHAR(13)          AS rfc_cte,
		  DATE              AS fecha_solic,
		  CHAR(1)           AS OS,
		  CHAR(40)          AS nom_pdcto,
		  DECIMAL(18,2)     AS lin_calculada,
		  CHAR(45)          AS nom_analista,
		  CHAR(2)           AS consulta,
		  SMALLINT			AS Continua,         -- INDICA SI EXISTEN MÁS REGISTROS POR CONSULTAR
		  INTEGER           AS pagina,
		  CHAR(8)			AS cEjec_autoriza;



DEFINE iNumReg           INTEGER;
DEFINE iContadorSol      INTEGER;
DEFINE iNumPag           INTEGER;
DEFINE sSiguiente        SMALLINT;

--Declaración de Variables
DEFINE iSqlErr         		INTEGER;
DEFINE iIsamErr        		INTEGER;
DEFINE cErrorInfo      		CHAR(80);
DEFINE cCodRet         		CHAR(6);
DEFINE cMensajeRet     		CHAR(80);

DEFINE cNumSolic       		CHAR(20);
DEFINE cSucursal            CHAR(4);
DEFINE cNumCte         		CHAR(20);
DEFINE cNom1Cte        		CHAR(26);
DEFINE cNom2Cte        		CHAR(26);
DEFINE cApellPat       		CHAR(26);
DEFINE cApellMat       		CHAR(26);
DEFINE cNombreCte      		CHAR(107);
DEFINE cRfcCte         		CHAR(13);
define cEjec_Atde           CHAR(8);
DEFINE dtFechSolic          DATE;
DEFINE cTieneOS             CHAR(1);
DEFINE cNum_Pdcto           CHAR(4);
DEFINE cNomPdcto            CHAR(40) ;
DEFINE dLinCalculada        DECIMAL(18,2);
DEFINE cNomAnalista         CHAR(45);
DEFINE cConsulta            CHAR(2) ;
DEFINE cStatus              CHAR(2);

---DEFINICIÓN DE VARIABLES PARA CÁLCULOS  CON HORAS  Y FECHAS
DEFINE dtHoraActual DATETIME HOUR TO SECOND;
DEFINE dtHoraAnterior DATETIME HOUR TO SECOND;
DEFINE dtHoraAnterior2 DATETIME HOUR TO SECOND;
DEFINE dfecha DATE;
DEFINE cHora CHAR(10);
DEFINE cHora2 CHAR(10);

-- FOLIO 1400
DEFINE cEjec_autoriza	CHAR(8);


LET iNumReg              = 0;
LET iContadorSol         = 0;
LET iNumPag              = 1;
LET sSiguiente           = 0;

--Inicialización de Variables
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cCodRet              = "000000";
LET cMensajeRet          = "CONSULTA EXITOSA";

LET cNumSolic          	= "";
LET cSucursal           = "";
LET cNumCte            	= "";
LET cNom1Cte           	= "";
LET cNom2Cte           	= "";
LET cApellPat			= "";
LET cApellMat			= "";
LET cNombreCte         	= "";
LET cRfcCte            	= "";
LET cEjec_Atde          = "";
LET dtFechSolic         = DATE(1);
LET cTieneOS            = "";
LET cNum_Pdcto          = "";
LET cNomPdcto           = "";
LET dLinCalculada       = 0.00;
LET cNomAnalista       	= "";
LET cConsulta           = "";
LET cStatus             = "";


-- FOLIO 1400
LET cEjec_autoriza      = "";

---INICIALIZACION DE VARIABLES PARA CALCULOS  CON HORAS  Y FECHAS

LET dtHoraActual = CURRENT;
LET cHora = dtHoraActual - '00:15:00';
LET cHora2 = dtHoraActual - '00:24:00';
LET dtHoraAnterior = cHora;
LET dtHoraAnterior2 = cHora2;
LET dfecha = CURRENT;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	IF iSqlErr != 0 THEN
		LET cCodRet     = iSqlErr;
		LET cMensajeRet = cErrorInfo;
		RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
			cNomAnalista, cConsulta, sSiguiente, iNumPag,NVL(cEjec_autoriza,"");
	END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/respaldosbd/josue/sp_busca_solicitudes_cac.out';
--TRACE ON;

IF pEmpresa IS NULL THEN
   LET cCodRet     = "000001";
   LET cMensajeRet = "LA EMPRESA INDICADA NO ES VALIDA";
	RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
		cNomAnalista, cConsulta, sSiguiente, iNumPag,NVL(cEjec_autoriza,"");
END IF;

-- SE ASIGNA LA PAGINACIÓN 
LET iNumReg =  20;

-- SE VALIDAN PARAMETROS DE ENTRADA
IF NVL(iNumReg,"") = "" THEN
    LET cCodRet = "000001";
    LET cMensajeRet = "NO SE ENCUENTRA EL PARÁMETRO PARA LA PAGINACIÓN DE CONSULTA.";
	RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
		cNomAnalista, cConsulta, sSiguiente, iNumPag,NVL(cEjec_autoriza,"");
END IF;

--PASAR DE STATUS LC  STATUS AT
	--CICLO PARA ACTUALIZAR LOS STATUS, ES DECIR , CAMBIAR DE STATUS "LC" A STATUS "AT".
	IF pBuscaSolic = 0 THEN
		FOREACH    -- SE TOMA SOLICITUD POR SOLICITUD
			SELECT num_solicitud, fecha_insert
			INTO cNumSolic, dtFechSolic
			FROM "informix".ss_solicitudes_cac
			WHERE empresa = pEmpresa
			AND (
					  ( status = "LC"  AND (os = "N"   AND ejecutivo_autoriza IS NULL  OR ejecutivo_autoriza =  "")
						AND fecha_insert + 60 <= dfecha AND hora_insert < dtHoraAnterior)
					  OR
					  ( status = "LC"  AND (os = "S"   AND ejecutivo_autoriza IS NULL  OR ejecutivo_autoriza =  "")
						AND (fecha_insert + 61 UNITS DAY) < dfecha AND hora_insert < dtHoraActual)
				)
			AND num_solicitud NOT IN(SELECT num_solicitud FROM "informix".ss_sol_revision_cac)

			-- SE ACTUALIZAN LOS STATUS DE "LC" A STATUS "AT" EN LA TABLA SS_SOLICITUDES_CAC
			UPDATE "informix".ss_solicitudes_cac
					SET status = "AT",
						fecha_determinacion =  CURRENT
			WHERE empresa = pEmpresa
			AND num_solicitud = cNumSolic;
			
			-- SE ACTUALIZAN LOS STATUS EN LA TABLA SS_SOLICITUDES Y SS_AUTORIZACIÖN DE LA BD BDISOLIC
			EXECUTE PROCEDURE "informix".sp_actualiza_status_sol (pEmpresa, 'sistema',cNumSolic, 'AT', '', 'Solicitud Autorizada' )
						INTO cCodRet;

			-- SE VALIDA QUE NO EXISTAN ERRORES AL ACTUALIZAR LOS STATUS EN LA TABLA SS_SOLICITUDES 
			-- Y SS_AUTORIZACIÖN DE LA BD BDISOLIC
			IF cCodRet <> "000000" THEN
				LET cMensajeRet = "ERROR AL ACTUALIZAR EL STATUS DE LA SOLICITUD EN EL PROCEDIMIENTO SP_ACTUALIZA_STATUS_SOL";
				RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
				cNomAnalista, cConsulta, sSiguiente, iNumPag,NVL(cEjec_autoriza,"");
			END IF;
		END FOREACH;
		-- SE VALIDA QUE SI SE REALIZE LA ACTUALIZACIÓN DE EL ESTATUS
		LET cMensajeRet = "SE REALIZÓ LA ACTUALIZACIÓN DEL STATUS DE LC A AT EN LA TABLA DE SOLICITUDES MC";
		RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
		cNomAnalista, cConsulta, sSiguiente, iNumPag,NVL(cEjec_autoriza,"");
	END IF;

IF NVL(pDesplazar,0) IN (0,2,3) THEN -- CONSULTA INICIAL (0), PAGINA SIGUIENTE(2), CONSULTA GENERAL SIN PAGINACIÓN (3).

	IF NVL(pDesplazar,0) = 0 THEN
		DELETE FROM "informix".ss_paginacion_solicitudes_cac
        WHERE   ejecutivo = pEjecutivo;

	ELIF NVL(pDesplazar,0) = 2 THEN 	-- AVANZAR HACIA LA SIGUIENTE PÁGINA

		SELECT MAX(pagina) + 1
		  INTO iNumPag
		  FROM "informix".ss_paginacion_solicitudes_cac
		 WHERE ejecutivo = pEjecutivo;
    END IF;

	-- SI LA CONSULTA SE REALIZA GENERAL 

	IF pNumSolicitud = "" OR pNumSolicitud IS NULL THEN

		FOREACH
			SELECT {+INDEX(ss_solicitudes_cac idx_ss_solicitudes_cac2)} status, num_solicitud, sucursal, numcte, fecha_insert, os, num_producto, ejecutivo_atiende
			INTO cStatus, cNumSolic, cSucursal, cNumCte, dtFechSolic, cTieneOS, cNum_Pdcto, cEjec_Atde
			FROM "informix".ss_solicitudes_cac
			WHERE empresa = pEmpresa
			AND 	(
				   (status = "LC" )
				   OR
				   (status IN ("AT","RT") AND ((ejecutivo_autoriza IS NULL AND os = "S"
										AND (fecha_insert + 1 UNITS DAY) <= dfecha AND hora_insert < dtHoraAnterior)
										OR
										(ejecutivo_autoriza IS NULL AND os = "N"
										AND (fecha_insert + 1 UNITS DAY) <= dfecha AND hora_insert < dtHoraAnterior2)))
				)
			AND num_solicitud NOT IN (SELECT num_solicitud  FROM "informix".ss_paginacion_solicitudes_cac WHERE ejecutivo =  pEjecutivo)
			ORDER BY OS,fecha_insert,hora_insert ASC

			-- SE CONSULTA EL NOMBRE DE EL CLIENTE
			SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
			INTO cNom1Cte, cNom2Cte, cApellPat, cApellMat, cRfcCte
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa
			AND numcte = cNumCte;

			-- SE CONCATENA LA CONSULTA ANTERIOR PARA FORMAR EL NOMBRE DE EL CLIENTE
			LET cNombreCte = TRIM(NVL(cNom1Cte,"")) || " " || TRIM(NVL(cNom2Cte,"")) || " " || TRIM(NVL(cApellPat,"")) || " " || TRIM(NVL(cApellMat,""));

			--OBTIENE EL NOMBRE DEL PRODUCTO
			SELECT nombre_prod
			INTO cNomPdcto
			FROM bdicred:"informix".sd_definicion
			WHERE empresa = pEmpresa
			AND num_producto = cNum_Pdcto;

			--OBTIENE LA LÍNEA CALCULADA
			SELECT monto_solicitado
			INTO dLinCalculada
			FROM "informix".ss_solicitudes
			WHERE empresa = pEmpresa
			AND num_solicitud = cNumSolic;

			--OBTIENE EL NOMBRE DEL EJECUTIVO QUE ATIENDE(ANALISTA)
			SELECT nombre
			INTO cNomAnalista
			FROM bdinteg:"informix".si_ejecut
			WHERE empresa = pEmpresa
			AND ejecutivo =  cEjec_Atde;

			-- SE VALIDA QUE EXISTA UN NOMBRE DE ANALISTA
			IF cNomAnalista = "" OR cNomAnalista IS NULL THEN
				IF cStatus =  "AT" THEN
					LET cConsulta = "XX";
				ELSE
					LET cConsulta = "NO";
				END IF;
			ELSE
				LET cConsulta =  "SI";
			END IF;

			-- SE AUMENTA EL CONTADOR
			LET iContadorSol = iContadorSol + 1;
			LET iNumReg = iNumReg;

			-- SI LO QUE SE QUIERE ES UNA CONSULTA INICIAL (pDesplazar = 0) ó PAGINA SIGUIENTE(pDesplazar = 2)
            IF  pDesplazar <> 3 THEN 
				
				-- SI AUN NO SE LLLEGA AL TOPE DE REGISTROS SE INSERTA EN LA TABLA ss_paginacion_solicitudes_cac
                 IF iContadorSol <= iNumReg THEN
					INSERT INTO "informix".ss_paginacion_solicitudes_cac
						(secuencia, ejecutivo, num_solicitud, sucursal, numcte, nombre_cte, rfc_cte, fecha_solic, os, num_producto, lin_calculada,
						num_analista,nombre_analista, consulta, pagina)

					VALUES (iContadorSol, pEjecutivo,cNumSolic, cSucursal,cNumCte, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNum_Pdcto, dLinCalculada,
							cEjec_Atde, cNomAnalista, cConsulta, iNumPag);

				 ELIF iContadorSol = (iNumReg + 1) THEN
                    LET sSiguiente = 1;
				
				-- SI ES UNA CONSULTA GENERAL SIN PAGINACIÓN (pDesplazar = 3) SE SALE DE EL CICLO
                 ELSE
                    EXIT FOREACH;
                 END IF;

            END IF;
			
			-- SE RETORNA TODA LA INFORMACIÓN QUE EXISTA EN LA CONSULTA GENERAL SOLICITUD POR SOLICITUD
			RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
				cNomAnalista, cConsulta, sSiguiente, iNumPag,NVL(cEjec_autoriza,"") WITH RESUME;

		END FOREACH;

		-- SI LA CONSULTA GENERAL NO REGRESA INFORMACIÓN SE RETORNA UNA CÓDIGO Y MENSAJE DE ERROR
		IF iContadorSol = 0 THEN
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = "000002";
					LET cMensajeRet = "NO HAY REGISTROS CON EL FÍLTRO SOLICITADO";

					RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
							cNomAnalista, cConsulta, 1, NVL(iNumPag,0),NVL(cEjec_autoriza,"");
			END IF;
		END IF;

	ELSE
		
		-- SI LA CONSULTA SE REALIZA POR NúMERO DE SOLICITUD
		IF EXISTS(SELECT num_solicitud FROM "informix".ss_solicitudes_cac WHERE num_solicitud = pNumSolicitud) THEN

				-- SE CONSULTA LA INFORMACIÓN DE LA SOLICITUD EN ESPECÍFICO
				FOREACH
					SELECT status, num_solicitud, sucursal, numcte, fecha_insert, os, num_producto, ejecutivo_atiende,ejecutivo_autoriza 
					INTO cStatus, cNumSolic, cSucursal, cNumCte, dtFechSolic, cTieneOS, cNum_Pdcto, cEjec_Atde, cEjec_autoriza
					FROM "informix".ss_solicitudes_cac
					WHERE empresa = pEmpresa
					AND status  IN ("LC","AT","RT")
					AND num_solicitud NOT IN (SELECT num_solicitud  FROM "informix".ss_paginacion_solicitudes_cac WHERE ejecutivo =  pEjecutivo)
					AND num_solicitud = pNumSolicitud
					
					-- SE CONSULTA EL NOMBRE DE EL CLIENTE
					SELECT nombre1, nombre2, apell_paterno, apell_materno, rfc
					INTO cNom1Cte, cNom2Cte, cApellPat, cApellMat, cRfcCte
					FROM bdinteg:"informix".si_cliente
					WHERE empresa = pEmpresa
					AND numcte = cNumCte;
					
					-- SE CONCATENA LA CONSULTA ANTERIOR PARA FORMAR EL NOMBRE DE EL CLIENTE
					LET cNombreCte = TRIM(NVL(cNom1Cte,"")) || " " || TRIM(NVL(cNom2Cte,"")) || " " || TRIM(NVL(cApellPat,"")) || " " || TRIM(NVL(cApellMat,""));

					--OBTIENE EL NOMBRE DEL PRODUCTO
					SELECT nombre_prod
					INTO cNomPdcto
					FROM bdicred:"informix".sd_definicion
					WHERE empresa = pEmpresa
					AND num_producto = cNum_Pdcto;

					--OBTIENE LA LÍNEA CALCULADA
					SELECT monto_solicitado
					INTO dLinCalculada
					FROM "informix".ss_solicitudes
					WHERE empresa = pEmpresa
					AND num_solicitud = cNumSolic;

					--OBTIENE EL NOMBRE DEL EJECUTIVO QUE ATIENDE(ANALISTA)
					SELECT nombre
					INTO cNomAnalista
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = pEmpresa
					AND ejecutivo =  cEjec_Atde;
					
					-- SE VALIDA QUE EL NOMBRE DE EL ANALISTA NO SE ENCUENTRE VACÍO
					IF cNomAnalista = "" OR cNomAnalista IS NULL THEN
						IF cStatus =  "AT" THEN
							LET cConsulta = "XX";
						ELSE
							LET cConsulta = "NO";
						END IF;
					ELSE
						LET cConsulta =  "SI";
					END IF;

					LET iContadorSol = iContadorSol + 1;
					LET iNumReg = iNumReg;

					-- SI LO QUE SE QUIERE ES UNA CONSULTA INICIAL (pDesplazar = 0) ó PAGINA SIGUIENTE(pDesplazar = 2)
					IF  pDesplazar <> 3 THEN

						-- SI AUN NO SE LLLEGA AL TOPE DE REGISTROS SE INSERTA EN LA TABLA ss_paginacion_solicitudes_cac
						 IF iContadorSol <= iNumReg THEN
							INSERT INTO "informix".ss_paginacion_solicitudes_cac
								(secuencia, ejecutivo, num_solicitud, sucursal, numcte, nombre_cte, rfc_cte, fecha_solic, os, num_producto,
								lin_calculada,num_analista,nombre_analista, consulta, pagina)

							VALUES (iContadorSol, pEjecutivo,cNumSolic, cSucursal,cNumCte, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNum_Pdcto,
							        dLinCalculada,cEjec_Atde, cNomAnalista, cConsulta, iNumPag);

						 ELIF iContadorSol = (iNumReg + 1) THEN
							LET sSiguiente = 1;
						 ELSE
							EXIT FOREACH;
						 END IF;

					END IF;
					
					-- SE RETORNA TODA LA INFORMACIÓN QUE EXISTA EN LA CONSULTA DE LA SOLICITUD ESPECIFICADA
					RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
						cNomAnalista, cConsulta, sSiguiente, iNumPag,NVL(cEjec_autoriza,"") WITH RESUME;

				END FOREACH;
				
				-- SE VALIDA SI NO EXISTE INFORMACIÓN DE LA SOLICITUD ESPECIFICADA Y SE MANDA CÓDIGO Y MENSAJE DE ERROR
				IF iContadorSol = 0 THEN
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
							LET cCodRet = "000002";
							LET cMensajeRet = "NO HAY REGISTROS CON EL FÍLTRO SOLICITADO";

							RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
									cNomAnalista, cConsulta, 1, NVL(iNumPag,0),NVL(cEjec_autoriza,"");
					END IF;
				END IF;
		ELSE
			
			-- SI LA SOLICITUD EXISTE EN LA TABLA SS_SOLICITUDES SE REGRESA QUE NO SE REQUIERE REVISIÓN
			IF EXISTS(SELECT num_solicitud FROM "informix".ss_solicitudes WHERE num_solicitud = pNumSolicitud ) THEN
				LET cCodRet = "000002";
				LET cMensajeRet = "SOLICITUD NO REQUIERE REVISIÓN POR MC";

				RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
					cNomAnalista, cConsulta, 0, iNumPag,NVL(cEjec_autoriza,"");
			ELSE
				-- SI LA SOLICITUD NO EXISTE EN LA TABLA SS_SOLICITUDES SE REGRESA UN CÓDIGO Y MENSAJE DE ERROR
				LET cCodRet = "000003";
				LET cMensajeRet = "NÚMERO DE SOLICITUD NO EXISTE";

				RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
					cNomAnalista, cConsulta, 0, iNumPag,NVL(cEjec_autoriza,"");
			END IF;

		END IF;
	END IF;

ELIF NVL(pDesplazar,0) = 1 THEN -- PAGINA ANTERIOR
	-- SI SE ESTA EN LA PÁGINA ANTERIOR  SE BORRA REGISTRO  DE LA TABLA ss_paginacion_solicitudes_cac
    DELETE FROM "informix".ss_paginacion_solicitudes_cac
          WHERE ejecutivo = pEjecutivo
			AND pagina = pNumPag + 1;

	-- CICLO PARA RETORNAR LOS REGISTROS DE LA TABLA ss_paginacion_solicitudes_cac 
    FOREACH
        SELECT num_solicitud, sucursal, numcte, nombre_cte, rfc_cte, fecha_solic, os, num_producto, lin_calculada,
			   num_analista,nombre_analista, consulta, pagina
          INTO cNumSolic, cSucursal,cNumCte, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNum_Pdcto, dLinCalculada,
				cEjec_Atde, cNomAnalista, cConsulta, iNumPag
          FROM "informix".ss_paginacion_solicitudes_cac
         WHERE ejecutivo = pEjecutivo
           AND pagina = pNumPag
		   ORDER BY secuencia

		-- SE REGRESA LA INFORMACIÓN CONSULTADA
		RETURN cCodRet, cMensajeRet, cNumSolic, cSucursal, cNombreCte, cRfcCte, dtFechSolic, cTieneOS, cNomPdcto, dLinCalculada,
		cNomAnalista, cConsulta, 1, NVL(iNumPag,0),NVL(cEjec_autoriza,"")  WITH RESUME;
    END FOREACH;

END IF;

END
END PROCEDURE
