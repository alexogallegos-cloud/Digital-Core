CREATE PROCEDURE  "informix".envia_monitorsol_cjunk_ss_popup(o_empresa 		CHAR(3), 
													   o_sucursal 			CHAR(20), 
           				                               o_solicitudes 		SMALLINT, 
				                                       o_numcte 			CHAR(20),
				                                       o_status_solicitud 	CHAR(5),
				                                       o_Num_producto 		CHAR(4),
				                                       o_Tipo 				INTEGER,										   
				                                       pFechaIni 			DATE, 
				                                       pFechaFin 			DATE)


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
-- COMENTARIOS: Se modifica para que muestre las solicitud de CrÃÂ©dito 
--              BanCoppel y las de CrÃÂ©dito Coppel
-------------------------------------------------------------------------------
-- FECHA: 2010/02/09
-- MODIFICO: Paul Ivan Quintero Varela
-- COMENTARIOS: Se modifica para realizar las consulta por tipo de solicitud 
--              en vez de realizarla por el producto.
-------------------------------------------------------------------------------
-- FECHA: 2011/06/08
-- MODIFICO: JesÃÂºs Manuel Aguilar Heredia
-- COMENTARIOS: Se modifica para realizar la homologacion del procedimiento con la versiÃÂ³n envia_monitorsol.
--se elimina codigo que no se usa para cumplir con los estandares de codificacion.
-------------------------------------------------------------------------------
-- FECHA: 2012
-- MODIFICO: JesÃÂºs Manuel Aguilar Heredia
-- COMENTARIOS: Se modifica para realizar la homologacion del procedimiento con la versiÃÂ³n envia_monitorsol.
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
--DEFINE vdias_vigencia 	  SMALLINT;
DEFINE vdias_vigencia 	  INTEGER;
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

DEFINE cEstatus_aplica  CHAR(100);
DEFINE cAplica			CHAR(10);
DEFINE iLongitud		INTEGER;
DEFINE i				INTEGER;
DEFINE cEstatus         CHAR(100);
DEFINE pTipoSol			CHAR(2);
DEFINE vstatusCoppel          CHAR (1);
DEFINE iCausaSituacionEspecial INTEGER;
-- VARIABLES Solicitudes dobles 1 cte
DEFINE cNumCteAux       CHAR(20);
DEFINE cCodRet2         CHAR(6);
DEFINE cNumSolEliminar  CHAR(20);
DEFINE cNum_ProdAux		CHAR(4);
DEFINE sSolsTot			SMALLINT;
DEFINE solic_prospecteo	CHAR(12);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret          = "000";
LET vsqlerr           = 0;
--LET s_nombre          = "??????????";
--LET s_numcte          = "??????????";
LET s_nombre          = "";
LET s_numcte          = "";
LET s_fechaaut        = "";
LET s_fechasol        = "";
--LET s_status          = "??";
--LET s_numsol          = "??????????";
--LET s_comentario      = "??????????";
--LET s_stdesc          = "??????????";
--LET s_rfc             = "??????????";
LET s_status          = "";
LET s_numsol          = "";
LET s_comentario      = "";
LET s_stdesc          = "";
LET s_rfc             = "";
LET s_linea           = 0;
LET s_diacorte        = "20";
--LET s_divisa          = "??";
LET s_divisa          = "";
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
LET vstatusCoppel = '';
LET iCausaSituacionEspecial = 0;
-- VARIABLES Solicitudes dobles 1 cte
LET cNumCteAux          = "";
LET cCodRet2            = "";
LET cNumSolEliminar     = "";
LET cNum_ProdAux		= '';
LET sSolsTot			= 0;
LET solic_prospecteo	= "";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc,
             s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,s_comentario,vdias_vigencia;
   END IF;
END EXCEPTION;

  --SET DEBUG FILE TO '/informix/motor_ev_efv/trace/envia_monitorsol_cjunk_ss_PopUp.out';
  --TRACE ON;
 
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   	SET ISOLATION TO DIRTY READ;
--    SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET LOCK MODE TO WAIT 3;

   -- Carga la Fecha del Dia
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = o_empresa;
	 
	-- Cancela solicitudes dobles de clientes del mismo producto.
	IF NVL(o_status_solicitud,"") = "AT" OR NVL(o_numcte,"") <> ""  THEN 
	
		IF  NVL(o_numcte,"") <> "" THEN	-- Busqueda por cliente

			FOREACH WITH HOLD
			   SELECT a.numcte, a.num_producto, count(a.numcte) INTO cNumCteAux, cNum_ProdAux, sSolsTot
				 FROM "informix".ss_solicitudes a
				 JOIN bdicred:sd_definicion p ON (a.numcte = o_numcte and a.num_producto = p.num_producto and p.llena_solicitud = 'S' and lower(p.edocta_param) = 'tdc')
				WHERE a.status_solicitud = 'AT' 																						-- in ('6600','8100','7000','6001')
				GROUP BY a.numcte, a.num_producto
			   HAVING COUNT (a.numcte) > 1
			   
				FOREACH WITH HOLD
				 SELECT num_solicitud INTO cNumSolEliminar
				   FROM bdisolic:"informix".ss_solicitudes 
				  WHERE numcte = cNumCteAux
					AND num_producto = cNum_ProdAux -- IN ('6600','8100','7000','6001')
					AND status_solicitud = 'AT'
					ORDER BY monto_solicitado DESC
						   
					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'sistema', cNumSolEliminar, 'RT', 'PPD', 'Mas de un tramite de tarjeta de credito por dia') INTO cCodRet2;
					IF cCodRet2 <> '000000' THEN											
						CONTINUE FOREACH;
					END IF;
					
					LET sSolsTot = sSolsTot - 1;
					IF sSolsTot <= 1 THEN
						EXIT FOREACH;
					END IF;
				END FOREACH;
			END FOREACH;
		ELSE -- Inicia busqueda por sucursal

			FOREACH WITH HOLD	
			  SELECT a.numcte, a.num_producto, count(a.numcte) INTO cNumCteAux, cNum_ProdAux, sSolsTot
				FROM "informix".ss_solicitudes a
				JOIN bdicred:sd_definicion p ON (a.sucursal = o_sucursal and a.status_solicitud = 'AT' and a.num_producto = p.num_producto and p.llena_solicitud = 'S' and lower(p.edocta_param) = 'tdc')
			   GROUP BY a.numcte, a.num_producto																										 --in ('6300','7700','7600','6800') 	
			  HAVING COUNT (a.numcte) > 1
			  
				FOREACH WITH HOLD
				 SELECT num_solicitud INTO cNumSolEliminar
				   FROM bdisolic:"informix".ss_solicitudes 
				  WHERE numcte = cNumCteAux
					AND num_producto = cNum_ProdAux -- IN ('6600','8100','7000','6001')
					AND status_solicitud = 'AT'
					order by monto_solicitado desc

					EXECUTE PROCEDURE "informix".sp_actualiza_status_sol(o_empresa, 'sistema', cNumSolEliminar, 'RT', 'PPD', 'Mas de un tramite de tarjeta de credito por dia') INTO cCodRet2;
					
					IF cCodRet2 <> '000000' THEN											
						CONTINUE FOREACH;
					END IF;
					
					LET sSolsTot = sSolsTot - 1;
					IF sSolsTot <= 1 THEN
						EXIT FOREACH;
					END IF;
				END FOREACH;
			END FOREACH;
		END IF;
	END IF;	-- Cancela solicitudes dobles de clientes del mismo producto.

	 
	IF o_Tipo = 1 THEN

		FOREACH 
			SELECT {+INDEX("informix".ss_solicitudes idx_ss_solicitudes2)} skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_solicitudes a
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud and fecha_entrada = 
                                                           (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = num_solicitud
											                AND c.status_solicitud  = status_solicitud)
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
			WHERE a.sucursal = o_Sucursal			
			AND a.tipo_solicitud IN ('T','C') 
			AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','CM','PA','IN')			
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
												 		
			SELECT  limit 1 e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,s_comentario,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        AND e.fecha_entrada = (SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                            WHERE h.empresa           = o_empresa
										      AND h.num_solicitud     = s_numsol
											  AND h.status_solicitud  = s_status) 
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
			   -- AAME RQM 10 679 Carga la Fecha de Corte	 
				--SET ISOLATION TO DIRTY READ;
				SELECT dia_cuota
				  INTO s_diacorte
				  FROM bdicred:"informix".sd_definicion
				 WHERE num_producto = sNumProducto;	 
			
			IF sNumProducto= '6500' AND s_status = 'AT' THEN 
				SELECT nvl(status,''),  NVL (causa,'0')
				INTO vstatusCoppel,iCausaSituacionEspecial 
				FROM bdisolic:"informix".ss_os_solautdirecta 
				WHERE empresa = o_empresa 
                AND num_solicitud = s_numsol;
			
				IF vstatusCoppel = 'S' AND iCausaSituacionEspecial <> '50' THEN 
					LET s_comentario = 'Preautorizada por supervisar';
				END IF;
			END IF;
-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------icm_MOSTRAR "PA" en monitor por PROSPECTEO  ------------------
----------------------------------------------------------------------------------------------------------------			  			
				IF s_status = 'PA' THEN					
					LET s_comentario = 'Pre-Aut, Continua integracion del expediente en Alta Unica';					
				END IF	
-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------icm_MOSTRAR "PA" en monitor por PROSPECTEO  ------------------
----------------------------------------------------------------------------------------------------------------			
			RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,s_comentario,vdias_vigencia WITH RESUME;
        END FOREACH;

	ELIF o_Tipo = 2 THEN
		---2 Select num_producto = uno  y Status = Todos
 		FOREACH 
		  SELECT {+INDEX("informix".ss_solicitudes idx_ss_solicitudes2)} skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_solicitudes a
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud and fecha_entrada = 
                                                           (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = num_solicitud
											                AND c.status_solicitud  = status_solicitud)
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte)
			WHERE a.sucursal = o_Sucursal			
			AND a.num_producto = o_Num_producto
			AND a.tipo_solicitud IN ('T','C') 
			AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','CM','PA','IN')			
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
			
			SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,s_comentario,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        AND e.fecha_entrada = (SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = o_empresa--c.empresa
										                  AND h.num_solicitud     = s_numsol
											                AND h.status_solicitud  = s_status) --c.status_solicitud)
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
			
			IF sNumProducto = '6500' AND s_status = 'AT' THEN 
				SELECT nvl(status,''),  NVL (causa,'0')
				INTO vstatusCoppel,iCausaSituacionEspecial 
				FROM bdisolic:"informix".ss_os_solautdirecta 
				WHERE empresa = o_empresa 
                AND num_solicitud = s_numsol;
			
				IF vstatusCoppel = 'S' AND iCausaSituacionEspecial <> '50' THEN 
					LET s_comentario = 'Preautorizada por supervisar';
				END IF;
			END IF;
			
			   -- AAME RQM 10 679 Carga la Fecha de Corte	 
				--SET ISOLATION TO DIRTY READ;
				SELECT dia_cuota
				  INTO s_diacorte
				  FROM bdicred:"informix".sd_definicion
				 WHERE num_producto = sNumProducto;
-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------icm_MOSTRAR "PA" en monitor por PROSPECTEO  ------------------
----------------------------------------------------------------------------------------------------------------			  
				IF s_status = 'PA' THEN					
					LET s_comentario = 'Pre-Aut, Continua integracion del expediente en Alta Unica';					
				END IF	
-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------icm_MOSTRAR "PA" en monitor por PROSPECTEO  ------------------
----------------------------------------------------------------------------------------------------------------						
			RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc,s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,s_comentario,vdias_vigencia WITH RESUME;
        END FOREACH;
	ELIF o_Tipo = 3 THEN
		----3 Select Todos los productos y una solicitud   
		FOREACH 
		SELECT {+INDEX("informix".ss_solicitudes idx_ss_solicitudes2)} skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_solicitudes a
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud and fecha_entrada = 
                                                           (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = num_solicitud
											                AND c.status_solicitud  = status_solicitud)
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
			WHERE a.sucursal = o_Sucursal						
			AND a.tipo_solicitud IN ('T','C') 
			AND a.status_solicitud = o_status_solicitud
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
			
			SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,s_comentario,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        AND e.fecha_entrada = (SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = o_empresa--c.empresa
										                  AND h.num_solicitud     = s_numsol
											                AND h.status_solicitud  = s_status) --c.status_solicitud)
              AND f.num_producto = sNumProducto
              AND f.empresa = o_empresa
              and x.empresa = o_empresa
              AND x.status_solicitud= s_status
			  AND i.empresa = o_empresa
			  AND i.tp_solicitud = pTipoSol;			

			LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));


			IF sNumProducto= '6500' AND s_status = 'AT' THEN 
				SELECT nvl(status,''),  NVL (causa,'0')
				INTO vstatusCoppel,iCausaSituacionEspecial 
				FROM bdisolic:"informix".ss_os_solautdirecta 
				WHERE empresa = o_empresa 
                AND num_solicitud = s_numsol;
			
				IF vstatusCoppel = 'S' AND iCausaSituacionEspecial <> '50' THEN 
					LET s_comentario = 'Preautorizada por supervisar';
				END IF;
			END IF;
				
			IF s_fechaaut IS NULL THEN
				LET s_fechaaut = DATE(1);
			END IF;

				LET vdias_vigencia = vfecha_hoy - s_fechaaut;

			IF s_status <> "AT" THEN
				LET s_fechaaut = "";
				LET s_linea = 0;
			END IF;
			
			   -- AAME RQM 10 679 Carga la Fecha de Corte	 
				--SET ISOLATION TO DIRTY READ;
				SELECT dia_cuota
				  INTO s_diacorte
				  FROM bdicred:"informix".sd_definicion
				 WHERE num_producto = sNumProducto;	 
				 
			RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,s_comentario,vdias_vigencia WITH RESUME;
        END FOREACH;
	ELIF o_Tipo = 4 THEN
			----4 Select uno uno
		FOREACH 
		SELECT {+INDEX("informix".ss_solicitudes idx_ss_solicitudes2)} skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_solicitudes a
			INNER JOIN "informix".ss_autorizacion c on (a.empresa = c.empresa and a.num_solicitud = c.num_solicitud and a.status_solicitud = c.status_solicitud and fecha_entrada = 
                                                           (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion h
                                                            WHERE c.empresa           = empresa
									   	                    AND c.num_solicitud     = num_solicitud
											                AND c.status_solicitud  = status_solicitud)
                                                            AND c.fecha_entrada >= CASE WHEN NVL(pFechaIni,'') = '' THEN  vfecha_hoy - 10 ELSE pFechaIni END
															AND c.fecha_entrada <= CASE WHEN NVL(pFechaFin,'') = '' THEN  vfecha_hoy ELSE  pFechaFin END )
			INNER JOIN bdinteg:"informix".si_cliente b          ON (a.numcte  = b.numcte  )
			WHERE  a.sucursal = o_sucursal
			AND a.num_producto  = o_Num_producto
			AND a.status_solicitud = o_status_solicitud
			AND a.tipo_solicitud IN ('T','C') 			
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
			
			SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,s_comentario,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        AND e.fecha_entrada = (SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = o_empresa--c.empresa
										                  AND h.num_solicitud     = s_numsol
											                AND h.status_solicitud  = s_status) --c.status_solicitud)
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
			
			IF sNumProducto= '6500' AND s_status = 'AT' THEN 
				SELECT nvl(status,''),  NVL (causa,'0')
				INTO vstatusCoppel,iCausaSituacionEspecial 
				FROM bdisolic:"informix".ss_os_solautdirecta 
				WHERE empresa = o_empresa 
                AND num_solicitud = s_numsol;
			
				IF vstatusCoppel = 'S' AND iCausaSituacionEspecial <> '50' THEN 
					LET s_comentario = 'Preautorizada por supervisar';
				END IF;
			END IF;
			
			   -- AAME RQM 10 679 Carga la Fecha de Corte	 
				--SET ISOLATION TO DIRTY READ;
				SELECT dia_cuota
				  INTO s_diacorte
				  FROM bdicred:"informix".sd_definicion
				 WHERE num_producto = sNumProducto;	 
				 
			RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,s_comentario,vdias_vigencia WITH RESUME;
        END FOREACH;
	ELIF o_Tipo = 0 Then		
			-- SELECT x nombre
            FOREACH
				--APR 20220225 Se comenta lÃÂ­nea
				--SELECT {+INDEX("informix".ss_solicitudes idx_numctesolic)} skip o_solicitudes limit 11 				
				--APR 20220225 se le quita el limit
				SELECT {+INDEX("informix".ss_solicitudes idx_numctesolic)}
					a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
					NVL(a.monto_solicitado,0), a.fecha_insert, 
					b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
					a.tipo_solicitud
				INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
					apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
					pTipoSol
				FROM "informix".ss_solicitudes a
				INNER JOIN bdinteg:"informix".si_cliente b          ON (a.numcte  = b.numcte  )
				WHERE  a.numcte = o_numcte
				--INI RQM 09 570-2 - Adendum Pop Ups para informar sobre solicitudes no autorizadas.
				AND a.tipo_solicitud IN ('T','C')
				--AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','CM','PA','IN')
				AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','CM','PA','IN')
				--FIN RQM 09 570-2 - Adendum Pop Ups para informar sobre solicitudes no autorizadas.
				ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud
				
				SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
					NVL(( select  d.descripcion  from "informix".ss_causas_sol d
						where d.empresa = o_empresa AND d.status_solicitud = s_status  
						AND d.causa_solicitud = e.causa_solicitud),''),
					TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
					f.divisa,
					NVL(c.ingreso_mensual, 0)
				INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,s_comentario,s_comentario,			    
					s_divisa,s_ingreso
				FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
					"informix".ss_status_sol x, "informix".ss_tp_solicitud i
				WHERE c.empresa = o_empresa
				AND c.num_solicitud = s_numsol
				AND e.empresa = c.empresa 
				AND e.num_solicitud = c.num_solicitud
						AND e.status_solicitud = s_status
						AND e.fecha_entrada = (SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
										WHERE h.empresa           = o_empresa--c.empresa
															AND h.num_solicitud     = s_numsol
																AND h.status_solicitud  = s_status) --c.status_solicitud)
				AND f.num_producto = sNumProducto
				AND f.empresa = o_empresa
				and x.empresa = o_empresa
				AND x.status_solicitud= s_status
				AND i.empresa = o_empresa
				AND i.tp_solicitud = pTipoSol;
				
				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					IF s_status = "CN" OR s_status = "CM" THEN
						SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
							NVL(( select  d.descripcion  from "informix".ss_causas_sol d
								where d.empresa = o_empresa AND d.status_solicitud = s_status  
								AND d.causa_solicitud = e.causa_solicitud),''),
							TRIM(NVL(e.comentario, ' ')) comentario,
							f.divisa,
							0
						INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,s_comentario,s_comentario,			    
							s_divisa,s_ingreso
						FROM "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
							"informix".ss_status_sol x, "informix".ss_tp_solicitud i
						WHERE e.empresa = o_empresa
							AND e.num_solicitud = s_numsol
							AND e.status_solicitud = s_status
							AND e.fecha_entrada = (	SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
														WHERE 	h.empresa           	= o_empresa
																AND h.num_solicitud     = s_numsol
																AND h.status_solicitud  = s_status)
							AND f.num_producto = sNumProducto
							AND f.empresa = o_empresa
							AND x.empresa = o_empresa
							AND x.status_solicitud= s_status
							AND i.empresa = o_empresa
							AND i.tp_solicitud = pTipoSol;
					END IF;
				END IF;

    			LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));

						
				IF s_fechaaut IS NULL THEN
					LET s_fechaaut = DATE(1);
				END IF;
					
					LET vdias_vigencia = vfecha_hoy - s_fechaaut;

				IF s_status <> "AT" THEN
					LET s_fechaaut = "";
					LET s_linea = 0;
				END IF;
				
			IF sNumProducto= '6500' AND s_status = 'AT' THEN 
				SELECT nvl(status,''),  NVL (causa,'0')
				INTO vstatusCoppel,iCausaSituacionEspecial 
				FROM bdisolic:"informix".ss_os_solautdirecta 
				WHERE empresa = o_empresa 
                AND num_solicitud = s_numsol;
			
				IF vstatusCoppel = 'S' AND iCausaSituacionEspecial <> '50' THEN 
					LET s_comentario = 'Preautorizada por supervisar';
				END IF;
			END IF;
	 
			   -- AAME RQM 10 679 Carga la Fecha de Corte	 
				--SET ISOLATION TO DIRTY READ;
				SELECT dia_cuota
				  INTO s_diacorte
				  FROM bdicred:"informix".sd_definicion
				 WHERE num_producto = sNumProducto;	 
				 
					LET s_status = s_status;
					LET v_cuantos = v_cuantos + 1;
				IF v_cuantos <= o_solicitudes THEN
				   CONTINUE FOREACH;
				END IF;
-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------icm_MOSTRAR "PA" en monitor por PROSPECTEO  ------------------
----------------------------------------------------------------------------------------------------------------			  
				IF s_status = 'PA' THEN					
					LET s_comentario = 'Pre-Aut, Continua integracion del expediente en Alta Unica';					
				END IF	
-------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------icm_MOSTRAR "PA" en monitor por PROSPECTEO  ------------------
----------------------------------------------------------------------------------------------------------------


				RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,s_comentario,vdias_vigencia WITH RESUME;
            END FOREACH;
	----------------------------------------------		
	-----Para validacion de prospecteo
	----------------------------------------------
	ELIF o_Tipo = 6 THEN
	    --SELECT count(numcte) INTO es_prospecteo from bdisolic:"informix".ss_prospecteo_solicitudes
		---WHERE numcte = o_numcte AND empresa = o_empresa;
		
		--IF es_prospecteo >= 1 THEN 
		
		    FOREACH
				SELECT {+INDEX("informix".ss_solicitudes idx_numctesolic)} skip o_solicitudes limit 11 				
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM "informix".ss_solicitudes a
			INNER JOIN bdinteg:"informix".si_cliente b          ON (a.numcte  = b.numcte  )
			WHERE  a.numcte = o_numcte
			AND a.tipo_solicitud IN ('T','C') 			
			AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','CM','PC','PA','IN')
			ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud

			
			SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,s_comentario,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        AND e.fecha_entrada = (SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = o_empresa--c.empresa
										                  AND h.num_solicitud     = s_numsol
											                AND h.status_solicitud  = s_status) --c.status_solicitud)
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

			   -- AAME RQM 10 679 Carga la Fecha de Corte	 
				SET ISOLATION TO DIRTY READ;
				SELECT dia_cuota
				  INTO s_diacorte
				  FROM bdicred:"informix".sd_definicion
				 WHERE num_producto = sNumProducto;	 
				 
					LET s_status = s_status;
					LET v_cuantos = v_cuantos + 1;
				IF v_cuantos <= o_solicitudes THEN
				   CONTINUE FOREACH;
				END IF;

				RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,s_comentario,vdias_vigencia WITH RESUME;
            END FOREACH;
		
		----------------------------------------------	
		-------	termina validacion de prospecteo 
		----------------------------------------------
	ELIF o_Tipo = 5 Then		  
			-- SOLICITUDES RECHAZADAS POR OS CALLE
            FOREACH
				select  skip o_solicitudes limit 11 
				sol.num_solicitud, sol.numcte, sol.status_solicitud, sol.num_producto,
				sol.monto_solicitado, sol.fecha_insert, 
				cte.apell_paterno, cte.apell_materno, cte.Nombre1,cte.Nombre2, cte.razon_social, cte.rfc,
				sol.tipo_solicitud
				into s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
                    from bdisolic:"informix".ss_solicitudes sol, bdinteg:si_cliente cte,
                         bdisolic:"informix".ss_resum_scor_fin  res, 
                         bdisolic:"informix".ss_solicitud_os solos , "informix".ss_autorizacion c ,
						 bdisitesp:"informix".se_catsitesp esp, bdinteg:"informix".si_telefonos_actual tel,
						 bdinteg:"informix".si_telefonos_actual tel2, bdinteg:"informix".si_bitsmstels sms
                    where cte.numcte = sol.numcte
					  and res.num_solicitud = sol.num_solicitud  
					  and res.empresa = sol.empresa
					  and sol.status_solicitud = "RT"
					  and sol.tipo_solicitud ='T'
					  and sol.sucursal = o_sucursal				
					  and sol.num_producto  = o_Num_producto
					  and res.evalua_cc = '0'
					  and sol.num_solicitud = solos.num_solicitud
					  and sol.empresa = solos.empresa 
					  and solos.status = 'R'	
					  AND solos.situacionespecialrespuesta = esp.situacion  
					  AND solos.causasituacionespecialrespuesta = esp.causa
					  AND c.fecha_entrada >= TODAY - 60
					  AND esp.autoriza_gerente = '1'
                      and solos.fecha_solicitud = (select max(fecha_solicitud) from bdisolic:ss_solicitud_os 
                                                   where empresa = '001' and num_solicitud = sol.num_solicitud ) 					  
												   AND sol.empresa = c.empresa 
						and sol.num_solicitud = c.num_solicitud 
						and sol.status_solicitud = c.status_solicitud
						and fecha_entrada = (SELECT MAX(fecha_entrada) FROM "informix".ss_autorizacion h
						WHERE c.empresa           = empresa
						AND c.num_solicitud     = num_solicitud
						AND c.status_solicitud  = status_solicitud)
						AND (tel.numcte =cte.numcte 
						and tel.tipo_tel = '2'
						AND tel.status_tel ='A'
						AND tel.cofetel ='V')
						AND (tel2.numcte =cte.numcte 
						and tel2.tipo_tel in ('1','3','4')
						AND tel2.status_tel ='A'
						AND tel2.cofetel ='V'
						AND tel2.secuencia = (SELECT MAX(tel3.secuencia) 
											FROM  bdinteg:"informix".si_telefonos_actual tel3 
											WHERE tel3.numcte =tel2.numcte
											and tel3.tipo_tel in ('1','3','4')
											AND tel3.status_tel ='A'
											AND tel3.cofetel ='V')
							)
						AND (sms.numcte =cte.numcte
						AND sms.bandera = 'T' 
						AND sms.telefono =tel.telefono
						AND sms.teclea_ejecut not in ('1111','2222','3333','4444')
						AND sms.fecha = (SELECT MAX(fecha) FROM  bdinteg:"informix".si_bitsmstels sms2 WHERE sms2.numcte =sms.numcte))
						AND sms.fecha > TODAY -60
					ORDER BY cte.Nombre1, cte.Nombre2, cte.apell_paterno, cte.apell_materno, sol.num_solicitud
			
					
			SELECT limit 1  e.fecha_entrada,i.descripcion,x.descripcion, NVL(e.causa_solicitud,""), 
                   NVL(( select  d.descripcion  from "informix".ss_causas_sol d
				     where d.empresa = o_empresa AND d.status_solicitud = s_status  
					 AND d.causa_solicitud = e.causa_solicitud),''),
				   TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,			
				f.divisa,
                NVL(c.ingreso_mensual, 0)
			INTO s_fechaaut, sProducto, s_stdesc,cCausaSol,s_comentario,s_comentario,			    
				 s_divisa,s_ingreso
			FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f , 
			     "informix".ss_status_sol x, "informix".ss_tp_solicitud i
            WHERE c.empresa = o_empresa
              AND c.num_solicitud = s_numsol
              AND e.empresa = c.empresa 
              AND e.num_solicitud = c.num_solicitud
			        AND e.status_solicitud = s_status
			        AND e.fecha_entrada = (SELECT MAX(h.fecha_entrada) FROM "informix".ss_autorizacion h
                                      WHERE h.empresa           = o_empresa--c.empresa
										                  AND h.num_solicitud     = s_numsol
											                AND h.status_solicitud  = s_status) --c.status_solicitud)
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
			   -- AAME RQM 10 679 Carga la Fecha de Corte	 
				--SET ISOLATION TO DIRTY READ;
				SELECT dia_cuota
				  INTO s_diacorte
				  FROM bdicred:"informix".sd_definicion
				 WHERE num_producto = sNumProducto;	 
				 
					LET s_status = s_status;
					LET v_cuantos = v_cuantos + 1;
				--IF v_cuantos <= o_solicitudes THEN
				  -- CONTINUE FOREACH;
				--END IF;

				RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, "RS", s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,s_comentario,vdias_vigencia WITH RESUME;
            END FOREACH;
    END IF;
END;
END PROCEDURE
