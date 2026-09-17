CREATE PROCEDURE "informix".sp_obtienegatbasicogeneral()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion  CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);
	DEFINE sTasa2			  DECIMAL(9,6);
	
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatbasicogeneral.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1400';
		
		SELECT max(gat_real),max(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '1400' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa1
		FROM bdicheq:sc_gat 
		WHERE rango_min = '0.00' 
		AND producto = '1400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat 
		WHERE rango_min = '200.01' 
		AND producto = '1400'
		AND fecha_publicacion = sFechaPublicacion;
		
		
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
	
	END;
	
END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivacheques()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);
	DEFINE sTasa2			  DECIMAL(9,6);
   
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivacheques.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
			END IF
		END EXCEPTION;
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1900';
		
		SELECT MAX(gat_real),max(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '1900' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa1
		FROM bdicheq:sc_gat 
		WHERE rango_min = '0.00' 
		AND producto = '1900'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat
		WHERE rango_min = '200.01'
		AND producto = '1900'
		AND fecha_publicacion = sFechaPublicacion;

		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
	
	END;
	
END PROCEDURE
DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2007",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivadigital()
   RETURNING CHAR(5), CHAR(10), DECIMAL(9,6), DECIMAL(9,6), DECIMAL(9,6), DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             INTEGER;
	DEFINE visamerr            INTEGER;
	DEFINE vdescerr            CHAR(50);
	DEFINE vcodret             CHAR(5);
	DEFINE vcodret2            CHAR(5);
    DEFINE vcodret3            CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			   DECIMAL(9,6);
	DEFINE sGatNominal		   DECIMAL(9,6);
	DEFINE sTasa1			   DECIMAL(9,6);
	DEFINE sTasa2			   DECIMAL(9,6);

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivadigital.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret,sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '2000';
		
		SELECT MAX(gat_real),MAX(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '2000' 
		AND fecha_publicacion = sFechaPublicacion;
	
		SELECT MAX(tasa)
		INTO sTasa1
		FROM bdicheq:sc_gat 
		WHERE rango_min = '0.00' 
		AND producto = '2000'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat 
		WHERE rango_min = '200.01' 
		AND producto = '2000'
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
	END;

END PROCEDURE
DOCUMENT
'SPL Extrae la Fecha Publicacion Maxima del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivagc()
   RETURNING CHAR(5), CHAR(10), DECIMAL(9,6), DECIMAL(9,6), DECIMAL(9,6);

	DEFINE cod_ret             	CHAR(5);
	DEFINE p_mensaje           	CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   	CHAR(10);
	DEFINE sGatReal			  	DECIMAL(9,6);
	DEFINE sGatNominal		  	DECIMAL(9,6);
	DEFINE sTasa1			  	DECIMAL(9,6);

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivaGC.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1;
			END IF
		END EXCEPTION;
	
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1300';
		
		SELECT MAX(gat_real),MAX(gat_nominal),MAX(tasa)
		INTO sGatReal,sGatNominal,sTasa1
		FROM bdicheq:sc_gat
		WHERE producto = '1300' 
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1;
		
	END;
	
END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivajovenes()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);
	DEFINE sTasa2			  DECIMAL(9,6);
   
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivajovenes.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '2500';
		
		SELECT MAX(gat_real),MAX(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '2500' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa1
		FROM bdicheq:sc_gat
		WHERE rango_min = '0.00' 
		AND producto = '1900'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat
		WHERE rango_min = '200.01' 
		AND producto = '2500'
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2;
	
	END;
	
END PROCEDURE
DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2007",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivaplatino()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);
	DEFINE sTasa2			  DECIMAL(9,6);
	DEFINE sTasa3			  DECIMAL(9,6);
	DEFINE sTasa4			  DECIMAL(9,6);
	DEFINE sTasa5			  DECIMAL(9,6);

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	LET sTasa2 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivaplatino.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2, sTasa3, sTasa4, sTasa5;
			END IF
		END EXCEPTION;
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '2400';
		
		SELECT max(gat_real),max(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '2400' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa1
		FROM bdicheq:sc_gat
		WHERE rango_min = '0.00' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa2
		FROM bdicheq:sc_gat
		WHERE rango_min = '200.01' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa3
		FROM bdicheq:sc_gat
		WHERE rango_min = '100000.01' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa4
		FROM bdicheq:sc_gat
		WHERE rango_min = '500000.01' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sTasa5
		FROM bdicheq:sc_gat 
		WHERE rango_min = '1000000.01' 
		AND producto = '2400'
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1, sTasa2, sTasa3, sTasa4, sTasa5;
	
	END;
	
END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatefectivaplus()
   RETURNING CHAR(5), CHAR(10), DECIMAL(9,6), DECIMAL(9,6), DECIMAL(9,6);

	DEFINE cod_ret             CHAR(5);
	DEFINE p_mensaje           CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   CHAR(10);
	DEFINE sGatReal			  DECIMAL(9,6);
	DEFINE sGatNominal		  DECIMAL(9,6);
	DEFINE sTasa1			  DECIMAL(9,6);

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sTasa1 = 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatefectivaplus.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1;
			END IF
		END EXCEPTION;
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1800';
		
		SELECT MAX(gat_real),MAX(gat_nominal),MAX(tasa)
		INTO sGatReal,sGatNominal,sTasa1
		FROM bdicheq:sc_gat
		WHERE producto = '1800' 
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sTasa1;
	
	END;

END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2023",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatinversioncreciente()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),
   DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             	CHAR(5);
	DEFINE p_mensaje           	CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion   	CHAR(10);
	DEFINE sGatReal			  	DECIMAL(9,6);
	DEFINE sGatNominal		  	DECIMAL(9,6);
	DEFINE sMes1				DECIMAL(9,6);
	DEFINE sMes2				DECIMAL(9,6);
	DEFINE sMes3				DECIMAL(9,6);
	DEFINE sMes4				DECIMAL(9,6);
	DEFINE sMes5				DECIMAL(9,6);
	DEFINE sMes6				DECIMAL(9,6);
	DEFINE sMes7				DECIMAL(9,6);
	DEFINE sMes8				DECIMAL(9,6);
	DEFINE sMes9				DECIMAL(9,6);
	DEFINE sMes10			  	DECIMAL(9,6);
	DEFINE sMes11			  	DECIMAL(9,6);
	DEFINE sMes12			  	DECIMAL(9,6);
   
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sGatReal = 0.00;
	LET sGatNominal = 0.00;
	LET sMes1 = 0.00;
	LET sMes2 = 0.00;
    LET sMes3 = 0.00;
	LET sMes4 = 0.00;
	LET sMes5 = 0.00;
	LET sMes6 = 0.00;
	LET sMes7 = 0.00;
	LET sMes8 = 0.00;
	LET sMes9 = 0.00;
	LET sMes10= 0.00;
	LET sMes11= 0.00;
	LET sMes12= 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatinversioncreciente.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sGatReal, sGatNominal, sMes1, sMes2, sMes3, sMes4, sMes5, sMes6, sMes7, sMes8, sMes9, sMes10, sMes11, sMes12;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdicheq:sc_gat 
		WHERE producto = '1100';
		
		SELECT MAX(gat_real),MAX(gat_nominal)
		INTO sGatReal,sGatNominal
		FROM bdicheq:sc_gat
		WHERE producto = '1100' 
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes1
		FROM bdicheq:sc_gat 
		WHERE mes = '1' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes2
		FROM bdicheq:sc_gat 
		WHERE mes = '2' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes3
		FROM bdicheq:sc_gat 
		WHERE mes = '3' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes4
		FROM bdicheq:sc_gat 
		WHERE mes = '4' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes5
		FROM bdicheq:sc_gat 
		WHERE mes = '5' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes6
		FROM bdicheq:sc_gat 
		WHERE mes = '6' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes7
		FROM bdicheq:sc_gat 
		WHERE mes = '7' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes8
		FROM bdicheq:sc_gat 
		WHERE mes = '8' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes9
		FROM bdicheq:sc_gat 
		WHERE mes = '9' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes10
		FROM bdicheq:sc_gat 
		WHERE mes = '10' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes11
		FROM bdicheq:sc_gat 
		WHERE mes = '11' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		SELECT MAX(tasa) 
		INTO sMes12
		FROM bdicheq:sc_gat 
		WHERE mes = '12' 
		AND producto = '1100'
		AND fecha_publicacion = sFechaPublicacion;
		
		RETURN cod_ret, sFechaPublicacion, sGatReal, sGatNominal, sMes1, sMes2, sMes3, sMes4, sMes5, sMes6, sMes7, sMes8, sMes9, sMes10, sMes11, sMes12;
	
	END;
	
END PROCEDURE

DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2007",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_obtienegatpagare()
   RETURNING CHAR(5), CHAR(10),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),
   DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),
   DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),
   DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6);

	DEFINE cod_ret             	CHAR(5);
	DEFINE p_mensaje           	CHAR(80);
	--DEFINICION VARIABLES EXCEPCION
	DEFINE vsqlerr             	INTEGER;
	DEFINE visamerr            	INTEGER;
	DEFINE vdescerr            	CHAR(50);
	DEFINE vcodret             	CHAR(5);
	DEFINE vcodret2            	CHAR(5);
    DEFINE vcodret3            	CHAR(50);
	--VARIABLES PARA USO EN PROCEDIMIENTO
	DEFINE sFechaPublicacion  CHAR(10);
	DEFINE sGatReal1	  DECIMAL(9,6);
	DEFINE sGatReal2	  DECIMAL(9,6);
	DEFINE sGatReal3	  DECIMAL(9,6);
	DEFINE sGatReal4	  DECIMAL(9,6);
	DEFINE sGatReal5	  DECIMAL(9,6);
	DEFINE sGatReal6	  DECIMAL(9,6);
	DEFINE sGatReal7	  DECIMAL(9,6);
	DEFINE sGatReal8	  DECIMAL(9,6);
	DEFINE sGatReal9	  DECIMAL(9,6);
	DEFINE sGatReal10	  DECIMAL(9,6);
	DEFINE sGatReal11	  DECIMAL(9,6);
	DEFINE sGatNominal1	  DECIMAL(9,6);
	DEFINE sGatNominal2	  DECIMAL(9,6);
	DEFINE sGatNominal3	  DECIMAL(9,6);
	DEFINE sGatNominal4	  DECIMAL(9,6);
	DEFINE sGatNominal5	  DECIMAL(9,6);
	DEFINE sGatNominal6	  DECIMAL(9,6);
	DEFINE sGatNominal7	  DECIMAL(9,6);
	DEFINE sGatNominal8	  DECIMAL(9,6);
	DEFINE sGatNominal9	  DECIMAL(9,6);
	DEFINE sGatNominal10  DECIMAL(9,6);
	DEFINE sGatNominal11  DECIMAL(9,6);
	DEFINE sTasa1		  DECIMAL(9,6);
	DEFINE sTasa2		  DECIMAL(9,6);
	DEFINE sTasa3		  DECIMAL(9,6);
	DEFINE sTasa4		  DECIMAL(9,6);
	DEFINE sTasa5		  DECIMAL(9,6);
	DEFINE sTasa6		  DECIMAL(9,6);
	DEFINE sTasa7		  DECIMAL(9,6);
	DEFINE sTasa8		  DECIMAL(9,6);
	DEFINE sTasa9		  DECIMAL(9,6);
	DEFINE sTasa10		  DECIMAL(9,6);
	DEFINE sTasa11		  DECIMAL(9,6);
	DEFINE sTasa12		  DECIMAL(9,6);
   
	
	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";
	--ASIGNACION VARIABLES EXCEPCION
	LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
	--ASIGNACION VARIABLES PARA USO EN PROCEDIMIENTO
	LET sFechaPublicacion = '1900-01-30';
	LET sTasa1 		 = 0.00;
	LET sTasa2 		 = 0.00;
    LET sTasa3 		 = 0.00;
	LET sTasa4 		 = 0.00;
	LET sTasa5 		 = 0.00;
	LET sTasa6 		 = 0.00;
	LET sTasa7 		 = 0.00;
	LET sTasa8 		 = 0.00;
	LET sTasa9 		 = 0.00;
	LET sTasa10		 = 0.00;
	LET sTasa11		 = 0.00;
	LET sTasa12		 = 0.00;
	LET sGatReal1	 = 0.00;
	LET sGatReal2	 = 0.00;
	LET sGatReal3	 = 0.00;
	LET sGatReal4	 = 0.00;
	LET sGatReal5	 = 0.00;
	LET sGatReal6	 = 0.00;
	LET sGatReal7	 = 0.00;
	LET sGatReal8	 = 0.00;
	LET sGatReal9	 = 0.00;
	LET sGatReal10	 = 0.00;
	LET sGatReal11	 = 0.00;
	LET sGatNominal1 = 0.00;
	LET sGatNominal2 = 0.00;
	LET sGatNominal3 = 0.00;
	LET sGatNominal4 = 0.00;
	LET sGatNominal5 = 0.00;
	LET sGatNominal6 = 0.00;
	LET sGatNominal7 = 0.00;
	LET sGatNominal8 = 0.00;
	LET sGatNominal9 = 0.00;
	LET sGatNominal10= 0.00;
	LET sGatNominal11= 0.00;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
		ON EXCEPTION SET vsqlerr, visamerr, vdescerr
			SET DEBUG FILE TO "/tmp/sp_obtienegatpagare.err";
			TRACE ON;
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				LET vcodret2 = visamerr;
				LET vcodret3 = vdescerr;
				RETURN vcodret, sFechaPublicacion, sTasa1, sTasa2, sTasa3, sTasa4, sTasa5, sTasa6, sTasa7, sTasa8, sTasa9, sTasa10, sTasa11,
				sGatNominal1,sGatNominal2,sGatNominal3,sGatNominal4,sGatNominal5,sGatNominal6,sGatNominal7,sGatNominal8,sGatNominal9,sGatNominal10,sGatNominal11,
				sGatReal1,sGatReal2,sGatReal3,sGatReal4,sGatReal5,sGatReal6,sGatReal7,sGatReal8,sGatReal9,sGatReal10,sGatReal11;
			END IF
		END EXCEPTION;
		
		SELECT MAX(fecha_publicacion) 
		INTO sFechaPublicacion 
		FROM bdinvers:sv_gat;
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa1, sGatReal1, sGatNominal1
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 28 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 28);

		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa2, sGatReal2, sGatNominal2
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio =  60
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 60);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa3, sGatReal3, sGatNominal3
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 91 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 91);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa4, sGatReal4, sGatNominal4
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 120
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 120);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa5, sGatReal5, sGatNominal5
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 150 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 150);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa6, sGatReal6, sGatNominal6
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 180 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 180);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa7, sGatReal7, sGatNominal7
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 210 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 210);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa8, sGatReal8, sGatNominal8
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 240 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 240);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa9, sGatReal9, sGatNominal9
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 270 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 270);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa10, sGatReal10, sGatNominal10
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 300 
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 300);
		
		SELECT MAX(tasa), MAX(gat_real), MAX(gat_nomina) 
		INTO sTasa11, sGatReal11, sGatNominal11
		FROM bdinvers:sv_gat 
		WHERE plazo_inicio = 330
		AND fecha_publicacion = (SELECT MAX(fecha_publicacion)FROM bdinvers:sv_gat WHERE plazo_inicio = 330);
		
		RETURN cod_ret, sFechaPublicacion, sTasa1, sTasa2, sTasa3, sTasa4, sTasa5, sTasa6, sTasa7, sTasa8, sTasa9, sTasa10, sTasa11,
		sGatNominal1,sGatNominal2,sGatNominal3,sGatNominal4,sGatNominal5,sGatNominal6,sGatNominal7,sGatNominal8,sGatNominal9,sGatNominal10,sGatNominal11,
		sGatReal1,sGatReal2,sGatReal3,sGatReal4,sGatReal5,sGatReal6,sGatReal7,sGatReal8,sGatReal9,sGatReal10,sGatReal11;
	
	END;
	
END PROCEDURE
DOCUMENT
'SPL Extrae la Fecha Publicacion, Gat Real, Gat Nominal y Tasa Maximas del Producto',
"MODIFICO : Julian Reyna",
"FECHA : 03/Octubre/2007",
"Ver.  : 1.1",
"BD    : bdicheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_dispercionnomina_bpi()

-- ******************************************************************************************
-- Realizo   : Martin Valenzuela Ojeda, Armando Mercado
-- Proyecto  : Dispersion Nomina BanCoppel
-- Actividad : Ejecuta el proceso para la dispersion de la nomina,
--             actualiza el campo status en el detalle de aquellos empleados
--             que si se les ejecuto el pago de la nomina y
--             aquellos que por algun motivo no se les disperso su sueldo.
--             Tambien actualiza el encabezado para aquellos archivos que fueron dispersados,
--             ejecutando las validaciones correspondientes.
--             Este store sera ejecutado para varios archivos en Batch
-- Fecha     : Abril de 2008
-- ******************************************************************************************

RETURNING CHAR(5);

-- // DefiniciÃ³n de Variables
DEFINE GLOBAL mtotalregspei             INTEGER	DEFAULT 0;

DEFINE cNumeroEmpresa                   CHAR(3);
DEFINE dFechaGeneracion                 DATE;
DEFINE IFolioArchivo                    INTEGER;
DEFINE dFechaActual                     DATE;
DEFINE cEstatusCta                      CHAR(1);
DEFINE cNumeroCuentaEmpleado            CHAR(20);
DEFINE cNumeroEmpleado                  CHAR(10);
DEFINE mImporteEmpleado                 MONEY(14,3);
DEFINE dFechaAplicacion                 DATE;
DEFINE cHoraActual                      DATETIME HOUR TO SECOND;
DEFINE cNumeroTarjeta                   CHAR(20);
DEFINE mImporteAbonado                  MONEY(16,3);
DEFINE mImporteNoAbonado                MONEY(16,3);
DEFINE mImporteTotalAplicado            MONEY(16,3);
DEFINE siSaldoDisponible                SMALLINT;
DEFINE mTotalNoPagado                   MONEY(16,3);
DEFINE mTotalComisionDispercionIvaEmp   MONEY(14,3);
DEFINE mImporteTotalEnc                 MONEY(14,3);
DEFINE mSaldoActual                     MONEY(14,3);
DEFINE iNumeroRegistros                 INTEGER;
DEFINE bPrimerEmpleado                  BOOLEAN;
DEFINE bSiguienteEmpleado               BOOLEAN;
DEFINE cCodRet                          CHAR(3);
DEFINE cMensaje                         CHAR(100);
DEFINE mTotaliva                        MONEY(14,3);
DEFINE mTotalComision                   MONEY(14,3);
DEFINE iCodigoEstatus                   INTEGER;
DEFINE vsqlerr                          INTEGER;
DEFINE vcodret                          VARCHAR(6);
DEFINE p_mensaje                        VARCHAR(100);
DEFINE cNumeroFolio                     CHAR(16);
DEFINE cNombreArchivo                   CHAR(30);
DEFINE vtranret                         CHAR(4);
DEFINE vfechoy                          DATE;
DEFINE vsdodisp                         MONEY(14,2);
DEFINE vmontoret                        MONEY(14,2);
DEFINE cFolioDispercion                 CHAR(16);
DEFINE mComisionAplicado                MONEY(16,3);
DEFINE mIvaAplicado                     MONEY(16,3);
DEFINE cNombreArchivoConciliacion       CHAR(20);
DEFINE cCuentaEje                       CHAR(20);
DEFINE cCuentaEjeClabe					CHAR(20);
DEFINE cUsuarioAutoriza                 CHAR(8);
DEFINE siValorStatus					SMALLINT;

-- // Variables del sp: conciliacionDispercionNomina
DEFINE v_cCodRet                        CHAR(5);

-- // Nuevas Variables
DEFINE siValorConcepto                  SMALLINT;
DEFINE siValorConceptoAnterior          SMALLINT;
DEFINE cValorTransaccion                CHAR(4);
DEFINE cValorTipoTransaccion            CHAR(3);
DEFINE cTransaccAbono                   CHAR(4);
DEFINE cTransaccCargo                   CHAR(4);
DEFINE mMontoTransComiDisp              MONEY(16,2);
DEFINE mMontoTransComiAper              MONEY(16,2);
DEFINE mMontoTransIvaDisp               MONEY(16,2);
DEFINE mMontoTransIvaAper               MONEY(16,2);
DEFINE mMontoFijo                       MONEY(16,2);
DEFINE mTotalPagado                     MONEY(16,3);
DEFINE mTotalCargo                      MONEY(16,3);
DEFINE cTransaccComiDisp                CHAR(4);    -- // Aqui se traera el 0394
DEFINE cTransacIvaDisp                  CHAR(4);    -- // Aqui se traera el 0396
DEFINE mImporteEmpleadoCuentaEje        MONEY(16,3);
DEFINE mImporteEmpleadoComisionMasIva   MONEY(16,3);
DEFINE cEstatusCuenta                   CHAR(1);
DEFINE vcodretCargo1                    CHAR(6);
DEFINE vcodretCargo2                    CHAR(6);
DEFINE vcodretCargo3                    CHAR(6);
DEFINE vBegin                           CHAR(1);
DEFINE mIvaPorEmpleado                  MONEY(16,2);
DEFINE siTipoEmpresa                    SMALLINT ;
DEFINE cSucursalAbono                   CHAR(4);
DEFINE cSucursalCargo                   CHAR(4);
DEFINE cRecDatonoUtilizableNOperacion   CHAR(4);
DEFINE siVuelta                         INTEGER ;
DEFINE cCargo               			CHAR(2);
DEFINE cAbono               			CHAR(2);
DEFINE cAceptaProducto         			CHAR(50);
DEFINE iContador						INTEGER;
DEFINE vexiste_encab                    CHAR(17);
DEFINE vexiste_ctaeje                   CHAR(20);
DEFINE vexiste_cta                      CHAR(20);
DEFINE cProducto                        CHAR(20);
DEFINE vexiste_sec                      SMALLINT;
DEFINE iNumeroRegistrosAplicados        INTEGER ;
DEFINE vspei                            CHAR(1);
DEFINE mtotalspei                       MONEY(16,3);
DEFINE mtotalcomspei                    MONEY(16,3);
DEFINE mtotalivaspei                    MONEY(16,3);
DEFINE vcomisionspei                    MONEY(16,3);
DEFINE vcomisionspei_gral               MONEY(16,3);  --aqui
DEFINE vnombre_empresa                  CHAR(40);
DEFINE vnumcte_empresa                  CHAR(20); 
DEFINE vrfc_empresa                     CHAR(13);
DEFINE vnombre_beneficiario             CHAR(40);
DEFINE verror                           CHAR(100);
DEFINE vcverastreo                      CHAR(30);
DEFINE vcvebanco_benef					CHAR(5);
DEFINE vcvebanco_cta					CHAR(3);
DEFINE mDispCtaBcoppel					MONEY;
DEFINE mDispCtaOtroBco					MONEY;
--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
DEFINE vExcentaComision					INTEGER;
DEFINE cProductoEje                     CHAR(20);

-- // VALORES INICIALES
LET siValorStatus = 0;
LET p_mensaje = " ";
LET dFechaActual = '' ;
LET cEstatusCta = '' ;
LET cNumeroCuentaEmpleado = '';
LET cNumeroEmpleado = '';
LET mImporteEmpleado = 0;
LET dFechaAplicacion = '';
LET cHoraActual = '' ;
LET cNumeroTarjeta = '';
LET mImporteAbonado = 0;
LET mImporteNoAbonado = 0;
LET mImporteTotalAplicado = 0;
LET siSaldoDisponible = 0 ;
LET mTotalNoPagado = 0;
LET mTotalComisionDispercionIvaEmp = 0;
LET mImporteTotalEnc = 0;
LET mSaldoActual = 0;
LET iNumeroRegistros = 0;
LET iCodigoEstatus = 0;
LET bPrimerEmpleado = "T" ;
LET bSiguienteEmpleado = "F" ;
LET cNombreArchivo = "";
LET iNumeroRegistrosAplicados = 0;
LET siValorConceptoAnterior = 0;
LET cValorTransaccion = '';
LET cValorTipoTransaccion = '';
LET cTransaccAbono = '';
LET cTransaccCargo = '';
LET mMontoTransComiDisp = 0;
LET mMontoTransComiAper = 0;
LET mMontoTransIvaDisp = 0;
LET mMontoTransIvaAper = 0;
LET mMontoFijo = 0;
LET mTotalPagado = 0;
LET mTotalCargo = 0;
LET cTransaccComiDisp = '';
LET cTransacIvaDisp = '';
LET mImporteTotalEnc = 0;
LET mImporteEmpleadoCuentaEje = 0;
LET mImporteEmpleadoComisionMasIva = 0;
LET cEstatusCuenta = '';
LET vBegin = 'N';
LET mIvaPorEmpleado = 0;
LET siTipoEmpresa = 0;
LET cSucursalAbono = '';
LET cSucursalCargo = '';
LET siVuelta = 0;
LET cCargo='';
LET cAbono='';
LET cAceptaProducto = '';
LET cNumeroFolio = '';
LET iContador = 0;
LET vexiste_encab = '';
LET vexiste_ctaeje = '';
LET vexiste_cta = '';
LET vexiste_sec = 0;
LET vspei = 0;
LET mtotalspei = 0;
LET mtotalregspei = 0;
LET mtotalcomspei = 0;
LET mtotalivaspei = 0;
LET vcomisionspei = 0;
LET vcomisionspei_gral = 0; --aqui
LET vnombre_empresa = ' ';
LET vnumcte_empresa = ' ';
LET vrfc_empresa = ' ';
LET vnombre_beneficiario = ' ';
LET verror = ' ';
LET vcverastreo = ' ';
LET vcvebanco_benef = ' ';
LET vcvebanco_cta = ' ';
LET cproducto = '';
LET mDispCtaBcoppel	= 0.0;
LET mDispCtaOtroBco	= 0.0;

--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
LET vExcentaComision = 0;
LET cProductoEje = '';


--SET DEBUG FILE TO '/home/informix/ivonne/sp_dispercionnomina_bpi.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 OR vsqlerr <> -206 THEN
			LET vcodret = vsqlerr;  --- Dispercion No Ejecutada
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";
			IF vBegin = 'S' THEN
				ROLLBACK WORK;
			END IF;
			RETURN vcodret;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
      LET vBegin = 'S';
      COMMIT WORK;
 	END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	SELECT fecha_hoy
	  INTO dFechaActual
	  FROM bdicheq:sc_fechas
	 WHERE empresa = "001";

	SELECT FIRST 1 nombre_archivo
	  INTO vexiste_encab
	  FROM bdicheq:sc_nominaencabezadosumario_bpi
	 WHERE status = '1'
	   AND fecha_aplicacion = dFechaActual;

	IF vexiste_encab IS NULL OR vexiste_encab = '' THEN
		LET vcodret = '805'; --- Dispercion No Ejecutada: No Existe el Encabezado del Archivo Ã?el Estatus No es el Correcto;
		RETURN vcodret;
	END IF

	LET cHoraActual = CURRENT;

	-- // Se borra la tabla de control al inicio de cada ciclo
	--TRUNCATE TABLE bdicheq:sc_nominaresultadosdispercionautomatica;

	SELECT valor
	  INTO mMontoTransIvaDisp
	  FROM bdinteg:si_param
	 WHERE cod_param = 47
	   AND empresa = "001";
	   
	--SELECT mnycomision
	--  INTO vcomisionspei_gral --aqui
	--  FROM bdispei:tblcomision;

	-- OBTIENE EL VALOR DE LA COMISION POR DISPERSION DE CTAS DE OTRO BANCO EN LA TABLA si_transsacc con el numero '3257'
	SELECT monto_fijo 
	  INTO vcomisionspei_gral
	  FROM bdinteg:"informix".si_transacc
	 WHERE sistema = '01' 
	   AND empresa = '001'
	   AND numero = '3257';
	  
	IF (mMontoTransIvaDisp = "") OR (mMontoTransIvaDisp = " ") OR (mMontoTransIvaDisp IS NULL) THEN
		LET vcodret = '855';  --- Dispercion No Ejecutada: El Valor del Iva No es Valido
		RETURN vcodret;
	END IF	
	
	FOREACH WITH HOLD
		SELECT empresa, fecha_gen, folio_archivo, nombre_archivo, cuenta_cargo, fecha_aplicacion, total_registros, importe_tot
		  INTO cNumeroEmpresa, dFechaGeneracion, IFolioArchivo, cNombreArchivo, cCuentaEje, dFechaAplicacion, iNumeroRegistros, mImporteTotalEnc
		  FROM bdicheq:sc_nominaencabezadosumario_bpi
		 WHERE status = '1'
		   AND fecha_aplicacion <= dFechaActual
		 ORDER BY empresa, nombre_archivo

		BEGIN WORK;
		LET vBegin = 'S';
		LET vcodret = '000';

		-- // Consulta el Tipo de empresa
		SELECT tipo_empresa, TRIM(acepta_producto), nombre, numcte
		  INTO siTipoEmpresa, cAceptaProducto, vnombre_empresa, vnumcte_empresa
		  FROM bdicheq:sc_nominaempresas
		 WHERE codigo = cNumeroEmpresa;
		 
		SELECT rfc INTO vrfc_empresa
          FROM bdinteg:si_cliente
         WHERE numcte = vnumcte_empresa;		  

		SELECT LIMIT 1 concepto --, nombre_archivo
		  INTO siValorConcepto --, cNombre
		  FROM bdicheq:sc_nominamovimientos_bpi
		 WHERE nombre_archivo = cNombreArchivo
		   AND status = '0';

		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		SELECT cuenta, cuenta_clabe, sdo_actual, producto
		  INTO vexiste_ctaeje, cCuentaEjeClabe, mSaldoActual, cProductoEje
		  FROM bdicheq:sc_maechq
		 WHERE empresa = '001'
		   AND cuenta = cCuentaEje;
		   
		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		SELECT COUNT(1) INTO vExcentaComision FROM bdicheq:sc_nominaexcentocomision WHERE producto = cProductoEje;

		IF vexiste_ctaeje IS NULL THEN
			LET vcodret  = "810"; --- La cuenta NO Existe en la Base de Datos

				--// Nueva Instruccion Para actualizar el encabezado y saber porque no se disperso el Archivo
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '7', --
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;
			COMMIT WORK;
				LET vBegin = 'N';
			CONTINUE FOREACH;

		ELSE
			
			CALL sp_dispersionnominavalidacionestatus_bpi (cCuentaEje, cNumeroEmpresa, dFechaGeneracion::CHAR(10), iFolioArchivo, dFechaActual::CHAR(10), cHoraActual::CHAR(8), '', '', 0.0, 0.0, '')
				RETURNING vcodret, cEstatusCuenta, cCargo, mImporteNoAbonado, cSucursalCargo, cRecDatonoUtilizableNOperacion;
			
			IF vcodret <> '000' THEN
				COMMIT WORK;
				LET vBegin = 'N';
				CONTINUE FOREACH;
			END IF
		END IF
		
		--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION DE CTAS DE BANCOPPEL EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
		SELECT disp_cta_bcoppel, disp_cta_otrobco
		INTO mDispCtaBcoppel, mDispCtaOtroBco
		FROM "informix".sc_maecomtasserv_pm
		WHERE cuenta = cCuentaEje;
		
		--// OBTIENE EL VALOR DE LA COMISION POR DISPERSION DE CTAS DE OTRO BANCO EN LA TABLA MAESTRA DE COMISIONES DE PERSONAS MORALES
		{
		SELECT disp_cta_otrobco
		INTO mDispCtaOtroBco
		FROM "informix".sc_maecomtasserv_pm
		WHERE cuenta = cCuentaEje;
		}

		LET cUsuarioAutoriza = "informix";
		LET mTotalNoPagado = 0;
		LET mImporteAbonado = 0;
		LET mImporteNoAbonado = 0;
		LET mImporteTotalAplicado = 0;
		LET mTotalPagado = 0;
		LET iNumeroRegistrosAplicados = 0;
		LET mTotalCargo = 0;
		LET mtotalspei = 0;
		LET mtotalregspei = 0;
        LET mtotalcomspei = 0;
        LET mtotalivaspei = 0; 

		IF (cNombreArchivo IS NULL) OR (cNombreArchivo = "") OR (cNombreArchivo = " ") THEN
			LET vcodret = '830';
			LET p_mensaje = "Dispercion No Ejecutada: Existe el Encabezado Pero No Existe el Detalle del Archivo";
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";

			LET vcodret = '000'; --- Este codigo se deja en 000 porque el ciclo continua ejecutandose para otro archivo y necesita llevar este valor

			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '6', --Importe restaurado a la cuenta
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;

			COMMIT WORK;
			LET vBegin = 'N';
		END IF

		LET siValorConceptoAnterior = 0; --- Aqui inicializo la variable cada vez que se vaya a procesar otro archivo

		-- // Se Limpian las Variables en Cada Vuelta
		LET cTransaccAbono = "";
		LET cTransaccCargo = "";
		LET cTransaccComiDisp = "";
		LET cTransacIvaDisp = "";
		LET vcodret = '000';

		{
		SELECT sdo_actual
		  INTO mSaldoActual
		  FROM bdicheq:sc_maechq
		 WHERE empresa ='001'
		   AND cuenta = cCuentaEje;
		}

		SELECT MIN(importe)
		  INTO mImporteEmpleado
		  FROM bdicheq:sc_nominamovimientos_bpi
		 WHERE nombre_archivo = cNombreArchivo
		   AND status = '0'; --- Con status <> 1 tomo todos los registros que no hayan sido procesados

		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		IF vExcentaComision > 0 THEN 
			LET mIvaPorEmpleado = 0;
			LET mTotalComisionDispercionIvaEmp = 0;
			LET mImporteEmpleadoCuentaEje = mImporteEmpleado;
		ELSE
			LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
			LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
			LET mImporteEmpleadoCuentaEje = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
		END IF

			--- Linea nueva aqui valido que por lo menos exista saldo para pagar a un empleado
		IF (mSaldoActual <= 0) OR (mSaldoActual < mImporteEmpleadoCuentaEje) THEN
			LET siSaldoDisponible = 0;
			LET vcodret = '835';
			LET p_mensaje = "Dispercion No Ejecutada: La Cuenta Eje No Tiene Saldo";
			LET cFolioDispercion = "";
			LET mImporteTotalAplicado = 0;
			LET mComisionAplicado = 0;
			LET mIvaAplicado = 0;
			LET cNombreArchivoConciliacion = "";
			LET vcodret = '000'; --- Este codigo se deja en 000 porque el ciclo continua para otro archivo y necesita llevar este valor

			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '5', --Saldo insuficiente
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;

			COMMIT WORK;
			LET vBegin = 'N';
			CONTINUE FOREACH;
		ELSE
			LET siSaldoDisponible = 1;
			LET mImporteEmpleado = 0;
			LET mTotalComisionDispercionIvaEmp = 0;
			LET mImporteEmpleadoCuentaEje = 0;
		END IF

		LET cNumeroEmpresa = cNumeroEmpresa;
		LET siValorConcepto = siValorConcepto;

		-- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
		--- CALL sp_dispersionnominatransacciones (siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
        CALL sp_dispersionnominatransacciones (siTipoEmpresa, siValorConcepto)
		RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo,
				  cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransacIvaDisp, mMontoTransIvaAper;

		IF vcodret <> '000' THEN
			-- // El Numero De transaccion es Invalido o No Existe
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '4', --No aplicado cuenta inexistente
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;

			COMMIT WORK;
			LET vBegin = 'N';
			CONTINUE FOREACH;
		END IF

		LET siVuelta = 0;
		
		--aqui	
		IF mDispCtaOtroBco IS NOT NULL THEN
			LET vcomisionspei = mDispCtaOtroBco;
		ELSE
            LET vcomisionspei = vcomisionspei_gral;
		END IF		
		
		LET vcomisionspei = NVL(vcomisionspei,0);
		
		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		IF vExcentaComision > 0 THEN 
			LET vcomisionspei = 0;
		END IF

		FOREACH WITH HOLD

			SELECT mov.num_empleado, mov.cuenta_abono, mov.importe, mov.concepto,
                   TRIM(nombres)||" "||TRIM(apell_paterno)||" "||TRIM(apell_materno)			
			  INTO cNumeroEmpleado, cNumeroCuentaEmpleado, mImporteEmpleado, siValorConcepto, vnombre_beneficiario
			FROM bdicheq:sc_nominamovimientos_bpi mov
			WHERE mov.nombre_archivo = cNombreArchivo
			  AND mov.status = 0 --- Con status <> 1 tomo todos los registros que no hayan sido procesados
			ORDER BY mov.importe

			LET cProducto = ' ';
			
            IF LENGTH(cNumeroCuentaEmpleado) <> 18 THEN
			   SELECT mae.status_cta, mae.producto
			     INTO siValorStatus, cProducto
			     FROM bdicheq:sc_maechq mae
			    WHERE mae.empresa = '001'
				  AND mae.cuenta = cNumeroCuentaEmpleado;
			   LET vspei = '0';
			ELSE
               LET vspei = '1';
            END IF

			LET siVuelta = siVuelta + 1;
			LET iContador = iContador + 1;

			IF (siValorConcepto <> 0) AND (siValorConceptoAnterior <> siValorConcepto) THEN
				LET siValorConceptoAnterior = siValorConcepto;
			END IF

			-- // CICLO PARA VALIDAR LOS VALORES DE LAS TRANSACCIONES
			--- CALL sp_dispersionnominatransacciones(siTipoEmpresa, cNumeroEmpresa, siValorConcepto)
            CALL sp_dispersionnominatransacciones(siTipoEmpresa, siValorConcepto)
			RETURNING vcodret, cValorTipoTransaccion, cValorTransaccion, mMontoFijo, cTransaccAbono, cTransaccCargo,
					  cTransaccComiDisp, mMontoTransComiDisp, mMontoTransComiAper, cTransacIvaDisp, mMontoTransIvaAper;

			IF vcodret <> '000' THEN
				-- // El Numero De transaccion es Invalido o No Existe
				UPDATE bdicheq:sc_nominaencabezadosumario_bpi
				   SET status = '4', --Error
					   fecha_aplicado = dFechaActual,
					   hora_aplicado = cHoraActual
				 WHERE empresa = cNumeroEmpresa
				   AND fecha_gen = dFechaGeneracion
				   AND folio_archivo = IFolioArchivo
				   AND nombre_archivo = cNombreArchivo;

				COMMIT WORK;
				LET vBegin = 'N';
				LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
				CONTINUE FOREACH;
			END IF

			LET cAceptaProducto = TRIM(cAceptaProducto);

		    IF (cProducto IS NULL OR cProducto = ' ') AND vspei = '0' THEN
				-- // Cuenta no existe
				UPDATE bdicheq:sc_nominamovimientos_bpi
				SET status = '4'
				WHERE nombre_archivo = cNombreArchivo
				AND num_empleado = cNumeroEmpleado;

				LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
				CONTINUE FOREACH;
	        END IF

			--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
			IF vExcentaComision > 0 THEN 
				LET mIvaPorEmpleado = 0;
				LET mTotalComisionDispercionIvaEmp = 0;
				LET mImporteEmpleadoComisionMasIva = mImporteEmpleado;
			ELSE
				-- // Inicio de validacion de tipo de empresa externas
				LET mIvaPorEmpleado = mMontoTransComiDisp * mMontoTransIvaDisp;
				LET mTotalComisionDispercionIvaEmp = mMontoTransComiDisp + mIvaPorEmpleado;
				LET mImporteEmpleadoComisionMasIva = mImporteEmpleado + mTotalComisionDispercionIvaEmp;
			END IF
			
			--- Aqui se le resta 1 centavo, porque cuando el saldo inicial de la cuenta eje
			--- es igual a la suma del  monto a dispersar + su comision + su iva
			--- cuando ya esta en el ultimo empleado el proceso le suma 1 centavo
			--- a mTotalCargo + mImporteEmpleadoComisionMasIva, por lo tango
			--- el mSaldoActual es menor que mTotalCargo + mImporteEmpleadoComisionMasIva,
			--- cuando la realidad es que deben de ser iguales.

			IF siVuelta = iNumeroRegistros THEN
				LET mTotalCargo = mTotalCargo - 0.01;
			END IF

			-- // Si el saldo sobrante que me queda es Mayor o Igual al importe a pagar, le pago al empleado
			IF mSaldoActual >= (mTotalCargo + mImporteEmpleadoComisionMasIva) THEN
				LET bSiguienteEmpleado = "T" ;
				LET siSaldoDisponible = 1;
			ELSE
				LET bSiguienteEmpleado = "F" ;
				LET siSaldoDisponible = 0;
			END IF

			IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T") THEN
				IF siValorStatus > 1 THEN
				   IF vspei = '0' THEN
					  CALL sp_dispersionnominavalidacionestatus_bpi
					       (cNumeroCuentaEmpleado, '', '', 0, '', '' ,cNombreArchivo, cNumeroEmpleado, mImporteEmpleado, mImporteNoAbonado, siTipoEmpresa)
					       RETURNING vcodret, cEstatusCta, cAbono, mImporteNoAbonado, cRecDatonoUtilizableNOperacion, cSucursalAbono;
				   END IF
				ELSE
					LET cEstatusCta=1;
				END IF

				LET cSucursalAbono = "9103";
				
				-- // Estatus 1 = Cuenta Activa, Estatus 3 = Cuenta Bloqueada,
				-- // Se modifica IF, se le agrego, que pudiera se abonar a la cuenta bloqueada, si el motivo del bloqueo lo permite
				IF vspei = '0' THEN

					
					IF  ((siSaldoDisponible = 1) AND (cEstatusCta = '1' )) OR ((siSaldoDisponible = 1) AND (cAbono = 'S')) THEN
						SELECT MAX(secuencia)
						INTO vexiste_sec
						FROM bdicheq:sc_tarjeta
						WHERE empresa = '001'
						AND cuenta = cNumeroCuentaEmpleado
						AND tipo_tarjeta = "T"
						AND status_tar = "A";

						IF vexiste_sec IS NOT NULL OR vexiste_sec <> '' OR vexiste_sec > 0 THEN
							SELECT NVL(num_tarjeta, '')
							INTO cNumeroTarjeta
							FROM bdicheq:sc_tarjeta
							WHERE empresa = '001'
							AND cuenta = cNumeroCuentaEmpleado
							AND tipo_tarjeta = "T"
							AND status_tar = "A"
							AND secuencia = vexiste_sec;
						ELSE
							LET cNumeroTarjeta = '';
						END IF

						CALL sp_generafolionomina ("informix")
						RETURNING cCodRet, cNumeroFolio;

						-- // Aqui siempre se mandara la empresa 001 indepENDientemente
						-- // del numero de empresa que se este ejecutando tanto para el abono_ref y el cargo_ref

						CALL abono_ref ("001", cSucursalAbono, "informix", cTransaccAbono, "0000", cNumeroFolio, cNumeroCuentaEmpleado,
										0, mImporteEmpleado, mImporteEmpleado, 0, 0, 0, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
						RETURNING vcodret;

						IF vcodret = '000' THEN
							UPDATE bdicheq:sc_nominamovimientos_bpi
							SET status = '1'  --- Aqui actualizo el status = 1  (Aplicado)
							WHERE nombre_archivo = cNombreArchivo
							AND num_empleado = cNumeroEmpleado;

							LET mImporteAbonado = mImporteAbonado + mImporteEmpleado;

							LET iNumeroRegistrosAplicados = iNumeroRegistrosAplicados +1;

							--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
							IF vExcentaComision > 0 THEN 
								LET mTotalComision = 0;
								LET mTotaliva = 0;
							ELSE
								LET mTotalComision = iNumeroRegistrosAplicados * mMontoTransComiDisp;
								LET mTotaliva = mTotalComision * mMontoTransIvaDisp;  --Nueva Forma de Calcular el Iva
							END IF
							
							LET mTotalPagado = mTotalPagado + mImporteEmpleado;
							LET mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;
						ELSE
							UPDATE bdicheq:sc_nominamovimientos_bpi
							SET status = '9'  --- Aqui actualizo el status = 9  (Error en la transaccion del sp abono_ref)
							WHERE nombre_archivo = cNombreArchivo
							AND num_empleado = cNumeroEmpleado;
							LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
						END IF
					ELSE
						UPDATE bdicheq:sc_nominamovimientos_bpi
						SET status = '5' --- Saldo Insuficiente
						WHERE nombre_archivo = cNombreArchivo
						AND num_empleado = cNumeroEmpleado;
						LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
					END IF
				ELSE
					LET cNumeroFolio = "";
                    CALL sp_generafolionomina ("informix")
						RETURNING cCodRet, cNumeroFolio;
					LET vcvebanco_cta = SUBSTR(cNumeroCuentaEmpleado, 1, 3);
					LET vcvebanco_benef = "40"||TRIM(vcvebanco_cta);
					CALL bdispei:sp_regordenpagospei_pp ("001", "informix", cSucursalAbono, cNumeroFolio, vcvebanco_benef, dFechaActual, 1, 0, mImporteEmpleado, vnombre_empresa, cCuentaEjeClabe, vrfc_empresa, vnombre_beneficiario, cNumeroCuentaEmpleado, " ", 0.00, 0,
                                                 " ", " ", " ", " ", " ", " ", "NOMINA", "0274", 40, 40)
						 RETURNING vcodret, verror, vcverastreo;
                     IF vcodret = "000" THEN
						UPDATE bdicheq:sc_nominamovimientos_bpi
						   SET status = '1'  --- Aqui actualizo el status = 1  (Aplicado)
					  	 WHERE nombre_archivo = cNombreArchivo
						   AND num_empleado = cNumeroEmpleado;
						   
						LET mImporteAbonado = mImporteAbonado + mImporteEmpleado;
						LET iNumeroRegistrosAplicados = iNumeroRegistrosAplicados +1;
							
						--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
						IF vExcentaComision > 0 THEN 
							LET mTotalComision = 0;
							LET mTotaliva = 0;
						ELSE
							LET mTotalComision = iNumeroRegistrosAplicados * mMontoTransComiDisp;
							LET mTotaliva = mTotalComision * mMontoTransIvaDisp;  --Nueva Forma de Calcular el Iva
						END IF
						
						LET mTotalPagado = mTotalPagado + mImporteEmpleado;
						LET mTotalCargo = mTotalPagado + mTotalComision + mTotaliva;					 
						LET mtotalspei = mtotalspei + mImporteEmpleado;
						LET mtotalregspei = mtotalregspei + 1;
						
						-- CARGO POR CADA SPEI A REALIZAR CORRESPONDIENTE A CADA IMPORTE ABONADO
						CALL cargo_ref ("001", cSucursalCargo, "informix", '0274', "0331", cNumeroFolio,
							cCuentaEje, 0, mImporteEmpleado, "01", vcverastreo, cNumeroTarjeta, cUsuarioAutoriza)
							RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
						IF vcodretCargo1 = '000' AND vcomisionspei > 0 THEN
							-- CARGO POR COMISION POR CADA DISPERSION
							CALL cargo_ref ("001", cSucursalCargo, "informix", "3257", "0000", cNumeroFolio,
								cCuentaEje, 0, vcomisionspei, "01", vcverastreo, cNumeroTarjeta, cUsuarioAutoriza)
								RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;
							IF vcodretCargo2 = '000' THEN
								-- CARGO POR IVA POR COMISION POR CADA DISPERSION
								CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,
								cCuentaEje, 0, vcomisionspei *  mMontoTransIvaDisp, "01", vcverastreo, cNumeroTarjeta, cUsuarioAutoriza)
								RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
							END IF
						END IF
 				     ELSE
					 	UPDATE bdicheq:sc_nominamovimientos_bpi
						   SET status = '9'  --- Aqui actualizo el status = 9  (Error al enviar el SPEI)
					     WHERE nombre_archivo = cNombreArchivo
						   AND num_empleado = cNumeroEmpleado;
						LET mImporteNoAbonado = mImporteNoAbonado + mImporteEmpleado;
					 END IF
                END IF
			END IF  -- // FIN de: IF (bPrimerEmpleado = "T") OR  (bSiguienteEmpleado = "T")

			LET bPrimerEmpleado = "F" ;
		END FOREACH;

		-- // Inicio de validacion de tipo de empresa externas
		CALL sp_generafolionomina ("informix")
			RETURNING cCodRet, cNumeroFolio;
			
		--RobertoCastro para cuentas que no se les cobra comision 20/02/2023
		IF vExcentaComision > 0 THEN 
			LET mTotalComspei = 0;
			LET mTotalivaspei = 0;	
			LET mMontoTransComiDisp = 0;
		ELSE
			--aqui
			LET mTotalComspei = mtotalregspei * vcomisionspei;
			LET mTotalivaspei = mTotalComspei * mMontoTransIvaDisp;	
			IF mDispCtaBcoppel IS NOT NULL THEN
				LET mMontoTransComiDisp = mDispCtaBcoppel;
			END IF
		END IF

			-- // Aqui se manda llamar el sp que obtiene los totales del IVA y de la comision de los empleados Aplicados
		CALL sp_nominatotalivacomision_bpi (cNombreArchivo, mMontoTransIvaDisp, mMontoTransComiDisp) 
			RETURNING cCodRet, cMensaje, mTotaliva, mTotalComision, mTotalPagado, mTotalNoPagado, mTotalCargo;
			

		IF mTotalNoPagado <> 0 THEN
			LET iCodigoEstatus = 3;
		ELSE
			LET iCodigoEstatus = 2;
		END IF

		IF cCodRet = '000' THEN
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = iCodigoEstatus,
				   importe_aplicado = mTotalPagado,
				   importe_no_aplicado = mTotalNoPagado,
				   folio_dispersion = cNumeroFolio,
				   iva = mTotaliva + mTotalivaspei,
				   comision = mTotalComision + mTotalComspei,
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;
		ELSE
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = iCodigoEstatus,
				   importe_no_aplicado = mTotalNoPagado,
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = IFolioArchivo
			   AND nombre_archivo = cNombreArchivo;
		END IF

		LET cNumeroTarjeta = '';
		LET vcodretCargo1 = '000';
		LET vcodretCargo2 = '000';
		LET vcodretCargo3 = '000';
		
		IF mTotalPagado > 0 or mTotalComision > 0 or mtotalspei > 0 THEN
			IF mTotalPagado - mtotalspei > 0 THEN
				CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccCargo, "0000", cNumeroFolio,
								cCuentaEje, 0, mTotalPagado - mtotalspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
			ELSE
				LET vcodretCargo1 = '000';
			END IF
			/*
			IF vcodretcargo1 = '000' THEN
				IF mtotalspei > 0 THEN
					CALL cargo_ref ("001", cSucursalCargo, "informix", '0274', "0000", cNumeroFolio,
									cCuentaEje, 0, mtotalspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
						RETURNING vcodretCargo1, vtranret, vfechoy, vsdodisp, vmontoret;
				ELSE
					LET vcodretCargo1 = '000';
				END IF
			END IF
			*/
			IF vcodretCargo1 = '000' AND mTotalComision > 0 THEN
				CALL cargo_ref ("001", cSucursalCargo, "informix", cTransaccComiDisp, "0000", cNumeroFolio,
								cCuentaEje, 0, mTotalComision, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
				RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;

				IF vcodretCargo2 = '000' THEN
					CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,
									cCuentaEje, 0, mTotaliva, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
				END IF
			ElIF (vcodretCargo1 = '000') AND (mTotalComision = 0) THEN
			 	 LET vcodretCargo2 = '000';
				 LET vcodretCargo3 = '000';
			END IF
			
            IF vcodretCargo1 = '000' AND mTotalComspei > 0 THEN
				/*
			     CALL cargo_ref ("001", cSucursalCargo, "informix", "3257", "0000", cNumeroFolio,
								cCuentaEje, 0, mTotalComspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
				 RETURNING vcodretCargo2, vtranret, vfechoy, vsdodisp, vmontoret;
				 IF vcodretCargo2 = '000' THEN
				    CALL cargo_ref ("001", cSucursalCargo, "informix", '0260', "0000", cNumeroFolio,
									cCuentaEje, 0, mTotalivaspei, "01", " ", cNumeroTarjeta, cUsuarioAutoriza)
					RETURNING vcodretCargo3,vtranret,vfechoy,vsdodisp,vmontoret;
				 END IF	  
				 */
			ElIF (vcodretCargo1 = '000') AND (mTotalComision = 0) THEN
				 LET vcodretCargo2 = '000';
				 LET vcodretCargo3 = '000';
			END IF
		END IF

		IF (vcodretCargo1 = '000') AND (vcodretCargo2 = '000') AND (vcodretCargo3 = '000') THEN
			COMMIT WORK;
		ELSE
			ROLLBACK WORK;

			-- // El archivo no efectuo el cargo y deja movimientos en cero pero actualiza el status de encabezado sumario a 9
			UPDATE bdicheq:sc_nominaencabezadosumario_bpi
			   SET status = '9', --Error del cargo_ref
				   fecha_aplicado = dFechaActual,
				   hora_aplicado = cHoraActual
			 WHERE empresa = cNumeroEmpresa
			   AND fecha_gen = dFechaGeneracion
			   AND folio_archivo = iFolioArchivo;
		END IF

		LET v_cCodret ='00000';
		
		CALL sp_dispersiontraspasomovtos_bpi(cNombreArchivo)
		  RETURNING v_cCodRet;
		
	    IF v_cCodRet <> "00000" AND v_cCodRet <> "00001" THEN
	       LET vcodret = '100'; --los registros ya fueron enviados a la tabla historica
	    END IF;
		
		LET vBegin = 'N';
	CONTINUE FOREACH;
	END FOREACH;

	--LET v_cCodret ='00000';

	--Se Corre este procedimiento para enviar los registros procesados a las tablas historicas.
	--EXECUTE PROCEDURE sp_dispersiontraspasomovtos_bpi()
	--INTO v_cCodRet;

	--IF v_cCodRet <> "00000" AND v_cCodRet <> "00001" THEN
	--   LET vcodret = '100'; --los registros ya fueron enviados a la tabla historica
	--END IF;

	RETURN vcodret;
    
    END;
    
END PROCEDURE;