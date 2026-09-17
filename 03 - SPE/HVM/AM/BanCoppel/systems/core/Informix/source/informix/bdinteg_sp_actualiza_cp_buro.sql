create procedure "informix".sp_actualiza_cp_buro()
returning char(30);

    -- V7 Modif select del reg a insertar que sea tipo_dir 1
    -- V6 Validar en caso de que numerociudad sea 0
    -- V2 20120525 Crear SP
    
    -- Define variables
    define cod_ret char(30);
    define sql_err integer;
    define v_numcte char(9);
    define v_numcalle integer;
    define v_numcolonia integer;
    define v_numerociudad integer;
    define v_estado char(5);
    define v_clave_estado char(2);
    define v_nombrecalle char(30);
    define v_conteocolonias smallint;
    define v_codpostal char(5);
    define v_ciudad char(4);
    define v_max_secuencia integer;
    define v_secuencia_r integer;
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
    define v_strlog char(100);
    define v_user_insert char(8);
    define v_pais char(3);
    define pOrigen char(8);

    --- SET DEBUG FILE TO "/ids10_uc9/actualiza_domicilio.out";
    --- TRACE ON;
    
    -- Inicializa variables
    let cod_ret       = "000";
    let v_numcte      = "";
    let v_numcalle    = 0;
    let v_numcolonia  = 0;
    let v_numerociudad = 0;
    let v_estado = "";
    let v_clave_estado = "";
    let v_codpostal = "";
    let v_ciudad = "";
    let v_max_secuencia = 0;
    let v_nombrecalle = "";
    let v_conteocolonias = 0;
    let v_strlog = "";
    let v_user_insert = "";
    let v_pais= '001';
    let pOrigen ='1';	
    
    BEGIN

    on exception set sql_err
        SYSTEM 'echo ----eRROR-----' || v_numcte || 'actualiza_domicilio.log';
        if sql_err <> 0 then	  
            let cod_ret = sql_err;
            return cod_ret;
        end if
    end exception;

    --- SYSTEM 'echo ---- DATOS INCOMPLETOS DE CLIENTES ----- ' || v_numcte || '> ' || 'actualiza_domicilio.log';
    --- V4
    
    set lock mode to wait 3;

    foreach with hold
        select numcte, numerocalle, numerocolonia, numerociudad, estado, cod_postal ---Obtener cliente por cliente --numcte, cod_postal ---Obtener cliente por cliente	   
        --- into v_numcte, v_codpostal
          into v_numcte, v_numcalle, v_numcolonia, v_numerociudad, v_estado, v_codpostal	   
          from bdinteg:si_por_asignar
         where actualizacion_previa = 'N'
        
        --- SYSTEM 'echo Registro de , numcte: ' || v_numcte || '>> ' || 'actualiza_domicilio.log';
        
        -- Obtener secuencia máxima.
        select max(secuencia) 
          into v_secuencia_r
          from bdinteg:si_direcciones
         where numcte = v_numcte;
        --- and tipo_dir = '1';
        
        -- Selecc para cada cliente el registro que tiene la maxima secuencia
        select first 1 d.tipo_dir, d.calle, d.colonia, d.entre_calles, d.pais, d.estado, d.ciudad, d.municipio, d.cod_postal, d.apart_postal, 
               /* d.tipo_telef1, d.telefono1, d.tipo_telef2, d.telefono2, d.tipo_telef3, d.telefono3, d.extension, */
               d.estado_inegi, d.municipio_inegi, d.localidad_inegi, d.numerociudad, d.numeroextcalle, d.numerointcalle, d.departamento, d.numerocalle, d.numerocolonia, 
               d.puntocardinal, d.unidadhabitac, d.manzana, d.otros, d.andador, d.etapa, d.lote, d.edificio, d.entrada, d.observaciones, d.user_insert, d.fecha_insert
          into v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 
               /* v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r, v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, */
               v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, 
               v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, 
               v_andador_r, v_etapa_r, v_lote_r, v_edificio_r, v_entrada_r, v_observaciones_r, v_user_insert_r, v_fecha_insert_r
          from bdinteg:si_direcciones_actual d
         where d.numcte =  v_numcte
           and d.tipo_dir = '1';

        if v_tipo_dir_r is null or v_secuencia_r is null then --  No existe el cliente
            let cod_ret = "Reg. de si_direcciones_actual incompleto";
            SYSTEM 'echo Registro de cliente en si_direcciones_actual esta incompleto, numcte: ' || v_numcte || '>> ' || 'actualiza_domicilio.log';
            -- return cod_ret;
            CONTINUE FOREACH;
        end if 

        -- El registro obtenido guardarlo nuevamente con la secuencia + 1
        let v_max_secuencia = v_secuencia_r + 1;
        let v_tipo_dir_r = '1';
        
        begin work;
        
        insert into bdinteg:si_direcciones
        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais,
          estado, ciudad, municipio, cod_postal, apart_postal,
          /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */
          estado_inegi, municipio_inegi, localidad_inegi, numerociudad,
          numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia,
          puntocardinal, unidadhabitac, manzana, otros, andador, etapa,
          lote, edificio, entrada, observaciones, user_insert, fecha_insert )
        values  
        ( v_numcte,v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, 
          v_estado /* v_estado_r */, v_ciudad_r, v_municipio_r, v_codpostal /* v_cod_postal_r */, v_apart_postal_r, 
          /* v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r,v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, */
          v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad /* v_numerociudad_r */, 
          v_numeroextcalle_r, v_numerointcalle_r, v_departamento_r, /* v_numerocalle_r, v_numerocolonia_r */
          v_numcalle, v_numcolonia, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, v_etapa_r,
          v_lote_r, v_edificio_r, v_entrada_r, v_observaciones_r, /* v_user_insert_r */ pOrigen, today /* v_fecha_insert_r */ );

        update bdinteg:si_por_asignar
           set actualizacion_previa = 'S'
         where numcte = v_numcte;
         
        commit work;		
        -- Actualizar
    end foreach;

    end
    
    let cod_ret = "Termina proceso";
    
    SYSTEM 'echo ----Termina el proceso-----' || '>> ' || 'actualiza_domicilio.log';
    
    return cod_ret;
    
end procedure;