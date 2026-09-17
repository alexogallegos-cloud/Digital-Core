CREATE PROCEDURE "informix".sp_generareferencia( piTipoTrans INTEGER, psAdquiriente CHAR (30), psSecuenciaOTarjeta CHAR (20) )

RETURNING CHAR (40) ;

--****************************************************************************************************
-- DESCRIPCION: GENERA REFERENCIA PARA LA TRANSACCION (ATM POS) CON LOS DATOS DE PROSEDENCIA DE LA TRANSACCION
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : 16/06/2008 --ZERO 
--***************************************************************************************************    

/*  DEFINICION DE VARIABLES */
DEFINE viTipoTransaccion INTEGER ;
DEFINE vsNombreBanco CHAR (20) ;
DEFINE vsReferencia CHAR (41) ;
DEFINE  viExiste  INTEGER ;
            
/* INICIALIZACION DE VARIABLES */
LET viTipoTransaccion  = 0 ;
LET vsNombreBanco  = 'Banco No Registrado' ;
LET vsReferencia = '' ;

BEGIN 

    IF ( piTipoTrans = 1 ) OR ( piTipoTrans = 6 ) THEN   
        --  1   RETIRO
        --  6   REVERSAPARCIAL_ATM
        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;

        SELECT Nombre INTO vsNombreBanco  FROM Banco WHERE ClaveBanco = TRIM (psAdquiriente) ;

        IF ( vsNombreBanco  IS NULL ) THEN 
            LET vsNombreBanco  = 'Banco No Registrado' ;
        END IF ;

        --LET vsReferencia = TRIM (psAdquiriente) || ' ' || TRIM (vsNombreBanco) || ' ' || TRIM (psSecuenciaOTarjeta) ; 
        LET vsReferencia = TRIM (vsNombreBanco) || ' ' || TRIM (psSecuenciaOTarjeta) ; 

    ELIF ( piTipoTrans = 9 ) OR ( piTipoTrans = 7 ) OR ( piTipoTrans = 8 ) OR ( piTipoTrans = 14 )THEN   --COMISIONRETIRO     
        --  9  COMISIONRETIRO         ---Es cajero Nuestro?
        --  7  COMISIONCONSULTA  ---Comision por Consulta ATM Nac. e Int.
        --  8  COMISIONCAMB_NIP   ---Comision por Cambio de NIP
        -- 14  RETIROINTER_ATM

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;        

        SELECT Count(Nombre) INTO viExiste  FROM Banco WHERE ClaveBanco = TRIM (psAdquiriente) ;
        
        IF ( viExiste > 0 ) THEN 
            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;        
            SELECT LIMIT 1 Nombre INTO vsNombreBanco FROM Banco WHERE ClaveBanco = psAdquiriente ;
            LET vsReferencia = TRIM (vsNombreBanco) || ' ' || TRIM (psSecuenciaOTarjeta) ;
        ELSE 
            LET vsReferencia = TRIM (psAdquiriente)  || ' ' || TRIM (psSecuenciaOTarjeta) ;
        END IF ;

        --SELECT Count(FIID) INTO viExiste  FROM Parametros WHERE FIID = TRIM (psAdquiriente) ; --IDRECEPTOR
        --IF ( viExiste > 0 ) THEN 
        --    LET vsReferencia = 'Cajero BanCoppel'  || ': ' || SUBSTRING (TRIM (psSecuenciaOTarjeta) 
        --        FROM ( LENGTH (psSecuenciaOTarjeta ) - 3 ) FOR ( LENGTH (psSecuenciaOTarjeta ) ) ) ;
        --ELSE    
        --    LET vsReferencia = 'Cajero RED'  || ': ' || SUBSTRING (TRIM (psSecuenciaOTarjeta)
        --        FROM ( LENGTH (psSecuenciaOTarjeta ) - 3 ) FOR ( LENGTH (psSecuenciaOTarjeta ) ) ) ;
        --END IF ;

    ELIF ( piTipoTrans = 2 ) OR ( piTipoTrans = 20 ) OR ( piTipoTrans = 23 ) OR ( piTipoTrans = 21 ) OR ( piTipoTrans = 22 )THEN   
        --  2     COMPRA  -- Compra POS Nac. e Int.
        --  20   CASHBACK
        --  23  COMISIONCASHBACK
        --  21  CASHADVANCE   
        --  22  PAGOINTERBANCARIO

        LET vsReferencia = TRIM (psAdquiriente) || ' ' || TRIM (psSecuenciaOTarjeta) ;

    ELIF ( piTipoTrans = 10 ) OR ( piTipoTrans = 11 ) OR ( piTipoTrans = 12 ) OR ( piTipoTrans = 15 ) OR ( piTipoTrans = 13 ) OR ( piTipoTrans = 16 )THEN   
        --  10  COMISIONCOMPRA
        --  11  COMISIONDEVOLUCION
        --  12  COMISIONFORZADA
        --  15  CRETIROINTER_ATM
        --  13  COMISIONRTOTALPOS
        --  16  CREVERSATOTAL_ATM

        LET vsReferencia = TRIM (psSecuenciaOTarjeta) ; 

    ELIF ( piTipoTrans = 3 ) THEN   --DEVOLUCION  Devolucion (POS)

        LET vsReferencia =  ' DEVOL.' || ' ' ||  TRIM (psAdquiriente) ;

    ELIF ( piTipoTrans = 4 ) THEN   --FORZADA Forzada POS

        LET vsReferencia = TRIM (psAdquiriente) || ' ' || SUBSTRING ( LPAD ( TRIM ( psSecuenciaOTarjeta ), 7, '0' ) FROM 2 FOR 7 ) ;

    ELIF ( piTipoTrans = 14 ) THEN   --RETIROINTER_ATM

        LET vsReferencia = TRIM (psAdquiriente) || ' ' || TRIM (psSecuenciaOTarjeta) ;

    ELIF ( piTipoTrans = 17 ) OR ( piTipoTrans = 18 ) THEN   
        --  17  CREEXPTRJ
        --  18  CREIMPNIP

        LET vsReferencia = TRIM (psAdquiriente) ;

    END IF ;


    RETURN vsReferencia  ;

END 

END PROCEDURE 
;