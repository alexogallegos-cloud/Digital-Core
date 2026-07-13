CREATE PROCEDURE "informix".asigna_numsol_web(o_empresa CHAR(3), o_num_producto CHAR(4), o_numcte CHAR(20))

RETURNING CHAR(5), CHAR(20);
--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificion: Se modifica el sp para que calcule el siguiente num de solicitud 
--             de la tarjeta de credito Coppel".
-- Fecha de modificaciÃ³n: 07-01-2009
-- Proyecto: Caja Unica.
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃ³n: Se modifica para que asigne un consecutivo de solicitud para el 
--                producto PrÃ©stamo Personal.
--Fecha de modificaciÃ³n: 09-09-2009
--PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃ³n: Se modifica para parametrizar las consultas que se realizan
--              para generar el nÃºmero de solicitud correspondiente al producto 
--              recibido como parÃ¡metro.
--Fecha de modificaciÃ³n: 03-11-2009
--PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃ³n: Se renombra para que se unifique con el spl productivo.
--		     Se tomÃ³ el spl asigna_numsol_cjunk versiÃ³n que se
--		     tomÃ³ para alta Ãºnica, misma que ahora reemplazarÃ¡
--		     al spl que actualmente existe en producciÃ³n.
--Fecha de modificaciÃ³n: 05-01-2010
--PeticiÃ³n: RQM 10 108 PrÃ©stamo Personal
--------------------------------------------------------------------------------

-- DEFINICION DE VARIABLES
DEFINE vsqlerr INTEGER;
DEFINE vcod_ret CHAR(5);
DEFINE vnum_solicitud CHAR(20);
DEFINE vcuantas SMALLINT;

-- ASIGNACION DE VARIABLES
LET vsqlerr = 0;
LET vcod_ret = "00000";
LET vnum_solicitud ="???????????????";
LET vcuantas = 0;

BEGIN
	ON EXCEPTION SET vsqlerr
	   IF vsqlerr != 0 THEN
		  LET vcod_ret=vsqlerr;
		  RETURN vcod_ret,vnum_solicitud;
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
-- *********** INICIA PROCESO DE ASIGNACION ******************
	
	SELECT COUNT(*) INTO vcuantas FROM bdisolic:ss_solicitudes
	 WHERE numcte = o_numcte
	   AND num_producto = o_num_producto 
	   AND status_solicitud <>'AP'
	   AND status_solicitud[1,1] <> 'R';

	IF vcuantas > 0 THEN
		LET vcod_ret = "00500";
		RETURN vcod_ret, vnum_solicitud;
	END IF
	
  	CREATE TEMP TABLE signumero
  		(numero CHAR(20));

	INSERT INTO signumero
	SELECT num_credito FROM bdicred:sd_maecred
	WHERE numcte = o_numcte
	   AND num_producto = o_num_producto;

	INSERT INTO signumero
	SELECT num_solicitud FROM bdisolic:ss_solicitudes
	WHERE numcte = o_numcte
	   AND num_producto = o_num_producto 
	   AND status_solicitud <>'AP'
	   AND status_solicitud[1,1] <> 'R';

	SELECT MAX(numero) INTO vnum_solicitud
	  FROM signumero;

	IF vnum_solicitud IS NULL THEN
		LET vnum_solicitud = "000";
		LET vnum_solicitud = TRIM(o_numcte) || TRIM(o_num_producto) || 
			             vnum_solicitud;
	ELSE
		LET vnum_solicitud = SUBSTR(vnum_solicitud, -3) + 1;
		LET vnum_solicitud = TRIM(o_numcte) || TRIM(o_num_producto) || 
			             vnum_solicitud;
	END IF

END

	RETURN vcod_ret, vnum_solicitud;

END PROCEDURE;