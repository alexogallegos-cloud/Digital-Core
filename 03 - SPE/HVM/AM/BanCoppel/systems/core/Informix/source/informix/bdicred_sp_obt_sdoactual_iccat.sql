CREATE PROCEDURE "informix".sp_obt_sdoactual_iccat(pEmpresa char(3), pCuenta char(20))
   returning char(5), MONEY(14, 2);

--------------------------------------------------------------------------------------------
-- Realizó: Mauricio León
-- Actividad: Obtiene el saldo al día de hoy del nùmero de crédito
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 26/11/2008
---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE vSdoActual money(14, 2);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret  = "000";
   LET vSdoActual = 0;


BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vSdoActual;
      END IF ;
   END EXCEPTION ;


   IF EXISTS ( SELECT num_credito FROM bdicred:sd_maesdos WHERE empresa = pEmpresa AND num_credito = pCuenta ) THEN

        SELECT sdo_cap_insoluto INTO vSdoActual FROM bdicred:sd_maesdos WHERE empresa = pEmpresa AND num_credito = pCuenta;

   ELSE

        LET cod_ret = '001';  -- No existe el numero de credito

   END IF ;

   RETURN cod_ret, vSdoActual;

END

END PROCEDURE ;