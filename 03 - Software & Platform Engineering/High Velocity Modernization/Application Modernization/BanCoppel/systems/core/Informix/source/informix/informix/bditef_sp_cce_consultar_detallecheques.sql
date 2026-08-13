CREATE PROCEDURE "informix".sp_cce_consultar_detallecheques( pEmpresa    CHAR(3),
                                                             pBanco      CHAR(3),
                                                             pCuenta     CHAR(20),
                                                             pNoCheque   CHAR(7) )
RETURNING CHAR(6) AS cod_ret,
          CHAR(3) AS compensacion,    
          CHAR(2) AS transacc,
          CHAR(3) AS codseguridad,
          CHAR(1) AS digverpre,
          CHAR(1) AS digverinter;
    
    -- // DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		CHAR(80);
    DEFINE cCodRet			CHAR(6);
    
    DEFINE cCompensacion	CHAR(3);
    DEFINE cTransacc		CHAR(2);
    DEFINE cCodSeguridad	CHAR(3);
    DEFINE cDigVerPre		CHAR(1);
    DEFINE cDigVerInter		CHAR(1);
    
    DEFINE viCuenta         INT8;
    DEFINE viNoCheque       INTEGER;
    DEFINE vcCuenta         CHAR(20);
    DEFINE vcNoCheque       CHAR(7);
    
    -- // INICIALIZACIONES
    LET iSqlErr    = 0;
    LET iIsamErr   = 0;
    LET cErrorInfo = "";
    LET cCodRet    = "000000";
    
    LET cCompensacion = "";
    LET cTransacc     = "";
    LET cCodSeguridad = "";
    LET cDigVerPre    = "";
    LET cDigVerInter  = "";
    
    LET viCuenta   = 0;
    LET vcCuenta   = '';
    LET viNoCheque = 0;
    LET vcNoCheque = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cCompensacion, cTransacc, cCodSeguridad, cDigVerPre, cDigVerInter;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- SET DEBUG FILE TO '/respaldosbd/has/sp_cce_consultar_detallecheques.out';
    --- TRACE ON;
    
    IF NVL(pEmpresa,"") = "" OR NVL(pBanco,"") = "" OR NVL(pCuenta,"") = "" OR NVL(pNoCheque,"") = "" THEN
        -- FALTAN UNO O MAS PARAMETROS
        LET cCodRet = "000001";
        RETURN cCodRet, cCompensacion, cTransacc, cCodSeguridad, cDigVerPre, cDigVerInter;
    ELSE
        LET viCuenta = pCuenta::INT8;
        LET vcCuenta = viCuenta::CHAR(20);
        LET viNoCheque = pNoCheque::INTEGER;
        LET vcNoCheque = viNoCheque::CHAR(7);
        
        FOREACH WITH HOLD
            SELECT compensacion, transaccion, codseguridad, digverpre, digverinter
              INTO cCompensacion, cTransacc, cCodSeguridad, cDigVerPre, cDigVerInter
              FROM bditef:cce_cheques_det
             WHERE empresa = pEmpresa 
               AND cvebanco = pBanco
               AND numcuenta = vcCuenta
               AND numcheque = vcNoCheque
            
            RETURN cCodRet, cCompensacion, cTransacc, cCodSeguridad, cDigVerPre, cDigVerInter WITH RESUME;
        END FOREACH 
    END IF;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que consulta el detalle de cheques para el código 40, 46 y 47', 
'BD: bditef', 
'AUTOR: Mohamed Carreón ',
'FECHA: Octubre 2012',
'VERSION: 20121026.1305';

CREATE PROCEDURE "informix".sp_obtenermensajeerror(psCodError CHAR(5))
RETURNING CHAR(5) AS CodRet, VARCHAR(121) AS Descripcion; 


--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LAS DESCRIPCIONES DE LOS MENSAJES DE ERROR
-- AUTOR : Casanova Edeza Hector Juan.
-- FECHA : 09/03/2011
-- BD: BdiTEF
-- SISTEMA : Transferencia Electronica de Fondos
--****************************************************************************************************

---DECLARACIONES
DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;

DEFINE vsDescripcion VARCHAR(121);

---INICIALIZACIONES
LET vsCodRet = '00000';
LET vsDescripcion = "";

BEGIN

--SET DEBUG FILE TO "/dbexport/TEF/trace/sp_obtenermensajeerror.out";
--TRACE ON;

	ON EXCEPTION
		SET viSqlErr, viSamErr
		IF viSqlErr <> 0 THEN
			LET vsCodRet = viSqlErr;
		END IF;

		RETURN vsCodRet, NULL;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	LET psCodError = TRIM(psCodError);

	SELECT trim(Modulo) || " " || trim(Descripcion)
	INTO vsDescripcion
	FROM BdiTef:"informix".Tef_Cat_Mensajes_Error
	WHERE Cod_Ret = psCodError;

	IF vsDescripcion IS NULL THEN
		SELECT trim(Modulo) || " " || trim(Descripcion)
		INTO vsDescripcion
		FROM BdiTef:"informix".Tef_Cat_Mensajes_Error
		WHERE Cod_Ret = "00500";
	END IF

	RETURN psCodError, vsDescripcion;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Transferencia Electronica de Fondos',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: OBTIENE LAS DESCRIPCIONES DE LOS MENSAJES DE ERROR.',
'Fecha: 2011/03/09',
'Version: 20110309.1015',
'BD: BdiTef';

CREATE PROCEDURE "informix".sp_valida_imagencheque
(
	pcEmpresa 		CHAR(3),
	pcNumCheq		CHAR(7),
	pcCveBanco		CHAR(3),
	pcNumCuenta		CHAR(20),
	pdFechaAlta		DATE
)

RETURNING
--DATOS A REGRESAR--
CHAR(5);   					--Codigo de Retorno

--DEFINICION DE VARIABLES--
DEFINE iSql_err 		INTEGER;
DEFINE cCodRet 			CHAR(5);
DEFINE wBegin			CHAR(1);
DEFINE iexiste	 		INTEGER;

--INICIACION DE VARIABLES--
LET iSql_err 			=	0;
LET cCodRet 			=	'00001';
LET wBegin				=	'N';
LET iexiste				=   0;


	--SET DEBUG FILE TO "/tmp/sp_valida_imagencheque.out";
	--TRACE ON;


	
	BEGIN
	
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				ROLLBACK WORK;
				IF (wBegin = 'S') THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET wBegin = 'S';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		BEGIN WORK;
		
		IF pcEmpresa <> '' AND pcNumCheq <> '' AND pcCveBanco <> '' AND pcNumCuenta <> '' AND pdFechaAlta IS NOT NULL THEN
		
			--IF EXISTS( SELECT numcheque FROM "informix".cce_cheques_img WHERE empresa = pcEmpresa AND numcheque = pcNumCheq AND cvebanco = pcCveBanco AND numcuenta = pcNumCuenta AND fecha_alta = pdFechaAlta) THEN
			SELECT count(*) into iexiste  FROM "informix".cce_cheques_img WHERE empresa = pcEmpresa AND numcheque = pcNumCheq AND cvebanco = pcCveBanco AND numcuenta = pcNumCuenta AND fecha_alta = pdFechaAlta;

			IF (iexiste > 0) THEN
					DELETE FROM "informix".cce_cheques_img WHERE empresa = pcEmpresa AND numcheque = pcNumCheq AND cvebanco = pcCveBanco 
					AND numcuenta = pcNumCuenta AND fecha_alta = pdFechaAlta;			
			END IF;
			
			LET cCodRet = '00000';
		
		END IF;
		
		COMMIT WORK;
		  
		IF (wBegin = 'S') THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
		
	END

END PROCEDURE
DOCUMENT
'Folio........: 1408',
'Autor........: 95526749 ',
'Fecha........: 29/04/2014',
'Descripcion..: Funcion que elimina el registro de la cce_cheques_img.',
'Sustento.....: INC 24 021 Cheques en Blanco',
'Solicita.....: Cutberto Gonzalez Perez',
'BD...........: BDITEF';

CREATE PROCEDURE "informix".obtenerimagennula(pempresa       char(3),
									  pcvebanco   	 char(3),
									  pnumcuenta   	 char(20),
									  pnumcheque   	 char(7),
									  pfechapresenta char(10))
RETURNING char(5);  

    DEFINE v_codret char(5);
    DEFINE sql_err,isam_err int;   
    DEFINE v_existe int;

    -- // Inicializa variables
    LET v_codret    = "000";
    LET v_existe    = 0;
    
    -- // Valida la informacion de entrada
    IF pempresa    	  is null or
		pcvebanco      is null or
		pnumcuenta     is null or
		pnumcheque     is null or
		pfechapresenta is null THEN
		LET v_codret = "110"; -- // datos de entrada incompletos
		RETURN v_codret; 
    END IF;
    
    BEGIN

    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            return v_codret;
        end if;
    end exception;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

    -- // validacion imagen nula
		select count(numcheque)
		into v_existe
		from "informix".cce_cheques_img
		where empresa = pempresa
		and cvebanco = pcvebanco
		and numcuenta = pnumcuenta
		and numcheque = pnumcheque
		and fechapresenta = pfechapresenta
		and imagen is null;

    IF v_existe > 0 THEN 
        LET v_codret = "130"; 
        RETURN v_codret;                 
    END IF;  
    
    END;    

    RETURN v_codret;

END PROCEDURE;