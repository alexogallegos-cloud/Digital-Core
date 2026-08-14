create procedure "informix".desbloque()
returning integer;
begin

    UNLOCK TABLE bei_cambiostusuario;
    return 1;
end

end procedure;