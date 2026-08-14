CREATE PROCEDURE "informix".cal_circulocredito_cjunk2(o_empresa CHAR(3),
                                          o_numcte  CHAR(25),
                                          o_numsol  CHAR (25))

RETURNING CHAR(5), 	 -- Codigo de Retorno
          CHAR(1),	 -- Calificacion 1 Aprobado, 0 Rechazado
		  DECIMAL(14,2), -- Compromisos > 0 si Calificacion es 1
		  VARCHAR(255);  -- Descripcion de Creditos Motivo de Rechazo

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret      CHAR(5);
DEFINE vsqlerr       INTEGER;
DEFINE sql_err       SMALLINT;
DEFINE isam_err      SMALLINT;

DEFINE error_info    CHAR(100);
DEFINE s_califica    CHAR(1);
DEFINE s_compromisos DECIMAL(14,2);
DEFINE vStatus	     CHAR(2);

DEFINE vMensaje      VARCHAR(255);
DEFINE vCuantos      SMALLINT;

DEFINE vMontoUdis    DECIMAL(14,2);
DEFINE vCodUdi       CHAR(2);
DEFINE vCodUs        CHAR(2);
DEFINE vClase        CHAR(1);

DEFINE vTpCambioUdi  DECIMAL(14,6);
DEFINE vTpCambioUs   DECIMAL(14,6);
DEFINE vMaxMtoUdi    DECIMAL(14,2);
DEFINE vInstitucion  CHAR(2);
DEFINE vTl02         CHAR(16);
DEFINE vTl11         CHAR(1);
DEFINE vTl16         DATE;
DEFINE vTl17         DATE;
DEFINE vfecha        DATE;
DEFINE vFechaHoy     DATE;

DEFINE vTl26         CHAR(2);
DEFINE vTl27		CHAR(24);
DEFINE vTl28		DATE;
DEFINE cTpSolicitud     CHAR(1);
define vDescripcion_status char(40);
define i            integer;
define iMesesaConsultar    smallint;
define iMesesCalculados    smallint;
define v_sc01       varchar(04);

define cTipoNegocio varchar(50);
--rss temporal para pruebas unitarias 
define factor smallint;
--rss temporal para pruebas unitarias
define sPosicionIni smallint; 
--
define vmeses6      varchar(6);
define vmeses12     varchar(12);
define vmeses30     varchar(30);
define var_i        smallint;
define vmeses_pos   smallint;
define vbuenpago    char(30);
define vacumpagos   smallint;
define cStatus   char(2);
define cOrigen   char(1);

DEFINE cuenta       INTEGER; --RQM 09 408
DEFINE v_factor     DECIMAL(14,6); --RQM 09 408
DEFINE v_moneda     CHAR(2); --RQM 09 408
DEFINE v_monto      MONEY; --RQM 09 408
DEFINE v_total      MONEY; --RQM 09 408
DEFINE v_tot_tp     MONEY; --RQM 09 408
DEFINE vfechaServ DATE;	
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret      = "000";
LET vsqlerr       = 0;
LET s_califica    = "X";
LET s_compromisos = 0;

LET vStatus       = "";
LET vMontoUdis    = 0;
LET cTpSolicitud  = "";
let vDescripcion_status = "";
let v_sc01       = "";
LET vFechaHoy     = DATE(1);
LET vClase       = "";
let cTipoNegocio = '';
LET vInstitucion = '';
LET iMesesCalculados = 0;
LET sPosicionIni = 0;

let vmeses6      = "";
let vmeses12     = "";
let vmeses30     = "";
let var_i        = 0;  
let vmeses_pos   = 0;
let vbuenpago    = "";
let vacumpagos   = 0;
let cStatus   = "";
let cOrigen   = "C";

LET cuenta       = 0; --RQM 09 408
LET v_factor     = 0;LET v_moneda     = ''; --RQM 09 408
LET v_monto      =0; --RQM 09 408
LET v_total      =0; --RQM 09 408
LET v_tot_tp     =0; --RQM 09 408 

SELECT TRIM(valor)::integer
  INTO iMesesaConsultar
  FROM bdiburo:"informix".br_param
 WHERE cod_param = 12;

   IF iMesesaConsultar IS NULL THEN
      LET iMesesaConsultar=12;
   END IF;

      -- *****************************************
      --       Extrae Tipo de Cmabio Divisa      *
      -- *****************************************
SELECT TRIM(valor) 
  INTO vCodUdi
  FROM bdinteg:si_param
 WHERE empresa = o_empresa
   AND cod_param = 16;

SELECT TRIM(valor) 
  INTO vCodUs
  FROM bdinteg:si_param
 WHERE empresa = o_empresa
   AND cod_param = 17;


      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
      SELECT TRIM(valor) INTO vClase
	    FROM bdicred:sd_param
       WHERE empresa = o_empresa
	     AND cod_param = "336";

    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicred:sd_fechas
     WHERE empresa = o_empresa;
	 
	-- RQI 21 246  Originación de solicitudes 24 x 7
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;

	IF vFechaHoy < vfechaServ THEN
		LET vFechaHoy = vfechaServ;
	END IF;
	------------------------------------------------------------------------------------------------------------------ RQM 10 1404 CHI ->
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	------------------------------------------------------------------------------------------------------------------ RQM 10 1404 CHI <-

--SET DEBUG FILE TO "/informix/Rebeca/cal_circulocredito_cjunk.out";
--TRACE ON;


    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(o_empresa, vFechaHoy,vCodUdi,vClase,'0')
    INTO scod_ret,vTpCambioUdi;

    IF scod_ret<>'00000' THEN
      RETURN scod_ret, s_califica, s_compromisos, "No se econtro valor de UDI";
    END IF;

    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(o_empresa, vFechaHoy,vCodUs,vClase,'1')
    INTO scod_ret,vTpCambioUs;

    IF scod_ret<>'00000' THEN
      RETURN scod_ret, s_califica, s_compromisos, "No se econtro valor de USA";
    END IF;

--LET scod_ret      = "000";

SELECT valor 
  INTO vMaxMtoUdi
  FROM ss_param
 WHERE empresa = o_empresa
   AND secuencia = "309";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
--      SET DEBUG FILE TO "CargoLineaCredito.err";
      LET scod_ret = sql_err;
      RETURN scod_ret, s_califica, s_compromisos, vMensaje;
   END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

-- ***********************************************
-- Ini Caja Unica
-- ***********************************************

LET vMensaje      = "";
LET scod_ret      = "000";
	IF o_numsol <> o_numcte THEN  -- FJPR
		select b.descripcion,a.tipo_solicitud,a.status_solicitud
			into   vDescripcion_status,cTpSolicitud,cStatus
		from bdisolic:"informix".ss_solicitudes a
		left outer join bdisolic:"informix".ss_status_sol b on (a.empresa = b.empresa and a.status_solicitud = b.status_solicitud)
		where a.empresa = o_empresa
		 and a.num_solicitud = o_numsol;

		IF cTpSolicitud IS NULL OR cTpSolicitud = '' THEN 
		   LET scod_ret = '99999';
		   LET cTpSolicitud = 'X'; 
		   LET s_califica = '9';
		   RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		END IF;
	ELSE
		------------------------------------------------------------------------------------------------------------------ RQM 10 1404 CHI ->
		IF EXISTS (SELECT 1
					FROM bdiburo:"informix".br_traslado a,
						bdiburo:"informix".br_tl b, 
						bdiburo:"informix".br_sc c
					WHERE a.numcte  = b.num_cliente
						AND a.numcte  = c.num_cliente
						AND a.institucion = b.institucion
						AND a.institucion = c.institucion
						AND a.fecha_insert = b.fecha
						AND a.fecha_insert = c.fecha
						AND a.numcte = o_numcte
						AND a.institucion = 'BC')	THEN
			LET cTpSolicitud = 'H';
		ELSE
		------------------------------------------------------------------------------------------------------------------ RQM 10 1404 CHI <-
			LET cTpSolicitud = 'T';
		END IF;
	END IF;
	
	IF cStatus = "AP" AND cTpSolicitud = "T" THEN
		SELECT a.origen
		  INTO cOrigen
		FROM bdicred:"informix".sd_bitacora_aumlincred a
		WHERE num_solicitud = o_numsol
		AND fecha_insert = (SELECT MAX(fecha_insert)
							 FROM bdicred:"informix".sd_bitacora_aumlincred c
							WHERE  c.empresa = '001' AND c.num_solicitud = a.num_solicitud);
	END IF
	IF cStatus = "AP" AND cTpSolicitud = "T" AND cOrigen = 'C' THEN--Incremento
		-- Valida MOP actual y se calculan las UDIs descartando los tipos de negocio
			LET vCuantos = 0;
			FOREACH
				SELECT institucion, tl02, tl11, 
					   nvl(tl26,''), 
					   round(CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl24,0) /* * c.factor*/ )/vTpCambioUdi
								  WHEN tl08 = 'US'                THEN ((nvl(b.tl24,0) * vTpCambioUs) /* * c.factor*/ ) /vTpCambioUdi
								  WHEN tl08 = 'UD'                THEN   nvl(b.tl24,0) --* c.factor
							 ELSE nvl(b.tl24,0)  -- * c.factor
							 END,2),
						   tl16,tl17,fecha
				  INTO vInstitucion, vTl02, vTl11, vTl26, vMontoUdis,vTl16,vTl17,vfecha
				  FROM bdiburo:br_tl_bc b, bdisolic:ss_circulo_frecpag c
				 WHERE b.num_cliente  = o_numcte
				   AND NVL(tl26,'') <> ''
				   AND b.tl11=c.tipo
				   and b.tl04 not in (select tl04 FROM bdiburo:br_tl_bc where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				   and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				 ORDER BY tl26 DESC

		-- Se obtiene el tipo de negocio a excluir
		--       SELECT tipo_negocio INTO cTipoNegocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion	= vInstitucion and tipo_negocio = TRIM(vTl02);

		--RQM 09 234 Punto 1 Valida MOPs actual != 03 y exceptuando los tipos de negocio mencionados en requerimiento
			   IF EXISTS(SELECT 1 FROM bdiburo:br_tlmop WHERE codigo = vTl26 AND status_cons IN (1,3)) AND vMontoUdis >= vMaxMtoUdi THEN
					LET vCuantos = 1;
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP actual ' || vTl26 || ' con ' || vMontoUdis || ' UDIs ';
					EXIT FOREACH;
		--RQM 09 234 Punto 1 Valida MOPs actual = 03, saldo vencido >= 100 UDIs y exceptuando los tipos de negocio mencionados en requerimiento
		--       ELIF vTl26 = '03' AND vMontoUdis >= vMaxMtoUdi AND (cTipoNegocio IS NULL OR cTipoNegocio = '') THEN
		--            LET vCuantos = 1;
		--            LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP actual ' || vTl26 || ' con ' || vMontoUdis || ' UDIs ';
		--            EXIT FOREACH;
			   END IF

			END FOREACH;

			IF vCuantos > 0 THEN
				LET s_califica = "1";
				LET vMensaje = trim(vMensaje);
				RETURN scod_ret, s_califica, s_compromisos, vMensaje;
			END IF


		-- Valida MOP histórico de los últimos 12 y 30 meses
		   let vCuantos = 0;
		   let i = 0;
		   let var_i = 0;
			FOREACH
				SELECT institucion, tl02, tl17, tl27, tl28,
					   round(CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl36,0) /* * c.factor*/ )/vTpCambioUdi
								  WHEN tl08 = 'US'                THEN ((nvl(b.tl36,0) * vTpCambioUs) /* * c.factor */) /vTpCambioUdi
								  WHEN tl08 = 'UD'                THEN   nvl(b.tl36,0) -- * c.factor
							 ELSE nvl(b.tl24,0) -- * c.factor
							 END,2),
							case when year(mdy(month(b.fecha),'01',year(b.fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
								 then (year(mdy(month(b.fecha),'01',year(b.fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12 
								else 0
							end +
							month(mdy(month(b.fecha),'01',year(b.fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos
				  INTO vInstitucion, vTl02, vTl17, vTl27, vTl28, vMontoUdis, vmeses_pos
				  FROM bdiburo:br_tl_bc b, bdisolic:ss_circulo_frecpag c
				 WHERE b.num_cliente  = o_numcte
				   AND NVL(tl26,'') <> ''
				   AND b.tl11=c.tipo
				   and b.tl04 not in (select tl04 FROM bdiburo:br_tl_bc where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				   and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				 ORDER BY tl17 DESC
		-- VALIDAR 6 MESES
				 let vmeses6 = '';
				 let vmeses12 = '';
				 let vmeses30 = '';

				 for var_i = 1 to case when vmeses_pos > 6 then 6 else vmeses_pos end
					let vmeses6 = vmeses6||'0'; 
				 end for;

				 let vmeses6 = replace(replace(replace(replace(vmeses6||substr(vTl27,1,6),'-','0'),'X','0'),'U','0'),' ','0');
				 for var_i = 1 to 6
					if (substr(vmeses6,var_i,1) >= 4 and vMontoUdis >= vMaxMtoUdi) then
						LET vCuantos = 1;
						exit for;
					end if;
				 end for;

				 if (vCuantos = 1) then
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || substr(vmeses6,var_i,1) || ' con ' || vMontoUdis || ' UDIs en los últimos 6 meses ';
					LET s_califica = "1";
					LET vMensaje = trim(vMensaje);
					RETURN scod_ret, s_califica, s_compromisos, vMensaje;
				 end if;

		-- VALIDAR 12 MESES
				 let vCuantos = 0;
				 let var_i = 0;

				 for var_i = 1 to case when vmeses_pos > 12 then 12 else vmeses_pos end
					let vmeses12 = vmeses12||'0'; 
				 end for;

				 let vmeses12 = replace(replace(replace(replace(vmeses12||substr(vTl27,1,12),'-','0'),'X','0'),'U','0'),' ','0');

				 let var_i = 0;         

				 for var_i = 1 to 12
					if (substr(vmeses12,var_i,1) >= 4 and vMontoUdis >= vMaxMtoUdi) then
						if (substr(vmeses12,var_i,1) = 4) then
							LET vCuantos = 2;
						else
							LET vCuantos = 1;
						end if;
						exit for;
					end if;
				 end for;

				 if (vCuantos = 1) then
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || substr(vmeses12,var_i,1) || ' con ' || vMontoUdis || ' UDIs en los últimos 12 meses ';
					LET s_califica = "1";
					LET vMensaje = trim(vMensaje);
					RETURN scod_ret, s_califica, s_compromisos, vMensaje;
				 elif (vCuantos = 2) then
		-- VALIDA BUEN PAGO         
					let i = var_i;
					let vCuantos = 0;
					execute procedure cal_buen_pago(o_numcte,'1') INTO scod_ret,vbuenpago;

					if (vbuenpago is not null) then
						let var_i = 0; 
						let vacumpagos = 0;

						for var_i = 1 to length(trim(vbuenpago))
							if substr(trim(vbuenpago),var_i,1) = 'S' then
								let vacumpagos = vacumpagos + 1;
							elif substr(trim(vbuenpago),var_i,1) <> ' ' then
								exit for;
							end if;
							if  (vacumpagos >= 6) then
								exit for;
							end if;

						end for;
					end if;

					if (vacumpagos < 6) then
						LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || substr(vmeses12,i,1) || ' con ' || vMontoUdis || ' UDIs en los últimos 12 meses ';
						LET s_califica = "1";
						LET vMensaje = trim(vMensaje);
						RETURN scod_ret, s_califica, s_compromisos, vMensaje;
					end if;

				 end if;
		-- VALIDAR 30 MESES
				 let vCuantos = 0;
				 let i = 0;
				 let vmeses30 = '';

				 for var_i = 1 to case when vmeses_pos > 30 then 30 else vmeses_pos end
					let vmeses30 = vmeses30||'0'; 
				 end for;

				 let vmeses30 = replace(replace(replace(replace(vmeses30||substr(vTl27,1,24),'-','0'),'X','0'),'U','0'),' ','0');
				 for var_i = 1 to 30
					if (substr(vmeses30,var_i,1) >= 5 and vMontoUdis >= vMaxMtoUdi) then
						LET vCuantos = 2;       
						exit for;
					end if;
				 end for;

				 if (vCuantos = 2) then
		-- VALIDA BUEN PAGO         
					let vCuantos = 0;
					let i = var_i;

					execute procedure cal_buen_pago(o_numcte,'1') INTO scod_ret,vbuenpago;

					if (vbuenpago is not null) then
						let var_i = 0; 
						let vacumpagos = 0;

						for var_i = 1 to length(trim(vbuenpago))
							if substr(trim(vbuenpago),var_i,1) = 'S' then
								let vacumpagos = vacumpagos + 1;
							elif substr(trim(vbuenpago),var_i,1) <> ' ' then
								exit for;
							end if;
							if  (vacumpagos >= 12) then
								exit for;
							end if;
						end for;
					end if;

					if (vacumpagos < 12) then
						LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || substr(vmeses30,i,1) || ' con ' || vMontoUdis || ' UDIs en los últimos 30 meses ';
						LET s_califica = "1";
						LET vMensaje = trim(vMensaje);
						RETURN scod_ret, s_califica, s_compromisos, vMensaje;
					end if;

				 end if;
			END FOREACH;


		-- Valida claves de observación con monto vencido >= 50 UDIs
		   LET vCuantos = 0;
		--Se eleccionan los estatus ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		   FOREACH
			  SELECT institucion,b.tl30,
					   round(CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl24,0) /* * c.factor*/ )/vTpCambioUdi
								  WHEN tl08 = 'US'                THEN ((nvl(b.tl24,0) * vTpCambioUs) /* * c.factor */) /vTpCambioUdi
								  WHEN tl08 = 'UD'                THEN   nvl(b.tl24,0) -- * c.factor
							 ELSE nvl(b.tl24,0) -- *-c.factor
							 END,2)
				INTO vInstitucion,vStatus,vMontoUdis
				FROM ss_circulo_status a, bdiburo:br_tl_bc b, bdisolic:ss_circulo_frecpag c
			   WHERE b.num_cliente  = o_numcte
				 AND a.status = b.tl30
				 AND a.rango_rechazo = "1"
		--         and b.tl04 not in (select tl04 FROM bdiburo:br_tl_bc where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				 and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				 AND NVL(tl26,'') <> ''
				 AND b.tl11=c.tipo
			   ORDER BY tl26 DESC
	
		--modificar datos de la tabla ss_circulo_status para que aparezcan las claves de observación

		--Se eleccionan las claves de observación ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		--RQM 09 234 Punto 5 Valida claves de observación con monto vencido >= 50 UDIs
		-- RQM 09 234 - 2 Se cambia a 100 UDIS ini
			  IF vStatus in ('FD','PS','SU') and vMontoUdis >= vMaxMtoUdi THEN
				  LET vCuantos = 1;
				  LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Observación ' || vStatus || ' con ' || vMontoUdis || ' UDIs ';
				  EXIT FOREACH;
			  END IF
		-- RQM 09 234 - 2 Se cambia a 100 UDIS fin
		   END FOREACH;

		   IF vCuantos > 0 THEN
			   LET s_califica = "1";
			   LET vMensaje = trim(vMensaje);
			   RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		   END IF

		-- Valida claves de observación con monto vencido >= 100 UDIs
		   LET vCuantos = 0;
		--Se eleccionan los estatus ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		-- RQM 09 234-2 eliminar claves de observacion ini

		-- RQM 09 234-2 eliminar claves de observacion ini

		-- Valida claves de exclusión
		   LET vCuantos = 0;
		--RQM 09 234 Punto 7 Valida claves de exclusión para Buró de CrÃ?Â©dito
		   FOREACH
				select institucion,sc01
				  into vInstitucion,v_sc01
				  from bdiburo:br_sc_bc
				 where numcte = o_numcte

				IF (v_sc01 is not null and v_sc01 != '') and EXISTS(SELECT * FROM bdiburo:br_scvsc WHERE codigo = v_sc01 AND status_cons = 1) THEN
					LET vCuantos = 1;
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Exclusión ' || v_sc01;
					EXIT FOREACH;
				END IF;
		   END FOREACH;


		   IF vCuantos > 0 THEN
			  LET s_califica = "1";
			   LET vMensaje = trim(vMensaje);
			  RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		   END IF;

			-- *************************************
			-- Determina Obligaciones del cliente  *
			-- *************************************	
			LET vCuantos = 0;
			LET cuenta = 0;
			FOREACH -- RQM 09 408
				SELECT tl08,tl12,b.factor
				INTO v_moneda,v_monto,v_factor		
					FROM bdiburo:br_tl a, bdisolic:ss_circulo_frecpag b
					WHERE a.tl11 = b.tipo
					AND a.tl02 NOT IN (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = a.institucion)
					AND num_cliente = o_numcte
				UNION ALL
				SELECT tl08,tl12,b.factor
					FROM bdiburo:br_tl a, bdisolic:ss_circulo_frecpag b
					WHERE a.tl11 = b.tipo
						AND a.tl06 = 'M' AND a.tl07 = 'RE'
						AND a.tl12 <> 0 AND a.tl02 = 'SERVICIOS'
						AND num_cliente = o_numcte
					
    			IF (v_moneda = 'N$' OR v_moneda = 'MX') THEN 
				   LET v_tot_tp = v_monto * v_factor; 
				   IF v_monto > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
				   ELSE LET v_monto = 0; END IF;
				END IF;
				IF v_moneda = 'UD' THEN  
				   LET v_tot_tp = vTpCambioUdi * (v_monto * v_factor);
				   IF v_monto > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
				   ELSE LET v_monto = 0; END IF;
				END IF;
				IF v_moneda = 'US' THEN
				   LET v_tot_tp = vTpCambioUs * (v_monto * v_factor);
				   IF v_monto > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
				   ELSE LET v_monto = 0; END IF;
				END IF;
				                				
				LET cuenta = cuenta + 1; 
				
			END FOREACH; 
            
				LET s_compromisos = v_total;
				LET vCuantos = cuenta;			
                
		--    AND tl02 not in  ('SIC','BANCOPPEL');
		--and a.tl04 not in (select tl04 FROM bdiburo:br_tl_bc where institucion = a.institucion and num_cliente = a.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV');

	ELSE --solicitud normal
		IF cTpSolicitud IN ('T','P') THEN
		-- Valida MOP actual y se calculan las UDIs descartando los tipos de negocio
			LET vCuantos = 0;
			FOREACH
				SELECT institucion, tl02, tl11,
					   nvl(tl26,''),
					   round(CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl24,0) /* * c.factor*/ )/vTpCambioUdi
								  WHEN tl08 = 'US'                THEN ((nvl(b.tl24,0) * vTpCambioUs) /* * c.factor*/ ) /vTpCambioUdi
								  WHEN tl08 = 'UD'                THEN   nvl(b.tl24,0) --* c.factor
							 ELSE nvl(b.tl24,0)  -- * c.factor
							 END,2),
						   tl16,tl17,fecha
				  INTO vInstitucion, vTl02, vTl11, vTl26, vMontoUdis,vTl16,vTl17,vfecha
				  FROM bdiburo:br_tl b, bdisolic:ss_circulo_frecpag c
				 WHERE b.num_cliente  = o_numcte
				   AND NVL(tl26,'') <> ''
				   AND b.tl11=c.tipo
				   and b.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				   and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				 ORDER BY tl26 DESC

		-- Se obtiene el tipo de negocio a excluir
		--       SELECT tipo_negocio INTO cTipoNegocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion	= vInstitucion and tipo_negocio = TRIM(vTl02);

		--RQM 09 234 Punto 1 Valida MOPs actual != 03 y exceptuando los tipos de negocio mencionados en requerimiento
			   IF EXISTS(SELECT 1 FROM bdiburo:br_tlmop WHERE codigo = vTl26 AND status_cons IN (1,3)) AND vMontoUdis >= vMaxMtoUdi THEN
					LET vCuantos = 1;
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP actual ' || vTl26 || ' con ' || vMontoUdis || ' UDIs ';
					EXIT FOREACH;
		--RQM 09 234 Punto 1 Valida MOPs actual = 03, saldo vencido >= 100 UDIs y exceptuando los tipos de negocio mencionados en requerimiento
		--       ELIF vTl26 = '03' AND vMontoUdis >= vMaxMtoUdi AND (cTipoNegocio IS NULL OR cTipoNegocio = '') THEN
		--            LET vCuantos = 1;
		--            LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP actual ' || vTl26 || ' con ' || vMontoUdis || ' UDIs ';
		--            EXIT FOREACH;
			   END IF

			END FOREACH;

			IF vCuantos > 0 THEN
				LET s_califica = "1";
				LET vMensaje = trim(vMensaje);
				RETURN scod_ret, s_califica, s_compromisos, vMensaje;
			END IF


		-- Valida MOP histórico de los últimos 12 y 30 meses
		   let vCuantos = 0;
		   let i = 0;
		   let var_i = 0;
			FOREACH
				SELECT institucion, tl02, tl17, tl27, tl28,
					   round(CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl36,0) /* * c.factor*/ )/vTpCambioUdi
								  WHEN tl08 = 'US'                THEN ((nvl(b.tl36,0) * vTpCambioUs) /* * c.factor */) /vTpCambioUdi
								  WHEN tl08 = 'UD'                THEN   nvl(b.tl36,0) -- * c.factor
							 ELSE nvl(b.tl24,0) -- * c.factor
							 END,2),
							case when year(mdy(month(b.fecha),'01',year(b.fecha))) <> case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end
								 then (year(mdy(month(b.fecha),'01',year(b.fecha))) - case when tl28 is null then year(mdy(month(tl17),'01',year(tl17)) - 1 units month) else year(mdy(month(tl28),'01',year(tl28))) end ) * 12
								else 0
							end +
							month(mdy(month(b.fecha),'01',year(b.fecha))) -  case when tl28 is null then month(mdy(month(tl17),'01',year(tl17)) - 1 units month) else  month(mdy(month(tl28),'01',year(tl28))) end meses_pos
				  INTO vInstitucion, vTl02, vTl17, vTl27, vTl28, vMontoUdis, vmeses_pos
				  FROM bdiburo:br_tl b, bdisolic:ss_circulo_frecpag c
				 WHERE b.num_cliente  = o_numcte
				   AND NVL(tl26,'') <> ''
				   AND b.tl11=c.tipo
				   and b.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				   and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				 ORDER BY tl17 DESC
		-- VALIDAR 6 MESES
				 let vmeses6 = '';
				 let vmeses12 = '';
				 let vmeses30 = '';

				 for var_i = 1 to case when vmeses_pos > 6 then 6 else vmeses_pos end
					let vmeses6 = vmeses6||'0';
				 end for;

				 let vmeses6 = replace(replace(replace(replace(vmeses6||substr(vTl27,1,6),'-','0'),'X','0'),'U','0'),' ','0');
				 for var_i = 1 to 6
					if (substr(vmeses6,var_i,1) >= 4 and vMontoUdis >= vMaxMtoUdi) then
						LET vCuantos = 1;
						exit for;
					end if;
				 end for;

				 if (vCuantos = 1) then
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || substr(vmeses6,var_i,1) || ' con ' || vMontoUdis || ' UDIs en los últimos 6 meses ';
					LET s_califica = "1";
					LET vMensaje = trim(vMensaje);
					RETURN scod_ret, s_califica, s_compromisos, vMensaje;
				 end if;

		-- VALIDAR 12 MESES
				 let vCuantos = 0;
				 let var_i = 0;

				 for var_i = 1 to case when vmeses_pos > 12 then 12 else vmeses_pos end
					let vmeses12 = vmeses12||'0';
				 end for;

				 let vmeses12 = replace(replace(replace(replace(vmeses12||substr(vTl27,1,12),'-','0'),'X','0'),'U','0'),' ','0');

				 let var_i = 0;

				 for var_i = 1 to 12
					if (substr(vmeses12,var_i,1) >= 4 and vMontoUdis >= vMaxMtoUdi) then
						if (substr(vmeses12,var_i,1) = 4) then
							LET vCuantos = 2;
						else
							LET vCuantos = 1;
						end if;
						exit for;
					end if;
				 end for;

				 if (vCuantos = 1) then
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || substr(vmeses12,var_i,1) || ' con ' || vMontoUdis || ' UDIs en los últimos 12 meses ';
					LET s_califica = "1";
					LET vMensaje = trim(vMensaje);
					RETURN scod_ret, s_califica, s_compromisos, vMensaje;
				 elif (vCuantos = 2) then
		-- VALIDA BUEN PAGO
					let i = var_i;
					let vCuantos = 0;
					execute procedure cal_buen_pago(o_numcte,'0') INTO scod_ret,vbuenpago;

					if (vbuenpago is not null) then
						let var_i = 0;
						let vacumpagos = 0;

						for var_i = 1 to length(trim(vbuenpago))
							if substr(trim(vbuenpago),var_i,1) = 'S' then
								let vacumpagos = vacumpagos + 1;
							elif substr(trim(vbuenpago),var_i,1) <> ' ' then
								exit for;
							end if;
							if  (vacumpagos >= 6) then
								exit for;
							end if;

						end for;
					end if;

					if (vacumpagos < 6) then
						LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || substr(vmeses12,i,1) || ' con ' || vMontoUdis || ' UDIs en los últimos 12 meses ';
						LET s_califica = "1";
						LET vMensaje = trim(vMensaje);
						RETURN scod_ret, s_califica, s_compromisos, vMensaje;
					end if;

				 end if;
		-- VALIDAR 30 MESES
				 let vCuantos = 0;
				 let i = 0;
				 let vmeses30 = '';

				 for var_i = 1 to case when vmeses_pos > 30 then 30 else vmeses_pos end
					let vmeses30 = vmeses30||'0';
				 end for;

				 let vmeses30 = replace(replace(replace(replace(vmeses30||substr(vTl27,1,24),'-','0'),'X','0'),'U','0'),' ','0');
				 for var_i = 1 to 30
					if (substr(vmeses30,var_i,1) >= 5 and vMontoUdis >= vMaxMtoUdi) then
						LET vCuantos = 2;
						exit for;
					end if;
				 end for;

				 if (vCuantos = 2) then
		-- VALIDA BUEN PAGO
					let vCuantos = 0;
					let i = var_i;

					execute procedure cal_buen_pago(o_numcte,'0') INTO scod_ret,vbuenpago;

					if (vbuenpago is not null) then
						let var_i = 0;
						let vacumpagos = 0;

						for var_i = 1 to length(trim(vbuenpago))
							if substr(trim(vbuenpago),var_i,1) = 'S' then
								let vacumpagos = vacumpagos + 1;
							elif substr(trim(vbuenpago),var_i,1) <> ' ' then
								exit for;
							end if;
							if  (vacumpagos >= 12) then
								exit for;
							end if;
						end for;
					end if;

					if (vacumpagos < 12) then
						LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || substr(vmeses30,i,1) || ' con ' || vMontoUdis || ' UDIs en los últimos 30 meses ';
						LET s_califica = "1";
						LET vMensaje = trim(vMensaje);
						RETURN scod_ret, s_califica, s_compromisos, vMensaje;
					end if;

				 end if;
			END FOREACH;


		-- Valida claves de observación con monto vencido >= 50 UDIs
		   LET vCuantos = 0;
		--Se eleccionan los estatus ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		   FOREACH
			  SELECT institucion,b.tl30,
					   round(CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (nvl(b.tl24,0) /* * c.factor*/ )/vTpCambioUdi
								  WHEN tl08 = 'US'                THEN ((nvl(b.tl24,0) * vTpCambioUs) /* * c.factor */) /vTpCambioUdi
								  WHEN tl08 = 'UD'                THEN   nvl(b.tl24,0) -- * c.factor
							 ELSE nvl(b.tl24,0) -- *-c.factor
							 END,2)
				INTO vInstitucion,vStatus,vMontoUdis
				FROM ss_circulo_status a, bdiburo:br_tl b, bdisolic:ss_circulo_frecpag c
			   WHERE b.num_cliente  = o_numcte
				 AND a.status = b.tl30
				 AND a.rango_rechazo IN ('1','3')
		--         and b.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = b.institucion and num_cliente = b.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV')
				 and b.tl02 not in (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = b.institucion)
				 AND NVL(tl26,'') <> ''
				 AND b.tl11=c.tipo
			   ORDER BY tl26 DESC
			   
		--modificar datos de la tabla ss_circulo_status para que aparezcan las claves de observación

		--Se eleccionan las claves de observación ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		--RQM 09 234 Punto 5 Valida claves de observación con monto vencido >= 50 UDIs
		-- RQM 09 234 - 2 Se cambia a 100 UDIS ini
			  --IF vStatus in ('FD','PS','SU') and vMontoUdis >= vMaxMtoUdi THEN
			  IF vStatus in ('FD','PS','SU','CV','PC','SG','SP','SR','UP','FR')and vMontoUdis >= vMaxMtoUdi THEN 
				  LET vCuantos = 1;
				  LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Observación ' || vStatus || ' con ' || vMontoUdis || ' UDIs ';
				  EXIT FOREACH;
			  END IF
		-- RQM 09 234 - 2 Se cambia a 100 UDIS fin
		   END FOREACH;

		   IF vCuantos > 0 THEN
			   LET s_califica = "1";
			   LET vMensaje = trim(vMensaje);
			   RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		   END IF

		-- Valida claves de observación con monto vencido >= 100 UDIs
		   LET vCuantos = 0;
		--Se eleccionan los estatus ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		-- RQM 09 234-2 eliminar claves de observacion ini

		-- RQM 09 234-2 eliminar claves de observacion ini

		-- Valida claves de exclusión
		   LET vCuantos = 0;
		--RQM 09 234 Punto 7 Valida claves de exclusión para Buró de CrÃ?Â©dito
		   FOREACH
				select institucion,sc01
				  into vInstitucion,v_sc01
				  from bdiburo:br_sc
				 where num_cliente = o_numcte

				IF (v_sc01 is not null and v_sc01 != '') and EXISTS(SELECT * FROM bdiburo:br_scvsc WHERE codigo = v_sc01 AND status_cons = 1) THEN
					LET vCuantos = 1;
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Exclusión ' || v_sc01;
					EXIT FOREACH;
				END IF;
		   END FOREACH;


		   IF vCuantos > 0 THEN
			  LET s_califica = "1";
			   LET vMensaje = trim(vMensaje);
			  RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		   END IF;

			-- *************************************
			-- Determina Obligaciones del cliente  *
			-- *************************************
		ELIF cTpSolicitud = 'C' THEN
		   LET vCuantos = 0;
		   LET vMensaje = "Creditos con Antecedentes en circulo de Credito:";
		   FOREACH
			   SELECT tl26
				 INTO vTl26
				 FROM bdiburo:br_tl b
				WHERE b.num_cliente  = o_numcte
				  AND NVL(tl26,'') <> ''

			   IF vTl26 IN ('96', '97', '99') THEN
				   LET vCuantos = vCuantos + 1;
				   LET vMensaje = TRIM(vMensaje)
					   || ' P:' || TRIM(vTl26);
			   END IF;
		   END FOREACH;

			IF vCuantos > 0 THEN
			   LET s_califica = "1";
			   RETURN scod_ret, s_califica, s_compromisos, vMensaje;
			END IF;

		END IF;

		LET vCuantos = 0;
		LET cuenta = 0;
		FOREACH -- RQM 09 408
			SELECT tl08,tl12,b.factor
			INTO v_moneda,v_monto,v_factor		
				FROM bdiburo:br_tl a, bdisolic:ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl02 NOT IN (SELECT tipo_negocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion = a.institucion)
				AND num_cliente = o_numcte
			UNION ALL
			SELECT tl08,tl12,b.factor
				FROM bdiburo:br_tl a, bdisolic:ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
					AND a.tl06 = 'M' AND a.tl07 = 'RE'
					AND a.tl12 <> 0 AND a.tl02 = 'SERVICIOS'
					AND num_cliente = o_numcte
				
			IF (v_moneda = 'N$' OR v_moneda = 'MX') THEN 
			   LET v_tot_tp = v_monto * v_factor; 
			   IF v_monto > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
			   ELSE LET v_monto = 0; END IF;
			END IF;
			IF v_moneda = 'UD' THEN  
			   LET v_tot_tp = vTpCambioUdi * (v_monto * v_factor);
			   IF v_monto > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
			   ELSE LET v_monto = 0; END IF;
			END IF;
			IF v_moneda = 'US' THEN
			   LET v_tot_tp = vTpCambioUs * (v_monto * v_factor);
			   IF v_monto > 0 THEN LET v_total = ROUND(NVL(v_total + v_tot_tp,0),2); 
			   ELSE LET v_monto = 0; END IF;
			END IF;
											
			LET cuenta = cuenta + 1; 
			
		END FOREACH; 
		
			LET s_compromisos = v_total;
			LET vCuantos = cuenta;		
		--    AND tl02 not in  ('SIC','BANCOPPEL');
		--and a.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = a.institucion and num_cliente = a.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV');

	END IF
	
	------------------------------------------------------------------------------------------------------------------ RQM 10 1404 CHI ->
	IF cTpSolicitud = 'H' THEN 
		-- Valida MOP actual y se calculan las UDIs descartando los tipos de negocio
		LET vCuantos = 0;
			
		FOREACH
			SELECT institucion, tl02, tl11, NVL(tl26, ''),
					ROUND(CASE 
							WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(b.tl24, 0)) / vTpCambioUdi
							WHEN tl08 = 'US'                THEN ((NVL(b.tl24, 0) * vTpCambioUs)) / vTpCambioUdi
							WHEN tl08 = 'UD'                THEN   NVL(b.tl24, 0) 
							ELSE NVL(b.tl24, 0)
						END, 2),
					tl16, tl17, fecha
			INTO vInstitucion, vTl02, vTl11, vTl26, vMontoUdis, vTl16, vTl17, vfecha
			FROM bdiburo:br_tl b, bdisolic:ss_circulo_frecpag c
			WHERE b.num_cliente  = o_numcte
				AND NVL(tl26,'') <> ''
				AND b.tl11 = c.tipo
				AND b.tl04 NOT IN (SELECT tl04 
									FROM bdiburo:br_tl 
									WHERE institucion = b.institucion 
										AND num_cliente = b.num_cliente 
										AND tl02='BANCOPPEL' 
										AND tl30 = 'RV')
				AND b.tl02 NOT IN (SELECT tipo_negocio
									FROM bdisolic:ss_cat_tiponegocio_sic 
									WHERE institucion = b.institucion)
			ORDER BY tl26 DESC
			--Malos Antecedentes MOPS Actuales: 03 Siempre y cuando cuente con un vencido >= 100 UDIS vencido en la cuenta, 
			IF EXISTS (SELECT 1 
						FROM bdiburo:br_tlmop 
						WHERE codigo = vTl26 
							AND status_cons = 3)
					AND vMontoUdis >= vMaxMtoUdi THEN
				LET vCuantos = 1;
				LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP actual ' || vTl26 || ' con ' || vMontoUdis || ' UDIs ';
				EXIT FOREACH;
			END IF	
			--Malos Antecedentes MOPS Actuales: 04, 05, 06, 07, 96, 97 y 99.
			IF EXISTS (SELECT 1 
						FROM bdiburo:br_tlmop 
						WHERE codigo = vTl26 
							AND status_cons = 1) THEN
				LET vCuantos = 1;
				LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP actual ' || vTl26;
				EXIT FOREACH;
			END IF			
		END FOREACH;

		IF vCuantos > 0 THEN
			LET s_califica = "1";
			LET vMensaje = TRIM(vMensaje);
			RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		END IF

		-- Valida MOP histórico de los últimos 12 y 30 meses
		LET vCuantos = 0;
		LET i = 0;
		LET var_i = 0;
		
		FOREACH
			SELECT institucion, tl02, tl17, tl27, tl28,
				ROUND(CASE 
						WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(b.tl36, 0)) / vTpCambioUdi
						WHEN tl08 = 'US'                THEN ((NVL(b.tl36, 0) * vTpCambioUs)) / vTpCambioUdi
						WHEN tl08 = 'UD'                THEN   NVL(b.tl36, 0)
						ELSE NVL(b.tl24, 0)
					END, 2),
					CASE WHEN YEAR(mdy(MONTH(b.fecha),'01',YEAR(b.fecha))) <> CASE WHEN tl28 IS NULL THEN YEAR(mdy(MONTH(tl17),'01',YEAR(tl17)) - 1 units MONTH) ELSE YEAR(mdy(MONTH(tl28),'01',YEAR(tl28))) END
						 THEN (YEAR(mdy(MONTH(b.fecha),'01',YEAR(b.fecha))) - CASE WHEN tl28 IS NULL THEN YEAR(mdy(MONTH(tl17),'01',YEAR(tl17)) - 1 units MONTH) ELSE YEAR(mdy(MONTH(tl28),'01',YEAR(tl28))) END ) * 12
						ELSE 0
					END +
					MONTH(mdy(MONTH(b.fecha),'01',YEAR(b.fecha))) -  CASE WHEN tl28 IS NULL THEN MONTH(mdy(MONTH(tl17),'01',YEAR(tl17)) - 1 units MONTH) ELSE  MONTH(mdy(MONTH(tl28),'01',YEAR(tl28))) END meses_pos
			INTO vInstitucion, vTl02, vTl17, vTl27, vTl28, vMontoUdis, vmeses_pos
			FROM bdiburo:br_tl b, bdisolic:ss_circulo_frecpag c
			WHERE b.num_cliente  = o_numcte
				AND NVL(tl26,'') <> ''
				AND b.tl11=c.tipo
				AND b.tl04 NOT IN (SELECT tl04 
									FROM bdiburo:br_tl 
									WHERE institucion = b.institucion 
										AND num_cliente = b.num_cliente 
										AND tl02='BANCOPPEL' 
										AND tl30 = 'RV')
				AND b.tl02 NOT IN (SELECT tipo_negocio 
									FROM bdisolic:ss_cat_tiponegocio_sic 
									WHERE institucion = b.institucion)
			ORDER BY tl17 DESC
		-- VALIDAR 6 MESES
			LET vmeses6 = '';
			LET vmeses12 = '';
			LET vmeses30 = '';

			FOR var_i = 1 TO CASE WHEN vmeses_pos > 6 THEN 6 ELSE vmeses_pos END
				LET vmeses6 = vmeses6||'0';
			END FOR;

			LET vmeses6 = REPLACE(REPLACE(REPLACE(REPLACE(vmeses6||SUBSTR(vTl27, 1, 6), '-', '0'), 'X', '0'), 'U', '0'), ' ', '0');
			
			FOR var_i = 1 TO 6
				IF (SUBSTR(vmeses6, var_i, 1) >= 4 AND vMontoUdis >= vMaxMtoUdi) THEN
					LET vCuantos = 1;
					EXIT FOR;
				END IF;
			END FOR;

			IF (vCuantos = 1) THEN
				LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || SUBSTR(vmeses6,var_i,1) || ' con ' || vMontoUdis || ' UDIs en los últimos 6 meses ';
				LET s_califica = "1";
				LET vMensaje = TRIM(vMensaje);
				RETURN scod_ret, s_califica, s_compromisos, vMensaje;
			END IF;

		-- VALIDAR 12 MESES
			LET vCuantos = 0;
			LET var_i = 0;

			FOR var_i = 1 TO CASE WHEN vmeses_pos > 12 THEN 12 ELSE vmeses_pos END
				LET vmeses12 = vmeses12||'0';
			END FOR;

			LET vmeses12 = REPLACE(REPLACE(REPLACE(REPLACE(vmeses12||SUBSTR(vTl27, 1, 12), '-', '0'), 'X', '0'), 'U', '0'), ' ', '0');

			LET var_i = 0;

			FOR var_i = 1 TO 12
				IF (SUBSTR(vmeses12, var_i, 1) >= 4 AND vMontoUdis >= vMaxMtoUdi) THEN
					IF (SUBSTR(vmeses12, var_i, 1) = 4) THEN
						LET vCuantos = 2;
					ELSE
						LET vCuantos = 1;
					END IF;
					EXIT FOR;
				END IF;
			END FOR;

			IF (vCuantos = 1) THEN
				LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || SUBSTR(vmeses12, var_i, 1) || ' con ' || vMontoUdis || ' UDIs en los últimos 12 meses ';
				LET s_califica = "1";
				LET vMensaje = TRIM(vMensaje);
				RETURN scod_ret, s_califica, s_compromisos, vMensaje;
			ELIF (vCuantos = 2) THEN
		-- VALIDA BUEN PAGO
				LET i = var_i;
				LET vCuantos = 0;
				
				EXECUTE PROCEDURE cal_buen_pago(o_numcte,'0') INTO scod_ret, vbuenpago;

				IF (vbuenpago IS NOT NULL) THEN
					LET var_i = 0;
					LET vacumpagos = 0;

					FOR var_i = 1 TO LENGTH(TRIM(vbuenpago))
						IF SUBSTR(TRIM(vbuenpago), var_i, 1) = 'S' THEN
							LET vacumpagos = vacumpagos + 1;
						ELIF SUBSTR(TRIM(vbuenpago), var_i, 1) <> ' ' THEN
							EXIT FOR;
						END IF;
						
						IF  (vacumpagos >= 6) THEN
							EXIT FOR;
						END IF;
					END FOR;
				END IF;

				IF (vacumpagos < 6) THEN
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || SUBSTR(vmeses12, i, 1) || ' con ' || vMontoUdis || ' UDIs en los últimos 12 meses ';
					LET s_califica = "1";
					LET vMensaje = TRIM(vMensaje);
					RETURN scod_ret, s_califica, s_compromisos, vMensaje;
				END IF;
			END IF;
		-- VALIDAR 30 MESES
			LET vCuantos = 0;
			LET i = 0;
			LET vmeses30 = '';

			FOR var_i = 1 TO CASE WHEN vmeses_pos > 30 THEN 30 ELSE vmeses_pos END
				LET vmeses30 = vmeses30||'0';
			END FOR;

			LET vmeses30 = REPLACE(REPLACE(REPLACE(REPLACE(vmeses30||SUBSTR(vTl27, 1, 24), '-', '0'), 'X', '0'), 'U', '0'), ' ', '0');
			FOR var_i = 1 TO 30
				IF (SUBSTR(vmeses30, var_i, 1) >= 5 AND vMontoUdis >= vMaxMtoUdi) THEN
					LET vCuantos = 2;
					EXIT FOR;
				END IF;
			END FOR;

			IF (vCuantos = 2) THEN
		-- VALIDA BUEN PAGO
				LET vCuantos = 0;
				LET i = var_i;

				EXECUTE PROCEDURE cal_buen_pago(o_numcte, '0') INTO scod_ret, vbuenpago;

				IF (vbuenpago IS NOT NULL) THEN
					LET var_i = 0;
					LET vacumpagos = 0;

					FOR var_i = 1 TO LENGTH(TRIM(vbuenpago))
						IF SUBSTR(TRIM(vbuenpago), var_i, 1) = 'S' THEN
							LET vacumpagos = vacumpagos + 1;
						ELIF SUBSTR(TRIM(vbuenpago), var_i, 1) <> ' ' THEN
							EXIT FOR;
						END IF;
						
						IF  (vacumpagos >= 12) THEN
							EXIT FOR;
						END IF;
					END FOR;
				END IF;

				IF (vacumpagos < 12) THEN
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP histórico ' || SUBSTR(vmeses30, i, 1) || ' con ' || vMontoUdis || ' UDIs en los últimos 30 meses ';
					LET s_califica = "1";
					LET vMensaje = TRIM(vMensaje);
					RETURN scod_ret, s_califica, s_compromisos, vMensaje;
				END IF;
			 END IF;
		END FOREACH;


		-- Valida claves de observación con monto vencido >= 50 UDIs
		LET vCuantos = 0;
		--Se eleccionan los estatus ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		FOREACH
			SELECT institucion, b.tl30,
				ROUND(CASE 
						WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(b.tl24, 0)) / vTpCambioUdi
						WHEN tl08 = 'US'                THEN ((NVL(b.tl24, 0) * vTpCambioUs)) / vTpCambioUdi
						WHEN tl08 = 'UD'                THEN   NVL(b.tl24, 0)
						ELSE NVL(b.tl24, 0)
					END,2)
			INTO vInstitucion, vStatus, vMontoUdis
			FROM ss_circulo_status a, bdiburo:br_tl b, bdisolic:ss_circulo_frecpag c
			WHERE b.num_cliente  = o_numcte
				AND a.status = b.tl30
				AND a.rango_rechazo IN ('1', '3')
				AND b.tl02 NOT IN (SELECT tipo_negocio 
									FROM bdisolic:ss_cat_tiponegocio_sic 
									WHERE institucion = b.institucion)
				AND NVL(tl26, '') <> ''
				AND b.tl11=c.tipo
		   ORDER BY tl26 DESC
			   
		--Se eleccionan las claves de observación ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
			IF vStatus IN ('FD','PS','SU','CV','PC','SG','SP','SR','UP','FR') AND vMontoUdis >= vMaxMtoUdi THEN 
				LET vCuantos = 1;
				LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Observación ' || vStatus || ' con ' || vMontoUdis || ' UDIs ';
				EXIT FOREACH;
			END IF
		END FOREACH;

		IF vCuantos > 0 THEN
			LET s_califica = "1";
			LET vMensaje = TRIM(vMensaje);
			RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		END IF

		-- Valida claves de observación con monto vencido >= 100 UDIs
		LET vCuantos = 0;
		--Se eleccionan los estatus ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		
		-- Valida claves de exclusión
		LET vCuantos = 0;
		
		FOREACH
			SELECT institucion, sc01
			INTO vInstitucion, v_sc01
			FROM bdiburo:br_sc
			WHERE num_cliente = o_numcte

			IF (v_sc01 IS NOT NULL AND v_sc01 != '') AND EXISTS(SELECT * FROM bdiburo:br_scvsc WHERE codigo = v_sc01 AND status_cons = 1) THEN
				LET vCuantos = 1;
				LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Exclusión ' || v_sc01;
				EXIT FOREACH;
			END IF;
		END FOREACH;


		IF vCuantos > 0 THEN
			LET s_califica = "1";
			LET vMensaje = TRIM(vMensaje);
			RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		END IF;

		LET vCuantos = 0;
		LET cuenta = 0;
		
		FOREACH
			SELECT tl08, tl12, b.factor
			INTO v_moneda, v_monto, v_factor		
				FROM bdiburo:br_tl a, bdisolic:ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
				AND a.tl02 NOT IN (SELECT tipo_negocio 
									FROM bdisolic:ss_cat_tiponegocio_sic 
									WHERE institucion = a.institucion)
				AND num_cliente = o_numcte
			UNION ALL
			SELECT tl08, tl12, b.factor
				FROM bdiburo:br_tl a, bdisolic:ss_circulo_frecpag b
				WHERE a.tl11 = b.tipo
					AND a.tl06 = 'M' AND a.tl07 = 'RE'
					AND a.tl12 <> 0 AND a.tl02 = 'SERVICIOS'
					AND num_cliente = o_numcte
				
			IF (v_moneda = 'N$' OR v_moneda = 'MX') THEN 
				LET v_tot_tp = v_monto * v_factor; 
				IF v_monto > 0 THEN 
					LET v_total = ROUND(NVL(v_total + v_tot_tp, 0), 2); 
				ELSE 
					LET v_monto = 0; 
				END IF;
			END IF;
			
			IF v_moneda = 'UD' THEN  
				LET v_tot_tp = vTpCambioUdi * (v_monto * v_factor);
				IF v_monto > 0 THEN 
					LET v_total = ROUND(NVL(v_total + v_tot_tp, 0), 2); 
				ELSE 
					LET v_monto = 0; 
				END IF;
			END IF;
			
			IF v_moneda = 'US' THEN
				LET v_tot_tp = vTpCambioUs * (v_monto * v_factor);
				IF v_monto > 0 THEN 
					LET v_total = ROUND(NVL(v_total + v_tot_tp, 0), 2); 
				ELSE 
					LET v_monto = 0; 
				END IF;
			END IF;
			
			LET cuenta = cuenta + 1; 			
		END FOREACH; 
		
		LET s_compromisos = v_total;
		LET vCuantos = cuenta;
	END IF;
	------------------------------------------------------------------------------------------------------------------ RQM 10 1404 CHI <-
	
   IF s_compromisos IS NULL THEN
      LET s_compromisos = 0;
   END IF
   IF vCuantos > 0 AND s_califica = "X" THEN
       LET s_califica = "0";
   END IF

   IF s_califica = "0" THEN
		LET vMensaje ="BUEN COMPORTAMIENTO " || trim(vDescripcion_status);
   ELIF s_califica = "X" THEN
		LET vMensaje ="COMPORTAMIENTO NULO EN SIC";
   ELIF s_califica = "9" THEN
       LET vMensaje = 'NUMERO DE SOLICITUD O TIPO DE SOLICITUD NO EXISTENTE';
   END IF
END
       LET scod_ret      = "000";
       RETURN scod_ret, s_califica, s_compromisos, vMensaje;
END PROCEDURE;