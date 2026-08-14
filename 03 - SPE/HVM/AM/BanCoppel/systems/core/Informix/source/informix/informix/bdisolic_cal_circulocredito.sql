CREATE PROCEDURE "informix".cal_circulocredito(o_empresa CHAR(3),
                                    o_numcte  CHAR(20))


RETURNING CHAR(5), 	-- Codigo de Retorno
	  CHAR(1),	-- Calificacion 1 Aprobado, 0 Rechazado
	  DECIMAL(14,2),-- Compromisos > 0 si Calificacion es 1
	  VARCHAR(255); -- Descripcion de Creditos Motivo de Rechazo

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE s_califica   CHAR(1);
DEFINE s_compromisos DECIMAL(14,2);
DEFINE vStatus	    CHAR(2);
DEFINE vStatusAnt   CHAR(2);
DEFINE vMensaje     VARCHAR(255);
DEFINE vCuantos     SMALLINT;
DEFINE vMoneda      CHAR(2);
DEFINE vMonto       DECIMAL(14,2);
DEFINE vMontoUdis   DECIMAL(14,2);
DEFINE vCodUdi      CHAR(2);
DEFINE vCodUs       CHAR(2);
DEFINE vTpCambioUdi DECIMAL(14,6);
DEFINE vTpCambioUs  DECIMAL(14,6);
DEFINE vMaxMtoUdi   DECIMAL(14,2);
DEFINE vTl11		CHAR(1);
DEFINE vTl26		CHAR(2);
DEFINE vTl30		CHAR(2);
define vRespuesta   integer;

--SET DEBUG FILE TO "/pisa/leo/cal_circulo.out";
--TRACE ON;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret      = "000";
LET vsqlerr       = 0;
LET s_califica    = "X";
LET s_compromisos = 0;
LET vStatus       = "";
LET vStatusAnt    = "";
LET vMontoUdis    = 0;

SELECT TRIM(valor) INTO vCodUdi
  FROM bdinteg:si_param
 WHERE empresa = o_empresa
   AND cod_param = 16;

SELECT precio_venta INTO vTpCambioUdi
  FROM bdinteg:si_tpcambio
 WHERE empresa = o_empresa
   AND divisa = vCodUdi
   AND clase_tpcambio = "O"
   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                           FROM bdinteg:si_tpcambio
                          WHERE empresa = o_empresa
                            AND divisa = vCodUdi);


SELECT TRIM(valor) INTO vCodUs
  FROM bdinteg:si_param
 WHERE empresa = o_empresa
   AND cod_param = 17;

SELECT precio_venta INTO vTpCambioUs
  FROM bdinteg:si_tpcambio
 WHERE empresa = o_empresa
   AND divisa = vCodUs
   AND clase_tpcambio = "O"
   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
                           FROM bdinteg:si_tpcambio
                          WHERE empresa = o_empresa
                            AND divisa = vCodUs);

SELECT valor INTO vMaxMtoUdi
  FROM ss_param
 WHERE empresa = o_empresa
   AND secuencia = "309";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
      LET scod_ret = sql_err;
      RETURN scod_ret, s_califica, s_compromisos, vMensaje;
   END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	-- *******************+*********************************
	-- Determina si el Cliente tiene creditos inaceptables *
	-- *****************************************************
	LET vCuantos = 0;
	LET vMensaje = "Creditos con Claves de Prevencion:";
	FOREACH SELECT b.tl30 INTO vStatus
          	  FROM ss_circulo_status a, bdiburo:br_tl b
         	 WHERE b.num_cliente  = o_numcte
           	   AND a.status = b.tl30
           	   AND a.rango_rechazo = "1"

		LET vCuantos = vCuantos + 1;

		IF vStatus <> vStatusAnt THEN
			LET vMensaje = TRIM(vMensaje) || ' ' || TRIM(vStatus);
			LET vStatusAnt = vStatus;
		END IF

	END FOREACH

	IF vCuantos > 0 THEN
		LET s_califica = "1";
      		RETURN scod_ret, s_califica, s_compromisos, vMensaje;
	END IF

	-- *****************************************************
	-- Determina si el Cliente tiene creditos inaceptables *
	-- por status de circulo de credito	               *
	-- *****************************************************
	LET vCuantos = 0;
	LET vMensaje = "Creditos con Antecedentes en circulo de Credito:";
	FOREACH SELECT tl11,tl26, tl30 INTO vTl11,vTl26, vTl30
          	  FROM bdiburo:br_tl b
         	 WHERE b.num_cliente  = o_numcte
 --        	  AND NVL(tl11,'') <> ''                  -- finalidad de descartar los creditos de los cuales requiere una
         	  AND NVL(tl26,'') <> ''                  --una autorizacion del analista


          let vRespuesta = 0;
          SELECT count(*)
            into vRespuesta
            FROM ss_circulo_status
           WHERE status = vTl30              -- se agrega la validacion del status
             AND rango_rechazo in ('2','3');     --  y el rango de rechazo sea diferente de 2 con la

         if vRespuesta is null or vRespuesta = 0 then
            IF NOT EXISTS(SELECT * FROM ss_circulo_exceppago
                          WHERE empresa=o_empresa
                          AND status <> 0
                          AND frecpago = vTl11
                          AND perpago = vTl26) THEN

                LET vCuantos = vCuantos + 1;
                LET vMensaje = TRIM(vMensaje)
                               || ' F:' || TRIM(vTl11)
                               || ' P:' || TRIM(vTl26);
            END IF;
         end if;

	END FOREACH

	IF vCuantos > 0 THEN
		LET s_califica = "1";
      		RETURN scod_ret, s_califica, s_compromisos, vMensaje;
	END IF
	-- *******************+**************************************
	-- Determina si el Cliente tiene creditos con los cuales se *
	-- requiera una autorizacion de analista		    *
	-- *******************+***************************************
        LET vCuantos = 0;
        FOREACH SELECT b.tl30 INTO vStatus        -- SELECT b.tl07 INTO vStatus
                  FROM ss_circulo_status a, bdiburo:br_tl b
                 WHERE b.num_cliente  = o_numcte
                   AND a.status = b.tl30          -- se modifica a.status = b.tl07
                   AND a.rango_rechazo = "2"

                LET vCuantos = vCuantos + 1;

                IF vStatus <> VstatusAnt THEN
                        LET vMensaje = TRIM(vMensaje) || ' ' || TRIM(vStatus);
                        LET vStatusAnt = vStatus;
                END IF

        END FOREACH

        IF vCuantos > 0 THEN
                LET s_califica = "2";
        END IF

        -- **************************************************************
        -- Determina creditos que se encuentren en status con rango de *
	-- rechazo 3 y no excedan del monto en udis determinado		*
        -- **************************************************************
        LET vCuantos = 0;
	--- se modifica el FOREACH en el campo vMonto para la condicion de la sumatoria

        SELECT round(SUM(CASE WHEN b.tl30 <> 'CV' AND tl08 = 'N$' OR tl08 = 'MX' THEN ((nvl(b.tl36,0) + nvl(b.tl24,0)) * factor)/vTpCambioUdi
                                ELSE CASE WHEN b.tl36 <> 0.00 AND tl08 = 'N$' OR tl08 = 'MX' THEN (nvl(b.tl36,0)* factor)/vTpCambioUdi
                                           ELSE CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN (nvl(b.tl21,0)* factor)/vTpCambioUdi 
                                                      ELSE 0 END END
                           END +
                           CASE WHEN b.tl30 <> 'CV' AND tl08 = 'US' THEN (((nvl(b.tl36,0) + nvl(b.tl24,0))* vTpCambioUs) * factor) /vTpCambioUdi
                                ELSE CASE WHEN b.tl36 <> 0.00 AND tl08 = 'US' THEN (nvl(b.tl36,0) * vTpCambioUs) * factor/vTpCambioUdi
                                          ELSE CASE WHEN tl08 = 'US' THEN (nvl(b.tl21,0) * vTpCambioUs) * factor/vTpCambioUdi 
                                                    ELSE 0 END END
                           END +
                           CASE WHEN b.tl30 <> 'CV' AND tl08 = 'UD' THEN (nvl(b.tl36,0) + nvl(b.tl24,0)) * factor
                                ELSE CASE WHEN b.tl36 <> 0.00 AND tl08 = 'UD' THEN nvl(b.tl36,0) * factor
                                           ELSE CASE WHEN tl08 = 'UD' THEN nvl(b.tl21,0) * factor 
                                                     ELSE 0 END END  
                           END),2)
        INTO vMontoUdis 
        FROM bdisolic:ss_circulo_status a, bdiburo:br_tl b, bdisolic:ss_circulo_frecpag c 
        WHERE b.num_cliente  = o_numcte
        AND a.status = b.tl30  -- se modifica a.status = b.tl07
        AND b.tl11 = c.tipo
        AND a.rango_rechazo = "3"
        AND tl02 <> 'SIC';

	IF vMontoUdis > vMaxMtoUdi THEN
		LET s_califica = "1";
		LET vMensaje = TRIM(vMensaje) || "Mto Max Udi:" || vMaxMtoUdi ||
			       "Mto Udi Cte:" || vMontoUdis;
      		RETURN scod_ret, s_califica, s_compromisos, vMensaje;
	END IF

        IF vCuantos > 0 AND s_califica = "2" THEN
                LET s_califica = "4";
	ELIF vCuantos > 0 AND s_califica = "0" THEN
		LET s_califica = "3";
        END IF

        -- *************************************
        -- Determina Obligaciones del cliente  *
        -- *************************************


    SELECT round(nvl(sum(case when tl08 = 'N$' or tl08 = 'MX'  then tl12 * b.factor  else 0 end),0) +
           nvl(sum(case when tl08 = 'UD' then (tl12 * b.factor) * vTpCambioUdi else 0 end),0) +
           nvl(sum(case when tl08 = 'US' then (tl12 * b.factor) * vTpCambioUs else 0 end),0),2),
           count(*)
    INTO s_compromisos, vCuantos
    FROM bdiburo:br_tl a, bdisolic:ss_circulo_frecpag b
    WHERE a.tl11 = b.tipo
    AND num_cliente = o_numcte 
    AND tl02 <> 'SIC';


	IF s_compromisos IS NULL THEN
		LET s_compromisos = 0;
	END IF


	IF vCuantos > 0 AND s_califica = "X" THEN
		LET s_califica = "0";
	END IF


	IF s_califica = "0" THEN
		LET vMensaje ="BUEN COMPORTAMIENTO EN CIRCULO DE CREDITO ";
	ELIF s_califica = "X" THEN
		LET vMensaje ="COMPORTAMIENTO NULO EN CIRCULO DE CREDITO ";
	END IF

END
      RETURN scod_ret, s_califica, s_compromisos, vMensaje;

END PROCEDURE
;