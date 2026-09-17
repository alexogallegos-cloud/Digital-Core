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
   let r_cuota = 1;
   FOREACH SELECT fecha_cuota 
	     INTO ax_fecha
	     FROM sd_pagocapit
	    WHERE num_credito = r_credito
	    ORDER BY fecha_cuota

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


	 SELECT TRUNC((SELECT SUM(monto_cuota-monto_real_pag)
		   FROM sd_pagocapit
		  WHERE num_credito = r_credito)
		 - (SELECT SUM(monto_cuota-monto_real_pag )
				    FROM sd_pagocapit 
				   WHERE num_credito = r_credito
				     AND fecha_cuota <= r_vento),2),
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
end procedure;