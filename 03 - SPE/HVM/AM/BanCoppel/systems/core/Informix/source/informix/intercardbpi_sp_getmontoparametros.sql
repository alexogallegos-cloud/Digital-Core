CREATE PROCEDURE "informix".sp_getmontoparametros(  piTipoTransaccion INTEGER, psNacional CHAR (1), psEsPropio CHAR (1), psEsConvenio CHAR (1) )

RETURNING MONEY ;

--****************************************************************************************************
-- DESCRIPCION: 
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */ 
DEFINE vmMontoCom MONEY  ;

/* INICIALIZACION DE VARIABLES */
LET vmMontoCom = 0 ;

BEGIN

    IF ( piTipoTransaccion = 200 ) THEN -- CONSULTA_ATM

        IF ( psEsConvenio = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComConsATMConvenio, 0 )  INTO vmMontoCom  FROM Parametros ;        
        ELIF ( psEsPropio = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComConsATMPropio, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELIF ( psNacional = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComConsATMnac, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELSE
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComConsATMint, 0 )  INTO vmMontoCom  FROM Parametros ;
        END IF ;

    ELIF ( piTipoTransaccion = 201 ) THEN -- RETIRO_ATM

        IF ( psEsConvenio = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRetATMConvenio, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELIF ( psEsPropio = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRetATMPropio, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELIF ( psNacional = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRetATMnac, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELSE 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRetATMint, 0 )  INTO vmMontoCom  FROM Parametros ;
        END IF ;

    ELIF ( piTipoTransaccion = 203 ) THEN -- COMPRA_POS

        IF ( psNacional = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComCompraPOSnac, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELSE
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComCompraPOSint, 0 )  INTO vmMontoCom  FROM Parametros ;
        END IF ;

    ELIF ( piTipoTransaccion = 210 ) THEN -- CASHBACK_POS

        IF ( psNacional = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComCashBackNac, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELSE
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComCashBackNac, 0 )  INTO vmMontoCom  FROM Parametros ;
        END IF ;

    ELIF ( piTipoTransaccion = 211 ) THEN -- CASHADVANCE_POS

        IF ( psNacional = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComCashAdvanceNac, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELSE
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComCashAdvanceNac, 0 )  INTO vmMontoCom  FROM Parametros ;
        END IF ;

    ELIF ( piTipoTransaccion = 202 ) THEN -- REVERSA_ATM

        IF ( psEsConvenio = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRevATMConvenio, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELIF ( psEsPropio = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRevATMPropio, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELIF ( psNacional = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRevATMnac, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELSE 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRevATMint, 0 )  INTO vmMontoCom  FROM Parametros ;
        END IF ;

    ELIF ( piTipoTransaccion = 204 ) THEN -- REVERSA_POS

        IF ( psNacional = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRevPOSnac, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELSE
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComRevPOSint, 0 )  INTO vmMontoCom  FROM Parametros ;
        END IF ;

    ELIF ( piTipoTransaccion = 205 ) THEN -- FORZADA_POS

        IF ( psNacional = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComFzdaPOSnac, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELSE
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComFzdaPOSnac, 0 )  INTO vmMontoCom  FROM Parametros ;
        END IF ;

    ELIF ( piTipoTransaccion = 199 ) THEN -- CAMBIO_NIP_ATM

        IF ( psEsPropio = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComConsATMPropio, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELIF ( psNacional = 'V' ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComConsATMnac, 0 )  INTO vmMontoCom  FROM Parametros ;
        ELSE 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            SELECT NVL ( MontoComConsATMint, 0 )  INTO vmMontoCom  FROM Parametros ;
        END IF ;

    ELSE

       LET vmMontoCom = 0 ;

    END IF ;


    RETURN vmMontoCom ;

END 

END PROCEDURE 
;