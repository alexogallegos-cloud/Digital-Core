create procedure "informix".sp_actualiza_domicilio_cac(pNumerocd smallint, pNumerocol smallint, pNuevacd smallint, pNuevacol smallint )
returning char(20);

    ---V5 20100127 Agregar directiva en select a bdinteg:si_direcciones 
    ---V4 20091124 Modificar
    ---V1 20091022 Crear SP
    define cod_ret char(20);
    define sql_err integer;
    define v_numcte char(9);
    define v_numerociudad smallint;
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

    --- SET DEBUG FILE TO "/ids10_uc9/actualiza_domicilio_cac.out";
    --- TRACE ON;

    let cod_ret       = "000";
    let v_numcte      = "";
    let v_numerociudad = 0;
    let v_max_secuencia = 0;
    let v_strlog = "";
    let v_pais= '001';

    BEGIN

    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret;
        end if
    end exception;

    SYSTEM 'echo ---- Inicia proceso --------- ' || '>> ' || 'actualiza_domicilio_cac.log';

    foreach
        /* ##########################################################################################
        select {+ INDEX (bdinteg:si_direcciones idx_numcolonia)} d.numcte into v_numcte
        from bdinteg:si_direcciones d
        where d.numerocolonia = pNumerocol
        and d.numerociudad = pNumerocd
        and d.tipo_dir = '1'
        and d.secuencia = ( select {+ INDEX (bdinteg:si_direcciones idx_numcte)} max(e.secuencia)
        from bdinteg:si_direcciones e
        where d.numcte = e.numcte
        and e.tipo_dir = '1')
        ########################################################################################## */
        SELECT d.numcte 
          INTO v_numcte
          from bdinteg:si_direcciones_actual d
         where d.numerocolonia = pNumerocol
           and d.numerociudad = pNumerocd
           and d.tipo_dir = '1'

        if v_numcte is null then
            SYSTEM 'echo Cliente no encontrado en si_direcciones ' || '>> ' || 'actualiza_domicilio_cac.log';
            CONTINUE FOREACH;
        end if

        -- Obtener secuencia máxima.
        select {+ INDEX (bdinteg:si_direcciones_actual idx_diract_cte /*idx_numcte*/)} 
               max(secuencia) 
          into v_secuencia_r
          from bdinteg:si_direcciones_actual
         where numcte = v_numcte;

        -- Selecc para cada cliente el registro que tiene la maxima secuencia
        select {+ INDEX (bdinteg:si_direcciones_actual idx_diract_ctetpo /*idx_numcte*/)} 
               d.tipo_dir, d.calle, d.colonia, d.entre_calles, d.pais, d.estado, d.ciudad, d.municipio, d.cod_postal, d.apart_postal, 
               /* d.tipo_telef1, d.telefono1, d.tipo_telef2, d.telefono2, d.tipo_telef3, d.telefono3, d.extension, */
               d.estado_inegi, d.municipio_inegi, d.localidad_inegi, d.numerociudad, d.numeroextcalle, d.numerointcalle, 
               d.departamento, d.numerocalle, d.numerocolonia, d.puntocardinal, d.unidadhabitac, d.manzana, d.otros, d.andador, 
               d.etapa, d.lote, d.edificio, d.entrada, d.observaciones, d.user_insert, d.fecha_insert
          into v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 
               /* v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r, v_telefono2_r, v_tipo_telef3_r, v_telefono3_r, v_extension_r, */
               v_estado_inegi_r, v_municipio_inegi_r, v_localidad_inegi_r, v_numerociudad_r, v_numeroextcalle_r, v_numerointcalle_r, 
               v_departamento_r, v_numerocalle_r, v_numerocolonia_r, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, v_andador_r, 
               v_etapa_r, v_lote_r, v_edificio_r, v_entrada_r, v_observaciones_r, v_user_insert_r, v_fecha_insert_r
          from  bdinteg:si_direcciones_actual d
         where d.numcte =  v_numcte
           and d.tipo_dir = '1';
        /* ###########################################################################
           and d.secuencia = (select {+ INDEX (bdinteg:si_direcciones idx_numcte)} 
                                     max(f.secuencia)
                                from bdinteg:si_direcciones f		
                               where d.numcte = f.numcte
                                 and f.tipo_dir = '1');
        ########################################################################### */

        -- El registro obtenido guardarlo nuevamente con la secuencia + 1
        let v_max_secuencia = v_secuencia_r + 1;
        -- let v_tipo_dir_r = '1';

        insert into bdinteg:si_direcciones
        ( numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal, apart_postal,
          /* tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension, */
          estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,
          puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,user_insert,fecha_insert )
        values  
        ( v_numcte,v_max_secuencia, v_tipo_dir_r, v_calle_r, v_colonia_r, v_entre_calles_r, v_pais_r, v_estado_r, v_ciudad_r, v_municipio_r, v_cod_postal_r, v_apart_postal_r, 
          /* v_tipo_telef1_r, v_telefono1_r, v_tipo_telef2_r,v_telefono2_r,v_tipo_telef3_r, v_telefono3_r, v_extension_r, */
          v_estado_inegi_r, v_municipio_inegi_r,v_localidad_inegi_r, pNuevacd /*v_numerociudad_r*/, v_numeroextcalle_r, v_numerointcalle_r, 
          v_departamento_r, v_numerocalle_r,pNuevacol /*v_numerocolonia_r*/, v_puntocardinal_r, v_unidadhabitac_r, v_manzana_r, v_otros_r, 
          v_andador_r, v_etapa_r,v_lote_r,v_edificio_r, v_entrada_r, v_observaciones_r, 'SOLI_CAC' /*v_user_insert_r*/, v_fecha_insert_r );

        -- Actualizar
        -- EL ACTUALIZAR SE ELIMINA YA QUE SE AGREGAN LOS VALORES QUE SE ACTUALIZAN AL INSERT
        /* #####################################
        update bdinteg:si_direcciones    
           set numerociudad = pNuevacd,
               numerocolonia = pNuevacol,
               user_insert = 'SOLI_CAC'
         where numcte = v_numcte 
           and secuencia = v_max_secuencia;
        ##################################### */
    end foreach;

    end
    
    let cod_ret = "Termina proceso";
    
    SYSTEM 'echo ----Termina el proceso-----' || '>> ' || 'actualiza_domicilio_cac.log';
    
    return cod_ret;
    
end procedure;