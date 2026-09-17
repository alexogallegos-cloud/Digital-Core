CREATE PROCEDURE "informix".pba_cancelacion()
RETURNING CHAR(30); -- folio;

    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vSqlErr          INTEGER;
    DEFINE vIsamErr         INTEGER;
    DEFINE wempresa         CHAR(3);
    DEFINE whora            CHAR(15);
    DEFINE wserial_folio    INTEGER;
    DEFINE wfolio_suc       CHAR(30);
    DEFINE wcuenta          CHAR(20);
    DEFINE wnum_tarjeta     CHAR(16);
    DEFINE wmaxsec          SMALLINT;
    DEFINE wsucursal        CHAR(4);
    DEFINE wusuario         CHAR(8);
    DEFINE wtransacc        CHAR(4);
    DEFINE wtran_suc        CHAR(4);
    DEFINE wdivisa          CHAR(2);
    DEFINE wexiste_mov      INTEGER;
	DEFINE wimporte         DECIMAL(12,2);
	DEFINE cVarDataErr      CHAR(100);
	DEFINE vtimestamp       LVARCHAR(20);
	DEFINE wtimestamp       CHAR(20);
	DEFINE wcomision 		DECIMAL(14,2);
		--FIRMA
	DEFINE wcadena_val      CHAR (1000);
	DEFINE codretfirma      INTEGER;
	DEFINE wvchrcodretcodi  CHAR(5);
	DEFINE pvchrconceptopago CHAR(210);
	DEFINE pvchrtpoctaord	CHAR(2);
	DEFINE pintBancoDest    CHAR(5);
	DEFINE pintTipoCtaBenef CHAR (2);
	DEFINE pvchrNombreBenef CHAR (20);
	DEFINE pvchrcuentaord	CHAR(20);
	DEFINE pvchrNombreOrd   CHAR (20);
	DEFINE pvchrCelOrd      CHAR (10);
	DEFINE pvchrCelBen      CHAR (20);
	DEFINE pvchridmjc	    CHAR (20);
	DEFINE vcomision        CHAR(7);
	DEFINE pcharfirma CHAR(512);

	LET wcadena_val = '';
	LET codretfirma = 0;

    LET vCodRet1      = "000";
    LET vCodRet2      = "000";
    LET vSqlErr       = 0;
    LET vIsamErr      = 0;
    LET wempresa      = '001';
    LET whora         = '';
    LET wserial_folio = 0;
    LET wfolio_suc    = '0';
    LET wcuenta       = '';
    LET wnum_tarjeta  = '';
    LET wmaxsec       = 0;
    LET wsucursal     = '9201';
    LET wusuario      = 'tranSPEI';
    LET wtransacc     = '0276';
    LET wtran_suc     = '0000';
    LET wdivisa       = '01';
    LET wexiste_mov   = 0;

     SET DEBUG FILE TO "/resplogifx/conciliachq/spei/pba_cancelacion.out";
     TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/pba_cancelacion.err";
        TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--GENERA CADENA A VALIDAR
	LET wcadena_val = '|50112347TRANSBPI19485477|137613104526652347|100.00|1948547|1|||0|0||40012|0|0.00||||1652106260661|';
--	LET pcharfirma = 'Pyu0fUcYQq00Vn/QDwiKO29uQDUc5CvVLz9tNnxGuXGrQpIpa3L6e2QrR4WMK3leHtYy8HPEYGdHsVIa8CtHwXMf841ONBu64ZdWi4FF7ltio0r3c07Pz0n0LayPcWL7Kfog3KK8VrMkP4juGyjLCvCRKq4HtzTJdrnt60gLBT7NJ4xgR95E9YOzYR1wSaZHQc59FhXP0UOIFYxQJVbXf8e2PbrOu+Ezmb0CrkV2v+uWkCqb0tc5qKMfP5F1Zwk1JDU2zZRy2gvsnKWG9AbAJ3SeJUNygpyhHbDSKLQvgLHiiyYilt3kBuEhzXa1KkExP4WVdNSxQOP1ytSBPu5DcQ==';

	LET pcharfirma = ' ';

	EXECUTE FUNCTION "informix".syn_sign(TRIM(wcadena_val), pcharfirma, 21)
	INTO codretfirma;

   END;

    RETURN wfolio_suc;

END PROCEDURE;