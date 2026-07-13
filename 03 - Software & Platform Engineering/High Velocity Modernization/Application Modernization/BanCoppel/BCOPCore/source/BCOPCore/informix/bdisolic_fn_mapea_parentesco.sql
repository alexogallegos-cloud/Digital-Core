create function "informix".fn_mapea_parentesco
(
    sParentesco char(2)
) returning char(1);

define sRegresa char(1);

Begin
    Let sRegresa    ='';
    if  sParentesco = '01' then    --Padre
        Let sRegresa = 'P';
    elif sParentesco = '02' then    --Hijo
        Let sRegresa = 'J';
    elif sParentesco = '03' then    --Hermano
        Let sRegresa = 'H';
    elif sParentesco = '04' then    --Abuelo
        Let sRegresa = 'A';
    elif sParentesco = '05' then    --Conyuge
        Let sRegresa = 'E';
    elif sParentesco = '06' then    --Tio
        Let sRegresa = 'T';
    end if;
    Return sRegresa;
End;

End function
;