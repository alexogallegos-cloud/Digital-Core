CREATE PROCEDURE "informix".sp_establoqueadaocancelada( psNumTarjeta CHAR (16), psFechaTransaccion CHAR (8), psHoraTransaccion CHAR (8))

RETURNING INTEGER, CHAR(3) ;

--****************************************************************************************************
-- DESCRIPCION: IDENTIFICA SI LA TRANSACCION TIENE EL STATUS DE BLOQUEADA O CANCELADA
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vsCodStatusTarjeta  CHAR (3) ;
DEFINE vsFechaTran CHAR (12) ;
DEFINE vsFechaTar CHAR (12) ;
    
DEFINE viRetorno INTEGER ;

DEFINE visqlerr   INTEGER ;


/* INICIALIZACION DE VARIABLES */

LET vsCodStatusTarjeta = '' ;
LET vsFechaTran = '' ;
LET vsFechaTar = '' ;

LET viRetorno = 0 ;

LET visqlerr = 0;                   --VARIABLE DE MANEJO DE ERRORES


BEGIN

    ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN 
            RETURN viRetorno, vsCodStatusTarjeta ;
        END IF; 
    END EXCEPTION;
    
    SET LOCK MODE TO WAIT  ;
    SET ISOLATION TO DIRTY READ ;
    --OBTIENE EL ESTATOUS Y FECHA ULTIMA MODICICACION DE LA TARJETA
    SELECT limit 1 NVL (CodStatusTarjeta, '' ), CAST( TO_CHAR ( FechaUltModif, '%y%m%d%H%M%S' ) AS char(10) ) as Fecha  
    INTO vsCodStatusTarjeta, vsFechaTar
    FROM Tarjeta WHERE NumTarjeta = psNumTarjeta ;

    LET vsFechaTar = NVL ( vsFechaTar, '' ) ;

    IF ( ( vsCodStatusTarjeta = "" )  OR  ( vsFechaTar = "" ) )THEN     --CHECA QUE NO ESTEN VACIOS LOS CAMPOS
        LET viRetorno = 0 ;   --ACTIVA
    ELIF ( ( vsCodStatusTarjeta  = 'BLO' ) OR ( vsCodStatusTarjeta  = 'CAN' ) ) THEN 

        LET vsFechaTran = SUBSTRING (psFechaTransaccion  FROM 7 FOR 2) || SUBSTRING (psFechaTransaccion  FROM 1 FOR 2) || 
                                        SUBSTRING (psFechaTransaccion  FROM 4 FOR 2) || SUBSTRING ( REPLACE (psHoraTransaccion, ':', '' )  FROM 1 FOR 4);
                                        
      
        IF (vsFechaTran <= vsFechaTar) THEN     
            LET viRetorno = 0 ;   --ACTIVA
        ELSE
            LET viRetorno = 1 ; --BLOQUEADA O CANCELADA
        END IF ;

    ELIF ((vsCodStatusTarjeta  = "ROB") OR (vsCodStatusTarjeta  = "EXT") OR (vsCodStatusTarjeta  = "DES") OR (vsCodStatusTarjeta  = "INA") ) THEN 
        --CONCATENA LA FECHA Y LA HORA 

        LET vsFechaTran = SUBSTRING (psFechaTransaccion  FROM 7 FOR 2) || SUBSTRING (psFechaTransaccion  FROM 1 FOR 2) || 
                                        SUBSTRING (psFechaTransaccion  FROM 4 FOR 2) || SUBSTRING ( REPLACE (psHoraTransaccion, ':', '' )  FROM 1 FOR 4);
      
        IF (vsFechaTran <= vsFechaTar) THEN     
            LET viRetorno = 0 ;  --ACTIVA
        ELSE
            LET viRetorno = 2 ;  --EXTRAVIADA, ROBADA, DES O INACTIVA
        END IF ;
        
    ELSE 
        LET viRetorno = 0 ;     --ACTIVA
    END IF ;

    RETURN NVL(viRetorno, 2 ), NVL( vsCodStatusTarjeta, '' ) ;

END

END PROCEDURE 
;