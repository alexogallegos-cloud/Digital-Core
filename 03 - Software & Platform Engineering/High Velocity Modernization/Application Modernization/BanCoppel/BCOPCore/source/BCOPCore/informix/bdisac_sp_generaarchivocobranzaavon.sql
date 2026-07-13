CREATE PROCEDURE "informix".sp_generaarchivocobranzaavon(pConvenio CHAR(5))
   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR (5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE cDia                     CHAR (2);
	DEFINE cMes                     CHAR (2);
	DEFINE cAnio                    CHAR (2);
    DEFINE cDiaPago                 CHAR (2);
	DEFINE cMesPago                 CHAR (2);
    DEFINE cAnioPago                CHAR (4);
    DEFINE cCategoria               CHAR (2);
    DEFINE cConvenio                CHAR (3);                                              
    DEFINE cReferencia1             CHAR (20);
    DEFINE cRutaArchAvon            CHAR (100);
    DEFINE cStmt                    CHAR (250);
	DEFINE cCveBancoppel            CHAR (100);
    DEFINE cFolio                   CHAR (16);
	DEFINE cTpoOperacion            CHAR (1);
	DEFINE cValor					CHAR(100);
	DEFINE cCuenta_Prestadora       CHAR(20);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE iImporte_Comision        INTEGER;
    DEFINE iSumaImporte_Comision    INTEGER;	
	DEFINE iImporte_IVA_Comision    INTEGER;
	DEFINE iSumaImporte_IVA_Comision INTEGER;	
	DEFINE iImporte_Pago            INTEGER;
	DEFINE iTotal_Pago              INTEGER;
    DEFINE iFlagCen                 INTEGER;
    DEFINE iFlagSuc                 INTEGER;
	DEFINE iCuantos                 INTEGER;
	DEFINE iNumPagos                INTEGER;
	DEFINE iTransac                 INTEGER;
	DEFINE iMonto_tot               INTEGER;
	DEFINE mMonto_tot               MONEY(12,2);
    DEFINE dFecha_Pago              DATE;    
    --INICIALIZACION DE VARIABLES--
    LET cCodRet       		  = "00000";
    LET iSqlErr       		  = 0;
    LET cCategoria    		  = SUBSTRING(pConvenio FROM 1 FOR 2);
    LET cConvenio     		  = SUBSTRING(pConvenio FROM 3 FOR 3);
    LET cReferencia1  		  = '';
    LET cDia          		  = '';
    LET cMes          		  = '';
    LET cAnio         		  = '';
	LET cDiaPago       		  = '';
	LET cMesPago       		  = '';
    LET cAnioPago      		  = '';
    LET iImporte_Pago 		  = 0;
	LET iImporte_Comision 	  = 0;
	LET iSumaImporte_Comision = 0;
	LET iImporte_IVA_Comision = 0;
	LET iSumaImporte_IVA_Comision = 0;
	LET iTotal_Pago  		  = 0;
    LET cFolio        		  = '';                 
    LET iFlagCen      		  = 0;                 
    LET iFlagSuc      		  = 0;      
    LET cCveBancoppel    	  = '';	
	LET cRutaArchAvon  		  = '';
	LET	iCuantos      		  = 0;
	LET cStmt         		  = '';
	LET dFechaIni     		  = DATE(1);
	LET dFecha_Hoy    		  = DATE(1);
	LET cTpoOperacion         = 'D';  
	LET iNumPagos             = 0;
	LET iTransac		      = 0;
	LET cValor				  = '';
	LET cCuenta_Prestadora    = '';
	LET mMonto_tot            = 0;
	LET iMonto_tot            = 0;
	
	--SET DEBUG FILE TO '/informix/noe/sp_generaarchivocobranzaavon.out';
	--TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

				UPDATE bdisac:"informix".sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

        SELECT fecha_hoy 
		  INTO dFecha_Hoy 
		  FROM bdisac:"informix".sac_fechas
		 WHERE empresa = "001";

        
		SELECT fecha_ultimo_archivo
          INTO dFechaIni
          FROM bdisac:"informix".sac_controlarchivoscobranza
         WHERE numcategoria = cCategoria
           AND numconvenio = cConvenio;

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
				
		
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza),cuenta_prestadora
		  INTO cRutaArchAvon,cCuenta_Prestadora
		  FROM bdisac:"informix".sac_convenios
		 WHERE numcategoria = cCategoria
           AND numconvenio = cConvenio;
     	
		LET cRutaArchAvon = REPLACE(cRutaArchAvon,'AA',cAnio);
		LET cRutaArchAvon = REPLACE(cRutaArchAvon,'MM',cMes);
		LET cRutaArchAvon = REPLACE(cRutaArchAvon,'DD',cDia);

		-- Consulta de la TransacciÃ³n del Servicio

		LET iTransac = 6017; -- OJO************ CAMBIAR
		SELECT valor 
		  INTO cValor
		  FROM bdisac:"informix".sac_param 
		 WHERE empresa = '001'
		   AND cod_param  = iTransac;
		
		LET iTransac = 6018;
		SELECT valor 
		  INTO cCveBancoppel
		  FROM bdisac:"informix".sac_param 
		 WHERE empresa = '001'
		  AND cod_param  = iTransac;
		
		--Consulta del IDE
		SELECT NVL(monto_tot,0)
		  INTO mMonto_tot
		  FROM bdicheq:"informix".sc_movhis
		 WHERE empresa = '001'
		   AND fech_alt = dFecha_Hoy
		   AND transacc =  cValor
		   AND cuenta = cCuenta_Prestadora;
		   
		IF mMonto_tot IS NULL THEN
			LET mMonto_tot = 0;
		END IF;
		
		LET iMonto_tot = mMonto_tot;
		LET iMonto_tot = iMonto_tot * 100;
			
        SET ISOLATION TO DIRTY READ;
        FOREACH
            
            SELECT LPAD(DAY(fecha_pago::DATE), 2, '0'), 
			       LPAD(MONTH(fecha_pago::DATE), 2, '0'),	
				   LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				   referencia1, 
				   importe_pago * 100,       
				   importe_comision_convenio * 100,
                   iva_comision_convenio * 100,
			       flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
	          INTO cDiaPago,cMesPago,cAnioPago,cReferencia1,iImporte_Pago,iImporte_Comision,iImporte_IVA_Comision,iFlagCen,iFlagSuc,cFolio, dFecha_Pago
              FROM bdisac:"informix".sac_movimientoshistorial
             WHERE numcategoria = cCategoria
              AND numconvenio = cConvenio
              AND fecha_pago > dFechaIni
              AND fecha_pago <= dFecha_Hoy
              AND status_cancelado <> 'S'
              AND (flag_confirmacion_central = 1
	          OR flag_confirmacion_sucursal = 1)
               
            IF iFlagCen = 0 or iFlagSuc =0 THEN
              SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
              IF iCuantos = 0 THEN
                 SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
                 IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                 END IF;
              END IF;
              IF iCuantos > 0 THEN            
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFecha_Pago,current);
					LET iCuantos = 0;
              END IF;
            END IF;			

			LET iSumaImporte_Comision = iSumaImporte_Comision + iImporte_Comision;
			LET iSumaImporte_IVA_Comision = iSumaImporte_IVA_Comision + iImporte_IVA_Comision;
			LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
			LET iNumPagos = iNumPagos + 1;
			
			--LINEA DE CODIGO QUE ARMABA EL DETALLE DE CADA PAGO CUANDO LA REFERENCIA ERA DE 14 POSICIONES
            --LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 8, '0') || LPAD(TRIM(cReferencia1), 14, '0') || LPAD(TRIM(cCveBancoppel), 2, '0') || LPAD(iImporte_Pago, 8, '0') || LPAD(cFolio, 16, '0') || '" >> ' || cRutaArchAvon;
			
			--NUEVA LINEA QUE ARMARA EL DETALLE CON LAS REFERENCIAS A 20 POSICIONES SEGUN RQM 10 1056
			  LET cStmt = 'echo "' || cTpoOperacion || cAnioPago || cMesPago || cDiaPago || LPAD(TRIM(cReferencia1), 2, '0') || LPAD(TRIM(cReferencia1), 20, '0') || LPAD(TRIM(cCveBancoppel), 2, '0') || LPAD(iImporte_Pago, 8, '0') || LPAD(cFolio, 16, '0') || '" >> ' || cRutaArchAvon;
			
            SYSTEM cStmt;
        END FOREACH;		
		
		LET cReferencia1 = '';
		LET cFolio       = '';
		
		IF iSumaImporte_Comision <> 0 THEN
			LET cTpoOperacion = 'C';  
			LET cStmt = 'echo "' || cTpoOperacion || cAnioPago || cMesPago || cDiaPago || LPAD(TRIM(cReferencia1), 8, '0') || LPAD(TRIM(cReferencia1), 14, '0') ||  LPAD(TRIM(cCveBancoppel), 2, '0') || LPAD(iSumaImporte_Comision, 8, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;
		END IF;
		
		IF iSumaImporte_IVA_Comision <> 0 THEN
		    LET cTpoOperacion = 'I';  
			LET cStmt = 'echo "' || cTpoOperacion || cAnioPago || cMesPago || cDiaPago || LPAD(TRIM(cReferencia1), 8, '0') || LPAD(TRIM(cReferencia1), 14, '0') ||LPAD(TRIM(cCveBancoppel), 2, '0') || LPAD(iSumaImporte_IVA_Comision, 8, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;
		END IF;
		
		IF mMonto_tot <> 0 THEN
			LET cTpoOperacion = 'E';  
			LET cStmt = 'echo "' || cTpoOperacion || cAnioPago || cMesPago || cDiaPago || LPAD(TRIM(cReferencia1), 8, '0') || LPAD(TRIM(cReferencia1), 14, '0') || LPAD(TRIM(cCveBancoppel), 2, '0') || LPAD(TRIM(TO_CHAR(iMonto_tot)), 8, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
			SYSTEM cStmt;
		END IF;
		
		IF iNumPagos <> 0 THEN
			LET cTpoOperacion = 'T';		
			LET iTotal_Pago = ((iTotal_Pago - iSumaImporte_Comision) - iSumaImporte_IVA_Comision) - iMonto_tot;
			
			LET cStmt = 'echo "' || cTpoOperacion || cAnioPago || cMesPago || cDiaPago || LPAD(TRIM(cReferencia1), 8, '0') || LPAD(TRIM(TO_CHAR(iNumPagos)), 14, '0') || LPAD(TRIM(cCveBancoppel), 2, '0') || LPAD(iTotal_Pago, 8, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
			SYSTEM cStmt;
		END IF;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cTpoOperacion = 'T'; 
			LET cStmt = 'echo "' || cTpoOperacion || LPAD(TRIM(cAnioPago),2,'0') || LPAD(TRIM(cMesPago),2,'0') || LPAD(TRIM(cDiaPago),2,'0') || LPAD(TRIM(cReferencia1), 8, '0') || LPAD(TRIM(cReferencia1), 14, '0') || LPAD(TRIM(cCveBancoppel), 2, '0') || LPAD(iTotal_Pago, 8, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;                 
        END IF;  



--ACTUALIZA BANDERA CONFIRMACION SUCURSAL
        FOREACH SELECT referencia, folio_suc, fecha_pago 
		        		INTO  cReferencia1, cFolio, dFecha_Pago
		        		FROM "informix".sac_bitacora_flags 
		        		WHERE fecha_insert::DATE = today 
		        		  AND numcategoria = cCategoria 
		        		  AND numconvenio = cConvenio 
       			
    		 UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio
                AND fecha_pago = dFecha_Pago
				AND folio_suc = cFolio
				AND referencia1 = cReferencia1
                AND status_cancelado <> 'S'
                AND flag_confirmacion_sucursal = 0;

        END FOREACH;


		UPDATE bdisac:"informix".sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
    END;
END PROCEDURE;