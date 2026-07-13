CREATE PROCEDURE "informix".planpagint(pempresa char(3),
                            pnum_credito  CHAR(20),
                            pnum_pago     SMALLINT) --mandan un cero y el
                                                    -- cs2 regresa de 20 en 20.

   RETURNING CHAR(06),     -- Codigo de retorno
             CHAR(80),     -- Nombre del cliente
             DATE,         -- Fecha de apertura del credito
             DATE,         -- Fecha de vencimiento del credito
             CHAR(45),     -- Nombre del Producto
             MONEY(14,2),  -- Monto de la cuota propios
             DATE,         -- Fecha de vencimiento de la cuota propios
             DATE,         -- Fecha de pago de la cuota propios
             CHAR(1),      -- Status de ls cuota
             CHAR(54),     -- Nombre del ejecutivo
             CHAR(30),     -- Nombre de la divisa
             MONEY(14,2);  -- Monto otorgado


   --####################################################################
   --#####                    Define variables                      #####
   --####################################################################

   DEFINE i                   SMALLINT;
   DEFINE text                CHAR(100);
   DEFINE sqlerr,isamerr      SMALLINT;
   DEFINE v_num_credito       CHAR(20);
   DEFINE cod_ret             CHAR(6);
   DEFINE v_ciclo             SMALLINT;
   DEFINE v_conta             SMALLINT;
   DEFINE v_apell_paterno     CHAR(15);
   DEFINE v_apell_materno     CHAR(15);
   DEFINE v_nombre1           CHAR(15);
   DEFINE v_nombre2           CHAR(15);
   DEFINE v_razon_social      CHAR(80);
   DEFINE v_cliente           CHAR(60);
   DEFINE v_descripcion       CHAR(44);
   DEFINE v_num_producto      LIKE sd_maecred.num_producto;
   DEFINE v_cod_tipcred       LIKE sd_definicion.cod_tipcred;
   DEFINE v_divisa            LIKE sd_maecred.divisa;
   DEFINE v_ejecutivo         LIKE sd_maecred.ejecutivo;
   DEFINE v_monto_otorgado    LIKE sd_maesdos.monto_otorgado;
   DEFINE vv_nombre           CHAR(54);
   DEFINE vv_descripcion      LIKE si_divisas.descripcion;

   DEFINE v_numcte            LIKE sd_maecred.numcte;
   DEFINE vg_cliente          CHAR(80);
   DEFINE v_fecha_apertura    LIKE sd_maecred.fecha_apertura;
   DEFINE v_fecha_vencim      LIKE sd_maecred.fecha_vencim;
   DEFINE v_monto_cuota       LIKE sd_paginter.monto_cuota;
   DEFINE v_fecha_cuota       LIKE sd_paginter.fecha_cuota;
   DEFINE v_fecha_pag         LIKE sd_paginter.fecha_pag;
   DEFINE v_status_cuota      LIKE sd_paginter.status_cuota;
   DEFINE v_monto_cuota1      LIKE sd_paginter.monto_cuota;
   DEFINE v_fecha_cuota1      LIKE sd_paginter.fecha_cuota;
   DEFINE v_fecha_pag1        LIKE sd_paginter.fecha_pag;
   DEFINE v_status_cuot1      LIKE sd_paginter.status_cuota;
   DEFINE v_monto_cuotas      MONEY(14,2);

-- ##########################################################################
-- #####                    Control de Errores
-- ##########################################################################

   ON EXCEPTION SET sqlerr, isamerr
      IF sqlerr != 0 THEN
         LET cod_ret = sqlerr;
         -- este parametro cero (0) es interno de visual es necesario
         -- que lo manden despues del credito.
         IF cod_ret = -696 THEN
            LET cod_ret = "272";
            LET v_fecha_apertura = " ";
            LET v_fecha_vencim   = " ";
            LET v_fecha_pag      = " ";
            LET v_fecha_cuota    = " ";
            LET v_monto_cuota    = 0.00;
            LET v_status_cuota   = " ";
            LET v_fecha_pag1     = " ";
            LET v_fecha_cuota1   = " ";
            LET v_monto_cuota1   = 0.00;
            LET v_status_cuot1   = " ";
            LET vg_cliente       = " ";
            LET v_descripcion    = " ";
            LET v_monto_cuotas   = 0;
            RETURN cod_ret,          vg_cliente,     v_fecha_apertura,
                   v_fecha_vencim,   v_descripcion,  
                   v_monto_cuota,    v_fecha_cuota,  v_fecha_pag,
                   v_status_cuota,   vv_nombre,      vv_descripcion,
                   v_monto_otorgado;
         END IF;
      END IF;
   END EXCEPTION;



   --####################################################################
   --#####                 Inicializa Variables                     #####
   --####################################################################

   LET cod_ret           = "000000";
   LET i                 = 1;
   LET v_ciclo           = 0;
   LET v_conta           = 0;
   LET v_num_credito     = " ";
   LET v_fecha_pag       = " ";
   LET v_fecha_apertura  = " ";
   LET v_fecha_vencim    = " ";
   LET v_monto_cuota     = 0;
   LET v_status_cuota    = " ";
   LET v_descripcion     = " ";
   LET vg_cliente        = " ";
   LET v_divisa          = " ";
   LET v_ejecutivo       = " ";
   LET v_monto_otorgado  = 0;
   LET vv_nombre         = " ";
   LET vv_descripcion    = "  ";
   LET v_monto_cuota1    = 0;
   LET v_fecha_cuota1    = " ";
   LET v_fecha_pag1      = " ";
   LET v_status_cuot1    = " ";
   LET v_monto_cuotas    = 0;

   --#####################################################################
   --######            Inicio de Transaccion                         #####
   --#####################################################################

   IF pnum_credito IS NULL OR
      pnum_credito = " " THEN
      LET cod_ret = "223"; -- NUMERO DE CREDITO NULO O BLANCO
            RETURN cod_ret,          vg_cliente,     v_fecha_apertura,
                   v_fecha_vencim,   v_descripcion,  
                   v_monto_cuota,    v_fecha_cuota,  v_fecha_pag,
                   v_status_cuota,   vv_nombre,      vv_descripcion,
                   v_monto_otorgado;
   ELSE
      LET v_num_credito = pnum_credito;
   END IF;

   SELECT num_credito,   numcte,         divisa,
          ejecutivo,     num_producto,   fecha_apertura,
          fecha_vencim
   INTO   v_num_credito, v_numcte,       v_divisa,
          v_ejecutivo,   v_num_producto, v_fecha_apertura,
          v_fecha_vencim
   FROM sd_maecred
   WHERE empresa = pempresa and num_credito = v_num_credito;

   IF v_num_credito IS NULL OR
      v_num_credito = " " THEN
      LET cod_ret = "224"; -- NO EXISTE EL CREDITO EN sd_maecred
            RETURN cod_ret,          vg_cliente,     v_fecha_apertura,
                   v_fecha_vencim,   v_descripcion,  
                   v_monto_cuota,    v_fecha_cuota,  v_fecha_pag,
                   v_status_cuota,   vv_nombre,      vv_descripcion,
                   v_monto_otorgado;
   END IF;

   IF v_numcte IS NULL THEN
      LET v_numcte = " ";
   ELSE
         SELECT numcte, TRIM(NVL(razon_social, " ")) ||
                TRIM(NVL(apell_paterno," ")) || " " ||
                TRIM(NVL(apell_materno,' ')) || " " ||
                TRIM(NVL(nombre1," ")) || " " ||
                TRIM(NVL(nombre2," "))
         INTO v_numcte, v_cliente
         FROM si_cliente
         WHERE numcte = v_numcte;
         LET vg_cliente = TRIM (v_numcte) || " " || v_cliente;
   END IF;

   IF v_num_producto IS NULL THEN
      LET v_num_producto = " ";
   END IF;

   SELECT monto_otorgado INTO v_monto_otorgado
   FROM sd_maesdos
   WHERE empresa = pempresa and num_credito = v_num_credito;

   SELECT nombre INTO vv_nombre
   FROM si_ejecut
   WHERE si_ejecut.ejecutivo = v_ejecutivo;

   IF vv_nombre IS NULL THEN
      LET vv_nombre = " ";
   ELSE
      LET vv_nombre = TRIM (v_ejecutivo) || " " ||
          TRIM (vv_nombre);
   END IF;

   SELECT descripcion INTO vv_descripcion
   FROM si_divisas
   WHERE empresa = pempresa and divisa = v_divisa;

   SELECT nombre_prod INTO v_descripcion
   FROM sd_definicion
   WHERE empresa = pempresa and num_producto = v_num_producto;

   FOREACH
      SELECT monto_cuota,fecha_cuota,fecha_pag,status_cuota
      INTO v_monto_cuota,v_fecha_cuota,v_fecha_pag,v_status_cuota
      FROM sd_paginter
      WHERE empresa = pempresa and num_credito = v_num_credito
      ORDER BY 2

      IF v_fecha_cuota IS NULL OR
         v_fecha_cuota = " " THEN
         LET v_fecha_cuota = " ";
      END IF;

      IF v_fecha_pag IS NULL OR
         v_fecha_pag = " " THEN
         LET v_fecha_pag = " ";
      END IF;

      LET v_ciclo = v_ciclo + 1;

      IF v_ciclo <= pnum_pago THEN
         CONTINUE FOREACH;
      END IF;


      IF v_monto_cuota IS NULL THEN
         LET v_monto_cuota = 0;
      END IF;
      IF v_monto_cuota1 IS NULL THEN
         LET v_monto_cuota1 = 0;
      END IF;

      LET v_monto_cuotas = v_monto_cuota + v_monto_cuota1;

      IF vg_cliente IS NULL THEN
         LET vg_cliente = " ";
      END IF;

            RETURN cod_ret,          vg_cliente,     v_fecha_apertura,
                   v_fecha_vencim,   v_descripcion,  
                   v_monto_cuota,    v_fecha_cuota,  v_fecha_pag,
                   v_status_cuota,   vv_nombre,      vv_descripcion,
                   v_monto_otorgado
      WITH RESUME;
      LET v_conta = v_conta + 1;
   END FOREACH;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".spsd_cupones(p_credito varchar(20), 
					 p_empresa char(3),
				         p_cuota   SMALLINT,
					 p_cupones SMALLINT)
       returning char(3),       varchar(20),   date,
                 varchar(20),   varchar(60),   varchar(4),
                 integer,       decimal(18,2), decimal(18,2),
                 decimal(18,2), decimal(18,2), date,
                 date,          decimal(18,2), decimal(18,2),
		 decimal(18,2), decimal(18,2), decimal(18,2);
   --##### Define variables de Retorno #####
   define r_empresa   char(3);
   define r_credito   varchar(20);
   define r_fecha     date;
   define r_numcte    varchar(20);
   define r_cliente   varchar(60);
   define r_tipocred  varchar(4);
   define r_cuota     integer;
   define r_seguro    decimal(18,2);
   define r_recargo   decimal(18,2);
   define r_monto1    decimal(18,2);
   define r_monto2    decimal(18,2);
   define r_vento     date;
   define r_gracia    date;
   define r_acciones  decimal(18,2);
   --##### Define variables de Trabajo #####
   define v_status    char(1);
   define v_cuantas   integer;
   define v_monto     decimal(18,2);
   define v_tasamora  decimal(9,6);
   define v_gracia    smallint;
   define v_capcuo    decimal(18,2);
   define v_intcuo    decimal(18,2);
   define v_balance   decimal(18,2);
   define v_fechaa    DATE;
   define v_mtoori    DECIMAL(18,2);
   define v_vueltas   SMALLINT;
   DEFINE ax_fecha    DATE;


   --###### Inicializa Variables ###########
   let r_empresa   = p_empresa;
   let r_credito   = p_credito;
   let r_fecha     = '';
   let v_fechaa     = '';
   let r_numcte    = '';
   let r_cliente   = '';
   let r_tipocred  = '';
   let r_cuota     = 0;
   let r_seguro    = 0;
   let r_recargo   = 0;
   let r_monto1    = 0;
   let r_monto2    = 0;
   let r_vento     = '';
   let r_gracia    = '';
   let v_status    = '';
   let v_monto     = 0;
   let v_gracia    = 0;
   LET v_capcuo    = 0;
   LET v_intcuo    = 0;
   LET v_balance   = 0;
   let r_acciones  = 0;
   LET v_vueltas   = 0;




   --###### Indica cuantos cupones se van a imprimir ###########
   --es 12 porque es mensual, pero en caso de variar unicamente
   --se cambia este dato por el numero de cupones a imprimir
   --de acuerdo al periodo
   let v_cuantas    = p_cupones;

   --###### Obtiene la fecha y las de vento ###########
   {SELECT NVL(valor,"0") 
     INTO r_acciones
     FROM sd_param
    WHERE cod_param = "72"
      AND empresa = p_empresa;}

   --###### Obtiene la fecha y las de vento ###########
   select fecha_hoy
   into   r_fecha
   from   sd_fechas
   where  empresa = p_empresa;

   --###### Obtiene datos del cliente y credito ###########
   select c.numcte, c.num_producto, nvl(c.tasa_moratorios, 0),
          nvl(p.gracia_calc_mora, 0), fecha_apertura, por_acciones
   into   r_numcte, r_tipocred,     v_tasamora,
          v_gracia, v_fechaa, r_acciones
   from   sd_maecred c, sd_definicion p
   where  c.empresa = p.empresa
   and    c.num_producto = p.num_producto
   and    c.empresa = r_empresa
   and    c.num_credito = r_credito;

   select decode(nvl(razon_social,''),
          '', trim(nvl(nombre1,'')) ||' '||
              trim(nvl(nombre2,'')) ||' '||
              trim(nvl(apell_paterno,'')) ||' '||
              trim(nvl(apell_materno,'')),
          trim(razon_social))
   into   r_cliente
   from   bdinteg:si_cliente
   where  empresa = r_empresa
   and    numcte = r_numcte;

   -- ##### Determina la Cuota en la que debe iniciar #########
   let r_cuota = 0;
   FOREACH SELECT fecha_cuota 
	     INTO ax_fecha
	     FROM sd_pagocapit
	    WHERE num_credito = r_credito

	LET r_cuota = r_cuota +1;
	IF r_cuota = p_cuota THEN
		EXIT FOREACH;
	END IF
   END FOREACH

   --###### Obtiene recibos a Reportar ###########
   foreach select fecha_cuota, status_cuota
           into   r_vento, v_status
           from   sd_pagocapit
           where  empresa = r_empresa
           and    num_credito = r_credito
	   and    fecha_cuota >= ax_fecha
           order  by fecha_cuota
      --###### Inicializa Variables ###########
      --let r_cuota = r_cuota + 1;

      --###### verifica si esta pagada o no ###########
--      if v_status = '1' then
	 LET v_vueltas = v_vueltas + 1;
         --###### Obtiene datos de capital ###########
         select sum(monto_cuota - monto_real_pag)
         into   r_monto1
         from   sd_pagocapit
         where  empresa = r_empresa
         and    num_credito = r_credito
         and    fecha_cuota = r_vento;
	 LET v_capcuo = r_monto1;

 	SELECT COUNT(*) INTO r_cuota
	  FROM sd_pagocapit
	 WHERE num_credito = r_credito
	   AND fecha_cuota <= r_vento;
         --###### Obtiene datos de intereses ###########
         select nvl(sum(monto_cuota - monto_real_pag), 0)
         into   v_monto
         from   sd_paginter
         where  empresa = r_empresa
         and    num_credito = r_credito
         and    fecha_cuota = r_vento;
	 LET v_intcuo = v_monto;


	 SELECT (SELECT SUM(monto_cuota-monto_real_pag)
		   FROM sd_pagocapit
		  WHERE num_credito = r_credito)
		 - (SELECT SUM(monto_cuota-monto_real_pag )
				    FROM sd_pagocapit 
				   WHERE num_credito = r_credito
				     AND fecha_cuota <= r_vento),
		monto_otorgado
	   INTO v_balance, v_mtoori
	   FROM sd_maesdos
	  WHERE num_credito = r_credito;
				   

         --###### Obtiene datos de seguros ###########
         select nvl(sum(monto_com), 0)
         into   r_seguro
         from   sd_detcomi
         where  empresa = r_empresa
         and    num_credito = r_credito
         and    fecha_alta = r_vento
         and    estado_com = 'P';

         --###### Obtiene moratorios ###########
         let r_recargo = (r_monto1 + v_monto) * (v_tasamora / 100);

         --###### Calcula los totales ###########
         let r_monto1 = r_monto1 + v_monto + r_seguro + r_acciones;
         let r_monto2 = r_monto1 + r_recargo;

         --###### Obtiene fecha de gracia ###########
         let r_gracia = r_vento + v_gracia;

         --###### Regresa los datos del Cupon ###########
         return r_empresa, r_credito, v_fechaa,
                r_numcte,  r_cliente, r_tipocred,
                r_cuota,   r_seguro,  r_recargo,
                r_monto1,  r_monto2,  r_vento,
                r_gracia,  r_acciones,v_balance,
		v_capcuo,  v_intcuo,  v_mtoori   with resume;
         if mod(v_vueltas,v_cuantas) = 0 then
            exit foreach;
         end if;
--      end if;
   end foreach;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".sp_mesejec( pempresa char(3) )
returning char(20) ,
	  integer ,
	  char(60) ,
	  char(160) ,
	  char(2) ,
	  char(4) ,
	  char(20) ,
	  char(2) ,
	  decimal(14,2) ,
	  decimal(14,2) ,
	  decimal(14,2) ,
	  decimal(14,2) ,
	  date ,
	  date ,
	  date ,
	  integer ,
	  integer ,
	  char(40) ;

define r_numcte char(20);
define r_tpo integer;
define r_nombre char(60);
define r_titulo char(160);
define r_siglas char(2);
define r_producto char(4);
define r_cuenta char(20);
define r_status char(2);
define r_saldo decimal(14,2);
define r_interes decimal(14,2);
define r_pago decimal(14,2);
define r_saldo_original decimal(14,2);
define r_fecha_apertura date;
define r_fecha_pago date;
define r_fecha_vencimiento date;
define r_plazos_total integer;
define r_plazos_pagados integer;
define r_producto_nombre char(40);

define v_nombre1 char(15);
define v_nombre2 char(15);
define v_apell_paterno char(15);
define v_apell_materno char(15);
define v_tasa char(8);
define v_secuencia integer;



SET ISOLATION TO DIRTY READ;

foreach
    select a.numcte, a.tpo, a.titulo,
	   b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno
    into r_numcte, r_tpo, r_titulo,
	 v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno
    from si_repmesejec a
    inner join si_cliente b
    on a.empresa = b.empresa
    and a.numcte = b.numcte
    order by a.numcte
    let r_nombre = TRIM(v_nombre1)||' '||TRIM(V_apell_paterno)||' '||TRIM(v_apell_materno);
    foreach
	select "SD", a.num_credito, a.num_producto, a.status_cred,
	sdo_cap_insoluto + sdo_exig_int + sdo_moratorio
	into r_siglas, r_cuenta, r_producto, r_status, r_saldo
	from sd_maecred a
	inner join sd_maesdos b
	on a.empresa = b.empresa
	and a.num_credito = b.num_credito
	where  a.empresa = pempresa
	and a.numcte = r_numcte
--	union all
--	select "SC", cuenta, producto, status_cta, sdo_actual
--	from bdicheq:sc_maechq
--	where empresa = pempresa and num_cte = r_numcte
--	union all
--	select "SV", cuenta, cod_instrum, status_cta, capital
--	from bdinvers:sv_maeinv
--	where empresa = pempresa and num_cte = r_numcte and status_cta <> "4"
	order by 2
	if r_status = "2" then
	    let r_saldo = 0;
	end if;
	
	let r_interes = 0.0;
	let r_pago = 0.0;
	let r_saldo_original = 0.0;
	let r_fecha_apertura = null;
	let r_fecha_pago = null;
	let r_fecha_vencimiento = null;
	let r_plazos_total = 0;
	let r_plazos_pagados = 0;
	let r_producto_nombre = ' ';

	if r_siglas = "SC" then
		select a.tasa 
		into v_tasa
		from bdicheq:sc_producto a
		where a.empresa = pempresa
		and a.producto = r_producto;
		select a.valor	
		into r_interes
		from bdinteg:si_fechavalor a
		where a.empresa = pempresa
		and a.tasa = v_tasa;
		if r_interes is null then
			let r_interes = 0.0;
		end if;
	elif r_siglas = "SV" then
		select max(a.secuencia)
		into v_secuencia
		from bdinvers:sv_maeinv a
		where a.empresa = pempresa 
		and a.cuenta = r_cuenta;
		select a.tasa + a.sobretasa, a.capital
		into r_interes, r_saldo_original
		from bdinvers:sv_maeinv a
		where a.empresa = pempresa
		and a.secuencia = v_secuencia
		and a.cuenta = r_cuenta;
		if r_interes is null then
			let r_interes = 0.0;
		end if;
		if r_saldo_original is null then
			let r_saldo_original = 0.0;
		end if;
	elif r_siglas = "SD" then
		select round(a.tasa_interes,2)
		into r_interes
		from bdicred:sd_maecred a
		where a.empresa = pempresa
		and num_credito = r_cuenta;
		if r_interes is null then
			let r_interes = 0.0;
		end if;
		select min(a.monto_cuota + b.monto_cuota)
		into r_pago
		from bdicred:sd_pagocapit a, bdicred:sd_paginter b
		where a.empresa = pempresa
		and a.empresa = b.empresa
		and a.num_credito = r_cuenta
		and a.num_credito = b.num_credito
		and a.fecha_cuota = b.fecha_cuota;
		if r_pago is null then
			let r_pago = 0.0;
		end if;
		select a.monto_otorgado
		into r_saldo_original
		from bdicred:sd_maesdos a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta;
		if r_saldo_original is null then
			let r_saldo_original = 0.0;
		end if;
		select a.fecha_apertura, a.fecha_vencim, a.plazo
		into r_fecha_apertura, r_fecha_vencimiento, r_plazos_total
		from bdicred:sd_maecred a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta;
		select min(fecha_cuota)
		into r_fecha_pago
		from bdicred:sd_pagocapit a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta
		and a.status_cuota in ('1','2','7');
		select count(*)
		into r_plazos_pagados
		from bdicred:sd_pagocapit a
		where a.empresa = pempresa
		and a.num_credito = r_cuenta
		and a.fecha_cuota < r_fecha_pago;

		select a.nombre_prod
		into r_producto_nombre
		from bdicred:sd_definicion a
		where a.empresa = pempresa
		and a.num_producto = r_producto;
	end if;
	return r_numcte, r_tpo, r_nombre, r_titulo, r_siglas, r_producto, r_cuenta, r_status, r_saldo, 
	       r_interes, r_pago, r_saldo_original,
	       r_fecha_apertura, r_fecha_pago, r_fecha_vencimiento, r_plazos_total, r_plazos_pagados, r_producto_nombre  with resume;
    end foreach;
end foreach;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_calcdia(param smallint)
RETURNING VARCHAR(10);


DEFINE params VARCHAR(10);

	LET params = "0";

	IF param = 1 THEN
		LET params = "UNO";
        END IF

	IF param = 2 THEN
		LET params = "DOS";
        END IF


	IF param = 3 THEN
		LET params = "TRES";
        END IF

	RETURN params;

END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".genmovto()
       returning char(3),char(20);

define vcodret char(3);
define vnumcte char(20);
define vcuenta char(20);
define vtranret char(4);
define i integer;

foreach
   select cuenta into vcuenta
      from sc_maechq
      where numcte between '101018051' and '101068064'
   call abono('001','001','victorlp','0202','0202','victorlp18353904',
              vcuenta,0,100,100,0,0,0,'01')
        returning vcodret;
   if vcodret <> "000" then
      return vcodret,vnumcte;
   end if
   call cargo ('001','001','victorlp','0221','0202','victorlp18353904',
               vcuenta, 222, 100,'01')
        returning vcodret,vtranret;
   if vcodret <> "000" then
      return vcodret,vnumcte;
   end if
end foreach
return vcodret,vnumcte;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".genclientes()
       returning char(3),char(20);

define vcodret char(3);
define vnumcte char(20);
define i integer;



for i = 1 to 5000000
    call ctefisico('001','A','','001','victorlp','01','1',
       'PATERNO'||i,'MATERNO','NOMBRE'||i,'NOMBREPRUEBA','',
       '00','000','001','000','000','','12',
       '01/01/1960','','001','1','','S','1','001','M','','A','2432',
       '8975646','12','423423','423423','9495','','','','01','00','',
       '','','','0','-    -    -','0','00','PROPIA',3,'E',0)
       returning vcodret,vnumcte;
    if vcodret <> "000" then
       return vcodret,vnumcte;
    end if
    call ingresos('001',vnumcte,'1','1','TITULAR','S',
                  'JH','87879987','HJKHJ','7','JHHJ','JHGJGHJH',20000)
       returning vcodret;
    if vcodret <> "000" then
       return vcodret,vnumcte;
    end if
    call Direcciones('001','A',vnumcte,1,'1','A','A','00601','A','001',
                   '01','001','12231','164554564','564564564',' ','01','001','0001')
       returning vcodret;
    if vcodret <> "000" then
       return vcodret,vnumcte;
    end if
end for
return vcodret,vnumcte;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".codpos4()
       returning char(5);

define vcodret	char(5);
define vcodigo_pos char(5);
define vcodigo_pos4 char(5);

let vcodret = "000";
let vcodigo_pos = "";
let vcodigo_pos4 = "";

foreach
      select codigo_pos into vcodigo_pos4
      from si_codigopostal
      where length(trim(codigo_pos)) = 4
      let vcodigo_pos = "0"||trim(vcodigo_pos4);
      update si_codigopostal set codigo_pos = vcodigo_pos
      where codigo_pos = vcodigo_pos4;

end foreach
    return vcodret;
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".conscedsol(pEmpresa LIKE si_cliente.EMPRESA,
	                    pNumCte  LIKE si_cliente.NUMCTE,
                            pNumCred varchar(20))
RETURNING CHAR(20),
          CHAR(6),
          CHAR(80);

   DEFINE lContador INTEGER;
   DEFINE pCredito  varchar(20);
   DEFINE pCodRet varchar(6);
   DEFINE pMensaje varchar(80);

   LET lContador = 0;
   LET pCredito = '';
   LET pCodRet = ' ';
   LET pMensaje = ' ';

   FOREACH
      SELECT num_credito
      INTO   pCredito
      FROM   bdicred:sd_maecred  --ss_solicitudes
      WHERE  empresa = pEmpresa
      AND    numcte  = pNumCte
   --   AND    status_solicitud NOT IN ('AT', 'AP','RE')
      LET pCodret  = '00000';
      LET pMensaje = 'Paso de solicitudes';
      RETURN pCredito,
             pCodRet,
             pMensaje
   WITH RESUME;
   LET lContador = lContador + 1;
   END FOREACH;
   LET pCredito = '';
   LET pCodRet = ' ';
   LET pMensaje = ' ';

      RETURN pCredito,
             pCodRet,
             pMensaje;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE  PROCEDURE "informix".cta_cont(v_empresa    CHAR(3),
                          v_ccmayor    CHAR(4),
                          v_ccsub      CHAR(2),
                          v_ccsubsub   CHAR(2),
                          v_ccssubsub  CHAR(2),
                          v_ccsssubsub CHAR(2),
                          v_sector     CHAR(2))
   RETURNING CHAR(5);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret CHAR(5);
   DEFINE v_cont  SMALLINT;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret = "";
   LET v_cont  = 0;



   IF v_ccmayor    IS NULL OR v_ccmayor    = " " OR
      v_ccsub      IS NULL OR v_ccsub      = " " OR
      v_ccsubsub   IS NULL OR v_ccsubsub   = " " OR
      v_ccssubsub  IS NULL OR v_ccssubsub  = " " OR
      v_ccsssubsub IS NULL OR v_ccsssubsub = " " OR
      v_sector     IS NULL OR v_sector     = " " THEN
      LET cod_ret = "110";
      RETURN cod_ret;
   END IF

-- ***************************************************************************
-- Inicia busqueda de cuenta del maestro contable
-- ***************************************************************************
   FOREACH
      SELECT COUNT(*) INTO v_cont FROM bdinteg:si_catalog
      WHERE ccmayor    = v_ccmayor
      AND   ccsub      = v_ccsub
      AND   ccsubsub   = v_ccsubsub
      AND   ccssubsub  = v_ccssubsub
      AND   ccsssubsub = v_ccsssubsub
      AND   sector     = v_sector
   END FOREACH;

   IF v_cont = 0 THEN
      LET cod_ret = "601";
   ELSE
      LET cod_ret = "000";
   END IF

   RETURN cod_ret;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".uniprod_qryb()
RETURNING CHAR(5);

DEFINE v_cod_ret CHAR(5);
DEFINE sql_err   INTEGER;
LET v_cod_ret = '00000';
LET sql_err   = 0;

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_cod_ret = sql_err;
         RETURN v_cod_ret;
      END IF
   END EXCEPTION;

 	DROP TABLE axel;
END;

RETURN v_cod_ret;
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".confirma_sp(pempresa char(3),
                                        p_rastreo char(16))
RETURNING char(5);

-- ************* Definicion de Variables ************************************

DEFINE v_codret char(5);
--DEFINE sql_err  integer;

-- **************************************************************************

LET v_codret = "000";

BEGIN
/*
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET v_codret = sql_err;
         RETURN v_codret;
      END IF
   END EXCEPTION;
*/
-- ************************************************************************
/*
UPDATE bdispeua:sp_pagoenviar SET status_envio = " "
 WHERE clave_rastreo = p_rastreo;
*/
RETURN v_codret;

-- ***********************************************************************
END
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".spobtenfechasinteg()
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    VARCHAR(64),        -- DescripcionError
    DATE,               -- Fecha Hoy
    DATE,               -- Fecha Anterior
    DATE,               -- Fecha Proxima
    DATE,               -- Fecha inicio mes natural
    DATE,               -- Fecha inicio mes habil
    DATE,               -- Fecha fin mes natural
    DATE;               -- Fecha fin mes habil
        
-- ***************************************************************************
-- spObtFechasinteg
-- Version              1.0.0
-- Obejtivo:            Proporcionar fechas de si_fechas
--                      Operaciones Inusuales
-- Supuestos:           Ninguno
-- Valores de Entrada:  Ninguno
-- Valores de Regreso:  
--                      VARCHAR(5)          CodigoRetorno     
--                      VARCHAR(64)         DescripcionError  
--                      DATE                Fecha Hoy
--                      DATE                Fecha Anterior
--                      DATE                Fecha Proxima
--                      DATE                Fecha inicio mes natural
--                      DATE                Fecha inicio mes habil
--                      DATE                Fecha fin mes natural
--                      DATE                Fecha fin mes habil
-- Creado por:          Alejandro Rueda Sanchez   
-- ModIFicado por:      
-- Ultima ModIFicacion: Agosto-2006
--                      Creación de SPL
-- ***************************************************************************

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet              CHAR(5);

DEFINE dFechaHoy            DATE;
DEFINE dFechaAnt            DATE;
DEFINE dProxFecha           DATE;
DEFINE dPriDiaNaturalMes    DATE;
DEFINE dPriDiaHabilMes      DATE;
DEFINE dUltDiaNaturalMes    DATE;
DEFINE dUltDiaHabilMes      DATE;




BEGIN
    ON EXCEPTION 
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
        END IF;
    END EXCEPTION;

    --// ********************************************************************
    --// Obtiene fechas a partir del sistema Integral (Central de Bsi)
    SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes,
	pri_hab_mes, ult_dia_mes, ult_hab_mes
    INTO dFechaHoy, dFechaAnt, dProxFecha, dPriDiaNaturalMes,
    	dPrIDiaHabilMes, dUltDiaNaturalMes, dUltDiaHabilMes
    FROM bdinteg:si_fechas;

    IF  dFechaHoy = '' OR dFechaHoy IS NULL THEN
	LET cCodret ='224';
	LET cVarDataErr ='No hay fecha registrada para hoy';
        RETURN cCodret, cVarDataErr, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
    END IF;        

    RETURN '000', '', dFechaHoy, dFechaAnt, dProxFecha, dPriDiaNaturalMes,
            dPriDiaHabilMes, dUltDiaNaturalMes,dUltDiaHabilMes;
END
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".spobtentipocambio(pFecha date,pDivisa char(2))
	returning char(5),money(12,7);

define sql_err integer;
define v_preco money(12,7);
define cod_ret char(5);
let v_preco = 0;
begin
   on exception set sql_err
      if sql_err <> 0 then
	 let cod_ret = sql_err;
         return cod_ret,v_preco;
      end if
   end exception;

let cod_ret="000";

SELECT precio_compra
	INTO v_preco
	FROM si_tpcambio
	WHERE divisa = pDivisa AND clase_tpcambio="O"
	AND fecha_tpcambio = pFecha;

if v_preco is null then
	let cod_ret="100";
end if;
return cod_ret,v_preco;
end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

create procedure "informix".spobtentipocambiohist(pFecha date,pDivisa char(2))
	returning char(5),money(12,7);

define sql_err integer;
define v_preco money(12,7);
define cod_ret char(5);
let v_preco = 0;
begin
   on exception set sql_err
      if sql_err <> 0 then
	 let cod_ret = sql_err;
         return cod_ret,v_preco;
      end if
   end exception;

let cod_ret="000";

SELECT precio_compra
	INTO v_preco
	FROM si_histdiv
	WHERE divisa = pDivisa AND clase_tpcambio="O"
	AND fecha_tc = pFecha;

if v_preco is null then
	let cod_ret="100";
end if;
return cod_ret,v_preco;
end
end procedure
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".ctefisicomel(pempresa CHAR(3),
                          pfuncion CHAR(1),
			  pnumcte CHAR(20),
			  psucursal CHAR(4))
  RETURNING CHAR(5),CHAR(20);

DEFINE vcodret CHAR(5);
DEFINE vtutor,vnumcte CHAR(20);
DEFINE vfecha DATE;
DEFINE vsignumcte INT;
DEFINE vtppersona CHAR(2);
DEFINE vexiste CHAR(1);
DEFINE vcont SMALLINT;
DEFINE vesfisica CHAR(1);
DEFINE vlongitud,vlong_cte SMALLINT;
DEFINE vsucursal CHAR(4);
define vdiferencia,i smallint;


LET vcodret = "000";
LET vnumcte = " ";
LET vsucursal = psucursal;


IF pnumcte IS NULL OR pnumcte = " " THEN
   SELECT valor
     INTO vlong_cte
     FROM si_param
    WHERE cod_param = 7
      AND empresa = pempresa;

   IF vlong_cte IS NULL THEN
      LET vcodret="105";
      RETURN vcodret,vnumcte;
   ELSE
      SELECT valor INTO vsignumcte
         FROM si_param
         WHERE empresa = pempresa and cod_param = 6;
      if vsignumcte is null then
         let vsignumcte = 1;
      end if
      LET vnumcte=vsignumcte;
      LET vsignumcte=vsignumcte + 1;
      UPDATE si_param
         SET (valor) = (vsignumcte)
         WHERE empresa = pempresa and cod_param = 6;
      let vdiferencia = vlong_cte - length(vnumcte);
      if vdiferencia > 0 then
         for i = 1 to vdiferencia
             let vnumcte = "0" || vnumcte;
         end for;
      end if
   END IF;
ELSE
   LET vnumcte = pnumcte;
END IF;
RETURN vcodret,vnumcte;
END PROCEDURE
DOCUMENT
"Alta, Baja y/o Cambio de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".splvalfecha(pCodPais 	  CHAR(3),
			    		pPriDiaNaturalMes DATE,
					pDiasBloque       integer)
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque

-- ***************************************************************************
-- splvalfecha          
-- Version              1.0.0
-- Obejtivo:            Calcula la fecha del mes actual FechaIniMes + DiasBloque - 1
--                      donde Días bloque son número de días hábiles del mes
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima ModIFicacion: Agosto-2006
--                      Creación de SPL
-- ***************************************************************************

DEFINE cVarDataErr      VARCHAR(64);
DEFINE iSqlErr          INTEGER;
DEFINE iSamErr          INTEGER;

DEFINE cCodRet          CHAR(5);
DEFINE dFechaActual        DATE;
DEFINE i,j              INTEGER;
DEFINE siFeriado        INTEGER;




BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret, cVarDataErr;
        END IF;
    END EXCEPTION;

    --// ********************************************************************
    --// Calcula dia por dia si es habil, hasta completar el bloque


    LET i = 0;
    LET j = 0;	
    WHILE i <= pDiasBloque 
	LET dFechaActual = pPriDiaNaturalMes + j;
	LET siFeriado = 0;

	IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
           SELECT COUNT(*) 
	     INTO siFeriado       
	    FROM si_feriado
	    WHERE fecha = dFechaActual
	     AND pais = pCodPais and laborable = "N";
	   IF siFeriado IS NULL OR siFeriado = 0 THEN
	     LET i = i + 1;
	   END IF;
	END IF;
	LET j = j + 1;
    END WHILE


   RETURN '000',dFechaActual;
END
END PROCEDURE
DOCUMENT
"MODIFICO : Manuel Hern ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".determina_lincred_tc(o_empresa CHAR(3),
                                      o_numsol  CHAR(20),
			              o_cte_nvo CHAR(1))


RETURNING CHAR(5), MONEY(14,2);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret          CHAR(3);
DEFINE vsqlerr           INTEGER;
DEFINE v_tasa            DECIMAL(9,6);
DEFINE v_factor	         CHAR(1);
DEFINE v_sobretasa       DECIMAL(9,6);
DEFINE v_porc_linea      DECIMAL(6,3);
DEFINE v_salariomin      DECIMAL(14,2);
DEFINE v_porcsalmin      DECIMAL(6,3);
DEFINE v_paramfactor     SMALLINT;
DEFINE v_ingreso         MONEY(14,2);
DEFINE v_situacion       DECIMAL(6,3);
DEFINE v_meseshist       SMALLINT;
DEFINE v_comproboingreso SMALLINT;
DEFINE v_porcpermitido   DECIMAL(6,3);
DEFINE v_mesespermitido  SMALLINT;
DEFINE v_capacidad       MONEY(14,2);
DEFINE v_linea      	 MONEY(14,2);
DEFINE v_factor_calc     DECIMAL(21,10);
DEFINE v_compromisos     MONEY(14,2);
DEFINE v_lintienda       MONEY(14,2);
DEFINE v_plazo		 SMALLINT;
DEFINE v_elevado         DECIMAL(21,6);
DEFINE v_moneypaso       MONEY(14,2);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_plazo      = 12;
LET v_linea      = 0;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, v_linea;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


	-- **************************************************
	-- Extrae Parametros para la definicion de la Linea *
	-- **************************************************
	SELECT valor INTO v_porcpermitido -- Porcentaje de Situacion de pago
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 307;

	IF v_porcpermitido IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	SELECT valor INTO v_mesespermitido -- Meses de Historia base
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 308;

	IF v_mesespermitido IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	SELECT valor INTO v_salariomin -- Salario Minimo Base
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 303;

	IF v_salariomin IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	-- *******************************************
	-- Extrae Porcentaje de ingresos del cliente *
	-- *******************************************
	IF o_cte_nvo = 1 THEN
	    LET v_paramfactor = 302; -- Cliente Nuevo
	ELSE
	    LET v_paramfactor = 301; -- Cliente No Nuevo
	END IF

	SELECT valor / 100 INTO v_porcsalmin
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = v_paramfactor;

	IF v_porcsalmin IS NULL THEN
		LET scod_ret = "100";
		RETURN scod_ret, v_linea;
	END IF

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************
        SELECT ingreso_mensual, situacion_pago, meses_historia , pago_minimo,
	       linea_tienda
	  INTO v_ingreso, v_situacion, v_meseshist, v_compromisos, v_lintienda
          FROM ss_resum_scor_fin
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;

        IF v_ingreso IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

        IF v_compromisos IS NULL THEN
		LET v_compromisos = 0;
        END IF

        IF v_situacion IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

        IF v_meseshist IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

        IF v_lintienda IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************

	SELECT COUNT(*) INTO v_comproboingreso
	  FROM ss_detalle_scoring
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol
	   AND seccion = 2
	   AND grupo = 14
	   AND elemento = 1;

	IF v_comproboingreso IS NULL THEN
		LET v_comproboingreso = 0;
	END IF

        -- *************************************
        -- Extrae Tasa de interes del producto *
        -- *************************************

	SELECT valor, c.factor_sobretasa, c.sobretasa
	  INTO v_tasa, v_factor, v_sobretasa
	  FROM ss_solicitudes a, bdinteg:si_fechavalor b,
	       bdicred:sd_definicion c
	 WHERE a.empresa = o_empresa
	   AND a.num_solicitud = o_numsol
	   AND c.empresa = a.empresa
	   AND c.num_producto = a.num_producto
	   AND b.empresa = c.empresa
	   AND b.tasa = c.cod_tasa_base
           AND b.fecha = (select max(fecha) from bdinteg:si_fechavalor s
                          where s.tasa = c.cod_tasa_base);




        IF v_tasa IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

	IF v_factor = "+" THEN
		LET v_tasa = v_tasa + v_sobretasa;
	ELIF v_factor = "-" THEN
		LET v_tasa = v_tasa - v_sobretasa;
	ELIF v_factor = "*" THEN
		LET v_tasa = v_tasa * v_sobretasa;
	ELSE
		LET v_tasa = v_tasa / v_sobretasa;
	END IF

        -- **********************************************************
        -- Extrae Porcentajes de Otorgamiento de Linea de acuerdo a *
        -- a caracteristicas del cliente			    *
        -- **********************************************************
	IF  v_situacion >= v_porcpermitido
        AND v_meseshist >= v_mesespermitido THEN
		SELECT valor / 100 INTO v_porc_linea
		  FROM ss_param
		 WHERE empresa = o_empresa
		   AND secuencia = 304;
	ELSE

		IF  v_situacion >= v_porcpermitido
        	AND v_meseshist <= v_mesespermitido
        	AND v_comproboingreso = 1 THEN
			SELECT valor / 100 INTO v_porc_linea
		  	  FROM ss_param
		 	 WHERE empresa = o_empresa
		   	   AND secuencia = 305;
		ELSE
			SELECT valor / 100 INTO v_porc_linea
		  	  FROM ss_param
		 	 WHERE empresa = o_empresa
		   	   AND secuencia = 306;
		END IF
	END IF
        IF v_porc_linea IS NULL THEN
		LET scod_ret = "100";
                RETURN scod_ret, v_linea;
        END IF

	-- ************************************
	-- Inicia Proceso de Calculo de Linea *
	-- ************************************
	LET v_capacidad = ((v_ingreso * v_porcsalmin) - v_compromisos)
			  * v_porc_linea;

	LET v_factor_calc=POW(ROUND(((v_tasa/100)/v_plazo)+1,10),(v_plazo*-1));
	LET v_factor_calc = 1-(v_factor_calc);
	LET v_linea =(v_capacidad * v_factor_calc) / ((v_tasa/100)/v_plazo);

        -- **********************************************************
        -- Valida Porcentajes de Otorgamiento de Linea de acuerdo a *
        -- a caracteristicas del cliente                            *
        -- **********************************************************
        IF  v_situacion >= v_porcpermitido
        AND v_meseshist >= v_mesespermitido THEN
                SELECT valor / 100 INTO v_porc_linea
                  FROM ss_param
                 WHERE empresa = o_empresa
                   AND secuencia = 304;

	        IF v_porc_linea IS NULL THEN
        	        LET scod_ret = "100";
                	RETURN scod_ret, v_linea;
        	END IF

		LET v_moneypaso = v_linea * v_porc_linea;
		IF v_lintienda < v_moneypaso THEN
			LET v_linea = v_lintienda;
			LET v_moneypaso = v_salariomin * 15;
			IF v_linea > v_moneypaso THEN
				LET v_linea = v_moneypaso;
			END IF
		ELSE
			LET v_linea = v_moneypaso;
			LET v_moneypaso = v_salariomin * 15;
			IF v_linea > v_moneypaso THEN
				LET v_linea = v_moneypaso;
			END IF
		END IF
        ELSE
                IF  v_situacion >= v_porcpermitido
                AND v_meseshist <= v_mesespermitido
                AND v_comproboingreso = 1 THEN
                        SELECT valor / 100 INTO v_porc_linea
                          FROM ss_param
                         WHERE empresa = o_empresa
                           AND secuencia = 305;

        	     IF v_porc_linea IS NULL THEN
                	LET scod_ret = "100";
                	RETURN scod_ret, v_linea;
        	     END IF

                     IF (v_linea * v_porc_linea) > (v_salariomin * 4) THEN
                   	LET v_linea  = v_salariomin * 4;
                     ELSE
                        LET v_linea = v_linea * v_porc_linea;
                     END IF

                ELSE
                     SELECT valor / 100 INTO v_porc_linea
                       FROM ss_param
                      WHERE empresa = o_empresa
                        AND secuencia = 306;

                     IF v_porc_linea IS NULL THEN
                          LET scod_ret = "100";
                          RETURN scod_ret, v_linea;
                     END IF

                     IF (v_linea * v_porc_linea) > (v_salariomin * 2) THEN
                   	 LET v_linea  = v_salariomin * 2;
                     ELSE
                         LET v_linea = v_linea * v_porc_linea;
                     END IF
                END IF
        END IF


	LET v_linea = ROUND(v_linea,-1);

END
	RETURN scod_ret, v_linea;

END PROCEDURE
;