CREATE PROCEDURE "informix".sp_adn_obtenerctanomina(pEmpresa CHAR(3), pCuenta  CHAR(20), pFrecuencia INTEGER,pMeses INTEGER )
RETURNING CHAR(5)  AS Codigo,
          SMALLINT AS Valida;

DEFINE iSqlErr      INTEGER;
DEFINE cCodRet      CHAR(5);
DEFINE cFechaHoy    DATE;
DEFINE cFechaIni    DATE;
DEFINE cProduct		CHAR(4);
DEFINE cCuenta		CHAR(20);
DEFINE dDiaprimero	DATE;
DEFINE dDiaUltimo	DATE;
DEFINE  cMes 		CHAR(2);
DEFINE cAnio		CHAR(4);
DEFINE cCodRet2 	CHAR(6);
DEFINE i			INTEGER;
DEFINE iCont		INTEGER;
DEFINE iCuentas		INTEGER;
DEFINE iCuentas_old INTEGER;
DEFINE vi_mesprom   INTEGER;
DEFINE iBandera   INTEGER;

LET iSqlErr         = 0;
LET cCodRet         = "00000";
LET  cFechaHoy   	= '';
LET cFechaIni   	= '';
LET cProduct		= '';
LET cCuenta			= '';
LET cCodRet2 		= '000000';
LET dDiaprimero		= '';
LET dDiaUltimo		= '';
LET cMes 			= 0;
LET cAnio			= 0;
LET i				= 1;
LET iCont			= 0;
LET iCuentas		= 0;
LET iCuentas_old    = 0;
LET vi_mesprom      = 0;
LET iBandera= 0;

BEGIN

ON EXCEPTION SET iSqlErr
   LET cCodRet= iSqlErr;
   RETURN cCodRet,  '' ;
END EXCEPTION;

--  SET DEBUG FILE TO "/tmp/sp_obtenerctanomina.out";
--  TRACE ON;

IF NVL(pEmpresa,'') = '' OR NVL(pCuenta,'') = '' OR NVL(pFrecuencia,0) = 0  THEN
    LET cCodRet     = "00001";  --Faltan parametros de entrada
    RETURN cCodRet,  0 ;
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy
  INTO cFechaHoy
  FROM bdicred:"informix".sd_fechas
 WHERE empresa = pEmpresa;		

		
    FOR i = 1 TO pMeses   
	
			CALL bdicred:"informix".monthadd(cFechaHoy,- i) RETURNING cFechaIni;

			LET cMes = MONTH(cFechaIni);
			LET cAnio=  YEAR(cFechaIni);		
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_diaprimeroultimomesanio (cMes, cAnio)
			             INTO cCodRet2 , dDiaprimero, dDiaUltimo; 	

			IF cCodRet2 <> "000000" THEN
				LET cCodRet     = "00002";  -- Error de ejecucion
				RETURN cCodRet,'';
			END IF;

            --FMV 19JUL11 Se cambia el estatus cancelad = N pos <> S 
            --Valida si tiene movimientos de depositos en el maestro de movimiento historico
            SELECT COUNT(cuenta)
              INTO iCuentas
              FROM bdicheq:"informix".sc_movhis mov
        INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
             WHERE cuenta = pCuenta 
               AND cancelad <> 'S'
               AND fech_alt BETWEEN dDiaprimero AND dDiaUltimo;

               IF NVL(iCuentas,0) < pFrecuencia THEN
                        SELECT COUNT(cuenta)
                          INTO iCuentas_old
                          FROM bdicheq:"informix".sc_movhis_old mov
                    INNER JOIN bdicred:"informix".sd_transvalprod tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
                         WHERE cuenta = pCuenta 
                           AND cancelad <> 'S' 
                           AND fech_alt BETWEEN dDiaprimero AND dDiaUltimo;

                           LET iCuentas = NVL(iCuentas,0) + NVL(iCuentas_old,0);                      

               END IF;
			   IF iCuentas >= pFrecuencia THEN 
				LET iBandera= 1;
				EXIT FOR;
			   END IF;
			   
    END FOR;   

    RETURN cCodRet,  iCuentas ;
END
END PROCEDURE
