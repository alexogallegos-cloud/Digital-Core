create procedure "informix".sp_manejamacejecutivo(pEmpresa char(3),pTipo char(1),pEjecutivo char(8),pSucursal char(4),pDepartamento char(3),pPuesto char(3),pPerfil int,pMac char(12),pStatus char(1),pUser char(8))
        returning char(5)

    -- Realizo   : Alfredo Gpe. Avena Rocha
    -- Actividad : Actualiza la tabla si_macejecutivo
    -- Solicitó  : Daniel Zambada
    -- Fecha     :  06/03/2007

       define vcodret	char(5);
       define sql_err	integer;
       define vArea	char(2);
       define vMac	char(12);

Let vcodret = '000';
Let vArea = "";
Let vMac = "";



Begin

	on exception set sql_err
		if sql_err <> 0 then
			let vcodret = sql_err;
			return vcodret;
		end if;
	end exception;

	if pTipo = '1'  then  --Alta

            if cast (nvl(pSucursal,0) as int ) > 0 then

                        Select area Into vArea From si_macarea Where sucursal = '0001' and puesto=pPuesto;

                         if nvl(vArea,'0') <> '0' then
                            if exists(Select sucursal From si_sucursalesmaquina  Where sucursal = pSucursal and area = vArea) then
                                --Foreach
                                               --Select mac Into vMac From si_sucursalesmaquina  Where sucursal = pSucursal and area = vArea

                                                Insert Into si_macejecutivo(empresa,mac,ejecutivo,status,user_insert,fecha_insert)
                                                Values(pEmpresa, pSucursal, pEjecutivo,pStatus,pUser,current);

                                                Insert Into si_macejecutivohistorico(empresa,mac,ejecutivo,status,user_insert,fecha_insert,tipomov,fechamov)
                                                Values(pEmpresa, pSucursal, pEjecutivo,pStatus,pUser,current,pTipo,current);

                                --End Foreach;
                            else
                                Let vcodret='001';
                            end if;
                        else
                                Let vcodret='006';
                        end if;
	    else
                   if cast (nvl(pDepartamento,0) as int ) > 0 then

                         if pStatus <> 'T' then

                            if not exists(Select ejecutivo From si_macejecutivo where ejecutivo = pEjecutivo) then

                                Insert Into si_macejecutivo(empresa,mac,ejecutivo,status,user_insert,fecha_insert)
					Values(pEmpresa, pMac, pEjecutivo,pStatus,pUser,current);

                                Insert Into si_macejecutivohistorico(empresa,mac,ejecutivo,status,user_insert,fecha_insert,tipomov,fechamov)
                                Select empresa, mac, ejecutivo, status, user_insert, fecha_insert, pTipo, current  from si_macejecutivo
                                where ejecutivo = pEjecutivo;

                            else
                                Let vcodret='005';
                            end if;

                         else
                            Let vcodret='002';
                         end if;

                   end if;

            end if;

        elif pTipo = '2'  then  --Baja

                   if pStatus = 'T' then

                        Insert Into si_macejecutivohistorico(empresa,mac,ejecutivo,status,user_insert,fecha_insert,tipomov,fechamov)
                        Select empresa, mac, ejecutivo, 'B', user_insert, fecha_insert,pTipo,current  from si_macejecutivo
                        where ejecutivo = pEjecutivo and status = 'T';

                        Delete from si_macejecutivo where ejecutivo = pEjecutivo and status = 'T';
                   else
                        Insert Into si_macejecutivohistorico(empresa,mac,ejecutivo,status,user_insert,fecha_insert,tipomov,fechamov)
                        Select empresa, mac, ejecutivo, 'B', user_insert, fecha_insert,pTipo,current  from si_macejecutivo
                        where ejecutivo = pEjecutivo;

                        Delete from si_macejecutivo where ejecutivo = pEjecutivo;
                   end if;

        elif pTipo = '3'  then  --Modificacion

                    if pStatus = 'A' then
                        update si_macejecutivo set status='I' where ejecutivo = pEjecutivo and status = 'A';
                    else
                        if pStatus = 'I' then
                            update si_macejecutivo set status='A' where ejecutivo = pEjecutivo and status = 'I';
                        end if;
                    end if;


                    Insert Into si_macejecutivohistorico(empresa,mac,ejecutivo,status,user_insert,fecha_insert,tipomov,fechamov)
                   Select empresa, mac, ejecutivo, status, user_insert, fecha_insert,pTipo,current  from si_macejecutivo
                   where ejecutivo = pEjecutivo;

	end if;

        Return vcodret;

end;
End procedure
;