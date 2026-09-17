CREATE procedure "informix".sp_inicializa_os(pfechasolicitud date, pnum_solicitud varchar(20))
    returning char(5);
    
    define cod_ret char(5);
    define sql_err integer;
    let cod_ret = "00000";

BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret;
      end if
   end exception;

    delete from bdisolic:"informix".ss_osclientesupervisar
    where empresa = '001'
    and fechasolicitud = pfechasolicitud
    and num_solicitud = pnum_solicitud
    and clave = ' ';

    update bdisolic:"informix".ss_solicitud_os
    set status = 'S'
    where empresa = '001'
    and fecha_solicitud = pfechasolicitud
    and num_solicitud = pnum_solicitud;

    update bdisolic:"informix".ss_solicitudes
    set status_solicitud = 'EE'
    where empresa = '001' 
    and fecha_insert = pfechasolicitud
    and num_solicitud = pnum_solicitud;
END;

return cod_ret;
end procedure;