CREATE PROCEDURE "informix".sp_cobracom_sin_mov( pEmpresa CHAR(3) )
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
    
    --SET DEBUG FILE TO "/informix/rsv/comision/sp_cobracom_sin_mov.out";
    --TRACE ON;

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

	SELECT COUNT(*) 
	INTO   v_valida_detalle
	FROM   sc_detalle_cobro_com
	WHERE  fecha_proc = TODAY; 
	
	
	--INSERTA O ACTUALIZA EL REGISTRO DEL PROCESO 
	IF   v_valida_detalle > 0 THEN 
	     LET vcSql = 'echo "UPDATE sc_detalle_cobro_com' ||
		             '  SET total = '||''''||' '||''''||','||
					 '  total_proc = '||''''||' '||''''||','||
		             '  fecha_hora_ini = CURRENT'||','||
					 '  fecha_hora_fin ='||''''||' '||''''||','||
					 '  estatus =  '||''''||'I'||''''||  
				     '  WHERE  fecha_proc = TODAY'||';" > /resplogifx/conciliachq/consulta.sql';
		SYSTEM vcSql;
        LET vcSql = ''; 
        LET vcSql = "dbaccess bdicheq /resplogifx/conciliachq/consulta.sql"; 	
        SYSTEM vcSql;			
	ELSE 
        INSERT INTO sc_detalle_cobro_com VALUES (TODAY,' ',' ',CURRENT,' ','I');
	END IF; 
		
	SELECT fecha_ant
	INTO   v_fecha_fin
	FROM   bdicheq:sc_fechas
	WHERE  empresa = pEmpresa;
		
	--OBTIENE TODAS LA CUENTAS DEL MESIVERSARIO. 
	SELECT cuenta,num_cte 
	FROM   sc_maehis  
	WHERE  fechafin >= v_fecha_fin
	INTO   temp tmp_ctas_mesi WITH NO LOG;
		
	--SE OBTIENEN LAS CUENTAS QUE SE RELACIONAN CON LAS DEL MESIVERSARIO 
	SELECT a.cliente, a.cuenta, a.num_tarjeta, a.saldo_promedio 
	FROM   sc_ctas_sin_movimientos AS a,
	       tmp_ctas_mesi           AS b
	WHERE  a.cuenta = b.cuenta 
	AND    a.cliente = b.num_cte
	INTO   temp tmp_ctas_proc WITH NO LOG;
	
	CREATE INDEX idx_tmp_ctas_proc ON tmp_ctas_proc(cliente,cuenta);
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas_proc;
	
	--SE DISCRIMINAN LAS CUENTAS QUE ESTAN CONSIDERADAS EN EL COBRO DE COMISION POR INACTIVIDAD.  
	SELECT * FROM tmp_ctas_proc 
	WHERE cuenta NOT IN (SELECT cuenta FROM sc_ctasinact_cobro_comision)
	INTO   temp tmp_ctas_proc_fin WITH NO LOG;
	
	CREATE INDEX idx_tmp_ctas_proc_fin ON tmp_ctas_proc_fin(cliente,cuenta);
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas_proc_fin;
		

		FOREACH WITH HOLD
			--******CONSULTA PRINCIPAL *************
			SELECT a.cuenta, b.sdo_actual - (b.sdo_retenido  + b.sdo_cong + b.imp_chq_sbg), b.sucursal 
			INTO   vCuenta,  v_sdodisponible,                                               v_sucursal
			FROM   tmp_ctas_proc_fin   AS a, 
			       sc_maechq       AS b
			WHERE  a.cuenta  = b.cuenta 
			AND    a.cliente = b.num_cte 
			
		  		  
            IF (vComienza = -1) THEN
                LET vComienza = 0;
		    	LET vEn_Transacc = 1;
                BEGIN WORK;
            END IF;
			
			EXECUTE PROCEDURE cons_sdos1(pEmpresa,vCuenta,'')
			INTO v_ret1,v_ret2,v_ret3,v_ret4,v_ret5,v_ret6,v_ret7,v_ret8,v_ret9,v_ret10,v_ret11,v_ret12,v_ret13,v_ret14,v_ret15,v_ret16,v_ret17,v_ret18,v_ret19,v_ret20,v_ret21,v_ret22,v_ret23,v_ret24; 

            IF  v_ret10 >= v_comision_mas_iva THEN 
			     
				--SE REALIZA EL CARGO DE LA COMISION  
				CALL cargon_ref(pEmpresa, v_sucursal, vUsuario, vTranCom, "0000", vFolio, vCuenta, 0, vMontoCom, vDivisa, "", "", "")
				RETURNING vCodRet, vTranRet;
				
			    --SE REALIZA EL CARGO DEL IVA.                
                 -- // Realiza Cobro de Iva
				CALL cargon_ref(pEmpresa, v_sucursal, vUsuario, vTranIva, "0000", vFolio, vCuenta, 0, vMontoIVA, vDivisa, "", "", "")
				RETURNING vCodRet, vTranRet;
					
				---CONTADOR 
                LET vContador1 = vContador1 + 1;
				
			END IF;
                
			COMMIT WORK;
			BEGIN WORK;
			
			LET vContador2 = vContador2 + 1;
            LET v_ret10 = 0.00;

        END FOREACH;
	
	IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;

	LET vcSql = ' '; 
	LET vcSql = 'echo "UPDATE sc_detalle_cobro_com' ||
		        '  SET total = '||vContador2||','||
				'  total_proc = '||vContador1||','||
		        '  fecha_hora_fin = CURRENT'||','||
				'  estatus =  '||''''||'F'||''''||  
				'  WHERE  fecha_proc = TODAY'||';" > /resplogifx/conciliachq/consulta.sql';
    SYSTEM vcSql;
    LET vcSql = ''; 
    LET vcSql = "dbaccess bdicheq /resplogifx/conciliachq/consulta.sql"; 
    SYSTEM vcSql;			
	
    DROP TABLE tmp_ctas_mesi; 
	DROP TABLE tmp_ctas_proc; 
	DROP TABLE tmp_ctas_proc_fin; 
	
	
       
END;
RETURN vCodRet1;
END PROCEDURE;