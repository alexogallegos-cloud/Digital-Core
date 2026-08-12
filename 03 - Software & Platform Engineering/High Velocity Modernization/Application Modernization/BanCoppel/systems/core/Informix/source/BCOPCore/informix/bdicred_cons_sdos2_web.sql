CREATE PROCEDURE "informix".cons_sdos2_web(pempresa CHAR(3),
                            pcuenta  CHAR(20),
                            ptarjeta CHAR(16))

RETURNING CHAR(5),	-- Codigo de Retorno
	  CHAR(20),	-- Numero de Credito
 	  CHAR(20),	-- Numero de Tarjeta
 	  CHAR(20),	-- Numero de Cliente
	  DECIMAL(14,2),-- Saldo Deudor
	  CHAR(60), 	-- Nombre Cliente
      DECIMAL(14,2),-- Pago Minimo
	  CHAR(10),	-- Fecha de Corte
	  CHAR(10),	-- Fecha Limite Pago
      DECIMAL(14,2),-- Saldo Disponible
	  DECIMAL(14,2), -- Saldo Retenido
      DECIMAL(14,2), -- Interes Moratorio
      DECIMAL(14,2), --  Iva Interes Moratorio
      DATE;

   DEFINE vCodRet             CHAR(5);
   DEFINE sql_err             INTEGER;
   DEFINE vNumCte             CHAR(20);
   DEFINE vNombreCte          CHAR(60);
   DEFINE vSdoDisponible      DECIMAL(14,2);
   DEFINE vPagoMin	          DECIMAL(14,2);
   DEFINE vFechaCorte         CHAR(10);
   DEFINE vFechaPago          CHAR(10);
   DEFINE vDisponible         DECIMAL(14,2);
   DEFINE vSdoRetenido        DECIMAL(14,2);
   define vSucursal           char(4);
   define vPorcIva            decimal(14,2);
   define vMoraConIva         decimal(14,2);
   DEFINE vIntMora            decimal(14,2);
   DEFINE vIvaIntMora       decimal(14,2);
--Jom ini agregar intereses vencido
   DEFINE vinteresvencido decimal(14,2);
   DEFINE vivacredito decimal(14,2);
   DEFINE vinteresmes decimal(14,2);
--   DEFINE vivames decimal(14,2);
   define vstatuscred char (02);
   DEFINE sFecExp date;
--Jom fin agregar intereses vencido
    DEFINE vind_cierre          CHAR(1);
    DEFINE vind_disponible      CHAR(1);
	DEFINE iIdUnidadProd        INTEGER;
	DEFINE dfh_pre_devol_an     DATE;

--- Inicializa Variables de Salida
    LET vCodRet        = "00000";
    LET vSdoDisponible = 0;
    LET vNumCte        = " ";
    LET vNombreCte     = " ";
    LET vPagoMin       = 0;
    LET vFechaCorte    = "";
    LET vFechaPago     = "";
    LET vDisponible    = 0;
    LET vSdoRetenido   = 0;
    LET vSucursal      = '0000';
    LET vPorcIva       = 0;
    LET vMoraConIva    = 0;
    LET vIntMora = 0;
    LET vIvaIntMora = 0;
--Jom ini agregar intereses vencido
    LET vinteresvencido = 0;
    LET vivacredito = 0;
    LET vinteresmes = 0;
--    LET vivames = 0;
    LET vstatuscred = '';
    LET sFecExp='';
--Jom fin agregar intereses vencido

    LET vind_cierre           = '0';
    LET vind_disponible       = '0';
	LET iIdUnidadProd     	  = 0;
	LET dfh_pre_devol_an	  = DATE(1);


BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
         RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
             vNombreCte, vPagoMin, vFechaCorte, vFechaPago, vDisponible,
	     vSdoRetenido,vIntMora,vIvaIntMora,sFecExp;
      END IF;
   END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   --SET DEBUG FILE TO "/tmp/cons_sdos2.out";
   --TRACE ON;
   
   SELECT ind_cierre, ind_disponible
     INTO vind_cierre, vind_disponible
     FROM sd_fechas;
     
    IF vind_cierre = '0' OR vind_disponible = '0' THEN
        LET vCodRet = "00040";
        RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
               vNombreCte, vPagoMin, vFechaCorte, vFechaPago, vDisponible,
               vSdoRetenido,vIntMora,vIvaIntMora,sFecExp;
    END IF;

   --Validando si la tarjeta esta INACTIVA
    IF ptarjeta IS NOT NULL OR LENGTH(ptarjeta) <> 0 THEN
       IF ((select COUNT(num_tarjeta) from sd_tarjeta WHERE empresa = pempresa AND num_tarjeta = ptarjeta AND status_tar = "I") > 0) THEN
          LET vCodRet ="00398";
          RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
                 vNombreCte, vPagoMin, vFechaCorte, vFechaPago,
                 vDisponible, vSdoRetenido,vIntMora,vIvaIntMora,sFecExp;
       END IF;
	END IF;
   --Fin validacion de Inactividad   
   
   IF pcuenta IS NULL OR LENGTH(pcuenta) = 0 THEN

  -- Valida que la tarjeta este activa
	SELECT num_credito, numcte, expiracion
	  INTO pcuenta , vNumCte, sFecExp
	  FROM sd_tarjeta
	 WHERE empresa = pempresa
	   AND num_tarjeta = ptarjeta
	   AND status_tar = "A";

	   LET sFecExp = date(mdy(month(sFecExp), '01',year(sFecExp)));
	
    IF pcuenta IS NULL THEN
-- valida ultima tarjeta cancelada
        SELECT num_credito, numcte
        INTO pcuenta , vNumCte
        from bdicred:sd_tarjeta
       where empresa = pempresa
         and num_tarjeta = ptarjeta
         and status_tar = "C"
         and tipo_tarjeta != 'A'
         and secuencia = (
             select max(secuencia)
               from bdicred:sd_tarjeta
              where empresa = pempresa
                and num_tarjeta = ptarjeta
                and tipo_tarjeta != 'A'
                and status_tar = "C");
    end if;

		IF pcuenta IS NULL THEN
		LET vCodRet ="00100";
           RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
                  vNombreCte, vPagoMin, vFechaCorte, vFechaPago,
		  vDisponible, vSdoRetenido,vIntMora,vIvaIntMora,sFecExp;
		END IF;

   ELSE
	SELECT num_tarjeta, numcte
	  INTO ptarjeta, vNumCte
	  FROM sd_tarjeta
	 WHERE empresa = pempresa
	   AND num_credito = pcuenta
	   AND tipo_tarjeta = "T"
	   AND status_tar = "A";

    IF ptarjeta IS NULL THEN
-- valida ultima tarjeta cancelada
	  SELECT num_tarjeta, numcte
	    INTO ptarjeta, vNumCte
        from bdicred:sd_tarjeta
       where empresa = pempresa
         AND num_credito = pcuenta
         AND tipo_tarjeta = "T"
         AND status_tar = "C"
         and secuencia = (
             select max(secuencia)
               from bdicred:sd_tarjeta
              where empresa = pempresa
                AND num_credito = pcuenta
                AND tipo_tarjeta = "T"
                and status_tar = "C");
    end if;

	IF ptarjeta IS NULL THEN
	   LET vCodRet ="00008";
           RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
                  vNombreCte, vPagoMin, vFechaCorte, vFechaPago,
		  vDisponible, vSdoRetenido,vIntMora,vIvaIntMora,sFecExp;
	END IF
   END IF

   SELECT TRIM(NVL(razon_social, ' ')) ||
          TRIM(nombre1) || " " ||
          TRIM(NVL(nombre2, ' ')) || " " ||
          TRIM(apell_paterno) || " " ||
          TRIM(apell_materno)
     INTO vNombreCte
     FROM bdinteg:si_cliente
    WHERE numcte = vNumCte;
	--AAME IFRS Se contempla el nuevo capital_status igual a 6 del vencido de Etapa 3
   SELECT (c.sdo_cap_insoluto + c.sdo_retenido),
	  monto_financiado,
          f.fecha_hoy, e.prox_fecha_pago,
	  monto_otorgado - (sdo_cap_insoluto + sdo_retenido),
	  sdo_retenido, sucursal,
--jom ini se agrega interes vencido
      status_cred,
      int_tra_no_exig Interes_vencido,
      nvl((SELECT SUM(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status in ('2','7','6')),0) iva_interes,
      nvl((SELECT SUM(interes_debe - interes_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status = '1'),0) interes_mes,
	  b.id_unidad_prod
--     ,nvl((SELECT SUM(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status = '1'),0) iva_mes
--jom ini se agrega interes vencido
     INTO vSdoDisponible, vPagoMin, vFechaCorte, vFechaPago,
	  vDisponible, vSdoRetenido, vSucursal,
      vstatuscred,
      vinteresvencido, vivacredito, vinteresmes, iIdUnidadProd --, vivames
     FROM sd_maecred b, sd_maesdos c, sd_maecredanexo e,
	  sd_fechas f
    WHERE b.empresa = pempresa
      AND b.num_credito = pcuenta
      AND c.empresa = b.empresa
      AND c.num_credito = b.num_credito
      AND e.empresa = b.empresa
      AND e.num_credito = b.num_credito
      AND f.empresa = b.empresa;

-- cartera vendida
      if ( vstatuscred = 'CV' ) then
	   LET vCodRet ="00015";
           RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
                  vNombreCte, vPagoMin, vFechaCorte, vFechaPago,
		  vDisponible, vSdoRetenido,vIntMora,vIvaIntMora,sFecExp;
      END IF;

--  credito cancelado
      IF ( vstatuscred = 'FF' ) then
	   LET vCodRet ="00279";
           RETURN vCodRet,'','','',0,
                  '', 0, date(1), date(1),
		  0, 0,0,0,'';
      END IF;

      SELECT iva INTO vPorcIva
        FROM bdinteg:si_sucursales
       WHERE empresa = pempresa
   	     AND sucursal = vSucursal;

-- jom ini se agregan los intereses vencidos al saldo  y al pago minimo
 --AAME IFRS Se contempla el nuevo estatus de Vencido por etapas
     if ( vstatuscred IN ('BT','E2','E3')) then
         let vPagoMin = vPagoMin + vinteresvencido + vivacredito;
         let vSdoDisponible = vSdoDisponible + vinteresvencido + vivacredito;

         if ( vinteresvencido > 0 ) then
            let vPagoMin = vPagoMin - vinteresmes;
            let vSdoDisponible = vSdoDisponible - vinteresmes;
         end if;
     end if;

-- jom fin se agregan los intereses vencidos al saldo  y al pago minimo

{ Se comentariza para desgloce de moratorios

      SELECT (sum(nvl(mora_provi_ordi,0)) + sum(nvl(mora_provi_cope,0))) *
	     (1 + nvl(vPorcIva,0)) as mora
      INTO vMoraConIva
      FROM bdicred:sd_amortiza_credito
      WHERE empresa = pempresa
      AND num_credito = pcuenta;

      IF vMoraConIva < 0 THEN
        LET vMoraConIva = 0;
      END IF;

      LET vPagoMin = vPagoMin + vMoraConIva;
}
	--AAME IFRS Se contempla el nuevo capital_status igual a 6 del vencido de Etapa 3
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
	--AAME IFRS Se contempla el nuevo capital_status igual a 6 del vencido de Etapa 3
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

-- jom ini se agregan los moratorios al saldo
    let vSdoDisponible = vSdoDisponible + vIntMora + vIvaIntMora;
-- jom fin se agregan los moratorios al saldo

    -- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad INI
    SELECT nvl(date(fecha_pre_devol_anual),date(1)) INTO dfh_pre_devol_an 
	  FROM bdicred:sd_indicador_cred WHERE empresa = pempresa AND num_credito = pcuenta;

	IF iIdUnidadProd = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) THEN 
		IF vSdoDisponible < 0 THEN
			LET vDisponible = (vSdoDisponible * -1); -- envia capital unicamente
		ELSE
			LET vDisponible = vSdoDisponible;
		END IF;
	END IF;
	-- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad FIN


    RETURN vCodRet,pcuenta,ptarjeta,vNumCte,vSdoDisponible,
           vNombreCte, vPagoMin, vFechaCorte, vFechaPago, vDisponible,
	   vSdoRetenido,vIntMora,vIvaIntMora,sFecExp;

END
END PROCEDURE
DOCUMENT
'Consulta de Saldos y Pago minimo en plataforma',
'AUTOR : Antonio Ruiz Mtz',
'FECHA : 04/Septiembre/2007',
'VERSION: 1.00.000',
'BD    : BDICRED',
'--------------------------',
'DSB 12/04/2011',
'ModificÃÂ³: Josue Zepeda',
'Se valido para que no muestre tarjetas cuando sea adicional y cancelada.',
'--------------------------';

CREATE PROCEDURE "informix".consultmovs(pempresa char(3),
                             pcuenta char(20),
                             psecuencia smallint)
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
   DEFINE vPorcIva  DECIMAL(14,2);
   DEFINE vSdoDeudor  DECIMAL(14,2);
   DEFINE vPagoMin    DECIMAL(14,2);
   DEFINE vFechaCorte CHAR(15);
   DEFINE vFechaPago  CHAR(15);
   DEFINE vIntMora DECIMAL(14,2);
   DEFINE vIvaIntMora DECIMAL(14,2);
--Jom ini agregar intereses vencido
   DEFINE vinteresvencido decimal(14,2); 
   DEFINE vivacredito decimal(14,2); 
   DEFINE vinteresmes decimal(14,2); 
--   DEFINE vivames decimal(14,2);
   define vstatuscred char (02);
--Jom fin agregar intereses vencido


   LET vcodret    = "000";
   LET vtransacc  = " ";
   LET vfecha     = " ";
   LET vmonto     = 0;
   LET vSucursal = 0;
   LET vPorcIva       = 0;
   LET vSdoDeudor = 0;
   LET vPagoMin = 0;
   LET vFechaCorte = " ";
   LET vFechaPago  = " ";
   LET vIntMora = 0;
   LET vIvaIntMora = 0;
   LET vciclo     = 0;
   LET vultmovto  = 5;
--Jom ini agregar intereses vencido
    LET vinteresvencido = 0;
    LET vivacredito = 0;
    LET vinteresmes = 0;
--    LET vivames = 0;
    let vstatuscred = '';
--Jom fin agregar intereses vencido

   set isolation to dirty read;
   set lock mode to wait 5;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/tmp/consultmovs.out";
 --TRACE ON;

   BEGIN
      ON EXCEPTION SET vsqlerr
         IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vfecha,vtransacc,vmonto,vPagoMin,vSdoDeudor,vIntMora,vIvaIntMora;
         END IF
      END EXCEPTION;

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
		
      SELECT a.sdo_cap_insoluto,
	     a.monto_financiado,
	     TO_CHAR(c.fecha_hoy,"20-%m-%Y"),
	     TO_CHAR(b.prox_fecha_pago, "%d-%m-%Y"),
          status_cred, 
          int_tra_no_exig Interes_vencido,
          nvl((SELECT SUM(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status in ('2','7','6')),0) iva_interes,
          nvl((SELECT SUM(interes_debe - interes_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status = '1'),0) interes_mes
--         ,nvl((SELECT SUM(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status = '1'),0) iva_mes
        INTO vSdoDeudor, vPagoMin, vFechaCorte, vFechaPago,
      vstatuscred, 
      vinteresvencido, vivacredito, vinteresmes--, vivames
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
         LET vcodret = "100";
         RETURN vcodret,vfecha,vtransacc,vmonto,vPagoMin,vSdoDeudor,vIntMora,vIvaIntMora;
      END IF;

---  credito cancelado
     if ( vstatuscred = 'FF' ) then
         LET vcodret = "279";
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
/*         SELECT fecha_mov, secuencia, monto,
                transacc||" "||TRIM(b.descripcion),naturaleza
           INTO vfecha,vserial,vmonto,vtransacc,vnaturaleza
           FROM sd_movdia a , bdinteg:si_transacc b, sd_transfun c
	  WHERE a.empresa = pempresa
	    AND a.num_credito = pcuenta
	    AND c.empresa = a.empresa
--	    AND c.codigo_fun = a.codigo_fun
--	    AND c.codigo_ref = a.codigo_ref
	    AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
        and a.fecha_mov >= date(0)
	    AND b.empresa = c.empresa
	    AND b.numero = c.transacc
	    AND b.sistema = "06"
	    AND b.se_emite_edocta = "S"
        AND a.reversado = "N"
          ORDER BY fecha_mov desc,secuencia desc
*/
         SELECT fecha_mov, secuencia, monto,
                transacc||" "||TRIM(b.descripcion),naturaleza
           INTO vfecha,vserial,vmonto,vtransacc,vnaturaleza
           FROM sd_movdia a , bdinteg:si_transacc b, sd_transfun c
--          WHERE a.empresa = pempresa
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
/*			 SELECT fecha_mov, secuencia, monto,
					transacc||" "||TRIM(b.descripcion),naturaleza
			   INTO vfecha,vserial,vmonto,vtransacc,vnaturaleza
			   FROM sd_movhis_new a , bdinteg:si_transacc b, sd_transfun c
			  WHERE a.empresa = pempresa
				AND a.num_credito = pcuenta
				AND c.empresa = a.empresa
				AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				and a.fecha_mov >= date(0)
				AND b.empresa = c.empresa
				AND b.numero = c.transacc
				AND b.se_emite_edocta = "S"
				AND b.sistema = "06"
				AND a.reversado = "N"
	  UNION ALL
	  		 SELECT fecha_mov, secuencia, monto,
					transacc||" "||TRIM(b.descripcion),naturaleza
			   FROM sd_movhis a , bdinteg:si_transacc b, sd_transfun c
			  WHERE a.empresa = pempresa
				AND a.num_credito = pcuenta
				AND c.empresa = a.empresa
				AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
				and a.fecha_mov >= date(0)
				AND b.empresa = c.empresa
				AND b.numero = c.transacc
				AND b.se_emite_edocta = "S"
				AND b.sistema = "06"
				AND a.reversado = "N"
		   ORDER BY fecha_mov desc,secuencia desc
*/
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
END
END PROCEDURE;