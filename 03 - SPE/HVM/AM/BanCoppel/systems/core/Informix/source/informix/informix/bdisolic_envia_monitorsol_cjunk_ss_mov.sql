CREATE PROCEDURE  "informix".envia_monitorsol_cjunk_ss_mov(o_empresa CHAR(3), 
										  o_sucursal CHAR(20), 
										  o_solicitudes SMALLINT, 
										  o_numcte CHAR(20),
										  o_status_solicitud CHAR(5),
										  o_Num_producto CHAR(4),
										  o_Tipo INTEGER,										   
										  pFechaIni DATE, 
										  pFechaFin DATE)
RETURNING CHAR(5)       AS cod_ret,
          CHAR(20)      AS num_solicitud,
          CHAR(20)      AS num_cte,
          CHAR(120)     AS nombre_cte,
          CHAR(15)      AS rfc,
          DATE	        AS fecha_solicitud,
          DATE          AS fecha_autorizacion,
          CHAR(4)	    AS num_producto,
          CHAR(40)	    AS nom_producto,
          MONEY(14,2)   AS linea_otorgada,
          CHAR(2)       AS status_solicitud,
          CHAR(60)      AS descripcion_status_solicitud,
          CHAR(255)     AS comentario,
          CHAR(2)       AS dia_de_corte,
          CHAR(2)       AS divisa,
          MONEY(14,2)   AS ingreso_cte,
		  CHAR(3)       AS causa_solicitud,
          CHAR(100)     AS descripcion_solicitud,
		  INTEGER       AS dias_vigencia;

-------------------------------------------------------------------------------
-- FECHA: 2009/09/08
-- MODIFICO: Jose Luis Pulido Zepeda
-- COMENTARIOS: Sea agrego filtro para consultar las solicitudes excepto las
--              de prestamo personal
-------------------------------------------------------------------------------
-- FECHA: 2008/12/30
-- MODIFICO: Mohamed Carreon
-- COMENTARIOS: Se modifica para que muestre las solicitud de Crédito 
--              BanCoppel y las de Crédito Coppel
-------------------------------------------------------------------------------
-- FECHA: 2010/02/09
-- MODIFICO: Paul Ivan Quintero Varela
-- COMENTARIOS: Se modifica para realizar las consulta por tipo de solicitud 
--              en vez de realizarla por el producto.
-------------------------------------------------------------------------------
-- FECHA: 2011/06/08
-- MODIFICO: Jesús Manuel Aguilar Heredia
-- COMENTARIOS: Se modifica para realizar la homologacion del procedimiento con la versión envia_monitorsol.
--se elimina codigo que no se usa para cumplir con los estandares de codificacion.
-------------------------------------------------------------------------------
-- FECHA: 2012
-- MODIFICO: Jesús Manuel Aguilar Heredia
-- COMENTARIOS: Se modifica para realizar la homologacion del procedimiento con la versión envia_monitorsol.
--se elimina codigo que no se usa para cumplir con los estandares de codificacion.
-------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	  CHAR(5);
DEFINE vsqlerr      	  INTEGER;
DEFINE s_numsol     	  CHAR(20);
DEFINE s_numcte     	  CHAR(20);
DEFINE s_nombre     	  CHAR(110);
DEFINE s_fechaaut   	  DATE;
DEFINE  s_fechasol  	  DATE;
DEFINE s_linea      	  MONEY(14,2);
DEFINE s_status     	  CHAR(2);
DEFINE s_stdesc     	  CHAR(50);
DEFINE s_comentario 	  CHAR(255);
DEFINE s_rfc        	  CHAR(15);
DEFINE s_diacorte   	  CHAR(2);
DEFINE s_divisa     	  CHAR(2);
DEFINE s_ingreso    	  MONEY(14,2);
DEFINE v_cuantos    	  SMALLINT;
DEFINE vfecha_hoy   	  DATE;
DEFINE vdias_vigencia 	  SMALLINT;
--jom ini
DEFINE r_social           CHAR(40);
DEFINE nombre1            CHAR(40);
DEFINE nombre2            CHAR(40);
DEFINE apellidopaterno    CHAR(40);
DEFINE apellidomaterno    CHAR(40);
DEFINE sNumProducto       CHAR(40);
DEFINE sProducto          CHAR(40);
--jom fin
DEFINE cCausaSol         CHAR(3);
DEFINE vDescCausaSol     CHAR(100);

DEFINE cEstatus_aplica CHAR(100);
DEFINE cAplica			CHAR(10);
DEFINE iLongitud		INTEGER;
DEFINE i				INTEGER;
DEFINE cEstatus        CHAR(100);
DEFINE pTipoSol			CHAR(2);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret          = "000";
LET vsqlerr           = 0;
LET s_nombre          = "??????????";
LET s_numcte          = "??????????";
LET s_fechaaut        = "";
LET s_fechasol        = "";
LET s_status          = "??";
LET s_numsol          = "??????????";
LET s_comentario      = "??????????";
LET s_stdesc          = "??????????";
LET s_rfc             = "??????????";
LET s_linea           = 0;
LET s_diacorte        = "20";
LET s_divisa          = "??";
LET v_cuantos         = 0;
LET vfecha_hoy        = "";
LET vdias_vigencia    = 0;
LET s_ingreso         = 0;
LET sNumProducto      = "";
LET sProducto         = "";
-- jom ini
LET r_social          = "";
LET nombre1           = "";
LET nombre2           = "";
LET apellidopaterno   = "";
LET apellidomaterno   = "";
-- jom fin
LET cCausaSol        = "";
LET vDescCausaSol    = "";

LET cEstatus_aplica  = "";
LET cAplica			 = "";
LET iLongitud		 = 0;
LET i				 = 0;
LET cEstatus         = "";
LET pTipoSol		 = '';
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc,
             s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia;
   END IF;
END EXCEPTION;

 --SET DEBUG FILE TO 'envia_monitorsol_cjunk_ss.out';
 --TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   	SET ISOLATION TO DIRTY READ;
--    SET ISOLATION TO COMMITTED READ LAST COMMITTED;
--    SET LOCK MODE TO WAIT 3;
   -- Carga la Fecha del Dia
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = o_empresa;
	 
	 
	IF o_Tipo = 1 THEN

		FOREACH 
			SELECT {+INDEX (bdisolic:ss_solicitudes_movil idx_ss_movil_solic)} skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
		--	INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol, apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc, pTipoSol
			FROM "informix".ss_solicitudes_movil e 
			INNER JOIN  "informix".ss_solicitudes a ON e.num_solicitud = a.num_solicitud
                                                    AND a.tipo_solicitud IN ('T','C') 
                                                    AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','PA','CN')
			INNER JOIN "informix".ss_autorizacion c on (e.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud 
                                                        /*and fecha_entrada = 
                                                           (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = num_solicitud
											                AND c.status_solicitud  = status_solicitud)*/
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
			--WHERE a.tipo_solicitud IN ('T','C') 
			--AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','PA','CN')
			--AND e.producto = a.num_producto
			--AND e.num_solicitud = a.num_solicitud  
		--	ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
		union 
	
            SELECT {+INDEX (bdisolic:ss_prospecteo_solicitudes ss_prospecteo_solicitudes)} --skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_prospecteo_solicitudes e 
			INNER JOIN  "informix".ss_solicitudes a ON (e.empresa = a.empresa 
                                                        AND e.numcte=a.numcte            
                                                        AND e.num_solicitud = a.num_solicitud 
                                                        and e.estatus<>''
                                                        AND e.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','PA','CN')			
                                                        AND e.canal_sol='4')  
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud 
                                                        /*and fecha_entrada = 
                                                           (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)} 
                                                            MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = a.num_solicitud
											                AND c.status_solicitud  = a.status_solicitud)*/
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
							    AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
			WHERE e.empresa =a.empresa
		--	AND e.folio_movil > ''
		    --    AND e.canal_sol='4' 
            --            AND e.num_producto = a.num_producto
			--AND  e.num_solicitud = a.num_solicitud  
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud

												 		
			SELECT  limit 1 e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,vDescCausaSol,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        /*AND e.fecha_entrada = (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)}
                                            MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                            WHERE h.empresa           = o_empresa
										      AND h.num_solicitud     = s_numsol
											  AND h.status_solicitud  = s_status) */
              AND f.num_producto = sNumProducto
              AND f.empresa = o_empresa
              and x.empresa = o_empresa
              AND x.status_solicitud= s_status
			  AND i.empresa = o_empresa
			  AND i.tp_solicitud = pTipoSol;
		
			LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));
      
					
			IF s_fechaaut IS NULL THEN
				LET s_fechaaut = DATE(1);
			END IF;
			
				LET vdias_vigencia = vfecha_hoy - s_fechaaut;
			
			IF s_status <> "AT" THEN
				LET s_fechaaut = "";
				LET s_linea = 0;
			END IF
		   
			RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia WITH RESUME;
        END FOREACH;

	ELIF o_Tipo = 2 THEN
		---2 Select num_producto = uno  y Status = Todos
 		FOREACH 
		  SELECT skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
		--	INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol, apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc, pTipoSol
			FROM "informix".ss_solicitudes_movil e 
			INNER JOIN  "informix".ss_solicitudes a ON (a.empresa = e.empresa and a.sucursal = e.sucursal AND  a.num_solicitud = e.num_solicitud AND a.num_producto = o_Num_producto AND  a.tipo_solicitud IN ('T','C') 
			AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','PA','CN') )
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud 
                                                    /*and fecha_entrada = 
                                                           (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)}
                                                            MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = num_solicitud
											                AND c.status_solicitud  = status_solicitud)*/
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte)
			--WHERE e.empresa =a.empresa
			--AND e.folio_movil > ''
			--AND e.producto = a.num_producto
			--AND  e.num_solicitud = a.num_solicitud  
		--	ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
	union	  
             SELECT --skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_prospecteo_solicitudes e 
			INNER JOIN  "informix".ss_solicitudes a ON (e.empresa = a.empresa 
                                                        AND e.numcte=a.numcte
                                                        AND e.num_solicitud = a.num_solicitud
                                                        and e.estatus<>''
                                                        AND e.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','PA','CN')			
                                                        AND e.canal_sol='4')
            INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud 
                                                    /*and fecha_entrada = 
                                                           (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)}
                                                            MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = a.num_solicitud
											                AND c.status_solicitud  = a.status_solicitud)*/
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte)
			WHERE e.empresa =a.empresa
		--	AND e.folio_movil > ''
		--	AND e.canal_sol=4
		--	AND e.num_producto = a.num_producto
		--	AND  e.num_solicitud = a.num_solicitud  
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
			
			SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,vDescCausaSol,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        /*AND e.fecha_entrada = (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)} 
                                            MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                            WHERE h.empresa         = o_empresa--c.empresa
										    AND h.num_solicitud     = s_numsol
											AND h.status_solicitud  = s_status)*/ --c.status_solicitud)
              AND f.num_producto = sNumProducto
              AND f.empresa = o_empresa
              and x.empresa = o_empresa
              AND x.status_solicitud= s_status
			  AND i.empresa = o_empresa
			  AND i.tp_solicitud = pTipoSol;			
			
			LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));


			IF s_fechaaut IS NULL THEN
				LET s_fechaaut = DATE(1);
			END IF;

				LET vdias_vigencia = vfecha_hoy - s_fechaaut;

			IF s_status <> "AT" THEN
				LET s_fechaaut = "";
				LET s_linea = 0;
			END IF

			RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc,s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia WITH RESUME;
        END FOREACH;
	ELIF o_Tipo = 3 THEN
		----3 Select Todos los productos y una solicitud   
		FOREACH 
		SELECT  skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
		--	INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol, apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc, pTipoSol
			FROM "informix".ss_solicitudes_movil e 
			INNER JOIN  "informix".ss_solicitudes a ON (a.empresa = e.empresa and a.sucursal = e.sucursal AND  a.num_solicitud = e.num_solicitud AND  a.tipo_solicitud IN ('T','C') 
			AND a.status_solicitud =o_status_solicitud )
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud 
                                                /*and fecha_entrada = 
                                                           (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)}
                                                            MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = num_solicitud
											                AND c.status_solicitud  = status_solicitud)*/
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
			WHERE e.empresa =a.empresa
			--AND e.folio_movil > ''
			AND e.producto = a.num_producto
			AND  e.num_solicitud = a.num_solicitud  
--			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
	union

	SELECT -- skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_prospecteo_solicitudes e 
			INNER JOIN  "informix".ss_solicitudes a ON (e.empresa=a.empresa
                                                    and e.numcte=a.numcte
                                                    and e.num_solicitud=a.num_solicitud
                                                    and e.estatus<>''
                                                    and e.status_solicitud=o_status_solicitud
                                                    and canal_sol='4')
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud
                                    /* and fecha_entrada = 
                                                           (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)}
                                                            MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = o_empresa
									   	                    AND c.num_solicitud     = a.num_solicitud
											                AND c.status_solicitud  = a.status_solicitud)*/
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
			WHERE e.empresa =a.empresa
		--	AND e.folio_movil > ''
		--	AND e.num_producto = a.num_producto
			AND  e.num_solicitud = a.num_solicitud  
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
						
			
			SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,vDescCausaSol,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        /*AND e.fecha_entrada = (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)}
                                      MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = o_empresa--c.empresa
									  AND h.num_solicitud     = s_numsol
									  AND h.status_solicitud  = s_status)*/ --c.status_solicitud)
              AND f.num_producto = sNumProducto
              AND f.empresa = o_empresa
              and x.empresa = o_empresa
              AND x.status_solicitud= s_status
			  AND i.empresa = o_empresa
			  AND i.tp_solicitud = pTipoSol;			

			LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));


			IF s_fechaaut IS NULL THEN
				LET s_fechaaut = DATE(1);
			END IF;

				LET vdias_vigencia = vfecha_hoy - s_fechaaut;

			IF s_status <> "AT" THEN
				LET s_fechaaut = "";
				LET s_linea = 0;
			END IF

			RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia WITH RESUME;
        END FOREACH;
	ELIF o_Tipo = 4 THEN
			----4 Select uno uno
		FOREACH 
		SELECT  skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			FROM "informix".ss_solicitudes_movil e 
			INNER JOIN  "informix".ss_solicitudes a ON (a.empresa = e.empresa 
														and a.sucursal = o_sucursal
													AND a.num_producto  = o_Num_producto
													AND a.status_solicitud =o_status_solicitud 
													AND  a.num_solicitud = e.num_solicitud
													AND  a.tipo_solicitud IN ('T','C') 
													)
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud and fecha_entrada = 
                                                           (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)}
                                                            MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = num_solicitud
											                AND c.status_solicitud  = status_solicitud)
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b          ON (a.numcte  = b.numcte  )
			WHERE e.empresa =a.empresa
			--AND e.folio_movil > ''
			AND e.producto = a.num_producto
			AND  e.num_solicitud = a.num_solicitud  
	--		ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
	union	
SELECT -- skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_prospecteo_solicitudes e 
			INNER JOIN  "informix".ss_solicitudes a ON (e.empresa = a.empresa 
							    	    and e.numcte=a.numcte
							    	    AND e.num_solicitud = e.num_solicitud
                                        and e.estatus<>''
                                        AND e.status_solicitud =o_status_solicitud 
                                        AND e.canal_sol='4' )
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud 
                                                                    and a.status_solicitud = c.status_solicitud and fecha_entrada = (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)} MAX(fecha_entrada) 
                                                                                                                                    FROM "informix".ss_autorizacion h
                                                                                                                                     WHERE c.empresa  = empresa
									   	                                                    AND c.num_solicitud = num_solicitud
											                                     AND c.status_solicitud  = status_solicitud)
                                                                   AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
						  	           AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b          ON (a.numcte  = b.numcte  )
			WHERE e.empresa =a.empresa
		        AND canal_sol='4'	
                        AND e.num_producto = a.num_producto
			AND  e.num_solicitud = a.num_solicitud  
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
			
			SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,vDescCausaSol,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        /*AND e.fecha_entrada = (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)}
                                      MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = o_empresa--c.empresa
									  AND h.num_solicitud     = s_numsol
									  AND h.status_solicitud  = s_status)*/ --c.status_solicitud)
              AND f.num_producto = sNumProducto
              AND f.empresa = o_empresa
              and x.empresa = o_empresa
              AND x.status_solicitud= s_status
			  AND i.empresa = o_empresa
			  AND i.tp_solicitud = pTipoSol;			
			

			LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));


			IF s_fechaaut IS NULL THEN
				LET s_fechaaut = DATE(1);
			END IF;

			LET vdias_vigencia = vfecha_hoy - s_fechaaut;

			IF s_status <> "AT" THEN
				LET s_fechaaut = "";
				LET s_linea = 0;
			END IF

			RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia WITH RESUME;
        END FOREACH;
	ELIF o_Tipo = 0 Then		  
			-- SELECT x nombre
            FOREACH
				SELECT  skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
--			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol, apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc, pTipoSol
			FROM "informix".ss_solicitudes_movil e 
			INNER JOIN  "informix".ss_solicitudes a ON (a.empresa = e.empresa and a.sucursal = e.sucursal 
			AND  a.num_solicitud = e.num_solicitud 			
			AND  a.tipo_solicitud IN ('T','C') 
			AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','PA','CN')			)
			INNER JOIN bdinteg:"informix".si_cliente b          ON (a.numcte  = b.numcte  )
			WHERE e.empresa =a.empresa
			--AND e.folio_movil > ''
			AND e.producto = a.num_producto
			AND e.numcte = o_numcte
			AND  e.num_solicitud = a.num_solicitud  
		      --ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
                 union
				
                       SELECT -- skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_prospecteo_solicitudes e 
			INNER JOIN  "informix".ss_solicitudes a ON (e.empresa = a.empresa  
                                            and e.numcte=a.numcte		
                                            AND  e.num_solicitud = a.num_solicitud 			
                                            AND  e.estatus<>''
                                            AND e.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','PA','CN','IN')	
                                            and e.canal_sol='4')
			INNER JOIN bdinteg:"informix".si_cliente b          ON (a.numcte  = b.numcte  )
			WHERE e.empresa =a.empresa
		--	AND e.folio_movil > ''
			AND e.num_producto = a.num_producto
			AND e.numcte = o_numcte
			AND  e.num_solicitud = a.num_solicitud  
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
			
			SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,vDescCausaSol,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        /*AND e.fecha_entrada = (SELECT {+INDEX (bdisolic:ss_autorizacion empsolsta)} 
                                        MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                        WHERE h.empresa         = o_empresa--c.empresa
										AND h.num_solicitud     = s_numsol
										AND h.status_solicitud  = s_status) --c.status_solicitud)*/
              AND f.num_producto = sNumProducto
              AND f.empresa = o_empresa
              and x.empresa = o_empresa
              AND x.status_solicitud= s_status
			  AND i.empresa = o_empresa
			  AND i.tp_solicitud = pTipoSol;			

    			LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));

						
				IF s_fechaaut IS NULL THEN
					LET s_fechaaut = DATE(1);
				END IF;
					
					LET vdias_vigencia = vfecha_hoy - s_fechaaut;

				IF s_status <> "AT" THEN
					LET s_fechaaut = "";
					LET s_linea = 0;
				END IF;

					LET s_status = s_status;
					LET v_cuantos = v_cuantos + 1;
				IF v_cuantos <= o_solicitudes THEN
				   CONTINUE FOREACH;
				END IF;

				RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia WITH RESUME;
            END FOREACH;
    END IF;
END;
END PROCEDURE
