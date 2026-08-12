CREATE PROCEDURE "informix".sp_reporteatmstat06cajero( psFechaIni CHAR (10), psFechaFin CHAR (10) )
RETURNING CHAR (4);

--****************************************************************************************************
-- DESCRIPCION: REPORTE DE CAJEROS PROPIOS , CORTE POR CAJERO 
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : -- 29/07/2008  ZERO 
-- MODIFICADO : Marcos Cuevas 				Fecha : 21/08/2008
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vsNumCajero CHAR (14) ;
DEFINE vsEmisor CHAR (4) ;
DEFINE viTotalTransacciones  INTEGER ;
DEFINE viTotalTransAprobadas INTEGER ; 
DEFINE viTotalTransrechazados INTEGER ;
DEFINE viTotalTransConsulta INTEGER ;
DEFINE viTotalTransRetiros INTEGER ;
DEFINE viTotalTransReversos INTEGER ;
DEFINE viTotalTransCredito INTEGER ;
DEFINE viTotalTransDebito INTEGER ;
DEFINE vsNomBanco CHAR (20) ;
DEFINE vsCodRet CHAR (4) ;

---TOTALES POR CAJERO
DEFINE viTotalTransaccionesXCajero INTEGER ;
DEFINE viTotalTransAprobadasXCajero INTEGER ; 
DEFINE viTotalTransrechazadosXCajero INTEGER ;
DEFINE viTotalTransConsultaXCajero INTEGER ;
DEFINE viTotalTransRetirosXCajero INTEGER ;
DEFINE viTotalTransReversosXCajero INTEGER ;
DEFINE viTotalTransCreditoXCajero INTEGER ;
DEFINE viTotalTransDebitoXCajero INTEGER ;

DEFINE viTotalCajeros INTEGER ;
DEFINE vsCajeroTemp CHAR (14) ;
/* INICIALIZACION DE VARIABLES */

LET vsNumCajero  = '' ;
LET vsEmisor  = '' ;
LET viTotalTransacciones  = 0 ;
LET viTotalTransAprobadas = 0 ;
LET viTotalTransrechazados = 0 ;
LET viTotalTransConsulta = 0 ;
LET viTotalTransRetiros = 0 ;
LET viTotalTransReversos = 0 ;
LET viTotalTransCredito = 0 ;
LET viTotalTransDebito = 0 ;
LET vsNomBanco = '' ;
LET vsCodRet = '0000' ;

LET viTotalTransaccionesXCajero = 0 ;
LET viTotalTransAprobadasXCajero = 0 ;
LET viTotalTransrechazadosXCajero = 0 ;
LET viTotalTransConsultaXCajero = 0 ;
LET viTotalTransRetirosXCajero = 0 ;
LET viTotalTransReversosXCajero = 0 ;
LET viTotalTransCreditoXCajero = 0 ;
LET viTotalTransDebitoXCajero = 0 ;  


LET viTotalCajeros = 0 ;
LET vsCajeroTemp =  '' ;
BEGIN

	--Borra la tabla  intercard:tmpRpts_Stat06
	
	DELETE FROM intercard:tmpRpts_Stat06;
	
	-- Se calculan valores

    FOREACH SELECT NumCajero, Emisor INTO vsNumCajero, vsEmisor FROM Conciliacion_ATM_Stat06
        WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
        GROUP BY NumCajero, Emisor ORDER BY NumCajero, Emisor ASC

        LET viTotalCajeros = viTotalCajeros + 1 ;

        --Nombre del banco
        SELECT Nombre INTO vsNomBanco FROM Banco 
            WHERE ClaveBanco = vsEmisor ;

        IF ( ( vsNomBanco IS NULL ) OR ( vsNomBanco = '' ) ) THEN 
            LET vsNomBanco = vsEmisor ;
        END IF ;

        --total de transacciones por cajero y banco
        SELECT COUNT (keyx) INTO viTotalTransacciones  FROM Conciliacion_ATM_Stat06
            WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
            AND Numcajero = vsNumCajero AND Emisor = vsEmisor ;

         --total de transacciones rechazadas 
        SELECT COUNT(keyx) INTO viTotalTransrechazados FROM Conciliacion_ATM_Stat06
            WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
            AND Numcajero = vsNumCajero AND Emisor = vsEmisor
            AND CodigoISO <> '00' ;

            --total de transacciones aprobadas
        LET viTotalTransAprobadas = viTotalTransacciones - viTotalTransrechazados ;

            --total de CONSULTAS
        SELECT COUNT(keyx) INTO viTotalTransConsulta FROM Conciliacion_ATM_Stat06
            WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
            AND Numcajero = vsNumCajero AND Emisor = vsEmisor
            AND descripcion LIKE 'CONSULTA%' AND IndicadordeReversa = '' ;

            --total de REVERSOS
        SELECT COUNT (keyx) INTO viTotalTransReversos FROM Conciliacion_ATM_Stat06
            WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
            AND Numcajero = vsNumCajero AND Emisor = vsEmisor
            AND IndicadordeReversa <> '' ;

            --total de RETIROS
        LET viTotalTransRetiros = viTotalTransacciones - ( viTotalTransConsulta + viTotalTransReversos ) ;

         --total de transacciones credito
        SELECT COUNT(keyx) INTO viTotalTransCredito FROM Conciliacion_ATM_Stat06
            WHERE (  SUBSTRING (FECHA FROM 4 FOR 2 )  || '-' || SUBSTRING (FECHA FROM 1 FOR 2 ) || '-' || SUBSTRING (FECHA FROM 7 FOR 2 )   )::DATE BETWEEN psFechaIni AND psFechaFin 
            AND Numcajero = vsNumCajero AND Emisor = vsEmisor
            AND (Descripcion LIKE '%CREDIT' OR Descripcion LIKE '%MAESTR');

        LET viTotalTransDebito = viTotalTransacciones - viTotalTransCredito ;

			 
		IF ( vsCajeroTemp = vsNumCajero ) THEN 	--CAJEROS IGUALES ACUMULAR TOTALES
			---TOTALES POR CAJERO
			LET viTotalTransaccionesXCajero = viTotalTransaccionesXCajero + NVL(viTotalTransacciones, 0) ;
			LET viTotalTransAprobadasXCajero = viTotalTransAprobadasXCajero + NVL(viTotalTransAprobadas, 0) ;
			LET viTotalTransrechazadosXCajero = viTotalTransrechazadosXCajero + NVL(viTotalTransrechazados, 0) ;
			LET viTotalTransConsultaXCajero = viTotalTransConsultaXCajero + NVL(viTotalTransConsulta, 0) ;
			LET viTotalTransRetirosXCajero = viTotalTransRetirosXCajero + NVL(viTotalTransRetiros, 0) ;
			LET viTotalTransReversosXCajero = viTotalTransReversosXCajero + NVL(viTotalTransReversos, 0) ;
			LET viTotalTransCreditoXCajero = viTotalTransCreditoXCajero + NVL(viTotalTransCredito, 0) ;
			LET viTotalTransDebitoXCajero = viTotalTransDebitoXCajero + NVL(viTotalTransDebito, 0) ;  
			 
		ELSE -- CAJEROS DISTINTOS    INICIALIZAR TOTALES
		
			IF ( viTotalCajeros > 1 ) THEN 
				INSERT INTO intercard:tmpRpts_Stat06(Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7,Campo8,Campo9,Campo10)
				VALUES ( vsNumCajero, 'TOTAL', viTotalTransaccionesXCajero, viTotalTransAprobadasXCajero, viTotalTransrechazadosXCajero, 
                        viTotalTransConsultaXCajero, viTotalTransRetirosXCajero, viTotalTransReversosXCajero, viTotalTransCreditoXCajero, 
						viTotalTransDebitoXCajero);
						
			END IF ;
			
			
			---TOTALES POR CAJERO
			LET viTotalTransaccionesXCajero = NVL(viTotalTransacciones, 0) ;
			LET viTotalTransAprobadasXCajero = NVL(viTotalTransAprobadas, 0) ;
			LET viTotalTransrechazadosXCajero = NVL(viTotalTransrechazados, 0) ;
			LET viTotalTransConsultaXCajero = NVL(viTotalTransConsulta, 0) ;
			LET viTotalTransRetirosXCajero = NVL(viTotalTransRetiros, 0) ;
			LET viTotalTransReversosXCajero = NVL(viTotalTransReversos, 0) ;
			LET viTotalTransCreditoXCajero = NVL(viTotalTransCredito, 0) ;
			LET viTotalTransDebitoXCajero = NVL(viTotalTransDebito, 0) ;  
			
			LET vsCajeroTemp = vsNumCajero ;
						
			
		END IF ;
		
        INSERT INTO intercard:tmpRpts_Stat06(Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7,Campo8,Campo9,Campo10)
		VALUES ( NVL(vsNumCajero, ''), NVL(vsNomBanco, ''), NVL(viTotalTransacciones, 0), NVL(viTotalTransAprobadas, 0), NVL(viTotalTransrechazados, 0), 
				NVL(viTotalTransConsulta, 0), NVL(viTotalTransRetiros, 0), NVL(viTotalTransReversos, 0), NVL(viTotalTransCredito, 0), 
				NVL(viTotalTransDebito, 0));

    END FOREACH ;

	IF (viTotalCajeros > 0) THEN --REGESA EL ULTIMO ACUMULADO DEL REPORTE
	
		INSERT INTO intercard:tmpRpts_Stat06(Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7,Campo8,Campo9,Campo10)
		VALUES ( NVL(vsNumCajero, ''), 'TOTAL', NVL(viTotalTransaccionesXCajero, 0), NVL(viTotalTransAprobadasXCajero, 0), NVL(viTotalTransrechazadosXCajero, 0), 
				NVL(viTotalTransConsultaXCajero, 0), NVL(viTotalTransRetirosXCajero, 0), NVL(viTotalTransReversosXCajero, 0), NVL(viTotalTransCreditoXCajero, 0), 
				NVL(viTotalTransDebitoXCajero, 0));
	
	ELSE -- NO HAY REGISTROS  
		
		LET vsCodRet = '0001';
		
	END IF ;
	
	RETURN vsCodRet;

END

END PROCEDURE;