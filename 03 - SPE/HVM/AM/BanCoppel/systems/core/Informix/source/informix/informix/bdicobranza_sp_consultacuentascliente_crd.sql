CREATE PROCEDURE "informix".sp_consultacuentascliente_crd(
                                            pEmpresa CHAR (3),
                                            pTipoBusqueda CHAR(1),  -- 1= por num cliente, 2= por num credito
                                            pNumero CHAR (20),
                                            pIndice CHAR (3),
                                            pFecha DATE
                                            )

RETURNING
			CHAR(5)  AS retorno,
            CHAR(20) AS numero_Cte, 
            CHAR(26) AS ApellidoPat,
            CHAR(26) AS ApellidoMat, 
            CHAR(26) AS Nombre1, 
            CHAR(26) AS Nombre2, 
            CHAR(20) AS NumeroRefer, 
            CHAR(13) AS NumeroTel, 
            CHAR(20) AS NumeroCred, 
            CHAR(40) AS DescripCred, 
            CHAR(30) AS SituacEspec,
            CHAR(30) AS Causa,
            CHAR(30) AS SaldoAct,
            CHAR(30) AS TipoConve,
            CHAR(30) AS NumDiasVencid, 
            CHAR(30) AS NunPagosVencid, 
            CHAR(30) AS PagoMinimVencid,
			CHAR(1) AS EstatTarj, 
		    DECIMAL(18,2) AS TotalLiquidar,
            CHAR(30) AS ProxPagoVencer, 
            CHAR(30) AS FechaUltAbono, 
            CHAR(30) AS ImportUltimAbono, 
            CHAR(30) AS FechaUltiConven, 
            CHAR(30) AS ImportConvenio, 
            CHAR(3) AS CumplioConvenio, 
            CHAR(3) AS OrigenConvenio, 
            DECIMAL(14,2) AS MontoMinimNegociar; 


DEFINE cCodretn CHAR(5);DEFINE cNumcte CHAR(20);
DEFINE cApaterno CHAR (26);
DEFINE cAmaterno CHAR (26);
DEFINE cNombre1 CHAR (26);
DEFINE cNombre2 CHAR (26);
DEFINE cNumcteref CHAR(20);
DEFINE cTelefono CHAR(13);
DEFINE cNumcredito CHAR (20);
DEFINE cDescripcioncred CHAR(40);
DEFINE cSituacionespecial CHAR(30);
DEFINE cCausa CHAR(30);
DEFINE dSaldoactual DECIMAL (16,2);
DEFINE cTipoconvenio CHAR (30);
DEFINE cNumdiasvencidos CHAR(30);
DEFINE cNumpagovencidos CHAR(30);
DEFINE cPagominvencido CHAR(30);
DEFINE cProxpagoporvencer CHAR(30);
DEFINE cFechaultabono CHAR(30);
DEFINE cImporteultabono CHAR(30);
DEFINE cFechaultconvenio DATE;
DEFINE dImporteconvenio DECIMAL(14);
DEFINE cCumplioconvenio CHAR(3);
DEFINE sOrigenconvenio smallint;

DEFINE iSqlerr INTEGER;
DEFINE iIsamerr INTEGER;

DEFINE iIndice INTEGER;
DEFINE cNum_producto CHAR (4);
DEFINE cFechaeimporteultabono CHAR(125);
DEFINE cCodretvalidavencidos CHAR (6);
DEFINE cActivo CHAR (6);
DEFINE cSucursal CHAR (4);
DEFINE dPorcIva DECIMAL (14);
DEFINE dIntMora DECIMAL(14);
DEFINE dIvaIntMora DECIMAL(14);
DEFINE dIvacredito DECIMAL(14);
DEFINE dInteresmes DECIMAL(14);
DEFINE dIvames DECIMAL(14);
DEFINE dSdoDisponible DECIMAL(14);
DEFINE dPagoMin DECIMAL(14);
DEFINE dFechaCorte DATE;
DEFINE dFechaPago DATE;
DEFINE dDisponible DECIMAL(14);
DEFINE dSdoRetenido DECIMAL(14);
DEFINE cStatuscred CHAR (4);
DEFINE mMSumaAbono MONEY(18,2);
DEFINE cStatus_tar CHAR(1);


DEFINE cCodRet  				CHAR(6);
DEFINE dMtoNegociar 			DECIMAL(14,2);
DEFINE cCod_ret                 CHAR(6);
DEFINE cMensaje                 CHAR(80); 
DEFINE cNumCred                 CHAR(20);
DEFINE cTipCred                 CHAR(2);
DEFINE dtFecha_origen           DATE;
DEFINE dtfecha_prox_pago        DATE;
DEFINE dPago_minimo             DECIMAL(18,2);       
DEFINE dtFecha_ult_pago         DATE;
DEFINE iPlazo                   INTEGER;
DEFINE iPagos_realizados        INTEGER;
DEFINE dLinea_otorgada          DECIMAL(18,2);
DEFINE dTasa_interes            DECIMAL(9,6);
DEFINE dTasa_mora               DECIMAL(9,6);
DEFINE dMonto_sbc               DECIMAL(14,2);
DEFINE dCap_vig                 DECIMAL(18,2);  
DEFINE dCap_trans               DECIMAL(18,2);
DEFINE dCap_vdo_exig            DECIMAL(18,2);
DEFINE dCap_vdo_no_exig         DECIMAL(18,2);
DEFINE dSdo_act_total_cap       DECIMAL(18,2);
DEFINE dInt_vig                 DECIMAL(18,2);
DEFINE dInt_vdo                 DECIMAL(18,2);
DEFINE dInt_moratorios          DECIMAL(18,2);
DEFINE dInt_mes                 DECIMAL(18,2);
DEFINE dSdo_act_total_int       DECIMAL(18,2);
DEFINE dIva_int_vig             DECIMAL(18,2);
DEFINE dIva_int_vdo             DECIMAL(18,2);
DEFINE dIva_int_moratorios      DECIMAL(18,2);
DEFINE dIva_int_mes             DECIMAL(18,2);
DEFINE dSdo_act_total_iva       DECIMAL(18,2);
DEFINE dCom_pend                DECIMAL(18,2);
DEFINE dIva_com                 DECIMAL(18,2);
DEFINE dSdo_retenido            DECIMAL(18,2);
DEFINE dTotal_liquidacion       DECIMAL(18,2);
DEFINE dInt_devengado           DECIMAL(18,2);
DEFINE dIva_int_devengado       DECIMAL(18,2);
DEFINE dLinea_disponible        DECIMAL(18,2);
DEFINE dPagos_vdos              DECIMAL(18,2);   
DEFINE cDesc_status_cred        CHAR(60);
DEFINE iId_bloqueo_cred         INTEGER;
DEFINE cBloqueo_cta             CHAR(60);
DEFINE cId_causa_bloqueo_cred   CHAR(3);
DEFINE cCausa_bloqueo_cta       CHAR(50);
DEFINE cId_sit_esp_cte          CHAR(1);
DEFINE iId_causa_esp_cte        INTEGER;
DEFINE cSit_esp_cte             CHAR(75);
DEFINE cId_sit_esp_cred         CHAR(1);
DEFINE iId_causa_esp_cred       INTEGER;
DEFINE cSit_esp_cred            CHAR(75);


LET cCodretn = "000";
LET cNumcte = "";
LET cApaterno = "";
LET cAmaterno = "";
LET cNombre1 = "";
LET cNombre2 = "";
LET cNumcteref = "";
LET cTelefono = "";
LET cNumcredito = "";
LET cDescripcioncred = "";
LET cSituacionespecial = "";
LET cCausa = "";
LET dSaldoactual = "";
LET cTipoconvenio = "";
LET cNumdiasvencidos = "";
LET cNumpagovencidos = "";
LET cPagominvencido = "";
LET cProxpagoporvencer = "";
LET cFechaultabono = "";
LET cImporteultabono = "";
LET cFechaultconvenio = "";
LET dImporteconvenio = "";
LET cCumplioconvenio = "";
LET sOrigenconvenio = "";

LET iSqlerr = 0;
LET iIsamerr = 0;

LET iIndice = 0;
LET cNum_producto = "";
LET cFechaeimporteultabono = "";
LET cCodretvalidavencidos = "";
LET cActivo = "";
LET cSucursal = "";
LET dPorcIva = 0;
LET dIntMora = 0;
LET dIvaIntMora = 0;
LET dIvacredito = 0;
LET dInteresmes = 0;
LET dIvames = 0;

LET dSdoDisponible = 0;
LET dPagoMin = 0;
LET dFechaCorte = "";
LET dFechaPago = "";
LET dDisponible = 0;
LET dSdoRetenido = 0;
LET cStatuscred = "";
LET cStatus_tar = "";


LET cCodRet         		= "000000";
LET dMtoNegociar    		= 0;
LET cCod_ret                = "000000";
LET cMensaje                = "";
LET cNumCred                = "";
LET cTipCred                = "";
LET dtFecha_origen          = DATE(1);
LET dtfecha_prox_pago       = DATE(1);
LET dPago_minimo            = 0;            
LET dtFecha_ult_pago        = DATE(1);
LET iPlazo                  = 0;
LET iPagos_realizados       = 0;
LET dLinea_otorgada         = 0;
LET dTasa_interes           = 0;
LET dTasa_mora              = 0;
LET dMonto_sbc              = 0;
LET dCap_vig                = 0;
LET dCap_trans              = 0;
LET dCap_vdo_exig           = 0;
LET dCap_vdo_no_exig        = 0;
LET dSdo_act_total_cap      = 0;
LET dInt_vig                = 0;
LET dInt_vdo                = 0;
LET dInt_moratorios         = 0;
LET dInt_mes                = 0;
LET dSdo_act_total_int      = 0;
LET dIva_int_vig            = 0;
LET dIva_int_vdo            = 0;
LET dIva_int_moratorios     = 0;
LET dIva_int_mes            = 0;
LET dSdo_act_total_iva      = 0;
LET dCom_pend               = 0;
LET dIva_com                = 0;
LET dSdo_retenido           = 0;
LET dTotal_liquidacion      = 0;
LET dInt_devengado          = 0;
LET dIva_int_devengado      = 0;
LET dLinea_disponible       = 0;
LET dPagos_vdos             = 0;             
LET cDesc_status_cred       = "";
LET iId_bloqueo_cred        = 0;
LET cBloqueo_cta            = "";
LET cId_causa_bloqueo_cred  = "";
LET cCausa_bloqueo_cta      = "";
LET cId_sit_esp_cte         = "";
LET iId_causa_esp_cte       = 0;
LET cSit_esp_cte            = "";
LET cId_sit_esp_cred        = "";
LET iId_causa_esp_cred      = 0;
LET cSit_esp_cred           = "";


--SET DEBUG FILE TO "/home/sysifx/viridiana/sp_consultacuentascliente.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlerr, iIsamerr
        IF iSqlerr != 0 THEN
            LET cCodretn=iSqlerr;
            --ROLLBACK WORK;
            RETURN cCodretn, cNumcte, cApaterno, cAmaterno, cNombre1, cNombre2, cNumcteref, cTelefono, cNumcredito, cDescripcioncred,
                    cSituacionespecial, cCausa, dSaldoactual, cTipoconvenio,cNumdiasvencidos, cNumpagovencidos, cPagominvencido,cStatus_tar,dTotal_liquidacion,
				    cProxpagoporvencer, cFechaultabono, cImporteultabono,cFechaultconvenio, dImporteconvenio, cCumplioconvenio, sOrigenconvenio,dMtoNegociar;
        END IF;
    END EXCEPTION;

    --checar valores nulos en los parametros
    IF pEmpresa IS NULL OR Trim(pEmpresa) = "" THEN
        LET cCodretn = "001";
        RETURN cCodretn, cNumcte, cApaterno, cAmaterno, cNombre1, cNombre2, cNumcteref, cTelefono, cNumcredito, cDescripcioncred,
                cSituacionespecial, cCausa, dSaldoactual, cTipoconvenio,cNumdiasvencidos, cNumpagovencidos, cPagominvencido,cStatus_tar,dTotal_liquidacion,
				cProxpagoporvencer, cFechaultabono, cImporteultabono,cFechaultconvenio, dImporteconvenio, cCumplioconvenio, sOrigenconvenio,dMtoNegociar;
    END IF;
    IF pTipoBusqueda IS NULL OR Trim(pTipoBusqueda) = "" THEN
        LET cCodretn = "002";
        RETURN cCodretn, cNumcte, cApaterno, cAmaterno, cNombre1, cNombre2, cNumcteref, cTelefono, cNumcredito, cDescripcioncred,
                cSituacionespecial, cCausa, dSaldoactual, cTipoconvenio,cNumdiasvencidos, cNumpagovencidos, cPagominvencido,cStatus_tar,dTotal_liquidacion,
				cProxpagoporvencer, cFechaultabono, cImporteultabono,cFechaultconvenio, dImporteconvenio, cCumplioconvenio, sOrigenconvenio,dMtoNegociar;
    END IF;

    -- Busqueda por numero de cliente
    IF pTipoBusqueda = "1" THEN
        LET cNumcte = pNumero;
        --Existe el cliente?
        IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = cNumcte) THEN

            --buscar nombre completo del cliente y su numero de referencia
            SELECT apell_paterno, apell_materno, nombre1, nombre2, numcte_ref
            INTO cApaterno, cAmaterno, cNombre1, cNombre2, cNumcteref
           FROM bdinteg:"informix".si_cliente
            WHERE empresa = pEmpresa AND numcte = cNumcte;

            --buscar si el cliente tiene alguna situacion especial
            SELECT situacion, causa
            INTO cSituacionespecial, cCausa
            FROM bdisitesp:"informix".se_ctessitespcte
            WHERE empresa = pEmpresa AND numcte = cNumcte;

            --buscar el numero de telefono del cliente
            SELECT telefono
            INTO cTelefono
            FROM bdinteg:"informix".si_telefonos
            WHERE numcte = cNumcte
            AND tipo_tel = 1
            AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos WHERE numcte = cNumcte AND tipo_tel = 1);

            --Ciclar la busqueda de creditos para ese numero de cliente
            FOREACH
                			
				-- Valida si se realiza convenio con la condicion del nuevo campo --VP
						SELECT a.num_credito, a.num_producto
						INTO cNumcredito, cNum_producto
						FROM bdicred:"informix".sd_maecredcrd a,
							 bdicred:"informix".sd_definicion b,
							 bdicred:"informix".sd_maesdoscrd c
						WHERE a.empresa = pEmpresa
							AND a.empresa = b.empresa 
							AND a.numcte= cNumcte
							AND a.num_credito = c.num_credito 
							AND a.status_cred IN ('BA','BT','VP','E1','E2','E3')
							AND (c.monto_vencido + c.mto_venc_trasp) > 0
							AND a.num_producto = b.num_producto
							AND b.realizar_convenio = 'S'
						   --AND b.num_producto IN("6300","6400") 'DSB 08/08/2019
						   
						   --buscar la descripcion del credito
							SELECT nombre_prod
							INTO cDescripcioncred
							FROM bdicred:"informix".sd_definicion
							WHERE empresa = pEmpresa AND num_producto = cNum_producto;
						

                EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa, 
                                                                                cNumcredito)
                  INTO cCod_ret,
                       cMensaje,
                       cNumCred,
                       cTipCred,
                       dtFecha_origen,
                       dtfecha_prox_pago,
                       dPago_minimo,            
                       dtFecha_ult_pago,
                       iPlazo,
                       iPagos_realizados,
                       dLinea_otorgada,
                       dTasa_interes,
                       dTasa_mora,
                       dMonto_sbc,
                       dCap_vig,
                       dCap_trans,
                       dCap_vdo_exig,
                       dCap_vdo_no_exig,
                       dSdo_act_total_cap,
                       dInt_vig,
                       dInt_vdo,
                       dInt_moratorios,
                       dInt_mes,
                       dSdo_act_total_int,
                       dIva_int_vig,
                       dIva_int_vdo,
                       dIva_int_moratorios,
                       dIva_int_mes,
                       dSdo_act_total_iva,
                       dCom_pend,
                       dIva_com,
                       dSdo_retenido,
                       dTotal_liquidacion,
                       dInt_devengado,
                       dIva_int_devengado,
                       dLinea_disponible,
                       dPagos_vdos,             
                       cDesc_status_cred,
                       iId_bloqueo_cred,
                       cBloqueo_cta,
                       cId_causa_bloqueo_cred,
                       cCausa_bloqueo_cta,
                       cId_sit_esp_cte,
                       iId_causa_esp_cte,
                       cSit_esp_cte,
                       cId_sit_esp_cred,
                       iId_causa_esp_cred,
                       cSit_esp_cred;


                       LET dSaldoactual        = dSdo_act_total_cap;
                       LET cNumpagovencidos    = dPagos_vdos;
                       LET cPagominvencido     = dPago_minimo;
                       LET dSdoDisponible       = dLinea_disponible;
                       LET cProxpagoporvencer  = dtfecha_prox_pago;
                       LET cFechaultabono      = dtFecha_ult_pago;                       

                        LET mMSumaAbono = 0;
						
						SELECT {+INDEX(bdicred:"informix".sd_movdia mov3)} NVL(SUM(monto),0)
                        INTO mMSumaAbono FROM bdicred:"informix".sd_movdiacrd
                        WHERE empresa = pEmpresa AND num_credito = cNumcredito 
                        AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
						AND codigo_ref = 1 AND reversado = 'N';

                        IF mMSumaAbono = 0 THEN
                           SELECT {+INDEX(bdicred:"informix".sd_movhiscrd inx_movhis)}NVL(SUM(monto),0) 
                           INTO mMSumaAbono 
                           FROM bdicred:"informix".sd_movhiscrd 
                           WHERE empresa = pEmpresa AND num_credito = cNumcredito 
                             AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
							 AND codigo_ref = 1
                             AND fecha_mov = cFechaultabono 
                             AND reversado = 'N'; 
                        END IF;

                        LET cImporteultabono = mMSumaAbono;

						
                        --buscar numero de dias vencidos y el tipo de convenio
                        EXECUTE PROCEDURE bdicobranza:"informix".sp_validavencidos_bis(pEmpresa, cNumcredito, pFecha)
                        INTO cCodretvalidavencidos, cNumdiasvencidos, cTipoconvenio;

                        --buscar la fecha del ultimo convenio, su importe, si fue cumplido y el origen de dicho convenio
                        IF EXISTS (SELECT keyx FROM bdicobranza:"informix".cb_compac WHERE empresa = pEmpresa AND numcuenta = cNumcredito) THEN
                            SELECT fecha_compac, importe, flag_pago, activo, origen
                            INTO cFechaultconvenio, dImporteconvenio, cCumplioconvenio, cActivo, sOrigenconvenio
                            FROM bdicobranza:"informix".cb_compac
                            WHERE empresa = pEmpresa AND numcuenta = cNumcredito
                            AND keyx = (SELECT MAX(keyx)FROM bdicobranza:"informix".cb_compac WHERE empresa = pEmpresa AND numcuenta = cNumcredito);
                        ELSE
                            IF EXISTS (SELECT keyx FROM bdicobranza:"informix".cb_compac_his WHERE empresa = pEmpresa AND numcuenta = cNumcredito) THEN
                                SELECT FIRST 1 fecha_compac, importe, flag_pago, activo, origen
                                INTO cFechaultconvenio, dImporteconvenio, cCumplioconvenio, cActivo, sOrigenconvenio
                                FROM bdicobranza:"informix".cb_compac_his
                                WHERE empresa = pEmpresa AND numcuenta = cNumcredito
                                AND keyx = (SELECT MAX(keyx)FROM bdicobranza:"informix".cb_compac_his WHERE empresa = pEmpresa AND numcuenta = cNumcredito);
                            ELSE
                                LET cFechaultconvenio = "";
                                LET dImporteconvenio = "";
                                LET cCumplioconvenio = "";
                                LET sOrigenconvenio = "";
                            END IF;
                        END IF;
                        --asignar descripcion para saber el estado del compac
                        IF TRIM(cCumplioconvenio) = '1' THEN
                            LET cCumplioconvenio = 'C';
                        ELSE
                            IF TRIM(cCumplioconvenio) = '0' THEN
                                IF TRIM(cActivo) = '0' THEN
                                    LET cCumplioconvenio = 'NC';
                                ELSE
                                    IF TRIM(cActivo) = '1' THEN
                                    LET cCumplioconvenio = 'P';
                                    ELSE
                                        LET cFechaultconvenio = "";
                                        LET dImporteconvenio = "";
                                        LET cCumplioconvenio = "";
                                        LET sOrigenconvenio = "";
                                    END IF;
                                END IF;
                            ELSE
                                LET cFechaultconvenio = "";
                                LET dImporteconvenio = "";
                                LET cCumplioconvenio = "";
                                LET sOrigenconvenio = "";
                            END IF;
                        END IF;


                        --incrementar el indice del ciclo y checar si debe de continuar
                        LET iIndice = iIndice +1;
                        IF iIndice <= pIndice THEN
                            CONTINUE FOREACH;
                        END IF;

                        EXECUTE PROCEDURE "informix".sp_compac_monto_minimo_convenio_bis(pEmpresa, cNumcredito)
                                     INTO cCodRet, cMensaje,dMtoNegociar;

                        IF cCodRet <> "000000" THEN
                            LET cCodretn = "005";
                        END IF;             

                        RETURN cCodretn, cNumcte, cApaterno, cAmaterno, cNombre1, cNombre2, cNumcteref, cTelefono, cNumcredito, cDescripcioncred,
                                cSituacionespecial, cCausa, dSaldoactual, cTipoconvenio,cNumdiasvencidos, cNumpagovencidos, cPagominvencido,cStatus_tar,dTotal_liquidacion,
								cProxpagoporvencer, cFechaultabono, cImporteultabono,cFechaultconvenio, dImporteconvenio, cCumplioconvenio, sOrigenconvenio,dMtoNegociar WITH RESUME;
            END FOREACH;
       
			ELSE
				LET cCodretn = "003";
					RETURN cCodretn, cNumcte, cApaterno, cAmaterno, cNombre1, cNombre2, cNumcteref, cTelefono, cNumcredito, cDescripcioncred,
							cSituacionespecial, cCausa, dSaldoactual, cTipoconvenio,cNumdiasvencidos, cNumpagovencidos, cPagominvencido,cStatus_tar,dTotal_liquidacion,
							cProxpagoporvencer,cFechaultabono, cImporteultabono,cFechaultconvenio, dImporteconvenio, cCumplioconvenio, sOrigenconvenio,dMtoNegociar;
        END IF;
    ELSE
        --Busqueda por numero de credito
        IF pTipoBusqueda = "2" THEN
            --checar si existe el numero de credito
            IF EXISTS ( SELECT numcte FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito =  pNumero) THEN
                LET cNumcredito = pNumero;
				
             -- buscar el numero de cliente
				SELECT a.numcte, a.num_producto
				INTO cNumcte, cNum_producto
				FROM bdicred:"informix".sd_maecredcrd a, 
					 bdicred:"informix".sd_definicion b,
					 bdicred:"informix".sd_maesdoscrd c
				WHERE a.empresa = pEmpresa
				AND a.num_credito =  cNumcredito
				AND a.empresa = b.empresa 
				AND a.num_credito = c.num_credito 
				AND a.status_cred IN ('BA','BT','VP','E1','E2','E3')
				AND (c.monto_vencido + c.mto_venc_trasp) > 0
				AND  a.num_producto = b.num_producto
				AND	 b.realizar_convenio = 'S';
				--AND  b.num_producto IN("6300","6400"); 'DSB 08/08/2019
				
			 --buscar el numero de telefono del cliente
				SELECT telefono
				INTO cTelefono
				FROM bdinteg:"informix".si_telefonos
				WHERE numcte = cNumcte
				AND 	tipo_tel = 1
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos WHERE numcte = cNumcte AND tipo_tel = 1);
			
                --buscar nombre completo del cliente y su numero de referencia
                SELECT apell_paterno, apell_materno, nombre1, nombre2, numcte_ref
                INTO cApaterno, cAmaterno, cNombre1, cNombre2, cNumcteref
                FROM bdinteg:"informix".si_cliente
                WHERE empresa = pEmpresa AND numcte = cNumcte;

                --buscar si el cliente tiene alguna situacion especial
                SELECT situacion, causa
                INTO cSituacionespecial, cCausa
                FROM bdisitesp:"informix".se_ctessitespcte
                WHERE empresa = pEmpresa AND numcte = cNumcte;

             --buscar la descripcion del credito
                SELECT nombre_prod
				INTO cDescripcioncred
				FROM bdicred:"informix".sd_definicion
                WHERE empresa = pEmpresa AND num_producto = cNum_producto;



                EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(pEmpresa, 
                                                                                cNumcredito)
                  INTO cCod_ret,
                       cMensaje,
                       cNumCred,
                       cTipCred,
                       dtFecha_origen,
                       dtfecha_prox_pago,
                       dPago_minimo,            
                       dtFecha_ult_pago,
                       iPlazo,
                       iPagos_realizados,
                       dLinea_otorgada,
                       dTasa_interes,
                       dTasa_mora,
                       dMonto_sbc,
                       dCap_vig,
                       dCap_trans,
                       dCap_vdo_exig,
                       dCap_vdo_no_exig,
                       dSdo_act_total_cap,
                       dInt_vig,
                       dInt_vdo,
                       dInt_moratorios,
                       dInt_mes,
                       dSdo_act_total_int,
                       dIva_int_vig,
                       dIva_int_vdo,
                       dIva_int_moratorios,
                       dIva_int_mes,
					   
                       dSdo_act_total_iva,
                       dCom_pend,
                       dIva_com,
                       dSdo_retenido,
                       dTotal_liquidacion,
                       dInt_devengado,
                       dIva_int_devengado,
                       dLinea_disponible,
                       dPagos_vdos,             
                       cDesc_status_cred,
                       iId_bloqueo_cred,
                       cBloqueo_cta,
                       cId_causa_bloqueo_cred,
                       cCausa_bloqueo_cta,
                       cId_sit_esp_cte,
                       iId_causa_esp_cte,
                       cSit_esp_cte,
                       cId_sit_esp_cred,
                       iId_causa_esp_cred,
                       cSit_esp_cred;


                       LET dSaldoactual        = dSdo_act_total_cap;
                       LET cNumpagovencidos    = dPagos_vdos;
                       LET cPagominvencido     = dPago_minimo;
                       LET dSdoDisponible       = dLinea_disponible;
                       LET cProxpagoporvencer  = dtfecha_prox_pago;
                       LET cFechaultabono      = dtFecha_ult_pago;
					

                LET mMSumaAbono =0;
				
				SELECT {+INDEX(bdicred:"informix".sd_movdia mov3)} NVL(SUM(monto),0)
                        INTO mMSumaAbono FROM bdicred:"informix".sd_movdiacrd
                        WHERE empresa = pEmpresa AND num_credito = cNumcredito 
                        AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
						AND codigo_ref = 1 AND reversado = 'N';

                        IF mMSumaAbono = 0 THEN
                           SELECT {+INDEX(bdicred:"informix".sd_movhiscrd inx_movhis)}NVL(SUM(monto),0) 
                           INTO mMSumaAbono 
                           FROM bdicred:"informix".sd_movhiscrd 
                           WHERE empresa = pEmpresa AND num_credito = cNumcredito 
                             AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanualcrd)
							 AND codigo_ref = 1
                             AND fecha_mov = cFechaultabono 
                             AND reversado = 'N'; 
                        END IF;

                        LET cImporteultabono = mMSumaAbono;

                --buscar numero de dias vencidos y el tipo de convenio
                EXECUTE PROCEDURE bdicobranza:"informix".sp_validavencidos_bis(pEmpresa, cNumcredito, pFecha)
                INTO cCodretvalidavencidos, cNumdiasvencidos, cTipoconvenio;

                --buscar la fecha del ultimo convenio, su importe, si fue cumplido y el origen de dicho convenio
                IF EXISTS (SELECT keyx FROM bdicobranza:"informix".cb_compac WHERE empresa = pEmpresa AND numcuenta = cNumcredito) THEN
                    SELECT fecha_compac, importe, flag_pago, activo, origen
                    INTO cFechaultconvenio, dImporteconvenio, cCumplioconvenio, cActivo, sOrigenconvenio
                    FROM bdicobranza:"informix".cb_compac
                    WHERE empresa = pEmpresa AND numcuenta = cNumcredito
                    AND keyx = (SELECT MAX(keyx)FROM bdicobranza:"informix".cb_compac WHERE empresa = pEmpresa AND numcuenta = cNumcredito);
                ELSE
                    IF EXISTS (SELECT keyx FROM bdicobranza:"informix".cb_compac_his WHERE empresa = pEmpresa AND numcuenta = cNumcredito) THEN
                        SELECT FIRST 1 fecha_compac, importe, flag_pago, activo, origen
                        INTO cFechaultconvenio, dImporteconvenio, cCumplioconvenio, cActivo, sOrigenconvenio
                        FROM bdicobranza:"informix".cb_compac_his
                        WHERE empresa = pEmpresa AND numcuenta = cNumcredito
                        AND keyx = (SELECT MAX(keyx)FROM bdicobranza:"informix".cb_compac_his WHERE empresa = pEmpresa AND numcuenta = cNumcredito);
                    ELSE
                        LET cFechaultconvenio = "";
                        LET dImporteconvenio = "";
                        LET cCumplioconvenio = "";
                        LET sOrigenconvenio = "";
                    END IF;
                END IF;
                --asignar descripcion para saber el estado del compac
                IF TRIM(cCumplioconvenio) = '1' THEN
                    LET cCumplioconvenio = 'C';
                ELSE
                    IF TRIM(cCumplioconvenio) = '0' THEN
                        IF TRIM(cActivo) = '0' THEN
                            LET cCumplioconvenio = 'NC';
                        ELSE
                            IF TRIM(cActivo) = '1' THEN
                            LET cCumplioconvenio = 'P';
                            ELSE
                                LET cFechaultconvenio = "";
                                LET dImporteconvenio = "";
                                LET cCumplioconvenio = "";
                                LET sOrigenconvenio = "";
                            END IF;
                        END IF;
                    ELSE
                        LET cFechaultconvenio = "";
                        LET dImporteconvenio = "";
                        LET cCumplioconvenio = "";
                        LET sOrigenconvenio = "";
                    END IF;
                END IF;

                        EXECUTE PROCEDURE bdicobranza:"informix".sp_compac_monto_minimo_convenio_bis(pEmpresa, cNumcredito)
                                     INTO cCodRet, cMensaje,dMtoNegociar;

                        IF cCodRet <> "000000" THEN
                            LET cCodretn = "006";
                        END IF;

                RETURN cCodretn, cNumcte, cApaterno, cAmaterno, cNombre1, cNombre2, cNumcteref, cTelefono, cNumcredito, cDescripcioncred,
                        cSituacionespecial, cCausa, dSaldoactual, cTipoconvenio,cNumdiasvencidos, cNumpagovencidos, cPagominvencido,cStatus_tar,dTotal_liquidacion,
						cProxpagoporvencer, cFechaultabono, cImporteultabono,cFechaultconvenio, dImporteconvenio, cCumplioconvenio, sOrigenconvenio,dMtoNegociar;

            ELSE
                LET cCodretn = "004";
                RETURN cCodretn, cNumcte, cApaterno, cAmaterno, cNombre1, cNombre2, cNumcteref, cTelefono, cNumcredito, cDescripcioncred,
                        cSituacionespecial, cCausa, dSaldoactual, cTipoconvenio,cNumdiasvencidos, cNumpagovencidos, cPagominvencido,cStatus_tar,dTotal_liquidacion,
						cProxpagoporvencer,cFechaultabono, cImporteultabono,cFechaultconvenio, dImporteconvenio, cCumplioconvenio, sOrigenconvenio,dMtoNegociar;
            END IF;
        END IF;
    END IF;
END;
END PROCEDURE
DOCUMENT
'Descripción: Consulta la tabla sd_maecredcrd en la consulta principal,se valido que si el credito realizara convenio con el nuevo vampo realiza_convenio',
'para las consultas ya sea por cliente o por numero de credito, al igual que tambien se obtiene el importe del ultimo abono',
'Folio: 1503',
'Base de datos: bdicobranza',
'Fecha: 21-Ago-2015',
'Folio: 587',
'Modifico: 97879606 Adrian Lizarraga',
'Fecha: 08/08/2019',
'DESCRIPCION: Se elimina el numero de producto en la busqueda a la tabla sd_maecredcrd',
'Solicita: PEDRO RICARDO SANCHEZ SANCHEZ',
'Folio: 587',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_ctesvencidosaburo()
       RETURNING CHAR(6), CHAR(80);

DEFINE vCodRet                  CHAR(6);
DEFINE vMensaje                 CHAR(80);
DEFINE SQL_ERR, ISAM_ERR        INTEGER;
DEFINE ERROR_INFO               VARCHAR(80);
DEFINE cNombreProceso           CHAR(30);
DEFINE v_fecha                  DATE;
DEFINE iRegistros               INTEGER;
DEFINE cRuta, cNombre, cNombre2 CHAR(100);
DEFINE iParamRuta, iParamNombre INTEGER;
DEFINE cCadena                  CHAR(2000);
DEFINE v_empresa                CHAR(3);
DEFINE v_numcte, v_cuenta       CHAR(20);

DEFINE v_fecha_desde            DATE;
DEFINE v_fecha_apertura         CHAR(10);
DEFINE v_fecha_ult_actualiza    CHAR(10);
DEFINE v_mto_fin_ven_trasp      INTEGER; 
DEFINE v_situacion              CHAR(1);
DEFINE v_causa, v_cuentatels    SMALLINT;
DEFINE v_fecha_ant              DATE;
DEFINE v_dia, v_mes             CHAR(2);
DEFINE v_anio, cProceso         CHAR(4);
DEFINE vvcCod_ret               CHAR(6);

LET vCodRet          = '11111';
LET vMensaje         = 'PROCESO INICIALIZADO';
LET SQL_ERR          = 0;
LET ISAM_ERR         = 0;
LET ERROR_INFO       = '';
LET cNombreProceso   = 'CTES. VENCIDOS A BURO';
LET v_fecha          = DATE(1);
LET cRuta            = '';
LET cNombre          = '';
LET iParamRuta       = 20;
LET iParamNombre     = 41;
LET iRegistros       = 0;
LET cCadena          = '';
LET v_empresa        = '001';
LET v_numcte         = '';
LET v_cuenta         = '';
LET v_fecha_desde    = '01-01-2010';
LET v_fecha_apertura = '';
LET v_situacion      = 'D';
LET v_causa          = 1;
LET v_cuentatels     = 0;
LET v_fecha_ult_actualiza = '';
LET v_fecha_ant      = DATE(1);
LET v_dia           = '';
LET v_mes           = '';
LET v_anio          = '';
LET cNombre2        = '';
LET cProceso    = '0025';
LET vvcCod_ret  = '';

--SET DEBUG FILE TO "/informix/macf/sp_ctesvencidosaburo.out";    
--TRACE ON; 

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;
    
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, vCodRet, trim(vMensaje), '02')
        RETURNING vvcCod_ret;

        RETURN vCodRet, vMensaje;
    END EXCEPTION;
    
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, vCodRet, vMensaje, '01') RETURNING vvcCod_ret;
    
    SELECT fecha_hoy 
      INTO v_fecha
     FROM bdinteg:si_fechas 
     WHERE empresa = v_empresa;
    
    LET v_fecha_ant = v_fecha - 3 UNITS MONTH;

    -- 1o Depurar la información que exista de 3 meses hacia atrás en la tabla
    begin work; 
        DELETE bdisitesp:se_ctessitespcte_cat WHERE fecha_insert <= v_fecha_ant;
    commit work;
    

    SELECT valor  INTO cRuta
      FROM bdicobranza:cb_param
     WHERE empresa = v_empresa
       AND cod_param = iParamRuta;

    SELECT valor  INTO cNombre2
      FROM bdicobranza:cb_param
     WHERE empresa = v_empresa
       AND cod_param = iParamNombre;

    IF day(v_fecha) < 10 then
    	LET v_dia = '0' || day(v_fecha);
    ELSE
    	LET v_dia = day(v_fecha);
    END IF;
    
    IF month(v_fecha) < 10 then
    	LET v_mes = '0' || month(v_fecha);
    ELSE
    	LET v_mes = month(v_fecha);
    END IF;
    
    LET v_anio = year(v_fecha);

    LET cNombre = trim(SUBSTR(cNombre2,1,LENGTH(cNombre2)) || v_dia || v_mes || v_anio || '.txt');
    --Ejemplo  localizador_Bncpl_22042012.txt
    
  --Inicializar archivo
    SYSTEM 'echo "numcte|num_credito|moras|fecha_apert|contador|fechaultactualiza"' || '> ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || cNombre;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    --SET pdqpriority 20;

  IF NVL(cRuta,'') <> '' and NVL(cNombre, '') <> '' THEN
     FOREACH 
            --Obtener los datos principales de crédito y moratorios a partir de 2010-01-01
            --Modificación para que no se tomen los clientes menores a 3 meses existentes en se_ctessitespcte_cat, solo se deben tomar de 3 meses hacia atrás
            SELECT m.numcte, m.num_credito, a.mto_fin_ven_trasp, to_char(m.fecha_apertura, "%d-%m-%Y")
                INTO v_numcte, v_cuenta, v_mto_fin_ven_trasp, v_fecha_apertura
              FROM bdicred:sd_maecred m, bdicred:sd_maesdos a
             WHERE m.empresa = v_empresa
               AND m.empresa = a.empresa 
               AND a.num_credito = m.num_credito
               AND (m.status_cred IN ('AA', 'BA', 'BT','E1', 'E2', 'E3'))
               AND a.mto_fin_ven_trasp BETWEEN 1 AND 4
               AND m.fecha_apertura >= v_fecha_desde
               AND m.num_credito NOT IN ( SELECT b.num_credito 
                                            FROM bdisitesp:se_ctessitespcte_cat b
                                           WHERE b.fecha_insert > v_fecha_ant )
    
            --OBTENER LA CANTIDAD DE TELEFONOS QUE TIENE REGISTRADOS EL CLIENTE EN cb_telefonos PROVENIENTES DE BURÓ(por ahora, despues será de si_telefonos)  
            SELECT COUNT(*)  INTO v_cuentatels 
              FROM bdicobranza:cb_telefonos
             WHERE numcte = v_numcte
               AND origen = 5;
            
            IF v_cuentatels > 0 THEN 
                --OBTENER LA FECHA DE ULTIMA ACTUALIZACION DE cb_telefonos
                SELECT MAX(to_char(fecha_insert, "%d-%m-%Y"))  INTO v_fecha_ult_actualiza 
                  FROM bdicobranza:cb_telefonos
                 WHERE numcte = v_numcte
                   AND origen = 5; 
                
                IF NVL(v_fecha_ult_actualiza, '') = '' THEN LET v_fecha_ult_actualiza = ' '; END IF; 
              
                 --INSERTAR LOS VALORES EN LA NUEVA TABLA DE SITUACIONES ESPECIALES CAT
                 IF NOT EXISTS(SELECT numcte FROM bdisitesp:se_ctessitespcte_cat WHERE numcte = v_numcte AND num_credito = v_cuenta ) THEN
                     INSERT INTO bdisitesp:se_ctessitespcte_cat (numcte, num_credito, situacion, causa, fecha_insert)
                      VALUES(v_numcte, v_cuenta, v_situacion, v_causa, today);
    	         
                    LET cCadena = 'echo "' || trim(v_numcte) || '|' || trim(v_cuenta) || '|' || v_mto_fin_ven_trasp || '|' || v_fecha_apertura || '|' || v_cuentatels || '|' || v_fecha_ult_actualiza || '">> ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || cNombre;
                    --INSERT INTO bdicobranza:cb_mensajes_trace(nom_variable, descripcion) VALUES('sp_ctesvencidosaburo', trim(cCadena));
                 
                    --Agregar cada registro al archivo
                    --SYSTEM 'echo ' || trim(v_numcte) || '|' || trim(v_cuenta) || '|' || trim(v_mto_fin_ven_trasp) || '|' || v_fecha_apertura || '|' || v_cuentatels || '|' || v_fecha_ult_actualiza || '>> ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || cNombre ;
                    System SUBSTR(cCadena,1,LENGTH(cCadena));         
                    
                    Let iRegistros = iRegistros + 1;
                END IF;
            END IF;
             
      END FOREACH 
      
      LET vMensaje = 'PROCESO FINALIZADO';
      LET vCodRet = '000000';	
      
      CALL bdicobranza:"informix".sp_inserta_bitacora_cob(v_empresa, cProceso, vCodRet, vMensaje, '03')
      RETURNING vvcCod_ret;

  END IF;

		
RETURN vCodRet, vMensaje;
END 
END PROCEDURE
DOCUMENT
'AUTOR: Marco A. Campos',
'Fecha: 2012-02-28 ',
'BDICOBRANZA. Genera un archivo plano con información de clientes de Crédito de 1 a 4 vencidos para el tipo de teléfono 5 (Buró de Crédito)',
'Fecha: 2012-04-23 - Corregir el nombre con el que se genera el archivo.',
'Fecha: 2012-05-03 - Condicionar que se seleccionen los clientes de se_ctessitespcte_cat mayores a 3 meses',
'Fecha: 2012/07/31 - Corregir condición < a <= en DELETE y validar que no exista registro en se_ctessitespcte_cat antes de ins. Autor:MACF',
'2012/08/28 - Cambiar el resultado de salida de 5 a 6 ceros para que empate con el CTRL-M. BY: MACF.';

CREATE PROCEDURE "informix".sp_envio_campana_prev_pzo(pEmpresa CHAR(3))
returning VARCHAR(06),
          VARCHAR(80);

-- EXECUTE PROCEDURE "informix".sp_envio_campana_prev_pzo('001');

DEFINE SQL_ERR					INTEGER;
DEFINE ISAM_ERR					INTEGER;
DEFINE ERROR_INFO				VARCHAR(80);
DEFINE cProceso					CHAR(4);
DEFINE P_COD_RET				VARCHAR(6);
DEFINE P_MENSAJE				VARCHAR(80);
DEFINE cCodRet  				CHAR(6);
DEFINE cMensaje  				CHAR(500);

DEFINE dFecha					DATE;
DEFINE cNumCredito				CHAR(20);
DEFINE cNumcte					CHAR(20);
DEFINE cNumProducto				CHAR(04);
DEFINE v_telcelular				VARCHAR(10);
DEFINE v_fecha_lim_pago			VARCHAR(10);
DEFINE v_prox_fecha_pago		DATE;
DEFINE vconta					INTEGER;
DEFINE vCont_sms				INTEGER;
DEFINE vBandera					CHAR(1);
DEFINE vBandera2				CHAR(1);
DEFINE dFechaInicio				INTEGER;
DEFINE v_cubrio					DECIMAL(18,2);
DEFINE v_capital_debe			DECIMAL(18,2);
DEFINE v_capital_pagado			DECIMAL(18,2);
DEFINE dFech_ini				DATE;

DEFINE iTotalCuentas			INTEGER;
DEFINE iTotalaEnviar			INTEGER;
DEFINE iTotalExcluidas			INTEGER;
DEFINE iTotalExcluidasXestar	INTEGER;
DEFINE iTotalExcluidaXpago		INTEGER;


BEGIN 
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = 'Error al ejecutar el proceso. '||cNumCredito;
     CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, P_COD_RET, P_MENSAJE, '02')
     RETURNING P_COD_RET;
     LET P_COD_RET = SQL_ERR;

     RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--SET DEBUG FILE TO "sp_envio_campana_prev_pzo.out";
--TRACE ON;

LET cProceso            	= '2055';
LET P_COD_RET           	= '000000';
LET cCodRet           		= '000000';
LET P_MENSAJE           	= 'El proceso de ENVIO CAMPANA PREVPP se ejecuto correctamente.';
LET cMensaje				= '';

LET dFecha					= DATE(1);
LET cNumCredito				= '';
LET cNumcte					= '';
LET cNumProducto			= '';
LET v_fecha_lim_pago		= '';
LET v_prox_fecha_pago		= DATE(1);
LET vconta					= 0;
LET vCont_sms				= 0;
LET vBandera				= '';
LET vBandera2				= '';
LET dFechaInicio			= 0;
LET v_cubrio				= 0;
LET v_capital_debe			= 0;
LET v_capital_pagado		= 0;
LET dFech_ini				= DATE(1);

LET iTotalCuentas 			= 0;
LET iTotalaEnviar			= 0;
LET iTotalExcluidas			= 0;
LET iTotalExcluidasXestar	= 0;
LET iTotalExcluidaXpago		= 0;


CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '01')
    RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
   LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
   RETURN P_COD_RET,P_MENSAJE;
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy INTO dFecha FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

IF(DAY(dFecha) >= 1 AND DAY(dFecha) <= 5) THEN
	LET dFechaInicio = 1;
ELIF(DAY(dFecha) >= 6 AND DAY(dFecha) <= 10) THEN
	LET dFechaInicio = 6;
ELIF(DAY(dFecha) >= 11 AND DAY(dFecha) <= 15) THEN
	LET dFechaInicio = 11;
ELIF(DAY(dFecha) >= 16 AND DAY(dFecha) <= 20) THEN
	LET dFechaInicio = 16;
ELIF(DAY(dFecha) >= 21 AND DAY(dFecha) <= 25) THEN
	LET dFechaInicio = 21;
ELIF(DAY(dFecha) >= 26 AND DAY(dFecha) <= 31) THEN
	LET dFechaInicio = 26;
END IF;

SELECT a.num_credito, b.numcte, a.telcelular, a.num_producto, c.prox_fecha_pago
FROM "informix".cb_campana_prev_sms a
INNER JOIN bdicred:"informix".sd_maecredcrd b ON (b.num_credito = a.num_credito AND b.num_producto IN ('6300','7600','7700') AND b.status_cred IN ('AA','E1') AND b.fecha_apertura > dFech_ini)
INNER JOIN bdicred:"informix".sd_maecredanexocrd c ON (c.num_credito = a.num_credito AND c.dia_corte = day(dFechaInicio))
INNER JOIN bdicred:"informix".sd_maesdoscrd d ON (d.num_credito = a.num_credito AND (d.monto_vencido + d.mto_venc_trasp) = 0)
WHERE a.num_producto IN ('6300','7600','7700')
UNION ALL
SELECT a.num_credito, b.numcte, a.telcelular, a.num_producto, c.prox_fecha_pago
FROM "informix".cb_campana_prev a
INNER JOIN bdicred:"informix".sd_maecredcrd b ON (b.num_credito = a.num_credito AND b.num_producto IN ('6300','7600','7700') AND b.status_cred IN ('AA','E1') AND b.fecha_apertura > dFech_ini)
INNER JOIN bdicred:"informix".sd_maecredanexocrd c ON (c.num_credito = a.num_credito AND c.dia_corte = day(dFechaInicio))
INNER JOIN bdicred:"informix".sd_maesdoscrd d ON (d.num_credito = a.num_credito AND (d.monto_vencido + d.mto_venc_trasp) = 0)
WHERE a.num_producto IN ('6300','7600','7700')
INTO TEMP cuentas_sms_pp WITH NO LOG;

CREATE INDEX inx_productos_sms_pp ON cuentas_sms_pp(num_producto) in dbs_movhis_idx3;
CREATE INDEX inx_ctecred_sms_pp ON cuentas_sms_pp(num_credito) in dbs_movhis_idx3;
UPDATE STATISTICS MEDIUM FOR TABLE cuentas_sms_pp;

FOREACH WITH HOLD
	SELECT UNIQUE(num_credito), numcte, telcelular, num_producto, prox_fecha_pago
	INTO cNumCredito, cNumcte, v_telcelular, cNumProducto, v_prox_fecha_pago
	FROM cuentas_sms_pp
	WHERE num_producto IN ('6300','7600','7700')

	LET iTotalCuentas = iTotalCuentas + 1;

	SELECT FIRST 1 '1'
	INTO vBandera
	FROM "informix".cb_campana_prev_sms
	WHERE campana = 'SMS'
	AND procesar = '1'
	AND num_credito = cNumCredito;

	IF vBandera = '1' THEN
		LET	iTotalExcluidasXestar = iTotalExcluidasXestar + 1;
		CONTINUE FOREACH;
	ELSE
		IF(v_telcelular = '') OR (v_telcelular IS NULL) THEN
			LET	iTotalExcluidas = iTotalExcluidas + 1;
			CONTINUE FOREACH;
		ELSE
			SELECT capital_debe, capital_pagado
			INTO v_capital_debe, v_capital_pagado
			FROM bdicred:"informix".sd_amortiza_creditocrd
			WHERE num_credito = cNumCredito
			AND fecha_cuota = dFecha;

			IF (v_capital_debe IS NULL) OR (v_capital_debe = "") THEN LET v_capital_debe = 0; END IF;

			IF (v_capital_pagado IS NULL) OR (v_capital_pagado = "") THEN LET v_capital_pagado = 0; END IF;

			LET v_cubrio = v_capital_debe - v_capital_pagado;

			IF(v_prox_fecha_pago IS NULL) THEN LET v_prox_fecha_pago = DATE(1); END IF;

			LET v_fecha_lim_pago = TO_CHAR(v_prox_fecha_pago,'%d/%m/%Y');

			IF (v_cubrio > 0) THEN
				CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','PP_PAGCOMS',cNumcte,cNumCredito,'','2',
													v_fecha_lim_pago,'','','','',
													'','','','','',
													'',v_telcelular,0,0,0,0,0,'','') RETURNING P_COD_RET;

				IF P_COD_RET != '00000' THEN
					LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
					RETURN P_COD_RET,P_MENSAJE;
				END IF;

				/*CALL "informix".sp_inserta_info_rep_envios (pEmpresa,'SMS',26, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

				IF P_COD_RET != '000000' THEN
					LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
					RETURN P_COD_RET,P_MENSAJE;
				END IF;*/

				LET iTotalaEnviar = iTotalaEnviar + 1;
				
				SELECT COUNT(num_credito)
				INTO vConta
				FROM cuentas_sms_pp
				WHERE num_credito = cNumCredito
				AND num_producto = cNumProducto;
				
				IF (vConta IS NULL) THEN LET vConta = 0; END IF;
				
				IF(vConta > 1) THEN
					SELECT cont_sms
					INTO vCont_sms
					FROM "informix".cb_campana_prev_sms
					WHERE num_credito = cNumCredito
					AND num_producto = cNumProducto;

					IF (vCont_sms IS NULL) THEN LET vCont_sms = 0; END IF;

					IF(vCont_sms > 1) THEN
						LET vCont_sms = 2;
					ELSE
						LET vCont_sms = 1;
					END IF;

					BEGIN WORK;
						UPDATE "informix".cb_campana_prev_sms
							SET numcte = cNumcte,
								cont_sms = vCont_sms
						WHERE num_credito = cNumCredito
						AND num_producto = cNumProducto;
					COMMIT WORK;
				ELSE
					SELECT FIRST 1 '1'
					INTO vBandera2
					FROM "informix".cb_campana_prev_sms
					WHERE num_credito = cNumCredito
					AND num_producto = cNumProducto;

					IF(vBandera2 = '1') THEN
						SELECT cont_sms
						INTO vCont_sms
						FROM "informix".cb_campana_prev_sms
						WHERE num_credito = cNumCredito
						AND num_producto = cNumProducto;

						IF (vCont_sms IS NULL) THEN LET vCont_sms = 0; END IF;

						IF(vCont_sms > 1) THEN
							LET vCont_sms = 2;
						ELSE
							LET vCont_sms = 1;
						END IF;

						BEGIN WORK;
							UPDATE "informix".cb_campana_prev_sms
								SET numcte = cNumcte,
									cont_sms = vCont_sms
							WHERE num_credito = cNumCredito
							AND num_producto = cNumProducto;
						COMMIT WORK;
					ELSE
						SELECT cont_sms
						INTO vCont_sms
						FROM "informix".cb_campana_prev
						WHERE num_credito = cNumCredito
						AND num_producto = cNumProducto;

						IF (vCont_sms IS NULL) THEN LET vCont_sms = 0; END IF;

						IF(vCont_sms > 1) THEN
							LET vCont_sms = 2;
						ELSE
							LET vCont_sms = 1;
						END IF;

						BEGIN WORK;
							UPDATE "informix".cb_campana_prev
								SET numcte = cNumcte,
									cont_sms = vCont_sms
							WHERE num_credito = cNumCredito
							AND num_producto = cNumProducto;
						COMMIT WORK;
					END IF;
				END IF;
			ELSE
				LET	iTotalExcluidaXpago = iTotalExcluidaXpago + 1;
			END IF;
		END IF;
	END IF;

	LET cNumcte, v_telcelular, cNumProducto, cNumCredito, v_fecha_lim_pago, vCont_sms, vBandera, vBandera2 = '', '', '', '', DATE(1), 0, '', '';
	LET v_prox_fecha_pago, v_capital_debe, v_capital_pagado, v_cubrio = DATE(1), 0, 0, 0;
END FOREACH;

DROP TABLE cuentas_sms_pp;

--Genera cifras de control
LET cMensaje = ' ------- Cifras de Control campana PP_PAGCOMS ------- ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

LET cMensaje = '';
LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iTotalCuentas;
LET cMensaje = TRIM(cMensaje)||'   Cuentas a enviar PP_PAGCOMS : ' ||iTotalaEnviar;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
LET cMensaje = 'Cuentas excluidas X CEL NO VALIDO : ' ||iTotalExcluidas;
LET cMensaje = TRIM(cMensaje)||'   Cuentas excluidas X PAGO MINIMO : ' ||iTotalExcluidaXpago;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
LET cMensaje = 'Cuentas excluidas X DOBLE SMS : ' ||iTotalExcluidasXestar;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
--Genera cifras de control

LET cMensaje 				= '';
LET iTotalCuentas 			= 0;
LET iTotalaEnviar			= 0;
LET iTotalExcluidas			= 0;
LET iTotalExcluidaXpago		= 0;
LET iTotalExcluidasXestar	= 0;

-----------------------------------------------------------------
-- Genera envio de la campana PP_PAGCOMS
-----------------------------------------------------------------
FOREACH WITH HOLD
	SELECT b.numcte, a.telcelular, a.num_producto, a.num_credito, a.fecha_lim_pago, a.cont_sms
	INTO cNumcte, v_telcelular, cNumProducto, cNumCredito, v_fecha_lim_pago, vCont_sms
	FROM "informix".cb_campana_prev_sms a
	INNER JOIN bdicred:"informix".sd_maecredcrd b ON (b.num_credito = a.num_credito)
	WHERE a.campana = 'SMS'
	AND a.procesar = '1'
	AND a.num_producto IN ('6300','7600','7700')

	LET iTotalCuentas = iTotalCuentas + 1;

	CALL bdimnsj:"informix".sp_registra_evento('2','COBRA_SMS','PP_PAGCOMS',cNumcte,cNumCredito,'','2',
												v_fecha_lim_pago,'','','','',
												'','','','','',
												'',v_telcelular,0,0,0,0,0,'','') RETURNING P_COD_RET;

	IF P_COD_RET != '00000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_registra_evento. '||cNumCredito;
		RETURN P_COD_RET,P_MENSAJE;
	END IF;

	IF(vCont_sms > 1) THEN
		LET vCont_sms = 2;
	ELSE
		LET vCont_sms = 1;
	END IF;

	BEGIN WORK;
		UPDATE "informix".cb_campana_prev_sms
			SET numcte = cNumcte,
				procesar = '0',
				cont_sms = vCont_sms
		WHERE num_credito = cNumCredito
		AND num_producto = cNumProducto;
	COMMIT WORK;

/*		CALL "informix".sp_inserta_info_rep_envios (pEmpresa,'SMS',26, cNumCredito, cNumcte, cNumProducto, TODAY, '', cStatusSituacion,cMotivoExclusion,dPagoMinimo) returning P_COD_RET;

	IF P_COD_RET != '000000' THEN
		LET P_MENSAJE  = 'Error en el llamado al sp_inserta_info_rep_envios. '||cNumCredito;
		RETURN P_COD_RET,P_MENSAJE;
	END IF;*/

	LET iTotalaEnviar = iTotalaEnviar + 1;

	LET cNumcte, v_telcelular, cNumProducto, cNumCredito, v_fecha_lim_pago, vCont_sms = '', '', '', '', DATE(1), 0;
END FOREACH;

--Genera cifras de control
LET cMensaje = ' ------- Cifras de Control campana PP_PAGCOMS ------- ';
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

LET cMensaje = '';
LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iTotalCuentas;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
LET cMensaje = '';
LET cMensaje = 'Cuentas a enviar PP_PAGCOMS: ' ||iTotalaEnviar;
CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
--Genera cifras de control

LET cMensaje 				= '';
LET iTotalCuentas 			= 0;
LET iTotalaEnviar			= 0;

CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, P_MENSAJE, '03') RETURNING P_COD_RET;

IF P_COD_RET != '000000' THEN
	LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
	RETURN P_COD_RET,P_MENSAJE;
END IF;

END
RETURN cCodRet,P_MENSAJE;
END PROCEDURE;