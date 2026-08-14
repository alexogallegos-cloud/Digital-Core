CREATE PROCEDURE "informix".sp_reporte_oa()

RETURNING CHAR(5);       -- Codigo de Retorno

--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numsol        CHAR(12);
DEFINE s_sucursal      CHAR(4);
DEFINE s_status        CHAR(2);
DEFINE s_nombrecte     CHAR(50);
DEFINE s_nombre1       CHAR(20);
DEFINE s_nombre2       CHAR(20);
DEFINE s_apell_paterno CHAR(20);
DEFINE s_apell_materno CHAR(20);
DEFINE s_fecha_sol     DATE;
DEFINE s_fecha_entrada DATE;
DEFINE pfechaini       DATE;
DEFINE pfechafin       DATE;
DEFINE s_numcte        CHAR(20);
DEFINE vfecha_hoy      DATE;
DEFINE s_consulta      SMALLINT;
DEFINE pempresa        CHAR(3);
DEFINE pstatus         CHAR(2);
DEFINE psucursal       CHAR(5);
DEFINE s_situacion     CHAR(2);
DEFINE s_causa         CHAR(2);
DEFINE s_num_producto  CHAR(4);

DEFINE s_prod          CHAR(10);
DEFINE s_prod2         CHAR(4);
DEFINE s_prod3         CHAR(4);
DEFINE cRuta           CHAR (50);
DEFINE cReporteOA      CHAR (50);
DEFINE cCadena         CHAR (500);
DEFINE cfec_arch       CHAR(8);
DEFINE s_cont_cte      INTEGER;
DEFINE num_prod1       CHAR(4);
DEFINE num_prod2       CHAR(4);
-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET scod_ret        = "000";
LET vsqlerr         = 0;
LET s_numcte        = "";
LET s_numsol        = "";
LET s_sucursal      = "";
LET s_status        = "";
LET s_nombrecte     = "";
LET s_nombre1       = "";
LET s_nombre2       = "";
LET s_apell_paterno = "";
LET s_apell_materno = "";
LET s_fecha_sol     = "";
LET s_fecha_entrada = "";
LET s_consulta      = 0;
LET pempresa	    = '001';
LET pstatus         = 'OA';
LET psucursal       = '';
LET s_consulta      = 0;
LET s_situacion     = '';
LET s_causa         = '';
LET s_num_producto  = '';
LET s_prod          = '';
LET s_prod2         = '';
LET s_prod3         = '';
LET cCadena         = '';
LET cReporteOA      = '';
LET cfec_arch       = '';
LET s_cont_cte      = 0;
LET num_prod1       = '';
LET num_prod2       = '';
LET pfechaini       = '';
LET pfechafin       = '';

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

		--SET DEBUG FILE TO "/informix/sp_reporte_OA.out";
		--TRACE ON;

-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************
    SELECT year(fecha_hoy)||lpad(month(fecha_hoy),2,0)||lpad(day(fecha_hoy),2,0),today - 6 UNITS MONTH,today
    INTO cfec_arch,pfechaini,pfechafin
    FROM bdicred:sd_fechas WHERE empresa=pempresa;
    
	SELECT valor
	INTO cRuta
    FROM "informix".sd_param WHERE cod_param = '49' AND empresa = '001';

   LET cReporteOA = "ReporteOA_"||cfec_arch||'.txt';

   LET pempresa = pempresa;
   LET psucursal = psucursal;
   LET pfechaini  = pfechaini;
   LET pfechafin = pfechafin;
   LET pstatus = pstatus;

   -- Reporte para todas las sucursales
    If nvl(psucursal, '') = '' then
        Let psucursal = null;
    End if;
	
	--Se crea tabla temporal
	 DROP INDEX IF EXISTS 'informix'.inx1_sd_repOA_tmp;
	 DROP INDEX IF EXISTS 'informix'.inx2_sd_repOA_tmp;
	 DROP TABLE IF EXISTS 'informix'.sd_reporte_oa;
	 CREATE TABLE 'informix'.sd_reporte_oa (
	           num_solicitud varchar(12),
	           num_sucursal  varchar(10),
	           nom_cliente   varchar(80),
	           producto      varchar(20),
			   num_producto  varchar(10),
			   numcte        varchar(20),
	           f_ini_vig     date,
	           f_fin_vig     date,
	           situacion_esp varchar(2),
	           causa_sit     varchar(2));
			   
     CREATE INDEX 'informix'.inx1_sd_repOA_tmp on 'informix'.sd_reporte_oa(numcte,num_solicitud,num_producto);
	 CREATE INDEX 'informix'.inx2_sd_repOA_tmp on 'informix'.sd_reporte_oa(numcte);

     LET s_consulta = 1;

     IF s_consulta = 1 THEN
        FOREACH
        	--Se obtienen las solicitudes con estatus OA	
			 SELECT a.num_solicitud, a.sucursal, a.num_producto, a.numcte, NVL(a.fecha_insert,date(1))
               INTO
                 s_numsol,s_sucursal,s_num_producto,s_numcte,s_fecha_sol		
             FROM (bdisolic:ss_solicitudes a 
             INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal )
             WHERE a.status_solicitud = pstatus AND (a.fecha_insert >= pfechaini AND a.fecha_insert <= pfechafin)  
             AND a.empresa = pempresa
             ORDER BY a.numcte,a.num_solicitud,a.sucursal,a.num_producto ASC
			 
			 --Se obtiene la informaciÃ²n de cuando se guardo el estatus OA en la bitacora de estatus
			 SELECT NVL(d.fecha_entrada,date(1))
               INTO
                 s_fecha_entrada		
             FROM bdisolic:ss_autorizacion d WHERE d.num_solicitud = s_numsol AND d.empresa = pempresa AND status_solicitud = pstatus
             AND d.fecha_entrada = (SELECT NVL(MAX(fecha_entrada),today) FROM bdisolic:ss_autorizacion
             WHERE  num_solicitud = s_numsol AND status_solicitud = pstatus AND empresa = pempresa);
			 
			 --Se obtiene el nombre del cliente
			 SELECT g.nombre1, g.nombre2, g.apell_paterno, g.apell_materno
			   INTO s_nombre1,s_nombre2, s_apell_paterno, s_apell_materno
			 FROM bdinteg:si_cliente g WHERE g.numcte = s_numcte;		 
             
			 --Se obtiene la situacion y causa
			 SELECT FIRST 1 c.situacionespecial, c.causasituacionespecial
               INTO s_situacion,s_causa
             FROM bdisolic:"informix".ss_solicitud_os a
             LEFT JOIN bdisolic:"informix".ss_osclientesupervisar c ON (c.empresa=a.empresa AND c.num_solicitud =a.num_solicitud AND c.fechasolicitud=a.fecha_solicitud)
             WHERE a.num_solicitud = s_numsol
             AND a.fecha_solicitud =(
             SELECT MAX(fecha_solicitud)
             FROM bdisolic:"informix".ss_solicitud_os b
             WHERE b.num_solicitud = a.num_solicitud ) AND a.empresa = pempresa;
             
			   --Se valida el tipo de producto	 
               IF s_num_producto = '6001' THEN
                  LET  s_prod = '4.-TDC';
               ELIF s_num_producto = '6500' THEN
                  LET  s_prod = '2.-CP';
               ELIF s_num_producto = '6800' THEN
                  LET  s_prod = '3.-PD';
			   ELIF s_num_producto = '6300' THEN
			      LET  s_prod = '3.-PP12';
			   ELIF s_num_producto = '7600' THEN
			      LET  s_prod = '3.-PP18';
			   ELIF s_num_producto = '7700' THEN
			      LET  s_prod = '3.-PP24';
               END IF;

             --Se concatena el nombre del cliente
             LET s_nombrecte=trim(s_nombre1) || ' ' || trim(s_nombre2) || ' ' || trim(s_apell_paterno) || ' ' || trim(s_apell_materno);
			 
			 --Se inserta la informacion a la tabla temporal
             INSERT INTO sd_reporte_oa VALUES (s_numsol,s_sucursal,s_nombrecte,s_prod,s_num_producto,s_numcte,s_fecha_sol,s_fecha_entrada,s_situacion,s_causa);
             	
             --Solicitudes mixtas
			   SELECT count(numcte) INTO s_cont_cte FROM bdicred:sd_reporte_oa where numcte = s_numcte AND f_ini_vig = s_fecha_sol;
			 
			   IF s_cont_cte = 2 THEN
			   
				   SELECT num_producto INTO num_prod1 FROM bdicred:sd_reporte_oa where numcte = s_numcte 
				   AND num_producto = (SELECT MIN(num_producto) FROM bdicred:sd_reporte_oa where numcte = s_numcte ) AND f_ini_vig = s_fecha_sol;
				   
				   SELECT num_producto INTO num_prod2 FROM bdicred:sd_reporte_oa where numcte = s_numcte 
				   AND num_producto = (SELECT MAX(num_producto) FROM bdicred:sd_reporte_oa where numcte = s_numcte ) AND f_ini_vig = s_fecha_sol;
			       
                  IF num_prod1 = '6001' THEN
                     LET  s_prod2 = 'TDC';
                  ELIF num_prod1 = '6500' THEN
                     LET  s_prod2 = 'CP';
                  ELIF num_prod1 = '6800' THEN
                     LET  s_prod2 = 'PD';
                  ELIF num_prod1 = '6300' THEN
			         LET  s_prod2 = 'PP12';
                  ELIF num_prod1 = '7600' THEN
                     LET  s_prod2 = 'PP18';
                  ELIF num_prod1 = '7700' THEN
                     LET  s_prod2 = 'PP24';
                  END IF;
				  
				  IF num_prod2 = '6001' THEN
                     LET  s_prod3 = 'TDC';
                  ELIF num_prod2 = '6500' THEN
                     LET  s_prod3 = 'CP';
                  ELIF num_prod2 = '6800' THEN
                     LET  s_prod3 = 'PD';
                  ELIF num_prod2 = '6300' THEN
			         LET  s_prod3 = 'PP12';
                  ELIF num_prod2 = '7600' THEN
                     LET  s_prod3 = 'PP18';
                  ELIF num_prod2 = '7700' THEN
                     LET  s_prod3 = 'PP24';
                  END IF;
				  
				  UPDATE "informix".sd_reporte_oa SET producto = '1.-'||TRIM(s_prod2) || ' Y ' || TRIM(s_prod3) WHERE numcte = s_numcte;
			   END IF;				
			 
        END FOREACH;
				
    END IF;

        LET cCadena = '';
        LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO ' || TRIM(cRuta) || TRIM(cReporteOA) ||' delimiter ''|'' SELECT num_solicitud,num_sucursal,TRIM(numcte),nom_cliente,TRIM(producto),f_ini_vig,f_fin_vig,situacion_esp,causa_sit FROM bdicred:sd_reporte_oa ORDER BY producto,f_ini_vig,numcte,nom_cliente,num_solicitud;" >'||TRIM(cRuta)||'Reporte_OA.sql';
        SYSTEM cCadena;
        LET cCadena='chmod 777 '|| TRIM(cRuta)||'Reporte_OA.sql';
        SYSTEM cCadena;
        LET cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'Reporte_OA.sql';
        SYSTEM cCadena;
        LET cCadena = '' ;
        --LET cCadena = 'rm ' || TRIM(cRuta) || 'Reporte_OA.sql';
        SYSTEM cCadena;


    RETURN scod_ret;

END;

END PROCEDURE;