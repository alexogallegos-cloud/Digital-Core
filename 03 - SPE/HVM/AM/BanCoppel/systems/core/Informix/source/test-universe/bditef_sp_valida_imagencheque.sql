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