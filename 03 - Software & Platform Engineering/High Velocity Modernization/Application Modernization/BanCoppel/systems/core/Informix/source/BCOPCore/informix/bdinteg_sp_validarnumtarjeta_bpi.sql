CREATE PROCEDURE "informix".sp_validarnumtarjeta_bpi(pEmpresa char(3), pNumCte char(9), pNumTarjeta char(16))
   returning char(5);

--------------------------------------------------------------------------------------------
-- Realizó: Javier Calderón
-- Actividad: Valida el numero de cliente o tarjeta de debito o credito
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 10/12/2009
---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret = "000";

--set debug file to "/tmp/sp_validarnumcteotarjeta_bpi.out";
--trace on;

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF;
   END exception;

   SET ISOLATION DIRTY READ ;
   SET LOCK mode TO wait 3;   
	IF EXISTS(SELECT mc.num_credito
			  FROM bdicred:sd_maecred mc
			  JOIN bdicred:sd_tarjeta tr on (tr.empresa = pEmpresa and mc.num_credito = tr.num_credito and tipo_tarjeta = 'T' and secuencia = (select max(secuencia) from bdicred:sd_tarjeta where empresa = pEmpresa and mc.num_credito = num_credito and tipo_tarjeta = 'T'))
			  WHERE mc.numcte = pNumCte AND tr.num_tarjeta = pNumTarjeta) THEN				
		RETURN cod_ret;
	END IF;
			
	IF EXISTS(SELECT mc.cuenta
			  FROM bdicheq:sc_maechq mc
			  JOIN bdicheq:sc_tarjeta tr on (tr.empresa = pEmpresa and mc.cuenta = tr.cuenta and tipo_tarjeta = 'T' and secuencia = (select max(secuencia) from bdicheq:sc_tarjeta where empresa = pEmpresa and mc.cuenta = cuenta and tipo_tarjeta = 'T'))
			  WHERE mc.num_cte = pNumCte AND tr.num_tarjeta = pNumTarjeta) THEN
		RETURN cod_ret;
	END IF;
			
	LET cod_ret = '001'; --Numero de tarjeta invalido
	RETURN cod_ret;


END
END PROCEDURE ;