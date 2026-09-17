CREATE PROCEDURE "informix".sp_consultamovscre_iccat(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro SMALLINT)
   RETURNING CHAR(5), DATE, CHAR(4), CHAR(23), CHAR(40), CHAR(1), MONEY(14,2), MONEY(14,2);

---------------------------------------------------------------------------
-- Realizó: Mauricio León
-- Actividad: Obtiene movimientos de una cuenta de crédito
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 27/11/2008
--------------------------------------------------------------------------
--Modificó: Mauricio León
--Fecha: 04/06/09
--Solicitó: Mauricio León
--Actividad: Agregar RFC a Descripción en caso de que Referencia contenga "intercar"
--------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE vserial       INTEGER;
   DEFINE cDescripcion     CHAR(40);
   DEFINE vFecha        DATE;
   DEFINE vTrans    CHAR(4);
   DEFINE vMonto        MONEY(14,2);
   DEFINE cReferencia    CHAR(23);
   DEFINE vRefTotal CHAR(100);
   DEFINE vReferencia23  CHAR(23);
   DEFINE vNaturaleza   CHAR(1);
   DEFINE vSdoDeudor    DECIMAL(14,2);
   DEFINE vRfcComer     CHAR(15);
   DEFINE vcodret       CHAR(5);
   DEFINE vsqlerr       INTEGER;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET vcodret = "000";
   LET vserial = 0;
   LET cDescripcion = " ";
   LET vFecha = '01/01/1900';
   LET vTrans = '';
   LET vMonto = 0;
   LET vSdoDeudor = 0;
   LET vNaturaleza = '';
   LET cReferencia = '';
   LET vReferencia23 = '';
   LET vRefTotal = '';
   LET vRfcComer = '';
   LET vsqlerr = 0;

   BEGIN
      ON EXCEPTION SET vsqlerr
         IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vFecha, vTrans, cReferencia,cDescripcion,vNaturaleza,vMonto,vSdoDeudor;
         END IF
      END EXCEPTION;

    SET ISOLATION TO DIRTY READ;

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
         RETURN vcodret,vFecha, vTrans, cReferencia,cDescripcion,vNaturaleza,vMonto,vSdoDeudor;
      END IF;

     -- Extrae los movimientos del rango de fechas especificado
     FOREACH
       (SELECT SKIP pRegistro FIRST 10
            secuencia, fecha_mov, c.transacc, NVL(a.referencia,''), b.descripcion, naturaleza, monto, a.referencia23, a.rfc_comer
         INTO vserial, vFecha, vTrans, vRefTotal,cDescripcion,vNaturaleza,vMonto, vReferencia23, vRfcComer
         FROM sd_movdia a, bdinteg:si_transacc b, sd_transfun c
         WHERE a.empresa = pempresa
         AND a.num_credito = pcuenta
         AND c.empresa = a.empresa
         AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
         AND b.empresa = c.empresa
         AND b.numero = c.transacc
         AND b.sistema = "06"
         AND b.se_emite_edocta = "S"
         AND a.reversado = "N"
         AND fecha_mov >=pFechaInicial
         AND fecha_mov <= pFechaFinal
     UNION
        SELECT secuencia, fecha_mov, c.transacc, NVL(a.referencia,''), b.descripcion, naturaleza, monto, a.referencia23, a.rfc_comer
         FROM sd_movhis a, bdinteg:si_transacc b, sd_transfun c
         WHERE a.empresa = pempresa
         AND a.num_credito = pcuenta
         AND c.empresa = a.empresa
         AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
         AND b.empresa = c.empresa
         AND b.numero = c.transacc
         AND b.se_emite_edocta = "S"
         AND a.reversado = "N"
         AND fecha_mov >= pFechaInicial
         AND fecha_mov <= pFechaFinal)
         ORDER BY fecha_mov desc,secuencia desc

         IF vNaturaleza = "C" THEN
            LET vMonto = (vmonto*(-1));
         END IF

         IF vRefTotal[1,8] = "intercar" THEN
                LET cDescripcion = TRIM(SUBSTRING(vRefTotal FROM 16));
                LET cReferencia = NVL(TRIM(vReferencia23),'');
                IF cDescripcion[1,8] = "intercar" THEN
                        LET cDescripcion = TRIM(SUBSTRING(cDescripcion FROM 16));
                END IF;
                LET cDescripcion = TRIM(cDescripcion) || " " || NVL(TRIM(vRfcComer),'');
        ELIF TRIM(vRefTotal) = '' THEN
            LET cReferencia = NVL(TRIM(vReferencia23),'');
        ELSE
            LET cReferencia = TRIM(vRefTotal);
        END IF;

         RETURN vcodret,vFecha, vTrans, cReferencia,cDescripcion,vNaturaleza,vMonto,vSdoDeudor WITH RESUME;
     END FOREACH;
END
END PROCEDURE ;