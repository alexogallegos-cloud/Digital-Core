CREATE PROCEDURE "informix".consnombrenumctenew(pEmpresa CHAR(3),
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

--set debug file to "ConsultarNombreNumCliente.out";
--trace on;

LET v_cod_ret = "00000";
LET v_ciclo = 0;
LET v_nombre_completo = "";
LET v_numcte = "0000000000";
LET v_rfc = "";

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
				RETURN v_cod_ret,v_nombre_completo,v_numcte,v_rfc WITH RESUME;
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

CREATE PROCEDURE "informix".sp_obtenernumproductonew(p_sEmpresa CHAR(3), p_sNumCuenta CHAR(20), p_sNumTarjeta CHAR(20))
RETURNING	 VARCHAR(6) as sNumProducto --numero de producto

	DEFINE iSqlErr				INTEGER;
	DEFINE v_sNumProducto 		CHAR(4);
	DEFINE v_sTipoCuenta		CHAR(2);
	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Erick Zamora
	-- FECHA: 23-03-2009
	-- Obtiene el numero de producto al que hace referencia una cuenta 
	-- SET DEBUG FILE TO "/tmp/sp_obtenernumproducto.out";
	-- TRACE ON;
	------------------------------------------------------------------------------------------------------
	LET v_sNumProducto = "";
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		LET v_sNumProducto = "0000";
		--SE OBTIENE EL NUMERO DE CUENTA DE LA TARJETA DE DEBITO
		IF p_sNumCuenta = "" AND p_sNumTarjeta <> "" THEN
			SELECT prodtarjeta INTO v_sNumProducto FROM bdicheq:sc_tarjeta WHERE empresa = p_sEmpresa AND num_tarjeta = p_sNumTarjeta;
			RETURN v_sNumProducto;
		END IF
		
		LET v_sTipoCuenta = SUBSTR(p_sNumCuenta,1,2);
		
		IF v_sTipoCuenta IN('10','11','13','15','18','19') THEN	--CUENTAS DE DEBITO
			SELECT producto INTO v_sNumProducto FROM bdicheq:sc_maechq WHERE empresa = p_sEmpresa AND cuenta = p_sNumCuenta;
		
		ELIF v_sTipoCuenta IN ('60', '65','66') THEN				--TC COPPEL
			SELECT num_producto INTO v_sNumProducto FROM bdisolic:ss_solicitudes WHERE empresa = p_sEmpresa AND num_solicitud = p_sNumCuenta;
			IF v_sNumProducto IS NULL AND v_sTipoCuenta in ('60','66') THEN
				SELECT num_producto INTO v_sNumProducto FROM bdicred:sd_maecred WHERE empresa = p_sEmpresa AND num_credito = p_sNumCuenta;
			END IF
			
		ELIF v_sTipoCuenta in ('60','66') THEN						--CUENTAS DE CREDITO					
				SELECT num_producto INTO v_sNumProducto FROM bdicred:sd_maecred WHERE empresa = p_sEmpresa AND num_credito = p_sNumCuenta;
		
		ELIF v_sTipoCuenta = '30' THEN						--CUENTAS DE INVERSION
			SELECT cod_instrum INTO v_sNumProducto FROM bdinvers:sv_maeinv WHERE empresa = p_sEmpresa AND cuenta = p_sNumCuenta;
		
		END IF
		IF v_sNumProducto is null or v_sNumProducto = ""
		THEN
		   LET v_sNumProducto = "0000";
		END IF;
		RETURN v_sNumProducto;
	END
END PROCEDURE;