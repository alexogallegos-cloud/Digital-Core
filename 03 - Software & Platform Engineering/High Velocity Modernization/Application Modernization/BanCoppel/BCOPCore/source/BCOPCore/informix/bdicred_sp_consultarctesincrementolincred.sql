CREATE PROCEDURE "informix".sp_consultarctesincrementolincred( pEmpresa CHAR(3),
																pNumCte CHAR(20),
																pRFC CHAR(13),
																pNumTarjeta CHAR(20),
																pTipoConsulta CHAR(2),
																pSucursal CHAR(4),
																pRegistros INTEGER,
                                                                pMonitor INTEGER)
RETURNING 	CHAR(5) AS codigoRetorno,
			CHAR(80) AS mensaje,
			CHAR(1) AS cIsCtePros,
			CHAR(20) AS NumCte,
			CHAR(120) AS NomCte,
			CHAR(13) AS RFC,
			DATE AS FechaSol,
			DATE AS FechaAut,
			DECIMAL(18,2) AS LinCredAct,
			DECIMAL(18,2) AS LincredCal,
			CHAR(1) AS origen,
			CHAR(2) AS Status,
			CHAR(40) AS DescStatus,
			CHAR(80) AS Comentario,
			CHAR(20) AS NumSol;

DEFINE cCodret CHAR(5);
DEFINE cIsCtePros CHAR(1);
DEFINE iSql_err INTEGER;
DEFINE cMensaje CHAR(80);
DEFINE dtFechaIni DATE;
DEFINE dtFechaFin DATE;
DEFINE cRFC CHAR(13);
DEFINE dtFechaSol DATE;
DEFINE dtFechaAut DATE;
DEFINE dLinCredAct DECIMAL(18,2);
DEFINE dLinCredCal DECIMAL(18,2);
DEFINE cOrigen CHAR(1);
DEFINE cStatus CHAR(2);
DEFINE cComentario CHAR(80);
DEFINE cNombre CHAR(120);
DEFINE cNumCte CHAR(20);
DEFINE iIsamErr SMALLINT;
DEFINE cErrorInfo CHAR(80);
DEFINE sDias SMALLINT;
DEFINE iReg INTEGER;
DEFINE cNumSol CHAR(20);
DEFINE cDescStatus CHAR(40);
DEFINE sContReg INTEGER;
DEFINE cEstatus_cred CHAR(2);
DEFINE dtFechaInsert DATE;
DEFINE iDiasVigencia INTEGER;
DEFINE cMtoven DECIMAL(18,2);

LET cCodret = '00000';
LET cIsCtePros = 'N';
LET iSql_err = 0;
LET cMensaje = 'El proceso se ejecuto correctamente';
LET dtFechaIni = DATE(1);
LET dtFechaFin = DATE(1);
LET cRFC = '';
LET dtFechaSol = DATE(1);
LET dtFechaAut = DATE(1);
LET dLinCredAct  = 0;
LET dLinCredCal = 0;
LET cOrigen = '';
LET cStatus = '';
LET cComentario = '';
LET cNombre = '';
LET cNumCte = '';
LET iIsamErr = 0;
LET cErrorInfo = '';
LET sDias = 0;
LET iReg = 0;
LET cNumSol = '';
LET cDescStatus = '';
LET sContReg = 0;
LET cEstatus_cred = '';
LET dtFechaInsert = DATE(1);
LET iDiasVigencia = 0;
LET cMtoven = 0;

BEGIN


	ON EXCEPTION SET iSql_err, iIsamErr, cErrorInfo
		IF iSql_err != 0 THEN
			LET cCodret = iSql_err;
			LET cMensaje= cErrorInfo;
			RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, NVL(cComentario,''), cNumSol;		
		END IF;
	END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/tmp/sp_consultarctesincrementolincred.out";
--TRACE ON ;

	IF (((NVL(pEmpresa,"") = "") OR	(NVL(pTipoConsulta,"") = "")) OR ((NVL(pNumCte,"") = "")  AND (NVL(pSucursal,"") = "") AND  (NVL(pRFC,"") = "") AND (NVL(pNumTarjeta,"") = ""))) THEN
		LET cCodret = '452';
		LET cMensaje = 'Parametros insuficientes para llevar a cabo la consulta'; -- Faltan ingresar parametros
		RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, cComentario, cNumSol;
	END IF;
	
	IF (NVL(pRFC,"") <> "") THEN

		SELECT FIRST 1 numcte 
		INTO pNumCte
		FROM bdinteg:"informix".si_cliente 
		WHERE rfc = pRFC; 
	
        IF (pNumCte IS NULL OR pNumCte = '') then
			LET cCodret = '450';
			LET cMensaje = 'El Cliente especificado no existe'; -- no existe Cliente
			RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, NVL(cComentario,''), cNumSol;
		END IF;
		
	END IF;

	IF (NVL(pNumCte,"") <> "")  THEN

		SELECT COUNT(*) 
		INTO iReg
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = pNumCte; 
		
		IF iReg = 0 THEN
			LET cCodret = '450';
			LET cMensaje = 'El Cliente especificado no existe'; -- no existe Cliente
			RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, NVL(cComentario,''), cNumSol;
		END IF;
		
	END IF;

    IF (NVL(pNumTarjeta,"") <> "") THEN
		IF (SELECT COUNT(num_tarjeta) FROM bdicred:"informix".sd_tarjeta WHERE empresa = pEmpresa and num_tarjeta = pNumTarjeta) = 0 THEN
			LET cCodret = '451';
			LET cMensaje = 'El NÃºmero de Tarjeta no existe'; -- no existe No. Tarjeta
			RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, NVL(cComentario,''), cNumSol;
		END IF;

		SELECT FIRST 1 numcte 
		  INTO pNumCte
          FROM bdicred:"informix".sd_tarjeta 
         WHERE empresa = pEmpresa
           and num_tarjeta = pNumTarjeta 
           and tipo_tarjeta = 'T';

        IF (pNumCte IS NULL OR pNumCte = '') then
			LET cCodret = '454';
			LET cMensaje = 'La tarjeta no es titular'; -- no existe No. Tarjeta
			RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, NVL(cComentario,''), cNumSol;
		END IF;
	END IF;

	SELECT fecha_hoy INTO dtFechaFin FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

	SELECT TRIM(valor) INTO sDias FROM bdicred:"informix".sd_param WHERE empresa = pEmpresa and cod_param = '011';

	LET dtFechaIni = dtFechaFin - sDias UNITS DAY;
	
    IF pMonitor = 1 THEN
       IF (NVL(pNumTarjeta,"") <> "" OR NVL(pRFC,"") <> "" OR NVL(pNumCte,"") <> "") THEN
                SELECT FIRST 1 b.numcte,
                       b.fecha_status, b.lincred_actual, b.lincred_sugerida, b.origen, b.status, b.num_solicitud, c.descripcion, b.fecha_insert,e.descripcion
                INTO cNumCte,dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cNumSol, cDescStatus, dtFechaInsert,cComentario
                FROM  bdicred:"informix".sd_bitacora_aumlincred b
                --INNER JOIN bdinteg:"informix".si_cliente a ON (a.empresa = b.empresa and a.numcte = b.numcte)
                --INNER JOIN bdicred:"informix".sd_status_aumlincred d ON (d.empresa = b.empresa and d.status = b.status )
				INNER JOIN bdicred:"informix".sd_status_aumlincred c ON (c.empresa = b.empresa  AND b.status   = c.status  AND c.mostrar_pantalla = "1")
				LEFT JOIN bdicred:"informix".sd_causas_aumlincred e ON (e.empresa = b.empresa  AND e.status   = b.status  AND e.causa_status = b.causa_status)
				WHERE b.empresa = pEmpresa
                  and b.numcte = pNumCte
				  --and b.status IN ('AT', 'IN')
                  and b.fecha_insert BETWEEN dtFechaIni AND dtFechaFin;

				/*-- SE AGREGA LA CONSULTA PARA OBTENER EL CAMPO DEL COMENTARIO.
                FOREACH
                    SELECT limit 1 justificacion
                    INTO cComentario
                    FROM bdicred:"informix".sd_autorizacion_aumlincred
                    WHERE empresa = pEmpresa
                    AND num_solicitud = cNumSol
                    AND status = cStatus
                    AND fecha_insert = fecha_insert
                   
                    EXIT FOREACH;
                END FOREACH;
				-- AND rowid = (SELECT MAX(rowid) FROM bdicred:'informix'.sd_autorizacion_aumlincred WHERE num_solicitud = cNumSol);
				*/
				LET cComentario = NVL(cComentario,"");
				  
				LET dtFechaSol = dtFechaInsert;
				  
                IF (cNumCte IS NULL OR cNumCte = '') THEN
                    LET cCodret = '453';
                    LET cMensaje = 'No existe cliente con los pará­¥tros especificados';
                    LET cIsCtePros = 'N';
                    LET cNumCte = '';
                    LET cNombre = '';
                    LET cRFC = '';
                    LET dtFechaSol = DATE(1);
                    LET dtFechaAut = DATE(1);
                    LET dLinCredAct  = 0;
                    LET dLinCredCal = 0;
                    LET cOrigen = '';
                    LET cStatus = '';
                    LET cDescStatus = '';
                    LET cComentario = '';
                    LET cNumSol = '';
				
				ELSE
					
					SELECT status_cred 
					INTO cEstatus_cred
					FROM "informix".sd_maecred 
					WHERE empresa = pEmpresa
					AND num_credito = cNumSol;
					
					-- IFRS
					SELECt NVL(monto_vencido + mto_venc_trasp,0) INTO cMtoven FROM bdicred:sd_maesdos WHERE num_credito = cNumSol;					

					IF (cMtoven > 0 AND cStatus <> "AP") THEN --Se modifica para atender INC 
				
						UPDATE bdicred:"informix".sd_bitacora_aumlincred SET status = 'RT', causa_status = 'REV', fecha_status = TODAY, hora_status = CURRENT
						WHERE empresa = pEmpresa AND num_solicitud = cNumSol AND status = cStatus AND fecha_insert BETWEEN dtFechaIni AND dtFechaFin;
						
						INSERT INTO "informix".sd_autorizacion_aumlincred (empresa,num_solicitud,status,causa_status,user_insert,fecha_status,fecha_insert,revision_cac)
						VALUES (pEmpresa, cNumSol, 'RT', 'REV', 'INFORMIX', TODAY, dtFechaInsert, 0);
						
						LET cCodret = '453';
						LET cMensaje = 'No existe cliente con los pará­¥tros especificados';
						LET cIsCtePros = 'N';
						LET cNumCte = '';
						LET cNombre = '';
						LET cRFC = '';
						LET dtFechaSol = DATE(1);
						LET dtFechaAut = DATE(1);
						LET dLinCredAct  = 0;
						LET dLinCredCal = 0;
						LET cOrigen = '';
						LET cStatus = '';
						LET cDescStatus = '';
						LET cComentario = '';
						LET cNumSol = '';
					ELSE
							SELECT FIRST 1 TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
								 a.rfc
							INTO cNombre, cRFC
							FROM bdinteg:si_cliente a 
						   WHERE a.numcte = pNumCte;
						
					END IF;
				END IF;
                
                IF NVL(cOrigen,"") = "C" THEN
                    LET dtFechaSol = "";
                END IF;


                RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, NVL(cComentario,''), cNumSol;
       ELSE
            /*    LET cCodret = '139'; 
                LET cMensaje = ' Esta consulta no esta disponible, por favor consulte por Cliente o por Tarjeta';
                LET cIsCtePros = 'N';
                LET cNumCte = '';
                LET cNombre = '';
                LET cRFC = '';
                LET dtFechaSol = DATE(1);
                LET dtFechaAut = DATE(1);
                LET dLinCredAct  = 0;
                LET dLinCredCal = 0;
                LET cOrigen = '';
                LET cStatus = '';
                LET cDescStatus = '';
                LET cComentario = '';
                LET cNumSol = '';
               
	 	RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, cComentario, cNumSol;
*/          
		FOREACH
                SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_sd_bitacora_aumlincred2), 
                        +INDEX(bdicred:sd_status_aumlincred idx_sd_status_aumlincred)} 
                        a.numcte, TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
                        a.rfc, b.fecha_status, b.lincred_actual, b.lincred_sugerida, b.origen, b.status, b.num_solicitud, c.descripcion,NVL(c.dias_vigencia,0),b.fecha_insert,e.descripcion
                INTO cNumCte, cNombre, cRFC, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cNumSol, cDescStatus,iDiasVigencia,dtFechaSol,cComentario
                FROM  bdicred:"informix".sd_bitacora_aumlincred b
                INNER JOIN bdinteg:"informix".si_cliente a ON (a.numcte   = b.numcte)
                INNER JOIN bdicred:"informix".sd_status_aumlincred c ON (c.empresa = b.empresa  AND b.status   = c.status  AND c.mostrar_pantalla = "1")
				LEFT JOIN bdicred:"informix".sd_causas_aumlincred e ON (e.empresa = b.empresa  AND e.status   = b.status  AND e.causa_status = b.causa_status)				
                WHERE b.empresa  = pEmpresa
                  AND a.numcte   = b.numcte
                  AND b.fecha_insert BETWEEN  dtFechaIni AND dtFechaFin
                  AND b.empresa  = c.empresa 
                  AND b.sucursal = pSucursal
				  AND b.origen = 'S'
                  ORDER BY nombre1, b.numcte

				IF dtFechaAut <  (dtFechaFin - iDiasVigencia UNITS DAY) THEN --validacion de los dias de vigencia de los status
					CONTINUE FOREACH;
				END IF;
				  
                IF NVL(cOrigen,"") = "C" THEN
                    LET dtFechaSol = "";
                END IF;

                LET sContReg = sContReg + 1;

                IF sContReg <= pRegistros THEN
                    CONTINUE FOREACH;
                END IF;         

                RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, NVL(cComentario,''), cNumSol WITH RESUME;
          END FOREACH;

       END IF;
    ELSE
    
			SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_bitacora_status)}
                     a.numcte, TRIM(NVL(a.nombre1, ""))||' '||TRIM(NVL(a.nombre2,""))||' '||TRIM(NVL(a.apell_paterno, ""))||' '||TRIM(NVL(a.apell_materno, "")) as nombre,
				   a.rfc, b.fecha_status, b.lincred_actual, b.lincred_sugerida, b.origen, b.status, b.num_solicitud, d.descripcion, b.fecha_insert
			INTO cNumCte, cNombre, cRFC, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cNumSol, cDescStatus, dtFechaInsert
			FROM  bdicred:"informix".sd_bitacora_aumlincred b
			INNER JOIN bdinteg:"informix".si_cliente a ON (a.empresa = b.empresa AND a.numcte = b.numcte)
			INNER JOIN bdicred:"informix".sd_status_aumlincred d ON (d.empresa = b.empresa AND d.status = b.status)
			WHERE b.empresa = pEmpresa
				AND b.numcte = pNumCte
				AND b.status = 'AT'
			    AND b.fecha_insert BETWEEN dtFechaIni AND dtFechaFin;

			IF NVL(cOrigen,"") = "C" THEN
				LET dtFechaSol = "";
			END IF;
			
            IF (cNumCte IS NULL OR cNumCte = '') THEN
            	LET cCodret = '453';
                LET cMensaje = 'No existe cliente con los pará­¥tros especificados';
                LET cIsCtePros = 'N';
                LET cNumCte = '';
                LET cNombre = '';
                LET cRFC = '';
                LET dtFechaSol = DATE(1);
                LET dtFechaAut = DATE(1);
                LET dLinCredAct  = 0;
                LET dLinCredCal = 0;
                LET cOrigen = '';
                LET cStatus = '';
                LET cDescStatus = '';
                LET cComentario = '';
                LET cNumSol = '';
				
			ELSE
					
					SELECT status_cred 
					INTO cEstatus_cred
					FROM "informix".sd_maecred 
					WHERE empresa = pEmpresa
					AND num_credito = cNumSol;
					
					-- IFRS
					SELECt NVL(monto_vencido + mto_venc_trasp,0) INTO cMtoven FROM bdicred:sd_maesdos WHERE num_credito = cNumSol;					

					IF (cMtoven > 0) THEN
						
						UPDATE bdicred:"informix".sd_bitacora_aumlincred SET status = 'RT', causa_status = 'REV', fecha_status = TODAY, hora_status = CURRENT
						WHERE empresa = pEmpresa AND num_solicitud = cNumSol AND status = cStatus AND fecha_insert between dtFechaIni and dtFechaFin;
						
						INSERT INTO "informix".sd_autorizacion_aumlincred (empresa,num_solicitud,status,causa_status,user_insert,fecha_status,fecha_insert,revision_cac)
						VALUES (pEmpresa, cNumSol, 'RT', 'REV', 'INFORMIX', TODAY, dtFechaInsert, 0);
						
						LET cCodret = '453';
						LET cMensaje = 'No existe cliente con los pará­¥tros especificados';
						LET cIsCtePros = 'N';
						LET cNumCte = '';
						LET cNombre = '';
						LET cRFC = '';
						LET dtFechaSol = DATE(1);
						LET dtFechaAut = DATE(1);
						LET dLinCredAct  = 0;
						LET dLinCredCal = 0;
						LET cOrigen = '';
						LET cStatus = '';
						LET cDescStatus = '';
						LET cComentario = '';
						LET cNumSol = '';

					END IF;
			END IF;

            RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, NVL(cComentario,''), cNumSol;

    END IF;
	

	
	
	IF sContReg = 0 THEN
		LET cCodret = '453';
		LET cMensaje = 'No existe cliente con los pará­¥tros especificados';
		RETURN cCodret, cMensaje, cIsCtePros, cNumCte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, NVL(cComentario,''), cNumSol;
	END IF;
	
END;

END PROCEDURE

DOCUMENT 
'Realiza la selecció® ¤e Clientes prospectos por diferentes filtros de bÃºsqueda',
'para ser mostrados en ventanilla (tipo de consulta 1) o por monitor (tipo de consulta 2)',
'AUTOR : Nubia Janeth Montoya Medina ',
'FECHA : 05/JULIO/2010',
'BD    : bdicred',
'Modificacion: Se descomenta busqueda por sucursal, y se le agregan mas status para ser mostrados en pantalla.',
'para ser mostrados monitor ',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 02/Noviembre/2011',
'BD    : bdicred',
'VERSION:20111102.1345',
'Modificacion: Se agregan mas status para ser mostrados en pantalla en los filtros de consulta por tarjeta,nombre,rfc ',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 09/julio/2012',
'BD    : bdicred',
'Modificacion: Se retorna la fecha de la solicitud con la fecha_insert de la bitacora de aumento de linea de credito',
'AUTOR : Mohamed Carre',
'FECHA : 25/Julio/2012',
'BD    : bdicred',
'VERSION:20120827.1011',
'Modificacion: Se corrige para que en el flujo de sucursal se muestre la fecha de la solicitud',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 17/Septiembre/2012',
'BD    : bdicred',
'VERSION:20120917.1011';

CREATE PROCEDURE "informix".sp_validacion_vigencia_pl() 
RETURNING	 CHAR(5); --Codigo Retorno

DEFINE cCodret				    CHAR(5);			 
DEFINE iSqlerr				    INTEGER;
DEFINE iExiste				    INTEGER;

DEFINE vFechaRegistro      	DATE;
DEFINE vFechaCaduco       	DATE;
DEFINE vFechaHoy			DATE;
define vNumCte				CHAR(20);
DEFINE mSaldoTotal			DECIMAL(18,2);
DEFINE vMontoAbono			DECIMAL(18,2);
DEFINE vNumCredito			CHAR(20);
DEFINE vTipoProducto		CHAR(40);
DEFINE vFolio				CHAR(40);
DEFINE vTipoMov				CHAR(40);
DEFINE vMonto				DECIMAL(18,2);
DEFINE vOrigen				CHAR(40);
DEFINE vBeneficioCalculado	DECIMAL(18,2);
DEFINE vMoneda				CHAR(40);
DEFINE vReferencia23		CHAR(40);
DEFINE pNombreComercio		CHAR(80);
DEFINE mReferencia23		CHAR(40);
DEFINE mOrigen				CHAR(40);
DEFINE aFechaMov			DATE;

DEFINE pMonto				    DECIMAL(16,2);
DEFINE pEmpresa				    CHAR(3);
DEFINE pUsuario					CHAR(40);
DEFINE pTransacc				CHAR(40);
DEFINE pTpPago					SMALLINT;
DEFINE aSucursal				CHAR(40);

DEFINE GLOBAL  g_Remanente      MONEY(14,2) DEFAULT 0;
DEFINE GLOBAL  g_IntMoraCob     MONEY(14,2) DEFAULT 0;
DEFINE GLOBAL  g_IntVencCob     MONEY(14,2) DEFAULT 0;
DEFINE GLOBAL  g_CapVencCob     MONEY(14,2) DEFAULT 0;
DEFINE GLOBAL  g_IntVigCob      MONEY(14,2) DEFAULT 0;
DEFINE GLOBAL  g_CapVigCob      MONEY(14,2) DEFAULT 0;
DEFINE GLOBAL  g_Impuesto       MONEY(14,2) DEFAULT 0;
DEFINE GLOBAL  g_Comision       MONEY(14,2) DEFAULT 0;
DEFINE GLOBAL  g_Seguro         MONEY(14,2) DEFAULT 0;

--INICIALIZANDO VARIABLES -------------
LET vFechaRegistro     	= "";
LET vFechaCaduco    	= "";
LET vFechaHoy			= "";
Let vNumCte				= "";
Let mSaldoTotal			= "";
let vMontoAbono			= "";
LET vNumCredito 		= "";
LET vTipoProducto		= "";
LET vFolio				= "";
LET vMonto				= "";
LET vOrigen				= "";
LET vBeneficioCalculado	= "";
LET vMoneda				= "";
LET vReferencia23		= "";
LET pNombreComercio		= "";
LET mReferencia23		= ""; 
LET mOrigen				= ""; 
LET aFechaMov			= "";

LET pMonto				= 0;
LET pEmpresa			= '001';
LET pUsuario			= 'informix';
LET pTransacc			= 0; 
LET pTpPago				= 1;
LET aSucursal			= "";

LET vTipoMov = 'CARGO_VIGENCIA';

LET g_Remanente     = 0;
LET g_IntMoraCob    = 0;
LET g_IntVencCob    = 0;
LET g_CapVencCob    = 0;
LET g_IntVigCob     = 0;
LET g_CapVigCob     = 0;
LET g_Impuesto      = 0;
LET g_Comision      = 0;
LET g_Seguro        = 0;
---------------------------------------
LET cCodret    			= "00001";
LET iSqlerr    			= 0;
LET iExiste	   			= 0;
---------------------------------------


BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Fausto/Pruebas/sp_validacion_vigencia_pl.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--consultar fecha actual
	SELECT fecha_hoy as fechaHoy
	INTO vFechaHoy 
	FROM bdicred:sd_fechas
	WHERE empresa = '001';
	--Vigencia de un aÃÂ±o
	let vFechaCaduco = mdy(month(vFechaHoy),day(vFechaHoy),year(vFechaHoy)) - 1 units year;

FOREACH
	SELECT numcte, monto_abono,folio, fecha_registro ,origen, referencia23
	INTO vNumCte, vMontoAbono,vFolio, vFechaRegistro, mOrigen, mReferencia23
	FROM bdicred: "informix".sd_vigencia_monedero_plan_lealtad
	where estatus = "f"
	
	select saldo_total
	into mSaldoTotal
	from bdicred:"informix".sd_monedero_plan_lealtad
	where numcte = vNumCte
	and origen = mOrigen;

	select num_credito, tipo_producto, monto, beneficio_calculado, origen, moneda, referencia23, nombre_comercio, fecha_mov
	into vNumCredito, vTipoProducto, vMonto, vBeneficioCalculado, vOrigen, vMoneda, vReferencia23, pNombreComercio, aFechaMov
	from bdicred:"informix".sd_movs_monedero_plan_lealtad
	where numcte = vNumCte
	AND tipo_producto != "CARGO_VIGENCIA"
	AND folio = vFolio
	AND referencia23 = mReferencia23
	AND origen NOT IN ('Devolucion_Pl', 'Devolucion_Ex', 'Devolucion','Aclaraciones_Pl','Aclaraciones_Ex');
	
	if vFechaRegistro < vFechaCaduco then
	
		let mSaldoTotal = mSaldoTotal - vMontoAbono;
			
		UPDATE bdicred:"informix".sd_monedero_plan_lealtad 
		SET saldo_total=mSaldoTotal, fecha_actualizacion=CURRENT 
		WHERE numcte = vNumCte
		AND origen = mOrigen;
		
		LET vMonto = vMonto * -1;
		LET vMontoAbono = vMontoAbono * -1;
	
		INSERT INTO bdicred:"informix".sd_movs_monedero_plan_lealtad(numcte, num_credito, tipo_producto, beneficio_calculado, tipo_mov, fecha_mov, folio, monto, origen, moneda, referencia23, nombre_comercio)
		VALUES(vNumCte, vNumCredito, vTipoProducto, vMontoAbono, vTipoMov, current, vFolio, vMonto, vOrigen, vMoneda, vReferencia23, pNombreComercio);
		
				--------Se agregara el sp principal--------
		SELECT first 1 sucursal
		INTO aSucursal
		FROM bdicred:"informix".sd_movhis
		WHERE num_credito = vNumCredito
		AND num_producto = vTipoProducto
		AND fecha_mov = aFechaMov 
		AND referencia23 = vReferencia23;  
		
		IF vOrigen = "Plan_Lealtad" then
			LET pTransacc = '9820'; 
		ELIF vOrigen = "Reworth" then
			LET pTransacc = '9997'; 
		END IF
	
		if NVL(aSucursal,"")=""  OR aSucursal = "" then
			let aSucursal = "Desconocido";
		end if
		
		if vMonto< 0 then
			let pMonto = ABS (vMonto);
		end if
		
	    EXECUTE PROCEDURE bdicred:"informix".principal(pEmpresa,vNumCredito,pTpPago,pMonto,pUsuario,aSucursal,vFolio,pTransacc)
	    INTO cCodRet,g_Remanente,g_IntMoraCob,g_IntVencCob,g_CapVencCob,g_IntVigCob,g_CapVigCob,g_Impuesto,g_Comision,g_Seguro;
	
		----------------	
	
		--Cambia el estatus al procesar
		UPDATE bdicred:"informix".sd_vigencia_monedero_plan_lealtad
		SET estatus = "t", tipo = "caducado"
		WHERE numcte = vNumCte	
		AND folio = vFolio;
	END IF; 
	
END FOREACH;

LET cCodret='00000';
RETURN  cCodret;

END;
END PROCEDURE
DOCUMENT
'Se crea SP para validacion de vigencia',
'AUTOR : FAUSTO VALENZUELA 99805228',
'FECHA : 01/09/2022',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_generar_devoluciones_pl() 
	RETURNING	 CHAR(5); --Codigo Retorno
	
DEFINE cCodret					CHAR(5);			 
DEFINE iSqlerr					INTEGER;
DEFINE iExiste					INTEGER;

DEFINE dTipoMov					CHAR(40);
DEFINE dOrigen					CHAR(40);
DEFINE dMoneda					CHAR(40);
DEFINE dEstatus					BOOLEAN;
DEFINE dNumCredito				CHAR(40); 
DEFINE dProducto				CHAR(4);
DEFINE dNumCte					CHAR(40); 
DEFINE dPeriodo					CHAR(40);
DEFINE dFechaTransaccion		DATE;
DEFINE dMonto					DECIMAL(18,2);
DEFINE dFolioMov				CHAR(40);
DEFINE cFolioMov				CHAR(40);
DEFINE dReferencia23			CHAR(40);
DEFINE cReferencia23			CHAR(40);
DEFINE cNumCreditoDevolucion	CHAR(40);
DEFINE cMontoDevolucion			DECIMAL(18,2);
DEFINE cPeriodoDevolucion		CHAR(40);
DEFINE cFechaDevolucion			DATE;
DEFINE pFechaCentral			DATE;
DEFINE cNombreComercio 			CHAR(40);
DEFINE mBeneficioCalculado		DECIMAL(18,2);
DEFINE mSaldoTotal				DECIMAL(18,2);
DEFINE vNumCredito				CHAR(40);
DEFINE vNumCte					CHAR(40);
DEFINE vOrigen					CHAR(40);
DEFINE vMonto					DECIMAL(18,2);
DEFINE vReferencia23			CHAR(40);



---------------------------------------
LET cCodret    				= "00001";
LET iSqlerr    				= 0;
LET iExiste	   				= 0;

LET dTipoMov 				= 'CARGO_DEVOLUCION';
LET dOrigen					= "Devolucion";
LET dMoneda					= "mxn";
LET dEstatus				= "f";
LET dNumCredito 			= "";
LET dProducto				= "";
LET dNumCte					= "";
LET dPeriodo				= "";
LET dFechaTransaccion		= "";
LET dMonto					= "";
LET dFolioMov				= "";
LET dReferencia23			= "";
LET cReferencia23			= "";
LET cNombreComercio 		= "";

LET cFolioMov				= "";
LET cNumCreditoDevolucion	= "";
LET cMontoDevolucion		= "";
LET cPeriodoDevolucion		= "";
LET cFechaDevolucion		= "";
LET pFechaCentral			= "";
LET mBeneficioCalculado		= "";
LET mSaldoTotal				= "";

LET vReferencia23			= "";
LET vNumCredito 			= "";
LET vNumCte					= "";
LET vMonto					= "";
LET vOrigen					= "";
---------------------------------------
	
BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/Fausto/Sps/sp_devoluciones.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

----------------------------------------------------------------------LLenado de tabla devoluciones---------------------------------------------------------------------------------------------
	--Obtener fecha DE CENTRAL -----------------------
	--------------------------------------------------
	SELECT fecha_hoy
	INTO pFechaCentral
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';
		
	foreach
	
		SELECT a.numcuenta,b.num_producto,b.numcte,a.fechatransaccion,a.folio_mov, a.montointercard, a.referencia23_325
		INTO   dNumCredito,dProducto,dNumCte,dFechaTransaccion,dFolioMov,dMonto,dReferencia23
		FROM bditarjeta:"informix".td_movimientos_conciliacion a, bdicred:"informix".sd_maecred b, bdicred:"informix".sd_movs_monedero_plan_lealtad c
			where  a.fechatransaccion = DATE(pFechaCentral - 1)
			AND a.tipotransaccion325 = '21'
			AND a.cod_retorno !='000'
			AND a.tipo_conciliacion not in ('10','15')
			and a.aplicacion = 'P'
			--
			AND b.num_credito = a.numcuenta
			AND c.referencia23 = a.refererncia23_325
			GROUP BY numcuenta,num_producto,numcte,fechatransaccion,folio_mov,montointercard,referencia23_325
			
		IF dNumCredito IS NOT NULL
		AND dProducto IS NOT NULL
		AND dNumCte IS NOT NULL
		AND dFechaTransaccion IS NOT NULL
		AND dFolioMov IS NOT NULL
		AND dMonto IS NOT NULL
		AND dReferencia23 IS NOT NULL
		THEN
			
			--valida si existe		
			SELECT num_credito, monto, periodo, fecha, folio_mov, referencia23
			INTO cNumCreditoDevolucion, cMontoDevolucion, cPeriodoDevolucion, cFechaDevolucion, cFolioMov, cReferencia23
			FROM bdicred:"informix".sd_devoluciones_plan_lealtad
			WHERE num_credito = dNumCredito
			AND referencia23 = dReferencia23;
			
			IF cNumCreditoDevolucion = dNumCredito AND cMontoDevolucion = dMonto AND cReferencia23 = dReferencia23 THEN
			
				CONTINUE FOREACH;
				
			ELSE
				If dMonto IS NOT NULL then
					LET dOrigen	= "Devolucion";
					
					LET dPeriodo = TO_CHAR(dFechaTransaccion, "%m-%Y");
					
					INSERT INTO bdicred:"informix".sd_devoluciones_plan_lealtad(numcte, producto, num_credito, monto, periodo, fecha, estatus, origen, moneda, folio_mov, referencia23)
					VALUES (dNumCte,dProducto,dNumCredito,dMonto,dPeriodo,dFechaTransaccion, dEstatus, dOrigen, dMoneda, dFolioMov, dReferencia23);
				END IF;
				
				SELECT a.num_credito,a.numcte, a.origen, a.monto_diario, a.referencia23, nombre_comercio
				INTO vNumCredito,vNumCte,vOrigen,vMonto,vReferencia23,cNombreComercio-------------------------------------------------------------
				FROM bdicred: "informix".sd_compras_plan_lealtad a
				where a.num_credito = dNumCredito
				AND a.numcte = dNumCte
				AND a.monto_diario = dMonto
				AND a.referencia23 = dReferencia23
				and a.estatus_calculo = "t"
				AND a.origen NOT IN ('Devolucion_Pl', 'Devolucion_Ex', 'Devolucion','Aclaraciones_Pl','Aclaraciones_Ex');
				
				IF vReferencia23 is not null and vReferencia23 != '' THEN
					IF vNumCredito IS NOT NULL AND vNumCte IS NOT NULL AND vMonto IS NOT NULL AND vReferencia23 IS NOT NULL THEN
			
						LET dMonto = dMonto * -1;
						
						LET dOrigen = "Devolucion_Pl";
						
						LET dPeriodo = TO_CHAR(dFechaTransaccion, "%m-%Y");
				
						INSERT INTO bdicred:"informix".sd_compras_plan_lealtad(numcte, producto, num_credito, monto_diario, periodo, fecha, estatus_calculo, origen, moneda, referencia23, nombre_comercio)
						VALUES (dNumCte,dProducto,dNumCredito,dMonto,dPeriodo,dFechaTransaccion, "f", dOrigen, dMoneda, dReferencia23, cNombreComercio);
					ELSE
						CONTINUE FOREACH;
					END IF;
				
				ELSE
					
					SELECT a.num_credito,a.numcte, a.origen, a.monto_diario, a.referencia23, nombre_comercio
					INTO vNumCredito,vNumCte,vOrigen,vMonto,vReferencia23, cNombreComercio
					FROM bdicred: "informix".sd_compras_externas a
					where a.num_credito = dNumCredito
					AND a.numcte = dNumCte
					AND a.monto_diario = dMonto
					AND a.referencia23 = dReferencia23
					and a.estatus_calculo = "t"
					AND a.origen NOT IN ('Devolucion_Pl', 'Devolucion_Ex', 'Devolucion','Aclaraciones_Pl','Aclaraciones_Ex');
					
					IF vNumCredito IS NOT NULL AND vNumCte IS NOT NULL AND vMonto IS NOT NULL AND vReferencia23 IS NOT NULL THEN
					
						LET dMonto = dMonto * -1;
						
						LET dOrigen = "Devolucion_Ex";
						
						LET dPeriodo = TO_CHAR(dFechaTransaccion, "%m-%Y");
						
						INSERT INTO bdicred:"informix".sd_compras_plan_lealtad(numcte, producto, num_credito, monto_diario, periodo, fecha, estatus_calculo, origen, moneda, referencia23, nombre_comercio)
						VALUES (dNumCte,dProducto,dNumCredito,dMonto,dPeriodo,dFechaTransaccion, "f", dOrigen, dMoneda, dReferencia23, cNombreComercio);
					ELSE
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;
		END IF;
		
		----------------------------------------------------------------------------------------------------------------------------------
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
	END FOREACH;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

RETURN  cCodret;
END
END procedure
DOCUMENT
'Se crea SP para Devoluciones de Plan de Lealtad',
'AUTOR : FAUSTO VALENZUELA 99805228',
'FECHA : 09/12/2022',
'BD    : BDICRED-BDITARJETA';

CREATE PROCEDURE "informix".sp_report_points_concilia_pl(FechaInicio datetime year to second,
												FechaFin	datetime year to second)
	RETURNING	 CHAR(5) AS codigoEjecucion; --Codigo Retorno
	
DEFINE cCodret				    CHAR(5);			 
DEFINE iSqlerr				    INTEGER;
DEFINE iExiste				    INTEGER;

DEFINE rFechaInicio				datetime year to second;
DEFINE rFechaFin				datetime year to second;

DEFINE aProducto 				char(40);
DEFINE aNumCte 					char(20);
DEFINE aNumCredito 				char(20);
DEFINE bMontoAcumulado			decimal(16,2);
DEFINE rAmount 					decimal(16,2);
DEFINE rPercentagePoints 		char(40);
DEFINE eSaldoTotal 				decimal(16,2);
DEFINE rAccumulatedMonetary 	decimal(16,2);
DEFINE fPeriodo 				char(40);
DEFINE rExpiration              char(40);
DEFINE aOrigen	                char(40);
DEFINE cPorcentajeEsp			char(40);
DEFINE cPorcentajeBen			char(40);
DEFINE cMontoMinimo				decimal(16,2);
DEFINE aReferencia23			CHAR(40);
DEFINE aFechaMov				DATE;
DEFINE dFechaNac				DATE;
DEFINE eFechaActualizacion		DATE;
---------------------------------------
LET cCodret    			= "00001";
LET iSqlerr    			= 0;
LET iExiste	   			= 0;

LET rFechaInicio	 	= FechaInicio;
LET rFechaFin		 	= FechaFin;

LET aProducto 				= "";
LET aNumCte 				= "";
LET aNumCredito 			= "";
LET bMontoAcumulado			= "";
LET rAmount					= "";
LET rPercentagePoints 		= "";
LET eSaldoTotal 			= "";
LET rAccumulatedMonetary 	= "";
LET fPeriodo 				= "";
LET rExpiration 			= "";
LET aOrigen		 			= "";
LET cPorcentajeEsp			= "";
LET cPorcentajeBen			= "";
LET cMontoMinimo			= "";
LET aReferencia23			= "";
LET aFechaMov				= "";
LET dFechaNac				= "";
LET eFechaActualizacion		= "";
---------------------------------------
	
BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/Fausto/Sps/reporte.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

---------------------------------------------------------------------------------------------
TRUNCATE TABLE bdicred:informix.sd_reporte_puntos_acumulados_pl;

FOREACH
	SELECT a.numcte, a.num_credito, a.tipo_producto, a.origen, a.referencia23, a.fecha_mov
	 INTO aNumCte, aNumCredito, aProducto, aOrigen, aReferencia23, aFechaMov
	 FROM "informix".sd_movs_monedero_plan_lealtad a 
	 where a.fecha_mov BETWEEN rFechaInicio AND rFechaFin
	 AND a.tipo_producto IN ('6001', '8100')
	
	 SELECT b.monto_acumulado
	 INTO bMontoAcumulado
	 FROM bdicred:"informix".sd_compra_acumulada_plan_lealtad b
	 WHERE b.num_credito = aNumCredito
	 AND b.numcte = aNumCte
	 AND b.producto = aProducto
	 AND b.origen = aOrigen;
	 
	 SELECT c.porcentaje_especial, c.porcentaje_beneficio, c.monto_minimo
	 INTO cPorcentajeEsp, cPorcentajeBen, cMontoMinimo
	 FROM bdicred:"informix".sd_productos_permitidos_plan_lealtad c
	 WHERE c.num_producto = aProducto;
	 
	 SELECT d.fecha_nac
	 INTO dFechaNac
	 FROM bdinteg:"informix".si_ctepf d
	 WHERE d.numcte = aNumCte;
	
	 SELECT e.saldo_total, e.fecha_actualizacion
	 INTO eSaldoTotal, eFechaActualizacion
	 FROM bdicred:"informix".sd_monedero_plan_lealtad e
	 WHERE e.numcte = aNumCte
	 AND e.origen = aOrigen;
	
	 SELECT f.periodo
	 INTO fPeriodo
	 FROM bdicred:"informix".sd_beneficios_calculados_plan_lealtad f
	 WHERE f.referencia23 = aReferencia23
	 AND f.num_credito = aNumCredito
	 AND f.origen = aOrigen; 
	 
	 LET rAmount = CASE 
					 WHEN aProducto = '6001' THEN cMontoMinimo 
					 WHEN aProducto = '8100' THEN cMontoMinimo 
				   END;
				   
	LET rPercentagePoints = CASE WHEN MONTH(dFechaNac) = MONTH(aFechaMov) THEN
							 CASE WHEN aProducto = '6001' THEN cPorcentajeEsp 
								  WHEN aProducto = '8100' THEN cPorcentajeEsp 
							 END 
							 ELSE  
							 CASE WHEN aProducto = '6001' THEN cPorcentajeBen
								  WHEN aProducto = '8100' THEN cPorcentajeBen  
							 END 
						   END;
	 
	 LET rAccumulatedMonetary = 0 ;
	 LET rExpiration = mdy(month(eFechaActualizacion),day(eFechaActualizacion),year(eFechaActualizacion)) + 1 units year;
	 
	 IF eSaldoTotal IS NOT NULL AND eFechaActualizacion IS NOT NULL THEN
		 INSERT INTO bdicred:informix.sd_reporte_puntos_acumulados_pl (Product,Client,Bill,AccomulatedPurchases,Amount,PercentagePoints,PercentageAccumulated,AccumulatedMonetary,CumulativePeriod,Expiration,origen) 
		 VALUES (aProducto,aNumCte,aNumCredito,bMontoAcumulado,rAmount,rPercentagePoints,eSaldoTotal,rAccumulatedMonetary,fPeriodo,rExpiration,aOrigen);
	 END IF;
END FOREACH;


---------------------------------------------------------------------------------------------
LET cCodret='00000';
RETURN  cCodret;
END
END procedure
DOCUMENT
'Sp para crear reporte de puntos',
'AUTOR : FAUSTO VALENZUELA 99805228',
'FECHA : 17/08/2022',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_generar_compras_externas() 
	RETURNING	 CHAR(5); --Codigo Retorno
	
DEFINE cCodret				    CHAR(5);
DEFINE iSqlerr				    INTEGER;

DEFINE pNumCredito				CHAR(20);
DEFINE pProducto			    CHAR(4);
DEFINE pMontoPago               DECIMAL(16,2);
DEFINE pPeriodo  			    CHAR(20);
DEFINE pNumCte			    CHAR(20);
DEFINE pFechaCorteCompraInicio	DATE;
DEFINE pFechaCorteCompraFinal	DATE;
DEFINE pFechaCentral		    DATE;
DEFINE pFechaMov		    	DATE;
DEFINE pReferencia23			CHAR(40);
DEFINE cFechaMov		    	DATE;
DEFINE pEstatusCalculo			BOOLEAN;
DEFINE cNumCreditoCompras		CHAR(20);
DEFINE cPeriodoCompras			CHAR(20);
DEFINE cMontoCompras			DECIMAL(16,2);
DEFINE cOrigen					CHAR(40);
DEFINE cMoneda					CHAR(40);
DEFINE cReferencia23			CHAR(40);
DEFINE pNombreComercio			CHAR(80);
DEFINE eReferencia23			CHAR(40);
DEFINE eMontoRecibido           DECIMAL(16,2);

--INICIALIZANDO VARIABLES -------------
---------------------------------------
LET iSqlerr    			= 0;
LET cCodret    			= "00000";

LET pNumCredito    		= "";
LET pProducto			= "";
LET pNumCte 			= "";
LET pMontoPago          = "";
LET pPeriodo 			= "";
LET pFechaCentral       = "";
LET pFechaMov			= "";
LET cFechaMov			= "";
LET pReferencia23		= null;
LET pEstatusCalculo		= "f";
LET cNumCreditoCompras  = "";
LET cPeriodoCompras		= "";
LET cMontoCompras		= "";
LET cReferencia23		= "";
LET pNombreComercio		= "";
LET eReferencia23		= "";
LET eMontoRecibido		= "";


LET cOrigen				= "Reworth";LET cMoneda				= "mxn";
---------------------------------------
BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/Fausto/sp_compras_externas.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

---------------------------------------------------------------------------------------------
--Obtener fecha DE CENTRAL -----------------------
	--------------------------------------------------
	SELECT fecha_hoy
	INTO pFechaCentral
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';
		
	foreach
		----------------------------
		SELECT referencia23,transaction_amount
		INTO eReferencia23,eMontoRecibido
		FROM bdicred:"informix".sd_recibir_reworth
		WHERE status = 'confirmed'
		----------------------------
		
		SELECT first 1 a.num_credito,b.num_producto,b.numcte,a.fecha_mov, a.monto :: DECIMAL(16,2) as monto1,a.referencia23,c.nomcomercio325
		INTO   pNumCredito,pProducto,pNumCte,pFechaMov,pMontoPago,pReferencia23,pNombreComercio
		FROM bdicred:"informix".sd_movhis a
		INNER JOIN bdicred:"informix".sd_maecred b ON a.num_credito = b.num_credito
		INNER JOIN bditarjeta:"informix".td_movimientos_conciliacion c on a.nro_tarjeta = c.numtarjeta and a.referencia23 = c.referencia23_325
		where a.referencia23 = eReferencia23
		AND a.monto = eMontoRecibido;
		
		IF pNumCte IS NOT NULL AND pReferencia23 IS NOT NULL THEN 
			
			IF NVL(pNombreComercio,"")=""  OR pNombreComercio = "" THEN
				LET pNombreComercio= 'Desconocido';
			END IF;	
					
			SELECT num_credito, monto_diario, periodo, fecha, referencia23
			INTO cNumCreditoCompras, cMontoCompras, cPeriodoCompras, cFechaMov, cReferencia23
			FROM bdicred:"informix".sd_compras_externas
			WHERE num_credito = pNumCredito
			AND referencia23 = pReferencia23
			AND monto_diario = pMontoPago;
			
			IF cNumCreditoCompras = pNumCredito AND cMontoCompras = pMontoPago AND cReferencia23 = pReferencia23 AND cFechaMov = pFechaMov THEN
			
				CONTINUE FOREACH;
				
			ELSE
				If pMontoPago IS NOT NULL THEN
				
					LET pPeriodo = TO_CHAR(pFechaMov, "%m-%Y");
					
					INSERT INTO bdicred:"informix".sd_compras_externas(numcte, producto, num_credito, monto_diario, periodo, fecha, estatus_calculo, origen, moneda, referencia23,nombre_comercio)
					VALUES (pNumCte,pProducto,pNumCredito,pMontoPago,pPeriodo,pFechaMov, pEstatusCalculo, cOrigen, cMoneda, pReferencia23,pNombreComercio);
				END IF;
			END IF;
		END IF;
		
	END FOREACH;	
		
	RETURN cCodret;
END;
---------------------------------------------------------------------------------------------
END procedure
DOCUMENT
'Se crea SP para Recibir Compras',
'AUTOR : FAUSTO VALENZUELA 99805228',
'FECHA : 17/08/2022',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_generar_aclaraciones_pl() 
	RETURNING	 CHAR(5); --Codigo Retorno
	
DEFINE cCodret					CHAR(5);			 
DEFINE iSqlerr					INTEGER;
DEFINE iExiste					INTEGER;

DEFINE vMoneda					CHAR(40);
DEFINE dEstatus					BOOLEAN;
DEFINE vProducto				CHAR(4);
DEFINE dNumCte					CHAR(40); 
DEFINE vPeriodo					CHAR(40);
DEFINE dFechaTransaccion		DATE;
DEFINE dFolioMov				CHAR(40);
DEFINE cObservaciones			CHAR(40);
DEFINE cReferencia23			CHAR(40);
DEFINE cNumCreditoDevolucion	CHAR(40);
DEFINE cImporteReclamado		DECIMAL(18,2);
DEFINE cFechaAclaracion			DATE;
DEFINE pFechaCentral			DATE;
DEFINE mBeneficioCalculado		DECIMAL(18,2);
DEFINE mSaldoTotal				DECIMAL(18,2);
DEFINE vNumCredito				CHAR(40);
DEFINE vNumCte					CHAR(40);
DEFINE vOrigen					CHAR(40);
DEFINE vMonto					DECIMAL(18,2);
DEFINE vReferencia23			CHAR(40);
DEFINE pNumCredito				CHAR(40);
DEFINE pNumCte					CHAR(40);
DEFINE pProducto				CHAR(4);
DEFINE pMonto					DECIMAL(18,2);
DEFINE pReferencia23			CHAR(40);
DEFINE pFecha					DATE;
DEFINE cId						int;
DEFINE vNombreComercio			CHAR(80);
DEFINE aNumCredito				CHAR(40);
DEFINE aNumCte					CHAR(40);
DEFINE aProducto				CHAR(40);
DEFINE aMonto					DECIMAL(18,2);
DEFINE aReferencia23			CHAR(40);
DEFINE aOrigen					CHAR(40);
DEFINE pOrigen					CHAR(40);
DEFINE aObservaciones			CHAR(40);

---------------------------------------
LET cCodret    				= "00001";
LET iSqlerr    				= 0;
LET iExiste	   				= 0;

LET vOrigen					= "";
LET vMoneda					= "mxn";
LET dEstatus				= "f";
LET vProducto				= "";
LET dNumCte					= "";
LET vPeriodo				= "";
LET dFechaTransaccion		= "";
LET dFolioMov				= "";
LET cReferencia23			= "";

LET cObservaciones			= "";
LET cNumCreditoDevolucion	= "";
LET cImporteReclamado		= "";
LET cFechaAclaracion		= "";
LET pFechaCentral			= "";
LET mBeneficioCalculado		= "";
LET mSaldoTotal				= "";

LET vReferencia23			= "";
LET vNumCredito 			= "";
LET vNumCte					= "";
LET vMonto					= "";
LET vNombreComercio			= "";

LET pNumCredito				= "";
LET pNumCte					= "";
LET pProducto				= "";
LET pMonto					= "";
LET pReferencia23			= "";
LET pFecha					= "";
LET cId						= "";
LET aNumCredito				= ""; 
LET aNumCte					= "";
LET aProducto				= "";
LET aMonto					= "";
LET aReferencia23			= "";
LET aOrigen					= "";
LET pOrigen					= "";
LET aObservaciones			= "";


BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Fausto/sp_aclaraciones.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

----------------------------------------------------------------------LLenado de tabla devoluciones---------------------------------------------------------------------------------------------
	--Obtener fecha DE CENTRAL -----------------------
	--------------------------------------------------
	SELECT fecha_hoy,  TO_CHAR( fecha_hoy, '%m-%Y' )
	INTO pFechaCentral,vPeriodo
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';
	
		
	FOREACH

			SELECT fecha_cargo, referencia23, importe_reclamado, observaciones, id
				INTO cFechaAclaracion, cReferencia23, cImporteReclamado, cObservaciones, cId
				FROM bdicred:"informix".sd_aclaraciones_pl
				where estatus = "f"
			union all 
			select fecha, referencia23, monto,
				case 
					when naturaleza = "A" or naturaleza = "a" then "ABONAR"
					when naturaleza = "C" or naturaleza = "c" then "QUITAR"
				end as observaciones,
				id
				from bdicred:"informix".sd_aclaraciones_soc
				where estatus ="f"
			
			
			
			IF cReferencia23 IS NOT NULL AND cObservaciones IS NOT NULL AND cFechaAclaracion IS NOT NULL THEN 
			
				SELECT num_credito,numcte,producto, monto_diario,referencia23,nombre_comercio
				INTO vNumCredito,vNumCte,vProducto,vMonto,vReferencia23,vNombreComercio
				FROM bdicred: "informix".sd_compras_plan_lealtad
				where referencia23 = cReferencia23
				AND origen NOT IN ('Devolucion_Pl', 'Devolucion_Ex', 'Devolucion','Aclaraciones_Pl','Aclaraciones_Ex');
			---------------------------------------------------------------------------
				select first 1 referencia23,origen
				INTO aReferencia23,aOrigen
				FROM bdicred:"informix".sd_aclaraciones_soc 
				where estatus = "t"
				AND referencia23 = cReferencia23
				and monto = cImporteReclamado;
			---------------------------------------------------------------------------
				IF vReferencia23 is not null and vReferencia23 != '' THEN
					IF vNumCredito IS NOT NULL AND vNumCte IS NOT NULL AND vMonto IS NOT NULL AND vReferencia23 IS NOT NULL THEN
						
						IF cObservaciones = "QUITAR" THEN
							LET cImporteReclamado = cImporteReclamado * -1;
						END IF;	
					
						LET vOrigen	= 'Aclaraciones_Pl';
						
						SELECT first 1 a.num_credito,a.numcte,a.producto, a.monto_diario,a.referencia23,a.fecha,a.origen
						INTO pNumCredito,pNumCte,pProducto,pMonto,pReferencia23,pFecha,pOrigen
						FROM bdicred: "informix".sd_compras_plan_lealtad a
						where a.referencia23 = vReferencia23
						and a.origen = vOrigen;
					
						IF pNumCredito = vNumCredito AND pNumCte = vNumCte AND pReferencia23 = vReferencia23 AND pMonto = vMonto AND aOrigen = pOrigen THEN
							CONTINUE FOREACH;
						ELSE
							INSERT INTO bdicred:"informix".sd_compras_plan_lealtad(numcte, producto, num_credito, monto_diario, periodo, fecha, estatus_calculo, origen, moneda, referencia23, nombre_comercio)
							VALUES (vNumCte,vProducto,vNumCredito,cImporteReclamado,vPeriodo,pFechaCentral, "f", vOrigen, vMoneda, vReferencia23, vNombreComercio);
							
							update bdicred:"informix".sd_aclaraciones_pl set estatus = 't'
							where referencia23 = vReferencia23
							and id = cId;
							
							update bdicred:"informix".sd_aclaraciones_soc set estatus = 't'
							where referencia23 = vReferencia23
							and id = cId;
							
						END IF;
						
					ELSE
						CONTINUE FOREACH;
					END IF;
				
				ELSE
					
					LET vOrigen	= 'Reworth';
				
					SELECT first 1 a.num_credito,a.numcte,a.producto,a.monto_diario, a.referencia23, a.nombre_comercio
					INTO vNumCredito,vNumCte,vProducto,vMonto,vReferencia23,vNombreComercio
					FROM bdicred: "informix".sd_compras_externas a
					where a.referencia23 = cReferencia23
					and a.origen = vOrigen;
					
					IF vNumCredito IS NOT NULL AND vNumCte IS NOT NULL AND vMonto IS NOT NULL AND vReferencia23 IS NOT NULL THEN
					
						IF cObservaciones = "QUITAR" THEN
							LET cImporteReclamado = cImporteReclamado * -1;
						END IF;	
					
						LET vOrigen	= 'Aclaraciones_Ex';
						
						SELECT first 1 a.num_credito,a.numcte,a.producto, a.monto_diario,a.referencia23,a.fecha,a.origen
						INTO pNumCredito,pNumCte,pProducto,pMonto,pReferencia23,pFecha,pOrigen-------------------------------------------------------------
						FROM bdicred: "informix".sd_compras_plan_lealtad a
						where a.referencia23 = vReferencia23
						and a.origen = vOrigen;
					
						IF pNumCredito = vNumCredito AND pNumCte = vNumCte AND pReferencia23 = vReferencia23 AND pFecha = cFechaAclaracion AND pMonto = vMonto and pOrigen = aOrigen THEN
							CONTINUE FOREACH;
						ELSE
							INSERT INTO bdicred:"informix".sd_compras_plan_lealtad(numcte, producto, num_credito, monto_diario, periodo, fecha, estatus_calculo, origen, moneda, referencia23, nombre_comercio)
							VALUES (vNumCte,vProducto,vNumCredito,cImporteReclamado,vPeriodo,pFechaCentral, "f", vOrigen, vMoneda, vReferencia23, vNombreComercio);
							
							update bdicred:"informix".sd_aclaraciones_pl set estatus = 't'
							where referencia23 = vReferencia23
							and id = cId;
							
							update bdicred:"informix".sd_aclaraciones_soc set estatus = 't'
							where referencia23 = vReferencia23
							and id = cId;
							
						END IF;
						
					ELSE
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
	END FOREACH;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

RETURN  cCodret;
END
END procedure
DOCUMENT
'Se crea SP para Aclaraciones de Plan de Lealtad',
'AUTOR : FAUSTO VALENZUELA 99805228',
'FECHA : 09/12/2022',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_liberasaldo_automatico()
RETURNING CHAR(5) AS CodRet,
CHAR(64) AS MensRet;

	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(200);
	DEFINE vCodRet				CHAR(5);
	DEFINE vMensajeRet			CHAR(64);
	DEFINE cRuta				CHAR(80);
	DEFINE vSql					CHAR(1024);
	DEFINE vSql2				CHAR(1024);
	DEFINE vArchivo				CHAR(200);
	DEFINE vCodRet2				CHAR(5);
	DEFINE vNomQuery			CHAR(50);
	DEFINE v_num_credito		CHAR(20);
	DEFINE v_existe				INTEGER;
	DEFINE i					INTEGER;
	DEFINE vTotalRegistros		INTEGER;
	DEFINE vfecha				CHAR(8);

	LET iSqlErr 				= 0;
	LET iIsamErr				= 0;
	LET cErrorInfo				= '';
	LET vCodRet 				= '00000';
	LET vMensajeRet				= 'Liberacion de saldos exitoso';
	LET cRuta 					='/resplogifx/archivoscredito/';
	LET vSql					='';
	LET vSql					='';
	LET vArchivo				="ventanaCreditoRetenido"; 
	LET vCodRet2				= '';
	LET vNomQuery				='cargaRetenido.sql';
	LET vTotalRegistros			= 0;
	LET vfecha					= '';
	
BEGIN

	/* EXCEPTION */
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr <> 0 THEN 
			LET vMensajeRet = 'Ocurrio un error en el proceso de liberar saldos automatico';
			RETURN iSqlErr,vMensajeRet; 
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/ciaguilar/Saldo_Retenido/automatizacion_liberasaldo.out";
	--TRACE ON;
	
	SELECT lpad(day(fecha_hoy),2,0)||lpad(month(fecha_hoy),2,0)||year(fecha_hoy)
	INTO vfecha
	FROM bdicred:sd_fechas;
	  
	/*Paso de validaciones para el archivo */
	DROP TABLE IF EXISTS "informix".tmp_sdo_retenido;
	
	CREATE TABLE "informix".tmp_sdo_retenido 
	(
	 num_tarjeta	CHAR(20) NOT NULL,
	 num_credito	CHAR(20) NOT NULL,
	 monto      	DECIMAL(18,2) NOT NULL,
	 folio_suc  	CHAR(16) NOT NULL,
	 fecha_hora 	DATETIME YEAR to SECOND DEFAULT CURRENT YEAR to SECOND,
	 existe 		INTEGER DEFAULT 1,
	 observaciones	CHAR(40)
	);

	CREATE INDEX "informix".idx_tmp_sdoretenido01 on "informix".tmp_sdo_retenido(num_credito);
	CREATE INDEX "informix".idx_tmp_sdoretenido02 on "informix".tmp_sdo_retenido(existe);
	
	LET vSql = 'echo "load from '||TRIM(cRuta)||TRIM(vArchivo)||vfecha||'.unl'||' insert into "informix".tmp_sdo_retenido(num_tarjeta,num_credito,monto,folio_suc,fecha_hora);" > ' || TRIM(cRuta)|| TRIM(vNomQuery);
	SYSTEM vSql;
	LET vSql = 'dbaccess bdicred ' || TRIM(cRuta)|| TRIM(vNomQuery);
	SYSTEM vSql;
	
	
	/* Comienzan validaciones */
	SELECT COUNT(*) INTO vTotalRegistros FROM "informix".tmp_sdo_retenido;
	
	IF vTotalRegistros = 0 THEN
		LET vMensajeRet = 'Archivo Vacio';
		RETURN vCodRet, vMensajeRet;	
	END IF;
	
	--Valida la existencia del credito
	FOREACH WITH HOLD
		SELECT num_credito into v_num_credito from bdicred:tmp_sdo_retenido 
			
			SELECT count(*) INTO i FROM sd_maecred WHERE num_credito = v_num_credito;
	
			IF i IS NULL OR i = 0 THEN
				BEGIN WORK;
					UPDATE "informix".tmp_sdo_retenido SET existe = 0 where num_credito = v_num_credito;
				COMMIT WORK;
			END IF;
			
	END FOREACH;
	
	/*PASO 1*/
	/* TRUNCATE */
	TRUNCATE TABLE "informix".sd_retenidolibera;
	
	/*PASO 2*/
	/* LOAD */
	INSERT INTO bdicred:"informix".sd_retenidolibera (num_tarjeta, num_credito, monto, folio_suc, fecha_hora)
	SELECT tmpsdo.num_tarjeta, tmpsdo.num_credito, tmpsdo.monto,tmpsdo.folio_suc,tmpsdo.fecha_hora
	FROM "informix".tmp_sdo_retenido tmpsdo 
	WHERE existe = 1 ;

	/*PASO 3*/
	/* STORED PRODECURED */
	EXECUTE PROCEDURE "informix".libera_retenido_forzado() into vCodRet2;
	
	SELECT COUNT(*) into i FROM tmp_sdo_retenido where existe = 0;
	
	IF  i > 0  THEN
		LET vSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'ObservacionesSaldoRetenido'||vfecha||'.unl'||
		' SELECT num_credito,folio_suc,DECODE(existe,0,''Credito no existe'') FROM "informix".tmp_sdo_retenido where existe = 0 " > '||TRIM(cRuta)|| TRIM(vNomQuery) ;
		SYSTEM vSql;
		LET vSql = 'dbaccess bdicred ' || TRIM(cRuta)|| TRIM(vNomQuery);
		SYSTEM vSql;
	END IF;
	
	LET vSql = 'rm -f ' || TRIM(cRuta) || TRIM(vNomQuery);
	SYSTEM vSql;
	
	IF vCodRet2 <> "000" THEN
		LET vMensajeRet = 'Error en ejecucion del stored libera_retenido_forzado';
		RETURN vCodRet2,vMensajeRet ;
	END IF;
	
	RETURN vCodRet,vMensajeRet;
END;
END PROCEDURE;