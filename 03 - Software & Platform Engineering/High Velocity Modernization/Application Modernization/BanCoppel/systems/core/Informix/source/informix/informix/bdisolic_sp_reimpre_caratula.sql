CREATE PROCEDURE "informix".sp_reimpre_caratula(eEmpresa     CHAR(3),
                                                 eNumCte      CHAR(20),
                                                 eNumProducto CHAR(4),
                                                 eTipoSol     INTEGER,
                                                 eRegist      INTEGER)

        RETURNING char(5)      ,  --CodRet
                  decimal(14,2),  --Mto. Solicitado
                  integer      ,  --Plazo
                  decimal(9,6) ,  --Tasa Interes
                  char(4)      ,  --Sucursal
                  decimal(14,2),  --Capital
                  decimal(14,2),  --Interes
                  decimal(14,2),  --Iva
                  char(20)     ,  --NumSol
                  date         ,  --Fec. Cuota
                  char(20)     ,  --Cuenta(Se genera en co_numcte de ss_solicitudes)
                  date         ,  --Fec. Apertura
                  char(8)      ,  --Cat
                  decimal(9,6) ,  --Tasa Mora
                  char(20)     ,  --Numero de Tarjeta
                  DECIMAL(14,2),  --Enganche
                  CHAR(20)     ;  --MontoAdeudo

  DEFINE vCodRet      CHAR(5);
  DEFINE vMtoSol      DECIMAL(14,2);
  DEFINE vTasaInt     DECIMAL(9,6);
  DEFINE vTasaMora    DECIMAL(9,6);
  DEFINE vCapital     DECIMAL(14,2);
  DEFINE vInteres     DECIMAL(14,2);
  DEFINE vIva         DECIMAL(14,2);
  DEFINE vPlazo       INTEGER;
  DEFINE sqlerr       INTEGER;
  DEFINE vStatus      CHAR(2);
  DEFINE vSucursal    CHAR(4);
  DEFINE vNumSol      CHAR(20);
  DEFINE vCuenta      CHAR(20);
  DEFINE vCat         CHAR(8);
  DEFINE vEnvia       INTEGER;
  DEFINE vFecCuota    DATE;
  DEFINE vFecAper     DATE;
  DEFINE vNumTarjeta  CHAR(20);
  DEFINE vEnganche    DECIMAL(14,2);
  DEFINE vMontoAdeudo CHAR(20);
  DEFINE vdummy       CHAR(100);

  LET vCodRet      = '000';
  LET vMtoSol      = 0;
  LET vTasaInt     = 0;
  LET vCapital     = 0;
  LET vInteres     = 0;
  LET vIva         = 0;
  LET vPlazo       = 0;
  LET vSucursal    = '';
  LET vEnvia       = 0;
  LET vNumSol      = '';
  LET vCuenta      = '';
  LET vFecCuota    = '';
  LET vFecAper     = '';
  LET vStatus      = '';
  LET vTasaMora    = 0;
  LET vCat         = '';
  LET vNumTarjeta  = '';
  LET vEnganche    = 0;
  LET vMontoAdeudo = '';

BEGIN
        ON EXCEPTION
             SET sqlerr
             LET vCodRet = sqlerr;
             return vCodRet,vMtoSol,vPlazo,vTasaInt,vSucursal,vCapital,vInteres,vIva,vNumSol,vFecCuota,
                    vCuenta,vFecAper,vCat,vTasaMora,vNumTarjeta,vEnganche,vMontoAdeudo;
        END EXCEPTION;

        --SET DEBUG FILE TO "/tmp/sp_reimpre_caratula.out";
        --TRACE ON;

       IF eTipoSol = 0 THEN
         LET vStatus = 'AP';
       ELSE
         LET vStatus = 'CC';
       END IF;

--FMV 6-DIC-12 : Se cambia codigo para Cat con iva solo Reestructura
       SELECT valor
       INTO vCat
       FROM bdicred:sd_param
       WHERE empresa = eEmpresa
         AND cod_param='321';




        SELECT monto_solicitado,plazo,tasa_interes,sucursal,num_solicitud,fecha_apert_prop,co_numcte,tasa_moratorios
        INTO vMtoSol,vPlazo,vTasaInt,vSucursal,vNumSol,vFecAPer,vCuenta,vTasaMora
        FROM ss_solicitudes
        WHERE empresa          = eEmpresa
          AND numcte           =  eNumCte
          AND status_solicitud = vStatus
          AND num_producto     = eNumProducto
          AND (periodo_plazo  Is not Null Or periodo_plazo <> '');


{        FOREACH
            SELECT num_tarjeta, status_tar
              INTO vNumTarjeta, vdummy
              FROM bdicred:sd_tarjeta tar, bdicred:sd_maecred mae
             WHERE mae.empresa = tar.empresa
               AND mae.num_credito = tar.num_credito
               AND mae.numcte = eNumCte
               AND tipo_tarjeta ='T'
             ORDER BY status_tar

            EXIT FOREACH;

        END FOREACH;
}

         SELECT otro_presta,otro_copresta, num_acta
           INTO vEnganche, vMontoAdeudo, vNumTarjeta
           FROM bdisolic:ss_anexosol
          WHERE empresa       = eEmpresa
            AND num_solicitud  = vNumSol;

       FOREACH
              SELECT capital_cuota,interes_cuota,iva_cuota,fecha_cuota
              INTO vCapital,vInteres,vIva,vFecCuota
              FROM bdicred:sd_proyecta
              WHERE empresa       = eEmpresa
                AND num_solicitud = vNumSol

              IF  vEnvia  < eRegist THEN
                 LET vEnvia = vEnvia + 1;
                 CONTINUE FOREACH;
              END IF;
              LET vEnvia = vEnvia + 1;
             return vCodRet,vMtoSol,vPlazo,vTasaInt,vSucursal,vCapital,vInteres,vIva,vNumSol,vFecCuota,
                    vCuenta,vFecAper,vCat,vTasaMora,vNumTarjeta,vEnganche,vMontoAdeudo with resume;

       END FOREACH;
END

END PROCEDURE
;