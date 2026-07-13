CREATE PROCEDURE "informix".sp_idegeneracmensual_2(  pEmpresa CHAR(3),
 pFecha DATE,  pUsuario CHAR(8), pFechaultimodia DATE  )
    -- DATOS A REGRESAR
	RETURNING
    CHAR(5);

    -- DEFINICION DE VARIABLES
    DEFINE vCodRet CHAR(5);
    DEFINE vNumcliente CHAR(20);
    DEFINE vRfc CHAR(13);
    DEFINE vImpacumulado MONEY(16,2);
    DEFINE vImparecaudar MONEY(16,2);
    DEFINE vImprecaudado MONEY(16,2);
    DEFINE vImppendiente MONEY(16,2);
    DEFINE vImpanterior  MONEY(16,2);
    DEFINE vTipocambio   MONEY(16,2);
    DEFINE vAniomes CHAR(6);
    DEFINE vProceso CHAR(10);
    DEFINE vcStatus CHAR(1);
    DEFINE vmImpGrabado MONEY(16,2);
    DEFINE vdUltimoDiaMes DATE;
    DEFINE vsqlerr  integer;
    DEFINE vcAnio   CHAR(4);
    DEFINE vcIniciaTran CHAR(1);

	--INICIALIZACION DE VARIABLES--
    LET vCodRet = "000";
    LET vNumcliente = "";
    LET vRfc = "";
    LET vImpacumulado = 0;
    LET vImparecaudar = 0;
    LET vImprecaudado = 0;
    LET vImppendiente = 0;
    LET vImpanterior = 0;
    LET vTipocambio = 0;
    LET vAniomes = "";
    LET vProceso = '';
    LET vcStatus = '';
    LET vmImpGrabado = 0.00;
    LET vsqlerr = 0;
    LET vdUltimoDiaMes = '';
    LET vcAnio = year(pFecha);
    LET vcIniciaTran = 'N';

     BEGIN

        ON EXCEPTION  SET vsqlerr
                IF vsqlerr <> 0  THEN
                        IF  vcIniciaTran = 'S' THEN
                             ROLLBACK WORK; 
                        END IF;
                     LET  vCodRet  = vsqlerr;
                     RETURN vCodRet;
                END IF;
         END  EXCEPTION;

       -- SET DEBUG FILE TO "/tmp/sp_idegeneraconstanciamensual.out";
        --TRACE ON;

        -- SE TOMA EL ANO Y MES CON BASE EN LA FECHA DE PARÁMETRO
        LET vAniomes         =  CAST(TO_CHAR(pFecha, '%Y%m') as char(6));
        -- SE OBTIENE ÚLTIMO DÍA DEL MES
        LET vdUltimoDiaMes = pFecha;

        -- SE VERIFICA QUE SE HAYA EJECUTADO EL PROCESO DE DECLARACIÓN MENSUAL
        IF EXISTS (SELECT proceso FROM sl_procesos WHERE proceso = 'ret_dialde' AND fech_proceso  = vdUltimoDiaMes AND status = 1 ) THEN


            -- SE OBTIENE EL ESTADO DEL PROCESO CONSTANCIA MENSUAL
            SELECT status  INTO vcStatus FROM bdilide:sl_procesos  WHERE proceso  = "conmensual" AND  fech_proceso =  pFecha;
           -- SI ES NÚLO EL PROCESO NO EXISTE Y ENTONCES SE REGISTRA
            IF vcStatus IS NULL THEN
                INSERT INTO bdilide:sl_procesos VALUES("conmensual", pFecha, '0', pUsuario, CURRENT ::DATE );
            ELIF vcStatus = '0' or  vcStatus = '' THEN
                DELETE FROM bdilide:sl_constancias WHERE aniomes = vAnioMes and tipo_cons = 'M';
            ELIF vcStatus = '1' THEN
                LET vCodRet = '002';
                RETURN vCodRet;
            END IF;

            
            
            BEGIN WORK; LET vcIniciaTran = 'S';
            FOREACH
                SELECT  DISTINCT nvl(num_cte, ''), nvl(rfc, '')
                INTO vNumcliente, vRfc
                FROM bdilide:sl_detlide
                WHERE CAST(TO_CHAR(fecha_ret, '%Y%m') as char(6))  = vAnioMes
                 -- SE OBTIENE EL IMPUESTO RECAUDADO DE LOS MESES ANTERIORES EN EL MES ACTUAL.
                SELECT nvl(SUM(imp_recaudado), 0)
                INTO vImpanterior
                FROM bdilide:sl_detlide
                WHERE CAST(TO_CHAR(fecha_ret, '%Y%m') as char(6))  = vAniomes AND aniomes < vAnioMes AND num_cte = vNumcliente; --AND  SUBSTRING(aniomes FROM 1 FOR 4) = vcAnio;

                IF EXISTS (SELECT num_cte FROM bdilide:sl_retlide WHERE aniomes = vAniomes AND num_cte = vNumcliente) THEN
                         -- SE OBTIENE LOS DATOS DEL LA TABLA bdilide:sl_retlide
                         SELECT  nvl(imp_acumulado, 0),NVL(imp_gravado,0), nvl(imp_arecaudar, 0),
                                          nvl(imp_recaudado, 0), (nvl(imp_arecaudar,0) - nvl(imp_recaudado, 0))
                        INTO  vImpacumulado, vmImpGrabado, vImparecaudar, vImprecaudado, vImppendiente
                        FROM bdilide:sl_retlide
                        WHERE aniomes = vAniomes AND num_cte = vNumcliente;
                ELSE
                        LET vImpacumulado = 0.00;
                        LET vmImpGrabado  = 0.00;
                        LET vImparecaudar = 0.00;
                        LET vImppendiente = 0.00;
                        LET vImprecaudado = 0.00;

                END IF;
                -- SE INSERTA EN LA TABLA bdilide:sl_constancias CON LOS DATOS OBTENIDOS ANTERIORMENTE.
                INSERT INTO bdilide:sl_constancias
                VALUES (vAnioMes, vNumcliente, 'M', vRfc, vmImpGrabado, vImparecaudar, vImprecaudado,vImppendiente, vImpanterior,vTipocambio, pUsuario, CURRENT::DATE);
            END FOREACH;
            
            -- SE ACTUALIZA ÉSTE PROCESO PARA INDICAR QUE SE EJECUTÓ CORRECTAMENTE. (PROCESO DE CONSTANCIAS MENSUAL).
            UPDATE bdilide:sl_procesos set status = '1' WHERE proceso = 'conmensual' AND fech_proceso = pFecha;
            COMMIT WORK;  LET vcIniciaTran = 'N';

        ELSE
            LET vCodRet = "001";
            RETURN vCodRet;
        END IF;

    END;

    RETURN vCodRet;
END PROCEDURE;