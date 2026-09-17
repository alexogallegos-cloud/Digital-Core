CREATE PROCEDURE "informix".sp_consulta_saldocortemin(pEmpresa  CHAR (3),pNumCredito CHAR (20), pTipoConsulta SMALLINT)
  RETURNING CHAR (5) AS CodRet, DECIMAL (14,2) AS saldototal;

--pTipoConsulta   0 = Pago para no generar intereses actualizado con pagos
--                1 = Saldo al Cierre
--                2 = Pago para no generar intereses
--                3 = pago minimo al corte
--                4 = pago minimo al corte actualizado con pagos
--FMJ Febrero 2012
  
 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE vSaldoTotal DECIMAL (14,2);
DEFINE vPagoMinimo DECIMAL (14,2);
DEFINE vInteresdebe DECIMAL (14,2);
DEFINE vIvadebe DECIMAL (14,2);

DEFINE iDia_corte 	 INTEGER;
DEFINE vRevolvente	 SMALLINT;
DEFINE dFechaCorte	 DATE;
DEFINE dFechaMesiver DATE;
DEFINE dFechaCentral DATE;
DEFINE vPagosHist    DECIMAL (14,2);
DEFINE vPagosAct     DECIMAL (14,2);

LET sSqlErr = 0;
LET cCodRet = '00000';

LEt iDia_corte = 0;
LET vRevolvente =0;
LET vSaldoTotal = 0;
LET vPagoMinimo = 0;
LET vInteresdebe = 0;
LET vIvadebe  = 0;
LET dFechaCentral =date(1); 
LET dFechaMesiver =date(1); 
LET dFechaCorte = date(1); 
LET vPagosHist  = 0;
LET vPagosAct   = 0;


BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, vSaldoTotal;
        END EXCEPTION;

	set lock mode to wait 3;
	set isolation to dirty read;

	SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy
  	  INTO dFechaCentral
      FROM bdicred:sd_fechas
     WHERE empresa = pEmpresa;

	SELECT dia_corte  INTO iDia_corte  
	  FROM bdicred:sd_maecredanexo     
	 WHERE empresa = pEmpresa  AND num_credito = pNumCredito;		

	LET iDia_corte = nvl(iDia_corte,0);
	 
	if iDia_corte <> 0 then   	
	  Let vRevolvente = 1;	
	  if day(dFechaCentral) <= iDia_corte then
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral)) - 1 units month;
		else
			let dFechaCorte = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral));
		end if;	  
    else     
		Let vRevolvente = 0;

        SELECT nvl(dia_corte,0)  INTO iDia_corte  
          FROM bdicred:sd_maecredanexocrd     
         WHERE empresa = pEmpresa  
           AND num_credito = pNumCredito;	
	LET iDia_corte = nvl(iDia_corte,0);

        EXECUTE PROCEDURE "informix".sp_fecha_plazo(pEmpresa,iDia_corte)
        into cCodRet, dFechaMesiver, dFechaCorte;

        if (cCodRet <> '00000') then
          let cCodRet = '00002';  -- ERROR EN RUTINA DE CALCULO DE MESIVERSARIO
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 
       end if;

	end if;	
		
	If  ( iDia_corte =0) and (nvl(dFechaCorte,date(1)) =date(1)) then   
          let cCodRet = '00001';  -- CREDITO NO EXISTE
          let vSaldoTotal = 0; 
		  let vRevolvente = 2; 	
    end if;
	
	If (vRevolvente = 1) Then

        select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0)
          into vInteresdebe, vIvadebe
          from bdicred:sd_amortiza_credito
         where empresa     = pEmpresa
           and num_credito = pNumCredito
           and capital_status  IN ('2','6');

     	select nvl(( case when (nvl(sdo_cap_insoluto,0) < 0) 
                          then decode( pTipoConsulta,1, nvl(sdo_cap_insoluto,0),0)  
		                  else  Nvl(sdo_cap_insoluto,0) +  Nvl(round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2),0)  
                           end),0),
							
    	       nvl(( case when (nvl(monto_financiado,0) < 0) 
                          then 0
		                  else Nvl(monto_financiado,0) +  Nvl(round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2),0)
                           end),0) 
                            into vSaldoTotal, vPagoMinimo
		from bdicred:sd_maecred a 				
		join bdicred:sd_maesdoshist b on (a.empresa = b.empresa and b.fecha =dFechaCorte  and a.num_credito = b.num_credito) 				 
		join bdinteg:si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
        where a.empresa = pEmpresa
          and a.num_credito = pNumCredito;	  

        LET vSaldoTotal = vSaldoTotal + vInteresdebe + vIvadebe;
        LET vPagoMinimo = vPagoMinimo + vInteresdebe + vIvadebe;

-- Devuelve el pago para no generar intereses disminuido por los pagos realizados en el periodo		
-- Se agrega condicion a la consulta de movtos para descartar los pagos anticipados por credisolución '082' AAME 27112017
        IF (pTipoConsulta in (0,4)) THEN
          -- Obtiene pagos realizados historicos
                select nvl(sum(monto),0)
                into vPagosHist
                from bdicred:sd_movhis
                where empresa = pEmpresa
                  and num_credito = pNumCredito
                  and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
                  and codigo_ref = 1
				  and codigo_fun <> '082'
                  and reversado = 'N'
                  and fecha_mov > dFechaCorte 
                  and fecha_mov <= dFechaCentral;

          -- Obtiene pagos realizados actual
                select nvl(sum(monto),0)
                into vPagosAct
                from bdicred:sd_movdia
                where empresa = pEmpresa
                  and num_credito = pNumCredito
                  and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
                  and codigo_ref = 1
				  and codigo_fun <> '082'
                  and reversado = 'N'
                  and fecha_mov > dFechaCorte 
                  and fecha_mov <= dFechaCentral;

              LET vSaldoTotal = vSaldoTotal - vPagosHist - vPagosAct;
              LET vPagoMinimo = vPagoMinimo - vPagosHist - vPagosAct;

              IF (vSaldoTotal < 0) THEN
                LET vSaldoTotal = 0;
              END IF

              IF (vPagoMinimo < 0) THEN
                LET vPagoMinimo = 0;
              END IF

          END IF

	Elif (vRevolvente = 0) then
	
		select (sdo_cap_insoluto     +  
				round(NVL(sdo_intereses,0) * (1+ s.iva),2) + 
				int_tra_no_exig + mto_venc_int + sdo_no_exig + mto_finan_vdo +  
				round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2)),
                (monto_financiado     +  
				round(NVL(sdo_intereses,0) * (1+ s.iva),2) + 
				int_tra_no_exig + mto_venc_int + sdo_no_exig + mto_finan_vdo +  
				round((sdo_moratorio + sdo_contab_mora) * (1+ s.iva),2)) 
                into vSaldoTotal,vPagoMinimo
		from bdicred:sd_maecredcrd a 				
		join bdicred:sd_maesdoshistcrd b on (a.empresa = b.empresa and b.fecha =dFechaCorte and a.num_credito = b.num_credito)                  
		join bdinteg:si_sucursales s on ( s.empresa = a.empresa and s.sucursal = a.sucursal ) 
		where a.empresa = pEmpresa
          and a.num_credito =pNumCredito;
	End If;

	Let vSaldoTotal =nvl(vSaldoTotal,0);
	Let vPagoMinimo =nvl(vPagoMinimo,0);

   IF (pTipoConsulta in (3,4)) THEN
      RETURN cCodRet, vPagoMinimo;
   ELSE
      RETURN cCodRet, vSaldoTotal;
   END IF;

END;
END PROCEDURE;