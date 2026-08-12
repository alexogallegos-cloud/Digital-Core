CREATE PROCEDURE "informix".sp_consultahuellactebcoenlinea (pTipo CHAR(1), pNumcte CHAR(20))
RETURNING CHAR(5), INTEGER, SMALLINT, CHAR(942), CHAR(942), INTEGER, INTEGER, SMALLINT, CHAR(1);

    DEFINE vCodret     CHAR(5);
    DEFINE vsqlerr     INTEGER;
    DEFINE visamerr    INTEGER;
    DEFINE vNumcte     INTEGER;
    DEFINE vSecuencia  SMALLINT;
    DEFINE vMapad      CHAR(942);
    DEFINE vMapai      CHAR(942);
    DEFINE vReferencia INTEGER;
    DEFINE vSucursal   INTEGER;
    DEFINE vNumciudad  SMALLINT;
    DEFINE vSexo       CHAR(1);

    LET vCodret = "000";
    LET vNumcte = 0;
    LET vSecuencia = 0;
    LET vMapad = "";
    LET vMapai = "";
    LET vReferencia = 0;
    LET vSucursal = 0;
    LET vNumciudad = 0;
    LET vSexo = "";

    BEGIN
    
    ON EXCEPTION SET vsqlerr,visamerr
        IF vsqlerr != 0 THEN
            LET vcodret = vsqlerr;
            RETURN vCodret, vNumcte, vSecuencia, vMapad, vMapai, vReferencia, vSucursal, vNumciudad, vSexo;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO '/tmp/huellas.out';
    --- TRACE ON;

    -- // Verifica Recepcion correcta de Parametro
    IF pNumcte IS NULL OR Trim(pNumcte) = "" THEN
        LET vCodret = "110";
        RETURN vCodret, vNumcte, vSecuencia, vMapad, vMapai, vReferencia, vSucursal, vNumciudad, vSexo;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF pTipo = "1" THEN
        SELECT {+INDEX(si_cte_huella ix_huellanew), +INDEX(si_cliente idx_si_clientex), +INDEX(si_direcciones_actual idx_numcte)}
               ctehuella.numcte::INTEGER, ctehuella.secuencia, ctehuella.dmapa, ctehuella.imapa, 
               NVL(cte.numcte_ref::INTEGER, 0) AS numcte_ref, cte.sucursal::INTEGER, dir.numerociudad, pf.sexo
          INTO vNumcte, vSecuencia, vMapad, vMapai, vReferencia, vSucursal, vNumciudad, vSexo
          FROM si_cte_huella ctehuella, 
               si_cliente cte, 
               si_direcciones_actual dir, 
               si_ctepf pf
         WHERE ctehuella.numcte = TRIM(pNumcte)         
           AND cte.numcte = ctehuella.numcte
           AND dir.numcte = ctehuella.numcte
           AND pf.numcte = ctehuella.numcte
           AND ctehuella.estado = 'A'
       --- AND dir.secuencia = (SELECT {+INDEX(si_direcciones inx_direcciones)} MAX(secuencia) FROM si_direcciones WHERE numcte = TRIM(pNumcte) AND tipo_dir = 1);
           AND dir.tipo_dir = '1';
           
        IF vMapad IS NULL OR vMapai IS NULL THEN
            LET vCodret = "132";
            RETURN vCodret, vNumcte, vSecuencia, vMapad, vMapai, vReferencia, vSucursal, vNumciudad, vSexo;
        END IF;
    END IF;

    RETURN vCodret, vNumcte, vSecuencia, vMapad, vMapai, vReferencia, vSucursal, vNumciudad, vSexo;
    
    END;
    
END PROCEDURE

DOCUMENT
"Consulta de Huella de cliente ",
"AUTOR: Jesus Montoya",
"FECHA: 23/Enero/2008",
"BD   : bdinteg",
"VER  : 1.1";

CREATE PROCEDURE "informix".sp_importarcatalogocalles(pSeparador CHAR(1), pNomArch CHAR(30), pEjecucion CHAR(1))
RETURNING CHAR(6), CHAR(80);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                     CHAR(6);
DEFINE cMensaje                     CHAR(80);

DEFINE cCadena                      CHAR(500);
DEFINE vPath                        CHAR(50);
------------------------------------------------------------

-- Creado: José de Jesús Almeida
-- Fecha: 20 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de obtener el total o una parcialidad de las calles del catalogo
---Nota: Este sp falla cuando se corre desde el visualizer pero funciona ok desde dbaccess.

-- Modificado por: MACF
-- Fecha: 07/06/2010
-- Agregar parámetro pEjecucion para determinar si es Automática o Manual

LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';
LET cCadena   = '';
LET vPath     = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
          LET cMensaje = error_info;
			    RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

  --SET DEBUG FILE TO "/tmp/ALMEIDA/SP_ImportarCatalogoCalles.out";
  --SET DEBUG FILE TO "/home/syscobra/domicilios/enviosbancoppel/SP_ImportarCatalogoCalles.out";
  --TRACE ON;

    IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'si_catcalles_coppel'  AND dbsname = 'bdinteg') THEN
                    DROP TABLE si_catcalles_coppel;
    END IF;

    CREATE TABLE si_catcalles_coppel
  (
    numerocalle     integer not null ,
    nombrecalle     char(30),   
    primary key (numerocalle) constraint pk_si_catcalles_coppel
  );

    if pEjecucion = 'A' then
          select valor into vPath 
          from bdinteg:si_param_dom 
          where cod_param = 12;
    
          LET cCadena = 'echo "load from ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(pNomArch,1,LENGTH(pNomArch)) || ' delimiter ''' || pSeparador || ''' insert into bdinteg:si_catcalles_coppel" >' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catcalles.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'dbaccess bdinteg ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catcalles.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
          let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catcalles.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
    else

    LET cCadena = 'echo "load from ' || '/tmp/' || SUBSTR(pNomArch,1,LENGTH(pNomArch)) || ' delimiter ''' || pSeparador || ''' insert into bdinteg:si_catcalles_coppel" > /tmp/importa_si_catcalles.sql';

    System SUBSTR(cCadena,1,LENGTH(cCadena));

    let cCadena = 'dbaccess bdinteg /tmp/importa_si_catcalles.sql';

    System SUBSTR(cCadena,1,LENGTH(cCadena));

    let cCadena = 'rm /tmp/importa_si_catcalles.sql';

    System SUBSTR(cCadena,1,LENGTH(cCadena));

    end if;
    
    ALTER TABLE si_catcalles_coppel ADD b_conciliado CHAR(1) DEFAULT 'F';


RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;