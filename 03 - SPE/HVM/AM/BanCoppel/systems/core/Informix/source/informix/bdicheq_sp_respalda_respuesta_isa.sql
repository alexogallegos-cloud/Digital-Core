CREATE PROCEDURE "informix".sp_respalda_respuesta_isa(pEmpresa char(3))
   RETURNING CHAR(6);   --CodRet
                                                                                
                                                                                
   DEFINE CodRet              CHAR(6);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);
   --AAME INC 27 108
   DEFINE vFechaant			  date;
   DEFINE vmes 				  char(2);
   DEFINE vanio 		 	  char(4); 
   DEFINE vregistros          integer;
   DEFINE vaniomes			  char(6);
   
                                                                                
   --DEFINE GLOBAL g_Empresa    CHAR(3)  DEFAULT ' ';                             
   --DEFINE GLOBAL g_NumCredito CHAR(20) DEFAULT ' ';                             
   --DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';                             
                                                                                
   LET CodRet  		= "000000";
   LET vFechaant	= '';
	LET vmes 		= '';
	LET vanio 		= '';  
   LET vregistros 	= 0;
   LET vaniomes  	= '';
   
   	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ; 
	
	--set debug file to "/resplogifx/conciliachq/ArchivosRespuestaIsa/sp_respalda_respuesta_isa.out";
	--trace on;
  
    -- Validacion para que inserte siempre y cuando no se tenga ya el respaldo
	SELECT fecha_hoy
			  INTO vFechaant
			  FROM sc_fechas
			 WHERE empresa = pEmpresa;
			 
	LET vmes = month(vFechaant);
	LET vanio = year(vFechaant);
	LET vaniomes = lpad(vanio::integer,4,'0')||lpad(vmes::integer,2,'0');
	
	SELECT count(*) 
	  INTO vregistros 
	  FROM "informix".sc_seguimiento_isa_hist 
	  WHERE fecha = vFechaant;
	  
	IF vregistros = 0 THEN                    
																			
	   --**    Respalda sc_seguimiento_isa **--
	   INSERT INTO sc_seguimiento_isa_hist
			  ( aniomes,     fecha,       sucursal,     real_mes,     meta,     cumplimiento  )
		   SELECT vaniomes,	   fecha,       sucursal,     real_mes,     meta,     cumplimiento 
			 FROM sc_seguimiento_isa;

	END IF;
   RETURN CodRet;

END PROCEDURE
;