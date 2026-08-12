CREATE PROCEDURE "informix".sp_generaarchivocobranzatelmex(cId_Convenio CHAR(5))

   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;

    DEFINE cSecuencia               CHAR;
    DEFINE cCveEnvio                CHAR;
    DEFINE cCveRegistro             CHAR;
    DEFINE cCveViaCobro             CHAR(2);
    DEFINE cMes, cDia, cMesE, cDiaE CHAR(2);
    DEFINE cCategoria               CHAR(2);
    DEFINE cStatusConvenio          CHAR(2);
    DEFINE cForma_Pago              CHAR(2);
    DEFINE cConvenio                CHAR(3);
    DEFINE cAnio, cAnioE            CHAR(4);
    DEFINE cCveEmpresa              CHAR(4);
    DEFINE cReferencia1             CHAR(20);
    DEFINE cReferencia2             CHAR(20);
    DEFINE cSucursal                CHAR(13);
    DEFINE cFolioSuc                CHAR(16);
    DEFINE cOficinaComercial        CHAR(3);
    DEFINE cEmpresa                 CHAR(20);
    DEFINE cNomArchTelmex           CHAR(35);
    DEFINE cNomArchTelmexOnln       CHAR(35);
    DEFINE cFiller                  CHAR(100);
    DEFINE cRutaArchTelmex          CHAR(100);
    DEFINE cRutaArchTelmexOnline    CHAR(100);
    DEFINE cStmt                    CHAR(250);

    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE dFecha_Rec               DATE;
    DEFINE dFecha_Pago               DATE;

    DEFINE iCveFormato              INTEGER;
    DEFINE iImporte_Pago            INTEGER;
	DEFINE iImporte_PagoOnline		INTEGER;
    DEFINE iTotalreg                INTEGER;
    DEFINE iTotalregOnline          INTEGER;
    DEFINE iImporteTotal            INTEGER;
    DEFINE iImporteTotalOnline      INTEGER;

    DEFINE cFolio                   CHAR(16);
    DEFINE cFlagCen                 INTEGER;
    DEFINE cFlagSuc                 INTEGER;
    DEFINE iCuantos                 INTEGER;
    DEFINE vTipoProceso             CHAR(1);
    DEFINE vIdPago                  CHAR(12);
    DEFINE cHoraPago                CHAR(8);
	DEFINE cCODdv CHAR(5);
	DEFINE cDV CHAR(2);

    --INICIALIZACION DE VARIABLES--
    LET cCodRet = "00000";
    LET iSqlErr = 0;
    LET cStatusConvenio = '';
    LET cCveEmpresa = '0011';
    LET cOficinaComercial = '';
    LET cCveRegistro = '0';
    LET cEmpresa = 'TELEFONOS DE MEXICO';
    LET cCveEnvio = 2;
    LET cFiller = '';
    LET iCveFormato = 2;
    LET cSecuencia  = '0';
    LET cCategoria  = SUBSTRING(cId_Convenio FROM 1 FOR 2);
    LET cConvenio  = SUBSTRING(cId_Convenio FROM 3 FOR 3);
    LET cReferencia1 = '';
    LET cReferencia2 = '';
    LET cForma_Pago = '';
    LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
    LET iImporte_Pago = 0;
	LET iImporte_PagoOnline = 0;
    LET iTotalReg = 0;
    LET iTotalregOnline = 0;
    LET iImporteTotal = 0;
    LET iImporteTotalOnline = 0;
    LET cFolio = '';                 
    LET cFlagCen = 0;                 
    LET cFlagSuc = 0;      
    LET iCuantos = 0;    
    LET vIdPago = '';
    LET vTipoProceso = '';
    LET cHoraPago = '00:00:00';
	LET cCODdv = '00000';
	LET cDV = '0';

    --SET DEBUG FILE TO "/informix/HMLG/sp_generaarchivocobranzatelmex.out";
    --TRACE ON;

    BEGIN

        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

                UPDATE sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio;
            END IF;
        END EXCEPTION;

        SELECT fecha_hoy INTO dFecha_Hoy FROM bdisac:sac_fechas;

        EXECUTE PROCEDURE sp_CalculaProxFechaHabil(dFecha_Hoy) INTO dFecha_Rec;

        SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        --LET dFechaIni = today -1;------------------------------------------------BORRRAR AL LIBERAR
        --LET dFecha_Hoy = today;------------------------------------------------BORRRAR AL LIBERAR

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');

        LET cDiaE = LPAD(DAY(dFecha_Rec::DATE), 2, '0');
        LET cMesE = LPAD(MONTH(dFecha_Rec::DATE), 2, '0');
        LET cAnioE = LPAD(YEAR(dFecha_Rec::DATE), 4, '0');

        SELECT TRIM(valor)||SUBSTRING(cAnio FROM 3 FOR 2)||cMes||cDia INTO cNomArchTelmex FROM bdisac:sac_param WHERE cod_param = 13;
        SELECT TRIM(valor)||cNomArchTelmex INTO cRutaArchTelmex FROM bdisac:sac_param WHERE cod_param = 3;
        SELECT TRIM(valor) INTO cCveViaCobro FROM bdisac:sac_param WHERE cod_param = 4;

        --NOMBRE ARCHIVO PROCESO ONLINE
        SELECT TRIM(valor) INTO cOficinaComercial FROM bdisac:sac_param WHERE cod_param = 142;
        LET cNomArchTelmexOnln = cOficinaComercial || year(today) || lpad(month(today),2,'0') || lpad(day(today),2,'0') || '.txt';
        SELECT TRIM(valor)||cNomArchTelmexOnln INTO cRutaArchTelmexOnline FROM bdisac:sac_param WHERE cod_param = 3;

        --HEADERS BATCH
        LET cStmt = 'echo "' || cCveRegistro || LPAD(cFiller, 1, ' ')||cAnio || cMes || cDia || cCveEmpresa || RPAD(TRIM(cEmpresa),38,' ') || cCveEnvio || LPAD(cFiller, 65, ' ') || cCveViaCobro || '" > ' || cRutaArchTelmex;
        SYSTEM cStmt;

        --HEADERS ONLINE
        LET cStmt = 'echo "#' || cAnio || '/' || cMes || '/' || cDia || '|' || cOficinaComercial || '" > ' || cRutaArchTelmexOnline;
        SYSTEM cStmt;

        LET cCveRegistro = '1';
        LET cStmt = '';

        --Detail del Archivo
        FOREACH
            SELECT LPAD(id_sucursal, 13, ' ')  as sucursal, folio_suc , TRIM(referencia1) as numtel,
                   TRIM(referencia2) as dv,
				   (CAST(importe_pago AS INTEGER)*100) - (CAST(importe_comision_cte AS INTEGER)*100) as importe, 
				   (CAST(importe_pago AS INTEGER)*100) as importe2,
				   DECODE(forma_pago,1,'01',2, '02',3,'01') AS formapago,
                   LPAD(DAY(fecha_pago::DATE), 2, '0') as diapago, LPAD(MONTH(fecha_pago::DATE), 2, '0') as mespago,
                   LPAD(YEAR(fecha_pago::DATE), 4, '0') as aniopago, flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago, extend(fecha_insert, hour to second)::CHAR(10) hora
            INTO   cSucursal, cFolioSuc, cReferencia1, cReferencia2, iImporte_Pago,iImporte_PagoOnline, cForma_Pago, cDia, cMes, cAnio, cFlagCen, cFlagSuc, cFolio, dFecha_Pago, cHoraPago
            FROM bdisac:sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
            OR flag_confirmacion_sucursal = 1)

            LET vIdPago ="";
			--Valida DV de cReferencia1
			
			IF LENGTH(TRIM(cReferencia2)) > 1 THEN
				
				EXECUTE PROCEDURE "informix".sp_calculadvtelmex(cReferencia1) INTO cCODdv,cDV;
				
				IF cCODdv = '00000' THEN 
					LET cReferencia2 = TRIM(cDV);
				ELSE
					LET cReferencia2 = substr(TRIM(cReferencia1),10,1);
				END IF;
				
			END IF;

            IF cFlagCen = 0 or cFlagSuc =0 THEN
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
						LET iCuantos=0;
              END IF;
            END IF;


            LET vIdPago = (SELECT count(*) FROM sac_pagos_telmex WHERE foliosuc=cFolioSuc and fecha_insert::date=dFecha_Pago);

            IF vIdPago::INTEGER > 0 THEN
            --ONLINE
                LET vIdPago = (SELECT idPago FROM sac_pagos_telmex WHERE foliosuc=cFolioSuc and fecha_insert::date=dFecha_Pago);
                LET vTipoProceso = 'E';
                LET iTotalregOnline = iTotalregOnline + 1;
                LET iImporteTotalOnline = iImporteTotalOnline + iImporte_PagoOnline;

                LET cStmt = 'echo "' || TRIM(cReferencia1) || '|'
                                || cOficinaComercial || '|' 
                                || trim(cSucursal) || '|' 
                                || YEAR(dFecha_Pago) || '/' || lpad(month(dFecha_Pago),2,'0') || '/' || lpad(day(dFecha_Pago),2,'0') || '|'
                                || cHoraPago || '|'
                                || cFolioSuc || '|'
                                || TRIM(vIdPago) || '|'
                                || TRIM(cForma_Pago) || '|'
                                || (iImporte_PagoOnline / 100)::decimal(10,2) || '|'
                                || vTipoProceso || '" >> ' || cRutaArchTelmexOnline;
                SYSTEM cStmt;

            ELSE
            --BATCH
                IF (cForma_Pago='01') THEN
                    LET iImporte_Pago = iImporte_PagoOnline;
                END IF;

                LET iTotalReg = iTotalReg + 1;
                LET iImporteTotal = iImporteTotal + iImporte_Pago / 100;

                LET cStmt = 'echo "' || cCveRegistro ||LPAD(cFiller, 3, ' ')||LPAD(cFiller, 10, ' ')||LPAD(cFiller, 7, ' ')||LPAD(cFiller, 2, ' ')||
                            LPAD(iImporte_Pago, 13, '0') || TRIM(cReferencia1) || cSecuencia || cForma_Pago || LPAD(cFiller, 8, ' ') ||cAnio || cMes || cDia ||
                            cAnioE || cMesE || cDiaE ||LPAD(TRIM(cFolioSuc),17,' ')||cSucursal||TRIM(cReferencia2)||iCveFormato||LPAD(cFiller, 4, ' ')||
                            LPAD(cFiller, 2, ' ')||LPAD(cFiller, 7, ' ')||cCveViaCobro || '" >> ' || cRutaArchTelmex;
                SYSTEM cStmt;

            END IF;

        END FOREACH;
		
		--Busco todos los registros de la tabla sac_bitacora_flags para actualizar en sac_movimientoshistorial
		FOREACH
            SELECT TRIM(referencia) AS referencia, folio_suc, fecha_pago
			INTO   cReferencia1, cFolio, dFecha_Pago
            FROM   bdisac:"informix".sac_bitacora_flags
            WHERE  numcategoria       = cCategoria
			AND    numconvenio        = cConvenio
			AND    fecha_insert::DATE = TODAY
			
			--Actualizo bandera de 0 a 1
			UPDATE bdisac:sac_movimientoshistorial
			SET    flag_confirmacion_sucursal = '1'
			WHERE  numcategoria               = cCategoria
			AND    numconvenio                = cConvenio
			AND    fecha_pago                 = dFecha_Pago
			AND    folio_suc                  = cFolio
			AND    referencia1                = cReferencia1
			AND    status_cancelado           <> 'S'
			AND    flag_confirmacion_sucursal = 0;
			
		END FOREACH;

        -- Trailer del Archivo
        
        --BATCH
        LET cCveRegistro = '9';
        LET cStmt = '';
        LET cStmt = 'echo "' ||cCveRegistro ||LPAD(cFiller, 1, ' ')|| LPAD(iTotalReg, 9, '0')|| LPAD(iImporteTotal * 100, 17, '0')||LPAD(cFiller, 90, ' ') || cCveViaCobro|| '" >> ' || cRutaArchTelmex;
        SYSTEM cStmt;

        --ONLINE
        LET cStmt = '';
        LET cStmt = 'echo "#' || LPAD(iTotalregOnline, 5, '0') || '|' || (iImporteTotalOnline / 100)::decimal(10,2) || '" >> ' || cRutaArchTelmexOnline;

        SYSTEM cStmt;

        UPDATE sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Genera el archivo de cobranza Telmex de acuerdo a Layout ptoporcionado por la misma empresa',
'Sucursales',
'EJECUTADO O LLAMADO POR:',
'sp_genera_ArchivosCobranzaCentral()',
'FECHA : Septiembre de 2008',
'VERSION: 20080930',
'ULTIMA MODIFICACION: 20090428',
'AUTOR MODIFICACION: José Angel López Adams',
'MODIFICACION: Se modifica para que al seleccionar los registros que serán agregados al archivo, se valide que esten confirmados en central y sucursal',
'AUTOR: FRG',
'DESCRIPCION: se agrega condición para considerar registros de cheques que NO estén reversados.',
'FECHA:02/Jun/2014',
'MODIFICACION: 04NOV2021 - NMR',
'DESCRIPCION: se agrega manejo de pagos y generacion de archivo adicional para pagos en linea',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzaeci(cId_Convenio CHAR(5))
   -- DEFINICION DE VARIABLES
   
    DEFINE cCodRet                  CHAR (5);
	DEFINE cCodRet2                 CHAR (5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE cDia                     CHAR (2);
	DEFINE cMes                     CHAR (2);
	DEFINE cAnio                    CHAR (2);
	DEFINE cDiaPag                  CHAR (2);
	DEFINE cMesPag                  CHAR (2);
    DEFINE cAnioPag                 CHAR (4);
    DEFINE cCategoria               CHAR (2);
    DEFINE cConvenio                CHAR (3);
    DEFINE cReferencia1             CHAR (20);
    DEFINE cSucursal                CHAR (4);
    DEFINE cRutaArchEci             CHAR (100);
    DEFINE cStmt                    CHAR (250);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
    DEFINE dFechaEntrega            DATE;
    DEFINE cFechaEntrega            CHAR (8);
    DEFINE iImporte_Pago            INTEGER;
    DEFINE cDisponible              CHAR (1);
	DEFINE cFolio                   CHAR (16);
    DEFINE cFlagCen                 INTEGER;
    DEFINE cFlagSuc                 INTEGER;
	DEFINE iCuantos                 INTEGER;
    DEFINE dFecha_Pago               DATE;  

    --INICIALIZACION DE VARIABLES--
    LET cCodRet       = "00000";
	LET cCodRet2      = "00000";
    LET iSqlErr       = 0;
    LET cCategoria    = SUBSTRING(cId_Convenio FROM 1 FOR 2);
    LET cConvenio     = SUBSTRING(cId_Convenio FROM 3 FOR 3);
    LET cReferencia1  = '';
    LET cDia          = '';
    LET cMes          = '';
    LET cAnio         = '';
	LET cDiaPag       = '';
	LET cMesPag       = '';
	LET cAnioPag      = '';
    LET cDisponible   = '';
    LET cFolio        = '';                 
    LET cFlagCen      = 0;                 
    LET cFlagSuc      = 0;      
	LET cSucursal     = '';
	LET cRutaArchEci  = '';
	LET cStmt         = '';
	LET dFechaIni     = '01-01-1990';
	LET dFecha_Hoy    = '01-01-1990';
	LET dFechaEntrega = '01-01-1990';
	LET cFechaEntrega = '';
	LET iImporte_Pago = 0;
	LET	iCuantos      = 0;
	
    --SET DEBUG FILE TO "/informix/noe/sp_generaarchivocobranzaeci.out";
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
				
		
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchEci
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
     	
		LET cRutaArchEci = REPLACE(cRutaArchEci,'AA',cAnio);
		LET cRutaArchEci = REPLACE(cRutaArchEci,'MM',cMes);
		LET cRutaArchEci = REPLACE(cRutaArchEci,'DD',cDia);
		
        	 
		EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFecha_Hoy) 
		INTO cCodRet2,dFechaEntrega;
		
		IF CAST(cCodRet2 AS INTEGER) = 0 THEN
		
     		LET cFechaEntrega  = SUBSTRING(dFechaEntrega FROM 7 FOR 4) || SUBSTRING(dFechaEntrega FROM 1 FOR 2)
			                    || SUBSTRING(dFechaEntrega FROM 4 FOR 2);
		
		    
			SET ISOLATION TO DIRTY READ;
			
	        FOREACH
	            
				SELECT referencia1, importe_pago * 100, LPAD(id_sucursal,4,'0'), 
				    LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),	LPAD(YEAR(fecha_pago::DATE), 4, '0'),  
				    flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
		        INTO  cReferencia1,  iImporte_Pago, cSucursal, cDiaPag, cMesPag, cAnioPag,  cFlagCen, cFlagSuc, cFolio, dFecha_Pago
	            FROM bdisac:"informix".sac_movimientoshistorial
	            WHERE numcategoria = cCategoria
	            AND numconvenio = cConvenio
	            AND fecha_pago > dFechaIni
	            AND fecha_pago <= dFecha_Hoy
	            AND status_cancelado <> 'S'
	            AND (flag_confirmacion_central = 1
	            OR flag_confirmacion_sucursal = 1)
		
            IF cFlagCen = 0 or cFlagSuc =0 THEN
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
			
	            LET cStmt = 'echo "'|| LPAD(TRIM(cDisponible), 4, ' ')|| LPAD(TRIM(cReferencia1), 10, '0') || LPAD(TRIM(cDisponible), 5, ' ')|| 
				                       LPAD(iImporte_Pago, 9, '0') || LPAD(TRIM(cDisponible), 1, ' ')|| cAnioPag || cMesPag || cDiaPag ||   
							           LPAD(TRIM(cDisponible), 1, ' ') || LPAD(TRIM(cSucursal), 4, '0') ||  LPAD(TRIM(cDisponible), 1, ' ') || 
									   cFechaEntrega ||  LPAD(TRIM(cDisponible), 1, ' ') || SUBSTRING(cFolio FROM 7 FOR 10) || '" >> ' || cRutaArchEci;
	            SYSTEM cStmt;
			END FOREACH;
		
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
	            LET cStmt = 'echo "' || "0"  || '" >> ' || cRutaArchEci;
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
		ELSE
		    LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
			UPDATE bdisac:"informix".sac_controlarchivoscobranza
			SET retorno = cCodRet
			WHERE numcategoria = cCategoria
			AND  numconvenio = cConvenio;
		END IF;
		
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramirez',
'DESCRIPCION: Genera el archivo de cobranza ECI de acuerdo al Layout',
'EJECUTADO O LLAMADO POR:sp_genera_ArchivosCobranzaCentral()',
'FECHA : 07 de Septiembre de 2011',
'VERSION: 20110907',
'AUTOR: FRG',
'DESCRIPCIÓN: se agrega condición para considerar registros de cheques que NO estén reversados.',
'FECHA:02/Jun/2014',
'BD: FRG';

CREATE PROCEDURE "informix".sp_generaarchivocobranzayvesrocher(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cReferencia1			CHAR(17);
DEFINE cRutaArchRocher			CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE cTpoOperacion			CHAR(1);
DEFINE dFechaIni				DATE;
DEFINE dFecha_Hoy				DATE;
DEFINE dFecha_Ant				DATE;
DEFINE iImporte_Comision		DECIMAL(11,0);
DEFINE iSumaImporte_Comision		DECIMAL(11,0);
DEFINE iImp_IVA_Com			DECIMAL(11,0);
DEFINE iSumaImporte_IVA_Comision	DECIMAL(11,0);
DEFINE iImporte_Pago			DECIMAL(14,0);
DEFINE iTotal_Pago			DECIMAL(11,0);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos				INTEGER;
DEFINE cNombrelegalempresa		CHAR(40);
DEFINE cNomes				CHAR(15);
DEFINE cHora				CHAR(2);
DEFINE cMinuto	  			CHAR(2);
DEFINE cSucursal				CHAR(5);
DEFINE dFechaPago				DATE;
DEFINE cHoraRuta				CHAR(2);
DEFINE cMinutoRuta			CHAR(2);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3  FOR 3);
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago				= 0;
LET iImporte_Comision			= 0;
LET iSumaImporte_Comision		= 0;
LET iImp_IVA_Com				= 0;
LET iSumaImporte_IVA_Comision		= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchRocher			= '';
LET	iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET dFecha_Ant				= DATE(1);
LET cTpoOperacion				= 'D';
LET iNumPagos				= 0;
LET cNombrelegalempresa			= '';
LET cNomes					= '';
LET cHora					= '';
LET cMinuto					= '';
LET cSucursal				= '';
LET dFechaPago				= DATE(1);
LET cHoraRuta				= '';
LET cMinutoRuta				= '';

--	SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_generaarchivocobranzayvesrocher.out';
--	TRACE ON;
	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND   numconvenio = cConvenio;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";	
		
		--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		SELECT fecha_ultimo_archivo
		INTO dFechaIni
		FROM "informix".sac_controlarchivoscobranza
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		--ASIGNA VALOR A LAS VARIABLES
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');

		--PONE NOMBRE DEL MES
		IF cMes='12' THEN
			LET cNomes =' DE DICIEMBRE DE ';
		END IF;
		IF cMes='11' THEN
			LET cNomes =' DE NOVIEMBRE DE ';
		END IF;
		IF cMes='10' THEN
			LET cNomes =' DE OCTUBRE DE ';
		END IF;
		IF cMes='09' THEN
			LET cNomes =' DE SEPTIEMBRE DE ';
		END IF;
		IF cMes='08' THEN
			LET cNomes =' DE AGOSTO DE ';
		END IF;
		IF cMes='07' THEN
			LET cNomes =' DE JULIO DE ';
		END IF;
		IF cMes='06' THEN
			LET cNomes =' DE JUNIO DE ';
		END IF;
		IF cMes='05' THEN
			LET cNomes =' DE MAYO DE ';
		END IF;
		IF cMes='04' THEN
			LET cNomes =' DE ABRIL DE ';
		END IF;
		IF cMes='03' THEN
			LET cNomes =' DE MARZO DE ';
		END IF;
		IF cMes='02' THEN
			LET cNomes =' DE FEBRERO DE ';
		END IF;
		IF cMes='01' THEN
			LET cNomes =' DE ENERO DE ';
		END IF;

		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza),nomlegalempresa
		INTO cRutaArchRocher,cNombrelegalempresa
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		SELECT LPAD(SUBSTR(DBINFO('utc_to_datetime', sh_curtime),12,2),2,'0'), LPAD(SUBSTR(DBINFO('utc_to_datetime', sh_curtime),15,2),2,'0')
		INTO cHoraRuta,cMinutoRuta
		FROM sysmaster:"informix".sysshmvals;
		
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'mm',cMinutoRuta);
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'hh',cHoraRuta);
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'YYYY',cAnio);
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'MM',cMes);
		LET cRutaArchRocher = REPLACE(cRutaArchRocher,'DD',cDia);

		--IMPRIME EL ENCABEZADO DEL ARCHIVO
		LET cStmt='echo "' || cNombrelegalempresa || '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
		LET cStmt='echo "' || 'FECHA: ' ||cDia||" "||TRIM(cNomes)||" "||cAnio|| '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;

		FOREACH

			SELECT fecha_pago,
				LPAD(DAY(fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				LPAD(SUBSTR(fecha_insert,12,2),2,'0'),
				LPAD(SUBSTR(fecha_insert,15,2),2,'0'),
				id_sucursal,
				folio_suc,
				referencia1,
				importe_pago*100,
				importe_comision_convenio * 100,
				iva_comision_convenio * 100,
				flag_confirmacion_central,
				flag_confirmacion_sucursal
				INTO   dFechaPago,cDiaPago,cMesPago,cAnioPago,cHora,cMinuto,cSucursal,cFolio,cReferencia1,iImporte_Pago,iImporte_Comision,iImp_IVA_Com,iFlagCen,iFlagSuc
				FROM "informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)

				--ACTUALIZACION DE FLAG_CONFIRMACION_SUCURSAL = 1 EN CASO DE QUE NO SE HAYA CONFIRMADO EN SUCURSAL POR ALGUN MOTIVO
				IF iFlagCen = 0 OR iFlagSuc = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
					IF iCuantos = 0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S' AND  fech_alt = dFechaPago;
						IF iCuantos = 0 THEN
							CONTINUE FOREACH;
						END IF;
					END IF;
				END IF;

				IF iCuantos > 0 THEN
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
					LET iCuantos = 0;
				END IF;

				LET iSumaImporte_Comision = iSumaImporte_Comision + iImporte_Comision;
				LET iSumaImporte_IVA_Comision = iSumaImporte_IVA_Comision + iImp_IVA_Com;
				LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
				LET iNumPagos = iNumPagos + 1;

				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || cHora || cMinuto || LPAD(TRIM(cSucursal), 5, '0')|| LPAD(cFolio, 16, '0') || LPAD(TRIM(cReferencia1), 17, '0') || LPAD(iImporte_Pago, 14, '0') || '" >> ' || cRutaArchRocher;
				SYSTEM cStmt;
		END FOREACH;

		LET cReferencia1 = '';
		LET cFolio       = '';
		LET cHora		 = '';
		LET cMinuto		 = '';
		LET cSucursal	 = '';

		--IMPRIME EL RENGLON COMISIONES
		IF iSumaImporte_Comision <> 0 THEN
			LET cTpoOperacion = 'C';
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago ||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0') ||LPAD(TRIM(cSucursal), 5, '0') ||LPAD(TRIM(cFolio), 16, '0') || LPAD(TRIM(cReferencia1), 17, '0') || LPAD(iSumaImporte_Comision, 14, '0') || '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
		END IF;

		--IMPRIME EL RENGLON DEL IVA
		IF iSumaImporte_IVA_Comision <> 0 THEN
			LET cTpoOperacion = 'I';
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago ||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0') ||LPAD(TRIM(cSucursal), 5, '0')||LPAD(TRIM(cFolio), 16, '0') || LPAD(TRIM(cReferencia1), 17, '0') || LPAD(iSumaImporte_IVA_Comision, 14, '0') || '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
		END IF;

		--IMPRIME EL RENGLON DE TOTAL
		IF iNumPagos <> 0 THEN
			LET cTpoOperacion = 'T';
			LET iTotal_Pago = ((iTotal_Pago - iSumaImporte_Comision) - iSumaImporte_IVA_Comision);

			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago ||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0')||LPAD(TRIM(cSucursal), 5, '0')||LPAD(TRIM(cFolio), 16, '0') || LPAD(TRIM(TO_CHAR(iNumPagos)), 15, '0')  ||LPAD(iTotal_Pago, 14, '0')|| '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
		END IF;

		--SI NO SE ENCONTRARON REGISTROS SE IMPRIME TOTAL EN CEROS
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cTpoOperacion = 'T';
			LET cStmt = 'echo "' || cTpoOperacion || LPAD(TRIM(cDia),2,'0') || LPAD(TRIM(cMes),2,'0') || LPAD(TRIM(cAnio),4,'0') ||LPAD(TRIM(cHora), 2, '0') ||LPAD(TRIM(cMinuto), 2, '0')||LPAD(TRIM(cSucursal), 5, '0')||LPAD(TRIM(cFolio), 16, '0')||LPAD(TRIM(cReferencia1), 17, '0') || LPAD(iTotal_Pago, 14, '0') || '" >> ' || cRutaArchRocher;
			SYSTEM cStmt;
		END IF;
		
		--Busco todos los registros de la tabla sac_bitacora_flags para actualizar en sac_movimientoshistorial
		FOREACH
			SELECT TRIM(referencia) AS referencia, folio_suc, fecha_pago
			INTO   cReferencia1, cFolio, dFechaPago
			FROM   bdisac:"informix".sac_bitacora_flags
			WHERE  numcategoria       = cCategoria
			AND    numconvenio        = cConvenio
			AND    fecha_insert::DATE = TODAY
			
			--Actualizo bandera de 0 a 1
			UPDATE bdisac:sac_movimientoshistorial
			SET    flag_confirmacion_sucursal = '1'
			WHERE  numcategoria               = cCategoria
			AND    numconvenio                = cConvenio
			AND    fecha_pago                 = dFechaPago
			AND    folio_suc                  = cFolio
			AND    referencia1                = cReferencia1
			AND    status_cancelado           <> 'S'
			AND    flag_confirmacion_sucursal = 0;
			
		END FOREACH;

		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: Vazquez Herrera Hugo Guadalupe',
'DESCRIPCIÓN: SP que genera un archivo .txt donde se guardan las operacines de pagos rocher.',
'FOLIO:1454',
'FECHA:12/08/2014',
'VERSIÓN: ',
'BASE DE DATOS: bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzacardif(pId_convenio CHAR(5))
	
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr			INTEGER;
	DEFINE cCategoria		CHAR(2);
	DEFINE cConvenio		CHAR(3);
	DEFINE dFechaIni		DATE;
	DEFINE dFecha_Hoy		DATE;
	DEFINE cRutaArch		CHAR(100);
	DEFINE cNomArch			CHAR(30);
	DEFINE cMes				CHAR(2);
	DEFINE cDia				CHAR(2);
	DEFINE cAnio			CHAR(4);
	DEFINE cStmt			CHAR(250);
	
	
	DEFINE cNumPoliza		CHAR(50);
	DEFINE cTipoPlan		CHAR(1);
	DEFINE dFechaAlta		DATE;
	DEFINE dFechaVenc 		DATE;
	DEFINE dFechaInsert		DATE;
	DEFINE cMontoPagado		CHAR(100);
	DEFINE pEmpresa			CHAR(3);
	DEFINE cEstatusConvenio CHAR(1);
	DEFINE cStatus_cancelado CHAR(1);
	DEFINE cFolioSuc 		CHAR (16);
	DEFINE vContador 		INTEGER;
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_generaarchivocobranzacardif.out';
	--TRACE ON;
	
	LET cCodRet				= '00000';
	LET cCategoria			= SUBSTRING(pId_convenio FROM 1 FOR 2);
	LET cConvenio 			= SUBSTRING(pId_convenio FROM 3 FOR 3);
	LET cRutaArch 			= '';
	LET cNomArch 			= '';
	LET cMes 				= '';
	LET cDia 				= '';
	LET cAnio 				= '';
	LET cStmt				= '';
	
	LET cNumPoliza			= '';
	LET cTipoPlan			= '';
	LET cMontoPagado		= '';
	LET cStatus_cancelado   = '';
	LET cFolioSuc			= '';
	LET pEmpresa 			= '001';
	LET vContador 			= 0;
	
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
		
		SELECT statusconvenio
		INTO cEstatusConvenio
		FROM sac_convenios 
		WHERE numcategoria = cCategoria 
		AND numconvenio = cConvenio;
		
		IF cEstatusConvenio = 'A' THEN
		
			SELECT fecha_hoy
			INTO dFecha_Hoy
			FROM bdisac:"informix".sac_fechas
			WHERE empresa = pEmpresa;

			SELECT fecha_ultimo_archivo
			INTO dFechaIni
			FROM bdisac:"informix".sac_controlarchivoscobranza
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio;

			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = YEAR(dFecha_Hoy );
			
			SELECT TRIM(ruta_archivo_cobranza), TRIM(nombre_archivo_cobranza)
			INTO cRutaArch, cNomArch
			FROM bdisac:"informix".sac_convenios
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio;
			
			LET cNomArch = REPLACE(cNomArch,'AAAA',cAnio);
			LET cNomArch = REPLACE(cNomArch,'MM',cMes);
			LET cNomArch = REPLACE(cNomArch,'DD',cDia);
			
			LET cNomArch = TRIM(cNomArch) || '.txt';
			
			LET cRutaArch = TRIM(cRutaArch) || TRIM(cNomArch);
			
			Drop table if exists sac_movimientoshistorial_TMP09023;
			LET cStmt = 'rm -rf ' || cRutaArch || '/' || cNomArch;
			SYSTEM cStmt;
			
			SELECT * FROM bdisac:"informix".sac_movimientoshistorial
				WHERE fecha_pago = dFecha_Hoy
				AND numcategoria = cCategoria AND numconvenio = cConvenio
				INTO TEMP sac_movimientoshistorial_TMP09023  WITH NO LOG;
			
			FOREACH
				
				/*
				SELECT num_poliza, tipo_plan, fecha_alta, fecha_vencimiento, fecha_insert 
				INTO cNumPoliza, cTipoPlan, dFechaAlta, dFechaVenc, dFechaInsert 
				FROM bdisac:"informix".sac_cardif_migrante
				WHERE fecha_insert = dFecha_Hoy AND estatus = '1' AND NVL(folio_suc,"") <> "" --estatus=1 (Activo)
				*/
				
				
				SELECT a.num_poliza, a.tipo_plan, a.fecha_alta, a.fecha_vencimiento, a.fecha_insert ,b.status_cancelado,a.folio_suc
				INTO cNumPoliza, cTipoPlan, dFechaAlta, dFechaVenc, dFechaInsert, cStatus_cancelado, cFolioSuc
				FROM bdisac:"informix".sac_cardif_migrante a
                LEFT JOIN sac_movimientoshistorial_TMP09023 b on a.folio_suc = b.folio_suc
				WHERE a.fecha_insert::date = dFecha_Hoy  AND a.estatus = '1' AND NVL(a.folio_suc,"") <> "" 

				LET cMontoPagado = '';
				
				IF cTipoPlan = '4' THEN --Anual
					SELECT valor 
					INTO cMontoPagado
					FROM bdisac:"informix".sac_param 
					WHERE cod_param = '126';				
				ELIF cTipoPlan = '5' THEN --Semestral
					SELECT valor 
					INTO cMontoPagado
					FROM bdisac:"informix".sac_param 
					WHERE cod_param = '127';
                ELIF cTipoPlan = '6' THEN --Anual Paisano
					SELECT valor 
					INTO cMontoPagado
					FROM bdisac:"informix".sac_param 
					WHERE cod_param = '155';
                ELIF cTipoPlan = '7' THEN --Semestral Paisano
					SELECT valor 
					INTO cMontoPagado
					FROM bdisac:"informix".sac_param 
					WHERE cod_param = '156';
				END IF;
				
				
				IF  cStatus_cancelado = 'S' THEN 

					UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 5, observ_siniestro = 'Cambio estatus 1 a 5 x Estado de Cuenta'
					WHERE num_poliza = cNumPoliza
					AND folio_suc = cFolioSuc
					AND tipo_plan = cTipoPlan;

				ELSE
					--IMPRIME RENGLON DE LAS OPERACIONES
					LET cStmt = 'echo "' || RPAD(trim(cNumPoliza), 35) || '|' || RPAD(trim(cTipoPlan), 3) || '|' || dFechaAlta || '|' || dFechaVenc || '|' || dFechaInsert  || '|' || RPAD(trim(cMontoPagado), 20) ||  '" >> ' || cRutaArch;
					SYSTEM cStmt;
				END IF;
				
				
				LET vContador = vContador + 1;
				
			END FOREACH;
			
			IF vContador = 0 THEN
				--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
				LET cStmt = 'echo "' || '" >> ' || cRutaArch;
				SYSTEM cStmt;
			END IF;
			
			UPDATE "informix".sac_controlarchivoscobranza
			SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio;
			
			Drop table if exists sac_movimientoshistorial_TMP09023;

		END IF;
	END;
END PROCEDURE;