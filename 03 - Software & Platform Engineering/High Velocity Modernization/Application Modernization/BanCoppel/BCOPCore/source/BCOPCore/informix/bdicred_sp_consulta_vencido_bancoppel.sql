CREATE PROCEDURE "informix".sp_consulta_vencido_bancoppel(pNumCliente CHAR(9), pTipoCliente CHAR(1), gen1 CHAR(50), gen2 CHAR(50), gen3 CHAR(50))
	RETURNING 	CHAR(6) AS CodigoRetorno, 
				CHAR(50) AS MensajeRetorno, 
				CHAR(9) AS NumCliente, 
				CHAR(1) AS IdVencido, 
				CHAR(1) AS IdSaturacion;

	DEFINE iSqlErr           	INTEGER;
    DEFINE iIsamErr          	INTEGER;
	DEFINE resultadoVencido 	DECIMAL(10,2);
	DEFINE cSaturacion 			DECIMAL(10,2);
	
	DEFINE cCodRet           	CHAR(6);
	DEFINE cErrorInfo        	CHAR(50);
	DEFINE cMensajeRet       	CHAR(50);
	DEFINE sNumeroCliente 		CHAR (15);
	DEFINE sIdVencido			INTEGER;
	DEFINE sIdSaturacion		INTEGER;
		
	DEFINE vSaldo				DECIMAL(10,2);
	DEFINE vLineaCredito		DECIMAL(10,2);
	DEFINE vPagoMinimoTotal		DECIMAL(10,2);
	DEFINE vMontoVencidoTotal	DECIMAL(10,2);
	DEFINE vLineaCreditoTotal 	DECIMAL(10,2);
	DEFINE vSaldoTotal			DECIMAL(10,2);
	DEFINE vNumCred				CHAR(15);
	DEFINE vMontoVencido 		DECIMAL(10,2);
	DEFINE vNumProd				CHAR(4);
	
	--Variables pago_minimo
	DEFINE cEmpresa          	CHAR(3);
	
	--Variables de retorno pago_minimo
	DEFINE vvcodigo_retorno 				CHAR(6);
	DEFINE vvmensaje_retorno				CHAR(80);
	DEFINE dMontoFinanciado  				DECIMAL(18,2);
	DEFINE dIntVdo           				DECIMAL(18,2);
	DEFINE dIntMoratorio     				DECIMAL(18,2);
	DEFINE dIvaIntVdo        				DECIMAL(18,2);
	DEFINE dPagosVdos						DECIMAL(18,2);
	DEFINE dIvaIntMoratorio  				DECIMAL(18,2);
	DEFINE dIntMes 							DECIMAL(18,2);
	DEFINE dIvaIntMes 						DECIMAL(18,2);
	DEFINE dIntVig 							DECIMAL(18,2);
	DEFINE dIvaIntVig 						DECIMAL(18,2);
	
	DEFINE dPagoMinimo       	DECIMAL(18,2);
	DEFINE vNoReg				INTEGER;

	LET vPagoMinimoTotal		= 0;
	LET resultadoVencido 		= 0;
	LET cSaturacion				= 0;
	LET vSaldo 					= 0;
	LET vLineaCredito 			= 0;
	LET iSqlErr             	= 0;
	LET iIsamErr             	= 0;
	
	LET cCodRet					= '00000';
	LET cErrorInfo           	= '';
	LET cMensajeRet				= 'CONSULTA EXITOSA';
	LET sIdVencido				= null;
	LET sIdSaturacion			= null;
	LET sNumeroCliente			= '';
	LET vMontoVencidoTotal		= 0;
	LET vLineaCreditoTotal 		= 0;
	LET vSaldoTotal				= 0;
	LET vNumCred 				= '';
	LET vMontoVencido 			= 0;
	LET cEmpresa             	= '001';
	LET vvcodigo_retorno 		= '';
	LET vvmensaje_retorno		= '';
	LET dMontoFinanciado  		= 0;
	LET dIntVdo           		= 0;
	LET dIntMoratorio         	= 0;
	LET dIvaIntVdo        		= 0;
	LET dPagosVdos				= 0;
	LET dIvaIntMoratorio  		= 0;
	LET dIntMes 				= 0;
	LET dIvaIntMes 				= 0;
	LET dIntVig 				= 0;
	LET dIvaIntVig 				= 0;
	LET dPagoMinimo           	= 0;
	LET vNoReg					= 0;
	LET vNumProd				= '';


	BEGIN	
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	    	IF iSqlErr != 0 THEN
	      		LET cCodRet = iSqlErr;
	      		LET cMensajeRet = iIsamErr||' - '||cErrorInfo ;
	      		RETURN cCodRet, cMensajeRet, sNumeroCliente, sIdVencido, sIdSaturacion;
	    	END IF;
	 	END EXCEPTION;
		
		--SET debug file to '/informix/sp_consulta_vencido_bancoppel.out';
		--trace on;
		

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF (pNumCliente = '' OR pTipoCliente = '')THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'FALTAN PARAMETROS';
			RETURN cCodRet, cMensajeRet, sNumeroCliente, sIdVencido, sIdSaturacion;
		END IF;
		
		IF pTipoCliente = '1' THEN
			--CONSULTA PARA OBTENER NUMERO DE CLIENTE BANCOPPEL
			SELECT numcte_banco INTO sNumeroCliente FROM bdinteg:"informix".si_relacion_ctebcplcpl where cliente = pNumCliente;
		ELSE
			LET sNumeroCliente = pNumCliente;
		END IF;
		
		IF (NVL(sNumeroCliente, '') = '')THEN
			LET cCodRet = '00002';
			LET cMensajeRet = 'NO SE ENCONTRO NO. DE CLIENTE';
			RETURN cCodRet, cMensajeRet, sNumeroCliente, sIdVencido, sIdSaturacion;
		END IF;
		
		---CONSULTA PARA TDC---
		FOREACH WITH HOLD 
				SELECT num_credito INTO vNumCred 
				FROM bdicred:informix.sd_maecred 
				WHERE numcte = sNumeroCliente AND  
				status_cred IN ('E1', 'E2','E3')
				
			SELECT monto_vencido, 
				   monto_otorgado, 
				   NVL(sdo_cap_insoluto,0)
			INTO vMontoVencido,
				 vLineaCredito,
				 vSaldo
			FROM bdicred:informix.sd_maesdos
			WHERE num_credito = vNumCred;
			
			--------------------------------PAGO MINIMO TDC-----------------------------------------
			
			EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(cEmpresa, vNumCred)
			INTO vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio,dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
			
			IF vvcodigo_retorno != '000000' THEN
				LET cCodRet = SUBSTR(vvcodigo_retorno,2);
				LET cMensajeRet = vvmensaje_retorno;
				RETURN cCodRet, cMensajeRet, '', sIdVencido, sIdSaturacion;
			END IF;
			
			---------------------------------------------------------------------------------------
			LET vPagoMinimoTotal = vPagoMinimoTotal + dPagoMinimo;
			LET vMontoVencidoTotal = vMontoVencidoTotal + vMontoVencido;
			LET vLineaCreditoTotal = vLineaCreditoTotal + vLineaCredito;
			LET vSaldoTotal = vSaldoTotal + vSaldo;
			LET vNoReg = vNoReg + 1;
		END FOREACH;
		----------------------------------------

		
		---CONSULTA PRESTAMOS Y REESTRUCTURAS---
		FOREACH WITH HOLD
				SELECT num_credito ,
						num_producto
				INTO vNumCred,
						vNumProd
				FROM bdicred:informix.sd_maecredcrd 
				WHERE numcte = sNumeroCliente AND 
				status_cred IN ('E1', 'E2','E3') 
				
				IF vNumProd = '6800' THEN
					SELECT 	md.monto_vencido, 
							pd.monto_linea, 
							NVL(md.sdo_cap_insoluto,0),
							NVL(md.monto_financiado,0)
					INTO vMontoVencido,
						vLineaCredito,
						vSaldo,
						dMontoFinanciado
					FROM 'informix'.sd_maesdoscrd md,
						 'informix'.sd_linea_prestamo pd
					WHERE md.num_credito = vNumCred AND
						md.num_credito = pd.num_credito;
				ELSE
					SELECT monto_vencido, 
						   monto_otorgado, 
							NVL(sdo_cap_insoluto,0),
							NVL(monto_financiado,0)
					INTO vMontoVencido,
						vLineaCredito,
						vSaldo,
						dMontoFinanciado
					FROM bdicred:informix.sd_maesdoscrd 
					WHERE num_credito = vNumCred;
				END IF;	
		
				--------------------------------PAGO MINIMO PRESTAMOS Y RESTRUCTURAS-----------------------------------------
				EXECUTE PROCEDURE bdicred:"informix".sp_obtener_pagomin(cEmpresa, vNumCred)
				INTO vvcodigo_retorno, vvmensaje_retorno, dPagoMinimo, dIntVdo, dIntMoratorio,dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
				
				
				IF vvcodigo_retorno != '000000' THEN
					LET cCodRet = SUBSTR(vvcodigo_retorno,2);
					LET cMensajeRet = vvmensaje_retorno;
					RETURN cCodRet, cMensajeRet, '', sIdVencido, sIdSaturacion;
				END IF;
			-----------------------------------------------------------------------------
			
				LET vPagoMinimoTotal = vPagoMinimoTotal + dPagoMinimo;
				LET vMontoVencidoTotal = vMontoVencidoTotal + vMontoVencido;
				LET vLineaCreditoTotal = vLineaCreditoTotal + vLineaCredito;
				LET vSaldoTotal = vSaldoTotal + vSaldo;
				LET vNoReg = vNoReg + 1;
		END FOREACH;
		-------------------------------
		
		
		IF vNoReg > 0 THEN
			
			IF NVL(vMontoVencidoTotal,0) <> 0 AND NVL(vPagoMinimoTotal,0) <> 0 THEN
				LET resultadoVencido = vMontoVencidoTotal / vPagoMinimoTotal;
			ELSE
				LET sIdVencido = 0;
			END IF;
			
			IF NVL(vSaldoTotal,0) <> 0 AND NVL(vLineaCreditoTotal,0) <> 0 THEN
				LET cSaturacion = (vSaldoTotal / vLineaCreditoTotal) * 100.0;
			ELSE
				LET sIdSaturacion = 0 ;
			END IF;
			
			IF sIdVencido IS NULL THEN
				SELECT 
						id 
				INTO 
					sIdVencido 
				FROM 'informix'.sd_param_vencido_saturacion 
				WHERE tipo_id = 'Vencido' AND
					resultadoVencido BETWEEN rango_ini AND rango_fin;
			END IF;

			IF sIdSaturacion IS NULL THEN
				SELECT {+INDEX('informix'.sd_param_vencido_saturacion sd_param_vencido_saturacion_tipo_id_idx)}  
						id
				INTO 
					sIdSaturacion
				FROM 'informix'.sd_param_vencido_saturacion 
				WHERE tipo_id = 'Saturacion' AND
					cSaturacion BETWEEN rango_ini AND rango_fin;
			END IF;
			
			IF sIdSaturacion IS NULL OR sIdVencido IS NULL THEN
				LET cCodRet = '00004';
				LET cMensajeRet = 'ID DE SATURACION O VENCIDO NO DEFINIDO';
			END IF;
		ELSE 
			LET cCodRet = '00003';
			LET cMensajeRet = 'CTE SIN NUMEROS DE CREDITO';
		END IF;
		
		RETURN cCodRet, cMensajeRet, sNumeroCliente, sIdVencido, sIdSaturacion;
  
	END;
END PROCEDURE
DOCUMENT
'PROYECTO: RQM 09 652 MODIFICACION RESTRICCION DE VENTA A CREDITO A CLIENTES CON VENCIDO BANCOPPEL',
'DESCRIPCION: CONSULTAR EL VENCIDO BANCOPPEL Y SATURACION DEL CLIENTE.',
'AUTOR: KEVIN GALVEZ PARRA',
'BD: BDICRED',
'FECHA: 30/01/2024',
'SOLICITA: GERMAN REYNAGA MURUA';

CREATE PROCEDURE "informix".consultmovscre_tipo_bpi(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro SMALLINT)
   RETURNING CHAR(5),DATE,CHAR(23),CHAR(40),CHAR(1),MONEY(14,2),MONEY(14,2),CHAR(4),CHAR(1), CHAR(40), MONEY(14,2);

    -----------------------------------------------------------------------------------------------------------------------
    --SE CLONA SPL: Berenice Noriega
    --Fecha: 16/MAYO/2019
    --Solicita: Alejandro Vazquez
    --Actividad: Se regresa parametros extras que indica si es titular o adicional el movimiento asi como la terminacion
    --Se renombra spl de consultmovscre_bpi a consultmovscre_tipo_bpi   
    --Proximo a liberar 
    --Se ajusta para no traer movimientos de cargos pagos fijos
    -----------------------------------------------------------------------------------------------------------------------

   DEFINE cDescripcion     CHAR(40);
   DEFINE vfecha        DATE;
   DEFINE vmonto        MONEY(14,2);
   DEFINE vserial       INTEGER;
   DEFINE vReferencia    CHAR(23);
   DEFINE vRefTotal CHAR(100);
   DEFINE vReferencia23  CHAR(23);
   DEFINE vcodret       CHAR(5);
   DEFINE vsqlerr       INTEGER;
   DEFINE vnaturaleza   CHAR(1);
   DEFINE vSdoDeudor    DECIMAL(14,2);
   DEFINE vRfcComer     CHAR(15);
   DEFINE vTrans     CHAR(4);
   DEFINE vTarjeta   CHAR(20);
   DEFINE vTerminacion CHAR(4);
   DEFINE vTipo         CHAR(1);
   DEFINE cFolioSuc		CHAR(16);
   DEFINE cDescripcionMovdescpos	CHAR(50);
   
   DEFINE vNumPagoFijo CHAR(12);
   DEFINE vCapitalInsoluto DECIMAL(14,2);
   DEFINE cPeriodo CHAR(40);
   DEFINE cDescripcionCapital   MONEY(14,2);
   DEFINE vReferencia2    CHAR(40);
   DEFINE cDescripcionTransfun     CHAR(40);

   LET vcodret = "000";
   LET cDescripcion = " ";
   LET vfecha = '01/01/1900';
   LET vmonto = 0;
   LET vSdoDeudor = 0;
   LET vnaturaleza = '';
   LET vReferencia = '';
   LET vReferencia23 = '';
   LET vserial = 0;
   LET vsqlerr = 0;
   LET vRfcComer = '';
   LET vTrans = '';
   LET vTarjeta ='';
   LET vTerminacion ='';
   LET vTipo ='';
   LET cFolioSuc =	"";
   LET cDescripcionMovdescpos =	"";
   
   LET vNumPagoFijo = "";
   LET vCapitalInsoluto = 0;
   LET cPeriodo = "";
   LET cDescripcionCapital = 0;
   LET vReferencia2 = '';
   LET cDescripcionTransfun = '';
   
   BEGIN
      ON EXCEPTION SET vsqlerr
         IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor,vTerminacion,vTipo, cPeriodo, cDescripcionCapital;
         END IF
      END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

      SELECT a.sdo_cap_insoluto
      INTO vSdoDeudor
      FROM sd_maesdos a, sd_maecredanexo b, sd_fechas c
      WHERE a.empresa = pempresa
      AND a.num_credito= pcuenta
      AND b.empresa = a.empresa
      AND b.num_credito = a.num_credito
      AND c.empresa = a.empresa;

      IF vSdoDeudor IS NULL THEN
         LET vSdoDeudor = 0;
         LET vcodret = "100";
         RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor, vTerminacion, vTipo, cPeriodo, cDescripcionCapital;
      END IF;

     -- Extrae los movimientos del rango de fechas especificado
     FOREACH
       (
        SELECT SKIP pRegistro FIRST 10
            a.secuencia, fecha_mov,
            CASE WHEN NVL(TRIM(a.referencia),'') = ''
            THEN c.transacc
              ELSE TRIM(a.referencia) END
              CASE,
            b.descripcion, naturaleza, monto, a.referencia23, a.rfc_comer, b.numero, d.num_tarjeta, d.tipo_tarjeta, a.folio_suc, c.descripcion
            INTO vserial,vfecha,vRefTotal,cDescripcion,vnaturaleza,vmonto, vReferencia23, vRfcComer, vTrans, vTarjeta, vTipo, cFolioSuc,cDescripcionTransfun
             FROM sd_movdia a
                JOIN sd_transfun c ON (a.codigo_fun = c.codigo_fun and a.codigo_ref = c.codigo_ref)
                JOIN bdinteg:si_transacc b ON (c.transacc = b.numero)
                LEFT OUTER JOIN sd_tarjeta d ON (a.nro_tarjeta=d.num_tarjeta)
             WHERE a.empresa = pempresa
             AND a.num_credito = pcuenta
             AND b.sistema = "06"
             AND b.se_emite_edocta = "S"
             AND a.reversado = "N"
			 AND b.numero NOT IN ('4200','4245','4220') --Filtro de movimientos pagos fijos
             AND fecha_mov between pFechaInicial and pFechaFinal

        UNION ALL
        SELECT a.secuencia, fecha_mov,
            CASE WHEN NVL(TRIM(a.referencia),'') = ''
              THEN c.transacc
            ELSE TRIM(a.referencia) END CASE,
            b.descripcion, naturaleza, monto, a.referencia23, a.rfc_comer, b.numero, d.num_tarjeta, d.tipo_tarjeta, a.folio_suc, c.descripcion
             FROM sd_movhis a
                JOIN sd_transfun c ON (a.codigo_fun = c.codigo_fun and a.codigo_ref = c.codigo_ref)
                JOIN bdinteg:si_transacc b ON (c.transacc = b.numero)
                LEFT OUTER JOIN sd_tarjeta d ON (a.nro_tarjeta=d.num_tarjeta)
             WHERE a.empresa = pempresa
             AND a.num_credito = pcuenta
             AND b.sistema = "06"
             AND b.se_emite_edocta = "S"
             AND a.reversado = "N"
			 AND b.numero NOT IN ('4200','4245','4220') --Filtro de movimientos pagos fijos
             AND fecha_mov between pFechaInicial and pFechaFinal
         )

          ORDER BY d.tipo_tarjeta DESC, d.num_tarjeta ASC, fecha_mov DESC, secuencia DESC

         IF vnaturaleza = "C" THEN
		 
            LET vmonto = (vmonto*(-1));
			
         END IF;

         IF (vTrans = '6801' or vTrans = '6830') THEN

                LET cDescripcion = TRIM(SUBSTRING(vRefTotal FROM 16));
                LET vReferencia = NVL(TRIM(vReferencia23),'');
				
                IF cDescripcion[1,8] = "intercar" THEN
				
                        LET cDescripcion = TRIM(SUBSTRING(cDescripcion FROM 16));
						
                END IF;
				
                LET cDescripcion = TRIM(cDescripcion) || " " || NVL(TRIM(vRfcComer),'');
        ELSE
            LET vReferencia = TRIM(vRefTotal);
        END IF;

        IF (vTrans = '6813' or vTrans = '6830') THEN

                SELECT NVL(TRIM(nomcomercio325),'')  INTO cDescripcionMovdescpos FROM bdicred:sd_movdescpos WHERE num_credito = pCuenta AND folio_suc = cFolioSuc ;

                IF cDescripcionMovdescpos  <> '' THEN 
				
                        LET cDescripcion = TRIM(cDescripcionMovdescpos) || " " || TRIM(cFolioSuc);
						
                END IF;

        END IF;
                
        IF (vTarjeta='' or vTarjeta is null) THEN
            LET vTipo='S';
            LET vTerminacion='';
        ELSE 
            LET vTarjeta = NVL(TRIM(vTarjeta),'');
            LET vTerminacion = SUBSTR(vTarjeta,13,4); 
        END IF;
		
		LET cPeriodo = '';
		LET cDescripcionCapital = 0;
		
         RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor, vTerminacion, vTipo, cPeriodo, cDescripcionCapital WITH RESUME;
     END FOREACH;
END
END PROCEDURE;