CREATE PROCEDURE "informix".sp_soe_insertacomentario(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pcFolio char(10), pcNumEmpleado char(8),
                                                     pcIdOperacion char(4), pcNumCte char(9), pcReferencia varchar(30), pcComentario char(500))

        RETURNING       CHAR(5) AS cCodRetChar,
                        VARCHAR(50) AS vMensajeErr;

        DEFINE v_cod_ret            CHAR(5);
        DEFINE vMensajeErr          VARCHAR(50);
        DEFINE iExiste              SMALLINT;
        DEFINE iSqlErr              INTEGER;
        DEFINE iSamErr              INTEGER;
		----------------------------------------
		DEFINE vcmes                CHAR(2);
		DEFINE vcanio               CHAR(2);
        DEFINE cFolioMax            CHAR(60);
		----------------------------------------
        LET vMensajeErr = '';
        LET iExiste     =0;
        LET vcmes       ='';
        LET vcanio      ='';
        LET cFolioMax   ='';

        BEGIN

                ON EXCEPTION
                        SET iSqlErr, iSamErr
                        IF iSqlErr <> 0 THEN
                                LET v_cod_ret = iSqlErr;
                                LET vMensajeErr= 'ERROR INTERNO EN BASE DE DATOS';
                        END IF;
                        RETURN v_cod_ret,vMensajeErr;
                END EXCEPTION;

        --SET DEBUG FILE TO "/tmp/sp_soe_insertacomentario.out";
		--TRACE ON;

			IF pIdUsuario = '' OR pIdFuncion = '' THEN
					LET v_cod_ret = '00003';
					RETURN v_cod_ret,NULL;
			END IF;

			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO v_cod_ret;
			IF v_cod_ret <> '00000' THEN
					RETURN v_cod_ret,vMensajeErr;
			END IF;


			IF pcFolio = '' OR pcNumEmpleado = '' OR pcIdOperacion = '' OR pcNumCte = '' OR pcReferencia = '' OR pcComentario = '' THEN
					LET v_cod_ret = '00003';
					LET vMensajeErr= 'PARAMETROS INCORRECTOS';
					RETURN v_cod_ret,vMensajeErr;
			END IF;

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;

			--Se Agrega para validar y crear el folio para Bloqueo y Desbloqueo de Token--
			LET cFolioMax = pcFolio;
			--SELECT SUBSTRING(fecha_hoy FROM 9 FOR 10)
			SELECT substring((year(fecha_hoy)) FROM 3 FOR 2), lpad(month(fecha_hoy),2,"0")
			INTO vcanio, vcmes
			FROM bdinteg:"informix".si_fechas;

            --SELECT CASE SUBSTRING(fecha_hoy FROM 1 FOR 2)
            SELECT CASE vcmes
            WHEN '01' THEN 'A'--ENERO
                        WHEN '02' THEN 'B'--FEBRERO
                        WHEN '03' THEN 'C'--MARZO
                        WHEN '04' THEN 'D'--ABRIL
                        WHEN '05' THEN 'E'--MAYO
                        WHEN '06' THEN 'F'--JUNIO
                        WHEN '07' THEN 'G'--JULIO
                        WHEN '08' THEN 'H'--AGOSTO
                        WHEN '09' THEN 'I'--SEPTIEMBRE
                        WHEN '10' THEN 'J'--OCTUBRE
                        WHEN '11' THEN 'K'--NOVIEMBRE
                        WHEN '12' THEN 'L'--DICIEMBRE
                        ELSE 'UN' END
                        INTO vcmes
            FROM bdinteg:"informix".si_fechas;

        IF (pcIdOperacion = "1020") THEN --BLOKEO TKN
            LET cFolioMax = 'BT' || TRIM(cFolioMax) || TRIM(vcmes) || vcanio;
                ELIF (pcIdOperacion = "1025") THEN --BLOQUEO DE USUARIO.La letra del mes y el anio ya viene desde el programa, solo se concatena la inicial.
            LET cFolioMax = 'BU' || TRIM(cFolioMax);
                ELIF (pcIdOperacion = "1026") THEN --RESET DE USUARIO.La letra del mes y el anio ya viene desde el programa, solo se concatena la inicial.
            LET cFolioMax = 'RU' || TRIM(cFolioMax);
        ELIF (pcIdOperacion = "1033") THEN --DESBLOKEO TKN
            LET cFolioMax = 'DT' || TRIM(cFolioMax) || TRIM(vcmes) || vcanio;
                ELIF (pcIdOperacion = "1037") THEN --DESBLOQUEO DE USUARIO. La letra del mes y el anio ya viene desde el programa, solo se concatena la inicial.
                        LET cFolioMax = 'DU' || TRIM(cFolioMax);
        END IF;

                SELECT COUNT(*) INTO iExiste FROM bdibei:"informix".soe_comentarios WHERE folio=TRIM(cFolioMax);

                IF(iExiste > 0) THEN
                        LET v_cod_ret = '00183';
                        LET vMensajeErr= 'VERIFICAR FOLIO YA EXISTE EN TABLA.';
                        RETURN v_cod_ret,vMensajeErr;
                END IF;

                INSERT INTO bdibei:"informix".soe_comentarios (folio, num_empleado, f_registro, id_operacion, num_cliente, referencia, comentario)
                VALUES(TRIM(cFolioMax), pcNumEmpleado, current, pcIdOperacion, pcNumCte, pcReferencia, pcComentario);

                RETURN v_cod_ret, vMensajeErr;

        END
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'DESCRIPCION: Inserta comentarios en SOE',
'FECHA: 10/12/2014',
'BD: bdibei';

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