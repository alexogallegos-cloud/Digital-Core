create procedure "informix".cal_fecharet( pfechaofi  date )
    RETURNING char(5), date;  

    DEFINE v_codret         char(5);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;  
    DEFINE v_fechapre       date;
    DEFINE v_esferiadox     char(1); 

    LET v_codret = "000";
    LET v_fechapre = " ";

    BEGIN

    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            return v_codret,v_fechapre;
        end if;
    end exception;

    -- set debug file to "cal_fecharet.txt";
    -- trace on;
    
    set isolation to dirty read;

    -- // Valida la informacion de entrada
    IF pfechaofi is null THEN
        -- // Datos de entrada incompletos
        LET v_codret = 210; 
        RETURN v_codret, v_fechapre; 
    END IF;

    -- // Validar feriado, sab o dom
    select "1"
      into v_esferiadox
      from bdinteg:si_feriado
     where fecha = pfechaofi;

    IF v_esferiadox is null THEN
        LET v_esferiadox = "0";
    END IF

    -- // Cuando es feriado, sab, dom o fuera de horario se pasa al sig habil
    IF v_esferiadox = "1" or 
       to_char(pfechaofi, "%A") = "Saturday" or 
       to_char(pfechaofi, "%A") = "Sunday" THEN 
        -- // Calcular la fecha correcta
        
        call cal_fecha_pre_fh(pfechaofi)
        returning v_codret, v_fechapre;	
        
        RETURN v_codret, v_fechapre;
    END IF

    LET v_fechapre = pfechaofi;	

    END;    

    RETURN v_codret,v_fechapre;

END PROCEDURE;