CREATE PROCEDURE "informix".sp_consulta_msi_bpi(pNumCte CHAR(20),pNumTarjeta CHAR(20),pNumCredito CHAR(20), pServicio char(2))


                        --        pServicio./ Plataforma desde donde se ejecuta: 1.- OFI
						-- 		  Servicio 2.- Consulta pago mÃÂ­nimo a fecha de corte
RETURNING
          CHAR(05)      AS codigo_retorno,
          CHAR(20)      AS numero_credito,
          DATE		    AS fecha_compra,
          CHAR(40)      AS concepto,
          CHAR(16) 		AS folio_compra,
          DECIMAL(19,4) AS saldo_total_compra,
          CHAR(02) 		AS numero_pago,
          CHAR(02) 		AS plazo,
          DECIMAL(19,4) AS saldo_apagar,
          DECIMAL(19,4) AS saldo_dedudor;
		  

DEFINE iSqlErr      	    INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensajeRet          CHAR(80);
DEFINE iRegistros           INTEGER;
DEFINE cNumCredito          CHAR(20);
DEFINE dFechaCompra			DATE;
DEFINE cConcepto			CHAR(40);
DEFINE cFolioCompra			CHAR(16);
DEFINE dSaldoTotalCompra	DECIMAL(19,4);
DEFINE cNumPago				CHAR(2);
DEFINE cPlazo				CHAR(2);
DEFINE dSaldoAPagar			DECIMAL(19,4);
DEFINE dSaldoDeudor			DECIMAL(19,4);
DEFINE cNumCte				CHAR(20);
DEFINE sCuentasMSI			SMALLINT;
DEFINE cNumSolPrestamo		CHAR(20);
DEFINE cStatusCred 			CHAR(4);
DEFINE sSecuencia			SMALLINT;

/*********************************************/
DEFINE cCodRet_pm 			CHAR(6);
DEFINE cMensaje_retorno_pm	CHAR(80);
DEFINE dPagoMinimo_pm		DECIMAL(18,2);
DEFINE dPagoMinimo_tot_pm	DECIMAL(18,2);
DEFINE dPagoMinimo_msi	DECIMAL(18,2);
DEFINE dIntVdo_pm 			DECIMAL(18,2);
DEFINE dIntMoratorio_pm 	DECIMAL(18,2);
DEFINE dIvaIntVdo_pm 		DECIMAL(18,2);
DEFINE dPagosVdos_pm 		DECIMAL(18,2);
DEFINE dIvaIntMoratorio_pm 	DECIMAL(18,2);
DEFINE dIntMes_pm 			DECIMAL(18,2);
DEFINE dIvaIntMes_pm 		DECIMAL(18,2);
DEFINE dIntVig_pm 			DECIMAL(18,2);
DEFINE dIvaIntVig_pm 		DECIMAL(18,2);




BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet = "-"||trim(cNumCredito)||"-"|| cErrorInfo;
		RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
			NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_consulta_msi_bpi.out"; 
--TRACE ON;

LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = '';
LET cCodRet             = '00000';
LET cMensajeRet         = 'Se realizo la consulta correctamente';
LET iRegistros          = 0;
LET cNumCredito         = '';
LET dFechaCompra		= DATE(1);
LET cConcepto			= '';
LET cFolioCompra		= '';
LET dSaldoTotalCompra	= 0;
LET cNumPago			= '';
LET cPlazo				= '';
LET dSaldoAPagar		= 0;
LET dSaldoDeudor		= 0;
LET cNumCte				= '';
LET sCuentasMSI			= 0;
LET cNumSolPrestamo		= '';
LET cStatusCred			= '';
LET sSecuencia			= 0;

/*********************************************/
LET cCodRet_pm 			= '';
LET cMensaje_retorno_pm	= '00000';
LET dPagoMinimo_pm		= 0;
LET dPagoMinimo_tot_pm  = 0;
LET dPagoMinimo_msi		= 0;
LET dIntVdo_pm 			= 0;
LET dIntMoratorio_pm 	= 0;
LET dIvaIntVdo_pm 		= 0;
LET dPagosVdos_pm 		= 0;
LET dIvaIntMoratorio_pm = 0;
LET dIntMes_pm 			= 0;
LET dIvaIntMes_pm 		= 0;
LET dIntVig_pm 			= 0;
LET dIvaIntVig_pm 		= 0;


	-- Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	IF NVL(pNumCte,'') = '' AND NVL(pNumCredito,'') = '' THEN
		LET cCodRet     = '99999';
		RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
		NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);
	END IF;

	-- Condiciones nuevas msi 
	LET pNumCte = pNumCte;
	LET pNumCredito = pNumCredito;
	
	-- SE REMOVIO LA VALIDACION DE TARJETA QUE RETORNABA EL CODIGO: cCodRet= '00001';
	
	IF  NVL(TRIM(pNumCredito),'') != '' THEN
	
		SELECT status_cred, num_credito INTO cStatusCred, cNumCredito FROM bdicred:sd_maecred 
		 WHERE num_credito = pNumCredito AND status_cred IN ('AA','BA','BT','E1','E2','E3');
		IF NVL(TRIM(cStatusCred), '') = '' THEN
			LET cCodRet= '00002';			
			RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
				   NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);	
		END IF;
	END IF;

	IF  NVL(TRIM(pNumCte),'') != '' THEN
		SELECT numcte INTO cNumCte FROM bdinteg:si_cliente WHERE numcte = pNumCte; 	
		SELECT num_credito INTO cNumCredito FROM bdicred:sd_maecred WHERE numcte = cNumCte AND num_credito = pNumCredito  AND status_cred IN ('AA','BA','BT','E1','E2','E3');
		IF TRIM(cNumCredito) = '' OR cNumCredito IS NULL THEN
		    LET cCodRet = '00003';			
			RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
			       NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);	
		END IF; 
	END IF;
	
	IF (pServicio = '1')THEN 	-- Retorna MSI contratados con determinada TDC
	    FOREACH WITH HOLD
		    SELECT a.num_credito,a.num_sol_prestamo,a.fecha,a.nombre_promo,a.folio_movto,c.monto_otorgado,a.plazo,a.mensualidad,a.monto_actual 
		    INTO cNumCredito,cNumSolPrestamo,dFechaCompra,cConcepto,cFolioCompra,dSaldoTotalCompra,cPlazo,dSaldoAPagar,dSaldoDeudor
		    FROM bdicred:sd_promocion_credito a
		    INNER JOIN bdicred:sd_maecred b on (a.num_credito = b.num_credito)
		    INNER JOIN bdicred:sd_maecredcrd d on (a.num_sol_prestamo = d.num_credito AND d.status_cred IN ('AA','BA','E1','E2'))
		    INNER JOIN bdicred:sd_maesdoscrd c on (a.num_sol_prestamo = c.num_credito)
		    WHERE a.num_credito = cNumCredito
		    AND a.num_pro_prestamo = '8900'
			
		    SELECT MAX(num_pago):: char INTO cNumPago
		    FROM bdicred:sd_amortiza_creditocrd
		    WHERE empresa = '001' AND num_credito = cNumSolPrestamo;

            RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
			NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0) WITH RESUME;
			
	    END FOREACH;

	    LET iRegistros = DBINFO("sqlca.sqlerrd2");
	    IF iRegistros  = 0 THEN
		    LET cCodRet     = '00004';
		    LET cMensajeRet = 'NO SE OBTUVIERON RESULTADOS';
		    RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dSaldoTotalCompra,0), NVL(cNumPago,0), 
			NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);
	    END IF;
	END IF; 
	
	
	IF (pServicio = '2')THEN 	-- Pago mÃÂ­nimo mÃÂ¡s meses sin intereses  (pago minimo tdc + pagos minimos de msi)  ( 1 bpi y app)
	
		LET dPagoMinimo_tot_pm = 0;
		-- Obtiene pago minimo de TDC
		
		EXECUTE PROCEDURE bdicred:sp_consultasaldocortemin('001',cNumCredito,4)
				INTO cCodRet_pm, dPagoMinimo_pm;


		LET dPagoMinimo_tot_pm = dPagoMinimo_pm;


		-- Obtiene Pago Minimo de MSI contratados a la tdc
		FOREACH WITH HOLD
			SELECT a.num_sol_prestamo
			  INTO   cNumSolPrestamo
			  FROM bdicred:sd_promocion_credito a
			 INNER JOIN bdicred:sd_maecred b on (a.num_credito = b.num_credito)
			 INNER JOIN bdicred:sd_maecredcrd d on (a.num_sol_prestamo = d.num_credito AND d.status_cred IN ('AA','BA','E1','E2'))
			 WHERE a.num_credito = cNumCredito AND a.num_pro_prestamo = '8900'

				--ModificaciÃÂ³n Inicial
			EXECUTE PROCEDURE bdicred:sp_consultasaldocortemin('001',cNumSolPrestamo,4)
				INTO cCodRet_pm, dPagoMinimo_msi;
				
			LET dPagoMinimo_tot_pm = dPagoMinimo_tot_pm + dPagoMinimo_msi;
			LET dPagoMinimo_msi = 0;

		END FOREACH;
		
		LET dFechaCompra = date(1);
		LET cConcepto = '';
		LET cFolioCompra = '';
		LET dSaldoTotalCompra = dPagoMinimo_tot_pm;
		LET cNumPago = '';
		LET cPlazo = '';
		LET dSaldoAPagar = 0;
		LET dSaldoDeudor = 0;

		RETURN cCodRet, NVL(cNumCredito,''), NVL(dFechaCompra,DATE(1)), NVL(cConcepto,0), NVL(cFolioCompra,0), NVL(dPagoMinimo_tot_pm,0), NVL(cNumPago,0), 
		NVL(cPlazo,0), NVL(dSaldoAPagar,0), NVL(dSaldoDeudor,0);
	
	
	END IF;
	
	
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'La consulta Meses Sin Intereses contratados por el cliente',
'AUTOR : ',
'FECHA : 23/OCTUBRE/2021',
'BD    : BDICRED';

CREATE PROCEDURE "informix".obt_datos_caratula(pEmpresa VARCHAR(3), pNumCred VARCHAR(20))
   RETURNING CHAR(5),  DECIMAL(14,2), DECIMAL(14,2), integer, integer, CHAR(18);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cProducto           CHAR(4);
   DEFINE cTipoCred           CHAR(2);
   DEFINE cMonto              DECIMAL(14,2);
   DEFINE cMontoTotal         DECIMAL(14,2);
   DEFINE cFechaPago          INTEGER;
   DEFINE cFechaCorte         INTEGER;
   DEFINE cClabe			  CHAR(18);
   DEFINE cSecuencia		  SMALLINT;
   
   LET cCodRet       ='00000';
   LET cProducto     ='0000';
   LET cTipoCred     ='00';   
   LET cMonto        =0;   
   LET cMontoTotal	 =0;
  LET cFechaPago	 =0;
  LET cFechaCorte	 =0;
  LET cClabe		 =0;
  LET cSecuencia	 =0;
         
BEGIN
            ON EXCEPTION SET iSqlErr
                  IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cMonto, cMontoTotal, cFechaPago, cFechaCorte, cClabe;
                  END IF;
            END EXCEPTION;
			
			--SET DEBUG FILE TO "/tmp/obt_datos_caratula.out";
			--TRACE ON;
			
                
            SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ;
			
			SELECT num_producto
			INTO cProducto
			FROM sd_maecredcrd 
			WHERE num_credito = pNumCred;
			
			IF cProducto = '' THEN			
				SELECT num_producto
				INTO cProducto
				FROM sd_maecred 
				WHERE num_credito = pNumCred;
			END IF;
			
			SELECT cod_tipcred
			INTO cTipoCred
			FROM sd_definicion 
			WHERE num_producto = cProducto;			
			
			-- Se obtiene la secuencia mas alta de la sd_tarjeta y se almacena en la variable cSecuencia para evitar
			-- hacer un select max dentro de un where, con esto se trae la cuenta activa o inactiva tomando en cuenta
			-- la secuencia mas alta
			SELECT MAX(secuencia) 
			INTO cSecuencia
			FROM sd_tarjeta 
			WHERE num_credito = pNumCred;

				
		   IF cTipoCred = '05' THEN					   	
				
			   SELECT 
				sdo_cap_insoluto, mto_capitalizado, dias_fecha_max_pago, dia_corte
			   INTO
			   	cMonto, cMontoTotal, cFechaPago, cFechaCorte
			   FROM  sd_maecredanexocrd a, sd_maesdoscrd b
			   WHERE a.num_credito = b.num_credito
			   AND a.num_credito = pNumCred
			   AND a.empresa = pEmpresa;  

			   IF ((cMonto IS NULL) OR cMonto = 0) AND cProducto = '6800' THEN
					SELECT 
					monto_otorgado, mto_capitalizado, dias_fecha_max_pago, dia_corte
					INTO
					cMonto, cMontoTotal, cFechaPago, cFechaCorte
					FROM  sd_maecredanexocrd a, sd_maesdoscrd b
					WHERE a.num_credito = b.num_credito
					AND a.num_credito = pNumCred
					AND a.empresa = pEmpresa; 
			   END IF;
			ELSE
			
				
				SELECT 
				limite_aut, (dia_corte - dias_gracia_mora) as diapago , dia_corte
				INTO cMonto, cFechaPago, cFechaCorte
				FROM  sd_maecredanexo a, sd_tarjeta b
				WHERE a.num_credito = b.num_credito
				AND a.num_credito = pNumCred
				AND status_tar in ('A', 'I')
				AND a.empresa = pEmpresa
                AND b.tipo_tarjeta ='T'
				AND b.secuencia = cSecuencia;
				
				IF (cMonto IS NULL) OR cMonto = 0 THEN
					SELECT monto_otorgado
					INTO cMonto
					FROM  sd_maecredanexo a, sd_maesdos b
					WHERE a.num_credito = b.num_credito
					AND a.num_credito = pNumCred
					AND a.empresa = pEmpresa; 
               END IF;
				
	       END IF;
		   
		   SELECT 
				cuenta_clabe
		   INTO cClabe
		   FROM  sd_maecredcrd
		   WHERE num_credito = pNumCred
		   AND empresa = pEmpresa;    

		   IF cClabe = "" Or cClabe IS NULL or cClabe = 0 THEN 		
				SELECT 
					cuenta_clabe
			    INTO cClabe
				FROM  sd_maecred
				WHERE num_credito = pNumCred
				AND empresa = pEmpresa;
				
	       END IF;

           IF (cMonto IS NULL) OR cMonto = 0 THEN
              LET  cCodRet = '00001';  
           END IF;

           RETURN cCodRet, cMonto, cMontoTotal, cFechaPago, cFechaCorte, cClabe;

END;
END PROCEDURE;