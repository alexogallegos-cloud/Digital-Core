CREATE PROCEDURE "informix".sp_gettransaccioninterempresas(psTipoTransaccion CHAR (2),  psRFC CHAR(16) , pmMonto MONEY, pmMontoCashBack MONEY)
RETURNING CHAR (10), CHAR(4), MONEY ;

--****************************************************************************************************
-- DESCRIPCION: OBTIENE LA REFERENCUIA DE LA EMPRESA PARA EL PAGO DE LOS SERV DE CASH BACK Y CASH ADVANCED
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/05/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsDescTransInterEmpresa CHAR (15) ;
DEFINE vsTipoTransInterEmpresa CHAR (4) ;
DEFINE vmMontoComInterEmpresa MONEY ;
DEFINE vsConvenioInterEmpresa CHAR (10) ;

/* INICIALIZACION DE VARIABLES */
LET vsDescTransInterEmpresa = '' ;
LET vsTipoTransInterEmpresa = '' ;
LET vmMontoComInterEmpresa = 0.0 ;
LET vsConvenioInterEmpresa = '' ;

BEGIN

    IF ( ( psTipoTransaccion = '01'  OR psTipoTransaccion = '09') AND ( pmMonto > 0 ) AND ( pmMonto > pmMontoCashBack ) ) THEN
        LET vsDescTransInterEmpresa = 'CASH_BACK' ;                        
    ELIF ( ( psTipoTransaccion = '01'  OR psTipoTransaccion = '09' ) AND ( pmMonto > 0 ) AND ( pmMonto = pmMontoCashBack ) ) THEN 
        LET vsDescTransInterEmpresa = 'CASH_ADVANCED' ;
    ELSE
        LET vsDescTransInterEmpresa = '' ;
    END IF ;

    IF ( ( pmMontoCashBack > 0 ) AND ( psRFC <> '' ) AND ( vsDescTransInterEmpresa <> '' ) ) THEN -- SI ES CASH BACK O CASH ADVANCE

        -- COBRO DE COM INTEREMPRESAS
        SET LOCK MODE TO WAIT  ;
        SET ISOLATION DIRTY READ ;
        SELECT Convenio, CVE_Transaccion, Monto_Comision INTO vsConvenioInterEmpresa, vsTipoTransInterEmpresa, vmMontoComInterEmpresa 
        FROM Cat_ComisionInterEmpresas WHERE RFC = psRFC AND Desc_Transaccion = vsDescTransInterEmpresa ;

    END IF ;

    RETURN vsConvenioInterEmpresa, vsTipoTransInterEmpresa, vmMontoComInterEmpresa ;

END

END PROCEDURE
;