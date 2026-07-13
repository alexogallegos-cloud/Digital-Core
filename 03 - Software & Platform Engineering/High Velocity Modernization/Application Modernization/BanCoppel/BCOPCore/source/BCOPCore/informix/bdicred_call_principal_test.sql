CREATE PROCEDURE "informix".call_principal_test(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT,
                           p_Monto                  MONEY(14,2),
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  CHAR(16),
                           p_Transacc               char(5))
                           
RETURNING CHAR(5) AS CodRet,     -- Codigo de Retorno
             MONEY(14,2) AS g_Remanente, -- Remanente
             MONEY(14,2) AS g_IntMoraCob, -- Interes Moratorio Cobrado
             MONEY(14,2) AS g_IntVencCob, -- Interes Vencido Cobrado
             MONEY(14,2) AS g_CapVencCob, -- Capital Vencido Cobrado
             MONEY(14,2) AS g_IntVigCob, -- Interes Vigente Cobrado
             MONEY(14,2) AS g_CapVigCob, -- Capital Vigente Cobrado
             MONEY(14,2) AS g_Impuesto, -- Impuesto Cobrado
             MONEY(14,2) AS g_Comision, -- Comisiones Cobradas
             MONEY(14,2) AS g_Seguro;   -- Seguro Cobrado

    DEFINE CodRet                CHAR(5);
    DEFINE GLOBAL  g_Remanente      MONEY(14,2) DEFAULT 0;
    DEFINE GLOBAL  g_IntMoraCob     MONEY(14,2) DEFAULT 0;
    DEFINE GLOBAL  g_IntVencCob     MONEY(14,2) DEFAULT 0;
    DEFINE GLOBAL  g_CapVencCob     MONEY(14,2) DEFAULT 0;
    DEFINE GLOBAL  g_IntVigCob      MONEY(14,2) DEFAULT 0;
    DEFINE GLOBAL  g_CapVigCob      MONEY(14,2) DEFAULT 0;
    DEFINE GLOBAL  g_Impuesto       MONEY(14,2) DEFAULT 0;
    DEFINE GLOBAL  g_Comision       MONEY(14,2) DEFAULT 0;
    DEFINE GLOBAL  g_Seguro         MONEY(14,2) DEFAULT 0;
    
    
    LET CodRet            = "00000";
    LET g_Remanente        = 0;
    LET g_IntMoraCob    = 0;
    LET g_IntVencCob     = 0;
    LET g_CapVencCob     = 0;
    LET g_IntVigCob        = 0;
    LET g_CapVigCob        = 0;
    LET g_Impuesto        = 0;
    LET g_Comision        = 0;
    LET g_Seguro        = 0;
    
BEGIN
    
    EXECUTE PROCEDURE  "informix".principal(p_Empresa,p_NumCredito,p_TpPago,p_Monto,p_Usuario,p_Sucursal,p_Folio,p_Transacc)
    INTO CodRet,g_Remanente,g_IntMoraCob,g_IntVencCob,g_CapVencCob,g_IntVigCob,g_CapVigCob,g_Impuesto,g_Comision,g_Seguro;
    
    RETURN CodRet,g_Remanente,g_IntMoraCob,g_IntVencCob,g_CapVencCob,g_IntVigCob,g_CapVigCob,g_Impuesto,g_Comision,g_Seguro WITH RESUME;
    
end;
END PROCEDURE;