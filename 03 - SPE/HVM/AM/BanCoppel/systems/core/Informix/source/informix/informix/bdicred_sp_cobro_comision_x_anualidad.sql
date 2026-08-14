CREATE PROCEDURE "informix".sp_cobro_comision_x_anualidad(pempresa CHAR(3))
RETURNING CHAR(5);       -- Codigo de Retorno 
--EXECUTE PROCEDURE sp_cobro_comision_x_anualidad('001');
---------------------------------------------------------------------------
--                         DEFINICION DE VARIABLES
---------------------------------------------------------------------------
DEFINE cCod_ret         CHAR(5);
DEFINE cMen_ret         CHAR(80);
DEFINE iSqlerr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cCodRet2         CHAR(5);
DEFINE cCodRet3         CHAR(5);
DEFINE cCobro_com_6001  CHAR(1);
DEFINE cCobro_com_7000  CHAR(1);
DEFINE cCobro_com_8100  CHAR(1);
DEFINE cCobro_com_5400  CHAR(1);
--JRVT BONIFICACIÓN--
DEFINE cAplica_bonificacion_anual_6001  	CHAR(1);
DEFINE cAplica_bonificacion_anual_7000  	CHAR(1);
DEFINE cAplica_bonificacion_anual_8100  	CHAR(1);
DEFINE cAplica_bonificacion_anual_5400  	CHAR(1);
DEFINE sDispercionTitular_7000				SMALLINT;
DEFINE sDispercionTitular_8100              SMALLINT;
DEFINE sDispercionAdicional_8100            SMALLINT;
DEFINE sDispercionTitular_5400              SMALLINT;
DEFINE sDispercionAdicional_5400            SMALLINT;
--JRVT BONIFICACIÓN--
DEFINE cCom_Titul_6001  CHAR(1);
DEFINE cCom_Adic_6001   CHAR(1);
DEFINE cCom_Titul_7000  CHAR(1);
DEFINE cCom_Adic_7000   CHAR(1);
DEFINE cCom_Titul_8100  CHAR(1);
DEFINE cCom_Adic_8100   CHAR(1);
DEFINE cCom_Titul_5400	CHAR(1);
DEFINE cCom_Adic_5400   CHAR(1);
DEFINE cFech_1er_anual  CHAR(1);
DEFINE cFech_1er_an6001 CHAR(1);
DEFINE cFech_1er_an7000 CHAR(1);
DEFINE cFech_1er_an8100 CHAR(1);
DEFINE cFech_1er_an5400 CHAR(1);
DEFINE iMnto_AnTit_6001 DECIMAL(16,2);
DEFINE iMnto_AnAdi_6001 DECIMAL(16,2);
DEFINE iMnto_AnTit_7000 DECIMAL(16,2);
DEFINE iMnto_AnAdi_7000 DECIMAL(16,2);
DEFINE iMnto_AnTit_8100 DECIMAL(16,2);
DEFINE iMnto_AnAdi_8100 DECIMAL(16,2);
DEFINE iMnto_AnTit_5400 DECIMAL(16,2);
DEFINE iMnto_AnAdi_5400 DECIMAL(16,2);
DEFINE iMnto_Cobr_ComTi DECIMAL(16,2);
DEFINE iMnto_Cobr_ComAd DECIMAL(16,2);
DEFINE dCob_Parc_6001   SMALLINT;
DEFINE dCob_Parc_7000   SMALLINT;
DEFINE dCob_Parc_8100   SMALLINT;
DEFINE dCob_Parc_5400   SMALLINT;
--JRVT BONIFICACIÓN--
DEFINE dImporte_boni_anual_6001 	DECIMAL (9,2);
DEFINE dImporte_boni_anual_7000 	DECIMAL (9,2);
DEFINE dImporte_boni_mensual_7000 	DECIMAL (9,2);
DEFINE dImporte_boni_anual_8100 	DECIMAL (9,2);
DEFINE dImporte_boni_mensual_8100 	DECIMAL (9,2);
DEFINE dImporte_boni_anual_5400 	DECIMAL (9,2);
DEFINE dImporte_boni_mensual_5400 	DECIMAL (9,2);
DEFINE dImporte_boni_primer_mes_7000 	DECIMAL (9,2);
DEFINE dImporte_boni_primer_mes_8100 	DECIMAL (9,2);
DEFINE dImporte_boni_primer_mes_5400 	DECIMAL (9,2);

--JRVT BONIFICACIÓN--
DEFINE cNumCred         CHAR(20);
DEFINE cNumCte          CHAR(20);
DEFINE cNumTarjeta      CHAR(20);
DEFINE cSucursal        CHAR(4);
DEFINE cStatusCred      CHAR(2);
DEFINE dFechaAlta       DATE;
DEFINE dFecha1erDisp    DATE;
DEFINE dFecha1erComp    DATE;
DEFINE dFechaMenor      DATE;
DEFINE dFecha1erAnual   DATE;
DEFINE dFechaProxAnual  DATE;
DEFINE dFechaActivTdc   DATE;
DEFINE dFechaHoy        DATE;
DEFINE dFecha_Pag_Anualidad DATE;
DEFINE sAniosDif        SMALLINT;
DEFINE dSucIva          DECIMAL(5,3);
DEFINE cFolioSuc        CHAR(16);
DEFINE cFolioSucBoni    CHAR(16);
DEFINE dSaldoFavor      DECIMAL(14,2);
DEFINE dDifMontoFavor   DECIMAL(14,2);
DEFINE dMntoDifTotalTit DECIMAL(14,2);
DEFINE dMntoDifTotalAdi DECIMAL(14,2);
DEFINE cMensajeMov      CHAR(25);

DEFINE dMontoTot        DECIMAL(16,2);
DEFINE dMontoApli       DECIMAL(16,2);
DEFINE iAfecPend        INTEGER;
DEFINE dFechProxPag     DATE;
DEFINE dFechProxPagCalc DATE;
DEFINE sTotalCobros     SMALLINT;
DEFINE dDifer_Parcial   CHAR(2);
DEFINE iMnto_Cobro      DECIMAL(16,2);
DEFINE cProceso         CHAR(4);
DEFINE cCod_retIB		CHAR(6);
DEFINE sExiste_T_Adic   SMALLINT;

--Variables retorno principal
DEFINE mRemantPrincp    MONEY(14,2);
DEFINE mIntMorPrincp    MONEY(14,2);
DEFINE mIntVenPrincp    MONEY(14,2);
DEFINE mCapVenPrincp    MONEY(14,2);
DEFINE mIntVigPrincp    MONEY(14,2);
DEFINE mCapVigPrincp    MONEY(14,2);
DEFINE mImpCobPrincp    MONEY(14,2);
DEFINE mComCobPrincp    MONEY(14,2);
DEFINE mSegCobPrincp    MONEY(14,2);
DEFINE mDiferenciaMonto MONEY(14,2);

---------------------------------------------------------------------------
-- *                        ASIGNACION DE VARIABLES
---------------------------------------------------------------------------

LET cCod_ret            = "00000";
LET cMen_ret            = "Proceso Exitoso";
LET iSqlerr             = 0;
LET iIsamErr            = 0;
LET cCodRet2            = '';
LET cCodRet3            = '';
LET cCobro_com_6001     = '';
LET cCobro_com_7000     = '';
LET cCobro_com_8100     = '';
LET cCobro_com_5400     = '';
LET cCom_Titul_6001     = '';
LET cCom_Adic_6001      = '';
LET cCom_Titul_7000     = '';
LET cCom_Adic_7000      = '';
LET cCom_Titul_8100     = '';
LET cCom_Adic_8100      = '';
LET cCom_Titul_5400     = '';
LET cCom_Adic_5400      = '';
LET cFech_1er_an6001    = '';
LET cFech_1er_an7000    = '';
LET cFech_1er_an8100    = '';
LET cFech_1er_an5400    = '';
LET iMnto_AnTit_6001    = 0;
LET iMnto_AnAdi_6001    = 0;
LET iMnto_AnTit_7000    = 0;
LET iMnto_AnAdi_7000    = 0;
LET iMnto_AnTit_8100    = 0;
LET iMnto_AnAdi_8100    = 0;
LET iMnto_AnTit_5400    = 0;
LET iMnto_AnAdi_5400    = 0;
LET iMnto_Cobr_ComTi    = 0;
LEt iMnto_Cobr_ComAd    = 0;
LET dCob_Parc_6001      = 0;
LET dCob_Parc_7000      = 0;
LET dCob_Parc_8100      = 0;
LET dCob_Parc_5400      = 0;
LET cNumCred            = '';
LET cNumCte             = '';
LET cNumTarjeta         = '';
LET cSucursal           = '';
LET cStatusCred         = '';
LET dFechaAlta          = DATE(1);
LET dFecha1erDisp       = DATE(1);
LET dFecha1erComp       = DATE(1);
LET dFechaMenor         = DATE(1);
LET dFecha1erAnual      = DATE(1);
LET dFechaProxAnual     = DATE(1);
LET dFechaActivTdc      = DATE(1);
LET dFechaHoy           = DATE(1);
LET dFecha_Pag_Anualidad= DATE(1);
LET sAniosDif           = 0;
LET dSucIva             = 0;
LET cFolioSuc           = '';
LET cFolioSucBoni       = '';
LET dSaldoFavor         = 0;
LET dDifMontoFavor      = 0;
LET dMntoDifTotalTit    = 0;
LET dMntoDifTotalAdi    = 0;
LET cMensajeMov         = '';
 
LET dMontoTot           = 0;
LET dMontoApli          = 0;
LET iAfecPend           = 0;
LET dFechProxPag        = Date(1);
LET dFechProxPagCalc    = Date(1);
LET sTotalCobros        = 0;
LET dDifer_Parcial      = '';
LET iMnto_Cobro         = 0;
LET cProceso            = '0087';
LET cCod_retIB          = '000000';
LET sExiste_T_Adic      = 0;

--JRVT BONIFICACIÓN--
LET cAplica_bonificacion_anual_6001 	= '';
LET cAplica_bonificacion_anual_7000 	= '';
LET cAplica_bonificacion_anual_8100  	= '';
LET cAplica_bonificacion_anual_5400  	= '';
LET dImporte_boni_anual_6001 	= 0;
LET dImporte_boni_anual_7000 	= 0;
LET dImporte_boni_mensual_7000 	= 0;
LET dImporte_boni_anual_8100 	= 0;
LET dImporte_boni_mensual_8100 	= 0;
LET dImporte_boni_anual_5400 	= 0;
LET dImporte_boni_mensual_5400 	= 0;
LET mRemantPrincp = 0;
LET mIntMorPrincp = 0;
LET mIntVenPrincp = 0;
LET mCapVenPrincp = 0;
LET mIntVigPrincp = 0;
LET mCapVigPrincp = 0;
LET mImpCobPrincp = 0;
LET mComCobPrincp = 0;
LET mSegCobPrincp = 0;

LET sDispercionTitular_7000	= 0;
LET sDispercionTitular_8100 = 0; 
LET sDispercionAdicional_8100 = 0;
LET sDispercionTitular_5400 = 0; 
LET sDispercionAdicional_5400 = 0;
LET mDiferenciaMonto = 0;

--JRVT BONIFICACIÓN--

    ---------------------------------------------------------------------------
    -- *                        CONTROL DE ERRORES
    ---------------------------------------------------------------------------

BEGIN
    ON EXCEPTION SET iSqlerr, iIsamErr, cMen_ret
        IF iSqlerr != 0 THEN
			
            LET cCod_ret=iSqlerr;
            CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'ERROR COMISION ANUALIDAD '||'-'||iIsamErr::CHAR, '02') Returning cCod_retIB;
            RETURN cCod_ret;
        END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 4;

    ---------------------------------------------------------------------------
    -- *                        PROGRAMA PRINCIPAL
    ---------------------------------------------------------------------------
	
	--SET DEBUG FILE TO "/home/e90402183/INCIDENCIAS/bonificacion_tdc/sp_cobro_comision_x_anualidad.out";
	--TRACE ON;

    CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'INICIA COBRO COMISION POR ANUALIDAD TDC', '02') Returning cCod_RetIB;

    -- Obtiene la fecha actual
    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = pempresa;

    -- Genera FolioSuc
	EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina("informix")INTO cCodRet2, cFolioSuc;

    -- Parametros: cobro_comision_anual: 0 = NO Cobro Anualidad, 1 = Cobro anualidad // cobro_anual_titular, cobro_anual_adicional: Como a TDC Titular y adicional
    --      // fecha_1er_cobro_anual: 0.- Cargo en fecha de 1er compra/disposicion, 1.- Cargo en fecha activacion, 2.- Cargo en fecha 1er aniversario activacion
    --      // cobro_parcializ_anual: Cobro de mensualidad en parcialidades: 1, 2 o 3
	--JRVT SE AGREGAN NUEVOS CAMPOS A LA CONSULTA PARA BONIFICACIÓN
	--aplica_boni_anual: 0 = NO bonificacion anual PRODUCTO | 1 = SI bonificacion anual PRODUCTO
    --importe_boni_anual: CANTIDAD a la que deben llegar para su bonificacion
	SELECT cobro_comision_anual, cobro_anual_titular, cobro_anual_adicional, fecha_1er_cobro_anual, cobro_parcializ_anual,
		   aplica_boni_anual,importe_boni_anual
      INTO cCobro_com_6001, cCom_Titul_6001, cCom_Adic_6001, cFech_1er_an6001, dCob_Parc_6001,
		   cAplica_bonificacion_anual_6001,dImporte_boni_anual_6001
      FROM bdicred:sd_definicion WHERE num_producto = '6001';

    SELECT cobro_comision_anual, cobro_anual_titular, cobro_anual_adicional, fecha_1er_cobro_anual, cobro_parcializ_anual,
		   aplica_boni_anual,importe_boni_anual,importe_boni_mensual,importe_boni_primer_mes
      INTO cCobro_com_7000, cCom_Titul_7000, cCom_Adic_7000, cFech_1er_an7000, dCob_Parc_7000,
		   cAplica_bonificacion_anual_7000,dImporte_boni_anual_7000,dImporte_boni_mensual_7000,dImporte_boni_primer_mes_7000
     FROM bdicred:sd_definicion WHERE num_producto = '7000';

    SELECT cobro_comision_anual, cobro_anual_titular, cobro_anual_adicional, fecha_1er_cobro_anual, cobro_parcializ_anual,
		   aplica_boni_anual,importe_boni_anual,importe_boni_mensual,importe_boni_primer_mes
      INTO cCobro_com_8100, cCom_Titul_8100, cCom_Adic_8100, cFech_1er_an8100, dCob_Parc_8100,
		   cAplica_bonificacion_anual_8100,dImporte_boni_anual_8100,dImporte_boni_mensual_8100,dImporte_boni_primer_mes_8100
      FROM bdicred:sd_definicion WHERE num_producto = '8100';
	  
	 SELECT cobro_comision_anual, cobro_anual_titular, cobro_anual_adicional, fecha_1er_cobro_anual, cobro_parcializ_anual,
		   aplica_boni_anual,importe_boni_anual,importe_boni_mensual,importe_boni_primer_mes
      INTO cCobro_com_5400, cCom_Titul_5400, cCom_Adic_5400, cFech_1er_an5400, dCob_Parc_5400,
		   cAplica_bonificacion_anual_5400,dImporte_boni_anual_5400,dImporte_boni_mensual_5400,dImporte_boni_primer_mes_5400
      FROM bdicred:sd_definicion WHERE num_producto = '5400';

    IF cCobro_com_6001 IS NULL OR cCobro_com_7000 IS NULL OR cCobro_com_8100 IS NULL OR cCobro_com_5400 IS NULL THEN
        LET cCod_ret = '00001';		
		RETURN cCod_ret;    -- No existen parametros correctos
    END IF;
    IF cFech_1er_an6001 IS NULL OR cFech_1er_an7000 IS NULL OR cFech_1er_an8100 IS NULL OR cFech_1er_an5400 IS NULL THEN
        LET cCod_ret = '00002';	
		RETURN cCod_ret;	-- No existen parametros correctos
    END IF;
    IF NVL(dCob_Parc_6001,0) = 0 OR NVL(dCob_Parc_7000,0) = 0 OR NVL(dCob_Parc_8100, 0) = 0 OR NVL(dCob_Parc_5400,0) = 0 THEN
        LET cCod_ret = '00003';
		RETURN cCod_ret;    -- No existen parametros correctos
    END IF;

    -- Monto de Cobro de comision para tarjetas titulares y adicionales.
    SELECT monto INTO iMnto_AnTit_6001 FROM bdicred:sd_tpcomis WHERE cod_comis = 'CAVT';
    SELECT monto INTO iMnto_AnAdi_6001 FROM bdicred:sd_tpcomis WHERE cod_comis = 'CAVA';
    SELECT monto INTO iMnto_AnTit_7000 FROM bdicred:sd_tpcomis WHERE cod_comis = 'CAPT';
    SELECT monto INTO iMnto_AnAdi_7000 FROM bdicred:sd_tpcomis WHERE cod_comis = 'CAPA';
    SELECT monto INTO iMnto_AnTit_8100 FROM bdicred:sd_tpcomis WHERE cod_comis = 'CAOT';
    SELECT monto INTO iMnto_AnAdi_8100 FROM bdicred:sd_tpcomis WHERE cod_comis = 'CAOA';
    SELECT monto INTO iMnto_AnTit_5400 FROM bdicred:sd_tpcomis WHERE cod_comis = 'CA54';
    SELECT monto INTO iMnto_AnAdi_5400 FROM bdicred:sd_tpcomis WHERE cod_comis = 'CA5A';

	IF cCobro_com_6001 = '1' AND cCom_Titul_6001 = '1' THEN   -- Realiza el cobro para TDC Visa 6001.

        CALL bdicred:sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'INICIA COBRO COMISION ANUALIDAD - 6001', '02') Returning cCod_RetIB;
     
        FOREACH WITH HOLD       -- Obtiene la fecha de  1er cargo de anualidad
            SELECT {+INDEX(bdicred:sd_maecred maecred3)} 
              crd.num_credito, crd.numcte, crd.sucursal, crd.status_cred, ind.fecha_alta, nvl(f_primer_compra,date(1)), nvl(f_primer_disp,date(1))
              INTO cNumCred, cNumCte, cSucursal, cStatusCred, dFechaAlta, dFecha1erComp, dFecha1erDisp
              FROM bdicred:sd_maecred crd JOIN bdicred:sd_indicador_cred ind 
                ON (crd.empresa = ind.empresa and crd.num_credito = ind.num_credito and crd.status_cred in ('AA','BA','BT','E1','E2','E3') and crd.num_producto = '6001')
             WHERE NVL(ind.fecha_1er_anualidad, date(1)) = date(1) AND ind.cobro_anualidad = '1'

            SELECT {+INDEX(bdicred:sd_tarjeta 217_886)}  --- llave 218 {+INDEX(bdicred:sd_tarjeta 193_600)}
                tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
                WHERE tar.empresa = pempresa and tar.num_credito = cNumCred and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
                where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') and tar.tipo_tarjeta = 'T'; 

            SELECT limit 1 date(fecha_activa) INTO dFechaActivTdc FROM bdicred:bitacora_activacion WHERE numtarjeta = cNumTarjeta;
            IF NVL(dFechaActivTdc, date(1)) = date(1) THEN
                SELECT limit 1 DATE(fechaasignacion) INTO dFechaActivTdc FROM intercard:tarjeta WHERE numtarjeta = cNumTarjeta;
            END IF;

            LET dFechaAlta = dFechaAlta;
            LET dFecha1erComp = dFecha1erComp;
            LET dFecha1erDisp = dFecha1erDisp;

            IF cFech_1er_an6001 = '2' THEN  -- Cargo en fecha de 1er aniversario de activacion de TDC Titular 
                LET sAniosDif = year(dFechaHoy) - year(dFechaActivTdc);
                IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                    LET dFecha1erAnual = monthadd(dFechaActivTdc, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                ELSE
                    LET dFecha1erAnual = monthadd(dFechaActivTdc, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                END IF;   
                IF dFecha1erAnual < dFechaHoy THEN
                    LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                END IF;

                IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.

            ELIF cFech_1er_an6001 = '1' THEN  -- Cargo el dia de activacion del plastico

                IF dFechaActivTdc = dFechaHoy THEN
                    LET dFecha1erAnual = dFechaHoy;
                END IF;
                -- Si la fecha de activacion ya fue previa al dia de hoy. Se calcula el aniversario a la fecha de activacion.
                IF NVL(dFecha1erAnual,date(1)) = date(1) AND nvl(dFechaActivTdc,date(1)) > date(1) THEN
                    LET sAniosDif = year(dFechaHoy) - year(dFechaActivTdc);
                    IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                        LET dFecha1erAnual = monthadd(dFechaActivTdc, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                    ELSE
                        LET dFecha1erAnual = monthadd(dFechaActivTdc, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                    END IF;   
                    IF dFecha1erAnual < dFechaHoy THEN
                        LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                    END IF;
                END IF; 
                IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.


            ELSE     -- 0.- Cargo anualidad fecha de 1er compra/disposicion de titular/adicional.
                IF dFecha1erDisp >= dFecha1erComp AND dFecha1erComp > date(1) THEN   -- Obtiene la fecha menor de las dos
                    LET dFechaMenor = dFecha1erComp;
                ELIF dFecha1erComp >= dFecha1erDisp AND dFecha1erDisp > date(1) THEN
                    LET dFechaMenor = dFecha1erDisp;
                ELIF NVL(dFecha1erComp, date(1)) = date(1) AND NVL(dFecha1erDisp, date(1)) > date(1) THEN
                    LET dFechaMenor = dFecha1erDisp;
                ELIF NVL(dFecha1erDisp, date(1)) = date(1) AND NVL(dFecha1erComp, date(1)) > date(1) THEN
                    LET dFechaMenor = dFecha1erComp;
                ELIF NVL(dFecha1erComp,date(1)) = date(1) AND NVL(dFecha1erDisp, date(1)) = date(1) THEN
                    LET dFechaMenor = dFechaActivTdc; -- Si es una cuenta nunca, se calcula con la fecha activacion
                    IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.
                END IF;

                LET sAniosDif = year(dFechaHoy) - year(dFechaMenor);
                IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                    LET dFecha1erAnual = monthadd(dFechaMenor, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                ELSE
                    LET dFecha1erAnual = monthadd(dFechaMenor, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                END IF;   
                IF dFecha1erAnual < dFechaHoy THEN
                    LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                END IF;

            END IF;

            BEGIN WORK;         -- Marca fecha prox anualidad igual a la 1er anualidad por que aun no se realiza el cobro
                UPDATE bdicred:"informix".sd_indicador_cred SET fecha_1er_anualidad = dFecha1erAnual, fecha_prox_anualidad = dFecha1erAnual
                 WHERE empresa = pempresa AND num_credito = cNumCred;
            COMMIT WORK;

            LET dFecha1erAnual = date(1);

        END FOREACH;

        -- Realiza el cobro de la 1er anualidad para aquellos cuya fecha sea el dia de hoy o este pendiente
        IF dCob_Parc_6001 > 1 THEN
            LET iMnto_Cobr_ComTi = iMnto_AnTit_6001 / dCob_Parc_6001; -- Divide el monto a cobrar para la parcializacion.
            LEt iMnto_Cobr_ComAd = iMnto_AnAdi_6001 / dCob_Parc_6001;
        ELSE
            LET iMnto_Cobr_ComTi = iMnto_AnTit_6001; 
            LEt iMnto_Cobr_ComAd = iMnto_AnAdi_6001;
        END IF;

        FOREACH WITH HOLD       
            SELECT crd.num_credito, crd.numcte, crd.sucursal, crd.status_cred, suc.iva, ind.fecha_prox_anualidad
              INTO cNumCred, cNumCte, cSucursal, cStatusCred, dSucIva, dFecha_Pag_Anualidad
              FROM bdicred:sd_maecred crd JOIN bdicred:sd_indicador_cred ind 
                ON (crd.empresa = ind.empresa AND crd.num_credito = ind.num_credito AND crd.num_producto = '6001' AND crd.status_cred in ('AA','BA','E1'))
              --JOIN bdicred:sd_maesdos sdos ON (crd.empresa = sdos.empresa AND crd.num_credito = sdos.num_credito)
              JOIN bdinteg:si_sucursales suc ON (crd.empresa = suc.empresa AND crd.sucursal = suc.sucursal)
             WHERE ind.fecha_prox_anualidad <= dFechaHoy AND ind.cobro_anualidad = '1'

            LET dMntoDifTotalTit = 0;
            LET dMntoDifTotalAdi = 0;
            LET sExiste_T_Adic = 0;

            SELECT {+INDEX(bdicred:sd_tarjeta 217_886)}  -- llave 218
                tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
                WHERE tar.empresa = pempresa and tar.num_credito = cNumCred and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
                where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') AND tar.tipo_tarjeta = 'T'; 

            EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComTi, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                'COMISION ANUALIDAD TIT', '', '') INTO cCodRet2;
            IF cCodRet2 <> '000' THEN 
                CONTINUE FOREACH; 
            END IF;
            LET dMntoDifTotalTit = dMntoDifTotalTit + iMnto_Cobr_ComTi;

            IF cCom_Adic_6001 = '1' THEN  -- Se cobra comision a Tarjetas adicionales 
                FOREACH WITH HOLD            -- Realiza el cobro a las tarjetas adicionales
                    SELECT num_tarjeta INTO cNumTarjeta 
                      FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa AND num_credito = cNumCred AND tipo_tarjeta = 'A' AND status_tar = 'A'


                    EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComAd, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                    'COMISION ANUALIDAD ADI', '', '') INTO cCodRet2;
                    IF cCodRet2 <> '000' THEN 
                        CONTINUE FOREACH; 
                    END IF;
                    LET dMntoDifTotalAdi = dMntoDifTotalAdi + iMnto_Cobr_ComAd;
                    LET sExiste_T_Adic = sExiste_T_Adic + 1;
                END FOREACH;
            END IF;
            IF cCodRet2 = '000' THEN --- Cobro correctamente. Calcula fecha proxima
                LET dFechaProxAnual = monthadd(dFecha_Pag_Anualidad, + 12);
                BEGIN WORK;
                    -- Actualiza proxima fecha de cobro de anualidad
                    UPDATE bdicred:"informix".sd_indicador_cred SET fecha_prox_anualidad = dFechaProxAnual WHERE empresa = pempresa AND num_credito = cNumCred;
                    -- Agrega registro de monto para Dispersion Contable
                    INSERT INTO bdicred:"informix".sd_comision_x_apertura_contable (empresa, num_credito,sucursal,monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
                        fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,(iMnto_AnTit_6001+(iMnto_AnAdi_6001*sExiste_T_Adic)),0,12,dCob_Parc_6001,'DC',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER, dFechaHoy);
                    -- Agrega registro de pago de Parcializacion Titular y Adicional
                    INSERT INTO bdicred:"informix".sd_comision_x_apertura_contable (empresa, num_credito,sucursal,monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
                    fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,iMnto_AnTit_6001,dMntoDifTotalTit,(dCob_Parc_6001-1),dCob_Parc_6001,'PT',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
                    IF sExiste_T_Adic > 0 THEN    -- Inserta solo si existe TDC adicionales
                        INSERT INTO bdicred:"informix".sd_comision_x_apertura_contable (empresa, num_credito,sucursal,monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
                        fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,iMnto_AnAdi_6001,dMntoDifTotalAdi,(dCob_Parc_6001-1),dCob_Parc_6001,'PA',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
                    END IF;
                COMMIT WORK;                 
            END IF;
        END FOREACH; 
    END IF;

	--JRVT Se agrega bloque de logica para bonificacion
    IF cCobro_com_7000 = '1' AND cCom_Titul_7000 = '1' THEN   -- Realiza el cobro para TDC Platino

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'INICIA COBRO COMISION ANUALIDAD Y BONIFICACION- 7000', '02') Returning cCod_RetIB;

        FOREACH WITH HOLD       -- Obtiene la fecha de  1er cargo de anualidad
            SELECT {+INDEX(bdicred:sd_maecred maecred3)}  
                   crd.num_credito, crd.numcte, crd.sucursal, crd.status_cred, ind.fecha_alta, nvl(f_primer_compra,date(1)), nvl(f_primer_disp,date(1))
              INTO cNumCred, cNumCte, cSucursal, cStatusCred, dFechaAlta, dFecha1erComp, dFecha1erDisp
              FROM bdicred:sd_maecred crd JOIN bdicred:sd_indicador_cred ind
                ON (crd.empresa = ind.empresa and crd.num_credito = ind.num_credito and crd.status_cred in ('AA','BA','BT','E1','E2','E3') and crd.num_producto = '7000' )
             WHERE NVL(ind.fecha_1er_anualidad,date(1)) = date(1) AND ind.cobro_anualidad = '1'

            SELECT {+INDEX(bdicred:sd_tarjeta 217_886)}  -- Llave 218 
                tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
                WHERE tar.empresa = pempresa and tar.num_credito = cNumCred and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
                where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') and tar.tipo_tarjeta = 'T'; 

            SELECT limit 1 date(fecha_activa) INTO dFechaActivTdc FROM bdicred:bitacora_activacion WHERE numtarjeta = cNumTarjeta;
            IF NVL(dFechaActivTdc, date(1)) = date(1) THEN
                SELECT limit 1 DATE(fechaasignacion) INTO dFechaActivTdc FROM intercard:tarjeta WHERE numtarjeta = cNumTarjeta;
            END IF;

            LET dFechaAlta = dFechaAlta;
            LET dFecha1erComp = dFecha1erComp;
            LET dFecha1erDisp = dFecha1erDisp;

            IF cFech_1er_an7000 = '2' THEN  -- Cargo en fecha de 1er aniversario de activacion de TDC Titular 
                LET sAniosDif = year(dFechaHoy) - year(dFechaActivTdc);
                IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                    LET dFecha1erAnual = monthadd(dFechaActivTdc, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                ELSE
                    LET dFecha1erAnual = monthadd(dFechaActivTdc, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                END IF;   
                IF dFecha1erAnual < dFechaHoy THEN
                    LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                END IF;
                IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.       


            ELIF cFech_1er_an7000 = '1' THEN  -- Cargo el dia de activacion del plastico
                
                IF dFechaActivTdc = dFechaHoy THEN
                    LET dFecha1erAnual = dFechaHoy;
                END IF;

                -- Si la fecha de activacion ya fue previa al dia de hoy. Se calcula el aniversario a la fecha de activacion.
                IF NVL(dFecha1erAnual,date(1)) = date(1) AND nvl(dFechaActivTdc,date(1)) > date(1) THEN
                    LET sAniosDif = year(dFechaHoy) - year(dFechaActivTdc);
                    IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                        LET dFecha1erAnual = monthadd(dFechaActivTdc, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                    ELSE
                        LET dFecha1erAnual = monthadd(dFechaActivTdc, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                    END IF;   
                    IF dFecha1erAnual < dFechaHoy THEN
                        LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                    END IF;
                END IF; 
                IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.


            ELSE     -- 0.- Cargo anualidad fecha de 1er compra/disposicion de titular/adicional.
                IF dFecha1erDisp >= dFecha1erComp AND dFecha1erComp > date(1) THEN   -- Obtiene la fecha menor de las dos
                    LET dFechaMenor = dFecha1erComp;
                ELIF dFecha1erComp >= dFecha1erDisp AND dFecha1erDisp > date(1) THEN
                    LET dFechaMenor = dFecha1erDisp;
                ELIF NVL(dFecha1erComp, date(1)) = date(1) AND NVL(dFecha1erDisp, date(1)) > date(1) THEN
                    LET dFechaMenor = dFecha1erDisp;
                ELIF NVL(dFecha1erDisp, date(1)) = date(1) AND NVL(dFecha1erComp, date(1)) > date(1) THEN
                    LET dFechaMenor = dFecha1erComp;
                ELIF NVL(dFecha1erComp,date(1)) = date(1) AND NVL(dFecha1erDisp, date(1)) = date(1) THEN
                    LET dFechaMenor = dFechaActivTdc; -- Si es una cuenta nunca, se calcula con la fecha activacion
                    IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.
                END IF;

                LET sAniosDif = year(dFechaHoy) - year(dFechaMenor);
                IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                    LET dFecha1erAnual = monthadd(dFechaMenor, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                ELSE
                    LET dFecha1erAnual = monthadd(dFechaMenor, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                END IF;   
                IF dFecha1erAnual < dFechaHoy THEN
                    LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                END IF;
            END IF;

            BEGIN WORK;         -- Marca fecha prox anualidad igual a la 1er anualidad por que aun no se realiza el cobro
                UPDATE bdicred:"informix".sd_indicador_cred SET fecha_1er_anualidad = dFecha1erAnual, fecha_prox_anualidad = dFecha1erAnual
                 WHERE empresa = pempresa AND num_credito = cNumCred;
            COMMIT WORK;                 
            LET dFecha1erAnual = date(1);
            
        END FOREACH;

        -- Realiza el cobro de la 1er anualidad para aquellos cuya fecha sea el dia de hoy o este pendiente
        IF dCob_Parc_7000 > 1 THEN
            LET iMnto_Cobr_ComTi = iMnto_AnTit_7000 / dCob_Parc_7000; -- Divide el monto a cobrar para la parcializacion.
            LEt iMnto_Cobr_ComAd = iMnto_AnAdi_7000 / dCob_Parc_7000;
        ELSE
            LET iMnto_Cobr_ComTi = iMnto_AnTit_7000;
            LEt iMnto_Cobr_ComAd = iMnto_AnAdi_7000;
        END IF;

        FOREACH WITH HOLD       
            SELECT crd.num_credito, crd.numcte, crd.sucursal, crd.status_cred, suc.iva, ind.fecha_prox_anualidad, ind.fecha_1er_anualidad
              INTO cNumCred, cNumCte, cSucursal, cStatusCred, dSucIva, dFecha_Pag_Anualidad, dFecha1erAnual
              FROM bdicred:sd_maecred crd JOIN bdicred:sd_indicador_cred ind 
                ON (crd.empresa = ind.empresa AND crd.num_credito = ind.num_credito AND crd.num_producto = '7000' AND crd.status_cred in ('AA','BA','E1'))
              --JOIN bdicred:sd_maesdos sdos ON (crd.empresa = sdos.empresa AND crd.num_credito = sdos.num_credito)
              JOIN bdinteg:si_sucursales suc ON (crd.empresa = suc.empresa AND crd.sucursal = suc.sucursal)
             WHERE ind.fecha_prox_anualidad <= dFechaHoy AND ind.cobro_anualidad = '1'

            LET dMntoDifTotalTit = 0;
            LET dMntoDifTotalAdi = 0;
            LET sExiste_T_Adic = 0;
			LET sDispercionTitular_7000 = 0;

            SELECT {+INDEX(bdicred:sd_tarjeta 217_886)}  -- Llave 218
                tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
             WHERE tar.empresa = pempresa and tar.num_credito = cNumCred and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
                   where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') AND tar.tipo_tarjeta = 'T';     
			
			--JRVT BONIFICACIÓN
			IF cAplica_bonificacion_anual_7000 <> '0' THEN
				
				EXECUTE PROCEDURE sp_valida_gastos_bonificacion(pEmpresa, cNumCred, dImporte_boni_anual_7000, dImporte_boni_mensual_7000, dFecha_Pag_Anualidad,
								cAplica_bonificacion_anual_7000,dFecha1erAnual, dImporte_boni_primer_mes_7000,'7000') INTO cCodRet3;
				
				IF cCodRet3 = '00000' THEN
				
					EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_AnTit_7000, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                    'COMISION ANUALIDAD TIT', '', '') INTO cCodRet2;
					IF cCodRet2 <> '000' THEN 
						CONTINUE FOREACH; 
					END IF;

					-- Genera FolioSucBoni
					EXECUTE PROCEDURE bdicheq:sp_generafolionomina("informix")INTO cCodRet2, cFolioSucBoni;
					
					EXECUTE PROCEDURE bdicred:principal(pEmpresa, cNumCred, 1, iMnto_AnTit_7000 ,USER,cSucursal,cFolioSucBoni,'4294')
						INTO cCodRet3, mRemantPrincp, mIntMorPrincp, mIntVenPrincp, mCapVenPrincp, mIntVigPrincp, mCapVigPrincp, mImpCobPrincp, mComCobPrincp, mSegCobPrincp;
							
					IF cCodRet3 <> "000" THEN
						LET cCod_ret = '00005';
						RETURN cCod_ret;
					END IF;
					
					EXECUTE PROCEDURE bdicred:principal(pEmpresa, cNumCred, 1, (iMnto_AnTit_7000 * dSucIva) ,USER,cSucursal,cFolioSucBoni,'4295')
						INTO cCodRet3, mRemantPrincp, mIntMorPrincp, mIntVenPrincp, mCapVenPrincp, mIntVigPrincp, mCapVigPrincp, mImpCobPrincp, mComCobPrincp, mSegCobPrincp;
							
					IF cCodRet3 <> "000" THEN
						LET cCod_ret = '00005';
						RETURN cCod_ret;
					END IF;
					
					--LEt dMntoDifTotalTit = dMntoDifTotalTit + iMnto_AnTit_7000 - iMnto_AnTit_7000;	
				ELSE-- NO CUMPLIo BONIFICACIoN
					EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComTi, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                    'COMISION ANUALIDAD TIT', '', '') INTO cCodRet2;
					IF cCodRet2 <> '000' THEN 
						CONTINUE FOREACH; 
					END IF;
					
					LET sDispercionTitular_7000 = 1;
					LET dMntoDifTotalTit = dMntoDifTotalTit + iMnto_Cobr_ComTi;
				END IF;
			ELSE --BANDERAS INACTIVAS DE BONIFICACIoN ANUAL 7000
				EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComTi, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                    'COMISION ANUALIDAD TIT', '', '') INTO cCodRet2;
				IF cCodRet2 <> '000' THEN 
					CONTINUE FOREACH; 
				END IF;
				
				LET sDispercionTitular_7000 = 1;
				LEt dMntoDifTotalTit = dMntoDifTotalTit + iMnto_Cobr_ComTi;
			END IF;

            IF cCom_Adic_7000 = '1' THEN  -- Se cobra comision a Tarjetas adicionales 
                FOREACH WITH HOLD            -- Realiza el cobro a las tarjetas adicionales
                    SELECT num_tarjeta INTO cNumTarjeta 
                      FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa AND num_credito = cNumCred AND tipo_tarjeta = 'A' AND status_tar = 'A'
					
					IF cAplica_bonificacion_anual_7000 <> '0' THEN
					
						IF sDispercionTitular_7000 = 0 THEN
						
							EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_AnAdi_7000, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                'COMISION ANUALIDAD ADI', '', '') INTO cCodRet2;
							IF cCodRet2 <> '000' THEN 
								CONTINUE FOREACH; 
							END IF;
	
							
						ELSE --no cumple con la bonificacion
							EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComAd, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                            'COMISION ANUALIDAD ADI', '', '') INTO cCodRet2;
							IF cCodRet2 <> '000' THEN 
								CONTINUE FOREACH; 
							END IF;
								
							LET sExiste_T_Adic = sExiste_T_Adic + 1;
							LET dMntoDifTotalAdi = dMntoDifTotalAdi + iMnto_Cobr_ComAd;
						END IF;
					ELSE --BANDERAS DESACTIVADAS BONIFICACIoN ANUAL
						--iMnto_Cobr_ComAd
						EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComAd, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                            'COMISION ANUALIDAD ADI', '', '') INTO cCodRet2;
						IF cCodRet2 <> '000' THEN 
							CONTINUE FOREACH; 
						END IF;
							
						LET sExiste_T_Adic = sExiste_T_Adic + 1;
						LET dMntoDifTotalAdi = dMntoDifTotalAdi + iMnto_Cobr_ComAd;
					END IF;
					
                END FOREACH;
				
				LET dFecha1erAnual = date(1);
            END IF;
			
            IF cCodRet2 = '000' THEN --- Cobro correctamente. Calcula fecha proxima
                LET dFechaProxAnual = monthadd(dFecha_Pag_Anualidad, + 12);
                BEGIN WORK;
                    -- Actualiza proxima fecha de cobro de anualidad
                    UPDATE bdicred:"informix".sd_indicador_cred SET fecha_prox_anualidad = dFechaProxAnual WHERE empresa = pempresa AND num_credito = cNumCred;
					
					IF sDispercionTitular_7000 >= 1 THEN--EL TITULAR NO ALCANZo EL IMPORTE PARA BONIFICACIoN.
						
						-- Agrega registro de monto para Dispersion Contable
						INSERT INTO bdicred:"informix".sd_comision_x_apertura_contable (empresa, num_credito,sucursal, monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
						fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,(iMnto_AnTit_7000+(iMnto_AnAdi_7000*sExiste_T_Adic)),0,12,dCob_Parc_7000,'DC',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
						
						-- Agrega registro de pago de Parcializacion Tituar y Adicional
						INSERT INTO bdicred:"informix".sd_comision_x_apertura_contable (empresa, num_credito,sucursal, monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
						fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,iMnto_AnTit_7000,dMntoDifTotalTit,(dCob_Parc_7000-1),dCob_Parc_7000,'PT',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
					
					END IF;
				   
					IF sExiste_T_Adic > 0 THEN
                        INSERT INTO bdicred:sd_comision_x_apertura_contable (empresa, num_credito,sucursal, monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
                        fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,iMnto_AnAdi_7000,dMntoDifTotalAdi,(dCob_Parc_7000-1),dCob_Parc_7000,'PA',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
                    END IF;
					
                COMMIT WORK;                 
            END IF;
        END FOREACH; 
    END IF;

	IF cCobro_com_8100 = '1' AND cCom_Titul_8100 = '1' THEN   -- Realiza el cobro para TDC Oro

        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'INICIA COBRO COMISION ANUALIDAD - 8100', '02') Returning cCod_RetIB;

        FOREACH WITH HOLD       -- Obtiene la fecha de  1er cargo de anualidad
            SELECT crd.num_credito, crd.numcte, crd.sucursal, crd.status_cred, ind.fecha_alta, nvl(f_primer_compra,date(1)), nvl(f_primer_disp,date(1))
              INTO cNumCred, cNumCte, cSucursal, cStatusCred, dFechaAlta, dFecha1erComp, dFecha1erDisp
              FROM bdicred:sd_maecred crd JOIN bdicred:sd_indicador_cred ind 
                ON (crd.empresa = ind.empresa and crd.num_credito = ind.num_credito and crd.num_producto = '8100' AND crd.status_cred in ('AA','BA','BT','E1','E2','E3'))
             WHERE NVL(ind.fecha_1er_anualidad,date(1)) = date(1) AND ind.cobro_anualidad = '1'

            SELECT {+INDEX(bdicred:sd_tarjeta 217_886)} -- Lave 218 
                tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
                WHERE tar.empresa = pempresa and tar.num_credito = cNumCred and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
                where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') and tar.tipo_tarjeta = 'T'; 

            SELECT limit 1 date(fecha_activa) INTO dFechaActivTdc FROM bdicred:bitacora_activacion WHERE numtarjeta = cNumTarjeta;
            IF NVL(dFechaActivTdc, date(1)) = date(1) THEN
                SELECT limit 1 DATE(fechaasignacion) INTO dFechaActivTdc FROM intercard:tarjeta WHERE numtarjeta = cNumTarjeta;
            END IF;

            LET dFechaAlta = dFechaAlta;
            LET dFecha1erComp = dFecha1erComp;
            LET dFecha1erDisp = dFecha1erDisp;

            IF cFech_1er_an8100 = '2' THEN  -- Cargo en fecha de 1er aniversario de activacion de TDC Titular 

                LET sAniosDif = year(dFechaHoy) - year(dFechaActivTdc);
                IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                    LET dFecha1erAnual = monthadd(dFechaActivTdc, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                ELSE
                    LET dFecha1erAnual = monthadd(dFechaActivTdc, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                END IF;   
                IF dFecha1erAnual < dFechaHoy THEN
                    LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                END IF;
                IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.

            ELIF cFech_1er_an8100 = '1' THEN  -- Cargo el dia de activacion del plastico

                IF dFechaActivTdc = dFechaHoy THEN
                    LET dFecha1erAnual = dFechaHoy;
                END IF;

                -- Si la fecha de activacion ya fue previa al dia de hoy. Se calcula el aniversario a la fecha de activacion.
                IF NVL(dFecha1erAnual,date(1)) = date(1) AND nvl(dFechaActivTdc,date(1)) > date(1) THEN
                    LET sAniosDif = year(dFechaHoy) - year(dFechaActivTdc);
                    IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                        LET dFecha1erAnual = monthadd(dFechaActivTdc, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                    ELSE
                        LET dFecha1erAnual = monthadd(dFechaActivTdc, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                    END IF;   
                    IF dFecha1erAnual < dFechaHoy THEN
                        LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                    END IF;
                END IF; 
                IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.


            ELSE     -- 0.- Cargo anualidad fecha de 1er compra/disposicion de titular/adicional.

                IF dFecha1erDisp >= dFecha1erComp AND dFecha1erComp > date(1) THEN   -- Obtiene la fecha menor de las dos
                    LET dFechaMenor = dFecha1erComp;
                ELIF dFecha1erComp >= dFecha1erDisp AND dFecha1erDisp > date(1) THEN
                    LET dFechaMenor = dFecha1erDisp;
                ELIF NVL(dFecha1erComp, date(1)) = date(1) AND NVL(dFecha1erDisp, date(1)) > date(1) THEN
                    LET dFechaMenor = dFecha1erDisp;
                ELIF NVL(dFecha1erDisp, date(1)) = date(1) AND NVL(dFecha1erComp, date(1)) > date(1) THEN
                    LET dFechaMenor = dFecha1erComp;
                ELIF NVL(dFecha1erComp,date(1)) = date(1) AND NVL(dFecha1erDisp, date(1)) = date(1) THEN
                    LET dFechaMenor = dFechaActivTdc; -- Si es una cuenta nunca, se calcula con la fecha activacion
                    IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.
                END IF;

                LET sAniosDif = year(dFechaHoy) - year(dFechaMenor);
                IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                    LET dFecha1erAnual = monthadd(dFechaMenor, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                ELSE
                    LET dFecha1erAnual = monthadd(dFechaMenor, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                END IF;   
                IF dFecha1erAnual < dFechaHoy THEN
                    LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                END IF;

            END IF;

            BEGIN WORK;         -- Marca fecha prox anualidad igual a la 1er anualidad por que aun no se realiza el cobro
                UPDATE bdicred:"informix".sd_indicador_cred SET fecha_1er_anualidad = dFecha1erAnual, fecha_prox_anualidad = dFecha1erAnual
                 WHERE empresa = pempresa AND num_credito = cNumCred;
            COMMIT WORK;                 
            LET dFecha1erAnual = date(1);

        END FOREACH;

        -- Realiza el cobro de la 1er anualidad para aquellos cuya fecha sea el dia de hoy o este pendiente
        IF dCob_Parc_8100 > 1 THEN
            LET iMnto_Cobr_ComTi = iMnto_AnTit_8100 / dCob_Parc_8100; -- Divide el monto a cobrar para la parcializacion.
            LEt iMnto_Cobr_ComAd = iMnto_AnAdi_8100 / dCob_Parc_8100;
        ELSE
            LET iMnto_Cobr_ComTi = iMnto_AnTit_8100;
            LEt iMnto_Cobr_ComAd = iMnto_AnAdi_8100;
        END IF;

        FOREACH WITH HOLD       
            SELECT crd.num_credito, crd.numcte, crd.sucursal, crd.status_cred, suc.iva, ind.fecha_prox_anualidad, ind.fecha_1er_anualidad
              INTO cNumCred, cNumCte, cSucursal, cStatusCred, dSucIva, dFecha_Pag_Anualidad, dFecha1erAnual
              FROM bdicred:sd_maecred crd JOIN bdicred:sd_indicador_cred ind 
                ON (crd.empresa = ind.empresa AND crd.num_credito = ind.num_credito AND crd.num_producto = '8100' AND crd.status_cred in ('AA','BA','E1'))
              --JOIN bdicred:sd_maesdos sdos ON (crd.empresa = sdos.empresa AND crd.num_credito = sdos.num_credito)
              JOIN bdinteg:si_sucursales suc ON (crd.empresa = suc.empresa AND crd.sucursal = suc.sucursal)
             WHERE ind.fecha_prox_anualidad <= dFechaHoy AND ind.cobro_anualidad = '1'

            LET dMntoDifTotalTit = 0;
            LET dMntoDifTotalAdi = 0;
            LET sExiste_T_Adic = 0;
			LET sDispercionTitular_8100 = 0;

            SELECT {+INDEX(bdicred:sd_tarjeta 217_886)} -- Llave 218
                tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
                WHERE tar.empresa = pempresa and tar.num_credito = cNumCred and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
                where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') and tar.tipo_tarjeta = 'T'; 
			 
			--JRVT BONIFICACIÓN
			IF cAplica_bonificacion_anual_8100 <> '0' THEN
									
				EXECUTE PROCEDURE sp_valida_gastos_bonificacion(pEmpresa, cNumCred, dImporte_boni_anual_8100, dImporte_boni_mensual_8100,dFecha_Pag_Anualidad, 
								cAplica_bonificacion_anual_8100,dFecha1erAnual, dImporte_boni_primer_mes_8100,'8100') INTO cCodRet3;
				
				IF cCodRet3 = '00000' THEN
				
					EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_AnTit_8100, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                'COMISION ANUALIDAD TIT', '', '') INTO cCodRet2;
					IF cCodRet2 <> '000' THEN 
						CONTINUE FOREACH; 
					END IF;    
					
					-- Genera FolioSucBoni
					EXECUTE PROCEDURE bdicheq:sp_generafolionomina("informix")INTO cCodRet2, cFolioSucBoni;
					
					EXECUTE PROCEDURE bdicred:principal(pEmpresa, cNumCred, 1, iMnto_AnTit_8100 ,USER,cSucursal,cFolioSucBoni,'4294')
						INTO cCodRet3, mRemantPrincp, mIntMorPrincp, mIntVenPrincp, mCapVenPrincp, mIntVigPrincp, mCapVigPrincp, mImpCobPrincp, mComCobPrincp, mSegCobPrincp;
							
					IF cCodRet3 <> "000" THEN
						LET cCod_ret = '00005';
						RETURN cCod_ret;
					END IF;
						
					EXECUTE PROCEDURE bdicred:principal(pEmpresa, cNumCred, 1, (iMnto_AnTit_8100 * dSucIva) ,USER,cSucursal,cFolioSucBoni,'4295')
						INTO cCodRet3, mRemantPrincp, mIntMorPrincp, mIntVenPrincp, mCapVenPrincp, mIntVigPrincp, mCapVigPrincp, mImpCobPrincp, mComCobPrincp, mSegCobPrincp;
							
					IF cCodRet3 <> "000" THEN
						LET cCod_ret = '00005';
						RETURN cCod_ret;
					END IF;
				ELSE --no paso validacion de bonificacion se hace la carga de la comision
					EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComTi, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                'COMISION ANUALIDAD TIT', '', '') INTO cCodRet2;
					IF cCodRet2 <> '000' THEN 
						CONTINUE FOREACH; 
					END IF;
					
					LET sDispercionTitular_8100 = 1;
					LET dMntoDifTotalTit = dMntoDifTotalTit + iMnto_Cobr_ComTi;
				END IF;
			ELSE--las banderas de bonificacion no estàn prendidas se realiza el cobro normal
				
				EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComTi, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                'COMISION ANUALIDAD TIT', '', '') INTO cCodRet2;
					IF cCodRet2 <> '000' THEN 
						CONTINUE FOREACH; 
					END IF;
					
					LET sDispercionTitular_8100 = 1;
					LET dMntoDifTotalTit = dMntoDifTotalTit + iMnto_Cobr_ComTi;
			END IF;
            --LEt dMntoDifTotalTit = dMntoDifTotalTit + iMnto_Cobr_ComTi;

            IF cCom_Adic_8100 = '1' THEN  -- Se cobra comision a Tarjetas adicionales 
                FOREACH WITH HOLD            -- Realiza el cobro a las tarjetas adicionales
                    SELECT num_tarjeta INTO cNumTarjeta 
                      FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa AND num_credito = cNumCred AND tipo_tarjeta = 'A' AND status_tar = 'A'
					  
					IF cAplica_bonificacion_anual_8100 <> '0' THEN
				
						IF sDispercionTitular_8100 = 0 THEN
				
							EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_AnAdi_8100, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
														'COMISION ANUALIDAD ADI', '', '') INTO cCodRet2;
							IF cCodRet2 <> '000' THEN 
								CONTINUE FOREACH; 
							END IF;    
					
						ELSE --no paso validacion de bonificacion se hace la carga de la comision
							EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComAd, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
														'COMISION ANUALIDAD ADI', '', '') INTO cCodRet2;
							IF cCodRet2 <> '000' THEN 
								CONTINUE FOREACH; 
							END IF;
							
							LET dMntoDifTotalTit = dMntoDifTotalAdi + iMnto_Cobr_ComAd;
							LET sExiste_T_Adic = sExiste_T_Adic + 1;
						END IF;
					ELSE--las banderas de bonificacion no estàn prendidas se realiza el cobro normal
					
						EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComAd, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
													'COMISION ANUALIDAD ADI', '', '') INTO cCodRet2;
						IF cCodRet2 <> '000' THEN 
							CONTINUE FOREACH; 
						END IF;
						
						LET dMntoDifTotalTit = dMntoDifTotalAdi + iMnto_Cobr_ComAd;
						LET sExiste_T_Adic = sExiste_T_Adic + 1;
					END IF;
                END FOREACH;
				
				LET dFecha1erAnual = date(1);
				
				
            END IF;

            IF cCodRet2 = '000' THEN --- Cobro correctamente. Calcula fecha proxima
                LET dFechaProxAnual = monthadd(dFecha_Pag_Anualidad, + 12);
                BEGIN WORK;
                    -- Actualiza proxima fecha de cobro de anualidad
                    UPDATE bdicred:sd_indicador_cred SET fecha_prox_anualidad = dFechaProxAnual WHERE empresa = pempresa AND num_credito = cNumCred;
					
					IF sDispercionTitular_8100 >= 1 THEN--EL TITULAR NO ALCANZo EL IMPORTE PARA BONIFICACIoN.
					
						-- Agrega registro de monto para Dispersion Contable
						INSERT INTO bdicred:sd_comision_x_apertura_contable (empresa, num_credito,sucursal,monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
						fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,(iMnto_AnTit_8100+(iMnto_AnAdi_8100*sExiste_T_Adic)),0,12,dCob_Parc_8100,'DC',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
						-- Agrega registro de pago de Parcializacion Tituar y Adicional
						INSERT INTO bdicred:sd_comision_x_apertura_contable (empresa, num_credito,sucursal,monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
						fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,iMnto_AnTit_8100,dMntoDifTotalTit,(dCob_Parc_8100-1),dCob_Parc_8100,'PT',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
                    
					END IF;
					
					IF sExiste_T_Adic > 0 THEN
                        INSERT INTO bdicred:sd_comision_x_apertura_contable (empresa, num_credito,sucursal,monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
                        fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,iMnto_AnAdi_8100,dMntoDifTotalAdi,(dCob_Parc_8100-1),dCob_Parc_8100,'PA',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
                    END IF;  
					
                COMMIT WORK;                 
            END IF;
        END FOREACH; 
    END IF;

	--JRVT SE AGREGA BLOQUE PARA TDC INFINITE
	IF cCobro_com_5400 = '1' AND cCom_Titul_5400 = '1' THEN   -- Realiza el cobro para TDC INFINITE
	
        CALL bdicred:sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'INICIA COBRO COMISION ANUALIDAD - 5400', '02') Returning cCod_RetIB;

        FOREACH WITH HOLD       -- Obtiene la fecha de  1er cargo de anualidad
            SELECT crd.num_credito, crd.numcte, crd.sucursal, crd.status_cred, ind.fecha_alta, nvl(f_primer_compra,date(1)), nvl(f_primer_disp,date(1))
              INTO cNumCred, cNumCte, cSucursal, cStatusCred, dFechaAlta, dFecha1erComp, dFecha1erDisp
              FROM bdicred:sd_maecred crd JOIN bdicred:sd_indicador_cred ind 
                ON (crd.empresa = ind.empresa and crd.num_credito = ind.num_credito and crd.num_producto = '5400' AND crd.status_cred in ('AA','BA','BT','E1','E2','E3'))
             WHERE NVL(ind.fecha_1er_anualidad,date(1)) = date(1) AND ind.cobro_anualidad = '1'

            SELECT {+INDEX(bdicred:sd_tarjeta 217_886)} -- Lave 218 
                tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
                WHERE tar.empresa = pempresa and tar.num_credito = cNumCred and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
                where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') and tar.tipo_tarjeta = 'T'; 

            SELECT limit 1 date(fecha_activa) INTO dFechaActivTdc FROM bdicred:bitacora_activacion WHERE numtarjeta = cNumTarjeta;
            IF NVL(dFechaActivTdc, date(1)) = date(1) THEN
                SELECT limit 1 DATE(fechaasignacion) INTO dFechaActivTdc FROM intercard:tarjeta WHERE numtarjeta = cNumTarjeta;
            END IF;

            LET dFechaAlta = dFechaAlta;
            LET dFecha1erComp = dFecha1erComp;
            LET dFecha1erDisp = dFecha1erDisp;
			LET dFechaMenor = null; 

            IF cFech_1er_an5400 = '2' THEN  -- Cargo en fecha de 1er aniversario de activacion de TDC Titular 

                LET sAniosDif = year(dFechaHoy) - year(dFechaActivTdc);
                IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                    LET dFecha1erAnual = monthadd(dFechaActivTdc, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                ELSE
                    LET dFecha1erAnual = monthadd(dFechaActivTdc, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                END IF;   
                IF dFecha1erAnual < dFechaHoy THEN
                    LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                END IF;
                IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.

            ELIF cFech_1er_an5400 = '1' THEN  -- Cargo el dia de activacion del plastico

                IF dFechaActivTdc = dFechaHoy THEN
                    LET dFecha1erAnual = dFechaHoy;
                END IF;

                -- Si la fecha de activacion ya fue previa al dia de hoy. Se calcula el aniversario a la fecha de activacion.
                IF NVL(dFecha1erAnual,date(1)) = date(1) AND nvl(dFechaActivTdc,date(1)) > date(1) THEN
                    LET sAniosDif = year(dFechaHoy) - year(dFechaActivTdc);
                    IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
                        LET dFecha1erAnual = monthadd(dFechaActivTdc, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
                    ELSE
                        LET dFecha1erAnual = monthadd(dFechaActivTdc, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
                    END IF;   
                    IF dFecha1erAnual < dFechaHoy THEN
                        LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
                    END IF;
                END IF; 
                IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.


            ELSE     -- 0.- Cargo anualidad fecha de 1er compra/disposicion de titular/adicional.

                IF dFecha1erDisp >= dFecha1erComp AND dFecha1erComp > date(1) THEN   -- Obtiene la fecha menor de las dos
                    LET dFechaMenor = dFecha1erComp;
                ELIF dFecha1erComp >= dFecha1erDisp AND dFecha1erDisp > date(1) THEN
                    LET dFechaMenor = dFecha1erDisp;
                ELIF NVL(dFecha1erComp, date(1)) = date(1) AND NVL(dFecha1erDisp, date(1)) > date(1) THEN
                    LET dFechaMenor = dFecha1erDisp;
                ELIF NVL(dFecha1erDisp, date(1)) = date(1) AND NVL(dFecha1erComp, date(1)) > date(1) THEN
                    LET dFechaMenor = dFecha1erComp;
                ELIF NVL(dFecha1erComp,date(1)) = date(1) AND NVL(dFecha1erDisp, date(1)) = date(1) THEN
					 CONTINUE FOREACH;
					--LET dFechaMenor = null; -- se agrega para incidencia de no calcular fechas de anualidad si el cliente no ha usado su tarjeta.
                    --LET dFechaMenor = dFechaActivTdc; -- Si es una cuenta nunca, se calcula con la fecha activacion SE COMENTA PARA INFINITE
                    --IF NVL(dFechaActivTdc, date(1)) = date(1) THEN CONTINUE FOREACH; END IF; -- No continue si no existe fecha de activacion.
                END IF;
				
				if dFechaMenor is not null then -- se agrega para incidencia de no calcular fechas de anualidad si el cliente no ha usado su tarjeta.
					LET sAniosDif = year(dFechaHoy) - year(dFechaMenor);
					IF sAniosDif = 0 THEN       -- Calcula la fecha de 1er cargo de anualidad
						LET dFecha1erAnual = monthadd(dFechaMenor, + 12);     -- Si es el mismo año que el actual, calcula un año mas 
					ELSE
						LET dFecha1erAnual = monthadd(dFechaMenor, + (12 * sAniosDif));   -- Si no, calcula el año mas proximo segun la dif de años
					END IF;   
					IF dFecha1erAnual < dFechaHoy THEN
						LET dFecha1erAnual = monthadd(dFecha1erAnual, + 12);
					END IF;
				end if;
            END IF;

            BEGIN WORK;         -- Marca fecha prox anualidad igual a la 1er anualidad por que aun no se realiza el cobro
                UPDATE bdicred:sd_indicador_cred SET fecha_1er_anualidad = dFecha1erAnual, fecha_prox_anualidad = dFecha1erAnual
                 WHERE empresa = pempresa AND num_credito = cNumCred;
            COMMIT WORK;                 
            LET dFecha1erAnual = date(1);

        END FOREACH;
		
		-- Realiza el cobro de la 1er anualidad para aquellos cuya fecha sea el dia de hoy o este pendiente
        IF dCob_Parc_5400 > 1 THEN
            LET iMnto_Cobr_ComTi = iMnto_AnTit_5400 / dCob_Parc_5400; -- Divide el monto a cobrar para la parcializacion.
            LEt iMnto_Cobr_ComAd = iMnto_AnAdi_5400 / dCob_Parc_5400;
        ELSE
            LET iMnto_Cobr_ComTi = iMnto_AnTit_5400;
            LEt iMnto_Cobr_ComAd = iMnto_AnAdi_5400;
        END IF;
		
        FOREACH WITH HOLD       
            SELECT crd.num_credito, crd.numcte, crd.sucursal, crd.status_cred, suc.iva, ind.fecha_prox_anualidad, ind.fecha_1er_anualidad
              INTO cNumCred, cNumCte, cSucursal, cStatusCred, dSucIva, dFecha_Pag_Anualidad, dFecha1erAnual
              FROM bdicred:sd_maecred crd JOIN bdicred:sd_indicador_cred ind 
                ON (crd.empresa = ind.empresa AND crd.num_credito = ind.num_credito AND crd.num_producto = '5400' AND crd.status_cred ='E1')
              --JOIN bdicred:sd_maesdos sdos ON (crd.empresa = sdos.empresa AND crd.num_credito = sdos.num_credito)
              JOIN bdinteg:si_sucursales suc ON (crd.empresa = suc.empresa AND crd.sucursal = suc.sucursal)
             WHERE ind.fecha_prox_anualidad <= dFechaHoy AND ind.cobro_anualidad = '1'

            LET dMntoDifTotalTit = 0;
            LET dMntoDifTotalAdi = 0;
            LET sExiste_T_Adic = 0;
			LET sDispercionTitular_5400 = 0;

            SELECT {+INDEX(bdicred:sd_tarjeta 217_886)} -- Llave 218
                tar.num_tarjeta INTO cNumTarjeta FROM bdicred:sd_tarjeta tar
                WHERE tar.empresa = pempresa and tar.num_credito = cNumCred and tar.secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
                where tar.empresa = empresa and tar.num_credito = num_credito and tipo_tarjeta = 'T') and tar.tipo_tarjeta = 'T'; 
			
			--JRVT BONIFICACIÓN
			IF cAplica_bonificacion_anual_5400 <> '0' THEN
				
				EXECUTE PROCEDURE sp_valida_gastos_bonificacion(pEmpresa, cNumCred, dImporte_boni_anual_5400, dImporte_boni_mensual_5400, dFecha_Pag_Anualidad,
								cAplica_bonificacion_anual_5400,dFecha1erAnual, dImporte_boni_primer_mes_5400,'5400') INTO cCodRet3;				
				
				IF cCodRet3 = '00000' THEN
				
					EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_AnTit_5400, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                'COMISION ANUALIDAD TIT', '', '') INTO cCodRet2;
					IF cCodRet2 <> '000' THEN 
						CONTINUE FOREACH; 
					END IF;    
					
					-- Genera FolioSucBoni
					EXECUTE PROCEDURE bdicheq:sp_generafolionomina("informix")INTO cCodRet2, cFolioSucBoni;
					
					EXECUTE PROCEDURE bdicred:principal(pEmpresa, cNumCred, 1, iMnto_AnTit_5400 ,USER,cSucursal,cFolioSucBoni,'4294')
						INTO cCodRet3, mRemantPrincp, mIntMorPrincp, mIntVenPrincp, mCapVenPrincp, mIntVigPrincp, mCapVigPrincp, mImpCobPrincp, mComCobPrincp, mSegCobPrincp;
							
					IF cCodRet3 <> "000" THEN
						CONTINUE FOREACH; 
					END IF;
					
					EXECUTE PROCEDURE bdicred:principal(pEmpresa, cNumCred, 1, (iMnto_AnTit_5400 * dSucIva) ,USER,cSucursal,cFolioSucBoni,'4295')
						INTO cCodRet3, mRemantPrincp, mIntMorPrincp, mIntVenPrincp, mCapVenPrincp, mIntVigPrincp, mCapVigPrincp, mImpCobPrincp, mComCobPrincp, mSegCobPrincp;
							
					IF cCodRet3 <> "000" THEN
						CONTINUE FOREACH; 
					END IF;
				ELSE--NO CUMPLE CON LA BONIFICACIÓN SE PARCIALIZA LA COMISIÓN POR ANUALIDAD--
					
					EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComTi, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                'COMISION ANUALIDAD PAR TIT', '', '') INTO cCodRet2;
					IF cCodRet2 <> '000' THEN 
						CONTINUE FOREACH; 
					END IF;  
					
					LET sDispercionTitular_5400 = 1;
					LEt dMntoDifTotalTit = dMntoDifTotalTit + iMnto_Cobr_ComTi;
				END IF;
			ELSE --NO ESTÀN ACTIVAS LAS BANDERAS DE BONIFICACIoN
					
				EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComTi, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                'COMISION ANUALIDAD PAR TIT', '', '') INTO cCodRet2;
				IF cCodRet2 <> '000' THEN 
					CONTINUE FOREACH; 
				END IF;  
				
				LET sDispercionTitular_5400 = 1;
				LEt dMntoDifTotalTit = dMntoDifTotalTit + iMnto_Cobr_ComTi;
			END IF;
			
            IF cCom_Adic_5400 = '1' THEN  -- Se cobra comision a Tarjetas adicionales 
                FOREACH WITH HOLD            -- Realiza el cobro a las tarjetas adicionales
                    SELECT num_tarjeta INTO cNumTarjeta 
                      FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa AND num_credito = cNumCred AND tipo_tarjeta = 'A' AND status_tar = 'A'
					  
					  
					IF cAplica_bonificacion_anual_5400 <> '0' THEN
				
						IF sDispercionTitular_5400 = 0 THEN
				
							EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_AnTit_5400, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
														'COMISION ANUALIDAD TIT', '', '') INTO cCodRet2;
							IF cCodRet2 <> '000' THEN 
								CONTINUE FOREACH; 
							END IF; 
							
						ELSE--NO CUMPLE CON LA BONIFICACIÓN SE PARCIALIZA LA COMISIÓN POR ANUALIDAD--
							
							EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComAd, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
														'COMISION ANUALIDAD PAR TIT', '', '') INTO cCodRet2;
							IF cCodRet2 <> '000' THEN 
								CONTINUE FOREACH; 
							END IF;  
							
							LET sExiste_T_Adic = sExiste_T_Adic + 1;
							LEt dMntoDifTotalAdi = dMntoDifTotalAdi + iMnto_Cobr_ComAd;
						END IF;
					ELSE --NO ESTÀN ACTIVAS LAS BANDERAS DE BONIFICACIoN
					
						EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, user, '8244', iMnto_Cobr_ComAd, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
														'COMISION ANUALIDAD PAR TIT', '', '') INTO cCodRet2;
						IF cCodRet2 <> '000' THEN 
							CONTINUE FOREACH; 
						END IF;  
						
						LET sExiste_T_Adic = sExiste_T_Adic + 1;
						LEt dMntoDifTotalTit = dMntoDifTotalTit + iMnto_Cobr_ComAd;
					END IF;  
					
                END FOREACH;
				
				LET dFecha1erAnual = date(1);
				
            END IF;

            IF cCodRet2 = '000' THEN --- Cobro correctamente. Calcula fecha proxima
                LET dFechaProxAnual = monthadd(dFecha_Pag_Anualidad, + 12);
                BEGIN WORK;
                    -- Actualiza proxima fecha de cobro de anualidad
                    UPDATE bdicred:sd_indicador_cred SET fecha_prox_anualidad = dFechaProxAnual WHERE empresa = pempresa AND num_credito = cNumCred;
					
					IF sDispercionTitular_5400 >= 1 THEN--EL TITULAR NO ALCANZo EL IMPORTE PARA BONIFICACIoN.
						-- Agrega registro de monto para Dispersion Contable
						INSERT INTO bdicred:sd_comision_x_apertura_contable (empresa, num_credito,sucursal,monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
							fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,(iMnto_AnTit_5400+(iMnto_AnAdi_5400*sExiste_T_Adic)),0,12,dCob_Parc_5400,'DC',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
						-- Agrega registro de pago de Parcializacion Tituar y Adicional
						INSERT INTO bdicred:sd_comision_x_apertura_contable (empresa, num_credito,sucursal,monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
							fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,iMnto_AnTit_5400,dMntoDifTotalTit,(dCob_Parc_5400-1),dCob_Parc_5400,'PT',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
					END IF;
					
					IF sExiste_T_Adic > 0 THEN
                        INSERT INTO bdicred:sd_comision_x_apertura_contable (empresa, num_credito,sucursal,monto_afectacion, monto_aplicado, afec_pendientes, num_cobros, diferim_parcial, 
                        fecha_prox_pago, proceso_comision, user_insert, fecha_insert) VALUES(pempresa,cNumCred,cSucursal,iMnto_AnAdi_5400,dMntoDifTotalAdi,(dCob_Parc_5400-1),dCob_Parc_5400,'PA',monthadd(dFecha_Pag_Anualidad,+1),'ANUALIDAD',USER,dFechaHoy);
                    END IF;     
					
                COMMIT WORK;                 
            END IF;
        END FOREACH; 
    END IF;	
	
    CALL bdicred:sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'TERMINA COBRO COMISION POR ANUALIDAD TDC', '02') Returning cCod_RetIB;




    ---------------------------------------------------------------------------
    --       Realiza el cobro de parcialidades pendientes por cobrar         --
    ---------------------------------------------------------------------------

    LET cNumCred = '';
    LET cSucursal = '';
    LET cSucursal = '';
    
    CALL bdicred:sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'INICIA COBRO PARCIALIDADES COMISION ANUALIDAD', '02') Returning cCod_RetIB;

    FOREACH WITH HOLD
        SELECT {+INDEX(bdicred:sd_comision_x_apertura_contable inx_cred)} 
               ca.num_credito, ca.monto_afectacion, ca.monto_aplicado, nvl(ca.afec_pendientes,0), crd.sucursal, ca.fecha_prox_pago, nvl(ca.num_cobros,0), suc.iva, ca.diferim_parcial
          INTO cNumCred, dMontoTot, dMontoApli, iAfecPend, cSucursal, dFechProxPag, sTotalCobros, dSucIva, dDifer_Parcial
          FROM bdicred:sd_comision_x_apertura_contable ca JOIN bdicred:sd_maecred crd 
            ON (ca.empresa = crd.empresa AND ca.num_credito = crd.num_credito AND crd.status_cred in ('AA','BA','E1'))
          --JOIN bdicred:sd_maesdos dos ON (ca.empresa = dos.empresa AND ca.num_credito = dos.num_credito)
          JOIN bdinteg:si_sucursales suc ON (crd.empresa = suc.empresa AND crd.sucursal = suc.sucursal)
	     WHERE ca.num_credito >= ''
		   AND ca.afec_pendientes > 0
           AND ca.fecha_prox_pago <= dFechaHoy
           AND ca.diferim_parcial IN ('PT','PA')

        LET iAfecPend = iAfecPend;
        LET sTotalCobros = sTotalCobros;

        IF dDifer_Parcial = 'PT' THEN
            LET cMensajeMov = 'COM ANUALIDAD ' ||((sTotalCobros - iAfecPend) + 1)::CHAR|| ' DE ' ||sTotalCobros::CHAR || ' TI';
        ELSE
            LET cMensajeMov = 'COM ANUALIDAD ' ||((sTotalCobros- iAfecPend) + 1)::CHAR|| ' DE ' ||sTotalCobros::CHAR || ' AD';
        END IF;

        LET iMnto_Cobro = (dMontoTot - dMontoApli) / iAfecPend; --- Realiza el cobro pendiente, correspondiente al num de cobros
                    
        EXECUTE PROCEDURE "informix".cargo_cred(pEmpresa, cNumCred, cSucursal, USER, '8244', iMnto_Cobro, cFolioSuc, cNumTarjeta, 0, 0, dFechaHoy,
                                                cMensajeMov, '', '') INTO cCodRet2;
        IF cCodRet2 <> '000' THEN 
            CONTINUE FOREACH; 
        END IF;    

        IF iAfecPend > 1 THEN
            LET dFechProxPagCalc = monthadd(dFechProxPag, + 1);
        ELSE
            LET dFechProxPagCalc = dFechProxPag;
        END IF;
        LET iMnto_Cobro = iMnto_Cobro;

        BEGIN WORK;
            UPDATE bdicred:sd_comision_x_apertura_contable
               SET monto_aplicado = monto_aplicado + iMnto_Cobro, afec_pendientes = afec_pendientes - 1, fecha_prox_pago = dFechProxPagCalc
             WHERE num_credito = cNumCred
               AND afec_pendientes > 0
               AND diferim_parcial = dDifer_Parcial
               AND fecha_prox_pago = dFechProxPag
               AND proceso_comision = 'ANUALIDAD';
			  
        COMMIT WORK;          

    END FOREACH;
	
    CALL bdicred:sp_inserta_bitacora(pempresa, cProceso, cCod_ret, 'TERMINA COBRO PARCIALIDADES COMISION ANUALIDAD', '02') Returning cCod_RetIB;


   RETURN cCod_ret;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para el cobro de la comision por anualidad en la Tarjeta de Credito, para los productos: 6001, 7000, 8100 y 5400',
'AUTOR: Martha Angelica Hernandez Rodriguez',
'BD: bdicred ',
'FECHA: Mayo 2017',
'VERSION: 20170501.1';

CREATE PROCEDURE "informix".sp_comisionxapertura_contable(pempresa CHAR(3))
RETURNING CHAR(5);       -- Codigo de Retorno  
--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE cCod_ret     CHAR(5);
DEFINE cMen_ret     CHAR(80);
DEFINE iSqlerr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cNumCred     CHAR(20);
DEFINE mMonto       DECIMAL(16,2);
DEFINE mMonto2      DECIMAL(16,2);
DEFINE mMonto3      DECIMAL(16,2);
DEFINE mMontoApli   DECIMAL(16,2);
DEFINE iAfecPend    INTEGER;
DEFINE cSucursal    CHAR(4);
DEFINE cStatusCred  CHAR(2);
DEFINE cProducto    CHAR(4);
DEFINE cod_ret      CHAR(10);
DEFINE cCodRet2     CHAR(5);
DEFINE cFolioSuc    CHAR(20);
DEFINE vMensaje     CHAR(80);
DEFINE iContador    INTEGER;
DEFINE ibanderafin  INTEGER;
DEFINE cDivisa      VARCHAR(5);
DEFINE dtFechaHoy   DATE;

DEFINE dMontoTot        DECIMAL(16,2);
DEFINE dMontoApli       DECIMAL(16,2);
DEFINE dFechProxPag     DATE;
DEFINE dFechProxPagCalc DATE;
DEFINE dMntoAplicar     DECIMAL(16,2);

-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET cCod_ret    = "00000";
LET cMen_ret    = "Proceso Exitoso";
LET iSqlerr     = 0;
LET iIsamErr    = 0;
LET cNumCred    = "";
LET mMonto      = 0;
LET mMonto2     = 0;
LET mMonto3     = 0;
LET mMontoApli  = 0;
LET iAfecPend   = 0;
LET cSucursal   = "";
LET cStatusCred = "";
LET cProducto   = "";
LET cod_ret     = "";
LET cCodRet2    = "";
LET cFolioSuc   = "";
LET vMensaje    = "";
LET iContador   = 0;
LET ibanderafin = 0;
LET cDivisa     = '';
LET dtFechaHoy  = '';
 

LET dMontoTot           = 0;
LET dMontoApli          = 0;
LET dFechProxPag        = Date(1);
LET dFechProxPagCalc    = Date(1);
LET dMntoAplicar        = 0;

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET iSqlerr,iIsamErr,cMen_ret
   IF iSqlerr != 0 THEN
      LET cCod_ret=iSqlerr;
      RETURN cCod_ret;
  END IF;
END EXCEPTION;



    --SET DEBUG FILE TO "/informix/mahr/sp_comisionxapertura_contable.out";
    --TRACE ON;
-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************

    IF NVL(pempresa, '') = '' THEN
        LET  cCod_ret = '00001';		
		RETURN cCod_ret;
	END IF;
	
	SELECT monto
		INTO mMonto3
	FROM  "informix".sd_tpcomis 
	WHERE empresa = pEmpresa 
	AND cod_comis = '8071';
					
    SELECT fecha_hoy INTO dtFechaHoy FROM bdicred:"informix".sd_fechas WHERE empresa = pempresa;

    -----------------------------------------------------------------------------------------------
    --              Realiza el diferimiento contable de comision por apertura                    --
    -----------------------------------------------------------------------------------------------
	
    --- Realiza el diferimiento contable para la comision por apertura.
   FOREACH WITH HOLD
	   SELECT num_credito, monto_afectacion, monto_aplicado, afec_pendientes, sucursal
			INTO cNumCred, mMonto, mMontoApli, iAfecPend, cSucursal
	   FROM "informix".sd_comision_x_apertura_contable
	   WHERE empresa = pempresa
		AND num_credito >= ''
		AND aplica_cobro = '0'
        AND proceso_comision IN ('') 
		
		IF mMonto <> mMonto3  THEN
			LET mMonto = mMonto3;
		END IF;
		IF (iContador = 0) THEN BEGIN WORK;  END IF;
		
		SELECT status_cred,num_producto,divisa
			INTO cStatusCred,cProducto,cDivisa
		FROM "informix".sd_maecred
		WHERE empresa = pempresa
		AND num_credito = cNumCred;

		-- PROCESO GENERICO PARA FORMATEAR UN FOLIO POR MEDIO DEL EJECUTIVO
		EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina("informix")
		INTO cCodRet2, cFolioSuc;
	
		IF cStatusCred  NOT IN ("BA","BT","AA","E1","E2","E3") OR  iAfecPend = 1 THEN  --en caso de que este el credito  se liquide , cancele o venda 
			--realizar todas las afectaciones pendientes		
			LET mMonto2 = mMonto - mMontoApli;	
			LET ibanderafin =1;
		ELSE
			LET mMonto2 = ROUND((mMonto / 12),2) ;
			LET ibanderafin =0;
		END IF;
   
		EXECUTE PROCEDURE "informix".genmov	(pEmpresa,cNumCred,cProducto,97,'339',dtFechaHoy,mMonto2,cFolioSuc,cSucursal,cDivisa,'8073')
		INTO cod_ret, vMensaje;
		
		IF cod_ret::INTEGER = 0 THEN
			UPDATE "informix".sd_comision_x_apertura_contable
			SET monto_aplicado = monto_aplicado + mMonto2,
			afec_pendientes = CASE WHEN ibanderafin = 0 THEN afec_pendientes -1 ELSE 0 END ,
			aplica_cobro = CASE WHEN ibanderafin = 1 THEN '1' ELSE aplica_cobro END ,
			monto_afectacion = mMonto
			WHERE  empresa = pempresa
			AND num_credito = cNumCred
			AND aplica_cobro = '0';
		END IF;
	  LET iContador = iContador +1;
	  IF (iContador >= 1) THEN
         COMMIT WORK;        
         LET iContador = 0;
      END IF;
    END FOREACH;	 
   
    IF (iContador > 0) THEN
		COMMIT WORK;
	END IF;

    -----------------------------------------------------------------------------------------------
    --              Realiza el diferimiento contable de comision por anualidad                   --
    -----------------------------------------------------------------------------------------------

    LET cNumCred = '';
    LET iAfecPend = 0;
    LET cSucursal = ''; 
    LET cStatusCred = '';
    LET cProducto = '';
    LET cDivisa = '';
    LET cFolioSuc = '';
    LET ibanderafin = 0;

    -- Realiza el diferimiento contable
    FOREACH WITH HOLD
        SELECT ca.num_credito, ca.monto_afectacion, ca.monto_aplicado, ca.afec_pendientes, crd.sucursal, crd.status_cred, crd.num_producto, crd.divisa, ca.fecha_prox_pago
          INTO cNumCred, dMontoTot, dMontoApli, iAfecPend, cSucursal, cStatusCred, cProducto, cDivisa, dFechProxPag
          FROM bdicred:"informix".sd_comision_x_apertura_contable ca JOIN bdicred:"informix".sd_maecred crd ON (ca.empresa = crd.empresa AND ca.num_credito = crd.num_credito)
	     WHERE ca.empresa = pempresa AND ca.num_credito >= ''
		   AND ca.afec_pendientes > 0 
           AND ca.fecha_prox_pago <= dtFechaHoy
           AND diferim_parcial = 'DC'
           AND proceso_comision IN ('ANUALIDAD')

        -- Genera folio suc para registrar movimientos
        EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina("informix") INTO cCodRet2, cFolioSuc;

        --IF (iContador = -1) THEN BEGIN WORK; LET iContador = 1; END IF;
		IF cStatusCred  NOT IN ('BA','BT','AA','E1','E2','E3') OR iAfecPend = 1 THEN -- en caso de que este el credito se liquide, cancele o venda 
			--realizar todas las afectaciones pendientes		
			LET dMntoAplicar = dMontoTot - dMontoApli;	
			LET ibanderafin = 1;
		ELSE
			LET dMntoAplicar = ROUND((dMontoTot / 12),2) ;
			LET ibanderafin = 0;
		END IF;

		EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa, cNumCred, cProducto, 102, '339', dtFechaHoy, dMntoAplicar, cFolioSuc, cSucursal, cDivisa, '8248')
		INTO cCodRet2, vMensaje;
        
        IF iAfecPend > 1 THEN
            LET dFechProxPagCalc = monthadd(dFechProxPag, + 1);
        ELSE
            LET dFechProxPagCalc = dFechProxPag;
        END IF;
            
        IF cCodRet2::INTEGER = 0 THEN
            BEGIN WORK;
                UPDATE bdicred:"informix".sd_comision_x_apertura_contable
                   SET monto_aplicado = monto_aplicado + dMntoAplicar, afec_pendientes = afec_pendientes - 1, fecha_prox_pago = dFechProxPagCalc
                 WHERE empresa = pempresa AND num_credito = cNumCred
                   AND afec_pendientes > 0
                   AND diferim_parcial = 'DC'
                   AND fecha_prox_pago = dFechProxPag;
            COMMIT WORK;      
        END IF;
    END FOREACH;

 
    RETURN cCod_ret;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para aplicacion de la caida contable del diferido del cobro de comision por apertura',
'AUTOR: JesÃÂºs Manuel Aguilar Heredia',
'BD: bdicred ',
'FECHA: FEBERO 2014',
'VERSION: 20140217.1735',
'DESCRIPCION: Se quita caida contable para tdc 6001 y GC',
'AUTOR: Luis Alberto Beltran Rodriguez',
'BD: bdicred ',
'FECHA: FEBERO 2014',
'VERSION: 20250424.1402';

CREATE PROCEDURE "informix".sp_generar_compras_pl() 
	RETURNING	 CHAR(5), CHAR(80); --Codigo Retorno
	DEFINE cCodret				    CHAR(5);
	DEFINE iSqlerr				    INTEGER;
	DEFINE pNumCredito				CHAR(20);
	DEFINE pProducto			    CHAR(4);
	DEFINE pNumCte_Ref				CHAR(20);
	DEFINE pMontoPago               DECIMAL(18,2);
	DEFINE pPeriodo  			    CHAR(20);
	DEFINE pNumCte			    	CHAR(20);
	DEFINE pFechaCorteCompraInicio	DATE;
	DEFINE pFechaCorteCompraFinal	DATE;
	DEFINE pFechaCentral		    DATE;
	DEFINE pFechaMenosDia			DATE;
	DEFINE pFechaMenosTres			DATE;
	DEFINE pFechaMov		    	DATETIME YEAR TO FRACTION(5);
	DEFINE pFechatransaccion        DATETIME YEAR TO FRACTION(5);
	DEFINE pReferencia23			CHAR(23);
	DEFINE cFechaMov		    	DATE;
	DEFINE pEstatusCalculo			BOOLEAN;
	DEFINE cNumCreditoCompras		CHAR(20);
	DEFINE cPeriodoCompras			CHAR(20);
	DEFINE cMontoCompras			DECIMAL(18,2);
	DEFINE cOrigen					CHAR(40);
	DEFINE cMoneda					CHAR(3);
	DEFINE cReferencia23			CHAR(23);
	DEFINE pNombreComercio			CHAR(80);
	
	DEFINE pCodFun					CHAR(3); 
	DEFINE pCodRef					INTEGER; 
	DEFINE pNumTarjeta				CHAR(20);
	DEFINE pNumCreditoMaesdos		CHAR(20);
	DEFINE pNumCreditoTarjeta		CHAR(20);
	DEFINE pNumCreditoMaecredanexo	CHAR(20);
	DEFINE pReferencia23_325		CHAR(23);
	DEFINE pRfc325                  CHAR(15);
	DEFINE pIdterminal              CHAR(16);
	DEFINE pFolio_suc               CHAR(16);
	DEFINE psecuencia325			CHAR(7);
	
	DEFINE psecuenciaextendida	    char(16); 
	DEFINE pMonto_post              decimal(16,2); 	
	DEFINE pUnixtime_compra 	    char(10); 	
	DEFINE punixtime_conciliada     char(10);
	DEFINE rMerchantId				char(40);	
	DEFINE pUuid			        char(20); 
	DEFINE rParity					char(40);
	DEFINE rMcc						char(4);
	DEFINE rAddress					char(40);
	DEFINE rZipCode					char(40);
	DEFINE rCommerce				char(40);
	DEFINE rCity					char(40);

	DEFINE cmensaje 		CHAR(80);
	DEFINE cNombreSp		CHAR(60);
	DEFINE cMensajeError	CHAR(60);

	--INICIALIZANDO VARIABLES -------------
	---------------------------------------
	LET iSqlerr    			= 0;
	LET cCodret    			= "00000";
	LET pNumCredito    		="";
	LET pProducto			="";
	LET pNumCte 			="";
	LET pMontoPago          ="";
	LET pNumCte_Ref	 		="";
	LET pPeriodo 			="";
	LET pFechaCorteCompraInicio ="";
	LET pFechaCorteCompraFinal  ="";
	LET pFechaCentral       ="";
	LET pFechaMenosDia		= "";
	LET pFechaMenosTres		= "";
	LET pFechaMov			="";
	LET cFechaMov			="";
	LET pReferencia23		= null;
	LET pEstatusCalculo		= "f";
	LET cNumCreditoCompras  = "";
	LET cPeriodoCompras		= "";
	LET cMontoCompras		= "";
	LET cReferencia23		= "";
	LET pNombreComercio		= "";

	LET pCodFun					= "";
	LET pCodRef					= 0;
	LET pNumTarjeta				= "";
	LET pNumCreditoMaesdos		= "";
	LET pNumCreditoTarjeta		= "";
	LET pNumCreditoMaecredanexo	= "";
	LET pReferencia23_325		= "";
	
	LET pFechatransaccion       = null;
	LET pRfc325                 = ''; 
	LET pIdterminal             = '';
	LET pFolio_suc				= '';
	LET psecuencia325			= '';
	
	LET cOrigen				="Plan_Lealtad";
	--LET cMoneda				="mxn";
	LET cMoneda				="484";
	LET cNombreSp			= "sp_generar_compras_pl";

	
	LET psecuenciaextendida = ''; 
	LET pMonto_post         = 0;
	LET pUnixtime_compra = "";
	LET punixtime_conciliada = "";
	LET rMerchantId			= "";
	LET pUuid = ""; 
	LET rAddress  = "NA";
	LET rZipCode  = "NA";
	LET rCity     =  "NA";
	LET rMcc      =  '0000';
	LET rCommerce = '0000';
	LET rParity   = '0000';

	LET cmensaje		='';
	LET cMensajeError	='';
	
				   
BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
		
			INSERT INTO "informix".sd_bitacora_errores_pl(nombreSp,cCodRet,mensaje_error,num_credito,numcte,folio_suc,fecha_mov)
			VALUES(cNombreSp,cCodret,cMensajeError,pNumCredito,pNumCte,pFolio_suc,pFechaMov);
		
			LET cmensaje = pNumCte||' '||pNumCredito||' '||pFolio_suc;
			RETURN cCodret,cmensaje;
		END IF;
	END EXCEPTION;
 
	--SET DEBUG FILE TO "/ifxsif01/DBA/IPCB/tdc/plan_lealtad_ipcb.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Obtener fecha DE CENTRAL -----------------------
	--------------------------------------------------
	SELECT fecha_hoy, fecha_ant 
	INTO pFechaCentral, pFechaMenosDia
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';
	
	----------------------------------------------------------------------------------------------------------------------------------------------------
	FOREACH WITH hold
	
	SELECT a.num_credito, d.num_producto, d.numcte, a.fecha_operacion,a.monto, a.referencia23, a.codigo_fun, a.codigo_ref,e.num_tarjeta,folio_suc
		INTO   pNumCredito,pProducto,pNumCte,pFechaMov,pMontoPago,pReferencia23,pCodFun,pCodRef,pNumTarjeta,pFolio_suc
		FROM bdicred:"informix".sd_movhis a,
				bdicred:"informix".sd_maecred d,
				bdicred:"informix".sd_transfun c,
				bdicred:"informix".sd_maesdos b,
				bdicred:"informix".sd_tarjeta e
		WHERE a.empresa = b.empresa
				AND a.num_credito = b.num_credito
				AND a.empresa = d.empresa
				AND a.num_credito = d.num_credito
				AND a.empresa = e.empresa
				AND a.num_credito = e.num_credito
				AND e.num_tarjeta = nro_tarjeta
				AND e.tipo_tarjeta = 'T'
				AND a.reversado = 'N'                 -- No reversado
				AND a.fecha_mov = pFechaMenosDia   
				AND d.status_cred = 'E1'
				AND a.codigo_fun = c.codigo_fun
				AND a.codigo_ref = c.codigo_ref
				and a.codigo_fun = '002'
				and a.codigo_ref in (37,57,84,85)
				and b.act = 0
				and d.num_producto in ('6001','8100','5400')
				--and (d.num_producto in ('6001','8100') and d.sucursal in (SELECT sucursal FROM bdicred: "informix".sd_sucursales_piloto where cmbc = 'si') or
					--d.num_producto = ('5400'))
				and a.monto >= 1
				and a.folio_suc not in (select folio_suc from bdicred:"informix".sd_compras_plan_lealtad z where z.estatus_calculo ='f' and z.num_credito = a.num_credito and z.fecha_conciliada = a.fecha_mov)

			If exists (
				select p.num_credito 
				from bdicred:"informix".sd_promocion_credito p 
				where p.folio_suc = pFolio_suc 
				and p.num_promo = 10 
				and p.num_credito = pNumCredito
				and p.num_tarjeta <> '' 
				and p.status in (2,6,7)
				) THEN
					CONTINUE FOREACH; 
			end if;



			LET pSecuencia325 = substr(pFolio_suc,11,6);
			LET pSecuenciaextendida = substr(pFolio_suc,2,15);
		
			LET cMensajeError	='Select table bditarjeta.td_movimientos_conciliacion';
		
			select nomcomercio325, rfc325, idterminal, fechatransaccion
			INTO pNombreComercio, pRfc325, pIdterminal, pFechatransaccion
			FROM bditarjeta:"informix".td_movimientos_conciliacion i
			WHERE i.numtarjeta = pNumTarjeta
			AND i.secuencia325 = pSecuencia325
			AND i.referencia23_325 =pReferencia23
			AND i.tipo_mov = 'C';

			LET cMensajeError	='Select table intercard.movimiento';
			
			select monto,idretailer
			into pMonto_post,rMerchantId
			from intercard:"informix".movimiento
			where numtarjeta = pNumTarjeta
			and secuenciaextendida = pSecuenciaextendida;
	
			LET pRfc325= NVL(pRfc325,'');
			LET pNombreComercio= NVL(pNombreComercio,'');
			LET pIdterminal= NVL(pIdterminal,'');
			LET pFechatransaccion= NVL(pFechatransaccion,'');

			IF pRfc325 = '' THEN
			 LET pRfc325='NA'  ;
			END IF;

			LET pMonto_post = TRUNC(NVL(pMonto_post,0));
			LET rMerchantId = NVL(rMerchantId,'');

			LET cMensajeError	='Conversion unixtime';
			LET pUnixtime_compra = to_unix_time(pFechatransaccion);
			LET punixtime_conciliada = to_unix_time(pFechaMov);	
			LET pUuid = lpad(trim(pNumCte),20,'0');
			LET pSecuenciaextendida = substr(pFolio_suc,2,15);

			LET pNombreComercio = nvl(pNombreComercio,'');
			LET pPeriodo = TO_CHAR(date(pFechaMov), "%m-%Y");
			LET pMontoPago = TRUNC (pMontoPago);

			LET cMensajeError	='Select de sd_compras_plan_lealtad para validar si ya existe';
			select first 1 num_credito
			INTO cNumCreditoCompras
			FROM bdicred:"informix".sd_compras_plan_lealtad
			WHERE num_credito = pNumCredito
			AND folio_suc = pFolio_suc
			AND fecha_conciliada = pFechaMov;
			
			IF cNumCreditoCompras is null  THEN	
				BEGIN WORK;
					INSERT INTO bdicred:"informix".sd_compras_plan_lealtad(numcte, producto, num_credito, monto_diario, periodo, fecha_compra,fecha_conciliada, estatus_calculo, origen, moneda, referencia23, nombre_comercio,rfc_comerce,idterminal,nro_tarjeta,secuencia,Folio_suc,estatus_envio,unixtime_compra,unixtime_conciliada,uuid,monto_post,mcc,Adress,zipcode,commerce,city,parity,idretailer)
					VALUES (pNumCte,pProducto,pNumCredito,pMontoPago,pPeriodo,pFechatransaccion, pFechaMov, "f", cOrigen, cMoneda, pReferencia23, pNombreComercio,pRfc325,pIdterminal,pNumTarjeta,pSecuencia325,pFolio_suc,'f',pUnixtime_compra,punixtime_conciliada,pUuid,pMonto_post,rMcc,rAddress,rZipCode,rCommerce,rCity,rParity,rMerchantId);
					
				COMMIT WORK;
			END IF;
	END FOREACH;
	
	RETURN cCodret,cmensaje;
END;
END PROCEDURE
DOCUMENT
'Se crea SP para obtener las compras conciliadas de cada cliente',
'AUTOR : FAUSTO VALENZUELA 90251013',
'FECHA CREACION: 28/02/2022',
'FECHA ULTIMA LIBERACION PRODUCTIVA : 05/12/2023',
'VERSION : 1.0.5',
'BD    : BDICRED';

CREATE PROCEDURE "informix".apercred1_pp_domicilia(
			 pEmpresa       VARCHAR(3), 	-- EMPRESA
             pSolicitud     VARCHAR(20), 	-- NUMERO DE SOLICITUD
		 	 pEjecutivo     CHAR(8),		-- EJECUTIVO
			 pPlazo			INTEGER,		-- PLAZO EN MESES PARA PAGAR EL CREDITO
			 pNombrePres	CHAR(50),		-- NOMBRE DEL PRESTAMO
			 pMonto			DECIMAL(18,2),	-- MONTO APROBADO
			 pCuentaCap		CHAR(20),		-- CUENTA DE CAPTACION
			 pMensualidad	MONEY(18,2),	-- IMPORTE MENSUAL
			 pFrecuencia    INTEGER 		-- Frecuencia de pago (--1.- Mensual credinomina / --2.- Quincenal credinomina)
			 )
RETURNING CHAR(6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);


--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE cCodRet				VARCHAR(6);		-- CODIGO DE RETORNO
DEFINE cCodRet3				VARCHAR(6);		-- CODIGO DE RETORNO ABONOREF BDICHEQ
DEFINE cCodRetTDif			CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE cErrorInfo           VARCHAR(80);	-- MENSAJE DE ERROR
DEFINE mTasaInteres         DECIMAL(18,2);	-- TASA DE INTERES
DEFINE mTasaMora            DECIMAL(18,2);	-- TASA MORATORIA
DEFINE mSobreTasa           DECIMAL(18,2);	-- SOBRETASA
DEFINE mSobreTasa_MORA      DECIMAL(18,2);	-- SOBRETASA MORA
DEFINE mTasaFavor           DECIMAL(18,2);	-- TASA A FAVOR
DEFINE mSobreTasaFAV        DECIMAL(18,2);	-- SOBRETASA A FAVOR DEL CLIENTE
DEFINE cFactor	            CHAR(1);		-- FACTOR
DEFINE cFactor_Mora	        CHAR(1);		-- FACTOR MORA
DEFINE dFechaApert          DATE;			-- FECHA DE INICIO DEL PRESTAMO
DEFINE dFechaVenc           DATE;			-- FECHA DE TERMINACION DEL PRESTAMO
DEFINE iSqlErr              INTEGER;		-- CODIGO DE ERROR
DEFINE iIsamError           INTEGER;		-- CODIGO DE ERROR
DEFINE cNumCte              CHAR(20);		-- NUMERO DE CLIENTE
DEFINE cTpCte               CHAR(1);		-- TIPO DE CLIENTE
DEFINE mIngreso             DECIMAL(18,2);	-- INGRESO DEL CLIENTE
DEFINE cFactorFAV           CHAR(1);		-- FACTOR A FAVOR DEL CLIENTE
DEFINE cProducto            CHAR(4);		-- CODIGO DE PRODUCTO
DEFINE cDivisa              CHAR(2);		-- DIVISA
DEFINE cSucursal            CHAR(4);		-- CODIGO DE SUCURSAL
DEFINE cFolio	            CHAR(16);		-- FOLIO PARA GENERACION DE MOVIMIENTOS DIARIOS
DEFINE cMensaje             CHAR(200);		-- MENSAJE MAS NOMBRE DE EJECUTIVO
DEFINE dFechaT              DATE;			-- FECHA DEL MES POSTERIOR A LA APERTURA
DEFINE sDiaCorte            SMALLINT;		-- DIA DE CORTE
DEFINE i		     		SMALLINT;		-- VARIABLE PARA ITERACION
DEFINE mCatIva		    	DECIMAL(18,2);	-- VALOR DEL CAT DEL IVA
DEFINE cMercadeo            CHAR(1);		-- PUBLICACION
DEFINE sSecIngreso 			SMALLINT;		-- SECUENCIA DE INGRESOS
DEFINE mTasaInteresProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE mTasaMoraProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE cPeriodoPag			CHAR(1);		-- PERIODICIDAD DEL PAGO
DEFINE iDiasTraspCap		INTEGER;		-- DIAS PARA TRASPASO DE CAPITAL
DEFINE iDiasTraspInt		INTEGER;		-- DIAS PARA TRASPASO DE INTERESES
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE cTransacc 			CHAR(4);	 	-- FOLIO DE TRANSACCION DEL ABONO
DEFINE iNumReg				INTEGER;		-- NUMERO DE REGISTROS DE UNA OPERACION
DEFINE dIvaSuc              DECIMAL(5,3);   -- IVA DE LA SUCURSAL DONDE SE GENERO LA SOLICITUD
DEFINE idAbono              CHAR(1);
DEFINE sDiasPeriodo         SMALLINT;
DEFINE dtDiaprimero         DATE;
DEFINE dtFecha_cargo  		DATE;
DEFINE mDispo         		MONEY(14,2);
DEFINE mCargo         		MONEY(14,2);
DEFINE mIvaComisionApertura MONEY(14,2);
DEFINE mComisionApertura    MONEY(14,2);
DEFINE dPorcComisionAper    DECIMAL(9,6);
DEFINE cTransaccIvaCargo    CHAR(4);
DEFINE cTransaccCargo       CHAR(4);
DEFINE iContador         	SMALLINT;
DEFINE mTotalPagar			DECIMAL(18,2);
DEFINE iNum_periodos    	INTEGER;
DEFINE dtFecha_cuota    	DATE;
DEFINE dSdo_inicial     	MONEY(14,2);
DEFINE dPago_mensual    	MONEY(14,2);
DEFINE dMto_Interes     	MONEY(14,2);
DEFINE dIva_interes     	MONEY(14,2);
DEFINE dCapital         	MONEY(14,2);
DEFINE dSdo_final       	MONEY(14,2);
DEFINE sDias_periodo    	SMALLINT;
DEFINE dtFecha_Aper			DATE;
DEFINE iDiaPago      		INTEGER;
DEFINE cNumMesesPagos   	CHAR(3);
DEFINE cCodRet2         	CHAR(6);
DEFINE cMensajeRet      	VARCHAR(80,1);
DEFINE vCatFinal        	DECIMAL(21,10);
DEFINE dPagoReq      		DECIMAL(18,2);
DEFINE pNumCel       		CHAR(13);
DEFINE sCodRetEvento 		CHAR(5);
DEFINE pMontoSolOtorga		DECIMAL(18,2);	-- MONTO APROBADO PRODUCTO 6800,7100
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);
DEFINE count_maecrd			SMALLINT;
DEFINE count_mdoscrd		SMALLINT;
DEFINE count_maeanexcrd		SMALLINT;
--DEFINE count_ctascarg		SMALLINT;
DEFINE count_amortcrd		SMALLINT;
DEFINE count_ssautoriz		SMALLINT;
DEFINE cIFRS				CHAR(1);
DEFINE cStatus_cred 		CHAR(2);
DEFINE iAtr_Act_ifrs		INTEGER;
DEFINE iPlazo_pago          INTEGER;
DEFINE vCancelVig           INTEGER;
DEFINE vFechaVig 			DATE;
DEFINE CanalSol             CHAR(1);

DEFINE dFechaIntegral   DATE;
DEFINE dFechaCierreCred   DATE;
DEFINE dFechaHabilAnt		DATE;
DEFINE cStatusCierreCred  CHAR(1);
DEFINE cIndCierreCheq   CHAR(1);


--***********************
--INICIALIZA VARIABLES
--***********************
LET cCodRet      		= '000000';
LET cCodRet3			= '000';
LET cCodRetTDif			= '';
LET cErrorInfo    		= 'PROCESO EXITOSO';
LET mTasaInteres 		= 0;
LET mTasaMora 			= 0;
LET mSobreTasa   		= 0;
LET mSobreTasa_MORA		= 0;
LET mTasaFavor   		= 0;
LET mSobreTasaFAV		= 0;
LET cFactor	  			= "";
LET cFactor_Mora		= "";
LET dFechaApert 		= DATE(1);
LET dFechaVenc 			= DATE(1);
LET iSqlErr    			= 0;
LET iIsamError 			= 0;
LET cErrorInfo 			= "";
LET cNumCte    			= "";
LET cTpCte     			= "";
LET mIngreso   			= 0;
LET cFactorFAV 			= "";
LET cProducto  			= "";
LET cDivisa    			= "";
LET cSucursal			= "";
LET cFolio				= "";
LET cMensaje 			= "";
LET dFechaT  			= DATE(1);
LET sDiaCorte			= 0;
LET i 					= 0;
LET mCatIva				= 0;
LET cMercadeo 			= "";
LET sSecIngreso			= 0;
LET mTasaInteresProd	= 0;
LET cPeriodoPag			= "";
LET iDiasTraspCap		= 0;
LET iDiasTraspInt		= 0;
LET cNumeroFolio		= "";
LET cTransacc			= "";
LET iNumReg				= 0;
LET dIvaSuc             = 0;
LET idAbono             = "N";
LET sDiasPeriodo        = 0;
LET dtDiaprimero  	 	= DATE(1);
LET dtFecha_cargo  	    = DATE(1);
LET mDispo              = 0;
LET mCargo      	    = 0;
LET mIvaComisionApertura = 0;
LET mComisionApertura	= 0;
LET dPorcComisionAper   = 0;
LET cTransaccIvaCargo   = "";
LET cTransaccCargo      = "";
LET iContador      	    = 0;
LET mTotalPagar			= 0;
LET iNum_periodos		= 0;
LET dtFecha_cuota      	= DATE(1);
LET dSdo_inicial      	= 0;
LET dPago_mensual      	= 0;
LET dMto_Interes      	= 0;
LET dIva_interes      	= "";
LET dCapital      	   	= "";
LET dSdo_final      	= 0;
LET sDias_periodo      	= 0;
LET dtFecha_Aper      	= DATE(1);
LET iDiaPago       		= 0; 
LET cNumMesesPagos  	= "";
LET cCodRet2            = "000000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET vCatFinal 			= 0;
LET dPagoReq 			= 0;
LET pNumCel  			= '';
LET sCodRetEvento		= '';
LET pMontoSolOtorga     = 0; 
LET vcod_ret			= '000';
LET cta_Clabe			= '';	
LET count_maecrd		= 0;
LET count_mdoscrd		= 0;
LET count_maeanexcrd	= 0;
--LET count_ctascarg		= 0;
LET count_amortcrd		= 0;
LET count_ssautoriz		= 0;
LET cIFRS				= '';
LET cStatus_cred		= '';
LET iAtr_Act_ifrs		= 0;
LET iPlazo_pago         = 0;
LET vCancelVig          = 0;
LET vFechaVig           = '';
LET CanalSol            = '';

LET dFechaIntegral   = DATE(1);
LET dFechaCierreCred   = DATE(1);
LET dFechaHabilAnt   = DATE(1);
LET cStatusCierreCred  = '1';
LET cIndCierreCheq   = '1';

--SET DEBUG FILE TO '/tmp/apercred1_pp_domicilia.out';
--TRACE ON;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
		LET cErrorInfo  = cErrorInfo;
        LET cCodRet    = iSqlErr;
        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END EXCEPTION;
	
	   EXECUTE PROCEDURE "informix".apercred1_pp_domicilia_web(pEmpresa,pSolicitud,pEjecutivo,pPlazo,pNombrePres,pMonto,pCuentaCap,pMensualidad,pFrecuencia,'')
	   INTO cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	   LET cCodRet = LPAD(cCodRet,6,'0');	 
	
    RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
END;
END PROCEDURE
DOCUMENT
'AUTOR: DR Roro',
'Descripcion: Apertura de prestamo personal con domiciliacion',
'Fecha: 2020/10/07',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Rodolfo Tortolero',
'Descripcion: Se agrega flujo oneclick para que tome la sucursal origen del cliente cuando la solicitud viene desde la aplicaciÃÂ³n.',
'Fecha: 2023/06/07',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Angel Anguiano',
'Descripcion: Se agrega cambio de sucursal 8503 por 6700 oneclick.',
'Fecha: 2024/02/28',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Miguel Angel ESpinoza Salmoran',
'Descripcion: Se agrega validacion para consumir apercred1_pp_domicilia_web si es por canal 7',
'Descripcion: y validar cierre.',
'Fecha: 2025/03/13',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_cartera_total_ppyr_finmes()
RETURNING CHAR(6),
		  CHAR(150);

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(150);
DEFINE cMensajeBitacora 	CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_ret2			CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE  vproceso			CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE pfechacorte 			DATE;
DEFINE Vult_dia_mes 		DATE;
--Structura
DEFINE Vcreditoexterno      CHAR(20);
DEFINE Vproducto     		CHAR(4);
DEFINE Vnum_credito         CHAR(20);
DEFINE cNumCredito			CHAR(20);
DEFINE  Vnumcte				CHAR(20);
DEFINE Vnum_tarjeta         CHAR(20);
DEFINE Vnum_sucursal		CHAR(4);
DEFINE  Vnom_sucursal		CHAR(40);
DEFINE  Vingreso_mensual    MONEY;
DEFINE  Vmonto_apertura     DECIMAL(18,2); 
DEFINE  Vfecha_apertura     DATE;

DEFINE  Vplazo 				SMALLINT;
DEFINE Vestatus 			CHAR (2);
DEFINE  Vsaldo_insoluto		DECIMAL(18,2);
DEFINE  Vcapital_vigente	DECIMAL(18,2);
DEFINE Vcapital_transitorio	DECIMAL(18,2);
DEFINE Vsaldo_vencido_exigible		DECIMAL(18,2);
DEFINE Vsaldo_vencido_no_exigible	DECIMAL(18,2);
DEFINE Vsaldo_actual 		DECIMAL(18,2); 
DEFINE  Vsaldo_cierre 		DECIMAL(18,2); 
DEFINE Vmes_vencido 		DECIMAL(18,2); 
DEFINE Vtipo_mov 			CHAR (1);
DEFINE Vfecha_mov 			DATE;

DEFINE Vsexo 				CHAR (1);
DEFINE Vfecha_nac 			DATE;
DEFINE Vnombre1 			CHAR(26);
DEFINE Vnombre2 			CHAR(26);
DEFINE Vapellido_p 			CHAR(26);
DEFINE Vapellido_m 			CHAR(26);
DEFINE Vmail 				CHAR (60);
DEFINE Vdir_calle 			CHAR(30);
DEFINE Vdir_numero 			CHAR(20);
DEFINE Vdir_colonia 		CHAR(32);
DEFINE Vcp 					CHAR(5);

DEFINE Vdir_municipio 		CHAR(60);
DEFINE Vnum_estado 			SMALLINT;
DEFINE Vdir_estado 			CHAR(30);
DEFINE Vnum_cd_coppel 		SMALLINT;
DEFINE Vcd_coppel 			CHAR(32);
DEFINE Vnum_cd_banco 		SMALLINT;
DEFINE  Vcd_banco 			CHAR(32);
DEFINE Vtel1 				CHAR(13);
DEFINE  Vtel2 				CHAR(13);
DEFINE Vtel3 				CHAR(13);
DEFINE Vext 				CHAR(5);

DEFINE Vref_coppel 			CHAR(20);
DEFINE Vficiencia 			DECIMAL(5,2);
DEFINE Vmeses_historia 		SMALLINT;
DEFINE Vhit 				CHAR(6);
DEFINE Vsecc1 				CHAR (4);
DEFINE Vsecc2 				DECIMAL(10,4);
DEFINE Vpri_dia_mes 		DATE;

	  --variables
DEFINE Vnumcreditortc       CHAR(20);
DEFINE VcreditoConsulta     CHAR(20);
DEFINE Vnumcuentartc      	CHAR(20);
--DEFINE Vnumcte        		CHAR(20);
DEFINE Vnumsucursal     	CHAR(4);
DEFINE Vsaldoactual      	DECIMAL(18,2);
DEFINE Vabonosvencidos		SMALLINT;
DEFINE Vestadocredito		CHAR(2);
DEFINE Vplazortc			SMALLINT;
DEFINE dFechaUltPago		DATE;
DEFINE dFechaUltimoPago		DATE;
DEFINE Vtipoultimomov		CHAR(2);
DEFINE Vfechacorte			DATE;
define cNombreArchivo		CHAR(70);
define cNombreArchivo2		CHAR(70);
define cNombreArchivoNvo	CHAR(70);
--define cempresa				CHAR(3);
define Vprod				CHAR(4);
define vmontor1				DECIMAL(18,2);
define vmontor2				DECIMAL(18,2);
DEFINE cMotivo				CHAR(5);
-- RQM 09 440

DEFINE dBcScore 			DECIMAL(5,2);
DEFINE dScoreProp 			DECIMAL(5,2);
DEFINE dFico 				DECIMAL(5,2);
DEFINE dFicoExtended 		DECIMAL(5,2);
DEFINE dIcc 				DECIMAL(5,2);
DEFINE v_selectcredito 		CHAR(20);
DEFINE cFlag2Credito   		VARCHAR(120,1);
DEFINE cStatus_Ini 			CHAR(2);
DEFINE cRevisado 			CHAR(2);
DEFINE cIdbox 				SMALLINT;
DEFINE cIfe 				CHAR(2);
DEFINE cGrupo				CHAR(01);
DEFINE sMesesVencidos 		SMALLINT;
DEFINE sNumPagos			SMALLINT;
DEFINE dMontoPagos			DECIMAL(18,2);
DEFINE dFechaVencido 		DATE;
DEFINE cPpyrNumCredito 		CHAR(20);

DEFINE iTotalCuentasProcesadas	INTEGER;
DEFINE iCuentasInsertadas		INTEGER;
DEFINE iCuentasActualizadas		INTEGER;
DEFINE dFechaInicio				DATE;
DEFINE vfecha_vencim		DATE;
DEFINE dFechaFin			DATE;
DEFINE dFecha				DATE;

DEFINE v_pago_mensual 		DECIMAL(18,2);

DEFINE cAct                     INTEGER;
DEFINE cAtr                     INTEGER;
DEFINE v_fecha_vencido  DATE;
DEFINE v_dias_vencido   INTEGER; 
DEFINE contador_commit	 INTEGER;

--Inicializacion de variables
LET sql_err					= 0;
LET isam_err				= 0;
LET error_info				= "";
LET cCod_Ret				= "000000";
LET cCod_Ret2				= "000000";
LET cMensaje				= 'PROCESO EXITOSO.';
LET cMensajeBitacora		= '';
LET vproceso	            = '2070'; --'2060';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre		    		= "";
LET cnomarchivo             = "";
LET cnomarchivo1            = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = ";";
LET cCod_RetIB              = "000000";
LET pfechacorte 			= DATE(1);
LET Vult_dia_mes 			= DATE(1);
LET Vpri_dia_mes 			= DATE(1);

-----VARIABLES
LET Vcreditoexterno			= '';
LET Vproducto				= '';
LET Vnum_credito			= '';
LET cNumCredito				= '';
LET VcreditoConsulta		= '';
LET  Vnumcte				= '';
LET Vnum_tarjeta			= '';
LET Vnum_sucursal			= '';
LET  Vnom_sucursal			= '';
LET  Vingreso_mensual		= 0;
LET  Vmonto_apertura		= 0;
LET  Vfecha_apertura		= DATE(1);

LET Vplazo						= 0;
LET Vestatus					= '';
LET Vsaldo_insoluto				= 0;
LET Vcapital_vigente			= 0;
LET Vcapital_transitorio		= 0;
LET Vsaldo_vencido_exigible		= 0;
LET Vsaldo_vencido_no_exigible	= 0;
LET Vsaldo_actual				= 0;
LET Vsaldo_cierre				= 0;
LET Vmes_vencido				= 0;
LET Vtipo_mov					= '';
LET Vfecha_mov					= DATE(1);

LET Vsexo					= '';
LET Vfecha_nac				= DATE(1);
LET Vnombre1 				= '';
LET Vnombre2 				= '';
LET Vapellido_p 			= '';
LET Vapellido_m 			= '';
LET Vmail 					= '';
LET Vdir_calle 				= '';
LET Vdir_numero 			= '';
LET Vdir_colonia 			= '';
LET Vcp 					= '';

LET Vdir_municipio			= '';
LET Vnum_estado				= 0;
LET Vdir_estado				= '';
LET Vnum_cd_coppel			= 0;
LET Vcd_coppel				= '';
LET Vnum_cd_banco			= 0;
LET Vcd_banco				= '';
LET Vtel1					= '';
LET Vtel2					= '';
LET Vtel3					= '';
LET Vext					= '';

LET Vref_coppel				= '';
LET Vficiencia				= 0;
LET Vmeses_historia			= 0;
LET Vhit					= '';
LET Vsecc1					= '';
LET Vsecc2					= 0;

	  --variables
LET	Vnumcreditortc			= '';
LET Vnumcuentartc			= '';
--LET	Vnumcte     		= '';
LET	Vnumsucursal			= 0;
LET Vsaldoactual			= 0;
LET Vabonosvencidos			= 0;
LET Vestadocredito			= 0;
LET Vplazortc				= 0;
LET	dFechaUltPago			= DATE(1);
LET dFechaUltimoPago		= DATE(1);
LET Vtipoultimomov			= '';
LET Vfechacorte				= DATE(1);
let Vprod					= '';
let vmontor1				= 0;
let vmontor2				= 0;
LET cMotivo					= '';

LET dScoreProp				= "";
LET dBcScore				= "";
LET dFico					= "";
LET dFicoExtended			= "";
LET dIcc					= "";
let v_selectcredito 		= "";
LET cFlag2Credito			= "";
LET cStatus_Ini				= "";
LET cRevisado				= "";
LET cIdbox					= 0;
LET cIfe					= "";
LET cGrupo					= '';
LET sMesesVencidos			= 0;
LET sNumPagos				= 0;
LET dMontoPagos				= 0;
LET dFechaVencido			= DATE(1);
LET cPpyrNumCredito			= '';

LET iTotalCuentasProcesadas	= 0;
LET iCuentasInsertadas		= 0;
LET iCuentasActualizadas	= 0;
LET dFechaInicio			= DATE(1);
LET vfecha_vencim			= DATE(1);
LET dFechaFin				= DATE(1);
LET dFecha					= DATE(1);
LET v_pago_mensual			= 0;

LET v_fecha_vencido  = DATE(1);
LET v_dias_vencido   =0;  
LET cAct                        = 0;
LET cAtr                        = 0;
LET contador_commit = 	0;	

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            --LET cMensaje = error_info;
			LET cMensaje = 'ERROR en el proceso: ' || cNumCredito || '   ' || trim(error_info);
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02') returning cCod_ret2;
        RETURN cCod_ret,cMensaje;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/sp_cartera_total_ppyr_finmesPRUEBA.out";
	--TRACE ON;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
	
	--colocar en ves de la consulta anterior:
	LET cdelimitador = ';';
	LET cruta = '/resplogifx/archivoscartera/';
--	LET cruta = '/home/c90260202/archivoscartera/'; --alex


	-------------------------------GENERA TABLA-------------------------------------
	
	LET pfechacorte = mdy(month(today),1,year(today)) - 1; -- Ejecuta_finmesrse al cambio de fechas de Credito y/o despues de la 1.30 hrs. CDMX para que tome la fecha del nuevo dia
	
	LET dFechaInicio = mdy(month(pfechacorte),1,year(pfechacorte));
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Genera tabla temporal', '02') returning cCod_ret2;
	
	
	update statistics medium for table sd_maecredcontcrd;			-- m2025
	update statistics medium for table sd_maesdoscontcrd;			-- m2025
	update statistics medium for table sd_cartera_total_ppyr_finmes;	update statistics medium for table sd_movhiscrd;				-- m2025
	update statistics medium for table bdisolic:ss_resumen_scoring;	-- m2025
	update statistics medium for table bdinteg:si_direcciones_actual;	
	SET ISOLATION TO DIRTY READ;	select crd.num_credito, crd.fecha_apertura, crd.numcte , crd.num_producto, crd.credito_externo, crd.sucursal,
			crd.plazo, crd.status_cred, ppyr.num_credito ppyr_num_credito,													 
			b.monto_otorgado, b.sdo_cap_insoluto,b.sdo_capital,b.monto_vencido,
			b.mto_venc_trasp,b.cap_tras_no_venci,b.mto_fin_ven_trasp, crd.fecha_vencim, ppyr.fecha,					
			ppyr.pago_mensual, 0 as act, b.atr
	  from bdicred:sd_maecredcontcrd crd 
      inner join bdicred:sd_maesdoscontcrd b on b.fecha = crd.fecha --and b.empresa = crd.empresa 
											and b.num_credito = crd.num_credito										 
	  left outer join bdicred:sd_cartera_total_ppyr_finmes ppyr on ppyr.num_credito = crd.num_credito
	  where crd.fecha =pfechacorte 
	   and crd.num_producto in ('6300','6011','7600','7700','6800') 
	   and crd.status_cred != 'FI' --and crd.num_credito in ('610000008314','610005551276','610005564253')
	into temp CreditosCrd with no log;

	create index indx_creditos on CreditosCrd (num_credito) using btree in dbs_movhis_idx5 ONLINE;
	update statistics medium for table CreditosCrd;
	
		select cod_fun from bdicred:sd_conceptospagomanualcrd
		where num_producto in ('6001','8500','7800','7000','8100')
			into temp tmp_conceptos with no log;
		
		create index idx_conceptospmcrd on tmp_conceptos(cod_fun)using btree in dbs_movhis_idx5 ONLINE;

	--------------------INSERTAR EN TABLA-----------------------------------
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Inicia Foreach', '02') returning cCod_ret2;

	FOREACH WITH HOLD
		select a.num_credito, a.fecha_apertura, a.numcte, a.num_producto, a.credito_externo, a.sucursal,suc.nombre,
		a.plazo, a.status_cred, a.ppyr_num_credito,
			a.monto_otorgado, a.sdo_cap_insoluto, a.sdo_capital, a.monto_vencido, a.mto_venc_trasp, a.cap_tras_no_venci, a.mto_fin_ven_trasp,
			c.fecha_ult_pago,a.fecha_vencim, a.fecha, a.act, a.atr
		  into   Vnum_credito, vfecha_apertura, Vnumcte, Vproducto, Vcreditoexterno, Vnum_sucursal, vnom_sucursal, vplazo, vestatus, cPpyrNumCredito,
		    vmonto_apertura, vsaldo_insoluto, vcapital_vigente, vcapital_transitorio, vsaldo_vencido_exigible, vsaldo_vencido_no_exigible, vmes_vencido,
			dFechaUltPago, vfecha_vencim, dFecha, cAct, cAtr
		  from CreditosCrd a 
		 inner join bdicred:sd_maecredanexocrd c on c.empresa = cempresa and a.num_credito = c.num_credito
		 left outer join bdinteg:si_sucursales suc on suc.empresa = cempresa and a.sucursal = suc.sucursal

   
		--************eliminar el empresa************************************************************************
  
		if dFechaUltPago is null or dFechaUltPago = '' then let dFechaUltPago = date(1); end if;
		if vfecha_vencim is null or vfecha_vencim = '' then let vfecha_vencim = date(1); end if;															 
		if cPpyrNumCredito is null or cPpyrNumCredito = '' then let cPpyrNumCredito = '-1'; end if;
		if dFecha is null or dFecha = '' then let dFecha = date(1); end if;
  
		if dFecha = pfechacorte then CONTINUE FOREACH; end if;
		
			
		IF contador_commit = 0 THEN
			BEGIN WORK;
		END IF;	   
		--BEGIN WORK;
	
		let cNumCredito = Vnum_credito;
		let iTotalCuentasProcesadas = iTotalCuentasProcesadas + 1;

		SET ISOLATION TO DIRTY READ;		SELECT first 1 ca.nombrecalle ,dir.numeroextcalle,zo.nombrezona,dir.cod_postal,cd.nombre as dir_mun,
		es.estado as num_estado,es.nombre as dir_estado,cd.ciudad_coppel as cd_coppel,cd.nombre ,
		zo.numerociudad as num_banco ,zo.poblacionzona as cd_banco
		INTO vdir_calle,vdir_numero,vdir_colonia,vcp
		,Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,Vcd_banco 
		FROM bdinteg:si_direcciones_actual dir 
		inner join bdinteg:si_catcalles ca on (dir.numerocalle = ca.numerocalle )
		inner join bdinteg:si_catzonas zo on (dir.numerociudad = zo.numerociudad   and dir.numerocolonia = zo.numerocolonia)
		inner join bdinteg:si_ciudades cd on (dir.estado = cd.estado    and dir.ciudad = cd.ciudad )
		inner join bdinteg:si_estados es on (dir.estado = es.estado )
		WHERE dir.numcte = Vnumcte AND dir.tipo_dir = 1;

		SELECT LIMIT 1 correo_elec
		  INTO Vmail
		  FROM bdinteg:si_correos
		 WHERE numcte = Vnumcte
		   AND status_correo = 'A';
		
		SELECT LIMIT 1 a.telefono, d.telefono,d.extension
			INTO Vtel1 , Vtel3 ,Vext
        FROM bdinteg:si_telefonos_actual a
     LEFT OUTER JOIN bdinteg:si_telefonos_actual d on ( d.numcte = a.numcte and d.tipo_tel = 3 AND d.status_tel = 'A' and d.cofetel = 'V') 
       WHERE a.numcte = vnumcte
         AND a.tipo_tel = 1
         AND a.status_tel = 'A' 
         AND a.cofetel = 'V' ;   

      SELECT LIMIT 1 a.telefono
			INTO Vtel2
        FROM bdinteg:si_telefonos_actual a
       WHERE a.numcte = vnumcte
         AND a.tipo_tel = 2
         AND a.status_tel = 'A' 
         AND a.cofetel = 'V' ;		   

		IF (vestatus <> 'FF') THEN 
			LET Vsaldo_cierre = vsaldo_insoluto; 
		else 
			LET Vsaldo_cierre = 0; 
		end if;

		-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------

		
		if dFechaUltPago >= dFechaInicio and dFechaUltPago <= pfechacorte then
			LET Vtipoultimomov = 'P'; -- Pago
		else 

			if vfecha_apertura >= dFechaInicio and vfecha_apertura <= pfechacorte then
					LET Vtipoultimomov = 'A'; -- Apertura
			else 
				LET Vtipoultimomov = ''; -- Sin movimiento
			end if;
		end if;
		SET ISOLATION TO DIRTY READ;        SELECT COUNT(*),SUM(monto) INTO sNumPagos,dMontoPagos
          FROM bdicred:sd_movhiscrd
         WHERE --empresa = cempresa AND 
			   fecha_mov >= MDY(MONTH(pfechacorte),1,YEAR(pfechacorte))
           AND fecha_mov <= pfechacorte
           AND num_credito = Vnum_credito
           AND codigo_fun IN (select cod_fun from tmp_conceptos)
           AND codigo_ref = 1 
           AND reversado = 'N';

		IF dMontoPagos IS NULL OR dMontoPagos = '' THEN
			LET sNumPagos = 0;
			LET dMontoPagos = 0;
		END IF;
		

		SELECT pago_mens  --NVL(pago_mens,0)
			INTO v_pago_mensual
			FROM bdisolic:ss_revision_determinacion
			WHERE num_solicitud = Vnum_credito;
			
		IF v_pago_mensual IS NULL OR v_pago_mensual = '' THEN
			LET v_pago_mensual = 0;
		END IF;

	-- MODIFICACION REPORTE RQM 09 459-2 (FIN)
--		IF (vestatus != 'AA' OR (NVL(atr_aux,-1)<> 0 and vestatus <> 'E1')) OR (vestatus = 'VP' AND vmes_vencido > 0) THEN
		IF (vcapital_transitorio+vsaldo_vencido_exigible) > 0 AND vmes_vencido > 0 THEN

			-- RQM 09 476 - 2 ADENDUM 				
			IF pfechacorte <= vfecha_vencim THEN 	
				LET sMesesVencidos = vmes_vencido; -- sd_maesdosCONTcrd
			ELSE
						
				--Caso donde el credito vencio: cuenta meses en la actual + meses historicos 
				--BIS 2008,2012,2016,2020,2024
				IF month(vfecha_vencim)in ('01','03','05','07','08','10','12') then 
					Let dFechaFin = mdy(month(vfecha_vencim),'31',year(vfecha_vencim));
				ELIF month(vfecha_vencim)in ( '04','06','09','11') then 
					Let dFechaFin = mdy(month(vfecha_vencim),'30',year(vfecha_vencim));
				ELIF month(vfecha_vencim) = '02' then 
					--IF mod(year(vfecha_vencim),4) = 0 AND ((mod(year(vfecha_vencim),4,100)) <> 0 OR (mod(year(vfecha_vencim),400) = 0)) THEN
					IF year(vfecha_vencim) IN ('2008','2012','2016','2020','2024','2028') then 
						Let dFechaFin = mdy(month(vfecha_vencim),'29',year(vfecha_vencim));
					ELSE
						Let dFechaFin = mdy(month(vfecha_vencim),'28',year(vfecha_vencim));
					END IF;
				END IF;
				
				--eliminar la consulta anterior sin sentido al usar datos ya existentes.
				LET sMesesVencidos = (year((pfechacorte)+1 units month) - year(dFechaFin)) * 12 + ( month((pfechacorte)+1 units month) - month(dFechaFin)) ;
			END IF;
		ELSE
			LET sMesesVencidos = 0;
		END IF;
	
		--NUEVOS CAMPOS ADENDUM RQM 04 127
            IF Vproducto in ('6001','8500','7800','7000','8100') then
                SELECT dias_atraso--fecha_vencido, dias_atraso
                INTO v_dias_vencido--v_fecha_vencido, 
                FROM sd_indicador_cred
                WHERE num_credito=Vnum_credito and empresa= '001';
				
				select fecha_vencto
				into v_fecha_vencido
				from bdicred:sd_maecredanexo
				where num_credito=Vnum_credito
				and empresa = cempresa;
                            
            ELSE 
                SELECT dias_atraso--fecha_vencido,
                INTO v_dias_vencido--v_fecha_vencido, 
                FROM sd_indicador_cred_crd
                WHERE num_credito=Vnum_credito and empresa = '001';
				
				select fecha_vencto
				into v_fecha_vencido
				from bdicred:sd_maecredanexocrd
				where num_credito=Vnum_credito
				and empresa = cempresa;
                
            END IF;
			
--Si es cuenta nueva se inserta registro nuevo en tabla, de lo contrario se actualizan datos a cuentas existentes
		if cPpyrNumCredito = '-1' then
			SELECT cte.numcte_ref,cte.nombre1, cte.nombre2, cte.apell_paterno  , cte.apell_materno,nvl(pf.sexo,''),nvl(pf.fecha_nac,'')
			INTO Vref_coppel,vnombre1 , vnombre2 ,vapellido_p ,vapellido_m,vsexo,vfecha_nac
			FROM  bdinteg:si_cliente cte 
			INNER JOIN bdinteg:si_ctepf pf on (pf.numcte = cte.numcte)
			WHERE cte.numcte = Vnumcte;
		
			SELECT cta.num_cta 
			--SELECT nvl(cta.num_cta,0)
			  INTO Vnum_tarjeta 
			FROM bdicred:sd_ctascarg cta
				WHERE cta.num_credito = Vnum_credito;
			
			IF Vnum_tarjeta is null or Vnum_tarjeta = '' THEN LET Vnum_tarjeta = 0; END IF;
			
			LET Vnumcuentartc = Vnum_tarjeta;	
		
	
			SELECT LIMIT 1 sc01 --nvl(sc01,'')
			  INTO  Vsecc1
			  FROM bdiburo:br_sc  br 
			 WHERE  br.num_cliente = Vnumcte;	

			IF Vsecc1 is null or Vsecc1 = '' THEN LET Vsecc1 = ''; END IF;			 

			SELECT limit 1 nvl(sum(valor),0) into Vsecc2
			  FROM bdisolic:ss_detalle_scoring 
			 WHERE empresa = cempresa
			   AND num_solicitud = Vnum_credito;
			
			IF Vsecc2 is null or Vsecc2 = '' THEN LET Vsecc2 = 0; END IF;

---------------------
			SELECT ingreso_mensual,situacion_pago , meses_historia,	evalua_cc, grupo
			INTO Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit, cGrupo
			from bdisolic:ss_resum_scor_fin scor
			where scor.empresa = cempresa
			and scor.num_solicitud = Vnum_credito;
			
			IF Vingreso_mensual is null or Vingreso_mensual = '' THEN LET Vingreso_mensual = 0; END IF;
			IF Vficiencia is null or Vficiencia = '' THEN LET Vficiencia = 0; END IF;
			IF Vmeses_historia is null or Vmeses_historia = '' THEN LET Vmeses_historia = 0; END IF;
			
			IF Vhit is null or Vhit = '' THEN
				LET Vhit = 'No Hit';
			ELSE 
				IF Vhit = 'X' THEN
					LET Vhit = 'No Hit';
				ELSE
					LET Vhit = 'HIT';
				END IF;
			END IF;
			
---------------------

		--obtener causa solicitud
			IF Vproducto != '6011' THEN
				SET ISOLATION TO DIRTY READ;				select limit 1 a.causa_solicitud --nvl(a.causa_solicitud,'') 
				into cMotivo
				from bdisolic:ss_autorizacion a
				where --a.empresa = cempresa and 
				a.num_solicitud = vNum_Credito
				and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = vNum_Credito and status_solicitud = 'AT')
				and a.status_solicitud = 'AT';
				
				IF cMotivo is null or cMotivo = '' THEN LET cMotivo = ''; END IF;
			
			ELSE
				let cMotivo = '';
			END IF;	
		
------------Obtenemos los valores de scores de originacion
			if Vproducto = '6011' then
				let v_selectcredito = Vcreditoexterno;
			else 
				let v_selectcredito = Vnum_credito;
			end if
			
			SET ISOLATION TO DIRTY READ;			select evaluacion,
					(select evaluacion from bdisolic:ss_resumen_scoring where --empresa = cempresa and 
																			num_solicitud = v_selectcredito and seccion= 2 ),
					(select evaluacion from bdisolic:ss_resumen_scoring where --empresa = cempresa and 
																			num_solicitud = v_selectcredito and seccion= 3 ),
					(select evaluacion from bdisolic:ss_resumen_scoring where --empresa = cempresa and 
																			num_solicitud = v_selectcredito and seccion= 4 ),
					(select evaluacion from bdisolic:ss_resumen_scoring where --empresa = cempresa and 
																			num_solicitud = v_selectcredito and seccion= 5 )
			 into dBcScore, dScoreProp, dFico, dFicoExtended, dIcc
			 from bdisolic:ss_resumen_scoring 
			where num_solicitud = v_selectcredito AND empresa = '001'
			  and seccion = 1;
			
			SELECT LIMIT 1 flag2creditoicc --DECODE(flag2creditoicc,'1','Evaluacion de segundo producto de credito en adelante','')
				INTO cFlag2Credito
				FROM bdisolic:"informix".ss_revision_determinacion
			   WHERE --empresa = cempresa  AND 
					num_solicitud = v_selectcredito;
					
			--******************revisar esta parte
			IF cFlag2Credito = '1' THEN
				LET cFlag2Credito = 'Evaluacion de segundo producto de credito en adelante';
			ELSE
				LET cFlag2Credito = '';
			END IF;
								 
			IF cFlag2Credito IS NULL THEN 
			   LET cFlag2Credito = ' ';
			END IF;
			
		-- MODIFICACION REPORTE RQM 09 459-2 (INICIO)
			SELECT status_ini,CASE WHEN revisado = 'N' THEN 'C'ELSE 'R' END
			 INTO cStatus_Ini,cRevisado
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE --empresa = cempresa  AND 
				num_solicitud = v_selectcredito;
				 
			IF cStatus_Ini IS NULL or cStatus_Ini = '' THEN LET cStatus_Ini = ' '; END IF;
			IF cRevisado IS NULL  or cRevisado = '' THEN LET cRevisado = ' '; END IF;			 
			
			SELECT COUNT(*) 
			 INTO cIdbox
			 FROM bdisolic:"informix".ss_solicitudes_mc a
			 RIGHT OUTER JOIN bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			WHERE --empresa = cempresa AND
			  num_solicitud = v_selectcredito;
			 			
			IF cIdbox >= 1 THEN 
			   LET cIFE = 'Si';
			ELSE   
			   LET cIFE = 'No'; 
			END IF;	
			
			INSERT INTO bdicred:sd_cartera_total_ppyr_finmes 
					(fecha, producto, num_credito, numcte, num_tarjeta, num_sucursal, nom_sucursal, ingreso_mensual,
					monto_apertura, fecha_apertura, plazo, estatus, saldo_insoluto, capital_vigente,
					capital_transitorio, saldo_vencido_exigible, saldo_vencido_no_exigible, saldo_actual, 
					saldo_cierre, mes_vencido, tipo_mov, fecha_mov, sexo, fecha_nac, nombre1, Nombre2, apellido_p,
					apellido_m, mail, dir_calle, dir_numero, dir_colonia, cp, dir_municipio, num_estado,
					dir_estado, num_cd_coppel, cd_coppel, num_cd_banco, cd_banco, tel1, tel2, tel3, ext, ref_coppel,
					eficiencia, meses_historia, hit, secc1, secc2, motivo, bc_score, score_prop, fico, fico_extended,
					icc, flag2credito, status, revisado, ife, grupo, meses_vencidos, num_pagos, monto_pagos,pago_mensual,
					act, atr,fecha_vencido, dias_vencido )
			VALUES
					(pfechacorte, Vproducto, Vnum_credito, Vnumcte, Vnum_tarjeta, Vnum_sucursal, Vnom_sucursal, nvl(Vingreso_mensual,''),
					Vmonto_apertura, Vfecha_apertura, Vplazo, Vestatus, Vsaldo_insoluto, Vcapital_vigente,
					Vcapital_transitorio, Vsaldo_vencido_exigible, Vsaldo_vencido_no_exigible, Vsaldo_actual,
					Vsaldo_cierre, Vmes_vencido, Vtipoultimomov, dFechaUltPago, Vsexo, Vfecha_nac, Vnombre1, Vnombre2, Vapellido_p,
					Vapellido_m, nvl(Vmail,''), Vdir_calle, Vdir_numero, Vdir_colonia, Vcp, Vdir_municipio, Vnum_estado,
					Vdir_estado, Vnum_cd_coppel, Vcd_coppel, Vnum_cd_banco, Vcd_banco, nvl(Vtel1,''), nvl(Vtel2,''), nvl(Vtel3,''),nvl(Vext,''), Vref_coppel,
					Vficiencia, Vmeses_historia, Vhit, Vsecc1, Vsecc2, cMotivo, nvl(dBcScore,''), nvl(dScoreProp,''), nvl(dFico,''), nvl(dFicoExtended,''), 
					nvl(dIcc,''), cFlag2Credito, cStatus_Ini, cRevisado, cIfe, nvl(cGrupo,''), nvl(sMesesVencidos,0), nvl(sNumPagos,0), nvl(dMontoPagos,0),
					v_pago_mensual,cAct, cAtr, v_fecha_vencido, v_dias_vencido);

			let iCuentasInsertadas = iCuentasInsertadas + 1;
		else
			update bdicred:sd_cartera_total_ppyr_finmes
			   set	
					fecha = pfechacorte, estatus = vestatus, saldo_insoluto = Vsaldo_insoluto, capital_vigente = Vcapital_vigente, 
					capital_transitorio = Vcapital_transitorio, saldo_vencido_exigible = Vsaldo_vencido_exigible,
					saldo_vencido_no_exigible = Vsaldo_vencido_no_exigible, saldo_actual = Vsaldo_actual, saldo_cierre = Vsaldo_cierre,
					mes_vencido = Vmes_vencido, tipo_mov = Vtipoultimomov, fecha_mov = dFechaUltPago, mail = nvl(Vmail,''),
					dir_calle = Vdir_calle, dir_numero = Vdir_numero, dir_colonia = Vdir_colonia, cp = Vcp, dir_municipio = Vdir_municipio,
					num_estado = Vnum_estado, dir_estado = Vdir_estado, num_cd_coppel = Vnum_cd_coppel, cd_coppel = Vcd_coppel, 
					num_cd_banco = Vnum_cd_banco, cd_banco = Vcd_banco, tel1 = nvl(Vtel1,''), tel2 = nvl(Vtel2,''), tel3 = nvl(Vtel3,''),
					ext = nvl(Vext,''), meses_vencidos = nvl(sMesesVencidos,0), num_pagos = nvl(sNumPagos,0), monto_pagos = nvl(dMontoPagos,0),
					pago_mensual = v_pago_mensual,act=cAct, atr=cAtr ,fecha_vencido=v_fecha_vencido, dias_vencido=v_dias_vencido
			where num_credito = Vnum_credito;
			
			let iCuentasActualizadas = iCuentasActualizadas + 1;
		end if;

		--COMMIT WORK;
		
			LET contador_commit = contador_commit  + 1;
			
			IF (contador_commit >= 500) THEN
				COMMIT WORK;
				LET contador_commit = 0; 
				--BEGIN WORK;
			END IF;
		
	END FOREACH;	
	
	
    let cMensajeBitacora = 'TOTAL Cuentas procesadas : ' || iTotalCuentasProcesadas;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02') RETURNING cCod_ret2;
    let cMensajeBitacora = 'Cuentas insertadas: ' || iCuentasInsertadas;
    let cMensajeBitacora = trim(cMensajeBitacora) ||'    Cuentas actualizadas: ' || iCuentasActualizadas;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, trim(cMensajeBitacora), '02') RETURNING cCod_ret2;

--SET DEBUG FILE TO "prueba12052017-1.out";
--TRACE ON;	
--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	--let cruta = '/informix/jorger/pruebas/';
	--let cruta = '/ifxsif01/PEDRO/';s
	--let cruta = '/informix/RESPALDOSNEW/';
	let cnombre = 'Cartera_Total_FinMes';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';
	 
	let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
--	LET cSQL2 = " select * from bdicred:sd_cartera_total_ppyr_finmes ";
	LET cSQL2 = ' select producto,num_credito,numcte,num_tarjeta,num_sucursal,nom_sucursal,ingreso_mensual,monto_apertura,fecha_apertura,plazo,estatus,saldo_insoluto,capital_vigente,'||
	' capital_transitorio,saldo_vencido_exigible,saldo_vencido_no_exigible,saldo_actual,saldo_cierre,mes_vencido, dias_vencido, atr, act, to_char( fecha_vencido,'''|| '%d/%m/%Y' || ''') fecha_vencido,tipo_mov,fecha_mov,sexo,fecha_nac,'||
	' nombre1,nombre2,apellido_p,apellido_m,mail,dir_calle,dir_numero,dir_colonia,cp,dir_municipio,num_estado,dir_estado,num_cd_coppel,cd_coppel,num_cd_banco,cd_banco,'||
	' tel1,tel2,tel3,ext,ref_coppel,eficiencia,meses_historia,hit,secc1,secc2,motivo,bc_score,score_prop,fico,fico_extended,icc,flag2credito,status,revisado,ife,'||
	' grupo,meses_vencidos,num_pagos,monto_pagos,pago_mensual'||
	' from bdicred:sd_cartera_total_ppyr_finmes where fecha = '|| ''''|| pfechacorte || ''''||'';
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta_finmes.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta_finmes.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_finmes.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " > " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;

    LET cSql = cSql;
    LET cSql = "gzip "|| TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta_finmes.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL; 

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03') returning cCod_ret2;

	let cMensaje = trim(cMensaje) || ' TOTAL Cuentas procesadas: '|| iTotalCuentasProcesadas;

	RETURN cCod_ret,cMensaje;
	
END;
END PROCEDURE;