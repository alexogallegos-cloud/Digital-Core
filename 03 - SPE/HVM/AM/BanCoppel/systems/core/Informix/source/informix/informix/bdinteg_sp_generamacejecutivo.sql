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