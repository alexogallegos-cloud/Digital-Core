CREATE PROCEDURE "informix".sp_consultadatospagare_web(pEmpresa CHAR(3),pCuenta CHAR(20))
	RETURNING 	CHAR(5)  		AS retorno,
				CHAR(3)  		AS Empresa,
				CHAR(4)	 		AS Sucursal,
				CHAR(4)  		AS Cod_instrum,
				CHAR(20) 		AS Cuenta,
				CHAR(20)  		AS Numcte,
				CHAR(13)		AS RFC,
				CHAR(26) 		AS Apellido_pat,
				CHAR(26) 		AS Apellido_mat,
				CHAR(26) 		AS Nombre1,
				CHAR(26) 		AS Nombre2,
				CHAR(8)  		AS Promotor,
				CHAR(3)  		AS Tipo_banca,
				CHAR(20) 		AS Cta_cheques,
				MONEY(14,2)		AS Capital,
				DATE	 		AS Fecha_alta,
				DATE     		AS Fecha_venc,
				SMALLINT 		AS Plazo,
				SMALLINT 		AS Direccion_env,
				MONEY(14,2)		AS Imp_ISR,
				MONEY(14,2) 	AS Rend_neto,
				DECIMAL(9,6) 	AS Tasa_bruta,
				DECIMAL(9,6) 	AS Tasa_isr,
				DECIMAL(9,6) 	AS Tasa_neta,
				DECIMAL(9,6) 	AS Tasa_base,
				SMALLINT  		AS Secuencia2,
				CHAR(1)			AS Status_cta,
				CHAR(2)			AS Motivo,
				DATE 			AS Fecha_ult_mov,
				DATE 			AS Fec_cancelac,
				DATE 			AS Fec_reinversion,
				MONEY(14,2) 	AS Sdo_retenido,
				MONEY(14,2) 	AS Sdo_cong,
				CHAR(2)			AS Opcion_retiro,
				MONEY(14,2) 	AS Intereses,
				MONEY(14,2) 	AS ISR,
				DECIMAL(9,6) 	AS Tasa,
				DECIMAL(9,6) 	AS Sobretasa,
				SMALLINT 		AS Dia_sdo_pos,
				MONEY(14,2) 	AS Acum_sdo_pos,
				MONEY(14,2)		AS Sdo_prom_mesant,
				MONEY(14,2)		AS Sdo_mes_ant,
				MONEY(14,2)		AS Sdo_dia_ant,
				MONEY(14,2)		AS Sdo_ult_corte,
				CHAR(8)			AS Adicionado,
				DATE 			AS Fecha_val,
				CHAR(8) 		AS Modificado,
				DATE 			AS Fecha_mod,
				CHAR(3) 		AS Plaza,
				CHAR(1)			AS Reg_firmas,
				CHAR(1)			AS Envio,
				CHAR(1)			AS Cobraisr,
				CHAR(1)			AS Per_acred_int,
				CHAR(2)			AS Al_Vencimiento;

	-- DEFINICION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE cValRetorno		CHAR(5);
	DEFINE cValRetorno2		CHAR(5);
	DEFINE cEmpresa			CHAR(3);
	DEFINE cSucursal		CHAR(4);
	DEFINE cCod_instrum     CHAR(4);
	DEFINE cCuenta			CHAR(20);
	DEFINE cNumcte			CHAR(20);
	DEFINE cNumcte2			CHAR(20);
	DEFINE cPromotor		CHAR(8);
	DEFINE cTipo_banca		CHAR(3);
	DEFINE cCta_cheques		CHAR(20);
	DEFINE cNombre			CHAR(60);
	DEFINE cTipo			CHAR(1);
	DEFINE cNombre2			CHAR(20);
	DEFINE cApell_pat       CHAR(26);
	DEFINE cApell_mat		CHAR(26);
	DEFINE cNombre1         CHAR(26);
	DEFINE cRFC				CHAR(13);
	DEFINE cFech_nac		CHAR(10);
	DEFINE cParentesco		CHAR(2);
	DEFINE cProducto		CHAR(4);
	DEFINE cStatus_cta      CHAR(1);
	DEFINE cMotivo			CHAR(2);
	DEFINE cOpcion_retiro   CHAR(2);
	DEFINE cAdicionado		CHAR(8);
	DEFINE cPlaza    		CHAR(3);
	DEFINE cReg_firmas	 	CHAR(1);
	DEFINE cEnvio			CHAR(1);
	DEFINE cCobraisr		CHAR(1);
	DEFINE cPer_acred_int   CHAR(1);
	DEFINE cModificado		CHAR(8);
	DEFINE mCapital    		MONEY(14,2);
	DEFINE mImp_ISR			MONEY(14,2);
	DEFINE mRend_neto		MONEY(14,2);
	DEFINE cSdo_retenido	MONEY(14,2);
	DEFINE cSdo_cong		MONEY(14,2);
	DEFINE cIntereses		MONEY(14,2);
	DEFINE cISR				MONEY(14,2);
	DEFINE cAcum_sdo_pos	MONEY(14,2);
	DEFINE cSdo_prom_mesant MONEY(14,2);
	DEFINE cSdo_mes_ant		MONEY(14,2);
	DEFINE cSdo_dia_ant		MONEY(14,2);
	DEFINE cSdo_ult_corte   MONEY(14,2);
	DEFINE dFecha_alta		DATE;
	DEFINE dFecha_venc		DATE;
	DEFINE dFecha_venc2		DATE;
	DEFINE cFecha_ult_mov   DATE;
	DEFINE cFec_cancelac    DATE;
	DEFINE cFec_reinversion DATE;
	DEFINE cFecha_val		DATE;
	DEFINE cFecha_mod		DATE;
	DEFINE sPlazo			SMALLINT;
	DEFINE sPlazo2			SMALLINT;
	DEFINE sDireccion_env	SMALLINT;
	DEFINE sCantReg         SMALLINT;
	DEFINE sSecuencia       SMALLINT;
	DEFINE cDia_sdo_pos		SMALLINT;
	DEFINE cSecuencia2		SMALLINT;
	DEFINE vTasa_bruta		DECIMAL(9,6);
	DEFINE vTasa_isr		DECIMAL(9,6);
	DEFINE vTasa_neta		DECIMAL(9,6);
	DEFINE vTasa_base		DECIMAL(9,6);
	DEFINE cTasa			DECIMAL(9,6);
	DEFINE cSobretasa		DECIMAL(9,6);
	DEFINE cVencimiento		CHAR(2);
	DEFINE iCanIntVen		INTEGER;
	
	
	
	--INICIALIZACION DE VARIABLES
	LET cValRetorno     = '00000';
	LET cValRetorno2    = '000';
	LET cEmpresa		= '';
	LET cSucursal       = '';
	LET cCod_instrum    = '';
	LET cCuenta  		= '';
	LET cNumcte			= '';
	LET cPromotor		= '';
	LET cTipo_banca		= '';
	LET cCta_cheques	= '';
	LET cTipo			= '';
	LET cNumcte2		= '';
	LET cApell_pat      = '';
	LET cApell_mat      = '';
	LET cNombre1		= '';
	LET cNombre2		= '';
	LET cRFC			= '';
	LET cFech_nac		= '';
	LET cParentesco		= '';
	LET cProducto		= '';
	LET cStatus_cta 	= '';
	LET cMotivo			= '';
	LET cOpcion_retiro  = '';
	LET cModificado		= '';
	LET cAdicionado		= '';
	LET cPlaza    		= '';
	LET cReg_firmas	 	= '';
	LET cEnvio			= '';
	LET cCobraisr		= '';
	LET cPer_acred_int  = '';
	LET mCapital		= 0;
	LET mImp_ISR		= 0;
	LET mRend_neto      = 0;
	LET sPlazo			= 0;
	LET sDireccion_env	= 0;
	LET sCantReg 		= 0;
	LET vTasa_base		= 0;
	LET vTasa_bruta		= 0;
	LET vTasa_isr 		= 0;
	LET vTasa_neta      = 0;
	LET sSecuencia		= 0;
	LET cSecuencia2		= 0;
	LET cIntereses		= 0;
	LET cISR			= 0;
	LET cTasa			= 0;
	LET cSobretasa		= 0;
	LET cDia_sdo_pos	= 0;
	LET cAcum_sdo_pos	= 0;
	LET cSdo_prom_mesant= 0;
	LET cSdo_mes_ant	= 0;
	LET cSdo_dia_ant	= 0;
	LET cSdo_ult_corte  = 0;
	LET cSdo_retenido	= 0;
	LET cSdo_cong		= 0;
	LET dFecha_alta		= date(1);
	LET dFecha_venc 	= date(1);
	LET dFecha_venc2	= date(1);
	LET cFecha_ult_mov  = date(1);
	LET cFec_cancelac   = date(1);
	LET cFec_reinversion= date(1);
	LET cFecha_val		= date(1);
	LET cFecha_mod		= date(1);
	LET cVencimiento	= '';
	LET iCanIntVen		= 0;
	

	--SET DEBUG FILE TO "/respaldosbd/felipe/sp_consultadatospagare.out"; 
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
		IF NVL(pEmpresa,'') = '' OR NVL(pCuenta,'') = '' THEN
			LET cValRetorno = '00086';
		ELSE
					
			SELECT empresa,sucursal,cod_instrum,cuenta,num_cte,capital,plazo,fecha_alta,fecha_venc,promotor,tipo_banca,direcc_envio,cta_cheques,secuencia,status_cta,motivo,fec_ult_mov,fec_cancelac,fec_reinversion,sdo_retenido,sdo_cong,opcion_retiro,intereses,isr,tasa,sobretasa,dia_sdo_pos,acum_sdo_pos,sdo_prom_mesant,sdo_mes_ant,sdo_dia_ant,sdo_ult_corte,adicionado,fecha_val,modificado,fecha_mod,plaza,reg_firmas,envio,cobraisr,per_acred_int
			INTO cEmpresa,cSucursal,cCod_instrum,cCuenta,cNumcte,mCapital,sPlazo,dFecha_alta,dFecha_venc,cPromotor,cTipo_banca,sDireccion_env,cCta_cheques,cSecuencia2,cStatus_cta,cMotivo,cFecha_ult_mov,cFec_cancelac,cFec_reinversion,cSdo_retenido,cSdo_cong,cOpcion_retiro,cIntereses,cISR,cTasa,cSobretasa,cDia_sdo_pos,cAcum_sdo_pos,cSdo_prom_mesant,cSdo_mes_ant,cSdo_dia_ant,cSdo_ult_corte,cAdicionado,cFecha_val,cModificado,cFecha_mod,cPlaza,cReg_firmas,cEnvio,cCobraisr,cPer_acred_int
			FROM bdinvers:"informix".sv_maeinv 
			WHERE empresa = pEmpresa 
			AND cuenta = pCuenta 
			AND secuencia = ( SELECT MAX(secuencia) FROM bdinvers:"informix".sv_maeinv WHERE empresa = pEmpresa AND cuenta = pCuenta );
			
			--AND status_cta = '1';
			
			FOREACH
				SELECT UNIQUE( inst_vento) INTO cVencimiento FROM sv_maeinstrucc WHERE empresa = pEmpresa  AND cuenta = pCuenta
				LET iCanIntVen = iCanIntVen + 1;
			END FOREACH
			
			IF iCanIntVen = 1 THEN
				IF TRIM(cVencimiento)= '02' THEN
					LET cVencimiento = '03';
				END IF;
			ELSE
				LET cVencimiento = '02';
			END IF;
				
				EXECUTE PROCEDURE bdinvers:"informix".consctesfirminv(pEmpresa,cCuenta,'','1')
				INTO cValRetorno2,cTipo,cNumcte2,cApell_pat,cApell_mat,cNombre1,cNombre2,cRFC,cFech_nac,sSecuencia,cParentesco,cProducto;
				
					
					IF cValRetorno2 = "000" THEN
                        --LET cNombre = TRIM(cApell_pat)|| ' ' || TRIM(cApell_mat) || ' ' ||TRIM(TRIM(cNombre1) || ' ' || TRIM(cNombre2));				
						EXECUTE  PROCEDURE bdinvers:"informix".conprev1(pEmpresa, cSucursal, cCod_instrum, mCapital,'', sPlazo, '01', 0.00, 'S')
						INTO cValRetorno2,sPlazo2,dFecha_venc2,mImp_ISR,mRend_neto,vTasa_bruta,vTasa_isr,vTasa_neta,vTasa_base;
						
						IF cValRetorno2 <> "000" THEN
                            let cValRetorno2= "00001"; 
							LET cValRetorno = cValRetorno2;
						END IF;
					ELSE
                        let cValRetorno2= "00001"; 
						LET cValRetorno = cValRetorno2;
						
					END IF;			
		END IF;
			RETURN cValRetorno,cEmpresa,cSucursal,cCod_instrum,cCuenta,cNumcte,cRFC,cApell_pat,cApell_mat,cNombre1,cNombre2,cPromotor,cTipo_banca,cCta_cheques,mCapital,dFecha_alta,dFecha_venc,sPlazo,sDireccion_env,mImp_ISR,mRend_neto,vTasa_bruta,vTasa_isr,vTasa_neta,vTasa_base,cSecuencia2,cStatus_cta,cMotivo,cFecha_ult_mov,cFec_cancelac, cFec_reinversion,cSdo_retenido,cSdo_cong,cOpcion_retiro,cIntereses,cISR,cTasa,cSobretasa,cDia_sdo_pos,cAcum_sdo_pos,cSdo_prom_mesant,cSdo_mes_ant,cSdo_dia_ant,cSdo_ult_corte,cAdicionado,cFecha_val,cModificado,cFecha_mod,cPlaza,cReg_firmas,cEnvio,cCobraisr,cPer_acred_int,cVencimiento;
			
	END
END PROCEDURE 

