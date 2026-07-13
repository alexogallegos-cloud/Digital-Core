create procedure "informix".sp_os_llenazonasporreplicar(empresa char(3))
returning char (5);

--Juan Andrés Coronel Morán
--08-08-2007
--llena tabla con zonas y calles dadas de alta e bancoppel, que son requeridas en coppel para imprimir OS

    define sNombreZona  char(32);   --like bdinteg:si_catzonas.nombrezona
    define sNombreCalle char(40);   --like bdinteg:si_catcalles.nombrecalle;
    define iCiudad     integer;
    define iColonia    integer;
    define iCalle      integer;
    --define iNumCte     char(20);
    define iNumeroCobranzas integer;
    define iCuantos     integer;
    DEFINE SQL_ERR          INTEGER;
    DEFINE ISAM_ERR         INTEGER;
    DEFINE ERROR_INFO       VARCHAR(80);
    DEFINE P_COD_RET        VARCHAR(5);
    DEFINE P_MENSAJE        VARCHAR(80);
    DEFINE pUsuario           CHAR(8);
    DEFINE vdia				  DATE;
    DEFINE vhora			  DATETIME YEAR to FRACTION(5);

    --Set debug file to '/pisa/pisabanco/pisa_ftes/credito/coronel/sp_os_llenazonasporreplicar.out';
    --trace on;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        ROLLBACK WORK;
        RETURN P_COD_RET;
    END EXCEPTION;

    LET pUsuario      = 'SYSCOBRA';

    INSERT INTO bdisolic:ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
    VALUES('sp_os_llenazonasporreplicar', '11111', 'PROCESO INICIALIZADO', pUsuario, CURRENT::DATE, CURRENT::DATETIME HOUR TO SECOND);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 2;

    Begin Work;
    Let P_cod_ret = "00000";
    ForEach

    select nvl(a.numerociudad,0) as numerociudad, nvl(a.numerocolonia,0) as numerocolonia, nvl(a.numerocalle,0) as numerocalle
    Into iCiudad, iColonia, iCalle
    from bdinteg:si_direcciones a
         ,bdisolic:ss_solicitudes e
    where e.numcte = a.numcte
    and e.empresa = empresa
    and a.tipo_dir in (1,2)
    /*and a.secuencia = (
        select max(secuencia)
        from bdinteg:si_direcciones b
        where b.numcte = a.NumCte
        and b.tipo_dir = a.tipo_dir)*/
    and a.numerociudad > 0
    and
        (
            (a.numerocolonia >= 8001 and a.numerocolonia <= 8900)
            or
            (a.numerocalle >= 800001 and a.numerocalle <= 899999)
        )
    and e.status_solicitud in ('EE','CE')


        --la calle se debe enviar a cada region donde se requiera, puede enviarse a muchas zonas
        Let sNombreCalle = ' ';
        if iCalle < 800001 or iCalle > 899999 then
            --Si la calle no es por asignar se envía en ceros
            Let iCalle = 0;
        end if;

        Select count(*)
        Into iCuantos
        From bdinteg:si_replicazonasasignar
        Where numerociudad = iCiudad
        and numerocolonia = iColonia
        and numerocalle = iCalle;

        If iCuantos = 0 then  --Si no ha sido replicada esta combinación, o para este cliente

            --If nvl(v_colonia, 0) >= 8001 and nvl(v_colonia, 0) <= 8900 then
            Select nombrezona
            Into sNombreZona
            from bdinteg:si_catzonas
            where numerociudad = iCiudad
            and numerocolonia = iColonia;
            --end if;

            If length(trim(nvl(sNombreZona, ' '))) = 0 then
                continue foreach;
            end if;

            Let sNombreCalle = '';
            if iCalle > 0 then
                Select nvl(nombrecalle, ' ')
                Into sNombreCalle
                from bdinteg:si_catcalles
                where numerocalle = iCalle;

                If sNombreCalle is null then
                    continue foreach;
                End if;

                if length(trim(nvl(sNombreCalle, ' '))) = 0 then
                    continue foreach;
                end if;
            end if;

            --obtener numerocobranzas

            select numerocobranzas
            Into iNumeroCobranzas
            from bdinteg:si_catzonas
            where numerociudad = iCiudad
            and numerocolonia  =
            (
                select min (numerocolonia)
                from bdinteg:si_catzonas
                where numerociudad = iCiudad
                and  numerocobranzas > 0 AND CENTRO>0 AND jefegrupozona > 0 and supervisorzona > 0
            )
            and  numerocobranzas > 0;

            If iNumeroCobranzas is Null then
                Continue foreach;
            End if;

            Insert into bdinteg:si_replicazonasasignar (numerociudad, numerocolonia, nombrezona, numerocalle, nombrecalle, numerocobranzas, fechaactualizacion)
            Values (iCiudad, iColonia, sNombreZona, iCalle, sNombreCalle, iNumeroCobranzas, current);
            --commit;

        End if;
    End ForEach;

    IF P_cod_ret = "00000" THEN --no hubo errores
        COMMIT WORK;
    ELSE
        ROLLBACK WORK;
    END IF;

    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
	  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

    INSERT INTO bdisolic:ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
    VALUES('sp_os_llenazonasporreplicar', P_COD_RET, 'PROCESO FINALIZADO', pUsuario, vdia,  vhora);

    RETURN P_COD_RET;


end;
end procedure;