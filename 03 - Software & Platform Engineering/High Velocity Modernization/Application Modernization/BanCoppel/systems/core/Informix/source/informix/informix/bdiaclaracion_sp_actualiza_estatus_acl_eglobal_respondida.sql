CREATE PROCEDURE "informix".sp_actualiza_estatus_acl_eglobal_respondida(e_folio_csuac VARCHAR(11)) 

RETURNING  CHAR(3) AS s_CodRetorno, INTEGER AS s_EstatusCorpNuevo;

/* Variables Salida*/
DEFINE s_CodRet         CHAR(3);
DEFINE s_EstatusCorpNew INTEGER;

/* Variables locales*/
DEFINE s_EstatusCorp    INTEGER;
DEFINE s_EstatusCorpAnt INTEGER;
DEFINE l_EstatusConsultado INTEGER;
DEFINE iSqlErr INTEGER;


/* Evita bloqueo de tabla*/
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

 /* Asignacion de valores */
LET s_CodRet            = '000';
LET s_EstatusCorp       = 14;
LET s_EstatusCorpAnt    = 10;
LET s_EstatusCorpNew    = 0;
LET l_EstatusConsultado = (SELECT fky_estatus_corp_analisis from acl_aclaracion WHERE folio_csuac = e_folio_csuac); 

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET s_CodRet = '002';  
			RETURN s_CodRet,s_EstatusCorpNew;
		END IF;
	END EXCEPTION;

	
	 /* Validacion de el estatus corporativo ya esta respondido 001*/
	IF (l_EstatusConsultado==s_EstatusCorpAnt) THEN
		/* Actualizacion del campo fky_estatus_corp_analisis en la aclaracion */
		UPDATE "informix".acl_aclaracion set fky_estatus_corp_analisis = s_EstatusCorp WHERE folio_csuac = e_folio_csuac and fky_estatus_corp_analisis=s_EstatusCorpAnt;
	ELSE
		LET s_CodRet='001';
		LET s_EstatusCorpNew = l_EstatusConsultado;
	END IF; /* Validacion de el estatus corporativo ya esta respondido 001*/
	
	LET s_EstatusCorpNew =  (SELECT fky_estatus_corp_analisis from acl_aclaracion WHERE folio_csuac = e_folio_csuac);

	RETURN s_CodRet, s_EstatusCorpNew; /*Retorno de valores*/
END;
END PROCEDURE;