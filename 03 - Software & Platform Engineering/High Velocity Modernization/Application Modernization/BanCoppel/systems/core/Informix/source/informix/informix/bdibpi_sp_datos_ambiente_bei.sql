CREATE PROCEDURE "informix".sp_datos_ambiente_bei(pTransCtasPro CHAR(4),
													pCtasTerceros CHAR(4),
													pPagoTelmex CHAR(4),
													pPagoServSky CHAR(4),
													pCheques CHAR(4),
													pTransSpei CHAR(4)
													)
RETURNING CHAR(5),CHAR(80),CHAR(80),CHAR(80),CHAR(80),CHAR(80),CHAR(80),
CHAR(5),CHAR(925),CHAR(925),CHAR(925),CHAR(925),CHAR(925),CHAR(925),CHAR(925),CHAR(925);
	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LOS PROCDUCTOS Y LOS HORARIOS PARA LA BANCA EMPRESARIAL
	-- AUTOR : Francisco Rodríguez Ibarra
	-- FECHA : 26/08/2011
	-- BD: bdibpi
	-- SOLICITO :Mauricio León
	-- DESCRIPCION:  SE AGRAGARON PARAMETROS DE SALIDA PARA HORARIO DE CHEQUERAS
	-- AUTOR : Jose Ruben Lopez Hernandez
	-- FECHA : 26/03/2013
	-- BD: bdibpi
	-- SOLICITO :Jorge Nuñez
	-- DESCRIPCION: INCREMENTO DE VARIABLES DE PRODUCTOS PERMITIDOS A 80 CARACTERES
	-- AUTOR : ING. ALFONSO CRUZ
	-- FECHA : 29/07/2013
	-- BD: bdibpi
	-- SOLICITO : Mauricio Leon
	--***************************************************************************************************
	--DECLARACION DE VARIABLES
	DEFINE vCod_Ret CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vIdOpe CHAR(4);
	DEFINE vProducto CHAR(4);
	DEFINE vTransCtasPropias VARCHAR(80);
	DEFINE vCtasTerceros VARCHAR(80);
	DEFINE vPagoTelmex VARCHAR(80);
	DEFINE vCheques VARCHAR(80);
	DEFINE vPagoServSKY VARCHAR(80);	
	DEFINE vTransSPEI VARCHAR(80);
--***************************************************
	--DECLARACION DE VARIABLES
	DEFINE vIdOper CHAR(4);
	DEFINE vH_Ini_Baja CHAR(8);
	DEFINE vH_Fin_Baja	CHAR(8);
	DEFINE vMsn_TimeOut CHAR(150);
	DEFINE vFec_Baja CHAR(10);
	DEFINE vIcont INTEGER;
	DEFINE vIcont2 INTEGER;
	DEFINE vHorarios1 LVARCHAR(925);
	DEFINE vHorarios2 LVARCHAR(925);
	DEFINE vHorarios3 LVARCHAR(925);
	DEFINE vHorarios4 LVARCHAR(925);
	DEFINE vHorarios5 LVARCHAR(925);
	DEFINE vHorarios6 LVARCHAR(925);
	DEFINE vHorarios7 LVARCHAR(925);
	DEFINE vHorarios8 LVARCHAR(925);
	DEFINE vCadenaHorario CHAR(185);
	
--****************************************************
	--INICIALIZAR VALORES A VARIABLES;
	LET vCod_Ret='00000';
	LET vIdOpe = '';
	LET vProducto = '';
	LET vTransCtasPropias ='1008';
	LET vTransSPEI='1015';
	LET vCtasTerceros ='1016';
	LET vPagoTelmex ='1020';
	LET vPagoServSKY ='1021';
	LET vCheques ='1CHQ';

--********************************************************
	--INICIALIZAR VALORES A VARIABLES;
	
	LET vIdOper='';
	LET vH_Ini_Baja='01-01-1900';
	LET vH_Fin_Baja='01-01-1900';
	LET vMsn_TimeOut='';
	LET vFec_Baja='';
	LET vCadenaHorario='';
	LET vIcont=0;
	LET vIcont2=1;
	--LET vDescAvatar='';
	LET vHorarios1 ='';
	LET vHorarios2 ='';
	LET vHorarios3 ='';
	LET vHorarios4 ='';
	LET vHorarios5 ='';
	LET vHorarios6 ='';
	LET vHorarios7 ='';
	LET vHorarios8 ='';
--SET DEBUG FILE TO "sp_datos_ambiente_bei.out";
--TRACE ON;
--*********************************************************
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,'','','','','','','','','','','','','','','';
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3 ;
		SET ISOLATION DIRTY READ ;
		FOREACH
			SELECT id_oper,producto
				INTO vIdOpe,vProducto
				FROM bdibpi:"informix".bpi_pprod
				WHERE id_oper IN(pTransCtasPro,pCtasTerceros,pPagoTelmex,pPagoServSky,pCheques,pTransSpei)
				ORDER BY id_oper
			
				IF(vIdOpe=pTransCtasPro)  THEN	LET vTransCtasPropias=vTransCtasPropias||vProducto;	END IF;
				IF(vIdOpe=pCtasTerceros)  THEN	LET vCtasTerceros=vCtasTerceros||vProducto;         END IF;
				IF(vIdOpe=pPagoTelmex)    THEN	LET vPagoTelmex=vPagoTelmex||vProducto;	            END IF;
				IF(vIdOpe=pPagoServSky)   THEN	LET vPagoServSKY=vPagoServSKY||vProducto;	        END IF;
				IF(vIdOpe=pCheques)       THEN	LET vCheques=vCheques||vProducto; 	                END IF;
				IF(vIdOpe=pTransSpei)	  THEN  LET vTransSPEI=vTransSPEI||vProducto;				END IF;

		END FOREACH;
--**********************************************************************************************************************************
--Horarios de Operacion
--**********************************************************************************************************************************
		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		FOREACH
		
			SELECT NVL(id_oper,' ')||';'||NVL(h_fin_baja::CHAR(8),'') ||';'||NVL(h_ini_baja::CHAR(8),' ')||';'||NVL(msn_timeout,' ')||';'||NVL(fecha_baja,' ')||';'
				INTO vCadenaHorario
			 FROM bdibpi:"informix".bpi_cat_operaciones
			     WHERE id_oper NOT IN('1000','1001' ,'1002' ,'1003','1004','1005','1006','1007','1011','1013','1014','1017','2007','2009','2011','2101','2100')
			 ORDER BY id_oper
			 
			 IF (vCadenaHorario<>'' OR vCadenaHorario IS NOT NULL) THEN
				LET vIcont=vIcont+1;
						
				IF(vIcont>0  AND vIcont<= 5) THEN	 LET vHorarios1=vHorarios1||TRIM(vCadenaHorario);	END IF;
				IF(vIcont>5  AND vIcont<=10) THEN	 LET vHorarios2=vHorarios2||TRIM(vCadenaHorario);	END IF;
				IF(vIcont>10 AND vIcont<=15) THEN    LET vHorarios3=vHorarios3||TRIM(vCadenaHorario);	END IF;
				IF(vIcont>15 AND vIcont<=20) THEN    LET vHorarios4=vHorarios4||TRIM(vCadenaHorario);	END IF;
				IF(vIcont>20 AND vIcont<=25) THEN 	 LET vHorarios5=vHorarios5||TRIM(vCadenaHorario);	END IF;
				IF(vIcont>25 AND vIcont<=30) THEN 	 LET vHorarios6=vHorarios6||TRIM(vCadenaHorario);	END IF;
				IF(vIcont>30 AND vIcont<=35) THEN 	 LET vHorarios7=vHorarios7||TRIM(vCadenaHorario);	END IF;
				IF(vIcont>35 AND vIcont<=40) THEN 	 LET vHorarios8=vHorarios8||TRIM(vCadenaHorario);	END IF;
				
			END IF;
		 END FOREACH;
		 IF (vIcont=0) THEN
			LET vCod_Ret='00001';			
			RETURN vCod_Ret,vTransCtasPropias,vCtasTerceros,vPagoTelmex,vPagoServSKY,vCheques,vTransSPEI,vCod_Ret,vHorarios1,vHorarios2,vHorarios3,vHorarios4,vHorarios5,vHorarios6,vHorarios7,vHorarios8;
		 END IF;
--********************************************************************************************** FIN
		RETURN vCod_Ret,vTransCtasPropias,vCtasTerceros,vPagoTelmex,vPagoServSKY,vCheques,vTransSPEI,vCod_Ret,vHorarios1,vHorarios2,vHorarios3,vHorarios4,vHorarios5,vHorarios6,vHorarios7,vHorarios8 WITH RESUME;
		
	END;
END PROCEDURE;