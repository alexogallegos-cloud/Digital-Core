CREATE PROCEDURE "informix".pasecont_web_2(psucursal CHAR(8),
                          pfecha_hoy     DATE,
                          psecuencia     INTEGER,
                          pempresa       CHAR(3),
                          pccmayor       CHAR(10),
                          pccsub         CHAR(10),
                          pccsubsub      CHAR(10),
                          pccssubsub     CHAR(10),
                          pcargo_abono   CHAR(1),
                          pmonto         MONEY(14,2),
                          pmoneda        CHAR(2),
                          pindicador     CHAR(1),  -- "1" ult renglon
                          pinic_mov_suc  CHAR(1),  -- "1" 2da. vez
                          pauxiliar      CHAR(12),
                          pfecha_valor   DATE,
                          pcentro_costo  CHAR(4))

RETURNING CHAR(5);
   DEFINE cod_ret CHAR(5);
   DEFINE vw_mca_aplic,v_carabo,v_natur CHAR(1);
   DEFINE vw_ccsubsub,vw_ccssubsub,vw_ccsssubsub,vw_sector CHAR(10);
   DEFINE v_tipo_mon, v_moneda CHAR(2);
   DEFINE vw_ciudad,vw_empresa CHAR(3);
   DEFINE vw_usuario CHAR(8);
   DEFINE vw_proceso,v_proceso CHAR(8);
   DEFINE vw_auxiliar CHAR(12);
   DEFINE vw_descripcion CHAR(30);
   DEFINE v_existen,v_control SMALLINT;
   DEFINE vw_valor_cambio,vw_valor_div,vw_capt_cargo,vw_capt_abono,
          vw_cIFra_control, v_monto MONEY(19,2);
   DEFINE sql_err INTEGER;
   DEFINE contador INTEGER;
   DEFINE fech_hora DATETIME HOUR TO FRACTION;
   DEFINE vmensaje CHAR(60);
   DEFINE cod_ret_2 CHAR(5);
   
   LET fech_hora = CURRENT HOUR TO FRACTION;   

--   SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/pasecont_web.out";
--   TRACE ON;

-- *****************************************************************
-- Inicializa variables
-- *****************************************************************
   LET cod_ret         = "00000";

   LET pccssubsub = pccssubsub;

   LET vw_ccsubsub     = pccssubsub[1,2];
   LET vw_ccssubsub    = pccssubsub[3,4];
   LET vw_sector       = pccssubsub[5,6];

   LET vw_auxiliar     = " ";
   LET vw_descripcion  = "Movimientos de Sucursal del dia de hoy";
   LET vw_valor_cambio = 0;
   LET vw_valor_div    = 0;
   LET vw_mca_aplic    = "0";
   LET cod_ret_2       = '00000';

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret;
      END IF;
   END EXCEPTION;

--Se anexan para disminuir los -243/-244/-245	
	SET LOCK MODE TO WAIT 3;	
-- *****************************************************************
-- Valida los parametros de entrada
-- *****************************************************************
   IF psucursal    IS NULL OR
      pfecha_hoy   IS NULL OR
      psecuencia   < 0 or
      pempresa     IS NULL OR
      pccmayor     IS NULL OR
      pccsub       IS NULL OR
      pccsubsub    IS NULL OR
      pccssubsub   IS NULL OR
      pcargo_abono IS NULL OR
      pmonto       IS NULL OR
      pmoneda      IS NULL OR
      pindicador   IS NULL OR
      pinic_mov_suc IS NULL OR
      pauxiliar    IS NULL OR
      pfecha_valor IS NULL OR
	  pcentro_costo IS NULL THEN
      LET cod_ret = "00110";
      RETURN cod_ret;
   END IF
-- valida si el renglon es terminador

   IF pauxiliar <> " " THEN
     LET  vw_auxiliar = pauxiliar;
   END IF

-- VerIFica si la poliza se ha transmitido ya en base a la secuencia.

   IF (psecuencia = 1) THEN 
      IF EXISTS(SELECT usuario FROM bdicont:"informix".co_poldet WHERE usuario = psucursal 
                AND fecha_captura = pfecha_hoy AND moneda = pmoneda
                AND fecha_valida = pfecha_valor) THEN
				DELETE FROM bdicont:"informix".co_poldet
				WHERE usuario = psucursal AND
               fecha_captura = pfecha_hoy AND
               moneda = pmoneda AND 
               fecha_valida = pfecha_valor;
      END IF
   END IF


-- *****************************************************************
-- Valida la sucursal asignada,como el usuario del Pase Contable
-- *****************************************************************
   SELECT regional INTO vw_ciudad
   FROM bdinteg:"informix".si_sucursales s, bdinteg:"informix".si_plazas p
   WHERE s.empresa = pempresa AND s.sucursal = psucursal[1,4] AND
         s.empresa = p.empresa AND s.plaza = p.plaza;
   
   IF vw_ciudad IS NULL THEN
      LET cod_ret = "00159";
      RETURN cod_ret;
   END IF
   
   LET vw_usuario = psucursal;
   LET psecuencia = psecuencia + 1;
   -- Genera el detalle de la poliza
   IF pmonto > 0 THEN
      -- VerIFica la moneda/tipo de metal            24/JUN/96  AMF.

      IF pmoneda matches "*[^1234567890]*" THEN
         SELECT tipo INTO v_tipo_mon
         FROM bdinteg:"informix".si_metales
         WHERE codigo = pmoneda;
         LET pmoneda = "  ";
         IF v_tipo_mon = "O" THEN           -- ORO
            LET pmoneda = "10";
         ELIF v_tipo_mon = "P" THEN         -- PLATA
            LET pmoneda = "11";
         END IF
      END IF
      IF (pcargo_abono <> "T") THEN
         INSERT INTO bdicont:"informix".co_poldet
            VALUES(vw_usuario,pfecha_hoy,psecuencia,pempresa,
               pccmayor,pccsub,pccsubsub,vw_ccsubsub,vw_ccssubsub, --vw_ccsssubsub, MAU REVISA
               vw_sector,vw_ciudad,pcentro_costo,vw_auxiliar,pcargo_abono,
               pmonto,vw_descripcion,pfecha_valor,pmoneda,psucursal);
      END IF
   END IF

   IF pindicador = "1" THEN
      -- Actualiza el control de procesos
      LET v_proceso = "pase";
      SELECT proceso INTO vw_proceso FROM bdisuc:"informix".ss_contproc
         WHERE sucursal=psucursal[1,4] AND proceso = v_proceso;
      IF vw_proceso IS NULL THEN
         INSERT INTO bdisuc:"informix".ss_contproc
            VALUES(psucursal,v_proceso,pfecha_hoy);
      ELSE
         UPDATE bdisuc:"informix".ss_contproc
            SET fecha = pfecha_hoy
            WHERE sucursal=psucursal[1,4] AND proceso = v_proceso;
      END IF
   END IF
   IF pindicador = "1" THEN
      EXECUTE PROCEDURE bdicont:"informix".auditapase(pfecha_hoy,pempresa,vw_usuario,pfecha_valor)
              INTO cod_ret_2;
			  IF (LENGTH(TRIM(cod_ret_2)) == 3) THEN 
				LET cod_ret = '00'||cod_ret_2;
			  ELSE 
				LET cod_ret = cod_ret_2;
			  END IF
   END IF
RETURN cod_ret;
END
END PROCEDURE
DOCUMENT
'MODIFICA:    	Felipe Urias',
'FECHA:       	18 de Julio de 2012',
'DESCRIPCION: 	se agrega parametro de entrada para insertar sucursal en bdicont:co_poldet',
'BASE DE DATOS: bdisuc';

CREATE PROCEDURE "informix".pasecont_web(psucursal CHAR(8),
                          pfecha_hoy     DATE,
                          psecuencia     INTEGER,
                          pempresa       CHAR(3),
                          pccmayor       CHAR(10),
                          pccsub         CHAR(10),
                          pccsubsub      CHAR(10),
                          pccssubsub     CHAR(10),
                          pcargo_abono   CHAR(1),
                          pmonto         MONEY(14,2),
                          pmoneda        CHAR(2),
                          pindicador     CHAR(1),  -- "1" ult renglon
                          pinic_mov_suc  CHAR(1),  -- "1" 2da. vez
                          pauxiliar      CHAR(12),
                          pfecha_valor   DATE,
                          pcentro_costo  CHAR(4))

RETURNING CHAR(5);
   DEFINE cod_ret CHAR(5);
   DEFINE vw_mca_aplic,v_carabo,v_natur CHAR(1);
   DEFINE vw_ccsubsub,vw_ccssubsub,vw_ccsssubsub,vw_sector CHAR(10);
   DEFINE v_tipo_mon, v_moneda CHAR(2);
   DEFINE vw_ciudad,vw_empresa CHAR(3);
   DEFINE vw_usuario CHAR(8);
   DEFINE vw_proceso,v_proceso CHAR(8);
   DEFINE vw_auxiliar CHAR(12);
   DEFINE vw_descripcion CHAR(30);
   DEFINE v_existen,v_control SMALLINT;
   DEFINE vw_valor_cambio,vw_valor_div,vw_capt_cargo,vw_capt_abono,
          vw_cIFra_control, v_monto MONEY(19,2);
   DEFINE sql_err INTEGER;
   DEFINE contador INTEGER;
   DEFINE fech_hora DATETIME HOUR TO FRACTION;
   DEFINE vmensaje CHAR(60);
   DEFINE cod_ret_2 CHAR(5);
   
   LET fech_hora = CURRENT HOUR TO FRACTION;   

--   SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/pasecont_web.out";
--   TRACE ON;

-- *****************************************************************
-- Inicializa variables
-- *****************************************************************
   LET cod_ret         = "00000";

   LET pccssubsub = pccssubsub;

   LET vw_ccsubsub     = pccssubsub[1,2];
   LET vw_ccssubsub    = pccssubsub[3,4];
   LET vw_sector       = pccssubsub[5,6];

   LET vw_auxiliar     = " ";
   LET vw_descripcion  = "Movimientos de Sucursal del dia de hoy";
   LET vw_valor_cambio = 0;
   LET vw_valor_div    = 0;
   LET vw_mca_aplic    = "0";
   LET cod_ret_2       = '00000';

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret;
      END IF;
   END EXCEPTION;

--Se anexan para disminuir los -243/-244/-245	
	SET LOCK MODE TO WAIT 3;	
-- *****************************************************************
-- Valida los parametros de entrada
-- *****************************************************************
   IF psucursal    IS NULL OR
      pfecha_hoy   IS NULL OR
      psecuencia   < 0 or
      pempresa     IS NULL OR
      pccmayor     IS NULL OR
      pccsub       IS NULL OR
      pccsubsub    IS NULL OR
      pccssubsub   IS NULL OR
      pcargo_abono IS NULL OR
      pmonto       IS NULL OR
      pmoneda      IS NULL OR
      pindicador   IS NULL OR
      pinic_mov_suc IS NULL OR
      pauxiliar    IS NULL OR
      pfecha_valor IS NULL OR
	  pcentro_costo IS NULL THEN
      LET cod_ret = "00110";
      RETURN cod_ret;
   END IF
-- valida si el renglon es terminador

   IF pauxiliar <> " " THEN
     LET  vw_auxiliar = pauxiliar;
   END IF

-- VerIFica si la poliza se ha transmitido ya en base a la secuencia.

   IF (psecuencia = 1) THEN 
      IF EXISTS(SELECT usuario FROM bdicont:"informix".co_poldet WHERE usuario = psucursal 
                AND fecha_captura = pfecha_hoy AND moneda = pmoneda
                AND fecha_valida = pfecha_valor) THEN
				DELETE FROM bdicont:"informix".co_poldet
				WHERE usuario = psucursal AND
               fecha_captura = pfecha_hoy AND
               moneda = pmoneda AND 
               fecha_valida = pfecha_valor;
      END IF
   END IF


-- *****************************************************************
-- Valida la sucursal asignada,como el usuario del Pase Contable
-- *****************************************************************
   SELECT regional INTO vw_ciudad
   FROM bdinteg:"informix".si_sucursales s, bdinteg:"informix".si_plazas p
   WHERE s.empresa = pempresa AND s.sucursal = psucursal[1,4] AND
         s.empresa = p.empresa AND s.plaza = p.plaza;
   
   IF vw_ciudad IS NULL THEN
      LET cod_ret = "00159";
      RETURN cod_ret;
   END IF
   
   LET vw_usuario = psucursal;
   LET psecuencia = psecuencia + 1;
   -- Genera el detalle de la poliza
   IF pmonto > 0 THEN
      -- VerIFica la moneda/tipo de metal            24/JUN/96  AMF.

      IF pmoneda matches "*[^1234567890]*" THEN
         SELECT tipo INTO v_tipo_mon
         FROM bdinteg:"informix".si_metales
         WHERE codigo = pmoneda;
         LET pmoneda = "  ";
         IF v_tipo_mon = "O" THEN           -- ORO
            LET pmoneda = "10";
         ELIF v_tipo_mon = "P" THEN         -- PLATA
            LET pmoneda = "11";
         END IF
      END IF
      IF (pcargo_abono <> "T") THEN
         INSERT INTO bdicont:"informix".co_poldet
            VALUES(vw_usuario,pfecha_hoy,psecuencia,pempresa,
               pccmayor,pccsub,pccsubsub,vw_ccsubsub,vw_ccssubsub, --vw_ccsssubsub, MAU REVISA
               vw_sector,vw_ciudad,pcentro_costo,vw_auxiliar,pcargo_abono,
               pmonto,vw_descripcion,pfecha_valor,pmoneda,psucursal);
      END IF
   END IF

   IF pindicador = "1" THEN
      -- Actualiza el control de procesos
      LET v_proceso = "pase";
      SELECT proceso INTO vw_proceso FROM bdisuc:"informix".ss_contproc
         WHERE sucursal=psucursal[1,4] AND proceso = v_proceso;
      IF vw_proceso IS NULL THEN
         INSERT INTO bdisuc:"informix".ss_contproc
            VALUES(psucursal,v_proceso,pfecha_hoy);
      ELSE
         UPDATE bdisuc:"informix".ss_contproc
            SET fecha = pfecha_hoy
            WHERE sucursal=psucursal[1,4] AND proceso = v_proceso;
      END IF
   END IF
   IF pindicador = "1" THEN
      EXECUTE PROCEDURE bdicont:"informix".auditapase(pfecha_hoy,pempresa,vw_usuario,pfecha_valor)
              INTO cod_ret_2;
			  IF (LENGTH(TRIM(cod_ret_2)) == 3) THEN 
				LET cod_ret = '00'||cod_ret_2;
			  ELSE 
				LET cod_ret = cod_ret_2;
			  END IF
   END IF
RETURN cod_ret;
END
END PROCEDURE
DOCUMENT
'MODIFICA:    	Felipe Urias',
'FECHA:       	18 de Julio de 2012',
'DESCRIPCION: 	se agrega parametro de entrada para insertar sucursal en bdicont:co_poldet',
'BASE DE DATOS: bdisuc';

CREATE PROCEDURE "informix".sp_faltsob_atm_ofi_web(
	pempresa CHAR(3),
	psucursal CHAR(4),
	pcajeroprincipal CHAR(8),
	pfolio_suc CHAR(16),
	ptransaccion CHAR(4),
	pdivisa CHAR(2),
	pmonto MONEY(14,2),
	pfecha DATE,
	pdeno1 CHAR(18),
	pdeno2 CHAR(18),
	pdeno3 CHAR(18),
	pdeno4 CHAR(18),
	pdeno5 CHAR(18),
	pdeno6 CHAR(18),
	pdeno7 CHAR(18),
	pdeno8 CHAR(18),
	pdeno9 CHAR(18),
	pdeno10 CHAR(18),
	pdeno11 CHAR(18),
	pdeno12 CHAR(18),
	pdeno13 CHAR(18),
	pdeno14 CHAR(18),
	pdeno15 CHAR(18),
	pcant1 FLOAT(8),
	pcant2 FLOAT(8),
	pcant3 FLOAT(8),
	pcant4 FLOAT(8),
	pcant5 FLOAT(8),
	pcant6 FLOAT(8),
	pcant7 FLOAT(8),
	pcant8 FLOAT(8),
	pcant9 FLOAT(8),
	pcant10 FLOAT(8),
	pcant11 FLOAT(8),
	pcant12 FLOAT(8),
	pcant13 FLOAT(8),
	pcant14 FLOAT(8),
	pcant15 FLOAT(8),
	poperacion SMALLINT,
	pmotivo CHAR(2),
	pfolio_ope CHAR(8))
	
	RETURNING CHAR(5),CHAR(8);

	DEFINE vcodret CHAR(5);
	DEFINE vfolio CHAR(8);
	DEFINE vsqlerr,visamerr INTEGER;
	DEFINE vhora CHAR(5);
	DEFINE vproveedor CHAR(4);
	DEFINE vplaza CHAR(3);
	DEFINE vprocedencia CHAR(4);
	DEFINE vnum INTEGER;
	DEFINE iContador INTEGER;
	DEFINE bTransacInterAct	CHAR(1);
	DEFINE bEnTransac CHAR(1);
	
	LET vcodret = "00000";
	LET vproveedor = "";
	LEt vplaza = "";
	LET vprocedencia = "";
	LET vhora = substr(current,12,5);
	LET vnum = 0;
	LET vfolio = "";
	LET iContador = 0;
	LET bTransacInterAct = 'F';
	LET bEnTransac = 'F';

BEGIN
	ON EXCEPTION SET vsqlerr,visamerr
		IF vsqlerr <> 0 THEN
			IF bTransacInterAct = 'T' THEN		--DSB20150429 {
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					BEGIN WORK;
				END IF;
			ELSE
				IF bEnTransac = 'T' THEN
					ROLLBACK WORK;
				ELSE
					ROLLBACK WORK;
				END IF;							
			END IF;	

			LET vcodret = vsqlerr;
			RETURN vcodret,vfolio;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN (-535)				--DSB20150429 {
		LET bTransacInterAct = 'T';
		LET bEnTransac = 'T';
		COMMIT WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;

	--SET DEBUG FILE TO "/home/sysifx/Mario/trace.sql";
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
    --- Verifica recepcion correcta de datos
    IF pempresa = '0' OR pempresa = '' OR psucursal = '0' OR psucursal = '' OR pdivisa = '0' OR pdivisa = ''  OR pcajeroprincipal = '0' 
        OR pcajeroprincipal = '' OR pfolio_suc = '0' OR pfolio_suc = '' OR ptransaccion = '0' OR ptransaccion = '' OR pmonto = 0 THEN
        LET vcodret = "00110";
    ELSE
        SELECT plaza_cajagen 
        INTO vplaza
        FROM bdinteg:"informix".si_sucursales
        WHERE sucursal = psucursal
		AND empresa = pempresa;

        SELECT cod_proveedor 
        INTO vproveedor
        FROM bdisuc:"informix".ss_proveedores
        WHERE plaza = vplaza;

        --IF EXISTS (SELECT cod_proveedor FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = vproveedor) THEN
		SELECT COUNT(*) INTO iContador FROM bdisuc:"informix".ss_proveedores WHERE cod_proveedor = vproveedor;		
		IF iContador > 0 THEN
            IF poperacion != 0 AND poperacion != 1 THEN
                LET vcodret = "00106";
            ELSE
	            SELECT valor
	            INTO vnum
	            FROM bdisuc:"informix".ss_param_cajagen
	            WHERE codigo = '0005';

	            UPDATE bdisuc:"informix".ss_param_cajagen
	            SET    valor = valor + 1
	            WHERE  codigo = '0005';
				
				LET vfolio = LPAD(ROUND(vnum),8,"0");

				SELECT sucursal 
			    INTO vprocedencia
			    FROM bdisuc:ss_atms_sucursal 
				WHERE cod_atm = psucursal;

				IF vprocedencia ="" OR vprocedencia IS NULL THEN
					LET vprocedencia = psucursal;
				END IF

				--SE AGREGA DEPURACIÃÂN A LA TABLA DE RECUPERACIÃÂN			
				DELETE FROM bdisuc:"informix".ss_atm_rec WHERE  cod_atm = psucursal;
				   
				INSERT INTO bdisuc:"informix".ss_atm_rec(empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
				denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,
				denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,
				cantidad_12,cantidad_13,cantidad_14,cantidad_15 ) 
				SELECT empresa,cod_atm,divisa,saldo_anterior,saldo_asignado,saldo_total,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,
				denominacion_6,denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,denominacion_13,denominacion_14,
				denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,
				cantidad_12,cantidad_13,cantidad_14,cantidad_15 FROM ss_atm WHERE  cod_atm = psucursal;
				
				DELETE FROM bdisuc:"informix".ss_operaciones WHERE  sucursal = psucursal and  fecha_operacion = today and cod_trans = ptransaccion;

				INSERT INTO bdisuc:"informix".ss_operaciones(empresa,cod_trans,fecha_operacion,sucursal,folio_sucursal,folio_oper,reversado,usuario,divisa,
				procedencia,monto,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,
				denominacion_7,denominacion_8,denominacion_9,denominacion_10,denominacion_11,denominacion_12,
				denominacion_13,denominacion_14,denominacion_15,cantidad_1,cantidad_2,cantidad_3,cantidad_4,
				cantidad_5,cantidad_6,cantidad_7,cantidad_8,cantidad_9,cantidad_10,cantidad_11,cantidad_12,
				cantidad_13,cantidad_14,cantidad_15,motiv_afecta,mov_aplicado)
				VALUES(pempresa,ptransaccion,pfecha,psucursal,pfolio_suc,vfolio,'0',pcajeroprincipal,pdivisa,vprocedencia,pmonto,pdeno1,pdeno2,pdeno3,
				pdeno4,pdeno5,pdeno6,pdeno7,pdeno8,pdeno9,pdeno10,pdeno11,pdeno12,pdeno13,pdeno14,pdeno15,pcant1,pcant2,pcant3,pcant4,
				pcant5,pcant6,pcant7,pcant8,pcant9,pcant10,pcant11,pcant12,pcant13,pcant14,pcant15,pmotivo,0);

				IF poperacion = 1 THEN

					UPDATE bdisuc:"informix".ss_atm 
					SET cantidad_1 = cantidad_1 + pcant1, cantidad_2 = cantidad_2 + pcant2, cantidad_3 = cantidad_3 + pcant3, 
					cantidad_4 = cantidad_4 + pcant4, cantidad_5 = cantidad_5 + pcant5, cantidad_6 = cantidad_6 + pcant6,
					cantidad_7 = cantidad_7 + pcant7, cantidad_8 = cantidad_8 + pcant8, cantidad_9 = cantidad_9 + pcant9,
					cantidad_10 = cantidad_10 + pcant10,						
					saldo_anterior = saldo_total, saldo_total =  saldo_total + pmonto
					WHERE cod_atm = psucursal;

                ELIF poperacion = 0 THEN

					UPDATE bdisuc:"informix".ss_atm 
					SET cantidad_1 = cantidad_1 - pcant1, cantidad_2 = cantidad_2 - pcant2, cantidad_3 = cantidad_3 - pcant3, 
					cantidad_4 = cantidad_4 - pcant4, cantidad_5 = cantidad_5 - pcant5, cantidad_6 = cantidad_6 - pcant6,
					cantidad_7 = cantidad_7 - pcant7, cantidad_8 = cantidad_8 - pcant8, cantidad_9 = cantidad_9 - pcant9,
					cantidad_10 = cantidad_10 - pcant10,
					saldo_anterior = saldo_total, saldo_total =  saldo_total - pmonto
					WHERE cod_atm = psucursal;

                END IF;

				IF Trim(pfolio_ope) <> '0' THEN
					UPDATE bdisuc:"informix".ss_operaciones SET mov_aplicado = 1 WHERE folio_oper = pfolio_ope;
				END IF

            END IF;
        ELSE
            LET vcodret = "00105";
            RETURN vcodret,vfolio;
        END IF;
    END IF;
	COMMIT WORK;
	IF bTransacInterAct = 'T' THEN
		BEGIN WORK;
	END IF;
    RETURN vcodret,vfolio;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica procedimiento para guardar en monedas en el arqueo de cajeros ATM',
'AUTOR: 95142134 - Mario Gallardo',
'FECHA DE CREACION: 03/06/2020',
'BD: bdisuc',
'Folio: 674 - Ofi Plus';

CREATE PROCEDURE "informix".sp_monitor_operaciones3_2_resp(eEmpresa      CHAR(3),
                                                    eTipo         CHAR(1), --**C = ATM , S = Sucursal
                                                    eSucursal     CHAR(4),
                                                    eCodTrans     CHAR(4),  --Operacion
                                                    eFecInicio    DATE,
                                                    eFecFin       DATE,
                                                    eProveedor    CHAR(4)) 
			RETURNING CHAR(5),        --** Error vCodRet            vcodret                            
                      --CHAR(50),       --** Nombre Sucursal          vSucursal|| ' '||vNomSuc  
					  CHAR(4),       	--** Nombre Sucursal          vSucursal 
					  CHAR(45),         --** Nombre Sucursal          vNomSuc
                      DATE   ,        --** Fec. Operacion           vFecOpera                          
                      CHAR(50),       --** Desc. Status             vDesStatus                                 
                      CHAR(16),       --** Folio                    vFolio                             
                      DECIMAL(14,2),  --** Monto                    vMonto                             
                      CHAR(50),       --** CodTrans                 vDesCodTra                         
                      CHaR(4),        --** Cod Proveedor            vCodProveedor                      
                      CHAR(50),       --** Procedencia              vProcedencia  || ' '|| vDesProv    
                      CHAR(16),       --** folio Servicio           vFolioSer                          
                      CHAR(40),       --** Usuario                  vUsuario || ' ' || vNomUsuSol      
                      CHAR(4),        --** Status                   vStatus                            
                      CHAR(6),        --** Id ATM                   vIdatm
                      INTEGER,        --Biellete 1000
                      INTEGER,        --Biellete 500
                      INTEGER,        --Biellete 200
                      INTEGER,        --Biellete 100
                      INTEGER,        --Biellete 50
                      INTEGER,        --Biellete 20
                      INTEGER,        --Biellete 10
                      INTEGER,        --Biellete 5
                      INTEGER,        --Biellete 2
                      INTEGER,        --Biellete 1
                      INTEGER,        --Biellete .50  
                      CHAR(40),       --Nombre de codigo proveedor
                      INTEGER ,       --Posicion en reporte
                      money (18,2),   -- sdo caja 
                      CHAR(4);        --CC ATM


	DEFINE vCodRet       CHAR(5);
	DEFINE vWHERE        CHAR(300);
	DEFINE vPlaza        CHAR(4);
	DEFINE vSucursal     CHAR(4);
	DEFINE vNomSuc       CHAR(50);
	DEFINE vFecOpera     DATE;
	DEFINE vStatus       CHAR(4);
	DEFINE vFolio        CHAR(16);
	DEFINE vMonto        DECIMAL(14,2);
	DEFINE vUsuario      CHAR(8);
	DEFINE vCodProveedor CHAR(4);
	DEFINE vProcedencia  CHAR(4);
	DEFINE vFolioSer     CHAR(16);
	DEFINE vCodTrans     CHAR(4);
	DEFINE vNomUsuSol    CHAR(40);
	DEFINE vDesCodTra    CHAR(50);
	DEFINE vDesStatus    CHAR(70);
	DEFINE vDesProv      CHAR(40);
	DEFINE vCajGen       CHAR(1);
	DEFINE vIdatm        CHAR(15);
	DEFINE v1000         INTEGER;
	DEFINE v500          INTEGER;
	DEFINE v200          INTEGER;
	DEFINE v100          INTEGER;
	DEFINE v50           INTEGER;
	DEFINE v20           INTEGER;
	DEFINE v10           INTEGER;
	DEFINE v5            INTEGER;
	DEFINE v2            INTEGER;
	DEFINE v1            INTEGER;
	DEFINE vm50          INTEGER;
	DEFINE vnomprov      CHAR(40);   
	DEFINE sdo_caja      MONEY (18,2);
	DEFINE vcc_atm       CHAR(4);
	DEFINE iNoRegistros  INTEGER;
	DEFINE iPosReporte   SMALLINT;
	
	LET vCodRet       = "000";
	LET vWHERE        = '';
	LET vPlaza        = '';
	LET vSucursal     = '';
	LET vNomSuc       = '';
	LET vFecOpera     = '';
	LET vStatus       = '';
	LET vFolio        = '';
	LET vMonto        = 0;
	LET vUsuario      = '';
	LET vCodProveedor = '';
	LET vProcedencia   = '';
	LET vFolioSer     = '';
	LET vNomUsuSol    = '';
	LET vDesCodTra    = '';
	LET vDesStatus    = '';
	LET vDesProv      = '';
	LET vCajGen       = 'N';
	LET vIdatm        = '';
	lET v1000         = 0 ;
	lET v500          = 0 ;
	lET v200          = 0 ;
	lET v100          = 0 ;
	lET v50           = 0 ;
	lET v20           = 0 ;
	lET v10           = 0 ;
	lET v5            = 0 ;
	lET v2            = 0 ;
	lET v1            = 0 ;
	lET vm50          = 0 ;  
	LET vnomprov      = 0 ; 
	LET sdo_caja      = 0 ; 
	LET vcc_atm       = '';
	LET iNoRegistros  = 0 ;
	LET iPosReporte   = 0;
	
	BEGIN

		--SET debug file  to "monitor_isa.out";
		--trace on;
		SET DEBUG FILE TO "/tmp/mfinis/sp_monitor_operaciones3_2.out";
		TRACE ON;

		SET LOCK MODE TO WAIT 3; 
		SET ISOLATION TO DIRTY READ;

		LET eTipo = eTipo;
		LET eProveedor = eProveedor;
		LET vCodTrans  = eCodTrans;
		LET eFecInicio = eFecinicio;
		LET eFecFin    = eFecFin;

		IF eCodTrans = '' OR eCodTrans IS NULL THEN   --** Por operacion
			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio = MDY(1,1,2007);
			END IF

			IF eTipo = 'C' THEN
				LET vCajGen = eTipo;
			END IF
		
			FOREACH 
				SELECT b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans != '0'
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
					AND a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
									FROM bdinteg:"informix".si_sucursales
									WHERE sucursal != '0'
										AND empresa = eEmpresa
										AND tpo_sucursal = eTipo or tpo_sucursal = vCajGen)
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper
					AND b.cod_proveedor = eProveedor
					AND c.cod_proveedor = b.cod_proveedor
				ORDER BY UPPER(TRIM(c.descripcion)) ASC 

				SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre
				INTO vNomSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = vSucursal;

				SELECT descripcion
				INTO vDesStatus
				FROM bdisuc:"informix".ss_catstatus
				WHERE status = vStatus;

				SELECT nombre
				INTO vNomUsuSol   
				FROM bdinteg:"informix".si_ejecut     
				WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion) 
				INTO vDesCodTra 
				FROM bdisuc:"informix".ss_param_cajagen 
				WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion) 
				INTO vDesProv 
				FROM bdisuc:"informix".ss_cat_proveedor 
				WHERE codigo= vProcedencia;

				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, '' WITH RESUME; 
					
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;

			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;
			
		ELIF eProveedor = '0000' THEN

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF;

			IF eCodTrans in ('0001','0002','0010','0036','0041') THEN
				
					IF eCodTrans ='0001' THEN
						FOREACH 
								SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
										NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
								INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
								FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
								WHERE a.cod_trans = eCodTrans
									AND b.status IN ('01','03','05','11','08')
									AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
									AND(a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
														FROM bdinteg:"informix".si_sucursales
														WHERE sucursal != '0'
														AND empresa = eEmpresa
														AND tpo_sucursal = eTipo)
									OR a.sucursal IN (SELECT cod_proveedor
													FROM bdisuc:ss_proveedores
													WHERE cod_proveedor = b.cod_proveedor ))
														AND a.reversado IN ('0','1')
									AND a.folio_oper = b.folio_oper
									AND c.cod_proveedor = b.cod_proveedor 									
									ORDER BY UPPER(TRIM(c.descripcion)) ASC
							
							SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre 
							INTO vNomSuc 
							FROM bdinteg:"informix".si_sucursales 
							WHERE sucursal = vSucursal;                          

							SELECT descripcion
							INTO vDesStatus
							FROM bdisuc:"informix".ss_catstatus
							WHERE status = vStatus;

							SELECT nombre
							INTO vNomUsuSol
							FROM bdinteg:"informix".si_ejecut
							WHERE ejecutivo = vUsuario;

							SELECT TRIM(descripcion)
							INTO vDesCodTra
							FROM bdisuc:"informix".ss_param_cajagen
							WHERE codigo = vCodTrans;

							SELECT TRIM(descripcion)
							INTO vDesProv 
							FROM bdisuc:"informix".ss_cat_proveedor
							WHERE codigo= vProcedencia;

							SELECT id 
							INTO vIdatm 
							FROM  bdisuc:"informix".ss_relacionccid 
							WHERE cc = vSucursal;

							SELECT cantidad_1, cantidad_2 ,cantidad_3,cantidad_4,cantidad_5,cantidad_6, cantidad_7, cantidad_8, cantidad_9,cantidad_10,cantidad_11
							INTO v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50
							FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = vFolio;

							SELECT cc 
							INTO vcc_atm
							FROM  bdisuc:"informix".ss_relacionccid 
							WHERE cc = vSucursal;

							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,iPosReporte,0,vcc_atm WITH RESUME;
							
							LET iNoRegistros = iNoRegistros + 1;

						END FOREACH;
						
						IF iNoRegistros = 0 THEN
							LET vcodret = '001';
							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
						END IF;					

					ELSE

						FOREACH 
							SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
									NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
								INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
								FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
								WHERE a.cod_trans = eCodTrans
									AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
									AND( a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal 
													FROM bdinteg:"informix".si_sucursales
													WHERE sucursal != '0'
														AND empresa = eEmpresa
														AND tpo_sucursal = eTipo)
									OR a.sucursal IN (SELECT cod_proveedor
													FROM bdisuc:ss_proveedores
													WHERE cod_proveedor = b.cod_proveedor ))
									AND a.reversado IN ('0','1')
									AND a.folio_oper = b.folio_oper
									AND c.cod_proveedor = b.cod_proveedor
									ORDER BY UPPER(TRIM(c.descripcion)) ASC
								
							SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre
							INTO vNomSuc 
							FROM bdinteg:"informix".si_sucursales
							WHERE sucursal = vSucursal;                          

							SELECT descripcion
							INTO vDesStatus
							FROM bdisuc:"informix".ss_catstatus
							WHERE status = vStatus;

							SELECT nombre
							INTO vNomUsuSol
							FROM bdinteg:"informix".si_ejecut
							WHERE ejecutivo = vUsuario;

							SELECT TRIM(descripcion)
							INTO vDesCodTra
							FROM bdisuc:"informix".ss_param_cajagen
							WHERE codigo = vCodTrans;

							SELECT TRIM(descripcion)
							INTO vDesProv
							FROM bdisuc:"informix".ss_cat_proveedor
							WHERE codigo= vProcedencia;

							SELECT id
							INTO vIdatm
							FROM bdisuc:"informix".ss_relacionccid
							WHERE cc = vSucursal;

							SELECT cantidad_1, cantidad_2 ,cantidad_3,cantidad_4,cantidad_5,cantidad_6, cantidad_7, cantidad_8, cantidad_9,cantidad_10,cantidad_11
							INTO v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50
							FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = vFolio;

							SELECT cc
							INTO vcc_atm
							FROM bdisuc:"informix".ss_relacionccid
							WHERE cc = vSucursal;

							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,iPosReporte,0,vcc_atm WITH RESUME;


							LET iNoRegistros = iNoRegistros + 1;

						END FOREACH;
						
						IF iNoRegistros = 0 THEN
							LET vcodret = '001';
							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
						END IF;					
					END IF;

				--END IF;
		
			END IF;

		ELIF eSucursal <> '0000'  THEN   --** Por Sucursal

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF

			FOREACH
				SELECT b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans = eCodTrans
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
					AND a.sucursal = eSucursal
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper
					AND c.cod_proveedor = b.cod_proveedor
				ORDER BY UPPER(TRIM(c.descripcion)) ASC

				SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre 
				INTO vNomSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = vSucursal;

				SELECT descripcion
				INTO vDesStatus
				FROM bdisuc:"informix".ss_catstatus
				WHERE status = vStatus;

				SELECT nombre
				INTO vNomUsuSol
				FROM bdinteg:"informix".si_ejecut
				WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion)
				INTO vDesCodTra
				FROM bdisuc:"informix".ss_param_cajagen
				WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion)
				INTO vDesProv
				FROM bdisuc:"informix".ss_cat_proveedor
				WHERE codigo= vProcedencia;

				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
				
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;

		ELSE

			FOREACH
				SELECT a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores c
				WHERE a.cod_trans = eCodTrans
					AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin
					AND( a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} sucursal
										FROM bdinteg:"informix".si_sucursales
										WHERE sucursal != '0'
											AND empresa = eEmpresa
											AND tpo_sucursal = eTipo)
					OR a.sucursal IN (SELECT cod_proveedor
										FROM bdisuc:ss_proveedores
										WHERE cod_proveedor = eProveedor))
					AND a.reversado IN ('0','1')
					AND a.folio_oper    = b.folio_oper
					AND b.cod_proveedor = eProveedor
					AND c.cod_proveedor = b.cod_proveedor
				ORDER BY UPPER(TRIM(c.descripcion)) ASC

				SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre
				INTO vNomSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = vSucursal;

				SELECT descripcion
				INTO vDesStatus 
				FROM bdisuc:"informix".ss_catstatus 
				WHERE status = vStatus;

				SELECT nombre
				INTO vNomUsuSol
				FROM bdinteg:"informix".si_ejecut 
				WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion) 
				INTO vDesCodTra
				FROM bdisuc:"informix".ss_param_cajagen
				WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion)
				INTO vDesProv
				FROM bdisuc:"informix".ss_cat_proveedor
				WHERE codigo= vProcedencia;

				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
					
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;

		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 12/01/2015',
'DESCRIPCION: Clon del SPL de sp_monitor_operaciones para manejar la paginaciÃ?ÃÂ³n',
'vcodret = 001 -> No se encontraron datos',
'eTotalRes = 1 -> Recuperar registros con la sumatoria de las operaciones 0001,0002,0036,0041',
'AUTOR: L. Montserrat LeÃÂ³n Amador',
'FECHA: 08/10/2015',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor Operaciones', 
'DESCRIPCION: Se hizo la modificaciÃÂ³n para que el retorno de los registros se ordenara por descripciÃÂ³n caja general (descripcion)',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 25/10/2016',
'DESCRIPCION: Se realiza spl clon para que retorne el bloque total de registros.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_monitor_operaciones3_2(eEmpresa      CHAR(3),
                                                    eTipo         CHAR(1), --**C = ATM , S = Sucursal
                                                    eSucursal     CHAR(4),
                                                    eCodTrans     CHAR(4),  --Operacion
                                                    eFecInicio    DATE,
                                                    eFecFin       DATE,
                                                    eProveedor    CHAR(4)) 
			RETURNING CHAR(5),        --** Error vCodRet            vcodret                            
                      --CHAR(50),       --** Nombre Sucursal          vSucursal|| ' '||vNomSuc  
					  CHAR(4),       	--** Nombre Sucursal          vSucursal 
					  CHAR(45),         --** Nombre Sucursal          vNomSuc
                      DATE   ,        --** Fec. Operacion           vFecOpera                          
                      CHAR(50),       --** Desc. Status             vDesStatus                                 
                      CHAR(16),       --** Folio                    vFolio                             
                      DECIMAL(14,2),  --** Monto                    vMonto                             
                      CHAR(50),       --** CodTrans                 vDesCodTra                         
                      CHaR(4),        --** Cod Proveedor            vCodProveedor                      
                      CHAR(50),       --** Procedencia              vProcedencia  || ' '|| vDesProv    
                      CHAR(16),       --** folio Servicio           vFolioSer                          
                      CHAR(40),       --** Usuario                  vUsuario || ' ' || vNomUsuSol      
                      CHAR(4),        --** Status                   vStatus                            
                      CHAR(6),        --** Id ATM                   vIdatm
                      INTEGER,        --Biellete 1000
                      INTEGER,        --Biellete 500
                      INTEGER,        --Biellete 200
                      INTEGER,        --Biellete 100
                      INTEGER,        --Biellete 50
                      INTEGER,        --Biellete 20
                      INTEGER,        --Biellete 10
                      INTEGER,        --Biellete 5
                      INTEGER,        --Biellete 2
                      INTEGER,        --Biellete 1
                      INTEGER,        --Biellete .50  
                      CHAR(40),       --Nombre de codigo proveedor
                      INTEGER ,       --Posicion en reporte
                      money (18,2),   -- sdo caja 
                      CHAR(4);        --CC ATM


	DEFINE vCodRet       CHAR(5);
	DEFINE vWHERE        CHAR(300);
	DEFINE vPlaza        CHAR(4);
	DEFINE vSucursal     CHAR(4);
	DEFINE vNomSuc       CHAR(50);
	DEFINE vFecOpera     DATE;
	DEFINE vStatus       CHAR(4);
	DEFINE vFolio        CHAR(16);
	DEFINE vMonto        DECIMAL(14,2);
	DEFINE vUsuario      CHAR(8);
	DEFINE vCodProveedor CHAR(4);
	DEFINE vProcedencia  CHAR(4);
	DEFINE vFolioSer     CHAR(16);
	DEFINE vCodTrans     CHAR(4);
	DEFINE vNomUsuSol    CHAR(40);
	DEFINE vDesCodTra    CHAR(50);
	DEFINE vDesStatus    CHAR(70);
	DEFINE vDesProv      CHAR(40);
	DEFINE vCajGen       CHAR(1);
	DEFINE vIdatm        CHAR(15);
	DEFINE v1000         INTEGER;
	DEFINE v500          INTEGER;
	DEFINE v200          INTEGER;
	DEFINE v100          INTEGER;
	DEFINE v50           INTEGER;
	DEFINE v20           INTEGER;
	DEFINE v10           INTEGER;
	DEFINE v5            INTEGER;
	DEFINE v2            INTEGER;
	DEFINE v1            INTEGER;
	DEFINE vm50          INTEGER;
	DEFINE vnomprov      CHAR(40);   
	DEFINE sdo_caja      MONEY (18,2);
	DEFINE vcc_atm       CHAR(4);
	DEFINE iNoRegistros  INTEGER;
	DEFINE iPosReporte   SMALLINT;
	
	LET vCodRet       = "000";
	LET vWHERE        = '';
	LET vPlaza        = '';
	LET vSucursal     = '';
	LET vNomSuc       = '';
	LET vFecOpera     = '';
	LET vStatus       = '';
	LET vFolio        = '';
	LET vMonto        = 0;
	LET vUsuario      = '';
	LET vCodProveedor = '';
	LET vProcedencia   = '';
	LET vFolioSer     = '';
	LET vNomUsuSol    = '';
	LET vDesCodTra    = '';
	LET vDesStatus    = '';
	LET vDesProv      = '';
	LET vCajGen       = 'N';
	LET vIdatm        = '';
	lET v1000         = 0 ;
	lET v500          = 0 ;
	lET v200          = 0 ;
	lET v100          = 0 ;
	lET v50           = 0 ;
	lET v20           = 0 ;
	lET v10           = 0 ;
	lET v5            = 0 ;
	lET v2            = 0 ;
	lET v1            = 0 ;
	lET vm50          = 0 ;  
	LET vnomprov      = 0 ; 
	LET sdo_caja      = 0 ; 
	LET vcc_atm       = '';
	LET iNoRegistros  = 0 ;
	LET iPosReporte   = 0;
	
	BEGIN

		--SET debug file  to "monitor_isa.out";
		--trace on;
		--SET DEBUG FILE TO "/tmp/mfinis/Daniel/sp_monitor_operaciones3_2.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3; 
		SET ISOLATION TO DIRTY READ;

		LET eTipo = eTipo;
		LET eProveedor = eProveedor;
		LET vCodTrans  = eCodTrans;
		LET eFecInicio = eFecinicio;
		LET eFecFin    = eFecFin;

		IF eCodTrans = '' OR eCodTrans IS NULL THEN   --** Por operacion
			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio = MDY(1,1,2007);
			END IF

			IF eTipo = 'C' THEN
				LET vCajGen = eTipo;
			END IF
		
			FOREACH 
				SELECT 
				{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
				{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
				{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
				
				b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
				NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a
				INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
				INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
					WHERE  a.cod_trans != '0'
					AND	b.cod_proveedor = eProveedor
					AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
					AND a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal2)} sucursal
									FROM bdinteg:"informix".si_sucursales
									WHERE sucursal != '0'
										AND empresa = eEmpresa
										AND tpo_sucursal = eTipo or tpo_sucursal = vCajGen)
					AND a.reversado IN ('0','1')
				ORDER BY UPPER(TRIM(c.descripcion)) ASC 

				SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre
				INTO vNomSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = vSucursal;

				SELECT descripcion
				INTO vDesStatus
				FROM bdisuc:"informix".ss_catstatus
				WHERE status = vStatus;

				SELECT nombre
				INTO vNomUsuSol   
				FROM bdinteg:"informix".si_ejecut     
				WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion) 
				INTO vDesCodTra 
				FROM bdisuc:"informix".ss_param_cajagen 
				WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion) 
				INTO vDesProv 
				FROM bdisuc:"informix".ss_cat_proveedor 
				WHERE codigo= vProcedencia;

				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, '' WITH RESUME; 
					
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;

			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;
			
		ELIF eProveedor = '0000' THEN

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF;

			IF eCodTrans in ('0001','0002','0010','0036','0041') THEN
				
					IF eCodTrans ='0001' THEN
						FOREACH 

							SELECT 
							{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
							{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
							{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
							a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
							NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
								INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
							FROM bdisuc:"informix".ss_operaciones a 
							INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
							INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
							WHERE a.cod_trans = eCodTrans
								AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
							AND a.sucursal IN 
										(SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal2)} sucursal  
											FROM bdinteg:"informix".si_sucursales
											WHERE empresa = eEmpresa
											AND sucursal != '0'
											AND tpo_sucursal = eTipo
											UNION 
											SELECT a.cod_proveedor  	 
											FROM bdisuc:ss_proveedores a
											INNER JOIN bdisuc:"informix".ss_mae_entradasalida b 
											ON a.cod_proveedor = b.cod_proveedor)
								AND a.reversado IN ('0','1')
								AND b.status IN ('01','03','05','11','08')
							ORDER BY UPPER(TRIM(c.descripcion)) ASC
							
							SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre 
							INTO vNomSuc 
							FROM bdinteg:"informix".si_sucursales 
							WHERE sucursal = vSucursal;                          

							SELECT descripcion
							INTO vDesStatus
							FROM bdisuc:"informix".ss_catstatus
							WHERE status = vStatus;

							SELECT nombre
							INTO vNomUsuSol
							FROM bdinteg:"informix".si_ejecut
							WHERE ejecutivo = vUsuario;

							SELECT TRIM(descripcion)
							INTO vDesCodTra
							FROM bdisuc:"informix".ss_param_cajagen
							WHERE codigo = vCodTrans;

							SELECT TRIM(descripcion)
							INTO vDesProv 
							FROM bdisuc:"informix".ss_cat_proveedor
							WHERE codigo= vProcedencia;

							SELECT id 
							INTO vIdatm 
							FROM  bdisuc:"informix".ss_relacionccid 
							WHERE cc = vSucursal;

							SELECT cantidad_1, cantidad_2 ,cantidad_3,cantidad_4,cantidad_5,cantidad_6, cantidad_7, cantidad_8, cantidad_9,cantidad_10,cantidad_11
							INTO v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50
							FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = vFolio;

							SELECT cc 
							INTO vcc_atm
							FROM  bdisuc:"informix".ss_relacionccid 
							WHERE cc = vSucursal;

							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,iPosReporte,0,vcc_atm WITH RESUME;
							
							LET iNoRegistros = iNoRegistros + 1;

						END FOREACH;
						
						IF iNoRegistros = 0 THEN
							LET vcodret = '001';
							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
						END IF;					

					ELSE

						FOREACH 
								SELECT 
									{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
									{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
									{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
								a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
									NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans, 1 as pos_reporte
									INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer, vUsuario, vCodTrans, iPosReporte
									FROM bdisuc:"informix".ss_operaciones a 
									INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
									INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
									WHERE a.cod_trans = eCodTrans
									AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
									AND a.sucursal IN 
													(SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal2)} sucursal  
														FROM bdinteg:"informix".si_sucursales
														WHERE empresa = eEmpresa
														AND sucursal != '0'
														AND tpo_sucursal = eTipo
														UNION 
														SELECT a.cod_proveedor  	 
														FROM bdisuc:ss_proveedores a
														INNER JOIN bdisuc:"informix".ss_mae_entradasalida b 
														ON a.cod_proveedor = b.cod_proveedor)
									AND a.reversado IN ('0','1')
									AND a.folio_oper = b.folio_oper
									AND c.cod_proveedor = b.cod_proveedor
									ORDER BY UPPER(TRIM(c.descripcion)) ASC
														
							SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre
							INTO vNomSuc 
							FROM bdinteg:"informix".si_sucursales
							WHERE sucursal = vSucursal;                          

							SELECT descripcion
							INTO vDesStatus
							FROM bdisuc:"informix".ss_catstatus
							WHERE status = vStatus;

							SELECT nombre
							INTO vNomUsuSol
							FROM bdinteg:"informix".si_ejecut
							WHERE ejecutivo = vUsuario;

							SELECT TRIM(descripcion)
							INTO vDesCodTra
							FROM bdisuc:"informix".ss_param_cajagen
							WHERE codigo = vCodTrans;

							SELECT TRIM(descripcion)
							INTO vDesProv
							FROM bdisuc:"informix".ss_cat_proveedor
							WHERE codigo= vProcedencia;

							SELECT id
							INTO vIdatm
							FROM bdisuc:"informix".ss_relacionccid
							WHERE cc = vSucursal;

							SELECT cantidad_1, cantidad_2 ,cantidad_3,cantidad_4,cantidad_5,cantidad_6, cantidad_7, cantidad_8, cantidad_9,cantidad_10,cantidad_11
							INTO v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50
							FROM bdisuc:"informix".ss_operaciones WHERE folio_oper = vFolio;

							SELECT cc
							INTO vcc_atm
							FROM bdisuc:"informix".ss_relacionccid
							WHERE cc = vSucursal;

							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,vIdatm,v1000,v500,v200,v100,v50,v20,v10,v5,v2,v1,vm50,vnomprov,iPosReporte,0,vcc_atm WITH RESUME;


							LET iNoRegistros = iNoRegistros + 1;

						END FOREACH;
						
						IF iNoRegistros = 0 THEN
							LET vcodret = '001';
							RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
								vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
						END IF;					
					END IF;

				--END IF;
		
			END IF;

		ELIF eSucursal <> '0000'  THEN   --** Por Sucursal

			IF eFecInicio = '' OR eFecInicio IS NULL  THEN
				LET eFecInicio= MDY(1,1,2007);
			END IF

			FOREACH
				SELECT 
				{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
				{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
				{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
				{+INDEX (bdinteg:si_sucursales idx_sucursal)}
				
				b.sucursal,a.fecha_operacion,b.status,b.folio_oper,b.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a 
				INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
				INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
				WHERE a.cod_trans = eCodTrans
					AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
					AND a.sucursal = eSucursal
					AND a.reversado IN ('0','1')
				ORDER BY UPPER(TRIM(c.descripcion)) ASC

				SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre 
				INTO vNomSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = vSucursal;

				SELECT descripcion
				INTO vDesStatus
				FROM bdisuc:"informix".ss_catstatus
				WHERE status = vStatus;

				SELECT nombre
				INTO vNomUsuSol
				FROM bdinteg:"informix".si_ejecut
				WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion)
				INTO vDesCodTra
				FROM bdisuc:"informix".ss_param_cajagen
				WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion)
				INTO vDesProv
				FROM bdisuc:"informix".ss_cat_proveedor
				WHERE codigo= vProcedencia;

				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
				
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;

		ELSE

			FOREACH
				SELECT 
				{+INDEX (bdisuc:"informix".ss_operaciones idx01ss_operaciones)} 
				{+INDEX (bdisuc:"informix".ss_mae_entradasalida idx01ss_mae_entradasalida)}
				{+INDEX (bdisuc:"informix".ss_proveedores idx_provplaza)}
				a.sucursal,a.fecha_operacion,b.status,a.folio_oper,a.monto, b.cod_proveedor, c.descripcion,
					NVL(a.procedencia,''),b.folio_servicio,a.usuario,a.cod_trans
				INTO vSucursal,vFecOpera, vStatus,vFolio,vMonto, vCodProveedor,vnomprov,vProcedencia,vFolioSer,
					vUsuario,vCodTrans
				FROM bdisuc:"informix".ss_operaciones a
				INNER JOIN bdisuc:"informix".ss_mae_entradasalida b ON a.folio_oper = b.folio_oper
				INNER JOIN bdisuc:"informix".ss_proveedores c ON c.cod_proveedor = b.cod_proveedor 
				WHERE a.cod_trans = eCodTrans
					AND b.cod_proveedor = eProveedor
					AND a.fecha_operacion >= eFecInicio AND a.fecha_operacion <= eFecFin
					AND a.sucursal IN (SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal2)} sucursal
										FROM bdinteg:"informix".si_sucursales
										WHERE sucursal != '0'
											AND empresa = eEmpresa
											AND tpo_sucursal = eTipo
										UNION 
										SELECT cod_proveedor
										FROM bdisuc:ss_proveedores
										WHERE cod_proveedor = eProveedor)
					AND a.reversado IN ('0','1')
				ORDER BY UPPER(TRIM(c.descripcion)) ASC

				SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} nombre
				INTO vNomSuc
				FROM bdinteg:"informix".si_sucursales
				WHERE sucursal = vSucursal;

				SELECT descripcion
				INTO vDesStatus 
				FROM bdisuc:"informix".ss_catstatus 
				WHERE status = vStatus;

				SELECT nombre
				INTO vNomUsuSol
				FROM bdinteg:"informix".si_ejecut 
				WHERE ejecutivo = vUsuario;

				SELECT TRIM(descripcion) 
				INTO vDesCodTra
				FROM bdisuc:"informix".ss_param_cajagen
				WHERE codigo = vCodTrans;

				SELECT TRIM(descripcion)
				INTO vDesProv
				FROM bdisuc:"informix".ss_cat_proveedor
				WHERE codigo= vProcedencia;

				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0,'' WITH RESUME;
					
				LET iNoRegistros = iNoRegistros + 1;

			END FOREACH;
			
			IF iNoRegistros = 0 THEN
				LET vcodret = '001';
				RETURN vcodret, vSucursal, vNomSuc, vFecOpera, vDesStatus, vFolio, vMonto,vDesCodTra ,vCodProveedor,vProcedencia  || ' '|| vDesProv, 
					vFolioSer, vUsuario || ' ' || vNomUsuSol, vStatus,'',0,0,0,0,0,0,0,0,0,0,0,vnomprov,1,0, ''; 
			END IF;

		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 12/01/2015',
'DESCRIPCION: Clon del SPL de sp_monitor_operaciones para manejar la paginacion',
'vcodret = 001 -> No se encontraron datos',
'eTotalRes = 1 -> Recuperar registros con la sumatoria de las operaciones 0001,0002,0036,0041',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 08/10/2015',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor Operaciones', 
'DESCRIPCION: Se hizo la modificacion para que el retorno de los registros se ordenara por descripcion caja general (descripcion)',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 25/10/2016',
'DESCRIPCION: Se realiza spl clon para que retorne el bloque total de registros.',
'BD: bdisuc',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 24/11/2022',
'DESCRIPCION: Se colocan indices, se cambia join por sintaxis estandar y se optimiza consulta a si_sucursales y ss_proveedores',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_reportesdosuc()
RETURNING CHAR(6), CHAR(50);
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCodRetP CHAR(6);
DEFINE cCadena  CHAR (500);
DEFINE cRuta CHAR (50);
DEFINE cNombreArch CHAR (50);
DEFINE dtFechaHoy			DATE;
DEFINE dtFechaAyer    DATE;
DEFINE cMensajeRetP		CHAR(50);
DEFINE v_fecha DATE;
DEFINE v_sucursal CHAR(4); 
DEFINE v_nombre_suc CHAR(40); 
DEFINE v_denominacion_1 CHAR(18); 
DEFINE v_denominacion_2 CHAR(18); 
DEFINE v_denominacion_3 CHAR(18);
DEFINE v_denominacion_4 CHAR(18);  
DEFINE v_denominacion_5 CHAR(18); 
DEFINE v_denominacion_6 CHAR(18);
DEFINE v_denominacion_7 CHAR(18); 
DEFINE v_cantidad_1 DECIMAL(18,2); 
DEFINE v_cantidad_2 DECIMAL(18,2);
DEFINE v_cantidad_3 DECIMAL(18,2); 
DEFINE v_cantidad_4 DECIMAL(18,2); 
DEFINE v_cantidad_5 DECIMAL(18,2); 
DEFINE v_cantidad_6 DECIMAL(18,2); 
DEFINE v_cantidad_7 DECIMAL(18,2); 
DEFINE v_saldo_total DECIMAL(18,2);


LET iSqlErr = 0;
LET cCodRet = '000001';
LET cCodRetP = '00000';
LET cCadena = '';
LET cRuta = '';
LET cNombreArch = '';
LET dtFechaHoy			= DATE(1);
LET dtFechaAyer		= DATE(1);
LET cMensajeRetP 		= 'PROCESO EXITOSO';

LET v_fecha =DATE(1);
LET v_sucursal =''; 
LET v_nombre_suc =''; 
LET v_denominacion_1  ='';
LET v_denominacion_2  ='';
LET v_denominacion_3  ='';
LET v_denominacion_4  ='';  
LET v_denominacion_5  =''; 
LET v_denominacion_6  ='';
LET v_denominacion_7  ='';
LET v_cantidad_1 =0; 
LET v_cantidad_2 =0;
LET v_cantidad_3 =0;
LET v_cantidad_4 =0;
LET v_cantidad_5 =0;
LET v_cantidad_6 =0;
LET v_cantidad_7 =0;
LET v_saldo_total =0;


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
		
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/resplogifx/archivoscontabilidad/sp_reportesdosuc.out';
	--TRACE ON;
 
	--SE OBTIENE LA FECHA HOY Y AYER.
	SELECT fecha_hoy, fecha_ant 
	INTO dtFechaHoy, dtFechaAyer
	FROM bdinteg:"informix".si_fechas WHERE empresa = '001';	
	  
	LET cNombreArch='ss_saldossuc_'||LPAD(DAY(dtFechaAyer),2,0)||LPAD(MONTH(dtFechaAyer),2,0)||YEAR(dtFechaAyer)||'.txt';
    LET cRuta="/resplogifx/archivoscontabilidad/";                                              
	  
	IF NVL(cRuta,'') <> '' THEN
	
		LET cCadena = '';
		TRUNCATE TABLE ss_saldossuc_arqueo;
		
		FOREACH WITH HOLD
			SELECT a.fecha,a.sucursal,b.nombre,a.denominacion_1,a.denominacion_2,a.denominacion_3,a.denominacion_4,a.denominacion_5,a.denominacion_6,a.denominacion_7,a.cantidad_1, a.cantidad_2,a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7, a.saldo_total
			INTO v_fecha,v_sucursal, v_nombre_suc, v_denominacion_1, v_denominacion_2, v_denominacion_3, v_denominacion_4, v_denominacion_5, v_denominacion_6,v_denominacion_7, v_cantidad_1, v_cantidad_2, v_cantidad_3, v_cantidad_4, v_cantidad_5, v_cantidad_6, v_cantidad_7, v_saldo_total
			FROM bdisuc:ss_saldossuc a
			LEFT OUTER JOIN bdinteg:si_sucursales b 
			ON (a.empresa = b.empresa and a.sucursal = b.sucursal)
			WHERE a.fecha= dtFechaAyer 
			ORDER BY 1, 2

			LET v_saldo_total = (v_denominacion_1 * v_cantidad_1) + (v_denominacion_2 * v_cantidad_2) + (v_denominacion_3 * v_cantidad_3) + (v_denominacion_4 * v_cantidad_4) + (v_denominacion_5 * v_cantidad_5) + (v_denominacion_6 * v_cantidad_6) + v_cantidad_7;
			
			INSERT INTO ss_saldossuc_arqueo(fecha,sucursal,nombre_sucursal,denominacion_1,denominacion_2,denominacion_3,denominacion_4,denominacion_5,denominacion_6,denominacion_7,cantidad_1,cantidad_2,cantidad_3,cantidad_4,cantidad_5,cantidad_6,cantidad_7,saldo_total)
			VALUES(v_fecha,v_sucursal,v_nombre_suc,v_denominacion_1,v_denominacion_2,v_denominacion_3,v_denominacion_4,v_denominacion_5, v_denominacion_6,'1',v_cantidad_1,v_cantidad_2,v_cantidad_3,v_cantidad_4,v_cantidad_5,v_cantidad_6,v_cantidad_7,NVL(v_saldo_total,'0'));
	
		END FOREACH;
			
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreArch)  ||'  delimiter ''|'' SELECT * FROM bdisuc:"informix".ss_saldossuc_arqueo" > '||TRIM(cRuta)||'bit_carga.sql';				
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '||TRIM(cRuta)||'bit_carga.sql';
		System cCadena;		
		let cCadena = 'dbaccess bdisuc '||TRIM(cRuta)||'bit_carga.sql';
		System cCadena;				
		LET cCadena = '' ;
		LET cCadena = 'rm '|| TRIM(cRuta) ||'bit_carga.sql';
		SYSTEM cCadena;	
	END IF;
			
	RETURN cCodRetP, cMensajeRetP;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 24/feb/2019',
'BD    : BDISUC';

CREATE PROCEDURE "informix".sp_consulta_cajageneral(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(4) AS cIdProvCaja,
		CHAR(30) AS cDescCaja;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cIdProvCaja CHAR(4);
		DEFINE cDescCaja CHAR(30);
        DEFINE cPlazaCaja CHAR(3);
        DEFINE iNoRegistros INTEGER;

        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cIdProvCaja = '';
        LET cDescCaja = '';
        LET cPlazaCaja = '';
        LET iNoRegistros = 0;


        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cIdProvCaja, cDescCaja;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_cajageneral.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = ''  THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cIdProvCaja, cDescCaja;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cIdProvCaja, cDescCaja;
                END IF;

				SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;

                -- COMBOBOX CAJA GENERAL
			FOREACH
                SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor, descripcion, plaza
                INTO cIdProvCaja, cDescCaja, cPlazaCaja 
                FROM bdisuc:"informix".ss_proveedores ORDER BY UPPER(descripcion)

                LET iNoRegistros = iNoRegistros + 1;
                RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;   
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cIdProvCaja, cDescCaja;
			ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, cIdProvCaja, cDescCaja;
			END IF;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 03/09/2018',
'DESCRIPCION: SPL, que hace la consulta para el llenado del combobox caja general, Aumento Resta de Saldos Caja General',
'AUTOR: ING. JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 06/07/2023',
'DESCRIPCION: MODIFICACIÃN Se le agrego la paginaciÃ³n a la consulta.',
'BD: bdisuc';

CREATE PROCEDURE  "informix".sp_valfcfs_web_pbatrace(pusuario         char(4),
                                  pfecha_sucursal  date)

   RETURNING CHAR(5),
             DATE,
             SMALLINT;

   DEFINE cod_ret           CHAR(5);
   DEFINE sql_err           INTEGER;
   DEFINE vfecha_central    DATE;
   DEFINE vexiste           SMALLINT; 

-- *****************************************************************
-- Inicializa variables
-- *****************************************************************
   LET cod_ret           = "00000";
   LET vfecha_central    = "";

      SET DEBUG FILE TO "/DBA/INC/20240518/RESPALDO/bdisuc.sp_valfcfs_web.240518_trace.out";
      TRACE ON;


BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret,vfecha_central,vexiste;
      END IF;
   END EXCEPTION;

-- *****************************************************************
-- Valida los parametros de entrada
-- *****************************************************************
      IF pfecha_sucursal is null THEN 
         LET cod_ret = "00110";
         RETURN cod_ret,vfecha_central,vexiste;
      END IF
      
-- *****************************************************************
-- Valida la sucursal asignada,como el usuario del Pase Contable
-- *****************************************************************
   
   SELECT fecha_hoy 
   INTO vfecha_central
   FROM bdicont:co_fechas;
   
   IF EXISTS(SELECT usuario FROM bdicont:co_poldet_20240518 WHERE usuario = pusuario AND  
                     fecha_captura = pfecha_sucursal AND fecha_valida = vfecha_central) THEN
      LET vexiste = 0;
   ELSE
      LET vexiste = 1;
   END IF;
  

   IF not vfecha_central > pfecha_sucursal THEN
      --RETURN cod_ret,vfecha_central,vexiste;
   --ELSE
      LET vfecha_central = pfecha_sucursal;
   END IF;
    
    RETURN cod_ret,vfecha_central,vexiste;
END
END PROCEDURE;