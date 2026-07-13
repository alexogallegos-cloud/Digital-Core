CREATE PROCEDURE "informix".sp_consulta_error(
                pInstitucion char(2),pnum_solicitud char(20)) 
              
RETURNING CHAR(5),   -- Codigo de Retorno
          CHAR(255), -- Segmento
          CHAR(255); -- Campo
		
--Roque Enrique Solis Campaña
--31  DE OCTUBRE DE 2008
--Determina el segmento y el campo de la cadena de error enviado por la 
--Institucion Crediticia ya sea CC (Circulo de Credito) o Buro de Credito.

--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_mensajeError  CHAR(255);
DEFINE s_mensajeError2 CHAR(255);
DEFINE s_tipoRegreso   char(8);
DEFINE pInsti          char(2);
DEFINE psolicitud      char(20);
DEFINE s_segmento      char(2);
DEFINE s_tipoSegmento  char(2);
DEFINE s_nombre_seg    char(255);
DEFINE s_nombre_cam    char(255);
DEFINE s_clave_segmento char(2);

-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;

LET s_mensajeError=" ";
LET s_mensajeError2=" ";
LET s_tipoRegreso=" ";

LET s_segmento="";
LET s_tipoSegmento="";

LET s_nombre_seg="";
LET s_nombre_cam="";

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_mensajeError, s_mensajeError2;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "sp_consulta_error.out";
-- TRACE ON;

-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************

LET pInsti=pInstitucion;            
LET psolicitud=pnum_solicitud;                     

    --**************Existe la caden ERR*************    
    SELECT LIMIT 1 bu.regreso[1,4]
	INTO s_tipoRegreso
	FROM bdiburo:sb_regreso bu
	WHERE bu.institucion=pInstitucion
	AND bu.num_solicitud=pnum_solicitud;
	
    IF s_tipoRegreso='ERRR' THEN
	
	    --Obtener el segmento y la clave del campo dentro de la cadena de error
            SELECT LIMIT 1 bu.regreso[36,37], bu.regreso[38,39] 
	        INTO s_segmento,s_tipoSegmento
	        FROM bdiburo:sb_regreso bu
	        WHERE bu.institucion=pInstitucion
	        AND bu.num_solicitud=pnum_solicitud;

			 
			 --Pregunta si existe el segmento dentro de la tabla
               IF EXISTS (SELECT seg.descripcion_segmento 
			   FROM bdiburo:br_segmento_error seg
			   WHERE seg.referencia_segmento=s_segmento ) THEN
			   
			   --Obtener el nombre del segmento y la clave del segmento
                   SELECT seg.descripcion_segmento, clave_segmento 
                   INTO s_nombre_seg, s_clave_segmento
                   FROM bdiburo:br_segmento_error seg
                   where seg.referencia_segmento=s_segmento;

                   LET s_mensajeError="Segmento: " || trim(s_nombre_seg);
			   
			   --Obtener la descripcion del campo
                    SELECT des.descripcion_campo
                    INTO s_nombre_cam
                    FROM bdiburo:br_detalle_error des 
                    WHERE clave_segmento=s_clave_segmento AND etiqueta_error=s_tipoSegmento;
			
			--Si el campo del segmento existe se asigna a la variable de regreso
			IF s_nombre_cam <>"" THEN
  			   LET s_mensajeError2="  Campo: " || TRIM(s_nombre_cam);
			END IF
				
			ELSE
			    LET s_mensajeError="ERROR NO ASIGNADO";
			END IF
	   
	   ELSE
	      LET s_mensajeError="SIN ERRORES";
	END IF
           
    RETURN scod_ret, s_mensajeError, s_mensajeError2
	WITH RESUME;

END;
END PROCEDURE;