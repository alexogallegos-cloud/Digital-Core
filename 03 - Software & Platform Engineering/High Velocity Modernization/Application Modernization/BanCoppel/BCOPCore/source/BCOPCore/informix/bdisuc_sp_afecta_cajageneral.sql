CREATE PROCEDURE "informix".sp_afecta_cajageneral(
				pempresa CHAR(3),
                pcodigo_proveedor CHAR(4),
				pusuario CHAR(8),
                pcant1  FLOAT(8),
                pcant2  FLOAT(8),
                pcant3  FLOAT(8),
                pcant4  FLOAT(8),
                pcant5  FLOAT(8),
                pcant6  FLOAT(8),
                pcant7  FLOAT(8),
                pcant8  FLOAT(8),
                pcant9  FLOAT(8),
				pcant10 FLOAT(8),
                pcant11 FLOAT(8),
                pcant12 FLOAT(8),
                pcant13 FLOAT(8),
                pcant14 FLOAT(8),
                pcant15 FLOAT(8),
                pcant16 FLOAT(8),
                pcant17 FLOAT(8),
				ptipo_afectacion CHAR(1))
                RETURNING CHAR(3) AS codret,
				CHAR(100) AS mensaje;

			DEFINE cCodRet CHAR(5);
			DEFINE iSqlErr INTEGER;
			DEFINE iNoRegistros INTEGER;
			DEFINE cMensaje CHAR(100);
			
			DEFINE fCantidad_1000   	FLOAT(8);
			DEFINE fCantidad_500		FLOAT(8);
			DEFINE fCantidad_200		FLOAT(8);
			DEFINE fCantidad_100		FLOAT(8);
			DEFINE fCantidad_50			FLOAT(8);
			DEFINE fCantidad_20			FLOAT(8);
			DEFINE fCantidad_mon_100	FLOAT(8);
			DEFINE fCantidad_mon_50		FLOAT(8);
			DEFINE fCantidad_mon_20		FLOAT(8);
			DEFINE fCantidad_mon_10		FLOAT(8);
			DEFINE fCantidad_mon_5		FLOAT(8);
			DEFINE fCantidad_mon_2		FLOAT(8);
			DEFINE fCantidad_mon_1		FLOAT(8);
			DEFINE fCantidad_mon_0_50	FLOAT(8); 
			DEFINE fCantidad_mon_0_20	FLOAT(8);
			DEFINE fCantidad_mon_0_10	FLOAT(8);
			DEFINE fCantidad_mon_0_05	FLOAT(8);
			DEFINE dMonto_total_bitacora   DECIMAL(18,2);
			DEFINE dMonto_total   DECIMAL(18,2);
			
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
			
			DEFINE valida1 INTEGER;
			DEFINE valida2 INTEGER;
			
			
			LET cCodRet = '000';
			LET iSqlErr = 0;
			LET iNoRegistros = 0;
			LET cMensaje='PROCESO EXITOSO';
	
			LET fCantidad_1000   	=0;	
			LET fCantidad_500		=0;
			LET fCantidad_200		=0;
			LET fCantidad_100		=0;
			LET fCantidad_50		=0;	
			LET fCantidad_20		=0;	
			LET fCantidad_mon_100	=0;
			LET fCantidad_mon_50	=0;	
			LET fCantidad_mon_20	=0;	
			LET fCantidad_mon_10	=0;	
			LET fCantidad_mon_5		=0;
			LET fCantidad_mon_2		=0;
			LET fCantidad_mon_1		=0;
			LET fCantidad_mon_0_50	=0;
			LET fCantidad_mon_0_20	=0;
			LET fCantidad_mon_0_10	=0;
			LET fCantidad_mon_0_05	=0;
			LET dMonto_total_bitacora=0.0; 
			LET dMonto_total==0.0;
			
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
			
			LET valida1 = 0;
			LET valida2 = 0;
		
		BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
						LET cMensaje='';
                        RETURN cCodRet,cMensaje;
                END EXCEPTION;

               --SET DEBUG FILE TO '/tmp/mfinis/sp_afecta_cajageneral.out';
               --TRACE ON;

                SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				
				--VALIDA QUE EXISTA LA CAJA GRAL
				SELECT COUNT(*) INTO valida1 FROM bdisuc:"informix".ss_cajageneral WHERE empresa=pempresa AND cod_proveedor=pcodigo_proveedor;
				IF (valida1 < 1) THEN
						LET cCodRet = '001';
						LET cMensaje='NO EXISTE LA CAJA GENERAL';
                        RETURN cCodRet,cMensaje;
				END IF;
				
				--VALIDA QUE EXISTA EL USUARIO
				SELECT COUNT(*) INTO valida2 FROM bdinteg:"informix".si_ejecut WHERE ejecutivo=pusuario;
				IF (valida2 < 1) THEN
						LET cCodRet = '002';
						LET cMensaje='NO EXISTE EL USUARIO';
                        RETURN cCodRet,cMensaje;
				END IF;
				
				--VALIDA TIPO AFECTACION
				IF ptipo_afectacion NOT IN ('S','R')   THEN
						LET cCodRet = '003';
						LET cMensaje='TIPO DE AFECTACION INCORRECTA';
                        RETURN cCodRet,cMensaje;
				END IF;
				
							
				SELECT  NVL(denominacion_1,0),NVL(denominacion_2,0),NVL(denominacion_3,0),NVL(denominacion_4,0),NVL(denominacion_5,0),NVL(denominacion_6,0)
				INTO pdenominacion_1,pdenominacion_2,pdenominacion_3,pdenominacion_4,pdenominacion_5, pdenominacion_6
				FROM bdisuc:ss_cajageneral
				WHERE empresa=pempresa AND	cod_proveedor = pcodigo_proveedor;

				LET dMonto_total_bitacora=(pdenominacion_1 * pcant1) + (pdenominacion_2 * pcant2) + (pdenominacion_3*pcant3) + (pdenominacion_4 * pcant4) + (pdenominacion_5* pcant5)  +  (pdenominacion_6 * pcant6) + (pdenominacion_7* pcant13);
				
				
				IF(ptipo_afectacion='R') THEN
						 UPDATE bdisuc:"informix".ss_cajageneral SET 
							cantidad_1 = cantidad_1 - pcant1,
							cantidad_2 = cantidad_2 - pcant2,
							cantidad_3 = cantidad_3 - pcant3,
							cantidad_4 = cantidad_4 - pcant4,
							cantidad_5 = cantidad_5 - pcant5,
							cantidad_6 = cantidad_6 - pcant6,
							cantidad_7 = cantidad_7 - pcant13,
							saldo_total = saldo_total - dMonto_total_bitacora
						WHERE
							empresa=pempresa AND	
							cod_proveedor = pcodigo_proveedor;
							
				ELSE
						UPDATE bdisuc:"informix".ss_cajageneral SET 
							cantidad_1 = cantidad_1 + pcant1,
							cantidad_2 = cantidad_2 + pcant2,
							cantidad_3 = cantidad_3 + pcant3,
							cantidad_4 = cantidad_4 + pcant4,
							cantidad_5 = cantidad_5 + pcant5,
							cantidad_6 = cantidad_6 + pcant6,
							cantidad_7 = cantidad_7 + pcant13,
							saldo_total = saldo_total + dMonto_total_bitacora
						WHERE
							empresa=pempresa AND	
							cod_proveedor = pcodigo_proveedor;
					
				END IF;
				
				LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
						
				--ACTUALIZACION DE CANTIDADES
                IF iNoRegistros = 0 THEN
                    LET cCodRet = '004';
					LET cMensaje='ERROR AL ACTUALIZAR EL REGISTRO';
					RETURN cCodRet, iNoRegistros;
                END IF;
				
				--ACTUALIZACION DE TOTAL SALDO	
				/*SELECT NVL((cantidad_1 * denominacion_1),0)+ NVL((cantidad_2 * denominacion_2),0)+ NVL((cantidad_3 * denominacion_3),0)+ NVL((cantidad_4 * denominacion_4),0)+
				NVL((cantidad_5 * denominacion_5),0)+ NVL((cantidad_6 * denominacion_6),0)+NVL((cantidad_7 * 1),0)
				INTO dMonto_total
				FROM bdisuc:ss_cajageneral
				WHERE empresa=pempresa AND	cod_proveedor = pcodigo_proveedor;
				
				UPDATE bdisuc:"informix".ss_cajageneral SET 
				saldo_total =  dMonto_total
				WHERE empresa=pempresa AND	cod_proveedor = pcodigo_proveedor;
							
				LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
						
				--ACTUALIZACION DE SALDO
                IF iNoRegistros = 0 THEN
                    LET cCodRet = '004';
					LET cMensaje='ERROR AL ACTUALIZAR EL REGISTRO';
					RETURN cCodRet, iNoRegistros;
                END IF;*/
				
				INSERT INTO bdisuc:"informix".ss_bitacora_importe(empresa, caja_general, usuario, nombre, fecha_modificacion, descripcion, saldo, cantidad_1000, cantidad_500, cantidad_200, cantidad_100, cantidad_50, cantidad_20, cant_m_100, cant_m_50, cant_m_20, cant_m_10, cant_m_5, cant_m_2, cant_m_1, cant_m_05, cant_m_02, cant_m_01, cant_m_005) 
				VALUES(pempresa, pcodigo_proveedor, pusuario, (SELECT nombre FROM bdinteg:"informix".si_ejecut WHERE ejecutivo=pusuario), CURRENT, ptipo_afectacion, dMonto_total_bitacora, pcant1, pcant2, pcant3, pcant4, pcant5, pcant6, pcant7, pcant8, pcant9, pcant10, pcant11, pcant12, pcant13, pcant14, pcant15, pcant16, pcant17);
				
				LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
				
				--INSERTAR REGISTRO EN BITACORA
				IF iNoRegistros = 0 THEN
                    LET cCodRet = '005';
					LET cMensaje='ERROR AL REGISTAR EN BITACORA';
                    RETURN cCodRet, iNoRegistros;
                 END IF;
				
				
				RETURN cCodRet,cMensaje;
					  

        END;

END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 03/09/2018',
'DESCRIPCION: SPL, que actualiza las cantidades de las denominaciones de la tabla bdisuc:ss_cajageneral',
'BD: bdisuc';

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