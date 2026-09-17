CREATE PROCEDURE "informix".sp_consulta_sdo(pempresa CHAR(3),
                 pcuenta  CHAR(20),
                 ptarjeta CHAR(16))
-- FMV corrige nombre de campo
RETURNING CHAR(5),	 -- Codigo de Retorno
          DECIMAL(14,2), -- Capital
          DECIMAL(14,2), -- Interes Vigente
	  DECIMAL(14,2), -- Interes Vencido
          DECIMAL(14,2), -- Iva Int. Vigente
          DECIMAL(14,2), -- Iva Int. Vencido
          DECIMAL(14,2), -- Mora Ord.
          DECIMAL(14,2), -- Iva Mora Ord.
          DECIMAL(14,2), -- Mora Copete
          DECIMAL(14,2), -- Iva Mora Copete
          CHAR(20)     , --NumCte
          CHAR(20)     ; --No.Tarjeta

   DEFINE vCodRet       CHAR(5);
   DEFINE sql_err       INTEGER;
   DEFINE vCapital      DECIMAL(14,2);
   DEFINE vIntVigente   DECIMAL(14,2);
   DEFINE vIntVencido   DECIMAL(14,2);
   DEFINE vIvaIntVig    DECIMAL(14,2);
   DEFINE vIvaIntVen    DECIMAL(14,2);
   DEFINE vMoraOrd      DECIMAL(14,2);
   DEFINE vIvaMoraOrd   DECIMAL(14,2);
   DEFINE vMoraCopete   DECIMAL(14,2);
   DEFINE vIvaMoraCope  DECIMAL(14,2);
   DEFINE vCuotasVenc   CHAR(4);
   DEFINE vCtaCuotas    INTEGER;
   DEFINE vNumCte       CHAR(20);
   DEFINE vNumTarjeta   CHAR(20);
   DEFINE vSucursalCred CHAR(4);
   DEFINE vIvaSucursal  DECIMAL(5,3);
   DEFINE vIvaNominal   DECIMAL(14,2);
   DEFINE vdummy        CHAR(100);
   DEFINE vCartera	INTEGER;
   DEFINE vinteresvend  DECIMAL(14,2);
   DEFINE vivavend      DECIMAL(14,2);
   define vtasa         date;
   define vhoy          date;
   define vfecaper      date;
   define vfecuota      date;
   define vmensaje      char(80);
   define ccontar       integer;
   --- Inicializa Variables de Salida
    LET vCodRet        = "000";
    LET vCapital       = 0;
    LET vIntVigente    = 0;
    LET vIntVencido    = 0;
    LET vIvaIntVig     = 0;
    LET vIvaIntVen     = 0;
    LET vMoraOrd       = 0;
    LET vIvaMoraOrd    = 0;
    LET vMoraCopete    = 0;
    LET vIvaMoraCope   = 0;
    LET vCuotasVenc    = '';
    LET vCtaCuotas     = 0;
    LET vNumTarjeta    = '';
    LET vNumCTe        = '';
	LET vSucursalCred  = '';
	LET vIvaSucursal   = 0;
	LET vIvaNominal    = 0;
    let ccontar        = 0;


BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
           RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig, vIvaIntVen, vMoraOrd,
                  vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte, vNumTarjeta;
      END IF;
   END EXCEPTION;

   --** No. De Cuotas Vencidas **--
--   SET DEBUG FILE TO "/tmp/sdo.out";
--   TRACE ON;

   SELECT valor
     INTO vCuotasVenc
     FROM sd_param
    WHERE empresa = pempresa
      AND cod_param ='111';

   IF vCuotasVenc Is Null THEN   -- FMV BGM 3-feb-10 se deja la validacion como estaba antes
      LET vCodRet  ='9';
           RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig, vIvaIntVen, vMoraOrd,
                  vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte, vNumTarjeta;
   END IF;

  --** Verifica Si Existe El Credito **--
  LET pcuenta = pcuenta;
  LET ptarjeta = ptarjeta;
  IF pcuenta IS NOT NULL AND pcuenta <> ' '  THEN   --Busqueda Por Cliente
     LET vNumCte = pcuenta;

     FOREACH
          SELECT tar.num_credito,tar.num_tarjeta
            INTO pcuenta, vNumTarjeta
            FROM sd_tarjeta tar, sd_maecred mae
	   WHERE mae.empresa = tar.empresa
	     AND mae.num_credito = tar.num_credito
	     AND mae.numcte = vNumCte
             AND tipo_tarjeta  = 'T'
           ORDER BY status_tar

            EXIT FOREACH;
     END FOREACH

     IF vNumTarjeta IS NOT NULL AND vNumTarjeta <> "" THEN
           IF Exists (SELECT numcte
		                FROM sd_maecred
					   WHERE empresa = pempresa
					     AND num_credito = pcuenta
						 AND status_cred = 'FC') THEN
              LET vCodRet  ='7';
              RETURN vCodRet, vCapital   , vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
                     vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte,vNumTarjeta;
	    END IF;
     END IF;
   ELSE
	 SELECT num_credito, numcte, num_tarjeta
	   INTO pcuenta, vNumCte, vNumTarjeta
	   FROM sd_tarjeta
	  WHERE empresa = pempresa
	    AND num_tarjeta = ptarjeta
	    AND tipo_tarjeta = "T";
--	    AND status_tar = "A";
     IF pcuenta IS NULL THEN
	    LET vCodRet ="008";
        RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig, vIvaIntVen, vMoraOrd,
               vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte, vNumTarjeta;
	 END IF
   END IF

   --** Lectura De Cuotas Vencidas **--
   SELECT Count(*)
   INTO vCtaCuotas
   FROM sd_amortiza_credito
   WHERE empresa = pempresa and num_credito = pcuenta and capital_status in ('2','7','6');

   --** Lectura De Existencia De Credito Reestructurado **--
   IF Exists (SELECT numcte FROM sd_maecred WHERE empresa = pempresa AND num_credito  = pcuenta AND status_cred='FC' ) THEN
      LET vCodRet  ='7';
      RETURN vCodRet, vCapital   , vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
             vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte,vNumTarjeta;
   ELSE
      IF vCtaCuotas < vCuotasVenc THEN
         LET vCodRet  ='10';
         RETURN vCodRet, vCapital   , vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
               vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte,vNumTarjeta;
      END IF;
   END IF;

   -- BGM 28/ago/09 :Se valida que el credito este en cartera vendida

   SELECT id_unidad_prod
   into vCartera
   FROM sd_maecred
   WHERE empresa = pempresa AND num_credito  = pcuenta;

   IF vCartera IS NOT NULL THEN
      LET vCodRet  ='15';
      RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
             vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte,vNumTarjeta;
   END IF;

-- No se pueden reestructurar los clientes de prueba de grupo3 jom
    select count(*)
     into ccontar
     from bdisitesp:se_ctessitespcred 
    where empresa = pempresa
      and numcred  = pcuenta
      and situacion = 'P' 
      and causa = 61;
-- No se pueden reestructurar los clientes de prueba de grupo3 jom

   IF ccontar > 0 THEN
      LET vCodRet  ='307';
      RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
             vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte,vNumTarjeta;
   END IF;

   -- BGM Termina validación cartera vendida

   --** Lectura De Saldos Para Reestructurar **--
   -- AVC Modifica la forma de obtener Capital
   --SELECT sdo_cap_insoluto, sdo_no_exig, (sdo_exig_int + int_tra_no_exig)
   --INTO vCapital, vIntVigente, vIntVencido
   --FROM sd_maesdos
   --WHERE empresa     = pempresa
   --  AND num_credito = pcuenta;

   -- AVC Obtiene la Sucursal del Credito
   SELECT sucursal
     INTO vSucursalCred
     FROM bdicred:sd_maecred
	WHERE empresa = pempresa
	  AND num_credito = pcuenta;

   --** Lectura De Saldos Para Reestructurar **--
   -- AVC Modifica la forma de obtener Capital
   SELECT sdo_cap_insoluto
   INTO vCapital
   FROM sd_maesdos
   WHERE empresa     = pempresa
     AND num_credito = pcuenta;

	-- AVC Modifica la forma de obtener el interes Vigente
	-- considerando como fecha de nuevo calculo (estatus capital) Dic/2008
	SELECT NVL(sum(interes_debe),0), NVL(sum(iva_debe - iva_pagado),0)
	INTO vIntVigente, vIvaIntVig
	FROM bdicred:sd_amortiza_credito
    WHERE empresa     = pempresa
      AND num_credito = pcuenta
	  AND capital_status = '1';
	-- AVC FIN Modifica la forma de obtener el interes Vigente

	-- AVC Modifica la forma de obtener el interes Vencido
	-- considerando como fecha de nuevo calculo (estatus capital) Dic/2008
	SELECT NVL(sum(interes_debe - interes_pagado),0), NVL(sum(iva_debe - iva_pagado),0)
	INTO vIntVencido, vIvaIntVen
	FROM bdicred:sd_amortiza_credito
    WHERE empresa     = pempresa
      AND num_credito = pcuenta
	  AND capital_status in ('2','6','7');
	-- AVC FIN Modifica la forma de obtener el interes Vencido

   -- AVC Obtencion de los Moratorios
   SELECT NVL(sum(mora_provi_ordi +  mora_sdo_ordi - mora_sdo_ordi_pag),0),
          NVL(sum( mora_provi_cope+  mora_sdo_cope - mora_sdo_cope_pag),0)
          --NVL(sum(mora_iva_debe - mora_iva_pagado),0)
	 --INTO vMoraOrd , vMoraCopete, vIvaMoraOrd
     INTO vMoraOrd , vMoraCopete
     FROM bdicred:sd_amortiza_credito
    WHERE empresa = pempresa
      AND num_credito = pcuenta
	  AND capital_status in ('2','7','6');

   --AVC Obtencion del IVA de la Sucursal
   SELECT iva
     INTO vIvaSucursal
     FROM bdinteg:si_sucursales
	WHERE empresa = pempresa
	  AND sucursal = vSucursalCred;

   --AVC Calcula el IVA de Mora Ordinaria y Copete
   LET vIvaNominal = (vMoraOrd + vMoraCopete) * vIvaSucursal;
   LET vIvaMoraOrd = vMoraOrd * vIvaSucursal;
   LET vIvaMoraCope = vIvaNominal - vIvaMoraOrd;
   
   select sdo_intereses into vinteresvend  
     from sd_maesdos
    WHERE empresa     = pempresa
      AND num_credito = pcuenta;
		 
   if vinteresvend is null then let vinteresvend = 0; end if;
   
   if vinteresvend > 0 then
    select tasa_interes,fecha_apertura
      into vtasa,vfecaper
      from sd_maecred
      WHERE empresa     = pempresa
         AND num_credito = pcuenta;
      select fecha_hoy into vhoy
        from sd_fechas;
     SELECT max(fecha_cuota)
	INTO vfecuota
	FROM bdicred:sd_amortiza_credito
    WHERE empresa     = pempresa
      AND num_credito = pcuenta
	  AND capital_status = '1';        
      call calc_iva_grav_pp(pempresa,pcuenta,vtasa,vIvaSucursal,vhoy,null,
          vfecaper,vfecuota,vinteresvend)
       returning    vCodRet,vivavend,vmensaje;
      let vIntVigente = vIntVigente + vinteresvend;
      let vIvaIntVig = vIvaIntVig + vivavend;
   end if
   -- AVC Ya se calculo arriba
   --SELECT sum(iva_debe - iva_pagado)
   --  INTO vIvaIntVig
   --  FROM sd_amortiza_credito
   -- WHERE empresa     = pempresa
   --   AND num_credito = pcuenta
   --   AND iva_status = '1';

   -- AVC Eliminar pues ya se tiene el NVL arriba
   --IF vIvaIntVig Is Null THEN
   --   LET vIvaIntVig = 0;
   --END IF;

   -- AVC Ya se calculo arriba
   --SELECT sum(iva_debe - iva_pagado)
   --  INTO vIvaIntVen
   --  FROM sd_amortiza_credito
   -- WHERE empresa     = pempresa
   --   AND num_credito = pcuenta
   --   AND iva_status IN ('2','3','7');

   -- AVC Eliminar pues ya se tiene el NVL arriba
   --IF vIvaIntVen Is Null THEN
   --    LET vIvaIntVen = 0;
   --END IF;

   RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd,
          vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte, vNumTarjeta;
END
END PROCEDURE
;