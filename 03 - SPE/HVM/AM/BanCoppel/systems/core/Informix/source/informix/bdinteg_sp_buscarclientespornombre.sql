CREATE PROCEDURE "informix".sp_buscarclientespornombre(
                        pEmpresa CHAR(3),
                        pNombre1 CHAR(30),
                        pNombre2 CHAR(30),
                        pPaterno CHAR(30),
                        pMaterno CHAR(30),
                        pFechaNac DATE,
                        pNo_Rfc CHAR(13),
                        pRazon CHAR(60),
                        pSecuencia SMALLINT)

RETURNING CHAR(20) as num_cliente, CHAR(30) as nombre1, CHAR(30) as nombre2, CHAR(30) as apaterno, CHAR(30) as amaterno;

-- ************************************************************************
-- Definición de variables
-- ************************************************************************

DEFINE sql_err 									  INTEGER;
DEFINE v_longitud,v_ciclo 					      SMALLINT;
DEFINE v_nombre_completo 						  CHAR(63);

--DEFINE v_nombre1, v_nombre2, v_paterno, v_materno CHAR(30);

DEFINE v_nombre1                                  CHAR(30);
DEFINE v_nombre2                                  CHAR(30);
DEFINE v_paterno                                  CHAR(30);
DEFINE v_materno                                  CHAR(30);

DEFINE v_numcte 								  CHAR(20);
DEFINE v_cod_ret 								  CHAR(5);
DEFINE v_razon_soc 								  CHAR(60);
DEFINE v_rfc 									  CHAR(13);

--set debug file to "ConsultarNombreNumCliente.out";
--trace on;

-- ************************************************************************
-- inicialización de variables
-- ************************************************************************

LET v_cod_ret = "00000";
LET v_ciclo = 0;
LET v_nombre_completo = "";

LET v_nombre1 = "";
LET v_nombre2 = "";
LET v_paterno = "";
LET v_materno = "";

LET v_numcte = "0000000000";
LET v_rfc = "";

BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
   	     LET v_cod_ret = sql_err;
	     RETURN v_numcte, v_nombre1, v_nombre2, v_paterno, v_materno;
     END IF;
   END EXCEPTION;

IF NVL(pEmpresa,'') = ''  THEN
	LET v_cod_ret = "00001";
	LET v_nombre_completo = 'Parámetros incompletos';
	RETURN v_numcte, v_nombre1, v_nombre2, v_paterno, v_materno;
END IF;

SET ISOLATION TO DIRTY READ;

IF pRazon IS NOT NULL AND pRazon !="" THEN
    FOREACH
        SELECT skip pSecuencia limit 21
             razon_social,numcte,rfc
 	    INTO v_razon_soc,v_numcte,v_rfc
        FROM si_cliente
        WHERE razon_social = prazon
           and apell_paterno = ''
	       and apell_materno = ''
        ORDER BY numcte
--        LET v_ciclo = v_ciclo+1;
--        IF v_ciclo <= psecuencia THEN
-- 	        CONTINUE FOREACH;
--        END IF;
        LET v_nombre_completo = v_razon_soc;
        RETURN v_numcte, v_nombre1, v_nombre2, v_paterno, v_materno WITH RESUME;
    END FOREACH;
ELSE

    IF pNo_Rfc IS NOT NULL AND pNo_Rfc != "" THEN
        FOREACH
            SELECT skip pSecuencia limit 21 
                 nombre1,nombre2,apell_paterno,apell_materno,pf.numcte,rfc
	        INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc
      	    FROM si_ctepf pf, si_cliente cl
      	    WHERE rfc = pno_rfc AND cl.numcte = pf.numcte
      	    ORDER BY pf.numcte
--      	    LET v_ciclo = v_ciclo+1;
--      	    IF v_ciclo <= psecuencia THEN
--                 CONTINUE FOREACH;
--      	    END IF;
	        LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
             || " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
	        RETURN v_numcte, v_nombre1, v_nombre2, v_paterno, v_materno WITH RESUME;
        END FOREACH;
    ELSE

   ---VALIDA PARAMETROS

--	IF NVL(pPaterno,'') = '' AND NVL(pMaterno,'') = '' THEN
	IF NVL(pPaterno,'') = ''  THEN
		LET v_cod_ret = "00002";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos apellidos';
		RETURN v_numcte, v_nombre1, v_nombre2, v_paterno, v_materno;
--	ELIF NVL(pNombre1,'') = '' AND NVL(pNombre2,'') = '' THEN
	ELIF NVL(pNombre1,'') = '' THEN
		LET v_cod_ret = "00003";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos nombres';
		RETURN v_numcte, v_nombre1, v_nombre2, v_paterno, v_materno;
	ELSE
        if ( pPaterno is null or pPaterno = "" ) then
           let pPaterno = "";
        else
--           let pPaterno = trim(pPaterno)||"*";
           let pPaterno = trim(pPaterno);
        end if;  

        if ( pMaterno is null or pMaterno = "" ) then
           let pMaterno = "";
        else
--           let pMaterno = trim(pMaterno)||"*";
           let pMaterno = trim(pMaterno);
        end if;  

        if ( pNombre1 is null or pNombre1 = "" ) then
           let pNombre1 = "";
        else
           let pNombre1 = trim(pNombre1)||"*";
        end if;  

        if ( pNombre2 is null or pNombre2 = "" ) then
           let pNombre2 = "";
        else
           let pNombre2 = trim(pNombre2)||"*";
        end if;  

--		LET pPaterno = TRIM(pPaterno)||"*";
--		LET pMaterno = TRIM(pMaterno)||"*";
--		LET pNombre1 = TRIM(pNombre1)||"*";
--		LET pNombre2 = TRIM(pNombre2)||"*";

		IF NVL(pFechaNac,'') <> '' THEN
			FOREACH
				SELECT skip pSecuencia limit 21
                     nombre1,nombre2,apell_paterno,apell_materno,cl.numcte,rfc
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc
				FROM si_ctepf pf, si_cliente cl
				WHERE cl.apell_paterno = ppaterno
				AND cl.apell_materno = pmaterno
				AND cl.nombre1 matches pNombre1
				AND cl.nombre2 matches pNombre2
				AND pf.fecha_nac = pFechaNac
				AND cl.numcte = pf.numcte
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2

--				LET v_ciclo = v_ciclo + 1;

--				IF v_ciclo <= psecuencia THEN
--					CONTINUE FOREACH;
--				END IF;

				LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
						|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
				RETURN v_numcte, v_nombre1, v_nombre2, v_paterno, v_materno WITH RESUME;
			END FOREACH;

		ELSE

			FOREACH
				SELECT skip pSecuencia limit 21
                     nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc
				FROM si_cliente
				WHERE apell_paterno = ppaterno
				AND apell_materno = pmaterno
				AND nombre1 matches pNombre1
				AND nombre2 matches pNombre2
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2

--				LET v_ciclo = v_ciclo+1;

--				IF v_ciclo <= psecuencia THEN
--					CONTINUE FOREACH;
--				END IF;

				LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(UPPER(v_materno))
						|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
				RETURN v_numcte, v_nombre1, v_nombre2, v_paterno, v_materno WITH RESUME;
			END FOREACH;
		END IF;
        END IF;
    END IF;
END IF;

END;
END PROCEDURE


-- ************************************************************************
-- SP modificado, tomando como referencia el SP consnombrenumcte de la BD bdinteg
-- 23/03/2011
-- Sistema de aclaraciones
-- ************************************************************************
;

CREATE PROCEDURE "informix".sp_buscarclientespornumero (p_sNumeroCliente CHAR(30))

     RETURNING	CHAR(20) AS noCliente, CHAR(30) AS primerApellido, CHAR(30) AS segundoApellido, CHAR(30) AS primerNombre, CHAR(30) AS segundoNombre;

	--definicion de variables--	    
	DEFINE resultado_numeroCliente 		CHAR(20);
	DEFINE resultado_primerApellido		CHAR(30);
	DEFINE resultado_segundoApellido	CHAR(30);
    DEFINE resultado_primerNombre		CHAR(30);
    DEFINE resultado_segundoNombre		CHAR(30);
    DEFINE resultado_numerotransfer     CHAR(30);
  
    DEFINE iSqlErr                      INTEGER;
	
     	-- InicializaciÃ³n de las variables.
	LET resultado_numeroCliente = '';
	LET resultado_primerApellido = '';
	LET resultado_segundoApellido = '';
	LET resultado_primerNombre = '';
	LET resultado_segundoNombre = '';
  

    SET ISOLATION TO DIRTY READ;
			
	BEGIN

        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_numeroCliente = '';
                    LET resultado_primerApellido = '';
                    LET resultado_segundoApellido = '';
                    LET resultado_primerNombre = '';
                    LET resultado_segundoNombre = '';
                   
                    RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;
                END IF;
        END EXCEPTION;

	SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE p_sNumeroCliente = numcte;
    

   IF ( resultado_primerNombre IS NULL) THEN 
    
      SELECT bditransfer:tf_maecte.numcte 
      INTO resultado_numerotransfer
         FROM bditransfer:tf_maecte
        WHERE bditransfer:tf_maecte.numcte_tf = p_sNumeroCliente;
      
     SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
		INTO resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido
		FROM bdinteg:si_cliente
		WHERE resultado_numerotransfer = numcte;
     

    END IF;
      
    

   RETURN resultado_numeroCliente, resultado_primerNombre, resultado_segundoNombre, resultado_primerApellido, resultado_segundoApellido;

		

	END
END PROCEDURE;