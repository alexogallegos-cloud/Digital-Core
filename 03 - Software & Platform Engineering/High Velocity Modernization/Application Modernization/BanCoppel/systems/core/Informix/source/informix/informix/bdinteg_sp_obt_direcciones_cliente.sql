CREATE PROCEDURE "informix".sp_obt_direcciones_cliente(pNumCte char(9))
RETURNING char(5), integer, char(1), char(20), char(40), char(10), char(10), char(60), char(100), char(30), char(5), char(80);

    --- Realizo   : Javier Humberto Calderon Zazueta
    --- Actividad : Obetener direcciones de cliente
    --- Solicitó  : Mauricio Leon Ibarra
    --- Fecha     : 25/05/2010
	
	--- Realizó		: Walber Castro
	--- Actividad	: Se modifica el order by de la consulta para que se respete casa-trabajo-envios
	--- Solicitó	: Mauricio León
	--- Fecha		: 02/09/2011

    DEFINE vCodret   char(5);
    DEFINE vCalle  char(40);
    DEFINE vNum_int char(10);
    DEFINE vNum_ext   char(10);
    DEFINE vColonia char(60);
    DEFINE vMun_del char(100);
    DEFINE vEstado char(30);
    DEFINE vCp char(5);
    DEFINE vObservaciones char(80);
    DEFINE vSecuencia integer;
    DEFINE vTipoDir char(1);
    DEFINE vDescTipoDir char(20);
    DEFINE sql_err integer;
	
    LET vCodret = '000';
    LET vCalle = '';
    LET vNum_int = '';
    LET vNum_ext = '';
    LET vColonia = '';
    LET vMun_del = '';
    LET vEstado = '';
    LET vCp = '';
    LET vObservaciones = '';
    LET vSecuencia = 0;
    LET vTipoDir = '';
    LET vDescTipoDir = '';

    SET LOCK MODE TO WAIT 3;
	
	BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vCodret = sql_err;
            RETURN vcodret, vSecuencia, vTipoDir, vDescTipoDir, vCalle, vNum_ext, vNum_int, vColonia, vMun_del, vEstado, vCp, vObservaciones;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION DIRTY READ;
    
    IF EXISTS(SELECT {+INDEX(bdinteg:"informix".si_direcciones_actual idx_diract_cte)} tipo_dir FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pNumCte) THEN
        FOREACH
            SELECT {+INDEX(bdinteg:"informix".si_direcciones_actual idx_diract_cte)} 
                   secuencia, tipo_dir
              INTO vSecuencia, vTipoDir
              FROM bdinteg:"informix".si_direcciones_actual
             WHERE numcte = pNumCte
             GROUP BY secuencia, tipo_dir
             ORDER BY tipo_dir ASC

            SELECT {+INDEX(bdinteg:"informix".si_direcciones_actual idx_diract_ctetpo)} 
                   nvl(desc_tipo_dir,''), nvl(ca.nombrecalle,''), nvl(numeroextcalle,''), nvl(numerointcalle,''), 
                   nvl(zo.nombrezona,''), nvl(cd.nombre,''), nvl(es.nombre,''), nvl(cod_postal,''), nvl(observaciones,'')
              INTO vDescTipoDir, vCalle, vNum_ext, vNum_int, vColonia, vMun_del, vEstado, vCp, vObservaciones
              FROM bdinteg:"informix".si_direcciones_actual AS dr
             INNER JOIN bdinteg:"informix".si_cat_tipo_direcciones AS tdr ON dr.tipo_dir = tdr.tipo_dir
             INNER JOIN bdinteg:"informix".si_estados AS es ON dr.estado = es.estado
             INNER JOIN bdinteg:"informix".si_ciudades AS cd ON dr.ciudad = cd.ciudad AND dr.estado = cd.estado
             INNER JOIN bdinteg:"informix".si_catcalles AS ca ON dr.numerocalle = ca.numerocalle
             INNER JOIN bdinteg:"informix".si_catzonas AS zo ON dr.numerociudad = zo.numerociudad AND dr.numerocolonia = zo.numerocolonia
             WHERE numcte = pNumCte 
               AND dr.tipo_dir = vTipoDir;

            RETURN vcodret, vSecuencia, vTipoDir, vDescTipoDir, vCalle, vNum_ext, vNum_int, vColonia, vMun_del, vEstado, vCp, vObservaciones WITH RESUME;

        END FOREACH;
    ELSE
        LET vCodret = '001';
        RETURN vcodret, vSecuencia, vTipoDir, vDescTipoDir, vCalle, vNum_ext, vNum_int, vColonia, vMun_del, vEstado, vCp, vObservaciones WITH RESUME;
    END IF;
    
    END;

END PROCEDURE;