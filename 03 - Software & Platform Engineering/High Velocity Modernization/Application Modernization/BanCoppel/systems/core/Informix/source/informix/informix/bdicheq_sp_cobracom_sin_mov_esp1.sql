CREATE PROCEDURE "informix".sp_cobracom_sin_mov_esp1( pEmpresa CHAR(3) )
    RETURNING CHAR(5);
    
    DEFINE Sql_Err       INTEGER;
    DEFINE Isam_Err      INTEGER;
    DEFINE Desc_Err      CHAR(50);
    DEFINE vCodRet1      CHAR(5);
    DEFINE vCodRet2      CHAR(5);
    DEFINE vCodRet3      CHAR(50);
    DEFINE vComienza     INTEGER;
    DEFINE vEn_Transacc  SMALLINT;
    DEFINE vContador1    INTEGER;  
	DEFINE vContador2    INTEGER; 
    DEFINE vFecha_Hoy    DATE;
	DEFINE v_fecha_ant   DATE;
    DEFINE vTranCom      CHAR(4);
    DEFINE vTranIva      CHAR(4);
    DEFINE vValorIva     DECIMAL(9,6);
    DEFINE vMontoCOM     DECIMAL(14,2);
    DEFINE vMontoIVA     DECIMAL(14,2);
    DEFINE vUsuario      CHAR(8);
    DEFINE vHora         CHAR(12);
    DEFINE vFolio        CHAR(16);
    DEFINE vDivisa       CHAR(2);
    DEFINE vCuenta       CHAR(20);
    DEFINE v_sucursal    CHAR(4);
    DEFINE vCodRet       CHAR(5);
    DEFINE vTranRet      CHAR(4);
	DEFINE v_sdodisponible    DECIMAL(14,2);
	DEFINE v_comision_mas_iva DECIMAL (14,2);
	DEFINE v_valida_detalle   INTEGER;
	DEFINE v_transacc         CHAR(4);
	DEFINE v_monto_com        DECIMAL(14,2);
	DEFINE vcSql              CHAR(600);
	DEFINE v_fecha_fin        DATE;
		
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
	
	DEFINE v_estatus     CHAR(1);
	DEFINE vsql          CHAR(500);
	DEFINE v_totalreg    INTEGER;      
    
    LET Sql_Err	       = 0;
    LET Isam_Err       = 0;
    LET Desc_Err       = '';
    LET vCodRet1       = '00000';
    LET vCodRet2       = '000';
    LET vCodRet3       = '';
    LET vComienza      = -1;
    LET vEn_Transacc   = 0;
    LET vContador1     = 0;
	LET vContador2     = 0;
    LET vFecha_Hoy     = '';
	LET v_fecha_ant    = '';
    LET vTranCom       = '';
    LET vTranIva       = '0260';
    LET vValorIva      = 0;
    LET vMontoIVA      = 0.00;
    LET vUsuario       = 'informix';
    LET vHora          = '';
    LET vFolio         = '';
    LET vDivisa        = '01';
    LET vCuenta        = '';
    LET v_sucursal      = '';
    LET vCodRet         = '000';
    LET v_sdodisponible = 0.00;
    LET vTranRet        = '';
	LET v_comision_mas_iva = 0.00;
	LET vcSql          = ""; 
	
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
	
	LET v_estatus      = "";
	LET vsql           = '';
	LET v_totalreg     = 0;
	
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobracom_sin_mov.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vEn_Transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/ifxsif01/rsv/comisionfull/rsv.txt";
    ---TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	 --TRANSACCION 0495 EN PARAMETROS
	SELECT valor  
	INTO   v_transacc
	FROM   sc_param 
	WHERE  codparam = 'trancobcom';
	
	--TRANSACCION 0495 EN SC_TRANSACCION
	SELECT numero
	INTO   vTranCom
	FROM   bdinteg:si_transacc
	WHERE  numero = v_transacc;
	
	--VALOR DEL MONTO COMISION
	SELECT valor  
	INTO   vMontoCom
	FROM   sc_param 
	WHERE  codparam = 'montocom';
	
    -- VALOR IVA .16 
    SELECT valor 
    INTO   vValorIva 
    FROM   bdinteg:si_param
    WHERE  empresa = pEmpresa
    AND    cod_param = 47;
       
	   
    LET vHora  = CURRENT HOUR TO FRACTION;
    LET vFolio = vUsuario||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
    LET vMontoIVA = vMontoCom * vValorIva;
    LET v_comision_mas_iva = vMontoCom + vMontoIVA;
	
	
    TRUNCATE TABLE sc_ctas_com_0495; 
		
	LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/info_773941_com.txt INSERT INTO sc_ctas_com_0495" > /resplogifx/conciliachq/ctasxproc1.sql';
    SYSTEM vsql;
    LET vsql = '';
       
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxproc1.sql'; 
    SYSTEM vsql;
    LET vsql = '';	
	
		FOREACH WITH HOLD
			--******CONSULTA PRINCIPAL *************
			SELECT FIRST 10000 a.cuenta, b.sdo_actual - (b.sdo_retenido  + b.sdo_cong + b.imp_chq_sbg), b.sucursal, b.status_cta 
			INTO   vCuenta,  v_sdodisponible,                                               v_sucursal, v_estatus
			FROM   sc_ctas_com_0495  AS a,  ----TABLA CON LAS CUENTAS A PROCESAR 773,941
			       sc_maechq         AS b   ----MAESTRA DE CHEQUES 
			WHERE  a.cuenta  = b.cuenta     
			AND    a.cuenta NOT IN (SELECT cuenta 
			                        FROM   sc_ctrol_com_0495  --TABLA QUE VA A TENER LAS CUENTAS QUE YA SE PROCESARON
									WHERE  estatus IN("PC","SS","EN"))				
	  
            IF (vComienza = -1) THEN
                LET vComienza = 0;
		    	LET vEn_Transacc = 1;
                BEGIN WORK;
            END IF;
			
			IF v_estatus IN("1","4","5") THEN 
			
			    EXECUTE PROCEDURE cons_sdos1(pEmpresa,vCuenta,'')
			    INTO v_ret1,v_ret2,v_ret3,v_ret4,v_ret5,v_ret6,v_ret7,v_ret8,v_ret9,v_ret10,v_ret11,v_ret12,v_ret13,v_ret14,v_ret15,v_ret16,v_ret17,v_ret18,v_ret19,v_ret20,v_ret21,v_ret22,v_ret23,v_ret24; 
			    
                IF  v_ret10 >= v_comision_mas_iva THEN 
			         
			    	--SE REALIZA EL CARGO DE LA COMISION  
			    	CALL cargon_ref(pEmpresa, v_sucursal, vUsuario, vTranCom, "0000", vFolio, vCuenta, 0, vMontoCom, vDivisa, "Pendiente Marzo", "", "")
			    	RETURNING vCodRet, vTranRet;
			    	
			        --SE REALIZA EL CARGO DEL IVA.                
                     -- // Realiza Cobro de Iva
			    	CALL cargon_ref(pEmpresa, v_sucursal, vUsuario, vTranIva, "0000", vFolio, vCuenta, 0, vMontoIVA, vDivisa, "Pendiente Marzo", "", "")
			    	RETURNING vCodRet, vTranRet;
					
					INSERT INTO sc_ctrol_com_0495 VALUES (vCuenta,"PC",TODAY);
					
				ELSE 
				INSERT INTO sc_ctrol_com_0495 VALUES (vCuenta,"SS",TODAY);   			
			    END IF;
				
			ELSE 	
			INSERT INTO sc_ctrol_com_0495 VALUES (vCuenta,"EN",TODAY);	
			END IF;   
			COMMIT WORK;
			BEGIN WORK;
			
        END FOREACH;
	
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;     
END;
RETURN vCodRet1;
END PROCEDURE;