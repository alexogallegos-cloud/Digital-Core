CREATE PROCEDURE "informix".sp_pp_consultarprog_bei(p_snum_cte CHAR(20), pDesde INTEGER, pHasta INTEGER, p_usuario INTEGER)


      RETURNING         CHAR(5),    --Código Retorno
                        CHAR(250),  --Mensaje Retorno
                        CHAR(10),   --Clave de Pago de Programación
                        CHAR(2),    --Clave de Estado
                        CHAR(20),   --Concepto de Pago
                        DATE,       --Fecha Programación
                        CHAR(30),   --Frecuencia
                        MONEY(16,2),--Monto
                        DATE        --Fecha inicio
                        

        --Definicion de Variables  
        DEFINE v_sCodRet             CHAR(5);
        DEFINE v_sMensajeRet         CHAR(250);

        DEFINE sCve_PagoProg         CHAR(10);
        DEFINE aCve_Estado           CHAR(2);
        DEFINE sConcepto_Pago        CHAR(20);
        DEFINE sFecha_Programacion   DATE;
        DEFINE sFrecuencia           CHAR(30);
        DEFINE sMonto                MONEY(16,2);
        DEFINE sFecha_Inicio         DATE;

        DEFINE iContador             INT;
        DEFINE vCountProgramaciones   INT;
        DEFINE v_dfecha              DATE;


                  
        --Inicializacion de Variables
        LET v_sCodRet = '';
        LET v_sMensajeRet = '';

        LET sCve_PagoProg = '';
        LET aCve_Estado = '';
        LET sConcepto_Pago = '';
        LET sFecha_Programacion = '';
        LET sFrecuencia = '';
        LET sMonto = 0;
        LET sFecha_Inicio = '';

        LET iContador = 0;
        LET vCountProgramaciones = 0;
        LET v_dfecha = '';  
  
    --****************************************************************************************************
    -- DESCRIPCION:  tomado como base el spl bdiprog:sp_consultarprogramaciongeneral_bpi
    -- se le agrega un parametro mas de entrada p_usuario y se consulta la tabla de relacion de 
    -- pagos programados por usuario.
    -- AUTOR : Berenice Noriega Guevara - BanCoppel_Internet
    -- FECHA : 17/06/2015
    -- BD: bdibei
    -- SOLICITO :BanCoppel
    --***************************************************************************************************
    -- DESCRIPCION:  se agrega el siguiente filtro "and a.banco_destino = d.cve_banco" al siguiente inner
    -- LEFT JOIN bdiprog:"informix".pp_ctasterceros d
    -- pagos programados por usuario.
    -- AUTOR : Edgar Azael Rosas Velazquez - Solsersistem
    -- FECHA : 30/09/2016
    -- BD: bdibei
    -- SOLICITO :BanCoppel
    --***************************************************************************************************



--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
      
--Cuerpo del procedimiento.
BEGIN
    SET LOCK MODE TO WAIT 10;
    SELECT fecha_hoy INTO v_dfecha FROM bdinteg:"informix".si_fechas;
    --Valida que los parametros de entrada sean diferentes a nulos o blancos
    IF (NVL(p_snum_cte,'') <> '')  THEN
    ELSE
        SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '104';
        RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio;
    END IF;
    
    --se valida que el cliente exista
    IF EXISTS(SELECT empresa  FROM bdinteg:"informix".si_cliente WHERE numcte =  p_snum_cte) THEN
   
        --SE valida que existan pagos programados para ese cliente --Se pone por USUARIO**** primer


        SELECT COUNT (pagoprog.descripcion)
        INTO vCountProgramaciones  
        FROM bdiprog:"informix".pp_pagoprog as pagoprog
        INNER JOIN bdibei:"informix".bei_pp_usuprog AS usuprog ON (pagoprog.cve_pagoprog = usuprog.cve_pagoprog)
        WHERE pagoprog.num_cte = p_snum_cte AND usuprog.id_usuario = p_usuario;

        IF ((vCountProgramaciones - pDesde) > 0) THEN
        --Se seleccionan todos los pagos programados de ese Usuario.
            FOREACH     
                SELECT SKIP pDesde 
                    a.cve_pagoprog,
                    a.cve_estado,
                    a.descripcion as concepto_pago,
                    a.fecha_insert as fecha_programacion,
                    NVL(b.descripcion,'No Definida') as frecuencia, 
                    NVL(a.importe,0) + NVL(a.importe_iva,0) as monto,
                    a.fecha_inicio
                INTO sCve_PagoProg,aCve_Estado,sConcepto_Pago,sFecha_Programacion,
                sFrecuencia,sMonto,sFecha_Inicio
                FROM bdiprog:"informix".pp_pagoprog a 
                INNER JOIN bdibei:"informix".bei_pp_usuprog AS usuprog ON (a.cve_pagoprog = usuprog.cve_pagoprog)
                LEFT JOIN bdiprog:"informix".pp_tpprograma b ON (a.cve_programa = b.cve_programa)
                WHERE a.num_cte = p_snum_cte and usuprog.id_usuario=p_usuario --restriccion 
                ORDER BY a.cve_estado,a.fecha_insert DESC,b.cve_programa

                IF ( iContador = pHasta ) THEN
                    EXIT foreach;
                END IF;

                SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '00';
                LET iContador = iContador + 1;
                RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio WITH RESUME;
            END FOREACH;
        ELSE
            --Se informa que no existen pagos programados para ese cliente
            SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '88';
            RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio;
        END IF;              
    --Se informa que el cliente exista
    ELSE
        SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes where cve_mensaje = '04';
        RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio;
    END IF;
END;
END PROCEDURE;