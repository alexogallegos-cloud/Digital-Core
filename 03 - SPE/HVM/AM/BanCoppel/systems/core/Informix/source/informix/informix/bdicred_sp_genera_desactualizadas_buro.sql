CREATE PROCEDURE "informix".sp_genera_desactualizadas_buro(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(4), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20) AS num_credito;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdxReg INTEGER;
	DEFINE cDuplicada CHAR(2);
	DEFINE cNivelDesactualizada CHAR(3);
	DEFINE cMemberCode CHAR(10);
	DEFINE cMemberKob CHAR(2);
	DEFINE cNumCredito CHAR(20);
	DEFINE cFechaReporte CHAR(8);
	DEFINE cIdExpediente CHAR(10);
	DEFINE cRfc CHAR(20);
	DEFINE cApellidoPaterno CHAR(30);
	DEFINE cApellidoMaterno CHAR(30);
	DEFINE cApellidoAdicional CHAR(30);
	DEFINE cPrimerNombre CHAR(30);
	DEFINE cSegundoNombre CHAR(30);
	DEFINE cFechaApertura CHAR(8);
	DEFINE cTipoContrato CHAR(2);
	DEFINE cTipoCuenta CHAR(1);
	DEFINE cLimiteCredito CHAR(20);
	DEFINE cHistoricoPago CHAR(128);
	DEFINE cIdInterno CHAR(20) ;
	DEFINE cClaveObservacion CHAR(10);
	DEFINE cFormaPago CHAR(2);
	DEFINE cSaldoActual CHAR(20);
	DEFINE cSaldoVencido CHAR(20);
	DEFINE cImportePago CHAR(20);
	DEFINE cFechaCierre CHAR(8);
	DEFINE cSaldoActual1 CHAR(18);
	DEFINE cSaldoVencido1 CHAR(18);
	DEFINE cImportePago1 CHAR(18);
	DEFINE cFormaPago1 CHAR(2);
	DEFINE cClaveObserva1 CHAR(2);
	DEFINE cNumCreditoExt CHAR(20);
	
	DEFINE iRecuperacion INTEGER;	
	DEFINE cMemberKobAux CHAR(2);
	DEFINE cNumCreditoAux CHAR(20);
	DEFINE cProducto CHAR(4);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	LET iIdxReg = 0;
	LET cDuplicada = '';
	LET cNivelDesactualizada = '';
	LET cMemberCode = '';
	LET cMemberKob = '';
	LET cNumCredito = '';
	LET cFechaReporte = '';
	LET cIdExpediente = '';
	LET cRfc = '';
	LET cApellidoPaterno = '';
	LET cApellidoMaterno = '';
	LET cApellidoAdicional = '';
	LET cPrimerNombre = '';
	LET cSegundoNombre = '';
	LET cFechaApertura = '';
	LET cTipoContrato = '';
	LET cTipoCuenta = '';
	LET cLimiteCredito = '';
	LET cHistoricoPago = '';
	LET cIdInterno = '';
	LET cClaveObservacion = '';
	LET cFormaPago = '';
	LET cSaldoActual = '';
	LET cSaldoVencido = '';
	LET cImportePago = '';
	LET cFechaCierre = '';
	LET cSaldoActual1 = '';
	LET cSaldoVencido1 = '';
	LET cImportePago1 = '';
	LET cFormaPago1 = '';
	LET cClaveObserva1 = '';
	LET cNumCreditoExt = '';
	
	LET cMemberKobAux = '';
	LET cNumCreditoAux = '';
	LET iRecuperacion = 0;
	LET cProducto = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNumCreditoAux;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_genera_desactualizadas_buro.out';
		--TRACE ON;
		
		---VALIDACIÃN DE DATOS REQUERIDOS
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNumCreditoAux;
		END IF;
		
		-- VALIDACIÃN DE LOS DATOS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cNumCreditoAux;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNumCreditoAux;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion member_kob, num_credito, idx
			INTO cMemberKobAux,cNumCreditoAux,iIdxReg
			FROM bdicred:'informix'.sd_desactualizadas_temp

				IF cMemberKobAux = 'BC' THEN 
					---Obtiene tipo producto del credito
					SELECT num_producto
					INTO cProducto
					FROM
					(SELECT num_producto 
					FROM bdicred:'informix'.sd_maecred
					WHERE num_credito = cNumCreditoAux
					UNION
					SELECT num_producto 
					FROM bdicred:'informix'.sd_maecredcrd
					WHERE num_credito = cNumCreditoAux);					
					
					IF cProducto IN ('6001','6600','6500','7000') THEN
						---TARJETAS DE CREDITO
						INSERT INTO bdicred:'informix'.sd_desactualizadas_buro(duplicada,nivel_desactualizada,member_code,member_kob,num_credito,fecha_reporte,id_expediente,
							rfc,apellido_paterno,apellido_materno,apellido_adicional,primer_nombre,segundo_nombre,fecha_apertura,
							tipo_contrato,tipo_cuenta,limite_credito,historico_pago,id_interno,clave_observacion,forma_pago,
							saldo_actual,saldo_vencido,importe_pago,fecha_cierre,saldo_actual_1,saldo_vencido_1,importe_pago_1,
							forma_pago_1,clave_observa_1,num_credito_ext,fecha_proceso)
						SELECT cte.duplicada, cte.nivel_desactualizada, cte.member_code, cte.member_kob, cte.num_credito, cte.fecha_reporte, cte.id_expediente,				
							cte.rfc, cte.apellido_paterno, cte.apellido_materno, cte.apellido_adicional, cte.primer_nombre, cte.segundo_nombre, cte.fecha_apertura,				
							cte.tipo_contrato, cte.tipo_cuenta, cte.limite_credito, cte.historico_pago, cte.id_interno, cte.clave_observacion, cte.forma_pago,					
							cte.saldo_actual, cte.saldo_vencido, cte.importe_pago,''||YEAR(mav.fecha)||LPAD(MONTH(mav.fecha),2,'0')||LPAD(DAY(mav.fecha),2,'0') AS fecha_cierre, --substr(mav.fecha,7,4)||substr(mav.fecha,1,2)||substr(mav.fecha,4,2) as fecha_cierre
							'0' AS saldo_actual_1,
							CASE WHEN mae.credito_externo = '' THEN ROUND(msv.sdo_cap_insoluto,0)::CHAR(18)
								 WHEN mae.credito_externo <> '' THEN '0' 
							END
							AS saldo_vencido_1,
							'0' AS importe_pago_1,
							CASE WHEN mae.credito_externo <> '' THEN '01'  
								 WHEN mae.credito_externo = '' THEN 
							(SELECT 
							CASE WHEN COUNT(*)+1 <= 7 THEN '0'||COUNT(*)+1 
								 WHEN COUNT(*)+1 > 7 AND COUNT(*)+1 <= 12 THEN '07' 
								 WHEN COUNT(*)+1 > 12 THEN '96'
							END  
							FROM bdicred:'informix'.sd_amortiza_credito_vendida WHERE num_credito = cte.num_credito AND capital_status IN ('2','7','6'))
							END
							AS forma_pago_1,
							CASE WHEN mae.credito_externo = '' THEN 'CV' 
								 WHEN mae.credito_externo <> '' THEN 'RV' 
							END
							AS clave_observa_1, 
							CASE WHEN mae.credito_externo = '' THEN ''
								 WHEN mae.credito_externo <> '' THEN mae.credito_externo
							END
							AS num_credito_ext,
							pFecha AS fecha_proceso
							FROM bdicred:'informix'.sd_desactualizadas_temp cte
							LEFT JOIN bdicred:'informix'.sd_maecred mae ON mae.num_credito = cte.num_credito 
							LEFT JOIN bdicred:'informix'.sd_maesdos_vendida msv ON msv.num_credito = cte.num_credito  
							LEFT JOIN bdicred:'informix'.sd_maecred_vendida mav ON mav.num_credito = cte.num_credito 
							WHERE  mav.fecha = msv.fecha AND cte.num_credito = cNumCreditoAux AND cte.idx = iIdxReg;
							
						LET iNoRegistros =  iNoRegistros + DBINFO('sqlca.sqlerrd2');
						
					ELSE
						--REESTRUCTURAS
						INSERT INTO bdicred:'informix'.sd_desactualizadas_buro(duplicada,nivel_desactualizada,member_code,member_kob,num_credito,fecha_reporte,id_expediente,
							rfc,apellido_paterno,apellido_materno,apellido_adicional,primer_nombre,segundo_nombre,fecha_apertura,
							tipo_contrato,tipo_cuenta,limite_credito,historico_pago,id_interno,clave_observacion,forma_pago,
							saldo_actual,saldo_vencido,importe_pago,fecha_cierre,saldo_actual_1,saldo_vencido_1,importe_pago_1,
							forma_pago_1,clave_observa_1,num_credito_ext,fecha_proceso)
						SELECT cte.duplicada, cte.nivel_desactualizada, cte.member_code, cte.member_kob, cte.num_credito, cte.fecha_reporte, cte.id_expediente,				
							cte.rfc, cte.apellido_paterno, cte.apellido_materno, cte.apellido_adicional, cte.primer_nombre, cte.segundo_nombre, cte.fecha_apertura,				
							cte.tipo_contrato, cte.tipo_cuenta, cte.limite_credito, cte.historico_pago, cte.id_interno, cte.clave_observacion, cte.forma_pago,					
							cte.saldo_actual, cte.saldo_vencido, cte.importe_pago,''||YEAR(mav.fecha)||LPAD(MONTH(mav.fecha),2,'0')||LPAD(DAY(mav.fecha),2,'0')  AS fecha_cierre
							,'0' AS saldo_actual_1,
							ROUND(msv.sdo_cap_insoluto,0)::CHAR(18)
							AS saldo_vencido_1,'0' AS importe_pago_1,
							(SELECT 
							CASE WHEN COUNT(*)+1 <= 7 THEN '0'||COUNT(*)+1 
								 WHEN COUNT(*)+1 > 7 AND COUNT(*)+1 <= 12 THEN '07' 
								 WHEN COUNT(*)+1 > 12 THEN '96'
							END  
							FROM bdicred:'informix'.sd_amortiza_creditocrd_vendida WHERE num_credito = cte.num_credito AND capital_status in ('2','7','6')) AS forma_pago_1,
							'CV' AS clave_observa_1,
							'' AS num_credito_ext,
							pFecha AS fecha_proceso
							FROM bdicred:'informix'.sd_desactualizadas_temp cte
							LEFT JOIN bdicred:'informix'.sd_maesdoscrd_vendida msv ON msv.num_credito = cte.num_credito  
							LEFT JOIN bdicred:'informix'.sd_maecredcrd_vendida mav ON mav.num_credito = cte.num_credito 
							WHERE  mav.fecha = msv.fecha  AND cte.num_credito = cNumCreditoAux AND cte.idx = iIdxReg;
							
						LET iNoRegistros =  iNoRegistros + DBINFO('sqlca.sqlerrd2');
						
					END IF;	
				ELSE
					--CUENTAS A PLAZO
					INSERT INTO bdicred:'informix'.sd_desactualizadas_buro(duplicada,nivel_desactualizada,member_code,member_kob,num_credito,fecha_reporte,id_expediente,
						rfc,apellido_paterno,apellido_materno,apellido_adicional,primer_nombre,segundo_nombre,fecha_apertura,
						tipo_contrato,tipo_cuenta,limite_credito,historico_pago,id_interno,clave_observacion,forma_pago,
						saldo_actual,saldo_vencido,importe_pago,fecha_cierre,saldo_actual_1,saldo_vencido_1,importe_pago_1,
						forma_pago_1,clave_observa_1,num_credito_ext,fecha_proceso)
					SELECT cte.duplicada, cte.nivel_desactualizada, cte.member_code, cte.member_kob, cte.num_credito, cte.fecha_reporte, cte.id_expediente,				
						cte.rfc, cte.apellido_paterno, cte.apellido_materno, cte.apellido_adicional, cte.primer_nombre, cte.segundo_nombre, cte.fecha_apertura,				
						cte.tipo_contrato, cte.tipo_cuenta, cte.limite_credito, cte.historico_pago, cte.id_interno, cte.clave_observacion, cte.forma_pago,					
						cte.saldo_actual, cte.saldo_vencido, cte.importe_pago,''||YEAR(mav.fecha)||LPAD(MONTH(mav.fecha),2,'0')||LPAD(DAY(mav.fecha),2,'0')  AS fecha_cierre
						,'0' AS saldo_actual_1,
						CASE WHEN mav.credito_externo = '' THEN ROUND(msv.sdo_cap_insoluto,0)::CHAR(18)
							 WHEN mav.credito_externo <> '' THEN '0' 
						END
						AS saldo_vencido_1,'0' AS importe_pago_1,
						CASE WHEN mav.credito_externo <> '' THEN '01'  
							 WHEN mav.credito_externo = '' THEN 
						(SELECT 
						CASE WHEN COUNT(*)+1 <= 7 THEN '0'||COUNT(*)+1 
							 WHEN COUNT(*)+1 > 7 AND COUNT(*)+1 <= 12 THEN '07' 
							 WHEN COUNT(*)+1 > 12 THEN '96'
						END  
						FROM bdicred:'informix'.sd_amortiza_creditocrd_vendida WHERE num_credito = cte.num_credito AND capital_status IN ('2','7','6'))
						END AS forma_pago_1, 
						CASE WHEN mav.credito_externo = '' THEN 'CV' 
							 WHEN mav.credito_externo <> '' THEN 'RV' 
						END AS clave_observa_1, 
						CASE WHEN mav.credito_externo = '' THEN ''
							 WHEN mav.credito_externo <> '' THEN mav.credito_externo
						END AS num_credito_ext,
						pFecha AS fecha_proceso
						FROM bdicred:'informix'.sd_desactualizadas_temp cte
						LEFT JOIN bdicred:'informix'.sd_maesdoscrd_vendida msv ON msv.num_credito = cte.num_credito  
						LEFT JOIN bdicred:'informix'.sd_maecredcrd_vendida mav ON mav.num_credito = cte.num_credito 
						WHERE  mav.fecha = msv.fecha  AND cte.num_credito = cNumCreditoAux AND cte.idx = iIdxReg;
						
						LET iNoRegistros =  iNoRegistros + DBINFO('sqlca.sqlerrd2');
							
				END IF;
				
				RETURN cCodRet,cNumCreditoAux WITH RESUME;
				
			END FOREACH;
			
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Rodolfo Conde Flores',
'FECHA: 01/12/2015',
'MODULO: CRÃDITO',
'FUNCIONALIDAD: Cuentas Desactualizadas de BurÃ³ de CrÃ©dito',
'DESCRIPCION: Genera complemento de reporte para contestacion a burÃ³ de crÃ©dito',
'FECHA: 22/02/2016',
'DESCRIPCION: Se actualiza credito_externo de NV a CV solicitado por bancoppel para cuentas a plazo',
'FECHA: 25/02/2016',
'DESCRIPCION: Se modifica tamaÃ±o de columna historico_pago de 8 a 80 caracteres',
'FECHA: 08/03/2016',
'DESCRIPCION: Se modifica tamaÃ±o de columna historico_pago de 80 a 128 caracteres',
'BD: bdicred';

CREATE PROCEDURE "informix".consultmovs_web(pempresa CHAR(3), 
											pcuenta  CHAR(20), 
											psecuencia SMALLINT)
   RETURNING CHAR(5),DATE,CHAR(40),MONEY(14,2),MONEY(14,2),MONEY(14,2),DECIMAL(14,2), DECIMAL(14,2); 

   DEFINE vtransacc   CHAR(40);
   DEFINE vfecha      DATE;
   DEFINE vmonto      MONEY(14,2);
   DEFINE vserial     INTEGER;
   DEFINE vconta      SMALLINT;
   DEFINE vciclo      SMALLINT;
   DEFINE vcodret     CHAR(5);
   DEFINE vsqlerr     INTEGER;
   DEFINE vnaturaleza CHAR(1);
   DEFINE vultmovto   SMALLINT;
   DEFINE vSucursal   CHAR(4);
   DEFINE vPorcIva    DECIMAL(14,2);
   DEFINE vSdoDeudor  DECIMAL(14,2);
   DEFINE vPagoMin    DECIMAL(14,2);
   DEFINE vFechaCorte CHAR(15);
   DEFINE vFechaPago  CHAR(15);
   DEFINE vIntMora    DECIMAL(14,2);
   DEFINE vIvaIntMora DECIMAL(14,2);
--Jom ini agregar intereses vencido
   DEFINE vinteresvencido DECIMAL(14,2); 
   DEFINE vivacredito 	  DECIMAL(14,2); 
   DEFINE vinteresmes 	  DECIMAL(14,2); 
--   DEFINE vivames decimal(14,2);
   DEFINE vstatuscred CHAR (02);
--Jom fin agregar intereses vencido


   LET vcodret    = "00000";
   LET vtransacc  = " ";
   LET vfecha     = " ";
   LET vmonto     = 0;
   LET vSucursal  = 0;
   LET vPorcIva   = 0;
   LET vSdoDeudor = 0;
   LET vPagoMin   = 0;
   LET vFechaCorte = " ";
   LET vFechaPago  = " ";
   LET vIntMora    = 0;
   LET vIvaIntMora = 0;
   LET vciclo      = 0;
   LET vultmovto   = 5;
--Jom ini agregar intereses vencido
   LET vinteresvencido = 0;
   LET vivacredito = 0;
   LET vinteresmes = 0;
--    LET vivames = 0;
   LET vstatuscred = '';
--Jom fin agregar intereses vencido

							   
						   

												 
							
						

											
			

   BEGIN
      ON EXCEPTION SET vsqlerr
         IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vfecha,vtransacc,vmonto,vPagoMin,vSdoDeudor,vIntMora,vIvaIntMora;
         END IF
      END EXCEPTION;

	   SET ISOLATION TO DIRTY READ;
	   SET LOCK MODE TO WAIT 5;
   
        SELECT  b.sucursal
        INTO  vSucursal
        FROM sd_maecred b
        WHERE b.empresa = pempresa
          AND b.num_credito = pcuenta;
        
        SELECT iva
        INTO vPorcIva
        FROM bdinteg:si_sucursales 
        WHERE empresa = pempresa 
	      AND sucursal = vSucursal;

        IF vPorcIva IS NULL THEN
            LET vPorcIva=0;
        END IF;

		IF ( psecuencia = 10 ) THEN
			LET vultmovto = psecuencia;
		END IF;						 
		
		SELECT a.sdo_cap_insoluto, a.monto_financiado, TO_CHAR(c.fecha_hoy,"20-%m-%Y"), TO_CHAR(b.prox_fecha_pago, "%d-%m-%Y"), status_cred, int_tra_no_exig Interes_vencido,
						 
									  
											 
					   
										  
          nvl((SELECT SUM(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status in ('2','7','6')),0) iva_interes,
          nvl((SELECT SUM(interes_debe - interes_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status = '1'),0) interes_mes 
																																												  
        INTO vSdoDeudor, vPagoMin, vFechaCorte, vFechaPago, vstatuscred, vinteresvencido, vivacredito, vinteresmes
				   
														  
        FROM sd_maesdos a, sd_maecredanexo b, sd_fechas c, sd_maecred d
        WHERE a.empresa = pempresa
 	     AND a.num_credito= pcuenta
         AND b.empresa = a.empresa
	     AND b.num_credito = a.num_credito
         AND d.empresa = a.empresa
	     AND d.num_credito = a.num_credito
	     AND c.empresa = a.empresa;
		 
      IF vSdoDeudor IS NULL THEN
         LET vSdoDeudor = 0;
         LET vPagoMin = 0;
         LET vcodret = "00100";
         RETURN vcodret,vfecha,vtransacc,vmonto,vPagoMin,vSdoDeudor,vIntMora,vIvaIntMora;
      END IF;

---  credito cancelado
     if ( vstatuscred = 'FF' ) then
         LET vcodret = "00279";
         RETURN vcodret,vfecha,vtransacc,0,0,0,0,0;
     end if;
	 

     --if ( vstatuscred = 'BT' ) then
	 if vstatuscred in ( 'BT','E2','E3') then         
	     let vPagoMin = vPagoMin + vinteresvencido + vivacredito;
         let vSdoDeudor = vSdoDeudor + vinteresvencido + vivacredito;

         if ( vinteresvencido > 0 ) then
            let vPagoMin = vPagoMin - vinteresmes;
            let vSdoDeudor = vSdoDeudor - vinteresmes;
         end if;
     end if;     
	  


      -- Extrae los ultimos 5 movimientos
      FOREACH
         SELECT {+ INDEX (sd_transfun idx_sd_transfun_codigos)} fecha_mov, secuencia, monto,
                transacc||" "||TRIM(b.descripcion),naturaleza
           INTO vfecha,vserial,vmonto,vtransacc,vnaturaleza
           FROM sd_movdia a , bdinteg:si_transacc b, sd_transfun c
							 
	       WHERE a.num_credito = pcuenta
							  
									  
									  
																			
								  
							  
							  
						 
								
							 
												
  
											
															 
														   
																  
									  
										
            AND a.codigo_fun = c.codigo_fun
            AND a.codigo_ref = c.codigo_ref
            AND a.reversado = "N"
            AND c.empresa = a.empresa
--            AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
            AND a.fecha_mov >= date(0)
            AND b.sistema = "06"
            AND b.empresa = c.empresa
            AND b.numero = c.transacc
            AND b.se_emite_edocta = "S"
          ORDER BY fecha_mov desc,secuencia desc

         LET vciclo = vciclo+1;
         IF vciclo >  vultmovto THEN
            EXIT FOREACH;
         END IF
         IF vnaturaleza = "C" THEN
            LET vmonto = (vmonto*(-1));
         END IF
         -- El Pago Minimo Negativo representa un saldo a Favor MEL 
         -- 14 de Agosto 2007 
         IF vPagoMin < 0 THEN
            LET vPagoMin = 0;
         END IF

-- Se deja intencionalmnte la suma del mora_sdo_ordi al copete poe estar incorrecto en el principal
-- Se deja intencionalmnte la suma del mora_sdo_ordi al copete poe estar incorrecto en el principal

         SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) + Sum(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag))
         INTO vIntMora
         FROM sd_amortiza_credito
         WHERE  empresa = pempresa
         AND num_credito = pcuenta
         AND capital_status IN ("2","7","6");
    --     AND (mora_sdo_ordi - mora_sdo_ordi_pag) + (mora_sdo_cope - mora_sdo_cope_pag) > 0 ;

		IF  vIntMora IS NULL OR  vIntMora < 0 THEN
			LET vIntMora = 0;
		END IF;

         SELECT SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * vPorcIva)-mora_iva_pagado)
         INTO vIvaIntMora
         FROM sd_amortiza_credito
         WHERE  num_credito = pcuenta
         AND empresa = pempresa
         AND capital_status IN ("2","7","6")
         AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * vPorcIva)) > 0;

         IF  vIvaIntMora  IS NULL OR  vIvaIntMora < 0 THEN
                LET vIvaIntMora = 0;
         END IF;

         LET vSdoDeudor = vSdoDeudor + vIntMora + vIvaIntMora;

         RETURN vcodret,vfecha,vtransacc,vmonto,vPagoMin,vSdoDeudor,vIntMora,vIvaIntMora
                WITH RESUME;
      END FOREACH;

      -- ****************************************************************
      -- Consulta la Tabla Historica si los movimientos del mes no son  *
      -- suficientes						        *
      -- ****************************************************************
      FOREACH
		SELECT fecha_mov, secuencia, monto,
			transacc||" "||TRIM(b.descripcion),naturaleza
		INTO vfecha,vserial,vmonto,vtransacc,vnaturaleza
		FROM sd_movhis_new a , bdinteg:si_transacc b, sd_transfun c
		WHERE a.empresa = pempresa
			AND a.num_credito = pcuenta
							 
																		   
			and a.fecha_mov >= date(0)
							 
							 
							   
						
			AND a.reversado = "N"
			
										 
												  
															 
							   
							   
			AND c.empresa = a.empresa
			AND c.codigo_fun = a.codigo_fun
							  
							 
							 
							   
						
						 
										   
  
															
																					 
																		   
																					  
													
														   
														  
													 
														 
															   
			AND c.codigo_ref = a.codigo_ref
			AND b.sistema = "06"
			AND b.empresa = c.empresa
			AND b.numero = c.transacc
			AND b.se_emite_edocta = "S"

        UNION ALL
		
		SELECT fecha_mov, secuencia, monto,
			transacc||" "||TRIM(b.descripcion),naturaleza
		FROM sd_movhis a , bdinteg:si_transacc b, sd_transfun c
		WHERE a.empresa = pempresa
			AND a.num_credito = pcuenta
			AND a.codigo_fun = c.codigo_fun
			AND a.codigo_ref = c.codigo_ref
			and a.fecha_mov >= date(0)
			AND a.reversado = "N"
			AND c.empresa = a.empresa
			AND b.sistema = "06"
			AND b.empresa = c.empresa
			AND b.numero = c.transacc
			AND b.se_emite_edocta = "S"
		   ORDER BY fecha_mov desc,secuencia desc  

				   
															
																					 
																				  
													 
														   
															   
															   
														  
													 
														 
													
														 
														 
														   
														 

         LET vciclo = vciclo+1;
         IF vciclo > vultmovto THEN
            EXIT FOREACH;
         END IF
         IF vnaturaleza = "C" THEN
            LET vmonto = (vmonto*(-1));
         END IF
         -- El Pago Minimo Negativo representa un saldo a Favor MEL 
         -- 14 de Agosto 2007 
         IF vPagoMin < 0 THEN
            LET vPagoMin = 0;
         END IF

-- Se deja intencionalmnte la suma del mora_sdo_ordi al copete poe estar incorrecto en el principal
-- Se deja intencionalmnte la suma del mora_sdo_ordi al copete poe estar incorrecto en el principal

         SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) + Sum(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag))
         INTO vIntMora
         FROM sd_amortiza_credito
         WHERE  empresa = pempresa
         AND num_credito = pcuenta
         AND capital_status IN ("2","7","6");
																							  

          IF  vIntMora IS NULL OR  vIntMora < 0 THEN
                LET vIntMora = 0;
          END IF;

         SELECT SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * vPorcIva)-mora_iva_pagado)
         INTO vIvaIntMora
         FROM sd_amortiza_credito
         WHERE  num_credito = pcuenta
         AND empresa = pempresa
         AND capital_status IN ("2","7","6")
         AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * vPorcIva)) > 0;

         IF  vIvaIntMora  IS NULL OR  vIvaIntMora < 0 THEN
                LET vIvaIntMora = 0;
         END IF;

         LET vSdoDeudor = vSdoDeudor + vIntMora + vIvaIntMora;


         RETURN vcodret,vfecha,vtransacc,vmonto,vPagoMin,vSdoDeudor,vIntMora,vIvaIntMora
                WITH RESUME;
      END FOREACH;
END
END PROCEDURE;