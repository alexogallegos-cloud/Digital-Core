CREATE PROCEDURE "informix".sp_incrementa_lincred_adn(pEmpresa CHAR(3))
RETURNING CHAR(6)        AS codigo_retorno,
          VARCHAR(150,1) AS mensaje_retorno;
		  
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
DEFINE cSucursal        CHAR(4);
DEFINE cDivisa          CHAR(2);
DEFINE vCtaNomina       VARCHAR(20,1);

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
LET cSucursal       = "";
LET cDivisa         = "";
LET vCtaNomina      = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN

      IF cBegin= "S" THEN
        ROLLBACK WORK;
      END IF;
   
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
---SET PDQPRIORITY 5; HMD-INCIDENCIA-20220224

-- SET DEBUG FILE TO '/informix/paulq/pruebas/sp_incrementa_lincred_adn.out';
-- TRACE ON;
		  
 SELECT empresa
   INTO cEmpresa     
   FROM bdinteg:si_empresas 
  WHERE empresa= pEmpresa;
  
  IF TRIM(NVL(cEmpresa,'')) = '' THEN
	  LET cCodRet = '000001';
	  LET cMensajeRet = 'El parámetro de la empresa no es valido';
	  RETURN cCodRet, cMensajeRet;
  END IF;
  
SELECT fecha_hoy
  INTO dtFechaHoy
  FROM "informix".sd_fechas
 WHERE empresa = pEmpresa;
 
 	 SELECT a.num_credito, a.numcte, a.sucursal, a.divisa, b.monto_otorgado, c.cuenta_nomina
	   FROM "informix".sd_maecred a, "informix".sd_maesdos b, bdisolic:ss_adn_solicitudcuenta c
	  WHERE a.num_credito = b.num_credito
	    AND a.empresa = b.empresa
	    AND a.num_producto = '7800'
	    AND b.monto_otorgado < 600
        AND c.num_solicitud = b.num_credito
        AND c.numcte  = a.numcte		
	INTO temp paso_incrementoadn WITH NO LOG;
 
	CREATE INDEX inx_paso_incrementoadn ON paso_incrementoadn(num_credito,numcte,cuenta_nomina);
	UPDATE STATISTICS HIGH FOR TABLE paso_incrementoadn;

FOREACH WITH HOLD
 
	 SELECT num_credito, numcte, sucursal, divisa, monto_otorgado, cuenta_nomina
	   INTO vNumCred, vNumCte, cSucursal, cDivisa, dMontoOtorgado, vCtaNomina
	   FROM paso_incrementoadn
		
		BEGIN WORK;
		LET cBegin = "S";
		
		UPDATE bdisolic:"informix".ss_adn_solicitudcuenta SET linea = 600 WHERE num_solicitud = vNumCred AND numcte = vNumCte AND cuenta_nomina = vCtaNomina;
		
		UPDATE "informix".sd_maesdos SET monto_otorgado = 600 WHERE empresa = pEmpresa AND num_credito = vNumCred;
		
        LET dMontoDif = 600 - dMontoOtorgado;	
		
		EXECUTE PROCEDURE "informix".genmov(pEmpresa, vNumCred,'7800','1','008',dtFechaHoy,dMontoDif,vFolioSuc,cSucursal,cDivisa,'0000')
                     INTO cCodRetAux, cMensajeRetAux;

		IF cCodRetAux::INTEGER > 0 THEN
			LET cCodRet = cCodRetAux; 
			LET cMensajeRet = "Ocurrio un error al guardar los movimientos del credito en el SP bdicred:genmov";	   	
			ROLLBACK WORK;
			CONTINUE FOREACH;
		END IF;		
		
		COMMIT WORK;
		LET cBegin = "N";
 
 END FOREACH;

	RETURN cCodRet,cMensajeRet;

END

END PROCEDURE
DOCUMENT 
'Se realiza procedimiento incrementar las lineas',
'del producto ADN',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 04/NOVIEMBRE/2016',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_procesa_amortiza( pFechaCorte date)
RETURNING
   CHAR(6)        AS Cod_Ret,
   CHAR(80)       AS Mens_Ret;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cCodRet2       CHAR(10);
DEFINE cMensajeRet   CHAR(125);


DEFINE vfechabaja DATE;
DEFINE 	spmensaje_Retorno	CHAR(80);
DEFINE	spNum_Credito	CHAR(20);
DEFINE	spCuenta_eje	CHAR(20);
DEFINE	spProducto		CHAR(40);
DEFINE	spNum_Cliente	CHAR(20);
DEFINE	spNom_Cliente	CHAR(150);
DEFINE	spPago_Efectivo	DECIMAL(18,2);
DEFINE	spPago_Cuenta	DECIMAL(18,2);
DEFINE	spMonto_Operacion	DECIMAL(18,2);
DEFINE	spSaldo_Actual	DECIMAL(18,2);
DEFINE	spSaldo_Actual2	DECIMAL(18,2);
DEFINE	spSaldo_Actual3	DECIMAL(18,2);
DEFINE	spSaldo_Actual4	DECIMAL(18,2);
DEFINE	spSaldo_Actual5	DECIMAL(18,2);
DEFINE	spSaldo_Actual6	DECIMAL(18,2);
DEFINE	spStatus_Actual	CHAR(60);

DEFINE	vFechaCuota	DATE;
DEFINE	vFechaCuota2 DATE;
DEFINE	vfecha_apertura DATE;
DEFINE	vlStatus_cred CHAR(2);
DEFINE 	vsdo_capital DECIMAL(18,2); 
DEFINE	vmonto_financiado DECIMAL(18,2);  
DEFINE	vsdo_cap_insoluto DECIMAL(18,2); 
DEFINE	vInteresdebe DECIMAL(18,2); 
DEFINE	vmonto_venc_trasp DECIMAL(18,2); 
DEFINE	cNumCredito  CHAR(20);
DEFINE vcuantos INTEGER;
DEFINE dFechacuotamin   DATE;
--FMJ APoyo 2014
DEFINE wbandera_apoyo CHAR(1);
DEFINE iFechaVencto			DATE;


LET ccodret             ='000';
LET vcuantos  = 0;
LET dFechacuotamin = DATE(1);
LET wbandera_apoyo = '';
LET iFechaVencto = DATE(1);

LET	spmensaje_Retorno='';	
LET	spNum_Credito='';	
LET	spCuenta_eje='';	
LET	spProducto='';		
LET	spNum_Cliente='';	
LET	spNom_Cliente='';	
LET	spPago_Efectivo=0;

LET	spSaldo_Actual2	=0;
LET	spSaldo_Actual3	=0;
LET	spSaldo_Actual4	=0;
LET	spSaldo_Actual5	=0;
LET	spSaldo_Actual6	=0;
LET	spPago_Cuenta=0;
LET	spMonto_Operacion=0;
LET	spSaldo_Actual=0;
LET	spStatus_Actual	='';

LET vFechaCuota = DATE(1);
LET vFechaCuota2 = DATE(1);
LET vfecha_apertura = DATE(1);
LET vfechabaja = DATE(1);

LET	vsdo_capital =0;
LET	vmonto_financiado =0;
LET	vsdo_cap_insoluto =0;
LET vInteresdebe = 0;
LET vmonto_venc_trasp = 0;
LET cNumCredito = '';

SET ISOLATION TO DIRTY READ;
--SET PDQPRIORITY 10; HMD-INCIDENCIA-20220224


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
  

   RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_procesa_pagostdcaa.out';
--TRACE ON;

-- *******************************************************
--  Seleccciona los creditos que se van a reactivar de baja de cartera
-- *******************************************************
FOREACH WITH HOLD
		select  cr.num_credito , fecha_apertura, status_cred, sdo_capital, monto_financiado, sdo_cap_insoluto , mto_venc_trasp
		  into cNumCredito,vfecha_apertura, vlStatus_cred, vsdo_capital, vmonto_financiado, vsdo_cap_insoluto , vmonto_venc_trasp
		  from bdicred:Sd_maecred cr, bdicred:sd_maesdos  sdo
         where cr.num_credito = sdo.num_credito
		   and campo_trab3 = 'BAJA' 
		   and status_cred in ('AA','BT','BA') 
		   -- and sucursal = '0002'
		   -- and cr.num_credito ='600000060969'

		---Selecciona la fecha de baja de cartera
        select limit 1 fecha_baja into vfechabaja 
		  from bdicobranza:cb_rep_cart_quebrantar
		  where num_credito = cNumCredito
		    and fechareporte >= mdy('01','01','2014')  
		    and fechareporte <= mdy('12','01','2014')  and excluido = 'B';
		let vfechabaja = mdy( month(vfechabaja)+1, '20', year(vfechabaja));
		
		--- Obtiene la fecha maxima de cuota generada
        SELECT max(fecha_cuota)
          INTO vFechaCuota
          FROM bdicred:sd_amortiza_credito
         WHERE num_credito = cNumCredito;
		 
		 let vFechaCuota2 = vFechaCuota;
		 /* ****************************************************************************************************************
		- Genera todas las cuotas faltantes de los creditos de BAJA que se van a reactivar
		- La fecha  MDY('02','20','2015') correspondera a la fecha del cierre en el que se vaya a meter el cambio.
		- La fecha mdy('03','01','2014') es para aquellos créditos que se aperturaron un año atras de la fecha de cierre que se ejecutara
		-  ya que si se aperturaron posterior los registros en la amortiza estan generados.
		******************************************************************************************************************* */
		WHILE vFechaCuota2 < pFechaCorte and  vfecha_apertura < mdy('03','01','2014')
		   let vcuantos = 0;
		   let vFechaCuota2 = vFechaCuota2 + 1 units month;
		  ---Valida que no exista la cuota que se va a generar 
		  select count(*) into vcuantos 
		    from  bdicred:sd_amortiza_credito 
		   where empresa = '001'
		    and num_credito = cNumCredito
			and fecha_cuota = vFechaCuota2;
			
		  if nvl(vcuantos,0) = 0 then 
		  --- Inserta la cuota a generar tomando la información de la última cuota viva que tenía el credito.
		    INSERT INTO bdicred:sd_amortiza_credito
		    select empresa ,num_credito,vFechaCuota2,tipo_cuota ,capital_mto_cuota ,capital_debe ,
		         capital_pagado ,capital_status ,capital_status_ant ,capital_fecha_pago,interes_debe,
				 interes_pagado,interes_status,interes_status_ant,interes_fecha_pago,iva_debe,
				 iva_pagado,iva_status,iva_status_ant,iva_fecha_pago,mora_provi_ordi,mora_provi_cope,
				 mora_sdo_ordi,mora_sdo_ordi_pag,mora_sdo_cope,mora_sdo_cope_pag,mora_bonificado,mora_status,
				 mora_iva_debe ,mora_iva_pagado,mora_iva_status,mora_iva_fecha_pago,num_pago,campo_trabajo1,campo_trabajo2,
				 campo_trabajo3,campo_trabajo4
		    from bdicred:sd_amortiza_credito
		    where empresa = '001'
		      and num_credito = cNumCredito
			  and fecha_cuota = vFechaCuota;			
		  end if;	
		END while;		
		
		/*if vfecha_apertura < mdy('02','01','2014')   then*/
		--- Obtiene la maxima fecha cuota generada con capital_status = 1
			SELECT min(fecha_cuota)--, max(fecha_cuota)
			INTO vFechaCuota2--, vFechaCuota
			FROM bdicred:sd_amortiza_credito
			WHERE num_credito = cNumCredito
			  and capital_status = 1;
			  
		---	Obtiene el monto de interes debe de la ultima cuota generada.  
			SELECT interes_debe			
			INTO vInteresdebe--, vFechaCuota
			FROM bdicred:sd_amortiza_credito
			WHERE num_credito = cNumCredito
			  and fecha_cuota = vFechaCuota2
			  and capital_status = 1;
		--- Si el crédito es vigente, pone las cuotas anteriores generadas como pagadas y quita el interes e iva debe en caso de existir		
		IF (vsdo_capital >0) or  (vsdo_cap_insoluto <= 0) 	THEN
		  update bdicred:sd_amortiza_credito
			set capital_debe = capital_pagado,			    
			    capital_status_ant = 1 ,
				capital_status = 5,
				interes_debe = 0,
				iva_debe = 0
         WHERE num_credito = cNumCredito
		   and fecha_cuota = vFechaCuota2
		   and capital_status = 1;	
		   
		--- Actualiza saldos a cero para no hacerlo exiigible
		   update bdicred:sd_maesdos
		     set  sdo_intereses = 0,
			      monto_financiado = 0, 
			      sdo_no_exig = 0
		    where empresa = '001'
			   and num_credito = cNumCredito;
			   
		ELif (vsdo_capital =0) and   (vmonto_financiado > 0) 	THEN
		--Creditos Vencidos, actualiza la última cuota activa como pagada (5)
          update bdicred:sd_amortiza_credito
			set capital_debe = capital_pagado,
			    capital_status_ant = 1 ,
				capital_status = 5,
				interes_debe = 0,
				iva_debe = 0
         WHERE num_credito = cNumCredito
		   and fecha_cuota = vFechaCuota2            
		   and capital_status = 1;			
		   
		   ---Actualiza maesdos con el monto financiado menos el monto ya vencido y el 
		   update bdicred:sd_maesdos
		     set  monto_financiado = vmonto_venc_trasp,
			      sdo_intereses = 0, 
			      sdo_no_exig = 0,
				  int_tra_no_exig =  int_tra_no_exig - vInteresdebe
		    where empresa = '001'
			   and num_credito = cNumCredito;
			   
			-- Actualiza el monto financiado de la base de datos historica con los montos vencidos   
			update bdicred:sd_maesdoshist
		     set  monto_financiado = (monto_vencido+ mto_venc_trasp)
		    where fecha >= vfechabaja
			  and empresa = '001'
			  and num_credito = cNumCredito;   
		   
		END IF;	
		---Actualiza todas las cuotas generadas a 5
		  update bdicred:sd_amortiza_credito
			set capital_status = 5
         WHERE num_credito = cNumCredito
		   and fecha_cuota >= vFechaCuota2 + 1 units month
           and	fecha_cuota < pFechaCorte
		   and capital_status = 1;		   
		   
		   UPDATE bdicred:Sd_maecred 
		      SET campo_trab3 = '' 
			WHERE empresa = '001'
			  and num_credito = cNumCredito;		
END FOREACH;    
   LET cCodRet = "000";   LET cMensajeRet = "PROCESO CONCLUIDO";
 RETURN cCodRet,cMensajeRet;

END;
END PROCEDURE;