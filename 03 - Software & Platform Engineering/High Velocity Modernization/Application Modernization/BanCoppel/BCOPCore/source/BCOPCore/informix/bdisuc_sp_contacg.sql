create procedure "informix".sp_contacg(pempresa    CHAR(4),
                            ptransacc   CHAR(4),
                            psucursal   CHAR(4),
                            ptesoreria  CHAR(4),
                            pdivisa     CHAR(2),
                            pproveedor  CHAR(4),
                            pnaturaleza CHAR(1),
                            pmonto      MONEY(14,2),
                            ptipo_tran  CHAR(2))
returning char(5);


DEFINE vcod_ret CHAR(5);
DEFINE wcmayor                       CHAR(4);
DEFINE wcsub1                        CHAR(3);
DEFINE wcsub2                        CHAR(3);
DEFINE wcsub3                        CHAR(3);
DEFINE wcsub4                        CHAR(3);
DEFINE wcsector                      CHAR(3);

DEFINE wamayor                       CHAR(4);
DEFINE wasub1                        CHAR(3);
DEFINE wasub2                        CHAR(3);
DEFINE wasub3                        CHAR(3);
DEFINE wasub4                        CHAR(3);
DEFINE wasector                      CHAR(3);
DEFINE vaux                          CHAR(1);
DEFINE wfecha                        DATE;
DEFINE vsecuencia                    SMALLINT;
DEFINE wnro_auxiliar                 CHAR(12);
DEFINE wnro_auxiliar2                 CHAR(12);
DEFINE vorigen                       CHAR(4);
DEFINE vdestino                      CHAR(4);


LET vcod_ret = "000";
LET wnro_auxiliar = "";
LET wnro_auxiliar2 = "";
LET vsecuencia = 0;
LET vorigen = "";
LET vdestino = "";

-- Carga los Centrso de Costo de la Transaccion Correspondiente
LET ptipo_tran = ptipo_tran;
IF ptipo_tran[1,1] = "S" THEN -- Sucursal
   LET vorigen = psucursal;
ELIF ptipo_tran[1,1] = "P" THEN --Proveedor
     LET vorigen = pproveedor;
ELIF ptipo_tran[1,1] = "T" THEN -- Tesoreria
     LET vorigen = ptesoreria;
ELSE
    LET vorigen = psucursal;
END IF
IF ptipo_tran[2,2] = "S" THEN -- Sucursal
   LET vdestino = psucursal;
ELIF ptipo_tran[2,2] = "P" THEN --Proveedor
     LET vdestino = pproveedor;
ELIF ptipo_tran[2,2] = "T" THEN -- Tesoreria
     LET vdestino = ptesoreria;
ELSE
    LET vdestino = psucursal;
END IF

--SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/conta.out";
--trace on;


       FOREACH
        -- Lee la Contabilidad para Extraer solo lo del dia
          SELECT c_ccmayor,c_ccsub,c_ccsubsub,c_ccsssub,c_ccssssub,c_sector,
                 a_ccmayor,a_ccsub,a_ccsubsub,a_ccsssub,a_ccssssub,a_sector,
                 secuencia
          INTO
                 wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,
                 wamayor,wasub1,wasub2,wasub3,wasub4,wasector,
                 vsecuencia
          FROM   bdinteg:si_prodtran
          WHERE  sistema='02' AND transaccion= ptransacc
          AND    producto='0001' order by secuencia

          -- Verifica si la Cuenta Contable Maneja Auxiliar
          IF not wcmayor IS NULL THEN
             SELECT auxiliar INTO vaux
             FROM   bdinteg:si_catalog
             WHERE  empresa= pempresa AND ccmayor = wcmayor
             AND    ccsub= wcsub1 AND ccsubsub=wcsub2
             AND    ccssubsub=wcsub3 AND ccsssubsub=wcsub4
             AND    sector=wcsector;
             IF vaux = "S" THEN
                SELECT max(fecha) into wfecha
                FROM   ss_saldossuc
                WHERE  sucursal = psucursal;
                IF NOT wfecha IS NULL THEN
                   SELECT sucursal||cajero_principal INTO wnro_auxiliar
                   FROM   ss_saldossuc
                   WHERE  fecha = wfecha
                   AND    sucursal = psucursal;
                END IF
             ELSE
              LET wnro_auxiliar = "";
             END IF
          END IF

          IF not wamayor IS NULL THEN
             SELECT auxiliar INTO vaux
             FROM   bdinteg:si_catalog
             WHERE  empresa= pempresa AND ccmayor = wamayor
             AND    ccsub= wasub1 AND ccsubsub=wasub2
             AND    ccssubsub=wasub3 AND ccsssubsub=wasub4
             AND    sector=wasector;
             IF vaux = "S" THEN
                SELECT max(fecha) into wfecha
                FROM   ss_saldossuc
                WHERE  sucursal = psucursal;
                IF NOT wfecha IS NULL THEN
                   SELECT sucursal||cajero_principal INTO wnro_auxiliar2
                   FROM   ss_saldossuc
                   WHERE  fecha = wfecha
                   AND    sucursal = psucursal;
                END IF
             ELSE
              LET wnro_auxiliar2 = "";
             END IF
          END IF

          IF pnaturaleza = "A" THEN
             -- Checa si el Transaccion Dotacion Tercero
--             IF ptransacc = "0003" or ptransacc = "0004" THEN
--                LET psucursal = ptesoreria;
--             END IF
             IF Trim(wcmayor) != "" THEN
                INSERT INTO ss_poliza(empresa,sucursal,producto,
                               cod_trans,secuencia,cargo_abono,
                      cmayor,cnivel1,cnivel2,cnivel3,cnivel4,csector,
                      nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (pempresa,vorigen,"0001",ptransacc,vsecuencia,"1",
                    wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,
                    wnro_auxiliar,pmonto,pdivisa,vdestino);
             END IF
             IF Trim(wamayor) != "" THEN
                INSERT INTO ss_poliza(empresa,sucursal,producto,
                                   cod_trans,secuencia,cargo_abono,
                      cmayor,cnivel1,cnivel2,cnivel3,cnivel4,csector,
                      nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (pempresa,vdestino,"0001",ptransacc,vsecuencia,"0",
                    wamayor,wasub1,wasub2,wasub3,wasub4,wasector,
                    wnro_auxiliar2,pmonto,pdivisa,vorigen);
             END IF
          ELSE
             -- Checa si el Transaccion Dotacion Tercero
--             IF ptransacc = "0003" or ptransacc = "0004" THEN
--                LET psucursal = ptesoreria;
--             END IF
             IF Trim(wcmayor) != "" THEN
                INSERT INTO ss_poliza(empresa,sucursal,producto,
                               cod_trans,secuencia,cargo_abono,
                      cmayor,cnivel1,cnivel2,cnivel3,cnivel4,csector,
                      nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (pempresa,vorigen,"0001",ptransacc,vsecuencia,"1",
                    wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,
                    wnro_auxiliar,pmonto,pdivisa,vdestino);
             END IF
             IF Trim(wamayor) != "" THEN
                INSERT INTO ss_poliza(empresa,sucursal,producto,
                                   cod_trans,secuencia,cargo_abono,
                      cmayor,cnivel1,cnivel2,cnivel3,cnivel4,csector,
                      nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (pempresa,vdestino,"0001",ptransacc,vsecuencia,"0",
                    wamayor,wasub1,wasub2,wasub3,wasub4,wasector,
                    wnro_auxiliar2,pmonto,pdivisa,vorigen);
             END IF
          END IF
       END FOREACH;

       RETURN vcod_ret;


END PROCEDURE
;