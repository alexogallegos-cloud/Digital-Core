CREATE PROCEDURE "informix".sp_actsdomensual(eEmpresa      CHAR(3),
                                             eNumCredito   CHAR(20),
                                             eFecMov       DATE,
                                             eAnio         SMALLINT,
                                             eMes          CHAR(2),
                                             eStatusCred   CHAR(2))

RETURNING CHAR(5);

--//Definicion de Variables
 DEFINE vsqlerr            INTEGER;
 DEFINE vCodRet            CHAR(5);
 DEFINE vSucursal          CHAR(4);
 DEFINE vCapVig            DECIMAL(14,2);
 DEFINE vCapTrans          DECIMAL(14,2);
 DEFINE vCapVecNoExig      DECIMAL(14,2);
 DEFINE vCapVencExig       DECIMAL(14,2);
 DEFINE vCapVigProm        DECIMAL(14,2);
 DEFINE vCapTransProm      DECIMAL(14,2);
 DEFINE vCapVecNoExigProm  DECIMAL(14,2);
 DEFINE vCapVencExigProm   DECIMAL(14,2);
 DEFINE vProvInt           DECIMAL(14,2);
 DEFINE vProvIva           DECIMAL(14,2);
 DEFINE vProvIntVenc       DECIMAL(14,2);
 DEFINE vProIvaVenc        DECIMAL(14,2);
 DEFINE eSdoCapital        DECIMAL(14,2);
 DEFINE eMontoVencido      DECIMAL(14,2);
 DEFINE eCapTrasNo         DECIMAL(14,2);
 DEFINE eMtoVencTrasp      DECIMAL(14,2);
 DEFINE vDiaCapVig         INTEGER;
 DEFINE vDiaCapTrans       INTEGER;
 DEFINE vDiaCapVencExig    INTEGER;
 DEFINE vDiaCapVencNoExig  INTEGER;


 LET vCodRet           = '000';
 LET vsqlerr           = 0;
 LET vSucursal         = '';
 LET vCapVig           = 0;
 LET vCapTrans         = 0;
 LET vCapVecNoExig     = 0;
 LET vCapVencExig      = 0;
 LET vDiaCapVig        = 0;
 LET vDiaCapTrans      = 0;
 LET vDiaCapVencNoExig  = 0;
 LET vDiaCapVencExig   = 0;
 LET vCapVigProm       = 0;
 LET vCapTransProm     = 0;
 LET vCapVecNoExigProm = 0;
 LET vCapVencExigProm  = 0;
 LET eSdoCapital       = 0;
 LET eMontoVencido     = 0;
 LET eCapTrasNo        = 0;
 LET eMtoVencTrasp     = 0;
 LET vProvInt          = 0;
 LET vProvIva          = 0;
 LET vProvIntVenc      = 0;
 LET vProIvaVenc       = 0;

 -- CONTROL DE ERRORES
BEGIN
 ON EXCEPTION SET vsqlerr
    IF vsqlerr != 0 THEN
       LET vCodRet=vsqlerr;
       RETURN vCodRet;
    END IF;
 END EXCEPTION;

  -- SET DEBUG FILE TO "sp_actsdodiario.out";
  -- TRACE ON;

    -- ** Calcula Promedios Por Capitales **--
    SELECT nvl(acucapvig,0),       nvl(diacapvig,0),
           nvl(acucaptra,0),       nvl(diacaptra,0),
           nvl(acucapvennoexig,0), nvl(diacapvennoexig,0),
           nvl(acucapvencexig,0),  nvl(diacapvencexig,0),
           sucursal
    INTO vCapVig       , vDiaCapVig,
         vCapTrans     , vDiaCapTrans,
         vCapVecNoExig , vDiaCapVencExig,
         vCapVencExig  , vDiaCapVencExig,
         vSucursal
    FROM sd_sdodiario
    WHERE fecha=mdy(month(eFecMov),'01',year(eFecMov))  ---cas
     AND  num_credito = eNumCredito
     AND  (acucapvig       > 0 Or
          acucaptra       > 0 Or
          acucapvennoexig > 0 Or
          acucapvencexig  > 0);

    if (vSucursal is not null) then
       --** Valores Para Acumular Al Mes **--
        LET eSdoCapital   = vCapVig;
        LET eMontoVencido = vCapTrans;
        LET eCapTrasNo    = vCapVecNoExig;
        LET eMtoVencTrasp = vCapVencExig;


        IF vDiaCapVig > 0 THEN
          LET vCapVigProm = vCapVig / vDiaCapVig;
        ELSE
           LET vCapVigProm = 0;
        END IF ;
        IF vDiaCapTrans > 0 THEN
          LET vCapTransProm = vCapTrans / vDiaCapTrans;
        ELSE
           LET vCapTransProm = 0;
        END IF;
        IF vDiaCapVencExig > 0 THEN
          LET vCapVecNoExigProm = vCapVecNoExig / vDiaCapVencExig;
        ELSE
           LET vCapVecNoExigProm = 0;
        END IF;
        IF vDiaCapVencExig > 0 THEN
          LET vCapVencExigProm = vCapVencExig / vDiaCapVencExig;
        ELSE
           LET vCapVencExigProm = 0;
        END IF;

        -- ** Interes e Iva De Saldos Fin Mes Vigentes
        SELECT nvl(sum(monto),0)
        INTO vProvInt
        FROM sd_movhis
        WHERE empresa     = eEmpresa
          AND num_credito = eNumCredito
          AND codigo_fun  = '606'
          AND codigo_ref  = 1
          AND fecha_mov   = eFecMov;

        SELECT nvl(sum(monto),0)
        INTO vProvIva
        FROM sd_movhis
        WHERE empresa     = eEmpresa
          AND num_credito = eNumCredito
          AND codigo_fun  = '605'
          AND codigo_ref  = 2
          AND fecha_mov   = eFecMov;

        -- ** Interes e Iva De Saldos Fin Mes Vencidos
        SELECT nvl(sum(monto),0)
        INTO vProvIntVenc
        FROM sd_movhis
        WHERE empresa     = eEmpresa
          AND num_credito = eNumCredito
          AND codigo_fun  = '334'
          AND codigo_ref  = 5
          AND fecha_mov   = eFecMov;

        SELECT nvl(sum(monto),0)
        INTO vProIvaVenc
        FROM sd_movhis
        WHERE empresa     = eEmpresa
          AND num_credito = eNumCredito
          AND codigo_fun  = '340'
          AND codigo_ref  = 22
          AND fecha_mov   = eFecMov;

        IF EXISTS (SELECT num_credito FROM sd_sdomensual
                              WHERE num_credito = eNumCredito
                                AND anio = eAnio) THEN
                   UPDATE sd_sdomensual SET estatus1           = DECODE(eMes,1,eStatusCred,estatus1),
                                           capvig1             = DECODE(eMes,1,eSdoCapital,capvig1),
                                           capvigprom1         = DECODE(eMes,1,vCapVigProm,capvigprom1),
                                           captrans1           = DECODE(eMes,1,eMontoVencido,captrans1),
                                           captransprom1       = DECODE(eMes,1,vCapTransProm,captransprom1),
                                           capvencnoexig1      = DECODE(eMes,1,eCapTrasNo,capvencnoexig1),
                                           capvencnoexigprom1  = DECODE(eMes,1,vCapVecNoExigProm,capvencnoexigprom1),
                                           capvenexig1         = DECODE(eMes,1,eMtoVencTrasp,capvenexig1),
                                           capvencexigprom1    = DECODE(eMes,1,vCapVencExigProm,capvencexigprom1),
                                           intvig1             =  DECODE(eMes,1,vProvInt,intvig1),
                                           intvenc1            =  DECODE(eMes,1,vProvIntVenc,intvenc1),
                                           ivaintvig1          =  DECODE(eMes,1,vProvIva,ivaintvig1),
                                           ivaintvenc1         =  DECODE(eMes,1,vProvIntVenc,ivaintvenc1),
                                           
                                           estatus2            = DECODE(eMes,2,eStatusCred,estatus2),
                                           capvig2             = DECODE(eMes,2,eSdoCapital,capvig2),
                                           capvigprom2         = DECODE(eMes,2,vCapVigProm,capvigprom2),
                                           captrans2           = DECODE(eMes,2,eMontoVencido,captrans2),
                                           captransprom2       = DECODE(eMes,2,vCapTransProm,captransprom2),
                                           capvencnoexig2      = DECODE(eMes,2,eCapTrasNo,capvencnoexig2),
                                           capvencnoexigprom2  = DECODE(eMes,2,vCapVecNoExigProm,capvencnoexigprom2),
                                           capvenexig2         = DECODE(eMes,2,eMtoVencTrasp,capvenexig2),
                                           capvencexigprom2    = DECODE(eMes,2,vCapVencExigProm,capvencexigprom2),
                                           intvig2             =  DECODE(eMes,2,vProvInt,intvig2),
                                           intvenc2            =  DECODE(eMes,2,vProvIntVenc,intvenc2),
                                           ivaintvig2          =  DECODE(eMes,2,vProvIva,ivaintvig2),
                                           ivaintvenc2         =  DECODE(eMes,2,vProvIntVenc,ivaintvenc2),

                                           estatus3            = DECODE(eMes,3,eStatusCred,estatus3),
                                           capvig3             = DECODE(eMes,3,eSdoCapital,capvig3),
                                           capvigprom3         = DECODE(eMes,3,vCapVigProm,capvigprom3),
                                           captrans3           = DECODE(eMes,3,eMontoVencido,captrans3),
                                           captransprom3       = DECODE(eMes,3,vCapTransProm,captransprom3),
                                           capvencnoexig3      = DECODE(eMes,3,eCapTrasNo,capvencnoexig3),
                                           capvencnoexigprom3  = DECODE(eMes,3,vCapVecNoExigProm,capvencnoexigprom3),
                                           capvenexig3         = DECODE(eMes,3,eMtoVencTrasp,capvenexig3),
                                           capvencexigprom3    = DECODE(eMes,3,vCapVencExigProm,capvencexigprom3),
                                           intvig3             = DECODE(eMes,3,vProvInt,intvig3),
                                           intvenc3            = DECODE(eMes,3,vProvIntVenc,intvenc3),
                                           ivaintvig3          = DECODE(eMes,3,vProvIva,ivaintvig3),
                                           ivaintvenc3         = DECODE(eMes,3,vProvIntVenc,ivaintvenc3),

                                           estatus4            = DECODE(eMes,4,eStatusCred,estatus4),
                                           capvig4             = DECODE(eMes,4,eSdoCapital,capvig4),
                                           capvigprom4         = DECODE(eMes,4,vCapVigProm,capvigprom4),
                                           captrans4           = DECODE(eMes,4,eMontoVencido,captrans4),
                                           captransprom4       = DECODE(eMes,4,vCapTransProm,captransprom4),
                                           capvencnoexig4      = DECODE(eMes,4,eCapTrasNo,capvencnoexig4),
                                           capvencnoexigprom4  = DECODE(eMes,4,vCapVecNoExigProm,capvencnoexigprom4),
                                           capvenexig4         = DECODE(eMes,4,eMtoVencTrasp,capvenexig4),
                                           capvencexigprom4    = DECODE(eMes,4,vCapVencExigProm,capvencexigprom4),
                                           intvig4             = DECODE(eMes,4,vProvInt,intvig4),
                                           intvenc4            = DECODE(eMes,4,vProvIntVenc,intvenc4),
                                           ivaintvig4          = DECODE(eMes,4,vProvIva,ivaintvig4),
                                           ivaintvenc4         = DECODE(eMes,4,vProvIntVenc,ivaintvenc4),

                                           estatus5            = DECODE(eMes,5,eStatusCred,estatus5),
                                           capvig5             = DECODE(eMes,5,eSdoCapital,capvig5),
                                           capvigprom5         = DECODE(eMes,5,vCapVigProm,capvigprom5),
                                           captrans5           = DECODE(eMes,5,eMontoVencido,captrans5),
                                           captransprom5       = DECODE(eMes,5,vCapTransProm,captransprom5),
                                           capvencnoexig5      = DECODE(eMes,5,eCapTrasNo,capvencnoexig5),
                                           capvencnoexigprom5  = DECODE(eMes,5,vCapVecNoExigProm,capvencnoexigprom5),
                                           capvenexig5         = DECODE(eMes,5,eMtoVencTrasp,capvenexig5),
                                           capvencexigprom5    = DECODE(eMes,5,vCapVencExigProm,capvencexigprom5),
                                           intvig5             = DECODE(eMes,5,vProvInt,intvig5),
                                           intvenc5            = DECODE(eMes,5,vProvIntVenc,intvenc5),
                                           ivaintvig5          = DECODE(eMes,5,vProvIva,ivaintvig5),
                                           ivaintvenc5         = DECODE(eMes,5,vProvIntVenc,ivaintvenc5),

                                           estatus6            = DECODE(eMes,6,eStatusCred,estatus6),
                                           capvig6             = DECODE(eMes,6,eSdoCapital,capvig6),
                                           capvigprom6         = DECODE(eMes,6,vCapVigProm,capvigprom6),
                                           captrans6           = DECODE(eMes,6,eMontoVencido,captrans6),
                                           captransprom6       = DECODE(eMes,6,vCapTransProm,captransprom6),
                                           capvencnoexig6      = DECODE(eMes,6,eCapTrasNo,capvencnoexig6),
                                           capvencnoexigprom6  = DECODE(eMes,6,vCapVecNoExigProm,capvencnoexigprom6),
                                           capvenexig6         = DECODE(eMes,6,eMtoVencTrasp,capvenexig6),
                                           capvencexigprom6    = DECODE(eMes,6,vCapVencExigProm,capvencexigprom6),
                                           intvig6             = DECODE(eMes,6,vProvInt,intvig6),
                                           intvenc6            = DECODE(eMes,6,vProvIntVenc,intvenc6),
                                           ivaintvig6          = DECODE(eMes,6,vProvIva,ivaintvig6),
                                           ivaintvenc6         = DECODE(eMes,6,vProvIntVenc,ivaintvenc6),

                                           estatus7            = DECODE(eMes,7,eStatusCred,estatus7),
                                           capvig7             = DECODE(eMes,7,eSdoCapital,capvig7),
                                           capvigprom7         = DECODE(eMes,7,vCapVigProm,capvigprom7),
                                           captrans7           = DECODE(eMes,7,eMontoVencido,captrans7),
                                           captransprom7       = DECODE(eMes,7,vCapTransProm,captransprom7),
                                           capvencnoexig7      = DECODE(eMes,7,eCapTrasNo,capvencnoexig7),
                                           capvencnoexigprom7  = DECODE(eMes,7,vCapVecNoExigProm,capvencnoexigprom7),
                                           capvenexig7         = DECODE(eMes,7,eMtoVencTrasp,capvenexig7),
                                           capvencexigprom7    = DECODE(eMes,7,vCapVencExigProm,capvencexigprom7),
                                           intvig7             = DECODE(eMes,7,vProvInt,intvig7),
                                           intvenc7            = DECODE(eMes,7,vProvIntVenc,intvenc7),
                                           ivaintvig7          = DECODE(eMes,7,vProvIva,ivaintvig7),
                                           ivaintvenc7         = DECODE(eMes,7,vProvIntVenc,ivaintvenc7),

                                           estatus8            = DECODE(eMes,8,eStatusCred,estatus8),
                                           capvig8             = DECODE(eMes,8,eSdoCapital,capvig8),
                                           capvigprom8         = DECODE(eMes,8,vCapVigProm,capvigprom8),
                                           captrans8           = DECODE(eMes,8,eMontoVencido,captrans8),
                                           captransprom8       = DECODE(eMes,8,vCapTransProm,captransprom8),
                                           capvencnoexig8      = DECODE(eMes,8,eCapTrasNo,capvencnoexig8),
                                           capvencnoexigprom8  = DECODE(eMes,8,vCapVecNoExigProm,capvencnoexigprom8),
                                           capvenexig8         = DECODE(eMes,8,eMtoVencTrasp,capvenexig8),
                                           capvencexigprom8    = DECODE(eMes,8,vCapVencExigProm,capvencexigprom8),
                                           intvig8             = DECODE(eMes,8,vProvInt,intvig8),
                                           intvenc8            = DECODE(eMes,8,vProvIntVenc,intvenc8),
                                           ivaintvig8          = DECODE(eMes,8,vProvIva,ivaintvig8),
                                           ivaintvenc8         = DECODE(eMes,8,vProvIntVenc,ivaintvenc8),

                                           estatus9            = DECODE(eMes,9,eStatusCred,estatus9),
                                           capvig9             = DECODE(eMes,9,eSdoCapital,capvig9),
                                           capvigprom9         = DECODE(eMes,9,vCapVigProm,capvigprom9),
                                           captrans9           = DECODE(eMes,9,eMontoVencido,captrans9),
                                           captransprom9       = DECODE(eMes,9,vCapTransProm,captransprom9),
                                           capvencnoexig9      = DECODE(eMes,9,eCapTrasNo,capvencnoexig9),
                                           capvencnoexigprom9  = DECODE(eMes,9,vCapVecNoExigProm,capvencnoexigprom9),
                                           capvenexig9         = DECODE(eMes,9,eMtoVencTrasp,capvenexig9),
                                           capvencexigprom9    = DECODE(eMes,9,vCapVencExigProm,capvencexigprom9),
                                           intvig9             = DECODE(eMes,9,vProvInt,intvig9),
                                           intvenc9            = DECODE(eMes,9,vProvIntVenc,intvenc9),
                                           ivaintvig9          = DECODE(eMes,9,vProvIva,ivaintvig9),
                                           ivaintvenc9         = DECODE(eMes,9,vProvIntVenc,ivaintvenc9),

                                           estatus10            = DECODE(eMes,10,eStatusCred,estatus10),
                                           capvig10             = DECODE(eMes,10,eSdoCapital,capvig10),
                                           capvigprom10         = DECODE(eMes,10,vCapVigProm,capvigprom10),
                                           captrans10           = DECODE(eMes,10,eMontoVencido,captrans10),
                                           captransprom10       = DECODE(eMes,10,vCapTransProm,captransprom10),
                                           capvencnoexig10      = DECODE(eMes,10,eCapTrasNo,capvencnoexig10),
                                           capvencnoexigprom10  = DECODE(eMes,10,vCapVecNoExigProm,capvencnoexigprom10),
                                           capvenexig10         = DECODE(eMes,10,eMtoVencTrasp,capvenexig10),
                                           capvencexigprom10    = DECODE(eMes,10,vCapVencExigProm,capvencexigprom10),
                                           intvig10             = DECODE(eMes,10,vProvInt,intvig10),
                                           intvenc10            = DECODE(eMes,10,vProvIntVenc,intvenc10),
                                           ivaintvig10          = DECODE(eMes,10,vProvIva,ivaintvig10),
                                           ivaintvenc10         = DECODE(eMes,10,vProvIntVenc,ivaintvenc10),

                                           estatus11            = DECODE(eMes,10,eStatusCred,estatus11),
                                           capvig11             = DECODE(eMes,11,eSdoCapital,capvig11),
                                           capvigprom11         = DECODE(eMes,11,vCapVigProm,capvigprom11),
                                           captrans11           = DECODE(eMes,11,eMontoVencido,captrans11),
                                           captransprom11       = DECODE(eMes,11,vCapTransProm,captransprom11),
                                           capvencnoexig11      = DECODE(eMes,11,eCapTrasNo,capvencnoexig11),
                                           capvencnoexigprom11  = DECODE(eMes,11,vCapVecNoExigProm,capvencnoexigprom11),
                                           capvenexig11         = DECODE(eMes,11,eMtoVencTrasp,capvenexig11),
                                           capvencexigprom11    = DECODE(eMes,11,vCapVencExigProm,capvencexigprom11),
                                           intvig11             = DECODE(eMes,11,vProvInt,intvig11),
                                           intvenc11            = DECODE(eMes,11,vProvIntVenc,intvenc11),
                                           ivaintvig11          = DECODE(eMes,11,vProvIva,ivaintvig11),
                                           ivaintvenc11         = DECODE(eMes,11,vProvIntVenc,ivaintvenc11),

                                           estatus12            = DECODE(eMes,12,eStatusCred,estatus12),
                                           capvig12             = DECODE(eMes,12,eSdoCapital,capvig12),
                                           capvigprom12         = DECODE(eMes,12,vCapVigProm,capvigprom12),
                                           captrans12           = DECODE(eMes,12,eMontoVencido,captrans12),
                                           captransprom12       = DECODE(eMes,12,vCapTransProm,captransprom12),
                                           capvencnoexig12      = DECODE(eMes,12,eCapTrasNo,capvencnoexig12),
                                           capvencnoexigprom12  = DECODE(eMes,12,vCapVecNoExigProm,capvencnoexigprom12),
                                           capvenexig12         = DECODE(eMes,12,eMtoVencTrasp,capvenexig12),
                                           capvencexigprom12    = DECODE(eMes,12,vCapVencExigProm,capvencexigprom12),
                                           intvig12             = DECODE(eMes,12,vProvInt,intvig12),
                                           intvenc12            = DECODE(eMes,12,vProvIntVenc,intvenc12),
                                           ivaintvig12          = DECODE(eMes,12,vProvIva,ivaintvig12),
                                           ivaintvenc12         = DECODE(eMes,12,vProvIntVenc,ivaintvenc12)
                  WHERE num_credito = eNumCredito
                    AND anio = eAnio;
           ELSE
                  INSERT INTO sd_sdomensual
                 VALUES(eNumCredito, vSucursal,eAnio,
                                     DECODE(eMes,1,eStatusCred,'00'),
                                     DECODE(eMes,1,eSdoCapital,0),
                                     DECODE(eMes,1,vCapVigProm,0),
                                     DECODE(eMes,1,eMontoVencido,0),
                                     DECODE(eMes,1,vCapTransProm,0),
                                     DECODE(eMes,1,eCapTrasNo,0),
                                     DECODE(eMes,1,vCapVecNoExigProm,0),
                                     DECODE(eMes,1,eMtoVencTrasp,0),
                                     DECODE(eMes,1,vCapVencExigProm,0),
                                     DECODE(eMes,1,vProvInt,0),
                                     DECODE(eMes,1,vProvIntVenc,0),
                                     DECODE(eMes,1,vProvIva,0),
                                     DECODE(eMes,1,vProvIntVenc,0),

                                     DECODE(eMes,2,eStatusCred,'00'),
                                     DECODE(eMes,2,eSdoCapital,0),
                                     DECODE(eMes,2,vCapVigProm,0),
                                     DECODE(eMes,2,eMontoVencido,0),
                                     DECODE(eMes,2,vCapTransProm,0),
                                     DECODE(eMes,2,eCapTrasNo,0),
                                     DECODE(eMes,2,vCapVecNoExigProm,0),
                                     DECODE(eMes,2,eMtoVencTrasp,0),
                                     DECODE(eMes,2,vCapVencExigProm,0),
                                     DECODE(eMes,2,vProvInt,0),
                                     DECODE(eMes,2,vProvIntVenc,0),
                                     DECODE(eMes,2,vProvIva,0),
                                     DECODE(eMes,2,vProvIntVenc,0),

                                     DECODE(eMes,3,eStatusCred,'00'),
                                     DECODE(eMes,3,eSdoCapital,0),
                                     DECODE(eMes,3,vCapVigProm,0),
                                     DECODE(eMes,3,eMontoVencido,0),
                                     DECODE(eMes,3,vCapTransProm,0),
                                     DECODE(eMes,3,eCapTrasNo,0),
                                     DECODE(eMes,3,vCapVecNoExigProm,0),
                                     DECODE(eMes,3,eMtoVencTrasp,0),
                                     DECODE(eMes,3,vCapVencExigProm,0),
                                     DECODE(eMes,3,vProvInt,0),
                                     DECODE(eMes,3,vProvIntVenc,0),
                                     DECODE(eMes,3,vProvIva,0),
                                     DECODE(eMes,3,vProvIntVenc,0),

                                     DECODE(eMes,4,eStatusCred,'00'),
                                     DECODE(eMes,4,eSdoCapital,0),
                                     DECODE(eMes,4,vCapVigProm,0),
                                     DECODE(eMes,4,eMontoVencido,0),
                                     DECODE(eMes,4,vCapTransProm,0),
                                     DECODE(eMes,4,eCapTrasNo,0),
                                     DECODE(eMes,4,vCapVecNoExigProm,0),
                                     DECODE(eMes,4,eMtoVencTrasp,0),
                                     DECODE(eMes,4,vCapVencExigProm,0),
                                     DECODE(eMes,4,vProvInt,0),
                                     DECODE(eMes,4,vProvIntVenc,0),
                                     DECODE(eMes,4,vProvIva,0),
                                     DECODE(eMes,4,vProvIntVenc,0),

                                     DECODE(eMes,5,eStatusCred,'00'),
                                     DECODE(eMes,5,eSdoCapital,0),
                                     DECODE(eMes,5,vCapVigProm,0),
                                     DECODE(eMes,5,eMontoVencido,0),
                                     DECODE(eMes,5,vCapTransProm,0),
                                     DECODE(eMes,5,eCapTrasNo,0),
                                     DECODE(eMes,5,vCapVecNoExigProm,0),
                                     DECODE(eMes,5,eMtoVencTrasp,0),
                                     DECODE(eMes,5,vCapVencExigProm,0),
                                     DECODE(eMes,5,vProvInt,0),
                                     DECODE(eMes,5,vProvIntVenc,0),
                                     DECODE(eMes,5,vProvIva,0),
                                     DECODE(eMes,5,vProvIntVenc,0),

                                     DECODE(eMes,6,eStatusCred,'00'),
                                     DECODE(eMes,6,eSdoCapital,0),
                                     DECODE(eMes,6,vCapVigProm,0),
                                     DECODE(eMes,6,eMontoVencido,0),
                                     DECODE(eMes,6,vCapTransProm,0),
                                     DECODE(eMes,6,eCapTrasNo,0),
                                     DECODE(eMes,6,vCapVecNoExigProm,0),
                                     DECODE(eMes,6,eMtoVencTrasp,0),
                                     DECODE(eMes,6,vCapVencExigProm,0),
                                     DECODE(eMes,6,vProvInt,0),
                                     DECODE(eMes,6,vProvIntVenc,0),
                                     DECODE(eMes,6,vProvIva,0),
                                     DECODE(eMes,6,vProvIntVenc,0),

                                     DECODE(eMes,7,eStatusCred,'00'),
                                     DECODE(eMes,7,eSdoCapital,0),
                                     DECODE(eMes,7,vCapVigProm,0),
                                     DECODE(eMes,7,eMontoVencido,0),
                                     DECODE(eMes,7,vCapTransProm,0),
                                     DECODE(eMes,7,eCapTrasNo,0),
                                     DECODE(eMes,7,vCapVecNoExigProm,0),
                                     DECODE(eMes,7,eMtoVencTrasp,0),
                                     DECODE(eMes,7,vCapVencExigProm,0),
                                     DECODE(eMes,7,vProvInt,0),
                                     DECODE(eMes,7,vProvIntVenc,0),
                                     DECODE(eMes,7,vProvIva,0),
                                     DECODE(eMes,7,vProvIntVenc,0),

                                     DECODE(eMes,8,eStatusCred,'00'),
                                     DECODE(eMes,8,eSdoCapital,0),
                                     DECODE(eMes,8,vCapVigProm,0),
                                     DECODE(eMes,8,eMontoVencido,0),
                                     DECODE(eMes,8,vCapTransProm,0),
                                     DECODE(eMes,8,eCapTrasNo,0),
                                     DECODE(eMes,8,vCapVecNoExigProm,0),
                                     DECODE(eMes,8,eMtoVencTrasp,0),
                                     DECODE(eMes,8,vCapVencExigProm,0),
                                     DECODE(eMes,8,vProvInt,0),
                                     DECODE(eMes,8,vProvIntVenc,0),
                                     DECODE(eMes,8,vProvIva,0),
                                     DECODE(eMes,8,vProvIntVenc,0),

                                     DECODE(eMes,9,eStatusCred,'00'),
                                     DECODE(eMes,9,eSdoCapital,0),
                                     DECODE(eMes,9,vCapVigProm,0),
                                     DECODE(eMes,9,eMontoVencido,0),
                                     DECODE(eMes,9,vCapTransProm,0),
                                     DECODE(eMes,9,eCapTrasNo,0),
                                     DECODE(eMes,9,vCapVecNoExigProm,0),
                                     DECODE(eMes,9,eMtoVencTrasp,0),
                                     DECODE(eMes,9,vCapVencExigProm,0),
                                     DECODE(eMes,9,vProvInt,0),
                                     DECODE(eMes,9,vProvIntVenc,0),
                                     DECODE(eMes,9,vProvIva,0),
                                     DECODE(eMes,9,vProvIntVenc,0),

                                     DECODE(eMes,10,eStatusCred,'00'),
                                     DECODE(eMes,10,eSdoCapital,0),
                                     DECODE(eMes,10,vCapVigProm,0),
                                     DECODE(eMes,10,eMontoVencido,0),
                                     DECODE(eMes,10,vCapTransProm,0),
                                     DECODE(eMes,10,eCapTrasNo,0),
                                     DECODE(eMes,10,vCapVecNoExigProm,0),
                                     DECODE(eMes,10,eMtoVencTrasp,0),
                                     DECODE(eMes,10,vCapVencExigProm,0),
                                     DECODE(eMes,10,vProvInt,0),
                                     DECODE(eMes,10,vProvIntVenc,0),
                                     DECODE(eMes,10,vProvIva,0),
                                     DECODE(eMes,10,vProvIntVenc,0),

                                     DECODE(eMes,11,eStatusCred,'00'),
                                     DECODE(eMes,11,eSdoCapital,0),
                                     DECODE(eMes,11,vCapVigProm,0),
                                     DECODE(eMes,11,eMontoVencido,0),
                                     DECODE(eMes,11,vCapTransProm,0),
                                     DECODE(eMes,11,eCapTrasNo,0),
                                     DECODE(eMes,11,vCapVecNoExigProm,0),
                                     DECODE(eMes,11,eMtoVencTrasp,0),
                                     DECODE(eMes,11,vCapVencExigProm,0),
                                     DECODE(eMes,11,vProvInt,0),
                                     DECODE(eMes,11,vProvIntVenc,0),
                                     DECODE(eMes,11,vProvIva,0),
                                     DECODE(eMes,11,vProvIntVenc,0),

                                     DECODE(eMes,12,eStatusCred,'00'),
                                     DECODE(eMes,12,eSdoCapital,0),
                                     DECODE(eMes,12,vCapVigProm,0),
                                     DECODE(eMes,12,eMontoVencido,0),
                                     DECODE(eMes,12,vCapTransProm,0),
                                     DECODE(eMes,12,eCapTrasNo,0),
                                     DECODE(eMes,12,vCapVecNoExigProm,0),
                                     DECODE(eMes,12,eMtoVencTrasp,0),
                                     DECODE(eMes,12,vCapVencExigProm,0),
                                     DECODE(eMes,12,vProvInt,0),
                                     DECODE(eMes,12,vProvIntVenc,0),
                                     DECODE(eMes,12,vProvIva,0),
                                     DECODE(eMes,12,vProvIntVenc,0));

        END IF;
    END IF;

    --//Elimina el Registro de sc_sdodiarioc
    IF vCodRet = "000" THEN
       --DELETE FROM sd_sd_sdodiario
       --WHERE num_credito = eNumCredito;
    END IF;


END
	RETURN vCodRet;
END PROCEDURE DOCUMENT "Version 1.00.000";

create procedure "informix".califcartconsumo(pempresa char(3))
       returning char(5);

define vcodret 			        char(5);
define vmensaje			        char(80);
define scod_ret     		    char(5);
define vsqlerr      		    integer;
define vContador 		        smallint;
define vTotalContador 		    smallint;
define vTotal 			        money;
define vGrado 			        char(2);
define vGrado_Aplicar 		    char(2);
define vCredito 		        char(20);
define vPeriodo 		        char(1);
define vNumPeriodo 		        smallint;
define vNum_Periodo 		    smallint;
define vPorcentajeReserva 	    money;
define vImporteReserva 		    money;
define vCalificacion 		    char(1);
define vProducto 		        char(4);
define vSucursal 		        char(4);
define vDivisa 			        char(2);
define vcapital_vig		        money;
define vinteres_vig		        money;

define pfecha 			        date;
define vtotal_dias		        smallint;
define vcapital_venc		    money;
define vinteres_venc		    money;
define vperiodicidad		    char(1);
define vnum_periodos		    smallint; 
define vcalificacion_riesgo	    char(1);
define vnum_producto		    char(4);
define vNvoPeriodo 		        smallint;
define vcuotasvenc 		        money;
define vult_hab_mes 		    date;
define vstatus_proc 		    char(1);
define vprox_fecha              date;
define vpri_hab_mes		        date;

define cEvaluaCC                Char(1);
define vImporteReservaBuroCC    Money(16,2);
define vtotal_capitalizado      Money(16,2);
define vmonto_capitalizado      Money(16,2);
define vStatusCred              char(02);
define vcodigo_ref              integer;
define vcontador_insert         integer;

BEGIN

ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "califcartconsumo.out";
--TRACE ON;
	
LET vcodret        = "000";
LET vtotal_dias    = 0;
LET vcuotasvenc    = 0;
LET vContador 	   = 0;
LET vTotalContador = 0;
LET vcapital_vig   = 0;
LET vinteres_vig   = 0;
LET vNvoPeriodo    = 0;
LET vmensaje 	   = "PROCESO TERMINADO SATISFACTORIAMENTE";
LET vpri_hab_mes   = "";
LET cEvaluaCC= "";
LET vImporteReservaBuroCC= 0;
LET vtotal_capitalizado= 0;
LET vmonto_capitalizado= 0;
LET vStatusCred='';
let vcodigo_ref = 0;
LET vcontador_insert = 0;

    --Obtiene la Fecha del Dia 
    SELECT fecha_hoy, ult_hab_mes, prox_fecha, pri_hab_mes
      INTO pfecha, vult_hab_mes, vprox_fecha, vpri_hab_mes
      FROM sd_fechas  
     WHERE empresa = pempresa;

   -- Valida que sea ultimo dia habil de mes
   -- if pfecha <> vult_hab_mes then
   --    let vcodret = "581";
   --    return vcodret;
   -- end if
   

   -- Valida que ya fue realizado el cierre del dia   
--   SELECT status_proc
--     INTO vstatus_proc
--     FROM sd_contproc
--    WHERE empresa = pempresa and 
--          proceso = "cierre" and
--          status_proc = "F" and
--          fecha = pfecha;
            
   SELECT status_proc
     INTO vstatus_proc
     FROM bdinteg:sx_contproc
    WHERE empresa = pempresa and 
          proceso = "CierreCred" and
          status_proc = "F" and
	  sistema = "06"  and
          fecha = pfecha;

   if vstatus_proc is null then
      let vcodret = "582";
      return vcodret;
   end if
   
    -- Elimina el Movimiento Generado de la Calificacion anterior

    truncate table sd_movcalcval;

    -- Elimina el Movimiento del Dia en Historico
    DELETE FROM sd_histvalcon 
     WHERE empresa = pEmpresa and 
           year(fecha_alta) = Year(pFecha) and 
           month(fecha_alta) = Month(pFecha);

    update statistics medium for table sd_histvalcon;

FOREACH with hold
    SELECT b.num_credito, b.capital_venc, --+ b.interes_venc, 
           b.periodicidad, b.num_periodos, b.interes_venc,
           b.calificacion_riesgo , a.num_producto, a.sucursal, a.divisa, a.status_cred
      INTO vCredito, vTotal,
           vPeriodo, vNum_Periodo, vInteres_venc,
           vGrado, vProducto, vSucursal, vDivisa, vStatusCred
      FROM sd_maecred a, sd_movvalcon b
     WHERE a.empresa = pempresa
       and a.empresa = b.empresa 
       and a.num_credito = b.num_credito
  ORDER BY b.num_credito 

  if (vcontador_insert = 0) then
     begin work;
  end if;

  -- Determina la Periodicidad del Credito
  IF UPPER(vPeriodo) = "S" THEN
     IF vNum_Periodo > 18 THEN
        LET vNum_Periodo = 18;
     END IF
  END IF   


  IF UPPER(vPeriodo) = "Q" THEN
     IF vNum_Periodo > 13 THEN
        LET vNum_Periodo = 13;
     END IF
  END IF   

  IF UPPER(vPeriodo) = "M" THEN
     IF vNum_Periodo > 9 THEN
        LET vNum_Periodo = 9;
     END IF
  END IF   
     
  -- Extrae el Numero de Periodos Vencidos
  
  SELECT porcentaje, grado, grado
    INTO vPorcentajeReserva, vGrado_Aplicar, vCalificacion
    FROM sd_porc_reserva 
   WHERE empresa = pempresa and 
         periodo = vPeriodo and 
         num_periodo = vNum_Periodo and 
         tipocredito = "01";

-- No se toman los intereses en cuenta para creditos con mas de 1 pago vencido
 -- IF UPPER(vPeriodo) = "M" THEN
 --   IF vNum_Periodo > 1 THEN
 --      LET vTotal = vTotal - vInteres_venc;
 --   END IF
 -- END IF

  -- Calcula el Importe de la Reserva
  LET vImporteReserva = vTotal * (vPorcentajeReserva / 100);

  -- Inserta informacion Calculada
  INSERT INTO sd_movcalcval (empresa,
                             num_credito,
                             periodo,
                             num_periodo,
                             grado_riesgo,
                             importe,
                             porcentaje,
                             imp_reservas,
                             calificacion,
                             fecha)
                     VALUES (pEmpresa,
                             vCredito,
                             vPeriodo,
                             vNum_Periodo,
                             vGrado_Aplicar,
                             vTotal,
                             vPorcentajeReserva,
                             vImporteReserva,
                             vCalificacion,
                             pFecha);
                             
  -- Actualiza Maestro de Credito Central
    
    UPDATE sd_maecred SET calificacion_riesgo = vCalificacion
     WHERE empresa = pempresa and
           num_credito = vCredito;
      
  -- Graba Movimiento en Historico de Calificaciones
     
    INSERT INTO sd_histvalcon (empresa,
                               num_credito,
                               fecha_alta,
                               calif_ant,
                               calif_actual,
                               porcentaje,
                               num_periodos,
                               importe,
                               importe_reserva) 
                       VALUES (pEmpresa,
                               vCredito,
                               pFecha,
                               vGrado, 
                               vCalificacion,
                               vPorcentajeReserva,
                               vNum_Periodo,
                               vTotal,
                               vImporteReserva);

-- Jom ini req 07-012

    IF UPPER(vPeriodo) = "M" Then

       LET vNvoPeriodo = vNum_Periodo;
{
       IF vNum_Periodo = 0 THEN
          LET vNvoPeriodo = 0;
       END IF
       
       IF vNum_Periodo = 1 THEN
          LET vNvoPeriodo = 1;
       END IF
          
       IF vNum_Periodo = 2 THEN
          LET vNvoPeriodo = 2;
       END IF

       IF vNum_Periodo = 3 OR vNum_Periodo = 4 OR vNum_Periodo = 5 OR vNum_Periodo = 6 THEN
          LET vNvoPeriodo = 3;
       END IF

       IF vNum_Periodo = 7 OR vNum_Periodo = 8 OR vNum_Periodo = 9 THEN
          LET vNvoPeriodo = 4;
       END IF
}
    END IF     

-- Jom fin req 07-012   

    IF UPPER(vPeriodo) = "Q" THEN
       IF vNum_Periodo = 0 THEN
          LET vNvoPeriodo = 0;
       END IF

       IF vNum_Periodo = 1 OR vNum_Periodo = 2 THEN
          LET vNvoPeriodo = 1;
       END IF

       IF vNum_Periodo = 3 OR vNum_Periodo = 4 OR vNum_Periodo = 5 THEN
          LET vNvoPeriodo = 2;
       END IF

       IF vNum_Periodo = 6 OR vNum_Periodo = 7 OR vNum_Periodo = 8 OR vNum_Periodo = 9 OR vNum_Periodo = 10 THEN
          LET vNvoPeriodo = 3;
       END IF

       IF vNum_Periodo = 11 OR vNum_Periodo = 12 OR vNum_Periodo = 13 THEN
          LET vNvoPeriodo = 4;
       END IF
    End IF
     
    IF UPPER(vPeriodo) = "S" Then
       IF vNum_Periodo = 0 THEN
          LET vNvoPeriodo = 0;
       END IF

       IF vNum_Periodo = 1 OR vNum_Periodo = 2 OR vNum_Periodo = 3 OR vNum_Periodo = 4 THEN
          LET vNvoPeriodo = 1;
       END IF

       IF vNum_Periodo = 5 OR vNum_Periodo = 6 OR vNum_Periodo = 7 OR vNum_Periodo = 8 OR vNum_Periodo = 9 OR vNum_Periodo = 10 OR vNum_Periodo = 11 THEN
          LET vNvoPeriodo = 2;
       END IF

       IF vNum_Periodo = 12 OR vNum_Periodo = 13 OR vNum_Periodo = 14 OR vNum_Periodo = 15 OR vNum_Periodo = 16 OR vNum_Periodo = 17 THEN
          LET vNvoPeriodo = 3;
       END IF

       IF vNum_Periodo = 16 THEN
          LET vNvoPeriodo = 4;
       END IF

    END IF

  -- Genera Movimiento para Contabilidad                     
        EXECUTE PROCEDURE genmov_hist (pEmpresa,
				  vCredito,
				  vProducto,
				  vNvoPeriodo,
				  "665",
				  pFecha,
				  vImporteReserva,
				  "CalifCartReserva",
				  vSucursal,
				  vDivisa,
				  "0000")
        INTO vcodret, vmensaje;
        IF vcodret <> "00000" THEN
           RETURN vcodret;
        END IF

        EXECUTE PROCEDURE genmov_hist (pEmpresa,
				  vCredito,
				  vProducto,
				  vNum_Periodo,
				  "666",
				  pFecha,
				  vTotal,
				  "CalifCart",
				  vSucursal,
				  vDivisa,
				  "0000")
   	INTO vcodret, vmensaje;
   	IF vcodret <> "00000" THEN
	   RETURN vcodret;
   	END IF

  -- Genera Movimiento Inverso para Contabilidad                     
        EXECUTE PROCEDURE genmov_hist (pEmpresa,
				  vCredito,
				  vProducto,
				  vNvoPeriodo,
				  "667",
				  vprox_fecha,  --vpri_hab_mes,
				  vImporteReserva,
				  "CalifCartReserva",
				  vSucursal,
				  vDivisa,
				  "0000")
   	INTO vcodret, vmensaje;
   	IF vcodret <> "00000" THEN
	   RETURN vcodret;
   	END IF

        EXECUTE PROCEDURE genmov_hist (pEmpresa,
				  vCredito,
				  vProducto,
				  vNum_Periodo,
				  "668",
				  vprox_fecha, -- 'vpri_hab_mes,
				  vTotal,
				  "CalifCart",
				  vSucursal,
				  vDivisa,
				  "0000")
   	INTO vcodret, vmensaje;
   	IF vcodret <> "00000" THEN
	   RETURN vcodret;
   	END IF

    -- Reservas por Riesgos Operativos (Clientes con mal Antecedentes en el circulo de Crédito)

     LET cEvaluaCC = '0';

     SELECT evalua_cc
       INTO cEvaluaCC
       FROM bdisolic:ss_resum_scor_fin
      WHERE empresa= pEmpresa
        AND num_solicitud = vCredito;

        IF cEvaluaCC IS NULL THEN
            LET cEvaluaCC = '0';
        END IF;

        LET vImporteReservaBuroCC= vImporteReserva * 0.15;
       
    IF cEvaluaCC= '1' THEN
--Califica malos antecedentes
          EXECUTE PROCEDURE genmov_hist(pEmpresa,
                        vCredito,
                        vProducto,
                        51, -- Codigo_ref
                        "661", -- codigo_fun
                        pFecha,
                        vImporteReservaBuroCC,
                        "CalifCart", -- Descripción
                        vSucursal,
                        vDivisa,
                        "0000")
          INTO vcodret, vmensaje;
          IF vcodret <> "00000" THEN
            RETURN vcodret;
          END IF

-- Cancela reserva
          EXECUTE PROCEDURE genmov_hist(pEmpresa,
                        vCredito,
                        vProducto,
                        51, -- Codigo_ref
                        "663", -- codigo_fun
                        vprox_fecha,
                        vImporteReservaBuroCC,
                        "CalifCart", -- Descripción
                        vSucursal,
                        vDivisa,
                        "0000")
          INTO vcodret, vmensaje;
          IF vcodret <> "00000" THEN
            RETURN vcodret;
          END IF
    END IF;

    -- Reservas por Intereses devengados sobre créditos vencidos.

    LET vtotal_capitalizado = 0;
    LET vmonto_capitalizado = 0;

   if vStatusCred = 'BT' then
        FOREACH 
                        select first 4 monto, codigo_ref
                         into vmonto_capitalizado, vcodigo_ref
                        from bdicred:sd_movhis
                        where empresa = pEmpresa
                          and num_credito = vCredito  
                          and codigo_fun = '605' 
--                          and codigo_ref = 2
                          and fecha_mov >= date(0)
                          and reversado = 'N'
                        order by fecha_mov desc

                        if ( vcodigo_ref = 2 ) then
                          let vtotal_capitalizado = vtotal_capitalizado + vmonto_capitalizado;
                        end if;
                        
                       
        END FOREACH;

        if vtotal_capitalizado > 0 then 
        -- INI JOM requerimiento
            let vtotal_capitalizado = vtotal_capitalizado * (1 - (vPorcentajeReserva / 100));
        -- INI JOM requerimiento
             EXECUTE PROCEDURE genmov_hist(pEmpresa,
                                     vCredito,
                                     vProducto,
                                     50, --- Codigo_ref
                                     "661", -- codigo_fun
                                     pFecha,
                                     vtotal_capitalizado,
                                     "CalifCart", -- Descripción
                                     vSucursal, 
                                     vDivisa,
                                     "0000")
            INTO vcodret, vmensaje;
            IF vcodret <> "00000" THEN
                    RETURN vcodret;
            END IF

             EXECUTE PROCEDURE genmov_hist(pEmpresa,
                                     vCredito,
                                     vProducto,
                                     50, --- Codigo_ref
                                     "663", -- codigo_fun
                                     vprox_fecha,
                                     vtotal_capitalizado,
                                     "CalifCart", -- Descripción
                                     vSucursal, 
                                     vDivisa,
                                     "0000")
            INTO vcodret, vmensaje;
            IF vcodret <> "00000" THEN
                    RETURN vcodret;
            END IF

        end if
   end if

        -- *********************************************
        -- Realiza Pase de Movimiento Diario a Historico *
        -- *********************************************
--        INSERT INTO sd_movhis
--             SELECT * FROM sd_movdia
--              WHERE num_credito = vCredito
--                    AND empresa = pEmpresa;

--        DELETE FROM sd_movdia
--              WHERE num_credito = vCredito
--                    AND empresa = pEmpresa;



    let vcontador_insert = vcontador_insert + 1;

    if (vcontador_insert >= 70000) then
        commit work;
        let vcontador_insert = 0;
        update statistics medium for table sd_histvalcon;
        update statistics medium for table sd_movcalcval;
    end if;

END FOREACH

if (vcontador_insert > 0) then
  commit work;
end if;

let vcodret = "000";
RETURN vcodret;

END

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".log_cierrecrd(vEmpresa CHAR(3),
			    vNumCred CHAR(20),
			    vCodRet  CHAR(5),
			    vFecha   DATE,
			    vDesc    VARCHAR(200,1))
RETURNING SMALLINT;


DEFINE vContador SMALLINT;
DEFINE vParamPara SMALLINT;

	SELECT valor INTO vParamPara
	  FROM sd_param
	 WHERE empresa = vEmpresa
	   AND cod_param ="79";

	INSERT INTO sd_valcierrecrd
	 (empresa, cod_ret, num_credito, secuencia, fecha_proc,
	  desc_err)
	VALUES
	 (vEmpresa, vCodRet, vNumCred, 0, vFecha, vDesc);


	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(*) INTO vContador
	  FROM sd_valcierrecrd
	 WHERE empresa = vEmpresa
	   AND fecha_proc = vFecha;

	IF vContador >= vParamPara THEN
		RETURN vContador;
	ELSE
		LET vContador = 0;
	END IF

	RETURN vContador;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_cal_fecha
					(
					pFecha 		DATE,	-->Fecha  a Calcular
					pTipoSuma 	INT,    -->Tipo para sumar Dia, Mes, Anio
								-->Dia =1, Mes = 2, Anio =3
					pSuma		INT,	-->Cuanto va sumar
				        pUltDiaLab	INT,	-->Ultimo dia laboral L=0,M=1,M=2,J=3,V=4,S=5,D=6
					pDiaHab 	INT 	-->Dia habil anterior=0, o posterior=1
					)

RETURNING CHAR(5),-->Codigo de Retorno
	  DATE ,  -->Fecha de Calculada
	  INT  ,  -->Periodo en que regresara (mes,añio,dias)
	  INT ;   -->Numero de dias Transcurridos

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr          INTEGER;

DEFINE vFechaCalculada	DATE;
DEFINE vPeriodo 	INT;
dEFINE vDiaTras		INT;
DEFINE vUltimoDiaMes    DATE;
DEFINE vDias 		INT;
DEFINE vUltDiaLab       INT;
DEFINE vUltDiaMes	DATE;
DEFINE vAnio		int;


--SET DEBUG FILE TO "sp_cal_fecha.out";
--TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;

	   RETURN vcodret,--> Codigo de Retorno
	          vFechaCalculada,	-->FechaCaluculada
	          vPeriodo,		-->Fecha regresa
		  vDiaTras;		-->Dias Transcurridos
	END EXCEPTION;

LET vcodret = "00000";
LET vUltDiaLab      = 0;
LET vFechaCalculada = " ";
LET vUltimoDiaMes   = " ";
LET vPeriodo 	    = 0;
LET vDiaTras	    = 0;
LET vDias           = 0;
let pFecha          = pFecha;
Let vAnio 	    = 0;

--Calculo por dia =1

	IF pTipoSuma = '1' THEN

		LET	vFechaCalculada = MONTH(pFecha)||"/"||DAY(pFecha)||"/"||YEAR(pFecha);
		LET	vFechaCalculada = vFechaCalculada + pSuma UNITS DAY;
		LET	vPeriodo = 1;
	END IF;

--Calculo por mes =2

	IF pTipoSuma = '2' THEN

	LET	vPeriodo = 2;

	select {+INDEX (sd_fechas idx_sdfechas)} ult_dia_mes
	into vUltDiaMes
	from sd_fechas where empresa='001';


--Fin de Mes
	If pFecha = vUltDiaMes Then
           IF MONTH(pfecha) = 12 THEN
              LET vFechaCalculada  = "01/01/"|| YEAR(pFecha)+1;
           ELSE
              LET vFechaCalculada  = MONTH(pFecha)+1 ||"/01/"|| YEAR(pFecha);
           END IF
	   LET vFechaCalculada = (vFechaCalculada + pSuma UNITS MONTH); ---1 UNITS DAY;
	   LET vFechaCalculada = (vFechaCalculada - 1 UNITS DAY); ---1 UNITS DAY;
--Si es bisiesto
	Else
	        LET vFechaCalculada = MONTH(pFecha) ||"/01/"|| YEAR(pFecha);
        	LET vFechaCalculada = vFechaCalculada + pSuma UNITS MONTH;


        	IF day(pFecha) >= 29 AND MONTH(vFechaCalculada) = 2 THEN
                   IF MOD(YEAR(vFechaCalculada),4) = 0 THEN
              	      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| "29" ||"/"|| YEAR(vFechaCalculada);
                   ELSE
                      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| "28" ||"/"|| YEAR(vFechaCalculada);
                   END IF
               ELSE
                     LET vUltimoDiaMes = (vFechaCalculada + 1 UNITS MONTH) - 1 UNITS DAY;
                   IF day(pFecha) <= DAY(vUltimoDiaMes) THEN
                     -- LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| day(pFecha) ||"/"|| YEAR(vFechaCalculada);
                      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| day(vUltimoDiaMes) ||"/"|| YEAR(vFechaCalculada);
                   ELSE
                      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| DAY(vUltimoDiaMes) ||"/"|| YEAR(vFechaCalculada);
                  END IF

             end if;
        END IF;
 END IF;
--Calculo por anio =3

	LET pFecha = pfecha;
	LET psuma = pSuma;

	IF pTipoSuma = '3' THEN
		LET vAnio = YEAR(pFecha) + psuma;
                   IF MOD(vAnio,4) = 0 THEN
              	      LET vFechaCalculada = MONTH(pFecha) ||"/"|| "29" ||"/"|| vAnio;
                   ELSE
                      LET vFechaCalculada = MONTH(pFecha) ||"/"|| "28" ||"/"|| vAnio;
                   END IF
		LET	vPeriodo = 3;
	END IF;

	--****Calculo del dia habil y fecha porsterior o anterior***--
        LET vUltDiaLab = WeekDay(vFechaCalculada);
        IF pUltDiaLab = vUltDiaLab THEN
	   if pDiaHab = 0 then
	--	LET vFechaCalculada = vFechaCalculada - 1 UNITS DAY;
	     Call sp_valfechabil(vFechaCalculada,"-") returning vCodret,vFechaCalculada;
	   Else
	     Call sp_valfechabil(vFechaCalculada,"") returning vCodret,vFechaCalculada;
	   end if
	Elif pUltDiaLab < vUltDiaLab and pUltDiaLab <> 0 Then

	    if pDiaHab = 0 then
               LET vFechaCalculada = vFechaCalculada - (vUltDiaLab - pUltDiaLab) UNITS DAY;
               Call sp_valfechabil(vFechaCalculada,"-") returning vCodret,vFechaCalculada;
       	    Else
               LET vFechaCalculada = vFechaCalculada + (vUltDiaLab - pUltDiaLab) UNITS DAY;
               Call sp_valfechabil(vFechaCalculada,"") returning vCodret,vFechaCalculada;
       	   end if
	---Si es Domigo - Sabado

	Elif pUltDiaLab > vUltDiaLab and vUltDiaLab = 0 Then
	    if pDiaHab = 0 then

		 if   pUltDiaLab = 5 then
	         	Let vFechaCalculada = (vFechaCalculada - 2 UNITS DAY);
		 end if

		 if pUltDiaLab = 6 then
	   --      	Let vFechaCalculada = (vFechaCalculada -  1 UNITS DAY);
		 end if

                 Call sp_valfechabil(vFechaCalculada,"-") returning vCodret,vFechaCalculada;
            Else

		 if   pUltDiaLab = 5 then
	         	Let vFechaCalculada = (vFechaCalculada +  1 UNITS DAY);
		 end if

		 if pUltDiaLab = 6 then
	--       	Let vFechaCalculada = (vFechaCalculada +  2 UNITS DAY);
		 end if

                 Call sp_valfechabil(vFechaCalculada,"") returning vCodret,vFechaCalculada;
       	   end if
        END IF;

	--Calcula los dias Transcurridos--

      LET     vDiaTras= ( vFechaCalculada - pFecha );

        RETURN
	vcodret,              --> Codigo de Retorno
        vFechaCalculada,      -->FechaCaluculada
        vPeriodo,             -->Fecha regresa
        vDiaTras;             -->Dias Transcurridos


END
END PROCEDURE
;