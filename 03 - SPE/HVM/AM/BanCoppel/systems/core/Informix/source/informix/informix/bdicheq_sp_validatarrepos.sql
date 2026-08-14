CREATE PROCEDURE "informix".sp_validatarrepos(pTipo CHAR(1), pEmpresa CHAR(3), pNumCta CHAR(20), pNumTar CHAR(20))

-- DATOS A REGRESAR --
RETURNING
CHAR(5),  -- Codigo de Retorno
CHAR(1)   -- Codigo de Retorno Auxiliar

-- DEFINICION DE VARIABLES --
DEFINE iSql_Err INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cCodRetAux CHAR(1);
DEFINE cCliente CHAR(20);
DEFINE iSecuencia INTEGER;
DEFINE cBinTar CHAR(6);

-- INICIALIZACION DE VARIABLES --
LET iSql_Err = 0;
LET cCodRet = '000';
LET cCodRetAux = '0';
LET cBinTar = '0';

BEGIN

        ON EXCEPTION SET iSql_Err
                IF iSql_Err <> 0 THEN
                        LET cCodRet = iSql_Err;
                        RETURN cCodRet, cCodRetAux;
                END IF;
        END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_ValidaTarRepos";
--TRACE ON;

	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;

        IF pTipo = '1' THEN
                FOREACH SELECT max(secuencia), numcte
                        INTO iSecuencia, cCliente
                        FROM bdicheq:sc_tarjeta
                        WHERE empresa = pEmpresa
                        AND cuenta = pNumCta
                        GROUP BY numcte

                        IF pNumTar = (SELECT num_tarjeta FROM bdicheq:sc_tarjeta WHERE cuenta = pNumCta AND numcte = cCliente AND secuencia = iSecuencia) THEN
                                LET cCodRetAux = '1' ;
                        END IF;
                END FOREACH;
        ELSE
		
			 
		--DSB PAY INICIO
		LET cBinTar = SUBSTR(pNumTar,1,6);
		
			IF TRIM(cBinTar) = '514014' THEN
				select numcliente
				INTO cCliente
				from  intercard:"informix".Tarjeta
				where numtarjeta =   pNumTar;
			
				IF dbinfo("sqlca.sqlerrd2") = 1 THEN
					 LET cCodRetAux = '1';
				END IF;
			
			ELSE
		
		--DSB PAY FIN
		
		
                FOREACH SELECT max(secuencia), numcte
                        INTO iSecuencia, cCliente
                        FROM bdicred:sd_tarjeta
                        WHERE empresa = pEmpresa
                        AND num_credito = pNumCta
                        GROUP BY numcte

                        IF pNumTar = (SELECT num_tarjeta FROM bdicred:sd_tarjeta WHERE num_credito = pNumCta AND numcte = cCliente AND secuencia = iSecuencia) THEN
                                LET cCodRetAux = '1';
                        END IF;
                END FOREACH;
				
			END IF;        END IF;
        
        RETURN cCodRet, cCodRetAux;

END;
END PROCEDURE
DOCUMENT
"Valida Tarjetas a Reponer",
"AUTOR: ",
"FECHA: 15/01/2009",
"BD: bdicheq";

CREATE PROCEDURE "informix".sp_validatarrepos_web(pTipo CHAR(1), pEmpresa CHAR(3), pNumCta CHAR(20), pNumTar CHAR(20))

-- DATOS A REGRESAR --
RETURNING
CHAR(5),  -- Codigo de Retorno
CHAR(1)   -- Codigo de Retorno Auxiliar

-- DEFINICION DE VARIABLES --
DEFINE iSql_Err INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cCodRetAux CHAR(1);
DEFINE cCliente CHAR(20);
DEFINE iSecuencia INTEGER;
DEFINE cBinTar CHAR(6);

-- INICIALIZACION DE VARIABLES --
LET iSql_Err = 0;
LET cCodRet = '00000';
LET cCodRetAux = '0';
LET cBinTar = '0';

BEGIN

        ON EXCEPTION SET iSql_Err
                IF iSql_Err <> 0 THEN
                        LET cCodRet = iSql_Err;
                        RETURN cCodRet, cCodRetAux;
                END IF;
        END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_ValidaTarRepos";
--TRACE ON;
	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;

        IF pTipo = '1' THEN
                FOREACH SELECT max(secuencia), numcte
                        INTO iSecuencia, cCliente
                        FROM bdicheq:sc_tarjeta
                        WHERE empresa = pEmpresa
                        AND cuenta = pNumCta
                        GROUP BY numcte

                        IF pNumTar = (SELECT num_tarjeta FROM bdicheq:sc_tarjeta WHERE cuenta = pNumCta AND numcte = cCliente AND secuencia = iSecuencia) THEN
                                LET cCodRetAux = '1' ;
                        END IF;
                END FOREACH;
        ELSE

			--DSB PAY INICIO
			LET cBinTar = SUBSTR(pNumTar,1,6);
		
			IF TRIM(cBinTar) = '514014' THEN
				select numcliente
				INTO cCliente
				from  intercard:"informix".Tarjeta
				where numtarjeta =   pNumTar;
			
				IF dbinfo("sqlca.sqlerrd2") = 1 THEN
					 LET cCodRetAux = '1';
				END IF;
			
			ELSE --DSB PAY FIN
			
				FOREACH SELECT max(secuencia), numcte
						INTO iSecuencia, cCliente
						FROM bdicred:sd_tarjeta
						WHERE empresa = pEmpresa
						AND num_credito = pNumCta
						GROUP BY numcte

						IF pNumTar = (SELECT num_tarjeta FROM bdicred:sd_tarjeta WHERE num_credito = pNumCta AND numcte = cCliente AND secuencia = iSecuencia) THEN
								LET cCodRetAux = '1';
						END IF;
				END FOREACH;
                
			END IF;        END IF;

        RETURN cCodRet, cCodRetAux;

END;
END PROCEDURE
DOCUMENT
"Valida Tarjetas a Reponer",
"AUTOR: ",
"FECHA: 15/01/2009",
"BD: bdicheq";

CREATE PROCEDURE "informix".sp_abono_sd(pCuenta_eje CHAR(20), pCuenta_sd CHAR(20), pTipoMov CHAR(1), pCanal CHAR(1), pFecOper DATE, 
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

CREATE PROCEDURE "informix".sp_calcprifechabo_sd (	pPeriodicidad CHAR (2), 
													pFechCrea DATE,
													pHoraCrea CHAR(8))
	RETURNING CHAR(5), DATE;


    DEFINE vsqlerr          	INTEGER;
    DEFINE iIsamErr         	SMALLINT;
    DEFINE cErrorInfo       	CHAR(80);
	DEFINE vErrorInfo       	CHAR(80);
    DEFINE vCodRet         		CHAR(5);
	
	DEFINE vPrim_abo_auto	DATE;
	DEFINE vDiaSem			INTEGER;
	DEFINE vUlt_dia_mes		DATE;
	DEFINE vPri_dia_mes		DATE;
	DEFINE vDiames			INTEGER;
	DEFINE vAjuste			INTEGER;
	DEFINE vMes				INTEGER;
	
    LET vsqlerr         	    = 0; 
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";   
    LET vErrorInfo              = "INICIO DEL PROCESO";
    LET vCodRet                 = "00000";
	
	LET vPrim_abo_auto			= "";
	LET vDiaSem					= 0;
	LET vUlt_dia_mes			= "";
	LET vPri_dia_mes			= "";
	LET vDiames					= 0;
	LET vAjuste					= 0;
	LET vMes					= 0;
	
	BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF  vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/informix/c90186322/trace/sp_calcprifechabo_sd_err.txt";
				--TRACE ON;
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/c90186322/trace/sp_calcprifechabo_sd.txt";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  

		SELECT pri_dia_mes, ult_dia_mes
		INTO vPri_dia_mes, vUlt_dia_mes
		FROM "informix".sc_fechas;	

		--Valida periodicidad semanal
		IF pPeriodicidad = 1 THEN
			
			SELECT WEEKDAY (pFechCrea) 
			INTO   vDiaSem
			FROM   "informix".sc_fechas;
			
			--Verifica que dia de la semana es
			IF vDiaSem = 1 THEN --LUNES
				--Verifica la hora de alta
				IF (pHoraCrea < "17:50:00") THEN
					LET vPrim_abo_auto = pFechCrea;
				ELSE
					LET vPrim_abo_auto = pFechCrea + 7;
				END IF;
			END IF;
				
			IF vDiaSem = 2 THEN --MARTES
				LET vPrim_abo_auto = pFechCrea + 6;
			END IF;
				
			IF vDiaSem = 3 THEN --MIERCOLES
				LET vPrim_abo_auto = pFechCrea + 5;
			END IF;

			IF vDiaSem = 4 THEN --JUEVES
				LET vPrim_abo_auto = pFechCrea + 4;
			END IF;
			IF vDiaSem = 5 THEN --VIERNES
				LET vPrim_abo_auto = pFechCrea + 3;
			END IF;
			IF vDiaSem = 6 THEN --SABADO
				LET vPrim_abo_auto = pFechCrea + 2;
			END IF;

			IF vDiaSem = 0 THEN --DOMINGO
				LET vPrim_abo_auto = pFechCrea + 1;
			END IF;

			LET vDiames	= DAY(vPrim_abo_auto);
			LET vMes 	= MONTH (vPrim_abo_auto);
			IF (vMes = "1" AND vDiames = "1") OR (vMes = "12" AND vDiames = "25") THEN
				LET vPrim_abo_auto = vPrim_abo_auto + 1;
			END IF;
			
		END IF;

		--Valida periodicidad quincenal
		IF pPeriodicidad = 2 THEN

			--Saca el dÃ­a del mes
			SELECT DAY(pFechCrea) 
			INTO   vDiames
			FROM   "informix".sc_fechas;
			
			SELECT MONTH(pFechCrea) 
			INTO   vMes
			FROM   "informix".sc_fechas;
			
			IF vDiames = 15 THEN
				IF (pHoraCrea > "17:50:00") THEN	
					LET vPrim_abo_auto = pFechCrea + 15;
					IF vMes = 2 THEN
						LET vPrim_abo_auto = vUlt_dia_mes;
					END IF;			
				ELSE
					LET vPrim_abo_auto = pFechCrea;
				END IF;
			END IF;
			
			IF vDiames = 30 THEN
				IF (pHoraCrea < "17:50:00") THEN
					LET vPrim_abo_auto = pFechCrea;
				ELSE
					LET vPrim_abo_auto = vUlt_dia_mes + 15;
				END IF;
			END IF;
			
			IF vDiames < 15 THEN
				LET vAjuste = 15 - vDiames;
				LET vPrim_abo_auto = pFechCrea + vAjuste;
			END IF;
			
			IF vDiames > 15 AND vDiames < 30 THEN
			
				IF vMes = 2 THEN
					IF (pHoraCrea < "17:50:00") THEN
						LET vPrim_abo_auto = vUlt_dia_mes;
					ELSE
						LET vPrim_abo_auto = vUlt_dia_mes + 15;
					END IF;
				ELSE
					LET vAjuste = 30 - vDiames;
					LET vPrim_abo_auto = pFechCrea + vAjuste;
				END IF;
				
			END IF;
			
			IF vDiames = 31 THEN
				LET vPrim_abo_auto = vUlt_dia_mes + 15;
			END IF;			

		END IF;

		--Valida periodicidad Mensual
		IF pPeriodicidad = 3 THEN
			
			--Compara que la fecha recibida sea igual al primer dia del mes
			IF vPri_dia_mes = pFechCrea THEN
			
				IF (pHoraCrea < "17:50:00") THEN
					LET vPrim_abo_auto = vPri_dia_mes;
				ELSE
					LET vPrim_abo_auto = vUlt_dia_mes + 1;
				END IF;

			ELSE
				LET vPrim_abo_auto = vUlt_dia_mes + 1;
			END IF;

			LET vDiames	= DAY(vPrim_abo_auto);
			LET vMes 	= MONTH (vPrim_abo_auto);
			IF (vMes = "1" AND vDiames = "1") THEN
				LET vPrim_abo_auto = vPrim_abo_auto + 1;
			END IF;

		END IF;

		RETURN vCodRet, vPrim_abo_auto;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA CORREGIR EL CALCULO DE PROXIMA FECHA DE ABONO AUTOMATICO LOS DIAS FERIADOS EN LAS PERIODICIDADES SEMANAL Y MENSUAL',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_consmov_sd (	pCuenta_eje CHAR(20), pCuenta_sd CHAR(20))
				
	RETURNING	CHAR(5),--codigo retorno
				CHAR (2),--tipo_movimiento
				DATE,--fecha_oper
				CHAR(8),--hora_oper
				MONEY (14,2),
				CHAR(2); --tipo ahorro

	DEFINE vsqlerr          	INTEGER;
    DEFINE iIsamErr         	SMALLINT;
    DEFINE cErrorInfo       	CHAR(80);
	DEFINE vErrorInfo       	CHAR(80);
    DEFINE vCodRet         		CHAR(5);
	DEFINE vCuenta_eje			CHAR(20);
	DEFINE vProducto			CHAR(4);
	DEFINE vEst_cta				CHAR(1);
	DEFINE vCant_sd				SMALLINT;
	DEFINE vEstatus				INTEGER;	
	DEFINE vMov					SMALLINT;
	DEFINE vTipo_mov			CHAR (2);
	DEFINE vTipAh				CHAR(2);
	DEFINE vFecha_oper			DATE;
	DEFINE vHora_oper			CHAR(8);
	DEFINE vMonto				MONEY (14,2);
	
	
	LET vsqlerr         		= 0; 
    LET iIsamErr         		= 0;
    LET cErrorInfo       		= "";   
   	LET vErrorInfo        		= "INICIO DEL PROCESO";
	LET vCodRet					= "00000";
	LET vCuenta_eje				= '';
	LET vProducto				= '';
	LET vEst_cta				= '';
	LET vCant_sd				= 0;
	LET vEstatus				= 0;
	LET vMov					= 0;
	LET vFecha_oper				= " ";
	LET vHora_oper				= '';
	LET vMonto					= 0.00;
	LET vTipo_mov				= 0;
	LET vTipAh					= '';
	LET pCuenta_sd				= TRIM(NVL(pCuenta_sd,''));
	LET pCuenta_eje            	= TRIM(NVL(pCuenta_eje,''));
	
	BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF  vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consmov_sd.txt";
				--TRACE ON;
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
				LET vCuenta_eje= pCuenta_eje;
				RETURN vCodRet,vTipo_mov,vFecha_oper,vHora_oper,vMonto, vTipAh;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/c90186322/trace/sp_consmov_sd.txt';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SE OPTIENE LOS VALORES DE LA CUENTA EJE	
		SELECT TRIM(cuenta), producto,  status_cta
		INTO   vCuenta_eje,  vProducto, vEst_cta
		FROM   "informix".sc_maechq
		WHERE  cuenta = pCuenta_eje;
		
		LET vCuenta_eje = TRIM(NVL(vCuenta_eje,''));
		LET vProducto = TRIM(NVL(vProducto,''));
		LET vEst_cta = TRIM(NVL(vEst_cta,''));
			
		--SE VALIDA QUE LA CUENTA EJE NO VENGA VACIO O NULO
		IF  vCuenta_eje = '' THEN
			LET  vCodRet='00001';			RETURN vCodRet,vTipo_mov,vFecha_oper,vHora_oper,vMonto, vTipAh;
		END IF;	
			
		--SE VALIDA EL ESTATUS DE LA CUENTA 
		IF  vEst_cta <>  '1' THEN 
			LET vcodret='00002'; --estatus no valido
			RETURN vCodRet,vTipo_mov,vFecha_oper,vHora_oper,vMonto, vTipAh;
		END IF;	
		
		--SE VALIDA QUE EL PRODUCTO DE LA CUENTA EJE SEA VALIDO AL CATALOGO
		IF vProducto NOT IN (SELECT producto FROM sc_prodis_sd) THEN
			LET  vCodRet='00003';			RETURN vCodRet,vTipo_mov,vFecha_oper,vHora_oper,vMonto, vTipAh;
		END IF;
				
		IF NOT EXISTS (SELECT 1 FROM  "informix".sc_mae_sd WHERE cuenta_eje = pCuenta_eje)  THEN
			LET vcodRet='00018'; -- la cuenta no tiene sobres 
			RETURN vCodRet,vTipo_mov,vFecha_oper,vHora_oper,vMonto, vTipAh;
		END IF

				
		--SE VALIDA QUE EL SOBRE SE ENCUENTRA ACTIVO Y FINALIZADO
		IF NOT EXISTS (SELECT 1 FROM  "informix".sc_mae_sd WHERE cuenta_sd = pCuenta_sd AND estatus IN (1,3)) THEN
			LET vCodRet='00010';  --El estatus del apartado es invalido.
			RETURN vCodRet,vTipo_mov,vFecha_oper,vHora_oper,vMonto, vTipAh;
		END IF
				
		--SE VALIDA QUE EL SOBRE SE ENCUENTRA ACTIVO
		IF NOT EXISTS (SELECT 1 FROM  "informix".sc_mov_sd WHERE cuenta_sobre=pCuenta_sd) THEN
			LET vCodRet='00019'; --El sobre no tiene movimientos
			RETURN vCodRet,vTipo_mov,vFecha_oper,vHora_oper,vMonto, vTipAh;
		END IF
		
		FOREACH
			SELECT 
			tipo_movimiento,fecha_operacion,hora_operacion,monto, tipo_ahorro
			INTO
			vTipo_mov,vFecha_oper,vHora_oper,vMonto, vTipAh
			FROM
			 "informix".sc_mov_sd
			WHERE 
			cuenta_sobre=pCuenta_sd
			AND 
			cuenta_eje=pCuenta_eje
			ORDER BY
			fecha_operacion DESC, hora_operacion DESC

			RETURN vCodRet,vTipo_mov,vFecha_oper,vHora_oper,vMonto, vTipAh WITH RESUME;
		END FOREACH;
						
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA CONSULTAR LOS APARTADOS CON ESTATUS 3 DE FINALIZADO',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_crea_sd(pCuenta_eje CHAR(20), pFechCrea DATE, pHoraCrea CHAR(8), pNombre_sd CHAR (18),
	pIcono CHAR(2), pColor CHAR(2), pMonto_meta MONEY (14,2), pFecha_meta DATE, pPeriodo INTEGER, pMontAboAuto MONEY(14,2),
	pPeriodicidad INTEGER, pCanal CHAR(2))
								
	RETURNING CHAR (5),CHAR(20),CHAR(20),DATE,CHAR(8),CHAR(18),CHAR(2),CHAR(2),DATE,
		MONEY (14,2),MONEY (14,2),	MONEY (14,2),INTEGER,DATE,DATE,INTEGER,CHAR(2);			  
	
		
    DEFINE vsqlerr          	INTEGER;
    DEFINE iIsamErr         	SMALLINT;
    DEFINE cErrorInfo       	CHAR(80);
	DEFINE vErrorInfo       	CHAR(80);
    DEFINE vCodRet         		CHAR(5);
	DEFINE vCuenta_eje			CHAR(20);
	DEFINE vFecha_oper			DATE;
	DEFINE vHora_oper			CHAR(8);
	DEFINE vNombre_sd			CHAR(18);
	DEFINE vIcono				CHAR(2);
	DEFINE vColor				CHAR(2);
	DEFINE vMonto_meta			MONEY(14,2);
	DEFINE vFecha_meta			DATE;
	DEFINE vMonto_acum			MONEY(14,2);
	DEFINE vMontAboAuto		    MONEY(14,2);
	DEFINE vPeriodicidad		INTEGER;		
	DEFINE vProducto			CHAR(4);
	DEFINE vEstatus				CHAR(1);
	DEFINE vCuenta_sd			CHAR(20);
	DEFINE vFechUltAbo	        DATE;
	DEFINE vProxAboAut 	        DATE;
	DEFINE iContSobre			INTEGER;
	DEFINE vEst_sd				INTEGER;
	DEFINE vCanal               CHAR(2);
	DEFINE vConSd               INTEGER;
	DEFINE vLonSD               INTEGER;
	DEFINE vdIFerencia          SMALLINT;
	DEFINE vLoncons             INTEGER;
	DEFINE vValiser             INTEGER;
	DEFINE iContProd            INTEGER;
	DEFINE vFechaHoy            DATE;  
	DEFINE iContIcono           INTEGER;
	DEFINE iContColor           INTEGER;
	DEFINE iContPer             INTEGER;
	DEFINE vDiaPer              INTEGER;
	DEFINE vValPer              INTEGER;
	DEFINE vEsPeriVal           INTEGER;
	DEFINE vNotCuenta           CHAR(8);
	DEFINE vNotMonto            CHAR(9);
	DEFINE vSp_CodRet           CHAR(5);
	DEFINE vNumCte              CHAR(20);
	DEFINE vFecha_oper_not      CHAR(10);    
	DEFINE vFecha_meta_not      CHAR(10);
    DEFINE vProxAboAut_not      CHAR(10);
	DEFINE vFecha_proc          DATE;
	DEFINE iContDif             SMALLINT;
	DEFINE cNombCanal			CHAR(20);

	
    LET vsqlerr         	    = 0; 
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";   
    LET vErrorInfo              = "INICIO DEL PROCESO";
    LET vCodRet                 = "00000";
	LET vProducto			    = '';
	LET vEstatus			    = '';
	LET	vFechUltAbo	            = "";
	LET vProxAboAut	            = "";
	LET iContSobre			    = 0;
	LET vEst_sd				    = 1;
    LET vCuenta_sd              = " ";
    LET vMonto_acum             = 0.00;
	LET vConSd                  = 0;
	LET vLonSD                  = 0;
	LET vdIFerencia             = 0;
	LET vLoncons                = 0;
	LET vValiser                = 0; 
	LET iContProd               = 0;
	LET iContIcono              = 0;
	LET iContColor              = 0;
	LET iContPer                = 0;
	LET vDiaPer                 = 0;
	LET vValPer                 = 0;
	LET vEsPeriVal				= 0;
	LET vNotCuenta              = "";
	LET vNotMonto               = "";
	LET vSp_CodRet              = '00000';
	LET vNumCte                 = "";
	LET vFecha_oper_not         = "";
	LET vFecha_meta_not         = "";
	LET vProxAboAut_not         = "";
    LET vFecha_proc             = "";
	LET iContDif 				= 0;
	LET vFecha_oper			    = TRIM(NVL(pFechCrea,''));
	LET vHora_oper			    = TRIM(NVL(pHoraCrea,''));
	LET vNombre_sd              = TRIM(NVL(pNombre_sd,''));
	LET vIcono                  = TRIM(NVL(pIcono,''));
	LET vColor                	= TRIM(NVL(pColor,''));
	LET vMonto_meta             = NVL(pMonto_meta,0.00);
	LET vFecha_meta             = TRIM(NVL(pFecha_meta,'')); 
	LET vMontAboAuto	        = NVL(pMontAboAuto,0.00);
	LET vPeriodicidad           = NVL(pPeriodicidad,0); 
	LET vCanal                  = TRIM(NVL(pCanal,'')); 
	LET pPeriodo				= NVL(pPeriodo,0);
	LET cNombCanal				= '';
	
    BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF  vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/resplogifx/conciliachq/sp_crea_sd.txt";
				--TRACE ON;
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
				LET vCuenta_eje= pCuenta_eje;
				RETURN vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
					vFechUltAbo,vProxAboAut,vEst_sd,vCanal;            
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/informix/c90186322/trace/sp_crea_sd.txt';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  

		--VALORES DE LA CUENTA EJE	
		SELECT TRIM(cuenta), producto,  status_cta, num_cte
		INTO   vCuenta_eje,  vProducto, vEstatus,   vNumCte
		FROM   "informix".sc_maechq
		WHERE  cuenta = pCuenta_eje;
		
		LET vCuenta_eje = TRIM(NVL(vCuenta_eje,''));
		LET vProducto = TRIM(NVL(vProducto,''));
		LET vEstatus = TRIM(NVL(vEstatus,''));
		LET vNumCte = TRIM(NVL(vNumCte,''));
		
		--SE VALIDA QUE LA CUENTA EJE EXISTA
		IF  vCuenta_eje = '' THEN
			LET vCodRet = '00001';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal;            
		END IF;
		
		IF vEstatus <> '1' THEN 
			LET vCodRet = '00002';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal;   
		END IF;
		
		--SE VALIDA QUE EL PRODUCTO ENTRE DENTRO LOS PARTICIPANTES
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_prodis_sd WHERE producto = vProducto) THEN 
			LET vCodRet = '00003';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal;   
		END IF;
		
		--VALIDA QUE EXISTA EL ID DEL ICONO	
		IF  NOT EXISTS (SELECT 1 FROM "informix".sc_ico_sd WHERE id = pIcono) THEN 
			LET vCodRet = '00005';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal;   
		END IF;
		
		--VALIDA QUE EXISTA EL ID DEL COLOR 
		IF   NOT EXISTS (SELECT 1 FROM "informix".sc_col_sd WHERE id = vColor) THEN 
			LET vCodRet = '00006';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal;   
		END IF;
		
		--SE VALIDA QUE EXISTA EL ID DE PERIORICIDAD	
				
		IF  NOT EXISTS(SELECT 1 FROM "informix".sc_peri_sd WHERE id = vPeriodicidad) THEN 
			LET vCodRet = '00007';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal;   
		END IF;
		
		--SE VALIDA LA CANTIDAD DE SOBRES ACTIVOS O FINALIZADOS
		SELECT COUNT(*) 
		INTO   iContSobre
		FROM   "informix".sc_mae_sd
		WHERE  cuenta_eje = vCuenta_eje
		AND    estatus IN ('1','3');
				
		IF iContSobre >= 5 THEN 
			LET vCodRet = '00008';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal;   
		END IF;
		
		
		--SE VALIDA EL MONTO META
		IF  vMonto_meta < 1 OR  vMonto_meta > 10000000 THEN 
			LET vCodRet = '00004';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal;   
		END IF;
		
		--FECHA DEL SISTEMA DE CHEQUES
		SELECT fecha_hoy
		INTO   vFechaHoy
		FROM   "informix".sc_fechas
		WHERE  empresa = "001";
		
		--VALIDA LA FECHA DE LA CREACION 
		
		IF  (vFecha_oper < vFechaHoy) OR (vFecha_meta < vFechaHoy) THEN
			LET vCodRet = '00017';
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
				vFechUltAbo,vProxAboAut,vEst_sd,vCanal;   
		END IF;	
		
		--SE OBTIENE PERIODO SEMANAL
		LET vDiaPer =  vFecha_meta - vFecha_oper;
		IF vPeriodicidad = "1" THEN
            LET vValPer  =  (TRUNC(vDiaPer / 7,0));
			--SE VALIDA QUE SEAN MENOS DE 52 SEMANAS
            IF pPeriodo <= 52 AND vValPer <= 52 THEN
                LET vEsPeriVal = 1;
            END IF;
		END IF;
		
		--SE OBTIENE PERIODO QUINCENAL	
		IF vPeriodicidad = "2" THEN
		    LET vValPer  =  (TRUNC(vDiaPer / 15,0));
			--SE VALIDA QUE SEAN MENOS DE 24 QUINCENAS
            IF pPeriodo <= 24 AND vValPer <= 24 THEN
                LET vEsPeriVal = 1;
            END IF;
		END IF;
		
		--SE OBTIENE PERIODO MENSUAL
		IF vPeriodicidad = "3" THEN
		   LET vValPer  =  (TRUNC(vDiaPer / 30,0));
		   --SE VALIDA QUE SEAN MENOS DE 12 MESES
            IF pPeriodo <= 12 AND vValPer <= 12 THEN
                LET vEsPeriVal = 1;
            END IF;
		END IF;

		--SE VALIDA QUE LA CANTIDAD DE PERIODOS RECIBIDA SEA LA MISMA QUE EL CALCULO
		IF vEsPeriVal = 0 OR NOT (pPeriodo = vValPer OR pPeriodo-1 = vValPer) OR (pPeriodo=0) THEN
			LET vCodRet = '00020'; --NÃºmero de periodos invalidos.
			RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
			vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;
		
		--CONSECUTIVO DEL SOBRE DIGITAL 
		SELECT TRIM(valor) 
		INTO   vConSd
		FROM   "informix".sc_param
		WHERE  codparam = "concsd";
   
		--INCREMENTA EL CONSECUTIVO
		LET vConSd = NVL(vConSd,0) + 1;
  
		--LONGITUD DEL CONSECUTIVO
		SELECT valor 
		INTO   vLoncons
		FROM   "informix".sc_param
		WHERE  codparam = "concsd";
   
		LET vLoncons = (LEN(TRIM(((NVL(vLoncons,0)::INTEGER) + 1)::CHAR(9)))::INTEGER);
		
		--LONGITUD TOTAL DEL IDENTIFICADOR DEL SOBRE (20)
		SELECT valor
		INTO   vLonSD
		FROM   "informix".sc_param
		WHERE  codparam = "logctasd";
   
		--SE CALCULA LOS CEROS A CONSIDERAR  14 - 11 - LA LONGITUD DEL CONSECUTIVO
		LET vdIFerencia = NVL(vLonSD - 11 - vLoncons,0);
   
		--DIFERENCIA = LA CANTIDAD DE CEROS A AGREGAR 
		IF  vdIFerencia > 0 THEN
			FOR iContDif = 1 TO vdIFerencia
			LET vCuenta_sd = TRIM(vCuenta_sd) || "0" ; 
			END FOR;
		END IF;
   
		--CONCATENA LA CUENTA EJE A LOS CEROS 
		LET  vCuenta_sd = TRIM(vCuenta_eje) || vCuenta_sd; 
	   
		--CONCATENA EL CONCECUTIVO DE SOBRE DIGITAL 
		LET  vCuenta_sd = TRIM(vCuenta_sd) || vConSd;
		 
		--EJECUCION CALCULO PRIMER ABONO AUTO
		EXECUTE PROCEDURE "informix".sp_calcprifechabo_sd(pPeriodicidad,pFechCrea,pHoraCrea)
		INTO vCodret, vProxAboAut;
	   
	 
		--CREA EL SOBRE DIGITAL 
		INSERT INTO "informix".sc_mae_sd VALUES (vCuenta_eje,   vCuenta_sd,   vFecha_oper, vHora_oper, 
												vNombre_sd,  vIcono,       vColor,      vFecha_meta,
												pPeriodo,    vMonto_meta,   vMontAboAuto, vMonto_acum,
												vPeriodicidad, vFechUltAbo, vProxAboAut,  vEst_sd, 
												vCanal,vFecha_proc);	
									  
		IF   dbinfo('sqlca.sqlerrd2') > 0 THEN
			LET vValiser = '1';
		END IF;
	
		IF  vValiser = '1' THEN
			UPDATE "informix".sc_param
			SET    valor    = vConSd
			WHERE  empresa = "001" and codparam = "concsd";	
				
			--NOTIFICACION POR MAIL 
			LET vNotCuenta = TRIM(NVL(SUBSTR(vCuenta_eje,8,4),''));
			LET vNotMonto  = vMonto_meta;

			--FECHA OPERACION
			LET vFecha_oper_not = TO_CHAR(vFecha_oper, '%d/%m/%Y');
			--FECHA META													
			LET vFecha_meta_not = TO_CHAR(vFecha_meta, '%d/%m/%Y');
			--PROXIMO ABONO													
			LET vProxAboAut_not = TO_CHAR(vProxAboAut, '%d/%m/%Y'); 
			
			IF vCanal = '1' THEN
				LET cNombCanal = 'App Bancoppel';
			END IF;

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','PORTAL_BPI','SD_CREAM',vNumCte,'','','1',vFecha_oper_not,vNotCuenta,vNotMonto,vFecha_meta_not,vNombre_sd,vProxAboAut_not,cNombCanal,'','','','','',1,0,0,0,0,CURRENT,'') ----NOTIFICACION MAIL
			INTO vSp_CodRet;
			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX','SD_CREAP',vNumCte,'','','1','','','','',vNombre_sd,'','','','','','','',1,0,0,0,0,'','') ----NOTIFICACION PUSH
			INTO vSp_CodRet;
			
		END IF;
		
		RETURN  vCodRet,pCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vFecha_meta,vMonto_meta,vMontAboAuto,vMonto_acum,vPeriodicidad,
			vFechUltAbo,vProxAboAut,vEst_sd,vCanal;  
		
	END; 
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR ESTATUS 3 DE FINALIZADO CUANDO SE CONSULTAN LOS APARTADOS POR CUENTA DE CAPTACION',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_deta_sd ( pcuenta_eje CHAR(20))

RETURNING  CHAR(5),--cod_retorno
		CHAR (20),--cuenta eje
		CHAR (20), --cuenta_sd
		DATE, --fecha_creacion
		CHAR(10),--hora_creacion
		CHAR(50),--nombre_sd
		CHAR(2), --icono
		CHAR(2),--color
		DATE, --fecha_meta
		MONEY(14,2),-- monto meta
		MONEY(14,2), --monto abono auto
		MONEY(14,2), --monto acumu
		INTEGER, --perio
		DATE, --fecha ult abono
		DATE, --prox abo
		INTEGER,--estatus 
		CHAR(2);		   
   	DEFINE vsqlerr          				INTEGER;
    DEFINE iIsamErr         				SMALLINT;
    DEFINE cErrorInfo       				CHAR(80);
	DEFINE vErrorInfo       				CHAR(80);
    DEFINE vCodRet         					CHAR(5);
	DEFINE vCuenta_eje						CHAR(20);
	DEFINE vCta_exis						SMALLINT;
	DEFINE vCant_sd							SMALLINT;
	DEFINE vCuenta_sd						CHAR (20);
	DEFINE vFech_creac						DATE;
	DEFINE vHor_creac						CHAR (8);
	DEFINE vNombre_sd						CHAR (50);
	DEFINE vIcono							CHAR(2);
	DEFINE vColor							CHAR(2);
	DEFINE vFecha_meta						DATE;
	DEFINE vMonto_meta						MONEY(14,2);
	DEFINE vMontAboAuto						MONEY(14,2);
	DEFINE vMonto_acum						MONEY(14,2);
	DEFINE vPeriodicidad					INTEGER;
	DEFINE vFechUltAboAut					DATE;
	DEFINE vProxAboAut						DATE;
	DEFINE vEstatus							INTEGER;
	DEFINE vCanal							CHAR(2);
	DEFINE cProducto						CHAR(4);
	DEFINE cProdVdo							CHAR(4);
	DEFINE cStaCta							CHAR(1);
	DEFINE iPeriodo							INTEGER;
	
    LET vsqlerr         					= 0; 
    LET iIsamErr         					= 0;
    LET cErrorInfo       					= "";   
   	LET vErrorInfo        					= "INICIO DEL PROCESO";
	LET vCodRet								= "00000";
	LET vCuenta_eje							= '';
	LET vCta_exis							= 0; 

	LET vCant_sd							= 0;
	--LET iNsobre
	LET vCuenta_sd							= "";
	LET vFech_creac							= " ";
	LET vHor_creac							= '';
	LET vNombre_sd							= "";
	LET vIcono								= 0;
	LET vColor								= 0;
	LET vFecha_meta							= " ";
	LET vMonto_meta							= 0.00;
	LET vMontAboAuto						= 0.00;
	LET vMonto_acum							= 0.00;
	LET vPeriodicidad						= 0;
	LET vFechUltAboAut						= " ";
	LET vProxAboAut							= " ";
	LET vEstatus							= 0;
	LET vCanal								= 0;
	LET	cProducto							= '';
	LET cProdVdo							= '';
	LET cStaCta								= '';
	LET iPeriodo							= 0;
	
    BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			--SET DEBUG FILE TO '/informix/c90186322/a.err.out';
			--TRACE ON;
			IF  vsqlerr != 0 THEN
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
				LET vCuenta_eje= pCuenta_eje;
				RETURN vCodRet, vCuenta_eje, vCuenta_sd, vFech_creac, vHor_creac, vnombre_sd, vIcono, vColor, vFecha_meta, vMonto_meta, vMontAboAuto,
		  vMonto_acum, vPeriodicidad, vFechUltAboAut,vProxAboAut, vEstatus, vCanal WITH RESUME;	
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/informix/c90186322/trace/sp_deta_sd.txt';
		--TRACE ON;
		
		--SE OPTIENE LOS VALORES DE LA CUENTA EJE	
		SELECT TRIM(cuenta), producto,  status_cta
		INTO   vCuenta_eje,  cProducto, cStaCta
		FROM   "informix".sc_maechq
		WHERE  cuenta = pcuenta_eje;
	
		LET vCuenta_eje = TRIM(NVL(vCuenta_eje,''));
		LET cProducto = TRIM(NVL(cProducto,''));
		LET cStaCta = TRIM(NVL(cStaCta,''));
	
		IF vCuenta_eje = ''THEN
			LET vCodRet='00001'; -- la cuenta no existe dentro de la BD
			RETURN vCodRet, vCuenta_eje, vCuenta_sd, vFech_creac, vHor_creac, vnombre_sd, vIcono, vColor, vFecha_meta, vMonto_meta, vMontAboAuto,
			vMonto_acum, vPeriodicidad, vFechUltAboAut,vProxAboAut, vEstatus, vCanal WITH RESUME;	
		END IF;
		
		IF cStaCta <> '1'THEN
			LET vCodRet='00002'; --estatus no valido
			RETURN vCodRet, vCuenta_eje, vCuenta_sd, vFech_creac, vHor_creac, vnombre_sd, vIcono, vColor, vFecha_meta, vMonto_meta, vMontAboAuto,
			vMonto_acum, vPeriodicidad, vFechUltAboAut,vProxAboAut, vEstatus, vCanal WITH RESUME;	
		END IF;
	
		SELECT producto 
		INTO cProdVdo
		FROM "informix".sc_prodis_sd
		WHERE producto = cProducto;
		
		LET cProdVdo = TRIM(NVL(cProdVdo,''));
				
		IF cProdVdo = '' THEN
			LET vCodRet='00003'; --producto no participante
			RETURN vCodRet, vCuenta_eje, vCuenta_sd, vFech_creac, vHor_creac, vnombre_sd, vIcono, vColor, vFecha_meta, vMonto_meta, vMontAboAuto,
			vMonto_acum, vPeriodicidad, vFechUltAboAut,vProxAboAut, vEstatus, vCanal WITH RESUME;	
		END IF;

		SELECT COUNT(cuenta_eje) 
		INTO vCant_sd
		FROM "informix".sc_mae_sd
		WHERE cuenta_eje=pCuenta_eje
		AND estatus in ("1","3");
		
		LET vCant_sd = NVL(vCant_sd,0);
		
		IF vCant_sd = 0 THEN
			LET vCodRet='00018'; -- la cuenta no tiene sobres
			RETURN vCodRet, vCuenta_eje, vCuenta_sd, vFech_creac, vHor_creac, vnombre_sd, vIcono, vColor, vFecha_meta, vMonto_meta, vMontAboAuto,
			vMonto_acum, vPeriodicidad, vFechUltAboAut,vProxAboAut, vEstatus, vCanal WITH RESUME;	

		END IF;		
							
		FOREACH 
			SELECT
			cuenta_eje, cuenta_sd, fecha_creacion, hora_creacion, nombre_sd, icono, color, fecha_meta, monto_meta, monto_ahor_auto,
			monto_acum, periodicidad, ult_fech_abo_auto, prox_fech_abo_auto,estatus, canal,periodo
			INTO 
			vCuenta_eje, vCuenta_sd, vFech_creac, vHor_creac, vNombre_sd, vIcono, vColor, vFecha_meta, vMonto_meta, vMontAboAuto,
			vMonto_acum, vPeriodicidad, vFechUltAboAut,vProxAboAut, vEstatus, vCanal,iPeriodo
			FROM
			"informix".sc_mae_sd
			WHERE 
			cuenta_eje = pCuenta_eje
			AND estatus in ("1","3")
			ORDER BY
			fecha_creacion DESC, hora_creacion DESC
			
			--NO MOSTRAR FECHA DE PROXIMO PAGO CON APARTADOS FINALIZADOS O ACTIVOS SIN PERIODOS DE COBRO
			If (vEstatus = '3') OR (vEstatus = '1' AND iPeriodo = 0 ) THEN
				LET vProxAboAut = '';
			END IF;

			RETURN vCodRet, vCuenta_eje, vCuenta_sd, vFech_creac, vHor_creac, vnombre_sd, vIcono, vColor, vFecha_meta, vMonto_meta, vMontAboAuto,
			vMonto_acum, vPeriodicidad, vFechUltAboAut,NVL(vProxAboAut,''), vEstatus, vCanal WITH RESUME;	
 
		END FOREACH;

	END; 	   
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA CONSULTAR APARTADOS ACTIVOS O FINALIZADOS POR CUENTA DE CAPTACION',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_edic_sd( pCuenta_eje  CHAR(20), pCuenta_sd CHAR(20), pFechCrea DATE, pHoraCrea CHAR(8), pMonto_meta  MONEY (14,2), 
	pFecha_meta  DATE, pPeriodo  INTEGER, pMontAboAuto MONEY(14,2), pPeriodicidad INTEGER, pCanal CHAR(2))
								
	RETURNING   CHAR(5),--codigo retorno
	            CHAR(20),--cuenta_eje
                CHAR(20),--cuenta_sd
                DATE,--fecha_oper
                CHAR(8),--hora_oper
                CHAR(18),--nombre_sd
                CHAR(2),--icono
                CHAR(2),--color
				CHAR(20),--folio_oper
                DATE,--Fecha_meta
                MONEY (14,2),--monto_meta
                MONEY (14,2),--monto ahorro auto
                MONEY (14,2),--monto_acumulado
                INTEGER,--periodicidad
                DATE,--ult_fech_abono_auto
                DATE,--prox_fecha_abo_auto
                INTEGER,--estatus
                CHAR(2);	
	--CONTROL DE EXCEPCIONES
    DEFINE vsqlerr          	INTEGER;
	DEFINE vPeriodicidad		INTEGER;
	DEFINE vEst_sd				INTEGER;
	DEFINE vPeriodo     		INTEGER;
	DEFINE vDiaPer              INTEGER;
	DEFINE vValPer              INTEGER;
	DEFINE vEsPeriVal           INTEGER;
	DEFINE vEst_sd_ant			INTEGER;
	DEFINE vConPer              INTEGER;


    DEFINE iIsamErr         	SMALLINT;
	DEFINE vProducto			SMALLINT;
	DEFINE vEst_cta				SMALLINT;
	DEFINE vCant_sd				SMALLINT;


    DEFINE cErrorInfo       	CHAR(80);
	DEFINE vErrorInfo       	CHAR(80);
    DEFINE vCodRet         		CHAR(5);
	DEFINE vCuenta_eje			CHAR(20);
	DEFINE vCuenta_sd			CHAR(20);
	DEFINE vHora_oper			CHAR(8);
	DEFINE vNombre_sd			CHAR(18);
	DEFINE vIcono				CHAR(2);
	DEFINE vColor				CHAR(2);
	DEFINE vfolio_oper			CHAR(20);
	DEFINE vCanal               CHAR(2);
	DEFINE vProd                CHAR(4);
	DEFINE vSp_CodRet           CHAR(5);
	DEFINE vIdPlantillaMail		CHAR(12);
	DEFINE vIdPlantillaPush		CHAR(12);
	DEFINE vNumCte              CHAR(20);
	DEFINE vFecha_oper_not      CHAR(10);
	DEFINE vNotCuenta           CHAR(8);
	DEFINE vNotMonto            CHAR(9);
	DEFINE vFecha_meta_not      CHAR(10);
    DEFINE vProxAboAut_not      CHAR(10);

	DEFINE vFecha_meta			DATE;
	DEFINE vFecha_oper			DATE;
	DEFINE vFechUltAbo	        DATE;
	DEFINE vProxAboAut 	        DATE;
	DEFINE vFechaHoy            DATE;

	DEFINE vMonto_meta			MONEY(14,2);
	DEFINE vMontAboAuto		    MONEY(14,2);
	DEFINE vMonto_acum			MONEY(14,2);


	
    LET vsqlerr         	    = 0;
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";
    LET vErrorInfo              = "INICIO DEL PROCESO";
    LET vCodRet                 = "00000";
	LET vCuenta_eje             = TRIM(pCuenta_eje);
	LET vCuenta_sd              = TRIM(pCuenta_sd);
	LET vFecha_oper			    = pFechCrea;
	LET vHora_oper			    = pHoraCrea;
	LET vNombre_sd              = "";
	LET vIcono                  = "";
    LET vColor                  = "";
	LET vfolio_oper				= "";
	LET vFecha_meta             = pFecha_meta;
    LET vMonto_meta             = pMonto_meta;
	LET vMontAboAuto	        = pMontAboAuto;
	LET vMonto_acum             = 0.00;
	LET vPeriodicidad           = pPeriodicidad;
	LET	vFechUltAbo	            = "";
	LET vProxAboAut	            = "";
	LET vEst_sd				    = 1;
	LET vCanal                  = TRIM(pCanal);
	LET vProducto			    = 0;
	LET vEst_cta			    = 0;
	LET vFechaHoy         		= "";
    LET vPeriodo                = pPeriodo;
	LET vDiaPer                 = 0;
	LET vValPer                 = 0;
    LET vEsPeriVal              = 0;
	LET vProd                   = "";
	LET vEst_sd_ant		    	= 1;
	LET vCant_sd			    = 0;
	LET vConPer                 = 0;
	LET vSp_CodRet              = '00000';
	LET vIdPlantillaMail		= "SD_EDICM";
	LET vIdPlantillaPush		= "SD_EDICP";
	LET vNumCte                 = "";
	LET vFecha_oper_not         = "";
	LET vNotCuenta 				= "";
	LET vNotMonto 				= "";
	LET vFecha_meta_not         = "";
	LET vProxAboAut_not         = "";

    BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF  vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/informix/c90186322/trace/sp_edic_sd_err.txt";
				--TRACE ON;
				LET vCodRet    	= vsqlerr;
				LET vErrorInfo 	= cErrorInfo;
				LET vCuenta_eje	= pCuenta_eje;
				RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/informix/c90186322/trace/sp_edic_sd.txt";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALORES DE LA CUENTA EJE
		SELECT TRIM(cuenta), producto,  status_cta, TRIM(num_cte)
		INTO   vCuenta_eje,  vProducto, vEst_cta, 	vNumCte
		FROM   "informix".sc_maechq
		WHERE  cuenta = pCuenta_eje;

		--SE VALIDA QUE LA CUENTA EJE EXISTA
		IF vCuenta_eje IS NULL OR vCuenta_eje = "" THEN
			LET vCodRet = '00001'; --Cuenta eje no existe.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

		--SE VALIDA EL ESTATUS DE LA CUENTA EJE
		IF vEst_cta <> "1" THEN
			LET vCodRet = '00002'; --Estatus de cuenta eje diferente de activo.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

		--SE VALIDA QUE EL PRODUCTO ENTRE DENTRO LOS PARTICIPANTES
		IF NOT EXISTS (SELECT 1  FROM "informix".sc_prodis_sd WHERE producto = vProducto ) THEN
			LET vCodRet = '00003'; --Producto invalido.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

		--SE VALIDA QUE EXISTA EL ID DE PERIORICIDAD
		IF NOT EXISTS (SELECT 1  FROM "informix".sc_peri_sd WHERE id = vPeriodicidad ) THEN
			LET vCodRet = '00007'; --Id de periodicidad invalida.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

		--FECHA DEL SISTEMA DE CHEQUES
		SELECT fecha_hoy
		INTO   vFechaHoy
		FROM   "informix".sc_fechas
		WHERE  empresa = "001";

		--VALIDA LA FECHA DE LA EDICION 
		IF (vFecha_oper < vFechaHoy OR vFecha_meta <= vFechaHoy) THEN
			LET vCodRet='00017'; --Fecha de edicion invalida.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;
		
		--SE OBTIENE PERIODO SEMANAL
		LET vDiaPer =  vFecha_meta - vFecha_oper;
		IF vPeriodicidad = "1" THEN
            LET vValPer  =  (TRUNC(vDiaPer / 7,0));
			--SE VALIDA QUE SEAN MENOS DE 52 SEMANAS
            IF vPeriodo <= 52 AND vValPer <= 52 THEN
                LET vEsPeriVal = 1;
            END IF;
		END IF;
		
		--SE OBTIENE PERIODO QUINCENAL	
		IF vPeriodicidad = "2" THEN
		    LET vValPer  =  (TRUNC(vDiaPer / 15,0));
			--SE VALIDA QUE SEAN MENOS DE 24 QUINCENAS
            IF vPeriodo <= 24 AND vValPer <= 24 THEN
                LET vEsPeriVal = 1;
            END IF;
		END IF;
		
		--SE OBTIENE PERIODO MENSUAL
		IF vPeriodicidad = "3" THEN
		   LET vValPer  =  (TRUNC(vDiaPer / 30,0));
		   --SE VALIDA QUE SEAN MENOS DE 12 MESES
            IF vPeriodo <= 12 AND vValPer <= 12 THEN
                LET vEsPeriVal = 1;
            END IF;
		END IF;

		--SE VALIDA QUE LA CANTIDAD DE PERIODOS RECIBIDA SEA LA MISMA QUE EL CALCULO
		IF vEsPeriVal = 0 OR NOT (vPeriodo = vValPer OR vPeriodo-1 = vValPer) OR (pPeriodo=0) THEN
			LET vCodRet = '00020'; --NÃºmero de periodos invalidos.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

		SELECT monto_acum, estatus, nombre_sd, icono, color , ult_fech_abo_auto
		INTO vMonto_acum, vEst_sd_ant, vNombre_sd,vIcono, vColor , vFechUltAbo 
		FROM "informix".sc_mae_sd
		WHERE cuenta_sd = pCuenta_sd
			AND cuenta_eje = pCuenta_eje
			AND estatus IN (1,3); 

		--SE VALIDA SI EL APARTADO EXISTE
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET vCodRet = '00010'; --Apartado no existe o tiene un estatus invalido
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

		--SE VALIDA EL MONTO MINIMO y MAXIMO DE APERTURA/EDICION
		IF (NVL(vMonto_meta, 0) < vMonto_acum + 1) OR (NVL(vMonto_meta, 0) > 10000000 OR ROUND((vMonto_meta - vMonto_acum) / vPeriodo,2) != pMontAboAuto ) THEN
			LET vCodRet = '00004'; --Monto de meta invalido.
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vfolio_oper,vFecha_meta,vMonto_meta,
				vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal;
		END IF;

		IF NVL(vHora_oper, "") = "" THEN
			LET vHora_oper = TO_CHAR(CURRENT, '%H:%M:%S');
		END IF;

		EXECUTE PROCEDURE "informix".sp_calcprifechabo_sd(vPeriodicidad,vFecha_oper,vHora_oper)
		INTO vCodret, vProxAboAut;

		IF NVL(vMontAboAuto, 0) = 0 THEN
			LET vMontAboAuto = ((vMonto_meta - vMonto_acum)/vPeriodo);
		END IF;

		UPDATE "informix".sc_mae_sd SET 
			fecha_creacion = vFecha_oper,
			hora_creacion = vHora_oper,
			fecha_meta = vFecha_meta,
			periodo = vPeriodo,
			monto_meta = vMonto_meta,
			monto_ahor_auto = vMontAboAuto,
			periodicidad = vPeriodicidad,
			prox_fech_abo_auto = vProxAboAut,
			estatus = 1
		WHERE cuenta_eje = pCuenta_eje AND cuenta_sd = pCuenta_sd;

		IF dbinfo('sqlca.sqlerrd2') > 0 THEN
			IF vEst_sd_ant = "3" THEN
				LET vIdPlantillaMail = "SD_CONTM";
				LET vIdPlantillaPush = "SD_CONTP";
			END IF;
			
			--FECHA OPERACION MAIL
			LET vFecha_oper_not = TO_CHAR(vFecha_oper, '%d/%m/%Y');
			--CUENTA EJE MAIL
			LET vNotCuenta = SUBSTR(vCuenta_eje,8,4);
			--MONTO META MAIL
			LET vNotMonto  = vMonto_meta;
			--FECHA META MAIL
			LET vFecha_meta_not = TO_CHAR(vFecha_meta, '%d/%m/%Y');
			--PROXIMO ABONO	MAIL												
			LET vProxAboAut_not = TO_CHAR(vProxAboAut, '%d/%m/%Y');

			--NOTIFICACION MAIL
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','PORTAL_BPI',vIdPlantillaMail,vNumCte,'','','1',vFecha_oper_not,vNotCuenta,vNotMonto,vFecha_meta_not,vNombre_sd,vProxAboAut_not,'','','','','','',1,0,0,0,0,CURRENT,'')
			INTO vSp_CodRet;

			--NOTIFICACION PUSH
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX',vIdPlantillaPush,vNumCte,'','','1','','','','',vNombre_sd,'','','','','','','',1,0,0,0,0,'','')
			INTO vSp_CodRet;
		END IF;
		
		RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecha_oper,vHora_oper,vNombre_sd,vIcono,vColor,vCuenta_sd,vFecha_meta,vMonto_meta,
			vMontAboAuto,vMonto_acum,vPeriodicidad,vFechUltAbo,vProxAboAut,1,vCanal;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento almacenado para la edicion de apartados en la app movil.',
'AUTOR : 90034397 - Brando D. Garcia Lemus',
'FECHA : 13/01/2023',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_perso_sd(pCuenta_eje	CHAR(20),pCuenta_sd	CHAR(20),pNombre_sd CHAR(18),pIcono CHAR(2),pColor CHAR(2))
							
	RETURNING   CHAR(5), --Codigo retorno
				CHAR(20),--cuenta_eje
				CHAR(20),--cuenta_sd
				CHAR(18),--nombre_sd
				CHAR(2), --icono
				CHAR(2); --color
		   
    DEFINE iIsamErr,vProducto,vEst_sd,vCant_sd SMALLINT;
	
	DEFINE vsqlerr          	INTEGER;
    DEFINE cErrorInfo       	CHAR(80);
	DEFINE vErrorInfo       	CHAR(80);
    DEFINE vCodRet         		CHAR(5);
	DEFINE vCuenta_sd			CHAR(20);
	DEFINE vNombre_sd			CHAR(18);
	DEFINE vNombreT_sd			CHAR(18);
	DEFINE vIcono				CHAR(2);
	DEFINE vColor				CHAR(2);
	DEFINE vCuenta_eje			CHAR(20);
	DEFINE vEst_cta				CHAR(1);

	
	LET vsqlerr					= 0; 
    LET iIsamErr				= 0;
    LET cErrorInfo				= '';   
	LET vErrorInfo        		= 'INICIO DEL PROCESO';
	LET vCodRet					= '00000';
	LET vNombre_sd				= '';
	LET vIcono					= '';
	LET vColor					= '';
	LET vProducto				= 0;
	LET vEst_cta				= '';
	LET vEst_sd					= 0;
	LET vCant_sd				= 0;
	LET vCuenta_sd				= TRIM(NVL(pCuenta_sd,''));
	LET vCuenta_eje            	= TRIM(NVL(pCuenta_eje,''));
	LET vNombreT_sd				= TRIM(NVL(pNombre_sd,''));
	LET pIcono					= TRIM(NVL(pIcono,''));
	LET pColor					= TRIM(NVL(pColor,''));
	
	BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/informix/c90186322/trace/sp_perso_sd_err.txt";
				--TRACE ON;
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
				LET vCuenta_eje= pCuenta_eje;
				RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/c90186322/trace/sp_perso_sd.txt';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3; 
		
		--SE VALIDA QUE LA CUENTA EJE NO VENGA VACIO O NULO
		IF  vCuenta_eje = '' THEN
			LET  vCodRet='00001';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
		END IF;
		
		
		--SE OPTIENE LOS VALORES DE LA CUENTA EJE	
		SELECT producto,  status_cta
		INTO   vProducto, vEst_cta
		FROM   "informix".sc_maechq
		WHERE  cuenta = pCuenta_eje;
			
		LET vEst_cta = TRIM(NVL(vEst_cta,''));
		LET vProducto = TRIM(NVL(vProducto,''));
				
			--SE VALIDA EL ESTATUS DE LA CUENTA QUE SEA ACTIVO
		IF vEst_cta <>  '1' THEN
			LET  vCodRet='00002';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
		END IF;
		
		--SE VALIDA QUE EL PRODUCTO DE LA CUENTA EJE SEA VALIDO AL CATALOGO
		IF vProducto NOT IN (SELECT producto FROM sc_prodis_sd) THEN
			LET  vCodRet='00003';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_mae_sd WHERE cuenta_sd = pCuenta_sd AND cuenta_eje = pCuenta_eje AND estatus in (1,3)) THEN
			LET vCodRet='00010';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,vIcono,vColor;
		END IF
		
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_ico_sd WHERE id = pIcono)  THEN
			LET  vCodRet='00005';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,'','';
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_col_sd WHERE id = pColor) THEN
			LET  vCodRet='00006';			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vNombre_sd,'','';
		END IF;
		
		--Actualiza los datos del sobre y valida que no venga vacio
		IF vNombreT_sd = '' THEN
			SELECT nombre_sd
			INTO vNombreT_sd
			FROM "informix".sc_mae_sd
			WHERE cuenta_sd = pCuenta_sd;
		END IF;

		UPDATE "informix".sc_mae_sd
		SET icono = pIcono,
			color = pColor,
			nombre_sd = vNombreT_sd
		WHERE cuenta_sd = pCuenta_sd;
		
		RETURN vCodRet,pCuenta_eje,pCuenta_sd,vNombreT_sd,pIcono,pColor;			
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR ESTATUS 3 DE FINALIZADO CUANDO SE CONSULTAN LOS APARTADOS POR CUENTA DE CAPTACION',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_valferiadobanca_exp(pEmpresa 	  		CHAR(3),
											   pPriDiaNaturalMes	DATE,
											   pDiasBloque       	INT,
											   pOperacion			CHAR(1))
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    DATE;               -- Fecha Habil del bloque

DEFINE cVarDataErr      	VARCHAR(64);
DEFINE iSqlErr          	INTEGER;
DEFINE iSamErr          	INTEGER;
DEFINE cCodRet          	CHAR(5);
DEFINE dFechaActual        	DATE;
DEFINE i              		INTEGER;
DEFINE j              		INTEGER;
DEFINE siFeriado        	INTEGER;
DEFINE cRespSP  			CHAR(5);
DEFINE dFechaSp 			DATE;
DEFINE sRetCodSP 			CHAR(5);
DEFINE dFechaReSp 			DATE;
DEFINE cDia 				CHAR(2);
DEFINE cMes 				CHAR(2);
DEFINE cAnio 				CHAR(4);
DEFINE cFechaFormat			CHAR(8);
DEFINE cFechaDiaLEN 		INTEGER;
DEFINE cFechaMesLEN 		INTEGER;
DEFINE cFechaAnioLEN 		INTEGER;


LET cCodRet					= '00000';
LET dFechaActual			= '';
LET cRespSP 				= '';
LET sRetCodSP 				= '';
LET cDia 					= '';
LET cMes 					= '';
LET cAnio 					= '';
LET siFeriado				= 0;
LET i 						= 0;
LET j 						= 0;	
LET cvardataerr				= '';	
LET cFechaFormat			= '';		

	--SET debug FILE TO "/tmp/domi/sp_valferiadobanca.out";
	--TRACE ON;
	
BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodret=iSqlErr;
            RETURN cCodret,dFechaActual;
        END IF;
    END EXCEPTION;

	IF pOperacion = 'V' OR pDiasBloque = 0 THEN
		LET dFechaActual = pPriDiaNaturalMes; 
		
		IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
			SELECT COUNT(*) 
				INTO siFeriado       
			FROM bdinteg:si_feriado_banca
			WHERE fecha = dFechaActual
				AND pais = pEmpresa and laborable = "N";
			
			IF NOT siFeriado IS NULL AND siFeriado <> 0 THEN
				LET dFechaActual = '';
				LET cCodRet = "00008";			
			END IF;	
		ELSE
			LET dFechaActual = '';
			LET cCodRet = "00009";
		END IF;

	-- Se valida si la operacion elegida fue la suma de dias
	ELIF pOperacion = 'S' THEN
		WHILE i <= pDiasBloque 
			LET dFechaActual = pPriDiaNaturalMes + j;
			LET siFeriado = 0;
			--Valida los fines de semana.
			IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
				--Consulta si el dia es feria para la banca
				SELECT COUNT(*) 
					INTO siFeriado       
				FROM bdinteg:si_feriado_banca
				WHERE fecha = dFechaActual
					AND pais = pEmpresa and laborable = "N";
				--Si no es feriado aumenta el contador del ciclo
				IF siFeriado IS NULL OR siFeriado = 0 THEN
					LET i = i + 1;
				END IF;
			END IF;
			LET j = j + 1;
		END WHILE
	-- Se valida si la operacion elegida fue la resta de dias
	ELIF pOperacion = 'R' THEN
		WHILE i <= pDiasBloque
			LET dFechaActual = pPriDiaNaturalMes;
			LET dFechaActual = pPriDiaNaturalMes + j UNITS DAY;
			LET siFeriado = 0;
			--Valida los fines de semana.
			IF (WEEKDAY(dFechaActual) >= 1 AND WEEKDAY(dFechaActual) <= 5) then
				--Consulta si el dia es feria para la banca
				SELECT COUNT(*) 
					INTO siFeriado       
				FROM bdinteg:si_feriado_banca
				WHERE fecha = dFechaActual
					AND pais = pEmpresa and laborable = "N";
				 --Si no es feriado aumenta el contador del ciclo
				IF siFeriado IS NULL OR siFeriado = 0 THEN
					LET i = i + 1;
				END IF;
			END IF;
			LET j = j - 1;
		END WHILE
	ELSE
		--Si la operacion elegida fue distinta a "S" SUMA, "R" RESTA ó "V" Validacion de la fecha recibida.
		LET cCodRet = "00010";
	END IF;
	
   RETURN cCodRet,dFechaActual;
END
END PROCEDURE
DOCUMENT
'AUTOR : Antonio Bastidas',
'DESCRIPCION: Valida la cadena de fecha, con base a los dias de bloque y la operacion "S" = SUMA, "R"= RESTA',
' determina la fecha proxima segun el catalogo si_feriado_banca y tambien excluyendo los fines de semana.',
'FECHA : 21/04/2010',
'BD    : BDIDOMI',
'VER   : 20100422.0906';

Create Procedure "informix".sp_generaarchivocuentasnomina_exp()
Returning Char(3), Char(18);
    
    Define siMes            Smallint ;
    Define siYear           Integer ;
    Define siDia            Smallint ;
    Define cCodRet          Char(3);
    Define cCodRet2         Char(5);
    Define cCodRet3         Char(50);
    Define dFechaActual     Date ;
    Define cSQL             Char(600);    
    Define cDirectorio      Char(100);
    Define cEmpresa         Char(3);
    Define cNombreArchivo   Char(18);
    Define cMes             Char(2);
    Define cDia             Char(2);
    Define dFechaAnterior   Date;
    Define v_iSqlErr        Integer;
    Define v_iSamErr        Integer;
    Define v_cDesErr        Char(50);
    Define bGrupCop         Integer;
	DEFINE cHoraAplicado    DateTime Hour to Second;
    
    Let siMes          = 0;
    Let siYear         = 0;
    Let siDia          = 0;
    LET cCodRet        = '';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    Let cDirectorio    = "";
    Let cSQL           = "";
    Let dFechaActual   = '';
    Let cEmpresa       = '';
    Let cNombreArchivo = '';
    Let cMes           = '';
    Let cDia           = '';
    Let dFechaAnterior = '';
    Let v_iSqlErr      = 0;
    Let v_iSamErr      = 0;
    LET v_cDesErr      = '';
    Let bGrupCop       = 0;
	LET cHoraAplicado  = current;
    
    --- Set debug file to "/tmp/sp_generaarchivocuentasnomina.out";
    --- Trace on;
    
    Begin
    
    -- // Controla algun posible error del procedimiento.
    ON EXCEPTION SET v_iSqlErr, v_iSamErr, v_cDesErr
        Set debug file to "/tmp/sp_generaarchivocuentasnomina.err";
        Trace on;
        IF v_iSqlErr <> 0 THEN
            LET cCodRet  = v_iSqlErr;
            LET cCodRet2 = v_iSamErr;
            LET cCodRet3 = v_cDesErr;
            RETURN cCodRet, cNombreArchivo;
        END IF;
    END EXCEPTION
    
	-- // Truncar tabla donde se guarda el nombre de archivo
	TRUNCATE TABLE bdicheq:sc_nominaresultadoscuentasnomina;
	
    -- // Realiza una consulta a la tabla de fechas donde saca los valores de fechas y los inserta en las variables.
    Select Year(fecha_hoy), Month(fecha_hoy), Day(fecha_hoy), fecha_hoy, fecha_hoy - Day(20)
      Into siYear, siMes, siDia, dFechaActual, dFechaAnterior
      From bdicheq:sc_fechas
     Where empresa = "001";
    
    -- // Saca las altasnuevas segun el rango de fechas  y las inserta en la tabla sc_nominarelacionnuevascuentas.
    Insert Into bdicheq:sc_nominarelacionnuevascuentas
    ( empresa, numero_empleado, numero_cuenta, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe )
    Select lpad(pf.numeric1,3,"0"), pf.numeric2, noc.cuenta, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, cte.rfc, tar.num_tarjeta, chq.cuenta_clabe
      From bdicheq:sc_maenoc as noc
     Inner Join bdicheq:sc_maechq as chq On ( chq.cuenta = noc.cuenta )
     Inner Join bdinteg:si_ctepf as pf On ( chq.num_cte = pf.numcte )
     Inner Join bdinteg:si_cliente as cte On ( chq.num_cte = cte.numcte )
      Left Outer Join bdicheq:sc_tarjeta as tar On ( chq.num_cte = tar.numcte and chq.cuenta = tar.cuenta and tar.Status_tar = 'A' and tar.tipo_tarjeta = 'T' )
	  Left Outer Join intercard:tarjeta as card On ( tar.num_tarjeta = card.numtarjeta )
     Where chq.empresa = '001'
       And chq.status_cta = '1'
       And ( ( noc.fecha_alta >= dFechaAnterior And noc.fecha_alta < dFechaActual ) OR 
             ( card.fechaasignacion::date >= dFechaAnterior AND card.fechaasignacion::date < dFechaActual ) ) 
       And chq.producto in('1300','1700');
    
    -- // Valida si existen altas nuevas
    If Exists ( Select empresa From bdicheq:sc_nominarelacionnuevascuentas ) Then
        -- // Si existen altas nuevas las guarda de manera historica en sc_nominarelacionnuevascuentashis.
        Insert Into bdicheq:sc_nominarelacionnuevascuentashis
        ( empresa, numero_empleado, numero_cuenta, fecha_insercion, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe )
        Select empresa, numero_empleado, numero_cuenta, date(current), apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe
          From bdicheq:sc_nominarelacionnuevascuentas;
        
        -- // Inicializa el codigo de retorno.
        Let cCodRet = '000';		
        Let cMes = LPAD(siMes,2,"0");
        Let cDia = LPAD(siDia,2,"0");
        Let cDirectorio = "/tmp/traspasobanco/archivosnomina/conciliacion/originales/altasnuevas.unl";
            
        -- // Entra a un ciclo foreach en donde el primer select separa las distintas empresas existentes.
        ForEach
            Select Distinct(empresa) 
              Into cEmpresa 
              From bdicheq:sc_nominarelacionnuevascuentas 
             Where empresa::integer > 10
            
            -- // Se genera el nombre del archivo lo compone la empresa, el a?o, mes, dia y un folio (01).			
            Let cNombreArchivo = Trim(cEmpresa)||siYear||cMes||cDia||"01"||".dat";          
            
            -- // Le agrega la "N" al nombre y le asigna un direntorio.
            Let cNombreArchivo = "N" || Trim(cNombreArchivo);			
            
            -- // Crea y le da contenido al archivo query.sql						
            Let cSQL = '';
            Let cSQL = 'echo "UNLOAD TO '||cDirectorio||' '||
                       'Select empresa, numero_empleado, numero_cuenta, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe '||
                       'From bdicheq:sc_nominarelacionnuevascuentas '||
                       'Where empresa = '||cEmpresa||';" > /tmp/query_nomaltas.sql';
            System cSQL;	
            
            -- // IMPORTANTE: Favor de adaptar este directorio en base al funcionamiento de produccion.
            Let cSQL = ''; 	
            Let cSQL = "/ifxsif01/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";        --- PRODUCCION
			--- Let cSQL = "/informix/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";    --- DESARROLLO
            System cSQL;
            
            -- // Le quita el ultimo | al archivo altasnuevas.unl y se renombra con estandar de nombres
            LET cSql = "sed 's/|$//g' /tmp/traspasobanco/archivosnomina/conciliacion/originales/altasnuevas.unl > " ||
                       "/tmp/traspasobanco/archivosnomina/conciliacion/originales/"||cNombreArchivo;
			--- Let cSql = TRIM(cSql);
            SYSTEM cSql;		
        End ForEach
		
        IF ( cNombreArchivo != '' ) THEN
            INSERT INTO bdicheq:sc_nominaresultadoscuentasnomina
            ( nombre_archivo, hora_aplicado ) 
            VALUES
            ( cNombreArchivo||'.asc', cHoraAplicado );
        END IF;
            
        Let cNombreArchivo = '';
        
        If Exists ( Select empresa From bdicheq:sc_nominarelacionnuevascuentas Where empresa::integer <= 10 ) Then
            -- // Se genera el nombre del archivo lo compone la empresa, el a?o, mes, dia y un folio (01).			
            Let cNombreArchivo = 'N001'||siYear||cMes||cDia||"01"||".dat";          	

            -- // Crea y le da contenido al archivo query.sql						
            Let cSQL = '';
            Let cSQL = 'echo "UNLOAD TO '||cDirectorio||' '||
                       'Select empresa, numero_empleado, numero_cuenta, apell_paterno, apell_materno, nombre1, nombre2, rfc, num_tarjeta, cta_clabe '||
                       'From bdicheq:sc_nominarelacionnuevascuentas '||
                       'Where empresa::integer <= 10; " > /tmp/query_nomaltas.sql';
            System cSQL;	
            
            -- // IMPORTANTE: Favor de adaptar este directorio en base al funcionamiento de produccion.
            Let cSQL = ''; 	
            Let cSQL = "/ifxsif01/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";        --- PRODUCCION
			--- Let cSQL = "/informix/bin/dbaccess bdicheq /tmp/query_nomaltas.sql";    --- DESARROLLO
            System cSQL;
            
            -- // Le quita el ultimo | al archivo altasnuevas.unl y se renombra con estandar de nombres
            LET cSql = "sed 's/|$//g' /tmp/traspasobanco/archivosnomina/conciliacion/originales/altasnuevas.unl > " ||
                       "/tmp/traspasobanco/archivosnomina/conciliacion/originales/"||cNombreArchivo;
            SYSTEM cSql;			
        End IF;				
    Else
        -- // NO EXISTEN DATOS NUEVOS
        Let cCodRet = "100";
    End If
    
	-- // Insertar en la tabla el nombre del archivo generado 
	IF ( cNombreArchivo != '' ) THEN
        INSERT INTO bdicheq:sc_nominaresultadoscuentasnomina 
        ( nombre_archivo, hora_aplicado ) 
        VALUES
        ( cNombreArchivo||'.asc', cHoraAplicado );
	END IF;
	
    -- // Borra las altas nuevas y deja la tabla disponible para el proximo llamado
    Delete From bdicheq:sc_nominarelacionnuevascuentas;
    
    -- // Regresa el valor del codigo de retorno al usuario.
    Return cCodRet, cNombreArchivo;
    
    End
        
End Procedure
    
DOCUMENT
'CAMBIO : Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se alter? la estructura de la tabla para generar el archivo con el nombre del cliente y rfc',
'Solicito: Jose Mendoza, Delia Borboa',
'FECHA : 23 de Abril de 2009',
'VERSION:20090423.1052',

'CAMBIO : César Valdéz Figueroa',
'DESCRIPCION: Se altero la estructura de las tablas sc_nominarelacionnuevascuentas y la sc_nominarelacionnuevascuentashis para generar el',
'             campo Num_tarjeta, ademas de modificar el select principal para que filtrara por la tarjeta titular del cliente con estado activo',
'FECHA : 02 de Noviembre de 2009',
'VERSION:20091106.1000',

'CAMBIO : Selene Campos',
'DESCRIPCION: Se modificó para insertar el nombre del archivo en la tabla sc_nominaresultadoscuentasnomina',
'FECHA : 28 de Agosto de 2014',

'CAMBIO : Jorge Ivan Camacho Sanchez',
'DESCRIPCION: Se modificó para obtener la cuenta clabe',
'FECHA : 04 de Abril de 2023';

CREATE PROCEDURE "informix".sp_ws_coppel_bcpl_tar2( pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  pcTipoEje CHAR(1),
											  pcNumCteNumTar CHAR(20) )

RETURNING
 CHAR(5) AS ccCodRetorno,
 CHAR(4)  AS cCodRet,
 CHAR(100) AS mensaje,
 CHAR(8)  AS cFecha_proceso,
 CHAR(6)  AS cHora_proceso,
 CHAR(20) AS ClienteBancoppel,
 CHAR(20) AS ClienteCoppel,
 CHAR(20) AS NumTarjeta,
 CHAR(10) AS FechaAsignacion,
 CHAR(1)  AS EstatusTarjeta,
 CHAR(1)  AS IndicadorTarjeta;

	--VARIABLES DE RETORNO
	DEFINE ccCodRetorno 			CHAR(5);
	DEFINE cCodRet					CHAR(4);
	DEFINE mensaje					CHAR(100);
	DEFINE cFecha_proceso 			CHAR(8);
	DEFINE cHora_proceso 			CHAR(6);
	DEFINE cOpcode 					CHAR(4);
	DEFINE cDescr_completa_mensaje 	CHAR(100);
	DEFINE cNombre_proceso			CHAR(17);
	DEFINE cCadena_ent				CHAR(100);

	DEFINE cCodigoError 			CHAR(5);
	DEFINE cDescripcion 			CHAR(40);
	DEFINE cClienteBancoppel 		CHAR(20);
	DEFINE cClienteCoppel 			CHAR(20);
	DEFINE cNumTarjeta 				CHAR(20);
	DEFINE cFechaAsignacion 		CHAR(20);
	DEFINE cEstatusTarjeta 			CHAR(1);
	DEFINE cIndicadorTarjeta 		CHAR(1);
	DEFINE iContador 				INTEGER;
	DEFINE cNumTarjetas 			CHAR(20); --Variable Nueva
	DEFINE cReturnProc				CHAR(3);

	--VARIABLES DE CONTROL DE ERRORES
	DEFINE	iSqlErr 				INTEGER;
	DEFINE	iIsamErr				INTEGER;
	DEFINE	vErrorInfo				VARCHAR(80);
	DEFINE  iIsamError 				INTEGER;

	---INICIALIZAR VARIABLES
	LET ccCodRetorno  				= '00000';
	LET cCodRet 					= '0000';
	LET mensaje 					= 'Consulta Exitosa';
	LET cFecha_proceso 				= TRIM(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));
	LET cHora_proceso				= REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET cOpcode 					= '0000';
	LET cDescr_completa_mensaje 	= 'Consulta Exitosa.';
	LET cNombre_proceso				= 'sp_ws_coppel_bcpl_tar2';
	LET cCadena_ent 				= TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));

	LET iIsamError = 0;

	LET cCodigoError 		= "00000";
	LET cDescripcion 		= "CONSULTA EXITOSA";
	LET cClienteCoppel 		= "";
	LET cClienteBancoppel 	= "";
	LET cNumTarjeta 		= "";
	LET cFechaAsignacion 	= "";
	LET cEstatusTarjeta 	= "";
	LET cIndicadorTarjeta 	= "";
	LET iSqlErr 			= 0;
	LET iContador 			= 0;
	LET cNumTarjetas        = "";
	LET cReturnProc  		= "";

	--SET DEBUG FILE TO '/home/sysifx/respaldosbd/Adrian/577/sp_ws_coppel_bcpl_tar2.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
			IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
				IF iSqlErr = '-1213' THEN
					LET cCodRet = '0001';
					LET cOpcode = cCodRet;
					
					SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
					INTO cOpcode,mensaje,cDescr_completa_mensaje
					FROM bdisac:"informix".sac_ws_catmensajes
					WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
					
					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
					INTO ccCodRetorno;
					
					IF cOpcode IS NULL THEN
						LET cOpcode = cCodRet;
						LET mensaje = 'Codigo no registrado en catalogo.';
						LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
					END IF;
				ELSE
					LET cCodRet = iSqlErr;
					LET cOpcode = cCodRet;
					LET mensaje = '';
					LET cDescr_completa_mensaje = '';
					
					--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
					EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
					INTO ccCodRetorno;
				END IF;
				
				INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
				VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);
				
				DROP TABLE IF EXISTS tmp_si_clientetarjetas;
				
				--RETURN cCodRet, mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta;
				RETURN cCodRet, cOpcode, cDescr_completa_mensaje, cFecha_proceso, cHora_proceso, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta;
			END IF;
		END EXCEPTION;

		-- VALIDACION DE PARAMETROS
		IF  NVL(pcAgent_cd,'?') <> 'TDA' OR NVL(pcAgent_trans_type_code,'?') <> 'BCPL_TAR2' OR NVL(pcUsuario,'?')= '?'
			OR NVL(pcPassword,'?')= '?' OR NVL(pcFecha_peticion,'?')= '?' OR NVL(pcHora_peticion,'?')= '?'
			OR NVL(pcIp_origen,'')= '' OR NVL(pcSession_id,'')=''
			OR NVL(pcTipoEje,'?')= '?' OR NVL(pcNumCteNumTar,'?')= '?' THEN
			
			LET cCodRet ='9996';
		ELSE
			EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code, pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id)
			INTO cCodRet, mensaje;

			IF cCodRet = '0000' THEN
				IF( pcTipoEje IN( 1, 2 ) AND pcNumCteNumTar != '' ) THEN
						SET LOCK MODE TO WAIT 3;
						SET ISOLATION TO DIRTY READ;

						DROP TABLE IF EXISTS tmp_si_clientetarjetas;
						DROP TABLE IF EXISTS tmp_si_tarjetas;
						
						LET pcNumCteNumTar = TRIM( pcNumCteNumTar );

						IF TRIM( NVL(pcTipoEje, "") ) = "1" THEN

							SELECT a.numcte AS numctebancoppel, {+INDEX (bdinteg:"informix".idx_numcte_ref)} a.numcte_ref AS numctecoppel, b.numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, SPACE(1) AS statustarjeta, 'D' AS indicadortarjeta
							FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
							ON a.numcte = b.numcliente
							JOIN bdicheq:"informix".sc_tarjeta c
							ON b.numtarjeta = c.num_tarjeta
							WHERE a.numcte_ref = pcNumCteNumTar
							AND c.status_tar = 'A'
							AND a.empresa = '001'
							INTO TEMP tmp_si_clientetarjetas with no log;

						ELSE

							SELECT a.numcte AS numctebancoppel, a.numcte_ref AS numctecoppel, {+INDEX (intercard:tarjeta idx_tarjeta1)} b.numtarjeta AS numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, c.status_tar AS statustarjeta, c.tipo_tarjeta AS indicadortarjeta
							FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
							ON a.numcte = b.numcliente
							JOIN bdicheq:"informix".sc_tarjeta c
							ON b.numtarjeta = c.num_tarjeta
							WHERE b.numtarjeta = pcNumCteNumTar
							AND a.empresa = '001'
							INTO TEMP tmp_si_clientetarjetas with no log;

						END IF;

						CREATE TEMP TABLE tmp_si_tarjetas(numtarj VARCHAR(16)) WITH NO LOG;

						SELECT FIRST 1 numctebancoppel
						INTO cClienteBancoppel
						FROM tmp_si_clientetarjetas;

						FOREACH
							EXECUTE PROCEDURE bditrapres:"informix".sp_consulta_tarjetas_dep(cClienteBancoppel) INTO cReturnProc, cNumTarjetas
							INSERT INTO tmp_si_tarjetas(numtarj) VALUES(cNumTarjetas);
						END FOREACH;

						FOREACH sal_cursor FOR
							SELECT numctebancoppel, numctecoppel, numtarjeta, fechaasignacion, statustarjeta, indicadortarjeta
							INTO cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cindicadorTarjeta
							FROM tmp_si_clientetarjetas a JOIN tmp_si_tarjetas c
							ON a.numtarjeta = c.numtarj

							LET iContador = iContador + 1;

							--RETURN cCodigoError, cDescripcion, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta WITH RESUME;
							RETURN cCodRet, cOpcode, cDescr_completa_mensaje, cFecha_proceso, cHora_proceso, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta WITH RESUME;

						END FOREACH;
				END IF;
			END IF;
		END IF;

		DROP TABLE IF EXISTS tmp_si_clientetarjetas;
		DROP TABLE IF EXISTS tmp_si_tarjetas;

		IF cCodRet <> '0000' THEN
			--Se obtienen los mensajes de error asi como el codigo del mensaje
			SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
			INTO cOpcode,mensaje,cDescr_completa_mensaje
			FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;

			--En caso de que no exista el codigo del mensaje se les asigna otros valores
			IF cOpcode IS NULL THEN
				LET cOpcode = cCodRet;
				LET mensaje = 'Codigo no registrado en catalogo.';
				LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
			END IF;

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso,cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
			INTO ccCodRetorno;

		END IF;

		INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
		VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, cDescr_completa_mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);

		IF  iContador = 0 THEN
			RETURN cCodRet, cOpcode, cDescr_completa_mensaje, cFecha_proceso, cHora_proceso, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta;
		END IF;

	END
END PROCEDURE;