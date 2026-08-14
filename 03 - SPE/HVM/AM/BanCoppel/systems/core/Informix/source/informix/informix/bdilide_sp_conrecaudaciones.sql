CREATE PROCEDURE "informix".sp_conrecaudaciones(pNumCte CHAR(20), pPeriodo CHAR(6), pTipo CHAR(2))
RETURNING
    CHAR(5), DATE, CHAR(20), CHAR(6), MONEY(10,2);
--Declaración de Variables
DEFINE cCodRet  CHAR(5);
DEFINE dFecha   DATE;
DEFINE cNumCta  CHAR(20);
DEFINE cPeriodo     CHAR(6);
DEFINE mImpuestoRec MONEY(10,2);

--Inicializacion de Variables
LET cCodRet = "000";
LET dFecha = "";
LET cNumCta = "";
LET cPeriodo = "";
LET mImpuestoRec = 0.00;
--Validacion de Parametros
IF pNumCte = "" OR pNumCte IS NULL THEN
    LET  cCodRet = "100";
    RETURN cCodRet, dFecha, cNumCta, cPeriodo, mImpuestoRec;
END IF;
IF pPeriodo = "" OR pPeriodo IS NULL THEN
    LET cCodRet = "200";
    RETURN cCodRet, dFecha, cNumCta, cPeriodo, mImpuestoRec;
END IF;

BEGIN
    IF pTipo = "01" THEN
            FOREACH
                SELECT aniomes, cuenta_ret, fecha_ret, imp_recaudado INTO cPeriodo, cNumCta, dFecha, mImpuestoRec
                FROM bdilide:sl_detlide
                WHERE num_cte = pNumCte AND aniomes = pPeriodo

                RETURN cCodRet, dFecha, cNumCta, cPeriodo, mImpuestoRec WITH RESUME;
            END FOREACH;
    ELIF pTipo = "02" THEN
                IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sl_movgrid') THEN
                        DELETE sl_movgrid;
                ELSE
                        CREATE TABLE sl_movgrid(fecha DATE, cuenta CHAR(20), sucursal CHAR(4), importe MONEY(10,2));
                END IF
                RETURN cCodRet, dFecha, cNumCta, cPeriodo, mImpuestoRec;
    END IF;

END;
END PROCEDURE;