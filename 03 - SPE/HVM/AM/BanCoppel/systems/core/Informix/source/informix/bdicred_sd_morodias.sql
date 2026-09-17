create procedure "informix".sd_morodias(p_empresa char(3), p_idias integer, p_fdias integer)
       returning char(3) ,       varchar(20) ,   varchar (20) ,
                 char(4) ,   varchar(60) , varchar(18) , smallint ,
		 date , money(14,2) , money(18,2) , 
		 varchar(19) , integer , integer , date ,
		 money(14,2) , money(14,2) , money(14,2) ,
		 money(14,2) , money(14,2) ,
		 money(14,2) , money(14,2) , money(14,2) ,
		 money(14,2) , money(14,2) ,
		 money(14,2) , money(14,2) , money(14,2) ,
		 money(14,2) , money(14,2) , money(14,2) ;
--    return r_empresa, r_numcte, r_numcredito,
--	     r_numproducto, r_nombre, r_ctetelefono, r_tienecodeudor,
--           r_fechaapertura, r_montoapertura, r_montopago, 
--	     r_plazosapertura, r_cuotaspagadas, r_fechaultimopago,
--           r_diasenmora
--           with resume;
   --##### Define variables de Retorno #####
   define r_empresa   char(3);
   define r_numcte       varchar(20);
   define r_numcredito   varchar(20);
   define r_numproducto char(4);
   define r_nombre varchar(60);
   define r_fechaultimopago date;
   define r_fechaapertura date;
   define r_montoapertura money(14,2);
   define r_montopago     money(14,2);
   define r_cuotaspagadas integer;
   define r_plazosapertura varchar(19);
   define r_diasenmora    integer;
   define r_ctetelefono   varchar(18);
   define r_tienecodeudor smallint;

   define v_codret char(5);
   define sql_err integer;
   define x_nrocuotas smallint;
   define x_capvig money(14,2);
   define x_intvig money(14,2);
   define x_comvig money(14,2);
   define x_segvig money(14,2);
   define x_totvig money(14,2);
   define x_capven money(14,2);
   define x_intven money(14,2);
   define x_segven money(14,2);
   define x_morven money(14,2);
   define x_totven money(14,2);
   define x_adedia money(14,2);
   define x_mtooto money(14,2);
   define x_adetot money(14,2);
   define x_status char(2);
   
   define r_captot money(14,2);
   define r_inttot money(14,2);
   define r_segtot money(14,2);
   define r_intdia money(14,2);
   
   --##### Define variables de Trabajo #####
   define v_idias integer;
   define v_fdias integer;
   define v_fecha date;
   define v_fechainicio date;
   define v_fechafinal date;
   define v_fecha_nopagada_min date;
   define v_cod_status_mora char(2);
   define v_gracia_calc_mora integer;
   define v_fechaultimopago date;
   define v_cuotaspagadas integer;
   define v_sdo_cap_insoluto money(14,2);
   --###### Inicializa Variables ###########
   let r_empresa = p_empresa;
   let r_numcte = '';
   let r_numcredito  = '';
   let r_numproducto  = '';
   let r_fechaultimopago = 0;
   let r_fechaapertura  = 0;
   let r_montoapertura  = 0.0;
   let r_montopago  = 0.0;
   let r_cuotaspagadas = 0;
   let r_plazosapertura = 0;
   let r_ctetelefono = '';
   let r_tienecodeudor = 0;



   if p_idias > p_fdias then
     let v_idias = p_fdias;
     let v_fdias = p_idias;
   else
     let v_idias = p_idias;
     let v_fdias = p_fdias;
   end if;

   --###### Obtiene la fecha y las de vento ###########
   select fecha_hoy
   into   v_fecha
   from   sd_fechas
   where  empresa = p_empresa;
   
   let v_fechainicio = v_fecha - v_fdias;
   let v_fechafinal = v_fecha - v_idias;
   
   --###### Obtiene creditos a Reportar ###########
   foreach select trim(a.num_credito), MIN(a.fecha_cuota), b.cod_status_mora
   into   r_numcredito, v_fecha_nopagada_min, v_cod_status_mora
   from sd_pagocapit as a, outer sd_marcpro as b
   where a.empresa = p_empresa
   and a.fecha_cuota between v_fechainicio and v_fechafinal
   --and a.status_cuota in('7','2','1')
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
    if v_fecha_nopagada_min is null then
	continue foreach;
    end if;
      
    let r_diasenmora = v_fecha - v_fecha_nopagada_min;

    select a.gracia_calc_mora
    into   v_gracia_calc_mora
    from   sd_definicion as a, sd_maecred as b
    where  a.empresa = p_empresa
    and    a.empresa = b.empresa
    and    a.num_producto = b.num_producto
    and    trim(b.num_credito) = r_numcredito;

    if v_gracia_calc_mora >= r_diasenmora then
	continue foreach;
    end if;

    --###### Inicializa Variables ###########
    let r_empresa = p_empresa;
    let r_numcte = '';
    let r_numproducto  = '';
    let r_fechaultimopago = 0;
    let r_fechaapertura  = 0;
    let r_montoapertura  = 0.0;
    let r_montopago  = 0.0;
    let r_cuotaspagadas = 0;
    let r_plazosapertura = 0;
    let r_ctetelefono = '';
    let r_tienecodeudor = 0;

    --##### Obtiene datos generales del credito
    select num_producto, plazo || periodo_plazo, fecha_apertura,
	   trim(numcte)
    into   r_numproducto, r_plazosapertura, r_fechaapertura,
	   r_numcte
    from   sd_maecred  
    where  empresa = p_empresa and trim(num_credito) = r_numcredito;
    
    select monto_otorgado, sdo_cap_insoluto
    into r_montoapertura, v_sdo_cap_insoluto
    from sd_maesdos
    where empresa = p_empresa and trim(num_credito) = r_numcredito;
    
    --###### Obtiene datos del cliente ###########
    select decode(nvl(razon_social,''),
             '', trim(nvl(nombre1,'')) ||' '||
                 trim(nvl(nombre2,'')) ||' '||
                 trim(nvl(apell_paterno,'')) ||' '||
                 trim(nvl(apell_materno,'')),
	         trim(razon_social))
    into   r_nombre
    from   bdinteg:si_cliente
    where  empresa = p_empresa
    and    numcte = r_numcte;
      
    --###### Obtiene datos de ultimo pago o vencido ###########
    let r_fechaultimopago = '';
    select max(fecha_pago), count(*)
    into   r_fechaultimopago, r_cuotaspagadas
    from   sd_pagocapit
    where  empresa = p_empresa
    and    num_credito = r_numcredito
    and    fecha_cuota <= v_fecha;
    if r_fechaultimopago is null or r_fechaultimopago = '' then
	select max(fecha_cuota), count(*)
        into   r_fechaultimopago, r_cuotaspagadas
        from   sd_pagocapit
        where  empresa = p_empresa
        and    num_credito = r_numcredito
        and    fecha_cuota <= v_fecha
        and    status_cuota in ('5');
    end if;
    let v_fechaultimopago = '';
    select max(fecha_pag), count(*)
    into   v_fechaultimopago, v_cuotaspagadas
    from   sd_paginter
    where  empresa = p_empresa
    and    num_credito = r_numcredito
    and    fecha_cuota <= v_fecha
    and    status_cuota in('5');
    if v_fechaultimopago is not null and v_fechaultimopago <> '' then
	if r_fechaultimopago > v_fechaultimopago then
   	    let r_fechaultimopago = v_fechaultimopago;
	    let r_cuotaspagadas = v_cuotaspagadas;
     end if;
    end if;
    let r_fechaultimopago = v_fecha_nopagada_min;

    --###### Optiene monot del pago
    select MAX(a.monto_cuota + b.monto_cuota)
    into r_montopago
    from sd_pagocapit as a, sd_paginter as b
    where a.empresa = p_empresa
    and a.num_credito = b.num_credito
    and a.fecha_cuota = b.fecha_cuota
    and a.num_credito = r_numcredito;

    --##### Optiene Telefono
   /* select telefono1
    into r_ctetelefono
    from bdinteg:si_direcciones
    where numcte = r_numcte;*/
	select  telefono 
		into  r_ctetelefono
	from bdinteg:si_telefonos_actual 
	where numcte = r_numcte 
		and tipo_tel = 1 and cofetel ='V'
		and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = r_numcte and tipo_tel = 1 and cofetel ='V');
    
    --#####Optiene # Codeudores
    select count(*)
    into r_tienecodeudor
    from bdigaran:sg_aval
    where empresa = p_empresa
    and num_credito = r_numcredito;
    
    call conadecred(p_empresa, r_numcredito) returning
    v_codret, x_nrocuotas, x_capvig, x_intvig, x_comvig, x_segvig, x_totvig,
    x_capven, x_intven, x_segven, x_morven, x_totven, x_adedia, x_mtooto,
    x_adetot, x_status;
    
    let r_captot = x_capvig + x_capven;
    let r_inttot = x_intvig + x_intven;
    let r_segtot = x_segvig + x_segven;
    let r_intdia = x_adetot - v_sdo_cap_insoluto - x_intven - x_segven - x_morven;
    
    return r_empresa, r_numcte, r_numcredito,
	   r_numproducto, r_nombre, r_ctetelefono, r_tienecodeudor,
           r_fechaapertura, r_montoapertura, r_montopago, 
	   r_plazosapertura, r_cuotaspagadas,
           r_diasenmora, r_fechaultimopago,
	   x_capvig, x_intvig, x_comvig, x_segvig, x_totvig,
	   x_capven, x_intven, x_morven, x_segven, x_totven,
	   r_captot, r_inttot, r_segtot, x_adedia, r_intdia,
	   x_adetot
           with resume;
   end foreach;
end procedure;