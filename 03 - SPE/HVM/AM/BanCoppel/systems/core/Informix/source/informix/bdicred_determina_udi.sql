CREATE PROCEDURE "informix".determina_udi(pEmpresa CHAR(3),
			       pFecha   DATE)
RETURNING CHAR(5), DECIMAL(14,6);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vValor1	      DECIMAL(14,6);
   DEFINE vValor2      	      DECIMAL(14,6);
   DEFINE vPrecio	      DECIMAL(14,6);
   DEFINE vFechaPaso	      DATE;
   DEFINE vDivUdi	      CHAR(2);
   DEFINE vClaseUdi	      CHAR(1);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret, vPrecio;
   END EXCEPTION;

-- SET DEBUG FILE TO "determina_udi.out";
-- TRACE ON;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vValor1	  = 0;
   LET vValor2	  = 0;
   LET vPrecio	  = 0;
   LET vFechaPaso = "";

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

      -- ******************************************
      -- Extrae Parametro de Codigo de Divisa UDI *
      -- ******************************************
      SELECT TRIM(valor) INTO vDivUdi
	FROM bdinteg:si_param
       WHERE empresa = pEmpresa
	 AND cod_param = 16;

      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
      SELECT TRIM(valor) INTO vClaseUdi
	FROM sd_param
       WHERE empresa = pEmpresa
	 AND cod_param = "336";


      -- **************
      -- Precio Inicio*
      -- **************
     
      SELECT precio_compra INTO vValor1
       	FROM bdinteg:si_tpcambio
        WHERE empresa = pEmpresa
       	 AND divisa = vDivUdi
       	 AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	  AND divisa = vDivUdi
                               	  AND fecha_tpcambio = pFecha)
         AND hora_tpcambio=(SELECT MAX(hora_tpcambio)
               	                 FROM bdinteg:si_tpcambio
                       	        WHERE empresa = pEmpresa
                       	   	  AND divisa = vDivUdi
                              AND fecha_tpcambio = pFecha)
         AND clase_tpcambio = vClaseUdi;

	IF vValor1 IS NULL THEN
           SELECT precio_compra INTO vValor1
             FROM bdinteg:si_histdiv
            WHERE empresa = pEmpresa
              AND divisa = "09"
              AND fecha_tc = (SELECT MAX(fecha_tc)
                                FROM bdinteg:si_histdiv
                               WHERE empresa = pEmpresa
                                 AND divisa = "09"
                                 AND fecha_tc <= pFecha)
              AND hora_tc=(SELECT MAX(hora_tc)
                           FROM bdinteg:si_histdiv
                           WHERE empresa = pEmpresa
                           AND divisa = "09"
                           AND fecha_tc = pFecha)                 
              AND clase_tpcambio = vClaseUdi;

	    IF vValor1 IS NULL THEN
		LET cod_ret = "900";
		RETURN cod_ret, vPrecio;
	    END IF
	END IF

	-- *************
	-- Precio Final*
	-- *************
       IF DAY(pFecha) = 31 AND MONTH(pFecha) IN (5,7,10,12) THEN
	LET pFecha = MONTH(pFecha) || "/30/" || YEAR(pFecha);
       END IF

       IF MONTH(pFecha) = 3 AND DAY(pFecha) > 28 THEN
	LET vFechaPaso = MONTH(pFecha) || "/01/" || YEAR(pFecha);
	LET vFechaPaso = vFechaPaso -1;
	LET pFecha = MONTH(pFecha) || "/" || DAY(vFechaPaso) || "/" ||
		     YEAR(pFecha);
       END IF

       LET pFecha = pFecha ;
       LET pFecha = pFecha -1 UNITS MONTH ;
       SELECT precio_compra INTO vValor2
        FROM bdinteg:si_histdiv
       WHERE empresa = pEmpresa
         AND divisa = "09"
         AND fecha_tc = (SELECT MAX(fecha_tc)
                           FROM bdinteg:si_histdiv
                          WHERE empresa = pEmpresa
                            AND divisa = "09"
          	 	    AND fecha_tc <= pFecha)
          AND hora_tc=(SELECT MAX(hora_tc)
                       FROM bdinteg:si_histdiv
                       WHERE empresa = pEmpresa
                       AND divisa = "09"
                       AND fecha_tc = pFecha)  
         AND clase_tpcambio = vClaseUdi;

	IF vValor2 IS NULL THEN
		LET cod_ret = "901";
		RETURN cod_ret, vPrecio;
	END IF


      -- IF vValor2 < vValor1 THEN
       --  let vPrecio = 0;
      -- ELSE
	   LET vPrecio = (vValor1 / vValor2);
           IF vPrecio > 1 THEN
              LET vPrecio =  vPrecio -1;
           ELSE
              LET vPrecio = 0;
           END IF
     -- END IF;

END
	RETURN cod_ret, vPrecio;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_corrige_insertos(pEmpresa CHAR(3))
RETURNING 
          CHAR(5) AS resultado,
          CHAR(80) AS mensaje;

    DEFINE iSqlErr      	     INTEGER;
    DEFINE iIsamErr              INTEGER;
    DEFINE cErrorInfo            CHAR(80);
    DEFINE cCodRet               CHAR(5); 
    DEFINE cMensajeRet           CHAR(80);
    DEFINE cNumCredito           CHAR(20);
    DEFINE cInsertoNuevo         CHAR(15);
    DEFINE cFechaEmision         DATE;
    DEFINE cPosicion             CHAR(2);

    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
        RETURN cCodRet,cMensajeRet;
       END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "sp_corrige_insertos";
    --TRACE ON;
    LET iSqlErr=0;
    LET iIsamErr=0;
    LET cErrorInfo="";
    LET cCodRet= '00000';
    LET cMensajeRet= 'Se realizó la consulta correctamente';
    LET cNumCredito="";
    LET cInsertoNuevo='000000000000000';
    LET cFechaEmision=MDY('05','20','2009');
    LET cPosicion="";

    FOREACH
        SELECT num_credito,posicion
          INTO cNumCredito,cPosicion
          FROM bdicred:sd_marcaje 
         WHERE empresa=pEmpresa
           AND fecha_emision=date(0)

        IF cPosicion = '10' THEN
            LET cInsertoNuevo = '100000000000000';
        ELIF cPosicion = '00' THEN 
            LET cInsertoNuevo = '000100000000000';
        END IF;

        UPDATE bdicred:sd_marcaje
        SET fecha_emision=cFechaEmision,
            posicion=0,
            insertos=cInsertoNuevo
        WHERE empresa=pEmpresa
          AND num_credito=cNumCredito
          AND fecha_emision=date(0);

        UPDATE bdicred:sd_encabezado_edocta
        SET insertos=cInsertoNuevo
        WHERE num_credito=cNumCredito
          AND fecha_emision=cFechaEmision;
    END FOREACH;
  RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;