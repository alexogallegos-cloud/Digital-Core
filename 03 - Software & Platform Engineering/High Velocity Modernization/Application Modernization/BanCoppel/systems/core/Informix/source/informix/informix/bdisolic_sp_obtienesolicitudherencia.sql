CREATE PROCEDURE "informix".sp_obtienesolicitudherencia(pEmpresa CHAR(3),
														pNumSolicitudActual CHAR(20) ,
														pNumcte CHAR(20))

--RETORNOS-
RETURNING
CHAR(6)  AS codigo_ret,
CHAR(20) AS Num_sol_Herencia;

--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(6);
DEFINE iSql_err				    INTEGER; 
DEFINE iIsamErr                 INTEGER;

DEFINE dFechaActual             DATE;
DEFINE dFechaMinima             DATE;

DEFINE iBandera                 INTEGER;
DEFINE iDiasSolicitud                 INTEGER;
DEFINE cNumSolicitud            CHAR(20);
DEFINE cNumProd                 CHAR(4);
DEFINE cStatusSol               CHAR(2);
DEFINE cTpSol 					CHAR(1);
DEFINE cRechazo 				INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodret                  = '000000'; --EJECUCION EXITOSA
LET iIsamErr                 = 0 ;
LET iSql_err                 = 0 ;  

LET dFechaActual             = DATE(1);
LET dFechaMinima             = DATE(1);

LET iBandera                 = 0 ;
LET iDiasSolicitud			= 0 ;
LET cNumSolicitud			= '' ;
LET cRechazo 				= 0 ;
LET cTpSol 					= '' ;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret) , cNumSolicitud;
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/informix/gpe/sp_obtienesolicitudherencia.out';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	  --CONTROL DE ERRORES POR PARAMETRO--
	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSolicitudActual,'')= '' OR  NVL(pNumcte, '') = ''   THEN
		LET cCodret = '000001'; --PROPORCIONE PARAMETROS PARA EJECUTAR EL PROCEDIMIENTO
		RETURN TRIM(cCodret) , cNumSolicitud;
	 END IF;
	 
	  ------------------------------------------------------VALIDACION DE CONDICIONES-----------
	 --SE CONSULTA EL RANGO DE DIAS DONDE DEBE ESTAR LA SOLICITUD QUE SE VAN A MOSTRAR 
	SELECT valor_alfabetico 
	INTO iDiasSolicitud
	FROM bdicobranza:"informix".cb_param_campania
	WHERE empresa = TRIM(pEmpresa)
	AND tipo_campania = 58
	AND grupo_parametro = 'PRSTMPRSNL';
			
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN
		LET cCodret = '000002'; --NO HAY UN RANGO DE DIAS ESPECIFICADO PORQUE EL TIPO DE CAMPAÑA NO EXISTE.
		RETURN TRIM(cCodret) , cNumSolicitud;
	END IF;
				
	--SE CONSULTA LA FECHA ACTUAL
	SELECT fecha_hoy  
	INTO dFechaActual
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = TRIM(pEmpresa);
-------------------------------------------inicio icm 13-05-2020 SI EL CLIENTE TUVO ALGUN PROSPECTEO NO HEREDE INFORMACION 	
	SELECT FIRST 1 num_solicitud
	INTO cNumSolicitud
	FROM "informix".ss_prospecteo_solicitudes 
	WHERE empresa = TRIM(pEmpresa)
	AND numcte = TRIM(pNumcte);
			
	IF DBINFO('sqlca.sqlerrd2') <> 0 THEN
	    LET cCodret = '000004'; --NO DEBE HEREDAR REFERENCIAS TIENE UNA SOLICITUD POR PROSPECTEO INCOMPLETA PARA USARSE EN  UNA SOLICITUD NORMAL.
	    RETURN TRIM(cCodret) , '';
	END IF;
------------------------------------------- fin icm 13-05-2020 SI EL CLIENTE TUVO ALGUN PROSPECTEO NO HEREDE INFORMACION 				
	IF cCodret = '000000' THEN
		 --SE HACE EL CALCULO DE LA FECHA QUE NO DEBE SOBREPASAR LA SOLICITUD
		LET dFechaMinima = dFechaActual - iDiasSolicitud UNITS DAY;
		
		FOREACH WITH HOLD
		
			SELECT num_solicitud, num_producto, status_solicitud, tipo_solicitud
			INTO cNumSolicitud, cNumProd, cStatusSol, cTpSol
			FROM "informix".ss_solicitudes 
			WHERE empresa = TRIM(pEmpresa)
			AND numcte = TRIM(pNumcte)
			AND num_producto IN (SELECT valor_alfabetico FROM bdicobranza:"informix".cb_param_campania WHERE empresa = TRIM(pEmpresa) AND tipo_campania = 59)
			AND num_solicitud <> TRIM(pNumSolicitudActual)
			AND status_solicitud IN (SELECT valor_alfabetico FROM bdicobranza:"informix".cb_param_campania WHERE empresa = TRIM(pEmpresa) AND tipo_campania = 57)
			AND fecha_insert >= dFechaMinima
			AND fecha_insert <= dFechaActual
			ORDER BY fecha_insert DESC


					IF cStatusSol = 'RT' AND cTpSol <> 'P' THEN
						LET iBandera = 0;
						EXIT FOREACH;	
					ELIF cStatusSol = 'RT' THEN
						SELECT LIMIT 1 1
						  INTO cRechazo
						  FROM bdisolic:ss_autorizacion 
						 WHERE num_solicitud = cNumSolicitud
                           AND status_solicitud = 'RT' and causa_solicitud = 'CPS';
						   
						   IF NVL(cRechazo,0) = 0  THEN
						      LET iBandera = 0;
						      EXIT FOREACH;	
						   END IF;						   
					END IF;
			
				LET iBandera = 1;
				EXIT FOREACH;	
		
		
		END FOREACH;
			
		IF DBINFO('sqlca.sqlerrd2') = 0 OR NVL(iBandera,0) = 0 THEN
			LET cCodret = '000004'; --EL CLIENTE NO TIENE SOLICITUDES DE EL PRODUCTO INDICADO QUE CUMPLAN CON LAS CARACTERISTICAS DE ESTATUS Y FECHA
		END IF;
	END IF;

		RETURN TRIM(cCodret) , cNumSolicitud;
	
END;
END PROCEDURE
