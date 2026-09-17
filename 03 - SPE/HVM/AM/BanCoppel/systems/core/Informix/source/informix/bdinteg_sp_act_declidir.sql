create procedure "informix".sp_act_declidir()
RETURNING char(5),int,char(100);
    
    DEFINE vsCodRetorno          char(5);
    DEFINE sql_err,isam_err  int;
    DEFINE v_descripcion  char(100);
    DEFINE v_cte         char(9);
    DEFINE v_sec         char(2);
    
    LET vsCodRetorno     = "00000";
    LET isam_err="0";
    LET v_cte="";
    LET v_sec=""; 

    BEGIN
    
    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let vsCodRetorno = sql_err;
            let v_descripcion="PROCESO NO EJECUTADO";
            RETURN vsCodRetorno,isam_err,v_descripcion;
        end if;
    end exception;

    --- SET DEBUG FILE TO "/ids10_uc9/VH/170611/act_dir.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    
    FOREACH 
        select numcte,secuencia 
          into v_cte,v_sec 
          from si_direcciones dir
         where numcte in ( select distinct trim(cliente_tit)
                             from log_fusionclientes where cliente_tit <> '' )
          and secuencia in ( select max(secuencia) 
                               from si_direcciones
                              where numcte = dir.numcte 
                                and tipo_dir = 1 )
        
        INSERT INTO bdinteg:si_direcciones_actual
        SELECT numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,  
               /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, 
               numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, 
               user_insert, fecha_insert, ind_cofeteltel1 as ind_cofeteltel1, ind_cofeteltel2 as ind_cofeteltel2, ind_cofeteltel3 as ind_cofeteltel3    
          FROM si_direcciones 
         where numcte = trim(v_cte) 
           and secuencia = trim(v_sec) 
           and tipo_dir = 1;
    END FOREACH;
    
    SET ISOLATION TO DIRTY READ;
    
    FOREACH 
        select numcte, secuencia 
          into v_cte, v_sec 
          from si_direcciones dir
         where numcte in ( select distinct trim(cliente_tit)
                             from log_fusionclientes 
                            where cliente_tit <> '' )
           and secuencia in ( select max(secuencia) 
                                from si_direcciones
                               where numcte = dir.numcte 
                                 and tipo_dir = 2 )
        
        INSERT INTO bdinteg:si_direcciones_actual
        SELECT numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,  
               /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, 
               numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, 
               user_insert, fecha_insert, ind_cofeteltel1 as ind_cofeteltel1, ind_cofeteltel2 as ind_cofeteltel2, ind_cofeteltel3 as ind_cofeteltel3    
          FROM si_direcciones 
         where numcte = trim(v_cte) 
           and secuencia = trim(v_sec) 
           and tipo_dir = 2;
    END FOREACH;
    
    SET ISOLATION TO DIRTY READ;
    
    FOREACH 
        select numcte,secuencia 
          into v_cte,v_sec 
          from si_direcciones dir
         where numcte in ( select distinct trim(cliente_tit)
                             from log_fusionclientes 
                            where cliente_tit <> '' )
           and secuencia in ( select max(secuencia) 
                                from si_direcciones
                               where numcte = dir.numcte 
                                 and tipo_dir = 3 )
        
        INSERT INTO bdinteg:si_direcciones_actual
        SELECT numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,  
               /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
               estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, 
               numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, 
               user_insert, fecha_insert, ind_cofeteltel1 as ind_cofeteltel1, ind_cofeteltel2 as ind_cofeteltel2, ind_cofeteltel3 as ind_cofeteltel3    
          FROM si_direcciones 
         where numcte = trim(v_cte) 
           and secuencia = trim(v_sec) 
           and tipo_dir = 3;
    END FOREACH;
    
    let v_descripcion = "PROCESO EJECUTADO CORRECTAMENTE";
    
    RETURN vsCodRetorno,isam_err,v_descripcion;
    
    END;
    
END PROCEDURE;