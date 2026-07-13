create procedure "informix".sp_os_actualiza_status_solic
	(empresa varchar(3))
returning char(5);

--SP Para ejecutarse mientras no haya un proceso automatico de actualizacion a estatus OA al recibir una respuesta 'D' en la OS .
--Autor: Juan A. Coronel M.
--Fecha: 25-07-2007
--Objetivo:
--  Actualizar las solic de crédito cuyo estatus es 'EE', y cuya OS ya ha sido respondida con estatus 'D' (Por Localizar)
--  Las Solic se pasan al estatus 'OA'.
--  Inserta 2 nuevos estatus en la tabla ss_status_sol.

--Modificación 09-08-2007
--Hará update a la descripción del estatus "OS", decía "ReEnviada a Orden de Supervision.", ahora dirá "Enviada a Orden de Supervisión"
--Modificacion 29-08-2007
--Hacer que las solic que ya estan en estatus EE y que estan en espera de respuesta, se pasen al estatus OS, que es el estatus actual para las solic cuya OS ya se generó y se envió o está por enviarse a coppel.
--Justificacion: El nuevo estatus OS entró en vigor a partir del lunes 20 de agosto, fecha en que se metio a producción esta lógica. Las solic ya existentes, y que su OS ya está en coppel, se quedaron en el estatus original 'EE'.


define vNum_Solic   like ss_solicitudes.num_solicitud;
define vStatus      like ss_solicitudes.status_solicitud;
define vDescripcion like ss_status_sol.descripcion;
define iCuantos		Integer;
define dFechaEnt	date;
define dFechaSalida	date;
define dFechaSolicOS date;

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE P_COD_RET   VARCHAR(6);
DEFINE P_MENSAJE   VARCHAR(80);

--Set debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/sp_os_actualiza_status_solic.out';
--trace on;

Begin
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        ROLLBACK WORK;
        RETURN P_COD_RET;
    END EXCEPTION;

	Begin Work;
	Let P_COD_RET = '000000';

	Let iCuantos = 0;
	Select count(*)
	Into iCuantos
	From ss_status_sol
	Where status_solicitud = "OA";

	If iCuantos = 0 then
		Insert into ss_status_sol (empresa, status_solicitud, descripcion)
		Values ("001", "OA", "Orden Supervision en Aclaracion");
	End If;

	Let iCuantos = 0;
	Select count(*)
	Into iCuantos
	From ss_status_sol
	Where status_solicitud = "OS";

	If iCuantos = 0 then
		Insert Into  ss_status_sol (empresa, status_solicitud, descripcion)
		Values ("001", "OS", "Enviada a Orden de Supervision");
	Else
		Update ss_status_sol
		Set descripcion = "Enviada a Orden de Supervision"
		Where empresa = "001"
		and status_solicitud = "OS";
	End If;


	Select descripcion
	Into vDescripcion
	From ss_status_sol
	where status_solicitud = 'OA';

	ForEach
	select a.num_solicitud, b.status_solicitud
	Into vNum_Solic, vStatus
	from ss_solicitud_os a, ss_solicitudes b
	where a.status = 'D'
	and a.num_solicitud = b.num_solicitud
	and b.status_solicitud = 'EE'
	and a.fecha_solicitud =
		(
			Select max(c.fecha_solicitud)
			from ss_solicitud_os c
			where c.num_solicitud = a.num_solicitud
		)

        --execute procedure sp_actualiza_status_sol(empresa, user, vNum_Solic, 'OA', vDescripcion) Into P_COD_RET;
/*
sp_actualiza_status_sol(
    pempresa char(3), pejecutivo char(8), pnum_solicitud char(20), pNuevo_Status_Sol char(2),
    pcomentario varchar(255,1)) returning char(6);
*/

		select max(fecha_salida)
		Into dFechaEnt
		from ss_autorizacion
		where num_solicitud = vNum_Solic
		and status_solicitud = vStatus;


    		select
    		(case when a.fecha_respuesta::date = '01/01/1900'::date then
     	 		current::date
     		else
         		a.fecha_respuesta::date
     		end)
     		into dfechasalida
     		from ss_solicitud_os a, ss_solicitudes b, ss_osclientesupervisar c
     		where a.status = 'D'
		and a.num_solicitud = vNum_Solic
     		and a.num_solicitud = b.num_solicitud
     		and a.num_solicitud = b.num_solicitud
     		and b.status_solicitud = 'EE'
     		and a.fecha_solicitud =
		(
			Select max(c.fecha_solicitud)
			from ss_solicitud_os c
			where c.num_solicitud = a.num_solicitud
		)
    		and c.num_solicitud  = a.num_solicitud
    		and c.fechasolicitud = a.fecha_solicitud;



		Update ss_autorizacion
		Set fecha_salida = dfechasalida
		Where num_solicitud = vNum_solic
		and fecha_entrada = dFechaEnt
		and status_solicitud = vStatus;

		Update ss_solicitudes
		Set status_solicitud = 'OA'
		Where num_solicitud = vNum_Solic;

		Insert Into ss_autorizacion
			(empresa, ejecutivo_auto, num_solicitud, status_solicitud,
			comentario, fecha_entrada, fecha_salida)
		Values
			("001", "sistema", vNum_Solic, "OA",
	 		vDescripcion, dfechasalida, dfechasalida);

	End ForEach;


	Select descripcion
	Into vDescripcion
	From ss_status_sol
	where status_solicitud = 'OS';

	ForEach
	select a.num_solicitud, b.status_solicitud , a.fecha_solicitud,
        (case when fechamovto::date = '01/01/1900'::date then
            a.fecha_solicitud
        else
            c.fechamovto::date
        end)
	Into vNum_Solic, vStatus, dFechaSolicOS, dFechaSalida
	from ss_solicitud_os a, ss_solicitudes b, ss_osclientesupervisar c
	where a.status = 'P'
	and a.num_solicitud = b.num_solicitud
	and b.status_solicitud = 'EE'
	and a.fecha_solicitud =
		(
			Select max(c.fecha_solicitud)
			from ss_solicitud_os c
			where c.num_solicitud = a.num_solicitud
		)
    and c.num_solicitud  = a.num_solicitud
    and c.fechasolicitud = a.fecha_solicitud

		Select max(fecha_entrada)
		Into dFechaEnt
		From ss_autorizacion
		Where num_solicitud = vNum_Solic
		And status_solicitud = vStatus;
/*
        Select mdy(month(fechamovto), day(fechamovto), year(fechamovto))::date Into dFechaSalida
        From ss_osclientesupervisar a
        Where a.num_solicitud = vNum_Solic
        And a.fechasolicitud = dFechaSolicOS;
*/
--        If nvl(dFechaSalida, '1900-01-01'::date) = '1900-01-01'::date then
--            Let dFechaSalida = dFechaSolicOS;
        --Else
        --    Let dFechaSalida = dFechaSalida -1 units year;
--        End if;

		Update ss_autorizacion
		Set fecha_salida = dFechaSalida
		Where num_solicitud = vNum_solic
		and fecha_entrada = dFechaEnt
		and status_solicitud = vStatus;

		Update ss_solicitudes
		Set status_solicitud = 'OS'
		Where num_solicitud = vNum_Solic;

--Poner como fecha entrada y salida del nuevo estatus la fecha en que entró realmente, que debe ser la fecha de generacion de datos de OS
		Insert Into ss_autorizacion
			(empresa, ejecutivo_auto, num_solicitud, status_solicitud,
			comentario, fecha_entrada, fecha_salida)
		Values
			("001", "sistema", vNum_Solic, "OS",
	 		vDescripcion, dFechaSalida, dFechaSalida);

	End ForEach;

	If P_COD_RET = '000000' then
		Commit Work;
	Else
		RollBack Work;
	End if;

	Return p_Cod_ret;

End;
end procedure;