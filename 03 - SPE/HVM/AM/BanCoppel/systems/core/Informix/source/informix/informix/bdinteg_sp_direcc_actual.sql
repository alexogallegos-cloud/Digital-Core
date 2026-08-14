CREATE PROCEDURE "informix".sp_direcc_actual( pnumcte           char(20),
                                              psecuencia        integer,
                                              ptipo_dir         char(1),
                                              pcalle            char(40),
                                              pcolonia          char(60),
                                              pentre_calles     char(40),
                                              ppais             char(3),
                                              pestado           char(2),
                                              pciudad           char(3),
                                              pmunicipio        char(5),
                                              pcod_postal       char(5),
                                              papart_postal     char(11),
                                              /*
                                              ptipo_telef1      char(1),
                                              ptelefono1        char(13),
                                              ptipo_telef2      char(1),
                                              ptelefono2        char(13),
                                              ptipo_telef3      char(1),
                                              ptelefono3        char(13),
                                              pextension        char(5),
                                              */
                                              pestado_inegi     char(2),
                                              pmunicipio_inegi  char(3),
                                              plocalidad_inegi  char(4),
                                              pnumerociudad     smallint,
                                              pnumeroextcalle   char(10),
                                              pnumerointcalle   char(10),
                                              pdepartamento     char(6),
                                              pnumerocalle      integer,
                                              pnumerocolonia    integer,
                                              ppuntocardinal    char(1),
                                              punidadhabitac    char(1),
                                              pmanzana          smallint,
                                              potros            smallint,
                                              pandador          smallint,
                                              petapa            smallint,
                                              plote             smallint,
                                              pedificio         smallint,
                                              pentrada          smallint,
                                              pobservaciones    char(80),
                                              puser_insert      char(8),
                                              pfecha_insert     date,
                                              pind_cofeteltel1  char(1),
                                              pind_cofeteltel2  char(1),
                                              pind_cofeteltel3  char(1) )
--- RETURNING CHAR(5);

    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;

    DEFINE vexiste_cte INTEGER;

    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET sql_err	 = 0;
    LET isam_err = 0;

    LET vexiste_cte = 0;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_direcc_actual.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            --- RETURN vcodret1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_direcc_actual.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)}
           numcte
      INTO vexiste_cte
      FROM bdinteg:si_direcciones_actual
     WHERE numcte = pnumcte
       AND tipo_dir = ptipo_dir;

    IF vexiste_cte > 0 THEN

        UPDATE {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)}
               bdinteg:si_direcciones_actual
           SET secuencia        = psecuencia,
               calle            = pcalle,
               colonia          = pcolonia,
               entre_calles     = pentre_calles,
               pais             = ppais,
               estado           = pestado,
               ciudad           = pciudad,
               municipio        = pmunicipio,
               cod_postal       = pcod_postal,
               apart_postal     = papart_postal,
               /*
               tipo_telef1      = ptipo_telef1,
               telefono1        = ptelefono1,
               tipo_telef2      = ptipo_telef2,
               telefono2        = ptelefono2,
               tipo_telef3      = ptipo_telef3,
               telefono3        = ptelefono3,
               extension        = pextension,
               */
               estado_inegi     = pestado_inegi,
               municipio_inegi  = pmunicipio_inegi,
               localidad_inegi  = plocalidad_inegi,
               numerociudad     = pnumerociudad,
               numeroextcalle   = pnumeroextcalle,
               numerointcalle   = pnumerointcalle,
               departamento     = pdepartamento,
               numerocalle      = pnumerocalle,
               numerocolonia    = pnumerocolonia,
               puntocardinal    = ppuntocardinal,
               unidadhabitac    = punidadhabitac,
               manzana          = pmanzana,
               otros            = potros,
               andador          = pandador,
               etapa            = petapa,
               lote             = plote,
               edificio         = pedificio,
               entrada          = pentrada,
               observaciones    = pobservaciones,
               user_insert      = puser_insert,
               fecha_insert     = pfecha_insert,
               ind_cofeteltel1  = pind_cofeteltel1,
               ind_cofeteltel2  = pind_cofeteltel2,
               ind_cofeteltel3  = pind_cofeteltel3
         WHERE numcte = pnumcte
           AND tipo_dir = ptipo_dir;

    ELSE

        INSERT INTO bdinteg:si_direcciones_actual
        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal,
          /* tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, */ 
          estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle,
          departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa,
          lote, edificio, entrada, observaciones, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3 )
        VALUES
        ( pnumcte, psecuencia, ptipo_dir, pcalle, pcolonia, pentre_calles, ppais, pestado, pciudad, pmunicipio, pcod_postal, papart_postal, 
          /* ptipo_telef1, ptelefono1, ptipo_telef2, ptelefono2, ptipo_telef3, ptelefono3, pextension, */ 
          pestado_inegi, pmunicipio_inegi, plocalidad_inegi, pnumerociudad, pnumeroextcalle, pnumerointcalle,
          pdepartamento, pnumerocalle, pnumerocolonia, ppuntocardinal, punidadhabitac, pmanzana, potros, pandador, petapa,
          plote, pedificio, pentrada, pobservaciones, puser_insert, pfecha_insert, pind_cofeteltel1, pind_cofeteltel2, pind_cofeteltel3 );

    END IF;

    END;

    --- RETURN vcodret1;

END PROCEDURE;