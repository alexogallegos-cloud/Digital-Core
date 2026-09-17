CREATE PROCEDURE "informix".sp_consultarmaxsecuenciadocumento(pEmpresa CHAR(3),pCliente CHAR(20),pCodDocto CHAR(4),pCuenta CHAR(11))
RETURNING CHAR(6),
          SMALLINT;

--Declaracion de varibales
DEFINE cCodRet  CHAR(6);
DEFINE iMaxSec  SMALLINT;
DEFINE sql_err  INT;  

ON EXCEPTION SET sql_err
    LET cCodRet = sql_err;
    RETURN  cCodRet, iMaxSec;
END EXCEPTION;

--Inicualizacion de variables.
LET cCodRet='000000'; 
LET iMaxSec = 0;

--SET DEBUG FILE TO "/home/sysifx/vlv/sp_consultarmaxsecuenciadocumento.out";
--TRACE ON;

BEGIN

--Verifica que no contenga parametros nulos
IF pEmpresa <> '' AND pCliente <> '' AND pCodDocto <> '' THEN
    
	--Cosulta la maxima secuencia del documento que se quiere consultar.
	SELECT MAX(Secuencia) INTO iMaxSec 
	FROM bdidigital@coppelimg_tcp:"informix".dg_expediente
	-----WHERE empresa = pEmpresa
	WHERE cliente = pCliente
	  AND cod_docto = pCodDocto
      AND cuenta=pCuenta;
	
	IF iMaxSec = '' OR iMaxSec IS NULL THEN
	   LET cCodRet = '000001';  --No se encuentran los registros.
	END IF;
	
ELSE
    LET cCodRet = '000002'; --Contiene parametros nulos o vacios
END IF;

RETURN  cCodRet, iMaxSec;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Valentin Lopez',
'FECHA: 16 de Mayo del 2011',
'DESCRIPCION: Obtiene la maxima secuencia del documento que se quiere consultar.',
'VERSION: 20110516.1039',
'BD: bdidigital';

create procedure "informix".cons_sec_expendiente(pempresa char(3), pcliente	char(20),pcod_docto char(4))
			RETURNING char(5), smallint;


   DEFINE v_codret          char(5);
   DEFINE sql_err,isam_err  int;
   DEFINE v_secuencia smallint;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "000";
   LET v_secuencia = 0;

BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_codret,v_secuencia;
      end if;
   end exception;


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
  SET ISOLATION TO DIRTY READ;

	IF  	pempresa is null or pcliente is null or pcod_docto is null then
	   -- datos de entrada incompletos
	   let v_codret = '110';
	   RETURN v_codret,v_secuencia;
	END IF;


-- ****************************************************************************
-- devuelve la secuencia
-- ****************************************************************************
        select max(secuencia) into v_secuencia 
        from bdidigital@coppelimg_tcp:dg_expediente
        --from bdidigital@coppelimgdn_tcp:dg_expediente_img
        -----where empresa   = pempresa
        where cliente   = trim(pcliente)
        and cod_docto   = pcod_docto;

        IF v_secuencia is null then
                LET v_secuencia = 1;
        ELSE
                LET v_secuencia = v_secuencia +1;
        END IF;

	RETURN v_codret,v_secuencia;

END;
END PROCEDURE;