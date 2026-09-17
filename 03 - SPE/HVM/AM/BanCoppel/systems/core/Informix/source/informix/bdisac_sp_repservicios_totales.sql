CREATE PROCEDURE "informix".sp_repservicios_totales (dFechaI char(10), dFechaF char(10))
    RETURNING CHAR(5),CHAR(50),INTEGER,MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2);
    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE cNomConvenio CHAR(50);
    DEFINE iNumPagos    INTEGER;
    DEFINE mImportePago  MONEY(16,2);
    DEFINE mIVAComisionConvenio MONEY(16,2);
    DEFINE mImpComisionCte     MONEY(16,2);
    DEFINE mImpComisionConvenio   MONEY(16,2);
    DEFINE mIVAComisionCte   MONEY(16,2);
    DEFINE cNumcategoria CHAR(5);
    DEFINE cNumconvenio CHAR(5);
    DEFINE Importe_total   MONEY(16,2);
    -- Inicializa variables
    LET cCodRet = "00000";
    LET iSql_err = 0;
    LET cNomConvenio = "";
    LET iNumPagos = 0;
    LET mImportePago = 0;
    LET mIVAComisionConvenio = 0;
    LET mImpComisionCte = 0;
    LET mImpComisionConvenio = 0;
    LET mIVAComisionCte = 0;
    LET Importe_total = 0;
    LET cNumcategoria = "";
    LET cNumconvenio = "";

     --SET DEBUG FILE TO "/home/informix/VHSM/sp_repservicios_totales.out";
     --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet, cNomConvenio,iNumPagos, mImportePago, mImpComisionConvenio,mIVAComisionConvenio, mImpComisionCte,mIVAComisionCte,Importe_total;
            END IF;
        END EXCEPTION;

FOREACH
      SELECT {+INDEX (bdisac:sac_convenios 103_9)} TRIM(NVL(nomconvenio,'')), TRIM(NVL(numcategoria,'')), TRIM(NVL(numconvenio,''))
      INTO cNomConvenio, cNumcategoria, cNumconvenio
      FROM bdisac:sac_convenios
      where statusconvenio='A'
 
      SET ISOLATION TO DIRTY READ;
      SELECT count(*),nvl(sum(importe_pago),0),nvl(sum(importe_comision_convenio),0),nvl(sum(iva_comision_convenio),0),
      nvl(sum(importe_comision_cte),0)  ,nvl(sum(iva_comision_cte),0)
      INTO iNumPagos, mImportePago, mImpComisionConvenio,mIVAComisionConvenio, mImpComisionCte,mIVAComisionCte
      FROM bdisac:sac_movimientoshistorial
      WHERE fecha_pago::DATE >= dFechaI AND fecha_pago::DATE  <= dFechaF AND numcategoria = cNumcategoria AND
      numconvenio = cNumConvenio AND status_cancelado <> 'S'
      AND flag_confirmacion_central = 1
      AND flag_confirmacion_sucursal = 1;

      let Importe_total=mImportePago-mImpComisionConvenio-mIVAComisionConvenio-mImpComisionCte-mIVAComisionCte;

      RETURN cCodRet, cNomConvenio,iNumPagos, mImportePago, mImpComisionConvenio,mIVAComisionConvenio, mImpComisionCte,mIVAComisionCte,Importe_total WITH RESUME;

END FOREACH;

END;
END PROCEDURE;