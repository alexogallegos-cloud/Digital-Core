CREATE PROCEDURE "informix".sp_dispercionnominaautomatico()
RETURNING CHAR(5);
    
    -- ******************************************************************************************
    -- Realizo   : Martin Valenzuela Ojeda, Armando Mercado
    -- Proyecto  : Dispersion Nomina BanCoppel
    -- Actividad : Ejecuta el proceso para la dispersion de la nomina,
    --             actualiza el campo status en el detalle de aquellos empleados
    --             que si se les ejecuto el pago de la nomina y
    --             aquellos que por algun motivo no se les disperso su sueldo.
    --             Tambien actualiza el encabezado para aquellos archivos que fueron dispersados,
    --             ejecutando las validaciones correspondientes.
    --             Este store sera ejecutado para varios archivos en Batch
    -- Fecha     : Abril de 2008
    -- ******************************************************************************************
    
    DEFINE vsqlerr                          INTEGER;
    DEFINE visamerr                         INTEGER;
    DEFINE vdescerr                         CHAR(60);
    DEFINE vcodret                          VARCHAR(6);
    DEFINE vcodret2                         VARCHAR(6);
    DEFINE vcodret3                         VARCHAR(60);
    DEFINE p_mensaje                        VARCHAR(100);
    DEFINE cNumeroEmpresa                   CHAR(3);
    DEFINE dFechaGeneracion                 DATE;
    DEFINE IFolioArchivo                    INTEGER;
    DEFINE dFechaActual                     DATE;
    DEFINE cEstatusCta                      CHAR(1);
    DEFINE cNumeroCuentaEmpleado            CHAR(20);
    DEFINE cNumeroEmpleado                  CHAR(10);
    DEFINE mImporteEmpleado                 MONEY(14,3);
    DEFINE dFechaAplicacion                 DATE;
    DEFINE cHoraActual                      DATETIME HOUR TO SECOND;
    DEFINE cNumeroTarjeta                   CHAR(20);
    DEFINE mImporteAbonado                  MONEY(16,3);
    DEFINE mImporteNoAbonado                MONEY(16,3);
    DEFINE mImporteTotalAplicado            MONEY(16,3);
    DEFINE siSaldoDisponible                SMALLINT;
    DEFINE mTotalNoPagado                   MONEY(16,3);
    DEFINE mTotalComisionDispercionIvaEmp   MONEY(14,3);
    DEFINE mImporteTotalEnc                 MONEY(14,3);
    DEFINE mSaldoActual                     MONEY(14,3);
    DEFINE iNumeroRegistros                 INTEGER;
    DEFINE bPrimerEmpleado                  BOOLEAN;
    DEFINE bSiguienteEmpleado               BOOLEAN;
    DEFINE cCodRet                          CHAR(3);
    DEFINE cMensaje                         CHAR(100);
    DEFINE mTotaliva                        MONEY(14,3);
    DEFINE mTotalComision                   MONEY(14,3);
    DEFINE iCodigoEstatus                   INTEGER;
    DEFINE cNumeroFolio                     CHAR(16);
    DEFINE cNombreArchivo                   CHAR(30);
    DEFINE vtranret                         CHAR(4);
    DEFINE vfechoy                          DATE;
    DEFINE vsdodisp                         MONEY(14,2);
    DEFINE vmontoret                        MONEY(14,2);
    DEFINE cFolioDispercion                 CHAR(16);
    DEFINE mComisionAplicado                MONEY(16,3);
    DEFINE mIvaAplicado                     MONEY(16,3);
    DEFINE cNombreArchivoConciliacion       CHAR(20);
    DEFINE cCuentaEje                       CHAR(20);
    DEFINE cUsuarioAutoriza                 CHAR(8);
    DEFINE siValorStatus					SMALLINT;
    DEFINE v_cCodRet                        CHAR(5);
    DEFINE siValorConcepto                  SMALLINT;
    DEFINE siValorConceptoAnterior          SMALLINT;
    DEFINE cValorTransaccion                CHAR(4);
    DEFINE cValorTipoTransaccion            CHAR(3);
    DEFINE cTransaccAbono                   CHAR(4);
    DEFINE cTransaccCargo                   CHAR(4);
    DEFINE mMontoTransComiDisp              MONEY(16,2);
    DEFINE mMontoTransComiAper              MONEY(16,2);
    DEFINE mMontoTransIvaDisp               MONEY(16,2);
    DEFINE mMontoTransIvaAper               MONEY(16,2);
    DEFINE mMontoFijo                       MONEY(16,2);
    DEFINE mTotalPagado                     MONEY(16,3);
    DEFINE mTotalCargo                      MONEY(16,3);
    DEFINE cTransaccComiDisp                CHAR(4);    -- // Aqui se traera el 0394
    DEFINE cTransacIvaDisp                  CHAR(4);    -- // Aqui se traera el 0396
    DEFINE mImporteEmpleadoCuentaEje        MONEY(16,3);
    DEFINE mImporteEmpleadoComisionMasIva   MONEY(16,3);
    DEFINE cEstatusCuenta                   CHAR(1);
    DEFINE vcodretCargo1                    CHAR(6);
    DEFINE vcodretCargo2                    CHAR(6);
    DEFINE vcodretCargo3                    CHAR(6);
    DEFINE vBegin                           CHAR(1);
    DEFINE mIvaPorEmpleado                  MONEY(16,2);
    DEFINE siTipoEmpresa                    SMALLINT ;
    DEFINE cSucursalAbono                   CHAR(4);
    DEFINE cSucursalCargo                   CHAR(4);
    DEFINE cRecDatonoUtilizableNOperacion   CHAR(4);
    DEFINE siVuelta                         INTEGER ;
    DEFINE cCargo               			CHAR(2);
    DEFINE cAbono               			CHAR(2);
    DEFINE cAceptaProducto         			CHAR(50);
    DEFINE iContador						INTEGER;
    DEFINE vexiste_encab                    CHAR(17);
    DEFINE vexiste_ctaeje                   CHAR(20);
    DEFINE vexiste_sec                      SMALLINT;
    DEFINE cProducto                        CHAR(20);
    DEFINE iNumeroRegistrosAplicados        INTEGER ;
    DEFINE vind_cierre                      CHAR(1);
    DEFINE vind_dispon                      CHAR(1);
	DEFINE mDispCtaBcoppel					MONEY;
    
    DEFINE vcNombreArchivo                  CHAR(17);
    DEFINE iCuentas                         INTEGER;
    DEFINE iSumCtas                         INTEGER;
    DEFINE mSumMonto                        MONEY(18,2);
    DEFINE cCtaAbono                        CHAR(20);
    DEFINE mImporte                         MONEY(16,2);
    DEFINE iCtas                            INTEGER;
    DEFINE iCuenta                          INTEGER;
    DEFINE iSumCuentas                      INT8;
    DEFINE mSumImporte                      MONEY(18,2);
    --Para cuentas que no se les cobra comision de dispersion 
	DEFINE vExcentaComision					INTEGER;
	DEFINE cProductoEje						CHAR(20);
	DEFINE cCuentaEjeClabe					CHAR(20);

	
    LET vsqlerr                         = 0;
    LET visamerr                        = 0;
    LET vdescerr                        = '' ;
    LET vcodret                         = '' ;
    LET vcodret2                        = '' ;
    LET vcodret3                        = '' ;
    LET p_mensaje                       = ' ' ;
    LET cNumeroEmpresa                  = '';
    LET dFechaGeneracion                = '';
    LET IFolioArchivo                   = 0;
    LET dFechaActual                    = '' ;
    LET cEstatusCta                     = '' ;
    LET cNumeroCuentaEmpleado           = '';
    LET cNumeroEmpleado                 = '';
    LET mImporteEmpleado                = 0;
    LET dFechaAplicacion                = '';
    LET cHoraActual                     = '' ;
    LET cNumeroTarjeta                  = '';
    LET mImporteAbonado                 = 0;
    LET mImporteNoAbonado               = 0;
    LET mImporteTotalAplicado           = 0;
    LET siSaldoDisponible               = 0;
    LET mTotalNoPagado                  = 0;
    LET mTotalComisionDispercionIvaEmp  = 0;
    LET mImporteTotalEnc                = 0;
    LET mSaldoActual                    = 0;
    LET iNumeroRegistros                = 0;
    LET bPrimerEmpleado                 = "T" ;
    LET bSiguienteEmpleado              = "F" ;
    LET cCodRet                         = '';
    LET cMensaje                        = '';
    LET mTotaliva                       = 0.00;
    LET mTotalComision                  = 0.00;
    LET iCodigoEstatus                  = 0;
    LET cNumeroFolio                    = '';
    LET cNombreArchivo                  = "";
    LET vtranret                        = '';
    LET vfechoy                         = '';
    LET vsdodisp                        = 0.00;
    LET vmontoret                       = 0.00;
    LET cFolioDispercion                = '';
    LET mComisionAplicado               = 0.00;
    LET mIvaAplicado                    = 0.00;
    LET cNombreArchivoConciliacion      = '';
    LET cCuentaEje                      = '';
    LET cUsuarioAutoriza                = '';
    LET siValorStatus                   = 0;
    LET v_cCodRet                       = '';
    LET siValorConcepto                 = 0;
    LET siValorConceptoAnterior         = 0;
    LET cValorTransaccion               = '';
    LET cValorTipoTransaccion           = '';
    LET cTransaccAbono                  = '';
    LET cTransaccCargo                  = '';
    LET mMontoTransComiDisp             = 0;
    LET mMontoTransComiAper             = 0;
    LET mMontoTransIvaDisp              = 0;
    LET mMontoTransIvaAper              = 0;
    LET mMontoFijo                      = 0;
    LET mTotalPagado                    = 0;
    LET mTotalCargo                     = 0;
    LET cTransaccComiDisp               = '';
    LET cTransacIvaDisp                 = '';
    LET mImporteEmpleadoCuentaEje       = 0;
    LET mImporteEmpleadoComisionMasIva  = 0;
    LET cEstatusCuenta                  = '';
    LET vcodretCargo1                   = '';
    LET vcodretCargo2                   = '';
    LET vcodretCargo3                   = '';
    LET vBegin                          = 'S';
    LET mIvaPorEmpleado                 = 0;
    LET siTipoEmpresa                   = 0;
    LET cSucursalAbono                  = '';
    LET cSucursalCargo                  = '';
    LET cRecDatonoUtilizableNOperacion  = '';
    LET siVuelta                        = 0;
    LET cCargo                          ='';
    LET cAbono                          ='';
    LET cAceptaProducto                 = '';
    LET iContador                       = 0;
    LET vexiste_encab                   = '';
    LET vexiste_ctaeje                  = '';
    LET vexiste_sec                     = 0;
    LET cProducto                       = '';
    LET iNumeroRegistrosAplicados       = 0;
    LET vind_cierre                     = '0';
    LET vind_dispon                     = '0';
	LET mDispCtaBcoppel	                = 0.0;
    
    LET vcNombreArchivo = '';
    LET iCuentas        = 0;
    LET iSumCtas        = 0;
    LET mSumMonto       = 0.00;
    LET cCtaAbono       = '';
    LET mImporte        = 0.00;
    LET iCtas           = 0;
    LET iCuenta         = 0;
    LET iSumCuentas     = 0;
    LET mSumImporte     = 0.00;
	
	 --Para cuentas que no se les cobra comision de dispersion 
	 LET vExcentaComision = 0;
	 LET cProductoEje = '';
	
    
     --SET DEBUG FILE TO '/home/sysifx/captacion/trace/sp_dispercionnominaautomatico.out';
    --TRACE ON;
    
    BEGIN
    
	ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO '/tmp/sp_dispercionnominaautomatico.err';
        TRACE ON;
		IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
			LET vcodret  = vsqlerr;  --- Dispercion No Ejecutada
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";
			IF vBegin = 'S' THEN
				ROLLBACK WORK;
			END IF;
			RETURN vcodret;
		END IF;
	END EXCEPTION;
    
	SET ISOLATION TO CURSOR STABILITY; 
	SET ISOLATION TO DIRTY READ; 
	SET LOCK MODE TO WAIT 5; 
    
	SELECT fecha_hoy, ind_cierre, ind_disponible
	  INTO dFechaActual, vind_cierre, vind_dispon
	  FROM bdicheq:sc_fechas
	 WHERE empresa = "001";
     
    IF ( vind_cierre = '0' OR vind_dispon = '0' ) THEN
        LET vcodret = '004';
        RETURN vcodret;
    END IF;
    
	SELECT FIRST 1 nombre_archivo
	  INTO vexiste_encab
	  FROM bdicheq:sc_nominaencabezadosumario
	 WHERE status = '1'
	   AND fecha_aplicacion =  dFechaActual;
    
	IF vexiste_encab IS NULL OR vexiste_encab = '' THEN
		LET vcodret = '805'; --- Dispercion No Ejecutada: No Existe el Encabezado del Archivo Ã?el Estatus No es el Correcto;
		RETURN vcodret;
	END IF;
    
	LET cHoraActual = CURRENT;
    
	-- // Se borra la tabla de control al inicio de cada ciclo
	TRUNCATE TABLE bdicheq:sc_nominaresultadosdispercionautomatica;
    
	SELECT valor
	  INTO mMontoTransIvaDisp
	  FROM bdinteg:si_param
	 WHERE cod_param = 47
	   AND empresa = "001";
    
	IF (mMontoTransIvaDisp = "") OR (mMontoTransIvaDisp = " ") OR (mMontoTransIvaDisp IS NULL) THEN
		LET vcodret = '855';  --- Dispercion No Ejecutada: El Valor del Iva No es Valido
		RETURN vcodret;
	END IF;
    
    FOREACH
        SELECT cif.nombre_archivo, cif.no_cuentas, cif.suma_cuentas, cif.suma_importe
          INTO vcNombreArchivo, iCuentas, iSumCtas, mSumMonto
          FROM bdicheq:sc_cifr_ctl_disp cif, 
               bdicheq:sc_nominaencabezadosumario nom
         WHERE cif.nombre_archivo = nom.nombre_archivo
		   AND cif.fecha_aplicacion = nom.fecha_aplicacion
		   AND nom.fecha_aplicacion <= dFechaActual
		   AND nom.status = '1'
           
        FOREACH
            SELECT cuenta_abono, importe
              INTO cCtaAbono, mImporte
              FROM bdicheq:sc_nominamovimientos 
             WHERE nombre_archivo = vcNombreArchivo
               AND status = 0
               
            LET iCtas = iCtas + 1;
            LET iCuenta = SUBSTR(cCtaAbono,3,9)::INTEGER;
            LET iSumCuentas = ( iSumCuentas + ( iCuenta / 10000 ) );
            LET mSumImporte = mSumImporte + mImporte;
                      
            LET cCtaAbono = '';
            LET mImporte = 0.00;
            LET iCuenta = 0;
        END FOREACH;
        
        IF iCuentas <> iCtas OR iSumCtas <> iSumCuentas OR mSumMonto <> mSumImporte THEN
            LET vcodret = '805'; 
            RETURN vcodret;
        END IF;          
        
        LET iCtas = 0;
        LET iCuentas = 0;
        LET iSumCtas = 0;
        LET mSumMonto = 0.00;
        LET iSumCuentas = 0;
        LET mSumImporte = 0.00;
        LET vcNombreArchivo = '';
    END FOREACH;
    
	FOREACH WITH HOLD
		SELECT nom.empresa, nom.fecha_gen, nom.folio_archivo, nom.nombre_archivo, nom.cuenta_cargo, nom.fecha_aplicacion, nom.total_registros, nom.importe_tot
		  INTO cNumeroEmpresa, dFechaGeneracion, IFolioArchivo, cNombreArchivo, cCuentaEje, dFechaAplicacion, iNumeroRegistros, mImporteTotalEnc
		  FROM bdicheq:sc_nominaencabezadosumario nom,
               bdicheq:sc_cifr_ctl_disp cif
		 WHERE cif.nombre_archivo = nom.nombre_archivo
           AND cif.fecha_aplicacion = nom.fecha_aplicacion
           AND nom.status = '1'
		   AND nom.fecha_aplicacion <= dFechaActual
		 ORDER BY nom.empresa, nom.nombre_archivo
        
		BEGIN WORK;
		LET vBegin = 'S';
		LET vcodret = '000';
        
		-- // Consulta el Tipo de empresa
		SELECT tipo_empresa, TRIM(acepta_producto)
		  INTO siTipoEmpresa, cAceptaProducto
		  FROM bdicheq:sc_nominaempresas
		 WHERE codigo = cNumeroEmpresa;
        
		SELECT LIMIT 1 concepto --, nombre_archivo
		  INTO siValorConcepto --, cNombre
		  FROM bdicheq:sc_nominamovimientos
		 WHERE nombre_archivo = cNombreArchivo
		   AND status = '0';
		   
		 -- para cuentas que no se les cobra comision 20/02/2023
		SELECT  cuenta_clabe, producto
		  INTO cCuentaEjeClabe, cProductoEje
		  FROM bdicheq:sc_maechq
		 WHERE empresa = '001'
		   AND cuenta = cCuentaEje;
		   
		-- para cuentas que no se les cobra comision 20/02/2023
		SELECT COUNT(1) INTO vExcentaComision FROM bdicheq:sc_nominaexcentocomision WHERE producto = cProductoEje;
        
		-- // Cambio Validacion para que si la empresa es interna pero tiene un concepto dIFerente a nomina se tome como externa para el cobro de impuestos
		IF (siTipoEmpresa = 2) AND (siValorConcepto <> 1) AND (siValorConcepto <> 5) THEN
			LET siTipoEmpresa = 1;
		END IF;
        
		-- // Inicio de validacion de tipo de empresa externas
		IF siTipoEmpresa <> 2  THEN
			SELECT cuenta
			  INTO vexiste_ctaeje
			  FROM bdicheq:sc_maechq
			 WHERE empresa = '001'
			   AND cuenta = cCuentaEje;
            
			--- IF NOT Exists (SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cCuentaEje) THEN
			--- IF vexiste_ctaeje <> cCuentaEje THEN
			IF vexiste_ctaeje IS NULL THEN
				LET vcodret  = "810"; --- La cuenta NO Existe en la Base de Datos
                
				-- // Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo
				UPDATE bdicheq:sc_nominaencabezadosumario
				   SET status = '7', 
					   fecha_aplicado = dFechaActual,
					   hora_aplicado = cHoraActual
				 WHERE empresa = cNumeroEmpresa
				   AND fecha_gen = dFechaGeneracion
				   AND folio_archivo = IFolioArchivo;
                
				COMMIT WORK;
				LET vBegin = 'N';
                
				-- // Genera respuesta para el cliente
				CALL sp_conciliaciondispersionnomina (cNombreArchivo)
				RETURNING v_cCodRet, cNombreArchivoConciliacion;
                
				-- // Continua con el siguiente archivo
				CONTINUE FOREACH;
			ELSE
				CALL sp_dispersionnominavalidacionestatus(cCuentaEje, cNumeroEmpresa, dFechaGeneracion, iFolioArchivo, dFechaActual, cHoraActual, '', '', '', '', '')
				RETURNING vcodret, cEstatusCuenta, cCargo, mImporteNoAbonado, cSucursalCargo, cRecDatonoUtilizableNOperacion;
                
				IF vcodret <> '000' THEN
					COMMIT WORK;
					LET vBegin = 'N';
                    
					-- // Genera respuesta para el cliente
					CALL sp_conciliaciondispersionnomina (cNombreArchivo)
					RETURNING v_cCodRet, cNombreArchivoConciliacion;
                    
					-- // Continua con el siguiente archivo
					CONTINUE FOREACH;
				END IF;
			END IF;
		END IF; -- // Fin de validacion de tipo de empresa externas
        
		LET cUsuarioAutoriza = "informix";
		LET mTotalNoPagado = 0;
		LET mImporteAbonado = 0;
		LET mImporteNoAbonado = 0;
		LET mImporteTotalAplicado = 0;
		LET mTotalPagado = 0;
		LET iNumeroRegistrosAplicados = 0;
		LET mTotalCargo = 0;
        
		IF (cNombreArchivo IS NULL) OR (cNombreArchivo = "") OR (cNombreArchivo = " ") THEN
			LET vcodret = '830';
			LET p_mensaje = "Dispercion No Ejecutada: Existe el Encabezado Pero No Existe el Detalle del Archivo";
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";
            LET vcodret = '000'; --- Este codigo se deja en 000 porque el ciclo continua ejecutandose para otro archivo y necesita llevar este valor
            
			UPDATE bdicheq:sc_nominaencabezadosumario
			   SET status = '6', --- Importe restaurado a la cuenta
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo;
            
			COMMIT WORK;
			LET vBegin = 'N';
            
			-- // Genera respuesta para el cliente
			CALL sp_conciliaciondispersionnomina (cNombreArchivo)
			RETURNING v_cCodRet, cNombreArchivoConciliacion;
            
			-- // Continua con el siguiente archivo
			CONTINUE FOREACH;
		END IF;
        
		LET siValorConceptoAnterior = 0; --- Aqui inicializo la variable cada vez que se vaya a procesar otro archivo
        
		-- // Se Limpian las Variables en Cada Vuelta
		LET cTransaccAbono = "";
		LET cTransaccCargo = "";
		LET cTransaccComiDisp = "";
		LET cTransacIvaDisp = "";
		LET vcodret = '000';
        
		-- // Inicio de validacion de tipo de empresa externas
		IF siTipoEmpresa <> 2 THEN
			SELECT sdo_actual
			  INTO mSaldoActual
			  FROM bdicheq:sc_maechq
			 WHERE empresa ='001'
			   AND cuenta = cCuentaEje;
            
			SELECT MIN(importe)
			  INTO mImporteEmpleado
			  FROM bdicheq:sc_nominamovimientos
			 WHERE nombre_archivo = cNombreArchivo
			   AND status = '0'; --- Con status <> 1 tomo todos los registros que no hayan sido procesados
			
			-- para cuentas que no se les cobra comision 20/02/2023
			IF vExcentaComision > 0 THEN 
				LET mIvaPorEmpleado = 0;
				LET mTotalComisionDispercionIvaEmp = 0;
				LET mImporteEmpleadoCuentaEje = mImporteEmpleado;
			ELSE
				LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
				LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
				LET mImporteEmpleadoCuentaEje = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
			END IF
            
			--- // Linea nueva aqui valido que por lo menos exista saldo para pagar a un empleado
			IF (mSaldoActual <= 0) OR (mSaldoActual < mImporteEmpleadoCuentaEje) THEN
				LET siSaldoDisponible = 0;
				LET vcodret = '835';
				LET p_mensaje = "Dispercion No Ejecutada: La Cuenta Eje No Tiene Saldo";
				LET cFolioDispercion = "";
				LET mImporteTotalAplicado = 0;
				LET mComisionAplicado = 0;
				LET mIvaAplicado = 0;
				LET cNombreArchivoConciliacion = "";
				LET vcodret = '000'; --- Este codigo se deja en 000 porque el ciclo continua para otro archivo y necesita llevar este valor
                
				UPDATE bdicheq:sc_nominaencabezadosumario
				   SET status = '5', --Saldo insuficiente
					   fecha_aplicado = dFechaActual,
					   hora_aplicado = cHoraActual
				 WHERE empresa = cNumeroEmpresa
				   AND fecha_gen = dFechaGeneracion
				   AND folio_archivo = IFolioArchivo;
                
				COMMIT WORK;
				LET vBegin = 'N';
				
				-- // Genera respuesta para el cliente
				CALL sp_conciliaciondispersionnomina (cNombreArchivo)
				RETURNING v_cCodRet, cNombreArchivoConciliacion;
				
				CONTINUE FOREACH;
			ELSE
				LET siSaldoDisponible = 1;
				LET mImporteEmpleado = 0;
				LET mTotalComisionDispercionIvaEmp = 0;
				LET mImporteEmpleadoCuentaEje = 0;
			END IF;
            
			LET cNumeroEmpresa = cNumeroEmpresa;
			LET siValorConcepto = siValorConcepto;
		END IF; -- // Fin de validacion de tipo de empresa externas
        
		-- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
		--- CALL sp_dispersionnominatransacciones (siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
        CALL sp_dispersionnominatransacciones (siTipoEmpresa, siValorConcepto)
		RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo,
				  cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransacIvaDisp, mMontoTransIvaAper;
        
		IF vcodret <> '000' THEN
			-- // El Numero De transaccion es Invalido o No Existe
			UPDATE bdicheq:sc_nominaencabezadosumario
			   SET status = '4', --No aplicado cuenta inexistente
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo;
            
			COMMIT WORK;
			LET vBegin = 'N';
            
			-- // Genera respuesta para el cliente
			CALL sp_conciliaciondispersionnomina (cNombreArchivo)
			RETURNING v_cCodRet, cNombreArchivoConciliacion;
			
			CONTINUE FOREACH;
		END IF;
        
		LET siVuelta = 0;
        
		FOREACH WITH HOLD
			SELECT mov.num_empleado, mov.cuenta_abono, mov.importe, mov.concepto, mae.status_cta, mae.producto
			  INTO cNumeroEmpleado, cNumeroCuentaEmpleado, mImporteEmpleado, siValorConcepto,siValorStatus, cProducto
			  FROM bdicheq:sc_nominamovimientos mov
			  LEFT JOIN bdicheq:sc_maechq mae ON (mae.empresa = '001' AND mov.cuenta_abono = mae.cuenta)
			 WHERE mov.nombre_archivo = cNombreArchivo
			   AND mov.status = 0 --- Con status <> 1 tomo todos los registros que no hayan sido procesados
			ORDER BY mov.importe
            
			LET siVuelta = siVuelta + 1;
			LET iContador = iContador + 1;
            
			IF (siValorConcepto <> 0) AND (siValorConceptoAnterior <> siValorConcepto) THEN
				LET siValorConceptoAnterior = siValorConcepto;
			END IF;
            
			-- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
			--- CALL sp_dispersionnominatransacciones(siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
            CALL sp_dispersionnominatransacciones(siTipoEmpresa, siValorConcepto)
			RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo,
					  cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransacIvaDisp, mMontoTransIvaAper;
            
			IF vcodret <> '000' THEN
				-- // El Numero De transaccion es Invalido o No Existe
				UPDATE bdicheq:sc_nominaencabezadosumario
				   SET status = '4', --- Error
					   fecha_aplicado = dFechaActual,
					   hora_aplicado = cHoraActual
				 WHERE empresa = cNumeroEmpresa
				   AND fecha_gen = dFechaGeneracion
				   AND folio_archivo = IFolioArchivo;
                
				COMMIT WORK;
				LET vBegin = 'N';
				CONTINUE FOREACH;
			END IF;
            
			LET cAceptaProducto = TRIM(cAceptaProducto);
            
			--- IF cProducto IS NULL OR cProducto <> cAceptaProducto THEN
			IF cProducto IS NULL THEN
				-- // Cuenta no existe
				UPDATE bdicheq:sc_nominamovimientos
				   SET status = '4'
				 WHERE nombre_archivo = cNombreArchivo
				   AND num_empleado = cNumeroEmpleado;
                
				IF siTipoEmpresa = 2 THEN
					LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
				END IF;
                
				CONTINUE FOREACH;
	        END IF;
			
			-- // Inicio de validacion de tipo de empresa externas
			IF siTipoEmpresa <> 2 THEN
			
			IF vExcentaComision > 0 THEN 
				LET mIvaPorEmpleado = 0;
				LET mTotalComisionDispercionIvaEmp = 0;
				LET mImporteEmpleadoComisionMasIva = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
            ELSE
				LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
				LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
				LET mImporteEmpleadoComisionMasIva = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
            END IF;
  
                --- Aqui se le resta 1 centavo, porque cuando el saldo inicial de la cuenta eje es igual a la suma del  monto a dispersar + su comision + su iva
				--- cuando ya esta en el ultimo empleado el proceso le suma 1 centavo a mTotalCargo + mImporteEmpleadoComisionMasIva, por lo tango el mSaldoActual 
				--- es menor que mTotalCargo + mImporteEmpleadoComisionMasIva, cuando la realidad es que deben de ser iguales. 
				IF siVuelta = iNumeroRegistros THEN
					LET mTotalCargo = mTotalCargo - 0.01;
				END IF;
                
				-- // Si el saldo sobrante que me queda es Mayor o Igual al importe a pagar, le pago al empleado
				IF mSaldoActual >= (mTotalCargo + mImporteEmpleadoComisionMasIva) THEN
					LET bSiguienteEmpleado = "T" ;
					LET siSaldoDisponible = 1;
				ELSE
					LET bSiguienteEmpleado = "F" ;
					LET siSaldoDisponible = 0;
				END IF;
			END IF; -- // Fin de validacion de tipo de empresa externas
            
			-- // Inicio de validacion de tipo de empresa = 2
			IF siTipoEmpresa = 2 THEN
				LET bPrimerEmpleado = "T";
				LET bSiguienteEmpleado = "T";
				LET siSaldoDisponible = 1;
			END IF; -- // Fin de validacion de tipo de empresa = 2
            
			IF (bPrimerEmpleado = "T") OR (bSiguienteEmpleado = "T") THEN
				IF siValorStatus > 1 THEN
					CALL sp_dispersionnominavalidacionestatus(cNumeroCuentaEmpleado, '', '', 0, '', '' ,cNombreArchivo, cNumeroEmpleado, mImporteEmpleado, mImporteNoAbonado, siTipoEmpresa)
					RETURNING vcodret, cEstatusCta, cAbono, mImporteNoAbonado, cRecDatonoUtilizableNOperacion, cSucursalAbono;
				ELSE
					LET cEstatusCta = 1;
				END IF;
                
				-- // Estatus 1 = Cuenta Activa, Estatus 3 = Cuenta Bloqueada, Se modifica que pudiera abonarse a la cuenta bloqueada, si el motivo del bloqueo lo permite
				IF ((siSaldoDisponible = 1) AND (cEstatusCta = '1' )) OR ((siSaldoDisponible = 1) AND (cAbono = 'S')) THEN
					SELECT MAX(secuencia)
					  INTO vexiste_sec
					  FROM bdicheq:sc_tarjeta
					 WHERE empresa = '001'
					   AND cuenta = cNumeroCuentaEmpleado
					   AND tipo_tarjeta = "T"
					   AND status_tar = "A";
                    
					IF vexiste_sec IS NOT NULL OR vexiste_sec <> '' OR vexiste_sec > 0 THEN
						SELECT NVL(num_tarjeta, '')
						  INTO cNumeroTarjeta
						  FROM bdicheq:sc_tarjeta
						 WHERE empresa = '001'
						   AND cuenta = cNumeroCuentaEmpleado
						   AND tipo_tarjeta = "T"
						   AND status_tar = "A"
						   AND secuencia = vexiste_sec;
					ELSE
						LET cNumeroTarjeta = '';
					END IF;
                    
					CALL sp_generafolionomina ("informix")
					RETURNING cCodRet, cNumeroFolio;
                    
					-- // Aqui siempre se mandara la empresa 001 independientemente del numero de empresa que se este ejecutando tanto para el abono_ref y el cargo_ref
					LET cSucursalAbono = "9103";
                    
					CALL abono_ref ("001", cSucursalAbono, "informix", cTransaccAbono, "0000", cNumeroFolio, cNumeroCuentaEmpleado,
									0, mImporteEmpleado, mImporteEmpleado, 0, 0, 0, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodret;
                    
					IF vcodret = '000' THEN
						UPDATE bdicheq:sc_nominamovimientos
						   SET status = '1'  --- Aqui actualizo el status = 1  (Aplicado)
						 WHERE nombre_archivo = cNombreArchivo
						   AND num_empleado = cNumeroEmpleado;
						
						LET mImporteAbonado = mImporteAbonado + mImporteEmpleado;
						
						LET iNumeroRegistrosAplicados = iNumeroRegistrosAplicados +1;
						
			-- para cuentas que no se les cobra comision 20/02/2023
						IF vExcentaComision > 0 THEN 
							LET mTotalComision = 0;
							LET mTotaliva = 0;
						ELSE
							LET mTotalComision = iNumeroRegistrosAplicados * mMontoTransComiDisp;
							LET mTotaliva = mTotalComision * mMontoTransIvaDisp;  --Nueva Forma de Calcular el Iva
						END IF
						
						LET mTotalPagado = mTotalPagado + mImporteEmpleado;
						LET mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;
					ELSE
						UPDATE bdicheq:sc_nominamovimientos
						   SET status = '9'  --- Aqui actualizo el status = 9  (Error en la transaccion del sp abono_ref)
						 WHERE nombre_archivo = cNombreArchivo
						   AND num_empleado = cNumeroEmpleado;
                        
						LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
					END IF;
				END IF;
			ELSE
				UPDATE bdicheq:sc_nominamovimientos
				   SET status = '5' --- Saldo Insuficiente
				 WHERE nombre_archivo = cNombreArchivo
				   AND num_empleado = cNumeroEmpleado;
                
				IF siTipoEmpresa = 2 THEN
					LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
				END IF;
			END IF;  -- // FIN de: IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T")
            
			LET bPrimerEmpleado = "F" ;
		END FOREACH;
        
		-- // Inicio de validacion de tipo de empresa externas
		IF siTipoEmpresa <> 2 THEN
			CALL sp_generafolionomina ("informix")
			RETURNING cCodRet, cNumeroFolio;
            
		
		
			-- para cuentas que no se les cobra comision 20/02/2023
			IF vExcentaComision > 0 THEN 
				LET mMontoTransComiDisp = 0;
			ELSE

			   --// OBTIENE EL VALOR DE LA COMISION POR DISPERSION EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
				SELECT disp_cta_bcoppel
				INTO mDispCtaBcoppel
				FROM "informix".sc_maecomtasserv_pm
				WHERE cuenta = cCuentaEje;

				IF mDispCtaBcoppel IS NOT NULL THEN
					LET mMontoTransComiDisp = mDispCtaBcoppel;
				END IF
			END IF
			
			-- // Aqui se manda llamar el sp que obtiene los totales del IVA y de la comision de los empleados Aplicados
			CALL sp_nominatotalivacomision (cNombreArchivo, mMontoTransIvaDisp, mMontoTransComiDisp)
			RETURNING cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;
            
			
			--/total pagado revisar y lo del 2600 totaliva0
			
			IF mTotalNoPagado <> 0 THEN
				LET iCodigoEstatus = 3;
			ELSE
				LET iCodigoEstatus = 2;
			END IF;
            
			IF cCodRet = '000' THEN
				UPDATE bdicheq:sc_nominaencabezadosumario
				   SET status = iCodigoEstatus,
					   importe_aplicado = mTotalPagado,
					   importe_no_aplicado = mTotalNoPagado,
					   folio_dispersion = cNumeroFolio,
					   iva = mTotaliva,
					   comision = mTotalComision,
					   fecha_aplicado = dFechaActual,
					   hora_aplicado = cHoraActual
				 WHERE empresa = cNumeroEmpresa
				   AND fecha_gen = dFechaGeneracion
				   AND folio_archivo = IFolioArchivo;
			ELSE
				UPDATE bdicheq:sc_nominaencabezadosumario
				   SET status = iCodigoEstatus,
					   importe_no_aplicado = mTotalNoPagado,
					   fecha_aplicado = dFechaActual,
					   hora_aplicado = cHoraActual
				 WHERE empresa = cNumeroEmpresa
				   AND fecha_gen = dFechaGeneracion
				   AND folio_archivo = IFolioArchivo;
			END IF;
            
			LET cNumeroTarjeta = '';
			LET vcodretCargo1 = '000';
			LET vcodretCargo2 = '000';
			LET vcodretCargo3 = '000';
            
			IF mTotalPagado > 0 or mTotalComision > 0 THEN
				IF mTotalPagado > 0 THEN
					CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccCargo, "0000", cNumeroFolio,cCuentaEje, 0, mTotalPagado, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
				ELSE
					LET vcodretCargo1 = '000';
				END IF;
				
				IF vcodretCargo1 = '000' AND mTotalComision > 0 THEN
					CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccComiDisp, "0000", cNumeroFolio,cCuentaEje, 0, mTotalComision, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;
                    
					IF vcodretCargo2 = '000' THEN
						CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,cCuentaEje, 0, mTotaliva, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
						RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
					END IF;
				ElIF (vcodretCargo1 = '000') AND (mTotalComision = 0) THEN
					LET vcodretCargo2 = '000';
					LET vcodretCargo3 = '000';
				END IF;
			END IF;
			
			IF (vcodretCargo1 = '000') AND (vcodretCargo2 = '000') AND (vcodretCargo3 = '000') THEN
				COMMIT WORK;
			ELSE
				ROLLBACK WORK;
                
				-- // El archivo no efectuo el cargo y deja movimientos en cero pero actualiza el status de encabezado sumario a 9
				UPDATE bdicheq:sc_nominaencabezadosumario
				   SET status = '9', --Error del cargo_ref
					   fecha_aplicado = dFechaActual,
					   hora_aplicado = cHoraActual
				 WHERE empresa = cNumeroEmpresa
				   AND fecha_gen = dFechaGeneracion
				   AND folio_archivo = iFolioArchivo;
			END IF;
            
			LET vBegin = 'N';
		END IF;  -- // Fin de validacion de tipo de empresa externas
        
		-- // Inicio de validacion de tipo de empresa = 2
		IF siTipoEmpresa = 2 THEN
			IF mImporteNoAbonado > 0 THEN
				LET iCodigoEstatus = 3;
			ELSE
				LET iCodigoEstatus = 2;
			END IF;
            
			UPDATE bdicheq:sc_nominaencabezadosumario
			   SET status = iCodigoEstatus,
				   importe_aplicado = mImporteAbonado,
				   importe_no_aplicado = mImporteNoAbonado,
				   folio_dispersion = cNumeroFolio,
				   iva = 0,
				   comision = 0,
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo;
            
			COMMIT WORK;
            
			CALL sp_conciliaciondispersionnomina (cNombreArchivo)
			RETURNING v_cCodRet, cNombreArchivoConciliacion;
            
			CONTINUE FOREACH;
		END IF;  -- // Fin de validacion de tipo de empresa = 2
            
		-- // Procedimiento para generar conciliacion del archivo dispersado
		CALL sp_conciliaciondispersionnomina (cNombreArchivo)
		RETURNING v_cCodRet, cNombreArchivoConciliacion;
        
		CONTINUE FOREACH;
	END FOREACH;
        
	LET vcodret ='00000';
    
	-- // Se Corre este procedimiento para enviar los registros procesados a las tablas historicas.
	EXECUTE PROCEDURE sp_dispersiontraspasomovtos()
	INTO v_cCodRet;
    
	IF v_cCodRet <> "00000" AND v_cCodRet <> "00001" THEN
	   LET vcodret = '100'; --los registros ya fueron enviados a la tabla historica
	END IF;
    
	RETURN vcodret;
    
    END;
    
END PROCEDURE;