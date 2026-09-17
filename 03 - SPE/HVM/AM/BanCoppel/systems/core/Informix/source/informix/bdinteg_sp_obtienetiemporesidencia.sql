CREATE PROCEDURE "informix".sp_obtienetiemporesidencia(cnumcte CHAR(20),cStatusSolicitud CHAR(2))
	RETURNING CHAR(5),CHAR(10);

--DEFINICION DE VARIABLES 
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE cNumerosolicituddecredito CHAR(20);
DEFINE dFechaSolicitudCredito date;
DEFINE iDiasSolicitud INTEGER;
DEFINE cDiasSolicitudFinal CHAR(50);
DEFINE iElementoScoring INTEGER;
DEFINE cDescripElemento CHAR(50);
DEFINE cFechaResidencia CHAR(10);

--INICIALIZACION DE VARIABLES
LET cCodRet = '00000';
LET cNumerosolicituddecredito = '';
LET dFechaSolicitudCredito =date(1);
LET iDiasSolicitud = 0;
LET cDiasSolicitudFinal = '';
LET iElementoScoring = 0;
LET cDescripElemento = '';
LET cFechaResidencia = '';

	--SET DEBUG FILE TO "/tmp/sp_ObtieneTiempoResidencia.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,'';
			END IF;
		END EXCEPTION;
		
		IF cnumcte IS NOT NULL OR cnumcte <> "" THEN
			--OBTENER FECHA Y NUMERO DE SOLICITUD
			IF EXISTS(SELECT num_solicitud, fecha_insert
				FROM   bdisolic:"informix".ss_solicitudes
				WHERE  numcte = cnumcte AND num_producto = '6500' AND status_solicitud = cStatusSolicitud) THEN
				
				SELECT num_solicitud, fecha_insert
				INTO   cNumerosolicituddecredito, dFechaSolicitudCredito
				FROM   bdisolic:"informix".ss_solicitudes
				WHERE  numcte = cnumcte AND num_producto = '6500' AND status_solicitud = cStatusSolicitud;
							
				--TIEMPO DE RESIDENCIA 
				--Obtener dias de la solicitud
				LET iDiasSolicitud = CAST(dFechaSolicitudCredito::DATE AS INTEGER);
				
				--Para obtener elemento
				SELECT elemento  
				INTO iElementoScoring 
				FROM bdisolic:"informix".ss_detalle_scoring 
				WHERE grupo = '6'  
				--AND seccion = '2' 
				AND num_solicitud = cNumerosolicituddecredito;
				
				--Para buscar descripcion de elemento 
				SELECT descripcion
				INTO cDescripElemento  
				FROM bdisolic:"informix".ss_scoring_element 
				WHERE elemento = iElementoScoring
				AND grupo = '6'  
				--AND seccion = '2'
				AND activa = 1;
				
				IF cDescripElemento = "20 años o mas" THEN
					LET cDiasSolicitudFinal = iDiasSolicitud -7300;
				END IF;
				
				IF cDescripElemento = "De 10 a 19 años 11 meses" THEN
					LET cDiasSolicitudFinal = (iDiasSolicitud -7265);
				END IF;
				
				IF cDescripElemento = "De 8 a 9 años 11 meses" THEN
					LET cDiasSolicitudFinal = (iDiasSolicitud -3615);
				END IF;
				
				IF cDescripElemento = "Entre 5 y 7 años 11 meses" THEN
					LET cDiasSolicitudFinal = (iDiasSolicitud -2885);
				END IF;
				
				IF cDescripElemento = "Entre 3 y 4 años 11 meses (o propia con menos de 3 años)" THEN
					LET cDiasSolicitudFinal = (iDiasSolicitud -1790);
				END IF;
				
				IF cDescripElemento = "Entre 2 y 2 años 11 meses" THEN
					LET cDiasSolicitudFinal = (iDiasSolicitud -1060);
				END IF;
				
				IF cDescripElemento = "Entre 1 y 1 año 11 meses (rentada o familiar)" THEN
					LET cDiasSolicitudFinal = (iDiasSolicitud -695);
				END IF;
				
				IF cDescripElemento = "Menos de 1 año (rentada o familiar)" THEN
					LET cDiasSolicitudFinal = (iDiasSolicitud -364);
				END IF;
				
				LET cFechaResidencia = CAST(cDiasSolicitudFinal::INTEGER AS date);
				
			ELSE
				RETURN '00002',('01/01/2005');
			END IF;
		ELSE    
				RETURN '00001',('01/01/2005');
		END IF;
		RETURN cCodRet, NVL(cFechaResidencia,'01/01/2005');
	END;
	
--*************************************************************************
--| Procedimiento   : sp_ObtieneTiempoResidencia
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Noviembre de 2008
--| Descripción     : Obtiene el tiempo de residencia del cliente 
--|                   en su domicilio
--*************************************************************************
END PROCEDURE;