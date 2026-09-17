CREATE PROCEDURE "informix".sp_act_dirmovil(pCP CHAR(5), sNumCte CHAR(9))
RETURNING CHAR(5) AS CodRet, CHAR(3)as sPais, CHAR(2)as sEdo, CHAR(5)as sCiudad, CHAR (5) as sCP, CHAR(6)as sNumCiudad, CHAR(6)as sColonia, CHAR(5)as sMpo;
DEFINE iSqlErr 	    INTEGER;
DEFINE cCodRet 	    CHAR(5);
DEFINE sPais        CHAR(3);
DEFINE sEdo         CHAR(2);
DEFINE sCiudad      CHAR(5);
DEFINE sCP          CHAR(5);
DEFINE sNumCiudad   CHAR(6);
DEFINE sColonia     CHAR(6);
DEFINE sMpo         CHAR(5);
LET cCodRet 	 ='00000';
LET sPais        ='';
LET sEdo         ='';
LET sCiudad      ='';
LET sCP          ='';
LET sNumCiudad   ='';
LET sColonia     ='';
LET sMpo         ='00000';
BEGIN
-- ERRORES DE INFORMIX
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet, sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia, sMpo;
	END IF;
END EXCEPTION;
 FOREACH
    SELECT limit 1 {+INDEX (bdinteg:si_ciudades ix_2363)}{+INDEX (bdinteg:si_catzonas idx_zona)}
           {+INDEX (bdinteg:si_estados inx_estado)} 
    b.pais, b.estado, b.ciudad, codigopostalzona, numerociudad, numerocolonia
    INTO sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia
    FROM bdinteg:si_catzonas a inner join bdinteg:si_ciudades b 
      on a.numerociudad=b.ciudad_coppel and a.numerociudad<>0 
    inner join bdinteg:si_estados c on b.estado=c.estado 
    WHERE codigopostalzona=pCP
 END FOREACH;
IF sEdo='09' THEN
    LET sMpo='00'||sCiudad;
END IF;

RETURN cCodRet, sPais, sEdo, sCiudad, sCP, sNumCiudad, sColonia, sMpo;
END 
END PROCEDURE;