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