CREATE PROCEDURE "informix".sp_cont_norecuperados(pcliente CHAR(9))
   RETURNING CHAR(3), char(9), char(104) , char(10), char(4), char(40), char(1);

DEFINE iSqlErr   INTEGER;
DEFINE cCodRet   CHAR(5);
DEFINE sExiste   CHAR(9);
DEFINE sNumcte   CHAR(9);  
DEFINE sNombre   CHAR(104); 
DEFINE dFecha    CHAR(10); 
DEFINE sSucursal CHAR(4);
DEFINE sNomsuc   CHAR(40); 
DEFINE sTporep   CHAR(1);


LET iSqlErr = 0;
LET cCodRet = '';
LET sExiste='';
LET sNumcte='';
LET sNombre=''; 
LET dFecha='1900-01-01';
LET sSucursal='';
LET sNomsuc=''; 
LET sTporep='';

--SET DEBUG FILE TO '/tmp/anj/sp_autoriza_datos_contacto.sql';
--		TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet, sNumcte, sNombre, dFecha, sSucursal, sNomsuc, sTporep;


   END IF;
END EXCEPTION;
        --let pcliente=pcliente;
        select count(numcte) INTO sExiste  from ss_cont_norecuperados where numcte=pcliente;

        IF sExiste<>'0' THEN
           SELECT numcte, nombre, fechasolicitud::Date, sucursal, nomsucursal, tporeporte 
             INTO sNumcte, sNombre, dFecha, sSucursal, sNomsuc, sTporep
             FROM ss_cont_norecuperados WHERE numcte=pcliente;
           LET cCodRet = '000';
        ELSE
           LET cCodRet = '001';
        END IF   
    
RETURN cCodRet, sNumcte, sNombre, dFecha, sSucursal, sNomsuc, sTporep;

END
END PROCEDURE;