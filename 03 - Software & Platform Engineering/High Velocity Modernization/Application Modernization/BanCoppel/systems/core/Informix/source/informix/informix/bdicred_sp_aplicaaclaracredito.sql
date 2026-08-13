CREATE PROCEDURE "informix".sp_aplicaaclaracredito(pEmpresa CHAR(3), pFolioSuac CHAR(10), pDictamen CHAR(2), pCalculaInteres CHAR(1), pEmpleadoAut CHAR (8))
RETURNING CHAR(3);

    DEFINE cCodRet              CHAR(3);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;

    DEFINE CnumCredito          CHAR(20);
    DEFINE CnumTarjeta          CHAR(20);
    DEFINE CmontoAcla           DECIMAL(18,2);
    DEFINE Csucursal            CHAR(4);
    DEFINE pfecha               DATE;
    DEFINE pfechaAux            DATE;
    DEFINE pfechaMov            DATE;
    DEFINE pfechaAcl            DATE;
    DEFINE pIntDev              DECIMAL(18,2);
    DEFINE pIntVig              DECIMAL(18,2);
    DEFINE pIntVenc             DECIMAL(18,2);
    DEFINE pIntCalc             DECIMAL(18,2);
    DEFINE pTasaInt             DECIMAL(18,2);
    DEFINE pIntBoni             DECIMAL(18,2);
    DEFINE pIvaBoni             DECIMAL(18,2);
    DEFINE DiasCalc             SMALLINT;
    DEFINE DiasPeri             SMALLINT;
    DEFINE pIntCap              DECIMAL(18,2);
    DEFINE pIvaCap              DECIMAL(18,2);
    DEFINE CCodret_c            CHAR(5);
    DEFINE CMensaje             CHAR(80);
    DEFINE CSecuencia           INTEGER;
    DEFINE Ctrannopro           CHAR(04);
    DEFINE Ctransinauto         CHAR(04);
    DEFINE Ctranpro             CHAR(04);
    DEFINE Ctranauto            CHAR(04);
    DEFINE Ccargo               SMALLINT;
    DEFINE ptranaplica          CHAR(04);
    DEFINE Ctrans_no_procede    CHAR(04);
    DEFINE Mcosto               DECIMAL(18,2);
    DEFINE Ifky_aclaracion      INTEGER;
    DEFINE Ifky_producto        INTEGER;
    DEFINE Ipky_tipo_movimiento INTEGER;
    DEFINE wBegin               CHAR(1);
    DEFINE Ipky_movimiento      INTEGER;
    DEFINE v_contador           SMALLINT;
    DEFINE pFolioSuacSUC        CHAR(16);
    DEFINE v_fecha_folio        CHAR(10);
	DEFINE CSecuencia_acl_mov   INTEGER;
	DEFINE fecha_captura		DATE;

    DEFINE v_numero_transaccion CHAR(04);
	DEFINE Es_Nacional			CHAR(1);
	DEFINE v_nombre_origen 		CHAR(50);
	DEFINE v_OrigenEvento		INTEGER;
	DEFINE v_NumTarjeta			CHAR(20);
	DEFINE v_FolioSuc			CHAR(20);

--> Variables para duplicidad de movimientos
	DEFINE v_fky_padre          INTEGER;
	DEFINE v_monto				DECIMAL(18,2);
	DEFINE v_montoprocedente    DECIMAL(18,2);
	DEFINE v_fky_tipo_evento    INTEGER;
	DEFINE v_duplicado          SMALLINT;

--> Variable para control de movimientos a afectar
	DEFINE v_tipo_fky_padre     INTEGER;

	DEFINE v_contador_1			INTEGER;
	DEFINE v_contador_2			INTEGER;
	DEFINE v_contador_total		INTEGER;
	
--> Variables tabla de control
	DEFINE max_control_afect_cred INTEGER;
	
--> Variable para almacenar nombre de un SP || JLM - 02/06/2022	
	DEFINE v_nombre_sp            CHAR(20);
	DEFINE horaActual             DATETIME YEAR TO FRACTION(5);
	
	---VARIABLES TDC
	DEFINE v_tipo_producto   CHAR(4);
    DEFINE v_descripcion_pro VARCHAR(255);
	
	--VARIABLES PARA EL RQM 06 919 ABONO INMEDIATO
	DEFINE abono_inmediato				CHAR(2);
	DEFINE dfa						    CHAR(1);
	DEFINE devolucion					CHAR(1);
	

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,CMensaje
      LET cCodRet = sql_err;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;

      RETURN cCodRet;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      --ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

   --	SET DEBUG FILE TO "/resplogifx/Rey_David/extra/sp_aplicacredito.out";
   --TRACE ON;
   LET cCodRet      		= '000';
   LET pfechaMov    		= DATE(1);
   LET pfechaAcl    		= DATE(1);
   LET pfechaAux    		= DATE(1);
   LET pfecha       		= DATE(1);
   LET CnumCredito  		= '';
   LET CnumTarjeta  		= '';
   LET CmontoAcla   		= 0;
   LET Csucursal    		= '';
   LET pIntVig      		= 0;
   LET pIntVenc     		= 0;
   LET DiasPeri     		= 0;
   LET pIntBoni     		= 0;
   LET pIntCap      		= 0;
   LET pIvaCap      		= 0;
   LET CCodret_c    		= '';
   LET CMensaje     		= '';
   LET CSecuencia   		= 0;
   LET Ctrannopro   		= '';
   LET Ctransinauto 		= '';
   LET Ctranpro     		= '';
   LET Ctranauto    		= '';
   LET Ccargo       		= 0;
   LET ptranaplica  		= '0000';
   LET Ctrans_no_procede 	= '';
   LET Mcosto       		= 0;
   LET Ifky_aclaracion 		= 0;
   LET Ifky_producto 		= 0;
   LET Ipky_tipo_movimiento = 0;
   LET wBegin 				= 'N';
   LET Ipky_movimiento 		= 0;
   LET v_contador 			= 0;
   LET pFolioSuacSUC 		= '';
   LET v_fecha_folio 		= "";
   LET CSecuencia_acl_mov   = 0;
   LET fecha_captura		=DATE(1);

   LET v_numero_transaccion = '';
   LET Es_Nacional			= '';
   LET v_nombre_origen 		= '';
   LET v_OrigenEvento		= 0;
   LET v_NumTarjeta			= '';
   LET v_FolioSuc			= '';

--> Variables para duplicidad de movimientos
   LET v_fky_padre       = 0;
   LET v_monto           = 0;
   LET v_montoprocedente = 0;
   LEt v_fky_tipo_evento = 0;
   LET v_duplicado 	     = 0;
   LET v_contador_1		 = 0;
   LET v_contador_2		 = 0;
   LET v_contador_total	 = 0;

--> Variable para control de movimientos a afectar
   LET v_tipo_fky_padre  = 0;
--> Variables tabla de control
   LET max_control_afect_cred = 0;
   
--> Variable para almacenar nombre de un SP || JLM - 02/06/2022   
   LET v_nombre_sp       = '';
   LET horaActual        = NULL;
   LET v_tipo_producto   = NULL;
   LET v_descripcion_pro = '';
   
   --VARIABLES PARA EL RQM 06 919 ABONO INMEDIATO
	LET abono_inmediato					='';
	LET dfa						   	 	='';
	LET devolucion						='';
   
   
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones
   -- 15/01/2013 sp_aplicaaclaracredito V6 	-> ModificaciÃ³n afectaciones lÃ³gica movimientos duplicados
   --										-> Flujos adicionales a seguir
   -- 										-> Validaciones para que no cargue movimientos sin previamente abonados
   -- 										-> ValidaciÃ³n de flujo AA para cargo de comisiÃ³n, iva de comisiÃ³n y si es el caso el monto previamente abonado.
   -- 										-> Agregar validaciÃ³n para cargos
-- 03/04/2013 sp_aplicaaclaracredito V7 	-> ModificaciÃ³n envÃ­o de num_empleado que autoriza las afectaciones Entrega III, CNBV

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar debug
   --SET DEBUG FILE TO "/resplogifx/repaclaraciones/sp_aplicaaclaracredito"||"_"||""||pFolioSuac||""||"_v13_"||""||pDictamen||".out";
    --SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_aplicaaclaracredito_usr"||pFolioSuac||pDictamen||"_35"||".out";
    --TRACE ON;


   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   BEGIN WORK;

   
   -- APLICA VALIDACIÓN DE COPPEL TDC
	
		SELECT tp.producto, tp.descripcion INTO v_tipo_producto, v_descripcion_pro FROM bdiaclaracion:acl_aclaracion acl
		inner join bdiaclaracion:acl_producto p on acl.fky_producto = p.pky_producto
		inner join bdiaclaracion:acl_tipo_producto tp on p.fky_tipo_producto = tp.pky_tipo_producto
		where acl.folio_csuac = pFolioSuac;
   
			
		IF pFolioSuac IS NULL OR pFolioSuac='' THEN
			LET cCodRet='001';
			RETURN cCodRet;
		END IF;
		
-- 		  IF pNaturaleza IS NULL OR pNaturaleza='' THEN
-- 		     LET cCodRet='006';
-- 		     RETURN cCodRet;
-- 		  END IF;
		
		IF pDictamen IS NULL OR pDictamen='' THEN
			LET cCodRet='007';
			RETURN cCodRet;
		END IF;
		
		IF pCalculaInteres IS NULL OR pCalculaInteres='' THEN
			LET cCodRet='008';
			RETURN cCodRet;
		END IF;
		
			SELECT valor INTO DiasCalc
			FROM sd_param
			WHERE empresa = pEmpresa
			AND cod_param = "24"; -- Dias Para Calculo de Intereses
		
			SELECT fecha_hoy
			INTO pfecha
			FROM bdicred:sd_fechas
			WHERE empresa = pEmpresa;
		
		----SE INTEGRA VALIDACIÃN PARA EL RQM 06 919 ABONO INMEDIATO-----
		--Se obtiene banderas para validar si es un flujo de abono inmediato
		SELECT ev.acepta_dfa, ev.acepta_devolucion  
		INTO dfa, devolucion
		FROM bdiaclaracion:acl_aclaracion acl 
		INNER JOIN bdiaclaracion:acl_tipo_evento ev ON acl.fky_tipo_evento = ev.pky_tipo_evento
		WHERE acl.folio_csuac = pFolioSuac;
		
		--Valida que los campos de DFA o DevoluciÃ³n se encuentren encendidos
		IF (dfa = 1) THEN 
			LET abono_inmediato = 1;
		ELIF (devolucion = 1) THEN 
			LET abono_inmediato = 1;
		END IF; --fin de validaciÃ³n banderas DFA y DevoluciÃ³n
		
		-- APLICA VALIDACIÃN DE COPPEL TDC
			
		IF v_tipo_producto <> '6500' THEN
		
			IF (pDictamen = 'NP') THEN
		
---		---------------------------------------------- >> ValidaciÃ³n para creaciÃ³n de movimientos duplicados.
				SELECT fky_padre
				INTO v_fky_padre
				FROM bdiaclaracion:acl_movimiento
				WHERE duplicado = 1
				AND folio_csuac = pFolioSuac;
		
				IF (v_fky_padre IS NULL) THEN
		
				IF (pCalculaInteres='0') THEN
					FOREACH WITH hold
						-- >> Insertar movimientos duplicados.
						SELECT a.folio_csuac, a.monto, a.montoprocedente, b.trans_no_procede, a.fky_padre, a.fky_producto, a.fky_tipo_evento, a.fky_tipo_movimiento
						INTO
						pFolioSuac,          -- folio_csuac,  	   			--> Mismo que el padre -- ok
						v_monto,             -- monto, 						--> Mismo que el padre -- para afectaciÃ³n contable
						v_montoprocedente,   -- montoprocedente, 			--> Mismo que el padre -- Breviario cultural
						Ctrans_no_procede,   -- numero_transaccion, 		--> null -- Tran_no_procede para que haga la afectaciÃ³n con esa transacciÃ³n.
						Ipky_movimiento,     -- fky_padre,	 				--> pky del movimiento padre
						Ifky_producto,       -- fky_producto, 				--> Mismo que el padre
						v_fky_tipo_evento,   -- fky_tipo_evento, 			--> Mismo que el padre
						Ipky_tipo_movimiento -- fky_tipo_movimiento, 		--> Mismo que el padre
						FROM bdiaclaracion:acl_movimiento a, bdiaclaracion:acl_tipo_movimiento b
						WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
						AND a.folio_csuac = pFolioSuac
						AND a.cargo = 0
						AND a.exitoso = 1
						-- AND a.procede = 1
						AND a.fecha_afectacion IS NOT NULL
						AND a.duplicado = 0
					--	AND a.fky_tipo_movimiento <> 340 --> ValidaciÃ??Ã?Â³n no duplicar intereses abonados
		
						SELECT MAX (secuencia)
						INTO CSecuencia_acl_mov
						FROM bdiaclaracion:acl_movimiento
						WHERE folio_csuac = pFolioSuac;
		
						SELECT duplicado
						INTO v_duplicado
						FROM bdiaclaracion:acl_movimiento a
						WHERE folio_csuac = pFolioSuac
						AND a.duplicado = 1
						AND monto = v_monto;
		
						IF (v_duplicado IS NULL) THEN
		
						INSERT INTO bdiaclaracion:acl_movimiento VALUES (
						-- pky_movimiento                             calculado     cargo  	cargo_ajuste   exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia        referencia23             reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio                              num_sucursal , recuperacion, montorecuperacion
						bdiaclaracion:MOVIMIENTO_SEQ.nextval,     0,            1,        	null,		0,          null,                    null,                  current,                pFolioSuac,     null,             null,                         null,      null,      v_monto,  v_montoprocedente,  1,            Ctrans_no_procede,     1,          '',               '',                      0,            CSecuencia_acl_mov, null,              Ipky_movimiento, Ifky_producto,   null,                      v_fky_tipo_evento,  Ipky_tipo_movimiento,   null,                             null,                                     "9250", null, 0, 0);
						-- VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0, 1, 0, null, null, current, pFolioSuac, null, null, null, null, Mcosto, Mcosto, 0,Ctrans_no_procede, 1, '', '', 0, CSecuencia_acl_mov, null, Ipky_movimiento, Ifky_producto, null, 1, Ipky_tipo_movimiento, null, null, "9250");
		
						END IF;
		
					END FOREACH;
		
				END IF; -- Calculo de interes = 0
		
		
				SET ISOLATION TO DIRTY READ;
				IF (pCalculaInteres='1') THEN
							FOREACH WITH hold
						-- >> Insertar movimientos duplicados.
						SELECT a.folio_csuac, a.monto, a.montoprocedente, b.trans_no_procede, a.fky_padre, a.fky_producto, a.fky_tipo_evento, a.fky_tipo_movimiento
		
						INTO
						pFolioSuac,          -- folio_csuac,  	   			--> Mismo que el padre -- ok
						v_monto,             -- monto, 						--> Mismo que el padre -- para afectaciÃ??Ã?Â³n contable
						v_montoprocedente,   -- montoprocedente, 			--> Mismo que el padre -- Breviario cultural
						Ctrans_no_procede,   -- numero_transaccion, 		--> null -- Tran_no_procede para que haga la afectaciÃ??Ã?Â³n con esa transacciÃ??Ã?Â³n.
						Ipky_movimiento,     -- fky_padre,	 				--> pky del movimiento padre
						Ifky_producto,       -- fky_producto, 				--> Mismo que el padre
						v_fky_tipo_evento,   -- fky_tipo_evento, 			--> Mismo que el padre
						Ipky_tipo_movimiento -- fky_tipo_movimiento, 		--> Mismo que el padre
		
						FROM bdiaclaracion:acl_movimiento a, bdiaclaracion:acl_tipo_movimiento b
						WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
						AND a.folio_csuac = pFolioSuac
						AND a.cargo = 0
						AND a.exitoso = 1
						-- AND a.procede = 1
						AND a.fecha_afectacion IS NOT NULL
						AND a.duplicado = 0
						--AND a.fky_tipo_movimiento <> 340 --> ValidaciÃ??Ã?Â³n no duplicar intereses abonados
		
						SELECT MAX (secuencia)
						INTO CSecuencia_acl_mov
						FROM bdiaclaracion:acl_movimiento
						WHERE folio_csuac = pFolioSuac;
		
						SELECT duplicado
						INTO v_duplicado
						FROM bdiaclaracion:acl_movimiento a
		
						WHERE folio_csuac = pFolioSuac
						AND a.duplicado = 1
						AND monto = v_monto;
		
						IF (v_duplicado IS NULL) THEN
		
							INSERT INTO bdiaclaracion:acl_movimiento VALUES (
							-- pky_movimiento                         calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion     fecha_hora_e_global     fechahora     folio_csuac     folio_suc     identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia        referencia23             reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio     num_sucursal
							bdiaclaracion:MOVIMIENTO_SEQ.nextval,     0,            1,        null,			0,          null,                null,                   current,      pFolioSuac,     null,         null,                         null,      null,      v_monto,  v_montoprocedente,  1,            Ctrans_no_procede,     1,          '',               '',                      0,            CSecuencia_acl_mov, null,              Ipky_movimiento, Ifky_producto,   null,                      v_fky_tipo_evento,  Ipky_tipo_movimiento,   null,                             null,            "9250", null,0,0);
		
						END IF;
		
					END FOREACH;
				END IF; -- Calculo de interes 1
		
				END IF;
		
				--------- >> Determina si el movimiento es Nacional o Internacional
				SET ISOLATION TO DIRTY READ;
				SELECT tipo_movimiento INTO Es_Nacional
				FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = pFolioSuac;
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional ='N') THEN --Deshabilitar cuando se utilice completamente el campo tipo_movimiento de acl_aclaracion
					SELECT te.fky_origen_evento, p.numero_tarjeta
						INTO v_OrigenEvento, v_NumTarjeta
						FROM bdiaclaracion:acl_aclaracion acl
						INNER JOIN bdiaclaracion:acl_tipo_evento te on te.pky_tipo_evento = acl.fky_tipo_evento
						INNER JOIN bdiaclaracion:acl_producto p on p.pky_producto = acl.fky_producto
						WHERE acl.folio_csuac = pFolioSuac;
		
					SELECT LIMIT 1 SUBSTR(bdiaclaracion:acl_movimiento.folio_suc,2)
						INTO v_FolioSuc
						FROM bdiaclaracion:acl_movimiento
						WHERE bdiaclaracion:acl_movimiento.folio_csuac=pFolioSuac;
		
					SELECT nombre INTO v_nombre_origen
						FROM bdiaclaracion:acl_origen_evento WHERE pky_origen_evento = v_OrigenEvento;
		
					--IF v_OrigenEvento = '2' or v_OrigenEvento = '3' or v_OrigenEvento = '6' or v_OrigenEvento = '7' Then
					IF v_nombre_origen = 'POS' or v_nombre_origen = 'ATMS' Then
						SET ISOLATION TO DIRTY READ;
						SELECT intercard:movimiento.esnacional
							INTO Es_Nacional
							FROM intercard:movimiento
							WHERE intercard:movimiento.secuenciaextendida=v_FolioSuc
							AND intercard:movimiento.numtarjeta=v_NumTarjeta;
		
						IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
							SET ISOLATION TO DIRTY READ;
							SELECT intercard:movimientohistorico.esnacional
								INTO Es_Nacional
								FROM intercard:movimientohistorico
								WHERE intercard:movimientohistorico.secuenciaextendida=v_FolioSuc
								AND intercard:movimientohistorico.numtarjeta=v_NumTarjeta;
		
								IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
									UPDATE bdiaclaracion:acl_aclaracion SET tipo_movimiento = 'V' WHERE folio_csuac=pFolioSuac;
								ELSE
									UPDATE bdiaclaracion:acl_aclaracion SET tipo_movimiento = Es_Nacional WHERE folio_csuac=pFolioSuac;
								END IF;
						END IF;
					ELSE
						LET Es_Nacional = 'V';
					END IF;
				END IF;
		
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
					LET Es_Nacional = 'V';
				END IF;
		
				-------------- >> Inserta movimiento de comisiÃ³n por Aclaacion no procedente
				-- >> Se inactiva para evitar el cobro de comisiÃ³n e iva en crÃ©ditos 09/09/2011
				-- >> Se activa para realizar el cobro de comisiÃ³n e iva en crÃ©ditos 13/02/2011
			--SET ISOLATION TO DIRTY READ;
			SET ISOLATION TO DIRTY READ;
			SELECT d.trans_no_procede,
					CASE
						WHEN Es_Nacional = 'F' THEN 0
						WHEN Es_Nacional = 'V' THEN nvl(e.costo,0)
					END AS costo, a.fky_aclaracion, a.fky_producto, d.pky_tipo_movimiento, a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c,
					bdiaclaracion:acl_tipo_movimiento d,
					bdiaclaracion:acl_costo_aclaracion e
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND c.pky_origen_evento = d.fky_origen_evento
				AND c.pky_origen_evento = e.fky_origen_evento
				AND a.fky_padre IS NULL
				AND d.fky_tipo_transaccion = 12
				-- AND a.cargo IS NOT NULL
				AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
				AND duplicado = 0
				AND folio_csuac = pFolioSuac;
		
				IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisiÃ³n desde tabla acl_tipo_Evento
				/* Se elimina referencia a tabla acl_tipo_movimiento, transacciÃ³n de no procedencia es fija y se define una trasacciÃ³n fija para comisiones de
				no procedencia, esto para no tener que repetir por cada uno de los Eventos creados, ya que las comisiones ahora son por evento RQM 06 315*/
				SET ISOLATION TO DIRTY READ;
				SELECT '5212',
					CASE
						WHEN Es_Nacional = 'F' THEN 0
						WHEN Es_Nacional = 'V' THEN nvl(b.costo,0)
					END AS costo,
					a.fky_aclaracion, a.fky_producto, '143', a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND a.fky_padre IS NULL
				AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
				AND duplicado = 0
				AND folio_csuac = pFolioSuac;
		
				END IF;  -- comisiÃ³n desde acl_tipo_evento
		
				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (numero_transaccion)
				INTO v_numero_transaccion
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac
				AND numero_transaccion = Ctrans_no_procede;
		
				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (secuencia)
				INTO CSecuencia_acl_mov
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac;
		
				UPDATE bdiaclaracion:acl_movimiento -->> Valida que no existan movimientos como procedentes de forma erronea para que no sean cargados al cliente.
				SET procede = 0
				WHERE folio_csuac = pFolioSuac
				AND cargo = 0
				AND (exitoso = 0 OR exitoso IS NULL);
		
				IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la comisiÃ??Ã?Â³n de crÃ??Ã?Â©dito, para no duplicarla 24/04/2012
					If Mcosto = '0' Then
						INSERT INTO bdiaclaracion:acl_movimiento
						-- pky_movimiento                            calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal  , recuperaciom, monto_recuperacion
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,        null,			0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     0,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250", null,0, 0);
					Else
						INSERT INTO bdiaclaracion:acl_movimiento
																		--cargo por ajuste
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0, 1, null, 0, null, null, current, pFolioSuac, null, null, null, null, Mcosto, Mcosto, 0,Ctrans_no_procede, 1, '', '', 0, CSecuencia_acl_mov, null, Ipky_movimiento, Ifky_producto, null, 1, Ipky_tipo_movimiento, null, null, "9250", null, 0, 0);
					End If;
				END IF;
		
		
			END IF;
---		----------*******************************************************************************************************************************************
		
-->		> Flujo de aclaraciones: Analizar, No Procede = Sin AfectaciÃ??Ã?Â³n  --> Solo cobro de comision
		
			IF (pDictamen = 'CM') THEN
				SET ISOLATION TO DIRTY READ;
		
				--------- >> Determina si el movimiento es Nacional o Internacional
				SELECT tipo_movimiento INTO Es_Nacional
				FROM bdiaclaracion:acl_aclaracion WHERE folio_csuac = pFolioSuac;
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN --Deshabilitar cuando se utilice completamente el campo tipo_movimiento de acl_aclaracion
					SELECT te.fky_origen_evento, p.numero_tarjeta
						INTO v_OrigenEvento, v_NumTarjeta
						FROM bdiaclaracion:acl_aclaracion acl
						INNER JOIN bdiaclaracion:acl_tipo_evento te on te.pky_tipo_evento = acl.fky_tipo_evento
						INNER JOIN bdiaclaracion:acl_producto p on p.pky_producto = acl.fky_producto
						WHERE acl.folio_csuac = pFolioSuac;
		
					SELECT LIMIT 1 SUBSTR(bdiaclaracion:acl_movimiento.folio_suc,2)
						INTO v_FolioSuc
						FROM bdiaclaracion:acl_movimiento
						WHERE bdiaclaracion:acl_movimiento.folio_csuac=pFolioSuac;
		
					SELECT nombre INTO v_nombre_origen
						FROM bdiaclaracion:acl_origen_evento WHERE pky_origen_evento = v_OrigenEvento;
		
					--IF v_OrigenEvento = '2' or v_OrigenEvento = '3' or v_OrigenEvento = '6' or v_OrigenEvento = '7' Then
					IF v_nombre_origen = 'POS' or v_nombre_origen = 'ATMS' Then
						SET ISOLATION TO DIRTY READ;
						SELECT intercard:movimiento.esnacional
							INTO Es_Nacional
							FROM intercard:movimiento
							WHERE intercard:movimiento.secuenciaextendida=v_FolioSuc
							AND intercard:movimiento.numtarjeta=v_NumTarjeta;
		
						IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
							SET ISOLATION TO DIRTY READ;
							SELECT intercard:movimientohistorico.esnacional
								INTO Es_Nacional
								FROM intercard:movimientohistorico
								WHERE intercard:movimientohistorico.secuenciaextendida=v_FolioSuc
								AND intercard:movimientohistorico.numtarjeta=v_NumTarjeta;
		
								IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
									UPDATE bdiaclaracion:acl_aclaracion SET tipo_movimiento = 'V' WHERE folio_csuac=pFolioSuac;
									LET Es_Nacional = 'V';
								ELSE
									UPDATE bdiaclaracion:acl_aclaracion SET tipo_movimiento = Es_Nacional WHERE folio_csuac=pFolioSuac;
								END IF;
						END IF;
					ELSE
						LET Es_Nacional = 'V';
					END IF;
				END IF;
		
		
				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
					LET Es_Nacional = 'V';
				END IF;
			SET ISOLATION TO DIRTY READ;
			SELECT d.trans_no_procede,
					CASE
						WHEN Es_Nacional = 'F' THEN 0
						WHEN Es_Nacional = 'V' THEN nvl(e.costo,0)
					END AS costo, a.fky_aclaracion, a.fky_producto, d.pky_tipo_movimiento, a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c,
					bdiaclaracion:acl_tipo_movimiento d,
					bdiaclaracion:acl_costo_aclaracion e
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND c.pky_origen_evento = d.fky_origen_evento
				AND c.pky_origen_evento = e.fky_origen_evento
				AND a.fky_padre is null
				AND d.fky_tipo_transaccion = 12
				AND a.cargo is  null  -- is not null
				AND folio_csuac = pFolioSuac;
		
				IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisiÃ³n desde tabla acl_tipo_Evento
				/* Se elimina referencia a tabla acl_tipo_movimiento, transacciÃ³n de no procedencia es fija y se define una trasacciÃ³n fija para comisiones de
				no procedencia, esto para no tener que repetir por cada uno de los Eventos creados, ya que las comisiones ahora son por evento RQM 06 315*/
				SELECT '5212',
					CASE
						WHEN Es_Nacional = 'F' THEN 0
						WHEN Es_Nacional = 'V' THEN nvl(b.costo,0)
					END AS costo,
					a.fky_aclaracion, a.fky_producto, '143', a.pky_movimiento
				INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
				FROM bdiaclaracion:acl_movimiento a,
					bdiaclaracion:acl_tipo_evento b,
					bdiaclaracion:acl_origen_evento c
				WHERE b.pky_tipo_evento = a.fky_tipo_evento
				AND c.pky_origen_evento = b.fky_origen_evento
				AND a.fky_padre IS NULL
				AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
				AND duplicado = 0
				AND folio_csuac = pFolioSuac;
		
				END IF;  -- comisiÃ??Ã?Â³n desde acl_tipo_evento
		
		
				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (numero_transaccion)
				INTO v_numero_transaccion
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac
				AND numero_transaccion = Ctrans_no_procede;
		
				--SET ISOLATION TO DIRTY READ;
				SELECT MAX (secuencia)
				INTO CSecuencia_acl_mov
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac;
		
				UPDATE bdiaclaracion:acl_movimiento -->> Valida que no existan movimientos como procedentes de forma erronea para que no sean cargados al cliente.
				SET procede = 0
				WHERE folio_csuac = pFolioSuac
				AND numero_transaccion IS NULL;
		
				IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la comision de credito, para no duplicarla 24/04/2012
					If Mcosto = '0' Then
						INSERT INTO bdiaclaracion:acl_movimiento
						-- pky_movimiento                            calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal, recuperacion, monto_recuperacion
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,        null,			0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     0,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250", null, 0, 0);
					Else
						INSERT INTO bdiaclaracion:acl_movimiento
																		--cargo por ajuste
						VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0, 1, null, 0, null, null, current, pFolioSuac, null, null, null, null, Mcosto, Mcosto, 0,Ctrans_no_procede, 1, '', '', 0, CSecuencia_acl_mov, null, Ipky_movimiento, Ifky_producto, null, 1, Ipky_tipo_movimiento, null, null, "9250", null, 0, 0);
					End If;
				END IF;
		
				-- Redireccionar la BD para la secuencia
				-- UPDATE bdiaclaracion:acl_movimiento SET exitoso = 1, procede = 1 WHERE folio_csuac = pFolioSuac and numero_transaccion is null;
			END IF;
		
			IF (pDictamen = 'NP') THEN
		
				UPDATE bdiaclaracion:acl_movimiento
				SET procede = 0
				WHERE (
				(folio_csuac = pFolioSuac
				AND procede = 1
				AND cargo IS NULL
				AND fecha_afectacion IS NULL) 
				--Se anexa validaciÃ³n para abono inmediato
				OR (folio_csuac = pFolioSuac AND abono_inmediato = 1 AND procede IS NULL)
				);
		
			END IF;
			LET v_contador = 0;
		
			--SET ISOLATION TO DIRTY READ;
			SELECT fechacaptura
			into fecha_captura
			FROM bdiaclaracion:acl_aclaracion
			WHERE folio_csuac=pFolioSuac;
			
			SET ISOLATION TO DIRTY READ;
		
			FOREACH WITH hold
		
				SELECT pky_movimiento, numero_cuenta, numero_tarjeta, montoprocedente, trans_no_procede, trans_procede, trans_procede_automatico, trans_procede_sin_autorizacion, nvl(cargo,0)
				INTO CSecuencia, CnumCredito, CnumTarjeta, CmontoAcla, Ctrannopro, Ctranpro, Ctranauto, Ctransinauto,Ccargo
				FROM bdiaclaracion:acl_movimiento a
				LEFT OUTER JOIN bdiaclaracion:acl_producto b on (a.fky_producto = b.pky_producto)
				LEFT OUTER JOIN bdiaclaracion:acl_tipo_movimiento c on (a.fky_tipo_movimiento = c.pky_tipo_movimiento)
				WHERE folio_csuac = pFolioSuac
				AND (procede IS NULL OR procede = 1)
				AND (exitoso IS NULL OR exitoso <> '1')
				AND NVL(fky_padre,0) = CASE WHEN ( pDictamen IN ('AA','AS')) THEN 0 ELSE NVL(fky_padre,0) END
		
				IF CnumCredito IS NULL THEN
					LET cCodRet='003';
					ROLLBACK WORK;
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet;
				END IF;
		
				IF CmontoAcla IS NULL or CmontoAcla = 0 THEN
					LET cCodRet='004';
					ROLLBACK WORK;
					IF (wBegin = "S") THEN
						BEGIN WORK;
					END IF;
					RETURN cCodRet;
				END IF;
		
				IF (CnumTarjeta is null) then
					let CnumTarjeta = '';
				END IF;
		
		
		
--f		alta definir la transaccion
--f		alta definir el centro de costos (sucursal)
		
				IF (pDictamen = 'PR') THEN --> transaccion procedente
					let ptranaplica = Ctranpro;
				elif (pDictamen = 'NP') THEN --> transaccion no procedente
					let ptranaplica = Ctrannopro;
				elif (pDictamen = 'CM') THEN --> transaccion no procedente sin afectaciÃ³n, solÃ³ comisiÃ³n
					let ptranaplica = Ctrannopro;
				elif (pDictamen = 'AA') THEN --> transaccion abono automatico
					let ptranaplica = Ctranauto;
				elif (pDictamen = 'AS') THEN --> transaccion abono automatico sin autorizacion
					let ptranaplica = Ctransinauto;
				END IF;
		
				SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
				INTO v_fecha_folio FROM bdicred:sd_fechas;
		
-- 		     let pFolioSuacSUC = pFolioSuacSUC||lpad(pFolioSuac,10,0);
				let pFolioSuacSUC = trim(v_fecha_folio)||lpad(pFolioSuac,10,0);
		
		
			--ValidaciÃ??Ã?Â³n para no permitir abonos/cargos dobles del mismo folio a las cuentas 13/01/2015
		
				SET ISOLATION TO DIRTY READ;
				SELECT count(*)
					INTO v_contador_1
				FROM bdicred:sd_movdia
				WHERE empresa=pEmpresa
					AND num_credito=CnumCredito
					AND monto=CmontoAcla
					AND substr(folio_suc,7)=pFolioSuac
					AND transacc_suc=ptranaplica;
		
				--SET ISOLATION TO DIRTY READ;
				SELECT fechacaptura
					into fecha_captura
				FROM bdiaclaracion:acl_aclaracion
				WHERE folio_csuac=pFolioSuac;
		
				SET ISOLATION TO DIRTY READ;
				SELECT count(*)
					INTO v_contador_2
				FROM bdicred:sd_movhis
				WHERE  num_credito=CnumCredito
					AND fecha_mov>=fecha_captura
					AND empresa=pEmpresa
					AND monto=CmontoAcla
					AND substr(folio_suc,7)=pFolioSuac
					AND transacc_suc=ptranaplica;
		
					LET v_contador_total = v_contador_1 + v_contador_2;
					
					
				--> Asignamos valor a "v_nombre_sp" y obtenemos dateTime del sistema JLM - 02/06/2022
				LET v_nombre_sp ='sp_cargo_abono_aclara';
				SELECT DBINFO("utc_to_datetime", sh_curtime)
					INTO horaActual
				FROM sysmaster:sysshmvals;
				-->
		
					IF (v_contador_total = 0 ) THEN
		
						call sp_cargo_abono_aclara(pEmpresa, CnumCredito, CnumTarjeta, CmontoAcla, user, '9250',ptranaplica,Ccargo ,pFolioSuacSUC)
						RETURNING CCodret_c, CMensaje;
						
						
						--> Validamos el codigo de retorno del sp_calculaintaclaraciones, si es difernete de "0", guardamos el error en bitacora. JLM - 02/06/2022
						IF( CCodret_c <> '000' ) THEN
							INSERT INTO informix.aplicaaclaracredito_control_errores(cod_retorno, nombre_sp, num_credito, num_tarjeta, folio_csuac, fecha_insert) 
								VALUES(CCodret_c, v_nombre_sp, CnumCredito, CnumTarjeta, pFolioSuac, horaActual);
						END IF;
						-->
						
		
					END IF; -- aplicaciÃ??Ã?Â³n cargo/abono
						IF (CCodret_c = "005") THEN
							LET cCodRet='005'; -- Intento de cargo con crÃ©dito vencido "BT" y bloqueado y sin saldo suficiente
							ROLLBACK WORK;
							IF (wBegin = "S") THEN
								BEGIN WORK;
							END IF;
							RETURN cCodRet;
						END IF;
		
						IF (CCodret_c = "207") THEN
							LET cCodRet='207'; -- Intento de cargo con crÃ©dito vencido "BT" y bloqueado
							ROLLBACK WORK;
							IF (wBegin = "S") THEN
								BEGIN WORK;
							END IF;
							RETURN cCodRet;
						END IF;
		
						IF (CCodret_c <> "000") THEN
							--Tabla de control de cÃ³digo de retorno
							LET CMensaje = TRIM(CMensaje)||'|'||v_contador_total;
							
							SELECT MAX(id_registro) + 1 
							INTO max_control_afect_cred
							FROM bdiaclaracion:"informix".acl_control_afectacion_cred;
							
							IF max_control_afect_cred IS NULL THEN
								LET max_control_afect_cred = 1;
							END IF;
							
							INSERT INTO bdiaclaracion:"informix".acl_control_afectacion_cred 
							VALUES (max_control_afect_cred, pFolioSuac, CURRENT, pDictamen, CCodret_c,TRIM(CMensaje),'bdicred:sp_aplicaaclaracredito');
							LET cCodRet='009'; --definir codigo en caso de falla en el cargo o abono
							--ROLLBACK WORK;
							IF (wBegin = "S") THEN
								BEGIN WORK;
							END IF;
		
							RETURN cCodRet;
							
						END IF;
		
		
---		----------- >> Actualiza tabla de movimientos (acl_movimiento) relacionados a la aclaraciÃ³n para indicar que se aplicarÃ³n
		
				LET CSecuencia_acl_mov = 0;
		
				SELECT MAX (secuencia)--, folio_csuac
				INTO CSecuencia_acl_mov
				FROM bdiaclaracion:acl_movimiento
				WHERE folio_csuac = pFolioSuac;
		
				-------------- >> ValidaciÃ³n de secuencia
		
				IF (CSecuencia_acl_mov is null) THEN
						LET CSecuencia_acl_mov = 1;
					ELSE
						LET CSecuencia_acl_mov = (CSecuencia_acl_mov) + 1;
				END IF;
		
				IF (pDictamen NOT IN ('NP', 'CM')) THEN --> Considerar CM y NP para actualizaciones correctas 14/01/2013
		
					IF (v_contador_total = 0 ) THEN
		
						UPDATE bdiaclaracion:acl_movimiento
						SET cargo = 0,
							exitoso = '1',
							fecha_afectacion = CURRENT,
							numero_transaccion = ptranaplica,
							secuencia = CSecuencia_acl_mov
						WHERE pky_movimiento = CSecuencia
						AND folio_csuac = pFolioSuac;
		
					ELSE
		
						UPDATE bdiaclaracion:acl_movimiento
						SET cargo = 0,
							fecha_afectacion = CURRENT,
							secuencia = CSecuencia_acl_mov
						WHERE pky_movimiento = CSecuencia
						AND folio_csuac = pFolioSuac;
		
					END IF;
					-- let v_contador = v_contador + 1;
		
				ELSE
		
					UPDATE bdiaclaracion:acl_movimiento
					SET cargo = 1,
						exitoso = '1',
						fecha_afectacion = CURRENT,
						numero_transaccion = ptranaplica,
						secuencia = CSecuencia_acl_mov
					WHERE pky_movimiento = CSecuencia
					AND folio_csuac = pFolioSuac;
		
					-- let v_contador = v_contador + 1;
				END IF;
		
		
			let v_contador = v_contador + 1;
		
		
		
			END FOREACH;
		END IF; -- Fin de validación de TADC
-- Actualiza tabla de acl_aclaracion con la fecha en que se dictamino

    COMMIT WORK;

    IF (wBegin = "S") THEN
        BEGIN WORK;
    END IF;

 END;

 RETURN cCodRet;

END PROCEDURE
DOCUMENT
'Sp sp_aplicaaclaracredito',
'Se incluye validacion para evitar se dupliquen abonos',
'Sistema: Aclaraciones',
'AUTOR : Bancoppel',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 13/Enero/2014',
'FECHA MOD: 31/Octubre/2018',
'VERSION: 1.0.0',
'BD    :  bdicred'

;

CREATE PROCEDURE "informix".sp_rep_cartera_activa(pEmpresa char(3))
returning 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
		  
	--update : JAHJ 11/12/2026 RQI 21 425
	
--************************ Definicion de variables *****************************
    define iSql_err                  integer;
    define cSql                      char(2080);
    define dPrimerDiaMes             date;
    define dUltimoDiaMesAnterior             date;
    define cNumCte                   char(20);
    define cNum_Credito              char(20);
    define cCreditoREES              char(20);
    define cStatus_CreditoREES       char(20);
    define cStatus_Credito           char(15);
    define cHit                      char(6);
    define dFecha_Nac                date;
    define cRfc                      char(13);
    define cSexo                     char(10);
    define cEstado_Civil             char(15);
    define cEmail                    char(70);
    define cNumeroEstado             char(2);
    define cNombreEstado             char(30);
    define sNumeroCiudad, sNumeroCiudadCpl smallint;
    define cNombreCiudad, cNombreCiudadCpl char(30);
    define iNumeroColonia            integer; 
    define cMunicipioZona            char(27);   
    define cTelefono1                char(13);           
    define cTelefono2                char(13);      
    define cTelefono3                char(13);     
    define cExtension                char(5);       
    define mIngreso_Mensual          money;     
    define cSucursal, cNum_Producto  char(4);    
    define cTiempo_Ocupacion_Act     char(50);     
    define dUltima_Disposicion       date;                        
    define dUltimo_Movimiento        date;                         
    define dUltimo_Vencido           date;               
    define cTipo_Ult_Mov             char(3);
    define dultimo_pago              date;
    define dSaldo_Actual             decimal(18,2);     
    define dSaldo_Vencido            decimal(18,2);     
    define dSdo_Capital              decimal(18,2);     
    define dMonto_Vencido            decimal(18,2);     
    define dMto_Venc_Trasp           decimal(18,2);     
    define dCap_Tras_No_Venci        decimal(18,2);     
    define dSaldo_Cierre             decimal(18,2);     
    define dMeses_Vencidos           decimal(18,2);     
    define cNum_Tarjeta              char(20);           
    define cNumCte_Ref               char(20);            
    define dFecha_Apertura           date;     
    define dSituacion_Pago           decimal(5,2);     
    define sMeses_Historia           smallint;
    define dfecha_hoy                date;
    define cMensajeRet               char(80);
    define cCodRet,vvcCod_ret        char(6); 
	define cCod_ret2				 char(6);
    define cNum_dia                  char(02);
    define cNum_mes                  char(02);
    define cNum_anio,cProceso        char(04);
    define dFechaVtaRees             date;
    define dFecha                    date;
    define contador_commit INTEGER;
    define sCommit      SMALLINT;
    define actualiza_esta integer;
    define cTipoReporte             char(02);
    define dUltDisp_atm             date;
    define dUltDisp_pos             date;
    define dUltDisp_vnt             date;
    define vCurrent                 char(25);
    define vdia                     char(10);
    define vhora                    char(8);
    define vHora3                   char(22); 
    define cPaso                    char(01); 
	define cMotivo					char(5);
	
	DEFINE dEvaluacion1        decimal(18,2);
	DEFINE dEvaluacion2         decimal(18,2);
	DEFINE dEvaluacion3         decimal(18,2);
	DEFINE dEvaluacion4         decimal(18,2);
	DEFINE dEvaluacion5         decimal(18,2);
	DEFINE cStatus_Ini CHAR(2);
	DEFINE cRevisado CHAR(2);
	DEFINE cIdbox smallint;
	DEFINE cIfe CHAR(2);
	DEFINE iNumPagos			INTEGER;
	DEFINE dMontoPagos  		decimal(18,2);
	DEFINE cGrupo				CHAR(2);
	DEFINE sFlag2creditoicc		SMALLINT;
	
	-- RQM 09 476 - 2 ADENDUM 
	DEFINE dLineaOrigen			decimal(18,2);
	DEFINE dLineaActual			decimal(18,2);
	DEFINE iSolicitudOS			integer;
	DEFINE iSolicitudOS_Gpo5	integer;
	DEFINE iSolicitudOS_P		integer;
	DEFINE iMarcaOS				integer;
	DEFINE cTipoFac				char(1);
	
	DEFINE cAct                     INTEGER;
    DEFINE cAtr                     INTEGER;
    DEFINE v_fecha_vencido  DATE;
    DEFINE v_num_vencidos   INTEGER;
    DEFINE dPagosVdos       INTEGER;
    DEFINE v_dias_vencido   INTEGER; 
	
     
    let iSql_err = 0;
    let cSql    = '';
    let cNumCte = '';
    let	cNum_Credito = '';
    let cNum_Credito = '';
    let cCreditoREES = '';
    let	cStatus_Credito	= '';
    let cHit = '';
    let dFecha_Nac = DATE(1);
    let cRfc = '';
    let cSexo ='';
    let cEstado_Civil = '';
    let cEmail = '';
    let cNumeroEstado = '';
    let cNombreEstado = '';
    let sNumeroCiudad = 0;
    let cNombreCiudad = '';
    let sNumeroCiudadCpl = 0;
    let cNombreCiudadCpl = '';
    let iNumeroColonia = 0;
    let cMunicipioZona = '';
    let cTelefono1 = '';
    let cTelefono2 = '';
    let cTelefono3 = '';
    let cExtension = '';
    let cSucursal = '';
    let cTiempo_Ocupacion_Act = '';
    let dUltima_Disposicion = DATE(1);
    let dUltimo_Movimiento = DATE(1);
    let dUltimo_Vencido = ' ';
    let cTipo_Ult_Mov = '';
    let dUltimo_pago = DATE(1);
    let dSaldo_Actual = 0.0;
    let dSaldo_Vencido = 0.0;
    let dSdo_Capital = 0.0;
    let dMonto_Vencido = 0.0;
    let dMto_Venc_Trasp = 0.0;
    let dCap_Tras_No_Venci = 0.0;
    let dSaldo_Cierre = 0.0;
    let dMeses_Vencidos = 0.0;
    let cNum_Tarjeta = '';
    let cNumCte_Ref = '';
    let dFecha_Apertura = DATE(1);
    let dSituacion_Pago = 0.0;
    let sMeses_Historia = 0;
    let dFecha_hoy = DATE(1);
    let dPrimerDiaMes = DATE(1);
    let dUltimoDiaMesAnterior = DATE(1);
    let cMensajeRet= 'El reporte de CARTERA ACTIVA se realizo correctamente';
    let cCodRet    = '000000';
	let cCod_ret2  = '000000';
    let cNum_dia   = '';
    let cNum_mes   = '';
    let cNum_anio  = '';
    let dFechaVtaRees  = DATE(1);
    let dFecha         = DATE(1);
    let contador_commit = 0;
    let sCommit         = 0;
    let actualiza_esta = 0;
    let cTipoReporte = '';
    let cProceso = '0033';
    let vvcCod_ret = '';
    let mIngreso_Mensual = 0;
    let dUltDisp_atm = date(1); let dUltDisp_pos = date(1); let dUltDisp_vnt = date(1);
    let vCurrent = ''; let vdia = '';   let vhora = '';  let vHora3 = '';
    let cPaso = '';  LET cNum_Producto = '';
	let cMotivo = '';
	
	let dEvaluacion1        =0;
	let dEvaluacion2        =0;
	let dEvaluacion3        =0;
	let dEvaluacion4        =0;
	let dEvaluacion5        =0;
	LET cStatus_Ini = "";
	LET cRevisado = "";
	LET cIdbox = 0;
	LET cIfe = "";
	LET iNumPagos			= 0;
	LET dMontoPagos			= 0;
	LET cGrupo				= '';
	LET sFlag2creditoicc	= 0;
	
	-- RQM 09 476 - 2 ADENDUM 
	LET dLineaOrigen		= 0.00;
	LET dLineaActual		= 0.00;
	LET iSolicitudOS		= 0;
	LET iSolicitudOS_Gpo5	= 0;
	LET iSolicitudOS_P		= 0;
	LET iMarcaOS			= 0;
	LET cTipoFac			= '';
	
	LET cAct                        = 0;
    LET cAtr                        = 0;
    LET v_fecha_vencido  = DATE(1);
    LET v_num_vencidos   =0;
    LET dPagosVdos       =0;
    LET v_dias_vencido   =0;
	
--**************************** Control de errores ******************************
    begin
    on exception set iSql_err
		if iSql_err <> 0 then
           let cCodRet= iSql_err;
           let cMensajeRet= 'ERROR en la ejecucion del reporte de CARTERA ACTIVA' || cNum_Credito;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '02') returning cCod_ret2;
--           SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora3 from sysmaster:sysshmvals;
           return cCodRet,cMensajeRet;
		end if;
	end exception;


	--SET DEBUG FILE TO "/RESPALDOSNEW/cobranza/146/sp_rep_cartera_activa.out";
	--TRACE ON;

    SELECT today, current INTO vdia, vCurrent 
      FROM systables
      where tabid=1;

      LET vhora = vCurrent[12,19];      


--*************************** Programa principal *******************************
    set isolation to dirty read;
    set lock mode to wait 3;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '01') returning cCod_ret2;	
	
	select fecha_hoy, pri_dia_mes into dFecha_hoy,dPrimerDiaMes from bdicred:sd_fechas where empresa = pEmpresa;
    

--temporal para pruebas
   --let dFecha_hoy = mdy('02','28','2022');
   --let dPrimerDiaMes = mdy('02','01','2022');
--temporal para pruebas

    let dUltimoDiaMesAnterior = dPrimerDiaMes - 1 units day;
    let dPrimerDiaMes = dPrimerDiaMes - 1 units month;								

    let cNum_dia  = lpad(DAY(dUltimoDiaMesAnterior),2,'0');
    let cNum_mes  = lpad(MONTH(dUltimoDiaMesAnterior),2,'0');
    let cNum_anio = lpad(YEAR(dUltimoDiaMesAnterior),4,'0');
 
/* 
    IF NOT EXISTS (select idxname from sysindices where idxname='idx_numcredito_repcartactiva') THEN
       CREATE INDEX idx_numcredito_repcartactiva on bdicred:"informix".sd_rep_cartera_activa(fecha,tipo_reporte,num_credito);
    END IF;
*/
	--*******************************************************
	-- JAHJ: Ajuste para ser creada por unica ocasion con usr syscred 11/02/2026
	--*******************************************************
	IF (SELECT COUNT(*) FROM  systables 
				WHERE tabname = 'sd_rep_cartera_activa') = 0 THEN
		
		create table bdicred:sd_rep_cartera_activa (
			fecha date,	tipo_reporte char(2),
			numcte char(20), num_credito char(20),
			estatus_credito char(15),num_producto char(4),
			hit char(6),fecha_nac date,
			rfc char(13),sexo char(10),
			estado_civil char(15),email char(60),
			numeroestado char(2),nombreestado char(30),
			numerociudad smallint,nombreciudad char(30),
			numciudad_cpl smallint,nombreciudad_cpl char(30),
			numerocolonia integer,municipiozona char(27),
			telefono1 char(13),	telefono2 char(13),
			telefono3 char(13),	extension char(5),
			ingreso_mensual money(16,2),sucursal char(4),
			tiempo_ocupacion_act char(50),	ultima_disposicion date,
			ultimo_movimiento date,	ultimo_vencido date,
			tipo_ult_mov char(3),	saldo_actual decimal(18,2),
			saldo_vencido decimal(18,2),	sdo_capital decimal(18,2),
			monto_vencido decimal(18,2),	mto_venc_trasp decimal(18,2),
			cap_tras_no_venci decimal(18,2),	saldo_cierre decimal(18,2),
			meses_vencidos decimal(18,2),	num_tarjeta char(20),
			numcte_ref char(20),	fecha_apertura date,
			situacion_pago decimal(5,2),meses_historia smallint,
			motivo char(5),		bscore decimal(18,2) 	default 0.00,
			scoreprop decimal(18,2) 	default 0.00,ficoscore decimal(18,2) 	default 0.00,
			ficoextended decimal(18,2)	default 0.00,icc decimal(18,2) 	default 0.00,
			status char(2),	revisado char(2),
			ife char(2),	flag2credito smallint,
			grupo char(1),	num_pagos smallint,
			monto_pagos decimal(18,2),	linea_origen decimal(16) 	default 0.0000000000000000,
			linea_actual decimal(16) 	default 0.0000000000000000,		marca_os decimal(16) 	default 0.0000000000000000,
			tipo_facturacion char(1) default '',	act integer default null,
			atr integer default null,	dias_vencido integer default null,
			fecha_vencido date 	default null
		  );

			create index idx_numcredito_repcartactiva on sd_rep_cartera_activa (fecha,num_credito) ONLINE;
			
			UPDATE STATISTICS medium FOR TABLE sd_rep_cartera_activa;

	END IF;

	
	--*******************************************************
	--JAHJ: Ajuste para ser creada por unica ocasion con usr syscred 11/02/2026
	-- con el fin de optimizar la lectura se eliminan los indices para crearlos antes de la descarga deinfo
	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_rep_cartactiva1' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN drop index idx_rep_cartactiva1;
	END IF;

	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_rep_cartactiva2' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN drop index idx_rep_cartactiva2;
	END IF;

	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'sd_repcartera_activa1' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN drop index sd_repcartera_activa1;
	END IF;
	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'sd_repcartera_activa2' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN drop index sd_repcartera_activa2;
	END IF;	
	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'sd_repcartera_activa3' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN drop index sd_repcartera_activa3;
	END IF;	
	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'sd_repcartera_activa4' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN drop index sd_repcartera_activa4;
	END IF;	
	
	UPDATE STATISTICS medium FOR TABLE sd_rep_cartera_activa;
	--*******************************************************
	--*******************************************************

    select valor into cPaso from bdicred:sd_param where cod_param = '079' and empresa = pEmpresa;

    select first 1 fecha into dFecha from bdicred:sd_rep_cartera_activa WHERE fecha > DATE(1);

    IF dFecha != dUltimoDiaMesAnterior THEN
        TRUNCATE TABLE sd_rep_cartera_activa;
	    UPDATE statistics medium FOR TABLE sd_rep_cartera_activa; -- RQI 21 373 18102024 JAHJ
    END IF;
    
IF cPaso = '1' THEN
    select  'CA' tipo_reporte, fecha, empresa, num_credito, numcte, sucursal, status_cred, fecha_apertura, num_producto
     from bdicred:sd_maecredcont 
     where fecha = dUltimoDiaMesAnterior 
       and num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
	   and empresa = pEmpresa 
       and campo_trab3 <> 'BAJA'
     into temp paso_maecredcont with no log; 

    CREATE INDEX idx_paso_maecredcont on paso_maecredcont (fecha, empresa, num_credito); 
    UPDATE statistics medium FOR TABLE paso_maecredcont;
    
	
    FOREACH WITH HOLD
        select a.tipo_reporte, a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'E1' then 'CREDITO ETAPA1' else
			  case when a.status_cred = 'E2' then 'CREDITO ETAPA2' else
			  case when a.status_cred = 'E3' then 'CREDITO ETAPA3' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, 
             a.sucursal,
             0 saldo_actual, 
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido, 
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_cierre, 
             i.mto_fin_ven_trasp meses_vencidos, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto, nvl(h.grupo,''),i.act
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto, cGrupo,cAct
         from paso_maecredcont a
              join bdicred:sd_maesdoscont i on i.fecha = a.fecha and i.empresa = a.empresa and i.num_credito = a.num_credito
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
              
            SELECT num_vencidos, dias_atraso --fecha_vencido, 
            INTO v_num_vencidos, v_dias_vencido --v_fecha_vencido, 
            FROM sd_indicador_cred
            WHERE num_credito=cNum_Credito;
			
			select fecha_vencto
			into v_fecha_vencido
			from bdicred:sd_maecredanexo
			where num_credito=cNum_Credito;	
				
           
           BEGIN WORK;
               insert into bdicred:sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo, flag2credito, grupo, num_pagos, monto_pagos,linea_origen,linea_actual,marca_os,tipo_facturacion, dias_vencido, atr, act, fecha_vencido)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cMotivo, sFlag2creditoicc, cGrupo, iNumPagos, dMontoPagos,dLineaOrigen,dLineaActual,iMarcaOS,cTipoFac,
                  v_dias_vencido, cAtr, cAct, v_fecha_vencido);
          COMMIT WORK;
    
    END FOREACH;
	---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
	
	select 'CA' tipo_reporte, fecha, empresa, num_credito, numcte, sucursal, status_cred, fecha_apertura, num_producto
     from bdicred:sd_maecredcontcrd
     where fecha = dUltimoDiaMesAnterior and empresa = pEmpresa 
       and num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
       and campo_trab3 <> 'BAJA'
	   and num_producto ='6900'
     into temp paso_maecredcontcrd with no log; 

    CREATE INDEX idx_paso_maecredcontcrd on paso_maecredcontcrd (fecha, empresa, num_credito); 
    UPDATE statistics medium FOR TABLE paso_maecredcontcrd;
	
	
	
	 FOREACH WITH HOLD
        select a.tipo_reporte, a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
			  case when a.status_cred = 'E1' then 'CREDITO ETAPA1' else
			  case when a.status_cred = 'E2' then 'CREDITO ETAPA2' else
			  case when a.status_cred = 'E3' then 'CREDITO ETAPA3' else			  
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, 
             a.sucursal,
             0 saldo_actual, 
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido, 
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_cierre, 
             i.mto_fin_ven_trasp meses_vencidos, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto, h.grupo, i.atr
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto, cGrupo, cAtr
         from paso_maecredcontcrd a
              join bdicred:sd_maesdoscontcrd i on i.fecha = a.fecha and i.empresa = a.empresa and i.num_credito = a.num_credito
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
              
            SELECT num_vencidos_ch, dias_atraso --fecha_vencido, 
            INTO v_num_vencidos, v_dias_vencido --v_fecha_vencido, 
            FROM sd_indicador_cred_crd
            WHERE num_credito=cNum_Credito;
			
			select fecha_vencto
			into v_fecha_vencido
			from bdicred:sd_maecredanexocrd
			where num_credito=cNum_Credito;
           
           BEGIN WORK;
               insert into bdicred:sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo, flag2credito, grupo, num_pagos, monto_pagos,dias_vencido, atr, act, fecha_vencido)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cMotivo, sFlag2creditoicc, cGrupo, iNumPagos, dMontoPagos,v_dias_vencido, cAtr, cAct, v_fecha_vencido);
          COMMIT WORK;
    
    END FOREACH;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='2'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '2';
END IF;

IF cPaso = '2' THEN
    FOREACH WITH HOLD
        select 'CV' tipo_reporte,a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
			  case when a.status_cred = 'E1' then 'CREDITO ETAPA1' else
			  case when a.status_cred = 'E2' then 'CREDITO ETAPA2' else
			  case when a.status_cred = 'E3' then 'CREDITO ETAPA3' else			  
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, a.sucursal,
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_actual,
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido,
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 0 saldo_cierre,
             i.mto_fin_ven_trasp meses_vencidos, --j.num_tarjeta, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto, i.act
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto, cAct
         from bdicred:sd_maecred_vendida a
              join bdicred:sd_maesdos_vendida i on (a.fecha = i.fecha and a.empresa = i.empresa and a.num_credito = i.num_credito)
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
        where a.fecha between dPrimerDiaMes and dUltimoDiaMesAnterior and a.empresa = pEmpresa and a.num_credito>=''
          and a.num_credito in (select num_credito from bdicred:"informix".sd_maecred where empresa=pEmpresa and num_credito=a.num_credito and status_cred='CV') 
          and a.num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
          
          /*SELECT fecha_vencido, num_vencidos, dias_atraso
            INTO v_fecha_vencido, v_num_vencidos, v_dias_vencido
            FROM sd_indicador_cred
            WHERE num_credito=cNum_Credito;*/
			
			
			SELECT num_vencidos, dias_atraso --fecha_vencido, 
            INTO v_num_vencidos, v_dias_vencido --v_fecha_vencido, 
            FROM sd_indicador_cred
            WHERE num_credito=cNum_Credito;
			
			select fecha_vencto
			into v_fecha_vencido
			from bdicred:sd_maecredanexo
			where num_credito=cNum_Credito;	
			
			
          BEGIN WORK;
               insert into bdicred:sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo, dias_vencido, atr, act, fecha_vencido)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia,cMotivo,v_dias_vencido, cAtr, cAct, v_fecha_vencido);
          COMMIT WORK;
  
    END FOREACH;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='3'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '3';
END IF;

IF cPaso = '3' THEN

    UPDATE statistics medium FOR TABLE bdicred:sd_rep_cartera_activa;

    FOREACH WITH HOLD

--        select {+INDEX(bdicred:sd_rep_cartera_activa sd_repcartera_activa1)} tipo_reporte, numcte, num_credito 
        select tipo_reporte, numcte, num_credito 
          INTO cTipoReporte, cNumCte, cNum_Credito  
	        from bdicred:sd_rep_cartera_activa 
           where fecha = dUltimoDiaMesAnterior
             and (sexo is null or sexo = '')
         
         select nvl(a.correo_elec,'')  into cEmail 
           from bdinteg:si_correos a
          where a.empresa = pEmpresa
            and a.numcte = cNumCte
            and a.secuencia = (select max(secuencia) from bdinteg:si_correos where empresa = a.empresa and numcte = a.numcte); 

         select c.fecha_nac, b.rfc, (case when c.sexo = 'M' then 'MASCULINO' else 'FEMENINO' end) sexo, 
               (case when c.estado_civil = 'C' then 'Casado' else
                case when c.estado_civil = 'D' then 'Divorciado' else
                case when c.estado_civil = 'S' then 'Soltero' else
                case when c.estado_civil = 'U' then 'Union Libre' else 'Viudo' end end end end) estado_civil,
                b.numcte_ref
             into dFecha_Nac, cRfc, cSexo, cEstado_Civil, cNumCte_Ref
            from bdinteg:si_cliente b 
            left outer join bdinteg:si_ctepf c on (c.numcte = b.numcte)
            where b.numcte = cNumCte;

         select a.num_tarjeta into cNum_Tarjeta
           from bdicred:sd_tarjeta a
          where a.empresa = pEmpresa 
            and a.num_credito = cNum_Credito
            and a.tipo_tarjeta = 'T' and secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
    	                                                 where empresa = a.empresa and num_credito = a.num_credito and tipo_tarjeta = 'T');

         select limit 1 d1.estado, e.nombre, d1.numerociudad CdCpl, catcd.nombreciudad NomCdCpl, d1.ciudad NumCdBcpl,cds.nombre NomCdBcpl,d1.numerocolonia, g.municipiozona,
                nvl(tel1.telefono,''), nvl(tel2.telefono,''), nvl(tel3.telefono,''), nvl(tel3.extension,'')
           into cNumeroEstado, cNombreEstado, sNumeroCiudadCpl, cNombreCiudadCpl, sNumeroCiudad, cNombreCiudad, iNumeroColonia,
                cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension 
           from bdinteg:si_direcciones_actual d1 
                left outer join bdinteg:si_direcciones_actual d2 on (d2.numcte = d1.numcte and d2.tipo_dir = '2')
                left outer join bdinteg:si_estados e on (e.estado = d1.estado)
                left outer join bdinteg:si_catciudades catcd on (catcd.numerociudad = d1.numerociudad )
                left outer join bdinteg:si_ciudades cds on (cds.estado = d1.estado and cds.ciudad_coppel = d1.numerociudad and cds.ciudad = d1.ciudad)
                left outer join bdinteg:si_catzonas g on (g.numerociudad = d1.numerociudad and g.numerocolonia = d1.numerocolonia)
                Left outer join bdinteg:si_telefonos_actual tel1 on tel1.numcte= d1.numcte 
                     and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 1 and cofetel ='V')
                     and tel1.tipo_tel = 1 and tel1.cofetel ='V'
                left outer join bdinteg:si_telefonos_actual tel2 on tel2.numcte= d1.numcte 
                     and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 2 and cofetel ='V')
                     and tel2.tipo_tel = 2 and tel2.cofetel ='V'
                left outer join bdinteg:si_telefonos_actual tel3 on tel3.numcte= d1.numcte 
                     and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 3 and cofetel ='V')
                     and tel3.tipo_tel = 3 and tel3.cofetel ='V'    
          where d1.numcte = cNumCte
            and d1.tipo_dir = '1';
 /*
     select fecha_ult_pago,fecha_vencto into dUltimo_pago,dUltimo_Vencido from bdicred:sd_maecredanexo where empresa = pEmpresa and num_credito = cNum_Credito ;

     if dUltimo_pago is null then let dUltimo_pago = ''; end if;
     if dUltimo_Vencido is null then let dUltimo_Vencido = ''; end if;
 */
    -- obtener la ocupacion actual
         select sel.descripcion into cTiempo_Ocupacion_Act from bdisolic:ss_detalle_scoring  dsc 
             inner join bdisolic:ss_scoring_grupo sgr on sgr.empresa=dsc.empresa and sgr.grupo=dsc.grupo and sgr.seccion=dsc.seccion
             inner join bdisolic:ss_scoring_element sel on sel.empresa=dsc.empresa and sel.grupo=dsc.grupo and sel.elemento=dsc.elemento 
                        and sel.seccion=dsc.seccion
          where dsc.empresa = pEmpresa and dsc.grupo = '8' and dsc.seccion = '2' and dsc.num_solicitud = cNum_Credito 
            and sel.elemento = (select max(elemento) 
                                  from bdisolic:ss_detalle_scoring 
                                 where empresa= dsc.empresa and grupo = dsc.grupo and seccion = dsc.seccion and num_solicitud = dsc.num_solicitud); 
/*
-- obtener la ultima disposicion
    select {+INDEX(bdicred:sd_movhis inx_movhis)} nvl(max(fecha_mov),dFecha_Apertura) into dUltima_Disposicion 
      from bdicred:sd_movhis 
     where empresa = pEmpresa 
       AND fecha_mov >= dFecha_Apertura 
       AND fecha_mov <= dUltimoDiaMesAnterior
       and num_credito = cNum_Credito 
       and codigo_fun = '002' 
       and codigo_ref in (50,60,30,40,41,42,61,62,63,64)
       and reversado = 'N';
*/
		---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
		IF SUBSTR(cNum_Credito,1,2) = '69' THEN
			let dUltDisp_atm = ''; 
			let dUltDisp_pos = ''; 
			let dUltDisp_vnt = ''; 
			let dUltimo_pago = ''; 
			let dUltimo_Vencido = ''; 
		ELSE
         SELECT nvl(atm_disp_fecha_h,''), nvl(pos_disp_fecha_h,''), nvl(vnt_disp_fecha_h,''), nvl(fecha_ultimo_pago_h,''), 
               nvl(fecha_vencido,'')
          INTO dUltDisp_atm, dUltDisp_pos, dUltDisp_vnt, dUltimo_pago, dUltimo_Vencido
          FROM bdicred:sd_indicador_cred
         WHERE empresa = pEmpresa 
           AND num_credito = cNum_Credito;
		END IF;
		
        if dUltDisp_atm is null then let dUltDisp_atm = ''; end if;
        if dUltDisp_pos is null then let dUltDisp_pos = ''; end if;
        if dUltDisp_vnt is null then let dUltDisp_vnt = ''; end if;
        if dUltimo_pago is null then let dUltimo_pago = ''; end if;
        if dUltimo_Vencido is null then let dUltimo_Vencido = ''; end if;
       
        IF (dUltDisp_atm > dUltDisp_pos) THEN
            IF (dUltDisp_atm >= dUltDisp_vnt) THEN
               LET dUltima_Disposicion = dUltDisp_atm;
            ELSE
               LET dUltima_Disposicion = dUltDisp_vnt;
            END IF;
        ELIF (dUltDisp_atm = dUltDisp_pos) THEN    
            IF (dUltDisp_pos >= dUltDisp_vnt) THEN
                LET dUltima_Disposicion = dUltDisp_pos;
            ELSE
                LET dUltima_Disposicion = dUltDisp_vnt;
            END IF;
        END IF;


    -- obtener ultimo pago
        if(dUltima_Disposicion > dUltimo_pago) then
            let dUltimo_Movimiento = dUltima_Disposicion;
            let cTipo_Ult_Mov = '002';
        elif (dUltimo_pago > dUltima_Disposicion) then
            let dUltimo_Movimiento = dUltimo_pago;
            let cTipo_Ult_Mov = '052';
        elif(dUltima_Disposicion = dUltimo_pago) then
            let dUltimo_Movimiento = dUltima_Disposicion;
            let cTipo_Ult_Mov = '002';
        end if;
		
	-- obtener causa solicitud
		
		select limit 1 nvl(a.causa_solicitud,'') into cMotivo
		from bdisolic:ss_autorizacion a
		where a.empresa = pEmpresa
		and a.num_solicitud = cNum_Credito
		and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = cNum_Credito and status_solicitud = 'AT')
		and a.status_solicitud = 'AT';
			
	 ---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
		SELECT
				nvl(SUM(decode(seccion, '1', nvl(evaluacion,0), 0)),0) AS seccion1,
				nvl(SUM(decode(seccion, '2', nvl(evaluacion,0), 0)),0) AS seccion2,
				nvl(SUM(decode(seccion, '3', nvl(evaluacion,0), 0)),0) AS seccion3,
				nvl(SUM(decode(seccion, '4', nvl(evaluacion,0), 0)),0) AS seccion4,
				nvl(SUM(decode(seccion, '5', nvl(evaluacion,0), 0)),0) AS seccion5                        
		INTO dEvaluacion1, dEvaluacion2, dEvaluacion3, dEvaluacion4,dEvaluacion5
		FROM bdisolic:ss_resumen_scoring
		WHERE empresa= '001'
		AND seccion in ('1', '2','3', '4','5')
		AND num_solicitud = cNum_Credito;
		
					-- MODIFICACION REPORTE RQM 09 459-2 (INICIO)
			SELECT status_ini
			 INTO cStatus_Ini
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 
			IF cStatus_Ini IS NULL THEN
			   LET cStatus_Ini = ' ';
			END IF;
			
			SELECT CASE WHEN revisado = 'N' THEN 'C'ELSE 'R' END
			 INTO cRevisado
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 
			IF cRevisado IS NULL THEN
			   LET cRevisado = ' ';
			END IF;
			
			SELECT COUNT(*) 
			 INTO cIdbox
			 FROM bdisolic:"informix".ss_solicitudes_mc a
			 RIGHT OUTER JOIN bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 			
			IF cIdbox >= 1 THEN 
			   LET cIFE = 'Si';
			ELSE   
			   LET cIFE = 'No'; 
			END IF;	
			-- MODIFICACION REPORTE RQM 09 459-2 (FIN)				
		
			SELECT nvl(flag2creditoicc,0) INTO sFlag2creditoicc 
			FROM bdisolic:ss_revision_determinacion
			WHERE empresa = '001'
			  AND num_solicitud = cNum_Credito;

         SELECT nvl(num_pagos,0),nvl(monto_pagos,0)
          INTO iNumPagos, dMontoPagos
          FROM bdicred:sd_indicador_cred_hist
         WHERE empresa = pEmpresa 
		   AND fecha = dUltimoDiaMesAnterior
           AND num_credito = cNum_Credito;
		   
			-- RQM 09 476 - 2 ADENDUM 
			SELECT monto_solicitado INTO dLineaOrigen FROM bdisolic:ss_solicitudes	
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito; 

			SELECT monto_otorgado INTO dLineaActual FROM bdicred:sd_maesdos 
			WHERE empresa=pEmpresa AND num_credito=cNum_Credito; 
			
			SELECT COUNT(num_solicitud) INTO iSolicitudOS FROM bdisolic:ss_solicitud_os
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito;
			
			SELECT COUNT(num_solicitud) INTO iSolicitudOS_Gpo5 FROM bdisolic:bitacora_os_gpo5 
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito;
			  
			IF iSolicitudOS > 0 THEN 
			
				LET iMarcaOS = 1;		-- ADD
				
				SELECT COUNT(num_solicitud) INTO iSolicitudOS_P FROM bdisolic:ss_solicitud_os
				WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito AND status='P';
				
				IF iSolicitudOS_P > 0 THEN
					LET iMarcaOS = 1;
				ELSE
					IF iSolicitudOS_Gpo5 >0 THEN
						LET iMarcaOS = 2;
					ELSE
						LET iMarcaOS = 0;
					END IF;	
				END IF;
			ELSE	
				IF iSolicitudOS_Gpo5 >0 THEN
					LET iMarcaOS = 2;
				ELSE
					LET iMarcaOS = 0;
				END IF;	
			END IF;
			
			if dUltDisp_atm is null or dUltDisp_atm = '' then let dUltDisp_atm = date(1); end if;
			if dUltDisp_pos is null or dUltDisp_pos = '' then let dUltDisp_pos = date(1); end if;
			if dUltDisp_vnt is null or dUltDisp_vnt = '' then let dUltDisp_vnt = date(1); end if;
			
			--	Indicaremos "D" si el cliente durante el mes realizÃ?Ã?Ã?ÃÂ³ SOLO disposiciones en efectivo.((ATM OR VNT)OR (ATM AND VNT))AND NOT POS
			IF ((dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) OR  (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) OR
				 ((dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior)))AND	
				 (dUltDisp_pos<dPrimerDiaMes OR dUltDisp_pos>dUltimoDiaMesAnterior)THEN
					LET cTipoFac = 'D';
			-- Indicaremos "C" si el cliente durante el mes realizÃ?Ã?Ã?ÃÂ³ SOLO compras en terminal punto de venta.
			--	((POS)AND(ATM<PriDiaMes OR ATM>UltDiaMes) or AMBAS)AND (VNT<PriDiaMes OR VNT>UltDiaMes) or AMBAS)
			ELIF (dUltDisp_pos BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND 
				 (dUltDisp_atm<dPrimerDiaMes OR dUltDisp_atm>dUltimoDiaMesAnterior) AND 
				 (dUltDisp_vnt<dPrimerDiaMes OR dUltDisp_vnt>dUltimoDiaMesAnterior ) THEN
					LET cTipoFac = 'C';
			--	Indicaremos "M" si el cliente durante el mes realizÃ?Ã?Ã?ÃÂ³ compras y disposiciones (cajero y/o ventanilla) en efectivo.(ATM AND VNT AND POS)
			ELIF (dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND
				   (dUltDisp_pos BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) THEN
						LET cTipoFac = 'M';
			ELSE 
				LET cTipoFac = ' ';
			END IF;
						
        BEGIN WORK;
            UPDATE bdicred:sd_rep_cartera_activa
               SET  fecha_nac = dFecha_Nac, rfc = cRfc, sexo = cSexo, estado_civil = cEstado_Civil, email = cEmail, numeroestado = cNumeroEstado, 
                    nombreestado = cNombreEstado, numerociudad=sNumeroCiudad, nombreciudad=cNombreCiudad, numciudad_cpl=sNumeroCiudadCpl, nombreciudad_cpl=cNombreCiudadCpl, numerocolonia=iNumeroColonia, 
                    municipiozona = cMunicipioZona, telefono1 = cTelefono1, telefono2 = cTelefono2, telefono3 = cTelefono3, extension = cExtension, 
                    tiempo_ocupacion_act = NVL(cTiempo_Ocupacion_Act,''), ultima_disposicion = dUltima_Disposicion, ultimo_movimiento = dUltimo_Movimiento,
                    ultimo_vencido = dUltimo_Vencido, tipo_ult_mov = cTipo_Ult_Mov, num_tarjeta = NVL(cNum_Tarjeta,''), numcte_ref = cNumCte_Ref, motivo = NVL(cMotivo  ,''),
					bscore = dEvaluacion1, scoreprop= dEvaluacion2, ficoscore = dEvaluacion3, ficoextended = dEvaluacion4,icc =dEvaluacion5,
					status = cStatus_Ini, revisado = cRevisado, ife = cIFE, num_pagos = nvl(iNumPagos,0), monto_pagos = nvl(dMontoPagos,0), flag2credito = nvl(sFlag2creditoicc,0),
					num_pagos = nvl(iNumPagos,0), monto_pagos = nvl(dMontoPagos,0),linea_origen=dLineaOrigen,linea_actual=dLineaActual,marca_os=iMarcaOS,tipo_facturacion=nvl(cTipoFac,'')
             WHERE  num_credito = cNum_Credito ;
        COMMIT WORK;
    	
    
        let dFecha_Nac = '';
        let cRfc  = '';
        let cSexo = '';
        let cEstado_Civil = '';
        let cEmail = '';
        let cNumeroEstado = '';
        let cNombreEstado = '';
        let sNumeroCiudad = '';
        let cNombreCiudad  = '';
        let sNumeroCiudadCpl=''; let cNombreCiudadCpl='';
        let iNumeroColonia = '';
        let cMunicipioZona = '';
        let cTelefono1 = '';
        let cTelefono2 = '';
        let cTelefono3 = '';
        let cExtension = '';
        let cTiempo_Ocupacion_Act  = '';
        let dUltima_Disposicion  = '';
        let dUltimo_Movimiento = '';
        let dUltimo_Vencido = '';
        let cTipo_Ult_Mov = '';
        let cNum_Tarjeta  = '';
        let cNumCte_Ref  = '';
		let cMotivo = '';
		let sFlag2creditoicc = 0;
        let contador_commit = contador_commit  + 1;
        let actualiza_esta = actualiza_esta + 1;
		let dLineaOrigen=0;
		let dLineaActual=0;
		let iMarcaOS=0;
   end foreach;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='4'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '4';
END IF;


IF cPaso = '4' THEN
			
	--*****************************************************************************			
	-- JAHJ RQI 21 425  Se crean con el fin de optimizar la lectura se crean los indices para crearlos antes de la descarga deinfo
	IF NOT EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_rep_cartactiva1' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN create index idx_rep_cartactiva1 on sd_rep_cartera_activa(numcte) ONLINE;
	END IF;

	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'idx_rep_cartactiva2' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN create index idx_rep_cartactiva2 on sd_rep_cartera_activa(tipo_reporte) ONLINE ;
	END IF;

	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'sd_repcartera_activa1' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN create index sd_repcartera_activa1 on sd_rep_cartera_activa(fecha) ONLINE;
	END IF;
	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'sd_repcartera_activa2' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN create index sd_repcartera_activa2 on sd_rep_cartera_activa(tipo_reporte,saldo_cierre) ONLINE;
	END IF;	
	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'sd_repcartera_activa3' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN create index sd_repcartera_activa3 on sd_rep_cartera_activa(num_credito) ONLINE;
	END IF;	
	IF EXISTS(SELECT idxname 
				FROM sysindices 
				WHERE idxname = 'sd_repcartera_activa4' AND tabid = (SELECT tabid 
																	FROM systables WHERE tabname = 'sd_rep_cartera_activa'))
		THEN create index sd_repcartera_activa4 on sd_rep_cartera_activa(sexo) ONLINE;
	END IF;	
	--*********************************************************************************
	
   let sCommit = 0;
--Reporte de cartera activa
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_cartera_activa_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_cartera_activa_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select A.num_producto, A.numcte, A.num_credito, A.estatus_credito, A.hit, A.numeroestado, A.nombreestado, ' ||
       ' A.numciudad_cpl, A.nombreciudad_cpl, A.numerociudad, A.nombreciudad, ' ||
       ' A.sucursal, A.saldo_actual, A.saldo_vencido, A.sdo_capital, A.monto_vencido, A.mto_venc_trasp, A.cap_tras_no_venci, ' ||
       ' A.saldo_cierre, A.meses_vencidos,A.dias_vencido, A.atr, A.act, to_char( A.fecha_vencido,'''||'%d/%m/%Y'||''') fecha_vencido, A.fecha_apertura, A.situacion_pago, A.meses_historia, A.motivo, ' ||  -- se ajusto fecha a dd/mm/yyyy
	   ' case when (select excluye_validacion from bdisolic:'''||'informix'||'''.ss_revision_determinacion where empresa = '''||'001'||''' and num_solicitud = A.num_credito) ' || 
	   ' = 1 then '''||'Excepcion de validacion telefonica por puntaje'||'''  else '''||' '||''' end case ,' ||	 
	   ' A.bscore ,A.scoreprop, A.ficoscore , A.ficoextended , A.icc,status , A.revisado, A.ife, A.flag2credito, A.grupo, A.num_pagos, A.monto_pagos, ' ||	
	   ' A.linea_origen,A.linea_actual,A.marca_os,A.tipo_facturacion,A.ultima_disposicion, B.evaluacion as score_coppel, C.puntualidad'||
       ' from sd_rep_cartera_activa A'||
	   ' LEFT JOIN bdisolic:ss_resumen_scoring B ON B.num_solicitud = A.num_credito AND B.seccion = '''||'6'||'''  ' ||
	   ' LEFT JOIN bdisolic:ss_resum_scor_fin C ON C.num_solicitud = A.num_credito'||
	   ' where A.tipo_reporte = '''||'CA'||''' and A.saldo_cierre > 0;"' ||	 
       ' > /resplogifx/archivoscartera/query_cartera_activa.sql';
       /*' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia, flag2credito, grupo, num_pagos, monto_pagos from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre > 0;"' ||
       ' > /resplogifx/archivoscartera/query_cartera_activa.sql'; */
--     ' > query_cartera_activa.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_cartera_activa.sql';
--  let cSql = 'dbaccess bdicred query_cartera_activa.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_cartera_activa.sql';
--  LET cSql = 'rm query_cartera_activa.sql';
    SYSTEM cSql;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='5'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '5';
END IF;

IF cPaso = '5' THEN
--Reporte de creditos inactivos o con saldo a favor
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_clientes_inactivos_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_clientes_inactivos_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre <= 0;"' ||
       ' > /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--     ' > query_clientes_inactivos.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--  let cSql = 'dbaccess bdicred query_clientes_inactivos.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--  LET cSql = 'rm query_clientes_inactivos.sql';
    SYSTEM cSql;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='6'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '6';
END IF;

IF cPaso = '6' THEN
--Reporte de cartera vendida
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_cartera_vendida'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_cartera_vendida'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia from sd_rep_cartera_activa where tipo_reporte ='''||'CV'||''';"' ||
       ' > /resplogifx/archivoscartera/query_cartera_vendida.sql';
--     ' > query_cartera_vendida.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_cartera_vendida.sql';
--  let cSql = 'dbaccess bdicred query_cartera_vendida.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_cartera_vendida.sql';
--  LET cSql = 'rm query_cartera_vendida.sql';
    SYSTEM cSql;
END IF;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='1'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
--    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora3 from sysmaster:sysshmvals;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '03') returning cCod_ret2;
    return cCodRet,cMensajeRet;
end;
end procedure;