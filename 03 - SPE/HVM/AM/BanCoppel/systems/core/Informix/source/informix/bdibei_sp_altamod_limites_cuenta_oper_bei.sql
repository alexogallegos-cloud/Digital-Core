CREATE PROCEDURE "informix".sp_altamod_limites_cuenta_oper_bei (
    pcliente  CHAR(9),  prestricc CHAR(2),  pcuenta CHAR(16),
    poperacion CHAR(2), plimite DECIMAL(16,2),  pcanal CHAR(2), 
    pusuario  CHAR(10) )
    RETURNING CHAR(3), CHAR(80);  

    --------------------------------------------------------------------
    --DOCUMENTACION
    --Guarda/Actualiza los limites de las empresas personalizados.
    --ya sea por operacion o por cuenta.
    --Realizo: Berenice Noriega Guevara
    --Fecha: 29/Agosto/2014
    --Modificado: 28/Enero/2015
    --Descripcion: Se ajusta para que no regrese error si se intenta 
    --              Borrar y ya no existe.
    --Modifico:Berenice Noriega - BanCoppel
    --LIBERADO A PRODUCCION: 30 ENERO 2015
    --------------------------------------------------------------------


--Se definen variables----
DEFINE iSql_Err INT;
DEFINE cCodRet CHAR(3);
DEFINE cErrorInfo CHAR(80);	--MENSAJE DE CODIGO DE RETORNO

--INICIALIZACION DE VARIABLES--
LET iSql_Err = 0;
LET cCodRet = '000';
LET cErrorInfo="PROCESO EXITOSO";

--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_altamod_limites_cuenta_oper_bei.out";
--TRACE ON;


BEGIN

    ON EXCEPTION SET iSql_Err
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet,cErrorInfo;
        END IF;
    END EXCEPTION;

----------------------------------------------------------------
---Valida que no tenga datos vacios o nulos---------------------

    IF nvl(pcliente,'') = ''  OR pcliente IS NULL THEN
        LET cCodRet='001';
        LET cErrorInfo='CLIENTE NO VALIDO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF nvl(prestricc,'') = '' OR prestricc IS NULL THEN
        LET cCodRet='002';
        LET cErrorInfo='CODIGO DE RESTRICCION VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF nvl(poperacion,'') = '' OR poperacion IS NULL THEN
        LET cCodRet='003';
        LET cErrorInfo='CODIGO DE OPERACION VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF nvl(pcanal,'') = '' OR pcanal IS NULL THEN
        LET cCodRet='004';
        LET cErrorInfo='CANAL VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF nvl(pusuario,'') = '' OR pusuario IS NULL THEN
        LET cCodRet='005';
		LET cErrorInfo='USUARIO VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

	IF nvl(plimite,'') = '' OR plimite IS NULL THEN
        LET cCodRet='006';
        LET cErrorInfo='LIMITE VACIO';
        RETURN cCodRet, cErrorInfo;
    END IF;

    IF prestricc = '01' THEN --POR CUENTA
        IF nvl(pcuenta,'') = '' OR pcuenta IS NULL THEN
            LET cCodRet='007';
            LET cErrorInfo='CUENTA VACIO NO VALIDO PARA RESTRICCION';
            RETURN cCodRet, cErrorInfo;
        END IF;
    END IF;

-------------------------------------------------------------------------------
    IF NOT EXISTS(select num_cliente from bdinteg:"informix".si_plimites_empresas 
                  where num_cliente = pcliente and id_restriccion=prestricc
                  and num_cta=pcuenta and id_operacion=poperacion
                  and id_canal=pcanal) then
		
		IF plimite>0 then
			--Si no existe lo registramos
			INSERT INTO bdinteg:"informix".si_plimites_empresas(num_cliente, id_restriccion, num_cta, id_operacion, id_canal, activo, tope_max_pesos, tope_max_udis, id_periodo, envio_mensaje, id_tipo_mensaje, id_medio, id_mensaje, f_registro, usuario_alta, f_modifica, 
			usuario_modifica)
			VALUES(pcliente, prestricc, pcuenta, poperacion, pcanal, '1', plimite, 0, '01', 'F', '  ', '  ', 'NO_DISP   ', current, pusuario, current, pusuario);
		
		ElSE --El limite no existe, pero se ejecuta el SPL con valor 0, lo ignoramos
			LET cCodRet='000';
            LET cErrorInfo='EL REGISTRO NO EXISTE Y SE INTENTA BORRAR';
            RETURN cCodRet, cErrorInfo;
		END IF;
		

    ELSE --Ya existe un registro
		IF plimite>0 then 	--Si ya existe y el limiete es mayor a cero se trata de una actualización.	
			update bdinteg:"informix".si_plimites_empresas 
			set tope_max_pesos=plimite, f_modifica=current, usuario_modifica=pusuario
			where num_cliente = pcliente and id_restriccion=prestricc
			and num_cta=pcuenta and id_operacion=poperacion
			and id_canal=pcanal;
		Else 	--Si ya existe y el limite es 0, estonses se elimina el registro
			DELETE bdinteg:"informix".si_plimites_empresas 
			WHERE num_cliente = pcliente and id_restriccion=prestricc
			and num_cta=pcuenta and id_operacion=poperacion
			and id_canal=pcanal;
		END IF;
    
	END IF;

    RETURN cCodRet, cErrorInfo;

END
END PROCEDURE;