CREATE PROCEDURE "informix".sp_modificacion_vigencia_pl(eNumCte CHAR(40),
															ePuntos DECIMAL(18,2)) 
	RETURNING	 CHAR(5); --Codigo Retorno
	
DEFINE cCodret				    CHAR(5);
DEFINE iSqlerr				    INTEGER;

DEFINE vNumCte				    CHAR(40);
DEFINE cNumCte				    CHAR(40);
DEFINE vPuntos				    DECIMAL(18,2);
DEFINE vSaldo 					DECIMAL(18,2);
DEFINE vSaldoValida				DECIMAL(18,2);
DEFINE vSaldo2 					DECIMAL(18,2);
DEFINE vFolio					CHAR(40);
DEFINE vFechaVigencia			DATE;
DEFINE vOrigen					CHAR(40);
DEFINE vTipo				    CHAR(40);
DEFINE vSumaPuntos				DECIMAL(18,2);
DEFINE vReferencia23			CHAR(40);
DEFINE vAbonoRecuperado			DECIMAL(18,2);

--INICIALIZANDO VARIABLES -------------
---------------------------------------
LET iSqlerr    			= 0;
LET cCodret    			= "00000";
LET vFolio				= "";
LET vFechaVigencia		= "";
LET vOrigen				= "";
LET vTipo 				= "";
LET vNumCte				= eNumCte;
LET vPuntos				= ePuntos;
LET vSumaPuntos			= "";
LET vSaldo				= "";
LET vSaldoValida		= "";
LET vSaldo2				= "";
LET vReferencia23		= "";
LET vAbonoRecuperado	= "";
LET cNumCte				= "";
---------------------------------------
BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/Fausto/Sps/sp_modificacion_vigencia_pl.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
---------------------------------------
SELECT first 1 numcte
		INTO cNumCte
		FROM bdicred: "informix".sd_vigencia_monedero_plan_lealtad
		WHERE numcte = vNumCte 
		and estatus = "f";
	
IF cNumCte is not null THEN
	WHILE (vPuntos > 0)
		FOREACH
				
				
			SELECT first 1 monto_abono,monto_abono, folio, fecha_insert, origen, referencia23, monto_abono_recuperado
			INTO vSaldo,vSaldoValida, vFolio, vFechaVigencia, vOrigen, vReferencia23, vAbonoRecuperado
			FROM bdicred: "informix".sd_vigencia_monedero_plan_lealtad
			WHERE numcte = vNumCte 
			and estatus = "f"
			ORDER BY 
			CASE 
		        WHEN origen = "Reworth" THEN 0
		        WHEN origen = "Plan_Lealtad" THEN 1
    		END,
			fecha_insert ASC 
			

			SELECT sum(monto_abono)
			INTO vSumaPuntos
			FROM bdicred: "informix".sd_vigencia_monedero_plan_lealtad
			WHERE numcte = vNumCte 
			and estatus = "f"
			group by numcte;
			
			IF vSumaPuntos IS NULL then
				CONTINUE FOREACH;
			END IF;
			
			IF vSumaPuntos < vPuntos THEN
				LET vPuntos = 0;
				CONTINUE FOREACH;
			END IF; 	
		
			let vSaldo2 = vSaldo - vAbonoRecuperado;
					
			IF vPuntos >= vSaldo2 THEN
		
				LET vAbonoRecuperado = vAbonoRecuperado + vPuntos;
			
				UPDATE sd_vigencia_monedero_plan_lealtad SET estatus = "t", tipo = "gastado", monto_abono_recuperado = vSaldo --vAbonoRecuperado
				WHERE numcte = vNumCte
				and referencia23 = vReferencia23
				and folio = vFolio
				and origen = vOrigen
				and monto_abono = vSaldoValida;
			
				LET vPuntos = vPuntos - vSaldo2;
			else
				LET vAbonoRecuperado = vAbonoRecuperado + vPuntos;

				UPDATE sd_vigencia_monedero_plan_lealtad SET monto_abono_recuperado = vAbonoRecuperado
				WHERE numcte = vNumCte
				and referencia23 = vReferencia23
				and folio = vFolio
				and origen = vOrigen
				and monto_abono = vSaldoValida;
				
				LET vPuntos = 0;
				
			END IF; 
		
		if vAbonoRecuperado = vSaldo then 
			UPDATE sd_vigencia_monedero_plan_lealtad SET estatus = "t", tipo = "gastado", monto_abono_recuperado = vSaldo--vAbonoRecuperado
				WHERE numcte = vNumCte
				and referencia23 = vReferencia23
				and folio = vFolio
				and origen = vOrigen
				and monto_abono = vSaldoValida;
		end if;
	
		END FOREACH;
	
	END WHILE;
ELSE
	LET cCodret = '00000';
END IF;
---------------------------------------
	RETURN cCodret;
END;
--------------------------------------
END procedure;