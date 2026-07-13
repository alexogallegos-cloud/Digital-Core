create procedure "informix".spobtentipocambio(pFecha date,pDivisa char(2))
	returning char(5),money(12,7);

define sql_err integer;
define v_preco money(12,7);
define cod_ret char(5);
let v_preco = 0;
begin
   on exception set sql_err
      if sql_err <> 0 then
	 let cod_ret = sql_err;
         return cod_ret,v_preco;
      end if
   end exception;

let cod_ret="000";

SELECT precio_compra
	INTO v_preco
	FROM si_tpcambio
	WHERE divisa = pDivisa AND clase_tpcambio="O"
	AND fecha_tpcambio = pFecha;

if v_preco is null then
	let cod_ret="100";
end if;
return cod_ret,v_preco;
end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".spobtentipocambiohist(pFecha date,pDivisa char(2))
	returning char(5),money(12,7);

define sql_err integer;
define v_preco money(12,7);
define cod_ret char(5);
let v_preco = 0;
begin
   on exception set sql_err
      if sql_err <> 0 then
	 let cod_ret = sql_err;
         return cod_ret,v_preco;
      end if
   end exception;

let cod_ret="000";

SELECT precio_compra
	INTO v_preco
	FROM si_histdiv
	WHERE divisa = pDivisa AND clase_tpcambio="O"
	AND fecha_tc = pFecha;

if v_preco is null then
	let cod_ret="100";
end if;
return cod_ret,v_preco;
end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".ctefisicomel(pempresa CHAR(3),
                          pfuncion CHAR(1),
			  pnumcte CHAR(20),
			  psucursal CHAR(4))
  RETURNING CHAR(5),CHAR(20);

DEFINE vcodret CHAR(5);
DEFINE vtutor,vnumcte CHAR(20);
DEFINE vfecha DATE;
DEFINE vsignumcte INT;
DEFINE vtppersona CHAR(2);
DEFINE vexiste CHAR(1);
DEFINE vcont SMALLINT;
DEFINE vesfisica CHAR(1);
DEFINE vlongitud,vlong_cte SMALLINT;
DEFINE vsucursal CHAR(4);
define vdiferencia,i smallint;


LET vcodret = "000";
LET vnumcte = " ";
LET vsucursal = psucursal;


IF pnumcte IS NULL OR pnumcte = " " THEN
   SELECT valor
     INTO vlong_cte
     FROM si_param
    WHERE cod_param = 7
      AND empresa = pempresa;

   IF vlong_cte IS NULL THEN
      LET vcodret="105";
      RETURN vcodret,vnumcte;
   ELSE
      SELECT valor INTO vsignumcte
         FROM si_param
         WHERE empresa = pempresa and cod_param = 6;
      if vsignumcte is null then
         let vsignumcte = 1;
      end if
      LET vnumcte=vsignumcte;
      LET vsignumcte=vsignumcte + 1;
      UPDATE si_param
         SET (valor) = (vsignumcte)
         WHERE empresa = pempresa and cod_param = 6;
      let vdiferencia = vlong_cte - length(vnumcte);
      if vdiferencia > 0 then
         for i = 1 to vdiferencia
             let vnumcte = "0" || vnumcte;
         end for;
      end if
   END IF;
ELSE
   LET vnumcte = pnumcte;
END IF;
RETURN vcodret,vnumcte;
END PROCEDURE
DOCUMENT
"Alta, Baja y/o Cambio de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".splvalfecha(pCodPais 	  CHAR(3),
			    		pPriDiaNaturalMes DATE,
					pDiasBloque       integer)
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque

-- ***************************************************************************
-- splvalfecha          
-- Version              1.0.0
-- Obejtivo:            Calcula la fecha del mes actual FechaIniMes + DiasBloque - 1
--                      donde Días bloque son número de días hábiles del mes
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima ModIFicacion: Agosto-2006
--                      Creación de SPL
-- ***************************************************************************

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet          CHAR(5);
DEFINE dFechaActual        DATE;
DEFINE i,j              INTEGER;
DEFINE siFeriado        INTEGER;




BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;

    --// ********************************************************************
    --// Calcula dia por dia si es habil, hasta completar el bloque


    LET i = 0;
    LET j = 0;	
    WHILE i <= pDiasBloque 
	LET dFechaActual = pPriDiaNaturalMes + j;
	LET siFeriado = 0;

	IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
           SELECT COUNT(*) 
	     INTO siFeriado       
	    FROM si_feriado
	    WHERE fecha = dFechaActual
	     AND pais = pCodPais and laborable = "N";
	   IF siFeriado IS NULL OR siFeriado = 0 THEN
	     LET i = i + 1;
	   END IF;
	END IF;
	LET j = j + 1;
    END WHILE


   RETURN '000',dFechaActual;
END
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".determina_lincred_tc(o_empresa CHAR(3),
                                      o_numsol  CHAR(20),
			              o_cte_nvo CHAR(1))


RETURNING CHAR(5), MONEY(14,2);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret          CHAR(3);
DEFINE vsqlerr           INTEGER;
DEFINE v_tasa            DECIMAL(9,6);
DEFINE v_factor	         CHAR(1);
DEFINE v_sobretasa       DECIMAL(9,6);
DEFINE v_porc_linea      DECIMAL(6,3);
DEFINE v_salariomin      DECIMAL(14,2);
DEFINE v_porcsalmin      DECIMAL(6,3);
DEFINE v_paramfactor     SMALLINT;
DEFINE v_ingreso         MONEY(14,2);
DEFINE v_situacion       DECIMAL(6,3);
DEFINE v_meseshist       SMALLINT;
DEFINE v_comproboingreso SMALLINT;
DEFINE v_porcpermitido   DECIMAL(6,3);
DEFINE v_mesespermitido  SMALLINT;
DEFINE v_capacidad       MONEY(14,2);
DEFINE v_linea      	 MONEY(14,2);
DEFINE v_factor_calc     DECIMAL(21,10);
DEFINE v_compromisos     MONEY(14,2);
DEFINE v_lintienda       MONEY(14,2);
DEFINE v_plazo		 SMALLINT;
DEFINE v_elevado         DECIMAL(21,6);
DEFINE v_moneypaso       MONEY(14,2);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_plazo      = 12;
LET v_linea      = 0;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, v_linea;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


	-- **************************************************
	-- Extrae Parametros para la definicion de la Linea *
	-- **************************************************
	SELECT valor INTO v_porcpermitido -- Porcentaje de Situacion de pago
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 307;

	IF v_porcpermitido IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	SELECT valor INTO v_mesespermitido -- Meses de Historia base
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 308;

	IF v_mesespermitido IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	SELECT valor INTO v_salariomin -- Salario Minimo Base
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 303;

	IF v_salariomin IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	-- *******************************************
	-- Extrae Porcentaje de ingresos del cliente *
	-- *******************************************
	IF o_cte_nvo = 1 THEN
	    LET v_paramfactor = 302; -- Cliente Nuevo
	ELSE
	    LET v_paramfactor = 301; -- Cliente No Nuevo
	END IF

	SELECT valor / 100 INTO v_porcsalmin
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = v_paramfactor;

	IF v_porcsalmin IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************
        SELECT ingreso_mensual, situacion_pago, meses_historia , pago_minimo,
	       linea_tienda
	  INTO v_ingreso, v_situacion, v_meseshist, v_compromisos, v_lintienda
          FROM ss_resum_scor_fin
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;

        IF v_ingreso IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

        IF v_compromisos IS NULL THEN
		LET v_compromisos = 0;
        END IF

        IF v_situacion IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

        IF v_meseshist IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

        IF v_lintienda IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************

	SELECT COUNT(*) INTO v_comproboingreso
	  FROM ss_detalle_scoring
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol
	   AND seccion = 2
	   AND grupo = 14
	   AND elemento = 1;

	IF v_comproboingreso IS NULL THEN
		LET v_comproboingreso = 0;
	END IF

        -- *************************************
        -- Extrae Tasa de interes del producto *
        -- *************************************

	SELECT valor, c.factor_sobretasa, c.sobretasa
	  INTO v_tasa, v_factor, v_sobretasa
	  FROM ss_solicitudes a, bdinteg:si_fechavalor b,
	       bdicred:sd_definicion c
	 WHERE a.empresa = o_empresa
	   AND a.num_solicitud = o_numsol
	   AND c.empresa = a.empresa
	   AND c.num_producto = a.num_producto
	   AND b.empresa = c.empresa
	   AND b.tasa = c.cod_tasa_base
           AND b.fecha = (select max(fecha) from bdinteg:si_fechavalor s
                          where s.tasa = c.cod_tasa_base);




        IF v_tasa IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

	IF v_factor = "+" THEN
		LET v_tasa = v_tasa + v_sobretasa;
	ELIF v_factor = "-" THEN
		LET v_tasa = v_tasa - v_sobretasa;
	ELIF v_factor = "*" THEN
		LET v_tasa = v_tasa * v_sobretasa;
	ELSE
		LET v_tasa = v_tasa / v_sobretasa;
	END IF

        -- **********************************************************
        -- Extrae Porcentajes de Otorgamiento de Linea de acuerdo a *
        -- a caracteristicas del cliente			    *
        -- **********************************************************
	IF  v_situacion >= v_porcpermitido
        AND v_meseshist >= v_mesespermitido THEN
		SELECT valor / 100 INTO v_porc_linea
		  FROM ss_param
		 WHERE empresa = o_empresa
		   AND secuencia = 304;
	ELSE

		IF  v_situacion >= v_porcpermitido
        	AND v_meseshist <= v_mesespermitido
        	AND v_comproboingreso = 1 THEN
			SELECT valor / 100 INTO v_porc_linea
		  	  FROM ss_param
		 	 WHERE empresa = o_empresa
		   	   AND secuencia = 305;
		ELSE
			SELECT valor / 100 INTO v_porc_linea
		  	  FROM ss_param
		 	 WHERE empresa = o_empresa
		   	   AND secuencia = 306;
		END IF
	END IF
        IF v_porc_linea IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

	-- ************************************
	-- Inicia Proceso de Calculo de Linea *
	-- ************************************
	LET v_capacidad = ((v_ingreso * v_porcsalmin) - v_compromisos)
			  * v_porc_linea;

	LET v_factor_calc=POW(ROUND(((v_tasa/100)/v_plazo)+1,10),(v_plazo*-1));
	LET v_factor_calc = 1-(v_factor_calc);
	LET v_linea =(v_capacidad * v_factor_calc) / ((v_tasa/100)/v_plazo);

        -- **********************************************************
        -- Valida Porcentajes de Otorgamiento de Linea de acuerdo a *
        -- a caracteristicas del cliente                            *
        -- **********************************************************
        IF  v_situacion >= v_porcpermitido
        AND v_meseshist >= v_mesespermitido THEN
                SELECT valor / 100 INTO v_porc_linea
                  FROM ss_param
                 WHERE empresa = o_empresa
                   AND secuencia = 304;

	        IF v_porc_linea IS NULL THEN
        	        LET scod_ret = "100";
                	RETURN scod_ret, v_linea;
        	END IF

		LET v_moneypaso = v_linea * v_porc_linea;
		IF v_lintienda < v_moneypaso THEN
			LET v_linea = v_lintienda;
			LET v_moneypaso = v_salariomin * 15;
			IF v_linea > v_moneypaso THEN
				LET v_linea = v_moneypaso;
			END IF
		ELSE
			LET v_linea = v_moneypaso;
			LET v_moneypaso = v_salariomin * 15;
			IF v_linea > v_moneypaso THEN
				LET v_linea = v_moneypaso;
			END IF
		END IF
        ELSE
                IF  v_situacion >= v_porcpermitido
                AND v_meseshist <= v_mesespermitido
                AND v_comproboingreso = 1 THEN
                        SELECT valor / 100 INTO v_porc_linea
                          FROM ss_param
                         WHERE empresa = o_empresa
                           AND secuencia = 305;

        	     IF v_porc_linea IS NULL THEN
                	LET scod_ret = "100";
                	RETURN scod_ret, v_linea;
        	     END IF

                     IF (v_linea * v_porc_linea) > (v_salariomin * 4) THEN
                   	LET v_linea  = v_salariomin * 4;
                     ELSE
                        LET v_linea = v_linea * v_porc_linea;
                     END IF

                ELSE
                     SELECT valor / 100 INTO v_porc_linea
                       FROM ss_param
                      WHERE empresa = o_empresa
                        AND secuencia = 306;

                     IF v_porc_linea IS NULL THEN
                          LET scod_ret = "100";
                          RETURN scod_ret, v_linea;
                     END IF

                     IF (v_linea * v_porc_linea) > (v_salariomin * 2) THEN
                   	 LET v_linea  = v_salariomin * 2;
                     ELSE
                         LET v_linea = v_linea * v_porc_linea;
                     END IF
                END IF
        END IF


	LET v_linea = ROUND(v_linea,-1);

END
	RETURN scod_ret, v_linea;

END PROCEDURE
;