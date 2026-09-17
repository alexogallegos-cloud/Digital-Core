CREATE PROCEDURE "informix".sp_consulta_perfil_ctas_frecuentes_bei2_historico(pNumCliente CHAR(9), pIdPerfil INTEGER, pIdUsuario INTEGER, pIdBitacoraAdmin INTEGER) 
RETURNING CHAR(5), CHAR(1), CHAR(1);

	--****************************************************************************************************
	-- DESCRIPCION: Consulta si usuario cuenta con permiso para cuentas frecuentes (mancomunidad)
	-- AUTOR : Jose Angel Hernandez Gonzalez
	-- FECHA : 29/Agosto/2016
	-- BD: bdibei
	--****************************************************************************************************

	--****************************************************************************************************
	-- DESCRIPCION: Consulta si usuario cuenta con permiso para cuentas frecuentes (mancomunidad)
	-- AUTOR : GUSTAVO BUJANO GUZMÁN
	-- FECHA : 18/04/2017
	-- BD: bdibei
	-- MODIFICACION: Se adecua la excepción para cuando son alta de usuarios
	--****************************************************************************************************

	--****************************************************************************************************
    -- NOTA: Clonado para el requerimiento de bitacora de administradores
    -- AUTOR: Solser
    -- FECHA: 05/06/2018
	
	-- MODIFICADO PARA LIBERAR: Se ajusta para cumplir las politicas de BD
	-- AUTOR: Berenice Noriega 
	-- FECHA LIBERACIÓN PRODUCCIÓN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************



-- Variables para manejo de excepcion/resultado
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);

-- Variables
    DEFINE vNum_cta CHAR(8);
    DEFINE vIdMenuOper INTEGER;
    DEFINE vMancomunidad CHAR(1);
    DEFINE vAutoriza CHAR(1);
	
    DEFINE vMancomunidadTem BOOLEAN;
    DEFINE vAutorizaTem BOOLEAN;


    LET cod_ret  = '00000';
    LET vNum_cta = '00000000';
    LET vIdMenuOper = 63;
	
	LET vAutoriza = '';
	LET vMancomunidad='';
	
	--SET debug FILE TO "/home/informix/BereniceOut/sp_consulta_perfil_ctas_frecuentes_bei2_historico.out";
	--Trace ON;

BEGIN

    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret, '', '';
      END IF;
    END EXCEPTION;
	

		
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
       SELECT manc.autoriza, oper.mancomunado
       INTO vAutorizaTem, vMancomunidadTem
       FROM bdibei:"informix".bei_mancomunidad_historico AS manc
       INNER JOIN bdibei:"informix".bei_operaciones_historico AS oper  ON oper.id_perfil = pIdPerfil 
       AND oper.num_cta = vNum_cta 
       AND oper.id_menu_oper = vIdMenuOper
       AND oper.id_bitacora_admin = pIdBitacoraAdmin
       WHERE manc.num_cta = vNum_cta 
       AND manc.num_cte = pNumCliente
       AND manc.id_usuario = pIdUsuario
       AND manc.id_bitacora_admin = pIdBitacoraAdmin;
			
		IF (vAutorizaTem is not null AND vMancomunidadTem is not null) THEN
			IF vAutorizaTem = 't' THEN
				LET vAutoriza = 't';
			ELIF vAutorizaTem = 'f' THEN
				LET vAutoriza='f';			
			END IF;
		
			IF vMancomunidadTem ='t' THEN
				LET vMancomunidad='M';
			ELIF vMancomunidadTem ='f' THEN
				LET vMancomunidad='I';			
			END IF;
			
		END IF;		
		        
        RETURN cod_ret, vAutoriza, vMancomunidad;
   END;
END PROCEDURE;