CREATE PROCEDURE "informix".sp_consultafirmantescta(pCuenta CHAR(20))
RETURNING  CHAR(5),CHAR(20),CHAR(20),INTEGER,CHAR(110);

DEFINE cCodRet 			CHAR(5);
DEFINE iSqlErr			INTEGER;
DEFINE cCuenta 			CHAR(20);
DEFINE cNum_Cte			CHAR(20);
DEFINE iSecuencia		INTEGER;
DEFINE cNombre 			CHAR(110);

LET cCodRet 			= '00000';
LET iSqlErr				= 0;
LET cCuenta 			= '';
LET cNum_Cte			= '';
LET iSecuencia		    = 0;
LET cNombre 			= '';


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet, NVL(cCuenta,0), NVL(cNum_Cte,0), NVL(iSecuencia,0), NVL(cNombre,0);
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_ConsultaFirmantesCta.out";
	--TRACE ON;

	set isolation to dirty read;

	IF pCuenta <> '' THEN
		FOREACH WITH HOLD
			SELECT m.cuenta, f.numcte, f.secuencia, TRIM(t.nombre1)||' '||TRIM(t.nombre2)||' '||TRIM(t.apell_paterno)||'  '||TRIM(t.apell_materno)AS nombre
			INTO cCuenta, cNum_Cte, iSecuencia, cNombre
			FROM bdicheq:sc_maechq m,  bdicheq:sc_firmantes f,  bdinteg:si_cliente t
			WHERE m.empresa = '001'
			AND m.cuenta = pCuenta
			AND m.cuenta = f.cuenta
			AND f.numcte = t.numcte

			RETURN cCodRet, NVL(cCuenta,0), NVL(cNum_Cte,0), NVL(iSecuencia,0), NVL(cNombre,0) WITH RESUME;
		END FOREACH;
	ELSE
		--Falta parametro
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cCuenta,0), NVL(cNum_Cte,0), NVL(iSecuencia,0), NVL(cNombre,0);
	END IF;
END
END PROCEDURE
Document
'DESCRIPCION: Procedimiento que consulta los firmantes relacionados con una cuenta',
'AUTOR: César Valdéz Figueroa',
'FECHA: 23 de Febrero de 2010',
'VERSION: 20100223.1830',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_actualizasaldos_maenoc()
    RETURNING CHAR(5);
    
    DEFINE saldo_mns2010                        DECIMAL(14,2);
    DEFINE vcodret                              CHAR(5);
    DEFINE cuenta_maenoc                        CHAR(20);
    DEFINE anio2010                             CHAR (4);

    BEGIN

   	--	SET DEBUG FILE TO "/ids10_1uc5/tmp/sp_actualizasaldos_maenoc.err";
   	--	TRACE ON;

	LET anio2010 = '2010';
		
		FOREACH
			select a.cuenta, a.capvigprom12
   			into cuenta_maenoc, saldo_mns2010
                	from bdicheq:sc_sdomensualc2010 a, bdicheq:sc_maenoc b
                	where
                	a.anio = anio2010 and
                	a.cuenta = b.cuenta and a.cuenta like '19%'

               		update sc_maenoc
			set sdo_prom_mesant = saldo_mns2010
			where
                	cuenta = cuenta_maenoc;
									
 		END FOREACH;
 			
    END;

END PROCEDURE;