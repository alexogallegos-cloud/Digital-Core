CREATE PROCEDURE "informix".sp_consultafoliocontratobpi(pEmpresa CHAR(3), pNumCte CHAR(20))

--DATOS A REGRESAR---
RETURNING
CHAR(5), -- Codigo de Retorno
CHAR(12); -- Folio de contrato

--DEFINICION DE VARIABLES--
DEFINE sql_err INT;
DEFINE vCodRet CHAR(5);
DEFINE vFolio CHAR(12);

--INICIALIZACION DE VARIABLES--
LET sql_err = 0;
LET vCodRet = '000';
LET vFolio = '';

--SET DEBUG FILE TO "/respaldosbd/Daniela/SP_consultafoliocontratobpi.out";
--TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vCodRet = sql_err;
            RETURN vCodRet, vFolio;
        END IF;
    END EXCEPTION;
		
    SET LOCK MODE TO WAIT 3;

    IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte) THEN

        SELECT folio_contrato INTO vFolio FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte AND empresa = pEmpresa;
        LET vCodRet = '000';

    ELSE

         LET vCodRet = '001'; --El cliente no tiene servicio de banca por internet

    END IF;

    RETURN vCodRet, vFolio;

END   
END PROCEDURE

DOCUMENT
'Consulta el folio de contrato de BPI',
'Autor :Daniela Ramirez',
'BD: bdibpi',
'Fecha: 16/08/2011';

CREATE PROCEDURE "informix".sp_cons_tar_divisa(pempresa    CHAR(3),
                                     psistema    SMALLINT,
                                     pcta        CHAR(20))

RETURNING CHAR(5),       -- Codigo de Retorno
	  CHAR(20),      -- TARJETA
      CHAR(5);      -- DIVISA


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_tarjeta       CHAR(20);
DEFINE s_divisa        CHAR(5);
DEFINE iSecuencia      INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = '00000';
LET vsqlerr      = 0;
LET s_tarjeta    = '';
LET s_divisa     = '';
LET iSecuencia   = 0;

--SET DEBUG FILE TO "/tmp/sp_cons_tar_divisa.out";
--TRACE ON;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_tarjeta, s_divisa;
   END IF;
END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

 -- Valida Parametros de Entrada

  IF NVL(pempresa, '') = ''  OR NVL(psistema, '') = ''  OR NVL(pcta, '') = ''  THEN
     LET scod_ret = '001';
     RETURN scod_ret, s_tarjeta, s_divisa;
  END IF

  IF psistema = 1 then -- Sistema de Cheques

          SELECT d.divisa
			INTO s_divisa
			FROM bdicheq:sc_maechq as a
			LEFT JOIN bdinteg:si_cliente as b on (a.num_cte = b.numcte)
			LEFT JOIN bdicheq:sc_producto as e on (e.producto = a.producto)
			LEFT JOIN bdinteg:si_divisas as d on (d.divisa = e.divisa)
			WHERE a.empresa = pempresa
			AND a.cuenta = pcta;

   END IF

  IF psistema = 6 then -- Sistema de Credito
        SELECT MAX(secuencia)
        INTO iSecuencia
        FROM bdicred:sd_tarjeta
        WHERE empresa = pempresa
        AND num_credito= pcta
        AND status_tar = 'A'
        AND tipo_tarjeta = 'T';

           SELECT a.num_tarjeta, f.divisa
             INTO s_tarjeta, s_divisa
             FROM bdicred:sd_tarjeta a,
                  bdinteg:si_cliente b,
                  bdicred:sd_maecred d,
                  bdinteg:si_divisas f
            WHERE a.empresa = b.empresa
                  AND a.numcte = b.numcte
                  AND d.empresa = a.empresa
                  AND d.num_credito = a.num_credito
                  AND f.empresa = d.empresa
                  AND f.divisa = d.divisa
                  AND ((a.empresa = pempresa)
                  AND (a.num_credito = pcta)
                  AND (a.status_tar = 'A')
                  AND (a.secuencia = iSecuencia));
  END IF;

  --IF NVL(s_tarjeta, '') = '' OR NVL(s_divisa, '') = ''  THEN
      --LET s_tarjeta = '';
      --LET s_divisa = '';
  --END IF;

  RETURN scod_ret, s_tarjeta, s_divisa;


END
END PROCEDURE
DOCUMENT
"Obtener el número de tarjeta y de divisa de la cuenta del cliente",
"Autor : Dulce Ramírez",
"FECHA : Noviembre de 2009",
"Ver.  : 1.0",
"BD    : bdibpi",
"VER   : 1.0",
"Se modifico para que puede regresar la divisa incluso cuando no encuentre una tarjeta en la sc_tarjeta",
"Autor : Jose Angel Rodriguez",
"FECHA : 25 Febrero de 2010",
"BD    : bdibpi",
"VER   : 20100224.1200";

CREATE PROCEDURE "informix".sp_obtenerpreguntas()
RETURNING CHAR (5), INT, CHAR(50);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene preguntas
	-- Solicitó: Diana Castellanos
	-- Fecha: 16/11/2010
	
	-- Modificado: Manuel Ramos Figueroa
	-- Descripción: Se modifica para retornar solo 5 preguntas del total con tipo igual 1
	-- Fecha: 10/11/2011

	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_pregunta INT;
	DEFINE vDesc_pregunta VARCHAR(50);
	DEFINE iIdRegistro INTEGER;
	DEFINE iOrdAle INTEGER;
	DEFINE iOrdAleAux INTEGER;

	LET cCod_ret = '00000';
	LET iId_pregunta = 0;
	LET vDesc_pregunta = '';
	LET iIdRegistro = 0;
	LET iOrdAle = 0;
	LET iOrdAleAux = 0;

	--SET DEBUG FILE TO "sp_obtenerpreguntas.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta;
		  END IF ;
		END EXCEPTION ;

		EXECUTE PROCEDURE sp_random(0, 1000) INTO iIdRegistro;

		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT id_pregunta, desc_pregunta 
			INTO iId_pregunta, vDesc_pregunta 
			FROM bdibpi:"informix".bpi_cat_preguntas 
			WHERE tipo = 1 
			AND activo = 't' 
			ORDER BY id_pregunta 

			LET iOrdAleAux = iOrdAle;
			EXECUTE PROCEDURE sp_random(iOrdAleAux, 100) INTO iOrdAle;

			INSERT INTO bdibpi:"informix".bpi_cat_preguntas_aux(id_ordenamiento, id_pregunta, desc_pregunta, id_registro) VALUES (iOrdAle, iId_pregunta, vDesc_pregunta, iIdRegistro);
		END FOREACH;

		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT LIMIT 5 id_pregunta, desc_pregunta 
			INTO iId_pregunta, vDesc_pregunta 
			FROM bdibpi:"informix".bpi_cat_preguntas_aux 
			WHERE id_registro = iIdRegistro
			ORDER BY id_ordenamiento

			RETURN cCod_ret, iId_pregunta, vDesc_pregunta WITH RESUME;
		END FOREACH;

		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdibpi:"informix".bpi_cat_preguntas_aux WHERE id_registro = iIdRegistro;
	END;
END PROCEDURE;