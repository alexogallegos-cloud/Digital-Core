CREATE PROCEDURE "informix".sp_blqdesconcentractasinactivas( pEmpresa CHAR(3), pCuenta CHAR(20) )
RETURNING CHAR(5), CHAR(50);
    
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vFechaHoy        DATE;
    DEFINE vCuenta          CHAR(20);
    DEFINE vSdoConcentrado  DECIMAL(18,2);
    DEFINE vSucursal        CHAR(4);
    DEFINE vProducto        CHAR(4);
    DEFINE vStatus          CHAR(1);
    DEFINE vSdoActual       DECIMAL(18,2);
    DEFINE vHora            CHAR(15);
    DEFINE vFolio           CHAR(16);
    DEFINE vHoraTrx         CHAR(12);
    DEFINE vIsrCalc         DECIMAL(14,2);
    DEFINE vInsertaTransacc CHAR(1);
    DEFINE vActualizaMaechq CHAR(1);
	DEFINE vActualizaMaenoc CHAR(1);
    DEFINE vActualizaConcen CHAR(1);
    DEFINE vTrxAbierta      CHAR(1);
    DEFINE vNumCte          CHAR(20);
    DEFINE vFechaConcentra  DATE;
	DEFINE vFechaOperacion  DATE;
	DEFINE iAnio			SMALLINT;
	DEFINE iAniobase		SMALLINT;
	DEFINE dResiduo 		DECIMAL(6,2); 
	DEFINE vAcumSdoInt		DECIMAL(14,2);
	DEFINE cPfisica			CHAR(1);
	DEFINE cExento_isr		CHAR(1);
	DEFINE vIntsProvs		DECIMAL(14,2);
	DEFINE vPagoInts		DECIMAL(14,2);
	DEFINE dPorRetencionSuj	DECIMAL(9,6);
	DEFINE cTipoPersona		CHAR(1);
	DEFINE cSujRet			CHAR(1);
	DEFINE dPorRetSuj		DECIMAL(9,6);
	DEFINE mbase_exenta     DECIMAL(14,2);
	DEFINE iDias			SMALLINT;
	DEFINE mBase_gravable	DECIMAL(14,2);
	DEFINE vProd			CHAR(2);
	DEFINE vProdOrig		CHAR(4);
    DEFINE iNoAbonos        SMALLINT;
    DEFINE iNoCargos        SMALLINT;
    DEFINE vSdoIntIsr       DECIMAL(14,2);
    DEFINE cTpo_Persona     CHAR(2);
	
    LET Sql_Err	         = 0;
    LET Isam_Err         = 0;
    LET Desc_Err         = '';
    LET vCodRet1         = '000';
    LET vCodRet2         = '000';
    LET vCodRet3         = '';
    LET vFechaHoy        = '';
    LET vCuenta          = '';   
    LET vSdoConcentrado  = 0.00;
    LET vSucursal        = '';
    LET vProducto        = '';
    LET vStatus          = '';
    LET vSdoActual       = 0.00;
    LET vHora            = '';
    LET vFolio           = '';
    LET vHoraTrx         = '';
    LET vIsrCalc         = 0.00;
    LET vInsertaTransacc = '0';
    LET vActualizaMaechq = '0';
	LET vActualizaMaenoc = '0';
    LET vActualizaConcen = '0';
    LET vTrxAbierta      = '0';
    LET vNumCte          = '';
    LET vFechaConcentra  = '';
	LET vFechaOperacion  = TODAY;
	LET iAnio			 = 0;
	LET iAniobase        = 0;
	LET dResiduo         = 0.00;
	LET vAcumSdoInt		 = 0.00;
	LET cPfisica		 = '';
	LET cExento_isr      = '';
	LET vIntsProvs       = 0.00;
	LET vPagoInts        = 0.00;
	LET dPorRetencionSuj = 0.000000;
	LET cTipoPersona     = '';
	LET cSujRet          = '';
	LET dPorRetSuj       = 0.000000;
	LET mbase_exenta     = 0.00;
	LET iDias            = 0;
	LET mBase_gravable   = 0.00;
	LET vProd            = '';
	LET vProdOrig        = '';
    LET iNoAbonos        = 0;
    LET iNoCargos        = 0;
    LET vSdoIntIsr       = 0.00;
    LET cTpo_Persona     = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_blqdesconcentractasinactivas.sql.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vTrxAbierta = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_blqdesconcentractasinactivas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTINENE LA FECHA DE HOY
    SELECT fecha_hoy
      INTO vFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	 
   	-- // RSV NUEVA CONSULTA PARA ATENDER LA NUEVA FUNCIONALIDAD  
	SELECT con.cuenta, con.sdo_concentrado, mae.sucursal, mae.producto, mae.status_cta, mae.sdo_actual, 
    con.num_cte, con.fecha_concentra, noc.acum_sdo_int, cte.tpo_persona, tip.es_fisica, tip.exento_isr 
    INTO vCuenta, vSdoConcentrado, vSucursal, vProducto, vStatus, vSdoActual, 
    vNumCte, vFechaConcentra, vAcumSdoInt, cTpo_Persona, cPfisica, cExento_isr
    FROM sc_cuentas_concentradas con, sc_maechq mae, sc_maenoc noc, bdinteg:si_cliente cte,
    bdinteg:si_tipper tip
    WHERE con.cuenta = pCuenta
    AND mae.cuenta = con.cuenta 
    AND noc.cuenta = mae.cuenta
    AND cte.numcte = mae.num_cte
    AND tip.tpo_persona = cte.tpo_persona
    AND con.fecha_concentra = (SELECT MAX(fecha_concentra) FROM sc_cuentas_concentradas WHERE cuenta = pCuenta );
       
    IF vProducto = '5000' THEN
    
        -- // VALIDA QUE EXISTA LA CUENTA DE CHEQUES
        IF vCuenta is null OR vCuenta = '' OR vCuenta <> pCuenta THEN
            LET vCodRet1 = '100';
            LET vCodRet3 = 'LA CUENTA NO EXISTE. FAVOR DE VERIFICAR.';
            RETURN vCodRet1, vCodRet3;
        END IF; 
        
        -- // VALIDA QUE LA CUENTA SE ENCUENTRE CONCENTRADA
        IF vStatus is null OR vStatus = '' OR vStatus <> '6' THEN
            LET vCodRet1 = '202';
            LET vCodRet3 = 'STATUS DE LA CUENTA INCORRECTO. FAVOR DE VERIFICAR';
            RETURN vCodRet1, vCodRet3;
        END IF;
        
        IF vProducto is null OR vProducto = '' OR vProducto <> '5000' THEN
            LET vCodRet1 = '014';
            LET vCodRet3 = 'PRODUCTO DE LA CUENTA INCORRECTO. FAVOR DE VERIFICAR';
            RETURN vCodRet1, vCodRet3;
        END IF;
        
        BEGIN WORK;
        LET vTrxAbierta = '1';
        
        LET vHora = CURRENT HOUR TO FRACTION;
        LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
        
        -- // INSERTA TRANSACCION DE PROVISION DE INTERES FALTANTE
        IF vAcumSdoInt > 0.00 THEN
            LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
            
            INSERT INTO sc_movdia VALUES
            ( 0, vFolio, '9250' , 'informix', vFechaHoy, vFechaHoy, vHoraTrx, '3381', vSucursal, vProducto, pEmpresa, vCuenta, '', 0, 
              vAcumSdoInt, vAcumSdoInt, 0.00, 0.00, 0, '', vStatus, vSdoActual, '', 'PROVISION DE INTERESES', 0, '', '', '', vFechaOperacion);
        END IF;
        
        -- // CALCULA EL MONTO PARA EL PAGO DE INTERESES
        SELECT NVL(ints_prov_acum,0.00)
          INTO vIntsProvs
          FROM sc_cuentas_concentradas
         WHERE cuenta = vCuenta
           AND fecha_concentra = vFechaConcentra;
         
        LET vPagoInts = vIntsProvs + vAcumSdoInt;
        
        -- // PAGO DE INTERESES
        IF vPagoInts > 0.00 THEN
            LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
            
            INSERT INTO sc_movdia VALUES
            ( 0, vFolio, '9250' , 'informix', vFechaHoy, vFechaHoy, vHoraTrx, '3276', vSucursal, vProducto, pEmpresa, vCuenta, '', 0, 
              vPagoInts, vPagoInts, 0.00, 0.00, 0, '', vStatus, vSdoActual, '', 'PAGO DE INTERESES', 0, '', '', '', vFechaOperacion);
              
            LET iNoAbonos = iNoAbonos + 1;
        END IF;
        
        -- // DETERMINA COBRO DE ISR
        LET iAnio = year(vFechaHoy);
        LET dResiduo = mod(iAnio, 4);

        IF dResiduo = 0 THEN
            LET iAniobase = 366;
        ELSE
            LET iAniobase = 365;
        END IF;
        
        SELECT valor
          INTO dPorRetencionSuj
          FROM bdinteg:si_fechavalor
         WHERE tasa = 'I.S.R.'
           AND fecha = ( SELECT MAX(fecha) FROM bdinteg:si_fechavalor WHERE tasa = 'I.S.R.' );
           
        IF cPfisica = 'S' THEN
            LET cTipoPersona = 'F';
        ELSE
            LET cTipoPersona = 'M';
        END IF;
         
        IF cExento_isr = 'N' THEN
            LET cSujRet = 'S';
        ELSE
            LET cSujRet = 'N';
        END IF;
        
        IF cSujRet <> 'S' THEN
            LET dPorRetSuj = 0;
        ELSE
            LET dPorRetSuj = dPorRetencionSuj;
        END IF;
        
        SELECT valor 
          INTO mBase_exenta
          FROM sc_param
         WHERE empresa = pEmpresa
           AND codparam = "baseexenta";

        IF mBase_exenta is null THEN
            LET mbase_exenta = 0;
        END IF;
        
        LET iDias = vFechaHoy - vFechaConcentra;
        LET mBase_gravable = vSdoActual - mBase_exenta;
        
        IF dPorRetSuj <> 0 THEN
            IF cTipoPersona = 'F' THEN
                IF mBase_gravable > 0 THEN
                    LET vIsrCalc = (mBase_gravable * (dPorRetSuj/100)) * iDias / iAniobase;
                ELSE
                    LET vIsrCalc = 0;
                END IF;
            ELSE
                LET vIsrCalc = (vSdoActual * (dPorRetSuj/100)) * iDias / iAniobase;
            END IF;
        ELSE
            LET vIsrCalc = 0;
        END IF;
        
        IF vIsrCalc > 0 THEN
            LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
            
            INSERT INTO sc_movdia VALUES
            ( 0, vFolio, '9250', 'informix', vFechaHoy, vFechaHoy, vHoraTrx, '3277', vSucursal, vProducto, pEmpresa, vCuenta, 
              '', 0, vIsrCalc, 0.00, 0.00, 0.00, 0, '', vStatus, vSdoActual, '', 'COBRO DE ISR', 0, '', '', '', vFechaOperacion);
              
            LET iNoCargos = iNoCargos + 1;
        END IF;
        
        LET vSdoIntIsr = vSdoActual + (vPagoInts - vIsrCalc);
        
        -- // INSERTA TRANSACCION DE DESCONCENTRACION
        LET vHoraTrx = CURRENT HOUR TO FRACTION(3);
        
        INSERT INTO sc_movdia VALUES
        ( 0, vFolio, '9250', 'informix', vFechaHoy, vFechaHoy, vHoraTrx, '0416', vSucursal, vProducto, pEmpresa, vCuenta, '', 0, 
          vSdoIntIsr, vSdoIntIsr, 0.00, 0.00, 0, '', vStatus, vSdoActual, '0000', 'DESCONCENTRACION ART 61 LIC', 0, '', '', '', vFechaOperacion);
                  
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vInsertaTransacc                                                                                                                                                                          = '1';
        END IF;
             
        -- // ACTUALIZA TABLA DE CUENTAS CONCENTRADAS
        UPDATE sc_cuentas_concentradas
           SET ints_prov_acum = ints_prov_acum + vAcumSdoInt,
               pago_sdo_concentra = vSdoActual,
               int_sdo_concentra = vPagoInts,
               fecha_pago_concentra = vFechaHoy
         WHERE cuenta = vCuenta
           AND fecha_concentra = vFechaConcentra;
        
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vActualizaConcen = '1';
        END IF;
        
        -- // INICIALIZA ACUMULADOS
        UPDATE sc_maenoc
           SET dia_sdo_pos   = 0,
               acum_sdo_pos  = 0.00,
               int_acum      = 0.00,
               isr_acum      = 0.00,
               dias_acum_int = 0,
               acum_sdo_int  = 0.00
         WHERE cuenta = vCuenta;
         
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vActualizaMaenoc = '1';
        END IF;
        
        -- // ACTUALIZA EL ESTATUS Y EL PRODUCTO DE LA CUENTA
        LET vProd = SUBSTR(vCuenta,1,2);
        LET vProdOrig = DECODE( vProd, '10', '2000', '12', '1200', '13', '1300', '14', '1400', '15', '1500', '16', '1600', '17', '1700', '18', '1800', 
                                       '19', '1900', '22', '2200', '23', '2300', '24', '2400', '25', '2500', '26', '2600', '27', '2700', '28', '2800', 
                                       '29', '2900' );
         
        UPDATE sc_maechq
           SET status_cta = '1',
               producto = vProdOrig,
               fecha_proceso = vFechaHoy,
               sdo_actual = sdo_actual + (vPagoInts - vIsrCalc),
               num_abonos_mes = num_abonos_mes + iNoAbonos,
               imp_abonos_mes = imp_abonos_mes + vPagoInts,
               num_cgos_mes = num_cgos_mes + iNoCargos,
               imp_cgos_mes = imp_cgos_mes + vIsrCalc,
               fecultdep = vFechaHoy,
               fecultret = vFechaHoy,
               ultpagoint = vFechaHoy,
               fec_ult_mov = vFechaHoy
         WHERE cuenta = vCuenta; 
         
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vActualizaMaechq = '1';
        END IF;
        
        IF ( vInsertaTransacc = '1' AND vActualizaConcen = '1' AND vActualizaMaenoc = '1' AND vActualizaMaechq = '1' ) THEN
            COMMIT WORK;
            LET vTrxAbierta = '0';
            LET vCodRet1 = '000';
            LET vCodRet3 = 'CUENTA DESCONCENTRADA SATISFACTORIAMENTE';
        ELSE
            ROLLBACK WORK;
            LET vTrxAbierta = '0';
            LET vCodRet1 = '999';
            LET vCodRet3 = 'INSERCION O ACTUALIZACION NO SATISFACTORIOS';
            RETURN vCodRet1, vCodRet3;
        END IF;
        
    ELSE
    
        CALL sp_blqdesconcentractasinactivas_ant(pempresa, pcuenta)
        RETURNING vCodRet1, vCodRet3;
        
    END IF;
               
    END;
    
    RETURN vCodRet1, vCodRet3;
    
END PROCEDURE 

DOCUMENT
'DESCRIPCION: Proceso para realizar el regreso del saldo de la cuenta global a la cuenta de cheques, se modifico para hacer el reverso cuandio ocurra un error en el reverso', 
'MODIFICO: Mohamed CarreÃÂ³n ',
'FECHA: Marzo 2012',
'DESCRIPCION MODIFICACION: Se modifica el proceso para parametrizar los codigos de retorno y obtener sus mensajes correspondientes que estan en la tabla si_codret del sistema integral.',
'FECHA MODIFICACION: 20120509',
'NOMBRE MODIFCO: Mohamed CarreÃÂ³n',
'VERSION: 20120509.1820',
'DESCRIPCION MODIFICACION: Reingenieria del proceso de desconcentracion de cuentas inactivas ART 61 LIC',
'FECHA MODIFICACION: 20131001',
'NOMBRE MODIFCO: JICS',
'VERSION: 20131001.1400',
'BD: bdicheq',
'DESCRIPCION MODIFICACION: Reingenieria del proceso de desconcentracion de cuentas inactivas ART 61 LIC',
'FECHA MODIFICACION: 20190322',
'NOMBRE MODIFCO: JICS',
'VERSION: 20190603.1800',
'DESCRIPCION MODIFICACION: Se agrega el producto 2900',
'FECHA MODIFICACION: 2025-09-29',
'NOMBRE MODIFCO: RFR',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cobra_com(p_empresa CHAR(3),   --empresa
                                         p_cuenta  CHAR(20),  --cuenta a la cual se le realizra el cargo. 
										 p_folio   CHAR(16),  --folio de la operacion 
										 p_corres  CHAR(4))   --corresponsal
    RETURNING   CHAR(5);
       
    DEFINE vsqlerr          INTEGER;
    DEFINE iIsamErr         SMALLINT;
    DEFINE cErrorInfo       CHAR(80);
	DEFINE vErrorInfo       CHAR(80);
    DEFINE vCodRet          CHAR(5);
	DEFINE v_num_cte        CHAR(9);
	DEFINE v_exi_cte        INTEGER;
	DEFINE vValorIva        DECIMAL(9,6);
	DEFINE v_transacc       CHAR(4);
	DEFINE vTranCom         CHAR(4);
	DEFINE vCom_Ma_Iva      DECIMAL(14,2);
	DEFINE v_comision      DECIMAL(14,2);
	DEFINE vMontoIVA       DECIMAL(14,2);
	DEFINE v_comision_mas_iva DECIMAL (14,2);
	DEFINE v_sucursal    CHAR(4);
	DEFINE vUsuario      CHAR(8);
	DEFINE vHora         CHAR(12);
	DEFINE vFolio        CHAR(16);
	DEFINE vDivisa       CHAR(2);
	DEFINE vTranIva      CHAR(4);
	DEFINE vTranRet      CHAR(4);
	DEFINE v_ret1        CHAR(5);
    DEFINE v_ret2        CHAR(20);
    DEFINE v_ret3        CHAR(20);
    DEFINE v_ret4        CHAR(26);
    DEFINE v_ret5        CHAR(26);
    DEFINE v_ret6        CHAR(26);
    DEFINE v_ret7        CHAR(26);
    DEFINE v_ret8        CHAR(60);
    DEFINE v_ret9        CHAR(1);
    DEFINE v_ret10       MONEY(14,2);
    DEFINE v_ret11       MONEY(14,2);
    DEFINE v_ret12       MONEY(14,2);
    DEFINE v_ret13       MONEY(14,2);
    DEFINE v_ret14       MONEY(14,2);
    DEFINE v_ret15       CHAR(1);
    DEFINE v_ret16       CHAR(40);
    DEFINE v_ret17       CHAR(40); 
    DEFINE v_ret18       MONEY(14,2);
	DEFINE v_ret19       MONEY(14,2);
	DEFINE v_ret20       MONEY(14,2);
	DEFINE v_ret21       CHAR(8);
	DEFINE v_ret22       DATE;
	DEFINE v_ret23       CHAR(16);
	DEFINE v_ret24       CHAR(18);
	DEFINE dMontoAplica	 MONEY;
	DEFINE mMtoCom		 MONEY(14,2);
	DEFINE mMontoPen	 MONEY(14,2);
    DEFINE mIva			 MONEY(14,2);
	DEFINE cCodRetGF	 CHAR(3);
	DEFINE cFolioGF		 CHAR(16);

		
	   		
    LET vsqlerr             = 0; 
    LET iIsamErr            = 0;
    LET cErrorInfo          = "";   
    LET vErrorInfo          = "INICIO DEL PROCESO";
    LET vCodRet             = "00000";
	LET v_num_cte           = "";
	LET v_exi_cte           = 0;
	LET vValorIva           = 0;
	LET v_transacc          = 0;
	LET vTranCom            = '';
	LET vMontoIVA           = 0.00;
	LET v_comision_mas_iva  = 0.00;
	LET v_sucursal          = '';
	LET vUsuario            = 'informix';
	LET vHora               = '';
	LET vFolio         		= '';
	LET vDivisa             = '01';
	LET vTranIva            = '0260';
	LET vTranRet            = '';
	LET v_ret1         = "";
	LET v_ret2         = '';
	LET v_ret3         = '';
	LET v_ret4         ='';
	LET v_ret5         = '';
	LET v_ret6         = '';
	LET v_ret7         = '';
	LET v_ret8         = '';
	LET v_ret9         = '';
	LET v_ret10        = 0 ;
	LET v_ret11        = 0 ;
	LET v_ret12        = 0 ;
	LET v_ret13        = 0 ;
	LET v_ret14        = 0 ;
	LET v_ret15        = " ";
	LET v_ret16        = '';
	LET v_ret17        = "";
	LET v_ret18        = 0 ;
	LET v_ret19        = 0 ;
	LET v_ret20        = 0;
	LET v_ret21        = " ";
	LET v_ret22        = "";
	LET v_ret23        = '';
	LET v_ret24        = "";
	LET dMontoAplica   = 0.0;
	LET mMtoCom        = 0.0;
	LET mMontoPen	   = 0.0;
	LET	mIva		   = 0.0;
	LET cCodRetGF	   = "000";
	LET cFolioGF	   = "";
		
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
    --        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobra_com.err";
	 --	    TRACE ON;
			LET vCodRet    = vsqlerr;
            LET vErrorInfo = cErrorInfo;
	        RETURN vCodRet;
        END IF;
    END EXCEPTION;
	
	--SET   DEBUG FILE TO '/resplogifx/conciliachq/sp_cobra_com.txt';
	--SET    DEBUG FILE TO '/informix/rsv/seven/sp_cobra_com.txt';
    --TRACE ON;
	
   	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
	
	--CORRESPONSAL OXXO
	IF  p_corres = '0482' THEN 
	    
	    --OXXO 
	    --TRANSACCION 0507 EN PARAMETROS
	    SELECT valor  
	    INTO   v_transacc
	    FROM   bdicheq:sc_param 
	    WHERE  codparam = 'trancobcomoxxo';
	    
	    --TRANSACCION 0507 EN SC_TRANSACCION
	    SELECT numero
	    INTO   vTranCom
	    FROM   bdinteg:si_transacc
	    WHERE  numero = v_transacc
	    AND    sistema = '01';
	    
	    ----VALOR DE LA COMISION 
	    SELECT ROUND(valor  / 1.16 ,2)
	    INTO   vCom_Ma_Iva 
	    FROM   bdicheq:sc_param 
	    WHERE  codparam = 'montocomoxxo';
	
   ELIF p_corres = '0491' THEN 
	    --CORRESPONSAL 7-ELEVEN   

	    SELECT valor  
	    INTO   v_transacc
	    FROM   bdicheq:sc_param 
	    WHERE  codparam = 'trancobcomseven';
	    
	    --TRANSACCION PENDIENTE EN SC_TRANSACCION
	    SELECT numero
	    INTO   vTranCom
	    FROM   bdinteg:si_transacc
	    WHERE  numero  = v_transacc
	    AND    sistema = '01';
	    
	    --VALOR DE LA COMISION 
	    SELECT ROUND(valor  / 1.16 ,2)
	    INTO   vCom_Ma_Iva 
	    FROM   bdicheq:sc_param 
	    WHERE  codparam = 'montocomseven';
	   
	END IF; 
		
	IF vCom_Ma_Iva  = 0 THEN 
	   LET vCodRet  = '00001';
	   RETURN  vCodRet;
	END IF; 	
	
    -- VALOR IVA .16 
    SELECT valor 
    INTO   vValorIva 
    FROM   bdinteg:si_param
    WHERE  empresa = p_empresa
    AND    cod_param = 47;
    	
	-- TOTAL DE IVA
	LET vMontoIVA  = ROUND(vCom_Ma_Iva * vValorIva,2);
	-- TOTAL DE COMISION 
	LET v_comision = vCom_Ma_Iva;
	-- TOTAL DE COMISION + IVA
	LET v_comision_mas_iva = v_comision + vMontoIVA;
	-- FOLIO DEL CARGO 
	LET vHora  = CURRENT HOUR TO FRACTION;
    LET vFolio = vUsuario||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
	
	LET vFolio = p_folio;
	
	--SE IDENTIFICA AL CLIENTE DE LA CUENTA A PROCESAR
	SELECT num_cte,   sucursal
    INTO   v_num_cte, v_sucursal
    FROM   bdicheq:"informix".sc_maechq
    WHERE  cuenta = p_cuenta;
	
	--SE VALIDA SI EL CLIENTE TIENE UN PRESTAMO PERSONAL VIGENTE
	SELECT COUNT(*)
	INTO   v_exi_cte 
	FROM   bdicred:sd_ppvigente
	WHERE  numcte =  v_num_cte;
	
	--IF  v_exi_cte  IS NULL OR v_exi_cte = "" THEN 
 -- IF  v_exi_cte  = 0 THEN --  Se comenta para eliminar la regla que un cliente con credito si se deba cobrar la comision 
	    
		EXECUTE PROCEDURE cons_sdos1(p_empresa,p_cuenta,'')
		INTO v_ret1,v_ret2,v_ret3,v_ret4,v_ret5,v_ret6,v_ret7,v_ret8,v_ret9,v_ret10,v_ret11,v_ret12,v_ret13,v_ret14,v_ret15,v_ret16,v_ret17,v_ret18,v_ret19,v_ret20,v_ret21,v_ret22,v_ret23,v_ret24; 
	
	    IF  v_ret10 >= v_comision_mas_iva THEN 
		
		    --SE REALIZA EL CARGO DE LA COMISION  
			CALL cargon_ref(p_empresa, v_sucursal, vUsuario, vTranCom, "0000", vFolio, p_cuenta, 0, v_comision, vDivisa, "", "", "")
			RETURNING vCodRet, vTranRet;
			
			IF  vCodRet <> '000' THEN 
			
			    --BITACORA DE ERRORES
			    INSERT INTO "informix".sc_bita_cobcom VALUES (v_num_cte,p_cuenta,vFolio,p_corres);
				
				--REGISTRA LA COMISION PENDIENTE
				INSERT INTO "informix".sc_detcomis
				VALUES("001", p_cuenta, vTranCom, v_comision, 0, TODAY, "", "P", vFolio);

				--MARCA LA COMISION PENDIENTE EN sc_maechq
				UPDATE "informix".sc_maechq
				SET    com_pendiente =  com_pendiente + v_comision
				WHERE  empresa = "001"
				AND    cuenta  = p_cuenta;
			   
			ELSE 
			    --SE REALIZA EL CARGO DEL IVA.                
			    CALL cargon_ref(p_empresa, v_sucursal, vUsuario, vTranIva, "0000", vFolio, p_cuenta, 0, vMontoIVA, vDivisa, "", "", "")
			    RETURNING vCodRet, vTranRet;
			
			END IF;
			
            --SE REALICE O NO EL CARGO SE RETORNA 00000
			IF  vCodRet = '000' OR vCodRet <> '000' THEN 
			    LET vCodRet = '00000';
			END IF; 			
			
		ELSE 

			LET mMtoCom      = v_comision;
			LET dMontoAplica = ROUND(v_ret10 / (1 + vValorIva),2);
			LET mMontoPen    = v_comision - dMontoAplica;
			LET mIva         = v_ret10 - dMontoAplica;
			
			IF 	v_ret10 > 0 AND dMontoAplica > 0  AND mIva > 0 THEN 		
			    --SE REALIZA EL CARGO DE LA COMISION  
			    CALL cargon_ref(p_empresa, v_sucursal, vUsuario, vTranCom, "0000", vFolio, p_cuenta, 0, dMontoAplica, vDivisa, "", "", "")
			    RETURNING vCodRet, vTranRet;
			    
			    --SE REALIZA EL CARGO DEL IVA.                
			    CALL cargon_ref(p_empresa, v_sucursal, vUsuario, vTranIva, "0000", vFolio, p_cuenta, 0, mIva, vDivisa, "", "", "")
			    RETURNING vCodRet, vTranRet;
			END IF; 
					
			IF  mMontoPen > 0 THEN
			
			    --REGISTRA LA COMISION PENDIENTE
			    INSERT INTO "informix".sc_detcomis
			    VALUES("001", p_cuenta, vTranCom, mMontoPen, 0, TODAY, "", "P", vFolio);
                
			    --MARCA LA COMISION PENDIENTE EN sc_maechq
			    UPDATE "informix".sc_maechq
			    SET    com_pendiente =  com_pendiente + mMontoPen
			    WHERE  empresa = "001"
			    AND    cuenta  = p_cuenta;
				
			END IF;
			---RETORNO POR QUE NO TENIA EL SALDO DISPONIBLE 
		    LET vCodRet = '00002';
		END IF; 
		
/*	ELSE 
	    --EL CLIENTE TIENE UN PRESTAMO PERSONAL VIGENTE. 
	    LET vCodRet = '00001';
	END IF;	*/
	
RETURN  vCodRet;
END; 
END PROCEDURE;