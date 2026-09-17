CREATE PROCEDURE "informix".sp_rechaza_solicitud(p_empresa char(3), 
                                                 p_usuario char(10), 
                                                 p_numsolicitud char(20),
                                                 p_statussolant char(2),
                                                 p_statussolnvo char(2),
                                                 p_causa_sol char(3),
                                                 p_comentario varchar(255,1),
                                                 p_revisioncac smallint,
                                                 p_montolinea_ant money,
                                                 p_montolinea_nvo money  )
    returning char(5);

-- Control de cambios
--------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo
-- Descripción: Se agrega parámetro de entrada para recibir la causa del estatus
--              a actualizar en la solicitud. Este parámetro se enviará a su vez 
--              como dato de entrada en la ejecución del sp_actualiza_status_sol

-- Fecha: 22-04-2010
-- Petición: RQM 09 171
--------------------------------------------------------------------------------

    --V2 30/JUL/09
    define cod_ret char(5);
    define sql_err integer;
    define scod_ret6 varchar(6);
    define v_secuencia smallint;
    define v_numcte char(20);
    --define v_mensaje varchar(80);

    let cod_ret = "00000";
    let v_secuencia = 0;
    --SET DEBUG FILE TO "rechaza_solicitud.out";
    --TRACE ON;
BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret;
      end if
   end exception;

   --SYSTEM 'echo ---- INICIA sp_rechaza_solicitud -----' || cod_ret || '> ' || 'rechaza_solicitud.log';

   LET p_causa_sol = TRIM(NVL(p_causa_sol,""));

   execute procedure bdisolic:sp_actualiza_status_sol (p_empresa, p_usuario, p_numsolicitud, p_statussolnvo,p_causa_sol,p_comentario) 
   Into scod_ret6;          

   --SYSTEM 'echo Ejecuto sp_actualiza_status_sol ' || scod_ret6 || '>> ' || 'rechaza_solicitud.log';

    If scod_ret6 <> '000000' then
        If length(trim(scod_ret6)) = 6 then  --No cabe en la long actual de la var cod_ret
            LET cod_ret = '00017'; --Nota: 00017 Solo si la long del error generado es de 6 caracteres
        Else
            LET cod_ret = trim(scod_ret6);
        End if;
    End if;

   Update bdisolic:ss_autorizacion
   set revision_cac = p_revisioncac, status_solicitud = p_statussolnvo
   where empresa = p_empresa
   and ejecutivo_auto = p_usuario
   and num_solicitud = p_numsolicitud
   and status_solicitud = p_statussolant
   and fecha_entrada = today;

   --SYSTEM 'echo Termina Update a ss_autorizacion >> rechaza_solicitud.log';
   --calcular la secuencia
   select max(secuencia+1) into v_secuencia 
   from bdisolic:ss_autorizacion_especial
   where empresa = p_empresa
     and num_solicitud = p_numsolicitud;
   if v_secuencia is null then
      let v_secuencia = 1;
   end if

   select numcte into v_numcte from bdisolic:ss_solicitudes where num_solicitud = p_numsolicitud;

   --SYSTEM 'echo Valores: ' || p_empresa || ' ' || p_numsolicitud || ' ' || v_numcte || ' ' || v_secuencia || ' ' || p_comentario || ' ' || p_montolinea_ant || ' ' ||p_montolinea_nvo || ' ' ||p_statussolant || ' ' || p_statussolnvo || ' ' ||p_usuario ||'>> ' || 'rechaza_solicitud.log';

   insert into bdisolic:ss_autorizacion_especial(empresa,num_solicitud,numcte,secuencia,comentario,causa_solicitud,montolinea_ant,
                                                 montolinea_nvo,status_ant,status_nvo, usuario_modif,fecha_modif)
   values(p_empresa, p_numsolicitud, v_numcte, v_secuencia, p_comentario, p_causa_sol,p_montolinea_ant, p_montolinea_nvo, p_statussolant,
          p_statussolnvo, p_usuario, today);

   

END;

return cod_ret;
end procedure;