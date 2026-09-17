CREATE PROCEDURE "informix".asigna_numsol(o_empresa CHAR(3),o_producto CHAR(4))
RETURNING CHAR(5) AS retorno, 
		  CHAR(20) As solicitud;

--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificion: Se modifica el sp para que calcule el siguiente num de solicitud 
--             de la tarjeta de credito Coppel".
-- Fecha de modificación: 07-01-2009
-- Proyecto: Caja Unica.
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--Modificación: Se modifica para que asigne un consecutivo de solicitud para el 
--                producto Préstamo Personal.
--Fecha de modificación: 09-09-2009
--Petición: RQM 10 108 Préstamo Personal
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--Modificación: Se modifica para parametrizar las consultas que se realizan
--              para generar el número de solicitud correspondiente al producto 
--              recibido como parámetro.
--Fecha de modificación: 03-11-2009
--Petición: RQM 10 108 Préstamo Personal
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--Modificación: Se renombra para que se unifique con el spl productivo.
--		     Se tomó el spl asigna_numsol_cjunk versión que se
--		     tomó para alta única, misma que ahora reemplazará
--		     al spl que actualmente existe en producción.
--Fecha de modificación: 05-01-2010
--Petición: RQM 10 108 Préstamo Personal
--------------------------------------------------------------------------------

-- DEFINICION DE VARIABLES
DEFINE vsqlerr              INTEGER;
DEFINE vcodret              CHAR(5);
DEFINE vnum_solicitud       CHAR(20);
DEFINE vcuantas             SMALLINT;
DEFINE vlongsol             SMALLINT;
DEFINE vdivisa              CHAR(2);
define vsignumsol           INTEGER;
define vdiferencia,i        SMALLINT;
define v_digito             CHAR(1);
DEFINE vcodsolic            CHAR(2); -- Indica los digitos que se le antepondran al num. solicitud. Este depende del producto
DEFINE vrestar_pos          INTEGER; -- Indica las posiciones que se tendran reservadas para los digitos a agregar a la solicitud.
                            -- ( indicadas por la variable vcodsolic). Depende del tipo de producto.
DEFINE ccod_param           CHAR(3);

-- ASIGNACION DE VARIABLES
LET vsqlerr = 0;
LET vcodret = "00000";
LET vnum_solicitud ="???????????????";
LET v_digito ="?";
LET vcuantas = 0;
LET vcodsolic= '';
LET vrestar_pos= 0;

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
    --  DROP TABLE signumero;
      LET vcodret=vsqlerr;
      RETURN vcodret,vnum_solicitud;
   END IF;
END EXCEPTION;

--SET ISOLATION COMMITTED READ;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 10;

  --SET DEBUG FILE TO "/tmp/asigna_numsol.out";
  --TRACE ON;

-- *********** INICIA PROCESO DE ASIGNACION ******************
   SELECT valor 
     INTO vlongsol
     FROM bdicred:sd_param
    WHERE cod_param = '8';

   LET vlongsol = vlongsol -1;

   SELECT secuencia_prod,prefijo_sol
     INTO vsignumsol,vcodsolic
     FROM bdisolic:ss_solic_producto
    WHERE empresa = o_empresa 
      AND num_producto = o_producto;

   IF vlongsol IS NULL OR vsignumsol IS NULL THEN
      LET vcodret="105";
      RETURN vcodret,vnum_solicitud;
   ELSE
      LET vrestar_pos = LENGTH(SUBSTR(vcodsolic,1,2));
      LET vnum_solicitud = vsignumsol;
      LET vsignumsol = vsignumsol + 1;

      UPDATE bdisolic:ss_solic_producto
         SET secuencia_prod = vsignumsol
       WHERE empresa = o_empresa 
       AND num_producto = o_producto;  
    
      LET vdiferencia = vlongsol - length(vnum_solicitud) - vrestar_pos;
      IF vdiferencia > 0 THEN
         FOR i = 1 TO vdiferencia
             LET vnum_solicitud = "0" || vnum_solicitud;
         END FOR;
      END IF;
      LET vnum_solicitud = TRIM(vcodsolic)||trim(vnum_solicitud);
   END IF;

   EXECUTE PROCEDURE bdicred:digvermod10(vnum_solicitud)
         INTO vcodret, v_digito;

   LET vnum_solicitud = TRIM(vnum_solicitud) || v_digito;

   RETURN vcodret, vnum_solicitud;
END
END PROCEDURE;