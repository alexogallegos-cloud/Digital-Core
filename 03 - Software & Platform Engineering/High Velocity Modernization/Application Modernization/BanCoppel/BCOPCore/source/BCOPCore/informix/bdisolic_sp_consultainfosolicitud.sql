CREATE PROCEDURE "informix".sp_consultainfosolicitud(pEmpresa CHAR(3), pNumSolicitudActual CHAR(20) ,pNumcte CHAR(20), pProducto CHAR (4), pPaginacion INTEGER)

--RETORNOS-
RETURNING
CHAR(6)      AS codigo_ret,
INTEGER      AS paginacion,
MONEY(14,2)  AS ingreso_mensual,
CHAR(80)     AS datos_complement,
CHAR(80)     AS resp_cte,
SMALLINT     AS grupo_res,
SMALLINT     AS elemen_res;

--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(6);
DEFINE iSql_err				    INTEGER; 
DEFINE iIsamErr                 INTEGER;
DEFINE mIngreso                 MONEY(14,2);
DEFINE cDatosComp               CHAR(80);
DEFINE cRespCte                 CHAR(80);
DEFINE sGrupo                   SMALLINT;
DEFINE sElemento                SMALLINT;
DEFINE cNumSolicitud            CHAR(20);
DEFINe dFechaSolic              DATE;
DEFINE sSeccion                 SMALLINT;
DEFINE iDiasSolicitud           INTEGER;
DEFINE iContador                INTEGER;
DEFINE dFechaActual             DATE;
DEFINE dFechaMinima             DATE;
DEFINE iPaginacionRetorno       INTEGER;
DEFINE iBandera                 INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodret                  = '000000'; --EJECUCION EXITOSA
LET iIsamErr                 = 0 ;
LET iSql_err                 = 0 ;  
LET mIngreso                 = 0;
LET cDatosComp               = '';
LET cRespCte                 = '';
LET sGrupo                   = 0;
LET sElemento                = 0;
LET cNumSolicitud            = '';
LET dFechaSolic              = DATE(1);
LET sSeccion                 = 0;
LET iDiasSolicitud           = 0;
LET iContador                = 0; --LLEVA EL CONTROL DE CUANTOS REGISTROS VA A IMPRIMIR EN PANTALLA
LET dFechaActual             = DATE(1);
LET dFechaMinima             = DATE(1);
LET iPaginacionRetorno       = 0 ;
LET iBandera                 = 0 ;


--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret) , NVL(iPaginacionRetorno, 0), NVL(mIngreso, 0.00), NVL(cDatosComp,''), NVL(cRespCte, ''), NVL(sGrupo, 0), NVL(sElemento, 0);
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/dbexportb/carlos/mttoprestamopersonal/sp_consultainfosolicitud.out';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	  --CONTROL DE ERRORES POR PARAMETRO--
	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSolicitudActual,'')= '' OR  NVL(pNumcte, '') = '' OR NVL(pProducto, '') = '' OR NVL(pPaginacion, '') = '' THEN
		LET cCodret = '000001'; --PROPORCIONE PARAMETROS PARA EJECUTAR EL PROCEDIMIENTO
		RETURN TRIM(cCodret) , NVL(iPaginacionRetorno, 0), NVL(mIngreso, 0.00), NVL(cDatosComp,''), NVL(cRespCte, ''), NVL(sGrupo, 0), NVL(sElemento, 0);
	 END IF;
	 ------------------SE CONSULTA QUE EL PRODUCTO A CONSULTAR SEA UNO PERMITIDO
	IF NOT EXISTS (SELECT valor_alfabetico FROM bdicobranza:"informix".cb_param_campania WHERE empresa = TRIM(pEmpresa) AND tipo_campania = 59 AND valor_alfabetico = TRIM(pProducto)) THEN
		LET cCodret = '000003'; --EL PRODUCTO DEL PARAMETRO NO ES UN PRODUCTO VÁLIDO
	END IF;
	
	IF cCodret = '000000' THEN
		EXECUTE PROCEDURE "informix".sp_obtienesolicitudherencia
		 (pEmpresa ,pNumSolicitudActual,pNumcte)
		 INTO cCodret, cNumSolicitud;
	END IF;
	-----------------BLOQUE DE CONSULTA DE PREGUNTAS, RESPUESTAS E INGRESO
	IF cCodret = '000000' THEN
		LET iPaginacionRetorno = iPaginacionRetorno + (pPaginacion + 1);
				
		FOREACH
			SELECT SKIP pPaginacion d.ingreso_mensual , b.descripcion , c.descripcion , c.grupo, c.elemento
			INTO mIngreso, cDatosComp, cRespCte, sGrupo, sElemento
			FROM "informix".ss_detalle_scoring a
			LEFT OUTER JOIN "informix".ss_scoring_grupo b ON(a.grupo = b.grupo AND a.seccion = b.seccion AND b.mostrar_pantalla = 1)
			LEFT OUTER JOIN "informix".ss_scoring_element c ON(a.grupo = c.grupo AND a.seccion = c.seccion  AND a.tpo_persona = c.tpo_persona AND a.elemento = c.elemento)
			LEFT OUTER JOIN "informix".ss_resum_scor_fin d ON(d.empresa = pEmpresa AND a.num_solicitud = d.num_solicitud)--JMAH 09-18-2013  AND d.meses_historia=d.meses_historia)
			WHERE a.num_solicitud = cNumSolicitud
			ORDER BY a.grupo 
					
			IF iContador <= 19 THEN --si el contador es menor o igual a la paginacion que se da entra y da los retornos
				RETURN TRIM(cCodret) , NVL(iPaginacionRetorno, 0), NVL(mIngreso, 0.00), NVL(cDatosComp,''), NVL(cRespCte, ''), NVL(sGrupo, 0), NVL(sElemento, 0) WITH RESUME;
				LET iContador = iContador + 1; --CADA VEZ QUE REGRESA UN REGISTRO AUMENTA 1
				LET iPaginacionRetorno = iPaginacionRetorno + 1 ;
			ELSE 
				EXIT FOREACH;
			END IF;
		END FOREACH;
					
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000005'; --EL NÚMERO DE SOLICITUD NO TIENE REGISTRADAS PREGUNTAS/RESPUESTAS/INGRESO
			LET iPaginacionRetorno = 0 ; --SE INICIALIZA EL VALOR.
		END IF;
	END IF;
	IF cCodret <> '000000' THEN
		RETURN TRIM(cCodret) , NVL(iPaginacionRetorno, 0), NVL(mIngreso, 0.00), NVL(cDatosComp,''), NVL(cRespCte, ''), NVL(sGrupo, 0), NVL(sElemento, 0);
	END IF;
END;
END PROCEDURE
