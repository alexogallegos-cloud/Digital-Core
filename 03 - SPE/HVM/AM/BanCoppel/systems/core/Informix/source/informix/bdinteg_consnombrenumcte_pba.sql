CREATE PROCEDURE "informix".consnombrenumcte_pba(pEmpresa CHAR(3),
						pNombre1 CHAR(26),
						pNombre2 CHAR(26),
                        pPaterno CHAR(26),
                        pMaterno CHAR(26),
						pFechaNac DATE,
						pNo_Rfc CHAR(13),
						pRazon CHAR(60),
                        pSecuencia SMALLINT)

RETURNING CHAR(5),CHAR(60),CHAR(20),CHAR(13);

DEFINE sql_err 									  INTEGER;
DEFINE v_longitud,v_ciclo 					      SMALLINT;
DEFINE v_nombre_completo 						  CHAR(63);
DEFINE v_nombre1, v_nombre2, v_paterno, v_materno CHAR(26);
DEFINE v_numcte 								  CHAR(20);
DEFINE v_cod_ret 								  CHAR(5);
DEFINE v_razon_soc 								  CHAR(60);
DEFINE v_rfc 									  CHAR(13);
DEFINE v_rfc_alterno                              CHAR(13);

--set debug file to "ConsultarNombreNumCliente.out";
--trace on;

LET v_cod_ret = "00000";
LET v_ciclo = 0;
LET v_nombre_completo = "";
LET v_numcte = "0000000000";
LET v_rfc = "";
LET v_rfc_alterno = "";

BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
   	     LET v_cod_ret = sql_err;
	     RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
     END IF;
   END EXCEPTION;

IF NVL(pEmpresa,'') = ''  THEN
	LET v_cod_ret = "00001";
	LET v_nombre_completo = 'Parámetros incompletos';
	RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
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
        RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
    END FOREACH;
ELSE

    IF pNo_Rfc IS NOT NULL AND pNo_Rfc != "" THEN
        FOREACH
            SELECT skip pSecuencia limit 21 
                 nombre1,nombre2,apell_paterno,apell_materno,pf.numcte,rfc, rfc_alterno
	        INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc, v_rfc_alterno
      	    FROM si_ctepf pf, si_cliente cl
      	    WHERE rfc = pno_rfc AND cl.numcte = pf.numcte
      	    ORDER BY pf.numcte
--      	    LET v_ciclo = v_ciclo+1;
--      	    IF v_ciclo <= psecuencia THEN
--                 CONTINUE FOREACH;
--      	    END IF;
	        LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
             || " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
			 
			IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
               LET v_rfc = v_rfc_alterno;
            END IF;
			
	        RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
        END FOREACH;
    ELSE

   ---VALIDA PARAMETROS

--	IF NVL(pPaterno,'') = '' AND NVL(pMaterno,'') = '' THEN
	IF NVL(pPaterno,'') = ''  THEN
		LET v_cod_ret = "00002";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos apellidos';
		RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
--	ELIF NVL(pNombre1,'') = '' AND NVL(pNombre2,'') = '' THEN
	ELIF NVL(pNombre1,'') = '' THEN
		LET v_cod_ret = "00003";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos nombres';
		RETURN v_cod_ret, v_nombre_completo, v_numcte,v_rfc;
	ELSE
        if ( pPaterno is null or pPaterno = "" ) then
           let pPaterno = "";
        else
            let pPaterno = trim(pPaterno)||"*";
           --- let pPaterno = trim(pPaterno);
        end if;  

        if ( pMaterno is null or pMaterno = "" ) then
           let pMaterno = "";
        else
           let pMaterno = trim(pMaterno)||"*";
           --- let pMaterno = trim(pMaterno);
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
                     nombre1,nombre2,apell_paterno,apell_materno,cl.numcte,rfc, rfc_alterno
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc, v_rfc_alterno
				FROM si_ctepf pf, si_cliente cl
				WHERE cl.apell_paterno matches ppaterno
				AND cl.apell_materno matches pmaterno
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
						
				IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
                   LET v_rfc = v_rfc_alterno;
                END IF;
				
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
			END FOREACH;

		ELSE

			FOREACH
				SELECT skip pSecuencia limit 21
                     nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc, rfc_alterno
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc, v_rfc_alterno
				FROM si_cliente
				WHERE apell_paterno matches ppaterno
				AND apell_materno matches pmaterno
				AND nombre1 matches pNombre1
				AND nombre2 matches pNombre2
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2

--				LET v_ciclo = v_ciclo+1;

--				IF v_ciclo <= psecuencia THEN
--					CONTINUE FOREACH;
--				END IF;

				LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(UPPER(v_materno))
						|| " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
						
				IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
                   LET v_rfc = v_rfc_alterno;
                END IF;		
						
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
			END FOREACH;
		END IF;
        END IF;
    END IF;
END IF;

END;
END PROCEDURE
DOCUMENT
'Consulta clientes por nombre(s) y apellido(s) y por fecha de nacimiento si asi se requiere',
'AUTOR : Dulce Ramirez',
'FECHA : 01/Junio/2009',
'Ver.  : 1.1',
'BD    : bdinteg',
'VER   : 1.1';

CREATE PROCEDURE "informix".consnombrenumcte(pEmpresa CHAR(3),
						pNombre1 CHAR(26),
						pNombre2 CHAR(26),
                        pPaterno CHAR(26),
                        pMaterno CHAR(26),
						pFechaNac DATE,
						pNo_Rfc CHAR(13),
						pRazon CHAR(60),
                        pSecuencia SMALLINT)

RETURNING CHAR(5),CHAR(60),CHAR(20),CHAR(13);

DEFINE sql_err 									  INTEGER;
DEFINE v_longitud,v_ciclo 					      SMALLINT;
DEFINE v_nombre_completo 						  CHAR(63);
DEFINE v_nombre1, v_nombre2, v_paterno, v_materno CHAR(26);
DEFINE v_numcte 								  CHAR(20);
DEFINE v_cod_ret 								  CHAR(5);
DEFINE v_razon_soc 								  CHAR(60);
DEFINE v_rfc 									  CHAR(13);
DEFINE v_rfc_alterno                              CHAR(13);

--set debug file to "ConsultarNombreNumCliente.out";
--trace on;

LET v_cod_ret = "00000";
LET v_ciclo = 0;
LET v_nombre_completo = "";
LET v_numcte = "0000000000";
LET v_rfc = "";
LET v_rfc_alterno = "";

BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
   	     LET v_cod_ret = sql_err;
	     RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
     END IF;
   END EXCEPTION;

IF NVL(pEmpresa,'') = ''  THEN
	LET v_cod_ret = "00001";
	LET v_nombre_completo = 'Parámetros incompletos';
	RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
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
        RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
    END FOREACH;
ELSE

    IF pNo_Rfc IS NOT NULL AND pNo_Rfc != "" THEN
        FOREACH
            SELECT skip pSecuencia limit 21 
                 nombre1,nombre2,apell_paterno,apell_materno,pf.numcte,rfc, rfc_alterno
	        INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc, v_rfc_alterno
      	    FROM si_ctepf pf, si_cliente cl
      	    WHERE rfc = pno_rfc AND cl.numcte = pf.numcte
      	    ORDER BY pf.numcte
--      	    LET v_ciclo = v_ciclo+1;
--      	    IF v_ciclo <= psecuencia THEN
--                 CONTINUE FOREACH;
--      	    END IF;
	        LET v_nombre_completo = TRIM(v_paterno) || " " || TRIM(v_materno)
             || " " || TRIM(v_nombre1) || " " || TRIM(v_nombre2);
			 
			IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
               LET v_rfc = v_rfc_alterno;
            END IF;
			
	        RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
        END FOREACH;
    ELSE

   ---VALIDA PARAMETROS

--	IF NVL(pPaterno,'') = '' AND NVL(pMaterno,'') = '' THEN
	IF NVL(pPaterno,'') = ''  THEN
		LET v_cod_ret = "00002";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos apellidos';
		RETURN v_cod_ret, v_nombre_completo, v_numcte, v_rfc;
--	ELIF NVL(pNombre1,'') = '' AND NVL(pNombre2,'') = '' THEN
	ELIF NVL(pNombre1,'') = '' THEN
		LET v_cod_ret = "00003";
		LET v_nombre_completo = 'Debe capturar al menos uno de los dos nombres';
		RETURN v_cod_ret, v_nombre_completo, v_numcte,v_rfc;
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
                     nombre1,nombre2,apell_paterno,apell_materno,cl.numcte,rfc, rfc_alterno
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc, v_rfc_alterno
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
						
				IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
                   LET v_rfc = v_rfc_alterno;
                END IF;
				
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
			END FOREACH;

		ELSE

			FOREACH
				SELECT skip pSecuencia limit 21
                     nombre1,nombre2,apell_paterno,apell_materno,numcte,rfc, rfc_alterno
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_rfc, v_rfc_alterno
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
						
				IF v_rfc_alterno is not null and v_rfc_alterno <> "" THEN
                   LET v_rfc = v_rfc_alterno;
                END IF;		
						
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
			END FOREACH;
		END IF;
        END IF;
    END IF;
END IF;

END;
END PROCEDURE
DOCUMENT
'Consulta clientes por nombre(s) y apellido(s) y por fecha de nacimiento si asi se requiere',
'AUTOR : Dulce Ramirez',
'FECHA : 01/Junio/2009',
'Ver.  : 1.1',
'BD    : bdinteg',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_actualizacurp(pEmpresa CHAR(3), pNumCte CHAR(20), pCURP CHAR(18))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Se actualiza CURP en los datos del cliente (si_ctepf)
--Realizó: Nancy Sevilla Camacho
--Fecha: 24/06/2011                    
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5);      -- Código de Retorno
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);	
DEFINE cRfc CHAR(13);	

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '00000';
LET cRfc = '';
	
	--SET DEBUG FILE TO "/tmp/sp_actualizacurp.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;	
		
		-- Se valida que los parámetros de entrada no vengan vacíos
		IF pEmpresa IS NULL OR pEmpresa = '' OR pNumCte IS NULL OR pNumCte = '' OR 
		   pCURP IS NULL OR pCURP = '' THEN
		
			LET cCodRet = "100"; -- Parámetro de entrada vacío
			
		ELSE
			SELECT rfc 
			  INTO cRfc
			  FROM bdinteg:si_cliente
			 WHERE empresa = pEmpresa
			   AND numcte = pNumCte;
			   
			IF SUBSTRING(cRfc FROM 1 FOR 10) = SUBSTRING(pCURP FROM 1 FOR 10) THEN
			-- Se actualiza CURP
				UPDATE bdinteg:"informix".si_ctepf
				   SET curp = pCURP
				 WHERE empresa = pEmpresa
				   AND numcte = pNumCte;
			   
				INSERT INTO si_bitacora_cambio_curp (numcte,rfc,curp,resultado,fecha)
				VALUES(pNumCte, cRfc, pCURP, '01', CURRENT);
				
			ELIF SUBSTRING(pCURP FROM 2 FOR 1) = "X" THEN
				-- Se actualiza CURP con palabras altizonantes
				UPDATE bdinteg:"informix".si_ctepf
				SET curp = pCURP
				WHERE empresa = pEmpresa
				AND numcte = pNumCte;
			   
				INSERT INTO si_bitacora_cambio_curp (numcte,rfc,curp,resultado,fecha)
				VALUES(pNumCte, cRfc, pCURP, '01', CURRENT);
			ELSE
				INSERT INTO si_bitacora_cambio_curp (numcte,rfc,curp,resultado,fecha)
				VALUES(pNumCte, cRfc, pCURP, '02', CURRENT);
				
				LET cCodRet = "290";
			
			END IF;

		END IF;
		
	    RETURN cCodRet;			
		
	END
END PROCEDURE;