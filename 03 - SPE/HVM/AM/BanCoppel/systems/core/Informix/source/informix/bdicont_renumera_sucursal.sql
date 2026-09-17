CREATE PROCEDURE "informix".renumera_sucursal()

DEFINE v_usuario CHAR(8);
DEFINE v_ctrl_poliza INTEGER;
DEFINE v_fecha_captura DATE;


SET ISOLATION TO DIRTY READ;

SELECT usuario,control_poliza,fecha_captura FROM co_mensual 
WHERE length (usuario) = 4
AND usuario NOT IN ('spei')
AND control_poliza IN (SELECT control_poliza
                         FROM co_mensual 
                        WHERE control_poliza > 0
                          AND secuencia = 2
                     GROUP BY control_poliza
                       HAVING count(*) > 1 )
AND fecha_captura >= '01092011'
GROUP BY 1,2,3
INTO TEMP mensual_tmp WITH NO LOG;

    FOREACH WITH HOLD
        SELECT a.usuario, a.control_poliza, a.fecha_captura 
          INTO v_usuario, v_ctrl_poliza, v_fecha_captura
          FROM co_mensual a, mensual_tmp b
         WHERE a.usuario = b.usuario
           AND a.control_poliza = b.control_poliza
           AND a.fecha_captura = b.fecha_captura
           
        BEGIN WORK;    
            UPDATE co_mensual 
               SET descripcion = TRIM(descripcion) || ' ' || (control_poliza), control_poliza = control_poliza + 7250
             WHERE usuario = TRIM(v_usuario)
               AND control_poliza = v_ctrl_poliza
               AND fecha_captura = v_fecha_captura;
        COMMIT WORK;
                           
    END FOREACH;

END PROCEDURE;