CREATE PROCEDURE "informix".sp_consulta_bpioperaciones(p_tipo INTEGER,p_idoperacion VARCHAR(5),p_dtfecha_ini DATE, p_dtfecha_final DATE,p_cta_origen varchar(20))
RETURNING 
VARCHAR(6)                      AS CodRetorno
,VARCHAR(80)                    AS Mensaje
,VARCHAR(30) 					AS descrip
,DATE  							AS fecha_aplicacion
,varchar(20) 					AS cta_origen
,varchar(20) 					AS cta_destino
,MONEY(14,2) 					AS Monto
,varchar(25) 					AS folio_suc
,DATETIME YEAR TO FRACTION		AS fecha_operacion
,varchar(25) 					AS ref_pago;

-- Definicion de variables para el control de  errores
DEFINE  SQL_ERR                INTEGER;
DEFINE  ISAM_ERR               INTEGER;
DEFINE  ERROR_INFO             VARCHAR(80);
DEFINE  P_COD_RET              VARCHAR(6);
DEFINE  P_MENSAJE              VARCHAR(80);

DEFINE  v_vDescrip 		       VARCHAR(30); 					
DEFINE  v_dFecha_aplicacion    DATE;  							
DEFINE  v_dFecha_operacion     DATETIME YEAR TO FRACTION ;  	
DEFINE  v_vCta_origen          varchar(20); 
DEFINE  v_vCta_destino         varchar(20);
DEFINE  v_mMonto               MONEY(14,2);
DEFINE  v_vFolio_suc           varchar(25);
DEFINE  v_vRef_pago            varchar(25);

-- Inicializacion de variables para el control de  errores
LET P_COD_RET = '00000';
LET P_MENSAJE = 'PROCESO EXITOSO';

-- Inicializacion de variables
LET v_vDescrip 				= "";
LET v_dFecha_aplicacion		= "01-01-1900";
LET v_vCta_origen 			= "";
LET v_vCta_destino 			= "";
LET v_mMonto 				= 0;
LET v_vFolio_suc 			= "";

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;	  	
		RETURN  P_COD_RET, P_MENSAJE,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	IF p_tipo == 1 THEN --Filtrado por id de la OperaciÃ³n
		FOREACH		 	
			SELECT  desc_oper,fecha_aplic,cuenta_origen,destino,monto_oper,cgenerico1,fecha_oper,cgenerico2
			INTO v_vDescrip,v_dFecha_aplicacion,v_vCta_origen,v_vCta_destino,v_mMonto,v_vFolio_suc,v_dFecha_operacion,v_vRef_pago
			FROM bdibpi:bpi_bitacora a, bdinteg:si_bpioperaciones b
			WHERE id_operacion = p_idoperacion AND  date(fecha_oper) BETWEEN p_dtfecha_ini AND  p_dtfecha_final
			AND a.id_operacion = b.id_oper
			UNION
			SELECT  desc_oper,fecha_aplic,cuenta_origen,destino,monto_oper,cgenerico1,fecha_oper,cgenerico2
			--INTO v_vDescrip,v_dFecha_aplicacion,v_vCta_origen,v_vCta_destino,v_mMonto,v_vFolio_suc,v_dFecha_operacion,v_vRef_pago
			FROM bdibpi:bpi_bitacora_historial a, bdinteg:si_bpioperaciones b
			WHERE id_operacion = p_idoperacion AND  date(fecha_oper) BETWEEN p_dtfecha_ini AND  p_dtfecha_final
			AND a.id_operacion = b.id_oper
			
				
			RETURN P_COD_RET,P_MENSAJE,v_vDescrip,v_dFecha_aplicacion,v_vCta_origen,v_vCta_destino,v_mMonto,v_vFolio_suc,v_dFecha_operacion,v_vRef_pago WITH RESUME;

		END FOREACH;
	ELIF p_tipo == 2 THEN --Filtrado por la Cuenta
		FOREACH	
			SELECT  desc_oper,fecha_aplic,cuenta_origen,destino,monto_oper,cgenerico1,fecha_oper,cgenerico2 
			INTO v_vDescrip,v_dFecha_aplicacion,v_vCta_origen,v_vCta_destino,v_mMonto,v_vFolio_suc,v_dFecha_operacion,v_vRef_pago
			FROM bdibpi:bpi_bitacora a, bdinteg:si_bpioperaciones b
			WHERE  date(fecha_oper) BETWEEN p_dtfecha_ini AND  p_dtfecha_final
			AND a.cuenta_origen  = p_cta_origen
			AND  a.id_operacion  = b.id_oper and b.mostrar = 't'
			UNION
			SELECT  desc_oper,fecha_aplic,cuenta_origen,destino,monto_oper,cgenerico1,fecha_oper,cgenerico2 
			--INTO v_vDescrip,v_dFecha_aplicacion,v_vCta_origen,v_vCta_destino,v_mMonto,v_vFolio_suc,v_dFecha_operacion,v_vRef_pago
			FROM bdibpi:bpi_bitacora_historial a, bdinteg:si_bpioperaciones b
			WHERE  date(fecha_oper) BETWEEN p_dtfecha_ini AND  p_dtfecha_final
			AND a.cuenta_origen  = p_cta_origen
			AND  a.id_operacion  = b.id_oper and b.mostrar = 't'
			
	   	RETURN P_COD_RET,P_MENSAJE,v_vDescrip,v_dFecha_aplicacion,v_vCta_origen,v_vCta_destino,v_mMonto,v_vFolio_suc,v_dFecha_operacion,v_vRef_pago WITH RESUME;

		END FOREACH;
	ELIF p_tipo == 3 THEN --Filtrado por fecha en todas las operaciones
		FOREACH	
			SELECT  desc_oper,fecha_aplic,cuenta_origen,destino,monto_oper,cgenerico1,fecha_oper,cgenerico2 
			INTO v_vDescrip,v_dFecha_aplicacion,v_vCta_origen,v_vCta_destino,v_mMonto,v_vFolio_suc,v_dFecha_operacion,v_vRef_pago
			FROM bdibpi:bpi_bitacora a, bdinteg:si_bpioperaciones b
			WHERE  date(fecha_oper) BETWEEN p_dtfecha_ini AND  p_dtfecha_final			
			AND   a.id_operacion  = b.id_oper and b.mostrar = 't'
			UNION
			SELECT  desc_oper,fecha_aplic,cuenta_origen,destino,monto_oper,cgenerico1,fecha_oper,cgenerico2 
			--INTO v_vDescrip,v_dFecha_aplicacion,v_vCta_origen,v_vCta_destino,v_mMonto,v_vFolio_suc,v_dFecha_operacion,v_vRef_pago
			FROM bdibpi:bpi_bitacora_historial a, bdinteg:si_bpioperaciones b
			WHERE  date(fecha_oper) BETWEEN p_dtfecha_ini AND  p_dtfecha_final			
			AND   a.id_operacion  = b.id_oper and b.mostrar = 't'
	   	
		RETURN P_COD_RET,P_MENSAJE,v_vDescrip,v_dFecha_aplicacion,v_vCta_origen,v_vCta_destino,v_mMonto,v_vFolio_suc,v_dFecha_operacion,v_vRef_pago WITH RESUME;

		END FOREACH;
    END IF;

	
END;
--##############################################################################
--## Procedimiento   : sp_consulta_bpioperaciones
--## Base de datos   : integ
--## Version         : 1.0
--## Creado por      : Manuel Osuna Valencia 
--## Fecha creacion  : 08 Sept 2009
--##Descripcion :  Consulta las Operaciones Realizadas por la Banca de Internet
--##############################################################################
--##Fecha ModificaciÃ³n: 05 Octubre 2015
--##Descripcion :  Se actualiza para consulta ambas tablas de bitacora de bdinteg y bdibpi.
--##############################################################################
--##Fecha ModificaciÃ³n: 12 Noviembre 2018
--##Descripcion :  Se actualiza para consulta ambas tablas de bitacora de bdibpi.
--##############################################################################
END PROCEDURE;