CREATE PROCEDURE "informix".sp_set_statustoken_admtoken(pNumToken char(9), pStatusViejo char(3), pStatusNuevo char(3), pUsrAtendio char(9),pCanal char(2))
   returning char(5) ;

--------------------------------------------------------------------------------------------
-- Realizó: Pedro Enrique Zavala Valdez
-- Actividad: Actualiza el estatus del token del AdmToken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 10/11/2009

---------------------------------------------------------------------------------------------
--Realizo: Francisco Rodríguez Ibarra
--Modificación:Se modifico para agregar el canal en la tkn_series y tkn_status_token.
--Solicito: Jorge Nuñez
--Fecha:28/09/2010
---------------------------------------------------------------------------------------------
--Realizo: Berenice Noriega Guevara
--Modificación:Se modifico para que en caso de que sea desbloqueo (160) grabe en las tablas (140).
--Fecha:11/05/2012
---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    
    DEFINE sql_err integer ;
    DEFINE cod_ret char(5);
    
   
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
    LET cod_ret  = '000';
    

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

    
    IF EXISTS(SELECT ns_token FROM bdibpi:tkn_nseries WHERE ns_token = pNumToken AND id_status = pStatusViejo) THEN
      IF pStatusNuevo='160' THEN --Cuando es desploqueo guardara en la tkn_nseries 140
	  UPDATE bdibpi:tkn_nseries 
        SET id_status = '140', f_status = current ,canal=pCanal
        WHERE ns_token = pNumToken AND id_status = pStatusViejo; 
		--insertara el 160 152 para que quede evidencia del desbloqueo,y 140 160 para que exista correspondencia
        INSERT INTO bdibpi:tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
        VALUES(pNumToken, pStatusViejo, pStatusNuevo, CURRENT, pUsrAtendio,pCanal);
	  INSERT INTO bdibpi:tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
        VALUES(pNumToken, pStatusNuevo, '140', CURRENT, pUsrAtendio,pCanal);

	ELSE
	  UPDATE bdibpi:tkn_nseries 
        SET id_status = pStatusNuevo, f_status = current ,canal=pCanal
        WHERE ns_token = pNumToken AND id_status = pStatusViejo; 

        INSERT INTO bdibpi:tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
        VALUES(pNumToken, pStatusViejo, pStatusNuevo, CURRENT, pUsrAtendio,pCanal);
	END IF;

    ELSE
        LET cod_ret = '001'; -- No se encontro token con el estatus indicado
    END IF;
    
    RETURN cod_ret;
   
END

END PROCEDURE ;