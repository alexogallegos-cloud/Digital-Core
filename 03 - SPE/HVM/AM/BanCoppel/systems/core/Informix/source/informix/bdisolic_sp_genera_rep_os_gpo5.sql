CREATE PROCEDURE "informix".sp_genera_rep_os_gpo5(p_empresa CHAR(3))
RETURNING CHAR(6);


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************

DEFINE v_cod_ret			CHAR(6);
DEFINE vsqlerr				INTEGER;

DEFINE p_fecha_ini			DATE;
DEFINE p_fecha_fin			DATE;
DEFINE v_numsol				CHAR(20);
DEFINE v_status				CHAR(2);
DEFINE v_fecha_aper			DATE;
DEFINE v_comentario			CHAR(50);	

DEFINE sDia					CHAR(2);
DEFINE sMes					CHAR(2);
DEFINE sYear				CHAR(4);
DEFINE sFechaArch			CHAR(10);
DEFINE cCons1				CHAR(1000);
DEFINE cQuery				CHAR(10000);
DEFINE pArchDescarga		CHAR(100);
DEFINE cnom_Sql				CHAR(100);
DEFINE cSQL1				CHAR(200);
DEFINE cRuta				char(100);


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET v_cod_ret				= "000000";
LET vsqlerr					= 0;

LET p_fecha_ini				= DATE(1);
LET p_fecha_fin				= DATE(1);
LET v_numsol				= "";
LET v_status				= "";
LET v_fecha_aper			= DATE(1);
LET v_comentario			= "";

LET sDia					= "";
LET sMes					= "";
LET sYear					= "";
LET sFechaArch				= "";
LET cCons1					= "";
LET cQuery					= "";
LET pArchDescarga			= "";
LET cnom_Sql				= "";
LET cSQL1					= "";
LET cRuta		 			= "/RESPALDOSNEW/";
--LET cRuta					= "/informix/Israel/";


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************


BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET v_cod_ret=vsqlerr;
      RETURN v_cod_ret;
   END IF;
END EXCEPTION;
	
--	SET DEBUG FILE TO "/informix/sp_genera_rep_os_gpo5.out";
--	TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

	SELECT {+INDEX(bdicred:"informix".sd_fechas idx_sd_fechas)} 
	ADD_MONTHS (pri_dia_mes, -1),last_day (ADD_MONTHS (fecha_hoy, -1))
	INTO p_fecha_ini, p_fecha_fin
	FROM  bdicred:"informix".sd_fechas
	WHERE empresa = p_empresa;

	--- Actualiza bitacora con solicitudes en AP y fecha de apertura
	FOREACH WITH HOLD
	
		SELECT  a.num_solicitud,
				a.status_solicitud
		INTO v_numsol,
				v_status
		FROM bdisolic:ss_solicitudes a
			join bdisolic:bitacora_os_gpo5 b on (a.empresa = b.empresa and a.num_solicitud =  b.num_solicitud)
		WHERE a.empresa = p_empresa
			AND b.fecha_solicitud BETWEEN p_fecha_ini AND p_fecha_fin
			
			
		IF v_status = 'AP' THEN
		
			SELECT fecha_insert 
			INTO v_fecha_aper
			FROM bdisolic:ss_autorizacion 
			WHERE empresa = p_empresa
			AND	num_solicitud = v_numsol and status_solicitud = v_status;
			
			UPDATE "informix".bitacora_os_gpo5 
			SET estatus = v_status, 
				fecha_apertura = v_fecha_aper
			WHERE empresa = p_empresa
			AND num_solicitud = v_numsol;
		ELSE
			IF v_status <> 'AT' THEN
				SELECT comentario
				INTO v_comentario
				FROM bdisolic:ss_autorizacion 
				WHERE empresa = p_empresa
				AND	num_solicitud = v_numsol 
				AND status_solicitud = v_status
				AND fecha_hora in (SELECT MAX(fecha_hora) FROM bdisolic:ss_autorizacion WHERE num_solicitud = v_numsol AND status_solicitud = v_status);
						
				UPDATE "informix".bitacora_os_gpo5 
				SET estatus = v_status, 
					comentario = v_comentario
				WHERE empresa = p_empresa
				AND num_solicitud = v_numsol;
			END IF;
			
		END IF;
		
		LET v_comentario = '';
		LET v_fecha_aper = DATE(1);
		
	END FOREACH;
	
	
-- ****************************************************************************
-- *                        Genera Reporte                                    *
-- ****************************************************************************	
	
	LET sDia= DAY(p_fecha_fin);
	LET sMes= MONTH(p_fecha_fin);
	LET sYear= YEAR(p_fecha_fin);
	
	IF LENGTH(sDia)<2 THEN
		LET sDia="0"||sDia;
	END IF;
	
	IF LENGTH(sMes)<2 THEN
		LET sMes="0"||sMes;
	END IF;	
	
	LET sFechaArch=sDia||sMes||sYear;
	LET cnom_Sql = 'Reporte_aux.sql';
	LET pArchDescarga= "/RESPALDOSNEW/clientes_excepcionOS_"||TRIM(sFechaArch)||".txt";
--	LET pArchDescarga= "/informix/Israel/clientes_excepcionOS_"||TRIM(sFechaArch)||".txt";


		LET cCons1 = " SELECT producto,num_solicitud,fecha_solicitud,fecha_apertura,estatus,sucursal, "
			||  " grupo,bc_score,sc_propietario,fico_score,fc_extended,linea_credito,motivo "
			||  " FROM bdisolic:bitacora_os_gpo5 "
			||  " WHERE fecha_solicitud BETWEEN "
			||  " (SELECT {+INDEX(bdicred:'informix'.sd_fechas idx_sd_fechas)} ADD_MONTHS (pri_dia_mes, -1) "
			||  " FROM  bdicred:sd_fechas WHERE empresa = '001') AND " 
			||  " (SELECT {+INDEX(bdicred:'informix'.sd_fechas idx_sd_fechas)} "
			||  " last_day (ADD_MONTHS (fecha_hoy, -1))	FROM  bdicred:sd_fechas "
			||  " WHERE empresa = '001');";
					
			
		LET pArchDescarga = pArchDescarga;
		LET cSQL1 = '">'||TRIM(cRuta)|| cnom_Sql;
	
		LET cQuery = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||" delimiter '|'  "||TRIM(cCons1) || " " || cSQL1;
		
		SYSTEM TRIM(cQuery);
	
	
		LET cQuery='chmod 777 '|| TRIM(cRuta)|| cnom_Sql;
		System cQuery;
	
		let cQuery = 'dbaccess bdisolic ' || TRIM(cRuta) || cnom_Sql;
		System cQuery;
	
	
	RETURN v_cod_ret;	
	
END;	

END PROCEDURE;