CREATE PROCEDURE "informix".cal_circulocredito_cjunk(o_empresa CHAR(3),
                                          o_numcte  CHAR(20),
                                          o_numsol  CHAR (20))

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
DEFINE vCuantos_motor      SMALLINT;

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
DEFINE cBRM_reing SMALLINT;	--MACM	
DEFINE iOneClick  SMALLINT;
DEFINE iCanal	CHAR(1);
DEFINE vCount		 SMALLINT; --MACM
DEFINE vRegistro	 SMALLINT; --MACM

--VARIABLES PARA MOTOR
DEFINE iMax_MOP_Hist_6m             VARCHAR(50);       --MÃÂ¡ÃÂ¸ÃÂ©mo_MOP histÃÂ³ÃÂ²ÃÂ©ÃÂ£o 6 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_6m         CHAR(2);       --Nombre de instituciÃÂ³ÃÂ®ÃÂ ÃÂ¤e cuenta con mayor MOP histÃÂ³ÃÂ²ÃÂ©ÃÂ£o 6 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP			CHAR(2);	   --MACM
DEFINE dMontoUDIS_MM_6m             DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP histÃÂ³ÃÂ²ÃÂ©ÃÂ£o 6 meses de cuentas con >=100 UDIS
DEFINE iMM_Histo_12m                VARCHAR(50);       --MÃÂ¡ÃÂ¸ÃÂ©mo_MOP histÃÂ³ÃÂ²ÃÂ©ÃÂ£o 12 meses de cuentas con >=100 UDIS
DEFINE cInstCta_MayorMOP_12m        CHAR(2);       --Nombre de instituciÃÂ³ÃÂ®ÃÂ ÃÂ¤e cuenta con mayor MOP histÃÂ³ÃÂ²ÃÂ©ÃÂ£o 12 meses de cuentas con >=100 UDIS
DEFINE dMontoUDIS_MM_12m            DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP histÃÂ³ÃÂ²ÃÂ©ÃÂ£o 12 meses de cuentas con >=100 UDIS
DEFINE iNumCtasMOP_4_12m            INTEGER;       --NÃÂÃÂºmero de cuentas MOP =4 ÃÂÃÂºltimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_12m            INTEGER;       --NÃÂÃÂºmero de cuentas MOP =5 ÃÂÃÂºltimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_12m       INTEGER;       --NÃÂÃÂºmero de cuentas MOP >5 ÃÂÃÂºltimos 12 meses, UDIS >=100 & Sin comunicaciones ni servicios
define var_j        smallint;
DEFINE iCtasMOP_4_30mCon1o2         INTEGER;       --NÃÂÃÂºmero de cuentas MOP =4 ÃÂÃÂºltimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃÂ¡ÃÂ ÃÂ£onsiderar los 12 meses mÃÂ¡ÃÂ³ÃÂ recientes con valores 1 0 2
DEFINE iCtasMOP_5_30mCon1o2         INTEGER;       --NÃÂÃÂºmero de cuentas MOP =4 ÃÂÃÂºltimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃÂ¡ÃÂ ÃÂ£onsiderar los 12 meses mÃÂ¡ÃÂ³ÃÂ recientes con valores 1 0 2
DEFINE iCtasMOP_mayor5_30mCon1o2    INTEGER;       --NÃÂÃÂºmero de cuentas MOP >5 ÃÂÃÂºltimos 30 meses, UDIS >=100, no considera telecomunicaciones ni servicios, deberÃÂ¡ÃÂ ÃÂ£onsiderar los 12 meses mÃÂ¡ÃÂ³ÃÂ recientes con valores 1 0 2
DEFINE iNumCtasMOP_4_30m            INTEGER;       --NÃÂÃÂºmero de cuentas MOP =4 ÃÂÃÂºltimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_5_30m            INTEGER;       --NÃÂÃÂºmero de cuentas MOP =5 ÃÂÃÂºltimos 30 meses, UDIS >=100 & Sin comunicaciones ni servicios
DEFINE iNumCtasMOP_mayor5_30m       INTEGER;       --NÃÂÃÂºmero de cuentas MOP >5 ÃÂÃÂºltimos 30 meses, UDIS >=100, sin comunicaciones ni servicios
DEFINE dMotoUDIS_MM_30m_Rech        DECIMAL(14,2); --Monto UDIS de cuenta con mayor MOP (maximo Mop histrico 30 meses..) de la cuenta que provoca el rechazo
DEFINE dMonto_UDIS_MayorMOP			DECIMAL(14,2);
DEFINE cInstCta_MM_30m_Rech         CHAR(2);       --Nombre de instituciÃÂ³ÃÂ®ÃÂ ÃÂ¤e cuenta con mayor MOP (maximo Mop histrico 30 meses..) de cuenta que provoca el rechazo
DEFINE iNumCtas_ClvOb               VARCHAR(50);       --NÃÂÃÂºmero de cuentas que tienen clave de observaciÃÂ³ÃÂ®ÃÂ ÃÂD,PS,SU,CV,PC,SG,SP,SR,UP,FR en BurÃÂ³ÃÂ¬ÃÂ ÃÂ®o considera comunicaciones y servicios
DEFINE dMontoUdis                   DECIMAL(14,2); --monto en UDIS de la observaciÃÂ³ÃÂ®ÃÂ ÃÂ­ÃÂ¡ÃÂ³ÃÂ reciente
DEFINE cInstitucion                 CHAR(2);       --nombre de la instituciÃÂ³ÃÂ®ÃÂ ÃÂ¤e la observaciÃÂ³ÃÂ®ÃÂ ÃÂ­ÃÂ¡ÃÂ³ÃÂ reciente
DEFINE cClvObser                    CHAR(2);       --clave de observaciÃÂ³ÃÂ®ÃÂ ÃÂ­ÃÂ¡ÃÂ³ÃÂ reciente (vStatus) 
DEFINE vClvExclusionMasReciente INTEGER;	-- Corresponde a la CALVE de exclusion mÃÂ¡ÃÂ³ÃÂ reciente
DEFINE cInstitucionClvExclusionMasReciente CHAR(2); -- Corresponde a la INSTITUCION de exclusion mÃÂ¡ÃÂ³ÃÂ reciente
DEFINE iMM_Histo_30m                VARCHAR(50);       --MÃÂ¡ÃÂ¸ÃÂ©mo_MOP histÃÂ³ÃÂ²ÃÂ©ÃÂ£o 30 meses de cuentas con >=100 UDIS (Se jerarquizan por fecha_reporte, " para mns de salida")
DEFINE vTl26_motor	CHAR(2); --MACM
DEFINE sFlagBuenPago12   VARCHAR(50);      --Corresponde al flag de buen pago 12meses
DEFINE sFlagBuenPago30   VARCHAR(50);      --Corresponde al flag de buen pago 30meses
DEFINE NumCuentaPagoMinimo 		INT8;
DEFINE icontador SMALLINT;
DEFINE cProducto 					CHAR(4);

DEFINE isBRM SMALLINT;

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
LET cBRM_reing   =0;	--MACM
LET iOneClick	= 0;
LET iCanal	= '';
LET vCount = 0;	--MACM
LET vRegistro = 0;	--MACM

LET iMax_MOP_Hist_6m          = "0";
LET cInstCta_MayorMOP_6m      ="";  
LET cInstCta_MayorMOP		  ="";     
LET dMontoUDIS_MM_6m          = 0;
LET iMM_Histo_12m             ="0";
LET cInstCta_MayorMOP_12m     ="";
LET dMontoUDIS_MM_12m         = 0;
LET iNumCtasMOP_4_12m         = 0;       
LET iNumCtasMOP_5_12m         = 0;       
LET iNumCtasMOP_mayor5_12m    = 0;
let var_j        = 0;
LET iCtasMOP_4_30mCon1o2      = 0;
LET iCtasMOP_5_30mCon1o2      = 0;
LET iCtasMOP_mayor5_30mCon1o2 = 0;
LET iNumCtasMOP_4_30m         = 0;       
LET iNumCtasMOP_5_30m         = 0;       
LET iNumCtasMOP_mayor5_30m    = 0;
LET dMotoUDIS_MM_30m_Rech        = 0;
LET dMonto_UDIS_MayorMOP		= 0;
LET cInstCta_MM_30m_Rech         ="";
LET cClvObser				  ="";
LET vClvExclusionMasReciente = 0;
LET cInstitucionClvExclusionMasReciente = "";
LET iMM_Histo_30m                ="0";
LET dMontoUdis                = 0;
LET cInstitucion              ="";
LET iNumCtas_ClvOb            ="0";
LET vTl26_motor = "";
LET vCuantos      =0;
LET vCuantos_motor      =0;
LET sFlagBuenPago12	  ="0";
LET sFlagBuenPago30	  ="0";
LET NumCuentaPagoMinimo = 0;
LET icontador  = 0;
LET cProducto = "";

LET isBRM = 0;

-- ****************************************************************************
-- *                        CONTROL DE CAMBIOS                                *
-- ****************************************************************************
----------------------------------------------------------------------------------------------------------------',
--DESCRIPCION: Se agregan variables que se necesitan para el motor de evaluacion de prestamos personales MACM', 
--AUTOR:Marco Antonio Cardenas Medina ',
--FECHA:15/08/2024',
--BD: BDISOLIC';
--------------------------------------------------------------------------------
-- Autor: Kevin Galvez Parra
-- Modificacion: Se agrega validacion de OneClick Prestamo Digital para enviar a BRM.

-- Fecha de Creacion: 19-09-2025
-- Proyecto: RQM 09 665- Capacidad de Pago - One Click
----------------------------------------------------------------------------------------------------------------',
--------------------------------------------------------------------------------
-- Autor: Luis Angel Garcia Gayosso
-- Modificacion: Se agrega variable isBRM y consulta para validacion de OneClick Prestamo Digital para enviar a BRM.

-- Fecha de Creacion: 30-01-2026
-- Proyecto: RQM 09 665- Capacidad de Pago - One Click
----------------------------------------------------------------------------------------------------------------',


  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
  
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
	-- RQI 21 246  OriginaciÃÂÃÂ³n de solicitudes 24 x 7
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;

	IF vFechaHoy < vfechaServ THEN
		LET vFechaHoy = vfechaServ;
	END IF;

--SET DEBUG FILE TO "/informix/Rebeca/cal_circulocredito_cjunk.out";
--TRACE ON;
	--SET debug file to '/informix/MarcoCardenas/PruebasMotor/PRUEBAS/cal_circulocredito_cjunk'||trim(o_numsol)||'.out';
	--TRACE ON;
	
	-- SET debug file to '/home/e10001925/CapacidadDePagoPP/LOGS/cal_circulocredito_cjunk_'||trim(o_numsol)||'.out';
	-- TRACE ON;
	
	-- SET debug file to '/home/e10001126/logsapp/cal_circulocredito_cjunk_'||trim(o_numsol)||'.out';
	-- TRACE ON;

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
	--MACM
	SELECT count(*) INTO cBRM_reing FROM bdisolic:"informix".ss_enviossolicitudesmotor_pp where num_solicitud = o_numsol AND status_consumo= '0';

	select b.descripcion,a.tipo_solicitud,a.status_solicitud, a.canal_sol, a.num_producto
        into   vDescripcion_status,cTpSolicitud,cStatus, iCanal, cProducto
	from bdisolic:"informix".ss_solicitudes a
	left outer join bdisolic:"informix".ss_status_sol b on (a.empresa = b.empresa and a.status_solicitud = b.status_solicitud)
	where a.empresa = o_empresa
	 and a.num_solicitud = o_numsol;
	
	select count(*) into isBRM from bdisolic:ss_certif_evaluacion_cte_pp where cSolBanco_ss = o_numsol;
	
	IF iCanal IN ('6','7') AND cProducto = "6800" AND isBRM > 0 THEN
		LET iOneClick = 1;
	END IF;

    IF cTpSolicitud IS NULL OR cTpSolicitud = '' THEN 
       LET scod_ret = '99999';
       LET cTpSolicitud = 'X'; 
       LET s_califica = '9';
	   RETURN scod_ret, s_califica, s_compromisos, vMensaje;
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


		-- Valida MOP historico de los ultimos 12 y 30 meses
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
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP historico ' || substr(vmeses6,var_i,1) || ' con ' || vMontoUdis || ' UDIs en los ultimos 6 meses ';
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
							LET sFlagBuenPago12 = vCuantos;
						else
							LET vCuantos = 1;
						end if;
						exit for;
					end if;
				 end for;

				 if (vCuantos = 1) then
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP historico ' || substr(vmeses12,var_i,1) || ' con ' || vMontoUdis || ' UDIs en los ultimos 12 meses ';
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
						LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP historico ' || substr(vmeses12,i,1) || ' con ' || vMontoUdis || ' UDIs en los ultimos 12 meses ';
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
						LET sFlagBuenPago30 = vCuantos;						
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
						LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP historico ' || substr(vmeses30,i,1) || ' con ' || vMontoUdis || ' UDIs en los ultimos 30 meses ';
						LET s_califica = "1";
						LET vMensaje = trim(vMensaje);
						RETURN scod_ret, s_califica, s_compromisos, vMensaje;
					end if;

				 end if;
			END FOREACH;


		-- Valida claves de observacion con monto vencido >= 50 UDIs
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
	
		--modificar datos de la tabla ss_circulo_status para que aparezcan las claves de observacion

		--Se eleccionan las claves de observacion ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		--RQM 09 234 Punto 5 Valida claves de observacion con monto vencido >= 50 UDIs
		-- RQM 09 234 - 2 Se cambia a 100 UDIS ini
			  IF vStatus in ('FD','PS','SU') and vMontoUdis >= vMaxMtoUdi THEN
				  LET vCuantos = 1;
				  LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Observacion ' || vStatus || ' con ' || vMontoUdis || ' UDIs ';
				  EXIT FOREACH;
			  END IF
		-- RQM 09 234 - 2 Se cambia a 100 UDIS fin
		   END FOREACH;

		   IF vCuantos > 0 THEN
			   LET s_califica = "1";
			   LET vMensaje = trim(vMensaje);
			   RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		   END IF

		-- Valida claves de observacion con monto vencido >= 100 UDIs
		   LET vCuantos = 0;
		--Se eleccionan los estatus ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		-- RQM 09 234-2 eliminar claves de observacion ini

		-- RQM 09 234-2 eliminar claves de observacion ini

		-- Valida claves de exclusion
		   LET vCuantos = 0;
		--RQM 09 234 Punto 7 Valida claves de exclusion para Buro de Credito
		   FOREACH
				select institucion,sc01
				  into vInstitucion,v_sc01
				  from bdiburo:br_sc_bc
				 where numcte = o_numcte

				IF (v_sc01 is not null and v_sc01 != '') and EXISTS(SELECT * FROM bdiburo:br_scvsc WHERE codigo = v_sc01 AND status_cons = 1) THEN
					LET vCuantos = 1;
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Exclusion ' || v_sc01;
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
			LET icontador  = 0;
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
				 ORDER BY tl26 DESC, 5 DESC

		-- Se obtiene el tipo de negocio a excluir
		--       SELECT tipo_negocio INTO cTipoNegocio FROM bdisolic:ss_cat_tiponegocio_sic WHERE institucion	= vInstitucion and tipo_negocio = TRIM(vTl02);
				-- Se guarda el valor del peor mop actual con el primer registro
				IF icontador = 0 THEN
					LET dMonto_UDIS_MayorMOP = vMontoUdis;
					LET vTl26_motor = case when vTl26='' then '00' else vTl26 end;	
					LET cInstCta_MayorMOP = NVL(vInstitucion,'');
					IF vTl26_motor <> 'UR' THEN
                        LET icontador  = 1;
                    END IF;
				END IF;	
				--Si aplica rechazo reemplazarÃÂ¡ÃÂ ÃÂ¥l valor del peor mop actual
		--RQM 09 234 Punto 1 Valida MOPs actual != 03 y exceptuando los tipos de negocio mencionados en requerimiento
			   IF EXISTS(SELECT 1 FROM bdiburo:br_tlmop WHERE codigo = vTl26 AND status_cons IN (1,3)) AND vMontoUdis >= vMaxMtoUdi THEN
					LET vCuantos = 1;
					LET vCuantos_motor = 1;
					LET vTl26_motor = case when vTl26='' then '00' else vTl26 end;
					LET dMonto_UDIS_MayorMOP = vMontoUdis;
					LET cInstCta_MayorMOP = NVL(vInstitucion,'');
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP actual ' || vTl26 || ' con ' || vMontoUdis || ' UDIs ';
					EXIT FOREACH;
		--RQM 09 234 Punto 1 Valida MOPs actual = 03, saldo vencido >= 100 UDIs y exceptuando los tipos de negocio mencionados en requerimiento
		--       ELIF vTl26 = '03' AND vMontoUdis >= vMaxMtoUdi AND (cTipoNegocio IS NULL OR cTipoNegocio = '') THEN
		--            LET vCuantos = 1;
		--            LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP actual ' || vTl26 || ' con ' || vMontoUdis || ' UDIs ';
		--            EXIT FOREACH;
			   END IF

			END FOREACH;

			IF vCuantos > 0 AND cBRM_reing = 0 AND iOneClick = 0 THEN
				LET s_califica = "1";
				LET vMensaje = trim(vMensaje);
				RETURN scod_ret, s_califica, s_compromisos, vMensaje;
			END IF


		-- Valida MOP historico de los ultimos 12 y 30 meses
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
						LET vCuantos_motor = 1;
						--MACM variables de motor
						LET iMax_MOP_Hist_6m = NVL(substr(vmeses6,var_i,1),0);
						LET cInstCta_MayorMOP_6m = NVL(vInstitucion,'');
						LET dMontoUDIS_MM_6m = NVL(vMontoUdis,0);						
						exit for;
					end if;
				 end for;

				 if (vCuantos = 1 AND cBRM_reing = 0 AND iOneClick = 0) then
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP historico ' || substr(vmeses6,var_i,1) || ' con ' || vMontoUdis || ' UDIs en los ultimos 6 meses ';
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
							LET vCuantos_motor = 2;
							LET iMM_Histo_12m = substr(vmeses12,var_i,1);		
						else
							LET dMontoUDIS_MM_12m = vMontoUdis;	
							LET vCuantos = 1;
							LET vCuantos_motor = 1;
						end if;
						LET cInstCta_MayorMOP_12m = vInstitucion;
						LET dMontoUDIS_MM_12m = vMontoUdis;	
						exit for;
					end if;
				 end for;		 

				 if (vCuantos = 1 AND cBRM_reing = 0 AND iOneClick = 0) then
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP historico ' || substr(vmeses12,var_i,1) || ' con ' || vMontoUdis || ' UDIs en los ultimos 12 meses ';
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

					if (vacumpagos < 6 AND cBRM_reing = 0 AND iOneClick = 0) then
						LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP historico ' || substr(vmeses12,i,1) || ' con ' || vMontoUdis || ' UDIs en los ultimos 12 meses ';
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
						LET vCuantos_motor = 2;
						LET iMM_Histo_30m = substr(vmeses30,var_i,1);
						LET dMotoUDIS_MM_30m_Rech = vMontoUdis;
						LET cInstCta_MM_30m_Rech = vInstitucion;
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
					If vacumpagos < 12 THEN
						LET vCuantos_motor = 1;
					End if;
					if (vacumpagos < 12 AND cBRM_reing = 0 AND iOneClick = 0) then
						LET vMensaje = 'Rechazo en ' || vInstitucion || ' por MOP historico ' || substr(vmeses30,i,1) || ' con ' || vMontoUdis || ' UDIs en los ultimos 30 meses ';
						LET s_califica = "1";
						LET vMensaje = trim(vMensaje);
						RETURN scod_ret, s_califica, s_compromisos, vMensaje;
					end if;

				 end if;
			END FOREACH;


		-- Valida claves de observacion con monto vencido >= 50 UDIs
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
			   
		--modificar datos de la tabla ss_circulo_status para que aparezcan las claves de observacion

		--Se eleccionan las claves de observacion ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		--RQM 09 234 Punto 5 Valida claves de observacion con monto vencido >= 50 UDIs
		-- RQM 09 234 - 2 Se cambia a 100 UDIS ini
			  --IF vStatus in ('FD','PS','SU') and vMontoUdis >= vMaxMtoUdi THEN
			  IF vStatus in ('FD','PS','SU','CV','PC','SG','SP','SR','UP','FR')and vMontoUdis >= vMaxMtoUdi THEN 
				  LET iNumCtas_ClvOb = iNumCtas_ClvOb + 1;
				  LET vCuantos = 1;
				  LET vCuantos_motor = 1;
				  LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Observacion ' || vStatus || ' con ' || vMontoUdis || ' UDIs ';
				  EXIT FOREACH;
			  END IF
		-- RQM 09 234 - 2 Se cambia a 100 UDIS fin
		   END FOREACH;

		   IF vCuantos > 0 AND cBRM_reing = 0 AND iOneClick = 0 THEN
			   LET s_califica = "1";
			   LET vMensaje = trim(vMensaje);
			   RETURN scod_ret, s_califica, s_compromisos, vMensaje;
		   END IF

		-- Valida claves de observacion con monto vencido >= 100 UDIs
		   LET vCuantos = 0;
		--Se eleccionan los estatus ('FD','PS','SU','CV','DS','LC','MD','SG','SP','SR','UP','VR','NV')
		-- RQM 09 234-2 eliminar claves de observacion ini

		-- RQM 09 234-2 eliminar claves de observacion ini

		-- Valida claves de exclusion

		--RQM 09 234 Punto 7 Valida claves de exclusion para Buro de Credito
		   FOREACH
				select institucion,sc01
				  into vInstitucion,v_sc01
				  from bdiburo:br_sc
				 where num_cliente = o_numcte

				IF (v_sc01 is not null and v_sc01 != '') and EXISTS(SELECT * FROM bdiburo:br_scvsc WHERE codigo = v_sc01 AND status_cons = 1) THEN
					LET vStatus = NVL(vStatus,''); 
					LET v_sc01 = NVL(v_sc01,''); 
					LET vCuantos = 1;
					LET vCuantos_motor = 1;
					LET vMensaje = 'Rechazo en ' || vInstitucion || ' por Clave de Exclusion ' || v_sc01;
					EXIT FOREACH;
				END IF;
		   END FOREACH;
			LET vMontoUdis = NVL(vMontoUdis,0);
			LET vInstitucion = NVL(vInstitucion,'');


		   IF vCuantos > 0 AND cBRM_reing = 0 AND iOneClick = 0 THEN
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
				   LET vCuantos_motor = vCuantos_motor + 1;
				   LET vMensaje = TRIM(vMensaje)
					   || ' P:' || TRIM(vTl26);
			   END IF;
		   END FOREACH;

			IF vCuantos > 0 AND cBRM_reing = 0 AND iOneClick = 0 THEN
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
			LET vCuantos_motor = cuenta;				
			LET NumCuentaPagoMinimo = cuenta;
		--    AND tl02 not in  ('SIC','BANCOPPEL');
		--and a.tl04 not in (select tl04 FROM bdiburo:br_tl where institucion = a.institucion and num_cliente = a.num_cliente AND tl02='BANCOPPEL' and tl30 = 'RV');

	END IF
	

	
   IF s_compromisos IS NULL THEN
      LET s_compromisos = 0;
   END IF
   IF (vCuantos > 0) AND s_califica = "X" THEN
       LET s_califica = "0";
   END IF

   IF s_califica = "0" THEN
		LET vMensaje ="BUEN COMPORTAMIENTO " || trim(vDescripcion_status);
   ELIF s_califica = "X" THEN
		LET vMensaje ="COMPORTAMIENTO NULO EN SIC";
   ELIF s_califica = "9" THEN
       LET vMensaje = 'NUMERO DE SOLICITUD O TIPO DE SOLICITUD NO EXISTENTE';
   END IF
   
   --MACM SE ACTUALIZAN LOS DATOS EN LA TABLA DE CERTIFICACION, PARA MANDAR A MOTOR DE EVALUACION
   IF cBRM_reing > 0 OR iOneClick > 0 THEN
		IF vCuantos_motor > 0 AND iOneClick = 0 THEN 
			LET s_califica = "1";		
		END IF;
		SELECT COUNT(*) INTO vCount
			FROM bdisolic:"informix".ss_certif_evaluacion_buro_pp 
			WHERE cSolBanco_ss = o_numsol 
			AND cNumCteBco_ss = o_numcte;
		IF vCount > 0 THEN
			UPDATE bdisolic:"informix".ss_certif_evaluacion_buro_pp
				SET iMax_MOP_ss = vTl26_motor,
					cInstCta_MayorMOP_ss = cInstCta_MayorMOP,
					dMonto_UDIS_MayorMOP_ss = dMonto_UDIS_MayorMOP,
					iMax_MOP_Hist_6m_ss = iMax_MOP_Hist_6m,
					cInstCta_MayorMOP_6m_ss = cInstCta_MayorMOP_6m,
					dMontoUDIS_MM_6m_ss = dMontoUDIS_MM_6m,
					dMotoUDIS_MM_30m_Rech_ss = dMotoUDIS_MM_30m_Rech,
					cInstCta_MM_30m_Rech_ss = cInstCta_MM_30m_Rech,
					iMM_Histo_12m_ss = iMM_Histo_12m,
					cInstCta_MayorMOP_12m_ss = cInstCta_MayorMOP_12m,
					dMontoUDIS_MM_12m_ss = dMontoUDIS_MM_12m,
					iMM_Histo_30m_ss = iMM_Histo_30m,
					iNumCtas_ClvOb_ss = iNumCtas_ClvOb,
					dMontoUdis_ss = vMontoUdis,
					cInstitucion_ss = vInstitucion,
					cClvObser_ss = vStatus,
					vClvExclusionMasReciente_ss = v_sc01,
					cInstitucionClvExclusionMasReciente_ss = vinstitucion,
					cRespSic_ss = s_califica,
					dCompromisosSic_ss = s_compromisos,
					vMensajeSic_ss = vMensaje,
					vmeses6_ss = vmeses6,
					vmeses12_ss = vmeses12,
					vmeses30_ss = vmeses30,
					sFlagBuenPago12_ss = sFlagBuenPago12,
					sFlagBuenPago30_ss = sFlagBuenPago30,
					NumCuentaPagoMinimo_ss = NumCuentaPagoMinimo,
					mPagoMinimo_ss = s_compromisos
					WHERE cSolBanco_ss = o_numsol 
					AND cNumCteBco_ss = o_numcte;
				
		END IF;
   END IF;   
   
END
       LET scod_ret      = "000";
       RETURN scod_ret, s_califica, s_compromisos, vMensaje;
END PROCEDURE;