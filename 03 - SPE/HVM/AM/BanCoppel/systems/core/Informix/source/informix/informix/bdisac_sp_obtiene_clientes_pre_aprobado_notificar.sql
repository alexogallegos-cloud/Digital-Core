CREATE PROCEDURE "informix".sp_obtiene_clientes_pre_aprobado_notificar(pSucursal CHAR(4))

RETURNING   CHAR(6)         AS codigo,          -- CODIGO DE RETORNO
                        CHAR(20)                AS numcte,              --Numero De Cliente
                        CHAR(26)                AS nombre1,             --Primer Nombre
                        CHAR(26)                AS nombre2,             --Segundo Nombre
                        CHAR(26)                AS apellido1,   --Primer Apellido
                        CHAR(26)                AS apellido2,   --Segundo Apellido
                        CHAR(4)                 AS noproducto,  --Numero de Producto
                        CHAR(50)                AS nombreprod,  --Nombre de Producto
                        CHAR(50)                AS nombreejecut,--Nombre de Ejecutivo
                        DATETIME HOUR TO SECOND         AS hora;                        --Hora

DEFINE isqlerr          INTEGER;                        -- CODIGO DE ERROR
-- VARIABLES PARA RETORNO DE DATOS
DEFINE cCodRet                  CHAR(6);                        -- CODIGO DE RETORNO DE ERROR
DEFINE cCodRetTDif              CHAR(6);                -- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE dFechaCouta              DATE;                           -- FECHA
DEFINE cNumCte                  CHAR(20);
DEFINE dHora                DATETIME HOUR TO SECOND;
DEFINE cNombreCte               CHAR(26);
DEFINE cNombre2Cte              CHAR(26);
DEFINE cAp1Cte                  CHAR(26);
DEFINE cAp2Cte                  CHAR(26);
DEFINE cNumProducto             CHAR(4);
DEFINE cNombreProducto  CHAR(50);
DEFINE cEstatusNot              CHAR(2);
DEFINE cNombreEjecutivo CHAR(50);
DEFINE cEjecutivo               CHAR(8);
DEFINE iCountCtesDiaAnt SMALLINT;
DEFINE vtransaccion     CHAR(1);

LET iSqlErr             = 0;
LET cCodRet             = "000000";
LET cCodRetTDif         = '';
LET dFechaCouta         = DATE(1);
LET cNumCte                     ='';
LET dHora                       = EXTEND(DATE(1),HOUR TO SECOND);
LET cNombreCte          ='';
LET cNombre2Cte         ='';
LET cAp1Cte                     ='';
LET cAp2Cte                     ='';
LET cNumProducto        ='';
LET cNombreProducto     ='';
LET cEstatusNot         ='';
LET cNombreEjecutivo='';
LET cEjecutivo          ='';
LET iCountCtesDiaAnt=0;
LET vtransaccion='0';

BEGIN

        ON EXCEPTION  SET iSqlErr
                IF iSqlErr <> 0  THEN
                        LET  cCodRet  = iSqlErr;
                        RETURN cCodRet,cNumCte,cNombreCte,cNombre2Cte,cAp1Cte,cAp2Cte,cNumProducto,cNumProducto,cNombreEjecutivo,dHora;
                END IF;
        END  EXCEPTION
        ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

        SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

        -- Inicia transacción
    --BEGIN WORK;
        SELECT COUNT(numcte) INTO iCountCtesDiaAnt FROM bdicred:"informix".sd_pre_aprobados_notificar WHERE fecha_insert < TODAY;

        IF iCountCtesDiaAnt > 0 THEN
                DELETE bdicred:"informix".sd_pre_aprobados_notificar WHERE fecha_insert < TODAY;
        END IF;

        SELECT estatus INTO cEstatusNot
        FROM bdicred:"informix".sd_pre_aprobados_cat_not
        WHERE codigo=1;

        FOREACH SELECT numcte, EXTEND(fecha_insert,HOUR TO SECOND),num_producto,ejecutivo
                        INTO cNumCte,dHora,cNumProducto,cEjecutivo
                        FROM bdicred:"informix".sd_pre_aprobados_notificar
                        WHERE DATE(fecha_insert)=DATE(CURRENT) AND sucursal=pSucursal AND estatus_notificacion=cEstatusNot ORDER BY fecha_insert DESC
        --Nombre de cliente
                SELECT nombre1,nombre2,apell_paterno,apell_materno
                INTO cNombreCte,cNombre2Cte,cAp1Cte,cAp2Cte
                FROM bdinteg:"informix".si_cliente
                WHERE numcte=cNumCte;
                --Nombre ejecutivo ventanilla
                SELECT nombre
                INTO cNombreEjecutivo
                FROM bdinteg:"informix".si_ejecut
                WHERE ejecutivo=cEjecutivo;

                SELECT nombre_prod
                INTO cNombreProducto
                FROM bdicred:"informix".sd_definicion
                WHERE num_producto=cNumProducto;

                RETURN cCodRet,cNumCte,cNombreCte,cNombre2Cte,cAp1Cte,cAp2Cte,cNumProducto,cNombreProducto,cNombreEjecutivo,dHora WITH RESUME;
    END FOREACH;
        COMMIT WORK; -- Confirma transacciones
END;
END PROCEDURE;