CREATE PROCEDURE "informix".sp_cac_rep_perfil_usuario3(pFechaIni CHAR (10), pFechaFin CHAR(10))
RETURNING CHAR(6)                         AS codigo_retorno,
          CHAR(80)                        AS mensaje_retorno,
		  CHAR(8)                         AS Numempleado,
		  CHAR(45)                        AS Nombre,
		  CHAR (25)                       AS Perfil_Puesto,
		  INTEGER                         AS Atendidas,
		  DECIMAL(18,2)                   AS PorcAtendidas,
		  INTEGER                         AS Canceladas,
		  DECIMAL(18,2)                   AS PorcCanceladas,
		  INTEGER                         AS Rechazadas,
		  DECIMAL(18,2)                   AS PorcRechazadas,
		  INTEGER                         AS Autorizadas,
		  DECIMAL(18,2)                   AS PorcAutorizadas,
		  
		  INTEGER                         AS TotalAtendidas,
		  DECIMAL(18,2)                   AS TotalPorcAtendidas,
		  INTEGER                         AS TotalCanceladas,
		  DECIMAL(18,2)                   AS TotalPorcCanceladas,
		  INTEGER                         AS TotalRechazadas,
		  DECIMAL(18,2)                   AS TotalPorcRechazadas,
		  INTEGER                         AS TotalAutorizadas,
		  DECIMAL(18,2)                   AS TotalPorcAutorizadas;

---DECLARACIONES   
DEFINE cCodRet              CHAR(6); 
DEFINE cMensajeRet          CHAR(80);
DEFINE iSqlErr      	    INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE dPorcAtendidas		DECIMAL(18,2);	
DEFINE dPorcCanceladas		DECIMAL(18,2);
DEFINE dPorcRechazadas		DECIMAL(18,2);
DEFINE dPorcAutorizados	    DECIMAL(18,2);
DEFINE cDescripcion 		CHAR(25);
DEFINE cNombre				CHAR(45);
DEFINE cBandera 			CHAR(1);
DEFINE iCanceladas			INTEGER;
DEFINE iAutorizadas	     	INTEGER;
DEFINE iRechazadas		    INTEGER;
DEFINE cEjecutivo           CHAR(8);
DEFINE cPuesto 				CHAR(2);
DEFINE cRangoAutorizacion	CHAR(2);
DEFINE iTotalReg 			INTEGER;
DEFINE iTotalPerfil			INTEGER;

DEFINE dTotalPorcAtendidas		DECIMAL(18,2);	
DEFINE dTotalPorcCanceladas		DECIMAL(18,2);
DEFINE dTotalPorcRechazadas		DECIMAL(18,2);
DEFINE dTotalPorcAutorizados	    DECIMAL(18,2);

DEFINE iTotalTotalPerfil			INTEGER;
DEFINE iTotalCanceladas			INTEGER;
DEFINE iTotalAutorizadas	     	INTEGER;
DEFINE iTotalRechazadas		    INTEGER;
---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Se realizó la consulta correctamente";
LET dPorcAtendidas		     = 0;
LET dPorcCanceladas		     = 0;
LET dPorcRechazadas		     = 0;
LET dPorcAutorizados	     = 0;
LET iCanceladas		     	 = 0;
LET iAutorizadas	     	 = 0;
LET iRechazadas		     	 = 0;
LET cEjecutivo				 = "";
LET cPuesto 				 = "";
LET cRangoAutorizacion		 = "";
LET iTotalReg				 = 0;
LET cDescripcion			 = "";
LET cNombre 				 = "";
LET cBandera				 = "";
LET iTotalPerfil			 = 0;

LET dTotalPorcAtendidas		     = 0;
LET dTotalPorcCanceladas		     = 0;
LET dTotalPorcRechazadas		     = 0;
LET dTotalPorcAutorizados	     = 0;

LET iTotalTotalPerfil			 = 0;
LET iTotalCanceladas		     	 = 0;
LET iTotalAutorizadas	     	 = 0;
LET iTotalRechazadas		     	 = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
    LET cCodRet= iSqlErr;
	LET cMensajeRet=cErrorInfo;	 
	
	
       RETURN cCodRet, cMensajeRet, NVL(cEjecutivo,' '), NVL(cNombre,' '), NVL(cDescripcion,' '), NVL(iTotalPerfil,0), NVL(dPorcAtendidas,0), NVL(iCanceladas,0), NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
   END IF;
END EXCEPTION;

	--set debug file to "/informix/jesus/sp_cac_rep_perfil_usuario.out";
	--trace on;

--se validan los parametros de entrada.
IF NVL(pFechaini,"") = "" OR NVL(pFechaFin,"")="" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "Falta un parámetro de fecha requerido para realizar  la consulta";
	RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
END IF;



SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
----se obtiene el total de registros de solicitudes atendidas.
	
		
	SELECT COUNT( b.num_solicitud) --total atendidas 
	INTO iTotalReg
	FROM  bdicred:"informix".sd_historica_cac_aumlincred h ,
	bdicred:"informix".sd_bitacora_aumlincred b			  
	WHERE  h.empresa = b.empresa 
	AND h.solicitud  = b.num_solicitud
	AND h.fecha_insert between  b.fecha_insert and b.fecha_status
	AND b.fecha_insert >= pFechaIni
	AND b.fecha_insert <= pFechaFin
	AND b.origen = "S";
	
	
	IF iTotalReg = 0 THEN
		LET cCodRet = "000003";
		LET cMensajeRet =  "No hay información con el rango de fechas solicitado";		
		RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
			NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
	END IF;	
	--Ciclo para obtener la cantidad de solicitudes atendidas por puesto y ejecutivo
	FOREACH WITH HOLD	
		--SELECT {+INDEX(bdicred:"informix".sd_historica_cac_aumlincred idx1_sd_historica_cac_aumlincred)} skip pInicio limit pFin h.puesto,h.ejecutivo,COUNT( b.num_solicitud), --total atendidas por usuario	
		SELECT {+INDEX(bdicred:"informix".sd_historica_cac_aumlincred idx1_sd_historica_cac_aumlincred)} h.puesto,h.ejecutivo,COUNT( b.num_solicitud), --total atendidas por usuario	
		SUM(CASE WHEN b.status='CM' THEN 1 ELSE 0 END),--Canceladas
		SUM(CASE WHEN b.status='RT' THEN 1 ELSE 0 END),--Rechazadas
		SUM(CASE WHEN b.status in ('AT','AP','IN') THEN 1 ELSE 0 END)--Autorizadas
		INTO cPuesto,cEjecutivo,iTotalPerfil,iCanceladas,iRechazadas,iAutorizadas
		FROM bdicred:"informix".sd_bitacora_aumlincred b, bdicred:"informix".sd_historica_cac_aumlincred h
		WHERE  h.empresa = b.empresa 
		AND h.solicitud  = b.num_solicitud
		AND h.fecha_insert between  b.fecha_insert and b.fecha_status
		AND b.fecha_insert >= pFechaIni
		AND b.fecha_insert <= pFechaFin
		AND b.origen = "S"
		GROUP BY h.puesto,h.ejecutivo
		ORDER BY h.puesto,h.ejecutivo
		
			
			LET dPorcCanceladas	=0;
			LET dPorcRechazadas	=0;
			LET dPorcAutorizados=0;
			LET dPorcAtendidas  =0;
			
			--Se obtiene el nombre del ejecutivo
			SELECT nombre
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo=cEjecutivo;
			--Se obtiene la descripcion del puesto del ejecutivo
			SELECT descripcion_puesto
			INTO cDescripcion
			FROM bdicred:"informix".sd_puestos_cac_aumlincred
			WHERE puesto=cPuesto;
			
			--Calculo para obtener los porcentajes de las solicitudes atendidas,  canceladas, rechazadas y autorizadas. 
			IF NVL(iTotalPerfil,0) <> 0 THEN
			LET dPorcAtendidas = ((iTotalPerfil * 100) / iTotalReg);
			--Total
			LET iTotalTotalPerfil = iTotalTotalPerfil + iTotalPerfil;
			
			END IF;
			IF NVL(iCanceladas,0) <> 0 THEN
				LET dPorcCanceladas = ((iCanceladas * 100) / iTotalPerfil);
				--Total
				LET iTotalCanceladas = iTotalCanceladas + iCanceladas;
				
			END IF;
			IF NVL(iRechazadas,0) <> 0 THEN
				LET dPorcRechazadas	= ((iRechazadas * 100) / iTotalPerfil);
				--Total
				LET iTotalRechazadas = iTotalRechazadas + iRechazadas;
				
			END IF;
			IF NVL(iAutorizadas,0) <> 0 THEN
				LET dPorcAutorizados =((iAutorizadas * 100) / iTotalPerfil);
				--Total
				LET iTotalAutorizadas = iTotalAutorizadas + iAutorizadas;
				
			END IF;			
			
			
			LET dTotalPorcAtendidas = ((iTotalTotalPerfil * 100) / iTotalTotalPerfil); 
			LET dTotalPorcCanceladas = ((iTotalCanceladas * 100) / iTotalTotalPerfil);
			LET dTotalPorcRechazadas = ((iTotalRechazadas * 100) / iTotalTotalPerfil); 
			LET dTotalPorcAutorizados = ((iTotalAutorizadas * 100) / iTotalTotalPerfil);
			
			RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
				NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0) WITH RESUME;
		
	END FOREACH;	
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros para el reporte por perfil de usuario en un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111021.0902',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agregan los totales de las atendidas, autorizadas, canceladas y rechazadas',
'Fecha de modificación: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Modificación: Se clona spl y se modifica para eliminar paginado de recuperación de información',
'Fecha de modificación: 30/07/2019',
'Modificó: Rodolfo Conde Flores',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_revisioncac3(pFechaIni CHAR (10), pFechaFin CHAR(10))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  INTEGER  AS tiene_causa,
		  CHAR(100) AS descripcion,
		  INTEGER AS totalRegCentral,
		  DECIMAL(18,2) AS porcentajeCentral,
		  INTEGER AS totalCentral,
		  DECIMAL(18,2) AS totPorCentral,
		  INTEGER AS totalRegSucursal,
		  DECIMAL(18,2) AS porcentajeSucursal,
		  INTEGER AS totalSucursal,
		  DECIMAL(18,2) AS totPorSucursal;
		  
		
---DECLARACIONES   
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);
DEFINE cComentario           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);

DEFINE dPorcStatusSuc		DECIMAL(18,2);
DEFINE dPorcStatusCen		DECIMAL(18,2);
DEFINE dPorcStatus			DECIMAL(18,2);
DEFINE dPorcStatusAcum		DECIMAL(18,2);
DEFINE dPorcStatusAcum2		DECIMAL(18,2);
DEFINE cStatus 				CHAR(2);
DEFINE cCausa 				CHAR(3);
DEFINE cDescripcion 		VARCHAR(100);
DEFINE cBandera 			CHAR(1);
DEFINE cOrigen				CHAR(1);
DEFINE iTotalStatus 		INTEGER;
DEFINE iTotal 				INTEGER;
DEFINE iTotalRegistros 		INTEGER;
DEFINE iTotalStatusSuc		INTEGER;
DEFINE iTotalStatusCen		INTEGER;
DEFINE iTieneCausa 			INTEGER;
DEFINE iCont 				INTEGER;
DEFINE dPorSucursal         DECIMAL(18,2);
DEFINE dPorCentral          DECIMAL(18,2);
DEFINE iTotalReg 			INTEGER;
DEFINE iTotalCentral         DECIMAL(18,2);
DEFINE iTotalSucursal        DECIMAL(18,2);
DEFINE dporCasoSucursal       DECIMAL(18,2);
DEFINE dporCasoCentral       DECIMAL(18,2);

---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "SE REALIZA LA CONSULTA CORRECTAMENTE";
LET dPorcStatusSuc			 = 0;
LET dPorcStatusCen			 = 0;
LET dPorcStatus			     = 0;
LET dPorcStatusAcum		     = 0;
LET dPorcStatusAcum2	     = 100;
LET iTotalStatus			 = 0;
LET iTotal			         = 0;
LET iTotalRegistros			 = 0;
LET iTotalStatusCen			 = 0;
LET iTotalStatusSuc			 = 0;
LET iTieneCausa				 = 0;
LET iCont					 = 0;
LET iTotalReg				 = 0;
LET cDescripcion			 = "";
LET cBandera				 = "";
LET cOrigen 				 = "";
LET cStatus 				 = "";
LET cCausa 					 = "";
LET dPorSucursal             = 0;
LET dPorCentral              = 0;
LET iTotalCentral            = 0;
LET iTotalSucursal           = 0;
LET dporCasoSucursal         = 0;
LET dporCasoCentral          = 0;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
    LET cCodRet= iSqlErr;
	LET cMensajeRet=cErrorInfo;
	 IF iSqlErr IN (-1204,-1205,-1206) THEN
		LET cCodRet = "000002";
		LET cMensajeRet = "PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA";
	 END IF;	 
	 IF  cBandera = "S" THEN
		 DROP TABLE tme_consultaincrementos;
	 END IF;
       RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalStatusCen, 0), NVL(dPorcStatusCen, 0), NVL(iTotalCentral, 0), NVL(dporCasoCentral, 0),
			NVL(iTotalStatusSuc, 0),NVL(dPorcStatusSuc, 0), NVL(iTotalSucursal, 0), NVL(dPorCasoSucursal, 0);
   END IF;
END EXCEPTION;

	--SET debug FILE TO "/informix/jesus/sp_cac_rep_revisioncac.out";
	--trace ON;

--se validan los parametros de entrada.
IF NVL(pFechaini,"") = "" OR NVL(pFechaFin,"")="" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "FALTA PARAMETRO DE FECHA REQUERIDO PARA REALIZAR  LA CONSULTA";
	RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalStatusCen, 0), NVL(dPorcStatusCen, 0), NVL(iTotalCentral, 0), NVL(dporCasoCentral, 0),
			NVL(iTotalStatusSuc, 0),NVL(dPorcStatusSuc, 0), NVL(iTotalSucursal, 0), NVL(dPorCasoSucursal, 0);
END IF;
-- Crear una tabla temporal para insertar los datos de la consulta	
IF EXISTS (SELECT tabname FROM systables  WHERE tabname = 'tme_consultaincrementos') THEN	
    DROP TABLE tme_consultaincrementos;
END IF;

-- Se crea la tabla de trabajo
CREATE TEMP TABLE tme_consultaincrementos
    (
		status CHAR(2),
		causa	CHAR(3),
		descripcion  CHAR(100),
		totalRegCentral INTEGER,
		porcentajeCentral  DECIMAL(18,2),
		totalcentral    INTEGER,
		porCentral		DECIMAL(18,2),
		totalRegSucursal INTEGER,
		porcentajeSucursal DECIMAL(18,2),
		totalSucursal  INTEGER,
		porSucursal	DECIMAL(18,2)
		
    )WITH NO LOG;	
	
	LET cBandera = "S";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
 
 FOREACH WITH HOLD
 
	 SELECT origen 
	 INTO cOrigen
	 FROM "informix".sd_aumlincred_origen
	 ORDER by  origen 
	 
	 IF cOrigen='C' THEN	 
		----se insertan el total de registros por estatus
			FOREACH WITH HOLD
				SELECT status,TRIM(descripcion)
					INTO cStatus,cDescripcion
				FROM  "informix".sd_status_aumlincred 
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
				    INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen = cOrigen
					AND status = cStatus			
			
						INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegCentral,porcentajeCentral,totalRegSucursal,porcentajeSucursal)
						VALUES(cStatus,'',cDescripcion,NVL(iTotalStatus,0),0,0,0);	 
			
				END FOREACH;  	
			END FOREACH;
		--se obtiene el total de los registros para esta consulta	
				SELECT NVL(SUM(totalRegCentral),0), COUNT(status)
					INTO iTotal,iTotalReg
				FROM  tme_consultaincrementos 
				WHERE status=status
				AND causa = ""
				AND totalRegCentral <>0;
				
				LET iTotalRegistros = iTotal;
					
				IF iTotalReg <> 0 THEN
					--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
					FOREACH
						SELECT status,descripcion,totalRegCentral
							INTO cStatus, cDescripcion,iTotalStatus
						FROM  tme_consultaincrementos
						WHERE status=status
						AND causa = ""
						AND totalRegCentral <>0	
						
							LET dPorcStatus    = ((iTotalStatus * 100) / iTotal);
							IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
								LET iCont= iCont + 1;
								IF iTotalReg = iCont THEN
									LET dPorcStatus= 100 - dPorcStatusAcum;
								END IF;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							ELSE
								LET iCont= iCont + 1;
								LET dPorcStatus= 100 - dPorcStatusAcum;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							END IF;
								
						UPDATE tme_consultaincrementos
							SET porcentajeCentral = dPorcStatus
						WHERE status=cStatus;
				    END FOREACH;
				END IF;
		---se insertan el total de registros por causas
			FOREACH WITH HOLD
				SELECT status,causa_status,TRIM(descripcion)
				  INTO cStatus,cCausa,cDescripcion
				  FROM  "informix".sd_causas_aumlincred 
                 WHERE mostrar_pantalla = "1"
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
						INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen =cOrigen
					AND status=cStatus
					AND causa_status=cCausa
		
						INSERT INTO tme_consultaincrementos (status,causa,descripcion,totalRegCentral,porcentajeCentral,totalRegSucursal,porcentajeSucursal)	
						VALUES(cStatus,cCausa,cDescripcion,NVL(iTotalStatus,0),0,0,0);	
				 
				END FOREACH;  		
			END FOREACH;	
			--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
			LET dPorcStatusAcum=0;
			LET dPorcStatus=0;
			LET iCont=0;

			FOREACH WITH HOLD
					SELECT status,causa_status
                      INTO cStatus,cCausa
					  FROM  "informix".sd_causas_aumlincred
					 WHERE mostrar_pantalla = "1"					
					ORDER BY status,causa_status
							
							SELECT NVL(SUM(totalRegCentral),0), COUNT(causa)
								INTO iTotal,iTotalReg
							FROM  tme_consultaincrementos 
							WHERE status=cStatus
							AND causa <> ""
							AND totalRegCentral <>0;
							
							SELECT porcentajeCentral
								INTO dPorCentral
							FROM  tme_consultaincrementos 
							WHERE status=cStatus
							AND causa = ""
							AND totalRegCentral <>0;
							
						IF iTotalReg <> 0 THEN			
								SELECT status,causa,descripcion,totalRegCentral
									INTO cStatus,cCausa,cDescripcion,iTotalStatus
								FROM  tme_consultaincrementos
								WHERE status = cStatus
								AND causa = cCausa
								AND totalRegCentral <>0;
								
							   IF NVL(iTotalStatus,0) <> 0 THEN
									LET dPorcStatus    = ((iTotalStatus * dPorCentral) / iTotal);
									IF (dPorcStatusAcum + dPorcStatus) < dPorCentral THEN
										LET iCont= iCont + 1;
										IF iTotalReg = iCont THEN
											LET dPorcStatus= dPorCentral - dPorcStatusAcum;							
										END IF;
										LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
									ELSE
										LET iCont= iCont + 1;
										LET dPorcStatus= dPorCentral - dPorcStatusAcum;
										LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
									END IF;
										
								UPDATE tme_consultaincrementos
									SET porcentajeCentral = dPorcStatus
								WHERE status=cStatus
								AND causa=cCausa;	
							   END IF;
						END IF;
					
					IF iTotalReg = iCont THEN
						LET dPorcStatusAcum=0;
						LET dPorcStatus=0;
						LET iCont=0;
					END IF;		
			END FOREACH;
	ELSE 
		LET dPorcStatus= 0;
		IF cOrigen='S' THEN
			FOREACH WITH HOLD
				SELECT status,TRIM(descripcion)
					INTO cStatus,cDescripcion
				FROM  "informix".sd_status_aumlincred 
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
						INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen =cOrigen
					AND status=cStatus			
					
						UPDATE tme_consultaincrementos 
						SET totalRegSucursal=iTotalStatus 
						WHERE status=cStatus 
						AND causa='' 
						AND descripcion=cDescripcion;			
						
				END FOREACH;  	
			END FOREACH;
		--se obtiene el total de los registros para esta consulta	
				SELECT NVL(SUM(totalRegSucursal),0), COUNT(status)
					INTO iTotal,iTotalReg
				FROM  tme_consultaincrementos 
				WHERE status=status
				AND causa = ""
				AND totalRegSucursal <>0;
				
				LET iTotalRegistros = iTotal;
					
				IF iTotalReg <> 0 THEN
					--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
					FOREACH
						SELECT status,descripcion,totalRegSucursal
							INTO cStatus, cDescripcion,iTotalStatus
						FROM  tme_consultaincrementos
						WHERE status=status
						AND causa = ""
						AND totalRegSucursal <>0	
						
							LET dPorcStatus    = ((iTotalStatus * 100) / iTotal);
							IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
								LET iCont= iCont + 1;
								IF iTotalReg = iCont THEN
									LET dPorcStatus= 100 - dPorcStatusAcum;
								END IF;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							ELSE
								LET iCont= iCont + 1;
								LET dPorcStatus= 100 - dPorcStatusAcum;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							END IF;
								
						UPDATE tme_consultaincrementos
							SET porcentajeSucursal = dPorcStatus
						WHERE status=cStatus;
				    END FOREACH;
					LET dPorcStatus= 0;
					LET dPorcStatusAcum = 0;
--				ELSE 
--					LET dPorcStatus= 0;
--					LET dPorcStatusAcum = 0;
				END IF;
		---se insertan el total de registros por causas
			FOREACH WITH HOLD
				SELECT status,causa_status,TRIM(descripcion)
				  INTO cStatus,cCausa,cDescripcion
				  FROM "informix".sd_causas_aumlincred
		         WHERE mostrar_pantalla = "1"				
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
						INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen =cOrigen
					AND status=cStatus
					AND causa_status=cCausa
				
						UPDATE tme_consultaincrementos 
						SET causa = cCausa, totalRegSucursal = iTotalStatus, porcentajeSucursal = 0 
						WHERE status=cStatus 
						AND descripcion=cDescripcion;
				 
				END FOREACH;  
				LET dPorcStatus= 0;	
				LET dPorcStatusAcum = 0;				
			END FOREACH;	
			 LET dPorcStatus= 0;
			 LET dPorcStatusAcum = 0;
		--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
		LET dPorcStatusAcum=0;
		LET dPorcStatus=0;
		LET iCont=0;
		LET dPorSucursal = 0;
	
		FOREACH WITH HOLD
					SELECT status,causa_status
					  INTO cStatus,cCausa
					  FROM "informix".sd_causas_aumlincred
		             WHERE mostrar_pantalla = "1"					
					ORDER BY status,causa_status
					
							SELECT NVL(SUM(totalRegSucursal),0), COUNT(causa)
								INTO iTotal,iTotalReg
							FROM  tme_consultaincrementos 
							WHERE status=cStatus
							AND causa <> ""
							AND totalRegSucursal <>0;
							
							SELECT porcentajeSucursal
								INTO dPorSucursal 
							FROM  tme_consultaincrementos 
							WHERE status=cStatus
							AND causa = ""
							AND totalRegSucursal <>0;
							
						IF iTotalReg <> 0 THEN			
								SELECT status,causa,descripcion,totalRegSucursal
									INTO cStatus,cCausa,cDescripcion,iTotalStatus
								FROM  tme_consultaincrementos
								WHERE status = cStatus
								AND causa = cCausa
								AND totalRegSucursal <>0;
								
							   IF NVL(iTotalStatus,0) <> 0 THEN
									LET dPorcStatus    = ((iTotalStatus * dPorSucursal) / iTotal);
									IF (dPorcStatusAcum + dPorcStatus) < dPorSucursal THEN
										LET iCont= iCont + 1;
										IF iTotalReg = iCont THEN
											LET dPorcStatus= dPorSucursal - dPorcStatusAcum;							
										END IF;
										LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
									ELSE
										LET iCont= iCont + 1;
										LET dPorcStatus= dPorSucursal - dPorcStatusAcum;
										LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
									END IF;
										
								UPDATE tme_consultaincrementos
									SET porcentajeSucursal = dPorcStatus
								WHERE status=cStatus
								AND causa=cCausa;	
							   END IF;

						END IF;			
					
					IF iTotalReg = iCont THEN
						LET dPorcStatusAcum=0;
						LET dPorcStatus=0;
						LET iCont=0;
					END IF;		
			END FOREACH;		
			LET dPorcStatus= 0;
		END IF;
	END IF;
END FOREACH;
--Se obtienen totales de ambos casos y se guardan en la tabla
FOREACH
	SELECT SUM(totalRegCentral),SUM(totalRegSucursal),SUM(porcentajeCentral), SUM(porcentajeSucursal)
		INTO iTotalStatusCen, iTotalStatusSuc, dporCasoCentral, dPorCasoSucursal
	FROM  tme_consultaincrementos
	WHERE causa=""

	UPDATE tme_consultaincrementos
	SET totalCentral = iTotalStatusCen,
		porCentral = dporCasoCentral,
		totalSucursal = iTotalStatusSuc,
		porSucursal = dPorCasoSucursal;	 

END FOREACH;

--se obtiene los datos de la tabla
FOREACH
	--SELECT skip pInicio limit pFin status,causa,descripcion,totalRegCentral,porcentajeCentral,totalCentral,porCentral,totalRegSucursal,porcentajeSucursal, totalSucursal,porSucursal
	SELECT status,causa,descripcion,totalRegCentral,porcentajeCentral,totalCentral,porCentral,totalRegSucursal,porcentajeSucursal, totalSucursal,porSucursal
		INTO cStatus,cCausa,cDescripcion,iTotalStatusCen,dPorcStatusCen,iTotalCentral, dporCasoCentral, iTotalStatusSuc,dPorcStatusSuc, iTotalSucursal, dPorCasoSucursal
	FROM  tme_consultaincrementos
	ORDER BY status,causa

	IF NVL(cCausa,"") <> "" THEN
		LET iTieneCausa=1;
		LET  cDescripcion = TRIM (cCausa) || '-' || TRIM (cDescripcion);
	ELSE
		LET iTieneCausa=0;
	END IF;

	RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalStatusCen, 0), NVL(dPorcStatusCen, 0), NVL(iTotalCentral, 0), NVL(dporCasoCentral, 0),
			NVL(iTotalStatusSuc, 0),NVL(dPorcStatusSuc, 0), NVL(iTotalSucursal, 0), NVL(dPorCasoSucursal, 0) WITH RESUME;
END FOREACH;
	
	IF  cBandera = "S" THEN
		DROP TABLE tme_consultaincrementos;
	END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111019.1402',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: JosuÃ?Â© Remberto Zazueta Acosta',
'ModificaciÃ?Â³n: Se borra cÃ?Â³digo comentado,se agregan informix y bd a las tablas que no tenÃ?Â­an,Se implementan reglas', 'de informix',
'Fecha de modificaciÃ?Â³n: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Modificación: Se clona spl y se modifica para eliminar paginado de recuperación de información',
'Fecha de modificación: 30/07/2019',
'Modificó: Rodolfo Conde Flores',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_revisioncentral3(pFechaIni CHAR (10), pFechaFin CHAR(10))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  INTEGER  AS tiene_causa,
		  CHAR(100) AS descripcion,
		  INTEGER AS totalRegCasosCac,
		  DECIMAL(18,2) AS porcentajeCasosCac,
	      INTEGER AS totCAC,
		  DECIMAL(18,2) AS porCAC,
		  INTEGER AS totalRegCasosAuto,
		  DECIMAL(18,2) AS porcentajeCasosAuto,
		  INTEGER AS totAUTO,
		  DECIMAL(18,2) AS porAUTO;
---DECLARACIONES
DEFINE cCodRet               CHAR(6);
DEFINE cMensajeRet           CHAR(80);
DEFINE cComentario           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);

DEFINE dPorcCasosCac		DECIMAL(18,2);
DEFINE dPorcCasosAuto		DECIMAL(18,2);
DEFINE dPorcStatus			DECIMAL(18,2);
DEFINE dPorcStatusAcum		DECIMAL(18,2);
DEFINE dPorcStatusAcum2		DECIMAL(18,2);
DEFINE dPorcenStatus		DECIMAL(18,2);
DEFINE cStatus 				CHAR(2);
DEFINE cCausa 				CHAR(3);
DEFINE cDescripcion 		VARCHAR(100);
DEFINE cBandera 			CHAR(1);
DEFINE cOrigen				CHAR(1);
DEFINE iTotalStatus 		INTEGER;
DEFINE iTotal 				INTEGER;
DEFINE iTotalRegistros 		INTEGER;
DEFINE iTotalCasosCac		INTEGER;
DEFINE iTotalCasosAuto		INTEGER;
DEFINE iTieneCausa 			INTEGER;
DEFINE iCont 				INTEGER;
DEFINE iTotalReg 			INTEGER;
DEFINE dtFecha 				DATE;
DEFINE itotalCAC            INTEGER;
DEFINE itotalAUTO           INTEGER;
DEFINE dporCAC              DECIMAL(18,2);
DEFINE dporAUTO             DECIMAL(18,2);

---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Se realizó la consulta correctamente";
LET dPorcCasosCac			 = 0;
LET dPorcCasosAuto			 = 0;
LET dPorcStatus			     = 0;
LET dPorcStatusAcum		     = 0;
LET dPorcStatusAcum2	     = 100;
LET dPorcenStatus			 = 0;
LET iTotalStatus			 = 0;
LET iTotal			         = 0;
LET iTotalRegistros			 = 0;
LET iTotalCasosCac			 = 0;
LET iTotalCasosAuto			 = 0;
LET iTieneCausa				 = 0;
LET iCont					 = 0;
LET iTotalReg				 = 0;
LET cDescripcion			 = "";
LET cBandera				 = "";
LET cOrigen 				 = "";
LET cStatus 				 = "";
LET cCausa 					 = "";
LET itotalCAC                = 0;
LET itotalAUTO               = 0;
LET dporCAC                  = 0;
LEt dporAUTO                 = 0;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
    LET cCodRet= iSqlErr;
	LET cMensajeRet=cErrorInfo;
	 IF iSqlErr IN (-1204,-1205,-1206) THEN
		LET cCodRet = "000002";
		LET cMensajeRet = "Parámetro de fecha invalido para realizar  la consulta";
	 END IF;
	 IF  cBandera = "S" THEN
		 DROP TABLE tme_consultaincrementos;
	 END IF;
       RETURN cCodRet, cMensajeRet,0,'',0,0,0 ,0,0,0,0,0;
   END IF;
END EXCEPTION;

	--set debug file to "/informix/jesus/sp_cac_rep_revisioncentral.out";
	--trace on;

--se validan los parametros de entrada.
IF NVL(pFechaIni,"") = ""  OR NVL(pFechaFin,"") = "" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "Falta parámetro de fechas requerido para realizar la consulta";
	RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalCasosCac, 0), NVL(dPorcCasosCac, 0), NVL(itotalCAC, 0),NVL(dporCAC, 0),
				NVL(iTotalCasosAuto, 0),NVL(dPorcCasosAuto, 0), NVL(itotalAUTO, 0), NVL(dporAUTO, 0);

END IF;

-- Crear una tabla temporal para insertar los datos de la consulta
IF EXISTS (SELECT tabname FROM systables  WHERE tabname = 'tme_consultaincrementos') THEN
    DROP TABLE tme_consultaincrementos;
END IF;

-- Se crea la tabla de trabajo
CREATE TEMP TABLE tme_consultaincrementos
    (
		status CHAR(2),
		causa	CHAR(3),
		descripcion  CHAR(100),
		totalRegCac INTEGER,
		porcentajeCac  DECIMAL(18,2),
		totalCAC INTEGER,
		porCAC   DECIMAL(18,2),
		totalRegAuto INTEGER,
		porcentajeAuto DECIMAL(18,2),
		totalAUTO INTEGER,
		porAUTO   DECIMAL(18,2)
    )WITH NO LOG;

	LET cBandera = "S";
	LET cOrigen ="C";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--Se obtienen los datos referentes a las solicitudes que requieren revision CAC (Casos CAC)
----se insertan el total de registros por estatus
	FOREACH WITH HOLD
		SELECT status,TRIM(descripcion)
			INTO cStatus,cDescripcion
		FROM  "informix".sd_status_aumlincred

		FOREACH WITH HOLD
			SELECT COUNT(status)
				INTO iTotalStatus
			FROM  "informix".sd_bitacora_aumlincred
			WHERE fecha_insert>=pFechaIni
			AND fecha_insert<=pFechaFin
			AND origen=cOrigen
			AND status=cStatus
			AND revisioncac=1

				INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegCac,porcentajeCac,totalRegAuto,porcentajeAuto)
				VALUES(cStatus,'',cDescripcion,NVL(iTotalStatus,0),0,0,0);

		END FOREACH;
	END FOREACH;
--se obtiene el total de los registros para esta consulta
		SELECT NVL(SUM(totalRegCac),0), COUNT(status)
			INTO iTotal,iTotalReg
		FROM  tme_consultaincrementos
		WHERE status=status
		AND causa = ""
		AND totalRegCac <>0;

		LET iTotalRegistros = iTotal;

		IF iTotalReg <> 0 THEN
			--se realiza el calculo del porcentaje por cada status del total de registros de la consulta
			FOREACH
				SELECT status,descripcion,totalRegCac
					INTO cStatus, cDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status=status
				AND causa = ""
				AND totalRegCac <>0

					LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);
					IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
						LET iCont= iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus= 100 - dPorcStatusAcum;
						END IF;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					ELSE
						LET iCont= iCont + 1;
						LET dPorcStatus= 100 - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					END IF;

				UPDATE tme_consultaincrementos
					SET porcentajeCac = dPorcStatus
				WHERE status=cStatus
				AND causa="";
			END FOREACH;
		END IF;
---se insertan el total de registros por causas
	FOREACH WITH HOLD
		SELECT status,causa_status,TRIM(descripcion)
		  INTO cStatus,cCausa,cDescripcion
		  FROM "informix".sd_causas_aumlincred
		 WHERE mostrar_pantalla = "1"

		FOREACH WITH HOLD
			SELECT COUNT(status)
				INTO iTotalStatus
			FROM  "informix".sd_bitacora_aumlincred
			WHERE fecha_insert>=pFechaIni
			AND fecha_insert<=pFechaFin
			AND origen=cOrigen
			AND status=cStatus
			AND causa_status=cCausa
			AND revisioncac=1

						INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegCac,porcentajeCac,totalRegAuto,porcentajeAuto)
						VALUES(cStatus,cCausa,cDescripcion,NVL(iTotalStatus,0),0,0,0);

		END FOREACH;
	END FOREACH;
	--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status
	LET dPorcStatusAcum=0;
	LET dPorcStatus=0;
	LET iCont=0;

	FOREACH WITH HOLD
			SELECT status,causa_status
				INTO cStatus,cCausa
			FROM  "informix".sd_causas_aumlincred
			WHERE mostrar_pantalla = "1"
			ORDER BY status,causa_status

					SELECT NVL(SUM(totalRegCac),0), COUNT(causa)
						INTO iTotal,iTotalReg
					FROM  tme_consultaincrementos
					WHERE status=cStatus
					AND causa <> ""
					AND totalRegCac <>0;

				IF iTotalReg <> 0 THEN
						SELECT status,causa,descripcion,totalRegCac
							INTO cStatus,cCausa,cDescripcion,iTotalStatus
						FROM  tme_consultaincrementos
						WHERE status = cStatus
						AND causa = cCausa
						AND totalRegCac <>0;

					   IF NVL(iTotalStatus,0) <> 0 THEN
							LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);
						UPDATE tme_consultaincrementos
							SET porcentajeCac = dPorcStatus
						WHERE status=cStatus
						AND causa=cCausa;
					   END IF;
				END IF;

			IF iTotalReg = iCont THEN
				LET dPorcStatusAcum=0;
				LET dPorcStatus=0;
				LET iCont=0;
			END IF;
	END FOREACH;
--Se obtienen los datos referentes a las solicitudes que no requieren revision Cac (Casos Automaticos)
----se insertan el total de registros por estatus
	FOREACH WITH HOLD
		SELECT status,TRIM(descripcion)
			INTO cStatus,cDescripcion
		FROM  "informix".sd_status_aumlincred

		FOREACH WITH HOLD
			SELECT COUNT(status)
				INTO iTotalStatus
			FROM  "informix".sd_bitacora_aumlincred
			WHERE fecha_insert>=pFechaIni
			AND fecha_insert<=pFechaFin
			AND origen=cOrigen
			AND status=cStatus
			AND revisioncac=0

				UPDATE tme_consultaincrementos
				SET totalRegAuto=iTotalStatus
				WHERE status=cStatus
				AND descripcion=cDescripcion;


		END FOREACH;
	END FOREACH;
--se obtiene el total de los registros para esta consulta
		SELECT NVL(SUM(totalRegAuto),0), COUNT(status)
			INTO iTotal,iTotalReg
		FROM  tme_consultaincrementos
		WHERE status=status
		AND causa = ""
		AND totalRegAuto <>0;

		LET iTotalRegistros = iTotal;

		IF iTotalReg <> 0 THEN
			--se realiza el calculo del porcentaje por cada status del total de registros de la consulta
			FOREACH
				SELECT status,descripcion,totalRegAuto
					INTO cStatus, cDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status=status
				AND causa = ""
				AND totalRegAuto <>0

					LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);
					IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
						LET iCont= iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus= 100 - dPorcStatusAcum;
						END IF;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					ELSE
						LET iCont= iCont + 1;
						LET dPorcStatus= 100 - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					END IF;

				UPDATE tme_consultaincrementos
					SET porcentajeAuto = dPorcStatus
				WHERE status=cStatus
				AND causa="";
			END FOREACH;
		END IF;
---se insertan el total de registros por causas
	FOREACH WITH HOLD
		SELECT status,causa_status,TRIM(descripcion)
			INTO cStatus,cCausa,cDescripcion
		FROM  "informix".sd_causas_aumlincred
		WHERE mostrar_pantalla = "1"

		FOREACH WITH HOLD
			SELECT COUNT(status)
				INTO iTotalStatus
			FROM  "informix".sd_bitacora_aumlincred
			WHERE fecha_insert>=pFechaIni
			AND fecha_insert<=pFechaFin
			AND origen=cOrigen
			AND status=cStatus
			AND causa_status = cCausa
			AND RevisionCac=0

				UPDATE tme_consultaincrementos
				SET totalRegAuto=iTotalStatus
				WHERE status=cStatus
				AND causa=cCausa
				AND descripcion=cDescripcion;

		END FOREACH;
	END FOREACH;
	--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status
	LET dPorcStatusAcum=0;
	LET dPorcStatus=0;
	LET iCont=0;

	FOREACH WITH HOLD
			SELECT status,causa_status
				INTO cStatus,cCausa
			FROM  "informix".sd_causas_aumlincred
			WHERE mostrar_pantalla = "1"
			ORDER BY status,causa_status

					SELECT NVL(SUM(totalRegAuto),0), COUNT(causa)
						INTO iTotal,iTotalReg
					FROM  tme_consultaincrementos
					WHERE status=cStatus
					AND causa <> ""
					AND totalRegAuto <>0;

				IF iTotalReg <> 0 THEN
					--Se obtiene porcentaje del estatus
					SELECT porcentajeAuto
					INTO dPorcenStatus
					FROM tme_consultaincrementos
					WHERE status = cStatus
					AND causa = ""
					AND porcentajeAuto <>0;
					-- Se obtiene el total de registros de status por su causa
						SELECT status,causa,descripcion,totalRegAuto
							INTO cStatus,cCausa,cDescripcion,iTotalStatus
						FROM  tme_consultaincrementos
						WHERE status = cStatus
						AND causa = cCausa
						AND totalRegAuto <>0;

					   IF NVL(iTotalStatus,0) <> 0 THEN
							LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);
							IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
								LET iCont= iCont + 1;
								IF iTotalReg = iCont THEN
									LET dPorcStatus= dPorcenStatus - dPorcStatusAcum;
								END IF;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							ELSE
								LET iCont= iCont + 1;
								LET dPorcStatus= iTotalStatus - dPorcStatusAcum;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							END IF;
							UPDATE tme_consultaincrementos
								SET porcentajeAuto = dPorcStatus
							WHERE status=cStatus
							AND causa=cCausa;
					   END IF;
				END IF;

			IF iTotalReg = iCont THEN
				LET dPorcStatusAcum=0;
				LET dPorcStatus=0;
				LET iCont=0;
			END IF;
	END FOREACH;

	--Se obtienen totales de ambos casos y se guardan en la tabla
	FOREACH
		SELECT SUM(totalRegCac),SUM(totalRegAuto), SUM(porcentajeCac), SUM (porcentajeAuto)
			INTO iTotalCasosCac, iTotalCasosAuto, dporCAC, dporAUTO
		FROM  tme_consultaincrementos
		WHERE causa=""

			UPDATE tme_consultaincrementos
			SET totalCAC = iTotalCasosCac,
				porCAC = dporCAC,
				totalAUTO = iTotalCasosAuto,
				porAUTO = dporAUTO;

	END FOREACH;


	--se obtiene los datos de la tabla
	FOREACH
		--SELECT skip pInicio limit pFin status,causa,descripcion,totalRegCac,porcentajeCac,totalCAC,porCAC, totalRegAuto,porcentajeAuto, totalAUTO, porAUTO
		SELECT status,causa,descripcion,totalRegCac,porcentajeCac,totalCAC,porCAC, totalRegAuto,porcentajeAuto, totalAUTO, porAUTO
			INTO cStatus,cCausa,cDescripcion,iTotalCasosCac,dPorcCasosCac, itotalCAC, dporCAC, iTotalCasosAuto,dPorcCasosAuto, itotalAUTO, dporAUTO
		FROM  tme_consultaincrementos
		ORDER BY status,causa

		IF NVL(cCausa,"") <> "" THEN
			LET iTieneCausa=1;
			LET  cDescripcion = TRIM (cCausa) || '-' || TRIM (cDescripcion);
		ELSE
			LET iTieneCausa=0;
		END IF;
		 RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalCasosCac, 0), NVL(dPorcCasosCac, 0), NVL(itotalCAC, 0),NVL(dporCAC, 0),
				NVL(iTotalCasosAuto, 0),NVL(dPorcCasosAuto, 0), NVL(itotalAUTO, 0), NVL(dporAUTO, 0) WITH RESUME;
	END FOREACH;


	IF  cBandera = "S" THEN
		DROP TABLE tme_consultaincrementos;
	END IF;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111019.1402',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Modificación: Se clona spl y se modifica para eliminar paginado de recuperación de información',
'Fecha de modificación: 30/07/2019',
'Modificó: Rodolfo Conde Flores',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aut3(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pUsuario CHAR(8), pOrigen CHAR(1))
	RETURNING 		
		CHAR(6)       					AS codigo_retorno,
        CHAR(80)      					AS mensaje_retorno,     
        DATE          					AS fecha_origen,
        VARCHAR(20)   					AS Numero_solicitud,
        CHAR(1)       					AS  Origen,
        VARCHAR(20)   					AS Numero_Cliente,
        VARCHAR(26)   					AS Apell_Paterno,
        VARCHAR(26)   					AS Apell_Materno,
        VARCHAR(53)   					AS Nombre,
        DECIMAL(18,2) 					AS Lincred_actual,
        DECIMAL(18,2) 					AS Lincred_sugerida,
        DECIMAL(18,2) 					AS Incremento,
        CHAR(2)       					AS Status,
        VARCHAR(45)   					AS AnalistaCac,
        VARCHAR(45)   					AS Analista2nivel,
        VARCHAR(45)   					AS Analista3nivel,
        VARCHAR(45)   					AS Analista4nivel,
        VARCHAR(106)  					AS motivo,
        DATE          					AS fecha_ingresoAC,
        DATETIME HOUR TO FRACTION(3) 	AS hora_ingresoAC,
        DATE          					AS fecha_atencion,
        DATETIME HOUR TO FRACTION(3) 	AS hora_atencion,
		CHAR(10)  						AS tipoIncremento;
                          
                          
        ---DECLARACIONES         
        DEFINE cCodRet                  CHAR(6); 
        DEFINE cMensajeRet              CHAR(80);
        DEFINE cComentario              CHAR(80);
        DEFINE iSqlErr                  INTEGER;
        DEFINE iIsamErr                 INTEGER;
        DEFINE iCon                     INTEGER;
        DEFINE cErrorInfo               CHAR(80);

        DEFINE dtFechaOrigen            DATE;
        DEFINE vcNumSol                 VARCHAR(20);    
        DEFINE cOrigen                  CHAR(1);
        DEFINE vcNumCte                 VARCHAR(20);
        DEFINE vcApellPaterno           VARCHAR(26);
        DEFINE vcApellMaterno           VARCHAR(26);
        DEFINE vcNombre                 VARCHAR(53);
        DEFINE dLinCredAct              DECIMAL(18,2);
        DEFINE dLinCredCal              DECIMAL(18,2);
        DEFINE dIncremento              DECIMAL(18,2);
        DEFINE dMontoIncremento         DECIMAL(18,2);
        DEFINE cStatus                  CHAR(2);
        DEFINE vcAnalistaCac            VARCHAR(45);
        DEFINE vcAnalista2nivel         VARCHAR(45);
        DEFINE vcAnalista3nivel         VARCHAR(45);
        DEFINE vcAnalista4nivel         VARCHAR(45);

        DEFINE vcMotivo                 VARCHAR(106);
        DEFINE cCausa                   CHAR(3);
        DEFINE cPuesto                  CHAR(3);
        DEFINE cNomEjecutivo            CHAR(45);
        DEFINE dtFecha                  DATE;
        DEFINE dtFechaIngresoAC     	DATE;
        DEFINE dtFechaIngreso     		DATE;
        DEFINE dtHoraIngresoAC      	DATETIME HOUR TO FRACTION;
        DEFINE dtHoraIngreso      		DATETIME HOUR TO FRACTION;
        DEFINE dtFechaAtencion     		DATE;
        DEFINE dtHoraAtencion      		DATETIME HOUR TO FRACTION;
		
		DEFINE cTpoMovto				CHAR(10);
		
		DEFINE sQuery				CHAR(300);
		DEFINE cUser				CHAR(10);
		
        ---INICIALIZACIONES
        LET iSqlErr                     = 0;
        LET iIsamErr                    = 0;
        LET iCon                        = 0;
        LET cErrorInfo                  = '';
        LET cCodRet                     = '000000';
        LET cMensajeRet                 = 'SE REALIZÃ LA CONSULTA CORRECTAMENTE';

        LET dtFechaOrigen               = DATE(1);
        LET vcNumSol                    = '';   
        LET cOrigen                     = '';
        LET vcNumCte                    = '';
        LET vcApellPaterno              = '';
        LET vcApellMaterno              = '';
        LET vcNombre                    = '';
        LET dLinCredAct                 = 0;
        LET dLinCredCal                 = 0;
        LET dIncremento                 = 0;
        LET dMontoIncremento            = 0;
        LET cStatus                     = '';
        LET vcAnalistaCac               = '';
        LET vcAnalista2nivel            = '';
        LET vcAnalista3nivel            = '';
        LET vcAnalista4nivel            = '';
        LET vcMotivo                    = '';
        LET cCausa                      = '';
        LET cPuesto                     = '';
        LET cNomEjecutivo               = '';
        LET dtFechaIngresoAC     		= DATE(1);
        LET dtHoraIngresoAC      		= CURRENT;
        LET dtFechaAtencion     		= DATE(1);
        LET dtHoraAtencion      		= CURRENT;
        LET cTpoMovto            		= '';
		LET sQuery						= '';
		LET cUser						= '';

        BEGIN

                ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
                        IF iSqlErr != 0 THEN
                                LET cCodRet= iSqlErr;
                                LET cMensajeRet = cErrorInfo;
                                IF iSqlErr IN (-1204,-1205,-1206) THEN
                                        LET cCodRet = '000002';
                                        LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
                                END IF; 
                                RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                       NVL(vcNombre,''),0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,'');       
                        END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO 'sp_consulta_gral_aumlincred_aut3.out';
                --TRACE ON;
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                -- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
                IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
                        LET cCodRet = '000001';
                        LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
                        RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,''); 

                ELSE
                        /*IF pFechaInicial > pFechaFinal THEN
                                LET cCodRet = '000002';
                                LET cMensajeRet = 'LA FECHA INICIAL ES MAYOR A LA FECHA FINAL';
                                RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                           NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT);
                        ELSE*/          
						
                                FOREACH WITH HOLD
                                        SELECT fecha_insert, num_solicitud,origen ,numcte,                                              
                                                lincred_actual,lincred_sugerida,status,causa_status,user_insert                                             
                                        INTO dtFechaOrigen,vcNumSol,cOrigen,vcNumCte, 
                                        dLinCredAct, dLinCredCal,cStatus, cCausa ,  cUser                                      
                                        FROM  bdicred:"informix".sd_bitacora_aumlincred
                                        WHERE empresa ='001'
                                        AND fecha_insert  >= pFechaInicial
                                        AND fecha_insert <= pFechaFinal
                                        AND status = pStatus
										AND origen = (CASE WHEN pOrigen = '0' THEN origen ELSE pOrigen END)
                                        ORDER BY fecha_insert
                                
                                        
                                        LET dMontoIncremento = dLinCredCal - dLinCredAct;
                                        IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
                                                LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
                                        ELSE
                                                LET dIncremento = 0;
                                        END IF;
                                        
                                        SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))                                     
                                        INTO vcNombre, vcApellPaterno,vcApellMaterno
                                        FROM bdinteg:"informix".si_cliente
                                        WHERE numcte = vcNumCte;
                                        
                                        LET vcAnalistaCac                       = '';
                                        LET vcAnalista2nivel                    = '';
                                        LET vcAnalista3nivel                    = '';
                                        LET vcAnalista4nivel                    = '';
                                        
                                        IF NVL(cOrigen,"") = "S" THEN
                                                FOREACH WITH HOLD
                                                        SELECT b.nombre,a.puesto,a.fecha_atencion, EXTEND(a.hora_atencion, HOUR TO SECOND)  
                                                        INTO cNomEjecutivo,cPuesto,dtFechaIngreso, dtHoraIngreso
                                                        FROM bdicred:"informix".sd_historica_cac_aumlincred a
                                                        INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo = a.ejecutivo)
                                                        WHERE a.solicitud = vcNumSol
                                                        AND a.fecha_insert = dtFechaOrigen
                                                        ORDER BY a.puesto                                                       

                                                        IF cPuesto = '01'       THEN  
                                                                LET vcAnalistaCac = cNomEjecutivo;
                                                                LET dtFechaIngresoAC =dtFechaIngreso;
                                                                LET dtHoraIngresoAC = dtHoraIngreso;
                                                        ELIF cPuesto in ('02','03') THEN 
                                                                LET vcAnalista2nivel = cNomEjecutivo;
                                                                LET dtFechaAtencion =dtFechaIngreso;
                                                                LET dtHoraAtencion = dtHoraIngreso;
                                                        ELIF cPuesto in ('04') THEN 
                                                                LET vcAnalista3nivel = cNomEjecutivo;
                                                                LET dtFechaAtencion =dtFechaIngreso;
                                                                LET dtHoraAtencion = dtHoraIngreso;
                                                        ELIF cPuesto in ('05','06','07','08') THEN
                                                                LET vcAnalista4nivel = cNomEjecutivo;
                                                                LET dtFechaAtencion =dtFechaIngreso;
                                                                LET dtHoraAtencion = dtHoraIngreso;
                                                        END IF

                                                END FOREACH
                                                IF cPuesto = '01'	THEN
                                                        LET dtFechaAtencion =dtFechaIngresoAC;
                                                        LET dtHoraAtencion = dtHoraIngresoAC;
                                                END IF;
												
												LET cTpoMovto = 'Manual'; 
											ELSE
												IF EXISTS (SELECT ejecutivo FROM "informix".sd_perfiles_cac_aumlincred WHERE empresa = '001' AND ejecutivo = trim(cUser)) THEN    
													LET cTpoMovto = 'Manual';   
												ELSE
													LET cTpoMovto = 'Automatico';     
												END IF;
                                        END IF;
                                        
                                        
                                        IF NVL(cCausa,"") <> "" THEN
                                        
                                        --se obtiene la descripcion del motivo de rechazo o cancelacion
                                                SELECT causa_status||' - '||TRIM(descripcion)
                                                INTO vcMotivo
                                                FROM bdicred:"informix".sd_causas_aumlincred
                                                WHERE status = cStatus
                                                AND causa_status = cCausa;
                                        END IF; 
                                
                                
                                        RETURN cCodRet, cMensajeRet,dtFechaOrigen,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                        NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,'') WITH RESUME;      
                                        
                                END FOREACH;  
                                
                                IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
                                        LET cCodRet= '000003';
                                        LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
                                        RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                               NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,'');
                                END IF;                 
                        --END IF
                END IF
        END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 09/03/2011',
'MODIFICO : Mohamed CarreÃ³n',
'DESCRIPCION CAMBIO : Se agregÃ³ la fecha final y la fecha inicial',
'FECHA : 12/06/2011',
'MODIFICACIÃN: Se modifica para contemplar las reglas de informix, se elimina la variable "cNum_credito" ya que no es utilizada en el codigo.',
'FECHA MODIFICACIÃN: 25/07/2012',
'MODIFICÃ: Guadalupe Payan',
'BD: BDICRED',
'VERSION: 20120725.1150',
'----------------------------------------------------------------------------------',
'Autor: JosuÃ© Remberto Zazueta Acosta',
'ModificaciÃ³n: Se borra cÃ³digo comentado,se agregan informix y bd a las tablas que no tenÃ­an,Se implementan reglas', 'de informix',
'Fecha de modificaciÃ³n: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'ModificaciÃ³n: Se agregan los campos Fecha Ingreso AC, Hora Ingreso AC, Fecha AtenciÃ³n, Hora AtenciÃ³n en el retorno del sp',
'Fecha de modificaciÃ³n: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'ModificaciÃ³n: Se modifica para agregar el tipo de incremento manual o automÃ¡tico',
'Fecha de modificaciÃ³n: 20/09/2016',
'ModificÃ³: Johnattan Esquivel SÃ¡nchez',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'ModificaciÃ³n: Se clona spl y se modifica para eliminar paginado de recuperaciÃ³n de informaciÃ³n',
'Fecha de modificaciÃ³n: 30/07/2019',
'ModificÃ³: Rodolfo Conde Flores',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_rep_gral_status3(pFechaIni CHAR (10), pFechaFin CHAR(10), pOrigen CHAR(1))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS tiene_causa,
			  CHAR(100) 	AS descripcion,
			  INTEGER 		AS total_status,
			  DECIMAL(18,2) AS porcentaje,
			  INTEGER 		AS total_general;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcStatusTotal     DECIMAL(18,2);

	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = "";
	LET cCodRet                  = "000000";
	LET cMensajeRet              = "SE REALIZÓ LA CONSULTA CORRECTAMENTE";
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = "";
	LET cBandera				 = "";
	LET cStatus 				 = "";
	LET cCausa 					 = "";
	LET dPorcStatusTotal         = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet=cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = "000002";
					LET cMensajeRet = "PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA";
				END IF;	 
				IF  cBandera = "S" THEN
					DROP TABLE tme_consultaincrementos;
				END IF;
				RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0), NVL(vcDescripcion,' '), NVL(iTotalStatus, 0), NVL(dPorcStatus, 0), NVL(iTotal, 0);
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/jesus/sp_rep_gral_status.out';
		--TRACE ON;

		--se validan los parametros de entrada.
		IF NVL(pFechaIni,"") = ""  OR NVL(pFechaFin,"") = "" THEN
			LET cCodRet = "000001";
			LET cMensajeRet = "FALTA PARÁMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA";
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0);
		END IF;

		IF NVL(pOrigen,"") = "" THEN
			LET cCodRet = "000003";
			LET cMensajeRet = "FALTA PARÁMETRO REQUERIDO DE ORIGEN PARA REALIZAR  LA CONSULTA";
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0);
		END IF;
		-- Crear una tabla temporal para insertar los datos de la consulta	
		IF EXISTS (SELECT tabname FROM systables  WHERE tabname = 'tme_consultaincrementos') THEN	
			DROP TABLE tme_consultaincrementos;
		END IF;

		-- Se crea la tabla de trabajo
		CREATE TEMP TABLE tme_consultaincrementos
		(
			status CHAR(2),
			causa	CHAR(3),
			descripcion  CHAR(100),
			totalRegistros INTEGER,
			porcentaje   decimal(18,2)		
		)WITH NO LOG;	
			
		LET cBandera = "S";

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		----se insertan el total de registros por estatus
		FOREACH WITH HOLD
			SELECT status,TRIM(descripcion)
				INTO cStatus,vcDescripcion
			FROM  "informix".sd_status_aumlincred 
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen = pOrigen
					AND status = cStatus					
					AND causa_status =""
				
				IF iTotalStatus > 0 THEN
					INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegistros,porcentaje)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0);	 
				END IF;
			END FOREACH;  	
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen = pOrigen
					AND status = cStatus					
					AND causa_status IN(SELECT causa_status		  
										 FROM "informix".sd_causas_aumlincred
										 WHERE mostrar_pantalla = "1")
				
				IF iTotalStatus > 0 THEN
					INSERT INTO tme_consultaincrementos(status,causa,descripcion,totalRegistros,porcentaje)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0);	 
				END IF;
				
			END FOREACH;  	
			
		END FOREACH;
		--se obtiene el total de los registros para esta consulta	
		SELECT NVL(SUM(totalregistros),0), COUNT(status)
		INTO iTotal,iTotalReg
		FROM  tme_consultaincrementos 
		WHERE status = status
			AND causa = ""
			AND totalRegistros <> 0;
		
		LET iTotalRegistros = iTotal;
					
		IF iTotalReg <> 0 THEN
			--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
			FOREACH
				SELECT status,descripcion,totalRegistros
				INTO cStatus, vcDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status = status
					AND causa = ""
					AND totalRegistros <> 0	
				
				LET dPorcStatus = ((iTotalStatus * 100)/iTotalRegistros);
				IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
					LET iCont = iCont + 1;
					IF iTotalReg = iCont THEN
						LET dPorcStatus = 100 - dPorcStatusAcum;
					END IF;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				ELSE
					LET iCont = iCont + 1;
					LET dPorcStatus = 100 - dPorcStatusAcum;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				END IF;
						
				UPDATE tme_consultaincrementos
				SET porcentaje = dPorcStatus
				WHERE status = cStatus;
			END FOREACH;
		END IF;
		---se insertan el total de registros por causas
		FOREACH WITH HOLD
			SELECT status,causa_status,TRIM(descripcion)
			  INTO cStatus,cCausa,vcDescripcion
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = "1"
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin		
					AND origen = pOrigen
					AND status = cStatus
					AND causa_status = cCausa
			
				INSERT INTO tme_consultaincrementos (status,causa,descripcion,totalRegistros,porcentaje)	
				VALUES(cStatus,cCausa,vcDescripcion,NVL(iTotalStatus,0),0);
			 
			END FOREACH;  		
		END FOREACH;	
		--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
		LET dPorcStatusAcum = 0;
		LET dPorcStatus = 0;
		LET iCont = 0;

		FOREACH WITH HOLD
			SELECT status,causa_status
			  INTO cStatus,cCausa
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = "1"
			ORDER BY status,causa_status
					
			SELECT NVL(SUM(totalregistros),0), COUNT(causa)
			INTO iTotal,iTotalReg
			FROM  tme_consultaincrementos 
			WHERE status = cStatus
				AND causa <> ""
				AND totalRegistros <> 0;
								
			SELECT porcentaje
			INTO  dPorcStatusTotal
			FROM  tme_consultaincrementos 
			WHERE status = cStatus
				AND causa = ""
				AND totalRegistros <> 0;
					
			IF iTotalReg <> 0 THEN
				SELECT status,causa,descripcion,totalRegistros
				INTO cStatus,cCausa,vcDescripcion,iTotalStatus
				FROM  tme_consultaincrementos
				WHERE status = cStatus
					AND causa = cCausa
					AND totalRegistros <> 0;
					
				IF NVL(iTotalStatus,0) <> 0 THEN
					LET dPorcStatus = ((iTotalStatus * 100) / iTotalRegistros);

					IF (dPorcStatusAcum + dPorcStatus) < dPorcStatusTotal THEN
						LET iCont = iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;							
						END IF;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
					ELSE
						LET iCont = iCont + 1;
						LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
					END IF;
						
					UPDATE tme_consultaincrementos
						SET porcentaje = dPorcStatus
					WHERE status = cStatus
						AND causa = cCausa;	
				END IF;
			END IF;
			IF iTotalReg = iCont THEN
				LET dPorcStatusAcum = 0;
				LET dPorcStatus = 0;
				LET iCont = 0;
			END IF;				
		END FOREACH;
		
		--se obtiene los datos de la tabla
		FOREACH
			--SELECT skip pInicio limit pFin status,causa,descripcion,totalRegistros,porcentaje
			SELECT status,causa,descripcion,totalRegistros,porcentaje
			INTO cStatus,cCausa,vcDescripcion,iTotalStatus,dPorcStatus
			FROM  tme_consultaincrementos
			ORDER BY status,causa
			
			IF NVL(cCausa,"") <> "" THEN
				LET iTieneCausa = 1;
				LET  vcDescripcion = TRIM (cCausa) || '-' || TRIM (vcDescripcion);
			ELSE
				LET iTieneCausa = 0;				
			END IF;
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0), NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotalRegistros, 0) WITH RESUME;			 

		END FOREACH;	
		
		IF  cBandera = "S" THEN
			DROP TABLE tme_consultaincrementos;
		END IF;
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada status de acuerdo al mes consultado',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2011',
'MODIFICACION: Se modifica para que reciba como parametro de entrada  el rango de fechas del cual se desea la informacion.',
'FECHA: 04/11/2011',
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'MODIFICACION: Se modifica para corregir y cambiar el retorno de la variable "iTotal" por "iTotalRegistros" ya que perdia el valor cuando el ultimo',
'			   registro tomaba el valor de 0 y por consecuencia no mostraba registros. Se contemplan las reglas de informix, se elimina variable "cComentario" y',
'              dPorcStatusAcum2 ya que estas no son usadas en el procedimiento',
'FECHA: 24/07/2012',
'AUTOR : Guadalupe Payan',
'BD    : BDICRED',
'Version: 20120724.1714',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Modificación: Se clona spl y se modifica para eliminar paginado de recuperación de información',
'Fecha de modificación: 30/07/2019',
'Modificó: Rodolfo Conde Flores',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_supervision_mc
(pEmpresa      CHAR(3),
pNumSolicitud  VARCHAR(20,1),
pNumCte        VARCHAR(20,1),
pFechaIni      DATE,
pFechaFin      DATE,
pStatus        CHAR(2),
pProducto      CHAR(4),
pInicio        INTEGER,
pFinal         INTEGER)
RETURNING
	CHAR(6) 	    AS CodRet,
	VARCHAR(20,1)	AS Num_Solicitud,
	VARCHAR(20,1)	AS Num_Cte,
	VARCHAR(130,1)	AS Nombre_Cte,
	DATE 			AS Fecha_Solicitud,
	DATE 			AS Fecha_Cambio_Status,
	CHAR(2) 		AS Status,
	VARCHAR(8,1)    AS Respuesta_OS;	
	
---DECLARACIONES
DEFINE cCodRet        CHAR(6); 
DEFINE iSqlErr        INTEGER;
DEFINE iIsamErr       INTEGER;
DEFINE iNumReg        INTEGER;

DEFINE cEmpresa             CHAR(3);
DEFINE cNumSolic            VARCHAR(20,1);
DEFINE cNumCte              VARCHAR(20,1);
DEFINE cNomCte              VARCHAR(130,1);
DEFINE dtFechaSolic         DATE;
DEFINE dtFechaCambioSolic   DATE;
DEFINE cStatusSolic         CHAR(2);
DEFINE cSityCausa           VARCHAR(8,1);
DEFINE cNomCte1				CHAR(26);
DEFINE cNomCte2				CHAR(26);
DEFINE cApellidoCte1		CHAR(26);
DEFINE cApellidoCte2		CHAR(26);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cCodRet             = "000000";
LET iNumReg             = 0;

LET cEmpresa            = '';
LET cNumSolic           = '';
LET cNumCte             = '';
LET cNomCte             = '';
LET dtFechaSolic        = DATE(1);
LET dtFechaCambioSolic  = DATE(1);
LET cStatusSolic        = '';
LET cSityCausa          = '';
LET cNomCte1			= '';
LET cNomCte2			= '';
LET cApellidoCte1		= '';
LET cApellidoCte2		= '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet,NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'');
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/gpe/sp_consulta_supervision_mc.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
  INTO cEmpresa     
  FROM bdinteg:si_empresas 
 WHERE empresa= pEmpresa;
  
IF cEmpresa IS NULL THEN
  LET cCodRet = '000001';
  RETURN cCodRet,NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'');
END IF;

/*
FOREACH WITH HOLD
	SELECT 	SKIP pInicio FIRST pFinal
			sol.num_solicitud AS solicitud, 
			sol.numcte AS cliente,
			sol.status_solicitud AS status, 
			sol.fecha_insert AS fecha_solicitud,
			TRIM(NVL(cli.nombre1,'')) ||' '||
			TRIM(NVL(cli.nombre2,'')) ||' '||
			TRIM(NVL(cli.apell_paterno,'')) ||' '||
			TRIM(NVL(cli.apell_materno,'')) AS nom_cte,
			aut.fecha_entrada as fecha_cambio			 
	  INTO  cNumSolic,
	        cNumCte,
	        cStatusSolic,
			dtFechaSolic,
			cNomCte,
			dtFechaCambioSolic
	  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
															  AND aut.empresa= sol.empresa 
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																					   FROM bdisolic:ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa 
																					   AND aut_aux.num_solicitud= sol.num_solicitud 
																					   AND aut_aux.status_solicitud= sol.status_solicitud))
	INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
	INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
	 WHERE sol.empresa = pEmpresa
	   AND sol.num_solicitud = (CASE WHEN pNumSolicitud  = '' THEN sol.num_solicitud ELSE TRIM(pNumSolicitud) END)
	   AND sol.numcte = (CASE WHEN pNumCte = '' THEN sol.numcte ELSE TRIM(pNumCte) END)
	   AND (sol.fecha_insert >= (CASE WHEN pFechaIni =date(1) THEN sol.fecha_insert ELSE pFechaIni END) 
		   AND  sol.fecha_insert <= (CASE WHEN pFechaFin =date(1) THEN sol.fecha_insert ELSE pFechaFin END))
	   AND sol.status_solicitud = (CASE WHEN pStatus = '' THEN sol.status_solicitud ELSE TRIM(pStatus) END)
	   AND sol.num_producto = (CASE WHEN pProducto = '' THEN sol.num_producto ELSE TRIM(pProducto) END)
       AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso)*/
	   
	  
	IF  pNumSolicitud  <> '' THEN --numero de solicitud
	
	FOREACH WITH HOLD
	SELECT 	SKIP pInicio FIRST pFinal
			sol.num_solicitud AS solicitud, 
			sol.numcte AS cliente,
			sol.status_solicitud AS status, 
			sol.fecha_insert AS fecha_solicitud,
			cli.nombre1,
			cli.nombre2,
			cli.apell_paterno,
			cli.apell_materno,
			aut.fecha_entrada as fecha_cambio			 
	  INTO  cNumSolic,
	        cNumCte,
	        cStatusSolic,
			dtFechaSolic,
			cNomCte1,
			cNomCte2,
			cApellidoCte1,
			cApellidoCte2,
			dtFechaCambioSolic
	  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
															  AND aut.empresa= sol.empresa 
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																					   FROM bdisolic:ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa 
																					   AND aut_aux.num_solicitud= sol.num_solicitud 
																					   AND aut_aux.status_solicitud= sol.status_solicitud))
	INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
	INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
	 WHERE sol.empresa = pEmpresa
	   AND sol.num_solicitud =  pNumSolicitud 
       AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso)
	   
	   LET cNomcte = TRIM(NVL(cNomCte1,'')) ||' '||TRIM(NVL(cNomCte2,'')) ||' '||TRIM(NVL(cApellidoCte1,'')) ||' '||TRIM(NVL(cApellidoCte2,'')) ;
	
	   
	    SELECT FIRST 1 TRIM(c.situacionespecial)||'-'|| c.causasituacionespecial 
	INTO cSityCausa
	FROM bdisolic:"informix".ss_solicitud_os a 
	LEFT JOIN bdisolic:"informix".ss_osclientesupervisar c ON (c.empresa=a.empresa AND c.num_solicitud =a.num_solicitud AND c.fechasolicitud=a.fecha_solicitud)
	WHERE a.num_solicitud = cNumSolic
	  AND a.fecha_solicitud =(
							   SELECT MAX(fecha_solicitud) 
							   FROM bdisolic:"informix".ss_solicitud_os b 
							   WHERE b.num_solicitud = a.num_solicitud 
							   AND b.empresa = a.empresa
							 )
							
	  AND a.empresa = pEmpresa;
	  
	  	RETURN cCodRet,NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'') WITH RESUME;

	   
	   END FOREACH;
	   
	ELIF  pNumCte  <> '' THEN --numero de cliente
	
	FOREACH WITH HOLD
	SELECT 	SKIP pInicio FIRST pFinal
			sol.num_solicitud AS solicitud, 
			sol.numcte AS cliente,
			sol.status_solicitud AS status, 
			sol.fecha_insert AS fecha_solicitud,
			cli.nombre1,
			cli.nombre2,
			cli.apell_paterno,
			cli.apell_materno,
			aut.fecha_entrada as fecha_cambio			 
	  INTO  cNumSolic,
	        cNumCte,
	        cStatusSolic,
			dtFechaSolic,
			cNomCte1,
			cNomCte2,
			cApellidoCte1,
			cApellidoCte2,
			dtFechaCambioSolic
	  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
															  AND aut.empresa= sol.empresa 
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																					   FROM bdisolic:ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa 
																					   AND aut_aux.num_solicitud= sol.num_solicitud 
																					   AND aut_aux.status_solicitud= sol.status_solicitud))
	INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
	INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
	 WHERE sol.empresa = pEmpresa
	   AND sol.numcte = pNumCte
       AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso)
	   
	   LET cNomcte = TRIM(NVL(cNomCte1,'')) ||' '||TRIM(NVL(cNomCte2,'')) ||' '||TRIM(NVL(cApellidoCte1,'')) ||' '||TRIM(NVL(cApellidoCte2,''));
	
	   
	    SELECT FIRST 1 TRIM(c.situacionespecial)||'-'|| c.causasituacionespecial 
	INTO cSityCausa
	FROM bdisolic:"informix".ss_solicitud_os a 
	LEFT JOIN bdisolic:"informix".ss_osclientesupervisar c ON (c.empresa=a.empresa AND c.num_solicitud =a.num_solicitud AND c.fechasolicitud=a.fecha_solicitud)
	WHERE a.num_solicitud = cNumSolic
	  AND a.fecha_solicitud =(
							   SELECT MAX(fecha_solicitud) 
							   FROM bdisolic:"informix".ss_solicitud_os b 
							   WHERE b.num_solicitud = a.num_solicitud 
							   AND b.empresa = a.empresa
							 )
							
	  AND a.empresa = pEmpresa;
	  
	  	RETURN cCodRet,NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'') WITH RESUME;

	   
	   END FOREACH;
	
	ELSE --otros criterios
	
	FOREACH WITH HOLD
	SELECT 	SKIP pInicio FIRST pFinal
			sol.num_solicitud AS solicitud, 
			sol.numcte AS cliente,
			sol.status_solicitud AS status, 
			sol.fecha_insert AS fecha_solicitud,
			cli.nombre1,
			cli.nombre2,
			cli.apell_paterno,
			cli.apell_materno,
			aut.fecha_entrada as fecha_cambio			 
	  INTO  cNumSolic,
	        cNumCte,
	        cStatusSolic,
			dtFechaSolic,
			cNomCte1,
			cNomCte2,
			cApellidoCte1,
			cApellidoCte2,
			dtFechaCambioSolic
	  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
															  AND aut.empresa= sol.empresa 
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
																					   FROM bdisolic:ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa 
																					   AND aut_aux.num_solicitud= sol.num_solicitud 
																					   AND aut_aux.status_solicitud= sol.status_solicitud))
	INNER JOIN bdinteg:"informix".si_cliente AS cli ON (sol.numcte = cli.numcte)
	INNER JOIN bdisolic:"informix".ss_catalogo_supervision AS cat ON (sol.status_solicitud = cat.status AND sol.empresa = cat.empresa)
	 WHERE sol.empresa = pEmpresa
	   AND sol.fecha_insert BETWEEN  pFechaIni AND pFechaFin 
	   AND sol.status_solicitud =  pStatus 
	   AND sol.num_producto = pProducto
       AND cli.numcte NOT IN (SELECT numcte FROM bdisolic:"informix".ss_solsuperv_paso)
	   
	   LET cNomcte = TRIM(NVL(cNomCte1,'')) ||' '||TRIM(NVL(cNomCte2,'')) ||' '||TRIM(NVL(cApellidoCte1,'')) ||' '||TRIM(NVL(cApellidoCte2,''));
	
	 SELECT FIRST 1 c.situacionespecial||'-'|| c.causasituacionespecial 
	INTO cSityCausa
	FROM bdisolic:"informix".ss_solicitud_os a 
	LEFT JOIN bdisolic:"informix".ss_osclientesupervisar c ON (c.empresa=a.empresa AND c.num_solicitud =a.num_solicitud AND c.fechasolicitud=a.fecha_solicitud)
	WHERE a.num_solicitud = cNumSolic
	  AND a.fecha_solicitud =(
							   SELECT MAX(fecha_solicitud) 
							   FROM bdisolic:"informix".ss_solicitud_os b 
							   WHERE b.num_solicitud = a.num_solicitud 
							   AND b.empresa = a.empresa
							 )
	  AND a.empresa = pEmpresa;
	
	RETURN cCodRet,NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'') WITH RESUME;

END FOREACH;
	
	
	END IF;
	
	
	/*
	   
  SELECT TRIM(c.situacionespecial)||'-'|| c.causasituacionespecial 
	INTO cSityCausa
	FROM bdisolic:"informix".ss_solicitud_os a 
	LEFT JOIN bdisolic:"informix".ss_osclientesupervisar c ON (c.empresa=a.empresa AND c.num_solicitud =a.num_solicitud AND c.fechasolicitud=a.fecha_solicitud)
	WHERE a.num_solicitud = cNumSolic
	  AND a.fecha_solicitud =(
							   SELECT MAX(fecha_solicitud) 
							   FROM bdisolic:"informix".ss_solicitud_os b 
							   WHERE b.num_solicitud = a.num_solicitud 
							   AND b.empresa = a.empresa
							 )
	  AND a.empresa = pEmpresa;
	
	RETURN cCodRet,NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'') WITH RESUME;

END FOREACH;*/

LET iNumReg = dbinfo("sqlca.sqlerrd2");
IF iNumReg = 0 THEN
	LET cCodRet = "000002";
	RETURN cCodRet,NVL(cNumSolic,''),NVL(cNumCte,''),NVL(cNomCte,''),NVL(dtFechaSolic,DATE(1)),NVL(dtFechaCambioSolic,DATE(1)),NVL(cStatusSolic,''),NVL(cSityCausa,'');
END IF;
	
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la obtencion de la informaciÃ³n principal del Monitor de SupervisiÃ³n',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 26/04/2016',
'BD    : BDICRED',
'Version: 20160426.1110';

CREATE PROCEDURE "informix".sp_desbloqueocuenta (pEmpresa CHAR(3), pNumCuenta CHAR(20), pEjecutivo CHAR(8), pTipo INTEGER, pArea VARCHAR(150,1), pJustificacion VARCHAR(150,1))

RETURNING CHAR(6) AS CODIGO,
          CHAR(80) AS MENSAJECOD;

--Definicion de variables--
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);

DEFINE vFecha        DATE; 
DEFINE vCodSP        CHAR(6);
DEFINE vStatusCred   CHAR(2);
DEFINE iBloqueoAnt   INTEGER;
DEFINE cCausaAnt     CHAR(3);

DEFINE cCredBitacora CHAR(20);
DEFINE dcSdoCapital  DECIMAL(18,2);
DEFINE cEmpresa      CHAR(3);
DEFINE cEjecutivo    CHAR(8);

--Set debug file to '/tmp/sp_desbloqueocuenta.out';
--trace on;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
	  LET cCodRet= iSqlErr;
	  LET cMensajeRet= cErrorInfo;
	  RETURN 
		   cCodRet,
		   cMensajeRet;  
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
--Inicializar Variables--
LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = '';
LET cCodRet        = '000000';
LET cMensajeRet    = 'La cuenta se ha desbloqueado satisfactoriamente';

LET vCodSP         = '';
LET vStatusCred    = '';
LET vFecha         = DATE(1);
LET iBloqueoAnt    = 0;
LET cCausaAnt      = '';
LET cCredBitacora  = '';
LET dcSdoCapital   = 0;
LET cEmpresa       = '';
LET cEjecutivo     = '';
        
	IF NVL(pEmpresa,'') = ''  OR NVL(pNumCuenta,'') = '' OR NVL(pEjecutivo,'') = '' OR 
	NVL(pTipo,'') = '' THEN
		LET cCodRet = '000001';    --Faltan Valores
		LET cMensajeRet = 'Faltan valores para ejecutar el procedimiento.'; 
	ELSE
		SELECT empresa INTO cEmpresa 
		FROM bdinteg:"informix".si_empresas 
		WHERE empresa = pEmpresa;
		
		IF NVL(cEmpresa,'') = '' THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'La empresa no válida';
		ELSE
			SELECT ejecutivo INTO cEjecutivo
			FROM bdinteg:"informix".si_ejecut 
			WHERE ejecutivo = pEjecutivo;
			
			IF NVL(cEjecutivo,'') = '' THEN
				LET cCodRet = '000003';
				LET cMensajeRet = 'El ejecutivo no es valido';
			ELSE
				IF pTipo NOT IN (1,2) THEN
					LET cCodRet = '000004';
					LET cMensajeRet = 'El tipo de bloqueo no es válido';
				ELSE
					EXECUTE PROCEDURE "informix".sp_validacredito (pEmpresa, pNumCuenta) 
					INTO vCodSP;
					IF vCodSP::INTEGER <> 0 THEN
						LET cCodRet = '000005';    --No existe el credito en la base de datos.
						LET cMensajeRet= 'La cuenta no existe';
					ELSE    
						SELECT id_unidad_prod, status_Cred, cod_caract_2
						  INTO iBloqueoAnt, vStatusCred, cCausaAnt
						  FROM "informix".sd_maecred
						 WHERE empresa = pEmpresa 
						   AND num_credito = pNumCuenta;

						IF iBloqueoAnt IS NULL AND (cCausaAnt IS NULL  OR cCausaAnt IS NOT NULL) THEN
							LET cCodRet = '000006';    --La cuenta ya esta desbloqueada.
							LET cMensajeRet= 'La cuenta se encuentra desbloqueada';
						ELSE
							IF vStatusCred='FF' THEN
								LET cCodRet = '000011';                   
								LET cMensajeRet= 'La cuenta se encuentra saldada';   
							ELIF vStatusCred='CV' THEN
							   LET cCodRet = '000007';                   
							   LET cMensajeRet= 'La cuenta se encuentra en cartera vendida';
							ELSE
							   IF (iBloqueoAnt = 0 AND cCausaAnt IS NOT NULL) THEN 
									LET cCodRet = '000008';
									LET cMensajeRet = 'Crédito bloqueado manualmente favor de verificar'; 
							   ELSE
									IF iBloqueoAnt > 0 THEN
										LET cCausaAnt = nvl(cCausaAnt,'');
										SELECT cuenta
										  INTO cCredBitacora
										  FROM "informix".sd_bitacorabloqueocta
										 WHERE cuenta=pNumCuenta
										   AND cve_bloqueo=iBloqueoAnt
										   AND nvl(cve_causa,'')= cCausaAnt
										   AND id=(SELECT max(id)
													 FROM "informix".sd_bitacorabloqueocta
													WHERE cuenta=pNumCuenta
													  AND cve_bloqueo=iBloqueoAnt
													  AND nvl(cve_causa,'')= cCausaAnt);
													  
										IF cCredBitacora IS NULL THEN
											LET cCodRet = '000009';    --Cuenta bloqueada manualmente
											LET cMensajeRet= 'No es posible desbloquear, el crédito ha sido bloqueado manualmente';
										ELSE
											LET cMensajeRet= 'El crédito ha sido desbloqueado de forma automática';
											SELECT fecha_hoy
											INTO vFecha
											FROM "informix".sd_fechas
											WHERE empresa = pEmpresa;
											
                                            SELECT sdo_cap_insoluto
											  INTO dcSdoCapital
											  FROM "informix".sd_maesdos
											 WHERE num_credito = pNumCuenta 
											   AND empresa = pEmpresa;
											
											INSERT INTO "informix".sd_bitacorabloqueocta 
											(cuenta, cve_bloqueo, cve_causa, cve_bloqueAnterior,cve_causa_anterior,ejecutivo, fecha, tipo_bloqueo, tipo_movimiento, area_solicita, justificacion, saldo_capital)
											VALUES (pNumCuenta, NULL, NULL, iBloqueoAnt, cCausaAnt, pEjecutivo, vFecha, pTipo, 'D',NVL(pArea,''), NVL(pJustificacion,''), NVL(dcSdoCapital,0));
											
											UPDATE "informix".sd_maecred
											SET id_unidad_prod = NULL, cod_caract_2 = NULL
											WHERE empresa = pEmpresa 
											AND num_credito = pNumCuenta;
										END IF;
									ELSE
										LET cCodRet = '000010';    
										LET cMensajeRet= 'El bloqueo actual no es valido favor de verificar';
									END IF;
								END IF;
							END IF;
						END IF;	
					END IF;
				END IF;                
			END IF;            
		END IF;        
	END IF;        		
		
	RETURN cCodRet, cMensajeRet;
        
    END;
END PROCEDURE

DOCUMENT
'Autor: Maria Elena Angulo',
'Fecha: 02/08/2019',
'Descripcion: Desbloquea una cuenta e inserta un registro en la tabla sd_bitacorabloqueocta. Bloqueo Cuentas. Se agrega de tipo bloqueo (manual o masivo), tipo_bloqueo  1 = Manual, 2 = Masivo',
'Cambio: Clon del proceso Actual sp_desbloqueocuenta para agregar los siguientes parámetros: pArea y pJustificacion. Se quitan los IF NOT EXITS',
'Version: 20190802.1150';

CREATE PROCEDURE "informix".sp_cac_rep_excepciones_tot(pFechaIni CHAR (10), pFechaFin CHAR(10), pExcepcion CHAR(3), pUsuario CHAR(10))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS total;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcExcepcion		DECIMAL(18,2);
	DEFINE dPorcExcepcionAcum	DECIMAL(18,2);
	DEFINE cExcepcion			CHAR(3);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE iTotalExcepcion 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcExcepcionTotal  DECIMAL(18,2);
    

	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
	LET dPorcExcepcion			 = 0;
	LET dPorcExcepcionAcum		 = 0;
	LET iTotalExcepcion			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = '';
	LET cBandera				 = '';
	LET cExcepcion				 = '';
	LET cCausa 					 = '';
	LET dPorcExcepcionTotal      = 0;
    

	BEGIN

	
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	 
				IF  cBandera = "S" THEN
					DELETE FROM bdicnweb:"informix".sw_consultaincrementosexcepciones WHERE usuario = pUsuario;
				END IF;
				RETURN cCodRet, cMensajeRet, iTotalReg;
		   END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cac_rep_excepciones.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--se validan los parametros de entrada.
		IF NVL(pFechaIni,'') = ''  OR NVL(pFechaFin,'') = ''  OR NVL(pUsuario,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA PARAMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA';
			RETURN cCodRet, cMensajeRet, iTotalReg;
		END IF;
		
		IF pExcepcion IS NULL THEN 
		 LET pExcepcion = '';
		END IF;
		
		-- Se elimina la tabla de trabajo
		DELETE FROM bdicnweb:"informix".sw_consultaincrementosexcepciones WHERE usuario = pUsuario;
			
		LET cBandera = "S";

		-- Se insertan el total de registros por excepcion
		FOREACH WITH HOLD
			SELECT clave_excepcion,TRIM(descripcion)
				INTO cExcepcion,vcDescripcion
			FROM "informix".sd_excepciones_aumlincred 
			WHERE clave_excepcion = (CASE WHEN pExcepcion = '' THEN clave_excepcion ELSE pExcepcion END)
				
			FOREACH WITH HOLD
				SELECT COUNT(excepciones)
				INTO iTotalExcepcion
				FROM  "informix".sd_sol_excepciones_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND empresa = '001'
					AND excepciones = cExcepcion			
				
				INSERT INTO bdicnweb:"informix".sw_consultaincrementosexcepciones(excepcion,causa,descripcion,totalRegistros,porcentaje,usuario)
				VALUES(cExcepcion,'',vcDescripcion,NVL(iTotalExcepcion,0),0, pUsuario);	 
				
			END FOREACH;  	
		END FOREACH;
		
		-- Se obtiene el total de los registros para esta consulta	
		SELECT NVL(SUM(totalregistros),0), COUNT(excepcion)
		INTO iTotal,iTotalReg
		FROM  bdicnweb:"informix".sw_consultaincrementosexcepciones 
		WHERE excepcion = excepcion
			AND causa = ''
			AND totalRegistros <> 0;
		
		LET iTotalRegistros = iTotal;
					
		IF iTotalReg <> 0 THEN
			-- Se realiza el calculo del porcentaje por cada  Excepcion del total de registros de la consulta	
			FOREACH
				SELECT excepcion,descripcion,totalRegistros
				INTO cExcepcion, vcDescripcion,iTotalExcepcion
				FROM  bdicnweb:"informix".sw_consultaincrementosexcepciones
				WHERE excepcion = excepcion
					AND causa = ''
					AND totalRegistros <> 0	
					AND usuario = pUsuario
					
				LET dPorcExcepcion= ((iTotalExcepcion * 100)/iTotalRegistros);
				IF (dPorcExcepcionAcum + dPorcExcepcion) < 100 THEN
					LET iCont = iCont + 1;
					IF iTotalReg = iCont THEN
						LET dPorcExcepcion= 100 - dPorcExcepcionAcum;
					END IF;
					LET dPorcExcepcionAcum = dPorcExcepcionAcum + dPorcExcepcion;
				ELSE
					LET iCont = iCont + 1;
					LET dPorcExcepcion= 100 - dPorcExcepcionAcum;
					LET dPorcExcepcionAcum = dPorcExcepcionAcum + dPorcExcepcion;
				END IF;
						
				UPDATE bdicnweb:"informix".sw_consultaincrementosexcepciones
				SET porcentaje = dPorcExcepcion
				WHERE excepcion = cExcepcion AND usuario = pUsuario;
			END FOREACH;
		END IF;
		
		-- Se obtiene los datos de la tabla

		SELECT COUNT(*)
		INTO iTotalReg
		FROM bdicnweb:"informix".sw_consultaincrementosexcepciones
		WHERE usuario = pUsuario;
		
		RETURN cCodRet, cMensajeRet, iTotalReg;			 	
		
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada excepcion de acuerdo al mes consultado',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 04/02/2013',
'BD: BDICRED',
'Version: 20130204.1714',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_excepciones2(pFechaIni CHAR (10), pFechaFin CHAR(10), pExcepcion CHAR(3), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS tiene_causa,
			  CHAR(100) 	AS descripcion,
			  INTEGER 		AS total_excepcion,
			  DECIMAL(18,2) AS porcentaje,
			  INTEGER 		AS total_general,
			  DECIMAL(18,2) AS total_porcentaje;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcExcepcion		DECIMAL(18,2);
	DEFINE dPorcExcepcionAcum	DECIMAL(18,2);
	DEFINE cExcepcion			CHAR(3);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE iTotalExcepcion 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcExcepcionTotal  DECIMAL(18,2);

	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
	LET dPorcExcepcion			 = 0;
	LET dPorcExcepcionAcum		 = 0;
	LET iTotalExcepcion			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = '';
	LET cBandera				 = '';
	LET cExcepcion				 = '';
	LET cCausa 					 = '';
	LET dPorcExcepcionTotal      = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet=cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	 
				IF  cBandera = 'S' THEN
					DROP TABLE tme_consultaincrementos;
				END IF;
				RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0), NVL(vcDescripcion,''), NVL(iTotalExcepcion, 0), NVL(dPorcExcepcion, 0), NVL(iTotal, 0), NVL(dPorcExcepcionTotal, 0);
		   END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cac_rep_excepciones2.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		-- Se validan los parametros de entrada.
		IF NVL(pFechaIni,'') = ''  OR NVL(pFechaFin,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA PARAMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA';
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalExcepcion, 0), NVL(dPorcExcepcion, 0),NVL(iTotal, 0), NVL(dPorcExcepcionTotal, 0);
		END IF;
		
		-- Se obtiene los datos de la tabla
		FOREACH
			SELECT SKIP pInicio LIMIT pFin excepcion,causa,descripcion,totalRegistros,porcentaje
			INTO cExcepcion,cCausa,vcDescripcion,iTotalExcepcion,dPorcExcepcion
			FROM bdicnweb:"informix".sw_consultaincrementosexcepciones WHERE usuario = pUsuario
			
			IF NVL(cCausa,'') <> '' THEN
				LET iTieneCausa = 1;
				LET  vcDescripcion = TRIM (cCausa) || '-' || TRIM (vcDescripcion);
			ELSE
				LET iTieneCausa = 0;				
			END IF;
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0), NVL(vcDescripcion,''),NVL(iTotalExcepcion, 0), NVL(dPorcExcepcion, 0),NVL(iTotalRegistros, 0), NVL(dPorcExcepcionTotal, 0) WITH RESUME;			 
		END FOREACH;	
		
		
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada excepciÃ³n de acuerdo al mes consultado',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 04/02/2013',
'BD: BDICRED',
'Version: 20130204.1714',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de CrÃ©dito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_perfil_usuario_tot(pFechaIni CHAR (10), pFechaFin CHAR(10), pUsuario CHAR(10))
	RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  INTEGER  AS total;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);
	DEFINE dPorcAtendidas		DECIMAL(18,2);	
	DEFINE dPorcCanceladas		DECIMAL(18,2);
	DEFINE dPorcRechazadas		DECIMAL(18,2);
	DEFINE dPorcAutorizados	    DECIMAL(18,2);
	DEFINE cDescripcion 		CHAR(25);
	DEFINE cNombre				CHAR(45);
	DEFINE cBandera 			CHAR(1);
	DEFINE iCanceladas			INTEGER;
	DEFINE iAutorizadas	     	INTEGER;
	DEFINE iRechazadas		    INTEGER;
	DEFINE cEjecutivo           CHAR(8);
	DEFINE cPuesto 				CHAR(2);
	DEFINE cRangoAutorizacion	CHAR(2);
	DEFINE iTotalReg 			INTEGER;
	DEFINE iTotalPerfil			INTEGER;
	
	DEFINE dTotalPorcAtendidas		DECIMAL(18,2);	
	DEFINE dTotalPorcCanceladas		DECIMAL(18,2);
	DEFINE dTotalPorcRechazadas		DECIMAL(18,2);
	DEFINE dTotalPorcAutorizados	DECIMAL(18,2);
	
	DEFINE iTotalTotalPerfil		INTEGER;
	DEFINE iTotalCanceladas			INTEGER;
	DEFINE iTotalAutorizadas	    INTEGER;
	DEFINE iTotalRechazadas		    INTEGER;
	---INICIALIZACIONES
	
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'Se realizó la consulta correctamente';
	LET dPorcAtendidas		     = 0;
	LET dPorcCanceladas		     = 0;
	LET dPorcRechazadas		     = 0;
	LET dPorcAutorizados	     = 0;
	LET iCanceladas		     	 = 0;
	LET iAutorizadas	     	 = 0;
	LET iRechazadas		     	 = 0;
	LET cEjecutivo				 = '';
	LET cPuesto 				 = '';
	LET cRangoAutorizacion		 = '';
	LET iTotalReg				 = 0;
	LET cDescripcion			 = '';
	LET cNombre 				 = '';
	LET cBandera				 = '';
	LET iTotalPerfil			 = 0;
	
	LET dTotalPorcAtendidas		 = 0;
	LET dTotalPorcCanceladas	 = 0;
	LET dTotalPorcRechazadas	 = 0;
	LET dTotalPorcAutorizados	 = 0;
	
	LET iTotalTotalPerfil		 = 0;
	LET iTotalCanceladas		 = 0;
	LET iTotalAutorizadas	     = 0;
	LET iTotalRechazadas		 = 0;

	BEGIN
	
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	IF iSqlErr != 0 THEN
		LET cCodRet = iSqlErr;
		LET cMensajeRet = cErrorInfo;	 
		
		RETURN cCodRet, cMensajeRet, iTotalReg;
	END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_cac_rep_perfil_usuario.out';
	--TRACE ON;

	-- Se validan los parametros de entrada.
	IF NVL(pFechaini,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Falta un parámetro de fecha requerido para realizar  la consulta';
		RETURN cCodRet, cMensajeRet, iTotalReg;
	END IF;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- Elimina la tabla de trabajo
	DELETE FROM bdicnweb:"informix".sw_consultaincrementosperfilusuario WHERE usuario = pUsuario;
	
	-- Se obtiene el total de registros de solicitudes atendidas.
		
	SELECT COUNT( b.num_solicitud) --total atendidas 
	INTO iTotalReg
	FROM  bdicred:"informix".sd_historica_cac_aumlincred h ,
	bdicred:"informix".sd_bitacora_aumlincred b			  
	WHERE  h.empresa = b.empresa 
	AND h.solicitud  = b.num_solicitud
	AND h.fecha_insert between  b.fecha_insert and b.fecha_status
	AND b.fecha_insert >= pFechaIni
	AND b.fecha_insert <= pFechaFin
	AND b.origen = 'S';
	
	
	IF iTotalReg = 0 THEN
		LET cCodRet = '000003';
		LET cMensajeRet =  'No hay información con el rango de fechas solicitado';
		RETURN cCodRet, cMensajeRet, iTotalReg;
	END IF;	
	
	FOREACH WITH HOLD	
		SELECT h.puesto,h.ejecutivo,COUNT( b.num_solicitud), --total atendidas por usuario	
		SUM(CASE WHEN b.status='CM' THEN 1 ELSE 0 END),--Canceladas
		SUM(CASE WHEN b.status='RT' THEN 1 ELSE 0 END),--Rechazadas
		SUM(CASE WHEN b.status in ('AT','AP','IN') THEN 1 ELSE 0 END)--Autorizadas
		INTO cPuesto,cEjecutivo,iTotalPerfil,iCanceladas,iRechazadas,iAutorizadas
		FROM bdicred:"informix".sd_bitacora_aumlincred b, bdicred:"informix".sd_historica_cac_aumlincred h
		WHERE  h.empresa = b.empresa 
		AND h.solicitud  = b.num_solicitud
		AND h.fecha_insert between  b.fecha_insert and b.fecha_status
		AND b.fecha_insert >= pFechaIni
		AND b.fecha_insert <= pFechaFin
		AND b.origen = 'S'
		GROUP BY h.puesto,h.ejecutivo
		ORDER BY h.puesto,h.ejecutivo
		
			
			LET dPorcCanceladas	 = 0;
			LET dPorcRechazadas	 = 0;
			LET dPorcAutorizados = 0;
			LET dPorcAtendidas   = 0;
			
			--Se obtiene el nombre del ejecutivo
			SELECT nombre
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = cEjecutivo;
			
			--Se obtiene la descripcion del puesto del ejecutivo
			SELECT descripcion_puesto
			INTO cDescripcion
			FROM bdicred:"informix".sd_puestos_cac_aumlincred
			WHERE puesto = cPuesto;
			
			--Calculo para obtener los porcentajes de las solicitudes atendidas,  canceladas, rechazadas y autorizadas. 
			IF NVL(iTotalPerfil,0) <> 0 THEN
			LET dPorcAtendidas = ((iTotalPerfil * 100) / iTotalReg);
			--Total
			LET iTotalTotalPerfil = iTotalTotalPerfil + iTotalPerfil;
			
			END IF;
			IF NVL(iCanceladas,0) <> 0 THEN
				LET dPorcCanceladas = ((iCanceladas * 100) / iTotalPerfil);
				--Total
				LET iTotalCanceladas = iTotalCanceladas + iCanceladas;
				
			END IF;
			IF NVL(iRechazadas,0) <> 0 THEN
				LET dPorcRechazadas	= ((iRechazadas * 100) / iTotalPerfil);
				--Total
				LET iTotalRechazadas = iTotalRechazadas + iRechazadas;
				
			END IF;
			IF NVL(iAutorizadas,0) <> 0 THEN
				LET dPorcAutorizados =((iAutorizadas * 100) / iTotalPerfil);
				--Total
				LET iTotalAutorizadas = iTotalAutorizadas + iAutorizadas;
				
			END IF;			
			
			
			LET dTotalPorcAtendidas = ((iTotalTotalPerfil * 100) / iTotalTotalPerfil); 
			LET dTotalPorcCanceladas = ((iTotalCanceladas * 100) / iTotalTotalPerfil);
			LET dTotalPorcRechazadas = ((iTotalRechazadas * 100) / iTotalTotalPerfil); 
			LET dTotalPorcAutorizados = ((iTotalAutorizadas * 100) / iTotalTotalPerfil);
			
			
			INSERT INTO bdicnweb:"informix".sw_consultaincrementosperfilusuario(numempleado, nombre, perfilpuesto, atendidas, porcatendidas, canceladas, porccanceladas, rechazadas, porcrechazadas, autorizadas, porcautorizadas, totalatendidas, totalporcatendidas, totalcanceladas, totalporccanceladas, totalrechazadas, totalporcrechazadas, totalautorizadas, totalporcautorizadas, usuario) 
			VALUES(NVL(cEjecutivo,''), NVL(cNombre,''), NVL(cDescripcion,''), NVL(iTotalPerfil,0), NVL(dPorcAtendidas,0), NVL(iCanceladas,0), NVL(dPorcCanceladas,0), NVL(iRechazadas,0), NVL(dPorcRechazadas,0), NVL(iAutorizadas,0), NVL(dPorcAutorizados,0), NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0), NVL(iTotalRechazadas,0), NVL(dTotalPorcRechazadas,0), NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0), pUsuario);
	
			
	END FOREACH;
	
		SELECT count(*)
		INTO iTotalReg
		FROM bdicnweb:"informix".sw_consultaincrementosperfilusuario
		WHERE usuario = pUsuario;
			
		RETURN cCodRet, cMensajeRet, iTotalReg;		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros para el reporte por perfil de usuario en un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111021.0902',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agregan los totales de las atendidas, autorizadas, canceladas y rechazadas',
'Fecha de modificación: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_cac_rep_perfil_usuario2(pFechaIni CHAR (10), pFechaFin CHAR(10), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
RETURNING CHAR(6)                         AS codigo_retorno,
          CHAR(80)                        AS mensaje_retorno,
		  CHAR(8)                         AS Numempleado,
		  CHAR(45)                        AS Nombre,
		  CHAR (25)                       AS Perfil_Puesto,
		  INTEGER                         AS Atendidas,
		  DECIMAL(18,2)                   AS PorcAtendidas,
		  INTEGER                         AS Canceladas,
		  DECIMAL(18,2)                   AS PorcCanceladas,
		  INTEGER                         AS Rechazadas,
		  DECIMAL(18,2)                   AS PorcRechazadas,
		  INTEGER                         AS Autorizadas,
		  DECIMAL(18,2)                   AS PorcAutorizadas,
		  
		  INTEGER                         AS TotalAtendidas,
		  DECIMAL(18,2)                   AS TotalPorcAtendidas,
		  INTEGER                         AS TotalCanceladas,
		  DECIMAL(18,2)                   AS TotalPorcCanceladas,
		  INTEGER                         AS TotalRechazadas,
		  DECIMAL(18,2)                   AS TotalPorcRechazadas,
		  INTEGER                         AS TotalAutorizadas,
		  DECIMAL(18,2)                   AS TotalPorcAutorizadas;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);
	DEFINE dPorcAtendidas		DECIMAL(18,2);	
	DEFINE dPorcCanceladas		DECIMAL(18,2);
	DEFINE dPorcRechazadas		DECIMAL(18,2);
	DEFINE dPorcAutorizados	    DECIMAL(18,2);
	DEFINE cDescripcion 		CHAR(25);
	DEFINE cNombre				CHAR(45);
	DEFINE cBandera 			CHAR(1);
	DEFINE iCanceladas			INTEGER;
	DEFINE iAutorizadas	     	INTEGER;
	DEFINE iRechazadas		    INTEGER;
	DEFINE cEjecutivo           CHAR(8);
	DEFINE cPuesto 				CHAR(2);
	DEFINE cRangoAutorizacion	CHAR(2);
	DEFINE iTotalReg 			INTEGER;
	DEFINE iTotalPerfil			INTEGER;
	
	DEFINE dTotalPorcAtendidas		DECIMAL(18,2);	
	DEFINE dTotalPorcCanceladas		DECIMAL(18,2);
	DEFINE dTotalPorcRechazadas		DECIMAL(18,2);
	DEFINE dTotalPorcAutorizados	DECIMAL(18,2);
	
	DEFINE iTotalTotalPerfil		INTEGER;
	DEFINE iTotalCanceladas			INTEGER;
	DEFINE iTotalAutorizadas	    INTEGER;
	DEFINE iTotalRechazadas		    INTEGER;
	---INICIALIZACIONES
	
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'Se realizó la consulta correctamente';
	LET dPorcAtendidas		     = 0;
	LET dPorcCanceladas		     = 0;
	LET dPorcRechazadas		     = 0;
	LET dPorcAutorizados	     = 0;
	LET iCanceladas		     	 = 0;
	LET iAutorizadas	     	 = 0;
	LET iRechazadas		     	 = 0;
	LET cEjecutivo				 = '';
	LET cPuesto 				 = '';
	LET cRangoAutorizacion		 = '';
	LET iTotalReg				 = 0;
	LET cDescripcion			 = '';
	LET cNombre 				 = '';
	LET cBandera				 = '';
	LET iTotalPerfil			 = 0;
	
	LET dTotalPorcAtendidas		 = 0;
	LET dTotalPorcCanceladas	 = 0;
	LET dTotalPorcRechazadas	 = 0;
	LET dTotalPorcAutorizados	 = 0;
	
	LET iTotalTotalPerfil	     = 0;
	LET iTotalCanceladas		 = 0;
	LET iTotalAutorizadas	     = 0;
	LET iTotalRechazadas		 = 0;

	BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			LET cMensajeRet=cErrorInfo;	 	
	
			RETURN cCodRet, cMensajeRet, NVL(cEjecutivo,''), NVL(cNombre,''), NVL(cDescripcion,''), NVL(iTotalPerfil,0), NVL(dPorcAtendidas,0), NVL(iCanceladas,0), NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
				NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_cac_rep_perfil_usuario.out';
	--TRACE ON;

	-- Se validan los parametros de entrada.
	IF NVL(pFechaini,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Falta un parámetro de fecha requerido para realizar  la consulta';
		RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,''),NVL(cNombre,''),NVL(cDescripcion,''),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
			NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Ciclo para obtener la cantidad de solicitudes atendidas por puesto y ejecutivo
	FOREACH WITH HOLD	
		SELECT SKIP pInicio FIRST pFin numEmpleado, nombre, perfilpuesto, atendidas, porcatendidas, canceladas, porccanceladas, rechazadas, porcrechazadas, 
		autorizadas, porcautorizadas, totalatendidas, totalporcatendidas, totalcanceladas, totalporccanceladas, totalrechazadas, 
		totalporcrechazadas, totalautorizadas, totalporcautorizadas 
		INTO cEjecutivo, cNombre, cDescripcion, iTotalPerfil, dPorcAtendidas, iCanceladas, dPorcCanceladas, iRechazadas, dPorcRechazadas, 
		iAutorizadas, dPorcAutorizados, iTotalTotalPerfil, dTotalPorcAtendidas, iTotalCanceladas, dTotalPorcCanceladas, iTotalRechazadas, dTotalPorcRechazadas, iTotalAutorizadas, dTotalPorcAutorizados
		FROM bdicnweb:"informix".sw_consultaincrementosperfilusuario
		WHERE usuario = pUsuario
			
		RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,''),NVL(cNombre,''),NVL(cDescripcion,''),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
			NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0) WITH RESUME;
		
	END FOREACH;	
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros para el reporte por perfil de usuario en un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111021.0902',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agregan los totales de las atendidas, autorizadas, canceladas y rechazadas',
'Fecha de modificación: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_cac_rep_revisioncac_total(pFechaIni CHAR (10), pFechaFin CHAR(10), pUsuario CHAR(10))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  INTEGER  AS total;
		  
		
---DECLARACIONES   
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);
DEFINE cComentario           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);

DEFINE dPorcStatusSuc		DECIMAL(18,2);
DEFINE dPorcStatusCen		DECIMAL(18,2);
DEFINE dPorcStatus			DECIMAL(18,2);
DEFINE dPorcStatusAcum		DECIMAL(18,2);
DEFINE dPorcStatusAcum2		DECIMAL(18,2);
DEFINE cStatus 				CHAR(2);
DEFINE cCausa 				CHAR(3);
DEFINE cDescripcion 		VARCHAR(100);
DEFINE cOrigen				CHAR(1);
DEFINE iTotalStatus 		INTEGER;
DEFINE iTotal 				INTEGER;
DEFINE iTotalRegistros 		INTEGER;
DEFINE iTotalStatusSuc		INTEGER;
DEFINE iTotalStatusCen		INTEGER;
DEFINE iTieneCausa 			INTEGER;
DEFINE iCont 				INTEGER;
DEFINE dPorSucursal         DECIMAL(18,2);
DEFINE dPorCentral          DECIMAL(18,2);
DEFINE iTotalReg 			INTEGER;
DEFINE iTotalCentral         DECIMAL(18,2);
DEFINE iTotalSucursal        DECIMAL(18,2);
DEFINE dporCasoSucursal       DECIMAL(18,2);
DEFINE dporCasoCentral       DECIMAL(18,2);

---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET cCodRet                  = '000000';
LET cMensajeRet              = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
LET dPorcStatusSuc			 = 0;
LET dPorcStatusCen			 = 0;
LET dPorcStatus			     = 0;
LET dPorcStatusAcum		     = 0;
LET dPorcStatusAcum2	     = 100;
LET iTotalStatus			 = 0;
LET iTotal			         = 0;
LET iTotalRegistros			 = 0;
LET iTotalStatusCen			 = 0;
LET iTotalStatusSuc			 = 0;
LET iTieneCausa				 = 0;
LET iCont					 = 0;
LET iTotalReg				 = 0;
LET cDescripcion			 = '';
LET cOrigen 				 = '';
LET cStatus 				 = '';
LET cCausa 					 = '';
LET dPorSucursal             = 0;
LET dPorCentral              = 0;
LET iTotalCentral            = 0;
LET iTotalSucursal           = 0;
LET dporCasoSucursal         = 0;
LET dporCasoCentral          = 0;


BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			LET cMensajeRet=cErrorInfo;
			IF iSqlErr IN (-1204,-1205,-1206) THEN
				LET cCodRet = '000002';
				LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
			END IF;	 
			RETURN cCodRet, cMensajeRet, iTotalReg;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_cac_rep_revisioncac.out';
	--TRACE ON;

	-- Se validan los parametros de entrada.
	IF NVL(pFechaini,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'FALTA PARAMETRO DE FECHA REQUERIDO PARA REALIZAR  LA CONSULTA';
		RETURN cCodRet, cMensajeRet, iTotalReg;
	END IF;
	-- Se borran registros de tabla de paso para insertar los datos de la consulta	
	DELETE FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac WHERE usuario = pUsuario;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
 
	FOREACH WITH HOLD
 
		SELECT origen 
		INTO cOrigen
		FROM "informix".sd_aumlincred_origen
		ORDER by  origen 
	 
		IF cOrigen = 'C' THEN	 
			-- Se insertan el total de registros por estatus
			FOREACH WITH HOLD
				SELECT status,TRIM(descripcion)
				INTO cStatus,cDescripcion
				FROM  "informix".sd_status_aumlincred 
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
				    INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen = cOrigen
					AND status = cStatus			
			
					INSERT INTO bdicnweb:"informix".sw_consultaincrementosreprevisioncac(status,causa,descripcion,totalRegCentral,porcentajeCentral,totalRegSucursal,porcentajeSucursal,usuario)
					VALUES(cStatus,'',cDescripcion,NVL(iTotalStatus,0),0,0,0,pUsuario);	 
		
				END FOREACH;  	
			END FOREACH;
			
			--se obtiene el total de los registros para esta consulta	
			SELECT NVL(SUM(totalRegCentral),0), COUNT(status)
			INTO iTotal, iTotalReg
			FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac 
			WHERE status = status
			AND causa = ''
			AND totalRegCentral <> 0
			AND usuario = pUsuario;
				
			LET iTotalRegistros = iTotal;
					
			IF iTotalReg <> 0 THEN
				-- Se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
				FOREACH
					SELECT status,descripcion,totalRegCentral
					INTO cStatus, cDescripcion, iTotalStatus
					FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac
					WHERE status = status
					AND causa = ''
					AND totalRegCentral <> 0
					AND usuario = pUsuario					
						
					LET dPorcStatus    = ((iTotalStatus * 100) / iTotal);
					
					IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
						LET iCont= iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus= 100 - dPorcStatusAcum;
						END IF;
						
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					ELSE
						LET iCont= iCont + 1;
						LET dPorcStatus= 100 - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
					END IF;
								
					UPDATE bdicnweb:"informix".sw_consultaincrementosreprevisioncac
					SET porcentajeCentral = dPorcStatus
					WHERE status=cStatus AND usuario = pUsuario;
				END FOREACH;
			END IF;
			
			-- Se insertan el total de registros por causas
			FOREACH WITH HOLD
				SELECT status, causa_status, TRIM(descripcion)
				INTO cStatus, cCausa, cDescripcion
				FROM "informix".sd_causas_aumlincred 
				WHERE mostrar_pantalla = '1'
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
					INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen = cOrigen
					AND status = cStatus
					AND causa_status = cCausa
		
					INSERT INTO bdicnweb:"informix".sw_consultaincrementosreprevisioncac(status,causa,descripcion,totalRegCentral,porcentajeCentral,totalRegSucursal,porcentajeSucursal,usuario)	
					VALUES(cStatus,cCausa,cDescripcion,NVL(iTotalStatus,0),0,0,0, pUsuario);	
				 
				END FOREACH;  		
			END FOREACH;	
			
			--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
			LET dPorcStatusAcum = 0;
			LET dPorcStatus = 0;
			LET iCont = 0;

			FOREACH WITH HOLD
				SELECT status, causa_status
                INTO cStatus, cCausa
				FROM  "informix".sd_causas_aumlincred
				WHERE mostrar_pantalla = '1'					
				ORDER BY status, causa_status
							
				SELECT NVL(SUM(totalRegCentral),0), COUNT(causa)
				INTO iTotal, iTotalReg
				FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac 
				WHERE status = cStatus
				AND causa <> ''
				AND totalRegCentral <> 0
				AND usuario = pUsuario;
							
				SELECT porcentajeCentral
				INTO dPorCentral
				FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac 
				WHERE status = cStatus
				AND causa = ""
				AND totalRegCentral <> 0
				AND usuario = pUsuario;
							
				IF iTotalReg <> 0 THEN			
					SELECT status,causa,descripcion,totalRegCentral
					INTO cStatus,cCausa,cDescripcion,iTotalStatus
					FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac
					WHERE status = cStatus
					AND causa = cCausa
					AND totalRegCentral <> 0
					AND usuario = pUsuario;
								
					IF NVL(iTotalStatus,0) <> 0 THEN
						LET dPorcStatus = ((iTotalStatus * dPorCentral) / iTotal);
						IF (dPorcStatusAcum + dPorcStatus) < dPorCentral THEN
							LET iCont= iCont + 1;
							IF iTotalReg = iCont THEN
								LET dPorcStatus= dPorCentral - dPorcStatusAcum;							
							END IF;
							LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
						ELSE
							LET iCont= iCont + 1;
							LET dPorcStatus= dPorCentral - dPorcStatusAcum;
							LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
						END IF;
										
						UPDATE bdicnweb:"informix".sw_consultaincrementosreprevisioncac
						SET porcentajeCentral = dPorcStatus
						WHERE status = cStatus
						AND causa = cCausa
						AND usuario = pUsuario;
					END IF;
				END IF;
					
				IF iTotalReg = iCont THEN
					LET dPorcStatusAcum = 0;
					LET dPorcStatus = 0;
					LET iCont = 0;
				END IF;		
			END FOREACH;
	ELSE 
		LET dPorcStatus = 0;
		IF cOrigen = 'S' THEN
			FOREACH WITH HOLD
				SELECT status, TRIM(descripcion)
				INTO cStatus, cDescripcion
				FROM  "informix".sd_status_aumlincred 
					
				FOREACH WITH HOLD
					SELECT COUNT(status)
					INTO iTotalStatus
					FROM  "informix".sd_bitacora_aumlincred 
					WHERE fecha_insert >= pFechaIni
			        AND fecha_insert <= pFechaFin
					AND origen = cOrigen
					AND status = cStatus			
					
					UPDATE bdicnweb:"informix".sw_consultaincrementosreprevisioncac 
					SET totalRegSucursal = iTotalStatus 
					WHERE status = cStatus 
					AND causa = '' 
					AND descripcion = cDescripcion
					AND usuario = pUsuario;
						
				END FOREACH;  	
			END FOREACH;
		--se obtiene el total de los registros para esta consulta	
				SELECT NVL(SUM(totalRegSucursal),0), COUNT(status)
					INTO iTotal,iTotalReg
				FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac 
				WHERE status=status
				AND causa = ''
				AND totalRegSucursal <> 0
				AND usuario = pUsuario;
				
				LET iTotalRegistros = iTotal;
					
				IF iTotalReg <> 0 THEN
					--se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
					FOREACH
						SELECT status,descripcion,totalRegSucursal
						INTO cStatus, cDescripcion,iTotalStatus
						FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac
						WHERE status=status
						AND causa = ''
						AND totalRegSucursal <> 0
						AND usuario = pUsuario
						
							LET dPorcStatus = ((iTotalStatus * 100) / iTotal);
							IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
								LET iCont= iCont + 1;
								IF iTotalReg = iCont THEN
									LET dPorcStatus= 100 - dPorcStatusAcum;
								END IF;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							ELSE
								LET iCont= iCont + 1;
								LET dPorcStatus= 100 - dPorcStatusAcum;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
							END IF;
								
						UPDATE bdicnweb:"informix".sw_consultaincrementosreprevisioncac
							SET porcentajeSucursal = dPorcStatus
						WHERE status = cStatus
						AND usuario = pUsuario;
				    END FOREACH;
					LET dPorcStatus = 0;
					LET dPorcStatusAcum = 0;
					
				END IF;
			
				-- Se insertan el total de registros por causas
				FOREACH WITH HOLD
					SELECT status,causa_status,TRIM(descripcion)
					INTO cStatus,cCausa,cDescripcion
					FROM "informix".sd_causas_aumlincred
					WHERE mostrar_pantalla = "1"				
					
					FOREACH WITH HOLD
						SELECT COUNT(status)
						INTO iTotalStatus
						FROM  "informix".sd_bitacora_aumlincred 
						WHERE fecha_insert >= pFechaIni
						AND fecha_insert <= pFechaFin
						AND origen = cOrigen
						AND status = cStatus
						AND causa_status = cCausa
				
						UPDATE bdicnweb:"informix".sw_consultaincrementosreprevisioncac 
						SET causa = cCausa, totalRegSucursal = iTotalStatus, porcentajeSucursal = 0 
						WHERE status = cStatus 
						AND descripcion = cDescripcion
						AND usuario = pUsuario;
				 
					END FOREACH;  
					LET dPorcStatus = 0;	
					LET dPorcStatusAcum = 0;				
				END FOREACH;	
			
				LET dPorcStatus = 0;
				LET dPorcStatusAcum = 0;
			
				-- Se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
				LET dPorcStatusAcum = 0;
				LET dPorcStatus = 0;
				LET iCont = 0;
				LET dPorSucursal = 0;
	
				FOREACH WITH HOLD
					SELECT status, causa_status
					INTO cStatus, cCausa
					FROM "informix".sd_causas_aumlincred
					WHERE mostrar_pantalla = '1'					
					ORDER BY status,causa_status
					
					SELECT NVL(SUM(totalRegSucursal),0), COUNT(causa)
					INTO iTotal,iTotalReg
					FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac 
					WHERE status = cStatus
					AND causa <> ''
					AND totalRegSucursal <>0
					AND usuario = pUsuario;
							
					SELECT porcentajeSucursal
					INTO dPorSucursal 
					FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac 
					WHERE status=cStatus
					AND causa = ''
					AND totalRegSucursal <> 0
					AND usuario = pUsuario;
							
					IF iTotalReg <> 0 THEN			
						SELECT status,causa,descripcion,totalRegSucursal
						INTO cStatus,cCausa,cDescripcion,iTotalStatus
						FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac
						WHERE status = cStatus
						AND causa = cCausa
						AND totalRegSucursal <> 0
						AND usuario = pUsuario;
								
						IF NVL(iTotalStatus,0) <> 0 THEN
							LET dPorcStatus = ((iTotalStatus * dPorSucursal) / iTotal);
							IF (dPorcStatusAcum + dPorcStatus) < dPorSucursal THEN
								LET iCont= iCont + 1;
								IF iTotalReg = iCont THEN
									LET dPorcStatus = dPorSucursal - dPorcStatusAcum;							
								END IF;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
							ELSE
								LET iCont= iCont + 1;
								LET dPorcStatus = dPorSucursal - dPorcStatusAcum;
								LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
							END IF;
										
							UPDATE bdicnweb:"informix".sw_consultaincrementosreprevisioncac
							SET porcentajeSucursal = dPorcStatus
							WHERE status = cStatus
							AND causa = cCausa
							AND usuario = pUsuario;
						END IF;

					END IF;			
					
					IF iTotalReg = iCont THEN
						LET dPorcStatusAcum = 0;
						LET dPorcStatus = 0;
						LET iCont = 0;
					END IF;		
				END FOREACH;		
			
				LET dPorcStatus= 0;
			END IF;
		END IF;
	END FOREACH;
	
	--Se obtienen totales de ambos casos y se guardan en la tabla
	FOREACH
		SELECT SUM(totalRegCentral),SUM(totalRegSucursal),SUM(porcentajeCentral), SUM(porcentajeSucursal)
		INTO iTotalStatusCen, iTotalStatusSuc, dporCasoCentral, dPorCasoSucursal
		FROM  bdicnweb:"informix".sw_consultaincrementosreprevisioncac
		WHERE causa = ''
		AND usuario = pUsuario

		UPDATE bdicnweb:"informix".sw_consultaincrementosreprevisioncac
		SET totalCentral = iTotalStatusCen,
		porCentral = dporCasoCentral,
		totalSucursal = iTotalStatusSuc,
		porSucursal = dPorCasoSucursal
		WHERE usuario = pUsuario;		

	END FOREACH;

	SELECT count(*)
	INTO iTotalReg
	FROM bdicnweb:"informix".sw_consultaincrementosreprevisioncac
	WHERE usuario = pUsuario;

	RETURN cCodRet, cMensajeRet, iTotalReg;

	

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111019.1402',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Josue Remberto Zazueta Acosta',
'Modificacion: Se borra codigo comentado,se agregan informix y bd a las tablas que no tenian,Se implementan reglas de informix',
'Fecha de modificacion: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta';

CREATE PROCEDURE "informix".sp_cac_rep_revisioncac2(pFechaIni CHAR (10), pFechaFin CHAR(10), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  INTEGER  AS tiene_causa,
		  CHAR(100) AS descripcion,
		  INTEGER AS totalRegCentral,
		  DECIMAL(18,2) AS porcentajeCentral,
		  INTEGER AS totalCentral,
		  DECIMAL(18,2) AS totPorCentral,
		  INTEGER AS totalRegSucursal,
		  DECIMAL(18,2) AS porcentajeSucursal,
		  INTEGER AS totalSucursal,
		  DECIMAL(18,2) AS totPorSucursal;
		  
		
	-- DECLARACIONES   
	DEFINE cCodRet               CHAR(6); 
	DEFINE cMensajeRet           CHAR(80);
	DEFINE cComentario           CHAR(80);
	DEFINE iSqlErr      	     INTEGER;
	DEFINE iIsamErr              INTEGER;
	DEFINE cErrorInfo            CHAR(80);
	
	DEFINE dPorcStatusSuc		DECIMAL(18,2);
	DEFINE dPorcStatusCen		DECIMAL(18,2);
	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE dPorcStatusAcum2		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE cDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE cOrigen				CHAR(1);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTotalStatusSuc		INTEGER;
	DEFINE iTotalStatusCen		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE dPorSucursal         DECIMAL(18,2);
	DEFINE dPorCentral          DECIMAL(18,2);
	DEFINE iTotalReg 			INTEGER;
	DEFINE iTotalCentral        DECIMAL(18,2);
	DEFINE iTotalSucursal       DECIMAL(18,2);
	DEFINE dporCasoSucursal     DECIMAL(18,2);
	DEFINE dporCasoCentral      DECIMAL(18,2);
	
	---INICIALIZACIONES
	
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
	LET dPorcStatusSuc			 = 0;
	LET dPorcStatusCen			 = 0;
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET dPorcStatusAcum2	     = 100;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTotalStatusCen			 = 0;
	LET iTotalStatusSuc			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET cDescripcion			 = '';
	LET cBandera				 = '';
	LET cOrigen 				 = '';
	LET cStatus 				 = '';
	LET cCausa 					 = '';
	LET dPorSucursal             = 0;
	LET dPorCentral              = 0;
	LET iTotalCentral            = 0;
	LET iTotalSucursal           = 0;
	LET dporCasoSucursal         = 0;
	LET dporCasoCentral          = 0;
	
	
	BEGIN
	
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			IF iSqlErr IN (-1204,-1205,-1206) THEN
				LET cCodRet = '000002';
				LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
			END IF;
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalStatusCen, 0), NVL(dPorcStatusCen, 0), NVL(iTotalCentral, 0), NVL(dporCasoCentral, 0), NVL(iTotalStatusSuc, 0),NVL(dPorcStatusSuc, 0), NVL(iTotalSucursal, 0), NVL(dPorCasoSucursal, 0);
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_cac_rep_revisioncac2.out';
	--TRACE ON;

	-- Se validan los parametros de entrada.
	IF NVL(pFechaini,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'FALTA PARAMETRO DE FECHA REQUERIDO PARA REALIZAR  LA CONSULTA';
		RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalStatusCen, 0), NVL(dPorcStatusCen, 0), NVL(iTotalCentral, 0), NVL(dporCasoCentral, 0),
				NVL(iTotalStatusSuc, 0),NVL(dPorcStatusSuc, 0), NVL(iTotalSucursal, 0), NVL(dPorCasoSucursal, 0);
	END IF;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
  
	-- Se obtiene los datos de la tabla
	FOREACH
		SELECT skip pInicio limit pFin status,causa,descripcion,totalRegCentral,porcentajeCentral,totalCentral,porCentral,totalRegSucursal,porcentajeSucursal, totalSucursal,porSucursal
		INTO cStatus,cCausa,cDescripcion,iTotalStatusCen,dPorcStatusCen,iTotalCentral, dporCasoCentral, iTotalStatusSuc,dPorcStatusSuc, iTotalSucursal, dPorCasoSucursal
		FROM bdicnweb:"informix".sw_consultaincrementosreprevisioncac
		WHERE usuario = pUsuario
		ORDER BY status,causa
	
		IF NVL(cCausa,'') <> '' THEN
			LET iTieneCausa=1;
			LET  cDescripcion = TRIM (cCausa) || '-' || TRIM (cDescripcion);
		ELSE
			LET iTieneCausa=0;
		END IF;
	
		RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalStatusCen, 0), NVL(dPorcStatusCen, 0), NVL(iTotalCentral, 0), NVL(dporCasoCentral, 0),
				NVL(iTotalStatusSuc, 0),NVL(dPorcStatusSuc, 0), NVL(iTotalSucursal, 0), NVL(dPorCasoSucursal, 0) WITH RESUME;
	END FOREACH;

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111019.1402',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Josue Remberto Zazueta Acosta',
'Modificacion: Se borra codigo comentado,se agregan informix y bd a las tablas que no tenian,Se implementan reglas de informix',
'Fecha de modificacion: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_revisioncentral_total(pFechaIni CHAR (10), pFechaFin CHAR(10), pUsuario CHAR(10))
	RETURNING CHAR(6)  AS codigo_retorno,
			CHAR(80) AS mensaje_retorno,
			INTEGER  AS total;
		  
	---DECLARACIONES
	DEFINE cCodRet               CHAR(6);
	DEFINE cMensajeRet           CHAR(80);
	DEFINE cComentario           CHAR(80);
	DEFINE iSqlErr      	     INTEGER;
	DEFINE iIsamErr              INTEGER;
	DEFINE cErrorInfo            CHAR(80);
	
	DEFINE dPorcCasosCac		DECIMAL(18,2);
	DEFINE dPorcCasosAuto		DECIMAL(18,2);
	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE dPorcStatusAcum2		DECIMAL(18,2);
	DEFINE dPorcenStatus		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE cDescripcion 		VARCHAR(100);
	DEFINE cOrigen				CHAR(1);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTotalCasosCac		INTEGER;
	DEFINE iTotalCasosAuto		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dtFecha 				DATE;
	DEFINE itotalCAC            INTEGER;
	DEFINE itotalAUTO           INTEGER;
	DEFINE dporCAC              DECIMAL(18,2);
	DEFINE dporAUTO             DECIMAL(18,2);

	---INICIALIZACIONES
	
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'Se realizó la consulta correctamente';
	LET dPorcCasosCac			 = 0;
	LET dPorcCasosAuto			 = 0;
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET dPorcStatusAcum2	     = 100;
	LET dPorcenStatus			 = 0;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTotalCasosCac			 = 0;
	LET iTotalCasosAuto			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET cDescripcion			 = '';
	LET cOrigen 				 = '';
	LET cStatus 				 = '';
	LET cCausa 					 = '';
	LET itotalCAC                = 0;
	LET itotalAUTO               = 0;
	LET dporCAC                  = 0;
	LEt dporAUTO                 = 0;
	
	
	BEGIN
	
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	IF iSqlErr != 0 THEN
		LET cCodRet= iSqlErr;
		LET cMensajeRet=cErrorInfo;
		IF iSqlErr IN (-1204,-1205,-1206) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'Parámetro de fecha invalido para realizar  la consulta';
		END IF;
		RETURN cCodRet, cMensajeRet, iTotalReg;
	END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_cac_rep_revisioncentral_total.out';
	--TRACE ON;
	
	--se validan los parametros de entrada.
	IF NVL(pFechaIni,'') = '' OR NVL(pFechaFin,'') = '' OR NVL(pUsuario,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Falta parámetro de fechas requerido para realizar la consulta';
		RETURN cCodRet, cMensajeRet, iTotalReg;
	
	END IF;
	
	-- Se eliminan los dato de la estructura para insertar los datos de la consulta
	DELETE FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral WHERE usuario = pUsuario;

	LET cOrigen = 'C';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- Se obtienen los datos referentes a las solicitudes que requieren revision CAC (Casos CAC)
	-- Se insertan el total de registros por estatus
		FOREACH WITH HOLD
			SELECT status, TRIM(descripcion)
			INTO cStatus, cDescripcion
			FROM "informix".sd_status_aumlincred
	
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred
				WHERE fecha_insert >= pFechaIni
				AND fecha_insert <= pFechaFin
				AND origen = cOrigen
				AND status = cStatus
				AND revisioncac = 1
	
					INSERT INTO bdicnweb:"informix".sw_consultaincrementosrevisioncentral(status,causa,descripcion,totalRegCac,porcentajeCac,totalRegAuto,porcentajeAuto,usuario)
					VALUES(cStatus,'',cDescripcion,NVL(iTotalStatus,0),0,0,0,pUsuario);
	
			END FOREACH;
		END FOREACH;
		-- Se obtiene el total de los registros para esta consulta
			SELECT NVL(SUM(totalRegCac),0), COUNT(status)
			INTO iTotal,iTotalReg
			FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
			WHERE status = status
			AND causa = ''
			AND totalRegCac <> 0
			AND usuario = pUsuario;
	
			LET iTotalRegistros = iTotal;
	
			IF iTotalReg <> 0 THEN
				--se realiza el calculo del porcentaje por cada status del total de registros de la consulta
				FOREACH
					SELECT status,descripcion,totalRegCac
					INTO cStatus, cDescripcion,iTotalStatus
					FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
					WHERE status = status
					AND causa = ''
					AND totalRegCac <> 0
					AND usuario = pUsuario
	
						LET dPorcStatus = ((iTotalStatus * 100) / iTotalRegistros);
						IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
							LET iCont= iCont + 1;
							IF iTotalReg = iCont THEN
								LET dPorcStatus= 100 - dPorcStatusAcum;
							END IF;
							LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
						ELSE
							LET iCont= iCont + 1;
							LET dPorcStatus= 100 - dPorcStatusAcum;
							LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
						END IF;
	
					UPDATE bdicnweb:"informix".sw_consultaincrementosrevisioncentral
					SET porcentajeCac = dPorcStatus
					WHERE status = cStatus
					AND causa = ''
					AND usuario = pUsuario;
				END FOREACH;
			END IF;
	---se insertan el total de registros por causas
		FOREACH WITH HOLD
			SELECT status, causa_status, TRIM(descripcion)
			INTO cStatus, cCausa, cDescripcion
			FROM "informix".sd_causas_aumlincred
			WHERE mostrar_pantalla = '1'
	
			FOREACH WITH HOLD
				SELECT COUNT(status)
					INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred
				WHERE fecha_insert >= pFechaIni
				AND fecha_insert <= pFechaFin
				AND origen = cOrigen
				AND status = cStatus
				AND causa_status = cCausa
				AND revisioncac = 1
	
							INSERT INTO bdicnweb:"informix".sw_consultaincrementosrevisioncentral(status,causa,descripcion,totalRegCac,porcentajeCac,totalRegAuto,porcentajeAuto,usuario)
							VALUES(cStatus,cCausa,cDescripcion,NVL(iTotalStatus,0),0,0,0,pUsuario);
	
			END FOREACH;
		END FOREACH;
		-- Se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status
		LET dPorcStatusAcum = 0;
		LET dPorcStatus = 0;
		LET iCont = 0;
	
		FOREACH WITH HOLD
				SELECT status,causa_status
				INTO cStatus,cCausa
				FROM  "informix".sd_causas_aumlincred
				WHERE mostrar_pantalla = '1'
				ORDER BY status,causa_status
	
						SELECT NVL(SUM(totalRegCac),0), COUNT(causa)
						INTO iTotal,iTotalReg
						FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
						WHERE status=cStatus
						AND causa <> ''
						AND totalRegCac <> 0
						AND usuario = pUsuario;
	
					IF iTotalReg <> 0 THEN
							SELECT status,causa,descripcion,totalRegCac
								INTO cStatus,cCausa,cDescripcion,iTotalStatus
							FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
							WHERE status = cStatus
							AND causa = cCausa
							AND totalRegCac <> 0
							AND usuario = pUsuario;
	
						IF NVL(iTotalStatus,0) <> 0 THEN
							LET dPorcStatus = ((iTotalStatus * 100) / iTotalRegistros);
							UPDATE bdicnweb:"informix".sw_consultaincrementosrevisioncentral
							SET porcentajeCac = dPorcStatus
							WHERE status = cStatus
							AND causa = cCausa
							AND usuario = pUsuario;
						END IF;
					END IF;
	
				IF iTotalReg = iCont THEN
					LET dPorcStatusAcum = 0;
					LET dPorcStatus = 0;
					LET iCont = 0;
				END IF;
		END FOREACH;
		-- Se obtienen los datos referentes a las solicitudes que no requieren revision Cac (Casos Automaticos)
		-- Se insertan el total de registros por estatus
		FOREACH WITH HOLD
			SELECT status,TRIM(descripcion)
			INTO cStatus,cDescripcion
			FROM  "informix".sd_status_aumlincred
	
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred
				WHERE fecha_insert >= pFechaIni
				AND fecha_insert <= pFechaFin
				AND origen = cOrigen
				AND status = cStatus
				AND revisioncac = 0
	
					UPDATE bdicnweb:"informix".sw_consultaincrementosrevisioncentral
					SET totalRegAuto = iTotalStatus
					WHERE status = cStatus
					AND descripcion = cDescripcion
					AND usuario = pUsuario;
	
			END FOREACH;
		END FOREACH;
		
		-- Se obtiene el total de los registros para esta consulta
			SELECT NVL(SUM(totalRegAuto),0), COUNT(status)
				INTO iTotal,iTotalReg
			FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
			WHERE status = status
			AND causa = ''
			AND totalRegAuto <> 0
			AND usuario = pUsuario;
	
			LET iTotalRegistros = iTotal;
	
			IF iTotalReg <> 0 THEN
				-- Se realiza el calculo del porcentaje por cada status del total de registros de la consulta
				FOREACH
					SELECT status,descripcion,totalRegAuto
						INTO cStatus, cDescripcion,iTotalStatus
					FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
					WHERE status = status
					AND causa = ''
					AND totalRegAuto <> 0
					AND usuario = pUsuario
	
						LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);
						IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
							LET iCont= iCont + 1;
							IF iTotalReg = iCont THEN
								LET dPorcStatus= 100 - dPorcStatusAcum;
							END IF;
							LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
						ELSE
							LET iCont= iCont + 1;
							LET dPorcStatus= 100 - dPorcStatusAcum;
							LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
						END IF;
	
					UPDATE bdicnweb:"informix".sw_consultaincrementosrevisioncentral
						SET porcentajeAuto = dPorcStatus
					WHERE status = cStatus
					AND causa = ''
					AND usuario = pUsuario;
				END FOREACH;
			END IF;
		-- Se insertan el total de registros por causas
		FOREACH WITH HOLD
			SELECT status,causa_status,TRIM(descripcion)
				INTO cStatus,cCausa,cDescripcion
			FROM  "informix".sd_causas_aumlincred
			WHERE mostrar_pantalla = '1'
	
			FOREACH WITH HOLD
				SELECT COUNT(status)
					INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred
				WHERE fecha_insert >= pFechaIni
				AND fecha_insert <= pFechaFin
				AND origen = cOrigen
				AND status = cStatus
				AND causa_status = cCausa
				AND RevisionCac = 0
	
					UPDATE bdicnweb:"informix".sw_consultaincrementosrevisioncentral
					SET totalRegAuto = iTotalStatus
					WHERE status = cStatus
					AND causa = cCausa
					AND descripcion = cDescripcion
					AND usuario = pUsuario;
	
			END FOREACH;
		END FOREACH;
		--se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status
		LET dPorcStatusAcum = 0;
		LET dPorcStatus = 0;
		LET iCont = 0;
	
		FOREACH WITH HOLD
				SELECT status,causa_status
					INTO cStatus,cCausa
				FROM  "informix".sd_causas_aumlincred
				WHERE mostrar_pantalla = '1'
				ORDER BY status,causa_status
	
						SELECT NVL(SUM(totalRegAuto),0), COUNT(causa)
							INTO iTotal,iTotalReg
						FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
						WHERE status=cStatus
						AND causa <> ''
						AND totalRegAuto <> 0
						AND usuario = pUsuario;
	
					IF iTotalReg <> 0 THEN
						--Se obtiene porcentaje del estatus
						SELECT porcentajeAuto
						INTO dPorcenStatus
						FROM bdicnweb:"informix".sw_consultaincrementosrevisioncentral
						WHERE status = cStatus
						AND causa = ''
						AND porcentajeAuto <> 0
						AND usuario = pUsuario;
						
						-- Se obtiene el total de registros de status por su causa
							SELECT status,causa,descripcion,totalRegAuto
								INTO cStatus,cCausa,cDescripcion,iTotalStatus
							FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
							WHERE status = cStatus
							AND causa = cCausa
							AND totalRegAuto <> 0
							AND usuario = pUsuario;
	
						IF NVL(iTotalStatus,0) <> 0 THEN
								LET dPorcStatus    = ((iTotalStatus * 100) / iTotalRegistros);
								IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
									LET iCont= iCont + 1;
									IF iTotalReg = iCont THEN
										LET dPorcStatus= dPorcenStatus - dPorcStatusAcum;
									END IF;
									LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
								ELSE
									LET iCont= iCont + 1;
									LET dPorcStatus= iTotalStatus - dPorcStatusAcum;
									LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
								END IF;
								UPDATE bdicnweb:"informix".sw_consultaincrementosrevisioncentral
									SET porcentajeAuto = dPorcStatus
								WHERE status = cStatus
								AND causa = cCausa
								AND usuario = pUsuario;
						END IF;
					END IF;
	
				IF iTotalReg = iCont THEN
					LET dPorcStatusAcum = 0;
					LET dPorcStatus = 0;
					LET iCont = 0;
				END IF;
		END FOREACH;
	
		-- Se obtienen totales de ambos casos y se guardan en la tabla
		FOREACH
			SELECT SUM(totalRegCac),SUM(totalRegAuto), SUM(porcentajeCac), SUM (porcentajeAuto)
				INTO iTotalCasosCac, iTotalCasosAuto, dporCAC, dporAUTO
			FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
			WHERE causa = '' AND usuario = pUsuario
	
				UPDATE bdicnweb:"informix".sw_consultaincrementosrevisioncentral
				SET totalCAC = iTotalCasosCac,
					porCAC = dporCAC,
					totalAUTO = iTotalCasosAuto,
					porAUTO = dporAUTO
				WHERE usuario = pUsuario;
	
		END FOREACH;
	
	
		-- Se obtiene los datos de la tabla
		SELECT count(*)
			INTO iTotalReg
		FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
		WHERE usuario = pUsuario;
		
		RETURN cCodRet, cMensajeRet, iTotalReg;

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111019.1402',
'BD: BDICRED',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Crédito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_revisioncentral2(pFechaIni CHAR (10), pFechaFin CHAR(10), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		  INTEGER  AS tiene_causa,
		  CHAR(100) AS descripcion,
		  INTEGER AS totalRegCasosCac,
		  DECIMAL(18,2) AS porcentajeCasosCac,
	      INTEGER AS totCAC,
		  DECIMAL(18,2) AS porCAC,
		  INTEGER AS totalRegCasosAuto,
		  DECIMAL(18,2) AS porcentajeCasosAuto,
		  INTEGER AS totAUTO,
		  DECIMAL(18,2) AS porAUTO;
	
	-- DECLARACIONES
	DEFINE cCodRet               CHAR(6);
	DEFINE cMensajeRet           CHAR(80);
	DEFINE cComentario           CHAR(80);
	DEFINE iSqlErr      	     INTEGER;
	DEFINE iIsamErr              INTEGER;
	DEFINE cErrorInfo            CHAR(80);
	
	DEFINE dPorcCasosCac		DECIMAL(18,2);
	DEFINE dPorcCasosAuto		DECIMAL(18,2);
	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE dPorcStatusAcum2		DECIMAL(18,2);
	DEFINE dPorcenStatus		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE cDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE cOrigen				CHAR(1);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTotalCasosCac		INTEGER;
	DEFINE iTotalCasosAuto		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dtFecha 				DATE;
	DEFINE itotalCAC            INTEGER;
	DEFINE itotalAUTO           INTEGER;
	DEFINE dporCAC              DECIMAL(18,2);
	DEFINE dporAUTO             DECIMAL(18,2);
	
	---INICIALIZACIONES
	
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'Se realizó la consulta correctamente';
	LET dPorcCasosCac			 = 0;
	LET dPorcCasosAuto			 = 0;
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET dPorcStatusAcum2	     = 100;
	LET dPorcenStatus			 = 0;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTotalCasosCac			 = 0;
	LET iTotalCasosAuto			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET cDescripcion			 = '';
	LET cBandera				 = '';
	LET cOrigen 				 = '';
	LET cStatus 				 = '';
	LET cCausa 					 = '';
	LET itotalCAC                = 0;
	LET itotalAUTO               = 0;
	LET dporCAC                  = 0;
	LEt dporAUTO                 = 0;
	
	
	BEGIN
	
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	IF iSqlErr != 0 THEN
		LET cCodRet= iSqlErr;
		LET cMensajeRet=cErrorInfo;
		IF iSqlErr IN (-1204,-1205,-1206) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'Parámetro de fecha invalido para realizar  la consulta';
		END IF;

		RETURN cCodRet, cMensajeRet,0,'',0,0,0 ,0,0,0,0,0;
	END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_cac_rep_revisioncentral2.out';
	--TRACE ON;
	
	-- Se validan los parametros de entrada.
	IF NVL(pFechaIni,'') = ''  OR NVL(pFechaFin,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Falta parámetro de fechas requerido para realizar la consulta';
		RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalCasosCac, 0), NVL(dPorcCasosCac, 0), NVL(itotalCAC, 0),NVL(dporCAC, 0),
					NVL(iTotalCasosAuto, 0),NVL(dPorcCasosAuto, 0), NVL(itotalAUTO, 0), NVL(dporAUTO, 0);
	
	END IF;
	
		--se obtiene los datos de la tabla
		FOREACH
			SELECT skip pInicio limit pFin status,causa,descripcion,totalRegCac,porcentajeCac,totalCAC,porCAC, totalRegAuto,porcentajeAuto, totalAUTO, porAUTO
				INTO cStatus,cCausa,cDescripcion,iTotalCasosCac,dPorcCasosCac, itotalCAC, dporCAC, iTotalCasosAuto,dPorcCasosAuto, itotalAUTO, dporAUTO
			FROM  bdicnweb:"informix".sw_consultaincrementosrevisioncentral
			WHERE usuario = pUsuario
			ORDER BY status, causa
	
			IF NVL(cCausa,"") <> "" THEN
				LET iTieneCausa=1;
				LET  cDescripcion = TRIM (cCausa) || '-' || TRIM (cDescripcion);
			ELSE
				LET iTieneCausa=0;
			END IF;
			RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0),NVL(cDescripcion, ''),NVL(iTotalCasosCac, 0), NVL(dPorcCasosCac, 0), NVL(itotalCAC, 0),NVL(dporCAC, 0),
					NVL(iTotalCasosAuto, 0),NVL(dPorcCasosAuto, 0), NVL(itotalAUTO, 0), NVL(dporAUTO, 0) WITH RESUME;
		END FOREACH;
	
	
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111019.1402',
'BD: BDICRED',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 14/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Crédito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aplicados2(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pOrigen CHAR(1), pOpcFecha CHAR(1), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,     
			  DATE  		AS fecha_atencion,
			  VARCHAR(20) 	AS Numero_solicitud,
			  CHAR(8) 		AS Origen,
			  VARCHAR(20) 	AS Numero_Cliente,
			  VARCHAR(26) 	AS Apell_Paterno,
			  VARCHAR(26) 	AS Apell_Materno,
			  VARCHAR(53) 	AS Nombre,
			  DECIMAL(18,2) AS Lincred_actual,
			  DECIMAL(18,2) AS Lincred_sugerida,
			  DECIMAL(18,2) AS Incremento,
			  CHAR(2) 		AS Status,
			  VARCHAR(45) 	AS AnalistaCac,
			  VARCHAR(45) 	AS Analista2nivel,
			  VARCHAR(45) 	AS Analista3nivel,
			  VARCHAR(45) 	AS Analista4nivel,
			  VARCHAR(106) 	AS motivo,
			  DATE          AS FechaStatus,
			  INTEGER       AS TotalNumReg,
			  VARCHAR(45)   AS NomEjecutivoMaxPuesto;
			  
			  
	---DECLARACIONES         
	DEFINE cCodRet               	CHAR(6); 
	DEFINE cMensajeRet           	CHAR(80);
	DEFINE cComentario           	CHAR(80);
	DEFINE iSqlErr      	     	INTEGER;
	DEFINE iIsamErr              	INTEGER;
	DEFINE iCon            		 	INTEGER;
	DEFINE cErrorInfo            	CHAR(80);

	DEFINE  dtFechaAtencion 		DATE;
	DEFINE vcNumSol 				VARCHAR(20);	
	DEFINE cOrigen  				CHAR(8);
	DEFINE vcNumCte 				VARCHAR(20);
	DEFINE vcApellPaterno			VARCHAR(26);
	DEFINE vcApellMaterno 			VARCHAR(26);
	DEFINE vcNombre 				VARCHAR(53);
	DEFINE dLinCredAct 		    	DECIMAL(18,2);
	DEFINE dLinCredCal 	     		DECIMAL(18,2);
	DEFINE dIncremento				DECIMAL(18,2);
	DEFINE dMontoIncremento			DECIMAL(18,2);
	DEFINE cStatus 					CHAR(2);
	DEFINE vcAnalistaCac			VARCHAR(45);
	DEFINE vcAnalista2nivel 		VARCHAR(45);
	DEFINE vcAnalista3nivel 		VARCHAR(45);
	DEFINE vcAnalista4nivel 		VARCHAR(45);

	DEFINE vcMotivo 				VARCHAR(106);
	DEFINE cCausa 					CHAR(3);
	DEFINE cPuesto 					CHAR(3);
	DEFINE cNomEjecutivo 			CHAR(45);
	DEFINE dtFecha 					DATE;
	DEFINE dtFecha_status 			DATE;
	DEFINE iContador				INTEGER;
	DEFINE cNomEjecutivoMaxPuesto	CHAR(45);
	DEFINE cEjecutivo				CHAR(10);
	DEFINE dfecha  					CHAR(10);
	

	---INICIALIZACIONES
	LET iSqlErr                  	= 0;
	LET iIsamErr                 	= 0;
	LET iCon                 	 	= 0;
	LET cErrorInfo               	= '';
	LET cCodRet                  	= '000000';
	LET cMensajeRet              	= 'SE REALIZO LA CONSULTA CORRECTAMENTE';

	LET  dtFechaAtencion 		 	= DATE(1);
	LET vcNumSol 			 		= '';	
	LET cOrigen  		     		= '';
	LET vcNumCte 			 		= '';
	LET vcApellPaterno		 		= '';
	LET vcApellMaterno 		 		= '';
	LET vcNombre 			 		= '';
	LET dLinCredAct 		 		= 0;
	LET dLinCredCal 	     		= 0;
	LET dIncremento			 		= 0;
	LET dMontoIncremento	 		= 0;
	LET cStatus 			 		= '';
	LET vcAnalistaCac		 		= '';
	LET vcAnalista2nivel 	 		= '';
	LET vcAnalista3nivel 	 		= '';
	LET vcAnalista4nivel      		= '';
	LET vcMotivo 			 		= '';
	LET cCausa 			 		    = '';
	LET cPuesto 			 		= '';
	LET cNomEjecutivo	 		    = '';
	LET dtFecha_status 				= DATE(1);
	LET iContador					= 0;
	LET cNomEjecutivoMaxPuesto		= '';
	LET cEjecutivo					= '';
	LET dfecha 						=  '';

	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	
				RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				       NVL(vcNombre,''),0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''),'', NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');	
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_gral_aumlincred_aplicados.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pStatus IS NULL THEN 
		 LET pStatus = '';
		END IF;
		
		-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
		IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
			RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''),'', NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');
		ELSE
		
				FOREACH WITH HOLD							
					SELECT skip pInicio limit pFin fecha_atencion, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, 
						nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, 
						analista3nivel, analista4nivel, motivo, fechastatus, totalnumreg, nomejecutivomaxpuesto
						INTO  dtFechaAtencion,vcNumSol,cOrigen,vcNumCte, vcApellPaterno, vcApellMaterno, vcNombre, 
						dLinCredAct, dLinCredCal, dIncremento, cStatus, vcAnalistaCac, vcAnalista2nivel, vcAnalista3nivel, vcAnalista4nivel,
						vcMotivo, dtFecha_status, iContador, cNomEjecutivoMaxPuesto
						FROM bdicnweb:"informix".sw_consultaincrementosgralaplicados 
						WHERE usuario = pUsuario
									
					RETURN cCodRet, cMensajeRet, dtFechaAtencion, NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
						NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'') WITH RESUME;	
				END FOREACH; 
				
				
		END IF; 
						
		IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
			LET cCodRet= '000003';
			LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
			RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');
		END IF;	   		
			
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha (Fecha Origen o Fecha Atencion)',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 06/02/2014',
'MODIFICO : Daniel Lazalde',
'BD: BDICRED',
'VERSION: 20140206.0001',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aut_tot(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pOrigen CHAR(1), pUsuario CHAR(10))
        RETURNING CHAR(6)               AS codigo_retorno,
                  CHAR(80)              AS mensaje_retorno,     
                  INTEGER       		AS TotalRegs;
                          
                          
        ---DECLARACIONES         
        DEFINE cCodRet                  CHAR(6); 
        DEFINE cMensajeRet              CHAR(80);
		DEFINE iTotReg             		INTEGER;
		DEFINE iSqlErr             		INTEGER;
		DEFINE iIsamErr             	INTEGER;
		DEFINE iCon                     INTEGER;
		DEFINE cErrorInfo             	CHAR(80);
		
		DEFINE dtFechaOrigen            DATE;
        DEFINE vcNumSol                 VARCHAR(20);    
        DEFINE cOrigen                  CHAR(1);
        DEFINE vcNumCte                 VARCHAR(20);
        DEFINE vcApellPaterno           VARCHAR(26);
        DEFINE vcApellMaterno           VARCHAR(26);
        DEFINE vcNombre                 VARCHAR(53);
        DEFINE dLinCredAct              DECIMAL(18,2);
        DEFINE dLinCredCal              DECIMAL(18,2);
        DEFINE dIncremento              DECIMAL(18,2);
        DEFINE dMontoIncremento         DECIMAL(18,2);
        DEFINE cStatus                  CHAR(2);
        DEFINE vcAnalistaCac            VARCHAR(45);
        DEFINE vcAnalista2nivel         VARCHAR(45);
        DEFINE vcAnalista3nivel         VARCHAR(45);
        DEFINE vcAnalista4nivel         VARCHAR(45);

        DEFINE vcMotivo                 VARCHAR(106);
        DEFINE cCausa                   CHAR(3);
        DEFINE cPuesto                  CHAR(3);
        DEFINE cNomEjecutivo            CHAR(45);
        DEFINE dtFecha                  DATE;
        DEFINE dtFechaIngresoAC     	DATE;
        DEFINE dtFechaIngreso     		DATE;
        DEFINE dtHoraIngresoAC      	DATETIME HOUR TO FRACTION;
        DEFINE dtHoraIngreso      		DATETIME HOUR TO FRACTION;
        DEFINE dtFechaAtencion     		DATE;
        DEFINE dtHoraAtencion      		DATETIME HOUR TO FRACTION;
		
		DEFINE cTpoMovto				CHAR(10);
		DEFINE cUser				CHAR(10);
        
        ---INICIALIZACIONES
        LET iSqlErr                     = 0;
        LET iIsamErr                    = 0;
        LET iCon                        = 0;
        LET cErrorInfo                  = '';
        LET cCodRet                     = '000000';
        LET cMensajeRet                 = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
		 LET dtFechaOrigen               = DATE(1);
        LET vcNumSol                    = '';   
        LET cOrigen                     = '';
        LET vcNumCte                    = '';
        LET vcApellPaterno              = '';
        LET vcApellMaterno              = '';
        LET vcNombre                    = '';
        LET dLinCredAct                 = 0;
        LET dLinCredCal                 = 0;
        LET dIncremento                 = 0;
        LET dMontoIncremento            = 0;
        LET cStatus                     = '';
        LET vcAnalistaCac               = '';
        LET vcAnalista2nivel            = '';
        LET vcAnalista3nivel            = '';
        LET vcAnalista4nivel            = '';
        LET vcMotivo                    = '';
        LET cCausa                      = '';
        LET cPuesto                     = '';
        LET cNomEjecutivo               = '';
        LET dtFechaIngresoAC     		= DATE(1);
        LET dtHoraIngresoAC      		= CURRENT;
        LET dtFechaAtencion     		= DATE(1);
        LET dtHoraAtencion      		= CURRENT;
        LET cTpoMovto            		= '';
        LET iTotReg            			= 0;
		LET cUser						= '';
		
        BEGIN

                ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
                        IF iSqlErr != 0 THEN
                                LET cCodRet= iSqlErr;
                                LET cMensajeRet = cErrorInfo;
                                IF iSqlErr IN (-1204,-1205,-1206) THEN
                                        LET cCodRet = '000002';
                                        LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
                                END IF; 
                                RETURN cCodRet, cMensajeRet, iTotReg;   
                        END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO 'sp_consulta_gral_aumlincred_aut.out';
                --TRACE ON;
				
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                -- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
                IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' OR  NVL(pOrigen,'') = ''  THEN
                        LET cCodRet = '000001';
                        LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
                        RETURN cCodRet, cMensajeRet, iTotReg;
				ELSE 
				
				DELETE FROM bdicnweb:"informix".sw_consultaincrementosgralaut WHERE usuario = pUsuario;	
				
					 FOREACH WITH HOLD
                                        SELECT fecha_insert, num_solicitud,origen ,numcte,                                              
                                                lincred_actual,lincred_sugerida,status,causa_status,user_insert                                             
                                        INTO dtFechaOrigen,vcNumSol,cOrigen,vcNumCte, 
                                        dLinCredAct, dLinCredCal,cStatus, cCausa ,  cUser                                      
                                        FROM  bdicred:"informix".sd_bitacora_aumlincred
                                        WHERE empresa ='001'
                                        AND fecha_insert  >= pFechaInicial
                                        AND fecha_insert <= pFechaFinal
                                        AND status = pStatus
										AND origen = (CASE WHEN pOrigen = '0' THEN origen ELSE pOrigen END)
                                        ORDER BY fecha_insert
                                
                                        
                                        LET dMontoIncremento = dLinCredCal - dLinCredAct;
                                        IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
                                                LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
                                        ELSE
                                                LET dIncremento = 0;
                                        END IF;
                                        
                                        SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))                                     
                                        INTO vcNombre, vcApellPaterno,vcApellMaterno
                                        FROM bdinteg:"informix".si_cliente
                                        WHERE numcte = vcNumCte;
                                        
                                        LET vcAnalistaCac                       = '';
                                        LET vcAnalista2nivel                    = '';
                                        LET vcAnalista3nivel                    = '';
                                        LET vcAnalista4nivel                    = '';
                                        
                                        IF NVL(cOrigen,'') = 'S' THEN
                                                FOREACH WITH HOLD
                                                        SELECT b.nombre,a.puesto,a.fecha_atencion, EXTEND(a.hora_atencion, HOUR TO SECOND)  
                                                        INTO cNomEjecutivo,cPuesto,dtFechaIngreso, dtHoraIngreso
                                                        FROM bdicred:"informix".sd_historica_cac_aumlincred a
                                                        INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo = a.ejecutivo)
                                                        WHERE a.solicitud = vcNumSol
                                                        AND a.fecha_insert = dtFechaOrigen
                                                        ORDER BY a.puesto                                                       

                                                        IF cPuesto = '01'       THEN  
                                                                LET vcAnalistaCac = cNomEjecutivo;
                                                                LET dtFechaIngresoAC =dtFechaIngreso;
                                                                LET dtHoraIngresoAC = dtHoraIngreso;
                                                        ELIF cPuesto in ('02','03') THEN 
                                                                LET vcAnalista2nivel = cNomEjecutivo;
                                                                LET dtFechaAtencion =dtFechaIngreso;
                                                                LET dtHoraAtencion = dtHoraIngreso;
                                                        ELIF cPuesto in ('04') THEN 
                                                                LET vcAnalista3nivel = cNomEjecutivo;
                                                                LET dtFechaAtencion =dtFechaIngreso;
                                                                LET dtHoraAtencion = dtHoraIngreso;
                                                        ELIF cPuesto in ('05','06','07','08') THEN
                                                                LET vcAnalista4nivel = cNomEjecutivo;
                                                                LET dtFechaAtencion =dtFechaIngreso;
                                                                LET dtHoraAtencion = dtHoraIngreso;
                                                        END IF

                                                END FOREACH
                                                IF cPuesto = '01'	THEN
                                                        LET dtFechaAtencion = dtFechaIngresoAC;
                                                        LET dtHoraAtencion = dtHoraIngresoAC;
                                                END IF;
												
												LET cTpoMovto = 'Manual'; 
											ELSE
												IF EXISTS (SELECT ejecutivo FROM "informix".sd_perfiles_cac_aumlincred WHERE empresa = '001' AND ejecutivo = trim(cUser)) THEN    
													LET cTpoMovto = 'Manual';   
												ELSE
													LET cTpoMovto = 'Automatico';     
												END IF;
                                        END IF;
                                        
                                        
                                        IF NVL(cCausa,'') <> '' THEN
                                        
                                        --se obtiene la descripcion del motivo de rechazo o cancelacion
                                                SELECT causa_status||' - '||TRIM(descripcion)
                                                INTO vcMotivo
                                                FROM bdicred:"informix".sd_causas_aumlincred
                                                WHERE status = cStatus
                                                AND causa_status = cCausa;
                                        END IF; 
                                
										INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralaut(fechaorigen, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechaingresoac, horaingresoac, fechaatencion, horaatencion, tipoincremento, usuario) 
										VALUES(dtFechaOrigen, NVL(vcNumSol,''), NVL(cOrigen,''), NVL(vcNumCte,''), NVL(vcApellPaterno,''), NVL(vcApellMaterno,''), NVL(vcNombre,''), NVL(dLinCredAct,0), NVL(dLinCredCal,0), 
										NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,''), pUsuario);                                        
                                        
                                END FOREACH;  
                                
                                IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
                                        LET cCodRet= '000003';
                                        LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
                                        RETURN cCodRet, cMensajeRet, iTotReg;
                                END IF;                 
					
                END IF;                


		SELECT COUNT(*)                                     
		INTO iTotReg                                    
		FROM  bdicnweb:"informix".sw_consultaincrementosgralaut
		WHERE usuario = pUsuario;							

		RETURN cCodRet, cMensajeRet, iTotReg;       
                                                   
        END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 09/03/2011',
'MODIFICO : Mohamed Carreon',
'DESCIPCION CAMBIO : Se agrega la fecha final y la fecha inicial',
'FECHA : 12/06/2011',
'MODIFICACION: Se modifica para contemplar las reglas de informix, se elimina la variable "cNum_credito" ya que no es utilizada en el codigo.',
'FECHA MODIFICACION: 25/07/2012',
'MODIFICA: Guadalupe Payan',
'BD: BDICRED',
'VERSION: 20120725.1150',
'----------------------------------------------------------------------------------',
'Autor: Josue Remberto Zazueta Acosta',
'Modificacion: Se borra codigo comentado,se agregan informix y bd a las tablas que no tenian,Se implementan reglas de informix',
'Fecha de modificacion: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificacion: Se agregan los campos Fecha Ingreso AC, Hora Ingreso AC, Fecha Atencion, Hora Atencion en el retorno del sp',
'Fecha de modificacion: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'ModificaciÃ³n: Se modifica para agregar el tipo de incremento manual o automatico',
'Fecha de modificaciÃ³n: 20/09/2016',
'ModificÃ³: Johnattan Esquivel SÃ¡nchez',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aut2(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pOrigen CHAR(1), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
	RETURNING 		
		CHAR(6)       					AS codigo_retorno,
        CHAR(80)      					AS mensaje_retorno,     
        DATE          					AS fecha_origen,
        VARCHAR(20)   					AS Numero_solicitud,
        CHAR(1)       					AS  Origen,
        VARCHAR(20)   					AS Numero_Cliente,
        VARCHAR(26)   					AS Apell_Paterno,
        VARCHAR(26)   					AS Apell_Materno,
        VARCHAR(53)   					AS Nombre,
        DECIMAL(18,2) 					AS Lincred_actual,
        DECIMAL(18,2) 					AS Lincred_sugerida,
        DECIMAL(18,2) 					AS Incremento,
        CHAR(2)       					AS Status,
        VARCHAR(45)   					AS AnalistaCac,
        VARCHAR(45)   					AS Analista2nivel,
        VARCHAR(45)   					AS Analista3nivel,
        VARCHAR(45)   					AS Analista4nivel,
        VARCHAR(106)  					AS motivo,
        DATE          					AS fecha_ingresoAC,
        DATETIME HOUR TO FRACTION(3) 	AS hora_ingresoAC,
        DATE          					AS fecha_atencion,
        DATETIME HOUR TO FRACTION(3) 	AS hora_atencion,
		CHAR(10)  						AS tipoIncremento;
                          
                          
        ---DECLARACIONES         
        DEFINE cCodRet                  CHAR(6); 
        DEFINE cMensajeRet              CHAR(80);
        DEFINE cComentario              CHAR(80);
        DEFINE iSqlErr                  INTEGER;
        DEFINE iIsamErr                 INTEGER;
        DEFINE iCon                     INTEGER;
        DEFINE cErrorInfo               CHAR(80);

        DEFINE dtFechaOrigen            DATE;
        DEFINE vcNumSol                 VARCHAR(20);    
        DEFINE cOrigen                  CHAR(1);
        DEFINE vcNumCte                 VARCHAR(20);
        DEFINE vcApellPaterno           VARCHAR(26);
        DEFINE vcApellMaterno           VARCHAR(26);
        DEFINE vcNombre                 VARCHAR(53);
        DEFINE dLinCredAct              DECIMAL(18,2);
        DEFINE dLinCredCal              DECIMAL(18,2);
        DEFINE dIncremento              DECIMAL(18,2);
        DEFINE dMontoIncremento         DECIMAL(18,2);
        DEFINE cStatus                  CHAR(2);
        DEFINE vcAnalistaCac            VARCHAR(45);
        DEFINE vcAnalista2nivel         VARCHAR(45);
        DEFINE vcAnalista3nivel         VARCHAR(45);
        DEFINE vcAnalista4nivel         VARCHAR(45);

        DEFINE vcMotivo                 VARCHAR(106);
        DEFINE cCausa                   CHAR(3);
        DEFINE cPuesto                  CHAR(3);
        DEFINE cNomEjecutivo            CHAR(45);
        DEFINE dtFecha                  DATE;
        DEFINE dtFechaIngresoAC     	DATE;
        DEFINE dtFechaIngreso     		DATE;
        DEFINE dtHoraIngresoAC      	DATETIME HOUR TO FRACTION;
        DEFINE dtHoraIngreso      		DATETIME HOUR TO FRACTION;
        DEFINE dtFechaAtencion     		DATE;
        DEFINE dtHoraAtencion      		DATETIME HOUR TO FRACTION;
		
		DEFINE cTpoMovto				CHAR(10);
		
		DEFINE sQuery					CHAR(300);
		DEFINE cUser					CHAR(10);
		
        ---INICIALIZACIONES
        LET iSqlErr                     = 0;
        LET iIsamErr                    = 0;
        LET iCon                        = 0;
        LET cErrorInfo                  = '';
        LET cCodRet                     = '000000';
        LET cMensajeRet                 = 'SE REALIZO LA CONSULTA CORRECTAMENTE';

        LET dtFechaOrigen               = DATE(1);
        LET vcNumSol                    = '';   
        LET cOrigen                     = '';
        LET vcNumCte                    = '';
        LET vcApellPaterno              = '';
        LET vcApellMaterno              = '';
        LET vcNombre                    = '';
        LET dLinCredAct                 = 0;
        LET dLinCredCal                 = 0;
        LET dIncremento                 = 0;
        LET dMontoIncremento            = 0;
        LET cStatus                     = '';
        LET vcAnalistaCac               = '';
        LET vcAnalista2nivel            = '';
        LET vcAnalista3nivel            = '';
        LET vcAnalista4nivel            = '';
        LET vcMotivo                    = '';
        LET cCausa                      = '';
        LET cPuesto                     = '';
        LET cNomEjecutivo               = '';
        LET dtFechaIngresoAC     		= DATE(1);
        LET dtHoraIngresoAC      		= CURRENT;
        LET dtFechaAtencion     		= DATE(1);
        LET dtHoraAtencion      		= CURRENT;
        LET cTpoMovto            		= '';
		LET sQuery						= '';
		LET cUser						= '';

        BEGIN

                ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
                        IF iSqlErr != 0 THEN
                                LET cCodRet= iSqlErr;
                                LET cMensajeRet = cErrorInfo;
                                IF iSqlErr IN (-1204,-1205,-1206) THEN
                                        LET cCodRet = '000002';
                                        LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
                                END IF; 
                                RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                       NVL(vcNombre,''),0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,'');       
                        END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO 'sp_consulta_gral_aumlincred_aut.out';
                --TRACE ON;
				
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                -- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
                IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
                        LET cCodRet = '000001';
                        LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
                        RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,''); 

                ELSE
                                FOREACH WITH HOLD
                                        SELECT skip pInicio limit pFin fechaorigen, numerosolicitud, origen, numerocliente, apellpaterno, 
										apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, 
										analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechaingresoac, horaingresoac, 
										fechaatencion, horaatencion, tipoincremento 
										INTO dtFechaOrigen,vcNumSol,cOrigen,vcNumCte, vcApellPaterno, vcApellMaterno, vcNombre, 
                                        dLinCredAct, dLinCredCal,dIncremento,cStatus, 
										vcAnalistaCac, vcAnalista2nivel,vcAnalista3nivel,vcAnalista4nivel, vcMotivo,
										dtFechaIngresoAC, dtHoraIngresoAC, dtFechaAtencion,dtHoraAtencion, cTpoMovto
										FROM bdicnweb:"informix".sw_consultaincrementosgralaut
                                        WHERE usuario = pUsuario
                                
                                        RETURN cCodRet, cMensajeRet,dtFechaOrigen,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                        NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,'') WITH RESUME;      
                                        
                                END FOREACH;  
                                
                                IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
                                        LET cCodRet= '000003';
                                        LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
                                        RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                               NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,'');
                                END IF;                 
                        --END IF
                END IF
        END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 09/03/2011',
'MODIFICO : Mohamed Carreon',
'DESCRIPCION CAMBIO : Se agrego la fecha final y la fecha inicial',
'FECHA : 12/06/2011',
'MODIFICACION: Se modifica para contemplar las reglas de informix, se elimina la variable "cNum_credito" ya que no es utilizada en el codigo.',
'FECHA MODIFICACION: 25/07/2012',
'MODIFICO: Guadalupe Payan',
'BD: BDICRED',
'VERSION: 20120725.1150',
'----------------------------------------------------------------------------------',
'Autor: Josue Remberto Zazueta Acosta',
'Modificacion: Se borra codigo comentado,se agregan informix y bd a las tablas que no tenian,Se implementan reglas de informix',
'Fecha de modificacion: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificacion: Se agregan los campos Fecha Ingreso AC, Hora Ingreso AC, Fecha Atencion, Hora Atencion en el retorno del sp',
'Fecha de modificacion: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Modificacion: Se modifica para agregar el tipo de incremento manual o automatico',
'Fecha de modificacion: 20/09/2016',
'Modifico: Johnattan Esquivel SÃ¡nchez',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_rep_gral_status_total(pFechaIni CHAR (10), pFechaFin CHAR(10), pOrigen CHAR(1), pUsuario CHAR(10))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS total;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcStatusTotal     DECIMAL(18,2);
	DEFINE cOrigen				CHAR(1);
	DEFINE cOrigen2				CHAR(1);


	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = '';
	LET cBandera				 = '';
	LET cStatus 				 = '';
	LET cCausa 					 = '';
	LET dPorcStatusTotal         = 0;
	LET cOrigen					 = "";
	LET cOrigen2				 = "";

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet=cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	 
				
				RETURN cCodRet, cMensajeRet, iTotalReg;
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_gral_status_total.out';
		--TRACE ON;

		-- Se validan los parametros de entrada.
		IF NVL(pFechaIni,'') = ''  OR NVL(pFechaFin,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA PARÁMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA';
			RETURN cCodRet, cMensajeRet, iTotalReg;
		END IF;

		IF NVL(pOrigen,'') = '' THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'FALTA PARÁMETRO REQUERIDO DE ORIGEN PARA REALIZAR  LA CONSULTA';
			RETURN cCodRet, cMensajeRet, iTotalReg;
		END IF;
		
		-- Se elimina la tabla de trabajo
		DELETE FROM bdicnweb:"informix".sw_consultaincrementosgralstatus WHERE usuario = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOrigen ='0' THEN --TODOS
			LET cOrigen ='C';
			LET cOrigen2 ='S';
		ELSE
			LET cOrigen = pOrigen;
		END IF;
		-- Se insertan el total de registros por estatus
		FOREACH WITH HOLD
			SELECT status,TRIM(descripcion)
				INTO cStatus,vcDescripcion
			FROM  "informix".sd_status_aumlincred 
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen IN (cOrigen,cOrigen2)
					AND status = cStatus					
					AND causa_status = ''
				
				IF iTotalStatus > 0 THEN
					INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralstatus(status,causa,descripcion,totalRegistros,porcentaje,totalGeneral,usuario)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0,0,pUsuario);	 
				END IF;
			END FOREACH;
			
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen IN (cOrigen,cOrigen2)
					AND status = cStatus					
					AND causa_status IN(SELECT causa_status		  
										 FROM "informix".sd_causas_aumlincred
										 WHERE mostrar_pantalla = '1')
				
				IF iTotalStatus > 0 THEN
					INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralstatus(status,causa,descripcion,totalRegistros,porcentaje,totalGeneral,usuario)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0,0,pUsuario);	 
				END IF;
				
			END FOREACH;  	
			
		END FOREACH;
		-- Se obtiene el total de los registros para esta consulta	
		SELECT NVL(SUM(totalregistros),0), COUNT(status)
		INTO iTotal,iTotalReg
		FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus 
		WHERE status = status
			AND causa = ''
			AND totalRegistros <> 0
			AND usuario = pUsuario;
		
		LET iTotalRegistros = iTotal;
					
		IF iTotalReg <> 0 THEN
			-- Se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
			FOREACH
				SELECT status,descripcion,totalRegistros
				INTO cStatus, vcDescripcion,iTotalStatus
				FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus
				WHERE status = status
					AND causa = ''
					AND totalRegistros <> 0
					AND usuario = pUsuario				
				
				LET dPorcStatus = ((iTotalStatus * 100)/iTotalRegistros);
				IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
					LET iCont = iCont + 1;
					IF iTotalReg = iCont THEN
						LET dPorcStatus = 100 - dPorcStatusAcum;
					END IF;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				ELSE
					LET iCont = iCont + 1;
					LET dPorcStatus = 100 - dPorcStatusAcum;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				END IF;
						
				UPDATE bdicnweb:"informix".sw_consultaincrementosgralstatus
				SET porcentaje = dPorcStatus
				WHERE status = cStatus
					AND usuario = pUsuario;
			END FOREACH;
		END IF;
		-- Se insertan el total de registros por causas
		FOREACH WITH HOLD
			SELECT status,causa_status,TRIM(descripcion)
			  INTO cStatus,cCausa,vcDescripcion
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = '1'
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin		
					AND origen IN (cOrigen,cOrigen2)
					AND status = cStatus
					AND causa_status = cCausa
			
				INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralstatus (status,causa,descripcion,totalRegistros,porcentaje,totalGeneral,usuario)	
				VALUES(cStatus,cCausa,vcDescripcion,NVL(iTotalStatus,0),0,0,pUsuario);
			 
			END FOREACH;  		
		END FOREACH;	
		-- Se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
		LET dPorcStatusAcum = 0;
		LET dPorcStatus = 0;
		LET iCont = 0;

		FOREACH WITH HOLD
			SELECT status,causa_status
			  INTO cStatus,cCausa
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = '1'
			ORDER BY status,causa_status
					
			SELECT NVL(SUM(totalregistros),0), COUNT(causa)
			INTO iTotal,iTotalReg
			FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus 
			WHERE status = cStatus
				AND causa <> ''
				AND totalRegistros <> 0
				AND usuario = pUsuario;
								
			SELECT porcentaje
			INTO  dPorcStatusTotal
			FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus 
			WHERE status = cStatus
				AND causa = ''
				AND totalRegistros <> 0
				AND usuario = pUsuario;
					
			IF iTotalReg <> 0 THEN
				SELECT status,causa,descripcion,totalRegistros
				INTO cStatus,cCausa,vcDescripcion,iTotalStatus
				FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus
				WHERE status = cStatus
					AND causa = cCausa
					AND totalRegistros <> 0
					AND usuario = pUsuario;
					
				IF NVL(iTotalStatus,0) <> 0 THEN
					LET dPorcStatus = ((iTotalStatus * 100) / iTotalRegistros);

					IF (dPorcStatusAcum + dPorcStatus) < dPorcStatusTotal THEN
						LET iCont = iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;							
						END IF;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
					ELSE
						LET iCont = iCont + 1;
						LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
					END IF;
						
					UPDATE bdicnweb:"informix".sw_consultaincrementosgralstatus
						SET porcentaje = dPorcStatus
					WHERE status = cStatus
						AND causa = cCausa
						AND usuario = pUsuario;	
				END IF;
			END IF;
			IF iTotalReg = iCont THEN
				LET dPorcStatusAcum = 0;
				LET dPorcStatus = 0;
				LET iCont = 0;
			END IF;				
		END FOREACH;
		
		UPDATE bdicnweb:"informix".sw_consultaincrementosgralstatus
		SET totalGeneral = iTotalRegistros
		WHERE usuario = pUsuario;
						
		-- Se obtiene los datos de la tabla
		SELECT COUNT(*)
		INTO iTotalReg
		FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus
		WHERE usuario = pUsuario;
		
		RETURN cCodRet, cMensajeRet, iTotalReg;			 
		
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada status de acuerdo al mes consultado',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2011',
'MODIFICACION: Se modifica para que reciba como parametro de entrada  el rango de fechas del cual se desea la informacion.',
'FECHA: 04/11/2011',
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'MODIFICACION: Se modifica para corregir y cambiar el retorno de la variable "iTotal" por "iTotalRegistros" ya que perdia el valor cuando el ultimo',
'			   registro tomaba el valor de 0 y por consecuencia no mostraba registros. Se contemplan las reglas de informix, se elimina variable "cComentario" y',
'              dPorcStatusAcum2 ya que estas no son usadas en el procedimiento',
'FECHA: 24/07/2012',
'AUTOR : Guadalupe Payan',
'BD    : BDICRED',
'Version: 20120724.1714',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_rep_gral_status2(pFechaIni CHAR (10), pFechaFin CHAR(10), pOrigen CHAR(1), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS tiene_causa,
			  CHAR(100) 	AS descripcion,
			  INTEGER 		AS total_status,
			  DECIMAL(18,2) AS porcentaje,
			  INTEGER 		AS total_general;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcStatusTotal     DECIMAL(18,2);

	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = '';
	LET cStatus 				 = '';
	LET cCausa 					 = '';
	LET dPorcStatusTotal         = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet=cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	 
			
				RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0), NVL(vcDescripcion,' '), NVL(iTotalStatus, 0), NVL(dPorcStatus, 0), NVL(iTotal, 0);
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_gral_status2.out';
		--TRACE ON;

		-- Se validan los parametros de entrada.
		IF NVL(pFechaIni,'') = ''  OR NVL(pFechaFin,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA PARAMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA';
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0);
		END IF;

		IF NVL(pOrigen,'') = '' THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'FALTA PARAMETRO REQUERIDO DE ORIGEN PARA REALIZAR  LA CONSULTA';
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0);
		END IF;
		
		-- Se obtiene los datos de la tabla
		FOREACH
			SELECT skip pInicio limit pFin status,causa,descripcion,totalRegistros,porcentaje,totalGeneral
			INTO cStatus,cCausa,vcDescripcion,iTotalStatus,dPorcStatus,iTotal
			FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus
			ORDER BY status,causa
			
			IF NVL(cCausa,'') <> '' THEN
				LET iTieneCausa = 1;
				LET  vcDescripcion = TRIM (cCausa) || '-' || TRIM (vcDescripcion);
			ELSE
				LET iTieneCausa = 0;				
			END IF;
			
			RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0), NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0) WITH RESUME;			 
		
		END FOREACH;	
		
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada status de acuerdo al mes consultado',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2011',
'MODIFICACION: Se modifica para que reciba como parametro de entrada  el rango de fechas del cual se desea la informacion.',
'FECHA: 04/11/2011',
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'MODIFICACION: Se modifica para corregir y cambiar el retorno de la variable "iTotal" por "iTotalRegistros" ya que perdia el valor cuando el ultimo',
'			   registro tomaba el valor de 0 y por consecuencia no mostraba registros. Se contemplan las reglas de informix, se elimina variable "cComentario" y',
'              dPorcStatusAcum2 ya que estas no son usadas en el procedimiento',
'FECHA: 24/07/2012',
'AUTOR : Guadalupe Payan',
'BD    : BDICRED',
'Version: 20120724.1714',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aplicados_tot(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pOrigen CHAR(1), pOpcFecha CHAR(1), pUsuario CHAR(10))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,     
			  INTEGER  		AS TotalRegs;
			  
			  
	---DECLARACIONES         
	DEFINE cCodRet               	CHAR(6); 
	DEFINE cMensajeRet           	CHAR(80);
	DEFINE cComentario           	CHAR(80);
	DEFINE iSqlErr      	     	INTEGER;
	DEFINE iIsamErr              	INTEGER;
	DEFINE iCon            		 	INTEGER;
	DEFINE cErrorInfo            	CHAR(80);

	DEFINE  dtFechaAtencion 		DATE;
	DEFINE vcNumSol 				VARCHAR(20);	
	DEFINE cOrigen  				CHAR(8);
	DEFINE vcNumCte 				VARCHAR(20);
	DEFINE vcApellPaterno			VARCHAR(26);
	DEFINE vcApellMaterno 			VARCHAR(26);
	DEFINE vcNombre 				VARCHAR(53);
	DEFINE dLinCredAct 		    	DECIMAL(18,2);
	DEFINE dLinCredCal 	     		DECIMAL(18,2);
	DEFINE dIncremento				DECIMAL(18,2);
	DEFINE dMontoIncremento			DECIMAL(18,2);
	DEFINE cStatus 					CHAR(2);
	DEFINE vcAnalistaCac			VARCHAR(45);
	DEFINE vcAnalista2nivel 		VARCHAR(45);
	DEFINE vcAnalista3nivel 		VARCHAR(45);
	DEFINE vcAnalista4nivel 		VARCHAR(45);

	DEFINE vcMotivo 				VARCHAR(106);
	DEFINE cCausa 					CHAR(3);
	DEFINE cPuesto 					CHAR(3);
	DEFINE cNomEjecutivo 			CHAR(45);
	DEFINE dtFecha 					DATE;
	DEFINE dtFecha_status 			DATE;
	DEFINE iContador				INTEGER;
	DEFINE cNomEjecutivoMaxPuesto	CHAR(45);
	DEFINE cEjecutivo				CHAR(10);
	DEFINE iTotReg              	INTEGER;

	---INICIALIZACIONES
	LET iSqlErr                  	= 0;
	LET iIsamErr                 	= 0;
	LET iCon                 	 	= 0;
	LET cErrorInfo               	= '';
	LET cCodRet                  	= '000000';
	LET cMensajeRet              	= 'SE REALIZO LA CONSULTA CORRECTAMENTE';

	LET  dtFechaAtencion 		 	= DATE(1);
	LET vcNumSol 			 		= '';	
	LET cOrigen  		     		= '';
	LET vcNumCte 			 		= '';
	LET vcApellPaterno		 		= '';
	LET vcApellMaterno 		 		= '';
	LET vcNombre 			 		= '';
	LET dLinCredAct 		 		= 0;
	LET dLinCredCal 	     		= 0;
	LET dIncremento			 		= 0;
	LET dMontoIncremento	 		= 0;
	LET cStatus 			 		= '';
	LET vcAnalistaCac		 		= '';
	LET vcAnalista2nivel 	 		= '';
	LET vcAnalista3nivel 	 		= '';
	LET vcAnalista4nivel      		= '';
	LET vcMotivo 			 		= '';
	LET cCausa 			 		    = '';
	LET cPuesto 			 		= '';
	LET cNomEjecutivo	 		    = '';
	LET dtFecha_status 				= DATE(1);
	LET iContador					= 0;
	LET cNomEjecutivoMaxPuesto		= '';
	LET cEjecutivo					= '';
    LET iTotReg                     = 0;

	BEGIN
		
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	
				RETURN cCodRet, cMensajeRet, iTotReg;	
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_gral_aumlincred_aplicados_tot.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		IF pStatus IS NULL THEN 
		 LET pStatus = '';
		END IF;
		
		-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
		IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
			RETURN cCodRet, cMensajeRet, iTotReg;
		ELSE
		
		DELETE FROM bdicnweb:"informix".sw_consultaincrementosgralaplicados WHERE usuario = pUsuario;
		
			IF pOpcFecha = '1' THEN --Busqueda por fechaOrigen: fecha_insert	
					
					FOREACH WITH HOLD							
						SELECT a.fecha_insert, a.num_solicitud,a.origen ,a.numcte, a.lincred_actual,a.lincred_sugerida,
							a.status,a.causa_status, a.fecha_status,a.ejecutivo
							INTO  dtFechaAtencion, vcNumSol, cOrigen, vcNumCte, 
							dLinCredAct, dLinCredCal,cStatus, cCausa, dtFecha_status, cEjecutivo
							FROM  bdicred:"informix".sd_bitacora_aumlincred a
							WHERE a.status = 'AP'	
							AND a.fecha_insert  >= pFechaInicial
							AND a.origen = (CASE WHEN pOrigen = '0' THEN a.origen ELSE pOrigen END)
							AND a.fecha_insert  <= pFechaFinal
							ORDER BY fecha_insert
					
						
						LET dMontoIncremento = dLinCredCal - dLinCredAct;
						IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
							LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
						ELSE
							LET dIncremento = 0;
						END IF;
						
						SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))					
						INTO vcNombre, vcApellPaterno,vcApellMaterno
						FROM bdinteg:'informix'.si_cliente
						WHERE numcte = vcNumCte;
						
					
					IF NVL(cCausa,'') <> '' THEN
					
					--se obtiene la descripcion del motivo de rechazo o cancelacion
						SELECT causa_status||' - '||TRIM(descripcion)
						INTO vcMotivo
						FROM "informix".sd_causas_aumlincred
						WHERE status = cStatus
						AND causa_status = cCausa;
					END IF;
						
					IF NVL(cOrigen,'') = 'S' THEN	
						
						--Obtener el nombre del ejecutivo del maximo puesto						
						SELECT LIMIT 1 c.nombre 
						INTO cNomEjecutivoMaxPuesto
						FROM "informix".sd_historica_cac_aumlincred h
						INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
						WHERE h.solicitud = vcNumSol
						AND h.fecha_insert = dtFechaAtencion
						AND h.puesto = (
									SELECT max(puesto)
									FROM "informix".sd_historica_cac_aumlincred
									WHERE solicitud = vcNumSol
									AND fecha_insert =  dtFechaAtencion
								);
						
						IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
							SELECT LIMIT 1 c.nombre 
							INTO cNomEjecutivoMaxPuesto
							FROM "informix".sd_perfiles_cac_aumlincred h
							INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
							WHERE h.ejecutivo = cEjecutivo;
							
							IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
								LET cNomEjecutivoMaxPuesto = 'SUCURSAL';
							END IF;
							
						END IF;							
						--LET cOrigen = DECODE(cOrigen,'CENTRAL','C','SUCURSAL','S');
					ELSE
						LET cNomEjecutivoMaxPuesto = 'CENTRAL';
					END IF;
					LET cOrigen = DECODE(cOrigen,'C','CENTRAL','S','SUCURSAL');				
						LET iContador = iContador + 1;
						
						INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralaplicados(fecha_atencion, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechastatus, totalnumreg, nomejecutivomaxpuesto, usuario) 
						VALUES(dtFechaAtencion,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''), NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,''), pUsuario);
		
						
					END FOREACH; 
						
				ELSE
						--Busqueda por fechaAtencion: fecha_status
						FOREACH WITH HOLD							
							SELECT a.fecha_insert, a.num_solicitud,a.origen ,a.numcte,						
								a.lincred_actual,a.lincred_sugerida,a.status,a.causa_status,
								a.fecha_status,a.ejecutivo
							INTO  dtFechaAtencion,vcNumSol,cOrigen,vcNumCte, 
							dLinCredAct, dLinCredCal,cStatus, cCausa, dtFecha_status,cEjecutivo
							FROM "informix".sd_bitacora_aumlincred a
							WHERE a.status = "AP"	
							AND a.fecha_status >= pFechaInicial
							AND a.origen = (CASE WHEN pOrigen = '0' THEN a.origen ELSE pOrigen END)
							AND a.fecha_status <= pFechaFinal							
							ORDER BY fecha_status
						
							
							LET dMontoIncremento = dLinCredCal - dLinCredAct;
							IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
								LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
							ELSE
								LET dIncremento = 0;
							END IF;
							
							SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))					
							INTO vcNombre, vcApellPaterno,vcApellMaterno
							FROM bdinteg:"informix".si_cliente
							WHERE numcte = vcNumCte;
							
							
						IF NVL(cCausa,'') <> '' THEN
						
						--se obtiene la descripcion del motivo de rechazo o cancelacion
							SELECT causa_status||' - '||TRIM(descripcion)
							INTO vcMotivo
							FROM 'informix'.sd_causas_aumlincred
							WHERE status = cStatus
							AND causa_status = cCausa;
						END IF;
							
					IF NVL(cOrigen,'') = 'S' THEN	
						
						--Obtener el nombre del ejecutivo del maximo puesto						
						SELECT LIMIT 1 c.nombre 
						INTO cNomEjecutivoMaxPuesto
						FROM "informix".sd_historica_cac_aumlincred h
						INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
						WHERE h.solicitud = vcNumSol
						AND h.fecha_insert = dtFechaAtencion
						AND h.puesto = (
									SELECT max(puesto)
									FROM "informix".sd_historica_cac_aumlincred
									WHERE solicitud = vcNumSol
									AND fecha_insert =  dtFechaAtencion
								);
						
						IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
							SELECT LIMIT 1 c.nombre 
							INTO cNomEjecutivoMaxPuesto
							FROM "informix".sd_perfiles_cac_aumlincred h
							INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
							WHERE h.ejecutivo = cEjecutivo;
							
							IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
								LET cNomEjecutivoMaxPuesto = 'SUCURSAL';
							END IF;
							
						END IF;							
						--LET cOrigen = DECODE(cOrigen,'CENTRAL','C','SUCURSAL','S');
					ELSE
						LET cNomEjecutivoMaxPuesto = 'CENTRAL';
					END IF;
						LET cOrigen = DECODE(cOrigen,'C','CENTRAL','S','SUCURSAL');		
						
							LET iContador = iContador + 1;
							INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralaplicados(fecha_atencion, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechastatus, totalnumreg, nomejecutivomaxpuesto, usuario) 
							VALUES(dtFechaAtencion,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''), NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,''), pUsuario);
						END FOREACH; 
		END IF; 
		
		SELECT COUNT(*) 
		INTO iTotReg 
		FROM bdicnweb:"informix".sw_consultaincrementosgralaplicados 
		WHERE usuario = pUsuario;
		
		RETURN cCodRet, cMensajeRet, iTotReg;
						
				IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
					LET cCodRet= '000003';
					LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
					RETURN cCodRet, cMensajeRet,iTotReg;
				END IF;	   		
			--END IF
		END IF
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha (Fecha Origen o Fecha AtenciÃ³n)',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 06/02/2014',
'MODIFICO : Daniel Lazalde',
'BD: BDICRED',
'VERSION: 20140206.0001',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_depura_si_refclientes()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE vNumCte      VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE fFecha       DATE;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET vNumCte      = '';
LET fFecha       = date(1);

-- SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO 'sp_depura_sd_movhis2.out';
--    TRACE ON;

    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     where proceso = 11;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(11,'');
    END IF;

	select empresa, num_solicitud, numcte
	 from bdisolic:ss_solicitudes 
	where status_solicitud in ('CN','RT') 
	  AND fecha_insert <= mdy('12','31','2018')
	  AND num_solicitud > vNumCredAux 
	  into temp paso1 with no log;
	  
	create unique index inx_paso1 on paso1(num_solicitud, numcte);
	update statistics medium for table paso1;


    FOREACH WITH HOLD
       SELECT a.num_solicitud, a.numcte
	       INTO vNumCred, vNumCte
           FROM paso1 a,
                bdinteg:si_refclientes b
          WHERE a.empresa = b.empresa
            and a.numcte = b.numcte
            and a.num_solicitud = b.num_solicitud
		  group by 1,2
		  order by 1

        BEGIN WORK;

            insert into bdinteg:si_refclientes_0819
            select * from bdinteg:si_refclientes
            where empresa = '001'
            and num_solicitud = vNumCred
            and numcte = vNumCte;

            delete from bdinteg:si_refclientes
            where empresa = '001'
            and num_solicitud = vNumCred
            and numcte = vNumCte;

            UPDATE "informix".sd_param_movhis_dep
               SET num_credito = vNumCred
             where proceso = 11;

        COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;