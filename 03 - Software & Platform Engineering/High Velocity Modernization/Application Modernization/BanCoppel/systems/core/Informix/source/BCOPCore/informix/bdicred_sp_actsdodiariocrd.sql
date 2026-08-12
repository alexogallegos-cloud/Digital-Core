CREATE PROCEDURE "informix".sp_actsdodiariocrd(eNumCredito CHAR(20),
													 eSucursal      CHAR(4),
													 eSdoCapital    MONEY(14,2),
													 eMontoVencido  MONEY(14,2),
													 eCapTrasNo     MONEY(14,2),
													 eMtoVencTrasp  MONEY(14,2),
													 eSdoIntereses  MONEY(14,2),
													 eSdoExigInt    MONEY(14,2),
													 eIvaIntVig     MONEY(14,2),
													 eIvaIntVenc    MONEY(14,2),
													 eIntVenBal     MONEY(14,2),
													 eIvaIntVenBal  MONEY(14,2),
													 eMontoFinanciado MONEY(14,2),
													 eFecha         DATE,
													 eEtapa 		   CHAR(2),
													 iAtr			INTEGER)
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
 

 LET vCodRet = '000';
 LET vsqlerr = 0;

 -- CONTROL DE ERRORES
BEGIN
 ON EXCEPTION SET vsqlerr
    IF vsqlerr != 0 THEN
       LET vCodRet=vsqlerr;
       RETURN vCodRet;
    END IF;
 END EXCEPTION;
 
 SET LOCK MODE TO WAIT 3; 
 SET ISOLATION TO DIRTY READ; 
 
 
--SET DEBUG FILE TO  '/RESPALDOS/INFOSAT/RIESGOS/RQM07134/SDOSCRD/actsdodiariocrd_14crd.out';
--TRACE ON;
   
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
	
	--KSOV -- RQI 25 265 SE CAMBIA AL INICIO LAS SIGUIENTES ASIGNACIONES.
    LET vFecha_primes=MDY(MONTH(eFecha),'01',YEAR(eFecha));
    let eDia=day(eFecha);
	--KSOV

IF DAY(eFecha)=1  
	   OR (MONTH(eFecha) = 1 AND DAY(eFecha)= 2) --KSOV --RQI 25 265 SE AGREG VALIDACION PARA QUE SE ACTUALICE LE REGISTRO EN EL MES DE ENERO.
			 THEN			 
			 LET vFecha_mesant=DATE(eFecha- 3 UNITS MONTH);
			 
		IF --KSOV -- RQI 25 265 SE AGREG VALIDACION PARA QUE SE ACTUALICE LE REGISTRO EN EL MES DE ENERO.
		   MONTH(eFecha) = 1 THEN
		       LET eFecha=MDY(MONTH(eFecha),'01',YEAR(eFecha));
			   LET vFecha_mesant=DATE(eFecha- 3 UNITS MONTH);
		END IF; --KSOV


             UPDATE sd_sdodiariocrd SET capvig1        =  0,captrans1      =  0,capvencnoexig1 =  0,capvenexig1    =  0, ivaint_venc_bal1=  0, 
                                     intvig1        =  0,intvenc1       =  0,ivaintvig1     =  0,ivaintvenc1    =  0, int_venc_bal1=  0,
                                     capvig2        =  0,captrans2      =  0,capvencnoexig2 =  0,capvenexig2    =  0, ivaint_venc_bal2=  0,
                                     intvig2        =  0,intvenc2       =  0,ivaintvig2     =  0,ivaintvenc2    =  0, int_venc_bal2=  0,
                                     capvig3        =  0,captrans3      =  0,capvencnoexig3 =  0,capvenexig3    =  0, ivaint_venc_bal3=  0,
                                     intvig3        =  0,intvenc3       =  0,ivaintvig3     =  0,ivaintvenc3    =  0, int_venc_bal3=  0,
                                     capvig4        =  0,captrans4      =  0,capvencnoexig4 =  0,capvenexig4    =  0, ivaint_venc_bal4=  0,
                                     intvig4        =  0,intvenc4       =  0,ivaintvig4     =  0,ivaintvenc4    =  0, int_venc_bal4=  0,
                                     capvig5        =  0,captrans5      =  0,capvencnoexig5 =  0,capvenexig5    =  0, ivaint_venc_bal5=  0,
                                     intvig5        =  0,intvenc5       =  0,ivaintvig5     =  0,ivaintvenc5    =  0, int_venc_bal5=  0,
                                     capvig6        =  0,captrans6      =  0,capvencnoexig6 =  0,capvenexig6    =  0, ivaint_venc_bal6=  0,
                                     intvig6        =  0,intvenc6       =  0,ivaintvig6     =  0,ivaintvenc6    =  0, int_venc_bal6=  0,
                                     capvig7        =  0,captrans7      =  0,capvencnoexig7 =  0,capvenexig7    =  0, ivaint_venc_bal7=  0,
                                     intvig7        =  0,intvenc7       =  0,ivaintvig7     =  0,ivaintvenc7    =  0, int_venc_bal7=  0,
                                     capvig8        =  0,captrans8      =  0,capvencnoexig8 =  0,capvenexig8    =  0, ivaint_venc_bal8=  0,
                                     intvig8        =  0,intvenc8       =  0,ivaintvig8     =  0,ivaintvenc8    =  0, int_venc_bal8=  0,
                                     capvig9        =  0,captrans9      =  0,capvencnoexig9 =  0,capvenexig9    =  0, ivaint_venc_bal9=  0,
                                     intvig9        =  0,intvenc9       =  0,ivaintvig9     =  0,ivaintvenc9    =  0, int_venc_bal9=  0,
                                     capvig10       =  0,captrans10     =  0,capvencnoexig10=  0,capvenexig10   =  0, ivaint_venc_bal10= 0,
                                     intvig10       =  0,intvenc10      =  0,ivaintvig10    =  0,ivaintvenc10   =  0, int_venc_bal10=  0,
                                     capvig11       =  0,captrans11     =  0,capvencnoexig11=  0,capvenexig11   =  0, ivaint_venc_bal11=  0,
                                     intvig11       =  0,intvenc11      =  0,ivaintvig11    =  0,ivaintvenc11   =  0, int_venc_bal11=  0,
                                     capvig12       =  0,captrans12     =  0,capvencnoexig12=  0,capvenexig12   =  0, ivaint_venc_bal12=  0,
                                     intvig12       =  0,intvenc12      =  0,ivaintvig12    =  0,ivaintvenc12   =  0, int_venc_bal12=  0,
                                     capvig13       =  0,captrans13     =  0,capvencnoexig13=  0,capvenexig13   =  0, ivaint_venc_bal13=  0,
                                     intvig13       =  0,intvenc13      =  0,ivaintvig13    =  0,ivaintvenc13   =  0, int_venc_bal13=  0,
                                     capvig14       =  0,captrans14     =  0,capvencnoexig14=  0,capvenexig14   =  0, ivaint_venc_bal14=  0,
                                     intvig14       =  0,intvenc14      =  0,ivaintvig14    =  0,ivaintvenc14   =  0, int_venc_bal14=  0,
                                     capvig15       =  0,captrans15     =  0,capvencnoexig15=  0,capvenexig15   =  0, ivaint_venc_bal15=  0,
                                     intvig15       =  0,intvenc15      =  0,ivaintvig15    =  0,ivaintvenc15   =  0, int_venc_bal15=  0,
                                     capvig16       =  0,captrans16     =  0,capvencnoexig16=  0,capvenexig16   =  0, ivaint_venc_bal16=  0,
                                     intvig16       =  0,intvenc16      =  0,ivaintvig16    =  0,ivaintvenc16   =  0, int_venc_bal16=  0,
                                     capvig17       =  0,captrans17     =  0,capvencnoexig17=  0,capvenexig17   =  0, ivaint_venc_bal17=  0,
                                     intvig17       =  0,intvenc17      =  0,ivaintvig17    =  0,ivaintvenc17   =  0, int_venc_bal17=  0,
                                     capvig18       =  0,captrans18     =  0,capvencnoexig18=  0,capvenexig18   =  0, ivaint_venc_bal18=  0,
                                     intvig18       =  0,intvenc18      =  0,ivaintvig18    =  0,ivaintvenc18   =  0, int_venc_bal18=  0, 
                                     capvig19       =  0,captrans19     =  0,capvencnoexig19=  0,capvenexig19   =  0, ivaint_venc_bal19=  0,
                                     intvig19       =  0,intvenc19      =  0,ivaintvig19    =  0,ivaintvenc19   =  0, int_venc_bal19=  0,
                                     capvig20       =  0,captrans20     =  0,capvencnoexig20=  0,capvenexig20   =  0, ivaint_venc_bal20=  0,
                                     intvig20       =  0,intvenc20      =  0,ivaintvig20    =  0,ivaintvenc20   =  0, int_venc_bal20=  0,
                                     capvig21       =  0,captrans21     =  0,capvencnoexig21=  0,capvenexig21   =  0, ivaint_venc_bal21=  0,
                                     intvig21       =  0,intvenc21      =  0,ivaintvig21    =  0,ivaintvenc21   =  0, int_venc_bal21=  0,
                                     capvig22       =  0,captrans22     =  0,capvencnoexig22=  0,capvenexig22   =  0, ivaint_venc_bal22=  0,
                                     intvig22       =  0,intvenc22      =  0,ivaintvig22    =  0,ivaintvenc22   =  0, int_venc_bal22=  0,
                                     capvig23       =  0,captrans23     =  0,capvencnoexig23=  0,capvenexig23   =  0, ivaint_venc_bal23=  0,
                                     intvig23       =  0,intvenc23      =  0,ivaintvig23    =  0,ivaintvenc23   =  0, int_venc_bal23=  0,
                                     capvig24       =  0,captrans24     =  0,capvencnoexig24=  0,capvenexig24   =  0, ivaint_venc_bal24=  0,
                                     intvig24       =  0,intvenc24      =  0,ivaintvig24    =  0,ivaintvenc24   =  0, int_venc_bal24=  0,
                                     capvig25       =  0,captrans25     =  0,capvencnoexig25=  0,capvenexig25   =  0, ivaint_venc_bal25=  0,
                                     intvig25       =  0,intvenc25      =  0,ivaintvig25    =  0,ivaintvenc25   =  0, int_venc_bal25=  0,
                                     capvig26       =  0,captrans26     =  0,capvencnoexig26=  0,capvenexig26   =  0, ivaint_venc_bal26=  0,
                                     intvig26       =  0,intvenc26      =  0,ivaintvig26    =  0,ivaintvenc26   =  0, int_venc_bal26=  0,
                                     capvig27       =  0,captrans27     =  0,capvencnoexig27=  0,capvenexig27   =  0, ivaint_venc_bal27=  0,
                                     intvig27       =  0,intvenc27      =  0,ivaintvig27    =  0,ivaintvenc27   =  0, int_venc_bal27=  0,
                                     capvig28       =  0,captrans28     =  0,capvencnoexig28=  0,capvenexig28   =  0, ivaint_venc_bal28=  0,
                                     intvig28       =  0,intvenc28      =  0,ivaintvig28    =  0,ivaintvenc28   =  0, int_venc_bal28=  0,
                                     capvig29       =  0,captrans29     =  0,capvencnoexig29=  0,capvenexig29   =  0, ivaint_venc_bal29=  0,
                                     intvig29       =  0,intvenc29      =  0,ivaintvig29    =  0,ivaintvenc29   =  0, int_venc_bal29=  0,
                                     capvig30       =  0,captrans30     =  0,capvencnoexig30=  0,capvenexig30   =  0, ivaint_venc_bal30=  0,
                                     intvig30       =  0,intvenc30      =  0,ivaintvig30    =  0,ivaintvenc30   =  0, int_venc_bal30=  0,
                                     capvig31       =  0,captrans31     =  0,capvencnoexig31=  0,capvenexig31   =  0, ivaint_venc_bal31=  0,
                                     intvig31       =  0,intvenc31      =  0,ivaintvig31    =  0,ivaintvenc31   =  0, int_venc_bal31=  0,
                                     diacapvig      = 0,acucapvig      = 0,diacaptra      = 0,acucaptra      = 0,
                                     diacapvennoexig= 0,acucapvennoexig= 0,diacapvencexig = 0,acucapvencexig = 0,fecha=eFecha,
									 monto_financiado1 = 0, monto_financiado2 = 0, monto_financiado3 = 0,
									 monto_financiado4 = 0, monto_financiado5 = 0, monto_financiado6 = 0, monto_financiado7 = 0,
									 monto_financiado8 = 0, monto_financiado9 = 0, monto_financiado10 = 0, monto_financiado11 =0,
									 monto_financiado12 = 0, monto_financiado13 = 0, monto_financiado14 = 0, monto_financiado15 = 0,
									 monto_financiado16 = 0, monto_financiado17 = 0, monto_financiado18 = 0, monto_financiado19 = 0,
									 monto_financiado20 = 0, monto_financiado21 = 0, monto_financiado22 = 0, monto_financiado23 = 0,
									 monto_financiado24 = 0, monto_financiado25 = 0, monto_financiado26 = 0, monto_financiado27 = 0,
									 monto_financiado28 = 0, monto_financiado29 = 0, monto_financiado30 = 0, monto_financiado31 = 0,
									 --status_cred_1 = NVL(eEtapa,''), fecha_venc_1 = eFechaEtapa -- IFSR se agrega actualizaciÃÂ³n para cuando sea dÃÂ­a uno
									 --IFSR se actualiza para que en el primer registro que se tenga, se guarde la fecha vencimiento y el status en el primer dÃÂ­a del mes
									 --fecha_venc_1 = eFechaEtapa,fecha_venc_2 = null,fecha_venc_3 = null,fecha_venc_4 = null,fecha_venc_5 = null,fecha_venc_6 = null,
									 --fecha_venc_7 = null,fecha_venc_8 = null,fecha_venc_9 = null,fecha_venc_10 = null,fecha_venc_11 = null,fecha_venc_12 = null,
									 --fecha_venc_13 = null,fecha_venc_14 = null,fecha_venc_15 = null,fecha_venc_16 = null,fecha_venc_17 = null,fecha_venc_18 = null,
									 --fecha_venc_19 = null,fecha_venc_20 = null,fecha_venc_21 = null,fecha_venc_22 = null,fecha_venc_23 = null,fecha_venc_24 = null,
									 --fecha_venc_25 = null,fecha_venc_26 = null,fecha_venc_27 = null,fecha_venc_28 = null,fecha_venc_29 = null,fecha_venc_30 = null,fecha_venc_31 = null,
									 status_cred_1 = NVL(eEtapa,''),status_cred_2 = null,status_cred_3 = null,status_cred_4 = null,status_cred_5 = null,status_cred_6 = null,
									 status_cred_7 = null,status_cred_8 = null,status_cred_9 = null,status_cred_10 = null,status_cred_11 = null,status_cred_12 = null,
									 status_cred_13 = null,status_cred_14 = null,status_cred_15 = null,status_cred_16 = null,status_cred_17 = null,status_cred_18 = null,
									 status_cred_19 = null,status_cred_20 = null,status_cred_21 = null,status_cred_22 = null,status_cred_23 = null,status_cred_24 = null,
									 status_cred_25 = null,status_cred_26 = null,status_cred_27 = null,status_cred_28 = null,status_cred_29 = null,status_cred_30 = null,status_cred_31 = null,
									 atr1 = iAtr,atr2 = null,atr3 = null,atr4 = null,atr5 = null,atr6 = null,
									 atr7 = null,atr8 = null,atr9 = null,atr10 = null,atr11 = null,atr12 = null,
									 atr13 = null,atr14 = null,atr15 = null,atr16 = null,atr17 = null,atr18 = null,
									 atr19 = null,atr20 = null,atr21 = null,atr22 = null,atr23 = null,atr24 = null,
									 atr25 = null,atr26 = null,atr27 = null,atr28 = null,atr29 = null,atr30 = null,atr31 = null
             WHERE fecha=vFecha_mesant
               AND num_credito = eNumCredito;
    END IF;

	--KSOV RQI 25 265 SE COMENTAN ASIGNACIONES DE VARIABLES Y SE MUEVEN AL INICIO
	/*
    LET vFecha_primes=MDY(MONTH(eFecha),'01',YEAR(eFecha));
    let eDia=day(eFecha);
	*/
    --KSOV     
        
IF  exists (Select num_credito from sd_sdodiariocrd where fecha=vFecha_primes and num_credito = eNumCredito) 
    OR exists (Select num_credito from sd_sdodiariocrd where fecha=vFecha_primes and num_credito = eNumCredito)  And MONTH(eFecha) = 1  --KSOV RQI 25 265 SE AGREGA VALIDACION
			THEN
             UPDATE sd_sdodiariocrd SET capvig1     =  DECODE(eDia,1,eSdoCapital,capvig1),
                                     captrans1      =  DECODE(eDia,1,eMontoVencido,captrans1),
                                     capvencnoexig1 =  DECODE(eDia,1,eCapTrasNo,capvencnoexig1),
                                     capvenexig1    =  DECODE(eDia,1,eMtoVencTrasp,capvenexig1),
                                     intvig1        =  DECODE(eDia,1,eSdoIntereses,intvig1),
                                     intvenc1       =  DECODE(eDia,1,eSdoExigInt,intvenc1),
                                     ivaintvig1     =  DECODE(eDia,1,eIvaIntVig,ivaintvig1),
                                     ivaintvenc1    =  DECODE(eDia,1,eIvaIntVenc,ivaintvenc1),
                                     int_venc_bal1  =  DECODE(eDia,1,eIntVenBal,int_venc_bal1),
                                     ivaint_venc_bal1  =  DECODE(eDia,1,eIvaIntVenBal,ivaint_venc_bal1),
									 monto_financiado1  =  DECODE(eDia,1,eMontoFinanciado,monto_financiado1),

                                     capvig2        =  DECODE(eDia,2,eSdoCapital,capvig2),
                                     captrans2      =  DECODE(eDia,2,eMontoVencido,captrans2),
                                     capvencnoexig2 =  DECODE(eDia,2,eCapTrasNo,capvencnoexig2),
                                     capvenexig2    =  DECODE(eDia,2,eMtoVencTrasp,capvenexig2),
                                     intvig2        =  DECODE(eDia,2,eSdoIntereses,intvig2),
                                     intvenc2       =  DECODE(eDia,2,eSdoExigInt,intvenc2),
                                     ivaintvig2     =  DECODE(eDia,2,eIvaIntVig,ivaintvig2),
                                     ivaintvenc2    =  DECODE(eDia,2,eIvaIntVenc,ivaintvenc2), 
                                     int_venc_bal2  =  DECODE(eDia,2,eIntVenBal,int_venc_bal2),
                                     ivaint_venc_bal2  =  DECODE(eDia,2,eIvaIntVenBal,ivaint_venc_bal2),
									 monto_financiado2  =  DECODE(eDia,2,eMontoFinanciado,monto_financiado2),

                                     capvig3        =  DECODE(eDia,3,eSdoCapital,capvig3),
                                     captrans3      =  DECODE(eDia,3,eMontoVencido,captrans3),
                                     capvencnoexig3 =  DECODE(eDia,3,eCapTrasNo,capvencnoexig3),
                                     capvenexig3    =  DECODE(eDia,3,eMtoVencTrasp,capvenexig3),
                                     intvig3        =  DECODE(eDia,3,eSdoIntereses,intvig3),
                                     intvenc3       =  DECODE(eDia,3,eSdoExigInt,intvenc3),
                                     ivaintvig3     =  DECODE(eDia,3,eIvaIntVig,ivaintvig3),
                                     ivaintvenc3    =  DECODE(eDia,3,eIvaIntVenc,ivaintvenc3),
                                     int_venc_bal3  =  DECODE(eDia,3,eIntVenBal,int_venc_bal3),
                                     ivaint_venc_bal3  =  DECODE(eDia,3,eIvaIntVenBal,ivaint_venc_bal3),
									 monto_financiado3  =  DECODE(eDia,3,eMontoFinanciado,monto_financiado3),

                                     capvig4        =  DECODE(eDia,4,eSdoCapital,capvig4),
                                     captrans4      =  DECODE(eDia,4,eMontoVencido,captrans4),
                                     capvencnoexig4 =  DECODE(eDia,4,eCapTrasNo,capvencnoexig4),
                                     capvenexig4    =  DECODE(eDia,4,eMtoVencTrasp,capvenexig4),
                                     intvig4        =  DECODE(eDia,4,eSdoIntereses,intvig4),
                                     intvenc4       =  DECODE(eDia,4,eSdoExigInt,intvenc4),
                                     ivaintvig4     =  DECODE(eDia,4,eIvaIntVig,ivaintvig4),
                                     ivaintvenc4    =  DECODE(eDia,4,eIvaIntVenc,ivaintvenc4),
                                     int_venc_bal4  =  DECODE(eDia,4,eIntVenBal,int_venc_bal4),
                                     ivaint_venc_bal4  =  DECODE(eDia,4,eIvaIntVenBal,ivaint_venc_bal4),
									 monto_financiado4  =  DECODE(eDia,4,eMontoFinanciado,monto_financiado4),

                                     capvig5        =  DECODE(eDia,5,eSdoCapital,capvig5),
                                     captrans5      =  DECODE(eDia,5,eMontoVencido,captrans5),
                                     capvencnoexig5 =  DECODE(eDia,5,eCapTrasNo,capvencnoexig5),
                                     capvenexig5    =  DECODE(eDia,5,eMtoVencTrasp,capvenexig5),
                                     intvig5        =  DECODE(eDia,5,eSdoIntereses,intvig5),
                                     intvenc5       =  DECODE(eDia,5,eSdoExigInt,intvenc5),
                                     ivaintvig5     =  DECODE(eDia,5,eIvaIntVig,ivaintvig5),
                                     ivaintvenc5    =  DECODE(eDia,5,eIvaIntVenc,ivaintvenc5),
                                     int_venc_bal5  =  DECODE(eDia,5,eIntVenBal,int_venc_bal5),
                                     ivaint_venc_bal5  =  DECODE(eDia,5,eIvaIntVenBal,ivaint_venc_bal5),
									 monto_financiado5  =  DECODE(eDia,5,eMontoFinanciado,monto_financiado5),

                                     capvig6        =  DECODE(eDia,6,eSdoCapital,capvig6),
                                     captrans6      =  DECODE(eDia,6,eMontoVencido,captrans6),
                                     capvencnoexig6 =  DECODE(eDia,6,eCapTrasNo,capvencnoexig6),
                                     capvenexig6    =  DECODE(eDia,6,eMtoVencTrasp,capvenexig6),
                                     intvig6        =  DECODE(eDia,6,eSdoIntereses,intvig6),
                                     intvenc6       =  DECODE(eDia,6,eSdoExigInt,intvenc6),
                                     ivaintvig6     =  DECODE(eDia,6,eIvaIntVig,ivaintvig6),
                                     ivaintvenc6    =  DECODE(eDia,6,eIvaIntVenc,ivaintvenc6),
                                     int_venc_bal6  =  DECODE(eDia,6,eIntVenBal,int_venc_bal6),
                                     ivaint_venc_bal6  =  DECODE(eDia,6,eIvaIntVenBal,ivaint_venc_bal6),
									 monto_financiado6  =  DECODE(eDia,6,eMontoFinanciado,monto_financiado6),

                                     capvig7        =  DECODE(eDia,7,eSdoCapital,capvig7),
                                     captrans7      =  DECODE(eDia,7,eMontoVencido,captrans7),
                                     capvencnoexig7 =  DECODE(eDia,7,eCapTrasNo,capvencnoexig7),
                                     capvenexig7    =  DECODE(eDia,7,eMtoVencTrasp,capvenexig7),
                                     intvig7        =  DECODE(eDia,7,eSdoIntereses,intvig7),
                                     intvenc7       =  DECODE(eDia,7,eSdoExigInt,intvenc7),
                                     ivaintvig7     =  DECODE(eDia,7,eIvaIntVig,ivaintvig7),
                                     ivaintvenc7    =  DECODE(eDia,7,eIvaIntVenc,ivaintvenc7),
                                     int_venc_bal7  =  DECODE(eDia,7,eIntVenBal,int_venc_bal7),
                                     ivaint_venc_bal7  =  DECODE(eDia,7,eIvaIntVenBal,ivaint_venc_bal7),
									 monto_financiado7  =  DECODE(eDia,7,eMontoFinanciado,monto_financiado7),

                                     capvig8        =  DECODE(eDia,8,eSdoCapital,capvig8),
                                     captrans8      =  DECODE(eDia,8,eMontoVencido,captrans8),
                                     capvencnoexig8 =  DECODE(eDia,8,eCapTrasNo,capvencnoexig8),
                                     capvenexig8    =  DECODE(eDia,8,eMtoVencTrasp,capvenexig8),
                                     intvig8        =  DECODE(eDia,8,eSdoIntereses,intvig8),
                                     intvenc8       =  DECODE(eDia,8,eSdoExigInt,intvenc8),
                                     ivaintvig8     =  DECODE(eDia,8,eIvaIntVig,ivaintvig8),
                                     ivaintvenc8    =  DECODE(eDia,8,eIvaIntVenc,ivaintvenc8),
                                     int_venc_bal8  =  DECODE(eDia,8,eIntVenBal,int_venc_bal8),
                                     ivaint_venc_bal8  =  DECODE(eDia,8,eIvaIntVenBal,ivaint_venc_bal8),
									 monto_financiado8  =  DECODE(eDia,8,eMontoFinanciado,monto_financiado8),

                                     capvig9        =  DECODE(eDia,9,eSdoCapital,capvig9),
                                     captrans9      =  DECODE(eDia,9,eMontoVencido,captrans9),
                                     capvencnoexig9 =  DECODE(eDia,9,eCapTrasNo,capvencnoexig9),
                                     capvenexig9    =  DECODE(eDia,9,eMtoVencTrasp,capvenexig9),
                                     intvig9        =  DECODE(eDia,9,eSdoIntereses,intvig9),
                                     intvenc9       =  DECODE(eDia,9,eSdoExigInt,intvenc9),
                                     ivaintvig9     =  DECODE(eDia,9,eIvaIntVig,ivaintvig9),
                                     ivaintvenc9    =  DECODE(eDia,9,eIvaIntVenc,ivaintvenc9),
                                     int_venc_bal9  =  DECODE(eDia,9,eIntVenBal,int_venc_bal9),
                                     ivaint_venc_bal9  =  DECODE(eDia,9,eIvaIntVenBal,ivaint_venc_bal9),
									 monto_financiado9  =  DECODE(eDia,9,eMontoFinanciado,monto_financiado9),

                                     capvig10       =  DECODE(eDia,10,eSdoCapital,capvig10),
                                     captrans10     =  DECODE(eDia,10,eMontoVencido,captrans10),
                                     capvencnoexig10=  DECODE(eDia,10,eCapTrasNo,capvencnoexig10),
                                     capvenexig10   =  DECODE(eDia,10,eMtoVencTrasp,capvenexig10),
                                     intvig10       =  DECODE(eDia,10,eSdoIntereses,intvig10),
                                     intvenc10      =  DECODE(eDia,10,eSdoExigInt,intvenc10),
                                     ivaintvig10    =  DECODE(eDia,10,eIvaIntVig,ivaintvig10),
                                     ivaintvenc10   =  DECODE(eDia,10,eIvaIntVenc,ivaintvenc10),
                                     int_venc_bal10 =  DECODE(eDia,10,eIntVenBal,int_venc_bal10),
                                     ivaint_venc_bal10 =  DECODE(eDia,10,eIvaIntVenBal,ivaint_venc_bal10),
									 monto_financiado10  =  DECODE(eDia,10,eMontoFinanciado,monto_financiado10),

                                     capvig11       =  DECODE(eDia,11,eSdoCapital,capvig11),
                                     captrans11     =  DECODE(eDia,11,eMontoVencido,captrans11),
                                     capvencnoexig11=  DECODE(eDia,11,eCapTrasNo,capvencnoexig11),
                                     capvenexig11   =  DECODE(eDia,11,eMtoVencTrasp,capvenexig11),
                                     intvig11       =  DECODE(eDia,11,eSdoIntereses,intvig11),
                                     intvenc11      =  DECODE(eDia,11,eSdoExigInt,intvenc11),
                                     ivaintvig11    =  DECODE(eDia,11,eIvaIntVig,ivaintvig11),
                                     ivaintvenc11   =  DECODE(eDia,11,eIvaIntVenc,ivaintvenc11),
                                     int_venc_bal11 =  DECODE(eDia,11,eIntVenBal,int_venc_bal11),
                                     ivaint_venc_bal11  =  DECODE(eDia,11,eIvaIntVenBal,ivaint_venc_bal11),
									 monto_financiado11  =  DECODE(eDia,11,eMontoFinanciado,monto_financiado11),

                                     capvig12       =  DECODE(eDia,12,eSdoCapital,capvig12),
                                     captrans12     =  DECODE(eDia,12,eMontoVencido,captrans12),
                                     capvencnoexig12=  DECODE(eDia,12,eCapTrasNo,capvencnoexig12),
                                     capvenexig12   =  DECODE(eDia,12,eMtoVencTrasp,capvenexig12),
                                     intvig12       =  DECODE(eDia,12,eSdoIntereses,intvig12),
                                     intvenc12      =  DECODE(eDia,12,eSdoExigInt,intvenc12),
                                     ivaintvig12    =  DECODE(eDia,12,eIvaIntVig,ivaintvig12),
                                     ivaintvenc12   =  DECODE(eDia,12,eIvaIntVenc,ivaintvenc12),
                                     int_venc_bal12 =  DECODE(eDia,12,eIntVenBal,int_venc_bal12),
                                     ivaint_venc_bal12  =  DECODE(eDia,12,eIvaIntVenBal,ivaint_venc_bal12),
									 monto_financiado12  =  DECODE(eDia,12,eMontoFinanciado,monto_financiado12),

                                     capvig13       =  DECODE(eDia,13,eSdoCapital,capvig13),
                                     captrans13     =  DECODE(eDia,13,eMontoVencido,captrans13),
                                     capvencnoexig13=  DECODE(eDia,13,eCapTrasNo,capvencnoexig13),
                                     capvenexig13   =  DECODE(eDia,13,eMtoVencTrasp,capvenexig13),
                                     intvig13       =  DECODE(eDia,13,eSdoIntereses,intvig13),
                                     intvenc13      =  DECODE(eDia,13,eSdoExigInt,intvenc13),
                                     ivaintvig13    =  DECODE(eDia,13,eIvaIntVig,ivaintvig13),
                                     ivaintvenc13   =  DECODE(eDia,13,eIvaIntVenc,ivaintvenc13),
                                     int_venc_bal13 =  DECODE(eDia,13,eIntVenBal,int_venc_bal13),
                                     ivaint_venc_bal13  =  DECODE(eDia,13,eIvaIntVenBal,ivaint_venc_bal13),
									 monto_financiado13  =  DECODE(eDia,13,eMontoFinanciado,monto_financiado13),

                                     capvig14       =  DECODE(eDia,14,eSdoCapital,capvig14),
                                     captrans14     =  DECODE(eDia,14,eMontoVencido,captrans14),
                                     capvencnoexig14=  DECODE(eDia,14,eCapTrasNo,capvencnoexig14),
                                     capvenexig14   =  DECODE(eDia,14,eMtoVencTrasp,capvenexig14),
                                     intvig14       =  DECODE(eDia,14,eSdoIntereses,intvig14),
                                     intvenc14      =  DECODE(eDia,14,eSdoExigInt,intvenc14),
                                     ivaintvig14    =  DECODE(eDia,14,eIvaIntVig,ivaintvig14),
                                     ivaintvenc14   =  DECODE(eDia,14,eIvaIntVenc,ivaintvenc14),
                                     int_venc_bal14 =  DECODE(eDia,14,eIntVenBal,int_venc_bal14),
                                     ivaint_venc_bal14  =  DECODE(eDia,14,eIvaIntVenBal,ivaint_venc_bal14),
									 monto_financiado14  =  DECODE(eDia,14,eMontoFinanciado,monto_financiado14),

                                     capvig15       =  DECODE(eDia,15,eSdoCapital,capvig15),
                                     captrans15     =  DECODE(eDia,15,eMontoVencido,captrans15),
                                     capvencnoexig15=  DECODE(eDia,15,eCapTrasNo,capvencnoexig15),
                                     capvenexig15   =  DECODE(eDia,15,eMtoVencTrasp,capvenexig15),
                                     intvig15       =  DECODE(eDia,15,eSdoIntereses,intvig15),
                                     intvenc15      =  DECODE(eDia,15,eSdoExigInt,intvenc15),
                                     ivaintvig15    =  DECODE(eDia,15,eIvaIntVig,ivaintvig15),
                                     ivaintvenc15   =  DECODE(eDia,15,eIvaIntVenc,ivaintvenc15),
                                     int_venc_bal15 =  DECODE(eDia,15,eIntVenBal,int_venc_bal15),
                                     ivaint_venc_bal15  =  DECODE(eDia,15,eIvaIntVenBal,ivaint_venc_bal15),
									 monto_financiado15  =  DECODE(eDia,15,eMontoFinanciado,monto_financiado15),

                                     capvig16       =  DECODE(eDia,16,eSdoCapital,capvig16),
                                     captrans16     =  DECODE(eDia,16,eMontoVencido,captrans16),
                                     capvencnoexig16=  DECODE(eDia,16,eCapTrasNo,capvencnoexig16),
                                     capvenexig16   =  DECODE(eDia,16,eMtoVencTrasp,capvenexig16),
                                     intvig16       =  DECODE(eDia,16,eSdoIntereses,intvig16),
                                     intvenc16      =  DECODE(eDia,16,eSdoExigInt,intvenc16),
                                     ivaintvig16    =  DECODE(eDia,16,eIvaIntVig,ivaintvig16),
                                     ivaintvenc16   =  DECODE(eDia,16,eIvaIntVenc,ivaintvenc16),
                                     int_venc_bal16 =  DECODE(eDia,16,eIntVenBal,int_venc_bal16),
                                     ivaint_venc_bal16  =  DECODE(eDia,16,eIvaIntVenBal,ivaint_venc_bal16),
									 monto_financiado16  =  DECODE(eDia,16,eMontoFinanciado,monto_financiado16),

                                     capvig17       =  DECODE(eDia,17,eSdoCapital,capvig17),
                                     captrans17     =  DECODE(eDia,17,eMontoVencido,captrans17),
                                     capvencnoexig17=  DECODE(eDia,17,eCapTrasNo,capvencnoexig17),
                                     capvenexig17   =  DECODE(eDia,17,eMtoVencTrasp,capvenexig17),
                                     intvig17       =  DECODE(eDia,17,eSdoIntereses,intvig17),
                                     intvenc17      =  DECODE(eDia,17,eSdoExigInt,intvenc17),
                                     ivaintvig17    =  DECODE(eDia,17,eIvaIntVig,ivaintvig17),
                                     ivaintvenc17   =  DECODE(eDia,17,eIvaIntVenc,ivaintvenc17),
                                     int_venc_bal17 =  DECODE(eDia,17,eIntVenBal,int_venc_bal17),
                                     ivaint_venc_bal17  =  DECODE(eDia,17,eIvaIntVenBal,ivaint_venc_bal17),
									 monto_financiado17  =  DECODE(eDia,17,eMontoFinanciado,monto_financiado17),

                                     capvig18       =  DECODE(eDia,18,eSdoCapital,capvig18),
                                     captrans18     =  DECODE(eDia,18,eMontoVencido,captrans18),
                                     capvencnoexig18=  DECODE(eDia,18,eCapTrasNo,capvencnoexig18),
                                     capvenexig18   =  DECODE(eDia,18,eMtoVencTrasp,capvenexig18),
                                     intvig18       =  DECODE(eDia,18,eSdoIntereses,intvig18),
                                     intvenc18      =  DECODE(eDia,18,eSdoExigInt,intvenc18),
                                     ivaintvig18    =  DECODE(eDia,18,eIvaIntVig,ivaintvig18),
                                     ivaintvenc18   =  DECODE(eDia,18,eIvaIntVenc,ivaintvenc18),
                                     int_venc_bal18 =  DECODE(eDia,18,eIntVenBal,int_venc_bal18),
                                     ivaint_venc_bal18  =  DECODE(eDia,18,eIvaIntVenBal,ivaint_venc_bal18),
									 monto_financiado18  =  DECODE(eDia,18,eMontoFinanciado,monto_financiado18),

                                     capvig19       =  DECODE(eDia,19,eSdoCapital,capvig19),
                                     captrans19     =  DECODE(eDia,19,eMontoVencido,captrans19),
                                     capvencnoexig19=  DECODE(eDia,19,eCapTrasNo,capvencnoexig19),
                                     capvenexig19   =  DECODE(eDia,19,eMtoVencTrasp,capvenexig19),
                                     intvig19       =  DECODE(eDia,19,eSdoIntereses,intvig19),
                                     intvenc19      =  DECODE(eDia,19,eSdoExigInt,intvenc19),
                                     ivaintvig19    =  DECODE(eDia,19,eIvaIntVig,ivaintvig19),
                                     ivaintvenc19   =  DECODE(eDia,19,eIvaIntVenc,ivaintvenc19),
                                     int_venc_bal19 =  DECODE(eDia,19,eIntVenBal,int_venc_bal19),
                                     ivaint_venc_bal19  =  DECODE(eDia,19,eIvaIntVenBal,ivaint_venc_bal19),
									 monto_financiado19  =  DECODE(eDia,19,eMontoFinanciado,monto_financiado19),
									
                                     capvig20       =  DECODE(eDia,20,eSdoCapital,capvig20),
                                     captrans20     =  DECODE(eDia,20,eMontoVencido,captrans20),
                                     capvencnoexig20=  DECODE(eDia,20,eCapTrasNo,capvencnoexig20),
                                     capvenexig20   =  DECODE(eDia,20,eMtoVencTrasp,capvenexig20),
                                     intvig20       =  DECODE(eDia,20,eSdoIntereses,intvig20),
                                     intvenc20      =  DECODE(eDia,20,eSdoExigInt,intvenc20),
                                     ivaintvig20    =  DECODE(eDia,20,eIvaIntVig,ivaintvig20),
                                     ivaintvenc20   =  DECODE(eDia,20,eIvaIntVenc,ivaintvenc20),
                                     int_venc_bal20 =  DECODE(eDia,20,eIntVenBal,int_venc_bal20),
                                     ivaint_venc_bal20  =  DECODE(eDia,20,eIvaIntVenBal,ivaint_venc_bal20),
									 monto_financiado20  =  DECODE(eDia,20,eMontoFinanciado,monto_financiado20),

                                     capvig21       =  DECODE(eDia,21,eSdoCapital,capvig21),
                                     captrans21     =  DECODE(eDia,21,eMontoVencido,captrans21),
                                     capvencnoexig21=  DECODE(eDia,21,eCapTrasNo,capvencnoexig21),
                                     capvenexig21   =  DECODE(eDia,21,eMtoVencTrasp,capvenexig21),
                                     intvig21       =  DECODE(eDia,21,eSdoIntereses,intvig21),
                                     intvenc21      =  DECODE(eDia,21,eSdoExigInt,intvenc21),
                                     ivaintvig21    =  DECODE(eDia,21,eIvaIntVig,ivaintvig21),
                                     ivaintvenc21   =  DECODE(eDia,21,eIvaIntVenc,ivaintvenc21),
                                     int_venc_bal21 =  DECODE(eDia,21,eIntVenBal,int_venc_bal21),
                                     ivaint_venc_bal21  =  DECODE(eDia,21,eIvaIntVenBal,ivaint_venc_bal21),
									 monto_financiado21  =  DECODE(eDia,21,eMontoFinanciado,monto_financiado21),

                                     capvig22       =  DECODE(eDia,22,eSdoCapital,capvig22),
                                     captrans22     =  DECODE(eDia,22,eMontoVencido,captrans22),
                                     capvencnoexig22=  DECODE(eDia,22,eCapTrasNo,capvencnoexig22),
                                     capvenexig22   =  DECODE(eDia,22,eMtoVencTrasp,capvenexig22),
                                     intvig22       =  DECODE(eDia,22,eSdoIntereses,intvig22),
                                     intvenc22      =  DECODE(eDia,22,eSdoExigInt,intvenc22),
                                     ivaintvig22    =  DECODE(eDia,22,eIvaIntVig,ivaintvig22),
                                     ivaintvenc22   =  DECODE(eDia,22,eIvaIntVenc,ivaintvenc22),
                                     int_venc_bal22 =  DECODE(eDia,22,eIntVenBal,int_venc_bal22),
                                     ivaint_venc_bal22  =  DECODE(eDia,22,eIvaIntVenBal,ivaint_venc_bal22),
									 monto_financiado22  =  DECODE(eDia,22,eMontoFinanciado,monto_financiado22),

                                     capvig23       =  DECODE(eDia,23,eSdoCapital,capvig23),
                                     captrans23     =  DECODE(eDia,23,eMontoVencido,captrans23),
                                     capvencnoexig23=  DECODE(eDia,23,eCapTrasNo,capvencnoexig23),
                                     capvenexig23   =  DECODE(eDia,23,eMtoVencTrasp,capvenexig23),
                                     intvig23       =  DECODE(eDia,23,eSdoIntereses,intvig23),
                                     intvenc23      =  DECODE(eDia,23,eSdoExigInt,intvenc23),
                                     ivaintvig23    =  DECODE(eDia,23,eIvaIntVig,ivaintvig23),
                                     ivaintvenc23   =  DECODE(eDia,23,eIvaIntVenc,ivaintvenc23),
                                     int_venc_bal23 =  DECODE(eDia,23,eIntVenBal,int_venc_bal23),
                                     ivaint_venc_bal23  =  DECODE(eDia,23,eIvaIntVenBal,ivaint_venc_bal23),
									 monto_financiado23  =  DECODE(eDia,23,eMontoFinanciado,monto_financiado23),

                                     capvig24       =  DECODE(eDia,24,eSdoCapital,capvig24),
                                     captrans24     =  DECODE(eDia,24,eMontoVencido,captrans24),
                                     capvencnoexig24=  DECODE(eDia,24,eCapTrasNo,capvencnoexig24),
                                     capvenexig24   =  DECODE(eDia,24,eMtoVencTrasp,capvenexig24),
                                     intvig24       =  DECODE(eDia,24,eSdoIntereses,intvig24),
                                     intvenc24      =  DECODE(eDia,24,eSdoExigInt,intvenc24),
                                     ivaintvig24    =  DECODE(eDia,24,eIvaIntVig,ivaintvig24),
                                     ivaintvenc24   =  DECODE(eDia,24,eIvaIntVenc,ivaintvenc24),
                                     int_venc_bal24 =  DECODE(eDia,24,eIntVenBal,int_venc_bal24),
                                     ivaint_venc_bal24  =  DECODE(eDia,24,eIvaIntVenBal,ivaint_venc_bal24),
									 monto_financiado24  =  DECODE(eDia,24,eMontoFinanciado,monto_financiado24),

                                     capvig25       =  DECODE(eDia,25,eSdoCapital,capvig25),
                                     captrans25     =  DECODE(eDia,25,eMontoVencido,captrans25),
                                     capvencnoexig25=  DECODE(eDia,25,eCapTrasNo,capvencnoexig25),
                                     capvenexig25   =  DECODE(eDia,25,eMtoVencTrasp,capvenexig25),
                                     intvig25       =  DECODE(eDia,25,eSdoIntereses,intvig25),
                                     intvenc25      =  DECODE(eDia,25,eSdoExigInt,intvenc25),
                                     ivaintvig25    =  DECODE(eDia,25,eIvaIntVig,ivaintvig25),
                                     ivaintvenc25   =  DECODE(eDia,25,eIvaIntVenc,ivaintvenc25),
                                     int_venc_bal25 =  DECODE(eDia,25,eIntVenBal,int_venc_bal25),
                                     ivaint_venc_bal25  =  DECODE(eDia,25,eIvaIntVenBal,ivaint_venc_bal25),
									 monto_financiado25  =  DECODE(eDia,25,eMontoFinanciado,monto_financiado25),

                                     capvig26       =  DECODE(eDia,26,eSdoCapital,capvig26),
                                     captrans26     =  DECODE(eDia,26,eMontoVencido,captrans26),
                                     capvencnoexig26=  DECODE(eDia,26,eCapTrasNo,capvencnoexig26),
                                     capvenexig26   =  DECODE(eDia,26,eMtoVencTrasp,capvenexig26),
                                     intvig26       =  DECODE(eDia,26,eSdoIntereses,intvig26),
                                     intvenc26      =  DECODE(eDia,26,eSdoExigInt,intvenc26),
                                     ivaintvig26    =  DECODE(eDia,26,eIvaIntVig,ivaintvig26),
                                     ivaintvenc26   =  DECODE(eDia,26,eIvaIntVenc,ivaintvenc26),
                                     int_venc_bal26 =  DECODE(eDia,26,eIntVenBal,int_venc_bal26),
                                     ivaint_venc_bal26  =  DECODE(eDia,26,eIvaIntVenBal,ivaint_venc_bal26),
									 monto_financiado26  =  DECODE(eDia,26,eMontoFinanciado,monto_financiado26),

                                     capvig27       =  DECODE(eDia,27,eSdoCapital,capvig27),
                                     captrans27     =  DECODE(eDia,27,eMontoVencido,captrans27),
                                     capvencnoexig27=  DECODE(eDia,27,eCapTrasNo,capvencnoexig27),
                                     capvenexig27   =  DECODE(eDia,27,eMtoVencTrasp,capvenexig27),
                                     intvig27       =  DECODE(eDia,27,eSdoIntereses,intvig27),
                                     intvenc27      =  DECODE(eDia,27,eSdoExigInt,intvenc27),
                                     ivaintvig27    =  DECODE(eDia,27,eIvaIntVig,ivaintvig27),
                                     ivaintvenc27   =  DECODE(eDia,27,eIvaIntVenc,ivaintvenc27),
                                     int_venc_bal27 =  DECODE(eDia,27,eIntVenBal,int_venc_bal27),
                                     ivaint_venc_bal27  =  DECODE(eDia,27,eIvaIntVenBal,ivaint_venc_bal27),
									 monto_financiado27  =  DECODE(eDia,27,eMontoFinanciado,monto_financiado27),

                                     capvig28       =  DECODE(eDia,28,eSdoCapital,capvig28),
                                     captrans28     =  DECODE(eDia,28,eMontoVencido,captrans28),
                                     capvencnoexig28=  DECODE(eDia,28,eCapTrasNo,capvencnoexig28),
                                     capvenexig28   =  DECODE(eDia,28,eMtoVencTrasp,capvenexig28),
                                     intvig28       =  DECODE(eDia,28,eSdoIntereses,intvig28),
                                     intvenc28      =  DECODE(eDia,28,eSdoExigInt,intvenc28),
                                     ivaintvig28    =  DECODE(eDia,28,eIvaIntVig,ivaintvig28),
                                     ivaintvenc28   =  DECODE(eDia,28,eIvaIntVenc,ivaintvenc28),
                                     int_venc_bal28 =  DECODE(eDia,28,eIntVenBal,int_venc_bal28),
                                     ivaint_venc_bal28  =  DECODE(eDia,28,eIvaIntVenBal,ivaint_venc_bal28),
									 monto_financiado28  =  DECODE(eDia,28,eMontoFinanciado,monto_financiado28),

                                     capvig29       =  DECODE(eDia,29,eSdoCapital,capvig29),
                                     captrans29     =  DECODE(eDia,29,eMontoVencido,captrans29),
                                     capvencnoexig29=  DECODE(eDia,29,eCapTrasNo,capvencnoexig29),
                                     capvenexig29   =  DECODE(eDia,29,eMtoVencTrasp,capvenexig29),
                                     intvig29       =  DECODE(eDia,29,eSdoIntereses,intvig29),
                                     intvenc29      =  DECODE(eDia,29,eSdoExigInt,intvenc29),
                                     ivaintvig29    =  DECODE(eDia,29,eIvaIntVig,ivaintvig29),
                                     ivaintvenc29   =  DECODE(eDia,29,eIvaIntVenc,ivaintvenc29),
                                     int_venc_bal29 =  DECODE(eDia,29,eIntVenBal,int_venc_bal29),
                                     ivaint_venc_bal29  =  DECODE(eDia,29,eIvaIntVenBal,ivaint_venc_bal29),
									 monto_financiado29  =  DECODE(eDia,29,eMontoFinanciado,monto_financiado29),	

                                     capvig30       =  DECODE(eDia,30,eSdoCapital,capvig30),
                                     captrans30     =  DECODE(eDia,30,eMontoVencido,captrans30),
                                     capvencnoexig30=  DECODE(eDia,30,eCapTrasNo,capvencnoexig30),
                                     capvenexig30   =  DECODE(eDia,30,eMtoVencTrasp,capvenexig30),
                                     intvig30       =  DECODE(eDia,30,eSdoIntereses,intvig30),
                                     intvenc30      =  DECODE(eDia,30,eSdoExigInt,intvenc30),
                                     ivaintvig30    =  DECODE(eDia,30,eIvaIntVig,ivaintvig30),
                                     ivaintvenc30   =  DECODE(eDia,30,eIvaIntVenc,ivaintvenc30),
                                     int_venc_bal30 =  DECODE(eDia,30,eIntVenBal,int_venc_bal30),
                                     ivaint_venc_bal30  =  DECODE(eDia,30,eIvaIntVenBal,ivaint_venc_bal30),
									 monto_financiado30  =  DECODE(eDia,30,eMontoFinanciado,monto_financiado30),

                                     capvig31       =  DECODE(eDia,31,eSdoCapital,capvig31),
                                     captrans31     =  DECODE(eDia,31,eMontoVencido,captrans31),
                                     capvencnoexig31=  DECODE(eDia,31,eCapTrasNo,capvencnoexig31),
                                     capvenexig31   =  DECODE(eDia,31,eMtoVencTrasp,capvenexig31),
                                     intvig31       =  DECODE(eDia,31,eSdoIntereses,intvig31),
                                     intvenc31      =  DECODE(eDia,31,eSdoExigInt,intvenc31),
                                     ivaintvig31    =  DECODE(eDia,31,eIvaIntVig,ivaintvig31),
                                     ivaintvenc31   =  DECODE(eDia,31,eIvaIntVenc,ivaintvenc31),
                                     int_venc_bal31 =  DECODE(eDia,31,eIntVenBal,int_venc_bal31),
                                     ivaint_venc_bal31  =  DECODE(eDia,31,eIvaIntVenBal,ivaint_venc_bal31),
									 monto_financiado31  =  DECODE(eDia,31,eMontoFinanciado,monto_financiado31),

                                     diacapvig      = diacapvig + vDiaCapital,
                                     acucapvig      = acucapvig + eSdoCapital,
                                     diacaptra      = diacaptra + vDiaVencido,
                                     acucaptra      = acucaptra + eMontoVencido,
                                     diacapvennoexig= diacapvennoexig + vDiaNoExig,
                                     acucapvennoexig= acucapvennoexig + eCapTrasNo,
                                     diacapvencexig = diacapvencexig + vDiaExig,
                                     acucapvencexig = acucapvencexig + eMtoVencTrasp

             WHERE fecha=vFecha_primes
               AND num_credito = eNumCredito;
			   
			   -- IFSR se agrega validaciÃÂ³n para actualizar la etapa dependiendo el dÃÂ­a
		if  (eDia = 1) then
			UPDATE sd_sdodiariocrd SET
				status_cred_1 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_1 = eFechaEtapa,
				atr1 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 2) then
			UPDATE sd_sdodiariocrd SET
				status_cred_2 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_2 = eFechaEtapa,
				atr2 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 3) then
			UPDATE sd_sdodiariocrd SET
				status_cred_3 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_3 = eFechaEtapa,
				atr3 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 4) then
			UPDATE sd_sdodiariocrd SET
				status_cred_4 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_4 = eFechaEtapa,
				atr4 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 5) then
			UPDATE sd_sdodiariocrd SET
				status_cred_5 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_5 = eFechaEtapa,
				atr5 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 6) then
			UPDATE sd_sdodiariocrd SET
				status_cred_6 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_6 = eFechaEtapa,
				atr6 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 7) then
			UPDATE sd_sdodiariocrd SET
				status_cred_7 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_7 = eFechaEtapa,
				atr7 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 8) then
			UPDATE sd_sdodiariocrd SET
				status_cred_8 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_8 = eFechaEtapa,
				atr8 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 9) then
			UPDATE sd_sdodiariocrd SET
				status_cred_9 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_9 = eFechaEtapa,
				atr9 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 10) then
			UPDATE sd_sdodiariocrd SET
				status_cred_10 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_10 = eFechaEtapa,
				atr10 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 11) then
			UPDATE sd_sdodiariocrd SET
				status_cred_11 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_11 = eFechaEtapa,
				atr11 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 12) then
			UPDATE sd_sdodiariocrd SET
				status_cred_12 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_12 = eFechaEtapa,
				atr12 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 13) then
			UPDATE sd_sdodiariocrd SET
				status_cred_13 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_13 = eFechaEtapa,
				atr13 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 14) then
			UPDATE sd_sdodiariocrd SET
				status_cred_14 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_14 = eFechaEtapa,
				atr14 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 15) then
			UPDATE sd_sdodiariocrd SET
				status_cred_15 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_15 = eFechaEtapa,
				atr15 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 16) then
			UPDATE sd_sdodiariocrd SET
				status_cred_16 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_16 = eFechaEtapa,
				atr16 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 17) then
			UPDATE sd_sdodiariocrd SET
				status_cred_17 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_17 = eFechaEtapa,
				atr17 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 18) then
			UPDATE sd_sdodiariocrd SET
				status_cred_18 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_18 = eFechaEtapa,
				atr18 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 19) then
			UPDATE sd_sdodiariocrd SET
				status_cred_19 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_19 = eFechaEtapa,
				atr19 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 20) then
			UPDATE sd_sdodiariocrd SET
				status_cred_20 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_20 = eFechaEtapa,
				atr20 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 21) then
			UPDATE sd_sdodiariocrd SET
				status_cred_21 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_21 = eFechaEtapa,
				atr21 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 22) then
			UPDATE sd_sdodiariocrd SET
				status_cred_22 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_22 = eFechaEtapa,
				atr22 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 23) then
			UPDATE sd_sdodiariocrd SET
				status_cred_23 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_23 = eFechaEtapa,
				atr23 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 24) then
			UPDATE sd_sdodiariocrd SET
				status_cred_24 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_24 = eFechaEtapa,
				atr24 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 25) then
			UPDATE sd_sdodiariocrd SET
				status_cred_25 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_25 = eFechaEtapa,
				atr25 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 26) then
			UPDATE sd_sdodiariocrd SET
				status_cred_26 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_26 = eFechaEtapa,
				atr26 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 27) then
			UPDATE sd_sdodiariocrd SET
				status_cred_27 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_27 = eFechaEtapa,
				atr27 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 28) then
			UPDATE sd_sdodiariocrd SET
				status_cred_28 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_28 = eFechaEtapa,
				atr28 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 29) then
			UPDATE sd_sdodiariocrd SET
				status_cred_29 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_29 = eFechaEtapa,
				atr29 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 30) then
			UPDATE sd_sdodiariocrd SET
				status_cred_30 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_30 = eFechaEtapa,
				atr30 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
			
		elif (eDia = 31) then
			UPDATE sd_sdodiariocrd SET
				status_cred_31 = NVL(eEtapa,''), -- IFSR se agrega actualizacion de etapa dependiendo del dÃÂ­a en que se encuentre la fecha
				--fecha_venc_31 = eFechaEtapa,
				atr31 = iAtr
			WHERE fecha=vFecha_primes
            AND num_credito = eNumCredito;
		
		end if;
      ELSE
	  
	    
             INSERT INTO sd_sdodiariocrd
             VALUES(vFecha_primes,eNumCredito, eSucursal,
                                 DECODE(eDia,1,eSdoCapital,0),
                                 DECODE(eDia,1,eMontoVencido,0),
                                 DECODE(eDia,1,eCapTrasNo,0),
                                 DECODE(eDia,1,eMtoVencTrasp,0),
                                 DECODE(eDia,1,eSdoIntereses,0),
                                 DECODE(eDia,1,eSdoExigInt,0),
                                 DECODE(eDia,1,eIvaIntVig,0),
                                 DECODE(eDia,1,eIvaIntVenc,0),
                                

                                 DECODE(eDia,2,eSdoCapital,0),
                                 DECODE(eDia,2,eMontoVencido,0),
                                 DECODE(eDia,2,eCapTrasNo,0),
                                 DECODE(eDia,2,eMtoVencTrasp,0),
                                 DECODE(eDia,2,eSdoIntereses,0),
                                 DECODE(eDia,2,eSdoExigInt,0),
                                 DECODE(eDia,2,eIvaIntVig,0),
                                 DECODE(eDia,2,eIvaIntVenc,0),
								 

                                 DECODE(eDia,3,eSdoCapital,0),
                                 DECODE(eDia,3,eMontoVencido,0),
                                 DECODE(eDia,3,eCapTrasNo,0),
                                 DECODE(eDia,3,eMtoVencTrasp,0),
                                 DECODE(eDia,3,eSdoIntereses,0),
                                 DECODE(eDia,3,eSdoExigInt,0),
                                 DECODE(eDia,3,eIvaIntVig,0),
                                 DECODE(eDia,3,eIvaIntVenc,0),
								 

                                 DECODE(eDia,4,eSdoCapital,0),
                                 DECODE(eDia,4,eMontoVencido,0),
                                 DECODE(eDia,4,eCapTrasNo,0),
                                 DECODE(eDia,4,eMtoVencTrasp,0),
                                 DECODE(eDia,4,eSdoIntereses,0),
                                 DECODE(eDia,4,eSdoExigInt,0),
                                 DECODE(eDia,4,eIvaIntVig,0),
                                 DECODE(eDia,4,eIvaIntVenc,0),
								 

                                 DECODE(eDia,5,eSdoCapital,0),
                                 DECODE(eDia,5,eMontoVencido,0),
                                 DECODE(eDia,5,eCapTrasNo,0),
                                 DECODE(eDia,5,eMtoVencTrasp,0),
                                 DECODE(eDia,5,eSdoIntereses,0),
                                 DECODE(eDia,5,eSdoExigInt,0),
                                 DECODE(eDia,5,eIvaIntVig,0),
                                 DECODE(eDia,5,eIvaIntVenc,0),
								 

                                 DECODE(eDia,6,eSdoCapital,0),
                                 DECODE(eDia,6,eMontoVencido,0),
                                 DECODE(eDia,6,eCapTrasNo,0),
                                 DECODE(eDia,6,eMtoVencTrasp,0),
                                 DECODE(eDia,6,eSdoIntereses,0),
                                 DECODE(eDia,6,eSdoExigInt,0),
                                 DECODE(eDia,6,eIvaIntVig,0),
                                 DECODE(eDia,6,eIvaIntVenc,0),
								 

                                 DECODE(eDia,7,eSdoCapital,0),
                                 DECODE(eDia,7,eMontoVencido,0),
                                 DECODE(eDia,7,eCapTrasNo,0),
                                 DECODE(eDia,7,eMtoVencTrasp,0),
                                 DECODE(eDia,7,eSdoIntereses,0),
                                 DECODE(eDia,7,eSdoExigInt,0),
                                 DECODE(eDia,7,eIvaIntVig,0),
                                 DECODE(eDia,7,eIvaIntVenc,0),
								 

                                 DECODE(eDia,8,eSdoCapital,0),
                                 DECODE(eDia,8,eMontoVencido,0),
                                 DECODE(eDia,8,eCapTrasNo,0),
                                 DECODE(eDia,8,eMtoVencTrasp,0),
                                 DECODE(eDia,8,eSdoIntereses,0),
                                 DECODE(eDia,8,eSdoExigInt,0),
                                 DECODE(eDia,8,eIvaIntVig,0),
                                 DECODE(eDia,8,eIvaIntVenc,0),
								 

                                 DECODE(eDia,9,eSdoCapital,0),
                                 DECODE(eDia,9,eMontoVencido,0),
                                 DECODE(eDia,9,eCapTrasNo,0),
                                 DECODE(eDia,9,eMtoVencTrasp,0),
                                 DECODE(eDia,9,eSdoIntereses,0),
                                 DECODE(eDia,9,eSdoExigInt,0),
                                 DECODE(eDia,9,eIvaIntVig,0),
                                 DECODE(eDia,9,eIvaIntVenc,0),
								 

                                 DECODE(eDia,10,eSdoCapital,0),
                                 DECODE(eDia,10,eMontoVencido,0),
                                 DECODE(eDia,10,eCapTrasNo,0),
                                 DECODE(eDia,10,eMtoVencTrasp,0),
                                 DECODE(eDia,10,eSdoIntereses,0),
                                 DECODE(eDia,10,eSdoExigInt,0),
                                 DECODE(eDia,10,eIvaIntVig,0),
                                 DECODE(eDia,10,eIvaIntVenc,0),
								 
								 
                                 DECODE(eDia,11,eSdoCapital,0),
                                 DECODE(eDia,11,eMontoVencido,0),
                                 DECODE(eDia,11,eCapTrasNo,0),
                                 DECODE(eDia,11,eMtoVencTrasp,0),
                                 DECODE(eDia,11,eSdoIntereses,0),
                                 DECODE(eDia,11,eSdoExigInt,0),
                                 DECODE(eDia,11,eIvaIntVig,0),
                                 DECODE(eDia,11,eIvaIntVenc,0),
								 

                                 DECODE(eDia,12,eSdoCapital,0),
                                 DECODE(eDia,12,eMontoVencido,0),
                                 DECODE(eDia,12,eCapTrasNo,0),
                                 DECODE(eDia,12,eMtoVencTrasp,0),
                                 DECODE(eDia,12,eSdoIntereses,0),
                                 DECODE(eDia,12,eSdoExigInt,0),
                                 DECODE(eDia,12,eIvaIntVig,0),
                                 DECODE(eDia,12,eIvaIntVenc,0),
								 

                                 DECODE(eDia,13,eSdoCapital,0),
                                 DECODE(eDia,13,eMontoVencido,0),
                                 DECODE(eDia,13,eCapTrasNo,0),
                                 DECODE(eDia,13,eMtoVencTrasp,0),
                                 DECODE(eDia,13,eSdoIntereses,0),
                                 DECODE(eDia,13,eSdoExigInt,0),
                                 DECODE(eDia,13,eIvaIntVig,0),
                                 DECODE(eDia,13,eIvaIntVenc,0),
								 

                                 DECODE(eDia,14,eSdoCapital,0),
                                 DECODE(eDia,14,eMontoVencido,0),
                                 DECODE(eDia,14,eCapTrasNo,0),
                                 DECODE(eDia,14,eMtoVencTrasp,0),
                                 DECODE(eDia,14,eSdoIntereses,0),
                                 DECODE(eDia,14,eSdoExigInt,0),
                                 DECODE(eDia,14,eIvaIntVig,0),
                                 DECODE(eDia,14,eIvaIntVenc,0),
								 

                                 DECODE(eDia,15,eSdoCapital,0),
                                 DECODE(eDia,15,eMontoVencido,0),
                                 DECODE(eDia,15,eCapTrasNo,0),
                                 DECODE(eDia,15,eMtoVencTrasp,0),
                                 DECODE(eDia,15,eSdoIntereses,0),
                                 DECODE(eDia,15,eSdoExigInt,0),
                                 DECODE(eDia,15,eIvaIntVig,0),
                                 DECODE(eDia,15,eIvaIntVenc,0),
								 

                                 DECODE(eDia,16,eSdoCapital,0),
                                 DECODE(eDia,16,eMontoVencido,0),
                                 DECODE(eDia,16,eCapTrasNo,0),
                                 DECODE(eDia,16,eMtoVencTrasp,0),
                                 DECODE(eDia,16,eSdoIntereses,0),
                                 DECODE(eDia,16,eSdoExigInt,0),
                                 DECODE(eDia,16,eIvaIntVig,0),
                                 DECODE(eDia,16,eIvaIntVenc,0),
								

                                 DECODE(eDia,17,eSdoCapital,0),
                                 DECODE(eDia,17,eMontoVencido,0),
                                 DECODE(eDia,17,eCapTrasNo,0),
                                 DECODE(eDia,17,eMtoVencTrasp,0),
                                 DECODE(eDia,17,eSdoIntereses,0),
                                 DECODE(eDia,17,eSdoExigInt,0),
                                 DECODE(eDia,17,eIvaIntVig,0),
                                 DECODE(eDia,17,eIvaIntVenc,0),
								 

                                 DECODE(eDia,18,eSdoCapital,0),
                                 DECODE(eDia,18,eMontoVencido,0),
                                 DECODE(eDia,18,eCapTrasNo,0),
                                 DECODE(eDia,18,eMtoVencTrasp,0),
                                 DECODE(eDia,18,eSdoIntereses,0),
                                 DECODE(eDia,18,eSdoExigInt,0),
                                 DECODE(eDia,18,eIvaIntVig,0),
                                 DECODE(eDia,18,eIvaIntVenc,0),
								 

                                 DECODE(eDia,19,eSdoCapital,0),
                                 DECODE(eDia,19,eMontoVencido,0),
                                 DECODE(eDia,19,eCapTrasNo,0),
                                 DECODE(eDia,19,eMtoVencTrasp,0),
                                 DECODE(eDia,19,eSdoIntereses,0),
                                 DECODE(eDia,19,eSdoExigInt,0),
                                 DECODE(eDia,19,eIvaIntVig,0),
                                 DECODE(eDia,19,eIvaIntVenc,0),
								 

                                 DECODE(eDia,20,eSdoCapital,0),
                                 DECODE(eDia,20,eMontoVencido,0),
                                 DECODE(eDia,20,eCapTrasNo,0),
                                 DECODE(eDia,20,eMtoVencTrasp,0),
                                 DECODE(eDia,20,eSdoIntereses,0),
                                 DECODE(eDia,20,eSdoExigInt,0),
                                 DECODE(eDia,20,eIvaIntVig,0),
                                 DECODE(eDia,20,eIvaIntVenc,0),
								 

                                 DECODE(eDia,21,eSdoCapital,0),
                                 DECODE(eDia,21,eMontoVencido,0),
                                 DECODE(eDia,21,eCapTrasNo,0),
                                 DECODE(eDia,21,eMtoVencTrasp,0),
                                 DECODE(eDia,21,eSdoIntereses,0),
                                 DECODE(eDia,21,eSdoExigInt,0),
                                 DECODE(eDia,21,eIvaIntVig,0),
                                 DECODE(eDia,21,eIvaIntVenc,0),
								 

                                 DECODE(eDia,22,eSdoCapital,0),
                                 DECODE(eDia,22,eMontoVencido,0),
                                 DECODE(eDia,22,eCapTrasNo,0),
                                 DECODE(eDia,22,eMtoVencTrasp,0),
                                 DECODE(eDia,22,eSdoIntereses,0),
                                 DECODE(eDia,22,eSdoExigInt,0),
                                 DECODE(eDia,22,eIvaIntVig,0),
                                 DECODE(eDia,22,eIvaIntVenc,0),
								

                                 DECODE(eDia,23,eSdoCapital,0),
                                 DECODE(eDia,23,eMontoVencido,0),
                                 DECODE(eDia,23,eCapTrasNo,0),
                                 DECODE(eDia,23,eMtoVencTrasp,0),
                                 DECODE(eDia,23,eSdoIntereses,0),
                                 DECODE(eDia,23,eSdoExigInt,0),
                                 DECODE(eDia,23,eIvaIntVig,0),
                                 DECODE(eDia,23,eIvaIntVenc,0),
								 

                                 DECODE(eDia,24,eSdoCapital,0),
                                 DECODE(eDia,24,eMontoVencido,0),
                                 DECODE(eDia,24,eCapTrasNo,0),
                                 DECODE(eDia,24,eMtoVencTrasp,0),
                                 DECODE(eDia,24,eSdoIntereses,0),
                                 DECODE(eDia,24,eSdoExigInt,0),
                                 DECODE(eDia,24,eIvaIntVig,0),
                                 DECODE(eDia,24,eIvaIntVenc,0),
								 

                                 DECODE(eDia,25,eSdoCapital,0),
                                 DECODE(eDia,25,eMontoVencido,0),
                                 DECODE(eDia,25,eCapTrasNo,0),
                                 DECODE(eDia,25,eMtoVencTrasp,0),
                                 DECODE(eDia,25,eSdoIntereses,0),
                                 DECODE(eDia,25,eSdoExigInt,0),
                                 DECODE(eDia,25,eIvaIntVig,0),
                                 DECODE(eDia,25,eIvaIntVenc,0),
								

                                 DECODE(eDia,26,eSdoCapital,0),
                                 DECODE(eDia,26,eMontoVencido,0),
                                 DECODE(eDia,26,eCapTrasNo,0),
                                 DECODE(eDia,26,eMtoVencTrasp,0),
                                 DECODE(eDia,26,eSdoIntereses,0),
                                 DECODE(eDia,26,eSdoExigInt,0),
                                 DECODE(eDia,26,eIvaIntVig,0),
                                 DECODE(eDia,26,eIvaIntVenc,0),
								 

                                 DECODE(eDia,27,eSdoCapital,0),
                                 DECODE(eDia,27,eMontoVencido,0),
                                 DECODE(eDia,27,eCapTrasNo,0),
                                 DECODE(eDia,27,eMtoVencTrasp,0),
                                 DECODE(eDia,27,eSdoIntereses,0),
                                 DECODE(eDia,27,eSdoExigInt,0),
                                 DECODE(eDia,27,eIvaIntVig,0),
                                 DECODE(eDia,27,eIvaIntVenc,0),
								

                                 DECODE(eDia,28,eSdoCapital,0),
                                 DECODE(eDia,28,eMontoVencido,0),
                                 DECODE(eDia,28,eCapTrasNo,0),
                                 DECODE(eDia,28,eMtoVencTrasp,0),
                                 DECODE(eDia,28,eSdoIntereses,0),
                                 DECODE(eDia,28,eSdoExigInt,0),
                                 DECODE(eDia,28,eIvaIntVig,0),
                                 DECODE(eDia,28,eIvaIntVenc,0),
								 
                                 DECODE(eDia,29,eSdoCapital,0),
                                 DECODE(eDia,29,eMontoVencido,0),
                                 DECODE(eDia,29,eCapTrasNo,0),
                                 DECODE(eDia,29,eMtoVencTrasp,0),
                                 DECODE(eDia,29,eSdoIntereses,0),
                                 DECODE(eDia,29,eSdoExigInt,0),
                                 DECODE(eDia,29,eIvaIntVig,0),
                                 DECODE(eDia,29,eIvaIntVenc,0),

                                 DECODE(eDia,30,eSdoCapital,0),
                                 DECODE(eDia,30,eMontoVencido,0),
                                 DECODE(eDia,30,eCapTrasNo,0),
                                 DECODE(eDia,30,eMtoVencTrasp,0),
                                 DECODE(eDia,30,eSdoIntereses,0),
                                 DECODE(eDia,30,eSdoExigInt,0),
                                 DECODE(eDia,30,eIvaIntVig,0),
                                 DECODE(eDia,30,eIvaIntVenc,0),
								 

                                 DECODE(eDia,31,eSdoCapital,0),
                                 DECODE(eDia,31,eMontoVencido,0),
                                 DECODE(eDia,31,eCapTrasNo,0),
                                 DECODE(eDia,31,eMtoVencTrasp,0),
                                 DECODE(eDia,31,eSdoIntereses,0),
                                 DECODE(eDia,31,eSdoExigInt,0),
                                 DECODE(eDia,31,eIvaIntVig,0),
                                 DECODE(eDia,31,eIvaIntVenc,0),
								 
								 
                                 vDiaCapital,eSdoCapital,vDiaVencido,
                                 eMontoVencido,vDiaNoExig,eCapTrasNo,
                                 vDiaExig,eMtoVencTrasp,
                                 DECODE(eDia,1,eIntVenBal,0),
                                 DECODE(eDia,1,eIvaIntVenBal,0),  
                                 DECODE(eDia,2,eIntVenBal,0),
                                 DECODE(eDia,2,eIvaIntVenBal,0),  
                                 DECODE(eDia,3,eIntVenBal,0),
                                 DECODE(eDia,3,eIvaIntVenBal,0),  
                                 DECODE(eDia,4,eIntVenBal,0),
                                 DECODE(eDia,4,eIvaIntVenBal,0),  
                                 DECODE(eDia,5,eIntVenBal,0),
                                 DECODE(eDia,5,eIvaIntVenBal,0),  
                                 DECODE(eDia,6,eIntVenBal,0),
                                 DECODE(eDia,6,eIvaIntVenBal,0),  
                                 DECODE(eDia,7,eIntVenBal,0),
                                 DECODE(eDia,7,eIvaIntVenBal,0),  
                                 DECODE(eDia,8,eIntVenBal,0),
                                 DECODE(eDia,8,eIvaIntVenBal,0),  
                                 DECODE(eDia,9,eIntVenBal,0),
                                 DECODE(eDia,9,eIvaIntVenBal,0),  
                                 DECODE(eDia,10,eIntVenBal,0),
                                 DECODE(eDia,10,eIvaIntVenBal,0),  
                                 DECODE(eDia,11,eIntVenBal,0),
                                 DECODE(eDia,11,eIvaIntVenBal,0),  
                                 DECODE(eDia,12,eIntVenBal,0),
                                 DECODE(eDia,12,eIvaIntVenBal,0),  
                                 DECODE(eDia,13,eIntVenBal,0),
                                 DECODE(eDia,13,eIvaIntVenBal,0),  
                                 DECODE(eDia,14,eIntVenBal,0),
                                 DECODE(eDia,14,eIvaIntVenBal,0),  
                                 DECODE(eDia,15,eIntVenBal,0),
                                 DECODE(eDia,15,eIvaIntVenBal,0),  
                                 DECODE(eDia,16,eIntVenBal,0),
                                 DECODE(eDia,16,eIvaIntVenBal,0),  
                                 DECODE(eDia,17,eIntVenBal,0),
                                 DECODE(eDia,17,eIvaIntVenBal,0),  
                                 DECODE(eDia,18,eIntVenBal,0),
                                 DECODE(eDia,18,eIvaIntVenBal,0),  
                                 DECODE(eDia,19,eIntVenBal,0),
                                 DECODE(eDia,19,eIvaIntVenBal,0),  
                                 DECODE(eDia,20,eIntVenBal,0),
                                 DECODE(eDia,20,eIvaIntVenBal,0),  
                                 DECODE(eDia,21,eIntVenBal,0),
                                 DECODE(eDia,21,eIvaIntVenBal,0),  
                                 DECODE(eDia,22,eIntVenBal,0),
                                 DECODE(eDia,22,eIvaIntVenBal,0),  
                                 DECODE(eDia,23,eIntVenBal,0),
                                 DECODE(eDia,23,eIvaIntVenBal,0),  
                                 DECODE(eDia,24,eIntVenBal,0),
                                 DECODE(eDia,24,eIvaIntVenBal,0),  
                                 DECODE(eDia,25,eIntVenBal,0),
                                 DECODE(eDia,25,eIvaIntVenBal,0),  
                                 DECODE(eDia,26,eIntVenBal,0),
                                 DECODE(eDia,26,eIvaIntVenBal,0),  
                                 DECODE(eDia,27,eIntVenBal,0),
                                 DECODE(eDia,27,eIvaIntVenBal,0),  
                                 DECODE(eDia,28,eIntVenBal,0),
                                 DECODE(eDia,28,eIvaIntVenBal,0),  
                                 DECODE(eDia,29,eIntVenBal,0),
                                 DECODE(eDia,29,eIvaIntVenBal,0),  
                                 DECODE(eDia,30,eIntVenBal,0),
                                 DECODE(eDia,30,eIvaIntVenBal,0),  
                                 DECODE(eDia,31,eIntVenBal,0),
                                 DECODE(eDia,31,eIvaIntVenBal,0),
								 
								 								 
								 DECODE(eDia,1,eMontoFinanciado,0),
								 DECODE(eDia,2,eMontoFinanciado,0),
								 DECODE(eDia,3,eMontoFinanciado,0),
								 DECODE(eDia,4,eMontoFinanciado,0),
								 DECODE(eDia,5,eMontoFinanciado,0),
								 DECODE(eDia,6,eMontoFinanciado,0),
								 DECODE(eDia,7,eMontoFinanciado,0),
								 DECODE(eDia,8,eMontoFinanciado,0),
								 DECODE(eDia,9,eMontoFinanciado,0),
								 DECODE(eDia,10,eMontoFinanciado,0),
								 DECODE(eDia,11,eMontoFinanciado,0),
								 DECODE(eDia,12,eMontoFinanciado,0),
								 DECODE(eDia,13,eMontoFinanciado,0),
								 DECODE(eDia,14,eMontoFinanciado,0),
								 DECODE(eDia,15,eMontoFinanciado,0),
								 DECODE(eDia,16,eMontoFinanciado,0),
								 DECODE(eDia,17,eMontoFinanciado,0),
								 DECODE(eDia,18,eMontoFinanciado,0),
								 DECODE(eDia,19,eMontoFinanciado,0),
								 DECODE(eDia,20,eMontoFinanciado,0),
								 DECODE(eDia,21,eMontoFinanciado,0),
								 DECODE(eDia,22,eMontoFinanciado,0),
								 DECODE(eDia,23,eMontoFinanciado,0),
								 DECODE(eDia,24,eMontoFinanciado,0),
								 DECODE(eDia,25,eMontoFinanciado,0),
								 DECODE(eDia,26,eMontoFinanciado,0),
								 DECODE(eDia,27,eMontoFinanciado,0),
								 DECODE(eDia,28,eMontoFinanciado,0),
								 DECODE(eDia,29,eMontoFinanciado,0),
								 DECODE(eDia,30,eMontoFinanciado,0),
								 DECODE(eDia,31,eMontoFinanciado,0),
								 
								 DECODE(eDia,1,eEtapa,''),
								 DECODE(eDia,2,eEtapa,''),
								 DECODE(eDia,3,eEtapa,''),
								 DECODE(eDia,4,eEtapa,''),
								 DECODE(eDia,5,eEtapa,''),
								 DECODE(eDia,6,eEtapa,''),
								 DECODE(eDia,7,eEtapa,''),
								 DECODE(eDia,8,eEtapa,''),
								 DECODE(eDia,9,eEtapa,''),
								 DECODE(eDia,10,eEtapa,''),
								 DECODE(eDia,11,eEtapa,''),
								 DECODE(eDia,12,eEtapa,''),
								 DECODE(eDia,13,eEtapa,''),
								 DECODE(eDia,14,eEtapa,''),
								 DECODE(eDia,15,eEtapa,''),
								 DECODE(eDia,16,eEtapa,''),
								 DECODE(eDia,17,eEtapa,''),
								 DECODE(eDia,18,eEtapa,''),
								 DECODE(eDia,19,eEtapa,''),
								 DECODE(eDia,20,eEtapa,''),
								 DECODE(eDia,21,eEtapa,''),
								 DECODE(eDia,22,eEtapa,''),
								 DECODE(eDia,23,eEtapa,''),
								 DECODE(eDia,24,eEtapa,''),
								 DECODE(eDia,25,eEtapa,''),
								 DECODE(eDia,26,eEtapa,''),
								 DECODE(eDia,27,eEtapa,''),
								 DECODE(eDia,28,eEtapa,''),
								 DECODE(eDia,29,eEtapa,''),
								 DECODE(eDia,30,eEtapa,''),
								 DECODE(eDia,31,eEtapa,''),

								 DECODE(eDia,1,iAtr,0),
								 DECODE(eDia,2,iAtr,0),
								 DECODE(eDia,3,iAtr,0),
								 DECODE(eDia,4,iAtr,0),
								 DECODE(eDia,5,iAtr,0),
								 DECODE(eDia,6,iAtr,0),
								 DECODE(eDia,7,iAtr,0),
								 DECODE(eDia,8,iAtr,0),
								 DECODE(eDia,9,iAtr,0),
								 DECODE(eDia,10,iAtr,0),
								 DECODE(eDia,11,iAtr,0),
								 DECODE(eDia,12,iAtr,0),
								 DECODE(eDia,13,iAtr,0),
								 DECODE(eDia,14,iAtr,0),
								 DECODE(eDia,15,iAtr,0),
								 DECODE(eDia,16,iAtr,0),
								 DECODE(eDia,17,iAtr,0),
								 DECODE(eDia,18,iAtr,0),
								 DECODE(eDia,19,iAtr,0),
								 DECODE(eDia,20,iAtr,0),
								 DECODE(eDia,21,iAtr,0),
								 DECODE(eDia,22,iAtr,0),
								 DECODE(eDia,23,iAtr,0),
								 DECODE(eDia,24,iAtr,0),
								 DECODE(eDia,25,iAtr,0),
								 DECODE(eDia,26,iAtr,0),
								 DECODE(eDia,27,iAtr,0),
								 DECODE(eDia,28,iAtr,0),
								 DECODE(eDia,29,iAtr,0),
								 DECODE(eDia,30,iAtr,0),
								 DECODE(eDia,31,iAtr,0)
								 );
       END IF;
END
	RETURN vCodRet;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_reporte_oa()

RETURNING CHAR(5);       -- Codigo de Retorno

--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numsol        CHAR(12);
DEFINE s_sucursal      CHAR(4);
DEFINE s_status        CHAR(2);
DEFINE s_nombrecte     CHAR(50);
DEFINE s_nombre1       CHAR(20);
DEFINE s_nombre2       CHAR(20);
DEFINE s_apell_paterno CHAR(20);
DEFINE s_apell_materno CHAR(20);
DEFINE s_fecha_sol     DATE;
DEFINE s_fecha_entrada DATE;
DEFINE pfechaini       DATE;
DEFINE pfechafin       DATE;
DEFINE s_numcte        CHAR(20);
DEFINE vfecha_hoy      DATE;
DEFINE s_consulta      SMALLINT;
DEFINE pempresa        CHAR(3);
DEFINE pstatus         CHAR(2);
DEFINE psucursal       CHAR(5);
DEFINE s_situacion     CHAR(2);
DEFINE s_causa         CHAR(2);
DEFINE s_num_producto  CHAR(4);

DEFINE s_prod          CHAR(10);
DEFINE s_prod2         CHAR(4);
DEFINE s_prod3         CHAR(4);
DEFINE cRuta           CHAR (50);
DEFINE cReporteOA      CHAR (50);
DEFINE cCadena         CHAR (500);
DEFINE cfec_arch       CHAR(8);
DEFINE s_cont_cte      INTEGER;
DEFINE num_prod1       CHAR(4);
DEFINE num_prod2       CHAR(4);
-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET scod_ret        = "000";
LET vsqlerr         = 0;
LET s_numcte        = "";
LET s_numsol        = "";
LET s_sucursal      = "";
LET s_status        = "";
LET s_nombrecte     = "";
LET s_nombre1       = "";
LET s_nombre2       = "";
LET s_apell_paterno = "";
LET s_apell_materno = "";
LET s_fecha_sol     = "";
LET s_fecha_entrada = "";
LET s_consulta      = 0;
LET pempresa	    = '001';
LET pstatus         = 'OA';
LET psucursal       = '';
LET s_consulta      = 0;
LET s_situacion     = '';
LET s_causa         = '';
LET s_num_producto  = '';
LET s_prod          = '';
LET s_prod2         = '';
LET s_prod3         = '';
LET cCadena         = '';
LET cReporteOA      = '';
LET cfec_arch       = '';
LET s_cont_cte      = 0;
LET num_prod1       = '';
LET num_prod2       = '';
LET pfechaini       = '';
LET pfechafin       = '';

-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

		--SET DEBUG FILE TO "/informix/sp_reporte_OA.out";
		--TRACE ON;

-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************
    SELECT year(fecha_hoy)||lpad(month(fecha_hoy),2,0)||lpad(day(fecha_hoy),2,0),today - 6 UNITS MONTH,today
    INTO cfec_arch,pfechaini,pfechafin
    FROM bdicred:sd_fechas WHERE empresa=pempresa;
    
	SELECT valor
	INTO cRuta
    FROM "informix".sd_param WHERE cod_param = '49' AND empresa = '001';

   LET cReporteOA = "ReporteOA_"||cfec_arch||'.txt';

   LET pempresa = pempresa;
   LET psucursal = psucursal;
   LET pfechaini  = pfechaini;
   LET pfechafin = pfechafin;
   LET pstatus = pstatus;

   -- Reporte para todas las sucursales
    If nvl(psucursal, '') = '' then
        Let psucursal = null;
    End if;
	
	--Se crea tabla temporal
	 DROP INDEX IF EXISTS 'informix'.inx1_sd_repOA_tmp;
	 DROP INDEX IF EXISTS 'informix'.inx2_sd_repOA_tmp;
	 DROP TABLE IF EXISTS 'informix'.sd_reporte_oa;
	 CREATE TABLE 'informix'.sd_reporte_oa (
	           num_solicitud varchar(12),
	           num_sucursal  varchar(10),
	           nom_cliente   varchar(80),
	           producto      varchar(20),
			   num_producto  varchar(10),
			   numcte        varchar(20),
	           f_ini_vig     date,
	           f_fin_vig     date,
	           situacion_esp varchar(2),
	           causa_sit     varchar(2));
			   
     CREATE INDEX 'informix'.inx1_sd_repOA_tmp on 'informix'.sd_reporte_oa(numcte,num_solicitud,num_producto);
	 CREATE INDEX 'informix'.inx2_sd_repOA_tmp on 'informix'.sd_reporte_oa(numcte);

     LET s_consulta = 1;

     IF s_consulta = 1 THEN
        FOREACH
        	--Se obtienen las solicitudes con estatus OA	
			 SELECT a.num_solicitud, a.sucursal, a.num_producto, a.numcte, NVL(a.fecha_insert,date(1))
               INTO
                 s_numsol,s_sucursal,s_num_producto,s_numcte,s_fecha_sol		
             FROM (bdisolic:ss_solicitudes a 
             INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal )
             WHERE a.status_solicitud = pstatus AND (a.fecha_insert >= pfechaini AND a.fecha_insert <= pfechafin)  
             AND a.empresa = pempresa
             ORDER BY a.numcte,a.num_solicitud,a.sucursal,a.num_producto ASC
			 
			 --Se obtiene la informaciÃ²n de cuando se guardo el estatus OA en la bitacora de estatus
			 SELECT NVL(d.fecha_entrada,date(1))
               INTO
                 s_fecha_entrada		
             FROM bdisolic:ss_autorizacion d WHERE d.num_solicitud = s_numsol AND d.empresa = pempresa AND status_solicitud = pstatus
             AND d.fecha_entrada = (SELECT NVL(MAX(fecha_entrada),today) FROM bdisolic:ss_autorizacion
             WHERE  num_solicitud = s_numsol AND status_solicitud = pstatus AND empresa = pempresa);
			 
			 --Se obtiene el nombre del cliente
			 SELECT g.nombre1, g.nombre2, g.apell_paterno, g.apell_materno
			   INTO s_nombre1,s_nombre2, s_apell_paterno, s_apell_materno
			 FROM bdinteg:si_cliente g WHERE g.numcte = s_numcte;		 
             
			 --Se obtiene la situacion y causa
			 SELECT FIRST 1 c.situacionespecial, c.causasituacionespecial
               INTO s_situacion,s_causa
             FROM bdisolic:"informix".ss_solicitud_os a
             LEFT JOIN bdisolic:"informix".ss_osclientesupervisar c ON (c.empresa=a.empresa AND c.num_solicitud =a.num_solicitud AND c.fechasolicitud=a.fecha_solicitud)
             WHERE a.num_solicitud = s_numsol
             AND a.fecha_solicitud =(
             SELECT MAX(fecha_solicitud)
             FROM bdisolic:"informix".ss_solicitud_os b
             WHERE b.num_solicitud = a.num_solicitud ) AND a.empresa = pempresa;
             
			   --Se valida el tipo de producto	 
               IF s_num_producto = '6001' THEN
                  LET  s_prod = '4.-TDC';
               ELIF s_num_producto = '6500' THEN
                  LET  s_prod = '2.-CP';
               ELIF s_num_producto = '6800' THEN
                  LET  s_prod = '3.-PD';
			   ELIF s_num_producto = '6300' THEN
			      LET  s_prod = '3.-PP12';
			   ELIF s_num_producto = '7600' THEN
			      LET  s_prod = '3.-PP18';
			   ELIF s_num_producto = '7700' THEN
			      LET  s_prod = '3.-PP24';
               END IF;

             --Se concatena el nombre del cliente
             LET s_nombrecte=trim(s_nombre1) || ' ' || trim(s_nombre2) || ' ' || trim(s_apell_paterno) || ' ' || trim(s_apell_materno);
			 
			 --Se inserta la informacion a la tabla temporal
             INSERT INTO sd_reporte_oa VALUES (s_numsol,s_sucursal,s_nombrecte,s_prod,s_num_producto,s_numcte,s_fecha_sol,s_fecha_entrada,s_situacion,s_causa);
             	
             --Solicitudes mixtas
			   SELECT count(numcte) INTO s_cont_cte FROM bdicred:sd_reporte_oa where numcte = s_numcte AND f_ini_vig = s_fecha_sol;
			 
			   IF s_cont_cte = 2 THEN
			   
				   SELECT num_producto INTO num_prod1 FROM bdicred:sd_reporte_oa where numcte = s_numcte 
				   AND num_producto = (SELECT MIN(num_producto) FROM bdicred:sd_reporte_oa where numcte = s_numcte ) AND f_ini_vig = s_fecha_sol;
				   
				   SELECT num_producto INTO num_prod2 FROM bdicred:sd_reporte_oa where numcte = s_numcte 
				   AND num_producto = (SELECT MAX(num_producto) FROM bdicred:sd_reporte_oa where numcte = s_numcte ) AND f_ini_vig = s_fecha_sol;
			       
                  IF num_prod1 = '6001' THEN
                     LET  s_prod2 = 'TDC';
                  ELIF num_prod1 = '6500' THEN
                     LET  s_prod2 = 'CP';
                  ELIF num_prod1 = '6800' THEN
                     LET  s_prod2 = 'PD';
                  ELIF num_prod1 = '6300' THEN
			         LET  s_prod2 = 'PP12';
                  ELIF num_prod1 = '7600' THEN
                     LET  s_prod2 = 'PP18';
                  ELIF num_prod1 = '7700' THEN
                     LET  s_prod2 = 'PP24';
                  END IF;
				  
				  IF num_prod2 = '6001' THEN
                     LET  s_prod3 = 'TDC';
                  ELIF num_prod2 = '6500' THEN
                     LET  s_prod3 = 'CP';
                  ELIF num_prod2 = '6800' THEN
                     LET  s_prod3 = 'PD';
                  ELIF num_prod2 = '6300' THEN
			         LET  s_prod3 = 'PP12';
                  ELIF num_prod2 = '7600' THEN
                     LET  s_prod3 = 'PP18';
                  ELIF num_prod2 = '7700' THEN
                     LET  s_prod3 = 'PP24';
                  END IF;
				  
				  UPDATE "informix".sd_reporte_oa SET producto = '1.-'||TRIM(s_prod2) || ' Y ' || TRIM(s_prod3) WHERE numcte = s_numcte;
			   END IF;				
			 
        END FOREACH;
				
    END IF;

        LET cCadena = '';
        LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO ' || TRIM(cRuta) || TRIM(cReporteOA) ||' delimiter ''|'' SELECT num_solicitud,num_sucursal,TRIM(numcte),nom_cliente,TRIM(producto),f_ini_vig,f_fin_vig,situacion_esp,causa_sit FROM bdicred:sd_reporte_oa ORDER BY producto,f_ini_vig,numcte,nom_cliente,num_solicitud;" >'||TRIM(cRuta)||'Reporte_OA.sql';
        SYSTEM cCadena;
        LET cCadena='chmod 777 '|| TRIM(cRuta)||'Reporte_OA.sql';
        SYSTEM cCadena;
        LET cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'Reporte_OA.sql';
        SYSTEM cCadena;
        LET cCadena = '' ;
        --LET cCadena = 'rm ' || TRIM(cRuta) || 'Reporte_OA.sql';
        SYSTEM cCadena;


    RETURN scod_ret;

END;

END PROCEDURE;