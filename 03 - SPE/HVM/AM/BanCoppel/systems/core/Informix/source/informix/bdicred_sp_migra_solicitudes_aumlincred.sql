CREATE PROCEDURE "informix".sp_migra_solicitudes_aumlincred(pEmpresa char(3))
returning CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;



--************************ Definicion de variables *****************************
    define sql_err integer;
    define cCodRet char(6);
    define cMensajeRet char(80);
    define contador_commit integer;
    define sCommit smallint;
    define cSql char(2080);
    define vfecha_hoy date;
 	define vNumSolicitud char(20);
	define vNumcte char(20);
	define vNumProducto char(4);
	define vNuevoStatus char(2);
	define vCausaStatus char(3);
	define vFechaStatus date;
	define vHoraStatus datetime hour to fraction(3);
	define vSucursal char(4);
	define vLincredActual decimal(18,2);
	define vLincredSugerida decimal(18,2);
	define vSmbLincred decimal(18,2);
    define vGradoRiesgo char(2);
	define vMontoReserva decimal(18,2);
	define vCalificaBuro char(1);
	define vRespCte smallint;
	define vMensaje char(200);
	define vEjecutivo char(8);
	define vSucursalAt char(4);
	define vOrigen char(1);
	define vUserInsert char(10);
	define vFechaInsert date;
	define vFechaCobranza date;

    let sql_err = 0;
    let cCodRet = '000000';
    let cMensajeRet = "El proceso de MIGRACIÓN DE SOLICITUDES terminó correctamente";
    let contador_commit = 0;
    let sCommit = 0;
    let cSql = '';
	let vNumSolicitud = '';
    let vNumcte = '';
	let vNumProducto =(4);
	let vNuevoStatus =(2);
	let vCausaStatus =(3);
	let vFechaStatus = date(1);
	let vHoraStatus = '';
	let vSucursal = '';
	let vLincredActual ='';
	let vLincredSugerida = '';
	let vSmbLincred = '';
    let vGradoRiesgo = '';
	let vMontoReserva = '';
	let vCalificaBuro = '';
	let vRespCte = '';
	let vMensaje = '';
	let vEjecutivo = '';
	let vSucursalAt = '';
	let vOrigen = '';
	let vUserInsert = '';
	let vFechaInsert = date(1);
	let vFechaCobranza = date(1);

    set isolation to dirty read;
--**************************** Control de errores ******************************
    begin
    on exception set sql_err
		if sql_err <> 0 then
            let cCodRet = sql_err;
            let cMensajeRet = 'Error en el proceso CANCELACION INCREMENTOS DE LINEA ' || vNumSolicitud;
            if (sCommit = -1) then
               rollback work;
            end if;
            return cCodRet, cMensajeRet;
        end if;
	end exception;

--Set debug file to "sp_migra_solicitudes_aumlincred.out";
--trace on;

--*************************** Programa principal *******************************

--obtener la fecha de hoy
select fecha_hoy
  into vfecha_hoy
  from bdicred:sd_fechas
 where empresa = pEmpresa;

foreach with hold
-- obtener las solicitudes que se encuentren en estatus 'AT', 'IN', 'RT','BC','AP','PC'
     select {+INDEX(bdicred:sd_bitacora_aumlincred_hist idx_bitacora_status_hist)}
        num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,smb_lincred,
        grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert,dfecha_cobranza
       into
        vNumSolicitud,vNumcte,vNumProducto,vNuevoStatus,vCausaStatus,vFechaStatus,vHoraStatus,vSucursal,vLincredActual,vLincredSugerida,vSmbLincred,
        vGradoRiesgo,vMontoReserva,vCalificaBuro,vRespCte,vMensaje,vEjecutivo,vSucursalAt,vOrigen,vUserInsert,vFechaInsert,vFechaCobranza
       from bdicred:sd_bitacora_aumlincred_hist
      where empresa = pEmpresa
        and numcte > ''
--        and status in ('AP')
        and status in ('AT','IN','RT','BC','AP','PC')

    IF (sCommit = 0) THEN
       BEGIN WORK;
       LET contador_commit = 0;
       LET sCommit = -1;
    END IF;

-- inserta en la tabla sd_bitacora_aumlincred
        INSERT INTO bdicred:sd_bitacora_aumlincred
        (empresa,num_solicitud,numcte,num_producto,status,causa_status,fecha_status,hora_status,sucursal,lincred_actual,lincred_sugerida,smb_lincred,
        grado_riesgo,monto_reserva,califica_buro,resp_cte,mensaje,ejecutivo,sucursal_at,origen,user_insert,fecha_insert,dfecha_cobranza)
        values
        (pEmpresa,vNumSolicitud,vNumcte,vNumProducto,vNuevoStatus,vCausaStatus,vFechaStatus,vHoraStatus,vSucursal,vLincredActual,vLincredSugerida,vSmbLincred,
        vGradoRiesgo,vMontoReserva,vCalificaBuro,vRespCte,vMensaje,vEjecutivo,vSucursalAt,vOrigen,vUserInsert,vFechaInsert,vFechaCobranza);

-- elimina registro cancelado de la tabla sd_bitacora_aumlincred_hist
        delete from bdicred:sd_bitacora_aumlincred_hist
        where empresa = pEmpresa
        and num_solicitud = vNumSolicitud
        and status = vNuevoStatus
        and fecha_insert = vFechaInsert
        and hora_status = vHoraStatus
        and lincred_actual = vLincredActual;
       

    let contador_commit = contador_commit  + 1;

    IF (contador_commit >= 7000) THEN
       COMMIT WORK;
--       UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_bitacora_aumlincred;
--       UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_autorizacion_aumlincred;
       LET contador_commit = 0;
       BEGIN WORK;
    END IF;

    let vNuevoStatus = '';
    let vCausaStatus = '';
end foreach;

  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;
  LET sCommit = 0;

  UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_bitacora_aumlincred;
  UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_autorizacion_aumlincred;
  UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_bitacora_aumlincred_hist;
  UPDATE STATISTICS MEDIUM FOR TABLE bdicred:sd_autorizacion_aumlincred_hist;

return cCodRet, cMensajeRet;
end;
end procedure;