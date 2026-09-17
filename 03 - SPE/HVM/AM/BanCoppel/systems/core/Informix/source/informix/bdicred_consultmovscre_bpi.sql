CREATE PROCEDURE "informix".consultmovscre_bpi(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro SMALLINT)
   RETURNING CHAR(5),DATE,CHAR(23),CHAR(40),CHAR(1),MONEY(14,2),MONEY(14,2);

--Modificó: Javier Calderón Zazueta
--Fecha: 25/02/09
--Solicitó: Mauricio León
--Actividad: Consultar los movimientos de una cuenta de crédito durante un periodo indicado
-----------------------------------------------------------------------------------------------------------------------
--Modificó: Mauricio León
--Fecha: 10/03/09
--Solicitó: Mauricio León
--Actividad: Agregar RFC a Descripción en caso de que Referencia contenga "intercar"
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

   BEGIN
      ON EXCEPTION SET vsqlerr
         IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor;
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
         RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor;
      END IF;

     -- Extrae los movimientos del rango de fechas especificado
     FOREACH
       (SELECT SKIP pRegistro FIRST 10
            secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = ''
            THEN c.transacc ELSE TRIM(a.referencia) END CASE, b.descripcion,
            naturaleza, monto, a.referencia23, a.rfc_comer, b.numero
         INTO vserial,vfecha,vRefTotal,cDescripcion,vnaturaleza,vmonto, vReferencia23, vRfcComer, vTrans
         FROM sd_movdia a, bdinteg:si_transacc b, sd_transfun c
         WHERE a.empresa = pempresa
         AND a.num_credito = pcuenta
         AND c.empresa = a.empresa
         --AND c.codigo_fun = a.codigo_fun
         --AND c.codigo_ref = a.codigo_ref
     AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
         AND b.empresa = c.empresa
         AND b.numero = c.transacc
         AND b.sistema = "06"
         AND b.se_emite_edocta = "S"
         AND a.reversado = "N"
		 AND fecha_mov >=pFechaInicial
         AND fecha_mov <= pFechaFinal
     --UNION ALL
     UNION
        SELECT secuencia, fecha_mov, CASE WHEN NVL(TRIM(a.referencia),'') = ''
            THEN c.transacc ELSE TRIM(a.referencia) END CASE, b.descripcion,
            naturaleza, monto, a.referencia23, a.rfc_comer, b.numero
         FROM sd_movhis a, bdinteg:si_transacc b, sd_transfun c
         WHERE a.empresa = pempresa
         AND a.num_credito = pcuenta
         AND c.empresa = a.empresa
         --AND c.codigo_fun = a.codigo_fun
         --AND c.codigo_ref = a.codigo_ref
     AND trim(c.codigo_fun)||c.codigo_ref = trim(a.codigo_fun)||a.codigo_ref
         AND b.empresa = c.empresa
         AND b.numero = c.transacc
		 AND b.sistema = "06"  --Se agrega validacion por sistema 06
         AND b.se_emite_edocta = "S"
         AND a.reversado = "N"
         AND fecha_mov >= pFechaInicial
         AND fecha_mov <= pFechaFinal)
         ORDER BY fecha_mov desc,secuencia desc

         IF vnaturaleza = "C" THEN
            LET vmonto = (vmonto*(-1));
         END IF;

         IF (vTrans = '6801' or vTrans = '6830') THEN
        --IF vRefTotal[1,8] = "intercar" THEN
                LET cDescripcion = TRIM(SUBSTRING(vRefTotal FROM 16));
                LET vReferencia = NVL(TRIM(vReferencia23),'');
                IF cDescripcion[1,8] = "intercar" THEN
                        LET cDescripcion = TRIM(SUBSTRING(cDescripcion FROM 16));
                END IF;
                LET cDescripcion = TRIM(cDescripcion) || " " || NVL(TRIM(vRfcComer),'');
        ELSE
            LET vReferencia = TRIM(vRefTotal);
        END IF;
        
         RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor WITH RESUME;
     END FOREACH;
END
END PROCEDURE;