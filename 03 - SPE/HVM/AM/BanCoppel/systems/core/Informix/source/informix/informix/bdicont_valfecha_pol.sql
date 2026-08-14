CREATE PROCEDURE "informix".valfecha_pol(vb_fecha    DATE,
			      vb_empresa  CHAR(3),
			      vb_fcaptura DATE)
RETURNING CHAR(5);

-- ############################################################################
-- #                        Definicion de Variables                           #
-- ############################################################################
DEFINE v_codret     CHAR(5);
DEFINE sqlerr       INTEGER;
DEFINE v_fval       DATE;
DEFINE v_Mchar      CHAR(2);
DEFINE v_Achar      CHAR(4);
DEFINE v_Achar1     CHAR(4);
DEFINE v_fchar      CHAR(10);
DEFINE v_cie1       CHAR(2);
DEFINE v_cie1r      CHAR(2);
DEFINE v_cie2       CHAR(2);
DEFINE v_pais       CHAR(2);
DEFINE v_fecha      DATE;
DEFINE v_hoy        DATE;

-- ############################################################################
-- #                        Asignacion de Variables                           #
-- ############################################################################
LET v_codret     = "000";
LET sqlerr       = 0;
LET v_fval       = "";
LET v_Mchar      = "";
LET v_Achar      = "";
LET v_Achar1     = "";
LET v_cie1       = "";
LET v_cie1r      = "";
LET v_cie2       = "";
LET v_pais       = "";
LET v_fecha      = "";
LET v_hoy        = "";
-- ############################################################################
-- #                    Control de Errores para INFORMIX                      #
-- ############################################################################
BEGIN
 ON EXCEPTION
      SET sqlerr
      LET v_codret = sqlerr;
      RETURN v_codret;
 END EXCEPTION;



-- ############################################################################
-- #                              Codigo Principal                            #
-- ############################################################################

SELECT pais INTO v_pais FROM bdinteg:si_param
WHERE  empresa = vb_empresa;

SELECT fecha_hoy INTO v_hoy FROM co_fechas
 WHERE empresa = vb_empresa;

SELECT fecha INTO v_fecha FROM bdinteg:si_feriado
 WHERE pais = v_pais
   AND fecha = vb_fecha
   AND empresa = vb_empresa;
IF v_fecha IS NOT NULL THEN
	LET v_codret = "999";
	RETURN v_codret;
END IF

SELECT mescierre1, mescierre1, mescierre2 INTO v_cie1, v_cie1r, v_cie2
  FROM co_param
 WHERE empresa = vb_empresa;


IF v_cie1 = v_cie2 THEN
	-- Para determinar si es el mismo anio
	LET v_fchar  = v_hoy;
	LET v_Achar1 = v_fchar[7,10];
	LET v_fchar  = vb_fecha;
	LET v_Achar  = v_fchar[7,10];
	IF v_Achar <> v_Achar1 THEN
	        LET v_fchar = vb_fecha ;
        	LET v_Achar = v_fchar[7,10];
		LET v_fchar = "12/01/" || v_Achar;
		LET v_fval  = v_fchar;
		LET v_fval  = v_fval + 1 UNITS MONTH;
		LET v_fval  = v_fval - 1 UNITS DAY;
		LET v_fval  = v_fval;
		IF v_fval > vb_fecha THEN
			LET v_codret = "999";
		END IF
		RETURN v_codret;
	ELSE
		RETURN v_codret;
	END IF
END IF

LET v_fchar = vb_fecha;
LET v_Mchar = v_fchar[2,2];

LET v_fchar  = v_hoy;
LET v_Achar1 = v_fchar[7,10];
LET v_fchar  = vb_fecha;
LET v_Achar  = v_fchar[7,10];

IF v_cie1 < v_Mchar AND v_Achar = v_Achar1 THEN
	LET v_fchar = TRIM(v_cie1) || "/01/" || v_Achar;
	LET v_fval  = v_fchar;
	LET v_fval  = v_fval + 1 UNITS MONTH;
	LET v_fval  = v_fval - 1 UNITS DAY;
	LET v_fval  = v_fval;
	IF v_fval <> vb_fecha THEN
		LET v_codret ="999";
		RETURN v_codret;
	END IF
END IF

IF v_cie1 < v_Mchar AND v_Achar <> v_Achar1 THEN
	IF v_cie1 < v_cie2 THEN
		LET v_fchar = TRIM(v_cie1) || "/01/" || v_Achar1;
		LET v_fval  = v_fchar;
		LET v_fval  = v_fval + 1 UNITS MONTH;
		LET v_fval  = v_fval - 1 UNITS DAY;
		LET v_fval  = v_fval;
		IF v_fval <> vb_fecha THEN
			LET v_codret = "999";
			RETURN v_codret;
		END IF
	ELSE
                LET v_fchar = TRIM(v_cie2) || "/01/" || v_Achar1;
                LET v_fval  = v_fchar;
                LET v_fval  = v_fval + 1 UNITS MONTH;
                LET v_fval  = v_fval - 1 UNITS DAY;
                LET v_fval  = v_fval;
                IF v_fval <> vb_fecha THEN
                        LET v_codret = "999";
                        RETURN v_codret;
                END IF
	END IF
END IF


IF v_cie1 > v_Mchar AND v_Achar = v_Achar1 THEN
	IF v_cie1 > v_cie2 THEN
		LET v_fchar = TRIM(v_cie2) || "/01/" || v_Achar1;
		LET v_fval  = v_fchar;
		LET v_fval  = v_fval + 1 UNITS YEAR;
		LET v_fval  = v_fval + 1 UNITS MONTH;
		LET v_fval  = v_fval - 1 UNITS DAY;
		IF vb_fecha > v_fval THEN
			LET v_codret = "999";
			RETURN v_codret;
		END IF
	ELSE
		LET v_fchar = TRIM(v_cie1) || "/01/" || v_Achar1;
		LET v_fval  = v_fchar;
		LET v_fval  = v_fval + 1 UNITS YEAR;
		LET v_fval  = v_fval + 1 UNITS MONTH;
		LET v_fval  = v_fval - 1 UNITS DAY;
		IF vb_fecha > v_fval THEN
			LET v_codret = "999";
			RETURN v_codret;
		END IF
	END IF
END IF




IF WEEKDAY(vb_fecha) = 0 OR WEEKDAY(vb_fecha) = 6 THEN
        LET v_codret = "999";
        RETURN v_codret;
END IF

END
RETURN v_codret;
END PROCEDURE

DOCUMENT
"Este spl se encarga de valida de fecha de captura de la poliza          ",
"Se prohibe la distribucion total o parcial de este programa sin la",
"autorizacion de GRUPO PISA",
"Realizado por : AXEL el 20/08/2001" ;

CREATE PROCEDURE "informix".valida_archivo_importa(p_archivo CHAR(100),p_fecha_hoy DATE)
         RETURNING CHAR(5);

   DEFINE cod_ret      CHAR(5);
   DEFINE sql_err      INTEGER;
   DEFINE isam_err     INTEGER;
   DEFINE error_info   CHAR(40);
   DEFINE v_valida     INTEGER;

     ON EXCEPTION SET sql_err, isam_err, error_info
         LET cod_ret = sql_err;
         
         RETURN cod_ret;
     END EXCEPTION;

  
   LET v_valida = 0;
   LET cod_ret = "000";

   SELECT COUNT(*) INTO v_valida
   FROM bdicont:co_archivos
   WHERE bdicont:co_archivos.archivo = p_archivo
   AND bdicont:co_archivos.fecha = p_fecha_hoy;


   IF v_valida > 0 THEN
      LET cod_ret = "143";
      RETURN cod_ret;
   END IF;

   RETURN cod_ret;

END PROCEDURE;