create function "informix".mapea_tipo_casa
(
    sTipoCasa char(2)
) returning char(1);

define sRegresa char(1);

Begin
    Let sRegresa    ='';
    if   sTipoCasa = '01' then    --Propia
        Let sRegresa = 'P';
    elif sTipoCasa = '02' then    --Rentada
        Let sRegresa = 'R';
    elif sTipoCasa = '03' then    --Familiares
        Let sRegresa = 'F';
    end if;
    Return sRegresa;
End;

End function
;