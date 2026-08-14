CREATE PROCEDURE "informix".sp_soe_consultatokenareponer(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(9), pTipoBusqueda CHAR(1))
RETURNING CHAR(5) AS codret,
	CHAR(10)AS solicitud,
	CHAR(10)AS numeroSerieToken,
	INTEGER AS statusToken,
	DATE AS fechaSolicitud,
	CHAR(150) AS nombre,
	INTEGER AS id_usuario,
	DECIMAL(18,2) AS costo,
	CHAR(1) AS usar_ws;

--****************************************************************************************************
--Modificacion: Se modifican las consultas que buscan los token no asociados a un usuario en la tabla historica bei_tokenhis obteniendo los tokens mas recientes de los usuarios del cliente
-- ademas se compara contra la tabla de bei_servicio para asegurar el ultimo token de un usuario administrador
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 16 Octubre 2023
--Modificacion: Se agrega validacion para saber si un usuario tiene/tuvo token asignado, si no, para su descarte
--Modifico: Marco Tinajero - BanCoppel - Internet.
--FechaMod: 02 Junio 2025
--****************************************************************************************************
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dCosto DECIMAL(18,2);
	DEFINE sIdUsuario SMALLINT;
	DEFINE cNsToken CHAR(10);
	DEFINE iIdStatusToken INTEGER;
	DEFINE cSolicitud CHAR(10);
	DEFINE dFechaSolicitud DATE;
	DEFINE cNombre CHAR(150);
	DEFINE dFechaMaxima DATE;
	DEFINE dIva DECIMAL(18,2);
	DEFINE cUsarWs CHAR(1);
	DEFINE iProductos INTEGER;
    DEFINE iTipoUsuario INTEGER;
    DEFINE cTokenServicioAdmin CHAR(10);
	DEFINE sCountTotalRegsTkn SMALLINT;
	DEFINE cNsTokenDuplicado CHAR(10);
	DEFINE iIdStatusTokenDuplicado INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET dCosto = 0.0;
	LET sIdUsuario = 0;
	LET cNsToken = '';
	LET iIdStatusToken = 0;
	LET cSolicitud = '';
	LET dFechaSolicitud = '';
	LET cNombre = '';
	LET dFechaMaxima = '';
	LET dIva = 0.0;
	LET cUsarWs = '';
	LET iProductos = 0;
	LET iTipoUsuario = 0;
	LET cTokenServicioAdmin = '';
	LET sCountTotalRegsTkn = 0;
	LET cNsTokenDuplicado = '';
	LET iIdStatusTokenDuplicado = 0;
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSolicitud, cNsToken, iIdStatusToken, dFechaSolicitud, cNombre, sIdUsuario, dCosto, cUsarWs;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_consultatokenareponer.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pNumCte = '' OR pTipoBusqueda = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSolicitud, cNsToken, iIdStatusToken, dFechaSolicitud, cNombre, sIdUsuario, dCosto, cUsarWs;
		END IF;

		IF pTipoBusqueda NOT IN ('1', '2') THEN
			LET cCodRet = '00005';
			RETURN cCodRet, cSolicitud, cNsToken, iIdStatusToken, dFechaSolicitud, cNombre, sIdUsuario, dCosto, cUsarWs;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSolicitud, cNsToken, iIdStatusToken, dFechaSolicitud, cNombre, sIdUsuario, dCosto, cUsarWs;
		END IF;

		IF EXISTS(SELECT numcte FROM bdibei:"informix".bei_tokensolicitud WHERE numcte = pNumCte) THEN
			-- CONSULTA LAS CUENTAS DEL CLIENTE 
			SELECT count(producto) INTO iProductos
			FROM bdicheq:'informix'.sc_maechq  WHERE num_cte = pNumCte AND producto IN ('2600','2800','2700');
					
			IF iProductos > 0 THEN
			
				LET dCosto = 0.00;
			
			ELSE
			
				SET ISOLATION TO DIRTY READ;
				SELECT valor::DECIMAL INTO dCosto
				FROM bdibpi:"informix".tkn_parametros WHERE id_param = 55;
									
				-- CONSULTA DEL VALOR DEL IVA
				SELECT valor INTO dIva FROM bdinteg:"informix".si_param WHERE cod_param = '47';
				LET dCosto = dCosto + (dCosto * dIva);
			
			END IF;
									
			IF pTipoBusqueda = '1' THEN
				FOREACH SELECT id_usuario, id_tipo_usuario
					INTO sIdUsuario, iTipoUsuario
					FROM bdibei:"informix".bei_usuario
					WHERE num_cliente = pNumCte

					LET cNombre = '';

					IF EXISTS(SELECT id_usuario FROM bdibei:"informix".bei_token where num_cliente = pNumCte AND id_usuario = sIdUsuario) THEN

						SELECT ns_token, id_status_token
						INTO cNsToken, iIdStatusToken
						FROM bdibei:"informix".bei_token
						WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario;

						SELECT NVL(nombre, '')
						INTO cNombre
						FROM bdibei:"informix".bei_datos_usuario
						WHERE id_usuario = sIdUsuario;

					ELSE

						-- Buscar si hay mas de 1 registro de tokens con la misma fecha para el mismo usuario
						SELECT COUNT (ns_token) INTO sCountTotalRegsTkn
						FROM bdibei:"informix".bei_tokenhis a
						WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario
						AND f_status = (SELECT MAX(f_status)
										FROM bdibei:bei_tokenhis
										WHERE num_cliente = a.num_cliente AND id_usuario = a.id_usuario);

						IF sCountTotalRegsTkn > 1 THEN

							FOREACH WITH HOLD
								SELECT ns_token, id_status_token
								INTO cNsTokenDuplicado, iIdStatusTokenDuplicado
								FROM bdibei:"informix".bei_tokenhis a
								WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario
								ORDER BY f_status

								-- Validar el token obtenido solo para usuarios administradores (id_tipo_usuario = 1)
								IF (NVL(TRIM(cNsTokenDuplicado),'') != '') AND iTipoUsuario = 1 THEN
									-- Buscar el token de bei_servicio omitiendo los usuarios que esten en estatus ACTIVACION(10), REGISTRO DE USR (20), PRE-REGISTRO DE TOKEN (27)
									SELECT ns_token INTO cTokenServicioAdmin FROM bdibei:"informix".bei_servicio 
									WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario AND id_status NOT IN ('10', '20', '27');

									-- Validar que el token de bei_servicio y la historica sean iguales, caso contrario se toma el de bei_servicio
									IF (NVL(TRIM(cTokenServicioAdmin), '') != '') AND (TRIM(cTokenServicioAdmin) != TRIM(cNsTokenDuplicado)) THEN
										LET cNsToken = cTokenServicioAdmin;
										
										-- Al encontrar coincidencia con la tabla de servicio, salir del ciclo
										EXIT FOREACH;
									END IF;

									 -- Si no hay coincidencia con bei_servicio, se toma el de la historica y se sale del ciclo
									LET cNsToken = cNsTokenDuplicado;
									LET iIdStatusToken = iIdStatusTokenDuplicado;
									EXIT FOREACH;
								END IF;

								-- Si fuera un operador el que se duplica N veces, habra que plantear otra solucion PUES SOLO SE TOMARA EL PRIMER VALOR DESCENDENTE
								LET cNsToken = cNsTokenDuplicado;
								LET iIdStatusToken = iIdStatusTokenDuplicado;
								EXIT FOREACH;

							END FOREACH;
						ELSE
							SELECT ns_token, id_status_token
							INTO cNsToken, iIdStatusToken
							FROM bdibei:"informix".bei_tokenhis a
							WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario
							AND f_status = (SELECT MAX(f_status)
											FROM bdibei:bei_tokenhis
											WHERE num_cliente = a.num_cliente AND id_usuario = a.id_usuario);

						END IF;

					END IF;

					SELECT a.solicitud, f_solicitud
					INTO cSolicitud, dFechaSolicitud
					FROM bdibei:"informix".bei_tokensolicitud a, bdibei:"informix".bei_solicitudtoken b
					WHERE a.ns_token = cNsToken
						AND a.numcte = pNumCte
						AND b.solicitud = a.solicitud
						AND b.numcte = a.numcte;
						
					-- COMPROBACION DEL NUMERO DE ESTATUS DEL TOKEN PARA HACER USO DE WS 1 = si, 0 = no
					LET cUsarWs = '1';
					IF iIdStatusToken IN (110, 120, 130) THEN
						LET cUsarWs = '0';
					END IF;

					-- Solo retornar valores cuando el usuario tenga/tuvo un token
					IF (NVL(TRIM(cNsToken),'') != '') THEN
						RETURN cCodRet, cSolicitud, cNsToken, iIdStatusToken, dFechaSolicitud, cNombre, sIdUsuario, dCosto, cUsarWs WITH RESUME;
					END IF;

				END FOREACH;

				LET sIdUsuario = 0;
				LET cNombre = '';

				FOREACH SELECT ns_token
					INTO cNsToken
					FROM bdibei:"informix".bei_tokensolicitud
					WHERE numcte = pNumCte AND ns_token NOT IN (
						SELECT ns_token FROM bdibei:"informix".bei_token
						WHERE num_cliente = pNumCte
					UNION
					SELECT ns_token FROM bdibei:"informix".bei_tokenhis a
					WHERE num_cliente = pNumCte
						AND f_status = (SELECT MAX(f_status)
										FROM bdibei:"informix".bei_tokenhis
										WHERE num_cliente = a.num_cliente AND id_usuario = a.id_usuario))

					SELECT id_status
					INTO iIdStatusToken
					FROM bdibpi:"informix".tkn_nseries
					WHERE ns_token = cNsToken;
							--AND id_status between 110 AND 130;

					IF iIdStatusToken IS NOT NULL THEN

						SELECT a.solicitud, f_solicitud
						INTO cSolicitud, dFechaSolicitud
						FROM bdibei:"informix".bei_tokensolicitud a, bdibei:"informix".bei_solicitudtoken b
						WHERE a.ns_token = cNsToken
								AND a.numcte = pNumCte
								AND b.solicitud = a.solicitud
								AND b.numcte = a.numcte;
								
						-- COMPROBACION DEL NUMERO DE ESTATUS DEL TOKEN PARA HACER USO DE WS 1 = si, 0 = no
						LET cUsarWs = '1';
						IF iIdStatusToken IN (110, 120, 130) THEN
							LET cUsarWs = '0';
						END IF;

						RETURN cCodRet, cSolicitud, cNsToken, iIdStatusToken, dFechaSolicitud, cNombre, sIdUsuario, dCosto, cUsarWs WITH RESUME;

					END IF;

				END FOREACH;

			ELIF pTipoBusqueda = '2' THEN

				FOREACH SELECT id_usuario, id_tipo_usuario
					INTO sIdUsuario, iTipoUsuario
					FROM bdibei:"informix".bei_usuario
					WHERE num_cliente = pNumCte

					SELECT nombre
					INTO cNombre
					FROM bdibei:"informix".bei_datos_usuario
					WHERE id_usuario = sIdUsuario;

					IF EXISTS(SELECT id_usuario FROM bdibei:"informix".bei_token WHERE id_usuario = sIdUsuario) THEN

						SELECT ns_token, id_status_token
						INTO cNsToken, iIdStatusToken
						FROM bdibei:"informix".bei_token
						WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario;

					ELSE
						
						-- Buscar si hay mas de 1 registro de tokens con la misma fecha para el mismo usuario
						SELECT COUNT (ns_token) INTO sCountTotalRegsTkn
						FROM bdibei:"informix".bei_tokenhis a
						WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario
						AND f_status = (SELECT MAX(f_status)
										FROM bdibei:bei_tokenhis
										WHERE num_cliente = a.num_cliente AND id_usuario = a.id_usuario);

						IF sCountTotalRegsTkn > 1 THEN

							FOREACH WITH HOLD
								SELECT ns_token, id_status_token
								INTO cNsTokenDuplicado, iIdStatusTokenDuplicado
								FROM bdibei:"informix".bei_tokenhis a
								WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario
								ORDER BY f_status

								-- Validar el token obtenido solo para usuarios administradores (id_tipo_usuario = 1)
								IF (NVL(TRIM(cNsTokenDuplicado),'') != '') AND iTipoUsuario = 1 THEN
									-- Buscar el token de bei_servicio omitiendo los usuarios que esten en estatus ACTIVACION(10), REGISTRO DE USR (20), PRE-REGISTRO DE TOKEN (27)
									SELECT ns_token INTO cTokenServicioAdmin FROM bdibei:"informix".bei_servicio 
									WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario AND id_status NOT IN ('10', '20', '27');

									-- Validar que el token de bei_servicio y la historica sean iguales, caso contrario se toma el de bei_servicio
									IF (NVL(TRIM(cTokenServicioAdmin), '') != '') AND (TRIM(cTokenServicioAdmin) != TRIM(cNsTokenDuplicado)) THEN
										LET cNsToken = cTokenServicioAdmin;
										
										-- Al encontrar coincidencia con la tabla de servicio, salir del ciclo
										EXIT FOREACH;
									END IF;

									 -- Si hay coincidencia con bei_servicio, se toma el de la historica y se sale del ciclo
									LET cNsToken = cNsTokenDuplicado;
									LET iIdStatusToken = iIdStatusTokenDuplicado;
									EXIT FOREACH;
								END IF;

								-- Si fuera un operador el que se duplica N veces, habra que plantear otra solucion PUES SOLO SE TOMARA EL PRIMER VALOR DESCENDENTE
								LET cNsToken = cNsTokenDuplicado;
								LET iIdStatusToken = iIdStatusTokenDuplicado;
								EXIT FOREACH;

							END FOREACH;
						ELSE
							SELECT ns_token, id_status_token
							INTO cNsToken, iIdStatusToken
							FROM bdibei:"informix".bei_tokenhis a
							WHERE num_cliente = pNumCte AND id_usuario = sIdUsuario
							AND f_status = (SELECT MAX(f_status)
											FROM bdibei:bei_tokenhis
											WHERE num_cliente = a.num_cliente AND id_usuario = a.id_usuario);

						END IF;

					END IF;
					
					-- COMPROBACION DEL NUMERO DE ESTATUS DEL TOKEN PARA HACER USO DE WS 1 = si, 0 = no
					LET cUsarWs = '1';
					IF iIdStatusToken IN (110, 120, 130) THEN
						LET cUsarWs = '0';
					END IF;

					-- Solo retornar valores cuando el usuario tenga/tuvo un token
					IF (NVL(TRIM(cNsToken),'') != '') THEN
						RETURN cCodRet, cSolicitud, cNsToken, iIdStatusToken, dFechaSolicitud, cNombre, sIdUsuario, dCosto, cUsarWs WITH RESUME;
					END IF;

				END FOREACH;

			END IF;

		ELSE
			LET cCodRet = '00030'; --El NUMERO DE CLIENTE NO EXISTE
			RETURN cCodRet, cSolicitud, cNsToken, iIdStatusToken, dFechaSolicitud, cNombre, sIdUsuario, dCosto, cUsarWs;
		END IF;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 18/11/2014',
'DESCRIPCION: Procedimiento que consulta el token a reponer segun el tipo de busqueda',
'pTipoBusqueda => 1 el tipo de busqueda es por NÃºmero de serie token anterior',
'pTipoBusqueda => 2 el tipo de busqueda es por Nombre del usuario que repone token',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_scvalidatransfctaspropias_bei(pEmpresa char(3),
                                                        pUsuario char(50),
                                                        pCtaOrigen char(20),
                                                        pCtaDestino char(20),
                                                        pMonto money(14,2))
        RETURNING char(5), char(20), char(20);
--****************************************************************************************************
-- DESCRIPCION:  Pago Tarjeta Credito Bancoppel
-- AUTOR :
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


       DEFINE vcodret   char(5);
       DEFINE vUsuStatus smallint;
       DEFINE vSdoReal money(14,2);
       DEFINE vNumTarjOrigen char(20);
       DEFINE vNumTarjDestino char(20);
       DEFINE sql_err   integer;
	   -- SE AGREGAN LAS VARIABLES DE codigo de retorno y mensaje de retorno para el sp de consulta de saldo por tipo de formula OACM
	   DEFINE cCodRet          CHAR(5);
	   DEFINE cMensajeRet      CHAR(50); 

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vNumTarjOrigen, vNumTarjDestino;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vNumTarjOrigen = '0';
LET vNumTarjDestino = '0';

--Set debug file to '/tmp/spscvalidatransfctaspropias.out';
--trace on;
BEGIN
    --Se valida el status del usuario sea completamente activado
    SELECT id_status INTO vUsuStatus FROM "informix".bei_usuario WHERE usuario_bei = pUsuario;
    IF vUsuStatus <> 30 THEN
        RETURN '100', vNumTarjOrigen, vNumTarjDestino;
    END IF;

    -- RQM 09 704. Se almacena el saldo actual por medio de la ejecucion del SP sp_cons_sdodisp_x_tpcalculo OACM
    EXECUTE PROCEDURE BDICHEQ:sp_cons_sdodisp_x_tpcalculo(pCtaOrigen,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'T',2) 
	INTO cCodRet,cMensajeRet,vSdoReal;

    IF pMonto > vSdoReal THEN
        RETURN '200', vNumTarjOrigen, vNumTarjDestino;
    END IF;

    --Se obtiene el numero de tarjeta de la cuenta origen
    SELECT tr.num_tarjeta
    INTO vNumTarjOrigen
    FROM bdicheq:"informix".sc_maechq mc
    INNER JOIN bdicheq:"informix".sc_tarjeta tr
    on mc.empresa = pEmpresa  AND
    mc.empresa = tr.empresa AND
    mc.cuenta = pCtaOrigen AND
    tr.cuenta = mc.cuenta AND
    tr.tipo_tarjeta = 'T' AND
    tr.status_tar = 'A';

    --Se obtiene el numero de tarjeta de la cuenta destino
    SELECT tr.num_tarjeta
    INTO vNumTarjDestino
    FROM bdicheq:"informix".sc_maechq mc
    INNER JOIN bdicheq:"informix".sc_tarjeta tr
    on mc.empresa = pEmpresa  AND
    mc.empresa = tr.empresa AND
    mc.cuenta = pCtaDestino AND
    tr.cuenta = mc.cuenta AND
    tr.tipo_tarjeta = 'T' AND
    tr.status_tar = 'A';

    if 	vNumTarjDestino is null then
	let vNumTarjDestino = '';
    end if;

   if 	vNumTarjOrigen is null then
	let vNumTarjOrigen = '';
    end if;


END;
RETURN vcodret, vNumTarjOrigen, vNumTarjDestino;

END PROCEDURE
DOCUMENT
'MODIFICIACION : Se agrega el saldo sbc en el saldo DISPONIBLE ',
'AUTOR : Osiel Alfredo Camacho Mendoza',
'FECHA : 17/10/2025',
'BD : bdibei';

CREATE PROCEDURE "informix".sp_depura_arch_movimientos(pFolio CHAR(25)) 
RETURNING CHAR(5) AS cod_ret;
--************************************************************************************************************************************
-- DESCRIPCION: Depurar los registros de movimientos por folio de un archivo de movimientos generado sobre bdibei:bei_movimientos_cons
-- AUTOR : Marco Tinajero - BanCoppel - Internet.
-- BD: bdibei
-- FECHA DE CREACION: 06/Agosto/2025
-- INC 03 501 EmpresaNet - Optimizacion Generacion Archivo de Movimientos
--**************************************************************************************************************************************

    -- Variables para manejo de excepcion/resultado
    DEFINE vIntSqlErr INTEGER;
    DEFINE vChrCodRet CHAR(5);

    -- Variables para consulta de movimientos
    DEFINE vIntIdMovimiento INTEGER;
    DEFINE vChrFolio CHAR(25);

    -- Variables para manejo de excepcion/resultado
    DEFINE vIntContadorMovs INTEGER;
    DEFINE vIntIniciarBegin INTEGER;
    DEFINE vIntRegistros INTEGER;

    -- Inicializar variables
    LET vChrCodRet = "00000";
    LET vIntContadorMovs = 0;
    LET vIntIniciarBegin = 1;
    LET vIntRegistros = 1000;

    BEGIN
        -- Manejo de excepcion
        ON EXCEPTION SET vIntSqlErr
            IF vIntSqlErr <> 0 THEN
                LET vChrCodRet = vIntSqlErr;
                RETURN vChrCodRet;
            END IF ;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        FOREACH WITH HOLD
            SELECT id_movimientos, folio
            INTO vIntIdMovimiento, vChrFolio
            FROM bdibei:"informix".bei_movimientos_cons 
            WHERE folio = pFolio 
            ORDER BY id_movimientos

            IF vIntIniciarBegin = 1 THEN
                BEGIN WORK;
                LET vIntIniciarBegin = 0;
            END IF;

            LET vIntContadorMovs = vIntContadorMovs + 1;

            DELETE {+INDEX(bdibei:"informix".bei_movimientos_cons movimientos)}
            FROM bdibei:"informix".bei_movimientos_cons 
            WHERE id_movimientos = vIntIdMovimiento AND folio = vChrFolio;

            -- Se realiza el commit work al alcanzar los 1000 registros
            IF (vIntContadorMovs >= vIntRegistros) THEN
                COMMIT WORK;
                LET vIntIniciarBegin = 1;
                LET vIntContadorMovs = 0;
            END IF;        

            CONTINUE FOREACH;
        END FOREACH;

        -- Si al terminar la ejecucion del foreach se creo un BEGIN WORK y no se genero el COMMIT WORK con mas de 1000 regs, se ejecutara aqui
        IF (vIntIniciarBegin = 0) THEN
            COMMIT WORK;
        END IF;

        RETURN vChrCodRet;
    END;
END PROCEDURE;