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