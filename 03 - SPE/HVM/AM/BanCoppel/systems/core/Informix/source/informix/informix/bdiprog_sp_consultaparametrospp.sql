CREATE PROCEDURE "informix".sp_consultaparametrospp(pCveParam CHAR(8), pValor CHAR(10))
    
    RETURNING 
    CHAR(5),
    CHAR(50);

    DEFINE iSqlErr	INTEGER;
    DEFINE cCodRet	CHAR(5);
    DEFINE cDescpn  CHAR(50);
    
    LET iSqlErr     = 0;
    LET cCodRet     = "00000";
    LET cDescpn     = "";

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cDescpn;
        END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_consultaparametrospp.out";
	--TRACE ON;

    IF pCveParam = "" OR pValor = "" THEN
        LET cCodRet = "00001";
        RETURN cCodRet, cDescpn;
    END IF
    
    SELECT desc_valor INTO cDescpn FROM bdiprog:pp_parametros WHERE cve_param = pCveParam AND valor = pValor;
    
    IF NVL(cDescpn,"") = "" THEN
        LET cCodRet = "00002";
        RETURN cCodRet, cDescpn;
    END IF
    RETURN cCodRet, cDescpn;
END
END PROCEDURE
DOCUMENT
'Modifico: Adrian Lara',
'Proyecto: Programacion de Transacciones',
'Solicito: Frank Gaxiola',
'Descripcion: Se crea procedimiento para la consulta de parametros',
'Fecha: 10/09/2010',
'Version: 20100910.1040 Rumpelstiltskin',
'BD: bdiprog';

CREATE PROCEDURE "informix".sp_validasky(pNumRefSky CHAR(12))
	 RETURNING CHAR(5);

	-- *************************************************
	-- Realizo: Francisco Rodríguez               --*
	-- Actividad:validar la referencia sky     --*
	-- Solicito:Diana Castellanos                      --*
	--Fecha: 16/Agosto/2010                        --*
	-- *************************************************

--Asignacion de variables
	 --Declaración de Variables
	 DEFINE sql_err INTEGER;
	 DEFINE vcCodRet       CHAR(5);
	 DEFINE vcCodRetDig       CHAR(5);
	 DEFINE v_DigCapturado INTEGER;
	 DEFINE v_DigCalculado INTEGER;
	 DEFINE v_ValorDigito  INTEGER;
	 DEFINE v_FlagLetra	INTEGER;
	 DEFINE v_NoPeso		INTEGER;
	 DEFINE v_AUX			INTEGER;
	 DEFINE v_Num1			CHAR(1);
	 DEFINE v_Num2			CHAR(1);
	 DEFINE v_Suma			INTEGER;
	 DEFINE i				INTEGER;
	 DEFINE v_ValorDig		INTEGER;
	 DEFINE v_Letra  		CHAR(1);
	 DEFINE letra  char(12);
	 --Asignación valores a variables
	 LET v_DigCapturado = 0;
	 LET v_DigCalculado = 0;
	 LET v_ValorDigito 	= 0;
	 LET v_FlagLetra	= 0;
	 LET v_NoPeso		=0;
	 LET v_AUX =0;
	 LET v_Num1='';
	 LET v_Num2='';
	 LET v_Suma=0;
	 LET vcCodRet='99999';
	 LET sql_err =0;
	 LET i=0;
	 LET letra="";
	 --Inicio del procedimiento

	BEGIN

		ON EXCEPTION SET sql_err
			LET vcCodRet = sql_err;
			RETURN vcCodRet;
		END EXCEPTION;

		IF( LENGTH(pNumRefSky)=12 ) THEN
			LET v_DigCapturado=SUBSTR(pNumRefSky,12,1)::INTEGER;


			FOR i = 1 TO 11

				IF(MOD(i,2)=0) THEN
					LET v_NoPeso = 1;
				ELSE
					 LET v_NoPeso = 2;
				END IF

				LET v_Letra=UPPER(SUBSTR(pNumRefSky,i,1));
				IF (v_Letra='A' OR v_Letra='B' OR v_Letra='C' OR v_Letra='D' OR v_Letra='E' OR v_Letra='F' OR v_Letra='G' OR v_Letra='H' OR
					v_Letra='I' OR v_Letra='J' OR v_Letra='K' OR v_Letra='L' OR v_Letra='M' OR v_Letra='N' OR v_Letra='O' OR v_Letra='P' OR
					v_Letra='Q' OR v_Letra='R' OR v_Letra='S' OR v_Letra='T' OR v_Letra='U' OR v_Letra='V' OR v_Letra='W' OR v_Letra='X' OR
					v_Letra='Y' OR v_Letra='Z') THEN

					SELECT valor INTO  v_ValorDigito
	                  FROM bdiprog:pp_sacasignacionletrassky
	                  WHERE letra = v_Letra;

					IF(v_ValorDigito="" OR v_ValorDigito IS NULL )THEN
						LET v_FlagLetra = 1;

					END IF

				ELIF (v_Letra='0' OR v_Letra='1' OR v_Letra='2' OR v_Letra='3' OR v_Letra='4' OR v_Letra='5' OR v_Letra='6' OR v_Letra='7' OR
					  v_Letra='8' OR v_Letra='9') THEN

	                 LET  v_ValorDigito = SUBSTR(pNumRefSky,i,1)::INTEGER;

	            END IF;

				LET v_AUX= v_ValorDigito * v_NoPeso;
				IF v_AUX > 9 THEN
				  --raise notice ''Multiplicacion Mayor a 9 = %'', iAux ;
				  LET v_Num1 = SUBSTR(v_AUX::CHAR(2),1,1) ;
		          LET v_Num2 = SUBSTR(v_AUX::CHAR(2),2,1) ;
		          LET v_AUX = v_Num1::INTEGER + v_Num2::INTEGER;


				END IF;
				LET v_Suma = v_Suma + v_AUX;
			END FOR

			IF (v_FlagLetra = 0) THEN
				IF SUBSTR(v_Suma::CHAR(2),2,1)=1 THEN
					LET v_DigCalculado =  9;
				ELIF SUBSTR(v_Suma::CHAR(2),2,1)=2 THEN
					LET v_DigCalculado =  8;
				ELIF SUBSTR(v_Suma::CHAR(2),2,1)=3 THEN
					LET v_DigCalculado =  7;
				ELIF SUBSTR(v_Suma::CHAR(2),2,1)=4 THEN
					LET v_DigCalculado =  6;
				ELIF SUBSTR(v_Suma::CHAR(2),2,1)=5 THEN
					LET v_DigCalculado =  5;
				ELIF SUBSTR(v_Suma::CHAR(2),2,1)=6 THEN
					LET v_DigCalculado =  4;
				ELIF SUBSTR(v_Suma::CHAR(2),2,1)=7 THEN
					LET v_DigCalculado =  3;
				ELIF SUBSTR(v_Suma::CHAR(2),2,1)=8 THEN
					LET v_DigCalculado =  2;
				ELIF SUBSTR(v_Suma::CHAR(2),2,1)=9 THEN
					LET v_DigCalculado =  1;
				ELIF SUBSTR(v_Suma::CHAR(2),2,1)=0 THEN
					LET v_DigCalculado =  0;
				END IF

				IF (v_DigCapturado = v_DigCalculado) THEN
		  	       LET vcCodRet= "00000";

			    ELSE
			       LET vcCodRet="00004";  --referencia invalida
			    END IF;

			ELIF ( v_FlagLetra = 1 ) THEN
				LET vcCodRet= "00003";
			END IF
		ELSE
			LET vcCodRet= "00002";  --Referencia no es de 12 digitos
		END IF;

		RETURN vcCodRet;
	END
END PROCEDURE
;