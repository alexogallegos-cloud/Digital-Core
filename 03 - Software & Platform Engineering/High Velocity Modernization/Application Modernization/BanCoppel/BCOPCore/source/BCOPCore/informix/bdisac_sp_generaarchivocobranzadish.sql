CREATE PROCEDURE "informix".sp_generaarchivocobranzadish(cId_Convenio CHAR(5))
   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;

    DEFINE cCveRegistro             CHAR;
    DEFINE cMes, cDia               CHAR(2);
    DEFINE cMesPag, cDiaPag         CHAR(2);
    DEFINE cAnioPag                 CHAR(4);
    DEFINE cCategoria               CHAR(2);
    DEFINE cConvenio                CHAR(3);
    DEFINE cAnio                    CHAR(4);
    ------------------------------------------------------------------------------------
    --	2010-12-28: A peticiÃ?Â³n de MVS, se atualiza el Nombreempresa de DSH a BANCOPPEL -
    --	DEFINE cCveEmpresa              CHAR(3);                                       -
    DEFINE cCveEmpresa              CHAR(9);                                           
    ------------------------------------------------------------------------------------
    DEFINE cReferencia1             CHAR(20);
    DEFINE cSucursal                CHAR(5);
    DEFINE cRutaArchdish            CHAR(100);
    DEFINE cRutaArchdish2           CHAR(100);
    DEFINE cStmt                    CHAR(250);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE dFecha_Pago               DATE;
	
    DEFINE iImporte_Pago            INTEGER;
    DEFINE iTotalreg                INTEGER;
    DEFINE iImporteTotal            INTEGER;
    DEFINE iIdTransacc              INTEGER;
    DEFINE mImporteTotal            MONEY(16,2);
	
    DEFINE cFormaPago               CHAR(2);
    DEFINE cHorMinSec               DATETIME  HOUR TO FRACTION;
    DEFINE cConstante               INTEGER;
		
    DEFINE cFolio                   CHAR(16);
    DEFINE cFlagCen                 INTEGER;
    DEFINE cFlagSuc                 INTEGER;
    DEFINE iCuantos                 INTEGER;
    DEFINE iStatusCancelado         CHAR(1);
    DEFINE iLinea                   INTEGER;

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET cCveEmpresa = '';
    LET cCveRegistro = 'H';
    LET cCategoria  = SUBSTRING(cId_Convenio FROM 1 FOR 2);
    LET cConvenio  = SUBSTRING(cId_Convenio FROM 3 FOR 3);
    LET cReferencia1 = '';
    LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
    LET iImporte_Pago = 0;
    LET iTotalReg = 0;
    LET iImporteTotal = 0;
    LET iIdTransacc = 0;
    LET mImporteTotal = 0;
    LET cConstante = '0';
    LET cFolio = '';                 
    LET cFlagCen = 0;                 
    LET cFlagSuc = 0;      
    LET iCuantos = 0;    	
    LET iStatusCancelado = '';
    LET iLinea   = 0;
    LET cRutaArchdish2 = '';
	
    --SET DEBUG FILE TO "/informix/EPG/sp_generaarchivocobranzadish.out";
    --TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

                UPDATE {+INDEX (bdisac:sac_controlarchivoscobranza 104_10)} sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_Hoy FROM bdisac:sac_fechas;

        SELECT {+INDEX (bdisac:sac_controlarchivoscobranza 104_10)} fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
				
		--SELECT {+INDEX (bdisac:sac_convenios 103_4)} TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
        SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchdish
		FROM bdisac:sac_convenios
		--WHERE TRIM(numcategoria)|| TRIM(numconvenio) = cId_Convenio;
        WHERE numcategoria = cCategoria AND numconvenio = cConvenio;

        LET cRutaArchdish2 = cRutaArchdish;
 
        SELECT {+INDEX (bdisac:sac_param idxsc_par)} TRIM(valor)
		INTO cCveEmpresa
		FROM bdisac:sac_param 
		WHERE SUBSTRING(cod_param FROM 1 FOR 1) = '1' 
		AND SUBSTRING (cod_param FROM 2 FOR 5)  = cId_Convenio;
		
		LET cRutaArchdish = REPLACE(cRutaArchdish,'YYYY',cAnio);
		LET cRutaArchdish = REPLACE(cRutaArchdish,'MM',cMEs);
		LET cRutaArchdish = REPLACE(cRutaArchdish,'DD',cDia);

        LET cRutaArchdish2 = REPLACE(cRutaArchdish2,'YYYY',cAnio || '_1');
		LET cRutaArchdish2 = REPLACE(cRutaArchdish2,'MM',cMEs);
		LET cRutaArchdish2 = REPLACE(cRutaArchdish2,'DD',cDia);

		--Encabezado  en linea
        LET cStmt = 'echo "' || cCveRegistro || cDia || cMes || cAnio || cCveEmpresa ||'" > ' || cRutaArchdish;
        SYSTEM cStmt;

       --Encabezado  en batch
        LET cStmt = 'echo "' || cCveRegistro || cDia || cMes || cAnio || cCveEmpresa ||'" > ' || cRutaArchdish2;
        SYSTEM cStmt;

        LET cCveRegistro = '0';
        LET cStmt = '';

        --Detalle
        SET ISOLATION TO DIRTY READ;
        FOREACH ---EN LINEA
            SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1, importe_pago * 100, LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),	LPAD(YEAR(fecha_pago::DATE), 4, '0'),  
			NVL(LPAD(id_sucursal,5,'0'),'00000'), forma_pago , fecha_insert::datetime HOUR TO SECOND,
            flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago, status_cancelado
	        INTO   cReferencia1,  iImporte_Pago, cDiaPag, cMesPag, cAnioPag,  cSucursal, cFormaPago, cHorMinSec, cFlagCen, cFlagSuc, cFolio, dFecha_Pago, iStatusCancelado
            FROM bdisac:sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy

            SELECT COUNT(*) INTO iLinea
            FROM bdisac:sac_msw_respuesta
            WHERE fecha_pago > dFechaIni 
            AND fecha_pago <= dFecha_Hoy 
            AND numcategoria = '06'and numconvenio = '002'
            AND folio_suc = cFolio	AND num_trama = '2';
 
            IF iLinea > 0 THEN
 
            IF TRIM(cFormaPago) = '1' THEN
                LET cFormaPago = 'EF';
			ELIF TRIM(cFormaPago) = '2' THEN	
			    LET cFormaPago = 'CA';
            ELIF TRIM(cFormaPago) = '3' THEN	
			    LET cFormaPago = 'MX';
            END IF;

            LET iTotalReg = iTotalReg + 1;            

            IF iStatusCancelado = 'N' THEN
                LET mImporteTotal = mImporteTotal + iImporte_Pago / 100;
            END IF;

            LET cStmt = 'echo "' || cCveRegistro || cConstante || LPAD(trim(cReferencia1), 14, ' ') || LPAD(iImporte_Pago, 6, '0') || cDiaPag || cMesPag || cAnioPag ||  
						 cSucursal || SUBSTRING(cHorMinSec  FROM 1 FOR 2) || SUBSTRING(cHorMinSec  FROM 4 FOR 2) || SUBSTRING(cHorMinSec  FROM 7 FOR 2) || cFormaPago || iStatusCancelado || '" >> ' || cRutaArchdish;
            SYSTEM cStmt;

            END IF;

        END FOREACH;

        LET iImporteTotal = mImporteTotal * 100;

        -- Sumario
        LET cCveRegistro = 'T';
        LET cStmt = '';

        LET cStmt = 'echo "' || cCveRegistro || cDia || cMes || cAnio || LPAD(iTotalReg, 6, '0') || LPAD(iImporteTotal, 11, '0') || '" >> ' || cRutaArchdish;
        SYSTEM cStmt;

        LET iImporte_Pago = 0;
        LET iTotalReg = 0;
        LET iImporteTotal = 0;
        LET iIdTransacc = 0;
        LET mImporteTotal = 0;
        LET cFolio = '';                 
        LET cFlagCen = 0;                 
        LET cFlagSuc = 0;      
        LET iCuantos = 0;    	
        LET iStatusCancelado = '';
        LET iLinea = 0;
        LET cCveRegistro = '0';
        LET cStmt = '';

        FOREACH ---EN BATCH
          
           SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1, importe_pago * 100, LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),	LPAD(YEAR(fecha_pago::DATE), 4, '0'),  
			NVL(LPAD(id_sucursal,5,'0'),'00000'), forma_pago , fecha_insert::datetime HOUR TO SECOND,
            flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago, status_cancelado
	        INTO   cReferencia1,  iImporte_Pago, cDiaPag, cMesPag, cAnioPag,  cSucursal, cFormaPago, cHorMinSec, cFlagCen, cFlagSuc, cFolio, dFecha_Pago, iStatusCancelado
            FROM bdisac:sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy

            SELECT COUNT(*) INTO iLinea
            FROM bdisac:sac_msw_respuesta
            WHERE fecha_pago > dFechaIni 
            AND fecha_pago <= dFecha_Hoy 
            AND numcategoria = '06'and numconvenio = '002'
            AND folio_suc = cFolio	AND num_trama = '2';
 
            IF iLinea = 0 THEN
                IF TRIM(cFormaPago) = '1' THEN
                    LET cFormaPago = 'EF';
                ELIF TRIM(cFormaPago) = '2' THEN	
                    LET cFormaPago = 'CA';
                ELIF TRIM(cFormaPago) = '3' THEN	
                    LET cFormaPago = 'MX';
                END IF;

                LET iTotalReg = iTotalReg + 1;            

                IF iStatusCancelado = 'N' THEN
                    LET mImporteTotal = mImporteTotal + iImporte_Pago / 100;
                END IF;

                LET cStmt = 'echo "' || cCveRegistro || cConstante || LPAD(trim(cReferencia1), 14, ' ') || LPAD(iImporte_Pago, 6, '0') || cDiaPag || cMesPag || cAnioPag ||  
                             cSucursal || SUBSTRING(cHorMinSec  FROM 1 FOR 2) || SUBSTRING(cHorMinSec  FROM 4 FOR 2) || SUBSTRING(cHorMinSec  FROM 7 FOR 2) || cFormaPago || iStatusCancelado || '" >> ' || cRutaArchdish2;
                SYSTEM cStmt;
            END IF;

        END FOREACH;

        LET iImporteTotal = mImporteTotal * 100;

        -- Sumario
        LET cCveRegistro = 'T';
        LET cStmt = '';

        LET cStmt = 'echo "' || cCveRegistro || cDia || cMes || cAnio || LPAD(iTotalReg, 6, '0') || LPAD(iImporteTotal, 11, '0') || '" >> ' || cRutaArchdish2;
        SYSTEM cStmt;


        UPDATE {+INDEX (bdisac:sac_controlarchivoscobranza 104_10)} sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramirez',
'DESCRIPCION: Genera el archivo de cobranza dish de acuerdo al Layout',
'EJECUTADO O LLAMADO POR:sp_genera_ArchivosCobranzaCentral()',
'FECHA : 06 de Septiembre de 2010',
'VERSION: 20100906',
'AUTOR: FRG',
'DESCRIPCIÃ?Â?N: se agrega condiciÃ?Â³n para considerar registros de cheques que NO estÃ?Â¡n reversados.',
'FECHA:02/Jun/2014',
'AUTOR: MARIO ENRIQUEZ',
'DESCRIPCIÃ?Â?N: Se agregan todos los pagos sea el status, Dish Online',
'FECHA:28/Nov/2019',
'BD    : bdisac';

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