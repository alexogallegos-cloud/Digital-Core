create procedure "informix".sp_validaejecutivo(pnumejecutivo char(8))                           
       returning char(5), char (3), char (45), char(4), char(4),char (3),int, 
       date;

define vcodret char(5);
define vsqlerr integer;
define vempresa char(3);
define vnombre char(45);
define vdepartamento char(4);
define vsucursal char(4);
define vpuesto char(3);
define vperfil  int;
define vvigencia date;

let vcodret = "000";
let  vsqlerr = 0;
let vnombre = "";
let vdepartamento = "";
let vvigencia = "";
let vsucursal = "";
let vempresa = "";
let vpuesto = "";
let vperfil=0;



begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret, vempresa, vnombre, vdepartamento, vsucursal, vpuesto, vperfil, vvigencia;
     end if;
   end exception;

 if pnumejecutivo <> "" then 
        If exists(select ejecutivo from si_ejecut where ejecutivo=pnumejecutivo) then

            SELECT   empresa, nombre, sucursal, puesto, departamento, vigencia, perfil
            INTO  vempresa, vnombre, vsucursal, vpuesto, vdepartamento, vvigencia, vperfil   
            FROM bdinteg:si_ejecut
            WHERE ejecutivo = pnumejecutivo;
              if vvigencia is null then
                  let vcodret= '014';
              else
                 if vvigencia > today then
                    if cast(nvl(vdepartamento,0) as int)= 0 and cast(nvl(vsucursal,0) as int)=0 then
                        let vcodret = '011'; 
                    end if; 
                        if cast(nvl(vdepartamento,0) as int) > 0 then
                            if exists(select ejecutivo from si_macejecutivo where ejecutivo=pnumejecutivo) then
                                let vcodret = '012'; 
                            end if ;
                        else
                            if exists(select ejecutivo from si_macejecutivo where ejecutivo=pnumejecutivo) then
                               let vcodret = '013'; 
                            end if;
                        end if;
                 else
                    let vcodret = '010';
                 end if;
              end if; 
        else
          let vcodret = '009';
        end if;
end if;
     return vcodret, vempresa, vnombre, vdepartamento, vsucursal, vpuesto, vperfil, vvigencia;
end
end procedure;