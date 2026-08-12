CREATE PROCEDURE "informix".conisr_anual_cta(
       pCuenta    CHAR(20),
       pEmpresa   CHAR(3),
       pEjercicio SMALLINT)

RETURNING
    VARCHAR(5),         -- CodigoRetorno
    VARCHAR(64),        -- DescripcionError
    INTEGER;            -- Cantidad de registros añadidos

-- ***********************************************************************************************
-- conisr_anual
-- Version              1.0.0
-- Obejtivo:            Obtener en tabla sc_retenisr la
--                      informacion del periodo indicado referente a retenciones de isr
-- Supuestos:           Ninguno
-- Valores de Entrada:  pEmpresa            Clave de la Empresa
--                      pEjercicio          Ejercicio Fiscal
-- Valores de Regreso:  Codigo
--                      Descripcion de retorno
--                      cantidad de registros
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima ModIFicacion: Febrero-2008
--                      Creación de SPL
-- *************************************************************************************************

DEFINE cVarDataErr         VARCHAR(64);
DEFINE iSqlErr             INTEGER;
DEFINE iSamErr             INTEGER;
DEFINE vCodRet             CHAR(5);
DEFINE vt_folio            INTEGER;
DEFINE vt_cuenta           CHAR(20);
DEFINE vt_cliente          CHAR(20);

DEFINE ct_incp0            DECIMAL(12,8);
DEFINE ct_incp1            DECIMAL(12,8);
DEFINE ct_incp2            DECIMAL(12,8);
DEFINE ct_incp3            DECIMAL(12,8);
DEFINE ct_incp4            DECIMAL(12,8);
DEFINE ct_incp5            DECIMAL(12,8);
DEFINE ct_incp6            DECIMAL(12,8);
DEFINE ct_incp7            DECIMAL(12,8);
DEFINE ct_incp8            DECIMAL(12,8);
DEFINE ct_incp9            DECIMAL(12,8);
DEFINE ct_incp10           DECIMAL(12,8);
DEFINE ct_incp11           DECIMAL(12,8);
DEFINE ct_incp12           DECIMAL(12,8);
DEFINE vt_fecha            DATE;
DEFINE vt_preciocont       DECIMAL(12,8);
DEFINE vt_tasaprom         DECIMAL(6,2);
DEFINE vt_tasarealperi     DECIMAL(12,8);
DEFINE vt_cuantos          INTEGER;
DEFINE vt_totintpag        DECIMAL(12,2);

DEFINE vt_tasaperdida      DECIMAL(12,2);
DEFINE vt_tasaperdidatot   DECIMAL(12,2);
DEFINE vt_perdida          DECIMAL(10,2);
DEFINE vt_diasanio         SMALLINT;
DEFINE vt_diasinver        SMALLINT;

DEFINE vt_sdopromt         DECIMAL(12,2);
DEFINE vt_sdoprom          DECIMAL(12,2);
DEFINE vt_sdoprom1         DECIMAL(12,2);
DEFINE vt_sdoprom2         DECIMAL(12,2);
DEFINE vt_sdoprom3         DECIMAL(12,2);
DEFINE vt_sdoprom4         DECIMAL(12,2);
DEFINE vt_sdoprom5         DECIMAL(12,2);
DEFINE vt_sdoprom6         DECIMAL(12,2);
DEFINE vt_sdoprom7         DECIMAL(12,2);
DEFINE vt_sdoprom8         DECIMAL(12,2);
DEFINE vt_sdoprom9         DECIMAL(12,2);
DEFINE vt_sdoprom10        DECIMAL(12,2);
DEFINE vt_sdoprom11        DECIMAL(12,2);
DEFINE vt_sdoprom12        DECIMAL(12,2);

DEFINE vt_mes              SMALLINT;
DEFINE vt_totintpagt       DECIMAL(12,2);
DEFINE vt_interesexento    DECIMAL(12,2);
DEFINE vt_tasapromt        DECIMAL(15,10);
DEFINE vt_acumsdopos       DECIMAL(12,2);
DEFINE vt_diasdopos        SMALLINT;
DEFINE vt_isretenido       DECIMAL(12,2);
DEFINE vt_mesini           SMALLINT;
DEFINE vt_mesfin           SMALLINT;

DEFINE vt_inpcini          DECIMAL(12,8);
DEFINE vt_inpcfin          DECIMAL(12,8);
DEFINE vt_interesreal      DECIMAL(12,2);
DEFINE vt_ajustexinf       DECIMAL(10,8);
DEFINE vt_ajustexinfx100   DECIMAL(6,3);
DEFINE vt_tasapromtx100    DECIMAL(6,3);
DEFINE vt_interesexentot   DECIMAL(12,2);
DEFINE vt_interesrealtot   DECIMAL(12,2);
DEFINE vt_aniomes          CHAR(6);
DEFINE vt_fechaini         DATE;
DEFINE vt_fechafin         DATE;

BEGIN
  ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET vCodret=iSqlErr;
            RETURN vCodret, cVarDataErr, NULL;
        END IF;
    END EXCEPTION;

   --set debug file to "/tmp/conisr_anual.out";
   --trace on;

    --//Inicializa Variables
    LET vCodRet = '000';
    LET vt_folio = 0;
    LET vt_diasanio = 360;
    LET vt_diasinver = 30;

    LET ct_incp0 = 0.0;
    LET ct_incp1 = 0.0;
    LET ct_incp2 = 0.0;
    LET ct_incp3 = 0.0;
    LET ct_incp4 = 0.0;
    LET ct_incp5 = 0.0;
    LET ct_incp6 = 0.0;
    LET ct_incp7 = 0.0;
    LET ct_incp8 = 0.0;
    LET ct_incp9 = 0.0;
    LET ct_incp10 = 0.0;
    LET ct_incp11 = 0.0;
    LET ct_incp12 = 0.0;

    --// ********************************************************************
    --// Obtiene los INPC del ejercicio correspondiente
    --// ********************************************************************
    FOREACH
         SELECT fecha, preciocontable
           INTO vt_fecha, vt_preciocont
           FROM bdirepaut:sp_preciocontable
          WHERE moneda = '95'
            AND YEAR(fecha) = pEjercicio

         IF MONTH(vt_fecha) = 1 THEN
            LET ct_incp1 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 2 THEN
            LET ct_incp2 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 3 THEN
            LET ct_incp3 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 4 THEN
            LET ct_incp4 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 5 THEN
            LET ct_incp5 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 6 THEN
            LET ct_incp6 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 7 THEN
            LET ct_incp7 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 8 THEN
            LET ct_incp8 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 9 THEN
            LET ct_incp9 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 10 THEN
            LET ct_incp10 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 11 THEN
            LET ct_incp11 = vt_preciocont;
         ELIF MONTH(vt_fecha) = 12 THEN
            LET ct_incp12 = vt_preciocont;
         END IF

    END FOREACH


    --// ********************************************************************
    --// Elimina los calculos anteriores para el periodo seleccionado
    --// ********************************************************************

    DELETE FROM sc_retenisr
     WHERE empresa = pEmpresa
       AND ejercicio = pEjercicio
       AND cuenta = pcuenta;

    --// ********************************************************************
    --// Trae las cuentas de Cheques
    --// ********************************************************************
    FOREACH
            SELECT mae.cuenta, num_cte
              INTO vt_cuenta, vt_cliente
              FROM sc_maechq mae
             WHERE mae.empresa = pEmpresa
             --  AND mae.cuenta = mae.cuenta
                 AND mae.cuenta = pCuenta
             --WHERE mae.cuenta in('10000611730' ,'10000005016')

           LET vt_totintpagt = 0;
           LET vt_tasapromt = 0;
           LET vt_sdopromt = 0;
           LET vt_mesini = 0;
           LET vt_mesfin = 0;
           LET vt_interesexentot = 0;
           LET vt_tasaperdidatot = 0;
           LET vt_interesrealtot = 0;

           LET vt_sdoprom1 = 0.0;
           LET vt_sdoprom2 = 0.0;
           LET vt_sdoprom3 = 0.0;
           LET vt_sdoprom4 = 0.0;
           LET vt_sdoprom5 = 0.0;
           LET vt_sdoprom6 = 0.0;
           LET vt_sdoprom7 = 0.0;
           LET vt_sdoprom8 = 0.0;
           LET vt_sdoprom9 = 0.0;
           LET vt_sdoprom10 = 0.0;
           LET vt_sdoprom11 = 0.0;
           LET vt_sdoprom12 = 0.0;

           --//Calculos mensuales
           FOREACH
                SELECT aniomes[5,6], aniomes, totintpag, nvl(tasabruta,0),acum_sdo_pos,dia_sdo_pos,
                       fechaini, fechafin
                  INTO vt_mes, vt_aniomes, vt_totintpag, vt_tasaprom, vt_acumsdopos, vt_diasdopos,
                       vt_fechaini, vt_fechafin
                  FROM sc_maehis
                 WHERE cuenta = vt_cuenta
                   AND aniomes[1,4] = pEjercicio
                   --AND aniomes = "200710"
                 ORDER BY 1

                 SELECT NVL(SUM(monto_tot),0)
                   INTO vt_totintpag
                   FROM sc_movhis_old
                  WHERE fech_alt BETWEEN vt_fechaini AND vt_fechafin
                    AND YEAR(fech_alt)= pEjercicio
                    AND transacc = '3276'
                    AND empresa = pEmpresa
		    AND cuenta = vt_cuenta
                    AND cancelad <> 'S';
                    --AND aniomes = vt_aniomes;

                 IF vt_totintpag  <= 0 THEN
                    CONTINUE FOREACH;
                 END IF;

                 LET vt_totintpagt = vt_totintpagt + vt_totintpag;
                 LET vt_tasaprom = 8.5000;

                 --//Calcula la tasa y en porciento
                 LET vt_tasapromt = ((8.50/vt_diasanio) * vt_diasinver)/100;
                 LET vt_tasapromtx100 = vt_tasapromt * 100;

                 --//Calcula el saldo promedio del mes
                 --IF vt_acumsdopos > 0 AND vt_tasaprom > 0 THEN
                    LET vt_sdoprom = ((vt_totintpag * vt_diasanio)/(vt_tasaprom/100))/vt_diasinver;
                 --ELSE
                 --   LET vt_sdoprom = 0;
                 --END IF;

                 LET vt_sdopromt = vt_sdopromt + vt_sdoprom;

                 --//Coloca en el mes, el saldo promedio
                 IF vt_mes = 1 THEN
                    LET vt_sdoprom1 = vt_sdoprom;
                 ELIF vt_mes = 2 THEN
                    LET vt_sdoprom2 = vt_sdoprom;
                 ELIF vt_mes = 3 THEN
                    LET vt_sdoprom3 = vt_sdoprom;
                 ELIF vt_mes = 4 THEN
                    LET vt_sdoprom4 = vt_sdoprom;
                 ELIF vt_mes = 5 THEN
                    LET vt_sdoprom5 = vt_sdoprom;
                 ELIF vt_mes = 6 THEN
                    LET vt_sdoprom6 = vt_sdoprom;
                 ELIF vt_mes = 7 THEN
                    LET vt_sdoprom7 = vt_sdoprom;
                 ELIF vt_mes = 8 THEN
                    LET vt_sdoprom8 = vt_sdoprom;
                 ELIF vt_mes = 9 THEN
                    LET vt_sdoprom9 = vt_sdoprom;
                 ELIF vt_mes = 10 THEN
                    LET vt_sdoprom10 = vt_sdoprom;
                 ELIF vt_mes = 11 THEN
                    LET vt_sdoprom11 = vt_sdoprom;
                 ELIF vt_mes = 12 THEN
                    LET vt_sdoprom12 = vt_sdoprom;
                 END IF


                 --//Ubica el mes inicial y final del periodo
                 LET vt_mesfin = vt_mes;
                 LET vt_mesini = vt_mes -1;

                 --//Calcula el INPC del periodo inicial
                 IF vt_mesini = 1 THEN
                    LET vt_inpcini = ct_incp1;
                 ELIF vt_mesini = 2 THEN
                    LET vt_inpcini = ct_incp2;
                 ELIF vt_mesini = 3 THEN
                    LET vt_inpcini = ct_incp3;
                 ELIF vt_mesini = 4 THEN
                    LET vt_inpcini = ct_incp4;
                 ELIF vt_mesini = 5 THEN
                    LET vt_inpcini = ct_incp5;
                 ELIF vt_mesini = 6 THEN
                    LET vt_inpcini = ct_incp6;
                 ELIF vt_mesini = 7 THEN
                    LET vt_inpcini = ct_incp7;
                 ELIF vt_mesini = 8 THEN
                    LET vt_inpcini = ct_incp8;
                 ELIF vt_mesini = 9 THEN
                    LET vt_inpcini = ct_incp9;
                 ELIF vt_mesini = 10 THEN
                    LET vt_inpcini = ct_incp10;
                 ELIF vt_mesini = 11 THEN
                    LET vt_inpcini = ct_incp11;
                 ELIF vt_mesini = 12 THEN
                    LET vt_inpcini = ct_incp12;
                 END IF

                 --//Calcula el INPC del periodo final
                 IF vt_mesfin = 1 THEN
                    LET vt_inpcfin = ct_incp1;
                 ELIF vt_mesfin = 2 THEN
                    LET vt_inpcfin = ct_incp2;
                 ELIF vt_mesfin = 3 THEN
                    LET vt_inpcfin = ct_incp3;
                 ELIF vt_mesfin = 4 THEN
                    LET vt_inpcfin = ct_incp4;
                 ELIF vt_mesfin = 5 THEN
                    LET vt_inpcfin = ct_incp5;
                 ELIF vt_mesfin = 6 THEN
                    LET vt_inpcfin = ct_incp6;
                 ELIF vt_mesfin = 7 THEN
                    LET vt_inpcfin = ct_incp7;
                 ELIF vt_mesfin = 8 THEN
                    LET vt_inpcfin = ct_incp8;
                 ELIF vt_mesfin = 9 THEN
                    LET vt_inpcfin = ct_incp9;
                 ELIF vt_mesfin = 10 THEN
                    LET vt_inpcfin = ct_incp10;
                 ELIF vt_mesfin = 11 THEN
                    LET vt_inpcfin = ct_incp11;
                 ELIF vt_mesfin = 12 THEN
                    LET vt_inpcfin = ct_incp12;
                 END IF

                 --//Calcula el Factor Ajuste y en porcentaje
                 LET vt_ajustexinf = TRUNC((vt_inpcfin/vt_inpcini),4)-1;
                 IF vt_ajustexinf <= 0 THEN
                    LET vt_ajustexinf = 0;
                 END IF;

                 LET vt_ajustexinfx100 = vt_ajustexinf * 100;

                 --//Calcula la tasa real del periodo
                 LET vt_tasarealperi = (vt_tasapromtx100)-(vt_ajustexinfx100);

                 --/Si la tasa real es negativa, se pone a cero
                 IF vt_tasarealperi <= 0 THEN
                    LET vt_tasarealperi = 0.00;
                 END IF

                 --//Calcula el interes real
                 LET vt_interesreal = vt_sdoprom * vt_tasarealperi;
                 LET vt_interesreal = (vt_interesreal/100);
                 LET vt_interesrealtot = vt_interesrealtot + vt_interesreal;

                 --//Calcula el interes exento
                 LET vt_interesexento = vt_totintpag - vt_interesreal;
                 LET vt_interesexentot = vt_interesexentot + vt_interesexento;

                 --/Cuando el ajuste por inflación sea mayor que la tasa de interés del periodo, el resultado será pérdida
                 IF vt_ajustexinfx100 > vt_tasapromtx100 THEN

                    --//Calcula el Factor Ajuste y en porcentaje
                    LET vt_ajustexinf = TRUNC(vt_inpcfin/vt_inpcini,8)-1;
                    LET vt_ajustexinfx100 = vt_ajustexinf * 100;

                    --//PERDIDA\\---
                    --//Calcula el ajuste mayor que la tasa ints.
                    LET vt_tasarealperi = ((vt_tasapromt)-(vt_ajustexinf))*100;

                    --//Calcula la Perdida
                    LET vt_tasaperdida = (vt_sdoprom * vt_tasarealperi)/100;
                    LET vt_tasaperdidatot = vt_tasaperdidatot + vt_tasaperdida;

                 END IF

           END FOREACH


           SELECT NVL(sum(imp_isr),0)
             INTO vt_isretenido
             FROM sc_isr
            WHERE cuenta = vt_cuenta
              AND secuencia BETWEEN (pEjercicio||'01') AND (pEjercicio||'12')
              AND dia_promedio > 0;

           SELECT NVL(SUM(monto_tot),0)
             INTO vt_totintpagt
             FROM sc_movhis
            WHERE YEAR(fech_alt)= pEjercicio
              AND transacc = '3276'
              AND empresa = pEmpresa
	      AND cuenta = vt_cuenta
              AND cancelad <> 'S';

           IF (vt_totintpagt - vt_interesexentot - vt_interesrealtot) <> 0 THEN
              LET vt_interesrealtot = (vt_totintpagt - vt_interesexentot);
           END IF

           IF vt_sdopromt  = 0 AND vt_totintpagt = 0 THEN
              CONTINUE FOREACH;
           END IF;

           LET vt_folio = vt_folio +1;
           INSERT INTO sc_retenisr (empresa,
                                     ejercicio,
                                     num_cte,
                                     cuenta,
                                     interes_pagado,
                                     interes_exento,
                                     interes_real,
                                     reten_interes,
                                     sdo_prom1,
                                     sdo_prom2,
                                     sdo_prom3,
                                     sdo_prom4,
                                     sdo_prom5,
                                     sdo_prom6,
                                     sdo_prom7,
                                     sdo_prom8,
                                     sdo_prom9,
                                     sdo_prom10,
                                     sdo_prom11,
                                     sdo_prom12,
                                     tasa_prom,
                                     perdida)
                             VALUES (pEmpresa,
                                     pEjercicio,
                                     vt_cliente,
                                     vt_cuenta,
                                     vt_totintpagt,
                                     vt_interesexentot,
                                     vt_interesrealtot,
                                     vt_isretenido,
                                     vt_sdoprom1,
                                     vt_sdoprom2,
                                     vt_sdoprom3,
                                     vt_sdoprom4,
                                     vt_sdoprom5,
                                     vt_sdoprom6,
                                     vt_sdoprom7,
                                     vt_sdoprom8,
                                     vt_sdoprom9,
                                     vt_sdoprom10,
                                     vt_sdoprom11,
                                     vt_sdoprom12,
                                     vt_tasapromt,
                                     vt_tasaperdidatot);

     END FOREACH;
    --// ********************************************************************
    --// Trae las cuentas de Cheques
    --// ********************************************************************
    --EXECUTE PROCEDURE coninvsr_anual(pEmpresa,pEjercicio) INTO vCodret, cVarDataErr, vt_cuantos;

   RETURN '000','', vt_folio + vt_cuantos;
END
END PROCEDURE DOCUMENT "Version: 1.00.000"
;

CREATE PROCEDURE "informix".abono_cred (pEmpresa    CHAR(3),
			     pCredito    CHAR(20),
			     pSucursal   CHAR(4),
			     pUsuario    CHAR(8),
			     pTran       CHAR(4),
			     pMonto      DECIMAL(14,2),
			     pFolio      CHAR(16),
			     pTarjeta    CHAR(20),
			     pMontoDls   DECIMAL(14,2),
			     pTpCambio   DECIMAL(14,6),
			     pFecha      DATE,
			     pReferencia CHAR(40),
			     pTpMov      CHAR(1),	
	  		     pRfcComer    VARCHAR(20),
			     pRef23       VARCHAR(23))

   RETURNING CHAR(5);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vSucCred	      CHAR(4);
   DEFINE vIvaSuc	      DECIMAL(5,3);
   DEFINE vIvaBase	      DECIMAL(5,3);
   DEFINE vTpTran             CHAR(2);
   DEFINE vTpTranRel          CHAR(2);
   DEFINE vTranRelac          CHAR(4);
   DEFINE vTranParalela       CHAR(4);
   DEFINE vTranNro	      SMALLINT;
   DEFINE vDiasRet	      SMALLINT;
   DEFINE vMensaje	      CHAR(1);
   DEFINE vProducto	      CHAR(4);
   DEFINE vTranRetuvo	      CHAR(4);
   DEFINE vDivisa             CHAR(2);
   DEFINE vMtoRet	      DECIMAL(14,2);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;



  SET LOCK MODE TO WAIT 10;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vTranNro   = pTran;
   LET vMtoRet    = 0;

   LET pTran = vTranNro;
   IF LENGTH(pTran) < 4 THEN
       LET pTran = LPAD(TRIM(pTran),4,"6");
   END IF

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   -- ******************************
   -- Extrae Parametro de IVA Base *
   -- ******************************
   SELECT valor INTO vIvaBase
     FROM bdinteg:si_param
    WHERE empresa = pEmpresa
      AND cod_param = 47;

   IF vIvaBase IS NULL THEN
	LET vIvaBase = 0;
   END IF

   -- **************************************************
   -- Extrae informacion de Sucursal e Iva del Credito *
   -- **************************************************
   SELECT a.sucursal, a.iva, b.num_producto, b.divisa
     INTO vSucCred, vIvaSuc, vProducto, vDivisa
     FROM bdinteg:si_sucursales a, sd_maecred b
    WHERE b.empresa = pEmpresa
      AND b.num_credito = pCredito
      AND a.empresa = b.empresa
      AND a.sucursal = b.sucursal;

   -- ***************************************
   -- Extrae informacion de la Transaccion  *
   -- ***************************************

   SELECT tipo_tran, NVL(tran_relac,"0000"), NVL(trancivaesp,"0000"),
	  NVL(dias_ret,0)
     INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
     FROM bdinteg:si_transacc
    WHERE empresa = pEmpresa
      AND sistema = "06"
      AND numero = pTran;

   IF LENGTH(vTranRelac) = 0 THEN
	LET vTranRelac = "0000";
   END IF

   IF LENGTH(vTranParalela) = 0 THEN
	LET vTranParalela = "0000";
   END IF
   -- **************************************************************
   -- Determina la transaccion a utilizar por clasificacion de IVA *
   -- **************************************************************
   IF vIvaSuc <> vIvaBase AND vTranParalela <> "0000" THEN
	LET pTran = vTranParalela;
   END IF

   -- ******************************************************************
   -- Determina si es reversion y busca los valores para la aplicacion *
   -- ******************************************************************
   IF pTpMov = "R" THEN
	-- Extrae Datos de la Transaccion de Reversion
	SELECT tipo_tran, NVL(tran_relac,"0000"), NVL(trancivaesp,"0000"),
               NVL(dias_ret,0)
   	  INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
     	  FROM bdinteg:si_transacc
   	 WHERE empresa = pEmpresa
      	   AND sistema = "06"
      	   AND numero = pTran;

   	IF LENGTH(vTranRelac) = 0 THEN
        	LET vTranRelac = "0000";
  	END IF

   	IF LENGTH(vTranParalela) = 0 THEN
        	LET vTranParalela = "0000";
  	 END IF

        -- Extrae Datos de la Transaccion a Reversar
	IF vTranRelac <> "0000" THEN
		LET pTran = vTranRelac;
        	SELECT tipo_tran, NVL(tran_relac,"0000"),
		       NVL(trancivaesp,"0000"), NVL(dias_ret,0)
          	  INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
          	  FROM bdinteg:si_transacc
         	 WHERE empresa = pEmpresa
           	   AND sistema = "06"
           	   AND numero = pTran;

        	IF LENGTH(vTranRelac) = 0 THEN
                	LET vTranRelac = "0000";
        	END IF

        	IF LENGTH(vTranParalela) = 0 THEN
                	LET vTranParalela = "0000";
         	END IF
	END IF

   END IF

   -- Libera Retencion por Reversion
   IF vTpTran >= "20" AND vTpTran <= "29" AND pTpMov = "R" THEN

	SELECT monto
	  INTO vMtoRet
	  FROM sd_maeretenido
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFOlio
	   AND transacc = pTran;

	UPDATE sd_maesdos SET sdo_retenido = sdo_retenido - vMtoRet
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito;

	UPDATE sd_maeretenido
	   SET estatus = "S"
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFOlio
	   AND transacc = pTran;

	UPDATE sd_movhis
	   SET reversado = "S"
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFOlio
	   AND transacc_suc = pTran;

	UPDATE sd_movdia
	   SET reversado = "S"
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFOlio
	   AND transacc_suc = pTran;

   -- Reversa Movimientos sin retencion
   ELIF vTpTran >= "00" AND vTpTran <= "19" AND pTpMov = "R" THEN

        UPDATE sd_maesdos SET sdo_capital = sdo_capital - pMonto,
                              sdo_cap_insoluto = sdo_cap_insoluto - pMonto,
                              mto_ministra_cap = mto_ministra_cap - pMonto,
                              cargos_mes_cap   = cargos_mes_cap - pMonto
         WHERE empresa = pEmpresa
           AND num_credito = pCredito;

	UPDATE sd_movdia
	   SET reversado = "S"
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFolio
	   AND transacc_suc = pTran;

   ELIF VTpTran >= "00" AND vTpTran <= "19" AND pTpMov <> "R" THEN
	UPDATE sd_maesdos SET sdo_capital = sdo_capital - pMonto,
			      sdo_cap_insoluto = sdo_cap_insoluto - pMonto,
		              mto_ministra_cap = mto_ministra_cap - pMonto,
          		      cargos_mes_cap   = cargos_mes_cap - pMonto
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito;

   END IF

   -- **************************
   -- Aplica Movimiento Diario *
   -- **************************
   IF pTpMov <> "R" THEN
   	EXECUTE PROCEDURE genmov_tc(pEmpresa, pCredito, vProducto,
                               	    pFecha, pMonto, pFolio, pSucursal,
                                    vDivisa, pTran, pTarjeta, pReferencia,
			            pTpCambio, pMontoDls, pUsuario, vSucCred,
				      pRfcComer,pRef23)
   	INTO cod_ret, vMensaje;
   	IF cod_ret <> "000" THEN
		RETURN cod_ret;
   	END IF
   END IF

   -- ************************************************
   -- Ejecuta Aplicacion de Transaccion Relacionada  *
   -- ************************************************
   IF vTranRelac IS NULL THEN
	LET vTranRelac = "0000";
   END IF

   IF vTranRelac <> "0000" THEN
	SELECT tipo_tran INTO vTpTranRel
	  FROM si_transacc
	 WHERE empresa = pEmpresa
	   AND sistema = "06"
	   AND numero = vTranRelac;

	IF pTpMov = "R" THEN
		SELECT monto INTO pMonto
	          FROM sd_movdia
		 WHERE empresa = pEmpresa
		   AND num_credito = pCredito
		   AND folio_suc = pFolio
		   AND transacc_suc = vTranRelac;
	END IF

        EXECUTE PROCEDURE abono_cred(pEmpresa, pCredito, pSucursal,
                                     pUsuario,vTranRelac, pMonto,
                                     pFolio, pTarjeta, pMontoDls,
                                     pTpCambio, pFecha, pReferencia,"R",
					       pRfcComer,pRef23)

	INTO cod_ret;

   END IF


   RETURN cod_ret;


END PROCEDURE
DOCUMENT
'Esta funcion se encarga de realizar los movimientos de abono y reversion ',
'relacionados a la tarjeta de credito',
'AUTOR : Procesaminto Interactivo S.A.',
'FECHA : 23/01/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

create procedure "informix".sp_consultafecha (dfecini char(10),dfecfin char(10))
        returning  char(5),char(20),money,date,DateTime Hour to Second,char(35),char(35),char(20),char(200) ;
        define cCodret char(5);
        define cCuenta char(20);
        define mImporte money ; --(14,2);
        define dFecha date ;
        define dHora DateTime Hour to Second ;
        define cDescripcion char(35);
        define cDescripcion2 char(35);
        define cNombre char(200);
        define cRfc char(20);
        define cSQL_ERR integer;

        let cCuenta = "";
        let mImporte= 0;
        let cDescripcion = "";
        let cDescripcion2 = "";
        let cNombre = "";
        let cRfc = "";
        let cSQL_ERR = 100 ;
        let cCodret  = "00000";
        let dFecha = "" ;
        let dHora = '' ;


--SET DEBUG FILE TO '/tmp/consxcta.out';
--TRACE ON;

BEGIN
                ON EXCEPTION SET cSQL_ERR
                LET cCodret = cSQL_ERR;
                RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre;
                END EXCEPTION;

FOREACH

select hb.cuenta,
NVL(TRIM(si_cliente.nombre1),"") ||' '|| NVL(TRIM(si_cliente.nombre2),"") ||' '|| NVL(TRIM(si_cliente.apell_paterno),"") ||' '|| NVL(TRIM(si_cliente.apell_materno),""),
rfc,cb.descripcion,ob.descripcion,hb.importe,hb.fecha,hb.hora
INTO
    cCuenta,cNombre,cRfc, cDescripcion, cDescripcion2, mImporte, dFecha, dHora
 from bdicheq:sc_maechq mae
             INNER JOIN bdinteg:si_cliente si_cliente on si_cliente.numcte= mae.num_cte
             INNER JOIN bdicheq:sc_histbloq hb on hb.cuenta=mae.cuenta
             INNER JOIN bdicheq:sc_opcionbloqueo ob  on ob.opcion= hb.opcion
             INNER JOIN bdicheq:sc_bloqueo cb on  cb.codigo=hb.motivo
where hb.fecha>=dfecini  and hb.fecha<=dfecfin
             order by hb.fecha desc,hb.hora desc

     RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre with resume ;
END FOREACH;


end;
end procedure
DOCUMENT
'AUTOR :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se creo el sp para el llenado del reporte por periodo de fechas de bloqueo.',
'Captacion',
'FECHA : Septiembre de 2008',
'VERSION: 200809',
'BD    : BDICHEQ';

create procedure "informix".sp_consultacta(cCta char(20))
        returning  char(5),char(20),money,date,DateTime Hour to Second,char(35),char(35),char(20),char(200) ;
        define cCodret char(5);
        define cCuenta char(20);
        define mImporte money ; --(14,2);
        define dFecha date ;
        define dHora DateTime Hour to Second ;
        define cDescripcion char(35);
        define cDescripcion2 char(35);
        define cNombre char(200);
        define cRfc char(20);
        define cSQL_ERR integer;

        let cCuenta = "";
        let mImporte= 0;
        let cDescripcion = "";
        let cDescripcion2 = "";
        let cNombre = "";
        let cRfc = "";
        let cSQL_ERR = 100 ;
        let cCodret  = "00000";
        let dFecha = "" ;
        let dHora = '' ;


--SET DEBUG FILE TO '/tmp/consxcta.out';
--TRACE ON;

BEGIN
                ON EXCEPTION SET cSQL_ERR
                LET cCodret = cSQL_ERR;
                RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre;
                END EXCEPTION;

FOREACH

select hb.cuenta,
NVL(TRIM(si_cliente.nombre1),"") ||' ' || NVL(TRIM(si_cliente.nombre2),"") ||' '|| NVL(TRIM(si_cliente.apell_paterno),"") ||' '|| NVL(TRIM(si_cliente.apell_materno),""),
rfc,cb.descripcion,ob.descripcion,hb.importe,hb.fecha,hb.hora
INTO
        cCuenta,cNombre,cRfc, cDescripcion, cDescripcion2, mImporte, dFecha, dHora
 from bdicheq:sc_maechq mae
             INNER JOIN bdinteg:si_cliente si_cliente on si_cliente.numcte= mae.num_cte
             INNER JOIN bdicheq:sc_histbloq hb on hb.cuenta=mae.cuenta
             INNER JOIN bdicheq:sc_opcionbloqueo ob  on ob.opcion= hb.opcion
             INNER JOIN bdicheq:sc_bloqueo cb on  cb.codigo=hb.motivo
where mae.cuenta= cCta
             order by hb.fecha desc,hb.hora desc

     RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre with resume ;
END FOREACH;


end;
end procedure
DOCUMENT
'AUTOR :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se creo el sp para el llenado del reporte por cuenta de bloqueo.',
'Captacion',
'FECHA : Septiembre de 2008',
'VERSION: 200809',
'BD    : BDICHEQ';

Create procedure "informix".sp_consultaclave(cClave char(35), dFecha1 char(10), dFecha2 char(10))
    Returning  char(5),char(20),money,date,DateTime Hour to Second,char(35),char(35),char(20),char(200);
		
	define cCodret char(5);
	define cCuenta char(20);
	define mImporte money ; --(14,2);
	define dFecha date ;
	define dHora DateTime Hour to Second ;
	define cDescripcion char(35);
	define cDescripcion2 char(35);
	define cNombre char(200);
	define cRfc char(20);
	define cSQL_ERR integer;

	let cCuenta = "";
	let mImporte= 0;
	let cDescripcion = "";
	let cDescripcion2 = "";
	let cNombre = "";
	let cRfc = "";
	let cSQL_ERR = 100 ;
	let cCodret  = "000";
	let dFecha = "" ;
	let dHora = '' ;


--SET DEBUG FILE TO '/tmp/consxcta.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET cSQL_ERR
	LET cCodret = cSQL_ERR;
	RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre;
	END EXCEPTION;

    FOREACH
        Select hb.cuenta, NVL(TRIM(si_cliente.nombre1),"") ||' '|| NVL(TRIM(si_cliente.nombre2),"") ||' '
            || NVL(TRIM(si_cliente.apell_paterno),"") ||' '|| NVL(TRIM(si_cliente.apell_materno),""),
            rfc,cb.descripcion,ob.descripcion,hb.importe,hb.fecha,hb.hora
        INTO cCuenta,cNombre,cRfc, cDescripcion, cDescripcion2, mImporte, dFecha, dHora
        From bdicheq:sc_maechq mae
			INNER JOIN bdinteg:si_cliente si_cliente on si_cliente.numcte= mae.num_cte
			INNER JOIN bdicheq:sc_histbloq hb on hb.cuenta=mae.cuenta
			INNER JOIN bdicheq:sc_opcionbloqueo ob  on ob.opcion= hb.opcion
			INNER JOIN bdicheq:sc_bloqueo cb on  cb.codigo=hb.motivo
        Where cb.descripcion = cClave
			And hb.fecha >= dFecha1 And hb.fecha <= dFecha2
        Order by hb.fecha desc,hb.hora desc

        RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre with resume;

    END FOREACH;


end;
end procedure
DOCUMENT
'AUTOR :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se creo el sp para el llenado del reporte por clave de bloqueo.',
'Captacion',
'FECHA : Septiembre de 2008',
'VERSION: 200809',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".desbloq_cuentas(pempresa char(3))

RETURNING CHAR(5);

   DEFINE vcodret     	CHAR(5);
   DEFINE sql_err     	INTEGER;
   DEFINE vcuenta	CHAR(20);
   DEFINE vstatus 	CHAR(1);
   DEFINE vmotivo 	CHAR(2);
   DEFINE vfecha	DATE;
   DEFINE vhora		CHAR(15);
   DEFINE vfolio	CHAR(20);

   LET vcodret = "000";

   BEGIN

   ON EXCEPTION
       SET sql_err
       IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
           RETURN vcodret;
       END IF;
   END EXCEPTION;

   -- SET DEBUG FILE TO "./desbloq_cuentas.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   SELECT fecha_hoy
     INTO vfecha
     FROM sc_fechas
    WHERE empresa = pempresa;

   LET vhora = current hour to fraction;

   LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
   
   FOREACH
       SELECT UNIQUE cuenta
	 INTO vcuenta
         FROM cuentas_desbloq
        WHERE cuenta IS NOT NULL

	SELECT status_cta, motivo
	  INTO vstatus, vmotivo
	  FROM sc_maechq
	 WHERE empresa = pempresa
	   AND cuenta = vcuenta;

	IF vstatus = "3" AND vmotivo = "09" THEN

            UPDATE sc_maechq
               SET status_cta = "1",
	           motivo = "00"
	     WHERE empresa = pempresa
               AND cuenta = vcuenta;

	    INSERT INTO sc_histbloq VALUES(
			pempresa, vcuenta, "D", "00", " ",
	                0.00, "informix", vfecha,
			current hour to fraction,
			"1111", "D", vfolio, " ");

	    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", 4);

            DELETE FROM sc_ctabloqueo
	     WHERE cuenta = vcuenta;

	END IF;

   END FOREACH

   END;

   RETURN vcodret;

END PROCEDURE;