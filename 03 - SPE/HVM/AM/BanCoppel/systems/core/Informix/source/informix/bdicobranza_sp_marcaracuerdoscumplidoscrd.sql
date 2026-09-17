CREATE PROCEDURE "informix".sp_marcaracuerdoscumplidoscrd(pEmpresa char(3), pTipo char(1), pFecha date )
RETURNING CHAR(5);

--Fecha de creacion: 14/04/2016
--ProgramÃ³: Carlos Valenzuela
--Objetivo: Store Procedure que realiza el marcaje de los compromisos y acuerdos que ya fueron
--cumplidos o en su defecto los que ya se vencieron para las cuentas a plazos.

--Fecha de Modificacion: 21/04/2016
--ProgramÃ³: Carlos Valenzuela
--Objetivo: Se modifica proceso para que al momento de hacer la migracion de la tabla compac a la historica,
--			considere el nuevo campo pago_minimo.


DEFINE vcCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE vdFechaHoy DATE;
DEFINE vdFechaAcuerdo DATE;
DEFINE vFechaCumplimiento DATE;

DEFINE vcNumCuenta CHAR(20);
DEFINE vmSumaPagos  MONEY(16,2);
DEFINE vmSuma   MONEY(16,2);
DEFINE vmSuma_temp   MONEY(16,2);
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
DEFINE vNumProducto CHAR(4);
DEFINE cuentas_procesar INTEGER;
DEFINE cuentas_cumplio INTEGER;
DEFINE cuentas_nocumplido INTEGER;
DEFINE dFecha_promesarota  DATE;
DEFINE dFecha_cifrado DATE;
DEFINE iCuenta_creds smallint;

define dImp_pagado      decimal(18,2);
define cBorra_conv      char(1);
define dFecha_cumpl_max date;

LET viSqlErr = 0;
LET vOrigen = 4;
LET vProceso = 'MACCRD';
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
LET vlFlagPago = '';
LET vHorainsert = CURRENT;
LET vFechaCumplimiento = '01/01/1900';
LET vNumProducto = '';
LET cuentas_procesar = 0;
LET cuentas_cumplio = 0;
LET cuentas_nocumplido = 0;
LET vMensaje = '';
LET dFecha_promesarota = date(1);
LET dFecha_cifrado = date(1);
let iCuenta_creds = 0;

let dImp_pagado      = 0;
let cBorra_conv      = '';
let dFecha_cumpl_max = date(1);
let vmSuma_temp  = 0.00;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;
SET LOCK MODE TO WAIT 3;

BEGIN    
	ON EXCEPTION SET viSqlErr, isam_err, error_info
		LET vcCodret = viSqlErr;
		LET cMensaje = error_info;
		CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodRet, cMensaje, '02');
		RETURN vcCodRet;            
	END EXCEPTION;

  --SET DEBUG FILE TO "/ifxsif01/macf/sp_marcaracuerdoscumplidoscrd.trc";
  --TRACE ON;  
        
    CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, cMensaje, '01');

	IF pEmpresa IS NULL OR pEmpresa = "" THEN
		LET vcCodRet = '00001';
		LET viSqlErr = '00001';
		LET cMensaje = 'FALTA PARAMETRO EMPRESA';
		CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, cMensaje, '02');
	ELSE
		IF pTipo = "0" OR pTipo = "" THEN
			SELECT {+INDEX(bdinteg:si_fechas idx_si_fechas)} fecha_hoy
			INTO vdFechaHoy
			FROM bdinteg:si_fechas
			--FROM bdicred:sd_fechas_pred
			WHERE empresa = pEmpresa;
		ELSE
			IF pFecha IS NULL OR pFecha = "" THEN
				LET vcCodRet = '00002';      --CODIGO DE ERROR PARAMETRO INCORRECTO
				LET viSqlErr = '00002';
				LET cMensaje = 'FALTA PARAMETRO FECHA';
				CALL bdicobranza:"informix".inserta_bitacora_cob(pempresa, vProceso, vcCodret, cMensaje, '02');
			ELSE
				LET vdFechaHoy = pFecha;
			END IF;
		END IF;
		
		--LET vdFechaHoy = MDY(8,7,2019);  --SOLO TEST

		IF vcCodRet = '00000' THEN

			LET vcEsTransaccion = 'S';

			--let dFecha_cumpl_max = date(vdFechaHoy + 28 units day);
			
			FOREACH WITH HOLD
				SELECT {+INDEX(bdicobranza:cb_compac idx_compac3)}
					a.numcuenta, a.importe, a.fecha_compac, a.plazo, a.hora_insert, b.num_producto, a.imp_pagado
				INTO vcNumCuenta, vmCantidadAcordada, vdFechaAcuerdo, vPlazo, vHorainsert, vNumProducto, dImp_pagado
				FROM BDICOBRANZA:CB_COMPAC a
				INNER JOIN bdicred:sd_maecredcrd b ON (b.empresa = a.empresa AND b.num_credito = a.numcuenta 
				      AND b.num_producto IN('6011', '6300', '7600', '7700','6400','6800'))
				WHERE a.empresa = pEmpresa
				AND a.activo = 1
				AND ( vdFechaHoy + ( a.plazo * 7 ) ) >= a.fecha_compac

				
				LET cuentas_procesar = cuentas_procesar + 1;

				LET vFechaCumplimiento = vdFechaAcuerdo + (vPlazo * 7) UNITS DAY; 
		
				--Sacamos si la fecha es inhabil para sumarle un dia  
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
				  from bdicobranza:cb_compac_his where numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo;
				
				--IF NOT EXISTS (select numcuenta from cb_compac_his where numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo) THEN
				if iCuenta_creds = 0 then 

					-- SUMA DE LOS PAGOS DEL DIA ACTUAL (sd_movdiacrd) POR CUALQUIER CANAL DE PAGO.
					--IF vdFechaAcuerdo = vdFechaHoy THEN
						
					SELECT SUM(monto)
						INTO vmSuma_temp
						FROM bdicred:sd_movdiacrd  --SOLO PRUEBAS sd_movhiscrd - PROD movdia
						WHERE empresa = pEmpresa AND num_credito = vcNumCuenta 
						AND fecha_mov = vdFechaHoy
						AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd WHERE num_producto = vNumProducto) --in ('033', '334', '335', '336', '337')
						AND codigo_ref = 1
						AND reversado = 'N';
						--AND hora_mov > vHorainsert;
	          						           				           
                        LET vmSuma = NVL(vmSuma_temp,0);


						LET vmSumaPagos = vmSuma;
					
					--- 1.- Si fecha hoy es mayor o igual a fecha cumplimiento, es momento de evaluar el convenio (no importa si tuvo pago o no)
					--IF ( vmSumaPagos > 0  )  OR  ( vdFechaHoy  >=  vFechaCumplimiento )     THEN
					IF vdFechaHoy  >=  vFechaCumplimiento  THEN

						BEGIN WORK;
					
							--IF vmSumaPagos >= (vmCantidadAcordada/2) THEN
							IF (dImp_pagado+vmSumaPagos >= vmCantidadAcordada) THEN

								
								-- Se actualiza en cb_compac el imp_pagado con dImp_pagado+vmSumaPagos y flag_pago a 1 (CUMPLIDO)
                                update bdicobranza:cb_compac set flag_pago = 1, imp_pagado = nvl(imp_pagado,0) + vmSumaPagos,
						               fecha_insert = vdFechaHoy
						         where empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;

								Let vlFlagPago = '1';  
								LET cuentas_cumplio = cuentas_cumplio + 1;
								-- RQM 09 473 Triad MACF
								let dFecha_promesarota = date(1);
								-- RQM 09 473 Triad MACF
								
							ELSE
							
								-- Se actualiza en cb_compac el imp_pagado con dImp_pagado+vmSumaPagos y flag_pago a 0 (NO CUMPLIDO) 
						        update bdicobranza:cb_compac set flag_pago = 0, imp_pagado = nvl(imp_pagado,0) + vmSumaPagos,
						               fecha_insert = vdFechaHoy
						         where empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;

                                let vlFlagPago = '0';
						        let cuentas_nocumplido = cuentas_nocumplido + 1;
							
								-- RQM 09 473 Triad MACF
								let dFecha_promesarota = vFechaCumplimiento; 
								-- RQM 09 473 Triad MACF
								
							END IF;
							
							--El sistema replica los compromisos marcados como cumplidos y los compromisos vencidos  a la tabla de movimientos historicos.
							INSERT INTO bdicobranza:cb_compac_his(empresa, sucursal, origen, empleado_captura, numcliente, 
									  numcuenta, plazo, importe, tipo_compac, activo, flag_pago, 
									  efectuo_compac, tipo_movto, nombre_efectuo,  fecha_compac, 
									  fecha_insert, keyx, quien_convenio, nom_convenio, email, 
									  referenciacoppel, imp_pagado, hora_insert, pago_programado, pago_minimo)

							SELECT empresa, sucursal, origen, empleado_captura, numcliente, 
								   numcuenta, plazo, importe, tipo_compac, '0', flag_pago, 
								   efectuo_compac, '', nombre_efectuo,  fecha_compac, 
								   --today, keyx, quien_convenio, nom_convenio, email,   -- en la fecha del dÃ­a confirmar si se guarde mejor la de si_fechas, o como ya estaba
								   fecha_insert, keyx, quien_convenio, nom_convenio, email,
								   referenciacoppel, nvl(imp_pagado, 0), hora_insert, pago_programado, pago_minimo
							FROM bdicobranza:CB_COMPAC 
							WHERE empresa = pEmpresa AND numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo AND keyx = vmaxkeyx;

							UPDATE bdicred:sd_indicador_cred_crd SET cumplio_convenio = vlFlagPago, fecha_promesa_rota = dFecha_promesarota 
							 WHERE empresa = pEmpresa AND num_credito = vcNumCuenta;
							
							-- El sistema elimina los compromisos marcados como cumplidos y los compromisos vencidos de la tabla de movimientos.
							DELETE FROM BDICOBRANZA:CB_COMPAC 
							WHERE empresa = pEmpresa AND numcuenta = vcNumCuenta AND fecha_compac = vdFechaAcuerdo AND keyx = vmaxkeyx;
						COMMIT WORK;
						
					ELIF  vmSumaPagos > 0 THEN 

					  BEGIN WORK;  
					    let cBorra_conv = 'N';
					    update bdicobranza:cb_compac set imp_pagado = nvl(imp_pagado,0) + vmSumaPagos,
					       fecha_insert = vdFechaHoy
					     where empresa = pEmpresa and numcuenta = vcNumCuenta and fecha_compac = vdFechaAcuerdo and keyx = vmaxkeyx;
					
					  COMMIT WORK;
						
						
					END IF;
				END IF;
				
				LET vlFlagPago = '';

			END FOREACH;

			LET vcEsTransaccion = 'N';

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