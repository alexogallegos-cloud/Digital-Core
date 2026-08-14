CREATE PROCEDURE "informix".sp_consultarexpediente_cliente(
pEmpresa     CHAR(3),
pCliente     CHAR(20),
pProducto    CHAR(5),
pTipoCliente CHAR(2)
)

RETURNING
CHAR(5)    AS cCodret

DEFINE sql_err       INTEGER;
DEFINE cCodret       CHAR(5);
DEFINE siSecuencia   SMALLINT;
DEFINE cDescProd     CHAR(40);
DEFINE cCod_docto    CHAR(4);
DEFINE cDescrip2     CHAR(30); 
DEFINE cNumRegistros SMALLINT;
DEFINE cBandM1		 SMALLINT;
DEFINE cBandM2		 SMALLINT;
DEFINE cCont		 SMALLINT;
DEFINE cSecAux		 SMALLINT;
DEFINE cCod_docAux	 CHAR(4);
DEFINE cBandIdentC   SMALLINT;
DEFINE cMismoDoc     CHAR(4);

LET cCodret = "00000";
LET siSecuencia = 0;
LET cDescProd = "";
LET cCod_docto = "";
LET cDescrip2 = "";
LET cNumRegistros = 0;
LET cBandM1 = 0;
LET cBandM2 = 0;
LET cCont = 0;
LET cSecAux = 0;
LET cCod_docAux = "";
LET cBandIdentC = 0;
LET cMismoDoc = "";

BEGIN
 
    ON EXCEPTION SET sql_err

		RETURN sql_err;

    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/LIP/sp_consultarexpediente_cliente.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--VALIDAR DATOS VACIOS
	IF NVL(pEmpresa,'') = '' OR NVL(pCliente, '') = '' OR NVL(pProducto, '') = '' OR NVL(pTipoCliente, '') = '' THEN	
		LET cCodret = "00002"; --Datos vacios
		RETURN cCodret;
	ELSE 
		IF pTipoCliente = 1 THEN --extranjero ?
		
			SELECT COUNT(DISTINCT(ex.cod_docto))
			INTO cNumRegistros
				FROM dg_expediente ex, 
  					 dg_grupodocto gd,
                 	 dg_tipodocumento td
				WHERE ex.cod_docto = td.cod_docto
				AND td.cod_grupo = gd.cod_grupo
				AND ex.empresa = pEmpresa
				AND ex.cliente = pCliente 
				AND ex.producto = pProducto
				AND td.cod_grupo = '001';
			
			IF cNumRegistros > 1 THEN 
				LET cCodret = "00000";
			ELSE
				LET cCodret = "00001";
			END IF;	
		
		ELIF pTipoCliente = 2 THEN --menor de edad
		
			SELECT COUNT(DISTINCT(ex.cod_docto))
			INTO cNumRegistros
				FROM dg_expediente ex, 
  					 dg_grupodocto gd,
                 	 dg_tipodocumento td
				WHERE ex.cod_docto = td.cod_docto
				AND td.cod_grupo = gd.cod_grupo
				AND ex.empresa = pEmpresa
				AND ex.cliente = pCliente 
				AND ex.producto = pProducto
				AND td.cod_grupo = '045';
			
			IF cNumRegistros > 1 THEN 
				LET cBandM1 = 1;
			END IF;
			
			LET cNumRegistros = 0;
			
			SELECT COUNT(DISTINCT(ex.cod_docto)) -- tutor
			INTO cNumRegistros
				FROM dg_expediente ex, 
  					 dg_grupodocto gd,
                 	 dg_tipodocumento td
				WHERE ex.cod_docto = td.cod_docto
				AND td.cod_grupo = gd.cod_grupo
				AND ex.empresa = pEmpresa
				AND ex.cliente = pCliente 
				AND ex.producto = pProducto
				AND td.cod_grupo = '140';
				
			IF cNumRegistros > 0 THEN 
				LET cBandM2 = 1;
			END IF;
				
			IF cBandM1 = 1 AND cBandM2 = 1 THEN
				LET cCodret = "00000";
			ELSE
				LET cCodret = "00001";
			END IF;
			
		ELIF pTipoCliente = 3 THEN	-- nacional otras?
		
			SELECT COUNT(DISTINCT(ex.cod_docto))
			INTO cNumRegistros
				FROM dg_expediente ex, 
  					 dg_grupodocto gd,
                 	 dg_tipodocumento td
				WHERE ex.cod_docto = td.cod_docto
				AND td.cod_grupo = gd.cod_grupo
				AND ex.empresa = pEmpresa
				AND ex.cliente = pCliente 
				AND ex.producto = pProducto
				AND td.cod_grupo = '001';
			
			IF cNumRegistros > 1 THEN 
				LET cCodret = "00000";
			ELSE
				LET cCodret = "00001";
			END IF;	
		
		ELIF pTipoCliente = 4 THEN --nacional ine
		
			SELECT COUNT(DISTINCT(ex.cod_docto))
			INTO cNumRegistros
				FROM dg_expediente ex, 
  					 dg_grupodocto gd,
                 	 dg_tipodocumento td
				WHERE ex.cod_docto = td.cod_docto
				AND td.cod_grupo = gd.cod_grupo
				AND ex.empresa = pEmpresa
				AND ex.cliente = pCliente 
				AND ex.producto = pProducto
				AND td.cod_grupo = '001'
				AND td.cod_docto = '0001';

			IF cNumRegistros > 0 THEN 
				LET cCodret = "00000";
			ELSE
				LET cCodret = "00001";
			END IF;	
			
		ELSE 
			LET cCodret = "00001";
		END IF;
		
	END IF;
    RETURN cCodret;
	
END;
END PROCEDURE;