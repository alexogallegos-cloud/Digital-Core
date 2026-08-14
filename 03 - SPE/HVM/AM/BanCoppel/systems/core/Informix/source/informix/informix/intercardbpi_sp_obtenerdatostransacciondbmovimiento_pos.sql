CREATE PROCEDURE "informix".sp_obtenerdatostransacciondbmovimiento_pos( piMonto MONEY, psNumTarjeta CHAR (16), psSecuencia CHAR (7))

RETURNING INTEGER, CHAR (7), CHAR (16), CHAR (2), MONEY, CHAR (1) , CHAR (1), CHAR (4), CHAR (5), 
CHAR (7), CHAR (6), CHAR (1), MONEY, CHAR (16),CHAR (1), CHAR (1),
 CHAR (4), CHAR (6), DATETIME YEAR TO FRACTION, CHAR (1), CHAR (1), CHAR (7), CHAR (1), MONEY, CHAR (5), MONEY, CHAR (7),
MONEY, MONEY, CHAR (7), CHAR (7), CHAR(2), CHAR (4), CHAR (4), CHAR (3), CHAR (4),CHAR (1000) ;

--****************************************************************************************************
-- DESCRIPCION: BUSCA EL MOVIMIENTO ORIGINAL EN MOVIMIENTOS (POS)
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
DEFINE vdtMovFechaHoraInAuthorizer DATETIME YEAR TO FRACTION;
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
DEFINE vsCodTran CHAR (2) ;
DEFINE vsFormato CHAR (4) ;
DEFINE vsIdReceptor CHAR (4) ;
DEFINE vsMovMoneda CHAR (3);
DEFINE vsQUERY1 CHAR (1000) ;

DEFINE viContador INTEGER ;

DEFINE vsFecha  CHAR (4) ;
DEFINE vsHora CHAR (6) ;
DEFINE vsTransaccionOrigen CHAR (4);

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
LET vdtMovFechaHoraInAuthorizer = NULL ;
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
LET vsCodTran = '' ;
LET vsFormato = '' ;
LET vsIdReceptor = '' ;
LET vsMovMoneda = '' ;
LET vsQUERY1= '' ;

LET viContador  = 0 ;

LET vsFecha = '' ;
LET vsHora = '' ;
LET vsTransaccionOrigen = '';
-- VARIABLE DE MANEJO DE ERRORES
LET visqlerr = 0 ;

--SET DEBUG FILE TO '/informixuc7/perifericos/obtienemovimiento.txt';
--TRACE ON ;

BEGIN

    ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN
            LET viExisteEnMovimiento = visqlerr  ;
            LET vsMovFechaLocalTransaccion = to_char(current,'%m%d');
    	    LET vsMovHoraLocalTransaccion  = to_char(current,'%H%M');

            RETURN viExisteEnMovimiento, vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado, vsMovFechaMov, 
                vsMovCodigoCentral,vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, 
                vsMovEnLinea, vsMovEsNacional,vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, 
                vsMovPermiteComisionPendiente,vsMovGeneroComisionPendiente, vsMovSecComision, vsMovComisionEnLinea, 
                vmMovMontoComision, vsMovCodigoRetComision, vmMovMontoSurcharge, vsMovSecSurcharge,  vmMovMontoCashBack, 
                vmMovMontoComCashBack, vsMovSecuenciaCashBack,vsMonvSecuenciaComCashBack, vsCodTran, vsFormato, 
                vsIdReceptor, vsMovMoneda, vsTransaccionOrigen, vsQUERY1 ;
        END IF ;
    END EXCEPTION ;


    LET vsQUERY1= 'SELECT Secuencia, SecuenciaExtendida, CodigoISO, Monto, MovConciliado, MovReversado, FechaMov, '
    || 'CodigoCentral, SecuenciaOrig, HoraMov, CodReversa, MontoRealRevFzda, '
    || 'IdTerminal, EnLinea, EsNacional, FechaLocalTransaccion, HoraLocalTransaccion, '
    || 'FechaHoraInAuth,'
    || 'PermiteComisionPendiente, GeneroComisionPendiente, SecComision, ComisionEnLinea, '
    || 'MontoComision, CodigoRetComision, MontoSurcharge, SecSurcharge, MontoCashBack, '
    || 'MontoComCashBack, SecuenciaCashBack, SecuenciaComCashBack, CodTran, Formato, IdReceptor, Moneda, TransaccionOrigen'
    || ' FROM Movimiento '
    || ' WHERE  NumTarjeta ="'|| psNumTarjeta||'"AND ProdInd = "02"  AND Secuencia = "1' ||psSecuencia||'"AND movconciliado = "F";';
    

    LET vsMovFechaLocalTransaccion = to_char(current,'%m%d');
    LET vsMovHoraLocalTransaccion  = to_char(current,'%H%M');

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ ;

    SELECT COUNT (Secuencia)  INTO viContador 
	FROM Movimiento
    WHERE  NumTarjeta = psNumTarjeta AND ProdInd = '02' AND Secuencia = '1' ||psSecuencia AND movconciliado = 'F';

    IF ( viContador   = 1 ) THEN
        --SE ENCONTRO UN MOVIMIENTO QUE COINCIDE

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ ;

        SELECT LIMIT 1 NVL (Secuencia, ''), SecuenciaExtendida, NVL (CodigoISO, ''), NVL (Monto, 0), NVL (MovConciliado, 'F'), NVL (MovReversado, 'F'), NVL (FechaMov, ''),
            NVL (CodigoCentral, ''), NVL (SecuenciaOrig, ''), NVL (HoraMov, ''), NVL (CodReversa, ''), NVL (MontoRealRevFzda, 0),
            NVL (IdTerminal, ''), NVL (EnLinea, 'F'), NVL (EsNacional, 'F'), NVL (FechaLocalTransaccion, ''), NVL (HoraLocalTransaccion, ''),
            FechaHoraInAuth,
            NVL (PermiteComisionPendiente, 'F'), NVL (GeneroComisionPendiente, 'F'), NVL (SecComision, ''), NVL (ComisionEnLinea, 'F'),
            NVL (MontoComision, 0), NVL (CodigoRetComision, ''), NVL (MontoSurcharge, 0), NVL (SecSurcharge, ''),  NVL (MontoCashBack, 0),
            NVL (MontoComCashBack, 0), NVL (SecuenciaCashBack, ''), NVL (SecuenciaComCashBack, ''), NVL(CodTran, '' ), NVL(Formato, ''),
            NVL (IdReceptor, '' ), NVL (Moneda, '' ), TransaccionOrigen
            INTO vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral,
            vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional,
            vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, vsMovPermiteComisionPendiente,
            vsMovGeneroComisionPendiente, vsMovSecComision, vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision,
            vmMovMontoSurcharge, vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack,
            vsMonvSecuenciaComCashBack, vsCodTran, vsFormato, vsIdReceptor, vsMovMoneda, vsTransaccionOrigen
            FROM Movimiento
            WHERE  NumTarjeta = psNumTarjeta AND ProdInd = '02' AND Secuencia = '1' ||psSecuencia;
            LET viExisteEnMovimiento = 1 ;

    ELIF ( viContador > 1 ) THEN --BUSCAR MOVIMIENTO NO CONCILIADO

        
        IF ( viContador > 1 ) THEN 

            SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;

            SELECT COUNT (Secuencia)  INTO viContador FROM Movimiento
            WHERE  NumTarjeta = psNumTarjeta AND ProdInd = '02' AND Secuencia = '1' ||psSecuencia AND movconciliado = 'F';

        END IF ;





        IF ( viContador   >= 1 ) THEN  --SE ENCONTRO MAS DE UN MOVIMIENTO QUE COINCIDE

            LET vsQUERY1= 'SELECT Secuencia, SecuenciaExtendida, CodigoISO, Monto, MovConciliado, MovReversado, FechaMov, '
            || 'CodigoCentral, SecuenciaOrig, HoraMov, CodReversa, MontoRealRevFzda, '
            || 'IdTerminal, EnLinea, EsNacional, FechaLocalTransaccion, HoraLocalTransaccion, '
            || 'FechaHoraInAuth, ' 
            || 'PermiteComisionPendiente, GeneroComisionPendiente, SecComision, ComisionEnLinea, '
            || 'MontoComision, CodigoRetComision, MontoSurcharge, SecSurcharge, MontoCashBack, '
            || 'MontoComCashBack, SecuenciaCashBack, SecuenciaComCashBack, CodTran, Formato, IdReceptor, Moneda, TransaccionOrigen'
            || ' FROM Movimiento '
            || ' WHERE  NumTarjeta ="'|| psNumTarjeta||'"AND ProdInd = "02"  AND Secuencia = "1' ||psSecuencia||'"AND movconciliado = "F";';

            SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ ;

            SELECT LIMIT 1 NVL (Secuencia, ''), SecuenciaExtendida,NVL (CodigoISO, ''), NVL (Monto, 0), NVL (MovConciliado, 'F'), NVL (MovReversado, 'F'), NVL (FechaMov, ''),
                NVL (CodigoCentral, ''), NVL (SecuenciaOrig, ''), NVL (HoraMov, ''), NVL (CodReversa, ''), NVL (MontoRealRevFzda, 0),
                NVL (IdTerminal, ''), NVL (EnLinea, 'F'), NVL (EsNacional, 'F'), NVL (FechaLocalTransaccion, ''), NVL (HoraLocalTransaccion, ''),
                FechaHoraInAuth, 
                NVL (PermiteComisionPendiente, 'F'), NVL (GeneroComisionPendiente, 'F'), NVL (SecComision, ''), NVL (ComisionEnLinea, 'F'),
                NVL (MontoComision, 0), NVL (CodigoRetComision, ''), NVL (MontoSurcharge, 0), NVL (SecSurcharge, ''),  NVL (MontoCashBack, 0),
                NVL (MontoComCashBack, 0), NVL (SecuenciaCashBack, ''), NVL (SecuenciaComCashBack, ''), NVL(CodTran, '' ), NVL(Formato, ''),
                NVL (IdReceptor, ''), NVL (Moneda, '' ) ,TransaccionOrigen
                INTO vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral,
                vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional,
                vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, vsMovPermiteComisionPendiente,
                vsMovGeneroComisionPendiente, vsMovSecComision, vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision,
                vmMovMontoSurcharge, vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack,
                vsMonvSecuenciaComCashBack, vsCodTran, vsFormato, vsIdReceptor, vsMovMoneda, vsTransaccionOrigen
                FROM Movimiento
                WHERE  NumTarjeta = psNumTarjeta AND ProdInd = '02' AND Secuencia = '1' ||psSecuencia  AND movconciliado = 'F';

                LET viExisteEnMovimiento = 1 ;

         
        ELSE  --MANDA EL PRIMERO QUE ENCUENTRE  SIN CONCILIAR

            LET vsQUERY1= 'SELECT Secuencia, CodigoISO, Monto, MovConciliado, MovReversado, FechaMov, '
            || 'CodigoCentral, SecuenciaOrig, HoraMov, CodReversa, MontoRealRevFzda, '
            || 'IdTerminal, EnLinea, EsNacional, FechaLocalTransaccion, HoraLocalTransaccion, '
            || 'FechaHoraInAuth,'
            || 'PermiteComisionPendiente, GeneroComisionPendiente, SecComision, ComisionEnLinea, '
            || 'MontoComision, CodigoRetComision, MontoSurcharge, SecSurcharge, MontoCashBack, '
            || 'MontoComCashBack, SecuenciaCashBack, SecuenciaComCashBack, CodTran, Formato, IdReceptor, Moneda,TransaccionOrigen'
            || ' FROM Movimiento '
            || ' WHERE  NumTarjeta ="'|| psNumTarjeta||'"AND ProdInd = "02"  AND Secuencia = "1' ||psSecuencia||'"AND movconciliado = "F";';


            SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ ;

            SELECT LIMIT 1 NVL (Secuencia, ''), SecuenciaExtendida, NVL (CodigoISO, ''), NVL (Monto, 0), NVL (MovConciliado, 'F'), NVL (MovReversado, 'F'), NVL (FechaMov, ''),
                NVL (CodigoCentral, ''), NVL (SecuenciaOrig, ''), NVL (HoraMov, ''), NVL (CodReversa, ''), NVL (MontoRealRevFzda, 0),
                NVL (IdTerminal, ''), NVL (EnLinea, 'F'), NVL (EsNacional, 'F'), NVL (FechaLocalTransaccion, ''), NVL (HoraLocalTransaccion, ''),
                FechaHoraInAuth, 
                NVL (PermiteComisionPendiente, 'F'), NVL (GeneroComisionPendiente, 'F'), NVL (SecComision, ''), NVL (ComisionEnLinea, 'F'),
                NVL (MontoComision, 0), NVL (CodigoRetComision, ''), NVL (MontoSurcharge, 0), NVL (SecSurcharge, ''),  NVL (MontoCashBack, 0),
                NVL (MontoComCashBack, 0), NVL (SecuenciaCashBack, ''), NVL (SecuenciaComCashBack, ''), NVL(CodTran, '' ), NVL(Formato, ''),
                NVL (IdReceptor, ''), NVL (Moneda, '' ) ,TransaccionOrigen
                INTO vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral,
                vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional,
                vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, vsMovPermiteComisionPendiente,
                vsMovGeneroComisionPendiente, vsMovSecComision, vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision,
                vmMovMontoSurcharge, vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack,
                vsMonvSecuenciaComCashBack, vsCodTran, vsFormato, vsIdReceptor, vsMovMoneda, vsTransaccionOrigen
                FROM Movimiento
                WHERE  NumTarjeta = psNumTarjeta AND ProdInd = '02' AND Secuencia = '1' ||psSecuencia AND movconciliado = 'F';
                LET viExisteEnMovimiento = 1 ;
           

        END IF ;

    END IF ;

/**/
    IF ( viContador = 0 ) THEN --BUSCAR MOVIMIENTO YA CONCILIADO

         SET LOCK MODE TO WAIT 3;
         SET ISOLATION TO DIRTY READ ;
		 
		     LET vsQUERY1= 'SELECT Secuencia, CodigoISO, Monto, MovConciliado, MovReversado, FechaMov, '
            || 'CodigoCentral, SecuenciaOrig, HoraMov, CodReversa, MontoRealRevFzda, '
            || 'IdTerminal, EnLinea, EsNacional, FechaLocalTransaccion, HoraLocalTransaccion, '
            || 'FechaHoraInAuth,'
            || 'PermiteComisionPendiente, GeneroComisionPendiente, SecComision, ComisionEnLinea, '
            || 'MontoComision, CodigoRetComision, MontoSurcharge, SecSurcharge, MontoCashBack, '
            || 'MontoComCashBack, SecuenciaCashBack, SecuenciaComCashBack, CodTran, Formato, IdReceptor, Moneda,TransaccionOrigen'
            || ' FROM Movimiento '
            || ' WHERE  NumTarjeta ="'|| psNumTarjeta||'"AND ProdInd = "02"  AND Secuencia = "1' ||psSecuencia||'"AND movconciliado = "V";';

		IF ((psSecuencia='') OR (psSecuencia IS NULL)) THEN
			LET viExisteEnMovimiento = 3; --/// MARCA CON ERROR A LOS MOVIMIENTOS DE COMPRA QUE NO TIENEN NUMERO DE AUTORIZACIÓN INTERCARD (NO APLICA PARA DEVOLUCIONES Y PAGOS INTERBANCARIOS)
		END IF;
	
         IF ( viExisteEnMovimiento <> 3) THEN
		 
			SELECT COUNT (Secuencia)  INTO viContador 
			FROM Movimiento
			WHERE  NumTarjeta = psNumTarjeta AND ProdInd = '02' AND Secuencia = '1' ||psSecuencia AND movconciliado = 'V';

			IF ( viContador   = 1 ) THEN
				SELECT LIMIT 1 NVL (Secuencia, ''), SecuenciaExtendida,NVL (CodigoISO, ''), NVL (Monto, 0), NVL (MovConciliado, 'F'), NVL (MovReversado, 'F'), NVL (FechaMov, ''),
				NVL (CodigoCentral, ''), NVL (SecuenciaOrig, ''), NVL (HoraMov, ''), NVL (CodReversa, ''), NVL (MontoRealRevFzda, 0),
				NVL (IdTerminal, ''), NVL (EnLinea, 'F'), NVL (EsNacional, 'F'), NVL (FechaLocalTransaccion, ''), NVL (HoraLocalTransaccion, ''),
				FechaHoraInAuth, 
				NVL (PermiteComisionPendiente, 'F'), NVL (GeneroComisionPendiente, 'F'), NVL (SecComision, ''), NVL (ComisionEnLinea, 'F'),
				NVL (MontoComision, 0), NVL (CodigoRetComision, ''), NVL (MontoSurcharge, 0), NVL (SecSurcharge, ''),  NVL (MontoCashBack, 0),
				NVL (MontoComCashBack, 0), NVL (SecuenciaCashBack, ''), NVL (SecuenciaComCashBack, ''), NVL(CodTran, '' ), NVL(Formato, ''),
				NVL (IdReceptor, ''), NVL (Moneda, '' ) ,TransaccionOrigen
				INTO vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral,
				vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional,
				vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, vsMovPermiteComisionPendiente,
				vsMovGeneroComisionPendiente, vsMovSecComision, vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision,
				vmMovMontoSurcharge, vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack,
				vsMonvSecuenciaComCashBack, vsCodTran, vsFormato, vsIdReceptor, vsMovMoneda, vsTransaccionOrigen
				FROM Movimiento
				WHERE  NumTarjeta = psNumTarjeta AND ProdInd = '02' AND Secuencia = '1' ||psSecuencia AND movconciliado = 'V';
				LET viExisteEnMovimiento = 2 ;  --// Indicador de existencia de movimiento previamente conciliado
			END IF ;  	
			
		END IF;
		   
	 END IF ;    
/**/

/*
    IF ( viContador = 1 ) THEN -- SE ENCONTRO EL MOVIMIENTO QUE COINCIDE
        LET viExisteEnMovimiento = 1 ;
    ELIF ( viContador  <= 0 ) THEN      --NO SE ENCONTRO NINGUN MOVIMIENTO QUE COINCIDE
        LET viExisteEnMovimiento = 0 ;
    ELIF ( viContador  > 1 ) THEN      --SE ENCONTRO MAS DE UN REGISTRO QUE COINCIDE
        LET viExisteEnMovimiento = 1 ;
    END IF ;
*/

    RETURN viExisteEnMovimiento, vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado, vsMovMovReversado, vsMovFechaMov, 
        vsMovCodigoCentral,vsMovSecuenciaOrig, vsMovHoraMov, vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, 
        vsMovEnLinea, vsMovEsNacional,vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, 
        vsMovPermiteComisionPendiente,vsMovGeneroComisionPendiente, vsMovSecComision, vsMovComisionEnLinea, 
        vmMovMontoComision, vsMovCodigoRetComision, vmMovMontoSurcharge, vsMovSecSurcharge,  vmMovMontoCashBack, 
        vmMovMontoComCashBack, vsMovSecuenciaCashBack,vsMonvSecuenciaComCashBack, vsCodTran, vsFormato, 
        vsIdReceptor, vsMovMoneda, vsTransaccionOrigen, vsQUERY1 ;

END

END PROCEDURE
;