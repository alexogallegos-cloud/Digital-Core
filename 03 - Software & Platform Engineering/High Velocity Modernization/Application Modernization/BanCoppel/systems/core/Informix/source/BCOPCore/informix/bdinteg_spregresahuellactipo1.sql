CREATE PROCEDURE "informix".spregresahuellactipo1( pfechaini DATE )

RETURNING INTEGER;

    define vcodret      INTEGER;
    define vexiste      CHAR(1);
    define vsqlerr      INTEGER;
    define visamerr     INTEGER;
    define vsql         char(600);
    define varchivo     char(60);

    -- SET DEBUG FILE TO "/tmp/spregresahuellactipo1.out";
    -- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET vsqlerr,visamerr
        IF vsqlerr != 0 THEN
            LET vcodret=vsqlerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    LET vcodret = 1;
    LET vexiste = 0;
    LET vsql = '';
    LET varchivo = 'descarga.sql';

    set isolation to dirty read;

    -- // Verifica recepcion correcta de datos
    if pfechaini is null  then
        let vcodret = 120;
        return vcodret;
    end if;

    let vsql = 'echo " unload to /resplogifx/conciliachq/huellas'||lpad(month(pfechaini),2,"0")||lpad(day(pfechaini),2,"0")||'.unl'||" delimiter '|' "||'" > '||varchivo;
    system vsql;

    let vsql = 'echo "'||
    "select nvl(ch.numcte,''),nvl(ch.secuencia,0),nvl(ch.estado,''),nvl(ch.dmapa,''),"||
    "nvl(ch.imapa,''),nvl(ch.usuario,''),nvl(ch.sucursal,''),"||
    "nvl(ch.fecha_alta,mdy(1,1,1900)),nvl(ch.usuario_camb,''),"||
    "nvl(ch.fecha_camb,mdy(1,1,1900)),nvl(cp.sexo,''),nvl(trim(ct.numcte_ref),'0') "||
    "from si_cte_huella ch "||
    "left outer join si_cliente ct on (ct.numcte = ch.numcte) "||
    "left outer join si_ctepf cp on (cp.numcte = ch.numcte) "||
    "where ch.fecha_alta='" || pfechaini || '''" >> '||varchivo;
    system vsql;

    let vsql = "dbaccess bdinteg "||varchivo;
    system vsql;
    
    let vsql = '/usr/bin/chmod 664 /resplogifx/conciliachq/huellas'||lpad(month(pfechaini),2,"0")||lpad(day(pfechaini),2,"0")||'.unl';
    system vsql;
    
    let vsql = "rm descarga.sql";
    system vsql;

    return vcodret;

    END;
    
END PROCEDURE

DOCUMENT
"Proceso temporal para la replicacion de huellas de clientes",
"AUTOR : Julio Cesar Polanco  ",
"FECHA : 09/02/2010",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".ctemoralapoderados(
                                         eEmpresa      CHAR(3),
                                         eNumCte       CHAR(20),
                                         vSecuencia    INTEGER,
                                         vNumCteApode  CHAR(20),
                                         vNomApodera   CHAR(60),
                                         vUsuario     CHAR(20),
                                         vFecha        DATE)



RETURNING CHAR(5);

 DEFINE vcod_ret             CHAR(5);
 DEFINE vsqlerr              INTEGER;


 LET vcod_ret ='000';
 LET vsqlerr  = 0;


BEGIN
    ON EXCEPTION SET vsqlerr
      IF vsqlerr != 0 THEN
         LET vcod_ret=vsqlerr;
        RETURN vcod_ret;
      END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/home/informix/ash/cteapo.out";
    --TRACE ON;

    if exists(select numcteapoderado from si_apoderado where numcte = eNumCte) then
         UPDATE bdinteg:si_apoderado SET secuencia = vSecuencia,
                                         numcteapoderado = vNumCteApode,
                                         nombreapoderado = vNomApodera,
                                         user_insert     = vUsuario,
                                         fecha_insert    = vFecha
         WHERE empresa = eEmpresa AND numcte = eNumCte;
     else
	INSERT INTO bdinteg:si_apoderado (secuencia,numcteapoderado,nombreapoderado,empresa,numcte,user_insert,fecha_insert)
	VALUES     (vSecuencia,vNumCteApode,vNomApodera,eEmpresa,eNumCte,vUsuario,vFecha);
     end if;
END
  RETURN vcod_ret;
END PROCEDURE;