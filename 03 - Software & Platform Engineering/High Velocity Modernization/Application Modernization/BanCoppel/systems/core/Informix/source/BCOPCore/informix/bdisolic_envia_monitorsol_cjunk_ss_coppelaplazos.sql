CREATE PROCEDURE  "informix".envia_monitorsol_cjunk_ss_coppelaplazos(o_empresa CHAR(3), 
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

DEFINE cEstatus_aplica CHAR(100);
DEFINE cAplica			CHAR(10);
DEFINE iLongitud		INTEGER;
DEFINE i				INTEGER;
DEFINE cEstatus        CHAR(100);
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
DEFINE s_numcteCoppel	CHAR(20);
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
LET s_numcteCoppel		= "";

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

  --SET DEBUG FILE TO "/home/sysifx/respaldosbd/JesusRLopez/789/envia_monitorsol_cjunk_ss.out";
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

	IF o_Tipo = 0 Then		  
	
			SELECT limit 1			
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert, 
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
			INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
				apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
				pTipoSol
			FROM bdisolic: "informix".ss_solicitudes a
			INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
			WHERE  a.numcte = o_numcte
			AND a.tipo_solicitud = 'C'
			AND a.status_solicitud IN ('AP','AT')
			AND a.num_producto = '6500';

			
		IF s_numsol IS NULL THEN
		
		
		SELECT cliente 
		INTO s_numcteCoppel
		FROM bdinteg: "informix".si_relacion_ctebcplcpl 
		WHERE numcte_banco = o_numcte;
		
			IF TRIM(s_numcteCoppel) <> "" THEN
						
					EXECUTE PROCEDURE bdisolic: "informix".asigna_numsol(o_empresa,'6500')
					INTO scod_ret, s_numsol;
					-- se inserta solo un registro
					INSERT INTO "informix".ss_solicitudes
					(empresa, num_solicitud, numcte, sucursal, tipo_solicitud,
					status_solicitud, num_producto, user_insert, fecha_insert)
					VALUES
					(o_empresa, s_numsol, o_numcte, o_sucursal, "C","AP", "6500", USER, CURRENT);
					
					-- se inserta solo un registro
					 INSERT INTO  "informix".ss_resum_scor_fin
                    (empresa, num_solicitud, situacion_pago, situacion_credito,
                    meses_historia, fuente, ingreso_mensual, linea_tienda, causa,
                    puntualidad, saldoropa, saldomuebles, saldoprestamos, vencidoropa,
                    vencidomuebles, vencidoprestamos, abonomensualropa, abonomensualmuebles,
                    abonomensualprestamos,origen)
					VALUES
                    (o_empresa, s_numsol, 0 , "0", 0,"", 0, "", "", "", 0,0, 0, 0, 0,0, 0, 0,0,'1');

					SELECT  LIMIT 1			
						a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
						a.monto_solicitado, a.fecha_insert, 
						b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
						a.tipo_solicitud
					INTO s_numsol, s_numcte, s_status, sNumProducto, s_linea, s_fechasol,
						apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,
						pTipoSol
					FROM bdisolic: "informix".ss_solicitudes a
					INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte  )
					WHERE  a.numcte = o_numcte
					AND a.tipo_solicitud = 'C'
					AND a.status_solicitud IN ('AP','AT')
					AND a.num_producto = '6500';
		
			END IF;
		END IF
		
	
			
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
	 

				SELECT dia_cuota
				  INTO s_diacorte
				  FROM bdicred:"informix".sd_definicion
				 WHERE num_producto = sNumProducto;	 
		
				RETURN scod_ret, s_numsol, s_numcte, s_nombre, s_rfc, s_fechasol, s_fechaaut, sNumProducto, sProducto, s_linea, s_status, s_stdesc, s_comentario, s_diacorte, s_divisa, s_ingreso,cCausaSol,s_comentario,vdias_vigencia;
           
	
    END IF;
END;
END PROCEDURE
