create procedure "informix".spsd_nomorosos(p_empresa char(3), p_fecha date)
returning 	char(20) ,
		char(4) ,
		char(20) ,
		char(2) ,
		date ,
		date ,
		decimal(9,6) ,
		char(2) ,
		char(15) ,
		char(15) ,
		char(15) ,
		char(15) ,
		char(60) ,
		char(40) ,
		decimal(18,2) ,
		decimal(18,2) ,
		decimal(18,2) ,
		date ,
		DECIMAL(18,2) ;

define r_num_credito LIKE bdicred:sd_maecred.num_credito;
define r_num_producto LIKE bdicred:sd_maecred.num_producto; 
define r_numcte LIKE bdicred:sd_maecred.numcte; 
define r_status_cred LIKE bdicred:sd_maecred.status_cred;
define r_fecha_apertura LIKE bdicred:sd_maecred.fecha_apertura;
define r_fecha_vencim LIKE bdicred:sd_maecred.fecha_vencim; 
define r_tasa_interes LIKE bdicred:sd_maecred.tasa_interes;
define r_tpo_persona LIKE bdinteg:si_cliente.tpo_persona;
define r_apell_paterno LIKE bdinteg:si_cliente.apell_paterno;
define r_apell_materno LIKE bdinteg:si_cliente.apell_materno;
define r_nombre1 LIKE bdinteg:si_cliente.nombre1;
define r_nombre2 LIKE bdinteg:si_cliente.nombre2;
define r_razon_social LIKE bdinteg:si_cliente.razon_social;
define r_nombre_prod LIKE bdicred:sd_definicion.nombre_prod;
define r_sdo_moratorio LIKE bdicred:sd_maesdos.sdo_moratorio; 
define r_sdo_cap_insoluto LIKE bdicred:sd_maesdos.sdo_cap_insoluto;
define r_monto_otorgado LIKE bdicred:sd_maesdos.monto_otorgado;
define r_fecha_hoy LIKE bdicred:sd_fechas.fecha_hoy; 
define r_monto_haberes DECIMAL(18,2);

define v_monto_haberes DECIMAL(18,2);
		

foreach
SELECT
   a.num_credito, a.num_producto, a.numcte, a.status_cred, a.fecha_apertura, a.fecha_vencim, a.tasa_interes,
   e.tpo_persona, e.apell_paterno, e.apell_materno, e.nombre1, e.nombre2, e.razon_social,
   b.nombre_prod,
   c.sdo_moratorio, c.sdo_cap_insoluto, c.monto_otorgado,
   d.fecha_hoy
INTO
	r_num_credito, r_num_producto, r_numcte, r_status_cred, r_fecha_apertura, r_fecha_vencim, r_tasa_interes,
	r_tpo_persona, r_apell_paterno, r_apell_materno, r_nombre1, r_nombre2, r_razon_social,
	r_nombre_prod,
	r_sdo_moratorio, r_sdo_cap_insoluto, r_monto_otorgado,
	r_fecha_hoy
FROM
   (((sd_maecred a INNER JOIN sd_definicion b 
		   ON a.empresa = b.empresa 
		   AND a.num_producto = b.num_producto)       
		   INNER JOIN sd_maesdos c 
		   ON a.empresa = c.empresa 
		   AND a.num_credito = c.num_credito)       
		   INNER JOIN sd_fechas d 
		   ON a.empresa = d.empresa)       
		   INNER JOIN si_cliente e 
		   ON a.empresa = e.empresa 
		   AND a.numcte = e.numcte
WHERE
a.empresa = p_empresa
--   (a.status_cred <> 'FC' AND
--   a.status_cred <> 'FF' AND
--   a.status_cred <> 'CC') AND
--   c.sdo_moratorio = 0 AND
--   a.num_producto <> '420'
ORDER BY
   a.num_producto ASC,
   a.num_credito ASC
	
      --###### Obtiene datos de haberes ###########
      let v_monto_haberes = 0;
      select nvl(sum(sdo_actual), 0)
      into   v_monto_haberes
      from   bdicheq:sc_maechq
      where  empresa = p_empresa
      and    num_cte = r_numcte;
      if v_monto_haberes is null then
         let v_monto_haberes = 0;
      end if;
      let r_monto_haberes = v_monto_haberes;
      select nvl(sum(capital), 0)
      into   v_monto_haberes
      from   bdinvers:sv_maeinv
      where  empresa = p_empresa
      and    num_cte = r_numcte
      and    status_cta in('1', '3');
      if v_monto_haberes is null then
         let v_monto_haberes = 0;
      end if;
      let r_monto_haberes = r_monto_haberes + v_monto_haberes;

	return r_num_credito, r_num_producto, r_numcte, r_status_cred, r_fecha_apertura, r_fecha_vencim, r_tasa_interes,
	       r_tpo_persona, r_apell_paterno, r_apell_materno, r_nombre1, r_nombre2, r_razon_social,
	       r_nombre_prod,
	       r_sdo_moratorio, r_sdo_cap_insoluto, r_monto_otorgado, r_fecha_hoy, r_monto_haberes with resume;
end foreach;

end procedure;