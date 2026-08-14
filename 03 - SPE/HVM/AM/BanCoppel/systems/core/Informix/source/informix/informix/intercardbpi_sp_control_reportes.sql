CREATE PROCEDURE "informix".sp_control_reportes( psArchivoOrigen CHAR(3), piTipoReporte INTEGER,  psFechaIni CHAR (14), psFechaFin CHAR (14) )

RETURNING INTEGER AS Retorno, CHAR (250) AS NomArchivo, CHAR (250) AS Repositorio;

--****************************************************************************************************
-- DESCRIPCION:  CONTROLA LOS SP DE REPORTES DE ATM (STAT 06 Y 07 ) Y REPORTES DE POS
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 06/08/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : --ZERO 
-- MODIFICADO : Marcos Cuevas 				Fecha : 21/08/2008
--MODIFICADO: EDGAR IVAN ROCHIN ROCHA            FECHA: 2/09/2008 REDIRECCIONAMIENTO A TABLA PARAMETROS_CONCILIACIONAUTO
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsRepositorio_Historico VARCHAR (250) ;
DEFINE vsRepositorio_Proceso VARCHAR (250) ;
DEFINE vsSQL CHAR (1000) ;
DEFINE vsSQL1 CHAR (150);
DEFINE vsSQL2 CHAR (400) ;
DEFINE vsSQL3 CHAR (150) ;
DEFINE vsNomArchivo VARCHAR (250);
DEFINE vsAuxiliar CHAR (1);
DEFINE vsCodRet CHAR (4) ;

DEFINE viSqlError INTEGER ;


/* INICIALIZACION DE VARIABLES */

LET vsRepositorio_Historico = '' ;
LET vsRepositorio_Proceso = '' ;
LET vsSQL = '' ;
LET vsSQL1 = '' ;
LET vsSQL2 = '' ;
LET vsSQL3 = '' ;
LET vsNomArchivo = '' ;
LET vsAuxiliar = '' ;
LET vsCodRet = '0000' ;

LET viSqlError = 0 ;

BEGIN	
		
ON EXCEPTION SET viSqlError  --cacha el error en caso de que exista y regresa un valor predeterminado
	
	IF viSqlError <> 0 THEN             		

	   RETURN viSqlError, vsNomArchivo, vsRepositorio_Historico;

	END IF; 
	
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/conciliacion/reportes.txt';
--TRACE ON ;

	--OBTIENE LA DIRECCION DE LA CARPETA DEL HISTORICO PARA DEJAR LOS ARCHIVOS DE LOS REPORTES 
	SELECT NVL(Valor, '') INTO vsRepositorio_Historico FROM Param_ConciliacionAuto WHERE Descripcion = 'REP_HISTORICO';
	SELECT NVL(Valor, '') INTO vsRepositorio_Proceso FROM Param_ConciliacionAuto WHERE Descripcion = 'REP_PROCESO';

	LET vsRepositorio_Historico = TRIM(vsRepositorio_Historico) || '/' ;
	LET vsRepositorio_Proceso = TRIM(vsRepositorio_Proceso)  ;
	
	IF (psArchivoOrigen = 'ATM') THEN  --  1-9
		--1 RETIROS NACIONALES CREDITO    
	    --2 RETIROS NACIONALES DEBITO	
	    --3 RETIROS TOTAL NACIONALES 	
	    --4 RETIROS INTERNACIONALES CREDITO
	    --5 RETIROS INTERNACIONALES DEBITO
	    --6 RETIROS TOTAL INTERNACIONALES       
	    --7 CAJEROS PROPIOS  RETIROS CREDITO
	    --8 CAJEROS PROPIOS  RETIROS DEBITO
		--9 CAJEROS PROPIOS  TOTALES
	    IF ( piTipoReporte = 1 ) THEN --RETIROS NACIONALES CREDITO
	        LET vsNomArchivo = 'RET_NAC_CRED' ;

	    ELIF ( piTipoReporte = 2 ) THEN  --RETIROS NACIONALES DEBITO
	        LET vsNomArchivo = 'RET_NAC_DEB' ;
			
	    ELIF ( piTipoReporte = 3 ) THEN --RETIROS TOTAL NACIONALES 
	        LET vsNomArchivo = 'RET_NAC_TOTAL' ; 
			
	    ELIF ( piTipoReporte = 4 ) THEN --RETIROS INTERNACIONALES CREDITO
	        LET vsNomArchivo = 'RET_INT_CRED' ;
			
	    ELIF ( piTipoReporte = 5 ) THEN --RETIROS INTERNACIONALES DEBITO
	        LET vsNomArchivo = 'RET_INT_DEB' ;

	    ELIF ( piTipoReporte = 6 ) THEN --RETIROS TOTAL INTERNACIONALES
	        LET vsNomArchivo = 'RET_INT_TOTAL' ; 

	    ELIF ( piTipoReporte = 7 ) THEN --CAJEROS PROPIOS  RETIROS CREDITO
	        LET vsNomArchivo = 'RET_PROP_CRED' ;

	    ELIF ( piTipoReporte = 8 ) THEN --CAJEROS PROPIOS  RETIROS DEBITO
	        LET vsNomArchivo = 'RET_PROP_DEB' ;

		ELIF ( piTipoReporte = 9 ) THEN --CAJEROS PROPIOS  TOTALES
	        LET vsNomArchivo = 'RET_PROP_TOTAL' ; 

	    END IF ;
	
		--FORMA EL NOMBRE DEL ARCHIVO
		LET vsNomArchivo = 'RPT_ATM_' || TRIM(vsNomArchivo) || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt';
		
		EXECUTE PROCEDURE sp_ReporteATMStat07 ( piTipoReporte,psFechaIni,psFechaFin) INTO vsCodRet;
		
		IF (vsCodRet = '0000') THEN
			LET vsSQL1 = 'echo "UNLOAD TO ' || vsRepositorio_Historico || vsNomArchivo || ' DELIMITER ' || '''|''';
			LET vsSQL2 = ' SELECT CodProductoTarjeta ,ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, FechaDeConciliacion, ' 
			|| 'StatusDeConciliacion,NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, '
			|| 'HoraLocalTransaccion, CodReversa, MontoRetenido, IdReceptor, Referencia, NomBanco FROM intercard:tmpRpts_ATM ';
			LET vsSQL3 = ' " > '|| TRIM(vsRepositorio_Proceso) || '/control_reporte.sql';
			
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL3 = TRIM(vsSQL3);
			
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
		ELSE
			LET viSqlError = 1 ;
		END IF; 	
		
		--EXECUTE PROCEDURE sp_ReporteATMStat07 ( piTipoReporte INTEGER,  psFechaIni CHAR (14), psFechaFin CHAR (14) )		
		
		
	ELIF (psArchivoOrigen = 'POS') THEN -- 1-10
		--1 VENTAS NACIONALES CREDITO
	    --2 VENTAS NACIONALES DEBITO
	    --3 TOTAL VENTAS NACIONALES 
	    --4 PAGOS INTERBANCARIOS 
	    --5 VENTAS INTERNACIONALES CREDITO
	    --6 VENTAS INTERNACIONALES DEBITO       
	    --7 TOTAL  VENTAS INTERNACIONALES
	    --8 TIENDAS COPPEL CREDITO        
	    --9TIENDAS COPPEL DEBITO 
	    --10 TOTAL TIENDAS COPPEL 
		
		IF ( piTipoReporte = 1 ) THEN --VENTAS NACIONALES CREDITO
	        LET vsNomArchivo = 'VEN_NAC_CRED' ;

	    ELIF ( piTipoReporte = 2 ) THEN  --VENTAS NACIONALES DEBITO
	        LET vsNomArchivo = 'VEN_NAC_DEB' ;

	    ELIF ( piTipoReporte = 3 ) THEN -- TOTAL VENTAS NACIONALES 
	        LET vsNomArchivo = 'VEN_NAC_TOTAL' ;

	    ELIF ( piTipoReporte = 4 ) THEN --PAGOS INTERBANCARIOS
	        LET vsNomArchivo = 'PAGO_INTERBAN' ;

	    ELIF ( piTipoReporte = 5 ) THEN --VENTAS INTERNACIONALES CREDITO
	        LET vsNomArchivo = 'VEN_INT_CRED' ;

	    ELIF ( piTipoReporte = 6 ) THEN --VENTAS INTERNACIONALES DEBITO
	        LET vsNomArchivo = 'VEN_INT_DEB' ;   

	    ELIF ( piTipoReporte = 7 ) THEN --TOTAL  VENTAS INTERNACIONALES
			LET vsNomArchivo = 'VEN_INT_TOTAL' ;

	    ELIF ( piTipoReporte = 8 ) THEN --TIENDAS COPPEL CREDITO
	        LET vsNomArchivo = 'VEN_COP_CRED' ;   
	        
	    ELIF ( piTipoReporte = 9 ) THEN --TIENDAS COPPEL DEBITO 
	        LET vsNomArchivo = 'VEN_COP_DEB' ;
	        
	    ELIF ( piTipoReporte = 10 ) THEN --TOTAL TIENDAS COPPEL 
	        LET vsNomArchivo = 'VEN_COP_TOTAL' ;
	       
	    END IF ;  
		
		--FORMA EL NOMBRE DEL ARCHIVO
		LET vsNomArchivo = 'RPT_POS_' || TRIM(vsNomArchivo) || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt';
		
		EXECUTE PROCEDURE sp_ReportesPOS325 (piTipoReporte,psFechaIni,psFechaFin) INTO vsCodRet;
		
		IF (vsCodRet = '0000') THEN
			LET vsSQL1 = 'echo "UNLOAD TO ' || vsRepositorio_Historico || vsNomArchivo || ' DELIMITER ' || '''|''';
			LET vsSQL2 = ' SELECT CodProductoTarjeta, ProdInd, Formato, CodTran, NumeroTarjeta, ClaveAutDeTransaccion, FechaDeConciliacion, ' 
			|| 'StatusDeConciliacion, NumCtaChequesAfectada, MontoDeTransaccion, MontoComisionCobrada, FechaLocalTransaccion, '
			|| 'HoraLocalTransaccion, CodReversa, MontoRetenido,IdReceptor, Referencia, MontoCashBack, NombreComercio, IdComercio FROM intercard:tmpRpts_POS ';
			LET vsSQL3 = ' " > '|| TRIM(vsRepositorio_Proceso) || '/control_reporte.sql';
			
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL3 = TRIM(vsSQL3);
			
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
		   
		ELSE
			LET viSqlError = 1 ;
		END IF;
		
		--EXECUTE PROCEDURE sp_ReportesPOS325 ( psTipoConsulta INTEGER,  psFechaIni CHAR (14), psFechaFin CHAR (14) )
	ELIF (psArchivoOrigen = 'TMO') THEN -- 5
		IF (piTipoReporte = 1) THEN --CORTE POR CAJERO Y FECHA
			
			LET vsNomArchivo = 'STAT06_CAJERO' ;
			LET vsNomArchivo = 'RPT_TMO_' || TRIM(vsNomArchivo) || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt' ;
			
			EXECUTE PROCEDURE sp_ReporteATMStat06Cajero (psFechaIni,psFechaFin)INTO vsCodRet;
			
			--IF (vsCodRet = '0000') THEN
			LET vsSQL1 = 'echo "UNLOAD TO ' || vsRepositorio_Historico || vsNomArchivo || ' DELIMITER ' || '''|''';
			LET vsSQL2 = ' SELECT Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7,Campo8,Campo9,Campo10 FROM intercard:tmpRpts_Stat06 ';
			LET vsSQL3 = ' " > '|| TRIM(vsRepositorio_Proceso) || '/control_reporte.sql';
			
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL3 = TRIM(vsSQL3);
			
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
		 
			--ELSE
			--	LET viSqlError = 1 ;
			--END IF;	
			
		ELIF ((piTipoReporte = 2) OR (piTipoReporte = 3)) THEN  -- CORTE POR CAJERO, FECHA Y TIPO DE TARJETA (CREDITO - DEBITO)
			
			IF ( piTipoReporte = 2) THEN 
				LET vsNomArchivo = 'DET_CRED' ;
				LET vsAuxiliar = 'C' ;
			ELSE
				LET vsNomArchivo = 'DET_DEB' ;
				LET vsAuxiliar = 'D' ;
			END IF ;
			
			--FORMA EL NOMBRE DEL ARCHIVO
			LET vsNomArchivo = 'RPT_TMO_' || TRIM(vsNomArchivo) || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt';
			
			EXECUTE PROCEDURE sp_Rep_Stat06_TransXCajeroCredDeb(TRIM(vsAuxiliar),TRIM(psFechaIni),TRIM(psFechaFin))INTO vsCodRet;
			
			--IF (vsCodRet = '0000') THEN
			LET vsSQL1 = 'echo "UNLOAD TO ' || vsRepositorio_Historico || vsNomArchivo || ' DELIMITER ' || '''|''';
			LET vsSQL2 = ' SELECT Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7,Campo8 FROM intercard:tmpRpts_Stat06 ';
			LET vsSQL3 = ' " > '|| TRIM(vsRepositorio_Proceso) || '/control_reporte.sql';
			
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL3 = TRIM(vsSQL3);
			
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;          			
			--ELSE
			--	LET viSqlError = 1 ;
			--END IF;	
			
		ELIF ((piTipoReporte = 4) OR (piTipoReporte = 5)) THEN  --TOTALES POR CAJERO, FECHA Y TIPO DE TARJETA (CREDITO - DEBITO)
			
			IF ( piTipoReporte = 4 ) THEN 
				LET vsNomArchivo = 'DET_CAJ_CRED' ;
				LET vsAuxiliar = 'C' ;
			ELSE
				LET vsNomArchivo = 'DET_CAJ_DEB' ;
				LET vsAuxiliar = 'D' ;
			END IF ;
			
			--FORMA EL NOMBRE DEL ARCHIVO
			LET vsNomArchivo = 'RPT_TMO_' || TRIM(vsNomArchivo) || '_' || CAST(TO_CHAR(current, '%d%m%Y') as char(8)) || '.txt';
			
			EXECUTE PROCEDURE sp_Rep_Stat06_TransaccionesTodoATM(TRIM(vsAuxiliar),TRIM(psFechaIni),TRIM(psFechaFin))INTO vsCodRet;
			
			--IF (vsCodRet = '0000') THEN
			LET vsSQL1 = 'echo "UNLOAD TO ' || vsRepositorio_Historico || vsNomArchivo || ' DELIMITER ' || '''|''';
			LET vsSQL2 = ' SELECT Campo1,Campo2,Campo3,Campo4,Campo5,Campo6,Campo7 FROM intercard:tmpRpts_Stat06 ';
			LET vsSQL3 = ' " > '|| TRIM(vsRepositorio_Proceso) || '/control_reporte.sql';
			
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL3 = TRIM(vsSQL3);
			
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
			--ELSE
			--	LET viSqlError = 1 ;
			--END IF;
			
		END IF ;

	ELSE
		LET viSqlError = 2 ;	
	END IF ;

	--CHECA QUE NO ESTE VACIA LA CONSULTA
	IF ( vsSQL <> '' ) THEN 
		SYSTEM vsSQL ;

        let vsSQL = '' ;
        let vsSQL = 'dbaccess intercard ' || TRIM(vsRepositorio_Proceso) || '/control_reporte.sql' ;          					
        SYSTEM vsSQL ;
		 
	ELSE -- CONSULTA VACIA	
		LET viSqlError = 1 ;
	END IF ;	
	
	RETURN viSqlError, vsNomArchivo, vsRepositorio_Historico;

END

END PROCEDURE;