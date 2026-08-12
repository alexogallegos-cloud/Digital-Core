CREATE PROCEDURE "informix".sp_consultarcatalogocalles(pTipo INTEGER)

RETURNING CHAR(6), CHAR(80), INTEGER, CHAR(80);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE vnumerocalle                     INTEGER;
DEFINE vnombrecalle                     CHAR(30);


LET cCod_ret                            = '00000';
LET cMensaje                            = 'Proceso Existoso';
LET vnumerocalle                     = 0;
LET vnombrecalle                     = '';
BEGIN
  
  /*
  Creado por José Almeida,
  fecha de creación 23 de octubre de 2009,
  crear en bdinteg,
  el proposito de este procedimento es el de 
  hacer una consulta al catalogo de datos conciliados 
  a los que seran modificados o insertados, y tambien a aquellos
  que no fueron conciliados por que existian y 
  no tenian diferencias de el catologo de calles.
  */
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje, vnumerocalle, vnombrecalle;
	    END EXCEPTION;
        
       --SET DEBUG FILE TO "/tmp/ALMEIDA/SP_ConciliarCatalogoZonas.out";
       --TRACE ON;
       
       IF (pTipo = 1) THEN
       
       FOREACH
       
         SELECT numerocalle, nombrecalle
         INTO   vnumerocalle, vnombrecalle
         FROM   BDINTEG:si_catcalles_bcpl_cpl
         WHERE  tipo_actualizacion = 'I'
         
         RETURN cCod_ret, cMensaje, vnumerocalle, vnombrecalle WITH RESUME;
         
       END FOREACH;
      
       
       ELIF (pTipo = 2) THEN
       
       FOREACH
       
         SELECT numerocalle, nombrecalle
         INTO   vnumerocalle, vnombrecalle
         FROM   BDINTEG:si_catcalles_bcpl_cpl
         WHERE  tipo_actualizacion = 'M'
         
         RETURN cCod_ret, cMensaje, vnumerocalle, vnombrecalle WITH RESUME;
         
       END FOREACH;
       
       
        ELIF (pTipo = 3) THEN
       
       FOREACH
       
         SELECT numerocalle, nombrecalle
         INTO   vnumerocalle, vnombrecalle
         FROM   BDINTEG:si_catcalles_coppel
         WHERE  b_conciliado = 'F'
         
         RETURN cCod_ret, cMensaje, vnumerocalle, vnombrecalle WITH RESUME;
         
       END FOREACH;
       
       ELSE
               LET cCod_ret = '00001';
               LET cMensaje = 'El parametro es incorrecto';
        RETURN cCod_ret, cMensaje, vnumerocalle, vnombrecalle;
       
       END IF;
       
       END;
       END PROCEDURE;