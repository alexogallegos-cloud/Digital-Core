CREATE PROCEDURE "informix".sp_autoriza_incremento_auto(pEmpresa CHAR(3),pNumCredito CHAR (20), pRespuesta CHAR(1))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;           

---DECLARACIONES          
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(80);
DEFINE cComentario           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE sReg_Afectados        SMALLINT;
DEFINE sStatusRT             CHAR(5);

---INICIALIZACIONES
LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Se realizÃ³ la consulta correctamente";
LET sReg_Afectados                 = 0;
LET sStatusRT                = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_autoriza_incremento_auto.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT status_solicitud
INTO sStatusRT
FROM bdisolic:ss_solicitudes WHERE num_solicitud = pNumCredito;

IF sStatusRT = 'RT' THEN 
    LET cCodRet= '00002';
    LET cMensajeRet= 'Esta cuenta se encuentra con status RT, no va a ser Aperturada.';
RETURN cCodRet, cMensajeRet;
END IF;

 UPDATE bdisolic:"informix".ss_solicitudes
	SET ajuste_de_cuota = pRespuesta
 WHERE empresa=pEmpresa
 AND num_solicitud = pNumCredito;
 
	LET sReg_Afectados = dbinfo("sqlca.sqlerrd2");
	IF (sReg_Afectados = 0) THEN
			LET cCodRet= '000001';
			LET cMensajeRet= 'No fue posible actualizar el nÃºmero de crÃ©dito con la respuesta del cliente';
	END IF;
 RETURN cCodRet, cMensajeRet;
		
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para actualizar la confirmacion o cancelacion de incrementos automaticos de linea de crÃ©dito',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 04/03/2010',
'BD    : BDICRED',
'Version: 20110304.1210';

CREATE PROCEDURE "informix".sp_autoriza_incremento_auto_web(pEmpresa CHAR(3),pNumCredito CHAR (20), pRespuesta CHAR(1))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;

---DECLARACIONES
DEFINE cCodRet               CHAR(5);
DEFINE cMensajeRet           CHAR(80);
DEFINE cComentario           CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE sReg_Afectados         SMALLINT;
DEFINE sStatusRT         CHAR(5);

---INICIALIZACIONES
LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "00000";
LET cMensajeRet              = "Se realizÃ³ la consulta correctamente";
LET sReg_Afectados                 = 0;
LET sStatusRT                = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_autoriza_incremento_auto.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT status_solicitud
INTO sStatusRT
FROM bdisolic:ss_solicitudes WHERE num_solicitud = pNumCredito;

IF sStatusRT = 'RT' THEN 
    LET cCodRet= '00002';
    LET cMensajeRet= 'Esta cuenta se encuentra con status RT, no va a ser Aperturada.';
RETURN cCodRet, cMensajeRet;
END IF;

 UPDATE bdisolic:"informix".ss_solicitudes
	SET ajuste_de_cuota = pRespuesta
 WHERE empresa=pEmpresa
 AND num_solicitud = pNumCredito;

	LET sReg_Afectados = dbinfo("sqlca.sqlerrd2");
	IF (sReg_Afectados = 0) THEN
			LET cCodRet= '00001';
			LET cMensajeRet= 'No fue posible actualizar el numero de credito con la respuesta del cliente';
	END IF;
 RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para actualizar la confirmacion o cancelacion de incrementos automaticos de linea de credito',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 04/03/2010',
'BD    : BDICRED',
'Version: 20110304.1210';

CREATE PROCEDURE "informix".cargoref_tc_ofi_web(o_empresa  CHAR(3),
				 o_sucursal CHAR(4),
				 o_usuario  CHAR(8),
				 o_tarjeta  CHAR(20),
				 o_monto    DECIMAL(14,2),
				 o_folio    CHAR(16),
				 o_transuc  CHAR(4))

RETURNING CHAR(5),   -- Codigo Retorno
	  DECIMAL(14,2), -- Saldo Disponible 
      DECIMAL(14,2), -- Importe Cargado
	  DECIMAL(14,2), -- Importe Comision
      DECIMAL(14,2); -- Iva de Comisiones

-- **************************************************************************
-- *                      DEFINICION DE VARIABLES                           *
-- **************************************************************************
DEFINE cod_ret            CHAR(5);
DEFINE cod_ret2           CHAR(5);
DEFINE sql_err            SMALLINT;
DEFINE isam_err           SMALLINT;
DEFINE error_info         CHAR(40);
DEFINE Saldo              MONEY(14,2);
DEFINE SaldoCom           MONEY(14,2);
DEFINE v_monto		      MONEY(14,2);
DEFINE v_codparam	   	  CHAR(4);
DEFINE v_fecha            DATE;
DEFINE v_num_credito      CHAR(20);
DEFINE v_divisa		  	  CHAR(2);
DEFINE MtoCgo		  	  MONEY(14,2);
DEFINE MtoCom		   	  MONEY(12,2);
DEFINE v_faplica          CHAR(1);
DEFINE v_factor		 	  DECIMAL(9,6);
DEFINE v_rangos		 	  CHAR(1);
DEFINE v_rmax	          MONEY(14,2);
DEFINE vIva		  		  MONEY(14,2);
DEFINE dMonto		 	  DECIMAL(18,2);
DEFINE cFolioPromo		  CHAR(16);
DEFINE cCodRetGenMov	  CHAR(10);
DEFINE cMsjeGenMov		  CHAR(80);
DEFINE v_dv               CHAR(2);
DEFINE v_tipocambio       DECIMAL(14,6);
DEFINE vsucorig           CHAR(4);
DEFINE vBloqueo           INTEGER;
DEFINE dfh_pre_devol_an   DATE;
DEFINE dfh_devol_an       DATE;
DEFINE dSdoCapInsol       DECIMAL(18,2);
DEFINE cCodRetDevol		  CHAR(5);
DEFINE cMen_retDevol      CHAR(80);
DEFINE dMntoDevol         DECIMAL(16,2);
DEFINE vexist_reg         SMALLINT;
DEFINE vflag_siweb        SMALLINT;
DEFINE vbitacora_dup      SMALLINT;

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

ON EXCEPTION SET sql_err, isam_err, error_info
   --SET DEBUG FILE TO "CargoLineaCredito.err";
   --TRACE sql_err||" * "||isam_err||" * "||error_info;
   LET cod_ret = sql_err;
   LET Saldo = 0;
   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
END EXCEPTION;

-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret             = "00000";
LET Saldo               = 0;
LET cod_ret2            = "00000";
LET SaldoCom            = 0;
LET MtoCgo              = 0;
LET MtoCom              = 0;
LET vIva                = 0;
LET dMonto              = 0;
LET cFolioPromo         = "";
LET cCodRetGenMov		= "";
LET cMsjeGenMov		    = "";
LET v_dv                = "00";
LET v_tipocambio        = 0;
LET vsucorig            = "";
LET vBloqueo            = 0;
LET dfh_pre_devol_an    = date(1);
LET dfh_devol_an        = date(1);
LET dSdoCapInsol        = 0;
LET cCodRetDevol		= "";
LET cMen_retDevol       = ""; 
LET dMntoDevol          = 0;
LET vexist_reg          = 0;
LET vflag_siweb         = 0;
LET vbitacora_dup       = 0;

--SET DEBUG FILE TO "/informix/JesusBueno/cargofi.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --//validacion piloto SIWEB
    SELECT nvl(flag_piloto,0)
    INTO vflag_siweb
    FROM bdinteg:si_sucursales_web
    WHERE sucursal = o_sucursal;

    IF vflag_siweb <> 0 THEN
        --//validar registro existente
        SELECT {+index(mov2)} 
		       count(*)
        INTO vexist_reg
        FROM sd_movdia
        WHERE empresa = o_empresa AND folio_suc = o_folio AND sucursal = o_sucursal AND usuario = o_usuario AND 
              transacc_suc = o_transuc AND nro_tarjeta = o_tarjeta AND monto = o_monto;
        
        IF vexist_reg > 0 THEN
            --//parametro bitacora TX duplicadas
	        SELECT nvl(valor,0)
	        INTO vbitacora_dup
	        FROM bdinteg:si_param  
	        WHERE cod_param = 515;	        
	        
	        IF vbitacora_dup <> 0 THEN
	            insert into bitacora_dup values 
                (o_folio,o_sucursal,o_usuario,"0603",o_transuc,"",o_tarjeta,o_monto,current, current hour to fraction(3));
	        END IF
	        
	        RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
	        
	    END IF
    END IF          

	SELECT a.num_credito, b.divisa, b.sucursal, b.id_unidad_prod
	  INTO v_num_credito, v_divisa, vsucorig,   vBloqueo
	FROM bdicred:"informix".sd_tarjeta a, bdicred:"informix".sd_maecred b
	WHERE a.empresa = o_empresa
	   AND a.num_tarjeta = o_tarjeta
	   AND b.empresa = a.empresa
	   AND b.num_credito = a.num_credito;

	IF v_num_credito IS NULL THEN
		LET cod_ret = "00008";
	    RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
	END IF



	EXECUTE PROCEDURE bdicred:"informix".cargo_ref_cel(o_tarjeta, o_sucursal, o_usuario,
					o_transuc, o_transuc,  o_folio,
					v_num_credito, 1, o_monto, 0,
					" ", " ", v_divisa, "",  
					o_sucursal, o_usuario, "",
					"", "", v_num_credito,
					1, 0, v_divisa, " ", "2",
					"F"," ", " ", " ", 0, 0, " ", " ")
	INTO cod_ret, v_codparam, v_fecha, Saldo, MtoCgo, 
	     cod_ret2, v_codparam, v_fecha, SaldoCom, MtoCom;
		

	IF (LENGTH(TRIM(cod_ret)) == 3) THEN
		LET cod_ret = "00"||cod_ret;
	END IF;
	

	SELECT SUM(monto_com) INTO vIva 
    FROM bdicred:"informix".sd_detcomi
	WHERE num_credito = v_num_credito
        AND cod_comis IN ("6260","6261")
	    AND num_solicitud = o_folio
        AND empresa = o_empresa
	    AND num_credito=v_num_credito;

	SELECT SUM(monto_com) INTO MtoCom 
    FROM bdicred:"informix".sd_detcomi
	WHERE num_credito = v_num_credito
        AND cod_comis IN ("6902","6901")
	    AND num_solicitud = o_folio
        AND empresa = o_empresa
	    AND num_credito=v_num_credito;

    SELECT sdo_cap_insoluto + sdo_retenido    
        INTO SaldoCom                        
    FROM bdicred:"informix".sd_maesdos                         
    WHERE empresa = o_empresa
        AND num_credito=v_num_credito;

	IF MtoCom IS NULL THEN
		LET MtoCom = 0;
		LET vIva   = 0;
	END IF
	
	--JMAH 
	-- OBTIENE EL FOLIO DE LA PROMOCION Y EL MONTO DE LOS INTERESES DE CREDISOLUCIONES
	SELECT folio_movto, monto_int_iva
	INTO cFolioPromo, dMonto
	FROM bdicred:"informix".sd_promocion_credito
	WHERE num_credito = v_num_credito 
	AND folio_movto = o_folio 
	AND status = 6;
	-- VALIDA SI EL CARGO TUVO UNA CREDISOLUCION DE EFECTIVO LIGADA
	IF NVL(cFolioPromo,"") <> "" THEN

        SELECT valor INTO v_dv FROM bdinteg:si_param WHERE cod_param = 17;

		SELECT precio_venta INTO v_tipocambio
	    FROM bdinteg:si_tpcambio
		WHERE empresa = "001"
		   AND divisa = v_dv
		   AND clase_tpcambio = "O"
		   AND fecha_tpcambio = (SELECT MAX(fecha_tpcambio)
								FROM bdinteg:si_tpcambio
								WHERE empresa = "001"
									AND divisa = v_dv);

		UPDATE bdicred:"informix".sd_maesdos SET sdo_retenido = sdo_retenido + dMonto
		WHERE empresa = o_empresa
		AND num_credito = v_num_credito;

		INSERT INTO bdicred:"informix".sd_maeretenido
		(empresa, num_credito, folio_suc, fecha, hora, transacc, dias_ret,monto, usuario, estatus, referencia, sucursal, dias_ori)
		VALUES(o_empresa, v_num_credito, o_folio, CURRENT, CURRENT HOUR TO FRACTION(3),"6837", 0, dMonto, o_usuario, "R", trim(cFolioPromo) || ' RET. CREDISOLUCIONES', o_sucursal, 0);	
		
		UPDATE bdicred:"informix".sd_promocion_credito
			SET status = 0
		WHERE num_credito = v_num_credito
		AND folio_movto = o_folio;		

--     GENERAMOS EL MOVIMIENTO DEL RETENIDO DE LOS INTERESES
		EXECUTE PROCEDURE bdicred:"informix".genmov_tc('001',v_num_credito,'6001',TODAY,dMonto,o_folio,o_sucursal,v_divisa,'6837',o_tarjeta,'RET. CREDISOLUCIONES',v_tipocambio,0,o_usuario,vsucorig,'','')
		INTO cCodRetGenMov, cMsjeGenMov;

	END IF;


	-- Devolucion anualidad RQM 10 850 INI
	-- Obtiene marcas de creditos pre-cancelados por devolucion de anualidad
	SELECT nvl(date(ind.fecha_pre_devol_anual),date(1)), nvl(date(ind.fecha_devol_anual),date(1)), dos.sdo_cap_insoluto 
      INTO dfh_pre_devol_an,                       dfh_devol_an,                       dSdoCapInsol
    FROM bdicred:sd_indicador_cred ind JOIN bdicred:sd_maesdos dos ON (ind.empresa = dos.empresa and ind.num_credito = dos.num_credito )
    WHERE ind.empresa = '001' AND ind.num_credito = v_num_credito;
	 
	-- Si el credito tiene devolucion de anualidad, y el retiro termino correctamente, que proceda a marcar el credito como devolucion realizada.
	IF vBloqueo = 4 AND nvl(dfh_pre_devol_an,date(1)) > date(1) AND nvl(dfh_devol_an,date(1)) = date(1) AND dSdoCapInsol = 0 THEN
		-- Reinicia fecha para validaciones correctas en caso de retiro despues de un reverso del 1er retiro.
        EXECUTE PROCEDURE "informix".sp_comision_anual_devolucion(o_empresa, v_num_credito, o_usuario) INTO cCodRetDevol, cMen_retDevol, dMntoDevol;
		IF (cCodRetDevol = '00000' OR cCodRetDevol = '1208') AND dMntoDevol = 0 THEN
            --LET cod_ret = '01208'; -- Retiro de devolucion correcto. Credito se cancelara.
			LET cod_ret = '00000'; -- Retiro de devolucion correcto. Credito se cancelara.
		END IF

	END IF;
	-- Devolucion anualidad RQM 10 850 FIN
    RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica para contemplar movimientos diferidos, en el proceso de realizar el cargo al credito', 
'AUTOR: Jesus Aguilar ',
'FECHA: 08 FEBRERO 2012',
'BD: BDICRED',
'DESCRIPCION MODIFICACION: Se cambia el proceso para que guarde la transaccion 6837 en los retenidos de los intereses en lugar de la transaccion de disposicion',
'MODIFICO: Mohamed Carreon',
'VERSION: 20120607.0919',
'DESCRIPCION MODIFICACION: Se agrega validacion de transacciones duplicadas',
'MODIFICO: Victor Vazquez',
'FECHA: 05 MARZO 2024';

CREATE PROCEDURE "informix".principalrefer_web(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT, 
                           p_Tarjeta                CHAR(20),
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  LIKE sd_movdia.Folio_Suc,
                           p_Transacc               LIKE sd_movdia.Transacc_Suc,
                           p_MontoSBC               MONEY(14,2),
                           p_MontoEfe               MONEY(14,2),
                           p_referencia             CHAR(40))
  --Valores a Regresar
      RETURNING CHAR(5),     -- Codigo de Retorno
             MONEY(14,2), -- Remanente
             MONEY(14,2), -- Interes Moratorio Cobrado
             MONEY(14,2), -- Interes Vencido Cobrado
             MONEY(14,2), -- Capital Vencido Cobrado
             MONEY(14,2), -- Interes Vigente Cobrado
             MONEY(14,2), -- Capital Vigente Cobrado
             MONEY(14,2), -- Impuesto Cobrado
             MONEY(14,2), -- Comisiones Cobradas
             MONEY(14,2)  -- Seguro Cobrado

 DEFINE GLOBAL g_sistema       CHAR(2)     DEFAULT '06';

   DEFINE CodRet                CHAR(5);
   DEFINE vCodRet               CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);
   DEFINE wBegin                CHAR(1);
   DEFINE vfecha_hoy            DATE;
   
   DEFINE g_IntMoraCob   MONEY(14,2);
   DEFINE g_IntVencCob   MONEY(14,2);
   DEFINE g_CapVencCob   MONEY(14,2);
   DEFINE g_IntVigCob    MONEY(14,2);
   DEFINE g_CapVigCob    MONEY(14,2);
   DEFINE g_Impuesto     MONEY(14,2);
   DEFINE g_Comision     MONEY(14,2);
   DEFINE g_Seguro       MONEY(14,2);
   DEFINE g_Remanente    MONEY(14,2);
   DEFINE g_NumProducto   CHAR(4);
   DEFINE g_NumCte        CHAR(20);
   DEFINE v_NumCredito    CHAR(20);
   DEFINE vSdoTdc_Crds 	  		DECIMAL(14,2);	-- Cobro sdo a favor para pago PFSI
   DEFINE dFechaCreds	  		DATE;
   DEFINE cNum_Credisol	  		CHAR(20);
   DEFINE dCap_Credisol	  		DECIMAL(14,2);
   DEFINE dMntoPagoCredis 		DECIMAL(14,2);
   DEFINE cNumCredito_Crds		CHAR(20);
   DEFINE cCta_Eje_Crds        	CHAR(20);
   DEFINE cProducto_Crds       	CHAR(40);
   DEFINE cNum_Cte_Crds        	CHAR(20);
   DEFINE cNom_Cte_Crds        	CHAR(150);
   DEFINE dPago_Efec_Crds      	DECIMAL(18,2);
   DEFINE dPago_Cta_Crds       	DECIMAL(18,2);
   DEFINE dMonto_Op_Crds     	DECIMAL(18,2);
   DEFINE dSaldo_Actual_Crds   	DECIMAL(18,2);
   DEFINE cStatus_Actual_Crds  	CHAR(60);
   DEFINE dFecha_ProxPago_Crds	DATE;
   DEFINE vexist_reg         SMALLINT;
   DEFINE vflag_siweb        SMALLINT;
   DEFINE vbitacora_dup      SMALLINT;
   DEFINE vmonto             MONEY(14,2);
									        

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      LET Mensaje = error_info;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
	     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      --ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

   
    --SET DEBUG FILE TO "/informix/mahr/principalrefer-"||p_Transacc||".out";     
    --TRACE ON;

   LET wBegin = "N";
   LET vSdoTdc_Crds 	= 0;
   LET dFechaCreds		= DATE(1);
   LET cNum_Credisol 	= '';
   LET dCap_Credisol 	= 0;   
   LET dMntoPagoCredis	= 0;
   
   LET cNumCredito_Crds		= '';
   LET cCta_Eje_Crds        = '';
   LET cProducto_Crds       = '';
   LET cNum_Cte_Crds        = '';
   LET cNom_Cte_Crds        = '';
   LET dPago_Efec_Crds      = 0;
   LET dPago_Cta_Crds       = 0;
   LET dMonto_Op_Crds     	= 0;
   LET dSaldo_Actual_Crds   = 0;
   LET cStatus_Actual_Crds  = '';
   LET dFecha_ProxPago_Crds	= DATE(1);
   LET vexist_reg          = 0;
   LET vflag_siweb         = 0;
   LET vbitacora_dup       = 0;
   LET vmonto       = 0;

   BEGIN WORK;

   LET CodRet = "00000";
   LET vCodRet = "000";
   LET v_NumCredito = "";
   LET vfecha_hoy = "";
   LET g_Seguro =0;
   
   SELECT descripcion
     INTO Mensaje
     FROM bdinteg:"informix".si_codret
    WHERE sistema = g_sistema
      AND codigo_retorno = SUBSTR(CodRet,2,3);
	  
   SELECT fecha_hoy INTO vfecha_hoy FROM "informix".sd_fechas;

   LET p_Empresa     = p_Empresa;
   LET g_Remanente   = 0;
   LET g_IntMoraCob  = 0;
   LET g_IntVencCob  = 0;
   LET g_CapVencCob  = 0;
   LET g_IntVigCob   = 0;
   LET g_CapVigCob   = 0;
   LET g_Impuesto    = 0;
   LET g_Comision    = 0;
   LET g_Seguro      = 0;   
   LET nRows         = 0;
   
   --//validacion piloto SIWEB
    SELECT nvl(flag_piloto,0)
    INTO vflag_siweb
    FROM bdinteg:si_sucursales_web
    WHERE sucursal = p_Sucursal;

    IF vflag_siweb <> 0 THEN
        --//validar registro existente
        SELECT {+index(mov2)} 
		       count(*)
        INTO vexist_reg
        FROM sd_movdia
        WHERE empresa = p_Empresa AND folio_suc = p_Folio AND sucursal = p_Sucursal AND usuario = p_Usuario AND 
              transacc_suc = p_Transacc AND nro_tarjeta = p_Tarjeta AND monto = (p_MontoSBC + p_MontoEfe);
        
        IF vexist_reg > 0 THEN
            --//parametro bitacora TX duplicadas
	        SELECT nvl(valor,0)
	        INTO vbitacora_dup
	        FROM bdinteg:si_param  
	        WHERE cod_param = 515;	        
	        
	        IF vbitacora_dup <> 0 THEN
                LET vmonto = p_MontoSBC + p_MontoEfe;
	            insert into bitacora_dup values 
				(p_Folio,p_Sucursal,p_Usuario,p_Transacc,"","",p_Tarjeta,vmonto,current, current hour to fraction(3));
	        END IF
	        
	        RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
	        
	    END IF
    END IF
   
   --**Se selecciona el producto
   IF length(p_NumCredito) = 16 THEN
      LET p_Tarjeta = p_NumCredito;

      SELECT num_credito 
        INTO v_NumCredito
        FROM "informix".sd_tarjeta
       WHERE num_tarjeta = p_NumCredito
         AND empresa     = p_Empresa; 
   ELSE
      LET v_NumCredito = p_NumCredito;
   END IF

   --Pago de TDC por Efectivo
    IF p_MontoEfe < 1 and p_Transacc = '0600' THEN
		if p_MontoEfe > 0 THEN 
			LET CodRet = '00399';
		ELSE
			LET CodRet = '00284';
		END IF;
    ELSE
      if p_MontoEfe > 0 then
            CALL "informix".Principal(
                p_Empresa,
                v_NumCredito,
                p_TpPago,
                p_MontoEfe,
                p_Usuario,
                p_Sucursal,
                p_Folio,
                p_Transacc
            )
            returning CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
                   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
			
			LET CodRet = '00'|| CodRet;

            IF (CodRet::SMALLINT <> 0) THEN
                SELECT descripcion
                INTO   Mensaje
                FROM   bdinteg:"informix".si_codret
                WHERE  sistema        = "06"
                AND    codigo_retorno = SUBSTR(CodRet,2,3);				
                ROLLBACK WORK;
                IF (wBegin = "S") THEN
                   BEGIN WORK;
                END IF;
            ELSE
				if ( p_Transacc = '8324') then  --Se graba clave de rastreo para movimientos de credito SPEI
                    UPDATE "informix".sd_movdia
                       SET referencia = p_referencia
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                elif ( p_Transacc = '6246') then  -- Graba referencia saldo buen cobro            
                    UPDATE "informix".sd_movdia
                       SET referencia23 = p_referencia,
                           nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                else
                    UPDATE "informix".sd_movdia
                       SET nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                end if;
				
				-- Pago de TDC termina correctamente. Realiza el cobro del saldo a favor si existe un PFSI activo (Sdo Inmediato - Apoyo 2020)
				SELECT sdo_cap_insoluto INTO vSdoTdc_Crds FROM bdicred:"informix".sd_maesdos WHERE empresa = p_Empresa AND num_credito = v_NumCredito;
				
				--IF vSdoTdc_Crds < -1 AND p_Transacc = '0600' THEN -- Solo entre cuando venga de pago tdc
				IF vSdoTdc_Crds < -1 THEN -- Solo entre cuando venga de pago tdc

					SELECT count(num_credito) INTO nRows FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
					IF nRows > 0 THEN	-- Existe credisolucion vigente relacionado a la TDC
				  
						SELECT max(fecha) INTO dFechaCreds FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
						SELECT num_sol_prestamo INTO cNum_Credisol FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND fecha = dFechaCreds AND tipo_contrato = '3' AND status = 2;
						SELECT nvl(sdo_cap_insoluto,0) INTO dCap_Credisol FROM bdicred:sd_maesdoscrd WHERE num_credito = cNum_Credisol;
						
						IF dCap_Credisol > 1 THEN	-- Aun se tiene deuda del credito 6900 y no vuelva a entrar en la 2da ejecucion del principalrefer 	
							IF abs(vSdoTdc_Crds) < dCap_Credisol THEN	-- El saldo excedente es menor que el monto de la deuda total del credito 6900. El excedente solo cubre parte del monto de deuda 6900
								LET dMntoPagoCredis = abs(vSdoTdc_Crds);
							ELSE										-- Parte del excedente cubre la deuda total del credito 6900
								LET dMntoPagoCredis = dCap_Credisol;
							END IF;
							
							-- Elimina el pago previo para casos iterativos y asi no sume el monto de ambos pagos a cargar a la tdc.
							SELECT count(folio) INTO nRows FROM bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
							IF nRows > 0 THEN
								DELETE bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
								LET nRows = 0;
							END IF;

							--EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '618')
							BEGIN WORK;
							EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '8654')
							   INTO CodRet, Mensaje, cNumCredito_Crds, cCta_Eje_Crds, cProducto_Crds, cNum_Cte_Crds, cNom_Cte_Crds, dPago_Efec_Crds, dPago_Cta_Crds, 
									  dMonto_Op_Crds, dSaldo_Actual_Crds, cStatus_Actual_Crds, dFecha_ProxPago_Crds;
							IF CodRet::SMALLINT = 0 THEN
								-- Se actualiza remanente
								LET g_Remanente = g_Remanente;
								LET CodRet = "00000";
							END IF;										
							
						END IF;
					END IF;  
					LET nRows = 0;
				END IF;    
				
           END IF
      END IF
	END IF;
/*
--jom ini
   else
	if p_MontoEfe > 0 THEN 
	        let CodRet = '399';
	ELSE
		let CodRet = '284';
	end if;
--jom fin
   END IF;
*/
   --Pago de TDC por Cheque
   IF p_MontoSBC > 0 THEN
   	--realiza la grabacion del Movimiento

      SELECT num_producto
        INTO g_NumProducto
        FROM "informix".sd_maecred
       WHERE empresa     = p_Empresa
         AND num_credito = v_NumCredito
		 AND status_cred      not in ('CV','FC','FF','FI')	
         AND (id_unidad_prod is null or id_unidad_prod <> 1);
		      
	 --2012-09-18 se valida que el credino no este marcado para venta en pago SBC.
	LET nrows = dbinfo("sqlca.sqlerrd2");
   IF (nrows = 0) THEN   
       LET CodRet = "00008";     
    ELSE
	
		CALL "informix".Genmovref(
		p_Empresa,
		v_NumCredito,
		g_NumProducto,
		p_MontoSBC,
		p_Folio ,
		p_Sucursal,
        p_Tarjeta,
		p_referencia)

		RETURNing CodRet;
		
    END IF;          	
	
    IF (LENGTH(CodRet) = 3) THEN  
		LET CodRet = '00'|| CodRet;
	END IF
	
  	IF (CodRet::SMALLINT <> 0) THEN
   	    SELECT descripcion
            INTO   Mensaje
       	    FROM   bdinteg:"informix".si_codret
       	    WHERE  sistema        = "06"
             AND   codigo_retorno = SUBSTR(CodRet,2,3);
       	     ROLLBACK WORK;
       	     IF (wBegin = "S") THEN
                 BEGIN WORK;
       	     END IF;
        END IF
   END IF;

   RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
END PROCEDURE;