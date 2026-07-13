CREATE PROCEDURE "informix".sp_obtenerproducto_masivo(pMovAhorro CHAR(4),
													pMovCredito CHAR(4),
													pEdoCtaAho CHAR(4),
													pEdoCtaCre CHAR(4),
													pTransCtasPro CHAR(4),
													pTDCPropia CHAR(4),
													pCtasTerceros CHAR(4),
													pPagoOtroBanco CHAR(4),
													pPagoTelmex CHAR(4),
													pPagoServSky CHAR(4),
													pCheques CHAR(4),
													pTransSpei CHAR(4)
													)
RETURNING CHAR(5),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50);


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creador: Francisco Rodríguez
-- Objetivo: Se obtienen todos los productos que se necesitan para la  funcionalidad de la BPI
-- Solicitó: Mauricio León
-- Fecha: 16/02/2011
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creador: Francisco Rodríguez
-- Objetivo: Se modificó para traerse los productos de transferencias SPEI
-- Solicitó: Mauricio León
-- Fecha: 11/03/2011
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--DECLARACION DE VARIABLES
	DEFINE vCod_Ret CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vIdOpe CHAR(4);
	DEFINE vProducto CHAR(4);
	DEFINE vMovAhorro VARCHAR(50);
	DEFINE vMovCredito VARCHAR(50);
	DEFINE vEdoCtaAhorro VARCHAR(50);
	DEFINE vEdoCtaCredito VARCHAR(50);
	DEFINE vTransCtasPropias VARCHAR(50);
	DEFINE vTDCPropia VARCHAR(50);
	DEFINE vCtasTerceros VARCHAR(50);
	DEFINE vPagoTelmex VARCHAR(50);
	DEFINE vCheques VARCHAR(50);
	DEFINE vPagoOtroBanco VARCHAR(50);
	DEFINE vPagoServSKY VARCHAR(50);	
	DEFINE vTransSPEI VARCHAR(50);
		
	--INICIALIZAR VALORES A VARIABLES;
	LET vCod_Ret='00000';
	LET vIdOpe = '';
	LET vProducto = '';
	
	LET vMovAhorro ='1004';
	LET vMovCredito ='1005';
	LET vEdoCtaAhorro ='1006';
	LET vEdoCtaCredito ='1007';
	LET vTransCtasPropias ='1008';
	LET vTDCPropia ='1011';
	LET vTransSPEI='1015';
	LET vCtasTerceros ='1016';
	LET vPagoOtroBanco ='1017';
	LET vPagoTelmex ='1020';
	LET vPagoServSKY ='1021';	
	LET vCheques ='1CHQ';

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,'','','','','','','','','','','','';
		  END IF ;
		END EXCEPTION ;
		
		FOREACH
			SELECT id_oper,producto
				INTO vIdOpe,vProducto
				FROM bdibpi:bpi_pprod
				WHERE id_oper IN(pMovAhorro,pMovCredito,pEdoCtaAho,pEdoCtaCre,pTransCtasPro,pTDCPropia,pCtasTerceros,pPagoOtroBanco,pPagoTelmex,pPagoServSky,pCheques,pTransSpei)
				ORDER BY id_oper
				
				IF(vIdOpe=pMovAhorro)     THEN	LET vMovAhorro=vMovAhorro||vProducto;	            END IF;
				IF(vIdOpe=pMovCredito)    THEN	LET vMovCredito=vMovCredito||vProducto;	            END IF;
				IF(vIdOpe=pEdoCtaAho)     THEN	LET vEdoCtaAhorro=vEdoCtaAhorro||vProducto;	        END IF;
				IF(vIdOpe=pEdoCtaCre)     THEN  LET vEdoCtaCredito=vEdoCtaCredito||vProducto;       END IF;
				IF(vIdOpe=pTransCtasPro)  THEN	LET vTransCtasPropias=vTransCtasPropias||vProducto;	END IF;
				IF(vIdOpe=pTDCPropia)     THEN	LET vTDCPropia=vTDCPropia||vProducto;	            END IF;
				IF(vIdOpe=pCtasTerceros)  THEN	LET vCtasTerceros=vCtasTerceros||vProducto;         END IF;
				IF(vIdOpe=pPagoOtroBanco) THEN	LET vPagoOtroBanco=vPagoOtroBanco||vProducto;	    END IF;
				IF(vIdOpe=pPagoTelmex)    THEN	LET vPagoTelmex=vPagoTelmex||vProducto;	            END IF;
				IF(vIdOpe=pPagoServSky)   THEN	LET vPagoServSKY=vPagoServSKY||vProducto;	        END IF;
				IF(vIdOpe=pCheques)       THEN	LET vCheques=vCheques||vProducto; 	                END IF;
				IF(vIdOpe=pTransSpei)	  THEN  LET vTransSPEI=vTransSPEI||vProducto;				END IF;
				/*CASE vIdOpe::INTEGER
					WHEN 1004 THEN LET vMovAhorro = vMovAhorro + vProducto;
					WHEN 1005 THEN LET vMovCredito = vMovCredito + vProducto;
					WHEN 1006 THEN LET vMovCredito = vEdoCtaAhorro + vProducto;
					WHEN 1007 THEN LET vMovCredito = vEdoCtaCredito + vProducto;
					WHEN 1008 THEN LET vTransCtasPropias = vTransCtasPropias + vProducto;
					WHEN 1011 THEN LET vTDCPropia = vTDCPropia + vProducto;
					WHEN 1016 THEN LET vCtasTerceros = vCtasTerceros + vProducto;
					WHEN 1017 THEN LET vPagoOtroBanco = vPagoOtroBanco + vProducto;
					WHEN 1020 THEN LET vPagoTelmex = vPagoTelmex + vProducto;
					WHEN 1021 THEN LET vPagoServSKY = vPagoServSKY + vProducto;
					--WHEN 1CHQ THEN LET vCheques = vCheques + vProducto;
					ELSE
					  RAISE EXCEPTION 100; --illegal value
				END CASE;*/
				
		END FOREACH;
		
		RETURN vCod_Ret,vMovAhorro,vMovCredito,vEdoCtaAhorro,vEdoCtaCredito,vTransCtasPropias,vTDCPropia,vCtasTerceros,vPagoOtroBanco,vPagoTelmex,vPagoServSKY,vCheques,vTransSPEI WITH RESUME;
		
		END;
END PROCEDURE;