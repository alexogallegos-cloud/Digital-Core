CREATE PROCEDURE "informix".sp_generaarchivocobranzacp(cId_convenio CHAR(5))

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
	
		--SET DEBUG FILE TO '/informix/noe/sp_generaarchivocobranzacp.out';
		--TRACE ON;
	
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
			FROM bdisac:"informix".sac_movimientosdetallehistorial a, bdisac:"informix".sac_movimientoshistorial b
			WHERE a.fecha::date > dFechaIni
			AND a.fecha::date <= dFecha_Hoy
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
					INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
					VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFecha_Pago,current);
					LET iCuantos = 0;	
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

CREATE PROCEDURE "informix".sp_generaarchivocobranzadepinfonavit(cId_Convenio CHAR(5))

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
	DEFINE cReferencia1 CHAR(27);
	DEFINE iImporte_Pago DECIMAL(20,2);
	DEFINE cIva INTEGER;
	DEFINE cComision INTEGER;
	DEFINE cSucursal CHAR(5);
	DEFINE cDiaPag CHAR(2);
	DEFINE cMesPag CHAR(2);
    DEFINE cAnioPag CHAR(4);
    DEFINE cFlagCen INTEGER;
    DEFINE cFlagSuc INTEGER;
	DEFINE cFolio CHAR(16);
	DEFINE dFecha_Pago DATE;
	DEFINE iCuantos INTEGER;
	DEFINE cStmt CHAR(250);
	DEFINE vContador INTEGER;
	DEFINE iTotalPagos INTEGER;
	DEFINE cFecha_Insert CHAR(6);
	DEFINE cforma_pago CHAR(1);
	DEFINE iTotalIva INTEGER;
	DEFINE iTotalComision INTEGER;
	DEFINE cCodigo_postal CHAR(5);
	DEFINE cDiferenciador CHAR(5);
	DEFINE cSuma_abonos DECIMAL(20,2);
	DEFINE cSuma_cargos INTEGER;
	DEFINE cNum_operaciones_cargos INTEGER;
	DEFINE cNum_operaciones_abonos INTEGER;
	DEFINE iImportePago VARCHAR(25);
	DEFINE cSumaAbonos VARCHAR(25);
		
	--SET DEBUG FILE TO '/informix/noe/sp_generaarchivocobranzadepinfonavit.out';
	--TRACE ON;
	
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
	LET cSucursal = '';
	LET cDiaPag = '';
	LET cMesPag = '';
    LET cAnioPag = '';
	LET cFlagCen = 0; 
	LET cFlagSuc = 0;
	LET cFolio = '';
	LET dFecha_Pago = MDY('01','01','1900');
	LET	iCuantos = 0;
	LET cStmt = '';
	LET vContador = 0;
	LET iTotalPagos = 0;
	LET cFecha_Insert = "";
	LET cforma_pago = "";
	LET cIva = 0;
	LET cComision = 0;
	LET iTotalIva = 0;
	LET iTotalComision = 0;
	LET cCodigo_postal = '';
	LET cDiferenciador = '';
	LET cSuma_abonos = 0;
	LET cSuma_cargos = 0;
	LET cNum_operaciones_cargos = 0;
	LET cNum_operaciones_abonos = 0;
	LET iImportePago = '';
	LET cSumaAbonos = '';
	
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
		LET cSuma_cargos = 0;
		LET cNum_operaciones_cargos = 0;
		LET cNum_operaciones_abonos = 0;
		
       
        FOREACH
            
            SELECT referencia1, importe_pago, LPAD(id_sucursal,4,'0'), LPAD(DAY(fecha_pago::DATE), 2, '0'), LPAD(MONTH(fecha_pago::DATE), 2, '0'),	LPAD(YEAR(fecha_pago::DATE), 4, '0'),
			     flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago,forma_pago, to_char(extend(fecha_insert, hour to second),'%H%M%S') as fecha_insert 
	        INTO  cReferencia1,  iImporte_Pago, cSucursal, cDiaPag, cMesPag, cAnioPag, cFlagCen, cFlagSuc, cFolio, dFecha_Pago,cforma_pago,cFecha_Insert
            FROM bdisac:"informix".sac_movimientoshistorial
            WHERE numcategoria = cCategoria
            AND numconvenio = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S'
            AND (flag_confirmacion_central = 1
	        OR flag_confirmacion_sucursal = 1)
			ORDER BY fecha_insert
			
			--Se obtiene el codigo postal de la sucursal
			SELECT cp INTO cCodigo_postal FROM bdinteg:si_ptf WHERE id_ptf = cSucursal AND tipo <> 'C';
			
               
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
					LET iCuantos = 0;	
              END IF;
            END IF;
			
			LET cSuma_abonos = cSuma_abonos + iImporte_Pago;
			LET cNum_operaciones_abonos = cNum_operaciones_abonos + 1;
			LET vContador = vContador + 1;
			--Se genera el encabezado
			IF vContador = 1 THEN
				LET cStmt = 'echo "' || '1' || '137' || LPAD(YEAR(dFecha_Hoy::DATE), 4, '0') || LPAD(MONTH(dFecha_Hoy::DATE), 2, '0') || LPAD(DAY(dFecha_Hoy::DATE), 2, '0') ||'" >> ' || cRutaArch;
				SYSTEM cStmt;
			END IF;	
			--Se genera el detalle
			LET iImportePago = iImporte_Pago;
            LET cStmt = 'echo "' ||'2'|| '0000000000' || LPAD(TRIM(cSucursal),10,'0') || LPAD(TRIM("Efectivo"), 25, '0') || 
			TRIM(NVL(cCodigo_postal, "00000")) || LPAD(YEAR(dFecha_Pago::DATE),4,'0') || LPAD(MONTH(dFecha_Pago::DATE), 2, '0') || LPAD(DAY(dFecha_Pago::DATE), 2, '0') || 
				'0000000' || '00000000.00' ||
				LPAD(TRIM(iImportePago), 11, '0') || '00000000.00' || LPAD(trim(cReferencia1), 27, '0') ||
				'000' || LPAD(TRIM(cFolio),20,'0') ||'" >> ' || cRutaArch;    --LPAD(iImporte_Pago,11,'0')  TRIM(LPAD(DECIMAL(FLOAT(iImporte_Pago)),8,'0')
            SYSTEM cStmt;
			
			
        END FOREACH;
		--Se genera la parte final del archivo
		LET cSumaAbonos = cSuma_abonos;
		IF vContador > 0 THEN 
			LET cStmt = 'echo "' || '3' || '00000000.00' || LPAD('00000000.00', 11, '0') || 
			LPAD('00000', 5, '0') || LPAD(TRIM(cSumaAbonos), 11, '0') || 
			LPAD(cNum_operaciones_abonos, 5,'0') || LPAD(TRIM(cSumaAbonos), 11, '0') || '" >> ' || cRutaArch;
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