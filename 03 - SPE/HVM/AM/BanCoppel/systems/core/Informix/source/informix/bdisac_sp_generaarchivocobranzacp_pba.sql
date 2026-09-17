CREATE PROCEDURE "informix".sp_generaarchivocobranzacp_pba(cId_convenio CHAR(5))

--DEFINICION DE VARIABLES

	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cInfoErr			CHAR(100);
	DEFINE iSucursal		INTEGER;
	DEFINE iImporte			INTEGER;
	DEFINE iCantidad		INTEGER;
	DEFINE cCategoria		CHAR(2);
	DEFINE cMes				CHAR(2);
	DEFINE cDia				CHAR(2);
	DEFINE cConvenio		CHAR(3);
	DEFINE cAnio			CHAR(4);
	DEFINE cExtTxt			CHAR(4);
	DEFINE cNomArchTotF		CHAR(15);
	DEFINE cRuta			CHAR(40);
	DEFINE cRutaFT			CHAR(50);
	DEFINE cStmt			CHAR(250);
	DEFINE dFechaIni		DATE;
	DEFINE dFecha_Hoy		DATE;
	DEFINE cNomes			CHAR(15);
	DEFINE cCuentaPrestadora CHAR(12);
	DEFINE cTipoOperacion	CHAR(1);
	DEFINE cNumCteBanco		CHAR(11);
	DEFINE iNumPolizaSeg	INTEGER;
	DEFINE cPlanContra		CHAR(1);
	DEFINE cTipoPago		CHAR(2);
	DEFINE iImportePago		INTEGER;
	DEFINE iImporteComi		INTEGER;
	DEFINE cFolioBanco		CHAR(16);
	DEFINE iNumPagos		INTEGER;
	DEFINE iTotalPagado		INTEGER;
	DEFINE iTotalComision	INTEGER;
	DEFINE dFechaPago		DATE;
	DEFINE wiva             DECIMAL(5,2);
	
	DEFINE cReferencia1     CHAR(20);
	DEFINE iFlagCen 		INTEGER;
	DEFINE iFlagSuc 		INTEGER;
	DEFINE cFolio			CHAR(16);
	DEFINE dFecha_Pago		DATE;
	DEFINE iCuantos         INTEGER;
	
	--	SET DEBUG FILE TO '/informix/EPG/sp_generaarchivocobranzacp.out';
	--	TRACE ON;
	
    --INICIALIZACION DE VARIABLES
	LET cCodRet = '00000';
	LET cStmt = '' ;
	LET cRuta = '';
	LET iImporte = 0;
	LET iCantidad = 0;
	LET cExtTxt = ".txt";
	LET cCategoria = SUBSTRING(cId_convenio FROM 1 FOR 2);
	LET cConvenio = SUBSTRING(cId_convenio FROM 3 FOR 3);
	LET cNomes						= '';
	LET cCuentaPrestadora = '';
	LET cTipoOperacion = 'D';
	LET cNumCteBanco = '00000000000';
	LET iNumPolizaSeg = '00000000000';
	LET cPlanContra = '0';
	LET cTipoPago = '00';
	LET iImportePago = '000000000';
	LET iImporteComi = '00000000';
	LET cFolioBanco = '0000000000000000';
	LET iNumPagos = 0;
	LET iTotalPagado = 0;
	LET iTotalComision = 0;
	LET dFechaPago = date(1);
	LET wiva = 0.00;
	
	LET cReferencia1 = '';
	LET iFlagCen 	 = 0;
	LET iFlagSuc 	 = 0;
	LET cFolio		 = '';
	LET dFecha_Pago	 = DATE(1);
	LET iCuantos     = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlarchivoscobranza
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;

				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_generaarchivocobranzacp");
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas;

		SELECT fecha_ultimo_archivo
		INTO dFechaIni
		FROM "informix".sac_controlarchivoscobranza
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE) , 4, '0');
		
		-- La ruta donde se generarÃ¡ el archivo txt de cobranza para el club de proteccion serÃ¡ la misma que usa el convenio abono coppel
		SELECT TRIM(valor)
		INTO cRuta
		FROM "informix".sac_param
		WHERE cod_param = 3;

		LET cNomArchTotF = "BC"|| cDia||cMes||cAnio ||cExtTxt;
		LET cRutaFT = TRIM(cRuta) || cNomArchTotF;

		IF cMes='12' THEN LET cNomes =' DE DICIEMBRE DE '; END IF;
		IF cMes='11' THEN LET cNomes =' DE NOVIEMBRE DE '; END IF;
		IF cMes='10' THEN LET cNomes =' DE OCTUBRE DE '; END IF;
		IF cMes='09' THEN LET cNomes =' DE SEPTIEMBRE DE '; END IF;
		IF cMes='08' THEN LET cNomes =' DE AGOSTO DE '; END IF;
		IF cMes='07' THEN LET cNomes =' DE JULIO DE '; END IF;
		IF cMes='06' THEN LET cNomes =' DE JUNIO DE '; END IF;
		IF cMes='05' THEN LET cNomes =' DE MAYO DE '; END IF;
		IF cMes='04' THEN LET cNomes =' DE ABRIL DE '; END IF;
		IF cMes='03' THEN LET cNomes =' DE MARZO DE '; END IF;
		IF cMes='02' THEN LET cNomes =' DE FEBRERO DE '; END IF;
		IF cMes='01' THEN LET cNomes =' DE ENERO DE '; END IF;

		--IMPRIME RENGLON DE LAS OPERACIONES
		LET cStmt='echo "' || 'ARCHIVO GENERADO POR BANCOPPEL		   NOMBRE DEL ARCHIVO:' || ' '||  'BC' || cDia|| cMEs || cAnio || '" >> ' || cRutaFT;

		SYSTEM cStmt;
		LET cStmt='echo "' || 'FECHA: ' ||cDia||" "||TRIM(cNomes)||" "||cAnio|| '" >> ' || cRutaFT;
		SYSTEM cStmt;
		
		--Se obtienen los valores de los parametros cuenta prestadora e Iva correspondientes al convenio de club de proteccion coppel
		SELECT cuenta_prestadora, (iva_convenio / 100 )+1
		INTO cCuentaPrestadora, wiva 
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		--IMPRIME RENGLON DE LAS OPERACIONES
		LET cStmt='echo "' || 'CUENTA CONCENTRADORA COPPEL: '|| cCuentaPrestadora ||'" >> ' || cRutaFT;
		SYSTEM cStmt;

		FOREACH
			SELECT LPAD(TRIM(NVL(b.referencia1,0)),11,'0'), LPAD(a.folio,11,'0'), LPAD(a.cantidadseguros,1,'0'),
					CASE WHEN forma_pago = 1 THEN 'EF' ELSE (CASE WHEN forma_pago = 2 THEN 'CD' ELSE 'CC' END) END AS efe,
                              (b.importe_pago * 100), (b.importe_comision_convenio * 100), LPAD(nvl(b.folio_suc,0),16,'0'), a.fecha
			INTO cNumCteBanco, iNumPolizaSeg, cPlanContra, cTipoPago, iImportePago, iImporteComi, cFolioBanco, dFechaPago
			FROM "informix".sac_movimientosdetallehistorial a, "informix".sac_movimientoshistorial b
			---WHERE a.fecha::date > dFechaIni
			WHERE a.fecha > dFechaIni
			---AND a.fecha::date <= dFecha_Hoy
			AND a.fecha <= dFecha_Hoy
			AND a.recibo = b.referencia2
			AND b.numcategoria = cCategoria
			AND b.numconvenio = cConvenio
			AND b.referencia1 = CASE WHEN a.cliente <> 0 THEN a.cliente ELSE a.cte_prospecto END
			AND NOT (status_cancelado = 'S' AND status_coppel = 0)

			LET cDia = LPAD(DAY(dFechaPago::DATE), 2, '0');
			LET cMEs = LPAD(MONTH(dFechaPago::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFechaPago::DATE) , 4, '0');

			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "' || cTipoOperacion || '|' ||cDia || cMes || cAnio || '|' || LPAD(cNumCteBanco, 11,'0') || '|' || LPAD(iNumPolizaSeg, 11,'0') || '|' || LPAD(cPlanContra, 1,'0') || '|' || LPAD(cTipoPago, 2,'0') || '|' || LPAD(iImportePago ,9,'0') || '|' || LPAD(iImporteComi, 8, '0') || '|' || LPAD(cFolioBanco, 16, '0')  || '" >> ' || cRutaFT;
			SYSTEM cStmt;

			LET iNumPagos = iNumPagos + 1;
			LET iTotalPagado = iTotalPagado + iImportePago;
			LET iTotalComision = iTotalComision + (iImporteComi * wiva );

		END FOREACH;

        FOREACH
			SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1,flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
			INTO  cReferencia1, iFlagCen, iFlagSuc, cFolio, dFecha_Pago
			FROM bdisac:sac_movimientoshistorial
			WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)
				
			IF iFlagCen = 0 or iFlagSuc =0 THEN
				SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio AND cancelad <> 'S';
				IF iCuantos = 0 THEN
					SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago AND cancelad <> 'S';
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				IF iCuantos > 0 THEN            
					UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
					WHERE numcategoria = cCategoria
						AND numconvenio = cConvenio
						AND fecha_pago = dFecha_Pago
						AND folio_suc = cFolio
						AND referencia1 = cReferencia1
						AND status_cancelado <> 'S'
						AND flag_confirmacion_sucursal = 0;             
						
						INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
						VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFecha_Pago,current);
				END IF;
			END IF;
		END FOREACH;

		IF DBINFO("sqlca.sqlerrd2") <> 0 THEN
			LET cTipoOperacion = 'C';
			LET cNumCteBanco = '00000000000';
			LET iNumPolizaSeg = '00000000000';
			LET cPlanContra = '0';
			LET cTipoPago = '00';
			--LET iImportePago = '000000000';
			LET iImporteComi = '00000000';
			LET cFolioBanco = '0000000000000000';

			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "' || cTipoOperacion || '|' ||cDia || cMes || cAnio || '|' || LPAD(cNumCteBanco, 11,'0') || '|' || LPAD(iNumPolizaSeg, 11,'0') || '|' || LPAD(cPlanContra, 1,'0') || '|' || LPAD(cTipoPago, 2,'0') || '|' || LPAD(iTotalComision ,9,'0') || '|' || LPAD(iImporteComi, 8, '0') || '|' || LPAD(cFolioBanco, 16, '0') || '" >> ' || cRutaFT;
			SYSTEM cStmt;

			LET cTipoOperacion = 'T';
			LET iTotalPagado = iTotalPagado - iTotalComision;

			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "' || cTipoOperacion || '|' ||cDia || cMes || cAnio || '|' || LPAD(cNumCteBanco, 11,'0') || '|' || LPAD(iNumPagos, 11,'0') || '|' || LPAD(cPlanContra, 1,'0') || '|' || LPAD(cTipoPago, 2,'0') || '|' || LPAD(iTotalPagado ,9,'0') || '|' || LPAD(iTotalComision, 8, '0') || '|' || LPAD(cFolioBanco, 16, '0') || '" >> ' || cRutaFT;
			SYSTEM cStmt;

		ELIF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cTipoOperacion = 'T';
			LET cNumCteBanco = '00000000000';
			LET iNumPolizaSeg = '00000000000';
			LET cPlanContra = '0';
			LET cTipoPago = '00';
			LET iImportePago = '000000000';
			LET iImporteComi = '00000000';
			LET cFolioBanco = '0000000000000000';

			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "' || cTipoOperacion || '|' ||cDia || cMes || cAnio || '|' || LPAD(cNumCteBanco, 11,'0') || '|' || LPAD(iNumPolizaSeg, 11,'0') || '|' || LPAD(cPlanContra, 1,'0') || '|' || LPAD(cTipoPago, 2,'0') || '|' || LPAD(iImportePago ,9,'0') || '|' || LPAD(iImporteComi, 8, '0') || '|' || LPAD(cFolioBanco, 16, '0') || '" >> ' || cRutaFT;
			SYSTEM cStmt;
		END IF;
		
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'Folio: 1448',
'Autor: 93893061 ',
'Fecha: 09/09/2014',
'DescripciÃ³n: Se crea procedimiento que realiza archivo en txt. de la cobranza generada con los pagos para club de proteccion coppel',
'Sustento:RQI 62 038 VentaClubdeProteccionCppl-BCP_InterfacesCaja_v3',
'Solicita: FermÃ­n Ramos',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzacam(pConvenio CHAR(5))
   
   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
	DEFINE iSqlErr                  INTEGER;
	DEFINE dImporte_Pago            DECIMAL(11,0);
	DEFINE iTotal_Pago              INTEGER;
    DEFINE iFlagCen                 INTEGER;
    DEFINE iFlagSuc                 INTEGER;
	DEFINE iCuantos                 INTEGER;
	DEFINE iNumPagos                INTEGER;
    DEFINE iTransac                 INTEGER;
	DEFINE iMonto_tot               INTEGER;
    DEFINE cDia                     CHAR(2);
	DEFINE cDia_a                   CHAR(2);
	DEFINE cMes                     CHAR(2);
	DEFINE cAnio                    CHAR(4);
    DEFINE cDiaPago                 CHAR(2);
	DEFINE cMesPago                 CHAR(2);
    DEFINE cAnioPago                CHAR(4);
    DEFINE cCategoria               CHAR(2);
    DEFINE cConvenio                CHAR(3);                                              
    DEFINE cReferencia1             CHAR(20);
	DEFINE cRutaArchCam             CHAR(100);
    DEFINE cStmt                    CHAR(250);
    DEFINE cFolio                   CHAR(16);
    DEFINE dFechaIni                DATE;
    DEFINE dFecha_Hoy               DATE;
	DEFINE cFecha					CHAR(10);
	DEFINE cCuenta_Prestadora       CHAR(20);
	DEFINE cSucursal                CHAR(4);
	DEFINE cFormaPago				CHAR(1);
	DEFINE dFechaPago               DATE;
	DEFINE cCargoAbono 				CHAR(1);
	DEFINE cReferencia2				CHAR(20);
	DEFINE cCveProcedencia 			CHAR(2);
		
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
    LET dImporte_Pago 		  = 0;
	LET iTotal_Pago  		  = 0;
    LET cFolio        		  = '';                 
    LET iFlagCen      		  = 0;                 
    LET iFlagSuc      		  = 0; 
	LET cRutaArchCam  		  = '';
	LET	iCuantos      		  = 0;
	LET cStmt         		  = '';
	LET dFechaIni     		  = DATE(1);
	LET dFecha_Hoy    		  = DATE(1); 
	LET iNumPagos             = 0;
	LET iTransac		      = 0;
	LET cCuenta_Prestadora    = '';
	LET iMonto_tot            = 0;
	LET cSucursal			  = '';
	LET cFormaPago            = '';
	LET dFechaPago            = DATE(1);
	LET cStmt 				  = '';
	LET cCargoAbono 		  ='';
	LET cReferencia2		  = '';
	LET cCveProcedencia		  = '';
	
	--SET DEBUG FILE TO '/informix/noe/sp_generaarchivocobranzacam.out';
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
		
		SET ISOLATION TO DIRTY READ;
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
		LET cDia_a = LPAD(DAY(dFecha_Hoy::DATE) , 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = YEAR(dFecha_Hoy ::DATE);
		LET cFecha = cDia_a || '-' || cMes || '-' || cAnio;
		
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza),cuenta_prestadora
		INTO cRutaArchCam,cCuenta_Prestadora
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
		
		
		LET cRutaArchCam = REPLACE(cRutaArchCam,'DD',cDia);
		LET cRutaArchCam = REPLACE(cRutaArchCam,'MM',cMes);
		LET cRutaArchCam = REPLACE(cRutaArchCam,'AAAA',cAnio);

		SELECT TRIM(valor) 
		INTO cCveProcedencia
		FROM bdisac:"informix".sac_param
		WHERE cod_param='6034';

		LET cStmt = 'echo "BANCOPPEL " >> ' || cRutaArchCam;
		SYSTEM cStmt;		
		LET cStmt = 'echo "DETALLE DE MOVIMIENTOS DE PAGOS CAMINEMOS RECIBIDOS " >> ' || cRutaArchCam;
		SYSTEM cStmt;		
		LET cStmt = 'echo "CUENTA CONCENTRADORA: ' || TRIM(cCuenta_Prestadora) || ' " >> ' || cRutaArchCam;
		SYSTEM cStmt;		
		LET cStmt = 'echo "FECHA: ' || TRIM(cFecha) || ' " >> ' || cRutaArchCam;
		SYSTEM cStmt;		
		
        FOREACH
            SELECT fecha_pago,
			   referencia1,
			   importe_pago * 100,
			   (DECODE(forma_pago, '1', 'A', DECODE(forma_pago, '2', 'A', DECODE(forma_pago, '3', 'A', DECODE(forma_pago, '5', 'A'))))) ,
			   flag_confirmacion_central, 
			   flag_confirmacion_sucursal, 
			   referencia2,
			   id_sucursal,
			   folio_suc
			INTO  dFechaPago,cReferencia1,dImporte_Pago,cCargoAbono,iFlagCen,iFlagSuc,cReferencia2,cSucursal,cFolio
            FROM bdisac:"informix".sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
	        OR flag_confirmacion_sucursal = 1)
			
			IF iFlagCen = 0 OR iFlagSuc =0 THEN
				SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
				IF iCuantos = 0 THEN
					SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND  fech_alt = dFechaPago
--2014.06.02 FRG-i
				and cancelad <> 'S';
--2014.06.02 FRG-f
					IF iCuantos = 0 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
	        END IF;
			
			IF iCuantos > 0 THEN            
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);					
              END IF;
 
			LET cDiaPago 	= LPAD(DAY(dFechaPago::DATE), 2, '0');
			LET cMesPago 	= LPAD(MONTH(dFechaPago::DATE), 2, '0');
			LET cAnioPago 	= YEAR(dFechaPago ::DATE); 			
						
			LET cStmt = 'echo "' || TRIM(cAnioPago)|| TRIM(cMesPago) || TRIM(cDiaPago)||"|"|| LPAD(TRIM(cReferencia1),10,'0')|| "|" || LPAD(dImporte_Pago,11,'0')|| "|" || TRIM(cCargoAbono) || "|" || LPAD(cReferencia2,20,' ')|| "|" || TRIM(cSucursal)|| "|" || TRIM(cCveProcedencia) || '">> ' || cRutaArchCam;
            SYSTEM cStmt;
			
        END FOREACH;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cStmt = 'echo "' || "" ||'">> ' || cRutaArchCam;
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
        
		
		UPDATE bdisac:"informix".sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio; 
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Eduardo López Cuevas',
'DESCRIPCION: Genera el archivo de cobranza CAMINEMOS de acuerdo al Layout',
'EJECUTADO O LLAMADO POR:sp_genera_ArchivosCobranzaCentral()',
'BD: BDISAC',
'FECHA : 22 de Mayo 2013',
'VERSION: 20130522',
'AUTOR: FRG',
'DESCRIPCIÓN: se agrega condición para considerar registros de cheques que NO estén reversados.',
'FECHA:02/Jun/2014';

CREATE PROCEDURE "informix".sp_generaarchivocobranzacarnival(pConvenio CHAR(5))

   -- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago			CHAR(4);
DEFINE cCategoria			CHAR(2);
DEFINE cConvenio			CHAR(3);
DEFINE cReferencia1			CHAR(20);
DEFINE cReferencia2			CHAR(2);
DEFINE cRutaArchSolfi		CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE dFechaIni			DATE;
DEFINE dFecha_Hoy			DATE;
DEFINE iImporte_Pago		DECIMAL(11,0);
DEFINE iTotal_Pago			DECIMAL(11,0);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos			INTEGER;
DEFINE cCuenta_Prestadora	CHAR(20);
DEFINE cNomes				CHAR(15);
DEFINE cHora				CHAR(2);
DEFINE cMinuto	  			CHAR(2);
DEFINE cSegundo				CHAR(2);
DEFINE cAlfaReferencia1		CHAR(2);
DEFINE cAlfaReferencia2		CHAR(5);
DEFINE iDigiVerificador		CHAR(1);
DEFINE cSucursal			CHAR(4);
DEFINE iValor1				SMALLINT ;
DEFINE iValor2				SMALLINT;
DEFINE iValor3				SMALLINT;
DEFINE iValor4				SMALLINT;
DEFINE iValor5				SMALLINT;
DEFINE dFechaPago				DATE;

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3 FOR 3);
LET cReferencia1			= '';
LET cReferencia2			= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago			= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchSolfi			= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET iNumPagos				= 0;
LET cCuenta_Prestadora		= '';
LET cNomes					= '';
LET cHora					= '';
LET cMinuto					= '';
LET cSegundo				= '';
LET cAlfaReferencia1		= '';
LET cAlfaReferencia2		= '';
LET iDigiVerificador		= '';
LET cSucursal				= '';
LET iValor1					= 0;
LET iValor2					= 0;
LET iValor3					= 0;
LET iValor4					= 0;
LET iValor5					= 0;
LET dFechaPago              = DATE(1);

	--SET DEBUG FILE TO '/informix/noe/sp_generaarchivocobranzacarnival.out';
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

		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza),cuenta_prestadora
		INTO cRutaArchSolfi,cCuenta_Prestadora
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

		LET cRutaArchSolfi = REPLACE(cRutaArchSolfi,'AAAA',cAnio);
		LET cRutaArchSolfi = REPLACE(cRutaArchSolfi,'MM',cMes);
		LET cRutaArchSolfi = REPLACE(cRutaArchSolfi,'DD',cDia);

		FOREACH

			SELECT fecha_pago,
			LPAD(DAY(fecha_pago::DATE), 2, '0'),
			LPAD(MONTH(fecha_pago::DATE), 2, '0'),
			LPAD(YEAR(fecha_pago::DATE), 4, '0'),
			LPAD(SUBSTR(fecha_insert,12,2),2,'0'),
			LPAD(SUBSTR(fecha_insert,15,2),2,'0'),
			LPAD(SUBSTR(fecha_insert,18,2),2,'0'),
			referencia1, referencia2, importe_pago*100, flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, id_sucursal
			INTO  dFechaPago,cDiaPago,cMesPago,cAnioPago,cHora,cMinuto,cSegundo,cReferencia1,cReferencia2,iImporte_Pago,iFlagCen,iFlagSuc,cFolio,cSucursal 
			FROM "informix".sac_movimientoshistorial
			WHERE numcategoria = cCategoria
			AND numconvenio = cConvenio
			AND fecha_pago > dFechaIni
			AND fecha_pago <= dFecha_Hoy
			AND status_cancelado <> 'S'
			AND (flag_confirmacion_central = 1
			OR flag_confirmacion_sucursal = 1)

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
		  END IF;

			--IMPRIME RENGLON DE LAS OPERACIONES			
			LET cStmt = 'echo "' || cAnioPago || cMesPago || cDiaPago || LPAD(cReferencia1, 7,'0') || LPAD(cReferencia2, 1,'0') || LPAD(iImporte_Pago, 9, '0') || LPAD(cSucursal, 4, '0') || '" >> ' || cRutaArchSolfi;
			
			SYSTEM cStmt;
			
		END FOREACH;		
	
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cAlfaReferencia1 = '00';
			LET cAlfaReferencia2 = '00000';
			LET iDigiVerificador = '0';
			LET iImporte_Pago = '000000000';
			LET cSucursal = '0000';
			
			--IMPRIME RENGLON DE LAS OPERACIONES
			LET cStmt = 'echo "' || cAnio || cMes || cDia || cAlfaReferencia1 || LPAD(cAlfaReferencia2, 5,'0') || LPAD(iDigiVerificador ,1,'0') || LPAD(iImporte_Pago, 9, '0') || LPAD(cSucursal ,4,'0') || '" >> ' || cRutaArchSolfi;
			
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
        

		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO		
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Vazquez Herrera Hugo Guadalupe.',
'DESCRIPCIÃ?N: SP que genera un archivo .txt donde se guardan las operacines de pagos CARNIVAL.',
'FOLIO:1443',
'FECHA:25/06/2014',
'VERSIÃ?N: 20140625.1622',
'BASE DE DATOS: bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzadyclass(pConvenio CHAR(5))
   -- DEFINICION DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE cDia                     CHAR(2);
	DEFINE cMes                     CHAR(2);
	DEFINE cAnio                    CHAR(2);
    DEFINE cDiaPago                 CHAR(2);
	DEFINE cMesPago                 CHAR(2);
    DEFINE cAnioPago                CHAR(4);
    DEFINE cCategoria               CHAR(2);
    DEFINE cConvenio                CHAR(3);                                              
    DEFINE cReferencia1             CHAR(20);
    DEFINE cRutaArchAvon            CHAR(100);
    DEFINE cStmt                    CHAR(250);
    DEFINE cFolio                   CHAR(16);
	DEFINE cTpoOperacion            CHAR(1);
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
    DEFINE cValor					CHAR(100);
	DEFINE cCuenta_Prestadora       CHAR(20);
	DEFINE mMonto_tot               MONEY(12,2);
    DEFINE dFecha_Pago               DATE;
	
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
	
	--SET DEBUG FILE TO '/informix/noe/sp_generaarchivocobranzadyclass.out';
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
				
		
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza),cuenta_prestadora
		INTO cRutaArchAvon,cCuenta_Prestadora
		FROM bdisac:"informix".sac_convenios
		WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;
     	
		LET cRutaArchAvon = REPLACE(cRutaArchAvon,'AA',cAnio);
		LET cRutaArchAvon = REPLACE(cRutaArchAvon,'MM',cMes);
		LET cRutaArchAvon = REPLACE(cRutaArchAvon,'DD',cDia);

		-- Consulta de la Transacción del Servicio
		LET iTransac = 6017; -- OJO************ CAMBIAR
		SELECT valor 
		  INTO cValor
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
	        INTO  cDiaPago,cMesPago,cAnioPago,cReferencia1, iImporte_Pago,iImporte_Comision,iImporte_IVA_Comision,iFlagCen,iFlagSuc,cFolio, dFecha_Pago
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
              END IF;
            END IF;	
			
			LET iSumaImporte_Comision = iSumaImporte_Comision + iImporte_Comision;
			LET iSumaImporte_IVA_Comision = iSumaImporte_IVA_Comision + iImporte_IVA_Comision;			
			LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
			LET iNumPagos = iNumPagos + 1;
			
            LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iImporte_Pago, 10, '0') || LPAD(cFolio, 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;
        END FOREACH;
        
	   
		LET cReferencia1 = '';
		LET cFolio       = '';
		
		IF iSumaImporte_Comision <> 0 THEN
			LET cTpoOperacion = 'C';  
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iSumaImporte_Comision, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;
		END IF;
		
		IF iSumaImporte_IVA_Comision <> 0 THEN
		    LET cTpoOperacion = 'I';  
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iSumaImporte_IVA_Comision, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
            SYSTEM cStmt;
		END IF;
		
		IF mMonto_tot <> 0 THEN
			LET cTpoOperacion = 'E';  
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iSumaImporte_IVA_Comision, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
			SYSTEM cStmt;
		END IF;
		
		IF iNumPagos <> 0 THEN
			LET cTpoOperacion = 'T';		
			LET iTotal_Pago = ((iTotal_Pago - iSumaImporte_Comision) - iSumaImporte_IVA_Comision) - iMonto_tot;
			
			LET cStmt = 'echo "' || cTpoOperacion || cDiaPago || cMesPago || cAnioPago || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(TO_CHAR(iNumPagos)), 9, '0') || LPAD(iTotal_Pago, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
			SYSTEM cStmt;
		END IF;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
		    LET cTpoOperacion = 'T'; 
			LET cStmt = 'echo "' || cTpoOperacion || LPAD(TRIM(cDiaPago),2,'0') || LPAD(TRIM(cMesPago),2,'0') || LPAD(TRIM(cAnioPago),2,'0') || LPAD(TRIM(cReferencia1), 7, '0') || LPAD(TRIM(cReferencia1), 9, '0') || LPAD(iTotal_Pago, 10, '0') || LPAD(TRIM(cFolio), 16, '0') || '" >> ' || cRutaArchAvon;
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
END PROCEDURE
DOCUMENT
'AUTOR : Martín Eduardo Miranda',
'DESCRIPCION: Genera el archivo de cobranza Dyclass de acuerdo al Layout',
'EJECUTADO O LLAMADO POR:sp_genera_ArchivosCobranzaCentral()',
'BD: BDISAC',
'FECHA : 06 Julio 2012',
'VERSION: 20120706',
'AUTOR: FRG',
'DESCRIPCIÓN: se agrega condición para considerar registros de cheques que NO estén reversados.',
'FECHA:02/Jun/2014';

CREATE PROCEDURE "informix".sp_generaarchivocobranzaaxtel(pConvenio CHAR(5))

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(2);
DEFINE cAnio2				CHAR(4);
DEFINE cDiaPago				CHAR(2);
DEFINE cMesPago				CHAR(2);
DEFINE cAnioPago				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cMovimiento			CHAR(2);
DEFINE cTipoMovimiento		CHAR(2);
DEFINE cReferencia1			CHAR(30);
DEFINE cRutaArchAxtel		CHAR(100);  
DEFINE cStmt				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE cTpoOperacion			CHAR(1);
DEFINE dFechaIni				DATE;
DEFINE dFecha_Hoy				DATE;
DEFINE iImporte_Pago			DECIMAL(16,2);
DEFINE iTotal_Pago			DECIMAL(16,2);
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE iNumPagos				INTEGER;
DEFINE cSucursal				CHAR(4);
DEFINE dFechaPago				DATE;
DEFINE iRelleno				INTEGER;
DEFINE iFlagCopp			INTEGER;
DEFINE vDias                INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET iSqlErr					= 0;
LET cCategoria				= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio				= SUBSTRING(pConvenio FROM 3 FOR 3);
LET cMovimiento				= '';
LET cTipoMovimiento			= '';
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET cAnio2					= '';
LET cDiaPago				= '';
LET cMesPago				= '';
LET cAnioPago				= '';
LET iImporte_Pago				= 0;
LET iTotal_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchAxtel			= '';
LET iCuantos				= 0;
LET cStmt					= '';
LET dFechaIni				= DATE(1);
LET dFecha_Hoy				= DATE(1);
LET cTpoOperacion				= '1';
LET iNumPagos				= 0;
LET cSucursal				= '';
LET dFechaPago				= DATE(1);
LET iRelleno				= 0;
LET iFlagCopp           	= 0;
LET vDias               	= 0;

	---SET DEBUG FILE TO  '/informix/rer/sp_generaarchivocobranzaaxtel.out';
	---TRACE ON;
	--SET DEBUG FILE TO  '/tmp/adrian/sp_generaarchivocobranzaaxtel.out';
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
		LET cAnio = LPAD(SUBSTRING(YEAR(dFecha_Hoy ::DATE) FROM 3 FOR 2), 2, '0'); 
		LET cAnio2 = YEAR(dFecha_Hoy ::DATE); 
		
		
				
		
		--SELECCIONA LA RUTA DONDE SE GUARDARA EL ARCHIVO
		SELECT TRIM(ruta_archivo_cobranza )|| TRIM(nombre_archivo_cobranza)
		INTO cRutaArchAxtel
		FROM "informix".sac_convenios
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;
		
		LET cRutaArchAxtel = REPLACE(cRutaArchAxtel,'DD',cDia);	
		LET cRutaArchAxtel = REPLACE(cRutaArchAxtel,'MM',cMes);
		LET cRutaArchAxtel = REPLACE(cRutaArchAxtel,'AA',cAnio);
		
		--Borramos evidencia de archivo generado anteriormente (En caso de existir)
		LET cStmt = 'rm -f ' || cRutaArchAxtel;
		SYSTEM cStmt;
		
		--OBTENGO VALOR DE DIAS DE GRACIA
		SELECT valor
		INTO   vDias
		FROM   "informix".sac_param
		WHERE  empresa   = '001'
		AND    cod_param = '118';
		
		--OBTENGO EL TIPO DE MOVIMIENTO
		SELECT movimiento, tipomovimiento
		INTO   cMovimiento, cTipoMovimiento
		FROM   sac_servicios_cpl
		WHERE  numcategoria = cCategoria
		AND    numconvenio  = cConvenio;

		--Reviso si existe archivo importado correctamente del dÃ­a
		IF (SELECT COUNT(*)
			FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
			WHERE  movimiento = cMovimiento
			AND    tipomovimiento = cTipoMovimiento
			AND    st_conciliado = '1') > 0 THEN
			LET iFlagCopp = 1;
		END IF;
		
			

		FOREACH

			SELECT fecha_pago,
				LPAD(DAY(fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(fecha_pago::DATE), 4, '0'),
				case when origen = 'CPL' then NVL(sucursal_cpl,'') else NVL(id_sucursal,'') end,
				NVL(folio_suc,''),
				NVL(referencia1,''),
				NVL(importe_pago,0),
				NVL(flag_confirmacion_central,0),
				NVL(flag_confirmacion_sucursal,0)
				INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM "informix".sac_movimientoshistorial
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio
				AND fecha_pago > dFechaIni
				AND fecha_pago <= dFecha_Hoy
				AND status_cancelado <> 'S'
				AND (flag_confirmacion_central = 1
				OR flag_confirmacion_sucursal = 1)
				AND origen                    != "CPL"				

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
				END IF;
				
				LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
				LET iNumPagos = iNumPagos + 1;

				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || cTpoOperacion || ' ,' || 'TDA ' || RPAD(cSucursal,21,' ') || ',' || cAnioPago || cMesPago || cDiaPago || ',' || '00000' || ',' || SUBSTR(cReferencia1,1,8) || SUBSTR(cReferencia1,9,8) || '000000000' || ',' || SUBSTR(cReferencia1,17,1) || LPAD(iRelleno,24,0) || ',' || LPAD(iImporte_Pago,16,0) || '" >> ' || cRutaArchAxtel;
				SYSTEM cStmt;
		END FOREACH;
		
		IF iFlagCopp = 1 THEN
		
			FOREACH
				--Solo obtengo aquellos registros que estÃ¡n conciliados
				SELECT sm.fecha_pago,
				LPAD(DAY(sm.fecha_pago::DATE), 2, '0'),
				LPAD(MONTH(sm.fecha_pago::DATE), 2, '0'),
				LPAD(YEAR(sm.fecha_pago::DATE), 4, '0'),
				case when origen = 'CPL' then NVL(sm.sucursal_cpl,'') else NVL(sm.id_sucursal,'') end,
				NVL(sm.folio_suc,''),
				NVL(sm.referencia1,''),
				NVL(sm.importe_pago,0),
				NVL(sm.flag_confirmacion_central,0),
				NVL(sm.flag_confirmacion_sucursal,0)
				INTO dFechaPago,cDiaPago,cMesPago,cAnioPago,cSucursal,cFolio,cReferencia1,iImporte_Pago,iFlagCen,iFlagSuc
				FROM bdisac:"informix".sac_movimientoshistorial sm,
					 bdisac:"informix".sac_conciliacion_bcpl_cpl sc
				WHERE    sm.numcategoria     = cCategoria
				AND	     sm.numconvenio      = cConvenio
				AND      sm.fecha_pago       > dFechaIni - vDias
				AND      sm.fecha_pago       <= dFecha_Hoy
				AND      sm.status_cancelado <> 'S'
				AND      sm.origen           = "CPL"
				AND      sm.folio_suc        = sc.foliosucursal
				AND      sm.fecha_pago       = sc.fechapago
				AND      (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)
				AND      sc.st_conciliado           = 1
				ORDER BY sm.fecha_pago DESC

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
				END IF;
				
				LET iTotal_Pago = iTotal_Pago + iImporte_Pago ;
				LET iNumPagos = iNumPagos + 1;

				--IMPRIME RENGLON DE LAS OPERACIONES
				LET cStmt = 'echo "' || cTpoOperacion || ' ,' || 'TDA ' || RPAD(cSucursal,21,' ') || ',' || cAnioPago || cMesPago || cDiaPago || ',' || '00000' || ',' || SUBSTR(cReferencia1,1,8) || SUBSTR(cReferencia1,9,8) || '000000000' || ',' || SUBSTR(cReferencia1,17,1) || LPAD(iRelleno,24,0) || ',' || LPAD(iImporte_Pago,16,0) || '" >> ' || cRutaArchAxtel;
				SYSTEM cStmt;

			END FOREACH;
			
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
		
		--IMPRIME EL RENGLON DE TOTAL		
		LET cTpoOperacion = '2';
		LET cStmt = 'echo "' || cTpoOperacion || ' ,' || 'REGISTRO DE CONTROL      ' || ',' || cAnio2 || cMEs || cDia || ',' || '00000' || ',' || LPAD(iNumPagos,25,0) || ',' || LPAD(iRelleno,25,0) || ',' || LPAD(iTotal_Pago,16,0) || '" >> ' || cRutaArchAxtel;
		SYSTEM cStmt;		
		
		--ACTUALIZA LA FECHA DEL ULTIMO ARCHIVO GENERADO
		UPDATE "informix".sac_controlarchivoscobranza
		SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
;