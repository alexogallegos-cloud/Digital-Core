CREATE PROCEDURE "informix".sp_dispercionnominamanual( cNumeroEmpresa   CHAR(3),
                                                       dFechaGeneracion DATE,
                                                       IFolioArchivo    INTEGER,
                                                       cUsuarioAutoriza CHAR(8),
                                                       cNombreUsuario   CHAR(8) )
--- Se necesita regresar de retorno el monto total de lo que se aplico.
--- RETURNING CHAR(5), CHAR(100), CHAR(50), MONEY(14,2), MONEY(14,2), MONEY(14,2), CHAR(18), CHAR(8);
RETURNING CHAR(5), CHAR(100), CHAR(50), CHAR(19), CHAR(19), CHAR(19), CHAR(18), CHAR(8);
    
    -- *******************************************************************************************************
    -- Realizo   : Martin Valenzuela Ojeda, Armando Mercado
    -- Proyecto  : Dispercion Nomina BanCoppel
    -- Actividad : Ejecuta el proceso para la dispercion de la nomina, actualiza el campo status en el detalle de aquellos empleados
    --             que si se les ejecuto el pago de la nomina y aquellos que por algun motivo no se les disperso su sueldo. 
    --             Tambien actualiza el encabezado para aquellos archivos que fueron dispersados, ejecutando las validaciones correspondientes. 
    --             Este store sera ejecutado para un Archivo cada vez.
    -- Fecha     : Abril de 2008
    -- *******************************************************************************************************
    
    DEFINE dFechaActual                     DATE ;
    DEFINE cEstatusCta                      CHAR(1) ;
    DEFINE cNumeroCuentaEmpleado            CHAR(20);
    DEFINE cNumeroEmpleado                  CHAR(10);
    DEFINE mImporteEmpleado                 MONEY(14,3);
    DEFINE dFechaAplicacion                 DATE ;
    DEFINE cHoraActual                      DATETIME HOUR TO SECOND ;
    DEFINE cNumeroTarjeta                   CHAR(20);
    DEFINE mImporteAbonado                  MONEY(16,3);
    DEFINE mImporteNoAbonado                MONEY(16,3);
    DEFINE mImporteTotalAplicado            MONEY(16,3);
    DEFINE siSaldoDisponible                SMALLINT ;
    DEFINE mTotalNoPagado                   MONEY(16,3);
    DEFINE mTotalComisionDispercionIvaEmp   MONEY(14,3);
    DEFINE mImporteTotalEnc                 MONEY(14,3);
    DEFINE mSaldoActual                     MONEY(16,3);
    DEFINE iNumeroRegistros                 INTEGER ;
    DEFINE cNombreArchivo                   CHAR(17);
    DEFINE siEmpleadoNoAplicado             SMALLINT ;
    DEFINE bPrimerEmpleado                  BOOLEAN ;
    DEFINE bSiguienteEmpleado               BOOLEAN ;
    DEFINE cCodRet                          CHAR(3);
    DEFINE cMensaje                         CHAR(100);
    DEFINE mTotaliva                        MONEY(14,3);
    DEFINE mTotalComision                   MONEY(14,3);
    DEFINE iCodigoEstatus                   INTEGER ;
    DEFINE bParametroErroneo                BOOLEAN  ;
    DEFINE vsqlerr                          INTEGER ;
    DEFINE vcodret                          VARCHAR(6);
    DEFINE p_mensaje                        VARCHAR(100);
    DEFINE cNumeroFolio                     CHAR(16);
    DEFINE siSecuencia                      SMALLINT ;
    DEFINE cNombre                          CHAR(30);
    DEFINE bExisteDetalle                   BOOLEAN ;
    DEFINE vtranret                         CHAR(4);
    DEFINE vfechoy                          DATE ;
    DEFINE vsdodisp                         MONEY(14,2);
    DEFINE vmontoret                        MONEY(14,2);
    DEFINE cFolioDispercion                 CHAR(50);
    DEFINE mComisionAplicado                MONEY(16,3);
    DEFINE mIvaAplicado                     MONEY(16,3);
    DEFINE cNombreArchivoConciliacion       CHAR(20);
    DEFINE cNumeroTransaccion               CHAR(10);
    DEFINE cCuentaEje                       CHAR(20);    
    DEFINE cProducto                        CHAR(20);

    -- // Variables del sp: conciliacionDispercionNomina
    DEFINE v_cCodRet                        CHAR(5);
    DEFINE v_cCuentaCar                     CHAR(20);
    DEFINE v_mSdoDiaAnt                     MONEY;
    DEFINE v_mSdoActual                     MONEY;
    DEFINE v_dFechaGen                      DATE;
    DEFINE v_dFechaApli                     DATE;
    DEFINE v_mMontoTot                      MONEY;
    DEFINE v_iTotRegApli                    INTEGER;
    DEFINE v_mMontoTotCom                   MONEY;
    DEFINE v_mMontoTotIva                   MONEY;
    DEFINE v_mComDis                        MONEY;
    DEFINE v_mIvaDis                        MONEY;
    DEFINE v_cHoraAplicada                  CHAR(8);
    DEFINE v_cNomArchivo                    CHAR(20);
    
    DEFINE siValorConcepto                  SMALLINT ;
    DEFINE siValorConceptoAnterior          SMALLINT ;
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
    DEFINE cTransaccComiDisp                CHAR(4);    --Aqui se traera el 0394
    DEFINE cTransaccIvaDisp                 CHAR(4);    --Aqui se traera el 0396
    DEFINE mImporteEmpleadoCuentaEje        MONEY(16,3);
    DEFINE mImporteEmpleadoComisionMasIva   MONEY(16,3);
    DEFINE mImporteAcumuladoEnc             MONEY(16,3);
    DEFINE iNumeroCuentas                   INTEGER ;
    DEFINE cImporteTotalAplicadoCh          CHAR(19);
    DEFINE cComisionAplicadoCh              CHAR(19);
    DEFINE cIvaAplicadoCh                   CHAR(19);
    DEFINE iLargoImporte                    INTEGER ;
    DEFINE iLargoComision                   INTEGER ;
    DEFINE iLargoIva                        INTEGER ;
    DEFINE cEstatusCuenta                   CHAR(1);
    DEFINE vcodretCargo1                    CHAR(6);
    DEFINE vcodretCargo2                    CHAR(6);
    DEFINE vcodretCargo3                    CHAR(6);
    DEFINE vBegin                           CHAR(1);
    DEFINE mIvaPorEmpleado                  MONEY(16,3);
    DEFINE siTipoEmpresa                    SMALLINT ;
    DEFINE cSucursalAbono                   CHAR(4);
    DEFINE cSucursalCargo                   CHAR(4);
    DEFINE cRecDatoNoUtilizableNOperacion   CHAR(4);
    DEFINE cMotivo              			CHAR(2);
    DEFINE cAbono               			CHAR(2);
    DEFINE cCargo               			CHAR(2);
    DEFINE cAceptaProducto               	CHAR(50);
    DEFINE iContador						INTEGER;
    DEFINE siValorStatus					SMALLINT;
    DEFINE iNumeroRegistrosAplicados        INTEGER ;
    DEFINE cTransacIvaDisp                  CHAR(4);    -- // Aqui se traera el 0396
	--RobertoCastro para cuentas que no se les cobra comision 27/02/2023
	DEFINE vExcentaComision					INTEGER;
	DEFINE cProductoEje                     CHAR(20);

    LET cTransacIvaDisp = '';
    LET iNumeroRegistrosAplicados = 0;
    LET siValorStatus = 0;
    LET p_mensaje = " ";
    LET siEmpleadoNoAplicado = 0;
    LET dFechaActual = '' ;
    LET cEstatusCta = '' ;
    LET cNumeroCuentaEmpleado = '';
    LET cNumeroEmpleado = '';
    LET mImporteEmpleado = 0;
    LET dFechaAplicacion = '';
    LET cHoraActual = '' ;
    LET cNumeroTarjeta = '';
    LET mImporteAbonado = 0;
    LET mImporteNoAbonado = 0;
    LET mImporteTotalAplicado = 0;
    LET siSaldoDisponible = 0 ;
    LET mTotalNoPagado = 0;
    LET mTotalComisionDispercionIvaEmp = 0;
    LET mImporteTotalEnc = 0;
    LET mSaldoActual = 0;
    LET iNumeroRegistros = 0;
    LET iCodigoEstatus = 0;
    LET bPrimerEmpleado = "T" ;
    LET bSiguienteEmpleado = "F" ;
    LET bParametroErroneo = "F";
    LET siSecuencia = 0;
    LET cNombre = "";
    LET bExisteDetalle = "F";
    LET cFolioDispercion = "";
    LET mImporteTotalAplicado = 0;
    LET mComisionAplicado = 0;
    LET mIvaAplicado = 0;
    LET cNombreArchivoConciliacion = "";
    LET cNumeroFolio = "";
    LET v_mComDis = 0.00;
    LET  v_mIvaDis  = 0.00;
    LET v_cHoraAplicada = "";
    LET  v_cNomArchivo  = "";
    LET siValorConcepto = 0;
    LET siValorConceptoAnterior = 0;
    LET cValorTransaccion = '';
    LET cValorTipoTransaccion = '';
    LET cTransaccAbono = '';
    LET cTransaccCargo = '';
    LET mMontoTransComiDisp = 0;
    LET mMontoTransComiAper = 0;
    LET mMontoTransIvaDisp = 0;
    LET mMontoTransIvaAper = 0;
    LET mMontoFijo = 0;
    LET mTotalPagado = 0;
    LET mTotalCargo = 0;
    LET cTransaccComiDisp = '';
    LET cTransaccIvaDisp = '';
    LET mImporteTotalEnc = 0;
    LET mImporteEmpleadoCuentaEje = 0;
    LET mImporteEmpleadoComisionMasIva = 0;
    LET mImporteAcumuladoEnc = 0;
    LET iNumeroCuentas = 0;
    LET cImporteTotalAplicadoCh = "";
    LET cComisionAplicadoCh = "";
    LET cIvaAplicadoCh = "";
    LET iLargoImporte = 0;
    LET iLargoComision = 0;
    LET iLargoIva = 0;
    LET cEstatusCuenta = '';
    LET vBegin = 'S';
    LET mIvaPorEmpleado = 0;
    LET siTipoEmpresa = 0;
    LET cSucursalAbono = '';
    LET cSucursalCargo = '';
    LET cMotivo='';
    LET cAbono='';
    LET cCargo='';
    LET cAceptaProducto = '';
    LET iContador = 0;
	
	--RobertoCastro para cuentas que no se les cobra comision 27/02/2023
	LET vExcentaComision = 0;
	LET cProductoEje = '';
    
    --- SET DEBUG FILE TO "/tmp/sp_dispercionnominamanual_Actualizado.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
            LET vcodret = vsqlerr;
            LET p_mensaje  = "Dispercion No Ejecutada";
            LET cFolioDispercion = "";
            LET mImporteTotalAplicado = 0;
            LET mComisionAplicado = 0;
            LET mIvaAplicado = 0;
            LET cNombreArchivoConciliacion = "";
            LET cHoraActual = "";
            LET cImporteTotalAplicadoCh = "0.00";
            LET cComisionAplicadoCh = "0.00";
            LET cIvaAplicadoCh = "0.00";
            IF vBegin = 'S' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
        END IF;
    END EXCEPTION;
	
	SET ISOLATION TO CURSOR STABILITY;
	SET LOCK MODE TO WAIT 10;
    
    -- // VALIDACIONES DE PARAMETROS
    IF (cNumeroEmpresa = '000') OR (cNumeroEmpresa = "") OR (cNumeroEmpresa IS NULL) THEN
        LET bParametroErroneo = "T";
    ElIF (dFechaGeneracion = "") OR (dFechaGeneracion = "") OR (dFechaGeneracion IS NULL) THEN
        LET bParametroErroneo = "T";
    ElIF (IFolioArchivo = 0) OR (IFolioArchivo = "") OR (IFolioArchivo IS NULL) THEN
        LET bParametroErroneo = "T";
    ElIF (cUsuarioAutoriza = '00000000') OR (cUsuarioAutoriza = "") OR (cUsuarioAutoriza IS NULL) THEN
        LET bParametroErroneo = "T";
    ElIF (cNombreUsuario = '00000000') OR (cNombreUsuario = "") OR (cNombreUsuario IS NULL) THEN
        LET bParametroErroneo = "T";
    END IF
    
    -- // INICIALIZO VARIABLES
    LET cFolioDispercion = "";  --
    LET mImporteTotalAplicado = 0;
    LET mComisionAplicado = 0;
    LET mIvaAplicado = 0;
    LET cNombreArchivoConciliacion = "";
    LET cHoraActual = "";
    LET cImporteTotalAplicadoCh = "0.00";
    LET cComisionAplicadoCh = "0.00";
    LET cIvaAplicadoCh = "0.00";
    LET vcodret = '000';
    
    IF bParametroErroneo = "T" THEN
        LET vcodret = '800';
        LET p_mensaje = "Dispercion No Ejecutada: Parametros Incorrectos";
        RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
    END IF
    
    BEGIN WORK;
    LET vBegin = 'S';
    LET vcodret = '000';
    
    IF NOT EXISTS ( SELECT empresa FROM sc_nominaencabezadosumario WHERE empresa = cNumeroEmpresa AND fecha_gen = dFechaGeneracion AND folio_archivo = IFolioArchivo AND status = '1' ) THEN
        LET vcodret = '805';
        LET p_mensaje = "Dispercion No Ejecutada: No Existe el Encabezado del Archivo o el Estatus No es el Correcto";
        COMMIT WORK;
        LET vBegin = 'N';
        RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
    END IF
    
    SELECT fecha_aplicacion, Importe_tot, Total_registros, nombre_archivo, cuenta_cargo
      INTO dFechaAplicacion, mImporteTotalEnc, iNumeroRegistros, cNombreArchivo, cCuentaEje
      FROM bdicheq:sc_nominaencabezadosumario
     WHERE empresa = cNumeroEmpresa 
       AND fecha_gen = dFechaGeneracion 
       AND folio_archivo = IFolioArchivo;
    
    SELECT tipo_empresa, TRIM(acepta_producto) 
      INTO siTipoEmpresa, cAceptaProducto 
      FROM bdicheq:sc_nominaempresas 
     WHERE codigo = cNumeroEmpresa;
    
    SELECT LIMIT 1 concepto, nombre_archivo 
      INTO siValorConcepto, cNombre 
      FROM bdicheq:sc_nominamovimientos 
     WHERE nombre_archivo = cNombreArchivo;
    
    -- // Cambio Validacion para que si la empresa es interna pero tiene un concepto dIFerente a nomina se tome como externa para el cobro de impuestos
    IF (siTipoEmpresa = 2) AND (siValorConcepto <> 1) AND (siValorConcepto <> 5) THEN
        LET siTipoEmpresa = 1;
    END IF
    
    SELECT fecha_hoy 
	  INTO dFechaActual 
	  FROM bdicheq:sc_fechas
	 WHERE empresa = "001";
	 
    LET cHoraActual = CURRENT ;
    
    --  **************************************************** INICIO de validacion de tipo de empresa externa ****************************************************
    IF siTipoEmpresa <> 2 THEN
        IF NOT EXISTS (SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cCuentaEje) THEN
            LET vcodret  = "810";
            LET p_mensaje = "El Numero de Cuenta Eje NO Existe en la Base de Datos";
            
            UPDATE bdicheq:sc_nominaencabezadosumario  -- Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo
               SET status = '7', 
                   fecha_aplicado = dFechaActual, 
                   hora_aplicado = cHoraActual
             WHERE empresa = cNumeroEmpresa 
               AND fecha_gen = dFechaGeneracion 
               AND folio_archivo = IFolioArchivo;
               
            COMMIT WORK;
            LET vBegin = 'N';
            RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
        END IF
        
        CALL sp_dispersionnominavalidacionestatus(cCuentaEje, cNumeroEmpresa, dFechaGeneracion, IFolioArchivo,dFechaActual,cHoraActual,'', '', '', '', '')
        RETURNING vcodret,cEstatusCuenta,cCargo,mImporteNoAbonado,cSucursalCargo,cRecDatoNoUtilizableNOperacion;
        
        IF cEstatusCuenta = '2' THEN
            LET vcodret = "815";
            LET p_mensaje = "El Numero de Cuenta Eje esta Cancelada";
            COMMIT WORK;
            LET vBegin = 'N';
            RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
        END IF
        
        IF cCargo = 'N' THEN
            COMMIT WORK;
            LET vBegin = 'N';
            RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
        END IF
    END IF
    -- **************************************************** FIN de validacion de tipo de empresa externa ****************************************************
    
	IF dFechaAplicacion > dFechaActual THEN
		LET vcodret = '825';
		LET p_mensaje = "Dispercion No Ejecutada: La Fecha de Aplicacion es Mayor de la Fecha Actual";
		COMMIT WORK;
		LET vBegin = 'N';
		RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
	END IF
    
    IF dFechaAplicacion <= dFechaActual THEN
        IF (cNombre IS NULL) OR (cNombre = "") OR (cNombre = " ") THEN
            LET vcodret = '830';
            LET p_mensaje = "Dispercion No Ejecutada: Existe el Encabezado Pero No Existe el Detalle del Archivo";
            
            UPDATE bdicheq:sc_nominaencabezadosumario
                SET status = '6', 
                    fecha_aplicado = dFechaActual, 
                    hora_aplicado = cHoraActual
             WHERE empresa = cNumeroEmpresa 
               AND fecha_gen = dFechaGeneracion 
               AND folio_archivo = IFolioArchivo;
               
            COMMIT WORK;
            LET vBegin = 'N';
            RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
        END IF
        
        LET mTotalNoPagado = 0;
        LET mImporteAbonado = 0;
        LET mImporteNoAbonado = 0;
        LET mImporteTotalAplicado = 0;
        
        SELECT LIMIT 1 concepto 
          INTO siValorConcepto 
          FROM bdicheq:sc_nominamovimientos
         WHERE nombre_archivo = cNombreArchivo 
           AND status = '0';
        
        -- ******************************************************** INICIO de validacion de tipo de empresa externa ********************************************************
        IF siTipoEmpresa <> 2 THEN
			--RobertoCastro para cuentas que no se les cobra comision 27/02/2023
            SELECT sdo_actual, producto 
              INTO mSaldoActual, cProductoEje
              FROM bdicheq:sc_maechq  
             WHERE empresa = '001' 
               AND cuenta = cCuentaEje;
            
            IF mSaldoActual <= 0 THEN
                LET siSaldoDisponible = 0;
                LET vcodret = '835';
                LET p_mensaje = "Dispercion No Ejecutada: La Cuenta Eje No Tiene Saldo";
                
                UPDATE bdicheq:sc_nominaencabezadosumario
                   SET status = '5', 
                       fecha_aplicado = dFechaActual, 
                       hora_aplicado = cHoraActual
                 WHERE empresa = cNumeroEmpresa 
                   AND fecha_gen = dFechaGeneracion 
                   AND folio_archivo = IFolioArchivo;
                   
                COMMIT WORK;
                LET vBegin = 'N';
                RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
            ELSE
				--RobertoCastro para cuentas que no se les cobra comision 27/02/2023
				SELECT COUNT(1) INTO vExcentaComision FROM bdicheq:sc_nominaexcentocomision WHERE producto = cProductoEje;
                LET siSaldoDisponible = 1;
            END IF
        END IF
        -- ******************************************************** FIN de validacion de tipo de empresa externa ********************************************************
        
        -- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
        --- CALL sp_dispersionnominatransacciones(siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
        CALL sp_dispersionnominatransacciones(siTipoEmpresa, siValorConcepto)
        RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo, cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransaccIvaDisp, mMontoTransIvaAper;
		
		
        
        IF vcodret <> '000' THEN
            IF vcodret = '840'   THEN
                LET p_mensaje = "Dispercion No Ejecutada: El Numero de Transaccion de Abono No es Valido";
            ElIF vcodret = '845' THEN
                LET p_mensaje = "Dispercion No Ejecutada: El Numero de Transaccion del Cargo No es Valido";
            ElIF vcodret = '850' THEN
                LET p_mensaje = "Dispercion No Ejecutada: El Numero de Transaccion de la Comision no es Valido";
            ElIF vcodret = '855' THEN
                LET p_mensaje = "Dispercion No Ejecutada: El Numero de Transaccion del Iva No es Valido";
            END IF
            
            ROLLBACK WORK;
            LET vBegin = 'N';
            RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
        END IF
        
        LET siValorConceptoAnterior = 0;  -- Aqui inicializo la variable cada vez que se vaya a procesar otro archivo
        
        -- ******************************************************** INICIO de validacion de tipo de empresa externa ********************************************************
        IF siTipoEmpresa <> 2 THEN
            -- // Inicio de Nuevo Codigo
            SELECT valor 
			  INTO mMontoTransIvaDisp 
			  FROM bdinteg:si_param   -- Aqui se obtiene el valor del Iva
             WHERE cod_param = 47
			   AND empresa = "001";
			   
            IF (mMontoTransIvaDisp = "") OR (mMontoTransIvaDisp = " ") OR (mMontoTransIvaDisp IS NULL) THEN
                LET vcodret = '855';  -- Dispercion No Ejecutada: El Numero de Transaccion del Iva No es Valido
                LET p_mensaje = "Dispercion No Ejecutada: El Valor del Iva No es Valido";
                ROLLBACK WORK;
                LET vBegin = 'N';
                RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
            END IF
            -- // Fin de Nuevo Codigo
        END IF
        -- ********************************************************  FIN de validacion de tipo de empresa externa  ********************************************************
        
        FOREACH WITH HOLD
            SELECT mov.num_empleado, mov.cuenta_abono, mov.importe, mov.concepto, mae.status_cta, mae.producto
		      INTO cNumeroEmpleado, cNumeroCuentaEmpleado, mImporteEmpleado, siValorConcepto,siValorStatus, cProducto
		      FROM bdicheq:sc_nominamovimientos mov
		      LEFT JOIN bdicheq:sc_maechq mae ON (mae.empresa = '001' AND mov.cuenta_abono = mae.cuenta)
             WHERE mov.nombre_archivo = cNombreArchivo
			   AND mov.status = 0 --- Con status <> 1 tomo todos los registros que no hayan sido procesados
		     ORDER BY mov.importe
            
            IF (siValorConcepto <> 0) AND (siValorConceptoAnterior <> siValorConcepto) THEN
				LET siValorConceptoAnterior = siValorConcepto;					
				LET iContador = iContador + 1;
                
                -- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
                --- CALL sp_dispersionnominatransacciones(siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
                CALL sp_dispersionnominatransacciones(siTipoEmpresa, siValorConcepto)
                RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo, cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransaccIvaDisp, mMontoTransIvaAper;
                
                IF vcodret <> '000' THEN
                    IF vcodret = '840'   THEN
                        LET p_mensaje = "Dispercion No Ejecutada: El Numero de Transaccion de Abono No es Valido";
                    ElIF vcodret = '845' THEN
                        LET p_mensaje = "Dispercion No Ejecutada: El Numero de Transaccion del Cargo No es Valido";
                    ElIF vcodret = '850' THEN
                        LET p_mensaje = "Dispercion No Ejecutada: El Numero de Transaccion de la ComisiÃ³o es Valido";
                    ElIF vcodret = '855' THEN
                        LET p_mensaje = "Dispercion No Ejecutada: El Numero de Transaccion del Iva No es Valido";
                    END IF
                    
                    ROLLBACK WORK;
                    LET vBegin = 'N';
                    RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
                END IF
                
				IF iContador = 1000 THEN
					UPDATE STATISTICS medium FOR TABLE bdicheq:sc_nominamovimientos;
					LET iContador = 0;
				END IF
            END IF
            
            -- IF NOT EXISTS (SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cNumeroCuentaEmpleado AND producto = cAceptaProducto ) THEN
			IF NOT EXISTS (SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cNumeroCuentaEmpleado) THEN 
				UPDATE bdicheq:sc_nominamovimientos
                   SET status = '4'     -- Cuenta No Existe
                 WHERE nombre_archivo = cNombreArchivo 
                   AND num_empleado = cNumeroEmpleado;
                   
				IF siTipoEmpresa = 2 THEN
				   LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
				END IF
            ELSE
                IF siTipoEmpresa <> 2 THEN
	                LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
	                LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
					LET mImporteEmpleadoComisionMasIva = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
					
					--RobertoCastro para cuentas que no se les cobra comision 27/02/2023
					IF vExcentaComision > 0 THEN 
						LET mImporteEmpleadoComisionMasIva = 0;
					END IF
                    
                    IF mSaldoActual >= (mTotalCargo + mImporteEmpleadoComisionMasIva) THEN   --Si el saldo sobrante que me queda es Mayor o Igual al importe a pagar, le pago al empleado
                        LET bSiguienteEmpleado = "T" ;
                        LET siSaldoDisponible = 1;
                    ELSE
                        LET bSiguienteEmpleado = "F" ;
                        LET siSaldoDisponible = 0;
                    END IF
                ElIF siTipoEmpresa = 2 THEN
                    LET bPrimerEmpleado = "T";
                    LET bSiguienteEmpleado = "T";
                    LET siSaldoDisponible = 1;
                END IF   --Es de: IF siTipoEmpresa <>2
                
                IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T") THEN
                    IF siSaldoDisponible = 1 THEN	
	                    CALL sp_dispersionnominavalidacionestatus(cNumeroCuentaEmpleado, '', '', 0,'','',cNombreArchivo, cNumeroEmpleado, mImporteEmpleado, mImporteNoAbonado, siTipoEmpresa)
	                    RETURNING vcodret,cEstatusCta,cAbono,mImporteNoAbonado,cRecDatoNoUtilizableNOperacion,cSucursalAbono;
							
                        LET cRecDatoNoUtilizableNOperacion = cRecDatoNoUtilizableNOperacion;
							
                        IF cEstatusCta = '1' OR cAbono = 'S' THEN--Si la cuenta esta activa o si la cuenta esta bloqueada pero recibe abonos
                            IF EXISTS ( SELECT secuencia FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND cuenta = cNumeroCuentaEmpleado AND  tipo_tarjeta = "T" AND status_tar = "A") THEN
                                SELECT NVL(num_tarjeta, '') 
                                  INTO cNumeroTarjeta 
                                  FROM bdicheq:sc_tarjeta
                                 WHERE empresa = '001'
                                   AND cuenta = cNumeroCuentaEmpleado
                                   AND tipo_tarjeta = "T" 
                                   AND status_tar = "A"
                                   AND secuencia = (SELECT NVL(secuencia, '') FROM bdicheq:sc_tarjeta WHERE empresa = '001' AND cuenta = cNumeroCuentaEmpleado AND tipo_tarjeta = "T" AND status_tar = "A");
                            ELSE
                                LET cNumeroTarjeta = '';
                            END IF
                            
                            CALL sp_generafolionomina (cNombreUsuario) 
                            RETURNING cCodRet, cNumeroFolio;
                            
                            -- // Aqui siempre se mANDara la empresa 001 indepENDientemente del numero de empresa que se este ejecutANDo tanto para el abono_ref y el cargo_ref
                            -- // Segundo parametro anterior 9251
                            LET cSucursalAbono = "9103"; --La sucursal abono se asigna fija dado a la solicitud del departamento.
                                    
                            CALL abono_ref ("001", cSucursalAbono, cNombreUsuario,  cTransaccAbono, "0000", cNumeroFolio, cNumeroCuentaEmpleado, 0, mImporteEmpleado, mImporteEmpleado, 0, 0, 0, "01", " ", cNumeroTarjeta, cUsuarioAutoriza) 
                            RETURNING vcodret;
                            
                            IF vcodret = '000' THEN
                                UPDATE bdicheq:sc_nominamovimientos
                                   SET status = '1'   --Aqui actualizo el status = 1  (Aplicado)
                                 WHERE nombre_archivo = cNombreArchivo 
                                   AND num_empleado = cNumeroEmpleado;
                                
								LET mImporteAbonado = mImporteAbonado + mImporteEmpleado;
								LET iNumeroRegistrosAplicados = iNumeroRegistrosAplicados +1;
								
								--RobertoCastro para cuentas que no se les cobra comision 27/02/2023
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
                                   SET status = '9'  -- Aqui actualizo el status = 9  (Error en la transaccion del sp abono_ref)
                                 WHERE nombre_archivo = cNombreArchivo 
                                   AND num_empleado = cNumeroEmpleado;
                                
                                LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
                            END IF
                        END IF    --Es de: IF  (siSaldoDisponible = 1) AND (cEstatusCta = '1')
                    ELSE
                        LET vcodret = '835';
                        LET p_mensaje = "Dispercion No Ejecutada: La Cuenta Eje No Tiene Saldo Suficiente";
                        
                        UPDATE bdicheq:sc_nominaencabezadosumario
                           SET status = '5', 
                               fecha_aplicado = dFechaActual, 
                               hora_aplicado = cHoraActual
                         WHERE empresa = cNumeroEmpresa 
                           AND fecha_gen = dFechaGeneracion 
                           AND folio_archivo = IFolioArchivo;
                           
                        COMMIT WORK;
                        LET vBegin = 'N';
                        RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
                    END IF
                ELSE   --Es de: IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T")
                    UPDATE bdicheq:sc_nominamovimientos
                       SET status = '5'    --iCodigoEstatus  --Aqui actualizo el status = 5  (No Aplicado: Saldo Insuficiente)
                     WHERE nombre_archivo = cNombreArchivo 
                       AND num_empleado = cNumeroEmpleado;
                    
                    IF siTipoEmpresa = 2 THEN
                        LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
                    END IF
                END IF   --Es de: IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T")
            END IF   --Este END IF es de: IF NOT EXISTS el numero de cuenta
            
            LET bPrimerEmpleado = "F" ;
        END FOREACH;
        
        -- ******************************************************** INICIO de validacion de tipo de empresa externa ********************************************************
        IF siTipoEmpresa <> 2 THEN
            CALL sp_generafolionomina (cNombreUsuario) 
            RETURNING cCodRet, cNumeroFolio;
            
			--RobertoCastro para cuentas que no se les cobra comision 27/02/2023
			IF vExcentaComision > 0 THEN 
				LET mMontoTransIvaDisp = 0;
				LET mMontoTransComiDisp = 0;
			END IF
			
            -- // Aqui se manda llamar el sp que obtiene los totales del IVA y de la comision de los empleados Aplicados
            CALL sp_nominatotalivacomision (cNombreArchivo, mMontoTransIvaDisp, mMontoTransComiDisp)
            RETURNING cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;
            
            IF mTotalNoPagado <> 0 THEN
                LET iCodigoEstatus = 3;
            ELSE
                LET iCodigoEstatus = 2;
            END IF
            
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
            END IF
            
            LET cNumeroTarjeta = '';
            LET vcodretCargo1 = '000';
            LET vcodretCargo2 = '000';
            LET vcodretCargo3 = '000';
            
            IF mTotalPagado > 0 OR mTotalComision > 0 THEN
                IF mTotalPagado > 0 THEN
                    CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccCargo, "0000", cNumeroFolio, cCuentaEje, 0, mTotalPagado, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
                    RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
                ELSE
                    LET vcodretCargo1 = '000';
                END IF;
                    
                IF vcodretCargo1 = '000' AND mTotalComision > 0 THEN 
                    CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccComiDisp, "0000", cNumeroFolio, cCuentaEje, 0, mTotalComision, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
                    RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;
                    
                    IF vcodretCargo2 = '000' THEN   --Se cambio el cTransacIvaDisp x vtranret
                        CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio, cCuentaEje, 0, mTotaliva, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
                        RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
                    END IF
                ElIF (vcodretCargo1 = '000') AND (mTotalComision = 0) THEN
                    LET vcodretCargo2 = '000';
                    LET vcodretCargo3 = '000';
                END IF
            END IF
            
            IF (vcodretCargo1 = '000') AND (vcodretCargo2 = '000') AND (vcodretCargo3 = '000') THEN
                COMMIT WORK;
            ELSE
                ROLLBACK WORK;
                
                UPDATE bdicheq:sc_nominaencabezadosumario  -- El archivo no efectuo el cargo y deja movimientos en cero pero actualiza el status de encabezado sumario a 9
                   SET status = '9', 
                       fecha_aplicado = dFechaActual, 
                       hora_aplicado = cHoraActual
                 WHERE empresa = cNumeroEmpresa 
                   AND fecha_gen = dFechaGeneracion 
                   AND folio_archivo = iFolioArchivo;					
            END IF
        END IF
        --  ******************************************************** FIN de validacion de tipo de empresa externa ********************************************************
        
        --  ******************************************************** INICIO de validacion de tipo de empresa = 2 ********************************************************
        IF siTipoEmpresa = 2 THEN
            IF mImporteNoAbonado > 0 THEN
                LET iCodigoEstatus = 3;
            ELSE
                LET iCodigoEstatus = 2;
            END IF
            
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
            RETURNING v_cCodRet,v_cNomArchivo;
            
            IF v_cCodRet = '000' THEN
                LET vcodret = '000';
                LET p_mensaje = "El Archivo ha Sido Procesado Correctamente";
                LET cFolioDispercion = cNumeroFolio;
                LET mImporteTotalAplicado = mImporteAbonado;
                LET cNombreArchivoConciliacion = v_cNomArchivo;
                LET cHoraActual = cHoraActual;
            ELSE
                LET vcodret =  v_cCodRet;
                LET p_mensaje = "Dispercion Ejecutada Pero, El Archivo de Consiliacion No Fue Creado";
                LET cFolioDispercion = cNumeroFolio;
                LET mImporteTotalAplicado = mImporteAbonado;
                LET cNombreArchivoConciliacion = "";
                LET cHoraActual = cHoraActual;
            END IF
            
            RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
        END IF
        --  ******************************************************** FIN de validacion de tipo de empresa = 2 ********************************************************
        
        IF vcodretCargo3 = '000' THEN
            CALL sp_conciliaciondispersionnomina (cNombreArchivo) 
            RETURNING v_cCodRet,v_cNomArchivo;
            
            IF v_cCodRet = '000' THEN
                LET vcodret = '000';
                LET p_mensaje = "El Archivo ha Sido Procesado Correctamente";
                LET cFolioDispercion = cNumeroFolio;
                LET mImporteTotalAplicado = mImporteAbonado;
                LET mComisionAplicado = mTotalComision;
                LET mIvaAplicado = mTotaliva;
                LET cNombreArchivoConciliacion = v_cNomArchivo;
                LET cHoraActual = cHoraActual;
            ELSE
                LET vcodret =  v_cCodRet;
                LET p_mensaje = "Dispercion Ejecutada Pero, El Archivo de Consiliacion No Fue Creado";
                LET cFolioDispercion = cNumeroFolio;
                LET mImporteTotalAplicado = mImporteAbonado;
                LET mComisionAplicado = 0;
                LET mIvaAplicado = 0;
                LET cNombreArchivoConciliacion = "";
                LET cHoraActual = cHoraActual;
            END IF
        ELSE
            LET vcodret =  vcodretCargo3;
            LET p_mensaje = "Dispercion No Ejecutada, No Se Efectuo el Cargo";
            LET cFolioDispercion = cNumeroFolio;
            LET mImporteTotalAplicado = 0;
            LET mComisionAplicado = 0;
            LET mIvaAplicado = 0;
            LET cNombreArchivoConciliacion = "";
            LET cHoraActual = cHoraActual;
        END IF
    END IF  -- IF dFechaAplicacion <= dFechaActual
	
	LET cImporteTotalAplicadoCh =  mImporteTotalAplicado;
	LET cComisionAplicadoCh = mComisionAplicado;
	LET cIvaAplicadoCh = mIvaAplicado;
    
	LET iLargoImporte = LENGTH(cImporteTotalAplicadoCh);
	LET iLargoComision = LENGTH(cImporteTotalAplicadoCh);
	LET iLargoIva = LENGTH(cIvaAplicadoCh);
    
	LET cImporteTotalAplicadoCh = SUBSTR(cImporteTotalAplicadoCh, 2, iLargoImporte);
	LET cComisionAplicadoCh = SUBSTR(cComisionAplicadoCh, 2, iLargoComision);
	LET cIvaAplicadoCh = SUBSTR(cIvaAplicadoCh, 2, iLargoIva);
    
    LET vcodret ='00000';
    
	-- // Se Corre este procedimiento pa enviar los registros que no pudieron ser procesados a las tabla historias.
	EXECUTE PROCEDURE sp_dispersiontraspasomovtos()
	INTO v_cCodRet;
    
	IF v_cCodRet <> "00000" AND v_cCodRet <> "00001" THEN
        LET vcodret = '100';
	END IF;
    
	RETURN vcodret, p_mensaje, cFolioDispercion, cImporteTotalAplicadoCh, cComisionAplicadoCh, cIvaAplicadoCh, cNombreArchivoConciliacion, cHoraActual;
    
    END
    
END PROCEDURE
    
DOCUMENT
'MODIFICO :Valentin Lopez Valenzuela',
'DESCRIPCION: Se cambia los estatus <> 1 por estatus =0, se realiza una consulta ala tabla sc_nominamovimientos con left join a la sc_maecheq y se sustituye la funcionalidad del sp_nominatotalivacomision por variables acumuladas.',
'Captacion',
'FECHA : Enero de 2011',
'VERSION: 2011',
'BD    : BDICHEQ',
'MODIFICO :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se valida Si la empresa es interna y su concepto distINTO a nomina entonces se toma como externa para generar cobros correspondientes.',
'Captacion',
'FECHA : Octubre de 2008',
'VERSION: 200810',
'BD    : BDICHEQ',
'MODIFICO :Cristian Valentina Aguilar',
'DESCRIPCION: El cambio realizado permite que la dispersión de la nómina se ejecute, aún cuANDo las cuentas estén bloqueadas, depENDiENDo si el motivo permite cargos o abonos',
'Captacion',
'FECHA : Marzo de 2009',
'VERSION: 200903',
'BD    : BDICHEQ',
'AUTOR: Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se optimizo para una mejor lectura de codigo y se generaron 2 procesos de complemento donde se valida el estatus de las cuentas y otro que obtiene"',
'las transacciones utilizadas en el proceso de dispercion, adapto para nomina altas nuevas empresa 001',
'FECHA : Octubre de 2009',
'VERSION: 20091013',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_dispersionlinea_bpi(pidempresa CHAR(3),pnumcte CHAR(9),pnombrearchivo CHAR(20),pSucursal CHAR(10),pUsuario CHAR(10),pTransaccionIva CHAR(5),pTransaccionCargo CHAR(5),pFolioSuc CHAR(20),pCuenta CHAR(20),pIvaDisp MONEY(14,2),pCargoDisp MONEY(14,2))
returning char(5);

--RealizÃ³: Jose Ruben Lopez Hernadez
--Fecha: 26/03/2013
--Actividad:Se unifico la ejecucion de los sp de cargo de iva y de comision 
--RealizÃ³: Gabriela Aguilar mendoza
--Fecha: 15/08/2017
--Actividad:Se coloca nombre del archivo al spl de dispersion
--BD:bdicheq.

    DEFINE vsqlerr          INTEGER;
    DEFINE vcodret          CHAR(5);
	DEFINE vcodret2         CHAR(5);
	DEFINE vcodret3         CHAR(5);
	DEFINE vcodret4         CHAR(5);
	DEFINE vcodret5         CHAR(5);
	DEFINE vcodret6         CHAR(5);
	DEFINE cFolio 			CHAR(16);
	DEFINE cMensaje 		CHAR(50);
	DEFINE cTransacCargo    CHAR(4);
	DEFINE dFechacargo      DATE;
	DEFINE mSaldoEje        MONEY(14,2);
	DEFINE mRedondeo        MONEY(18,5);
	DEFINE mDispLinea		MONEY;
	DEFINE mMontoTransIvaDisp	MONEY(16,2);
	DEFINE cProducto	 CHAR(4);
	DEFINE cTpoPersona	 CHAR(1);
	DEFINE cProductoDisperion CHAR(4);
	
	LET vsqlerr = 0;
    LET vcodret = "00000";
	LET vcodret2 = "00000";
	LET vcodret3="00000";
	LET vcodret4="00000";
	LET vcodret5="00000";
	LET vcodret6="00000";
	LET cFolio = '';
	LET cMensaje = " ";
	LET cTransacCargo='';
	LET dFechacargo='';
	LET mSaldoEje=0;
	LET mRedondeo=0;
	LET mDispLinea = 0.0;
	LET mMontoTransIvaDisp = 0;
	LET cProducto	 = "";
	LET cTpoPersona	 = "";
	LET cProductoDisperion  = "";
	
	--SET debug FILE TO "/home/informix/BereniceOut/sp_dispersionlinea_bpi.out";
	--Trace ON;
	
	SET ISOLATION TO CURSOR STABILITY;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

    BEGIN

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
			INSERT INTO bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)VALUES(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,CURRENT);
            RETURN vcodret;
        END IF;
    END EXCEPTION;

	
	
    CALL "informix".sp_cargadividearchivonomina_bpi(pnombrearchivo)
		RETURNING vcodret, cFolio, cMensaje;

    IF 	vcodret <> "00000" THEN		
		LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_cargadividearchivonomina_bpi)';
	ELSE
		SELECT producto
		INTO cProducto
		FROM "informix".sc_maechq
		WHERE empresa = "001"
		AND cuenta = pCuenta;
		   
		SELECT tpper_valida
		INTO cTpoPersona
		FROM bdicheq:"informix".sc_producto
		WHERE empresa = "001" 
		AND producto = cProducto;
		
		IF cTpoPersona IN ("2","4","5") AND cProducto <> "2600"  THEN
			-- OBTIENE EL IVA
			SELECT valor
			INTO mMontoTransIvaDisp
			FROM bdinteg:"informix".si_param
			WHERE cod_param = 47
			AND empresa = "001";
			--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
			SELECT disp_linea
			INTO mDispLinea
			FROM "informix".sc_maecomtasserv_pm
			WHERE cuenta = pCuenta;
			
			IF mDispLinea IS NOT NULL THEN
				LET pCargoDisp = mDispLinea;
				LET pIvaDisp = pCargoDisp * mMontoTransIvaDisp;
				LET pTransaccionIva = "0260";
				LET pTransaccionCargo = "3255";
			END IF
		END IF
	
		--para cuentas que no se les cobra comision dispersion 1600 y 2600
		SELECT COUNT(1) INTO cProductoDisperion
			FROM sc_nominaexcentocomision
				WHERE producto = cProducto;

		IF cProductoDisperion > 0 THEN 
			LET pCargoDisp = 0;
		END IF
		
		IF pCargoDisp <> 0 THEN--bandera ejecutar los cargos					
					EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',pSucursal,pUsuario,pTransaccionIva,'',pFolioSuc,pCuenta,0,pIvaDisp,'01','','','')
					INTO vcodret4,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo;
					IF vcodret4="000" THEN
							EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',pSucursal,pUsuario,pTransaccionCargo,'',pFolioSuc,pCuenta,0,pCargoDisp,'01','','','')	
							INTO vcodret5,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo;
							IF vcodret5="000" THEN
								EXECUTE PROCEDURE bdicheq:"informix".sp_dispercionnomina_bpi('5008',pnombrearchivo) INTO  vcodret2;
								IF vcodret2 = "000" THEN 
									LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE CC';
								ELSE
									EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pSucursal,pUsuario,pFolioSuc, 'A')
									INTO vcodret6;	
									LET vcodret = vcodret2;
									LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_dispercionnomina_bpi)';
								END IF
							ELSE
								EXECUTE PROCEDURE bdicheq:"informix".reversion('001',pSucursal,pUsuario,pFolioSuc, 'A')
								INTO vcodret6;	
								LET vcodret = vcodret5;
								LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(cargo_ref CARGO)';	
							END IF
					ELSE
						LET vcodret = vcodret4;
						LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(cargo_ref IVA)';	
					END IF
		ELSE--No se ejecutan los cargos
			EXECUTE PROCEDURE "informix".sp_dispercionnomina_bpi('5008',pnombrearchivo) INTO  vcodret2;
					IF vcodret2 = "000" THEN 
						LET cMensaje = 'LA APLICACION SE EJECUTO EXITOSAMENTE SC';
					ELSE
						LET vcodret = vcodret2;
						LET cMensaje = 'ERROR AL EJECUTAR LA APLICACION(sp_dispercionnomina_bpi)';
					END IF
		END IF
	END IF;

	INSERT INTO bdibpi:"informix".tmp_disp_err(id_empresa ,num_cte ,nom_arch,codret,mensaje,f_registro)VALUES(pidempresa,pnumcte,pnombrearchivo,vcodret,cMensaje,current);
    RETURN vcodret;
    END;

END PROCEDURE;