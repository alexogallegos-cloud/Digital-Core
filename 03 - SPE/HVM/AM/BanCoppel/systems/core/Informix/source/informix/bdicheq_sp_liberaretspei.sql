CREATE PROCEDURE "informix".sp_liberaretspei( pEmpresa CHAR(3) ) 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vAbierto         CHAR(1);
    DEFINE vFechaAnt        DATE;
    DEFINE vFechaHoy        DATE;
    DEFINE vDiasRet         SMALLINT;   
    DEFINE vCuenta          CHAR(20);
    DEFINE vMontoRet        MONEY(14,2);
    DEFINE vFechaTrx        DATE;
    DEFINE vSdoRetenido     MONEY(14,2);
    DEFINE vSucursal        CHAR(4);
    DEFINE vImpSbg          MONEY(14,2);
    DEFINE cFolioDep        CHAR(16);
    DEFINE cReferencia      CHAR(40);
    DEFINE vCobraCom        SMALLINT;
    DEFINE vComPend         SMALLINT;
    DEFINE vHora            CHAR(15);
    DEFINE vFolioSuc        CHAR(16);
    DEFINE vCodRet4         CHAR(5);
    DEFINE vCodRet5         CHAR(5);
    DEFINE vSigDiaHabil     DATE;
    --RQM 09 704 . Osiel Alfredo Camacho Mendoza. Fecha modificacion: 14/10/2025
	--Variables de retorno para el sp maestro de retenciones.
	DEFINE cCodRetSpReten	CHAR(5);
	DEFINE cMensajeRetSpReten	CHAR(150);
    DEFINE cNumCte          CHAR(16);
    DEFINE cProceso             CHAR(50);
    DEFINE vfecha_operacion     DATE;
    DEFINE iContTxPermRet       INTEGER;
    DEFINE cTransacc        CHAR(50);
	
    LET Sql_Err	      = 0;
    LET Isam_Err      = 0;
    LET Desc_Err      = '';
    LET vCodRet1      = '';
    LET vCodRet2      = '';
    LET vCodRet3      = '';  
    LET vContador1    = 0;
    LET vContador2    = 0;
    LET vAbierto      = '0';
    LET vFechaAnt     = '';
    LET vFechaHoy     = '';
    LET vDiasRet      = 0;
    LET vCuenta       = '';
    LET vMontoRet     = 0.00;
    LET vFechaTrx     = '';
    LET vSdoRetenido  = 0.00;
    LET vSucursal     = '';
    LET vImpSbg       = 0.00;
    LET cFolioDep     = '';
    LET cReferencia   = '';
    LET vComPend      = 0;
    LET vCobraCom     = 0;
    LET vHora         = '';
    LET vFolioSuc     = '';   
    LET vCodRet4      = '';
    LET vCodRet5      = '';
    LET vSigDiaHabil  = '';
    --Variables de retorno para el sp maestro de retenciones OACM.
	LET cCodRetSpReten		='00000';
	LET cMensajeRetSpReten	='';
    LET cNumCte       = '';
    LET cProceso      = 'sp_liberaretspei';
    LET iContTxPermRet		=0;
    LET cTransacc  = '0273';
    
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretspei.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_liberaretspei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
    -- // OBTIENE FECHAS DEL SISTEMA DE CHEQUES 
    SELECT fecha_ant, fecha_hoy
      INTO vFechaAnt, vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // REALIZA LIBERACION DE MONTOS RETENIDOS POR TRANSACCIONES SPEI
    FOREACH WITH HOLD
        SELECT dep.cuenta, dep.monto_ret, dep.fecha_hoy, dep.folio_suc, dep.referencia,
               mae.sdo_retenido, mae.sucursal, (mae.imp_chq_sbg + mae.imp_sbg_ccc),mae.num_cte
          INTO vCuenta, vMontoRet, vFechaTrx, cFolioDep, cReferencia, 
               vSdoRetenido, vSucursal, vImpSbg, cNumCte
          FROM sc_depositospei dep,
               sc_maechq mae
         WHERE dep.fecha_hoy < vFechaHoy
           AND dep.cuenta = mae.cuenta
           AND dep.monto_ret > 0
           AND dep.liberado = '0' 
        
        BEGIN WORK;
        LET vAbierto = '1';
        
        -- // VALIDA EL DIA DE LIBERACION
        CALL bdispei:sp_validafecha(pEmpresa, vFechaTrx)
        RETURNING vCodRet5, vSigDiaHabil;
        
        IF vFechaHoy >= vSigDiaHabil THEN
            IF vSdoRetenido >= vMontoRet THEN
                UPDATE sc_maechq
                   SET sdo_retenido = sdo_retenido - vMontoRet
                 WHERE cuenta = vCuenta;
                    
                UPDATE sc_depositospei
                   SET liberado = '1'
                 WHERE fecha_hoy = vFechaTrx
                   AND cuenta = vCuenta
                   AND monto_ret = vMontoRet
                   AND liberado = '0'
                   AND folio_suc = cFolioDep
                   AND referencia = cReferencia;
                   
                LET vcontador2 = vcontador2 + 1;
                   
                IF vImpSbg > 0 THEN
                    LET vCobraCom = 1;
                END IF;
                   
                IF vCobraCom = 0 THEN
                    SELECT COUNT(*)
                      INTO vComPend
                      FROM sc_detcomis
                     WHERE empresa = pEmpresa 
                       AND cuenta = vCuenta 
                       AND estado_com = "P";
                             
                    IF vComPend > 0 THEN
                        LET vCobraCom = 1;
                    END IF;
                END IF;
                   
                IF vCobraCom = 1 THEN
                    LET vHora = CURRENT HOUR TO FRACTION;
                    LET vFolioSuc = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
                    
                    CALL cobintcomsbg(pEmpresa, vCuenta, vFolioSuc, 'informix', vSucursal)
                    RETURNING vCodRet4;
                END IF;
            END IF; 
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
       
        COMMIT WORK;
        
        --RQM 09 704 . Osiel Alfredo Camacho Mendoza. Fecha modificacion: 29/10/2025 
		--Se realiza la validacion sobre las transacciones de pago de nomina para el llamado al sp de retenciones
		--Conteo para validacion de transaccion permitida
		SELECT COUNT(*) 
        INTO iContTxPermRet 
		FROM sc_transaccs_no_permitidas_reten_cob_auto 
		WHERE transaccion = cTransacc AND estatus = '1';

        IF(iContTxPermRet = 0) THEN
	        EXECUTE PROCEDURE sp_retencion_cobranza_automatica(cNumCte,vCuenta,vFolioSuc)INTO cCodRetSpReten,cMensajeRetSpReten;
         --Validacion del codigo de retorno.
		    IF (cCodRetSpReten NOT IN ('00000','00002','00003')) THEN
			    --Registro del tipo de error al ejecutar el SPL sp_retencion_cobranza_automatica.
                INSERT INTO sc_bit_error_cobranza_automatica VALUES(0, cProceso, cCodRetSpReten, cMensajeRetSpReten, cNumCte, vCuenta, vFechaHoy, vHora, vFolioSuc);
            END IF;
        END IF;
		LET vAbierto = '0';
        
        LET vCuenta       = '';
        LET vMontoRet     = 0;
        LET vFechaTrx     = '';
        LET vSdoRetenido  = 0;
        LET vSucursal     = '';
        LET vImpSbg       = 0.00;
        LET cFolioDep     = '';
        LET vCobraCom     = 0;
        LET vComPend      = 0;
        LET vHora         = '';
        LET vFolioSuc     = '';
        LET vCodRet4      = '';
    END FOREACH;
    
    /* ###########################################
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO vCuenta
          FROM sc_depositospei
         WHERE fecha_hoy < vFechaHoy 
           AND liberado = '1'
             
        BEGIN WORK;
        LET vAbierto = '1';
             
        INSERT INTO sc_depositospeihist
        SELECT *
          FROM sc_depositospei
         WHERE cuenta = vCuenta
           AND fecha_hoy < vFechaHoy
           AND liberado = '1';
             
        DELETE FROM sc_depositospei
         WHERE cuenta = vCuenta
           AND fecha_hoy < vFechaHoy
           AND liberado = '1';
             
        COMMIT WORK;
        LET vAbierto = '0';
        
        LET vCuenta = '';
    END FOREACH;
    ########################################### */
    
    LET vCodRet1 = '000';
    LET vCodRet2 = '000';
    LET vCodRet3 = 'PROCESO FINALIZADO';  
	    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se agrega el sp de retencion de cobranza automatica, el cual retiene el saldo del cliente si se encuentra en la tabla de control ',
'Modificador : Osiel Alfredo Camacho Mendoza',
'FECHA : 28/10/2025',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_retiro_sd( pCuenta_eje CHAR(20),pCuenta_sd CHAR(20),pTipoMov CHAR(1), pCanal CHAR(1),pFecOper DATE,pHorOper CHAR(10),pMonRet MONEY(14,2))
						
									
	RETURNING CHAR (5), CHAR(20), CHAR(20), DATE, CHAR(8), MONEY(14,2), CHAR(10), CHAR(18), CHAR(2), CHAR(2),
				MONEY(14,2), DATE, MONEY(14,2), MONEY(14,2), INTEGER, DATE, DATE, INTEGER,  CHAR(2), CHAR(2), CHAR(10);
				  

    DEFINE vsqlerr, vEstCtaEje,vValUptMaeSd,vValUptMaeChq,vEst_sd,vValInse
		,vTransaccion,vPeriodicidad INTEGER;
	
	DEFINE vMonto_meta,vMontAboAuto,vMontoAcum,vSaldRetEj MONEY(14,2);
    
	DEFINE vFecOper,vFecha_meta,vFechUltAbo,vProxAboAut DATE;

	DEFINE iIsamErr, vProducto  SMALLINT;
	DEFINE bInicia  BOOLEAN;

    DEFINE cErrorInfo      	 CHAR(80);
	DEFINE vErrorInfo     	 CHAR(80);
    DEFINE vCodRet         	 CHAR(5);
	DEFINE vCuenta_eje	  	 CHAR(20);
	DEFINE vCuenta_sd	     CHAR(20);
	DEFINE vHorOper		     CHAR(8);
	DEFINE vCanal		     CHAR(2);
	DEFINE vSucursal         CHAR(4); 
	DEFINE vHora             CHAR(25);
	DEFINE vFolio            CHAR(16);
	DEFINE vUsuario          CHAR(8);
	DEFINE vProd             CHAR(4);
	DEFINE VusuMovRet        CHAR(10);
	DEFINE vIdPlantillaPush	 CHAR(12);
	DEFINE vNumCte           CHAR(20);
	DEFINE vSp_CodRet        CHAR(5);
	DEFINE vNombre_sd        CHAR(18);
	DEFINE vIcono	         CHAR(2);
	DEFINE vColor		     CHAR(2);
	DEFINE vTipoApartado     CHAR(2);
	DEFINE vDiaAboIni        CHAR(10);
	--RQM 09 704 - Luis Enrique Orozco Cosme - Fecha modificacion: 14/10/2025
    --Variables de retorno para el sp maestro de retenciones.
    DEFINE cCodRetSpReten       CHAR(5);
    DEFINE cMensajeRetSpReten   CHAR(150);
    DEFINE cProceso             CHAR(50);

	LET vsqlerr            = 0; 
    LET iIsamErr           = 0;
    LET cErrorInfo         = "";   
    LET vErrorInfo         = "INICIO DEL PROCESO";
    LET vCodRet            = "00000";
	LET vCuenta_eje        = TRIM(NVL(pCuenta_eje,''));
	LET vCuenta_sd         = TRIM(pCuenta_sd);
	LET vFecOper           = pFecOper;
	LET vHorOper           = TRIM(pHorOper);
	LET vCanal             = TRIM(pCanal);
	LET vEstCtaEje         = 0;
	LET vSucursal          = " ";
	LET vUsuario           = 'informix';
	LET vHora              = '';
	LET vFolio         	   = " ";
	LET vValUptMaeSd       = 0; 
	LET vValUptMaeChq      = 0;
	LET vProd              = "";
	LET vProducto		   = 0;
	LET vNombre_sd         = " ";
	LET vIcono	           = " ";
	LET vColor		       = " ";
	LET vMonto_meta        = 0;
	LET vFecha_meta        = " ";
	LET vMontAboAuto       = 0.00;
	LET vPeriodicidad      = 0;
	LET vFechUltAbo        = " ";
	LET vProxAboAut        = " ";
	LET vEst_sd            = 0;
	LET vMontoAcum         = 0;
	LET vSaldRetEj         = 0;
	LET vValInse           = 0;
	LET bInicia            = "F"; 
	LET VusuMovRet         = "";
	LET vIdPlantillaPush   = "SD_FINAP";
	LET vNumCte            = "";
	LET vSp_CodRet         = '00000';
	LET vTransaccion       = 0;
	LET vTipoApartado = "";
    LET vDiaAboIni      = '';
    --RQM 09 704 - Luis Enrique Orozco Cosme - Fecha modificacion: 14/10/2025
    --Variables de retorno para el sp maestro de retenciones.
    LET cCodRetSpReten      ='00000';
    LET cMensajeRetSpReten  ='';
    LET cProceso            = 'sp_retiro_sd';
         
    BEGIN
		ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
			IF  vsqlerr != 0 THEN
				--SET DEBUG FILE TO "/resplogifx/conciliachq/sp_retiro_sd.txt";
				--TRACE ON;
				LET vCodRet    = vsqlerr;
				LET vErrorInfo = cErrorInfo;
				LET vCuenta_eje= pCuenta_eje;
				IF bInicia = "T" THEN
				   IF vtransaccion = 1  THEN 
					  ROLLBACK WORK;
					  BEGIN WORK;
				   ELSE 
					   ROLLBACK WORK;
				   END IF;    
				END IF;
				RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
			END IF;
		END EXCEPTION;
		
		ON  EXCEPTION IN (-535)
			LET vTransaccion = 1;
		END EXCEPTION WITH resume;
	
	
		--SET DEBUG FILE TO '/informix/c90186322/trace/sp_retiro_sd.txt';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  
		
		--ESTATUS CUENTA EJE
		SELECT TRIM(NVL(status_cta,'0')), sucursal,  TRIM(NVL(producto,'')),   num_cte  
		INTO   vEstCtaEje, vSucursal, vProducto,  vNumCte
		FROM   "informix".sc_maechq 
		WHERE  cuenta = vCuenta_eje
		AND    status_cta = '1';
			
		--ESTATUS DE LA CUENTA EJE
		IF  vEstCtaEje <> '1' OR vEstCtaEje IS NULL THEN 	
			LET  vCodRet='00002';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,
			vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;

		-- Valida si es un producto valido para el apartados
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_prodis_sd WHERE producto = vProducto) THEN
			LET vCodRet = '00003';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
		
		 -- VALIDA EL SOBRE DIGITAL Y EL ESTATUS 
		IF NOT EXISTS (SELECT 1 FROM "informix".sc_mae_sd WHERE cuenta_eje = vCuenta_eje AND cuenta_sd = vCuenta_sd AND estatus IN (1,3)) THEN
			LET  vCodRet='00010';
			RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
	
		--TIPO MOVIMIENTO
				
		--VALIDA EL TIPO DE MOVIMIENTO (RETIRO)
		IF pTipoMov <> '2' OR NOT EXISTS (SELECT id FROM "informix".sc_tmov_sd WHERE  id = pTipoMov )  THEN 
			LET  vCodRet='00013';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
	
		 --VALIDA EL TIPO DE CANAL
		IF vCanal <> '1' OR NOT EXISTS (SELECT id FROM "informix".sc_can_sd WHERE  id = vCanal)  THEN
			LET  vCodRet='00014';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,
				vFecha_meta,vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;	
	
		 -- SALDO DISPONIBLE PARA EL SOBRE DIGITAL 
		SELECT NVL(monto_acum,0),TRIM(nombre_sd),TRIM(icono),TRIM(color), monto_meta, fecha_meta,monto_ahor_auto, periodicidad,
			ult_fech_abo_auto, prox_fech_abo_auto,estatus, tipo_apartado,dia_del_cobro
		INTO   vMontoAcum,vNombre_sd,vIcono, vColor, vMonto_meta,vFecha_meta, vMontAboAuto,vPeriodicidad, 
			vFechUltAbo, vProxAboAut, vEst_sd,vTipoApartado,vDiaAboIni
		FROM   "informix".sc_mae_sd
		WHERE  cuenta_eje = vCuenta_eje
		AND    cuenta_sd  = vCuenta_sd
		AND    estatus IN (1,3);	
		
		--SE VALIDA EL SALDO ACUMULADO DEL SOBRE 
		IF   pMonRet > vMontoAcum THEN
			LET  vCodRet='00009';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,
			vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;	
		
		SELECT NVL(sdo_retenido,0)
		INTO   vSaldRetEj
		FROM   "informix".sc_maechq
		WHERE  cuenta = vCuenta_eje
		AND    status_cta = "1";
		
		--SE VALIDA QUE EL SALDO RETENIDO DE LA CUENTA EJE SEA IGUAL O MAYOR A LO QUE SE QUIERE RETIRAR 
		IF vSaldRetEj < pMonRet THEN 
			LET  vCodRet='00015';
			RETURN  vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,
			vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
											
		IF  vTransaccion = 1 THEN 
			COMMIT WORK;
			BEGIN WORK;
		ELSE 
			BEGIN WORK;
		END IF; 
		
		LET bInicia = "T";
		
		LET vMontoAcum = vMontoAcum - pMonRet;

		IF  vMontoAcum = "0" THEN 
			LET vEst_sd = "2";
		END IF;

		--SE LIBERA EL SALDO RETENIDO 
		UPDATE "informix".sc_mae_sd
		SET    monto_acum = vMontoAcum,
			   estatus    = vEst_sd					   
		WHERE  cuenta_eje = vCuenta_eje
		AND    cuenta_sd  = vCuenta_sd
		AND    estatus IN (1,3);	
		
		IF    dbinfo('sqlca.sqlerrd2') > 0 THEN
			  LET vValUptMaeSd = '1';
		END IF;
		
		-- FOLIO DEL MOVIMIENTO 
		LET vHora  = CURRENT YEAR TO FRACTION;
		LET vFolio = vUsuario||vHora[6,7]||vHora[9,10]||vHora[15,16]||vHora[18,19];
		
		--CREA EL FOLIO A RETORNAR
		LET VusuMovRet =  "SD"||SUBSTR(vFolio,9,8);
		
		--INSERTA EL MOVIMIENTO 
		INSERT INTO "informix".sc_mov_sd VALUES (vCuenta_eje,vCuenta_sd,VusuMovRet,2,1,vFecOper,vHorOper,pMonRet,1);
		
		IF dbinfo('sqlca.sqlerrd2') > 0 THEN
			  LET vValInse = '1';
		END IF;
		
		--ACTUALIZA EL SALDO RETENIDO DE LA CUENTA EJE
		UPDATE "informix".sc_maechq 
		SET    sdo_retenido = sdo_retenido - pMonRet
		WHERE  cuenta       = vCuenta_eje
		AND    status_cta   = "1";
	
		IF dbinfo('sqlca.sqlerrd2') > 0 THEN
			LET vValUptMaeChq = '1';
		END IF;
											
		LET bInicia = "F";
		IF  vValUptMaeSd = "1" AND vValInse = "1" AND vValUptMaeChq = "1" THEN 
			LET vCodRet = "00000";
			COMMIT WORK;
			IF vtransaccion = 1 THEN
			   BEGIN WORK;
			END IF;
		ELSE 
			ROLLBACK WORK;
			LET vCodRet = '00011'; --ERROR AL LIBERAR EL SALDO EN LAS TABLAS MAESTRA O DETALLE
			IF vtransaccion = 1  THEN 
			   BEGIN WORK; 
			END IF; 
			   RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,vMontoAcum,
			   vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		END IF;
		
		--RQM 09 704 . Luis Enrique Orozco Cosme. Fecha modificacion: 28/02/2025 
        --Se llama al SPL sp_retencion_cobranza_automatica para realizar la retencion.          
        EXECUTE PROCEDURE sp_retencion_cobranza_automatica(vNumCte,vCuenta_eje,VusuMovRet)INTO cCodRetSpReten,cMensajeRetSpReten;
        
        --Agregar validacion de codigo de retorno
        IF (cCodRetSpReten NOT IN ('00000','00002','00003')) THEN
    		--Registro del tipo de error al ejecutar el SPL sp_retencion_cobranza_automatica.
            INSERT INTO sc_bit_error_cobranza_automatica VALUES(0, cProceso, cCodRetSpReten, cMensajeRetSpReten, vNumCte, vCuenta_eje, vFecOper, vHorOper, VusuMovRet); 						
		END IF;

		-- SI EL ACUMULADO TERMINA en 0 SE CANCELA LA CUENTA									
		IF  vMontoAcum = "0" THEN 			
			IF vTipoApartado = "2" THEN
				LET vIdPlantillaPush = "SD_ELSPP";	
			END IF;

			--RETIRO TOTAL
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX',vIdPlantillaPush,vNumCte,'','','1','','','','',vNombre_sd,
				'','','','','','','',1,0,0,0,0,'','') ----NOTIFICACION PUSH
			INTO vSp_CodRet;
		ELSE 
			--RETIRO PARCIAL
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','PNS_BEX','SD_RETIP',vNumCte,'','','1',pMonRet,'','','',
				vNombre_sd,'','','','','','','',1,0,0,0,0,'','') ----NOTIFICACION PUSH
			INTO vSp_CodRet;

		END IF;
			
		RETURN vCodRet,vCuenta_eje,vCuenta_sd,vFecOper,vHorOper,pMonRet,VusuMovRet,vNombre_sd,vIcono,vColor,vMonto_meta,vFecha_meta,
			vMontoAcum,vMontAboAuto,vPeriodicidad,vFechUltAbo,vProxAboAut,vEst_sd,vCanal,vTipoApartado,vDiaAboIni;
		
	END; 
END PROCEDURE
DOCUMENT
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA REALIZAR RETIROS A APARTADOS ACTIVOS O FINALIZADOS',
'AUTOR : 95358897 - ISARAI BOJORQUEZ',
'FECHA : 07/02/2023',
'BD: BDICHEQ',
'----------------------------------------------------',
'MODIFICO :     Luis Enrique Orozco Cosme',
'FECHA :        01-10-2025',
'MODIFICACION : Se agrega la inmovilizacion de saldos a la cuenta de captacion siempre y cuando cuente con una exigencia de un pago de credito',
'PROYECTO :     RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD :           bdicheq',
'VERSION :      1.0.1';

CREATE PROCEDURE "informix".cargo_comisiones(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
    DEFINE mSdoActual    money(14,2);
    DEFINE mSdoRetenido  money(14,2);
    DEFINE mSdoCong      money(14,2);
    DEFINE mImpChqSbg    money(14,2);
    DEFINE mSaldoSbc     money(14,2);

    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/tmp/cargo_comisiones.err";
        TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo		= '00000';
    LET cMensajeRetConsSdo	= '';
    --RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
    LET mSdoActual    = 0.00;
    LET mSdoRetenido  = 0.00;
    LET mSdoCong      = 0.00;
    LET mImpChqSbg    = 0.00;
    LET mSaldoSbc     = 0.00;
	
    --- SET DEBUG FILE TO "/tmp/cargo_comisiones.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA DATOS DE ENTRADA - EMPRESA
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    
    -- // VALIDA DATOS DE ENTRADA - CUENTA
    --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
    SELECT producto, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
      INTO vproducto, mSdoActual, mSdoRetenido, mSdoCong, mImpChqSbg, mSaldoSbc
      FROM sc_maechq
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta;
    
    --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, mImpChqSbg, '', '', 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vDisponible;

    IF cCodRetConsSdo <> '00000' THEN
        LET eCodRet = '420';
        RETURN eCodRet;
    END IF;        

    IF vproducto in('1300', '1400', '1700') THEN
	   LET eCodRet = '000';
	   RETURN eCodRet;
	END IF;
	   
    --// Extrae instrumentacion de la Comision
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '550';
       RETURN eCodRet;
    END IF; 
	
	-- // Valida la sucursal para transacciones de aclaraciones
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- // SE AGREGA UNA NUEVA FORMA DE APLICACION '3' VARIABLE 
    -- // Determina Forma de Aplicacion
    IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;

    -- // Valida los Rangos
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra comision por reposicion de TDD
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- // Aplica Cargo por Comision	 
		IF vDisponible > 0 THEN 
        CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            RETURN eCodRet;
        END IF;
        
        -- // Valida Cobro de Iva
        IF vGenIva = "S" THEN
            --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
            EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo(eCuenta, '', '', '', '', '', '', '', 'T', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vSdoDisp;
            IF cCodRetConsSdo <> '00000' THEN
                LET eCodRet = '420';
                RETURN eCodRet;
            END IF;       

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra IVA de comision por reposicion de TDD			   
       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- // Registra comision pendiente si es el caso
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos',
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFICO:         Donovan Fernando Torres Landeros',
'FECHA:            10-02-2026',
'MODIFICACION:     Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:         RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:               BDICHEQ',
'VERSION:          1.3';

CREATE PROCEDURE "informix".cargo_comisiones_per(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    DEFINE mSdoActual       MONEY(14,2);
    DEFINE mSdoRetenido     MONEY(14,2);
    DEFINE mSdoCong         MONEY(14,2);
    DEFINE mImpChqSbg       MONEY(14,2);
    DEFINE mSaldoSbc        MONEY(14,2);
    DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/tmp/cargo_comisiones_per.err";
        TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
   --RQM 09 704. Se agregan las siguientes variable DFTL
    LET mSdoActual          = 0;
    LET mSdoRetenido        = 0;
    LET mSdoCong            = 0;
    LET mImpChqSbg          = 0;
    LET mSaldoSbc           = 0;
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';

	
   --SET DEBUG FILE TO "/home/c90402536/Traza/cargo_comisiones_per_modif.out";
   --TRACE ON; 
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA DATOS DE ENTRADA - EMPRESA
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    


    -- // VALIDA DATOS DE ENTRADA - CUENTA
    -- RQM 09 704. Se agrega la variable del saldo inmovilizado para el consumo del spl sp_cons_sdodisp_x_tpcalculo. DFTL
    SELECT producto, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
      INTO vproducto, mSdoActual, mSdoRetenido, mSdoCong, mImpChqSbg, mSaldoSbc
      FROM sc_maechq
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta;
    
    --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, mImpChqSbg, null, null, 'F', '1')     
    INTO cCodRetConsSdo, cMensajeRetConsSdo, vDisponible;
   
    IF cCodRetConsSdo <> '00000' THEN
        LET eCodRet = '420';
        RETURN eCodRet;
    END IF;   
    --IF vproducto in('1300', '1400', '1700') THEN
	--   LET eCodRet = '000';
	--   RETURN eCodRet;
	--END IF;
	   
    --// Extrae instrumentacion de la Comision
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '550';
       RETURN eCodRet;
    END IF; 
	
	-- // Valida la sucursal para transacciones de aclaraciones
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- // SE AGREGA UNA NUEVA FORMA DE APLICACION '3' VARIABLE 
    -- // Determina Forma de Aplicacion
    /*IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;*/

    LET vMontoCom=eMOnto;

    -- // Valida los Rangos
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra comision por reposicion de TDD
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- // Aplica Cargo por Comision	 
		IF vDisponible > 0 THEN 
        CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            RETURN eCodRet;
        END IF;
        
        -- // Valida Cobro de Iva
        IF vGenIva = "S" THEN
        --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
        EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo(eCuenta, null, null, null, null, null, null, null, 'T', '1')     
        INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDisp;

        IF cCodRetConsSdo <> '00000' THEN
            LET eCodRet = '420';
            RETURN eCodRet;
        END IF;   

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra IVA de comision por reposicion de TDD			   
       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- // Registra comision pendiente si es el caso
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/03',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFICO:         Donovan Fernando Torres Landeros',
'FECHA:            10-02-2026',
'MODIFICACION:     Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:         RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:               BDICHEQ',
'VERSION:          1.3';

CREATE PROCEDURE "informix".cargo_comisiones_per_web(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);
    -- SE AGREGAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
    DEFINE cCodRetConsSdo          CHAR(5);
    DEFINE cMensajeRet      CHAR(50); 
    DEFINE mSdoActual       MONEY(14,2);
    DEFINE mSdoRetenido     MONEY(14,2);
    DEFINE mSdoCong         MONEY(14,2);
    DEFINE mSaldoSbc        MONEY(14,2);
    DEFINE mImpChqSbg       MONEY(14,2);

    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/tmp/cargo_comisiones_per.err";
        TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "00000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
    -- SE INICIALIZAN LAS VARIABLES DE SALDO ACTUAL, SALDO RETENIDO, SALDO CONGELADO Y SALDO SBC OACM
    LET cCodRetConsSdo = '00000';
    LET cMensajeRet	= 'Proceso de consulta de saldo exitoso';
    LET mSdoActual = 0.00;
    LET mSdoRetenido = 0.00;
    LET mSdoCong  = 0.00;
    LET mSaldoSbc = 0.00;
    LET mImpChqSbg = 0.00;
	
    -- SET DEBUG FILE TO "/tmp/cargo_comisiones_per.out";
     --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA DATOS DE ENTRADA - EMPRESA
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    
    ---RQM 09 704. Se realiza la consulta de saldo congelado, el saldo retenido y el saldo sbc. OACM 
		--Consulta el saldo de la cuenta Cargo AFORE	 
	SELECT producto,sdo_actual,sdo_cong, sdo_retenido,saldo_sbc,imp_chq_sbg
	INTO vproducto,mSdoActual,mSdoCong,mSdoRetenido,mSaldoSbc,mImpChqSbg
	FROM bdicheq:"informix".sc_maechq
    WHERE empresa = eEmpresa
    AND cuenta = eCuenta;

	-- RQM 09 704. Se almacena el saldo actual por medio de la ejecucion del SP sp_cons_sdodisp_x_tpcalculo OACM
	EXECUTE PROCEDURE BDICHEQ:sp_cons_sdodisp_x_tpcalculo(NULL,mSdoActual,mSdoRetenido,mSdoCong,mSaldoSbc,mImpChqSbg,NULL,NULL,'F',1) 
	INTO cCodRetConsSdo,cMensajeRet,vDisponible;
    
    IF cCodRetConsSdo <> '00000' THEN
        LET eCodRet = '420';
        RETURN eCodRet;
    END IF;   

    --IF vproducto in('1300', '1400', '1700') THEN
	--   LET eCodRet = '000';
	--   RETURN eCodRet;
	--END IF;
	   
    --// Extrae instrumentacion de la Comision
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '550';
       RETURN eCodRet;
    END IF; 
	
	-- // Valida la sucursal para transacciones de aclaraciones
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- // SE AGREGA UNA NUEVA FORMA DE APLICACION '3' VARIABLE 
    -- // Determina Forma de Aplicacion
    /*IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;*/

    LET vMontoCom=eMOnto;

    -- // Valida los Rangos
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra comision por reposicion de TDD
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- // Aplica Cargo por Comision	 
		IF vDisponible > 0 THEN 
        CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            RETURN eCodRet;
        END IF;
        
        -- // Valida Cobro de Iva
        IF vGenIva = "S" THEN
			---RQM 09 704. Se realiza la consulta de saldo congelado, el saldo retenido y el saldo sbc. OACM 
			SELECT sdo_actual,sdo_cong, sdo_retenido,saldo_sbc,imp_chq_sbg
			INTO mSdoActual,mSdoCong,mSdoRetenido,mSaldoSbc,mImpChqSbg
			FROM bdicheq:"informix".sc_maechq
			WHERE empresa = eEmpresa
			AND cuenta = eCuenta;

			-- RQM 09 704. Se almacena el saldo actual por medio de la ejecucion del SP sp_cons_sdodisp_x_tpcalculo OACM
			EXECUTE PROCEDURE BDICHEQ:sp_cons_sdodisp_x_tpcalculo(NULL,mSdoActual,mSdoRetenido,mSdoCong,mSaldoSbc,mImpChqSbg,NULL,NULL,'F',1) 
			INTO cCodRetConsSdo,cMensajeRet,vSdoDisp;

            IF cCodRetConsSdo <> '00000' THEN
                LET eCodRet = '420';
                RETURN eCodRet;
            END IF;   
		
--- //Registra nuevo numero de tarjeta en sc_movdia cuando cobra IVA de comision por reposicion de TDD			   
       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- // Registra comision pendiente si es el caso
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN '00'||eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos',
'Modificacion Se agrega el saldo sbc en el saldo actual ',
'AUTOR : Osiel Alfredo Camacho Mendoza',
'FECHA : 08/07/2025',
'BD : bdicheq ',
'MODIFICO:         Donovan Fernando Torres Landeros',
'FECHA:            10-02-2026',
'MODIFICACION:     Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:         RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:               BDICHEQ',
'VERSION:          1.3';

CREATE PROCEDURE "informix".cargo_comisiones_web(eEmpresa  CHAR(3),
                                             eCuenta   CHAR(20),
                                             eComision CHAR(4),
                                             eMonto    MONEY(14,2),
                                             eFolio    CHAR(16),
                                             eSucursal CHAR(4),
                                             eUsuario  CHAR(8),
                                             eCheque   INTEGER,
                                             eDivisa   CHAR(2),
                                             eHoy      DATE)
RETURNING CHAR(5);
    
    DEFINE eCodRet          CHAR(5);
    DEFINE eCodRet2         CHAR(5);
    DEFINE eCodRet3         CHAR(50);
    DEFINE sql_err          SMALLINT;
    DEFINE isam_err         SMALLINT;
    DEFINE error_info       CHAR(50);
    DEFINE vFormaAplic      CHAR(1);
    DEFINE vMtoAplic        MONEY(14,2);
    DEFINE vFactorAplic     DECIMAL(9,6);
    DEFINE vRangos          CHAR(1);
    DEFINE vRangoMin        DECIMAL(14,2);
    DEFINE vRangoMax        DECIMAL(14,2);
    DEFINE vGenIva          CHAR(1);
    DEFINE vTranCom         CHAR(4);
    DEFINE vTranIva         CHAR(4);
	DEFINE vNumTarjeta      CHAR(20);
	DEFINE pNumTarjeta      CHAR(20);
    DEFINE vMontoCom        MONEY(14,2);
    DEFINE vValIva          DECIMAL(9,6);
    DEFINE vDisponible      MONEY(14,2);
    DEFINE vMtoCom          MONEY(14,2);
    DEFINE vMontoPen        MONEY(14,2);
    DEFINE vMontoDif        MONEY(14,2);
    DEFINE vexistecta       SMALLINT;
    DEFINE vexistecom       SMALLINT;
	DEFINE vproducto        CHAR(4);
	DEFINE vIVA             MONEY(14,2);
    DEFINE vSdoDisp         MONEY(14,2);
    --RQM 09 704. Se agregan las siguientes variable DFTL
    DEFINE mSdoActual       MONEY(14,2);
    DEFINE mSdoRetenido     MONEY(14,2);
    DEFINE mSdoCong         MONEY(14,2);
    DEFINE mImpChqSbg       MONEY(14,2);
    DEFINE mSaldoSbc        MONEY(14,2);
    DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    DEFINE mSdoDisponible    MONEY(14,2);

    ON EXCEPTION SET sql_err, isam_err, error_info
        --SET DEBUG FILE TO "/tmp/cargo_comisiones.err";
        --TRACE ON;
        LET eCodRet = sql_err;
        LET eCodRet2 = isam_err;
        LET eCodRet3 = error_info;
        RETURN eCodRet;
    END EXCEPTION;

    LET eCodRet      = "00000";
    LET eCodRet2     = "000";
    LET eCodRet3     = "000";
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET error_info   = '';
    LET vFormaAplic  = '';
    LET vMtoAplic    = 0;
    LET vFactorAplic = 0;
    LET vRangos      = '';
    LET vRangoMin    = 0;
    LET vRangoMax    = 0;
    LET vGenIva      = '';
    LET vTranCom     = '';
    LET vTranIva     = '';
    LET vMontoCom    = 0;
    LET vValIva      = 0;
	LET vNumTarjeta  = '';
	LET pNumTarjeta  = '';
    LET vDisponible  = 0;
    LET vMtoCom      = 0;
    LET vMontoPen    = 0;
    LET vMontoDif    = 0;
    LET vexistecta   = 0;
    LET vexistecom   = 0;
	LET vproducto    = '';
	LET vIVA         = 0;
    LET vSdoDisp     = 0;
   --RQM 09 704. Se agregan las siguientes variable DFTL
    LET mSdoActual          = 0;
    LET mSdoRetenido        = 0;
    LET mSdoCong            = 0;
    LET mImpChqSbg          = 0;
    LET mSaldoSbc           = 0;
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';


   --SET DEBUG FILE TO "/home/c90402536/Traza/cargo_comisiones_web_modif.out";
   --TRACE ON; 
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- 
    IF eEmpresa is null OR eEmpresa = '' THEN
        LET eCodRet = '110';
        RETURN eCodRet;
    END IF;
    
    -- // VALIDA DATOS DE ENTRADA - CUENTA
    -- RQM 09 704. Se agrega la variable del saldo inmovilizado para el consumo del spl sp_cons_sdodisp_x_tpcalculo. DFTL
    SELECT producto, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg, saldo_sbc
      INTO vproducto, mSdoActual, mSdoRetenido, mSdoCong, mImpChqSbg, mSaldoSbc
      FROM sc_maechq
     WHERE empresa = eEmpresa
       AND cuenta = eCuenta;
    
    --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, mImpChqSbg, null, null, 'F', '1')     
    INTO cCodRetConsSdo, cMensajeRetConsSdo, vDisponible;

    IF cCodRetConsSdo <> '00000' THEN
        LET eCodRet = '420';
        RETURN eCodRet;
    END IF;   

    IF vproducto in('1300', '1400', '1700') THEN
	   LET eCodRet = '000';
	   RETURN eCodRet;
	END IF;
	   
    --
    SELECT forma_aplica, monto_aplica, factor_aplica, rangos, rango_min, rango_max, genera_iva, transacc_com, transacc_iva
      INTO vFormaAplic, vMtoAplic, vFactorAplic, vRangos, vRangoMin, vRangoMax, vGenIva, vTranCom, vTranIva
      FROM sc_comisiones
     WHERE empresa = eEmpresa
       AND comision = eComision;
	   
	IF vFormaAplic is null OR vFormaAplic = " " THEN
       LET eCodRet = '00550';
       RETURN eCodRet;
    END IF; 
	
	-- 
	IF eComision = '0343' THEN
	   SELECT sucursal 
	     INTO eSucursal
	     FROM bdinteg:si_sucursales
		WHERE sucursal = eSucursal;
	   IF eSucursal is null or eSucursal = "" THEN
	      SELECT sucursal
            INTO eSucursal		  
		    FROM bdinteg:si_ejecut 
		   WHERE ejecutivo in(SELECT num_empleado 
		                        FROM bdiaclaracion:acl_aclaracion 
							   WHERE folio_csuac = eFolio);
       END IF;
    END IF;	   
	
    SELECT valor 
      INTO vValIva 
      FROM bdinteg:si_param
     WHERE empresa = eEmpresa
       AND cod_param = 47;
		 
    -- 
    -- 
    IF vFormaAplic = "1" THEN 
        LET vMontoCom = vMtoAplic; -- Monto Fijo de Comision
    ELIF vFormaAplic = "2" THEN  
        LET vMontoCom = eMOnto * vFactorAplic; -- Por Factor
    ELIF vFormaAplic = "3" THEN  -- Variable (JGP - Para Cheques Devueltos)
        LET vMontoDif = eMOnto - vDisponible;
        
        IF vMontoDif > vMtoAplic THEN
            LET vMontoCom = vMtoAplic;
        ELSE
            LET vMontoCom = vMontoDif;
        END IF;
    ELIF vFormaAplic = "4" THEN 
        LET vMontoCom = eMOnto; -- Aclaraciones
    END IF;

    -- 
    IF vRangos = "S" THEN
        IF vMontoCom < vRangoMin OR vMontoCom > vRangoMax THEN
            LET vMontoCom = vMtoAplic;
        END IF;
    END IF;

    IF vGenIva = "N" THEN 
        LET vValIva = 0;  
    END IF;

    IF vDisponible < (vMontoCom * (1 + vValIva)) THEN
        LET vMtoCom   = vMontoCom;
        LET vMontoCom = ROUND(vDisponible / (1 + vValIva),2);
        LET vMontoPen = vMtoCom - vMOntoCom;
		LET vIVA      = vDisponible - vMontoCom;
	ELSE
	    LET vIVA      = TRUNC((vMontoCom * vValIva),2);
    END IF;

--- 
	IF vDisponible > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;
	    -- 
		IF vDisponible > 0 THEN 
        CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranCom, "0000", eFolio, eCuenta, eCheque, vMontoCom, eDivisa, "", pNumTarjeta,"")
        RETURNING eCodRet, eComision;
        
        IF eCodRet <> "000" THEN
            LET eCodRet = '00001';
            RETURN eCodRet;
        END IF;
        
        -- 
        IF vGenIva = "S" THEN
        --RQM 09 704. Se ejecuta el siguiente SP para el calculo del saldo disponible DFTL 
        EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo(eCuenta, null, null, null, null, null, null, null, 'T', '1')     
        INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDisp;
---     
        IF cCodRetConsSdo <> '00000' THEN
            LET eCodRet = '420';
            RETURN eCodRet;
        END IF;

       IF vSdoDisp > 0 THEN 
	SELECT num_tarjeta INTO vNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
         WHERE secuencia = (select max(secuencia) FROM sc_tarjeta where cuenta = eCuenta) 
         and empresa = eEmpresa
         and cuenta = eCuenta;
		 LET pNumTarjeta = vNumTarjeta;
		 END IF;  
            IF vSdoDisp > 0 THEN
                CALL cargon_ref(eEmpresa, eSucursal, eUsuario, vTranIva, "0000", eFolio, eCuenta, eCheque, vIVA, eDivisa, "",pNumTarjeta,"")
                RETURNING eCodRet, eComision;
            END IF;
                
            IF eCodRet <> "000" THEN
                LET eCodRet = '00001';
                RETURN eCodRet;
            END IF;
        END IF;
    END IF;

    -- 
    IF vMontoPen > 0 THEN
        INSERT INTO sc_detcomis 
        VALUES(eEmpresa, eCuenta, vTranCom, vMontoPen  , 0, eHoy, "", "P", eFolio);

        UPDATE sc_maechq
           SET com_pendiente =  com_pendiente + vMontoPen
         WHERE empresa = eEmpresa
           AND cuenta  = eCuenta;
    END IF;

    RETURN eCodRet;

END PROCEDURE

DOCUMENT
'Esta funcion se encarga de realizar los movimientos de cargo por ',
'concepto de comisiones e iva de las mismas',
'AUTOR : Procesaminto Interactivo S.A. Axl',
'FECHA : 28/01/2010',
'BD : bdicheq ',
'CLIENTE : Todos',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/03',
'RAZON:                 Se agrega la nueva variable saldo_sbc (inmovilizacion por concepto de credito)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFICO:              Donovan Fernando Torres Landeros',
'FECHA:                 10-02-2026',
'MODIFICACION:          Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:              RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:                    BDICHEQ',
'VERSION:               1.3';

create procedure "informix".cobintcomsbg(pempresa   char(3),
                                         pcuenta    char(20),
                                         pfolio_suc char(16),
                                         pusuario   char(8),
                                         psucursal  char(4))
returning char(5);

    define vcodret                      char(5);
    define vimpiva                      money(14,2);
    define vtransacc,vtraniva           char(4);
    define vtasaiva                     decimal (6,3);
    define vsqlerr,vrowid               integer;
    define vsuccta                      char(4);
    define vfecha_hoy                   date;
    define vfechacalendario             date;
    define vimp_int_ccc,vimp_sbg_ccc,
           vsdo_retenido,vsdo_cong,
           vsdo_actual,vsdo_disp,
           vtotcobro,vimp_chq_sbg,
           vimp_int_sbg,vimpcobro,
           vsdo_comision                money(14,2);
    define vreferencia                  char(20);
    define vproducto                    char(4);
    define vnumcgos                     smallint;
    define vhora datetime               hour to fraction(3);
    define vestado_com                  char(1);
    define vnum_tarjeta                 char(16);
    define vmaxsec                      smallint;
    define vtasabaseiva                 decimal(6,3);
    define vstatus_cta                  char(1);
	
	DEFINE cCodRetIndicador				CHAR(6);
	define vfecha_operacion             date;
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC			MONEY(14,2); --Monto del saldo invomilizado (Salvo Buen Cobro).
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
		

    let vcodret     = "000";
    let vreferencia = " ";
	
	LET cCodRetIndicador  = "000000";
	LET vfecha_operacion = TODAY;
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC			= 0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	
    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret;
        end if;
    end exception;
	
	--set debug file to '/informix/moha/cobintcomsbg.out';
	--trace on;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    set optimization high;
--    set pdqpriority 1;

    select {+INDEX(sc_fechas idx_fechas1)}
           fecha_hoy 
      into vfechacalendario
      from sc_fechas 
     where empresa = pempresa;

    select fecha_proceso, status_cta
      into vfecha_hoy, vstatus_cta
      from sc_maechq
     where empresa = pempresa
       and cuenta = pcuenta;

    if (vfecha_hoy is null or vstatus_cta = '4' or vstatus_cta = '5')then
        let vfecha_hoy = vfechacalendario;
    end if       

    if (vfecha_hoy < vfechacalendario ) then
        let vcodret = "549";
        return  vcodret;
    end if  
    
    if ( vstatus_cta in('2','6','7','8') ) then
        let vcodret = "549";
        return  vcodret;
    end if  

	--RQM 09 704.Se agregan la variable del saldo inmovilizado. DHG
    select sucursal,producto,imp_int_ccc,imp_sbg_ccc,sdo_retenido,
           sdo_cong, sdo_actual,saldo_sbc,imp_chq_sbg, imp_int_sbg
      into vsuccta,vproducto,vimp_int_ccc,vimp_sbg_ccc,vsdo_retenido,
           vsdo_cong,vsdo_actual,mSaldoSBC,vimp_chq_sbg, vimp_int_sbg
      from sc_maechq
     where empresa = pempresa 
       and cuenta = pcuenta;

    if vsuccta is null then
        let vcodret = "100";
        return vcodret;
    end if

    select iva 
      into vtasaiva
      from bdinteg:si_sucursales
     where empresa = pempresa 
       and sucursal = vsuccta;
       
    if vtasaiva is null then
        let vtasaiva = 0;
    end if;

    select valor 
      into vtasabaseiva
      from bdinteg:si_param
     where empresa = pempresa 
       and cod_param = 47;

    select max(secuencia) 
      into vmaxsec
      from sc_tarjeta
     where empresa = pempresa 
       and cuenta = pcuenta 
       and tipo_tarjeta = "T";

    select num_tarjeta 
      into vnum_tarjeta
      from sc_tarjeta
     where empresa = pempresa 
       and cuenta = pcuenta 
       and secuencia = vmaxsec;

    -- // Cobra interes de linea de credito
	--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
	EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vsdo_retenido,vsdo_cong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdo_disp;        	
	--let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong;

    -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
        IF cCodRetConsSdo <> '00000' THEN
            let vcodret = '420';    -- Suma de montos erronea.
            RETURN vcodret;
        END IF;  

    let vnumcgos = 0;
    
    if vimp_int_ccc > 0 and vsdo_disp > 0 then
        let vimpiva = vimp_int_ccc * vtasaiva;
        let vtotcobro  = vimp_int_ccc + vimpiva;
        
        if vsdo_disp >= vtotcobro  then
            let vimpcobro = vimp_int_ccc;
        else
            let vimpcobro = vsdo_disp / (vtasaiva + 1);
            let vimpiva = vsdo_disp - vimpcobro;
            let vtotcobro = vimpcobro + vimpiva;
        end if
        
        select valor 
          into vtransacc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranintccc";
        
        if vtasaiva <> vtasabaseiva then
            select trancivaesp 
              into vtransacc -- tran intccc c/iva al 10%
              from bdinteg:si_transacc
             where empresa = pempresa 
               and numero = vtransacc;
        end if 
        
        let vhora = current hour to fraction;
        
        insert into sc_movdia
        values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhora,vtransacc,vsuccta,vproducto,pempresa,pcuenta," ",0,
                vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
				
		EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,vtransacc,vimpcobro,vfecha_hoy,"C")
		INTO cCodRetIndicador;
                
        let vsdo_actual = vsdo_actual - vimpcobro;
        let vnumcgos = vnumcgos + 1;
        
        if vimpiva > 0 then
            select valor 
              into vtraniva
              from sc_param
             where empresa = pempresa 
               and codparam = "tranivaccc";
               
            if vtasaiva <> vtasabaseiva then
                select trancivaesp 
                  into vtraniva -- tran ivaintccc al 10%
                  from bdinteg:si_transacc
                 where empresa = pempresa 
                   and numero = vtraniva;
            end if 
            
            let vhora = current hour to fraction;
            
            insert into sc_movdia
            values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy, vhora,vtraniva,vsuccta,vproducto,
                    pempresa,pcuenta," ",0,vimpiva,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
                    
            let vnumcgos = vnumcgos + 1;
        end if
        
        let vsdo_actual = vsdo_actual - vimpiva;
        
        update sc_maechq
           set sdo_actual = sdo_actual - vtotcobro,
               imp_int_ccc = imp_int_ccc - vimpcobro,
               imp_cgos_mes = imp_cgos_mes + vtotcobro,
               num_cgos_mes = num_cgos_mes + vnumcgos
         where empresa = pempresa 
           and cuenta = pcuenta;
    end if

    -- // Cobra interes por sobregiro
	--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
	let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong - mSaldoSBC;
    let vnumcgos = 0;
    
    if vimp_int_sbg > 0 and vsdo_disp > 0 then
        let vimpiva = vimp_int_sbg * vtasaiva;
        let vtotcobro  = vimp_int_sbg + vimpiva;
        
        if vsdo_disp >= vtotcobro  then
            let vimpcobro = vimp_int_sbg;
        else
            let vimpcobro = vsdo_disp / (vtasaiva + 1);
            let vimpiva = vsdo_disp - vimpcobro;
            let vtotcobro = vimpcobro + vimpiva;
        end if
        
        select valor 
          into vtransacc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranintsbg";
           
        if vtasaiva <> vtasabaseiva then
            select trancivaesp 
              into vtransacc -- tran intsbg c/iva al 10%
              from bdinteg:si_transacc
             where empresa = pempresa 
               and numero = vtransacc;
        end if 
        
        let vhora = current hour to fraction;
        
        insert into sc_movdia
        values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhora,vtransacc,vsuccta,vproducto,pempresa,pcuenta," ",0,
                vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
				
		EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,vtransacc,vimpcobro,vfecha_hoy,"C")
		INTO cCodRetIndicador;
                
        let vsdo_actual = vsdo_actual - vimpcobro;
        let vnumcgos = vnumcgos + 1;
        
        if vimpiva > 0 then
            select valor 
              into vtraniva
              from sc_param
             where empresa = pempresa 
               and codparam = "tranivasbg";
               
            if vtasaiva <> vtasabaseiva then
                select trancivaesp 
                  into vtraniva  -- tranivasbg al 10%
                  from bdinteg:si_transacc
                 where empresa = pempresa 
                   and numero = vtraniva;
            end if
            
            let vhora = current hour to fraction;
            
            insert into sc_movdia
            values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy, vhora,vtraniva,vsuccta,vproducto,
                    pempresa,pcuenta," ",0,vimpiva,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
                    
            let vnumcgos = vnumcgos + 1;
        end if
        
        let vsdo_actual = vsdo_actual - vimpiva;
        
        update sc_maechq
           set sdo_actual = sdo_actual - vtotcobro,
               imp_int_sbg = imp_int_sbg - vimpcobro,
               imp_cgos_mes = imp_cgos_mes + vtotcobro,
               num_cgos_mes = num_cgos_mes + vnumcgos
         where empresa = pempresa 
           and cuenta = pcuenta;
    end if

    -- // Cobra comisiones pendientes
	--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
    let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong - mSaldoSBC;
    
    if vsdo_disp > 0 then
        foreach
            select dc.rowid,monto_com-pago_com,transacc_com,transacc_iva
              into vrowid,vsdo_comision,vtransacc,vtraniva
              from sc_detcomis dc, sc_comisiones co
             where dc.empresa = pempresa 
               and cuenta = pcuenta 
               and estado_com = "P" 
               and dc.empresa = co.empresa 
               and dc.comision = co.comision
               
            let vnumcgos = 0;
            
			--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
            select sdo_actual,sdo_retenido,sdo_cong,saldo_sbc
              into vsdo_actual,vsdo_retenido,vsdo_cong,mSaldoSBC
              from sc_maechq
             where empresa = pempresa 
               and cuenta = pcuenta;
               
			--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
			EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vsdo_retenido,vsdo_cong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdo_disp;        	

            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
            IF cCodRetConsSdo <> '00000' THEN
                let vcodret = '420';    -- Suma de montos erronea.
                RETURN vcodret;
            END IF;  

            if vsdo_comision > 0 and vsdo_disp > 0 then
                let vimpiva = vsdo_comision * vtasaiva;
                let vtotcobro  = vsdo_comision + vimpiva;
                
                if vsdo_disp >= vtotcobro  then
                    let vimpcobro = vsdo_comision;
                    let vestado_com = "A";
                else
                    let vimpcobro = vsdo_disp / (vtasaiva + 1);
                    let vimpiva = vsdo_disp - vimpcobro;
                    let vtotcobro = vimpcobro + vimpiva;
                    let vestado_com = "P";
                end if
                
                let vhora = current hour to fraction;
                
                if vtasaiva <> vtasabaseiva then
                    select trancivaesp 
                      into vtransacc -- tran comision al 10%
                      from bdinteg:si_transacc
                     where empresa = pempresa 
                       and numero = vtransacc;
                    
                    select trancivaesp 
                      into vtraniva -- tran ivacom al 10%
                      from bdinteg:si_transacc
                     where empresa = pempresa 
                       and numero = vtraniva;
                end if
                
                insert into sc_movdia
                values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy, vhora,vtransacc,vsuccta,vproducto,
                        pempresa,pcuenta," ",0,vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
                        
                let vsdo_actual = vsdo_actual - vimpcobro;
                let vnumcgos = vnumcgos + 1;
                
                if vimpiva > 0 then
                    let vhora = current hour to fraction;
                    
                    insert into sc_movdia
                    values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy, vhora,vtraniva,vsuccta,vproducto,pempresa,
                            pcuenta," ",0,vimpiva,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
                        
                    let vnumcgos = vnumcgos + 1;
                end if
                
                let vsdo_actual = vsdo_actual - vimpiva;
                
                update sc_maechq
                   set sdo_actual = sdo_actual - vtotcobro,
                       com_pendiente = com_pendiente - vimpcobro,
                       imp_cgos_mes = imp_cgos_mes + vtotcobro,
                       num_cgos_mes = num_cgos_mes + vnumcgos
                 where empresa = pempresa 
                   and cuenta = pcuenta;
                   
                update sc_detcomis
                   set pago_com = pago_com + vimpcobro,
                       fecult_pago = vfecha_hoy,
                       estado_com = vestado_com
                 where rowid = vrowid;
            end if
        end foreach
    end if

    -- // Cobra linea de credito
	--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
	let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong - mSaldoSBC;
    
    if vimp_sbg_ccc > 0 and vsdo_disp > 0 then
        let vtotcobro  = vimp_sbg_ccc;
        
        if vsdo_disp >= vtotcobro  then
            let vimpcobro = vimp_sbg_ccc;
        else
            let vimpcobro = vsdo_disp;
            let vimpiva = vsdo_disp - vimpcobro;
            let vtotcobro = vimpcobro;
        end if
        
        select valor 
          into vtransacc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranpagoccc";
           
        let vhora = current hour to fraction;
        
        insert into sc_movdia
        values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhora,vtransacc,vsuccta,vproducto,pempresa,pcuenta," ",0,
                vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
				
		EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,vtransacc,vimpcobro,vfecha_hoy,"C")
		INTO cCodRetIndicador;
                
        let vsdo_actual = vsdo_actual - vimpcobro;
        
        update sc_maechq
           set sdo_actual = sdo_actual - vtotcobro,
               imp_sbg_ccc = imp_sbg_ccc - vimpcobro,
               imp_cgos_mes = imp_cgos_mes + vtotcobro,
               num_cgos_mes = num_cgos_mes + 1
         where empresa = pempresa 
           and cuenta = pcuenta;
    end if

    -- // Cobra sobregiro
	--RQM 09 704.Se agrega el valor del saldo inmovilizado en el calculo del saldo disponible. 
	let vsdo_disp = vsdo_actual - vsdo_retenido - vsdo_cong - mSaldoSBC;
    
    if vimp_chq_sbg > 0 and vsdo_disp > 0 then
        let vimpiva = vimp_chq_sbg;
        let vtotcobro  = vimp_chq_sbg;
        
        if vsdo_disp >= vtotcobro  then
            let vimpcobro = vimp_chq_sbg;
        else
            let vimpcobro = vsdo_disp;
            let vimpiva = vsdo_disp - vimpcobro;
            let vtotcobro = vimpcobro;
        end if
        
        select valor 
          into vtransacc
          from sc_param
         where empresa = pempresa 
           and codparam = "tranpagosbg";
           
        let vhora = current hour to fraction;
        
        insert into sc_movdia
        values (0,pfolio_suc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,vhora,vtransacc,vsuccta,vproducto,pempresa,pcuenta," ",0,
                vimpcobro,0,0,0,0," ",vstatus_cta,vsdo_actual," ",vreferencia,0,vnum_tarjeta,"","",vfecha_operacion);
				
		EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(psucursal,pcuenta,vtransacc,vimpcobro,vfecha_hoy,"C")
		INTO cCodRetIndicador;
                
        let vsdo_actual = vsdo_actual - vimpcobro;
        
        update sc_maechq
           set sdo_actual = sdo_actual - vtotcobro,
               imp_chq_sbg = imp_chq_sbg - vimpcobro,
               imp_cgos_mes = imp_cgos_mes + vtotcobro,
               num_cgos_mes = num_cgos_mes + 1
         where empresa = pempresa 
           and cuenta = pcuenta;
    end if
    
    return vcodret;
    
    end;
    
end procedure
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 11-06-2025',
'MODIFICACION: Se modifican las formulas de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2',
'MODIFICO:         Donovan Fernando Torres Landeros',
'FECHA:            10-02-2026',
'MODIFICACION:     Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO:         RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:               BDICHEQ',
'VERSION:          1.3';

create procedure "informix".cobracom(pempresa   char(3),
                                      psucursal  char(4),
                                      pusuario   char(8),
                                      ptransacc  char(4),
                                      pfolio_suc char(16),
                                      pcuenta    char(20))
   returning char(5);

   define vcodret char(5);
   define vsqlerr integer;
   define vfecha_hoy date;
   define vsdodisp money(14,2);
   define vstatus_cta char(1);
   --RQM 09 704. Se agregan las siguientes variable DFTL 
   define mSdoActual      money(14,2);
   define mSdoRetenido        money(14,2);
   define mSdoCongelado       money(14,2);
   define mSaldoSbc       MONEY(14,2);
   define cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
   define cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.


   let vcodret = "000";
   --RQM 09 704. Se agregan las siguientes variable DFTL
   let mSdoActual         = 0;
   let mSdoRetenido           = 0;
   let mSdoCongelado          = 0;
   let mSaldoSbc           = 0;
   let cCodRetConsSdo      = '00000';
   let cMensajeRetConsSdo  = '';

   --SET DEBUG FILE TO "/home/c90402536/Traza/cobracom_modif.out";
   --TRACE ON; 

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret;
      end if
   end exception;

   select fecha_hoy into vfecha_hoy
      from sc_fechas where empresa = pempresa;

   select status_cta, sdo_actual, sdo_retenido, sdo_cong, saldo_sbc
      into vstatus_cta, mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc
      from sc_maechq
      where empresa = pempresa and cuenta = pcuenta;

   --RQM 09 704. Se executa el siguiente SP para el calculo del saldo disponible DFTL 
   EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, null, null, null, 'F', '2') 
   INTO cCodRetConsSdo, cMensajeRetConsSdo, vsdodisp; 
   
   -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      IF cCodRetConsSdo <> '00000' THEN
         let vcodret = '420';    -- Suma de montos erronea.
         RETURN vcodret;
      END IF;  

   if vstatus_cta is null then
      let vcodret = "100";
      return vcodret;
   end if;

   if vstatus_cta in("2","6","7") then
      let vcodret = "200";
      return vcodret;
   end if;

   call gencomtran(pempresa,pcuenta,ptransacc,pfolio_suc,0,
                   psucursal,pusuario) returning vcodret;

   if vcodret = "000" and vsdodisp > 0 then
      call cobintcomsbg(pempresa,pcuenta,pfolio_suc,pusuario,psucursal)
                        returning vcodret;
   end if
   return vcodret;
end;
end procedure
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/06/16',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO: RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFIC0:              Donovan F. Torres Landeros',
'FECHA:                 10-02-2026',
'MODIFICACION:          Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'                       cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:              RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.3';

create procedure "informix".consultmovs_bf1(pempresa   char(3),
                                            pcuenta    char(20),
                                            psecuencia smallint)

returning char(5),date,char(40),money(14,2),money(14,2),money(14,2);

    define vtransacc        char(40);
    define vfecha           date;
    define vmonto           money(14,2);
    define vsdoactual       money(14,2);
    define vsdodisp         money(14,2);
    define vserial          integer;
    define vconta           smallint;
    define vciclo           smallint;
    define vcodret          char(5);
    define vsqlerr          integer;
    define vnaturaleza      char(1);
    define vultmovto        smallint;
    define cFech_param      CHAR(10);
    define cFech_param_ini  CHAR(10);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
	  define cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	  define cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	  --RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
    define mSdoRetenido  money(14,2);
    define mSdoCong      money(14,2);
    define mSaldoSbc     money(14,2);

    let vcodret    = "000";
    let vtransacc  = " ";
    let vfecha     = " ";
    let vmonto     = 0;
    let vsdoactual = 0;
    let vsdodisp   = 0;
    let vciclo     = 0;
    let vultmovto  = 5;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
	  let cCodRetConsSdo		= '00000';
	  let cMensajeRetConsSdo	= '';
	  --RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
    let mSdoRetenido  = 0.00;
    let mSdoCong      = 0.00;
    let mSaldoSbc     = 0.00;		

    begin
    
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp;
        end if;
    end exception;
    
    SET ISOLATION TO DIRTY READ;

    --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
    select mc.sdo_actual, mc.sdo_retenido, mc.sdo_cong, mc.saldo_sbc
      into vsdoactual, mSdoRetenido, mSdoCong, mSaldoSbc
      from sc_maechq mc
     where mc.empresa = pempresa 
       and mc.cuenta = pcuenta;
    
    --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vsdoactual, mSdoRetenido, mSdoCong, mSaldoSbc, null, null, null, 'F', 2) 
    INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdodisp;

    -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
    IF cCodRetConsSdo <> '00000' THEN
        let vsdoactual = 0;
        let vsdodisp = 0;
        let vcodret = '420';    -- Suma de montos erronea.
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp;
    END IF;  
       
    if vsdoactual is null then
        let vsdoactual = 0;
        let vsdodisp = 0;
        let vcodret = "100";
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp;
    end if;
    
    -- // Extrae los ultimos 5 movimientos
    foreach
        select md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza
          into vfecha, vserial, vmonto, vtransacc, vnaturaleza
          from sc_movdia md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.cancelad not in("V","S") 
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
         order by fech_alt desc, num_serial desc
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp with resume;
    end foreach;
    
    SELECT valor
      INTO cFech_param
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'fechcon_movhis';
       
    SELECT valor
      INTO cFech_param_ini
      FROM bdicheq:sc_param
     WHERE empresa = pempresa
       AND codparam = 'FechIniCon_movhis_ol';
    
    foreach
        select {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
               md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza
          into vfecha,vserial,vmonto,vtransacc,vnaturaleza
          from sc_movhis md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
        union all
        select {+INDEX(bdicheq:sc_movhis_old movhis1)}
               md.fech_alt, md.num_serial, md.monto_tot, md.transacc||" "||tr.descripcion, tr.naturaleza
          from sc_movhis_old md,
               bdinteg:si_transacc tr
         where md.empresa = pempresa 
           and md.cuenta = pcuenta 
           and md.fech_alt >= cFech_param_ini
           and md.fech_alt < cFech_param
           and md.cancelad not in("V","S") 
           and md.transacc = tr.numero
           and tr.empresa = md.empresa 
           and tr.numero = md.transacc 
           and tr.se_emite_edocta = "S"
         order by md.fech_alt desc, md.num_serial desc
         
        let vciclo = vciclo + 1;
        
        if vciclo > vultmovto then
            exit foreach;
        end if;
        
        if vmonto < 0 then
            let vtransacc = "REV "||trim(vtransacc);
        end if;
        
        if vnaturaleza = "C" then
            let vmonto = (vmonto * (-1));
        end if;
        
        return vcodret, vfecha, vtransacc, vmonto, vsdoactual, vsdodisp with resume;
    end foreach;
    
    end;
    
end procedure

DOCUMENT
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_cobrosbg(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vfecha           DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsucursal        CHAR(4);  
    DEFINE vproducto        CHAR(4);
    DEFINE vsuc_cta         CHAR(4);
    DEFINE vsdo_actual      MONEY(18,2);    
    DEFINE vsdo_retenido    MONEY(18,2);    
    DEFINE vsdo_cong        MONEY(18,2);    
    DEFINE vimp_chq_sbg     MONEY(18,2);    
    DEFINE vsdo_disp        MONEY(18,2);
	DEFINE cCodRetIndicador	CHAR(6);
    DEFINE vstatus_cta      CHAR(1);
	DEFINE vfecha_operacion DATE;
	--RQM 09 704. Se agregan las variables para el llamado y retorno de consulta de saldo. DHG.
	DEFINE mSaldoSBC			MONEY(14,2); --Monto del saldo invomilizado (Salvo Buen Cobro).
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    
    LET vcodret1	 = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vfecha  = '';
    LET vhora   = '';
    LET vfolio  = '';
    LET vcuenta       = '';
    LET vsucursal     = '9250';
    LET vproducto     = '';
    LEt vsuc_cta      = '';
    LET vsdo_actual   = 0.00;
    LET vsdo_retenido = 0.00;
    LET vsdo_cong     = 0.00;
    LET vimp_chq_sbg  = 0.00;
    LET vsdo_disp     = 0.00;
	LET cCodRetIndicador  = "000000";
    LET vstatus_cta = '';
	LET vfecha_operacion = TODAY;
	--RQM 09 704. Se inicializan las variables para el llamado y retorno de consulta de saldo. DHG.
	LET mSaldoSBC			= 0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobrosbg.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobrosbg.out";
    --- TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
	--RQM 09 704.Se agrega la variable del saldo inmovilizado para el calculo del saldo disponible.DHG
        SELECT cuenta, producto, sucursal, sdo_actual, sdo_retenido, sdo_cong, saldo_sbc, imp_chq_sbg, status_cta
          INTO vcuenta, vproducto, vsuc_cta, vsdo_actual, vsdo_retenido, vsdo_cong , mSaldoSBC, vimp_chq_sbg, vstatus_cta
          FROM sc_maechq
         WHERE status_cta NOT IN('2','6','7','8')
           AND imp_chq_sbg > 0.00
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
		--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
		EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vsdo_retenido,vsdo_cong,mSaldoSBC,0.00,0.00,0.00,'F',2) INTO cCodRetConsSdo,cMensajeRetConsSdo,vsdo_disp;
        --LET vsdo_disp = vsdo_actual - (vsdo_retenido + vsdo_cong);
        
		-- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      	IF cCodRetConsSdo <> '00000' THEN
        	let vsdo_disp = 0;
            let vcodret1 = '420';    -- Suma de montos erronea.
            CONTINUE FOREACH;
      	END IF;  

        IF vsdo_disp > 0.00 THEN
        
            IF vsdo_disp >= vimp_chq_sbg THEN

                INSERT INTO sc_movdia VALUES
                ( 0, vfolio, vsucursal, "informix", vfecha, vfecha, vhora, '3247', vsuc_cta, vproducto, pempresa, vcuenta, 
                  " ", 0, vimp_chq_sbg, 0, 0, 0, 0, " ", vstatus_cta, vsdo_actual, '0000', "COBRO PENDIENTE DE SOBREGIRO", 0, " ", "informix", "", vfecha_operacion);
                  
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF ven_transacc = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    CONTINUE FOREACH;
                END IF;
				
				-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(vsucursal,vcuenta,"3247",vimp_chq_sbg,vfecha,"C")
				INTO cCodRetIndicador;
                
                UPDATE sc_maechq
                   SET sdo_actual  = sdo_actual - vimp_chq_sbg,
                       imp_chq_sbg = 0.00
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
            ELIF vsdo_disp < vimp_chq_sbg THEN
            
                INSERT INTO sc_movdia VALUES
                ( 0, vfolio, vsucursal, "informix", vfecha, vfecha, vhora, '3247', vsuc_cta, vproducto, pempresa, vcuenta, 
                  " ", 0, vsdo_disp, 0, 0, 0, 0, " ", vstatus_cta, vsdo_actual, '0000', "COBRO PENDIENTE DE SOBREGIRO", 0, " ", "informix" , "", vfecha_operacion);
                  
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF ven_transacc = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    CONTINUE FOREACH;
                END IF;
				
				-- LLAMADO AL SP QUE GENERA LOS INDICADORES DE CAPTACION
				EXECUTE PROCEDURE "informix".sp_actualizar_indicadores(vsucursal,vcuenta,"3247",vsdo_disp,vfecha,"C")
				INTO cCodRetIndicador;
                
                UPDATE sc_maechq
                   SET sdo_actual  = sdo_actual - vsdo_disp,
                       imp_chq_sbg = imp_chq_sbg - vsdo_disp
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
            END IF;
        
            LET vcontador2 = vcontador2 + 1;
            
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta       = '';
        LET vproducto     = '';
        LEt vsuc_cta      = '';
        LET vsdo_actual   = 0.00;
        LET vsdo_retenido = 0.00;
        LET vsdo_cong     = 0.00;
        LET vimp_chq_sbg  = 0.00;
        LET vsdo_disp     = 0.00;
        LET vstatus_cta   = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE
DOCUMENT
'MODIFICO: Daniel Hernandez Garcia',
'FECHA: 11-06-2025',
'MODIFICACION: Se modifica la forma de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.2',
'MODIFICO: Donovan Fernando Torres Landeros',
'FECHA: 09-09-2025',
'MODIFICACION: Se agrega la validacion del codigo de retorno no exitoso(diferente de 00000)', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDICHEQ',
'VERSION: 1.3',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.4';

CREATE PROCEDURE "informix".sp_corrige_isr( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5), INTEGER, INTEGER;
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE iContador1       INTEGER;
    DEFINE iContador2       INTEGER;
    DEFINE dFechaHoy        DATE;
    DEFINE iAnio            INTEGER;
    DEFINE iResiduo         INTEGER;
    DEFINE iAnioBase        INTEGER;
    DEFINE dTasaISR         DECIMAL(9,6);
    DEFINE dTasa_ISR        DECIMAL(9,6);
    DEFINE cCuenta          CHAR(20);
    DEFINE cProducto        CHAR(4);
    DEFINE mSdoAcum         DECIMAL(18,2);
    DEFINE iDias            SMALLINT;
    DEFINE mIsrCobrado      DECIMAL(18,2);
    DEFINE mSdoPromedio     DECIMAL(18,2);
    DEFINE mBaseExenta      DECIMAL(18,2);
    DEFINE mBaseGravable    DECIMAL(18,2);
    DEFINE mISRCalculado    DECIMAL(14,2);
    DEFINE mDiferenciaISR   DECIMAL(14,2);
    DEFINE cHora            CHAR(15);
    DEFINE cFolio           CHAR(16);
    DEFINE cSucursal        CHAR(4);
    DEFINE cStatusCta       CHAR(1);
    DEFINE cMotivo          CHAR(2);
    DEFINE mSdoActual       DECIMAL(14,2);
    DEFINE mSdoRetenido     DECIMAL(14,2);
    DEFINE mSdoCongelado    DECIMAL(14,2);
    DEFINE mImpChqSbg       DECIMAL(14,2);
    DEFINE mSdoDisponible   DECIMAL(14,2);
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo   CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agrega la variable mSaldoSbc para la consulta del campo en la maestra de cheques. EEAP.
    DEFINE mSaldoSbc            MONEY(14,2);
    
    LET cCodRet1        = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET iTransacc       = 0;
    LET iContador1      = 0;
    LET iContador2      = 0;
    LET dFechaHoy       = '01/01/1900';
    LET iAnio           = 0;
    LET iResiduo        = 0;
    LET iAnioBase       = 0;
    LET dTasaISR        = 0.000000;
    LET dTasa_ISR       = 0.000000;
    LET cCuenta         = '';
    LET cProducto       = '';
    LET mSdoAcum        = 0.00;
    LET iDias           = 0;
    LET mIsrCobrado     = 0.00;
    LET mSdoPromedio    = 0.00;
    LET mBaseExenta     = 0.00;
    LET mBaseGravable   = 0.00;
    LET mISRCalculado   = 0.00;
    LET mDiferenciaISR  = 0.00;
    LET cHora           = '';
    LET cFolio          = '';
    LET cSucursal       = '';
    LET cStatusCta      = '';
    LET cMotivo         = '';
    LET mSdoActual      = 0.00;
    LET mSdoRetenido    = 0.00;
    LET mSdoCongelado   = 0.00;
    LET mImpChqSbg      = 0.00;
    LET mSdoDisponible  = 0.00;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo    = '00000';
    LET cMensajeRetConsSdo  = '';
    --RQM 09 704. Se inicializa la variable mSaldoSbc para el campo retornado de la maestra de cheques. EEAP.
    LET mSaldoSbc           = 0.00;
  
  BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrige_isr.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, iContador1, iContador2;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrige_isr.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO dFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
    
    SELECT valor 
    INTO mBaseExenta
      FROM sc_param
   WHERE empresa = pempresa 
     AND codparam = "baseexenta"; 

  IF mBaseExenta is null THEN
    LET mBaseExenta = 0;
  END IF;
       
    LET iAnio = YEAR(pFecha);
    LET iResiduo = MOD(iAnio,4);
    
    IF iResiduo <> 0 THEN
        LET iAnioBase = 365;
    ELSE
        LET iAnioBase = 366;
    END IF;
    
    SELECT valor
      INTO dTasaISR
      FROM bdinteg:si_fechavalor
     WHERE empresa = pEmpresa 
       AND tasa = "I.S.R." 
       AND fecha = ( SELECT MAX(fecha) 
                       FROM bdinteg:si_fechavalor
                      WHERE empresa = pEmpresa 
                        AND tasa = "I.S.R."
                        AND fecha < pFecha );
                        
    LET cHora = CURRENT HOUR TO FRACTION;
    LET cFolio = 'informix'||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
    
    FOREACH WITH HOLD
        --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
        SELECT {+INDEX(sc_maehis maehis_ffin)}
               his.cuenta, his.producto, his.acum_sdo_pos, his.dia_sdo_pos, his.totisrcobrado,
               mae.sucursal, mae.status_cta, mae.motivo, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.saldo_sbc
          INTO cCuenta, cProducto,  mSdoAcum, iDias, mIsrCobrado,
               cSucursal, cStatusCta, cMotivo, mSdoActual, mSdoRetenido, mSdoCongelado, mImpChqSbg, mSaldoSbc
          FROM sc_maehis his,
               sc_maechq mae
         WHERE his.fechafin = pFecha
           AND his.cuenta = mae.cuenta
           AND his.totisrcobrado <> 0.00
           AND his.producto <> '1200'
           AND mae.cuenta NOT IN(SELECT cuenta FROM sc_movdia WHERE transacc = '3277')
           --- AND mae.status_cta in('1','3','4','5')
        
        BEGIN WORK;
        
        LET iTransacc = 1;
               
        LET mSdoPromedio = mSdoAcum / iDias;
        
        LET mBaseGravable = mSdoPromedio - mBaseExenta;
        
        LET dTasa_ISR = TRUNC( ( ( ( dTasaISR / 100 ) * iDias ) / iAnioBase ), 6 );
        
        --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
        EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, mImpChqSbg, null, null, 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdoDisponible;
    
    -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
        IF cCodRetConsSdo <> '00000' THEN
          ROLLBACK WORK; 
          LET iTransacc = 0;  
          CONTINUE FOREACH;
        END IF;  


        IF mBaseGravable > 0 THEN
        
            LET mISRCalculado = TRUNC( (mBaseGravable * dTasa_ISR ), 2);
            
            LET mDiferenciaISR = mISRCalculado - mIsrCobrado;
        
            IF ( mDiferenciaISR > 0 AND cStatusCta IN('1','4','5') AND ( mSdoDisponible >= mDiferenciaISR ) ) THEN
                INSERT INTO sc_movdia VALUES
                ( 0, cFolio, cSucursal, 'informix', dFechaHoy, dFechaHoy, current, '3277', cSucursal, cProducto, pEmpresa, cCuenta, '', 
                  0, mDiferenciaISR, mDiferenciaISR, 0.00, 0.00, 0, '', cStatusCta, mSdoActual, '0000', '', 0, '', '', '', dFechaHoy );
                  
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual - mDiferenciaISR,
                       imp_cgos_mes = imp_cgos_mes + mDiferenciaISR,
                       num_cgos_mes = num_cgos_mes + 1
                 WHERE cuenta = cCuenta;   
                
                LET iContador2 = iContador2 + 1;
            END IF;
            
            UPDATE sc_maehis
               SET totisrcobrado = mIsrCobrado + mDiferenciaISR
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fechafin = pFecha;
            
        ELIF mBaseGravable < 0 THEN
            
            LET mDiferenciaISR = mIsrCobrado;
            
            IF ( mDiferenciaISR > 0 AND cStatusCta IN('1','4','5') ) THEN
                INSERT INTO sc_movdia VALUES
                ( 0, cFolio, cSucursal, 'informix', dFechaHoy, dFechaHoy, current, '0242', cSucursal, cProducto, pEmpresa, cCuenta, '', 
                  0, mDiferenciaISR, mDiferenciaISR, 0.00, 0.00, 0, '', cStatusCta, mSdoActual, '0000', '', 0, '', '', '', dFechaHoy );
                  
                UPDATE sc_maechq
                   SET sdo_actual = sdo_actual + mDiferenciaISR,
                       imp_abonos_mes = imp_abonos_mes + mDiferenciaISR,
                       num_abonos_mes = num_abonos_mes + 1
                 WHERE cuenta = cCuenta;   
                
                LET iContador2 = iContador2 + 1;
            END IF;
            
            UPDATE sc_maehis
               SET totisrcobrado = mIsrCobrado - mDiferenciaISR
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fechafin = pFecha;
            
        END IF;
        
        LET iContador1 = iContador1 + 1;
        
        COMMIT WORK;
        
        LET iTransacc = 0;
        
        LET cCuenta         = '';
        LET cProducto       = '';
        LET mSdoAcum        = 0.00;
        LET iDias           = 0;
        LET mIsrCobrado     = 0.00;
        LET cSucursal       = '';
        LET cStatusCta      = '';
        LET cMotivo         = '';
        LET mSdoActual      = 0.00;
        LET mSdoRetenido    = 0.00;
        LET mSdoCongelado   = 0.00;
        LET mImpChqSbg      = 0.00;
        LET mSdoPromedio    = 0.00;
        LET mBaseGravable   = 0.00;
        LET dTasa_ISR       = 0.000000;
        LET mSdoDisponible  = 0.00;
        LET mISRCalculado   = 0.00;
        LET mDiferenciaISR  = 0.00;
    END FOREACH;
    
    END;
    
    RETURN cCodRet1, iContador1, iContador2;
    
END PROCEDURE

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_marcactasinactivas_3anios( pEmpresa char(3) )
RETURNING CHAR(5)  AS vCodRet1, 
          CHAR(5)  AS vCodRet2, 
          CHAR(50) AS vCodRet3, 
          INTEGER  AS vContador1, 
          INTEGER  AS vContador2,  
          INTEGER  AS vContador3,
          INTEGER  AS vContador4;
      
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vComienza        INTEGER;
    DEFINE vEnTransacc     SMALLINT;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vContador3       INTEGER;
    DEFINE vContador4       INTEGER;
    
    DEFINE vSql                 CHAR(500);
    DEFINE vStmt                CHAR(250);
    DEFINE vFechaHoy            DATE;
    DEFINE vDiasInformada       INTEGER;
    DEFINE vDiasConcentrada     INTEGER;
    DEFINE vDiasTraspasada      INTEGER;
    DEFINE vTrxCargoConcen      CHAR(4);
    DEFINE vTrxCargoTrasp       CHAR(4);
    DEFINE vTrxAbonoConcen      CHAR(4);
    DEFINE vCtaConcentradora    CHAR(20);
    DEFINE vCtaMinima           CHAR(20);
    DEFINE vCtaMaxima           CHAR(20);
    DEFINE vCuenta              CHAR(20);
    DEFINE vStatusCta           CHAR(1);
    DEFINE vSucursal            CHAR(4);
    DEFINE vSdoActual           DECIMAL(18,2);
    DEFINE vSdoRetenido         DECIMAL(18,2);
    DEFINE vSdoCongelado        DECIMAL(18,2);
    DEFINE vSdoSobregirado      DECIMAL(18,2);
    DEFINE vSdoDispCuenta       DECIMAL(18,2);
    DEFINE vFechaUltimoDep      DATE;
    DEFINE vFechaUltimoRet      DATE;
    DEFINE vFechaAlta           DATE;
    DEFINE vFechaCompara        DATE;
    DEFINE vDiasSinTransacc     INTEGER;
    DEFINE vHora                CHAR(15);
    DEFINE vFolio               CHAR(16);
    DEFINE vCodRetCargo         CHAR(5);
    DEFINE vCodRetAbono         CHAR(5);
    DEFINE vTransaccRetCargo    CHAR(4);
    DEFINE vFechaRetCargo       DATE;
    DEFINE vSdoDispCargo        DECIMAL(18,2);
    DEFINE vMontoRetCargo       DECIMAL(18,2);
    DEFINE vNomProducto         CHAR(40);
    DEFINE vNumCliente          CHAR(20);
    DEFINE vNumTarjeta          CHAR(16);
    DEFINE vNombreCliente       CHAR(104);
    
    -- RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. LEOC.
    DEFINE cCodRetConsSdo               CHAR(5);    -- Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo           CHAR(50);   -- Mensaje de retorno de SP de consulta de saldo.
    DEFINE mSaldoSbc                    MONEY(14,2);    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vComienza    = -1;
    LET vEnTransacc = 0;
    LET vContador1   = 0;
    LET vContador2   = 0;
    LET vContador3   = 0;
    LET vContador4   = 0;
    
    LET vSql              = '';
    LET vStmt             = '';
    LET vFechaHoy         = '';
    LET vDiasInformada    = 0;
    LET vDiasConcentrada  = 0;
    LET vDiasTraspasada   = 0;
    LET vTrxCargoConcen   = '';
    LET vTrxCargoTrasp    = '';
    LET vTrxAbonoConcen   = '';
    LET vCtaConcentradora = '';
    LET vCtaMinima        = '';
    LET vCtaMaxima        = '';
    LET vCuenta           = '';   
    LET vStatusCta        = '';
    LET vSucursal         = '';
    LET vSdoActual        = 0.00;
    LET vSdoRetenido      = 0.00;
    LET vSdoCongelado     = 0.00;
    LET vSdoSobregirado   = 0.00;
    LET vSdoDispCuenta    = 0.00;
    LET vFechaUltimoDep   = '';
    LET vFechaUltimoRet   = '';
    LET vFechaAlta        = '';
    LET vFechaCompara     = '';
    LET vDiasSinTransacc  = 0;
    LET vHora             = '';
    LET vFolio            = '';
    LET vCodRetCargo      = '';
    LET vCodRetAbono      = '';
    LET vTransaccRetCargo = '';
    LET vFechaRetCargo    = '';
    LET vSdoDispCargo     = 0.00;
    LET vMontoRetCargo    = 0.00;
    LET vNomProducto      = '';
    LET vNumCliente       = '';
    LET vNumTarjeta       = '';
    LET vNombreCliente    = '';

    -- RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. LEOC.
    LET cCodRetConsSdo      = '00000';
    LET cMensajeRetConsSdo  = '';
    LET mSaldoSbc           =0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactasinactivas_3anios.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2, vContador3, vContador4;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_marcactasinactivas_3anios.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasinactivas3anios') THEN
        DROP TABLE "informix".ctasinactivas3anios;
    END IF;
    
    CREATE TABLE "informix".ctasinactivas3anios
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctainact ON "informix".ctasinactivas3anios(cuenta) USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE ctasinactivas3anios;
    
    LET vSql = 'echo "LOAD FROM /resplogifx/conciliachq/ctasinactivas3anios.unl DELIMITER ''","'' INSERT INTO ctasinactivas3anios" > /resplogifx/conciliachq/cargactas.sql';
    SYSTEM vSql;
    LET vSql = '';
    
    LET vStmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargactas.sql';

    SYSTEM vStmt;
    LET vStmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasinactivas3anios;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicheq:"informix".sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS INFORMADAS
    SELECT valor::INT
      INTO vDiasInformada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaInformada';
    
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS CONCENTRADAS
    SELECT valor::INT
      INTO vDiasConcentrada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaConcentrad';
       
    -- // OBTIENE EL NUMERO DE DIAS INICIALES PARA CUENTAS CONCENTRADAS
    SELECT valor::INT
      INTO vDiasTraspasada
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasIniCtaTraspasada';
       
    -- // OBTIENE TRANSACCION PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargoConcen
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxCgoCtaConcentrada';
       
    -- // OBTIENE TRANSACCION PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargoTrasp
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxCgoCtaTraspasada';
        
    -- // OBTIENE TRANSACCION PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxAbonoConcen
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxAboCtaConcentrada';
       
    -- // OBTIENE LA CUENTA CONCENTRADORA PARA TRASPASOS POR INACTIVIDAD
    SELECT valor
      INTO vCtaConcentradora
      FROM bdicheq:"informix".sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'CtaConcentradorArt61';
       
    -- // OBTIENE EL NUMERO CUENTA MINIMA Y MAXIMA
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vCtaMinima, vCtaMaxima
      FROM ctasinactivas3anios;

    FOREACH WITH HOLD
        SELECT cuenta
          INTO vCuenta
          FROM ctasinactivas3anios
         WHERE cuenta BETWEEN vCtaMinima AND vCtaMaxima
          
        IF vComienza = -1 THEN
            LET vComienza = 0;
            LET vEnTransacc = 1;
            BEGIN WORK;
        END IF;    
        
        LET vContador1 = vContador1 + 1;

        -- // OBTIENE INFORMACION DE LA CUENTA
        SELECT mae.status_cta, mae.sucursal, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, 
               mae.imp_chq_sbg, mae.fecultdep, mae.fecultret, noc.fecha_alta, pro.nombre, mae.num_cte, mae.saldo_sbc
          INTO vStatusCta, vSucursal, vSdoActual, vSdoRetenido, vSdoCongelado, 
               vSdoSobregirado, vFechaUltimoDep, vFechaUltimoRet, vFechaAlta, vNomProducto, vNumCliente, mSaldoSbc
          FROM bdicheq:"informix".sc_maechq mae,
               bdicheq:"informix".sc_maenoc noc,
               bdicheq:"informix".sc_producto pro
         WHERE mae.empresa = pEmpresa
           AND mae.cuenta = vCuenta
           AND noc.empresa = mae.empresa
           AND noc.cuenta = mae.cuenta
           AND pro.empresa = mae.empresa
           AND pro.producto = mae.producto;
           
        -- // VALIDA EL STATSU DE LA CUENTA
        IF vStatusCta IN('2','3','5','6') THEN
            ROLLBACK WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
        END IF;
        
        -- // OBTIENE  FECHA DE ULTIMO DEPOSITO
        IF vFechaUltimoDep is null OR vFechaUltimoDep = '' THEN
            LET vFechaUltimoDep = vFechaAlta;
        END IF;
        
        -- // OBTIENE  FECHA DE ULTIMO RETIRO
        IF vFechaUltimoRet is null OR vFechaUltimoRet = '' THEN
            LET vFechaUltimoRet = vFechaAlta;
        END IF;
        
        -- // OBTIENE FECHA MAS RECIENTE SIN TRANSACCIONAR
        IF vFechaUltimoRet >= vFechaUltimoDep THEN
            LET vFechaCompara = vFechaUltimoRet;
        ELSE
            LET vFechaCompara = vFechaUltimoDep;
        END IF;
        
        LET vDiasSinTransacc = vFechaHoy - vFechaCompara;
        
        -- // MARCA LA CUENTA DEPENDIENDO LA INACTIVIDAD DE LA MISMA
        IF ( vDiasSinTransacc < vDiasInformada ) THEN
        
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
           
        ELIF ( vDiasSinTransacc >= vDiasInformada AND vDiasSinTransacc < vDiasConcentrada ) THEN
        
            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '5', motivo = '14'
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta;
               
            LET vContador2 = vContador2 + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
            
        ELIF ( vDiasSinTransacc >= vDiasConcentrada AND vDiasSinTransacc < vDiasTraspasada ) THEN
        
            LET vHora = CURRENT HOUR TO FRACTION;
            LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
            -- LET vSdoDispCuenta = vSdoActual - (vSdoRetenido + vSdoCongelado + vSdoSobregirado);
            -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
            EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo(NULL, vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, NULL, NULL, 'F', 1) INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDispCuenta;

			      -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		  IF cCodRetConsSdo <> '00000' THEN
         		   CONTINUE FOREACH;
      		  END IF;  
            
            IF vSdoDispCuenta > 0.00 THEN 
                CALL cargo_ref( pEmpresa, vSucursal, 'informix', vTrxCargoConcen, '0000', vFolio, 
                                vCuenta, 0, vSdoDispCuenta, '01', 'CARGO CUENTA CONCENTRADA', '', '' ) 
                RETURNING vCodRetCargo, vTransaccRetCargo, vFechaRetCargo, vSdoDispCargo, vMontoRetCargo;
                
                IF vCodRetCargo = '000' THEN
                    CALL abono_ref( pEmpresa, vSucursal, 'informix', vTrxAbonoConcen, '0000', vFolio, vCtaConcentradora, 0, 
                                    vSdoDispCuenta, vSdoDispCuenta, 0, 0, 0, '01', 'TRASPASO CTA CONCENTRADA '||vCuenta, '', '' )
                    RETURNING vCodRetAbono;
                    
                    IF vCodRetAbono = '000' THEN
                        
                    END IF;
                END IF;
            END IF;
            
            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '6'
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta; 
            
            SELECT NVL(num_tarjeta, ' ')
              INTO vNumTarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND tipo_tarjeta = 'T'
               AND status_tar = 'A'
               AND secuencia = (SELECT MAX(secuencia)
                                  FROM bdicheq:"informix".sc_tarjeta
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vCuenta
                                   AND tipo_tarjeta = 'T'
                                   AND status_tar = 'A');
                                   
            SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
              INTO vNombreCliente
              FROM bdinteg:"informix".si_cliente
             WHERE numcte = vNumCliente;
               
            INSERT INTO bdicheq:"informix".sc_cuentas_concentradas
            (grupo, folio, producto, num_cte, cuenta, tarjeta, cliente, fech_ult_dep, fech_ult_ret, sdo_concentrado, fecha_concentra, int_sdo_concentra, pago_sdo_concentra, fecha_pago_concentra, int_trasp_beneficiencia, sdo_trasp_beneficiencia, fecha_trasp_benefic)
            VALUES
            (pEmpresa, vFolio, vNomProducto, vNumCliente, vCuenta, vNumTarjeta, vNombreCliente, vFechaUltimoDep, vFechaUltimoRet, vSdoDispCuenta, vFechaHoy, null, null, null, null, null, null);
            
            LET vContador3 = vContador3 + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
                    
        ELIF vDiasSinTransacc >= vDiasTraspasada THEN
        
            LET vHora = CURRENT HOUR TO FRACTION;
            LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
            -- LET vSdoDispCuenta = vSdoActual - (vSdoRetenido + vSdoCongelado + vSdoSobregirado);
            -- RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. LEOC
            EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo(NULL, vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, NULL, NULL, 'F', 1) INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoDispCuenta;
   
            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
         		CONTINUE FOREACH;
      		END IF;  


            UPDATE bdicheq:"informix".sc_maechq
               SET status_cta = '2', motivo = '14', fec_cancelac = vFechaHoy
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta; 
            
            SELECT NVL(num_tarjeta, ' ')
              INTO vNumTarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pEmpresa
               AND cuenta = vCuenta
               AND tipo_tarjeta = 'T'
               AND status_tar = 'A'
               AND secuencia = (SELECT MAX(secuencia)
                                  FROM bdicheq:"informix".sc_tarjeta
                                 WHERE empresa = pEmpresa
                                   AND cuenta = vCuenta
                                   AND tipo_tarjeta = 'T'
                                   AND status_tar = 'A');
                                   
            SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
              INTO vNombreCliente
              FROM bdinteg:"informix".si_cliente
             WHERE numcte = vNumCliente;
               
            INSERT INTO bdicheq:"informix".sc_cuentas_concentradas
            (grupo, folio, producto, num_cte, cuenta, tarjeta, cliente, fech_ult_dep, fech_ult_ret, sdo_concentrado, fecha_concentra, int_sdo_concentra, pago_sdo_concentra, fecha_pago_concentra, int_trasp_beneficiencia, sdo_trasp_beneficiencia, fecha_trasp_benefic)
            VALUES
            (pEmpresa, vFolio, vNomProducto, vNumCliente, vCuenta, vNumTarjeta, vNombreCliente, vFechaUltimoDep, vFechaUltimoRet, vSdoDispCuenta, vFechaHoy, null, null, null, null, null, null);
            
            LET vContador4 = vContador4 + 1;
            
            COMMIT WORK;
            BEGIN WORK;
            CONTINUE FOREACH;
            
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF vEnTransacc = 1 THEN
        LET vEnTransacc = 0;
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2, vContador3, vContador4;
    
END PROCEDURE
DOCUMENT
'AUTOR      : N/A',
'BD         : BDICHEQ',
'MODIFICO   : Luis Enrique Orozco Cosme',
'FECHA      : 7 de julio de 2025',
'MODIFICACION: Se modifica el calculo de saldo disponible para homologarlo con el llamado a un nuevo spl sp_cons_sdodisp_x_tpcalculo',
'PROYECTO   : RQM 09 704 Cobranza Automatica en Cuentas de Captacion',
'BD         : BDICHEQ',
'VERSION    : 1.0.1',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.0.2';

Create Procedure "informix".sp_proac_redondeoporcompra()
   returning Char(5), Char(50);

--//Definicion de variables
Define cMensajeRetRet char(50);
Define cCodRet        char(5);
Define isqlerr        integer;
Define iIsamErr       integer;
Define cErrorInfo     char(5);
Define cCuenta_eje    char(20);
Define cCuenta        char(20);
Define dFecha_hoy     date;
Define cMensajeRet    char(50);
Define cTransacCompra char(4);
DEFINE cTransacCompra2 char(4);
Define mMontoCompra   money(14,2);
Define mDecimal       money(18,5);
Define mExcedente     money(18,5);
Define cStatusEje     char(1);
Define mSaldoEje      money(14,2);
Define mRedondeo      money(18,5);
Define cStatusProac   char(1);
Define cTransacCargo  char(4);
Define cTransacAbono  char(4);
Define cSucursal      char(4);
Define cNumeroFolio   char(16);
Define cAceptab       char(1);
Define vusuario       char(8);
Define mSdodisp       money(14,2);
Define cCodRet_sp     char(5);
Define dUltima_ejec   Date;
Define cFolioRev      char(16);
Define cMontoMin      char(4);
Define dFechacargo    date;
--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
Define cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
Define cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
--RQM 09 704. Se agregan las variables para la consulta de los campos en la maestra de cheques. EEAP.
Define mSdoActual	 money(14,2);
Define mSdoRetenido  money(14,2);
Define mSdoCong      money(14,2);
Define mSaldoSbc     money(14,2);
 
--//Asignacion de variables
Let isqlerr = 0;
Let iIsamErr = 0;
Let cErrorInfo = '';
Let cCuenta_eje  = '';
Let cCuenta = '';
Let dFecha_hoy = '';
Let cMensajeRet = '';
Let cTransacCompra = '';
LET cTransacCompra2 = '';
Let mMontoCompra = 0;
Let mDecimal = 0;
Let mExcedente = 0;
Let cStatusEje = '';
Let mSaldoEje = 0;
Let mRedondeo = 0;
Let cStatusProac = '';
Let cTransacCargo = '';
Let cTransacAbono = '';
Let cSucursal = '';
Let cNumeroFolio = '';
let cAceptab = '' ;
let vusuario = user;
Let mSdodisp = 0;
Let cMensajeRetRet = '';
Let cCodRet = '';
Let cCodRet_sp = '000';
Let dUltima_ejec = '';
Let cFolioRev = '';
Let cMontoMin = '';
Let dFechacargo = '';
--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
Let cCodRetConsSdo		= '00000';
Let cMensajeRetConsSdo	= '';
--RQM 09 704. Se inicializan las variables los campos retornados de la maestra de cheques. EEAP.
Let mSdoActual	  = 0.00;
Let mSdoRetenido  = 0.00;
Let mSdoCong      = 0.00;
Let mSaldoSbc     = 0.00;	

--Set debug file to "/tmp/sp_PROAC_RedondeoPorCompra.out";
--trace on;

Begin

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet_sp= iSqlErr;
			LET cMensajeRetRet= cErrorInfo;
			ROLLBACK WORK;
			RETURN cCodRet_sp,cMensajeRetRet;
		END IF;
	END EXCEPTION;

	Let cCodRet_sp = '000';
	Let cMensajeRetRet = 'Proceso se ejecuto con exito: ';

	Select fecha_hoy
	Into dFecha_hoy
	From sc_fechas;

	--Valida que proceso no se ejecuto hoy
	If Exists(Select 1 from sc_proacprocesos where fecha_ejec = dfecha_hoy and proceso = 'Redondeo' ) then
		Let cCodRet_sp = '00100';
		Let cMensajeRet = 'Proceso ya ejecutado en fecha: ' || dfecha_hoy;
		Return cCodRet_sp, cMensajeRet;
	End if

	--Transac de Compra conciliada
	Select valor
	Into cTransacCompra
	From sc_param
	Where codparam = 'PROACTRANSCCOMPCONC';
    
    Select valor
	Into cTransacCompra2
	From sc_param
	Where codparam = 'PROACTRANSCCOMPINTE';

	--transac de cargo
	Select valor
	Into cTransacCargo
	From sc_param
	Where codparam = 'PROACTRANSACCCARGO';

	--transac de abono
	Select valor
	Into cTransacAbono
	From sc_param
	Where codparam = 'PROACTRANSACCABONO';
	
	-- monto minimo de compra
	Select valor
	Into cMontoMin
	From sc_param
	Where codparam = 'PROACCOMMAYOR'; 

	--Busca todas las cuentas existentes del programa
	FOREACH WITH HOLD
		Select cta_eje, cuenta, status_cta, sucursal
		Into cCuenta_eje, cCuenta, cStatusProac, cSucursal
		From sc_proac
		Where status_cta = '1'

		Let mMontoCompra = 0;

		--Busca todos los movimientos de la cuenta
		FOREACH WITH HOLD
			Select monto_tot
			Into mMontoCompra
			From sc_movdia
			Where empresa = '001'              --Index idx_movdia1a
			And cuenta = cCuenta_eje            			
			And transacc IN(cTransacCompra, cTransacCompra2)
		
			
			IF mMontoCompra <= cMontoMin then 
				Continue Foreach;			
			END IF		

			--Calculo Redondeo
			Let mRedondeo = 0;
			Let mRedondeo = mMontoCompra / 10;
			--'Let mMontoCompraEntero =  Round (mRedondeo -5); '
			Let mDecimal = trunc (mRedondeo, 5) - trunc (mRedondeo, 0);
			Let mExcedente = mDecimal * 100;
			Let mRedondeo = 100 - mExcedente;
			Let mRedondeo =  mRedondeo / 10;

			--Obtengo el saldo disponible
			--RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
			Select sdo_actual, sdo_cong, sdo_retenido, saldo_sbc, status_cta
			Into mSdoActual, mSdoCong, mSdoRetenido, mSaldoSbc, cStatusEje
			From sc_maechq
			Where empresa = '001'
			And Cuenta = cCuenta_eje;	

			--RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
    		EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCong, mSaldoSbc, null, null, null, 'F', 2) 
    		INTO cCodRetConsSdo,cMensajeRetConsSdo,mSdodisp;	

			-- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
         		CONTINUE FOREACH;
      		END IF;  

			If cStatusEje <> 1 Or cStatusProac <> 1 Or mSdodisp < mRedondeo Then
				Continue Foreach;
			End if;

			--Obtengo folio
			Call sp_generafolionomina ("informix") Returning cCodRet, cNumeroFolio;

			--Cargo (eje)
			Call cargo_ref('001', cSucursal, "informix", cTransacCargo, '0250', cNumeroFolio, cCuenta_eje, 0, mRedondeo, '01', 'Cargo x Redondeo ', '','')
			returning cCodRet,cTransacCargo,dFechacargo,mSaldoEje,mRedondeo ;
			
			Let cFolioRev = cNumeroFolio;

			If cCodRet  = '000'  Then
				--Obtengo folio
				Call sp_generafolionomina ("informix") Returning cCodRet, cNumeroFolio;

				--Abono (proac)
				Call abono_ref ('001', cSucursal, "informix", cTransacAbono,'0250', cNumeroFolio, cCuenta, 0 ,mRedondeo, mRedondeo, 0, 0, 0, '01', 'Abono x Redondeo', '0','')
				returning cCodRet;

				Let cMensajeRetRet = 'Proceso se ejecutado con exito: ';

				If cCodRet  <> '000'  Then
					--Reversion al cargo sp reverso();
					Call reversion ('001', cSucursal, "informix",cFolioRev, "C") Returning cCodRet;
					Call reversion ('001', cSucursal, "informix",cNumeroFolio, "C") Returning cCodRet;
					Continue foreach;
				End If

				--obtengo saldo de proac de maestro
				Select nvl(sdo_actual, 0)
				Into mSaldoEje
				From sc_maechq
				Where Cuenta = cCuenta;

				--actualizo nuevo saldo proac  con el del maestro
				Update sc_proac					
				Set saldo = mSaldoEje
				Where cta_eje = cCuenta_eje
				And status_cta = '1';				

			End If;
		End Foreach;
	End Foreach;

	-- Inserta registro de ejecusion
	Insert into sc_proacprocesos (proceso, status, fecha_ejec, hora_ejec) Values ('Redondeo','1',dFecha_hoy, current hour to fraction);
	RETURN cCodRet_sp,cMensajeRetRet;
	
End;
End Procedure
DOCUMENT
'AUTOR		: Yahaira Corona, Carmen orozco Ibarria',
'DESCRIPCION: Genera el proceso de redondeo en las cuentas afiliadas al PROAC',
'FECHA		: Febrero de 2009',
'VERSION	: 20090212',
'BD			: BDICHEQ',
'ModificÃ³	: Abigail Vasavilbazo CaÃ±edo',
'DESCRIPCION: Se cambio la variable para el redondeo',
'FECHA		: Marzo 2009',
'VERSION	: 200903',
'BD			: BDICHEQ',
'ModificÃ³	: Armando Mercado Figueroa',
'DESCRIPCION: Se cambio la consulta a los movimientos de la tabla historica por la tabla de movimientos del dia',
'FECHA		: Abril 2009',
'VERSION	: 200904',
'BD			: BDICHEQ',
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 09-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_verifctasdesconcentradas( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
       
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vTrxAbierta          SMALLINT;
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vFechaHoy            DATE;
    DEFINE vTrxCargo            CHAR(4);
    DEFINE vTrxAbono            CHAR(4);
    DEFINE vCtaNostro           CHAR(20);
    DEFINE vDiasDesConcentra    INTEGER;
    DEFINE vCuenta              CHAR(20);
    DEFINE vStatusCta           CHAR(1);
    DEFINE vSucursal            CHAR(4);
    DEFINE vNumCliente          CHAR(20);
    DEFINE vProducto            CHAR(4);
    DEFINE vSdoActual           DECIMAL(18,2);
    DEFINE vSdoRetenido         DECIMAL(18,2);
    DEFINE vSdoCongelado        DECIMAL(18,2);
    DEFINE vSdoSobregirado      DECIMAL(18,2);
    DEFINE vFechaUltimoDep      DATE;
    DEFINE vFechaUltimoRet      DATE;
    DEFINE vFechaDesConcentra   DATE;
    DEFINE vDiasSinTransacc     INTEGER;    
    DEFINE vSdoDispCuenta       DECIMAL(18,2);
    DEFINE vHora                CHAR(15);
    DEFINE vFolio               CHAR(16);
    DEFINE vHoraTrx             CHAR(15);
    DEFINE vProdNostro          CHAR(4);
    DEFINE vSucNostro           CHAR(4);
    DEFINE vSdoNostro           DECIMAL(18,2);
    DEFINE vInsTrxCargo         CHAR(1);
    DEFINE vUpdTrxCargo         CHAR(1);
    DEFINE vInsTrxAbono         CHAR(1);
    DEFINE vUpdTrxAbono         CHAR(1);
    DEFINE vUpdCuenta           CHAR(1);
    DEFINE vUpdConcen           CHAR(1);
    DEFINE vUpdCtaDesc          CHAR(1);
	DEFINE vFechaOperacion   	DATE;
    --RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. EEAP.
    DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
    --RQM 09 704. Se agrega la variable mSaldoSbc para la consulta del campo en la maestra de cheques. EEAP.
    DEFINE mSaldoSbc            MONEY(14,2);

    
    LET Sql_Err	            = 0;
    LET Isam_Err            = 0;
    LET Desc_Err            = '';
    LET vCodRet1            = '000';
    LET vCodRet2            = '000';
    LET vCodRet3            = '';
    LET vTrxAbierta         = 0;
    LET vContador1          = 0;
    LET vContador2          = 0;
    LET vFechaHoy           = '';
    LET vTrxCargo           = '';
    LET vTrxAbono           = '';
    LET vCtaNostro          = '';
    LET vDiasDesConcentra   = 0;
    LET vCuenta             = '';   
    LET vStatusCta          = '';
    LET vSucursal           = '';
    LET vNumCliente         = '';
    LET vProducto           = '';
    LET vSdoActual          = 0.00;
    LET vSdoRetenido        = 0.00;
    LET vSdoCongelado       = 0.00;
    LET vSdoSobregirado     = 0.00;
    LET vFechaUltimoDep     = '';
    LET vFechaUltimoRet     = '';
    LET vFechaDesConcentra  = '';
    LET vDiasSinTransacc    = 0;
    LET vSdoDispCuenta      = 0.00;
    LET vHora               = '';
    LET vFolio              = '';
    LET vHoraTrx            = '';
    LET vProdNostro         = '';
    LET vSucNostro          = '';
    LET vSdoNostro          = 0.00;
    LET vInsTrxCargo        = '0';
    LET vUpdTrxCargo        = '0';
    LET vInsTrxAbono        = '0';
    LET vUpdTrxAbono        = '0';
    LET vUpdCuenta          = '0';
    LET vUpdConcen          = '0';
    LET vUpdCtaDesc         = '0';
	LET vFechaOperacion   	= TODAY;
    --RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. EEAP.
    LET cCodRetConsSdo		= '00000';
    LET cMensajeRetConsSdo	= '';
    --RQM 09 704. Se inicializa la variable mSaldoSbc para el campo retornado de la maestra de cheques. EEAP.
    LET mSaldoSbc           = 0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifctasdesconcentradas.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_verifctasdesconcentradas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE TRANSACCION DE CARGO PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxCargo
      FROM sc_param
     WHERE empresa = pEmpresa
      AND codparam = 'TrxCgoCtaConcentrada';

    -- // OBTIENE TRANSACCION DE ABONO PARA CUENTAS CONCENTRADAS
    SELECT valor
      INTO vTrxAbono
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'TrxAboCtaConcentrada';

    -- // OBTIENE LA CUENTA CONCENTRADORA PARA TRASPASOS POR INACTIVIDAD
    SELECT valor
      INTO vCtaNostro
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'CtaConcentradorArt61';
     
    -- // OBTIENE EL NUMERO DE DIAS PARA VOLVER A CONCENTRAR
    SELECT valor::INT
      INTO vDiasDesConcentra
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'DiasCtasDesConcentra';
    
    FOREACH WITH HOLD
        -- // OBTIENE DATOS DE LA CUENTA A CONCENTRAR
        --RQM 09 704. Se agrega el campo saldo_sbc en la consulta. EEAP.
		SELECT mae.cuenta, mae.status_cta, mae.sucursal, mae.num_cte, mae.producto, 
               mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, 
               mae.fecultdep, mae.fecultret, con.fecha_pago_concentra, mae.saldo_sbc
          INTO vCuenta, vStatusCta, vSucursal, vNumCliente, vProducto, 
               vSdoActual, vSdoRetenido, vSdoCongelado, vSdoSobregirado, 
               vFechaUltimoDep, vFechaUltimoRet, vFechaDesConcentra, mSaldoSbc
          FROM sc_maechq mae,
               sc_cuentas_concentradas con
         WHERE mae.empresa = pEmpresa
           AND mae.status_cta = '8'
           AND con.cuenta = mae.cuenta
    
        BEGIN WORK;
        LET vTrxAbierta = 1;
        
        LET vContador1 = vContador1 + 1;
        
        LET vDiasSinTransacc = 0;
        LET vSdoDispCuenta   = 0;
        LET vInsTrxCargo     = '0';
        LET vUpdTrxCargo     = '0';
        LET vInsTrxAbono     = '0';
        LET vUpdTrxAbono     = '0';
        LET vUpdCuenta       = '0';
        LET vUpdConcen       = '0';
        LET vUpdCtaDesc      = '0';
        
        LET vDiasSinTransacc = vFechaHoy - vFechaDesConcentra;
        
		IF ( vDiasSinTransacc > vDiasDesConcentra ) THEN
            --RQM 09 704. Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion. EEAP
            EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, vSdoSobregirado, null, null, 'F', 1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vSdoDispCuenta;
			
            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
      		IF cCodRetConsSdo <> '00000' THEN
                ROLLBACK WORK;
                LET vTrxAbierta = 0;
         		CONTINUE FOREACH;
      		END IF;  
            
			IF vSdoDispCuenta > 0.00 THEN 
				LET vHora = CURRENT HOUR TO FRACTION;
				LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
			
				LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
            
                INSERT INTO sc_movdia VALUES
                ( 0, vFolio, '9250' , 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxCargo, vSucursal, vProducto, pEmpresa, vCuenta, '', 0, 
                  vSdoDispCuenta, 0.00, 0.00, 0.00, 0, '', '', vSdoActual, '0000' , 'CONCENTRACION POR INACTIVIDAD ART 61 LIC', 0, '', '', '', vFechaOperacion);
                  
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vInsTrxCargo = '1';
                END IF;
                
                UPDATE sc_maechq
                   SET sdo_actual   = sdo_actual - vSdoDispCuenta,
                       imp_cgos_mes = imp_cgos_mes + vSdoDispCuenta,
                       num_cgos_mes = num_cgos_mes + 1,
                       fec_ult_mov  = vFechaHoy
                 WHERE empresa = pEmpresa
                   AND cuenta = vCuenta; 
                   
                IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                    LET vUpdTrxCargo = '1';
                END IF;
                
                IF vInsTrxCargo = '1' AND vUpdTrxCargo = '1' THEN
                    SELECT producto, sucursal, sdo_actual
                      INTO vProdNostro, vSucNostro, vSdoNostro
                      FROM sc_maechq 
                     WHERE empresa = pEmpresa
                       AND cuenta = vCtaNostro;
                       
                    LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
                    
                    INSERT INTO sc_movdia VALUES
                    ( 0, vFolio, '9250', 'informix', vFechaHoy, vFechaHoy, vHoraTrx, vTrxAbono, vSucNostro, vProdNostro, pEmpresa, vCtaNostro, '', 0, 
                      vSdoDispCuenta, vSdoDispCuenta, 0.00, 0.00, 0, '', '', vSdoNostro, '0000', 'ABONO X CONCENTRACION DE CTA '||TRIM(vCuenta), 0, '', '', '', vFechaOperacion);
                              
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN 
                        LET vInsTrxAbono = '1'; 
                    END IF;
                    
                    UPDATE sc_maechq
                       SET sdo_actual = sdo_actual + vSdoDispCuenta,
                           imp_abonos_mes = imp_abonos_mes + vSdoDispCuenta, 
                           num_abonos_mes = num_abonos_mes + 1,
                           fec_ult_mov = vFechaHoy,
                           fecultdep = vFechaHoy
                     WHERE empresa = pEmpresa 
                       AND cuenta = vCtaNostro;
                                   
                    IF dbinfo('sqlca.sqlerrd2') > 0 THEN 
                        LET vUpdTrxAbono = '1'; 
                    END IF;
                    
                    IF vInsTrxAbono = '1' AND vUpdTrxAbono = '1' THEN
                        UPDATE sc_cuentas_concentradas
                           SET folio = vFolio,
                               sdo_concentrado = vSdoDispCuenta
                         WHERE cuenta = vCuenta;
                        
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdConcen = '1';
                        END IF;
                        
                        UPDATE sc_maechq
						   SET status_cta = '6'
						 WHERE empresa = pEmpresa
						   AND cuenta = vCuenta; 
                           
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdCuenta = '1';
                        END IF;
                        
                        INSERT INTO sc_ctasdescon_concentradas
                        ( num_cte, producto, cuenta, status_cta, sdo_actual, fech_ult_dep, fech_ult_ret, fecha_desmar, fecha_marc )
                        VALUES
                        ( vNumCliente, vProducto, vCuenta, vStatusCta, vSdoActual, vFechaUltimoDep, vFechaUltimoRet, vFechaDesConcentra, vFechaHoy );
                        
                        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                            LET vUpdCtaDesc = '1';
                        END IF;
                        
                        IF vUpdConcen = '1' AND vUpdCuenta = '1' AND vUpdCtaDesc = '1' THEN
                            LET vContador2 = vContador2 + 1;
                        ELSE
                            ROLLBACK WORK;
                            LET vTrxAbierta = '0';
                            CONTINUE FOREACH;
                        END IF;
                    ELSE
                        ROLLBACK WORK;
                        LET vTrxAbierta = '0';
                        CONTINUE FOREACH;
                    END IF;
                ELSE
                    ROLLBACK WORK;
                    LET vTrxAbierta = '0';
                    CONTINUE FOREACH;
                END IF;
            ELSE
                ROLLBACK WORK;
                LET vTrxAbierta = '0';
                CONTINUE FOREACH;
            END IF;
        ELSE
            ROLLBACK WORK;
            LET vTrxAbierta = '0';
            CONTINUE FOREACH;
        END IF; 
        
        COMMIT WORK;
        LET vTrxAbierta = '0';
    END FOREACH;
    
    END;
     
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1, vContador2;
     
END PROCEDURE

DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 01-07-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para agregar',
'               en su lugar la ejecucion de un SPL que realiza el calculo de forma interna',
'               eviando como parametros los campos retornados en la consulta a la maestra de cheques',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2',
'MODIFIC0:      Donovan F. Torres Landeros',
'FECHA:         10-02-2026',
'MODIFICACION:  Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:      RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD:            bdicheq',
'VER:           1.3';

CREATE PROCEDURE "informix".sp_actparampasecheq(pempresa CHAR(3))
RETURNING CHAR(5);
    
    --- ################################################################################
    --- ##  Nombre:              sp_actparampasecheq                                  ##
    --- ##  Version:             2.0                                                  ##
    --- ##  Objetivo:            Programa del pase contable de captacion              ##
    --- ##  Creado por:                                                               ##
    --- ##  Modificado por:      Ivan Escorza                                         ##
    --- ##  Ultima Modificacion: Marzo 2026                                           ##
    --- ################################################################################

    DEFINE vcodret       CHAR(5);
    DEFINE vcodret2      CHAR(5);
    DEFINE vcodret3      VARCHAR(50);
    DEFINE vsqlerr       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE error_info    VARCHAR(50);
    DEFINE vpromedio     INTEGER;
    DEFINE vcont         SMALLINT;
    DEFINE vbrinca       INTEGER;
    DEFINE vserial       INTEGER;
    DEFINE vparam_serial VARCHAR(60);
    
    LET vcodret          = "000";
    LET vcodret2         = "000";
    LET vcodret3         = " ";
    LET vsqlerr          = 0;
    LET isam_err         = 0;
    LET error_info       = '';
    LET vpromedio        = 0;
    LET vcont            = 0;
    LET vbrinca          = 0;
    LET vserial          = 0;
    LET vparam_serial    = '';
    
    BEGIN

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actparampasecheq.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    ---	SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_actparampasecheq.out";
    ---	TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

     SELECT ROUND(COUNT(*)/6)
      INTO vpromedio
      FROM bdicheq:sc_movdia_concil
	  WHERE num_serial > 0;  

    LET vcont = 1;  
    
    WHILE vcont <= 5         
        IF vcont = 1 THEN
            LET vbrinca = vpromedio;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0
                 ORDER BY num_serial 

                LET vparam_serial = vserial;
                
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom1';

            END FOREACH;

        ELIF vcont = 2 THEN
            LET vbrinca = vpromedio * 2;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial
 
                LET vparam_serial = vserial;
                 
                 UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom2';
 
            END FOREACH;

        ELIF vcont = 3 THEN
            LET vbrinca = vpromedio * 3;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0
                 ORDER BY num_serial

                LET vparam_serial = vserial;
    
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom3';
  
            END FOREACH;

        ELIF vcont = 4 THEN
            LET vbrinca = vpromedio * 4;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial
 
                LET vparam_serial = vserial;
     
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom4';

            END FOREACH;

        ELIF vcont = 5 THEN
            LET vbrinca = vpromedio * 5;

            FOREACH CurIni WITH HOLD FOR
				--Se quita el filtro de campo 'empresa', se tiene INDEX PATH
                SELECT SKIP vbrinca FIRST 1 num_serial
                  INTO vserial
                  FROM bdicheq:sc_movdia_concil
                 WHERE num_serial > 0 
                 ORDER BY num_serial

                LET vparam_serial = vserial;
                 
                UPDATE bdicheq:sc_param
                   SET valor = vparam_serial
                 WHERE codparam = 'SerialIniPaseChqCom5'; 
            END FOREACH;
        END IF;
        LET vcont = vcont + 1;  
        LET vserial = 0;
        LET vparam_serial = '';
    END WHILE;    

    RETURN vcodret;

    END;

END PROCEDURE;