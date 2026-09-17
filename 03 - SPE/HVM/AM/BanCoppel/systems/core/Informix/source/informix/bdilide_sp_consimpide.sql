CREATE PROCEDURE "informix".sp_consimpide(pNumeroCliente CHAR(20), pPeriodo CHAR(6))
--*************************************************
    --Realizó: Aymme Osuna
    --Actividad: Consulta importe acumulado, importe excedente, importe recaudado
    --Solicitó: Aymme Osuna
    --Fecha: 15-08-2008
--*************************************************
RETURNING CHAR(3), --Codigo de Retorno
                         MONEY(10,2), --Impuesto grabado
                         MONEY(10,2), --Impuesto a recaudar
                         MONEY(10,2), --Impuesto recaudado
                         MONEY(10,2), --Impuesto Pendiente
                         MONEY(10,2); --Impuesto acumulado

--Declaración de Variables
DEFINE vcCodRet    CHAR(3);
DEFINE vmImpGrabado MONEY(10,2);
DEFINE vmImpArecaudar MONEY(10,2);
DEFINE vmImpRecaudado MONEY(10,2);
DEFINE vmImpPendiente MONEY(10,2);
DEFINE vmImpAcumulado MONEY(10,2);
DEFINE  vsqlerr     INTEGER;

--Inicialización de Variables
LET vcCodRet = "000";
LET vmImpGrabado = 0.00;
LET vmImpArecaudar = 0.00;
LET vmImpRecaudado = 0.00;
LET vmImpPendiente = 0.00;
LET vmImpAcumulado = 0.00;
LET  vsqlerr        = 0;

BEGIN

       ON EXCEPTION  SET vsqlerr
                 IF vsqlerr <> 0  THEN
                         LET  vcCodRet  = vsqlerr;
                        RETURN vcCodRet, vmImpGrabado, vmImpArecaudar, vmImpRecaudado, vmImpPendiente, vmImpAcumulado;
                 END IF;
         END  EXCEPTION;

            --SET DEBUG FILE TO "/tmp/sp_ConsImpIDE.out";
            --TRACE ON;

    --Validación de  variables de entrada
    IF pNumeroCliente IS NULL OR pNumeroCliente = "" THEN
        LET vcCodRet = "100"; --Parametro Invalido
        RETURN vcCodRet, vmImpGrabado, vmImpArecaudar, vmImpRecaudado, vmImpPendiente, vmImpAcumulado;
    ELIF pPeriodo IS NULL OR pPeriodo = "" THEN
        LET vcCodRet = "100"; --Parametro Invalido
        RETURN vcCodRet, vmImpGrabado, vmImpArecaudar, vmImpRecaudado, vmImpPendiente, vmImpAcumulado;
    END IF;
    --Extracción de Información
    IF EXISTS(SELECT rfc FROM bdilide:sl_retlide WHERE num_cte = pNumeroCliente AND aniomes = pPeriodo) THEN
        SELECT imp_gravado, imp_arecaudar,imp_recaudado,(imp_arecaudar-imp_recaudado), imp_acumulado
        INTO vmImpGrabado, vmImpArecaudar, vmImpRecaudado, vmImpPendiente, vmImpAcumulado
        FROM bdilide:sl_retlide
         WHERE num_cte = pNumeroCliente AND aniomes = pPeriodo;
    ELSE
        LET vcCodRet = "200"; --Numero de Cliente no existe para el mes consultado
         RETURN vcCodRet, vmImpGrabado, vmImpArecaudar, vmImpRecaudado, vmImpPendiente, vmImpAcumulado;
    END IF;
     RETURN vcCodRet, vmImpGrabado, vmImpArecaudar, vmImpRecaudado, vmImpPendiente, vmImpAcumulado;
END;
END PROCEDURE;