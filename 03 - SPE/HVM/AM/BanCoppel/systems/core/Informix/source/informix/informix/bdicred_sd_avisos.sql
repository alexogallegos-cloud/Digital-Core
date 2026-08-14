create procedure "informix".sd_avisos(p_cual integer, p_empresa char(3), p_dias integer)
       returning char(3),       varchar(20),   date,
                 varchar(20),   varchar(60),   varchar(100),
                 decimal(18,2), decimal(18,2), decimal(18,2),
                 decimal(18,2), integer,       date,
                 varchar(100),  varchar(255),  varchar(255);
   --##### Define variables de Retorno #####
   define r_empresa   char(3);
   define r_credito   varchar(20);
   define r_fecha     date;
   define r_numcte    varchar(20);
   define r_cliente   varchar(60);
   define r_domcte    varchar(100);
   define r_atraso    decimal(18,2);
   define r_recargo   decimal(18,2);
   define r_seguro    decimal(18,2);
   define r_total     decimal(18,2);
   define r_plazo     integer;
   define r_ultimo    date;
   define r_numdeud   varchar(100);
   define r_deudor1   varchar(255);
   define r_deudor2   varchar(255);
   --##### Define variables de Trabajo #####
   define v_numdeud   varchar(20);
   define v_deudor    varchar(60);
   define v_param     integer;
   define v_dias      integer;
   define v_rdias     integer;
   define v_fecvento1 date;
   define v_fecvento2 date;
   define v_ultimo    date;
   define v_numcte    varchar(20);
   define v_cliente   varchar(60);
   define v_status_cred char(2);

   define v_fecvento3 date;
   define v_periodo_plazo char(1);
   define v_gracia_calc_mora smallint;
   define v_cod_status_mora char(2);
   define v_numreg    SMALLINT;
   
   --###### Inicializa Variables ###########
   let r_empresa = p_empresa;
   let r_credito = '';
   let r_fecha   = '';
   let r_numcte  = '';
   let r_cliente = '';
   let r_domcte  = '';
   let r_atraso  = 0;
   let r_recargo = 0;
   let r_seguro  = 0;
   let r_total   = 0;
   let r_plazo   = 0;
   let r_ultimo  = '';
   let r_numdeud = '';
   let r_deudor1  = '';
   let r_deudor2  = '';
   let v_numdeud = '';
   let v_deudor  = '';
   let v_numreg  = 0;


   --###### Define y Obtiene el parametro de dias ###########
   if p_cual = 1 then
      let v_param = 62;
   elif p_cual = 2 then
      let v_param = 63;
   elif p_cual = 3 then
      let v_param = 64;
   elif p_cual = 4 then
      let v_param = 65;
   elif p_cual = 5 then
      let v_param = 66;
   end if;
   
   --select valor
   --into   v_dias
   --from   sd_param
   --where  empresa = p_empresa
   --and    cod_param = v_param;
   
   --###### Coloca los dias que trae de pantalla ###########
   --###### Por que varia desde la pantalla ###########
   let v_dias = p_dias;

   --###### Obtiene la fecha y las de vento ###########
   select fecha_ant, fecha_hoy, fecha_hoy
   into   v_fecvento1, v_fecvento2, r_fecha
   from   sd_fechas
   where  empresa = p_empresa;
   
   let v_fecvento1 = v_fecvento1 - v_dias + 1;
   let v_fecvento2 = v_fecvento2 - v_dias;

   --###### Obtiene creditos a Reportar ###########
   foreach select trim(a.num_credito), MIN(a.fecha_cuota), b.cod_status_mora
   into   r_credito, r_ultimo, v_cod_status_mora
   from sd_pagocapit as a, outer sd_marcpro as b
   where a.empresa = p_empresa
   and a.fecha_cuota = v_fecvento2
   and a.empresa = b.empresa
   and (trim(a.num_credito) = trim(b.num_credito) or b.num_credito is null)
   and a.fecha_cuota in ( 
      select MIN(fecha_cuota)
      from sd_pagocapit
      where empresa = p_empresa
      and num_credito = a.num_credito
      and status_cuota in('7','2','1') 
   )
   group  by 1,3
   order  by 1
      --###### Checa Validez por Marco de Moratorio 
      if v_cod_status_mora in ('07','13','BB','SF','SI') then
         continue foreach;
      end if;
      --###### Checa Validez de Dias de Gracia
      if r_ultimo is null then
        continue foreach;
      end if;
      select a.periodo_plazo, a.gracia_calc_mora, b.status_cred
      into   v_periodo_plazo, v_gracia_calc_mora, v_status_cred
      from   sd_definicion as a, sd_maecred as b
      where  a.empresa = p_empresa
      and    a.empresa = b.empresa
      and    a.num_producto = b.num_producto
      and    trim(b.num_credito) = r_credito;

      if v_gracia_calc_mora >= v_dias then
         continue foreach;
      end if;

      if v_status_cred = 'CC' then
	 continue foreach;
      end if;

      --###### Inicializa Variables ###########
      let r_numcte  = '';
      let r_cliente = '';
      let r_domcte  = '';
      let r_atraso  = 0;
      let r_recargo = 0;
      let r_seguro  = 0;
      let r_total   = 0;
      let r_plazo   = 0;
      let r_numdeud = '';
      let r_deudor1  = '';
      let r_deudor2  = '';
      let v_numdeud = '';
      let v_deudor  = '';

      --###### Obtiene datos del cliente ###########
      select numcte
      into   r_numcte
      from   sd_maecred
      where  empresa = p_empresa
      and    num_credito = r_credito;

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
      
      select decode(trim(calle),
                    'MIGRACION', colonia,
                    trim(calle) || ' ' || colonia)
      into   r_domcte
      from   bdinteg:si_direcciones d
      where  numcte = r_numcte;
      
      --###### Obtiene datos de atraso y Plazos ###########
      select sum(monto_cuota - monto_real_pag),
             count(*)
      into   r_atraso, r_plazo
      from   sd_pagocapit
      where  empresa = p_empresa
      and    num_credito = r_credito
      and    fecha_cuota <= r_fecha
      and    status_cuota in('7', '2', '1');
      let v_rdias = 0;
      select nvl(sum(monto_cuota - monto_real_pag), 0),
             count(*)
      into   r_total, v_rdias
      from   sd_paginter
      where  empresa = p_empresa
      and    num_credito = r_credito
      and    fecha_cuota <= r_fecha
      and    status_cuota in('7','2','1');
      if v_rdias is not null then
         let r_atraso = r_atraso + r_total;
         if v_rdias > r_plazo then
              let r_plazo = v_rdias;
         end if;
      end if;
      let v_rdias = 0;
      let r_total = 0;

      --###### Obtiene datos de recargos ###########
      select nvl(sum(sdo_mora_ordi), 0)
      into   r_recargo
      from   sd_detmora
      where  empresa = p_empresa
      and    num_credito = r_credito
      and    fecha_cuota <= r_fecha;

      --###### Obtiene datos de seguros ###########
      select nvl(sum(monto_com), 0)
      into   r_seguro
      from   sd_detcomi
      where  empresa = p_empresa
      and    num_credito = r_credito
      and    fecha_alta <= r_fecha
      and    estado_com = 'P';

      --###### Obtiene datos de total ###########
      let r_total = r_atraso + r_recargo + r_seguro;
      --###### Obtiene datos de ultimo pago o vencido ###########
      if p_cual > 2 then
         let r_ultimo = '';
--         select max(fecha_cuota)
--         into   r_ultimo
--         from   sd_pagocapit
--         where  empresa = p_empresa
--         and    num_credito = r_credito
--         and    fecha_cuota <= r_fecha;
         if r_ultimo is null or r_ultimo = '' then
            select max(fecha_cuota)
            into   r_ultimo
            from   sd_pagocapit
            where  empresa = p_empresa
            and    num_credito = r_credito
            and    fecha_cuota <= r_fecha
            and    status_cuota in ('5');
         end if;
--         let v_ultimo = '';
--         select max(fecha_pag)
--         into   v_ultimo
--         from   sd_paginter
--         where  empresa = p_empresa
--         and    num_credito = r_credito
--         and    fecha_cuota <= r_fecha
--         and    status_cuota in('5');
--         if v_ultimo is not null and v_ultimo <> '' then
--            if r_ultimo > v_ultimo then
--                 let r_ultimo = v_ultimo;
--            end if;
--         end if;
      end if;

      --###### Obtiene datos codeudores ###########
      if p_cual > 2 then
         foreach select trim(apellido_p)
                 into   v_numdeud
                 from   bdigaran:sg_aval
                 where  empresa = p_empresa
                 and    num_credito = r_credito
            select decode(nvl(razon_social,''),
                   '', trim(nvl(nombre1,'')) ||' '||
                       trim(nvl(nombre2,'')) ||' '||
                       trim(nvl(apell_paterno,'')) ||' '||
                       trim(nvl(apell_materno,'')),
                   trim(razon_social))
            into   v_deudor
            from   bdinteg:si_cliente
            where  empresa = p_empresa
            and    numcte = v_numdeud;

            if length(r_numdeud) <> 0 then
               let r_numdeud = r_numdeud || '__';
            end if;
            let r_numdeud = r_numdeud || v_numdeud;
         
            if length(r_deudor1) + length(v_deudor) > 250 THEN
               if length(r_deudor2) <> 0 then
                  let r_deudor2 = r_deudor2 || '__';
               end if;
               let r_deudor2 = r_deudor2 || v_deudor;
            else
               if length(r_deudor1) <> 0 then
                  let r_deudor1 = r_deudor1 || '__';
               end if;
               let r_deudor1 = r_deudor1 || v_deudor;
            end if;
            let v_numreg = v_numreg + 1;
         end foreach;
      end if;
      --###### Regresa los datos del Principal ###########
      return r_empresa, r_credito, r_fecha,
    	     r_numcte,  r_cliente, r_domcte,
	     r_atraso,  r_recargo, r_seguro,
             r_total,   r_plazo,   r_ultimo,
             r_numdeud, r_deudor1, r_deudor2
             with resume;
      if p_cual <> 1 then
         let v_numcte = r_numcte;
         let v_cliente = r_cliente;
         --###### Obtiene los codeudores para enviar cartas alternas ########
         foreach select trim(apellido_p)
                 into   r_numcte
                 from   bdigaran:sg_aval
                 where  empresa = p_empresa
                 and    num_credito = r_credito
            --###### Inicializa Cliente y Codeudores ###########
            let r_cliente = '';
            let r_domcte = '';
            let r_numdeud = trim(v_numcte);
            let r_deudor1 = trim(v_cliente);
            let r_deudor2 = '';
            --###### Obtiene nombre codeudor a enviar ###########
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
            --###### Obtiene domicilio codeudor a enviar ###########
            select decode(trim(calle),
                          'MIGRACION', colonia,
                          trim(calle) || ' ' || colonia)
            into   r_domcte
            from   bdinteg:si_direcciones d
            where  numcte = r_numcte;

            if p_cual > 2 then
               --###### Obtiene datos codeudores para ccp ###########
               foreach select trim(apellido_p)
                       into   v_numdeud
                       from   bdigaran:sg_aval
                       where  empresa = p_empresa
                       and    num_credito = r_credito
                       and    apellido_p <> r_numcte
                  select decode(nvl(razon_social,''),
                         '', trim(nvl(nombre1,'')) ||' '||
                             trim(nvl(nombre2,'')) ||' '||
                             trim(nvl(apell_paterno,'')) ||' '||
                             trim(nvl(apell_materno,'')),
                         trim(razon_social))
                  into   v_deudor
                  from   bdinteg:si_cliente
                  where  empresa = p_empresa
                  and    numcte = v_numdeud;

                  let r_numdeud = r_numdeud || '__' || v_numdeud;
                  if length(r_deudor1) + length(v_deudor) > 250 THEN
                     if length(r_deudor2) <> 0 then
                        let r_deudor2 = r_deudor2 || '__';
                     end if;
                     let r_deudor2 = r_deudor2 || v_deudor;
                  else
                     let r_deudor1 = r_deudor1 || '__' || v_deudor;
                  end if;
               end foreach;
            end if;
            
            --###### Regresa los datos de los Codeudor ###########
            let v_numreg = v_numreg + 1;
            return r_empresa, r_credito, r_fecha,
                   r_numcte,  r_cliente, r_domcte,
                   r_atraso,  r_recargo, r_seguro,
                   r_total,   r_plazo,   r_ultimo,
                   r_numdeud, r_deudor1, r_deudor2
                   with resume;
         end foreach;
      end if;
      let v_numreg = v_numreg + 1;
   end foreach;
   if v_numreg = 0 then
      let r_empresa = "";
      let r_credito = "";
      return r_empresa, r_credito, r_fecha,
             r_numcte,  r_cliente, r_domcte,
             r_atraso,  r_recargo, r_seguro,
             r_total,   r_plazo,   r_ultimo,
             r_numdeud, r_deudor1, r_deudor2;
   end if
end procedure;