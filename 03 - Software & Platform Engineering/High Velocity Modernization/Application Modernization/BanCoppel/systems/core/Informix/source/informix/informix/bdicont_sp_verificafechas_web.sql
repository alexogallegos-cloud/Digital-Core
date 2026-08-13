CREATE PROCEDURE  "informix".sp_verificafechas_web(pfecha_sucursal  date)

   RETURNING CHAR(5),
             DATE,
             CHAR (1);
--Definicion de variables
   DEFINE cod_ret           CHAR(5);
   DEFINE sql_err           INTEGER;
   DEFINE vfecha_central    DATE;
   DEFINE iDiferencia       SMALLINT; 

-- Inicializa variables

   LET cod_ret           = "00000";
   LET vfecha_central    = "";
   
   BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret,vfecha_central,iDiferencia;
      END IF;
   END EXCEPTION;
   
   SET ISOLATION DIRTY READ;
   SET LOCK MODE TO WAIT 3;

-- Valida los parametros de entrada
      IF pfecha_sucursal is null THEN 
         LET cod_ret = "00110";
         RETURN cod_ret,vfecha_central,iDiferencia;
      END IF

-- Valida la sucursal asignada,como el usuario del Pase Contable

   SELECT fecha_hoy 
   INTO vfecha_central
   FROM bdinteg:si_fechas; 

   IF vfecha_central >= pfecha_sucursal THEN
      LET iDiferencia = 0; --Sigue Ejecucion
   ELSE
      LET iDiferencia = 1;
   END IF;

  RETURN cod_ret,vfecha_central,iDiferencia;
END;
END PROCEDURE
DOCUMENT
    'DESCRIPCION: Realiza una consulta la tabla co_fechas para obtener la fecha hoy y compararla con la fecha hoy recibida en pfecha_sucursal, esto es para',
                 'determinar, sÃ­ las fechas son iguales, el pase contable debe realizarse, si existe diferencia este no debe permitir su ejecuciÃ³n.',
    'AUTOR: Cristian Valentina Aguilar',
    'FECHA: Julio 2009',
    'VERSION: 20090706',
    'BD: BDICONT';

CREATE PROCEDURE "informix".sp_conciliaxctacontab(
                               pempresa         char(3),
                               psucursal        char(4),
                               pfecha           date,
                               pctaconta        char(14),
                               pnaturaleza      char(1),
                               psistema         char(2))
RETURNING char(5), char(4), char(16), char(4),
          char(50), money(14,2), char(1), char(1),char(16);

--//Definicion de variables
DEFINE vcodret        CHAR(5);
DEFINE vsqlerr        INTEGER;
DEFINE vt_producto 	  CHAR(4);
DEFINE vt_folio       CHAR(16);
DEFINE vt_cuenta      CHAR(16);
DEFINE vt_transacc    CHAR(4);
DEFINE vt_descripcion CHAR(16);
DEFINE vt_monto       MONEY(14,2);
DEFINE vt_status      CHAR(1);
DEFINE vt_naturaleza  CHAR(1);
DEFINE vDesErr        CHAR (30);
DEFINE iCuantos       INTEGER;
DEFINE vfec_movhis    DATE;
DEFINE val_ifrs       CHAR(1);

   on exception set vsqlerr
	if vsqlerr <> 0 then
	   let vcodret = vsqlerr;
           RETURN vcodret,null,null,null,null,null, null, null,null;
	end if
   end exception;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   --set debug file to "/tmp/sp_conciliaxctacontab.out";
   --trace on;

    --//Inicializacion de variables
   LET vcodret    = "000";
   LET val_ifrs   = '';

   IF pempresa ="" OR psucursal ="" OR pctaconta ="" OR pnaturaleza ="" THEN
      LET vcodret = "110";
      RETURN vcodret,null,null,null,null,null, null, null,null;
   END IF

IF psistema = '01' THEN

	SELECT MDY(SUBSTR(VALOR,1,2),SUBSTR(VALOR,4,2),SUBSTR(VALOR,7,4))
          INTO vfec_movhis
		  FROM bdicheq:sc_param 
         WHERE codparam='fechcon_movhis';

	IF pfecha >= vfec_movhis THEN

	   SELECT {+INDEX(bdinteg:"informix".si_transacc idx_transacc2)}
              his.producto, his.folio_suc, his.transacc, tran.descripcion,
              his.monto_tot, cancelad, naturaleza,
              trim(c_ccmayor)|| trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) as cuenta1, his.cuenta
		FROM bdicheq:"informix".sc_movhis his,
               bdinteg:"informix".si_transacc tran,
               bdinteg:"informix".si_prodtran prod
		WHERE his.empresa = pempresa
		  AND his.cuenta <> ''
		  AND his.fech_alt = pfecha
		  AND his.cancelad <> 'S'
		  AND his.transacc = tran.numero
		  AND his.sucursal = psucursal
		  AND his.transacc_suc <> '0000'
		  AND tran.sistema = psistema
		  AND tran.numero = his.transacc
		  AND tran.empresa = his.empresa
		  AND prod.transaccion = tran.numero
		  AND prod.producto = his.producto
		  AND prod.sistema = tran.sistema
		  AND ((TRIM(prod.c_ccmayor) = '9512' OR TRIM(prod.c_ccmayor) = '9513'))
		  INTO TEMP tmp_concil_chq
          WITH NO LOG;
	   INSERT INTO tmp_concil_chq
	   SELECT {+INDEX(bdinteg:"informix".si_transacc idx_transacc2)}
              his.producto, his.folio_suc, his.transacc, tran.descripcion,
              his.monto_tot, cancelad, naturaleza,
              trim(a_ccmayor)|| trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) as cuenta1, his.cuenta
		FROM bdicheq:"informix".sc_movhis his,
               bdinteg:"informix".si_transacc tran,
               bdinteg:"informix".si_prodtran prod
		WHERE his.empresa = pempresa
		  AND his.cuenta <> ''
		  AND his.fech_alt = pfecha
		  AND his.cancelad <> 'S'
		  AND his.transacc = tran.numero
		  AND his.sucursal = psucursal
		  AND his.transacc_suc <> '0000'
		  AND tran.sistema = psistema
		  AND tran.numero = his.transacc
		  AND tran.empresa = his.empresa
		  AND prod.transaccion = tran.numero
		  AND prod.producto = his.producto
		  AND prod.sistema = tran.sistema
		  AND ((TRIM(prod.a_ccmayor) = '9512' OR TRIM(prod.a_ccmayor) = '9513'));

	ELSE

	   SELECT {+INDEX(bdinteg:"informix".si_transacc idx_transacc2)}
              his.producto, his.folio_suc, his.transacc, tran.descripcion,
              his.monto_tot, cancelad, naturaleza,
              trim(c_ccmayor)|| trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) as cuenta1, his.cuenta
		FROM bdicheq:"informix".sc_movhis_old his,
               bdinteg:"informix".si_transacc tran,
               bdinteg:"informix".si_prodtran prod
		WHERE his.empresa = pempresa
		  AND his.cuenta <> ''
		  AND his.fech_alt = pfecha
		  AND his.cancelad <> 'S'
		  AND his.transacc = tran.numero
		  AND his.sucursal = psucursal
		  AND his.transacc_suc <> '0000'
		  AND tran.sistema = psistema
		  AND tran.numero = his.transacc
		  AND tran.empresa = his.empresa
		  AND prod.transaccion = tran.numero
		  AND prod.producto = his.producto
		  AND prod.sistema = tran.sistema
		  AND ((TRIM(prod.c_ccmayor) = '9512' OR TRIM(prod.c_ccmayor) = '9513'))
		  INTO TEMP tmp_concil_chq
          WITH NO LOG;

	   INSERT INTO tmp_concil_chq
	   SELECT {+INDEX(bdinteg:"informix".si_transacc idx_transacc2)}
              his.producto, his.folio_suc, his.transacc, tran.descripcion,
              his.monto_tot, cancelad, naturaleza,
              trim(a_ccmayor)|| trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) as cuenta1, his.cuenta
		FROM bdicheq:"informix".sc_movhis_old his,
               bdinteg:"informix".si_transacc tran,
               bdinteg:"informix".si_prodtran prod
		WHERE his.empresa = pempresa
		  AND his.cuenta <> ''
		  AND his.fech_alt = pfecha
		  AND his.cancelad <> 'S'
		  AND his.transacc = tran.numero
		  AND his.sucursal = psucursal
		  AND his.transacc_suc <> '0000'
		  AND tran.sistema = psistema
		  AND tran.numero = his.transacc
		  AND tran.empresa = his.empresa
		  AND prod.transaccion = tran.numero
		  AND prod.producto = his.producto
		  AND prod.sistema = tran.sistema
		  AND ((TRIM(prod.a_ccmayor) = '9512' OR TRIM(prod.a_ccmayor) = '9513'));

    END IF

    DELETE FROM bdicheq:tmp_concil_chq where producto = '1100' AND transacc != '0223';
	DELETE FROM bdicheq:tmp_concil_chq where transacc in ('0221','0239','0251');
	--DELETE FROM bdicheq:tmp_concil_chq where producto in ('1300','1200') AND transacc = '0239';

	CREATE INDEX idx_tmp_concil_chq ON tmp_concil_chq(cuenta1);
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_concil_chq(cuenta1);
    FOREACH
       SELECT producto, folio_suc, transacc, descripcion,
              monto_tot, cancelad, naturaleza, cuenta
         INTO vt_producto, vt_folio, vt_transacc, vt_descripcion,
              vt_monto, vt_status, vt_naturaleza, vt_cuenta
         FROM bdicheq:tmp_concil_chq
        WHERE cuenta1 = pctaconta
        ORDER BY folio_suc ASC

       RETURN vcodret, vt_producto, vt_folio, vt_transacc, vt_descripcion,
              vt_monto, vt_status, vt_naturaleza, vt_cuenta WITH RESUME;
    END FOREACH

    DROP TABLE tmp_concil_chq;

ELIF psistema = '03' THEN

        SELECT his.folio_suc, his.transacc, tran.descripcion,
               his.monto_tot, cancelad, naturaleza,
               trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) as cuenta1, mae.cuenta
          FROM bdinteg:si_prodtran prod, bdinvers:sv_maeinv mae,
               bdinvers:sv_movhis his, bdinteg:si_transacc tran
         WHERE his.empresa  = pempresa
           AND his.cuenta   = mae.cuenta
           AND his.fech_alt = pfecha
           AND his.cancelad = cancelad
           AND his.transacc = prod.transaccion
           AND his.sucursal = psucursal
           AND prod.empresa = tran.empresa
           AND prod.producto = mae.cod_instrum
           AND prod.sistema = tran.sistema
           AND prod.transaccion = tran.numero
           AND prod.secuencia  >= 1
           INTO TEMP tmp_concil_inv
           WITH NO LOG;

           CREATE INDEX idx_tmp_concil_inv ON tmp_concil_inv(cuenta1);
           UPDATE statistics MEDIUM FOR TABLE tmp_concil_inv(cuenta1);

   FOREACH
      SELECT folio_suc, transacc, descripcion,
             monto_tot, cancelad , naturaleza, cuenta
        INTO vt_folio, vt_transacc, vt_descripcion,
             vt_monto, vt_status, vt_naturaleza, vt_cuenta
        FROM bdicred:tmp_concil_inv
       WHERE cuenta1 = pctaconta
       ORDER BY folio_suc ASC

        RETURN vcodret, vt_producto, vt_folio, vt_transacc, vt_descripcion,
              vt_monto, vt_status, vt_naturaleza, vt_cuenta WITH RESUME;
   END FOREACH

   DROP TABLE tmp_concil_inv;

ELIF psistema = '06' THEN
	
	
	--Valida si esta activo el IFRS	
	   select NVL(valor,'I') 
	     into val_ifrs 
		 from bdicred:"informix".sd_param 
		where cod_param = '700';

	   IF (val_ifrs = 'I') THEN

		   SELECT {+INDEX(bdinteg:si_transacc idx_transacc1),+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}
				 his.num_producto, his.folio_suc, ttra.transacc, tran.descripcion,
				 his.monto, reversado, naturaleza , his.num_credito
			FROM bdicred:sd_movhis his, bdinteg:si_transacc tran,
				 bdicred:sd_transfun ttra
		   WHERE his.empresa = pempresa
			 AND his.num_credito is not null
			 AND his.codigo_fun = ttra.codigo_fun
			 AND his.codigo_ref = ttra.codigo_ref
			 AND his.fecha_mov = pfecha
			 AND his.reversado <> 'S'
			 AND his.sucursal = psucursal
			 AND tran.empresa = ttra.empresa
			 AND tran.numero = ttra.transacc
			 AND tran.sistema = psistema
			 INTO TEMP tmp_concil_crd_1
			 WITH NO LOG;
	   ELSE
		   SELECT {+INDEX(bdinteg:si_transacc idx_transacc1),+INDEX(bdicred:sd_transfun idx_sd_transfun_codigos)}
				 his.num_producto, his.folio_suc, ttra.transacc_ifrs transacc, tran.descripcion,
				 his.monto, reversado, naturaleza , his.num_credito
			FROM bdicred:sd_movhis his, bdinteg:si_transacc tran,
				 bdicred:sd_transfun ttra
		   WHERE his.empresa = pempresa
			 AND his.num_credito is not null
			 AND his.codigo_fun = ttra.codigo_fun
			 AND his.codigo_ref = ttra.codigo_ref
			 AND his.fecha_mov = pfecha
			 AND his.reversado <> 'S'
			 AND his.sucursal = psucursal
			 AND tran.empresa = ttra.empresa
			 AND tran.numero = ttra.transacc_ifrs
			 AND tran.sistema = psistema
			 INTO TEMP tmp_concil_crd_1
			 WITH NO LOG;	   
	   END IF;

	  	  SELECT num_producto, folio_suc, '600' AS transacc, 'PAGO TARJETA DE CREDITO EFECTIVO' as descripcion,
                 sum(monto) as monto, reversado, 'A' as naturaleza,
                 trim(c_ccmayor)||trim(c_ccsub)||trim(c_ccsubsub)||trim(c_ccsssub)||trim(c_ccssssub)||trim(c_sector) as cuenta1,
				 num_credito
            FROM tmp_concil_crd_1 t, bdinteg:si_prodtran prod
           WHERE prod.transaccion = t.transacc
             AND prod.producto = t.num_producto
             AND prod.sistema = '06'
        GROUP BY 1,2,3,4,6,7,8,9
         INTO TEMP tmp_concil_crd
         WITH NO LOG;
   
          INSERT INTO tmp_concil_crd
	  	  SELECT num_producto, folio_suc, '603' AS transacc, 'RETIRO TARJETA DE CREDITO' as descripcion,
                 sum(monto) as monto, reversado, 'C' as naturaleza,
                 trim(a_ccmayor)||trim(a_ccsub)||trim(a_ccsubsub)||trim(a_ccsssub)||trim(a_ccssssub)||trim(a_sector) as cuenta1,
				 num_credito
            FROM tmp_concil_crd_1 t, bdinteg:si_prodtran prod
           WHERE prod.transaccion = t.transacc
             AND prod.producto = t.num_producto
             AND prod.sistema = '06'
        GROUP BY 1,2,3,4,6,7,8,9; 

         CREATE INDEX idx_tmp_concil_crd ON tmp_concil_crd(cuenta1);
         UPDATE STATISTICS MEDIUM FOR TABLE tmp_concil_crd(cuenta1);

   FOREACH
    SELECT num_producto, folio_suc, transacc, descripcion,
           monto, reversado, naturaleza, num_credito
      INTO vt_producto, vt_folio, vt_transacc, vt_descripcion,
           vt_monto, vt_status, vt_naturaleza, vt_cuenta
      FROM bdicred:tmp_concil_crd
     WHERE cuenta1 = pctaconta
     ORDER BY folio_suc ASC

       RETURN vcodret, vt_producto, vt_folio, vt_transacc, vt_descripcion,
              vt_monto, vt_status, vt_naturaleza, vt_cuenta WITH RESUME;
   END FOREACH

   DROP TABLE tmp_concil_crd_1;
   DROP TABLE tmp_concil_crd;

ELIF psistema = '21' THEN

       RETURN vcodret, vt_producto, vt_folio, vt_transacc, vt_descripcion,
              vt_monto, vt_status, vt_naturaleza, vt_cuenta WITH RESUME;
END IF;

END PROCEDURE;