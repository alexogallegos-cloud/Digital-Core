create procedure "informix".stcamara2()
define cod_ret           char (3);
define v_tipo_docto      char (2);
define v_tipo_ant        char (2);
define v_tipo_docto2     char (2);
define v_banco           char (3);
define v_cuenta          char (20);
define v_num_docto       char (7);
define v_num_ant         char (7);
define v_num_docto2      char (7);
define v_moneda          char (2);
define v_importe         money (14,2);
define v_fecha_hora      datetime year to second;
define v_plaza           char (3);
define v_usuario         char (8);
define v_sucursal        char (3);
define v_cve_chq_caja    char (2);
define v_cve_chq_cert    char (2);
define v_cve_giro_banc   char (2);
define v_cve_orden_pago  char (2);
define v_cve_liq_cam     char (1);
define v_cve_en_transito char (1);
define v_cve_desbloqueo  char (1);
define v_num_transacc    char (4);
define v_ExisteMtro      smallint;


let v_plaza    = "999";
let v_usuario  = "CECOBAN";
let v_sucursal = "999";
select fecha_hoy into v_fecha_hora
   from bdicent:si_fechas;
let v_fecha_hora = current hour to second;
select cve_chq_caja, cve_chq_cert, cve_giro_banc, 
       cve_orden_pago, cve_liq_cam, cve_en_transito,
       cve_desbloqueo
   into v_cve_chq_caja, v_cve_chq_cert, v_cve_giro_banc, 
	v_cve_orden_pago, v_cve_liq_cam, v_cve_en_transito,
	v_cve_desbloqueo
   from st_param;

begin work;
foreach
   select tipo_docto, num_docto, banco, cuenta, importe
      into v_tipo_docto, v_num_docto, v_banco, v_cuenta, v_importe
      from st_camara
      where causa_dev   = "  " and
            encontrado != "S"
      -- Asigna el Num. de Transaccion por tipo de Docto. *** TEMPORAL
      if v_tipo_docto = v_cve_chq_caja then
	 let v_num_transacc = "0078";
      elif v_tipo_docto = v_cve_chq_cert then
	 let v_num_transacc = "0086";
      elif v_tipo_docto = v_cve_giro_banc then
	 let v_num_transacc = "0092";
      elif v_tipo_docto = v_cve_orden_pago then
	 let v_num_transacc = "5534";
      end if
      -- Verifica contra el Maestro de Transferencias
      select count(*), tipo_docto, num_docto, moneda
         into v_ExisteMtro, v_tipo_docto2, v_num_docto2, v_moneda
         from st_maetrans
	 where tipo_docto       = v_tipo_docto and
	       num_docto        = v_num_docto  and
	      (status_docto     = v_cve_en_transito or
	       status_docto     = v_cve_desbloqueo) and
	      (monto            = v_importe or
	       unidades_divisa  = v_importe);
	 if v_ExisteMtro = 0 then
	    update st_camara
               set encontrado = "N"
	       where tipo_docto = v_tipo_docto and num_docto = v_num_docto;
         else
	    update st_maetrans
	       set (cajero_paga, status_docto, fecha_hora_pago)
	       =   (v_usuario, v_cve_liq_cam, v_fecha_hora)
	       where tipo_docto = v_tipo_docto and num_docto = v_num_docto;
            insert into st_movdia
	       values(v_plaza, v_sucursal, v_usuario,
		      v_fecha_hora, v_num_transacc, v_cve_liq_cam,
		      v_moneda, v_tipo_docto2, v_num_docto2, v_cuenta);
	    update st_camara
               set encontrado = "S"
	       where tipo_docto = v_tipo_docto and num_docto = v_num_docto;
         end if
end foreach;

commit work;

end procedure;