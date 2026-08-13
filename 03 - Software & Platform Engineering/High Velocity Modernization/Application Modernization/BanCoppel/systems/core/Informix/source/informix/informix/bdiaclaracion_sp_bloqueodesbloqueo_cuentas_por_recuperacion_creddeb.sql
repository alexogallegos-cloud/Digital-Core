CREATE PROCEDURE "informix".sp_bloqueodesbloqueo_cuentas_por_recuperacion_creddeb(pNumCuenta CHAR(20), pTipoProducto CHAR(2), pAccion CHAR(2) ,pUsuario INTEGER)

    RETURNING CHAR(5) AS codeRet,
              CHAR(30)  AS mensajeRet;

DEFINE vResultado_saldo_congelado  MONEY;
DEFINE eEmpresa CHAR(5);
DEFINE codeRet CHAR(5);
DEFINE mensajeRet CHAR(30);

LET vResultado_saldo_congelado = 0;
LET eEmpresa = '001';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  --SET DEBUG FILE TO " /resplogifx/repaclaraciones/RQM732-1/sp_desbloqueo_cuentas_por_recuperacion_credDeb"||TRIM(pNumCuenta)||".out"; --> TRACE DESDE APP
  --TRACE ON;

BEGIN

--ES DÉBITO
IF pTipoProducto = '2' THEN
IF pAccion = 'D' THEN
    --DESBLOQUEA LA CUENTA DE ACUERDO AL SALDO CONGELADO
    SELECT sdo_cong INTO vResultado_saldo_congelado
    FROM bdicheq:"informix".sc_maechq
    WHERE cuenta = pNumCuenta;
    IF (vResultado_saldo_congelado > 0) THEN
        -- DESBLOQUEA POR MONTO
        CALL bdicheq:"informix".bloqueo_cta(eEmpresa,pNumCuenta, vResultado_saldo_congelado, '00', 0, today, '0', '4469', '07', 'A', '09', 'P' ) RETURNING codeRet,mensajeRet;
        RETURN codeRet,mensajeRet;
    ELIF (vResultado_saldo_congelado == 0) THEN
        -- DESBLOQUEA POR 0
        CALL bdicheq:"informix".bloqueo_cta(eEmpresa,pNumCuenta,0,'00',0,today,'0','4469','07','A','09','P' ) RETURNING codeRet,mensajeRet;
        RETURN codeRet,mensajeRet;
    END IF;
ELIF pAccion = 'B' THEN
    SELECT sdo_cong INTO vResultado_saldo_congelado
    FROM bdicheq:"informix".sc_maechq
    WHERE cuenta = pNumCuenta;
    --BLOQUEA LA CUENTA
    IF (vResultado_saldo_congelado > 0) THEN
        CALL bdicheq:"informix".bloqueo_cta(eEmpresa,pNumCuenta, vResultado_saldo_congelado, '56', 3, today, '0', '4469', '07', 'A', '09', 'P' ) RETURNING codeRet,mensajeRet;
        RETURN codeRet,mensajeRet;
    ELIF (vResultado_saldo_congelado == 0) THEN
        CALL bdicheq:"informix".bloqueo_cta(eEmpresa,pNumCuenta,0,'56',3,today,'0','4469','07','A','09','P' ) RETURNING codeRet,mensajeRet;
        RETURN codeRet,mensajeRet;
    END IF;
END IF;
--ES CRÉDITO
ELIF pTipoProducto = '1' THEN
IF pAccion = 'D' THEN
    --DESBLOQUEO CUENTA CREDITO
    CALL bdicred:"informix".sp_desbloqueocuenta (eEmpresa,pNumCuenta,'0','1') RETURNING codeRet, mensajeRet;
    RETURN codeRet,mensajeRet;
ELIF pAccion = 'B' THEN
    --BLOQUEA LA CUENTA
    CALL bdicred:"informix".sp_bloqueocuenta(eEmpresa,pNumCuenta,'3','10',pUsuario,'1') RETURNING codeRet, mensajeRet;
    RETURN codeRet,mensajeRet;
END IF;
END IF;
END;
END PROCEDURE;