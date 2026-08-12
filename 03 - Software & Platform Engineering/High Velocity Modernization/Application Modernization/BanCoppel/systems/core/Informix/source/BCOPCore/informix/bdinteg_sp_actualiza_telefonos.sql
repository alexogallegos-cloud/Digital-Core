CREATE PROCEDURE "informix".sp_actualiza_telefonos()
returning char(30);

    --- V3 Mejoras 20111201 MACF
    --- V2 20100504 Agregar validaciones   
    --- V1 20100218 Crear SP
    
    define cod_ret char(30);
    define sql_err integer;
    define v_numcte char(20);
    define v_tipo_telef char(1);
    define v_telefono char(13);
    define v_tipo_telef1 char(1);
    define v_telefono1 char(13);
    define v_extension char(5);
    define v_numcte1 char(20);
    define v_tipo_telef2 char(1);
    define v_telefono2 char(13);
    define v_tipo_telef3 char(1);
    define v_telefono3 char(13);
    define v_secuencia integer;
    define cMensaje 		CHAR(150);
    DEFINE isam_err 		INTEGER;
    DEFINE error_info		CHAR(150);
        
    define v_tipo_dir_r char(1);
    define v_calle_r char(40);
    define v_colonia_r char(60);
    define v_entre_calles_r char(40);
    define v_pais_r char(3);
    define v_estado_r char(2);
    define v_ciudad_r char(3);
    define v_municipio_r char(5);
    define v_cod_postal_r char(5);
    define v_apart_postal_r char(11);
    define v_tipo_telef1_r char(1);
    define v_telefono1_r char(13);
    define v_tipo_telef2_r char(1);
    define v_telefono2_r  char(13);
    define v_tipo_telef3_r char(1);
    define v_telefono3_r char(13);
    define v_extension_r char(5);
    define v_estado_inegi_r char(2);
    define v_municipio_inegi_r char(3);
    define v_localidad_inegi_r char(4);
    define v_numerociudad_r smallint;
    define v_numeroextcalle_r char(10);
    define v_numerointcalle_r char(10);
    define v_departamento_r char(6);
    define v_numerocalle_r integer;
    define v_numerocolonia_r integer;
    define v_puntocardinal_r char(1);
    define v_unidadhabitac_r  char(1);
    define v_manzana_r smallint;
    define v_otros_r smallint;
    define v_andador_r smallint;
    define v_etapa_r smallint;
    define v_lote_r smallint;
    define v_edificio_r smallint;
    define v_entrada_r smallint;
    define v_observaciones_r char(80);
    define v_user_insert_r char(8);
    define v_fecha_insert_r date;
    define v_max_secuencia integer;

    --SET DEBUG FILE TO "/informix/macf/sp_actualiza_telefonos.out";
    --TRACE ON;
    
    let cod_ret  = '00000';
    let v_numcte = '';
    let v_secuencia = 0;
    let v_max_secuencia = 0;
    LET cMensaje = '';
    LET isam_err	  	 = 0;
    LET error_info = '';
    
    BEGIN

    on exception set sql_err, isam_err, error_info
        if sql_err <> 0 then
            let cod_ret = sql_err;
            LET cMensaje = error_info;
            
            INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
             VALUES('sp_actualiza_telefonos.sql', cod_ret, cMensaje, 0, 'informix', today, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

            
            return cod_ret;
        end if
    end exception;

      INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
      VALUES('sp_actualiza_telefonos.sql', '11111', 'PROCESO INICIALIZADO', 0, 'informix', today, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));


    set isolation to dirty read;
    set lock mode to wait 3;

    -- // Domicilio CASA
    foreach
        select numcte, tipo_telef1, telefono1, extension  -- // Primero tipo P (Casa)
          into v_numcte, v_tipo_telef, v_telefono, v_extension
          from bdinteg:si_gestion_telefonica

        if v_tipo_telef IN('P', 'C', 'A') then
            select {+INDEX(bdinteg:si_direcciones_actual idx_diract_cte)} max(secuencia) 
              into v_secuencia
              from bdinteg:si_direcciones_actual
             where numcte = v_numcte;

            if nvl(v_secuencia,0) = 0 then
                continue foreach;
            end if 

            select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} 
                   d.tipo_dir, d.calle, d.colonia, d.entre_calles, 
                   d.pais, d.estado, d.ciudad, d.municipio, d.cod_postal, d.apart_postal, d.tipo_telef1, d.telefono1, 
                   d.tipo_telef2, d.telefono2, d.tipo_telef3, d.telefono3, d.extension, d.estado_inegi, d.municipio_inegi,
                   d.localidad_inegi, d.numerociudad, d.numeroextcalle, d.numerointcalle, d.departamento, d.numerocalle,
                   d.numerocolonia, d.puntocardinal, d.unidadhabitac, d.manzana, d.otros, d.andador, d.etapa, d.lote,
                   d.edificio, d.entrada, d.observaciones, d.user_insert, d.fecha_insert
              into v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r,
                   v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r,
                   v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, v_estado_inegi_r, v_municipio_inegi_r,
                   v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, v_departamento_r, 
                   v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, 
                   v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, v_entrada_r, v_observaciones_r, v_user_insert_r, 
                   v_fecha_insert_r
              from bdinteg:si_direcciones_actual d
             where d.numcte = v_numcte
               and d.tipo_dir = '1';

            let v_max_secuencia = v_secuencia + 1;
            
            --if (v_telefono is not null or v_telefono <> '') then
            if nvl(v_telefono, '') <> '' then
            
                if v_tipo_telef = 'P' then 
                    insert into bdinteg:si_direcciones
                    ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                      cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                      extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                      numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                      otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                    values 
                    ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                      v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 'P', 
                      v_telefono, v_tipo_telef2_r, v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, 
                      v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                      v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                      v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                      v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                elif v_tipo_telef = 'C' then
                    insert into bdinteg:si_direcciones
                    ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                      cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                      extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                      numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                      otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                    values 
                    ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                      v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, 
                      v_telefono1_r, 'C', v_telefono, v_tipo_telef3_r, v_telefono3_r, v_extension_r, 
                      v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                      v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                      v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                      v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                elif v_tipo_telef = 'A' then
                    --if v_telefono1_r is null or v_telefono1_r = '' then
                    if nvl(v_telefono1_r, '') = '' then
                        insert into bdinteg:si_direcciones
                        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                          cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                          extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                          numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                          otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                        values 
                        ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                          v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 'P', 
                          v_telefono, v_tipo_telef2_r, v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, 
                          v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                          v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                          v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                          v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                    elif nvl(v_telefono2_r, '') = ''  then
                        insert into bdinteg:si_direcciones
                        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                          cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                          extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                          numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                          otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                        values 
                        ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                          v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, 
                          v_telefono1_r, 'P', v_telefono, v_tipo_telef3_r, v_telefono3_r, v_extension_r, 
                          v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                          v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                          v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                          v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                    else
                        insert into bdinteg:si_direcciones
                        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                          cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                          extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                          numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                          otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )  
                        values 
                        ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                          v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, 
                          v_telefono1_r, v_tipo_telef2_r, v_telefono2_r, 'P', v_telefono, v_extension_r, 
                          v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                          v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                          v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                          v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                    end if
                end if
            end if
        elif v_tipo_telef = 'T' then
            --if v_telefono is not null then
            if nvl(v_telefono, '') <> '' then
                select {+INDEX(bdinteg:si_direcciones_actual idx_diract_cte)} 
                       max(secuencia) 
                  into v_secuencia
                  from bdinteg:si_direcciones_actual
                 where numcte = v_numcte;

                select {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} 
                       d.tipo_dir, d.calle, d.colonia, d.entre_calles, 
                       d.pais, d.estado, d.ciudad, d.municipio, d.cod_postal, d.apart_postal, d.tipo_telef1, d.telefono1, 
                       d.tipo_telef2, d.telefono2, d.tipo_telef3, d.telefono3, d.extension, d.estado_inegi, d.municipio_inegi,
                       d.localidad_inegi, d.numerociudad, d.numeroextcalle, d.numerointcalle, d.departamento, d.numerocalle,
                       d.numerocolonia, d.puntocardinal, d.unidadhabitac, d.manzana, d.otros, d.andador, d.etapa, d.lote,
                       d.edificio, d.entrada, d.observaciones, d.user_insert, d.fecha_insert
                  into v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r,
                       v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r,
                       v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, v_estado_inegi_r, v_municipio_inegi_r,
                       v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, v_departamento_r, 
                       v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, 
                       v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, v_entrada_r, v_observaciones_r, v_user_insert_r, 
                       v_fecha_insert_r
                  from bdinteg:si_direcciones_actual d
                 where d.numcte =  v_numcte
                   and d.tipo_dir = '2';

                --if (v_tipo_dir_r is not null and v_pais_r is not null and v_estado_r is not null) then
                if nvl(v_tipo_dir_r,'') <> '' and nvl(v_pais_r,'') <> '' and nvl(v_estado_r, '') <> '' then
                    let v_max_secuencia = v_secuencia + 1;

                    insert into bdinteg:si_direcciones
                    ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio,
                      cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, 
                      extension, estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, 
                      numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, 
                      otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert )
                    values 
                    ( v_numcte, v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
                      v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, v_tipo_telef1_r, 
                      v_telefono1_r, v_tipo_telef2_r, v_telefono2_r, 'O', v_telefono, v_extension, 
                      v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, 
                      v_numerointcalle_r, v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, 
                      v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, 
                      v_entrada_r, v_observaciones_r, v_user_insert_r, today );
                end if
            end if
        end if
    
    end foreach;
      
    INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
    VALUES('sp_actualiza_telefonos.sql', cod_ret, 'PROCESO FINALIZADO', 0, 'informix', today, (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
    
    end

    return cod_ret;
    
END PROCEDURE;