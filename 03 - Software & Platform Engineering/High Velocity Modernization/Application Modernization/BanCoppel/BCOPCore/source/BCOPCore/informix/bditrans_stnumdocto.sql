create procedure "informix".stnumdocto(pempresa char(3),
                            psucursal char(4),
                            ptipodocto char(2))
   returning char(5), int, char(11);

   define v_cod_ret         char(5);
   define v_num_docto       char(11);
   define v_ult_dto         char(10);
   define v_longitud        smallint;
   define v_diferencia      smallint;
   define v_temp            int;
   define v_cve_ccaj        char(2);
   define v_cve_gban        char(2);
   define v_cve_opag        char(2);
   define v_existe_suc      int;
   define v_existen_doctos  int;
   define v_docto_inic      char(7);
   define v_doct_inic       integer;
   define v_doct_fin        integer;
   define v_ult_docto       integer;
   define sql_err, isam_err integer;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************


let v_cod_ret   = "000";
let v_num_docto = "0000000000";
let v_temp      = 0;

   begin
      on exception set sql_err,isam_err
         if sql_err <> 0 or isam_err <> 0 then
            let v_cod_ret = sql_err;
            return v_cod_ret, v_temp, v_num_docto;
         end if;
      end exception;

-- ****************************************************************************
-- Obtiene y valida los Codigos Correspondientes
-- ****************************************************************************
   -- Sucursal Valida
   select count(*) into v_existe_suc 
      from bdinteg:si_sucursales
      where empresa = pempresa and sucursal = psucursal;
   if v_existe_suc = 0 then
      let v_cod_ret = "028";
      return v_cod_ret, v_temp, v_num_docto;
   end if

   -- Tipo de Documento Valido
   select cve_chq_caja, cve_giro_banc, cve_orden_pago
      into v_cve_ccaj, v_cve_gban, v_cve_opag
      from bditrans:st_param
      where empresa = pempresa;
   if ptipodocto != v_cve_ccaj and
      ptipodocto != v_cve_gban and
      ptipodocto != v_cve_opag then
      let v_cod_ret = "035";
      return v_cod_ret, v_temp, v_num_docto;
   end if

   -- Documento Inicial o Siquiente al Asignado
   select docto_inic,docto_final,ult_docto
      into v_doct_inic,v_doct_fin,v_ult_docto
      from st_dotacsuc
      where empresa = pempresa and 
            tipo_docto = ptipodocto and
            sucursal = psucursal;

   if v_ult_docto is null then
      let v_ult_docto = 0;
      let v_cod_ret = "037";
      return v_cod_ret, v_temp, v_num_docto;
   end if
   let v_temp = v_ult_docto + 1;
   if (v_temp < v_doct_inic or v_temp > v_doct_fin) then
      let v_cod_ret = "008";
      return v_cod_ret, v_temp, v_num_docto;
   end if
   update st_dotacsuc
      set (ult_docto) = (v_temp)
      where empresa = pempresa and 
            tipo_docto = ptipodocto and
            sucursal = psucursal;

-- ****************************************************************************
-- Determina el numero de Documento
-- ****************************************************************************
   let v_ult_dto  = v_temp;
   let v_longitud = length(v_ult_dto);
   let v_diferencia = 7 - v_longitud;
   if ptipodocto <> v_cve_opag then
      let psucursal = "000";
   end if
   if v_diferencia = 0 then
      let v_num_docto = psucursal || v_temp;
   elif v_diferencia = 1 then
      let v_num_docto = psucursal || 0 || v_temp;
   elif v_diferencia = 2 then
      let v_num_docto = psucursal || "00" || v_temp;
   elif v_diferencia = 3 then
      let v_num_docto = psucursal || "000" || v_temp;
   elif v_diferencia = 4 then
      let v_num_docto = psucursal || "0000" || v_temp;
   elif v_diferencia = 5 then
      let v_num_docto = psucursal || "00000" || v_temp;
   elif v_diferencia = 6 then
      let v_num_docto = psucursal || "000000" || v_temp;
   elif v_diferencia = 7 then
      let v_num_docto = psucursal || "0000000" || v_temp;
   elif v_diferencia = 8 then
      let v_num_docto = psucursal || "00000000" || v_temp;
   elif v_diferencia = 9 then
      let v_num_docto = psucursal || "000000000" || v_temp;
   end if

-- ****************************************************************************
-- Realiza la actualizacion a la tabla de sucursales
-- ****************************************************************************

end;     --fin del on exception
return v_cod_ret, v_temp, v_num_docto;
end procedure;