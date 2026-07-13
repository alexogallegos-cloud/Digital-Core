CREATE PROCEDURE "informix".sp_fuscte_elidocdig(pNumeroCliente CHAR(20), pUsuario CHAR(8))
RETURNING CHAR(5);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet    CHAR(5);
DEFINE vi_SqlErr    INTEGER;
DEFINE vc_Cuenta    CHAR(20);
DEFINE vc_Producto  CHAR(4);
DEFINE vs_Secuencia SMALLINT;
DEFINE vd_FechaAlta DATE;
DEFINE vc_Tabla     CHAR(50);
DEFINE vc_Detalle   CHAR(100);
DEFINE vc_Proceso   CHAR(60);
DEFINE vc_cod_docto    CHAR(4);
--DECLARACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vc_Cuenta = "";
LET vc_Producto = "";
LET vs_Secuencia = 0;
LET vd_FechaAlta = "";
LET vc_Tabla = "";
LET vc_Detalle = "";
LET vc_Proceso = "DEPURACION DE DOCUMENTOS NO TRASPASADOS AL TITULAR";
LET vc_cod_docto = "";
BEGIN
    ON EXCEPTION SET vi_SqlErr
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            RETURN vc_CodRet;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/sp_fuscte_EliDocDig.out";
    --TRACE ON;

        LET vc_Tabla = "bdidigital:dg_expediente";
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT cuenta, producto, cod_docto, secuencia, fecha_alta
            INTO vc_Cuenta, vc_Producto, vc_cod_docto, vs_Secuencia, vd_FechaAlta
            FROM bdidigital@coppelimg_tcp:dg_expediente
            WHERE cliente = pNumeroCliente

            LET vc_Detalle = TRIM(pNumeroCliente)||'|'||TRIM(vc_Cuenta)||'|'||TRIM(vc_Producto)||'|'||TRIM(vc_cod_docto)||'|'||vs_Secuencia||'|'||vd_FechaAlta||'|'||"DOCUMENTO ELIMINADO";

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_Proceso, vc_Tabla, "", pNumeroCliente, vc_Detalle, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

--            DELETE bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = "001" AND cliente = pNumeroCliente AND cuenta = vc_Cuenta AND cod_docto = vc_cod_docto AND secuencia = vs_Secuencia;
        END FOREACH;
         
        LET vc_Tabla = "bdidigital:dg_expediente_img";
         FOREACH
            SELECT cod_docto, secuencia, fecha_alta
            INTO vc_cod_docto, vs_Secuencia, vd_FechaAlta
            FROM bdidigital@coppelimg_tcp:dg_expediente_img
            WHERE empresa = "001" AND cliente = pNumeroCliente

            LET vc_Detalle = TRIM(pNumeroCliente)||'|'||TRIM(vc_cod_docto)||'|'||vs_Secuencia||'|'||vd_FechaAlta;

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_Proceso, vc_Tabla, "", pNumeroCliente, vc_Detalle, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

--            DELETE bdidigital@coppelimg_tcp:dg_expediente_img WHERE empresa = "001" AND cliente = pNumeroCliente AND cod_docto = vc_cod_docto AND secuencia = vs_Secuencia;
         END FOREACH;

   RETURN  vc_CodRet;
END;
END PROCEDURE;