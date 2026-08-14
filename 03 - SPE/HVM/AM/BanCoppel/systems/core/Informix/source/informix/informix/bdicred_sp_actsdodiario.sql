CREATE PROCEDURE "informix".sp_actsdodiario( eNumCredito    CHAR(20),
                                             eSucursal      CHAR(4),
                                             eSdoCapital    MONEY(14,2),
                                             eMontoVencido  MONEY(14,2),
                                             eCapTrasNo     MONEY(14,2),
                                             eMtoVencTrasp  MONEY(14,2),
                                             eSdoIntereses  MONEY(14,2),
                                             eSdoExigInt    MONEY(14,2),
                                             eIvaIntVig     MONEY(14,2),
                                             eIvaIntVenc    MONEY(14,2),
                                             eFecha         DATE)
RETURNING CHAR(3);


 DEFINE vsqlerr             INTEGER;
 DEFINE vCodRet             CHAR(3);
 DEFINE vFecha_mesant       DATE;
 DEFINE vFecha_primes       DATE;
 DEFINE eDia                INTEGER;
 DEFINE vDiaCapital         INTEGER;
 DEFINE vDiaVencido         INTEGER;
 DEFINE vDiaNoExig          INTEGER;
 DEFINE vDiaExig            INTEGER;
 define vexiste             integer;

 LET vCodRet = '000';
 LET vsqlerr = 0;
 let vexiste = 0;

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

 --   IF eSdoCapital<=0 THEN LET eSdoCapital=0; LET vDiaCapital=0; ELSE LET vDiaCapital=1; END IF;
 --   IF eMontoVencido<=0 THEN LET eMontoVencido=0; LET vDiaVencido=0; ELSE LET vDiaVencido=1; END IF;
 --   IF eCapTrasNo<=0 THEN LET eCapTrasNo=0; LET vDiaNoExig=0; ELSE LET vDiaNoExig=1; END IF;
 --   IF eMtoVencTrasp<=0 THEN LET eMtoVencTrasp=0; LET vDiaExig=0; ELSE LET vDiaExig=1; END IF;
 --   IF eSdoIntereses<=0 THEN LET eSdoIntereses=0; END IF;
 --   IF eSdoExigInt<=0 THEN LET eSdoExigInt=0; END IF;
 --   IF eIvaIntVig<=0 THEN LET eIvaIntVig=0; END IF;
 --   IF eIvaIntVenc<=0 THEN LET eIvaIntVenc=0; END IF;

    IF eSdoCapital<=0 THEN LET vDiaCapital=0; ELSE LET vDiaCapital=1; END IF;
    IF eMontoVencido<=0 THEN LET vDiaVencido=0; ELSE LET vDiaVencido=1; END IF;
    IF eCapTrasNo<=0 THEN LET vDiaNoExig=0; ELSE LET vDiaNoExig=1; END IF;
    IF eMtoVencTrasp<=0 THEN LET vDiaExig=0; ELSE LET vDiaExig=1; END IF;


IF DAY(eFecha)=1 THEN
        LET vFecha_mesant=DATE(eFecha- 2 UNITS MONTH);
             UPDATE sd_sdodiario SET capvig1        =  0,captrans1      =  0,capvencnoexig1 =  0,capvenexig1    =  0,
                                     intvig1        =  0,intvenc1       =  0,ivaintvig1     =  0,ivaintvenc1    =  0,
                                     capvig2        =  0,captrans2      =  0,capvencnoexig2 =  0,capvenexig2    =  0,
                                     intvig2        =  0,intvenc2       =  0,ivaintvig2     =  0,ivaintvenc2    =  0,
                                     capvig3        =  0,captrans3      =  0,capvencnoexig3 =  0,capvenexig3    =  0,
                                     intvig3        =  0,intvenc3       =  0,ivaintvig3     =  0,ivaintvenc3    =  0,
                                     capvig4        =  0,captrans4      =  0,capvencnoexig4 =  0,capvenexig4    =  0,
                                     intvig4        =  0,intvenc4       =  0,ivaintvig4     =  0,ivaintvenc4    =  0,
                                     capvig5        =  0,captrans5      =  0,capvencnoexig5 =  0,capvenexig5    =  0,
                                     intvig5        =  0,intvenc5       =  0,ivaintvig5     =  0,ivaintvenc5    =  0,
                                     capvig6        =  0,captrans6      =  0,capvencnoexig6 =  0,capvenexig6    =  0,
                                     intvig6        =  0,intvenc6       =  0,ivaintvig6     =  0,ivaintvenc6    =  0,
                                     capvig7        =  0,captrans7      =  0,capvencnoexig7 =  0,capvenexig7    =  0,
                                     intvig7        =  0,intvenc7       =  0,ivaintvig7     =  0,ivaintvenc7    =  0,
                                     capvig8        =  0,captrans8      =  0,capvencnoexig8 =  0,capvenexig8    =  0,
                                     intvig8        =  0,intvenc8       =  0,ivaintvig8     =  0,ivaintvenc8    =  0,
                                     capvig9        =  0,captrans9      =  0,capvencnoexig9 =  0,capvenexig9    =  0,
                                     intvig9        =  0,intvenc9       =  0,ivaintvig9     =  0,ivaintvenc9    =  0,
                                     capvig10       =  0,captrans10     =  0,capvencnoexig10=  0,capvenexig10   =  0,
                                     intvig10       =  0,intvenc10      =  0,ivaintvig10    =  0,ivaintvenc10   =  0,
                                     capvig11       =  0,captrans11     =  0,capvencnoexig11=  0,capvenexig11   =  0,
                                     intvig11       =  0,intvenc11      =  0,ivaintvig11    =  0,ivaintvenc11   =  0,
                                     capvig12       =  0,captrans12     =  0,capvencnoexig12=  0,capvenexig12   =  0,
                                     intvig12       =  0,intvenc12      =  0,ivaintvig12    =  0,ivaintvenc12   =  0,
                                     capvig13       =  0,captrans13     =  0,capvencnoexig13=  0,capvenexig13   =  0,
                                     intvig13       =  0,intvenc13      =  0,ivaintvig13    =  0,ivaintvenc13   =  0,
                                     capvig14       =  0,captrans14     =  0,capvencnoexig14=  0,capvenexig14   =  0,
                                     intvig14       =  0,intvenc14      =  0,ivaintvig14    =  0,ivaintvenc14   =  0,
                                     capvig15       =  0,captrans15     =  0,capvencnoexig15=  0,capvenexig15   =  0,
                                     intvig15       =  0,intvenc15      =  0,ivaintvig15    =  0,ivaintvenc15   =  0,
                                     capvig16       =  0,captrans16     =  0,capvencnoexig16=  0,capvenexig16   =  0,
                                     intvig16       =  0,intvenc16      =  0,ivaintvig16    =  0,ivaintvenc16   =  0,
                                     capvig17       =  0,captrans17     =  0,capvencnoexig17=  0,capvenexig17   =  0,
                                     intvig17       =  0,intvenc17      =  0,ivaintvig17    =  0,ivaintvenc17   =  0,
                                     capvig18       =  0,captrans18     =  0,capvencnoexig18=  0,capvenexig18   =  0,
                                     intvig18       =  0,intvenc18      =  0,ivaintvig18    =  0,ivaintvenc18   =  0,
                                     capvig19       =  0,captrans19     =  0,capvencnoexig19=  0,capvenexig19   =  0,
                                     intvig19       =  0,intvenc19      =  0,ivaintvig19    =  0,ivaintvenc19   =  0,
                                     capvig20       =  0,captrans20     =  0,capvencnoexig20=  0,capvenexig20   =  0,
                                     intvig20       =  0,intvenc20      =  0,ivaintvig20    =  0,ivaintvenc20   =  0,
                                     capvig21       =  0,captrans21     =  0,capvencnoexig21=  0,capvenexig21   =  0,
                                     intvig21       =  0,intvenc21      =  0,ivaintvig21    =  0,ivaintvenc21   =  0,
                                     capvig22       =  0,captrans22     =  0,capvencnoexig22=  0,capvenexig22   =  0,
                                     intvig22       =  0,intvenc22      =  0,ivaintvig22    =  0,ivaintvenc22   =  0,
                                     capvig23       =  0,captrans23     =  0,capvencnoexig23=  0,capvenexig23   =  0,
                                     intvig23       =  0,intvenc23      =  0,ivaintvig23    =  0,ivaintvenc23   =  0,
                                     capvig24       =  0,captrans24     =  0,capvencnoexig24=  0,capvenexig24   =  0,
                                     intvig24       =  0,intvenc24      =  0,ivaintvig24    =  0,ivaintvenc24   =  0,
                                     capvig25       =  0,captrans25     =  0,capvencnoexig25=  0,capvenexig25   =  0,
                                     intvig25       =  0,intvenc25      =  0,ivaintvig25    =  0,ivaintvenc25   =  0,
                                     capvig26       =  0,captrans26     =  0,capvencnoexig26=  0,capvenexig26   =  0,
                                     intvig26       =  0,intvenc26      =  0,ivaintvig26    =  0,ivaintvenc26   =  0,
                                     capvig27       =  0,captrans27     =  0,capvencnoexig27=  0,capvenexig27   =  0,
                                     intvig27       =  0,intvenc27      =  0,ivaintvig27    =  0,ivaintvenc27   =  0,
                                     capvig28       =  0,captrans28     =  0,capvencnoexig28=  0,capvenexig28   =  0,
                                     intvig28       =  0,intvenc28      =  0,ivaintvig28    =  0,ivaintvenc28   =  0,
                                     capvig29       =  0,captrans29     =  0,capvencnoexig29=  0,capvenexig29   =  0,
                                     intvig29       =  0,intvenc29      =  0,ivaintvig29    =  0,ivaintvenc29   =  0,
                                     capvig30       =  0,captrans30     =  0,capvencnoexig30=  0,capvenexig30   =  0,
                                     intvig30       =  0,intvenc30      =  0,ivaintvig30    =  0,ivaintvenc30   =  0,
                                     capvig31       =  0,captrans31     =  0,capvencnoexig31=  0,capvenexig31   =  0,
                                     intvig31       =  0,intvenc31      =  0,ivaintvig31    =  0,ivaintvenc31   =  0,
                                     diacapvig      = 0,acucapvig      = 0,diacaptra      = 0,acucaptra      = 0,
                                     diacapvennoexig= 0,acucapvennoexig= 0,diacapvencexig = 0,acucapvencexig = 0,fecha=eFecha
             WHERE fecha=vFecha_mesant
               AND num_credito = eNumCredito;
    END IF;

    LET vFecha_primes=MDY(MONTH(eFecha),'01',YEAR(eFecha));
    let eDia=day(eFecha);

      Select count(*)
        into vexiste
        from sd_sdodiario
       where fecha=vFecha_primes
        and num_credito = eNumCredito;

    if (vexiste = 0) then
             INSERT INTO sd_sdodiario
             VALUES(vFecha_primes,eNumCredito, eSucursal,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    end if;


    if (eSdoCapital + eMontoVencido + eCapTrasNo + eMtoVencTrasp + eSdoIntereses + eSdoExigInt + eIvaIntVig + eIvaIntVenc) <> 0 then
        if (eDia <=15) then
            if (eDia <= 7) then
                if  (eDia = 1) then
                     UPDATE sd_sdodiario SET capvig1        =  eSdoCapital,
                                             captrans1      =  eMontoVencido,
                                             capvencnoexig1 =  eCapTrasNo,
                                             capvenexig1    =  eMtoVencTrasp,
                                             intvig1        =  eSdoIntereses,
                                             intvenc1       =  eSdoExigInt,
                                             ivaintvig1     =  eIvaIntVig,
                                             ivaintvenc1    =  eIvaIntVenc
                     WHERE fecha=vFecha_primes
                       AND num_credito = eNumCredito;

                 elif (eDia = 2) then
                     UPDATE sd_sdodiario SET capvig2        =  eSdoCapital,
                                             captrans2      =  eMontoVencido,
                                             capvencnoexig2 =  eCapTrasNo,
                                             capvenexig2    =  eMtoVencTrasp,
                                             intvig2        =  eSdoIntereses,
                                             intvenc2       =  eSdoExigInt,
                                             ivaintvig2     =  eIvaIntVig,
                                             ivaintvenc2    =  eIvaIntVenc
                     WHERE fecha=vFecha_primes
                       AND num_credito = eNumCredito;

                 elif (eDia = 3) then
                             UPDATE sd_sdodiario SET capvig3        =  eSdoCapital,
                                                     captrans3      =  eMontoVencido,
                                                     capvencnoexig3 =  eCapTrasNo,
                                                     capvenexig3    =  eMtoVencTrasp,
                                                     intvig3        =  eSdoIntereses,
                                                     intvenc3       =  eSdoExigInt,
                                                     ivaintvig3     =  eIvaIntVig,
                                                     ivaintvenc3    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 4) then
                             UPDATE sd_sdodiario SET capvig4        =  eSdoCapital,
                                                     captrans4      =  eMontoVencido,
                                                     capvencnoexig4 =  eCapTrasNo,
                                                     capvenexig4    =  eMtoVencTrasp,
                                                     intvig4        =  eSdoIntereses,
                                                     intvenc4       =  eSdoExigInt,
                                                     ivaintvig4     =  eIvaIntVig,
                                                     ivaintvenc4    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 5) then
                             UPDATE sd_sdodiario SET capvig5        =  eSdoCapital,
                                                     captrans5      =  eMontoVencido,
                                                     capvencnoexig5 =  eCapTrasNo,
                                                     capvenexig5    =  eMtoVencTrasp,
                                                     intvig5        =  eSdoIntereses,
                                                     intvenc5       =  eSdoExigInt,
                                                     ivaintvig5     =  eIvaIntVig,
                                                     ivaintvenc5    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 6) then
                             UPDATE sd_sdodiario SET capvig6        =  eSdoCapital,
                                                     captrans6      =  eMontoVencido,
                                                     capvencnoexig6 =  eCapTrasNo,
                                                     capvenexig6    =  eMtoVencTrasp,
                                                     intvig6        =  eSdoIntereses,
                                                     intvenc6       =  eSdoExigInt,
                                                     ivaintvig6     =  eIvaIntVig,
                                                     ivaintvenc6    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig7        =  eSdoCapital,
                                                     captrans7      =  eMontoVencido,
                                                     capvencnoexig7 =  eCapTrasNo,
                                                     capvenexig7    =  eMtoVencTrasp,
                                                     intvig7        =  eSdoIntereses,
                                                     intvenc7       =  eSdoExigInt,
                                                     ivaintvig7     =  eIvaIntVig,
                                                     ivaintvenc7    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; -- 1-7
             else
                 if (eDia = 8) then
                             UPDATE sd_sdodiario SET capvig8        =  eSdoCapital,
                                                     captrans8      =  eMontoVencido,
                                                     capvencnoexig8 =  eCapTrasNo,
                                                     capvenexig8    =  eMtoVencTrasp,
                                                     intvig8        =  eSdoIntereses,
                                                     intvenc8       =  eSdoExigInt,
                                                     ivaintvig8     =  eIvaIntVig,
                                                     ivaintvenc8    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 9) then
                             UPDATE sd_sdodiario SET capvig9        =  eSdoCapital,
                                                     captrans9      =  eMontoVencido,
                                                     capvencnoexig9 =  eCapTrasNo,
                                                     capvenexig9    =  eMtoVencTrasp,
                                                     intvig9        =  eSdoIntereses,
                                                     intvenc9       =  eSdoExigInt,
                                                     ivaintvig9     =  eIvaIntVig,
                                                     ivaintvenc9    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 10) then
                             UPDATE sd_sdodiario SET capvig10        =  eSdoCapital,
                                                     captrans10      =  eMontoVencido,
                                                     capvencnoexig10 =  eCapTrasNo,
                                                     capvenexig10    =  eMtoVencTrasp,
                                                     intvig10        =  eSdoIntereses,
                                                     intvenc10       =  eSdoExigInt,
                                                     ivaintvig10     =  eIvaIntVig,
                                                     ivaintvenc10    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 11) then
                             UPDATE sd_sdodiario SET capvig11        =  eSdoCapital,
                                                     captrans11      =  eMontoVencido,
                                                     capvencnoexig11 =  eCapTrasNo,
                                                     capvenexig11    =  eMtoVencTrasp,
                                                     intvig11        =  eSdoIntereses,
                                                     intvenc11       =  eSdoExigInt,
                                                     ivaintvig11     =  eIvaIntVig,
                                                     ivaintvenc11    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 12) then
                             UPDATE sd_sdodiario SET capvig12        =  eSdoCapital,
                                                     captrans12      =  eMontoVencido,
                                                     capvencnoexig12 =  eCapTrasNo,
                                                     capvenexig12    =  eMtoVencTrasp,
                                                     intvig12        =  eSdoIntereses,
                                                     intvenc12       =  eSdoExigInt,
                                                     ivaintvig12     =  eIvaIntVig,
                                                     ivaintvenc12    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 13) then
                             UPDATE sd_sdodiario SET capvig13        =  eSdoCapital,
                                                     captrans13      =  eMontoVencido,
                                                     capvencnoexig13 =  eCapTrasNo,
                                                     capvenexig13    =  eMtoVencTrasp,
                                                     intvig13        =  eSdoIntereses,
                                                     intvenc13       =  eSdoExigInt,
                                                     ivaintvig13     =  eIvaIntVig,
                                                     ivaintvenc13    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 14) then
                             UPDATE sd_sdodiario SET capvig14        =  eSdoCapital,
                                                     captrans14      =  eMontoVencido,
                                                     capvencnoexig14 =  eCapTrasNo,
                                                     capvenexig14    =  eMtoVencTrasp,
                                                     intvig14        =  eSdoIntereses,
                                                     intvenc14       =  eSdoExigInt,
                                                     ivaintvig14     =  eIvaIntVig,
                                                     ivaintvenc14    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig15        =  eSdoCapital,
                                                     captrans15      =  eMontoVencido,
                                                     capvencnoexig15 =  eCapTrasNo,
                                                     capvenexig15    =  eMtoVencTrasp,
                                                     intvig15        =  eSdoIntereses,
                                                     intvenc15       =  eSdoExigInt,
                                                     ivaintvig15     =  eIvaIntVig,
                                                     ivaintvenc15    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; -- if 8-15
             end if; -- if 7
         else
             if (eDia <= 23) then
                 if (eDia = 16) then
                             UPDATE sd_sdodiario SET capvig16        =  eSdoCapital,
                                                     captrans16      =  eMontoVencido,
                                                     capvencnoexig16 =  eCapTrasNo,
                                                     capvenexig16    =  eMtoVencTrasp,
                                                     intvig16        =  eSdoIntereses,
                                                     intvenc16       =  eSdoExigInt,
                                                     ivaintvig16     =  eIvaIntVig,
                                                     ivaintvenc16    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 17) then
                             UPDATE sd_sdodiario SET capvig17        =  eSdoCapital,
                                                     captrans17      =  eMontoVencido,
                                                     capvencnoexig17 =  eCapTrasNo,
                                                     capvenexig17    =  eMtoVencTrasp,
                                                     intvig17        =  eSdoIntereses,
                                                     intvenc17       =  eSdoExigInt,
                                                     ivaintvig17     =  eIvaIntVig,
                                                     ivaintvenc17    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 18) then
                             UPDATE sd_sdodiario SET capvig18        =  eSdoCapital,
                                                     captrans18      =  eMontoVencido,
                                                     capvencnoexig18 =  eCapTrasNo,
                                                     capvenexig18    =  eMtoVencTrasp,
                                                     intvig18        =  eSdoIntereses,
                                                     intvenc18       =  eSdoExigInt,
                                                     ivaintvig18     =  eIvaIntVig,
                                                     ivaintvenc18    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 19) then
                             UPDATE sd_sdodiario SET capvig19        =  eSdoCapital,
                                                     captrans19      =  eMontoVencido,
                                                     capvencnoexig19 =  eCapTrasNo,
                                                     capvenexig19    =  eMtoVencTrasp,
                                                     intvig19        =  eSdoIntereses,
                                                     intvenc19       =  eSdoExigInt,
                                                     ivaintvig19     =  eIvaIntVig,
                                                     ivaintvenc19    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 20) then
                             UPDATE sd_sdodiario SET capvig20        =  eSdoCapital,
                                                     captrans20      =  eMontoVencido,
                                                     capvencnoexig20 =  eCapTrasNo,
                                                     capvenexig20    =  eMtoVencTrasp,
                                                     intvig20        =  eSdoIntereses,
                                                     intvenc20       =  eSdoExigInt,
                                                     ivaintvig20     =  eIvaIntVig,
                                                     ivaintvenc20    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 21) then
                             UPDATE sd_sdodiario SET capvig21        =  eSdoCapital,
                                                     captrans21      =  eMontoVencido,
                                                     capvencnoexig21 =  eCapTrasNo,
                                                     capvenexig21    =  eMtoVencTrasp,
                                                     intvig21        =  eSdoIntereses,
                                                     intvenc21       =  eSdoExigInt,
                                                     ivaintvig21     =  eIvaIntVig,
                                                     ivaintvenc21    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 22) then
                             UPDATE sd_sdodiario SET capvig22        =  eSdoCapital,
                                                     captrans22      =  eMontoVencido,
                                                     capvencnoexig22 =  eCapTrasNo,
                                                     capvenexig22    =  eMtoVencTrasp,
                                                     intvig22        =  eSdoIntereses,
                                                     intvenc22       =  eSdoExigInt,
                                                     ivaintvig22     =  eIvaIntVig,
                                                     ivaintvenc22    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig23        =  eSdoCapital,
                                                     captrans23      =  eMontoVencido,
                                                     capvencnoexig23 =  eCapTrasNo,
                                                     capvenexig23    =  eMtoVencTrasp,
                                                     intvig23        =  eSdoIntereses,
                                                     intvenc23       =  eSdoExigInt,
                                                     ivaintvig23     =  eIvaIntVig,
                                                     ivaintvenc23    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; --if 16-23
             else
                 if (eDia = 24) then
                             UPDATE sd_sdodiario SET capvig24        =  eSdoCapital,
                                                     captrans24      =  eMontoVencido,
                                                     capvencnoexig24 =  eCapTrasNo,
                                                     capvenexig24    =  eMtoVencTrasp,
                                                     intvig24        =  eSdoIntereses,
                                                     intvenc24       =  eSdoExigInt,
                                                     ivaintvig24     =  eIvaIntVig,
                                                     ivaintvenc24    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 25) then
                             UPDATE sd_sdodiario SET capvig25        =  eSdoCapital,
                                                     captrans25      =  eMontoVencido,
                                                     capvencnoexig25 =  eCapTrasNo,
                                                     capvenexig25    =  eMtoVencTrasp,
                                                     intvig25        =  eSdoIntereses,
                                                     intvenc25       =  eSdoExigInt,
                                                     ivaintvig25     =  eIvaIntVig,
                                                     ivaintvenc25    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 26) then
                             UPDATE sd_sdodiario SET capvig26        =  eSdoCapital,
                                                     captrans26      =  eMontoVencido,
                                                     capvencnoexig26 =  eCapTrasNo,
                                                     capvenexig26    =  eMtoVencTrasp,
                                                     intvig26        =  eSdoIntereses,
                                                     intvenc26       =  eSdoExigInt,
                                                     ivaintvig26     =  eIvaIntVig,
                                                     ivaintvenc26    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 27) then
                             UPDATE sd_sdodiario SET capvig27        =  eSdoCapital,
                                                     captrans27      =  eMontoVencido,
                                                     capvencnoexig27 =  eCapTrasNo,
                                                     capvenexig27    =  eMtoVencTrasp,
                                                     intvig27        =  eSdoIntereses,
                                                     intvenc27       =  eSdoExigInt,
                                                     ivaintvig27     =  eIvaIntVig,
                                                     ivaintvenc27    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 28) then
                             UPDATE sd_sdodiario SET capvig28        =  eSdoCapital,
                                                     captrans28      =  eMontoVencido,
                                                     capvencnoexig28 =  eCapTrasNo,
                                                     capvenexig28    =  eMtoVencTrasp,
                                                     intvig28        =  eSdoIntereses,
                                                     intvenc28       =  eSdoExigInt,
                                                     ivaintvig28     =  eIvaIntVig,
                                                     ivaintvenc28    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 29) then
                             UPDATE sd_sdodiario SET capvig29        =  eSdoCapital,
                                                     captrans29      =  eMontoVencido,
                                                     capvencnoexig29 =  eCapTrasNo,
                                                     capvenexig29    =  eMtoVencTrasp,
                                                     intvig29        =  eSdoIntereses,
                                                     intvenc29       =  eSdoExigInt,
                                                     ivaintvig29     =  eIvaIntVig,
                                                     ivaintvenc29   =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 30) then
                             UPDATE sd_sdodiario SET capvig30        =  eSdoCapital,
                                                     captrans30      =  eMontoVencido,
                                                     capvencnoexig30 =  eCapTrasNo,
                                                     capvenexig30    =  eMtoVencTrasp,
                                                     intvig30        =  eSdoIntereses,
                                                     intvenc30       =  eSdoExigInt,
                                                     ivaintvig30     =  eIvaIntVig,
                                                     ivaintvenc30    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig31        =  eSdoCapital,
                                                     captrans31      =  eMontoVencido,
                                                     capvencnoexig31 =  eCapTrasNo,
                                                     capvenexig31    =  eMtoVencTrasp,
                                                     intvig31        =  eSdoIntereses,
                                                     intvenc31       =  eSdoExigInt,
                                                     ivaintvig31     =  eIvaIntVig,
                                                     ivaintvenc31    =  eIvaIntVenc
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; --if 24-31
            end if; -- if 23
       end if; -- if 15
    END IF;
END
	RETURN vCodRet;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_actsdodiario( eNumCredito    CHAR(20),
                                             eSucursal      CHAR(4),
                                             eSdoCapital    MONEY(14,2),
                                             eMontoVencido  MONEY(14,2),
                                             eCapTrasNo     MONEY(14,2),
                                             eMtoVencTrasp  MONEY(14,2),
                                             eSdoIntereses  MONEY(14,2),
                                             eSdoExigInt    MONEY(14,2),
                                             eIvaIntVig     MONEY(14,2),
                                             eIvaIntVenc    MONEY(14,2),
											 eMesesVdos     INTEGER,
											 eMoratorios    MONEY(14,2),
                                             eFecha         DATE)
RETURNING CHAR(3);


 DEFINE vsqlerr             INTEGER;
 DEFINE vCodRet             CHAR(3);
 DEFINE vFecha_mesant       DATE;
 DEFINE vFecha_primes       DATE;
 DEFINE eDia                INTEGER;
-- DEFINE vDiaCapital         INTEGER;
-- DEFINE vDiaVencido         INTEGER;
-- DEFINE vDiaNoExig          INTEGER;
-- DEFINE vDiaExig            INTEGER;

 define vexiste             integer;

 LET vCodRet = '000';
 LET vsqlerr = 0;
 let vexiste = 0;

 -- CONTROL DE ERRORES
BEGIN
 ON EXCEPTION SET vsqlerr
    IF vsqlerr != 0 THEN
       LET vCodRet=vsqlerr;
       RETURN vCodRet;
    END IF;
 END EXCEPTION;

--    SET DEBUG FILE TO "sp_actsdodiario.out";
--    TRACE ON;

--    IF eSdoCapital<=0 THEN LET eSdoCapital=0; LET vDiaCapital=0; ELSE LET vDiaCapital=1; END IF;
--    IF eMontoVencido<=0 THEN LET eMontoVencido=0; LET vDiaVencido=0; ELSE LET vDiaVencido=1; END IF;
--    IF eCapTrasNo<=0 THEN LET eCapTrasNo=0; LET vDiaNoExig=0; ELSE LET vDiaNoExig=1; END IF;
--    IF eMtoVencTrasp<=0 THEN LET eMtoVencTrasp=0; LET vDiaExig=0; ELSE LET vDiaExig=1; END IF;
--    IF eSdoIntereses<=0 THEN LET eSdoIntereses=0; END IF;
--    IF eSdoExigInt<=0 THEN LET eSdoExigInt=0; END IF;
--    IF eIvaIntVig<=0 THEN LET eIvaIntVig=0; END IF;
--    IF eIvaIntVenc<=0 THEN LET eIvaIntVenc=0; END IF;

--    IF eSdoCapital<=0 THEN LET vDiaCapital=0; ELSE LET vDiaCapital=1; END IF;
--    IF eMontoVencido<=0 THEN LET vDiaVencido=0; ELSE LET vDiaVencido=1; END IF;
--    IF eCapTrasNo<=0 THEN LET vDiaNoExig=0; ELSE LET vDiaNoExig=1; END IF;
--    IF eMtoVencTrasp<=0 THEN LET vDiaExig=0; ELSE LET vDiaExig=1; END IF;

IF DAY(eFecha)=1 THEN
        LET vFecha_mesant=DATE(eFecha- 2 UNITS MONTH);
             UPDATE sd_sdodiario SET capvig1        =  0,captrans1      =  0,capvencnoexig1 =  0,capvenexig1    =  0,
                                     intvig1        =  0,intvenc1       =  0,ivaintvig1     =  0,ivaintvenc1    =  0,
                                     capvig2        =  0,captrans2      =  0,capvencnoexig2 =  0,capvenexig2    =  0,
                                     intvig2        =  0,intvenc2       =  0,ivaintvig2     =  0,ivaintvenc2    =  0,
                                     capvig3        =  0,captrans3      =  0,capvencnoexig3 =  0,capvenexig3    =  0,
                                     intvig3        =  0,intvenc3       =  0,ivaintvig3     =  0,ivaintvenc3    =  0,
                                     capvig4        =  0,captrans4      =  0,capvencnoexig4 =  0,capvenexig4    =  0,
                                     intvig4        =  0,intvenc4       =  0,ivaintvig4     =  0,ivaintvenc4    =  0,
                                     capvig5        =  0,captrans5      =  0,capvencnoexig5 =  0,capvenexig5    =  0,
                                     intvig5        =  0,intvenc5       =  0,ivaintvig5     =  0,ivaintvenc5    =  0,
                                     capvig6        =  0,captrans6      =  0,capvencnoexig6 =  0,capvenexig6    =  0,
                                     intvig6        =  0,intvenc6       =  0,ivaintvig6     =  0,ivaintvenc6    =  0,
                                     capvig7        =  0,captrans7      =  0,capvencnoexig7 =  0,capvenexig7    =  0,
                                     intvig7        =  0,intvenc7       =  0,ivaintvig7     =  0,ivaintvenc7    =  0,
                                     capvig8        =  0,captrans8      =  0,capvencnoexig8 =  0,capvenexig8    =  0,
                                     intvig8        =  0,intvenc8       =  0,ivaintvig8     =  0,ivaintvenc8    =  0,
                                     capvig9        =  0,captrans9      =  0,capvencnoexig9 =  0,capvenexig9    =  0,
                                     intvig9        =  0,intvenc9       =  0,ivaintvig9     =  0,ivaintvenc9    =  0,
                                     capvig10       =  0,captrans10     =  0,capvencnoexig10=  0,capvenexig10   =  0,
                                     intvig10       =  0,intvenc10      =  0,ivaintvig10    =  0,ivaintvenc10   =  0,
                                     capvig11       =  0,captrans11     =  0,capvencnoexig11=  0,capvenexig11   =  0,
                                     intvig11       =  0,intvenc11      =  0,ivaintvig11    =  0,ivaintvenc11   =  0,
                                     capvig12       =  0,captrans12     =  0,capvencnoexig12=  0,capvenexig12   =  0,
                                     intvig12       =  0,intvenc12      =  0,ivaintvig12    =  0,ivaintvenc12   =  0,
                                     capvig13       =  0,captrans13     =  0,capvencnoexig13=  0,capvenexig13   =  0,
                                     intvig13       =  0,intvenc13      =  0,ivaintvig13    =  0,ivaintvenc13   =  0,
                                     capvig14       =  0,captrans14     =  0,capvencnoexig14=  0,capvenexig14   =  0,
                                     intvig14       =  0,intvenc14      =  0,ivaintvig14    =  0,ivaintvenc14   =  0,
                                     capvig15       =  0,captrans15     =  0,capvencnoexig15=  0,capvenexig15   =  0,
                                     intvig15       =  0,intvenc15      =  0,ivaintvig15    =  0,ivaintvenc15   =  0,
                                     capvig16       =  0,captrans16     =  0,capvencnoexig16=  0,capvenexig16   =  0,
                                     intvig16       =  0,intvenc16      =  0,ivaintvig16    =  0,ivaintvenc16   =  0,
                                     capvig17       =  0,captrans17     =  0,capvencnoexig17=  0,capvenexig17   =  0,
                                     intvig17       =  0,intvenc17      =  0,ivaintvig17    =  0,ivaintvenc17   =  0,
                                     capvig18       =  0,captrans18     =  0,capvencnoexig18=  0,capvenexig18   =  0,
                                     intvig18       =  0,intvenc18      =  0,ivaintvig18    =  0,ivaintvenc18   =  0,
                                     capvig19       =  0,captrans19     =  0,capvencnoexig19=  0,capvenexig19   =  0,
                                     intvig19       =  0,intvenc19      =  0,ivaintvig19    =  0,ivaintvenc19   =  0,
                                     capvig20       =  0,captrans20     =  0,capvencnoexig20=  0,capvenexig20   =  0,
                                     intvig20       =  0,intvenc20      =  0,ivaintvig20    =  0,ivaintvenc20   =  0,
                                     capvig21       =  0,captrans21     =  0,capvencnoexig21=  0,capvenexig21   =  0,
                                     intvig21       =  0,intvenc21      =  0,ivaintvig21    =  0,ivaintvenc21   =  0,
                                     capvig22       =  0,captrans22     =  0,capvencnoexig22=  0,capvenexig22   =  0,
                                     intvig22       =  0,intvenc22      =  0,ivaintvig22    =  0,ivaintvenc22   =  0,
                                     capvig23       =  0,captrans23     =  0,capvencnoexig23=  0,capvenexig23   =  0,
                                     intvig23       =  0,intvenc23      =  0,ivaintvig23    =  0,ivaintvenc23   =  0,
                                     capvig24       =  0,captrans24     =  0,capvencnoexig24=  0,capvenexig24   =  0,
                                     intvig24       =  0,intvenc24      =  0,ivaintvig24    =  0,ivaintvenc24   =  0,
                                     capvig25       =  0,captrans25     =  0,capvencnoexig25=  0,capvenexig25   =  0,
                                     intvig25       =  0,intvenc25      =  0,ivaintvig25    =  0,ivaintvenc25   =  0,
                                     capvig26       =  0,captrans26     =  0,capvencnoexig26=  0,capvenexig26   =  0,
                                     intvig26       =  0,intvenc26      =  0,ivaintvig26    =  0,ivaintvenc26   =  0,
                                     capvig27       =  0,captrans27     =  0,capvencnoexig27=  0,capvenexig27   =  0,
                                     intvig27       =  0,intvenc27      =  0,ivaintvig27    =  0,ivaintvenc27   =  0,
                                     capvig28       =  0,captrans28     =  0,capvencnoexig28=  0,capvenexig28   =  0,
                                     intvig28       =  0,intvenc28      =  0,ivaintvig28    =  0,ivaintvenc28   =  0,
                                     capvig29       =  0,captrans29     =  0,capvencnoexig29=  0,capvenexig29   =  0,
                                     intvig29       =  0,intvenc29      =  0,ivaintvig29    =  0,ivaintvenc29   =  0,
                                     capvig30       =  0,captrans30     =  0,capvencnoexig30=  0,capvenexig30   =  0,
                                     intvig30       =  0,intvenc30      =  0,ivaintvig30    =  0,ivaintvenc30   =  0,
                                     capvig31       =  0,captrans31     =  0,capvencnoexig31=  0,capvenexig31   =  0,
                                     intvig31       =  0,intvenc31      =  0,ivaintvig31    =  0,ivaintvenc31   =  0,
                                     diacapvig      = 0,acucapvig      = 0,diacaptra      = 0,acucaptra      = 0,
                                     diacapvennoexig  = 0, acucapvennoexig  = 0, diacapvencexig   = 0, acucapvencexig   = 0,
									 meses_vencidos1  = 0, meses_vencidos2  = 0, meses_vencidos3  = 0, meses_vencidos4  = 0,
									 meses_vencidos5  = 0, meses_vencidos6  = 0, meses_vencidos7  = 0, meses_vencidos8  = 0,
									 meses_vencidos9  = 0, meses_vencidos10 = 0, meses_vencidos11 = 0, meses_vencidos12 = 0,
									 meses_vencidos13 = 0, meses_vencidos14 = 0, meses_vencidos15 = 0, meses_vencidos16 = 0,
									 meses_vencidos17 = 0, meses_vencidos18 = 0, meses_vencidos19 = 0, meses_vencidos20 = 0,
									 meses_vencidos21 = 0, meses_vencidos22 = 0, meses_vencidos23 = 0, meses_vencidos24 = 0,
									 meses_vencidos25 = 0, meses_vencidos26 = 0, meses_vencidos27 = 0, meses_vencidos28 = 0,
									 meses_vencidos29 = 0, meses_vencidos30 = 0, meses_vencidos31 = 0,
 									 moratorios1  = 0, moratorios2  = 0, moratorios3  = 0, moratorios4  = 0, moratorios5  = 0,
									 moratorios6  = 0, moratorios7  = 0, moratorios8  = 0, moratorios9  = 0, moratorios10 = 0,
									 moratorios11 = 0, moratorios12 = 0, moratorios13 = 0, moratorios14 = 0, moratorios15 = 0,
									 moratorios16 = 0, moratorios17 = 0, moratorios18 = 0, moratorios19 = 0, moratorios20 = 0,
									 moratorios21 = 0, moratorios22 = 0, moratorios23 = 0, moratorios24 = 0, moratorios25 = 0,
									 moratorios26 = 0, moratorios27 = 0, moratorios28 = 0, moratorios29 = 0, moratorios30 = 0,
									 moratorios31 = 0,
									 fecha=eFecha
             WHERE fecha=vFecha_mesant
               AND num_credito = eNumCredito;
    END IF;

    LET vFecha_primes=MDY(MONTH(eFecha),'01',YEAR(eFecha));
    let eDia=day(eFecha);

      Select count(*)
        into vexiste
        from sd_sdodiario
       where fecha=vFecha_primes
        and num_credito = eNumCredito;

    if (vexiste = 0) then
             INSERT INTO sd_sdodiario
             VALUES(vFecha_primes,eNumCredito, eSucursal,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    end if;

    if (eSdoCapital + eMontoVencido + eCapTrasNo + eMtoVencTrasp + eSdoExigInt + eIvaIntVenc + eMoratorios) <> 0 then
        if (eDia <=15) then
            if (eDia <= 7) then
                if  (eDia = 1) then
                     UPDATE sd_sdodiario SET capvig1         = eSdoCapital,
                                             captrans1       = eMontoVencido,
                                             capvencnoexig1  = eCapTrasNo,
                                             capvenexig1     = eMtoVencTrasp,
                                             intvig1         = eSdoIntereses,
                                             intvenc1        = eSdoExigInt,
                                             ivaintvig1      = eIvaIntVig,
                                             ivaintvenc1     = eIvaIntVenc,
											 meses_vencidos1 = eMesesVdos,
											 moratorios1     = eMoratorios
                     WHERE fecha=vFecha_primes
                       AND num_credito = eNumCredito;

                 elif (eDia = 2) then
                     UPDATE sd_sdodiario SET capvig2        =  eSdoCapital,
                                             captrans2      =  eMontoVencido,
                                             capvencnoexig2 =  eCapTrasNo,
                                             capvenexig2    =  eMtoVencTrasp,
                                             intvig2        =  eSdoIntereses,
                                             intvenc2       =  eSdoExigInt,
                                             ivaintvig2     =  eIvaIntVig,
                                             ivaintvenc2    =  eIvaIntVenc,
                                             meses_vencidos2 = eMesesVdos,
											 moratorios2     = eMoratorios
                     WHERE fecha=vFecha_primes
                       AND num_credito = eNumCredito;

                 elif (eDia = 3) then
                             UPDATE sd_sdodiario SET capvig3        =  eSdoCapital,
                                                     captrans3      =  eMontoVencido,
                                                     capvencnoexig3 =  eCapTrasNo,
                                                     capvenexig3    =  eMtoVencTrasp,
                                                     intvig3        =  eSdoIntereses,
                                                     intvenc3       =  eSdoExigInt,
                                                     ivaintvig3     =  eIvaIntVig,
                                                     ivaintvenc3    =  eIvaIntVenc,
											         meses_vencidos3 = eMesesVdos,
											         moratorios3     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 4) then
                             UPDATE sd_sdodiario SET capvig4         =  eSdoCapital,
                                                     captrans4       =  eMontoVencido,
                                                     capvencnoexig4  =  eCapTrasNo,
                                                     capvenexig4     =  eMtoVencTrasp,
                                                     intvig4         =  eSdoIntereses,
                                                     intvenc4        =  eSdoExigInt,
                                                     ivaintvig4      =  eIvaIntVig,
                                                     ivaintvenc4     =  eIvaIntVenc,
													 meses_vencidos4 = eMesesVdos,
											         moratorios4     = eMoratorios													 
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 5) then
                             UPDATE sd_sdodiario SET capvig5        =  eSdoCapital,
                                                     captrans5      =  eMontoVencido,
                                                     capvencnoexig5 =  eCapTrasNo,
                                                     capvenexig5    =  eMtoVencTrasp,
                                                     intvig5        =  eSdoIntereses,
                                                     intvenc5       =  eSdoExigInt,
                                                     ivaintvig5     =  eIvaIntVig,
                                                     ivaintvenc5    =  eIvaIntVenc,
													 meses_vencidos5 = eMesesVdos,
											         moratorios5     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 6) then
                             UPDATE sd_sdodiario SET capvig6         = eSdoCapital,
                                                     captrans6       = eMontoVencido,
                                                     capvencnoexig6  = eCapTrasNo,
                                                     capvenexig6     = eMtoVencTrasp,
                                                     intvig6         = eSdoIntereses,
                                                     intvenc6        = eSdoExigInt,
                                                     ivaintvig6      = eIvaIntVig,
                                                     ivaintvenc6     = eIvaIntVenc,
													 meses_vencidos6 = eMesesVdos,
											         moratorios6     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig7         = eSdoCapital,
                                                     captrans7       = eMontoVencido,
                                                     capvencnoexig7  = eCapTrasNo,
                                                     capvenexig7     = eMtoVencTrasp,
                                                     intvig7         = eSdoIntereses,
                                                     intvenc7        = eSdoExigInt,
                                                     ivaintvig7      = eIvaIntVig,
                                                     ivaintvenc7     = eIvaIntVenc,
													 meses_vencidos7 = eMesesVdos,
											         moratorios7     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; -- 1-7
             else
                 if (eDia = 8) then
                             UPDATE sd_sdodiario SET capvig8         = eSdoCapital,
                                                     captrans8       = eMontoVencido,
                                                     capvencnoexig8  = eCapTrasNo,
                                                     capvenexig8     = eMtoVencTrasp,
                                                     intvig8         = eSdoIntereses,
                                                     intvenc8        = eSdoExigInt,
                                                     ivaintvig8      = eIvaIntVig,
                                                     ivaintvenc8     = eIvaIntVenc,
                                                     meses_vencidos8 = eMesesVdos,
											         moratorios8     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 9) then
                             UPDATE sd_sdodiario SET capvig9         = eSdoCapital,
                                                     captrans9       = eMontoVencido,
                                                     capvencnoexig9  = eCapTrasNo,
                                                     capvenexig9     = eMtoVencTrasp,
                                                     intvig9         = eSdoIntereses,
                                                     intvenc9        = eSdoExigInt,
                                                     ivaintvig9      = eIvaIntVig,
                                                     ivaintvenc9     = eIvaIntVenc,
													 meses_vencidos9 = eMesesVdos,
											         moratorios9     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 10) then
                             UPDATE sd_sdodiario SET capvig10         = eSdoCapital,
                                                     captrans10       = eMontoVencido,
                                                     capvencnoexig10  = eCapTrasNo,
                                                     capvenexig10     = eMtoVencTrasp,
                                                     intvig10         = eSdoIntereses,
                                                     intvenc10        = eSdoExigInt,
                                                     ivaintvig10      = eIvaIntVig,
                                                     ivaintvenc10     = eIvaIntVenc,
                                                     meses_vencidos10 = eMesesVdos,
											         moratorios10     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 11) then
                             UPDATE sd_sdodiario SET capvig11         = eSdoCapital,
                                                     captrans11       = eMontoVencido,
                                                     capvencnoexig11  = eCapTrasNo,
                                                     capvenexig11     = eMtoVencTrasp,
                                                     intvig11         = eSdoIntereses,
                                                     intvenc11        = eSdoExigInt,
                                                     ivaintvig11      = eIvaIntVig,
                                                     ivaintvenc11     = eIvaIntVenc,
													 meses_vencidos11 = eMesesVdos,
											         moratorios11     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 12) then
                             UPDATE sd_sdodiario SET capvig12         = eSdoCapital,
                                                     captrans12       = eMontoVencido,
                                                     capvencnoexig12  = eCapTrasNo,
                                                     capvenexig12     = eMtoVencTrasp,
                                                     intvig12         = eSdoIntereses,
                                                     intvenc12        = eSdoExigInt,
                                                     ivaintvig12      = eIvaIntVig,
                                                     ivaintvenc12     = eIvaIntVenc,
													 meses_vencidos12 = eMesesVdos,
											         moratorios12     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 13) then
                             UPDATE sd_sdodiario SET capvig13         = eSdoCapital,
                                                     captrans13       = eMontoVencido,
                                                     capvencnoexig13  = eCapTrasNo,
                                                     capvenexig13     = eMtoVencTrasp,
                                                     intvig13         = eSdoIntereses,
                                                     intvenc13        = eSdoExigInt,
                                                     ivaintvig13      = eIvaIntVig,
                                                     ivaintvenc13     = eIvaIntVenc,
													 meses_vencidos13 = eMesesVdos,
											         moratorios13     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 14) then
                             UPDATE sd_sdodiario SET capvig14         = eSdoCapital,
                                                     captrans14       = eMontoVencido,
                                                     capvencnoexig14  = eCapTrasNo,
                                                     capvenexig14     = eMtoVencTrasp,
                                                     intvig14         = eSdoIntereses,
                                                     intvenc14        = eSdoExigInt,
                                                     ivaintvig14      = eIvaIntVig,
                                                     ivaintvenc14     = eIvaIntVenc,
													 meses_vencidos14 = eMesesVdos,
											         moratorios14     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig15         = eSdoCapital,
                                                     captrans15       = eMontoVencido,
                                                     capvencnoexig15  = eCapTrasNo,
                                                     capvenexig15     = eMtoVencTrasp,
                                                     intvig15         = eSdoIntereses,
                                                     intvenc15        = eSdoExigInt,
                                                     ivaintvig15      = eIvaIntVig,
                                                     ivaintvenc15     = eIvaIntVenc,
													 meses_vencidos15 = eMesesVdos,
											         moratorios15     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; -- if 8-15
             end if; -- if 7
         else
             if (eDia <= 23) then
                 if (eDia = 16) then
                             UPDATE sd_sdodiario SET capvig16         = eSdoCapital,
                                                     captrans16       = eMontoVencido,
                                                     capvencnoexig16  = eCapTrasNo,
                                                     capvenexig16     = eMtoVencTrasp,
                                                     intvig16         = eSdoIntereses,
                                                     intvenc16        = eSdoExigInt,
                                                     ivaintvig16      = eIvaIntVig,
                                                     ivaintvenc16     = eIvaIntVenc,
													 meses_vencidos16 = eMesesVdos,
											         moratorios16     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 17) then
                             UPDATE sd_sdodiario SET capvig17         = eSdoCapital,
                                                     captrans17       = eMontoVencido,
                                                     capvencnoexig17  = eCapTrasNo,
                                                     capvenexig17     = eMtoVencTrasp,
                                                     intvig17         = eSdoIntereses,
                                                     intvenc17        = eSdoExigInt,
                                                     ivaintvig17      = eIvaIntVig,
                                                     ivaintvenc17     = eIvaIntVenc,
													 meses_vencidos17 = eMesesVdos,
											         moratorios17     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 18) then
                             UPDATE sd_sdodiario SET capvig18         = eSdoCapital,
                                                     captrans18       = eMontoVencido,
                                                     capvencnoexig18  = eCapTrasNo,
                                                     capvenexig18     = eMtoVencTrasp,
                                                     intvig18         = eSdoIntereses,
                                                     intvenc18        = eSdoExigInt,
                                                     ivaintvig18      = eIvaIntVig,
                                                     ivaintvenc18     = eIvaIntVenc,
													 meses_vencidos18 = eMesesVdos,
											         moratorios18     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 19) then
                             UPDATE sd_sdodiario SET capvig19         = eSdoCapital,
                                                     captrans19       = eMontoVencido,
                                                     capvencnoexig19  = eCapTrasNo,
                                                     capvenexig19     = eMtoVencTrasp,
                                                     intvig19         = eSdoIntereses,
                                                     intvenc19        = eSdoExigInt,
                                                     ivaintvig19      = eIvaIntVig,
                                                     ivaintvenc19     = eIvaIntVenc,
													 meses_vencidos19 = eMesesVdos,
											         moratorios19     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 20) then
                             UPDATE sd_sdodiario SET capvig20         = eSdoCapital,
                                                     captrans20       = eMontoVencido,
                                                     capvencnoexig20  = eCapTrasNo,
                                                     capvenexig20     = eMtoVencTrasp,
                                                     intvig20         = eSdoIntereses,
                                                     intvenc20        = eSdoExigInt,
                                                     ivaintvig20      = eIvaIntVig,
                                                     ivaintvenc20     = eIvaIntVenc,
													 meses_vencidos20 = eMesesVdos,
											         moratorios20     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 21) then
                             UPDATE sd_sdodiario SET capvig21         = eSdoCapital,
                                                     captrans21       = eMontoVencido,
                                                     capvencnoexig21  = eCapTrasNo,
                                                     capvenexig21     = eMtoVencTrasp,
                                                     intvig21         = eSdoIntereses,
                                                     intvenc21        = eSdoExigInt,
                                                     ivaintvig21      = eIvaIntVig,
                                                     ivaintvenc21     = eIvaIntVenc,
													 meses_vencidos21 = eMesesVdos,
											         moratorios21     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 22) then
                             UPDATE sd_sdodiario SET capvig22         = eSdoCapital,
                                                     captrans22       = eMontoVencido,
                                                     capvencnoexig22  = eCapTrasNo,
                                                     capvenexig22     = eMtoVencTrasp,
                                                     intvig22         = eSdoIntereses,
                                                     intvenc22        = eSdoExigInt,
                                                     ivaintvig22      = eIvaIntVig,
                                                     ivaintvenc22     = eIvaIntVenc,
													 meses_vencidos22 = eMesesVdos,
											         moratorios22     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig23         = eSdoCapital,
                                                     captrans23       = eMontoVencido,
                                                     capvencnoexig23  = eCapTrasNo,
                                                     capvenexig23     = eMtoVencTrasp,
                                                     intvig23         = eSdoIntereses,
                                                     intvenc23        = eSdoExigInt,
                                                     ivaintvig23      = eIvaIntVig,
                                                     ivaintvenc23     = eIvaIntVenc,
													 meses_vencidos23 = eMesesVdos,
											         moratorios23     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; --if 16-23
             else
                 if (eDia = 24) then
                             UPDATE sd_sdodiario SET capvig24         = eSdoCapital,
                                                     captrans24       = eMontoVencido,
                                                     capvencnoexig24  = eCapTrasNo,
                                                     capvenexig24     = eMtoVencTrasp,
                                                     intvig24         = eSdoIntereses,
                                                     intvenc24        = eSdoExigInt,
                                                     ivaintvig24      = eIvaIntVig,
                                                     ivaintvenc24     = eIvaIntVenc,
													 meses_vencidos24 = eMesesVdos,
											         moratorios24     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 25) then
                             UPDATE sd_sdodiario SET capvig25         = eSdoCapital,
                                                     captrans25       = eMontoVencido,
                                                     capvencnoexig25  = eCapTrasNo,
                                                     capvenexig25     = eMtoVencTrasp,
                                                     intvig25         = eSdoIntereses,
                                                     intvenc25        = eSdoExigInt,
                                                     ivaintvig25      = eIvaIntVig,
                                                     ivaintvenc25     = eIvaIntVenc,
													 meses_vencidos25 = eMesesVdos,
											         moratorios25     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 26) then
                             UPDATE sd_sdodiario SET capvig26         = eSdoCapital,
                                                     captrans26       = eMontoVencido,
                                                     capvencnoexig26  = eCapTrasNo,
                                                     capvenexig26     = eMtoVencTrasp,
                                                     intvig26         = eSdoIntereses,
                                                     intvenc26        = eSdoExigInt,
                                                     ivaintvig26      = eIvaIntVig,
                                                     ivaintvenc26     = eIvaIntVenc,
													 meses_vencidos26 = eMesesVdos,
											         moratorios26     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 27) then
                             UPDATE sd_sdodiario SET capvig27         = eSdoCapital,
                                                     captrans27       = eMontoVencido,
                                                     capvencnoexig27  = eCapTrasNo,
                                                     capvenexig27     = eMtoVencTrasp,
                                                     intvig27         = eSdoIntereses,
                                                     intvenc27        = eSdoExigInt,
                                                     ivaintvig27      = eIvaIntVig,
                                                     ivaintvenc27     = eIvaIntVenc,
													 meses_vencidos27 = eMesesVdos,
											         moratorios27     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 28) then
                             UPDATE sd_sdodiario SET capvig28         = eSdoCapital,
                                                     captrans28       = eMontoVencido,
                                                     capvencnoexig28  = eCapTrasNo,
                                                     capvenexig28     = eMtoVencTrasp,
                                                     intvig28         = eSdoIntereses,
                                                     intvenc28        = eSdoExigInt,
                                                     ivaintvig28      = eIvaIntVig,
                                                     ivaintvenc28     = eIvaIntVenc,
													 meses_vencidos28 = eMesesVdos,
											         moratorios28     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 29) then
                             UPDATE sd_sdodiario SET capvig29         = eSdoCapital,
                                                     captrans29       = eMontoVencido,
                                                     capvencnoexig29  = eCapTrasNo,
                                                     capvenexig29     = eMtoVencTrasp,
                                                     intvig29         = eSdoIntereses,
                                                     intvenc29        = eSdoExigInt,
                                                     ivaintvig29      = eIvaIntVig,
                                                     ivaintvenc29     = eIvaIntVenc,
													 meses_vencidos29 = eMesesVdos,
											         moratorios29     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 elif (eDia = 30) then
                             UPDATE sd_sdodiario SET capvig30         = eSdoCapital,
                                                     captrans30       = eMontoVencido,
                                                     capvencnoexig30  = eCapTrasNo,
                                                     capvenexig30     = eMtoVencTrasp,
                                                     intvig30         = eSdoIntereses,
                                                     intvenc30        = eSdoExigInt,
                                                     ivaintvig30      = eIvaIntVig,
                                                     ivaintvenc30     = eIvaIntVenc,
													 meses_vencidos30 = eMesesVdos,
											         moratorios30     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;

                 else
                             UPDATE sd_sdodiario SET capvig31        =  eSdoCapital,
                                                     captrans31      =  eMontoVencido,
                                                     capvencnoexig31 =  eCapTrasNo,
                                                     capvenexig31    =  eMtoVencTrasp,
                                                     intvig31        =  eSdoIntereses,
                                                     intvenc31       =  eSdoExigInt,
                                                     ivaintvig31     =  eIvaIntVig,
                                                     ivaintvenc31    =  eIvaIntVenc,
													 meses_vencidos31 = eMesesVdos,
											         moratorios31     = eMoratorios
                             WHERE fecha=vFecha_primes
                               AND num_credito = eNumCredito;
                 end if; --if 24-31
            end if; -- if 23
       end if; -- if 15
    END IF;
END
	RETURN vCodRet;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".ugenera_layoutedocuenta_adn(pempresa CHAR(3),pperiodo DATE)
RETURNING CHAR(5);

DEFINE v_ruta      VARCHAR(255);
DEFINE v_ruta_cfd  VARCHAR(255);
DEFINE cod_ret     CHAR(5);
DEFINE sql_err     INTEGER;
DEFINE v_sql        CHAR(7000);
DEFINE v_sql1       CHAR(1500);
DEFINE v_sql2       CHAR(1500);
DEFINE v_sql3       CHAR(1500);
DEFINE v_sql4       CHAR(1000);
DEFINE v_sql5       CHAR(1000);
DEFINE cNumCred     CHAR(20);
DEFINE cNumCredAux  CHAR(20);
DEFINE cNumCte      CHAR(20);
DEFINE cNumCteAux   CHAR(20);
DEFINE iMovMax      INTEGER;
DEFINE sPaso        SMALLINT;

LET v_ruta      = "";
LET v_sql       = "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET sPaso       = 0; 
LET cNumCred    = "";
LET cNumCredAux = "";
LET cNumCte     = "";
LET cNumCteAux  = "";
LET iMovMax     = 0;

--SET DEBUG FILE TO "/informix/jesus/RQM10617/lib/ugenera_layoutedocuenta.out";
--TRACE ON;

set isolation to dirty read;
set lock mode to wait 3;


BEGIN

   ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

-----------------OBTENGO LA FECHA DE PROCESO---------------------------------------------------

SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';
SELECT TRIM(valor) INTO v_ruta_cfd FROM sd_param WHERE empresa = pempresa AND cod_param = '037';
                  

	-----------------ENCABEZADO DOS---------------------------------------------------ARCHIVO 200
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
                  ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
                  ' nvl ( capital_tc,0),'||
                  ' nvl ( interes_tc,0),'||
                  ' nvl ( iva_interes_tc,0),'||
                  ' nvl ( capital_ven_tc,0),'||
                  ' nvl ( interes_ven_tc,0),'||
	          ' nvl ( iva_interes_ven_tc,0),'||
                  ' nvl ( moratorios_tc,0),'||
                  ' nvl ( iva_moratorios_tc,0),'||                 
                  ' nvl ( interes_pago_total_tc,0),'||                  
                  ' date(1),'||
                  ' nvl ( periodo_tc_ini,0),'||
                  ' nvl ( periodo_tc_fin,date(1)),'||                 
                  ' nvl ( fecha_corte,date(1)),'||
                  ' nvl ( replace ( replace( dias_periodo_tc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( limite_tc,0),'||                  
                  ' nvl ( pago_antes_de,date(1)),'||
	          ' nvl ( sus_comisiones,0),'||                  
                  ' nvl ( mas_intereses,0),'||
                  ' nvl ( menos_abonos,0)'||
                  ' FROM sd_encabezado2_edocta a';
       LET v_sql3=' WHERE a.fecha_emision = '''||pperiodo||'''   " > query200.sql';


	 LET v_sql = v_sql1||v_sql2||v_sql3;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query200.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'ArchivoADN200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES



	-----------------DETALLE---------------------------------------------------ARCHIVO 300
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( fecha_mov,'' ''),'||
            ' nvl ( replace ( replace( concepto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( cargos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( abonos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_detalle_edocta a '||
            ' WHERE a.fecha_emision ='''||pperiodo||'''   ORDER BY a.num_credito,secuencia,nlinea"'||
            ' > query300.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query300.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'ArchivoADN300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------ACLARACIONES---------------------------------------------------ARCHIVO 400
	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
         LET v_sql2 = ' SELECT nvl ( fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( secuencia,0),'||
            ' nvl ( nlinea,0),'||
            ' nvl ( replace ( replace( fecha_aclara, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( folio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( fecha_movimiento, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( descripcion, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( importe,0) FROM sd_aclaraciones_edocta a '||
            ' WHERE a.fecha_emision ='''||pperiodo||'''   ORDER BY a.num_credito,secuencia,nlinea"'||
            ' > query400.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query400.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'ArchivoADN400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES


	-----------------MENSAJES---------------------------------------------------ARCHIVO 500

    LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';

    LET v_sql2 = ' SELECT nvl (a.fecha_emision,date(1)),'||
        ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
        ' nvl ( a.secuencia,0),'||
        ' nvl ( a.nlinea,0),'||
        ' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
        ' nvl ( replace ( replace( a.mensajes, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ) FROM sd_mensajes_edocta a '||
		 ' WHERE a.fecha_emision ='''||pperiodo|| ''' ' ||
        '   ORDER BY 2,3,4"'||
		' > query500.sql';		
	
		
	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query500.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'ArchivoADN500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
	  
	  --FIN DE COMPRIMIR. Este archivo se queda unicamente en archivoscartera (No se copia ni mueve).



	-----------------MENSAJES ARCHIVO 500 BIS -----------ARCHIVO DE MENSAJES ANTERIOR----------------------------------  
-----------------MENSAJES---------------------------------------------------
    LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga500B.unl';
    
	
	LET v_sql2 = ' SELECT nvl (a.fecha_emision,date(1)),'||
        ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
        ' (clave + 1 -43)::integer,'||
        ' ''1'','||
        ' nvl ( replace ( replace( '' '', ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
        '  nvl ( replace ( replace (replace ( b.mensajes, ''|'' , '' '' ), ''\'' , '' ''),''{1}'',meses_liq::CHAR(2)),'' '') FROM sd_mensajes_edocta a '||
		' left join   bdicred:sd_config_mensaje_edocta b on b.num_producto = '''||7800||''' '||
		' where a.num_credito =a.num_credito and a.secuencia= ''1'' '||		  
 ' UNION ALL '||
        ' SELECT a.fecha_emision,a.num_credito, a.secuencia, ''0'', '' '' , mensajes FROM bdicred:sd_mensajes_edocta a'||
        ' WHERE a.fecha_emision ='''||pperiodo|| ''' ' ||
        '  and num_credito = ''500'' ORDER BY 2,3,4"'||       
        ' > query500B.sql';
		
		


	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query500B.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga500B.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga500B.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > "||v_ruta||'ArchivoADN500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;	  
/*---
	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'Archivo500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y MOVER  A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES

	  
    -----------------MENSAJES ARCHIVO 800 ---------------------------------------------

    LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga800.unl';

     /*LET v_sql2 = ' SELECT 1, clave, mensajes FROM bdicred:sd_config_mensaje_edocta"'||
        ' > query501.sql';*/

     LET v_sql2 = ' SELECT '''||pperiodo||''', 1, clave, replace(replace (mensajes,''{0}'',''X1''),''{1}'',''X2'') FROM bdicred:sd_config_mensaje_edocta where num_producto = ''6001'' order by clave"'||
        ' > query800.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query800.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga800.unl'||" >"||v_ruta||'descarga1800.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga800.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1800.unl'||" > "||v_ruta||'ArchivoADN800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;
	  
      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1800.unl';
      SYSTEM v_sql;
	  

	  --COMPRIMIR Y COPIAR A LA RUTA DE CFD 
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES
	  
	-----------------PIE DE PAGINA---------------------------------------------------ARCHIVO 600

	 LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descarga.unl';
     LET v_sql2 = ' SELECT nvl (fecha_emision,date(1)),'||
            ' trim(nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )),'||
            ' nvl ( replace ( replace( tasa_mensual, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( round(tasa_anual,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( round(cat,1), ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( replace ( replace( saldo_promedio, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
            ' nvl ( tasa_mora,0),'||
			' case when nvl ( tasa_mensual_mora,0) - (trim(nvl ( tasa_mensual_mora,0)::CHAR(2))::int ) = 0 THEN '||
            ' (trim(nvl ( tasa_mensual_mora,0)::CHAR(2)))||''.00'' '||
            ' else '||
            ' (trim(nvl ( tasa_mensual_mora,0)::CHAR(2)))||substr(rpad(nvl (tasa_mensual_mora,0) - (trim(nvl (tasa_mensual_mora,0)::CHAR(2))::int ),4,0),2,3) '||
            ' end '||
			' FROM sd_pie_edocta a '||
            ' WHERE fecha_emision ='''||pperiodo||'''   "' ||
            ' > query600.sql';

	 LET v_sql = v_sql1||v_sql2;

     system v_sql;
	 LET v_sql = "dbaccess bdicred query600.sql";
	 system v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga.unl';
      SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga1.unl'||" > " ||v_ruta||'ArchivoADN600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban';
      SYSTEM v_sql;
	  
      LET v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;

	  --COMPRIMIR ARCHIVO GENERADO
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;

-----------------ENCABEZADO UNO---------------------------------------------------ARCHIVO 100
	 LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'descarga.unl';
	 LET v_sql2 = ' SELECT nvl ( fecha_emision,DATE(1)),'||
                  ' nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
	              ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),';
     LET v_sql3=  ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_gerente, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_tel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
     LET v_sql4=  ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )'||
                  ' FROM sd_encabezado_edocta a';
     LET v_sql5=  ' WHERE a.fecha_emision = '''||TO_CHAR(pperiodo,'%m/%d/%Y')||'''  order by ruta " > query100.sql';

	 LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
--||v_sql6;
	 system v_sql;

	 LET v_sql = "dbaccess bdicred query100.sql";
	 system v_sql;
 LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/Ã??Ã?Â´/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = 'sed "s/''/ /g" '||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
--"s/'/ /g"

		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/&/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/Ã??Ã?Â¨/ /g' "||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/>/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;


          LET v_sql = '';
		  LET v_sql = "sed 's/</ /g' "||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  
		  let v_sql = '';
		  LET v_sql = 'echo " cd '|| '\"'||v_ruta||'\"'||'" > eliminaespeciales.sh ' ;
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
		                         '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
                              '\"'||'])''//g'' '||v_ruta||'descarga1.unl'||" > "||v_ruta||'descarga2.unl'||
                              '" >>'||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  
		  LET v_sql = '';
		  LET v_sql = "./"||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  
		  let v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2.unl'||" > " || trim(v_ruta||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
		  SYSTEM v_sql;


	  --COMPRIME ARCHIVO GENERADO
	  LET v_sql = '';
	  LET v_sql = " gzip " || v_ruta||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES
	  
      let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;
	  
	  let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga2.unl';
      SYSTEM v_sql;

	  
	  --- ARCHIVO 100 DE CFDI con la atenciòn del RQI 12 379 Inclusión de Correo Electrónico en Archivos de TDC PIQV
	   LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'descarga.unl';
	 LET v_sql2 = ' SELECT nvl ( fecha_emision,DATE(1)),'||
                  ' nvl ( replace ( replace( a.num_credito, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( numcte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( num_tarjeta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( nombre_cte, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( direccion_cn, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' replace ( replace ( replace( direccion_col, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
	              ' replace ( replace ( replace( direccion_del, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),';
     LET v_sql3=  ' replace ( replace ( replace( edo_cd, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( cl_cobra, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_nombre, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_gerente, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( rfc, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal_tel, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( cp, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),';
     LET v_sql4=  ' replace ( replace ( replace( ruta, ''|'' , '' '' ), ''\'' , '' '' ), '''','' '' ),'||
                  ' nvl ( replace ( replace( entre_calles, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( observaciones, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( insertos, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
                  ' nvl ( replace ( replace( sucursal, ''|'' , '' '' ), ''\'' , '' '' ), '' '' ),'||
				   ' (SELECT TRIM(NVL(b.correo_elec,'' '')) FROM bdinteg:si_correos b WHERE b.numcte = a.numcte '||
				  ' AND b.secuencia IN (select max(d.secuencia) FROM bdinteg:si_correos d  WHERE d.numcte = a.numcte AND d.tipo_correo = b.tipo_correo '||
                  ' AND d.status_correo = b.status_correo AND d.valido = b.valido) AND b.tipo_correo = 1 AND b.status_correo = ''A'' AND b.valido = ''1'' ),'||
				  ' nvl ( replace ( replace( num_producto, ''|'' , '' '' ), ''\'' , '' '' ), '' '' )'||
                  ' FROM sd_encabezado_edocta a';
     LET v_sql5=  ' WHERE a.fecha_emision = '''||TO_CHAR(pperiodo,'%m/%d/%Y')||'''  order by ruta " > query100.sql';

	 LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;
--||v_sql6;
	 system v_sql;

	 LET v_sql = "dbaccess bdicred query100.sql";
	 system v_sql;
 LET v_sql = '';
		  LET v_sql = "sed 's/|$//g' "||v_ruta||'descarga.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/Ã??Ã?Â´/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = 'sed "s/''/ /g" '||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
--"s/'/ /g"

		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/&/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/Ã??Ã?Â¨/ /g' "||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

          LET v_sql = '';
		  LET v_sql = "sed 's/>/ /g' "||v_ruta||'descarga1.unl'||" >"||v_ruta||'descarga2.unl';
		  SYSTEM v_sql;


          LET v_sql = '';
		  LET v_sql = "sed 's/</ /g' "||v_ruta||'descarga2.unl'||" >"||v_ruta||'descarga1.unl';
		  SYSTEM v_sql;

		  
		  let v_sql = '';
		  LET v_sql = 'echo " cd '|| '\"'||v_ruta||'\"'||'" > eliminaespeciales.sh ' ;
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "chmod 777 "||'eliminaespeciales.sh ';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = ' echo '||'"'||' sed  -e ''s/''\$(echo ['||'\"'||'\\\001\\\002\\\003\\\004\\\005\\\006\\\007\\\010\\\016\\\017\\\020\\\021'||		                     
		                         '\\\022\\\023\\\024\\\025\\\026\\\027\\\030\\\031\\\032\\\033\\\034\\\035\\\036\\\037'||
                              '\"'||'])''//g'' '||v_ruta||'descarga1.unl'||" > "||v_ruta||'descarga2.unl'||
                              '" >>'||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  
		  LET v_sql = '';
		  LET v_sql = "./"||'eliminaespeciales.sh ';
		  SYSTEM v_sql;
		  
		  LET v_sql = '';
		  LET v_sql = "rm "||v_ruta||'descarga.unl';
		  SYSTEM v_sql;

		  LET v_sql = '';
		  LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descarga2.unl'||" > " || trim(v_ruta||'ArchivoADN100B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban');
		  SYSTEM v_sql;


	  --COMPRIME ARCHIVO GENERADO
	  --LET v_sql = '';
	  --LET v_sql = " gzip " || v_ruta||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      --SYSTEM v_sql;
--*/
	  --FIN DE COMPRIMIR Y COPIAR A LA RUTA DE CFD , EN ESTA SECCION VA PARA CADAD UNO DE LOS MENSAJES
	  
      let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga1.unl';
      SYSTEM v_sql;
	  
	  let v_sql = '';
      LET v_sql = "rm "||v_ruta||'descarga2.unl';
      SYSTEM v_sql;

	  
	  --- ARCHIVO 100 DE CFDI con la atenciòn del RQI 12 379 Inclusión de Correo Electrónico en Archivos de TDC PIQV
		
      ---------  COPIA ARCHIVOS CREADOS A LA DE CFD -------------------

	  --LET v_sql = '';
      --LET v_sql = "cp " || v_ruta|| 'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   --trim(v_ruta_cfd) ||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  --SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN200'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN300'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN400'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;
	  

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN800'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = "cp " || v_ruta|| 'ArchivoADN600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz '||
						   trim(v_ruta_cfd) ||'ArchivoADN600'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban.gz ';
	  SYSTEM v_sql;
	  
	
	  
	  LET v_sql = '';
      LET v_sql = "mv " || v_ruta|| 'ArchivoADN500B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban '||
						   trim(v_ruta_cfd) ||'ArchivoADN500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	  SYSTEM v_sql;
	  
	  
	  	  LET v_sql = '';
      LET v_sql = "mv " || v_ruta|| 'ArchivoADN100B'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban '||
						   trim(v_ruta_cfd) ||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
	  SYSTEM v_sql;

	  

    ---
	  --COMPRIMIR YA QUE AL PASAR SE PASA SIN COMPRIMIR PARA DEJAR EL MISMO NOMBRE
	  LET v_sql = '';
	  LET v_sql = " gzip " || trim(v_ruta_cfd)||'ArchivoADN500'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
	  
	  LET v_sql = '';
	  LET v_sql = " gzip " || trim(v_ruta_cfd)||'ArchivoADN100'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'a.ban ';
      SYSTEM v_sql;
	  
--*/
	  
	  
--*/  --FIN DE COPIAR A LA RUTA DE CFD.

	  LET v_sql = '';
      LET v_sql = 'rm query100.sql ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = 'rm query200.sql ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = 'rm query300.sql ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = 'rm query400.sql ';
	  SYSTEM v_sql;

	  LET v_sql = '';
      LET v_sql = 'rm query500.sql ';
	  SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = 'rm query600.sql ';
	  SYSTEM v_sql;

      LET v_sql = '';
      LET v_sql = 'rm query500B.sql ';
	  SYSTEM v_sql;

	  
	  LET v_sql = '';
      LET v_sql = 'rm query800.sql ';
	  SYSTEM v_sql;	  
	

  END;
  RETURN cod_ret;

END PROCEDURE;