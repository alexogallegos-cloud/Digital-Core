CREATE PROCEDURE "informix".sp_vta_cargacteexcep()
returning 
          CHAR(6) as resultado,
          CHAR(100) as mensaje;
		  
	DEFINE cMensajeRet      CHAR(100);
	DEFINE iCodRet          INTEGER;
	DEFINE SCodRet          CHAR(6);
	DEFINE  dtFechaHoy     	DATE;
	DEFINE  dtFechaAnt     	DATE;
	DEFINE  dtFechaRep     	CHAR(8);
	DEFINE  cRuta			CHAR(100);
	DEFINE  cNomArchOri 	CHAR(50);
	DEFINE  cNomArchRep 	CHAR(50);
	DEFINE  cSQL            CHAR(4000);
	DEFINE 	vnumcredito		CHAR(20);
	DEFINE 	vmotivo			CHAR(1);
	DEFINE	vfecharep		DATE;
	DEFINE	vproducto		CHAR(4);
	DEFINE	vexcluir		CHAR(100);
	
--SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_vta_cargacteexcep.out";
--TRACE ON; 
	
	
--Inicialización de variables
	LET cMensajeRet = 'El Proceso de cargar los créditos a excluir se ejecutó correctamente';
	LET iCodRet     = 0;
	LET SCodRet     ='000000';
	LET dtFechaHoy  = DATE(1);
	LET dtFechaAnt  = DATE(1);
	LET dtFechaRep  = '';
	LET cRuta       = '';
	LET cNomArchOri = '';
	LET cNomArchRep = '';
	LET cSQL        = '';
	LET vnumcredito   = '';
	LET vmotivo       = '';
	LET vfecharep	= DATE(1);
	LET	vproducto	= '';
	LET vexcluir       = '';
	
	--BEGIN
	BEGIN
	ON EXCEPTION SET iCodRet
	IF iCodRet != 0 THEN
		LET SCodRet = iCodRet;
		LET cMensajeRet = 'Error en la ejecución del proceso de cargar los créditos a excluir';
	END IF;
	RETURN SCodRet,cMensajeRet;
	END EXCEPTION;
	
	--Validando que se actualice el marcaje  de los creditos que se van a excluir de acuerdo al campo valor de la tabla sd_param
	SELECT TRIM(valor) INTO vexcluir
        FROM bdicred:"informix".sd_param
       WHERE cod_param = '108';
		 
	IF TRIM(vexcluir) <> '0' OR vexcluir IS NULL THEN
        LET SCodRet    = '000001';
        LET cMensajeRet   = 'Ya no es posible bloquear los créditos';
        RETURN SCodRet, cMensajeRet;
    END IF;	 
	
	
	--Seleccionamos la ruta de donde se tomará el archivo
	SELECT TRIM(valor_alfabetico) INTO cRuta 
	FROM bdicobranza:"informix".cb_param_campania WHERE empresa = '001' and tipo_campania = 50 and grupo_parametro = 'CAT_PROMOS'
	and num_parametro = 2;
	
	--let cRuta = '/informix/marcov/';----PRUEBA	
	
	--Seleccionamos Fecha de hoy
	SELECT NVL(fecha_hoy ,today) 
	INTO dtFechaHoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';	
	
	--Seleccionamos Fecha del cierre mes anterior
	
	LET dtFechaAnt = mdy(month(dtFechaHoy),1,year(dtFechaHoy));
	
	--Obtenemos Fecha para nombre de archivos
	LET dtFechaRep = year(dtFechaAnt) || lpad(month(dtFechaAnt),2,0);
	
	--Armar el nombre del archivo que contiene Archivo Origen que manda Coppel
    LET cNomArchOri = 'CreditosAExcluir'|| trim(dtFechaRep) ||'.txt';
	    
    --Verificamos si existe la tabla temporal donde se insertarán los registros y si no la borramos
	/*IF EXISTS (SELECT tabname FROM "informix".systables WHERE tabname = 'CreditosAExcluir') THEN
            DROP  TABLE CreditosAExcluir;
    END IF;
		
    --Crear Tabla Temporal donde de insertarán los datos del archivo
	create  table CreditosAExcluir
			(num_credito char(20),
			motivo char(1)
			); */
			
		
	--cargar los datos del archivo a la tabla fija
	Let  cSQL = 'echo " load from '||TRIM(cRuta) || TRIM(cNomArchOri) ||
     ' insert into "informix".sd_ctes_excluidos_vta;'
	|| '" > ' ||TRIM(cRuta) ||'query.sql';
	System cSQL;
	LET cSQL = "dbaccess bdicred "||TRIM(cRuta) ||"query.sql";
	System cSQL;
	--borrar archivo .sql
	let cSQL = '';
    let cSQL = "rm " || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'query.sql';
    System cSQL;
	
	 EXECUTE PROCEDURE sp_vta_excluyecte ('','',0) INTO SCodRet, cMensajeRet;
	
	 RETURN SCodRet,cMensajeRet;
	 END;
				
END PROCEDURE 
DOCUMENT
'Se realiza procedimiento para cargar de archivo a tabla los créditos a excluir de la venta de cartera solicitados por el area de operaciones y crédito',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 03/Abril/2013',
'BD    : BDISOLIC',
'Version: 20130507.1807 ',
'Modificación : Se Modificó SP para modificar el nombre del archivo a cargar para que tome el mes actual y solo en formato AAAAMM',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 07/Mayo/2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_actsdodiariocrd( eNumCredito    CHAR(20),
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
                                     diacapvennoexig= 0,acucapvennoexig= 0,diacapvencexig = 0,acucapvencexig = 0,fecha=eFecha
             WHERE fecha=vFecha_mesant
               AND num_credito = eNumCredito;
    END IF;

    LET vFecha_primes=MDY(MONTH(eFecha),'01',YEAR(eFecha));
    let eDia=day(eFecha);

        
IF  exists (Select num_credito from sd_sdodiariocrd where fecha=vFecha_primes and num_credito = eNumCredito) THEN
             UPDATE sd_sdodiariocrd SET capvig1        =  DECODE(eDia,1,eSdoCapital,capvig1),
                                     captrans1      =  DECODE(eDia,1,eMontoVencido,captrans1),
                                     capvencnoexig1 =  DECODE(eDia,1,eCapTrasNo,capvencnoexig1),
                                     capvenexig1    =  DECODE(eDia,1,eMtoVencTrasp,capvenexig1),
                                     intvig1        =  DECODE(eDia,1,eSdoIntereses,intvig1),
                                     intvenc1       =  DECODE(eDia,1,eSdoExigInt,intvenc1),
                                     ivaintvig1     =  DECODE(eDia,1,eIvaIntVig,ivaintvig1),
                                     ivaintvenc1    =  DECODE(eDia,1,eIvaIntVenc,ivaintvenc1),
                                     int_venc_bal1  =  DECODE(eDia,1,eIntVenBal,int_venc_bal1),
                                     ivaint_venc_bal1  =  DECODE(eDia,1,eIvaIntVenBal,ivaint_venc_bal1),

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
                                 --DECODE(eDia,1,eIvaIntVenc,0),

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
                                 DECODE(eDia,31,eIvaIntVenBal,0));
       END IF;
END
	RETURN vCodRet;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_actsdodiariocrd( eNumCredito    CHAR(20),
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
             UPDATE sd_sdodiariocrd SET capvig1        =  0,captrans1      =  0,capvencnoexig1 =  0,capvenexig1    =  0,
                                     intvig1        =  0,intvenc1       =  0,ivaintvig1     =  0,ivaintvenc1    =  0,
                                     capvig2        =  0,captrans2      =  0,capvencnoexig2 =  0,capvenexig2    =  0,
                                     intvig2        =  0,intvenc2       =  0,ivaintvig2     =  0,ivaintvenc2    =  0,
                                     capvig3        =  0,captrans3      =  0,capvencnoexig3 =  0,capvenexig3    =  0,
                                     intvig3        =  0,intvenc3       =  0,ivaintvig3     =  0,ivaintvenc3    =  0,
                                     capvig4        =  0,captrans4      =  0,capvencnoexig4 =  0,capvenexig4    =  0,
                                     intvig4        =  0,intvenc4       =  0,                                     ivaintvig5     =  DECODE(eDia,5,eIvaIntVig,ivaintvig5),
                                     ivaintvenc5    =  DECODE(eDia,5,eIvaIntVenc,ivaintvenc5),

                                     capvig6        =  DECODE(eDia,6,eSdoCapital,capvig6),
                                     captrans6      =  DECODE(eDia,6,eMontoVencido,captrans6),
                                     capvencnoexig6 =  DECODE(eDia,6,eCapTrasNo,capvencnoexig6),
                                     capvenexig6    =  DECODE(eDia,6,eMtoVencTrasp,capvenexig6),
                                     intvig6        =  DECODE(eDia,6,eSdoIntereses,intvig6),
                                     intvenc6       =  DECODE(eDia,6,eSdoExigInt,intvenc6),
                                     ivaintvig6     =  DECODE(eDia,6,eIvaIntVig,ivaintvig6),
                                     ivaintvenc6    =  DECODE(eDia,6,eIvaIntVenc,ivaintvenc6),

                                     capvig7        =  DECODE(eDia,7,eSdoCapital,capvig7),
                                     captrans7      =  DECODE(eDia,7,eMontoVencido,captrans7),
                                     capvencnoexig7 =  DECODE(eDia,7,eCapTrasNo,capvencnoexig7),
                                     capvenexig7    =  DECODE(eDia,7,eMtoVencTrasp,capvenexig7),
                                     intvig7        =  DECODE(eDia,7,eSdoIntereses,intvig7),
                                     intvenc7       =  DECODE(eDia,7,eSdoExigInt,intvenc7),
                                     ivaintvig7     =  DECODE(eDia,7,eIvaIntVig,ivaintvig7),
                                     ivaintvenc7    =  DECODE(eDia,7,eIvaIntVenc,ivaintvenc7),

                                     capvig8        =  DECODE(eDia,8,eSdoCapital,capvig8),
                                     captrans8      =  DECODE(eDia,8,eMontoVencido,captrans8),
                                     capvencnoexig8 =  DECODE(eDia,8,eCapTrasNo,capvencnoexig8),
                                     capvenexig8    =  DECODE(eDia,8,eMtoVencTrasp,capvenexig8),
                                     intvig8        =  DECODE(eDia,8,eSdoIntereses,intvig8),
                                     intvenc8       =  DECODE(eDia,8,eSdoExigInt,intvenc8),
                                     ivaintvig8     =  DECODE(eDia,8,eIvaIntVig,ivaintvig8),
                                     ivaintvenc8    =  DECODE(eDia,8,eIvaIntVenc,ivaintvenc8),

                                     capvig9        =  DECODE(eDia,9,eSdoCapital,capvig9),
                                     captrans9      =  DECODE(eDia,9,eMontoVencido,captrans9),
                                     capvencnoexig9 =  DECODE(eDia,9,eCapTrasNo,capvencnoexig9),
                                     capvenexig9    =  DECODE(eDia,9,eMtoVencTrasp,capvenexig9),
                                     intvig9        =  DECODE(eDia,9,eSdoIntereses,intvig9),
                                     intvenc9       =  DECODE(eDia,9,eSdoExigInt,intvenc9),
                                     ivaintvig9     =  DECODE(eDia,9,eIvaIntVig,ivaintvig9),
                                     ivaintvenc9    =  DECODE(eDia,9,eIvaIntVenc,ivaintvenc9),

                                     capvig10       =  DECODE(eDia,10,eSdoCapital,capvig10),
                                     captrans10     =  DECODE(eDia,10,eMontoVencido,captrans10),
                                     capvencnoexig10=  DECODE(eDia,10,eCapTrasNo,capvencnoexig10),
                                     capvenexig10   =  DECODE(eDia,10,eMtoVencTrasp,capvenexig10),
                                     intvig10       =  DECODE(eDia,10,eSdoIntereses,intvig10),
                                     intvenc10      =  DECODE(eDia,10,eSdoExigInt,intvenc10),
                                     ivaintvig10    =  DECODE(eDia,10,eIvaIntVig,ivaintvig10),
                                     ivaintvenc10   =  DECODE(eDia,10,eIvaIntVenc,ivaintvenc10),

                                     capvig11       =  DECODE(eDia,11,eSdoCapital,capvig11),
                                     captrans11     =  DECODE(eDia,11,eMontoVencido,captrans11),
                                     capvencnoexig11=  DECODE(eDia,11,eCapTrasNo,capvencnoexig11),
                                     capvenexig11   =  DECODE(eDia,11,eMtoVencTrasp,capvenexig11),
                                     intvig11       =  DECODE(eDia,11,eSdoIntereses,intvig11),
                                     intvenc11      =  DECODE(eDia,11,eSdoExigInt,intvenc11),
                                     ivaintvig11    =  DECODE(eDia,11,eIvaIntVig,ivaintvig11),
                                     ivaintvenc11   =  DECODE(eDia,11,eIvaIntVenc,ivaintvenc11),

                                     capvig12       =  DECODE(eDia,12,eSdoCapital,capvig12),
                                     captrans12     =  DECODE(eDia,12,eMontoVencido,captrans12),
                                     capvencnoexig12=  DECODE(eDia,12,eCapTrasNo,capvencnoexig12),
                                     capvenexig12   =  DECODE(eDia,12,eMtoVencTrasp,capvenexig12),
                                     intvig12       =  DECODE(eDia,12,eSdoIntereses,intvig12),
                                     intvenc12      =  DECODE(eDia,12,eSdoExigInt,intvenc12),
                                     ivaintvig12    =  DECODE(eDia,12,eIvaIntVig,ivaintvig12),
                                     ivaintvenc12   =  DECODE(eDia,12,eIvaIntVenc,ivaintvenc12),

                                     capvig13       =  DECODE(eDia,13,eSdoCapital,capvig13),
                                     captrans13     =  DECODE(eDia,13,eMontoVencido,captrans13),
                                     capvencnoexig13=  DECODE(eDia,13,eCapTrasNo,capvencnoexig13),
                                     capvenexig13   =  DECODE(eDia,13,eMtoVencTrasp,capvenexig13),
                                     intvig13       =  DECODE(eDia,13,eSdoIntereses,intvig13),
                                     intvenc13      =  DECODE(eDia,13,eSdoExigInt,intvenc13),
                                     ivaintvig13    =  DECODE(eDia,13,eIvaIntVig,ivaintvig13),
                                     ivaintvenc13   =  DECODE(eDia,13,eIvaIntVenc,ivaintvenc13),

                                     capvig14       =  DECODE(eDia,14,eSdoCapital,capvig14),
                                     captrans14     =  DECODE(eDia,14,eMontoVencido,captrans14),
                                     capvencnoexig14=  DECODE(eDia,14,eCapTrasNo,capvencnoexig14),
                                     capvenexig14   =  DECODE(eDia,14,eMtoVencTrasp,capvenexig14),
                                     intvig14       =  DECODE(eDia,14,eSdoIntereses,intvig14),
                                     intvenc14      =  DECODE(eDia,14,eSdoExigInt,intvenc14),
                                     ivaintvig14    =  DECODE(eDia,14,eIvaIntVig,ivaintvig14),
                                     ivaintvenc14   =  DECODE(eDia,14,eIvaIntVenc,ivaintvenc14),

                                     capvig15       =  DECODE(eDia,15,eSdoCapital,capvig15),
                                     captrans15     =  DECODE(eDia,15,eMontoVencido,captrans15),
                                     capvencnoexig15=  DECODE(eDia,15,eCapTrasNo,capvencnoexig15),
                                     capvenexig15   =  DECODE(eDia,15,eMtoVencTrasp,capvenexig15),
                                     intvig15       =  DECODE(eDia,15,eSdoIntereses,intvig15),
                                     intvenc15      =  DECODE(eDia,15,eSdoExigInt,intvenc15),
                                     ivaintvig15    =  DECODE(eDia,15,eIvaIntVig,ivaintvig15),
                                     ivaintvenc15   =  DECODE(eDia,15,eIvaIntVenc,ivaintvenc15),

                                     capvig16       =  DECODE(eDia,16,eSdoCapital,capvig16),
                                     captrans16     =  DECODE(eDia,16,eMontoVencido,captrans16),
                                     capvencnoexig16=  DECODE(eDia,16,eCapTrasNo,capvencnoexig16),
                                     capvenexig16   =  DECODE(eDia,16,eMtoVencTrasp,capvenexig16),
                                     intvig16       =  DECODE(eDia,16,eSdoIntereses,intvig16),
                                     intvenc16      =  DECODE(eDia,16,eSdoExigInt,intvenc16),
                                     ivaintvig16    =  DECODE(eDia,16,eIvaIntVig,ivaintvig16),
                                     ivaintvenc16   =  DECODE(eDia,16,eIvaIntVenc,ivaintvenc16),

                                     capvig17       =  DECODE(eDia,17,eSdoCapital,capvig17),
                                     captrans17     =  DECODE(eDia,17,eMontoVencido,captrans17),
                                     capvencnoexig17=  DECODE(eDia,17,eCapTrasNo,capvencnoexig17),
                                     capvenexig17   =  DECODE(eDia,17,eMtoVencTrasp,capvenexig17),
                                     intvig17       =  DECODE(eDia,17,eSdoIntereses,intvig17),
                                     intvenc17      =  DECODE(eDia,17,eSdoExigInt,intvenc17),
                                     ivaintvig17    =  DECODE(eDia,17,eIvaIntVig,ivaintvig17),
                                     ivaintvenc17   =  DECODE(eDia,17,eIvaIntVenc,ivaintvenc17),

                                     capvig18       =  DECODE(eDia,18,eSdoCapital,capvig18),
                                     captrans18     =  DECODE(eDia,18,eMontoVencido,captrans18),
                                     capvencnoexig18=  DECODE(eDia,18,eCapTrasNo,capvencnoexig18),
                                     capvenexig18   =  DECODE(eDia,18,eMtoVencTrasp,capvenexig18),
                                     intvig18       =  DECODE(eDia,18,eSdoIntereses,intvig18),
                                     intvenc18      =  DECODE(eDia,18,eSdoExigInt,intvenc18),
                                     ivaintvig18    =  DECODE(eDia,18,eIvaIntVig,ivaintvig18),
                                     ivaintvenc18   =  DECODE(eDia,18,eIvaIntVenc,ivaintvenc18),

                                     capvig19       =  DECODE(eDia,19,eSdoCapital,capvig19),
                                     captrans19     =  DECODE(eDia,19,eMontoVencido,captrans19),
                                     capvencnoexig19=  DECODE(eDia,19,eCapTrasNo,capvencnoexig19),
                                     capvenexig19   =  DECODE(eDia,19,eMtoVencTrasp,capvenexig19),
                                     intvig19       =  DECODE(eDia,19,eSdoIntereses,intvig19),
                                     intvenc19      =  DECODE(eDia,19,eSdoExigInt,intvenc19),
                                     ivaintvig19    =  DECODE(eDia,19,eIvaIntVig,ivaintvig19),
                                     ivaintvenc19   =  DECODE(eDia,19,eIvaIntVenc,ivaintvenc19),

                                     capvig20       =  DECODE(eDia,20,eSdoCapital,capvig20),
                                     captrans20     =  DECODE(eDia,20,eMontoVencido,captrans20),
                                     capvencnoexig20=  DECODE(eDia,20,eCapTrasNo,capvencnoexig20),
                                     capvenexig20   =  DECODE(eDia,20,eMtoVencTrasp,capvenexig20),
                                     intvig20       =  DECODE(eDia,20,eSdoIntereses,intvig20),
                                     intvenc20      =  DECODE(eDia,20,eSdoExigInt,intvenc20),
                                     ivaintvig20    =  DECODE(eDia,20,eIvaIntVig,ivaintvig20),
                                     ivaintvenc20   =  DECODE(eDia,20,eIvaIntVenc,ivaintvenc20),

                                     capvig21       =  DECODE(eDia,21,eSdoCapital,capvig21),
                                     captrans21     =  DECODE(eDia,21,eMontoVencido,captrans21),
                                     capvencnoexig21=  DECODE(eDia,21,eCapTrasNo,capvencnoexig21),
                                     capvenexig21   =  DECODE(eDia,21,eMtoVencTrasp,capvenexig21),
                                     intvig21       =  DECODE(eDia,21,eSdoIntereses,intvig21),
                                     intvenc21      =  DECODE(eDia,21,eSdoExigInt,intvenc21),
                                     ivaintvig21    =  DECODE(eDia,21,eIvaIntVig,ivaintvig21),
                                     ivaintvenc21   =  DECODE(eDia,21,eIvaIntVenc,ivaintvenc21),

                                     capvig22       =  DECODE(eDia,22,eSdoCapital,capvig22),
                                     captrans22     =  DECODE(eDia,22,eMontoVencido,captrans22),
                                     capvencnoexig22=  DECODE(eDia,22,eCapTrasNo,capvencnoexig22),
                                     capvenexig22   =  DECODE(eDia,22,eMtoVencTrasp,capvenexig22),
                                     intvig22       =  DECODE(eDia,22,eSdoIntereses,intvig22),
                                     intvenc22      =  DECODE(eDia,22,eSdoExigInt,intvenc22),
                                     ivaintvig22    =  DECODE(eDia,22,eIvaIntVig,ivaintvig22),
                                     ivaintvenc22   =  DECODE(eDia,22,eIvaIntVenc,ivaintvenc22),

                                     capvig23       =  DECODE(eDia,23,eSdoCapital,capvig23),
                                     captrans23     =  DECODE(eDia,23,eMontoVencido,captrans23),
                                     capvencnoexig23=  DECODE(eDia,23,eCapTrasNo,capvencnoexig23),
                                     capvenexig23   =  DECODE(eDia,23,eMtoVencTrasp,capvenexig23),
                                     intvig23       =  DECODE(eDia,23,eSdoIntereses,intvig23),
                                     intvenc23      =  DECODE(eDia,23,eSdoExigInt,intvenc23),
                                     ivaintvig23    =  DECODE(eDia,23,eIvaIntVig,ivaintvig23),
                                     ivaintvenc23   =  DECODE(eDia,23,eIvaIntVenc,ivaintvenc23),

                                     capvig24       =  DECODE(eDia,24,eSdoCapital,capvig24),
                                     captrans24     =  DECODE(eDia,24,eMontoVencido,captrans24),
                                     capvencnoexig24=  DECODE(eDia,24,eCapTrasNo,capvencnoexig24),
                                     capvenexig24   =  DECODE(eDia,24,eMtoVencTrasp,capvenexig24),
                                     intvig24       =  DECODE(eDia,24,eSdoIntereses,intvig24),
                                     intvenc24      =  DECODE(eDia,24,eSdoExigInt,intvenc24),
                                     ivaintvig24    =  DECODE(eDia,24,eIvaIntVig,ivaintvig24),
                                     ivaintvenc24   =  DECODE(eDia,24,eIvaIntVenc,ivaintvenc24),

                                     capvig25       =  DECODE(eDia,25,eSdoCapital,capvig25),
                                     captrans25     =  DECODE(eDia,25,eMontoVencido,captrans25),
                                     capvencnoexig25=  DECODE(eDia,25,eCapTrasNo,capvencnoexig25),
                                     capvenexig25   =  DECODE(eDia,25,eMtoVencTrasp,capvenexig25),
                                     intvig25       =  DECODE(eDia,25,eSdoIntereses,intvig25),
                                     intvenc25      =  DECODE(eDia,25,eSdoExigInt,intvenc25),
                                     ivaintvig25    =  DECODE(eDia,25,eIvaIntVig,ivaintvig25),
                                     ivaintvenc25   =  DECODE(eDia,25,eIvaIntVenc,ivaintvenc25),

                                     capvig26       =  DECODE(eDia,26,eSdoCapital,capvig26),
                                     captrans26     =  DECODE(eDia,26,eMontoVencido,captrans26),
                                     capvencnoexig26=  DECODE(eDia,26,eCapTrasNo,capvencnoexig26),
                                     capvenexig26   =  DECODE(eDia,26,eMtoVencTrasp,capvenexig26),
                                     intvig26       =  DECODE(eDia,26,eSdoIntereses,intvig26),
                                     intvenc26      =  DECODE(eDia,26,eSdoExigInt,intvenc26),
                                     ivaintvig26    =  DECODE(eDia,26,eIvaIntVig,ivaintvig26),
                                     ivaintvenc26   =  DECODE(eDia,26,eIvaIntVenc,ivaintvenc26),

                                     capvig27       =  DECODE(eDia,27,eSdoCapital,capvig27),
                                     captrans27     =  DECODE(eDia,27,eMontoVencido,captrans27),
                                     capvencnoexig27=  DECODE(eDia,27,eCapTrasNo,capvencnoexig27),
                                     capvenexig27   =  DECODE(eDia,27,eMtoVencTrasp,capvenexig27),
                                     intvig27       =  DECODE(eDia,27,eSdoIntereses,intvig27),
                                     intvenc27      =  DECODE(eDia,27,eSdoExigInt,intvenc27),
                                     ivaintvig27    =  DECODE(eDia,27,eIvaIntVig,ivaintvig27),
                                     ivaintvenc27   =  DECODE(eDia,27,eIvaIntVenc,ivaintvenc27),

                                     capvig28       =  DECODE(eDia,28,eSdoCapital,capvig28),
                                     captrans28     =  DECODE(eDia,28,eMontoVencido,captrans28),
                                     capvencnoexig28=  DECODE(eDia,28,eCapTrasNo,capvencnoexig28),
                                     capvenexig28   =  DECODE(eDia,28,eMtoVencTrasp,capvenexig28),
                                     intvig28       =  DECODE(eDia,28,eSdoIntereses,intvig28),
                                     intvenc28      =  DECODE(eDia,28,eSdoExigInt,intvenc28),
                                     ivaintvig28    =  DECODE(eDia,28,eIvaIntVig,ivaintvig28),
                                     ivaintvenc28   =  DECODE(eDia,28,eIvaIntVenc,ivaintvenc28),

                                     capvig29       =  DECODE(eDia,29,eSdoCapital,capvig29),
                                     captrans29     =  DECODE(eDia,29,eMontoVencido,captrans29),
                                     capvencnoexig29=  DECODE(eDia,29,eCapTrasNo,capvencnoexig29),
                                     capvenexig29   =  DECODE(eDia,29,eMtoVencTrasp,capvenexig29),
                                     intvig29       =  DECODE(eDia,29,eSdoIntereses,intvig29),
                                     intvenc29      =  DECODE(eDia,29,eSdoExigInt,intvenc29),
                                     ivaintvig29    =  DECODE(eDia,29,eIvaIntVig,ivaintvig29),
                                     ivaintvenc29   =  DECODE(eDia,29,eIvaIntVenc,ivaintvenc29),

                                     capvig30       =  DECODE(eDia,30,eSdoCapital,capvig30),
                                     captrans30     =  DECODE(eDia,30,eMontoVencido,captrans30),
                                     capvencnoexig30=  DECODE(eDia,30,eCapTrasNo,capvencnoexig30),
                                     capvenexig30   =  DECODE(eDia,30,eMtoVencTrasp,capvenexig30),
                                     intvig30       =  DECODE(eDia,30,eSdoIntereses,intvig30),
                                     intvenc30      =  DECODE(eDia,30,eSdoExigInt,intvenc30),
                                     ivaintvig30    =  DECODE(eDia,30,eIvaIntVig,ivaintvig30),
                                     ivaintvenc30   =  DECODE(eDia,30,eIvaIntVenc,ivaintvenc30),

                                     capvig31       =  DECODE(eDia,31,eSdoCapital,capvig31),
                                     captrans31     =  DECODE(eDia,31,eMontoVencido,captrans31),
                                     capvencnoexig31=  DECODE(eDia,31,eCapTrasNo,capvencnoexig31),
                                     capvenexig31   =  DECODE(eDia,31,eMtoVencTrasp,capvenexig31),
                                     intvig31       =  DECODE(eDia,31,eSdoIntereses,intvig31),
                                     intvenc31      =  DECODE(eDia,31,eSdoExigInt,intvenc31),
                                     ivaintvig31    =  DECODE(eDia,31,eIvaIntVig,ivaintvig31),
                                     ivaintvenc31   =  DECODE(eDia,31,eIvaIntVenc,ivaintvenc31),

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
                                 0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,
                                0,0,0,0,0,0,0,0,0,0,
                                0,0
                                 );
       END IF;
END
	RETURN vCodRet;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_mon_buro_reenviosrep(pModo SMALLINT, pTipoSolicitud CHAR(1), pNumSolicitud CHAR(20), pNumCte CHAR(20),pEstatus CHAR(2), pFechaIni DATE, pFechaFin DATE)


--RETORNOS-
RETURNING
CHAR(6)         AS codigo_ret,
CHAR(20)        AS retorno_01, --tiposol / numanalista
CHAR(104)       AS retorno_02, --producto /  nomanalista
CHAR(25)        AS retorno_03, --numsolic / perfilusuario
CHAR(20)        AS retorno_04, --numcte / errorcve01
CHAR(4)         AS retorno_05, --numsuc / errorcve02 
CHAR(104)       AS retorno_06, --nomcte / errorcve03
CHAR(10)        AS retorno_07, --fechasol / errorcve04
CHAR(12)        AS retorno_08, --hora / errorcve05
CHAR(4)         AS retorno_09, --estatus / errorcve06
CHAR(4)         AS retorno_10, --reenvio_exit SI o NO / errorcve07
CHAR(10)        AS retorno_11, --fecha_reenvio / errorcve08
CHAR(4)			AS retorno_12, --estatus fin / errorcve09
CHAR(80)        AS retorno_13, --motivo_reenvio/ totalbc
CHAR(104)       AS retorno_14, --nombre_analista / totalcc
CHAR(10)        AS retorno_15; -- totalglobal


--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(6);
DEFINE iSql_err				    INTEGER; 
DEFINE VSQL                     CHAR(5000);
DEFINE cReenvioExitoso          CHAR(1);
DEFINE cRetorno1                CHAR(20);
DEFINE cRetorno2                CHAR(104);   
DEFINE cRetorno3                CHAR(25);      
DEFINE cRetorno4                CHAR(20);       
DEFINE cRetorno5                CHAR(4);         
DEFINE cRetorno6                CHAR(104);       
DEFINE cRetorno7                CHAR(10);       
DEFINE cRetorno8                CHAR(12);        
DEFINE cRetorno9                CHAR(4);        
DEFINE cRetorno10               CHAR(4);        
DEFINE cRetorno11               CHAR(10);        
DEFINE cRetorno12               CHAR(4);         
DEFINE cRetorno13               CHAR(80);         
DEFINE cRetorno14               CHAR(104); 
DEFINE cRetorno15               CHAR(10);  
DEFINE cCve_grupo               CHAR(2);
DEFINE cSegmento                CHAR(2);
DEFINE cEtiqueta                CHAR(2);
DEFINE cDescripcion1            CHAR(100);
DEFINE cDescripcion2            CHAR(100);
DEFINE icontador                INTEGER;
DEFINE iSecuencia               INTEGER;
DEFINE iMaxSecuencia            INTEGER;

    
--INICIALIZACION DE VARIABLES--
LET cCodret				    = '000000';
LET iSql_err				= 0 ;
LET VSQL                    = '';
LET cReenvioExitoso         = '';
LET cRetorno1               = '';
LET cRetorno2               = '';
LET cRetorno3               = '';
LET cRetorno4               = '';
LET cRetorno5               = '';
LET cRetorno6               = '';
LET cRetorno7               = '';
LET cRetorno8               = '';
LET cRetorno9               = '';
LET cRetorno10              = '';
LET cRetorno11              = '';
LET cRetorno12              = '';
LET cRetorno13              = '';
LET cRetorno14              = '';
LET cRetorno15              = '';
LET cCve_grupo              = '';
LET cSegmento               = '';
LET cEtiqueta               = '';
LET cDescripcion1           = '';
LET cDescripcion2           = '';
LET icontador               = 0;
LET iSecuencia              = 0;
LET iMaxSecuencia           = 0;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), TRIM(NVL(cRetorno4,'')), TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')), TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), TRIM(NVL(cRetorno15,''))   ;    	
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/informix/Malena/reenvios.out';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	  --CONTROL DE ERRORES POR PARAMETRO--
	  
		IF NVL(pModo, 0) = 0 AND NVL(pTipoSolicitud, '') = '' AND NVL(pNumSolicitud, '') = '' AND NVL(pNumCte, '') = '' AND NVL(pEstatus, '') = '' AND NVL(pFechaIni, DATE(1)) = DATE(1) AND NVL(pFechaFin, DATE(1)) = DATE(1) THEN
			LET cCodret = '000001'; --PROCEDIMIENTO EJECUTADO SIN PROPORCIONAR PARAMETROS
			RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), TRIM(NVL(cRetorno4,'')), TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')), TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), TRIM(NVL(cRetorno15,'')) ; 
		END IF;
	  
		IF NVL(pModo,0) <> 1 AND NVL(pModo,0) <>2 AND NVL(pModo,0) <> 3 THEN
			LET cCodret = '000002'; --MODO DE EJECUCION INEXISTENTE
			RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), TRIM(NVL(cRetorno4,'')), TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')), TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), TRIM(NVL(cRetorno15,'')) ; 
		END IF;
	  
		IF pFechaIni IS NULL THEN
			LET pFechaIni = DATE(1);
		END IF;
		
		IF pFechaFin IS NULL THEN
			LET pFechaFin = TODAY;
		END IF;
				
	 IF pModo = 1 OR pModo = 2 THEN ---1 REENVIO DE SOLIC. O 2 REENVIO EXITOSO
		 IF pModo = 2 THEN
			LET cReenvioExitoso = '1' ;
		 END IF;
		-- SE ELIMINA EL CURSOR QUE SE ESTABA UTILIZANDO ADEMAS DE LA RELACION DE TABLAS,YA QUE SE REQUIERE SE 
		-- OBTENGA EL ESTATUS DE LA SOLICITUD DE LA TABLA DE SOLICITUDES Y/O BITACORA SEGUN SEA EL CASO.
		FOREACH WITH HOLD
		        
                SELECT rep.secuencia, rep.tipo_sol, rep.producto, rep.numsolicitud, rep.numcte, rep.sucursal,rep.nombre_cte, 
				rep.fecha_sol,rep.hora, rep.estatus,(CASE WHEN rep.reenvio_exit='1' AND (CASE WHEN rep.tipo_sol=1 THEN 
				aut.status_solicitud ELSE auto.status END) NOT IN ("BC","CC") OR (rep.reenvio_exit='0' AND rep.producto='6500' AND rep.estatus_fin NOT IN ('','BC')) THEN "SI" ELSE "NO" END) AS reenvio_exitoso, 
				rep.fecha_reenvio,rep.estatus_fin AS estatus_reenvio,(CASE WHEN rep.tipo_sol=1 THEN aut.status_solicitud ELSE auto.status END)AS estatus_fin ,rep.cve_grupo, rep.cve_segmento, rep.cve_etiqueta, 
				rep.nombre_analista,rep.motivo_reenvio 
				INTO iSecuencia,cRetorno1, cRetorno2, cRetorno3, cRetorno4,cRetorno5, cRetorno6,cRetorno7, cRetorno8,cRetorno9, 
				cRetorno10, cRetorno11, cRetorno12,cRetorno15, cCve_grupo, cSegmento, cEtiqueta, cRetorno14, cRetorno13
				FROM bdisolic:"informix".ss_mon_buro_rep rep
				LEFT JOIN bdicred:"informix".sd_bitacora_aumlincred bta ON (rep.empresa=bta.empresa 
							AND rep.numsolicitud=bta.num_solicitud
							AND bta.origen='S'
							AND rep.fecha_sol = bta.fecha_insert)
				LEFT JOIN bdicred:"informix".sd_autorizacion_aumlincred auto ON (rep.numsolicitud=auto.num_solicitud		
							AND bta.fecha_insert BETWEEN rep.fecha_sol AND auto.fecha_insert
							AND auto.status NOT IN ('PC','BC','CC') 
							AND auto.status IN (SELECT MIN(status) 
												FROM bdicred:"informix".sd_autorizacion_aumlincred 
												WHERE empresa = "001"
												AND status IN ('AC','AT','RT')
												AND fecha_insert = auto.fecha_insert
												AND num_solicitud=auto.num_solicitud))
				LEFT JOIN bdisolic:"informix".ss_autorizacion aut ON (rep.numsolicitud=aut.num_solicitud		
							AND aut.ROWID = (SELECT MIN(ROWID)
											 FROM bdisolic:ss_autorizacion WHERE empresa='001' 
											 AND status_solicitud NOT IN ('PC','BC','CC') 
											 AND num_solicitud=aut.num_solicitud))     
				WHERE rep.empresa = "001"
				AND rep.numsolicitud >=''
				AND rep.numsolicitud = DECODE (pNumSolicitud,'',rep.numsolicitud,pNumSolicitud)
				AND rep.numcte = DECODE (pNumCte,'',rep.numcte,pNumCte)
				AND rep.estatus = DECODE (pEstatus,'',rep.estatus,pEstatus)
				AND rep.reenvio_exit = rep.reenvio_exit
				AND rep.tipo_sol = DECODE (pTipoSolicitud,'',rep.tipo_sol,pTipoSolicitud)			
				AND rep.fecha_reenvio BETWEEN pFechaIni AND pFechaFin	
				ORDER BY rep.secuencia,rep.fecha_reenvio DESC				
				
		 	 	--2014-01-30 AAME INC 27 053 SE AGREGA VALIDACION PARA LOS CASOS DE LOS DE COPPEL QUE NO CAMBIA EL CAMPO DE REENVÍO EXITOSO
				IF cRetorno12 NOT IN ("BC","CC") AND cReenvioExitoso='1' THEN		
					 IF cRetorno2='6500' AND cRetorno10 ='NO' AND cRetorno12 <> '' THEN 
						LET cRetorno10 ='SI';
					 ELIF (cRetorno2 <>'6500' AND cRetorno10 ='NO') OR cRetorno12 ='' THEN 
					 	CONTINUE FOREACH;
					 END IF;
				ELIF cRetorno12 IN ("BC","CC") AND cReenvioExitoso='1' OR cRetorno2='6500' THEN
					IF cRetorno2='6500' AND NVL(cRetorno15,'BC') <> 'BC' THEN					
						SELECT MAX(secuencia)
						INTO iMaxSecuencia
						FROM bdisolic:ss_mon_buro_rep
						WHERE numsolicitud=cRetorno3;
						
						IF iSecuencia=iMaxSecuencia THEN
							LET cRetorno10 ='SI';
							LET cRetorno12 = cRetorno15;
						ELIF cReenvioExitoso='1' THEN
							CONTINUE FOREACH;
						END IF;
					ELIF cReenvioExitoso='1' THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				SELECT descripcion 
				INTO cRetorno1
				FROM "informix".sd_mon_buro_cattiposol
				WHERE SUBSTR(cve_tipo_sol,2,1) = TRIM(cRetorno1);
				
				LET cRetorno8 = SUBSTR(TRIM(cRetorno8),1,8);
				
				SELECT nombre_prod
				INTO cRetorno2
				FROM "informix".sd_definicion
				WHERE empresa = '001'
				AND num_producto = TRIM(cRetorno2);			
				
				LET icontador = icontador + 1;

				RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), 
				TRIM(NVL(cRetorno4,'')), TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), 
				TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')),
				TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), TRIM(NVL(cRetorno15,'')) WITH RESUME; 								
			
		END FOREACH;			
		
	 ELIF pModo = 3 THEN --CONSULTA POR ANALISTA
	 
		 FOREACH WITH HOLD
				SELECT  numempanalista,nombre_analista, perfil_usu, SUM (CASE WHEN cve_grupo = "01" THEN 1 ELSE 0 END) AS Total_cve01, 
				SUM (CASE WHEN cve_grupo = "02" THEN 1 ELSE 0 END) AS Total_cve02, SUM (CASE WHEN cve_grupo = "03" THEN 1 ELSE 0 END) AS Total_cve03, 
				SUM (CASE WHEN cve_grupo = "04" THEN 1 ELSE 0 END) AS Total_cve04, SUM (CASE WHEN cve_grupo = "05" THEN 1 ELSE 0 END) AS Total_cve05,
				SUM (CASE WHEN cve_grupo = "06" THEN 1 ELSE 0 END) AS Total_cve06, SUM (CASE WHEN cve_grupo = "07" THEN 1 ELSE 0 END) AS Total_cve07, 
				SUM (CASE WHEN cve_grupo = "08" THEN 1 ELSE 0 END) AS Total_cve08,SUM (CASE WHEN cve_grupo = "09" THEN 1 ELSE 0 END) AS Total_cve09, 
				SUM (CASE WHEN estatus = "BC" THEN 1 ELSE 0 END) AS Total_BC, SUM (CASE WHEN estatus = "CC" THEN 1 ELSE 0 END) AS Total_CC 
				INTO cRetorno1, cRetorno2, cRetorno3, cRetorno4,cRetorno5, cRetorno6,cRetorno7, cRetorno8,cRetorno9, cRetorno10, cRetorno11, cRetorno12, cRetorno13,cRetorno14
				FROM bdisolic: "informix".ss_mon_buro_rep 
				WHERE  empresa = "001"
				AND tipo_sol = DECODE (pTipoSolicitud,'',tipo_sol,pTipoSolicitud)
				AND estatus = DECODE (pEstatus,'',estatus,pEstatus)
				AND fecha_reenvio BETWEEN pFechaIni AND pFechaFin 
				GROUP BY numempanalista,nombre_analista, perfil_usu   
				
				LET cRetorno15 = cRetorno13::INTEGER + cRetorno14::INTEGER;
				
				LET icontador = icontador + 1;

				RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), TRIM(NVL(cRetorno4,'')), 
				TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), 
				TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')), TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), 
				TRIM(NVL(cRetorno15,'')) WITH RESUME;			


		END FOREACH;
		
	END IF;	IF icontador = 0 THEN
		LET cCodret = '000003'; --CONSULTA SIN RESULTADOS

		RETURN cCodret,'', '', '','','', '','', '','','','','','','',''; 	
	END IF;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDIMIENTO PARA LA PANTALLA DE REPORTERIA DE monitor_buro, QUE CONSULTA', 'A TRAVÉS DE 3 MODALIDADES DIFERENTES Y GENERA UN RESÚMEN ESTRUCTURADO DEL', '              CONTENIDO DE LA TABLA br_mon_buro_rep DE LA BASE DE DATOS BDIBURO. ',
'FECHA DE CREACIÓN: 07 DE JUNIO DE 2013',
'BASE DE DATOS: BDICRED',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 201306071200';

CREATE PROCEDURE "informix".sp_ce_aplicareversion (v_FolioSUC CHAR(16), v_usuario CHAR(8))

RETURNING CHAR(5);
    
    ------------------------------------------------------------------------------>
    -- Objetivo: Sp para reversion de cargo a cuenta de cheques por pago de crédito empresarial - Orión
    -- Autor: SADCV
    -- Fecha: 30/09/2013
    ------------------------------------------------------------------------------>
    
    ------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 			INTEGER;
    DEFINE cCodRet  		CHAR (5);
	

	DEFINE cod_ret 		CHAR (5);
	
    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	
	LET cod_ret 			= '';
	
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
   -- SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_aplicareversion.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
		
    ------------------------------------------------------------------------------>
	--//
    
    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            let cCodRet = vSqlErr;
            -- ROLLBACK WORK;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

	------------------------------------------------------------------------------>
	--//

    SET ISOLATION DIRTY READ;
	
	CALL bdicheq:reversion('001','9550', v_usuario, v_FolioSUC, '0') 
	RETURNING cod_ret;
	
	LET cCodRet = LPAD (TRIM(cod_ret), 5, '0');
	
    RETURN cCodRet;
    
	END;
	
END PROCEDURE;