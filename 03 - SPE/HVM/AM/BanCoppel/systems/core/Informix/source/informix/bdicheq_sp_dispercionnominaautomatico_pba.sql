CREATE PROCEDURE "informix".sp_dispercionnominaautomatico_pba()
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
	LET mDispCtaBcoppel	= 0.0;
    
    --- SET DEBUG FILE TO '/tmp/sp_dispercionnominaautomatico.out';
	--SET DEBUG FILE TO '/informix/moha/sp_dispercionnominaautomatico.out';
     --TRACE ON;
    
    BEGIN
    
	ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO '/tmp/sp_dispercionnominaautomatico.out';
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
	   AND fecha_aplicacion = dFechaActual;
    
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
    
	FOREACH WITH HOLD
		SELECT empresa, fecha_gen, folio_archivo, nombre_archivo, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot
		  INTO cNumeroEmpresa, dFechaGeneracion, IFolioArchivo, cNombreArchivo, cCuentaEje, dFechaAplicacion, iNumeroRegistros, mImporteTotalEnc
		  FROM bdicheq:sc_nominaencabezadosumario
		 WHERE status = '1'
		   AND fecha_aplicacion <= dFechaActual
		 ORDER BY empresa, nombre_archivo
        
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
            
			LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
			LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
			LET mImporteEmpleadoCuentaEje = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
            
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
				LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
				LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
				LET mImporteEmpleadoComisionMasIva = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
                
                /* Aqui se le resta 1 centavo, porque cuando el saldo inicial de la cuenta eje es igual a la suma del  monto a dispersar + su comision + su iva
				   cuando ya esta en el ultimo empleado el proceso le suma 1 centavo a mTotalCargo + mImporteEmpleadoComisionMasIva, por lo tango el mSaldoActual 
				   es menor que mTotalCargo + mImporteEmpleadoComisionMasIva, cuando la realidad es que deben de ser iguales. */
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
						
						LET mTotalComision = iNumeroRegistrosAplicados * mMontoTransComiDisp;
						LET mTotaliva = mTotalComision * mMontoTransIvaDisp;  --- Nueva Forma de Calcular el Iva
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
            
			IF cProducto <> "2600" THEN
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
						CALL cargo_ref ("001", cSucursalCargo, "informix", cTransacIvaDisp, "0000", cNumeroFolio,cCuentaEje, 0, mTotaliva, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
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
    
END PROCEDURE

DOCUMENT
'MODIFICO :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se valida Si la empresa es interna y su concepto distinto a nomina entonces se toma como externa para generar cobros correspondientes.',
'Captacion',
'FECHA : Octubre de 2008',
'VERSION: 200810',
'BD    : BDICHEQ',
'MODIFICO :Cristian Valentina Aguilar',
'DESCRIPCION: El cambio realizado permite que la dispersión de la nómina se ejecute, aún cuando las cuentas estén bloqueadas, dependiendo si el motivo permite cargos o abonos',
'Captacion',
'FECHA : Marzo de 2009',
'VERSION: 200903',
'MODIFICO: Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se optimizo y se generaron 2 procesos de complemento"',
'FECHA: Abril de 2009',
'VERSION: 200904',
'MODIFICO: Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se optimizo para una mejor lectura de codigo y se generaron 2 procesos de complemento donde se valida el estatus de las cuentas y otro que obtiene"',
'las transacciones utilizadas en el proceso de dispercion, adapto para nomina altas nuevas empresa 001',
'FECHA : Octubre de 2009',
'VERSION: 20091013',
'MODIFICO: Valentin Lopez Valenzuela',
'DESCRIPCION: Se cambia los estatus <> 1 por estatus =0, se realiza una consulta al tabla sc_nominamovimientos con left join a la sc_maecheq y se sustituye la funcionalidad del sp_nominatotalivacomision por variables acumuladas.',
'Captacion',
'FECHA : Enero de 2011',
'VERSION: 201101';

CREATE PROCEDURE "informix".sp_ctamec_generarrpthojadefirmas_pba (pEmpresa CHAR(3), pCuenta CHAR(20))

	-- DATOS A REGRESAR --
RETURNING	CHAR(6)		AS COD_RET,			 -- Codigo de retorno
			CHAR(60)	AS MENSAJE_EJEC,	 -- Mensaje de la ejecucion
			CHAR(40)	AS DESC_PRODUCTO,	 -- Descripcion del producto
			CHAR(20)	AS NUM_CTE,			 -- Numero de cliente
			CHAR(104) 	AS NOMBRE_CTE,    	 -- Nombre de cliente
			CHAR(4)		AS COD_SUCURSAL,	 -- Codigo de sucursal
			CHAR(30)	AS DESC_MONEDA,		 -- Descripcion de la moneda
			DATE		AS FECHA_ALTA,		 -- Fecha de alta de la cuenta
			DATE		AS FECHA_MODIFIC,	 -- Fecha de modificacion de firmantes
			CHAR(20)	AS REGIMEN,			 -- Regimen de firma relacionado a la cuenta
			CHAR(20)    AS ESPECIF_MANEJO,	 -- Especificaciones de manejo del regimen de la firma
			CHAR(104)	AS NOMBRE_FIRMANTE1,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE1,
			CHAR(104)	AS NOMBRE_FIRMANTE2,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE2,
			CHAR(104)	AS NOMBRE_FIRMANTE3,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE3,
			CHAR(104)	AS NOMBRE_FIRMANTE4,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE4;
	
	--	VARIABLES CONTROL DE ERRORES --
	
	DEFINE cCodRet			CHAR(6);
	DEFINE sql_err			INTEGER;
	DEFINE cMensaje			CHAR(60);
	
	-- VARIABLES --
	
	DEFINE cNumcte			CHAR(20);
	DEFINE cNombre			CHAR(104);
	DEFINE cCodSuc			CHAR(4);	
	DEFINE cCodProd			CHAR(4);
	DEFINE cNomProd			CHAR(40);
	DEFINE cCodMoneda		CHAR(2);
	DEFINE dfecha_alta		DATE;
	DEFINE cCodRegimen		CHAR(1);
	DEFINE cDescRegimen		CHAR(20);
	DEFINE cCombinacion		CHAR(20);
	DEFINE cDescMoneda		CHAR(30);
	DEFINE dUltModif		DATE;
	DEFINE cNumcteFirm		CHAR(20);
	DEFINE cNombreFirm		CHAR(104);
	DEFINE cNombreFirm1		CHAR(104);
	DEFINE cFirma1          CHAR(20);
	DEFINE cNombreFirm2		CHAR(104);
	DEFINE cFirma2          CHAR(20);
	DEFINE cNombreFirm3		CHAR(104);
	DEFINE cFirma3          CHAR(20);
	DEFINE cNombreFirm4		CHAR(104);
	DEFINE cFirma4          CHAR(20);
    DEFINE sSecuencia       SMALLINT;
    DEFINE iNumRegs         INTEGER;
    DEFINE iContador        INTEGER;
	DEFINE cSufijo          CHAR(60);	--DSB 16/05/2013
	
	-- INICIALIZACION DE VARIABLES --
	
	LET cCodRet			= '000000';
	LET cMensaje		= 'LA EJECUCION SE REALIZO EXITOSAMENTE';
	LET cCodSuc			= '';
	LET cNumcte			= '';
	LET cCodProd		= '';
	LET cNomProd		= '';
	LET cCodMoneda		= '';
	LET cNombre			= '';
	LET dfecha_alta		= '';
	LET cCodRegimen		= '';
	LET cDescRegimen	= '';
	LET cCombinacion	= '';
	LET cDescMoneda		= '';
	LET dUltModif		= '01/01/2000';
	LET cNumcteFirm		= '';
	LET cNombreFirm     = '';
	LET cNombreFirm1    = '';
	LET cFirma1         = 'C A N C E L A D O';
	LET cNombreFirm2    = '';
	LET cFirma2         = 'C A N C E L A D O';
	LET cNombreFirm3    = '';
	LET cFirma3         = 'C A N C E L A D O';
    LET cNombreFirm4    = '';
    LET cFirma4         = 'C A N C E L A D O';
    LET sSecuencia      = 0;
    LET iNumRegs        = 0;
    LET iContador       = 0;
	LET cSufijo         = '';	--DSB 16/05/2013

	-- CONTROL DE ERRORES --	
	BEGIN
	ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            LET cMensaje = 'ERROR INESPERADO EN LA EJECUCION';
			
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
        END IF
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    --SET DEBUG FILE TO "/respaldosbd/joseluis/sp_ctamec_generarrpthojadefirmas.out";
    --TRACE ON;
	
	-- VALIDACION DE PARAMETROS
	IF pEmpresa = '' OR pEmpresa IS NULL OR pCuenta = '' OR pCuenta IS NULL THEN
		LET cCodRet = '100';
		LET cMensaje = 'ERROR EN LOS PARAMETROS; AMBOS PARAMETROS SON OBLIGATORIOS';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
					
	ELIF LENGTH(pEmpresa) <> 3 OR pEmpresa <> '001' THEN
		LET cCodRet = '500';
		LET cMensaje = 'PARAMETRO EMPRESA NO VALIDO; VERIFIQUE';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- CONSULTA DE INFORMACION DE LA CUENTA
	SELECT sucursal, num_cte, producto
	INTO cCodSuc, cNumcte, cCodProd
	FROM bdicheq:'informix'.sc_maechq
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	-- SE VALIDA SI LA CUENTA EXISTE
	IF cNumcte IS NULL OR cNumcte = '' THEN
		LET cCodRet = '200';
		LET cMensaje = 'ERROR; NO EXISTE LA CUENTA';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- SE TOMA INFORMACION DE LA MONEDA
	SELECT nombre, divisa
	INTO cNomProd, cCodMoneda
	FROM bdicheq:'informix'.sc_producto
	WHERE empresa = pEmpresa
	AND producto = cCodProd;
	
	-- SE VALIDA SI EL PRODUCTO EXISTE
	IF cNomProd IS NULL OR cNomProd = '' THEN
		LET cCodRet = '210';
		LET cMensaje = 'ERROR; NO EXISTE EL PRODUCTO';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;

	-- SE TOMA EL NOMBRE DEL CLIENTE .. YA SEA PERSONA FISICA O MORAL
	SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(razon_social)
	INTO cNombre
	FROM bdinteg:'informix'.si_cliente
	WHERE empresa = pEmpresa
	AND numcte = cNumcte;	
	
	--DSB 16/05/2013
	SELECT NVL(descripcion, '')
	INTO cSufijo
	FROM bdinteg:"informix".si_sufijos suf,
	bdinteg:"informix".si_ctepm cte
	WHERE suf.codigo = cte.sufijo 
	AND cte.numcte = cNumCte;
	LET cNombre = TRIM(cNombre)||" "||TRIM(NVL(cSufijo, ''));
	
	-- SE CONSULTA INFORMACION DE LA CUENTA
	SELECT fecha_alta, reg_firmas
	INTO dfecha_alta, cCodRegimen
	FROM bdicheq:'informix'.sc_maenoc
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	-- SE CONSULTA INFORMACION DEL REGIMEN DE FIRMA RELACIONADO CON LA CUENTA
	SELECT descripcion, combinacion
	INTO cDescRegimen, cCombinacion
	FROM bdicntchq:'informix'.sq_catregimen
	WHERE cve_regimen = cCodRegimen;
	
	-- SE VALIDA QUE EL REGIMEN ES CORRECTO
	IF cDescRegimen IS NULL OR cDescRegimen = '' THEN
		LET cCodRet = '220';
		LET cMensaje = 'ERROR; NO EXISTE EL REGIMEN DE FIRMAS';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- SE TOMA INFORMACION DE LA MONEDA
	SELECT descripcion
	INTO cDescMoneda
	FROM bdinteg:'informix'.si_divisas
	WHERE divisa = cCodMoneda;
	
	-- SE VALIDA QUE LA MONEDA EXISTE
	IF cDescMoneda IS NULL OR cDescMoneda = '' THEN
		LET cCodRet = '230';
		LET cMensaje = 'ERROR; NO EXISTE LA MONEDA';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- SE TOMA LA FECHA DEL MAS RECIENTE REGISTRO DE FIRMANTES
	SELECT {+INDEX(bdinteg:si_cterelacionado idx_si_cterelacionado3)} MAX(fecha_insert)
	INTO dUltModif
	FROM bdinteg:'informix'.si_cterelacionado
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	-- SE VALIDA QUE EXISTAN FIRMANTES
	IF dUltModif IS NULL OR dUltModif = '' THEN
		LET cCodRet = '333';
		LET cMensaje = 'LA CUENTA NO TIENE FIRMANTES RELACIONADOS';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	
	ELIF dfecha_alta = dUltModif THEN -- NO EXISTE FECHA DE MODIFICACION, SOLO DE CREACION
		LET dUltModif = '01/01/2000';	
	END IF;
	
	-- SE HACE MAYUSCULA LA DESCRIPCION DEL REGIMEN
	LET cDescRegimen = UPPER(cDescRegimen);	
  
	-- SE CONSULTAN LOS FIRMANTES RELACIONADOS CON LA CUENTA
	FOREACH
		SELECT numcte, secuencia
		INTO cNumcteFirm, sSecuencia
		FROM bdicheq:'informix'.sc_firmantes
		WHERE empresa = pEmpresa
		AND cuenta = pCuenta
		ORDER BY secuencia
		
		-- SE INCREMENTA CONTADOR PARA IDENTIFICAR LA POSICION QUE OCUPARA EN EL REPORTE
		LET iContador = iContador + 1;
		
		-- SE CONSULTA EL NOMBRE DEL FIRMANTE .. SOLO PERSONA FISICA
		SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno)
		INTO cNombreFirm
		FROM bdinteg:'informix'.si_cliente
		WHERE empresa = pEmpresa
		AND numcte = cNumcteFirm;
		
			-- SE VALIDA SI ES EL FIRMANTE TITULAR DE LA CUENTA
			IF iContador = 1 THEN
			   LET cNombreFirm1 = cNombreFirm;
			   IF cNombreFirm1 <> '' THEN
			       LET cFirma1 = '';
			   END IF;
			   
			ELIF iContador = 2 THEN -- SE VALIDA SI ES EL FIRMANTE ADICIONAL 1 DE LA CUENTA
			   LET cNombreFirm2 = cNombreFirm;
			   IF cNombreFirm2 <> '' THEN
			       LET cFirma2 = '';
			   END IF;
			   
			ELIF iContador = 3 THEN -- SE VALIDA SI ES EL FIRMANTE ADICIONAL 2 DE LA CUENTA
			   LET cNombreFirm3 = cNombreFirm;
			   IF cNombreFirm3 <> '' THEN
			       LET cFirma3 = '';
			   END IF;
			   
			ELIF iContador = 4 THEN -- SE VALIDA SI ES EL FIRMANTE ADICIONAL 3 DE LA CUENTA
			   LET cNombreFirm4 = cNombreFirm;
			   IF cNombreFirm4 <> '' THEN
			       LET cFirma4 = '';
			   END IF;

			END IF;
            
	END FOREACH;
		-- SE REALIZA SOLO UN RETORNO QUE INCLUYE TODA LA INFORMACION DE LA CUENTA.
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	
END
END PROCEDURE 
DOCUMENT
'MODIFICO: Valentin Lopez',
'FECHA: 20 de Junio del 2011',
'DESCRIPCION: Procedimiento que llena el reporte de hoja de firmas.',
'VERSION: 20110620.1042',
'BD: BDICHEQ',
'Modifico: Jose Luis Polanco B.',
'Fecha: DSB 16/05/2013',
'Descripcion: Se agrega el "sufijo" a la variable de retorno "cNombre" para que aparesca en los reportes';

CREATE PROCEDURE "informix".sp_rptctasinactivascnvb( pEmpresa CHAR(3), pTipoEjec SMALLINT )
RETURNING CHAR(5), INTEGER;
       
    DEFINE Sql_Err                  INTEGER;
    DEFINE Isam_Err                 INTEGER;
    DEFINE Desc_Err                 CHAR(50);
    DEFINE vCodRet1                 CHAR(5);
    DEFINE vCodRet2                 CHAR(5);
    DEFINE vCodRet3                 CHAR(50);
    DEFINE vContador                INTEGER;
    DEFINE vContador2               INTEGER;
    DEFINE vdFechMovHisOld4         DATE;
    DEFINE vdFechMovHisOld3         DATE;
    DEFINE vdFechMovHisOld2         DATE;
    DEFINE vdFechMovHisOld          DATE;
    DEFINE vdFechMovHis             DATE;
    DEFINE vcCuenta                 CHAR(20);
    DEFINE vcProducto               CHAR(40);
    DEFINE vcNumCte                 CHAR(20);
    DEFINE vcTarjeta                CHAR(16);
    DEFINE vcSucursal               CHAR(4);
    DEFINE vcNombreCte              CHAR(100);
    DEFINE vmSdoActual              DECIMAL(18,2);
    DEFINE vdFechaUltDep            DATE;
    DEFINE vdFechaUltRet            DATE;
    DEFINE vcDomicilio              CHAR(200);
    DEFINE vcCalle                  CHAR(40);
    DEFINE vcNoExt                  CHAR(10);
    DEFINE vcNoInt                  CHAR(10);
    DEFINE vcDepto                  CHAR(10);
    DEFINE vcColonia                CHAR(40);
    DEFINE vcMuicipio               CHAR(30);
    DEFINE vcCiudad                 CHAR(20);
    DEFINE vcEstado                 CHAR(10);
    DEFINE vcCodPos                 CHAR(10);
    DEFINE vdFechaNotific           DATE;
    DEFINE vmSdoInform              DECIMAL(18,2);
    DEFINE vdFechaInactividad       DATE;
    DEFINE vdFechaMov               DATE;
    DEFINE vmMontoMov               DECIMAL(14,2);
    DEFINE iExisteConcentra         SMALLINT;
    DEFINE vdFechaConcentra         DATE;
    DEFINE vmSdoConcentra           DECIMAL(18,2);
    DEFINE vcUsuarioConcentra       CHAR(8);
    DEFINE vcResulConcentra         CHAR(10);
    DEFINE vcFolioConcentra         CHAR(16);
    DEFINE vdFechaDesconcentra      DATE;
    DEFINE vmSdoDesconcentra        DECIMAL(18,2);
    DEFINE vcUsuarioDesconcentra    CHAR(8);
    DEFINE vcFolioDesconcentra      CHAR(16);
    DEFINE vdFechaReConcentra       DATE;
    DEFINE vmSdoReConcentra         DECIMAL(18,2);
    DEFINE vcResulReConcentra       CHAR(10);
    DEFINE vcFolioReConcentra       CHAR(16);
    DEFINE vdFechaTraspBenef        DATE;
    DEFINE vmSdoTraspBenef          DECIMAL(18,2);
    DEFINE vcDescTraspBenef         CHAR(10);
    DEFINE vcResulTraspBenef        CHAR(10);
    DEFINE vcFolioTraspBenef        CHAR(16);
    DEFINE vcUsuarioTraspBenef      CHAR(8);
    DEFINE vdValorSM                DECIMAL(14,2);
    DEFINE vdFechaMin               DATE;
    DEFINE vcStatusMov              CHAR(1);
    
    LET Sql_Err	= 0;
    LET Isam_Err = 0;
    LET Desc_Err = '';
    LET vCodRet1 = '000';
    LET vCodRet2 = '';
    LET vCodRet3 = '';
    LET vContador = 0;
    LET vContador2 = 0;
    LET vdFechMovHisOld4 = '';
    LET vdFechMovHisOld3 = '';
    LET vdFechMovHisOld2 = '';
    LET vdFechMovHisOld = '';
    LET vdFechMovHis = '';
    LET vcCuenta = '';
    LET vcProducto = '';
    LET vcNumCte = '';
    LET vcTarjeta = '';
    LET vcSucursal = '';
    LET vcNombreCte = '';
    LET vmSdoActual = 0.00;
    LET vdFechaUltDep = '';
    LET vdFechaUltRet = '';
    LET vcDomicilio = '';
    LET vcCalle = '';
    LET vcNoExt = '';
    LET vcNoInt = '';
    LET vcDepto = '';
    LET vcColonia = '';
    LET vcMuicipio = '';
    LET vcCiudad = '';
    LET vcEstado = '';
    LET vcCodPos = '';
    LET vdFechaNotific = '';
    LET vmSdoInform = '';
    LET vdFechaInactividad = '';
    LET vdFechaMov = '';
    LET vmMontoMov = 0.00;
    LET iExisteConcentra = 0;
    LET vdFechaConcentra = '';
    LET vmSdoConcentra = 0.00;
    LET vcUsuarioConcentra = '';
    LET vcResulConcentra = '';
    LET vcFolioConcentra = '';
    LET vdFechaDesconcentra = '';
    LET vmSdoDesconcentra = 0.00;
    LET vcUsuarioDesconcentra = '';
    LET vcFolioDesconcentra = '';
    LET vdFechaReConcentra = '';
    LET vmSdoReConcentra = 0.00;
    LET vcResulReConcentra = '';
    LET vcFolioReConcentra = '';
    LET vdFechaTraspBenef = '';
    LET vmSdoTraspBenef = 0.00;
    LET vcDescTraspBenef = '';
    LET vcResulTraspBenef = '';
    LET vcFolioTraspBenef = '';
    LET vcUsuarioTraspBenef = '';
    LET vdValorSM = 0.00;
    LET vdFechaMin = '';
    LET vcStatusMov = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/jivan/sp_rptctasinactivascnvb.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            LET vcCuenta = vcCuenta;
            RETURN vCodRet1, vContador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/jivan/sp_rptctasinactivascnvb.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    CREATE TEMP TABLE sc_rptctasinactivascnvb
      (
        producto char(40),
        numcte char(20),
        num_tarjeta char(16),
        cuenta char(20),
        sucursal char(4),
        nombre_cte char(100),
        sdo_actual decimal(18,2), 
        fecha_inactividad date,
        fecha_ult_dep date,
        fecha_ult_ret date,
        domicilio char(200),
        calle char(40),
        no_ext char(10),
        no_int char(10),
        depto char(10),
        colonia char(40),
        muicipio char(30),
        ciudad char(20),
        estado char(10),
        cod_pos char(10),
        fecha_notific date,
        sdo_inform decimal(18,2),
        fecha_mov date,
        monto_mov decimal(14,2),
        status_cta char(1),
        fecha_concentra date,
        sdo_concentra decimal(18,2),
        usuario_concentra char(8),
        resul_concentra char(10),
        folio_concentra char(16),
        fecha_desconcentra date,
        sdo_desconcentra decimal(18,2),
        usuario_desconcentra char(8),
        folio_desconcentra char(16),
        fecha_reconcentra date,
        sdo_reconcentra decimal(18,2),
        resul_reconcentra char(10),
        folio_reconcentra char(16),
        fecha_trasp_benef date,
        sdo_trasp_benef decimal(18,2),
        desc_trasp_benef char(10),
        resul_trasp_benef char(10),
        folio_trasp_benef char(16),
        usuario_trasp_benef char(8)
      ) 
    WITH NO LOG LOCK MODE ROW;
    
    SELECT valor * 300
      INTO vdValorSM
      FROM sc_param
     WHERE codparam = 'smdf';
    
    SELECT valor
      INTO vdFechMovHisOld4
      FROM sc_param
     WHERE codparam = 'FechaIniMovhisOld4';
     
    SELECT valor
      INTO vdFechMovHisOld3
      FROM sc_param
     WHERE codparam = 'vfechconmovhisold3';
     
    SELECT valor
      INTO vdFechMovHisOld2
      FROM sc_param
     WHERE codparam = 'FechaIniMovhisOld2';
     
    SELECT valor
      INTO vdFechMovHisOld
      FROM sc_param
     WHERE codparam = 'FechIniCon_movhis_ol';
     
    SELECT valor
      INTO vdFechMovHis
      FROM sc_param
     WHERE codparam = 'fechcon_movhis';
     
    SELECT ina.cuenta
      FROM sc_ctasinformadas ina,
           sc_ctasinactinfor3anios inf
     WHERE ina.cuenta = inf.cuenta
    INTO TEMP tmp_ctasinactivas WITH NO LOG;
    CREATE INDEX idxtmp_ctasinactivas_cta ON tmp_ctasinactivas(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctasinactivas;
    
    SELECT UNIQUE cuenta
      FROM tmp_ctasinactivas
    INTO TEMP tmp_ctainactiva WITH NO LOG;
    CREATE INDEX idxtmp_ctainactiva_cta ON tmp_ctainactiva(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctainactiva;
    
    IF pTipoEjec = 1 THEN
        FOREACH 
            SELECT ina.cuenta
              INTO vcCuenta
              FROM tmp_ctainactiva ina
             WHERE ina.cuenta IN ( SELECT cuenta FROM sc_maechq WHERE cuenta = ina.cuenta AND status_cta IN('5','6','7','8') )
             
            SELECT MIN(fecha_rep) 
              INTO vdFechaMin
              FROM sc_ctasinactinfor3anios 
             WHERE cuenta = vcCuenta;
              
            SELECT UNIQUE inf.producto, inf.num_cte, inf.num_tarjeta, mae.sucursal, inf.cliente, mae.sdo_actual, inf.fech_ult_dep, inf.fech_ult_ret,
                   inf.domicilio, inf.calle, inf.no_ext, inf.no_int, inf.depto, inf.colonia, inf.municipio, inf.ciudad, inf.estado, inf.codpos,
                   inf.fecha_rep, inf.sdo_actual
              INTO vcProducto, vcNumCte, vcTarjeta, vcSucursal, vcNombreCte, vmSdoActual, vdFechaUltDep, vdFechaUltRet, 
                   vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos,
                   vdFechaNotific, vmSdoInform
              FROM sc_ctasinactinfor3anios inf,
                   sc_maechq mae,
                   sc_maenoc noc
             WHERE inf.cuenta = vcCuenta
               AND inf.fecha_rep = vdFechaMin
               AND inf.cuenta = mae.cuenta
               AND mae.empresa = noc.empresa
               AND mae.cuenta = noc.cuenta;
            
            -- // CALCULA FECHA DE INACTIVIDAD
            IF vdFechaUltRet >= vdFechaUltDep THEN
                LET vdFechaInactividad = vdFechaUltRet + 3 UNITS YEAR;
            ELSE
                LET vdFechaInactividad = vdFechaUltDep + 3 UNITS YEAR;
            END IF;
            
            -- // VERIFICA SI LA CUENTA TUVO MOVIMIENTOS PARA ACTIVARSE
            SELECT FIRST 1 fech_alt, monto_tot
              INTO vdFechaMov, vmMontoMov
              FROM sc_movhis_old4
             WHERE empresa = pEmpresa
               AND cuenta = vcCuenta
               AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
               AND fech_alt > vdFechaNotific
               AND cancelad <> 'S'
               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
               AND num_serial = ( SELECT MIN(num_serial)
                                    FROM sc_movhis_old4
                                   WHERE empresa = pEmpresa
                                     AND cuenta = vcCuenta
                                     AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                     AND fech_alt > vdFechaNotific
                                     AND cancelad <> 'S' 
                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
            
            IF vdFechaMov is null OR vdFechaMov = '' THEN
                SELECT FIRST 1 fech_alt, monto_tot
                  INTO vdFechaMov, vmMontoMov
                  FROM sc_movhis_old3
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                   AND fech_alt > vdFechaNotific
                   AND cancelad <> 'S'
                   AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old3
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                         AND fech_alt > vdFechaNotific
                                         AND cancelad <> 'S'
                                         AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                
                IF vdFechaMov is null OR vdFechaMov = '' THEN
                    SELECT FIRST 1 fech_alt, monto_tot
                      INTO vdFechaMov, vmMontoMov
                      FROM sc_movhis_old2
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                       AND fech_alt > vdFechaNotific
                       AND cancelad <> 'S'
                       AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old2
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                             AND fech_alt > vdFechaNotific
                                             AND cancelad <> 'S'
                                             AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                             
                    IF vdFechaMov is null OR vdFechaMov = '' THEN
                        SELECT FIRST 1 fech_alt, monto_tot
                          INTO vdFechaMov, vmMontoMov
                          FROM sc_movhis_old
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                           AND fech_alt > vdFechaNotific
                           AND cancelad <> 'S'
                           AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                 AND fech_alt > vdFechaNotific
                                                 AND cancelad <> 'S' 
                                                 AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                                 
                        IF vdFechaMov is null OR vdFechaMov = '' THEN
                            SELECT FIRST 1 fech_alt, monto_tot
                              INTO vdFechaMov, vmMontoMov
                              FROM sc_movhis
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND fech_alt >= vdFechMovHis
                               AND fech_alt > vdFechaNotific
                               AND cancelad <> 'S'
                               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND fech_alt >= vdFechMovHis
                                                     AND fech_alt > vdFechaNotific
                                                     AND cancelad <> 'S' 
                                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                        END IF;
                    END IF;
                END IF;
            END IF;
            
            IF vdFechaMov is not null OR vdFechaMov <> '' THEN
                LET vdFechaMov = vdFechaMov;
                LET vmMontoMov = vmMontoMov;
                LET vcStatusMov = '1';
            ELSE
                LET vdFechaMov = '';
                LET vmMontoMov = null;
                LET vcStatusMov = '';
            END IF;
            
            -- // VERIFICA SI LA CUENTA SE CONCENTRO, DESCONCENTRO, RE-CONCENTRO Y TRASPASO
            SELECT COUNT(*)
              INTO iExisteConcentra
              FROM sc_cuentas_concentradas
             WHERE cuenta = vcCuenta;
             
            IF iExisteConcentra > 0 THEN
                SELECT UNIQUE fecha_concentra, sdo_concentrado, folio, fecha_pago_concentra, pago_sdo_concentra, fecha_trasp_benefic, sdo_trasp_beneficiencia
                  INTO vdFechaConcentra, vmSdoConcentra, vcFolioConcentra, vdFechaDesconcentra, vmSdoDesconcentra, vdFechaTraspBenef, vmSdoTraspBenef
                  FROM sc_cuentas_concentradas
                 WHERE cuenta = vcCuenta;
                 
                LET vcUsuarioConcentra = 'informix';
                LET vcResulConcentra = 'EXITOSO';
                
                -- // VERIFICA DATOS DE LA DESCONCENTRACION
                IF vdFechaDesconcentra is not null OR vdFechaDesconcentra <> '' THEN
                    SELECT FIRST 1 usuario, folio_suc
                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                      FROM sc_movhis_old4
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0324'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old4
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0324');
                                             
                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                        SELECT FIRST 1 usuario, folio_suc
                          INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                          FROM sc_movhis_old3
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0324'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old3
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0324');
                        
                        IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                            SELECT FIRST 1 usuario, folio_suc
                              INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                              FROM sc_movhis_old2
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0324'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old2
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0324');
                                                     
                            IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                SELECT FIRST 1 usuario, folio_suc
                                  INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                  FROM sc_movhis_old
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0324'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis_old
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0324');
                                                         
                                IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                    SELECT FIRST 1 usuario, folio_suc
                                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                      FROM sc_movhis
                                     WHERE empresa = pEmpresa
                                       AND cuenta = vcCuenta
                                       AND fech_alt >= vdFechMovHis
                                       AND fech_alt > vdFechaConcentra
                                       AND cancelad <> 'S'
                                       AND transacc = '0324'
                                       AND num_serial = ( SELECT MIN(num_serial)
                                                            FROM sc_movhis
                                                           WHERE empresa = pEmpresa
                                                             AND cuenta = vcCuenta
                                                             AND fech_alt >= vdFechMovHis
                                                             AND fech_alt > vdFechaConcentra
                                                             AND cancelad <> 'S'
                                                             AND transacc = '0324');
                                                             
                                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                        LET vdFechaDesconcentra = '';
                                        LET vmSdoDesconcentra = null;
                                        LET vcUsuarioDesconcentra = '';
                                        LET vcFolioDesconcentra = '';
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                -- // VERIFICA DATOS DE LA RE-CONCENTRACION
                SELECT FIRST 1 fech_alt, folio_suc
                  INTO vdFechaReConcentra, vcFolioReConcentra
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0320'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0320');
                       
                IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                    SELECT FIRST 1 fech_alt, folio_suc
                      INTO vdFechaReConcentra, vcFolioReConcentra
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0320'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0320');
                                             
                    IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                        SELECT FIRST 1 fech_alt, folio_suc
                          INTO vdFechaReConcentra, vcFolioReConcentra
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0320'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0320');
                                                 
                        IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                            SELECT FIRST 1 fech_alt, folio_suc
                              INTO vdFechaReConcentra, vcFolioReConcentra
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0320'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0320');
                                                     
                            IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                                SELECT FIRST 1 fech_alt, folio_suc
                                  INTO vdFechaReConcentra, vcFolioReConcentra
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0320'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0320');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF vdFechaReConcentra is not null OR vdFechaReConcentra <> '' THEN
                    LET vdFechaReConcentra = vdFechaReConcentra;
                    LET vmSdoReConcentra = vmSdoConcentra;
                    LET vcResulReConcentra = 'EXITOSO';
                    LET vcFolioReConcentra = vcFolioReConcentra;
                ELSE
                    LET vdFechaReConcentra = '';
                    LET vmSdoReConcentra = null;
                    LET vcResulReConcentra = '';
                    LET vcFolioReConcentra = '';
                END IF;
                
                -- // VALIDA DATOS DE TRASPASO A LA BENEFICENCIA PUBLICA
                SELECT FIRST 1 folio_suc
                  INTO vcFolioTraspBenef
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0322'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0322');
                       
                IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                    SELECT FIRST 1 folio_suc
                      INTO vcFolioTraspBenef
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0322'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0322');
                                             
                    IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                        SELECT FIRST 1 folio_suc
                          INTO vcFolioTraspBenef
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0322'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0322');
                                                 
                        IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                            SELECT FIRST 1 folio_suc
                              INTO vcFolioTraspBenef
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0322'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0322');
                                                     
                            IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                                SELECT FIRST 1 folio_suc
                                  INTO vcFolioTraspBenef
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0322'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0322');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef <= vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = vmSdoTraspBenef;
                    LET vcDescTraspBenef = 'SPEI';
                    LET vcResulTraspBenef = 'EXITOSO';
                    LET vcFolioTraspBenef = vcFolioTraspBenef;
                    LET vcUsuarioTraspBenef = 'informix';
                ELIF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef > vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = 0.00;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = 'EXCEDE 300 DSMGVDF';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                ELSE
                    LET vdFechaTraspBenef = '';
                    LET vmSdoTraspBenef = null;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = '';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                END IF;
            ELSE
                LET vdFechaConcentra = '';
                LET vmSdoConcentra = null;
                LET vcUsuarioConcentra = '';
                LET vcResulConcentra = '';
                LET vcFolioConcentra = '';
                LET vdFechaDesconcentra = '';
                LET vmSdoDesconcentra = null;
                LET vcUsuarioDesconcentra = '';
                LET vcFolioDesconcentra = '';
                LET vdFechaReConcentra = '';
                LET vmSdoReConcentra = null;
                LET vcResulReConcentra = '';
                LET vcFolioReConcentra = '';
                LET vdFechaTraspBenef = '';
                LET vmSdoTraspBenef = null;
                LET vcDescTraspBenef = '';
                LET vcResulTraspBenef = '';
                LET vcFolioTraspBenef = '';
                LET vcUsuarioTraspBenef = '';
            END IF;
            
            INSERT INTO sc_rptctasinactivascnvb VALUES
            ( vcProducto, vcNumCte, vcTarjeta, vcCuenta, vcSucursal, vcNombreCte, vmSdoActual, 
              vdFechaInactividad, vdFechaUltDep, vdFechaUltRet, 
              vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos, 
              vdFechaNotific, vmSdoInform, 
              vdFechaMov, vmMontoMov, vcStatusMov, 
              vdFechaConcentra, vmSdoConcentra, vcUsuarioConcentra, vcResulConcentra, vcFolioConcentra,
              vdFechaDesconcentra, vmSdoDesconcentra, vcUsuarioDesconcentra, vcFolioDesconcentra,
              vdFechaReConcentra, vmSdoReConcentra, vcResulReConcentra, vcFolioReConcentra,
              vdFechaTraspBenef, vmSdoTraspBenef, vcDescTraspBenef, vcResulTraspBenef, vcFolioTraspBenef, vcUsuarioTraspBenef );
            
            LET vContador = vContador + 1;
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                EXIT FOREACH;
            END IF;
            
            LET vcCuenta = '';
            LET vcProducto = '';
            LET vcNumCte = '';
            LET vcTarjeta = '';
            LET vcSucursal = '';
            LET vcNombreCte = '';
            LET vmSdoActual = 0.00;
            LET vdFechaUltDep = '';
            LET vdFechaUltRet = '';
            LET vcDomicilio = '';
            LET vcCalle = '';
            LET vcNoExt = '';
            LET vcNoInt = '';
            LET vcDepto = '';
            LET vcColonia = '';
            LET vcMuicipio = '';
            LET vcCiudad = '';
            LET vcEstado = '';
            LET vcCodPos = '';
            LET vdFechaNotific = '';
            LET vmSdoInform = '';
            LET vdFechaInactividad = '';
            LET vdFechaMov = '';
            LET vmMontoMov = 0.00;
            LET iExisteConcentra = 0;
            LET vdFechaConcentra = '';
            LET vmSdoConcentra = 0.00;
            LET vcUsuarioConcentra = '';
            LET vcResulConcentra = '';
            LET vcFolioConcentra = '';
            LET vdFechaDesconcentra = '';
            LET vmSdoDesconcentra = 0.00;
            LET vcUsuarioDesconcentra = '';
            LET vcFolioDesconcentra = '';
            LET vdFechaReConcentra = '';
            LET vmSdoReConcentra = 0.00;
            LET vcResulReConcentra = '';
            LET vcFolioReConcentra = '';
            LET vdFechaTraspBenef = '';
            LET vmSdoTraspBenef = 0.00;
            LET vcDescTraspBenef = '';
            LET vcResulTraspBenef = '';
            LET vcFolioTraspBenef = '';
            LET vcUsuarioTraspBenef = '';
            LET vdFechaMin = '';
        END FOREACH;   
        
        LET vContador2 = 0;
        
        FOREACH 
            SELECT ina.cuenta
              INTO vcCuenta
              FROM tmp_ctainactiva ina
             WHERE ina.cuenta IN ( SELECT cuenta FROM sc_maechq WHERE cuenta = ina.cuenta AND status_cta = '1' )
             
            SELECT MIN(fecha_rep) 
              INTO vdFechaMin
              FROM sc_ctasinactinfor3anios 
             WHERE cuenta = vcCuenta;
              
            SELECT UNIQUE inf.producto, inf.num_cte, inf.num_tarjeta, mae.sucursal, inf.cliente, mae.sdo_actual, inf.fech_ult_dep, inf.fech_ult_ret,
                   inf.domicilio, inf.calle, inf.no_ext, inf.no_int, inf.depto, inf.colonia, inf.municipio, inf.ciudad, inf.estado, inf.codpos,
                   inf.fecha_rep, inf.sdo_actual
              INTO vcProducto, vcNumCte, vcTarjeta, vcSucursal, vcNombreCte, vmSdoActual, vdFechaUltDep, vdFechaUltRet, 
                   vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos,
                   vdFechaNotific, vmSdoInform
              FROM sc_ctasinactinfor3anios inf,
                   sc_maechq mae,
                   sc_maenoc noc
             WHERE inf.cuenta = vcCuenta
               AND inf.fecha_rep = vdFechaMin
               AND inf.cuenta = mae.cuenta
               AND mae.empresa = noc.empresa
               AND mae.cuenta = noc.cuenta;
            
            -- // CALCULA FECHA DE INACTIVIDAD
            IF vdFechaUltRet >= vdFechaUltDep THEN
                LET vdFechaInactividad = vdFechaUltRet + 3 UNITS YEAR;
            ELSE
                LET vdFechaInactividad = vdFechaUltDep + 3 UNITS YEAR;
            END IF;
            
            -- // VERIFICA SI LA CUENTA TUVO MOVIMIENTOS PARA ACTIVARSE
            SELECT FIRST 1 fech_alt, monto_tot
              INTO vdFechaMov, vmMontoMov
              FROM sc_movhis_old4
             WHERE empresa = pEmpresa
               AND cuenta = vcCuenta
               AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
               AND fech_alt > vdFechaNotific
               AND cancelad <> 'S'
               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
               AND num_serial = ( SELECT MIN(num_serial)
                                    FROM sc_movhis_old4
                                   WHERE empresa = pEmpresa
                                     AND cuenta = vcCuenta
                                     AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                     AND fech_alt > vdFechaNotific
                                     AND cancelad <> 'S' 
                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
            
            IF vdFechaMov is null OR vdFechaMov = '' THEN
                SELECT FIRST 1 fech_alt, monto_tot
                  INTO vdFechaMov, vmMontoMov
                  FROM sc_movhis_old3
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                   AND fech_alt > vdFechaNotific
                   AND cancelad <> 'S'
                   AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old3
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                         AND fech_alt > vdFechaNotific
                                         AND cancelad <> 'S'
                                         AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                
                IF vdFechaMov is null OR vdFechaMov = '' THEN
                    SELECT FIRST 1 fech_alt, monto_tot
                      INTO vdFechaMov, vmMontoMov
                      FROM sc_movhis_old2
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                       AND fech_alt > vdFechaNotific
                       AND cancelad <> 'S'
                       AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old2
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                             AND fech_alt > vdFechaNotific
                                             AND cancelad <> 'S'
                                             AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                             
                    IF vdFechaMov is null OR vdFechaMov = '' THEN
                        SELECT FIRST 1 fech_alt, monto_tot
                          INTO vdFechaMov, vmMontoMov
                          FROM sc_movhis_old
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                           AND fech_alt > vdFechaNotific
                           AND cancelad <> 'S'
                           AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                 AND fech_alt > vdFechaNotific
                                                 AND cancelad <> 'S' 
                                                 AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                                 
                        IF vdFechaMov is null OR vdFechaMov = '' THEN
                            SELECT FIRST 1 fech_alt, monto_tot
                              INTO vdFechaMov, vmMontoMov
                              FROM sc_movhis
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND fech_alt >= vdFechMovHis
                               AND fech_alt > vdFechaNotific
                               AND cancelad <> 'S'
                               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND fech_alt >= vdFechMovHis
                                                     AND fech_alt > vdFechaNotific
                                                     AND cancelad <> 'S' 
                                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                        END IF;
                    END IF;
                END IF;
            END IF;
            
            IF vdFechaMov is not null OR vdFechaMov <> '' THEN
                LET vdFechaMov = vdFechaMov;
                LET vmMontoMov = vmMontoMov;
                LET vcStatusMov = '1';
            ELSE
                LET vdFechaMov = '';
                LET vmMontoMov = null;
                LET vcStatusMov = '';
            END IF;
            
            -- // VERIFICA SI LA CUENTA SE CONCENTRO, DESCONCENTRO, RE-CONCENTRO Y TRASPASO
            SELECT COUNT(*)
              INTO iExisteConcentra
              FROM sc_cuentas_concentradas
             WHERE cuenta = vcCuenta;
             
            IF iExisteConcentra > 0 THEN
                SELECT UNIQUE fecha_concentra, sdo_concentrado, folio, fecha_pago_concentra, pago_sdo_concentra, fecha_trasp_benefic, sdo_trasp_beneficiencia
                  INTO vdFechaConcentra, vmSdoConcentra, vcFolioConcentra, vdFechaDesconcentra, vmSdoDesconcentra, vdFechaTraspBenef, vmSdoTraspBenef
                  FROM sc_cuentas_concentradas
                 WHERE cuenta = vcCuenta;
                 
                LET vcUsuarioConcentra = 'informix';
                LET vcResulConcentra = 'EXITOSO';
                
                -- // VERIFICA DATOS DE LA DESCONCENTRACION
                IF vdFechaDesconcentra is not null OR vdFechaDesconcentra <> '' THEN
                    SELECT FIRST 1 usuario, folio_suc
                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                      FROM sc_movhis_old4
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0324'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old4
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0324');
                                             
                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                        SELECT FIRST 1 usuario, folio_suc
                          INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                          FROM sc_movhis_old3
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0324'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old3
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0324');
                        
                        IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                            SELECT FIRST 1 usuario, folio_suc
                              INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                              FROM sc_movhis_old2
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0324'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old2
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0324');
                                                     
                            IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                SELECT FIRST 1 usuario, folio_suc
                                  INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                  FROM sc_movhis_old
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0324'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis_old
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0324');
                                                         
                                IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                    SELECT FIRST 1 usuario, folio_suc
                                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                      FROM sc_movhis
                                     WHERE empresa = pEmpresa
                                       AND cuenta = vcCuenta
                                       AND fech_alt >= vdFechMovHis
                                       AND fech_alt > vdFechaConcentra
                                       AND cancelad <> 'S'
                                       AND transacc = '0324'
                                       AND num_serial = ( SELECT MIN(num_serial)
                                                            FROM sc_movhis
                                                           WHERE empresa = pEmpresa
                                                             AND cuenta = vcCuenta
                                                             AND fech_alt >= vdFechMovHis
                                                             AND fech_alt > vdFechaConcentra
                                                             AND cancelad <> 'S'
                                                             AND transacc = '0324');
                                                             
                                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                        LET vdFechaDesconcentra = '';
                                        LET vmSdoDesconcentra = null;
                                        LET vcUsuarioDesconcentra = '';
                                        LET vcFolioDesconcentra = '';
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                -- // VERIFICA DATOS DE LA RE-CONCENTRACION
                SELECT FIRST 1 fech_alt, folio_suc
                  INTO vdFechaReConcentra, vcFolioReConcentra
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0320'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0320');
                       
                IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                    SELECT FIRST 1 fech_alt, folio_suc
                      INTO vdFechaReConcentra, vcFolioReConcentra
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0320'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0320');
                                             
                    IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                        SELECT FIRST 1 fech_alt, folio_suc
                          INTO vdFechaReConcentra, vcFolioReConcentra
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0320'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0320');
                                                 
                        IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                            SELECT FIRST 1 fech_alt, folio_suc
                              INTO vdFechaReConcentra, vcFolioReConcentra
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0320'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0320');
                                                     
                            IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                                SELECT FIRST 1 fech_alt, folio_suc
                                  INTO vdFechaReConcentra, vcFolioReConcentra
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0320'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0320');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF vdFechaReConcentra is not null OR vdFechaReConcentra <> '' THEN
                    LET vdFechaReConcentra = vdFechaReConcentra;
                    LET vmSdoReConcentra = vmSdoConcentra;
                    LET vcResulReConcentra = 'EXITOSO';
                    LET vcFolioReConcentra = vcFolioReConcentra;
                ELSE
                    LET vdFechaReConcentra = '';
                    LET vmSdoReConcentra = null;
                    LET vcResulReConcentra = '';
                    LET vcFolioReConcentra = '';
                END IF;
                
                -- // VALIDA DATOS DE TRASPASO A LA BENEFICENCIA PUBLICA
                SELECT FIRST 1 folio_suc
                  INTO vcFolioTraspBenef
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0322'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0322');
                       
                IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                    SELECT FIRST 1 folio_suc
                      INTO vcFolioTraspBenef
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0322'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0322');
                                             
                    IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                        SELECT FIRST 1 folio_suc
                          INTO vcFolioTraspBenef
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0322'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0322');
                                                 
                        IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                            SELECT FIRST 1 folio_suc
                              INTO vcFolioTraspBenef
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0322'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0322');
                                                     
                            IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                                SELECT FIRST 1 folio_suc
                                  INTO vcFolioTraspBenef
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0322'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0322');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef <= vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = vmSdoTraspBenef;
                    LET vcDescTraspBenef = 'SPEI';
                    LET vcResulTraspBenef = 'EXITOSO';
                    LET vcFolioTraspBenef = vcFolioTraspBenef;
                    LET vcUsuarioTraspBenef = 'informix';
                ELIF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef > vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = 0.00;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = 'EXCEDE 300 DSMGVDF';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                ELSE
                    LET vdFechaTraspBenef = '';
                    LET vmSdoTraspBenef = null;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = '';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                END IF;
            ELSE
                LET vdFechaConcentra = '';
                LET vmSdoConcentra = null;
                LET vcUsuarioConcentra = '';
                LET vcResulConcentra = '';
                LET vcFolioConcentra = '';
                LET vdFechaDesconcentra = '';
                LET vmSdoDesconcentra = null;
                LET vcUsuarioDesconcentra = '';
                LET vcFolioDesconcentra = '';
                LET vdFechaReConcentra = '';
                LET vmSdoReConcentra = null;
                LET vcResulReConcentra = '';
                LET vcFolioReConcentra = '';
                LET vdFechaTraspBenef = '';
                LET vmSdoTraspBenef = null;
                LET vcDescTraspBenef = '';
                LET vcResulTraspBenef = '';
                LET vcFolioTraspBenef = '';
                LET vcUsuarioTraspBenef = '';
            END IF;
            
            INSERT INTO sc_rptctasinactivascnvb VALUES
            ( vcProducto, vcNumCte, vcTarjeta, vcCuenta, vcSucursal, vcNombreCte, vmSdoActual, 
              vdFechaInactividad, vdFechaUltDep, vdFechaUltRet, 
              vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos, 
              vdFechaNotific, vmSdoInform, 
              vdFechaMov, vmMontoMov, vcStatusMov, 
              vdFechaConcentra, vmSdoConcentra, vcUsuarioConcentra, vcResulConcentra, vcFolioConcentra,
              vdFechaDesconcentra, vmSdoDesconcentra, vcUsuarioDesconcentra, vcFolioDesconcentra,
              vdFechaReConcentra, vmSdoReConcentra, vcResulReConcentra, vcFolioReConcentra,
              vdFechaTraspBenef, vmSdoTraspBenef, vcDescTraspBenef, vcResulTraspBenef, vcFolioTraspBenef, vcUsuarioTraspBenef );
            
            LET vContador = vContador + 1;
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                EXIT FOREACH;
            END IF;
            
            LET vcCuenta = '';
            LET vcProducto = '';
            LET vcNumCte = '';
            LET vcTarjeta = '';
            LET vcSucursal = '';
            LET vcNombreCte = '';
            LET vmSdoActual = 0.00;
            LET vdFechaUltDep = '';
            LET vdFechaUltRet = '';
            LET vcDomicilio = '';
            LET vcCalle = '';
            LET vcNoExt = '';
            LET vcNoInt = '';
            LET vcDepto = '';
            LET vcColonia = '';
            LET vcMuicipio = '';
            LET vcCiudad = '';
            LET vcEstado = '';
            LET vcCodPos = '';
            LET vdFechaNotific = '';
            LET vmSdoInform = '';
            LET vdFechaInactividad = '';
            LET vdFechaMov = '';
            LET vmMontoMov = 0.00;
            LET iExisteConcentra = 0;
            LET vdFechaConcentra = '';
            LET vmSdoConcentra = 0.00;
            LET vcUsuarioConcentra = '';
            LET vcResulConcentra = '';
            LET vcFolioConcentra = '';
            LET vdFechaDesconcentra = '';
            LET vmSdoDesconcentra = 0.00;
            LET vcUsuarioDesconcentra = '';
            LET vcFolioDesconcentra = '';
            LET vdFechaReConcentra = '';
            LET vmSdoReConcentra = 0.00;
            LET vcResulReConcentra = '';
            LET vcFolioReConcentra = '';
            LET vdFechaTraspBenef = '';
            LET vmSdoTraspBenef = 0.00;
            LET vcDescTraspBenef = '';
            LET vcResulTraspBenef = '';
            LET vcFolioTraspBenef = '';
            LET vcUsuarioTraspBenef = '';
            LET vdFechaMin = '';
        END FOREACH;   
    ELSE
        FOREACH 
            SELECT cuenta
              INTO vcCuenta
              FROM tmp_ctainactiva
              
            SELECT MIN(fecha_rep) 
              INTO vdFechaMin
              FROM sc_ctasinactinfor3anios 
             WHERE cuenta = vcCuenta;
        
            SELECT UNIQUE inf.producto, inf.num_cte, inf.num_tarjeta, mae.sucursal, inf.cliente, mae.sdo_actual, inf.fech_ult_dep, inf.fech_ult_ret,
                   inf.domicilio, inf.calle, inf.no_ext, inf.no_int, inf.depto, inf.colonia, inf.municipio, inf.ciudad, inf.estado, inf.codpos,
                   inf.fecha_rep, inf.sdo_actual
              INTO vcProducto, vcNumCte, vcTarjeta, vcSucursal, vcNombreCte, vmSdoActual, vdFechaUltDep, vdFechaUltRet, 
                   vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos,
                   vdFechaNotific, vmSdoInform
              FROM sc_ctasinactinfor3anios inf,
                   sc_maechq mae,
                   sc_maenoc noc
             WHERE inf.cuenta = vcCuenta
               AND inf.fecha_rep = vdFechaMin
               AND inf.cuenta = mae.cuenta
               AND mae.empresa = noc.empresa
               AND mae.cuenta = noc.cuenta;
            
            -- // CALCULA FECHA DE INACTIVIDAD
            IF vdFechaUltRet >= vdFechaUltDep THEN
                LET vdFechaInactividad = vdFechaUltRet + 3 UNITS YEAR;
            ELSE
                LET vdFechaInactividad = vdFechaUltDep + 3 UNITS YEAR;
            END IF;
            
            -- // VERIFICA SI LA CUENTA TUVO MOVIMIENTOS PARA ACTIVARSE
            SELECT FIRST 1 fech_alt, monto_tot
              INTO vdFechaMov, vmMontoMov
              FROM sc_movhis_old4
             WHERE empresa = pEmpresa
               AND cuenta = vcCuenta
               AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
               AND fech_alt > vdFechaNotific
               AND cancelad <> 'S'
               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
               AND num_serial = ( SELECT MIN(num_serial)
                                    FROM sc_movhis_old4
                                   WHERE empresa = pEmpresa
                                     AND cuenta = vcCuenta
                                     AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                     AND fech_alt > vdFechaNotific
                                     AND cancelad <> 'S' 
                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
            
            IF vdFechaMov is null OR vdFechaMov = '' THEN
                SELECT FIRST 1 fech_alt, monto_tot
                  INTO vdFechaMov, vmMontoMov
                  FROM sc_movhis_old3
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                   AND fech_alt > vdFechaNotific
                   AND cancelad <> 'S'
                   AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old3
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                         AND fech_alt > vdFechaNotific
                                         AND cancelad <> 'S'
                                         AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                
                IF vdFechaMov is null OR vdFechaMov = '' THEN
                    SELECT FIRST 1 fech_alt, monto_tot
                      INTO vdFechaMov, vmMontoMov
                      FROM sc_movhis_old2
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                       AND fech_alt > vdFechaNotific
                       AND cancelad <> 'S'
                       AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old2
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                             AND fech_alt > vdFechaNotific
                                             AND cancelad <> 'S'
                                             AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                             
                    IF vdFechaMov is null OR vdFechaMov = '' THEN
                        SELECT FIRST 1 fech_alt, monto_tot
                          INTO vdFechaMov, vmMontoMov
                          FROM sc_movhis_old
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                           AND fech_alt > vdFechaNotific
                           AND cancelad <> 'S'
                           AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                 AND fech_alt > vdFechaNotific
                                                 AND cancelad <> 'S' 
                                                 AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                                                 
                        IF vdFechaMov is null OR vdFechaMov = '' THEN
                            SELECT FIRST 1 fech_alt, monto_tot
                              INTO vdFechaMov, vmMontoMov
                              FROM sc_movhis
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND fech_alt >= vdFechMovHis
                               AND fech_alt > vdFechaNotific
                               AND cancelad <> 'S'
                               AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' )
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND fech_alt >= vdFechMovHis
                                                     AND fech_alt > vdFechaNotific
                                                     AND cancelad <> 'S' 
                                                     AND transacc NOT IN ( '0320','0321','0322','0323','0324','0242' ) );
                        END IF;
                    END IF;
                END IF;
            END IF;
            
            IF vdFechaMov is not null OR vdFechaMov <> '' THEN
                LET vdFechaMov = vdFechaMov;
                LET vmMontoMov = vmMontoMov;
                LET vcStatusMov = '1';
            ELSE
                LET vdFechaMov = '';
                LET vmMontoMov = null;
                LET vcStatusMov = '';
            END IF;
            
            -- // VERIFICA SI LA CUENTA SE CONCENTRO, DESCONCENTRO, RE-CONCENTRO Y TRASPASO
            SELECT COUNT(*)
              INTO iExisteConcentra
              FROM sc_cuentas_concentradas
             WHERE cuenta = vcCuenta;
             
            IF iExisteConcentra > 0 THEN
                SELECT UNIQUE fecha_concentra, sdo_concentrado, folio, fecha_pago_concentra, pago_sdo_concentra, fecha_trasp_benefic, sdo_trasp_beneficiencia
                  INTO vdFechaConcentra, vmSdoConcentra, vcFolioConcentra, vdFechaDesconcentra, vmSdoDesconcentra, vdFechaTraspBenef, vmSdoTraspBenef
                  FROM sc_cuentas_concentradas
                 WHERE cuenta = vcCuenta;
                 
                LET vcUsuarioConcentra = 'informix';
                LET vcResulConcentra = 'EXITOSO';
                
                -- // VERIFICA DATOS DE LA DESCONCENTRACION
                IF vdFechaDesconcentra is not null OR vdFechaDesconcentra <> '' THEN
                    SELECT FIRST 1 usuario, folio_suc
                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                      FROM sc_movhis_old4
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0324'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old4
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0324');
                                             
                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                        SELECT FIRST 1 usuario, folio_suc
                          INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                          FROM sc_movhis_old3
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0324'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old3
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0324');
                        
                        IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                            SELECT FIRST 1 usuario, folio_suc
                              INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                              FROM sc_movhis_old2
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0324'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old2
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0324');
                                                     
                            IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                SELECT FIRST 1 usuario, folio_suc
                                  INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                  FROM sc_movhis_old
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0324'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis_old
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0324');
                                                         
                                IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                    SELECT FIRST 1 usuario, folio_suc
                                      INTO vcUsuarioDesconcentra, vcFolioDesconcentra
                                      FROM sc_movhis
                                     WHERE empresa = pEmpresa
                                       AND cuenta = vcCuenta
                                       AND fech_alt >= vdFechMovHis
                                       AND fech_alt > vdFechaConcentra
                                       AND cancelad <> 'S'
                                       AND transacc = '0324'
                                       AND num_serial = ( SELECT MIN(num_serial)
                                                            FROM sc_movhis
                                                           WHERE empresa = pEmpresa
                                                             AND cuenta = vcCuenta
                                                             AND fech_alt >= vdFechMovHis
                                                             AND fech_alt > vdFechaConcentra
                                                             AND cancelad <> 'S'
                                                             AND transacc = '0324');
                                                             
                                    IF vcFolioDesconcentra is null OR vcFolioDesconcentra = '' THEN
                                        LET vdFechaDesconcentra = '';
                                        LET vmSdoDesconcentra = null;
                                        LET vcUsuarioDesconcentra = '';
                                        LET vcFolioDesconcentra = '';
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                -- // VERIFICA DATOS DE LA RE-CONCENTRACION
                SELECT FIRST 1 fech_alt, folio_suc
                  INTO vdFechaReConcentra, vcFolioReConcentra
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0320'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0320');
                       
                IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                    SELECT FIRST 1 fech_alt, folio_suc
                      INTO vdFechaReConcentra, vcFolioReConcentra
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0320'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0320');
                                             
                    IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                        SELECT FIRST 1 fech_alt, folio_suc
                          INTO vdFechaReConcentra, vcFolioReConcentra
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0320'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0320');
                                                 
                        IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                            SELECT FIRST 1 fech_alt, folio_suc
                              INTO vdFechaReConcentra, vcFolioReConcentra
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0320'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0320');
                                                     
                            IF vdFechaReConcentra is null OR vdFechaReConcentra = '' THEN
                                SELECT FIRST 1 fech_alt, folio_suc
                                  INTO vdFechaReConcentra, vcFolioReConcentra
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0320'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0320');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF vdFechaReConcentra is not null OR vdFechaReConcentra <> '' THEN
                    LET vdFechaReConcentra = vdFechaReConcentra;
                    LET vmSdoReConcentra = vmSdoConcentra;
                    LET vcResulReConcentra = 'EXITOSO';
                    LET vcFolioReConcentra = vcFolioReConcentra;
                ELSE
                    LET vdFechaReConcentra = '';
                    LET vmSdoReConcentra = null;
                    LET vcResulReConcentra = '';
                    LET vcFolioReConcentra = '';
                END IF;
                
                -- // VALIDA DATOS DE TRASPASO A LA BENEFICENCIA PUBLICA
                SELECT FIRST 1 folio_suc
                  INTO vcFolioTraspBenef
                  FROM sc_movhis_old4
                 WHERE empresa = pEmpresa
                   AND cuenta = vcCuenta
                   AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                   AND fech_alt > vdFechaConcentra
                   AND cancelad <> 'S'
                   AND transacc = '0322'
                   AND num_serial = ( SELECT MIN(num_serial)
                                        FROM sc_movhis_old4
                                       WHERE empresa = pEmpresa
                                         AND cuenta = vcCuenta
                                         AND ( fech_alt >= vdFechMovHisOld4 AND fech_alt < vdFechMovHisOld3 )
                                         AND fech_alt > vdFechaConcentra
                                         AND cancelad <> 'S'
                                         AND transacc = '0322');
                       
                IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                    SELECT FIRST 1 folio_suc
                      INTO vcFolioTraspBenef
                      FROM sc_movhis_old3
                     WHERE empresa = pEmpresa
                       AND cuenta = vcCuenta
                       AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                       AND fech_alt > vdFechaConcentra
                       AND cancelad <> 'S'
                       AND transacc = '0322'
                       AND num_serial = ( SELECT MIN(num_serial)
                                            FROM sc_movhis_old3
                                           WHERE empresa = pEmpresa
                                             AND cuenta = vcCuenta
                                             AND ( fech_alt >= vdFechMovHisOld3 AND fech_alt < vdFechMovHisOld2 )
                                             AND fech_alt > vdFechaConcentra
                                             AND cancelad <> 'S'
                                             AND transacc = '0322');
                                             
                    IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                        SELECT FIRST 1 folio_suc
                          INTO vcFolioTraspBenef
                          FROM sc_movhis_old2
                         WHERE empresa = pEmpresa
                           AND cuenta = vcCuenta
                           AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                           AND fech_alt > vdFechaConcentra
                           AND cancelad <> 'S'
                           AND transacc = '0322'
                           AND num_serial = ( SELECT MIN(num_serial)
                                                FROM sc_movhis_old2
                                               WHERE empresa = pEmpresa
                                                 AND cuenta = vcCuenta
                                                 AND ( fech_alt >= vdFechMovHisOld2 AND fech_alt < vdFechMovHisOld )
                                                 AND fech_alt > vdFechaConcentra
                                                 AND cancelad <> 'S'
                                                 AND transacc = '0322');
                                                 
                        IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                            SELECT FIRST 1 folio_suc
                              INTO vcFolioTraspBenef
                              FROM sc_movhis_old
                             WHERE empresa = pEmpresa
                               AND cuenta = vcCuenta
                               AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                               AND fech_alt > vdFechaConcentra
                               AND cancelad <> 'S'
                               AND transacc = '0322'
                               AND num_serial = ( SELECT MIN(num_serial)
                                                    FROM sc_movhis_old
                                                   WHERE empresa = pEmpresa
                                                     AND cuenta = vcCuenta
                                                     AND ( fech_alt >= vdFechMovHisOld AND fech_alt < vdFechMovHis )
                                                     AND fech_alt > vdFechaConcentra
                                                     AND cancelad <> 'S'
                                                     AND transacc = '0322');
                                                     
                            IF vcFolioTraspBenef is null OR vcFolioTraspBenef = '' THEN
                                SELECT FIRST 1 folio_suc
                                  INTO vcFolioTraspBenef
                                  FROM sc_movhis
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vcCuenta
                                   AND fech_alt >= vdFechMovHis 
                                   AND fech_alt > vdFechaConcentra
                                   AND cancelad <> 'S'
                                   AND transacc = '0322'
                                   AND num_serial = ( SELECT MIN(num_serial)
                                                        FROM sc_movhis
                                                       WHERE empresa = pEmpresa
                                                         AND cuenta = vcCuenta
                                                         AND fech_alt >= vdFechMovHis 
                                                         AND fech_alt > vdFechaConcentra
                                                         AND cancelad <> 'S'
                                                         AND transacc = '0322');
                            END IF;
                        END IF;
                    END IF;
                END IF;
                
                IF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef <= vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = vmSdoTraspBenef;
                    LET vcDescTraspBenef = 'SPEI';
                    LET vcResulTraspBenef = 'EXITOSO';
                    LET vcFolioTraspBenef = vcFolioTraspBenef;
                    LET vcUsuarioTraspBenef = 'informix';
                ELIF ( ( vdFechaTraspBenef is not null OR vdFechaTraspBenef <> '' ) AND vmSdoTraspBenef > vdValorSM ) THEN
                    LET vdFechaTraspBenef = vdFechaTraspBenef;
                    LET vmSdoTraspBenef = 0.00;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = 'EXCEDE 300 DSMGVDF';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                ELSE
                    LET vdFechaTraspBenef = '';
                    LET vmSdoTraspBenef = null;
                    LET vcDescTraspBenef = '';
                    LET vcResulTraspBenef = '';
                    LET vcFolioTraspBenef = '';
                    LET vcUsuarioTraspBenef = '';
                END IF;
            ELSE
                LET vdFechaConcentra = '';
                LET vmSdoConcentra = null;
                LET vcUsuarioConcentra = '';
                LET vcResulConcentra = '';
                LET vcFolioConcentra = '';
                LET vdFechaDesconcentra = '';
                LET vmSdoDesconcentra = null;
                LET vcUsuarioDesconcentra = '';
                LET vcFolioDesconcentra = '';
                LET vdFechaReConcentra = '';
                LET vmSdoReConcentra = null;
                LET vcResulReConcentra = '';
                LET vcFolioReConcentra = '';
                LET vdFechaTraspBenef = '';
                LET vmSdoTraspBenef = null;
                LET vcDescTraspBenef = '';
                LET vcResulTraspBenef = '';
                LET vcFolioTraspBenef = '';
                LET vcUsuarioTraspBenef = '';
            END IF;
            
            INSERT INTO sc_rptctasinactivascnvb VALUES
            ( vcProducto, vcNumCte, vcTarjeta, vcCuenta, vcSucursal, vcNombreCte, vmSdoActual, 
              vdFechaInactividad, vdFechaUltDep, vdFechaUltRet, 
              vcDomicilio, vcCalle, vcNoExt, vcNoInt, vcDepto, vcColonia, vcMuicipio, vcCiudad, vcEstado, vcCodPos, 
              vdFechaNotific, vmSdoInform, 
              vdFechaMov, vmMontoMov, vcStatusMov, 
              vdFechaConcentra, vmSdoConcentra, vcUsuarioConcentra, vcResulConcentra, vcFolioConcentra,
              vdFechaDesconcentra, vmSdoDesconcentra, vcUsuarioDesconcentra, vcFolioDesconcentra,
              vdFechaReConcentra, vmSdoReConcentra, vcResulReConcentra, vcFolioReConcentra,
              vdFechaTraspBenef, vmSdoTraspBenef, vcDescTraspBenef, vcResulTraspBenef, vcFolioTraspBenef, vcUsuarioTraspBenef );
            
            LET vContador = vContador + 1;
            
            LET vcCuenta = '';
            LET vcProducto = '';
            LET vcNumCte = '';
            LET vcTarjeta = '';
            LET vcSucursal = '';
            LET vcNombreCte = '';
            LET vmSdoActual = 0.00;
            LET vdFechaUltDep = '';
            LET vdFechaUltRet = '';
            LET vcDomicilio = '';
            LET vcCalle = '';
            LET vcNoExt = '';
            LET vcNoInt = '';
            LET vcDepto = '';
            LET vcColonia = '';
            LET vcMuicipio = '';
            LET vcCiudad = '';
            LET vcEstado = '';
            LET vcCodPos = '';
            LET vdFechaNotific = '';
            LET vmSdoInform = '';
            LET vdFechaInactividad = '';
            LET vdFechaMov = '';
            LET vmMontoMov = 0.00;
            LET iExisteConcentra = 0;
            LET vdFechaConcentra = '';
            LET vmSdoConcentra = 0.00;
            LET vcUsuarioConcentra = '';
            LET vcResulConcentra = '';
            LET vcFolioConcentra = '';
            LET vdFechaDesconcentra = '';
            LET vmSdoDesconcentra = 0.00;
            LET vcUsuarioDesconcentra = '';
            LET vcFolioDesconcentra = '';
            LET vdFechaReConcentra = '';
            LET vmSdoReConcentra = 0.00;
            LET vcResulReConcentra = '';
            LET vcFolioReConcentra = '';
            LET vdFechaTraspBenef = '';
            LET vmSdoTraspBenef = 0.00;
            LET vcDescTraspBenef = '';
            LET vcResulTraspBenef = '';
            LET vcFolioTraspBenef = '';
            LET vcUsuarioTraspBenef = '';
        END FOREACH;   
    END IF;
    
    CREATE INDEX idxtmp_rptctasinactivascnvb_cta ON sc_rptctasinactivascnvb(cuenta) ONLINE;
    CREATE INDEX idxtmp_rptctasinactivascnvb_cte ON sc_rptctasinactivascnvb(numcte) ONLINE;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_rptctasinactivascnvb;
    
    END;
     
    RETURN vCodRet1, vContador;
     
END PROCEDURE;