CREATE PROCEDURE "informix".sp_cons_cuentas_aut_bei_historico(pIdUsuario INTEGER, pNumCliente CHAR(9), pNoReg INTEGER, pRegIni INTEGER, pIdBitacoraAdmin INTEGER)
   RETURNING CHAR(5), INTEGER, CHAR(16), CHAR(2);

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
    DEFINE iTotalReg INTEGER;

    DEFINE pNum_Cta  CHAR(16);
    DEFINE pAutoriza CHAR(2);


    LET cod_ret  	 = "00000";
    LET pNum_Cta     = '';
    LET pAutoriza    = '';
    LET iTotalReg  	 = 0;
		
	--****************************************************************************************************
	-- DESCRIPCION: Consulta Datos de Usuario para Presentar en Pantalla
	-- AUTOR : Irving Guzman Salas
	-- FECHA : 24/05/2013
	-- BD: bdibei
	-- SOLICITO :
	-- MODIFICACION: Se ajusta spl para mejor manejo de la variable autoriza
	-- MODIFICADO POR: Solser
	-- FECHA: 2016 ENERO , para version 22Enero2016
	-- NOTA: Se clona el sp sp_cons_cuentas_aut_bei para la consulta del detalle
	-- de la operacion perfilar operador del requerimiento Bitacora Administradores (12/Junio/2018)
	--***************************************************************************************************

	--****************************************************************************************************
    -- NOTA: Clonado para el requerimiento de bitacora de administradores
    -- AUTOR: Solser
    -- FECHA: 12/Junio/2018
	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************


BEGIN 

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, iTotalReg, pNum_Cta, pAutoriza;
      END IF;
   END EXCEPTION;

	SET ISOLATION DIRTY READ;

    IF NVL(pNumCliente,'') == '' THEN
        LET cod_ret = '00002'; -- No mando Nombre de Usuario Valido
        RETURN cod_ret, iTotalReg, pNum_Cta, pAutoriza;
    END IF;

    SET LOCK MODE TO WAIT 3;

	
    SELECT COUNT(*)
        INTO iTotalReg
    FROM bdibei:"informix".bei_mancomunidad_historico  man
        WHERE man.id_bitacora_admin = pIdBitacoraAdmin
        AND man.num_cte = pNumCliente;

    IF iTotalReg == 0 THEN
        LET cod_ret = '003'; -- No ay Registros
        RETURN cod_ret, iTotalReg, pNum_Cta, pAutoriza;
    END IF;


    FOREACH
        SELECT SKIP pRegIni FIRST pNoReg  num_cta, decode(autoriza,'t','t','f','f')
            INTO pNum_Cta, pAutoriza
        FROM bdibei:"informix".bei_mancomunidad_historico man
            WHERE man.id_bitacora_admin = pIdBitacoraAdmin
            AND man.num_cte = pNumCliente

        RETURN cod_ret, iTotalReg, pNum_Cta, pAutoriza WITH RESUME;
    END FOREACH;

END;
END PROCEDURE;