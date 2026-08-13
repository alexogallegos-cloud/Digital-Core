CREATE PROCEDURE "informix".sdos_diarios_trfn()
RETURNING CHAR(5);

    DEFINE vcodret      CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vsqlerr      INTEGER;  
    DEFINE visamerr     INTEGER;  
    DEFINE vdescerr     CHAR(50);
    DEFINE vsql         CHAR(600);
    DEFINE vfecha       DATE; 
    DEFINE vaniomes     CHAR(6);
    DEFINE vdia         CHAR(2);
    DEFINE vfecha_hoy   DATE;
    DEFINE vfecha_desc  CHAR(8);

    LET vcodret     = "000";
    LET vcodret2    = "";
    LET vcodret3    = "";
    LET vsqlerr     = 0;
    LET visamerr    = 0;
    LET vdescerr    = '';
    LET vsql        = '';
    LET vfecha      = '';
    LET vaniomes    = '';
    LET vdia        = '';
    LET vfecha_hoy  = '';
    LET vfecha_desc = '';

    --- SET DEBUG FILE TO "sdos_diarios_trfn.out";
    --- TRACE ON;  

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "sdos_diarios_trfn.err";
        TRACE ON; 
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;

    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha
      FROM sc_fechas
     WHERE empresa = "001";

    LET vdia = SUBSTR(vfecha,4,2);
    LET vdia = vdia;
    
    LET vaniomes = SUBSTR(vfecha,7,4) || SUBSTR(vfecha,1,2);
    LET vaniomes = vaniomes;
    
    LET vfecha_desc = LPAD(SUBSTR(vfecha,4,2),2,'0')||LPAD(SUBSTR(vfecha,1,2),2,'0')||(SUBSTR(vfecha,7,4));
    
    IF LPAD(vdia,2,'0') = '01' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig1, sdo.intprovnp1, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ELIF LPAD(vdia,2,'0') = '02' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig2, sdo.intprovnp2, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '03' THEN
      
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig3, sdo.intprovnp3, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '04' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig4, sdo.intprovnp4, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '05' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig5, sdo.intprovnp5, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '06' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig6, sdo.intprovnp6, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '07' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig7, sdo.intprovnp7, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";
        
    ElIf LPAD(vdia,2,'0') = '08' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig8, sdo.intprovnp8, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '09' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig9, sdo.intprovnp9, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '10' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig10, sdo.intprovnp10, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '11' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig11, sdo.intprovnp11, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '12' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig12, sdo.intprovnp12, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '13' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig13, sdo.intprovnp13, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '14' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig14, sdo.intprovnp14, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '15' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig15, sdo.intprovnp15, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '16' THEN
         
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig16, sdo.intprovnp16, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '17' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig17, sdo.intprovnp17, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '18' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig18, sdo.intprovnp18, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '19' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig19, sdo.intprovnp19, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '20' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig20, sdo.intprovnp20, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '21' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig21, sdo.intprovnp21, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '22' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig22, sdo.intprovnp22, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";
        
    ElIf LPAD(vdia,2,'0') = '23' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig23, sdo.intprovnp23, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '24' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig24, sdo.intprovnp24, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '25' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig25, sdo.intprovnp25, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '26' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig26, sdo.intprovnp26, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '27' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig27, sdo.intprovnp27, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '28' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig28, sdo.intprovnp28, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '29' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig29, sdo.intprovnp29, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '30' THEN

        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig30, sdo.intprovnp30, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ElIf LPAD(vdia,2,'0') = '31' THEN
        
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /respaldos/conciliachq/archsdocaptrfn_'||vfecha_desc||'.txt '||
                   'SELECT sdo.sucursal, sdo.cuenta, mae.numcte, mae.ejecutivo, mae.fec_alta, fech.fecha_ant, sdo.capvig31, sdo.intprovnp31, mae.status_cta '||
                   'FROM sc_sdodiarioc sdo, bditransfer:tf_maecte mae, sc_fechas fech '||
                   'WHERE sdo.cuenta = mae.cuenta_tf '||
                   'AND sdo.aniomes = '''||vaniomes ||''' '||
                   'AND ( mae.status_cta <> "3" OR ( mae.status_cta = "3" AND mae.fec_cancelac = '''||vfecha_hoy ||''' ) ) '||
                   'AND fech.empresa = mae.empresa;" > /respaldos/conciliachq/query_saldos.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /respaldos/conciliachq/query_saldos.sql";
        SYSTEM vsql;
        LET vsql = "";

    ELSE

        LET vcodret = '200';  -- // FECHA INVALIDA

    END IF;

    END;

    RETURN vcodret;

END PROCEDURE;