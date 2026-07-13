CREATE PROCEDURE "informix".sp_reporte_credito_hipotecario()
	        RETURNING CHAR(5) AS resultado;

	--Variables--

	
	DEFINE dFechaHoy            DATE;
	DEFINE iSqlErr      		INTEGER;
	DEFINE iIsamErr     		INTEGER;
	DEFINE cMsjError      		CHAR(500);
	DEFINE cCodRet      		CHAR(5);
	DEFINE cCons1				CHAR(1000);
	DEFINE pArchDescarga		CHAR(150);
	DEFINE cnom_Sql				CHAR(100);
	DEFINE cSQL1				CHAR(200);
	DEFINE cRuta				CHAR(100);
	DEFINE cSQL                 CHAR(100) ;
	DEFINE cQuery			    CHAR(6000);
	DEFINE prueba               CHAR(10);
	DEFINE cclbRef              VARCHAR(20);
	DEFINE cmonto               DECIMAL(12,2);
	DEFINE cfecha               DATETIME YEAR TO FRACTION(5);
	DEFINE cfolioSuc            CHAR(19);
	DEFINE cRutaArch            CHAR(300);
	DEFINE dFechaAyerInicio     DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaAyerFin        DATETIME YEAR TO FRACTION(5);
 
	LET dFechaHoy 		= '';
	LET cCodRet      	= '00000';
	LET iSqlErr      	= 0;
	LET iIsamErr     	= 0;
	LET cQuery			= "";
	LET cRuta		 	= "/resplogifx/hipotecario_bancoppel/";
	LET cnom_Sql 		= 'MEDIOS_DE_PAGO_SPEI_' ;
	
	LET cclbRef         = '';
	LET cmonto          = 0.00;
	LET cfecha          = '';
	LET cfolioSuc       = '';
	LET cRutaArch       = '';

   --CONTROL DE ERRORES--

  BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/hipotecario_bancoppel/pro_1229_reporte_credito_hipotecario.err";
            TRACE ON;

			LET cCodRet = '00000';
			RETURN cCodRet; 
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/resplogifx/hipotecario_bancoppel/pro_1229_reporte_credito_hipotecario.out';
    --TRACE ON;
        
	    LET dFechaHoy = TODAY - 1;
	   
	    LET dFechaAyerInicio = EXTEND(TODAY-1, YEAR to FRACTION);
	    
	    LET dFechaAyerFin = EXTEND(TODAY, YEAR to FRACTION);
	    
	    --- Reportes Salida 
		LET pArchDescarga  = cnom_Sql;
		
		LET pArchDescarga = TRIM(pArchDescarga) || lpad(year(dFechaHoy),4,'0') || lpad(month(dFechaHoy),2,'0') ||  lpad(day(dFechaHoy),2,'0') || '.csv';
		
		LET cRutaArch = TRIM(cRuta) || pArchDescarga;
        
        LET cQuery = 'echo "clabe_referencia,monto,fecha,folio_suc" > ' || cRutaArch;
		SYSTEM cQuery;
        
		/*Generacion de Reporte*/
		FOREACH
	    
	        SELECT CONCAT('''',clabe_referencia), monto, fecha, folio_suc 
	        INTO cclbRef, cmonto, cfecha, cfolioSuc
	        FROM bdicheq:sc_creditohipotecario 
	        WHERE 
			fecha >= dFechaAyerInicio AND 
			fecha < dFechaAyerFin
	        AND status_envio = 'L'
	        
            LET cQuery = 'echo "' || cclbRef || ',' || cmonto || ',' || cfecha || ',' || cfolioSuc || '" >> ' || cRutaArch;
            SYSTEM TRIM(cQuery);
        
        END FOREACH;
		
		LET cQuery = 'chmod 777 ' || cRutaArch;
		SYSTEM cQuery;
        
		RETURN cCodRet;
	END;
END PROCEDURE;