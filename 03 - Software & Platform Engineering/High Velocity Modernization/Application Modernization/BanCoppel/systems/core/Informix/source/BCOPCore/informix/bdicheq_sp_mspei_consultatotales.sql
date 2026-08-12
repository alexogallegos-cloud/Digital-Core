CREATE PROCEDURE "informix".sp_mspei_consultatotales ()
RETURNING
	CHAR(6)				AS COD_RET,
	CHAR(60)			AS MENS_RET,
	INT8				AS NUM_OPER_LIQ,
	DECIMAL(14,2)		AS SUM_MONTO_LIQ,
	INT8				AS NUM_OPER_DEV,
	DECIMAL(14,2)		AS SUM_MONTO_DEV,
	INT8				AS NUM_OPER_LIQ2,
	DECIMAL(14,2)		AS SUM_MONTO_LIQ2,
	INT8				AS NUM_OPER_CANCELADA,
	DECIMAL(14,2)		AS SUM_MONTO_CANCELADA;
	
--DECLARACIONES
	DEFINE cCodRet		CHAR(6);
	DEFINE cMensajeRet	CHAR(80);
	DEFINE iNumLiq		INT8;
	DEFINE iNumDev		INT8;
	DEFINE dSumLiq		DECIMAL(14,2);
	DEFINE dSumDev		DECIMAL(14,2);
	DEFINE iNumLiq2		INT8;
	DEFINE iNumCanc		INT8;
	DEFINE dSumLiq2		DECIMAL(14,2);
	DEFINE dSumCanc		DECIMAL(14,2);
	DEFINE iSqlErr		INTEGER;
	DEFINE iIsamErr		INTEGER;
	DEFINE cErrorInfo	CHAR(80);
	DEFINE dtFechaHoy	DATE;

--INICIALIZACIONES

	LET cCodRet			= "000000";
	LET cMensajeRet		= "PROCESO EXITOSO";
	LET iNumLiq			= 0;
	LET iNumDev			= 0;
	LET dSumLiq			= 0.00;
	LET dSumDev			= 0.00;
	LET iNumLiq2		= 0;
	LET iNumCanc		= 0;
	LET dSumLiq2		= 0.00;
	LET dSumCanc		= 0.00;
	LET iSqlErr			= 0;
	LET iIsamErr		= 0;
	LET cErrorInfo		= "";
	LET dtFechaHoy		= DATE(1);

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN TRIM(cCodRet), TRIM(cMensajeRet), NVL(iNumLiq,0), NVL(dSumLiq,0.00), NVL(iNumDev,0), NVL(dSumDev,0.00), NVL(iNumLiq2,0), NVL(dSumLiq2,0.00), NVL(iNumCanc,0), NVL(dSumCanc,0.00);
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/armandomorales/sp_mspei_consultatotales.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SE CONSULTA LA FECHA DEL DIA.
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = "001";
		
	--HACE UN CONTEO Y SUMATORIA DEL CAMPO TRANSACCION DE LA SC_MOVDIA
	SELECT COUNT(Liquidadas), SUM(Liquidadas), COUNT(Devoluciones), SUM(Devoluciones), COUNT(Liquidadas2),SUM(Liquidadas2),COUNT(Canceladas), SUM(Canceladas)
	INTO iNumLiq, dSumLiq, iNumDev, dSumDev, iNumLiq2, dSumLiq2, iNumCanc, dSumCanc
	FROM TABLE (MULTISET ( 
		SELECT CASE WHEN mvd.transacc="0273" THEN mvd.monto_tot  END AS Liquidadas,
			  CASE WHEN mvd.transacc="0274" THEN mvd.monto_tot END AS Liquidadas2,
			  CASE WHEN mvd.transacc="0276" THEN mvd.monto_tot END AS Canceladas,
			  CASE WHEN mvd.transacc="0277" THEN mvd.monto_tot END AS Devoluciones								  
		FROM bdicheq:"informix".sc_movdia mvd, bdicheq:"informix".sc_maechq mae,bdinteg:"informix".si_transacc tran	
		WHERE mvd.transacc IN ("0274","0273","0276","0277")
		AND mvd.fech_val = dtFechaHoy
		AND mvd.cancelad <> 'S'	
		AND mvd.cuenta	= mae.cuenta
		AND mvd.transacc = tran.numero
		));
		
		--SI NO ENCUENTRA NINGUN REGISTRO MANDA MENSAJE DE ERROR.
	IF iNumLiq = 0 AND iNumDev = 0 AND iNumLiq2 = 0 AND iNumCanc = 0 THEN
		LET cCodRet = "000001";
		LET cMensajeRet = "NO HAY REGISTROS DE MOVIMIENTOS SPEI";
	END IF;
		
	RETURN TRIM(cCodRet), TRIM(cMensajeRet), NVL(iNumLiq,0), NVL(dSumLiq,0.00), NVL(iNumDev,0), NVL(dSumDev,0.00), NVL(iNumLiq2,0), NVL(dSumLiq2,0.00), NVL(iNumCanc,0), NVL(dSumCanc,0.00);
	
END
END PROCEDURE
DOCUMENT
'AUTOR : Armando Morales Barraza',
'DESCRIPCION: Se crea procedimeinto para que obtenga la información de las transacciones de SPEI agrupada por el tipo de transacción',
'			 (1.- Ordenes Recibidas:estado, número de operaciones y sumatoria de monto', 
'			 2.- Ordenes Enviadas:estado, número de operaciones y sumatoria de monto) y se retorna esta informacion',
'FECHA      : 18/Abril/2012',
'VERSION    : 20120418';

CREATE PROCEDURE "informix".sp_valida_monto_tras(pcEmpresa CHAR(3), pcCuenta CHAR(20), pcTransuc CHAR(4), pmTotTrans MONEY)
	RETURNING CHAR(6) AS CodRetorno, CHAR(4) AS CodMensaje;

--Definicion de Variables
DEFINE iSqlErr						INTEGER;
DEFINE cCodRet						CHAR(6);
DEFINE cCodMsj						CHAR(4);
DEFINE mMontoTot					MONEY(14,2);
--DEFINE iMontoMax					INTEGER;	--DSB 01/06/2012
DEFINE mMontoMax					MONEY(14,2);
DEFINE dFechaHoy					DATE;

--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '000000';
LET cCodMsj = '0000';
LET mMontoTot = 0;
LET mMontoMax = 0;
LET dFechaHoy = '01-01-1900';

--SET DEBUG FILE TO '/respaldosbd/joseluis/sp_valida_monto_tras.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCodMsj;
		END IF;
	END EXCEPTION;
	
	IF pcEmpresa = "" OR pcCuenta = "" OR pcTransuc = "" OR pmTotTrans = 0 THEN
		LET cCodRet = '110';
	ELSE
		SET LOCK MODE TO WAIT 3;
		--//Obtiene fecha del sistema de cheques
		SELECT fecha_hoy
		INTO dFechaHoy
		FROM bdicheq:"informix".sc_fechas
		WHERE empresa = pcEmpresa;
		
		SET LOCK MODE TO WAIT 3;
		--//Obtiene el monto total de las transacciones echas en el dia
		SELECT NVL(SUM(monto_tot),0) INTO mMontoTot
		FROM bdicheq:"informix".sc_movdia
		WHERE cuenta = pcCuenta AND fech_alt = dFechaHoy AND transacc_suc = pcTransuc AND transacc='0289' AND cancelad != 'S';
		
		SET LOCK MODE TO WAIT 3;
		--//Obtiene el monto maximo
		IF EXISTS(SELECT valor FROM bdicheq:"informix".sc_param WHERE codparam = 'montomaxtraspefectas') THEN
			--SELECT NVL(CAST(valor AS INTEGER),0) INTO iMontoMax		--DSB 01/06/2012
			SELECT NVL(CAST(valor AS MONEY(14,2)),0) INTO mMontoMax
			FROM bdicheq:"informix".sc_param WHERE codparam = 'montomaxtraspefectas';
		END IF;
		
		--//Comparacion del monto total con el monto maximo permitido
		--IF (mMontoTot > iMontoMax) OR (pmTotTrans > iMontoMax) THEN		--DSB 01/06/2012
		IF (pmTotTrans > mMontoMax) OR ((mMontoTot + pmTotTrans) > mMontoMax) THEN
			LET cCodMsj = '267';
		END IF;		
	END IF;
	RETURN cCodRet,cCodMsj;
END;

END PROCEDURE
DOCUMENT
'DESCRIPCION: Saca y compara el monto total de las transacciones echas en el dia, con el monto maximo permitido',
'AUTOR : Jose Luis Polanco B.',
'FECHA : 04/04/2012',
'VERSION: 1.0',
'BD: bdicheq',
'SISTEMA : Caja sucursal',
'FECHA : DSB 01/06/2012',
'DESCRIPCION: Se incluye la comparacion de la suma de operaciones y el monto de la transaccion en proceso, para que no sea mayor de lo permitido',
'Se cambia el tipo de dato del monto maximo permitido para hacer de buena forma la comparacion',
'AUTOR : Jose Luis Polanco B.';

CREATE PROCEDURE "informix".sp_actsdoctasconc( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
    
    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     CHAR(50);
    DEFINE vCodRet1     CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vcontador    INTEGER;
    DEFINE vcuenta      CHAR(20);
    DEFINE vfechaconc   DATE;
    DEFINE vsdo_actual  DECIMAL(16,2);
    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
    LET vCodRet2    = '000';
    LET vCodRet3    = 'PROCESO FINALIZADO CORRECTAMENTE';  
    LET vcontador   = 0;
    LET vcuenta     = '';
    LET vfechaconc  = '';
    LET vsdo_actual = 0.00;
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actsdoctasconc.err";
        --- TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1, vCodRet2, vCodRet3, vcontador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actsdoctasconc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    FOREACH WITH HOLD
        SELECT a.cuenta, a.fecha_concentra, b.sdo_actual
          INTO vcuenta, vfechaconc, vsdo_actual
          FROM sc_cuentas_concentradas a,
               sc_maechq b
         WHERE a.cuenta = b.cuenta
           AND a.fecha_concentra >= '08/03/2012'
           AND b.status_cta = '6'
           
        BEGIN WORK;
        
        UPDATE sc_maechq
           SET sdo_dia_ant = vsdo_actual
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
       
        IF vfechaconc = '08/03/2012' THEN
            UPDATE sc_sdodiarioc
               SET capvig3 = vsdo_actual,
                   capvig4 = vsdo_actual,
                   capvig5 = vsdo_actual,
                   capvig6 = vsdo_actual
             WHERE cuenta = vcuenta
               AND aniomes = '201208';
        END IF;
        
        IF vfechaconc = '08/06/2012' THEN
            UPDATE sc_sdodiarioc
               SET capvig6 = vsdo_actual
             WHERE cuenta = vcuenta
               AND aniomes = '201208';
        END IF;
           
        LET vcontador = vcontador + 1;
        
        COMMIT WORK;
        
        LET vcuenta = '';
        LET vfechaconc = '';
        LET vsdo_actual = 0.00;
    END FOREACH;
    
    END;
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vcontador;
    
END PROCEDURE;