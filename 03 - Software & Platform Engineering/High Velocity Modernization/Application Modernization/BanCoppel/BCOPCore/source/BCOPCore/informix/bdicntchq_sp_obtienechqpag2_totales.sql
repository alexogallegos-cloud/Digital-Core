CREATE PROCEDURE "informix".sp_obtienechqpag2_totales(pFechaInicio CHAR(10), pFechaFin CHAR(10))
RETURNING CHAR(6),
          INTEGER;
          
--DEFINICIONES
DEFINE cCodRet         CHAR(6);
DEFINE sql_err         INTEGER;
DEFINE cCuenta         CHAR(20);
DEFINE cCliente        CHAR(20);
DEFINE cNumFirmas      CHAR(2);
DEFINE cCombFirmas     VARCHAR(120);
DEFINE sSecuencia      SMALLINT;
DEFINE cSucursal       CHAR(4);
DEFINE cNombreSuc      CHAR(40);
DEFINE cNumChq         CHAR(3);
DEFINE mMonto          MONEY(16,2);
DEFINE vFechaHora      VARCHAR(60);
DEFINE cFolioSuc       CHAR(16);
DEFINE cTransacc       CHAR(4);
DEFINE iNumRegistros   INTEGER;

ON EXCEPTION SET sql_err
    LET cCodRet = sql_err;
    RETURN  cCodRet, iNumRegistros;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--INICIALIZACIONES
LET cCodRet            = '000';
LET cNumFirmas         = '0';
LET cCombFirmas        = '';
LET cCuenta            = '';
LET cCliente           = '';
LET cSucursal          = '';
LET cNombreSuc         = '';
LET cNumChq            = '';
LET mMonto             = 0.00;
LET vFechaHora         = '';
LET cFolioSuc          = '';
LET cTransacc          = '';
LET sSecuencia         = '';
LET iNumRegistros	   = 0;

BEGIN
    
    IF TRIM(pFechaInicio) <> '' AND pFechaInicio IS NOT NULL OR TRIM(pFechaFin) <> '' AND pFechaFin IS NOT NULL THEN

		SELECT COUNT(*)
		INTO iNumRegistros
		FROM bdicheq:"informix".sc_contch_hist sh 
		INNER JOIN bdinteg:"informix".si_sucursales sc ON (sc.empresa = sh.empresa AND sc.sucursal = sh.sucursal)
		INNER JOIN bdicheq:"informix".sc_maechq sch ON (sch.empresa = sh.empresa AND sch.cuenta = sh.cuenta)
		WHERE sh.fecha_alta >= pFechaInicio
		  AND sh.fecha_alta <= pFechaFin
		  AND sh.secuencia = (SELECT MAX(secuencia) 
								FROM bdicheq:"informix".sc_contch_hist 
								WHERE cuenta = sh.cuenta
								AND numchq = sh.numchq)
		  AND sh.status = 'P';
       
       IF cCodRet = '' OR cCodRet IS  NULL THEN
          LET cCodRet    = '003';
          LET cNombreSuc = 'No se encuentran registros';
          RETURN  cCodRet, iNumRegistros;
       END IF;
	   
	   RETURN  cCodRet, iNumRegistros;
       
    ELSE
        LET cCodRet = '002';
        LET cNombreSuc = 'Faltan Parametros';
        RETURN  cCodRet, iNumRegistros;
    END IF;
    
END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 03/08/2016',
'DESCRIPCION: Se realiza el spl para consultar el nÃºmero total de cheques pagados por sucursal.',
'BD: bdicntchq';

CREATE PROCEDURE "informix".sp_obtienechqpag2(pFechaInicio CHAR(10), pFechaFin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(6),
          CHAR(4),
          CHAR(40),
          CHAR(20),
          CHAR(5),
          MONEY(16,2),
          VARCHAR(60),
          CHAR(16),
          CHAR(4),
          CHAR(20),
          SMALLINT;
          
--DEFINICIONES
DEFINE cCodRet         CHAR(6);
DEFINE sql_err         INTEGER;
DEFINE cCuenta         CHAR(20);
DEFINE cCliente        CHAR(20);
DEFINE cNumFirmas      CHAR(2);
DEFINE cCombFirmas     VARCHAR(120);
DEFINE sSecuencia      SMALLINT;
DEFINE cSucursal       CHAR(4);
DEFINE cNombreSuc      CHAR(40);
DEFINE cNumChq         CHAR(5);
DEFINE mMonto          MONEY(16,2);
DEFINE vFechaHora      VARCHAR(60);
DEFINE cFolioSuc       CHAR(16);
DEFINE cTransacc       CHAR(4);


ON EXCEPTION SET sql_err
    LET cCodRet = sql_err;
    RETURN  cCodRet, cSucursal, cNombreSuc, cCuenta, cNumChq, mMonto, vFechaHora ,cFolioSuc ,cTransacc ,cCliente, sSecuencia;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--INICIALIZACIONES
LET cCodRet            = '000';
LET cNumFirmas         = '0';
LET cCombFirmas        = '';
LET cCuenta            = '';
LET cCliente           = '';
LET cSucursal          = '';
LET cNombreSuc         = '';
LET cNumChq            = '';
LET mMonto             = 0.00;
LET vFechaHora         = '';
LET cFolioSuc          = '';
LET cTransacc          = '';
LET sSecuencia         = '';

--SET DEBUG FILE TO "/home/sysifx/vlv/sp_obtieneChqPag.out";
--TRACE ON;

BEGIN
    
    IF TRIM(pFechaInicio) <> '' AND pFechaInicio IS NOT NULL OR TRIM(pFechaFin) <> '' AND pFechaFin IS NOT NULL THEN
    
       FOREACH 
            --Se obtiene la cuenta y el numero de cheque para obtener la maxima secuencia de cada cheque.
            SELECT SKIP pRegistros FIRST pRecuperacion sh.sucursal, sc.nombre, sh.cuenta, sh.numchq, sh.monto, SUBSTRING(sh.fecha_alta FROM 4 FOR 2)||'/'||SUBSTRING(sh.fecha_alta FROM 1 FOR 2) ||'/'||SUBSTRING(sh.fecha_alta FROM 7 FOR 4)||' '||sh.hora_alta, sh.folio_suc, sh.transaccion, sch.num_cte, sh.secuencia 
            INTO   cSucursal, cNombreSuc, cCuenta, cNumChq, mMonto, vFechaHora ,cFolioSuc ,cTransacc, cCliente, sSecuencia
            FROM bdicheq:"informix".sc_contch_hist sh 
            INNER JOIN bdinteg:"informix".si_sucursales sc ON (sc.empresa = sh.empresa AND sc.sucursal = sh.sucursal)
            INNER JOIN bdicheq:"informix".sc_maechq sch ON (sch.empresa = sh.empresa AND sch.cuenta = sh.cuenta)
            WHERE sh.fecha_alta >= pFechaInicio
              AND sh.fecha_alta <= pFechaFin
              AND sh.secuencia = (SELECT MAX(secuencia) 
                                    FROM bdicheq:"informix".sc_contch_hist 
                                    WHERE cuenta = sh.cuenta
                                    AND numchq = sh.numchq)
              AND sh.status = 'P'
	      ORDER BY sh.fecha_alta, sh.hora_alta

            RETURN cCodRet, cSucursal, cNombreSuc, cCuenta, cNumChq, mMonto, vFechaHora ,cFolioSuc ,cTransacc ,cCliente, sSecuencia WITH RESUME;
        
       END FOREACH;
       
       IF cCodRet = '' OR cCodRet IS  NULL THEN
          LET cCodRet    = '003';
          LET cNombreSuc = 'No se encuentran registros';
          RETURN  cCodRet, cSucursal, cNombreSuc, cCuenta, cNumChq, mMonto, vFechaHora ,cFolioSuc ,cTransacc, cCliente, sSecuencia;
       END IF;
       
    ELSE
        LET cCodRet = '002';
        LET cNombreSuc = 'Faltan Parametros';
        RETURN  cCodRet, cSucursal, cNombreSuc, cCuenta, cNumChq, mMonto, vFechaHora ,cFolioSuc ,cTransacc, cCliente, sSecuencia;
    END IF;
    
END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 02/08/2016',
'DESCRIPCION: Obtiene la informacion de cheques pagados por sucursal.',
'Se realiza el spl clon para agregar los parÃ¡metros de paginado.',
'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 08/03/2017',
'DESCRIPCION: Se homologa el declaracion de la variable cNumChq.',
'BD: bdicntchq';


CREATE PROCEDURE "informix".req_inicial()



DEFINE v_cta                CHAR(20);
DEFINE v_tp                 CHAR(2);
DEFINE v_in                 INTEGER;
DEFINE v_ro                 SMALLINT;
DEFINE v_cp                 INTEGER;
DEFINE v_si		    INTEGER;
DEFINE c   		    INTEGER;
DEFINE d   		    INTEGER;
DEFINE v_ncheq		    SMALLINT;
DEFINE i      		    SMALLINT;
DEFINE v_suc                CHAR(3);
DEFINE v_hoy		    DATE;
DEFINE v_pedido		    INTEGER;
DEFINE v_usuario	    CHAR(8);

--SET DEBUG FILE TO "req_inicial.out";
--TRACE ON;

SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;
SELECT (num_pedido - 1) INTO v_pedido FROM sq_paramgen;
LET v_usuario = USER;

FOREACH SELECT sucursal, cuenta, chequera, ultimo_stock, reorden, chq_prov 
	  INTO v_suc, v_cta, v_tp, v_in, v_ro, v_cp
	  FROM sq_stockctes
--	 WHERE cuenta ="0010137718"



	 SELECT no_cheques INTO v_ncheq FROM sq_chequera
	  WHERE chequera = v_tp;

	
	 LET v_si = v_in / v_ncheq;
	 IF v_si < 0 THEN
		CONTINUE FOREACH;
	 END IF

	 IF v_si < v_ro THEN
	   LET v_si = v_ro - v_si;

	   FOR i = 1 TO v_si
                 LET c = v_cp + 1;
                 LET d = v_cp + v_ncheq;
                 INSERT INTO bdicntchq:sq_reqctes VALUES(v_suc, v_cta, c,
                                                         d, v_hoy, v_hoy, v_hoy,
                                                         "X", "001", v_pedido,
							 v_usuario);
		 LET v_cp =  d;
            END FOR
	END IF
END FOREACH
END PROCEDURE;