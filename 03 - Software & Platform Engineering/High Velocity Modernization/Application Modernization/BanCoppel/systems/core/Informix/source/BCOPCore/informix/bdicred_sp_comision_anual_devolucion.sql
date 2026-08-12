CREATE PROCEDURE "informix".sp_comision_anual_devolucion(pempresa CHAR(3), pnum_credito CHAR(20), pusuario CHAR(8) )
RETURNING CHAR(5), CHAR(80), DECIMAL(16,2);       -- Codigo de Retorno, Mensaje de Retorno, Monto devolucion comision. 

---------------------------------------------------------------------------
--                         DEFINICION DE VARIABLES
---------------------------------------------------------------------------
DEFINE cCod_ret         CHAR(5);
DEFINE cCodRet2         CHAR(5);
DEFINE cMen_ret         CHAR(80);
DEFINE iSqlerr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE dMntoDevol       DECIMAL(16,2);

DEFINE dFech_1er_an     DATE;
DEFINE dFech_prox_an    DATE;
DEFINE dFech_prev_an    DATE;
DEFINE dFechaHoy        DATE;
DEFINE dFechaCobPrevT   DATE;
DEFINE dFechaPreDevol   DATE;
DEFINE dFechaDevol      DATE;
DEFINE dFechaTrspDevol	DATE;
DEFINE cCobro_an        CHAR(1);
DEFINE cNumCred         CHAR(20);
DEFINE cStatus_Cred     CHAR(2);
DEFINE dSdo_Capital     DECIMAL(18,2);
DEFINE mMntoTotCobT     DECIMAL(18,2); --MONEY;
DEFINE mMntoAplCobT     DECIMAL(18,2); --MONEY;
DEFINE mMntoTotCobA     DECIMAL(18,2); --MONEY;
DEFINE mMntoAplCobA     DECIMAL(18,2); --MONEY;
DEFINE dMntoDevolTit    DECIMAL(16,2);
DEFINE dMntoDevolAdi    DECIMAL(16,2);
DEFINE dMntoIvaDevol    DECIMAL(16,2);
DEFINE dMntoIvaCobr     DECIMAL(16,2);
DEFINE mMntoAnUsadAux   MONEY;
DEFINE sDiasTransCob       INTEGER;
DEFINE sDiasNoCobParam  INTEGER;
DEFINE sDiasTotAnio     SMALLINT;
DEFINE sPorcentNoCob    DECIMAL(18,2);
DEFINE cNumTarjeta      CHAR(20);
DEFINE cSucursal        CHAR(4);
DEFINE cFolioSuc        CHAR(16);
DEFINE cFolioSuc2       CHAR(16);
DEFINE iBloqueo         INTEGER;
DEFINE mRemantPrincp    MONEY(14,2);
DEFINE mIntMorPrincp    MONEY(14,2);
DEFINE mIntVenPrincp    MONEY(14,2);
DEFINE mCapVenPrincp    MONEY(14,2);
DEFINE mIntVigPrincp    MONEY(14,2);
DEFINE mCapVigPrincp    MONEY(14,2);
DEFINE mImpCobPrincp    MONEY(14,2);
DEFINE mComCobPrincp    MONEY(14,2);
DEFINE mSegCobPrincp    MONEY(14,2);

DEFINE cNumProducto					CHAR(4);
DEFINE cAplicaBoniAnual				CHAR(1);
DEFINE cRetBonificacionAnual		CHAR(5);
DEFINE cRetBonificacionMensual		CHAR(5);
DEFINE cRetBonificacionMensualAux	CHAR(5);
-----------------------------------------------------------------------------
--                         ASIGNACION DE VARIABLES                         --
-----------------------------------------------------------------------------
LET cCod_ret        = '00000';
LET cCodRet2        = '00000';
LET cMen_ret        = 'Proceso Exitoso';
LET iSqlerr         = 0;
LET iIsamErr        = 0;
LET dMntoDevol      = 0;
LET dFech_1er_an    = DATE(1);
LET dFech_prox_an   = DATE(1);
LET dFech_prev_an   = DATE(1);
LET dFechaHoy       = DATE(1);
LET dFechaCobPrevT  = DATE(1);
LET dFechaPreDevol  = DATE(1);
LET dFechaDevol     = DATE(1);
LET dFechaTrspDevol = DATE(1);
LET cCobro_an       = '';
LET cNumCred        = '';
LET cStatus_Cred    = '';
LET dSdo_Capital    = 0;
LET mMntoTotCobT    = 0;
LET mMntoAplCobT    = 0;
LET mMntoTotCobA    = 0;
LET mMntoAplCobA    = 0;
LET dMntoDevolTit   = 0;
LET dMntoDevolAdi   = 0;
LET dMntoIvaDevol   = 0;
LET dMntoIvaCobr    = 0;
LET mMntoAnUsadAux  = 0;
LET sDiasTransCob      = 0;
LET sDiasNoCobParam = 0;
LET sDiasTotAnio    = 0;
LET sPorcentNoCob   = 0;
LET cNumTarjeta     = '';
LET cSucursal       = '';
LET cFolioSuc       = '';
LET cFolioSuc2		= '';

LET iBloqueo        = 0;
LET mRemantPrincp   = 0;
LET mIntMorPrincp   = 0;
LET mIntVenPrincp   = 0;
LET mCapVenPrincp   = 0;
LET mIntVigPrincp   = 0;
LET mCapVigPrincp   = 0;
LET mImpCobPrincp   = 0;
LET mComCobPrincp   = 0;
LET mSegCobPrincp   = 0;

LET cNumProducto	 = '';
LET cAplicaBoniAnual = '';
LET cRetBonificacionAnual = '';
LET cRetBonificacionMensual = '';
LET cRetBonificacionMensualAux = '';

    -------------------------------------------------------------------------
    --                          CONTROL DE ERRORES                         --
    -------------------------------------------------------------------------

BEGIN
    ON EXCEPTION SET iSqlerr, iIsamErr, cMen_ret
        IF iSqlerr != 0 THEN
            LET cCod_ret = iSqlerr;
            LET dMntoDevol = 0;
            RETURN cCod_ret, cMen_ret, dMntoDevol;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/mahr/sp_comision_anual_devolucion.out";
    --TRACE ON;
    -------------------------------------------------------------------------
    --                          PROGRAMA PRINCIPAL                         --
    -------------------------------------------------------------------------

    IF NVL(pempresa, '') = '' OR NVL(pnum_credito,'') = '' THEN
        LET cCod_ret = '00001';		
        LET cMen_ret = 'Parametros incorrectos.';
        LET dMntoDevol = 0;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
	END IF;

    -- Obtiene la fecha actual
    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = pempresa;

    -- Se identifica si el credito tiene anualidad pendiente de cobrar.
    SELECT ind.num_credito, nvl(ind.fecha_1er_anualidad, date(1)), nvl(ind.fecha_prox_anualidad, date(1)), ind.cobro_anualidad, crd.status_cred, 
           dos.sdo_capital, crd.sucursal, nvl(date(fecha_pre_devol_anual), date(1)), nvl(date(fecha_devol_anual), date(1)), 
		   nvl(date(fecha_trasp_devol_anual),date(1)), crd.id_unidad_prod, crd.num_producto
      INTO cNumCred, dFech_1er_an, dFech_prox_an, cCobro_an, cStatus_Cred, dSdo_Capital, cSucursal, dFechaPreDevol, dFechaDevol, 
		   dFechaTrspDevol, iBloqueo, cNumProducto
      FROM bdicred:sd_indicador_cred ind JOIN bdicred:sd_maecred crd ON (ind.empresa = crd.empresa AND ind.num_credito = crd.num_credito)
      JOIN bdicred:sd_maesdos dos ON (ind.empresa = dos.empresa AND ind.num_credito = dos.num_credito)
     WHERE ind.empresa = pempresa AND ind.num_credito = pnum_credito;

    SELECT {+INDEX(bdicred:sd_tarjeta 217_886)}  --- {+INDEX(bdicred:sd_tarjeta 193_600)} -218-  --- BORRA -- cambiar por para MTY   
        tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
        WHERE tar.empresa = pempresa and tar.num_credito = pnum_credito and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
        where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') and tar.tipo_tarjeta = 'T'; 

    IF cNumCred IS NULL THEN
        LET cCod_ret = '00002';
        LET cMen_ret = 'Numero de credito no valido.';
        LET dMntoDevol = 0;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
    END IF;

    IF dFech_1er_an = date(1) THEN
        LET cCod_ret = '00000';
        LET cMen_ret = 'Credito no tiene anualidad cobrada previamente.';
        LET dMntoDevol = 0;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
    END IF;

    IF dFech_prox_an < dFechaHoy THEN
        LET cCod_ret = '00000';
        LET cMen_ret = 'No aplica devolucion de comision. Fecha proxima no valida.';
        LET dMntoDevol = 0;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
    END IF;
	
    -- No tiene anualidad cobrada previamente. No aplica devolucion de anualidad.
    IF (dFech_1er_an = dFech_prox_an) OR ((nvl(dFech_1er_an, date(1)) = date(1)) and (nvl(dFech_prox_an, date(1)) = date(1)) ) THEN
        LET cCod_ret = '00000';
        LET cMen_ret = 'No aplica devolucion de comision. No se ha realizado cobro previo.';
        LET dMntoDevol = 0;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
    END IF;
	
    -- Tiene fecha de pre-devolucion valida y fecha devolucion nula => No ha concluido el proceso de devolucion (precancelacion) y aun tiene saldo.
    IF ( nvl(dFechaPreDevol, date(1)) > date(1) AND nvl(dFechaDevol, date(1)) = date(1) AND nvl(dFechaTrspDevol,date(1)) = date(1)) 
	   AND dSdo_Capital != 0  THEN 
        LET cCod_ret = '00000';
        LET cMen_ret = 'Saldo incorrecto. Es necesario realizar el retiro de la devoluciÃ³n.';  -- Termina flujo, es necesario pasar a ventanilla
        LET dMntoDevol = dSdo_Capital;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
    END IF;	
	
	-- Verifica que el cliente realizo retiro en ventanilla y procede a cancelar el credito
    IF (nvl(dFechaPreDevol, date(1)) > date(1) AND nvl(dFechaDevol, date(1)) > date(1) AND nvl(dFechaTrspDevol,date(1)) = date(1)
		AND dSdo_Capital = 0 ) THEN 

		IF lower(pusuario) = 'informix' THEN  -- Si se ejecuta desde el job nocturno permita cancelar credito y deja continuar sp de cancelar.
			LET cCod_ret = '00000';
			LET cMen_ret = 'Devolucion correcta. Se cancelarÃ¡ el credito';
			LET dMntoDevol = 0;
			RETURN cCod_ret, cMen_ret, dMntoDevol;
		ELSE								  -- Si se ejecuta desde OFI no deje pasar la cancelacion, por que ya se hizo el retiro. Se cancela con job
			LET cCod_ret = '1208';
			LET cMen_ret = 'Retiro de devolucion correcto. Credito se cancelara';
			LET dMntoDevol = 0;
			RETURN cCod_ret, cMen_ret, dMntoDevol;
		END IF;
	END IF;	
	
    -- Verifica traspaso por no retiro de devolucion . Sdo != 0, el traspaso no se ha realizado correctamente.
    IF (nvl(dFechaPreDevol, date(1)) > date(1) AND nvl(dFechaDevol, date(1)) = date(1) AND nvl(dFechaTrspDevol,date(1)) > date(1)
		AND dSdo_Capital != 0 ) THEN 
		
		UPDATE bdicred:sd_indicador_cred SET fecha_trasp_devol_anual = NULL WHERE empresa = pempresa AND num_credito = pnum_credito;		
        LET cCod_ret = '00000';
        LET cMen_ret = 'No se ha realizado traspaso correctamente. Es necesario realizar traspaso o retiro';
        LET dMntoDevol = dSdo_Capital;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
	END IF;		

    -- Verifica traspaso por no retiro de devolucion. Se realizo traspaso, se cancelara cta
    IF (nvl(dFechaPreDevol, date(1)) > date(1) AND nvl(dFechaDevol, date(1)) = date(1) AND nvl(dFechaTrspDevol,date(1)) > date(1)
		AND dSdo_Capital = 0 ) THEN 
        LET cCod_ret = '00000';
        LET cMen_ret = 'Traspaso correcto. Se cancelara credito';
        LET dMntoDevol = 0;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
	END IF;			
	
	--JRVT CAMBIOS PROYECTO BONIFICACION ANUAL TDC 
	SELECT aplica_boni_anual INTO cAplicaBoniAnual FROM bdicred:sd_definicion WHERE empresa = '001' AND num_producto = cNumProducto;
	
	IF cAplicaBoniAnual <> '0' THEN--la bandera de aplica bonificacion esta prendida
		LET cCod_ret = '00000';
		LET cMen_ret = 'No aplica devolucion de comision. Bonificacion Anual otorgada.';
		LET dMntoDevol = 0;
		RETURN cCod_ret, cMen_ret, dMntoDevol;	
    END IF;	

    LET dFech_prev_an = monthadd(dFech_prox_an, -12);
	-- Obtiene el numero de dia de diferencia entre los dos aÃ±os
    LET sDiasTotAnio = mdy('01','01',year(dFech_prox_an)) - mdy('01','01',year(dFech_prev_an));
	
    -- Obtiene los dias no devengados. Dias que no se cubrieron para cumplir el aÃ±o. sDiasTransCob = Contiene  los dias transcurridos
    LET sDiasTransCob = date((dFechaHoy + 1 units day)) - date((dFech_prev_an - 1 units day));
	
    -- Obtiene el numero de dias parametro no devengados
    SELECT valor_numerico INTO sDiasNoCobParam FROM bdicred:sd_param_campania 
     WHERE empresa = pempresa AND tipo_campania = 70 AND grupo_parametro = 'COMI_ANUAL' AND num_parametro = 1;
	--	Dias total del aÃ±o - Dias transcurridos = dias no devengados.	// Dias no devengados sean menor a 30, no aplica devolucion.
    IF (sDiasTotAnio - sDiasTransCob) <= sDiasNoCobParam THEN -- Inicialmente sDiasNoCobParam = 30
        LET cCod_ret = '00000';
        LET cMen_ret = 'No aplica devolucion de comision. Proxima anualidad menor a 30 dias.';
        LET dMntoDevol = 0;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
    END IF;

    -- Verifica estatus de precancelacion y ya realizÃ³ el retiro de la devolucion. Para concluir proceso de devolucion de anualidad.
    IF (nvl(dFechaPreDevol, date(1)) > date(1) AND nvl(dFechaDevol, date(1)) = date(1) AND nvl(dFechaTrspDevol,date(1)) = date(1)
		AND iBloqueo = 4 AND dSdo_Capital = 0 ) THEN 
        --BEGIN WORK;
            -- Registra la fecha de devolucion de anualidad. Es decir, cuando se cancela el credito y .
            UPDATE bdicred:sd_indicador_cred SET fecha_devol_anual = CURRENT WHERE empresa = pempresa AND num_credito = pnum_credito;

            -- Elimina cobros pendientes en caso de tener mas de una en Parcialidad Titular, Parcialidad Adicional y Diferimiento Contable.
            UPDATE bdicred:sd_comision_x_apertura_contable SET afec_pendientes = 0 WHERE empresa = pempresa AND num_credito = pnum_credito 
               AND diferim_parcial IN ('PT', 'PA', 'DC') AND proceso_comision = 'ANUALIDAD' AND fecha_insert = dFech_prev_an;

            -- Elimina la marca de crÃ©dito bloqueado.
            -- UPDATE bdicred:sd_maecred SET id_unidad_prod = NULL WHERE empresa = pempresa AND num_credito = pnum_credito;
        --COMMIT WORK;

        LET cCod_ret = '00000';
        LET cMen_ret = 'Devolucion de comision por anualidad correcta';
        LET dMntoDevol = 0;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
    END IF;
	
    -- Verifica si es candidato a devolucion de comision por anualidad, a fin de iniciar proceso de pre-devolucion.
    SELECT MAX(fecha_insert) INTO dFechaCobPrevT FROM bdicred:sd_comision_x_apertura_contable
    WHERE empresa = pempresa AND num_credito = pnum_credito AND diferim_parcial = 'PT' AND proceso_comision = 'ANUALIDAD';
    IF dFechaCobPrevT != dFech_prev_an THEN -- Obtiene la fecha del ultimo cobro de comision por anualidad
        LET dFech_prev_an = dFechaCobPrevT;
    END IF;

    -- mMntoTotCob = Monto total de la comision / mMntoAplCob = Monto cobrado comision
    SELECT NVL(monto_afectacion,0), NVL(monto_aplicado,0) INTO mMntoTotCobT, mMntoAplCobT FROM bdicred:sd_comision_x_apertura_contable
     WHERE empresa = pempresa AND num_credito = pnum_credito AND diferim_parcial = 'PT' AND proceso_comision = 'ANUALIDAD' AND fecha_insert = dFech_prev_an;

    -- mMntoTotCobA = Monto total de la comision / mMntoAplCobA = Monto cobrado comision     
    SELECT NVL(monto_afectacion,0), NVL(monto_aplicado,0) INTO mMntoTotCobA, mMntoAplCobA FROM bdicred:sd_comision_x_apertura_contable
     WHERE empresa = pempresa AND num_credito = pnum_credito AND diferim_parcial = 'PA' AND proceso_comision = 'ANUALIDAD' AND fecha_insert = dFech_prev_an;

    -- Obtiene el porcentaje de anualidad no utilizado.
    LET sPorcentNoCob = (sDiasTotAnio - sDiasTransCob) / sDiasTotAnio;
    
    -- Obtiene el monto a abonar por TDC Titular y TDC Adicional. De los dias NO devengados (no usados)
    LET dMntoDevolTit = nvl((mMntoTotCobT * sPorcentNoCob),0);
    LET dMntoDevolAdi = nvl((mMntoTotCobA * sPorcentNoCob),0);

    IF mMntoTotCobT > mMntoAplCobT THEN -- Si la anualidad fue parcializada, y no ha sido pagada por completo = El total es mayor al pagado.

        LET mMntoAnUsadAux = mMntoTotCobT - dMntoDevolTit; -- Monto de anualidad usada. Correspondiente a los dias SI devengados.
        LET dMntoDevolTit = mMntoAplCobT - mMntoAnUsadAux; -- Monto de devolucion correspondiente al monto pagado de la anualidad. 

        IF mMntoTotCobA > mMntoAplCobA THEN -- Calcula el monto devolucion correspondiente al monto pagado en parcialidades.

            LET mMntoAnUsadAux = 0;
            LET mMntoAnUsadAux = mMntoTotCobA - dMntoDevolAdi; -- Monto de anualidad usada. Correspondiente a los dias SI devengados.
            LET dMntoDevolAdi = mMntoAplCobA - mMntoAnUsadAux; -- Monto de devolucion correspondiente al monto pagado de la anualidad. 
            IF dMntoDevolAdi < 0 THEN LET dMntoDevolAdi = 0; END IF;

        END IF;
    END IF;

    -- Realiza el abono del monto de la devolucion de la comision por anualidad
    IF dMntoDevolTit > 0 THEN

        -- Genera FolioSuc
        --EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina("informix")INTO cCodRet2, cFolioSuc;
		EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pusuario)INTO cCodRet2, cFolioSuc;
        IF cCodRet2 <> "000" THEN
            LET cCod_ret = '00004';
            LET cMen_ret = 'Error al obtener folio de operacion.';
            LET dMntoDevol = 0;
            RETURN cCod_ret, cMen_ret, dMntoDevol;
        END IF;

        LET cCodRet2 = '000';
        EXECUTE PROCEDURE bdicred:"informix".principal(pempresa, pnum_credito, 1, round((dMntoDevolTit + dMntoDevolAdi),0),USER,cSucursal,cFolioSuc,'8249')
           INTO cCodRet2, mRemantPrincp, mIntMorPrincp, mIntVenPrincp, mCapVenPrincp, mIntVigPrincp, mCapVigPrincp, mImpCobPrincp, mComCobPrincp, mSegCobPrincp;
        IF cCodRet2 <> "000" THEN
            LET cCod_ret = '00005';
            LET cMen_ret = 'Error al realizar devolucion a tdc.';
            LET dMntoDevol = 0;
            RETURN cCod_ret, cMen_ret, dMntoDevol;
        END IF;

        -- Obtiene el monto cargado con respecto a la comision anualidad para adicionales.
        SELECT nvl(SUM(monto),0) INTO dMntoIvaCobr
          FROM bdicred:sd_movhis WHERE empresa = pempresa AND fecha_mov >= dFech_prev_an AND fecha_mov < dFech_prox_an AND num_credito = pnum_credito
           AND codigo_fun = '340' AND codigo_ref IN (30,31) AND reversado = 'N';
        IF dMntoIvaCobr > 0 THEN

            -- Realiza el calculo para el iva.
            LET dMntoIvaDevol = dMntoIvaCobr * sPorcentNoCob;

            --- Realiza el deposito de la devoluciÃ³n del IVA
            LET cCodRet2 = '000';   LET mRemantPrincp = 0;  LET mIntMorPrincp = 0;  LET mIntVenPrincp = 0;  LET mCapVenPrincp = 0;
            LET mIntVigPrincp = 0;  LET mCapVigPrincp = 0;  LET mImpCobPrincp = 0;  LET mComCobPrincp = 0;  LET mSegCobPrincp = 0;
			
			-- Genera FolioSuc
			--EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina("informix")INTO cCodRet2, cFolioSuc2;
			EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pusuario)INTO cCodRet2, cFolioSuc2;
			IF cCodRet2 <> "000" THEN
				LET cCod_ret = '00004';
				LET cMen_ret = 'Error al obtener folio de operacion.';
				LET dMntoDevol = 0;
				RETURN cCod_ret, cMen_ret, dMntoDevol;
			END IF;
			
			IF cFolioSuc = cFolioSuc2 THEN
				EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina(pusuario)INTO cCodRet2, cFolioSuc;
				IF cCodRet2 <> "000" THEN
					LET cCod_ret = '00004';
					LET cMen_ret = 'Error al obtener folio de operacion.';
					LET dMntoDevol = 0;
					RETURN cCod_ret, cMen_ret, dMntoDevol;
				END IF;	
			ELSE
				LET cFolioSuc = cFolioSuc2;
			END IF;

            EXECUTE PROCEDURE bdicred:"informix".principal(pempresa, pnum_credito, 1, round(dMntoIvaDevol,0),USER,cSucursal,cFolioSuc,'8251')
               INTO cCodRet2, mRemantPrincp, mIntMorPrincp, mIntVenPrincp, mCapVenPrincp, mIntVigPrincp, mCapVigPrincp, mImpCobPrincp, mComCobPrincp, mSegCobPrincp;
            IF cCodRet2 <> "000" THEN
                LET cCod_ret = '00006';
                LET cMen_ret = 'Error al realizar devolucion de I.V.A. a tdc.';
                LET dMntoDevol = round((dMntoDevolTit + dMntoDevolAdi),0);
                --RETURN cCod_ret, cMen_ret, dMntoDevol;
            END IF;
        END IF;
    ELSE
        LET cCod_ret = '00000';
        LET cMen_ret = 'No aplica devolucion de comision. Calculo menor igual a 0.';
        LET dMntoDevol = 0;
        RETURN cCod_ret, cMen_ret, dMntoDevol;
    END IF;

	LET dMntoDevol = round((dMntoDevolTit + dMntoDevolAdi),0) + round(dMntoIvaDevol,0);

    -- Se realiza cambio de status para "bloquear el credito". 
    --BEGIN WORK;
        --  Establece la fecha de pre-cancelacion de la comision.
        UPDATE bdicred:sd_indicador_cred SET fecha_pre_devol_anual = CURRENT, monto_devolucion = dMntoDevol WHERE empresa = pempresa AND num_credito = pnum_credito;
        --  Marca el credito como "bloqueado", para que no pueda realizarse ningun movimiento al credito a partir de este punto hasta el retiro en ventanilla.
        UPDATE bdicred:sd_maecred SET id_unidad_prod = 4 WHERE empresa = pempresa AND num_credito = pnum_credito;
    --COMMIT WORK;

    LET cCod_ret = '00000';
    LET cMen_ret = 'Pre-devolucion correcta de comision por anualidad';
    --LET dMntoDevol = dMntoDevolTit + dMntoDevolAdi;
    --LET dMntoDevol = round(dMntoDevol,0);
    RETURN cCod_ret, cMen_ret, dMntoDevol;
   
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Identifica si el credito a cancelar le corresponde devolucion de comision por anualidad y realiza el deposito correspondiente.',
'AUTOR: Martha Angelica Hernandez Rodriguez',
'BD: bdicred ',
'FECHA: XXXX 2017',
'VERSION: 2017XXXX.1',
'MODIFICO: Juan Roman',
'DESCRIPCION: Se agrega validacion de la bandera de bonificacion del producto para evitar calcular el reembolso de la anualidad cobrada ',
'FECHA DE MODIFICACIÃN: 08 de Noviembre de 2024',
'BD: BDICRED',
'FOLIO: RQM 10 1669 INCREMENTALES TDC';

CREATE PROCEDURE "informix".sp_monto_promociones_bonificacion(pEmpresa CHAR(3), pCredito CHAR(20), pPeriodoInicio DATE, pPeriodoFinal DATE, pNumProducto CHAR(4), pBanderaMovMSI CHAR(1))
   RETURNING CHAR(5),
			 DECIMAL(16,2);
			 
   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   /*
   pEmpresa					Parametro estandar en los spl, ocupado en indices de busquedas.
   pCredito					Parametro que contiene el numero de crèdito a consultar/validar.
   pPeriodoInicio			Parametro que contiene la fecha inicio de busqueda de promocines.
   pPeriodoFinal			Parametro que contiene la fecha final de busqueda de promiciones, si la fecha es nula, tomarà la fecha hoy.
   pNumProducto				Parametro que sera utilizado para realizar las consultas a los paràmetros y sus validaciones.
   pBanderaHistorico		Parametro que ayudarà a determinar en que tablas se realizara la bùsqueda.
   */
	DEFINE cCod_ret         	CHAR(5);
	DEFINE cMen_ret         	CHAR(80);
	DEFINE iSqlerr          	INTEGER;
	DEFINE iIsamErr         	INTEGER;
	DEFINE dMonto	 			DECIMAL(16,2);
	DEFINE dMontoTotal 			DECIMAL(16,2);
	DEFINE cNumCreditoMSI		CHAR(20);
	
	LET cCod_ret			= '00000';
	LET cMen_ret			= '';
	LET iSqlerr 			= 0;
	LET iIsamErr			= 0;
	LET dMonto				= 0;
	LET dMontoTotal			= 0;
	LET cNumCreditoMSI		= '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlerr, iIsamErr, cMen_ret
			IF iSqlerr != 0 THEN
				LET cCod_ret = iSqlerr;
				
				RETURN cCod_ret,dMontoTotal;
			END IF;
		END EXCEPTION;
		
		--si el valor de esta variable es 0, quiere decir que los cargos se contaràn mensualmente Y NO LA SUMA TOTAL de la compra por MSI.
		--SELECT cargos_activacion_msi INTO cCargoActiva_MSI FROM sd_definicion WHERE empresa = pEmpresa AND num_producto = pNumProducto;
		
		FOREACH WITH HOLD
				
				SELECT num_sol_prestamo INTO cNumCreditoMSI FROM sd_promocion_credito 
					WHERE empresa = pEmpresa AND status NOT IN ('8') and num_promo = '10' AND num_credito = pCredito 
				
				IF pBanderaMovMSI = '1' THEN --ACTIVACIÒN DE MONTOS TOTALES MSI
					
					SELECT SUM(monto) INTO dMonto FROM 
					(
						SELECT SUM(monto) monto FROM sd_movhiscrd
							WHERE empresa = pEmpresa AND num_credito = cNumCreditoMSI  
								AND codigo_fun = '002' AND codigo_ref = '128' AND fecha_mov >= pPeriodoInicio AND fecha_mov <= pPeriodoFinal
						UNION ALL
						SELECT SUM(monto) monto FROM sd_movdiacrd
							WHERE empresa = pEmpresa AND num_credito = cNumCreditoMSI  
								AND codigo_fun = '002' AND codigo_ref = '128' AND fecha_mov = pPeriodoFinal
					);
					
					LET dMontoTotal = dMontoTotal + NVL(dMonto,0);
				ELSE--CARGOS MENSUALES MSI
				
					SELECT SUM(monto) INTO dMonto FROM 
					(
						SELECT SUM(monto) monto FROM sd_movhis 
							WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND SUBSTR(referencia, 18, 12) = cNumCreditoMSI AND fecha_mov >= pPeriodoInicio AND fecha_mov <= pPeriodoFinal
						UNION ALL
						SELECT SUM(monto) monto FROM sd_movdia 
							WHERE empresa = pEmpresa AND num_credito = pCredito 
								AND SUBSTR(referencia, 18, 12) = cNumCreditoMSI AND fecha_mov = pPeriodoFinal
					);
					
					LET dMontoTotal = dMontoTotal + NVL(dMonto,0);
				END IF;	
			END FOREACH;
	
	RETURN cCod_ret,dMontoTotal;
	END;
END PROCEDURE
   
;