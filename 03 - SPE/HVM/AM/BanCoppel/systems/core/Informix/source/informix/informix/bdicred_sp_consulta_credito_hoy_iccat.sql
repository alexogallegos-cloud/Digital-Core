CREATE PROCEDURE "informix".sp_consulta_credito_hoy_iccat(pEmpresa char (3), pNumCred char(12), pFecha date)
	returning char(5), DECIMAL(14,2), DECIMAL(14,2), DECIMAL(14,2), DECIMAL(14,2), 
				DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2);
   -----------------------------------------------------------------------
   --Elaboró: Ramon Octavio Romero Mascareño							--
   --Actividad: consulta estado de cuenta de credito al dia de hoy		--
   --Solicito: Mauricio León											--
   --Fecha: 14/05/09													--
   -----------------------------------------------------------------------
   --DEFINE
    DEFINE cod_ret 				char(5);
    DEFINE sql_err 				integer;
	DEFINE vCapital 			DECIMAL(14,2);
	DEFINE vCapitalVen 			DECIMAL(14,2);
	DEFINE vInteresesVen 		DECIMAL(14,2);
	DEFINE vIvaInteresesVen 	DECIMAL(14,2);
	DEFINE vIntMoratorios 		DECIMAL(14,2);
	DEFINE vIvaIntMoratorios 	DECIMAL(14,2);
	DEFINE vPagoNoIntereses 	DECIMAL(14,2);
	DEFINE vPagoMinimo 			DECIMAL(14,2);
	DEFINE vSaldoHoy 			DECIMAL(14,2);
	--temporales
	DEFINE vIvaDebe 			DECIMAL(14,2);
	DEFINE vFechaCouta 			DECIMAL(14,2);
	DEFINE vCapitalStatus 		DECIMAL(14,2);
	DEFINE vInteresesVenTem		DECIMAL(14,2);
	DEFINE vSdoMora				DECIMAL(14,2);
	
	--Inicializa
	LET cod_ret 				= '000';
	LET vCapital 				= 0;
	LET vCapitalVen 			= 0;
	LET vInteresesVen 			= 0;
	LET vIvaInteresesVen 		= 0;
	LET vIntMoratorios 			= 0;
	LET vIvaIntMoratorios 		= 0;
	LET vPagoNoIntereses 		= 0;
	LET vPagoMinimo 			= 0;
	LET vSaldoHoy 				= 0;
	--temporales
	LET vIvaDebe 				= 0;
	LET vFechaCouta 			= 0;
	LET vCapitalStatus 			= 0;
	LET vInteresesVenTem		= 0;
	LET vSdoMora				= 0;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vCapital, vCapitalVen ,vInteresesVen ,vIvaInteresesVen ,vIntMoratorios ,vIvaIntMoratorios ,vPagoNoIntereses ,vPagoMinimo ,vSaldoHoy;
      END IF ;
   END EXCEPTION ;

   if pNumCred == '' then
	let cod_ret = '001';
   end if
	   
    SET ISOLATION DIRTY READ ;

		select sdo_capital, (monto_vencido + mto_venc_trasp), int_tra_no_exig, (sdo_moratorio + sdo_contab_mora), sdo_cap_insoluto
		into vCapital, vCapitalVen, vInteresesVen, vIntMoratorios, vPagoNoIntereses
		from sd_maesdos
		where empresa = pEmpresa and num_credito = pNumCred;

		select (iva_debe - iva_pagado), capital_status 
		into vIvaInteresesVen, vCapitalStatus
		from sd_amortiza_credito
		where empresa = pEmpresa and num_credito = pNumCred and fecha_cuota = pFecha;
		
		if vCapitalStatus <> 2 and vCapitalStatus <> 7 and vCapitalStatus <> 6 then
			let vIvaInteresesVen = 0;
		end if
		
		let vIvaIntMoratorios = (vIntMoratorios * .15);
	
   RETURN cod_ret, vCapital, vCapitalVen ,vInteresesVen ,vIvaInteresesVen ,vIntMoratorios ,vIvaIntMoratorios ,vPagoNoIntereses ,vPagoMinimo ,vSaldoHoy;
END

END PROCEDURE;