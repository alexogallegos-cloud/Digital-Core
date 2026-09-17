CREATE PROCEDURE "informix".sp_ctepr_consultaresultparametrico
(	
	pCteProspecto 	 CHAR (20),	
	pTpoPersona		 CHAR (2)
)
RETURNING	
	CHAR (5)  AS Cod_Ret,
	CHAR (1)  AS Solicitud,
	CHAR (2)  AS TP_Persona,
	CHAR (3)  AS Seccion,
	CHAR (3)  AS Grupo,
	CHAR (3)  AS Elemento,
	CHAR (80) AS Gpo_descripcion,
	CHAR (3)  AS Orden_Presenta,
	CHAR (80) AS Element_descripcion;
	
	
	
	DEFINE cCodRet 					CHAR (5);
	DEFINE iSqlErr 					INTEGER;
	DEFINE cTPSolicitud 			CHAR (1);
	DEFINE cTPPersona 				CHAR (2);
	DEFINE cSec		 				CHAR (3);
	DEFINE cGpo						CHAR (3);
	DEFINE cElemento				CHAR (3);
	DEFINE cGpo_descripcion 		CHAR (80);
	DEFINE cOrden_Presenta 			CHAR (3);
	DEFINE cElement_descripcion 	CHAR (80);
	
	
	LET cCodRet					= '00000';
	LET iSqlErr 				= 0;	
	LET cTPSolicitud 			= '';	
    LET cTPPersona 				= '';
	LET cSec	 			    = '';
	LET cGpo					= '';
	LET cElemento				= '';
	LET cGpo_descripcion 		= '';
	LET cOrden_Presenta 		= '';
	LET cElement_descripcion	= '';
	
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, NVL(cTPSolicitud, ''), NVL(cTPPersona, ''), NVL(cSec, ''), NVL(cGpo, ''), NVL(cElemento, ''),  NVL(cGpo_descripcion, ''), NVL(cOrden_Presenta, ''),NVL(cElement_descripcion, '');
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1468/sp_ctepr_consultaresultparametrico.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3; 
		
		IF NVL(pCteProspecto, '') = ''  OR NVL(pTpoPersona, '') = ''  THEN
			LET cCodRet = '00001';
			RETURN cCodRet, NVL(cTPSolicitud, ''), NVL(cTPPersona, ''), NVL(cSec, ''), NVL(cGpo, ''), NVL(cElemento, ''),  NVL(cGpo_descripcion, ''), NVL(cOrden_Presenta, ''),NVL(cElement_descripcion, '');				
		ELSE			
			FOREACH
				SELECT DISTINCT(sSolic.tp_solicitud), sSolic.tpo_persona, cSeccion.seccion, sGrupo.grupo, sElement.elemento, sGrupo.descripcion, sGrupo.orden_presentacion, 
								sElement.descripcion
				INTO cTPSolicitud, cTPPersona, cSec, cGpo, cElemento, cGpo_descripcion, cOrden_Presenta, cElement_descripcion
				FROM "informix".pr_scoring_grupo AS sGrupo
				INNER JOIN "informix".pr_scoring_seccion AS cSeccion ON (sGrupo.empresa = cSeccion.empresa AND sGrupo.seccion = cSeccion.seccion) 
				INNER JOIN "informix".pr_scoring_solic AS sSolic ON (cSeccion.empresa = sSolic.empresa AND sSolic.tp_solicitud = 'T' 
							AND sSolic.tpo_persona = pTpoPersona AND cSeccion.seccion = sSolic.seccion AND sSolic.seccion = 2)
				INNER JOIN "informix".pr_detalle_scoring AS detScoring ON (sGrupo.empresa = detScoring.empresa 
							AND sGrupo.grupo = detScoring.grupo AND sGrupo.seccion = detScoring.seccion AND detScoring.num_solicitud = pCteProspecto) 
				INNER JOIN "informix".pr_scoring_element AS sElement ON (sGrupo.empresa = sElement.empresa AND sGrupo.grupo = sElement.grupo  
							AND sGrupo.seccion = sElement.seccion AND detScoring.elemento = sElement.elemento AND detScoring.tpo_persona = sElement.tpo_persona) 
				WHERE sGrupo.grupo IN(4,41,6,8,9,11,21,39)
				AND sGrupo.mostrar_pantalla = '1' 
				ORDER BY sSolic.tp_solicitud, sSolic.tpo_persona, cSeccion.seccion, sGrupo.orden_presentacion

				RETURN cCodRet, NVL(cTPSolicitud, ''), NVL(cTPPersona, ''), NVL(cSec, ''), NVL(cGpo, ''), NVL(cElemento, ''),  NVL(cGpo_descripcion, ''), NVL(cOrden_Presenta, ''),NVL(cElement_descripcion, '') WITH RESUME;
			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00002';
				RETURN cCodRet, NVL(cTPSolicitud, ''), NVL(cTPPersona, ''), NVL(cSec, ''), NVL(cGpo, ''), NVL(cElemento, ''),  NVL(cGpo_descripcion, ''), NVL(cOrden_Presenta, ''),NVL(cElement_descripcion, '');
			END IF;		
		END IF;
		
	END;
END PROCEDURE

