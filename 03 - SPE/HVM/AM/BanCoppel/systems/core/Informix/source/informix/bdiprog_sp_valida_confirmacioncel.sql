CREATE PROCEDURE "informix".sp_valida_confirmacioncel(pNumCte CHAR(20),pCelular CHAR (13))
--RETORNOS
RETURNING 
CHAR(5) 	AS CodRet;


--DECLARACIONES DE VARIABLES
DEFINE cCodRet        		CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE iCount				INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet 				= '00000';
LET iCount					=0;
LET iSqlErr					=0;

--SET DEBUG FILE TO '/respaldosbd/raulpacheco/sp_valida_confirmacioncel.out'; 
--TRACE ON;

BEGIN 

	ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN  TRIM(NVL(cCodRet,""));
			END IF;
	END EXCEPTION;
	
		
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	--Se validan parametros
	IF TRIM(NVL(pNumCte,"")) = "" OR TRIM(NVL(pCelular,"")) = "" THEN
		LET cCodRet =  '00001';		RETURN TRIM(NVL(cCodRet,""));
	END IF;	
	
	SELECT COUNT(*) INTO iCount FROM BDINTEG:"informix".si_bitsmstels WHERE numcte = pNumCte 
	AND telefono = pCelular 
	AND date(fecha)=date(current)
	AND teclea_ejecut IS NOT NULL;

    IF iCount > 0 THEN
		LET cCodRet =  '00003';		RETURN TRIM(NVL(cCodRet,""));
    END IF;

	--Se verifica  que el telefono se encuentre confirmado
	SELECT COUNT(*) INTO iCount FROM BDINTEG:"informix".si_telefonos
	WHERE numcte= TRIM(pNumCte)
	AND telefono = TRIM(pCelular) AND verificado = 'V' AND status_tel = 'A' AND NVL(fecha_actualiza,'1900-01-01') <> '1900-01-01' AND tipo_tel = 2;
	
	IF iCount = 0 THEN
		LET cCodRet =  '00002';	END IF;
	
	RETURN TRIM(NVL(cCodRet,""));
END;
		
END PROCEDURE
DOCUMENT
'AUTOR: 96152877 - Jose Raul Pacheco Ortiz  ',
'FOLIO: 184',
'DESCRIPCION: Valida que el celular ya este confirmado .',
'FECHA: 08/02/2017',
'BD:  BDIPROG',
'FOLIO: 237',
'MODIFICO: Pedro Portugal',
'FECHA: 23/05/2017',                                                  
'DESCRIPCION: Se modifica para obtener el codigo de confirmacion SMS';

CREATE PROCEDURE "informix".sp_consultacuentasdestinoservicios2(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT, p_CveBanco CHAR(3))
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(20), ---cuenta
	 CHAR(100), ---nombre
	 CHAR(50), ---banco
	 CHAR(2), ---compaÃ±ia celular
	 CHAR(10), ---numero celular
	 CHAR(100), ---correo electronico
	 CHAR(2), ---cve cuenta
     CHAR(20), ---desc cuenta
     CHAR(13); ---rfc

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_CvePago			CHAR(2);
	DEFINE v_CtaDestino			CHAR(20);
	DEFINE v_Nombre				CHAR(100);
	DEFINE v_Banco				CHAR(50);
	DEFINE v_CompCel			CHAR(2);
	DEFINE v_NumCel				CHAR(10);
	DEFINE v_CorreoE			CHAR(100);
	DEFINE v_CveCuenta			CHAR(2);
	DEFINE v_ContReg			SMALLINT;
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;

	LET v_CodDesc			    = "";
	LET v_CvePago				= "";
	LET v_CtaDestino			= "";
	LET v_Nombre				= "";
	LET v_Banco					= "";
	LET v_CompCel				= "";
	LET v_NumCel				= "";
	LET v_CorreoE				= "";
	LET v_CveCuenta				= "";
	LET v_ContReg			 	= 0;
	LET v_DescCta				= "";
    LET v_Rfc                   = "";
	LET v_Canal					= "";
	
	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_ConsultaCuentasDestinoServicios2.out";
	--TRACE ON;

	SELECT cod_ret INTO v_cod_ret FROM  BDIPROG:"informix".PP_MENSAJES WHERE cve_mensaje = "00";

	SELECT banco|| "  " ||descripcion
	INTO v_Banco
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";
    
    IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN
        IF EXISTS (SELECT ct.cuenta FROM bdiprog:"informix".pp_ctasterceros ct, pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta)  THEN
            FOREACH
                SELECT ct.cuenta, ct.nombre, ct.cve_banco, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert
                INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert
                FROM bdiprog:"informix".pp_ctasterceros ct, pp_cuentapago cp
                WHERE ct.num_cte = p_NumCte
                AND ct.cve_banco = p_CveBanco
                AND ct.cve_cuenta = cp.cve_cuenta
                AND cp.cve_pago = p_CvePago

                LET v_ContReg = v_ContReg + 1;

                IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                    CONTINUE FOREACH;
                END IF;

                RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc WITH RESUME;
            END FOREACH;
        ELSE
            SELECT cod_ret INTO v_cod_ret FROM  BDIPROG:"informix".PP_MENSAJES WHERE cve_mensaje = "13";
            RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
        END IF
    ELSE
        SELECT cod_ret INTO v_cod_ret FROM  BDIPROG:"informix".PP_MENSAJES	WHERE cve_mensaje = "01";
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END IF
    
END;
--##############################################################################
--## Procedimiento   : sp_consultacuentasdestinoservicios2
--## Version         : 1.0
--## Creado por      : Pedro Portugal
--## Fecha creacion  : Mayo de 2017
--## Descripcion     : Consulta las cuentas de servicio por la clave de banco.
--##############################################################################
END PROCEDURE;