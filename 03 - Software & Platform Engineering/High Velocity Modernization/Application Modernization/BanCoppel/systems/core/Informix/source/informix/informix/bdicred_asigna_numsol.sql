CREATE PROCEDURE "informix".asigna_numsol(o_empresa      CHAR(3),
			       o_num_producto CHAR(4),
			       o_numcte       CHAR(20))
RETURNING CHAR(5), CHAR(20);


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

 
-- *********** INICIA PROCESO DE ASIGNACION ******************
	
	SELECT COUNT(*) INTO vcuantas FROM bdisolic:ss_solicitudes
	 WHERE numcte = o_numcte
	   AND num_producto = o_num_producto 
	   AND status_solicitud <>'AP'
	   AND status_solicitud[1,1] <> 'R';

	IF vcuantas > 0 THEN
		LET vcod_ret = 500;
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