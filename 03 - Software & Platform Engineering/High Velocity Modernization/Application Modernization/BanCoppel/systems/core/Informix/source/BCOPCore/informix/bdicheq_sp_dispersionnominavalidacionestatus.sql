CREATE PROCEDURE "informix".sp_dispersionnominavalidacionestatus( pCuenta CHAR(20),
                                                                  pNumeroEmpresa CHAR(3),
                                                                  pFechaGeneracion CHAR(10),
                                                                  pFolioArchivo INTEGER,
                                                                  pFechaActual CHAR(10),
                                                                  pHoraActual CHAR (8),
                                                                  pNombreArchivo CHAR(17),
                                                                  pNumeroEmpleado CHAR(10),
                                                                  pImporteEmpleado MONEY(18,2),
                                                                  pImporteNoAbonado MONEY(18,2),
                                                                  piTipoEmpresa		CHAR(1) )
RETURNING CHAR(3),CHAR(1),CHAR(1),MONEY(18,2),CHAR(4),CHAR(4);
    
    DEFINE vcodret          CHAR(3);
    DEFINE cEstatusCuenta   CHAR(1);
    DEFINE cSucursalAbono   CHAR(4);
    DEFINE cSucursalCargo   CHAR(4);
    DEFINE cMotivo          CHAR(2);
    DEFINE cConsulta        CHAR(1);
    DEFINE iExiste          INTEGER;
    DEFINE iAceptab         INTEGER;
    DEFINE iSqlerr          INTEGER;
    DEFINE iBandera         INTEGER;

    Begin
    
    ON EXCEPTION SET iSqlerr
        IF iSqlerr <> 0 THEN
            Let vcodret = iSqlerr; 
            RETURN vcodret,cEstatusCuenta,cConsulta,NVL(pImporteNoAbonado,'0.00'),cSucursalCargo,cSucursalAbono;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- Set Debug File To '/tmp/sp_dispersionnominavalidacionestatus.out';
    --- Trace On;
    
    LET vcodret = "000";
    LET cEstatusCuenta	 = "";
    LET cSucursalAbono = "";
    LET cSucursalCargo	= "";
    LET cMotivo = "";
    LET cConsulta = "";
    LET iExiste = 0;
    LET iAceptab = 0;
    LET iBandera = 0;

    IF  pCuenta  <> "" AND pNumeroEmpresa <> "" AND pFechaGeneracion <> "" AND pFolioArchivo <> 0 AND pFechaActual <> "" AND pHoraActual <> "" THEN
        LET iBandera = 1;
        LET pImporteNoAbonado = '0.00';
    ELSE
        IF pCuenta  <> ""  AND pNombreArchivo <> "" AND pNumeroEmpleado <> "" AND NOT pImporteEmpleado IS NULL  AND NOT pImporteNoAbonado IS NULL AND piTipoEmpresa <> "" THEN
            LET iBandera = 2;
        END IF
    END IF;

    IF iBandera <> 1 AND iBandera <> 2 THEN
        LET vcodret = '805';
    END IF

    /* INICIO de Consulta para la cuenta eje */
    IF iBandera = 1 THEN
        Let cEstatusCuenta = '';
        Let cSucursalCargo = '';
        
        SELECT status_cta, sucursal,motivo 
          INTO cEstatusCuenta, cSucursalCargo, cMotivo
          FROM bdicheq:sc_maechq 
         WHERE empresa = '001' 
           AND cuenta = pCuenta;
        
        /* La Cuenta esta Cancelada */
        IF cEstatusCuenta IN('2','6','7','8') THEN   
            Let vcodret = "815";
            
             /* Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo */
            UPDATE bdicheq:sc_nominaencabezadosumario  
               SET status = '8', 
                   fecha_aplicado = pFechaActual, 
                   hora_aplicado = pHoraActual
             WHERE empresa = pNumeroEmpresa 
               AND fecha_gen = pFechaGeneracion 
               AND folio_archivo = pFolioArchivo;
        END IF

        IF cEstatusCuenta = '3' THEN   -- La Cuenta esta Bloqueada

            SELECT "1" 
              INTO iExiste 
              FROM sc_ctabloqueo 
             WHERE cuenta = pCuenta;

            IF iExiste = "1" THEN

                SELECT opcion 
                  INTO iAceptab 
                  FROM sc_ctabloqueo 
                  WHERE cuenta = pCuenta;

                IF iAceptab = 4 THEN
                    Let vcodret = "820";
                    
                    /* Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo */
                    UPDATE bdicheq:sc_nominaencabezadosumario  
                       SET status = '9',
                           fecha_aplicado = pFechaActual,
                           hora_aplicado = pHoraActual
                     WHERE empresa = pNumeroEmpresa
                       AND fecha_gen = pFechaGeneracion
                       AND folio_archivo = pFolioArchivo;
                END IF;

                IF iAceptab = 3 THEN
                    Let vcodret = "820";
                    
                    /* Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo */
                    UPDATE bdicheq:sc_nominaencabezadosumario  
                       SET status = '9',
                           fecha_aplicado = pFechaActual,
                           hora_aplicado = pHoraActual
                     WHERE empresa = pNumeroEmpresa
                       AND fecha_gen = pFechaGeneracion
                       AND folio_archivo = pFolioArchivo;
                END IF;
            ELSE
                /* Selecciono el campo cargo de sc_bloqueo, para saber si el tipo de bloqueo admite o no cargos */
                SELECT cargo 
                  INTO cConsulta 
                  FROM sc_bloqueo 
                 WHERE codigo=cMotivo;

                IF cConsulta = 'N' THEN
                    Let vcodret = "820";
                    
                    /* Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo */
                    UPDATE bdicheq:sc_nominaencabezadosumario  
                       SET status = '9',
                           fecha_aplicado = pFechaActual,
                           hora_aplicado = pHoraActual
                     WHERE empresa = pNumeroEmpresa
                       AND fecha_gen = pFechaGeneracion
                       AND folio_archivo = pFolioArchivo;
                END IF
            END IF
        END IF
    END IF  /* FIN de Consulta para la cuenta eje */

    /* INICIO de Consulta para la cuenta Empleado */
    IF iBandera = 2 THEN
        Let cEstatusCuenta = '';
        Let cSucursalAbono = '';
        LET  cConsulta = "S";
        
        SELECT status_cta, sucursal,motivo 
          INTO cEstatusCuenta, cSucursalAbono,cMotivo 
          FROM bdicheq:sc_maechq
         WHERE empresa = '001' 
           AND cuenta = pCuenta;

        IF cEstatusCuenta IN('2','6','7','8') THEN
            LET  cConsulta = "N"; 
            
            /* Cuenta Cancelada */
            UPDATE bdicheq:sc_nominamovimientos
               SET status = cEstatusCuenta   
             WHERE nombre_archivo = pNombreArchivo 
               AND num_empleado = pNumeroEmpleado;

            IF piTipoEmpresa = 2 THEN
                Let pImporteNoAbonado = pImporteNoAbonado + pImporteEmpleado;
            END IF
        END IF
        
        IF cEstatusCuenta = '3' THEN
            SELECT "1" 
              INTO iExiste  
              FROM sc_ctabloqueo 
             WHERE cuenta = pCuenta;

            IF iExiste = "1" THEN

                SELECT opcion 
                  INTO iAceptab 
                  FROM sc_ctabloqueo 
                 WHERE cuenta = pCuenta;

                IF iAceptab = 4 THEN
                    LET cConsulta = "N";
                    Let vcodret = "820";
                    
                    /* Cuenta Bloqueada */
                    UPDATE bdicheq:sc_nominamovimientos 
                       SET status = cEstatusCuenta
                     WHERE nombre_archivo = pNombreArchivo 
                       AND num_empleado = pNumeroEmpleado;

                    IF piTipoEmpresa = 2 THEN
                        Let pImporteNoAbonado = pImporteNoAbonado + pImporteEmpleado;
                    END IF
                END IF;
                
                IF iAceptab = 2 THEN
                    LET cConsulta = "N";
                    Let vcodret = "820";
                    
                    /* Cuenta Bloqueada */
                    UPDATE bdicheq:sc_nominamovimientos 
                       SET status = cEstatusCuenta
                     WHERE nombre_archivo = pNombreArchivo 
                       AND num_empleado = pNumeroEmpleado;

                    IF piTipoEmpresa = 2 THEN
                        Let pImporteNoAbonado = pImporteNoAbonado + pImporteEmpleado;
                    END IF
                END IF;
            ELSE
                /* Selecciono el campo Abono de sc_bloqueo, para saber si el tipo de bloqueo admite o no Abonos */
                SELECT abono 
                  INTO cConsulta 
                  FROM sc_bloqueo 
                 WHERE codigo = cMotivo;

                IF cConsulta = 'N' THEN
                    Let vcodret = "820";

                    /* Cuenta Bloqueada */
                    UPDATE bdicheq:sc_nominamovimientos 
                       SET status = cEstatusCuenta
                     WHERE nombre_archivo = pNombreArchivo 
                       AND num_empleado = pNumeroEmpleado;

                    IF piTipoEmpresa = 2 THEN
                        Let pImporteNoAbonado = pImporteNoAbonado + pImporteEmpleado;
                    END IF
                END IF
            END IF
        END IF
    END IF  /* FIN de Consulta para la cuenta Empleado */
    
    RETURN vcodret,cEstatusCuenta,cConsulta,pImporteNoAbonado,cSucursalCargo,cSucursalAbono;
    
    END
    
END Procedure

DOCUMENT
'DESCRIPCION: Genera las validaciones para el estatus de la cuenta a consultar para la dispersion de nomina"',
'AUTOR: Jesus Antonio Bastidas Lopez',
'FECHA: Abril de 2009',
'VERSION: 200904',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_obtenercuentascheques(pempresa CHAR(3),pnum_cte CHAR(9),pProducto CHAR(4),pmoneda CHAR(2),pRegistro SMALLINT)
RETURNING CHAR(5),CHAR(20),money(14,2);
    
    --*******************************************
    --sp_obtenerCuentasCheques
    --Objetivo: obtener las cuentas efectiva cheques, de un cliente especifico
    --Autor: Francisco Rodriguez Ibarra
    --Fecha: 30 marzo 2010
    --*********************************************
    
    --Declaracion de variables
    DEFINE vSqlErr 		INTEGER;
    DEFINE cod_ret  	CHAR(5);
    DEFINE v_cuenta		CHAR(20);
    DEFINE vSdoCta      money(14,2);
    DEFINE vRegistros    INTEGER;
    DEFINE iCont		INTEGER;
    
    --Asignacion de Valores a Variables
    LET cod_ret='00000';
    LET vSqlErr = 0;
    LET v_cuenta ='';
    LET vSdoCta = 0;
    LET iCont=0;
    LET vRegistros=0;

    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            let cod_ret = vSqlErr;
            --ROLLBACK WORK;
            RETURN cod_ret, v_cuenta, vSdoCta;
        END IF;
    END EXCEPTION;

    IF ( pempresa = '' OR pempresa IS NULL OR pnum_cte = '' OR
         pnum_cte IS NULL OR pmoneda = '' OR pmoneda IS NULL OR
         pRegistro = '' OR pRegistro IS NULL) THEN
        LET cod_ret = 100; --Parametros no validos.
        RETURN cod_ret, v_cuenta, vSdoCta;
    END IF

    SET ISOLATION DIRTY READ;

    FOREACH
        SELECT SKIP pRegistro FIRST 10 cuenta,sdo_actual
          INTO v_cuenta ,vSdoCta
          FROM bdicheq:sc_maechq  
         WHERE empresa = TRIM(pempresa)
           AND producto = TRIM(pProducto) 
           AND num_cte = TRIM(pnum_cte)
           AND status_cta NOT IN('2','6','7','8')

        LET iCont = iCont + 1;
        RETURN cod_ret, v_cuenta, vSdoCta WITH RESUME;
    END FOREACH

    IF ( iCont = 0 AND pRegistro = 0 ) THEN
        LET cod_ret = 101; -- Cliente No tiene cuentas
        RETURN cod_ret, v_cuenta, vSdoCta;
    END IF

    END;
    
END PROCEDURE;