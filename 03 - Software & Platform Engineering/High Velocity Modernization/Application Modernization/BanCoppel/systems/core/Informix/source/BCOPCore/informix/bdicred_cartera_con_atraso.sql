CREATE PROCEDURE "informix".cartera_con_atraso(pempresa     CHAR(3),
			    pfechaini    DATE,
			    pfechafin    DATE)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Credito
          CHAR(4),       -- Sucursal
	  CHAR(40),      -- Nombre Sucursal
          CHAR(104),     -- Nombre del Cliente
          CHAR(13),      -- Telefono1
          CHAR(13),      -- Telefono2
          CHAR(13),      -- Telefono3
          DATE,          -- Fecha Ultimo Pago
          MONEY(14,2),	 -- Importe Ultimo Pago
          MONEY(14,2),	 -- Saldo Total Adeudado
          MONEY(14,2),	 -- Pago Minimo
          MONEY(14,2),	 -- Saldo Adeudos Traspasados
          MONEY(14,2),	 -- Saldo Adeudos Transitorios
          MONEY(14,2),	 -- Saldo Vencido
          CHAR(5),	 -- Extension
          SMALLINT;	 -- Pagos Vencidos


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE vsqlerr            INTEGER;
DEFINE scod_ret           CHAR(5);
DEFINE s_numcred          CHAR(20);
DEFINE s_sucursal         CHAR(4);
DEFINE s_nomsuc           CHAR(40);
DEFINE s_nombrecte        CHAR(104);
DEFINE s_telefono1        CHAR(13);
DEFINE s_telefono2        CHAR(13);
DEFINE s_telefono3        CHAR(13);
DEFINE s_fecha_ult_pago   DATE;
DEFINE s_monto_ult_pago   MONEY(14,2);
DEFINE s_sdo_total        MONEY(14,2);
DEFINE s_pago_minimo      MONEY(14,2);
DEFINE s_sdo_traspasados  MONEY(14,2);
DEFINE s_sdo_transitorios MONEY(14,2);

DEFINE s_saldo_vencido    MONEY(14,2);
DEFINE s_extension	  CHAR(5);
DEFINE s_pagos_vencidos   SMALLINT;

DEFINE s_numcte        CHAR(20);
DEFINE v_cuantos       SMALLINT;
DEFINE vfecha_hoy      DATE;
DEFINE s_consulta      SMALLINT;
DEFINE s_fecha_cuota   DATE;
define vnumcte			char(20);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET scod_ret           = "000";
LET vsqlerr            = 0;
LET s_numcte           = "";
LET v_cuantos          = 0;

LET s_numcred          = "";
LET s_sucursal         = "";
LET s_nomsuc           = "";
LET s_nombrecte        = "";
LET s_telefono1        = "";
LET s_telefono2        = "";
LET s_telefono3        = "";
LET s_fecha_ult_pago   = "";
LET s_monto_ult_pago   = 0;
LET s_sdo_total        = 0;
LET s_pago_minimo     = 0;
LET s_sdo_traspasados  = 0;
LET s_sdo_transitorios = 0;
LET s_fecha_cuota      = "";

LET s_saldo_vencido    = 0;
LET s_extension	       = 0;
let vnumcte= '';
LET s_pagos_vencidos   = 0;


--scod_ret,s_numcred,s_sucursal,s_nomsuc,s_nombrecte,s_telefono1,s_telefono2,s_telefono3,
--s_fecha_ult_pago,s_monto_ult_pago,s_sdo_total,s_pago_minimo,s_sdo_traspasados,s_sdo_transitorios
--s_saldo_vencido,s_extension,s_pagos_vencidos




-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,s_numcred,s_sucursal,s_nomsuc,s_nombrecte,s_telefono1,s_telefono2,s_telefono3,
             s_fecha_ult_pago,s_monto_ult_pago,s_sdo_total,s_pago_minimo,s_sdo_traspasados,s_sdo_transitorios,
             s_saldo_vencido,s_extension,s_pagos_vencidos;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/credito/basura/cartera_con_atraso.out";
-- TRACE ON;
 
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

let pempresa = pempresa;
let pfechafin = pfechafin;
let pfechaini  = pfechaini;


   -- Carga la Fecha del Dia
   
   SELECT fecha_hoy 
     INTO vfecha_hoy
     FROM bdicred:sd_fechas
    WHERE empresa = pempresa;
     


      FOREACH 	
	SELECT
            a.numcte,a.num_credito, a.sucursal,
            b.nombre,     
            trim(c.nombre1) || ' ' || trim(c.nombre2) || ' ' || trim(c.apell_paterno) || ' ' || trim(c.apell_materno),
           -- nvl(d.telefono1," "), nvl(d.telefono2," "), nvl(d.telefono3," "), nvl(d.extension," "),
            (nvl(e.sdo_cap_insoluto,"0")), nvl(mto_venc_trasp,"0"), nvl(monto_vencido,"0"), nvl(monto_financiado,"0")
	INTO
            vnumcte,s_numcred,s_sucursal,
            s_nomsuc,
            s_nombrecte,
            --s_telefono1,s_telefono2,s_telefono3,s_extension,
            s_sdo_total, s_sdo_traspasados,s_sdo_transitorios,s_pago_minimo
        FROM
            bdicred:sd_maecred a,   
            bdinteg:si_sucursales b,   
            bdinteg:si_cliente c,
            --bdinteg:si_direcciones d,
            bdicred:sd_maesdos e   
	WHERE
            a.empresa = c.empresa  
        AND (a.fecha_apertura >= pfechaini AND a.fecha_apertura <= pfechafin)
        AND a.numcte = c.numcte   
        AND a.empresa = b.empresa
        AND a.sucursal = b.sucursal
        AND e.num_credito = a.num_credito
        AND e.empresa = a.empresa 
       -- AND d.numcte = a.numcte
       -- AND d.secuencia = (select max(secuencia) from bdinteg:si_direcciones where numcte = a.numcte and tipo_dir = 1)
        AND a.empresa = pempresa
		AND a.status_cred NOT IN ('AA','E1') 
		AND (e.mto_venc_trasp + e.monto_vencido) > 0
        -- IFRS AND (a.status_cred<>'AA')) 
     ORDER BY a.sucursal, b.nombre ASC
	
	
		select  telefono 
			into  s_telefono1
		from bdinteg:si_telefonos_actual 
		where numcte = vnumcte 
				and tipo_tel = 1 and cofetel ='V'
				and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = vnumcte and tipo_tel = 1 and cofetel ='V');
										
		select  telefono 
			into  s_telefono2
		from bdinteg:si_telefonos_actual 
		where numcte = vnumcte 
				and tipo_tel = 2 and cofetel ='V'
				and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = vnumcte and tipo_tel = 2 and cofetel ='V');
												
		select  telefono ,extension
			into  s_telefono3, s_extension
		from bdinteg:si_telefonos_actual 
		where numcte = vnumcte 
				and tipo_tel = 3 and cofetel ='V'
				and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = vnumcte and tipo_tel = 3 and cofetel ='V');


      SELECT max(capital_fecha_pago), max(fecha_cuota)
        INTO s_fecha_ult_pago, s_fecha_cuota
        FROM bdicred:sd_amortiza_credito
       WHERE empresa = pempresa
         AND num_credito = s_numcred
--         AND capital_status in (7,2)
--  IFRS   AND capital_status in (7,2,6)
         AND NOT capital_fecha_pago IS NULL;


      SELECT nvl(capital_pagado,"0") + nvl(interes_pagado,"0") + nvl(iva_pagado,"0")
        INTO s_monto_ult_pago
        FROM bdicred:sd_amortiza_credito
       WHERE empresa = pempresa
         AND num_credito = s_numcred
         AND capital_fecha_pago = s_fecha_ult_pago
         AND fecha_cuota = s_fecha_cuota;

      -- Saldo Vencido
      LET s_saldo_vencido = s_sdo_traspasados + s_sdo_transitorios;


      -- Pagos Vencidos
      SELECT count(capital_status)
        INTO s_pagos_vencidos
        FROM bdicred:sd_amortiza_credito
       WHERE empresa = pempresa
         AND num_credito = s_numcred
		 AND capital_status in (7,2,6);
         --IFRS AND capital_status in (7,2);


      RETURN scod_ret,s_numcred,s_sucursal,s_nomsuc,s_nombrecte,s_telefono1,s_telefono2,s_telefono3,
             s_fecha_ult_pago,s_monto_ult_pago,s_sdo_total,s_pago_minimo,s_sdo_traspasados,s_sdo_transitorios,
             s_saldo_vencido,s_extension,s_pagos_vencidos
             WITH RESUME;

      END FOREACH

END

END PROCEDURE
;