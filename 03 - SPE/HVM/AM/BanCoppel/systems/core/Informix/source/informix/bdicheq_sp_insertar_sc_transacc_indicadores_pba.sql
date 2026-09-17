CREATE PROCEDURE "informix".sp_insertar_sc_transacc_indicadores_pba
(
pEmpresa 		CHAR(3),
pNumero  		CHAR(4),
pSeEmiteEdoCta	CHAR(1)
)
	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";



BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	
	IF NVL(pSeEmiteEdoCta,"") = "S" THEN

		INSERT INTO "informix".sc_transacc_indicadores (empresa, numero)
		VALUES (pEmpresa, pNumero);

	END IF

	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para insertar el registro en los indicadores de la cuenta recien abierta',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Enero 2014';

CREATE PROCEDURE "informix".sp_insertar_sc_transacc_indicadores
(
pEmpresa 		CHAR(3),
pNumero  		CHAR(4),
pSeEmiteEdoCta	CHAR(1),
pSistema		CHAR(2)
)
	---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";



BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	
	IF NVL(pSeEmiteEdoCta,"") = "S" AND pSistema = "01" THEN

		INSERT INTO "informix".sc_transacc_indicadores (empresa, numero)
		VALUES (pEmpresa, pNumero);

	END IF

	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para insertar el registro en los indicadores de la cuenta recien abierta',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Enero 2014';

CREATE PROCEDURE "informix".sp_depura_sc_movhis_old(fecha_depurar DATE);
   define vcuenta char(20);
   let vcuenta = '';
   set isolation to dirty read;
   set lock mode to wait;
   FOREACH cursor_borra WITH HOLD FOR
                select {+INDEX (sc_movhis_old idx_movhis)} cuenta 
                  into vcuenta
                  FROM sc_movhis_old
                  WHERE empresa = '001'
                   AND cuenta between '10000000000' and '99099999999'
                   AND fech_alt =  fecha_depurar
           BEGIN WORK;
              DELETE FROM sc_movhis_old WHERE CURRENT OF cursor_borra;
           COMMIT WORK;
   END FOREACH
END PROCEDURE;