CREATE PROCEDURE "informix".sp_consulta_divisas_bym(pEmpresa CHAR(3), pCodDivisa CHAR(2))
RETURNING   CHAR(6)  AS CodRet,
			CHAR(4)  AS Sigla,
			CHAR(3)  AS Cve_intl,
			CHAR(3)  AS Cve_oficial,
			CHAR(30) AS Descripcion;
			
-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err       INTEGER;
DEFINE cCodRet        CHAR(6);
DEFINE cSigla         CHAR(4);
DEFINE cCve_intl      CHAR(3);
DEFINE cCve_oficial   CHAR(3);
DEFINE cDescripcion   CHAR(30);
DEFINE iBandera       INTEGER;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err		 = 0;
LET cCodRet          = '000000';
LET cSigla		     = '';
LET cCve_intl        = '';
LET cCve_oficial     = '';
LET cDescripcion     = '';
LET iBandera         = 0;


SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_consulta_divisas_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			RETURN cCodRet, cSigla, cCve_intl, cCve_oficial, cDescripcion WITH RESUME;
		END IF;
	END EXCEPTION;
	
	IF TRIM(NVL(pEmpresa,'')) <> '' AND TRIM(NVL(pCodDivisa,'')) <> '' THEN 
		
			SELECT sigla, cve_intl, cve_oficial, descripcion
			INTO cSigla, cCve_intl, cCve_oficial, cDescripcion 
			FROM bdinteg:"informix".si_divisas
			WHERE divisa = pCodDivisa 
			AND	empresa = pEmpresa;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000002';
			END IF;			
			
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	RETURN cCodRet, cSigla, cCve_intl, cCve_oficial, cDescripcion WITH RESUME;
	
END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 03/02/2015',
'DESCRIPCION:Consulta los registros de la tabla si_divisas de acuerdo a un código en espeífico.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obt_razonsocial(pEmpresa CHAR(3), pNumCte CHAR(9))
	returning CHAR(5), CHAR(60);

	--Elaboro: Roberto Castro
	--Actividad: devuelve la razon social del cliente
	--Solicito: Gabriela Aguilar (BanCoppel)
	--Fecha: 21/07/2015
	---*********************************************

	--DEFINE VARIABLES
	DEFINE vRazonSocial CHAR (60);
	DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER; 

	--Inicializa
	LET cod_ret ='000';
	LET vRazonSocial= "";

 BEGIN
	ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vRazonSocial;
      END IF ;
	END EXCEPTION ;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF(pNumCte <> '') THEN

		SELECT razon_social INTO vRazonSocial FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte and empresa = pEmpresa;

		IF (vRazonSocial = '' OR vRazonSocial IS NULL) THEN
			LET cod_ret = '002';
		END IF;

	ELSE
		LET cod_ret = '001';
	END IF;

	RETURN cod_ret, vRazonSocial;
 END;
END PROCEDURE;