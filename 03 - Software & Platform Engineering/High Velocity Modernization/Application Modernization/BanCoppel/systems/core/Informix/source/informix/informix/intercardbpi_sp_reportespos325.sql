CREATE PROCEDURE "informix".sp_reportespos325( psTipoConsulta INTEGER,  psFechaIni CHAR (14), psFechaFin CHAR (14) )
RETURNING CHAR (4);

--****************************************************************************************************
-- DESCRIPCION: REPORTERIA DEL 325 POS
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
-- MODIFICADO : Marcos Cuevas 				Fecha : 21/08/2008
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vsCodRet CHAR (4) ;
DEFINE vsArchivoOrigen1 CHAR (3) ;
DEFINE vsArchivoOrigen2 CHAR (3) ;
DEFINE viFechaIni INTEGER;
DEFINE viFechaFin INTEGER;

/* INICIALIZACION DE VARIABLES */

LET vsCodRet = '0000' ;
LET vsArchivoOrigen1 = '' ;
LET vsArchivoOrigen2 = '' ;
LET viFechaIni='';
LET viFechaFin='';

--SET DEBUG FILE TO '/informixuc7/perifericos/rpt325.txt';
--TRACE ON ;

BEGIN
	
	LET viFechaIni = CAST(substr(psFechaIni,7,4)||substr(psFechaIni,1,2)||substr(psFechaIni,4,2) AS INTEGER);
	LET viFechaFin = CAST(substr(psFechaFin,7,4)||substr(psFechaFin,1,2)||substr(psFechaFin,4,2) AS INTEGER);

	--Borra la tabla  intercard:tmpRpts_POS
	
	DELETE FROM intercard:tmpRpts_POS;
	
	-- Se escoge el tipo de consulta

    IF ( psTipoConsulta = 1 ) THEN --VENTAS NACIONALES CREDITO
        LET vsArchivoOrigen1 = 'VNC' ;        

    ELIF ( psTipoConsulta = 2 ) THEN  --VENTAS NACIONALES DEBITO
        LET vsArchivoOrigen1 = 'VND' ;

    ELIF ( psTipoConsulta = 3 ) THEN -- TOTAL VENTAS NACIONALES 
        LET vsArchivoOrigen1 = 'TMC' ;
        LET vsArchivoOrigen2 = 'TMD' ;

    ELIF ( psTipoConsulta = 4 ) THEN --PAGOS INTERBANCARIOS
        LET vsArchivoOrigen1 = 'PNC' ;

    ELIF ( psTipoConsulta = 5 ) THEN --VENTAS INTERNACIONALES CREDITO
        LET vsArchivoOrigen1 = 'VIC' ;

    ELIF ( psTipoConsulta = 6 ) THEN --VENTAS INTERNACIONALES DEBITO
        LET vsArchivoOrigen1 = 'VID' ;        

    ELIF ( psTipoConsulta = 7 ) THEN --TOTAL  VENTAS INTERNACIONALES
        LET vsArchivoOrigen1 = 'VIC' ;
        LET vsArchivoOrigen2 = 'VID' ;

    ELIF ( psTipoConsulta = 8 ) THEN --TIENDAS COPPEL CREDITO
        LET vsArchivoOrigen1 = 'TCC' ;        
        
    ELIF ( psTipoConsulta = 9 ) THEN --TIENDAS COPPEL DEBITO 
        LET vsArchivoOrigen1 = 'TCD' ;
        
    ELIF ( psTipoConsulta = 10 ) THEN --TOTAL TIENDAS COPPEL 
        LET vsArchivoOrigen1 = 'TCC' ;
        LET vsArchivoOrigen2 = 'TCD' ;
       
    END IF ;    

    IF ( ( ( psTipoConsulta >= 1 ) AND ( psTipoConsulta <= 9 )  AND ( vsArchivoOrigen2 = '' ) )  ) THEN  --REPORTES  DE UN SOLO TIPO 

			INSERT INTO intercard:tmpRpts_POS(CodProductoTarjeta, ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, 
				FechaDeConciliacion, StatusDeConciliacion, NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, 
				HoraLocalTransaccion, CodReversa, MontoRetenido, IdReceptor, Referencia, MontoCashBack, NombreComercio, IdComercio)
			SELECT CodProductoTarjeta ,ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, FechaDeConciliacion, StatusDeConciliacion,
	            NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, HoraLocalTransaccion, CodReversa,
	            MontoRetenido, IdReceptor, Referencia, MontoCashBack, NombreComercio, IdComercio 
            FROM MovConciliados, Tarjeta 
            WHERE MovConciliados.NumeroTarjeta = Tarjeta.NumTarjeta            
            AND ProdInd = '02'
            AND substr(FechaDeConciliacion,1,8)::integer >= viFechaIni
			AND substr(FechaDeConciliacion,1,8)::integer <= viFechaFin
            AND TipoMovimiento = vsArchivoOrigen1 
            AND ( CodTran = '00' OR CodTran = '21' OR CodTran = '01' );

    ELIF ( ( psTipoConsulta = 3 ) OR ( psTipoConsulta = 7 ) OR ( psTipoConsulta = 10 ) ) THEN  -- REPORTES TOTALES POR GRUPO

			INSERT INTO intercard:tmpRpts_POS(CodProductoTarjeta, ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, 
				FechaDeConciliacion, StatusDeConciliacion, NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, 
				HoraLocalTransaccion, CodReversa, MontoRetenido, IdReceptor, Referencia, MontoCashBack, NombreComercio, IdComercio)
			SELECT CodProductoTarjeta ,ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, FechaDeConciliacion, StatusDeConciliacion,
				NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, HoraLocalTransaccion, CodReversa,
				MontoRetenido, IdReceptor, Referencia, MontoCashBack, NombreComercio, IdComercio  
            FROM MovConciliados, Tarjeta 
            WHERE MovConciliados.NumeroTarjeta = Tarjeta.NumTarjeta            
            AND ProdInd = '02' 
            AND substr(FechaDeConciliacion,1,8)::integer >= viFechaIni
			AND substr(FechaDeConciliacion,1,8)::integer <= viFechaFin
            AND ( TipoMovimiento = vsArchivoOrigen1 OR TipoMovimiento = vsArchivoOrigen2 )
            AND ( CodTran = '00' OR CodTran = '21' OR CodTran = '01' );
 
    ELSE --ERROR
	
		LET vsCodRet = '0001' ;
    
    END IF ;
	
	RETURN vsCodRet;

END

END PROCEDURE;