CREATE PROCEDURE "informix".sp_gettypeoftransaction( psProdInd CHAR (2), psMessType CHAR (4), psTipoTran CHAR (2), pmMonto MONEY, pmMontoCashBack MONEY )

RETURNING INTEGER ;

--****************************************************************************************************
-- DESCRIPCION: ASIGNA EL TIPO DE TRANSACCION SEGUN LOS DATOS DE LA TRANSACCION
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viTipoTransaccion INTEGER ;


/* INICIALIZACION DE VARIABLES */
LET viTipoTransaccion  = 0 ;

BEGIN

    --ASIGNA LA CLAVE DE LA TRANSACCION SEGUN LA DESCRIPCION DE ESTA

    IF (psProdInd = '01') AND (psMessType = '0200') AND (psTipotran = '31') THEN
        LET viTipoTransaccion = 200 ; --CONSULTA_ATM
    ELIF (psProdInd = '01') AND (psMessType = '0200') AND (psTipotran = '01') THEN
        LET viTipoTransaccion = 201 ; --RETIRO_ATM
    ELIF (psProdInd = '01') AND (psMessType = '0200') AND (psTipotran = '94') THEN
        LET viTipoTransaccion = 211 ; --VALIDACION_NIP
    ELIF (psProdInd = '01') AND (psMessType = '0200') AND (psTipotran = '95') THEN
        LET viTipoTransaccion = 212 ; --ASIGNACION_NIP
    ELIF (psProdInd = '01') AND (psMessType = '0200') AND (psTipotran = '85') THEN
        LET viTipoTransaccion = 199 ; --CAMBIO_NIP_ATM
    ELIF ((psProdInd = '01') AND (psMessType = '0420') OR (psMessType = '0421')) THEN
        LET viTipoTransaccion = 202 ; --REVERSA_ATM
    ELIF ((psProdInd = '02') AND (psMessType = '0200') AND (psTipotran = '00')) THEN
        LET viTipoTransaccion = 203 ; --COMPRA_POS
    ELIF ((psProdInd = '02') AND (psMessType = '0200') AND (psTipotran = '09')) THEN
        IF ((pmMonto > 0) AND (pmMonto > pmMontoCashBack)) THEN
            LET viTipoTransaccion = 207 ; --CASH_BACK_POS
        ELIF (pmMonto = pmMontoCashBack) THEN
            LET viTipoTransaccion = 209 ; --CASH_ADVANCE_POS
        END IF ;
    ELIF ((psProdInd = '02') AND ((psMessType = '0420') OR (psMessType = '0421')) AND (psTipotran = '00')) THEN
        LET viTipoTransaccion = 204 ; --REVERSA_POS
    ELIF ((psProdInd = '02') AND ((psMessType = '0420') OR (psMessType = '0421')) AND (psTipotran = '09')) THEN
        IF ((pmMonto > 0) AND (pmMonto > pmMontoCashBack)) THEN
            LET viTipoTransaccion = 208 ;  --REVERSA_CASH_BACK_POS
        ELIF (pmMonto = pmMontoCashBack) THEN
            LET viTipoTransaccion = 210 ; --REVERSA_CASH_ADVANCE_POS
        END IF ;
    ELIF ((psProdInd = '02') AND ((psMessType = '0220') OR (psMessType = '0221'))) THEN
        LET viTipoTransaccion = 205 ; --FORZADA_POS 
    END IF ;


    RETURN viTipoTransaccion ;

END 

END PROCEDURE 
;