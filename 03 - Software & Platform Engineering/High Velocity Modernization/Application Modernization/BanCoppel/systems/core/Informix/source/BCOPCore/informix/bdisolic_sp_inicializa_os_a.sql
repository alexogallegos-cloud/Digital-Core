CREATE procedure "informix".sp_inicializa_os_a(pNum_Solicitud varchar(20), pSecuencia integer)
    returning char(5);
    
    define cod_ret char(5);
    define sql_err integer;
    define vMaxfecha date;
    define vEmpresa char(3);

    let cod_ret = '00000';
    let vEmpresa = '001';
-- Autor: Marco A. Campos
-- Fecha: 17-06-2010

BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret;
      end if
   end exception;

    delete bdisolic:"informix".ss_osclientesupervisar
    where empresa = vEmpresa
    and secuencia = pSecuencia
    and num_solicitud = pNum_Solicitud;

    select max(fecha_solicitud) into vMaxfecha
    from bdisolic:"informix".ss_solicitud_os
    where num_solicitud = pNum_Solicitud;

    update bdisolic:"informix".ss_solicitud_os
    set status = 'S'
    where empresa = vEmpresa
    and fecha_solicitud = vMaxfecha
    and num_solicitud = pNum_Solicitud;

    update bdisolic:"informix".ss_solicitudes
    set status_solicitud = 'EE'
    where empresa = vEmpresa 
    and num_solicitud = pNum_Solicitud;

END;

return cod_ret;
end procedure;