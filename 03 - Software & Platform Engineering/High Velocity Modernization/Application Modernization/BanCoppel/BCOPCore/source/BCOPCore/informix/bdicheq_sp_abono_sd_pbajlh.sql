CREATE PROCEDURE "informix".sp_abono_sd_pbajlh(pCuenta_eje CHAR(20), pCuenta_sd CHAR(20), pTipoMov CHAR(1), pCanal CHAR(1), pFecOper DATE, 
    pHorOper CHAR(10), pMontoAbono MONEY(14,2))
						
    RETURNING   CHAR (5)    AS pcodRetorno,         --Codigo de retorno
                CHAR(20)    AS pCuentaEje,          --Cuenta eje
                CHAR(20)    AS pCuentaSd,           --Cuenta sobre
                DATE        AS pFechaOpr,           --Fecha de operacion
                CHAR(8)     AS pHoraOpr,            --Hora operacion abono
                MONEY(14,2) AS pMonto,              --Monto operacion abono
                CHAR(10)    AS pFolio,              --Folio unico operacion
                CHAR(18)    AS pNombreSd,           --Nombre
                CHAR(2)     AS pIcono,              --Codigo icono
                CHAR(2)     AS pColor,              --Codigo color
                MONEY(14,2) AS pMontoMeta,          --Monto objetivo
                DATE        AS pFechaMeta,          --Fecha fin
                MONEY(14,2) AS pMontoAcum,          --Monto acumulado
                MONEY(14,2) AS pMontoAhorroAut,     --Monto ahorro automatico
                INTEGER     AS pPeridicidad,        --Opcion de abono automatico
                DATE        AS pFechaAbonoAut,      --Fecha ultimo aobono
                DATE        AS pProxFechaAbonoAut,  --Proxima fecha abono automatico
                INTEGER     AS pEstatus,            --Estatus sobre
                CHAR(2)     AS pCanal;              --Canal operacion sobre
				  
    --CONTROL DE EXCEPCIONES
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    --RETORNO
    DEFINE vCodRet          CHAR(5);
	DEFINE vCuenta_eje	    CHAR(20);
	DEFINE vCuenta_sd	    CHAR(20);
	DEFINE vFecha_oper		DATE;
	DEFINE vHora_oper		CHAR(8);
    DEFINE vMontoAbono      MONEY(14,2);
    DEFINE vFolioOper       CHAR(10);
    DEFINE vNombre_sd       CHAR(18);
    DEFINE vIcono	        CHAR(2);
	DEFINE vColor		    CHAR(2);
    DEFINE vMonto_meta      MONEY(14,2);
	DEFINE vFecha_meta      DATE;
	DEFINE vMonto_acum	    MONEY(14,2);
    DEFINE vMontAboAuto	    MONEY(14,2);
	DEFINE mMtoNvoAuto		MONEY(14,2);
    DEFINE vPeriodicidad    INTEGER;	
	DEFINE vFechUltAbo      DATE;
	DEFINE vProxAboAut      DATE;
	DEFINE vEst_sd		    INTEGER;    
	DEFINE vCanal		    CHAR(2);
    --ADICIONALES
    DEFINE vProducto        SMALLINT;    
	DEFINE vEst_cta         SMALLINT;
    DEFINE vProd            CHAR(4);
    DEFINE vTipMov          INTEGER;
    DEFINE vCanVal          INTEGER;    
    DEFINE vMontoMin        MONEY(14,2);
    DEFINE vMontoRest       MONEY(14,2);
    DEFINE vPeriodo		    INTEGER;
    DEFINE vNumTRa          CHAR(4);
    DEFINE vTipAh           CHAR(2);
    DEFINE vValUpdt         INTEGER;
	DEFINE vValInst         INTEGER;
    DEFINE bInicia          BOOLEAN;
    DEFINE vTransaccion     INTEGER;
    DEFINE vSp_CodRet       CHAR(5);	
    --CONSULTA SALDO DISPONILE
    DEFINE vHora            CHAR(12);
    DEFINE vFolio           CHAR(16);
    DEFINE vEmpresa         CHAR(3);
    DEFINE vSucursal        CHAR(4);
    DEFINE vUsuario         CHAR(8);    
    DEFINE vTranCarsd       CHAR(4);
	--VALIDA SALDO DISPONIBLE
    DEFINE v_ret1           CHAR(5);
    DEFINE v_ret2           CHAR(20);
    DEFINE v_ret3           CHAR(20);
    DEFINE v_ret4           CHAR(26);
    DEFINE v_ret5           CHAR(26);
    DEFINE v_ret6           CHAR(26);
    DEFINE v_ret7           CHAR(26);
    DEFINE v_ret8           CHAR(60);
    DEFINE v_ret9           CHAR(1);
    DEFINE v_ret10          MONEY(14,2);
    DEFINE v_ret11          MONEY(14,2);
    DEFINE v_ret12          MONEY(14,2);
    DEFINE v_ret13          MONEY(14,2);
    DEFINE v_ret14          MONEY(14,2);
    DEFINE v_ret15          CHAR(1);
    DEFINE v_ret16          CHAR(40);
    DEFINE v_ret17          CHAR(40); 
    DEFINE v_ret18          MONEY(14,2);
    DEFINE v_ret19          MONEY(14,2);
    DEFINE v_ret20          MONEY(14,2);
    DEFINE v_ret21          CHAR(8);
    DEFINE v_ret22          DATE;
    DEFINE v_ret23          CHAR(16);
    DEFINE v_ret24          CHAR(18);    
    --RETENCION DE SALDO
    DEFINE vtranret         CHAR(4);
    DEFINE vfechoy          DATE;
    DEFINE vsdodisp         MONEY(14,2);
	DEFINE vmontoret        MONEY(14,2);
	DEFINE cNumCte			CHAR(20);

    --CONTROL DE EXCEPCIONES
    LET vsqlerr         = 0; 
    LET iIsamErr        = 0;
    LET cErrorInfo      = "";   
    LET vErrorInfo      = "INICIO DEL PROCESO";
    --RETORNO
    LET vCodRet         = "00000";
    LET vCuenta_eje     = TRIM(pCuenta_eje);
    LET vCuenta_sd      = TRIM(pCuenta_sd);
    LET vFecha_oper     = pFecOper;
    LET vHora_oper      = TRIM(pHorOper);
    LET vMontoAbono     = NVL(pMontoAbono, 0);
    LET vFolioOper      = "";
    LET vNombre_sd      = " ";
    LET vIcono          = " ";
    LET vColor          = " ";
    LET vMonto_meta     = 0;
    LET vFecha_meta     = " ";
    LET vMonto_acum     = 0.00;
    LET vMontAboAuto    = 0.00;
    LET vPeriodicidad   = 0;
    LET vFechUltAbo     = " ";
    LET vProxAboAut     = " ";
    LET vEst_sd         = 0;
    LET vCanal          = TRIM(pCanal);
    --ADICIONALES
    LET vProducto       = 0;
    LET vEst_cta        = 0;
    LET vProd           = "";
    LET vTipMov         = 0;
    LET vCanVal         = 0;
    LET vMontoMin       = 0.00;
    LET vMontoRest      = 0.00;
    LET vPeriodo        = 0;
    LET vNumTRa         = "";
    LET vTipAh          = "";
    LET vValUpdt        = 0;
    LET vValInst        = 0;
    LET bInicia         = "F";
    LET vTransaccion    = 0;
    LET vSp_CodRet      = '00000';
    --CONSULTA SALDO DISPONILE
    LET vHora           = '';
    LET vFolio          = "";
    LET vEmpresa        = "001";
    LET vSucursal       = " ";
    LET vUsuario        = 'informix';
    LET vTranCarsd      = " ";        
	--VALIDA SALDO DISPONIBLE
    LET v_ret1          = "";
    LET v_ret2          = '';
    LET v_ret3          = '';
    LET v_ret4          ='';
    LET v_ret5          = '';
    LET v_ret6          = '';
    LET v_ret7          = '';
    LET v_ret8          = '';
    LET v_ret9          = '';
    LET v_ret10         = 0 ;
    LET v_ret11         = 0 ;
    LET v_ret12         = 0 ;
    LET v_ret13         = 0 ;
    LET v_ret14         = 0 ;
    LET v_ret15         = " ";
    LET v_ret16         = '';
    LET v_ret17         = "";
    LET v_ret18         = 0 ;
    LET v_ret19         = 0 ;
    LET v_ret20         = 0;
    LET v_ret21         = " ";
    LET v_ret22         = "";
    LET v_ret23         = '';
    LET v_ret24         = "";
    --RETENCION DE SALDO
    LET vtranret        = " ";
    LET vfechoy         = " ";
    LET vsdodisp        = 0;
    LET vmontoret       = 0;
	LET	mMtoNvoAuto 	= 0;
	LET cNumCte			= '';
	
    BEGIN
        ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
            IF  vsqlerr != 0 THEN
                --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_abono_sd.txt";
                --TRACE ON;
                LET vCodRet    = vsqlerr;
                LET vErrorInfo = cErrorInfo;
                LET vCuenta_eje= pCuenta_eje;

                IF bInicia = "T" THEN
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                END IF;

                RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                        vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
            END IF;
        END EXCEPTION;

        ON EXCEPTION IN (-535)
            LET vTransaccion = 1;
        END EXCEPTION WITH resume;
		
        --SET DEBUG FILE TO '/informix/c90186322/trace/sp_abono_sd.txt';
		--TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        --VALORES DE LA CUENTA EJE
		SELECT TRIM(cuenta), sucursal,   producto,  status_cta,num_cte
		INTO   vCuenta_eje,  vSucursal,  vProducto, vEst_cta,cNumCte
		FROM   "informix".sc_maechq
		WHERE  cuenta = pCuenta_eje;


        --SE VALIDA EL ESTATUS DE LA CUENTA EJE
		IF NVL(vEst_cta, 0) <> 1 THEN
			LET vCodRet = '00002'; --Estatus de cuenta eje diferente de activo.
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                    vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

        SELECT COUNT(*)
		INTO   vProd
		FROM   "informix".sc_prodis_sd
		WHERE  producto = vProducto;

		--SE VALIDA QUE EL PRODUCTO ENTRE DENTRO LOS PARTICIPANTES
		IF vProd = "0" THEN
			LET vCodRet = '00003'; --Producto invalido.
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                    vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

        SELECT id
        INTO   vTipMov
        FROM   "informix".sc_tmov_sd
        WHERE  id = pTipoMov;

        --SE VALIDA QUE EL TIPO DE MOVIMIENTO SEA ABONO
        IF NVL(vTipMov, 0) <>  1 THEN
            LET  vCodRet='00013'; --Tipo de movimiento invalido.
            RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                    vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
        END IF;

        --CUANDO EL ABONO SEA DESDE LA APP, ABONO SERA SIEPRE 1 = MANUAL
        SELECT  id
        INTO    vTipAh
        FROM    "informix".sc_tipo_ahor
        WHERE   id = "1";

        SELECT id
        INTO   vCanVal
        FROM   "informix".sc_can_sd
        WHERE  id = pCanal;
        
        --SE VALIDA QUE EL TIPO DE CANAL
        IF NVL(vCanVal, 0) <>  1 THEN
            LET  vCodRet='00014'; --Tipo de canal invalido.
            RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                    vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
        END IF;

        --MONTO MINIMO DE ABONO 
        SELECT NVL(monto, 1)
        INTO   vMontoMin
        FROM   "informix".sc_lim_sd
        WHERE  id = "1";

        --DATOS DEL APARTADO
        SELECT NVL(monto_meta, 0), NVL(monto_acum, 0),  estatus,  nombre_sd,  periodo,monto_ahor_auto
		INTO   vMonto_meta, vMonto_acum,vEst_sd, vNombre_sd, vPeriodo,mMtoNvoAuto
		FROM "informix".sc_mae_sd
		WHERE cuenta_sd = pCuenta_sd
			AND cuenta_eje = pCuenta_eje
			AND estatus = 1;

        --SE VALIDA SI EL APARTADO EXISTE
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET vCodRet = '00010'; --Apartado no existe o tiene un estatus invalido
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                    vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

        LET vMontoRest = NVL((vMonto_meta - vMonto_acum),0);

        --VALIDA EL SALDO DISPONIBLE DE LA CUENTA EJE 
	    EXECUTE PROCEDURE "informix".cons_sdos1("001",pCuenta_eje,'')
            INTO v_ret1,v_ret2,v_ret3,v_ret4,v_ret5,v_ret6,v_ret7,v_ret8,v_ret9,v_ret10,v_ret11,v_ret12,v_ret13,v_ret14,v_ret15,v_ret16,v_ret17,v_ret18,v_ret19,v_ret20,v_ret21,v_ret22,v_ret23,v_ret24;

        --SE VALIDA SALDO DISPONIBLE DE LA CUENTA EJE Y SE VALIDA MONTO MINIMO
        IF (vMontoAbono > v_ret10) OR (vMontoAbono < vMontoMin) THEN
            LET  vCodRet='00009'; --Saldo no disponible para realizar el abono.
            RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                    vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
        END IF;
		
		 --SE VALIDA MONTO MAXIMO DE ABONO
        IF vMontoAbono > vMontoRest THEN
            LET  vCodRet='00025'; --Monto de abono invalido.
            RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                    vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
        END IF;

        -- FOLIO DEL MOVIMIENTO 
	    LET vHora  = CURRENT HOUR TO FRACTION;
        LET vFolio = vUsuario||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];

        --TRANSACCION 0601 EN PARAMETROS
        SELECT valor  
        INTO   vNumTRa
        FROM   "informix".sc_param 
        WHERE  codparam = 'tranabonosd';
        
        --TRANSACCION 0601 EN SC_TRANSACCION
        SELECT numero
        INTO   vTranCarsd
        FROM   bdinteg:"informix".si_transacc
        WHERE  numero = vNumTRa
        AND    sistema = '01';

        IF vTransaccion = 1 THEN 
            COMMIT WORK;            
        END IF;

        BEGIN WORK;
        LET bInicia = "T";

        --SE INVOCA EL PROCESO PARA RETENER EL SALDO        
        CALL "informix".cargo_ref(vEmpresa,            -- empresa
                        vSucursal,          -- sucursal
                        vUsuario,           -- usuario
                        vTranCarsd,         -- transaccion central
                        "0000",             -- transaccion sucursal
                        vFolio,             -- folio
                        vCuenta_eje,        -- cuenta
                        0,                  -- cheque
                        vMontoAbono,        -- monto transaccion
                        "01",               -- divisa
                        "SOBRE DIG RET",    -- referencia
                        " ",                -- no. tarjeta
                        " ")                -- usuario autoriza
        RETURNING  vCodRet, vtranret, vfechoy, vsdodisp, vmontoret;

        --VALIDA FALLO EN LA RETENCION DE LA CUENTA
        IF vCodRet <> "000" THEN
            ROLLBACK WORK;
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;            
            LET bInicia = "F";
            LET vCodRet = '00012'; --Error al liberar el saldo en las tablas maestra o detalle.
            
            RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                    vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
        END IF;
		
		LET vPeriodo = NVL(vPeriodo,0);
		LET mMtoNvoAuto = NVL(mMtoNvoAuto,0);
		
			
		IF vPeriodo > 0 THEN
			LET mMtoNvoAuto = NVL(((vMonto_meta - (vMonto_acum + vMontoAbono))/vPeriodo),0);
			LET vMontoRest = NVL((vMonto_meta - (vMonto_acum + vMontoAbono)),0);		
			--SI FALTA PERIODOS POR COBRAR MENORES O IGUAL A 1 PESO, SE REDUCIRA A UN SOLO PERIODO
			IF vMontoRest <= 1 AND vPeriodo > 1 THEN
				LET mMtoNvoAuto = vMontoRest;
				LET vPeriodo = 1;
			END IF
		END IF;
		

        --SE ACTUALIZA LAS TABLAS DE SOBRES DIGITALES
        UPDATE "informix".sc_mae_sd
        SET monto_acum = monto_acum + vMontoAbono,
            monto_ahor_auto = mMtoNvoAuto,
            fecha_proc = vFecha_oper, -- se quitara si el abono no cuenta como parte del dia del cobro del apartado
			periodo = vPeriodo
        WHERE  cuenta_eje = pCuenta_eje
        AND    cuenta_sd  = pCuenta_sd
        AND    estatus    = 1;

        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vValUpdt = '1';
        END IF;

        --CREA EL FOLIO A RETORNAR
        LET vFolioOper = "SD"|| SUBSTR(vFolio,9,8);

        --INSERTA EL MOVIMIENTO
        INSERT INTO "informix".sc_mov_sd VALUES (vCuenta_eje,vCuenta_sd,vFolioOper,1,1,vFecha_oper,vHora_oper,vMontoAbono,vTipAh);
		
		IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vValInst = '1';
        END IF;

        IF vValUpdt <> "1" OR vValInst <> "1" THEN
            ROLLBACK WORK;
            IF vtransaccion = 1 THEN
                BEGIN WORK;
            END IF;
            LET bInicia = "F";
            LET vCodRet = '00011'; --Error al liberar el saldo en las tablas maestra o detalle.
            
            RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                    vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
        END IF;

        LET bInicia = "F";
        LET vCodRet = "00000";
        COMMIT WORK;
        IF vtransaccion = 1 THEN
            BEGIN WORK;
        END IF;
        
        --NOTIFICACION PUSH
        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX','SD_DEPOP',cNumCte,'','','1',vMontoAbono,'','','',vNombre_sd,'','','','','','','',1,0,0,0,0,'','')
		INTO vSp_CodRet;

        SELECT	cuenta_eje, cuenta_sd, fecha_creacion, hora_creacion, nombre_sd, 
				icono, color, monto_meta, fecha_meta, monto_acum, 
                monto_ahor_auto, periodicidad, ult_fech_abo_auto, prox_fech_abo_auto, 
				estatus, canal
		INTO 	vCuenta_eje, vCuenta_sd, vFecha_oper, vHora_oper, vNombre_sd, 
				vIcono, vColor, vMonto_meta, vFecha_meta, vMonto_acum,
                vMontAboAuto, vPeriodicidad, vFechUltAbo, vProxAboAut, 
				vEst_sd, vCanal
		FROM "informix".sc_mae_sd
		WHERE cuenta_sd = pCuenta_sd
			AND cuenta_eje = pCuenta_eje;
			

        --SE VALIDA SI SE COMPLETO LA META
        IF (vMonto_meta = vMonto_acum AND vMonto_meta >= 1) THEN
            LET vEst_sd     = 3;
            LET vPeriodo    = 0;
            LET vProxAboAut = "";

            UPDATE "informix".sc_mae_sd
            SET estatus = vEst_sd,
                periodo = vPeriodo,
                prox_fech_abo_auto = vProxAboAut
            WHERE  cuenta_eje = pCuenta_eje
            AND    cuenta_sd  = pCuenta_sd;
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX','SD_CUMPP',cNumCte,'','','1','','','','',vNombre_sd,'','','','','','','',1,0,0,0,0,'','') ----NOTIFICACION PUSH
			INTO vSp_CodRet;
        END IF;
	      	  
        RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vMontoAbono,vFolioOper,vNombre_sd,vIcono,vColor,
                vMonto_meta,vFecha_meta,vMonto_acum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
    END; 
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR ESTATUS 3 DE FINALIZADO CUANDO EL APARTADO HA LLEGADO A SU META',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_valida_deposito_ppc(pnumcte CHAR(20), pfolioPres CHAR(20), pTarjeta CHAR(4))
       RETURNING CHAR(5) AS cCodRet, MONEY AS rMonto;

	  
	   
DEFINE cCodRet			CHAR(5); 
DEFINE rMonto			MONEY;
DEFINE iSqlErr          INTEGER; 
DEFINE iMonto           MONEY;
DEFINE cCuenta			CHAR(20);
DEFINE cFoliosuc        CHAR(16);

LET cCodRet = "00000";
LET rMonto = 0;
LET iSqlErr = 0;
LET iMonto = 0;
LET cCuenta = "";
LET cFoliosuc = "";

BEGIN

   ON EXCEPTION SET iSqlErr
        LET cCodRet=iSqlErr;
        RETURN cCodRet, rMonto;
    
    END EXCEPTION;
	
	IF pnumcte ='' THEN
	  LET cCodRet='00001'; -- Parametro de entrada vacio
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT 
		monto_autorizado
		
	INTO 
		iMonto
		
	FROM 
		bdisolic:ss_prestamoscoppel 
	WHERE 
		numcte = pnumcte 
		AND folio_prestamo = pfolioPres 
		AND status_solicitud='P';
	 
	IF iMonto > 0 or iMonto is not null THEN
			SELECT 
				cuenta 
			INTO  
				cCuenta 
			FROM 
				BDICHEQ:sc_tarjeta 
			WHERE 
				numcte = pnumcte 
				AND substr(num_tarjeta,13,4) = pTarjeta 
				AND status_tar = 'A';
	  
		IF cCuenta is not null or cCuenta <> '' THEN
				SELECT 
					FIRST 1 folio_suc 
				INTO 
					cFoliosuc
				FROM 
					bdicheq:sc_movdia 
				WHERE 
					sucursal = '5006' 
					AND cuenta = cCuenta 
					AND monto_tot = iMonto;

	  	END IF
		
		IF NVL(cFoliosuc,'') = '' THEN
			LET cCodRet='00003'; -- NO se encontro el deposito			  
            RETURN cCodRet, rMonto;
			
		ELSE			    
 		    
			LET cCodRet='00000'; -- Si se encontro el deposito
			LET rMonto = iMonto;

        END IF
	ELSE
	 LET cCodRet ='00002'; -- No existe el registro
	END IF;
	RETURN cCodRet, rMonto;
END;
END PROCEDURE
;