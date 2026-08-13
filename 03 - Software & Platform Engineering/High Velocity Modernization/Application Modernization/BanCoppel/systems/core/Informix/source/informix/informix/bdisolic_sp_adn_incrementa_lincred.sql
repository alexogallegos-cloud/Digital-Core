CREATE PROCEDURE "informix".sp_adn_incrementa_lincred(pEmpresa CHAR(3))
RETURNING CHAR(6)        AS codigo_retorno;
          --VARCHAR(150,1) AS mensaje_retorno;
		  
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(150,1);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      VARCHAR(150,1);
DEFINE cCodRetAux       CHAR(6); 
DEFINE cMensajeRetAux   VARCHAR(150,1);

DEFINE cEmpresa         CHAR(3);
DEFINE vNumCred         VARCHAR(20,1); 
DEFINE vNumCte          VARCHAR(20,1);
DEFINE cBegin           CHAR(1);
DEFINE vFolioSuc 		VARCHAR(20,1);
DEFINE dMontoOtorgado   DECIMAL(18,2);
DEFINE dMontoDif        DECIMAL(18,2);
DEFINE dtFechaHoy       DATE;
DEFINE dtfecha_1        DATE;
DEFINE dtfecha_2        DATE;
DEFINE dtfecha_3        DATE;
DEFINE dtfecha_4        DATE;
DEFINE dtfecha_5        DATE;
DEFINE dtfecha_6        DATE;
DEFINE dtfecha_1_ini	DATE;
DEFINE dtfecha_2_ini	DATE;
DEFINE dtfecha_3_ini	DATE;
DEFINE dtfecha_4_ini	DATE;
DEFINE dtfecha_5_ini	DATE;
DEFINE dtfecha_6_ini	DATE;
DEFINE dtfecha_1_fin	DATE;
DEFINE dtfecha_2_fin	DATE;
DEFINE dtfecha_3_fin	DATE;
DEFINE dtfecha_4_fin	DATE;
DEFINE dtfecha_5_fin	DATE;
DEFINE dtfecha_6_fin	DATE;
DEFINE dtfechaToday		DATE;
DEFINE monto_fecha1		DECIMAL(18,2);
DEFINE monto_fecha2		DECIMAL(18,2);
DEFINE monto_fecha3		DECIMAL(18,2);
DEFINE monto_fecha4		DECIMAL(18,2);
DEFINE monto_fecha5		DECIMAL(18,2);
DEFINE monto_fecha6		DECIMAL(18,2);
DEFINE sdo_prom			DECIMAL(18,2);
DEFINE dLineaNva		DECIMAL(18,2);
DEFINE dLinea_Ant		DECIMAL(18,2);
DEFINE dLineaDif		DECIMAL(18,2);
DEFINE incLinea2		DECIMAL(18,2);
DEFINE cSucursal        CHAR(4);
DEFINE cDivisa          CHAR(2);
DEFINE vCtaNomina       VARCHAR(20,1);
DEFINE dPorcentaje		DECIMAL(18,2);
DEFINE dMontoMin		DECIMAL(18,2);
DEFINE dMontoMax		DECIMAL(18,2);
DEFINE dtfecha_apertura DATE;
DEFINE iFrecuenciaPago	INTEGER;
DEFINE dtFecha6meses	DATE;
DEFINE dtfecha_inc		DATE;
DEFINE flag_aniobis	INTEGER;


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "000000";
LET cMensajeRet     = "PROCESO EXITOSO";
LET cCodRetAux      = "";
LET cMensajeRetAux  = "";
		  
LET cEmpresa        = "";
LET vNumCred        = "";
LET vNumCte         = "";
LET cBegin          = "F";
LET vFolioSuc       = "Act LineaCredito";
LET dMontoOtorgado  = 0;
LET dMontoDif       = 0;
LET dtFechaHoy      = DATE(1);
LET dtfecha_1      = DATE(1);
LET dtfecha_2      = DATE(1);
LET dtfecha_3      = DATE(1);
LET dtfecha_4      = DATE(1);
LET dtfecha_5      = DATE(1);
LET dtfecha_6      = DATE(1);
LET dtfecha_1_ini	= DATE(1);
LET dtfecha_2_ini	= DATE(1);
LET dtfecha_3_ini	= DATE(1);
LET dtfecha_4_ini	= DATE(1);
LET dtfecha_5_ini	= DATE(1);
LET dtfecha_6_ini	= DATE(1);
LET dtfecha_1_fin	= DATE(1);
LET dtfecha_2_fin	= DATE(1);
LET dtfecha_3_fin	= DATE(1);
LET dtfecha_4_fin	= DATE(1);
LET dtfecha_5_fin	= DATE(1);
LET dtfecha_6_fin	= DATE(1);
LET dtfechaToday	= DATE(1);
LET monto_fecha1	=0;
LET monto_fecha2	=0;
LET monto_fecha3	=0;
LET monto_fecha4	=0;
LET monto_fecha5	=0;
LET monto_fecha6	=0;
LET sdo_prom		=0;
LET dLineaNva       =0;
LET dLinea_Ant		=0;
LET dLineaDif		=0;
LET incLinea2		=0;
LET cSucursal       = "";
LET cDivisa         = "";
LET vCtaNomina      = "";
LET dPorcentaje	=0;
LET dMontoMin=0;
LET dMontoMax=0;
LET iFrecuenciaPago = 0;
LET dtfecha_apertura = DATE(1);
LET dtFecha6meses =DATE(1);
LET dtfecha_inc =DATE(1);
LET flag_aniobis=0;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN

      IF cBegin= "S" THEN
        ROLLBACK WORK;
      END IF;
   
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet; --, cMensajeRet;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
---SET PDQPRIORITY 5; HMD-INCIDENCIA-20220224

 --SET DEBUG FILE TO '/RESPALDOSNEW/sp_incrementa_lincred_adn.out';
-- TRACE ON;
		  
 SELECT empresa
   INTO cEmpresa     
   FROM bdinteg:si_empresas 
  WHERE empresa= pEmpresa;
  
  IF TRIM(NVL(cEmpresa,'')) = '' THEN
	  LET cCodRet = '000001';
	  LET cMensajeRet = 'El parÃ¡metro de la empresa no es valido';
	  RETURN cCodRet; --, cMensajeRet;
  END IF;
  
  SELECT valor
	INTO dPorcentaje
	FROM bdicred:"informix".sd_param
	WHERE cod_param ='168';
		
	SELECT monto_min_cred, monto_max_cred 
	INTO dMontoMin, dMontoMax
	FROM bdicred:sd_definicion 
	WHERE num_producto ='7800';
	
	/*SELECT frecuencia_pgo 
	INTO iFrecuenciaPago
	FROM "informix".ss_adn_solicitudcuenta
	WHERE  numcte = pNumcte			
	AND cuenta_nomina = pCuenta;
	
	IF iFrecuenciaPago =1 THEN --se modifica el monto minimo de acuerdo a la frecuencia de pago del cliente 
		--linea minima Mensual
		SELECT valor 
		INTO dMontoMin
		FROM "informix".ss_param
		WHERE empresa = '001'
		AND secuencia = 386;
		
	ELSE
		--linea minima quincenal
		SELECT valor 
		INTO dMontoMin
		FROM "informix".ss_param
		WHERE empresa = '001'
		AND secuencia = 387;
	END IF*/
	
  
SELECT fecha_hoy --, MDY(month(fecha_hoy),day(fecha_hoy), year(fecha_hoy)) - 1 units month
  INTO dtFechaHoy --, dtfecha_1
  FROM bdicred:"informix".sd_fechas
 WHERE empresa = pEmpresa;

 LET dtfecha_1=MDY(month(dtFechaHoy),day(dtFechaHoy), year(dtFechaHoy)) - 1 units month;
 
--LET dtFechaHoy = mdy('07','10','2020'); ---SOLO PRUEBAS
--LET dtfecha_1 = mdy('06','10','2020');	---SOLO PRUEBAS

--Valida Anio Bisiesto
IF mod(year(dtFechaHoy),4) = 0 AND ((mod(year(dtFechaHoy),4)) = 0 OR (mod(year(dtFechaHoy),4) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;

 
	
	IF MONTH(dtfecha_1)='04' or month(dtfecha_1)='11'  THEN 
		LET dtfecha_1=MDY(month(dtfecha_1),day(dtfecha_1), year(dtfecha_1)) - 1 units month;
		LET dtfecha_2= MDY(month(dtfecha_1),day(dtfecha_1), year(dtfecha_1)) - 1 units month;
	ELIF MONTH(dtfecha_1)='05' or month(dtfecha_1)='12'  THEN 
		LET dtfecha_1= MDY(month(dtfecha_1),day(dtfecha_1), year(dtfecha_1)) - 2 units month;
		LET dtfecha_2= MDY(month(dtfecha_1),day(dtfecha_1), year(dtfecha_1)) - 1 units month;
	ELSE
		LET dtfecha_2= MDY(month(dtfecha_1),day(dtfecha_1), year(dtfecha_1)) - 1 units month;
	END IF;
	
	IF MONTH(dtfecha_1) IN('01','03','05','07','08','10','12') THEN
		LET dtfecha_1_fin=MDY(month(dtfecha_1),'31', year(dtfecha_1));
	ELIF MONTH(dtfecha_1) IN('04','06','09','11') THEN		
		LET dtfecha_1_fin=MDY(month(dtfecha_1),'30', year(dtfecha_1));
	ELSE 
		IF flag_aniobis=1 THEN
			LET dtfecha_1_fin=MDY(month(dtfecha_1),'29', year(dtfecha_1));
		ELSE 
			LET dtfecha_1_fin=MDY(month(dtfecha_1),'28', year(dtfecha_1));
		END IF;
	END IF;
		
	IF MONTH(dtfecha_2)='04' or month(dtfecha_2)='11'  THEN 
		LET dtfecha_2=MDY(month(dtfecha_2),day(dtfecha_2), year(dtfecha_2)) - 1 units month;
		LET dtfecha_3= MDY(month(dtfecha_2),day(dtfecha_2), year(dtfecha_2)) - 1 units month;
	ELIF MONTH(dtfecha_2)='05' or month(dtfecha_2)='12'  THEN 
		LET dtfecha_2= MDY(month(dtfecha_2),day(dtfecha_2), year(dtfecha_2)) - 2 units month;
		LET dtfecha_3= MDY(month(dtfecha_2),day(dtfecha_2), year(dtfecha_2)) - 1 units month;
	ELSE
		LET dtfecha_3= MDY(month(dtfecha_2),day(dtfecha_2), year(dtfecha_2)) - 1 units month;
	END IF;
	
	IF MONTH(dtfecha_2) IN('01','03','05','07','08','10','12') THEN
		LET dtfecha_2_fin=MDY(month(dtfecha_2),'31', year(dtfecha_2));
	ELIF MONTH(dtfecha_2) IN('04','06','09','11') THEN		
		LET dtfecha_2_fin=MDY(month(dtfecha_2),'30', year(dtfecha_2));
	ELSE 
		IF flag_aniobis=1 THEN
			LET dtfecha_2_fin=MDY(month(dtfecha_2),'29', year(dtfecha_2));
		ELSE 
			LET dtfecha_2_fin=MDY(month(dtfecha_2),'28', year(dtfecha_2));

		END IF;

	END IF;
	
	IF MONTH(dtfecha_3)='04' or month(dtfecha_3)='11'  THEN 
		LET dtfecha_3=MDY(month(dtfecha_3),day(dtfecha_3), year(dtfecha_3)) - 1 units month;
		LET dtfecha_4= MDY(month(dtfecha_3),day(dtfecha_3), year(dtfecha_3)) - 1 units month;
	ELIF MONTH(dtfecha_3)='05' or month(dtfecha_3)='12'  THEN 
		LET dtfecha_3= MDY(month(dtfecha_3),day(dtfecha_3), year(dtfecha_3)) - 2 units month;
		LET dtfecha_4= MDY(month(dtfecha_3),day(dtfecha_3), year(dtfecha_3)) - 1 units month;
	ELSE
		LET dtfecha_4= MDY(month(dtfecha_3),day(dtfecha_3), year(dtfecha_3)) - 1 units month;
	END IF;
	
	IF MONTH(dtfecha_3) IN('01','03','05','07','08','10','12') THEN
		LET dtfecha_3_fin=MDY(month(dtfecha_3),'31', year(dtfecha_3));
	ELIF MONTH(dtfecha_3) IN('04','06','09','11') THEN		
		LET dtfecha_3_fin=MDY(month(dtfecha_3),'30', year(dtfecha_3));
	ELSE 
		IF flag_aniobis=1 THEN
			LET dtfecha_3_fin=MDY(month(dtfecha_3),'29', year(dtfecha_3));
		ELSE 
			LET dtfecha_3_fin=MDY(month(dtfecha_3),'28', year(dtfecha_3));
		END IF;

		
	END IF;
	
	IF MONTH(dtfecha_4)='04' or month(dtfecha_4)='11'  THEN 
		LET dtfecha_4=MDY(month(dtfecha_4),day(dtfecha_4), year(dtfecha_4)) - 1 units month;
		LET dtfecha_5= MDY(month(dtfecha_4),day(dtfecha_4), year(dtfecha_4)) - 1 units month;
	ELIF MONTH(dtfecha_4)='05' or month(dtfecha_4)='12'  THEN 
		LET dtfecha_4= MDY(month(dtfecha_4),day(dtfecha_4), year(dtfecha_4)) - 2 units month;
		LET dtfecha_5= MDY(month(dtfecha_4),day(dtfecha_4), year(dtfecha_4)) - 1 units month;
	ELSE
		LET dtfecha_5= MDY(month(dtfecha_4),day(dtfecha_4), year(dtfecha_4)) - 1 units month;
	END IF;
	
	IF MONTH(dtfecha_4) IN('01','03','05','07','08','10','12') THEN
		LET dtfecha_4_fin=MDY(month(dtfecha_4),'31', year(dtfecha_4));
	ELIF MONTH(dtfecha_4) IN('04','06','09','11') THEN		
		LET dtfecha_4_fin=MDY(month(dtfecha_4),'30', year(dtfecha_4));
	ELSE 
		IF flag_aniobis=1 THEN
			LET dtfecha_4_fin=MDY(month(dtfecha_4),'29', year(dtfecha_4));
		ELSE 
			LET dtfecha_4_fin=MDY(month(dtfecha_4),'28', year(dtfecha_4));
		END IF;
		
	END IF;
	
	IF MONTH(dtfecha_5)='04' or month(dtfecha_5)='11'  THEN 
		LET dtfecha_5=MDY(month(dtfecha_5),day(dtfecha_5), year(dtfecha_5)) - 1 units month;
		LET dtfecha_6= MDY(month(dtfecha_5),day(dtfecha_5), year(dtfecha_5)) - 1 units month;
	ELIF MONTH(dtfecha_5)='05' or month(dtfecha_5)='12'  THEN 
		LET dtfecha_5= MDY(month(dtfecha_5),day(dtfecha_5), year(dtfecha_5)) - 2 units month;
		LET dtfecha_6= MDY(month(dtfecha_5),day(dtfecha_5), year(dtfecha_5)) - 1 units month;
	ELSE
		LET dtfecha_6= MDY(month(dtfecha_5),day(dtfecha_5), year(dtfecha_5)) - 1 units month;
	END IF;
	
	IF MONTH(dtfecha_5) IN('01','03','05','07','08','10','12') THEN
		LET dtfecha_5_fin=MDY(month(dtfecha_5),'31', year(dtfecha_5));
	ELIF MONTH(dtfecha_5) IN('04','06','09','11') THEN		
		LET dtfecha_5_fin=MDY(month(dtfecha_5),'30', year(dtfecha_5));
	ELSE 
		IF flag_aniobis=1 THEN
			LET dtfecha_5_fin=MDY(month(dtfecha_5),'29', year(dtfecha_5));
		ELSE 
			LET dtfecha_5_fin=MDY(month(dtfecha_5),'28', year(dtfecha_5));
		END IF;
		
	END IF;
	
	IF MONTH(dtfecha_6)='04' or month(dtfecha_6)='11'  THEN 
		LET dtfecha_6=MDY(month(dtfecha_6),day(dtfecha_6), year(dtfecha_6)) - 1 units month;
	ELIF MONTH(dtfecha_6)='05' or month(dtfecha_6)='12'  THEN 
		LET dtfecha_6= MDY(month(dtfecha_6),day(dtfecha_6), year(dtfecha_6)) - 2 units month;
	END IF;
	
	IF MONTH(dtfecha_6) IN('01','03','05','07','08','10','12') THEN
		LET dtfecha_6_fin=MDY(month(dtfecha_6),'31', year(dtfecha_6));
	ELIF MONTH(dtfecha_6) IN('04','06','09','11') THEN		
		LET dtfecha_6_fin=MDY(month(dtfecha_6),'30', year(dtfecha_6));
	ELSE 
		IF flag_aniobis=1 THEN
			LET dtfecha_6_fin=MDY(month(dtfecha_6),'29', year(dtfecha_6));
		ELSE 
			LET dtfecha_6_fin=MDY(month(dtfecha_6),'28', year(dtfecha_6));
		END IF;

		
	END IF;
	
	LET dtfecha_1_ini=MDY(month(dtfecha_1),'01', year(dtfecha_1));
	LET dtfecha_2_ini=MDY(month(dtfecha_2),'01', year(dtfecha_2));
	LET dtfecha_3_ini=MDY(month(dtfecha_3),'01', year(dtfecha_3));
	LET dtfecha_4_ini=MDY(month(dtfecha_4),'01', year(dtfecha_4));
	LET dtfecha_5_ini=MDY(month(dtfecha_5),'01', year(dtfecha_5));
	LET dtfecha_6_ini=MDY(month(dtfecha_6),'01', year(dtfecha_6));
	LET dtfechaToday=(mdy(month(dtFechaHoy),day(dtFechaHoy),year(dtFechaHoy)) - 12 units month);
	LET dtFecha6meses=(mdy(month(dtFechaHoy),day(dtFechaHoy),year(dtFechaHoy)) - 6 units month);
	--IFRS Se contempla nuevo capital status de vencido 6 y considera el nuevo estatus de crÃ©dito por etapa vigente
	SELECT a.num_credito, a.numcte, a.sucursal, a.divisa, b.monto_otorgado, c.cuenta_nomina,a.fecha_apertura --,(mdy(month(a.fecha_apertura),day(a.fecha_apertura),year(a.fecha_apertura)) + 12 units month) as fecha
	 FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_maesdos b, bdisolic:ss_adn_solicitudcuenta c
	 WHERE a.num_credito = b.num_credito
	    AND a.empresa = b.empresa
	    AND a.num_producto = '7800'
		AND a.fecha_apertura <= dtfechaToday
		AND a.status_cred in ('AA','E1')
		AND (b.monto_vencido + b.mto_venc_trasp) = 0
        AND c.num_solicitud = b.num_credito
        AND c.numcte  = a.numcte		
	INTO temp paso_incrementoadn WITH NO LOG;  --79473
 
	CREATE INDEX inx_paso_incrementoadn ON paso_incrementoadn(num_credito,numcte,cuenta_nomina);
	UPDATE STATISTICS MEDIUM FOR TABLE paso_incrementoadn;

	IF (SELECT COUNT(*) FROM "informix".ss_adn_bitacora_validacion WHERE fecha_actualizacion = dtFechaHoy)>0 THEN
		DELETE FROM "informix".ss_adn_bitacora_validacion WHERE fecha_actualizacion >= dtFecha6meses;
	ELSE
		TRUNCATE TABLE "informix".ss_adn_bitacora_validacion;
	END IF;

	FOREACH WITH HOLD
	
		SELECT num_credito, numcte, sucursal, divisa, monto_otorgado, cuenta_nomina, fecha_apertura
		INTO vNumCred, vNumCte, cSucursal, cDivisa, dMontoOtorgado, vCtaNomina,dtfecha_apertura
		FROM paso_incrementoadn
		
		IF (SELECT COUNT(*) FROM "informix".ss_adn_bitacora_lincred
		WHERE num_solicitud = vNumCred AND num_cliente = vNumCte AND cuenta_nomina = vCtaNomina)>0 THEN 
			
			SELECT max(fecha_actualizacion) into dtfecha_inc FROM "informix".ss_adn_bitacora_lincred
			WHERE num_solicitud = vNumCred AND num_cliente = vNumCte AND cuenta_nomina = vCtaNomina;
			
			IF dtfecha_inc>=dtFecha6meses THEN
				CONTINUE FOREACH;
			END IF
		END IF;
		
		BEGIN WORK;
		LET cBegin = "S";
		
		select sum(monto_tot) INTO monto_fecha1 
		FROM bdicheq:"informix".sc_movdia  mov2
		INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
		WHERE CUENTA=vCtaNomina
        AND fech_alt BETWEEN dtfecha_1_ini and dtfecha_1_fin 
		AND cancelad <> 'S'
		AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		
		IF nvl(monto_fecha1,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha1 
			FROM bdicheq:"informix".sc_movhis  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_1_ini and dtfecha_1_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		IF nvl(monto_fecha1,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha1 
			FROM bdicheq:"informix".sc_movhis_old  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_1_ini and dtfecha_1_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		
		select sum(monto_tot) INTO monto_fecha2 
		FROM bdicheq:"informix".sc_movHIS  mov2
		INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
		WHERE CUENTA=vCtaNomina
        AND fech_alt BETWEEN dtfecha_2_ini and dtfecha_2_fin 
		AND cancelad <> 'S'
		AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		
		IF nvl(monto_fecha2,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha2 
			FROM bdicheq:"informix".sc_movhis  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_2_ini and dtfecha_2_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		IF nvl(monto_fecha2,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha2 
			FROM bdicheq:"informix".sc_movhis_old  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_2_ini and dtfecha_2_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		select sum(monto_tot) INTO monto_fecha3 
		FROM bdicheq:"informix".sc_movHIS  mov2
		INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
		WHERE CUENTA=vCtaNomina
        AND fech_alt BETWEEN dtfecha_3_ini and dtfecha_3_fin 
		AND cancelad <> 'S'
		AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		
		IF nvl(monto_fecha3,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha3 
			FROM bdicheq:"informix".sc_movhis  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_3_ini and dtfecha_3_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		IF nvl(monto_fecha3,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha3 
			FROM bdicheq:"informix".sc_movhis_old  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_3_ini and dtfecha_3_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		select sum(monto_tot) INTO monto_fecha4 
		FROM bdicheq:"informix".sc_movHIS  mov2
		INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
		WHERE CUENTA=vCtaNomina
        AND fech_alt BETWEEN dtfecha_4_ini and dtfecha_4_fin 
		AND cancelad <> 'S'
		AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		
		IF nvl(monto_fecha4,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha4 
			FROM bdicheq:"informix".sc_movhis  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_4_ini and dtfecha_4_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		IF nvl(monto_fecha4,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha4 
			FROM bdicheq:"informix".sc_movhis_old  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_4_ini and dtfecha_4_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		select sum(monto_tot) INTO monto_fecha5 
		FROM bdicheq:"informix".sc_movHIS  mov2
		INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
		WHERE CUENTA=vCtaNomina
        AND fech_alt BETWEEN dtfecha_5_ini and dtfecha_5_fin 
		AND cancelad <> 'S'
		AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		
		IF nvl(monto_fecha5,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha5 
			FROM bdicheq:"informix".sc_movhis  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_5_ini and dtfecha_5_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		IF nvl(monto_fecha5,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha5 
			FROM bdicheq:"informix".sc_movhis_old  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_5_ini and dtfecha_5_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		select sum(monto_tot) INTO monto_fecha6 
		FROM bdicheq:"informix".sc_movHIS  mov2
		INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
		WHERE CUENTA=vCtaNomina
        AND fech_alt BETWEEN dtfecha_6_ini and dtfecha_6_fin 
		AND cancelad <> 'S'
		AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		
		IF nvl(monto_fecha6,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha6 
			FROM bdicheq:"informix".sc_movhis  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_6_ini and dtfecha_6_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		IF nvl(monto_fecha6,0)=0 THEN
			select sum(monto_tot) INTO monto_fecha6 
			FROM bdicheq:"informix".sc_movhis_old  mov2
			INNER JOIN bdicred:"informix".sd_transvalprod  tran ON tran.transacc = mov2.transacc 
			WHERE CUENTA=vCtaNomina
			AND fech_alt BETWEEN dtfecha_6_ini and dtfecha_6_fin 
			AND cancelad <> 'S'
			AND ((tran.activo = 2  and tran.transacc <> '0273') OR ( tran.transacc = '0273' AND mov2.referencia like('%NNNN%')));
		END IF;
		
		LET sdo_prom = (nvl(monto_fecha1,0) + nvl(monto_fecha2,0) + nvl(monto_fecha3,0) + nvl(monto_fecha4,0) + nvl(monto_fecha5,0) + nvl(monto_fecha6,0))/ 6;
		LET dLineaNva =  ROUND((NVL(sdo_prom,0) *  (dPorcentaje/100)),-2);
		
		
			/*SELECT Linea_Incremento INTO dLinea_Ant FROM "informix".ss_adn_bitacora_lincred
			WHERE num_solicitud = vNumCred AND num_cliente = vNumCte AND cuenta_nomina = vCtaNomina
			AND fecha_actualizacion= (select max(fecha_actualizacion) FROM "informix".ss_adn_bitacora_lincred
			WHERE num_solicitud = vNumCred AND num_cliente = vNumCte AND cuenta_nomina = vCtaNomina)
			AND fecha_actualizacion<=dtFecha6meses; */
			
			--VALIDAR FECHA_ACTUALIZACION > TODAY-6 MESES
		
		
		SELECT linea INTO dLinea_Ant FROM bdisolic:"informix".ss_adn_solicitudcuenta
		WHERE num_solicitud = vNumCred AND numcte = vNumCte AND cuenta_nomina = vCtaNomina;
		
		
		IF dLineaNva > dLinea_Ant THEN
		
			LET dLineaDif=dLineaNva-dLinea_Ant;
			IF dLineaDif>=500 THEN 
				--LET incLinea1 =  ROUND((NVL(dLineaNva,0) *  (30/100)),-2);
				LET incLinea2 =  ROUND((NVL(dLinea_Ant,0) *  (1.15)),-2);
				
				IF dLineaNva< incLinea2 THEN
					IF NVL(dLineaNva,0) >  dMontoMax THEN --SE TOPA LA LINEA
						LET dLineaNva = dMontoMax;
					END IF;
					IF dLineaNva=dLinea_Ant THEN
						ROLLBACK WORK;
						CONTINUE FOREACH;
					END IF;
					
					UPDATE bdisolic:"informix".ss_adn_solicitudcuenta SET linea = dLineaNva WHERE num_solicitud = vNumCred AND numcte = vNumCte AND cuenta_nomina = vCtaNomina;
					UPDATE bdicred:"informix".sd_maesdos SET monto_otorgado = dLineaNva WHERE empresa = pEmpresa AND num_credito = vNumCred;
					INSERT INTO "informix".ss_adn_bitacora_lincred(Num_Solicitud,Num_Cliente,Cuenta_nomina,Linea_Anterior,Linea_Incremento,Fecha_actualizacion)
					VALUES(vNumCred,vNumCte,vCtaNomina,dLinea_Ant,dLineaNva,dtFechaHoy);
					INSERT INTO "informix".ss_adn_bitacora_validacion(Num_Solicitud,Num_Cliente,Cuenta_nomina,fecha_apertura,fecha_mes1,monto_mes1,fecha_mes2,monto_mes2,
					fecha_mes3,monto_mes3,fecha_mes4,monto_mes4,fecha_mes5,monto_mes5,fecha_mes6,monto_mes6,sdo_promedio,Linea_Inicial,Linea_Anteriorx15,Linea_nuevo_ingreso,
					Linea_Incremento,Fecha_actualizacion)
					VALUES(vNumCred,vNumCte,vCtaNomina,dtfecha_apertura,dtfecha_1_ini,NVL(monto_fecha1,0),dtfecha_2_ini,NVL(monto_fecha2,0),dtfecha_3_ini,NVL(monto_fecha3,0),dtfecha_4_ini,NVL(monto_fecha4,0),
					dtfecha_5_ini,NVL(monto_fecha5,0),dtfecha_6_ini,NVL(monto_fecha6,0),sdo_prom,dLinea_Ant,incLinea2,dLineaNva,dLineaNva,dtFechaHoy);
								
					LET dMontoDif= dLineaNva-dLinea_Ant;
				ELSE
					IF NVL(incLinea2,0) >  dMontoMax THEN --SE TOPA LA LINEA
						LET incLinea2 = dMontoMax;
					END IF;
					IF incLinea2=dLinea_Ant THEN
						ROLLBACK WORK;
						CONTINUE FOREACH;
					END IF;
					
					UPDATE bdisolic:"informix".ss_adn_solicitudcuenta SET linea = incLinea2 WHERE num_solicitud = vNumCred AND numcte = vNumCte AND cuenta_nomina = vCtaNomina;
					UPDATE bdicred:"informix".sd_maesdos SET monto_otorgado = incLinea2 WHERE empresa = pEmpresa AND num_credito = vNumCred;
					INSERT INTO "informix".ss_adn_bitacora_lincred(Num_Solicitud,Num_Cliente,Cuenta_nomina,Linea_Anterior,Linea_Incremento,Fecha_actualizacion)
					VALUES(vNumCred,vNumCte,vCtaNomina,dLinea_Ant,incLinea2,dtFechaHoy);
					INSERT INTO "informix".ss_adn_bitacora_validacion(Num_Solicitud,Num_Cliente,Cuenta_nomina,fecha_apertura,fecha_mes1,monto_mes1,fecha_mes2,monto_mes2,
					fecha_mes3,monto_mes3,fecha_mes4,monto_mes4,fecha_mes5,monto_mes5,fecha_mes6,monto_mes6,sdo_promedio,Linea_Inicial,Linea_Anteriorx15,Linea_nuevo_ingreso,
					Linea_Incremento,Fecha_actualizacion)
					VALUES(vNumCred,vNumCte,vCtaNomina,dtfecha_apertura,dtfecha_1_ini,NVL(monto_fecha1,0),dtfecha_2_ini,NVL(monto_fecha2,0),dtfecha_3_ini,NVL(monto_fecha3,0),dtfecha_4_ini,NVL(monto_fecha4,0),
					dtfecha_5_ini,NVL(monto_fecha5,0),dtfecha_6_ini,NVL(monto_fecha6,0),sdo_prom,dLinea_Ant,incLinea2,dLineaNva, incLinea2,dtFechaHoy);
					
					LET dMontoDif= incLinea2-dLinea_Ant;
				END IF
				
				IF dMontoDif>0 THEN
					EXECUTE PROCEDURE bdicred:"informix".genmov(pEmpresa, vNumCred,'7800','1','008',dtFechaHoy,dMontoDif,vFolioSuc,cSucursal,cDivisa,'0000')
						 INTO cCodRetAux, cMensajeRetAux;

					IF cCodRetAux::INTEGER > 0 THEN
						LET cCodRet = cCodRetAux; 
						LET cMensajeRet = "Ocurrio un error al guardar los movimientos del credito en el SP bdicred:genmov";	   	
						ROLLBACK WORK;
						CONTINUE FOREACH;
					END IF;	
				END IF;
			END IF;	
		END IF;
		COMMIT WORK;
		LET cBegin = "N";
	END FOREACH;

	RETURN cCodRet; --,cMensajeRet;

END

END PROCEDURE
