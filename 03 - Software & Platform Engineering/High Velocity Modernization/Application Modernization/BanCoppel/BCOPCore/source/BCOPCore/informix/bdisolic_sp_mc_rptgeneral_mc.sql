CREATE PROCEDURE "informix".sp_mc_rptgeneral_mc (pProducto CHAR(4), pFechainicial CHAR(10), pFechafinal CHAR(10))
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION,
	CHAR(100) AS CONCEPTO,
	INTEGER AS MIXTA,
	INTEGER AS UNICA,
	INTEGER AS TOTAL,
	DECIMAL(18,2) AS PORCENTAJE,
	SMALLINT AS NIVEL,
	SMALLINT AS SUBNIVEL,
	SMALLINT AS SUBNIVEL2;
	
---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(6);
DEFINE cMensajeRet		CHAR(80);

DEFINE iSolicitudesMC INTEGER;
DEFINE iMIXTA  		  INTEGER;
DEFINE iUNICA         INTEGER;
DEFINE iNoAnalizadas  INTEGER;
DEFINE iAnalizadas    INTEGER;
DEFINE iSigueProceso  INTEGER;
DEFINE iRechazadas    INTEGER;
DEFINE iCanceladas	  INTEGER;
DEFINE iMIXTANoAna	  INTEGER;
DEFINE iUNICANoAna	  INTEGER;
DEFINE iMIXTAAna	  INTEGER;
DEFINE iUNICAAna      INTEGER;
DEFINE iMIXTASP       INTEGER;
DEFINE iUNICASP 	  INTEGER;
DEFINE iMIXTART		  INTEGER;
DEFINE iUNICART       INTEGER;
DEFINE iMIXTACM		  INTEGER;
DEFINE iUNICACM       INTEGER;


DEFINE dPorcentajeSP  DECIMAL(18,2);
DEFINE dPorcentajeRT  DECIMAL(18,2);
DEFINE dPorcentajeCN  DECIMAL(18,2);
DEFINE dPorcentajeCS  DECIMAL(18,2);
DEFINE dPorcentajeNoAna DECIMAL(18,2);
DEFINE dPorcentajeAna DECIMAL(18,2);
DEFINE cStatus  	  CHAR(2);
DEFINE cCausa 		  CHAR(3);
DEFINE cDesCausa  	  CHAR(100);
DEFINE iTotalCausa    INTEGER;
DEFINE iTotalMixta	  INTEGER;
DEFINE iTotalUnica    INTEGER;
DEFINE itotalesCausas INTEGER;
DEFINE iCancelacion   INTEGER;
DEFINE sCreoTabla  	  CHAR(1);
DEFINE cConcepto  	  CHAR(100);
DEFINE iTotal   	  INTEGER;
DEFINE dPorcentaje    DECIMAL(18,2);
DEFINE iNivel  	      INTEGER;
DEFINE iSubnivel  	  INTEGER;
DEFINE iSubnivel2  	  INTEGER;
				
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'Proceso Exitoso';

LET iSolicitudesMC = 0;
LET iMIXTA  	   = 0;
LET iUNICA         = 0;
LET iNoAnalizadas  = 0;
LET iAnalizadas    = 0;
LET iSigueProceso  = 0;
LET iRechazadas    = 0;
LET iCanceladas	   = 0;
LET iMIXTANoAna	   = 0;
LET iUNICANoAna	   = 0;
LET iMIXTAAna	   = 0;
LET iUNICAAna      = 0;
LET iMIXTASP       = 0;
LET iUNICASP 	   = 0;
LET iMIXTART	   = 0;
LET iUNICART       = 0;
LET iMIXTACM	   = 0;
LET iUNICACM       = 0;
LET dPorcentajeSP = 0 ;
LET dPorcentajeRT = 0 ;
LET dPorcentajeCN = 0 ;
LET dPorcentajeNoAna = 0 ;
LET dPorcentajeAna = 0 ;

LET dPorcentajeCS = 0;
LET cStatus		  = "";
LET cCausa	      = "";
LET cDesCausa     = "";
LET iTotalCausa	  = 0;
LET iTotalMixta   = 0;
LET iTotalUnica   = 0 ;
LET itotalesCausas = 0 ;
LET iCancelacion  = 0 ;
LET sCreoTabla ="N";
LET cConcepto  	   = "";
LET iTotal   	  = 0;
LET dPorcentaje   = 0;
LET iNivel  	  = 0;
LET iSubnivel  	  = 0;
LET iSubnivel2    = 0;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
		 IF sCreoTabla ="S" THEN
			DROP TABLE tme_consultarepgeneral;
		 END IF;
          RETURN cCodRet, cMensajeRet,cConcepto,iMixta,iUnica,iTotal,dPorcentaje,iNivel,iSubnivel,iSubnivel2;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO "/informix/jesus/sp_mc_rptgeneral_mc.out";
	--TRACE ON;
	
		---CONTROL DE ERRORES EN CASO QUE NO SE PROPORCIONE ALGUN PARÁMETRO--
	IF NVL(pFechainicial, '') = '' OR NVL(pFechafinal, '') = '' OR LENGTH(pFechainicial) < 10 OR  LENGTH(pFechafinal) < 10 THEN
		LET cCodret  = '000001';
		LET cMensajeRet = 'DEBE PROPORCIONAR LOS PARÁMETROS CORRECTAMENTE';
		RETURN TRIM(cCodret), TRIM(cMensajeRet),cConcepto,iMixta,iUnica,iTotal,dPorcentaje,iNivel,iSubnivel,iSubnivel2;
	ELSE	
	--OBTENER TOTALES

		CREATE TEMP TABLE tme_consultarepgeneral
		(
			concepto CHAR(100),
			mixta INTEGER,
			unica INTEGER,
			total INTEGER,
			porcentaje  DECIMAL(18,2),
			nivel INTEGER,
			subnivel INTEGER,
			subnivel2 INTEGER
		)WITH NO LOG;

			LET sCreoTabla ="S";
			
			SELECT (SUM(NVL( CASE WHEN tipo_movimiento = "M" THEN 1 END,0)) +
				  SUM(NVL( CASE WHEN tipo_movimiento = "U" THEN 1 END,0))),
			SUM(NVL( CASE WHEN tipo_movimiento = "M" THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "U" THEN 1 END,0)),
			SUM(NVL( CASE WHEN (status_fin IN ('EE','AT','ST') AND revisado ='N') THEN 1 END,0)),
			SUM(NVL( CASE WHEN ejecutivo_autoriza <> '' THEN 1 END,0)),
			SUM(NVL( CASE WHEN (status_fin  IN ('EE','AT','ST') AND revisado ='S') THEN 1 END,0)),
			SUM(NVL( CASE WHEN  status_fin = 'RT'  THEN 1 END,0)),
			SUM(NVL( CASE WHEN  status_fin = 'CM'  THEN 1 END,0)),
			--mixtas para subnivel
			SUM(NVL( CASE WHEN tipo_movimiento = "M"  AND (status_fin IN ('EE','AT','ST') AND revisado ='N') THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "U" AND (status_fin IN ('EE','AT','ST') AND revisado ='N') THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "M"  AND ejecutivo_autoriza <> '' THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "U" AND ejecutivo_autoriza <> ''  THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "M"  AND (status_fin  IN ('EE','AT','ST') AND revisado ='S') THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "U" AND (status_fin  IN ('EE','AT','ST') AND revisado ='S') THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "M"  AND status_fin = 'RT'  THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "U" AND status_fin = 'RT' THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "M"  AND status_fin = 'CM'  THEN 1 END,0)),
			SUM(NVL( CASE WHEN tipo_movimiento = "U" AND status_fin = 'CM' THEN 1 END,0))					
				INTO iSolicitudesMC,iMIXTA,iUNICA,iNoAnalizadas,iAnalizadas,iSigueProceso,iRechazadas,iCanceladas,
				--subnivel
				iMIXTANoAna,iUNICANoAna,iMIXTAAna,iUNICAAna,iMIXTASP,iUNICASP,iMIXTART,iUNICART,iMIXTACM,iUNICACM
			FROM "informix".ss_solicitudes_mc 
			WHERE num_producto = DECODE(TRIM(pProducto), '', num_producto, TRIM(pProducto)) 
			AND fecha_insert BETWEEN pFechainicial::DATE AND pFechafinal::DATE;	
	
	
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '000002'; 
				LET cMensajeRet = 'No existe información con los datos proporcionados';
				DROP TABLE tme_consultarepgeneral;
				RETURN cCodRet, cMensajeRet,cConcepto,NVL(iMixta,0),NVL(iUnica,0),NVL(iTotal,0),NVL(dPorcentaje,0),iNivel,iSubnivel,iSubnivel2 WITH RESUME;
			END IF;
	
		
			
	
			INSERT INTO tme_consultarepgeneral (concepto,mixta,unica,total,porcentaje,nivel,subnivel,subnivel2)
			VALUES ("SOLICITUDES ATENDIDAS",iMIXTA,iUNICA,iSolicitudesMC,100,1,0,0);
			
			IF iSolicitudesMC <= 0 THEN
				LET dPorcentajeNoAna = 0 ;
				LET dPorcentajeAna = 0 ;				
			ELSE 
				LET dPorcentajeNoAna = ROUND((iNoAnalizadas/iSolicitudesMC) * 100);
				LET dPorcentajeAna = ROUND((iAnalizadas/iSolicitudesMC) * 100);				
			END IF ;			
			
			INSERT INTO tme_consultarepgeneral (concepto,mixta,unica,total,porcentaje,nivel,subnivel,subnivel2) 
			VALUES ("NO ANALIZADAS EN TIEMPO",iMIXTANoAna,iUNICANoAna,iNoAnalizadas,dPorcentajeNoAna,2,0,0);
			INSERT INTO tme_consultarepgeneral (concepto,mixta,unica,total,porcentaje,nivel,subnivel,subnivel2) 
			VALUES ("ANALIZADAS EN TIEMPO",iMIXTAAna,iUNICAAna,iMIXTAAna+iUNICAAna,dPorcentajeAna,3,0,0);
			
		
			IF iAnalizadas <= 0 THEN
				LET dPorcentajeSP = 0 ;
				LET dPorcentajeRT = 0 ;
				LET dPorcentajeCN = 0 ;
			ELSE 
				LET dPorcentajeSP = ROUND((iSigueProceso/iAnalizadas) * dPorcentajeAna,2);
				LET dPorcentajeRT = ROUND((iRechazadas/iAnalizadas) * dPorcentajeAna,2);
				LET dPorcentajeCN = ROUND((iCanceladas/iAnalizadas) * dPorcentajeAna,2);
			END IF ;
			
			INSERT INTO tme_consultarepgeneral (concepto,mixta,unica,total,porcentaje,nivel,subnivel,subnivel2) 
			VALUES ("SIGUE PROCESO",iMIXTASP,iUNICASP,iSigueProceso,dPorcentajeSP,3,1,0);
			INSERT INTO tme_consultarepgeneral (concepto,mixta,unica,total,porcentaje,nivel,subnivel,subnivel2) 
			VALUES ("RECHAZADAS",iMIXTART,iUNICART,iRechazadas,dPorcentajeRT,3,2,0);
			INSERT INTO tme_consultarepgeneral (concepto,mixta,unica,total,porcentaje,nivel,subnivel,subnivel2) 
			VALUES ("CANCELADAS",iMIXTACM,iUNICACM,iCanceladas,dPorcentajeCN,3,3,0);
			
			
			FOREACH WITH HOLD
				SELECT c.status_solicitud,
				c.causa_solicitud,
				c.descripcion,
				count(c.descripcion),
				SUM(NVL( CASE WHEN a.tipo_movimiento = "M" THEN 1 END,0)),
				SUM(NVL( CASE WHEN a.tipo_movimiento = "U" THEN 1 END,0))
				INTO cStatus,cCausa,cDesCausa,iTotalCausa,iTotalMixta,iTotalUnica
				FROM "informix".ss_solicitudes_mc a
				INNER JOIN "informix".ss_autorizacion_especial b ON (a.empresa = b.empresa and a.num_solicitud = b.num_solicitud   and a.status_ini = b.status_ant  and  a.status_fin =  b.status_nvo )
				INNER JOIN "informix".ss_causas_sol c ON (c.empresa = a.empresa and a.status_fin = c.status_solicitud  and c.tipo_auto =2 and  c.causa_solicitud=b.causa_solicitud)			
				WHERE a.num_producto = DECODE(TRIM(pProducto), '', a.num_producto, TRIM(pProducto)) 
				AND a.fecha_insert BETWEEN pFechainicial::DATE AND pFechafinal::DATE
				GROUP BY  c.status_solicitud, c.causa_solicitud,c.descripcion
				ORDER BY  c.status_solicitud, c.causa_solicitud
				
				IF cStatus = "RT" THEN 
					LET itotalesCausas =iRechazadas;
					LET iCancelacion = 2;		
					LET dPorcentaje = dPorcentajeRT;				
				ELSE
					LET itotalesCausas =iCanceladas;
					LET iCancelacion = 3;
					LET dPorcentaje = dPorcentajeCN;
				END IF
				
				IF iTotalCausa <= 0 THEN
					LET dPorcentajeCS = 0 ;								
				ELSE 
					LET dPorcentajeCS = ROUND((iTotalCausa/itotalesCausas) * dPorcentaje,2);					
				END IF ;
				
					INSERT INTO tme_consultarepgeneral (concepto,mixta,unica,total,porcentaje,nivel,subnivel,subnivel2)
					VALUES (TRIM(cCausa)||'-'||TRIM(cDesCausa),iTotalMixta,iTotalUnica,iTotalCausa,dPorcentajeCS,3,iCancelacion,iSubnivel2+1);
								
			END FOREACH;
			FOREACH WITH HOLD
				SELECT concepto,mixta,unica,total,porcentaje,nivel,subnivel,subnivel2
					INTO cConcepto,iMixta,iUnica,iTotal,dPorcentaje,iNivel,iSubnivel,iSubnivel2
				FROM tme_consultarepgeneral
				ORDER BY nivel,subnivel,subnivel2
				
				RETURN cCodRet, cMensajeRet,cConcepto,NVL(iMixta,0),NVL(iUnica,0),NVL(iTotal,0),NVL(dPorcentaje,0),iNivel,iSubnivel,iSubnivel2 WITH RESUME;
			END FOREACH;
		
		DROP TABLE tme_consultarepgeneral;
	END IF;
	
END
END PROCEDURE
