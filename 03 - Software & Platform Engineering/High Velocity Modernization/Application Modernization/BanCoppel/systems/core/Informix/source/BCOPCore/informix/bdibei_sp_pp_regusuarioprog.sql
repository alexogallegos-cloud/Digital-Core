CREATE PROCEDURE "informix".sp_pp_regusuarioprog(
    pnum_cte        CHAR(20),
    pid_usuario     INTEGER,
    pcuenta_origen  CHAR(20),
    pdescripcion    CHAR(20),
    pfolio          CHAR(40)
)
    RETURNING   CHAR(5),  
                CHAR(60),
                INTEGER;

    DEFINE cod_ret          CHAR(5);
    DEFINE sql_err          INTEGER ;
    DEFINE sIdOper          INTEGER;
    DEFINE mens_ret         CHAR(60);
    DEFINE vcve_pagoprog    CHAR(10);

    LET sIdOper = 0;
    LET cod_ret = '00000';
    LET mens_ret = '';
    LET vcve_pagoprog = '';

    
    --****************************************************************************************************
    -- DESCRIPCION:  Registra en la tabla "" la relacion de que usuario realiza la programación.
    -- Esto para el nuevo modulo de pagos programados en EmpresaNet. ya que el proceso actual que se utiliza
        -- para BPI y Sucursal solo guarda el cliente, y en EmpreaNet se maneja todo por usuario.
    -- AUTOR : Berenice Noriega Guevara - BanCoppel_Internet
    -- FECHA : 17/06/2015
    -- BD: bdibei
    -- SOLICITO :BanCoppel
    --***************************************************************************************************


BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,sIdOper,mens_ret;
      END IF ;
    END EXCEPTION ;

    SET LOCK MODE TO WAIT 4;

    IF(LENGTH(TRIM(NVL(pnum_cte,''))) = 0) THEN
        LET cod_ret="00002"; 
        LET mens_ret="Variable pnum_cte vacia";
    END IF;

    IF(pid_usuario <= 0) THEN
        LET cod_ret="00003"; 
        LET mens_ret="Variable pid_usuario vacia";

    END IF;

    IF(LENGTH(TRIM(NVL(pcuenta_origen,''))) = 0) THEN
        LET cod_ret="00004"; 
        LET mens_ret="Variable pcuenta_origen vacia";
    END IF;

    IF(LENGTH(TRIM(NVL(pdescripcion,''))) = 0) THEN
        LET cod_ret="00005"; 
        LET mens_ret="Variable pdescripcion vacia";
    END IF;

    IF(LENGTH(TRIM(NVL(pfolio,''))) = 0) THEN
        LET cod_ret="00006"; 
        LET mens_ret="Variable pfolio vacia";
    END IF;

    --Regresa el error si alguna variable esta vacia.--
    IF(cod_ret <> '00000') THEN
        RETURN cod_ret,sIdOper,mens_ret;
    END IF;

   
    IF EXISTS (SELECT id_usuario FROM "informix".bei_usuario WHERE id_usuario=pid_usuario AND num_cliente=pnum_cte) THEN
        
        IF EXISTS (select cve_pagoprog from bdiprog:"informix".pp_pagoprog WHERE descripcion=pdescripcion AND num_cte=pnum_cte AND cuenta_origen=pcuenta_origen) THEN
            --Obtiene la Clave de Programación
            
            SELECT cve_pagoprog 
            INTO vcve_pagoprog 
            FROM bdiprog:"informix".pp_pagoprog 
            WHERE descripcion = pdescripcion AND num_cte = pnum_cte AND cuenta_origen = pcuenta_origen;

            -- Inserta el registro
            INSERT INTO bdibei:"informix".bei_pp_usuprog(id_usuario, num_cte, cuenta_origen, descripcion, cve_pagoprog, folio_portal)
            VALUES(pid_usuario, pnum_cte, pcuenta_origen, pdescripcion, vcve_pagoprog, pfolio);
            
        ELSE
            LET cod_ret="00008"; 
            LET mens_ret="No existe programacion para cuenta_cliente_descripcion";
            RETURN cod_ret,sIdOper,mens_ret;

        END IF;

    ELSE
        LET cod_ret="00007"; 
        LET mens_ret="El numero de usuario y_o el cliente no existe";
        RETURN cod_ret,sIdOper,mens_ret;

    END IF; 


    RETURN cod_ret,mens_ret,sIdOper;


END

END PROCEDURE;