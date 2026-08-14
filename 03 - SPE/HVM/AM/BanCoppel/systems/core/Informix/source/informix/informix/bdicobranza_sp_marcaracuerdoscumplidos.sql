CREATE PROCEDURE "informix".sp_marcaracuerdoscumplidos( pEmpresa char(3), pTipo char(1), pFecha date )
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
--Modificó³: Marco A. Campos
--Fecha: 2011-06-23
--Se modifica condición de fecha_compac de obtención de compromisos y acuerdos para que diario se califiquen los convenios que reciben pago y  aún no es su fecha de vencimiento  

--Modificó³: Abrham Lopez L
--Fecha: 2013-08-01
--Se modifica agrega condición del campo hora_mov de la tabla sd_movhis sea > hora_inser de la tabla cb_compac

/*Modificó: Carlos Valenzuela
  Fecha: 2016-04-14
  Se modifica el proceso para que solo realiza el marcaje de los compromisos y acuerdos que ya fueron
  cumplidos o en su defecto los que ya se vencieron solo para el producto 6001(TDC), ya que se creara 
  otro proceso para los productos a plazos(sp_marcaracuerdoscumplidoscrd).
*/

DEFINE vcCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE vdFechaHoy DATE;
DEFINE vdFechaAcuerdo DATE;
DEFINE vFechaCumplimiento DATE;

DEFINE vcNumCuenta CHAR(20);
DEFINE vmSumaPagos  MONEY(16,2);
DEFINE vmSuma   MONEY(16,2);
DEFINE vmCantidadAcordada   DECIMAL(14,2);
DEFINE vcEsTransaccion  CHAR(1);
DEFINE vOrigen SMALLINT;
DEFINE vProceso CHAR(30);
DEFINE cMensaje CHAR(80);
DEFINE vMensaje CHAR(150);
DEFINE isam_err INTEGER;
DEFINE error_info CHAR(80);
DEFINE vdia DATE;
DEFINE vHora CHAR(8);
DEFINE vmaxkeyx INTEGER;
DEFINE vPlazo char(2);
DEFINE vlFlagPago char(1);
DEFINE vHorainsert DATETIME HOUR to FRACTION(3);
DEFINE vCuentaPagosProg  SMALLINT;
DEFINE vPagoProgramado char(1);
DEFINE cuentas_procesar INTEGER;
DEFINE cuentas_cumplio INTEGER;
DEFINE cuentas_nocumplido INTEGER;
DEFINE dFecha_promesarota  DATE;
DEFINE dFecha_cifrado DATE;
DEFINE iCuenta_creds smallint;
define dtFechaIni       date; ---- Evaluación Objetiva
define dtFechaFin       date;
define iCteAsisteSuc    integer;
define cOrigen          char(10);
define pSucursalOrig    char(4);
define psucursal        char(4);
define pfechasistema    date;
define pefectuo_compac  integer;
define pnombre_efectuo  char(40);
define pnumcuenta       char(20);
define pnumproducto		char(4); 
define pplazo           char(2);
define porigen	        smallint;
define ptipo_compac     char(1);
define pimporte         decimal(18,2);
define dImp_pagado      decimal(18,2);
define cBorra_conv      char(1);
define dFecha_cumpl_max date;
 
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
LET vmCantidadAcordada = 0.00;
LET vmSuma = 0.00;
LET vcEsTransaccion = 'N';
LET vmaxkeyx = 0;
LET vPlazo = '';
LET vlFlagPago = '0';
LET vHorainsert = CURRENT;
LET vFechaCumplimiento = '01/01/1900';
LET vCuentaPagosProg = 0;
LET vPagoProgramado = '';
LET cuentas_procesar = 0;
LET cuentas_cumplio = 0;
LET cuentas_nocumplido = 0;
LET vMensaje = '';
LET dFecha_promesarota = date(1);
LET dFecha_cifrado = date(1);
let iCuenta_creds = 0;
let dtFechaIni       = date(1); ---- Evaluación Objetiva
let dtFechaFin       = date(1);
let iCteAsisteSuc    = 0;
let cOrigen          = '';
let pSucursalOrig    = '';
let psucursal        = ''; 
let pfechasistema    = date(1); 
let pefectuo_compac  = 0;
let pnombre_efectuo  = '';
let pnumcuenta       = '';
let pnumproducto     = '';
let pplazo           = '';
let porigen          = 0;
let ptipo_compac     = '';
let pimporte         = 0;  
let dImp_pagado      = 0;
let cBorra_conv      = '';
let dFecha_cumpl_max = date(1);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN    
	ON EXCEPTION SET viSqlErr, isam_err, error_info
		LET vcCodret = viSqlErr;
		LET cMensaje = error_info;
		CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodRet, cMensaje, '02');
		RETURN vcCodRet;            
	END EXCEPTION;

   --SET DEBUG FILE TO "/ifxsif01/macf/sp_marcaracuerdoscumplidos.trc";
   --TRACE ON;

    CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, cMensaje, '01');

	IF pEmpresa IS NULL OR pEmpresa = "" THEN
		LET vcCodRet = '00001';
		LET viSqlErr = '00001';
		LET cMensaje = 'FALTA PARAMETRO EMPRESA';
	ELSE
		IF pTipo = "0" OR pTipo = "" THEN
			SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)} fecha_hoy, pri_dia_mes, ult_dia_mes
			INTO vdFechaHoy, dtFechaIni, dtFechaFin
			FROM bdinteg:si_fechas
			WHERE empresa = pEmpresa;
		ELSE
			IF pFecha IS NULL OR pFecha = "" THEN
				LET vcCodRet = '00002';      --CÓDIGO DE ERROR PARÁMETRO INCORRECTO
				LET viSqlErr = '00002';
				LET cMensaje = 'FALTA PARAMETRO FECHA';
			ELSE
				LET vdFechaHoy = pFecha;
			END IF;
		END IF;

		
		IF vcCodRet = '00000' THEN
	--        BEGIN WORK;
			LET vcEsTransaccion = 'S';

			--let dFecha_cumpl_max = date(vdFechaHoy + 28 units day);
			
			FOREACH WITH HOLD
			    -- Obtener también el campo imp_pagado
				SELECT {+INDEX(bdicobranza:cb_compac idx_compac3)} a.numcuenta, a.importe, a.fecha_compac, a.plazo, a.hora_insert, a.imp_pagado
				INTO vcNumCuenta, vmCantidadAcordada, vdFechaAcuerdo, vPlazo, vHorainsert, dImp_pagado 
				FROM BDICOBRANZA:CB_COMPAC a
				     INNER JOIN bdicred:sd_maecred b ON (b.empresa = a.empresa AND b.num_credito = a.numcuenta)
				WHERE a.empresa = pEmpresa 
				AND ( vdFechaHoy + ( a.plazo * 7 ) ) >= a.fecha_compac
				AND a.activo = 1
				
				LET cuentas_procesar = cuentas_procesar + 1;
			   
				LET vFechaCumplimiento = vdFechaAcuerdo + (vPlazo * 7) UNITS DAY; 
				
				--A.L.L Sacamos si la fecha es inhabil para sumarle un dia
				SELECT fecha into dFecha_cifrado
				  FROM bdinteg:si_feriado 
				 WHERE pais = '001' and fecha = vFechaCumplimiento AND laborable = 'N';
				
				if NVL(dFecha_cifrado,'') <> '' and dFecha_cifrado <> mdy('01','01','1900') then
				   LET vFechaCumplimiento = vFechaCumplimiento - 1 UNITS DAY; 
				end if;
				
				--IF EXISTS (SELECT fecha FROM bdinteg:si_feriado WHERE pais = '001' and fecha = vFechaCumplimiento AND laborable = 'N') THEN
				--	LET vFechaCumplimiento = vFechaCumplimiento - 1 UNITS DAY; 
				--END IF;
				
				SELECT max(keyx)
				INTO vmaxkeyx
				FROM bdicobranza:cb_compac
				where empresa = pEmpresa and fecha_compac = vdFechaAcuerdo and numcuenta = vcNumCuenta;
				
				LET vmSumaPagos = 0.00;
				LET vmSuma = 0.00;
				
				select count(*) into iCuenta_creds
				  from cb_compac_his where numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo;
				
				if iCuenta_creds = 0 then
				--IF NOT EXISTS (select numcuenta from cb_compac_his where numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo) THEN
				
					-- No importa si el convenio es del día actual
					-- SUMA DE LOS PAGOS DEL DÍA ACTUAL (sd_movdia) POR VENTANILLA, INTERNET y CHEQUES.
					--IF vdFechaAcuerdo = vdFechaHoy THEN  --EVALOBJ
						--SELECT {+INDEX(bdicred:sd_movdia mov3)} NVL(SUM(monto),0) 
						SELECT NVL(SUM(monto),0)
						INTO vmSuma 
						FROM bdicred:sd_movdia     --SOLO PRUEBAS sd_movhis
						WHERE empresa = pEmpresa AND num_credito = vcNumCuenta 
						AND fecha_mov = vdFechaHoy
						AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual where cod_fun >= '')
						AND codigo_ref = 1
						AND reversado = 'N';
						--AND hora_mov > vHorainsert;  -- No importa la hora
	  
						IF (vmSuma is null) THEN
							LET vmSuma = 0;
						END IF;
				   
						LET vmSumaPagos = vmSuma;
					/*ELSE  --EVALOBJ
						-- EVALOBJ Al parecer solo necesitaré los del día actual pq se irán acumulando en cb_compac hasta que llegue su fecha vencim.
						-- SUMA DE LOS PAGOS DE LOS DÍAS ANTERIORES (sc_movhis)  POR VENTANILLA, INTERNET y CHEQUES.
						SELECT {+INDEX(bdicred:sd_movdia mov3)} NVL(SUM(monto),0) 
						INTO vmSuma 
						FROM bdicred:sd_movdia 
						WHERE empresa = pEmpresa AND num_credito = vcNumCuenta
						AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)--in ('033', '334', '335', '336', '337')
						AND codigo_ref = 1
						AND fecha_mov > vdFechaAcuerdo   -- MACF En prod esta >, pero para lo de pp ponerlo como >=
						AND reversado = 'N';
						
						IF (vmSuma is null) THEN
							LET vmSuma = 0;
						END IF;
						
						LET vmSumaPagos = vmSuma;

						SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) 
						INTO vmSuma 
						FROM bdicred:sd_movhis
						WHERE empresa = pEmpresa and num_credito = vcNumCuenta
						and codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)--in ('033', '334', '335', '336', '337')
						and codigo_ref = 1
						and fecha_mov > vdFechaAcuerdo 
						and reversado = 'N';

						LET vmSumaPagos = vmSumaPagos + vmSuma;
						
					END IF;
			        */
					--- Esto continúa igual ya que en el rqm no hacen mención que se deba cambiar
					--- Revisar si hay registrado algún pago programado
					select {+MULTI_INDEX(bdiprog:pp_pagoprog)} count(*) INTO vCuentaPagosProg
					from bdicred:sd_tarjeta a,
					 bdiprog:pp_pagoprog b,
					 bdicred:sd_movdia c
					where a.empresa = pEmpresa
					and a.num_tarjeta = b.cuenta_destino
					and b.cve_cuenta_dest = '04' 
					and b.cve_canal = '01' 
					and b.fecha_inicio = vdFechaHoy 
					and b.fecha_fin = vdFechaHoy 
					and a.empresa = c.empresa
					and a.num_credito = c.num_credito
					and c.codigo_fun = '337'
					and c.codigo_ref = 1
					and b.importe = c.monto
					and c.num_credito = vcNumCuenta
					AND (b.fecha_fin - b.fecha_insert) = 1;

					IF vCuentaPagosProg > 0 THEN 
					   LET vPagoProgramado = 'S'; 
					ELSE 
					   LET vPagoProgramado = '';
					END IF;
                    
					--- 1.- Si fecha hoy es mayor o igual a fecha cumplimiento, es momento de evaluar el convenio  (no importa si pagó o no)
                    --IF vmSumaPagos > 0 and (vdFechaHoy  >=  vFechaCumplimiento) THEN
					IF vdFechaHoy  >=  vFechaCumplimiento THEN

					   BEGIN WORK;
					   let cBorra_conv = 'S';
					   
                       IF (dImp_pagado+vmSumaPagos >= vmCantidadAcordada and vPagoProgramado = '') THEN
					      -- Se actualiza en cb_compac el imp_pagado con dImp_pagado+vmSumaPagos y flag_pago a 1 (CUMPLIDO)
                          update bdicobranza:cb_compac set flag_pago = 1, imp_pagado = nvl(imp_pagado,0) + vmSumaPagos, pago_programado = vPagoProgramado
						      --fecha_insert = vdFechaHoy
						  where empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;
						  
						  let vlFlagPago = '1';
						  let cuentas_cumplio = cuentas_cumplio + 1;
					   ELSE 
					      -- Se actualiza en cb_compac el imp_pagado con dImp_pagado+vmSumaPagos y flag_pago a 0 (NO CUMPLIDO) 
						  update bdicobranza:cb_compac set flag_pago = 0, imp_pagado = nvl(imp_pagado,0) + vmSumaPagos, pago_programado = vPagoProgramado
						     --fecha_insert = vdFechaHoy
						  where empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;

                          let vlFlagPago = '0';
						  let cuentas_nocumplido = cuentas_nocumplido + 1;
								
						  -- RQM 09 473 Triad MACF
						  let dFecha_promesarota = vFechaCumplimiento; 
						  -- RQM 09 473 Triad MACF						  
					
					   END IF; 
					   -- y se pasa a cb_compac_his el registro
					       INSERT INTO bdicobranza:cb_compac_his(empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, importe, tipo_compac, activo, flag_pago,
									  efectuo_compac, tipo_movto, nombre_efectuo,  fecha_compac, fecha_insert, keyx, quien_convenio, nom_convenio, email,
									  referenciacoppel, imp_pagado, hora_insert, pago_programado, pago_minimo)

							SELECT empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, importe, tipo_compac, '0', flag_pago,
								   efectuo_compac, '', nombre_efectuo,  fecha_compac, fecha_insert, keyx, quien_convenio, nom_convenio, email,
								   referenciacoppel, nvl(imp_pagado, 0), hora_insert, pago_programado, pago_minimo
							  FROM bdicobranza:CB_COMPAC 
							 WHERE empresa = pEmpresa AND numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo AND keyx = vmaxkeyx;
					    
					   -- Se actualiza la tabla de indicadores
						 UPDATE bdicred:sd_indicador_cred SET cumplio_convenio = vlFlagPago, fecha_promesa_rota = dFecha_promesarota
						  WHERE empresa = pEmpresa AND num_credito = vcNumCuenta;
							
					   -- El sistema elimina los compromisos vencidos
							DELETE FROM BDICOBRANZA:CB_COMPAC 
							WHERE empresa = pEmpresa AND numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo AND keyx = vmaxkeyx;
					   
					   COMMIT WORK;
					   
					--- 1b.- Si no solo se actualizará el monto recibido, y el convenio sigue vivo en cb_compac
					ELIF  vmSumaPagos > 0 THEN 
					 BEGIN WORK;  
					   let cBorra_conv = 'N';
					   update bdicobranza:cb_compac set imp_pagado = nvl(imp_pagado,0) + vmSumaPagos, pago_programado = vPagoProgramado,
					      fecha_insert = vdFechaHoy
					    where empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;
					
					 COMMIT WORK;
					
					END IF;

				END IF;
				
		let vCuentaPagosProg = 0;
		let vPagoProgramado = '';

		END FOREACH;

		let vcEsTransaccion = 'N';
        END IF;
    END IF;
		
	LET vMensaje = 'CUENTAS PROCESADAS = '||cuentas_procesar;
	CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, TRIM(vMensaje), '02');
	LET vMensaje = '';
	LET vMensaje = 'CUENTAS CONVENIO CUMPLIDO = '||cuentas_cumplio;
	LET vMensaje = TRIM(vMensaje)||'  CUENTAS CONVENIO NO CUMPLIDO = '||cuentas_nocumplido;
	CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, TRIM(vMensaje), '02');

	--IF vcCodRet <> '00000' then

	CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vproceso, vcCodret, cMensaje, '03');

	--END IF;

	RETURN vcCodRet;
END;
END PROCEDURE;