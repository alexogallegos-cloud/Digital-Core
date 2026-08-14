CREATE PROCEDURE "informix".sp_guarda_oper_bei_historico( pIdPerfil INTEGER,
												pIdOper INTEGER,
												pNumCta CHAR(16),
												pMontoMin DECIMAL(16,2),
												pMontoMax DECIMAL(16,2),
												pMancomunado CHAR(1),
												pCreatedBy INTEGER, 
                        pidBitacoraAdmin INTEGER,
                        sIdOper INTEGER
												 )
    RETURNING CHAR(5);


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER;

	LET cod_ret = '000000';

	--****************************************************************************************************
	-- DESCRIPCION:  Guarda OPERACIONES de Mancomunidad por Cuenta
	-- NOTA: Se clona sp sp_guarda_oper_bei para el requerimiento de bitacora de administradores
	-- AUTOR: Solser
	-- FECHA: 04/06/2018

	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF;
   END EXCEPTION;


    SET LOCK MODE TO WAIT 3;
    SET ISOLATION DIRTY READ;

			INSERT INTO bdibei:"informix".bei_operaciones_historico
			(id_historico, id_bitacora_admin, id_oper,id_menu_oper,id_perfil,num_cta,monto_min,monto_max,mancomunado,createdby,createdon,updatedby,updatedon,f_mov_historico) VALUES
			(0, pidBitacoraAdmin, sIdOper, pIdOper,pIdPerfil,pNumCta,pMontoMin, pMontoMax,pMancomunado,pCreatedBy,
                CURRENT YEAR TO DAY,pCreatedBy,CURRENT YEAR TO DAY, CURRENT YEAR TO SECOND);

  RETURN cod_ret;


END
END PROCEDURE;