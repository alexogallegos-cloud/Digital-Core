CREATE PROCEDURE "informix".situacion_pago_banco_cjunk_prue(o_empresa CHAR(3),
                                                          o_num_cliente   CHAR(20),
                                                          o_producto      CHAR(4),
                                                          o_sucursal      CHAR(4),
                                                          o_ejecutivo     CHAR(8),
                                                          o_bandera       CHAR(1),
														  pEjecucion	  CHAR(1))

RETURNING CHAR(5),      -- Retorno
          CHAR(300),    -- Mensaje de retorno 
		  --CHAR(250),    -- Mensaje de retorno   
          CHAR(2),      -- Tipo persona
          CHAR(20),     -- NÃÂºmero de cte de la referencia 1
          CHAR(120),    -- Nombre de la referencia 1
          CHAR(20),     -- NÃÂºmero de cte de la referencia 2
          CHAR(120),    -- Nombre de la referencia 2
          CHAR(1),      -- Sexo
          CHAR(1),      -- Estado civil
          SMALLINT,     -- Edad
          CHAR(2),      -- Tipo de vivienda en la que habita el cte
          CHAR(3),      -- Puesto
          CHAR(1),      -- Tiene crÃÂ©ditos
          CHAR(3),      -- ProfesiÃÂ³n
          CHAR(13),     -- TelÃÂ©fono de la referencia 1
          CHAR(13),     -- TelÃÂ©fono de la referencia 2
          CHAR(2),      -- Parentesco con la referencia 1
          CHAR(2),      -- Parentesco con la referencia
          CHAR(20);     -- NÃÂºmero de referencia del cte

		  -- CONTROL DE CAMBIOS:
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃÂ³n: Se modifica para asignar valor al puesto en base a los nuevos 
--              catÃÂ¡logos definidos.
--PeticiÃÂ³n:	Alta Ã?nica
--Fecha de ModificaciÃÂ³n: 05-11-2009
--------------------------------------------------------------------------------
--Modificacion: Se modifica para que la consulta a la tabla ss_scoring_solic
-- solo busque los registros antes de alta ÃÂºnica
--Autor: Julio Cesar Polanco
--Fecha: 23/02/2009

--------------------------------------------------------------------------------
-- Autor: Viridiana Osobampo
-- Modificacion: Se valida si el cliente tiene saldo vencido en su credito
--               BanCoppel, de ser asÃ?ÃÂ­ no se permite al cliente realizar una
--               solicitud de crÃÂ©dito dejando registro en la bitÃÂ¡cora de
--               precalificaciÃÂ³n.
--Fecha de ModificaciÃÂ³n:  12-03-2009
-- Proyecto: Caja Unica
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃÂ³n: Se modifica para evaluar los crÃÂ©ditos que el cliente tiene en Bancoppel y 
--			  verificar si estos presentan saldo vencido, si se encuentra en cartera vendida, 
--			  si cuenta con alguna reestructura o un grado de riesgo y monto de reserva no permitidos.
--PeticiÃÂ³n:	RQM 10 108 PrÃÂ©stamo Personal
--Fecha de ModificaciÃÂ³n: 08-09-2009
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃÂ³n: Se modifica para que cuando el cliente no tiene el nÃÂºm. referencia 
--                como cliente coppel, en la bitÃÂ¡cora de precalificaciÃÂ³n se asigne
--                el numcte Bancoppel, el motivo serÃÂ¡ "B" y cambia la secuencia de 
--                parÃÂ¡metro para la consulta de saldo vencido en crÃÂ©ditos Bancoppel.
--PeticiÃÂ³n:	RQM 10 108 PrÃÂ©stamo Personal
--Fecha de ModificaciÃÂ³n: 25-09-2009
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃÂ³n: Se agrega un mensaje en los valores de retorno, de modo que se 
--              indique el resultado obtenido en la ejecuciÃÂ³n del spl.
--PeticiÃÂ³n:	RQM 10 108 PrÃÂ©stamo Personal
--Fecha de ModificaciÃÂ³n: 04-11-2009
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃÂ³n: Se modifica para eliminar validaciones directas al producto "6300"
--              para que el spl estÃÂ© parametrizado para todos los productos futuros.
-- PeticiÃÂ³n: RQM 10 108 PrÃÂ©stamo Personal
--Fecha de ModificaciÃÂ³n: 06-11-2009
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃÂ³n: Se unifican los cambios realizados para el proyecto Alta Ã?nica y
--              PrÃÂ©stamo Personal BanCoppel en la versiÃÂ³n del spl productivo.
-- PeticiÃÂ³n: RQM 10 108 PrÃÂ©stamo Personal
--Fecha de ModificaciÃÂ³n: 07-01-2010
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃÂ³n: Se optimiza consulta a la tabla bdicred:sd_hist_reserva.
-- PeticiÃÂ³n: RQM 10 108 PrÃÂ©stamo Personal
--Fecha de ModificaciÃÂ³n: 16-03-2010
--------------------------------------------------------------------------------
--Autor: Viridiana Osobampo
--ModificaciÃÂ³n: Se modifican los mensajes cuando existe motivo de rechazo por la 
--		     situaciÃÂ³n del crÃÂ©dito del cliente.
-- PeticiÃÂ³n: Alta Ã?nica paso 04
--Fecha de ModificaciÃÂ³n: 23-06-2010
--------------------------------------------------------------------------------
--Autor: JesÃÂºs Manuel Aguilar Heredia
--ModificaciÃÂ³n: Se modifican los mensajes cuando existe motivo de rechazo por la 
--		     situaciÃÂ³n del crÃÂ©dito del cliente., se modifica el tamaÃ?ÃÂ±o de retorno del mensaje
-- PeticiÃÂ³n: Alta Ã?nica paso 04.5
--Fecha de ModificaciÃÂ³n: 09-12-2010
--------------------------------------------------------------------------------
--Autor: JesÃÂºs Manuel Aguilar Heredia
--ModificaciÃÂ³n: Se modifica para que cuando un credito restructurado, ya este liquidado, no se envie mensaje de credito con reestructura
-- PeticiÃÂ³n: RQM 09 240 "Solicitud de crÃÂ©dito posterior a una liquidaciÃÂ³n de una reestructura".
--Fecha de ModificaciÃÂ³n: 26-07-2011
--------------------------------------------------------------------------------
--Autor: Diego Guerra Atienzo
--ModificaciÃÂ³n: Se modifica para que evite enviar error -1207 cuando el cliente tiene varios prestamos personales
-- PeticiÃÂ³n: CorrecciÃÂ³n de Incidencia Productiva.
--Fecha de ModificaciÃÂ³n: 31-07-2012
--------------------------------------------------------------------------------
--Autor: Carolina Verdugo 
--ModificaciÃÂ³n: llamado a procedimiento sp_cosnsulta_act_riesgo.sql para verificar si  el cliemte 
--              cuenta con inestabilidad en la vivienda o actividad de riesgo
-- PeticiÃÂ³n: Cambios para optimizar el preoceso de alta unica
--Fecha de ModificaciÃÂ³n: 22-10-2015
--------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret             CHAR(5);
DEFINE vsqlerr              INTEGER;
DEFINE sql_err              SMALLINT;
DEFINE isam_err             SMALLINT;
DEFINE error_info           CHAR(100);
DEFINE v_nroref             SMALLINT;
DEFINE v_paramref           SMALLINT;
DEFINE s_tipper             CHAR(2);
DEFINE v_motivo             CHAR(1);
DEFINE v_tpsol              CHAR(1);
DEFINE v_eva_min            DECIMAL(5,2);
DEFINE v_eva_max            DECIMAL(5,2);
DEFINE v_porcen             DECIMAL(6,2);
DEFINE v_situacion          CHAR(1);
DEFINE v_producto           CHAR(4);
DEFINE v_fecha_apert        DATE;
DEFINE s_referen1           CHAR(20);
DEFINE s_nomrefer1          CHAR(110);
DEFINE s_referen2           CHAR(20);
DEFINE s_nomrefer2          CHAR(110);
DEFINE s_numsol             CHAR(20);
DEFINE s_sexo               CHAR(1);
DEFINE s_edad               SMALLINT;
DEFINE s_edocivil           CHAR(1);
DEFINE v_meses              SMALLINT;
DEFINE s_habita_en          CHAR(2);
DEFINE s_puesto             CHAR(3);
DEFINE s_creditos           SMALLINT;
DEFINE s_profesion          CHAR(3);
DEFINE s_tel_ref_1          CHAR(13);
DEFINE s_tel_ref_2          CHAR(13);
DEFINE s_parentesco1        CHAR(2);
DEFINE s_parentesco2        CHAR(2);
DEFINE s_cteref             CHAR(20);

-- Ini Caja Unica. Viridiana
DEFINE cNomcte              CHAR (104);
DEFINE dtFecha               DATE;
DEFINE cNomcteCoppel        CHAR(104);
DEFINE sPorcentaje          DECIMAL (5,2);
DEFINE cSituacion           CHAR(1);
DEFINE sMesesHist           SMALLINT;
DEFINE sCausa               SMALLINT;
DEFINE cMotivo              CHAR(1);
DEFINE cTipoRechazo         CHAR(1);
--DEFINE cMensaje             CHAR(250);
DEFINE cMensaje             CHAR(300);
DEFINE iVencidoMuebles      INTEGER;
DEFINE iVencidoRopa         INTEGER;
DEFINE iVencidoPrestamos    INTEGER;
DEFINE iSaldoMuebles        INTEGER;
DEFINE iSaldoRopa           INTEGER;
DEFINE iSaldoPrestamos      INTEGER;
DEFINE iAbonoMuebles        INTEGER;
DEFINE iAbonoRopa           INTEGER;
DEFINE iAbonoPrestamos      INTEGER;
DEFINE iFechaUltimaCompra   DATE;
DEFINE cCredito             CHAR(20);
DEFINE sParamVencido        SMALLINT;
-- Fin Caja Unica. Viridiana
DEFINE cNumcred             CHAR(20);
DEFINE cGrado_riesgo        CHAR(2); 
DEFINE dMto_reserva         DECIMAL(18,2);
DEFINE cStatus_cred         CHAR(2);
DEFINE dtFecha_aux          DATE;
DEFINE cParamReserva        CHAR(100);
DEFINE crechazo             CHAR(1);
DEFINE sVencidoInteresrest  DECIMAL (18,2);  
DEFINE cParamGradoRiesgo    CHAR(2); 
DEFINE dSdo_vencido         DECIMAL(18,2);
DEFINE dSdo_vencidocrd      DECIMAL(18,2);
DEFINE cCodRet              CHAR(6);
DEFINE dtFechaAper          DATE;
DEFINE dtMaxFechaCorte      DATE;
DEFINE cCausaSol            CHAR(3);
DEFINE cNumcreditoRR        CHAR(20);
DEFINE vlCodigo		 		CHAR(5);
DEFINE vlGrupo				CHAR(1);
DEFINE vlCteLargo 			smallint;
DEFINE cRiesgoViviendaCpl   CHAR(1); ---Autor: Carolina Verdugo(INICIO)
DEFINE cRiesgoViviendaBcpl  CHAR(1);
DEFINE cActRiesgoCpl        CHAR(1);
DEFINE cActRiesgoBCpl		CHAR(1);
DEFINE cDescripcion			CHAR(60);
DEFINE cDescpRiesgo			CHAR(120);
DEFINE cAbogadoLit			CHAR(120);
DEFINE cPoliciaM			CHAR(120);

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
DEFINE iScorePuntualidad    INTEGER;		        ---Autor: Jonathan Medina(FINAL)	07/09/2021	

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET scod_ret            = "000";
LET vsqlerr             = 0;
LET v_nroref            = 0;
LET v_paramref          = 0;
LET s_tipper            = "??";
LET v_tpsol             = "?";
LET v_eva_min           = 0;
LET v_eva_max           = 0;
LET v_porcen            = 0;
LET v_situacion         = "?";
LET v_producto          = "????";
LET s_referen1          = "??????????";
LET s_referen2          = "??????????";
LET s_nomrefer1         = "??????????";
LET s_sexo              = "?";
LET s_edad              = 0;
LET s_edocivil          = "?";
LET s_nomrefer2         = "??????????";
LET s_numsol            = "??????????";
LET s_habita_en         = "??";
LET s_puesto            = "??";
LET v_meses             = 0;
LET s_creditos          = 0;
LET s_profesion         = "";
LET s_tel_ref_1         = " ";
LET s_tel_ref_2         = " ";
LET s_parentesco1       = " ";
LET s_parentesco2       = " ";
LET s_cteref            = " ";
-- Ini Caja Unica. Viridiana
LET cNomcte             = " ";
LET dtFecha              = DATE (1);
LET cNomcteCoppel       = " ";
LET sPorcentaje         = 0;
LET cSituacion          = " ";
LET sMesesHist          = 0;
LET sCausa              = 0;
LET cMotivo             = "B";
LET cTipoRechazo        = " ";
LET cMensaje            = "Proceso Exitoso";
LET iVencidoMuebles     = 0;
LET iVencidoRopa        = 0;
LET iVencidoPrestamos   = 0;
LET iSaldoMuebles       = 0;
LET iSaldoRopa          = 0;
LET iSaldoPrestamos     = 0;
LET iAbonoMuebles       = 0;
LET iAbonoRopa          = 0;
LET iAbonoPrestamos     = 0;
LET iFechaUltimaCompra  = " ";
LET cCredito            = " ";
LET sParamVencido       = 0;
-- Fin Caja Unica. Viridiana
LET cNumcred            = "";
LET cGrado_riesgo       = ""; 
LET dMto_reserva        = 0;
LET cStatus_cred        = "";
LET dtFecha_aux         = DATE(1);
LET cParamReserva       = "";
LET crechazo            = "";
LET cParamGradoRiesgo   = "";
LET dSdo_vencido        = 0;
LET dSdo_vencidocrd     = 0;
LET cCodRet             = "000000";
LET dtFechaAper         = DATE(1);
LET dtMaxFechaCorte     = DATE(1);
LET cCausaSol           = "";
LET cNumcreditoRR       = "";
LET vlCodigo		 	= "00000";
LET vlGrupo				= "";
LET	vlCteLargo			= 0;

LET sql_err             = 0 ; 
LET isam_err            = 0 ;
LET error_info 			= "";
LET cRiesgoViviendaCpl  =""; ---Autor: Marco Beltran(INICIO)
LET cRiesgoViviendaBcpl ="";
LET cActRiesgoCpl       ="";
LET cActRiesgoBCpl		="";
LET cDescripcion		="";
LET cDescpRiesgo		= "";
LET cAbogadoLit			= "Abogado Litigante";
LET cPoliciaM			="Servicios de Seguridad Publica (Municipal)";

LET cRFC =""; 
LET cCodigoRet ="";
LET cFechaUltimoPago =""; 
LET cPrestamoAutorizado =""; 
LET iMontoAutorizado ="";
LET iReprestamo ="";

LET iVencidoAire    	 = 0;	---Autor: Jonathan Medina(INICIO) 	22/08/2021
LET iAbonoAire      	 = 0;
LET iSaldoAire   		 = 0;
LET iVencidoAfiliados    = 0;
LET iAbonoAfiliados      = 0;
LET iSaldoAfiliados      = 0;
LET iVencidoReestructura = 0;
LET iAbonoReestructura   = 0;
LET iSaldoReestructura   = 0;	
LET iScorePuntualidad    = 0;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
	  IF sql_err != 0 THEN
      LET scod_ret = sql_err;
      RETURN scod_ret, cMensaje,s_tipper, s_referen1, s_nomrefer1,
             s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad, s_habita_en,
	         s_puesto, s_creditos, s_profesion, s_tel_ref_1, s_tel_ref_2,
             s_parentesco1, s_parentesco2, s_cteref;
   END IF;      
   END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/situacion_pago_banco_cjunk.out";
    --TRACE ON;	

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   -- Ini Caja Unica. Viridiana
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
   SELECT fecha_hoy 
     INTO dtFecha
     FROM bdicred:"informix".sd_fechas
    where empresa = o_empresa; -- jom faltaba empresa

   SELECT TRIM(TRIM((TRIM(nombre1)||" "|| TRIM(nombre2))||" "|| TRIM(apell_paterno)||" "|| TRIM(apell_materno))), 
          tpo_persona, NVL(numcte_ref, " ")
     INTO cNomcte,s_tipper, s_cteref
     FROM bdinteg:"informix".si_cliente
--    WHERE empresa= o_empresa -- tenia empresa de mas no es llave
     where numcte= o_num_cliente;
    -- Fin caja Unica. Viridiana

   IF NVL(s_cteref,'') = '' THEN
       LET s_cteref = o_num_cliente;
   END IF;
   
   --CALL bdisolic:"informix".sp_obtengrupocliente(o_num_cliente) RETURNING vlCodigo, vlGrupo;
   SELECT count(*) into vlCteLargo
	FROM bdisolic:"informix".ss_clienteslargos
	WHERE numcte = o_num_cliente
	  AND fecha_vig_ini<= dtFecha 
	  AND fecha_vig_fin >= dtFecha;
	  
   if nvl(vlCteLargo,0) > 0 then  LET vlGrupo = '8'; end if;
	-- *******************************************************
	-- Extrae el numero de referencias por tipo de solicitud *
	-- *******************************************************
   SELECT NVL(nro_referencias,0), a.tp_solicitud
     INTO v_paramref, v_tpsol
     FROM bdisolic:"informix".ss_tp_solicitud a, bdisolic:"informix".ss_solic_producto b
    WHERE b.empresa = o_empresa
      AND b.num_producto = o_producto
      AND a.tp_solicitud = b.tp_solicitud;

   IF v_paramref = 0 OR v_paramref IS NULL THEN
       LET scod_ret = "100";
       LET cMensaje= 'No existe parametro de referencia para la solicitud';
       RETURN scod_ret, cMensaje,s_tipper, s_referen1, s_nomrefer1,
           s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,
           s_habita_en, s_puesto, s_creditos,S_profesion, s_tel_ref_1, s_tel_ref_2,
           s_parentesco1, s_parentesco2, s_cteref;
   END IF

	-- ****************************
	-- Valida Referencia Personas *
	-- ****************************
   SELECT COUNT(num_solicitud)
     INTO v_nroref 
     FROM bdisolic:"informix".ss_refpersonales
    WHERE empresa = o_empresa
      AND numcte = o_num_cliente;

   IF v_nroref IS NULL THEN
       LET v_nroref = 0;
   END IF

	-- **************************
	-- Extrae Datos del Cliente *
	-- **************************
   SELECT a.sexo, a.estado_civil, a.habita_en,
         (SELECT YEAR(fecha_hoy) FROM bdinteg:"informix".si_fechas)-YEAR(a.fecha_nac), NVL(profesion, " ")
     INTO s_sexo, s_edocivil, s_habita_en, s_edad, s_profesion
     FROM bdinteg:"informix".si_ctepf a
    WHERE a.numcte = o_num_cliente;
	
   SELECT puesto 
     INTO s_puesto
     FROM bdinteg:"informix".si_ingresos
    WHERE empresa = o_empresa
      AND numcte = o_num_cliente
      AND sec_ingreso = 1
      AND tipo_ingreso = "T";

   IF s_puesto IS NULL THEN
       LET s_puesto = "09";
   END IF

   IF v_nroref < v_paramref AND o_bandera ="0" THEN
       LET scod_ret = "000";
       LET s_referen1 = " ";
       LET s_nomrefer1 =" ";
       LET s_referen2 = " ";
       LET s_nomrefer2 =" ";
       LET s_tel_ref_1 = " ";
       LET s_tel_ref_2 = " ";
--       LET cMensaje = 'El cliente no tiene el numero de referencias personales requeridas para la solicitud';
--       RETURN scod_ret, cMensaje,s_tipper, s_referen1, s_nomrefer1,
--           s_referen2, s_nomrefer2, s_sexo, s_edocivil, s_edad,
--           s_habita_en, s_puesto, s_creditos, s_profesion, s_tel_ref_1, s_tel_ref_2,
--           s_parentesco1, s_parentesco2, s_cteref;
   END IF


   -- *************************************
-- EM  25/05/2017 Consulta RFC *
-- *************************************

	SELECT RFC
		INTO cRFC
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = o_num_cliente;
		
	IF cRFC <> "" THEN

		EXECUTE PROCEDURE bdisolic:"informix".sp_valida_cliente_coppel('3','',cRFC,'','','','','','','','','','','','','','','','','','','','','')
		INTO cCodigoRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;
		
	ELSE
			LET cFechaUltimoPago = '1900-01-01';
			LET cPrestamoAutorizado = '0';
			LET iMontoAutorizado = '0';
			LET iRePrestamo = '0';
			LET cCodigoRet = '000000';
	END IF;   

	LET v_nroref = 0;

--   FOREACH 
-- Se modifica para realizar una sola conuslta conuslta y traer la referencia de la ultima solicitud
     SELECT limit 1 nvl(a.numcte_ref, " "), nvl(nombre_ref," "), nvl(telefono_ref, " "), nvl(parentesco, " ")
       INTO s_referen1, s_nomrefer1, s_tel_ref_1, s_parentesco1
       FROM bdisolic:"informix".ss_refpersonales a
      WHERE a.empresa = o_empresa
        AND a.numcte = o_num_cliente
        AND a.numcte_ref ='R1'
        AND NOT a.nombre_ref IS NULL
        and num_solicitud = 
			(SELECT max(num_solicitud)
			       FROM bdisolic:"informix".ss_refpersonales a
			      WHERE a.empresa = o_empresa
			        AND a.numcte = o_num_cliente
                    AND a.numcte_ref ='R1'
			        AND NOT a.nombre_ref IS NULL);


--       LET v_nroref = v_nroref + 1;
--
--       IF v_nroref = 1 THEN
--           LET s_referen1 = s_referen2;
--           LET s_nomrefer1 = s_nomrefer2;
--           LET s_tel_ref_1 = s_tel_ref_2;
--           LET s_parentesco1 = s_parentesco2;
--           LET s_referen2 = " ";
--           LET s_nomrefer2 = " ";
--           LET s_tel_ref_2 = " ";
--           LET s_parentesco2 = " ";
--       ELSE
--           EXIT FOREACH;
--       END IF
--   END FOREACH

-- 	*************************************
	-- Jonathan Medina  07/09/2021 Consulta ss_cliente_coppel_pp *
	-- *************************************
	SELECT vencidototalaire,abonomensualaire,saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,
	abonomensualreestructura,saldototalreestructura,scorepuntualidad
	INTO iVencidoAire,iAbonoAire,iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,
	iAbonoReestructura,iSaldoReestructura,iScorePuntualidad
	FROM bdisolic:"informix".ss_cliente_coppel_pp
	WHERE empresa = o_empresa
	AND cliente_coppel = s_cteref;
	--RFC = cRFC;
	-- ************************************

	-- Inicia Precalificacion del Cliente *
	-- ************************************

   SELECT porcentaje, situacion, fecha_apertura, num_producto
     INTO v_porcen, v_situacion, v_fecha_apert, v_producto
     FROM bdicred:"informix".sd_situacion_pago a, bdicred:"informix".sd_maecred b
    WHERE b.numcte = o_num_cliente
      AND b.empresa = o_empresa
      AND a.empresa = b.empresa
      AND a.num_credito = b.num_credito
      AND a.fecha = (SELECT MAX(fecha) 
                       FROM bdicred:"informix".sd_situacion_pago s
                      WHERE s.empresa = b.empresa
			            AND s.num_credito = b.num_credito
			            AND s.porcentaje=(SELECT MIN(porcentaje)
                                            FROM bdicred:"informix".sd_situacion_pago j
					                       WHERE j.empresa = b.empresa
					                         AND j.num_credito=b.num_credito));

    --ORDER BY fecha_apertura;

   IF v_situacion IS NULL THEN
       LET v_situacion = "O";
   END IF

   SELECT motivo_rechazo_sol 
     INTO v_motivo
     FROM bdicred:"informix".sd_situacion_cred
    WHERE empresa = o_empresa
      AND situacion = v_situacion;

	-- *****************************
	-- Valida Situacion de credito *
	-- *****************************
   IF pEjecucion = "0" THEN
       IF v_motivo = "1" THEN
         LET scod_ret = "001";
         LET cMensaje= 'El cliente presenta una situacion especial que es  motivo de rechazo en BanCoppel';
         LET cCausaSol = "MRB";

           INSERT INTO bdisolic:"informix".ss_bitacora_precal
           (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
           causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
           saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra, grupo,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
		   saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
		  VALUES
          (o_empresa, dtFecha, o_producto, o_sucursal, cNomcte, cNomcteCoppel, s_cteref, o_ejecutivo, sPorcentaje, cSituacion,    sMesesHist,
          sCausa,cMotivo,cTipoRechazo,scod_ret, cMensaje,cCausaSol,iVencidoMuebles,iVencidoRopa,iVencidoPrestamos,iSaldoMuebles,
          iSaldoRopa,iSaldoPrestamos,iAbonoMuebles,iAbonoRopa,iAbonoPrestamos,iFechaUltimaCompra, vlGrupo,cFechaUltimoPago,cPrestamoAutorizado,iMontoAutorizado,iRePrestamo,iVencidoAire,iAbonoAire,
		  iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);

         RETURN scod_ret, cMensaje, NVL(s_tipper,''), NVL(s_referen1,''), NVL(s_nomrefer1,''),
           NVL(s_referen2,''), NVL(s_nomrefer2,''), NVL(s_sexo,''), NVL(s_edocivil,''), NVL(s_edad,''),
           NVL(s_habita_en,''), NVL(s_puesto,''), NVL(s_creditos,''), NVL(s_profesion,''), NVL(s_tel_ref_1,''), NVL(s_tel_ref_2,''),
           NVL(s_parentesco1,''), NVL(s_parentesco2,''), NVL(s_cteref,'');
     END IF
	END IF; 
	-- *******************************************
	-- Extrae los rangos validos de calificacion *
	-- *******************************************
   SELECT evaluacion_min, evaluacion_max INTO v_eva_min, v_eva_max
     FROM bdisolic:"informix".ss_scoring_solic
    WHERE empresa = o_empresa
      AND tp_solicitud = v_tpsol
      AND seccion = 1
      AND tpo_persona = s_tipper
      AND activa = '0';
	-- *****************************
	-- Valida Situacion de Pago    *
	-- *****************************
    IF v_porcen IS NULL THEN
       LET v_porcen = v_eva_min;
    END IF
 
   IF v_porcen < v_eva_min OR v_porcen >  v_eva_max THEN
         LET scod_ret = "103";
         LET cMensaje= 'Rango de Eficiencia fuera de Politica';
         LET cCausaSol = "EFB";
		 
	   IF pEjecucion ="0" THEN

         INSERT INTO bdisolic:"informix".ss_bitacora_precal
           (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
           causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
           saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra, grupo,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
		   saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
		  VALUES
          (o_empresa, dtFecha, o_producto, o_sucursal, cNomcte, cNomcteCoppel, s_cteref, o_ejecutivo, sPorcentaje, cSituacion,    sMesesHist,
          sCausa,cMotivo,cTipoRechazo,scod_ret, cMensaje,cCausaSol,iVencidoMuebles,iVencidoRopa,iVencidoPrestamos,iSaldoMuebles,
          iSaldoRopa,iSaldoPrestamos,iAbonoMuebles,iAbonoRopa,iAbonoPrestamos,iFechaUltimaCompra, vlGrupo,cFechaUltimoPago,cPrestamoAutorizado,iMontoAutorizado,iRePrestamo,iVencidoAire,iAbonoAire,
		  iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);
		  
         RETURN scod_ret, cMensaje, NVL(s_tipper,''), NVL(s_referen1,''), NVL(s_nomrefer1,''),
         NVL(s_referen2,''), NVL(s_nomrefer2,''), NVL(s_sexo,''), NVL(s_edocivil,''), NVL(s_edad,''),
         NVL(s_habita_en,''), NVL(s_puesto,''), NVL(s_creditos,''), NVL(s_profesion,''), NVL(s_tel_ref_1,''), NVL(s_tel_ref_2,''),
         NVL(s_parentesco1,''), NVL(s_parentesco2,''), NVL(s_cteref,'');
       END IF
  END IF;

	-- *******************
	-- Meses de Historia *
	-- *******************
   SELECT (SELECT MONTH(fecha_hoy) FROM bdicred:"informix".sd_fechas) -
   MONTH(v_fecha_apert)
    INTO v_meses
    FROM bdicred:"informix".sd_fechas
   WHERE empresa = o_empresa;

   IF v_meses IS NULL THEN
       LET v_meses = 0;
   END IF

   IF o_bandera = "1" THEN
       LET s_referen1 = v_porcen;
       LET s_referen1 = 0;
       LET s_nomrefer1 = v_situacion;
       LET s_referen2  = v_meses;
     {  RETURN scod_ret, cMensaje, NVL(s_tipper,''), NVL(s_referen1,''), NVL(s_nomrefer1,''),
           NVL(s_referen2,''), NVL(s_nomrefer2,''), NVL(s_sexo,''), NVL(s_edocivil,''), NVL(s_edad,''),
           NVL(s_habita_en,''), NVL(s_puesto,''), NVL(s_creditos,''), NVL(s_profesion,''), NVL(s_tel_ref_1,''), NVL(s_tel_ref_2,''),
           NVL(s_parentesco1,''), NVL(s_parentesco2,''), NVL(s_cteref,'');  }
   END IF

	-- ******************************************************************************
	-- Consulta si el Cliente ya tiene Historial Crediticio con el Banco 		*
	-- ******************************************************************************
  -- Ini caja Unica. Viridiana
   SELECT valor
     INTO sParamVencido
     FROM bdisolic:"informix".ss_param
    WHERE empresa = o_empresa
      AND secuencia= 350;

   SELECT valor
     INTO cParamGradoRiesgo
     FROM bdisolic:"informix".ss_param
    WHERE empresa = o_empresa
      AND secuencia = 351;

   SELECT valor
     INTO cParamReserva
     FROM bdisolic:"informix".ss_param
    WHERE empresa = o_empresa
      AND secuencia = 352;

   IF sParamVencido IS NULL THEN
       LET scod_ret= '102';
       LET cMensaje = 'No Existe parÃÂ¡metro para evaluar el monto vencido del crÃÂ©dito';
       LET cCausaSol = "SPV";
       LET crechazo = '1';  
   END IF;
       
   IF (cParamReserva IS NULL) OR (cParamGradoRiesgo IS NULL) THEN
       LET scod_ret= '105';
       LET cMensaje = 'No Existe parÃÂ¡metro para evaluar el grado de riesgo del crÃÂ©dito';
       LET cCausaSol = "SPG";
       LET crechazo = '1'; 
   END IF;

   IF crechazo <> 1 THEN
       FOREACH
            SELECT num_credito, status_cred,fecha_apertura,credito_externo
              INTO cNumcred, cStatus_cred, dtFechaAper,cNumcreditoRR
              FROM bdicred:"informix".sd_maecred
             WHERE empresa = o_empresa
               AND numcte = o_num_cliente
               AND status_cred NOT IN ("CC","FF")               

               SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
                 INTO dSdo_vencido
                FROM bdicred:"informix".sd_maesdos
                WHERE empresa = o_empresa
                  AND num_credito = cNumcred;

               IF (NVL(dSdo_vencido,0) >= sParamVencido) THEN
                   LET scod_ret= '002';
                   --LET cMensaje = 'El cliente tiene crÃÂ©dito vencido en Bancoppel';
                   LET cMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
								   'en la pantalla "SelecciÃÂ³n de Productos". El sistema me indica que tiene '||
								   'vencido en su crÃÂ©dito BanCoppel, le recuerdo que es importante ser '||
								   'puntual en sus pagos para conservar los beneficios de su crÃÂ©dito.' ;
                   LET cCausaSol = "CVB";
                   LET crechazo = '1';
                   EXIT FOREACH;
               ELIF TRIM(cStatus_cred) = "CV" THEN
                   LET scod_ret= '003';
                   --LET cMensaje = 'El cliente tiene crÃÂ©dito vendido en Bancoppel';
                   LET cMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
								   'en la pantalla "SelecciÃÂ³n de Productos". No se le puede ofrecer una '||
								   'solicitud de crÃÂ©dito porque cuenta con un crÃÂ©dito vendido en '||
                                   'BanCoppel.';
                   LET cCausaSol = "COB";
                   LET crechazo = '1';
                   EXIT FOREACH;
               ELIF TRIM(cStatus_cred) = "FC" THEN			   
					IF NOT EXISTS (SELECT num_credito 
									FROM bdicred:"informix".sd_maecredcrd 
									WHERE empresa = o_empresa
									AND numcte = o_num_cliente
									AND num_credito = cNumcreditoRR
									AND status_cred ="FF") THEN  --se agrega validacion para que cuando el credito de reestructura, este liquidado no se envie el mensaje
						LET scod_ret= '004';
						--LET cMensaje = 'El cliente cuenta con crÃÂ©dito Reestructurado en Bancoppel';
						LET cMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
										'en la pantalla "SelecciÃÂ³n de Productos". No se le puede ofrecer una '||
										'solicitud de crÃÂ©dito porque cuenta con un crÃÂ©dito reestructurado.';
						LET cCausaSol = "CRB";
						LET crechazo = '1';
						EXIT FOREACH;   
					END IF;		   
                  
               -- IFRSELIF TRIM(cStatus_cred) = 'AA' THEN
			   ELIF (TRIM(cStatus_cred) in ('AA','E1') and dSdo_vencido = 0) THEN
                CALL bdicred:"informix".monthadd(dtFecha,-1) RETURNING dtMaxFechaCorte;
                LET dtMaxFechaCorte=mdy(month(dtMaxFechaCorte),'20',year(dtMaxFechaCorte));

                     IF dtFechaAper <= dtMaxFechaCorte THEN            
                       SELECT grado_riesgo_edo_resultados, reserva_edo_resultados
                         INTO cGrado_riesgo, dMto_reserva
                         FROM bdicred:"informix".sd_hist_reserva
                        WHERE empresa = o_empresa
                          AND num_credito = cNumcred
                          AND fecha_corte = dtMaxFechaCorte; 
                      END IF;
                   IF cGrado_riesgo IS NULL THEN
                       LET cGrado_riesgo = "";
                   END IF;

                   IF dMto_reserva IS NULL THEN
                       LET dMto_reserva = 0;
                   END IF;

                   IF (cGrado_riesgo IN ('D','E')) OR (cGrado_riesgo = cParamGradoRiesgo AND dMto_reserva > cParamReserva) THEN
                       LET scod_ret= '005';
                       --LET cMensaje = 'El cliente presenta una mala eficiencia en el Banco';
                       LET cMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
										'en la pantalla "SelecciÃÂ³n de Productos". Le recuerdo que es importante '||
										'realizar puntualmente sus pagos mensuales de su crÃÂ©dito BanCoppel.';
                       LET cCausaSol = "MEB";
                       LET crechazo = '1';
                       EXIT FOREACH;
                   END IF;
               END IF;
       END FOREACH
   END IF;

    LET s_creditos = DBINFO("sqlca.sqlerrd2");
	--Se modifica para evitar error -1207 
	IF 	s_creditos > 1 THEN
		LET s_creditos = 1; 
	END IF;	
    LET cNumcred = "";
    LET cStatus_cred = "";

    IF crechazo <> '1' THEN    

       FOREACH 
           SELECT num_credito, status_cred, num_producto, fecha_apertura
             INTO cNumcred, cStatus_cred, v_producto, dtFechaAper
             FROM bdicred:"informix".sd_maecredcrd
            WHERE empresa = o_empresa
              AND numcte = o_num_cliente
              AND status_cred <> "FF"

           IF v_producto <> '6011' THEN
               SELECT NVL(SUM(NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)),0)
                 INTO dSdo_vencidocrd
                 FROM bdicred:"informix".sd_maesdoscrd
                WHERE empresa = o_empresa
                  AND num_credito = cNumcred;

               IF (NVL(dSdo_vencidocrd,0) >= sParamVencido) THEN
                   LET scod_ret= '002';
                   --LET cMensaje = 'El cliente tiene crÃÂ©dito vencido en Bancoppel';
                  LET cMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
								   'en la pantalla "SelecciÃÂ³n de Productos". El sistema me indica que tiene '||
								   'vencido en su crÃÂ©dito BanCoppel, le recuerdo que es importante ser '||
								   'puntual en sus pagos para conservar los beneficios de su crÃÂ©dito.' ;
                   LET cCausaSol = "CVB";
                   LET crechazo = '1';
                    EXIT FOREACH;
               ELIF TRIM(cStatus_cred) = "CV" THEN
                   LET scod_ret= '003';
                   --LET cMensaje = 'El cliente tiene crÃÂ©dito vendido en Bancoppel';
                  LET cMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
								   'en la pantalla "SelecciÃÂ³n de Productos". No se le puede ofrecer una '||
								   'solicitud de crÃÂ©dito porque cuenta con un crÃÂ©dito vendido en '||
                                   'BanCoppel.';
                   LET cCausaSol = "COB";
                   LET crechazo = '1';
                   EXIT FOREACH;
               -- IFRS ELIF TRIM(cStatus_cred) = 'AA' THEN
			   ELIF (TRIM(cStatus_cred) in ('AA','E1') and dSdo_vencidocrd = 0) THEN																		   

                CALL bdicred:"informix".monthadd(dtFecha,-1) RETURNING dtMaxFechaCorte;
                LET dtMaxFechaCorte=mdy(month(dtMaxFechaCorte),'20',year(dtMaxFechaCorte));

                     IF dtFechaAper <= dtMaxFechaCorte THEN            
                       SELECT grado_riesgo_edo_resultados, reserva_edo_resultados
                         INTO cGrado_riesgo, dMto_reserva
                         FROM bdicred:"informix".sd_hist_reserva
                        WHERE empresa = o_empresa
                          AND num_credito = cNumcred
                          AND fecha_corte = dtMaxFechaCorte; 
                      END IF;

                   IF cGrado_riesgo IS NULL THEN
                       LET cGrado_riesgo = "";
                   END IF;

                   IF dMto_reserva IS NULL THEN
                       LET dMto_reserva = 0;
                   END IF;

                   IF (cGrado_riesgo IN ('D','E')) OR (cGrado_riesgo = cParamGradoRiesgo AND dMto_reserva > cParamReserva) THEN
                       LET scod_ret= '005';
                       --LET cMensaje = 'El cliente presenta una mala eficiencia en el Banco';
                       LET cMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
										'en la pantalla "SelecciÃÂ³n de Productos". Le recuerdo que es importante '||
										'realizar puntualmente sus pagos mensuales de su crÃÂ©dito BanCoppel.';
                       LET cCausaSol = "MEB";
                       LET crechazo = '1';
                       EXIT FOREACH;
                   END IF;
             END IF;

           ELSE
			 IF TRIM(cStatus_cred) <> "FF" THEN --se agrega validacion para que cuando el credito de reestructura, este liquidado no se envie el mensaje
				  LET scod_ret= '004';
	               --LET cMensaje = 'El cliente cuenta con crÃÂ©dito reestructurado en Bancoppel';
	              LET cMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) '||
									'en la pantalla "SelecciÃÂ³n de Productos". No se le puede ofrecer una '||
									'solicitud de crÃÂ©dito porque cuenta con un crÃÂ©dito reestructurado.';
	               LET cCausaSol = "CRB";
	               LET crechazo = '1';
	               EXIT FOREACH;      
			 END IF;                   
           END IF;           

       END FOREACH
	   
	   -- Valida que el cliente no tenga un prestamo flexible (digital) aun vigente (liquidado (FF) pero con vigencia)
		IF o_producto = '6800' THEN
			LET vlCteLargo = 0;
			SELECT count(a.num_credito) INTO vlCteLargo FROM bdicred:"informix".sd_maecredcrd a JOIN bdicred:"informix".sd_linea_prestamo b ON (a.num_credito = b.num_credito and a.num_producto = '6800')  
			 WHERE a.numcte = o_num_cliente AND b.fecha_cancela IS NULL;
			IF vlCteLargo > 0 THEN -- existe al menos un credito flexible aun vivo.
				LET scod_ret= '006';
				LET cCausaSol = "RDO";
				LET crechazo = '1';
				LET cMensaje = 'Por el momento le podemos tramitar el (los) producto (s) presentado (s) ' ||
									'en la pantalla "SelecciÃÂ³n de Productos". No se le puede ofrecer una '||
									'solicitud de crÃÂ©dito porque cuenta con un prestamo digital activo.';			
			END IF;
		END IF;
			 
	   
       LET s_creditos = s_creditos + DBINFO("sqlca.sqlerrd2");
	   --Se modifica para evitar error -1207 
		IF 	s_creditos > 1 THEN
			LET s_creditos = 1; 
		END IF;	
   END IF;
   IF pEjecucion = "0" THEN
               IF crechazo = '1' THEN
               INSERT INTO bdisolic:"informix".ss_bitacora_precal
				(empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
				causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
				saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra, grupo,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
				saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
				VALUES
				(o_empresa, dtFecha, o_producto, o_sucursal, cNomcte, cNomcteCoppel, s_cteref, o_ejecutivo, sPorcentaje, cSituacion,    sMesesHist,
				sCausa,cMotivo,cTipoRechazo,scod_ret, cMensaje,cCausaSol,iVencidoMuebles,iVencidoRopa,iVencidoPrestamos,iSaldoMuebles,
				iSaldoRopa,iSaldoPrestamos,iAbonoMuebles,iAbonoRopa,iAbonoPrestamos,iFechaUltimaCompra, vlGrupo,cFechaUltimoPago,cPrestamoAutorizado,iMontoAutorizado,iRePrestamo,iVencidoAire,iAbonoAire,
				iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);

                  RETURN scod_ret, cMensaje, NVL(s_tipper,''), NVL(s_referen1,''), NVL(s_nomrefer1,''),
                      NVL(s_referen2,''), NVL(s_nomrefer2,''), NVL(s_sexo,''), NVL(s_edocivil,''), NVL(s_edad,''),
                      NVL(s_habita_en,''), NVL(s_puesto,''), NVL(s_creditos,''), NVL(s_profesion,''), NVL(s_tel_ref_1,''), NVL(s_tel_ref_2,''),
                      NVL(s_parentesco1,''), NVL(s_parentesco2,''), NVL(s_cteref,'');
             END IF;
   END IF;
-- FIN Caja Unica. Viridiana
END 

 
          -- Cliente  presenta ocupaciÃÂ³n de Riesgo o inestabilidad en la Vivienda
 EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_act_riesgo( o_empresa,o_num_cliente) INTO  cCodRet,
																							 cDescripcion,
																							 cRiesgoViviendaCpl,
																							 cRiesgoViviendaBcpl,
																							 cActRiesgoCpl,
																							 cActRiesgoBCpl,
																							 cDescpRiesgo;
	
   IF NVL(cRiesgoViviendaCpl,'') = 1 OR NVL(cRiesgoViviendaBcpl,'') = 1  THEN
		LET scod_ret= '106';
		LET cMensaje = 'Rechazo por inestabilidad en la Vivienda';	
		LET crechazo = '1';
		LET cCausaSol = "REV";
	ELIF cActRiesgoCpl = 1 AND cActRiesgoBCpl = 0 THEN
		IF TRIM(cDescpRiesgo) = TRIM(cAbogadoLit) THEN 
			LET scod_ret= '110';
			LET cMensaje = 'Rechazo por ocupacion de Riesgo Abogado Litigante';
			LET cCausaSol = "RDO";
		ELSE
			LET scod_ret= '108';
			LET cMensaje = 'Rechazo por ocupacion de Riesgo en Coppel';
			LET cCausaSol = "RDO";
		END IF ;
			LET crechazo = '1';
	ELIF cActRiesgoCpl = 0 AND cActRiesgoBCpl = 1 THEN		
		IF TRIM(cDescpRiesgo) = TRIM(cPoliciaM) THEN
			LET scod_ret= '111';
			LET cMensaje = 'Rechazo por ocupacion de Riesgo  Servicios de Seguridad Publica (Municipal)';
			LET cCausaSol = "RDO";
		ELSE 
			LET scod_ret= '109';
			LET cMensaje = 'Rechazo por ocupacion de Riesgo en Bancoppel';
			LET cCausaSol = "RDO";
		END IF;
		LET crechazo = '1';
	ELIF cActRiesgoCpl = 1 AND  cActRiesgoBCpl =1 THEN	
		IF TRIM(cDescpRiesgo) = TRIM(cAbogadoLit) THEN 
			LET scod_ret= '110';
			LET cMensaje = 'Rechazo por ocupacion de Riesgo Abogado Litigante';
			LET cCausaSol = "RDO";
		ELIF TRIM(cDescpRiesgo) = TRIM(cPoliciaM) THEN
			LET scod_ret= '111 ';
			LET cMensaje = 'Rechazo por ocupacion de Riesgo  Servicios de Seguridad Publica (Municipal)';
			LET cCausaSol = "RDO";
		ELSE
			LET scod_ret= '107';
			LET cMensaje = 'Rechazo por ocupacion de Riesgo';
			LET cCausaSol = "RDO";
		END IF;
		LET crechazo = '1';
	END IF;
  
	 IF crechazo = '1' AND pEjecucion= '0'THEN
	
			  INSERT INTO bdisolic:"informix".ss_bitacora_precal
			   (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
			   causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
			   saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra, grupo,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
			   saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
			  VALUES
			  (o_empresa, dtFecha, o_producto, o_sucursal, cNomcte, cNomcteCoppel, s_cteref, o_ejecutivo, sPorcentaje, cSituacion,    sMesesHist,
			  sCausa,cMotivo,cTipoRechazo,scod_ret, cMensaje,cCausaSol,iVencidoMuebles,iVencidoRopa,iVencidoPrestamos,iSaldoMuebles,
			  iSaldoRopa,iSaldoPrestamos,iAbonoMuebles,iAbonoRopa,iAbonoPrestamos,iFechaUltimaCompra, vlGrupo,cFechaUltimoPago,cPrestamoAutorizado,iMontoAutorizado,iRePrestamo,iVencidoAire,iAbonoAire,
			  iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);

			  RETURN scod_ret, cMensaje, NVL(s_tipper,''), NVL(s_referen1,''), NVL(s_nomrefer1,''),
				  NVL(s_referen2,''), NVL(s_nomrefer2,''), NVL(s_sexo,''), NVL(s_edocivil,''), NVL(s_edad,''),
				  NVL(s_habita_en,''), NVL(s_puesto,''), NVL(s_creditos,''), NVL(s_profesion,''), NVL(s_tel_ref_1,''), NVL(s_tel_ref_2,''),
				  NVL(s_parentesco1,''), NVL(s_parentesco2,''), NVL(s_cteref,'');
  
	
	END IF;
	    RETURN scod_ret, cMensaje, NVL(s_tipper,''), NVL(s_referen1,''), NVL(s_nomrefer1,''),
                      NVL(s_referen2,''), NVL(s_nomrefer2,''), NVL(s_sexo,''), NVL(s_edocivil,''), NVL(s_edad,''),
                      NVL(s_habita_en,''), NVL(s_puesto,''), NVL(s_creditos,''), NVL(s_profesion,''), NVL(s_tel_ref_1,''), NVL(s_tel_ref_2,''),
                      NVL(s_parentesco1,''), NVL(s_parentesco2,''), NVL(s_cteref,'');
	

END PROCEDURE
