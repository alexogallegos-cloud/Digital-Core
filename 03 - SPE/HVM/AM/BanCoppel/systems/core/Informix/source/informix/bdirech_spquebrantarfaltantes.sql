Create procedure "informix".spquebrantarfaltantes()

RETURNING char(5) AS CodigoRetorno, MONEY(10,0) AS Saldoquebrantado


DEFINE iSqlErr          INTEGER;

DEFINE v_numempleado 	CHAR(8);
DEFINE v_sCodRet     	CHAR(5);
DEFINE v_sSaldoActual 	MONEY(10,0);
DEFINE v_sSaldoInicial	MONEY(10,0);
DEFINE v_iIdafaltante	SMALLINT;
DEFINE v_sAuxiliar		CHAR(12);
DEFINE v_sSucursal		CHAR(4);
DEFINE v_mMontoMov		MONEY(10,0);
DEFINE v_iTotalMov		INTEGER;
DEFINE v_iMaxMov		SMALLINT;
DEFINE v_sReferencia	CHAR(26);
DEFINE v_sFolioSuc		CHAR(16);
DEFINE v_mMontoTot		MONEY(10,0);

   SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,0;
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet='00001';
		
		LET v_mMontoTot=0;
		
		
		FOREACH		
		select recc.numempleado,recc.idfaltante, recc.saldoactual, recc.saldoinicial, recc.auxiliar, recc.numsucursal ,recc.referencia
		into v_numempleado,v_iIdafaltante,v_sSaldoActual,v_sSaldoInicial,v_sAuxiliar,v_sSucursal, v_sReferencia
		from rec_confaltante recc
		inner join rec_movquebrantos recm on 
		recc.numempleado = recm.numempleado and recc.idfaltante=recm.idfaltante
		where recm.transaccion='0053' and recc.saldoactual>0
		
			--Obtenemos el monto total de movimientos, si es que hizo antes de quebrantar
			select NVL(sum(montomovimiento),0)
		
		into v_mMontoMov
			from rec_movfaltante			
			where numempleado = v_numempleado and idfaltante=v_iIdafaltante
			and transaccion in ('0051','0052','0055','0056');
			
			--Total de movimientos
			select NVL(count(montomovimiento),0)
			into v_iTotalMov
			from rec_movfaltante
			where numempleado = v_numempleado and idfaltante=v_iIdafaltante
			and transaccion in ('0051','0052','0055','0056');		
						
			
			--Actualizamos el movimiento del quebranto, los datos que faltaron
			update rec_movquebrantos set numsucursal=v_sSucursal,saldoinicial=v_sSaldoInicial,saldoactual=v_sSaldoActual,auxiliar=v_sAuxiliar, montotalbonos= v_mMontoMov, numabonos=v_iTotalMov
			where numempleado=v_numempleado and idfaltante=v_iIdafaltante;	
			
			--Obtenemos el ultimo movimiento realizado
			Select NVL(max(idmovimiento),0)
			Into v_iMaxMov
			from rec_movfaltante
			where numempleado = v_numempleado and idfaltante=v_iIdafaltante;
			
			--Obtenemos el folio de la sucursal
			Select first 1 NVL(foliosuc,v_sSucursal)
			into v_sFolioSuc
			from rec_movfaltante
			where numempleado = v_numempleado and idfaltante=v_iIdafaltante;
			
			LET v_iMaxMov = v_iMaxMov + 1;
			
			INSERT INTO informix.rec_movfaltante(numempleado, numsucursal, idfaltante, transaccion, idmovimiento, tipomovimiento, auxiliar, idrecupera, montomovimiento, fecharegistro, contable, usuarioautoriza, referencia, foliosuc, sucursalpago, secuencia)
			VALUES(v_numempleado, v_sSucursal, v_iIdafaltante, '0053', v_iMaxMov, 'A', v_sAuxiliar, 1, v_sSaldoActual, today, '1', 'informix', v_sReferencia, v_sFolioSuc, v_sSucursal, 0);
			
			update "informix".rec_confaltante set idestatus=4,saldoactual=0
			 where   numempleado = v_numempleado and idfaltante=v_iIdafaltante;			
			
			LET v_mMontoTot = v_mMontoTot + v_sSaldoActual;	
			
		END FOREACH;
		
		LET v_sCodRet='00000';
		
		RETURN v_sCodRet, v_mMontoTot WITH RESUME;		
		
END;
END PROCEDURE

;