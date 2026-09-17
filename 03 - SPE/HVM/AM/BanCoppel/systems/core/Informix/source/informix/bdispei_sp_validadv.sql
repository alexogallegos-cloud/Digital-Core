CREATE PROCEDURE "informix".sp_validadv(chrccc char(18))
returning char(5), smallint;
{
Modificado por: Mario Escobar Lara
Funcionalidad : Valida que DV sea correcto.
Fecha : 11 Abril 2008
}

define intCodigoError integer;
define strFuenteError smallint;
define chrCCCvalido char(18);
define vintpond integer;
define vintdigcontrol integer;
define vintdigitocta integer;
define i integer;
define chrbanco char(3);
define chrplazatef char(3);
define intcontador integer;

on exception set intCodigoError
   return intCodigoError, strFuenteError;
end exception;

-- DEBUG FLAG
-- set debug file to "spvalidadv.out";
-- trace on;

let intCodigoError = "000";
let strFuenteError = 0;
let chrCCCValido = substr(chrccc, 1, 17);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3 ;


if length(trim(chrCCCValido))=0 then
  let intCodigoError = "110";
  return intCodigoError,strFuenteError;
end if;
if chrccc='000000000000000000' then
  let intCodigoError = "110";
  return intCodigoError,strFuenteError;
end if;

let chrbanco= substr(chrCCCValido,0,3);
let chrplazatef=substr(chrCCCValido,4,3);

{No realiza validacion del banco hasta que los catalogos de TEF y SPEUA sean unificados.
select count(*) into intcontador from tblbancos where chrcodigo=chrbanco;
if intcontador<1 then
  let  intCodigoError = "100";
  return intCodigoError, strFuenteError;
end if;

select count(*) into intcontador from tblplazas where chrcodigo=chrplazatef;
if intcontador<1 then
  let intCodigoError = "100";
  return intCodigoError, strFuenteError;
end if; }

--Verifica si el digito de control es correcto.
let vintpond = 3;
let vintdigcontrol = 0;
for i = 1 to length(trim(chrCCCValido))

    let vintdigitocta = substr(chrCCCValido, i, 1)*vintpond;
    let vintDigControl = vintDigControl + mod(vintdigitocta,10);

    if vintpond = 1 then let vintpond = 3;
    elif vintpond = 3 then let vintpond = 7;
    elif vintpond = 7 then let vintpond = 1;
    end if;

end for;

let vintdigcontrol = 10 - mod(vintdigcontrol,10);
if vintdigcontrol=10 then
  let vintdigcontrol=0;
end if;

let chrCCCValido = trim(chrCCCValido) || vintDigControl;

if Trim(chrCCCValido) = Trim(chrCCC) then
   let strFuenteError = 1;
end if;

return intCodigoError, strFuenteError;

end procedure;