CREATE PROCEDURE "informix".situacion_pago_tienda_cjunk_precal1_pru(o_empresa CHAR(3),
				o_num_cliente    CHAR(20),
				o_producto       CHAR(4),
				o_sucursal       CHAR(4),
				o_ejecutivo      CHAR(8),
				o_porcentaje     DECIMAL(5,2),
				o_situacion      CHAR(1),
				o_causa		 SMALLINT,
				o_num_referencia CHAR(20),
				o_nombre	 CHAR(104),
				o_nombre_coppel  CHAR(104),
				o_meses_hist     SMALLINT,
				o_vencidomuebles INTEGER,
				o_vencidoropa    INTEGER,
				o_vencidoprestamos INTEGER,
				o_abonomuebles	 INTEGER,
				o_abonoropa      INTEGER,
				o_abonoprestamos INTEGER,
				o_saldomuebles   INTEGER,
				o_saldoropa      INTEGER,
				o_saldoprestamos INTEGER,
                o_ultimacompra   DATE,
                pEjecucion		 CHAR(1))

RETURNING CHAR(5) 	as retorno,
		  --CHAR(200) as mensaje;
          --CHAR(250) as mensaje;
		   CHAR(300) as mensaje;
    -- CONTROL DE CAMBIOS:
--------------------------------------------------------------------------------
-- Fecha Modificacion:  08/09/2008
-- Autor: Paul Ivan Quintero Varela
-- Descripcion: Se modifica la validacion del vencido de los clientes coppel A- con
--                         eficiencia de pagos entre 75 y 84.9 en Coppel, RQM 09 078.
--------------------------------------------------------------------------------
-- Fecha de Modificacion: 08/01/2009
-- Modifico: Viridiana Osobampo 
-- Descripcion: Se agrego parametro de entrada (o_ultimacompra) para indicar la 
-- fecha de la ultima compra del cliente en tiendas coppel. Proyecto Caja Unica
--------------------------------------------------------------------------------
--ACTIVIDAD: Se modifica para que las consultas a la tabla ss_scoring_solic
-- lean los registros antes de caja unica, activa=0.
--FECHA: 23/02/2009
--AUTOR: Julio Cesar Polanco.
--------------------------------------------------------------------------------
-- Fecha de Modificacion: 07/01/2010
-- Modifico: Viridiana Osobampo 
-- Descripcion: Se unifican cambios realizados para el proyecto Alta Ãnica con
--              la versiÃ³n del spl productivo.
--------------------------------------------------------------------------------
-- Fecha de Modificacion: 23/06/2010
-- Modifico: Viridiana Osobampo 
-- Descripcion: Se modifican los mensajes cuando no se cumple con el
-- 		    rango de eficiencia y vencidos en coppel.
--------------------------------------------------------------------------------
-- Fecha de Modificacion: 09/12/2010
-- Modifico: JesÃºs Manuel Aguilar Heredia 
-- Descripcion: Se modifican los mensajes cuando no se cumple con el
-- 		    rango de eficiencia y vencidos en coppel.
-- Se modifica la longitud del parametro de salida del mensaje.
--------------------------------------------------------------------------------
-- Fecha de Modificacion: 17/12/2015
-- Modifico: Carolina Elizabeth Verdugo GastÃ©lum
-- Descripcion: Se agrega parÃ¡metro de entrada para validar sÃ­ es la primera o segunda 
-- ejecuciÃ³n del procedimiento para guardar en la tabla  ss_bitacora_precal.
--------------------------------------------------------------------------------
--****************************************************************************
--*                        DEFINICION DE VARIABLES
--****************************************************************************
DEFINE scod_ret             CHAR(5);
DEFINE vsqlerr              INTEGER;
DEFINE v_nroref             SMALLINT;
DEFINE v_paramref           SMALLINT;
DEFINE s_tipper             CHAR(2);
DEFINE v_motivo             CHAR(1);
DEFINE v_tpsol              CHAR(1);
DEFINE v_eva_min_inf        DECIMAL(5,2);
DEFINE v_eva_max_inf        DECIMAL(5,2);
DEFINE v_eva_min_sup        DECIMAL(5,2);
DEFINE v_eva_max_sup        DECIMAL(5,2);
DEFINE v_porcen             DECIMAL(6,2);
DEFINE v_situacion          CHAR(1);
DEFINE v_producto           CHAR(4);
DEFINE s_numsol             VARCHAR(20);
--DEFINE vMensaje             CHAR(200);
--DEFINE vMensaje             CHAR(250);
DEFINE vMensaje             CHAR(300);
DEFINE vTipoRech            CHAR(1);
DEFINE v_avanza             SMALLINT;
DEFINE iMedSalMin           DECIMAL(10,2);
DEFINE iUdi                 DECIMAL(10,2);
DEFINE iComparacion75       DECIMAL(10,2);
DEFINE iComparacion85       DECIMAL(10,2);
DEFINE Can_iUdi             DECIMAL(10,2);
DEFINE v_MesesHis           SMALLINT;
--  INI jom Parametro referencia coppel
DEFINE v_paso_cliente       CHAR(20);
DEFINE cCausaSol            CHAR(3);
--  FIN jom Parametro referencia coppel
--  INI jom valor de udis
DEFINE vFechaHoy            DATE;
DEFINE vMaxMtoUdi           DECIMAL(14,2);
DEFINE vValorUdi            DECIMAL(14,6);
DEFINE vCodUdi              CHAR(2);
DEFINE vClase               CHAR(1);
DEFINE vCodRet              CHAR(5);                

DEFINE cRFC					CHAR(13);
DEFINE cCodigoRet 			CHAR(6);
DEFINE cFechaUltimoPago 	CHAR(13); 
DEFINE cPrestamoAutorizado 	CHAR(1); 
DEFINE iMontoAutorizado 	INT8; 
DEFINE iReprestamo 			INT8;  

DEFINE iVencidoAire      	INTEGER;				---Autor: Jonathan Medina(INICIO) 	07/09/2021
DEFINE iAbonoAire         	INTEGER;
DEFINE iSaldoAire    		INTEGER;
DEFINE iVencidoAfiliados    INTEGER;
DEFINE iAbonoAfiliados      INTEGER;
DEFINE iSaldoAfiliados      INTEGER;
DEFINE iVencidoReestructura INTEGER;
DEFINE iAbonoReestructura   INTEGER;
DEFINE iSaldoReestructura   INTEGER;	
DEFINE iScorePuntualidad    INTEGER;		        

DEFINE cPuntualidadB       			CHAR(1);						
DEFINE cPuntualidad		   			CHAR(3);				
DEFINE iAbonoVencido	   			INTEGER;				
DEFINE iAbonoTotal	       			INTEGER;			        
DEFINE iTotalVencido	   			INTEGER;						
DEFINE iAbonoVencidototal  			DECIMAL(14,2);
DEFINE cPuntualidadCta     			CHAR(20);
DEFINE iSaldosVencidosPermitidos    INTEGER;
DEFINE cPuntualidadZ		  		CHAR(3); 		---Autor: Jonathan Medina(FINAL)	07/09/2021
--  FIN jom valor de udis
--****************************************************************************
--*                        ASIGNACION DE VARIABLES
--****************************************************************************

LET scod_ret        = "000";
LET vsqlerr         = 0;
LET v_nroref        = 0;
LET v_paramref      = 0;
LET s_tipper        = "??";
LET v_tpsol         = "?";
LET v_eva_min_inf   = 0;
LET v_eva_max_inf   = 0;
LET v_eva_min_sup   = 0;
LET v_eva_max_sup   = 0;
LET v_porcen        = 0;
LET v_situacion     = "?";
LET v_producto      = "????";
LET s_numsol        = "??????????";
LET vMensaje        = "Pre-Calificacion Aprobada";
LET v_avanza        = 0;
LET iMedSalMin      = 0;
LET iUdi            = 0;
LET iComparacion75  = 0;
LET iComparacion85  = 0;
LET Can_iUdi        =0;
--  INI jom Parametro referencia coppel
LET v_paso_cliente  = '';
--  FIN jom Parametro referencia coppel
--  INI jom valor de udis
let vFechaHoy       = null;
LET vMaxMtoUdi      = 0;
LET vValorUdi       = 0;
LET vCodRet          = "00000";
LET vCodUdi         ="";
LET vClase          ="";
--  FIN jom valor de udis
LET cCausaSol       = "";

LET cRFC =""; 
LET cCodigoRet ="";
LET cFechaUltimoPago =""; 
LET cPrestamoAutorizado =""; 
LET iMontoAutorizado ="";
LET iReprestamo ="";

LET iVencidoAire    	 		= 0;	---Autor: Jonathan Medina(INICIO) 	22/08/2021
LET iAbonoAire      	 		= 0;
LET iSaldoAire   		 		= 0;
LET iVencidoAfiliados    		= 0;
LET iAbonoAfiliados      		= 0;
LET iSaldoAfiliados      		= 0;
LET iVencidoReestructura 		= 0;
LET iAbonoReestructura   		= 0;
LET iSaldoReestructura   		= 0;
LET iScorePuntualidad  	 		= 0;
LET cPuntualidadB  		 		= "";
LET cPuntualidad 		 		= "";
LET	iAbonoVencido		 		= 0;
LET	iAbonoTotal			 		= 0;
LET iTotalVencido	    		= 0;
LET iAbonoVencidototal  		= 0;
LET cPuntualidadCta      		= "";
LET iSaldosVencidosPermitidos   = 0;
LET cPuntualidadZ 			  	= "";	---Autor: Jonathan Medina(FINAL)	22/08/2021

--****************************************************************************
--*                        CONTROL DE ERRORES
--****************************************************************************

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, vMensaje;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;
	--SET DEBUG FILE TO "/tmp/situacion_pago_tienda_cjunk_precal.out";
	--TRACE ON;

--****************************************************************************
--*                        PROGRAMA PRINCIPAL
--****************************************************************************

	-- ************************************
	-- Inicia Precalificacion del Cliente *
	-- ************************************
--obtiene la fecha del dÃ­a
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = o_empresa;

    SELECT valor 
      INTO vMaxMtoUdi
      FROM ss_param
     WHERE empresa = o_empresa
       AND secuencia = 309;

      -- *****************************************
      --  Extrae Clase y Tipo de Cmabio para UDI *
      -- *****************************************

    SELECT TRIM(valor) 
      INTO vCodUdi
      FROM bdinteg:"informix".si_param
     WHERE empresa = o_empresa
       AND cod_param = 16;

      SELECT TRIM(valor) INTO vClase
	    FROM bdicred:"informix".sd_param
       WHERE empresa = o_empresa
	     AND cod_param = "336";

    CALL bdinteg: "informix".valor_divisa_pesos(o_empresa, vFechaHoy, vCodUdi, vClase,'0') RETURNING vCodRet, vValorUdi;

    if (vCodRet <> "00000") THEN
        LET scod_ret = vCodRet;
        RETURN scod_ret, "No se econtro valor de UDI";
    end if;
--  ini jom Parametro referencia coppel

   SELECT valor INTO v_paso_cliente
   FROM ss_param
   WHERE empresa = o_empresa
   AND secuencia = 324;


   if trim(v_paso_cliente) = trim(o_num_referencia) then
        RETURN scod_ret, nvl(vMensaje,'');
   end if;

   SELECT motivo_rechazo_sol, tipo_rechazo,descripcion
   INTO v_motivo, vTipoRech, vMensaje
   FROM bdicred:"informix".sd_situacion_cred
   WHERE empresa = o_empresa
   AND situacion = o_situacion;

	-- *****************************
	-- Valida Situacion de credito *
	-- *****************************

   IF v_motivo IS NULL THEN
       LET v_motivo ="0";
   END IF

	LET cCausaSol = "SE";

	IF o_num_cliente <> "" THEN

		EXECUTE PROCEDURE bdisolic:"informix".sp_valida_cliente_coppel('2',o_num_cliente,'','','','','','','','','','','','','','','','','','','','','','')
		INTO cCodigoRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;
	
	ELSE
		LET cFechaUltimoPago = '1900-01-01';
		LET cPrestamoAutorizado = '0';
		LET iMontoAutorizado = '0';
		LET iRePrestamo = '0';
		LET cCodigoRet = '000000';
	END IF;
	
	-- Jonathan Medina  07/09/2021 Consulta ss_cliente_coppel_pp *
	-- *************************************
	SELECT vencidototalaire,abonomensualaire,saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,
	abonomensualreestructura,saldototalreestructura,scorepuntualidad,puntualidad
	INTO iVencidoAire,iAbonoAire,iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,
	iAbonoReestructura,iSaldoReestructura,iScorePuntualidad,cPuntualidad
	FROM bdisolic:"informix".ss_cliente_coppel_pp
	WHERE cliente_coppel = o_num_referencia;
	-- ************************************
	
   IF v_motivo = "1" THEN
       LET scod_ret = "001";

       IF pEjecucion = "0" THEN
         -- Inserta Bitacora
         INSERT INTO bdisolic:"informix".ss_bitacora_precal
		 (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
         causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos, saldomuebles, 
         saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos,fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
		  saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
         VALUES
         (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
         o_causa,v_motivo,vTipoRech,scod_ret,vMensaje,cCausaSol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
         o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,iVencidoAire,iAbonoAire,
		  iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);
         RETURN scod_ret, vMensaje;
     END IF
   END IF;
   
   IF pEjecucion ="0" THEN
       IF vTipoRech = "1" THEN
         LET scod_ret = "001";

         -- Inserta Bitacora
         INSERT INTO bdisolic:"informix".ss_bitacora_precal
		  (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
	      causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
          saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
		  saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
		  VALUES
          (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
          o_causa,v_motivo,vTipoRech,scod_ret,vMensaje,cCausaSol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
          o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,iVencidoAire,iAbonoAire,
		  iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);
         RETURN scod_ret, vMensaje;
   ELSE
         SELECT motivo_rechazo_sol, descripcion
         INTO v_motivo, vMensaje
         FROM bdicred:"informix".sd_causas_cte_coppel
         WHERE empresa = o_empresa
         AND situacion = o_situacion
         AND causa = o_causa;
         IF v_motivo = "1" THEN
             LET scod_ret = "001";

            -- Inserta Bitacora
			  INSERT INTO bdisolic:"informix".ss_bitacora_precal
			  (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
			  causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
			  saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
			  saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
			  VALUES
			  (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
			  o_causa,v_motivo,vTipoRech,scod_ret,vMensaje,cCausaSol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
			  o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,iVencidoAire,iAbonoAire,
			  iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);
             RETURN scod_ret, vMensaje;
           END IF
       END IF
   END IF;

	-- ***********************************************
	-- Extrae los rangos validos de calificacion
	-- ***********************************************
   SELECT tp_solicitud
   INTO v_tpsol
   FROM bdisolic:"informix".ss_solic_producto b
   WHERE b.empresa = o_empresa
   AND b.num_producto = o_producto;

   SELECT evaluacion_min, evaluacion_max INTO v_eva_min_inf, v_eva_max_inf
   FROM bdisolic:"informix".ss_scoring_solic
   WHERE empresa = o_empresa
   AND tp_solicitud = v_tpsol
   AND seccion = 1
   AND tpo_persona = "01"
   AND activa = '0'; -- Caja Unica. Viridiana


   SELECT evaluacion_min, evaluacion_max INTO v_eva_min_sup, v_eva_max_sup
   FROM bdisolic:"informix".ss_scoring_solic
   WHERE empresa = o_empresa
   AND tp_solicitud = v_tpsol
   AND seccion = 3
   AND tpo_persona = "01"
   AND activa = '0'; -- Caja Unica. Viridiana

	-- *******************************
	-- Valida Situacion de Pago
	-- *******************************
 
   /*IF o_porcentaje >= 0 THEN
       IF o_porcentaje  < v_eva_min_sup OR o_porcentaje  >  v_eva_max_sup THEN
           --LET vMensaje = "Rango de Eficiencia fuera de politica.";
           LET cCausaSol = "EFP";
           LET vMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
							'en la pantalla "SelecciÃ³n de Productos". Para tramitar una solicitud de '||
							'crÃ©dito BanCoppel es necesario realizar puntualmente sus pagos '||
							'mensuales en su Tienda Coppel.';
           LET scod_ret = "001";

           IF pEjecucion = "0" THEN
                -- Inserta Bitacora
               INSERT INTO bdisolic:"informix".ss_bitacora_precal
			   (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
			   causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
			   saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos,fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
			   saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
			   VALUES
			   (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
			   o_causa,v_motivo,vTipoRech,scod_ret,vMensaje,cCausaSol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
			   o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,iVencidoAire,iAbonoAire,
			   iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);
               RETURN scod_ret, vMensaje;
		   END IF;
       END IF
   END IF*/
   

        -- *************************************************************************************
	-- Obtiene parametro de comparacion clientes coppel A- (eficiencia 75 y 84.9)
	-- *************************************************************************************

   LET cCausaSol = "";
        -- Se toma el parametro para la comparacion clientes coppel entre 75 y 84.9.
   SELECT valor
   INTO iComparacion75
   FROM bdisolic:"informix".ss_param
   WHERE secuencia= '321';
   
   -- Se toma el parametor ABONOS VENCIDOS PERMITIDOS
   SELECT valor
   INTO iAbonoVencido
   FROM bdisolic:"informix".ss_param
   WHERE secuencia= 43;

   -- Se toma el parametro de PUNTUALIDAD PARA RECHAZAR CON ACC (ATRASO EN CUENTA COPPEL) Y ABONOS VENCIDOS EN CUENTAS
   SELECT valor
   INTO cPuntualidadB
   FROM bdisolic:"informix".ss_param
   WHERE secuencia= 44;
   
   -- Se toma el parametro PUNTUALIDAD PARA RECHAZAR CON ACC (ATRASO EN CUENTA COPPEL)
   SELECT valor
   INTO cPuntualidadCta
   FROM bdisolic:"informix".ss_param
   WHERE secuencia= 45;
   
   -- Se toma el parametro SALDOS VENCIDOS PERMITIDOS
   SELECT valor
   INTO iSaldosVencidosPermitidos
   FROM bdisolic:"informix".ss_param
   WHERE secuencia= 18;
   
   SELECT valor
   INTO cPuntualidadZ
   FROM bdisolic:"informix".ss_param
   WHERE secuencia= 46;
   
        -- Se valida que el parametro tenga informacion correspondiente a la comparaciones de clientes coppel.
   IF iComparacion75 IS NULL THEN
       LET iComparacion75= 0;
   END IF;
 
    -- ***********************************************
	-- Valida que haya algun vencido
	-- ***********************************************

   IF o_vencidomuebles > 0 OR o_vencidoropa > 0 OR o_vencidoprestamos > 0 THEN
       LET v_avanza = 1;
   END IF;

  -- IF ( v_avanza = 1 ) THEN
	LET iAbonoTotal = o_abonomuebles + o_abonoprestamos + o_abonoropa + iAbonoAire + iAbonoAfiliados + iAbonoReestructura;
	LET iTotalVencido = o_vencidomuebles + o_vencidoropa + o_vencidoprestamos + iVencidoAire + iVencidoAfiliados + iVencidoReestructura;
	
	IF NVL(iAbonoTotal,0) > 0 THEN
		LET iAbonoVencidototal = iTotalVencido/iAbonoTotal;
	END IF;
	
	IF cPuntualidad = cPuntualidadB THEN
	
	-- *****************************************************************
	-- Valida porcentaje de eficiencia entre 75 y 84.9 y su vencido
	-- *****************************************************************
		
		IF iAbonoVencidototal > iAbonoVencido THEN
	  --IF o_porcentaje >= v_eva_min_inf AND o_porcentaje < v_eva_min_sup THEN
			
           /*LET v_avanza = 0;
           IF NOT ( o_vencidomuebles <= o_abonomuebles/2 AND o_vencidomuebles <= iComparacion75 ) AND o_vencidomuebles > 0 THEN
               LET v_avanza = 1;
           END IF

           IF NOT ( o_vencidoropa <= o_abonoropa/2 AND o_vencidoropa <= iComparacion75 ) AND v_avanza = 0 AND o_vencidoropa > 0 THEN
               LET v_avanza = 1;
           END IF

           IF NOT ( o_vencidoprestamos <= o_abonoprestamos/2 AND o_vencidoprestamos <= iComparacion75 ) AND v_avanza = 0 AND o_vencidoprestamos > 0 THEN
               LET v_avanza = 1;
           END IF
		  
           IF ( v_avanza = 1 ) THEN */

               --LET vMensaje = "El Cliente presenta un atraso en su cuenta Coppel.";
			   LET cCausaSol = "ACC";	
               LET vMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
								'en la pantalla "SelecciÃ³n de Productos". Para tramitar una solicitud de '||
								'crÃ©dito BanCoppel es necesario tener sus pagos al corriente en su Tienda '||
								'Coppel. Lo invito a ser mÃ¡s puntual en sus pagos en su tienda Coppel.';
			   LET scod_ret = "001";

               IF pEjecucion = "0" THEN
                -- Inserta Bitacora
                  INSERT INTO bdisolic:"informix".ss_bitacora_precal
				  (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
				  causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
				  saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
				  saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
				  VALUES
				  (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
				  o_causa,v_motivo,vTipoRech,scod_ret,vMensaje,cCausaSol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
				  o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,iVencidoAire,iAbonoAire,
				  iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);
                 RETURN scod_ret, vMensaje;
			   END IF;
       END IF
   END IF
	
	-- *******************************************************************
	-- Valida porcentaje de eficiencia mayor igual 85 y su vencido
	-- *******************************************************************

   --IF o_porcentaje >= v_eva_min_sup THEN

	IF CHARINDEX(TRIM(cPuntualidad),TRIM(cPuntualidadCta)) > 0 THEN
		
		IF iTotalVencido > iSaldosVencidosPermitidos THEN

		  /* let iComparacion85 = vMaxMtoUdi * vValorUdi;

		   LET v_avanza = 0;

			IF NOT ( o_vencidomuebles <= o_abonomuebles/2 AND o_vencidomuebles <= iComparacion85 ) AND o_vencidomuebles > 0 THEN
				LET v_avanza = 1;
			END IF

			IF NOT ( o_vencidoropa <= o_abonoropa/2 AND o_vencidoropa <= iComparacion85 ) AND v_avanza = 0 AND o_vencidoropa > 0 THEN
				LET v_avanza = 1;
			END IF

			IF NOT ( o_vencidoprestamos <= o_abonoprestamos/2 AND o_vencidoprestamos <= iComparacion85 ) AND v_avanza = 0 AND o_vencidoprestamos > 0 THEN
				LET v_avanza = 1;
			END IF*/

			   --LET vMensaje = "El Cliente presenta un atraso en su cuenta Coppel.";
			   LET cCausaSol = "ACC";	
			   LET vMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
								'en la pantalla "SelecciÃ³n de Productos". Para tramitar una solicitud de '||
								'crÃ©dito BanCoppel es necesario tener sus pagos al corriente en su Tienda '||
								'Coppel. Lo invito a ser mÃ¡s puntual en sus pagos en su tienda Coppel.';
			   LET scod_ret = "001";

			   IF pEjecucion = "0" THEN
				-- Inserta Bitacora
				 INSERT INTO bdisolic:"informix".ss_bitacora_precal
				  (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
				  causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
				  saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
				  saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
				  VALUES
				  (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
				  o_causa,v_motivo,vTipoRech,scod_ret,vMensaje,cCausaSol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
				  o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,iVencidoAire,iAbonoAire,
				  iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);
				 RETURN scod_ret, vMensaje;
			   END IF;
		END IF
   END IF
   
   IF (TRIM(cPuntualidad) = TRIM(cPuntualidadZ)) THEN
		LET cCausaSol = "EFP";	
		LET vMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
						'en la pantalla "SelecciÃ³n de Productos". Para tramitar una solicitud de '||
						'crÃ©dito BanCoppel es necesario tener sus pagos al corriente en su Tienda '||
						'Coppel. Lo invito a ser mÃ¡s puntual en sus pagos en su tienda Coppel.';
		LET scod_ret = "001";

		IF pEjecucion = "0" THEN
			-- Inserta Bitacora
			INSERT INTO bdisolic:"informix".ss_bitacora_precal
			(empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
			causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
			saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
			saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
			VALUES
			(o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
			o_causa,v_motivo,vTipoRech,scod_ret,vMensaje,cCausaSol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
			o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,iVencidoAire,iAbonoAire,
			iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);
			RETURN scod_ret, vMensaje;
		END IF;
   END IF;
	   
	-- ****************************************************
	--       VERIFICA ANTIGUEDAD EN CLIENTES COPPEL       *
	-- ****************************************************
   
   SELECT valor INTO v_MesesHis
   FROM bdisolic:"informix".ss_param
   WHERE empresa = o_empresa
   AND secuencia = 327;

   IF (trim(v_paso_cliente) <> trim(o_num_referencia)) THEN

       IF NVL(o_meses_hist,0)<v_MesesHis THEN
       	   LET cCausaSol = "PAC";
           LET vMensaje = "Cliente con poca antigÃ¼edad en Coppel";
           LET scod_ret = "001";

           IF pEjecucion ="0" THEN
				-- Inserta Bitacora
				  INSERT INTO bdisolic:"informix".ss_bitacora_precal
				  (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
				  causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
				  saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
				  saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
				  VALUES
				  (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
				  o_causa,v_motivo,vTipoRech,scod_ret,vMensaje,cCausaSol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
				  o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,iVencidoAire,iAbonoAire,
				  iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);

             RETURN scod_ret, vMensaje;
		   END IF;
       END IF;

   END IF;
--  FIN jom Parametro referencia coppel
END
	RETURN scod_ret, nvl(vMensaje,'');

END PROCEDURE
