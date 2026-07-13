CREATE PROCEDURE "informix".calulavariables_modelo2_pp (o_empresa CHAR(3),o_numsolicitud  CHAR(20))

RETURNING CHAR(5) AS scod_ret, INTEGER AS vTipoHit,INTEGER AS score;

--------- CONTROL DE CAMBIOS
--------------------------------------------------------------------------------
-- Autor: Luis Angel Juarez Vazquez, Gustavo Fuentes Lopez
-- Creacion: Se crea el procedimiento para la evaluacion de los subtipos de Hit que se pueden dar 
-- al cliente como los son Hit con cuentas de pagos fijos <= 3 y Hit con cuentas de pagos fijos > 3 
-- asi tambien como la evalucion de No Hit.

-- Fecha de Creacion: 20-07-2022
-- Proyecto: RQM 09 613- Modelo de prestamo personal Bancoppel
----------------------------------------------------------------------------------------------------------------',
--DESCRIPCION: Se agregan variables que se necesitan para el motor de evaluacion de prestamos personales MACM', 
--AUTOR:Marco Antonio Cardenas Medina ',
--FECHA:15/08/2024',
--BD: BDISOLIC';
--------------------------------------------------------------------------------
-- DESCRIPCION: Se modifica el SP para agregar el update a la tabla bdisolic:"informix".ss_certif_evaluacion_cte_adn para el producto 7800
-- AUTOR: Alan Castro Paredes
-- FECHA: 26-05-2025
-- BD: BDISOLIC';
--------------------------------------------------------------------------------
-- Autor: Luis Angel Garcia Gayosso, Kevin Galvez Parra
-- Modificacion: Se agrega validacion para ver si la solicitud es de OneClick para que se actualicen en las tablas 
-- ss_certif_evaluacion_buro_pp y ss_certif_evaluacion_cte_pp.

-- Fecha de Creacion: 25-06-2025
-- Proyecto: RQM 09 665- Capacidad de Pago - One Click
----------------------------------------------------------------------------------------------------------------',
--------------------------------------------------------------------------------
-- Autor: Kevin Galvez Parra
-- Modificacion: Se agrega validacion de OneClick Prestamo Digital para enviar a BRM.

-- Fecha de Creacion: 19-09-2025
-- Proyecto: RQM 09 665- Capacidad de Pago - One Click	
----------------------------------------------------------------------------------------------------------------',

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret                             CHAR(5);
DEFINE vsqlerr                              INTEGER;
DEFINE sql_err                              SMALLINT;
DEFINE isam_err                             SMALLINT;
DEFINE error_info                           CHAR(500);
DEFINE cmensaje                             CHAR(500);
DEFINE vMaxmop                              INTEGER;
DEFINE pfechahoy,pfechaAux, dTl13, d2Tl13   DATE;
DEFINE vEstadoCivil                         CHAR(2);
DEFINE vEstadoCivil2                        DECIMAL(10,4);
DEFINE westado_civil                        SMALLINT;

DEFINE vOcupacion                           INTEGER;
DEFINE vTmpOcupacion                        SMALLINT;

DEFINE vEscolaridad							            INTEGER;
DEFINE vEdadCte								              SMALLINT;
DEFINE vGenero								              CHAR(2);
DEFINE sGenero								SMALLINT;
DEFINE vGenero2								              DECIMAL(10,4);
DEFINE vTipo_Residencia             		    SMALLINT;
DEFINE vtmpo_Residencia             	    	SMALLINT;
DEFINE vClvEdo           					          SMALLINT;
--DEFINE vEstado          					          VARCHAR(200);
DEFINE cNomcte  							              CHAR(104);
DEFINE vNumcte                              CHAR(20);
DEFINE vNumcte_ref                              CHAR(20);
DEFINE vCuentasPF                           SMALLINT;
DEFINE vCuentasPF_c                         VARCHAR(50);
DEFINE vNumConsBC3Meses                     SMALLINT;
DEFINE vMesesAperCtaAntigua                 SMALLINT;
DEFINE vMesesAperCtaAntiguaRev              SMALLINT;
DEFINE vPorcSaldoCtasAper36                 INT;
DEFINE vSumSaldoActualTL22                  MONEY;
DEFINE vSumLimCredTL23                      MONEY;
DEFINE vSaldoMorHistAltaTL36                money(9,0);
DEFINE vMesesMorHistAltaTL37                DECIMAL(18,2);
DEFINE vNumTotalCtas                        SMALLINT;
DEFINE vPorcCta30oMasDias                   SMALLINT;
DEFINE vMaxPlazoDias                        INTEGER;
DEFINE vPeorMopHist                         CHAR(2);
DEFINE vMopT                                CHAR(2);
DEFINE vRatioConsUlt3M12M                   INT;
DEFINE vNumVecesBANCOPPEL                   INT;
DEFINE vPlazoCred                   		INTEGER;
DEFINE vNumVecesTiendaComercial             INT;
DEFINE vPromAntigMesesCtaRepUlt3Meses       INT;
DEFINE vScore                               INTEGER;
DEFINE intcount                             SMALLINT;
DEFINE intwhile                             SMALLINT;
DEFINE intConSerie                          SMALLINT;
DEFINE vMopTTemp                            CHAR(2);
DEFINE vTL38                                CHAR(2);
DEFINE vPeorMopHistTemp                     CHAR(2);
DEFINE vEficUltSem                          INTEGER; 
DEFINE vMorAct                              INTEGER;
DEFINE vPorcUso                             INTEGER;
DEFINE velemPuntualidad                     CHAR(1);
DEFINE vPuntualidad,vScorepuntualidad  INTEGER;
DEFINE vElement                              CHAR(1);
DEFINE ptpsolicitud,pSIC                         CHAR(1);
DEFINE cCodret_aux                          CHAR(5);
DEFINE vFechaTL37                           DATE;
DEFINE vGrupo                               CHAR(5);
DEFINE vEstado                              SMALLINT;
DEFINE vScorminelement 				SMALLINT;
DEFINE vScorminelementRev 			SMALLINT;
DEFINE vScormaxelement				SMALLINT;	
DEFINE vScormaxelementREv			SMALLINT;	
DEFINE vexistecta 							SMALLINT;
DEFINE dfecha36m							DATE;
DEFINE vSum_bal, vSum_higcred    DECIMAL(18,2);
DEFINE IQ0002								INTEGER;
DEFINE IQ0002_c								VARCHAR(50);
DEFINE IQ00012								INTEGER;			  
DEFINE BC_101,pmaxmop,maxmoptot,pmaxmop1,i    INTEGER;
DEFINE pcadenaaux                           CHAR(30);
DEFINE vScorePorcjUsoMin 			SMALLINT;
DEFINE vScorePorcjUsoMax 			SMALLINT;
DEFINE ESTADO_CIVIL_VAR_INT                 DECIMAL(18,2);
DEFINE UT0034, ut0034_aux, ut0034_aux2 DECIMAL(10,4);
--Rangos Minimos y Maximos Fijos
DEFINE PorcRangfijoMin 					SMALLINT;
DEFINE PorcRangofijoMax 				SMALLINT;
--Rangos Minimos y Maximos por modelo
DEFINE vScorePorcSdoMin 				SMALLINT;
DEFINE vScorePorcSdoMax 			SMALLINT;
DEFINE VI_TpResid_TmpResid         SMALLINT;
DEFINE VI_Edad_Escolaridad			SMALLINT;
DEFINE vVI_Ocup_TmpOcup           SMALLINT;
DEFINE vElem_TmpOcupacion			SMALLINT;
DEFINE vScoreMorActMin 	            SMALLINT;
DEFINE vScoreMorActMax 				SMALLINT;
DEFINE vScoreEficUltSemMin          SMALLINT;
DEFINE vScoreEficUltSemMax  		SMALLINT;
DEFINE vMesesyMonto					SMALLINT;
DEFINE vScorePlazoDiasMin    		SMALLINT;
DEFINE vScorePlazoDiasMax   		SMALLINT;
DEFINE vScorePorcjCta30oMasDiasMin	 SMALLINT;
DEFINE vScorePorcjCta30oMasDiasMax    SMALLINT;
DEFINE vScoreRatioCon3MMin         SMALLINT;
DEFINE vScoreRatioCon3MMax        SMALLINT;
DEFINE vBanCoppelTiendaComercial  SMALLINT;
DEFINE vPromAntMin 							SMALLINT;
DEFINE vPromAntMax 						SMALLINT;
DEFINE vAuxiliarPeorMOP						 INTEGER;
DEFINE vCtas_30_mas_atraso_hist				 INTEGER;
DEFINE vCtas_al_corriente					 INTEGER;
DEFINE vCtas_sin_historia					 INTEGER;
DEFINE vNumTotalCtasTL13					 INTEGER;
DEFINE iSumaTL13 							 DECIMAL(18,2);
DEFINE iSumaTL17                             DECIMAL(18,2);
DEFINE iSumaTL13TL17                         DECIMAL(18,2);
DEFINE vMesesTL13 							DECIMAL(18,2);
DEFINE vMesesTL17 							DECIMAL(18,2);
DEFINE cBRM_reing SMALLINT;	--MACM
DEFINE sId_actividad		    SMALLINT;      --ID de la actividad que realiza el cliente MACM
DEFINE cDescAct 			    CHAR(60);      --descripcion de la actividad que realiza el cliente MACM
DEFINE vDescSubAct      		VARCHAR (50);  --descripcion de la actividad que realiza el cliente MACM
DEFINE sId_subactividad	        SMALLINT;      --ID de la sub- actividad que realiza el cliente MACM
DEFINE iCanal_Sol         	    VARCHAR(50); 
DEFINE dtFechaCte			    CHAR(10);
DEFINE cSexo                    CHAR(1);       --Corresponde al genero del cliente 
DEFINE cEdo_Civil               CHAR(50);
DEFINE cEscolaridad             CHAR(50);  
DEFINE cEntidad                 CHAR(50);
DEFINE iFlag2credito 	 SMALLINT; 
DEFINE iExisteSolPP				INTEGER; 
DEFINE iExisteBR_TL_mora		CHAR(10); 
DEFINE cSucursal   			    CHAR(4);
DEFINE dtFechaNac 				CHAR(10); 
DEFINE dtFechaSolicitud         CHAR(10);
DEFINE capacidad_pres			INTEGER;
DEFINE cTp_solicitud            CHAR(1);        --tipo de solicitud
DEFINE cNum_Producto            CHAR(4);        --tipo de producto
DEFINE cStatusSolicitud         CHAR(2);        --estatus de la solicitud
DEFINE isOC						INTEGER;


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret                        = "000";
LET error_info                      = '';
LET cmensaje                        = '';
LET vsqlerr                         = 0;
LET vMaxmop                         = 0;
LET vEstadoCivil                    = '';
LET vEstadoCivil2					= 0.0000;
LET westado_civil					= 0;
LET vOcupacion                      = 0;
LET vTmpOcupacion                   = 0;
LET vEscolaridad		                = 0;
LET vEdadCte			                  = 0;
LET vGenero				                  = '';
LET sGenero   								=0;
LET vGenero2				                  = 0.0000;
LET vTipo_Residencia                = 0;
LET vtmpo_Residencia                = 0;
LET vClvEdo          		            = 0;
LET vEstado          		            = 0;
LET cNomcte  				                = '';
LET vNumcte                              ='';
LET vNumcte_ref                              ='';
LET vCuentasPF                      = 0;
LET vCuentasPF_c                      = '0';
LET vNumConsBC3Meses                = 0;
LET vMesesAperCtaAntigua            = 0;
LET vMesesAperCtaAntiguaRev         = 0;
LET vPorcSaldoCtasAper36            = 0;
LET vSumSaldoActualTL22             = 0;
LET vSumLimCredTL23                 = 0;
LET vSaldoMorHistAltaTL36           = 0.00;
LET vMesesMorHistAltaTL37           = 0.00;
LET vNumTotalCtas                   = 0;
LET vPorcCta30oMasDias              = 0;
LET vMaxPlazoDias                   = 0;
LET vPlazoCred                  	= 0;
LET vPeorMopHist                    = "";
LET vMopT                           = "";
LET vRatioConsUlt3M12M              = 0;
LET vNumVecesBANCOPPEL              = 0;
LET vNumVecesTiendaComercial        = 0;
LET vPromAntigMesesCtaRepUlt3Meses  = 0;
LET vScore                          = 0;

LET vEficUltSem                     = 0; 
LET vMorAct                         = 0;
LET vPorcUso                        = 0;
LET velemPuntualidad                = '';
LET vPuntualidad                    = 0;
LET ptpsolicitud                    ='';
LET cCodret_aux ='';
LET vFechaTL37                      = null;
LET vGrupo                          ='';
LET vScorminelement 			= 0;
LET vScorminelementRev 			= 0;
LET vScormaxelement			= 0;
LET vScormaxelementRev			= 0;
LET vexistecta = 0;
LET dfecha36m  = date(1);
LET vSum_bal  = 0;
LET vSum_higcred = 0;
LET UT0034 = 0;
LET ut0034_aux = 0;
LET IQ0002		 				= 0;
LET IQ0002_c		 				= '0';
LET IQ00012		 				= 0;
LET BC_101      =  0;
LET pmaxmop     = 0;
LET pmaxmop1    = 0;
LET pcadenaaux  = "";
LET maxmoptot   = 0;
LET vScorePorcjUsoMin = 0;
LET vScorePorcjUsoMax = 0;
LET vScorepuntualidad = 0;
LET ESTADO_CIVIL_VAR_INT = 0;
--Rangos Minimos y Maximos Fijos
LET PorcRangfijoMin = 0;
LET PorcRangofijoMax = 0;
--Rangos Minimos y Maximos por modelo
LET vScorePorcSdoMin = 0;
LET vScorePorcSdoMax = 0;
LET VI_TpResid_TmpResid = 0;
LET VI_Edad_Escolaridad    = 0;
LET vVI_Ocup_TmpOcup = 0;
LET vElem_TmpOcupacion =0;
LET i=0;
LET pSIC = '';
LET vScoreMorActMin = 0;
LET vScoreMorActMax = 0;
LET vScoreEficUltSemMin = 0;
LET vScoreEficUltSemMax = 0;
LET vMesesyMonto = 0;
LET vScorePlazoDiasMin    		= 0;
LET vScorePlazoDiasMax   		= 0;
LET vScorePorcjCta30oMasDiasMin	 = 0;
LET vScorePorcjCta30oMasDiasMax  = 0;
LET vScoreRatioCon3MMin = 0;
LET vScoreRatioCon3MMax = 0;
LET vBanCoppelTiendaComercial = 0;
LET vPromAntMin = 0;
LET vPromAntMax = 0;
LET vAuxiliarPeorMOP				 = 0;
LET vCtas_30_mas_atraso_hist		 = 0;
LET vCtas_al_corriente				 = 0;
LET vCtas_sin_historia				 = 0;
LET vNumTotalCtasTL13				 = 0;
LET iSumaTL13 						 = 0;
LET iSumaTL17                       = 0;
LET iSumaTL13TL17                   = 0;
LET vMesesTL13						= 0;
LET vMesesTL17                      = 0;
LET cBRM_reing = 0; --MACM
LET sId_actividad		  = 0; --MACM     
LET cDescAct              =""; --MACM
LET vDescSubAct              =""; --MACM                                         
LET sId_subactividad	  = 0; --MACM
LET iCanal_Sol             ="0";  
LET dtFechaCte			  = '01/01/1900';
LET cSexo                 ="";       
LET cEdo_Civil            =""; 
LET cEscolaridad          ="";
LET cEntidad              ="";
LET iFlag2credito 	  = 0;
LET iExisteSolPP	= 0;
LET iExisteBR_TL_mora = '0';
LET cSucursal   	       ="";
LET dtFechaNac 			  = '01/01/1900';
LET dtFechaSolicitud       = '01/01/1900';
LET capacidad_pres = 0;
LET cTp_solicitud          ="?";
LET cNum_Producto          ="";
LET cStatusSolicitud       ="";
LET isOC			= 0 ;

--SET DEBUG FILE TO "/ifxsif01/basededatos_motor/calulavariables_modelo2_pp.out";
--TRACE ON;
	
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "/resplogifx/calulavariables_modelo2_pp" || TRIM(o_numsolicitud) || ".err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
	  LET scod_ret = sql_err;
      RETURN scod_ret,0,0;
   END EXCEPTION; 

SET LOCK MODE TO WAIT 3;
    --Obtiene la fecha del dia
    SELECT fecha_hoy, fecha_hoy - 37 units month
      INTO pfechahoy, dfecha36m
      FROM bdicred: "informix".sd_fechas
     WHERE empresa=o_empresa;

 
    --Datos Generales de la Solicitud
    SELECT numcte, tipo_solicitud, canal_sol, sucursal, fecha_insert, nvl(capacidad_pres,0), status_solicitud, num_producto, tipo_solicitud
      INTO vNumcte, ptpsolicitud, iCanal_Sol, cSucursal, dtFechaSolicitud, capacidad_pres, cStatusSolicitud, cNum_Producto, cTp_solicitud
      FROM bdisolic:"informix".ss_solicitudes
     WHERE empresa = o_empresa
       AND num_solicitud = o_numsolicitud;

	--PPD OneClick BRM
	if iCanal_Sol in (6,7) AND cNum_Producto = "6800" THEN
		LET isOC = 1;
	end if;

	
	--MACM Se obtiene el valor si la solicitud vino por motor
	IF cNum_Producto = '7800' THEN	--ACP
		SELECT count(*) INTO cBRM_reing FROM bdisolic:"informix".ss_enviossolicitudesmotor_adn where num_solicitud = o_numsolicitud AND status_consumo= '0';
	ELSE
		SELECT count(*) INTO cBRM_reing FROM bdisolic:"informix".ss_enviossolicitudesmotor_pp where num_solicitud = o_numsolicitud AND status_consumo= '0';
	END IF;
	---- VARIABLES COPPEL
	SELECT SUBSTR(numcte_ref,1, LENGTH(numcte_ref) -1 ), fecha_insert 
	INTO vNumcte_ref, dtFechaCte
	FROM bdinteg:si_cliente 
	WHERE numcte = vNumcte;
	
	SELECT COUNT(*) into iExisteSolPP FROM bdisolic: "informix".SOLICITUDESPP_BCPPL WHERE idcte = vNumcte_ref;
	
    IF iExisteSolPP > 0 Then
      SELECT efic_ult_sem, mora_act, porcentaje_uso, puntualidad  
        INTO vEficUltSem, vMorAct, vPorcUso, velemPuntualidad 
      FROM bdisolic: "informix".SOLICITUDESPP_BCPPL WHERE idcte = vNumcte_ref;
    Else 
		Let vMorAct = null;
		Let vEficUltSem =  null;
		Let velemPuntualidad = NULL; --NO ES CLIENTE COPPEL

		LET vPorcUso = -99999;			--Nulo No es cliente COPPEL
		LET vScorePorcjUsoMin = 1;
		LET vScorePorcjUsoMax = 1;
    End IF;

    LET  vPuntualidad = CASE
            WHEN velemPuntualidad='A' THEN 1
            WHEN velemPuntualidad='B' THEN 2
            WHEN velemPuntualidad='C' THEN 3
            WHEN velemPuntualidad='D' THEN 4
            WHEN velemPuntualidad='Z' THEN 5
            WHEN velemPuntualidad='N' THEN 6
			WHEN velemPuntualidad IS NULL THEN 7
            ELSE -101 END;

    SELECT NVL(grupo,''), evalua_cc INTO vGrupo, pSIC FROM "informix".ss_resum_scor_fin WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud;

    ---- VARIABLES SOCIODEMOGRAFICAS
    --Edad del Cliente, Escolaridad, Genero y Estado Civil
    SELECT Edad,actividad, subactividad,actividad_descrip, sexo, DECODE(edo_civil,'C','Casado(a)','S', 'Soltero(a)','U', 'Union Libre', 'D', 'Divorciado(a)', 'V', 'Viudo(a)', '') as edoCivil, escolaridad_descrip,
	NVL(flag2credito,0), fecha_nacimiento
	INTO vEdadCte, sId_actividad, sId_subactividad, vDescSubAct,cSexo, cEdo_Civil, cEscolaridad,
	iFlag2credito, dtFechaNac
	FROM BDISOLIC: "informix".ss_revision_determinacion 
	  WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud;
	
	SELECT descrip
    INTO cDescAct
    FROM bdinteg:"informix".si_actsubact
    WHERE  id_subact = 0 
    AND id_act = sId_actividad;
	
	SELECT elemento INTO vEscolaridad FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' AND num_solicitud = o_numsolicitud AND grupo = 21;
	
	IF NVL(vEdadCte, 0 ) = 0 THEN
      EXECUTE PROCEDURE bdinteg:"informix".consEdadCte(o_empresa, vNumcte) INTO cCodret_aux, cNomcte, vEdadCte;    
    END IF;
	
	
      -- Nota: El detalle de los grupos vienen de la tabla ss_scoring_element
	  -- Grupo 69: Estado
      -- Grupo 5: Describe el tipo de residencia
      -- Grupo 6: Describe el tiempo de residencia
      -- Grupo 7: Describe la ocupaciÃ¿Â³n
      -- Grupo 8: Describe el tiempo de ocupaciÃ¿Â³n

    ------ VARIABLES DE BURÃ¿Â¿
    --NÃ¿Âºmero de consultas en los Ã¿Âºltimos 3 meses (90 dÃ¿Â­as).
	---------------- 'IQ0002: Num. de consultas en los ultimos 3 meses'    Gpo 56  

	select NVL (count(0),0),NVL (count(0),0) INTO IQ0002,IQ0002_c from (
	SELECT iqiq,iq02						--- INQ SEG TYPE CNT
	FROM bdiburo:br_iq 
	WHERE num_cliente = vNumcte
	and institucion in ('BC','CC')
	--and months_between ((pfechahoy-1),iqiq) >0.0
	--and months_between ((pfechahoy-1),iqiq) <= 3	--- ME INQ AGE IN MONTHS    5
	AND pfechahoy-iqiq > 0
	AND pfechahoy-iqiq <= 90							--- ME INQ VALID FLAG
	order by 1 desc
	);
    --NÃ¿Âºmero de consultas en los Ã¿Âºltimos 12 meses 

	select NVL (count(0),0) INTO IQ00012 from (
	SELECT iqiq,iq02						--- INQ SEG TYPE CNT
	FROM bdiburo:br_iq 
	WHERE num_cliente = vNumcte
	and institucion in ('BC','CC')
	--and months_between ((pfechahoy-1),iqiq) > 0.0
	--and months_between ((pfechahoy-1),iqiq) <= 12	--- ME INQ AGE IN MONTHS
	AND pfechahoy-iqiq > 0
	AND pfechahoy-iqiq <= 360							--- ME INQ VALID FLAG
	order by 1 desc
	);
    --Porcentaje de saldo de cuentas aperturadas en los Ã¿Âºltimos 36 meses.    Gpo 51
    IF (Exists(Select * FROM BDIBURO: "informix".BR_TL WHERE NUM_CLIENTE = vNumcte AND TL06 <>'M' AND months_between(pfechahoy,TL13) < 37)) THEN
      SELECT SUM(TL22) , SUM(TL23) INTO vSumSaldoActualTL22, vSumLimCredTL23 FROM BDIBURO: "informix".BR_TL WHERE NUM_CLIENTE = vNumcte AND TL06 <> 'M' AND months_between(pfechahoy,TL13) < 37;
      IF(vSumLimCredTL23 = 0) THEN
        LET vSumLimCredTL23 = -3;
      ELIF (vSumLimCredTL23 is null) THEN
        LET vSumLimCredTL23 = -2;
      END IF;

      IF(vSumSaldoActualTL22 = 0) THEN
        LET vSumSaldoActualTL22 = -1;
      END IF;

      LET vPorcSaldoCtasAper36 = TRUNC(((vSumSaldoActualTL22 / vSumLimCredTL23) * 100),0);
    ELSE
      LET vPorcSaldoCtasAper36 = null;
    END IF;

    -- Meses y monto de la fecha de morosidad mÃ¿Â¡s grave mÃ¿Â¡s reciente.

    -- FOREACH
    --   SELECT LIMIT 1 months_between(pfechahoy, TL37), TL36 
    --   INTO vMesesMorHistAltaTL37, vSaldoMorHistAltaTL36 
    --   FROM BDIBURO: "informix".BR_TL WHERE NUM_CLIENTE = vNumcte 
    --   AND TL36 IS NOT NULL AND TL37 IS NOT NULL
    --   order by TL37 desc, TL36 desc, TL38 desc, TL13 desc
    -- END FOREACH;
	
	SELECT count(TL37) 
	into iExisteBR_TL_mora 
	FROM BDIBURO: "informix".BR_TL
	 WHERE NUM_CLIENTE = vNumcte 
	 AND TL36 is not null 
	 And TL37 is not null;
	
    If iExisteBR_TL_mora > 0 Then
      
	  SELECT FIRST 1 MAX(TL37) INTO vFechaTL37 FROM BDIBURO: "informix".BR_TL WHERE NUM_CLIENTE = vNumcte  
      AND TL36 is not null And TL37 is not null; 
	  
	  LET vMesesMorHistAltaTL37 = months_between(pfechahoy,vFechaTL37);
	  
      SELECT MAX(TL36)
      INTO vSaldoMorHistAltaTL36
      FROM BDIBURO: "informix".BR_TL  WHERE NUM_CLIENTE = vNumcte  AND TL37 = vFechaTL37;

	  --SELECT first 1 tl37,tl36 INTO vMesesMorHistAltaTL37, vSaldoMorHistAltaTL36 FROM orderbymorhisalta;	  
	  --SELECT First 1 months_between(pfechahoy, TL37), TL36 
      --INTO vMesesMorHistAltaTL37, vSaldoMorHistAltaTL36
      --FROM BDIBURO: "informix".BR_TL  WHERE NUM_CLIENTE = vNumcte  AND TL37 = vFechaTL37;
    Else
      Let vMesesMorHistAltaTL37 = null;
      Let vSaldoMorHistAltaTL36 = null;
    End IF;


    --Porcentaje de cuentas con 30 o mÃ¿Â¡s dÃ¿Â­as de atraso.
    
	
	
	SELECT COUNT(*) INTO vNumTotalCtas FROM BDIBURO: "informix".BR_TL WHERE NUM_CLIENTE = vNumcte;
	
	
     
	 SELECT COUNT(*)
     INTO vCtas_30_mas_atraso_hist 
     FROM BDIBURO:BR_TL 
     WHERE NUM_CLIENTE = vNumcte 
     AND TL38 IN('02', '03', '04', '05', '06', '07', '09','2', '3', '4', '5', '6', '7', '9','96', '97', '99');
	 
	 SELECT COUNT(*) 
     INTO vCtas_al_corriente 
     FROM BDIBURO:BR_TL 
     WHERE NUM_CLIENTE = vNumcte 
     AND (TL38 IN('1')
	 OR TL38 IS null OR length(tl38)=0 );
	 
	 SELECT COUNT(*)
     INTO vCtas_sin_historia 
     FROM BDIBURO:BR_TL 
     WHERE NUM_CLIENTE = vNumcte 
     AND TL38 IN('0');
	 
	 
	
	IF vCtas_30_mas_atraso_hist > 0 THEN 
		LET vPorcCta30oMasDias = TRUNC((vCtas_30_mas_atraso_hist / vNumTotalCtas)*100);
	ELIF vCtas_al_corriente > 0 THEN
		LET vPorcCta30oMasDias = -1;
	ELIF vCtas_sin_historia > 0 THEN
		LET vPorcCta30oMasDias = -2;
	ELSE 	
		LET vPorcCta30oMasDias = -99;
	END IF;
	
	

    --MÃ¿Â¡ximo plazo en dÃ¿Â­as.
    IF NOT EXISTS (Select TL10 FROM BDIBURO: "informix".BR_TL WHERE NUM_CLIENTE = vNumcte And TL06 = 'I' ) THEN
      LET vMaxPlazoDias = null;
    ELSE

      FOREACH
        SELECT
          CASE 
            WHEN tl11 = 'H' THEN tl10 * 180 
            WHEN tl11 = 'K' THEN tl10 * 14
            WHEN tl11 = 'M' THEN tl10 * 30 
            WHEN tl11 = 'Q' THEN tl10 * 90 
            WHEN tl11 = 'S' THEN tl10 * 15 
            WHEN tl11 = 'W' THEN tl10 * 7 
            WHEN tl11 = 'Y' THEN tl10 * 365 
            WHEN tl11 = 'D' THEN tl10 
            WHEN tl11 = 'B' THEN tl10 * 60
          ELSE 0
          END 
        INTO vPlazoCred 
        FROM BDIBURO: "informix".BR_TL
          WHERE NUM_CLIENTE = vNumcte 
        And TL06 = 'I'
        order by TL22 Desc
		
		
		if vPlazoCred > vMaxPlazoDias then
			LET vMaxPlazoDias = vPlazoCred;
		end if ;
		
      END FOREACH;
    END IF;
	
				
	IF pSIC = 'X' THEN 
		LET vCuentasPF = 0; -- tipo No Hit
		LET vCuentasPF_c = 0; -- tipo No Hit
	ELSE
	 --Validar el tipo de hit >3 o <3 cuentas a calificar.
		SELECT COUNT(TL06), COUNT(TL06) INTO vCuentasPF, vCuentasPF_c FROM BDIBURO: "informix".BR_TL WHERE TL06 = 'I' AND NUM_CLIENTE = vNumcte;
		IF vCuentasPF = 0 THEN
			LET vCuentasPF = 1;
			LET vCuentasPF_c = 1;

		END IF;
		
	END IF;
 

    --Peor MOP histÃ¿Â³rico.  Gpo 27
	/*
	27	6		'<=1'
	27	7		'>1 y <=2'
	27	8		'>2'
	27	9		'Cualquier otro caso'
	27	10	'>2 y <=3'
	27	11	'>3'

	*/
	---BC_101
    SELECT MAX(case when tl38='' then 0 when tl38='UR' THEN -1 else tl38::integer end), 
           MAX(case when tl26='' then 0 when tl26='UR' THEN -1 else tl26::integer end)
      INTO pmaxmop,pmaxmop1
      FROM bdiburo:br_tl WHERE num_cliente=vNumcte;

       IF pmaxmop IS NULL AND pmaxmop1 IS NULL THEN
            LET BC_101      = -1;
            LET pmaxmop     = 0;
            LET pmaxmop1    = 0;
            LET pcadenaaux  = "";
            LET maxmoptot   = 0;
       ELIF pmaxmop IS NULL THEN
            LET pmaxmop     = 0;
       ELIF pmaxmop1 IS NULL THEN
            LET pmaxmop1    = 0;
       END IF;

       IF pmaxmop > pmaxmop1 THEN
          LET maxmoptot = pmaxmop;
       ELSE
          LET maxmoptot = pmaxmop1;
       END IF;

       LET pmaxmop  =0;
       LET pmaxmop1 =0;

    FOREACH
        SELECT TRIM(tl27),LENGTH(tl27)
          INTO pcadenaaux,pmaxmop1
          FROM bdiburo:br_tl
         WHERE num_cliente=vNumcte

          LET i = 1;

        WHILE i <= pmaxmop1
            IF substr(pcadenaaux,i,1) IN ('1','0','2','3','4','5','6','7','9') THEN LET pmaxmop= substr(pcadenaaux,i,1)::integer; 
			
			ELSE 
				LET pmaxmop= -1;
			END IF;
         -- IF pmaxmop='U' THEN LET pmaxmop=-1; END IF;
            IF  pmaxmop > maxmoptot THEN
                let maxmoptot = pmaxmop;
            END IF;
            LET i = i + 1;
        END WHILE;
    END FOREACH;

    LET BC_101      = (case when BC_101 = 0 then maxmoptot else BC_101 end);
    LET pmaxmop     = 0;
    LET pmaxmop1    = 0;
    LET pcadenaaux  = "";
    LET maxmoptot   = 0;
	
	    --HIT <= 3
    IF (vCuentasPF > 0 and vCuentasPF <= 3) THEN
		IF BC_101 <= 1 THEN
			LET vPeorMopHist = 6;   -- <=1
		ELIF BC_101 > 1 AND BC_101 <= 2 THEN
			LET vPeorMopHist = 7;    -- > 1 y <=2
		ELIF BC_101 > 2 THEN
			LET vPeorMopHist = 8;    -- > 2
		ELSE
			LET vPeorMopHist = 9;	--Cualquier otro caso'
		END IF;
	ELIF (vCuentasPF > 3) THEN
		IF BC_101 <= 1 THEN
			LET vPeorMopHist = 6;			-- <=1
		ELIF BC_101 > 1 AND BC_101 <= 2 THEN
			LET vPeorMopHist = 7;			-- > 1 y <=2
		ELIF BC_101 > 2 AND BC_101 <= 3 THEN
			LET vPeorMopHist = 10;			--'>2 y <=3'
		ELIF BC_101 > 3 THEN			
			LET vPeorMopHist = 11;			--'>3'
		ELSE
			LET vPeorMopHist = 9;	--Cualquier otro caso'
		END IF;	
	END IF;



     -- DIFERENCIA EN MESES CUENTA MAS ANTIGUA_DIFERENCIA EN MESES CUENTA MAS ANTIGUA REVOLVENTE (Variables dentro del IF(vNumcte <= 3))  Gpo 70
	  /*				<= 9
							Nulo 16
							<= 4 17
							>4 y <=7 23
							> 7 26
				>9 y <=15
							Nulo 20
							<= 10 22
							> 10 28
				>15 y <=24
							Nulo 20
							<= 10 21
							>10 y <=18 29
							> 18 35
				>24 y <=33
							Nulo 21
							<= 13 24
							>13 y <=23 31
							> 23 37
				>33 y <=45
							Nulo 23
							<= 23 29
							> 23 40
				>45 y <=92
							Nulo 25
							<= 4 23
							>4 y <=10 29
							>10 y <=18 35
							>18 y <=23 38
							>23 y <=41 42
							>41 y <=59 45
							> 59 47
				>92 y <=130
							Nulo 28
							<= 18 31
							>18 y <=31 41
							> 31 49
				> 130
							Nulo 28
							<= 23 32
							> 23 48
				Nulo 30
				Cualquier otro caso 16	  
	  */	-- DIFERENCIA EN MESES CUENTA MAS ANTIGUA_DIFERENCIA EN MESES CUENTA MAS ANTIGUA REVOLVENTE  
	--HIT <= 3
	
    --IF(vCuentasPF > 0 and vCuentasPF <= 3) THEN

      --Meses desde la apertura de la cuenta mÃ¿Â¡s antigua (en meses).
      SELECT MIN(TL13) INTO dTl13 
	    FROM BDIBURO: "informix".BR_TL  WHERE NUM_CLIENTE = vNumcte;

      SELECT FIRST 1 months_between(pfechahoy,dTl13) 
      INTO vMesesAperCtaAntigua 
      FROM BDIBURO: "informix".BR_TL  WHERE NUM_CLIENTE = vNumcte;  
	  
		IF vMesesAperCtaAntigua is null THEN
			LET vScorminelement = 1;
			LET vScormaxelement = 1;
			LET vMesesAperCtaAntigua = -1;
		ELSE
			SELECT MIN(elem.elemento) INTO vScorminelement FROM bdisolic:ss_scoring_element elem WHERE elem.empresa =  '001' AND elem.grupo = 70 and  vMesesAperCtaAntigua between elem.rango_minimo AND elem.rango_maximo ;	 	  
			SELECT MAX(elem.elemento) INTO vScormaxelement FROM bdisolic:ss_scoring_element elem WHERE elem.empresa =  '001' AND elem.grupo = 70 and  vMesesAperCtaAntigua between elem.rango_minimo AND elem.rango_maximo ;
		END IF;
	
      --Meses desde la apertura de la cuenta mÃ¿Â¡s antigua revolvente (en meses) de cuenta bancaria en moneda nacional.
		SELECT MIN(TL13) INTO d2Tl13 
		FROM BDIBURO: "informix".BR_TL    
		WHERE NUM_CLIENTE = vNumcte And TL02 in ('BANCO', 'BANCOS', 'BANCOPPEL') And TL08 <> 'US'  And TL06 = 'R' And TL16 is null ;

		SELECT FIRST 1 months_between(pfechahoy, d2Tl13) 
		INTO vMesesAperCtaAntiguaRev 
		FROM BDIBURO: "informix".BR_TL  
		WHERE NUM_CLIENTE = vNumcte And TL02 in ('BANCO', 'BANCOS', 'BANCOPPEL') And TL08 <> 'US'  And TL06 = 'R' And TL16 is null ;
	  
		IF vMesesAperCtaAntiguaRev is null Then
			IF vMesesAperCtaAntigua <= 9 THEN
				LET vScorminelementRev = 2;
				LET vScormaxelementRev = 2;
			ELIF vMesesAperCtaAntigua > 9  AND  vMesesAperCtaAntigua <= 15 THEN
				LET vScorminelementRev = 6;
				LET vScormaxelementRev = 6;
			ELIF vMesesAperCtaAntigua > 15  AND  vMesesAperCtaAntigua <= 24 THEN
				LET vScorminelementRev = 9;
				LET vScormaxelementRev = 9;		
			ELIF vMesesAperCtaAntigua > 24  AND  vMesesAperCtaAntigua <= 33 THEN
				LET vScorminelementRev = 13;
				LET vScormaxelementRev = 13;			
			ELIF vMesesAperCtaAntigua > 33  AND  vMesesAperCtaAntigua <= 45 THEN
				LET vScorminelementRev = 17;
				LET vScormaxelementRev = 17;			
			ELIF vMesesAperCtaAntigua > 45  AND  vMesesAperCtaAntigua <= 92 THEN
				LET vScorminelementRev = 20;
				LET vScormaxelementRev = 20;			
			ELIF vMesesAperCtaAntigua > 92  AND  vMesesAperCtaAntigua <= 130 THEN
				LET vScorminelementRev = 28;
				LET vScormaxelementRev = 28;			
			ELIF vMesesAperCtaAntigua > 130 THEN
				LET vScorminelementRev = 32;
				LET vScormaxelementRev = 32;		
			ELIF vMesesAperCtaAntigua IS NULL THEN	
				LET vScorminelementRev = 1;
				LET vScormaxelementRev = 1;		
			ELSE
				--Se contempla cualquier otro rango
				LET vScorminelementRev = 35;
				LET vScormaxelementRev = 35;			
			END IF;
			Let vMesesAperCtaAntiguaRev = -1;
		Else
			SELECT param.elemento INTO vScorminelementRev FROM bdisolic:ss_parametricos param INNER JOIN bdisolic:ss_scoring_element elem ON elem.elemento = param.elemento AND elem.grupo = param.grupo
			WHERE elem.empresa =  '001' AND param.grupo = 70 
			AND  param.elemento >= vScorminelement AND param.elemento <= vScormaxelement
			AND  vMesesAperCtaAntiguaRev between param.rango_min AND param.rango_max ;		
		END IF;
	--END IF;	
	

      --PORCENTAJE USO		Gpo 79																				
	/*		--Cuentas <= 3 pagos	  				--Cuentas > 3 pagos						79	2	1	'01'	'No cliente Coppel'	
		PORCENTAJE USO                 	          PORCENTAJE USO                                79	2	2	'01'	'0'         
			No cliente Coppel 18         	          	<= 0 32                                             79	2	3	'01'	'>0 y <=4'          
			0 35                                	         	>0 y <=3 38                                      79	2	4	'01'	'>4 y <=8'         
			>0 y <=4 40                    	         	>3 y <=8 35                                      79	2	5	'01'	'>8 y <=13'        
			>4 y <=8 37                    	          	>8 y <=24 33                                    79	2	6	'01'	'>13 y <=20'           
			>8 y <=13 35                  	          	>24 y <=36 30                                  79	2	7	'01'	'>20 y <=28'           
			>13 y <=20 33                 	          	>36 y <=52 29                                  79	2	8	'01'	'>28 y <=37'           
			>20 y <=28 31                 	          	>52 y <=78 25                                  79	2	9	'01'	'>37 y <=50'           
			>28 y <=37 29                 	         	> 78 20                                             79	2	10	'01'	'>50 y <=66'            
			>37 y <=50 27                 	         	No cliente Coppel 16                           79	2	11	'01'	'>66 y <=91'           
			>50 y <=66 24                 	         	Cualquier otro caso 16                        79	2	12	'01'	'>91'            
			>66 y <=91 22                 	                                                                    79	2	13	'01'	'Cualquier otro caso'
			> 91 18                           	                                                                    79	2	14	'01'	'<=0'
		Cualquier otro caso 18     	                                                                        79	2	15	'01'	'>0 y <=3'
		                                                                                                                79	2	16	'01'	'>3 y <=8'
		                                                                                                                79	2	17	'01'	'>8 y <=24'
		                                                                                                                79	2	18	'01'	'>24 y <=36'
		                                                                                                                79	2	19	'01'	'>36 y <=52'
		                                                                                                                79	2	20	'01'	'>52 y <=78'
		                                                                                                                79	2	21	'01'	'>78'
	*/  --Este solo aplica para Modelo 1 (Hit <=3 Ctas) y 2 (Hit >3 Ctas)
       IF(vPorcUso IS NOT NULL) THEN 
			--Rango de Elementos segÃ¿Âºn el modelo
			IF (vCuentasPF > 0 and vCuentasPF <= 3) THEN
				LET vScorePorcjUsoMin = 2;
				LET vScorePorcjUsoMax = 12;
			ELIF (vCuentasPF > 3)  THEN
				LET vScorePorcjUsoMin = 14;
				LET vScorePorcjUsoMax = 21;			
			END IF;			
      ELSE
			LET vPorcUso = -99998; --Cualquier otro caso
			LET vScorePorcjUsoMin = 13;
			LET vScorePorcjUsoMax = 13;

      END IF;	  	  
	  

	---------------- VI Edad & Escolaridad => Gpo 67
	/*

 Modelado Menor a 3 cuentas                                         Modelado Hit mayor a 3 cuentas							Modelado No hit												  --Menor a 3 cuentas
   	Escolaridad -- Edad				                                    EDAD --ESCOLARIDAD                                   		Variable CategorÃ¿Â­a Puntaje                      	  7	'Preparatoria ~ <=22'
	Preparatoria							                                                                                                        		Escolaridad -- Edad                                 	  8	'Preparatoria ~ >22 y <=25'
  		<= 22 			12    	                                          	<= 26	Preparatoria 7                                    		ESCOLARIDAD EDAD                              	  9	'Preparatoria ~ >25 y <=32'
   		>22 y <=25 	22         		                                            	Primaria 3                                          		Carrera TÃ¿Â©cnica   <= 41  45                    	  10	'Preparatoria ~ >32 y <=46'
    	>25 y <=32 	25				                                         		Secundaria 3                                      									> 41  57                    	  11	'Preparatoria ~ >46'
    	>32 y <=46 	30				                                         		No Estudio 3                                       	   Licenciatura o Superior  <= 23 52             	  12	'Secundaria ~ <=22'
   		>46 37								                                            	Carrera Tcnica 15                               											> 23 63             	  13	'Secundaria ~ >22 y <=25'
   	Secundaria                                                                    		Licenciatura o Superior 15                   		No Estudio 45                                         	  14	'Secundaria ~ >25 y <=28'
  		<= 22 8					                                          	>26 y <=31                                                   		Preparatoria	<= 19 		27                     	  15	'Secundaria ~ >28 y <=32'
    	>22<=25     17					                                         		Preparatoria 21                                  						>19 y <=20 	38                     	  16	'Secundaria ~ >32 y <=36'
    	>25 y <=28 21                                                          		Carrera TÃ¿Â©cnica	21                             						>20 y <=41 	48                     	  17	'Secundaria ~ >36 y <=41'
   		>28 y <=32 25                                                             		Primaria 12                                        							> 41 54                             	  18	'Secundaria ~ >41 y <=51'
  		>32 y <=36 29                                                           		No Estudio	12                                     		Primaria		<= 24 25                           	  19	'Secundaria ~ >51 y <=58'
  		>36 y <=41 31                                                           		Secundaria 12                                    							>24 y <=34 37                  	  20	'Secundaria ~ >58'
  		>41 y <=51 36                                                           		Licenciatura o Superior 29                   							>34 y <=42 46                  	  21	'Carrera TÃ¿Â©cnica ~ <=27'
    		>51 y <=58 39                                                      >31 y <=35                                                   						>42 y <=51 54                  	  22	'Carrera TÃ¿Â©cnica ~ >27 y <=45'
    		> 58 44                                                                 		Preparatoria 25                                  						> 51 63                                 	  23	'Carrera TÃ¿Â©cnica ~ >45'
    	Carrera TÃ¿Â©cnica                                                         		No Estudio 	21                                 	   Secundaria	<= 20 18                               	  24	'Primaria ~ <=29'
    		<= 27 20						                                        		Primaria 		21                                 						>20 y <=22 34                      	  25	'Primaria ~ >29 y <=35'
   		>27 y <=45 32				                                        			Secundaria 	21                                 							>22 y <=27 39                  	  26	'Primaria ~ >35 y <=43'
  		> 45 43                                                                 			Carrera Tcnica 31                               							>27 y <=35 45                  	  27	'Primaria ~ >43 y <=51'
  	Primaria                                                                    			Licenciatura o Superior 31                   							>35 y <=45 54                  	  28	'Primaria ~ >51'
   		<= 29 16							                                    >35 y <=39                                                   							> 45 60                             	  29	'No Estudio '
  		>29 y <=35 25                                                      			Carrera Tecnica 30                             		Cualquier otro caso 18                            	  30	'Licenciatura o Superior ~ <=25'
  		>35 y <=43 29                                                      			Preparatoria 30                                                                                                      	  31	'Licenciatura o Superio ~ >25 y <=46'
    	>43 y <=51 36                                                      			Licenciatura o Superior 30                                                                                       	  32	'Licenciatura o Superior ~ >46'
    	> 51 39                                                                 			No Estudio		21                                                                                                     	  33	'Null'
  	No Estudio 						 	                                    			Primaria 21                                                                                                            	  34	'Cualquier otro caso'
    	Licenciatura o Superior                                               		Secundaria 26					                                                                                    	  --Mayor a 3 cuentas
    	<= 25 28							                                    >39 y <=42                                                                                                                       	  35	'Preparatoria ~ <=26'
  		>25 y <=46 34                                                           		Secundaria 32                                                                                                        	  36	'Preparatoria ~ >26 y <=31'
    	> 46 42                                                                     		Preparatoria 32                                                                                                      	  37	'Preparatoria ~ >31 y <=35'
    	Nulo o Cualquier otro caso 8                                               Carrera Tcnica 32                                                                                                   	  38	'Preparatoria ~ >35 y <=39'
                                                                                    			Licenciatura o Superior 32                                                                                       	  39	'Preparatoria ~ >39 y <=42'
                                                                                   				No Estudio 	26                                                                                                     	  40	'Preparatoria ~ >42 y <=46'
                                                                                   				Primaria 26                                                                                                            	  41	'Preparatoria ~ >46 y <=50'
                                                                                    	>42 y <=46                                                                                                                   	  42	'Preparatoria ~ >50 y <=55'
                                                                                    			Secundaria 35                                                                                                        	  43	'Preparatoria ~ >55'
                                                                                    			Preparatoria 35                                                                                                      	  44	'Secundaria ~ <=26'
                                                                                    			Carrera Tcnica 35                                                                                                   	  45	'Secundaria ~ >26 y <=31'
                                                                                    			Licenciatura o Superior 35                                                                                       	  46	'Secundaria ~ >31 y <=35'
                                                                                   				No Estudio 29                                                                                                         	  47	'Secundaria ~ >35 y <=39'
                                                                                    			Primaria 29                                                                                                            	  48	'Secundaria ~ >39 y <=42'
                                                                                    	>46 y <=50                                                                                                                   	  49	'Secundaria ~ >42 y <=46'
                                                                                    			Secundaria 36                                                                                                        	  50	'Secundaria ~ >46 y <=50'
                                                                                    			Preparatoria 36                                                                                                      	  51	'Secundaria ~ >50 y <=55'
                                                                                   				Carrera Tcnica 36                                                                                                   	  52	'Secundaria ~ >55'
                                                                                    			Licenciatura o Superior 	36                                                                                     	  53	'Carrera TÃ¿Â©cnica ~ <=26'
                                                                                    			No Estudio 		31                                                                                                 	  54	'Carrera TÃ¿Â©cnica ~ >26 y <=31'
                                                                                    			Primaria 31                                                                                                            	  55	'Carrera TÃ¿Â©cnica ~ >31 y <=35'
                                                                                    	>50 y <=55  Carrera Tcnica 43                                                                                       	  56	'Carrera TÃ¿Â©cnica ~ >35 y <=39'
                                                                                   				Preparatoria 43                                                                                                      	  57	'Carrera TÃ¿Â©cnica ~ >39 y <=42'
                                                                                    			Licenciatura o Superior		43                                                                                 	  58	'Carrera TÃ¿Â©cnica ~ >42 y <=46'
                                                                                    			No Estudi 35                                                                                                           	  59	'Carrera TÃ¿Â©cnica ~ >46 y <=50'
                                                                                    			Primaria 35                                                                                                            	  60	'Carrera TÃ¿Â©cnica ~ >50 y <=55'
                                                                                   				Secundaria 39                                                                                                        	  61	'Carrera TÃ¿Â©cnica ~ >55'
                                                                                    	> 55                                                                                                                              	  62	'Primaria ~ <=26'
                                                                                   				Preparatoria 47                                                                                                      	  63	'Primaria ~ >26 y <=31'
                                                                                    			Carrera Tcnica 47                                                                                                   	  64	'Primaria ~ >31 y <=35'
                                                                                    			Licenciatura o Superior 47                                                                                       	  65	'Primaria ~ >35 y <=39'
                                                                                    			No Estudi 37                                                                                                           	  66	'Primaria ~ >39 y <=42'
                                                                                   				Primaria 37                                                                                                            	  67	'Primaria ~ >42 y <=46'
                                                                                    			Secundaria 42                                                                                                        	  68	'Primaria ~ >46 y <=50'
                                                                                    	Cualquier otro caso 3	                                                                                                    	  69	'Primaria ~ >50 y <=55'
                                                                                                                                                                                                                            	  70	'Primaria ~ >55'
		1	No EstudiÃ¿Â³                                                                                                                                                                                                 	  71	'No Estudio ~ <=26'
		2	Primaria                                                                                                                                                                                                    	  72	'No Estudio ~ >26 y <=31'
		3	Secundaria                                                                                                                                                                                                	  73	'No Estudio ~ >31 y <=35'
		4	Carrera TÃ¿Â©cnica                                                                                                                                                                                         	  74	'No Estudio ~ >35 y <=39'
		5	Preparatoria                                                                                                                                                                                               	  75	'No Estudio ~ >39 y <=42'
		6	Licenciatura o Superior		                                                                                                                                                                        	  76	'No Estudio ~ >42 y <=46'
	                                                                                                                                                                                                                    		  77	'No Estudio ~ >46 y <=50'
                                                                                                                                                                                                                            	  78	'No Estudio ~ >50 y <=55'
                                                                                                                                                                                                                            	  79	'No Estudio ~ >55'
                                                                                                                                                                                                                            	  80	'Licenciatura o Superior ~ <=26'
                                                                                                                                                                                                                            	  81	'Licenciatura o Superior ~ >26 y <=31'
                                                                                                                                                                                                                            	  82	'Licenciatura o Superior ~ >31 y <=35'
                                                                                                                                                                                                                            	  83	'Licenciatura o Superior ~ >35 y <=39'
                                                                                                                                                                                                                            	  84	'Licenciatura o Superior ~ >39 y <=42'
                                                                                                                                                                                                                            	  85	'Licenciatura o Superior ~ >42 y <=46'
                                                                                                                                                                                                                            	  86	'Licenciatura o Superior ~ >46 y <=50'
                                                                                                                                                                                                                            	  87	'Licenciatura o Superior ~ >50 y <=55'
                                                                                                                                                                                                                            	  88	'Licenciatura o Superior ~ >55'
                                                                                                                                                                                                                            	  --No hit
                                                                                                                                                                                                                            	  89	'Carrera TÃ¿Â©cnica ~ <=41'
                                                                                                                                                                                                                            	  90	'Carrera TÃ¿Â©cnica ~ >41'
                                                                                                                                                                                                                            	  91	'Licenciatura o Superior ~ <=23'
                                                                                                                                                                                                                            	  92	'Licenciatura o Superior ~ >23'
                                                                                                                                                                                                                            	  93	'Preparatoria ~ <=19'
                                                                                                                                                                                                                            	  94	'Preparatoria ~ >19 y <=20'
                                                                                                                                                                                                                                  95	'Preparatoria ~ >20 y <=41'
                                                                                                                                                                                                                                  96	'Preparatoria ~ >41'
                                                                                                                                                                                                                                  97	'Primaria ~ <=24'
                                                                                                                                                                                                                                  98	'Primaria ~ >24 y <=34'
                                                                                                                                                                                                                                  99	'Primaria ~ >34 y <=42'
                                                                                                                                                                                                                                  100	'Primaria ~ >42 y <=51'
                                                                                                                                                                                                                                  101	'Secundaria ~ <=20'
                                                                                                                                                                                                                                  102	'Secundaria ~ >20 y <=22'
                                                                                                                                                                                                                                  103	'Secundaria ~ >22 y <=27'
                                                                                                                                                                                                                                  104	'Secundaria ~ >27 y <=35'
                                                                                                                                                                                                                                  105	'Secundaria ~ >35 y <=45'
																																		                                                                                          106	'Secundaria ~ >45'
*/ 	
	IF vEscolaridad IN (5) THEN	-- <   Preparatoria  
		--Modelo Menor a 3 cuentas
		    --HIT <= 3
		IF(vCuentasPF > 0 and vCuentasPF <= 3) THEN
			IF vEdadCte <= 22 THEN 		--'Preparatoria- <= 22'
				LET VI_Edad_Escolaridad = 7;
			ELIF vEdadCte > 22 AND vEdadCte <= 25 THEN   --'Preparatoria- >22 y <=25'
				LET VI_Edad_Escolaridad = 8;
			ELIF vEdadCte  >25 AND vEdadCte <=32 THEN  --Preparatoria- >25 y <=32'
				LET VI_Edad_Escolaridad = 9;
			ELIF vEdadCte  >32 AND vEdadCte <=46 THEN  --Preparatoria- >32 y <=46'
				LET VI_Edad_Escolaridad = 10;
			ELIF vEdadCte  > 46 THEN								--Preparatoria- >46'
				LET VI_Edad_Escolaridad = 11;     			
			END IF;
		ELIF(vCuentasPF > 3) THEN
			IF vEdadCte <= 26 THEN 									--Preparatoria- <= 26'
				LET VI_Edad_Escolaridad = 35;
			ELIF vEdadCte > 26 AND vEdadCte <= 31 THEN 	--'Preparatoria- >26 y <=31'
				LET VI_Edad_Escolaridad = 36;
			ELIF vEdadCte > 31 AND vEdadCte <= 35 THEN  --'Preparatoria- >31 y <=35'
				LET VI_Edad_Escolaridad = 37;
			ELIF vEdadCte  > 35 AND vEdadCte <= 39 THEN  --Preparatoria- >35 y <=39'
				LET VI_Edad_Escolaridad = 38;
			ELIF vEdadCte  > 39 AND vEdadCte <= 42 THEN  --Preparatoria- >39 y <=42'
				LET VI_Edad_Escolaridad = 39;			
			ELIF vEdadCte  > 42 AND vEdadCte <= 46 THEN  --Preparatoria- >42 y <=46'
				LET VI_Edad_Escolaridad = 40;
			ELIF vEdadCte  > 46 AND vEdadCte <= 50 THEN  --Preparatoria- >46 y <=50'
				LET VI_Edad_Escolaridad = 41;			
			ELIF vEdadCte  > 50 AND vEdadCte <= 55 THEN  --Preparatoria- >50 y <=55'
				LET VI_Edad_Escolaridad = 42;				
			ELIF vEdadCte  > 55 THEN									 --Preparatoria- >55'
				LET VI_Edad_Escolaridad = 43;     			
			END IF;			
		ELIF pSIC='X' THEN
			IF vEdadCte <= 19 THEN 									--'Preparatoria- <= 19'
				LET VI_Edad_Escolaridad = 93;
			ELIF vEdadCte > 19 AND vEdadCte <= 20 THEN   --'Preparatoria- >19 y <=20'
				LET VI_Edad_Escolaridad = 94;
			ELIF vEdadCte  >20 AND vEdadCte <=41 THEN   --Preparatoria- >20 y <=41'
				LET VI_Edad_Escolaridad = 95;
			ELIF vEdadCte  > 41 THEN								    --Preparatoria- >41'
				LET VI_Edad_Escolaridad = 96;     			
			END IF;			
		END IF;
	ELIF vEscolaridad IN(3) THEN		--  Secundaria 
		--Modelo Menor a 3 cuentas
		--HIT <= 3
		IF(vCuentasPF > 0 and vCuentasPF <= 3) THEN		
			IF vEdadCte <= 22 THEN 									--Secundaria- <= 22'
				LET VI_Edad_Escolaridad = 12;
			ELIF vEdadCte > 22 AND vEdadCte <= 25 THEN 	--'Secundaria- >22 y <=25'
				LET VI_Edad_Escolaridad = 13;
			ELIF vEdadCte > 25 AND vEdadCte <= 28 THEN  --'Secundaria- >25 y <=28'
				LET VI_Edad_Escolaridad = 14;
			ELIF vEdadCte  >28 AND vEdadCte <=32 THEN  --Secundaria- >28 y <=32'
				LET VI_Edad_Escolaridad = 15;
			ELIF vEdadCte  >32 AND vEdadCte <=36 THEN  --Secundaria- >32 y <=36'
				LET VI_Edad_Escolaridad = 16;			
			ELIF vEdadCte  >36 AND vEdadCte <=41 THEN  --Secundaria- >36 y <=41'
				LET VI_Edad_Escolaridad = 17;
			ELIF vEdadCte  >41 AND vEdadCte <=51 THEN  --Secundaria- >41 y <=51'
				LET VI_Edad_Escolaridad = 18;			
			ELIF vEdadCte  >51 AND vEdadCte <=58 THEN  --Secundaria- >51 y <=58'
				LET VI_Edad_Escolaridad = 19;				
			ELIF vEdadCte  > 58 THEN								   --Secundaria- >58'
				LET VI_Edad_Escolaridad = 20;     			
			END IF;		
		ELIF(vCuentasPF > 3) THEN
			IF vEdadCte <= 26 THEN 									--Secundaria- <= 26'
				LET VI_Edad_Escolaridad = 44;
			ELIF vEdadCte > 26 AND vEdadCte <= 31 THEN 	--'Secundaria- >26 y <=31'
				LET VI_Edad_Escolaridad = 45;
			ELIF vEdadCte > 31 AND vEdadCte <= 35 THEN  --'Secundaria- >31 y <=35'
				LET VI_Edad_Escolaridad = 46;
			ELIF vEdadCte  > 35 AND vEdadCte <= 39 THEN  --Secundaria- >35 y <=39'
				LET VI_Edad_Escolaridad = 47;
			ELIF vEdadCte  > 39 AND vEdadCte <= 42 THEN  --Secundaria- >39 y <=42'
				LET VI_Edad_Escolaridad = 48;			
			ELIF vEdadCte  > 42 AND vEdadCte <= 46 THEN  --Secundaria- >42 y <=46'
				LET VI_Edad_Escolaridad = 49;
			ELIF vEdadCte  > 46 AND vEdadCte <= 50 THEN  --Secundaria- >46 y <=50'
				LET VI_Edad_Escolaridad = 50;			
			ELIF vEdadCte  > 50 AND vEdadCte <= 55 THEN  --Secundaria- >50 y <=55'
				LET VI_Edad_Escolaridad = 51;				
			ELIF vEdadCte  > 55 THEN									 --Secundaria- >55'
				LET VI_Edad_Escolaridad = 52;     			
			END IF;			
		ELIF pSIC='X' THEN
			IF vEdadCte <= 20 THEN 									--Secundaria- <= 20'
				LET VI_Edad_Escolaridad = 101;
			ELIF vEdadCte > 20 AND vEdadCte <= 22 THEN 	--'Secundaria- >20 y <=22'
				LET VI_Edad_Escolaridad = 102;
			ELIF vEdadCte > 22 AND vEdadCte <= 27 THEN  --'Secundaria- >22 y <=27'
				LET VI_Edad_Escolaridad = 103;
			ELIF vEdadCte  > 27 AND vEdadCte <= 35 THEN  --Secundaria- >27 y <=35'
				LET VI_Edad_Escolaridad = 104;
			ELIF vEdadCte  > 35 AND vEdadCte <= 45 THEN  --Secundaria- >35 y <=45'
				LET VI_Edad_Escolaridad = 105;			
			ELIF vEdadCte  > 45 THEN									 --Secundaria- >45'
				LET VI_Edad_Escolaridad = 106;     			
			END IF;						
		END IF;		
	ELIF vEscolaridad IN (4) THEN	-- <   Carrera TÃ¿Â©cnica   
		--HIT <= 3
		IF(vCuentasPF > 0 and vCuentasPF <= 3) THEN		
			IF vEdadCte <= 27 THEN 									--'Carrera TÃ¿Â©cnica- <= 27'
				LET VI_Edad_Escolaridad = 21;
			ELIF vEdadCte  >27 AND vEdadCte <=45 THEN  --Carrera TÃ¿Â©cnica- >27 y <=45'
				LET VI_Edad_Escolaridad = 22;
			ELIF vEdadCte  > 45 THEN									--Carrera TÃ¿Â©cnica- >45'
				LET VI_Edad_Escolaridad = 23;     			
			END IF;		
		ELIF(vCuentasPF > 3) THEN
			IF vEdadCte <= 26 THEN 									--Carrera TÃ¿Â©cnica- <= 26'
				LET VI_Edad_Escolaridad = 53;
			ELIF vEdadCte > 26 AND vEdadCte <= 31 THEN 	--'Carrera TÃ¿Â©cnica- >26 y <=31'
				LET VI_Edad_Escolaridad = 54;
			ELIF vEdadCte > 31 AND vEdadCte <= 35 THEN  --'Carrera TÃ¿Â©cnica- >31 y <=35'
				LET VI_Edad_Escolaridad = 55;
			ELIF vEdadCte  > 35 AND vEdadCte <= 39 THEN  --Carrera TÃ¿Â©cnica- >35 y <=39'
				LET VI_Edad_Escolaridad = 56;
			ELIF vEdadCte  > 39 AND vEdadCte <= 42 THEN  --Carrera TÃ¿Â©cnica- >39 y <=42'
				LET VI_Edad_Escolaridad = 57;			
			ELIF vEdadCte  > 42 AND vEdadCte <= 46 THEN  --Carrera TÃ¿Â©cnica- >42 y <=46'
				LET VI_Edad_Escolaridad = 58;
			ELIF vEdadCte  > 46 AND vEdadCte <= 50 THEN  --Carrera TÃ¿Â©cnica- >46 y <=50'
				LET VI_Edad_Escolaridad = 59;			
			ELIF vEdadCte  > 50 AND vEdadCte <= 55 THEN  --Carrera TÃ¿Â©cnica- >50 y <=55'
				LET VI_Edad_Escolaridad = 60;				
			ELIF vEdadCte  > 55 THEN									 --Carrera TÃ¿Â©cnica- >55'
				LET VI_Edad_Escolaridad = 61;     			
			END IF;				
		ELIF pSIC='X' THEN
			IF vEdadCte <= 41 THEN 									--Carrera TÃ¿Â©cnica- <= 41
				LET VI_Edad_Escolaridad = 89;
			ELIF vEdadCte  > 41 THEN									--Carrera TÃ¿Â©cnica- > 41
				LET VI_Edad_Escolaridad = 90;     			
			END IF;					
		END IF;				
	ELIF vEscolaridad IN (2) THEN	-- <   Primaria  
		--Modelo Menor a 3 cuentas
		--HIT <= 3
		IF(vCuentasPF > 0 and vCuentasPF <= 3) THEN				
			IF vEdadCte <= 29 THEN 									--'Primaria- <= 29'
				LET VI_Edad_Escolaridad = 24;
			ELIF vEdadCte > 29 AND vEdadCte <= 35 THEN   --'Primaria- >29 y <=35'
				LET VI_Edad_Escolaridad = 25;
			ELIF vEdadCte  >35 AND vEdadCte <=43 THEN  --Primaria- >35 y <=43'
				LET VI_Edad_Escolaridad = 26;
			ELIF vEdadCte  >43 AND vEdadCte <=51 THEN  --Primaria- >43 y <=51'
				LET VI_Edad_Escolaridad = 27;
			ELIF vEdadCte  > 51 THEN								--Primaria- >51'
				LET VI_Edad_Escolaridad = 28;     			
			END IF;		  			
				
		ELIF(vCuentasPF > 3) THEN
			IF vEdadCte <= 26 THEN 									--Primaria- <= 26'
				LET VI_Edad_Escolaridad = 62;
			ELIF vEdadCte > 26 AND vEdadCte <= 31 THEN 	--'Primaria- >26 y <=31'
				LET VI_Edad_Escolaridad = 63;
			ELIF vEdadCte > 31 AND vEdadCte <= 35 THEN  --'Primaria- >31 y <=35'
				LET VI_Edad_Escolaridad = 64;
			ELIF vEdadCte  > 35 AND vEdadCte <= 39 THEN  --Primaria- >35 y <=39'
				LET VI_Edad_Escolaridad = 65;
			ELIF vEdadCte  > 39 AND vEdadCte <= 42 THEN  --Primaria- >39 y <=42'
				LET VI_Edad_Escolaridad = 66;			
			ELIF vEdadCte  > 42 AND vEdadCte <= 46 THEN  --Primaria- >42 y <=46'
				LET VI_Edad_Escolaridad = 67;
			ELIF vEdadCte  > 46 AND vEdadCte <= 50 THEN  --Primaria- >46 y <=50'
				LET VI_Edad_Escolaridad = 68;			
			ELIF vEdadCte  > 50 AND vEdadCte <= 55 THEN  --Primaria- >50 y <=55'
				LET VI_Edad_Escolaridad = 69;				
			ELIF vEdadCte  > 55 THEN									 --Primaria- >55'
				LET VI_Edad_Escolaridad = 70;     			
			END IF;				
		ELIF pSIC='X' THEN
			IF vEdadCte <= 24 THEN 									--'Primaria- <= 24'
				LET VI_Edad_Escolaridad = 97;
			ELIF vEdadCte > 24 AND vEdadCte <= 34 THEN   --'Primaria- >24 y <=34'
				LET VI_Edad_Escolaridad = 98;
			ELIF vEdadCte  >34 AND vEdadCte <=42 THEN  --Primaria- >34 y <=42'
				LET VI_Edad_Escolaridad = 99;
			ELIF vEdadCte  >42 AND vEdadCte <=51 THEN  --Primaria- >42 y <=51'
				LET VI_Edad_Escolaridad = 100;
			ELIF vEdadCte  > 51 THEN								--Primaria- >51'
				LET VI_Edad_Escolaridad = 28;     			
			END IF;			
		END IF;				
	ELIF vEscolaridad IN (1) THEN  -- No EstudiÃ¿Â³
		--Modelo Menor a 3 cuentas
		--HIT <= 3
		IF(vCuentasPF > 0 and vCuentasPF <= 3) THEN					
				LET VI_Edad_Escolaridad = 29;   
		ELIF(vCuentasPF > 3) THEN
			IF vEdadCte <= 26 THEN 									--No EstudiÃ¿Â³- <= 26'
				LET VI_Edad_Escolaridad = 71;
			ELIF vEdadCte > 26 AND vEdadCte <= 31 THEN 	--'No EstudiÃ¿Â³- >26 y <=31'
				LET VI_Edad_Escolaridad = 72;
			ELIF vEdadCte > 31 AND vEdadCte <= 35 THEN  --'No EstudiÃ¿Â³- >31 y <=35'
				LET VI_Edad_Escolaridad = 73;
			ELIF vEdadCte  > 35 AND vEdadCte <= 39 THEN  --No EstudiÃ¿Â³- >35 y <=39'
				LET VI_Edad_Escolaridad = 74;
			ELIF vEdadCte  > 39 AND vEdadCte <= 42 THEN  --No EstudiÃ¿Â³- >39 y <=42'
				LET VI_Edad_Escolaridad = 75;			
			ELIF vEdadCte  > 42 AND vEdadCte <= 46 THEN  --No EstudiÃ¿Â³- >42 y <=46'
				LET VI_Edad_Escolaridad = 76;
			ELIF vEdadCte  > 46 AND vEdadCte <= 50 THEN  --No EstudiÃ¿Â³- >46 y <=50'
				LET VI_Edad_Escolaridad = 77;			
			ELIF vEdadCte  > 50 AND vEdadCte <= 55 THEN  --No EstudiÃ¿Â³- >50 y <=55'
				LET VI_Edad_Escolaridad = 78;				
			ELIF vEdadCte  > 55 THEN									 --No EstudiÃ¿Â³- >55'
				LET VI_Edad_Escolaridad = 79;     			
			END IF;			
		ELIF pSIC='X' THEN
				LET VI_Edad_Escolaridad = 29;   
		END IF;					
	ELIF vEscolaridad IN (6) THEN	-- <   Licenciatura o Superior  &   <= 25,  >25 y <=46, > 46
		--HIT <= 3
		IF(vCuentasPF > 0 and vCuentasPF <= 3) THEN			
			IF vEdadCte <= 25 THEN 									--'Licenciatura o Superior- <= 25'
				LET VI_Edad_Escolaridad = 30;
			ELIF vEdadCte  >25 AND vEdadCte <=46 THEN  --Licenciatura o Superior- >25 y <=46'
				LET VI_Edad_Escolaridad = 31;
			ELIF vEdadCte  > 46 THEN									--Licenciatura o Superior- >46'
				LET VI_Edad_Escolaridad = 32;     			
			END IF;				
		ELIF(vCuentasPF > 3) THEN
		--HIT >3
			IF vEdadCte <= 26 THEN 									--Licenciatura o Superior- <= 26'
				LET VI_Edad_Escolaridad = 80;
			ELIF vEdadCte > 26 AND vEdadCte <= 31 THEN 	--'Licenciatura o Superior- >26 y <=31'
				LET VI_Edad_Escolaridad = 81;
			ELIF vEdadCte > 31 AND vEdadCte <= 35 THEN  --'Licenciatura o Superior- >31 y <=35'
				LET VI_Edad_Escolaridad = 82;
			ELIF vEdadCte  > 35 AND vEdadCte <= 39 THEN  --Licenciatura o Superior- >35 y <=39'
				LET VI_Edad_Escolaridad = 83;
			ELIF vEdadCte  > 39 AND vEdadCte <= 42 THEN  --Licenciatura o Superior- >39 y <=42'
				LET VI_Edad_Escolaridad = 84;			
			ELIF vEdadCte  > 42 AND vEdadCte <= 46 THEN  --Licenciatura o Superior- >42 y <=46'
				LET VI_Edad_Escolaridad = 85;
			ELIF vEdadCte  > 46 AND vEdadCte <= 50 THEN  --Licenciatura o Superior- >46 y <=50'
				LET VI_Edad_Escolaridad = 86;			
			ELIF vEdadCte  > 50 AND vEdadCte <= 55 THEN  --Licenciatura o Superior- >50 y <=55'
				LET VI_Edad_Escolaridad = 87;				
			ELIF vEdadCte  > 55 THEN									 --Licenciatura o Superior- >55'
				LET VI_Edad_Escolaridad = 88;     			
			END IF;				
		ELIF pSIC='X' THEN
			IF vEdadCte <= 23 THEN 									--'Licenciatura o Superior- <= 23'
				LET VI_Edad_Escolaridad = 91;
			ELIF vEdadCte  > 23 THEN									--'Licenciatura o Superior- > 23'
				LET VI_Edad_Escolaridad = 92;     			
			END IF;		
		END IF;				
	ELSE	
		IF (vCuentasPF > 0 and vCuentasPF <= 3)  AND NVL(VI_Edad_Escolaridad,'') = '' THEN	
			LET VI_Edad_Escolaridad = 33; -- Missing o nulo
		ELSE 
			LET VI_Edad_Escolaridad = 34; --Cualquier otro caso	
		END IF;		
	END IF;
 
		
	  --- Variable (Estado Civil && GÃ¿Â©nero ) - GRUPO 61 - para producto P	(Prestamo Personal)
	  -- 1 = SOLTERO
		-- 6 = CASADO
		-- 7 = UNION LIBRE
		-- 8 = DIVORCIADO
		-- 9 = VIUDO
			/*
			ESTADO CIVIL GÃ¿Â¿NERO
			Casado(a)  6
					Hombre 52     Hombre - Casado  4
					Mujer 62		--ya esta  2
			Soltero(a)  1
					Hombre 38  -- ya esta   1
					Mujer 45     Mujer - Soltera 5					
			Divorciado(a)  8     44   Divorciado 6
			UniÃ¿Â³n Libre  7
					Hombre 40    Hombre - UniÃ¿Â³n Libre 7
					Mujer 45        Mujer - UniÃ¿Â³n Libre 8
			Viudo(a) 9    51            Viudo(a)  9
			Cualquier otro caso 38     10

			1	'01'	'Hombre - Soltero'
			2	'01'	'Mujer - Casada'
			3	'01'	'Missing'
			4	'01'	'Casado(a)-Hombre'
			5	'01'	'Divorciado(a)'
			6	'01'	'Soltero(a)-Mujer'
			7	'01'	'UniÃ¿Â³n Libre-Hombre'
			8	'01'	'UniÃ¿Â³n Libre-Mujer'
			9	'01'	'Viudo(a)-Hombre'
			10 '01'	'Viudo(a)-Mujer'
			11 '01'	'Cualquier otro caso'
			
			*/
		
		select elemento
		  into westado_civil
		  from bdisolic:ss_detalle_scoring 
		 where empresa = o_empresa
		   and num_solicitud = o_numsolicitud 
		   and seccion = 2
		   and grupo = 3
		   AND tpo_persona='01';		
		   
		--Genero: Elemento: 3 Mujer, 4 Hombre)
	
		SELECT elemento INTO sGenero FROM bdisolic:ss_detalle_scoring WHERE num_solicitud = o_numsolicitud AND seccion = 2 AND grupo = 2;		   
	
	    IF (westado_civil IS NULL) THEN
			LET ESTADO_CIVIL_VAR_INT = 3;
		
		ELIF (westado_civil) = 6 THEN			---- CASADO				
			IF sGenero =4 then		--- Hombre - Casado  4
				LET ESTADO_CIVIL_VAR_INT = 4;
			ELIF sGenero =3 then	--- Mujer - Casado  2
				LET ESTADO_CIVIL_VAR_INT = 2;
			END IF;
		ELIF (westado_civil) = 8 THEN			--- Divorciado
			LET ESTADO_CIVIL_VAR_INT = 5;
		ELIF (westado_civil) = 1 THEN			--- Soltero
			IF sGenero =4 then		--- Hombre - Soltero  1
				LET ESTADO_CIVIL_VAR_INT = 1;
			ELIF sGenero =3 then	--- Mujer - Soltera 5	
				LET ESTADO_CIVIL_VAR_INT = 6;
			END IF;						
		ELIF (westado_civil) = 7 THEN			--- Union Libre
			IF sGenero =4 then		--- Hombre - Union Libre  7
				LET ESTADO_CIVIL_VAR_INT = 7;
			ELIF sGenero =3 then	--- Mujer - Union Libre 8	
				LET ESTADO_CIVIL_VAR_INT = 8;
			END IF;		
		ELIF (westado_civil) = 9 THEN			--- Viudo  9
			IF sGenero =4 then		--- Hombre - Viudo  7
				LET ESTADO_CIVIL_VAR_INT = 9;	
			ELIF sGenero =3 then	--- Mujer - Viudo 8	
				LET ESTADO_CIVIL_VAR_INT = 10;
			END IF;						
		ELSE
				LET ESTADO_CIVIL_VAR_INT = 11;	 --Cualquier otro
		END IF;

 	---------------- VI Residencia & Tiempo Residencia => Gpo 60
	/*																					Tipo de Residencia											60	6		'De Familiar ~ Cualquier otro caso'
	Tipo residencia -- Tiempo residencia								5	Propia                                                   	60	7		'De Familiar ~ <=2'
	TIPO RESIDENCIA		TMPO DOM ACT                          	6	Con Hipoteca (incluye INFONAVIT)           	60	8		'De Familiar ~ >2 y <=19'
	De Familiar                                                                	7	De Familiar                                            	60	9		'De Familiar ~ >19 y <=22'
	Cualquier otro caso  40                                               	8	Rentada                                                 	60	10	'De Familiar ~ >22' 
		<= 2					40                                                 	9	HuÃ¿Â©sped                                                	60	11	'Propia ~ Cualquier otro caso'
		>2 y <=19		45                                                 	10	Prestada                                            	60	12	'Propia ~ <=3'
		>19 y <=22		46                                                                                                                     	60	13	'Propia ~ >3 y <=19'
		> 22					49                                                                                                                     	60	14	'Propia ~ >19 y <=24'
	Propia                                                                                                                                           	60	15	'Propia ~ >24 y <=30'
	Cualquier otro caso  40                                                                                                                   	60	16	'Propia ~ >30'
		<= 3					  40                                                                                                                   	60	17	'Rentada ~ Cualquier otro caso'
		>3 y <=19		  48                                                                                                                   	60	18	'Rentada ~ <= 5'
		>19 <=24			  49                                                                                                                   	60	19	'Rentada ~ >5'
		>24 y <=30		  52                                                                                                                   	60	20	'Prestada Con Hipoteca (incluye INFONAVIT) ~ '
		> 30					  54                                                                                                                   	60	21	'Cualquier otro caso'
	Rentada
	Cualquier otro caso	43
		<= 5						43
		> 5						44
	Prestada Con Hipoteca (incluye INFONAVIT)	47
	Cualquier otro caso	40*/
	

    SELECT TRIM(substr(ele.descripcion,1,2)) INTO vtmpo_Residencia 
	FROM bdisolic:ss_detalle_scoring det
	INNER JOIN BDISOLIC: ss_scoring_element ele on  ele.elemento = det.elemento and det.grupo = ele.grupo
	WHERE det.empresa = o_empresa AND det.num_solicitud = o_numsolicitud AND det.grupo = 6 and ele.seccion = 2;

	SELECT nvl(elemento,0) INTO vTipo_Residencia FROM bdisolic:ss_detalle_scoring WHERE empresa = o_empresa AND num_solicitud = o_numsolicitud AND grupo = 5;
	
	
	

	 -- Familiar <= 2 OR Familiar >2 y <=19 OR Familiar >19 y <=22 OR Familiar > 22  
	IF vTipo_Residencia = 7  THEN 
			IF vtmpo_Residencia <= 2 THEN 
					LET VI_TpResid_TmpResid = 7;	
			ELIF (vtmpo_Residencia > 2 AND vtmpo_Residencia <=19) THEN
				LET VI_TpResid_TmpResid = 8;	
			ELIF (vtmpo_Residencia > 19 AND vtmpo_Residencia <=22) THEN
				LET VI_TpResid_TmpResid = 9;	
			ELIF vtmpo_Residencia > 22 THEN 
				LET VI_TpResid_TmpResid = 10;	
			ELSE
				LET VI_TpResid_TmpResid = 6;	
			END IF;
	-- Propia <= 3 OR Propia & >3 y <=19 OR Propia & >19 <=24 OR Propia >24 y <=30 OR Propia > 30
	ELIF vTipo_Residencia = 5  THEN
			IF vtmpo_Residencia <= 3 THEN 
				LET VI_TpResid_TmpResid = 12;	
			ELIF (vtmpo_Residencia > 3 AND vtmpo_Residencia <=19) THEN
				LET VI_TpResid_TmpResid = 13;	
			ELIF (vtmpo_Residencia > 19 AND vtmpo_Residencia <=24) THEN
				LET VI_TpResid_TmpResid = 14;	
			ELIF (vtmpo_Residencia > 24 AND vtmpo_Residencia <=30) THEN
				LET VI_TpResid_TmpResid = 15;					
			ELIF vtmpo_Residencia > 30 THEN 
				LET VI_TpResid_TmpResid = 16;	
			ELSE
				LET VI_TpResid_TmpResid = 11;	
			END IF;	
	-- Rentada & <= 5 OR Rentada > 5		
	ELIF vTipo_Residencia = 8 THEN
			IF vtmpo_Residencia <= 5 THEN 
				LET VI_TpResid_TmpResid = 18;	
			ELIF vtmpo_Residencia > 5 THEN 
				LET VI_TpResid_TmpResid = 19;	
			ELSE
				LET VI_TpResid_TmpResid = 17;	-- Mismo puntaje cualquier otro al de <=5
			END IF;	
	--Prestada Con Hipoteca (incluye INFONAVIT)	47		
	ELIF (vTipo_Residencia = 6 OR vTipo_Residencia = 10 ) THEN
			LET VI_TpResid_TmpResid = 20;	
	ELSE
		LET VI_TpResid_TmpResid = 21; --Cualquier otro caso		40
	END IF;	 
	

      --ESTADO  	---------------- VEstado => Gpo 69
      /*
      estado_inegi     nombre_inegi                   			  Cuentas <= 3
      ---------------  ------------------------------            	  Estado
      00               SIN DATO                                     		ZACATECAS AGUASCALIENTES  36
      01               AGUSCALIENTES                           		SAN LUIS POTOSI TAMAULIPAS GUANAJUATO 34
      02               BAJA CALIFORNIA                          		OAXACA HIDALGO MICHOACAN PUEBLA GUERRERO 32 
      03               BAJA CALIFORNIA SUR                   		QUERETARO TLAXCALA NAYARIT YUCATAN BAJA CALIFORNIA NORTE MORELOS VERACRUZ CHIHUAHUA SINALOA 31 
      04               CAMPECHE                                    		NUEVO LEON COAHUILA JALISCO SONORA CAMPECHE CHIAPAS DURANGO QUINTANA ROO COLIMA 29
      05               COAHUILA DE ZARAGOZA              		BAJA CALIFORNIA SUR ESTADO DE MEXICO TABASCO 24
      06               COLIMA                                        		CIUDAD DE MEXICO 17
      07               CHIAPAS                                       		Cualquier otro caso 31 
      08               CHIHUAHUA                                  	  Cuentas <= 3
      09               DISTRITO FEDERAL                        		ESTADO 
      10               DURANGO                                     		COLIMA NUEVO LEON NAYARIT SINALOA TAMAULIPAS BAJA CALIFORNIA NORTE CHIHUAHUA GUANAJUATO JALISCO SONORA  32
      11               GUANAJUATO                                		ZACATECAS HIDALGO COAHUILA AGUASCALIENTES 30
      12               GUERRERO                                    		VERACRUZ BAJA CALIFORNIA SUR OAXACA DURANGO MICHOACAN MORELOS PUEBLA SAN LUIS POTOSI QUINTANA ROO 28
      13               HIDALGO                                      		GUERRERO QUERETARO TLAXCALA YUCATAN CHIAPAS TABASCO ESTADO DE MEXICO CAMPECHE  25
      14               JALISCO                                       		CIUDAD DE MEXICO 22
      15               MEXICO                                        		Cualquier otro caso  28	  
      16               MICHOACAN DE OCAMPO               	  
      17               MORELOS                                      	  Not hit
      18               NAYARIT                                       		  Estado
      19               NUEVO LEON                                 			AGUASCALIENTES GUANAJUATO QUERETARO SAN LUIS POTOSI TLAXCALA ZACATECAS  56
      20               OAXACA                                       			HIDALGO OAXACA PUEBLA  54
      21               PUEBLA                                         			GUERRERO MICHOACAN YUCATAN  52
      22               QUERETARO DE ARTEAGA              			NAYARIT TAMAULIPAS VERACRUZ  51
      23               QUINTANA ROO                             			CAMPECHE CHIAPAS COLIMA JALISCO MORELOS  48
      24               SAN LUIS POTOSI                          			ESTADO DE MEXICO  46
      25               SINALOA                                       			BAJA CALIFORNIA NORTE BAJA CALIFORNIA SUR DURANGO QUINTANA ROO SINALOA  43
      26               SONORA                                       			CHIHUAHUA COAHUILA NUEVO LEON TABASCO  40
      27               TABASCO                                      			CIUDAD DE MEXICO SONORA  36 
      28               TAMAULIPAS                                 			Cualquier otro caso  48
      29               TLAXCALA                                           
      30               VERACRUZ                       
      31               YUCATAN                        
      32               ZACATECAS                      
      00               SIN DATO         */
	
	SELECT elem.elemento, est.nombre
	INTO vEstado, cEntidad
	FROM bdinteg:si_direcciones_actual dir
	INNER JOIN bdinteg: si_estados est ON est.estado = dir.estado 
	INNER JOIN bdisolic: ss_scoring_element elem ON elem.descripcion = est.nombre
	WHERE dir.numcte = vNumcte AND dir.tipo_dir='1' AND grupo = 69;
	
	IF NVL(vEstado,0) = 0 THEN
		SELECT elem.elemento, est.nombre
		INTO vEstado, cEntidad
		FROM bdinteg:si_ctepf cpf
		INNER JOIN bdinteg:si_estados est ON est.estado = cpf.lugar_nac
		INNER JOIN bdisolic:ss_scoring_element elem ON elem.descripcion = est.nombre
		WHERE cpf.numcte = vNumcte and elem.grupo = 69;
	END IF;
	 
	IF NVL(vEstado,0) = 0 THEN
		LET vEstado = 33;
	END IF;
	 
    --SELECT elem.elemento INTO vEstado FROM bdisolic:ss_scoring_element elem
    -- WHERE elem.empresa =  '001' AND elem.grupo = 69 and elem.elemento =  vClvEdo;	 

-- VARIABLE: UT0034 Porcentaje de saldo de cuentas aperturadas en los Ã¿Âºltimos 36 meses. Grupo 51
		/*
		'Nulo (Clientes sin cuentas <=36m)'	'P'	51	15					    <= 3 cuentas																								> 3 cuentas
		'<=-4 '							'P'	51	16                                         	Porcentaje de saldo de cuentas aperturadas en los Ã¿Âºltimos 36 meses    Porcentaje de saldo de cuentas aperturadas en los Ã¿Âºltimos 36 meses
		'>-4 y <=-3 (LC=0)'		'P'	51	17                                         		Nulo (Clientes sin cuentas <=36m) 28                                            	Nulo (Clientes sin cuentas <=36m) 29
		'>-3 y <=-2 (LC nulo)'	'P'	51	18                                         		<=-4 28                                                                                       	<= -4 29
		'>-2 y <=0 (Sdo ctas=0)'	'P'	51	19                                     		>-4 y <=-3 (LC=0) 15                                                                   	> -4 y <=-3 (LC=0) 18 
		'>=0 y <=9'		'P'	51	20                                                     		>-3 y <=-2 (LC nulo) 17                                                                	> -3 y <=-2 (LC nulo) 18 
		'>9 y <=14'		'P'	51	21                                                     		>-2 y <=0 (Sdo ctas=0) 40                                                           	> -2 y <=-1 (Sdo ctas=0) 37
		'>14 y <=21'		'P'	51	22                                                     		>0 y <=9 41                                                                                	>=0 y <=1 41
		'>21 y <=30'		'P'	51	23                                                     		>9 y <=14 37                                                                               	>1 y <=9 39 
		'>30 y <=40'		'P'	51	24                                                     		>14 y <=21 34                                                                             	>9 y <=19 35
		'>40 y <=53'		'P'	51	25                                                     		>21 y <=30 31                                                                             	>19 y <=35 31
		'>53 y <=69'		'P'	51	26                                                     		>30 y <=40 28                                                                             	>35 y <=60 27
		'>69 y <=94'		'P'	51	27                                                     		>40 y <=53 23                                                                             	>60 y <=119 23
		'> 94'	1			'P'	51	28                                                     		>53 y <=69 20                                                                             	> 119 22
		'Cualquier otro caso'		'P'	51	29                                         		>69 y <=94 16                                                                             	Cualquier otro caso 18
		'>=0 y <=1'	 	'P'	51	30                                                     		> 94 14
		'>1 y <=9'	 	'P'	51	31                                                     		Cualquier otro caso 14
		'>9 y <=19'	 	'P'	51	32                                                     
		'>19 y <=35'	 	'P'	51	33
		'>35 y <=60'	 	'P'	51	34
		'>60 y <=119'	'P'	51	35
		'> 119'				'P'	51	36

		*/

     LET UT0034 = -999;
    LET ut0034_aux = 0;
    LET vSum_bal  = 0;
    LET vSum_higcred = 0;
	
	
	    Select Sum(rev_bal), sum(max_cred) INTO vSum_bal, vSum_higcred From (
        SELECT Sum( nvl(tl22,0)) rev_bal, Sum(tl23) max_cred
          FROM bdiburo:br_tl a
         WHERE num_cliente = vNumcte
           AND tl06 <> 'M'  
			AND tl13  > dfecha36m AND tl13 <=  pfechahoy
           GROUP BY TL06, TL13, TL23
		);
    
    IF (vSum_higcred IS NOT NULL) THEN 
        IF (vSum_higcred <= 0) THEN
            LET ut0034_aux = -993;		--(LC=0)
        ELSE
			IF vSum_bal > 0 THEN
				IF (TRUNC(((vSum_bal / vSum_higcred) * 100),0))>999999 Then
					LET UT0034 =999999.0;
				ELSE
					LET UT0034 =TRUNC(((vSum_bal / vSum_higcred) * 100),0);
				END IF;
			ELSE	
				LET ut0034_aux = -997;  --(Sdo ctas=0)
			END IF;
        END IF;
	ELSE
		LET ut0034_aux = -998;  --(LC nulo)
    END IF;
	
	
	IF ut0034_aux = -997  AND (vCuentasPF > 0 ) THEN          -- >-2 y <=0 (Sdo ctas=0)
        LET UT0034 = -1;
	ELIF ut0034_aux = -993  THEN  		-- >-4 y <=-3 (LC=0)
		 LET UT0034 = -3;
	ELIF ut0034_aux = -998  THEN   		-->-3 y <=-2 (LC nulo)
		LET UT0034 = -2;
    ELIF UT0034 IS NULL THEN
        LET UT0034 = -99999; -- Valor "Nulo"
	ELIF  UT0034 >= -99999 AND UT0034 <= -4  THEN
		LET UT0034 = -4; -- Valor Negativo	
	ELIF UT0034 = -99998 or UT0034 < -99999 THEN  
		LET UT0034 = -99998;  --Cualquier otro caso definido como -99998
	ELSE	
		LET UT0034 = UT0034;
    END IF;


	--Rangos Minimos y Maximos Fijos
		LET PorcRangfijoMin = 15;
		LET PorcRangofijoMax = 18;
	--Rangos Minimos y Maximos por modelo
		IF (vCuentasPF > 0 and vCuentasPF <= 3) THEN
			LET vScorePorcSdoMin = 19;
			LET vScorePorcSdoMax = 28;
		ELIF (vCuentasPF > 3)  THEN
			LET vScorePorcSdoMin = 30;
			LET vScorePorcSdoMax = 37;			
		END IF;	
	
	-- VI OCUPACION & TIEMPO OCUPACION ACTUAL - GRUPO 52
	
/*
52	-5	    'Pensionado/Jubilado - N/A'						No hit																				5	Migratorios 
52	-4	    'Ama de Casa - No aplica'                          	OCUPACIÃ¿Â¿N TMPO OCUP ACT                                         6	Desempleados
52	-3	    'Estudiante - No aplica'                          	Abogado o PolicÃ¿Â­a Judicial o Ministerial Estudiante 42              7	Abogado o PolicÃ¿Â­a Judicial o Ministerial 
52	-2	    'Missing'                           						Ama de casa 53                                                                 9	Profesionista independiente
52	-1	    'No aplica'                      					   	Empleado                                                                          10	Oficio independiente
52	1	    '0 aÃ¿Â±os'                          											<= 2 43                                                         11	Empleado 
52	2	    '1 aÃ¿Â±o'                          										>2 y <=3 45                                                      12	Ama de casa
52	3	    '2 aÃ¿Â±os'                          											>3 y <=9 47                                                  13	Eventuales
52	4	    '3 aÃ¿Â±os'                          											> 9 50                                                           14	TÃ¿Â©cnico
52	5	    '4 aÃ¿Â±os'                          						Negocio Propio                                                                   15	Estudiante
52	6	    '5 aÃ¿Â±os'                          											<= 4 41                                                         16	Negocio Propio 
52	7	    '6 aÃ¿Â±os'                          											>4 y <=14 46                                                17	Pensionado o Jubilado
52	8	    '7 aÃ¿Â±os'                          											> 14 51                                                         
52	9	    '8 aÃ¿Â±os'                          						Oficio independiente                                                           
52	10	'9 aÃ¿Â±os'                          											<= 3 45                                                        
52	11	'10 aÃ¿Â±os'                        					  						>3 y <=10 46                                                
52	12	'11 aÃ¿Â±os'                        					  						> 10 49                                                         
52	13	'12 aÃ¿Â±os'                        					  	Pensionado o Jubilado 56 
52	14	'13 aÃ¿Â±os'                        					  	Profesionista independiente 
52	15	'14 o mÃ¿Â¡s aÃ¿Â±os'                          								<= 7 42
52	16	'Abogado o PolicÃ¿Â­a Judicial o Ministeria'                         > 7 48
52	17	'Empleado ~ <=2'                           		Cualquier otro caso 41 
52	18	'Empleado ~ >2 y <=3'
52	19	'Empleado ~ >3 y <=9'
52	20	'Empleado ~ >9'
52	21	'Negocio Propio ~ <=4'
52	22	'Negocio Propio ~ >4 y <=14'
52	23	'Negocio Propio ~ >14'
52	24	'Oficio independiente ~ <=3'
52	25	'Oficio independiente ~ >3 y <=10'
52	26	'Oficio independiente ~ >10'
52	27	'Profesionista independiente ~ <=7'
52	28	'Profesionista independiente ~ >7'		

*/	
    LET vVI_Ocup_TmpOcup = -50;

    -- Obtiene los datos del cliente: Ocupacion y Tiempo Ocupacion Actual
    SELECT elemento INTO vOcupacion FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' AND num_solicitud = o_numsolicitud AND grupo = 7;
    SELECT elemento INTO vElem_TmpOcupacion FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' and num_solicitud = o_numsolicitud AND grupo = 8;
    -- Obtiene el numero de aÃ¿Â¿Ã¿Â±os
    SELECT elem.rango_minimo INTO vTmpOcupacion FROM bdisolic:ss_detalle_scoring det, bdisolic:ss_scoring_element elem
     WHERE det.empresa = elem.empresa and det.num_solicitud = o_numsolicitud AND det.grupo = elem.grupo and det.elemento = elem.elemento AND det.grupo = 8;

	-- Asigna elemento para Estudiante, Abogado o PolicÃ¿Â­a Judicial o Ministerial, Ama de Casa, y Pensionado/Jubilado.
    IF (vOcupacion = 15 OR vOcupacion = 7 )THEN -- Si es estudiante (15) Ã¿Â² Abogado o PolicÃ¿Â­a Judicial o Ministerial(7) y tiempo = No aplica
		IF  vOcupacion = 15 THEN 
			LET vVI_Ocup_TmpOcup = -3;
		ELSE
			LET vVI_Ocup_TmpOcup = 16;
		END IF;
    ELIF vOcupacion = 12  THEN -- Si es ama de casa (12) y tiempo = No aplica
        LET vVI_Ocup_TmpOcup = -4;
	ELIF vOcupacion = 17 THEN -- Si es Pensionado o Jubilado (17) y tiempo = No aplica
        LET vVI_Ocup_TmpOcup = -5;
    ELIF vOcupacion = 11 THEN
		IF vTmpOcupacion <= 2 THEN -- Si es Empleado (11) y <= 2 aÃ¿Â±os empleado
			LET vVI_Ocup_TmpOcup = 17;
		ELIF vTmpOcupacion = 3 THEN -- Si es Empleado (11) y = 3 aÃ¿Â±os empleado
			LET vVI_Ocup_TmpOcup = 18;
		ELIF vTmpOcupacion >=4 AND vTmpOcupacion <=9 THEN -- Si es Empleado (11) y >= 4  AND <= 9 aÃ¿Â±os empleado
			LET vVI_Ocup_TmpOcup = 19;
		ELIF vTmpOcupacion > 9 THEN -- Si es Empleado (11) y > 9 aÃ¿Â±os empleado
			LET vVI_Ocup_TmpOcup = 20;
		END IF;		
	ELIF vOcupacion = 16 THEN -- Si es Negocio Propio (16)
		IF vTmpOcupacion <= 4 THEN -- Si es <= 4 aÃ¿Â±os Negocio Propio
			LET vVI_Ocup_TmpOcup = 21;
		ELIF vTmpOcupacion >=5 AND vTmpOcupacion <=14 THEN -- Si es 5 a 14 aÃ¿Â±os Negocio Propio
			LET vVI_Ocup_TmpOcup = 22;
		ELIF vTmpOcupacion > 14 THEN -- Si es >	14 aÃ¿Â±os Negocio Propio
			LET vVI_Ocup_TmpOcup = 23;
		END IF;		
	ELIF vOcupacion = 10 THEN -- Si es oficio independiente (10)	
		IF vTmpOcupacion <= 3 THEN -- Si es <= 3 aÃ¿Â±os oficio independiente
			LET vVI_Ocup_TmpOcup = 24;
		ELIF vTmpOcupacion >=4 AND vTmpOcupacion <=10 THEN --  4 a 10 aÃ¿Â±os oficio independiente
			LET vVI_Ocup_TmpOcup = 25;
		ELIF vTmpOcupacion > 10 THEN -- Si es > 10 aÃ¿Â±os oficio independiente	
			LET vVI_Ocup_TmpOcup = 26;
		END IF;		
	ELIF vOcupacion = 9 THEN -- Si es profesionista independiente (9)
		IF vTmpOcupacion <= 7 THEN -- Si es <= 7 aÃ¿Â±os profesionista independiente
			LET vVI_Ocup_TmpOcup = 27;
		ELIF vTmpOcupacion > 7 THEN -- Si es > 7 aÃ¿Â±os profesionista independiente	
			LET vVI_Ocup_TmpOcup = 28;
		END IF;		
    ELIF vElem_TmpOcupacion = 88 THEN -- Si es OTRO y tiempo = No aplica, se asigna No aplica
        LET vVI_Ocup_TmpOcup = -1;
    ELIF vElem_TmpOcupacion <= 2 THEN -- Si es OTRO y tiempo = No aplica, se asigna No aplica
        LET vVI_Ocup_TmpOcup = -1;		
    ELIF vOcupacion IS NULL OR vElem_TmpOcupacion IS NULL THEN -- Si alguno de los datos es nulo, asigna valor: missing
        LET vVI_Ocup_TmpOcup = -2;
	ELSE
		LET vVI_Ocup_TmpOcup = -2; -- No se asigno valor, se asignarÃ¿Â¿Ã¿Â¡ valor missing
    END IF;
	
    IF vVI_Ocup_TmpOcup = -50 THEN -- No se asigno valor, se asignarÃ¿Â¿Ã¿Â¡ valor missing
        LET vVI_Ocup_TmpOcup = -2;
    END IF;	  

      --Varibales Coppel  
	/* 	--Cuentas <= 3 pagos	  				--Cuentas <= 3 pagos			--No hit
	    Mora actual                          			MORA ACTUAL                      	 Mora actual    						
	    	No cliente Coppel 26         				<= -1 (Abono = 0) 28          	No cliente Coppel 45 	    
	    	<= -1 30                         			  	>-1 y <=0 31                       	-1 45 	    
	    	>-1 y <=0 31                   	         	>0 y <=53 28                     	0 50	   
	    	>0 y <=54 26                  	          	> 53 23                                	>0 y <=27 48	   
	    	> 54 21                           	         	No cliente Coppel 22            	>27 y <=58 47	    
	    	Cualquier otro caso 21      	          	Cualquier otro caso 22         	>58 y <=93 45	   
                                                                                                        	>93 y <=130 44	   
			                                                                                               	> 130 40	     
			                                                                                             	Cualquier otro caso 40	   
	*/
      --Mora actual		78
       IF(vMorAct IS NOT NULL) THEN 
			--Rango de Elementos segÃ¿Âºn el modelo
			IF (vCuentasPF > 0 and vCuentasPF <= 3) THEN
				IF vMorAct <= -1 THEN
					LET vScoreMorActMin = 2;
					LET vScoreMorActMax = 2;					
				ELIF vMorAct =0 THEN
					LET vScoreMorActMin = 3;
					LET vScoreMorActMax = 3;
				ELIF vMorAct > 0 AND  vMorAct <= 54 THEN 
					LET vScoreMorActMin = 4;
					LET vScoreMorActMax = 4;			
				ELIF  vMorAct > 54 THEN 
					LET vScoreMorActMin = 5;
					LET vScoreMorActMax = 5;		
				END IF;
			ELIF (vCuentasPF > 3)  THEN
				IF vMorAct <= -1 THEN
					LET vScoreMorActMin = 7;
					LET vScoreMorActMax = 7;					
				ELIF vMorAct =0 THEN
					LET vScoreMorActMin = 3;
					LET vScoreMorActMax = 3;
				ELIF vMorAct > 0 AND  vMorAct <= 53 THEN 
					LET vScoreMorActMin = 8;
					LET vScoreMorActMax = 8;			
				ELIF  vMorAct > 53 THEN 
					LET vScoreMorActMin = 9;
					LET vScoreMorActMax = 9;		
				END IF;				
			ELIF pSIC='X' THEN --NoHit
				IF vMorAct <= -1 THEN
					LET vScoreMorActMin = 10;
					LET vScoreMorActMax = 10;					
				ELIF vMorAct =0 THEN
					LET vScoreMorActMin = 11;
					LET vScoreMorActMax = 11;
				ELIF vMorAct > 0 AND  vMorAct <= 27 THEN 
					LET vScoreMorActMin = 12;
					LET vScoreMorActMax = 12;			
				ELIF  vMorAct > 27  AND  vMorAct <= 58 THEN 
					LET vScoreMorActMin = 13;
					LET vScoreMorActMax = 13;		
				ELIF  vMorAct > 58  AND  vMorAct <= 93 THEN 		
					LET vScoreMorActMin = 14;
					LET vScoreMorActMax = 14;					
				ELIF  vMorAct > 93  AND  vMorAct <= 130 THEN 	
					LET vScoreMorActMin = 15;
					LET vScoreMorActMax = 15;					
				ELIF  vMorAct > 130 THEN 	
					LET vScoreMorActMin = 16;
					LET vScoreMorActMax = 16;	
				END IF;					
			END IF;			
      ELSE
			IF vMorAct is null THEN
				LET vMorAct = -99999;			--Nulo 
				LET vScoreMorActMin = 1;
				LET vScoreMorActMax = 1;
			ELSE 
				LET vMorAct = -99998; --Cualquier otro caso
				LET vScoreMorActMin = 6;
				LET vScoreMorActMax = 6;				
			END IF;
      END IF;	  

      --Eficiencia Ã¿Â¿ltimo Semestre	Grupo 77		

		/*		--Cuentas <= 3 pagos	  					--Cuentas > 3 pagos									--No hit
		        Eficiencia Ã¿Â¿ltimo Semestre	                	EFICIENCIA Ã¿Â¿LTIMO SEMESTRE			         Eficiencia Ã¿Âºltimo semestre
		        	No cliente Coppel 25                       	<= -1 (Abonos Ã¿Âºltimo semestre =0) 2            	No cliente Coppel 40 
		        	<= -1 27                                       	>-1 y <=76 25                                             	<=-1 37 
		        	>-1 y <=73 14                                	>76 y <=96 27                                           	>=0 y <=66 28
		        	>73 y <=94 22                              	> 96 29                                                      	>66 y <=82 39
		        	>94 y <=200 31                              	No cliente Coppel 25                                    	>82 y <=96 46 
		        	>200 y <=363 32                           	Cualquier otro caso 25                                 	>96 y <=206 54
		        	> 363 42                                                                                                            	>206 y <=349 56
		        	Cualquier otro caso 14                                                                                         	> 349 69
		                                                                                                                                 	   Cualquier otro caso 28	*/ 

       IF(vEficUltSem IS NOT NULL) THEN 
			--Rango de Elementos segÃ¿Âºn el modelo
			IF (vCuentasPF > 0 and vCuentasPF <= 3) THEN
				IF  vEficUltSem <= -1 THEN
					LET vScoreEficUltSemMin = 2;
					LET vScoreEficUltSemMax = 2;
				ELSE
					LET vScoreEficUltSemMin = 3;
					LET vScoreEficUltSemMax = 7;
				END IF;
			ELIF (vCuentasPF > 3)  THEN
				LET vScoreEficUltSemMin = 9;
				LET vScoreEficUltSemMax = 12;			
			ELIF pSIC='X' THEN --NoHit
				IF  vEficUltSem <= -1 THEN
					LET vScoreEficUltSemMin = 2;
					LET vScoreEficUltSemMax = 2;
				ELSE			
					LET vScoreEficUltSemMin = 13;
					LET vScoreEficUltSemMax = 18;	
				END IF;	
			END IF;
			
      ELSE
			IF vEficUltSem is null THEN
				LET vEficUltSem = -99999;			--Nulo 
				LET vScoreEficUltSemMin = 1;
				LET vScoreEficUltSemMax = 1;
			ELSE 
				LET vEficUltSem = -99998; --Cualquier otro caso
				LET vScoreEficUltSemMin = 8;
				LET vScoreEficUltSemMax = 8;				
			END IF;
      END IF;
	  
	  	  --71-'Meses y monto de la fecha de morosidad mÃ¿Â¡s grave mÃ¿Â¡s reciente'

	  ---------------------------------------------------------------------- JESUS 
	IF vMesesMorHistAltaTL37 IS NOT NULL AND vSaldoMorHistAltaTL36 IS NOT NULL THEN
		IF(vCuentasPF > 0 and vCuentasPF <= 3) THEN
			IF vMesesMorHistAltaTL37 < 2 THEN
				IF vSaldoMorHistAltaTL36 <= 0 THEN
					LET vMesesyMonto = 2;
				ELIF vSaldoMorHistAltaTL36 > 0 AND vSaldoMorHistAltaTL36 <= 468 THEN
					LET vMesesyMonto = 3;
				ELIF vSaldoMorHistAltaTL36 >468 THEN
					LET vMesesyMonto = 4;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 5;
				END IF;
			ELIF vMesesMorHistAltaTL37 >=2 AND vMesesMorHistAltaTL37 <3 THEN 
				IF vSaldoMorHistAltaTL36 <= 179 THEN
					LET vMesesyMonto = 6;
				ELIF vSaldoMorHistAltaTL36 > 179 THEN
					LET vMesesyMonto	=7;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 8;
				END IF;
			ELIF vMesesMorHistAltaTL37 >=3 AND vMesesMorHistAltaTL37 <5 THEN
				IF vSaldoMorHistAltaTL36 <= 300 THEN
					LET vMesesyMonto = 9;
				ELIF vSaldoMorHistAltaTL36 > 300 THEN 
					LET vMesesyMonto = 10;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN 
					LET vMesesyMonto = 11;
				END IF;
			ELIF vMesesMorHistAltaTL37 >=5 AND vMesesMorHistAltaTL37 <8 THEN
				IF vSaldoMorHistAltaTL36 <= 179 THEN
					LET vMesesyMonto = 12;
				ELIF vSaldoMorHistAltaTL36 >179 AND vSaldoMorHistAltaTL36 <= 468 THEN
					LET vMesesyMonto = 13;
				ELIF vSaldoMorHistAltaTL36 > 468 THEN
					LET vMesesyMonto = 14;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 15;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 8 AND vMesesMorHistAltaTL37 < 10 THEN
				IF vSaldoMorHistAltaTL36 <= 468 THEN
					LET vMesesyMonto = 16;
				ELIF vSaldoMorHistAltaTL36 > 468 THEN
					LET vMesesyMonto = 17;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vSaldoMorHistAltaTL36 = 18;
				END IF;
			ELIF vMesesMorHistAltaTL37 >=10 AND vMesesMorHistAltaTL37 < 13 THEN
				IF vSaldoMorHistAltaTL36 <= 179 THEN
					LET vMesesyMonto = 19;
				ELIF vSaldoMorHistAltaTL36 >179 THEN
					LET vMesesyMonto = 20;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN 
					LET vMesesyMonto = 21;
				END IF;
			ELIF vMesesMorHistAltaTL37 >=13 AND vMesesMorHistAltaTL37 < 19 THEN
				IF vSaldoMorHistAltaTL36 <= 179 THEN
					LET vMesesyMonto = 22;
				ELIF vSaldoMorHistAltaTL36 > 179 AND vSaldoMorHistAltaTL36 <= 468 THEN
					LET vMesesyMonto = 23;
				ELIF vSaldoMorHistAltaTL36 > 468 THEN
					LET vMesesyMonto = 24;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 25;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 19 AND vMesesMorHistAltaTL37 < 45 THEN
				IF vSaldoMorHistAltaTL36 <= 11 THEN
					LET vMesesyMonto = 26;
				ELIF vSaldoMorHistAltaTL36 >11 AND vSaldoMorHistAltaTL36 <= 468 THEN
					LET vMesesyMonto = 27;
				ELIF vSaldoMorHistAltaTL36 > 468 AND vSaldoMorHistAltaTL36 <= 1273 THEN
					LET vMesesyMonto = 28;
				ELIF vSaldoMorHistAltaTL36 > 1273 THEN 
					LET vMesesyMonto = 29;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 30;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 45 THEN 
				IF vSaldoMorHistAltaTL36 <= 0 THEN
					LET vMesesyMonto = 31;
				ELIF vSaldoMorHistAltaTL36 >0 AND vSaldoMorHistAltaTL36 <=720 THEN
					LET vMesesyMonto = 32;
				ELIF vSaldoMorHistAltaTL36 > 720 THEN
					LET vMesesyMonto = 33;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 34;
				END IF;
			END IF;
		ELIF(vCuentasPF >3) THEN
			IF vMesesMorHistAltaTL37 < 2 THEN
				IF  vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 5;
				ELIF vSaldoMorHistAltaTL36 <= 49 THEN 
					LET vMesesyMonto = 35;
				ELIF vSaldoMorHistAltaTL36 >49 AND vSaldoMorHistAltaTL36 <=573 THEN
					LET vMesesyMonto = 36;
				ELIF vSaldoMorHistAltaTL36 > 573 THEN 
					LET vMesesyMonto = 37;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 2 AND vMesesMorHistAltaTL37 < 3 THEN
				IF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 8;
				ELIF vSaldoMorHistAltaTL36 <= 388 THEN 
					LET vMesesyMonto = 38;	
				ELIF vSaldoMorHistAltaTL36 > 388 THEN 
					LET vMesesyMonto = 39;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 3 AND vMesesMorHistAltaTL37 < 5  THEN
				IF vSaldoMorHistAltaTL36 IS NULL THEN 
					LET vMesesyMonto = 11;
				ELIF vSaldoMorHistAltaTL36 <= 49 THEN 
					LET vMesesyMonto = 40;	
				ELIF vSaldoMorHistAltaTL36 > 49 AND vSaldoMorHistAltaTL36 <= 256 THEN 
					LET vMesesyMonto = 41;
				ELIF vSaldoMorHistAltaTL36 > 256 AND vSaldoMorHistAltaTL36 <=573 THEN
					LET vMesesyMonto = 42;
				ELIF vSaldoMorHistAltaTL36 > 573 THEN
					LET vMesesyMonto = 43;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 5 AND vMesesMorHistAltaTL37 < 7 THEN
				IF vSaldoMorHistAltaTL36 <=388 THEN
					LET vMesesyMonto = 44;
				ELIF vSaldoMorHistAltaTL36 >388 THEN
					LET vMesesyMonto = 45; 
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN 
					LET vMesesyMonto = 46;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 7 AND vMesesMorHistAltaTL37 < 10  THEN
				IF vSaldoMorHistAltaTL36 <= 49 THEN
					LET vMesesyMonto = 47;
				ELIF vSaldoMorHistAltaTL36 >49 AND vSaldoMorHistAltaTL36 <= 388 THEN
					LET vMesesyMonto = 48;
				ELIF vSaldoMorHistAltaTL36 > 388 THEN
					LET vMesesyMonto = 49;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 50;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 10 AND vMesesMorHistAltaTL37 < 14 THEN
				IF vSaldoMorHistAltaTL36 <= 164 THEN
					LET vMesesyMonto = 51;
				ELIF vSaldoMorHistAltaTL36 >164 AND vSaldoMorHistAltaTL36 <= 573 THEN
					LET vMesesyMonto = 52;
				ELIF vSaldoMorHistAltaTL36 > 573 THEN 
					LET vMesesyMonto =53;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN 
					LET vMesesyMonto = 54;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 14 AND vMesesMorHistAltaTL37 < 19 THEN 
				IF vSaldoMorHistAltaTL36 <= 256 THEN
					LET vMesesyMonto = 55; 
				ELIF vSaldoMorHistAltaTL36 > 256 THEN
					LET vMesesyMonto = 56;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN
					LET vMesesyMonto = 57;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 19 AND vMesesMorHistAltaTL37 < 46 THEN
				IF vSaldoMorHistAltaTL36 <= 49 THEN
					LET vMesesyMonto = 58;
				ELIF vSaldoMorHistAltaTL36 >49 AND vSaldoMorHistAltaTL36 <= 256 THEN
					LET vMesesyMonto = 59;
				ELIF vSaldoMorHistAltaTL36 >256 AND vSaldoMorHistAltaTL36 <= 573 THEN
					LET vMesesyMonto = 60;
				ELIF vSaldoMorHistAltaTL36 > 573 THEN 
					LET vMesesyMonto = 61;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN 
					LET vMesesyMonto = 62;
				END IF;
			ELIF vMesesMorHistAltaTL37 >= 46 THEN
				IF vSaldoMorHistAltaTL36 <= 388 THEN 
					LET vMesesyMonto = 63;
				ELIF vSaldoMorHistAltaTL36 > 388 THEN
					LET vMesesyMonto = 64;
				ELIF vSaldoMorHistAltaTL36 IS NULL THEN 
					LET vMesesyMonto = 65;
				END IF;
			END IF;
		END IF;
	ELSE 
		IF vMesesMorHistAltaTL37 IS NULL AND vSaldoMorHistAltaTL36 IS NULL THEN
				LET vMesesyMonto = 1;
		ELSE 
				LET vMesesyMonto = 66;
		END IF;		
	END IF;
	
	--73 'MÃ¿Â¡ximo plazo en dÃ¿Â­as'
	IF (vMaxPlazoDias IS NOT NULL) THEN
		IF	(vCuentasPF > 0 AND vCuentasPF <=3) THEN 
			LET vScorePlazoDiasMin = 1;
			LET vScorePlazoDiasMax = 4;
		ELIF (vCuentasPF > 3) THEN 
			LET vScorePlazoDiasMin = 7;
			LET vScorePlazoDiasMax = 9;
		END IF;
	ELSE 
		IF vMaxPlazoDias IS NULL THEN
			IF	(vCuentasPF > 0 AND vCuentasPF <=3) THEN 
				LET vMaxPlazoDias = -1;		--Nulo cuentas <=3
				LET vScorePlazoDiasMin = 5;
				LET vScorePlazoDiasMax = 5;
			ELIF (vCuentasPF > 3) THEN 
				LET vMaxPlazoDias = -1;	--Nulo cuentas > 3
				LET vScorePlazoDiasMin = 10;
				LET vScorePlazoDiasMax = 10;
			END IF;
		ELSE 
			LET vScorePlazoDiasMin = 6;	--Cualquier otro caso
			LET vScorePlazoDiasMax = 6;
		END IF;
	END IF;
	-- 72 - 'Porcentaje de cuentas con 30 o mÃ¿Â¡s dÃ¿Â­as de atraso'
	IF (vPorcCta30oMasDias IS NOT NULL) THEN
		IF (vCuentasPF > 0 AND vCuentasPF <=3) THEN
			LET vScorePorcjCta30oMasDiasMin = 1;
			LET vScorePorcjCta30oMasDiasMax = 9;
		ELIF (vCuentasPF > 3) THEN
			LET vScorePorcjCta30oMasDiasMin = 11;
			LET vScorePorcjCta30oMasDiasMax = 18;
			if vPorcCta30oMasDias <= -2 then
				LET vScorePorcjCta30oMasDiasMin = 1;
				LET vScorePorcjCta30oMasDiasMax = 1;
			END IF;
		END IF;
	ELSE
		IF vPorcCta30oMasDias IS NULL THEN 
			LET vPorcCta30oMasDias = -1;
			LET vScorePorcjCta30oMasDiasMin= 19;
			LET vScorePorcjCta30oMasDiasMax= 19;
		ELSE 
			LET vPorcCta30oMasDias = 0;
			LET vScorePorcjCta30oMasDiasMin= 10;
			LET vScorePorcjCta30oMasDiasMax= 10;
		END IF;
	END IF;
			
	-- 74 -'Ratio nÃ¿Âºmero de consultas en los Ã¿Âºltimos 3 meses entre nÃ¿Âºmero de consultas de los Ã¿Âºltimos 12 meses'		
	IF IQ00012 IS NULL OR IQ00012 = 0 THEN 
		LET vRatioConsUlt3M12M = -1;
	ELSE
		LET vRatioConsUlt3M12M = TRUNC((IQ0002 / IQ00012 * 100),0);
	END IF;
	
	
	IF vRatioConsUlt3M12M IS NOT NULL THEN 
		IF vRatioConsUlt3M12M <= -1 THEN
			LET vRatioConsUlt3M12M = -99997;
			LET vScoreRatioCon3MMin = 1;
			LET vScoreRatioCon3MMax = 1;
		ELSE
			LET vScoreRatioCon3MMin = 2;
			LET vScoreRatioCon3MMax = 5;
		END IF;
	ELSE
		IF vRatioConsUlt3M12M IS NULL THEN
			LET vRatioConsUlt3M12M = -99999;
			LET vScoreRatioCon3MMin = 6;
			LET vScoreRatioCon3MMax = 6;
		ELSE
			LET vRatioConsUlt3M12M = -99998;		
			LET vScoreRatioCon3MMin = 7;
			LET vScoreRatioCon3MMax = 7;
		END IF;
	END IF;
	
	SELECT COUNT(TL02) INTO vNumVecesBANCOPPEL FROM bdiburo:br_tl WHERE  num_cliente = vNumcte AND  TL02 = 'BANCOPPEL';
    SELECT COUNT(TL02) INTO vNumVecesTiendaComercial FROM bdiburo:br_tl WHERE  num_cliente = vNumcte AND  TL02 in ( 'TIENDA COMERCIAL', 'TIENDACOMERCIAL0');
	
	-- 75 - 'PRODUCTO BANCOPPEL-TIENDA COMERCIAL'
	IF vNumVecesBANCOPPEL IS NOT NULL AND vNumVecesTiendaComercial IS NOT NULL THEN
		IF vNumVecesBANCOPPEL <= 0 THEN
			IF vNumVecesTiendaComercial <= 2 THEN
				LET vBanCoppelTiendaComercial = 1;
			ELIF vNumVecesTiendaComercial > 2 AND vNumVecesTiendaComercial <= 5 THEN
				LET vBanCoppelTiendaComercial = 2;
			ELIF vNumVecesTiendaComercial > 5 AND vNumVecesTiendaComercial <= 9 THEN
				LET vBanCoppelTiendaComercial = 3;
			ELIF vNumVecesTiendaComercial > 9 THEN 
				LET vBanCoppelTiendaComercial = 4;
			END IF;
		ELIF vNumVecesBANCOPPEL > 0 AND vNumVecesBANCOPPEL <= 1 THEN
			IF vNumVecesTiendaComercial <= 0 THEN
				LET vBanCoppelTiendaComercial =  5;
			ELIF vNumVecesTiendaComercial >0 AND vNumVecesTiendaComercial <= 5 THEN	
				LET vBanCoppelTiendaComercial =  6;
			ELIF vNumVecesTiendaComercial > 5 AND vNumVecesTiendaComercial <= 7 THEN
				LET vBanCoppelTiendaComercial = 7;
			ELIF vNumVecesTiendaComercial > 7 AND vNumVecesTiendaComercial <= 15 THEN
				LET vBanCoppelTiendaComercial = 8;
			ELIF vNumVecesTiendaComercial > 15 THEN 
				LET vBanCoppelTiendaComercial = 9;
			END IF;
		ELIF vNumVecesBANCOPPEL > 1 AND vNumVecesBANCOPPEL <= 2 THEN
			IF vNumVecesTiendaComercial <= 5 THEN
				LET vBanCoppelTiendaComercial = 10;
			ELIF vNumVecesTiendaComercial > 5 THEN
				LET vBanCoppelTiendaComercial = 11;
			END IF;
		ELIF vNumVecesBANCOPPEL > 2 AND vNumVecesBANCOPPEL <= 3 THEN
			IF vNumVecesTiendaComercial <= 5 THEN
				LET vBanCoppelTiendaComercial = 12;
			ELIF vNumVecesTiendaComercial > 5 and vNumVecesTiendaComercial <= 9 THEN 
				LET vBanCoppelTiendaComercial =  13;
			ELIF vNumVecesTiendaComercial > 9 THEN
				LET vBanCoppelTiendaComercial = 14;
			END IF;
		ELIF vNumVecesBANCOPPEL > 3 AND vNumVecesBANCOPPEL <= 5 THEN 
			IF vNumVecesTiendaComercial <= 3 THEN 
				LET vBanCoppelTiendaComercial =  15;
			ELIF vNumVecesTiendaComercial > 3 AND vNumVecesTiendaComercial <= 7 THEN
				LET vBanCoppelTiendaComercial = 16;
			ELIF vNumVecesTiendaComercial > 7 THEN
				LET vBanCoppelTiendaComercial = 17;
			END IF;
		ELIF vNumVecesBANCOPPEL > 5 THEN 
			IF vNumVecesTiendaComercial <= 5 THEN
				LET vBanCoppelTiendaComercial =  18;
			ELIF vNumVecesTiendaComercial > 5 THEN 
				LET vBanCoppelTiendaComercial = 19;
			END IF;
		END IF;
	ELSE
		LET vBanCoppelTiendaComercial = 20;
	END IF;
	
	/*Select TRUNC(AVG(months_between(pfechahoy,TL13))) INTO vPromAntigMesesCtaRepUlt3Meses FROM BDIBURO: "informix".BR_TL 
	WHERE NUM_CLIENTE = vNumcte AND months_between(pfechahoy,TL17) <= 3 AND months_between(pfechahoy,TL13) >= 0;
	--76 - 'Promedio de la antigÃ¿Â¼edad en meses de cuentas reportadas en los Ã¿Âºltimos 3 meses'
	*/
	
	SELECT COUNT(TL13) INTO vNumTotalCtasTL13 FROM BDIBURO: "informix".BR_TL WHERE NUM_CLIENTE = vNumcte AND months_between(pfechahoy,TL17) < 4 AND months_between(pfechahoy,TL13) >= 0;

	FOREACH
	Select trunc(months_between(pfechahoy,TL13)) INTO vMesesTL13 FROM BDIBURO: "informix".BR_TL 
	WHERE NUM_CLIENTE = vNumcte AND months_between(pfechahoy,TL17) < 4 AND months_between(pfechahoy,TL13) >= 0
	
	LET iSumaTL13 = iSumaTL13 + vMesesTL13;
	
	END FOREACH;
	
	IF (iSumaTL13 = 0)  THEN          
        LET vPromAntigMesesCtaRepUlt3Meses = null;
    ELSE 
    LET vPromAntigMesesCtaRepUlt3Meses = TRUNC(iSumaTL13/vNumTotalCtasTL13);
    END IF;
	
	IF vPromAntigMesesCtaRepUlt3Meses IS NOT NULL THEN 
		LET vPromAntMin = 1;
		LET vPromAntMax = 8;
	ELSE 
		IF vPromAntigMesesCtaRepUlt3Meses IS NULL THEN 
			LET vPromAntigMesesCtaRepUlt3Meses = -99999;
			LET vPromAntMin = 9;
			LET vPromAntMax = 9;
		ELSE
			LET vPromAntigMesesCtaRepUlt3Meses = -99998;
			LET vPromAntMin = 10;
			LET vPromAntMax = 10;
		END IF; 
	END IF;
		  

      --PUNTUALIDAD   80																											<= 3 cuentas							> a 3 cuentas					No Hit
      /*																																		 PUNTUALIDAD                     PUNTUALIDAD                	Puntualidad  
      descripcion     Valor_Score (Valor Local)  					80	2	1	'01'	'A' 								 	No cliente Coppel 15         No cliente Coppel 14            No cliente Coppel 32
      ---------------   ------------                                          80	2	2	'01'	'B'                                  	A 37                                B 11                               	A 67
      A                   1                                                        80	2	3	'01'	'C'                                  	B 6                                  C 11                              	B 29
      B                   2                                                        80	2	4	'01'	'D'                                  	C 6                                  D 11                              	C 29
      C                   3                                                       80	2	5	'01'	'Z'                                  	D 6                                  Z 11                               	D 29 
      D                   4                                                       80	2	6	'01'	'N'                                  	Z 6                                  N 24                               	Z 29 
      N                   5                                                        80	2	7	'01'	'No cliente Coppel'           	N 28                                 A 34                        			N 48
      Z                   6                                                        80	2	8	'01'	'Cualquier otro caso'        	Cualquier otro caso 6        Cualquier otro caso 11      	Cualquier otro caso 29  
      */
      IF(vPuntualidad IS NULL) THEN 	  
		 LET vPuntualidad = 7; --
	  ELIF vPuntualidad NOT IN (1,2,3,4,5,6,7) THEN 	  
		 LET vPuntualidad = 8;
	  END IF;
		--SELECT elem.elemento INTO vScorepuntualidad FROM bdisolic:ss_scoring_element elem WHERE elem.empresa =  '001' AND elem.grupo = 80 and elem.elemento =  --vPuntualidad;	 
		
	--MACM Se valida si la solicitud viene del Motor de Evaluacion de PP
	If cBRM_reing = 0 AND isOC = 0 THEN
		DELETE FROM bdisolic:ss_detalle_modelo where num_solicitud = o_numsolicitud;
		
		DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
								and grupo >= 26 and grupo <= 37 and tpo_persona = '01' and  num_solicitud = o_numsolicitud;  --12
									
		DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
								and grupo >= 44 and grupo <= 47 and tpo_persona = '01' and  num_solicitud = o_numsolicitud;  --4
	
		DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' and seccion = '2' 
								and grupo in (16,49,50,51,52,53,54,55,56,57,63,64,65,66,67,60,68,61) and tpo_persona = '01' and  num_solicitud = o_numsolicitud;
								
		DELETE FROM bdisolic:ss_detalle_scoring WHERE empresa = '001' AND seccion ='2'  
								AND grupo IN (27,51,52,56,60,61,67,69,70,71,72,73,74,75,76,77,78,79,80) AND tpo_persona = '01' AND num_solicitud = o_numsolicitud; 						
		
	
		--Carga de tablas de Detalle de Modelo parametrico por solicitud
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'BC_101',vPeorMopHist,current,user);		
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'UT0034',UT0034,current,user);		
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'OCUPACION_&_TIEMPO_OCUPACION',vVI_Ocup_TmpOcup,current,user);		
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'IQ0002',IQ0002,current,user);		
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Residencia_&_Tpo_Residencia',VI_TpResid_TmpResid,current,user);			
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'EDO_CIVIL_&_GENERO',ESTADO_CIVIL_VAR_INT,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Edad&_Escolaridad',VI_Edad_Escolaridad,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Estado',vEstado,current,user);		
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Diferencias_Meses_&CtaMasAntigua_CtaRevolvente',vMesesAperCtaAntiguaRev,current,user);		
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Meses y monto de la fecha de morosidad mas grave mas reciente',vMesesyMonto,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Porcentaje_Cuentas_30_o_Mas_Dias_Atraso',vPorcCta30oMasDias,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Maximo plazo en dias',vMaxPlazoDias,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Ratio numero de consultas en los ultimos 3 meses entre numero de consultas de los ultimos 12 meses',vRatioConsUlt3M12M,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'PRODUCTO BANCOPPEL-TIENDA COMERCIAL',vBanCoppelTiendaComercial,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Promedio de la antiguedad en meses de cuentas reportadas en los ultimos 3 meses',vPromAntigMesesCtaRepUlt3Meses,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Eficiencia_Ultimo_Semestre',vEficUltSem,current,user);		
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Mora_Actual',vMorAct,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Porcentaje_de_Uso',vPorcUso,current,user);	
		insert into bdisolic:ss_detalle_modelo values(o_empresa,o_numsolicitud,'Puntualidad',vPuntualidad,current,user);

 
		UPDATE "informix".ss_detalle_scoring
		SET valor = 0
		WHERE empresa =  o_empresa
		AND seccion = 2
		AND num_solicitud = o_numsolicitud;
	
		--Carga de tablas de Detalle de puntajes del Modelo parametrico por solicitud
		insert into bdisolic:ss_detalle_scoring
		select o_empresa,'2',grupo,elemento,'01',o_numsolicitud,(case when pSIC='X'  THEN peso_no_hit When vCuentasPF > 0 And vCuentasPF <= 3 AND pSIC <> 'X' Then peso_hit When vCuentasPF > 3 AND pSIC <> 'X' Then peso_hit2 END)
		from ss_parametricos b
		where tipo_parametrico='2'
		and tp_solicitud=ptpsolicitud
		and ((grupo=27 and elemento = vPeorMopHist)
		or  (grupo=51 and UT0034 BETWEEN rango_min AND rango_max AND ((elemento between PorcRangfijoMin AND PorcRangofijoMax) OR (elemento between vScorePorcSdoMin AND vScorePorcSdoMax) OR  elemento IN (29)))	   
		or  (grupo=52 and elemento =vVI_Ocup_TmpOcup)	 
		or  (grupo=56 and IQ0002 BETWEEN rango_min AND rango_max AND elemento IN (6,7,8,9,10)) 	   
		or  (grupo=60 and elemento = VI_TpResid_TmpResid) 	
		or  (grupo=61 and elemento = ESTADO_CIVIL_VAR_INT)	
		or  (grupo=67 and elemento = VI_Edad_Escolaridad ) 	   	   
		or  (grupo=69 and elemento =  vEstado) 	
		or  (grupo=70 and elemento = vScorminelementRev)	  
		or  (grupo=71  AND elemento = vMesesyMonto)	   
		or  (grupo=72 and vPorcCta30oMasDias BETWEEN rango_min AND rango_max AND elemento between vScorePorcjCta30oMasDiasMin AND vScorePorcjCta30oMasDiasMax)	  
		or  (grupo=73 and vMaxPlazoDias BETWEEN rango_min AND rango_max AND elemento between vScorePlazoDiasMin AND vScorePlazoDiasMax)	   
		or  (grupo=74 and vRatioConsUlt3M12M BETWEEN rango_min AND rango_max AND elemento between vScoreRatioCon3MMin AND vScoreRatioCon3MMax) 	   
		or  (grupo=75 and vNumVecesTiendaComercial BETWEEN rango_min AND rango_max AND elemento = vBanCoppelTiendaComercial)	   
		or  (grupo=76 and vPromAntigMesesCtaRepUlt3Meses  BETWEEN rango_min AND rango_max AND elemento BETWEEN vPromAntMin AND vPromAntMax)	   
		or  (grupo=77 and vEficUltSem BETWEEN rango_min AND rango_max AND elemento between vScoreEficUltSemMin AND vScoreEficUltSemMax)	
		or  (grupo=78 and elemento between  vScoreMorActMin AND vScoreMorActMax) 	   
		or  (grupo=79 and vPorcUso BETWEEN rango_min AND rango_max AND ((elemento between vScorePorcjUsoMin AND vScorePorcjUsoMax) OR  elemento IN (1,13)))	   
		or  (grupo=80 AND elemento = vPuntualidad) 	   
		);
	ELSE
		
		IF cNum_Producto = '7800' THEN   --ACP
		
			UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
			SET clientecoppel_ss = vNumcte_ref,  tiempoocupacion_ss = vTmpOcupacion , tiemporesidencia_ss = vtmpo_Residencia,    
			idactividad_ss = sId_actividad, idsubactividad_ss = sId_subactividad , descripactividad_ss = cDescAct , descripsubactividad_ss = vDescSubAct, canal_ss = iCanal_Sol, 
			fechacliente_ss = dtFechaCte, genero_ss = cSexo, estadocivil_ss = cEdo_Civil,  escolaridad_ss = cEscolaridad, entidad_ss = cEntidad, 
			edad_ss = vEdadCte, estado_ss = cEntidad, sucursal_ss = cSucursal, fechanacimiento_ss = dtFechaNac, fechasolicitud_ss = dtFechaSolicitud, 
			estatussolicitud_ss = cStatusSolicitud, producto_ss = cNum_Producto, tiposolicitud_ss = cTp_solicitud, estabilidadvivienda_ss = vtmpo_Residencia,  mora_coppel_ss = vMorAct
			
			WHERE solicitudbancoppel_ss = o_numsolicitud
			AND clientebancoppel_ss = vNumcte;
			
		ELSE	
		
			UPDATE bdisolic:"informix".ss_certif_evaluacion_buro_pp
			SET iMM_act_Bancos_ss = pmaxmop1 ,iMM_hist_alto_Bancos_ss = pmaxmop ,vCuentasPF_ss = vCuentasPF_c ,vSumSaldoActualTL22_ss = vSumSaldoActualTL22 ,
			vSumLimCredTL23_ss = vSumLimCredTL23 , vNumTotalCtas_ss = vNumTotalCtas ,vCtas_al_corriente_ss = vCtas_al_corriente ,vCtas_sin_historia_ss = vCtas_sin_historia ,
			vMesesAperCtaAntigua_ss = vMesesAperCtaAntigua , vMesesAperCtaAntiguaRev_ss = vMesesAperCtaAntiguaRev ,vNumVecesBANCOPPEL_ss = vNumVecesBANCOPPEL ,
			vNumVecesTiendaComercial_ss = vNumVecesTiendaComercial ,vNumTotalCtasTL13_ss = vNumTotalCtasTL13 , vSaldoMorHistAltaTL36_ss = vSaldoMorHistAltaTL36 ,
			vCtas_30_mas_atraso_hist_ss = vCtas_30_mas_atraso_hist ,vFechaTL37_ss = vFechaTL37, iMM_hist_Bancos_ss = maxmoptot, iMaxMOP_actBancos_ss = pmaxmop1,
			iMaxMOP_histAltBancos_ss = pmaxmop, iMaxMOP_histBancos_ss = maxmoptot, iExisteBR_TL_mora_ss = iExisteBR_TL_mora
			
			WHERE cSolBanco_ss = o_numsolicitud                                                                                    
			AND cNumCteBco_ss = vNumcte;                                                                                              

			UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_pp
			SET cNumCte_ss = vNumcte_ref ,  BC_101_ss = BC_101 ,  UT0034_ss = UT0034 ,   
			iTiem_Ocupacion_ss = vTmpOcupacion ,  iTiem_Residencia_ss = vtmpo_Residencia ,  
			IQ0002_ss = IQ0002_c , vEficUltSem_ss = vEficUltSem , vMorAct_ss = vMorAct , vPorcUso_ss = vPorcUso ,  
			velemPuntualidad_ss = velemPuntualidad , IQ00012_ss = IQ00012 , iSumaTL13_ss = iSumaTL13 , vMaxPlazoDias_ss = vMaxPlazoDias ,  
			vSum_bal_ss = vSum_bal, cPuntualidadCoppel_ss = velemPuntualidad, sId_actividad_ss = sId_actividad, 
			sId_subactividad_ss = sId_subactividad , cDescAct_ss = cDescAct , vDescSubAct_ss = vDescSubAct, iCanal_Sol_ss = iCanal_Sol,
			dtFechaCte_ss = dtFechaCte, cSexo_ss = cSexo, cEdo_Civil_ss = cEdo_Civil, cEscolaridad_ss = cEscolaridad, cEntidad_ss = cEntidad,
			iFlag2credito_ss = iFlag2credito, sEdadCte_ss = vEdadCte, cEstado_ss = cEntidad, iExisteSolPP_ss = iExisteSolPP, vSum_higcred_ss = vSum_higcred,
			cSucursal_ss = cSucursal, dtFechaNac_ss = dtFechaNac, dtFechaSolicitud_ss = dtFechaSolicitud, capacidad_pres_ss = capacidad_pres,
			cStatusSolicitud_ss = cStatusSolicitud, cNum_Producto_ss = cNum_Producto, cTp_solicitud_ss = cTp_solicitud
			
			WHERE cSolBanco_ss = o_numsolicitud
			AND cNumCteBco_ss = vNumcte;
			
		END IF;
			
	END IF;

  
  END            
  
  LET vScore = 0;
  
  EXECUTE PROCEDURE "informix".calculo_parametrico(o_numsolicitud) INTO vScore;
  
  RETURN scod_ret, Case 
                  When vCuentasPF > 0 And vCuentasPF <= 3 Then 1
                  When vCuentasPF > 3 Then 2
                  When vCuentasPF = 0 Then 3
                  Else 0 End,vScore;

END PROCEDURE;