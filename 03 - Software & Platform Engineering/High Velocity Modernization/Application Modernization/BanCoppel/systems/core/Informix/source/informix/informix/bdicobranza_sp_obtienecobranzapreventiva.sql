create procedure "informix".sp_obtienecobranzapreventiva(pVencido_min INTEGER, 
pVencido_max INTEGER, pImporte_min decimal(18,2),
pImporte_max decimal(18,2), pRegistros integer, pFecha_Ejec DATE, 
pSituacion CHAR(7), pCausa SMALLINT)
RETURNING CHAR(6), CHAR(20), CHAR(20), CHAR(20), CHAR(20), CHAR(110), 
CHAR(1), CHAR(2),CHAR(13), CHAR(13), DECIMAL(18,2), DECIMAL(18,2),
SMALLINT;

---Elaborado por: Lorenzo Ibarra Garcia
--Fecha: 02-10-2009
--Objetivo: Obtener registros para la campaña preventiva del CAT filtrando por los parámetros.

---Modificado por: Lorenzo Ibarra Garcia
--Fecha: 23-10-2009
--Objetivo: Se le agrega el campo vencido en las consultas.

-- Modifico: José Almeida.
-- Fecha: 28 de enero de 2010.
-- Se modfico para que reciva como parametro la fecha de ejecucion y filtre por esta en las consultas.

--Modifico: Adilene Lara
--Fecha: 04-03-2010
--Se modifica para que el filtro de la campaña se realice por el campo pago_min
--Se modifica para excluir de la campaña cualquier cliente con apellido o nombre "Coppel".
--Se modifica para que reciba como parametros el campo Situacion y causa.
--Se modifica para que ademas de generar el archivo correspondiente en la ruta actual, se guarde en el servidor.

--Fecha 16-04-2010
--Se modifica para que al recibir el valor "Todas" en el parametro situacion muestre todos los registros sin importar si tiene o no una situacion especial y causa.

--VARIABLESDEFINE 
DEFINE vcodret                  CHAR(6);
DEFINE vsqlerr                  INTEGER;
DEFINE v_cliente                CHAR(20);
DEFINE v_credito                CHAR(20); 
DEFINE v_ciudad                 CHAR(20);
DEFINE v_estado                 CHAR(20); 
DEFINE v_nombre                 CHAR(110);
DEFINE v_sexo                   CHAR(1); 
DEFINE v_Estado_Civil           CHAR(2);
DEFINE v_t_casa                 CHAR(13); 
DEFINE v_t_celular              CHAR(13);
DEFINE v_saldo_tot              DECIMAL(18,2);
DEFINE v_pago_min               DECIMAL(18,2);
DEFINE v_vencido              SMALLINT;
DEFINE v_situacion              CHAR(7); 
DEFINE v_causa                  SMALLINT;
DEFINE cCausa                   CHAR(5);
DEFINE cSql                     CHAR(2024);
DEFINE cRuta                    CHAR(100);
DEFINE Nsituacion               CHAR(7);

DEFINE Ndia         CHAR(2);
DEFINE Nmes         CHAR(2);
DEFINE Nyear        CHAR(4);

LET vcodret = '000';
LET vsqlerr = 0;
LET v_cliente = '';
LET v_credito = '';
LET v_ciudad = '';
LET v_estado = '';
LET v_nombre = '';
LET v_sexo = '';
LET v_Estado_Civil = '';
LET v_t_casa = '';
LET v_t_celular = '';
LET v_saldo_tot = 0;
LET v_pago_min = 0;
LET v_vencido = 0;
LET v_situacion = '';
LET v_causa = 0;
LET cSql = '';
LET cRuta = '';
LET cCausa = '';

if DAY(pFecha_Ejec) < 10 then
    LET Ndia = '0' || DAY(pFecha_Ejec);
ELSE
    LET Ndia = DAY(pFecha_Ejec);
END IF;

if MONTH(pFecha_Ejec) < 10 then
    LET Nmes = '0' || MONTH(pFecha_Ejec);
ELSE
    LET Nmes = MONTH(pFecha_Ejec);
END IF;

LET Nyear = YEAR(pFecha_Ejec);

--SET DEBUG FILE TO '/tmp/sp_obtienecobranzapreventiva.out';
--TRACE ON;

BEGIN   
ON EXCEPTION SET vsqlerr        
IF vsqlerr <> 0 THEN            
LET vcodret = vsqlerr;            
RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''),NVL(v_nombre,''), NVL(v_sexo,''), NVL(v_Estado_Civil,''),
 NVL(v_t_casa,''), NVL(v_t_celular,''),NVL(v_saldo_tot,0), NVL(v_pago_min,0), NVL(v_vencido,0);        
END IF;    
END EXCEPTION;    

IF pVencido_min is null or pVencido_max is null or pImporte_min is null or pImporte_max is null or pRegistros is null then        
    LET vcodret = '001'; -- Parametros no validos        
    RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''),                 
    NVL(v_nombre,''), NVL(v_sexo,''), NVL(v_Estado_Civil,''), NVL(v_t_casa,''), NVL(v_t_celular,''),                
    NVL(v_saldo_tot,0), NVL(v_pago_min,0), NVL(v_vencido,0);    
END IF;    

IF pVencido_min < 0 OR pVencido_max < 0 OR pImporte_min < 0 OR pImporte_max < 0 OR pRegistros < 0 then        
    LET vcodret = '002'; -- los parametros numericos recibidos deben ser positivos        
    RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''),                 
    NVL(v_nombre,''), NVL(v_sexo,''), NVL(v_Estado_Civil,''), NVL(v_t_casa,''), NVL(v_t_celular,''),                
    NVL(v_saldo_tot,0), NVL(v_pago_min,0), NVL(v_vencido,0);    
END IF;        

IF ( pSituacion = "Ninguna") then
        LET pSituacion = null;
end if;

IF (pCausa = 0) then
        LET pCausa = null;
end if;


IF psituacion = "Todas" and pCausa is null then

IF NOT EXISTS(select cliente from cb_info_preventiva where vencido >= pVencido_min and vencido <= pVencido_max                    
            and pago_min >= pImporte_min and pago_min <= pImporte_max
            and fecha_ejecucion = pFecha_Ejec
            and upper(nombre) not like "%COPPEL%") THEN        
    LET vcodret = '003'; -- no hay registros para los criterios pasados como parametros        
    RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''),                 
        NVL(v_nombre,''), NVL(v_sexo,''), NVL(v_Estado_Civil,''), NVL(v_t_casa,''), NVL(v_t_celular,''),                
        NVL(v_saldo_tot,0), NVL(v_pago_min,0), NVL(v_vencido, 0);    
END IF;

IF pRegistros = 0 then         
    FOREACH            
    select cliente, credito, ciudad, estado, nombre, sexo, Estado_Civil, t_casa, t_celular, saldo_tot, 
    pago_min, vencido, situacion, causa            
    INTO v_cliente, v_credito, v_ciudad, v_estado, v_nombre, v_sexo, v_Estado_Civil, v_t_casa, 
    v_t_celular, v_saldo_tot, v_pago_min, v_vencido, v_situacion, v_causa            
    from cb_info_preventiva            
        where vencido >= pVencido_min and vencido <= pVencido_max
        and pago_min >= pImporte_min and pago_min <= pImporte_max
        and fecha_ejecucion = pFecha_Ejec
        and upper(nombre) not like "%COPPEL%"


        RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''),                 
        NVL(v_nombre,''), NVL(v_sexo,''), NVL(v_Estado_Civil,''), NVL(v_t_casa,''), NVL(v_t_celular,''),                
        NVL(v_saldo_tot,0), NVL(v_pago_min,0), NVL(v_vencido, 0) with resume;

    END FOREACH;    

    IF pSituacion is null then
        LET pSituacion = ' ';
        ELSE
        LET Nsituacion = pSituacion;
    end if;

    IF pCausa is null then
        LET cCausa = ' ';
    ELSE
        LET cCausa = pCausa;
    end if;

    select valor into cRuta from cb_param where cod_param = 1;

    LET cSql = 'echo "unload to ' || trim(nvl(cRuta,' ')) || 'preventiva_' || trim(nvl(pSituacion,' ')) || trim(nvl(cCausa,' ')) || '_' || Ndia || Nmes || Nyear || '.txt';
    LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) ||
    ' select cliente, credito, ciudad,'
    || ' estado, nombre, sexo, Estado_Civil, t_casa, t_celular,'
    || ' saldo_tot, pago_min, vencido, situacion, causa' ||
    ' from cb_info_preventiva where vencido >= ' || pVencido_min || ' and vencido <= ' || pVencido_max
    || ' and pago_min >= ' || pImporte_min || ' and pago_min <= ' || pImporte_max ||
    ' and fecha_ejecucion ='''|| pFecha_Ejec || '''';
    --|| ' AND nvl(situacion,) = '''|| nvl(pSituacion,'') || ''''
    --|| ' AND nvl(causa,0) = '|| nvl(pCausa,0)
    --|| ' and upper(nombre)not like "%COPPEL%"';
    
    IF (pSituacion = '' and pSituacion = "Todas") then
       LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND situacion is '|| 'null';
    ELSE
        LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND situacion = ''' || pSituacion::char(7) || '''';
    end if;
    
    IF pCausa is null then
        LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND causa is ' || 'null';
    ELSE
        LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND causa = ''' || pCausa || '''';
    end if; 
    
    LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' and upper(nombre) not like ''%COPPEL%''" > /tmp/guarda.sql';

    
    SYSTEM SUBSTR(cSql,1,LENGTH(cSql));             
    --LET cSql = 'dbaccess bdicobranza /tmp/guarda.sql';               
    --SYSTEM SUBSTR(cSql,1,LENGTH(cSql)); 
    SYSTEM 'dbaccess bdicobranza /tmp/guarda.sql';
         
    ELSE        
        FOREACH            
        select first pRegistros cliente, credito, ciudad, estado, nombre, sexo, Estado_Civil, t_casa, t_celular, saldo_tot,
        pago_min , vencido, situacion, causa            
        INTO v_cliente, v_credito, v_ciudad, v_estado, v_nombre, v_sexo, v_Estado_Civil, v_t_casa, v_t_celular, v_saldo_tot, 
        v_pago_min, v_vencido, v_situacion, v_causa            
        from cb_info_preventiva            
            where vencido >= pVencido_min and vencido <= pVencido_max            
            and pago_min >= pImporte_min and pago_min <= pImporte_max            
            and fecha_ejecucion = pFecha_Ejec            
            and upper(nombre) not like "%COPPEL%"


            RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''),                 
                NVL(v_nombre,''), NVL(v_sexo,''), NVL(v_Estado_Civil,''), NVL(v_t_casa,''), NVL(v_t_celular,''),                
                NVL(v_saldo_tot,0), NVL(v_pago_min,0), NVL(v_vencido,0) with resume;        
        END FOREACH;    
    END IF;


ELSE

IF NOT EXISTS(select cliente from cb_info_preventiva where vencido >= pVencido_min and vencido <= pVencido_max                    
            and pago_min >= pImporte_min and pago_min <= pImporte_max
            and fecha_ejecucion = pFecha_Ejec
            AND nvl(situacion,'') = nvl(pSituacion,'')
            AND nvl(causa,0) = nvl(pCausa,0)
            and upper(nombre) not like "%COPPEL%") THEN        
    LET vcodret = '003'; -- no hay registros para los criterios pasados como parametros        
    RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''),                 
        NVL(v_nombre,''), NVL(v_sexo,''), NVL(v_Estado_Civil,''), NVL(v_t_casa,''), NVL(v_t_celular,''),                
        NVL(v_saldo_tot,0), NVL(v_pago_min,0), NVL(v_vencido, 0);    
END IF;

IF pRegistros = 0 then         
    FOREACH            
    select cliente, credito, ciudad, estado, nombre, sexo, Estado_Civil, t_casa, t_celular, saldo_tot, 
    pago_min, vencido, situacion, causa            
    INTO v_cliente, v_credito, v_ciudad, v_estado, v_nombre, v_sexo, v_Estado_Civil, v_t_casa, 
    v_t_celular, v_saldo_tot, v_pago_min, v_vencido, v_situacion, v_causa            
    from cb_info_preventiva            
        where vencido >= pVencido_min and vencido <= pVencido_max
        and pago_min >= pImporte_min and pago_min <= pImporte_max
        and fecha_ejecucion = pFecha_Ejec
        AND nvl(situacion,'') = nvl(pSituacion,'')
        AND nvl(causa,0) = nvl(pCausa,0)
        and upper(nombre) not like "%COPPEL%"


        RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''),                 
        NVL(v_nombre,''), NVL(v_sexo,''), NVL(v_Estado_Civil,''), NVL(v_t_casa,''), NVL(v_t_celular,''),                
        NVL(v_saldo_tot,0), NVL(v_pago_min,0), NVL(v_vencido, 0) with resume;

    END FOREACH;    

    IF pSituacion is null then
        LET pSituacion = ' ';
        ELSE
        LET Nsituacion = pSituacion;
    end if;

    IF pCausa is null then
        LET cCausa = ' ';
    ELSE
        LET cCausa = pCausa;
    end if;

    select valor into cRuta from cb_param where cod_param = 1;

    LET cSql = 'echo "unload to ' || trim(nvl(cRuta,' ')) || 'preventiva_' || trim(nvl(pSituacion,' ')) || trim(nvl(cCausa,' ')) || '_' || Ndia || Nmes || Nyear || '.txt';
    LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) ||
    ' select cliente, credito, ciudad,'
    || ' estado, nombre, sexo, Estado_Civil, t_casa, t_celular,'
    || ' saldo_tot, pago_min, vencido, situacion, causa' ||
    ' from cb_info_preventiva where vencido >= ' || pVencido_min || ' and vencido <= ' || pVencido_max
    || ' and pago_min >= ' || pImporte_min || ' and pago_min <= ' || pImporte_max ||
    ' and fecha_ejecucion ='''|| pFecha_Ejec || '''';
    --|| ' AND nvl(situacion,) = '''|| nvl(pSituacion,'') || ''''
    --|| ' AND nvl(causa,0) = '|| nvl(pCausa,0)
    --|| ' and upper(nombre)not like "%COPPEL%"';
    
    IF (pSituacion = '') then
       LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND situacion is '|| 'null';
    ELSE
        LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND situacion = ''' || pSituacion::char(7) || '''';
    end if;
    
    IF pCausa is null then
        LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND causa is ' || 'null';
    ELSE
        LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' AND causa = ''' || pCausa || '''';
    end if; 
    
    LET cSql = SUBSTR(cSql,1,LENGTH(cSql)) || ' and upper(nombre) not like ''%COPPEL%''" > /tmp/guarda.sql';

    
    SYSTEM SUBSTR(cSql,1,LENGTH(cSql));             
    --LET cSql = 'dbaccess bdicobranza /tmp/guarda.sql';               
    --SYSTEM SUBSTR(cSql,1,LENGTH(cSql)); 
    SYSTEM 'dbaccess bdicobranza /tmp/guarda.sql';
         
    ELSE        
        FOREACH            
        select first pRegistros cliente, credito, ciudad, estado, nombre, sexo, Estado_Civil, t_casa, t_celular, saldo_tot,
        pago_min , vencido, situacion, causa            
        INTO v_cliente, v_credito, v_ciudad, v_estado, v_nombre, v_sexo, v_Estado_Civil, v_t_casa, v_t_celular, v_saldo_tot, 
        v_pago_min, v_vencido, v_situacion, v_causa            
        from cb_info_preventiva            
            where vencido >= pVencido_min and vencido <= pVencido_max            
            and pago_min >= pImporte_min and pago_min <= pImporte_max            
            and fecha_ejecucion = pFecha_Ejec            
            AND nvl(situacion,'') = nvl(pSituacion,'')
            AND nvl(causa,0) = nvl(pCausa,0)
            and upper(nombre) not like "%COPPEL%"


            RETURN vcodret, NVL(v_cliente,''), NVL(v_credito,''), NVL(v_ciudad,''), NVL(v_estado,''),                 
                NVL(v_nombre,''), NVL(v_sexo,''), NVL(v_Estado_Civil,''), NVL(v_t_casa,''), NVL(v_t_celular,''),                
                NVL(v_saldo_tot,0), NVL(v_pago_min,0), NVL(v_vencido,0) with resume;        
        END FOREACH;    
    END IF;
    END IF;
END;
END PROCEDURE;