CREATE PROCEDURE "informix".sp_guarda_aut_manc_bei_historico(pIdUser INTEGER, 
                                pNumCte CHAR(9), 
                                pNumCta CHAR(16), 
                                pAutoriza CHAR(1), 
                                pidBitacoraAdmin INTEGER)
    RETURNING CHAR(5);


    DEFINE cCod_Ret CHAR(5);
    DEFINE sql_err INTEGER;

    LET cCod_Ret  = "00000";

	--****************************************************************************************************
	-- DESCRIPCION:  Guarda Autorizacion de Mancomunidad por Cuenta
	-- NOTA: Se clona sp sp_guarda_aut_manc_bei para el requerimiento de bitacora de administradores
	-- AUTOR: Solser
	-- FECHA: 04/06/2018

	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************



    BEGIN

        ON EXCEPTION SET sql_err
          IF sql_err <> 0 THEN
                let cCod_Ret = sql_err;
                RETURN cCod_Ret;
          END IF ;
        END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ;

        INSERT INTO bdibei:"informix".bei_mancomunidad_historico
        (id_historico, id_bitacora_admin, id_usuario, num_cte, num_cta, autoriza, f_mov_historico) VALUES
        (0, pidBitacoraAdmin, pIdUser, pNumCte, pNumCta, pAutoriza, CURRENT YEAR TO SECOND);

        RETURN cCod_Ret;

    END
END PROCEDURE;