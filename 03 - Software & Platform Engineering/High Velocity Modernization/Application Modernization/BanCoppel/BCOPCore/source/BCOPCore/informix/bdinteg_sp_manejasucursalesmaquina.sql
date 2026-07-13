create procedure "informix".sp_manejasucursalesmaquina(pTipo char(1),pEmpresa char(3),pSucursal char(4),pDepartamento char(3), pIpMaquina char(16),pMac char(12),pArea char(2),pUserInsert char(8),pFechaInsert date)
        returning char(5)

       define cRegreso	char(5);
       define sql_err	integer;

       let cRegreso = "000";



Begin

	on exception set sql_err
		if sql_err <> 0 then
			rollback work;
			let cRegreso = sql_err;
			return cRegreso;
		end if;
	end exception;

	if ptipo='1' then --Inserta en tabla

		if exists(select sucursal,ipmaquina from si_sucursalesmaquina where psucursal=sucursal and pipmaquina=ipmaquina) then

                            let cRegreso='00001';

		else

                        if exists(select mac from si_sucursalesmaquina where pmac=mac) then

                            let cRegreso='00002';

                        else

                                    if nvl(psucursal, 0) > 0  then

                                        Insert Into si_sucursalesmaquina(empresa, sucursal, departamento, ipmaquina, mac, area, user_insert, fecha_insert)
                                        values(pEmpresa, pSucursal, "000", pIpMaquina, pMac, pArea, pUserInsert, pFechaInsert);

                                    else

                                        if nvl(pdepartamento, 0) > 0 then

                                            Insert Into si_sucursalesmaquina(empresa, sucursal, departamento, ipmaquina,mac, area, user_insert, fecha_insert)
                                            values(pEmpresa, "0000", pDepartamento, pIpMaquina, pMac, pArea, pUserInsert, pFechaInsert);

                                       end if;
                                end if;
			end if;
		end if;
	end if;

        if ptipo = '2' then --Borra en tabla si_sucursalesmaquina e inserta en tabla si_sucursalesmaquinahistorico

            if trim(pmac) = "todos" then

                        if cast(nvl(psucursal, 0) as int) > 0  then

                                 if exists (select sm.mac from si_sucursalesmaquina sm where sm.sucursal = psucursal and sm.mac  in (select ej.mac from si_macejecutivo ej)) then

                                        let cRegreso='00003';

                                 else

                                        Insert Into si_sucursalesmaquinahistorico(empresa,sucursal,departamento,ipmaquina,mac,area,user_insert,fecha_insert, fechamov)
                                        Select empresa,sucursal,departamento,ipmaquina,mac,area,user_insert,fecha_insert, current  from si_sucursalesmaquina
                                        where sucursal = psucursal;

                                        Delete from si_sucursalesmaquina where sucursal = psucursal;

                                 end if;

                       else

                                  if cast(nvl(pdepartamento, 0) as int) > 0 then

                                           if exists (select sm.mac from si_sucursalesmaquina sm where sm.departamento = pdepartamento and sm.mac in (select ej.mac from si_macejecutivo ej)) then

                                                    let cRegreso='00004';

                                           else

                                                    Insert Into si_sucursalesmaquinahistorico(empresa,sucursal,departamento,ipmaquina,mac,area,user_insert,fecha_insert, fechamov)
                                                    Select empresa,sucursal,departamento,ipmaquina,mac,area,user_insert,fecha_insert, current  from si_sucursalesmaquina
                                                    where departamento = pdepartamento;

                                                    Delete from si_sucursalesmaquina where departamento = pdepartamento;

                                            end if;

                                 else

                                            let cRegreso='00005';

                                 end if;

                       end if;

              else

                       if cast(nvl(psucursal, 0) as int) > 0  then

                             --if not  exists (select ej.mac from si_macejecutivo ej where ej.mac = pmac ) then

                                        Insert Into si_sucursalesmaquinahistorico(empresa,sucursal,departamento,ipmaquina,mac,area,user_insert,fecha_insert, fechamov)
                                        Select empresa,sucursal,departamento,ipmaquina,mac,area,user_insert,fecha_insert, current  from si_sucursalesmaquina
                                        where sucursal = psucursal and ipmaquina = pipmaquina and mac = pmac;


                                        Insert Into si_macejecutivohistorico(empresa,mac,ejecutivo,status,user_insert,fecha_insert,tipomov,fechamov)
                                        Select empresa, mac, ejecutivo, "B", user_insert, fecha_insert,pTipo,current  from si_macejecutivo
                                        where mac = pmac;

                                        Delete from si_macejecutivo where mac = pmac;

                                        Delete from si_sucursalesmaquina where sucursal = psucursal and ipmaquina = pipmaquina and mac = pmac;

                            --else

                            -- let cRegreso='00006';

                            -- end if;

                     else

                                      if cast(nvl(pdepartamento, 0) as int) > 0 then

                                            if not  exists (select ej.mac from si_macejecutivo ej where ej.mac = pmac ) then

                                                        Insert Into si_sucursalesmaquinahistorico(empresa,sucursal,departamento,ipmaquina,mac,area,user_insert,fecha_insert, fechamov)
                                                        Select empresa,sucursal,departamento,ipmaquina,mac,area,user_insert,fecha_insert, current  from si_sucursalesmaquina
                                                        where departamento = pdepartamento and ipmaquina = pipmaquina and mac = pmac;

                                                        Delete from si_sucursalesmaquina where departamento = pdepartamento and ipmaquina = pipmaquina and mac = pmac;

                                            else

                                            let cRegreso='00007';

                                            end if;

                                    else

                                            let cRegreso='00008';

                                    end if;

                     end if;

                end if;

         end if;

return cRegreso;

end
End procedure

DOCUMENT
"Maneja Sucursales Maquina",
"Autor : Frank Gaxiola"
;

create procedure "informix".sp_generamacejecutivo(cTipo CHAR(1),cUser_insert char(8))
        returning char(5)

    -- Realizo   : Daniel Zambada
    -- Actividad : Inserta registros de ejecutivos recientes a la si_macejecutivo/genera el cambio de sucursal
    -- Solicitó  : Daniel Zambada
    -- Fecha     :  16/03/2007
    -- Modificó  :  Frank Gaxiola Gaxiola

       define vcodret   char(5);
       define sql_err   integer;
       define vEjecutivo char(8);
       define vPuesto    char(3);
       define vSucursal  char(4);
       define vDepartamento char(3);
       define vVigencia date;
       define vStatus char(1);

Let vcodret = '000';
Let vEjecutivo = "";
Let vPuesto = "";
Let vSucursal = "";
Let vDepartamento = "000";
Let vVigencia = "";
Let vStatus = "";

Begin

        on exception set sql_err
                if sql_err <> 0 then
                        -- rollback work;
                        let vcodret = sql_err;
                        return vcodret;
                end if;
        end exception;

-- Begin work;
 if  cTipo = '1' then
        Foreach
            select ej.ejecutivo,ej.sucursal,ej.puesto
            into vEjecutivo,vSucursal, vPuesto
            from si_ejecut ej
            where ej.ejecutivo not in
            (select ejecutivo from si_macejecutivo where length(trim(mac)) = 4)
            and (ej.vigencia >= current) and (ej.sucursal <> '0000') and (ej.departamento = '000')

                if (cast(nvl(vSucursal,0) as int) <> 0 or nvl(vSucursal,'') <> '') and cast(nvl(vDepartamento,0) as int)  = 0  then
                    Execute Procedure sp_manejamacejecutivo('001',1,vEjecutivo,vSucursal,vDepartamento, vPuesto,0,'','A',cUser_insert)  into vcodret;
                end if

         End Foreach;

  elif cTipo = '2' then

        Foreach
            select ej.ejecutivo,ej.sucursal,ej.puesto
            into vEjecutivo,vSucursal, vPuesto
            from si_ejecut ej , si_macejecutivo me
            where (ej.vigencia >= current)
                  and (ej.sucursal <> '0000')
                  and (ej.departamento = '000')
                  and (ej.ejecutivo = me.ejecutivo)
                  and (length(trim(me.mac)) = 4)
                  and (ej.sucursal <> me.mac)
                  and (me.status = 'A')

                if (cast(nvl(vSucursal,0) as int) <> 0 or nvl(vSucursal,'') <> '') and cast(nvl(vDepartamento,0) as int)  = 0  then
                    Execute Procedure sp_manejamacejecutivo('001',2,vEjecutivo,vSucursal,vDepartamento, vPuesto,0,'','B',cUser_insert)  into vcodret;

                    if trim(vcodret) = '000' then
                        Execute Procedure sp_manejamacejecutivo('001',1,vEjecutivo,vSucursal,vDepartamento, vPuesto,0,'','A',cUser_insert)  into vcodret;
                    end if;

                end if

         End Foreach;

elif cTipo = '3' then
      Foreach
            select distinct a.ejecutivo, b.vigencia
            into vEjecutivo, vVigencia
            from si_macejecutivo a inner join si_ejecut b
            on a.ejecutivo = b.ejecutivo
            and b.vigencia < current

                if (nvl(vEjecutivo,0)) <> 0 and (nvl(vVigencia,0))  <> 0  then
                    Execute Procedure sp_manejamacejecutivo('001',2,vEjecutivo,vSucursal,vDepartamento, vPuesto,0,'','B',cUser_insert)  into vcodret;
                end if;

         End Foreach;

elif cTipo = '4' then
      Foreach

             select distinct ejecutivo, status
             into vEjecutivo, vStatus
             from si_macejecutivo
             where status = 'T'

                if (nvl(vEjecutivo,'0')) <> 0  then
                    Execute Procedure sp_manejamacejecutivo('001',2,vEjecutivo,vSucursal,vDepartamento, vPuesto,0,'','T',cUser_insert)  into vcodret;
               end if;

        End Foreach;


end if
Return vcodret;

-- commit work;

end;
End procedure
;