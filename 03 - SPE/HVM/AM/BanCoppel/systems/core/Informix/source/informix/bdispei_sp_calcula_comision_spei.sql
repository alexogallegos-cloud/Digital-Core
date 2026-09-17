CREATE PROCEDURE "informix".sp_calcula_comision_spei(
                pmnymonto money,
                pchrsucursal char(4)
)RETURNING money
{
CREADO POR :Cristian Campos
FECHA DE CREACION 10 De Enero del 2007
FUNCIONALIDAD: Utilizado para el calculo de comisiones en el cobro del SPEI


Parametros de Entrada
    pmnymonto : Indica el monto a enviar
    pchrsucursal: Indica la sucursal que hace el envio

Parametros de Salida:
    Comision: Indica cuanto se cobra de comision

}

DEFINE vmnycomision money;

        LET vmnycomision = 0;

            IF (pchrsucursal IS NULL) OR (pchrsucursal='') THEN
                SELECT  mnycomision into vmnycomision FROM informix.tblcomision 
                    WHERE pmnymonto BETWEEN mnymontomin AND mnymontomax  AND NVL(chrsucursal,'') = '';
            ELSE
                SELECT  mnycomision into vmnycomision FROM informix.tblcomision 
                    WHERE pmnymonto BETWEEN mnymontomin AND mnymontomax  AND chrsucursal = pchrsucursal;
            END IF;

        RETURN vmnycomision;

END PROCEDURE;