create procedure "informix".spsd_morosos(p_empresa char(3), p_fecha date)
       returning char(3),       date,          date,
                 varchar(20),   varchar(20),   varchar(60),
                 char(2),       varchar(4),    date,
                 date,          decimal(18,2), decimal(18,2),
                 integer,       integer,       decimal(18,2),
                 decimal(18,2), decimal(18,2), decimal(18,2),
                 decimal(18,2),
                 varchar(60),   varchar(10),   decimal(18,2);
   --##### Define variables de Retorno #####
   define r_empresa   char(3);
   define r_fecha     date;
   define r_fechadia  date;
   define r_credito   varchar(20);
   define r_numcte    varchar(20);
   define r_cliente   varchar(60);
   define r_cvemora   varchar(2);
   define r_producto  varchar(4);
   define r_fechaaper date;
   define r_fechapago date;
   define r_prestamo  decimal(18,2);
   define r_atraso    decimal(18,2);
   define r_plazo     integer;
   define r_vencidas  integer;
   define r_2meses    decimal(18,2);
   define r_7meses    decimal(18,2);
   define r_13meses   decimal(18,2);
   define r_haberes   decimal(18,2);
   define r_riesgo    decimal(18,2);
   define r_descprod  varchar(64);
   define r_cualmes   varchar(10);
   define r_insoluto  decimal(18,2);
   --##### Define variables de Trabajo #####
   define v_param     integer;
   define v_dias      integer;
   define v_fecadeudo date;
   define v_insoluto  decimal(18,2);
   define v_haberes   decimal(18,2);

   define v_numdeud   varchar(20);
   define v_deudor    varchar(60);
   define v_fecvento2 date;
   define v_ultimo    date;
   define v_numcte    varchar(20);
   define v_cliente   varchar(60);
   define ax_meses_venc INTEGER;

   --###### Inicializa Variables ###########
   let r_empresa   = p_empresa;
   let r_fecha     = p_fecha;
   let r_fechadia  = '';
   let r_credito   = '';
   let r_numcte    = '';
   let r_cliente   = '';
   let r_cvemora   = '';
   let r_producto  = '';
   let r_fechaaper = '';
   let r_fechapago = '';
   let r_prestamo  = 0;
   let r_atraso    = 0;
   let r_plazo     = 0;
   let r_vencidas  = 0;
   let r_2meses    = 0;
   let r_7meses    = 0;
   let r_13meses   = 0;
   let r_haberes   = 0;
   let r_riesgo    = 0;
   let v_param     = 0;
   let v_dias      = 0;
   let v_insoluto  = 0;
   let v_haberes   = 0;
   let r_descprod  = '';
   let r_cualmes   = '';
   let r_insoluto  = 0;
   let ax_meses_venc =0;

   --###### Define y Obtiene el parametro de dias ###########
   let v_param = 64;

   select valor
   into   v_dias
   from   sd_param
   where  empresa = p_empresa
   and    cod_param = v_param;

   --###### Obtiene la fecha del dia ###########
   select fecha_hoy
   into   r_fechadia
   from   sd_fechas
   where  empresa = p_empresa;

   --###### LA FECHA DE PROCESO IGUAL A LA FECHA DEL DIA ###########
   --###### en caso de ser parametro quitar esta linea ###########
   let r_fecha = r_fechadia;

   --###### LA FECHA DE ADEUDOS ###########
   let v_fecadeudo = r_fecha - v_dias;

   --###### Obtiene creditos a Reportar ###########
   foreach select trim(a.num_credito)
           into   r_credito
           from   sd_pagocapit as a, sd_maecred as b, outer sd_marcpro as c
           where  a.empresa = p_empresa
           and    a.fecha_cuota <= v_fecadeudo
           and    a.status_cuota in('7','2','1')
           and    a.empresa = b.empresa
           and    trim(a.num_credito) = trim(b.num_credito)
--           and    trim(b.num_producto) <> '420'
           and    a.empresa = c.empresa
           and    ((trim(a.num_credito) = trim(c.num_credito)) or ( c.num_credito is null ))
           and    b.status_cred not in ('CC')
           group  by 1
           order  by 1
      --###### Inicializa Variables por Vuelta ###########
      let r_numcte    = '';
      let r_cliente   = '';
      let r_cvemora   = '';
      let r_producto  = '';
      let r_fechaaper = '';
      let r_fechapago = '';
      let r_prestamo  = 0;
      let r_atraso    = 0;
      let r_plazo     = 0;
      let r_vencidas  = 0;
      let r_2meses    = 0;
      let r_7meses    = 0;
      let r_13meses   = 0;
      let r_haberes   = 0;
      let r_riesgo    = 0;
      let r_descprod  = '';
      let r_cualmes   = '';
      let r_insoluto  = 0;

      --###### Obtiene datos del credito ###########
      select c.numcte,      c.num_producto,   c.fecha_apertura,
             c.plazo,       s.monto_otorgado, s.sdo_cap_insoluto, 
             trim(c.num_producto) || ' ' || (d.nombre_prod)
      into   r_numcte,      r_producto,       r_fechaaper,
             r_plazo,       r_prestamo,       v_insoluto, 
             r_descprod
      from   sd_maecred c, sd_maesdos s, sd_definicion d
      where  c.empresa      = s.empresa
      and    c.num_credito  = s.num_credito
      and    c.empresa      = d.empresa
      and    c.num_producto = d.num_producto
      and    c.num_credito  = r_credito
      and    c.empresa      = p_empresa;

      --###### Obtiene datos del cliente ###########
      select decode(nvl(razon_social,''),
             '', trim(nvl(nombre1,'')) ||' '||
                 trim(nvl(nombre2,'')) ||' '||
                 trim(nvl(apell_paterno,'')) ||' '||
                 trim(nvl(apell_materno,'')),
             trim(razon_social))
      into   r_cliente
      from   bdinteg:si_cliente
      where  empresa = p_empresa
      and    numcte = r_numcte;

      --###### Obtiene estatus mora ###########
      select nvl(cod_status_mora,'')
      into   r_cvemora
      from   sd_marcpro
      where  num_credito = r_credito
      and    empresa     = p_empresa;

      --###### Obtiene datos de atraso y Plazos ###########
      select sum(monto_cuota - monto_real_pag),
             count(*)
      into   r_atraso, r_vencidas
      from   sd_pagocapit
      where  empresa = p_empresa
      and    num_credito = r_credito
      and    fecha_cuota <= r_fecha
      and    status_cuota in('7', '2', '1');
      let v_dias = 0;
      select nvl(sum(monto_cuota - monto_real_pag), 0),
             count(*)
      into   r_riesgo, v_dias
      from   sd_paginter
      where  empresa = p_empresa
      and    num_credito = r_credito
      and    fecha_cuota <= r_fecha
      and    status_cuota in('7','2','1');
      if v_dias is not null then
         let r_atraso = r_atraso + r_riesgo;
         if v_dias > r_vencidas then
              let r_vencidas = v_dias;
         end if;
      end if;
      let r_riesgo = 0;

      --###### Obtiene datos de los meses ###########
      SELECT TRUNC((fecha_hoy - fecha_cuota)/30) INTO ax_meses_venc
        FROM sd_pagocapit a, sd_fechas b
       WHERE num_credito = r_credito
         AND fecha_cuota =(SELECT MIN(fecha_cuota) FROM sd_pagocapit
                   WHERE num_credito = r_credito
                     AND status_cuota IN ("7","2"));

      if ax_meses_venc >= 13 then
         let r_13meses = v_insoluto;
         let r_cualmes = '13 Meses';
      elif ax_meses_venc >= 7 then
         let r_7meses = v_insoluto;
         let r_cualmes = '07 Meses';
      else
         let r_2meses = v_insoluto;
         let r_cualmes = '02 Meses';
      end if;
      let r_insoluto  = v_insoluto;

      --###### Obtiene datos de haberes ###########
      let v_haberes = 0;
      select nvl(sum(sdo_actual), 0)
      into   v_haberes
      from   bdicheq:sc_maechq
      where  empresa = r_empresa
      and    num_cte = r_numcte;
      if v_haberes is null then
         let v_haberes = 0;
      end if;
      let r_haberes = v_haberes;
      select nvl(sum(capital), 0)
      into   v_haberes
      from   bdinvers:sv_maeinv
      where  empresa = r_empresa
      and    num_cte = r_numcte
      and    status_cta in('1', '3');
      if v_haberes is null then
         let v_haberes = 0;
      end if;
      let r_haberes = r_haberes + v_haberes;

      if v_insoluto < r_haberes then
         continue foreach;
         let r_haberes = v_insoluto;
      end if;

      --###### Obtiene datos de riesgo ###########
      let r_riesgo = v_insoluto - r_haberes;

      --###### Obtiene datos de ultimo pago o vencido ###########
      select nvl(max(fecha_cuota), '')
      into   r_fechapago
      from   sd_pagocapit
      where  empresa = p_empresa
      and    num_credito = r_credito
      and    fecha_cuota <= r_fecha
      and    status_cuota in ('5');

      if r_fechapago is null or r_fechapago = '' then
       let r_fechapago = r_fechaaper;
      end if

      --###### Regresa los datos del Principal ###########
      return r_empresa,   r_fecha,    r_fechadia,
             r_credito,   r_numcte,   r_cliente,
             r_cvemora,   r_producto, r_fechaaper,
             r_fechapago, r_prestamo, r_atraso,
             r_plazo,     r_vencidas, r_2meses,
             r_7meses,    r_13meses,  r_haberes,
             r_riesgo,
             r_descprod,  r_cualmes,  r_insoluto
             with resume;
   end foreach;
end procedure;