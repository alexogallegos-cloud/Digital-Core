CREATE PROCEDURE "informix".sp_saldoactual_cajageneral(pEmpresa CHAR(3), pCajaGeneral  CHAR(4))
		RETURNING CHAR(5) AS codret,
			CHAR(18) AS deno_1000,
			CHAR(18) AS pdeno_500,
			CHAR(18) AS pdeno_200,
			CHAR(18) AS pdeno_100,
			CHAR(18) AS pdeno_50,
			CHAR(18) AS pdeno_20,
			CHAR(18) AS ptotal_billete, 
			CHAR(18) AS pdeno_mon_100,
			CHAR(18) AS pdeno_mon_50,
			CHAR(18) AS pdeno_mon_20,
			CHAR(18) AS pdeno_mon_10,
			CHAR(18) AS pdeno_mon_5,
			CHAR(18) AS pdeno_mon_2,
			CHAR(18) AS pdeno_mon_1,
			CHAR(18) AS pdeno_mon_0_50, 
			CHAR(18) AS pdeno_mon_0_20,
			CHAR(18) AS pdeno_mon_0_10,
			CHAR(18) AS pdeno_mon_0_05,
			CHAR(18) AS ptotal_morralla,
			CHAR(18) AS pmonto_total;

			DEFINE cCodRet CHAR(5);
			DEFINE iSqlErr INTEGER;
			DEFINE iNoRegistros INTEGER;
	
			DEFINE pdeno_1000   FLOAT(8);
			DEFINE pdeno_500	FLOAT(8);
			DEFINE pdeno_200	FLOAT(8);
			DEFINE pdeno_100	FLOAT(8);
			DEFINE pdeno_50		FLOAT(8);
			DEFINE pdeno_20		FLOAT(8);
			DEFINE ptotal_billete	DECIMAL(18,2); 
			DEFINE pdeno_mon_100	FLOAT(8);
			DEFINE pdeno_mon_50		FLOAT(8);
			DEFINE pdeno_mon_20		FLOAT(8);
			DEFINE pdeno_mon_10		FLOAT(8);
			DEFINE pdeno_mon_5		FLOAT(8);
			DEFINE pdeno_mon_2		FLOAT(8);
			DEFINE pdeno_mon_1		FLOAT(8);
			DEFINE pdeno_mon_0_50	FLOAT(8); 
			DEFINE pdeno_mon_0_20	FLOAT(8);
			DEFINE pdeno_mon_0_10	FLOAT(8);
			DEFINE pdeno_mon_0_05	FLOAT(8);
			DEFINE ptotal_morralla  DECIMAL(18,2);
			DEFINE pmonto_total     DECIMAL(18,2);
			
			DEFINE pdenominacion_1	 CHAR(18);
			DEFINE pdenominacion_2   CHAR(18);
			DEFINE pdenominacion_3   CHAR(18);
			DEFINE pdenominacion_4   CHAR(18);
			DEFINE pdenominacion_5   CHAR(18);
			DEFINE pdenominacion_6   CHAR(18);
			DEFINE pdenominacion_7   CHAR(18);
			DEFINE pdenominacion_8   CHAR(18);
			DEFINE pdenominacion_9   CHAR(18);
			DEFINE pdenominacion_10  CHAR(18);
			DEFINE pdenominacion_11  CHAR(18);
			DEFINE pdenominacion_12  CHAR(18);
			DEFINE pdenominacion_13  CHAR(18);
			DEFINE pdenominacion_14  CHAR(18);
			DEFINE pdenominacion_15  CHAR(18);
			DEFINE pdenominacion_16  CHAR(18);
			DEFINE pdenominacion_17  CHAR(18);
			
			DEFINE valida INTEGER;
			LET valida = 0;
			LET cCodRet = '00000';
			LET iSqlErr = 0;
			LET iNoRegistros = 0;
	
			LET pdeno_1000  	=0;
			LET pdeno_500		=0;
			LET pdeno_200		=0;
			LET pdeno_100		=0;
			LET pdeno_50		=0;
			LET pdeno_20		=0;
			LET ptotal_billete	=0.0; 
			LET pdeno_mon_100	=0;
			LET pdeno_mon_50	=0;
			LET pdeno_mon_20	=0;
			LET pdeno_mon_10	=0;
			LET pdeno_mon_5		=0;
			LET pdeno_mon_2		=0;
			LET pdeno_mon_1		=0;
			LET pdeno_mon_0_50	=0;
			LET pdeno_mon_0_20	=0;
			LET pdeno_mon_0_10	=0;
			LET pdeno_mon_0_05	=0;
			LET ptotal_morralla =0.0;
			LET pmonto_total    =0.0;
			
			LET pdenominacion_1	  ='';
			LET pdenominacion_2   ='';
			LET pdenominacion_3   ='';
			LET pdenominacion_4   ='';
			LET pdenominacion_5   ='';
			LET pdenominacion_6   ='';
			LET pdenominacion_7   ='1';
			LET pdenominacion_8   ='';
			LET pdenominacion_9   ='';
			LET pdenominacion_10  ='';
			LET pdenominacion_11  ='';
			LET pdenominacion_12  ='';
			LET pdenominacion_13  ='';
			LET pdenominacion_14  ='';
			LET pdenominacion_15  ='';
			LET pdenominacion_16  ='';
			LET pdenominacion_17  ='';
		
		BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,pdeno_1000,pdeno_500,pdeno_200,pdeno_100,pdeno_50, pdeno_20, ptotal_billete, pdeno_mon_100, pdeno_mon_50, pdeno_mon_20, pdeno_mon_10, 
							pdeno_mon_5, pdeno_mon_2,pdeno_mon_1, pdeno_mon_0_50, pdeno_mon_0_20, pdeno_mon_0_10, pdeno_mon_0_05, ptotal_morralla,pmonto_total;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_saldoactual_cajageneral.out';
                --TRACE ON;

                SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
				SELECT COUNT(*) INTO valida FROM bdisuc:"informix".ss_cajageneral WHERE empresa=pEmpresa AND cod_proveedor=pCajaGeneral;
				
				IF (valida > 0) THEN

						SELECT denominacion_1, cantidad_1,denominacion_2,cantidad_2,denominacion_3,cantidad_3,denominacion_4,cantidad_4,denominacion_5,cantidad_5,denominacion_6,cantidad_6,
						cantidad_7,saldo_total 
						INTO pdenominacion_1, pdeno_1000, pdenominacion_2, pdeno_500, pdenominacion_3, pdeno_200, pdenominacion_4, pdeno_100,pdenominacion_5, pdeno_50,pdenominacion_6, pdeno_20,
						pdeno_mon_1,pmonto_total
						FROM bdisuc:"informix".ss_cajageneral
						WHERE empresa=pEmpresa
						AND cod_proveedor=pCajaGeneral;
						
						LET ptotal_billete = (pdenominacion_1 * pdeno_1000) + ( pdenominacion_2 * pdeno_500) + (pdenominacion_3 * pdeno_200) + (pdenominacion_4 * pdeno_100) + (pdenominacion_5 * pdeno_50) + (pdenominacion_6 * pdeno_20);
						
						LET ptotal_morralla = (pdenominacion_7 * pdeno_mon_1);
						
						RETURN cCodRet,pdeno_1000,pdeno_500,pdeno_200,pdeno_100,pdeno_50, pdeno_20, ptotal_billete, pdeno_mon_100, pdeno_mon_50, pdeno_mon_20, pdeno_mon_10, 
							pdeno_mon_5, pdeno_mon_2,pdeno_mon_1, pdeno_mon_0_50, pdeno_mon_0_20, pdeno_mon_0_10, pdeno_mon_0_05, ptotal_morralla,pmonto_total;
					  
				ELSE	
				
                        LET cCodRet = '00001';
                        RETURN cCodRet,pdeno_1000,pdeno_500,pdeno_200,pdeno_100,pdeno_50, pdeno_20, ptotal_billete, pdeno_mon_100, pdeno_mon_50, pdeno_mon_20, pdeno_mon_10, 
							pdeno_mon_5, pdeno_mon_2,pdeno_mon_1, pdeno_mon_0_50, pdeno_mon_0_20, pdeno_mon_0_10, pdeno_mon_0_05, ptotal_morralla,pmonto_total;
              
                END IF;

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 03/09/2018',
'DESCRIPCION: SPL, que consulta las cantidades de las denominaciones de la tabla bdisuc:ss_cajageneral',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_recepdota_rollback(pFolio CHAR(8))
RETURNING CHAR(5);

DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;

LET cCodret	= '00000';
LET iSqlErr = 0;

--SET DEBUG FILE TO '/informix/jepolanco/sp_recepdota_rollback.out';
--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet;
			END IF;
		END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '11' WHERE folio_oper = pFolio;
		
		RETURN cCodRet;
	END
END PROCEDURE;