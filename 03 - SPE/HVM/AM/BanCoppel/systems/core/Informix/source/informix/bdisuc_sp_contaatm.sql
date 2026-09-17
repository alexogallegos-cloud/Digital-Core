CREATE PROCEDURE "informix".sp_contaatm(pempresa     CHAR(4),
                                        ptransacc    CHAR(4),
                                        psucursal    CHAR(4),
                                        ptesoreria   CHAR(4),
                                        pdivisa      CHAR(2),
                                        pproveedor   CHAR(4),
                                        pnaturaleza  CHAR(1),
                                        pmonto       MONEY(14,2),
                                        ptipo_tran   CHAR(2),
                                        pmotivo_afecta CHAR(2))
returning char(5);


DEFINE vcod_ret CHAR(5);
DEFINE wcmayor                       CHAR(4);
DEFINE wcsub1                        CHAR(3);
DEFINE wcsub2                        CHAR(3);
DEFINE wcsub3                        CHAR(3);
DEFINE wcsub4                        CHAR(3);
DEFINE wcsector                      CHAR(3);

-- Por Referencias Contables
DEFINE wrcmayor                       CHAR(4);
DEFINE wrcsub1                        CHAR(3);
DEFINE wrcsub2                        CHAR(3);
DEFINE wrcsub3                        CHAR(3);
DEFINE wrcsub4                        CHAR(3);
DEFINE wrcsector                      CHAR(3);
DEFINE wramayor                       CHAR(4);
DEFINE wrasub1                        CHAR(3);
DEFINE wrasub2                        CHAR(3);
DEFINE wrasub3                        CHAR(3);
DEFINE wrasub4                        CHAR(3);
DEFINE wrasector                      CHAR(3);

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
DEFINE wnro_auxiliar2                CHAR(12);
DEFINE wc_nro_auxiliar 				 CHAR(12);
DEFINE wa_nro_auxiliar 				 CHAR(12);
DEFINE vorigen                       CHAR(4);
DEFINE vdestino                      CHAR(4);
DEFINE vpcuenta 			         CHAR(14);


LET vcod_ret = "000";
LET wnro_auxiliar = "";
LET wnro_auxiliar2 = "";
LET wc_nro_auxiliar = "";
LET wa_nro_auxiliar = "";
LET vsecuencia = 0;
LET vorigen = "";
LET vdestino = "";

LET wrcmayor = "";
LET wrcsub1 = "";
LET wrcsub2 = "";
LET wrcsub3 = "";
LET wrcsub4 = "";
LET wrcsector = "";
LET wramayor = "";
LET wrasub1 = "";
LET wrasub2 = "";
LET wrasub3 = "";
LET wrasub4 = "";
LET wrasector = "";
LET ptipo_tran = ptipo_tran;

SET LOCK MODE TO WAIT 3;

-- Carga los Centrso de Costo de la Transaccion Correspondiente
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

--SET debug file to "/tmp/sp_contaatm.out";
--trace on;

    FOREACH
        -- Lee la Contabilidad para Extraer solo lo del dia
        SELECT c_ccmayor,c_ccsub,c_ccsubsub,c_ccsssub,c_ccssssub,c_sector,
               a_ccmayor,a_ccsub,a_ccsubsub,a_ccsssub,a_ccssssub,a_sector,secuencia
        INTO wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,
             wamayor,wasub1,wasub2,wasub3,wasub4,wasector,vsecuencia
        FROM bdinteg:"informix".si_prodtran
        WHERE sistema='04' 
            AND transaccion= ptransacc
            AND producto='0001' 
        ORDER BY secuencia
         
        -- Checa la Referencia por el Motivo y si hay la Asigna al Cargo a Abono
        IF NOT pmotivo_afecta IS NULL AND Trim(pmotivo_afecta) != "" AND pmotivo_afecta != "00" AND vsecuencia = 1 THEN --Referencia 
            LET pmotivo_afecta = pmotivo_afecta;
            IF ptransacc = "0042" OR ptransacc = "0043" THEN --Voltea las cuentas ya que el Eliminacion
                SELECT a_ccmayor,a_ccsub,a_ccsubsub,a_ccsssub,a_ccssssub,a_sector,
                       c_ccmayor,c_ccsub,c_ccsubsub,c_ccsssub,c_ccssssub,c_sector,a_nro_auxiliar,c_nro_auxiliar
                INTO wrcmayor,wrcsub1,wrcsub2,wrcsub3,wrcsub4,wrcsector,
                     wramayor,wrasub1,wrasub2,wrasub3,wrasub4,wrasector,wc_nro_auxiliar,wa_nro_auxiliar
                FROM bdisuc:"informix".ss_motiv_afecta
                WHERE codigo = pmotivo_afecta;

				IF ptransacc = "0042" AND pmotivo_afecta = "04" THEN
					SELECT valor
					  INTO vpcuenta 
                      FROM bdisuc:ss_param_cajagen where codigo='0060';

					LET wrcmayor = SUBSTR(vpcuenta,1,4);
					LET wrcsub1 =  SUBSTR(vpcuenta,5,2);
					LET wrcsub2 =  SUBSTR(vpcuenta,7,2);
					LET wrcsub3 =  SUBSTR(vpcuenta,9,2);
				    LET wrcsub4 =  SUBSTR(vpcuenta,11,2);
					LET wrcsector= SUBSTR(vpcuenta,13,2);
				END IF

            ELSE
                SELECT c_ccmayor,c_ccsub,c_ccsubsub,c_ccsssub,c_ccssssub,c_sector,
                       a_ccmayor,a_ccsub,a_ccsubsub,a_ccsssub,a_ccssssub,a_sector,c_nro_auxiliar,a_nro_auxiliar
                INTO wrcmayor,wrcsub1,wrcsub2,wrcsub3,wrcsub4,wrcsector,
                     wramayor,wrasub1,wrasub2,wrasub3,wrasub4,wrasector,wc_nro_auxiliar,wa_nro_auxiliar
                FROM bdisuc:"informix".ss_motiv_afecta
                WHERE codigo = pmotivo_afecta;
            END IF;

            IF NOT wrcmayor IS NULL AND wrcmayor != "" THEN
                LET wcmayor = wrcmayor;
                LET wcsub1 = wrcsub1;
                LET wcsub2 = wrcsub2;
                LET wcsub3 = wrcsub3;
                LET wcsub4 = wrcsub4;
                LET wcsector = wrcsector; 
				LET wnro_auxiliar=wc_nro_auxiliar ;
            END IF;

            IF NOT wramayor IS NULL AND wramayor != "" THEN

                LET wamayor = wramayor;
                LET wasub1 = wrasub1;
                LET wasub2 = wrasub2;
                LET wasub3 = wrasub3;
                LET wasub4 = wrasub4;
                LET wasector = wrasector; 
				LET wnro_auxiliar2 = wa_nro_auxiliar ;

            END IF;
        END IF;

          -- Verifica si la Cuenta Contable Maneja Auxiliar
        IF NOT wcmayor IS NULL THEN
             SELECT auxiliar 
             INTO vaux
             FROM   bdinteg:"informix".si_catalog
             WHERE  empresa= pempresa 
                AND ccmayor = wcmayor
                AND ccsub= wcsub1 
                AND ccsubsub=wcsub2
                AND ccssubsub=wcsub3 
                AND ccsssubsub=wcsub4
                AND sector=wcsector;
             IF vaux = "S" AND wc_nro_auxiliar = "" THEN
                SELECT max(fecha) 
                INTO wfecha
                FROM bdisuc:"informix".ss_saldossuc
                WHERE  sucursal = psucursal;
                IF NOT wfecha IS NULL THEN
                   SELECT sucursal||cajero_principal 
                   INTO wnro_auxiliar
                   FROM bdisuc:"informix".ss_saldossuc
                   WHERE  fecha = wfecha
                        AND sucursal = psucursal;
                END IF
             ELIF wc_nro_auxiliar = "" THEN
                LET wnro_auxiliar = "";
             END IF
        END IF

         IF NOT wamayor IS NULL THEN
             SELECT auxiliar 
             INTO vaux
             FROM   bdinteg:"informix".si_catalog
             WHERE  empresa= pempresa 
                AND ccmayor = wamayor
                AND ccsub= wasub1 
                AND ccsubsub=wasub2
                AND ccssubsub=wasub3 
                AND ccsssubsub=wasub4
                AND sector=wasector;
            IF vaux = "S" AND wa_nro_auxiliar = "" THEN
                SELECT max(fecha) 
                INTO wfecha
                FROM bdisuc:"informix".ss_saldossuc
                WHERE  sucursal = psucursal;
                IF NOT wfecha IS NULL THEN
                   SELECT sucursal||cajero_principal 
                   INTO wnro_auxiliar2
                   FROM bdisuc:"informix".ss_saldossuc
                   WHERE fecha = wfecha
                        AND sucursal = psucursal;
                END IF
            ELIF wa_nro_auxiliar = "" THEN
                LET wnro_auxiliar2 = "";
            END IF
        END IF
		--SE AGREGA GRABACION EN TABLA HISTORICA  DE PASE CONTABLE ss_pasehis
        IF pnaturaleza = "A" THEN
            IF Trim(wcmayor) != "" THEN
                INSERT INTO bdisuc:"informix".ss_poliza_atm(empresa,sucursal,producto,cod_trans,secuencia,cargo_abono,cmayor,cnivel1,cnivel2,cnivel3,
                                          cnivel4,csector,nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (pempresa,vdestino,"0001",ptransacc,vsecuencia,"1",wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,wnro_auxiliar,
                        pmonto,pdivisa,vorigen);
						
		INSERT INTO  bdisuc:"informix".ss_pasehis (fecha, empresa,sucursal,producto,cod_trans,secuencia,cargo_abono,cmayor,cnivel1,cnivel2,cnivel3,
                                          cnivel4,csector,nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (date (current),pempresa,vdestino,"0001",ptransacc,vsecuencia,"1",wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,wnro_auxiliar,
                        pmonto,pdivisa,vorigen);
						
            END IF
            IF Trim(wamayor) != "" THEN
                INSERT INTO bdisuc:"informix".ss_poliza_atm(empresa,sucursal,producto,cod_trans,secuencia,cargo_abono,cmayor,cnivel1,cnivel2,cnivel3,
                                          cnivel4,csector,nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (pempresa,vdestino,"0001",ptransacc,vsecuencia,"0",wamayor,wasub1,wasub2,wasub3,wasub4,wasector,wnro_auxiliar2,
                        pmonto,pdivisa,vorigen);
						
				INSERT INTO  bdisuc:"informix".ss_pasehis (fecha, empresa,sucursal,producto,cod_trans,secuencia,cargo_abono,cmayor,cnivel1,cnivel2,cnivel3,
                                          cnivel4,csector,nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (date (current),pempresa,vdestino,"0001",ptransacc,vsecuencia,"0",wamayor,wasub1,wasub2,wasub3,wasub4,wasector,wnro_auxiliar2,
                        pmonto,pdivisa,vorigen);
            END IF
        ELSE
             IF Trim(wcmayor) != "" THEN
                INSERT INTO bdisuc:"informix".ss_poliza_atm(empresa,sucursal,producto,cod_trans,secuencia,cargo_abono,cmayor,cnivel1,cnivel2,cnivel3,
                                          cnivel4,csector,nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (pempresa,vdestino,"0001",ptransacc,vsecuencia,"1",wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,wnro_auxiliar,
                        pmonto,pdivisa,vorigen);
						
				INSERT INTO  bdisuc:"informix".ss_pasehis (fecha, empresa,sucursal,producto,cod_trans,secuencia,cargo_abono,cmayor,cnivel1,cnivel2,cnivel3,
                                          cnivel4,csector,nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (date (current),pempresa,vdestino,"0001",ptransacc,vsecuencia,"1",wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,wnro_auxiliar,
                        pmonto,pdivisa,vorigen);
						
             END IF
             IF Trim(wamayor) != "" THEN
                INSERT INTO bdisuc:"informix".ss_poliza_atm(empresa,sucursal,producto,cod_trans,secuencia,cargo_abono,cmayor,cnivel1,cnivel2,cnivel3,
                                          cnivel4,csector,nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (pempresa,vdestino,"0001",ptransacc,vsecuencia,"0",wamayor,wasub1,wasub2,wasub3,wasub4,wasector,wnro_auxiliar2,
                        pmonto,pdivisa,vorigen);
						
				INSERT INTO  bdisuc:"informix".ss_pasehis (fecha, empresa,sucursal,producto,cod_trans,secuencia,cargo_abono,cmayor,cnivel1,cnivel2,cnivel3,
                                          cnivel4,csector,nro_auxiliar,monto,divisa,cod_proveedor)
                VALUES (date (current),pempresa,vdestino,"0001",ptransacc,vsecuencia,"1",wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,wnro_auxiliar,
                        pmonto,pdivisa,vorigen);
             END IF
          END IF
        END FOREACH;

       RETURN vcod_ret;

END PROCEDURE;