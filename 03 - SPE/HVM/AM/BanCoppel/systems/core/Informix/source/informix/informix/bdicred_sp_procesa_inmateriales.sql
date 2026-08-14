CREATE PROCEDURE "informix".sp_procesa_inmateriales(pEmpresa CHAR(3),pTpSol CHAR(1), pNumCredito CHAR(20),pNumcte CHAR (20))
returning char (6);



DEFINE cNumCredito                  Char(20);
DEFINE cNumProducto                 Char(4);
DEFINE dFecha                       Date;
DEFINE dpri_dia_mes					Date;
DEFINE vFechaVencCred               Date;
DEFINE ddia_corte				char(2);
DEFINE cFolio                       Char(16);
DEFINE cSucursal                    Char(4);
DEFINE cDivisa                      Char(2);
DEFINE vPeriodicidad                Char(1);
DEFINE vCalif_Riesgo                Char(2);
DEFINE vMontoLineaNoDispuesta       Decimal(16,2);
DEFINE vMontoVencidoExigible        Decimal(16,2);
DEFINE vMontoVencidoNoExigible      Decimal(16,2);
DEFINE vMontoVencidoPorCobrar       Decimal(14,2);
DEFINE vMontoReservado              Decimal(16,2);
DEFINE vCapitalVig                  Money(14,2);
DEFINE vCapitalVen                  Money(14,2);
DEFINE vmontodisp                   Money(14,2);
--DEFINE pFecha                       Date;
DEFINE vCredito                     Char(20);
DEFINE vTotal                       Money(16,2);
DEFINE vPeriodo                     Char(1);
DEFINE vNum_Periodo                 Smallint;
DEFINE vInteres_venc                Money(16,2);
DEFINE vGrado                       Char(2);
DEFINE vProducto                    Char(4);
DEFINE vSucursal                    Char(4);
DEFINE vDivisa                      Char(2);
DEFINE vIntMora                     Decimal(14,2);
DEFINE vIvaIntMora                  Decimal(14,2);
DEFINE vPorcIva                     Decimal(14,2);
DEFINE vPorcIva_rees                Decimal(14,2);
DEFINE vImporteReserva              Money(16,2);
DEFINE vPorcentajeReserva           Decimal(14,2);
DEFINE vGrado_Aplicar               Char(2);
DEFINE vCalificacion                Char(2);
DEFINE vMontoExigyNoExig            Decimal(16,2);
DEFINE cEvaluaCC                    Char(1);
DEFINE vImporteReservaBuroCC        Money(16,2);
DEFINE vNvoPeriodo                  Smallint;
DEFINE vNvoPeriodo2                 Smallint;
DEFINE vNvoPeriodo3                 Smallint;
DEFINE vfechaini                    Date;
--DEFINE vfechafin                    Date;
DEFINE vcuotasvenc                  smallint;
DEFINE vtotal_dias                  smallint;
DEFINE vtotal_capitalizado          Money(16,2);
DEFINE vmonto_capitalizado          Money(16,2);
DEFINE vMontoCompara                Money(16,2);
DEFINE vcodigo_ref                  INTEGER;
DEFINE fechafinmesant               DATE;
DEFINE vencifinmes                  SMALLINT;
DEFINE vtarjeta                     CHAR(20);
DEFINE cproduto                     VARCHAR(3);

DEFINE CodRet              CHAR(5);
DEFINE Mensaje             CHAR(80);
DEFINE sql_err             SMALLINT;
DEFINE isam_err            SMALLINT;
DEFINE error_info          CHAR(40);
DEFINE cErrorInfo          CHAR(40);
DEFINE nRows               SMALLINT;

--- variables para procesar reestructuras SDFM 22/02/2012
DEFINE vMontoVencidoExigible_rees DECIMAL(16,2);
DEFINE vMontoVencidoNoExigible_rees DECIMAL(16,2);
DEFINE vInteresVencido DECIMAL(16,2);
DEFINE vInteresVencido_rees DECIMAL(16,2);
DEFINE vInteresVencido_ant DECIMAL(16,2);
DEFINE vIvaInteresVencido DECIMAL(16,2);
DEFINE vIvaInteresVencido_rees DECIMAL(16,2);
DEFINE vIvaInteresVencido_ant DECIMAL(16,2);
DEFINE vCapitalVig_rees DECIMAL(16,2);
DEFINE vCapitalVen_rees DECIMAL(16,2);
DEFINE cStatusCred          CHAR(02);
define dproxfechapago, dfechaproceso date;
DEFINE dfecha_vencto61 DATE;
DEFINE dfecha_vencto63 DATE;

-- VARIABLES PARA CACHA LOS CAMPOS DEL PROCESO QUE GENERA EL FOLIO
DEFINE cCodRetGF			CHAR(6);
DEFINE cFolioSuc			CHAR(16);
DEFINE dIntMoratorio     DECIMAL(18,2);
DEFINE dIntMoratorio_d	 DECIMAL(18,2);
DEFINE dIvaIntMoratorio  DECIMAL(18,2);
DEFINE dIvaSuc DECIMAL(5,3);

DEFINE psaldoInteresTrasApoyo DECIMAL(14,2);
DEFINE psaldoIvaIntTrasApoyo DECIMAL(14,2);

--Set debug file to 'sp_Proceso_Venta_Cartera.out';
--trace on;

set isolation to dirty read;
set lock mode to wait 3;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
     Rollback Work;
	  LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

---+-SET DEBUG FILE TO "/informix/jesus/sp_procesa_inmateriales.out";
--TRACE ON;
	
	--SET DEBUG FILE TO "sp_procesa_inmaterialesv1.out";
	--TRACE ON;	
let vcodigo_ref = 0;

--- variables para procesar reestructuras SDFM 22/02/2012
LET vSucursal = '';
LET vMontoVencidoExigible_rees = 0;
LET vMontoVencidoNoExigible_rees = 0;
LET vInteresVencido = 0;
LET vInteresVencido_rees = 0;
LET vInteresVencido_ant = 0;
LET vIvaInteresVencido = 0;
LET vIvaInteresVencido_rees = 0;
LET vIvaInteresVencido_ant = 0;
LET vCapitalVig_rees = 0;
LET vCapitalVen_rees = 0;
LET cStatusCred = '';
let dproxfechapago = date(0);
let dfechaproceso   = date(0);
LET dfecha_vencto61 = DATE(0);
LET dfecha_vencto63 = DATE(0);
LET cNumCredito =pNumCredito;
LET cCodRetGF		 = '';
LET cFolioSuc		= '';

LET dIntMoratorio         = 0;
LET dIntMoratorio_d       = 0;
LET dIvaIntMoratorio       = 0;
LET dIvaSuc       = 0.16;

LET psaldoInteresTrasApoyo  = 0;
LET psaldoIvaIntTrasApoyo = 0;

/*
Select fecha_hoy,fecha_hoy --Obtiene la Fecha del Dia
Into vfechafin,dFecha--, vult_hab_mes, vpri_hab_mes
*/
Select pri_dia_mes, fecha_hoy  --Obtiene la Fecha del Dia
Into dpri_dia_mes, dFecha--, vult_hab_mes, vpri_hab_mes
From bdicred:sd_fechas
Where empresa = pEmpresa;
   Begin Work;
   
   --- PROCESO GENERICO PARA GENERAR UN FOLIO
	EXECUTE PROCEDURE bdicheq:"informix".sp_generafolionomina('Inmaterial') INTO  cCodRetGF , cFolioSuc ;
		
	IF pTpSol = 'T'  THEN
		  -- Se Replica la informacion de los creditos por Vender a la tabla bdicred:sd_maecred_vendida.
        	Insert into bdicred:sd_maecred_inmaterial
			Select current, * From bdicred:sd_maecred Where empresa = pEmpresa and num_credito= cNumCredito;

      
		-- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
		    Update bdicred:sd_maecred Set status_cred= 'FI' Where empresa = pEmpresa and num_credito= cNumCredito;

		-- Se Actualiza la fecha de proceso por estar bloqueados los crÃ©ditos
		    Update bdicred:sd_maecredanexo Set fecha_proceso = current Where empresa=pEmpresa And num_credito= cNumCredito;

		-- Se realiza el Bloqueo de la tarjeta.
            foreach
                select num_tarjeta
                  into vtarjeta
                from bdicred:sd_tarjeta
                where empresa=pEmpresa
                  and num_credito=cNumCredito
                  and tipo_tarjeta<>'0'
                  and status_tar <> 'C'

                  select codproductotarjeta
                    into cproduto
                  from intercard:tarjeta
                  where numtarjeta=vtarjeta;

                  execute procedure intercard:"informix".sp_cancelacion_tarjeta
                  (vtarjeta,cproduto,'informix') INTO CodRet, Mensaje;

                  if CodRet='001' or CodRet='002' then
                     LET CodRet = '000000';
                     LET Mensaje= " ";
                  end if;
            end foreach;

			-- Se Replica la informacion del Maestro de saldos a la tabla bdicred:sd_maesdos_vendida.
		    Insert into bdicred:sd_maesdos_inmaterial
			Select current, * From bdicred:sd_maesdos Where empresa=pEmpresa And num_credito= cNumCredito;

        -- se Replica la informacion de la Tabla sd_amortiza_credito a la tabla sd_amortiza_credito_vendida.
        	Insert into bdicred:sd_amortiza_credito_inmaterial
			Select current, * From bdicred:sd_amortiza_credito Where empresa= pEmpresa And num_credito= cNumCredito and fecha_cuota >= date(0);

			
			Update bdicred:sd_tarjeta Set status_tar= 'C', limite_aut = 0, motivo = 'FI' Where empresa= pEmpresa And num_credito= cNumCredito and status_tar <> 'C';

            SELECT
                a.num_producto, a.sucursal, a.divisa, a.periodo_plazo, calificacion_riesgo,
                b.monto_otorgado - (b.sdo_capital + b.monto_vencido + b.mto_venc_trasp + b.cap_tras_no_venci),-- Se obtiene el monto de la LINEA DE CREDITO NO DISPUESTA
                b.Mto_venc_trasp + b.monto_vencido, b.cap_tras_no_venci, b.int_tra_no_exig, b.monto_reservado, -- IFRS se agrega el monto vencido
                b.sdo_capital, b.sdo_cap_insoluto
            INTO
                cNumProducto, cSucursal, cDivisa, vPeriodicidad, vCalif_Riesgo,
                vMontoLineaNoDispuesta,
                vMontoVencidoExigible, vMontoVencidoNoExigible,vInteresVencido, vMontoReservado,
                vCapitalVig, vCapitalVen
            FROM
                sd_maecred a, sd_maesdos b, sd_definicion d,
                bdinteg:si_sucursales e
            WHERE a.empresa        = pEmpresa
              AND a.num_credito      = cNumCredito
              AND a.bandera_ministra = 'M'
              AND b.empresa          = a.empresa
              AND b.num_credito      = a.num_credito
              AND d.empresa          = a.empresa
              AND d.num_producto     = a.num_producto
              AND e.empresa			= a.empresa
              AND e.sucursal         = a.sucursal;

            If vMontoLineaNoDispuesta > 0 Then
                -- Cancelacion del registro de la LINEA DE CREDITO NO DISPUESTA
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 20,
                                "066", dFecha, vMontoLineaNoDispuesta, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
            Else
                let vMontoLineaNoDispuesta = abs(vMontoLineaNoDispuesta);
                -- Saldo Negativo Inversa de la Cancelacion del registro de la LINEA DE CREDITO NO DISPUESTA
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 21,
                                "066", dFecha, vMontoLineaNoDispuesta, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
            End If;
				
			IF vMontoVencidoExigible > 0 THEN
                IF(cStatusCred = 'E1') THEN
					-- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 41,
                                "066", dFecha, vMontoVencidoExigible, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
								
				ELIF (cStatusCred = 'E2') THEN
					-- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 51,
                                "066", dFecha, vMontoVencidoExigible, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
								
				ELSE -- E3/PRODUCTIVO
					-- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 1,
                                "066", dFecha, vMontoVencidoExigible, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
				END IF;
			END IF;
			IF vMontoVencidoNoExigible > 0 THEN
			
				IF(cStatusCred = 'E1') THEN
					-- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 42,
                                "066", dFecha, vMontoVencidoNoExigible, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
								
				ELIF (cStatusCred = 'E2') THEN
					-- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 52,
                                "066", dFecha, vMontoVencidoNoExigible, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
								
				ELSE -- E3/PRODUCTIVO
					-- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 2,
                                "066", dFecha, vMontoVencidoNoExigible, cFolioSuc,
                                cSucursal, cDivisa, "0000") RETURNING
                                CodRet, Mensaje;
				END IF;
			END IF;
			IF vInteresVencido > 0 THEN
        -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias
               CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 3,
                           "066", dFecha, vInteresVencido, cFolioSuc,
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;
			END IF
        -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias Moratorios

		     SELECT SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))
             INTO vIntMora
             FROM sd_amortiza_credito
             WHERE  empresa = pEmpresa
             AND num_credito = cNumCredito
             AND capital_status IN ("2","7","6");

             IF  vIntMora IS NULL OR  vIntMora < 0 THEN
                LET vIntMora = 0;
             END IF;
		
			IF  vIntMora > 0 THEN
               CALL GenMov(pEmpresa, cNumCredito, cNumProducto,4 ,
                           "066", dFecha, vIntMora , cFolioSuc,
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;
           	END IF;   

        -- Iva Vencido por Cobrar
             Select
                Sum(iva_debe - iva_pagado)
             Into
                vMontoVencidoPorCobrar
             From
                sd_amortiza_credito
             Where empresa= pEmpresa
               And num_credito= cNumCredito
               and capital_status <> '5';

				IF vMontoVencidoPorCobrar > 0 THEN
            -- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias
               CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 5,
                           "066", dFecha, vMontoVencidoPorCobrar, cFolioSuc,
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;
				END IF
            -- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias MORATORIOS

                    -- Se obtiene el iva de la sucursal
                    SELECT iva
                    INTO vPorcIva
                    FROM bdinteg:si_sucursales
                    WHERE empresa = pEmpresa
                    AND sucursal = cSucursal;

                    IF vPorcIva IS NULL THEN
                        LET vPorcIva=0;
                    END IF;

					
				FOREACH
					SELECT (NVL(mora_iva_debe,0) - NVL(mora_iva_pagado,0) +( NVL(mora_provi_ordi + mora_provi_cope,0)* vPorcIva ))
					INTO dIntMoratorio_d
					FROM sd_amortiza_credito a
					WHERE a.empresa   = pEmpresa
					AND a.num_credito = cNumCredito
					AND capital_status IN ("2","7","6")

					LET dIvaIntMoratorio = dIvaIntMoratorio + dIntMoratorio_d;

				END FOREACH;
					
            IF dIvaIntMoratorio > 0 THEN
                CALL GenMov(pEmpresa, cNumCredito, cNumProducto, 6,
                           "066", dFecha, dIvaIntMoratorio, cFolioSuc,
                           cSucursal, cDivisa, "0000") RETURNING
                           CodRet, Mensaje;
		    END IF;

            -- Se Actualizan los saldos
               Update sd_maesdos
                  Set mto_venc_trasp=0, monto_vencido=0,
                      cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0,
                      sdo_capital=0, sdo_cap_insoluto=0, monto_otorgado = 0,
                      monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0
                 Where empresa = pEmpresa
                   And num_credito= cNumCredito;

            -- Se Actualizan las amortizaciones

               Update sd_amortiza_credito
                  Set capital_status = 5,
                      iva_pagado = iva_debe,
                      mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
                      mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
                      mora_provi_ordi = 0,
                      mora_provi_cope = 0,
                      capital_pagado  = 0
                 Where empresa = pEmpresa
                   And num_credito= cNumCredito
                   and (capital_status in ('2','7','6') or interes_debe <> 0);


			  


	ELIF pTpSol = 'R'  THEN
	     -- Se Replica la informacion de los creditos (REESTRUCTURA) por Vender a la tabla bdicred:sd_maecred_vendida.
        INSERT INTO bdicred:sd_maecredcrd_inmaterial
        SELECT CURRENT, * FROM bdicred:sd_maecredcrd
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;
		  
		SELECT status_cred INTO cStatusCred 
		FROM bdicred:sd_maecredcrd
		WHERE empresa = pEmpresa
		AND num_credito = cNumCredito;

        -- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
        UPDATE bdicred:sd_maecredcrd
        SET status_cred= 'FI'
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;


        -- FMV 23May13  ajuste de indicador de buro por la venta de Cartera 6011           
        	SELECT fecha_vencto
			  INTO dfecha_vencto61
		      FROM bdicred:sd_maecredanexocrd
			 WHERE empresa = pEmpresa
		       AND num_credito = cNumCredito;      
               
          UPDATE "informix".sd_indicador_cred_crd
             SET dias_atraso   = (dFecha - nvl(dfecha_vencto61,dFecha) + 1)
           WHERE empresa       = pEmpresa
             AND num_credito   = cNumCredito;




        -- Se Actualiza la fecha de proceso por estar bloqueados los crÃ©ditos
        UPDATE bdicred:sd_maecredanexocrd   
        SET fecha_proceso = CURRENT
        WHERE empresa = pEmpresa
        AND num_credito = cNumCredito;
  
      -- Se Replica la informacion del Maestro de saldos a la tabla bdicred:sd_maesdos_vendida.
        INSERT INTO bdicred:sd_maesdoscrd_inmaterial
        SELECT CURRENT, * FROM bdicred:sd_maesdoscrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito;

        -- se Replica la informacion de la Tabla sd_amortiza_credito a la tabla sd_amortiza_credito_vendida.
        INSERT INTO bdicred:sd_amortiza_creditocrd_inmaterial
        SELECT CURRENT, * FROM bdicred:sd_amortiza_creditocrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito
        AND fecha_cuota >= date(1);

        SELECT
            a.num_producto, a.sucursal, a.divisa,
            (b.monto_vencido + b.mto_venc_trasp),(b.sdo_capital + b.cap_tras_no_venci), b.int_tra_no_exig,
            b.sdo_capital, b.sdo_cap_insoluto
        INTO
            cNumProducto, vSucursal, cDivisa,
            vMontoVencidoExigible_rees, vMontoVencidoNoExigible_rees,vInteresVencido,
            vCapitalVig_rees, vCapitalVen_rees
        FROM  bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_definicion c , bdinteg:si_sucursales d
        WHERE a.empresa          = pEmpresa
          AND a.num_credito      = cNumCredito
          AND a.bandera_ministra = 'M'
          AND b.empresa          = a.empresa
          AND b.num_credito      = a.num_credito
          AND c.empresa          = a.empresa
          AND c.num_producto     = a.num_producto
          AND d.empresa			 = a.empresa
          AND d.sucursal         = a.sucursal;

        -- Por la venta de la cartera vencida EXIGIBLE
		IF vMontoVencidoExigible_rees > 0 THEN
			IF(cStatusCred = 'E1') THEN
					-- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 41, "066", dFecha, vMontoVencidoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
                        RETURNING CodRet, Mensaje;
								
				ELIF (cStatusCred = 'E2') THEN
					-- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 51, "066", dFecha, vMontoVencidoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
                        RETURNING CodRet, Mensaje;
								
				ELSE -- E3/PRODUCTIVO
					-- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 1, "066", dFecha, vMontoVencidoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
                         RETURNING CodRet, Mensaje;
				END IF;		
		END IF;

        -- Por la venta de la cartera vencida NO EXIGIBLE
		IF vMontoVencidoNoExigible_rees > 0 THEN
			IF(cStatusCred = 'E1') THEN
					-- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 42, "066", dFecha, vMontoVencidoNoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;
								
				ELIF (cStatusCred = 'E2') THEN
					-- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 52, "066", dFecha, vMontoVencidoNoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;
								
				ELSE -- E3/PRODUCTIVO
					-- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 2, "066", dFecha, vMontoVencidoNoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;
				END IF;
		END IF;
-------------------------
        IF cStatusCred IN ('BT','VP') THEN
            --creditos BT
            --balanza
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7')
            and fecha_cuota <= (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '601'
                                and codigo_ref = 3
                                and reversado = 'N');

            --orden
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7')
            and fecha_cuota > (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '601'
                                and codigo_ref = 3
                                and reversado = 'N');

        ELIF cStatusCred IN ('E2','E3') THEN
			--Balanza
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
			AND campo_trabajo3 = '';

            --Orden
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
			AND campo_trabajo3 = 'V';
			
		ELSE
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            FROM bdicred:sd_amortiza_creditocrd
            WHERE empresa = pEmpresa
            AND num_credito= cNumCredito
            AND capital_status in ('2','7','6');
        END IF;

-------------------------


    -- Baja del INTERES VENCIDO por cobrar sobre operaciones crediticias
		IF vInteresVencido_rees > 0 THEN
			IF cStatusCred = 'E1' THEN
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 17, "066", dFecha, vInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 19, "066", dFecha, vIvaInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;			
			ELIF cStatusCred = 'E2' THEN
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 27, "066", dFecha, vInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 29, "066", dFecha, vIvaInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;			
			ELIF cStatusCred = 'E3' THEN
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 37, "066", dFecha, vInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 39, "066", dFecha, vIvaInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;			
			ELSE
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 7, "066", dFecha, vInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 9, "066", dFecha, vIvaInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			END IF;
		END IF;


        -- Baja del Interes Vencido por Cobrar

		IF vInteresVencido > 0 THEN
			IF cStatusCred = 'E1' THEN
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 18, "066", dFecha, vInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 110, "066", dFecha, vIvaInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			ELIF cStatusCred = 'E2' THEN			
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 28, "066", dFecha, vInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 210, "066", dFecha, vIvaInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			ELIF cStatusCred = 'E3' THEN						
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 38, "066", dFecha, vInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 310, "066", dFecha, vIvaInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			ELSE
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 8, "066", dFecha, vInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 10, "066", dFecha, vIvaInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			END IF;
		END IF;

        -- Se Actualizan los saldos
        UPDATE bdicred:sd_maesdoscrd
        SET    mto_venc_trasp=0, monto_vencido=0, cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0, sdo_capital=0,
               sdo_cap_insoluto=0, monto_otorgado = 0, monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0,
               ---- se agregan campos para que Juan Olivares valide
               sdo_intereses = 0, sdo_dia_ant_int = 0, provision_normal = 0, sdo_cap_insoluto = 0, sdo_dia_ant_cap = 0, sdo_mes_ant_cap = 0,
               sdo_acum_mes_cap = 0, mto_capitalizado = 0, mto_ministra_cap = 0, cargos_dia_cap = 0, abonos_dia_cap = 0, cargos_mes_cap = 0,
               abonos_mes_cap = 0, sdo_global_int = 0, mto_venc_int = 0, mto_fin_ven_trasp = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito;

        -- Se Actualizan las amortizaciones

        UPDATE sd_amortiza_creditocrd
        SET    capital_status = 5, iva_pagado = iva_debe, mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
               mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope, mora_provi_ordi = 0, mora_provi_cope = 0, capital_pagado  = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito
        AND    (capital_status in ('2','7','6') or interes_debe <> 0);


	ELSE
		LET pTpSol = pTpSol;	

-- Se Replica la informacion de los creditos (PRESTAMO PERSONAL) por Vender a la tabla bdicred:sd_maecred_vendida.
        INSERT INTO bdicred:sd_maecredcrd_inmaterial
        SELECT CURRENT, * FROM bdicred:sd_maecredcrd
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;
		  
		SELECT status_cred INTO cStatusCred 
		FROM bdicred:sd_maecredcrd
		WHERE empresa = pEmpresa
		AND num_credito = cNumCredito;		
		
        -- Se Actualiza el Status del Maestro de Credito al Status CV (Cartera Vendida).
        UPDATE bdicred:sd_maecredcrd
        SET status_cred= 'FI'
        WHERE empresa = pEmpresa
          AND num_credito = cNumCredito;


     -- FMV 23May13  ajuste de indicador de buro por la venta de Cartera 6300           
        	SELECT fecha_vencto
			  INTO dfecha_vencto63
		      FROM bdicred:sd_maecredanexocrd
			 WHERE empresa = pEmpresa
		       AND num_credito = cNumCredito;      
               
          UPDATE "informix".sd_indicador_cred_crd
             SET dias_atraso   = (dFecha - nvl(dfecha_vencto63,dFecha) + 1)
           WHERE empresa       = pEmpresa
             AND num_credito   = cNumCredito;






        -- Se Actualiza la fecha de proceso por estar bloqueados los crÃ©ditos
        UPDATE bdicred:sd_maecredanexocrd
        SET fecha_proceso = CURRENT
        WHERE empresa = pEmpresa
        AND num_credito = cNumCredito;

		-- Se Replica la informacion del Maestro de saldos a la tabla bdicred:sd_maesdos_vendida.
        INSERT INTO bdicred:sd_maesdoscrd_inmaterial
        SELECT CURRENT, * FROM bdicred:sd_maesdoscrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito;

        -- se Replica la informacion de la Tabla sd_amortiza_credito a la tabla sd_amortiza_credito_vendida.
        INSERT INTO bdicred:sd_amortiza_creditocrd_inmaterial
        SELECT CURRENT, * FROM bdicred:sd_amortiza_creditocrd
        WHERE empresa = pEmpresa
        AND num_credito= cNumCredito
        AND fecha_cuota >= date(1);
		
        SELECT
            a.num_producto, a.sucursal, a.divisa,
            (b.monto_vencido + b.mto_venc_trasp),(b.sdo_capital + b.cap_tras_no_venci), b.int_tra_no_exig,
            b.sdo_capital, b.sdo_cap_insoluto,
			e.dia_corte
        INTO
            cNumProducto, vSucursal, cDivisa,
            vMontoVencidoExigible_rees, vMontoVencidoNoExigible_rees,vInteresVencido,
            vCapitalVig_rees, vCapitalVen_rees,
			ddia_corte

        FROM  bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_definicion c , bdinteg:si_sucursales d, bdicred:sd_maecredanexocrd e
        WHERE a.empresa          = pEmpresa
          AND a.num_credito      = cNumCredito
          AND a.bandera_ministra = 'M'
          AND b.empresa          = a.empresa
          AND b.num_credito      = a.num_credito
          AND c.empresa          = a.empresa
          AND c.num_producto     = a.num_producto
          AND d.empresa			 = a.empresa
          AND d.sucursal         = a.sucursal
		  AND e.empresa 		 = a.empresa
		  AND e.num_credito      = a.num_credito;

        -- Por la venta de la cartera vencida EXIGIBLE

		IF vMontoVencidoExigible_rees > 0 THEN
				IF(cStatusCred = 'E1') THEN
					-- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 41, "066", dFecha, vMontoVencidoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
                        RETURNING CodRet, Mensaje;
								
				ELIF (cStatusCred = 'E2') THEN
					-- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 51, "066", dFecha, vMontoVencidoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
                        RETURNING CodRet, Mensaje;
								
				ELSE -- E3/PRODUCTIVO
					-- Por la venta de la cartera vencida EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 1, "066", dFecha, vMontoVencidoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
                         RETURNING CodRet, Mensaje;
				END IF;
		END IF;

					-- Por la venta de la cartera vencida NO EXIGIBLE
		IF vMontoVencidoNoExigible_rees > 0 THEN
				IF(cStatusCred = 'E1') THEN
					-- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 42, "066", dFecha, vMontoVencidoNoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;
								
				ELIF (cStatusCred = 'E2') THEN
					-- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 52, "066", dFecha, vMontoVencidoNoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;
								
				ELSE -- E3/PRODUCTIVO
					-- Por la venta de la cartera vencida NO EXIGIBLE
                    CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 2, "066", dFecha, vMontoVencidoNoExigible_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
				 RETURNING CodRet, Mensaje;
				END IF;
		END IF;

		IF cStatusCred IN ('E1','E2','E3') THEN
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
			AND campo_trabajo3 = '';

			select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
			AND campo_trabajo3 = 'V';
		ELSE
            select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido_rees, vIvaInteresVencido_rees
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
            and fecha_cuota <= (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '026'
                                and codigo_ref = 3
                                and reversado = 'N');

            --orden
            --select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido 08/06/2012 PARA PP POR RSS
			select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO vInteresVencido, vIvaInteresVencido
            from bdicred:sd_amortiza_creditocrd
            where empresa = pEmpresa
            and num_credito = cNumCredito
            and capital_status in ('2','7','6')
            and fecha_cuota > (
                                select max(fecha_mov)
                                from bdicred:sd_movhiscrd
                                where empresa = pEmpresa
                                and num_credito = cNumCredito
                                and codigo_fun = '026'
                                and codigo_ref = 3
                                and reversado = 'N');

		END IF;

		IF vInteresVencido_rees > 0 THEN
			IF cStatusCred = 'E1' THEN
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 17, "066", dFecha, vInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					RETURNING CodRet, Mensaje;
			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 19, "066", dFecha, vIvaInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					RETURNING CodRet, Mensaje;
			ELIF cStatusCred = 'E2' THEN
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 27, "066", dFecha, vInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					RETURNING CodRet, Mensaje;
			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 29, "066", dFecha, vIvaInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					RETURNING CodRet, Mensaje;
			ELIF cStatusCred = 'E3' THEN			
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 37, "066", dFecha, vInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					RETURNING CodRet, Mensaje;
			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 39, "066", dFecha, vIvaInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					RETURNING CodRet, Mensaje;
			ELSE
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 7, "066", dFecha, vInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					RETURNING CodRet, Mensaje;
			-- Baja del IVA VENCIDO por cobrar sobre operaciones crediticias
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 9, "066", dFecha, vIvaInteresVencido_rees, cFolioSuc, vSucursal, cDivisa, "0000","","")
					RETURNING CodRet, Mensaje;
			END IF;
		END IF;

				--- se obtienen los  montos de INT de la maeretenido del programa de apoyo
				SELECT monto
					INTO psaldoInteresTrasApoyo
				FROM bdicred:sd_maeretenido 
				WHERE num_credito = cNumCredito
					AND transacc = '8374'
					AND estatus = 'R';

					IF psaldoInteresTrasApoyo IS NULL THEN
						LET psaldoInteresTrasApoyo = 0;
					END IF;
					
				IF psaldoInteresTrasApoyo > 0 THEN

					CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 22, "066", dFecha, psaldoInteresTrasApoyo, cFolioSuc, vSucursal, cDivisa, "0000","","")
						 RETURNING CodRet, Mensaje;

				END IF;
				
				--- se obtienen los  montos de INT de la maeretenido del programa de apoyo
				SELECT monto
					INTO psaldoIvaIntTrasApoyo
				FROM bdicred:sd_maeretenido 
				WHERE num_credito = cNumCredito
					AND transacc = '8375'
					AND estatus = 'R';

					IF psaldoIvaIntTrasApoyo IS NULL THEN
						LET psaldoIvaIntTrasApoyo = 0;
					END IF;
					
				IF psaldoIvaIntTrasApoyo > 0 THEN

					CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 23, "066", dFecha, psaldoIvaIntTrasApoyo, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;

				END IF;
			
			
        -- Baja del Interes Vencido por Cobrar

		IF vInteresVencido > 0 THEN
			IF cStatusCred = 'E1'THEN
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 18, "066", dFecha, vInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 110, "066", dFecha, vIvaInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			ELIF cStatusCred = 'E2' THEN
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 28, "066", dFecha, vInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 210, "066", dFecha, vIvaInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;			
			ELIF cStatusCred = 'E3' THEN
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 38, "066", dFecha, vInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 310, "066", dFecha, vIvaInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;			
			ELSE
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 8, "066", dFecha, vInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 10, "066", dFecha, vIvaInteresVencido, cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
			END IF;
		END IF;

		
  			-- 2011-11-30 Se realiza cambio en calculo de IVA moratorio
  		SELECT SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),
  			   SUM(round((NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0))* dIvaSuc,2))
			   INTO dIntMoratorio, dIntMoratorio_d  		      
  		  FROM "informix".sd_amortiza_creditocrd
  		 WHERE empresa     = pEmpresa
  		   AND num_credito = cNumCredito
  		   AND capital_status IN ('2','7','6');
			
			IF dIntMoratorio > 0 THEN
			 
			  -- Genera Movmiento de Provision Mora				
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 4, "066", dFecha, dIntMoratorio , cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;
				
				CALL GenMovcrd(pEmpresa, cNumCredito, cNumProducto, 6, "066", dFecha, dIntMoratorio_d , cFolioSuc, vSucursal, cDivisa, "0000","","")
					 RETURNING CodRet, Mensaje;			
			END IF;
		
        -- Se Actualizan los saldos
        UPDATE bdicred:sd_maesdoscrd
        SET    mto_venc_trasp=0, monto_vencido=0, cap_tras_no_venci=0, int_tra_no_exig =0, sdo_no_exig = 0, sdo_capital=0,
               sdo_cap_insoluto=0, monto_otorgado = 0, monto_financiado = 0, sdo_contab_mora = 0, sdo_moratorio = 0,               
               sdo_intereses = 0, sdo_dia_ant_int = 0, provision_normal = 0, sdo_cap_insoluto = 0, sdo_dia_ant_cap = 0, sdo_mes_ant_cap = 0,
               sdo_acum_mes_cap = 0, mto_capitalizado = 0, mto_ministra_cap = 0, cargos_dia_cap = 0, abonos_dia_cap = 0, cargos_mes_cap = 0,
               abonos_mes_cap = 0, sdo_global_int = 0, mto_venc_int = 0, mto_fin_ven_trasp = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito;

        -- Se Actualizan las amortizaciones

        UPDATE sd_amortiza_creditocrd
        SET    capital_status = 5, iva_pagado = iva_debe, mora_iva_debe = mora_iva_debe + mora_provi_ordi + mora_provi_cope,
               mora_iva_pagado = mora_iva_debe + mora_provi_ordi + mora_provi_cope, mora_provi_ordi = 0, mora_provi_cope = 0, capital_pagado  = 0
        WHERE  empresa = pEmpresa
        AND    num_credito= cNumCredito
        AND    (capital_status in ('2','7','6') or interes_debe <> 0);
		
		/*Proceso de cancelacion de Linea de prestamo*/
			SELECT {+AVOID_FULL(bdicred:"informix".sd_linea_prestamo)} crd.num_producto, crd.sucursal, crd.fecha_vencim, pres.monto_linea
			INTO cNumProducto,vSucursal, vFechaVencCred, vMontoDisp
			FROM bdicred:"informix".sd_linea_prestamo pres
			JOIN bdicred:"informix".sd_maecredcrd crd ON (pres.num_credito = crd.num_credito)
			WHERE pres.num_credito = cNumCredito;
		    --LET cNumProducto = cNumProducto;
		IF cNumProducto = 6800 THEN
			
			-- SE GENERA EL FOLIO
			CALL bdicheq:"informix".sp_generafolionomina('informix') RETURNING CodRet, cFolioSuc;
			 LET CodRet = CodRet;
			 LET cFolioSuc = cFolioSuc;
			IF CodRet::integer  <> '000' THEN
					LET CodRet = "00002";  --Error en sp_generafolionomina
					RETURN CodRet || Mensaje;  
				ELSE
				
					EXECUTE PROCEDURE bdicred:genmovcrd(pEmpresa,cNumCredito, '6800', 2, '002', dFecha, vMontoDisp, cFolioSuc, vSucursal, '01', '7480', 'Cancelacion Linea Prestamo Digital' , '' ) INTO CodRet, cErrorInfo;
					
					IF CodRet::integer  <> '000000' THEN
							LET CodRet = "00004"; --Error en genmovcrd
							RETURN CodRet || Mensaje;
						ELSE
							UPDATE bdicred:"informix".sd_linea_prestamo SET fecha_cancela = dFecha, cancel_pf = '1', fecha_ult_pf = vFechaVencCred WHERE num_credito = cNumCredito;
					END IF;
			END IF;
		END IF;
		/*Proceso de cancelacion de Linea de prestamo*/

	END IF;
	
	--SE realiza el marcaje del cliente RQI 27 100 JMAH
	EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',1,pNumcte, USER)
	INTO CodRet, Mensaje;
	
    LET vInteresVencido_rees = 0;
    LET vIvaInteresVencido_rees = 0;
    LET vInteresVencido = 0;
    LET vIvaInteresVencido = 0;
	LET vInteresVencido_ant = 0;
	LET vIvaInteresVencido_ant = 0;
	LET cStatusCred = '';
	LET psaldoInteresTrasApoyo  = 0;
	LET psaldoIvaIntTrasApoyo = 0;

    Commit Work;


LET CodRet = '00000';
RETURN CodRet;

end;
end procedure;