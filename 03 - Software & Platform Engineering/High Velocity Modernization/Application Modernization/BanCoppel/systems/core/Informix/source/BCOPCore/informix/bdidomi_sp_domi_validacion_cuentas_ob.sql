CREATE PROCEDURE "informix".sp_domi_validacion_cuentas_ob()
	RETURNING char(5) AS cCodeRet

/******************************
Proyecto:				Domiciliacion OB.
Descripcion:			Se consulta la informacion de los clientes que realizaron domiciliaciones el dia de hoy, para posteriormente
						insertarlos en las tablas CTE mediante el sp_domi_createtablascte_ob.
Dev:					Derian Alejandro Sainz Zazueta.
Fecha creacion:			13/08/2024 
Respuesta esperada:		cCodeRet: 00000

******************************/

-- DECLARACION DE VARIABLES 
DEFINE iSqlerr      				INTEGER;        -- Error SQL.
DEFINE cCoderet     				CHAR(5);        -- Codigo de retorno sp_domi_validacion_cuentas_ob.
DEFINE cCoderet3  					CHAR(5);        -- Codigo de retorno auxiliar para los SP's consumidos.
DEFINE cFolioActivacion  			CHAR(20);       -- Folio de activacion.
DEFINE cNumCte_Bancoppel       		CHAR(20);       -- Numero de cliente BanCoppel.
DEFINE cNumCta       				CHAR(20);       -- Numero de cuenta de credito.
DEFINE cNombreCte      				CHAR(20);       -- Nombre del cliente.
DEFINE dFechaActual 				DATE;           -- Fecha actual.
DEFINE mMontoProximoPago 			DECIMAL(18,2);  -- Monto de proximo pago.
DEFINE mImporteMaximo               MONEY(16,2);    -- Importe maximo de domiciliacion.
DEFINE mImporteFijo 				DECIMAL(18,2);  -- Importe fijo seleccionado por el cliente en la tabla dom_autorizaciones.
DEFINE dFechaProximoPago			DATE;           -- Fecha de proximo pago.
DEFINE dFechaPago                   DATE;           -- Fecha de proximo pago.
DEFINE dFechaEnvioCecoban			DATE;           -- Fecha en que se enviaran los datos a cecoban.
DEFINE cTipoDomi					CHAR(2);        -- Tipo de domiciliacion. ('01' -> MVP | '02' -> Otros bancos)
DEFINE cTipoPago					CHAR(1);        -- Tipo de pago. ('F' -> Fijo | 'M' -> Minimo | 'T' -> Total)
DEFINE cNombreArch					CHAR(20);       -- Nombre de archivo.
DEFINE cTarjetaCargo 				CHAR(20);       -- Tarjeta de cargo.
DEFINE cTarjetaAbono				CHAR(20);       -- Tarjeta de abono.
DEFINE mImpOperacion 				DECIMAL(18,2);	-- Importe de operacion.
DEFINE mImpOperacionesSumario       DECIMAL(18,2);	-- Importe de operaciones de la tabla dom_cte_sumario.
DEFINE cImpOperacionesSumarioAux    CHAR(18);       -- Variable auxiliar para verificar si el suamrio es un numero valido.
DEFINE iProcesado    				INTEGER;        -- Bandera que indica si la domi ya fue procesada por CECOBAN.
DEFINE iContrato    				INTEGER;        -- Bandera que indica si la domi ya tiene contrato.
DEFINE iDiferencia    				INTEGER;        -- Bandera que indica si la domi ya tiene contrato.
DEFINE cTipoCtaCargo                CHAR(2);        --
DEFINE cTipoCtaAbono                CHAR(2);        --
DEFINE cNombreCargo                 CHAR(60);       --
DEFINE cCveBancoCargo               CHAR(3);        --
DEFINE cRfc                         CHAR(13);       --
DEFINE cReferenciaNumerica          CHAR(7);        --
DEFINE cPeriodo                     CHAR(2);        -- 
DEFINE cNumCte                      CHAR(9);        --
DEFINE cAux1                        CHAR(25);       -- Variable auxiliar.
DEFINE cAux2                        CHAR(25);       -- Variable auxiliar.
DEFINE cAux3                        CHAR(25);       -- Variable auxiliar.
DEFINE cAux4                        CHAR(25);       -- Variable auxiliar.
DEFINE cAux5                        CHAR(25);       -- Variable auxiliar.
DEFINE cAux6                        CHAR(25);       -- Variable auxiliar.
DEFINE cAux7                        CHAR(25);       -- Variable auxiliar.
DEFINE cAux8                        CHAR(25);       -- Variable auxiliar.
DEFINE cAux9                        CHAR(25);       -- Variable auxiliar.

-- VALORES INICIALES
LET iSqlerr    			            =  0;
LET cCoderet   			            = '00000';
LET cCoderet3 			            = '';
LET cFolioActivacion	            = '';
LET cNumCte_Bancoppel       		= '';
LET cNumCta       			        = '';
LET dFechaActual 			        = '';
LET mMontoProximoPago 		        = '';
LET mImporteFijo 				    = 0;
LET dFechaProximoPago		        = '';
LET dFechaEnvioCecoban		        = '';
LET dFechaPago      		        = '';
LET cTipoDomi				        = '';
LET cTipoPago				        = '';
LET cNombreArch                     = '';	 
LET cTarjetaCargo                   = '';	 
LET cTarjetaAbono                   = '';	 
LET mImpOperacion                   = '';	
LET mImpOperacionesSumario          = '';	
LET mImporteMaximo                  = 0.00;
LET cTipoCtaCargo                   = '';    
LET cTipoCtaAbono                   = '';    
LET cNombreCargo                    = '';    
LET cCveBancoCargo                  = ''; 
LET cRfc                            = ''; 
LET cReferenciaNumerica             = ''; 
LET cPeriodo                        = ''; 
LET cNumCte                         = ''; 
LET iProcesado                      = '';
LET iContrato                       = '';
LET iDiferencia                     = '';
LET cTipoCtaCargo                   = '';
LET cTipoCtaAbono                   = '';
LET cNombreCargo                    = '';
LET cCveBancoCargo                  = '';
LET cRfc                            = '';
LET cReferenciaNumerica             = '';
LET cNumCte                         = '';

BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 and iSqlerr <> -1213 THEN 
			LET cCoderet = iSqlerr;

            --Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
            INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
            VALUES (CURRENT, CURRENT HOUR TO FRACTION, cCoderet, '', 'sp_domi_validacion_cuentas_ob', trim(cFolioActivacion) || ' - ' || trim('Error de Informix ' || cCoderet), '', CURRENT);

			RETURN cCoderet;
		END IF;
	END EXCEPTION WITH RESUME;

	--***************************************************************************************
	--SET DEBUG FILE TO "/tmp/sp_domi_validacion_cuentas_ob.out"; --"/informix/Derian1/sp_domi_validacion_cuentas_ob.out";
	--TRACE ON;
	--***************************************************************************************
	
	SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;

	--Obtener fecha actual.
	SELECT {+INDEX(bdinteg:"informix".si_fechas idx_si_fechas_fecha_hoy)} fecha_hoy 
	INTO dFechaActual 
	FROM bdinteg:"informix".si_fechas where empresa ='001';

	--IF (dFechaActual = dFechaActual ) THEN -- Cambiar la fecha para que coincida con el dia de prox pago.
		SELECT TRIM(valor) INTO cNumCte_Bancoppel FROM bdidomi:"informix".dom_parametros WHERE cod_param = '36';
	
		FOREACH WITH HOLD
			SELECT DISTINCT 
			a.folio_activacion, d.fecha_prox_pago, a.cve_domiciliar_tc, a.cuenta, b.tipo_domi, a.imp_fijo_tc,
            b.nombre_arch, b.cuenta_cargo, b.cuenta_abono as tarjeta_abono, b.fecha_envio, e.procesado,
            a.imp_maximo, b.nombre_cargo, b.tipo_cta_abono, b.tipo_cta_cargo, b.cve_banco_cargo,b.rfc_cargo,
            b.ref_numerica,b.num_periodo,a.num_cte, d.fecha_pago, e.contrato, c.monto_proximo_pago
			INTO cFolioActivacion, dFechaProximoPago, cTipoPago, cNumCta, cTipoDomi, mImporteFijo, cNombreArch,
            cTarjetaCargo, cTarjetaAbono, dFechaEnvioCecoban, iProcesado, mImporteMaximo, cNombreCargo, cTipoCtaAbono,
            cTipoCtaCargo, cCveBancoCargo, cRfc, cReferenciaNumerica, cPeriodo, cNumCte, dFechaPago, iContrato, mImpOperacion
			FROM bdidomi:"informix".dom_autorizaciones a
			INNER JOIN bdidomi:"informix".dom_archivomanual b 				ON a.folio_activacion = b.folio_activacion 
			INNER JOIN bdidomi:"informix".dom_pago c 						ON a.folio_activacion = c.folio_activacion 
			INNER JOIN bdidomi:"informix".dom_fecha_pago d 					ON a.folio_activacion = d.folio_activacion
			INNER JOIN bdidomi:"informix".dom_activacion_domiciliacion_ob e	ON a.folio_activacion = e.folio_activacion
            AND a.cve_estatus = '01'    
            AND b.tipo_domi = '02'
            AND b.estatus = 'EP'
			AND e.procesado IN ('0','2')
			AND e.estatus IN ('01','03')
            AND (b.fecha_envio = dFechaActual OR d.fecha_prox_pago = dFechaActual)

            -- Si por alguna razon el sumario tiene un signo negativo.
            ON EXCEPTION IN (-1213)
                --Insertamos a la tabla bdidomi:dom_errores los datos del error ocurrido.
                INSERT INTO bdidomi:"informix".dom_errores (Fecha_Error,Hora_Error,Cod_Error,Nombre_Arch,Sp_Llamado,Mensaje_Error,User_Insert,Fecha_Insert)
                VALUES (CURRENT, CURRENT HOUR TO FRACTION, '-1213', '', 'sp_domi_validacion_cuentas_ob', trim(cFolioActivacion) || ' - ' || trim('1213 revisar sumario y montos'), '', CURRENT);
                CONTINUE FOREACH;
            END EXCEPTION WITH RESUME;
            
            -- Si retorna un saldo a favor este se inserta en la tabla dom_pago ¿lo ponemos en 0 o lo dejamos asi?
            EXECUTE PROCEDURE bdidomi:"informix".sp_domi_proximo_pago(cTipoPago, '001', TRIM(cNumCta), 'sysdomi', TRIM(cFolioActivacion), cTipoDomi) INTO cCoderet3, mMontoProximoPago;

            -- Checamos si el monto de pago supera al monto maximo.
            IF mMontoProximoPago > mImporteMaximo THEN
                LET mMontoProximoPago = mImporteMaximo;
                -- Actualizamos el monto_proximo_pago en la tabla dom_pago con el importe_maximo.
                UPDATE bdidomi:"informix".dom_pago 
                SET monto_proximo_pago = mMontoProximoPago 
                WHERE folio_activacion = cFolioActivacion;
            END IF;

            IF iProcesado = 0 THEN

                IF( NVL(cFolioActivacion,'') != '' AND NVL(mMontoProximoPago, '') != '' ) THEN
                
                    IF mMontoProximoPago <= 0 AND iContrato = 1 THEN
                        UPDATE bdidomi:"informix".dom_archivomanual 
                        SET estatus = '01', imp_operacion = LPAD(0,15,'0'),causa_rechazo = '16' 
                        WHERE folio_activacion = cFolioActivacion
                        AND estatus = 'EP';
                        
                        SELECT ROUND((months_between(dFechaActual, fecha_pago) + 1), 0)
                        INTO iDiferencia
                        FROM bdidomi:"informix".dom_fecha_pago
                        WHERE folio_activacion = cFolioActivacion; 
    
                        LET dFechaProximoPago = dFechaPago + iDiferencia UNITS MONTH;

                        IF cTipoPago = 'F' THEN
                            LET mMontoProximoPago = mImporteFijo;
                        END IF;
                        
                        -- Insertamos nuevo registro para la programacion del proximo pago.
                        EXECUTE PROCEDURE bdidomi:"informix".sp_domi_guardararchivo_manual_ob(cNombreCargo, cTarjetaAbono, 
                        cTipoCtaAbono, mMontoProximoPago::CHAR(15), cTarjetaCargo, cTipoCtaCargo, cCveBancoCargo, 'transBPI', 
                        TO_CHAR(dFechaProximoPago, '%Y%m%d'), cRfc, cFolioActivacion, cReferenciaNumerica, 'A', cPeriodo, 'EP', 
                        cNumCte, cTarjetaAbono, '','','','') INTO cCoderet3, cAux1,cAux2,cAux3,cAux4,cAux5,cAux6,cAux7,cAux8,cAux9;  
                        
                        CONTINUE FOREACH;
                    END IF; 
                       
                    EXECUTE PROCEDURE bdidomi:"informix".sp_domi_createtablascte_ob(cFolioActivacion, cNumCte_Bancoppel, 'sysdomi', dFechaProximoPago, '02') INTO cCoderet;

                    IF cCoderet <> '00000' THEN
                        CONTINUE FOREACH;
                    END IF; 

                    UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob SET procesado = '1' WHERE folio_activacion = cFolioActivacion;
                END IF;

            ELIF iProcesado = 2 THEN

                IF NVL(mMontoProximoPago,0) = 0 THEN
                    UPDATE bdidomi:"informix".dom_archivomanual 
                    SET estatus = '01', imp_operacion = LPAD(0,15,'0'),causa_rechazo = '16' 
                    WHERE folio_activacion = cFolioActivacion
                    AND estatus = 'EP';
                    
                    SELECT ROUND((months_between(dFechaActual, fecha_pago) + 1), 0)
                    INTO iDiferencia
                    FROM bdidomi:"informix".dom_fecha_pago
                    WHERE folio_activacion = cFolioActivacion; 

                    LET dFechaProximoPago = dFechaPago + iDiferencia UNITS MONTH;

                    IF cTipoPago = 'F' THEN
                        LET mMontoProximoPago = mImporteFijo;
                    END IF;

                    -- Insertamos nuevo registro para la programacion del proximo pago.
                    EXECUTE PROCEDURE bdidomi:"informix".sp_domi_guardararchivo_manual_ob(cNombreCargo, cTarjetaAbono, 
                    cTipoCtaAbono, mMontoProximoPago, cTarjetaCargo, cTipoCtaCargo, cCveBancoCargo, 'transBPI', 
                    TO_CHAR(dFechaProximoPago, '%Y%m%d'), cRfc, cFolioActivacion, cReferenciaNumerica, 'A', cPeriodo, 'EP', 
                    cNumCte, cTarjetaAbono, '','','','') INTO cCoderet3, cAux1,cAux2,cAux3,cAux4,cAux5,cAux6,cAux7,cAux8,cAux9;  
                    
                    UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob SET procesado = 0 WHERE folio_activacion = cFolioActivacion;
                    
                    CONTINUE FOREACH;
                END IF;

                UPDATE bdidomi:"informix".dom_cte_detalle SET imp_operacion = LPAD((mMontoProximoPago*100)::INTEGER::VARCHAR(15),15,'0') WHERE nombre_arch = cNombreArch AND cuenta_cargo = cTarjetaCargo AND cuenta_abono = cTarjetaAbono;

                SELECT SUM(imp_operacion/100::INTEGER)
                INTO mImpOperacionesSumario 
                FROM bdidomi:"informix".dom_cte_detalle 
                WHERE nombre_arch = cNombreArch;

                UPDATE bdidomi:"informix".dom_cte_sumario SET imp_operaciones = LPAD((mImpOperacionesSumario*100)::INTEGER::VARCHAR(18),18,'0') WHERE nombre_arch = cNombreArch;
                
                UPDATE bdidomi:"informix".dom_activacion_domiciliacion_ob SET procesado = 1 WHERE folio_activacion = cFolioActivacion;
            END IF;

		END FOREACH;
		LET cCoderet = '00000';
	--END IF;
END;

RETURN cCoderet;
END PROCEDURE;