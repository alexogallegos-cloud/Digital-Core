CREATE PROCEDURE "informix".sp_detalleeglobal(desde date, hasta date, eventoA char(15), eventoB char(15) )
returning char(50) as evento, char(50) as folio_csuac, char(50) as estatus,
char(22) as respuesta, char(50) as numero, char(50) as folio_suc, date as fechahora, float as monto, 
char(50) as nombre, char(50) as usuario, char(50) as supervisor;

    define var_aclaracion integer;
    define var_fecha datetime YEAR to SECOND;
    define var_fecha_s datetime YEAR to SECOND;

    define res_evento char(50);
    define res_folio_csuac char(50);
    define res_estatus char(50);
    define res_respuesta char(50);
    define res_numero char(50);
    define res_folio_suc char(50);
    define res_fechahora date;
    define res_monto float;
    define res_nombre char(50);
    define res_usuario char(50);
    define res_supervisor char(50);
	
	LET res_usuario='';
	
--   SET DEBUG FILE TO "/informix/sp_detalleeglobal.out";
--   TRACE ON;
	
	
    begin

        SELECT  aclara.pky_aclaracion, evento.nombre as evento, aclara.folio_csuac, 
                case when esta.nombre = 'ENVIADO_EGLOBAL' 
                then 'Solicitada' 
                else 
                    case when esta.nombre = 'CON_AUTORIZACION_SOLICITUD_EGLOBAL' 
                    then 'Enviada'
                    else
                        case when esta.nombre = 'CON_RESPUESTA_EGLOBAL'
                        then 'Respondida'
                        else
                            case when esta.nombre = 'CON_RECHAZO_SOLICITUD_EGLOBAL'
                            then 'Rechazada'
                            else esta.descripcion
                            end
                        end 
                    end
                end as estatus,
                case when solic.fky_respuesta_e_global is null 
                then 'Sin respuesta E-Global'
                else 'Con respuesta E-Global'
                end as respuesta,
            aclara.num_sucursal as numero, mov.folio_suc, mov.fechahora, mov.monto, tmov.transaccion as nombre
            FROM acl_aclaracion as aclara, acl_estatus_corporativo as esta, 
            acl_movimiento as mov, acl_tipo_movimiento as tmov,
            acl_solicitud_e_global as solic, acl_origen_evento as evento
            , acl_tipo_evento as tipevent--, acl_entrada_bitacora as ebit, acl_resolucion as resol
            where esta.pky_estatus_corporativo = aclara.fky_estatus_corp_analisis
            and esta.nombre in ('ENVIADO_EGLOBAL', 'CON_AUTORIZACION_SOLICITUD_EGLOBAL', 'CON_RESPUESTA_EGLOBAL', 'CON_RECHAZO_SOLICITUD_EGLOBAL')
            and mov.fky_aclaracion = aclara.pky_aclaracion
            --and suc.pky_sucursal = aclara.fky_sucursal
            and mov.fky_aclaracion = aclara.pky_aclaracion
            and tmov.pky_tipo_movimiento = mov.fky_tipo_movimiento
            and solic.pky_solicitud_e_global = mov.fky_solicitud_e_global
            and solic.fecha_envio_archivo_eglobal between desde and hasta
            and tipevent.pky_tipo_evento = aclara.fky_tipo_evento
            and evento.pky_origen_evento = tipevent.fky_origen_evento
            and evento.nombre in (eventoA, eventoB)
            order by aclara.pky_aclaracion
         INTO temp temp_solicitudes
         WITH NO LOG;

        foreach
            select pky_aclaracion, evento, folio_csuac, estatus, respuesta, 
                   numero, folio_suc, fechahora, 
                   monto, nombre
            into var_aclaracion, res_evento, res_folio_csuac, res_estatus, res_respuesta,
                 res_numero, res_folio_suc, res_fechahora, 
                 res_monto, res_nombre
            from temp_solicitudes

	 select usuario.nombre
            into res_usuario
            from acl_entrada_bitacora as ebit, acl_resolucion as resol,
            acl_usuario as usuario
            where
            resol.nombre = 'solicitudEGlobal'
            and ebit.fky_accion = resol.pky_resolucion
            and fky_aclaracion = var_aclaracion   -- pky de aclaracion
            and ebit.fechahora = ( select max(ebit.fechahora)         
            from acl_entrada_bitacora as ebit, acl_resolucion as resol,
            acl_usuario as usuario
            where
            resol.nombre = 'solicitudEGlobal'
            and ebit.fky_accion = resol.pky_resolucion
            and fky_aclaracion = var_aclaracion  --pky de aclaracion
            and usuario.pky_usuario = ebit.fky_usuario)	-- maxima fecha de entrada bitacora
            and usuario.pky_usuario = ebit.fky_usuario;
            --termina analista		
			
			
/*
            --  Esta parte es para el analista 
            select max(ebit.fechahora)
            into var_fecha
            from acl_entrada_bitacora as ebit, acl_resolucion as resol,
            acl_usuario as usuario
            where
            resol.nombre = 'solicitudEGlobal'
            and ebit.fky_accion = resol.pky_resolucion
            and fky_aclaracion = var_aclaracion  --pky de aclaracion
            and usuario.pky_usuario = ebit.fky_usuario;
            
            select usuario.nombre
            into res_usuario
            from acl_entrada_bitacora as ebit, acl_resolucion as resol,
            acl_usuario as usuario
            where
            resol.nombre = 'solicitudEGlobal'
            and ebit.fky_accion = resol.pky_resolucion
            and fky_aclaracion = var_aclaracion   -- pky de aclaracion
            and ebit.fechahora = var_fecha  		-- maxima fecha de entrada bitacora
            and usuario.pky_usuario = ebit.fky_usuario;
            --termina analista
*/
            --Empieza la parte para el supervisor
 /*           select max(ebit.fechahora)
            into var_fecha_s
            from acl_entrada_bitacora as ebit, acl_resolucion as resol,
            acl_usuario as usuario
            where
            resol.nombre = 'enviarSolicitudEglobal'
            and ebit.fky_accion = resol.pky_resolucion
            and fky_aclaracion = var_aclaracion
            and usuario.pky_usuario = ebit.fky_usuario;
*/
            select usuario.nombre
            into res_supervisor
            from acl_entrada_bitacora as ebit, acl_resolucion as resol,
            acl_usuario as usuario
            where
            resol.nombre = 'enviarSolicitudEglobal'
            and ebit.fky_accion = resol.pky_resolucion
            and fky_aclaracion = var_aclaracion
            and ebit.fechahora = (select max(ebit.fechahora)            
            from acl_entrada_bitacora as ebit, acl_resolucion as resol,
            acl_usuario as usuario
            where
            resol.nombre = 'enviarSolicitudEglobal'
            and ebit.fky_accion = resol.pky_resolucion
            and fky_aclaracion = var_aclaracion
            and usuario.pky_usuario = ebit.fky_usuario)
            and usuario.pky_usuario = ebit.fky_usuario;
            --termina supervisor

            return res_evento, res_folio_csuac, res_estatus, res_respuesta,
                 res_numero, res_folio_suc, res_fechahora, 
                 res_monto, res_nombre, res_usuario, res_supervisor
            with resume;
         end foreach;

         drop table temp_solicitudes;

    end;

end procedure

;