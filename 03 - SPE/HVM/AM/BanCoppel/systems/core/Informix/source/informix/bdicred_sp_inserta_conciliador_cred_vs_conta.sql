CREATE PROCEDURE "informix".sp_inserta_conciliador_cred_vs_conta(cFecha date, cCC char(14),vSdoConta Money(18,2),vsdoCargosConta Money(18,2), vsdoAbonosConta Money(18,2), vSdoFinDia Money(18,2), vsdoAbonos Money(18,2), vsdoCargos Money(18,2), vDescripcion char(50), cTipoProd integer)

--------------------------------------------------------------------
--DOCUMENTACIÓN
--inserta en la tabla sd_conciliacredito, los cargos, abonos, saldo inicio y saldo final
--Realizó: Richar 
--Fecha: 07/07/2015
--------------------------------------------------------------------													
--cTipoConcil = tipo de conciliacion 1=Saldos 2 = movimientos
--cTipoProd = 1 TDC, 2 credinomina, 3 prestamos personal y 4 Reestructura
							
    --DATOS A REGRESAR---	
	RETURNING CHAR(5) as codret;    

	DEFINE cCodRet 		CHAR(5);			
	DEFINE vDiferencia	MONEY(18,2);
	DEFINE vDiferenciaAbono	MONEY(18,2);
	DEFINE vDiferenciaCargo	MONEY(18,2);	
	DEFINE vProducto	CHAR(30);
	
	
	
			--SET DEBUG FILE TO "sp_inserta_conciliador_cred_vs_conta.out";
			--TRACE ON;
			  
	set isolation to dirty read;	

	-- INICIO DEL PROCEDIMIENTO	 
	BEGIN
	
	LET cCodRet = '00001';
	LET vDiferencia = 0;
	LET vDiferenciaAbono = 0;
	LET vDiferenciaCargo = 0;

					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;					  
				  
		if cTipoProd=1 then
			LET vProducto = 'Tarjeta de credito';
		elif cTipoProd=2 then
			LET vProducto = 'Credinomina';
		elif cTipoProd=3 then 
			LET vProducto = 'Prestamo Personal';
		elif cTipoProd=4 then 
			LET vProducto = 'Reestructura';
			
		End if;
		
					delete from bdicred:sd_conciliacredito where nivelcontable=cCC;
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
					  values(trim(vProducto),vDescripcion,cCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
					  
				if cTipoProd=3 and cCC ='77106102020132' then --and (cCC ='13110202020032' or cCC ='77106102020132')
					
					select NVL(sdoperativo-sdocontable,0)
					into vDiferencia
					from sd_conciliacredito
					where nivelcontable='13110202020032';
					
					--Restamos 
					update sd_conciliacredito set sdoperativo= (sdoperativo - vDiferencia) where nivelcontable='13110202020032';
					update sd_conciliacredito set sdoperativo= (sdoperativo + vDiferencia) where nivelcontable='77106102020132';
					
					--sacamos diferencias
					update sd_conciliacredito set sdodif=(sdoperativo-sdocontable) where nivelcontable='13110202020032';
					update sd_conciliacredito set sdodif=(sdoperativo-sdocontable) where nivelcontable='77106102020132';			
				End if;
	END;
		
	END PROCEDURE;