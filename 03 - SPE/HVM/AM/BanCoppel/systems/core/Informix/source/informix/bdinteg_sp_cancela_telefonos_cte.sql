CREATE PROCEDURE "informix".sp_cancela_telefonos_cte(
	pEmpresa     CHAR(3),
    pNumCte      CHAR(20), 
    pTelefono    CHAR(13),
    pTipoTel     SMALLINT)
	
	RETURNING CHAR(5) AS cCodRet1;
    
	--DEFINICION DE VARIABLES
    DEFINE cCodRet1 	    CHAR(5);
    DEFINE cCodRet2 		CHAR(5);
    DEFINE cCodRet3 		CHAR(50);
    DEFINE iSqlErr  		INTEGER;
    DEFINE iSamErr  		INTEGER;
    DEFINE cDesErr  		CHAR(50);
	DEFINE iOtroTipoTel     SMALLINT;
	DEFINE vSecuencia		SMALLINT;		
	
	--INICIALIZA VARIABLES
    LET cCodRet1		 = '000';
    LET cCodRet2		 = '';
    LET cCodRet3		 = '';
    LET iSqlErr			 = 0;
    LET iSamErr			 = 0;
    LET cDesErr			 = '';
	LET iOtroTipoTel	 = 0;
	LET vSecuencia		 ='0';
	
	--SET DEBUG FILE TO "/pisa/pisabanco/sp_cancela_telefonos_cte.out";
	--TRACE ON;
	
    BEGIN
	    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_telefonos.err";
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;
    		
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR (pNumCte is null OR pNumCte = '') OR
       (pTelefono is null OR pTelefono = '') OR (pTipoTel is null OR pTipoTel = 0) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO PARA OTRO TIPO DE TELEFONO PARA EL MISMO CLIENTE
    
	--Valida que el numero en cuestion no este registrado para ese cliente, pero con otro tipo de telefono
	IF pTipoTel IN (1, 2) THEN					   
		--SELECT COUNT(*)
		SELECT tipo_tel
		INTO iOtroTipoTel
		FROM "informix".si_telefonos
		WHERE numcte = pNumCte
		AND telefono = pTelefono
		AND tipo_tel != pTipoTel
		AND status_tel = 'A'
		AND tipo_tel IN (1,2)
		;

		IF iOtroTipoTel is null OR iOtroTipoTel = '' THEN
			LET cCodRet1 = '110';
			RETURN cCodRet1;
		END IF;

		SELECT secuencia INTO vSecuencia FROM bdinteg:"informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel=iOtroTipoTel AND status_tel = 'A' AND numcte = pNumCte;
	
		UPDATE "informix".si_telefonos
		   SET status_tel = 'C',
			fecha_actualiza = CURRENT::DATE		   
		 WHERE telefono = pTelefono
		   AND tipo_tel = iOtroTipoTel
		   AND status_tel = 'A'
		   AND secuencia = vSecuencia
		   AND numcte = pNumCte;


		SELECT secuencia INTO vSecuencia FROM bdinteg:"informix".si_telefonos_actual WHERE telefono=pTelefono AND tipo_tel=iOtroTipoTel AND status_tel = 'A' AND numcte = pNumCte;
			
		DELETE bdinteg:"informix".si_telefonos_actual
		WHERE telefono=pTelefono
		AND tipo_tel=iOtroTipoTel
		AND status_tel = 'A'
		AND secuencia = vSecuencia
		AND numcte = pNumCte;
		   
	ELSE
		LET cCodRet1 = '000';
	END IF;
	
    RETURN cCodRet1;
	
	END;
    
END PROCEDURE

DOCUMENT
'Modifico: Angeles Pérez',
'Fecha: 04/10/2024',
'BDD: bdinteg',
"Descripcion: Se cancela el telefono que tiene registrado el cliente con otro tipo de telefono";

CREATE PROCEDURE "informix".sp_valida_cel_repetido_tels(pNumCel CHAR(10), pNumCte CHAR(9), pSucursal CHAR(5))
RETURNING CHAR(5) as Cod_Ret, INTEGER as Repetidos;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;
DEFINE iValidaDiasTu    INTEGER;
DEFINE sTelefonoAct CHAR(13);
--TEls
DEFINE sNumcte 		CHAR(9);
--DEFINE sStatus_tel	CHAR(1);
DEFINE CodRet		CHAR(5);
DEFINE sTipoCte		CHAR(1);
DEFINE sSecuencia	CHAR(3);

LET sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;
LET iValidaDiasTu    = 0;
LET sTelefonoAct     = 0;
--TEls
LET sNumcte			= '';
--LET sStatus_tel		= '';
LET CodRet			= '00000';
LET sTipoCte		= '';
LET sSecuencia		= '';

BEGIN
    ON EXCEPTION SET iSqlErr 
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/LMendoza/sp_valida_cel_repetido.out';
--SET DEBUG FILE TO '/pisa/pisabanco/sp_valida_cel_repetido_tels.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;  
    SET LOCK MODE TO WAIT 3;
	
	SELECT telefono INTO sTelefonoAct FROM bdinteg:"informix".si_telefonos_actual WHERE numcte=pNumCte AND tipo_tel=2;
		IF (TRIM(sTelefonoAct) == TRIM(pNumCel)) THEN RETURN sCodRet, iCantRep;
			END IF;
	
	--Se cosulta el tipo de cliente que tiene el telefono celular
	SELECT first 1 numcte INTO sNumcte FROM bdinteg:"informix".si_telefonos 
		WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel = 'A' AND verificado='V';
	
	EXECUTE PROCEDURE bdinteg:cons_tipo_cte('001',sNumcte)
		   INTO CodRet, sTipoCte, sSecuencia;
	
	SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';

/*	RQM 10 1768 Mantto tels
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
	WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel IN ('A','C') AND verificado='V'	AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));

	IF iCantRep>=1 THEN
		LET sCodRet='288';
	END IF;
	
*/
	--Se identifica si el cliente es titular, aplica la regla de los 30 dÃ­as, de lo contrario puede registrar el celular del prospecto
	IF sTipoCte = '1' THEN
		SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos 
		WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel = 'A' AND verificado='V'	AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));
		
		IF iCantRep>=1 THEN
			LET sCodRet='288';
		END IF;
	END IF;

	
RETURN sCodRet, iCantRep;

END
END PROCEDURE;