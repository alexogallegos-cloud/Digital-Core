CREATE PROCEDURE  "informix".sp_envia_promocion_producto(o_empresa CHAR(3), o_Num_producto CHAR(4))
RETURNING CHAR(5)       AS cod_ret,
          CHAR(4)       AS num_promo,
          CHAR(50)      AS nombre_promo,
          DATE	        AS fecha_inicio,
          DATE          AS fecha_fin,
          INTEGER	    AS plazo,
          DECIMAL(10,2)	AS tasa;
		  

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************		  
DEFINE scod_ret     	  	CHAR(5);
DEFINE vsqlerr      	  	INTEGER;
DEFINE s_num_promo	 	  	CHAR(4);
DEFINE s_nombre_promo  	  	CHAR(50);
DEFINE s_fechaini   	  	DATE;
DEFINE s_fechafin  	    	DATE;
DEFINE s_plazo				INTEGER;
DEFINE s_tasa     	  		DECIMAL(10,2);
DEFINE vfecha_hoy   	  	DATE;
DEFINE s_flagtarjeta   	  	INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret          	= "00000";
LET vsqlerr           	= 0;
LET s_num_promo       	= "";
LET s_nombre_promo     	= "";
LET s_fechaini        	= "";
LET s_fechafin      	= "";
LET s_plazo        		= 0;
LET s_tasa          	= 0.0;
LET vfecha_hoy        	= "";
LET s_flagtarjeta       = 0;

		  
		  
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_num_promo, s_nombre_promo, s_fechaini, s_fechafin, s_plazo, s_tasa;
   END IF;
END EXCEPTION;

 --SET DEBUG FILE TO "/informix/miguel/envia_promocion_producto.out";
 --TRACE ON;
 
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy
    INTO vfecha_hoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = o_empresa;
	
	SELECT count(*)
	INTO s_flagtarjeta
	FROM bdicred:"informix".sd_definicion
	WHERE num_producto = o_Num_producto
	AND edocta_param = 'tdc';
	
	IF s_flagtarjeta = 0 THEN
		LET scod_ret = '00001';
		LET s_nombre_promo = 'Este producto no es Tarjeta de Credito';
		RETURN scod_ret, s_num_promo, s_nombre_promo, s_fechaini, s_fechafin, s_plazo, s_tasa;
	END IF;
	 
	 
	FOREACH
		select a.num_promo, a.nombre_promo, a.fechaini_promo ,a.fechafin_promo, b.plazo,b.tasa
		INTO s_num_promo, s_nombre_promo, s_fechaini, s_fechafin, s_plazo, s_tasa
		from bdicred:sd_promocion  a
		inner join  bdicred:sd_tasa_plazo b on a.num_promo = b.num_promo 
		WHERE vfecha_hoy between a.fechaini_promo and a.fechafin_promo
		and a.activo = b.plazo_activo
		and a.num_producto = b.num_producto
		and a.activo = b.plazo_activo
		and a.empresa = b.empresa
		and a.empresa = o_empresa
		and a.simulacred_act = 1
		and a.activo =1
		AND a.num_producto = o_Num_producto
		
		RETURN scod_ret, s_num_promo, s_nombre_promo, s_fechaini, s_fechafin, s_plazo, s_tasa WITH RESUME;
	END FOREACH;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene las promociones vigentes y activas para apagos fijos por producto de TDC"',
'CREATE :  Miguel Angel MartÃ­nez GalvÃ¡n',
'FECHA : 20/09/2018';

CREATE FUNCTION "informix".sp817_getrandomseed() RETURNING DECIMAL(10)
   DEFINE GLOBAL seed DECIMAL(10) DEFAULT NULL;
   RETURN seed;
END FUNCTION;