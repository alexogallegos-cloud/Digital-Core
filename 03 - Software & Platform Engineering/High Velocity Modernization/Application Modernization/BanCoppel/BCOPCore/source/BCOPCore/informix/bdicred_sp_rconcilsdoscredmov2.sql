CREATE PROCEDURE "informix".sp_rconcilsdoscredmov2(p_empresa  char(3), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING  char(3), char(25), char(40), char(14), MONEY(18,2), MONEY(18,2), MONEY(18,2), MONEY(18,2), MONEY(18,2), MONEY(18,2);


--*****************************************************************************
--   DECLARACION DE VARIABLES
--*****************************************************************************

DEFINE c_producto			CHAR(25);
DEFINE c_cocepto			CHAR(40);
DEFINE c_nivelcontable		CHAR(14); 
DEFINE m_abono_operativo	MONEY(18,2);
DEFINE m_cargo_operativo	MONEY(18,2);
DEFINE m_abono_conta		MONEY(18,2);
DEFINE m_cargo_conta		MONEY(18,2);
DEFINE m_abonos_dif			MONEY(18,2);
DEFINE m_cargos_dif			MONEY(18,2);

DEFINE p_cod_ret       		CHAR(3);
DEFINE sSqlErr          	SMALLINT;

LET c_producto			= '';		
LET c_cocepto			= '';
LET c_nivelcontable		= '';
LET m_abono_operativo	= 0;
LET m_cargo_operativo	= 0;
LET m_abono_conta		= 0;
LET m_cargo_conta		= 0;
LET m_abonos_dif		= 0;
LET m_cargos_dif		= 0;

LET p_cod_ret 			='000';
LET sSqlErr             = 0;

--SET DEBUG FILE TO "/tmp/sp_rconcilsdoscredmov.out"; 
--TRACE ON;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--*****************************************************************************

BEGIN

	ON EXCEPTION SET sSqlErr
		LET p_cod_ret = sSqlErr;
		RETURN TRIM(NVL(p_cod_ret,"")), TRIM(NVL(c_producto,"")), TRIM(NVL(c_cocepto,"")),
			TRIM(NVL(c_nivelcontable,"")), NVL(m_abono_operativo,0), NVL(m_cargo_operativo,0),
			NVL(m_abono_conta,0), NVL(m_cargo_conta,0), NVL(m_abonos_dif,0), NVL(m_cargos_dif,0);
	END EXCEPTION;

	--REGRESE CODIGO DE RETORNO 001 CUANDO FALTA PARÃMETROS

	IF p_empresa is null OR p_empresa = '' OR LENGTH(p_empresa) < 3 THEN
		LET c_producto			= NULL;
		LET c_cocepto			= NULL;
		LET c_nivelcontable		= NULL;
		LET m_abono_operativo	= 0;
		LET m_cargo_operativo	= 0;
		LET m_abono_conta		= 0;
		LET m_cargo_conta		= 0;
		LET m_abonos_dif		= 0;
		LET m_cargos_dif		= 0;
		LET p_cod_ret = '001';
        RETURN p_cod_ret, c_producto, c_cocepto, c_nivelcontable, m_abono_operativo, m_cargo_operativo, m_abono_conta, m_cargo_conta,
		       m_abonos_dif, m_cargos_dif;
	END IF;
	
	FOREACH
		SELECT SKIP pRegistros FIRST pRecuperacion producto, concepto, nivelcontable, abono_operativo, cargo_operativo, abono_conta, cargo_conta, abonos_dif, cargos_dif
		  INTO c_producto, c_cocepto, c_nivelcontable, m_abono_operativo, m_cargo_operativo, m_abono_conta, m_cargo_conta,
		       m_abonos_dif, m_cargos_dif
		FROM bdicred:informix.sd_conciliacredito 
		
		RETURN p_cod_ret, c_producto, c_cocepto, c_nivelcontable, m_abono_operativo, m_cargo_operativo, m_abono_conta, m_cargo_conta,
		       m_abonos_dif, m_cargos_dif WITH RESUME;
	END FOREACH;
	
	--REGRESE CODIGO DE RETORNO 002 CUANDO NO EXISTE INFORMACION
	IF c_producto = '' OR c_producto is null OR c_cocepto = '' OR c_cocepto IS NULL OR c_nivelcontable = '' OR c_nivelcontable IS NULL THEN
		LET c_producto			= NULL;
		LET c_cocepto			= NULL;
		LET c_nivelcontable		= NULL;
		LET m_abono_operativo	= 0;
		LET m_cargo_operativo	= 0;
		LET m_abono_conta		= 0;
		LET m_cargo_conta		= 0;
		LET m_abonos_dif		= 0;
		LET m_cargos_dif		= 0;
			
		LET p_cod_ret = '002';
		RETURN p_cod_ret, c_producto, c_cocepto, c_nivelcontable, m_abono_operativo, m_cargo_operativo, m_abono_conta, m_cargo_conta,
		       m_abonos_dif, m_cargos_dif WITH RESUME;
	END IF;
END;
END PROCEDURE;