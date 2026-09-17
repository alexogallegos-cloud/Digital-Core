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