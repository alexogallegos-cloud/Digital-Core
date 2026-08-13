CREATE PROCEDURE "informix".sp_consultarcatalogociudades(pTipo INTEGER)

RETURNING CHAR(6), CHAR(80), INTEGER, CHAR(30), CHAR(4), INTEGER, CHAR(4), INTEGER, INTEGER, DATE,
          INTEGER, INTEGER, INTEGER, INTEGER, CHAR(1), CHAR(1), INTEGER, CHAR(30);
              
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			               INTEGER;
DEFINE isam_err 		               INTEGER;
DEFINE error_info		               CHAR(80);
DEFINE cCod_ret                        CHAR(6);
DEFINE cMensaje                        CHAR(80);

DEFINE vnumerociudad                   INTEGER;
DEFINE vnombreciudad                   CHAR(30);
DEFINE vinicialciudad                  CHAR(4);
DEFINE vnumeroestado                   INTEGER; 
DEFINE vinicialestado                  CHAR(4);
DEFINE vsalariominimo                  INTEGER;
DEFINE vivaciudad                      INTEGER;
DEFINE vantiguedadciudad               DATE;
DEFINE vgerentezona                    INTEGER;
DEFINE vregioncobranzas                INTEGER;
DEFINE vunificaciudadescobranzas       INTEGER;
DEFINE vgerentecobranzas               INTEGER; 
DEFINE vregionestadodecuenta           CHAR(1);
DEFINE vtipo_ciudad                    CHAR(1);
DEFINE vnumerociudadcoppel             INTEGER;
DEFINE vnombreciudadcoppel             CHAR(30);

LET vnumerociudad                   = 0;
LET vnombreciudad                   = '';
LET vinicialciudad                  = '';
LET vnumeroestado                   = 0; 
LET vinicialestado                  = '';
LET vsalariominimo                  = 0;
LET vivaciudad                      = 0;
LET vantiguedadciudad               = '';
LET vgerentezona                    = 0;
LET vregioncobranzas                = 0;
LET vunificaciudadescobranzas       = 0;
LET vgerentecobranzas               = 0; 
LET vregionestadodecuenta           = '';
LET vtipo_ciudad                    = '';
LET vnumerociudadcoppel             = 0;
LET vnombreciudadcoppel             = '';


LET cCod_ret                            = '00000';
LET cMensaje                            = 'Proceso Existoso';


  /*
  Creado por José Almeida,
  fecha de creación 23 de octubre de 2009,
  crear en bdinteg,
  el proposito de este procedimento es el de 
  hacer una consulta al catalogo de datos conciliados 
  a los que seran modificados o insertados, y tambien a aquellos
  que no fueron conciliados por que existian y 
  no tenian diferencias de el catologo de ciudades.
  */

BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje, vnumerociudad, vnombreciudad , vinicialciudad, vnumeroestado, vinicialestado, 
                   vsalariominimo, vivaciudad, vantiguedadciudad, vgerentezona, vregioncobranzas,
                   vunificaciudadescobranzas, vgerentecobranzas, vregionestadodecuenta, vtipo_ciudad,
                   vnumerociudadcoppel, vnombreciudadcoppel;
	    END EXCEPTION;
        
        
        IF(pTipo = 1) THEN
        
        FOREACH
        
           SELECT  numerociudad, nombreciudad , inicialciudad, 
                   numeroestado, inicialestado, salariominimo, ivaciudad, antiguedadciudad,
                   gerentezona,regioncobranzas, unificaciudadescobranzas, gerentecobranzas,
                   regionestadodecuenta, tipo_ciudad, numerociudadcoppel, nombreciudadcoppel
            INTO   vnumerociudad, vnombreciudad , vinicialciudad, vnumeroestado, vinicialestado, 
                   vsalariominimo, vivaciudad, vantiguedadciudad, vgerentezona, vregioncobranzas,
                   vunificaciudadescobranzas, vgerentecobranzas, vregionestadodecuenta, vtipo_ciudad,
                   vnumerociudadcoppel, vnombreciudadcoppel
            FROM   BDINTEG:si_catciudades_bcpl_cpl
           WHERE   tipo_actualizacion = 'I'

          RETURN   cCod_ret, cMensaje, vnumerociudad, vnombreciudad , vinicialciudad, vnumeroestado, vinicialestado, 
                   vsalariominimo, vivaciudad, vantiguedadciudad, vgerentezona, vregioncobranzas,
                   vunificaciudadescobranzas, vgerentecobranzas, vregionestadodecuenta, vtipo_ciudad,
                   vnumerociudadcoppel, vnombreciudadcoppel WITH RESUME;
                   
          END FOREACH;
          
          ELIF (pTipo = 2) THEN
           
           FOREACH
           
           SELECT  numerociudad, nombreciudad , inicialciudad, 
                   numeroestado, inicialestado, salariominimo, ivaciudad, antiguedadciudad,
                   gerentezona,regioncobranzas, unificaciudadescobranzas, gerentecobranzas,
                   regionestadodecuenta, tipo_ciudad, numerociudadcoppel, nombreciudadcoppel
            INTO   vnumerociudad, vnombreciudad , vinicialciudad, vnumeroestado, vinicialestado, 
                   vsalariominimo, vivaciudad, vantiguedadciudad, vgerentezona, vregioncobranzas,
                   vunificaciudadescobranzas, vgerentecobranzas, vregionestadodecuenta, vtipo_ciudad,
                   vnumerociudadcoppel, vnombreciudadcoppel
            FROM   BDINTEG:si_catciudades_bcpl_cpl
           WHERE   tipo_actualizacion = 'M'

          RETURN   cCod_ret, cMensaje, vnumerociudad, vnombreciudad , vinicialciudad, vnumeroestado, vinicialestado, 
                   vsalariominimo, vivaciudad, vantiguedadciudad, vgerentezona, vregioncobranzas,
                   vunificaciudadescobranzas, vgerentecobranzas, vregionestadodecuenta, vtipo_ciudad,
                   vnumerociudadcoppel, vnombreciudadcoppel WITH RESUME;
                   
          END FOREACH;
                   
           ELIF (pTipo = 3) THEN
           
         FOREACH
         
           SELECT  numerociudad, nombreciudad , inicialciudad, 
                   numeroestado, inicialestado, salariominimo, ivaciudad, antiguedadciudad,
                   gerentezona,regioncobranzas, unificaciudadescobranzas, gerentecobranzas,
                   regionestadodecuenta, tipo_ciudad, numerociudadcoppel, nombreciudadcoppel
            INTO   vnumerociudad, vnombreciudad , vinicialciudad, vnumeroestado, vinicialestado, 
                   vsalariominimo, vivaciudad, vantiguedadciudad, vgerentezona, vregioncobranzas,
                   vunificaciudadescobranzas, vgerentecobranzas, vregionestadodecuenta, vtipo_ciudad,
                   vnumerociudadcoppel, vnombreciudadcoppel
            FROM   BDINTEG:si_catciudades_coppel
           WHERE   b_conciliado = 'F'

          RETURN   cCod_ret, cMensaje, vnumerociudad, vnombreciudad , vinicialciudad, vnumeroestado, vinicialestado, 
                   vsalariominimo, vivaciudad, vantiguedadciudad, vgerentezona, vregioncobranzas,
                   vunificaciudadescobranzas, vgerentecobranzas, vregionestadodecuenta, vtipo_ciudad,
                   vnumerociudadcoppel, vnombreciudadcoppel WITH RESUME;
                   
          END FOREACH;
          
          ELSE
          
               LET cCod_ret = '00001';
               LET cMensaje = 'El parametro es incorrecto';
               
          RETURN   cCod_ret, cMensaje, vnumerociudad, vnombreciudad , vinicialciudad, vnumeroestado, vinicialestado, 
                   vsalariominimo, vivaciudad, vantiguedadciudad, vgerentezona, vregioncobranzas,
                   vunificaciudadescobranzas, vgerentecobranzas, vregionestadodecuenta, vtipo_ciudad,
                   vnumerociudadcoppel, vnombreciudadcoppel;               
                
          
          END IF;
          END;
          END PROCEDURE;