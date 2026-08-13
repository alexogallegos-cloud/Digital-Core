CREATE PROCEDURE "informix".sp_registro_ope_favoritas_bex(
	pnumCte CHAR(20), 
	pctaDestino CHAR(20), 
	pidOperacion CHAR(50),
	pbanco CHAR(8), 
	pbenefi CHAR(50),  
	pconcepto CHAR (40), 
	preferencia CHAR (50), 
	pestatus CHAR(1), 
	pimporte MONEY(16,2), 
	poperaciones_max INTEGER)
	
	
    RETURNING CHAR(5),  CHAR(2);

    DEFINE sql_err 		INTEGER ;
    DEFINE cCod_ret 	CHAR(5);
	DEFINE vEstatus 	VARCHAR(9);
	DEFINE vOpeCount	INTEGER;
	DEFINE vTotal		CHAR(2);
	
	LET cCod_ret  		= '00000';
	LET vOpeCount 		= 0; 
	LET vEstatus 		= ''; 
	LET vTotal 			= '0';
	
	
BEGIN 

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			let cCod_ret = sql_err;
			RETURN cCod_ret, vTotal;
		END IF;
	END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	LET pnumCte =  NVL(pnumCte,'');
	LET pctaDestino = NVL(pctaDestino,'');
	LET pidOperacion = NVL(pidOperacion,'');
	LET pbenefi = NVL(pbenefi,'');
	LET pconcepto = NVL(pconcepto,'');
	LET preferencia = NVL(preferencia,'');
	LET pestatus = NVL(pestatus,''); 
	LET pimporte = NVL(pimporte,''); 
	
	
	IF pnumCte <> '' AND pctaDestino <> '' AND pidOperacion <> '' AND pestatus <> '' THEN 
		
			
		
		--Verifica si el usuario cuenta con el maximo de operaciones fav. registradas.
		SELECT count(num_cte)
		INTO vOpeCount
		FROM bdiprog:"informix".pp_registro_favoritos_bex
		WHERE num_cte = pnumCte
		AND estatus = '1';
		
		IF pestatus <> 1 AND pestatus <> 2 THEN 
			LET cCod_Ret = '00004'; -- parametros invalido
			RETURN cCod_ret, vTotal;
		END IF;
		
		
		--Verifica si existe operaciÃ³n favorita
		SELECT estatus
		INTO vEstatus
		FROM bdiprog:"informix".pp_registro_favoritos_bex
		WHERE num_cte = pnumCte 
		AND cta_destino = pctaDestino
		AND banco=pbanco;
			
		LET vEstatus = nvl(vEstatus,'');
		
		IF vOpeCount >= poperaciones_max AND  vEstatus = '' THEN
		
			LET cCod_Ret = '00003'; 
		
		ELSE
				IF vEstatus = '' THEN 
					
						INSERT INTO bdiprog:"informix".pp_registro_favoritos_bex(num_cte, cta_destino, id_operacion, fecha_alta, fecha_cancelado, banco, beneficiario, concepto, referencia, importe, estatus) 
						VALUES (pnumCte,pctaDestino,pIdOperacion,CURRENT,'',pbanco,pBenefi,pconcepto,preferencia,pimporte,pestatus);
					
					LET vTotal = vOpeCount + 1;
				ELSE 
						IF vEstatus = '2' AND pestatus <> '2' THEN
							
							UPDATE bdiprog:"informix".pp_registro_favoritos_bex
							SET fecha_alta = CURRENT , beneficiario = pBenefi, concepto = pconcepto, referencia = preferencia, importe = pimporte, estatus = pestatus
							WHERE num_cte = pnumCte 
							AND cta_destino = pctaDestino
							AND banco=pbanco;
							
							LET vTotal = vOpeCount + 1; 
							
						ELSE IF vEstatus <> '2' AND pestatus = '2' THEN
								UPDATE bdiprog:"informix".pp_registro_favoritos_bex
								SET fecha_cancelado = CURRENT , estatus = pestatus
								WHERE num_cte = pnumCte 
								AND cta_destino = pctaDestino
								AND id_operacion= pidOperacion
								AND banco=pbanco;
						
								LET vTotal = vOpeCount - 1; 
								
							ELSE
								IF pestatus = '1' THEN 
									UPDATE bdiprog:"informix".pp_registro_favoritos_bex
									SET fecha_alta = CURRENT , beneficiario = pBenefi, concepto = pconcepto, referencia = preferencia, importe = pimporte
									WHERE num_cte = pnumCte 
									AND cta_destino = pctaDestino
									AND estatus = '1'
									AND id_operacion= pidOperacion
									AND banco=pbanco;
								END IF;
								LET vTotal = vOpeCount; 		
							END IF;
						END IF;
						
				END IF;	

		END IF;
		
	ELSE
		LET cCod_Ret = '00002'; -- Faltan parametros
	END IF;
	
	
	RETURN cCod_ret, vTotal;
END
END PROCEDURE;