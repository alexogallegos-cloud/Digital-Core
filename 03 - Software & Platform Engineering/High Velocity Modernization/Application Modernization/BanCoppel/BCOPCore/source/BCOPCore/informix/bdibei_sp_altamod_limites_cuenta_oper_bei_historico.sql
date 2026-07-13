CREATE PROCEDURE "informix".sp_altamod_limites_cuenta_oper_bei_historico(
    pcliente  CHAR(9),  prestricc CHAR(2),  pcuenta CHAR(16),
    poperacion CHAR(2), plimite DECIMAL(16,2),  pcanal CHAR(2), 
    pusuario  CHAR(10), pidBitacoraAdmin INTEGER)
    RETURNING CHAR(3), CHAR(80);  

	
    --------------------------------------------------------------------
    --DOCUMENTACION ORIGINAL
    --Guarda/Actualiza los limites de las empresas personalizados.
    --ya sea por operacion o por cuenta.
    --Realizo: Berenice Noriega Guevara
    --Fecha: 29/Agosto/2014
    --Modificado: 28/Enero/2015
    --Descripcion: Se ajusta para que no regrese error si se intenta 
    --              Borrar y ya no existe.
    --Modifico:Berenice Noriega - BanCoppel
    --Modificado para historico por: Solser (el 16/05/2018)
    --LIBERADO A PRODUCCION: 30 ENERO 2015
    --------------------------------------------------------------------
	
	
	--****************************************************************************************************
    -- NOTA: Clonado para el requerimiento de bitacora de administradores
    -- AUTOR: Solser
    -- FECHA: 16/05/2018
	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************


--Se definen variables----
DEFINE iSql_Err INT;
DEFINE cCodRet CHAR(3);
DEFINE cErrorInfo CHAR(80);	--MENSAJE DE CODIGO DE RETORNO

--INICIALIZACION DE VARIABLES--
LET iSql_Err = 0;
LET cCodRet = '000';
LET cErrorInfo="PROCESO EXITOSO";


BEGIN

    ON EXCEPTION SET iSql_Err
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet,cErrorInfo;
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;

    IF plimite>0 then
        --El limite es mayor a 0, se guarda
        INSERT INTO bdinteg:"informix".si_plimites_empresas_historico(id_historico, id_bitacora_admin, num_cliente, id_restriccion, num_cta, id_operacion, id_canal, activo, tope_max_pesos, tope_max_udis, id_periodo, envio_mensaje, id_tipo_mensaje, id_medio, id_mensaje, f_registro, usuario_alta, f_modifica, 
        usuario_modifica)
        VALUES(0, pidBitacoraAdmin, pcliente, prestricc, pcuenta, poperacion, pcanal, '1', plimite, 0, '01', 'F', '  ', '  ', 'NO_DISP   ', current, pusuario, current, pusuario);

    ElSE --El limite es 0, lo ignoramos
        LET cCodRet='000';
        LET cErrorInfo='EL REGISTRO NO EXISTE Y SE INTENTA BORRAR';
        RETURN cCodRet, cErrorInfo;
    END IF;

    RETURN cCodRet, cErrorInfo;

END
END PROCEDURE;