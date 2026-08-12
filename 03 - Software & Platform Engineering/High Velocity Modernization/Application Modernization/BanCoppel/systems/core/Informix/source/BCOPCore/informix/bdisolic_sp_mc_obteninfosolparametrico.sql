CREATE PROCEDURE "informix".sp_mc_obteninfosolparametrico(pEmpresa CHAR(3), pNumSol CHAR(20),pTpPersona CHAR(2))
--RETORNOS-
RETURNING
CHAR(6)      AS codigo_ret,
CHAR(80)     AS mensaje_retorno,
CHAR(80)     AS pregunta,
CHAR(80)     AS respuesta,
DECIMAL(5,2) AS valor;
	  
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cPregunta		CHAR(80);
DEFINE cRespuesta		CHAR(80);
DEFINE dValor			DECIMAL(5,2);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó la consulta correctamente";
LET cPregunta			= "";
LET cRespuesta			= "";
LET dValor			    = 0;
 

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
		 LET cCodRet= iSqlErr;
		 RETURN cCodRet, cMensajeRet,cPregunta,cRespuesta,dValor; 
	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/jesus/sp_mc_obteninfosolparametrico.out';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	  --CONTROL DE ERRORES POR PARAMETRO--
	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSol,'')= '' OR  NVL(pTpPersona, '') = '' THEN
		LET cCodret = '000001'; --PROPORCIONE PARAMETROS PARA EJECUTAR EL PROCEDIMIENTO
		RETURN cCodRet, cMensajeRet,cPregunta,cRespuesta,dValor;
	 END IF;
	 
	
			
		FOREACH
		 
         SELECT TRIM(a.descripcion) ,TRIM(c.descripcion) ,NVL(b.valor,0) 
			INTO cPregunta,cRespuesta,dValor
         FROM "informix".ss_scoring_grupo a, "informix".ss_detalle_scoring b, "informix".ss_scoring_element c 
         WHERE a.seccion = '2'
         AND a.empresa = b.empresa 
         AND a.seccion = b.seccion 
         AND a.grupo = b.grupo 
         AND b.tpo_persona= pTpPersona 
         AND b.num_solicitud = pNumSol
         AND a.empresa = c.empresa 
         AND a.seccion = c.seccion 
         AND a.grupo = c.grupo 
         AND b.elemento = c.elemento 
         AND b.tpo_persona = c.tpo_persona 
         ORDER BY b.seccion, b.grupo, b.elemento 		 
		 
				RETURN cCodRet, cMensajeRet,cPregunta,cRespuesta,dValor WITH RESUME;
		END FOREACH;
					
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000005'; 
			RETURN cCodRet, cMensajeRet,cPregunta,cRespuesta,dValor;
		END IF;
	
END	
END PROCEDURE
