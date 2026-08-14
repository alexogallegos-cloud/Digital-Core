CREATE PROCEDURE "informix".sp_reg_convenio_eval_objetiva_crd(pEmpresa char(3), pFecha date)

RETURNING CHAR(6), char(80);
  -- vers 1.0.0 20190515
  define vcEsTransaccion  CHAR(1);
  define vDataErr	      varchar(64);
  define iSqlErr	      integer;
  define iSamErr	      integer;
  define cCodRet	      char(6);
  define dtFecha	      date;
  define cMensaje         char(80);
  define iCantidad        integer;
  define vEmpresa         char(3);
  define vFechahoy        date;
  define vFechaDiaAnt     date;
  define cNumCte          char(20);	 
  define cProceso         char(4);
  define cCod_ret_2       char(6);	 
  define cNumCte_movs     char(20);
  define iContGral        integer;
  define iContGral_2      integer;
  define vNum_credito     char(20);
  define dImporteConvenio decimal(18,2);
  define dSuma_importe    decimal(18,2);
  define dSuma_importe_2  decimal(18,2);
  define dSuma_importe_his decimal(18,2);
  define dSuma_importe_total decimal(18,2);
  define dtHora_insert    DATETIME HOUR to FRACTION(3);
  define dtFecha_convenio date;
  define cSucursal_pago   char(4);
  define cSucursal_pago_2 char(4);
  define vNum_credito_2   char(20);
  define iNum_pm_realizados    integer;
  define iNum_pm_no_realizados integer;
  define cCalificacion         char(1);
  define dTotal_importe        decimal(18,2);
  define dImp_pagado_acum      decimal(18,2); 
  
  define vPlazo           char(2);
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
  define cCalificado      char(1);
  define cUsuario_pago    char(8);
  define cNomUsuario_pago char(45);
  define dFecha_vencim    date;
  define dFecha_compac_guardado DATE;
  define dFecha_insert_guardado DATE;
  
  let vcEsTransaccion   = '';
  let cCodRet	        = "000000";
  let dtFecha           = date(1);
  let cMensaje          = 'PROCESO EXITOSO';	  
  let iCantidad         = 0;
  let vEmpresa          = '001';
  let vFechahoy         = date(1);
  let vFechaDiaAnt      = date(1);
  let cNumCte           = '';
  let cProceso          = '0083';
  let cCod_ret_2        = '';
  let cNumCte_movs      = '';
  let iContGral         = 0;
  let iContGral_2       = 0;
  let vNum_credito      = '';
  let dImporteConvenio  = 0;
  let dSuma_importe     = 0;
  let dSuma_importe_2   = 0;
  let dSuma_importe_his = 0;
  let dSuma_importe_total = 0; 
  let dtHora_insert     = CURRENT;
  let dtFecha_convenio  = date(1);
  let cSucursal_pago    = ''; 
  let cSucursal_pago_2  = '';
  let vNum_credito_2    = '';
  let iNum_pm_realizados = 0;
  let iNum_pm_no_realizados = 0;
  let cCalificacion      = '';
  let dTotal_importe     = 0;

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
  let vPlazo           = '';
  let dImp_pagado_acum = 0;
  let cCalificado   = '';
  let cUsuario_pago = '';
  let cNomUsuario_pago = '';
  let dFecha_vencim = date(1);
  let dFecha_compac_guardado = date(1);
  let dFecha_insert_guardado = date(1);
  
BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensaje = trim(cCodRet) || ' ' || vNum_credito;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_reg_convenio_eval_objetiva_crd.trc";
	--TRACE ON;

	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	CALL bdicobranza:sp_inserta_bitacora_cob_2(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	

	IF pEmpresa IS NULL OR pEmpresa = "" THEN
		LET cCodRet = '000001';
		LET iSqlErr = '000001';
		LET cMensaje = 'FALTA PARAMETRO EMPRESA';
	ELIF pFecha IS NULL OR pFecha = "" THEN
	
		SELECT fecha_hoy
		  INTO vFechaHoy
		  FROM bdinteg:si_fechas
		 WHERE empresa = pEmpresa;
	ELSE
		LET vFechaHoy = pFecha;
				
	END IF;

		--LET vFechaHoy = mdy(3,20,2020);  -- SOLO TEST MACF
		
		IF cCodRet = '000000' THEN
	--        BEGIN WORK;
			LET vcEsTransaccion = 'S';
	
	
			--- OBTENER EL UNIVERSO A PROCESAR
			FOREACH WITH HOLD
			   --Barrer cb_compac con los convenios activos exitentes cuya fecha es menor al día actual	
				SELECT {+INDEX(bdicobranza:cb_compac idx_compac3)} 
					   a.sucursal, a.numcuenta, a.importe, a.fecha_compac, a.plazo, a.hora_insert, a.efectuo_compac, a.nombre_efectuo,
					   a.origen, a.tipo_compac, b.num_producto, b.sucursal, ( a.fecha_compac + ( a.plazo * 7 ) )
				  INTO psucursal, vNum_credito, dImporteConvenio, dtFecha_convenio, vPlazo, dtHora_insert, pefectuo_compac, pnombre_efectuo, 
					   porigen, ptipo_compac, pnumproducto, pSucursalOrig, dFecha_vencim
				  FROM bdicobranza:cb_compac a
						INNER JOIN bdicred:sd_maecredcrd b ON (b.empresa = a.empresa AND b.num_credito = a.numcuenta AND b.num_producto IN('6011', '6300', '7600', '7700','6400','6800'))	
				 WHERE a.empresa = vEmpresa 
				   AND ( vFechahoy + ( a.plazo * 7 ) ) >= a.fecha_compac
				   AND a.activo = 1   
				   AND a.numcuenta not in( select num_credito from bdicobranza:cb_evaluacion_objetiva_convenios_crd where fecha_insert = vFechahoy)

				let dImporteConvenio = nvl(dImporteConvenio,0);
				
				SELECT count(*) INTO iCteAsisteSuc
				  FROM bdicobranza:cb_compac_bit_realiza 
				 WHERE empresa = vEmpresa 
				   --AND numcliente = pnumcliente 
				   AND numcuenta = vNum_credito
				 --AND fh_movimiento BETWEEN  dtFechaIni AND dtFechaFin
				 --AND fh_movimiento  between TO_DATE(dtFechaIni, "%Y/%m/%d") AND TO_DATE(dtFechaFin, "%Y/%m/%d")  
				   AND fh_movimiento =  vFechahoy;  --dtFecha_convenio -- TO_DATE(vFechahoy, "%Y/%m/%d")
				 
				let iCteAsisteSuc = nvl(iCteAsisteSuc,0);				
				
				if porigen = 1 then 
				   let cOrigen = 'TIENDA'; 
				elif porigen = 2 then  
				   let cOrigen = 'SUCURSAL';
				elif porigen = 3 then     
				   let cOrigen = 'CAT';
				end if;		   
				
				-- Si hubo un pago antes de la hora del convenio (es pago valido)  --no tomar en cuenta
				-- Se busca pago que haya hecho a cualquier hora, pq el convenio a evaluar es de ayer hacia atrás
				SELECT SUM(monto) --, sucursal
				  INTO dSuma_importe --, cSucursal_pago 
				  FROM bdicred:sd_movdiacrd    --- solo pruebas  sd_movhiscrd
				 WHERE empresa = vEmpresa AND num_credito = vNum_credito
				   AND fecha_mov = vFechahoy
				   AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd where num_producto = pnumproducto)
				   AND codigo_ref = 1
				   AND reversado = 'N';


				   
				--IF (dSuma_importe is null) THEN
				--	LET dSuma_importe = 0;
				--END IF;
				let dSuma_importe = nvl(dSuma_importe,0);
				
				--Debido al error que puede surgir si tiene dos pagos, puede ser que en un query sacar solo el pago
				--Y en otro sacar la sucursal donde la hora_mov sea la minima, osea el primero que entró
				SELECT LIMIT 1 sucursal, usuario into cSucursal_pago, cUsuario_pago
				  FROM bdicred:sd_movdiacrd            --- SOLO PRUEBA sd_movhiscrd
				 WHERE empresa = '001' AND num_credito =  vNum_credito 
				   AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd where num_producto = pnumproducto)
				   AND codigo_ref = 1
				   AND fecha_mov = vFechahoy                   
				   AND reversado = 'N'
				   AND hora_mov = (SELECT min(hora_mov)
									 FROM bdicred:sd_movdiacrd            --- SOLO PRUEBA sd_movhiscrd
									WHERE empresa = '001' AND num_credito =  vNum_credito 
									  AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd where num_producto = pnumproducto)
									  AND codigo_ref = 1
									  AND fecha_mov = vFechahoy 
									  AND reversado = 'N');
				
				let cSucursal_pago = nvl(cSucursal_pago,'');  
			  
				select nombre into cNomUsuario_pago
				  from bdinteg:si_ejecut
				 where ejecutivo = cUsuario_pago; 
			  
			   ---validar si existe cuenta, si existe se actualiza, si no se inserta
			   -- PENDIENTE agregar que no tome los convenios que ya fueron procesados: and fecha_insert <> vFechahoy
			   select num_credito, convenio_abono, nvl(calificacion,'0'), fecha_insert, fecha_compac
 			     into vNum_credito_2, dImp_pagado_acum, cCalificado, dFecha_insert_guardado, dFecha_compac_guardado
				 from bdicobranza:cb_evaluacion_objetiva_convenios_crd
				where num_credito =  vNum_credito
				  and fecha_compac = dtFecha_convenio; 
			   
			   let vNum_credito_2 = nvl(vNum_credito_2,'');
			   let dImp_pagado_acum = nvl(dImp_pagado_acum,0);
			   
			   
			   IF dSuma_importe > 0 THEN    --NOTA: considerar si también la condición: y que cCalificado = '0'
					--if dtFecha_convenio = vFechahoy then --and (dSuma_importe >= dImporteConvenio) then
					--   let iNum_pm_realizados = 0;	
					--   let iNum_pm_no_realizados = 1; 
					--   let cCalificacion = '0'; 
					--if dtFecha_convenio <> vFechahoy  and dFecha_vencim >= vFechahoy then
					if dFecha_vencim >= vFechahoy then
					   if nvl(vNum_credito_2,'') <> '' and (dSuma_importe + dImp_pagado_acum >= dImporteConvenio) THEN
						  let iNum_pm_realizados = 1;	
						  let iNum_pm_no_realizados = 0; 
						  let cCalificacion = '1';
					   elif nvl(vNum_credito_2,'') <> '' and (dSuma_importe + dImp_pagado_acum < dImporteConvenio) THEN
						  let iNum_pm_realizados = 0;	
						  let iNum_pm_no_realizados = 1; 
						  let cCalificacion = '0';
					   elif nvl(vNum_credito_2,'') = '' then
						  if dSuma_importe >= dImporteConvenio then
							 let iNum_pm_realizados = 1;	
							 let iNum_pm_no_realizados = 0; 
							 let cCalificacion = '1';
						  else
							 let iNum_pm_realizados = 0;
							 let iNum_pm_no_realizados = 1; 
							 let cCalificacion = '0';
						  end if;   
					   end if;  
				    --end if;
			   
			  
						let dTotal_importe = dSuma_importe;
				   
						--IF nvl(vNum_credito_2,'') <> '' and nvl(cNomUsuario_pago,'') <> '' and cCalificado <> '1' THEN
						IF nvl(vNum_credito_2,'') <> '' THEN
						
							--2020-01-17 Si cuando se generó el convenio se pagó(si fecha_compac = fecha_insert) ya no se debe actualizar el registro, solo si son diferentes
							IF dFecha_compac_guardado <> dFecha_insert_guardado THEN

							-- No es posible hacer un pago el mismo día con el mismo monto conveniado. (corregir)
							-- Se toma el pago pero se registra como calificacion cero
									begin;
										UPDATE bdicobranza:cb_evaluacion_objetiva_convenios_crd  
										SET sucursal_pago 		 = cSucursal_pago,
											--cajero               = cUsuario_pago, debe ser quien realiza el convenio, se afecta cuando se inserta solamente
											nom_cajero           = cNomUsuario_pago,
											convenio_abono 		 = NVL(convenio_abono,0) + dTotal_importe,
											cte_con_vencido    = NVL(cte_con_vencido,0) + iCteAsisteSuc,
											--num_convenios      = NVL(num_convenios,0) + 1,
											num_pm_realizados 	 = NVL(num_pm_realizados,0) + iNum_pm_realizados,
											num_pm_no_realizados = NVL(num_pm_no_realizados,0) + iNum_pm_no_realizados,
											calificacion 		 = cCalificacion,
											fecha_insert         = vFechahoy
										WHERE num_credito = vNum_credito_2
										   AND fecha_compac = dtFecha_convenio;  
									commit;
									let iContGral = iContGral + 1;
							END IF;	
						--ELIF nvl(vNum_credito_2,'') = '' and nvl(cNomUsuario_pago,'') <> '' THEN 
						ELIF nvl(vNum_credito_2,'') = '' THEN 

						     if (dtFecha_convenio = vFechahoy) then
							     -- Si se hace un pago el mismo día del convenio será no cumplido.
								 begin;
								   INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_crd(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, 
										  cajero, nom_cajero, num_producto, plazo, origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
										  num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
																								 
								   --VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, vFechahoy, cUsuario_pago, cNomUsuario_pago,  pnumproducto, vPlazo, cOrigen, ptipo_compac, 
								   VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, vFechahoy, pefectuo_compac, cNomUsuario_pago,  pnumproducto, vPlazo, cOrigen, ptipo_compac, 
										   dImporteConvenio, dTotal_importe, iCteAsisteSuc, 1, 0, 0, '0', dtFecha_convenio,dFecha_vencim);
								  commit;
						  
						     else
								  begin;
								   INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_crd(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, 
										  cajero, nom_cajero, num_producto, plazo, origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
										  num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
																								 
								   --VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, vFechahoy, cUsuario_pago, cNomUsuario_pago,  pnumproducto, vPlazo, cOrigen, ptipo_compac, 
								   VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, vFechahoy, pefectuo_compac, cNomUsuario_pago,  pnumproducto, vPlazo, cOrigen, ptipo_compac, 
										   dImporteConvenio, dTotal_importe, iCteAsisteSuc, 1, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, dtFecha_convenio,dFecha_vencim);
								  commit;
                            end if;  						  
							let iContGral_2 = iContGral_2 + 1;
						/*ELIF nvl(vNum_credito_2,'') = '' and nvl(cNomUsuario_pago,'') = '' THEN  -- Validación de más 2020-01-17
                          begin;  
                           INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_crd(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, cajero, nom_cajero, 
																						num_producto, plazo, origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
																						num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
																						 
						   VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, vFechahoy, pefectuo_compac, cNomUsuario_pago,  pnumproducto, vPlazo, cOrigen, ptipo_compac, 
								   dImporteConvenio, 0, iCteAsisteSuc, 1, 0, 0, '0', dtFecha_convenio,dFecha_vencim);
						  commit;
						  let iContGral_2 = iContGral_2 + 1;*/
						
						END IF;
					END IF;
					
				ELIF iCteAsisteSuc > 0 AND nvl(vNum_credito_2,'') <> '' THEN
				    begin;
				        UPDATE bdicobranza:cb_evaluacion_objetiva_convenios_crd  
						 SET cte_con_vencido = NVL(cte_con_vencido,0) + iCteAsisteSuc
							 --fecha_insert    = vFechahoy
						WHERE num_credito = vNum_credito_2
						  AND fecha_compac = dtFecha_convenio;  
					commit;	
					
				ELIF nvl(vNum_credito_2,'') = '' THEN	
					begin;
					   INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_crd(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, 
								  cajero, nom_cajero, num_producto, plazo, origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
								  num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
																							 
					   --VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, vFechahoy, pefectuo_compac, cNomUsuario_pago,  pnumproducto, vPlazo, cOrigen, ptipo_compac, 
					   VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal,'01/01/1900', pefectuo_compac, cNomUsuario_pago,  pnumproducto, vPlazo, cOrigen, ptipo_compac,
							   dImporteConvenio, dTotal_importe, iCteAsisteSuc, 1, 0, 0, '0', dtFecha_convenio,dFecha_vencim);
					commit;
					let iContGral_2 = iContGral_2 + 1;
				END IF;
				
				--- LIMPIAR VARIABLES
				LET iCteAsisteSuc = 0;
 				let cCalificacion = '0';
				let vNum_credito_2 = '';
				let dTotal_importe = 0;
				
			END FOREACH
	
		END IF;
	    LET vcEsTransaccion = 'N';
  
	

    --let cContGral = iContGral;
 LET cMensaje = trim(cMensaje) || '. ' || iContGral || ' UPDs - ' || iContGral_2 || ' Inserts.' ;
 CALL bdicobranza:sp_inserta_bitacora_cob_2(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2;  
 --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
 	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
	END
END PROCEDURE;