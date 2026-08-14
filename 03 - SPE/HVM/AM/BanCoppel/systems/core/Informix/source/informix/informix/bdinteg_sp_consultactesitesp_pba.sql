CREATE PROCEDURE "informix".sp_consultactesitesp_pba( pEmpresa char(3),
                                                  pSucursal char(4),
                                                  pOrigen smallint,
                                                  pNumCte char(20),
                                                  pApellidoPat char(26),
                                                  pApellidoMat char(26),
                                                  pNombreCte1 char(26),
                                                  pNombreCte2 char(26) )

RETURNING CHAR(6), CHAR(20), CHAR(26), CHAR(26), CHAR(26), CHAR(26), CHAR(1), SMALLINT, CHAR(13), DATE,CHAR(7);

    ----------------------------------------------------------------------
    --ACTIVIDAD: Consulta los clientes
    --Bencoppel con situacion especial.
    --Elaboró : Diana Castellanos L.
    ----------------------------------------------------------------------
    --Modificación: Cambiar Tabla si_direcciones por si_direcciones_actual
    --y eliminar la secuencia de las condiciones.
    --Fecha: 28-02-2011
    --Modifico: Sergio Fernandez Cordero
    ----------------------------------------------------------------------

    DEFINE chrcodret      CHAR(6);
    DEFINE chrnumcte      CHAR(50);
    DEFINE chrnombre1     CHAR(26);
    DEFINE chrnombre2     CHAR(26);
    DEFINE chrapell_pat   CHAR(26);
    DEFINE chrapell_mat   CHAR(26);
    DEFINE chrsituacion   CHAR(1);
    DEFINE chrtelefono    CHAR(13);
    DEFINE chrzona        CHAR(7);
    DEFINE intcausa       INTEGER;
    DEFINE intflag        SMALLINT;
    DEFINE intcodret      INT;
    DEFINE dtefecha       DATE;

    BEGIN

    ON EXCEPTION SET intcodret
        IF intcodret <> 0 THEN
            LET chrcodret = intcodret;
            RETURN chrcodret, pNumCte, pApellidoPat, pApellidoMat, pNombreCte1, pNombreCte2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/consultasitesp.out";
    --- TRACE ON;

    LET chrcodret     = '000';
    LET chrnumcte     = '';
    LET chrnombre1    = '';
    LET chrnombre2    = '';
    LET chrapell_pat  = '';
    LET chrapell_mat  = '';
    LET chrsituacion  = '';
    LET chrtelefono   = '';
    LET chrzona       = '';
    LET intcausa      = 0;
    LET intflag       = 0;
    LET dtefecha      = '01-01-1900';

    set isolation to dirty read;
    set lock mode to wait 3;

    IF pNumCte <> '' THEN
        IF EXISTS ( SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte ) THEN
            SELECT NVL(TRIM(a.nombre1),''),
                   NVL(TRIM(a.nombre2),''),
                   NVL(a.apell_paterno,''),
                   NVL(a.apell_materno,''),
                   NVL(b.situacion,'' ),
                   NVL(b.causa,0),
                   NVL(e.telefono,''),
                   d.fecha_nac,
                   trim(lpad(c.numerociudad,3,'0') ) || trim(lpad(c.numerocolonia,4,'0'))
              INTO chrnombre1, chrnombre2, chrapell_pat, chrapell_mat, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona
              FROM bdinteg:si_cliente a
             INNER JOIN bdinteg:si_direcciones_actual c ON ( a.numcte = c.numcte and tipo_dir = 1 )
              LEFT JOIN bdisitesp:se_ctessitespcte b ON ( a.numcte = b.numcte )
              LEFT JOIN bdinteg:si_ctepf d ON ( a.numcte = d.numcte )
              LEFT OUTER JOIN si_telefonos_actual e ON ( e.numcte = a.numcte AND e.tipo_tel = 1 )
            WHERE a.numcte = pNumCte;

            RETURN chrcodret, pNumCte, chrapell_pat, chrapell_mat, chrnombre1, chrnombre2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona WITH RESUME;
        ELSE
            LET chrcodret = '001';  --- No existe numero de cliente
            RETURN chrcodret, pNumCte, chrapell_pat, chrapell_mat, chrnombre1, chrnombre2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona WITH RESUME;
        END IF;
    ELSE
        FOREACH
            SELECT a.numcte,
                   NVL(TRIM(a.nombre1),''),
                   NVL(TRIM(a.nombre2),''),
                   NVL(a.apell_paterno,''),
                   NVL(a.apell_materno,''),
                   NVL(b.situacion,'' ),
                   NVL(b.causa,0),
                   NVL(e.telefono,''),
                   d.fecha_nac,
                   trim(lpad(c.numerociudad,3,'0') ) || trim(lpad(c.numerocolonia,4,'0'))
              INTO chrnumcte, chrnombre1, chrnombre2, chrapell_pat, chrapell_mat, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona
              FROM bdinteg:si_cliente a
             INNER JOIN bdinteg:si_direcciones_actual c ON a.numcte = c.numcte and c.tipo_dir = 1
             LEFT JOIN bdisitesp:se_ctessitespcte b ON a.numcte = b.numcte
             LEFT JOIN bdinteg:si_ctepf d ON a.numcte = d.numcte
             LEFT OUTER JOIN si_telefonos_actual e ON ( e.numcte = a.numcte AND e.tipo_tel = 1 )
             WHERE TRIM(a.nombre1) || ' ' || TRIM(a.nombre2) = TRIM(pNombreCte1)
               AND a.apell_paterno = pApellidoPat
               AND a.apell_materno = pApellidoMat

            LET intflag = 1;

            RETURN chrcodret, chrnumcte, chrapell_pat, chrapell_mat, chrnombre1, chrnombre2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona WITH RESUME;
        END FOREACH;

        IF intflag = 0 THEN
            LET chrcodret = '002';  --- No existe nombre de cliente
            RETURN chrcodret, chrnumcte, chrapell_pat, chrapell_mat, chrnombre1, chrnombre2, chrsituacion, intcausa, chrtelefono, dtefecha, chrzona WITH RESUME;
        END IF;

    END IF;

    END;

END PROCEDURE;