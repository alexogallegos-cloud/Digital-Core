CREATE PROCEDURE "informix".sp_retiro_autoriza(pEmpresa CHAR(3), pSucursal CHAR(4), pEjecutivo CHAR (8), pNombre CHAR(40), pTransaccion CHAR(3), pFolio_suc CHAR(16))
	RETURNING CHAR(5) AS CodigoRetorno;

-- *	DEFINICION DE VARIABLES		  
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cPuesto CHAR(20);

		
-- *	ASIGNACION DE VARIABLES
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET cPuesto = '';
	
-- *	CONTROL DE ERRORES
BEGIN	
	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
	 -- SET DEBUG FILE TO '/respaldosbd/mario/sp_retiro_autoriza.out';
	 -- TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF  NVL(TRIM(pEmpresa),'') <> '' AND NVL(TRIM(pSucursal),'') <> '' AND NVL(TRIM(pEjecutivo),'') <> '' AND NVL(TRIM(pNombre),'') <> '' AND NVL(TRIM(pTransaccion),'') <> '' AND NVL(TRIM(pFolio_suc),'') <> '' THEN
		
		SELECT nombramiento 
		INTO cPuesto
		FROM  bdinteg:"informix".si_ejecut 
		WHERE ejecutivo = pEjecutivo;

		INSERT INTO bdinteg:"informix".si_retiro_autoriza (empresa,sucursal,ejecutivo,nombre,puesto,transaccion,fecha_operacion,folio_suc) VALUES (pEmpresa,pSucursal,pEjecutivo,pNombre,cPuesto,pTransaccion,CURRENT,pFolio_suc);
		
	ELSE
		LET cCodRet = '00110';
	END IF;	

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'Folio: 1730 - OperacionesMayoresConNIP',
'Autor: 95142134 Mario Gallardo',
'Fecha: 02/06/2015',
'Modificación: Se crea procedimiento para agregar registro de quien autoriza un retiro a la tabla bitacora si_retiro_autoriza ',
'Sustento: RQM 06 221Operaciones Mayores con NIP y autorizadas por cajero o gerente.pdf',
'Solicita: Rodolfo Gómez',
'BD: bdinteg';

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