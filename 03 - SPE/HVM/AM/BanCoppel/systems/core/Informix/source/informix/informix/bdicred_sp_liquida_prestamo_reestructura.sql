CREATE PROCEDURE "informix".sp_liquida_prestamo_reestructura(P_EMPRESA        VARCHAR(3) ,
														   P_NUM_SOLICITUD  VARCHAR(20),
														   P_FOLIO          VARCHAR(20))
RETURNING VARCHAR(5), VARCHAR(80);

DEFINE vCodRet          	VARCHAR(5);
DEFINE vMensaje         	VARCHAR(80);
DEFINE vFuncion         	VARCHAR(3);
DEFINE vCodComis        	VARCHAR(4);
DEFINE vNumCte          	VARCHAR(20);
DEFINE vTarjeta         	VARCHAR(20);
DEFINE eRror_Info       	VARCHAR(80);
DEFINE vNumCredOld      	VARCHAR(20);
DEFINE vVigente         	DECIMAL(14,2);
DEFINE vVencido         	DECIMAL(14,2);
DEFINE vVencTrasp       	DECIMAL(14,2);
DEFINE vIntNoExig       	DECIMAL(14,2);
DEFINE vIntVenc         	DECIMAL(14,2);
DEFINE vIntVencTrasp    	DECIMAL(14,2);
DEFINE vIvaIntNoExig		DECIMAL(14,2);
DEFINE vIvaIntVenc			DECIMAL(14,2);
DEFINE vIvaIntVencTrasp		DECIMAL(14,2);
DEFINE vSdoSeg          	DECIMAL(18,2);
DEFINE vTotSdoSeg       	DECIMAL(18,2);
DEFINE vMora            	DECIMAL(14,2);
DEFINE vMtoComis        	DECIMAL(14,2);
DEFINE vNumProducto     	CHAR(4);
DEFINE vSucursal        	CHAR(4);
DEFINE vdivisa          	CHAR(2);
DEFINE vFolio           	CHAR(16);
DEFINE vComision        	CHAR(4);
DEFINE vEvento          	CHAR(2);
DEFINE vHoy             	DATE;
DEFINE vNumConfirma     	INTEGER;
DEFINE SQL_ERR          	INTEGER;
DEFINE ISAM_ERR         	INTEGER;
DEFINE vDiasCalc        	SMALLINT;
DEFINE vMtoCopete       	DECIMAL(14,2);
DEFINE vIvaMtoCopete    	DECIMAL(14,2);
DEFINE vIvaMtoOrdi      	DECIMAL(14,2);
DEFINE vMtoTotal        	DECIMAL(14,2);
DEFINE vLimite_aut      	DECIMAL(14,2);
DEFINE vIvaSuc          	CHAR(5);
DEFINE vinteresvend  		DECIMAL(14,2);
DEFINE vivavend      		DECIMAL(14,2);
define vtasa         		date;
define vfecaper      		date;
define vfecuota      		date;
define v_usuario      		varchar(8);
define vcadena 				integer;
define vEjecutivo			CHAR(8);
DEFINE vIntVencBalanza		DECIMAL(14,2);
DEFINE vIvaIntVencBalanza	DECIMAL(14,2);
DEFINE vIntVencOrdinario	DECIMAL(14,2);
DEFINE vIvaIntVencOrdinario	DECIMAL(14,2);
DEFINE sApoyo				SMALLINT;
DEFINE dMontoInteresApoyo		DECIMAL(14,2);
DEFINE dMontoiIvaInteresApoyo	DECIMAL(14,2);
DEFINE vstatus_cnr 				CHAR(2);

  --set debug file to "/ifxsif01/joel/liquida_cred.out";
  --trace on;

  --BEGIN WORK;

  --ASIGNA VALORES A LAS VARIABLES
  LET vCodRet        	= '00000';
  LET vMensaje       	= 'PROCESO EXITOSO';
  LET vFuncion       	= '124';
  LET vNumConfirma   	= 0;
  LET vCodComis      	= '';
  LET vNumCte        	= '';
  LET eRror_Info     	= '';
  LET vNumCredOld    	= '';
  LET vVigente       	= 0;
  LET vVencido       	= 0;
  LET vVencTrasp     	= 0;
  LET vIntNoExig     	= 0;
  LET vIntVenc       	= 0;
  LET vIntVencTrasp  	= 0;
  LET vIvaIntNoExig     = 0;
  LET vIvaIntVenc       = 0;
  LET vIvaIntVencTrasp  = 0;
  LET vSdoSeg        	= 0;
  LET vTotSdoSeg     	= 0;
  LET vMora          	= 0;
  LET vMtoComis      	= 0;
  LET vNumProducto   	= '';
  LET vSucursal      	= '';
  LET vdivisa        	= '';
  LET vFolio         	= '';
  LET vComision      	= '';
  LET vEvento        	= '';
  LET vHoy           	= '';
  LET vMtoCopete     	= 0;
  LET vIvaMtoOrdi    	= 0;
  LET vIvaMtoCopete  	= 0;
  LET vNumCredOld    	= P_NUM_SOLICITUD;
  LET vFolio         	= P_FOLIO;
  LET vMtoTotal      	= 0;
  LET vLimite_aut    	= 0;
  LET vEjecutivo		= '';
  LET vIntVencBalanza		= 0;
  LET vIvaIntVencBalanza	= 0;
  LET vIntVencOrdinario		= 0;
  LET vIvaIntVencOrdinario	= 0;
  LET sApoyo				= 0;
  LET dMontoInteresApoyo		= 0;
  LET dMontoiIvaInteresApoyo	= 0;
  LET vstatus_cnr = '';



  
  -- SACA EL I.V.A DEL SD_PARAM
    SELECT TRIM(valor) INTO vIvaSuc FROM sd_param
    WHERE cod_param = "12"
    AND empresa = P_EMPRESA;


  --LEE LA INFORMACION DEL CREDITO
     SELECT num_producto, sucursal, divisa, NUMCTE, ejecutivo, status_cred
     INTO   vNumProducto, vSucursal, 
            vdivisa, vNumCte, vEjecutivo, vstatus_cnr
     FROM   sd_maecredcrd
     WHERE  empresa     = P_EMPRESA AND
            num_credito = vNumCredOld;

    SELECT monto_otorgado
      INTO vLimite_aut
      FROM sd_maesdoscrd
     WHERE empresa  = P_EMPRESA AND
           num_credito = vNumCredOld;


     -- Respada Credito a Liquidar

    CALL respalda_creditocrd(P_EMPRESA,vNumCredOld,vEjecutivo) RETURNING vCodRet;
    IF vCodRet <> "000" THEN
       --ROLLBACK WORK;
       LET vMensaje ="Al Respaldar Credito a Renovar";
       RETURN vCodRet, vMensaje;
    ELSE
       LET vCodRet ="00000";
    END IF;

    SELECT  fecha_hoy
    INTO  vHoy
    FROM sd_fechas;

    -- Realpalda a Cartera Vendida
    CALL respventacnr(P_EMPRESA,vNumCredOld,vHoy) RETURNING vCodRet;
    IF vCodRet <> "000" THEN
       --ROLLBACK WORK;
       LET vMensaje ="Al Respaldar Credito a Vender";
       RETURN vCodRet, vMensaje;
    ELSE
       LET vCodRet ="00000";
    END IF;

    -- Capital Vigente,Vencido Transitorio, Vencido Traspasado
    SELECT sdo_capital + cap_tras_no_venci,monto_vencido,mto_venc_trasp --Capitales
    INTO   vVigente,vVencido,vVencTrasp
    FROM   "informix".sd_maesdoscrd
    WHERE  empresa = P_EMPRESA AND
           NUM_credito = vNumCredOld;

    -- Corrigen el Cliente y siempre si quiere el Monto Autorizado 22 Agos 2009 MEL
    --LET vLimite_aut = vLimite_aut - vVigente - vVencTrasp - vVencido;

    SELECT NVL(SUM(interes_debe),0), NVL(SUM(iva_debe - iva_pagado),0)
    INTO   vIntNoExig, vIvaIntNoExig
    FROM   bdicred: "informix".sd_amortiza_creditocrd
    WHERE  empresa     = P_EMPRESA
      AND  num_credito = vNumCredOld
      AND  capital_status = '1';

/*    SELECT NVL(SUM(interes_debe - interes_pagado),0), NVL(SUM(iva_debe - iva_pagado),0)
    INTO   vIntVencTrasp, vIvaIntVencTrasp
    FROM   bdicred: "informix".sd_amortiza_creditocrd
    WHERE  empresa     = P_EMPRESA
      AND  num_credito = vNumCredOld
      AND  capital_status = '2';*/
	--Borra la tabla temporal
	/*DROP TABLE IF EXISTS movcrd;
 	SELECT a.num_credito, codigo_fun, codigo_ref, max(fecha_mov) fecha_mov
	FROM bdicred:sd_movhiscrd a, bdicred:sd_maecredcrd b
	WHERE a.empresa = P_EMPRESA
	AND a.num_credito = b.num_credito
	AND codigo_fun = '026'
	AND codigo_ref in (3,7049)
	AND reversado = 'N'
	AND a.num_credito = vNumCredOld
	group by 1,2,3
 	into temp movcrd with no log;

	CREATE INDEX tmp_creditofr ON movcrd(num_credito, codigo_fun, codigo_ref);

	SELECT nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(interes_debe - interes_pagado,0) else 0 end),0),
				nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(iva_debe - iva_pagado,0) else 0 end),0),
				nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(interes_debe - interes_pagado,0) else 0 end),0),
				nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(iva_debe - iva_pagado,0) else 0 end),0)
	INTO vIntVencBalanza, vIvaIntVencBalanza, vIntVencOrdinario, vIvaIntVencOrdinario
	FROM bdicred:sd_amortiza_creditocrd a, movcrd b
	WHERE a.empresa = P_EMPRESA
	AND a.num_credito = vNumCredOld
	AND a.num_credito = b.num_credito
	AND a.capital_status in ('2','7','6')
	AND b.codigo_fun = '026' 
	AND b.codigo_ref in (3,7049);*/
	
	SELECT nvl(sum(case when a.campo_trabajo3 = '' then nvl(interes_debe - interes_pagado,0) else 0 end),0),
				nvl(sum(case when a.campo_trabajo3 = '' then nvl(iva_debe - iva_pagado,0) else 0 end),0),
				nvl(sum(case when a.campo_trabajo3 = 'V'  then nvl(interes_debe - interes_pagado,0) else 0 end),0),
				nvl(sum(case when a.campo_trabajo3 = 'V'  then nvl(iva_debe - iva_pagado,0) else 0 end),0)
	INTO vIntVencBalanza, vIvaIntVencBalanza, vIntVencOrdinario, vIvaIntVencOrdinario
	FROM bdicred:sd_amortiza_creditocrd a
	WHERE a.empresa = P_EMPRESA
	AND a.num_credito = vNumCredOld
	--AND a.num_credito = b.num_credito
	AND a.capital_status in ('2','7','6');

--Intereses e Iva de cuentas del programa de apoyo 2020
	SELECT COUNT(*) INTO sApoyo
	FROM bdicred:sd_programa_apoyo2020crd
	WHERE num_credito=vNumCredOld;

	IF sApoyo > 0 THEN
		SELECT monto INTO dMontoInteresApoyo
		FROM bdicred:sd_maeretenido 
		WHERE empresa = P_EMPRESA
		AND num_credito = vNumCredOld
		AND transacc = '8374'
		AND estatus = 'R';
		
		LET vIntVencBalanza = vIntVencBalanza + NVL(dMontoInteresApoyo,0);

		SELECT monto INTO dMontoiIvaInteresApoyo
		FROM bdicred:sd_maeretenido 
		WHERE empresa = P_EMPRESA
		AND num_credito = vNumCredOld
		AND transacc = '8375'
		AND estatus = 'R';

		LET vIvaIntVencBalanza = vIvaIntVencBalanza + NVL(dMontoiIvaInteresApoyo,0);
	END IF;
--Intereses e Iva de cuentas del programa de apoyo 2020	

	LET vIntVencTrasp = vIntVencBalanza + vIntVencOrdinario; 
	LET vIvaIntVencTrasp = vIvaIntVencBalanza + vIvaIntVencOrdinario;
	
/*	select sum(interes_debe-interes_pagado),sum(iva_debe-iva_pagado)
    INTO   vIntVencBalanza, vIvaIntVencBalanza
	from bdicred:sd_amortiza_creditocrd
	where empresa = P_EMPRESA
	and num_credito = vNumCredOld
	and capital_status_ant = '7'; --balanza

	select sum(interes_debe-interes_pagado),sum(iva_debe-iva_pagado)
    INTO   vIntVencOrdinario, vIvaIntVencOrdinario
	from bdicred:sd_amortiza_creditocrd
	where empresa = P_EMPRESA
	and num_credito = vNumCredOld
	and capital_status_ant = '1'; --ordinarios*/
	  
    --Cancelacion De Mora Copete

   SELECT NVL(SUM( mora_provi_cope+  mora_sdo_cope - mora_sdo_cope_pag),0)
   INTO   vMtoCopete
   FROM   "informix".sd_amortiza_creditocrd
   WHERE  empresa     = P_EMPRESA
   AND    num_credito = vNumCredOld
   AND  capital_status in('7', '2','6');
   IF vMtoCopete > 0 THEN
      LET vIvaMtoCopete = vMtoCopete *  vIvaSuc;
   ELSE
      LET vIvaMtoCopete = 0;
   END IF;

    --Cancelacion De Mora Ordinari

   SELECT NVL(sum(mora_provi_ordi +  mora_sdo_ordi - mora_sdo_ordi_pag),0)
   INTO   vMora
   FROM   "informix".sd_amortiza_creditocrd
   WHERE  empresa     = P_EMPRESA
   AND    num_credito = vNumCredOld
   AND  capital_status in('7', '2','6');
   IF vMora > 0 THEN
      LET vIvaMtoOrdi = vMora *  vIvaSuc ;
   ELSE
      LET vIvaMtoOrdi = 0;
   END IF;


   IF vMtoCopete > 0 THEN -- NO SE MUEVEN
     CALL genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto,1,
                 '124', vHoy, vMtoCopete,
                 vFolio, vSucursal, vDivisa, '0000', 'BAJA DE INTERESES MORATORIOS VENCIDOS COPETE', ' ')
     RETURNING vCodRet, vMensaje;
     IF vCodRet <> "00000" THEN
       RETURN vCodRet, vMensaje;
     END IF;
 --     LET vMtoTotal = vMtoTotal + vMtoCopete;
    END IF;

    --Cancelacion De Iva Mora Copete

   IF vIvaMtoCopete > 0 THEN -- NO SE MUEVEN
     CALL genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto,2,
                 '124', vHoy, vIvaMtoCopete,
                 vFolio, vSucursal, vDivisa, '0000', 'BAJA DEL IVA SOBRE INTERESES MORATORIOS COPETE', ' ')
     RETURNING vCodRet, vMensaje;
     IF vCodRet <> "00000" THEN
       RETURN vCodRet, vMensaje;
     END IF;
   --  LET vMtoTotal = vMtoTotal + vIvaMtoCopete;
   END IF;

     -- Liquida o Traspasa el Capital Vigente Segun Corresponda
    IF vVigente > 0 then
		IF  vstatus_cnr =  'E2' THEN  --IFRS
			EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 28,
									 '124', vHoy, vVigente, vFolio, vSucursal,
									 vdivisa, "0000", "CANCELACION DE CAPITAL VENCIDO NO EXIGIBLE", " ") 
									 INTO vCodRet, vMensaje;

			IF vCodRet <> "00000" THEN
			  --ROLLBACK WORK;
			  RETURN vCodRet, vMensaje;
			END IF;
		ELSE 
			EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 8,
									 '124', vHoy, vVigente, vFolio, vSucursal,
									 vdivisa, "0000", "CANCELACION DE CAPITAL VENCIDO NO EXIGIBLE", " ") 
									 INTO vCodRet, vMensaje;

			IF vCodRet <> "00000" THEN
			  --ROLLBACK WORK;
			  RETURN vCodRet, vMensaje;
			END IF;
		END IF;
        LET vMtoTotal = vMtoTotal + vVigente;
    END IF;

--    LET vMtoTotal = vMtoTotal;
     -- Liquida o Traspasa el Interes Vigente Segun Corresponda
    IF vVencido > 0 then
	 IF  vstatus_cnr =  'E2' THEN  --IFRS								 
       EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 27,
                                '124', vHoy, vVencido, vFolio, vSucursal,
                                vdivisa, "0000", "CANCELACION DE CAPITAL VENCIDO EXIGIBLE", " ") 
								INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;
	 ELSE
		EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 7,
                                '124', vHoy, vVencido, vFolio, vSucursal,
                                vdivisa, "0000", "CANCELACION DE CAPITAL VENCIDO EXIGIBLE", " ") 
								INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;
	 END IF;		
		
        LET vMtoTotal = vMtoTotal + vVencido;
    END IF;

--    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Capital Vencido Segun Corresponda
    IF vVencTrasp > 0 then
       EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 7,
                                '124', vHoy, vVencTrasp, vFolio, vSucursal,
                                vdivisa, "0000", "CANCELACION DE CAPITAL VENCIDO EXIGIBLE", " ") 
								INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
          --ROLLBACK WORK;
          RETURN vCodRet, vMensaje;
        END IF;

        LET vMtoTotal = vMtoTotal + vVencTrasp;
    END IF;

--    LET vMtoTotal = vMtoTotal;
     -- Liquida o Traspasa el Interes Vigente Segun Corresponda
    IF vIntNoExig > 0 then -- IFSR validar este caso
       EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 0,
                                '124', vHoy, vIntNoExig, vFolio, vSucursal,
                                vdivisa, "0000", " ", " ") 
								INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;
        LET vMtoTotal = vMtoTotal + vIntNoExig;
    END IF;

--    LET vMtoTotal = vMtoTotal;
     -- Liquida o Traspasa el Iva de Interes Vigente Segun Corresponda
    IF vIvaIntNoExig > 0 then -- IFSR validar este caso
       EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 0,
                                '124', vHoy, vIvaIntNoExig, vFolio, vSucursal,
                                vdivisa, "0000", " ", " ") 
								INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;
        LET vMtoTotal = vMtoTotal + vIvaIntNoExig;
    END IF;


--    LET vMtoTotal = vMtoTotal;

    -- Liquida o Traspasa el Interes Vencido Segun Corresponda

    IF vIntVencTrasp > 0 then
/*       EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 5,
                                '124', vHoy, vIntVencTrasp, vFolio, vSucursal,
                                vdivisa, "0000", "BAJA DE LOS INTERESES DE BALANZA VENCIDOS", " ") 
								INTO vCodRet, vMensaje;

       IF vCodRet <> "00000" THEN
          --ROLLBACK WORK;
          RETURN vCodRet, vMensaje;
       END IF;*/
		IF vIntVencBalanza > 0 THEN
		 IF  vstatus_cnr =  'E2' THEN  --IFRS	
		   EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 25,
									'124', vHoy, vIntVencBalanza, vFolio, vSucursal,
									vdivisa, "0000", "BAJA DE LOS INTERESES DE BALANZA VENCIDOS", " ") 
									INTO vCodRet, vMensaje;

		   IF vCodRet <> "00000" THEN
			  --ROLLBACK WORK;
			  RETURN vCodRet, vMensaje;
		   END IF;
		   
			EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 26,
									'124', vHoy, vIvaIntVencBalanza, vFolio, vSucursal,
									vdivisa, "0000", "BAJA DEL IVA SOBRE INTERESES DE BALANZA VENCIDOS", " ") 
									INTO vCodRet, vMensaje;

			IF vCodRet <> "00000" THEN
			   --ROLLBACK WORK;
			   RETURN vCodRet, vMensaje;
			END IF;
		ELSE 
			EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 5,
									'124', vHoy, vIntVencBalanza, vFolio, vSucursal,
									vdivisa, "0000", "BAJA DE LOS INTERESES DE BALANZA VENCIDOS", " ") 
									INTO vCodRet, vMensaje;

		   IF vCodRet <> "00000" THEN
			  --ROLLBACK WORK;
			  RETURN vCodRet, vMensaje;
		   END IF;
		   
			EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 6,
									'124', vHoy, vIvaIntVencBalanza, vFolio, vSucursal,
									vdivisa, "0000", "BAJA DEL IVA SOBRE INTERESES DE BALANZA VENCIDOS", " ") 
									INTO vCodRet, vMensaje;

			IF vCodRet <> "00000" THEN
			   --ROLLBACK WORK;
			   RETURN vCodRet, vMensaje;
			END IF;
		END IF;
		END IF;

       
	   
       LET vMtoTotal = vMtoTotal + vIntVencTrasp;

		IF vIntVencOrdinario > 0 THEN
		 IF  vstatus_cnr =  'E2' THEN  --IFRS	
			 EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 23,
									'124', vHoy, vIntVencOrdinario, vFolio, vSucursal,
									vdivisa, "0000", "BAJA DE LOS INTERESES ORINARIOS VENCIDOS", " ") 
									INTO vCodRet, vMensaje;

		   IF vCodRet <> "00000" THEN
			  --ROLLBACK WORK;
			  RETURN vCodRet, vMensaje;
		   END IF;
		   
			EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 24,
									'124', vHoy, vIvaIntVencOrdinario, vFolio, vSucursal,
									vdivisa, "0000", "BAJA DEL IVA SOBRE INTERESES ORDINARIOS VENCIDOS", " ") 
									INTO vCodRet, vMensaje;

			IF vCodRet <> "00000" THEN
			   --ROLLBACK WORK;
			   RETURN vCodRet, vMensaje;
			END IF;
		 ELSE
			EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 3,
									'124', vHoy, vIntVencOrdinario, vFolio, vSucursal,
									vdivisa, "0000", "BAJA DE LOS INTERESES ORINARIOS VENCIDOS", " ") 
									INTO vCodRet, vMensaje;

		   IF vCodRet <> "00000" THEN
			  --ROLLBACK WORK;
			  RETURN vCodRet, vMensaje;
		   END IF;
		   
			EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 4,
									'124', vHoy, vIvaIntVencOrdinario, vFolio, vSucursal,
									vdivisa, "0000", "BAJA DEL IVA SOBRE INTERESES ORDINARIOS VENCIDOS", " ") 
									INTO vCodRet, vMensaje;

			IF vCodRet <> "00000" THEN
			   --ROLLBACK WORK;
			   RETURN vCodRet, vMensaje;
			END IF;
		 END IF;
		END IF;

        LET vMtoTotal = vMtoTotal + vIvaIntVencTrasp;
    END IF;

--    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Iva de Interes Vencido Segun Corresponda
   -- IF vIvaIntVencTrasp > 0 then
/*       EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 6,
                                '124', vHoy, vIvaIntVencTrasp, vFolio, vSucursal,
                                vdivisa, "0000", "BAJA DEL IVA SOBRE INTERESES DE BALANZA VENCIDOS", " ") 
								INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;*/
      

      
  --   END IF;

--    LET vMtoTotal = vMtoTotal;
     -- Liquida el Interes Transitorio
     IF vIntVenc > 0 then
         EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 0,
                                  '124', vHoy, vIntVenc, vFolio, vSucursal,
                                  vdivisa, "0000", " ", " ") 
								  INTO vCodRet, vMensaje;

         IF vCodRet <> "00000" THEN
            --ROLLBACK WORK;
            RETURN vCodRet, vMensaje;
         END IF;
         LET vMtoTotal = vMtoTotal + vIntVenc;
     END IF;

--    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Iva de Interes Vencido Transitorio Segun Corresponda
    IF vIvaIntVenc > 0 then
       EXECUTE PROCEDURE genmovcrd(P_EMPRESA, vNumCredOld, vNumProducto, 0,
                                '124', vHoy, vIvaIntVenc, vFolio, vSucursal,
                                vdivisa, "0000", " ", " ") 
								INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
           --ROLLBACK WORK;
           RETURN vCodRet, vMensaje;
        END IF;
        LET vMtoTotal = vMtoTotal + vIvaIntVenc;
    END IF;

--    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Interes Moratorio Segun Corresponda
    IF vMora > 0 then
        EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 12,
                                 '124', vHoy, vMora, vFolio, vSucursal,
                                 vdivisa, "0000", "BAJA DE INTERESES MORATORIOS BASE", " ") 
								 INTO vCodRet, vMensaje;

        IF vCodRet <> "00000" THEN
          --ROLLBACK WORK;
          RETURN vCodRet, vMensaje;
        END IF;
        LET vMtoTotal = vMtoTotal + vMora;
    END IF ;

--    LET vMtoTotal = vMtoTotal;
    -- Liquida o Traspasa el Iva Interes Moratorio

    IF vIvaMtoOrdi > 0 THEN
       EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 13,
                             '124', vHoy, vIvaMtoOrdi, vFolio, vSucursal,
                             vdivisa, "0000", "BAJA DE IVA SOBRE INTERES MORATORIO BASE", " ") 
							INTO vCodRet, vMensaje;
							
     IF vCodRet <> "00000" THEN
       RETURN vCodRet, vMensaje;
     END IF;
     LET vMtoTotal = vMtoTotal + vIvaMtoOrdi;
   END IF;

--    LET vMtoTotal = vMtoTotal;

	IF vNumProducto = '6800' THEN
   EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 11,
                            '124', vHoy, vLimite_aut, vFolio, vSucursal,
                            vdivisa, "0000", "CANCELACION(BAJA) DE PRESTAMO", " ") 
							INTO vCodRet, vMensaje;

   IF vCodRet <> "00000" THEN
      --ROLLBACK WORK;
      RETURN vCodRet, vMensaje;
	ELSE
		
		UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = vHoy, cancel_pf = '1', fecha_ult_pf = vHoy WHERE num_credito = vNumCredOld;
   END IF;
   END IF;

   -- BGM 25-May-10 Se cambia el orden para obtener los intereses transcurridos, de modo que se incluyan en el total de la baja
   -- para el movimiento no contable codigo fun = '001' y codigo_ref = '4'
   
   select sdo_intereses into vinteresvend
   --from sd_maesdos_vendida
   from sd_maesdoscrd_vendida
    WHERE empresa     = p_empresa
         AND num_credito = vNumCredOld;
   if vinteresvend is null then let vinteresvend = 0; end if;

   if vinteresvend > 0 then
    select tasa_interes,fecha_apertura
      into vtasa,vfecaper
      from "informix".sd_maecredcrd
      WHERE empresa     = p_empresa
         AND num_credito = vNumCredOld;
      select fecha_hoy into vhoy
        from sd_fechas;
     SELECT max(fecha_cuota)
	INTO vfecuota
	FROM bdicred: "informix".sd_amortiza_creditocrd -- IFSR revisar este caso
     WHERE empresa     = p_empresa
         AND num_credito = vNumCredOld
    	  AND capital_status = '1';
      call calc_iva_grav_pp(p_empresa,vNumCredOld,vtasa,vIvaSuc,vHoy,null,
          vfecaper,vfecuota,vinteresvend)
       returning    vCodRet,vivavend,vMensaje;
      IF vinteresvend > 0 THEN
             EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 3,
                                   "124", vHoy, vinteresvend, vFolio, vSucursal,
                                   vdivisa, "0000", "BAJA DE INTERESES ORDINARIOS VENCIDOS", " ") 
								  INTO vCodRet, vMensaje;
								  
           IF vCodRet <> "00000" THEN
             RETURN vCodRet, vMensaje;
      END IF;
      LET vMtoTotal = vMtoTotal + vinteresvend;
     END IF;
     IF vivavend > 0 THEN
            EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, 4,
                                  "124", vHoy, vivavend, vFolio, vSucursal,
                                  vdivisa, "0000", "BAJA DEL IVA SOBRE INTERESES ORDINARIOS VENCIDOS", " ") 
								  INTO vCodRet, vMensaje;
								 
          IF vCodRet <> "00000" THEN
            RETURN vCodRet, vMensaje;
          END IF;
          LET vMtoTotal = vMtoTotal + vivavend;
     END IF;

   end if
   
--    LET vMtoTotal = vMtoTotal;
   IF vLimite_aut > 0 then
      EXECUTE PROCEDURE genmovcrd(p_empresa, vNumCredOld, vNumProducto, '10',
                               '124', vHoy, vMtoTotal, vFolio, vSucursal,
                               vdivisa, "0000", "TOTAL LIQUIDACION PP POR REESTRUCTURA", " ") 
							   INTO vCodRet, vMensaje;

      IF vCodRet <> "00000" THEN
         RETURN vCodRet, vMensaje;
      END IF;

   END IF;

--    LET vMtoTotal = vMtoTotal;
      UPDATE sd_amortiza_creditocrd SET capital_pagado = capital_debe,
       	capital_status = "5", capital_status_ant = capital_status
      WHERE num_credito = vNumCredOld
        AND empresa = p_empresa
        AND capital_status <> "5";

     UPDATE sd_amortiza_creditocrd SET interes_pagado = interes_debe,
         interes_status = "5", interes_status_ant = interes_status
     WHERE num_credito = vNumCredOld
       AND empresa = p_empresa
       AND interes_status <> "5";


     UPDATE sd_maesdoscrd
        SET  sdo_no_exig       = 0,
             sdo_exig_int      = 0,
             sdo_moratorio     = 0,
             sdo_capital       = 0,
             sdo_cap_insoluto  = 0,
             monto_vencido     = 0,
             mto_venc_trasp    = 0,
             mto_venc_int      = 0,
             mto_venc_tra_int  = 0,
             sdo_global_int    = 0,
             sdo_intereses     = 0,
             cap_tras_no_venci = 0,
             int_tra_no_exig   = 0,
             monto_financiado  = 0
       WHERE num_credito = vNumCredOld
         AND empresa = p_empresa ;

     UPDATE sd_maecredcrd SET status_cred = "FC"
      WHERE num_credito = vNumCredOld
        AND empresa = p_empresa ;

  --**Cancelacion de Tarjeta de Credito

	LET vcadena = length(vFolio) - 8;
	LET v_usuario    = substr(vFolio,1,vcadena);

END PROCEDURE
DOCUMENT
'Folio: 686',
'RQM 09 546 Reestructura PrÃÂÃÂÃÂÃÂ©stamo Personal',
'Autor: 97879606 AdriÃÂÃÂÃÂÃÂ¡n Eduardo LizÃÂÃÂÃÂÃÂ¡rraga CÃÂÃÂÃÂÃÂ¡zares',
'BD: bdicred',
'Fecha: 2020/10/06',
'DescripciÃÂÃÂÃÂÃÂ³n: Se genera un clon del sp proyecta para poder reestructurar los prÃÂÃÂÃÂÃÂ©stamos personales agregandoles periodo de gracia.',
'SolicitÃÂÃÂÃÂÃÂ³: Ricardo Sanchez';

CREATE PROCEDURE "informix".sp_obtener_pagomin(pEmpresa      CHAR(3),
                                               pNumCredito   CHAR(20))
RETURNING CHAR(6)       AS codigo_retorno,
          CHAR(80)      AS mensaje_retorno,
          DECIMAL(18,2) AS pago_minimo,
          DECIMAL(18,2) AS IntVdo,
          DECIMAL(18,2) AS IntMoratorio,
          DECIMAL(18,2) AS IvaIntVdo,
          DECIMAL(18,2) AS PagosVdos,
          DECIMAL(18,2) AS IvaIntMoratorio,
          DECIMAL(18,2) AS IntMes,
          DECIMAL(18,2) AS IvaIntMes,
          DECIMAL(18,2) AS IntVig,
          DECIMAL(18,2) AS IvaIntVig
            
          

DEFINE codigo_retorno    CHAR(6);
DEFINE mensaje_retorno   CHAR(80);
DEFINE numero_credito    CHAR(20);
DEFINE nrows             INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(6);
DEFINE cMensajeRet       CHAR(80);

DEFINE cEmpresa          CHAR(3);
DEFINE cNumCte           CHAR(20);
DEFINE cNumCredito       CHAR(20);
DEFINE cCodTipCred       CHAR(2);
DEFINE cNumTarjeta       CHAR(20);
DEFINE cDescStatusCred   CHAR(60);

DEFINE cSucursal         CHAR(4);
DEFINE iIdUnidadProd     INTEGER;
DEFINE cCodCaract2       CHAR(3);
DEFINE dMontoFinanciado  DECIMAL(18,2);
DEFINE dIvaSuc           DECIMAL(5,3);

DEFINE dtFechaOrigen     DATE;
DEFINE dtFechaProxPago   DATE;
DEFINE dPagoMinimo       DECIMAL(18,2);
DEFINE dtFechaUltPago    DATE;
DEFINE iPlazo            INTEGER;
DEFINE iPagosRealizados  INTEGER;
DEFINE dLineaOtorgada    DECIMAL(18,2);

DEFINE dTasaInteres      DECIMAL(9,6);
DEFINE dTasaMoratorios   DECIMAL(9,6);
DEFINE dMontoSBC         DECIMAL(14,2);

DEFINE dCapVig           DECIMAL(18,2);
DEFINE dCapTrans         DECIMAL(18,2);
DEFINE dCapVdoExig       DECIMAL(18,2);
DEFINE dCapVdoNoExig     DECIMAL(18,2);
DEFINE dSdoActCap        DECIMAL(18,2);

DEFINE dIntVig           DECIMAL(18,2);
DEFINE dIntVdo           DECIMAL(18,2);
DEFINE dIntMoratorio     DECIMAL(18,2);
DEFINE dIntMoratorio_d	 DECIMAL(18,2);
DEFINE dIntMes           DECIMAL(18,2);
DEFINE dSdoActInt        DECIMAL(18,2);

DEFINE dIvaIntVig        DECIMAL(18,2);
DEFINE dIvaIntVdo        DECIMAL(18,2);
DEFINE dIvaIntMoratorio  DECIMAL(18,2);
DEFINE dIvaIntMes        DECIMAL(18,2);
DEFINE dSdoActIvaInt     DECIMAL(18,2);

DEFINE dComPend          DECIMAL(18,2);
DEFINE dIvaCom           DECIMAL(18,2);
DEFINE dSdoRetenido      DECIMAL(18,2);
DEFINE dSdoTotalLiq      DECIMAL(18,2);

DEFINE dtIvaFechaPag         DATE;
DEFINE dtFechaCuota          DATE;
DEFINE dIntDevengado         DECIMAL(18,2);
DEFINE dIvaIntDevengado      DECIMAL(18,2);
DEFINE dLineaDisponible      DECIMAL(18,2);
DEFINE dPagosVdos            DECIMAL(18,2);

DEFINE cDescBloqueoCta       CHAR(60);
DEFINE cDescCausaBloqueoCta  CHAR(50);
DEFINE cSitCte               CHAR(1);
DEFINE cCausaCte             INTEGER;
DEFINE cDescSitEspCte        CHAR(75);
DEFINE cSitCred              CHAR(1);
DEFINE cCausaCred            INTEGER;
DEFINE cDescSitEspCred       CHAR(75);
DEFINE dFactorComision       DECIMAL(18,2);
DEFINE dtMesiversario        DATE;
DEFINE dtFechaHoy            DATE;
DEFINE cTipCred              CHAR(2);

--FMV 01-Sep-11: Se adicionan el indicador y transaccion de la comision de Credinomina
DEFINE cind_comision   CHAR(1);
DEFINE ctran_comision  CHAR(4);
DEFINE vRetCs_acum     DECIMAL(18,2);
DEFINE cTablaConsulta  CHAR(01);

LET nrows                = 0;
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = '';
LET cCodRet              = '';
LET cMensajeRet          = '';

LET cEmpresa             = '';
LET cNumCte              = '';
LET cNumCredito          = '';
LET cCodTipCred          = '';
LET cNumTarjeta          = '';
LET cDescStatusCred      = '';

LET cSucursal             = '';
LET iIdUnidadProd         = 0;
LET cCodCaract2           = '';
LET dMontoFinanciado      = 0;
LET dIvaSuc               = 0;

LET dtFechaOrigen         = DATE(1);
LET dtFechaProxPago       = DATE(1);
LET dPagoMinimo           = 0;
LET dtFechaUltPago        = DATE(1);
LET iPlazo                = 0;
LET iPagosRealizados      = 0;
LET dLineaOtorgada        = 0;

LET dTasaInteres          = 0;
LET dTasaMoratorios       = 0;
LET dMontoSBC             = 0;

LET dCapVig               = 0;
LET dCapTrans             = 0;
LET dCapVdoExig           = 0;
LET dCapVdoNoExig         = 0;
LET dSdoActCap            = 0;

LET dIntVig               = 0;
LET dIntVdo               = 0;
LET dIntMoratorio         = 0;
LET dIntMoratorio_d       = 0;
LET dIntMes               = 0;
LET dSdoActInt            = 0;

LET dIvaIntVig            = 0;
LET dIvaIntVdo            = 0;
LET dIvaIntMoratorio      = 0;
LET dIvaIntMes            = 0;
LET dSdoActIvaInt         = 0;

LET dComPend              = 0;
LET dIvaCom               = 0;
LET dSdoRetenido          = 0;
LET dSdoTotalLiq          = 0;

LET dtIvaFechaPag         = DATE(1);
LET dtFechaCuota          = DATE(1);
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
LET dLineaDisponible      = 0;
LET dPagosVdos            = 0;

LET cDescBloqueoCta       = '';
LET cDescCausaBloqueoCta  = '';
LET cSitCte               = '';
LET cCausaCte             = 0;
LET cDescSitEspCte        = '';
LET cSitCred              = '';
LET cCausaCred            = 0;
LET cDescSitEspCred       = '';
LET dFactorComision       = 0;
LET dtMesiversario        = DATE(1);
LET dtFechaHoy            = DATE(1);
LET cTipCred              = '';
LET cind_comision         = '';
LET ctran_comision        = '';
LET vRetCs_acum           = 0;
LET codigo_retorno        = '';
LET mensaje_retorno       = '';
LET cTablaConsulta        = '0';


--SET DEBUG FILE TO '/tmp/sp_consulta_saldos_general.out'; --- MODIFICAR RUTA DEL ARCHIVO
--TRACE ON;

 BEGIN

 ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = 'OcurriÃÂ³ error al consultar los saldos'||' - '||cErrorInfo;
      RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
    END IF;
 END EXCEPTION;

 LET cCodRet      = '000000';
 LET cMensajeRet  = 'Consulta pago mÃÂ­nimo correcta.';

 IF NVL(pEmpresa,'') = '' THEN
   LET pEmpresa = NULL;
   LET cEmpresa= '';
 ELSE
   LET cEmpresa= TRIM(pEmpresa);
 END IF;

 IF NVL(pNumCredito,'') = '' THEN
   LET pNumCredito = NULL;
   LET cNumCredito= '';
 ELSE
   LET cNumCredito = TRIM(pNumCredito);
 END IF;

 IF pEmpresa IS NULL AND pNumCredito IS NULL THEN
    LET cCodRet= '000001';
    LET cMensajeRet= 'No hay informaciÃÂ³n para realizar la consulta';
    RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig; 
 END IF;

 SET ISOLATION TO dirty READ;

  SELECT fecha_hoy
    INTO dtFechaHoy
    FROM "informix".sd_fechas
   WHERE empresa = pEmpresa;

  SELECT b.cod_prod
    INTO cTipCred
    FROM bdicred:sd_maecred a,
         bdicred:sd_tipprod b
   WHERE a.num_credito = cNumCredito
     AND a.empresa=pEmpresa
     AND a.empresa=b.empresa
     AND a.num_producto=b.abrevia_prod;

    IF cTipCred IS NULL OR cTipCred = '' THEN
          SELECT b.cod_prod
            INTO cTipCred
            FROM bdicred:sd_maecred_old a,
                 bdicred:sd_tipprod b
           WHERE a.num_credito = cNumCredito
             AND a.empresa=pEmpresa
             AND a.empresa=b.empresa
             AND a.num_producto=b.abrevia_prod;
             
			IF cTipCred IS NOT NULL THEN
				LET cTablaConsulta = '1'; 
			END IF;
    END IF;  		   

  IF cTipCred IS NULL OR cTipCred = '' THEN
       SELECT b.cod_prod
          INTO cTipCred
          FROM bdicred:sd_maecredcrd a,
               bdicred:sd_tipprod b
         WHERE a.num_credito = cNumCredito
           AND a.empresa=pEmpresa
           AND a.empresa=b.empresa
           AND a.num_producto=b.abrevia_prod;
        
         IF cTipCred IS NULL THEN
            LET cCodRet= '000002';
            LET cMensajeRet= 'No hay informaciÃÂ³n para realizar la consulta';
            RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig; 
        END IF;
  END IF; 
 
  IF cTipCred='T' THEN

    IF cTablaConsulta = '0' THEN
      SELECT a.sucursal
        INTO cSucursal
        FROM "informix".sd_maecred a
       WHERE a.num_credito  = cNumCredito
  		   AND a.empresa      = cEmpresa;
  		   
  		SELECT
  			   NVL(monto_financiado,0)
  		  INTO dMontoFinanciado
  		  FROM "informix".sd_maesdos
  		 WHERE num_credito = cNumCredito
  		   AND empresa     = cEmpresa;
    ELSE
      SELECT a.sucursal
        INTO cSucursal
        FROM "informix".sd_maecred_old a
       WHERE a.num_credito  = cNumCredito
  		   AND a.empresa      = cEmpresa;
  		   
  		SELECT
  			   NVL(monto_financiado,0)
  		  INTO dMontoFinanciado
  		  FROM "informix".sd_maesdos_old
  		 WHERE num_credito = cNumCredito
  		   AND empresa     = cEmpresa;
    END IF;  
    
  		SELECT iva
  		  INTO dIvaSuc
  		  FROM bdinteg:"informix".si_sucursales
  		 WHERE sucursal = cSucursal
  		   AND empresa  = cEmpresa;
  
--        IF cTablaConsulta = '0' THEN
            SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
                   SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
                   SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),
                   COUNT(num_credito)
              INTO dIntVdo,
                   dIntMoratorio,
                   dIvaIntVdo,
                   dPagosVdos
              FROM "informix".sd_amortiza_credito
             WHERE empresa     = cEmpresa
               AND num_credito = cNumCredito
               AND capital_status IN ('2','7','6');
/*        ELSE
                    SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
                   SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
                   SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),
                   COUNT(num_credito)
              INTO dIntVdo,
                   dIntMoratorio,
                   dIvaIntVdo,
                   dPagosVdos
              FROM "informix".sd_amortiza_credito_old
             WHERE empresa     = cEmpresa
               AND num_credito = cNumCredito
               AND capital_status IN ('2','7');
        END IF;*/

--    IF cTablaConsulta = '0' THEN
  		FOREACH
  			SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* dIvaSuc ))
  			INTO dIntMoratorio_d
  			FROM sd_amortiza_credito a
  			WHERE a.empresa   = cEmpresa
  			AND a.num_credito = cNumCredito
  			AND capital_status IN ("2","7","6")
  
  			LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;
  
  		END FOREACH;
/*  	ELSE
  		FOREACH
  			SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* dIvaSuc ))
  			INTO dIntMoratorio_d
  			FROM sd_amortiza_credito_old a
  			WHERE a.empresa   = cEmpresa
  			AND a.num_credito = cNumCredito
  			AND capital_status IN ("2","7")
  
  			LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;
  
  		END FOREACH;
  	END IF;*/
      
      
		   LET dPagoMinimo      = NVL(dMontoFinanciado,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);

  ELIF cTipCred  in ('P','R') THEN
       SELECT a.sucursal
  		   INTO cSucursal
  		   FROM "informix".sd_maecredcrd a
  		  WHERE a.num_credito  = cNumCredito
  		    AND a.empresa  = cEmpresa;
  
  		LET nrows = DBINFO("sqlca.sqlerrd2");
  		IF nrows  = 0 THEN
  		    LET cCodRet     = '000004';
  		    LET cMensajeRet = 'El nÃÂºmero de crÃÂ©dito no existe';
   		    RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig;
  
  		END IF;
  
      IF cTipCred='R' THEN
         LET dTasaMoratorios=0;
      END IF;
  
  		SELECT iva
  		  INTO dIvaSuc
  		  FROM bdinteg:"informix".si_sucursales
  		 WHERE sucursal = cSucursal
  		   AND empresa  = cEmpresa;
  
      --          CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInteres,dIvaSuc,dtFechaHoy,
      --                                           dtIvaFechaPag,dtFechaOrigen,dtFechaCuota,dIntDevengado) RETURNING cCodRet,dIvaIntDevengado,cMensajeRet;
      --          IF cCodRet <> "000000" THEN
      --                LET cCodRet      = '000005';
      --                LET cMensajeRet  = 'OcurriÃÂ³ un error al realizar calculo';
      --    				    RETURN cCodRet, cMensajeRet, NVL(dPagoMinimo,0), dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio;
      --          END IF;
  
    SELECT NVL(monto_financiado,0)
      INTO dMontoFinanciado
      FROM "informix".sd_maesdoscrd
		 WHERE num_credito = cNumCredito
		   AND empresa     = cEmpresa;
          
 
  		-- 2011-11-30 Se realiza cambio en calculo de IVA moratorio
  		SELECT SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),
  		       SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
  			   SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),
  		       COUNT(num_credito)
  		  INTO dIntVdo,
  		       dIntMoratorio,
   			   dIvaIntVdo,
  		       dPagosVdos
  		  FROM "informix".sd_amortiza_creditocrd
  		 WHERE empresa     = cEmpresa
  		   AND num_credito = cNumCredito
  		   AND capital_status IN ('2','7','6');

        FOREACH
  			SELECT ((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))* dIvaSuc )
  			  INTO dIntMoratorio_d
  			  FROM sd_amortiza_creditocrd a
  			 WHERE a.empresa   = cEmpresa
  			   AND a.num_credito = cNumCredito
  			   AND capital_status IN ('2','7','6')
  
  			LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;
  
  		END FOREACH;
  		
  		   LET dPagoMinimo = NVL(dMontoFinanciado,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);
 
  		   SELECT 0,
                0,
                NVL(SUM(NVL(interes_debe - interes_pagado,0)),0),
                NVL(SUM(NVL(iva_debe - iva_pagado,0)),0)
  		     INTO dIntMes,
  		          dIvaIntMes,
  		          dIntVig,
  		          dIvaIntVig
               FROM "informix".sd_amortiza_creditocrd
              WHERE empresa        = cEmpresa
                AND num_credito    = cNumCredito
                AND capital_status = 1;
  
  		     LET dSdoActInt    = NVL(dIntVig,0) + NVL(dIntVdo,0) + NVL(dIntMoratorio,0);
  		     LET dSdoActIvaInt = NVL(dIvaIntVig,0) + NVL(dIvaIntVdo,0) + NVL(dIvaIntMoratorio,0);
  
  			 LET dPagoMinimo = dPagoMinimo + NVL(dIntVig,0) + NVL(dIvaIntVig,0);
 

END IF;

  /* RETURN cCodRet, cMensajeRet, cNumCredito, NVL(cCodTipCred,''),NVL(dtFechaOrigen,DATE(1)), NVL(dtFechaProxPago,DATE(1)),
          NVL(dPagoMinimo,0), NVL(dtFechaUltPago,DATE(1)), NVL(iPlazo,0), NVL(iPagosRealizados,0), NVL(dLineaOtorgada,0),
          NVL(dTasaInteres,0), NVL(dTasaMoratorios,0), NVL(dMontoSBC,0), NVL(dCapVig,0), NVL(dCapTrans,0), NVL(dCapVdoExig,0),
          NVL(dCapVdoNoExig,0), NVL(dSdoActCap,0), NVL(dIntVig,0), NVL(dIntVdo,0), NVL(dIntMoratorio,0), NVL(dIntMes,0),
          NVL(dSdoActInt,0), NVL(dIvaIntVig,0), NVL(dIvaIntVdo,0), NVL(dIvaIntMoratorio,0), NVL(dIvaIntMes,0), NVL(dSdoActIvaInt,0),
          NVL(dComPend,0), NVL(dIvaCom,0), NVL(dSdoRetenido,0), NVL(dSdoTotalLiq,0), NVL(dIntDevengado,0),NVL(dIvaIntDevengado,0), NVL(dLineaDisponible,0),
          NVL(dPagosVdos,0), NVL(cDescStatusCred,''), NVL(iIdUnidadProd,0), NVL(TRIM(cDescBloqueoCta),''), NVL(cCodCaract2,''),
          NVL(TRIM(cDescCausaBloqueoCta),''), NVL(cSitCte,''), NVL(cCausaCte,0), NVL(TRIM(cDescSitEspCte),''), NVL(cSitCred,''),
          NVL(cCausaCred,0), NVL(TRIM(cDescSitEspCred),'');
  */

 RETURN cCodRet, cMensajeRet, dPagoMinimo, dIntVdo, dIntMoratorio, dIvaIntVdo, dPagosVdos, dIvaIntMoratorio, dIntMes, dIvaIntMes, dIntVig, dIvaIntVig; 
   
   
END
END PROCEDURE
DOCUMENT
'AUTOR : Marco A. Campos',
'FECHA : 20/05/2014',
'BD    : BDICRED';

CREATE PROCEDURE "informix".genmov_ifrs(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_codigo_ref             INTEGER,
   p_codigo_fun             VARCHAR(3),
   p_fecha_hoy              DATE,
   p_monto                  MONEY(14,2),
   p_foliosuc               VARCHAR(16),
   p_sucursal               VARCHAR(4),
   p_divisa                 VARCHAR(2),
   p_transacc_suc           VARCHAR(4))
RETURNING VARCHAR(10), VARCHAR(80);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE   v_plaza         VARCHAR(3);
DEFINE   v_hora          DATETIME HOUR TO FRACTION(3);
DEFINE   vm_secuencia    INTEGER;
DEFINE   v_reversado     VARCHAR(1);
DEFINE   v_usuario       VARCHAR(8);

DEFINE   v_num_producto  VARCHAR(4);
DEFINE   v_codigo_ref    INTEGER;
DEFINE   v_codigo_fun    VARCHAR(3);
DEFINE   v_fecha_hoy     DATE;
DEFINE   v_monto         DECIMAL(18,2);
DEFINE   v_foliosuc      VARCHAR(16);
DEFINE   v_sucursal      VARCHAR(4);
DEFINE   v_divisa        VARCHAR(2);
DEFINE   v_transacc_suc  VARCHAR(4);

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vcadena     INTEGER;
DEFINE vSucOri     CHAR(4);

DEFINE   vCodFunIFRS     CHAR(3);
DEFINE   vCodRefIFRS     SMALLINT;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;

   LET P_COD_RET      = '00000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET v_num_producto =  p_num_producto ;
   LET v_codigo_ref   =  p_codigo_ref   ;
   LET v_codigo_fun   =  p_codigo_fun   ;
   LET v_fecha_hoy    =  p_fecha_hoy    ;
   LET v_monto        =  p_monto        ;
   LET v_foliosuc     =  p_foliosuc     ;
   LET v_sucursal     =  p_sucursal     ;
   LET v_divisa       =  p_divisa       ;
   LET v_transacc_suc =  p_transacc_suc ;
   LET vCodFunIFRS    =  '';
   LET vCodRefIFRS    =  '';

   IF (p_transacc_suc IS NULL) THEN
      LET v_transacc_suc = '0000';
   END IF;

   IF (v_fecha_hoy IS NULL) THEN
      SELECT fecha_hoy
      INTO   v_fecha_hoy
      FROM   sd_fechas;
   END IF;
   IF (v_monto IS NULL) THEN
      LET v_monto = 0;
   END IF;
   IF (v_divisa IS NULL) THEN
      LET v_divisa = '00';
   END IF;
   IF (v_num_producto IS NULL) THEN
      LET v_num_producto = '    ';
   END IF;

   IF (v_foliosuc IS NULL) THEN
      LET p_cod_ret = '110';
      LET P_MENSAJE = 'ERROR';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   LET p_cod_ret    = '00000';
   LET P_MENSAJE    = 'PROCESO EXITOSO';
   LET v_hora       = EXTEND(CURRENT,HOUR TO fraction(3));

   LET v_reversado  = 'N';
--   v_usuario    := USER;


   LET vcadena = 0;

   let vcadena = length(p_foliosuc) - 8;
   LET v_usuario    = substr(p_foliosuc,1,vcadena);

--   LET v_usuario    = substr(v_foliosuc,1,8);

   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################

   SELECT plaza
   INTO   v_plaza
   FROM   bdinteg:si_sucursales
   WHERE  empresa  = p_empresa
   AND    sucursal = v_sucursal;

   IF V_PLAZA IS NULL OR V_PLAZA = '' THEN
      LET P_COD_RET = '00100';
      LET P_MENSAJE = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
      RETURN P_COD_RET, P_MENSAJE;
   END IF;

   SELECT sucursal INTO vSucOri
     FROM sd_maecred
    WHERE empresa = p_empresa
      AND num_credito = p_num_credito;

   /*SELECT codigo_fun_ifrs, codigo_ref_ifrs
	INTO vCodFunIFRS, vCodRefIFRS
       FROM sd_transfun
      WHERE empresa = p_empresa
	AND codigo_fun = v_codigo_fun
   AND codigo_ref = v_codigo_ref;

   IF ((vCodFunIFRS IS NOT NULL) AND (vCodRefIFRS IS NOT NULL)) THEN 
      LET v_codigo_fun = vCodFunIFRS;
      LET v_codigo_ref = vCodRefIFRS;
   END IF;*/

   INSERT INTO sd_movdia_ifrs (
               EMPRESA        ,
               FECHA_MOV      ,
               HORA_MOV       ,
               SUCURSAL       ,
               NUM_CREDITO    ,
               PLAZA          ,
               TRANSACC_SUC   ,
               USUARIO        ,
               MONTO          ,
               CODIGO_FUN     ,
               CODIGO_REF     ,
               DIVISA         ,
               REVERSADO      ,
               FOLIO_SUC      ,
               NUM_PRODUCTO   ,
	       SUC_ORIGEN     )
      VALUES ( p_empresa,
               v_fecha_hoy,
               current,
               v_sucursal,
               p_num_credito,
               v_plaza,
               v_transacc_suc,
               v_usuario,
               v_monto,
               v_codigo_fun,
               v_codigo_ref,
               v_divisa,
               v_reversado,
               v_foliosuc,
               v_num_producto,
	       vSucOri);

   RETURN P_COD_RET, P_MENSAJE;

END;
END PROCEDURE;