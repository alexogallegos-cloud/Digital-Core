CREATE PROCEDURE "informix".sp_reporteatmstat07( psTipoConsulta INTEGER,  psFechaIni CHAR (14), psFechaFin CHAR (14) )

RETURNING CHAR (4);

--****************************************************************************************************
-- DESCRIPCION:  REPORTERIA DEL STAT 07
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : 17/06/2008  --ZERO 
-- MODIFICADO : Marcos Cuevas 				Fecha : 21/08/2008
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vsCodRet CHAR (4) ;
DEFINE vsArchivoOrigen1 CHAR (3) ;
DEFINE vsArchivoOrigen2 CHAR (3) ;
DEFINE vsNacional CHAR (1) ;
DEFINE vsBin CHAR (6) ;
DEFINE vsPrefijo CHAR (10) ;
DEFINE viFechaIni INTEGER;
DEFINE viFechaFin INTEGER;

/* INICIALIZACION DE VARIABLES */

LET vsCodRet = '0000' ;
LET vsArchivoOrigen1 = '' ;
LET vsArchivoOrigen2 = '' ;
LET vsNacional = '' ;
LET vsBin = '' ;
LET vsPrefijo = '' ;
LET viFechaIni='';
LET viFechaFin='';

--SET DEBUG FILE TO '/informixuc7/perifericos/rpt325.txt';
--TRACE ON ;

BEGIN
	
	LET viFechaIni = CAST(substr(psFechaIni,7,4)||substr(psFechaIni,1,2)||substr(psFechaIni,4,2) AS INTEGER);
	LET viFechaFin = CAST(substr(psFechaFin,7,4)||substr(psFechaFin,1,2)||substr(psFechaFin,4,2) AS INTEGER);

	--Borra la tabla  intercard:tmpRpts_ATM
	
	DELETE FROM intercard:tmpRpts_ATM;
	
	-- Se escoge el tipo de consulta
	

    IF ( psTipoConsulta = 1 ) THEN --RETIROS NACIONALES CREDITO
        LET vsArchivoOrigen1 = 'TMC' ;
        LET vsArchivoOrigen2 = 'TMC' ;
        LET vsNacional = 'V' ;

    ELIF ( psTipoConsulta = 2 ) THEN  --RETIROS NACIONALES DEBITO
        LET vsArchivoOrigen1 = 'TMD' ;
        LET vsArchivoOrigen2 = 'TMD' ;
        LET vsNacional = 'V' ;

    ELIF ( psTipoConsulta = 3 ) THEN --RETIROS TOTAL NACIONALES 
        LET vsArchivoOrigen1 = 'TMC' ;
        LET vsArchivoOrigen2 = 'TMD' ;
        LET vsNacional = 'V' ;

    ELIF ( psTipoConsulta = 4 ) THEN --RETIROS INTERNACIONALES CREDITO
        LET vsArchivoOrigen1 = 'TMC' ;
        LET vsArchivoOrigen2 = 'TMC' ;
        LET vsNacional = 'F' ;

    ELIF ( psTipoConsulta = 5 ) THEN --RETIROS INTERNACIONALES DEBITO
        LET vsArchivoOrigen1 = 'TMD' ;
        LET vsArchivoOrigen2 = 'TMD' ;
        LET vsNacional = 'F' ;

    ELIF ( psTipoConsulta = 6 ) THEN --RETIROS TOTAL INTERNACIONALES
        LET vsArchivoOrigen1 = 'TMC' ;
        LET vsArchivoOrigen2 = 'TMD' ;
        LET vsNacional = 'F' ;

    ELIF ( psTipoConsulta = 9 ) THEN --CAJEROS PROPIOS  TOTALES
        LET vsArchivoOrigen1 = 'TMP' ;
        LET vsArchivoOrigen2 = 'TMP' ;
        LET vsNacional = 'V' ;

    ELIF ( psTipoConsulta = 7 ) THEN --CAJEROS PROPIOS  RETIROS CREDITO
        LET vsArchivoOrigen1 = 'TMP' ;        
        LET vsNacional = 'V' ;
        LET vsPrefijo = 'CRED' ;

    ELIF ( psTipoConsulta = 8 ) THEN --CAJEROS PROPIOS  RETIROS DEBITO
        LET vsArchivoOrigen1 = 'TMP' ;        
        LET vsNacional = 'V' ;
        LET vsPrefijo = 'DEB' ;

    END IF ;

    IF ( ( ( psTipoConsulta >= 1 ) AND ( psTipoConsulta <= 6 ) ) OR ( psTipoConsulta = 9 ) ) THEN  --REPORTES CLIENTES PROPIOS EN CAJEROS DE OTROS BANCOS    Y    CAJEROS PROPIOS  TOTALES (1-6 , 9)

        INSERT INTO intercard:tmpRpts_ATM (CodProductoTarjeta ,ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, 
			FechaDeConciliacion, StatusDeConciliacion, NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, HoraLocalTransaccion, CodReversa,
			MontoRetenido, IdReceptor, Referencia, NomBanco)
		SELECT CodProductoTarjeta ,ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, FechaDeConciliacion, StatusDeConciliacion,
            NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, HoraLocalTransaccion, CodReversa,
            MontoRetenido, IdReceptor, Referencia, Banco.Nombre  
		FROM MovConciliados, Banco, Tarjeta 
		WHERE MovConciliados.IdReceptor = Banco.ClaveBanco             
		AND ProdInd = '01' AND CodigoIso = '00'
		AND numtarjeta = numerotarjeta	
		AND substr(FechaDeConciliacion,1,8)::integer >= viFechaIni
		AND substr(FechaDeConciliacion,1,8)::integer <= viFechaFin
		AND (TipoMovimiento = vsArchivoOrigen1 OR TipoMovimiento = vsArchivoOrigen2 )
		AND NacInt = vsNacional 
		AND (CAST( StatusdeConciliacion AS INT ) < 6 );

    ELIF ( ( psTipoConsulta  = 7 ) OR ( psTipoConsulta = 8 ) ) THEN  -- REPORTE CLIENTES PROPIOS EN CAJEROS PROPIOS (7, 8) CLASIFICACION DE TRANSACCIONES POR BINES

        --OBTIENE EL BIN DE LA TARJETA QUE SE CONSULTA. CRED O DEBITO 
        SELECT Bin INTO vsBin FROM Bines WHERE Prefijo = vsPrefijo ;

        INSERT INTO intercard:tmpRpts_ATM (CodProductoTarjeta ,ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, 
			FechaDeConciliacion, StatusDeConciliacion, NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, HoraLocalTransaccion, CodReversa,
            MontoRetenido, IdReceptor, Referencia, NomBanco)
		SELECT CodProductoTarjeta ,ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, FechaDeConciliacion, StatusDeConciliacion,
            NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, HoraLocalTransaccion, CodReversa,
            MontoRetenido, IdReceptor, Referencia, Banco.Nombre 
		FROM MovConciliados, Banco, Tarjeta 
		WHERE MovConciliados.IdReceptor = Banco.ClaveBanco             
		AND ProdInd = '01' AND CodigoIso = '00'
		AND numtarjeta = numerotarjeta	
		AND substr(FechaDeConciliacion,1,8)::integer >= viFechaIni
		AND substr(FechaDeConciliacion,1,8)::integer <= viFechaFin
		AND TipoMovimiento = vsArchivoOrigen1 
		AND NacInt = vsNacional 
		AND (CAST( StatusdeConciliacion AS INT ) < 6 )
		AND NumeroTarjeta LIKE vsBin || '%' ;         

    ELSE --ERROR
	
        LET vsCodRet = '0001' ;
        
    END IF ;
	
	RETURN vsCodRet;

END

END PROCEDURE;