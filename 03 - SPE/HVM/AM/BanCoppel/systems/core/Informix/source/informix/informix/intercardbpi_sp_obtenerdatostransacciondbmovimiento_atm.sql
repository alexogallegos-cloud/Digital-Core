CREATE PROCEDURE "informix".sp_obtenerdatostransacciondbmovimiento_atm( psDescripcion CHAR (15),  psNumTarjeta CHAR (16),  psFormato CHAR (4),
psProdInd CHAR (2),  psCodTran CHAR (2), psFecha CHAR (8), psHora CHAR (8), psSecuenciaCajero CHAR (12), psAdquiriente CHAR (4), psSecuencia CHAR (7) )

RETURNING INTEGER, CHAR (7), CHAR (16), CHAR (2), MONEY, CHAR (1) , CHAR (1), CHAR (4), CHAR (5), CHAR (7), CHAR (6), CHAR (1), MONEY, CHAR (16),
CHAR (1), CHAR (1), CHAR (4), CHAR (6), DATETIME YEAR TO FRACTION, CHAR (1), CHAR (1), CHAR (7), CHAR (1), MONEY, CHAR (5), MONEY, CHAR (7),
MONEY, MONEY, CHAR (7), CHAR (7), CHAR (1000) ;

--****************************************************************************************************
-- DESCRIPCION: BUSCA EL MOVIMIENTO ORIGINAL EN MOVIMIENTOS (ATM)
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 01/07/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO :  Casanova Edeza Hector Juan   -- ZERO
--***************************************************************************************************

--DEFINICION DE VARIABLES
DEFINE viExisteEnMovimiento INTEGER ;

--- VARIABLES DEL SELECT DE MOVIMIENTOS
DEFINE vsMovSecuencia CHAR (7) ;    --ClaveAutorizacionDeTransaccion
DEFINE vsMovSecuenciaExtendida CHAR (16);    --ClaveAutorizacionDeTransaccion Extendida
DEFINE vsMovCodigoISO CHAR (2) ;
DEFINE vmMovMonto  MONEY ;
DEFINE vsMovMovConciliado  CHAR (1) ;
DEFINE vsMovMovReversado CHAR (1) ;
DEFINE vsMovFechaMov CHAR (4) ;
DEFINE vsMovCodigoCentral CHAR (5) ;
DEFINE vsMovSecuenciaOrig CHAR (7) ;
DEFINE vsMovHoraMov CHAR (6) ;
DEFINE vsMovCodReversa CHAR (1) ;
DEFINE vmMovMontoRealRevFzda MONEY ;
DEFINE vsMovIdTerminal CHAR (16) ;
DEFINE vsMovEnLinea CHAR (1) ;
DEFINE vsMovEsNacional CHAR (1) ;
DEFINE vsMovFechaLocalTransaccion CHAR (4) ;
DEFINE vsMovHoraLocalTransaccion CHAR (6) ;
DEFINE  vdtMovFechaHoraInAuthorizer DATETIME YEAR TO FRACTION ;
DEFINE vsMovPermiteComisionPendiente CHAR (1) ;
DEFINE vsMovGeneroComisionPendiente CHAR (1) ;
DEFINE vsMovSecComision CHAR (7) ;
DEFINE vsMovComisionEnLinea CHAR (1) ;
DEFINE vmMovMontoComision MONEY ;
DEFINE vsMovCodigoRetComision CHAR (5) ;
DEFINE vmMovMontoSurcharge MONEY ;
DEFINE vsMovSecSurcharge CHAR (7) ;
DEFINE vmMovMontoCashBack  MONEY ;
DEFINE vmMovMontoComCashBack  MONEY ;
DEFINE vmMovMontoRetenido MONEY ;
DEFINE vsMovSecuenciaCashBack  CHAR (7) ;
DEFINE vsMonvSecuenciaComCashBack CHAR (7) ;
DEFINE vsQUERY1 CHAR (1000) ;

DEFINE vsCodAux1 CHAR (2) ;
DEFINE vsCodAux2 CHAR (2) ;

DEFINE viContador INTEGER ;

DEFINE vsFecha  CHAR (4) ;
DEFINE vsHora CHAR (6) ;

-- VARIABLES DE MANEJO DE ERRORES
DEFINE visqlerr INTEGER ;

--INICIALIZACION DE VARIABLES
LET viExisteEnMovimiento = 0 ;

--- VARIABLES DEL SELECT DE MOVIMIENTOS
LET vsMovSecuencia = '' ;
LET vsMovSecuenciaExtendida = NULL ;
LET vsMovCodigoISO = '' ;
LET vmMovMonto = 0 ;
LET vsMovMovConciliado = '' ;
LET vsMovMovReversado = '' ;
LET vsMovFechaMov = '' ;
LET vsMovCodigoCentral = '' ;
LET vsMovSecuenciaOrig = '' ;
LET vsMovHoraMov = '' ;
LET vsMovCodReversa = '' ;
LET vmMovMontoRealRevFzda =  0 ;
LET vsMovIdTerminal = '' ;
LET vsMovEnLinea = '' ;
LET vsMovEsNacional = '' ;
LET vsMovFechaLocalTransaccion = '' ;
LET vsMovHoraLocalTransaccion = '' ;
LET vdtMovFechaHoraInAuthorizer = '' ;
LET vsMovPermiteComisionPendiente = '' ;
LET vsMovGeneroComisionPendiente = '' ;
LET vsMovSecComision = '' ;
LET vsMovComisionEnLinea = '' ;
LET vmMovMontoComision = 0 ;
LET vsMovCodigoRetComision = '' ;
LET vmMovMontoSurcharge = 0 ;
LET vsMovSecSurcharge = '' ;
LET vmMovMontoCashBack  = 0 ;
LET vmMovMontoComCashBack  = 0 ;
LET vmMovMontoRetenido = 0 ;
LET vsMovSecuenciaCashBack = '' ;
LET vsMonvSecuenciaComCashBack  = '' ;
LET vsQUERY1= '' ;

LET vsCodAux1 = 0 ;
LET vsCodAux2 = 0 ;

LET viContador  = 0 ;

LET vsFecha = '' ;
LET vsHora = '' ;
-- VARIABLE DE MANEJO DE ERRORES
LET visqlerr = 0 ;

BEGIN

    ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN
            LET viExisteEnMovimiento = visqlerr  ;            RETURN viExisteEnMovimiento, vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado,
                    vsMovFechaMov, vsMovCodigoCentral, vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda,
                    vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional, vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion,
                    vdtMovFechaHoraInAuthorizer, vsMovPermiteComisionPendiente, vsMovGeneroComisionPendiente, vsMovSecComision,
                    vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision, vmMovMontoSurcharge, vsMovSecSurcharge,
                    vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack, vsMonvSecuenciaComCashBack , vsQUERY1 ;
        END IF ;
    END EXCEPTION;

  --SET DEBUG FILE TO "/home/informix/jydg/sp_obtenerdatostransacciondbmovimiento_atm.out";
  --TRACE ON;

    --LET vsFecha =  SUBSTRING ( REPLACE (psFecha, '/', '' )  FROM 1 FOR 4) ;  --29/06/07
    LET vsFecha =  SUBSTRING ( REPLACE (psFecha, '/', '' )  FROM 3 FOR 2) || SUBSTRING ( REPLACE (psFecha, '/', '' )  FROM 1 FOR 2) ;
    LET vsHora = REPLACE ( psHora, ':', '' ) ;

    IF ( (psNumTarjeta <> '')  AND (psSecuencia <> '') AND (psFecha <> '') AND (psHora <> '') ) THEN  --BUSQUEDA NUEVA (CORTA)
        --ELIGE COMO REALIZAR LA BUSQUEDA, SI TRAE LA SECUENCIA BUSCA POR FECHA HORA SECUENCIA Y NUMTARJETA

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ ;

        SELECT COUNT (Secuencia)  INTO viContador FROM Movimiento
        WHERE  NumTarjeta = psNumTarjeta AND Secuencia = '1' || psSecuencia
        AND FechaLocalTransaccion = vsFecha  AND HoraLocalTransaccion = vsHora ;

        LET vsQUERY1= 'SELECT Secuencia, SecuenciaExtendida, CodigoISO, Monto, MovConciliado, MovReversado, FechaMov, '
        || 'CodigoCentral, SecuenciaOrig, HoraMov, CodReversa, MontoRealRevFzda, '
        || 'IdTerminal, EnLinea, EsNacional, FechaLocalTransaccion, HoraLocalTransaccion, '
        || 'FechaHoraInAuth, '
        || 'PermiteComisionPendiente, GeneroComisionPendiente, SecComision, ComisionEnLinea, '
        || 'MontoComision, CodigoRetComision, MontoSurcharge, SecSurcharge, MontoCashBack, '
        || 'MontoComCashBack, SecuenciaCashBack, SecuenciaComCashBack'
        || ' FROM Movimiento '
        || ' WHERE  Secuencia = "1'  || psSecuencia || '" AND NumTarjeta = "' ||  psNumTarjeta
        || '" AND FechaLocalTransaccion = "' || vsFecha  || '" AND HoraLocalTransaccion = "' || vsHora || '"AND ProdInd = "01" ';

        IF ( viContador  > 0 ) THEN
            --SE ENCONTRO UN MOVIMIENTO QUE COINCIDE

            SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ ;

            SELECT LIMIT 1 NVL (Secuencia, ''), SecuenciaExtendida, NVL (CodigoISO, ''), NVL (Monto, 0), NVL (MovConciliado, 'F'), NVL (MovReversado, 'F'), NVL (FechaMov, ''),
                NVL (CodigoCentral, '00000'), NVL (SecuenciaOrig, ''), NVL (HoraMov, ''), NVL (CodReversa, ''), NVL (MontoRealRevFzda, 0),
                NVL (IdTerminal, ''), NVL (EnLinea, 'F'), NVL (EsNacional, 'F'), NVL (FechaLocalTransaccion, ''), NVL (HoraLocalTransaccion, ''),
                FechaHoraInAuth,
                NVL (PermiteComisionPendiente, 'F'), NVL (GeneroComisionPendiente, 'F'), NVL (SecComision, ''), NVL (ComisionEnLinea, 'F'),
                NVL (MontoComision, 0), NVL (CodigoRetComision, '99999'), NVL (MontoSurcharge, 0), NVL (SecSurcharge, ''),  NVL (MontoCashBack, 0),
                NVL (MontoComCashBack, 0), NVL (SecuenciaCashBack, ''), NVL (SecuenciaComCashBack, '')
                INTO vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral,
                vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional,
                vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, vsMovPermiteComisionPendiente,
                vsMovGeneroComisionPendiente, vsMovSecComision, vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision,
                vmMovMontoSurcharge, vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack,
                vsMonvSecuenciaComCashBack
                FROM Movimiento
                WHERE  Secuencia = '1' || psSecuencia AND NumTarjeta = psNumTarjeta
                AND FechaLocalTransaccion = vsFecha  AND HoraLocalTransaccion = vsHora
                AND ProdInd = '01' ;

        END IF ;

    ELSE    --FALTA UNO DE LOS DATOS PARA LA BUSQUEDA. SE REALIZA DE LA FORMA LARGA (COMPLETA)

         IF ( psDescripcion = 'CAMB_NIP' ) THEN
            -- CHECA SI ES CAMBIO DE NIP. PARA SELECCIONAR LAS CONDICIONES
            -- ADECUADAS CAMBI DE NIP PUEDE TENER 2 CLAVES 81 O 96
            LET vsCodAux1 = '81' ;  --CODIGO DE CAMBIO DE NIP
            LET vsCodAux2 = '96' ;  --CODIGO DE CAMBIO DE NIP
        ELSE    --ASIGNA EL MISMO VALOR A LAS 2 VARIABLE
            LET vsCodAux1 = psCodTran ;     --CODIGO ORIGINAL DE LA TRANSACCION
            LET vsCodAux2 = psCodTran ;     --CODIGO ORIGINAL DE LA TRANSACCION
        END IF ;

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;

        SELECT COUNT (Secuencia)  INTO viContador FROM Movimiento
        WHERE  NumTarjeta = psNumTarjeta AND Formato = psFormato AND ProdInd = psProdInd  AND (CodTran = vsCodAux2 OR CodTran = vsCodAux2)
        AND FechaLocalTransaccion = vsFecha  AND HoraLocalTransaccion = vsHora  AND Referencia = psSecuenciaCajero AND IdReceptor = psAdquiriente ;


        LET vsQUERY1= 'SELECT Secuencia, CodigoISO, Monto, MovConciliado, MovReversado, FechaMov, '
        || 'CodigoCentral, SecuenciaOrig, HoraMov, CodReversa, MontoRealRevFzda, '
        || 'IdTerminal, EnLinea, EsNacional, FechaLocalTransaccion, HoraLocalTransaccion, '
        || 'FechaHoraInAuth, '
        || 'PermiteComisionPendiente, GeneroComisionPendiente, SecComision, ComisionEnLinea, '
        || 'MontoComision, CodigoRetComision, MontoSurcharge, SecSurcharge, MontoCashBack, '
        || 'MontoComCashBack, SecuenciaCashBack, SecuenciaComCashBack'
        || ' FROM Movimiento '
        || ' WHERE  NumTarjeta = "' || psNumTarjeta || '" AND Formato = "' || psFormato
        || '" AND ProdInd = "' || psProdInd  || '" AND (CodTran = "' || vsCodAux2 || '" OR CodTran = "'
        || vsCodAux2 || '")  AND FechaLocalTransaccion = "' || vsFecha
        || '" AND HoraLocalTransaccion = "' || vsHora || '" AND Referencia = "'
        || psSecuenciaCajero || '" AND IdReceptor = "' || psAdquiriente || '"';

        IF ( viContador  > 0 ) THEN
            --SE ENCONTRO UN MOVIMIENTO QUE COINCIDE

            SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ ;

            SELECT LIMIT 1 NVL (Secuencia, ''), SecuenciaExtendida, NVL (CodigoISO, ''), NVL (Monto, 0), NVL (MovConciliado, 'F'), NVL (MovReversado, 'F'), NVL (FechaMov, ''),
                NVL (CodigoCentral, '00000'), NVL (SecuenciaOrig, ''), NVL (HoraMov, ''), NVL (CodReversa, ''), NVL (MontoRealRevFzda, 0),
                NVL (IdTerminal, ''), NVL (EnLinea, 'F'), NVL (EsNacional, 'F'), NVL (FechaLocalTransaccion, ''), NVL (HoraLocalTransaccion, ''),
                FechaHoraInAuth,
                NVL (PermiteComisionPendiente, 'F'), NVL (GeneroComisionPendiente, 'F'), NVL (SecComision, ''), NVL (ComisionEnLinea, 'F'),
                NVL (MontoComision, 0), NVL (CodigoRetComision, '99999'), NVL (MontoSurcharge, 0), NVL (SecSurcharge, ''),  NVL (MontoCashBack, 0),
                NVL (MontoComCashBack, 0), NVL (SecuenciaCashBack, ''), NVL (SecuenciaComCashBack, '')
                INTO vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral,
                vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional,
                vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, vsMovPermiteComisionPendiente,
                vsMovGeneroComisionPendiente, vsMovSecComision, vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision,
                vmMovMontoSurcharge, vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack,
                vsMonvSecuenciaComCashBack
                FROM Movimiento
                WHERE  NumTarjeta = psNumTarjeta AND Formato = psFormato AND ProdInd = psProdInd
                AND (CodTran = vsCodAux2 OR CodTran = vsCodAux2)
                AND FechaLocalTransaccion = vsFecha  AND HoraLocalTransaccion = vsHora
                AND Referencia = psSecuenciaCajero AND IdReceptor = psAdquiriente
                AND ProdInd = '01'  ;

          END IF ;

    END IF ;

    IF ( ( viContador = 1 ) AND ( psFormato = '0420' ) AND ( vsMovSecuenciaOrig <> '' ) AND ( vsMovCodReversa = '2' ) ) THEN -- SE ENCONTRO EL MOVIMIENTO QUE COINCIDE

        LET vsQUERY1= 'SELECT Secuencia, CodigoISO, Monto, MovConciliado, MovReversado, FechaMov, '
        || 'CodigoCentral, SecuenciaOrig, HoraMov, CodReversa, MontoRealRevFzda, '
        || 'IdTerminal, EnLinea, EsNacional, FechaLocalTransaccion, HoraLocalTransaccion, '
        || 'FechaHoraInAuth, '
        || 'PermiteComisionPendiente, GeneroComisionPendiente, SecComision, ComisionEnLinea, '
        || 'MontoComision, CodigoRetComision, MontoSurcharge, SecSurcharge, MontoCashBack, '
        || 'MontoComCashBack, SecuenciaCashBack, SecuenciaComCashBack'
        || ' FROM Movimiento '
        || ' WHERE  Secuencia = "1'  || psSecuencia || '" AND NumTarjeta = "' ||  psNumTarjeta
        || '" AND FechaLocalTransaccion = "' || vsFecha  || '" AND HoraLocalTransaccion = "' || vsHora || '"AND ProdInd = "01" ';

        SET LOCK MODE TO WAIT  ;
        SET ISOLATION TO DIRTY READ ;

        SELECT LIMIT 1 NVL ( MontoSurcharge, 0 ), NVL ( SecSurcharge, '' ), NVL ( ComisionEnLinea, 'F' ), NVL ( PermiteComisionPendiente, 'F' ),
                NVL ( GeneroComisionPendiente, 'F' ), NVL ( SecComision, '' ), NVL ( MontoComision, 0 ), NVL ( CodigoRetComision, '99999' )
                INTO vmMovMontoSurcharge, vsMovSecSurcharge, vsMovComisionEnLinea, vsMovPermiteComisionPendiente, vsMovGeneroComisionPendiente,
                vsMovSecComision, vmMovMontoComision, vsMovCodigoRetComision
                FROM Movimiento WHERE Secuencia = vsMovSecuenciaOrig AND NumTarjeta = psNumTarjeta ;

    END IF ;

    IF ( viContador = 1 ) THEN -- SE ENCONTRO EL MOVIMIENTO QUE COINCIDE
        LET viExisteEnMovimiento = 1 ;
    ELIF ( viContador  <= 0 ) THEN      --NO SE ENCONTRO NINGUN MOVIMIENTO QUE COINCIDE
        LET viExisteEnMovimiento = 0 ;
    ELIF ( viContador  > 1 ) THEN
        --SE ENCONTRARON MAS DE UN REGISTRO QUE COINCIDE CON LOS DATOS DE EGLOBAL
        IF ( (psNumTarjeta <> '')  AND (psSecuencia <> '') AND (psFecha <> '') AND (psHora <> '') )THEN --BUSQUEDA NUEVA (CORTA)
            LET viExisteEnMovimiento = 2 ;
        ELSE    --BUSQUEDA COMPLETA (ANTIGUA)
            LET viExisteEnMovimiento = 3 ;
        END IF ;
    END IF ;


RETURN viExisteEnMovimiento, vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral,
        vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional,
        vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, vsMovPermiteComisionPendiente,
        vsMovGeneroComisionPendiente, vsMovSecComision, vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision,
        vmMovMontoSurcharge, vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack,
        vsMonvSecuenciaComCashBack, vsQUERY1 ;

END

END PROCEDURE
;