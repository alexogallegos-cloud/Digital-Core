create procedure "informix".stcamara()
define cod_ret          char (3);
define v_sucursal       char (3);
define v_tipo_docto     char (2);
define v_banco          char (3);
define v_cuenta         char (10);
define v_num_docto      char (7);
define v_importe        money (14,2);
define v_cve_chq_caja   char (1);
define v_cve_chq_cert   char (1);
define v_cve_giro_banc  char (1);
define v_cve_orden_pago char (1);


select cve_chq_caja, cve_chq_cert, cve_giro_banc, cve_orden_pago
   into v_cve_chq_caja, v_cve_chq_cert, v_cve_giro_banc, v_cve_orden_pago 
   from st_param;

begin work;
-- Lee Documentos de Recibidos a traves de la Camara de Compensacion
foreach 
-- Lee Documentos de sc_detcam que pertenecen a Transferencias 
   select sucursal, tipo_docto, numero_cheque, codigo_bco, numero_cta, importe
      into v_sucursal, v_tipo_docto, v_num_docto, v_banco, v_cuenta, v_importe
      from bdicheq:sc_detcam
      where (tipo_docto = cve_chq_caja or 
             tipo_docto = cve_giro_banc or 
             tipo_docto = cve_orden_pago)
      order by tipo_docto, numero_cheque
      insert into st_camara
         values (v_tipo_docto, v_num_docto, v_banco, 
		 v_cuenta, v_importe, " ", " ");
end foreach;

commit work;

end procedure;