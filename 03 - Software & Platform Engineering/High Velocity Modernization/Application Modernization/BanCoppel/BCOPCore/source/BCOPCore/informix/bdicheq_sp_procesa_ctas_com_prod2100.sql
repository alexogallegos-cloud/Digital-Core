CREATE PROCEDURE "informix".sp_procesa_ctas_com_prod2100(pEmpresa char(3))
RETURNING   CHAR(5);
	
	DEFINE vCodRet CHAR(5);
	DEFINE vCodRet2 Char(5);
    DEFINE vCodRet3 Char(50);
	DEFINE cSQL_ERR     Integer;
    DEFINE cISAM_ERR    Integer;
    DEFINE cDESC_ERR    Char(50);
	DEFINE vCliente char(20);
	DEFINE vCuenta char(20);
	DEFINE dFechaInicio date;
	DEFINE diaMesiversario char(6);
	DEFINE iCuentaInactiva int;
	DEFINE iMovimientos int;
	DEFINE mSaldoPromMes1 money(16,2);
	DEFINE mSaldoPromMes2 money(16,2);
	DEFINE mSaldoPromMes3 money(16,2);
	DEFINE mSaldoAcomulado1 money(16,2);
	DEFINE mSaldoAcomDisp money(16,2);
	DEFINE mSaldoAcomDispOld money(16,2);
	DEFINE mSaldoAcomuladoOld money(16,2);
	DEFINE mSaldoAcomulado2 money(16,2);
	DEFINE mSaldoAcomulado3 money(16,2);
	DEFINE mSaldoAcomuladoPorta money(16,2);
	DEFINE mSaldoAcomuladoEmp money(16,2);
	DEFINE dFechaFinalMes1 date;
	DEFINE dFechaFinalMes2 date;
	DEFINE dFechaFinalMes3 date;
	DEFINE dFechaInicialMes1 date;
	DEFINE dFechaInicialMes2 date;
	DEFINE dFechaInicialMes3 date;
	DEFINE vCobraComision char(2);
	DEFINE dFechaHoy date;
	--DEFINE iProductosInversion int;
	--DEFINE iProductosPagare int;
	DEFINE mSaldoProm money(16,2);
	DEFINE mMontoAcum money(16,2);
	DEFINE vSucursal CHAR(4);
	DEFINE iDiasIntegracion int;
	DEFINE iCommit INTEGER;
	DEFINE vContador1 INTEGER;
    DEFINE vContador2 INTEGER;
	DEFINE vComienza SMALLINT;
	DEFINE vAbierto CHAR(1);
	DEFINE mSaldoAcumulado MONEY(16,2);
	DEFINE iDiasConMov INTEGER;
	DEFINE cAnioMes1 char(6);
	DEFINE cAnioMes2 char(6);
	DEFINE cAnioMes3 char(6);
	DEFINE v_fecha_movhis DATE;
	--DEFINE mSaldoInvPagare MONEY(16,2);
	DEFINE vDias VARCHAR(30);
	DEFINE dPrimerDiaMes DATE;
	DEFINE mMontoIVA MONEY(16,2);
	DEFINE mMontoCom MONEY(16,2);
	DEFINE mComisionTotal MONEY(16,2);
	DEFINE vValorIva DECIMAL(16,2);
	DEFINE dFechaAyer DATE; 
	DEFINE mSaldoAcomDisp0273 money(16,2);
	DEFINE mSaldoAcomPen0273 money(16,2);
	--Fechas donde consultara las quincenas
	DEFINE dFechaIniM1Quin date;
	DEFINE dFechaIniM1Quin2 date;
	DEFINE dFechaFinM1Quin date;
	DEFINE dFechaFinM1Quin2 date;
	
	DEFINE dFechaIniM2Quin date;
	DEFINE dFechaIniM2Quin2 date;
	DEFINE dFechaFinM2Quin date;
	DEFINE dFechaFinM2Quin2 date;
	
	DEFINE dFechaIniM3Quin date;
	DEFINE dFechaIniM3Quin2 date;
	DEFINE dFechaFinM3Quin date;
	DEFINE dFechaFinM3Quin2 date;
	
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
	DEFINE iMovQuinMovhis  MONEY(14,2);
	DEFINE iMovQuinMovhis2 MONEY(14,2);
	DEFINE mSaldoAcum273Sdw money(16,2);
	
	

	LET vCodRet = '00000';
	LET vCliente = '';
	LET vCuenta = '';
	LET vSucursal = '';
	LET iCuentaInactiva = 0;
	LET iMovimientos = 0;
	LET mSaldoPromMes1 = 0;
	LET mSaldoPromMes2 = 0;
	LET mSaldoPromMes3 = 0;
	--LET iProductosInversion = 0;
	Let mSaldoAcomDisp = 0;
	Let mSaldoAcomDispOld =0;
	--LET iProductosPagare = 0;
	
	LET iCommit = 1000;
	LET vContador1 = 0;
    LET vContador2 = 0;
    LET vComienza = -1;
    LET vAbierto = '0';
	LET mSaldoAcumulado = 0;
	LET iDiasConMov = 0;
	
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
	LET mSaldoAcomDisp0273 = 0;
	LET mSaldoAcomPen0273  = 0;
	LET mSaldoAcomuladoPorta = 0;
	LET mSaldoAcomuladoEmp = 0;
	LET iMovQuinMovhis = 0;
	LET iMovQuinMovhis2 = 0;
	LET mSaldoAcum273Sdw = 0;
	BEGIN
		ON EXCEPTION SET cSQL_ERR, cISAM_ERR, cDESC_ERR
			LET vCodret  = cSQL_ERR;
			LET vCodRet2 = cISAM_ERR;
			LET vCodRet3 = cDESC_ERR;
			--SET DEBUG FILE TO '/sql-scripts/sp_procesa_ctas_com_prod2100.err';
		    --TRACE ON;
			IF vAbierto = '1' THEN
				ROLLBACK WORK;
			END IF;
			RETURN vCodRet;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--SET DEBUG FILE TO '/sql-scripts/sp_procesa_ctas_com_prod2100.out';
		--TRACE ON;
		
		--Consulta los dias que debe tener de integracion o de alta la cuenta para poder ser tomada en cuenta en el proceso
		SELECT valor 
		into iDiasIntegracion 
		FROM bdicheq:sc_param 
		WHERE codparam = 'INTEGRACION_PROCESO' and empresa = pEmpresa;
		
		--Consulta la fecha actual
		SELECT fecha_hoy 
		INTO dFechaHoy 
		FROM bdicheq:sc_fechas 
		where empresa = pEmpresa;
		
		--Consulta el primer dÃ­a del mes
		SELECT pri_dia_mes 
		INTO dPrimerDiaMes 
		FROM bdicheq:sc_fechas 
		where empresa = pEmpresa;
		
		--Consulta la fecha de ayer
		SELECT fecha_ant 
		INTO dFechaAyer 
		FROM bdicheq:sc_fechas 
		where empresa = pEmpresa;
				
		--Saldo promedio mensual
		SELECT valor  
		INTO   mSaldoProm
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'sdoprom_2100' and empresa = pEmpresa;
		
		--Saldo minimo en pagare e inversion
		--SELECT valor  
		--INTO   mSaldoInvPagare
		--FROM   bdicheq:sc_param 
		--WHERE  codparam = 'montoinvpag_2100' and empresa = pEmpresa;
		
		--Monto acumulado mensual
		SELECT valor  
		into mMontoAcum
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'montoacum_2100' and empresa = pEmpresa;
		
		
		SELECT valor
		INTO   v_fecha_movhis
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'fechcon_movhis';
		
		--Monto de la comision para cuenta del producto 2100
		SELECT valor  
		INTO   mMontoCom
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'montocom2100' and empresa = pEmpresa;
		
		--Valor del iva
		SELECT valor 
		INTO   vValorIva 
		FROM   bdinteg:si_param
		WHERE  empresa = pEmpresa
		AND    cod_param = 47;
		--Monto acumulado para suma de acumulado mensual sin filtrar por conceptos los dias de quincena 13 al 15 y ultimos 4 dias del mes
		SELECT 	NVL(valor,3000)
		INTO mSaldoAcum273Sdw
		FROM   bdicheq:sc_param 
		WHERE  codparam = 'montoAcum2100sdw' and empresa = pEmpresa;
		
		
		--Fechas iniciales y finales para validar sumatoria de movimientos y portabilidad
		LET dFechaInicialMes1 = DATE(dPrimerDiaMes - 1 UNITS MONTH);
		LET dFechaInicialMes2 = DATE(dPrimerDiaMes - 2 UNITS MONTH);
		LET dFechaInicialMes3 = DATE(dPrimerDiaMes - 3 UNITS MONTH);
		LET dFechaFinalMes1 = LAST_DAY(dFechaHoy -1 UNITS MONTH);
		LET dFechaFinalMes2 = LAST_DAY(dFechaHoy -2 UNITS MONTH);
		LET dFechaFinalMes3 = LAST_DAY(dFechaHoy -3 UNITS MONTH);
		--Fechas de rangos donde se consultara las quincenas los dias 13-16,28-31 del mes 1
		LET dFechaIniM1Quin = MDY(MONTH(dPrimerDiaMes - 1 UNITS MONTH),13,YEAR(dPrimerDiaMes - 1 UNITS MONTH));
		LET dFechaIniM1Quin2 =LAST_DAY(dFechaHoy -1 UNITS MONTH) - 3 units day;
	    LET dFechaFinM1Quin = MDY(MONTH(dPrimerDiaMes - 1 UNITS MONTH),15,YEAR(dPrimerDiaMes - 1 UNITS MONTH));
	    LET dFechaFinM1Quin2 =LAST_DAY(dFechaHoy -1 UNITS MONTH);
		--Fechas de rangos donde se consultara las quincenas los dias 13-16,28-31 del mes 2
		LET dFechaIniM2Quin = MDY(MONTH(dPrimerDiaMes - 2 UNITS MONTH),13,YEAR(dPrimerDiaMes - 2 UNITS MONTH));
		LET dFechaIniM2Quin2 =LAST_DAY(dFechaHoy -2 UNITS MONTH) - 3 units day;
	    LET dFechaFinM2Quin = MDY(MONTH(dPrimerDiaMes - 2 UNITS MONTH),15,YEAR(dPrimerDiaMes - 2 UNITS MONTH));
	    LET dFechaFinM2Quin2 =LAST_DAY(dFechaHoy -2 UNITS MONTH);
		--Fechas de rangos donde se consultara las quincenas los dias 13-16,28-31 del mes 3
		LET dFechaIniM3Quin = MDY(MONTH(dPrimerDiaMes - 3 UNITS MONTH),13,YEAR(dPrimerDiaMes - 3 UNITS MONTH));
		LET dFechaIniM3Quin2 =LAST_DAY(dFechaHoy -3 UNITS MONTH) - 3 units day;
	    LET dFechaFinM3Quin = MDY(MONTH(dPrimerDiaMes - 3 UNITS MONTH),15,YEAR(dPrimerDiaMes - 3 UNITS MONTH));
	    LET dFechaFinM3Quin2 =LAST_DAY(dFechaHoy -3 UNITS MONTH);
		
		
		--Fecha para tomar en cuenta las cuentas, la alta o creacion de la cuenta debe ser menor a hoy menos los dias de integracion(90)
		LET dFechaInicio = DATE(dFechaHoy - iDiasIntegracion UNITS DAY);
		
		--Fechas para saldo promedio en sc_maehis
		LET cAnioMes1 = YEAR(dFechaFinalMes1)||lpad(month(dFechaFinalMes1),2,"0");
		LET cAnioMes2 = YEAR(dFechaFinalMes2)||lpad(month(dFechaFinalMes2),2,"0");
		LET cAnioMes3 = YEAR(dFechaFinalMes3)||lpad(month(dFechaFinalMes3),2,"0");
		
		--Se calcula IVA y monto total de comision
		LET mMontoIVA = (mMontoCom * vValorIva);
		LET mComisionTotal = mMontoCom + mMontoIVA;
		
		FOREACH WITH HOLD
			SELECT a.num_cte, a.cuenta, a.sucursal 
			INTO   vCliente, vCuenta,  vSucursal
			FROM   bdicheq:sc_maechq AS a,
				   bdicheq:sc_maenoc AS b, 
				   bdicheq:sc_maehis AS c
			WHERE  a.cuenta     = b.cuenta 
			AND    a.cuenta     = c.cuenta
			AND    a.status_cta = "1"
			AND    a.producto   = "2100"
			AND    b.fecha_alta < dFechaInicio
			AND    c.fechafin = dFechaAyer
			AND a.cuenta NOT IN(select cuenta FROM bdicheq:sc_cuentas_procesar2100 where cuenta = a.cuenta)
			
			IF vComienza = -1 THEN
				LET vComienza = 0;
				BEGIN WORK;
				LET vAbierto = '1';
			END IF;
			--Limpiamos las variables despues de cada iteracion
			LET mSaldoAcomDispOld = 0;
			LET mSaldoAcomDisp = 0;
			LET mSaldoAcomulado1 = 0;
			LET mSaldoAcomuladoOld = 0;
			LET mSaldoAcomulado2 = 0;
			LET mSaldoAcomulado3 = 0;
			lET mSaldoAcumulado = 0;
			LET iDiasConMov = 0;
			LET mSaldoPromMes1 = 0;
			LET mSaldoPromMes2 = 0;
	        LET mSaldoPromMes3 = 0;
			LET mSaldoAcomDisp0273 = 0;
	        LET mSaldoAcomPen0273  = 0;
			LET mSaldoAcomuladoPorta = 0;
			LET mSaldoAcomuladoEmp = 0;
			LET iMovQuinMovhis = 0;
	        LET iMovQuinMovhis2 = 0;
			
			--Si la cuenta no cuenta con saldo suficiente para el cobro se descarta
			EXECUTE PROCEDURE cons_sdos1(pEmpresa,vCuenta,'')
			INTO v_ret1,v_ret2,v_ret3,v_ret4,v_ret5,v_ret6,v_ret7,v_ret8,v_ret9,v_ret10,v_ret11,v_ret12,v_ret13,v_ret14,v_ret15,v_ret16,v_ret17,v_ret18,v_ret19,v_ret20,v_ret21,v_ret22,v_ret23,v_ret24; 
			IF v_ret10 < mComisionTotal THEN
				CONTINUE FOREACH;
			END IF;
			
			--Si la cuenta esta considerada en el cobro comision por inectividad se descarta.
			SELECT count(cuenta) INTO iCuentaInactiva FROM bdicheq:sc_ctasinact_cobro_comision WHERE cuenta = vCuenta;
			IF iCuentaInactiva > 0 THEN
				CONTINUE FOREACH;
			END IF;
			
			--CONSULTA MOVIMIENTOS DE LA TRANSACCION 0273 PARA:
			--Pensionados
			--Ingresos con concepto de nomina que incluye los conceptos de NOMINA o SUELDO
			--portabilidad
			--Empleados nomina coppel y bancoppel(0293,0287)
			SELECT nvl(sum(ingresos_pen),0),nvl(sum(ingresos_sdw),0),nvl(sum(ingresos_porta),0),nvl(sum(ingresos_emp),0) 
			INTO mSaldoAcomPen0273,mSaldoAcomDisp0273,mSaldoAcomuladoPorta,mSaldoAcomuladoEmp FROM bdicheq:sc_nom_disp_cte 
			where cuenta = vCuenta and fecha_pago BETWEEN dFechaInicialMes3 and dFechaFinalMes1;
			--En caso de tener saldo > 0 se descarta para cobro de comision
			IF mSaldoAcomPen0273 > 0 OR mSaldoAcomDisp0273 > 0 or mSaldoAcomuladoPorta > 0 or mSaldoAcomuladoEmp >0 then
			    CONTINUE FOREACH;
			END IF;
			
			--Consulta si tiene dispersion de nomina en alguno de los 3 meses anteriores
			IF dFechaInicialMes3 >= v_fecha_movhis THEN
			    SELECT nvl(sum(monto_tot),0) into mSaldoAcomDisp FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null 
				and tipo_trans = 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes1;
			ELSE
			    SELECT nvl(sum(monto_tot),0) into mSaldoAcomDisp FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null 
				and tipo_trans = 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes1;
				
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomDispOld FROM bdicheq:sc_movhis_old 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null 
				and tipo_trans = 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes1;
			END IF;
			
			IF (mSaldoAcomDisp + mSaldoAcomDispOld) > 0 then
			    CONTINUE FOREACH;
			END IF;
			
			--FILTRO 2 NOMINA 0273 - CONSULTA POR TRANSACCION 0273 LOS DIAS DE QUINCENA 13-16,ultimos 4 dias del mes, MES 1
			--EN CASO DE TENER UN ACUMULADO >=3000 SE DESCARTA PARA COBRO DE COMISON
			IF dFechaIniM1Quin >= v_fecha_movhis THEN
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM1Quin and dFechaFinM1Quin or fech_alt between dFechaIniM1Quin2 and dFechaFinM1Quin2);
			ELSE
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis2 FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM1Quin and dFechaFinM1Quin or fech_alt between dFechaIniM1Quin2 and dFechaFinM1Quin2);
				
				SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis_old WHERE transacc = '0273'
				and cuenta = vCuenta and(fech_alt between dFechaIniM1Quin and dFechaFinM1Quin or fech_alt between dFechaIniM1Quin2 and dFechaFinM1Quin2);
			END IF;
			   
			   IF (iMovQuinMovhis + iMovQuinMovhis2) >= mSaldoAcum273Sdw then
			        CONTINUE FOREACH;
			    END IF;
			    LET iMovQuinMovhis = 0;
			    LET iMovQuinMovhis2 = 0;
				
		--MES 2 FILTRO 2
			IF dFechaIniM2Quin >= v_fecha_movhis THEN
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM2Quin and dFechaFinM2Quin or fech_alt between dFechaIniM2Quin2 and dFechaFinM2Quin2);
			ELSE
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis2 FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM2Quin and dFechaFinM2Quin or fech_alt between dFechaIniM2Quin2 and dFechaFinM2Quin2);
				
				SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis_old WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM2Quin and dFechaFinM2Quin or fech_alt between dFechaIniM2Quin2 and dFechaFinM2Quin2);
			END IF;
			    IF (iMovQuinMovhis + iMovQuinMovhis2) >= mSaldoAcum273Sdw then
			        CONTINUE FOREACH;
			    END IF;
			    LET iMovQuinMovhis = 0;
			    LET iMovQuinMovhis2 = 0;
				
		--MES 3 FILTRO 2
			IF dFechaIniM3Quin >= v_fecha_movhis THEN
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM3Quin and dFechaFinM3Quin or fech_alt between dFechaIniM3Quin2 and dFechaFinM3Quin2);
			ELSE
			    SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis2 FROM bdicheq:sc_movhis WHERE transacc = '0273'
				and cuenta = vCuenta and (fech_alt between dFechaIniM3Quin and dFechaFinM3Quin or fech_alt between dFechaIniM3Quin2 and dFechaFinM3Quin2);
				
				SELECT nvl(sum(monto_tot),0) into iMovQuinMovhis FROM bdicheq:sc_movhis_old WHERE transacc = '0273'
				and cuenta = vCuenta and(fech_alt between dFechaIniM3Quin and dFechaFinM3Quin or fech_alt between dFechaIniM3Quin2 and dFechaFinM3Quin2);
			END IF;
			
			    IF (iMovQuinMovhis + iMovQuinMovhis2) >= mSaldoAcum273Sdw then
			        CONTINUE FOREACH;
			    END IF;
			    LET iMovQuinMovhis = 0;
			    LET iMovQuinMovhis2 = 0;
			
			--Consulta la sumatoria de los movimientos validos de los 3 meses anteriores para remesas
			IF dFechaInicialMes1 >= v_fecha_movhis THEN
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado1 FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2) 
				and cuenta = vCuenta and fech_alt between dFechaInicialMes1 and dFechaFinalMes1;
			ELSE
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado1 FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2) 
				and cuenta = vCuenta and fech_alt between dFechaInicialMes1 and dFechaFinalMes1;
				
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomuladoOld FROM bdicheq:sc_movhis_old 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2) 
				and cuenta = vCuenta and fech_alt between dFechaInicialMes1 and dFechaFinalMes1;
				LET mSaldoAcomulado1 = mSaldoAcomulado1 + mSaldoAcomuladoOld;
				LET mSaldoAcomuladoOld = 0;
			END IF
			--si el monto acumulado es igual o mayor al establecido continua con el siguiente registro
			IF mSaldoAcomulado1 >= mMontoAcum THEN
				CONTINUE FOREACH;
			END IF;
			
			IF dFechaInicialMes2 >= v_fecha_movhis THEN
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado2 FROM bdicheq:sc_movhis 
				WHERE transacc in (SELECT numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes2 and dFechaFinalMes2;
			ELSE
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado2 FROM bdicheq:sc_movhis 
				WHERE transacc in (SELECT numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes2 and dFechaFinalMes2;
				
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomuladoOld FROM bdicheq:sc_movhis_old 
				WHERE transacc in (SELECT numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes2 and dFechaFinalMes2;
				LET mSaldoAcomulado2 = mSaldoAcomulado2 + mSaldoAcomuladoOld;
				LET mSaldoAcomuladoOld = 0;
			END IF;
			--si el monto acumulado es igual o mayor al establecido continua con el siguiente registro
			IF mSaldoAcomulado2 >= mMontoAcum THEN
				CONTINUE FOREACH;
			END IF;
			IF dFechaInicialMes3 >= v_fecha_movhis THEN
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado3 FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes3;
			ELSE
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomulado3 FROM bdicheq:sc_movhis 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes3;
				
				SELECT nvl(sum(monto_tot),0) into mSaldoAcomuladoOld FROM bdicheq:sc_movhis_old 
				WHERE transacc in (select numero FROM bdicheq:sc_productos_notificacion where empresa="001" and numero is not null and tipo_trans <> 2)
				and cuenta = vCuenta and fech_alt between dFechaInicialMes3 and dFechaFinalMes3;
				LET mSaldoAcomulado3 = mSaldoAcomulado3 + mSaldoAcomuladoOld;
				LET mSaldoAcomuladoOld = 0;
			END IF;
			--si el monto acumulado es igual o mayor al establecido continua con el siguiente registro
			IF mSaldoAcomulado3 >= mMontoAcum THEN
				CONTINUE FOREACH;
			END IF;
			
			--Consulta el saldo promedio mensual de los ulimos 3 meses
			SELECT NVL(acum_sdo_pos,0),NVL(dia_sdo_pos,0) into mSaldoAcumulado, iDiasConMov  from bdicheq:sc_maehis
			WHERE aniomes = cAnioMes1 and cuenta = vCuenta;
			IF iDiasConMov <> 0 THEN
				LET mSaldoPromMes1 = mSaldoAcumulado / iDiasConMov;
			ELSE
				LET mSaldoPromMes1 = 0;
			END IF;
			
			SELECT NVL(acum_sdo_pos,0),NVL(dia_sdo_pos,0) into mSaldoAcumulado, iDiasConMov  from bdicheq:sc_maehis
			WHERE aniomes = cAnioMes2 and cuenta = vCuenta;
			IF iDiasConMov <> 0 THEN
				LET mSaldoPromMes2 = mSaldoAcumulado / iDiasConMov;
			ELSE
				LET mSaldoPromMes2 = 0;
			END IF;  
			
			SELECT NVL(acum_sdo_pos,0),NVL(dia_sdo_pos,0) into mSaldoAcumulado, iDiasConMov  from bdicheq:sc_maehis
			WHERE aniomes = cAnioMes3 and cuenta = vCuenta;
			IF iDiasConMov <> 0 THEN
				LET mSaldoPromMes3 = mSaldoAcumulado / iDiasConMov;
			ELSE
				LET mSaldoPromMes3 = 0;
			END IF;
			
			IF mSaldoPromMes1 >= mSaldoProm or mSaldoPromMes2 >= mSaldoProm or mSaldoPromMes3 >= mSaldoProm THEN
				CONTINUE FOREACH;
			END IF;
			
			--Consulta si el cliente tiene por lo menos un producto de inversion activo con saldo minimo de 1500
			--SELECT count(*) INTO iProductosInversion 
			--FROM bdicheq:sc_maechq 
			--WHERE producto = '1100' AND num_cte  = vCliente AND status_cta = '1' and sdo_actual >= mSaldoInvPagare;
			--IF iProductosInversion > 0 THEN
				--CONTINUE FOREACH;
			--END IF;
			
			--Consulta si el cliente tiene por lo menos un producto de pagare activo con saldo minimo de 1500
			--SELECT count(*) INTO iProductosPagare 
			--FROM bdinvers:sv_maeinv 
			--WHERE cod_instrum = '3000' AND num_cte = vCliente AND    status_cta  = '1' and capital >= mSaldoInvPagare; 
			--IF iProductosPagare > 0 THEN
			--	CONTINUE FOREACH;
			--END IF;
			INSERT INTO sc_cuentas_procesar2100 VALUES(vCuenta,vSucursal,dFechaHoy);
			LET vcontador1 = vcontador1 + 1;
			LET vcontador2 = vcontador2 + 1;
			
			IF vcontador2 >= iCommit THEN
				LET vcontador2 = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;
		
		IF vAbierto = '1' THEN
			COMMIT WORK;
			LET vAbierto = '0';
		END IF;
		RETURN  vCodRet;
	END; 
END PROCEDURE
DOCUMENT
'DESCRIPCION: Filtra las cuentas del producto 2100 para poder realizar el cobro de comisiÃ³n por manejo de cuenta,',
'descartando las que no cuenten con portabilidad de nÃ³mina, la sumatoria de movimientos validos, saldo promedio mensual',
'en los ultimos 3 meses, que se encuentre en las cuentas consideradas en el cobro por inactividad y que no cuenten con  ',
'saldo suficiente para el cobro de la comisiÃ³n, las cuentas que no cumplan con alguno de estos requicitos serÃ¡n guardadas',
'en la tabla sc_cuentas_procesar2100',
'PETICION: Iniciativa Cuenta Nomina',
'AUTOR: 99805418 - Jose Zetina',
'FECHA DE CREACION: 17/09/2024',
'FECHA MODIFICACION: 14/02/2025',
'BD: bdicheq',
'_____________________________________________________________________________________________________________________________________',
'MODIFICADO: 	Jose Mauricio Ramirez Zamudio',
'FECHA: 		11 de Febrero de 2026',
'Peticion: Mariana Reyes, Bruno Bernabe',
'DESCRIPCION: - Se modifica consulta a la tabla sc_productos_notificacion para filtrar tipo_trans donde 1 es para remesas y 2 para transaccion de nomina',
    ',se consultan  movimientos de pensionados,portabilidad, nomina empleados coppel y bancopel de la tabla sc_nom_disp_cte',
	'se quita la consulta de portabilidad a la tabla sc_movhis y se hace ahora a la tabla sc_nom_disp_cte directamente,se agregan cambios',
    ' para consultar los dias de quincena por transaccion 0273 en la tabla sc_movhis para tratar de abarcar movimientos de nomina',
    'los dias 13-18 del mes y 28-31 del mes como segunda opcion en caso de no ser viable consultar el campo ingresos_sdw de la tabla sc_nom_disp_cte',
    ', se quita validacion para en caso de tener alguna cuenta de inversion o pagare pueda ser descartado de cobro de comision';

CREATE PROCEDURE "informix".sp_cap_cancelacta_masiva(pUsuario CHAR(8), pIdFuncion CHAR(10), pTrama LVARCHAR)
	RETURNING CHAR(5) AS codret, INTEGER AS total_canceladas, INTEGER AS total_no_canceladas;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	DEFINE v_PosPipe INT;
	DEFINE v_FechaHoy DATE;
	DEFINE v_Sucursal CHAR(4);
	DEFINE v_TipoSucursal CHAR(1);
	DEFINE v_ClavePagoProgramado CHAR(20);
	DEFINE v_Contador INTEGER;
	DEFINE v_Dec CHAR(5);
	DEFINE v_FolioCancelacion  VARCHAR(40);
	DEFINE v_Year              CHAR(4);
	DEFINE v_Month             CHAR(2);
	DEFINE v_Day               CHAR(2);
	DEFINE v_Hour              CHAR(2);
	DEFINE v_Minute            CHAR(2);
	DEFINE v_Second            CHAR(2);
	DEFINE v_PromotorPadded    CHAR(8); 
	DEFINE v_RespuestaProcesoCanc BOOLEAN;
	DEFINE v_CodRetProceso 		CHAR(5);
	
	DEFINE v_TramaRestante VARCHAR(100); 
	DEFINE v_ParCompleto   VARCHAR(40);
	DEFINE i INTEGER;
	DEFINE v_Char CHAR(1);
	DEFINE v_PosSeparador INTEGER; 
	DEFINE v_ContadorCuentasCanc INTEGER;
	DEFINE v_ContadorCuentasNoCanc INTEGER;
	DEFINE v_FechaActual DATETIME YEAR TO SECOND;
	DEFINE v_FechaNueva DATETIME YEAR TO SECOND;
	DEFINE v_Intervalo INTERVAL SECOND TO SECOND;	
	DEFINE v_PosPipe1 INTEGER;
	DEFINE v_PosPipe2 INTEGER;
	DEFINE v_Cliente CHAR(20);
	DEFINE v_Cuenta CHAR(20);
	
	LET cCodRet = '00000';
	LET v_RespuestaProcesoCanc = 'f';
	LET iSqlErr = 0;
	LET v_Cuenta = '';
	LET v_Cliente = '';
	LET v_PosPipe = 0;
	LET v_FechaHoy = TODAY;
	LET v_Sucursal = '';
	LET v_TipoSucursal = '';
	LET v_ClavePagoProgramado = '';
	LET v_Contador = 0;
	LET v_Dec = '';
	LET v_Year = YEAR(TODAY);    
	LET v_ContadorCuentasCanc = 0;
	LET v_ContadorCuentasNoCanc = 0;
	LET v_CodRetProceso = '00000';
	LET v_FechaActual = CURRENT;
	LET v_FechaNueva = CURRENT;
	LET v_Second = '';
	-- InicializaciÃ³n y limpieza
	LET v_TramaRestante = TRIM(pTrama); 
	LET i = 1;

	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
		RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;

		END EXCEPTION;
		DROP TABLE IF EXISTS temp_cuentas;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/vero/cancelacion/sp_cap_cancelacta_masiva.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTrama = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		CREATE TEMP TABLE temp_cuentas (
			cuenta    CHAR(20),
			cliente   CHAR(20)
		) WITH NO LOG;
	
		LET v_TramaRestante = TRIM(pTrama); 
		LET i = 1;

		WHILE LENGTH(v_TramaRestante) > 0

			SELECT INSTR(v_TramaRestante, '|') INTO v_PosPipe1 FROM systables WHERE tabid = 1;

			IF v_PosPipe1 = 0 THEN
				LET v_TramaRestante = '';
				EXIT WHILE;
			END IF;

			LET v_Cliente = SUBSTR(v_TramaRestante, 1, v_PosPipe1 - 1);

			SELECT 
				INSTR(SUBSTR(v_TramaRestante, v_PosPipe1 + 1), '|') 
			INTO 
				v_PosPipe2 
			FROM systables 
			WHERE tabid = 1;

			IF v_PosPipe2 = 0 THEN
				LET v_Cuenta = SUBSTR(v_TramaRestante, v_PosPipe1 + 1); 
				
				INSERT INTO temp_cuentas (cliente, cuenta) VALUES (TRIM(v_Cliente), TRIM(v_Cuenta));
				
				LET v_TramaRestante = '';
			ELSE
				LET v_Cuenta = SUBSTR(v_TramaRestante, v_PosPipe1 + 1, v_PosPipe2 - 1);
				INSERT INTO temp_cuentas (cliente, cuenta) VALUES (TRIM(v_Cliente), TRIM(v_Cuenta));
				LET v_TramaRestante = SUBSTR(v_TramaRestante, v_PosPipe1 + v_PosPipe2 + 1);
			END IF;
		END WHILE
		
		
		FOREACH
			SELECT * INTO v_Cuenta, v_Cliente 
			FROM temp_cuentas
			EXECUTE PROCEDURE bdicnweb:sp_valida_cuentacan(pUsuario, pIdFuncion, v_Cuenta) 
			INTO v_CodRetProceso, v_RespuestaProcesoCanc;
			
			IF v_RespuestaProcesoCanc = 't' THEN
				UPDATE bdicheq:sc_maechq 
				SET status_cta = '2', motivo = '15', fec_cancelac = v_FechaHoy 
				WHERE cuenta = v_Cuenta;
				
				UPDATE bdicheq:sc_contch 
				SET estado = 'C' 
				WHERE cuenta = v_Cuenta AND estado = 'A';
				
				SELECT sucursal 
				INTO v_Sucursal 
				FROM bdinteg:si_cliente 
				WHERE numcte = v_Cliente;
				
				SELECT tpo_sucursal 
				INTO v_TipoSucursal
				FROM bdinteg:si_sucursales 
				WHERE sucursal = v_Sucursal;
				
				FOREACH
					SELECT cve_pagoprog 
					INTO v_ClavePagoProgramado 
					FROM bdiprog:pp_pagoprog 
					WHERE num_cte=v_Cliente AND cuenta_origen = v_Cuenta AND cve_estado = '01'
					
					LET v_Contador = v_Contador + 1;
				END FOREACH;
				
				IF v_Contador>0 THEN
					LET v_Contador = 0;
					FOREACH
						SELECT DECODE(v_TipoSucursal, 'S', '01', 'N', '02', '')
						INTO v_Dec
						FROM bdinteg:si_sucursales
						WHERE sucursal = v_Sucursal
						LET v_Contador = v_Contador + 1;
					END FOREACH;
					IF v_Contador>0 THEN
						EXECUTE PROCEDURE bdiprog:sp_cancelaprogramacion ('02', v_Cliente, v_Dec, v_ClavePagoProgramado, 0, pUsuario);
						LET v_PromotorPadded = LPAD(pUsuario, 8, '0');
						LET v_FolioCancelacion = v_PromotorPadded || v_Year || v_Month || v_Day || v_Hour || v_Minute || v_Second;
					END IF;					
				END IF;
				
				LET v_FechaNueva = v_FechaActual + INTERVAL (1) SECOND TO SECOND;
				LET v_FechaActual = v_FechaNueva;
				LET v_Year = TO_CHAR(v_FechaNueva, '%Y');
				LET v_Month = TO_CHAR(v_FechaNueva, '%m');
				LET v_Day =	TO_CHAR(v_FechaNueva, '%d');
				LET v_Hour = TO_CHAR(v_FechaNueva, '%H');
				LET v_Minute = TO_CHAR(v_FechaNueva, '%M');
				LET v_Second = TO_CHAR(v_FechaNueva, '%S');
				LET v_PromotorPadded = LPAD(pUsuario, 8, '0');
				LET v_FolioCancelacion = v_PromotorPadded || v_Year || v_Month || v_Day || v_Hour || v_Minute || v_Second;
				UPDATE bdicheq:si_cliente_cancela_notifica 
				SET folio_cancelacion = v_FolioCancelacion, status = '2', fecha_cancelacion = v_FechaNueva, usuario_cancela = pUsuario 
				WHERE no_cuenta = v_Cuenta;
				
				LET v_ContadorCuentasCanc = v_ContadorCuentasCanc + 1;
			ELSE
				--ELIMINA LA REFERENCIA DE LA TABLA DE TRABAJO
				DELETE FROM bdicheq:si_cliente_cancela_notifica
				WHERE status = '' AND no_cliente = v_Cliente  AND no_cuenta = v_Cuenta;
				
				LET v_ContadorCuentasNoCanc = v_ContadorCuentasNoCanc + 1;
			END IF;
			
		END FOREACH;
		RETURN cCodRet, v_ContadorCuentasCanc, v_ContadorCuentasNoCanc;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento almacenado encargado de realiza la cancelacion de las cuentas de forma masiva',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_conemppru(id_usuarioc CHAR(8), id_funcionc CHAR(10), p_Bandera CHAR(2), pNumCliente CHAR(20), pEsEmpresaPrueba CHAR(1), pNoCuenta CHAR(11))
	RETURNING CHAR(5) AS codret, CHAR(20) AS no_cliente, CHAR(1) AS es_empresa_prueba;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	

	DEFINE v_fecha_hora_alta DATETIME YEAR TO SECOND;
	DEFINE v_fecha_hora_modifica DATETIME YEAR TO SECOND;
	
	DEFINE vConteo INTEGER;
	DEFINE vNoCliente CHAR(20);
	DEFINE vEsEmpresaPrueba CHAR(1);LET v_fecha_hora_alta = CURRENT;
	LET v_fecha_hora_modifica = CURRENT;

	LET cCodRet = '00000';
	LET iSqlErr = 0;		
	LET vConteo = 0;
	LET vNoCliente = '';
	LET vEsEmpresaPrueba = 'f';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/home/mfinis/EAPT/sp_cap_conemppru.out';
		-- TRACE ON;
		
		IF p_Bandera='' OR id_usuarioc = '' OR id_funcionc = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		END IF;		
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(id_usuarioc, id_funcionc) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF p_Bandera = '1' THEN
			IF pNumCliente = '' OR pNumCliente IS NULL  THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			INSERT INTO bdicheq:si_cliente_emp_pru (no_cliente, es_empresa_prueba, usuario_alta, fecha_hora_alta) 
			VALUES (pNumCliente, pEsEmpresaPrueba, id_usuarioc, v_fecha_hora_alta);
			RETURN cCodRet, pNumCliente, pEsEmpresaPrueba;
		ELIF p_Bandera = '2' THEN
			IF pNumCliente = '' OR pEsEmpresaPrueba = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			
			SELECT COUNT(*) 
			INTO vConteo 
			FROM bdicheq:si_cliente_emp_pru 
			WHERE no_cliente = pNumCliente;
			
			IF NVL(vConteo,0) = 0 THEN
				INSERT INTO bdicheq:si_cliente_emp_pru (no_cliente, no_cuenta, es_empresa_prueba, usuario_alta, fecha_hora_alta) 
				VALUES (pNumCliente, pNoCuenta, pEsEmpresaPrueba, id_usuarioc, v_fecha_hora_alta);
			ELSE
				UPDATE bdicheq:si_cliente_emp_pru 
				SET es_empresa_prueba = pEsEmpresaPrueba, usuario_modifica = id_usuarioc, fecha_hora_modifica = v_fecha_hora_modifica
				WHERE no_cliente = pNumCliente;
			END IF;
			RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
		ELIF p_Bandera = '3' THEN
			IF pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			SELECT COUNT(*) INTO vConteo FROM bdicheq:si_cliente_emp_pru WHERE no_cliente = pNumCliente;
			IF vConteo<=0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			ELSE
				SELECT no_cliente, es_empresa_prueba
				INTO vNoCliente, vEsEmpresaPrueba
				FROM bdicheq:si_cliente_emp_pru
				WHERE no_cliente = pNumCliente;
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			
			END IF;
		ELIF p_Bandera = '4' THEN
			IF pNumCliente = '' OR pNoCuenta='' OR pEsEmpresaPrueba='' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
			IF pEsEmpresaPrueba = 't' THEN
				INSERT INTO bdicheq:si_cliente_emp_pru (no_cliente, no_cuenta, es_empresa_prueba, usuario_alta, fecha_hora_alta) 
				VALUES (pNumCliente, pNoCuenta, pEsEmpresaPrueba, id_usuarioc, v_fecha_hora_alta);
				RETURN cCodRet, vNoCliente, vEsEmpresaPrueba;
			END IF;
	
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'DESCRIPCION: Procedimiento encargado de realizar la consulta, insercion y actualizacion de clientes de tipo prueba.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cap_notifica_ctecta_can(pNumCte CHAR(20), pNumCta CHAR(20), pFechaUltMov DATE, pSaldo MONEY)
	RETURNING CHAR(5) AS codret;
	
	DEFINE iSqlErr INTEGER;
	DEFINE v_Ejecutivo CHAR(8);
	DEFINE v_Funcion CHAR(8);
	DEFINE cCodRet CHAR(5);
	DEFINE v_CodRet CHAR(5);
	DEFINE v_Cuenta CHAR(20);
	DEFINE v_NumCte CHAR(20);
	DEFINE v_Saldo MONEY;
	DEFINE v_FechaUltimoMov DATE;
	DEFINE v_IdPlantilla CHAR(12);
	DEFINE v_CodRetRegistraEvento CHAR(5);

	LET iSqlErr = 0;
	LET v_Ejecutivo = 'informix';
	LET v_Funcion = 'CCN001';
	LET cCodRet = '00017';
	LET v_CodRet = '00000';
	LET v_Cuenta = '';
	LET v_NumCte = '';
	LET v_Saldo = 0;
	LET v_FechaUltimoMov = CURRENT;
	LET v_IdPlantilla = '121212';
	LET v_CodRetRegistraEvento = '00000';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;

		END EXCEPTION;
		
		 --SET DEBUG FILE TO '/tmp/mfinis/sp_extrae_cuentascan.out';
		 --TRACE ON;
		
		IF pNumCte = '' OR pNumCta = '' OR pFechaUltMov IS NULL OR pSaldo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_extrae_cuentascan(v_Ejecutivo, v_Funcion) 
			INTO v_CodRet, v_Cuenta, v_NumCte, v_Saldo, v_FechaUltimoMov
			IF v_CodRet = '00000' THEN
				EXECUTE PROCEDURE bdinteg:sp_registra_evento ('1', '', v_IdPlantilla, v_NumCte, v_Cuenta, '', '', '', '', '', '', '', '', '', '', '', '', '', '', v_Saldo, 0,
				0, 0, 0, '', '') 
				INTO v_CodRetRegistraEvento;
				
				IF v_CodRetRegistraEvento = '00000' THEN
					INSERT INTO bdicheq:"informix".si_cliente_cancela_notifica(no_cliente, no_cuenta, fec_ultimo_mov, saldo, cliente_notificado, fecha_notificacion, folio_cancelacion, status, 
								fecha_cancelacion, usuario_cancela )
					VALUES(v_NumCte, v_Cuenta, v_FechaUltimoMov, v_Saldo, 't', CURRENT, '', '0', '', '');
				ELSE
					INSERT INTO bdicheq:"informix".si_cancela_notifica_bitacora (cod_ret, fecha_error) 
					VALUES(v_CodRetRegistraEvento, CURRENT);
				END IF;
			ELSE 
				INSERT INTO bdicheq:"informix".si_cancela_notifica_bitacora (cod_ret, fecha_error) 
				VALUES(v_CodRet, CURRENT);
			END IF;
		END FOREACH;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'FUNCIONALIDAD: Componente NotificaciÃ³n de Correo ElectrÃ³nico ',
'DESCRIPCION: Procedimiento almacenado encargado de recuperar las cuentas que se deben de notificar para el proceso de cancelacion',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_extrae_cuentascan(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret, CHAR(20) AS Cuenta, CHAR(20) AS num_cte, MONEY AS saldo, DATE AS fecha_ultimo_movimiento;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	
	DEFINE v_Cuenta CHAR(20);
	DEFINE v_Cliente CHAR(20);
	DEFINE v_RazonSocial CHAR(120);
	DEFINE v_SdoActual MONEY;
	DEFINE v_SdoCongelado MONEY;
	DEFINE v_LimSbgCCC MONEY;
	DEFINE v_ImpChqSbg MONEY;
	DEFINE v_ComPendiente MONEY;
	DEFINE v_FecUltMov DATE;
	DEFINE v_Producto CHAR(4);
	DEFINE v_ProdNoCancelacion INTEGER;
	DEFINE anio_actual INTEGER;
    DEFINE anio_pasado INTEGER;
    DEFINE mes_actual INTEGER;
	DEFINE v_Anio SMALLINT;
	
	DEFINE v_capvigprom1 MONEY; 
	DEFINE v_capvigprom2 MONEY;
	DEFINE v_capvigprom3 MONEY;
	DEFINE v_capvigprom4 MONEY; 
	DEFINE v_capvigprom5 MONEY;
	DEFINE v_capvigprom6 MONEY;
	DEFINE v_capvigprom7 MONEY;
	DEFINE v_capvigprom8 MONEY;
	DEFINE v_capvigprom9 MONEY;
	DEFINE v_capvigprom10 MONEY;
	DEFINE v_capvigprom11 MONEY;
	DEFINE v_capvigprom12 MONEY;
	
	DEFINE v_SaldoProm1 MONEY; 
	DEFINE v_SaldoProm2 MONEY;
	DEFINE v_SaldoProm3 MONEY;
	DEFINE v_SaldoProm4 MONEY; 
	DEFINE v_SaldoProm5 MONEY;
	DEFINE v_SaldoProm6 MONEY;
	DEFINE v_SaldoProm7 MONEY;
	DEFINE v_SaldoProm8 MONEY;
	DEFINE v_SaldoProm9 MONEY;
	DEFINE v_SaldoProm10 MONEY;
	DEFINE v_SaldoProm11 MONEY;
	DEFINE v_SaldoProm12 MONEY;
	
	DEFINE v_CreditosVigentes INTEGER;
	DEFINE v_CreditosVigentes1 INTEGER;
	DEFINE v_CreditosVigentes2 INTEGER;
	
	DEFINE v_AclaracionPendiente INTEGER;
	
	DEFINE v_Spei INTEGER;
	
	define v_EmpresaPrueba INTEGER;
	DEFINE v_CuentaFideicomiso INTEGER;
	DEFINE v_FechaActual DATE;
	
	DEFINE v_mes_actual INTEGER;
	
	DEFINE v_mes_anio_actual INTEGER;
	DEFINE v_mes_anio_anterior INTEGER;
	
	DEFINE v_SaldoPromedioTotal MONEY;
	
	DEFINE v_SaldoSobregirado MONEY;
	DEFINE v_SaldoActual MONEY;
	
	DEFINE v_SaldoActualSegVal MONEY;
	DEFINE v_SaldoCuenta MONEY;
	DEFINE v_CodRetRegistraEvento CHAR(5);
	DEFINE v_TotalRegCan	INTEGER;
	DEFINE cStatus_Cta	CHAR(1);

    LET v_FechaActual = TODAY;    
    LET mes_actual = MONTH(v_FechaActual);	
	LET v_capvigprom1 = 0; 
	LET v_capvigprom2 = 0;
	LET v_capvigprom3 = 0;
	LET v_capvigprom4 = 0; 
	LET v_capvigprom5 = 0;
	LET v_capvigprom6 = 0;
	LET v_capvigprom7 = 0;
	LET v_capvigprom8 = 0;
	LET v_capvigprom9 = 0;
	LET v_capvigprom10 = 0;
	LET v_capvigprom11 = 0;
	LET v_capvigprom12 = 0;
	
	LET v_SaldoProm1 = 0; 
	LET v_SaldoProm2 = 0;
	LET v_SaldoProm3 = 0;
	LET v_SaldoProm4 = 0; 
	LET v_SaldoProm5 = 0;
	LET v_SaldoProm6 = 0;
	LET v_SaldoProm7 = 0;
	LET v_SaldoProm8 = 0;
	LET v_SaldoProm9 = 0;
	LET v_SaldoProm10 = 0;
	LET v_SaldoProm11 = 0;
	LET v_SaldoProm12 = 0;
	
	LET v_SaldoPromedioTotal = 0;
	
	LET v_Anio = 0;
	
	LET v_mes_anio_actual = 0;
	LET v_mes_anio_anterior = 0;

	LET v_Cuenta = '';
	LET v_Cliente  = '';
	LET v_RazonSocial = '';
	LET v_SdoActual = 0;
	LET v_SdoCongelado = 0;
	LET v_LimSbgCCC = 0;
	LET v_ImpChqSbg = 0;
	LET v_ComPendiente = 0;
	LET v_FecUltMov = CURRENT;
	LET v_Producto = '0000';
	LET v_ProdNoCancelacion = 0;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;		
	
	LET v_SaldoSobregirado = 0;
	LET v_SaldoActual = 0;
	
	LET v_CreditosVigentes = 0;
	LET v_CreditosVigentes1 = 0;
	LET v_CreditosVigentes2 = 0;
	
	LET v_SaldoActualSegVal = 0;
	LET v_SaldoCuenta = 0;
	
	LET v_AclaracionPendiente = 0;
	LET v_EmpresaPrueba = 0;
	LET v_CuentaFideicomiso = 0;
	
	LET v_Spei = 0;
	LET v_CodRetRegistraEvento = '00000';
	LET v_TotalRegCan = 0;
	LET cStatus_Cta = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
		END EXCEPTION;
		
		SET DEBUG FILE TO '/tmp/mfinis/vero/cancelacion/sp_extrae_cuentascan.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
		END IF;		
		
		/*EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
			RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
		END IF;*/
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT chq.cuenta, cli.numcte, cli.razon_social, chq.sdo_actual, chq.sdo_cong, chq.lim_sbg_ccc, chq.imp_chq_sbg, chq.com_pendiente, chq.fec_ult_mov, chq.producto, chq.status_cta
			INTO v_Cuenta, v_Cliente, v_RazonSocial, v_SdoActual, v_SdoCongelado, v_LimSbgCCC, v_ImpChqSbg, v_ComPendiente, v_FecUltMov, v_Producto, cStatus_Cta
			FROM bdinteg:si_cliente cli
			INNER JOIN bdicheq:sc_maechq chq ON cli.numcte = chq.num_cte
			WHERE chq.producto IN ('1200','1600','2200','2600') AND cli.tpo_persona='02' AND chq.status_cta NOT IN('3','2','5') 
			AND chq.fec_ult_mov <= (TODAY - DAY(TODAY) UNITS DAY) - 12 UNITS MONTH
			
			SELECT COUNT(*) 
			INTO v_ProdNoCancelacion 
			FROM bdicheq:sc_productonocancelacion 
			WHERE producto = v_Producto;
			
			IF NVL(v_ProdNoCancelacion,0) = 0 THEN
				LET v_mes_anio_actual = mes_actual - 1;
				LET v_mes_anio_anterior = 12 - v_mes_anio_actual;
				FOREACH
					SELECT
						capvigprom1, capvigprom2, capvigprom3, capvigprom4, capvigprom5, 
						capvigprom6, capvigprom7, capvigprom8, capvigprom9, capvigprom10, 
						capvigprom11, capvigprom12, anio
					INTO 
						v_capvigprom1, v_capvigprom2, v_capvigprom3, v_capvigprom4, v_capvigprom5,
						v_capvigprom6, v_capvigprom7, v_capvigprom8, v_capvigprom9, v_capvigprom10,
						v_capvigprom11, v_capvigprom12, v_Anio
					FROM 
						bdicheq:sc_sdomensualc
					WHERE
						cuenta = v_Cuenta
					AND				
						(anio = YEAR(v_FechaActual - 12 UNITS MONTH)
					OR
						anio = YEAR(v_FechaActual - 1 UNITS MONTH))
						
					IF v_Anio = YEAR(v_FechaActual - 1) THEN
						IF v_mes_anio_anterior = 1 THEN
							LET v_SaldoProm1 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 2 THEN
							LET v_SaldoProm1 = v_capvigprom11;
							LET v_SaldoProm2 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 3 THEN
							LET v_SaldoProm1 = v_capvigprom10;
							LET v_SaldoProm2 = v_capvigprom11;
							LET v_SaldoProm3 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 4 THEN
							LET v_SaldoProm1 = v_capvigprom9;
							LET v_SaldoProm2 = v_capvigprom10;
							LET v_SaldoProm3 = v_capvigprom11;
							LET v_SaldoProm4 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 5 THEN
							LET v_SaldoProm1 = v_capvigprom8;
							LET v_SaldoProm2 = v_capvigprom9;
							LET v_SaldoProm3 = v_capvigprom10;
							LET v_SaldoProm4 = v_capvigprom11;
							LET v_SaldoProm5 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 6 THEN
							LET v_SaldoProm1 = v_capvigprom7;
							LET v_SaldoProm2 = v_capvigprom8;
							LET v_SaldoProm3 = v_capvigprom9;
							LET v_SaldoProm4 = v_capvigprom10;
							LET v_SaldoProm5 = v_capvigprom11;
							LET v_SaldoProm6 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 7 THEN
							LET v_SaldoProm1 = v_capvigprom6;
							LET v_SaldoProm2 = v_capvigprom7;
							LET v_SaldoProm3 = v_capvigprom8;
							LET v_SaldoProm4 = v_capvigprom9;
							LET v_SaldoProm5 = v_capvigprom10;
							LET v_SaldoProm6 = v_capvigprom11;
							LET v_SaldoProm7 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 8 THEN
							LET v_SaldoProm1 = v_capvigprom5;
							LET v_SaldoProm2 = v_capvigprom6;
							LET v_SaldoProm3 = v_capvigprom7;
							LET v_SaldoProm4 = v_capvigprom8;
							LET v_SaldoProm5 = v_capvigprom9;
							LET v_SaldoProm6 = v_capvigprom10;
							LET v_SaldoProm7 = v_capvigprom11;
							LET v_SaldoProm8 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 9 THEN
							LET v_SaldoProm1 = v_capvigprom4;
							LET v_SaldoProm2 = v_capvigprom5;
							LET v_SaldoProm3 = v_capvigprom6;
							LET v_SaldoProm4 = v_capvigprom7;
							LET v_SaldoProm5 = v_capvigprom8;
							LET v_SaldoProm6 = v_capvigprom9;
							LET v_SaldoProm7 = v_capvigprom10;
							LET v_SaldoProm8 = v_capvigprom11;
							LET v_SaldoProm9 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 10 THEN
							LET v_SaldoProm1 = v_capvigprom3;
							LET v_SaldoProm2 = v_capvigprom4;
							LET v_SaldoProm3 = v_capvigprom5;
							LET v_SaldoProm4 = v_capvigprom6;
							LET v_SaldoProm5 = v_capvigprom7;
							LET v_SaldoProm6 = v_capvigprom8;
							LET v_SaldoProm7 = v_capvigprom9;
							LET v_SaldoProm8 = v_capvigprom10;
							LET v_SaldoProm9 = v_capvigprom11;
							LET v_SaldoProm10 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 11 THEN
							LET v_SaldoProm1 = v_capvigprom2;
							LET v_SaldoProm2 = v_capvigprom3;
							LET v_SaldoProm3 = v_capvigprom4;
							LET v_SaldoProm4 = v_capvigprom5;
							LET v_SaldoProm5 = v_capvigprom6;
							LET v_SaldoProm6 = v_capvigprom7;
							LET v_SaldoProm7 = v_capvigprom8;
							LET v_SaldoProm8 = v_capvigprom9;
							LET v_SaldoProm9 = v_capvigprom10;
							LET v_SaldoProm10 = v_capvigprom11;
							LET v_SaldoProm11 = v_capvigprom12;
						ELIF v_mes_anio_anterior = 12 THEN
							LET v_SaldoProm1 = v_capvigprom1;
							LET v_SaldoProm2 = v_capvigprom2;
							LET v_SaldoProm3 = v_capvigprom3;
							LET v_SaldoProm4 = v_capvigprom4;
							LET v_SaldoProm5 = v_capvigprom5;
							LET v_SaldoProm6 = v_capvigprom6;
							LET v_SaldoProm7 = v_capvigprom7;
							LET v_SaldoProm8 = v_capvigprom8;
							LET v_SaldoProm9 = v_capvigprom9;
							LET v_SaldoProm10 = v_capvigprom10;
							LET v_SaldoProm11 = v_capvigprom11;
							LET v_SaldoProm12 = v_capvigprom12;
						END IF;
					ELIF v_Anio = YEAR(v_FechaActual) THEN
						IF v_mes_anio_actual = 1 THEN
							LET v_SaldoProm12 = v_capvigprom1;
						ELIF v_mes_anio_actual = 2 THEN
							LET v_SaldoProm11 = v_capvigprom1;
							LET v_SaldoProm12 = v_capvigprom2;
						ELIF v_mes_anio_actual = 3 THEN
							LET v_SaldoProm10 = v_capvigprom1;
							LET v_SaldoProm11 = v_capvigprom2;
							LET v_SaldoProm12 = v_capvigprom3;
						ELIF v_mes_anio_actual = 4 THEN
							LET v_SaldoProm9 = v_capvigprom1;
							LET v_SaldoProm10 = v_capvigprom2;
							LET v_SaldoProm11 = v_capvigprom3;
							LET v_SaldoProm12 = v_capvigprom4;
						ELIF v_mes_anio_actual = 5 THEN
							LET v_SaldoProm8 = v_capvigprom1;
							LET v_SaldoProm9 = v_capvigprom2;
							LET v_SaldoProm10 = v_capvigprom3;
							LET v_SaldoProm11 = v_capvigprom4;
							LET v_SaldoProm12 = v_capvigprom5;
						ELIF v_mes_anio_actual = 6 THEN
							LET v_SaldoProm7 = v_capvigprom1;
							LET v_SaldoProm8 = v_capvigprom2;
							LET v_SaldoProm9 = v_capvigprom3;
							LET v_SaldoProm10 = v_capvigprom4;
							LET v_SaldoProm11 = v_capvigprom5;
							LET v_SaldoProm12 = v_capvigprom6;
						ELIF v_mes_anio_actual = 7 THEN
							LET v_SaldoProm6 = v_capvigprom1;
							LET v_SaldoProm7 = v_capvigprom2;
							LET v_SaldoProm8 = v_capvigprom3;
							LET v_SaldoProm9 = v_capvigprom4;
							LET v_SaldoProm10 = v_capvigprom5;
							LET v_SaldoProm11 = v_capvigprom6;
							LET v_SaldoProm12 = v_capvigprom7;
						ELIF v_mes_anio_actual = 8 THEN
							LET v_SaldoProm5 = v_capvigprom1;
							LET v_SaldoProm6 = v_capvigprom2;
							LET v_SaldoProm7 = v_capvigprom3;
							LET v_SaldoProm8 = v_capvigprom4;
							LET v_SaldoProm9 = v_capvigprom5;
							LET v_SaldoProm10 = v_capvigprom6;
							LET v_SaldoProm11 = v_capvigprom7;
							LET v_SaldoProm12 = v_capvigprom8;
						ELIF v_mes_anio_actual = 9 THEN
							LET v_SaldoProm4 = v_capvigprom1;
							LET v_SaldoProm5 = v_capvigprom2;
							LET v_SaldoProm6 = v_capvigprom3;
							LET v_SaldoProm7 = v_capvigprom4;
							LET v_SaldoProm8 = v_capvigprom5;
							LET v_SaldoProm9 = v_capvigprom6;
							LET v_SaldoProm10 = v_capvigprom7;
							LET v_SaldoProm11 = v_capvigprom8;
							LET v_SaldoProm12 = v_capvigprom9;
						ELIF v_mes_anio_actual = 10 THEN
							LET v_SaldoProm3 = v_capvigprom1;
							LET v_SaldoProm4 = v_capvigprom2;
							LET v_SaldoProm5 = v_capvigprom3;
							LET v_SaldoProm6 = v_capvigprom4;
							LET v_SaldoProm7 = v_capvigprom5;
							LET v_SaldoProm8 = v_capvigprom6;
							LET v_SaldoProm9 = v_capvigprom7;
							LET v_SaldoProm10 = v_capvigprom8;
							LET v_SaldoProm11 = v_capvigprom9;
							LET v_SaldoProm12 = v_capvigprom10;
						ELIF v_mes_anio_actual = 11 THEN
							LET v_SaldoProm2 = v_capvigprom1;
							LET v_SaldoProm3 = v_capvigprom2;
							LET v_SaldoProm4 = v_capvigprom3;
							LET v_SaldoProm5 = v_capvigprom4;
							LET v_SaldoProm6 = v_capvigprom5;
							LET v_SaldoProm7 = v_capvigprom6;
							LET v_SaldoProm8 = v_capvigprom7;
							LET v_SaldoProm9 = v_capvigprom8;
							LET v_SaldoProm10 = v_capvigprom9;
							LET v_SaldoProm11 = v_capvigprom10;
							LET v_SaldoProm12 = v_capvigprom11;
						ELIF v_mes_anio_actual = 12 THEN
							LET v_SaldoProm1 = v_capvigprom1;
							LET v_SaldoProm2 = v_capvigprom2;
							LET v_SaldoProm3 = v_capvigprom3;
							LET v_SaldoProm4 = v_capvigprom4;
							LET v_SaldoProm5 = v_capvigprom5;
							LET v_SaldoProm6 = v_capvigprom6;
							LET v_SaldoProm7 = v_capvigprom7;
							LET v_SaldoProm8 = v_capvigprom8;
							LET v_SaldoProm9 = v_capvigprom9;
							LET v_SaldoProm10 = v_capvigprom10;
							LET v_SaldoProm11 = v_capvigprom11;
							LET v_SaldoProm12 = v_capvigprom12;
						END IF;
					END IF;
					
				END FOREACH
				LET v_SaldoPromedioTotal = v_capvigprom1 + v_capvigprom2 + v_capvigprom3 + v_capvigprom4 + v_capvigprom5 + v_capvigprom6 + v_capvigprom7 + v_capvigprom8 + v_capvigprom9 + v_capvigprom10 + v_capvigprom11 + v_capvigprom2;
				IF NVL(v_SaldoPromedioTotal,0) = 0 THEN
					FOREACH
						SELECT imp_chq_sbg, sdo_actual INTO v_SaldoSobregirado, v_SaldoActual 
						FROM bdicheq:sc_maechq WHERE cuenta = v_Cuenta AND num_cte = v_Cliente --Aqui se agrego el filtro num_cte porque devolvÃ­a mas de un registro
					END FOREACH
					IF NVL(v_SaldoSobregirado,0) = 0 THEN
						IF NVL(v_SaldoActual,0) = 0 THEN
							--Aqui va el otro calculo del saldo actual
							SELECT (cheq.sdo_actual - (cheq.sdo_retenido + cheq.sdo_cong + cheq.imp_sbg_ccc)) AS saldo_actual, bal.sdo_cta
							INTO v_SaldoActualSegVal, v_SaldoCuenta
							FROM bdicheq:sc_maechq cheq
							INNER JOIN bditransfer:tf_maecte mae ON mae.numcte_tf = cheq.num_cte
							INNER JOIN bditransfer:tf_account_balance_customer bal ON bal.cuenta = mae.cuenta_tf
							WHERE cheq.num_cte = v_Cliente  AND (mae.numcte = v_Cliente OR mae.numcte_tf = v_Cliente) AND mae.status_cta != '2' AND bal.fecha_proceso = (SELECT MAX(bal2.fecha_proceso)
						    FROM bditransfer:tf_account_balance_customer bal2
							WHERE bal2.cuenta = bal.cuenta);
							
							IF NVL(v_SaldoActualSegVal,0) = 0 AND NVL(v_SaldoCuenta,0) = 0 THEN
								SELECT COUNT(*) INTO v_CreditosVigentes FROM bdicred:sd_ctascarg WHERE num_cta = v_Cuenta AND naturaleza = naturaleza;
								IF NVL(v_CreditosVigentes,0) > 0 THEN
									SELECT count(ctascar.num_cta)
									INTO v_CreditosVigentes1
									FROM bdicred:sd_ctascarg ctascar
									INNER JOIN bdicred:sd_maecred cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
									WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
									
									SELECT count(ctascar.num_cta)
									INTO v_CreditosVigentes2
									FROM bdicred:sd_ctascarg ctascar
									INNER JOIN bdicred:sd_maecredcrd cred ON ctascar.empresa = cred.empresa AND ctascar.num_credito = cred.num_credito
									WHERE cred.numcte = v_Cliente AND ctascar.num_cta = v_Cuenta AND cred.status_cred != 'FF';
								END IF;
								-- verificar regla d ecredito vig.
								IF NVL(v_CreditosVigentes,0) = 0 and (NVL(v_CreditosVigentes1,0) = 0 and NVL(v_CreditosVigentes2,0) = 0) THEN
										SELECT count(producto.numero_cuenta)
										INTO v_AclaracionPendiente
										FROM bdiaclaracion:acl_producto producto
										INNER JOIN bdiaclaracion:acl_aclaracion aclaracion ON producto.pky_producto = aclaracion.fky_producto
										WHERE producto.numero_cuenta = v_Cuenta AND aclaracion.fky_estatus_aclaracion = '2';
										IF NVL(v_AclaracionPendiente,0) = 0 THEN -- ajuste
											SELECT COUNT(*) 
											INTO v_EmpresaPrueba
											FROM bdicnweb:si_cliente_emp_pru
											WHERE no_cliente = v_Cliente;
											
											IF NVL(v_EmpresaPrueba,0) = 0 THEN
												SELECT COUNT(*) 
												INTO v_CuentaFideicomiso
												FROM bdinteg:si_ctepm 
												WHERE numcte = v_Cliente AND 
												(giro IS NULL OR giro = '' OR actividadsocial IS NULL OR actividadsocial = '' OR sufijo IS NULL OR sufijo = '' OR telefono_contacto IS NULL OR telefono_contacto = '' 
														OR tipo_poder IS NULL OR tipo_poder = '' OR tipo_admon IS NULL OR tipo_admon = '' OR tipo_org IS NULL OR tipo_org = '');
												IF NVL(v_CuentaFideicomiso,0) = 0 THEN -- ajuste
													SELECT COUNT(*) 
													INTO v_Spei
													FROM bdicheq:sc_movdia 
													WHERE cuenta = v_Cuenta AND transacc = '0274';
													IF v_Spei = 0 THEN
														SELECT COUNT(*)
														INTO v_TotalRegCan
														FROM bdicheq:"informix".si_cliente_cancela_notifica
														WHERE no_cliente = v_Cliente AND no_cuenta = v_Cuenta;
														IF NVL(v_TotalRegCan,0) = 0 THEN 
															--Aqui se ejecuta el SPL para envio de notifiaciÃ³n
															EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CTAS_INAC','COR_CAN_CTAI',v_Cliente,v_Cuenta,'','2','5426','','','','','','','','','','','',0,0,0,0,0,CURRENT,'')
															INTO v_CodRetRegistraEvento;
															IF v_CodRetRegistraEvento = '00000' THEN
																INSERT INTO bdicheq:"informix".si_cliente_cancela_notifica(no_cliente, no_cuenta, fec_ultimo_mov, saldo, cliente_notificado, fecha_notificacion, folio_cancelacion, status, fecha_cancelacion, usuario_cancela, status_ant)
																VALUES(v_Cliente, v_Cuenta, v_FecUltMov, v_SdoActual, 't', CURRENT, '', '', '', '', cStatus_Cta);
															ELSE
																INSERT INTO bdicheq:"informix".si_cancela_notifica_bitacora (cod_ret, fecha_error) 
																VALUES(v_CodRetRegistraEvento, CURRENT);
															END IF;
														END IF;
													END IF;
												END IF;
											END IF;
										END IF;
									--END IF;
								END IF;
							END IF;							
							--Aqui termina el calculo del saldo actual
						END IF;
					END IF;
				END IF;
			END IF;
		END FOREACH
		RETURN cCodRet, v_Cuenta, v_Cliente, v_SdoActual, v_FecUltMov;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Ãvila PÃ©rez Tagle',
'FECHA: 24/09/2025',
'Requerimiento: RQM 20 129 DEF AutomatizaciÃ³n de cancelaciÃ³n de cuentas inactivas',
'FUNCIONALIDAD:',
'DESCRIPCION: ',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_com_manejo_cta_ident_1()
    RETURNING CHAR(5), VARCHAR(80);
-- *****************************************************************************
-- Version          1.0.0
-- Objetivo:        Toma un cliente y analiza sus cuentas para
--                   decidir si se le cobrara la "Comision por Manejo de
--                   Cuenta", las cuentas que deben pagar son guardadas en la
--                   tabla sc_com_manejo_ctas_a_cobrar.
-- Creado por:      Joel Martinez
-- Fecha:           Septiembre - 2024
-- *****************************************************************************
    
    DEFINE vNumHilo                 SMALLINT;
    DEFINE vCodRet                  CHAR(5);
    DEFINE vErrorInfo               VARCHAR(80);
    DEFINE vIsamErr                 SMALLINT;
    DEFINE vSQLErr                  INTEGER;
    DEFINE vEmpresa                 CHAR(3);
    DEFINE vFechaInicial            DATE;
    DEFINE vFechaFinal              DATE;
    DEFINE vAnioMes                 CHAR(6);
    DEFINE vSdoPromMinGral          INTEGER;
    DEFINE vSdoPromMin2500          INTEGER;
    DEFINE vUltimoCteHiloAnterior   CHAR(20);
    DEFINE vUltimoCteHiloActual     CHAR(20);
    DEFINE vFechConMovHis           DATE;
    DEFINE vUltimoCteProcesado      CHAR(20);
    DEFINE vFechaHoraFinIniciador   DATETIME YEAR TO FRACTION(3);
    DEFINE vFechaHoraIni            DATETIME YEAR TO FRACTION(3);
    DEFINE vStatusPrevio            VARCHAR(10);
    DEFINE vStatusIniciador         VARCHAR(10);
    DEFINE vIndice                  SMALLINT;
    DEFINE vConfStatus              VARCHAR(60);
    DEFINE vConfProductos           VARCHAR(60);
    DEFINE vCharAux                 CHAR(1);
    DEFINE vStringAux               VARCHAR(4);
    DEFINE vExisteTMP               SMALLINT;
    DEFINE vExisteTMP2              SMALLINT;
    DEFINE vExisteTMP3              SMALLINT;
    DEFINE vExisteTMP4              SMALLINT;
    DEFINE vExisteTMP5              SMALLINT;
    DEFINE vContCtasInsertadas      INTEGER;
    DEFINE vNumCte                  CHAR(20);
    DEFINE vCuenta                  CHAR(20);
    DEFINE vSucursal                CHAR(4);
    DEFINE vCantCtasProcesadas      INTEGER;
    DEFINE vCantCtasIdentificadas   INTEGER;
    DEFINE vCantCtasInversion       SMALLINT;
    DEFINE vCantCtasPagare          SMALLINT;
    DEFINE vCantMovHis              SMALLINT;
    DEFINE vCantMovHisOld           SMALLINT;
    DEFINE cCantMovCred             SMALLINT;
    DEFINE vParamMontCargo          MONEY(14,2);
    DEFINE vArchivoSQL              CHAR(50);
    DEFINE vSQL                     CHAR(350);
   
    LET vNumHilo                = 1;
    LET vCodRet                 = "00000";
    LET vEmpresa                = "001";
    LET vErrorInfo              = '';
    LET vIsamErr                = 0;
    LET vSQLErr                 = 0; 
    LET vFechaInicial           = '';
    LET vFechaFinal             = '';
    LET vAnioMes                = '';
    LET vSdoPromMinGral         = 0;
    LET vSdoPromMin2500         = 0;
    LET vUltimoCteHiloAnterior  = '';
    LET vUltimoCteHiloActual    = ''; 
    LET vFechConMovHis          = '';
    LET vUltimoCteProcesado     = '';
    LET vFechaHoraFinIniciador  = '';
    LET vFechaHoraIni           = '';
    LET vStatusPrevio           = '';
    LET vStatusIniciador        = '';
    LET vIndice                 = 0;
    LET vConfStatus             = '';
    LET vConfProductos          = '';
    LET vCharAux                = '';
    LET vStringAux              = '';
    LET vExisteTMP              = 0;
    LET vExisteTMP2             = 0;
    LET vExisteTMP3             = 0;
    LET vExisteTMP4             = 0;
    LET vExisteTMP5             = 0;
    LET vContCtasInsertadas     = 0;
    LET vNumCte                 = '';
    LET vCuenta                 = '';
    LET vSucursal               = '';
    LET vCantCtasProcesadas     = 0;
    LET vCantCtasIdentificadas  = 0; 
    LET vCantCtasInversion      = 0;
    LET vCantCtasPagare         = 0;
    LET vCantMovHis             = 0;
    LET vCantMovHisOld          = 0;
    LET cCantMovCred            = 0;
    LET vParamMontCargo         = 150.00;
    LET vArchivoSQL             = "/resplogifx/conciliachq/updatebitacora" || vNumHilo ||".sql";
    LET vSQL                    = '';

    BEGIN
    ON EXCEPTION SET vSQLErr, vIsamErr, vErrorInfo
        IF  vSQLErr != 0 THEN
            SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_1.err';
            TRACE ON;
            LET vCodRet     = vSQLErr;
            LET vIsamErr    = vIsamErr;
            LET vErrorInfo   = vErrorInfo;
            LET vNumCte     = vNumCte;
            LET vCuenta     = vCuenta;
        
            IF vExisteTMP = 1 THEN
                DROP TABLE tmp_conf_status;
                DROP TABLE tmp_conf_productos; 
            END IF;
        
            IF vExisteTMP2 = 1 THEN
                DROP TABLE tmp_ctas_total;
                DROP TABLE tmp_ctas_cte;
            END IF;
        
            IF vExisteTMP3 = 1 THEN
                DROP TABLE tmp_ctes_exentos;
            END IF;

            IF vExisteTMP4 = 1 THEN
                DROP TABLE tmp_ctes_sin_sdo_prom;
            END IF;

            IF vExisteTMP5 = 1 THEN
                DROP TABLE tmp_ctes_sin_presperban;
            END IF;
        
            IF vContCtasInsertadas > 0 THEN
                ROLLBACK;
            END IF;
        
            RETURN vCodRet, vErrorInfo;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_com_manejo_cta_ident_1.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;  
    
    /**************************************************************************/
    /*                         CONSULTA DE PARAMETROS                         */
    /**************************************************************************/
    -- El periodo a procesar, sera del primero al ultimo dia del mes anterior
    SELECT DATE( pri_dia_mes - 1 UNITS MONTH ),
    DATE( pri_dia_mes - 1 UNITS DAY )
    INTO vFechaInicial, vFechaFinal
    FROM sc_fechas
    WHERE empresa = vEmpresa;
    
    -- Extrae aÃ±o y mes que se procesara
    LET vAnioMes = TO_CHAR(vFechaInicial,"%Y%m");

    -- Saldo promedio minimo general
    SELECT valor 
    INTO vSdoPromMinGral
    FROM sc_param
    WHERE codparam = "sdoprom";

    -- Saldo promedio minimo para producto 2500
    SELECT valor 
    INTO vSdoPromMin2500
    FROM sc_param
    WHERE codparam = "sdoprom_2500";
    
    -- Obtiene el ultimo cte que atendera este hilo
    SELECT valor 
    INTO vUltimoCteHiloActual
    FROM sc_param 
    WHERE codparam = "UltCteIdentComMC" || vNumHilo;

    -- Fecha de concentrado de la tabla sc_movhis_old
    SELECT TO_DATE(valor, '%m/%d/%Y')
    INTO vFechConMovHis
    FROM sc_param 
    WHERE codparam = "fechcon_movhis";
    
    -- Se obtienen los status de las cuentas a considerar
    SELECT valor
    INTO vConfStatus
    FROM sc_param
    WHERE codparam = "IdenComMCStatus";
    
    -- Se obtienen los productos de las cuentas a considerar
    SELECT valor
    INTO vConfProductos
    FROM sc_param
    WHERE codparam = "IdenComMCProductos";
    /**************************************************************************/
    /*                      [FIN] CONSULTA DE PARAMETROS                      */
    /**************************************************************************/

    /**************************************************************************/
    /*     GUARDA STATUS Y PRODUCTOS CONFIGURADOS EN TABLAS TEMPORALES        */
    /**************************************************************************/
    CREATE TEMP TABLE tmp_conf_status (
        status CHAR(1)) WITH NO LOG;

    CREATE TEMP TABLE tmp_conf_productos (
        producto CHAR(4)) WITH NO LOG;
    
    LET vExisteTMP = 1;

    -- Ciclo que extrae los status y los inserta en la tabla temporal
    FOR vIndice = 1 TO LENGTH( vConfStatus )
        LET vCharAux = SUBSTR( vConfStatus, vIndice, 1 );
        IF vCharAux IN ( '1', '2', '3', '5', '6', '7', '8', '9' ) THEN
            INSERT INTO tmp_conf_status ( status ) 
                VALUES ( vCharAux );
        END IF;
    END FOR;
    
    -- Ciclo que extrae los productos y los inserta en la tabla temporal
    FOR vIndice = 1 TO LENGTH( vConfProductos )
        LET vCharAux = SUBSTR( vConfProductos, vIndice, 1 );
        IF vCharAux IN ( '1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
            LET vStringAux = vStringAux || vCharAux;
            IF LENGTH( vStringAux ) > 3 THEN
                INSERT INTO tmp_conf_productos ( producto ) 
                    VALUES ( vStringAux );    
                LET vStringAux = '';
            END IF;
        ELSE
            LET vStringAux = '';
        END IF;
    END FOR;

    /**************************************************************************/
    /*    [FIN] GUARDA STATUS Y PRODUCTOS CONFIGURADOS EN TABLAS TEMPORALES   */
    /**************************************************************************/

    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Revisa que la ultima ejecucion del proceso iniciador haya concluido
    FOREACH 
        SELECT FIRST 1 status, fecha_hora_fin
        INTO vStatusIniciador, vFechaHoraFinIniciador
        FROM sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes
        AND etapa = 'INICIA IDENTIFICACION'
        ORDER BY fecha_hora_fin DESC
    END FOREACH;

    IF  vStatusIniciador <> 'FINALIZADO' THEN
        -- Error, el proceso iniciador no ha finalizado
        DROP TABLE tmp_conf_status;
        DROP TABLE tmp_conf_productos;
        LET vCodRet = "00002";
        LET vErrorInfo = "Error: El proceso iniciador no ha finalizado";
        RETURN vCodRet, vErrorInfo;
    END IF;

    -- Revisa si hay una ejecucion previa de este hilo
    FOREACH
        SELECT FIRST 1 status, fecha_hora_ini 
        INTO vStatusPrevio, vFechaHoraIni
        FROM sc_bitacora_com_manejo_cta 
        WHERE aniomes = vAnioMes
        AND etapa = 'IDENTIFICACION'
        AND hilo = vNumHilo
        AND fecha_hora_ini > vFechaHoraFinIniciador
        ORDER BY fecha_hora_ini DESC
    END FOREACH;

    IF vStatusPrevio = 'FINALIZADO' THEN 
        -- Se cancela todo, el proceso ya se ha finalizado previamente
        DROP TABLE tmp_conf_status;
        DROP TABLE tmp_conf_productos;
        LET vCodRet = "00003";
        LET vErrorInfo = "Este hilo ya ha finalizado en una ejecucion previa";
        RETURN vCodRet, vErrorInfo;
    END IF;

    IF vStatusPrevio = 'EN PROCESO' THEN 
        -- Retoma donde se quedo la ejecucion previa inconclusa
        SELECT MAX( cliente )
        INTO vUltimoCteProcesado
        FROM sc_com_manejo_ctas_a_cobrar
        WHERE cliente <= vUltimoCteHiloActual;

    ELSE
        -- Registra el inicio de la nueva ejecucion
        LET vFechaHoraIni = CURRENT;

        INSERT INTO sc_bitacora_com_manejo_cta (aniomes, etapa, hilo, status, fecha_hora_ini)
            VALUES (vAnioMes, 'IDENTIFICACION', vNumHilo, 'EN PROCESO', vFechaHoraIni);
    END IF;
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/

    /**************************************************************************/
    /*                           PROCESO PRINCIPAL                            */
    /**************************************************************************/
    -- Se valida si ya hay clientes procesados
    IF vUltimoCteProcesado IS NULL OR vUltimoCteProcesado == '' THEN
        -- No se ha procesado ni un cliente, se inicia despues del hilo anterior
        LET vUltimoCteProcesado = vUltimoCteHiloAnterior;
    END IF;

    -- Obtiene las cuentas que procesara este hilo
    --Insert Into tmp_ctas_total_cte
    SELECT chq.num_cte, chq.cuenta, chq.producto, chq.sucursal, 
    (sdo.capvigacum / sdo.diacum) AS sdo_prom
    FROM sc_maechq AS chq
    INNER JOIN tmp_conf_status AS c_stat ON chq.status_cta = c_stat.status
    INNER JOIN tmp_conf_productos AS c_prod ON chq.producto = c_prod.producto
    INNER JOIN sc_maenoc AS noc ON chq.num_cte > vUltimoCteProcesado
    AND chq.num_cte <= vUltimoCteHiloActual AND noc.fecha_alta < vFechaInicial
    AND chq.cuenta = noc.cuenta
    LEFT JOIN sc_sdodiarioc AS sdo ON sdo.aniomes = vAnioMes AND chq.cuenta = sdo.cuenta
    WHERE chq.empresa = vEmpresa
    INTO TEMP tmp_ctas_total WITH NO LOG;

    -- Tabla temporal para guardar las cuentas de un cliente siendo evaluado
    CREATE TEMP TABLE tmp_ctas_cte (
        cuenta CHAR(20),
        sucursal CHAR(4)) WITH NO LOG;
    LET vExisteTMP2 = 1;

    CREATE INDEX idx_tmp_ctas_total ON tmp_ctas_total(num_cte) 
        USING BTREE;
    CREATE INDEX idx_tmp_ctas_total2 ON tmp_ctas_total( producto, sdo_prom ) 
        USING BTREE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctas_total;

    DROP TABLE tmp_conf_status;
    DROP TABLE tmp_conf_productos;
    LET vExisteTMP = 0;

    -- Si es la primer ejecucion, se guarda cuantas cuentas procesa este hilo
    IF vStatusPrevio = '' THEN
        SELECT COUNT(*)
        INTO vCantCtasProcesadas
        FROM tmp_ctas_total;

        UPDATE sc_bitacora_com_manejo_cta 
        SET cuentas_procesadas = vCantCtasProcesadas
        WHERE aniomes = vAnioMes
        AND etapa = 'IDENTIFICACION'
        AND hilo = vNumHilo
        AND status = 'EN PROCESO'
        AND fecha_hora_ini = vFechaHoraIni;
    END IF;

    -- Tabla temporal que guarda los clientes que exentan por saldo promedio y prestamo personal BanCoppel
    CREATE TEMP TABLE tmp_ctes_exentos (
        num_cte CHAR(20)) WITH NO LOG;
    CREATE INDEX idx_tmp_ctes_exentos ON tmp_ctes_exentos(num_cte);
    LET vExisteTMP3 = 1;

    /* EXENCION POR CUMPLIR CON SALDO PROMEDIO MINIMO */
    INSERT INTO tmp_ctes_exentos (num_cte)
    SELECT num_cte
    FROM tmp_ctas_total 
    WHERE producto <> "2500" 
    AND sdo_prom >= vSdoPromMinGral;

    INSERT INTO tmp_ctes_exentos (num_cte)
    SELECT num_cte
    FROM tmp_ctas_total 
    WHERE producto = "2500" 
    AND sdo_prom >= vSdoPromMin2500;
            
    SELECT DISTINCT( num_cte )
    FROM tmp_ctas_total AS ctas
    WHERE NOT EXISTS(SELECT 1 
                    FROM tmp_ctes_exentos AS exentos 
                    WHERE ctas.num_cte = exentos.num_cte)
    INTO TEMP tmp_ctes_sin_sdo_prom WITH NO LOG;
    LET vExisteTMP4 = 1;
    CREATE INDEX idx_tmp_ctes_sin_sdo_prom ON tmp_ctes_sin_sdo_prom( num_cte );
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_sin_sdo_prom;
    /* [FIN] EXENCION POR CUMPLIR CON SALDO PROMEDIO MINIMO */

    DROP TABLE tmp_ctes_exentos;
    LET vExisteTMP3 = 0;

    -- Ciclo principal que procesa las cuentas
    FOREACH WITH HOLD
        SELECT num_cte
        INTO vNumCte
        FROM tmp_ctes_sin_sdo_prom
        ORDER BY num_cte ASC
        
        DELETE FROM tmp_ctas_cte;

        /*   EXENCION POR CUENTA INVERSION CRECIENTE   */
        SELECT COUNT(*)
        INTO vCantCtasInversion
        FROM sc_maechq AS chq 
        WHERE chq.num_cte = vNumCte
        AND chq.producto = "1100"
        AND chq.status_cta = '1';
                
        IF vCantCtasInversion > 0 THEN 
            -- si entra aqui, es porque este cte exento, se salta al siguiente
            CONTINUE FOREACH;
        END IF;

        /*         EXENCION POR CUENTA PAGARE          */
        SELECT COUNT(*)
        INTO vCantCtasPagare
        FROM bdinvers:sv_maeinv AS inv 
        WHERE inv.num_cte = vNumCte
        AND inv.cod_instrum = "3000"
        AND inv.status_cta = '1';

        IF vCantCtasPagare > 0 THEN
            -- si entra aqui, es porque este cte exento, se salta al siguiente
            CONTINUE FOREACH;
        END IF; 
    
        /*     EXENCION POR MOVIMIENTO DE PORTABILIDAD DE NOMINA     */
        FOREACH WITH HOLD
            SELECT cuenta, sucursal
            INTO vCuenta, vSucursal
            FROM tmp_ctas_total
            WHERE num_cte = vNumCte

            SELECT COUNT(*) 
            INTO vCantMovHis
            FROM sc_movhis AS mov
            WHERE mov.empresa  = vEmpresa
            AND mov.cuenta = vCuenta
            AND mov.fech_alt BETWEEN vFechaInicial AND vFechaFinal
            AND mov.cancelad <> 'S'
            AND mov.transacc = "0273"
            AND mov.referencia LIKE "%NNNN%";
            
           IF vCantMovHis > 0 THEN
                -- si entra aqui es porque la cuenta exento
                -- se exentan todas las ctas del cte
                DELETE FROM tmp_ctas_cte;
                EXIT FOREACH;

           END IF;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            IF vFechaInicial < vFechConMovHis THEN
                SELECT COUNT(*)
                INTO vCantMovHisOld
                FROM sc_movhis_old AS mov 
                WHERE mov.empresa  = vEmpresa
                AND mov.cuenta = vCuenta
                AND mov.fech_alt BETWEEN vFechaInicial AND vFechaFinal
                AND mov.cancelad <> 'S'
                AND mov.transacc = "0273"
                AND mov.referencia LIKE "%NNNN%";
                        
                IF vCantMovHisOld > 0 THEN
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    DELETE FROM tmp_ctas_cte;
                    EXIT FOREACH;
                END IF;
            END IF;
            /*  [FIN] EXENCION POR MOVIMIENTO DE PORTABILIDAD DE NOMINA   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            INSERT INTO tmp_ctas_cte (cuenta, sucursal )
                VALUES ( vCuenta, vSucursal );
        END FOREACH;

        /*     EXENCION POR CARGO RECURRENTE     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc = '1141' and monto_tot >= vParamMontCargo
            Having count(*) > 1;
            
            If vCantMovHis >= 2 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc = '1141' and monto_tot >= vParamMontCargo
                Having count(*) > 1;
                        
                If vCantMovHisOld >= 2 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR CARGO RECURRENTE   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        /*     EXENCION POR PRESTAMO PERSONAL BANCOPPEL     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc = '0548';
            
            If vCantMovHis > 0 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc = '0548';
                        
                If vCantMovHisOld > 0 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR PRESTAMO PERSONAL BANCOPPEL   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        /*     EXENCION POR PRESTAMO PERSONAL COPPEL     */
        FOREACH WITH HOLD
            Select cuenta, sucursal
            Into vCuenta, vSucursal
            From tmp_ctas_total
            Where num_cte = vNumCte and producto <> '2500'

            Select count(*)
            Into vCantMovHis
            From bdicheq:sc_movhis
            Where empresa = vEmpresa and cuenta = vCuenta
            and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
            and transacc in('0253', '1667');
            
            If vCantMovHis > 0 Then
                -- Si entra aqui es porque la cuenta exento
                -- Se exentan todas las ctas del cte
                Delete From tmp_ctas_cte;
                Exit Foreach;
            End If;

            -- Se revisa tambien la tabla sc_movhis_old cuando el rango de
            -- fechas analizado no se encuentra por completo en la sc_movhis
            If vFechaInicial < vFechConMovHis Then
                Select count(*)
                Into vCantMovHisOld
                From sc_movhis_old
                Where empresa = vEmpresa and cuenta = vCuenta
                and fech_alt Between vFechaInicial and vFechaFinal and cancelad <> 'S'
                and transacc in('0253', '1667');
                        
                If vCantMovHisOld > 0 Then
                    -- si entra aqui es porque la cuenta exento
                    -- se exentan todas las ctas del cte
                    Delete From tmp_ctas_cte;
                    Exit Foreach;
                End If;
            End If;

            /*  [FIN] EXENCION POR PRESTAMO PERSONAL COPPEL   */

            -- Si llega a este punto, es porque la cta no exento la comision, se
            -- guarda en una tmp a esperar evaluar las demas cuentas del cte
            Insert Into tmp_ctas_cte (cuenta, sucursal )
                Values (vCuenta, vSucursal);
        END FOREACH;

        -- Si llega a este punto, significa que ninguna cta del cte ha exentado
        -- por lo que se guardan en la tabla sc_com_manejo_ctas_a_cobrar
        FOREACH WITH HOLD
            SELECT cuenta, sucursal
            INTO vCuenta, vSucursal
            FROM tmp_ctas_cte
            Group By cuenta, sucursal

            IF vContCtasInsertadas = 0 THEN
                BEGIN WORK;
            END IF;

            LET vContCtasInsertadas = vContCtasInsertadas + 1;

            INSERT INTO sc_com_manejo_ctas_a_cobrar ( cliente, cuenta, sucursal )
                VALUES ( vNumCte, vCuenta, vSucursal );
                    
        END FOREACH;        

        IF vContCtasInsertadas >= 5000 THEN
            LET vContCtasInsertadas = 0;
            COMMIT WORK;
        END IF; 
        
    END FOREACH;

    -- Se valida si hay inserts pendientes de commits
    IF vContCtasInsertadas > 0 THEN
        LET vContCtasInsertadas = 0;
        COMMIT WORK;
    END IF;

    /**************************************************************************/
    /*                       [FIN] PROCESO PRINCIPAL                          */
    /**************************************************************************/
    
    /**************************************************************************/
    /*                         REGISTRO EN BITACORA                           */
    /**************************************************************************/
    -- Obtiene la cantidad de cuentas identificadas
    SELECT COUNT(*)
    INTO vCantCtasIdentificadas
    FROM sc_com_manejo_ctas_a_cobrar
    WHERE cliente <= vUltimoCteHiloActual;
     
    LET vSQL = 'echo "UPDATE sc_bitacora_com_manejo_cta' ||
                ' SET fecha_hora_fin = CURRENT,' ||
                ' status = ''FINALIZADO'',' ||
                ' cuentas_identificadas = ' || vCantCtasIdentificadas ||
                ' WHERE aniomes = ''' || vAnioMes || '''' ||
                ' AND etapa = ''IDENTIFICACION''' ||
                ' AND hilo = ' || vNumHilo ||
                ' AND status = ''EN PROCESO''' ||
                ' AND fecha_hora_ini = ''' || vFechaHoraIni || '''' ||
                ';" > '|| vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "chmod 777 " || vArchivoSQL;
    SYSTEM vSQL;
    LET vSQL = "dbaccess bdicheq " || vArchivoSQL;
    SYSTEM vSQL;

    -- Actualiza el registro de totales
    UPDATE sc_bitacora_com_manejo_cta
    SET cuentas_identificadas = 
    ( cuentas_identificadas + vCantCtasIdentificadas )::INTEGER
    WHERE aniomes = vAnioMes
    AND etapa = 'TOTALES';
    /**************************************************************************/
    /*                       [FIN] REGISTRO EN BITACORA                       */
    /**************************************************************************/
    --DROP TABLE tmp_ctas_total;
    DROP TABLE tmp_ctas_cte;
    DROP TABLE tmp_ctes_sin_sdo_prom;
        
    RETURN vCodRet, vErrorInfo;
    END
END PROCEDURE;