CREATE PROCEDURE "informix".sp_rconcilsdoscred2(p_empresa  char(3), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING  char(3), char(25), char(40), char(14), MONEY(18,2), MONEY(18,2), MONEY(18,2);


--*****************************************************************************
--   DECLARACION DE VARIABLES
--*****************************************************************************

DEFINE c_producto		CHAR(25);
DEFINE c_cocepto		char(40);
DEFINE c_nivelcontable	char(14); 
DEFINE m_sdoperativo	MONEY(18,2);
DEFINE m_sdcontable		MONEY(18,2);
DEFINE m_sdodif			MONEY(18,2);
DEFINE p_cod_ret       	char(3);
DEFINE sSqlErr          SMALLINT;


LET c_producto			= '';		
LET c_cocepto			= '';
LET c_nivelcontable		= '';
LET m_sdoperativo		= 0;
LET m_sdcontable		= 0;
LET m_sdodif			= 0;

LET p_cod_ret 			='000';
LET sSqlErr             = 0;

--SET DEBUG FILE TO "/tmp/sp_rconcilsdoscred.out"; 
--TRACE ON;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--*****************************************************************************

BEGIN

	ON EXCEPTION SET sSqlErr
		LET p_cod_ret = sSqlErr;
		RETURN TRIM(NVL(p_cod_ret,"")), TRIM(NVL(c_producto,"")), TRIM(NVL(c_cocepto,"")),
			TRIM(NVL(c_nivelcontable,"")), NVL(m_sdoperativo,0), NVL(m_sdcontable,0),
			NVL(m_sdodif,0);
	END EXCEPTION;

	--REGRESE CODIGO DE RETORNO 001 CUANDO FALTA PARÃMETROS

	IF p_empresa is null OR p_empresa = '' OR LENGTH(p_empresa) < 3 THEN
		LET c_producto			= NULL;
		LET c_cocepto			= NULL;
		LET c_nivelcontable		= NULL;
		LET m_sdoperativo		= 0;
		LET m_sdcontable		= 0;
		LET m_sdodif			= 0;
		LET p_cod_ret = '001';
        RETURN p_cod_ret, c_producto, c_cocepto, c_nivelcontable, m_sdoperativo, m_sdcontable, m_sdodif;
	END IF;
	
	FOREACH
		SELECT SKIP pRegistros FIRST pRecuperacion producto, concepto, nivelcontable, sdoperativo, sdocontable, sdodif
		  INTO c_producto, c_cocepto, c_nivelcontable, m_sdoperativo, m_sdcontable, m_sdodif
		FROM bdicred:informix.sd_conciliacredito
		
		RETURN p_cod_ret, c_producto, c_cocepto, c_nivelcontable, m_sdoperativo, m_sdcontable, m_sdodif WITH RESUME;
	END FOREACH;
	
	--REGRESE CODIGO DE RETORNO 002 CUANDO NO EXISTE SUCURSAL
	IF c_producto = '' OR c_producto is null OR c_cocepto = '' OR c_cocepto IS NULL OR c_nivelcontable = '' OR c_nivelcontable IS NULL THEN
		LET c_producto			= NULL;
		LET c_cocepto			= NULL;
		LET c_nivelcontable		= NULL;
		LET m_sdoperativo		= 0;
		LET m_sdcontable		= 0;
		LET m_sdodif			= 0;
			
		LET p_cod_ret = '002';
		RETURN p_cod_ret, c_producto, c_cocepto, c_nivelcontable, m_sdoperativo, m_sdcontable, m_sdodif WITH RESUME;
	END IF;
END;
END PROCEDURE;