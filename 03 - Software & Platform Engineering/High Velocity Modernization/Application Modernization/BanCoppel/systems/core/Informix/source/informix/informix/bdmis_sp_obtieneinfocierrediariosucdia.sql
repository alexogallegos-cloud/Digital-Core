create procedure "informix".sp_obtieneinfocierrediariosucdia(p_dFechaSucursal DATE)
RETURNING
    VARCHAR(5),         -- CodigoRetorno
    VARCHAR(120);       -- DescripcionError

--Declaracion de variables
DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE v_sEstatus CHAR(1);
DEFINE v_sCodRet CHAR(5);
DEFINE v_iTipoReg INTEGER;
DEFINE v_sEmpresa CHAR(3);
DEFINE v_sEjecutivo CHAR(8);
DEFINE v_sNombre CHAR(45);
DEFINE v_sProducto CHAR(4);
DEFINE v_sSucursal CHAR(4);
DEFINE v_dFechaCierre CHAR(10);
DEFINE v_iNumCtasDia INTEGER;
DEFINE v_iMetasCtasDia MONEY(9,3);
DEFINE v_mMetasCtasCumplidas MONEY(18,2);
DEFINE v_mMontoCtasDia MONEY(18,2);
DEFINE v_mMontoIncrementoDia MONEY(18,2);
DEFINE v_mMetaIncremento MONEY(18,2);
DEFINE v_mSaldoCumprido MONEY(18,2);
DEFINE v_iNumAbonoCtasCap INTEGER;
DEFINE v_iNumAbonoCtasCred INTEGER;
DEFINE v_mRecVsPagoMin MONEY(18,2);
DEFINE v_mRecVsVencido MONEY(18,2);
DEFINE v_iNumCteAct INTEGER;
DEFINE v_iNumComPago INTEGER;
DEFINE v_iNumAcuerdoPago INTEGER;
DEFINE v_iNumConsEdoCta INTEGER;
DEFINE v_iNumRetiroCaptacion INTEGER;
DEFINE v_iNumRetiroColocacion INTEGER;
DEFINE v_mMontoAbonoCtasCap MONEY(18,2);
DEFINE v_mMontoAbonoCtasCred MONEY(18,2);
DEFINE v_mMontoRetiroCaptacion MONEY(18,2);
DEFINE v_mMontoRetiroColocacion MONEY(18,2);
DEFINE v_iAnio INTEGER;
DEFINE v_iMes INTEGER;
DEFINE v_sAnioMes CHAR(6);
DEFINE dMaxFecha    DATE;
DEFINE v_sEstatusSuc CHAR(1);
DEFINE v_paso CHAR(1);
DEFINE VFECHA CHAR(10);
DEFINE VNOMBRE CHAR (60);
DEFINE VMETA MONEY(9,3);
DEFINE vmetaincremento  MONEY(18,2); 
DEFINE  cod_ret			 CHAR(05);
DEFINE  mensaje			 CHAR(180);
--Inicializar Variables
LET v_sEstatus = '';
LET v_sCodRet = '00000';
LET v_iTipoReg = 0;
LET v_sEmpresa = '';
LET v_sEjecutivo = '';
LET v_sSucursal = '';
LET v_sNombre = '';
LET v_sProducto = '';
LET v_dFechaCierre = '01-01-1900';
LET v_iNumCtasDia = 0;
LET v_iMetasCtasDia = 0;
LET v_mMetasCtasCumplidas = 0;
LET v_mMontoCtasDia = 0;
LET v_mMontoIncrementoDia = 0;
LET v_mMetaIncremento = 0;
LET v_mSaldoCumprido = 0;
LET v_iNumAbonoCtasCap = 0;
LET v_iNumAbonoCtasCred = 0;
LET v_mRecVsPagoMin = 0;
LET v_mRecVsVencido = 0;
LET v_iNumCteAct = 0;
LET v_iNumComPago = 0;
LET v_iNumAcuerdoPago  = 0;
LET v_iNumConsEdoCta = 0;
LET v_iNumRetiroCaptacion = 0;
LET v_iNumRetiroColocacion = 0;
LET v_mMontoAbonoCtasCap = 0;
LET v_mMontoAbonoCtasCred = 0;
LET v_mMontoRetiroCaptacion = 0;
LET v_mMontoRetiroColocacion = 0;
LET v_iAnio = 0;
LET v_iMes = 0;
LET v_sAnioMes = '';
LET v_sEstatusSuc = '';
LET v_paso = '1';
BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  insert into mi_rptcierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,v_paso,P_COD_RET, P_MENSAJE  from bdmis:mi_fechas;
      RETURN P_COD_RET, P_MENSAJE;
    END EXCEPTION;


--Set debug file to "/pisa/pisabanco/pisa_ftes/syndein/coppel/sp_ObtieneInfoCierreDiarioSucJY.out";
--Set debug file to "gli_sp_ObtieneInfoCierreDiarioSucDiario.out";
--Trace on;

LET v_iAnio = YEAR(p_dFechaSucursal);
LET v_iMes = LPAD(MONTH(p_dFechaSucursal),2,0);
LET v_sAnioMes = v_iAnio||LPAD((v_iMes),2,0);

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN WORK;
        TRUNCATE TABLE bdmis:tmp_cifrascierresuc;
        LET v_paso = '1';
    COMMIT WORK;



		SELECT MAX(fecha_rptcierre) INTO dMaxFecha FROM bdmis:mi_rptcierresucestatus WHERE sucursal = sucursal AND fecha_rptcierre IS NOT NULL;

		IF p_dFechaSucursal = dMaxFecha THEN
							---- Información de Cierre al ultimo día de corte
                            ----  se agregaron los producto 19 (Efectiva Cheques) y 23 (Ahorre su cambio).
                            ----  se quitaron los producto 13 (Efectiva Plus) y 18 (Nomina BanCoppel)
							---- se agrega el producto 2500 CUENTA EFECTIVA JOVENES							
							---- 6011	03	REESTRUCTURA DE TARJETA DE CREDITO      
							---- 6600	03	TARJETA DE CREDITO BASICA               
							---- 6400	05	CREDINOMINA BANCOPPEL                   
							---- 6300	05	PRÉSTAMO PERSONAL BANCOPPEL 
					execute procedure "informix".sp_bitacora_rcda('integra_op_diaria', 1)
						into cod_ret, mensaje;
						if trim(cod_ret) <> '000' then
							return cod_ret ,mensaje;
						end if	
		
                 BEGIN WORK;
    				INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuario,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca,NumTDC,MetaNumTDC,CumpMetaTDC)
							SELECT {+ INDEX(mi_rptcierresuc idx_mi_rptcierresuc)} DISTINCT DECODE(producto, '6011', '6', '9999', '3', '1100','1', '2000','1','2500','1','1100','1',/*'1300','1',*/'1400','1','1200','1',
                                '1600','1',/*'1800','1',*/'1500','1','1700','1','3000','1','6001','2','6011','2','6600','2','6400','2','6300','2'
								,'1900','1','2300','1','6666','2'),'informix', NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),
                                TRIM(NVL(nombre,'')),NVL(producto,0),NVL(fecha_cierre,'01-01-1900'),NVL(num_ctasdia,0),NVL(meta_ctasdia,0),
                                NVL(p_cumpmetactas,0),NVL(monto_ctasdia,0),NVL(monto_incrementodia,0),NVL(meta_incremento,0),NVL(p_cumpsaldo,0),
                                NVL(num_abonosctascap,0),NVL(num_abonosctascred,0),NVL(p_rec_vs_pagomin,0),NVL(p_rec_vs_vencido,0),
                                NVL(num_clientel_act,0),NVL(num_compago,0),NVL(num_acuerdopago,0),NVL(num_cons_edocta,0),NVL(num_retirocapta,0),
                                NVL(num_retirocoloca,0),NVL(monto_abonosctascap,0),NVL(monto_abonosctascred,0),NVL(monto_retirocapta,0),
                                NVL(monto_retirocoloca,0),NVL(num_ctasdia,0),NVL(meta_ctasdia,0),NVL(p_cumpmetactas,0)
							FROM bdmis:mi_rptcierresuc
							WHERE ejecutivo = ejecutivo AND sucursal = sucursal
							AND   producto = producto and producto not in ('1300','1800')
                            AND fecha_cierre = p_dFechaSucursal
                            AND   empresa = empresa;
                      LET v_paso = '2';
                 COMMIT WORK;
				 
					execute procedure "informix".sp_bitacora_rcda('integra_op_diaria', 2)
						into cod_ret, mensaje;
						if trim(cod_ret) <> '000' then
							return cod_ret ,mensaje;
						end if
						
                            ---- Registro de porcentaje de Metas y cumplimientos
							
						execute procedure "informix".sp_bitacora_rcda('integra_met_cumpli', 1)
						into cod_ret, mensaje;
						if trim(cod_ret) <> '000' then
							return cod_ret ,mensaje;
						end if	
					
                 BEGIN WORK;
            		INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuario,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca/*,NumTDC,MetaNumTDC,CumpMetaTDC*/)
                            SELECT {+ INDEX(mi_rptcierresucpgeneral idx_mi_rptcierresucpgeneral)}
                                DISTINCT 4, 'informix', NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),TRIM(NVL(nombre,'')),'',NVL(fecha_cierre,'01-01-1900'),
                                0,0,NVL(p_cumdia_capta,0),NVL(p_cumdia_coloca,0),NVL(p_cumdia_saldo,0),NVL(p_cumdia_general,0),NVL(p_cummes_capta,0),0,
                                0,NVL(p_cummes_coloca,0),NVL(p_cummes_saldo,0),0,0,0,0,0,0,NVL(p_cummes_general,0),0,0,0/*,0,0,0 --NVL(p_cumdia_tdc,0),NVL(p_cummes_tdc,0)*/
						    FROM  bdmis:mi_rptcierresucpgeneral
							WHERE sucursal = sucursal and  ejecutivo = ejecutivo
							AND fecha_cierre = p_dFechaSucursal AND empresa = empresa  ;
                    LET v_paso = '3';
                 COMMIT WORK;
				 
						execute procedure "informix".sp_bitacora_rcda('integra_met_cumpli', 2)
						into cod_ret, mensaje;
						if trim(cod_ret) <> '000' then
							return cod_ret ,mensaje;
						end if				 

                            ---- Registro Acumulado
                            ----  se agregaron los producto 19 (Efectiva Cheques) y 23 (Ahorre su cambio)
                            ----  se quitaron los producto 13 (Efectiva Plus) y 18 (Nomina BanCoppel)
							---- se agrega el producto 2500 CUENTA EFECTIVA JOVENES
							
					execute procedure "informix".sp_bitacora_rcda('integra_op_acumulada', 1)
						into cod_ret, mensaje;
						if trim(cod_ret) <> '000' then
							return cod_ret ,mensaje;
						end if
							
                 BEGIN WORK;
                	INSERT INTO bdmis:tmp_cifrascierresuc(tipo_reg,usuario,Empresa,Sucursal,Ejecutivo,Nombre,Producto,FechaCierre,NumCtasDia,MetaCtasDia,
							CumpMetaCtas,MontoCtasDia,MontoIncrementoDia,MetaIncremento,CumpSaldo,NumAbonosCtasCap,NumAbonosCtasCred,RecVsPagoMin,
							RecVsPagoVencido,NumClientelAct,NumComPago,NumAcuerdoPago,NumConsEdoCta,NumRetiroCapta,NumRetiroColoca,
							MontoAbonosCtasCap,MontoAbonosCtasCred,MontoRetiroCapta,MontoRetiroColoca,NumTDC,MetaNumTDC,CumpMetaTDC)
							    SELECT DISTINCT DECODE(producto, '9999', '7', '1100','5', '2000', '5','2500','5','1100','5',/*'1300','5',*/'1400','5','1200','5',
                                '1600','5',/*'1800','5',*/'1500','5','1700','5','3000','5','6001','6','6011','6','6600','6','6400','6','6300','6',
								'1900','5','2300','5','6666','6'/*,'6300','6'*/),'informix', NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),
                                TRIM(NVL(nombre,'')),NVL(producto,0),NVL(aniomes,0),NVL(num_ctasmes,0),NVL(meta_ctasmes,0),NVL(p_cumpmetactasmes,0),
                                NVL(monto_ctasmes,0),NVL(monto_incrementomes,0),NVL(meta_incrementomes,0),NVL(p_cumpsaldomes,0),
                                NVL(num_abonosctascapmes,0),NVL(num_abonosctascredmes,0),NVL(p_rec_vs_pagominmes,0),NVL(p_rec_vs_vencidomes,0),
                                NVL(num_clientel_actmes,0),NVL(num_compagomes,0),NVL(num_acuerdopagomes,0),NVL(num_cons_edoctames,0),
                                NVL(num_retirocaptames,0),NVL(num_retirocolocames,0),NVL(monto_abonosctascapmes,0),NVL(monto_abonosctascredmes,0),
                                NVL(monto_retirocaptames,0),NVL(monto_retirocolocames,0),NVL(num_ctasmes,0),NVL(meta_ctasmes,0),NVL(p_cumpmetactasmes,0)
							FROM bdmis:mi_rptcierresucacumulejecut
							WHERE sucursal = sucursal AND ejecutivo = ejecutivo
                            AND producto = producto AND producto not in ('1300','1800')
                            AND aniomes = v_sAnioMes
                            AND empresa = empresa;
                      LET v_paso = '4';
                 COMMIT WORK;
				 
					execute procedure "informix".sp_bitacora_rcda('integra_op_acumulada', 2)
						into cod_ret, mensaje;
						if trim(cod_ret) <> '000' then
							return cod_ret ,mensaje;
						end if				 
				 --- rellenar productos Diario

					execute procedure "informix".sp_bitacora_rcda('integra_relleno_diario', 1)
						into cod_ret, mensaje;
						if trim(cod_ret) <> '000' then
							return cod_ret ,mensaje;
						end if
						
					let VFECHA = p_dFechaSucursal;
					
						SELECT mt.metanum, mt.producto, si.num_sucursal						
						FROM mi_metasprod mt, mi_sucursalesinfo si
						where  mt.aniomes = v_sAnioMes and mt.id_tiposuc = si.tipo_suc and mt.producto 
						in ('1100','2000','2500','1400','1200','1600','1500','1700','3000') 	
						into temp tmprcda_meta_d  with no log;
					
					FOREACH	cursor1
							WITH HOLD
							FOR											
						select ejecutivo, sucursal, nombre, max(metaincremento)
						into v_sEjecutivo, v_sSucursal, VNOMBRE, vmetaincremento
						from bdmis:tmp_cifrascierresuc 
						where fechacierre = VFECHA and tipo_reg = '1'
						group by 1,2,3 
						
							/* select max(metaincremento)
							 into   vmetaincremento
							 from bdmis:tmp_cifrascierresuc 
							 where ejecutivo = v_sEjecutivo and tipo_reg = 1 ;		*/				
						
						FOREACH	cursor1
							WITH HOLD
							FOR
						select metanum, producto 
						into vmeta ,v_sProducto
						from tmprcda_meta_d
						where num_sucursal = v_sSucursal
						
						--  '1100','2000','2500','1400','1200','1600','1500','1700','3000'	
							if (select count(*) from bdmis:tmp_cifrascierresuc where ejecutivo = v_sEjecutivo and
							fechacierre = VFECHA and producto = v_sProducto and tipo_reg = '1' ) = 0 then
							 

							 
								begin work;
									insert into bdmis:tmp_cifrascierresuc(usuario,nombre,metactasdia,tipo_reg,empresa,sucursal,ejecutivo,producto,fechacierre, metaincremento) 
									values      ('informix',VNOMBRE,vmeta,'1','001',v_sSucursal,v_sEjecutivo,v_sProducto,VFECHA,vmetaincremento);
								commit work;
								
							end if 
						
							
							END FOREACH
					END FOREACH
					
					execute procedure "informix".sp_bitacora_rcda('integra_relleno_diario', 2)
						into cod_ret, mensaje;
						if trim(cod_ret) <> '000' then
							return cod_ret ,mensaje;
						end if		
						
				--- rellenar productos acumulado
				
					execute procedure "informix".sp_bitacora_rcda('integra_relleno_acumulado', 1)
						into cod_ret, mensaje;
						if trim(cod_ret) <> '000' then
							return cod_ret ,mensaje;
						end if
						
						SELECT /*round*/(nvl((((mt.metanum * 24) / 30 ) * day(p_dFechaSucursal)),0)) as metanum, mt.producto, si.num_sucursal
						FROM mi_metasprod mt, mi_sucursalesinfo si
						where  mt.aniomes = v_sAnioMes and mt.id_tiposuc = si.tipo_suc and mt.producto 
						in ('1100','2000','2500','1400','1200','1600','1500','1700','3000') 						
						into temp tmprcda_meta_m  with no log;	

				FOREACH	cursor1
							WITH HOLD
							FOR			
						select ejecutivo, sucursal, nombre, max(metaincremento)
						into v_sEjecutivo, v_sSucursal, VNOMBRE, vmetaincremento
						from bdmis:tmp_cifrascierresuc 
						where fechacierre = v_sAnioMes and tipo_reg = '5'
                        group by 1,2,3 
						
						/*	 select max(metaincremento)
							 into   vmetaincremento
							 from bdmis:tmp_cifrascierresuc 
							 where ejecutivo = v_sEjecutivo and tipo_reg = 5 ;						
						*/
						
						FOREACH	cursor1
							WITH HOLD
							FOR
						select metanum, producto 
						into vmeta ,v_sProducto
						from tmprcda_meta_m
						where num_sucursal = v_sSucursal
						
						
						--  '1100','2000','2500','1400','1200','1600','1500','1700','3000'	
							if (select count(*) from bdmis:tmp_cifrascierresuc where ejecutivo = v_sEjecutivo and
							fechacierre = v_sAnioMes and producto = v_sProducto and tipo_reg = '5' ) = 0 then
							 
								begin work;
									insert into bdmis:tmp_cifrascierresuc(usuario,nombre,metactasdia,tipo_reg,empresa,sucursal,ejecutivo,producto,fechacierre, metaincremento) 
									values      ('informix',VNOMBRE,vmeta,'5','001',v_sSucursal,v_sEjecutivo,v_sProducto,v_sAnioMes,vmetaincremento);
								commit work;
								
							end if 
						
							
							END FOREACH
					END FOREACH
				
					execute procedure "informix".sp_bitacora_rcda('integra_relleno_acumulado', 2)
					into cod_ret, mensaje;
					if trim(cod_ret) <> '000' then
						return cod_ret ,mensaje;
					end if	
			
        END IF;
			--	END FOREACH;

        IF v_sCodRet <> '000' THEN
                RETURN v_sCodRet, v_sNombre;
        END IF

    RETURN '00000', 'Todo OK';

END;
END PROCEDURE;