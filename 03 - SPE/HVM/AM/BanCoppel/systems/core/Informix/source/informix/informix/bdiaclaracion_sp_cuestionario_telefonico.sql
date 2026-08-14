CREATE PROCEDURE "informix".sp_cuestionario_telefonico(p_NumCte CHAR(30))

    RETURNING   CHAR(50) AS estado, CHAR(15) AS fecha_nacimiento, CHAR(10) AS cod_postal,
     CHAR(15) AS numero_exterior, CHAR(50) AS estado_nacio,CHAR(30) AS telefono,
     CHAR(50) AS calle, CHAR(50) AS colonia, CHAR(50) AS municipio, CHAR(50) AS correo_electronico;

    --definicion de variables--
    DEFINE resultado_estado                 CHAR(50);
    DEFINE resultado_estado_nacio           CHAR(50);
    DEFINE resultado_fecha_nacimiento       CHAR(15);
    DEFINE resultado_cod_postal             CHAR(10);
    DEFINE resultado_numero_exterior        CHAR(15);
    DEFINE resultado_apellido_paterno       CHAR(20);
    DEFINE resultado_apellido_materno       CHAR(20);
    DEFINE resultado_telefono               CHAR(30);
    DEFINE resultado_calle                  CHAR(50);
    DEFINE resultado_colonia                CHAR(50);
    DEFINE resultado_municipio              CHAR(50);
    DEFINE resultado_correo_electronico     CHAR(50);
    DEFINE iSqlErr                          INTEGER;
    -- Inicializacion de las variables.
    LET resultado_estado = '';
    LET resultado_estado_nacio ='';
    LET resultado_fecha_nacimiento = '';
    LET resultado_cod_postal = '';
    LET resultado_numero_exterior = '';
    LET resultado_apellido_paterno='';
    LET resultado_apellido_materno='';
    LET resultado_telefono = '';
    LET resultado_calle = '';
    LET resultado_colonia = '';
    LET resultado_municipio = '';
    LET resultado_correo_electronico = '';


    SET ISOLATION TO DIRTY READ;

    BEGIN
        ON EXCEPTION
                SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET resultado_estado = '';
                    LET resultado_estado_nacio ='';
                    LET resultado_fecha_nacimiento = '';
                    LET resultado_cod_postal = '';
                    LET resultado_numero_exterior = '';
                    LET resultado_telefono = '';
                    LET resultado_calle = '';
                    LET resultado_colonia = '';
                    LET resultado_municipio = '';
                    LET resultado_correo_electronico = '';
                    RETURN resultado_estado, resultado_fecha_nacimiento, resultado_cod_postal, resultado_numero_exterior,resultado_estado_nacio, resultado_telefono, resultado_calle, resultado_colonia, resultado_municipio, resultado_correo_electronico;
                END IF;
        END EXCEPTION;


        SELECT
                 edo.nombre as estado, ' 02 '|| substr(rfc,5,6) as fecha_nacimiento, ' 03 ' || sd.cod_postal,' 04 ' || numeroextcalle as numero_exterior, ' 06 ' || telefono as 
                 telefono_casa,ct.nombrecalle as calle,
                 sz.nombrezona as colonia, sz.municipiozona as municipio,
                 em.correo_elec as correo_electronico
                 INTO resultado_estado, resultado_fecha_nacimiento,resultado_cod_postal,resultado_numero_exterior
                 ,resultado_telefono,resultado_calle,resultado_colonia,resultado_municipio,resultado_correo_electronico
                FROM bdinteg:si_cliente sc
                 Left Outer Join bdinteg:si_direcciones_actual sd on sc.numcte = sd.numcte and tipo_dir = '1'
                 Left Outer Join bdinteg:si_estados edo on edo.estado = sd.estado
                 Left Outer Join bdinteg:si_telefonos st on st.numcte = sc.numcte and st.tipo_tel = '1' and st.status_tel = 'A'
                 Left Outer Join bdinteg:si_catcalles ct on ct.numerocalle = sd.numerocalle
                 Left Outer Join bdinteg:si_catzonas sz on sz.numerociudad = sd.numerociudad and sz.numerocolonia = sd.numerocolonia
                 Left Outer Join bdinteg:si_correos em on em.numcte = sc.numcte and status_correo = 'A' and em.tipo_correo='1'
            where
            sc.NUMCTE = p_NumCte;
            LET resultado_estado_nacio = ( select estados.nombre from bdinteg:si_ctepf ctpf
            inner join bdinteg:si_estados estados on ctpf.lugar_nac = estados.estado
            where numcte = p_NumCte);

 IF resultado_estado is null THEN
     LET resultado_estado = 'null';
END IF;

  IF resultado_fecha_nacimiento is null THEN
     LET resultado_fecha_nacimiento = '02 null';
END IF;

 IF resultado_cod_postal is null THEN
     LET resultado_cod_postal = '03 null';
END IF;

 IF resultado_numero_exterior is null THEN
     LET resultado_numero_exterior = '04 null';
END IF;

 IF resultado_estado_nacio is null THEN
     LET resultado_estado_nacio = 'null';
END IF;

IF resultado_telefono is null THEN
     LET resultado_telefono = '06 null';
END IF;

 IF resultado_calle is null THEN
     LET resultado_calle = 'null';
END IF;

 IF resultado_colonia is null THEN
     LET resultado_colonia = 'null';
END IF;

 IF resultado_municipio is null THEN
     LET resultado_municipio = 'null';
END IF;

 IF resultado_correo_electronico is null THEN
     LET resultado_correo_electronico = 'null';
END IF;

    RETURN ' 01 '|| Trim(resultado_estado), resultado_fecha_nacimiento,resultado_cod_postal,resultado_numero_exterior,' 05 '||resultado_estado_nacio,resultado_telefono,' 07 ' || Trim(resultado_calle),' 08 ' || Trim(resultado_colonia),'09 ' || Trim(resultado_municipio),'10 ' || Trim(resultado_correo_electronico);


END

END PROCEDURE;