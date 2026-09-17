CREATE PROCEDURE "informix".sp_consultarmensajespagosprogramados(p_cve_mensaje CHAR(8), p_cod_ret CHAR(6))
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(250); ---descripcion
	 
    
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_cod_ret            CHAR(6);
	DEFINE v_descripcion        CHAR(250);
	
	--- Declaraciones
    
    LET iSqlErr              = 0;
    LET iSamErr              = 0;
    LET vDesErr              = "";
	LET v_cod_ret            = '000000';
	LET v_descripcion        ='';
BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                
		LET v_cod_ret = iSqlErr;
                LET v_descripcion ="ERROR DE SQL";
        END IF;
        RETURN v_cod_ret,v_descripcion;
    END EXCEPTION;
	
	SELECT desc_mensaje
	INTO v_descripcion
    FROM bdiprog: pp_mensajes
    WHERE cve_mensaje = p_cve_mensaje
    AND cod_ret = p_cod_ret;
	
    if v_descripcion is null OR v_descripcion="" then
        LET v_descripcion="No se encontro la descripcion del mensaje de Error";
        RETURN v_cod_ret,v_descripcion;
    else
        RETURN v_cod_ret,v_descripcion;
    end if;
END;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel Rodriguez',
'CREACION: Se crea para obtener y regresar un mensaje de la tabla pp_mensajes a partir de los parametros recibidos',
'EQUIPO DE TRABAJO: Incidencias',
'EJECUTADO O LLAMADO POR: PLPAGPRO.EXE',
'FECHA : 04/NOV/2009',
'VERSION: 20091104.1636',
'BD    : bdiprog';

CREATE PROCEDURE "informix".sp_validatdc( p_sCuenta CHAR(20))
    RETURNING CHAR(6), CHAR(60);

--Declaracion de variables

DEFINE v_sCodRet CHAR(6);
DEFINE v_sMensajeRet CHAR(60);
DEFINE intcodret        INTEGER;

DEFINE v_iLongCuenta INTEGER;
DEFINE v_iCuenta INTEGER;
DEFINE v_sFinCiclo CHAR(1);
DEFINE v_sValor CHAR(1);
DEFINE v_iTotal INTEGER;
DEFINE v_iDigito INTEGER;
DEFINE v_iDivision INTEGER;
DEFINE v_sBandera CHAR(1);

-- *************************************************
-- Realizo: Walber Castro                    --*
-- Actividad: Validar Tarjetas de Crédito       --*
-- Solicito: Mauricio León                      --*
--Fecha: 16/JUNIO/2010                        --*
--SET DEBUG FILE TO "/home/sysifx/walber/sp_validatdc.out";
--TRACE ON;                                     --*
-- *************************************************

--Asignacion de variables
LET v_sCodRet = '000';
LET v_sMensajeRet = '';
LET v_iCuenta = LENGTH(p_sCuenta);
LET v_iLongCuenta = 1; 
LET v_sFinCiclo = 'T';
LET v_sValor = '';
LET v_iTotal = 0;
LET v_iDigito = 0;
LET v_iDivision = 0;
LET v_sBandera = '';

BEGIN
        ON EXCEPTION SET intcodret
            IF intcodret <> 0 THEN
                LET v_sCodRet  = intcodret;
                RETURN v_sCodRet, v_sMensajeRet;
            END IF;
        END EXCEPTION;

	--Se valida que la cuenta no este en blanco o en nulo

	IF (NVL(p_sCuenta,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '147';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;	

	--Se valida el tamaño de la cuenta

	IF (v_iCuenta <> 15 AND v_iCuenta <> 16) THEN
            SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes where cve_mensaje = '240';            
            RETURN v_sCodRet, v_sMensajeRet;
	END IF;

	WHILE (v_iLongCuenta <= v_iCuenta AND v_sFinCiclo = 'T') 
		LET v_sValor = SUBSTR(p_sCuenta,v_iLongCuenta,1);
		IF ((v_sValor >= '0') AND (v_sValor <= '9')) THEN
			LET v_sBandera = 'A';
                        LET v_iDigito = v_sValor;                        
                        LET v_iDivision = mod (v_iLongCuenta , 2);                        
                        IF ( v_iDivision = 1 ) THEN
                            LET v_iDigito = v_iDigito * 2;
                            IF (v_iDigito > 9) THEN
                                LET v_iDigito = v_iDigito - 9;
                            END IF;
                            LET v_iTotal = v_iTotal +  v_iDigito;
                        ELSE
                            LET v_iTotal = v_iTotal +  v_iDigito;
                        END IF;
		ELSE
			LET v_sBandera = 'B';
			LET v_sFinCiclo = 'F';
		END IF;
		LET v_iLongCuenta = ( v_iLongCuenta + 1);
	END WHILE;
	IF (v_sBandera = 'B') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '206';
		RETURN v_sCodRet, v_sMensajeRet;
	END IF;
        LET v_iTotal = mod (v_iTotal , 10);        
        IF (v_iTotal <> 0) THEN
            SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:pp_mensajes WHERE cve_mensaje = '17';
        END IF;
	
        RETURN v_sCodRet, v_sMensajeRet;
END
END PROCEDURE;