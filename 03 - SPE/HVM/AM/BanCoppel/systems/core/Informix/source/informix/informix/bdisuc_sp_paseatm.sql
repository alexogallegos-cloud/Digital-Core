CREATE PROCEDURE "informix".sp_paseatm(pempresa   CHAR(3),
                                       pfecha_pase DATE,
                                       pusuario   CHAR(8))
RETURNING CHAR(5);

   DEFINE vcod_ret                      CHAR(5);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);
   DEFINE v_error                       smallint;
   DEFINE wbegin                        CHAR(1);
   DEFINE wusuario                      CHAR(8);
   DEFINE wejecutivo                    CHAR(8);
   DEFINE wfecha_hoy                    DATE;
   DEFINE nrows                         SMALLINT;
   DEFINE wdescripcion_det              CHAR(80);
   DEFINE wdivisa                       CHAR(2);
   DEFINE vsecuencia                    SMALLINT;
   DEFINE vregional                     CHAR(3);
   DEFINE vsucdest                      CHAR(4);
   DEFINE wproveedor                    CHAR(4);
   DEFINE wnro_auxiliar                 CHAR(12);
   DEFINE vnaturaleza                   CHAR(1);
   DEFINE wmotiv_afecta                 CHAR(2);
   DEFINE wcmayor                       CHAR(4);
   DEFINE wcsub1                        CHAR(3);
   DEFINE wcsub2                        CHAR(3);
   DEFINE wcsub3                        CHAR(3);
   DEFINE wcsub4                        CHAR(3);
   DEFINE wcsector                      CHAR(3);
   DEFINE vcargo                        CHAR(1);

{****************************************************************************
 **         INICIA REGISTRO DE PASE CONTABLE                               **
 ****************************************************************************}

   DEFINE wsucursal                     CHAR(4);
   DEFINE wtransacc                     CHAR(4);
   DEFINE wprocedencia                  CHAR(4);
   DEFINE wstatus                       CHAR(2);
   DEFINE wmonto                        MONEY(14,2);

{***************************************************************************
 **   TERMINA REGISTRO DE ENCABEZADO DE POLIZA                            **
 ***************************************************************************}

   DEFINE wsectoriza                    CHAR(1);
   DEFINE detusuario                    CHAR(8);
   DEFINE dcontrol_poliza               SMALLINT;
   DEFINE wfolio                        CHAR(8);
   DEFINE wtesoreria                    CHAR(4);
   DEFINE vfecha_envio                  DATE;
   DEFINE vfecha_recep                  DATE;
   DEFINE vtranenvio                    CHAR(4);
   DEFINE vtipo_tran                    CHAR(2);
   DEFINE vdescripcion                  CHAR(50);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET vcod_ret = sql_err;
      SET DEBUG FILE TO "pasecont.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      IF (wbegin = "S") THEN
         ROLLBACK WORK;
         BEGIN WORK;
      ELSE
         ROLLBACK WORK;
      END IF;
      RETURN vcod_ret;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wbegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION;

   --set debug file to "/tmp/sp_paseatm.out";
   --TRACE ON;
   LET pusuario = "atms";
   LET wbegin = "S";
   LET detusuario = pusuario;
   LET wprocedencia = "";
   LET wstatus = "";
   LET wtesoreria = "";
   LET vfecha_envio = "";
   LET vfecha_recep = "";
   LET wproveedor = "";
   LET vcargo = "";
   LET vtipo_tran = "";
   LET vdescripcion = "";
   LET wmotiv_afecta = "";
   LET wusuario = pusuario;
   LET wnro_auxiliar = " ";
   LET wdescripcion_det = " ";

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
   SET ISOLATION COMMITTED READ;

   SET LOCK MODE TO WAIT 3;

   BEGIN WORK;
      LET vcod_ret = "000";

      SELECT fecha_hoy
      INTO wfecha_hoy
      FROM bdinteg:"informix".si_fechas
      WHERE empresa = pempresa;

      --borra lo existente en la base de contabilidad
      DELETE FROM bdisuc:"informix".ss_poliza_atm;

      DELETE FROM bdicont:"informix".co_poldet
      WHERE empresa = pempresa
        AND fecha_captura = pfecha_pase
        AND usuario = pusuario;

      DELETE FROM bdicont:"informix".co_detpol
      WHERE empresa = pempresa
        AND fecha_captura = pfecha_pase
        AND usuario = pusuario;

      DELETE FROM bdicont:"informix".co_poliza
      WHERE empresa = pempresa
        AND fecha_captura = pfecha_pase
        AND usuario = pusuario;

      -- Carga el Centro de Costo de Tesoreria
      SELECT valor 
      INTO wtesoreria
      FROM bdisuc:"informix".ss_param_cajagen
      WHERE codigo = "0034" 
        AND empresa=pempresa;

      SELECT ejecutivo,sucursal
      INTO wejecutivo,vsucdest
      FROM bdinteg:"informix".si_ejecut
      WHERE empresa = pempresa
        AND ejecutivo = pusuario;

      LET nrows = dbinfo("sqlca.sqlerrd2");

      IF (nrows = 0) THEN
         LET vcod_ret = "090";
         IF (wbegin = "S") THEN
            ROLLBACK WORK;
            BEGIN WORK;
         ELSE
            ROLLBACK WORK;
         END IF;
         RETURN vcod_ret;
      END IF;

      FOREACH
	   SELECT cod_trans,o.sucursal,divisa,procedencia,monto,folio_oper,motiv_afecta
         INTO wtransacc,wsucursal,wdivisa,wprocedencia,wmonto,wfolio,wmotiv_afecta
         FROM bdisuc:"informix".ss_operaciones o, bdisuc:ss_atms_sucursal a
        WHERE o.cod_trans IN ("0037","0038","0039","0040","0041","0042","0043")
	      AND o.fecha_operacion = pfecha_pase
		  AND o.sucursal > '0'
          AND o.reversado NOT IN ('1','SI','si')
          AND o.monto > 0
          AND a.cod_atm = o.sucursal

        -- Verifica si la Transaccion Contabiliza
        SELECT naturaleza,tipo_tran,descripcion
          INTO vnaturaleza,vtipo_tran,vdescripcion
          FROM bdinteg:"informix".si_transacc
         WHERE sistema='04' 
           AND se_contabiliza='S' 
           AND empresa = pempresa 
           AND numero = wtransacc;
        
        IF vnaturaleza IS NULL OR vnaturaleza = "" THEN
            CONTINUE FOREACH;
        END IF

        LET vtranenvio = wtransacc; -- Transacciones Normales
        CALL bdisuc:"informix".sp_contaatm(pempresa,vtranenvio,wsucursal,wtesoreria,wdivisa,wprocedencia,vnaturaleza,wmonto,vtipo_tran,wmotiv_afecta)
        returning vcod_ret;
        IF Trim(vcod_ret) != "000" THEN
            RETURN vcod_ret;
        END IF
      END FOREACH

      LET vsecuencia = 1;
      
      FOREACH
        SELECT sucursal,cod_trans,divisa,cmayor,cnivel1,cnivel2,cnivel3,cnivel4,csector,nro_auxiliar,monto,cargo_abono,cod_proveedor,NVL(UPPER(t.descripcion),'SIN ESPECIFICAR') as descripcion 
        INTO wsucursal,wtransacc,wdivisa,wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,wnro_auxiliar,wmonto,vcargo,vsucdest,wdescripcion_det
        FROM bdisuc:ss_poliza_atm p, bdinteg:si_transacc t
       WHERE t.sistema='04'
         AND t.numero=p.cod_trans
         AND t.empresa = '001'
         AND p.cod_trans = t.numero  

        SELECT regional 
        INTO vregional
        FROM bdinteg:"informix".si_plazas a,bdinteg:si_sucursales b
        WHERE a.plaza = b.plaza
          AND sucursal=wsucursal;

        IF vcargo = "1" THEN
             INSERT INTO bdicont:"informix".co_poldet(usuario,fecha_captura,secuencia,empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
                                           ciudad,sucursal,nro_auxiliar,naturaleza,monto,descripcion_det,fecha_valida,moneda,ccosto_orig)
             VALUES(pusuario,pfecha_pase,vsecuencia,pempresa,wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,vregional,wsucursal,
                    wnro_auxiliar,"D",wmonto,wdescripcion_det,wfecha_hoy,wdivisa,vsucdest);
        END IF

        IF vcargo = "0" THEN
             INSERT INTO bdicont:"informix".co_poldet(usuario,fecha_captura,secuencia,empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
                                           ciudad,sucursal,nro_auxiliar,naturaleza,monto,descripcion_det,fecha_valida,moneda,ccosto_orig)
             VALUES(pusuario,pfecha_pase,vsecuencia,pempresa,wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,vregional,wsucursal,
                    wnro_auxiliar,"C",wmonto,wdescripcion_det,wfecha_hoy,wdivisa,vsucdest);
        END IF

        LET vsecuencia = vsecuencia + 1;

      END FOREACH;

      IF (wbegin = "S") THEN
        COMMIT WORK;
        BEGIN WORK;
      ELSE
        COMMIT WORK;
      END IF;

      --EJECUTA EL PROCESO DE AUDITOR
      LET pfecha_pase = pfecha_pase;
      LET pempresa = pempresa;
      LET detusuario = detusuario;

      EXECUTE PROCEDURE bdicont:"informix".AUDITAPASE(pfecha_pase,pempresa,detusuario)

      INTO vcod_ret;

      COMMIT WORK;      
      RETURN vcod_ret;

END PROCEDURE;