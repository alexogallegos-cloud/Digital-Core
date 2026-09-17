create procedure "informix".sp_obtienecobranzaauronix(pVencido_min integer, pVencido_max integer, 
pImporte_min decimal(18,2), pImporte_max decimal(18,2), pRegistros integer,pSituacion CHAR(7), pCausa SMALLINT)
RETURNING CHAR(6), CHAR(20), CHAR(20), CHAR(20), CHAR(20), CHAR(110), CHAR(13), 
/*DECIMAL(18,2), */DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2);

---Elaborado por: Lorenzo Ibarra Garcia
--Fecha: 02-10-2009
--Objetivo: Obtener registros con celular propio para la campaña auronix del CAT filtrando por los parámetros.

---Modificado por: Armida Pazos Chávez
--Fecha: 25-10-2009
--Objetivo: Se le elimino el campo pago_venc_exig.

--Modifico: Adilene Lara
--Fecha: 06-03-2010
--Se modifica para que reciba como parametros los campos situacion y causa.
--Fecha: 15-04-2010
--Se modifico para que al extraer la informacion valide la fecha maxima del campo fecha_ejecucion
--Ademas para que al recibir el valor "Todas" en el parametro situacion muestre todos los registros sin importar si tiene o no una situacion especial y causa.

--VARIABLES
DEFINE vcodret                  CHAR(6);
DEFINE vsqlerr                  INTEGER;

DEFINE v_cliente                CHAR(20);
DEFINE v_credito                CHAR(20);
DEFINE v_ciudad                 CHAR(20);
DEFINE v_estado                 CHAR(20);
DEFINE v_nombre                 CHAR(110);
DEFINE v_t_celular              CHAR(13);
--DEFINE v_cap_venc_exig          DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora      DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo       DECIMAL(18,2);
DEFINE v_pago_min               DECIMAL(18,2);
DEFINE v_fecha                  DATE;
DEFINE v_situacion              CHAR(7);
DEFINE v_causa                  SMALLINT;

LET vcodret = '000';
LET vsqlerr = 0;

LET v_cliente = '';
LET v_credito = '';
LET v_ciudad = '';
LET v_estado = '';
LET v_nombre = '';
LET v_t_celular = '';
--LET v_cap_venc_exig = 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo = 0;
LET v_pago_min = 0;
LET v_situacion = '';
LET v_causa = 0;

--SET DEBUG FILE TO '/tmp/sp_obtienecobranzaauronix.out';
--TRACE ON;

BEGIN
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''), 
            NVL(v_nombre,''), NVL(v_t_celular,''),/* NVL(v_cap_venc_exig,0),*/ NVL(v_sdo_venc_int_mora,0), 
            NVL(v_pago_min_sin_vdo,0), NVL(v_pago_min,0);
        END IF;
    END EXCEPTION;

    IF pVencido_min is null or pVencido_max is null or pImporte_min is null or pImporte_max is null or pRegistros is null then
        LET vcodret = '001'; -- Parametros no validos
        RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''), 
                NVL(v_nombre,''), NVL(v_t_celular,''), /*NVL(v_cap_venc_exig,0),*/ NVL(v_sdo_venc_int_mora,0), 
                NVL(v_pago_min_sin_vdo,0), NVL(v_pago_min,0);
    END IF;

    IF pVencido_min < 0 OR pVencido_max < 0 OR pImporte_min < 0 OR pImporte_max < 0 OR pRegistros < 0 then
        LET vcodret = '002'; -- los parametros numericos recibidos deben ser positivos
        RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''), 
                NVL(v_nombre,''), NVL(v_t_celular,''), /*NVL(v_cap_venc_exig,0),*/ NVL(v_sdo_venc_int_mora,0), 
                NVL(v_pago_min_sin_vdo,0), NVL(v_pago_min,0);
    END IF;

    IF ( pSituacion = "Ninguna") then
        LET pSituacion = null;
    end if;

    IF (pCausa = 0) then
            LET pCausa = null;
    end if;
    
    select NVL(max(fecha_ejecucion),'01/01/1900')
    into v_fecha
    from bdicobranza:cb_info_administrativa;
  
    IF pSituacion = "Todas" and pCausa is null THEN
    IF NOT EXISTS(select cliente from cb_info_administrativa
                                where pago_venc >= pVencido_min and pago_venc <= pVencido_max
                                and pago_min >= pImporte_min and pago_min <= pImporte_max
                                and NVL(t_celular,'') <> ''
								AND t_celular <> 0
                                AND nvl(fecha_ejecucion,'01/01/1900') = v_fecha 
                                and upper(nombre) not like "%COPPEL%" )THEN
        LET vcodret = '003'; -- no hay registros para los criterios pasados como parametros
        RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''), 
                NVL(v_nombre,''), NVL(v_t_celular,''), /*NVL(v_cap_venc_exig,0),*/ NVL(v_sdo_venc_int_mora,0), 
                NVL(v_pago_min_sin_vdo,0), NVL(v_pago_min,0);
    END IF;
  
  IF pRegistros = 0 then 
        FOREACH
            select cliente, credito, ciudad, estado, nombre, t_celular, /*cap_venc_exig,*/ sdo_venc_int_mora, 
            pago_min_sin_vdo, pago_min,situacion, causa
            INTO v_cliente, v_credito, v_ciudad, v_estado, v_nombre, v_t_celular,/* v_cap_venc_exig, */v_sdo_venc_int_mora, 
            v_pago_min_sin_vdo, v_pago_min, v_situacion, v_causa
            from cb_info_administrativa
            where pago_venc >= pVencido_min and pago_venc <= pVencido_max
            and pago_min >= pImporte_min and pago_min <= pImporte_max
            and NVL(t_celular,'') <> ''
			AND t_celular <> 0
            AND nvl(fecha_ejecucion,'01/01/1900') = v_fecha 
            AND UPPER(nombre) not like "%COPPEL%"   
            
			 RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''), 
                NVL(v_nombre,''), NVL(v_t_celular,''), /*NVL(v_cap_venc_exig,0),*/NVL(v_sdo_venc_int_mora,0), 
                NVL(v_pago_min_sin_vdo,0), NVL(v_pago_min,0) with resume;
        END FOREACH;
    ELSE
        FOREACH
            select first pRegistros cliente, credito, ciudad, estado, nombre, t_celular, /*cap_venc_exig,*/ sdo_venc_int_mora, 
            pago_min_sin_vdo, pago_min, situacion, causa
            INTO v_cliente, v_credito, v_ciudad, v_estado, v_nombre, v_t_celular, /*v_cap_venc_exig,*/ v_sdo_venc_int_mora, 
            v_pago_min_sin_vdo, v_pago_min, v_situacion, v_causa
            from cb_info_administrativa
            where pago_venc >= pVencido_min and pago_venc <= pVencido_max
            and pago_min >= pImporte_min and pago_min <= pImporte_max
            and NVL(t_celular,'') <> ''
			AND t_celular <> 0
            AND nvl(fecha_ejecucion,'01/01/1900') = v_fecha 
            and upper(nombre) not like "%COPPEL%" 
			
                   
                RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''), 
                NVL(v_nombre,''), NVL(v_t_celular,''), /*NVL(v_cap_venc_exig,0),*/ NVL(v_sdo_venc_int_mora,0), 
                NVL(v_pago_min_sin_vdo,0), NVL(v_pago_min,0) with resume;
        END FOREACH;
    END IF;
    
    ELSE
    IF NOT EXISTS(select cliente from cb_info_administrativa
                                where pago_venc >= pVencido_min and pago_venc <= pVencido_max
                                and pago_min >= pImporte_min and pago_min <= pImporte_max
                                and NVL(t_celular,'') <> ''
								AND t_celular <> 0 
                                AND nvl(situacion,'') = nvl(pSituacion,'')
                                AND nvl(causa,0) = nvl(pCausa,0)
                                AND nvl(fecha_ejecucion,'01/01/1900') = v_fecha 
                                and upper(nombre) not like "%COPPEL%" )THEN
        LET vcodret = '003'; -- no hay registros para los criterios pasados como parametros
        RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''), 
                NVL(v_nombre,''), NVL(v_t_celular,''), /*NVL(v_cap_venc_exig,0),*/ NVL(v_sdo_venc_int_mora,0), 
                NVL(v_pago_min_sin_vdo,0), NVL(v_pago_min,0);
    END IF;

    select NVL(max(fecha_ejecucion),'01/01/1900')
    into v_fecha
    from bdicobranza:cb_info_administrativa;
  
  IF pRegistros = 0 then 
        FOREACH
            select cliente, credito, ciudad, estado, nombre, t_celular, /*cap_venc_exig,*/ sdo_venc_int_mora, 
            pago_min_sin_vdo, pago_min,situacion, causa
            INTO v_cliente, v_credito, v_ciudad, v_estado, v_nombre, v_t_celular,/* v_cap_venc_exig, */v_sdo_venc_int_mora, 
            v_pago_min_sin_vdo, v_pago_min, v_situacion, v_causa
            from cb_info_administrativa
            where pago_venc >= pVencido_min and pago_venc <= pVencido_max
            and pago_min >= pImporte_min and pago_min <= pImporte_max
            and NVL(t_celular,'') <> ''
			AND t_celular <> 0 
            AND nvl(situacion,'') = nvl(pSituacion,'')
            AND nvl(causa,0) = nvl(pCausa,0)
            AND nvl(fecha_ejecucion,'01/01/1900') = v_fecha 
            AND UPPER(nombre) not like "%COPPEL%"   
            
                RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''), 
                NVL(v_nombre,''), NVL(v_t_celular,''), /*NVL(v_cap_venc_exig,0),*/NVL(v_sdo_venc_int_mora,0), 
                NVL(v_pago_min_sin_vdo,0), NVL(v_pago_min,0) with resume;
        END FOREACH;
    ELSE
        FOREACH
            select first pRegistros cliente, credito, ciudad, estado, nombre, t_celular, /*cap_venc_exig,*/ sdo_venc_int_mora, 
            pago_min_sin_vdo, pago_min, situacion, causa
            INTO v_cliente, v_credito, v_ciudad, v_estado, v_nombre, v_t_celular, /*v_cap_venc_exig,*/ v_sdo_venc_int_mora, 
            v_pago_min_sin_vdo, v_pago_min, v_situacion, v_causa
            from cb_info_administrativa
            where pago_venc >= pVencido_min and pago_venc <= pVencido_max
            and pago_min >= pImporte_min and pago_min <= pImporte_max
            and NVL(t_celular,'') <> ''
			AND t_celular <> 0 
            AND nvl(situacion,'') = nvl(pSituacion,'')
            AND nvl(causa,0) = nvl(pCausa,0)
            AND nvl(fecha_ejecucion,'01/01/1900') = v_fecha 
            and upper(nombre) not like "%COPPEL%" 
                    
                RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''), 
                NVL(v_nombre,''), NVL(v_t_celular,''), /*NVL(v_cap_venc_exig,0),*/ NVL(v_sdo_venc_int_mora,0), 
                NVL(v_pago_min_sin_vdo,0), NVL(v_pago_min,0) with resume;
        END FOREACH;
    END IF;
    END IF;
END;
END PROCEDURE;