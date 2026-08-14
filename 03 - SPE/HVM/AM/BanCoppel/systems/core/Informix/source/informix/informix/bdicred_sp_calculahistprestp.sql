CREATE PROCEDURE "informix".sp_calculahistprestp(cEmpresa CHAR(3),cFecha date)
												
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Calcula el cargo y abonos, para prestamo personal
--Realizó: Richar 
--Fecha: 25/02/2015
--------------------------------------------------------------------													
--cTipoConcil = tipo de conciliacion 1=Saldos 2 = movimientos
--cTipoProd = 4 Credi nomina

							
    --DATOS A REGRESAR---	
	RETURNING CHAR(5);	--codret
              

			  /*
			   CHAR(40),	--nomproducto
              Char(40), --Concepto
              Char(20), --Nivel contable
              Money(18,2), --Saldo Operativo
              Money(18,2), --Saldo contable
			  */
			  
	--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	
	DEFINE vFechaHoy date; --Para obtener la fecha de hoy desde la sd_fechas
    DEFINE vMontoFinDiaAnt  Money(18,2); --Para obtener el monto del saldo fin de la fecha anterior
	DEFINE vMontoFinDiaAct  Money(18,2); --Para obtener el monto del saldo fin de la fecha actual
   
   
	--	Variables para las cuentas
	DEFINE vCtaCapVigPrest 			Char(14);
	DEFINE vCtaCapTransPrest 		Char(14);
	DEFINE vCtaCapNoExigPrest 		Char(14);	
	DEFINE vCtaCapExigPrest 		Char(14);
	DEFINE vCtaInteresVigPrest 		Char(14);
	DEFINE vCtaInteresVenPrest		Char(14);
	DEFINE vCtaInteresVenDOrPrest 	Char(14);
	DEFINE vCtaIVAInteresPrest		Char(14);
	DEFINE vCtaIVAInteresOrPrest	Char(14);

	
	--Variables para los saldos del sif para prestamo personal en cargo y abono
	DEFINE vSdoCapVigPrest 			Money(18,2);
	DEFINE vSdoCapVigPrest_a		Money(18,2);
	DEFINE vSdoCapTransPrest 		Money(18,2);
	DEFINE vSdoCapTransPrest_a 		Money(18,2);
	DEFINE vSdoCapNoExigPrest 		Money(18,2);
	DEFINE vSdoCapNoExigPrest_a 	Money(18,2);
	DEFINE vSdoCapExigPrest 		Money(18,2);
	DEFINE vSdoCapExigPrest_a 		Money(18,2);
	DEFINE vSdoInteresVigPrest 		Money(18,2);
	DEFINE vSdoInteresVigPrest_a 	Money(18,2);
	DEFINE vSdoInteresVenPrest		Money(18,2);
	DEFINE vSdoInteresVenPrest_a	Money(18,2);
	DEFINE vSdoInteresVenDOrPrest 	Money(18,2);
	DEFINE vSdoInteresVenDOrPrest_a Money(18,2);
	DEFINE vSdoIVAInteresPrest		Money(18,2);
	DEFINE vSdoIVAInteresPrest_a	Money(18,2);
	DEFINE vSdoIVAInteresOrPrest	Money(18,2);
	DEFINE vSdoIVAInteresOrPrest_a	Money(18,2);
	
	
	--Variables para los saldos del sif para prestamo personal en cargo y abono
	DEFINE vSdoCapVigPrestCnt 			integer;
	DEFINE vSdoCapVigPrest_acnt			integer;
	DEFINE vSdoCapTransPrestCnt 		integer;
	DEFINE vSdoCapTransPrest_aCnt 		integer;
	DEFINE vSdoCapNoExigPrestCnt 		integer;
	DEFINE vSdoCapNoExigPrest_aCnt 		integer;
	DEFINE vSdoCapExigPrestCnt 			integer;
	DEFINE vSdoCapExigPrest_aCnt 		integer;
	DEFINE vSdoInteresVigPrestCnt 		integer;
	DEFINE vSdoInteresVigPrest_aCnt 	integer;
	DEFINE vSdoInteresVenPrestCnt		integer;
	DEFINE vSdoInteresVenPrest_aCnt		integer;
	DEFINE vSdoInteresVenDOrPrestCnt 	integer;
	DEFINE vSdoInteresVenDOrPrest_aCnt 	integer;
	DEFINE vSdoIVAInteresPrestCnt		integer;
	DEFINE vSdoIVAInteresPrest_aCnt		integer;
	DEFINE vSdoIVAInteresOrPrestCnt		integer;
	DEFINE vSdoIVAInteresOrPrest_aCnt	integer;
	
	
	--Variables para los saldos
	DEFINE vSdoCapVig 			Money(18,2);
	DEFINE vSdoCapTrans 		Money(18,2);
	DEFINE vSdoCapNoExig 		Money(18,2);
	DEFINE vSdoCapExig 			Money(18,2);
	DEFINE vSdoInteresVig 		Money(18,2);
	DEFINE vSdoInteresVen		Money(18,2);
	DEFINE vSdoInteresVenDOr 	Money(18,2);
	DEFINE vSdoIVAInteres		Money(18,2);
	DEFINE vSdoIVAInteresOr		Money(18,2);
	
	DEFINE v_dFechaUno			date;
	DEFINE v_iDia				int;
	
	
	
	--Variables para los saldos de contabilidad		
	DEFINE vSdoCapVigCont 		Money(18,2);
	DEFINE vSdoCapTransCont 	Money(18,2);
	DEFINE vSdoCapNoExigCont 	Money(18,2);
	DEFINE vSdoCapExigCont 		Money(18,2);
	DEFINE vSdoInteresVigCont 	Money(18,2);
	DEFINE vSdoInteresVenCont	Money(18,2);
	DEFINE vSdoInteresVenDOrCont Money(18,2);
	DEFINE vSdoIVAInteresCont	Money(18,2);
	DEFINE vSdoIVAInteresOrCont	Money(18,2);
	
	
		
	--Banderas
	DEFINE v_paso				varchar(50);
	
	--INICIALIZACION DE VARIABLES--
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	
	--Cuentas para el prestamo personal
	LET vCtaCapVigPrest ='13110202010032';
	LET vCtaCapTransPrest ='13110202030032';
	LET vCtaCapNoExigPrest ='13610202010232';
	LET vCtaCapExigPrest ='13610202010132';
	LET vCtaInteresVigPrest ='13110202020032';
	LET vCtaInteresVenPrest	='13610202020132';
	LET vCtaInteresVenDOrPrest ='77106102020132';
	LET vCtaIVAInteresPrest ='14020305110232';
	LET vCtaIVAInteresOrPrest ='78376102020132';
							
	LET vSdoCapVigCont =0;
	LET vSdoCapTransCont =0;
	
	
	LET vSdoCapVig =0;
	LET vSdoCapTrans =0;
	LET vSdoCapNoExig =0;
	LET vSdoCapExig =0;
	LET vSdoInteresVig =0;
	LET vSdoInteresVen =0;
	LET vSdoInteresVenDOr =0;
	LET vSdoIVAInteres =0;
	LET vSdoIVAInteresOr =0;	
	
	
	
	LET v_paso ='';
		
	--SET DEBUG FILE TO "/home/sysifx/sp_calculahistprestp.out";
	--TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--Obtenemos la fecha del día de hoy de la sd_fechas
		select fecha_hoy 
		into vFechaHoy
		from bdicred:sd_fechas;

		If vFechaHoy = '' or vFechaHoy is null then
			LET vFechaHoy = today();
		End if;
		
		
		IF cFecha is null or cFecha='' then		
			select fecha_hoy 
			into cFecha
			from bdicred:sd_fechas;		
		End if;
		
		let v_dFechaUno= (cFecha - day(cFecha)) + 1;		
		let v_iDia = DAY(cFecha);
								
		select a.num_credito,
				   sum(case when trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) = '13110202010032' then monto else 0 end) capital_vigente_cargo,
				   sum(case when trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) = '13110202010032' then monto else 0 end) capital_vigente_abono, 
				   sum(case when trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) = '13110202030032' then monto else 0 end) capital_transitorio_cargo,
				   sum(case when trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) = '13110202030032' then monto else 0 end) capital_transitorio_abono,
				   sum(case when trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) = '13610202010132' then monto else 0 end) capital_exigible_cargo,
				   sum(case when trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) = '13610202010132' then monto else 0 end) capital_exigible_abono,
				   sum(case when trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) = '13610202010232' then monto else 0 end) capital_no_exigible_cargo,
				   sum(case when trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) = '13610202010232' then monto else 0 end) capital_no_exigible_abono,
				   sum(case when trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) = '13110202020032' then monto else 0 end) interes_vigente_cargo,
				   sum(case when trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) = '13110202020032' then monto else 0 end) interes_vigente_abono,
				   sum(case when trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) = '14020305110232' then monto else 0 end) interes_IVA_cargo,
				   sum(case when trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) = '14020305110232' then monto else 0 end) interes_IVA_abono,
				   sum(case when trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) = '77106102020132' then monto else 0 end) interes_ORDEN_cargo,
				   sum(case when trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) = '77106102020132' then monto else 0 end) interes_ORDEN_abono,
				   sum(case when trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) = '78376102020132' then monto else 0 end) IVA_ORDEN_cargo,
				   sum(case when trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) = '78376102020132' then monto else 0 end) IVA_ORDEN_abono
			from bdicred:sd_movhiscrd a
			left outer join bdicred:sd_transfun b on (a.empresa = b.empresa and a.codigo_fun = b.codigo_fun and a.codigo_ref = b.codigo_ref)
			left outer join bdinteg:si_transacc c on (b.transacc = c.numero)
			left outer join bdinteg:si_prodtran d on (b.transacc = d.transaccion and d.producto = num_producto)
			where a.empresa = '001'
			  and fecha_mov = cFecha --mdy('11','26','2014')
			  and reversado = 'N'
			  and se_contabiliza = 'S'
			  and num_producto='6300'
			group by 1 into temp his_cuenta with no log;
			
			create unique index his_cuenta_inx on his_cuenta(num_credito);
			update statistics high for table his_cuenta;
			
			select sum(case when v_iDia=1 then d.capvig1
								when v_iDia=2 then d.capvig2
								when v_iDia=3 then d.capvig3
								when v_iDia=4 then d.capvig4
								when v_iDia=5 then d.capvig5
								when v_iDia=6 then d.capvig6
								when v_iDia=7 then d.capvig7
								when v_iDia=8 then d.capvig8
								when v_iDia=9 then d.capvig9
								when v_iDia=10 then d.capvig10
								when v_iDia=11 then d.capvig11
								when v_iDia=12 then d.capvig12
								when v_iDia=13 then d.capvig13
								when v_iDia=14 then d.capvig14
								when v_iDia=15 then d.capvig15
								when v_iDia=16 then d.capvig16
								when v_iDia=17 then d.capvig17
								when v_iDia=18 then d.capvig18
								when v_iDia=19 then d.capvig19
								when v_iDia=20 then d.capvig20
								when v_iDia=21 then d.capvig21
								when v_iDia=22 then d.capvig22
								when v_iDia=23 then d.capvig23
								when v_iDia=24 then d.capvig24
								when v_iDia=25 then d.capvig25
								when v_iDia=26 then d.capvig26
								when v_iDia=27 then d.capvig27
								when v_iDia=28 then d.capvig28
								when v_iDia=29 then d.capvig29
								when v_iDia=30 then d.capvig30
								when v_iDia=31 then d.capvig31
								ELSE 0 END
							) as total_cap,
							sum(case when v_iDia=1 then d.captrans1
									when v_iDia=2 then d.captrans2
									when v_iDia=3 then d.captrans3
									when v_iDia=4 then d.captrans4
									when v_iDia=5 then d.captrans5
									when v_iDia=6 then d.captrans6
									when v_iDia=7 then d.captrans7
									when v_iDia=8 then d.captrans8
									when v_iDia=9 then d.captrans9
									when v_iDia=10 then d.captrans10
									when v_iDia=11 then d.captrans11
									when v_iDia=12 then d.captrans12
									when v_iDia=13 then d.captrans13
									when v_iDia=14 then d.captrans14
									when v_iDia=15 then d.captrans15
									when v_iDia=16 then d.captrans16
									when v_iDia=17 then d.captrans17
									when v_iDia=18 then d.captrans18
									when v_iDia=19 then d.captrans19
									when v_iDia=20 then d.captrans20
									when v_iDia=21 then d.captrans21
									when v_iDia=22 then d.captrans22
									when v_iDia=23 then d.captrans23
									when v_iDia=24 then d.captrans24
									when v_iDia=25 then d.captrans25
									when v_iDia=26 then d.captrans26
									when v_iDia=27 then d.captrans27
									when v_iDia=28 then d.captrans28
									when v_iDia=29 then d.captrans29 
									when v_iDia=30 then d.captrans30
									when v_iDia=31 then d.captrans31
								ELSE 0 END
							) as Cap_trans,
							sum(case when v_iDia=1 then d.capvencnoexig1
									when v_iDia=2 then d.capvencnoexig2
									when v_iDia=3 then d.capvencnoexig3
									when v_iDia=4 then d.capvencnoexig4
									when v_iDia=5 then d.capvencnoexig5
									when v_iDia=6 then d.capvencnoexig6
									when v_iDia=7 then d.capvencnoexig7
									when v_iDia=8 then d.capvencnoexig8
									when v_iDia=9 then d.capvencnoexig9
									when v_iDia=10 then d.capvencnoexig10
									when v_iDia=11 then d.capvencnoexig11
									when v_iDia=12 then d.capvencnoexig12
									when v_iDia=13 then d.capvencnoexig13
									when v_iDia=14 then d.capvencnoexig14
									when v_iDia=15 then d.capvencnoexig15
									when v_iDia=16 then d.capvencnoexig16
									when v_iDia=17 then d.capvencnoexig17
									when v_iDia=18 then d.capvencnoexig18
									when v_iDia=19 then d.capvencnoexig19
									when v_iDia=20 then d.capvencnoexig20
									when v_iDia=21 then d.capvencnoexig21
									when v_iDia=22 then d.capvencnoexig22
									when v_iDia=23 then d.capvencnoexig23
									when v_iDia=24 then d.capvencnoexig24
									when v_iDia=25 then d.capvencnoexig25
									when v_iDia=26 then d.capvencnoexig26
									when v_iDia=27 then d.capvencnoexig27
									when v_iDia=28 then d.capvencnoexig28
									when v_iDia=29 then d.capvencnoexig29
									when v_iDia=30 then d.capvencnoexig30
									when v_iDia=31 then d.capvencnoexig31
								ELSE 0 END
							) as cap_venc_No_exig,
							sum(case when v_iDia=1 then d.capvenexig1
									when v_iDia=2 then d.capvenexig2
									when v_iDia=3 then d.capvenexig3
									when v_iDia=4 then d.capvenexig4
									when v_iDia=5 then d.capvenexig5
									when v_iDia=6 then d.capvenexig6
									when v_iDia=7 then d.capvenexig7
									when v_iDia=8 then d.capvenexig8
									when v_iDia=9 then d.capvenexig9
									when v_iDia=10 then d.capvenexig10
									when v_iDia=11 then d.capvenexig11
									when v_iDia=12 then d.capvenexig12
									when v_iDia=13 then d.capvenexig13
									when v_iDia=14 then d.capvenexig14
									when v_iDia=15 then d.capvenexig15
									when v_iDia=16 then d.capvenexig16
									when v_iDia=17 then d.capvenexig17
									when v_iDia=18 then d.capvenexig18
									when v_iDia=19 then d.capvenexig19
									when v_iDia=20 then d.capvenexig20
									when v_iDia=21 then d.capvenexig21
									when v_iDia=22 then d.capvenexig22
									when v_iDia=23 then d.capvenexig23
									when v_iDia=24 then d.capvenexig24
									when v_iDia=25 then d.capvenexig25
									when v_iDia=26 then d.capvenexig26
									when v_iDia=27 then d.capvenexig27
									when v_iDia=28 then d.capvenexig28
									when v_iDia=29 then d.capvenexig29
									when v_iDia=30 then d.capvenexig30
									when v_iDia=31 then d.capvenexig31
								ELSE 0 END
							) as cap_venc_exig,
							sum(case when v_iDia=1 then d.intvig1
									when v_iDia=2 then d.intvig2
									when v_iDia=3 then d.intvig3
									when v_iDia=4 then d.intvig4
									when v_iDia=5 then d.intvig5
									when v_iDia=6 then d.intvig6
									when v_iDia=7 then d.intvig7
									when v_iDia=8 then d.intvig8
									when v_iDia=9 then d.intvig9
									when v_iDia=10 then d.intvig10
									when v_iDia=11 then d.intvig11
									when v_iDia=12 then d.intvig12
									when v_iDia=13 then d.intvig13
									when v_iDia=14 then d.intvig14
									when v_iDia=15 then d.intvig15
									when v_iDia=16 then d.intvig16
									when v_iDia=17 then d.intvig17
									when v_iDia=18 then d.intvig18
									when v_iDia=19 then d.intvig19
									when v_iDia=20 then d.intvig20
									when v_iDia=21 then d.intvig21
									when v_iDia=22 then d.intvig22
									when v_iDia=23 then d.intvig23
									when v_iDia=24 then d.intvig24
									when v_iDia=25 then d.intvig25
									when v_iDia=26 then d.intvig26
									when v_iDia=27 then d.intvig27
									when v_iDia=28 then d.intvig28
									when v_iDia=29 then d.intvig29
									when v_iDia=30 then d.intvig30
									when v_iDia=31 then d.intvig31
								ELSE 0 END
							) as interes_vigente,
							sum(case when v_iDia=1 then d.int_venc_bal1
									when v_iDia=2 then d.int_venc_bal2
									when v_iDia=3 then d.int_venc_bal3
									when v_iDia=4 then d.int_venc_bal4
									when v_iDia=5 then d.int_venc_bal5
									when v_iDia=6 then d.int_venc_bal6
									when v_iDia=7 then d.int_venc_bal7
									when v_iDia=8 then d.int_venc_bal8
									when v_iDia=9 then d.int_venc_bal9
									when v_iDia=10 then d.int_venc_bal10
									when v_iDia=11 then d.int_venc_bal11
									when v_iDia=12 then d.int_venc_bal12
									when v_iDia=13 then d.int_venc_bal13
									when v_iDia=14 then d.int_venc_bal14
									when v_iDia=15 then d.int_venc_bal15
									when v_iDia=16 then d.int_venc_bal16
									when v_iDia=17 then d.int_venc_bal17
									when v_iDia=18 then d.int_venc_bal18
									when v_iDia=19 then d.int_venc_bal19
									when v_iDia=20 then d.int_venc_bal20
									when v_iDia=21 then d.int_venc_bal21
									when v_iDia=22 then d.int_venc_bal22
									when v_iDia=23 then d.int_venc_bal23
									when v_iDia=24 then d.int_venc_bal24
									when v_iDia=25 then d.int_venc_bal25
									when v_iDia=26 then d.int_venc_bal26
									when v_iDia=27 then d.int_venc_bal27
									when v_iDia=28 then d.int_venc_bal28
									when v_iDia=29 then d.int_venc_bal29
									when v_iDia=30 then d.int_venc_bal30
									when v_iDia=31 then d.int_venc_bal31
								ELSE 0 END
							) as interes_vencido,
							sum(case when v_iDia=1 then d.intvenc1 - d.int_venc_bal1
									when v_iDia=2 then d.intvenc2 - d.int_venc_bal2
									when v_iDia=3 then d.intvenc3 - d.int_venc_bal3
									when v_iDia=4 then d.intvenc4 - d.int_venc_bal4
									when v_iDia=5 then d.intvenc5 - d.int_venc_bal5
									when v_iDia=6 then d.intvenc6 - d.int_venc_bal6
									when v_iDia=7 then d.intvenc7 - d.int_venc_bal7
									when v_iDia=8 then d.intvenc8 - d.int_venc_bal8
									when v_iDia=9 then d.intvenc9 - d.int_venc_bal9
									when v_iDia=10 then d.intvenc10 - d.int_venc_bal10
									when v_iDia=11 then d.intvenc11 - d.int_venc_bal11
									when v_iDia=12 then d.intvenc12 - d.int_venc_bal12
									when v_iDia=13 then d.intvenc13 - d.int_venc_bal13
									when v_iDia=14 then d.intvenc14 - d.int_venc_bal14
									when v_iDia=15 then d.intvenc15 - d.int_venc_bal15
									when v_iDia=16 then d.intvenc16 - d.int_venc_bal16
									when v_iDia=17 then d.intvenc17 - d.int_venc_bal17
									when v_iDia=18 then d.intvenc18 - d.int_venc_bal18
									when v_iDia=19 then d.intvenc19 - d.int_venc_bal19
									when v_iDia=20 then d.intvenc20 - d.int_venc_bal20
									when v_iDia=21 then d.intvenc21 - d.int_venc_bal21
									when v_iDia=22 then d.intvenc22 - d.int_venc_bal22
									when v_iDia=23 then d.intvenc23 - d.int_venc_bal23
									when v_iDia=24 then d.intvenc24 - d.int_venc_bal24
									when v_iDia=25 then d.intvenc25 - d.int_venc_bal25
									when v_iDia=26 then d.intvenc26 - d.int_venc_bal26
									when v_iDia=27 then d.intvenc27 - d.int_venc_bal27
									when v_iDia=28 then d.intvenc28 - d.int_venc_bal28
									when v_iDia=29 then d.intvenc29 - d.int_venc_bal29
									when v_iDia=30 then d.intvenc30 - d.int_venc_bal30
									when v_iDia=31 then d.intvenc31 - d.int_venc_bal31
								ELSE 0 END
							) as interes_vencido_orden,
							sum(case when v_iDia=1 then b.ivaint_venc_bal1
									when v_iDia=2 then b.ivaint_venc_bal2 
									when v_iDia=3 then b.ivaint_venc_bal3 
									when v_iDia=4 then b.ivaint_venc_bal4 
									when v_iDia=5 then b.ivaint_venc_bal5 
									when v_iDia=6 then b.ivaint_venc_bal6 
									when v_iDia=7 then b.ivaint_venc_bal7 
									when v_iDia=8 then b.ivaint_venc_bal8 
									when v_iDia=9 then b.ivaint_venc_bal9 
									when v_iDia=10 then b.ivaint_venc_bal10 
									when v_iDia=11 then b.ivaint_venc_bal11 
									when v_iDia=12 then b.ivaint_venc_bal12 
									when v_iDia=13 then b.ivaint_venc_bal13 
									when v_iDia=14 then b.ivaint_venc_bal14 
									when v_iDia=15 then b.ivaint_venc_bal15 
									when v_iDia=16 then b.ivaint_venc_bal16 
									when v_iDia=17 then b.ivaint_venc_bal17 
									when v_iDia=18 then b.ivaint_venc_bal18 
									when v_iDia=19 then b.ivaint_venc_bal19 
									when v_iDia=20 then b.ivaint_venc_bal20 
									when v_iDia=21 then b.ivaint_venc_bal21 
									when v_iDia=22 then b.ivaint_venc_bal22 
									when v_iDia=23 then b.ivaint_venc_bal23 
									when v_iDia=24 then b.ivaint_venc_bal24 
									when v_iDia=25 then b.ivaint_venc_bal25 
									when v_iDia=26 then b.ivaint_venc_bal26 
									when v_iDia=27 then b.ivaint_venc_bal27 
									when v_iDia=28 then b.ivaint_venc_bal28
									when v_iDia=29 then b.ivaint_venc_bal29
									when v_iDia=30 then b.ivaint_venc_bal30
									when v_iDia=31 then b.ivaint_venc_bal31
								ELSE 0 END
							) as iva_interes,
							sum(case when v_iDia=1 then d.ivaintvenc1 - d.ivaint_venc_bal1
									when v_iDia=2 then d.ivaintvenc2 - d.ivaint_venc_bal2
									when v_iDia=3 then d.ivaintvenc3 - d.ivaint_venc_bal3
									when v_iDia=4 then d.ivaintvenc4 - d.ivaint_venc_bal4
									when v_iDia=5 then d.ivaintvenc5 - d.ivaint_venc_bal5
									when v_iDia=6 then d.ivaintvenc6 - d.ivaint_venc_bal6
									when v_iDia=7 then d.ivaintvenc7 - d.ivaint_venc_bal7
									when v_iDia=8 then d.ivaintvenc8 - d.ivaint_venc_bal8
									when v_iDia=9 then d.ivaintvenc9 - d.ivaint_venc_bal9
									when v_iDia=10 then d.ivaintvenc10 - d.ivaint_venc_bal10
									when v_iDia=11 then d.ivaintvenc11 - d.ivaint_venc_bal11
									when v_iDia=12 then d.ivaintvenc12 - d.ivaint_venc_bal12
									when v_iDia=13 then d.ivaintvenc13 - d.ivaint_venc_bal13
									when v_iDia=14 then d.ivaintvenc14 - d.ivaint_venc_bal14
									when v_iDia=15 then d.ivaintvenc15 - d.ivaint_venc_bal15
									when v_iDia=16 then d.ivaintvenc16 - d.ivaint_venc_bal16
									when v_iDia=17 then d.ivaintvenc17 - d.ivaint_venc_bal17
									when v_iDia=18 then d.ivaintvenc18 - d.ivaint_venc_bal18
									when v_iDia=19 then d.ivaintvenc19 - d.ivaint_venc_bal19
									when v_iDia=20 then d.ivaintvenc20 - d.ivaint_venc_bal20
									when v_iDia=21 then d.ivaintvenc21 - d.ivaint_venc_bal21
									when v_iDia=22 then d.ivaintvenc22 - d.ivaint_venc_bal22
									when v_iDia=23 then d.ivaintvenc23 - d.ivaint_venc_bal23
									when v_iDia=24 then d.ivaintvenc24 - d.ivaint_venc_bal24
									when v_iDia=25 then d.ivaintvenc25 - d.ivaint_venc_bal25
									when v_iDia=26 then d.ivaintvenc26 - d.ivaint_venc_bal26
									when v_iDia=27 then d.ivaintvenc27 - d.ivaint_venc_bal27
									when v_iDia=28 then d.ivaintvenc28 - d.ivaint_venc_bal28
									when v_iDia=29 then d.ivaintvenc29 - d.ivaint_venc_bal29
									when v_iDia=30 then d.ivaintvenc30 - d.ivaint_venc_bal30
									when v_iDia=31 then d.ivaintvenc31 - d.ivaint_venc_bal31
								ELSE 0 END
							) as interes_vencido_orden
		INTO vSdoCapVig, vSdoCapTrans, vSdoCapNoExig, vSdoCapExig, vSdoInteresVig, vSdoInteresVen, vSdoInteresVenDOr, vSdoIVAInteres, vSdoIVAInteresOr
				from bdicred:sd_maecredcrd a
					inner join bdicred:sd_sdodiariocrd d on (d.fecha=v_dFechaUno and  a.num_credito = d.num_credito)
					left outer join bdicred:sd_sdodiariocrd b on (b.fecha=v_dFechaUno and  a.num_credito = b.num_credito)
					left outer join his_cuenta c on (a.num_credito = c.num_credito)
				where a.empresa = '001'
					and a.status_cred not in ('CV')
					and a.num_producto='6300'
					and fecha_apertura<=cFecha; --mdy('11','17','2015');	
							
				
				
				
				--Calculamos los cargos y abonos de las cuentas para prestamos
		select NVL(Sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaCapVigPrest Then a.monto else 0 End),0) as CapVig,
			   NVL(Sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaCapVigPrest Then a.monto else 0 End),0) as CapVig_a,
			   NVL(Sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaCapTransPrest Then a.monto else 0 End),0) as CapTrans,
			   NVL(Sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaCapTransPrest Then a.monto else 0 End),0) as CapTrans_a,
			   NVL(Sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaCapNoExigPrest Then a.monto else 0 End),0) as CapNoExig,
			   NVL(Sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaCapNoExigPrest Then a.monto else 0 End),0) as CapNoExig_a,
			   NVL(Sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaCapExigPrest Then a.monto else 0 End),0) as CapExig,
			   NVL(Sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaCapExigPrest Then a.monto else 0 End),0) as CapExig_a,
			   NVL(Sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaInteresVigPrest Then a.monto else 0 End),0) as InteresVig,
			   NVL(Sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaInteresVigPrest Then a.monto else 0 End),0) as InteresVig_a,
			   NVL(Sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaInteresVenPrest Then a.monto else 0 End),0) as InteresVen,
			   NVL(Sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaInteresVenPrest Then a.monto else 0 End),0) as InteresVen_a,
			   NVL(Sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaInteresVenDOrPrest Then a.monto else 0 End),0) as InteresVenDOr,
			   NVL(Sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaInteresVenDOrPrest Then a.monto else 0 End),0) as InteresVenDOr_a,
			   NVL(Sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaIVAInteresPrest Then a.monto else 0 End),0) as IVAInteres,
			   NVL(Sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaIVAInteresPrest Then a.monto else 0 End),0) as IVAInteres_a,
			   NVL(Sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaIVAInteresOrPrest Then a.monto else 0 End),0) as IVAInteresOr,
			   NVL(Sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaIVAInteresOrPrest Then a.monto else 0 End),0) as IVAInteresOr_a
				into  vSdoCapVigPrest,vSdoCapVigPrest_a,vSdoCapTransPrest,vSdoCapTransPrest_a,vSdoCapNoExigPrest,vSdoCapNoExigPrest_a,vSdoCapExigPrest,vSdoCapExigPrest_a,vSdoInteresVigPrest,vSdoInteresVigPrest_a,vSdoInteresVenPrest,vSdoInteresVenPrest_a,vSdoInteresVenDOrPrest,vSdoInteresVenDOrPrest_a,vSdoIVAInteresPrest,vSdoIVAInteresPrest_a,vSdoIVAInteresOrPrest,vSdoIVAInteresOrPrest_a
						from sd_movhiscrd a
						join bdicred:sd_maecredcrd e on (e.empresa = '001' and a.num_credito = e.num_credito) 
						left outer join bdicred:sd_transfun b on (a.codigo_fun = b.codigo_fun and a.codigo_ref = b.codigo_ref)
						left outer join bdinteg:si_transacc c on (b.transacc = c.numero)
						left outer join bdinteg:si_prodtran d on (b.transacc = d.transaccion and a.num_producto=d.producto)
						where a.empresa = '001' and fecha_mov = cFecha and reversado = 'N' and a.num_producto = '6300';
						
						
						
			--Calculamos lo numero de movimientos para cargos y abonos
		select NVL(sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaCapVigPrest Then 1 else 0 End),0) as CapVig,
			   NVL(sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaCapVigPrest Then 1 else 0 End),0) as CapVig_a,
			   NVL(sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaCapTransPrest Then 1 else 0 End),0) as CapTrans,
			   NVL(sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaCapTransPrest Then 1 else 0 End),0) as CapTrans_a,
			   NVL(sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaCapNoExigPrest Then 1 else 0 End),0) as CapNoExig,
			   NVL(sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaCapNoExigPrest Then 1 else 0 End),0) as CapNoExig_a,
			   NVL(sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaCapExigPrest Then 1 else 0 End),0) as CapExig,
			   NVL(sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaCapExigPrest Then 1 else 0 End),0) as CapExig_a,
			   NVL(sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaInteresVigPrest Then 1 else 0 End),0) as InteresVig,
			   NVL(sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaInteresVigPrest Then 1 else 0 End),0) as InteresVig_a,
			   NVL(sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaInteresVenPrest Then 1 else 0 End),0) as InteresVen,
			   NVL(sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaInteresVenPrest Then 1 else 0 End),0) as InteresVen_a,
			   NVL(sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaInteresVenDOrPrest Then 1 else 0 End),0) as InteresVenDOr,
			   NVL(sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaInteresVenDOrPrest Then 1 else 0 End),0) as InteresVenDOr_a,
			   NVL(sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaIVAInteresPrest Then 1 else 0 End),0) as IVAInteres,
			   NVL(sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaIVAInteresPrest Then 1 else 0 End),0) as IVAInteres_a,
			   NVL(sum(Case When trim(d.c_ccmayor)||trim(d.c_ccsub)||trim(d.c_ccsubsub)||trim(d.c_ccsssub)||trim(d.c_ccssssub)||trim(d.c_sector)=vCtaIVAInteresOrPrest Then 1 else 0 End),0) as IVAInteresOr,
			   NVL(sum(Case When trim(d.a_ccmayor)||trim(d.a_ccsub)||trim(d.a_ccsubsub)||trim(d.a_ccsssub)||trim(d.a_ccssssub)||trim(d.a_sector)=vCtaIVAInteresOrPrest Then 1 else 0 End),0) as IVAInteresOr_a
				into  vSdoCapVigPrestCnt,vSdoCapVigPrest_aCnt,vSdoCapTransPrestCnt,vSdoCapTransPrest_aCnt,vSdoCapNoExigPrestCnt,vSdoCapNoExigPrest_aCnt,vSdoCapExigPrestCnt,vSdoCapExigPrest_aCnt,vSdoInteresVigPrestCnt,vSdoInteresVigPrest_aCnt,vSdoInteresVenPrestCnt,vSdoInteresVenPrest_aCnt,vSdoInteresVenDOrPrestCnt,vSdoInteresVenDOrPrest_aCnt,vSdoIVAInteresPrestCnt,vSdoIVAInteresPrest_aCnt,vSdoIVAInteresOrPrestCnt,vSdoIVAInteresOrPrest_aCnt
						from sd_movhiscrd a
						join bdicred:sd_maecredcrd e on (e.empresa = '001' and a.num_credito = e.num_credito) 
						left outer join bdicred:sd_transfun b on (a.codigo_fun = b.codigo_fun and a.codigo_ref = b.codigo_ref)
						left outer join bdinteg:si_transacc c on (b.transacc = c.numero)
						left outer join bdinteg:si_prodtran d on (b.transacc = d.transaccion and a.num_producto=d.producto)
						where a.empresa = '001' and fecha_mov = cFecha and reversado = 'N' and a.num_producto = '6300';
				
				
				--Calculamos CapVig
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaCapVigPrest) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaCapVigPrest;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)='PP' and trim(cc)=vCtaCapVigPrest;
				
				LET vMontoFinDiaAct= vSdoCapVig; --(vMontoFinDiaAnt + vSdoCapVigPrest) - vSdoCapVigPrest_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', 'PP', vCtaCapVigPrest, cFecha, vSdoCapVigPrest, vSdoCapVigPrest_a, vSdoCapVigPrestCnt, vSdoCapVigPrest_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;
				
				--Calculamos CapTrans
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaCapTransPrest) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaCapTransPrest;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)='PP' and trim(cc)=vCtaCapTransPrest;
				
				LET vMontoFinDiaAct= vSdoCapTrans; --(vMontoFinDiaAnt + vSdoCapTransPrest) - vSdoCapTransPrest_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', 'PP', vCtaCapTransPrest, cFecha, vSdoCapTransPrest, vSdoCapTransPrest_a, vSdoCapTransPrestCnt, vSdoCapTransPrest_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));
				
				LET vMontoFinDiaAnt = 0;
				
				--Calculamos CapNoExig
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaCapNoExigPrest) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaCapNoExigPrest;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)='PP' and trim(cc)=vCtaCapNoExigPrest;
				
				LET vMontoFinDiaAct= vSdoCapNoExig; --(vMontoFinDiaAnt + vSdoCapNoExigPrest) - vSdoCapNoExigPrest_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', 'PP', vCtaCapNoExigPrest, cFecha, vSdoCapNoExigPrest, vSdoCapNoExigPrest_a, vSdoCapNoExigPrestCnt, vSdoCapNoExigPrest_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));

				LET vMontoFinDiaAnt = 0;
				
								
				--Calculamos CapExig
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaCapExigPrest) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaCapExigPrest;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)='PP' and trim(cc)=vCtaCapExigPrest;
				
				LET vMontoFinDiaAct= vSdoCapExig; --(vMontoFinDiaAnt + vSdoCapExigPrest) - vSdoCapExigPrest_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', 'PP', vCtaCapExigPrest, cFecha, vSdoCapExigPrest, vSdoCapExigPrest_a, vSdoCapExigPrestCnt, vSdoCapExigPrest_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));

				LET vMontoFinDiaAnt = 0;
				
				--Calculamos InteresVig
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaInteresVigPrest) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaInteresVigPrest;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)='PP' and trim(cc)=vCtaInteresVigPrest;
				
				LET vMontoFinDiaAct= vSdoInteresVig; --(vMontoFinDiaAnt + vSdoInteresVigPrest) - vSdoInteresVigPrest_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', 'PP', vCtaInteresVigPrest, cFecha, vSdoInteresVigPrest, vSdoInteresVigPrest_a, vSdoInteresVigPrestCnt, vSdoInteresVigPrest_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));

				LET vMontoFinDiaAnt = 0;
				
				--Calculamos InteresVen
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaInteresVenPrest) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaInteresVenPrest;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)='PP' and trim(cc)=vCtaInteresVenPrest;
				
				LET vMontoFinDiaAct= vSdoInteresVen; --(vMontoFinDiaAnt + vSdoInteresVenPrest) - vSdoInteresVenPrest_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', 'PP', vCtaInteresVenPrest, cFecha, vSdoInteresVenPrest, vSdoInteresVenPrest_a, vSdoInteresVenPrestCnt, vSdoInteresVenPrest_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));

				LET vMontoFinDiaAnt = 0;
				
				--Calculamos InteresVenDOr
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaInteresVenDOrPrest) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaInteresVenDOrPrest;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)='PP' and trim(cc)=vCtaInteresVenDOrPrest;
				
				LET vMontoFinDiaAct= vSdoInteresVenDOr; --(vMontoFinDiaAnt + vSdoInteresVenDOrPrest) - vSdoInteresVenDOrPrest_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', 'PP', vCtaInteresVenDOrPrest, cFecha, vSdoInteresVenDOrPrest, vSdoInteresVenDOrPrest_a, vSdoInteresVenDOrPrestCnt, vSdoInteresVenDOrPrest_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));

				LET vMontoFinDiaAnt = 0;
				
				--Calculamos IVAIntere
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaIVAInteresPrest) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaIVAInteresPrest;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)='PP' and trim(cc)=vCtaIVAInteresPrest;
				
				LET vMontoFinDiaAct=vSdoIVAInteres; --(vMontoFinDiaAnt + vSdoIVAInteresPrest) - vSdoIVAInteresPrest_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', 'PP', vCtaIVAInteresPrest, cFecha, vSdoIVAInteresPrest, vSdoIVAInteresPrest_a, vSdoIVAInteresPrestCnt, vSdoIVAInteresPrest_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));

				LET vMontoFinDiaAnt = 0;
				
				--Calculamos IVAIntere
				if exists(select * from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaIVAInteresOrPrest) then
					delete from sd_histsdodias where mes_dia=cFecha and trim(producto)='PP' and trim(cc)=vCtaIVAInteresOrPrest;
				End if;
				
				select NVL(saldo_fin_de_dia,0)
				into vMontoFinDiaAnt
				from sd_histsdodias where mes_dia=(cFecha -1) and trim(producto)='PP' and trim(cc)=vCtaIVAInteresOrPrest;
				
				LET vMontoFinDiaAct= vSdoIVAInteresOr; --(vMontoFinDiaAnt + vSdoIVAInteresOrPrest) - vSdoIVAInteresOrPrest_a;
				
				INSERT INTO informix.sd_histsdodias(empresa, producto, cc, mes_dia, cargos_dia, abonos_dia, nro_cargos_dia, nro_abonos_dia, saldo_inicio_dia, saldo_fin_de_dia)
				VALUES('001', 'PP', vCtaIVAInteresOrPrest, cFecha, vSdoIVAInteresOrPrest, vSdoIVAInteresOrPrest_a, vSdoIVAInteresOrPrestCnt, vSdoIVAInteresOrPrest_aCnt, NVL(vMontoFinDiaAnt,0), NVL(vMontoFinDiaAct,0));

				LET vMontoFinDiaAnt = 0;		

				drop table his_cuenta;
							
	--		LET cFecha= cFecha + 1;
			
				LET cCodRet = '00000';			
				RETURN cCodRet;		
				
	END;
	
END PROCEDURE;