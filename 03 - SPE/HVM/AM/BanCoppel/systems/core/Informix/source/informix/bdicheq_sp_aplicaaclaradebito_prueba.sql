CREATE PROCEDURE "informix".sp_aplicaaclaradebito_prueba(pEmpresa CHAR(3), pFolioSuac CHAR(10), pDictamen CHAR(2), pCalculaInteres CHAR(1), pEmpleadoAut CHAR (8))
RETURNING CHAR(3);

    DEFINE cCodRet              CHAR(3);	--> ok
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;

    DEFINE CnumCuenta           CHAR(20);
	DEFINE Tproducto            INTEGER;
    DEFINE CnumTarjeta          CHAR(20);
    DEFINE CmontoAcla           DECIMAL(18,2);
    DEFINE Csucursal            CHAR(4);
    DEFINE pfecha               DATE;		--> ok

-->> Variables para Comisiones (NP, CM) / Intereses

	DEFINE Ctrans_no_procede    	CHAR(04); 		--> ok Comisiones
    DEFINE Mcosto               	DECIMAL(18,2); 	--> ok Comisiones
    DEFINE Ifky_aclaracion      	INTEGER; 		--> ok Comisiones
    DEFINE Ifky_producto        	INTEGER; 		--> ok Comisiones
    DEFINE Ipky_tipo_movimiento 	INTEGER; 		--> ok Comisiones
	DEFINE FIpky_tipo_movimiento 	INTEGER; 		-- determinar el pky de aclaracion
    DEFINE v_pky_tipo_movimiento 	INTEGER; 		--> ok Comisiones
	DEFINE Ipky_movimiento      	INTEGER; 		--> ok Comisiones
	DEFINE v_numero_transaccion 	CHAR(04);		--> ok Comisiones
	DEFINE v_nombre_origen    	    CHAR(50); 		--> ok Comisiones
	DEFINE Es_Nacional    	        CHAR(1); 		--> ok Comisiones
	DEFINE v_OrigenEvento			CHAR(2);		--> ok Comisiones (Temporal)
	DEFINE v_NumTarjeta				CHAR(20);		--> ok Comisiones (Temporal)
	DEFINE v_FolioSuc				CHAR(20);		--> ok Comisiones (Temporal)
	DEFINE Ifky_tipo_transaccion	INTEGER;		--> ok Intereses
	DEFINE Ifechahora				DATE;			--> ok Intereses
	DEFINE IIntereses				MONEY (14, 2);   --> ok Intereses
-->> Variables para Codigos de Retorno
    DEFINE DCodret_a            CHAR(5);		--> ok Retornos.
	DEFINE DCodret_c            CHAR(5);		--> ok Retornos.
	DEFINE DTranret_c           CHAR(5);		--> ok Retornos.
	DEFINE DFechoy_c            DATE;			--> ok Retornos.
	DEFINE DVsdodisp_c          MONEY(14,2);	--> ok Retornos.
	DEFINE DVmontoret_c         MONEY(14,2);	--> ok Retornos.

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
    DEFINE CMensaje             CHAR(80);
    DEFINE CSecuencia           INTEGER;
    DEFINE Ctrannopro           CHAR(04);
    DEFINE Ctransinauto         CHAR(04);
    DEFINE Ctranpro             CHAR(04);
    DEFINE Ctranauto            CHAR(04);
    DEFINE Ccargo               SMALLINT;
    DEFINE ptranaplica          CHAR(04);
	DEFINE wBegin               CHAR(1);
    DEFINE v_contador           SMALLINT;
    DEFINE pFolioSuacSUC        CHAR(16);
    DEFINE v_fecha_folio        CHAR(10);
	DEFINE CSecuencia_acl_mov   INTEGER;	--> ok
	DEFINE fecha_captura		DATE;
    DEFINE v_contador_0			INTEGER;
	DEFINE v_contador_1			INTEGER;
	DEFINE v_contador_2			INTEGER;
	DEFINE v_contador_total		INTEGER;

--> Variables para duplicidad de movimientos
	DEFINE v_fky_padre          INTEGER;	-- ok Mov_Duplicados
	DEFINE v_monto				DECIMAL(18,2);
	DEFINE v_montoprocedente    DECIMAL(18,2);
	DEFINE v_fky_tipo_evento    INTEGER;
	DEFINE v_duplicado          SMALLINT;

--> Variable para control de movimientos a afectar
	DEFINE v_tipo_fky_padre     INTEGER;

-->> Variabla para validar intereses en 0
	DEFINE v_intereses_0		SMALLINT;

/* Retornos saldo*/
    DEFINE vcodret                 CHAR(5);
    DEFINE vsdodisp                MONEY(16,2);
    DEFINE vstatuscta              CHAR(1);

--> Variable para almacenar nombre de un SP || JLM - 02/06/2022	
	DEFINE v_nombre_sp            CHAR(20);
	DEFINE horaActual             DATETIME YEAR TO FRACTION(5);
	DEFINE v_usuario			  CHAR(8);

SET DEBUG FILE TO "/RESPALDOSNEW/lzapata/paso/sps"||"_"||""||TRIM(pFolioSuac)||""||".out";
   --SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_aplicaaclaradebito_des"||"_N_"||""||TRIM(pFolioSuac)||""||"_35.out"; --> TRACE DESDE APP
   TRACE ON;


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

   LET cCodRet      		= '000';
   LET pfechaMov    		= DATE(1);
   LET pfechaAcl    		= DATE(1);
   LET pfechaAux    		= DATE(1);
   LET pfecha       		= DATE(1);

-->> Variables para Comisiones (NP, CM) / Intereses

   LET Ctrans_no_procede 		= '';

   LET Mcosto       			= 0;
   LET Ifky_aclaracion 			= 0;
   LET Ifky_producto 			= 0;
   LET Ipky_tipo_movimiento 	= 0;
   LET v_pky_tipo_movimiento 	= 0;
   LET Ipky_movimiento 			= 0;
   LET FIpky_tipo_movimiento	= 0;
   LET v_numero_transaccion 	= '';
   LET Es_Nacional				= '';
   LET v_nombre_origen 			= '';
   LET v_OrigenEvento			= '';
   LET v_NumTarjeta				= '';
   LET v_FolioSuc				= '';
   LET Ifky_tipo_transaccion	= 0;
   LET Ifechahora				= '';
   LET IIntereses				= 0;

-->> Variables para Codigos de Retorno
   LET DCodret_a    		= '';
   LET DCodret_c            = '';
   LET DTranret_c           = '';
   LET DFechoy_c            = '';
   LET DVsdodisp_c          = 0;
   LET DVmontoret_c         = 0;

   LET CnumCuenta  		    = '';
   LET Tproducto  		    = 0;
   LET CnumTarjeta  		= '';
   LET CmontoAcla   		= 0;
   LET Csucursal    		= '';
   LET pIntVig      		= 0;
   LET pIntVenc     		= 0;
   LET DiasPeri     		= 0;
   LET pIntBoni     		= 0;
   LET pIntCap      		= 0;
   LET pIvaCap      		= 0;

   LET CMensaje     		= '';
   LET CSecuencia   		= 0;
   LET Ctrannopro   		= '';
   LET Ctransinauto 		= '';
   LET Ctranpro     		= '';
   LET Ctranauto    		= '';
   LET Ccargo       		= 0;
   LET ptranaplica  		= '0000';

   LET wBegin 				= 'N';

   LET v_contador 			= 0;
   LET pFolioSuacSUC 		= '';
   LET v_fecha_folio 		= "";
   LET CSecuencia_acl_mov   = 0;

   LET fecha_captura	 =DATE(1);
   LET v_contador_0		 = 0;
   LET v_contador_1		 = 0;
   LET v_contador_2		 = 0;
   LET v_contador_total	 = 0;


--> Variables para duplicidad de movimientos
   LET v_fky_padre       = 0;
   LET v_monto           = 0;
   LET v_montoprocedente = 0;
   LET v_fky_tipo_evento = 0;
   LET v_duplicado 	     = 0;

--> Variable para control de movimientos a afectar
   LET v_tipo_fky_padre  = 0;
   
--> Variable para almacenar nombre de un SP || JLM - 02/06/2022   
   LET v_nombre_sp       = '';
   LET horaActual        = NULL;
   LET v_usuario 		 = 'informix';

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Actualizaciones
   -- Mod			Prod			VersiÃ³n		Usr		Detalle
   -- 06/02/2013 	19/03/2013,		V0, 		SADVC,  CreaciÃ³n de lÃ³gica para afectaciones de CaptaciÃ³n.
   -- 06/02/2013, 	19/03/2013,    	V1, 		SADVC,  Agregar lÃ³gica para inversiones
   -- 20/03/2013, 	21/03/2013,		V2, 		SADVC, 	Agregar validaciÃ³n para comisiones sin transacciÃ³n flujo NP, CM
   -- 22/03/2013,	26/03/2013,		V3, 		SADVC,  Agregar validaciÃ³n para flujos AA, R, NP, no cargar montos no abonados
   -- 08/04/2013,	09/04/2013,		V4, 		SADVC,  Agregar validaciÃ³n para montos en cero y procede en 1 por empleados de ACL
   -- 16/04/2013,  	16/04/2013,		V5, 		SADVC,  ModificaciÃ³n envÃ­o de num_empleado que autoriza las afectaciones Entrega III, CNBV
   -- 19/10/2014,  	19/10/2014,		V6, 		VJMP,   Se realizan adaptaciones para Transfer, realizando condiciones para procesos de calculo de intereses

   -- Nota. Considerar selecciÃ³n de transacciÃ³n, cuando esten definidas las ristras contables correspondientes. (fky_tipo_movimiento = is not null --> fky_tipo_catalogo_transaccion)


-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar debug


   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   BEGIN WORK;

   IF pFolioSuac IS NULL OR pFolioSuac = '' THEN 			--> CodRet ok, pFolioSuac pentrada ok, cCodRet ok
      LET cCodRet='001';
      RETURN cCodRet;
   END IF;

  IF pDictamen IS NULL OR pDictamen = '' THEN				--> CodRet ok, pDictamen pentrada ok, cCodRet ok
      LET cCodRet='007';
      RETURN cCodRet;
   END IF;

   IF pCalculaInteres IS NULL OR pCalculaInteres = '' THEN	--> CodRet ok, pCalculaInteres pentrada ok, cCodRet ok
      LET cCodRet='008';
      RETURN cCodRet;
   END IF;

--> Consulta de Fechas DÃ©bito

	SELECT fecha_hoy
	  INTO pfecha   				--> ok
	  FROM bdicheq:sc_fechas
	 WHERE empresa = pEmpresa;



-- ***********************************************************************************************************************************************
-->> Flujo de aclaraciones: Abonar y Analizar, No Procede = Cargo de monto previamente Abonado + Cobro de comisiÃ³n.
-->> Flujo de aclaraciones: Abonar y Analizar, No Procede = Sin afectaciÃ³n + Cobro de comisiÃ³n.

	IF (pDictamen = 'NP') THEN

		------------------------------------------------- >> ValidaciÃ³n para creaciÃ³n de movimientos duplicados.

		SELECT fky_padre
		INTO v_fky_padre
		FROM bdiaclaracion:acl_movimiento
		WHERE duplicado = 1
		AND folio_csuac = pFolioSuac
		AND fky_padre is null;

		IF (v_fky_padre IS NULL) THEN

			FOREACH WITH hold
				-- >> Insertar movimientos duplicados.
				SELECT a.folio_csuac, a.monto, a.montoprocedente, b.trans_no_procede, a.fky_padre, a.fky_producto, a.fky_tipo_evento, a.fky_tipo_movimiento, a.fky_tipo_movimiento
				INTO
				pFolioSuac,          -- folio_csuac,  	   			--> Mismo que el padre -- ok
				v_monto,             -- monto, 						--> Mismo que el padre -- para afectaciÃ³n contable
				v_montoprocedente,   -- montoprocedente, 			--> Mismo que el padre -- Breviario cultural
				Ctrans_no_procede,   -- numero_transaccion, 		--> null -- Tran_no_procede para que haga la afectaciÃ³n con esa transacciÃ³n.
				Ipky_movimiento,     -- fky_padre,	 				--> pky del movimiento padre
				Ifky_producto,       -- fky_producto, 				--> Mismo que el padre
				v_fky_tipo_evento,   -- fky_tipo_evento, 			--> Mismo que el padre
				Ipky_tipo_movimiento, -- fky_tipo_movimiento, 		--> Mismo que el padre
				FIpky_tipo_movimiento
				FROM bdiaclaracion:acl_movimiento a, bdiaclaracion:acl_tipo_movimiento b
				WHERE b.pky_tipo_movimiento = a.fky_tipo_movimiento
				AND a.folio_csuac = pFolioSuac
				AND a.cargo = 0
				AND a.exitoso = 1
				-- AND a.procede = 1
				AND a.fecha_afectacion IS NOT NULL
				AND a.duplicado = 0
				--AND a.fky_tipo_movimiento <> 332 --> ValidaciÃ³n no duplicar intereses abonados

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
					-- pky_movimiento                         calculado     cargo  	cargo_ajuste		exitoso     fecha_afectacion     fecha_hora_e_global     fechahora     folio_csuac     folio_suc     identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia        referencia23             reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio     num_sucursal
					bdiaclaracion:MOVIMIENTO_SEQ.nextval,     0,            1,     null,	   			0,          null,                null,                   current,      pFolioSuac,     null,         null,                         null,      null,      v_monto,  v_montoprocedente,  1,            Ctrans_no_procede,     1,          '',               '',                      0,            CSecuencia_acl_mov, null,              Ipky_movimiento, Ifky_producto,   null,                      v_fky_tipo_evento,  Ipky_tipo_movimiento,   null,                             null,            "9250", null, 0, 0);

				END IF;

			END FOREACH;

		END IF;

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
				SELECT intercard:movimiento.esnacional
					INTO Es_Nacional
					FROM intercard:movimiento
					WHERE intercard:movimiento.secuenciaextendida=v_FolioSuc
					AND intercard:movimiento.numtarjeta=v_NumTarjeta;

				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
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
		-------------- >> Inserta movimiento de comisiÃ³n por Aclaracion NO Procedente

		IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
			LET Es_Nacional = 'V';
		END IF;


		SELECT d.trans_no_procede,
			CASE
				WHEN Es_Nacional = 'F' THEN 0
				WHEN Es_Nacional = 'V' THEN nvl(e.costo,0)
			END AS costo,
			a.fky_aclaracion, a.fky_producto, d.pky_tipo_movimiento, a.pky_movimiento
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
		AND d.fky_tipo_transaccion = 8
		AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
		AND duplicado = 0
		AND d.trans_no_procede IS NOT NULL -->> ValidaciÃ³n para comisiones sin transacciÃ³n flujo NP, CM
		AND folio_csuac = pFolioSuac;

		IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisiÃ³n desde tabla acl_tipo_Evento
		/* Se elimina referencia a tabla acl_tipo_movimiento, transacciÃ³n de no procedencia es fija y se define una trasacciÃ³n fija para comisiones de
		no procedencia, esto para no tener que repetir por cada uno de los Eventos creados, ya que las comisiones ahora son por evento RQM 06 315*/
		SELECT '0343',
			CASE
				WHEN Es_Nacional = 'F' THEN 0
				WHEN Es_Nacional = 'V' THEN nvl(b.costo,0)
			END AS costo,
			a.fky_aclaracion, a.fky_producto, '142', a.pky_movimiento
		INTO Ctrans_no_procede, Mcosto, Ifky_aclaracion, Ifky_producto, Ipky_tipo_movimiento, Ipky_movimiento
		FROM bdiaclaracion:acl_movimiento a,
			 bdiaclaracion:acl_tipo_evento b,
			 bdiaclaracion:acl_origen_evento c
		WHERE b.pky_tipo_evento = a.fky_tipo_evento
		AND c.pky_origen_evento = b.fky_origen_evento
		AND a.fky_padre IS NULL
		AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
		AND duplicado = 0
		AND a.fky_aclaracion IS NOT NULL
		AND folio_csuac = pFolioSuac;

		END IF;  -- comisiÃ³n desde acl_tipo_evento


			SELECT MAX (numero_transaccion)
			INTO v_numero_transaccion
			FROM bdiaclaracion:acl_movimiento
			WHERE folio_csuac = pFolioSuac
			AND numero_transaccion = Ctrans_no_procede;

			SELECT MAX (secuencia)
			INTO CSecuencia_acl_mov
			FROM bdiaclaracion:acl_movimiento
			WHERE folio_csuac = pFolioSuac;

			UPDATE bdiaclaracion:acl_movimiento -->> Valida que no existan movimientos como procedentes de forma erronea para que no sean cargados al cliente.
			SET procede = 0
		  WHERE (folio_csuac = pFolioSuac AND cargo = 0 AND (exitoso = 0 OR exitoso IS NULL))
			 OR (folio_csuac = pFolioSuac AND exitoso IS NULL AND fecha_afectacion IS NULL AND duplicado = 0); -->> 22/03/2013 ValidaciÃ³n para flujos AA, R, NP, no cargar montos no abonados

		IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la comisiÃ³n de debito, para no duplicarla 24/04/2012
			If Mcosto = '0' Then
				INSERT INTO bdiaclaracion:acl_movimiento
				-- pky_movimiento                            calculado     cargo   cargo_ajuste  exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal
				VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,       null,		0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     0,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250",null, 0, 0);
			Else
				INSERT INTO bdiaclaracion:acl_movimiento
				-- pky_movimiento                            calculado     cargo   cargo_ajuste  exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal
				VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,       null,	 	0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     1,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250", null, 0, 0);
			End If;
		END IF;

	END IF;

-->> ***************************************************************************************************************************************************** <<--

-->> Flujo de aclaraciones: Analizar, No Procede = Sin AfectaciÃ³n  --> Solo cobro de comisiÃ³n.


	IF (pDictamen = 'CM') THEN

	--------- >> Determina si el movimiento es Nacional o Internacional
		select tipo_movimiento INTO Es_Nacional
		   from bdiaclaracion:acl_aclaracion where folio_csuac = pFolioSuac;

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
				SELECT intercard:movimiento.esnacional
					INTO Es_Nacional
					FROM intercard:movimiento
					WHERE intercard:movimiento.secuenciaextendida=v_FolioSuc
					AND intercard:movimiento.numtarjeta=v_NumTarjeta;

				IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
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
	-------------- >> Inserta movimiento de comisiÃ³n por Aclaracion NO Procedente

		IF (Es_Nacional IS NULL OR Es_Nacional = '' OR Es_Nacional = 'N') THEN
			LET Es_Nacional = 'V';
		END IF;

		SELECT d.trans_no_procede,
			CASE
				WHEN Es_Nacional = 'F' THEN 0
				WHEN Es_Nacional = 'V' THEN nvl(e.costo,0)
			END AS costo,
			a.fky_aclaracion, a.fky_producto, d.pky_tipo_movimiento, a.pky_movimiento
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
		AND d.fky_tipo_transaccion = 8
		AND NVL(cargo,0) = CASE WHEN (exitoso is null) THEN 0 ELSE cargo END
		AND duplicado = 0
		AND d.trans_no_procede IS NOT NULL -->> ValidaciÃ³n para comisiones sin transacciÃ³n flujo NP, CM
		AND folio_csuac = pFolioSuac;

		IF	(Ipky_tipo_movimiento is null OR Ipky_tipo_movimiento='') THEN  -- Determinar la comisiÃ³n desde tabla acl_tipo_Evento
		/* Se elimina referencia a tabla acl_tipo_movimiento, transacciÃ³n de no procedencia es fija y se define una trasacciÃ³n fija para comisiones de
		no procedencia, esto para no tener que repetir por cada uno de los Eventos creados, ya que las comisiones ahora son por evento RQM 06 315*/
		SELECT '0343' as trans_no_procede,
			CASE
				WHEN Es_Nacional = 'F' THEN 0
				WHEN Es_Nacional = 'V' THEN nvl(b.costo,0)
			END AS costo,
			a.fky_aclaracion, a.fky_producto, '142' as pky_tipo_movimiento, a.pky_movimiento
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

			SELECT MAX (numero_transaccion)
			INTO v_numero_transaccion
			FROM bdiaclaracion:acl_movimiento
			WHERE folio_csuac = pFolioSuac
			AND numero_transaccion = Ctrans_no_procede;

			SELECT MAX (secuencia)
			INTO CSecuencia_acl_mov
			FROM bdiaclaracion:acl_movimiento
			WHERE folio_csuac = pFolioSuac;

			UPDATE bdiaclaracion:acl_movimiento -->> Valida que no existan movimientos como procedentes de forma erronea para que no sean cargados al cliente.
			SET procede = 0
		  WHERE (folio_csuac = pFolioSuac AND cargo = 0 AND (exitoso = 0 OR exitoso IS NULL))
			 OR (folio_csuac = pFolioSuac AND exitoso IS NULL AND fecha_afectacion IS NULL AND duplicado = 0); -->> 22/03/2013 ValidaciÃ³n para flujos AA, R, NP, no cargar montos no abonados

		IF ( v_numero_transaccion IS NULL) THEN  -->> Valida si ya se ingreso la ComisiÃ³n de Debito, para no duplicarla.
			If Mcosto = '0' Then
				INSERT INTO bdiaclaracion:acl_movimiento
				-- pky_movimiento                            calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal
				VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,        null,			0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     0,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250", null, 0, 0);
			Else
				INSERT INTO bdiaclaracion:acl_movimiento
				-- pky_movimiento                            calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto     montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal
				VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 0,            1,        null,			0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      Mcosto,   Mcosto,             0,            Ctrans_no_procede,     1,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      1,                  Ipky_tipo_movimiento,   null,                             null,          "9250", null, 0, 0);			End If;
		END IF;

	END IF;

-->> ***************************************************************************************************************************************************** <<--

-->> Proceso para Calculo de Intereses Debito

	--> Consulta de InversiÃ³n.

	SELECT fky_tipo_producto
	  INTO Tproducto
	  FROM bdiaclaracion:acl_producto a, bdiaclaracion:acl_aclaracion b
	 WHERE b.fky_producto = a.pky_producto
	   --AND fky_tipo_producto = 3
	   AND folio_csuac = pFolioSuac;

	If Tproducto = 4 Then
		Let pCalculaInteres = 0;
	End If;

	IF (pCalculaInteres = 1 AND pDictamen IN ('AA','AS','PR') AND Tproducto <> 3) THEN

	
	--> Consulta de movimiento de intereses.
        SELECT trans_procede, pky_tipo_movimiento, fky_tipo_transaccion
          INTO Ctrannopro, Ipky_tipo_movimiento, Ifky_tipo_transaccion
          FROM bdiaclaracion:acl_tipo_movimiento
         WHERE fky_tipo_transaccion = 10;

	--> Consulta de datos de aclaraciÃ³n.
		SELECT a.fky_aclaracion, a.fky_producto, a.pky_movimiento,b.numero_cuenta, monto, date (fechahora)
		  INTO Ifky_aclaracion, Ifky_producto, Ipky_movimiento, CnumCuenta, CmontoAcla, Ifechahora
		  FROM bdiaclaracion:acl_movimiento a,
               bdiaclaracion:acl_producto b
		 WHERE b.pky_producto = a.fky_producto
           AND a.fky_padre IS NULL
		   AND duplicado = 0
		   AND folio_csuac = pFolioSuac;

		--> Consulta para validaciÃ³n de intereses.
		SELECT fky_tipo_movimiento
		  INTO v_pky_tipo_movimiento
		  FROM bdiaclaracion:acl_movimiento
		 WHERE fky_tipo_movimiento = 332
		   AND folio_csuac = pFolioSuac;
		   
		--> Asignamos valor a "v_nombre_sp" y obtenemos dateTime del sistema JLM - 02/06/2022
        LET v_nombre_sp ='sp_calculaintaclaraciones';
	    SELECT DBINFO("utc_to_datetime", sh_curtime)
			INTO horaActual
	    FROM sysmaster:sysshmvals;
	    -->
		
		--> Calculo de intereses
		CALL sp_calculaintaclaraciones (Ifechahora, CURRENT, CnumCuenta, CmontoAcla)
		RETURNING DCodret_a, IIntereses;
		
		--> Validamos el codigo de retorno del sp_calculaintaclaraciones, si es difernete de "0", guardamos el error en bitacora. JLM - 02/06/2022
		IF( DCodret_a <> '000' ) THEN
			INSERT INTO informix.aplicaaclaradebito_control_errores(cod_retorno, nombre_sp, num_cuenta, folio_csuac, fecha_insert) 
				VALUES(DCodret_a, v_nombre_sp, CnumCuenta, pFolioSuac, horaActual);
		END IF;
		-->

			IF ( v_pky_tipo_movimiento IS NULL) THEN  -->> Valida si ya se ingresaron los intereses

			INSERT INTO bdiaclaracion:acl_movimiento
			-- pky_movimiento                            calculado     cargo     cargo_ajuste	exitoso     fecha_afectacion        fecha_hora_e_global     fechahora               folio_csuac     folio_suc         identificador_adquiriente     iso_37     iso_41     monto         montoprocedente     duplicado     numero_transaccion     procede     referencia    referencia23    reversado     secuencia           fky_aclaracion     fky_padre        fky_producto     fky_solicitud_e_global     fky_tipo_evento     fky_tipo_movimiento     fky_tipo_catalogo_transaccion     ref_comercio   num_sucursal
			VALUES(bdiaclaracion:MOVIMIENTO_SEQ.nextval, 1,            0,        null,				0,          null,                   null,                   current,                pFolioSuac,     null,             null,                         null,      null,      IIntereses,   IIntereses,                0,     Ctrannopro,            1,          '',           '',             0,            CSecuencia_acl_mov,  null,             Ipky_movimiento, Ifky_producto,   null,                      null,               Ipky_tipo_movimiento,   null,                             null,          "9250",null, 0, 0);

				IF (IIntereses = 0) THEN --> Valida si los intereses son "$0" no se intente aplicar el movimiento.

					UPDATE bdiaclaracion:acl_movimiento
					   SET procede = 0
					 WHERE folio_csuac = pFolioSuac
					   AND fky_tipo_movimiento = Ipky_tipo_movimiento;

				END IF;

			END IF;

	END IF;

-->> ***************************************************************************************************************************************************** <<--

	IF (pDictamen = 'NP') THEN

	   UPDATE bdiaclaracion:acl_movimiento
		  SET procede = 0
		WHERE folio_csuac = pFolioSuac
		  AND procede = 1
		  AND cargo IS NULL
		  AND fecha_afectacion IS NULL;

	END IF;


-->> ValidaciÃ³n de intereses en 0 anteriores
/*29/10/14;VJMP;Se agrega validacion*/
	SELECT '1'
		Into v_intereses_0
	FROM bdiaclaracion:acl_movimiento
	    Where folio_csuac = pFolioSuac
	    AND fky_tipo_movimiento = 332
	    AND montoprocedente = 0;

	If v_intereses_0 = '1' Then
		UPDATE bdiaclaracion:acl_movimiento
		   SET procede = 0
		Where folio_csuac = pFolioSuac
			AND fky_tipo_movimiento = 332
			AND montoprocedente = 0;
	End If


-->> FORECH para afectaciÃ³n de movimientos.

    LET v_contador = 0;

	--> ValidaciÃ³n de InversiÃ³n

	    IF (Tproducto <> 3) THEN

			SELECT numero_cuenta --> Cuenta de CaptaciÃ³n
			  INTO CnumCuenta
			  FROM bdiaclaracion:acl_producto a, bdiaclaracion:acl_aclaracion b
			 WHERE b.fky_producto = a.pky_producto
			   AND b.folio_csuac = pFolioSuac ;

        ELSE

			SELECT numero_cuenta_inversion --> Cambiar Cuenta InversiÃ³n / Pagares por la Cuenta eje CaptaciÃ³n.
			  INTO CnumCuenta
			  FROM bdiaclaracion:acl_producto a, bdiaclaracion:acl_aclaracion b
			 WHERE b.fky_producto = a.pky_producto
			   AND a.fky_tipo_producto = 3
			   AND b.folio_csuac = pFolioSuac ;

		END IF;

	LET CnumCuenta = CnumCuenta;

    FOREACH WITH hold

		SELECT pky_movimiento, /*numero_cuenta,*/ numero_tarjeta, montoprocedente, trans_no_procede, trans_procede, trans_procede_automatico, trans_procede_sin_autorizacion, nvl(cargo,0)
          INTO CSecuencia, /*CnumCuenta,*/ CnumTarjeta, CmontoAcla, Ctrannopro, Ctranpro, Ctranauto, Ctransinauto,Ccargo
          FROM bdiaclaracion:acl_movimiento a
          LEFT OUTER JOIN bdiaclaracion:acl_producto b on (a.fky_producto = b.pky_producto)
          LEFT OUTER JOIN bdiaclaracion:acl_tipo_movimiento c on (a.fky_tipo_movimiento = c.pky_tipo_movimiento)
         WHERE (folio_csuac = pFolioSuac AND (procede IS NULL OR procede = 1) AND (exitoso IS NULL OR exitoso <> '1') AND NVL(fky_padre,0) = CASE WHEN ( pDictamen IN ('AA','AS')) THEN 0 ELSE NVL(fky_padre,0) END)
		   OR  (folio_csuac = pFolioSuac AND (procede IS NULL OR procede = 1) AND (exitoso IS NULL OR exitoso <> '1') AND fky_tipo_movimiento = 332 ) --> Abono de intereses

	LET CnumCuenta = CnumCuenta;

		   IF CnumCuenta IS NULL THEN
              LET cCodRet='002'; -- >> "NÃºmero de cuenta es nulo"
              ROLLBACK WORK;
              IF (wBegin = "S") THEN
                  BEGIN WORK;
              END IF;
              RETURN cCodRet;
           END IF;

           IF CmontoAcla IS NULL or CmontoAcla = 0 THEN
              LET cCodRet='004'; --> ok
              -- ROLLBACK WORK;
              -- IF (wBegin = "S") THEN
              --   BEGIN WORK;
              -- END IF;
              RETURN cCodRet;
           END IF;

           IF (CnumTarjeta is null) then
              LET CnumTarjeta = '';
           END IF;

			SELECT substr((current HOUR TO SECOND),1,2)||substr((current HOUR TO SECOND),4,2)|| LPAD(v_contador,2,0)
			INTO v_fecha_folio
			FROM bdicheq:sc_fechas;

			LET pFolioSuacSUC = trim(v_fecha_folio)||lpad(pFolioSuac,10,0);

			IF (pDictamen = 'PR') THEN   --> Transaccion procedente
				LET ptranaplica = Ctranpro;
			ELIF (pDictamen = 'NP') THEN --> Transaccion no procedente
				LET ptranaplica = Ctrannopro;
			ELIF (pDictamen = 'CM') THEN --> Transaccion no procedente sin afectaciÃ³n, solÃ³ comisiÃ³n
				LET ptranaplica = Ctrannopro;
			ELIF (pDictamen = 'AA') THEN --> Transaccion abono automatico
				LET ptranaplica = Ctranauto;
			ELIF (pDictamen = 'AS') THEN --> Transaccion abono automatico sin autorizacion
				LET ptranaplica = Ctransinauto;
			END IF;
			
			--> Asignamos valor a "v_nombre_sp" y obtenemos dateTime del sistema JLM - 02/06/2022
            LET v_nombre_sp ='cons_saldo';
	        SELECT DBINFO("utc_to_datetime", sh_curtime)
				INTO horaActual
	        FROM sysmaster:sysshmvals;
			-->

			IF (pDictamen IN ('NP','CM')) THEN

			CALL bdicheq:cons_saldo (CnumCuenta) RETURNING  vcodret,vsdodisp,vstatuscta;
			
			--> Validamos el codigo de retorno del sp_calculaintaclaraciones, si es difernete de "0", guardamos el error en bitacora. JLM - 02/06/2022
		    IF( vcodret <> '000' ) THEN
			    INSERT INTO informix.aplicaaclaradebito_control_errores(cod_retorno, nombre_sp, num_cuenta, folio_csuac, fecha_insert) 
				   VALUES(vcodret, v_nombre_sp, CnumCuenta, pFolioSuac, horaActual);
		    END IF;
			-->

					IF ( ptranaplica = '0343') THEN
						IF 	(vsdodisp>=CmontoAcla*1.16) THEN -- Si no se puede cubrir el total de la comision regresa saldo insuficiente
							CALL cargo_comisiones(pEmpresa, CnumCuenta, ptranaplica, CmontoAcla, pFolioSuacSUC, '9250', v_usuario, 0, '01', today)
						RETURNING DCodret_a;
							
							LET v_nombre_sp ='cargo_comisiones';
							--> Validamos el codigo de retorno del sp_calculaintaclaraciones, si es difernete de "0", guardamos el error en bitacora. JLM - 02/06/2022
							IF( DCodret_a <> '000' ) THEN
								INSERT INTO informix.aplicaaclaradebito_control_errores(cod_retorno, nombre_sp, num_cuenta, folio_csuac, fecha_insert) 
								   VALUES(DCodret_a, v_nombre_sp, CnumCuenta, pFolioSuac, horaActual);
							END IF;
							-->
						
						ELSE
						LET DCodret_a ='400';
						END IF;
					ELSE
					LET v_nombre_sp ='cargo_ref';
						CALL cargo_ref(pEmpresa, '9250', v_usuario, ptranaplica, '0000', pFolioSuacSUC, CnumCuenta, 0, CmontoAcla, '01',	pFolioSuac, CnumTarjeta, v_usuario)
						RETURNING DCodret_a, DTranret_c, DFechoy_c, DVsdodisp_c, DVmontoret_c;
						
							--> Validamos el codigo de retorno del sp_calculaintaclaraciones, si es difernete de "0", guardamos el error en bitacora. JLM - 02/06/2022
							IF( DCodret_a <> '000' ) THEN
								INSERT INTO informix.aplicaaclaradebito_control_errores(cod_retorno, nombre_sp, num_cuenta, folio_csuac, fecha_insert) 
								   VALUES(DCodret_a, v_nombre_sp, CnumCuenta, pFolioSuac, horaActual);
							END IF;
							-->

					END IF;
			ELSE
			---Validar no exista abono aplicado por ese concepto para el folio 13/01/2015
		-----
				--SET ISOLATION TO DIRTY READ;
				SELECT fechacaptura
				into fecha_captura
				FROM bdiaclaracion:acl_aclaracion
				WHERE folio_csuac=pFolioSuac;

				--SET ISOLATION TO DIRTY READ;
				SELECT count(*)
				INTO v_contador_0
				FROM bdicheq:sc_movdia
				WHERE empresa=pEmpresa
				AND cuenta=CnumCuenta
				AND monto_tot=CmontoAcla
				AND substr(folio_suc,7)=pFolioSuac
				AND transacc=ptranaplica;

				--SET ISOLATION TO DIRTY READ;
				SELECT count(*)
				INTO v_contador_1
				FROM bdicheq:sc_movhis
				WHERE empresa=pEmpresa
				AND cuenta=CnumCuenta
				AND fech_alt>=fecha_captura
				AND monto_tot=CmontoAcla
				AND substr(folio_suc,7)=pFolioSuac
				AND transacc=ptranaplica;

				--SET ISOLATION TO DIRTY READ;
				SELECT count(*)
				INTO v_contador_2
				FROM bdicheq:sc_movhis_old
				WHERE empresa=pEmpresa
				AND cuenta=CnumCuenta
				AND fech_alt>=fecha_captura
				AND monto_tot=CmontoAcla
				AND substr(folio_suc,7)=pFolioSuac
				AND transacc=ptranaplica;

				LET v_contador_total=v_contador_0+v_contador_1+v_contador_2;
				
				


				IF (v_contador_total=0) THEN

				CALL abono_ref (pEmpresa, '9250', v_usuario, ptranaplica, '0000', pFolioSuacSUC, CnumCuenta, 0, CmontoAcla, CmontoAcla, 0, 0, 0, '01', pFolioSuac, CnumTarjeta, v_usuario)
				RETURNING DCodret_a;
				
					--> Asignamos valor a "v_nombre_sp" y obtenemos dateTime del sistema JLM - 02/06/2022
					LET v_nombre_sp ='abono_ref';
					SELECT DBINFO("utc_to_datetime", sh_curtime)
						INTO horaActual
					FROM sysmaster:sysshmvals;
					-->
				
					--> Validamos el codigo de retorno del sp_calculaintaclaraciones, si es difernete de "0", guardamos el error en bitacora. JLM - 02/06/2022
					IF( DCodret_a <> '000' ) THEN
						INSERT INTO informix.aplicaaclaradebito_control_errores(cod_retorno, nombre_sp, num_cuenta, folio_csuac, fecha_insert) 
							VALUES(DCodret_a, v_nombre_sp, CnumCuenta, pFolioSuac, horaActual);
					END IF;
					-->
		

				END IF;

			END IF

			LET cCodRet = DCodret_a;

			IF (DCodret_a = "005") THEN
				  LET cCodRet = '005'; -- Intento de cargo con credito vencido "BT" y bloqueado y sin saldo suficiente
				  ROLLBACK WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;

			IF (DCodret_a = "207") THEN
				  LET cCodRet = '207'; -- Intento de cargo con crÃ?Ã?Ã?ÃÂ©dito vencido "BT" y bloqueado
				  ROLLBACK WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;


			IF (DCodret_a = "400") THEN
				  LET cCodRet = '400'; -- Fondos insuficientes dÃ©bito
				--  ROLLBACK WORK;  -- Evitar el rollback cuando no se tenga saldo, para mantener la comisiÃ³n insertada
				COMMIT WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;

			IF (DCodret_a = "552") THEN
				  LET cCodRet = '552'; -- Naturaleza de la transaccion incorrecta abono
				  --ROLLBACK WORK;
				  COMMIT WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;

			IF (DCodret_a = "551") THEN
				  LET cCodRet = '551'; -- Naturaleza de la transaccion incorrecta cargo
				  --ROLLBACK WORK;
				  COMMIT WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;


			IF (DCodret_a = "300") THEN
				  LET cCodRet = '300'; -- Cuenta bloqueada
				  --ROLLBACK WORK;
				  COMMIT WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;

			IF (DCodret_a = "301") THEN
				  LET cCodRet = '301'; -- Cuenta bloqueada abonos
				  --ROLLBACK WORK;
				  COMMIT WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;

			IF (DCodret_a = "060") THEN
				  LET cCodRet = '060'; -- Cuenta bloqueada
				  --ROLLBACK WORK;
				  COMMIT WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;

		    IF (DCodret_a = "200") THEN
				  LET cCodRet = '200'; -- Cuenta cancelada
				  ROLLBACK WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;


			IF (DCodret_a <> "000") THEN
				  LET cCodRet = '009'; -- definir codigo en caso de falla en el cargo o abono
				--ROLLBACK WORK;
				  IF (wBegin = "S") THEN
					  BEGIN WORK;
				  END IF;
				  RETURN cCodRet;
			END IF;

		-------------- >> Consulta de secuencia

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

		-------------- >> ActualizaciÃ³n

			IF (pDictamen IN ('PR', 'AA')) THEN

				IF (v_contador_total=0) THEN

				UPDATE bdiaclaracion:acl_movimiento
				   SET cargo = 0,
					   exitoso = '1',
					   procede = 1,
					   fecha_afectacion = CURRENT,
					   numero_transaccion = ptranaplica,
					   secuencia = CSecuencia_acl_mov
				 WHERE pky_movimiento = CSecuencia
				   AND folio_csuac = pFolioSuac;

				ELSE
					UPDATE bdiaclaracion:acl_movimiento
				    SET cargo = 0,
					   procede = 0,
					   fecha_afectacion = CURRENT,
					   secuencia = CSecuencia_acl_mov
				 WHERE pky_movimiento = CSecuencia
				   AND folio_csuac = pFolioSuac;
				END IF;

			ELIF (pDictamen IN ('AS')) THEN
				UPDATE bdiaclaracion:acl_movimiento
				   SET cargo = 0,
					   exitoso = '1',
					   procede = null, --> Null para identificar si es un flujo Abono sin AutorizaciÃ³n
					   fecha_afectacion = CURRENT,
					   numero_transaccion = ptranaplica,
					   secuencia = CSecuencia_acl_mov
				 WHERE pky_movimiento = CSecuencia
				   AND folio_csuac = pFolioSuac;

			ELIF (pDictamen IN ('NP', 'CM')) THEN

				   IF 	(DCodret_a="000") THEN
				   UPDATE bdiaclaracion:acl_movimiento
				   SET cargo = 1,
					   exitoso = '1',
					   procede = 1,
					   fecha_afectacion = CURRENT,
					   numero_transaccion = ptranaplica,
					   secuencia = CSecuencia_acl_mov
					WHERE pky_movimiento = CSecuencia
						AND folio_csuac = pFolioSuac;
				  ELSE
				   	UPDATE bdiaclaracion:acl_movimiento
				    SET cargo = 1,
					   exitoso = '0',
					   procede = 1,
					   numero_transaccion = ptranaplica,
					   secuencia = CSecuencia_acl_mov
					WHERE pky_movimiento = CSecuencia
				   AND folio_csuac = pFolioSuac;
				   END IF; -- Validar cobro de comisiÃ³n

			END IF;

			LET v_contador = v_contador + 1;

    END FOREACH;

    COMMIT WORK;

    IF (wBegin = "S") THEN
        BEGIN WORK;
    END IF;

	END;

 RETURN cCodRet;

END PROCEDURE
DOCUMENT
'Sp sp_aplicaaclarabedito',
'Se incluye validacion para evitar se dupliquen abonos',
'Sistema: Aclaraciones',
'AUTOR : Bancoppel',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 13/Enero/2014',
'VERSION: 1.0.0',
'BD    :  bdicheq',
'Sp sp_aplicaaclarabedito',
'Se incluye validacion para evitar errores en el cobro de comision',
'Sistema: Aclaraciones',
'AUTOR : Bancoppel',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 10/Noviembre/2022',
'VERSION: 1.0.0',
'BD    :  bdicheq';

CREATE PROCEDURE "informix".sp_corrije_ints_sdos_diarios( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cDescErr         CHAR(50);
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iContador1       INTEGER;
    DEFINE iContador2       INTEGER;
    DEFINE iComienza        SMALLINT;
    DEFINE iAbierto         SMALLINT;
    DEFINE cAnioMes         CHAR(6);
    DEFINE cCuenta          CHAR(20);
    DEFINE mIntProvNoPag    DECIMAL(14,2);
    
    LET iSqlErr	      = 0;
    LET iIsamErr      = 0;
    LET cDescErr      = '';
    LET cCodRet1      = '000';
    LET cCodRet2      = '';
    LET cCodRet3      = '';   
    LET iContador1    = 0;
    LET iContador2    = 0;
    LET iComienza     = -1;
    LET iAbierto      = 0;
    LET cAnioMes      = '';
    LET cCuenta       = '';
    LET mIntProvNoPag = 0.00;
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrije_ints_sdos_diarios.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF iAbierto = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrije_ints_sdos_diarios.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET cAnioMes = YEAR(pFecha)||LPAD(MONTH(pFecha),2,'0');
    
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO cCuenta
          FROM sc_movhis 
         WHERE empresa = pEmpresa
           AND cuenta >= '10000005016'
           AND fech_alt = pFecha
           AND cancelad <> 'S'
           AND transacc IN('3381')
           AND transacc NOT IN('3276')
        
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iAbierto = 1;
        END IF;
        
        LET iContador1 = iContador1 + 1;
        
        SELECT SUM(monto_tot)
          INTO mIntProvNoPag
          FROM sc_movhis
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND fech_alt = pFecha
           AND transacc = '3381';
        
        UPDATE sc_sdodiarioc
           SET intprovnp31 = mIntProvNoPag
         WHERE cuenta = cCuenta
           AND aniomes = cAnioMes;
        
        LET iContador2 = iContador2 + 1;
        
        IF iContador2 >= 1000 THEN
            LET iContador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cCuenta = '';
        LET mIntProvNoPag = 0.00;
    END FOREACH;
    
    IF iAbierto = 1 THEN
        LET iAbierto = 0;
        COMMIT WORK;
    END IF;
    
    END; 
    
    RETURN cCodRet1, iContador1, iContador2;
    
END PROCEDURE;