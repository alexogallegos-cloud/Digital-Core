CREATE PROCEDURE "informix".sp_conspros_ctepf_web(pEmpresa CHAR(3),
												  pNumcte char(20))
											 
--DATOS A REGRESAR---
	RETURNING CHAR(5)   AS RETORNO,
			  CHAR(20)  AS CTE_PROSPECTO,
			  CHAR(26)	AS NOMBRE1,
			  CHAR(26)	AS NOMBRE2,
			  CHAR(26)	AS APELL_PATERNO,
			  CHAR(26)	AS APELL_MATERNO,
			  DATE	    AS FECHA_NAC,
			  CHAR(13)	AS RFC,
			  CHAR(20)	AS CURP,
			  CHAR(1)	AS SEXO,
			  
			  CHAR(2)	AS EDO_CIVIL,
			  CHAR(26)	AS APELL_CASADA,
			  CHAR(3)	AS NACIONALIDAD,
			  CHAR(18)	AS NOFM3,
			  CHAR(3)	AS OCUPACION,
			  CHAR(2)	AS TIPO_CASA,
			  CHAR(60)	AS DEPENDIENTES,
			  CHAR(2)	AS TIPO_IDENTIFICACION,
			  CHAR(30)	AS NOIDENTIFICACION,
			  CHAR(100)	AS EMAIL,
			  
			  CHAR(8)	AS USER_INSERT,
			  DATE		AS FECHA_INSERT,
			  CHAR(2)	AS ESTADO,
			  SMALLINT	AS NUM_CIUDAD,
			  CHAR(5)	AS DELEGACION,
			  INTEGER	AS COLONIA,
			  INTEGER	AS CALLE,
			  CHAR(10)	AS NUM_EXT,
			  CHAR(10)	AS NUM_INT,
			  CHAR(6)	AS DEPARTAMENTO,
			  
			  CHAR(5)	AS CP,
			  CHAR(1)	AS PUNTO_CARD,
			  SMALLINT	AS MANZANA,
			  SMALLINT	AS OTROS,
			  SMALLINT	AS ANDADOR,
			  SMALLINT	AS ETAPA,
			  SMALLINT	AS EDIFICIO,
			  SMALLINT	AS ENTRADA,
			  SMALLINT	AS LOTE,
			  CHAR(80)	AS OBSERVACIONES,

			  CHAR(40)	AS ENTRE_CALLES,
			  CHAR(13)	AS TEL_CASA,
			  CHAR(13)	AS TEL_CELULAR,
			  SMALLINT	AS CARRIER,
			  CHAR(3)	AS CIUDAD,
			  CHAR(1)	AS UNIDAD_HAB;

				-- 46 return

			  
-- DEFINICION DE VARIABLES
   DEFINE iSqlErr		   INTEGER;
   DEFINE vcCodRet         CHAR(5);
   DEFINE vcNumPros        CHAR(20);
   DEFINE vcNombre1        CHAR(26);
   DEFINE vcNombre2        CHAR(26);
   DEFINE vcApellPaterno   CHAR(26);
   DEFINE vcApellMaterno   CHAR(26);
   DEFINE vdFechaNac       DATE;
   DEFINE vcRfc            CHAR(13);
   DEFINE vcCurp           CHAR(20);
   DEFINE vcSexo           CHAR(1);
   DEFINE vcEdoCivil       CHAR(2);
   DEFINE vcApellCasada    CHAR(26);
   DEFINE vcNacionalidad   CHAR(3);
   DEFINE vcFM3            CHAR(18);
   DEFINE vcOcupacion      CHAR(3);
   DEFINE vcTipoCasa       CHAR(2);
   DEFINE vcDependientes   CHAR(60);
   DEFINE vcTipoId         CHAR(2);
   DEFINE vcNumId          CHAR(30);
   DEFINE vcCorreo         CHAR(100);
   DEFINE vpfuser_insert   CHAR(8);
   DEFINE vpffecha_insert  DATE;
   
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
   LET vcNumPros      		= '';
   LET vcNombre1      		= '';
   LET vcNombre2      		= '';
   LET vcApellPaterno 		= '';
   LET vcApellMaterno 		= '';
   LET vdFechaNac     		= '';
   LET vcRfc          		= '';
   LET vcCurp         		= '';
   LET vcSexo         		= '';
   LET vcEdoCivil     		= '';
   LET vcApellCasada  		= '';
   LET vcNacionalidad 		= '';
   LET vcFM3          		= '';
   LET vcOcupacion    		= '';
   LET vcTipoCasa     		= '';
   LET vcDependientes 		= '';
   LET vcTipoId       		= '';
   LET vcNumId        		= '';
   LET vcCorreo       		= '';
   LET vpfuser_insert 		= '';
   LET vpffecha_insert 		= '';
   
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
   
   
   --SET DEBUG FILE TO '/informix/sp_conspros_ctepf_web.out';
   --TRACE ON;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;

Call bdiprospectos:"informix".sp_conspros_ctepf(pEmpresa,pNumcte)
   RETURNING vcCodRet, vcNumPros, vcNombre1, vcNombre2, vcApellPaterno, vcApellMaterno, vdFechaNac, vcRfc, vcCurp, vcSexo, vcEdoCivil, vcApellCasada, vcNacionalidad, vcFM3, vcOcupacion, vcTipoCasa,vcDependientes, vcTipoId, vcNumId, vcCorreo;
   
	IF vcCodRet = "00000" THEN
	
	   SELECT user_insert, fecha_insert
       INTO vpfuser_insert,vpffecha_insert
       FROM pr_cliente 
       WHERE numcte_pros = vcNumPros;
	   
	   Call bdiprospectos:"informix".sp_conspros_dirtel_piloto(pEmpresa, pNumCte, 1)
				RETURNING vcCodRet1, vcNumPros1, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
				viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
	   
	ELSE
			  RETURN vcCodRet,vcNumPros,vcNombre1,vcNombre2,vcApellPaterno,vcApellMaterno,vdFechaNac,vcRfc,vcCurp,vcSexo,
					 vcEdoCivil,vcApellCasada,vcNacionalidad,vcFM3,vcOcupacion,vcTipoCasa,vcDependientes,vcTipoId,vcNumId,vcCorreo,
					 vpfuser_insert,vpffecha_insert,vcEstado,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,
					 vcCodPos,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,
					 vcEntreCalles,vcTelCasa,vcTelCelular,viCarrier,vcCiudad,vcUnidadHab;
   END IF;

   IF vcCodRet1 = '00000' THEN
   
   RETURN vcCodRet,vcNumPros,vcNombre1,vcNombre2,vcApellPaterno,vcApellMaterno,vdFechaNac,vcRfc,vcCurp,vcSexo,
					 vcEdoCivil,vcApellCasada,vcNacionalidad,vcFM3,vcOcupacion,vcTipoCasa,vcDependientes,vcTipoId,vcNumId,vcCorreo,
					 vpfuser_insert,vpffecha_insert,vcEstado,viCiudad,vcMunicipio,viColonia,viCalle,vcNumExt,vcNumInt,vcDepto,
					 vcCodPos,vcPuntoCard,viManzana,viOtros,viAndador,viEtapa,viEdificio,viEntrada,viLote,vcObservaciones,
					 vcEntreCalles,vcTelCasa,vcTelCelular,viCarrier,vcCiudad,vcUnidadHab; --24
					 
				ELIF vcCodRet1 = "00111" THEN
   
				   RETURN vcCodRet,vcNumPros,vcNombre1,vcNombre2,vcApellPaterno,vcApellMaterno,vdFechaNac,vcRfc,vcCurp,vcSexo,
									 vcEdoCivil,vcApellCasada,vcNacionalidad,vcFM3,vcOcupacion,vcTipoCasa,vcDependientes,vcTipoId,vcNumId,vcCorreo,
									 vpfuser_insert,vpffecha_insert,'','','','','','','','','','','','','','','','','','','','','','','','';

   ELSE
  /*  LET vcCodRet = vcCodRet1;
   RETURN vcCodRet,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''; */
   END IF;
   
END;
END PROCEDURE             
