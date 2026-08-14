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