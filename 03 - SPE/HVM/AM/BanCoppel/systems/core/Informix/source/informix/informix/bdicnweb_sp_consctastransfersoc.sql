CREATE PROCEDURE "informix".sp_consctastransfersoc( pNumCte CHAR(20) )
RETURNING CHAR(5), CHAR(20), CHAR(16), CHAR(40), CHAR(18), CHAR(10), CHAR(12), CHAR(10), CHAR(4), CHAR(8), CHAR(10);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE cCuenta      CHAR(104);
    DEFINE cTarjeta     CHAR(16);
    DEFINE cProducto    CHAR(40);
    DEFINE cCtaClabe    CHAR(18);
    DEFINE cFechaAlta   CHAR(10);
    DEFINE cStatusTar   CHAR(10);
    DEFINE cStatusCta   CHAR(12);
    DEFINE cSucursal    CHAR(40);
    DEFINE cEjecutivo   CHAR(8);
    DEFINE cFechaCanc   CHAR(10);
    
    LET cCodRet1    = '';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr	    = 0;
    LET iSamErr     = 0;
    LET cDesErr     = '';
    LET iExiste     = 0;
    LET cCuenta     = '';
    LET cTarjeta    = '';
    LET cProducto   = '';
    LET cCtaClabe   = '';
    LET cFechaAlta  = '';
    LET cStatusTar  = '';
    LET cStatusCta  = '';
    LET cSucursal   = '9747';
    LET cEjecutivo  = '';
    LET cFechaCanc  = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consctastransfersoc.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cCuenta, cTarjeta, cProducto, cCtaClabe, cFechaAlta, cStatusTar, cStatusCta, cSucursal, cEjecutivo, cFechaCanc;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consctastransfersoc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bditransfer:tf_maecte 
     WHERE numcte = pNumCte;
       
    IF iExiste = 0 THEN
        LET cCodRet1 = '104';
        RETURN cCodRet1, cCuenta, cTarjeta, cProducto, cCtaClabe, cFechaAlta, cStatusTar, cStatusCta, cSucursal, cEjecutivo, cFechaCanc;
    END IF;
    
    FOREACH
        SELECT mae.cuenta_tf, tar.num_tarjeta, mae.producto||' '||TRIM(pro.nombre), mae.cta_clabe, 
               mae.fec_alta, tar.status_tar, mae.status_cta, mae.ejecutivo, mae.fec_cancelac
          INTO cCuenta, cTarjeta, cProducto, cCtaClabe, cFechaAlta, cStatusTar, cStatusCta, cEjecutivo, cFechaCanc
          FROM bditransfer:tf_maecte mae
         INNER JOIN bdicheq:sc_producto pro ON ( pro.producto = mae.producto )
          LEFT OUTER JOIN bdicheq:sc_tarjeta tar ON ( tar.empresa = '001' AND tar.cuenta = mae.cuenta_tf AND tar.status_tar = 'A' AND tar.tipo_tarjeta = 'T' )
         WHERE mae.numcte = pNumCte
           
        IF ( cCuenta is null OR cCuenta = '' ) OR 
           ( cStatusCta is null OR cStatusCta = '' OR cStatusCta <> '1' ) THEN 
            CONTINUE FOREACH; 
        END IF;
        
        IF cStatusCta = '1' THEN
            LET cStatusCta = 'ACTIVA';
        ELIF cStatusCta = '2' THEN
            LET cStatusCta = 'PRECANCELADA';
        ELIF cStatusCta = '3' THEN
            LET cStatusCta = 'CANCELADA';
        END IF;
        
        IF cStatusTar = 'A' THEN
            LET cStatusTar = 'ACTIVA';
        ELIF cStatusTar = 'C' THEN
            LET cStatusTar = 'CANCELADA';
        END IF;
        
        IF cTarjeta   is null THEN LET cTarjeta   = ''; END IF;
        IF cProducto  is null THEN LET cProducto  = ''; END IF;
        IF cCtaClabe  is null THEN LET cCtaClabe  = ''; END IF;
        IF cFechaAlta is null THEN LET cFechaAlta = ''; END IF;
        IF cStatusTar is null THEN LET cStatusTar = ''; END IF;
        IF cEjecutivo is null THEN LET cEjecutivo = ''; END IF;
        IF cFechaCanc is null THEN LET cFechaCanc = ''; END IF;
        
        LET cCodRet1   = '000';
        RETURN cCodRet1, cCuenta, cTarjeta, cProducto, cCtaClabe, cFechaAlta, cStatusTar, cStatusCta, cSucursal, cEjecutivo, cFechaCanc WITH RESUME; 
        
        LET cCodRet1    = '';
        LET cCuenta     = '';
        LET cTarjeta    = '';
        LET cProducto   = '';
        LET cCtaClabe   = '';
        LET cFechaAlta  = '';
        LET cStatusTar  = '';
        LET cStatusCta  = '';
        LET cSucursal   = '';
        LET cEjecutivo  = '';
        LET cFechaCanc  = '';
    END FOREACH;
     
    END;
    
END PROCEDURE;