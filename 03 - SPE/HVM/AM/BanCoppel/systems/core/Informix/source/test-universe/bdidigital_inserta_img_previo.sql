create procedure "informix".inserta_img_previo(pempresa char(3),
                                                        pcliente char(20),
                                                        pcod_docto char(4),
                                                        pimg_formato char(3),
                                                        pusuario char(8))

RETURNING
char(5),
smallint;

DEFINE v_codret char(5);
DEFINE v_secuencia smallint;
DEFINE v_fecha date;
DEFINE v_hora char(10);
DEFINE sql_err,isam_err int;
DEFINE siSecuenciaHist smallint;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
LET v_codret    = "000";
LET v_secuencia = 0;
LET v_fecha        = today;
LET v_hora         = current hour to second;
LET siSecuenciaHist = 0;

BEGIN
        on exception set sql_err,isam_err
                if sql_err <> 0 or isam_err <> 0 then
                        let v_codret = sql_err;
                        return v_codret,v_secuencia;
                end if;
        end exception;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;


        -- ****************************************************************************
        -- Valida la informacion de entrada
        -- ****************************************************************************
        IF pempresa is null or
                pcliente is null or
                pcod_docto is null or
                pimg_formato is null or
                pusuario is null then

                -- datos de entrada incompletos
                let v_codret = 110;
                return v_codret,v_secuencia;
        END IF;

        -- ****************************************************************************
        -- obtener secuencia
        -- ****************************************************************************

        select max(secuencia) into v_secuencia from bdidigital@coppelimg_crx:dg_expediente_img --bdidigital@COPPELIMG_TCP:dg_expediente_img --182  --- bdidigital@coppelimgdn_tcp:dg_expediente_img --175
        where empresa   = pempresa
        and cliente     = pcliente
        and cod_docto   = pcod_docto;

        IF v_secuencia is null then
                LET v_secuencia = 1;
        ELSE
                LET v_secuencia = v_secuencia +1;
        END IF;

        -- ****************************************************************************
        -- insertar registro en dg_expediente_img sin la imagen
        -- ****************************************************************************
        insert into bdidigital@coppelimg_crx:dg_expediente_img1 --bdidigital@COPPELIMG_TCP:dg_expediente_img1 --182 --bdidigital@coppelimgdn_tcp:dg_expediente_img1 --175
		(empresa,cliente,cod_docto, secuencia,imagen_formato,usuario_alta,fecha_alta,observaciones)
        values (pempresa,pcliente,pcod_docto,v_secuencia,
        pimg_formato,pusuario,v_fecha,trim(v_hora));

END;
RETURN v_codret,v_secuencia;
END PROCEDURE;