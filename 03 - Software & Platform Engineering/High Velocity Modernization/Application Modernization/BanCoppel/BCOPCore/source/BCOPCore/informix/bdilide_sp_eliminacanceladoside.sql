CREATE PROCEDURE "informix".sp_eliminacanceladoside()
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vcCodRet               CHAR(5);
DEFINE vcMensaje             CHAR(80);
DEFINE SQL_ERR              INTEGER;
DEFINE ISAM_ERR             INTEGER;
DEFINE ERROR_INFO       VARCHAR(200);
DEFINE vcNumCte             CHAR(20);
DEFINE vcNumSerial         INTEGER;
DEFINE vcTipoCuenta        CHAR(1);
DEFINE vcNumCuenta       CHAR(20);
DEFINE vdFechaMov           DATE;
DEFINE vcCancelado          CHAR(1);
DEFINE vcReversado          CHAR(1);
DEFINE vcEmpresa             CHAR(3);
DEFINE vcSucursal              CHAR(4);
--INICIALIZACION DE VARIABLES
LET vcCodRet = "00000";
LET vcMensaje = "PROCESO EXITOSO";
LET SQL_ERR = 0;
LET ISAM_ERR  = 0;
LET ERROR_INFO = "";
LET vcNumCte = "";
LET vcNumSerial = 0;
LET vcTipoCuenta = "";
LET vcNumCuenta = "";
LET vdFechaMov = "";
LET vcCancelado = "";
LET vcReversado = "";
LET vcEmpresa = "001";
LET vcSucursal = "";
--******DATOS DE ELABORACION*****
    --Programador: Aymme Osuna.
    --Fecha de Elaboración: 02-07-2008
    --Hora: 16:00.
    --Descripcion: El proceso se encarga de eliminar movimientos que esten cancelados
    --en crédito y débito.
--****************************************
BEGIN
        --OBTIENE LOS ERRORES CONTROLADOS POR INFORMIX
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            LET vcCodRet = SQL_ERR;
            LET vcMensaje = ERROR_INFO;
            RETURN vcCodRet, vcMensaje;
        END EXCEPTION;
        -- SET DEBUG FILE TO '/tmp/sp_EliminaCanceladosIDE.out';
        -- TRACE ON;

        FOREACH
                --RECORRE LA TABLA DE MOVIMIENTOS DEL LIDE
                SELECT num_cte, num_serial, tipo_cta, sucursal, num_cta, fecha_mov
                INTO vcNumCte, vcNumSerial, vcTipoCuenta, vcSucursal, vcNumCuenta, vdFechaMov
                FROM bdilide:sl_movefec
                
                IF vcTipoCuenta = "D" THEN
                        --DEBITO
                        SELECT cancelad INTO vcCancelado FROM bdicheq:sc_movhis
                        WHERE empresa = vcEmpresa AND num_serial = vcNumSerial  AND sucursal = vcSucursal  AND cuenta = vcNumCuenta AND fech_alt = vdFechaMov;
                        IF vcCancelado = "S" THEN
                            --BORRA EL REGISTRO DE LA TABLA DE MOVIMIENTOS DEL LIDE
                            DELETE FROM bdilide:sl_movefec WHERE num_cte = vcNumCte AND num_serial = vcNumSerial AND num_cta = vcNumCuenta
                            AND fecha_mov = vdFechaMov;
                        END IF;
                ELIF vcTipoCuenta = "C" THEN
                        --CREDITO
                        SELECT reversado INTO vcReversado FROM bdicred:sd_movhis
                        WHERE empresa = vcEmpresa AND secuencia = vcNumSerial AND fecha_mov = vdFechaMov AND sucursal = vcSucursal  AND num_credito = vcNumCuenta;
                        IF vcReversado = "S" THEN
                            --BORRA EL REGISTRO DE LA TABLA DE MOVIMIENTOS DEL LIDE
                            DELETE FROM bdilide:sl_movefec WHERE num_cte = vcNumCte AND num_serial = vcNumSerial AND num_cta = vcNumCuenta
                            AND fecha_mov = vdFechaMov; 
                        END IF;
                END IF;

        END FOREACH;

        RETURN vcCodRet, vcMensaje;

END;
END PROCEDURE;