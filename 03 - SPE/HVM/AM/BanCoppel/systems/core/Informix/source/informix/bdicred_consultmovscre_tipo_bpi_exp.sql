CREATE PROCEDURE "informix".consultmovscre_tipo_bpi_exp(pEmpresa CHAR(3), pCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro SMALLINT)
   RETURNING CHAR(5),DATE,CHAR(23),CHAR(40),CHAR(1),MONEY(14,2),MONEY(14,2),CHAR(4),CHAR(1);

    -----------------------------------------------------------------------------------------------------------------------
    --SE CLONA SPL: Berenice Noriega
    --Fecha: 16/MAYO/2019
    --Solicita: Alejandro Vazquez
    --Actividad: Se regresa parametros extras que indica si es titular o adicional el movimiento asi como la terminacion
    --Se renombra spl de consultmovscre_bpi a consultmovscre_tipo_bpi	
    --Proximo a liberar	
	
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

   BEGIN
      ON EXCEPTION SET vsqlerr
         IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor,vTerminacion,vTipo;
         END IF
      END EXCEPTION;

	--SET debug FILE TO "/informix/gaby/ArchivosOut/consultmovscre_tipo_bpi.out";
    --Trace ON;

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
         RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor, vTerminacion, vTipo;
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
            b.descripcion, naturaleza, monto, a.referencia23, a.rfc_comer, b.numero, d.num_tarjeta, d.tipo_tarjeta
            INTO vserial,vfecha,vRefTotal,cDescripcion,vnaturaleza,vmonto, vReferencia23, vRfcComer, vTrans, vTarjeta, vTipo
             FROM sd_movdia a
                JOIN sd_transfun c ON (a.codigo_fun = c.codigo_fun and a.codigo_ref = c.codigo_ref)
                JOIN bdinteg:si_transacc b ON (c.transacc = b.numero)
                LEFT OUTER JOIN sd_tarjeta d ON (a.nro_tarjeta=d.num_tarjeta)
             WHERE a.empresa = pempresa
             AND a.num_credito = pcuenta
             AND b.sistema = "06"
             AND b.se_emite_edocta = "S"
             AND a.reversado = "N"
             AND fecha_mov between pFechaInicial and pFechaFinal

        UNION ALL
        SELECT a.secuencia, fecha_mov,
            CASE WHEN NVL(TRIM(a.referencia),'') = ''
              THEN c.transacc
            ELSE TRIM(a.referencia) END CASE,
            b.descripcion, naturaleza, monto, a.referencia23, a.rfc_comer, b.numero, d.num_tarjeta, d.tipo_tarjeta
             FROM sd_movhis a
                JOIN sd_transfun c ON (a.codigo_fun = c.codigo_fun and a.codigo_ref = c.codigo_ref)
                JOIN bdinteg:si_transacc b ON (c.transacc = b.numero)
                LEFT OUTER JOIN sd_tarjeta d ON (a.nro_tarjeta=d.num_tarjeta)
             WHERE a.empresa = pempresa
             AND a.num_credito = pcuenta
             AND b.sistema = "06"
             AND b.se_emite_edocta = "S"
             AND a.reversado = "N"
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
				
		IF (vTarjeta='' or vTarjeta is null) THEN
			LET vTipo='S';
			LET vTerminacion='';
		ELSE 
			LET vTarjeta = NVL(TRIM(vTarjeta),'');
			LET vTerminacion = SUBSTR(vTarjeta,13,4); 
		END IF;
			
			
		
         RETURN vcodret,vfecha,vReferencia,cDescripcion,vnaturaleza,vmonto,vSdoDeudor, vTerminacion, vTipo WITH RESUME;
     END FOREACH;
END
END PROCEDURE;