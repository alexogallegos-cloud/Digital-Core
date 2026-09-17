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