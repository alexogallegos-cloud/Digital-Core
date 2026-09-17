CREATE PROCEDURE "informix".sp_consultaempresa(p_empresa  char(3))
RETURNING  char(3), char(30);


--*****************************************************************************
--   DECLARACION DE VARIABLES
--*****************************************************************************

DEFINE  v_razon_social  char(30);
DEFINE  p_cod_ret       char(3);

LET p_cod_ret ='000';
LET  v_razon_social  = '';

--SET DEBUG FILE TO "/tmp/sp_consultaempresa.out"; 
--TRACE ON;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--*****************************************************************************
BEGIN
	IF p_empresa is null OR p_empresa = '' OR LENGTH(p_empresa) < 3 THEN
		LET v_razon_social = NULL;
        LET p_cod_ret = '001';
        RETURN p_cod_ret, trim(v_razon_social);
	END IF;

	SELECT razon_social
    INTO   v_razon_social
    FROM   si_empresas
    WHERE  empresa = p_empresa;
		
	IF v_razon_social is null or v_razon_social = '' THEN
		LET v_razon_social = NULL;
		LET p_cod_ret = '002';
		RETURN p_cod_ret, trim(v_razon_social);
	END IF;
END;
RETURN p_cod_ret, v_razon_social;
END PROCEDURE;