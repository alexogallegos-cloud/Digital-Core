CREATE PROCEDURE "informix".sp_conciliaciontotalporconvenio(cConvenio CHAR(5), dFechaIni DATE, dFechaFin DATE)
    RETURNING
    CHAR(5)         AS retorno,
    CHAR(40)        AS nomconvenio,
    DATE            AS fecha_pago,
    DECIMAL(16,2)   AS importe_archivo,
    CHAR(30)        AS cuenta_cheques,
    DECIMAL(16,2)   AS importe_cheq,
    CHAR(30)        AS cuenta_contable,
    DECIMAL(16,2)   AS importe_conta;

    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
    DEFINE cConveniosNoConciliables  CHAR(100);
    DEFINE cCodRet              CHAR(5);
    DEFINE cNomConvenio         CHAR(40);
    DEFINE cConv 		        CHAR(3);
    DEFINE cCateg       	    CHAR(2);
    DEFINE dFecha_pago          DATE;
    DEFINE deImporte_archivo    DECIMAL(16,2);
    DEFINE cCuenta_cheques      CHAR(30);
    DEFINE deImporte_cheq       DECIMAL(16,2);
    DEFINE cCuenta_contable     CHAR(30);
    DEFINE deImporte_conta      DECIMAL(16,2);
    DEFINE iTransCargoCuenta    INTEGER;
    DEFINE mCargoCuenta         MONEY(16,2);
    DEFINE mCargoEfectivo       MONEY(16,2);
    DEFINE cNumTransaccEfec     CHAR(4);
	DEFINE cNumCargoClien		CHAR(4);
    DEFINE dFechaHoy            DATE;
    DEFINE iProceso_automatico  INTEGER;
    DEFINE vconsmovhis          CHAR(10);
    DEFINE vconsmovhisold       CHAR(10);
	DEFINE mCargoCuentaCred     MONEY(16,2);
	DEFINE cNumCategoria		CHAR(2);
	DEFINE cNumConvenio			CHAR(3);
	DEFINE dFechaTabla			DATE;	
	DEFINE cTranCredPGDF   	    CHAR(5);
	DEFINE cTranCredPCP   	    CHAR(5);
	DEFINE cTranCredPEDOF   	CHAR(5);

    LET cCodRet  =   "00000";
    LET cNomConvenio  = "";
    LET cConv   = "";
    LET cCateg  = "";
    LET dFecha_pago  = "01-01-1990";
    LET deImporte_archivo = 0;
    LET cCuenta_cheques   = "";
    LET deImporte_cheq    = 0;
    LET cCuenta_contable  = "";
    LET deImporte_conta   = 0;
    LET dFecha_pago  = dFechaIni;
    LET iTransCargoCuenta = 0;
    LET mCargoCuenta      = 0;
    LET mCargoEfectivo    = 0;
	LET cNumCargoClien	  = '';
    LET cNumTransaccEfec  = '';
    LET cConveniosNoConciliables = '';
    LET dFechaHoy = '01-01-1900';
    LET iProceso_automatico  = 0;
	LET mCargoCuentaCred  	 = 0;
	LET cNumCategoria		= '';
	LET cNumConvenio		= '';
	LET dFechaTabla			= '';
	LET cTranCredPGDF       = '';
	LET cTranCredPCP		= '';
	LET cTranCredPEDOF      = '';
	
	--SET DEBUG FILE TO  '/informix/adrian/sp_conciliaciontotalporconvenio_aia.out';
	--TRACE ON;
		
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_ConciliacionTotalPorConvenio");
                RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, deImporte_cheq, cCuenta_contable, deImporte_conta;
            END IF;
        END EXCEPTION;
		
		SELECT MIN (fecha_pago)
		INTO dFechaTabla
		FROM bdisac:"informix".sac_conciliaciontotalporconvenio;
		
		SELECT valor INTO cTranCredPEDOF FROM bdisac:"informix".sac_param WHERE cod_param = '25';
        IF cConvenio = "" OR LENGTH(cConvenio) <> 5 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, deImporte_cheq, cCuenta_contable, deImporte_conta;
        ELSE		
			IF dFechaIni>=dFechaTabla THEN	
				--Nuevo Proceso utilizando la tabla sac_conciliaciontotalporconvenio
				IF cConvenio = "00000" THEN -- Todos los convenios
					SET ISOLATION TO DIRTY READ;
					FOREACH
						-- Obtiene Nombre de Convenio
						SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
						       NVL(cuenta_prestadora,'')
						  INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, cCuenta_cheques						 
						  FROM bdisac:"informix".sac_convenios
						 WHERE numcategoria||numconvenio <> '08002' 
                         UNION ALL
						SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
						       NVL(valor,'')
						  FROM bdisac:"informix".sac_convenios, bdisac:sac_param
                         WHERE cod_param IN ('30','31','32','33','34')
                           AND numcategoria||numconvenio = '08002' 
						IF cConvenio NOT IN ('07001', '07002', '07003') THEN
							WHILE dFecha_pago <= dFechaFin
								IF cConvenio <> '08002' THEN
									-- Obtiene el Monto Total de los Movimientos 
									SELECT NVL(SUM(importe_archivo), 0) INTO deImporte_archivo
									  FROM bdisac:"informix".sac_conciliaciontotalporconvenio
									 WHERE numcategoria = cCateg AND numconvenio = cConv
									   AND fecha_pago = dFecha_pago;										
									
									-- Obtiene el Monto Total de los Movimientos de cheques 
									SELECT NVL(SUM(importe_cheq), 0) INTO mCargoCuenta
									  FROM bdisac:"informix".sac_conciliaciontotalporconvenio 
									 WHERE numcategoria = cCateg AND numconvenio = cConv
									   AND fecha_pago = dFecha_pago;									
								ELSE
                                    -- Obtiene el Monto Total de los Movimientos 
                                    SELECT NVL(SUM(importe_archivo), 0) 
                                      INTO deImporte_archivo
                                      FROM bdisac:"informix".sac_conciliaciontotalporconvenio
                                     WHERE numcategoria = cCateg 
                                       AND numconvenio = cConv
                                       AND fecha_pago = dFecha_pago
                                       AND cuenta_cheques = cCuenta_cheques;	

                                    -- Obtiene el Monto Total de los Movimientos de cheques 
                                    SELECT NVL(SUM(importe_cheq), 0) 
                                      INTO mCargoCuenta
                                      FROM bdisac:"informix".sac_conciliaciontotalporconvenio 
                                     WHERE numcategoria = cCateg AND numconvenio = cConv
                                       AND fecha_pago = dFecha_pago
                                       AND cuenta_cheques = cCuenta_cheques;		
								END IF;
									
								RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta
								WITH RESUME;
								LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;																
							END WHILE;
						END IF;						
						LET dFecha_pago  = dFechaIni;					
					END FOREACH;
				ELSE-- Un Solo Convenio
					SET ISOLATION TO DIRTY READ;
					LET cNumCategoria = SUBSTRING(cConvenio FROM 1 FOR 2);
					LET cNumConvenio  = SUBSTRING(cConvenio FROM 3 FOR 3);
					-- Obtiene Nombre de Convenio
				 FOREACH
 					    SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
						       NVL(cuenta_prestadora,'')
						  INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, cCuenta_cheques						 
						  FROM bdisac:"informix".sac_convenios
						 WHERE numcategoria||numconvenio <> '08002'
						   AND numcategoria = cNumCategoria 
					       AND numconvenio = cNumConvenio
                         UNION ALL
						SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
						       NVL(valor,'')
						  FROM bdisac:"informix".sac_convenios, bdisac:sac_param
                         WHERE cod_param IN ('30','31','32','33','34')
                           AND numcategoria||numconvenio = '08002'
				           AND numcategoria = cNumCategoria 
					       AND numconvenio = cNumConvenio
					
					WHILE dFecha_pago <= dFechaFin
					   IF cConvenio NOT IN ('07001', '07002', '07003') THEN
						   IF cConvenio <> '08002' THEN
							-- Obtiene el Monto Total de los Movimientos 
								SELECT NVL(SUM(importe_archivo), 0) INTO deImporte_archivo
								  FROM bdisac:"informix".sac_conciliaciontotalporconvenio
								 WHERE numcategoria = cCateg 
								   AND numconvenio = cConv
								   AND fecha_pago = dFecha_pago;
									
							-- Obtiene el Monto Total de los Movimientos de cheques 
								SELECT NVL(SUM(importe_cheq), 0) INTO mCargoCuenta
								  FROM bdisac:"informix".sac_conciliaciontotalporconvenio 
								 WHERE numcategoria = cCateg 
								   AND numconvenio = cConv
								   AND fecha_pago = dFecha_pago;	
							ELSE
							-- Obtiene el Monto Total de los Movimientos 
								SELECT NVL(SUM(importe_archivo), 0) 
								  INTO deImporte_archivo
								  FROM bdisac:"informix".sac_conciliaciontotalporconvenio
								 WHERE numcategoria = cCateg 
								   AND numconvenio = cConv
								   AND fecha_pago = dFecha_pago
								   AND cuenta_cheques = cCuenta_cheques;	

								-- Obtiene el Monto Total de los Movimientos de cheques 
								SELECT NVL(SUM(importe_cheq), 0) 
								  INTO mCargoCuenta
								  FROM bdisac:"informix".sac_conciliaciontotalporconvenio 
								 WHERE numcategoria = cCateg AND numconvenio = cConv
								   AND fecha_pago = dFecha_pago
								   AND cuenta_cheques = cCuenta_cheques;		
							END IF;
						RETURN cCodRet, cNomConvenio,  dFecha_pago, deImporte_archivo,  cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta																	
						WITH RESUME;
						LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;
						ELSE
							LET cNomConvenio = '';
							RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta																	
							WITH RESUME;
							LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;
						END IF;
					END WHILE;					
				LET dFecha_pago = dFechaIni;				
				END FOREACH;			
			END IF;
				
			ELSE
				--Proceso anterior consultando los movimiento
				SELECT valor INTO vconsmovhis FROM bdicheq:"informix".sc_param WHERE codparam = 'fechcon_movhis' AND  empresa = '001';				
				SELECT valor INTO cTranCredPGDF FROM bdisac:"informix".sac_param WHERE cod_param = '87040';
				--HOMOLOGACION CLUB DE PROTECCION COPPEL
				SELECT valor INTO cTranCredPCP FROM bdisac:"informix".sac_param WHERE cod_param = 82;
				
				IF cConvenio = "00000" THEN -- Todos los convenios
					SET ISOLATION TO DIRTY READ;
					FOREACH
						-- Obtiene Nombre de Convenio
						SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
						   NVL(cuenta_prestadora,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), NVL(trans_cen_efectivo_cliente,''), NVL(trans_cen_cargo_cliente,'')
						INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, cCuenta_cheques, 
							 iProceso_automatico, iTransCargoCuenta, cNumTransaccEfec, cNumCargoClien
						FROM bdisac:"informix".sac_convenios 
						IF cConvenio NOT IN ('07001', '07002', '07003') THEN 
							WHILE dFecha_pago <= dFechaFin
							
								-- Obtiene el Monto Total de los Movimientos 
								SELECT NVL(SUM(importe_pago), 0) INTO deImporte_archivo
								FROM bdisac:"informix".sac_movimientoshistorial
								WHERE numcategoria = cCateg AND numconvenio = cConv
									AND fecha_pago = dFecha_pago
									AND status_cancelado = 'N'
									AND flag_confirmacion_central = 1
									AND flag_confirmacion_sucursal = 1;
								
								IF dFecha_pago >= vconsmovhis THEN
								-- Obtiene el Monto Total de los Movimientos de cheques 
									IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis 
										WHERE fech_alt = dFecha_pago
											AND cancelad <> 'S' AND transacc IN(cNumCargoClien, cNumTransaccEfec)
											AND cuenta = cCuenta_cheques;
									ELSE							
		--	2014.10.09 FRG-i	Se controlan totales por convenio Abonos Coppel y Club Protección.
										IF cConvenio = "01002" THEN
											SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
											FROM bdicheq:"informix".sc_movhis 
											WHERE fech_alt = dFecha_pago
											AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
											AND cuenta = cCuenta_cheques;
										ELSE
											IF cConvenio = "08001" THEN
												SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
												FROM bdicheq:"informix".sc_movhis 
												WHERE fech_alt = dFecha_pago
												AND cancelad <> 'S' AND transacc IN (cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
												AND cuenta = cCuenta_cheques;
											ELSE
												SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
												FROM bdicheq:"informix".sc_movhis 
												WHERE fech_alt = dFecha_pago
												AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec)
												AND cuenta = cCuenta_cheques;
											END IF
											
										END IF;					
		--	2014.10.09 FRG-f																	
									END IF;
								ELSE
								-- Obtiene el Monto Total de los Movimientos de cheques old
									IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis_old 
										WHERE fech_alt = dFecha_pago
											AND cancelad <> 'S' AND transacc IN (cNumCargoClien, cNumTransaccEfec)
											AND cuenta = cCuenta_cheques;
									ELSE
		--	2014.10.09 FRG-i	Se controlan totales por convenio Abonos Coppel y Club Protección.
										IF cConvenio = "01002" THEN
											SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
											FROM bdicheq:"informix".sc_movhis_old 
											WHERE fech_alt = dFecha_pago
											AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
											AND cuenta = cCuenta_cheques;									
										ELSE
											IF cConvenio = "08001" THEN
												SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
												FROM bdicheq:"informix".sc_movhis_old 
												WHERE fech_alt = dFecha_pago
												AND cancelad <> 'S' AND transacc IN(cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
												AND cuenta = cCuenta_cheques;
											ELSE
												SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
												FROM bdicheq:"informix".sc_movhis 
												WHERE fech_alt = dFecha_pago
												AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec)
												AND cuenta = cCuenta_cheques;
											END IF;									
										END IF;					
									END IF;						
								END IF;	

								RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta
								WITH RESUME;
								LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;							
							END WHILE;
						END IF;
						LET dFecha_pago = dFechaIni;
					END FOREACH;
				ELSE-- Un Solo Convenio
					SET ISOLATION TO DIRTY READ;
					LET cNumCategoria				= SUBSTRING(cConvenio FROM 1 FOR 2);
					LET cNumConvenio				= SUBSTRING(cConvenio FROM 3 FOR 3);
					-- Obtiene Nombre de Convenio
					SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
						   NVL(cuenta_prestadora,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), NVL(trans_cen_efectivo_cliente,''), NVL(trans_cen_cargo_cliente,'')
					INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable,
						 cCuenta_cheques, iProceso_automatico, iTransCargoCuenta, cNumTransaccEfec, cNumCargoClien
					FROM bdisac:"informix".sac_convenios
					WHERE numcategoria = cNumCategoria AND numconvenio = cNumConvenio;

						WHILE dFecha_pago <= dFechaFin
							IF cConvenio NOT IN ('07001', '07002', '07003') THEN  					
								-- Obtiene el Monto Total de los Movimientos
								SELECT NVL(SUM(importe_pago), 0) INTO deImporte_archivo
								FROM bdisac:"informix".sac_movimientoshistorial
								WHERE numcategoria = cCateg AND numconvenio = cConv
									AND fecha_pago = dFecha_pago
									AND status_cancelado = 'N'
									AND flag_confirmacion_central = 1
									AND flag_confirmacion_sucursal = 1;
								IF dFecha_pago >= vconsmovhis THEN
								-- Obtiene el Monto Total de los Movimientos de cheques 
									IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis 
										WHERE fech_alt = dFecha_pago
											AND cancelad <> 'S' AND transacc IN(cNumCargoClien, cNumTransaccEfec)
											AND cuenta = cCuenta_cheques;
									ELSE
		--	2014.10.09 FRG-i	Se controlan totales por convenio Abonos Coppel y Club Protección.
										IF cConvenio = "01002" THEN
											SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
											FROM bdicheq:"informix".sc_movhis 
											WHERE fech_alt = dFecha_pago
											AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
											AND cuenta = cCuenta_cheques;
										ELSE
											IF cConvenio = "08001" THEN
												SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
												FROM bdicheq:"informix".sc_movhis 
												WHERE fech_alt = dFecha_pago
												AND cancelad <> 'S' AND transacc IN(cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
												AND cuenta = cCuenta_cheques;
											ELSE
												SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
												FROM bdicheq:"informix".sc_movhis 
												WHERE fech_alt = dFecha_pago
												AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec)
												AND cuenta = cCuenta_cheques;
											END IF;
										END IF;					
									END IF;
								ELSE
								-- Obtiene el Monto Total de los Movimientos de cheques old
									IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis_old 
										WHERE fech_alt = dFecha_pago
											AND cancelad <> 'S' AND transacc IN(cNumCargoClien, cNumTransaccEfec)
											AND cuenta = cCuenta_cheques;
									ELSE
		--	2014.10.09 FRG-i	Se controlan totales por convenio Abonos Coppel y Club Protección.
										IF cConvenio = "01002" THEN
											SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
											FROM bdicheq:"informix".sc_movhis_old
											WHERE fech_alt = dFecha_pago
											AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
											AND cuenta = cCuenta_cheques;
										ELSE
											IF cConvenio = "08001" THEN
												SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
												FROM bdicheq:"informix".sc_movhis_old 
												WHERE fech_alt = dFecha_pago
												AND cancelad <> 'S' AND transacc IN(cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
												AND cuenta = cCuenta_cheques;
											ELSE
												SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
												FROM bdicheq:"informix".sc_movhis_old 
												WHERE fech_alt = dFecha_pago
												AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec)
												AND cuenta = cCuenta_cheques;
											END IF;
										END IF;						
									END IF;	
								END IF;	
								RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta
								WITH RESUME;
								LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;	
							ELSE
								LET cNomConvenio = "";
								RETURN cCodRet, cNomConvenio,  dFecha_pago,  deImporte_archivo,  cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta
								WITH RESUME;
								LET dFecha_pago =  dFecha_pago + 1 UNITS DAY;
							END IF;
						END WHILE;											
					LET dFecha_pago = dFechaIni;
				END IF;			
			END IF;
        END IF;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : Jesus Alberto Moreno',
'FECHA  : Febrero del 2009',
'VERSION: 20090203.1308',
'BD     : bdisac',
'MODIFICACION: 12/Febrero/2009',
'AUTOR: Raúl René Ruiz',
'MODIFICACION: 20/Abril/2009',
'AUTOR: Raúl René Ruiz',
'Se modifica para que utilize los indices existentes en produccion',
'de las tablas co_historico y co_mensual de la bdicont',
'MODIFICACION: 27/Mayo/2009',
'AUTOR: José Angel López Adams',
'Se modifica para que se contemplen los movimientos con Naturaleza C',
'Se implemento el uso de una tabla temporal, para que la consulta de los movimientos',
'se haga de esta tabla, que previamente se cargo con informacion exclusiva de movimientos de servicios',
'de las tablas co_mensual y co_historico de la BD bdicont',
'MODIFICACION: Jesús Antonio Bastidas López',
'Se modifica para que no tome en cuenta en la conciliación los convenios de DineroYa',
'Se cambia la consulta al sysmaster debido a que si la tabla no tiene registro pero existe truena el proceso',
'Fecha:29/03/2010',
'VERSION: 20100329.0907',
'FECHA: 18/11/2010',
'AUTOR: Manuel Ramos Figueroa',
'MODIFICACION: Se modifica para que consulte las tablas co_sdodias y co_histsdodias en lugar de las co_mensual y co_historico',
'AUTOR: Dulce Ramirez',
'MODIFICACION: Se modifica para que se tome los parametros de la tabla sac_convenios',
'Fecha: 14/09/2010',
'VERSION: 20100914.1721',
'AUTOR: Edgar Ivan Rochin Rocha',
'MODIFICACION: Se modifica para que se sumen los montos para la cuenta concentradora de BTS unicamente, filtrado por transacc',
'Fecha: 26/05/2011',
'VERSION: 20110526.1747',
'AUTOR: FRG',
'MODIFICACION: Se optimiza consulta para obtener las cuentas contables de la tabla bdisac:sac_convenios y no usar la bdisac:sac_param',
'Fecha: 01/02/2013',
'MODIFICA : Martha Aguirre',
'DESCRIPCION: Se agrega búsqueda de monto para el movimiento de cargo en cuenta de crédito para el cIdConvenio 8001',
'             "Pago de Servicios del Gobierno del Distrito Federal',
'VERSION DE CAMBIO: 20130109.1030',
'MODIFICA : Eduardo Lopez',
'DESCRIPCION: Se agrega nuevo codigo para el monto de movimiento de cargo en cuenta de crédito para el cIdConvenio 8001',
'             "Pago de Servicios del Gobierno del Distrito Federal',
'VERSION DE CAMBIO: 20130910.1130',
'VERSION: 20130807.1225',
'AUTOR: Christian Echavarria',
'MODIFICACION: Se modifica para agregar transacciones de WU para obtener los montos de la cuenta concentradora',
'Fecha: 07/08/2013',
'AUTOR: Mario Gallardo',
'MODIFICACION: Se Homologa para agregar transacciones de WU para obtener los montos de la cuenta concentradora',
'Fecha: 07/08/2013',
'AUTOR: Eduardo Pineda Guzmán',
'MODIFICACION: Se optimizan las busquedas tanto en la tabla sac_movimientoshistorial, sc_movhis, sc_movhis_old',
'FECHA 09/01/2014',
'AUTOR: Rigoberto Gonzalez Llanes',
'MODIFICACION: Se Homologa para agregar transacciones del club de proteccion coppel',
'Fecha: 02/09/2014',
'AUTOR: FRG',
'MODIFICACION: Se separan montos totales cuenta concentradora Coppel para Abonos y Club de Protección.',
'Fecha: 10/09/2014';

CREATE PROCEDURE "informix".sp_sacreportesremesasnoconciliadaswu(pFecha_Inicio DATE, pFecha_Fin DATE, pUsuario CHAR(8),pConvenio CHAR(5))

RETURNING 
		CHAR(5)		AS RetCodigoRet,
		DATE    	AS RetFecha, 
		INTEGER 	AS RetServicios,
		INTEGER 	AS RetCheques, 
		INTEGER 	AS RetWUCaja, 
		CHAR(16)    AS RetDiferencia; 
		
		--DEFINICION DE VARIABLES 
		DEFINE iSqlError 			INTEGER;
		DEFINE cCodRet 				CHAR(5);
		DEFINE dFechaIni 			DATE;
		DEFINE dFechaFin 			DATE;
		DEFINE cCategoria 			CHAR(2);
		DEFINE cConvenio 			CHAR(3);
		
		DEFINE dRetfecha			DATE;
		DEFINE iRetservicios		INTEGER;
		DEFINE iRetcheques			INTEGER;
		DEFINE iRetwucaja			INTEGER;
		DEFINE cRetdiferencia		CHAR(16);
		
		--INICIALIZAMOS LAS VARIABLES
		LET iSqlError = 0; 
		LET cCodRet = '00000';			
		LET dFechaIni=CURRENT;
		LET dFechaFin = CURRENT;		
		LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
		LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);
		
		LET dRetfecha				= '';
		LET iRetservicios			= 0;
		LET iRetcheques				= 0;
		LET iRetwucaja				= 0;
		LET cRetdiferencia			= '';
		
		BEGIN
			ON EXCEPTION SET iSqlError
				IF iSqlError <> 0 THEN
					
					LET cCodRet = iSqlError;				
					RETURN cCodRet,dFechaIni,iRetservicios,iRetcheques,iRetwucaja,cRetdiferencia;	
				
				END IF;
			END EXCEPTION;			
			
			--SET DEBUG FILE TO  '/informix/adrian/sp_sacreportesremesasnoconciliadaswu.out';
			--TRACE ON;
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			IF (pFecha_Inicio = "" OR pFecha_Inicio IS NULL) OR (pFecha_Fin ="" OR pFecha_Fin IS NULL) OR (cConvenio = "" OR cConvenio IS NULL ) OR (cCategoria = "" OR cCategoria IS NULL ) THEN 
				LET cCodRet = '00001'; --Parametros vacios
				RETURN cCodRet,'','','','','';
			ELSE 	
			
				--Tomamos los valores de las fecha de los parametros
				LET dFechaIni = pFecha_Inicio;
				LET dFechaFin = pFecha_Fin;
				
				SET ISOLATION TO DIRTY READ;
						
				WHILE (dFechaIni <= dFechaFin)
						
					 FOREACH							 
						SELECT retfecha, retservicios, retcheques, retwucaja, retdiferencia
						INTO dRetfecha, iRetservicios, iRetcheques, iRetwucaja, cRetdiferencia
						FROM bdisac:"informix".sac_wu_remesasnoconciliadas
						WHERE retfecha = dFechaIni
						and numcategoria = cCategoria
						and numconvenio = cConvenio
						and rev = '0'

						RETURN cCodRet,dFechaIni,iRetservicios,iRetcheques,iRetwucaja,cRetdiferencia WITH RESUME;
						
					END FOREACH;								
					LET dFechaIni = dFechaIni + INTERVAL(1) DAY TO DAY;
				END WHILE;				
			
			END IF;			
		END
END PROCEDURE  
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener los totales para las transacciones PAGADAS de Servicio,Cheques,BTSCaja ',
'para el reporte de remesas no de WESTERN UNION, asu ves mostrar las diferencias si existen entre',
'cada una de las sumatorias',
'AUTOR :Eduardo Lopez cuevas',
'FECHA : 2013/07/08',
'VER.  :20130708.1735',
'DESCRIPCION: Se modifican condiciones para obtener los totales de la tabla sac_wu_pay',
'AUTOR: FRG',
'FECHA: 2014/03/07',
'VER.  :20140307.0900',
'EJECUTADO POR: repsac.exe (SIF).',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesremesasnoconciliadaswurev(pFecha_Inicio DATE, pFecha_Fin DATE, pUsuario CHAR(8),pConvenio CHAR(5))

RETURNING 
		CHAR(5)		AS RetCodigoRet,
		DATE    	AS RetFecha, 
		INTEGER 	AS RetServicios,
		INTEGER 	AS RetCheques, 
		CHAR(16)    AS RetDiferencia; 
		
		--DEFINICION DE VARIABLES 
		DEFINE iSqlError 			INTEGER;
		DEFINE cCodRet 				CHAR(5);
		DEFINE dFechaIni 			DATE;
		DEFINE dFechaFin 			DATE;
		DEFINE cCategoria 			CHAR(2);
		DEFINE cConvenio 			CHAR(3);
		
		DEFINE dRetfecha			DATE;
		DEFINE iRetservicios		INTEGER;
		DEFINE iRetcheques			INTEGER;
		DEFINE cRetdiferencia		CHAR(16);
		
		--INICIALIZAMOS LAS VARIABLES
		LET iSqlError = 0; 
		LET cCodRet = '00000';			
		LET dFechaIni=CURRENT;
		LET dFechaFin = CURRENT;		
		LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
		LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);
		
		LET dRetfecha				= '';
		LET iRetservicios			= 0;
		LET iRetcheques				= 0;		
		LET cRetdiferencia			= '';
		
		BEGIN
			ON EXCEPTION SET iSqlError
				IF iSqlError <> 0 THEN
					
					LET cCodRet = iSqlError;				
					RETURN cCodRet,dFechaIni,iRetservicios,iRetcheques,cRetdiferencia;	
				
				END IF;
			END EXCEPTION;			
			
			--SET DEBUG FILE TO  '/informix/adrian/sp_sacreportesremesasnoconciliadaswu.out';
			--TRACE ON;
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			IF (pFecha_Inicio = "" OR pFecha_Inicio IS NULL) OR (pFecha_Fin ="" OR pFecha_Fin IS NULL) OR (cConvenio = "" OR cConvenio IS NULL ) OR (cCategoria = "" OR cCategoria IS NULL ) THEN 
				LET cCodRet = '00001'; --Parametros vacios
				RETURN cCodRet,'','','','';
			ELSE 	
			
				--Tomamos los valores de las fecha de los parametros
				LET dFechaIni = pFecha_Inicio;
				LET dFechaFin = pFecha_Fin;
				
				SET ISOLATION TO DIRTY READ;
						
				WHILE (dFechaIni <= dFechaFin)
						
					 FOREACH							 
						SELECT retfecha, retservicios, retcheques, retdiferencia
						INTO dRetfecha, iRetservicios, iRetcheques, cRetdiferencia
						FROM bdisac:"informix".sac_wu_remesasnoconciliadas
						WHERE retfecha = dFechaIni
						and numcategoria = cCategoria
						and numconvenio = cConvenio
						and rev = '1'

						RETURN cCodRet,dFechaIni,iRetservicios,iRetcheques,cRetdiferencia WITH RESUME;
						
					END FOREACH;								
					LET dFechaIni = dFechaIni + INTERVAL(1) DAY TO DAY;
				END WHILE;				
			
			END IF;			
		END
END PROCEDURE  
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener los totales para las transacciones PAGADAS de Servicio,Cheques,BTSCaja ',
'para el reporte de remesas no de WESTERN UNION, asu ves mostrar las diferencias si existen entre',
'cada una de las sumatorias',
'AUTOR :Eduardo Lopez cuevas',
'FECHA : 2013/07/08',
'VER.  :20130708.1735',
'DESCRIPCION: Se modifican condiciones para obtener los totales de la tabla sac_wu_pay',
'AUTOR: FRG',
'FECHA: 2014/03/07',
'VER.  :20140307.0900',
'EJECUTADO POR: repsac.exe (SIF).',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reportebts_edocta_pba(pdFechaIni DATE, pdFechaFin DATE, pUsuario CHAR (9))

RETURNING
CHAR(10) AS fecha, 
CHAR(14) AS saldo_inicial,
CHAR(10) AS total_abonos,
CHAR(14) AS monto_total_abonos,
CHAR(10) AS total_cargos,
CHAR(14) AS monto_total_cargos,
CHAR(14) AS saldo_final,
CHAR(20) AS cuenta_concentradora,
CHAR(18) AS cuenta_clabe,
CHAR(5) AS cod_ret;

--***************************************************************************************************
-- DESCRIPCION:  GENERA REPORTE ESTADO DE CUENTA BTS
-- AUTOR : ROCHIN ROCHA EDGAR IVAN
-- FECHA : 2011/08/30
-- BD: BDISAC
-- SISTEMA : BTS
--***************************************************************************************************

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;
DEFINE vdFechaIni			DATE;
DEFINE vdFechaFin			DATE;
DEFINE vsFechaIni			CHAR(10);
DEFINE vsFechaAnt			CHAR(10);
DEFINE vsFechaParam         CHAR(10);
DEFINE vdFechaParam         DATE;
DEFINE vsAnioMes			CHAR(6);
DEFINE vsAnioMesAnt			CHAR(6);
DEFINE vsMes 			CHAR(6);
DEFINE vsCtaConcentradora	CHAR(20);
DEFINE vsCtaClabe			CHAR(20);
DEFINE vsNomTabla 			CHAR (30);


DEFINE vsFecha				CHAR(10);
DEFINE vsSaldoInicial		CHAR(14);
DEFINE vsTotalAbonos		CHAR(10);
DEFINE vsMontoTotalAbonos	CHAR(14);
DEFINE vsTotalCargos		CHAR(10);
DEFINE vsMontoTotalCargos	CHAR(14);
DEFINE vsSaldoFinal			CHAR(14);
DEFINE vsAnioInicio			char (4);
DEFINE vsAnioFin			CHAR(4);
DEFINE vsAniohoy			CHAR(4);
DEFINE vsMesIni				CHAR(4);	
DEFINE vsAnioMesIni			CHAR(14);
DEFINE vsAnioMesFin			CHAR(14);
DEFINE vdFechahoy			DATE;
--DEFINE vsql        char(200);
DEFINE vsNomTablaInicio     CHAR (30);
DEFINE vsNomTablaFin 	CHAR (30);
DEFINE iBandera 			INTEGER;
DEFINE vsSQL CHAR (1800) ;
DEFINE vsSQL1 CHAR (800);
DEFINE vsSQL2 CHAR (900) ;
DEFINE vsSQL3 CHAR (50) ;

LET vsSQL = '' ;
LET vsSQL1 = '' ;
LET vsSQL2 = '' ;
LET vsSQL3 = '' ;

LET vsNomTablaFin = ""; 
LET vsNomTablaInicio = "";
--LET vsql = "";
LET vsCodRet = "";
LET viSqlErr = 0;
LET vdFechaIni = CURRENT;
LET vdFechaFin = CURRENT;
LET vsFechaIni = "";
LET vsFechaAnt = "";
LET vsFechaParam = "";
LET vsAnioMes = "";
LET vsMes = "";
LET vsAnioMesAnt = "";
LET vsCtaConcentradora = "";
LET vsCtaClabe = "";

LET vsFecha = "";
LET vsSaldoInicial = "";
LET vsTotalAbonos = "0";
LET vsMontoTotalAbonos = "";
LET vsTotalCargos = "0";
LET vsMontoTotalCargos = "";
LET vsSaldoFinal = "";
LET vsAnioInicio		= "";
LET vsAnioFin		= "";
LET vsAniohoy		= "";
LET vsMes			= "";
LET vsAnioMesIni	= "";
LET vsAnioMesFin	= "";
LET vdFechahoy  =CURRENT;
LET vsNomTabla = "";
LET iBandera   = 0 ;

--SET DEBUG FILE TO "/respaldosbd/cris/sp_reportebts_edocta.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
		IF viSqlErr <> 0 THEN
			--RETURN vsFecha, vsSaldoInicial, vsTotalAbonos, vsMontoTotalAbonos, vsTotalCargos, vsMontoTotalCargos, vsSaldoFinal, vsCtaConcentradora, vsCtaClabe, viSqlErr;
			RETURN vsFechaIni, NVL(vsSaldoInicial, 0.00),  vsTotalAbonos, NVL(vsMontoTotalAbonos, 0.00), vsTotalCargos, NVL(vsMontoTotalCargos, 0.00), NVL(vsSaldoFinal, 0.00), NVL(vsCtaConcentradora,''), NVL(vsCtaClabe,''), viSqlErr;
		END IF;
	END EXCEPTION;

	--Verifica parametros nulos o en blanco.
IF( pdFechaIni == "" OR pdFechaIni IS NULL ) OR ( pdFechaFin == "" OR pdFechaFin IS NULL )THEN
	LET vsCodRet = "00001";
	--RETURN vsFecha, vsSaldoInicial, vsTotalAbonos, vsMontoTotalAbonos, vsTotalCargos, vsMontoTotalCargos, vsSaldoFinal, vsCtaConcentradora, vsCtaClabe, vsCodRet;
	RETURN vsFechaIni, NVL(vsSaldoInicial, 0.00),  vsTotalAbonos, NVL(vsMontoTotalAbonos, 0.00), vsTotalCargos, NVL(vsMontoTotalCargos, 0.00), NVL(vsSaldoFinal, 0.00), NVL(vsCtaConcentradora,''), NVL(vsCtaClabe,''), viSqlErr ;
ELSE
	--Se asignan a variables los parametros recibidos.
	LET vdFechaIni = pdFechaIni;
	LET vdFechaFin = pdFechaFin;
	--Se obtiene el numero de cuenta concentradora y numero de cuenta clabe para BTS.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	/*
	SELECT cuenta_prestadora INTO vsCtaConcentradora FROM bdisac:"informix".sac_convenios WHERE numcategoria = '07' AND numconvenio = '004';
	SELECT numcuentaclabe INTO vsCtaClabe FROM bdisac:"informix".sac_convenios WHERE numcategoria = '07' AND numconvenio = '004';
	*/
	SELECT cuenta_prestadora , numcuentaclabe INTO vsCtaConcentradora,vsCtaClabe
	FROM bdisac:"informix".sac_convenios WHERE numcategoria = '07' AND numconvenio = '004';	
	
	select valor INTO vsFechaParam FROM bdicheq:"informix".sc_param where codparam='fechcon_movhis';
	select fecha_hoy INTO vdFechahoy FROM bdicheq:"informix".sc_fechas WHERE empresa = '001';
		
	DELETE FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE USUARIO = pUsuario;
	
	LET vsAnioInicio = TRIM(SUBSTRING(vdFechaIni FROM 7 FOR 4));	
	LET vsAnioFin = TRIM(SUBSTRING(vdFechaFin FROM 7 FOR 4));	
	LET vsAniohoy =  TRIM(SUBSTRING(vdFechahoy FROM 7 FOR 4));	
	LET vsMesIni = TRIM(SUBSTRING(vdFechaIni FROM 1 FOR 2));
	LET vsAnioMesIni = TRIM(SUBSTRING(vdFechaIni FROM 7 FOR 4)) || TRIM(SUBSTRING(vdFechaIni FROM 1 FOR 2));
	LET vsAnioMesFin = TRIM(SUBSTRING(vdFechaFin FROM 7 FOR 4)) || TRIM(SUBSTRING(vdFechaFin FROM 1 FOR 2));
	
		
	LET vsSQL1 = 'echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; INSERT INTO sc_sdodiarioc_edocta(cuenta,aniomes,sucursal,capvig1,intprovnp1,capvig2,intprovnp2,capvig3,intprovnp3,'
	||'capvig4,intprovnp4,capvig5,intprovnp5,capvig6,intprovnp6,capvig7,intprovnp7,capvig8,intprovnp8,capvig9,intprovnp9,capvig10,intprovnp10,'
	||'capvig11,intprovnp11,capvig12,intprovnp12,capvig13,intprovnp13,capvig14,intprovnp14,capvig15,intprovnp15,capvig16,intprovnp16,capvig17,'
	||'intprovnp17,capvig18,intprovnp18,capvig19,intprovnp19,capvig20,intprovnp20,capvig21,intprovnp21,capvig22,intprovnp22,capvig23,'
	||'intprovnp23,capvig24,intprovnp24,capvig25,intprovnp25,capvig26,intprovnp26,capvig27,intprovnp27,capvig28,intprovnp28,capvig29,'
	||'intprovnp29,capvig30,intprovnp30,capvig31,intprovnp31,capvigacum,diacum,usuario)';

	LET vsSQL3= '" > /tmp/sc_sdodiarioc_edocta.sql';
		
		
	IF (vsAnioInicio  = vsAnioFin ) AND (vsMesIni <> '01' )THEN
			IF ( vsAnioInicio = vsAniohoy) THEN
				LET vsNomTabla  = "sc_sdodiarioc";
			ELSE
				LET vsNomTabla  =  "sc_sdodiarioc_" || vsAnioInicio;
			END IF ;
			
		LET vsMesIni = vsMesIni::INTEGER - 1;
        LET vsAnioMesIni =  vsAnioInicio || LPAD(vsMesIni::CHAR,2,'0') ;
		LET  vsAnioMesIni = vsAnioMesIni;		
			
		IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabid > 99 AND tabname = vsNomTabla) THEN      	
			LET vsSQL2 = 'SELECT cuenta,aniomes,sucursal,capvig1,intprovnp1,capvig2,intprovnp2,capvig3,intprovnp3,capvig4,intprovnp4,capvig5,'
			||'intprovnp5,capvig6,intprovnp6,capvig7,intprovnp7,capvig8,intprovnp8,capvig9,intprovnp9,capvig10,intprovnp10,capvig11,intprovnp11,'
			||'capvig12,intprovnp12,capvig13,intprovnp13,capvig14,intprovnp14,capvig15,intprovnp15,capvig16,intprovnp16,capvig17,intprovnp17,capvig18,'
			||'intprovnp18,capvig19,intprovnp19,capvig20,intprovnp20,capvig21,intprovnp21,capvig22,intprovnp22,capvig23,intprovnp23,capvig24,'
			||'intprovnp24,capvig25,intprovnp25,capvig26,intprovnp26,capvig27,intprovnp27,capvig28,intprovnp28,capvig29,intprovnp29,capvig30,'
			||'intprovnp30,capvig31,intprovnp31,capvigacum,diacum,'''||TRIM(pUsuario)||''' FROM bdicheq:"informix".'
			|| TRIM (vsNomTabla ) || ' WHERE cuenta = '''|| TRIM( vsCtaConcentradora ) ||''' AND aniomes BETWEEN ''' || TRIM(vsAnioMesIni) || ''' AND ''' || TRIM(vsAnioMesFin) || '''';
			
			LET vsSQL1 = TRIM(vsSQL1);
			LET vsSQL2 = TRIM (vsSQL2);
			LET vsSQL3 = TRIM(vsSQL3);		
			LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
			LET vsSQL = TRIM(vsSQL);
			SYSTEM  vsSQL ;
			LET vsSQL = '';
			LET vsSQL = 'dbaccess bdicheq /tmp/sc_sdodiarioc_edocta.sql';
			LET vsSQL = TRIM(vsSQL);
			SYSTEM vsSQL;
		END IF;
	ELSE
		
			
			IF (vsMesIni = '01') AND (vsAnioInicio  = vsAnioFin ) THEN
			
				LET vsAnioInicio = vsAnioInicio::INTEGER  - 1;
				LET vsAnioMesIni =  vsAnioInicio || '12' ;			
			
				IF (vsAnioFin = vsAniohoy ) THEN
					LET vsNomTablaInicio  =  "sc_sdodiarioc_" || vsAnioInicio;
					LET vsNomTablaFin =  "sc_sdodiarioc" ;
				ELSE
					LET vsNomTablaInicio  =  "sc_sdodiarioc_" || TRIM(vsAnioInicio);
					LET vsNomTablaFin =  "sc_sdodiarioc_" || TRIM(vsAnioFin) ;				
				END IF;
			ELSE		
				
				LET vsMesIni = vsMesIni::INTEGER - 1;
                LET vsAnioMesIni =  vsAnioInicio || LPAD(vsMesIni::CHAR,2,'0') ;
				LET vsAnioMesIni = vsAnioMesIni;
				IF (vsAnioFin <> vsAniohoy ) THEN
					LET vsNomTablaInicio  =  "sc_sdodiarioc_" || TRIM(vsAnioInicio);
					LET vsNomTablaFin =  "sc_sdodiarioc_" || TRIM(vsAnioFin) ;
				ELSE
					LET vsNomTablaInicio  =  "sc_sdodiarioc_" || TRIM(vsAnioInicio) ;
					LET vsNomTablaFin =  "sc_sdodiarioc";
				END IF;
				
			END IF;
			
			IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames   WHERE  tabid > 99 AND tabname = vsNomTablaInicio) THEN      
  			
				LET vsSQL2 = 'SELECT cuenta,aniomes,sucursal,capvig1,intprovnp1,capvig2,intprovnp2,capvig3,intprovnp3,capvig4,intprovnp4,capvig5,'
				||'intprovnp5,capvig6,intprovnp6,capvig7,intprovnp7,capvig8,intprovnp8,capvig9,intprovnp9,capvig10,intprovnp10,capvig11,intprovnp11,'
				||'capvig12,intprovnp12,capvig13,intprovnp13,capvig14,intprovnp14,capvig15,intprovnp15,capvig16,intprovnp16,capvig17,intprovnp17,capvig18,'
				||'intprovnp18,capvig19,intprovnp19,capvig20,intprovnp20,capvig21,intprovnp21,capvig22,intprovnp22,capvig23,intprovnp23,capvig24,'
				||'intprovnp24,capvig25,intprovnp25,capvig26,intprovnp26,capvig27,intprovnp27,capvig28,intprovnp28,capvig29,intprovnp29,capvig30,'
				||'intprovnp30,capvig31,intprovnp31,capvigacum,diacum, ''' || TRIM(pUsuario) || ''' FROM bdicheq:"informix".'
				|| TRIM (vsNomTablaInicio) || ' WHERE  cuenta = '''|| TRIM(vsCtaConcentradora ) ||''' AND aniomes BETWEEN ''' || TRIM(vsAnioMesIni) || ''' AND ''' || TRIM(vsAnioMesFin) || '''';
				
				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL2 = TRIM (vsSQL2);
				LET vsSQL3 = TRIM(vsSQL3);		
				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
				LET vsSQL = TRIM(vsSQL);
				SYSTEM  vsSQL ;
				LET vsSQL = '';
				LET vsSQL = 'dbaccess bdicheq /tmp/sc_sdodiarioc_edocta.sql';
				LET vsSQL = TRIM(vsSQL);
				SYSTEM vsSQL;
			END IF;
			
			IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames   WHERE  tabid > 99 AND tabname = vsNomTablaFin) THEN
				LET  vsSQL2 = "";
				LET vsSQL2 = 'SELECT cuenta,aniomes,sucursal,capvig1,intprovnp1,capvig2,intprovnp2,capvig3,intprovnp3,capvig4,intprovnp4,capvig5,'
				||'intprovnp5,capvig6,intprovnp6,capvig7,intprovnp7,capvig8,intprovnp8,capvig9,intprovnp9,capvig10,intprovnp10,capvig11,intprovnp11,'
				||'capvig12,intprovnp12,capvig13,intprovnp13,capvig14,intprovnp14,capvig15,intprovnp15,capvig16,intprovnp16,capvig17,intprovnp17,capvig18,'
				||'intprovnp18,capvig19,intprovnp19,capvig20,intprovnp20,capvig21,intprovnp21,capvig22,intprovnp22,capvig23,intprovnp23,capvig24,'
				||'intprovnp24,capvig25,intprovnp25,capvig26,intprovnp26,capvig27,intprovnp27,capvig28,intprovnp28,capvig29,intprovnp29,capvig30,'
				||'intprovnp30,capvig31,intprovnp31,capvigacum,diacum, ''' || TRIM(pUsuario) || ''' FROM bdicheq:"informix".'		
				|| TRIM(vsNomTablaFin) || ' WHERE cuenta = '''|| TRIM(vsCtaConcentradora ) ||''' AND aniomes BETWEEN ''' || TRIM(vsAnioMesIni) || ''' AND ''' || TRIM(vsAnioMesFin) || '''';
				
				LET vsSQL1 = TRIM(vsSQL1);
				LET vsSQL2 = TRIM (vsSQL2);
				LET vsSQL3 = TRIM(vsSQL3);		
				LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
				LET vsSQL = TRIM(vsSQL);
				SYSTEM  vsSQL ;
				LET vsSQL = '';
				LET vsSQL = 'dbaccess bdicheq /tmp/sc_sdodiarioc_edocta.sql';
				LET vsSQL = TRIM(vsSQL);
				SYSTEM vsSQL;
			END IF;
		
	END IF;
	
    LET vdFechaParam = vsFechaParam;	
	
	
	IF  DAY (vdFechaIni)  = 2 AND MONTH(vdFechaIni) =  1 THEN 
		LET iBandera = 1;					
	END IF;
	IF EXISTS(SELECT aniomes FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes <> '' AND usuario = pUsuario) THEN
		--Trabaja mientras la fecha inicial sea menor o igual a la fecha final.
		WHILE(vdFechaIni <= vdFechaFin)
			--Se asigna a variable la fecha inicio.
			LET vsFechaIni = vdFechaIni;
			--Se asigna a variable año y mes de la fecha inicio.
			LET vsAnioMes = TRIM(SUBSTRING(vdFechaIni FROM 7 FOR 4)) || TRIM(SUBSTRING(vdFechaIni FROM 1 FOR 2));
			LET vsMes = TRIM(SUBSTRING(vdFechaIni FROM 1 FOR 2));
			--Verifica si es el dia primero del mes.
			IF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "01" )THEN
				--Se le resta un dia a la fecha inicio y se asigna a variable, en este caso sera el ultimo dia del mes anterior.
				LET vsFechaAnt = vdFechaIni - INTERVAL (1) DAY TO DAY;
				--Se asigna a variable año y mes del dia anterior.
				LET vsAnioMesAnt = TRIM(SUBSTRING(vsFechaAnt FROM 1 FOR 4)) || TRIM(SUBSTRING(vsFechaAnt FROM 6 FOR 2));
				--Verifica que dia fue el anterior, 28, 29, 30 o 31, dependiendo que dia resulte ser obtendra el capital vigente de ese dia.
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				IF( TRIM(SUBSTRING(vsFechaAnt FROM 9 FOR 2)) = "28" )THEN
					SELECT capvig28 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;
				ELIF( TRIM(SUBSTRING(vsFechaAnt FROM 9 FOR 2)) = "29" )THEN
					SELECT capvig29 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;
				ELIF( TRIM(SUBSTRING(vsFechaAnt FROM 9 FOR 2)) = "30" )THEN
					SELECT capvig30 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;
				ELIF( TRIM(SUBSTRING(vsFechaAnt FROM 9 FOR 2)) = "31" )THEN			
					SELECT capvig31 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;					
				END IF;
				
				--Se obtiene el capital vigente del primer dia del mes.
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				LET vsCtaConcentradora = vsCtaConcentradora;
				LET vsAnioMes = vsAnioMes;
				
				IF vsMes <>"01" THEN
					SELECT capvig1 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				ELSE
					LET vsSaldoFinal = "";
					LET vsSaldoFinal = vsSaldoInicial;
				END IF ;
				
				--Respectivamente se obtendra el capital vigente de cada dia correspondiente al rango de fechas a procesar.
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "02" )THEN			
				
				IF vsMes <> '01' THEN
					SELECT capvig1 ,capvig2 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
				ELSE
					IF iBandera = 1 THEN 
						LET vsFechaAnt = vdFechaIni - INTERVAL (2) DAY TO DAY;
					--Se asigna a variable año y mes del dia anterior.
						LET vsAnioMesAnt = TRIM(SUBSTRING(vsFechaAnt FROM 1 FOR 4)) || TRIM(SUBSTRING(vsFechaAnt FROM 6 FOR 2));
					--Verifica que dia fue el anterior, 28, 29, 30 o 31, dependiendo que dia resulte ser obtendra el capital vigente de ese dia.
						SELECT capvig31 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMesAnt AND usuario = pUsuario;												
						LET iBandera = 0 ;
					ELSE					
						LET vsSaldoInicial = "";
						LET vsSaldoInicial= vsSaldoFinal;
					END IF;
					SELECT capvig2 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
					
				END IF; 
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "03" )THEN
					SELECT capvig2 ,capvig3 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "04" )THEN
					SELECT capvig3 ,capvig4 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "05" )THEN
					SELECT capvig4 ,capvig5 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "06" )THEN
					SELECT capvig5 ,capvig6 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "07" )THEN
					SELECT capvig6 ,capvig7 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "08" )THEN
					SELECT capvig7 ,capvig8 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "09" )THEN
					SELECT capvig8 ,capvig9 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "10" )THEN
					SELECT capvig9 ,capvig10 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "11" )THEN
					SELECT capvig10 ,capvig11 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "12" )THEN
					SELECT capvig11 ,capvig12 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "13" )THEN
					SELECT capvig12 ,capvig13 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "14" )THEN
					SELECT capvig13 ,capvig14 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "15" )THEN
					SELECT capvig14 ,capvig15 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "16" )THEN					
					SELECT capvig15 ,capvig16 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "17" )THEN
					SELECT capvig16 ,capvig17 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "18" )THEN			
					SELECT capvig17 ,capvig18 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "19" )THEN				
					SELECT capvig18 ,capvig19 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "20" )THEN
					SELECT capvig19 ,capvig20 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "21" )THEN				
					SELECT capvig20 ,capvig21 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "22" )THEN				
					SELECT capvig21 ,capvig22 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "23" )THEN
					SELECT capvig22 ,capvig23 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "24" )THEN				
					SELECT capvig23 ,capvig24 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "25" )THEN
					IF vsMes <>"12" THEN
					
						SELECT capvig24 ,capvig25 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
					ELSE
						--	SELECT capvig24 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
						--	SELECT capvig24 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
						SELECT capvig24 ,capvig24 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
					END IF;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "26" )THEN
				if vsMes <>"12" THEN
						--	SELECT capvig25 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
						--	SELECT capvig26 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
							SELECT capvig25 ,capvig26 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
				ELSE
						--	SELECT capvig24 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
						--	SELECT capvig26 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
							SELECT capvig24 ,capvig26 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
				END if;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "27" )THEN
			--	SELECT capvig26 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig27 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig26 ,capvig27 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "28" )THEN
			--	SELECT capvig27 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig28 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig27 ,capvig28 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "29" )THEN
			--	SELECT capvig28 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig29 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig28 ,capvig29 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "30" )THEN
			--	SELECT capvig29 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig30 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig29 ,capvig30 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			ELIF( TRIM(SUBSTRING(vsFechaIni FROM 4 FOR 2)) = "31" )THEN
			--	SELECT capvig30 INTO vsSaldoInicial FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
			--	SELECT capvig31 INTO vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario;
				SELECT capvig30 ,capvig31 INTO vsSaldoInicial,vsSaldoFinal FROM bdicheq:"informix".sc_sdodiarioc_edocta WHERE cuenta = vsCtaConcentradora AND aniomes = vsAnioMes AND usuario = pUsuario ;
			END IF;
			
			--Se obtiene la cantidad de transacciones y el monto total de las transacciones de abono correspondientes del dia a consultar.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
	--		IF vsFechaIni >= vsFechaParam THEN
			IF vdFechaIni >= vdFechaParam THEN		
			SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalAbonos, vsMontoTotalAbonos FROM bdicheq:"informix".sc_movhis AS movhis, bdinteg:"informix".si_transacc AS trans WHERE movhis.fech_alt = vdFechaIni and movhis.cuenta = vsCtaConcentradora AND movhis.transacc = trans.numero AND trans.naturaleza = "A" AND movhis.cancelad <> 'S';
				--ELIF vsFechaIni <= vsFechaParam THEN
				--SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalAbonos, vsMontoTotalAbonos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = vdFechaIni and movhisold.cuenta = vsCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "A" AND movhisold.cancelad <> 'S';
				else
				SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalAbonos, vsMontoTotalAbonos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = vdFechaIni and movhisold.cuenta = vsCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "A" AND movhisold.cancelad <> 'S';
			END IF;
			--Se obtiene la cantidad de transacciones y el monto total de las transacciones de cargo correspondientes del dia a consultar.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
	--		IF vsFechaIni >= vsFechaParam THEN
			IF vdFechaIni >= vdFechaParam THEN
			SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalCargos, vsMontoTotalCargos FROM bdicheq:"informix".sc_movhis AS movhis, bdinteg:"informix".si_transacc AS trans WHERE movhis.fech_alt = vdFechaIni and movhis.cuenta = vsCtaConcentradora AND movhis.transacc = trans.numero AND trans.naturaleza = "C" AND movhis.cancelad <> 'S';
				--ELIF vsFechaIni <= vsFechaParam THEN
				--SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalCargos, vsMontoTotalCargos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = vdFechaIni and movhisold.cuenta = vsCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "C" AND movhisold.cancelad <> 'S';
				else
				SELECT COUNT(transacc), SUM(monto_tot) INTO vsTotalCargos, vsMontoTotalCargos FROM bdicheq:"informix".sc_movhis_old AS movhisold, bdinteg:"informix".si_transacc AS trans WHERE movhisold.fech_alt = vdFechaIni and movhisold.cuenta = vsCtaConcentradora AND movhisold.transacc = trans.numero AND trans.naturaleza = "C" AND movhisold.cancelad <> 'S';
			END IF; 
			RETURN vsFechaIni, NVL(vsSaldoInicial, 0.00),  vsTotalAbonos, NVL(vsMontoTotalAbonos, 0.00), vsTotalCargos, NVL(vsMontoTotalCargos, 0.00), NVL(vsSaldoFinal, 0.00), NVL(vsCtaConcentradora,''), NVL(vsCtaClabe,''), viSqlErr WITH RESUME;
			--Se asigna a variable el dia siguiente del mes para continuar consultando.
			LET vdFechaIni = vdFechaIni + INTERVAL (1) DAY TO DAY;
		END WHILE;
	END IF;
END IF;
END
END PROCEDURE
DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: BTS',
'Solicito: Jaime Gonzalez',
'Descripcion: GENERA REPORTE DE ESTADO DE CUENTA.',
'Fecha: 2011/08/30',
'Version: 20110830.1500',
'BD: BDISAC',
'AUTOR: José Angel Gaxiola / Cristian Valentina Aguilar ',
'Proyecto: BTS',
'Solicito: Jaime Gonzalez',
'Descripcion: Se modifica para que pueda generar el estado de cuenta contemplando que el periodo puede abarcar años diferentes al actual y diferentes entre sí.',
'Fecha: 2012/01/11',
'Version: 20120111.1901',
'BD: BDISAC',   
'AUTOR: José Angel Gaxiola / Cristian Valentina Aguilar ',
'Proyecto: BTS',
'Solicito: Jaime Gonzalez',
'Descripcion: Se modifico sp para que cuando se trate del primero de enero,muestre la misma cantidad tanto el saldo inicial como el saldo final',
'ya que ese día no hay movimientos en el banco, y pasar dicha cantidad al dia dos de enero como saldo inicial.',
'Fecha: 2012/01/23',
'Version: 20120123.1000',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sacreporteconciliacionconveniosucursal_pba(cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE)

-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(4) AS id_sucursal, INTEGER AS numpagos, CHAR(40) AS nomconvenio, MONEY(16,2) AS importe_pago, MONEY(16,2) AS importe_comision_convenio, MONEY(16,2) AS iva_comision_convenio, MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte, INTEGER AS flag_confirmacion_central, INTEGER AS flag_confirmacion_sucursal;


-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE cNumcategoria            CHAR(2);
DEFINE cIdSucursal              CHAR(4);
DEFINE cNumconvenio             CHAR(3);
DEFINE cNomconvenio             CHAR(40);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComisionConvenio    MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mIVAComisionCte         MONEY(16,2);
DEFINE mImportePago            MONEY(16,2);
DEFINE iConfirmacionCentral     INTEGER;
DEFINE iConfirmacionSucursal    INTEGER;
DEFINE iNumPagos                INTEGER;
DEFINE dFechaTabla			DATE;

--SET DEBUG FILE TO '/informix/adrian/sp_sacreporteconciliacionconveniosucursal_aia.out';
--TRACE ON;

--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cNumcategoria         = SUBSTRING(cConvenio FROM 1 FOR 2);
LET cNumconvenio          = SUBSTRING(cConvenio FROM 3 FOR 3);
LET cIdSucursal           = "";
LET cNomConvenio          = "";
LET mImportePago         = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte      = 0;
LET mIVAComisionCte      = 0;
LET iConfirmacionCentral  = 0;
LET iConfirmacionSucursal = 0;
LET iNumPagos             = 0;
LET dFechaTabla			= '';

BEGIN

    ON EXCEPTION SET iSqlErr

        IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
        END IF;

    END EXCEPTION;
	
	SELECT MIN (fecha_pago)
	INTO dFechaTabla
	FROM bdisac:"informix".sac_conciliaciontotalporconvenio;

    IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
    ELSE
		IF (dFechaIni>=dFechaTabla) THEN --Nuevo Proceso utilizando la tabla sac_conciliaciontotalporconvenio
			IF cConvenio = "00000" THEN      -- Todos los convenios
				IF cSucursal = "0000"  THEN   -- Todos los convenios y todas las sucursales
					FOREACH
						SELECT numcategoria, numconvenio 
						INTO cNumcategoria, cNumconvenio
						FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio					
						FOREACH
							SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
							SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
							SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_conciliaciontotalporconvenio
							WHERE fecha_pago::DATE  >= dFechaIni
							AND fecha_pago::DATE  <= dFechaFin
							AND numcategoria = cNumcategoria
							AND numconvenio = cNumconvenio
							GROUP BY nomconvenio, id_sucursal
							ORDER BY 2,1

							RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH;
					END FOREACH;
				ELSE   --Todos los convenios y una sucursal
					FOREACH
						SELECT numcategoria, numconvenio 
						INTO cNumcategoria, cNumconvenio
						FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
						FOREACH
							SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
							SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
							SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_conciliaciontotalporconvenio
							WHERE fecha_pago::DATE  >= dFechaIni
							AND fecha_pago::DATE  <= dFechaFin
							AND id_sucursal = cSucursal
							AND numcategoria = cNumcategoria
							AND numconvenio = cNumconvenio
							GROUP BY nomconvenio, id_sucursal
							ORDER BY 2,1

							RETURN cCodRet, cIdSucursal, iNumPagos,  cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH
					END FOREACH;
				END IF;
			ELSE
				IF cSucursal = "0000"  THEN   -- Un convenio y todas las sucursales
					FOREACH
						SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
						SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
						SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_conciliaciontotalporconvenio
						WHERE fecha_pago::DATE  >= dFechaIni
						AND fecha_pago::DATE  <= dFechaFin
						AND numcategoria = cNumcategoria
						AND numconvenio = cNumconvenio
						GROUP BY nomconvenio, id_sucursal
						ORDER BY 2,1

						RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						WITH RESUME;
					END FOREACH;
				ELSE   --Un convenio y una sucursal
					FOREACH
						SELECT TRIM(id_sucursal),TRIM(nomconvenio), SUM(numpagos), SUM(importe_archivo) AS importe, SUM(importe_comision_convenio) AS importe_comision_convenio,
						SUM(iva_comision_convenio) AS iva_comision_convenio, SUM(importe_comision_cte) AS importe_comision_cte, SUM(iva_comision_cte) AS iva_comision_cte,
						SUM(flag_confirmacion_central)AS confirmacion_central, SUM(flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_conciliaciontotalporconvenio
						WHERE fecha_pago::DATE  >= dFechaIni
						AND fecha_pago::DATE  <= dFechaFin
						AND numcategoria = cNumcategoria
						AND numconvenio = cNumconvenio
						AND id_sucursal = cSucursal
						GROUP BY nomconvenio,id_sucursal					
					
					END FOREACH;
					
					RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;

				END IF;

			END IF;
		ELSE --Proceso anterior consultando los movimiento
		
			IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
            LET cCodRet = "00001";
            RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;
			ELSE
				IF cConvenio = "00000" THEN      -- Todos los convenios
					IF cSucursal = "0000"  THEN   -- Todos los convenios y todas las sucursales
						FOREACH
							SELECT numcategoria, numconvenio 
							INTO cNumcategoria, cNumconvenio
							FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
							FOREACH
								SELECT TRIM(b.id_sucursal),TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
								SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
								SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
								INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
								WHERE b.fecha_pago::DATE  >= dFechaIni
								AND b.fecha_pago::DATE  <= dFechaFin
								AND a.numcategoria = b.numcategoria
								AND a.numconvenio = b.numconvenio
								AND b.numcategoria = cNumcategoria
								AND b.numconvenio = cNumconvenio
								AND b.status_cancelado <> 'S'
								AND flag_confirmacion_central = 1
								AND flag_confirmacion_sucursal = 1
								GROUP BY a.nomconvenio, b.id_sucursal
								ORDER BY 2,1

								RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								WITH RESUME;

							END FOREACH;
						END FOREACH;
					ELSE   --Todos los convenios y una sucursal
						FOREACH
							SELECT numcategoria, numconvenio 
							INTO cNumcategoria, cNumconvenio
							FROM bdisac:"informix".sac_convenios ORDER BY nomconvenio
							FOREACH
								SELECT TRIM(b.id_sucursal)AS id_sucursal, TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
								SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
								SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
								INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
								WHERE b.fecha_pago::DATE  >= dFechaIni
								AND b.fecha_pago::DATE  <= dFechaFin
								AND a.numcategoria = b.numcategoria
								AND a.numconvenio = b.numconvenio
								AND b.numcategoria = cNumcategoria
								AND b.numconvenio = cNumconvenio
								AND b.id_sucursal = cSucursal
								AND b.status_cancelado <> 'S'
								AND flag_confirmacion_central = 1
								AND flag_confirmacion_sucursal = 1
								GROUP BY a.nomconvenio, b.id_sucursal
								ORDER BY 2, 1

								RETURN cCodRet, cIdSucursal, iNumPagos,  cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
								WITH RESUME;
							END FOREACH
						END FOREACH;
					END IF;
				ELSE
					IF cSucursal = "0000"  THEN   -- Un convenio y todas las sucursales
						FOREACH
							SELECT TRIM(b.id_sucursal), TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
							SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
							SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
							INTO cIdSucursal, cNomConvenio, iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
							WHERE b.fecha_pago::DATE  >= dFechaIni
							AND b.fecha_pago::DATE  <= dFechaFin
							AND b.numcategoria = cNumcategoria
							AND b.numconvenio = cNumconvenio
							AND b.status_cancelado <> 'S'
							AND a.numcategoria = b.numcategoria
							AND a.numconvenio = b.numconvenio
							AND flag_confirmacion_central = 1
							AND flag_confirmacion_sucursal = 1
							GROUP BY a.nomconvenio, b.id_sucursal
							ORDER BY 2, 1

							RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
							WITH RESUME;
						END FOREACH;
					ELSE   --Un convenio y una sucursal
						SELECT TRIM(b.id_sucursal), TRIM(a.nomconvenio), COUNT(referencia1), SUM(b.importe_pago) AS importe, SUM(b.importe_comision_convenio) AS importe_comision_convenio,
						SUM(b.iva_comision_convenio) AS iva_comision_convenio, SUM(b.importe_comision_cte) AS importe_comision_cte, SUM(b.iva_comision_cte) AS iva_comision_cte,
						SUM(b.flag_confirmacion_central)AS confirmacion_central, SUM(b.flag_confirmacion_sucursal) AS confirmacion_sucursal
						INTO cIdSucursal, cNomConvenio , iNumPagos, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_convenios a,bdisac:"informix".sac_movimientoshistorial b
						WHERE b.fecha_pago::DATE  >= dFechaIni
						AND b.fecha_pago::DATE  <= dFechaFin
						AND b.numcategoria = cNumcategoria
						AND b.numconvenio = cNumconvenio
						AND b.status_cancelado <> 'S'
						AND a.numcategoria = b.numcategoria
						AND a.numconvenio = b.numconvenio
						AND b.id_sucursal = cSucursal
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY a.nomconvenio, b.id_sucursal;

						RETURN cCodRet, cIdSucursal, iNumPagos, cNomConvenio, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal;

					END IF;

				END IF;

			END IF;
		
		END IF;

    END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener los totales captados por convenio en un rango de fechas especificas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080905',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzaservcpl_pba()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

-- DEFINICION DE VARIABLES
DEFINE cCodRet				CHAR(5);
DEFINE cMensaje				CHAR(80);
DEFINE iSqlErr				INTEGER;
DEFINE cDia					CHAR(2);
DEFINE cMes					CHAR(2);
DEFINE cAnio				CHAR(4);
DEFINE cCategoria				CHAR(2);
DEFINE cConvenio				CHAR(3);
DEFINE cReferencia1			CHAR(15);
DEFINE cRutaArchDet		CHAR(100);
DEFINE cRutaArchCif		CHAR(100);
DEFINE cStmt				CHAR(250);
DEFINE cStmt2				CHAR(250);
DEFINE cFolio				CHAR(16);
DEFINE dFecha_Hoy				DATE;
DEFINE iFlagCen				INTEGER;
DEFINE iFlagSuc				INTEGER;
DEFINE iCuantos				INTEGER;
DEFINE dFechaPago			CHAR(10);
DEFINE cMovimiento			CHAR(2);
DEFINE cTipoMovimiento		CHAR(2);
DEFINE iImporte_Pago		INTEGER;
DEFINE dFecha_Pago			CHAR(10);
DEFINE cTienda				CHAR(4);
DEFINE iNum_Empleado		INTEGER;
DEFINE cEmpresa				CHAR(1);
DEFINE iCiudadCop				INTEGER;
DEFINE cDescripcion			CHAR(50);
DEFINE iCampoFuturo1		INTEGER;
DEFINE iCampoFuturo2		INTEGER;
DEFINE iCampoFuturo3		INTEGER;
DEFINE iCampoFuturo4		INTEGER;
DEFINE cCaja				CHAR(4);
DEFINE iNumeroTicket		BIGINT;
DEFINE iCantidadMovimientos	BIGINT;
DEFINE cStatus				CHAR(1);
DEFINE cFechaFormato		CHAR(10);

--INICIALIZACION DE VARIABLES--
LET cCodRet					= "00000";
LET cMensaje				= 'PROCESO EXITOSO';
LET iSqlErr					= 0;
LET cCategoria				= '';
LET cConvenio				= '';
LET cReferencia1				= '';
LET cDia					= '';
LET cMes					= '';
LET cAnio					= '';
LET iImporte_Pago				= 0;
LET cFolio					= '';
LET iFlagCen				= 0;
LET iFlagSuc				= 0;
LET cRutaArchDet			= '/home/systelmex/pagoserviciosdetalleaaaammdd.txt';
LET cRutaArchCif			= '/home/systelmex/pagoservicioscifraAAAAMMDD.txt';
LET iCuantos				= 0;
LET cStmt					= '';
LET cStmt2					='';
LET dFecha_Hoy				= DATE(1);
LET dFechaPago				= '';
LET cMovimiento			= '';
LET cTipoMovimiento		= '';
LET iImporte_Pago		= 0;
LET dFecha_Pago			= '';
LET cTienda				= '0';
LET iNum_Empleado		= 0;
LET cEmpresa				= '';
LET iCiudadCop				= 9999;
LET cDescripcion			= '';
LET iCampoFuturo1		= 0;
LET iCampoFuturo2		= 0;
LET iCampoFuturo3		= 0;
LET iCampoFuturo4		= 0;
LET cCaja				= '0';
LET iNumeroTicket		= 0;
LET iCantidadMovimientos = 0;
LET cStatus  			= '0';
LET cFechaFormato		= '1900-01-01';

	--SET DEBUG FILE TO  '/informix/adrian/sp_generaarchivocobranzaservcpl.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".sac_fechas
		WHERE empresa = "001";		

		IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='IND_AC_SC' and fecha_proceso = dFecha_Hoy) THEN
				INSERT INTO bdisac:"informix".sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert) 
				VALUES('IND_AC_SC',dFecha_Hoy,'0','informix',current);
		ELSE
			SELECT status 
			INTO cStatus
			FROM bdisac:"informix".sac_procesos_jobs 
			WHERE proceso='IND_AC_SC' and fecha_proceso = dFecha_Hoy;			
		END IF;
		
		IF cStatus = '0' THEN
		
			--ASIGNA VALOR A LAS VARIABLES
			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');			
			
			--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
			LET cRutaArchDet = REPLACE(cRutaArchDet,'aaaa',cAnio);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'mm',cMes);
			LET cRutaArchDet = REPLACE(cRutaArchDet,'dd',cDia);								
			LET cRutaArchCif = REPLACE(cRutaArchCif,'AAAA',cAnio);
			LET cRutaArchCif = REPLACE(cRutaArchCif,'MM',cMes);
			LET cRutaArchCif = REPLACE(cRutaArchCif,'DD',cDia);					

			--SERVICIOS DE COPPEL ACTIVOS EN BANCO O COPPEL
			FOREACH
				
				SELECT numcategoria, numconvenio, TRIM(movimiento), TRIM(tipomovimiento), TRIM(descripcion)
				INTO cCategoria, cConvenio, cMovimiento, cTipoMovimiento, cDescripcion
				FROM "informix".sac_servicios_cpl		
				
				--ARCHIVO DETALLE
				FOREACH
				
					SELECT importe_pago::integer,
					fecha_pago,
					case when origen = 'CPL' then sucursal_cpl else id_sucursal end,
					usuario::integer,
					case when origen = 'CPL' then 'C' else 'B' end,
					case when origen = 'CPL' then caja_cpl else '0' end,
					folio_suc,
					folio_operacion::integer,
					referencia1,
					flag_confirmacion_central,
					flag_confirmacion_sucursal
					INTO iImporte_Pago, dFechaPago, cTienda, iNum_Empleado, cEmpresa, cCaja, cFolio, iNumeroTicket, cReferencia1, iFlagCen, iFlagSuc
					FROM "informix".sac_movimientos
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio				
					AND fecha_pago = dFecha_Hoy
					AND status_cancelado <> 'S'
					AND (flag_confirmacion_central = 1
					OR flag_confirmacion_sucursal = 1)
						
					--OBTENER EL NUMERO DE CIUDAD CATALOGO COPPEL
					IF EXISTS (SELECT * FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_catciudades b
					WHERE a.sucursal = cTienda AND a.ciudad = b.numerociudad ) THEN
					
						SELECT b.numerociudadcoppel 
						INTO iCiudadCop
						FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_catciudades b
						WHERE a.sucursal = cTienda AND a.ciudad = b.numerociudad;
					ELSE
						LET iCiudadCop = 9999;
					END IF;

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
						UPDATE "informix".sac_movimientoshistorial SET flag_confirmacion_sucursal = '1'
						WHERE numcategoria = cCategoria
						AND numconvenio = cConvenio
						AND fecha_pago = dFechaPago
						AND folio_suc = cFolio
						AND referencia1 = cReferencia1
						AND status_cancelado <> 'S'
						AND flag_confirmacion_sucursal = 0;
						
						INSERT INTO "informix".sac_bitacora_flags(numcategoria,numconvenio,referencia,folio_suc,fecha_pago,fecha_insert)
						VALUES (cCategoria,cConvenio,cReferencia1,cFolio,dFechaPago,current);
					END IF;		

					LET cFechaFormato = YEAR(dFechaPago) || '-' || LPAD(MONTH(dFechaPago),2,'0') || '-' || LPAD(DAY(dFechaPago),2,'0');

					--IMPRIME RENGLON DE LAS OPERACIONES
					LET cStmt = 'echo "' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iImporte_Pago || '|' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iNum_Empleado || '|' || TRIM(cEmpresa) || '|' || iCiudadCop || '|' || TRIM(cDescripcion) || '|' || TRIM(cCaja) || '|' || TRIM(cFolio) || '|' || iNumeroTicket || '|' || iCampoFuturo1 || '|' || iCampoFuturo2 || '|' || iCampoFuturo3 || '|' || iCampoFuturo4 || '" >> ' || cRutaArchDet;
					SYSTEM cStmt;
					
				END FOREACH;
				
				--ARCHIVO CIFRA				
				FOREACH
				
					SELECT fecha_pago,			
					case when origen = 'CPL' then sucursal_cpl else id_sucursal end tienda,
					SUM(importe_pago::integer) importe,
					count(*) AS cantidad_movimientos, 
					case when origen = 'CPL' then 'C' else 'B' end empresa								
					INTO dFecha_Pago, cTienda, iImporte_Pago, iCantidadMovimientos, cEmpresa
					FROM "informix".sac_movimientos
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago = dFecha_Hoy
					AND status_cancelado <> 'S'
					AND (flag_confirmacion_central = 1
					OR flag_confirmacion_sucursal = 1)
					GROUP BY fecha_pago, empresa, tienda
					
					LET cFechaFormato = YEAR(dFecha_Pago) || '-' || LPAD(MONTH(dFecha_Pago),2,'0') || '-' || LPAD(DAY(dFecha_Pago),2,'0');				
					
					--IMPRIME RENGLON DE LAS OPERACIONES
					LET cStmt2 = 'echo "' || TRIM(cFechaFormato) || '|' || LPAD(cTienda,4,'0') || '|' || iImporte_Pago || '|' || TRIM(cMovimiento) || '|' || TRIM(cTipoMovimiento) || '|' || iCantidadMovimientos || '|' || TRIM(cEmpresa) || '" >> ' || cRutaArchCif;
					SYSTEM cStmt2;
				
				END FOREACH;
				
			END FOREACH;

			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt = 'echo "' || '" >> ' || cRutaArchDet;
			SYSTEM cStmt;			
			
			--GENERA ARCHIVO EN BLANCO EN CASO DE NO HABER MOVIMIENTOS
			LET cStmt2 = 'echo "' || '" >> ' || cRutaArchCif;
			SYSTEM cStmt2;				
			
		END IF;

		UPDATE bdisac:"informix".sac_procesos_jobs SET status = '1' WHERE proceso='IND_AC_SC' and fecha_proceso = dFecha_Hoy;
		RETURN cCodRet, cMensaje; 
		
	END;
END PROCEDURE;