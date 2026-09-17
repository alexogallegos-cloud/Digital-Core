CREATE PROCEDURE "informix".principalrefer(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT, 
                           p_Tarjeta                CHAR(20),
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  LIKE sd_movdia.Folio_Suc,
                           p_Transacc               LIKE sd_movdia.Transacc_Suc,
                           p_MontoSBC               MONEY(14,2),
                           p_MontoEfe               MONEY(14,2),
                           p_referencia             char(40))
  --Valores a Regresar
      RETURNING CHAR(5),     -- Codigo de Retorno
             MONEY(14,2), -- Remanente
             MONEY(14,2), -- Interes Moratorio Cobrado
             MONEY(14,2), -- Interes Vencido Cobrado
             MONEY(14,2), -- Capital Vencido Cobrado
             MONEY(14,2), -- Interes Vigente Cobrado
             MONEY(14,2), -- Capital Vigente Cobrado
             MONEY(14,2), -- Impuesto Cobrado
             MONEY(14,2), -- Comisiones Cobradas
             MONEY(14,2)  -- Seguro Cobrado

 DEFINE GLOBAL g_sistema       CHAR(2)     DEFAULT '06';

   DEFINE CodRet                CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);
   DEFINE wBegin                CHAR(1);
   DEFINE vfecha_hoy            DATE;
   
   DEFINE g_IntMoraCob   MONEY(14,2);
   DEFINE g_IntVencCob   MONEY(14,2);
   DEFINE g_CapVencCob   MONEY(14,2);
   DEFINE g_IntVigCob    MONEY(14,2);
   DEFINE g_CapVigCob    MONEY(14,2);
   DEFINE g_Impuesto     MONEY(14,2);
   DEFINE g_Comision     MONEY(14,2);
   DEFINE g_Seguro       MONEY(14,2);
   DEFINE g_Remanente    MONEY(14,2);
   DEFINE g_NumProducto   CHAR(4);
   DEFINE g_NumCte        CHAR(20);
   DEFINE v_NumCredito    CHAR(20);
   DEFINE vSdoTdc_Crds 	  		DECIMAL(14,2);	-- Cobro sdo a favor para pago PFSI
   DEFINE dFechaCreds	  		DATE;
   DEFINE cNum_Credisol	  		CHAR(20);
   DEFINE dCap_Credisol	  		DECIMAL(14,2);
   DEFINE dMntoPagoCredis 		DECIMAL(14,2);
   DEFINE cNumCredito_Crds		CHAR(20);
   DEFINE cCta_Eje_Crds        	CHAR(20);
   DEFINE cProducto_Crds       	CHAR(40);
   DEFINE cNum_Cte_Crds        	CHAR(20);
   DEFINE cNom_Cte_Crds        	CHAR(150);
   DEFINE dPago_Efec_Crds      	DECIMAL(18,2);
   DEFINE dPago_Cta_Crds       	DECIMAL(18,2);
   DEFINE dMonto_Op_Crds     	DECIMAL(18,2);
   DEFINE dSaldo_Actual_Crds   	DECIMAL(18,2);
   DEFINE cStatus_Actual_Crds  	CHAR(60);
   DEFINE dFecha_ProxPago_Crds	DATE;									  
									        

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      LET Mensaje = error_info;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
	     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      --ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

   
    --SET DEBUG FILE TO "/informix/mahr/principalrefer-"||p_Transacc||".out";     
    --TRACE ON;

   LET wBegin = "N";
   LET vSdoTdc_Crds 	= 0;
   LET dFechaCreds		= DATE(1);
   LET cNum_Credisol 	= '';
   LET dCap_Credisol 	= 0;   
   LET dMntoPagoCredis	= 0;
   
   LET cNumCredito_Crds		= '';
   LET cCta_Eje_Crds        = '';
   LET cProducto_Crds       = '';
   LET cNum_Cte_Crds        = '';
   LET cNom_Cte_Crds        = '';
   LET dPago_Efec_Crds      = 0;
   LET dPago_Cta_Crds       = 0;
   LET dMonto_Op_Crds     	= 0;
   LET dSaldo_Actual_Crds   = 0;
   LET cStatus_Actual_Crds  = '';
   LET dFecha_ProxPago_Crds	= DATE(1);

   BEGIN WORK;

   LET CodRet = "000";
   LET v_NumCredito = "";
   LET vfecha_hoy = "";
   LET g_Seguro =0;
   
   SELECT descripcion
     INTO Mensaje
     FROM bdinteg:"informix".si_codret
    WHERE sistema = g_sistema
      AND codigo_retorno = CodRet;
	  
   SELECT fecha_hoy INTO vfecha_hoy FROM "informix".sd_fechas;

   LET p_Empresa     = p_Empresa;
   LET g_Remanente   = 0;
   LET g_IntMoraCob  = 0;
   LET g_IntVencCob  = 0;
   LET g_CapVencCob  = 0;
   LET g_IntVigCob   = 0;
   LET g_CapVigCob   = 0;
   LET g_Impuesto    = 0;
   LET g_Comision    = 0;
   LET g_Seguro      = 0;   
   LET nRows         = 0;
   
   --**Se selecciona el producto
   IF length(p_NumCredito) = 16 THEN
      LET p_Tarjeta = p_NumCredito;

      SELECT num_credito 
        INTO v_NumCredito
        FROM "informix".sd_tarjeta
       WHERE num_tarjeta = p_NumCredito
         AND empresa     = p_Empresa; 
   ELSE
      LET v_NumCredito = p_NumCredito;
   END IF

   --Pago de TDC por Efectivo
    IF p_MontoEfe < 1 and p_Transacc = '0600' THEN
		if p_MontoEfe > 0 THEN 
			let CodRet = '399';
		ELSE
			let CodRet = '284';
		END IF;
    ELSE
      if p_MontoEfe > 0 then
            CALL "informix".Principal(
                p_Empresa,
                v_NumCredito,
                p_TpPago,
                p_MontoEfe,
                p_Usuario,
                p_Sucursal,
                p_Folio,
                p_Transacc
            )
            returning CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
                   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;

            IF (CodRet <> "000") THEN
                SELECT descripcion
                INTO   Mensaje
                FROM   bdinteg:"informix".si_codret
                WHERE  sistema        = "06"
                AND    codigo_retorno = CodRet;
                ROLLBACK WORK;
                IF (wBegin = "S") THEN
                   BEGIN WORK;
                END IF;
            ELSE
				if ( p_Transacc = '8324') then  --Se graba clave de rastreo para movimientos de credito SPEI
                    UPDATE "informix".sd_movdia
                       SET referencia = p_referencia
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                elif ( p_Transacc = '6246') then  -- Graba referencia saldo buen cobro            
                    UPDATE "informix".sd_movdia
                       SET referencia23 = p_referencia,
                           nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                else
                    UPDATE "informix".sd_movdia
                       SET nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                end if;
				
				-- Pago de TDC termina correctamente. Realiza el cobro del saldo a favor si existe un PFSI activo (Sdo Inmediato - Apoyo 2020)
				SELECT sdo_cap_insoluto INTO vSdoTdc_Crds FROM bdicred:"informix".sd_maesdos WHERE empresa = p_Empresa AND num_credito = v_NumCredito;
				
				--IF vSdoTdc_Crds < -1 AND p_Transacc = '0600' THEN -- Solo entre cuando venga de pago tdc
				IF vSdoTdc_Crds < -1 THEN -- Solo entre cuando venga de pago tdc

					SELECT count(num_credito) INTO nRows FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
					IF nRows > 0 THEN	-- Existe credisolucion vigente relacionado a la TDC
				  
						SELECT max(fecha) INTO dFechaCreds FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
						SELECT num_sol_prestamo INTO cNum_Credisol FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND fecha = dFechaCreds AND tipo_contrato = '3' AND status = 2;
						SELECT nvl(sdo_cap_insoluto,0) INTO dCap_Credisol FROM bdicred:sd_maesdoscrd WHERE num_credito = cNum_Credisol;
						
						IF dCap_Credisol > 1 THEN	-- Aun se tiene deuda del credito 6900 y no vuelva a entrar en la 2da ejecucion del principalrefer 	
							IF abs(vSdoTdc_Crds) < dCap_Credisol THEN	-- El saldo excedente es menor que el monto de la deuda total del credito 6900. El excedente solo cubre parte del monto de deuda 6900
								LET dMntoPagoCredis = abs(vSdoTdc_Crds);
							ELSE										-- Parte del excedente cubre la deuda total del credito 6900
								LET dMntoPagoCredis = dCap_Credisol;
							END IF;
							
							-- Elimina el pago previo para casos iterativos y asÃÂ­ no sume el monto de ambos pagos a cargar a la tdc.
							SELECT count(folio) INTO nRows FROM bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
							IF nRows > 0 THEN
								DELETE bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
								LET nRows = 0;
							END IF;

							--EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '618')
							BEGIN WORK;
							EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '8654')
							   INTO CodRet, Mensaje, cNumCredito_Crds, cCta_Eje_Crds, cProducto_Crds, cNum_Cte_Crds, cNom_Cte_Crds, dPago_Efec_Crds, dPago_Cta_Crds, 
									  dMonto_Op_Crds, dSaldo_Actual_Crds, cStatus_Actual_Crds, dFecha_ProxPago_Crds;
							IF CodRet::SMALLINT = 0 THEN
								-- Se actualiza remanente
								LET g_Remanente = g_Remanente;
								LET CodRet = "000";
							END IF;										
							
						END IF;
					END IF;  
					LET nRows = 0;
				END IF;    
				
           END IF
      END IF
	END IF;
/*
--jom ini
   else
	if p_MontoEfe > 0 THEN 
	        let CodRet = '399';
	ELSE
		let CodRet = '284';
	end if;
--jom fin
   END IF;
*/
   --Pago de TDC por Cheque
   IF p_MontoSBC > 0 THEN
   	--realiza la grabacion del Movimiento

      SELECT num_producto
        INTO g_NumProducto
        FROM "informix".sd_maecred
       WHERE empresa     = p_Empresa
         AND num_credito = v_NumCredito
		 AND status_cred      not in ('CV','FC','FF','FI')	
         AND (id_unidad_prod is null or id_unidad_prod <> 1);
		      
	 --2012-09-18 se valida que el credino no este marcado para venta en pago SBC.
	LET nrows = dbinfo("sqlca.sqlerrd2");
   IF (nrows = 0) THEN   
       LET CodRet = "008";     
    ELSE
	
		CALL "informix".Genmovref(
		p_Empresa,
		v_NumCredito,
		g_NumProducto,
		p_MontoSBC,
		p_Folio ,
		p_Sucursal,
        p_Tarjeta,
		p_referencia)

		RETURNing CodRet;
		
    END IF;          	
	
      
  	IF (CodRet <> "000") THEN
   	    SELECT descripcion
            INTO   Mensaje
       	    FROM   bdinteg:"informix".si_codret
       	    WHERE  sistema        = "06"
             AND   codigo_retorno = CodRet;
       	     ROLLBACK WORK;
       	     IF (wBegin = "S") THEN
                 BEGIN WORK;
       	     END IF;
        END IF
   END IF;

   RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
END PROCEDURE;