CREATE PROCEDURE "informix".sp_activarserviciobm(pTipo CHAR(2), pEmpresa CHAR(3), pNumCte CHAR(20), pNumcel CHAR(15),
							pFolio_contrato CHAR(12), pEmail CHAR(70), pStatusAnt SMALLINT, pStatusActual SMALLINT,
							pSuc_registra CHAR(4), pReg_numemp CHAR(8), pServicio SMALLINT, pIcia_cel INTEGER)
	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(50); -- Mensaje

	--DEFINICION DE VARIABLES--
	DEFINE iSql_err		INTEGER;
	DEFINE cCodRet		CHAR(5);
	DEFINE cMensaje		CHAR(15);
	DEFINE cFolioBPI	CHAR(12);
	DEFINE cFolioBM		CHAR(12);
	DEFINE cTexto		CHAR(255);
	DEFINE cParam		CHAR(50);
	DEFINE iBandera     INTEGER;
	DEFINE iStatus		INTEGER;

    DEFINE v_codret1      CHAR(5);
    DEFINE v_codret2      CHAR(5);
    DEFINE v_TipoCorreo  SMALLINT;
    DEFINE v_Empresa     CHAR(3); 
    DEFINE v_TipoTel     SMALLINT;
    DEFINE v_Extension   CHAR(5); 
    DEFINE v_Canal       SMALLINT;
    DEFINE v_CiaCel      SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET iSql_err		= 0;
	LET cCodRet		= '00000';
	LET cMensaje	= '';
	LET cFolioBPI	= '';
	LET cFolioBM	= '';
	LET cTexto		= '';
	LET cParam		= '';
	LET iBandera	= 0;
	LET iStatus		= 0;

    LET v_codret1 = '00000';
    LET v_codret2 = '00000';
    LET v_TipoCorreo = 1; 
    LET v_TipoTel    = 3; 
    LET v_Extension  = ''; 
    LET v_Canal      = 3; 
    LET v_CiaCel = 1;

	-- pTipo = 11: Activación BM CON BIACTUSU
	-- pTipo = 12: Activación BM CON pl004027
	-- pTipo = 20: REENVIO SOLICITUD BM CON pl004027
	--SET DEBUG FILE TO "/home/informix/ivonne/sp_activarserviciobm.out";
	--TRACE ON;

	IF NVL(pEmpresa, '') = '' OR NVL(pNumCte, '') = '' OR NVL(pNumcel, '') = '' OR pStatusAnt IS NULL OR
	   pStatusActual IS NULL OR NVL(pSuc_registra, '') = '' OR NVL(pReg_numemp, '') = '' OR pServicio IS NULL THEN
		LET cCodRet = '00001';
		LET cMensaje = 'existen parametros nulos o en blanco';
	END IF;

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN  cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;

		IF cCodRet = '00000' THEN
			IF pEmail <> '' THEN
				LET iBandera = 1;
			END IF;

			SELECT NVL(folio_contrato,'') INTO cFolioBPI
			FROM bdinteg:"informix".si_bpiusuarios
			WHERE empresa = pEmpresa AND numcte = pNumcte;
			
			--IF cFolioBPI = '' OR cFolioBPI IS NULL THEN
				--LET cFolioBPI = pFolio_contrato;
			--END IF

			SELECT  TRIM(valor) INTO cParam
			FROM bdibpi:"informix".tkn_parametros
			WHERE id_param = '50';

			SELECT TRIM(descripcion) --Se modificó para que se seleccione la descripción en vez del valor.
			INTO cTexto
			FROM bdibpi:"informix".tkn_parametros
			WHERE id_param = 42;

			LET cParam = cParam + 1;

			IF SUBSTR(pTipo,1,1) = "1" THEN
				IF (SELECT COUNT(numcte) FROM bdinteg:"informix".si_bm_usuarios WHERE numcte = pNumcte) = 0 THEN
					-- Registra activacion
					INSERT INTO bdinteg:"informix".si_bm_usuarios(empresa, numcte, numcel, folio_contrato, e_mail, id_status,
											fech_status, fech_registro, suc_registra, reg_numemp, servicio, numintacce, cia_cel)
						 VALUES(pEmpresa, pNumcte, pNumcel, cFolioBPI, pEmail, pStatusActual, CURRENT, CURRENT, pSuc_registra,
								pReg_numemp, pServicio, 0, pIcia_cel);

					-- Registra cambio status
                    --En los dos casos de activación pTipo = 11: Activación BM CON BIACTUSU y pTipo = 12: Activación BM CON pl004027
                    --se debe registrar el cambio de estatus en la tabla si_bm_camestcte
					INSERT INTO bdinteg:"informix".si_bm_camestcte(numcte, id_statant, id_statact, numcel,
									fecha_mod, suc_mod, user_mod)
						VALUES(pNumcte, pStatusAnt, pStatusActual, pNumcel, CURRENT, pSuc_registra, pReg_numemp);
				ELSE
					LET cCodRet = '00002';
					LET cMensaje = 'Ya existe un registro del cliente';
				END IF;

				IF (SELECT COUNT(numcte) FROM bdinteg:"informix".si_bm_usuarios WHERE empresa = pEmpresa AND numcte = pNumcte) <> 0 THEN

					SELECT folio_contrato
					INTO cFolioBM
					FROM bdinteg:"informix".si_bm_usuarios
					WHERE empresa = pEmpresa AND numcte = pNumcte;

					-- Registra solicitud de envio msn
					INSERT INTO bdinteg:"informix".si_bm_envsolmsn(numcte, numcel, texto, tipo, folio_contrato)
						 VALUES(pNumcte, pNumcel, cTexto, '001', cFolioBM);

					--Registra en bitácora
					--Se modificó el nombre del campo "foliosol" ya que antes tenía nombre "folio_sol" - 15/12/11
					INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper, numcel, cuenta, foliosol)
						VALUES(cParam,CURRENT,pNumcte,0,"4001",pNumcel,"",cFolioBM);

					--Actualiza datos de tkn_parametros
					UPDATE bdibpi:"informix".tkn_parametros SET valor = cParam WHERE id_param = '50';

					--Se agregó para que se actualice el numero celular y correo en la tabla bpi_usuario cuando el cliente realiza la activación
					--del servicio BM pero ya tiene (anteriormente) contratado el servicio BPI
					IF(SELECT COUNT(numcte) FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumcte) <> 0 THEN

						--Actualiza datos de bpi_usuario
						IF iBandera = 1 THEN
							/*UPDATE bdibpi:"informix".bpi_usuario
						  	SET (tel_celular,e_mail,cia_cel) = (pNumcel,pEmail,pIcia_cel)   --DSB 12/Marzo/2012
						   	WHERE numcliente = pNumcte AND st_portal = "activo";  
							*/
							IF (pNumcel <> '') THEN
								IF (SELECT count (telefono) from bdinteg:"informix".si_telefonos_actual where numcte = pNumcte 
									and telefono = pNumcel and carrier = v_CiaCel and tipo_tel = v_TipoTel) = 0 THEN
								EXECUTE PROCEDURE bdinteg:sp_registra_telefonos(pEmpresa, pNumcte, pNumcel, v_TipoTel,v_Extension, v_CiaCel, v_Canal,pReg_numemp)
									INTO v_codret1;
								END IF;
							END IF;
							IF (pEmail <> '') THEN
								IF (SELECT count (correo_elec) from bdinteg:"informix".si_correos where numcte = pNumcte and correo_elec = pEmail and status_correo = 'A') = 0 THEN
								EXECUTE PROCEDURE bdinteg:sp_registra_correos(pEmpresa,pNumcte,pEmail,v_TipoCorreo,v_Canal,pReg_numemp)
									INTO v_codret2;
								END IF;
							END IF;	
						ELSE
							/*UPDATE bdibpi:"informix".bpi_usuario
						   	SET (tel_celular,cia_cel) = (pNumcel,pIcia_cel)    --DSB 12/Marzo/2012
						   	WHERE numcliente = pNumcte AND st_portal = "activo";
							*/
							IF (pNumcel <> '') THEN
								IF (SELECT count (telefono) from bdinteg:"informix".si_telefonos_actual where numcte = pNumcte 
									and telefono = pNumcel and carrier = v_CiaCel and tipo_tel = v_TipoTel) = 0 THEN
								EXECUTE PROCEDURE bdinteg:sp_registra_telefonos(pEmpresa, pNumcte, pNumcel, v_TipoTel,v_Extension, v_CiaCel, v_Canal,pReg_numemp)
									INTO v_codret1;
								END IF;
							END IF;	
						END IF;
					END IF;

					LET cCodRet = '00000';
					LET cMensaje = 'Exito';
				ELSE
					LET cCodRet = '00003';
					LET cMensaje = 'No existe solicitud de envio';
				END IF;

			ELIF SUBSTR(pTipo,1,1) = "2" THEN

				SELECT TRIM(descripcion) --Se modificó para que se seleccione la descripción en vez del valor.
				INTO cTexto
				FROM bdibpi:"informix".tkn_parametros
				WHERE id_param = 43;

				SELECT folio_contrato
				INTO cFolioBM
				FROM bdinteg:"informix".si_bm_usuarios
				WHERE empresa = pEmpresa AND numcte = pNumcte;

				--Actualiza activación
				IF iBandera = 1 THEN
					UPDATE bdinteg:"informix".si_bm_usuarios SET (numcel,e_mail,cia_cel) = (pNumcel,pEmail,pIcia_cel) WHERE numcte = pNumcte;
				ELSE
					UPDATE bdinteg:"informix".si_bm_usuarios SET (numcel,cia_cel) = (pNumcel,pIcia_cel) WHERE numcte = pNumcte;
				END IF;

                --Se agregó porque existirá un proceso batch que barrerá la tabla si_bm_envsolmsn y cuando se envien los mensajes a los clientes
                --con envíos registrados en esta tabla se borrará el registro, entonces cuando se realice un reenvío sino se encuentra un registro
                --del cliente en la tabla se deberá de insertar.
				IF(SELECT COUNT(numcte) FROM bdinteg:"informix".si_bm_envsolmsn WHERE numcte = pNumcte) <> 0 THEN
					-- Registra solicitud de envio msn
					UPDATE bdinteg:"informix".si_bm_envsolmsn
					SET (numcte, numcel, texto, tipo, folio_contrato) = (pNumcte, pNumcel, cTexto, '002', cFolioBM)
					WHERE numcte = pNumcte;
				ELSE
					-- Registra solicitud de envio msn
					INSERT INTO bdinteg:"informix".si_bm_envsolmsn(numcte, numcel, texto, tipo, folio_contrato)
						 VALUES(pNumcte, pNumcel, cTexto, '002', cFolioBM);
				END IF;

				--IF EXISTS (SELECT 1 FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumcte AND st_portal = "activo") THEN
					--Actualiza datos de bpi_usuario
					IF iBandera = 1 THEN
						/*UPDATE bdibpi:"informix".bpi_usuario
						   SET (tel_celular,e_mail,cia_cel) = (pNumcel,pEmail,pIcia_cel)  --DSB 12/Marzo/2012
						   WHERE numcliente = pNumcte AND st_portal = "activo";
						   */
						IF (pNumcel <> '') THEN
							IF (SELECT count (telefono) from bdinteg:"informix".si_telefonos_actual where numcte = pNumcte 
								and telefono = pNumcel and carrier = v_CiaCel and tipo_tel = v_TipoTel) = 0 THEN
							EXECUTE PROCEDURE bdinteg:sp_registra_telefonos(pEmpresa, pNumcte, pNumcel, v_TipoTel,v_Extension, v_CiaCel, v_Canal,pReg_numemp)
								INTO v_codret1;
							END IF;
						END IF;
						IF (pEmail <> '') THEN
							IF (SELECT count (correo_elec) from bdinteg:"informix".si_correos where numcte = pNumcte and correo_elec = pEmail and status_correo = 'A') = 0 THEN
							EXECUTE PROCEDURE bdinteg:sp_registra_correos(pEmpresa,pNumcte,pEmail,v_TipoCorreo,v_Canal,pReg_numemp)
								INTO v_codret2;
							END IF;
						END IF;	  
					ELSE
						/*UPDATE bdibpi:"informix".bpi_usuario
						   SET (tel_celular,cia_cel) = (pNumcel,pIcia_cel)      --DSB 12/Marzo/2012
						   WHERE numcliente = pNumcte AND st_portal = "activo";
						   */
						IF (pNumcel <> '') THEN
							IF (SELECT count (telefono) from bdinteg:"informix".si_telefonos_actual where numcte = pNumcte 
								and telefono = pNumcel and carrier = v_CiaCel and tipo_tel = v_TipoTel) = 0 THEN
							EXECUTE PROCEDURE bdinteg:sp_registra_telefonos(pEmpresa, pNumcte, pNumcel, v_TipoTel,v_Extension, v_CiaCel, v_Canal,pReg_numemp)
								INTO v_codret1;
							END IF;
						END IF;  
					END IF;
				--END IF;

				--Registra en bitácora
				INSERT INTO bdinteg:"informix".si_bm_bitacora(id_session, fech_oper, numcte, secuencia, id_oper,
							numcel, cuenta, foliosol)
					VALUES(cParam,CURRENT,pNumcte,0,"4002",pNumcel,"",cFolioBM);

				--Actualiza datos de tkn_parametros
				UPDATE bdibpi:"informix".tkn_parametros SET valor = cParam WHERE id_param = '50';

				--Actualización tabla si_bm_usuario idstatus de 20 a 10 y de 30 a 15.
				IF (SELECT COUNT (numcte) FROM bdinteg:"informix".si_bm_usuarios WHERE numcte = pNumcte) <> 0 THEN

					SELECT id_status
					INTO iStatus
					FROM bdinteg:"informix".si_bm_usuarios
					WHERE empresa = pEmpresa AND numcte = pNumcte;

					IF iStatus = 20 THEN
						UPDATE bdinteg:"informix".si_bm_usuarios SET id_status = 10 WHERE numcte = pNumcte;
                        			INSERT INTO bdinteg:"informix".si_bm_camestcte VALUES (pNumcte,'20','10',pNumcel,CURRENT,pSuc_registra, pReg_numemp);
					ELIF iStatus = 30 THEN
						UPDATE bdinteg:"informix".si_bm_usuarios SET id_status = 15 WHERE numcte = pNumcte;
						INSERT INTO bdinteg:"informix".si_bm_camestcte VALUES (pNumcte,'30','15',pNumcel,CURRENT,pSuc_registra, pReg_numemp);
					END IF;
				END IF;

				LET cCodRet = '00000';
				LET cMensaje = 'Exito';

			END IF;
		END IF;

        --inserta registro de teléfono
        /*IF (pNumcel <> '') THEN
            EXECUTE PROCEDURE bdinteg:sp_registra_telefonos(pEmpresa, pNumcte, pNumcel, v_TipoTel,
                                                     v_Extension, v_CiaCel, v_Canal,pReg_numemp)
                             INTO v_codret1;
        END IF;
        IF (pEmail <> '') THEN
            EXECUTE PROCEDURE bdinteg:sp_registra_correos(pEmpresa,pNumcte,pEmail,v_TipoCorreo,v_Canal,pReg_numemp)
                            INTO v_codret2;
        END IF;
		*/

		RETURN  cCodRet, cMensaje;
	END
END PROCEDURE

DOCUMENT
'Activa el servicio BM',
'Autor :Daniela Ramírez',
'FECHA : 12/Septiembre/2011',
'BD: bdinteg',
'Se modifica por petición en RQM03104 donde se realiza una actualización',
'a la tabla si_bm_usuario idstatus de 20 a 10 y de 30 a 15 cuando se solicita',
'un cambio de Equipo/No. Celular',
'Autor :Daniela Ramírez',
'FECHA : 27/Diciembre/2011',
'BD: bdinteg',
'Autor: Jose Angel Gaxiola Gaxiola',
'Modificación: Se agrega parametro pIcia_cel para que inserte en la tabla si_bm_usuarios el codigo correspondiente a la compania celular ',
'Fecha de modificación: 23/Febrero/2012',
'BD: bdinteg',
'Autor: Josue Zepeda',
'Modificación: Se agrega al update parametro pIcia_cel para que actualice en la tabla si_bm_usuarios y bpi_usuario el codigo correspondiente a la compania celular',
'Fecha de modificación: 12/Marzo/2012';

create procedure "informix".sp_actualiza_calle( pNumeroCte char(20), pNumeroCalle integer )
returning char(20);

    --- V3 20100311 
    --- V2 20100125 Agregar log de error y conclusión a tabla
    --- V1 20100113 Crear SP
    
    define cod_ret char(20);
    define sql_err integer;
    define v_numcte char(20);
    define v_numerocalle integer;
    define v_numerociudad smallint;
    define v_max_secuencia integer;
    define v_secuencia_r integer;
    define v_tipo_dir_r char(1);
    define v_calle_r char(40);
    define v_colonia_r char(60);
    define v_entre_calles_r char(40);
    define v_pais_r char(3);
    define v_estado_r char(2);
    define v_ciudad_r char(3);
    define v_municipio_r char(5);
    define v_cod_postal_r char(5);
    define v_apart_postal_r char(11);
    define v_tipo_telef1_r char(1);
    define v_telefono1_r char(13);
    define v_tipo_telef2_r char(1);
    define v_telefono2_r  char(13);
    define v_tipo_telef3_r char(1);
    define v_telefono3_r char(13);
    define v_extension_r char(5);
    define v_estado_inegi_r char(2);
    define v_municipio_inegi_r char(3);
    define v_localidad_inegi_r char(4);
    define v_numerociudad_r smallint;
    define v_numeroextcalle_r char(10);
    define v_numerointcalle_r char(10);
    define v_departamento_r char(6);
    define v_numerocalle_r integer;
    define v_numerocolonia_r integer;
    define v_puntocardinal_r char(1);
    define v_unidadhabitac_r  char(1);
    define v_manzana_r smallint;
    define v_otros_r smallint;
    define v_andador_r smallint;
    define v_etapa_r smallint;
    define v_lote_r smallint;
    define v_edificio_r smallint;
    define v_entrada_r smallint;
    define v_observaciones_r char(80);
    define v_user_insert_r char(8);
    define v_fecha_insert_r date;
    define v_strlog char(100);
    define v_user_insert char(8);
    define v_pais char(3);
    define v_msj char(50);
    
    --- SET DEBUG FILE TO "/ids10_uc9/actualiza_calle.out";
    --- TRACE ON;
    
    let cod_ret = "00000";
    let v_numcte = "";
    let v_numerocalle = 0;
    let v_numerociudad = 0;
    let v_max_secuencia = 0;
    let v_strlog = "";
    let v_pais= '001';
    let v_secuencia_r = 0;

    BEGIN

    on exception set sql_err
        if sql_err <> 0 then
            LET cod_ret = sql_err;
            SYSTEM 'echo ---- Error en numcte -------- ' || v_numcte || '>> ' || 'actualiza_calle.log';
            LET v_msj = 'Error en numcte: ' || v_numcte;
            
            insert into bdinteg:si_bitacora_dom (proceso,cod_ret,mensaje,reg_insert,user_insert,fecha_insert,hora_insert) 
            values('sp_actualiza_calle.sql',cod_ret,v_msj,0,'XASIGN02',today,(SELECT DBINFO('utc_to_datetime',sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
            
            return cod_ret;
        end if
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;

    SYSTEM 'echo ---- Inicia proceso --------- ' || '> ' || 'actualiza_calle.log';
    
    if pNumeroCte = '000000000' then
        foreach
            select {+INDEX(bdinteg:si_por_asignar idx_numcd_numcol)} numcte, numerocalle
              into v_numcte, v_numerocalle
              from bdinteg:si_por_asignar

            --// Obtener secuencia máxima.
            select {+INDEX(bdinteg:si_direcciones_actual idx_diract_cte)} 
                   MAX(secuencia)
              into v_secuencia_r  
              from bdinteg:si_direcciones_actual
             where numcte = v_numcte;

            if v_secuencia_r is null or v_secuencia_r = 0 then
                SYSTEM 'echo Cliente no encontrado en si_direcciones : ' || v_numcte || '>> ' || 'actualiza_calle.log';
                LET v_msj = 'Error en numcte: ' || v_numcte;
                
                insert into bdinteg:si_bitacora_dom (proceso,cod_ret,mensaje,reg_insert,user_insert,fecha_insert,hora_insert) 
                values('sp_actualiza_calle.sql',cod_ret,v_msj,0,'XASIGN02',today,(SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
                
                CONTINUE FOREACH;
            end if

            -- // Selecc para cada cliente el registro que tiene la maxima secuencia dónde la dirección sea la de casa (tipo_dir = 1)
            select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} 
                   d.tipo_dir, d.calle, d.colonia, d.entre_calles, d.pais, d.estado, d.ciudad, d.municipio, d.cod_postal, d.apart_postal, 
                   /* d.tipo_telef1, d.telefono1, d.tipo_telef2, d.telefono2, d.tipo_telef3, d.telefono3, d.extension, */
                   d.estado_inegi, d.municipio_inegi, d.localidad_inegi, d.numerociudad, d.numeroextcalle, d.numerointcalle, d.departamento, 
                   d.numerocalle, d.numerocolonia, d.puntocardinal, d.unidadhabitac, d.manzana, d.otros, d.andador, d.etapa, d.lote,
                   d.edificio, d.entrada, d.observaciones, d.user_insert, d.fecha_insert
              into v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 
                   /* v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r, v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, */
                   v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, v_departamento_r, 
                   v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, 
                   v_edificio_r, v_entrada_r, v_observaciones_r, v_user_insert_r, v_fecha_insert_r
              from bdinteg:si_direcciones_actual d
             where d.numcte = v_numcte
               and d.tipo_dir = '1';

            -- // El registro obtenido guardarlo nuevamente con la secuencia + 1
            let v_max_secuencia = v_secuencia_r + 1;

            insert into bdinteg:si_direcciones
            ( numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal, apart_postal,
              /* tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension, */
              estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,
              puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,user_insert,fecha_insert )
            values  
            ( v_numcte,v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 
              /* v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r,v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, */
              v_estado_inegi_r, v_municipio_inegi_r,v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, v_departamento_r, v_numerocalle, v_numerocolonia_r, 
              v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r,v_lote_r,v_edificio_r, v_entrada_r, v_observaciones_r, 'XASIGN02', today );
        end foreach;
    else
        -- // Obtener secuencia máxima.
        select max(secuencia) 
          into v_secuencia_r  
          from bdinteg:si_direcciones_actual
         where numcte = pNumeroCte;

        if v_secuencia_r is null or v_secuencia_r = 0 then
            SYSTEM 'echo Cliente no encontrado en si_direcciones : ' || v_numcte || '>> ' || 'actualiza_calle.log';
            LET v_msj = 'Error en numcte: ' || v_numcte;
            
            insert into bdinteg:si_bitacora_dom (proceso,cod_ret,mensaje,reg_insert,user_insert,fecha_insert,hora_insert) 
            values('sp_actualiza_calle.sql',cod_ret,v_msj,0,'XASIGN02',today,(SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
        else
            select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} 
                   d.tipo_dir, d.calle, d.colonia, d.entre_calles, d.pais, d.estado, d.ciudad, d.municipio, d.cod_postal, d.apart_postal, 
                   /* d.tipo_telef1, d.telefono1, d.tipo_telef2, d.telefono2, d.tipo_telef3, d.telefono3, d.extension, */
                   d.estado_inegi, d.municipio_inegi, d.localidad_inegi, d.numerociudad, d.numeroextcalle, d.numerointcalle, d.departamento, 
                   d.numerocalle, d.numerocolonia, d.puntocardinal, d.unidadhabitac, d.manzana, d.otros, d.andador, d.etapa, d.lote,
                   d.edificio, d.entrada, d.observaciones, d.user_insert, d.fecha_insert
              into v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 
                   v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r, v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, 
                   v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, v_departamento_r, 
                   v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, 
                   v_edificio_r, v_entrada_r, v_observaciones_r, v_user_insert_r, v_fecha_insert_r
              from bdinteg:si_direcciones_actual d
             where d.numcte = pNumeroCte
               and d.tipo_dir = '1';

            let v_max_secuencia = v_secuencia_r + 1;

            insert into bdinteg:si_direcciones
            ( numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,
              /* tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension, */
              estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,
              puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,user_insert,fecha_insert )
            values  
            ( pNumeroCte,v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 
              /* v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r,v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, */
              v_estado_inegi_r, v_municipio_inegi_r,v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, v_departamento_r, pNumeroCalle,v_numerocolonia_r, 
              v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r,v_lote_r,v_edificio_r, v_entrada_r, v_observaciones_r, 'XASIGN02', today );
        end if
    end if

    end
    
    LET cod_ret = "Termina proceso";
    
    insert into bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
    values('sp_actualiza_calle.sql','00000',cod_ret,0,'XASIGN02',today,(SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

    SYSTEM 'echo ----Termina el proceso-----' || '>> ' || 'actualiza_calle.log';
    
    return cod_ret;
    
end procedure;