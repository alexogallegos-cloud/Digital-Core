create function "informix".fn_mapea_estado_civil
(
    sCodidentifi char(2)
) returning char(1);

define sRegreso char(1);

begin
    Let sRegreso    = '';
    if      upper(trim(sCodidentifi)) = 'S' then
        Let sRegreso = 'S';
    elif upper(trim(sCodidentifi)) = 'C' then
        Let sRegreso = 'C';
    elif upper(trim(sCodidentifi)) = 'V' then
        Let sRegreso = 'V';
    elif upper(trim(sCodidentifi)) = 'D' then
        Let sRegreso = 'D';
    elif upper(trim(sCodidentifi)) = 'U' then
        Let sRegreso = 'U';
    end if;
    return sRegreso;
end;
end function
;