CREATE PROCEDURE "informix".sp_validabts(pNumBTS CHAR(11))
RETURNING VARCHAR(6) AS COD_RET,VARCHAR(80) AS MSG;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  vAscii           INTEGER;
DEFINE  vPos             INTEGER;
DEFINE  iDigVerCapturado INTEGER;
DEFINE  iNoPeso          INTEGER;
DEFINE  iAux             INTEGER;
DEFINE  iValorDigito     INTEGER;
DEFINE  cNum1		     CHAR(1);
DEFINE  cNum2		     CHAR(1);
DEFINE  iSuma            INTEGER;
DEFINE  iResiduo         INTEGER;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;


 --+-----------------------------------------------------------------+--
 --|         FECHA: 21 de Febrero del 2011                           |--
 --|       ELABORO: Manuel Osuna Valencia                            |--
 --| FUNCIONALIDAD: Valida si el digito verificador capturado en la  |--
 --|                consulta de pagos de remesas BTS es correcto.    |--
 --|                Recibe:Numero de Confirmación BTS (11 digitos).  |--
 --|                Regresa: 0=Digito Verificador Correcto           |--
 --|                1=Digito Verificador Invalido                    |--
 --|                2=Referencia diferente de 11 digitos             |--
 --|                3=El Numero de Referencia contiene una letra     |--
 --+-----------------------------------------------------------------+--


   LET P_COD_RET = '00001';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   LET vAscii = '';
   LET vPos = 1;
   LET iDigVerCapturado = 0;
   LET iNoPeso = 0;
   LET iAux = 0;
   LET iSuma = 0;
   LET iResiduo = 0;

  IF LENGTH(TRIM(pNumBTS))= 11 THEN

		IF ( (UPPER(SUBSTR(pNumBTS,11,1)) >= 'A' AND  UPPER(SUBSTR(pNumBTS,11,1)) <= 'Z' ) OR   UPPER(SUBSTR(pNumBTS,11,1)) = '±' OR  UPPER(SUBSTR(pNumBTS,11,1)) = 'Ð') THEN
			LET P_COD_RET = '00003';
			RETURN P_COD_RET,P_MENSAJE;
		ELIF (UPPER(SUBSTR(pNumBTS,vPos,1)) >= '0' AND UPPER(SUBSTR(pNumBTS,vPos,1)) <= '9' ) THEN
			LET iDigVerCapturado = SUBSTR(pNumBTS,11,1)::int;
		END IF;

		FOR vPos = 4 TO 10
			IF ( (UPPER(SUBSTR(pNumBTS,vPos,1)) >= 'A' AND  UPPER(SUBSTR(pNumBTS,vPos,1)) <= 'Z' ) OR   UPPER(SUBSTR(pNumBTS,vPos,1)) = '±' OR  UPPER(SUBSTR(pNumBTS,vPos,1)) = 'Ð') THEN
				LET P_COD_RET = '00003';
				RETURN P_COD_RET,P_MENSAJE;
			ELIF (UPPER(SUBSTR(pNumBTS,vPos,1)) >= '0' AND UPPER(SUBSTR(pNumBTS,vPos,1)) <= '9' ) THEN
				LET iValorDigito = SUBSTR(pNumBTS,vPos,1)::int;
			END IF;

			IF MOD(vPos,2)= 0 THEN
				LET iNoPeso = 2;
			ELSE
				LET iNoPeso = 1;
			END IF;

			LET iAux = iValorDigito * iNoPeso;

			IF iAux > 9 THEN
                LET cNum1 = SUBSTR(iAux::char(2),1,1) ;
				LET cNum2 = SUBSTR(iAux::char(2),2,1) ;
				LET iAux = (cNum1::int) + (cNum2::int);
			END IF;

			LET iSuma = iSuma + iAux;

		END FOR;

		LET iResiduo = mod(iSuma , 10);
		IF iResiduo > 0 THEN
			LET iValorDigito = 10 - iResiduo;
			IF iValorDigito =  iDigVerCapturado THEN
				LET P_COD_RET = '00000';
			END IF;
		ELSE
			IF iResiduo =  iDigVerCapturado THEN
				LET P_COD_RET = '00000';
			END IF;
		END IF;

  ELSE
	LET P_COD_RET = '00002';
  END IF;


 RETURN P_COD_RET,P_MENSAJE;

END
END PROCEDURE;