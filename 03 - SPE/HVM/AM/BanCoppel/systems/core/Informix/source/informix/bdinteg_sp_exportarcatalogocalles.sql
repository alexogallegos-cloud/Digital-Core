CREATE PROCEDURE "informix".sp_exportarcatalogocalles(pCatalogo CHAR(1), pFechaAct DATE, pSeparador CHAR(1), pEjecucion CHAR(1))
RETURNING  CHAR(6), CHAR(80);
    
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE cCadena                          CHAR (500);
DEFINE vFechaArch                       DATE;
DEFINE vNomArch                         CHAR(30);
DEFINE vNomArchAux                      CHAR(40);
DEFINE vPathOri                         CHAR(50);
DEFINE vPath                            CHAR(50);
------------------------------------------------------------

-- Creado: José de Jesús Almeida Inzunza
-- Fecha: 19 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de obtener el total o una parcialidad de las calles del catalogo

-- Modificado por: MACF
-- Fecha: 03/06/2010
-- Agregar parámetro pEjecucion para determinar si es Automática o Manual

LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = '';
LET cCadena       = '';
LET vNomArch      = 'si_catcalles_';
LET vNomArchAux      = 'si_catcalles_Aux';
LET vPathOri        = '';
LET vPath         = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

--SET DEBUG FILE TO "/tmp/ALMEIDA/sp_ExportarCatalogoCalles.out";
  --SET DEBUG FILE TO "/ids10_uc9/macf/sp_ExportarCatalogoCalles.out";
  --TRACE ON;

    SELECT fecha_hoy
    INTO   vFechaArch
    FROM   bdinteg:si_fechas;
    
  --  LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';
    
    if pEjecucion = 'A' then
          select valor into vPathOri 
          from bdinteg:si_param_dom 
          where cod_param = 11;
    end if;
    Let vPath = TRIM(vPathOri);
    
     LET vNomArchAux = TRIM(vNomArchAux) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArchAux = TRIM(vNomArchAux);
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArch = TRIM(vNomArch);    
    
IF (pCatalogo = 1) THEN

    if pEjecucion = 'A' then
        LET cCadena = 'echo "unload to ' || trim(vPath) ||   trim(vNomArchAux) ||  ' DELIMITER ''' || pSeparador || ''' SELECT numerocalle, nombrecalle FROM BDINTEG:si_catcalles" >' || trim(vPath) || 'corre_si_catcalles.sql';
        System cCadena;
        let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catcalles.sql';
        System cCadena;
        LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
        SYSTEM cCadena;
        let cCadena = 'rm ' || trim(vPath) || 'corre_si_catcalles.sql';
        System cCadena;   
        let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
        System cCadena; 
    else
 /*
    LET cCadena = 'echo "unload to ' || '''/tmp/' ||   SUBSTR(vNomArch,1,LENGTH(vNomArch)) || '''' || ' DELIMITER ''' || pSeparador || ''' SELECT numerocalle, nombrecalle FROM BDINTEG:si_catcalles" > /tmp/corre_si_catcalles.sql';
    System cCadena;

    let cCadena = 'dbaccess bdinteg /tmp/corre_si_catcalles.sql';
    System cCadena;
  */
    let cCadena = 'rm /tmp/corre_si_catcalles.sql';
 --   System cCadena;
    
    end if;    
    
ELIF (pCatalogo = 0) THEN
       if pEjecucion = 'A' then
      /*      LET cCadena = 'echo "unload to ' || SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(vNomArch,1,LENGTH(vNomArch)) || '''' || ' DELIMITER ''' || pSeparador || ''' SELECT numerocalle, nombrecalle FROM BDINTEG:si_catcalles' 
               --  || ' WHERE f_ult_actualiza >= ''' || pFechaAct || '''" > /tmp/corre_si_catcalles.sql';
                   || '" > ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'corre_si_catcalles.sql';
            System cCadena;
            let cCadena = 'dbaccess bdinteg ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'corre_si_catcalles.sql';
            System cCadena; */
            let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'corre_si_catcalles.sql';
            --System cCadena;
       else
     /*LET cCadena = 'echo "unload to ' || '''/tmp/' || SUBSTR(vNomArch,1,LENGTH(vNomArch)) || '''' || ' DELIMITER ''' || pSeparador || ''' SELECT numerocalle, nombrecalle FROM BDINTEG:si_catcalles' 
               --  || ' WHERE f_ult_actualiza >= ''' || pFechaAct || '''" > /tmp/corre_si_catcalles.sql';
                   || '" > /tmp/corre_si_catcalles.sql';
                 
    System cCadena;

    let cCadena = 'dbaccess bdinteg /tmp/corre_si_catcalles.sql';
    System cCadena;
*/
    let cCadena = 'rm /tmp/corre_si_catcalles.sql';
  --  System cCadena;    

    end if;
ELSE

    LET cCod_ret = '00001';
    LET cMensaje = 'Parámetro de Catálogo Invalido';    
    RETURN cCod_ret, cMensaje;
   
END IF;    

LET cMensaje = TRIM(vNomArch);
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;