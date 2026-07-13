CREATE PROCEDURE "informix".sp_obt_num_solicitudes_act_admtoken()
   returning char(5), char(9);

--------------------------------------------------------------------------------------------
-- Realizó: Pedro Enrique Zavala Valdez
-- Actividad: Obtiene el número de solicitudes dependiendo de su estatus del AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 11/11/2009

---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    
    DEFINE sql_err integer ;
    DEFINE cod_ret char(5);
    DEFINE vNumSolicitudes  char(9);
   
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET cod_ret  = '000';
    LET vNumSolicitudes = '';

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vNumSolicitudes;
      END IF ;
   END EXCEPTION ;

    SELECT COUNT (solicitud) INTO vNumSolicitudes FROM bpi_tokensolicitud WHERE id_status IN (100,180) AND tipo IN ( 1,2);    

    IF (vNumSolicitudes='0') THEN
        LET cod_ret = '001'; -- No se encontro solicitudes con el estatus indicado
    END IF;

    RETURN cod_ret, vNumSolicitudes;

END

END PROCEDURE ;