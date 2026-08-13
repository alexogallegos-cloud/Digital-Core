CREATE PROCEDURE "informix".sp_marcaracuerdoscumplidos_rep(pEmpresa char(3), pTipo char(1), pFecha date)
RETURNING CHAR(5);

--Fecha de creación: 13/01/2009
--Programó: Anselmo Verdugo
--Objetivo: Store Procedure que realiza el marcaje de los compromisos y acuerdos que ya fueron
--cumplidos o en su defecto los que ya s evencieron.

--Fecha de Modificación: 24/01/2009
--Programó: Walber Castro
--Objetivo: Se agregan 2 parámetros de entrada al spl; una fecha y un tipo de
--ejecución que puede ser 0 (cero para automático) o 1 (uno para manual).
--Tomar la fecha de ejecución de la tabla bdinteg:si_fechas (campo
--fecha_hoy)y considerarla para el procesamiento de los Compromisos / Acuerdos
--cuando el parámetro de tipo de ejecución sea cero. En otro caso considerar
--como fecha de ejecución la fecha que pasa como parámetro.

--Fecha de Modificación: 07/02/2009
--Programó: Bernardo Carlos Baez Gonzalez
--Objetivo: Se modifica para que se actualize el campo flag_pago de el compromizo de pago 
--en base a los campos numcuenta y fecha_compac ya que antes solo se validaba el campo numcuenta
--Se modifica el borrado para que se borren los mismos registros que se han pasado al historico

--Fecha de Modificación: 09/03/2009
--Programó: Bernardo Carlos Baez Gonzalez
--Objetivo: Se modifica para que para que sean procesados, únicamente, los Compromisos y Acuerdos 
--que se vencen en la fecha de ejecución del proceso.

/*Fecha de Modificación: 03/11/2009
  Faviola Martínez Juárez
  Se integra monto pagado cuando un convenio es cumplido 
*/
 
--Modifico: Adilene Lara                                                                               
--Fecha: 17/03/2010                                                                                    
--Se modifica para que en caso de ocurrir un error guarde el detalle del convenio en cb_compac_error y en la cb_bitacora_cob
-- ademas de registrar el inicio y el fin del proceso en la tabla cb_bitacora_cob                                                 

/*Fecha de Modificación: 30/12/2010
  Enrique Lizárraga Lugo
  Se añade validación para evitar que se marque mas de un convenio en caso de que esté repetido. Se marca únicamente el convenio
  que tenga el valor mayor en keyx.
*/
--Modificó: Marco A. Campos
--Fecha: 2011-06-23
--Se modifica condición de fecha_compac de obtención de compromisos y acuerdos para que diario se califiquen los convenios que reciben pago y  aún no es su fecha de vencimiento  

--Modificó: Abrham Lopez L
--Fecha: 2013-08-01
--Se modifica agrega condición del campo hora_mov de la tabla sd_movhis sea > hora_inser de la tabla cb_compac

DEFINE vcCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE vdFechaHoy DATE;
DEFINE vdFechaAcuerdo DATE;
DEFINE vFechaCumplimiento DATE;

DEFINE vcNumCuenta CHAR(20);
DEFINE vmSumaPagos  MONEY(16,2);
DEFINE vmSuma   MONEY(16,2);
DEFINE vmCatidadAcordada   DECIMAL(14,2);
DEFINE vcEsTransaccion  CHAR(1);
DEFINE vOrigen SMALLINT;
DEFINE vProceso CHAR(30);
DEFINE cMensaje CHAR(80);
DEFINE isam_err INTEGER;
DEFINE error_info CHAR(80);
DEFINE vdia DATE;
DEFINE vHora CHAR(8);
DEFINE vmaxkeyx INTEGER;
DEFINE vPlazo char(2);
DEFINE vlFlagPago char(1);
DEFINE vHorainsert DATETIME HOUR to FRACTION(3);

LET viSqlErr = 0;
LET vOrigen = 4;
LET vProceso = 'MAC';
LET cMensaje = 'PROCESO EXITOSO';
LET isam_err = 0;
LET error_info = '';
LET vdFechaAcuerdo = '01/01/1900';
LET vdFechaHoy = CURRENT::DATE;
LET vcCodRet = '00000';
LET vcNumCuenta = '';
LET vmSumaPagos = 0.00;
LET vmCatidadAcordada = 0.00;
LET vmSuma = 0.00;
LET vcEsTransaccion = 'N';
LET vmaxkeyx = 0;
LET vPlazo = '';
LET vlFlagPago = '0';
LET vHorainsert = CURRENT;
LET vFechaCumplimiento = '01/01/1900';





    BEGIN    
        ON EXCEPTION SET viSqlErr, isam_err, error_info
            LET vcCodret = viSqlErr;
	        LET cMensaje = error_info;
            CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodRet, cMensaje, '02');
			RETURN vcCodRet;            
        END EXCEPTION;

--      SET DEBUG FILE TO "/informix/ALL/sp_marcaracuerdoscumplidos.out";
--      TRACE ON;
        
    CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, cMensaje, '01');

IF pEmpresa IS NULL OR pEmpresa = "" THEN
    LET vcCodRet = '00001';
    LET viSqlErr = '00001';
    LET cMensaje = 'FALTA PARAMETRO EMPRESA';
ELSE
    IF pTipo = "0" OR pTipo = "" THEN
        SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)} fecha_hoy
        INTO vdFechaHoy
        FROM bdinteg:si_fechas
        WHERE empresa = pEmpresa;
    ELSE
        IF pFecha IS NULL OR pFecha = "" THEN
            LET vcCodRet = '00002';      --CÓDIGO DE ERROR PARÁMETRO INCORRECTO
            LET viSqlErr = '00002';
            LET cMensaje = 'FALTA PARAMETRO FECHA';
        ELSE
            LET vdFechaHoy = pFecha;
        END IF;
    END IF;

    IF vcCodRet = '00000' THEN
--        BEGIN WORK;

        LET vcEsTransaccion = 'S';

        FOREACH WITH HOLD
            SELECT {+INDEX(bdicobranza:cb_compac idx_compac3)} numcuenta, importe, fecha_compac, plazo, hora_insert
                   INTO vcNumCuenta, vmCatidadAcordada, vdFechaAcuerdo, vPlazo, vHorainsert
              FROM BDICOBRANZA:CB_COMPAC
			       WHERE empresa = pEmpresa 
               AND ( vdFechaHoy + ( plazo * 7 ) ) >= fecha_compac  
               and fecha_compac <= vdFechaHoy
               AND activo = 1
		   
			LET vFechaCumplimiento = vdFechaAcuerdo + (vPlazo * 7) UNITS DAY; 
			
		--A.L.L Sacamos si la facha es inhabil para sumarle un dia  
			IF EXISTS (SELECT fecha FROM bdinteg:si_feriado WHERE pais = '001' and fecha = vFechaCumplimiento AND laborable = 'N') THEN

    			LET vFechaCumplimiento = vFechaCumplimiento - 1 UNITS DAY; 

            END IF;
			
			SELECT max(keyx)
			INTO vmaxkeyx
			FROM bdicobranza:cb_compac
			where empresa = pEmpresa and fecha_compac = vdFechaAcuerdo and numcuenta = vcNumCuenta;
			
            LET vmSumaPagos = 0.00;
            LET vmSuma = 0.00;
			
			IF NOT EXISTS (select numcuenta from cb_compac_his where numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo) THEN
			
            -- SUMA DE LOS PAGOS DEL DÍA ACTUAL (sc_movdia) POR VENTANILLA, INTERNET y CHEQUES.
         
				if vdFechaAcuerdo = vdFechaHoy then
					SELECT NVL(SUM(monto),0) 
					INTO vmSuma 
					FROM bdicred:sd_movhis 
					WHERE empresa = pEmpresa and num_credito = vcNumCuenta 
					and fecha_mov = vdFechaHoy
					and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
					and reversado = 'N'
					and hora_mov > vHorainsert;

			   
					LET vmSumaPagos = vmSumaPagos + vmSuma;
				 else

					-- SUMA DE LOS PAGOS DE LOS DÍAS ANTERIORES (sc_movhis)  POR VENTANILLA, INTERNET y CHEQUES.
					SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) 
					INTO vmSuma 
					FROM bdicred:sd_movhis 
					WHERE empresa = pEmpresa and num_credito = vcNumCuenta and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
					and fecha_mov > vdFechaAcuerdo 
					and fecha_mov <= vdFechaHoy 
					and reversado = 'N';
				
					LET vmSumaPagos = vmSumaPagos + vmSuma;
				 END IF;

	--            IF ( vmSumaPagos > 0  AND ( vdFechaHoy  <>  vdFechaAcuerdo +  (vPlazo * 7) )  )  OR  ( vdFechaHoy  =  vdFechaAcuerdo +  (vPlazo * 7) )     THEN
				IF ( vmSumaPagos > 0  )  OR  ( vdFechaHoy  >=  vFechaCumplimiento )     THEN

					BEGIN WORK;
				
						IF vmSumaPagos >= (vmCatidadAcordada/2) THEN
							UPDATE BDICOBRANZA:CB_COMPAC set flag_pago = 1, imp_pagado = vmSumaPagos
							WHERE empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;
							Let vlFlagPago = '1';
						ELSE
							UPDATE BDICOBRANZA:CB_COMPAC set flag_pago = 0, imp_pagado = vmSumaPagos 
							WHERE empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;
							Let vlFlagPago = '0';
						END IF;
						

						--El sistema replica los compromisos marcados como cumplidos y los compromisos vencidos  a la tabla de movimientos historicos.
						INSERT INTO bdicobranza:cb_compac_his(empresa, sucursal, origen, empleado_captura, numcliente, 
															  numcuenta, plazo, importe, tipo_compac, activo, flag_pago, 
															  efectuo_compac, tipo_movto, nombre_efectuo,  fecha_compac, 
															  fecha_insert, keyx,imp_pagado, hora_insert )

						SELECT empresa, sucursal, origen, empleado_captura, numcliente, 
							   numcuenta, plazo, importe, tipo_compac, '0', flag_pago, 
							   efectuo_compac, '', nombre_efectuo,  fecha_compac, 
							   pFecha, keyx, nvl(imp_pagado, 0), current
						 FROM bdicobranza:CB_COMPAC 
						WHERE empresa = pEmpresa AND numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo AND keyx = vmaxkeyx;


						UPDATE bdicred:sd_indicador_cred SET cumplio_convenio = vlFlagPago WHERE empresa = pEmpresa AND num_credito = vcNumCuenta;
						-- El sistema elimina los compromisos marcados como cumplidos y los compromisos vencidos de la tabla de movimientos.
						DELETE FROM BDICOBRANZA:CB_COMPAC 
						WHERE empresa = pEmpresa AND numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo AND keyx = vmaxkeyx;

					COMMIT WORK;
					
				END IF;

			END IF;

        END FOREACH;
        
        LET vcEsTransaccion = 'N';
        
    END IF;
END IF;

--IF vcCodRet <> '00000' then

CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vproceso, vcCodret, cMensaje, '03');

--END IF;

RETURN vcCodRet;
END;
END PROCEDURE;