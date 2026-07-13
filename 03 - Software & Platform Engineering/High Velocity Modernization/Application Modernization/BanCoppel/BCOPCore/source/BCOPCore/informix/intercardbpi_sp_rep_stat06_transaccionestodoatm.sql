CREATE PROCEDURE "informix".sp_rep_stat06_transaccionestodoatm( psTipoReporte CHAR (1),  psFechaIni CHAR (10), psFechaFin CHAR (10) )

RETURNING CHAR (4); 

--****************************************************************************************************
-- DESCRIPCION:  REPORTE DE TRANSACCIONES POR CAJERO DE ATM'S ( CREDITO - DEBITO) 
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 01/08/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
-- MODIFICADO : Marcos Cuevas 				Fecha : 21/08/2008
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vsNumCajero CHAR (14) ;
DEFINE viNum_Retiros INTEGER ;
DEFINE vmMonto_Retiros MONEY;
DEFINE viNum_Consultas INTEGER ;
DEFINE viNum_Cambio_NIP INTEGER ;
DEFINE viNum_Venta_Electronica INTEGER ;
DEFINE vmMonto_Venta_Electronica MONEY ;
DEFINE vsCodRet CHAR (4) ;

/*TOTALES*/
DEFINE viTotal_Num_Retiros INTEGER ;
DEFINE vmTotal_Monto_Retiros MONEY;
DEFINE viTotal_Num_Consultas INTEGER ;
DEFINE viTotal_Num_Cambio_NIP INTEGER ;
DEFINE viTotal_Num_Venta_Electronica INTEGER ;
DEFINE vmTotal_Monto_Venta_Electronica MONEY ;

DEFINE vsBin CHAR(6);
DEFINE vsCredDeb CHAR (6);
DEFINE vsAuxCredDeb CHAR (6) ;

DEFINE viTotalCajeros INTEGER ;

/* INICIALIZACION DE VARIABLES */

LET vsNumCajero = '' ;
LET viNum_Retiros = 0 ;
LET vmMonto_Retiros = 0.0 ;
LET viNum_Consultas = 0 ;
LET viNum_Cambio_NIP = 0 ;
LET viNum_Venta_Electronica = 0 ;
LET vmMonto_Venta_Electronica = 0.0 ;

/*TOTALES*/
LET viTotal_Num_Retiros = 0 ;
LET vmTotal_Monto_Retiros = 0.0 ;
LET viTotal_Num_Consultas = 0 ;
LET viTotal_Num_Cambio_NIP = 0 ;
LET viTotal_Num_Venta_Electronica = 0 ;
LET vmTotal_Monto_Venta_Electronica = 0.0 ;

LET vsBin = '' ;
LET vsCredDeb = '' ;
LET vsAuxCredDeb = '' ;
LET vsCodRet = '0000' ;

LET viTotalCajeros = 0 ;


BEGIN	


--SET DEBUG FILE TO '/tmp/conciliacion/TracesStat06.txt';
--TRACE ON ;

	--Borra la tabla  intercard:tmpRpts_Stat06
	
	truncate table intercard:tmpRpts_Stat06;
	
	-- Se escoge el tipo de consulta
	
	IF (psTipoReporte = 'C') THEN --CREDITO
		LET vsCredDeb = 'CREDIT' ;
		LET vsAuxCredDeb = 'MAESTR' ;
		LET vsBin = '' ;
	ELIF (psTipoReporte = 'D') THEN --DEBITO
		LET vsCredDeb = 'CHEQUE' ;
		LET vsAuxCredDeb = 'CHEQUE' ;
		LET vsBin = '' ;
	ELSE --ERROR
		LET vsCodRet = '0001' ;
	END IF ;

	IF ( vsCodRet <> '0001') THEN
	
		SELECT Bin INTO vsBin FROM BINES WHERE CreditoDebito = psTipoReporte;
		
		IF ( vsBin IS NULL )THEN 
			LET vsBin = '' ;
		END IF ;
		
		-- NOMBRE DE COLUMNA
		INSERT INTO intercard:tmpRpts_Stat06(Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7)
		VALUES ( 'Nombre del Banco', 'Numero de Retiros', 'Monto de Retiros', 'Numero de Consultas', 'Numero de Cambios de NIP', 
				'Num Venta Electronica', 'Monto Venta Electronica');

		-- SEPARADORES
		INSERT INTO intercard:tmpRpts_Stat06(Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7)
		VALUES ( '------------------------', '------------------------', '------------------------', 
				'------------------------', '------------------------', 
				'------------------------', '------------------------');

		FOREACH SELECT NumCajero INTO vsNumCajero FROM Conciliacion_ATM_Stat06    		
			WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
			AND ( (Descripcion LIKE '%' || vsCredDeb) OR (Descripcion LIKE '%' || vsAuxCredDeb) OR (Descripcion = 'CAMB_NIP NO_CTA') )
			GROUP BY NumCajero ORDER BY NumCajero ASC

	        LET viTotalCajeros = viTotalCajeros + 1 ;

	        --total de RETIROS  # $
	        SELECT COUNT (Keyx), SUM(NVL(Monto, 0.0)) INTO viNum_Retiros, vmMonto_Retiros FROM Conciliacion_ATM_Stat06
	            WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
	            AND Numcajero = vsNumCajero 
	            AND ( ( Descripcion = 'RETIRO   ' || vsCredDeb ) OR ( Descripcion = 'RETIRO   ' || vsAuxCredDeb ) )
				AND IndicadordeReversa = '' ;

	        --total de CONSULTAS #
	        SELECT COUNT(keyx) INTO viNum_Consultas FROM Conciliacion_ATM_Stat06
	            WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
	            AND Numcajero = vsNumCajero 
				AND ( ( Descripcion = 'CONSULTA ' || vsCredDeb ) OR ( Descripcion = 'CONSULTA ' || vsAuxCredDeb ) )            
				AND IndicadordeReversa = '' ;

	        --total de  VENTA ELECTRONICA #  $
	        SELECT COUNT(keyx), SUM (NVL(Monto, 0.0)) INTO viNum_Venta_Electronica, vmMonto_Venta_Electronica FROM Conciliacion_ATM_Stat06
	            WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
	            AND Numcajero = vsNumCajero             
				AND ( ( Descripcion = 'VTA_ELEC ' || vsCredDeb ) OR ( Descripcion = 'VTA_ELEC ' || vsAuxCredDeb ) )
				AND IndicadordeReversa = '' ;
				
	         --AND descripcion = vsVenta_Electronica 
			 
			--total de  CAMBIOS DE NIP
			SELECT COUNT(keyx) INTO viNum_Cambio_NIP FROM Conciliacion_ATM_Stat06
	            WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
	            AND Numcajero = vsNumCajero 
	            AND descripcion = 'CAMB_NIP NO_CTA' 
				AND NumTarjeta LIKE vsBin || '%' ;
				
			IF ( viNum_Cambio_NIP IS NULL ) THEN 
				LET viNum_Cambio_NIP = 0 ;
			END IF ;
			
			/*ACUMULA LOS TOTALES DEL REPORTE*/
			LET viTotal_Num_Retiros = viTotal_Num_Retiros + NVL(viNum_Retiros, 0) ;
			LET vmTotal_Monto_Retiros = vmTotal_Monto_Retiros + NVL(vmMonto_Retiros, 0.0) ;
			LET viTotal_Num_Consultas = viTotal_Num_Consultas + NVL(viNum_Consultas, 0) ;
			LET viTotal_Num_Cambio_NIP = viTotal_Num_Cambio_NIP + NVL(viNum_Cambio_NIP, 0) ;
			LET viTotal_Num_Venta_Electronica = viTotal_Num_Venta_Electronica + NVL(viNum_Venta_Electronica, 0)  ;
			LET vmTotal_Monto_Venta_Electronica = vmTotal_Monto_Venta_Electronica + NVL(vmMonto_Venta_Electronica, 0.0) ;
			
	        INSERT INTO intercard:tmpRpts_Stat06(Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7)
			VALUES ( NVL(vsNumCajero, ''), NVL(viNum_Retiros, 0), NVL(vmMonto_Retiros, 0.0), NVL(viNum_Consultas, 0), NVL(viNum_Cambio_NIP, 0), 
					NVL(viNum_Venta_Electronica, 0), NVL(vmMonto_Venta_Electronica, 0.0));

	    END FOREACH ; 
				
	    IF ( viTotalCajeros < 1) THEN 
	        INSERT INTO intercard:tmpRpts_Stat06(Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7)
			VALUES ( NVL(vsNumCajero, ''), NVL(viNum_Retiros, 0), NVL(vmMonto_Retiros, 0.0), NVL(viNum_Consultas, 0), NVL(viNum_Cambio_NIP, 0), 
					NVL(viNum_Venta_Electronica, 0), NVL(vmMonto_Venta_Electronica, 0.0));
	    END IF ; 
		
		-- SEPARADORES DE TOTALES
		INSERT INTO intercard:tmpRpts_Stat06(Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7)
		VALUES ( '------------------------', '------------------------', '------------------------', 
				'------------------------', '------------------------', 
				'------------------------', '------------------------');
		
		INSERT INTO intercard:tmpRpts_Stat06(Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7)
		VALUES ( '', NVL(viTotal_Num_Retiros, 0), NVL(vmTotal_Monto_Retiros, 0.0), NVL(viTotal_Num_Consultas, 0), NVL(viTotal_Num_Cambio_NIP, 0), 
				NVL(viTotal_Num_Venta_Electronica, 0), NVL(vmTotal_Monto_Venta_Electronica, 0.0));
				
		RETURN vsCodRet;
		
	ELSE
		RETURN vsCodRet;
	END IF;	

END

END PROCEDURE;