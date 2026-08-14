create procedure "informix".cons_dir_cte( pcliente char(20), pnum_regs smallint)
RETURNING char(5);

    DEFINE v_codret         char(5);
    DEFINE v_calle		    char(130);
    DEFINE v_numext	    	char(12);
    DEFINE v_numint       	char(12);
    DEFINE v_depto	      	char(6);
    DEFINE v_colonia       	char(65);
    DEFINE v_estado	   	    char(20);
    DEFINE v_obs	   	    char(80);   
    DEFINE v_entrecalles   	char(40);   
    DEFINE v_cp	   	        char(5);   
    DEFINE v_tel1   	    char(13);   
    DEFINE v_tel2   	    char(13);   
    DEFINE v_tel3   	    char(13);   
    DEFINE v_contador       smallint;
    DEFINE v_municipio	    char(50);	
    DEFINE sql_err,isam_err int;   

    LET v_codret     = "000";

    BEGIN
    
    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN  v_codret;
        end if;
    end exception;

    -- set debug file to "/tmp/cons_dir_cte.out";
    -- trace on;
    
    -- // Valida la informacion de entrada
    IF pcliente is null then  
        LET v_codret = 110; 
        RETURN  v_codret;
    END IF;

    -- // Inicializar variables
    let v_contador = 0;
    
    -- // obtener registros de direcciones completas del cliente
    FOREACH
        select cal.nombrecalle as calle, dir.numeroextcalle, dir.numerointcalle, zon.nombrezona as colonia, dir.cod_postal, mun.nombre as municipio, edo.nombre as edo
          into v_calle, v_numext, v_numint, v_colonia, v_cp, v_municipio, v_estado	
          from bdinteg:si_direcciones_actual dir
          left outer join bdinteg:si_estados edo on ( edo.estado = dir.estado )
          left outer join bdinteg:si_catzonas zon on ( zon.numerociudad = dir.numerociudad and zon.numerocolonia = dir.numerocolonia )
          left outer join bdinteg:si_catcalles cal on ( cal.numerocalle = dir.numerocalle )
          left outer join bdinteg:si_municipios mun on ( mun.estado = dir.estado  and  mun.ciudad = dir.ciudad )
         where dir.numcte = pcliente

        LET v_contador = v_contador + 1;

        IF v_contador < pnum_regs THEN
            CONTINUE FOREACH;
        END IF;    

        INSERT INTO bdicheq:sc_direcTemp(calle, numext, numint, colonia, cp, municipio, estado)
        VALUES(v_calle, v_numext, v_numint, v_colonia, v_cp, v_municipio, v_estado);
    END FOREACH; 
    
    RETURN v_codret;

    END; 
    
END PROCEDURE;