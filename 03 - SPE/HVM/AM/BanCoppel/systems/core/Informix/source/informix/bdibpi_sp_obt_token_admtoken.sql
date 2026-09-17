CREATE PROCEDURE "informix".sp_obt_token_admtoken(pStatus char(3), pRegistros smallint )
   returning char(5), char(3), char(9) ;

--------------------------------------------------------------------------------------------
-- Realizó: Pedro Enrique Zavala Valdez
-- Actividad: Obtiene los números de serie de tokens dependiendo de su estatus del AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 10/11/2009

---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    
    DEFINE sql_err integer ;
    DEFINE cod_ret char(5);
    DEFINE vNumToken  char(9);
   
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET cod_ret  = '000';
    LET vNumToken = '';

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, pStatus, vNumToken;
      END IF ;
   END EXCEPTION ;

    
    FOREACH
	
        SELECT SKIP pRegistros FIRST 10 ns_token 
        INTO vNumToken
        FROM bdibpi:tkn_nseries
        WHERE id_status = pStatus
        ORDER BY ns_token ASC

        RETURN cod_ret, pStatus, vNumToken WITH RESUME;
		
    END FOREACH;

    IF (vNumToken='') THEN
    
        LET cod_ret = '001'; -- No se encontro token con el estatus indicado
        RETURN cod_ret, pStatus, vNumToken;
    END IF;

END

END PROCEDURE ;