CREATE PROCEDURE "informix".sp_generaarchivocobranzagdf(pConvenio CHAR(5))
   
   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
	DEFINE iSqlErr                  INTEGER;
	DEFINE iImporte_Pago            INTEGER;
	DEFINE iNumBanco 				INTEGER;
	DEFINE iTotal_Pago              INTEGER;
    DEFINE iFlagCen                 INTEGER;
    DEFINE iFlagSuc                 INTEGER;
	DEFINE iCuantos                 INTEGER;
	DEFINE iNumPagos                INTEGER;
    DEFINE iTransac                 INTEGER;
	DEFINE iMonto_tot               INTEGER;
    DEFINE cDia                     CHAR(2);
	DEFINE cMes                     CHAR(2);
	DEFINE cAnio                    CHAR(2);
	DEFINE cAnio2                   CHAR(4);
    DEFINE cDiaPago                 CHAR(2);
	DEFINE cMesPago                 CHAR(2);
    DEFINE cAnioPago                CHAR(4);
	DEFINE cDiaPago2                CHAR(2);
	DEFINE cMesPago2                CHAR(2);
    DEFINE cAnioPago2               CHAR(4);
    DEFINE cCategoria               CHAR(2);
    DEFINE cConvenio                CHAR(3);                                              
    DEFINE cReferencia1             CHAR(20);
    DEFINE cRutaArchGDF             CHAR(100);
    DEFINE cStmt                    CHAR(250);
    DEFINE cFolio                   CHAR(16);
	DEFINE cTpoOperacion            CHAR(1);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
	DEFINE dFechaPago               DATE;
	DEFINE dFechaPago2              DATE;
    DEFINE cValor					CHAR(100);
	DEFINE cCuenta_Prestadora       CHAR(20);
	DEFINE cPassword                CHAR(32);
	DEFINE cUsuario                 CHAR(10);
	DEFINE cNombreBanco             CHAR(60);
	DEFINE cFuturo                  CHAR(47);
	DEFINE cSucursal                CHAR(4);
	DEFINE cFormaPago				CHAR(2);
	DEFINE mMonto_tot               MONEY(12,2);

    --INICIALIZACION DE VARIABLES--
    LET cCodRet       		  = "00000";
    LET iSqlErr       		  = 0;
    LET cCategoria    		  = SUBSTRING(pConvenio FROM 1 FOR 2);
    LET cConvenio     		  = SUBSTRING(pConvenio FROM 3 FOR 3);
    LET cReferencia1  		  = '';
    LET cDia          		  = '';
    LET cMes          		  = '';
    LET cAnio         		  = '';
	LET cAnio2         		  = '';
	LET cDiaPago       		  = '';
	LET cMesPago       		  = '';
    LET cAnioPago      		  = '';
    LET iImporte_Pago 		  = 0;
	LET iTotal_Pago  		  = 0;
    LET cFolio        		  = '';                 
    LET iFlagCen      		  = 0;                 
    LET iFlagSuc      		  = 0; 
	LET cRutaArchGDF  		  = '';
	LET	iCuantos      		  = 0;
	LET cStmt         		  = '';
	LET dFechaIni     		  = DATE(1);
	LET dFecha_Hoy    		  = DATE(1);
	LET dFechaPago            = DATE(1);
	LET dFechaPago2           = DATE(1);
	LET cTpoOperacion         = 'H';  
	LET iNumPagos             = 0;
	LET iTransac		      = 0;
	LET cValor				  = '';
	LET cCuenta_Prestadora    = '';
	LET mMonto_tot            = 0;
	LET iMonto_tot            = 0;
	LET cPassword             = '';
	LET cUsuario              = '';
	LET iNumBanco             = 137;
	LET cNombreBanco          = '';
	LET cFuturo               = '';
	LET cSucursal			  = '';
	LET cFormaPago            = '';
	LET cStmt 				  = '';
	LET cDiaPago2       	  = '';
	LET cMesPago2       	  = '';
    LET cAnioPago2      	  = '';
	
		--SET DEBUG FILE TO '/informix/ELM/sp_generaarchivocobranzagdf.out';
		--TRACE ON;

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

        SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM "informix".sac_fechas
		WHERE empresa = "001";

        
		SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM "informix".sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		LET cAnio2 = YEAR(dFecha_Hoy ::DATE); 
				
				-- Consulta NÃºmero y Descripcion del Banco:
--	20130408 - FRG.I
--	Se omite la consulta a la tabla bdisac:sac_catbancosgdf para no crear un catÃ¡logo nuevo:
/*
		SELECT numero, descripcion 
		  INTO iNumBanco,cNombreBanco
		  FROM "informix".sac_catbancosgdf
		 WHERE numero = 137;
*/		

		 SELECT valor
			INTO cNombreBanco
			FROM bdisac:sac_param
			where cod_param = '87030';

--	20130408 - FRG.F		 
		LET cNombreBanco = cNombreBanco[1,30];		
		
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza),cuenta_prestadora
		INTO cRutaArchGDF,cCuenta_Prestadora
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
		
		LET cRutaArchGDF = REPLACE(cRutaArchGDF,'BBB',LPAD(iNumBanco,3,'0'));
		LET cRutaArchGDF = REPLACE(cRutaArchGDF,'AA',cAnio);
		LET cRutaArchGDF = REPLACE(cRutaArchGDF,'MM',cMes);
		LET cRutaArchGDF = REPLACE(cRutaArchGDF,'DD',cDia);
		LET cRutaArchGDF = REPLACE(cRutaArchGDF,'CC','01');

		-- Consulta de la TransacciÃ³n del Servicio
		LET iTransac = 6015;
		
		SELECT valor 
		  INTO cValor
		  FROM "informix".sac_param 
		 WHERE empresa = '001'
		   AND cod_param  = iTransac;

		--Consulta del IDE
		SELECT monto_tot
		  INTO mMonto_tot
		  FROM bdicheq:"informix".sc_movhis
		 WHERE empresa = '001'
		   AND fech_alt = dFecha_Hoy
		   AND transacc =  cValor
		   AND cuenta = cCuenta_Prestadora;
		
		LET iMonto_tot = mMonto_tot;
		LET iMonto_tot = iMonto_tot * 100;
		
		  --Consultar Usuario
		 SELECT TRIM(valor)
		  INTO cUsuario
		  FROM "informix".sac_param 
		 WHERE empresa = '001'
		   AND cod_param  = 87031;
		   
		-- Consulta del Password
		SELECT TRIM(valor)
		  INTO cPassword
		  FROM "informix".sac_param 
		 WHERE empresa = '001'
		   AND cod_param  = 87032;
		 
		
        SET ISOLATION TO DIRTY READ;
		
		LET cStmt = 'echo "' || cTpoOperacion || LPAD(cNombreBanco,30,'*') || cAnio2 || cMEs|| cDia || LPAD(iNumBanco, 3, '0') || LPAD(cFuturo,29,'*') ||'" >> ' || cRutaArchGDF;
		SYSTEM cStmt;
		
		LET cTpoOperacion = 'D';
		
        FOREACH
            
            SELECT fecha_pago,
				   referencia1,
				   importe_pago * 100,
			       flag_confirmacion_central, 
				   flag_confirmacion_sucursal, 
				   folio_suc,
					case when id_sucursal IN ('5003','5008','5011') THEN DECODE(forma_pago,'1','23','2','23','5','23')
							else DECODE(forma_pago,'1','01','2','01','5','01')
							end as forma_pagoA,
				   id_sucursal				   
	        INTO  dFechaPago,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc,cFolio,cFormaPago,cSucursal
            FROM "informix".sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
 
			IF iFlagCen = 0 OR iFlagSuc = 0 THEN 
				SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
				IF iCuantos = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
              IF iCuantos > 0 THEN            
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
					LET iCuantos = 0;					
              END IF;
	        END IF;

			LET dFechaPago2 =  dFechaPago + 1;
			
			LET cDiaPago 	= LPAD(DAY(dFechaPago::DATE), 2, '0');
			LET cMesPago 	= LPAD(MONTH(dFechaPago::DATE), 2, '0');
			LET cAnioPago 	= SUBSTRING(YEAR(dFechaPago ::DATE) FROM 1 FOR 4); 
			
			LET cDiaPago2 	= LPAD(DAY(dFechaPago2::DATE), 2, '0');
			LET cMesPago2 	= LPAD(MONTH(dFechaPago2::DATE), 2, '0');
			LET cAnioPago2 	= SUBSTRING(YEAR(dFechaPago2 ::DATE) FROM 1 FOR 4);
		
			LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;			
			LET iNumPagos 	= iNumPagos + 1;
			
            LET cStmt = 'echo "' || cTpoOperacion || LPAD(TRIM(cSucursal),5,'0') || cFolio[1,12] || TRIM(cReferencia1) || TRIM (cAnioPago) || TRIM(cMesPago) || TRIM(cDiaPago) || LPAD(iImporte_Pago,15,'0') || TRIM (cAnioPago) || TRIM(cMesPago) || TRIM(cDiaPago) || TRIM (cFormaPago) ||  '" >> ' || cRutaArchGDF;
            SYSTEM cStmt;
			
        END FOREACH;

		IF iNumPagos <> 0 THEN
			LET cTpoOperacion = 'T';		
			
			LET cStmt = 'echo "' || cTpoOperacion || LPAD(iNumPagos,6,'0') || LPAD(iTotal_Pago,17,'0') || LPAD(cFuturo,47,'*')|| '" >> ' || cRutaArchGDF;
			SYSTEM cStmt;
		END IF;


--ACTUALIZA BANDERA CONFIRMACION SUCURSAL
        FOREACH SELECT referencia, folio_suc, fecha_pago 
		        		INTO  cReferencia1, cFolio, dFechaPago
		        		FROM "informix".sac_bitacora_flags 
		        		WHERE fecha_insert::DATE = today 
		        		  AND numcategoria = cCategoria 
		        		  AND numconvenio = cConvenio 
       			
    		 UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio
                AND fecha_pago = dFechaPago
				AND folio_suc = cFolio
				AND referencia1 = cReferencia1
                AND status_cancelado <> 'S'
                AND flag_confirmacion_sucursal = 0;

        END FOREACH;
        

		UPDATE "informix".sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END;
END PROCEDURE
DOCUMENT
'AUTOR : MartÃ­n Eduardo Miranda',
'DESCRIPCION: Genera el archivo de cobranza PGDF de acuerdo al Layout',
'EJECUTADO O LLAMADO POR:sp_genera_ArchivosCobranzaCentral()',
'FECHA : 12 de Diciembre 2012',
'VERSION: 20121212',
'MODIFICÃ MartÃ­n Eduardo Miranda',
'DESCRIPCION: Se modifica Procedimiento Almacenado  para reemplazar en el nombre del Archivo de cobranda "BBB" por el NÃºmero  ',
'            del Banco Origen del Cobro del Impuesto, asÃ­ como tambien reemplazar "CC" Por el Consecutivo del Archivo',
'FECHA: 12 de Marzo del 2013',
'AUTOR: FRG',
'DESCRIPCIÃN: se agrega condiciÃ³n para considerar registros de cheques que NO estÃ©n reversados.',
'BD: BDISAC',
'FECHA:02/Jun/2014';

CREATE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlError INTEGER, iIsamError INTEGER, cMensaje CHAR(200), cOrigen CHAR(150)) 

--DEFINICION DE VARIABLES

DEFINE dFecha_Hoy           DATE;

--INICIALIZACION DE VARIABLES

LET dFecha_Hoy = '01-01-1900';

    BEGIN
	-- se agrega el MAX para limitar la busqueda y mejorar el rendimiento--
       
	   SELECT MAX(fecha_hoy) INTO dFecha_Hoy FROM bdisac:sac_fechas;
        INSERT INTO sac_MensajeError
                         (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
        VALUES (iSqlError, iIsamError, cMensaje, cOrigen, dFecha_Hoy, CURRENT);

    END;
END PROCEDURE
DOCUMENT
'AUTOR : José Angel López Adams',
'DESCRIPCION: Guarda historial de excepciones registradas en el Sistema de Administracion de Convenios',
'AREA: Integral',
'FECHA : Septiembre de 2008',
'VERSION: 20080909.1525',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzahipinfonavit (cId_Convenio CHAR(5))
                            
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio CHAR(3);
	DEFINE cMes CHAR(2);
	DEFINE cDia CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE dFecha_Hoy DATE;
	DEFINE dFechaIni DATE;
	DEFINE cRutaArch CHAR(100);
	DEFINE cReferencia1 CHAR(20);
	DEFINE iImporte_Pago INTEGER;
	DEFINE iImporte_Pago2 CHAR(30);
	DEFINE iImporte_Pago3 CHAR(30);
	DEFINE ifolio_suc2 CHAR(30);
	DEFINE ifolio_suc3 CHAR(30);
	DEFINE cSucursal CHAR(5);
	DEFINE cDiaPag CHAR(2);
	DEFINE cMesPag CHAR(2);
    DEFINE cAnioPag CHAR(4);
   	DEFINE cFlagCen INTEGER;
    DEFINE cFlagSuc INTEGER;
	DEFINE cFolio CHAR(16);
	DEFINE dFecha_Pago DATE;
	DEFINE iCuantos INTEGER;
	DEFINE ICuantos2 INTEGER;
	DEFINE ICuantos3 INTEGER;
	DEFINE cStmt CHAR (350);
	DEFINE vContador INTEGER;
	DEFINE iTotalPagos INTEGER;
	DEFINE cForma_pago CHAR(1);
	DEFINE cCodigo_postal CHAR(6);
	DEFINE cSuma_importes INTEGER;
	DEFINE cSuma_abonos INTEGER;
	DEFINE cNum_registros INTEGER;
	DEFINE cCanal CHAR(10);
	DEFINE cOrigen CHAR(30);
 
	--set debug file to "/informix/VIMA/INFO/LOAD/reporte.out";
   	--trace on;
	
	LET cCodRet = "00000";
    LET iSqlErr = 0;
	LET cCategoria  = SUBSTRING(cId_Convenio FROM 1 FOR 2);
    LET cConvenio  = SUBSTRING(cId_Convenio FROM 3 FOR 3);
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET dFecha_Hoy = MDY('01','01','1900');
	LET dFechaIni = MDY('01','01','1900');
	LET cRutaArch = '';
	LET cReferencia1  = '';
	LET iImporte_Pago = 0;
	LET iImporte_Pago2 = 0;
	LET iImporte_Pago3 = 0;
	LET ifolio_suc2 = '';
	LET ifolio_suc3 = '';
	LET cSucursal = '';
	LET cDiaPag = '';
	LET cMesPag = '';
    LET cAnioPag = '';
	LET cFlagCen = 0; 
	LET cFlagSuc = 0;
	LET cFolio = '';
	LET dFecha_Pago = MDY('01','01','1900');
	LET	iCuantos = 0;
	LET iCuantos2 = 0;
	LET iCuantos3 = 0;
	LET cStmt = '';
	LET vContador = 0;
	LET iTotalPagos = 0;
	LET cForma_pago='0';
	LET cCodigo_postal='';
	LET cSuma_importes=0;
	LET cSuma_abonos=0;
	LET cNum_registros=0;
	LET cCanal = '';
	LET cOrigen ='';
	
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
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:sac_fechas
		WHERE empresa = "001";
		
		SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:"informix".sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
		
		
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
		
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArch
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
		
		LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
		LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
		LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);
		
		LET cStmt = 'rm -f ' || cRutaArch;
		SYSTEM cStmt;
		
		LET vContador = 0;
		LET cSuma_importes = 0;
		
		FOREACH --FOREACH COUNT1
		
		--CUENTA REGISTROS DE MOVHIS Y MOVDIA DONDE EL MONTO ES DIFERENTE A SAC_MOVIMIENTOSHISTORIAL
		SELECT COUNT(*)
		INTO iCuantos2
		FROM bdisac:"informix".sac_movimientoshistorial mh
        LEFT JOIN bdicheq:"informix".sc_movhis cheq ON mh.folio_suc = cheq.folio_suc
		LEFT JOIN bdicheq:"informix".sc_movdia dia ON mh.folio_suc = dia.folio_suc
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio
        AND fecha_pago > dFechaIni
        AND fecha_pago <= dFecha_Hoy
		AND (cheq.fech_oper > dFechaIni
        AND cheq.fech_oper <= dFecha_Hoy
		OR dia.fech_oper > dFechaIni
        AND dia.fech_oper <= dFecha_Hoy)
		AND (mh.importe_pago <> cheq.monto_tot
		OR mh.importe_pago <> dia.monto_tot)
		AND status_cancelado <> 'S'
        AND (cheq.cancelad <> 'S'
		OR dia.cancelad <> 'S')
        AND (cheq.transacc IN ('8038','0435','1306','1336','1415','1416','1417','1418','1307',
                                  '1337','1367','1419','1420','1421','1422','0547','1641','1675','1708',
                                  '1822','1823','1824','1825','1826','1827')
		
        OR dia.transacc IN ('8038','0435','1306','1336','1415','1416','1417','1418','1307',
                                  '1337','1367','1419','1420','1421','1422','0547','1641','1675','1708',
                                  '1822','1823','1824','1825','1826','1827'))
        AND (flag_confirmacion_central = 1
	    OR flag_confirmacion_sucursal = 1)
		
		END FOREACH; --CIERRA FOREACH COUNT1
		
		IF iCuantos2 = 0  THEN
		
		
		FOREACH --ABRE BLOQUE1_FLUJO_NORMAL
			   
		
		SELECT referencia1, importe_pago * 100, LPAD(id_sucursal,4,'0'), LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),	LPAD(YEAR(fecha_pago::DATE), 4, '0'),
			     flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago,forma_pago,origen
	        INTO  cReferencia1,  iImporte_Pago, cSucursal, cDiaPag, cMesPag, cAnioPag, cFlagCen, cFlagSuc, cFolio, dFecha_Pago, cForma_pago, cOrigen
            FROM bdisac:"informix".sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
	        OR flag_confirmacion_sucursal = 1)
			AND origen = ''
			ORDER BY fecha_insert
			

			
            IF cFlagCen = 0 or cFlagSuc =0 THEN
              SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';

              IF iCuantos = 0 THEN
                 SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago
				and cancelad <> 'S';
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
         
          
			LET cSuma_abonos = cSuma_abonos + 1;
			LET cSuma_importes = cSuma_importes + iImporte_Pago;
			LET vContador = vContador + 1;
			--Genera encabezado
			IF vContador = 1 THEN 
				LET cStmt = 'echo "' ||'1'|| '137'||LPAD(YEAR(dFecha_Hoy::DATE), 4, '0')||LPAD(MONTH(dFecha_Hoy::DATE), 2, '0')|| LPAD(DAY(dFecha_Hoy::DATE), 2, '0')||'" >> ' || cRutaArch;
				SYSTEM cStmt;
			END IF; 
			--Genera el detalle del archivo	
			-- Se evalua si el pago se realizo en ventanilla o ATM
			IF cSucursal = '9307' THEN
				LET cCanal = 'ATM';
				LET cCodigo_postal = '11800';
			ELSE
				LET cCanal = 'Efectivo';
				--Se obtiene el codigo postal de la sucursal
				SELECT cp INTO cCodigo_postal FROM bdinteg:si_ptf WHERE id_ptf = cSucursal AND tipo <> 'C';
			END IF;
			--Lo que va a imprimir
            LET cStmt = 'echo "' ||'2'|| '0000000000' || LPAD(TRIM(cSucursal),10,'0') || LPAD(TRIM(cCanal), 25, '0') || 
				TRIM(NVL(cCodigo_postal, "00000")) || LPAD(YEAR(dFecha_Pago::DATE), 4, '0') || LPAD(MONTH(dFecha_Pago::DATE), 2, '0')|| 
				LPAD(DAY(dFecha_Pago::DATE), 2, '0') || 'Abono' || LPAD(iImporte_Pago, 11, '0') || TRIM(cReferencia1) || TRIM(SUBSTRING(cFolio FROM 2 FOR 15)) ||'" >> ' || cRutaArch;
            SYSTEM cStmt;
			
        END FOREACH; -- CIERRA BLOQUE1_FLUJO_NORMAL
		
		
		ELSE --EN CASO CONTRARIO FLUJO COUNT
		
		
		FOREACH --FOREACH UPDATE EN DADO CASO QUE SEAN DIFERENTES EN sc_movdia

		SELECT dia.monto_tot, mh.folio_suc
		INTO iImporte_Pago2,ifolio_suc2
		FROM bdisac:"informix".sac_movimientoshistorial mh
        INNER JOIN bdicheq:"informix".sc_movdia dia ON mh.folio_suc = dia.folio_suc
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio
        AND fecha_pago > dFechaIni
        AND fecha_pago <= dFecha_Hoy
		AND dia.fech_oper > dFechaIni
        AND dia.fech_oper <= dFecha_Hoy
		AND mh.importe_pago <> dia.monto_tot
		AND status_cancelado <> 'S'
        AND dia.cancelad <> 'S'
        AND dia.transacc IN ('8038','0435','1306','1336','1415','1416','1417','1418','1307',
                                  '1337','1367','1419','1420','1421','1422','0547','1641','1675','1708',
                                  '1822','1823','1824','1825','1826','1827')
        AND (flag_confirmacion_central = 1
	    OR flag_confirmacion_sucursal = 1)
		
		
		UPDATE bdisac:sac_movimientoshistorial SET importe_pago = iImporte_Pago2
		WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
			AND folio_suc = ifolio_suc2
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
	        OR flag_confirmacion_sucursal = 1)
			AND origen = '';
			
			
		END FOREACH;	--CIERRE FOREACH UPDATE EN DADO CASO QUE SEAN DIFERENTES EN sc_movdia
		
		
		
		FOREACH	 --FOREACH UPDATE EN DADO CASO QUE SEAN DIFERENTES EN sc_movhis
		
		SELECT cheq.monto_tot, mh.folio_suc
		INTO iImporte_Pago3,ifolio_suc3
		FROM bdisac:"informix".sac_movimientoshistorial mh
        INNER JOIN bdicheq:"informix".sc_movhis cheq ON mh.folio_suc = cheq.folio_suc
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio
        AND fecha_pago > dFechaIni
        AND fecha_pago <= dFecha_Hoy
		AND cheq.fech_oper > dFechaIni
        AND cheq.fech_oper <= dFecha_Hoy
		AND mh.importe_pago <> cheq.monto_tot
		AND status_cancelado <> 'S'
        AND cheq.cancelad <> 'S'
        AND cheq.transacc IN ('8038','0435','1306','1336','1415','1416','1417','1418','1307',
                                  '1337','1367','1419','1420','1421','1422','0547','1641','1675','1708',
                                  '1822','1823','1824','1825','1826','1827')
        AND (flag_confirmacion_central = 1
	    OR flag_confirmacion_sucursal = 1)
		
	
			
		UPDATE bdisac:sac_movimientoshistorial SET importe_pago = iImporte_Pago3
		WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
			AND folio_suc = ifolio_suc3
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
	        OR flag_confirmacion_sucursal = 1)
			AND origen = '';
		
		 END FOREACH; --CIERRE FOREACH UPDATE EN DADO CASO QUE SEAN DIFERENTES EN sc_movhis
		
		
		
		
        FOREACH --Abre bloque2_Flujo_Normal
		
		SELECT referencia1, importe_pago * 100, LPAD(id_sucursal,4,'0'), LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),	LPAD(YEAR(fecha_pago::DATE), 4, '0'),
			     flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago,forma_pago,origen
	        INTO  cReferencia1,  iImporte_Pago, cSucursal, cDiaPag, cMesPag, cAnioPag, cFlagCen, cFlagSuc, cFolio, dFecha_Pago, cForma_pago, cOrigen
            FROM bdisac:"informix".sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
	        OR flag_confirmacion_sucursal = 1)
			AND origen = ''
			ORDER BY fecha_insert
			

			
            IF cFlagCen = 0 or cFlagSuc =0 THEN
              SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';

              IF iCuantos = 0 THEN
                 SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago
				and cancelad <> 'S';
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
         
          
			LET cSuma_abonos = cSuma_abonos + 1;
			LET cSuma_importes = cSuma_importes + iImporte_Pago;
			LET vContador = vContador + 1;
			--Genera encabezado
			IF vContador = 1 THEN 
				LET cStmt = 'echo "' ||'1'|| '137'||LPAD(YEAR(dFecha_Hoy::DATE), 4, '0')||LPAD(MONTH(dFecha_Hoy::DATE), 2, '0')|| LPAD(DAY(dFecha_Hoy::DATE), 2, '0')||'" >> ' || cRutaArch;
				SYSTEM cStmt;
			END IF; 
			--Genera el detalle del archivo	
			-- Se evalua si el pago se realizo en ventanilla o ATM
			IF cSucursal = '9307' THEN
				LET cCanal = 'ATM';
				LET cCodigo_postal = '11800';
			ELSE
				LET cCanal = 'Efectivo';
				--Se obtiene el codigo postal de la sucursal
				SELECT cp INTO cCodigo_postal FROM bdinteg:si_ptf WHERE id_ptf = cSucursal AND tipo <> 'C';
			END IF;
			--Lo que va a imprimir
            LET cStmt = 'echo "' ||'2'|| '0000000000' || LPAD(TRIM(cSucursal),10,'0') || LPAD(TRIM(cCanal), 25, '0') || 
				TRIM(NVL(cCodigo_postal, "00000")) || LPAD(YEAR(dFecha_Pago::DATE), 4, '0') || LPAD(MONTH(dFecha_Pago::DATE), 2, '0')|| 
				LPAD(DAY(dFecha_Pago::DATE), 2, '0') || 'Abono' || LPAD(iImporte_Pago, 11, '0') || TRIM(cReferencia1) || TRIM(SUBSTRING(cFolio FROM 2 FOR 15)) ||'" >> ' || cRutaArch;
            SYSTEM cStmt;
			
		
        END FOREACH; --Cierra bloque2_Flujo_Normal
					

	END IF; -- Cierra IF count1
		
		
		
		
		
		--Genera el Final del archivo
		IF vContador > 0  THEN
			LET cStmt = 'echo "' || "3" || LPAD(cSuma_importes, 11, '0') || LPAD(cSuma_abonos, 5, '0')  || '" >> ' || cRutaArch;
			SYSTEM cStmt; 
		END IF;	
		IF vContador = 0 THEN 
            LET cStmt = 'echo "' || "0"  || '" >> ' || cRutaArch;
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