CREATE PROCEDURE "informix".sp_conspros_ing_web( pEmpresa CHAR(3), pNumCte CHAR(20) )

--DATOS A REGRESAR---
	RETURNING CHAR(5)   	AS RETORNO,
			  CHAR(20)      AS NUMCTE_PROSPECTO,
			  CHAR(60)      AS EMPRESA_TRABAJO,
			  CHAR(2)       AS PUESTO_ESPECIAL,
			  CHAR(3)       AS PUESTO,
			  DECIMAL(14,2) AS INGRESO_MENSUAL,
			  INTEGER       AS PERIOCIDAD,
			 
			  CHAR(2)		AS ESTADO,
			  SMALLINT		AS NUM_CIUDAD,
			  CHAR(5)		AS DELEGACION,
			  INTEGER		AS COLONIA,
			  INTEGER		AS CALLE,
			  CHAR(10)		AS NUM_EXT,
			  CHAR(10)		AS NUM_INT,
			  CHAR(6)		AS DEPARTAMENTO,
			  CHAR(5)		AS CP,
			  CHAR(1)		AS PUNTO_CARD,
			  SMALLINT		AS MANZANA,
			  SMALLINT		AS OTROS,
			  SMALLINT		AS ANDADOR,
			  SMALLINT		AS ETAPA,
			  SMALLINT		AS EDIFICIO,
			  SMALLINT		AS ENTRADA,
			  SMALLINT		AS LOTE,
			  CHAR(80)		AS OBSERVACIONES,
			  CHAR(40)		AS ENTRE_CALLES,
			  CHAR(13)		AS TEL_TRABAJO,
			  CHAR(13)		AS EXTENSION_TRABAJO,
			  CHAR(3)		AS CIUDAD,
			  CHAR(1)		AS UNIDAD_HAB;
			  
-- DEFINICION DE VARIABLES
   DEFINE iSqlErr		   INTEGER;
   DEFINE vcCodRet         CHAR(5);
   DEFINE vcNumPros        CHAR(20);
   DEFINE vcNomEmpresa     CHAR(60);
   DEFINE vcPuestoEsp      CHAR(2);
   DEFINE vcPuesto         CHAR(3);
   DEFINE vdIngreso        DECIMAL(14,2);
   DEFINE viPeriocidad     INTEGER;
   
   DEFINE vcCodRet1        CHAR(5);
   DEFINE vcNumPros1       CHAR(20);
   DEFINE vcEstado         CHAR(2);
   DEFINE viCiudad         SMALLINT;
   DEFINE vcMunicipio      CHAR(5);
   DEFINE viColonia        INTEGER;
   DEFINE viCalle          INTEGER;
   DEFINE vcNumExt         CHAR(10);
   DEFINE vcNumInt         CHAR(10);
   DEFINE vcDepto          CHAR(6);
   DEFINE vcCodPos         CHAR(5);
   DEFINE vcPuntoCard      CHAR(1);
   DEFINE viManzana        SMALLINT;
   DEFINE viOtros          SMALLINT;
   DEFINE viAndador        SMALLINT;
   DEFINE viEtapa          SMALLINT;
   DEFINE viEdificio       SMALLINT;
   DEFINE viEntrada        SMALLINT;
   DEFINE viLote           SMALLINT;
   DEFINE vcObservaciones  CHAR(80);
   DEFINE vcEntreCalles    CHAR(40);
   DEFINE vcTelCasa        CHAR(13);
   DEFINE vcTelCelular     CHAR(13);
   DEFINE viCarrier        SMALLINT;
   DEFINE vcTelTrabajo     CHAR(13);
   DEFINE vcExtTrabajo     CHAR(5);
   DEFINE vcCiudad         CHAR(3);
   DEFINE vcUnidadHab      CHAR(1);
   
--INICIALIZACION DE VARIABLES  
   LET iSqlErr	        	= 0; 
   LET vcCodRet       		= '00000';
   LET vcNumPros    		= '';
   LET vcNomEmpresa 		= '';
   LET vcPuestoEsp  		= '';
   LET vcPuesto     		= '';
   LET vdIngreso    		= 0.00;
   LET viPeriocidad 		= 0;
   
   LET vcCodRet1       		= '00000';
   LET vcNumPros1       	= '';
   LET vcEstado        		= ''; 
   LET viCiudad        		= 0; 
   LET vcMunicipio     		= ''; 
   LET viColonia       		= 0; 
   LET viCalle         		= 0; 
   LET vcNumExt        		= ''; 
   LET vcNumInt        		= ''; 
   LET vcDepto         		= ''; 
   LET vcCodPos        		= ''; 
   LET vcPuntoCard     		= ''; 
   LET viManzana       		= 0;  
   LET viOtros         		= 0;  
   LET viAndador       		= 0;  
   LET viEtapa         		= 0;  
   LET viEdificio      		= 0;  
   LET viEntrada       		= 0;  
   LET viLote          		= 0;  
   LET vcObservaciones 		= '';
   LET vcEntreCalles   		= ''; 
   LET vcTelCasa       		= ''; 
   LET vcTelCelular    		= ''; 
   LET viCarrier       		= 0;  
   LET vcTelTrabajo    		= '';
   LET vcExtTrabajo    		= '';
   LET vcCiudad        		= '';
   LET vcUnidadHab     		= '';
   

   
    --SET DEBUG FILE TO '/informix/sp_conspros_ing_web.out';
	--TRACE ON;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
Call bdiprospectos:"informix".sp_conspros_ing(pEmpresa,pNumcte)
 RETURNING vcCodRet, vcNumPros, vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad;
 
 IF vcCodRet = "00000" THEN
	Call bdiprospectos:"informix".sp_conspros_dirtel_piloto(pEmpresa, pNumCte, 2)
	RETURNING vcCodRet1, vcNumPros1, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
			  viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
 ELSE
	RETURN vcCodRet,vcNumPros, vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad,vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana,viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;	 
 END IF;
 
	IF vcCodRet1 = "00000" THEN
 
		RETURN vcCodRet,vcNumPros, vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad,vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana,viOtros, 		 viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
					ELIF vcCodRet1 = "00111" THEN
						RETURN vcCodRet,vcNumPros, vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad,'', '', '', '', '', '', '', '', '', '', '','', '', '', '', '', '', '', '', '', '', '', '';
		ELSE
			IF vcCodRet1 = "00110" THEN
			LET vcCodRet = vcCodRet1;
				RETURN vcCodRet,vcNumPros, vcNomEmpresa, vcPuestoEsp, vcPuesto, vdIngreso, viPeriocidad,vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana,viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
				END IF;
 END IF;
 
END;
END PROCEDURE             
