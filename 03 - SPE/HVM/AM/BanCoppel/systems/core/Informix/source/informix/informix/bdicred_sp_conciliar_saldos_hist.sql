CREATE PROCEDURE "informix".sp_conciliar_saldos_hist(cEmpresa CHAR(3),cFecha date, cTipoProd integer)
												
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Regresa la conciliacion de los saldos y movimientos de credito vs la balanza contable
--Realizó: Richar 
--Fecha: 06/01/2015
--------------------------------------------------------------------													
--cTipoConcil = tipo de conciliacion 1=Saldos 2 = movimientos
--cTipoProd = 1 TDC, 2 credinomina, 3 prestamos personal y 4 Reestructura
							
    --DATOS A REGRESAR---	
	RETURNING CHAR(5) as codret,char(60) as s_descripcion,char(60) as s_cc,Money(18,2) as s_cargos_dia,Money(18,2) as s_abonos_dia, Money(18,2) as s_saldo_inicio_dia, Money(18,2) as s_saldo_fin_de_dia;	--codret
              
						  
	--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    ---------------------------	
			
	--	Variables para las cuentas ***********
	DEFINE vCtaCapVig 		Char(14);
	DEFINE vCtaCapTrans 	Char(14);
	DEFINE vCtaCapVenNoNeg 	Char(14);
	DEFINE vCtaCapVenExig	Char(14);
	DEFINE vCtaSdoFavor		Char(14);
	DEFINE vCtaIntVig		Char(14);
	DEFINE vCtaIntVenXTrans	Char(14);
	DEFINE vCtaInteresVen	Char(14);
	DEFINE vCtaIVAIntVig	Char(14);
	DEFINE vCtaIVAInteres	Char(14);
	DEFINE vCtaInteresVenOrd Char(14);
	DEFINE vCtaIVAInteresOrd Char(14);
	
	--  ***********
	DEFINE vDescripcion		Char(50);
	DEFINE vCC			  	Char(50);
	DEFINE vsdoCargos		Money(18,2);
	DEFINE vsdoAbonos		Money(18,2);
	DEFINE vSdoInicioDia	Money(18,2);
	DEFINE vSdoFinDia		Money(18,2);	
	
	--Banderas
	DEFINE v_paso				varchar(50);
	
	--INICIALIZACION DE VARIABLES--
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	
	LET vsdoAbonos=0;
	LET vsdoCargos=0;	
	
	LET vDescripcion='';	
	
	--Definimos todas las cuentas contables de TDC
	
	LET vCtaCapVig = '13110101010032';
	LET vCtaCapTrans = '13110101030032';
	LET vCtaCapVenNoNeg = '13610101010232';
	LET vCtaCapVenExig = '13610101010132';
	LET vCtaSdoFavor = '24029014000032';
    LET vCtaIntVig = '13110101020032';
	LET vCtaIntVenXTrans = '13110101040032';
	LET vCtaInteresVen = '13610101020132';
	LET vCtaIVAIntVig ='14020305110132'; --Iva de Interes Vigente
	LET vCtaInteresVenOrd = '77106101010132';
	LET vCtaIVAInteresOrd = '78376101010132';
		
	LET v_paso ='';
		
	--SET DEBUG FILE TO "/home/sysifx/sp_conciliar_saldos_hist.out";
	--TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	 
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'Error al ejecutar el SP','',0,0,0,0;
		END EXCEPTION;
		
		--Borramos la tabla donde se va guardando la informacion para el reporte
		delete from sd_conciliacredito;
		
				--Valida parámetros de entrada
		IF (cTipoProd=1) THEN		--Tarjeta de credito		
		
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='TDC' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaSdoFavor,vCtaIntVig,vCtaIntVenXTrans,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
					
					LET cCodRet = '00000';
			
					RETURN cCodRet,vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia WITH RESUME;
				End FOREACH;
				
		ElIF (cTipoProd=2) THEN		--Credinomina
		
				LET vCtaCapVig = '13110203010032';
				LET vCtaCapTrans = '13110203030032';
				LET vCtaCapVenNoNeg = '13610203010232';
				LET vCtaCapVenExig = '13610203010132';
				LET vCtaIntVig = '13110203020032';
				LET vCtaInteresVen = '13610203020132';
				LET vCtaInteresVenOrd = '77106102030132';	
				LET vCtaIVAIntVig ='14020305110332'; --Iva de Interes	
				LET vCtaIVAInteresOrd = '78376102030132';									
		
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='CDN' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaIntVig,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
								
					LET cCodRet = '00000';
				
					RETURN cCodRet,vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia WITH RESUME;
				
				End FOREACH;
				
		ElIF (cTipoProd=3) THEN		--Prestamo personal
		
				LET vCtaCapVig = '13110202010032';
				LET vCtaCapTrans = '13110202030032';
				LET vCtaCapVenNoNeg = '13610202010232';
				LET vCtaCapVenExig = '13610202010132';
				LET vCtaIntVig = '13110202020032';
				LET vCtaInteresVen = '13610202020132';
				LET vCtaInteresVenOrd = '77106102020132';	
				LET vCtaIVAIntVig ='14020305110232'; --Iva de Interes	
				LET vCtaIVAInteresOrd = '78376102020132';
											
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='PP' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaIntVig,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar				
				
					LET cCodRet = '00000';				
					RETURN cCodRet,vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia WITH RESUME;
				
				End FOREACH;
				
		ElIF (cTipoProd=4) THEN		--Restrucutra
		
				LET vCtaCapVig = '13110102010032';				
				LET vCtaCapVenExig = '13610102010132';
				LET vCtaCapVenNoNeg = '13610102010232';				
				LET vCtaCapTrans = '13110102030032';				
				LET vCtaIntVig = '13110102020032';				
				LET vCtaInteresVen = '13610102020032';				
				LET vCtaInteresVenOrd = '77106101020132';				
				LET vCtaIVAIntVig ='14020305110432'; --Iva de Interes					
				LET vCtaIVAInteresOrd = '78376101020132';
											
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='RTC' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaIntVig,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar								
					
					LET cCodRet = '00000';				
					RETURN cCodRet,vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia WITH RESUME;
				
				End FOREACH;				
		ELSE
		
			--Parámetro de entrada vacío
			LET cCodRet = '00001';			
			RETURN cCodRet,'Parámetro de entrada vacío','',0,0,0,0 WITH RESUME;
				
		End if
	END;
	
END PROCEDURE;