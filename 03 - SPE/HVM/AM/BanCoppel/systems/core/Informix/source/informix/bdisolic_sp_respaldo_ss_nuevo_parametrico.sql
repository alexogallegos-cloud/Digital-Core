CREATE PROCEDURE "informix".sp_respaldo_ss_nuevo_parametrico(o_empresa CHAR(3), o_numsol CHAR(20))
RETURNING CHAR(5) AS codret;
		
--DECLARACION DE VARIABLES
DEFINE cCodRet							CHAR(5);
DEFINE	cEmpresa                     	CHAR(3);
DEFINE	cNum_solicitud               	CHAR(20);
DEFINE	cStatus_solicitud            	CHAR(1);
DEFINE	cSituacion_especial          	CHAR(1);
DEFINE	iCausa_sitesp                	INTEGER;
DEFINE	iPuntos_parcn                	SMALLINT;
DEFINE	iPar_altoriesgo              	SMALLINT;
DEFINE	iPar_celulares               	SMALLINT;
DEFINE	iPar_prestamos               	SMALLINT;
DEFINE	iIngreso_mensual             	INTEGER ;
DEFINE	iCap_sistematica_abono       	INTEGER ;
DEFINE	iTope_abonocoppel            	INTEGER ;
DEFINE	iCapmaxima_abono             	INTEGER ;
DEFINE	iCapreal_abono               	INTEGER ;
DEFINE	iLineacredito_real           	INTEGER ;
DEFINE	iLineacreditotope            	INTEGER ;
DEFINE	cFechalineacreditoreal       	CHAR(10);
DEFINE	cFechalineacreditotope       	CHAR(10);
DEFINE	iCompromisossic              	INTEGER ;
DEFINE	iFlaglineacreditoesp         	SMALLINT;
DEFINE	cCod_ret                     	CHAR(3);
DEFINE	iLimitecredito               	INTEGER ;
DEFINE	iLimitecreditopesos          	INTEGER ;
DEFINE	iParaaltoriesgonvo           	INTEGER ;
DEFINE	cCampo_1                     	CHAR(1) ;
DEFINE	cCampo_2                     	CHAR(1) ;
DEFINE	cCampo_3                     	CHAR(1) ;
DEFINE	cClienteprospecto            	CHAR(10);
DEFINE	iId_situaciones              	INTEGER ;
DEFINE	cPuntualidad_ref1            	CHAR(2) ;
DEFINE	cPuntualidad_ref2            	CHAR(2) ;
DEFINE	cFlagtestigoparametricocn    	CHAR(1) ;
DEFINE	cFlag_altadirecta_asupervisar	CHAR(1) ;
DEFINE	iFuntos_var_param            	INTEGER ;
DEFINE	iFuntos_var_sic              	INTEGER ;
DEFINE	iScore_domicilio             	INTEGER ;
DEFINE	iNuevo_puntajefinal          	SMALLINT ;
DEFINE	iCampo_4                     	INTEGER ;
DEFINE	iPrepuntajealtoriesgo        	INTEGER ;
DEFINE	cFlag_pagoini                	CHAR(1);
DEFINE	cPorc_pagoini                	CHAR(4);
DEFINE	iMonto_disp_pagoini          	INTEGER;
DEFINE	cFlag_prestamo               	CHAR(1);
DEFINE	cCanal_origensol             	CHAR(1);
DEFINE	cGrupo_eval                  	CHAR(1);
DEFINE	cGrupo_hit                   	CHAR(1);
DEFINE	cFlagtipomsgmotos            	CHAR(1);
DEFINE	iMontodispmotos              	INTEGER;
DEFINE	cPorcpimotos                 	CHAR(4) ;
DEFINE iSqlErr INTEGER;

LET cCodRet= '00000';
LET	cEmpresa                     	='';
LET	cNum_solicitud               	='';
LET	cStatus_solicitud            	='';
LET	cSituacion_especial          	='';
LET	iCausa_sitesp                	= 0;
LET	iPuntos_parcn                	=0;
LET	iPar_altoriesgo              	=0;
LET	iPar_celulares               	=0;
LET	iPar_prestamos               	=0;
LET	iIngreso_mensual             	= 0;
LET	iCap_sistematica_abono       	= 0;
LET	iTope_abonocoppel            	= 0;
LET	iCapmaxima_abono             	= 0;
LET	iCapreal_abono               	= 0;
LET	iLineacredito_real           	= 0;
LET	iLineacreditotope            	= 0;
LET	cFechalineacreditoreal       	='';
LET	cFechalineacreditotope       	='';
LET	iCompromisossic              	= 0;
LET	iFlaglineacreditoesp         	=0;
LET	cCod_ret                     	='';
LET	iLimitecredito               	= 0;
LET	iLimitecreditopesos          	= 0;
LET	iParaaltoriesgonvo           	= 0;
LET	cCampo_1                     	='';
LET	cCampo_2                     	='';
LET	cCampo_3                     	='';
LET	cClienteprospecto            	='';
LET	iId_situaciones              	= 0;
LET	cPuntualidad_ref1            	='';
LET	cPuntualidad_ref2            	='';
LET	cFlagtestigoparametricocn    	='';
LET	cFlag_altadirecta_asupervisar	='';
LET	iFuntos_var_param            	= 0;
LET	iFuntos_var_sic              	= 0;
LET	iScore_domicilio             	= 0;
LET	iNuevo_puntajefinal          	=0;
LET	iCampo_4                     	= 0;
LET	iPrepuntajealtoriesgo        	= 0;
LET	cFlag_pagoini                	='';
LET	cPorc_pagoini                	='';
LET	iMonto_disp_pagoini          	= 0;
LET	cFlag_prestamo               	='';
LET	cCanal_origensol             	='';
LET	cGrupo_eval                  	='';
LET	cGrupo_hit                   	='';
LET	cFlagtipomsgmotos            	='';
LET	iMontodispmotos              	= 0;
LET	cPorcpimotos                 	='';
LET iSqlErr = 0;
--LET cCodRet = '00000';

--LET cEmpresa = '001';



--SET DEBUG FILE TO "/home/sysifx/JesusTASF/sp_respalda_ss_nuevo_parametrico.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
	
	FOREACH 
		--SE GUARDAN LOS VALORES EN LAS VARIABLES
		SELECT Empresa,Num_solicitud,Status_solicitud,Situacion_especial,Causa_sitesp,Puntos_parcn,Par_altoriesgo,Par_celulares,Par_prestamos,Ingreso_mensual
			,Cap_sistematica_abono,Tope_abonocoppel,Capmaxima_abono,Capreal_abono,Lineacredito_real,Lineacreditotope,Fechalineacreditoreal,Fechalineacreditotope
			,Compromisossic,Flaglineacreditoesp,Cod_ret,Limitecredito,Limitecreditopesos,Paraaltoriesgonvo,Campo_1,Campo_2,Campo_3,Clienteprospecto,Id_situaciones
			,Puntualidad_ref1,Puntualidad_ref2,Flagtestigoparametricocn,Flag_altadirecta_asupervisar,puntos_var_param,puntos_var_sic,Score_domicilio,Nuevo_puntajefinal
			,Campo_4,Prepuntajealtoriesgo,Flag_pagoini,Porc_pagoini,Monto_disp_pagoini,Flag_prestamo,Canal_origensol,Grupo_eval,Grupo_hit,Flagtipomsgmotos,Montodispmotos
			,Porcpimotos
		INTO cEmpresa,cNum_solicitud,cStatus_solicitud,cSituacion_especial,iCausa_sitesp,iPuntos_parcn,iPar_altoriesgo,iPar_celulares,iPar_prestamos,iIngreso_mensual
			,iCap_sistematica_abono,iTope_abonocoppel,iCapmaxima_abono,iCapreal_abono,iLineacredito_real,iLineacreditotope,cFechalineacreditoreal,cFechalineacreditotope
			,iCompromisossic,iFlaglineacreditoesp,cCod_ret,iLimitecredito,iLimitecreditopesos,iParaaltoriesgonvo,cCampo_1,cCampo_2,cCampo_3,cClienteprospecto,iId_situaciones
			,cPuntualidad_ref1,cPuntualidad_ref2,cFlagtestigoparametricocn,cFlag_altadirecta_asupervisar,iFuntos_var_param,iFuntos_var_sic,iScore_domicilio,iNuevo_puntajefinal
			,iCampo_4,iPrepuntajealtoriesgo,cFlag_pagoini,cPorc_pagoini,iMonto_disp_pagoini,cFlag_prestamo,cCanal_origensol,cGrupo_eval,cGrupo_hit,cFlagtipomsgmotos,iMontodispmotos
			,cPorcpimotos
		FROM bdisolic: "informix".ss_nuevo_parametrico 
		WHERE num_solicitud = o_numsol
		
		--SE INSERTAN LOS VALORES EN LA TABLA DE RESPALDO
		INSERT INTO bdisolic: "informix".ss_nuevo_parametrico_respaldo (Empresa,Num_solicitud,Status_solicitud,Situacion_especial,Causa_sitesp,Puntos_parcn,Par_altoriesgo,Par_celulares,Par_prestamos,Ingreso_mensual
			,Cap_sistematica_abono,Tope_abonocoppel,Capmaxima_abono,Capreal_abono,Lineacredito_real,Lineacreditotope,Fechalineacreditoreal,Fechalineacreditotope
			,Compromisossic,Flaglineacreditoesp,Cod_ret,Limitecredito,Limitecreditopesos,Paraaltoriesgonvo,Campo_1,Campo_2,Campo_3,Clienteprospecto,Id_situaciones
			,Puntualidad_ref1,Puntualidad_ref2,Flagtestigoparametricocn,Flag_altadirecta_asupervisar,puntos_var_param,puntos_var_sic,Score_domicilio,Nuevo_puntajefinal
			,Campo_4,Prepuntajealtoriesgo,Flag_pagoini,Porc_pagoini,Monto_disp_pagoini,Flag_prestamo,Canal_origensol,Grupo_eval,Grupo_hit,Flagtipomsgmotos,Montodispmotos
			,Porcpimotos)
		VALUES (cEmpresa,cNum_solicitud,cStatus_solicitud,cSituacion_especial,iCausa_sitesp,iPuntos_parcn,iPar_altoriesgo,iPar_celulares,iPar_prestamos,iIngreso_mensual
			,iCap_sistematica_abono,iTope_abonocoppel,iCapmaxima_abono,iCapreal_abono,iLineacredito_real,iLineacreditotope,cFechalineacreditoreal,cFechalineacreditotope
			,iCompromisossic,iFlaglineacreditoesp,cCod_ret,iLimitecredito,iLimitecreditopesos,iParaaltoriesgonvo,cCampo_1,cCampo_2,cCampo_3,cClienteprospecto,iId_situaciones
			,cPuntualidad_ref1,cPuntualidad_ref2,cFlagtestigoparametricocn,cFlag_altadirecta_asupervisar,iFuntos_var_param,iFuntos_var_sic,iScore_domicilio,iNuevo_puntajefinal
			,iCampo_4,iPrepuntajealtoriesgo,cFlag_pagoini,cPorc_pagoini,iMonto_disp_pagoini,cFlag_prestamo,cCanal_origensol,cGrupo_eval,cGrupo_hit,cFlagtipomsgmotos,iMontodispmotos
			,cPorcpimotos);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '10001'; -- LA INSERCION NO SE REALIZO
			RETURN cCodRet;
		ELSE
		--SE BORRAN LAS SOLICITUDES DE LA ANTIGUA TABLA
			DELETE FROM bdisolic: "informix".ss_nuevo_parametrico  WHERE num_solicitud = o_numsol;
			RETURN cCodRet;
		END IF;
		
	END FOREACH;
	

END;
END PROCEDURE

