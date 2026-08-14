CREATE PROCEDURE "informix".sp_incrementavolumetriadebito(dFecha DATE,cTrimestre CHAR(5),iMes INTEGER)
returning
char (5),
char(300);
/*
#####################################################################################
#   Creado por: Juan Fco. Ponce Damian												#
#   Fecha: 31/12/2012																#
#   Descripcion: Genera la información para el reporte trimestral de visa,			#
#	volumetria diaria de debito														#
#####################################################################################
#   Modificado por: Juan Fco. Ponce Damian											#
#	Fecha: 06/02/2013																#
#	Descripcion: se agregaron validaciones para sumar los ajustes por transacciones #
#	forzadas																		#
#####################################################################################
#   modificado por: Juan Fco. Ponce Damian											#
#   Fecha: 22/02/2013																#
#   Modificación: Se ajusta el nombre de los atms para extraer la volumetria con la #
#   fecha correcta (el nombre trae un dia acterior a la fecha de proceso).			#
#####################################################################################
#   modificado por: Juan Fco. Ponce Damian											#
#   Fecha: 05/07/2013																#
#   Modificación: Se elimina el calculo de monto surcharge para CEI y CEN           #
#####################################################################################
#   modificado por: Juan Fco. Ponce Damian y Ricardo Resendiz						#
#   Fecha: 17/10/2013																#
#   Modificación: Se modifica volumentria de debito por integracion de cash back    #
#####################################################################################
#   Modificado por: René Aldana Hernández											#
#   Fecha: 28/04/2014																#
#   Modificación: Se agrega el fintrlo "ban_bin" bandera sobre el tipo de bin para  #
#   que solo sean seleccionados bines que proceden de VISA							#
#   ban_bin igual al parametro'VDE' 	--VISA DEBITO								#
#####################################################################################
*/
DEFINE cCodFila         CHAR(8);
DEFINE iSqlErr          INTEGER;
DEFINE cVarDataErr      CHAR(300);
DEFINE cVarDataErr1     CHAR(100);
DEFINE cVarDataErr2     CHAR(100);
DEFINE cVarDataErr3     CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cProducto        CHAR(4);
DEFINE cNombreArc		CHAR(24);

DEFINE cFecha1 			CHAR(50);
DEFINE cFecha2 			CHAR(50);
DEFINE dFechaAtmInicio 	DATETIME YEAR TO FRACTION (5);
DEFINE dFechaAtmFin 	DATETIME YEAR TO FRACTION (5);
--VVP
DEFINE iTotalDisp    DECIMAL;
DEFINE mSaldoDisp   MONEY(14,2);
DEFINE dNumDispATMprop  DECIMAL;
DEFINE mMontoDispATMproptotal MONEY(14,2);
DEFINE iTotalComprasTCDTotal DECIMAL;
DEFINE dMontoComprasTCDTotal MONEY(14,2);
DEFINE iTotalCCDTotal DECIMAL;
DEFINE dMontoCCDTotal MONEY(14,2);
--CEN
DEFINE iTotalDispATMtotal    DECIMAL;
DEFINE mSaldoDispATMtotal    MONEY(14,2);
DEFINE iTotalComprasEntTotal DECIMAL;
DEFINE dMontoComprasEntTotal MONEY(14,2);
DEFINE iTotalComprasEntTotal01 DECIMAL;
DEFINE dMontoComprasEntTotal01 MONEY(14,2);
DEFINE iTotalComprasEntTotal05 DECIMAL;
DEFINE dMontoComprasEntTotal05 MONEY(14,2);
--CEI
DEFINE iTotalDispAtmIntTotal DECIMAL;
DEFINE dMontoAtmIntTotal     MONEY(14,2);
DEFINE iTotalComprasInterTotal DECIMAL;
DEFINE dMontoComprasInterTotal MONEY(14,2);
DEFINE iTotalComprasInterTotal05 DECIMAL;
DEFINE dMontoComprasInterTotal05 MONEY(14,2);
DEFINE iTotalComprasInterTotal01 DECIMAL;
DEFINE dMontoComprasInterTotal01 MONEY(14,2);


  ON EXCEPTION SET iSqlErr
        
		LET cVarDataErr = 'ERROR NO CONTROLADO (' || iSqlErr || '). ' ;
		LET cCodret = '-1';
		
        INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_incrementavolumetriadebito',iMes,dFecha,'', 0 ,cVarDataErr);
		
		RETURN cCodret, cVarDataErr;
       
  END EXCEPTION;

--Set debug file to "volumetriavisadeb.out";
-- trace on;

LET cCodret = '00000';
LET cVarDataErr = ' ';
LET cVarDataErr1 = '';
LET cVarDataErr2 = '';
LET cVarDataErr3 = '';
LET cNombreArc = '';



LET cFecha1 = YEAR(dFecha-2) || '-' || LPAD ( MONTH(dFecha-2), 2, '0') || '-' || LPAD ( DAY (dFecha-2), 2, '0') || ' 00:00:00.0';
LET dFechaAtmInicio = CAST (cFecha1 AS DATETIME year to fraction(5));
LET cFecha2 = YEAR(dFecha) || '-' || LPAD ( MONTH(dFecha), 2, '0') || '-' || LPAD ( DAY (dFecha), 2, '0') || ' 23:59:59.0'; 
LET dFechaAtmFin = CAST (cFecha2 AS DATETIME year to fraction(5));

--VVP
LET dNumDispATMprop = 0;
LET mMontoDispATMproptotal = 0.0;
LET iTotalComprasTCDTotal = 0;
LET dMontoComprasTCDTotal = 0.0;
LET iTotalCCDTotal = 0;
LET dMontoCCDTotal = 0.0;
--CEN
LET iTotalDispAtmTotal = 0;
LET mSaldoDispATMtotal = 0;
LET iTotalComprasEntTotal = 0;
LET dMontoComprasEntTotal = 0;
LET iTotalComprasEntTotal05 = 0;
LET dMontoComprasEntTotal05 = 0;
LET iTotalComprasEntTotal01 = 0;
LET dMontoComprasEntTotal01 = 0;
--CEI
LET iTotalComprasInterTotal = 0;
LET dMontoComprasInterTotal = 0;
LET iTotalDispAtmIntTotal = 0;
LET dMontoAtmIntTotal = 0;
LET iTotalComprasInterTotal05 = 0;
LET dMontoComprasInterTotal05 = 0;
LET iTotalComprasInterTotal01 = 0;
LET dMontoComprasInterTotal01 = 0;

--**********  LLenamos Volumetria de VVP ************

	--IF iTotalDisp IS NULL OR mSaldoDisp IS NULL THEN
		LET iTotalDisp = 0;
		LET mSaldoDisp = 0;
	--END IF

	--Inserta en la base de datos
SET ISOLATION TO dirty read;
	LET cCodFila = 'VVP';

	LET cProducto = '2000';
	
	IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_volumetria_diaria WHERE num_producto = cProducto 
	AND trimestre = cTrimestre AND id_col = cCodFila AND mes = iMes AND fecha_reg = dFecha ) THEN
		
		LET cNombreArc  = 'BCPL_ATMD_'||LPAD(DAY(dFecha-1),2,'0')||LPAD(MONTH(dFecha-1),2,'0')||substr(YEAR(dFecha-1),3,2)||'.txt';
		-- ATM PROPIOS
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(consecutivo), 
		nvl(sum(case when tipo_conciliacion = 56 then (montointercard::MONEY)-((monto325::MONEY)/100) - ((montosurcharge325::MONEY)/100)
        when tipo_conciliacion in (50,51,53) then ((Monto325::MONEY)/100)-((montosurcharge325::MONEY)/100)
		end),0)as monto	
		INTO dNumDispATMprop, mMontoDispATMproptotal
		FROM bditarjeta:td_movimientos_conciliacion
		WHERE  nombrearchivo = cNombreArc AND tipo_conciliacion IN (50,51,53,56) AND ban_bin = 'VDE' AND
		secuencia_extendida IN 	(SELECT secuenciaextendida FROM intercard:movimiento WHERE 
		fechahorainauth >= dFechaAtmInicio AND fechahorainauth <= dFechaAtmFin AND prodind='01' AND codigoiso = '00'
		AND esnacional = 'V' AND trancajeropropio='V' AND transaccionorigen = '1234' AND formato <> '0420' AND codtran = '01');
		-- TCD PROPIO (ventas coppel) 
		LET cNombreArc  = 'BCPLTCD_'||LPAD(DAY(dFecha),2,'0')||LPAD(MONTH(dFecha),2,'0')||YEAR(dFecha)||'.txt';
		SET ISOLATION TO DIRTY READ;
		SELECT count(consecutivo), nvl(sum(((Monto325::MONEY)/100)),0) INTO iTotalComprasTCDTotal, dMontoComprasTCDTotal
		FROM bditarjeta:td_movimientos_conciliacion 
		WHERE nombrearchivo = cNombreArc AND  tipo_conciliacion in (1,2,3,4,5,8) AND ban_bin = 'VDE';	
		-- CCD PROPIO (servicios coppel)
		LET cNombreArc  = 'BCPLCCD_'||LPAD(DAY(dFecha),2,'0')||LPAD(MONTH(dFecha),2,'0')||YEAR(dFecha)||'.txt';
		SET ISOLATION TO DIRTY READ;
		SELECT count(consecutivo), nvl(sum(((Monto325::MONEY)/100)),0) INTO iTotalCCDTotal, dMontoCCDTotal
		FROM bditarjeta:td_movimientos_conciliacion 
		WHERE nombrearchivo = cNombreArc AND ban_bin = 'VDE';	
		
		--Inserta en la base de datos VVP
		INSERT INTO bdireports:rpt_volumetria_diaria(num_producto,trimestre,id_col,mes,fecha_reg,campo_a,campo_b,campo_c,campo_d,
		campo_e,campo_f,campo_g,campo_h,campo_i,campo_j,campo_k,campo_l,campo_m,campo_n)     
		VALUES(cProducto,cTrimestre,cCodFila,iMes,dFecha,0,0,0,0,0,0,iTotalDisp,mSaldoDisp,dNumDispATMprop,mMontoDispATMproptotal,
		iTotalComprasTCDTotal,dMontoComprasTCDTotal,iTotalCCDTotal,dMontoCCDTotal);
	ELSE                                                                                                                                                                                                                                                                                           
		LET cCodret = '00001';  
		LET cVarDataErr1 = 'ERROR AL INSERTAR :'||trim(cCodFila)|| ','||trim(cProducto)||','|| dFecha ||'.';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_incrementavolumetriadebito',iMes,dFecha,'', 0 ,cCodret||cVarDataErr1);
	END IF;
	
--**********  LLenamos Volumetria de CEN ************

	LET cCodFila = 'CEN';
	
	IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_volumetria_diaria WHERE num_producto = cProducto 
	AND trimestre = cTrimestre AND id_col = cCodFila AND mes = iMes AND fecha_reg = dFecha) THEN
		
		LET cNombreArc  = 'BCPLVND_'||LPAD(DAY(dFecha),2,'0')||LPAD(MONTH(dFecha),2,'0')||YEAR(dFecha)||'.txt';
		--- POS NACIONAL ( DESLIZADA - 90 ) + AJUSTE POR FORZADAS
		SET ISOLATION TO DIRTY READ;
		SELECT count(consecutivo), nvl(sum(((Monto325::MONEY)/100)),0) + nvl(sum(((montocashback325::MONEY)/100)),0) -- Sumar montos de como una sola transaccion 
			INTO iTotalComprasEntTotal, dMontoComprasEntTotal
				FROM bditarjeta:td_movimientos_conciliacion 
			WHERE 	nombrearchivo = cNombreArc AND 
					((tipo_conciliacion in (1,2,3,4,5,     						-- Solo compras
											36,37,38,39,40,41,42,43,44,45,46,	-- Compras POS + Cash Back
											20,21,22,23,24) AND					-- Solo llego cash back 
					metodocaptura = 90 )	or 
					(tipo_conciliacion in (	8,									-- Solo compra
											31,									-- Compra POS + Cash Back
											28) and 							-- Solo Cash Back
					metodocaptura not in (90,05,01) 
					AND numtarjeta LIKE '40%')) 
			   AND ban_bin = 'VDE';
		--- POS NACIONAL ( CHIP - 05 ) + AJUSTE POR FORZADAS
		
		SET ISOLATION TO DIRTY READ;
		SELECT count(consecutivo), nvl(sum(((Monto325::MONEY)/100)),0) + nvl(sum(((montocashback325::MONEY)/100)),0) -- Sumar montos de como una sola transaccion 
			INTO iTotalComprasEntTotal05, dMontoComprasEntTotal05
				FROM bditarjeta:td_movimientos_conciliacion
			WHERE 	nombrearchivo = cNombreArc AND
					((tipo_conciliacion in (1,2,3,4,5,     						-- Solo compras
											36,37,38,39,40,41,42,43,44,45,46,	-- Compras POS + Cash Back
											20,21,22,23,24) AND					-- Solo llego cash back 
					metodocaptura = 05 )	or 
					(tipo_conciliacion in (	8,									-- Solo compra
											31,									-- Compra POS + Cash Back
											28) and 							-- Solo Cash Back
					metodocaptura not in (90,05,01) AND 
					numtarjeta LIKE '41%' ))
			   AND ban_bin = 'VDE';					
		--- POS NACIONAL  ( DIGITADA - 01) ( 0 para debito )
		
		SET ISOLATION TO DIRTY READ;
		SELECT count(consecutivo), nvl(sum(((Monto325::MONEY)/100)),0) 
			INTO iTotalComprasEntTotal01, dMontoComprasEntTotal01
				FROM bditarjeta:td_movimientos_conciliacion 
			WHERE 	nombrearchivo = cNombreArc AND  
					tipo_conciliacion in (	1,2,3,4,5,8) AND
					metodocaptura = 01
     		    AND ban_bin = 'VDE';	
			
		--- ATM NACIONAL 
		LET cNombreArc  = 'BCPL_ATMD_'||LPAD(DAY(dFecha-1),2,'0')||LPAD(MONTH(dFecha-1),2,'0')||substr(YEAR(dFecha-1),3,2)||'.txt';
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(consecutivo), nvl(sum(case when tipo_conciliacion = 56 then (montointercard::MONEY)-((monto325::MONEY)/100) - ((montosurcharge325::MONEY)/100)
        when tipo_conciliacion in (50,51,53) then ((Monto325::MONEY)/100)-((montosurcharge325::MONEY)/100)
		end),0)as monto	
		INTO iTotalDispAtmTotal, mSaldoDispATMtotal
		FROM bditarjeta:td_movimientos_conciliacion
		WHERE  nombrearchivo = cNombreArc AND tipo_conciliacion IN (50,51,53,56) 	AND ban_bin = 'VDE' AND
		secuencia_extendida IN 	(SELECT secuenciaextendida FROM intercard:movimiento WHERE 
		fechahorainauth >= dFechaAtmInicio AND fechahorainauth <= dFechaAtmFin AND prodind='01' AND codigoiso = '00'
		AND esnacional = 'V' AND trancajeropropio='F' AND transaccionorigen = '1234' AND formato <> '0420' AND codtran = '01');

		--Inserta en la base de datos CEN
		INSERT INTO bdireports:rpt_volumetria_diaria(num_producto,trimestre,id_col,mes,fecha_reg,campo_a,campo_b,campo_c,campo_d,
		campo_e,campo_f,campo_g,campo_h,campo_i,campo_j,campo_k,campo_l,campo_m,campo_n)         
		VALUES(cProducto,cTrimestre,cCodFila,iMes,dFecha,iTotalComprasEntTotal,dMontoComprasEntTotal,iTotalComprasEntTotal05 ,dMontoComprasEntTotal05 ,iTotalComprasEntTotal01,dMontoComprasEntTotal01
		,0,0,iTotalDispAtmTotal,mSaldoDispATMtotal,0,0,0,0);
	ELSE
		LET cCodret = '00002';
		LET cVarDataErr2 = 'ERROR AL INSERTAR :'||trim(cCodFila)|| ','||trim(cProducto)||','|| dFecha ||'.';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_incrementavolumetriadebito',iMes,dFecha,'', 0 ,cCodret||cVarDataErr2);
	END IF;
	
--**********  LLenamos Volumetria de CEI ************
	LET cCodFila = 'CEI';
	
	IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_volumetria_diaria WHERE num_producto = cProducto 
	AND trimestre = cTrimestre AND id_col = cCodFila AND mes = iMes AND fecha_reg = dFecha ) THEN
		
		LET cNombreArc  = 'BCPLVID_'||LPAD(DAY(dFecha),2,'0')||LPAD(MONTH(dFecha),2,'0')||YEAR(dFecha)||'.txt';
		--- POS NACIONAL ( DESLIZADA - 90 ) + AJUSTE POR FORZADAS
		SET ISOLATION TO DIRTY READ;
		SELECT count(consecutivo), nvl(sum(((Monto325::MONEY)/100)),0) INTO iTotalComprasInterTotal, dMontoComprasInterTotal
		FROM bditarjeta:td_movimientos_conciliacion 
		WHERE nombrearchivo = cNombreArc AND ( (tipo_conciliacion in (1,2,3,4,5) AND metodocaptura = 90 )
		or (tipo_conciliacion = 8 and  metodocaptura not in (90,05,01) AND numtarjeta LIKE '40%')) 
		AND ban_bin = 'VDE'  ;
		--- POS NACIONAL ( CHIP - 05 ) + AJUSTE POR FORZADAS
		SET ISOLATION TO DIRTY READ;
		SELECT count(consecutivo), nvl(sum(((Monto325::MONEY)/100)),0) INTO iTotalComprasInterTotal05, dMontoComprasInterTotal05
		FROM bditarjeta:td_movimientos_conciliacion
		WHERE nombrearchivo = cNombreArc AND ( (tipo_conciliacion in (1,2,3,4,5) AND metodocaptura = 05 )
		or (tipo_conciliacion = 8 and  metodocaptura not in (90,05,01) AND numtarjeta LIKE '41%' ))
		AND ban_bin = 'VDE' 		;
		--- POS INTERNACIONAL ( DIGITADA - 01 ) POR INTERNET   ( 0 para debito )
		SET ISOLATION TO DIRTY READ;
		SELECT count(consecutivo), nvl(sum(((Monto325::MONEY)/100)),0) INTO iTotalComprasInterTotal01, dMontoComprasInterTotal01
		FROM bditarjeta:td_movimientos_conciliacion 
		WHERE nombrearchivo = cNombreArc  AND  tipo_conciliacion in (1,2,3,4,5,8) AND metodocaptura = 01 AND ban_bin = 'VDE' ;
		
		--- ATM INTERNACIONAL
		LET cNombreArc  = 'BCPL_ATMD_'||LPAD(DAY(dFecha-1),2,'0')||LPAD(MONTH(dFecha-1),2,'0')||substr(YEAR(dFecha-1),3,2)||'.txt';
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(consecutivo), nvl(sum(case when tipo_conciliacion = 56 then (montointercard::MONEY)-((monto325::MONEY)/100) - ((montosurcharge325::MONEY)/100)
        when tipo_conciliacion in (50,51,53) then ((Monto325::MONEY)/100)-((montosurcharge325::MONEY)/100)
		end),0)as monto	
		INTO iTotalDispAtmIntTotal, dMontoAtmIntTotal
		FROM bditarjeta:td_movimientos_conciliacion
		WHERE  nombrearchivo = cNombreArc AND tipo_conciliacion IN (50,51,53,56) AND ban_bin = 'VDE' AND
		secuencia_extendida IN 	(SELECT secuenciaextendida FROM intercard:movimiento WHERE 
		fechahorainauth >= dFechaAtmInicio AND fechahorainauth <= dFechaAtmFin AND prodind='01' AND codigoiso = '00'
		AND esnacional = 'F' AND trancajeropropio='F' AND transaccionorigen = '1234' AND formato <> '0420' AND codtran = '01');
			
		--Se inserta informacion en la base de datos.
		INSERT INTO bdireports:rpt_volumetria_diaria(num_producto,trimestre,id_col,mes,fecha_reg,campo_a,campo_b,campo_c,campo_d,
		campo_e,campo_f,campo_g,campo_h,campo_i,campo_j,campo_k,campo_l,campo_m,campo_n)     
		VALUES(cProducto,cTrimestre,cCodFila,iMes,dFecha,iTotalComprasInterTotal,dMontoComprasInterTotal,iTotalComprasInterTotal05 ,dMontoComprasInterTotal05 ,iTotalComprasInterTotal01,dMontoComprasInterTotal01,
		0,0,iTotalDispAtmIntTotal,dMontoAtmIntTotal,0,0,0,0);
	ELSE
		LET cCodret = '00003';
		LET cVarDataErr3 = 'ERROR AL INSERTAR :'||trim(cCodFila)|| ','||trim(cProducto)||','|| dFecha ||'.';
		INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,ultima_actualizacion,estatus_actualizacion,dias_pendientes,ultimo_error)  
		VALUES ( 'sp_incrementavolumetriadebito',iMes,dFecha,'', 0 ,cCodret||cVarDataErr3);
	END IF;

LET cVarDataErr = trim(cVarDataErr1)||trim(cVarDataErr2)||trim(cVarDataErr3);
	
RETURN cCodret,cVarDataErr;

END PROCEDURE;