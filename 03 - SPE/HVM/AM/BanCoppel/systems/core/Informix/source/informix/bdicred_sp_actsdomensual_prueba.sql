CREATE PROCEDURE "informix".sp_actsdomensual_prueba(eEmpresa      CHAR(3),
                                             eNumCredito   CHAR(20),
                                             eFecMov       DATE,
                                             eAnio         SMALLINT,
                                             eMes          CHAR(2))

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

   SET DEBUG FILE TO "sp_mensual.out";
   TRACE ON;

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
    WHERE num_credito = eNumCredito 
     AND  acucapvig       > 0 Or 
          acucaptra       > 0 Or
          acucapvennoexig > 0 Or
          acucapvencexig  > 0;

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
                   UPDATE sd_sdomensual SET capvig1             = DECODE(eMes,1,eSdoCapital,capvig1),
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

CREATE PROCEDURE "informix".genmovref(
   p_empresa                VARCHAR(3),
   p_num_credito            VARCHAR(20),
   p_num_producto           VARCHAR(4),
   p_monto                  MONEY(14,2),
   p_folio                  VARCHAR(16),
   p_sucursal               CHAR(4),
   p_tarjeta                CHAR(20),
   p_referencia             VARCHAR(40))

RETURNING VARCHAR(5);

DEFINE   p_cod_ret       VARCHAR(10);
DEFINE   p_mensaje       VARCHAR(80);

DEFINE SQL_ERR     INTEGER;
DEFINE ISAM_ERR    INTEGER;
DEFINE ERROR_INFO  VARCHAR(80);
DEFINE vFecHoy     DATE;
DEFINE vDivisa     CHAR(2);


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET  = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET;
   END EXCEPTION;

   LET P_COD_RET      = '00000';
   LET P_MENSAJE      = 'PROCESO EXITOSO';
   LET vDivisa        = '';

  Select fecha_hoy Into vFecHoy From sd_fechas where empresa = p_empresa;
  Select divisa Into vDivisa From sd_maecred where empresa = p_empresa and num_credito = p_num_credito;

   CALL GenMov(p_empresa, p_num_credito, p_num_producto,20,
                  '336', vFecHoy, p_monto, p_folio,
                  p_sucursal, vDivisa, '0000') RETURNING
                  P_COD_RET, P_MENSAJE;
   IF (P_COD_RET <> "00000") THEN
         RETURN P_COD_RET;
   ELSE
         LET P_COD_RET = "000";
         UPDATE sd_movdia SET referencia23 = p_referencia,
                nro_tarjeta = p_Tarjeta 
         WHERE empresa = p_empresa and fecha_mov = vFecHoy and num_credito = p_num_credito and
               folio_suc = p_folio;
   END IF;
   RETURN P_COD_RET;

END;
END PROCEDURE DOCUMENT "Version 1.00.000";

create procedure "informix".act_amoiva(pempresa char(3))
returning char(5);



DEFINE vcodret       char(5);
DEFINE vsqlerr       smallint;
DEFINE vNumCredito   char(20);
DEFINE vSdoNoExig    decimal(14,2);
DEFINE vIva          decimal(14,2);





-- CONTROL DE ERRORES
BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr != 0 THEN
         LET vcodret=vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

   --set debug file to "act_amoiva.out";
   --trace on;

   let vcodret       = "000";
   let vNumCredito   = '';
   let  vSdoNoExig   = 0;
   let  vIva         = 0;


   FOREACH
           SELECT interes_debe,num_credito INTO vSdoNoExig, vNumCredito FROM sd_amortiza_credito
           WHERE empresa = '001'  and fecha_cuota = '08/20/2008'
                 and iva_debe = 0 and interes_debe > 0

           Let vIva = vSdoNoExig * 0.132742;
           UPDATE sd_amortiza_credito set iva_debe = vIva
           WHERE empresa = pempresa and num_credito = vNumCredito and fecha_cuota = '08/20/2008';

  END FOREACH;

  return vcodret;
END
END PROCEDURE;