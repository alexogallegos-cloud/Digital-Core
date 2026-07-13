CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aplicados2(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pOrigen CHAR(1), pOpcFecha CHAR(1), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,     
			  DATE  		AS fecha_atencion,
			  VARCHAR(20) 	AS Numero_solicitud,
			  CHAR(8) 		AS Origen,
			  VARCHAR(20) 	AS Numero_Cliente,
			  VARCHAR(26) 	AS Apell_Paterno,
			  VARCHAR(26) 	AS Apell_Materno,
			  VARCHAR(53) 	AS Nombre,
			  DECIMAL(18,2) AS Lincred_actual,
			  DECIMAL(18,2) AS Lincred_sugerida,
			  DECIMAL(18,2) AS Incremento,
			  CHAR(2) 		AS Status,
			  VARCHAR(45) 	AS AnalistaCac,
			  VARCHAR(45) 	AS Analista2nivel,
			  VARCHAR(45) 	AS Analista3nivel,
			  VARCHAR(45) 	AS Analista4nivel,
			  VARCHAR(106) 	AS motivo,
			  DATE          AS FechaStatus,
			  INTEGER       AS TotalNumReg,
			  VARCHAR(45)   AS NomEjecutivoMaxPuesto;
			  
			  
	---DECLARACIONES         
	DEFINE cCodRet               	CHAR(6); 
	DEFINE cMensajeRet           	CHAR(80);
	DEFINE cComentario           	CHAR(80);
	DEFINE iSqlErr      	     	INTEGER;
	DEFINE iIsamErr              	INTEGER;
	DEFINE iCon            		 	INTEGER;
	DEFINE cErrorInfo            	CHAR(80);

	DEFINE  dtFechaAtencion 		DATE;
	DEFINE vcNumSol 				VARCHAR(20);	
	DEFINE cOrigen  				CHAR(8);
	DEFINE vcNumCte 				VARCHAR(20);
	DEFINE vcApellPaterno			VARCHAR(26);
	DEFINE vcApellMaterno 			VARCHAR(26);
	DEFINE vcNombre 				VARCHAR(53);
	DEFINE dLinCredAct 		    	DECIMAL(18,2);
	DEFINE dLinCredCal 	     		DECIMAL(18,2);
	DEFINE dIncremento				DECIMAL(18,2);
	DEFINE dMontoIncremento			DECIMAL(18,2);
	DEFINE cStatus 					CHAR(2);
	DEFINE vcAnalistaCac			VARCHAR(45);
	DEFINE vcAnalista2nivel 		VARCHAR(45);
	DEFINE vcAnalista3nivel 		VARCHAR(45);
	DEFINE vcAnalista4nivel 		VARCHAR(45);

	DEFINE vcMotivo 				VARCHAR(106);
	DEFINE cCausa 					CHAR(3);
	DEFINE cPuesto 					CHAR(3);
	DEFINE cNomEjecutivo 			CHAR(45);
	DEFINE dtFecha 					DATE;
	DEFINE dtFecha_status 			DATE;
	DEFINE iContador				INTEGER;
	DEFINE cNomEjecutivoMaxPuesto	CHAR(45);
	DEFINE cEjecutivo				CHAR(10);
	DEFINE dfecha  					CHAR(10);
	

	---INICIALIZACIONES
	LET iSqlErr                  	= 0;
	LET iIsamErr                 	= 0;
	LET iCon                 	 	= 0;
	LET cErrorInfo               	= '';
	LET cCodRet                  	= '000000';
	LET cMensajeRet              	= 'SE REALIZO LA CONSULTA CORRECTAMENTE';

	LET  dtFechaAtencion 		 	= DATE(1);
	LET vcNumSol 			 		= '';	
	LET cOrigen  		     		= '';
	LET vcNumCte 			 		= '';
	LET vcApellPaterno		 		= '';
	LET vcApellMaterno 		 		= '';
	LET vcNombre 			 		= '';
	LET dLinCredAct 		 		= 0;
	LET dLinCredCal 	     		= 0;
	LET dIncremento			 		= 0;
	LET dMontoIncremento	 		= 0;
	LET cStatus 			 		= '';
	LET vcAnalistaCac		 		= '';
	LET vcAnalista2nivel 	 		= '';
	LET vcAnalista3nivel 	 		= '';
	LET vcAnalista4nivel      		= '';
	LET vcMotivo 			 		= '';
	LET cCausa 			 		    = '';
	LET cPuesto 			 		= '';
	LET cNomEjecutivo	 		    = '';
	LET dtFecha_status 				= DATE(1);
	LET iContador					= 0;
	LET cNomEjecutivoMaxPuesto		= '';
	LET cEjecutivo					= '';
	LET dfecha 						=  '';

	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	
				RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				       NVL(vcNombre,''),0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''),'', NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');	
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_gral_aumlincred_aplicados.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pStatus IS NULL THEN 
		 LET pStatus = '';
		END IF;
		
		-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
		IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
			RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''),'', NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');
		ELSE
		
				FOREACH WITH HOLD							
					SELECT skip pInicio limit pFin fecha_atencion, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, 
						nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, 
						analista3nivel, analista4nivel, motivo, fechastatus, totalnumreg, nomejecutivomaxpuesto
						INTO  dtFechaAtencion,vcNumSol,cOrigen,vcNumCte, vcApellPaterno, vcApellMaterno, vcNombre, 
						dLinCredAct, dLinCredCal, dIncremento, cStatus, vcAnalistaCac, vcAnalista2nivel, vcAnalista3nivel, vcAnalista4nivel,
						vcMotivo, dtFecha_status, iContador, cNomEjecutivoMaxPuesto
						FROM bdicnweb:"informix".sw_consultaincrementosgralaplicados 
						WHERE usuario = pUsuario
									
					RETURN cCodRet, cMensajeRet, dtFechaAtencion, NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
						NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'') WITH RESUME;	
				END FOREACH; 
				
				
		END IF; 
						
		IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
			LET cCodRet= '000003';
			LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
			RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,'');
		END IF;	   		
			
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha (Fecha Origen o Fecha Atencion)',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 06/02/2014',
'MODIFICO : Daniel Lazalde',
'BD: BDICRED',
'VERSION: 20140206.0001',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aut_tot(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pOrigen CHAR(1), pUsuario CHAR(10))
        RETURNING CHAR(6)               AS codigo_retorno,
                  CHAR(80)              AS mensaje_retorno,     
                  INTEGER       		AS TotalRegs;
                          
                          
        ---DECLARACIONES         
        DEFINE cCodRet                  CHAR(6); 
        DEFINE cMensajeRet              CHAR(80);
		DEFINE iTotReg             		INTEGER;
		DEFINE iSqlErr             		INTEGER;
		DEFINE iIsamErr             	INTEGER;
		DEFINE iCon                     INTEGER;
		DEFINE cErrorInfo             	CHAR(80);
		
		DEFINE dtFechaOrigen            DATE;
        DEFINE vcNumSol                 VARCHAR(20);    
        DEFINE cOrigen                  CHAR(1);
        DEFINE vcNumCte                 VARCHAR(20);
        DEFINE vcApellPaterno           VARCHAR(26);
        DEFINE vcApellMaterno           VARCHAR(26);
        DEFINE vcNombre                 VARCHAR(53);
        DEFINE dLinCredAct              DECIMAL(18,2);
        DEFINE dLinCredCal              DECIMAL(18,2);
        DEFINE dIncremento              DECIMAL(18,2);
        DEFINE dMontoIncremento         DECIMAL(18,2);
        DEFINE cStatus                  CHAR(2);
        DEFINE vcAnalistaCac            VARCHAR(45);
        DEFINE vcAnalista2nivel         VARCHAR(45);
        DEFINE vcAnalista3nivel         VARCHAR(45);
        DEFINE vcAnalista4nivel         VARCHAR(45);

        DEFINE vcMotivo                 VARCHAR(106);
        DEFINE cCausa                   CHAR(3);
        DEFINE cPuesto                  CHAR(3);
        DEFINE cNomEjecutivo            CHAR(45);
        DEFINE dtFecha                  DATE;
        DEFINE dtFechaIngresoAC     	DATE;
        DEFINE dtFechaIngreso     		DATE;
        DEFINE dtHoraIngresoAC      	DATETIME HOUR TO FRACTION;
        DEFINE dtHoraIngreso      		DATETIME HOUR TO FRACTION;
        DEFINE dtFechaAtencion     		DATE;
        DEFINE dtHoraAtencion      		DATETIME HOUR TO FRACTION;
		
		DEFINE cTpoMovto				CHAR(10);
		DEFINE cUser				CHAR(10);
        
        ---INICIALIZACIONES
        LET iSqlErr                     = 0;
        LET iIsamErr                    = 0;
        LET iCon                        = 0;
        LET cErrorInfo                  = '';
        LET cCodRet                     = '000000';
        LET cMensajeRet                 = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
		 LET dtFechaOrigen               = DATE(1);
        LET vcNumSol                    = '';   
        LET cOrigen                     = '';
        LET vcNumCte                    = '';
        LET vcApellPaterno              = '';
        LET vcApellMaterno              = '';
        LET vcNombre                    = '';
        LET dLinCredAct                 = 0;
        LET dLinCredCal                 = 0;
        LET dIncremento                 = 0;
        LET dMontoIncremento            = 0;
        LET cStatus                     = '';
        LET vcAnalistaCac               = '';
        LET vcAnalista2nivel            = '';
        LET vcAnalista3nivel            = '';
        LET vcAnalista4nivel            = '';
        LET vcMotivo                    = '';
        LET cCausa                      = '';
        LET cPuesto                     = '';
        LET cNomEjecutivo               = '';
        LET dtFechaIngresoAC     		= DATE(1);
        LET dtHoraIngresoAC      		= CURRENT;
        LET dtFechaAtencion     		= DATE(1);
        LET dtHoraAtencion      		= CURRENT;
        LET cTpoMovto            		= '';
        LET iTotReg            			= 0;
		LET cUser						= '';
		
        BEGIN

                ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
                        IF iSqlErr != 0 THEN
                                LET cCodRet= iSqlErr;
                                LET cMensajeRet = cErrorInfo;
                                IF iSqlErr IN (-1204,-1205,-1206) THEN
                                        LET cCodRet = '000002';
                                        LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
                                END IF; 
                                RETURN cCodRet, cMensajeRet, iTotReg;   
                        END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO 'sp_consulta_gral_aumlincred_aut.out';
                --TRACE ON;
				
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                -- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
                IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' OR  NVL(pOrigen,'') = ''  THEN
                        LET cCodRet = '000001';
                        LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
                        RETURN cCodRet, cMensajeRet, iTotReg;
				ELSE 
				
				DELETE FROM bdicnweb:"informix".sw_consultaincrementosgralaut WHERE usuario = pUsuario;	
				
					 FOREACH WITH HOLD
                                        SELECT fecha_insert, num_solicitud,origen ,numcte,                                              
                                                lincred_actual,lincred_sugerida,status,causa_status,user_insert                                             
                                        INTO dtFechaOrigen,vcNumSol,cOrigen,vcNumCte, 
                                        dLinCredAct, dLinCredCal,cStatus, cCausa ,  cUser                                      
                                        FROM  bdicred:"informix".sd_bitacora_aumlincred
                                        WHERE empresa ='001'
                                        AND fecha_insert  >= pFechaInicial
                                        AND fecha_insert <= pFechaFinal
                                        AND status = pStatus
										AND origen = (CASE WHEN pOrigen = '0' THEN origen ELSE pOrigen END)
                                        ORDER BY fecha_insert
                                
                                        
                                        LET dMontoIncremento = dLinCredCal - dLinCredAct;
                                        IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
                                                LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
                                        ELSE
                                                LET dIncremento = 0;
                                        END IF;
                                        
                                        SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))                                     
                                        INTO vcNombre, vcApellPaterno,vcApellMaterno
                                        FROM bdinteg:"informix".si_cliente
                                        WHERE numcte = vcNumCte;
                                        
                                        LET vcAnalistaCac                       = '';
                                        LET vcAnalista2nivel                    = '';
                                        LET vcAnalista3nivel                    = '';
                                        LET vcAnalista4nivel                    = '';
                                        
                                        IF NVL(cOrigen,'') = 'S' THEN
                                                FOREACH WITH HOLD
                                                        SELECT b.nombre,a.puesto,a.fecha_atencion, EXTEND(a.hora_atencion, HOUR TO SECOND)  
                                                        INTO cNomEjecutivo,cPuesto,dtFechaIngreso, dtHoraIngreso
                                                        FROM bdicred:"informix".sd_historica_cac_aumlincred a
                                                        INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo = a.ejecutivo)
                                                        WHERE a.solicitud = vcNumSol
                                                        AND a.fecha_insert = dtFechaOrigen
                                                        ORDER BY a.puesto                                                       

                                                        IF cPuesto = '01'       THEN  
                                                                LET vcAnalistaCac = cNomEjecutivo;
                                                                LET dtFechaIngresoAC =dtFechaIngreso;
                                                                LET dtHoraIngresoAC = dtHoraIngreso;
                                                        ELIF cPuesto in ('02','03') THEN 
                                                                LET vcAnalista2nivel = cNomEjecutivo;
                                                                LET dtFechaAtencion =dtFechaIngreso;
                                                                LET dtHoraAtencion = dtHoraIngreso;
                                                        ELIF cPuesto in ('04') THEN 
                                                                LET vcAnalista3nivel = cNomEjecutivo;
                                                                LET dtFechaAtencion =dtFechaIngreso;
                                                                LET dtHoraAtencion = dtHoraIngreso;
                                                        ELIF cPuesto in ('05','06','07','08') THEN
                                                                LET vcAnalista4nivel = cNomEjecutivo;
                                                                LET dtFechaAtencion =dtFechaIngreso;
                                                                LET dtHoraAtencion = dtHoraIngreso;
                                                        END IF

                                                END FOREACH
                                                IF cPuesto = '01'	THEN
                                                        LET dtFechaAtencion = dtFechaIngresoAC;
                                                        LET dtHoraAtencion = dtHoraIngresoAC;
                                                END IF;
												
												LET cTpoMovto = 'Manual'; 
											ELSE
												IF EXISTS (SELECT ejecutivo FROM "informix".sd_perfiles_cac_aumlincred WHERE empresa = '001' AND ejecutivo = trim(cUser)) THEN    
													LET cTpoMovto = 'Manual';   
												ELSE
													LET cTpoMovto = 'Automatico';     
												END IF;
                                        END IF;
                                        
                                        
                                        IF NVL(cCausa,'') <> '' THEN
                                        
                                        --se obtiene la descripcion del motivo de rechazo o cancelacion
                                                SELECT causa_status||' - '||TRIM(descripcion)
                                                INTO vcMotivo
                                                FROM bdicred:"informix".sd_causas_aumlincred
                                                WHERE status = cStatus
                                                AND causa_status = cCausa;
                                        END IF; 
                                
										INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralaut(fechaorigen, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechaingresoac, horaingresoac, fechaatencion, horaatencion, tipoincremento, usuario) 
										VALUES(dtFechaOrigen, NVL(vcNumSol,''), NVL(cOrigen,''), NVL(vcNumCte,''), NVL(vcApellPaterno,''), NVL(vcApellMaterno,''), NVL(vcNombre,''), NVL(dLinCredAct,0), NVL(dLinCredCal,0), 
										NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,''), pUsuario);                                        
                                        
                                END FOREACH;  
                                
                                IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
                                        LET cCodRet= '000003';
                                        LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
                                        RETURN cCodRet, cMensajeRet, iTotReg;
                                END IF;                 
					
                END IF;                


		SELECT COUNT(*)                                     
		INTO iTotReg                                    
		FROM  bdicnweb:"informix".sw_consultaincrementosgralaut
		WHERE usuario = pUsuario;							

		RETURN cCodRet, cMensajeRet, iTotReg;       
                                                   
        END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 09/03/2011',
'MODIFICO : Mohamed Carreon',
'DESCIPCION CAMBIO : Se agrega la fecha final y la fecha inicial',
'FECHA : 12/06/2011',
'MODIFICACION: Se modifica para contemplar las reglas de informix, se elimina la variable "cNum_credito" ya que no es utilizada en el codigo.',
'FECHA MODIFICACION: 25/07/2012',
'MODIFICA: Guadalupe Payan',
'BD: BDICRED',
'VERSION: 20120725.1150',
'----------------------------------------------------------------------------------',
'Autor: Josue Remberto Zazueta Acosta',
'Modificacion: Se borra codigo comentado,se agregan informix y bd a las tablas que no tenian,Se implementan reglas de informix',
'Fecha de modificacion: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificacion: Se agregan los campos Fecha Ingreso AC, Hora Ingreso AC, Fecha Atencion, Hora Atencion en el retorno del sp',
'Fecha de modificacion: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'ModificaciÃ³n: Se modifica para agregar el tipo de incremento manual o automatico',
'Fecha de modificaciÃ³n: 20/09/2016',
'ModificÃ³: Johnattan Esquivel SÃ¡nchez',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aut2(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pOrigen CHAR(1), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
	RETURNING 		
		CHAR(6)       					AS codigo_retorno,
        CHAR(80)      					AS mensaje_retorno,     
        DATE          					AS fecha_origen,
        VARCHAR(20)   					AS Numero_solicitud,
        CHAR(1)       					AS  Origen,
        VARCHAR(20)   					AS Numero_Cliente,
        VARCHAR(26)   					AS Apell_Paterno,
        VARCHAR(26)   					AS Apell_Materno,
        VARCHAR(53)   					AS Nombre,
        DECIMAL(18,2) 					AS Lincred_actual,
        DECIMAL(18,2) 					AS Lincred_sugerida,
        DECIMAL(18,2) 					AS Incremento,
        CHAR(2)       					AS Status,
        VARCHAR(45)   					AS AnalistaCac,
        VARCHAR(45)   					AS Analista2nivel,
        VARCHAR(45)   					AS Analista3nivel,
        VARCHAR(45)   					AS Analista4nivel,
        VARCHAR(106)  					AS motivo,
        DATE          					AS fecha_ingresoAC,
        DATETIME HOUR TO FRACTION(3) 	AS hora_ingresoAC,
        DATE          					AS fecha_atencion,
        DATETIME HOUR TO FRACTION(3) 	AS hora_atencion,
		CHAR(10)  						AS tipoIncremento;
                          
                          
        ---DECLARACIONES         
        DEFINE cCodRet                  CHAR(6); 
        DEFINE cMensajeRet              CHAR(80);
        DEFINE cComentario              CHAR(80);
        DEFINE iSqlErr                  INTEGER;
        DEFINE iIsamErr                 INTEGER;
        DEFINE iCon                     INTEGER;
        DEFINE cErrorInfo               CHAR(80);

        DEFINE dtFechaOrigen            DATE;
        DEFINE vcNumSol                 VARCHAR(20);    
        DEFINE cOrigen                  CHAR(1);
        DEFINE vcNumCte                 VARCHAR(20);
        DEFINE vcApellPaterno           VARCHAR(26);
        DEFINE vcApellMaterno           VARCHAR(26);
        DEFINE vcNombre                 VARCHAR(53);
        DEFINE dLinCredAct              DECIMAL(18,2);
        DEFINE dLinCredCal              DECIMAL(18,2);
        DEFINE dIncremento              DECIMAL(18,2);
        DEFINE dMontoIncremento         DECIMAL(18,2);
        DEFINE cStatus                  CHAR(2);
        DEFINE vcAnalistaCac            VARCHAR(45);
        DEFINE vcAnalista2nivel         VARCHAR(45);
        DEFINE vcAnalista3nivel         VARCHAR(45);
        DEFINE vcAnalista4nivel         VARCHAR(45);

        DEFINE vcMotivo                 VARCHAR(106);
        DEFINE cCausa                   CHAR(3);
        DEFINE cPuesto                  CHAR(3);
        DEFINE cNomEjecutivo            CHAR(45);
        DEFINE dtFecha                  DATE;
        DEFINE dtFechaIngresoAC     	DATE;
        DEFINE dtFechaIngreso     		DATE;
        DEFINE dtHoraIngresoAC      	DATETIME HOUR TO FRACTION;
        DEFINE dtHoraIngreso      		DATETIME HOUR TO FRACTION;
        DEFINE dtFechaAtencion     		DATE;
        DEFINE dtHoraAtencion      		DATETIME HOUR TO FRACTION;
		
		DEFINE cTpoMovto				CHAR(10);
		
		DEFINE sQuery					CHAR(300);
		DEFINE cUser					CHAR(10);
		
        ---INICIALIZACIONES
        LET iSqlErr                     = 0;
        LET iIsamErr                    = 0;
        LET iCon                        = 0;
        LET cErrorInfo                  = '';
        LET cCodRet                     = '000000';
        LET cMensajeRet                 = 'SE REALIZO LA CONSULTA CORRECTAMENTE';

        LET dtFechaOrigen               = DATE(1);
        LET vcNumSol                    = '';   
        LET cOrigen                     = '';
        LET vcNumCte                    = '';
        LET vcApellPaterno              = '';
        LET vcApellMaterno              = '';
        LET vcNombre                    = '';
        LET dLinCredAct                 = 0;
        LET dLinCredCal                 = 0;
        LET dIncremento                 = 0;
        LET dMontoIncremento            = 0;
        LET cStatus                     = '';
        LET vcAnalistaCac               = '';
        LET vcAnalista2nivel            = '';
        LET vcAnalista3nivel            = '';
        LET vcAnalista4nivel            = '';
        LET vcMotivo                    = '';
        LET cCausa                      = '';
        LET cPuesto                     = '';
        LET cNomEjecutivo               = '';
        LET dtFechaIngresoAC     		= DATE(1);
        LET dtHoraIngresoAC      		= CURRENT;
        LET dtFechaAtencion     		= DATE(1);
        LET dtHoraAtencion      		= CURRENT;
        LET cTpoMovto            		= '';
		LET sQuery						= '';
		LET cUser						= '';

        BEGIN

                ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
                        IF iSqlErr != 0 THEN
                                LET cCodRet= iSqlErr;
                                LET cMensajeRet = cErrorInfo;
                                IF iSqlErr IN (-1204,-1205,-1206) THEN
                                        LET cCodRet = '000002';
                                        LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
                                END IF; 
                                RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                       NVL(vcNombre,''),0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,'');       
                        END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO 'sp_consulta_gral_aumlincred_aut.out';
                --TRACE ON;
				
                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                -- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
                IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
                        LET cCodRet = '000001';
                        LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
                        RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,''); 

                ELSE
                                FOREACH WITH HOLD
                                        SELECT skip pInicio limit pFin fechaorigen, numerosolicitud, origen, numerocliente, apellpaterno, 
										apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, 
										analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechaingresoac, horaingresoac, 
										fechaatencion, horaatencion, tipoincremento 
										INTO dtFechaOrigen,vcNumSol,cOrigen,vcNumCte, vcApellPaterno, vcApellMaterno, vcNombre, 
                                        dLinCredAct, dLinCredCal,dIncremento,cStatus, 
										vcAnalistaCac, vcAnalista2nivel,vcAnalista3nivel,vcAnalista4nivel, vcMotivo,
										dtFechaIngresoAC, dtHoraIngresoAC, dtFechaAtencion,dtHoraAtencion, cTpoMovto
										FROM bdicnweb:"informix".sw_consultaincrementosgralaut
                                        WHERE usuario = pUsuario
                                
                                        RETURN cCodRet, cMensajeRet,dtFechaOrigen,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                        NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,'') WITH RESUME;      
                                        
                                END FOREACH;  
                                
                                IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
                                        LET cCodRet= '000003';
                                        LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
                                        RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
                                               NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT), NVL(cTpoMovto,'');
                                END IF;                 
                        --END IF
                END IF
        END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 09/03/2011',
'MODIFICO : Mohamed Carreon',
'DESCRIPCION CAMBIO : Se agrego la fecha final y la fecha inicial',
'FECHA : 12/06/2011',
'MODIFICACION: Se modifica para contemplar las reglas de informix, se elimina la variable "cNum_credito" ya que no es utilizada en el codigo.',
'FECHA MODIFICACION: 25/07/2012',
'MODIFICO: Guadalupe Payan',
'BD: BDICRED',
'VERSION: 20120725.1150',
'----------------------------------------------------------------------------------',
'Autor: Josue Remberto Zazueta Acosta',
'Modificacion: Se borra codigo comentado,se agregan informix y bd a las tablas que no tenian,Se implementan reglas de informix',
'Fecha de modificacion: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificacion: Se agregan los campos Fecha Ingreso AC, Hora Ingreso AC, Fecha Atencion, Hora Atencion en el retorno del sp',
'Fecha de modificacion: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Modificacion: Se modifica para agregar el tipo de incremento manual o automatico',
'Fecha de modificacion: 20/09/2016',
'Modifico: Johnattan Esquivel SÃ¡nchez',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_rep_gral_status_total(pFechaIni CHAR (10), pFechaFin CHAR(10), pOrigen CHAR(1), pUsuario CHAR(10))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS total;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE cBandera 			CHAR(1);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcStatusTotal     DECIMAL(18,2);
	DEFINE cOrigen				CHAR(1);
	DEFINE cOrigen2				CHAR(1);


	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = '';
	LET cBandera				 = '';
	LET cStatus 				 = '';
	LET cCausa 					 = '';
	LET dPorcStatusTotal         = 0;
	LET cOrigen					 = "";
	LET cOrigen2				 = "";

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet=cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	 
				
				RETURN cCodRet, cMensajeRet, iTotalReg;
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_gral_status_total.out';
		--TRACE ON;

		-- Se validan los parametros de entrada.
		IF NVL(pFechaIni,'') = ''  OR NVL(pFechaFin,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA PARÁMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA';
			RETURN cCodRet, cMensajeRet, iTotalReg;
		END IF;

		IF NVL(pOrigen,'') = '' THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'FALTA PARÁMETRO REQUERIDO DE ORIGEN PARA REALIZAR  LA CONSULTA';
			RETURN cCodRet, cMensajeRet, iTotalReg;
		END IF;
		
		-- Se elimina la tabla de trabajo
		DELETE FROM bdicnweb:"informix".sw_consultaincrementosgralstatus WHERE usuario = pUsuario;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOrigen ='0' THEN --TODOS
			LET cOrigen ='C';
			LET cOrigen2 ='S';
		ELSE
			LET cOrigen = pOrigen;
		END IF;
		-- Se insertan el total de registros por estatus
		FOREACH WITH HOLD
			SELECT status,TRIM(descripcion)
				INTO cStatus,vcDescripcion
			FROM  "informix".sd_status_aumlincred 
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen IN (cOrigen,cOrigen2)
					AND status = cStatus					
					AND causa_status = ''
				
				IF iTotalStatus > 0 THEN
					INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralstatus(status,causa,descripcion,totalRegistros,porcentaje,totalGeneral,usuario)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0,0,pUsuario);	 
				END IF;
			END FOREACH;
			
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin			
					AND origen IN (cOrigen,cOrigen2)
					AND status = cStatus					
					AND causa_status IN(SELECT causa_status		  
										 FROM "informix".sd_causas_aumlincred
										 WHERE mostrar_pantalla = '1')
				
				IF iTotalStatus > 0 THEN
					INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralstatus(status,causa,descripcion,totalRegistros,porcentaje,totalGeneral,usuario)
					VALUES(cStatus,'',vcDescripcion,NVL(iTotalStatus,0),0,0,pUsuario);	 
				END IF;
				
			END FOREACH;  	
			
		END FOREACH;
		-- Se obtiene el total de los registros para esta consulta	
		SELECT NVL(SUM(totalregistros),0), COUNT(status)
		INTO iTotal,iTotalReg
		FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus 
		WHERE status = status
			AND causa = ''
			AND totalRegistros <> 0
			AND usuario = pUsuario;
		
		LET iTotalRegistros = iTotal;
					
		IF iTotalReg <> 0 THEN
			-- Se realiza el calculo del porcentaje por cada status del total de registros de la consulta	
			FOREACH
				SELECT status,descripcion,totalRegistros
				INTO cStatus, vcDescripcion,iTotalStatus
				FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus
				WHERE status = status
					AND causa = ''
					AND totalRegistros <> 0
					AND usuario = pUsuario				
				
				LET dPorcStatus = ((iTotalStatus * 100)/iTotalRegistros);
				IF (dPorcStatusAcum + dPorcStatus) < 100 THEN
					LET iCont = iCont + 1;
					IF iTotalReg = iCont THEN
						LET dPorcStatus = 100 - dPorcStatusAcum;
					END IF;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				ELSE
					LET iCont = iCont + 1;
					LET dPorcStatus = 100 - dPorcStatusAcum;
					LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;
				END IF;
						
				UPDATE bdicnweb:"informix".sw_consultaincrementosgralstatus
				SET porcentaje = dPorcStatus
				WHERE status = cStatus
					AND usuario = pUsuario;
			END FOREACH;
		END IF;
		-- Se insertan el total de registros por causas
		FOREACH WITH HOLD
			SELECT status,causa_status,TRIM(descripcion)
			  INTO cStatus,cCausa,vcDescripcion
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = '1'
				
			FOREACH WITH HOLD
				SELECT COUNT(status)
				INTO iTotalStatus
				FROM  "informix".sd_bitacora_aumlincred 
				WHERE fecha_insert >= pFechaIni
					AND fecha_insert <= pFechaFin		
					AND origen IN (cOrigen,cOrigen2)
					AND status = cStatus
					AND causa_status = cCausa
			
				INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralstatus (status,causa,descripcion,totalRegistros,porcentaje,totalGeneral,usuario)	
				VALUES(cStatus,cCausa,vcDescripcion,NVL(iTotalStatus,0),0,0,pUsuario);
			 
			END FOREACH;  		
		END FOREACH;	
		-- Se realiza el calculo del porcentaje por cada status con causa del total de registros de la consulta para cada status		
		LET dPorcStatusAcum = 0;
		LET dPorcStatus = 0;
		LET iCont = 0;

		FOREACH WITH HOLD
			SELECT status,causa_status
			  INTO cStatus,cCausa
			  FROM "informix".sd_causas_aumlincred
             WHERE mostrar_pantalla = '1'
			ORDER BY status,causa_status
					
			SELECT NVL(SUM(totalregistros),0), COUNT(causa)
			INTO iTotal,iTotalReg
			FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus 
			WHERE status = cStatus
				AND causa <> ''
				AND totalRegistros <> 0
				AND usuario = pUsuario;
								
			SELECT porcentaje
			INTO  dPorcStatusTotal
			FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus 
			WHERE status = cStatus
				AND causa = ''
				AND totalRegistros <> 0
				AND usuario = pUsuario;
					
			IF iTotalReg <> 0 THEN
				SELECT status,causa,descripcion,totalRegistros
				INTO cStatus,cCausa,vcDescripcion,iTotalStatus
				FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus
				WHERE status = cStatus
					AND causa = cCausa
					AND totalRegistros <> 0
					AND usuario = pUsuario;
					
				IF NVL(iTotalStatus,0) <> 0 THEN
					LET dPorcStatus = ((iTotalStatus * 100) / iTotalRegistros);

					IF (dPorcStatusAcum + dPorcStatus) < dPorcStatusTotal THEN
						LET iCont = iCont + 1;
						IF iTotalReg = iCont THEN
							LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;							
						END IF;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;						
					ELSE
						LET iCont = iCont + 1;
						LET dPorcStatus = dPorcStatusTotal - dPorcStatusAcum;
						LET dPorcStatusAcum = dPorcStatusAcum + dPorcStatus;	
					END IF;
						
					UPDATE bdicnweb:"informix".sw_consultaincrementosgralstatus
						SET porcentaje = dPorcStatus
					WHERE status = cStatus
						AND causa = cCausa
						AND usuario = pUsuario;	
				END IF;
			END IF;
			IF iTotalReg = iCont THEN
				LET dPorcStatusAcum = 0;
				LET dPorcStatus = 0;
				LET iCont = 0;
			END IF;				
		END FOREACH;
		
		UPDATE bdicnweb:"informix".sw_consultaincrementosgralstatus
		SET totalGeneral = iTotalRegistros
		WHERE usuario = pUsuario;
						
		-- Se obtiene los datos de la tabla
		SELECT COUNT(*)
		INTO iTotalReg
		FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus
		WHERE usuario = pUsuario;
		
		RETURN cCodRet, cMensajeRet, iTotalReg;			 
		
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada status de acuerdo al mes consultado',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2011',
'MODIFICACION: Se modifica para que reciba como parametro de entrada  el rango de fechas del cual se desea la informacion.',
'FECHA: 04/11/2011',
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'MODIFICACION: Se modifica para corregir y cambiar el retorno de la variable "iTotal" por "iTotalRegistros" ya que perdia el valor cuando el ultimo',
'			   registro tomaba el valor de 0 y por consecuencia no mostraba registros. Se contemplan las reglas de informix, se elimina variable "cComentario" y',
'              dPorcStatusAcum2 ya que estas no son usadas en el procedimiento',
'FECHA: 24/07/2012',
'AUTOR : Guadalupe Payan',
'BD    : BDICRED',
'Version: 20120724.1714',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_rep_gral_status2(pFechaIni CHAR (10), pFechaFin CHAR(10), pOrigen CHAR(1), pUsuario CHAR(10), pInicio INTEGER, pFin INTEGER)
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,
			  INTEGER  		AS tiene_causa,
			  CHAR(100) 	AS descripcion,
			  INTEGER 		AS total_status,
			  DECIMAL(18,2) AS porcentaje,
			  INTEGER 		AS total_general;

	---DECLARACIONES   
	DEFINE cCodRet              CHAR(6); 
	DEFINE cMensajeRet          CHAR(80);	
	DEFINE iSqlErr      	    INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);

	DEFINE dPorcStatus			DECIMAL(18,2);
	DEFINE dPorcStatusAcum		DECIMAL(18,2);
	DEFINE cStatus 				CHAR(2);
	DEFINE cCausa 				CHAR(3);
	DEFINE vcDescripcion 		VARCHAR(100);
	DEFINE iTotalStatus 		INTEGER;
	DEFINE iTotal 				INTEGER;
	DEFINE iTotalRegistros 		INTEGER;
	DEFINE iTieneCausa 			INTEGER;
	DEFINE iCont 				INTEGER;
	DEFINE iTotalReg 			INTEGER;
	DEFINE dPorcStatusTotal     DECIMAL(18,2);

	---INICIALIZACIONES
	LET iSqlErr                  = 0;
	LET iIsamErr                 = 0;
	LET cErrorInfo               = '';
	LET cCodRet                  = '000000';
	LET cMensajeRet              = 'SE REALIZO LA CONSULTA CORRECTAMENTE';
	LET dPorcStatus			     = 0;
	LET dPorcStatusAcum		     = 0;
	LET iTotalStatus			 = 0;
	LET iTotal			         = 0;
	LET iTotalRegistros			 = 0;
	LET iTieneCausa				 = 0;
	LET iCont					 = 0;
	LET iTotalReg				 = 0;
	LET vcDescripcion			 = '';
	LET cStatus 				 = '';
	LET cCausa 					 = '';
	LET dPorcStatusTotal         = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet=cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	 
			
				RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0), NVL(vcDescripcion,' '), NVL(iTotalStatus, 0), NVL(dPorcStatus, 0), NVL(iTotal, 0);
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_rep_gral_status2.out';
		--TRACE ON;

		-- Se validan los parametros de entrada.
		IF NVL(pFechaIni,'') = ''  OR NVL(pFechaFin,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA PARAMETRO DE FECHAS REQUERIDO PARA REALIZAR LA CONSULTA';
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0);
		END IF;

		IF NVL(pOrigen,'') = '' THEN
			LET cCodRet = '000003';
			LET cMensajeRet = 'FALTA PARAMETRO REQUERIDO DE ORIGEN PARA REALIZAR  LA CONSULTA';
			RETURN cCodRet, cMensajeRet,NVL(iTieneCausa, 0),NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0);
		END IF;
		
		-- Se obtiene los datos de la tabla
		FOREACH
			SELECT skip pInicio limit pFin status,causa,descripcion,totalRegistros,porcentaje,totalGeneral
			INTO cStatus,cCausa,vcDescripcion,iTotalStatus,dPorcStatus,iTotal
			FROM  bdicnweb:"informix".sw_consultaincrementosgralstatus
			ORDER BY status,causa
			
			IF NVL(cCausa,'') <> '' THEN
				LET iTieneCausa = 1;
				LET  vcDescripcion = TRIM (cCausa) || '-' || TRIM (vcDescripcion);
			ELSE
				LET iTieneCausa = 0;				
			END IF;
			
			RETURN cCodRet, cMensajeRet, NVL(iTieneCausa, 0), NVL(vcDescripcion,''),NVL(iTotalStatus, 0), NVL(dPorcStatus, 0),NVL(iTotal, 0) WITH RESUME;			 
		
		END FOREACH;	
		
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener el total y porcentaje de cada status de acuerdo al mes consultado',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 04/03/2011',
'MODIFICACION: Se modifica para que reciba como parametro de entrada  el rango de fechas del cual se desea la informacion.',
'FECHA: 04/11/2011',
'AUTOR : Héctor Manuel Bojorquez Ruelas',
'MODIFICACION: Se modifica para corregir y cambiar el retorno de la variable "iTotal" por "iTotalRegistros" ya que perdia el valor cuando el ultimo',
'			   registro tomaba el valor de 0 y por consecuencia no mostraba registros. Se contemplan las reglas de informix, se elimina variable "cComentario" y',
'              dPorcStatusAcum2 ya que estas no son usadas en el procedimiento',
'FECHA: 24/07/2012',
'AUTOR : Guadalupe Payan',
'BD    : BDICRED',
'Version: 20120724.1714',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aplicados_tot(pFechaInicial CHAR(10), pFechaFinal CHAR(10), pStatus CHAR(2), pOrigen CHAR(1), pOpcFecha CHAR(1), pUsuario CHAR(10))
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,     
			  INTEGER  		AS TotalRegs;
			  
			  
	---DECLARACIONES         
	DEFINE cCodRet               	CHAR(6); 
	DEFINE cMensajeRet           	CHAR(80);
	DEFINE cComentario           	CHAR(80);
	DEFINE iSqlErr      	     	INTEGER;
	DEFINE iIsamErr              	INTEGER;
	DEFINE iCon            		 	INTEGER;
	DEFINE cErrorInfo            	CHAR(80);

	DEFINE  dtFechaAtencion 		DATE;
	DEFINE vcNumSol 				VARCHAR(20);	
	DEFINE cOrigen  				CHAR(8);
	DEFINE vcNumCte 				VARCHAR(20);
	DEFINE vcApellPaterno			VARCHAR(26);
	DEFINE vcApellMaterno 			VARCHAR(26);
	DEFINE vcNombre 				VARCHAR(53);
	DEFINE dLinCredAct 		    	DECIMAL(18,2);
	DEFINE dLinCredCal 	     		DECIMAL(18,2);
	DEFINE dIncremento				DECIMAL(18,2);
	DEFINE dMontoIncremento			DECIMAL(18,2);
	DEFINE cStatus 					CHAR(2);
	DEFINE vcAnalistaCac			VARCHAR(45);
	DEFINE vcAnalista2nivel 		VARCHAR(45);
	DEFINE vcAnalista3nivel 		VARCHAR(45);
	DEFINE vcAnalista4nivel 		VARCHAR(45);

	DEFINE vcMotivo 				VARCHAR(106);
	DEFINE cCausa 					CHAR(3);
	DEFINE cPuesto 					CHAR(3);
	DEFINE cNomEjecutivo 			CHAR(45);
	DEFINE dtFecha 					DATE;
	DEFINE dtFecha_status 			DATE;
	DEFINE iContador				INTEGER;
	DEFINE cNomEjecutivoMaxPuesto	CHAR(45);
	DEFINE cEjecutivo				CHAR(10);
	DEFINE iTotReg              	INTEGER;

	---INICIALIZACIONES
	LET iSqlErr                  	= 0;
	LET iIsamErr                 	= 0;
	LET iCon                 	 	= 0;
	LET cErrorInfo               	= '';
	LET cCodRet                  	= '000000';
	LET cMensajeRet              	= 'SE REALIZO LA CONSULTA CORRECTAMENTE';

	LET  dtFechaAtencion 		 	= DATE(1);
	LET vcNumSol 			 		= '';	
	LET cOrigen  		     		= '';
	LET vcNumCte 			 		= '';
	LET vcApellPaterno		 		= '';
	LET vcApellMaterno 		 		= '';
	LET vcNombre 			 		= '';
	LET dLinCredAct 		 		= 0;
	LET dLinCredCal 	     		= 0;
	LET dIncremento			 		= 0;
	LET dMontoIncremento	 		= 0;
	LET cStatus 			 		= '';
	LET vcAnalistaCac		 		= '';
	LET vcAnalista2nivel 	 		= '';
	LET vcAnalista3nivel 	 		= '';
	LET vcAnalista4nivel      		= '';
	LET vcMotivo 			 		= '';
	LET cCausa 			 		    = '';
	LET cPuesto 			 		= '';
	LET cNomEjecutivo	 		    = '';
	LET dtFecha_status 				= DATE(1);
	LET iContador					= 0;
	LET cNomEjecutivoMaxPuesto		= '';
	LET cEjecutivo					= '';
    LET iTotReg                     = 0;

	BEGIN
		
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARAMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	
				RETURN cCodRet, cMensajeRet, iTotReg;	
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_gral_aumlincred_aplicados_tot.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		IF pStatus IS NULL THEN 
		 LET pStatus = '';
		END IF;
		
		-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
		IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' OR NVL(pStatus,'') = '' THEN
			LET cCodRet = '000001';
			LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
			RETURN cCodRet, cMensajeRet, iTotReg;
		ELSE
		
		DELETE FROM bdicnweb:"informix".sw_consultaincrementosgralaplicados WHERE usuario = pUsuario;
		
			IF pOpcFecha = '1' THEN --Busqueda por fechaOrigen: fecha_insert	
					
					FOREACH WITH HOLD							
						SELECT a.fecha_insert, a.num_solicitud,a.origen ,a.numcte, a.lincred_actual,a.lincred_sugerida,
							a.status,a.causa_status, a.fecha_status,a.ejecutivo
							INTO  dtFechaAtencion, vcNumSol, cOrigen, vcNumCte, 
							dLinCredAct, dLinCredCal,cStatus, cCausa, dtFecha_status, cEjecutivo
							FROM  bdicred:"informix".sd_bitacora_aumlincred a
							WHERE a.status = 'AP'	
							AND a.fecha_insert  >= pFechaInicial
							AND a.origen = (CASE WHEN pOrigen = '0' THEN a.origen ELSE pOrigen END)
							AND a.fecha_insert  <= pFechaFinal
							ORDER BY fecha_insert
					
						
						LET dMontoIncremento = dLinCredCal - dLinCredAct;
						IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
							LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
						ELSE
							LET dIncremento = 0;
						END IF;
						
						SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))					
						INTO vcNombre, vcApellPaterno,vcApellMaterno
						FROM bdinteg:'informix'.si_cliente
						WHERE numcte = vcNumCte;
						
					
					IF NVL(cCausa,'') <> '' THEN
					
					--se obtiene la descripcion del motivo de rechazo o cancelacion
						SELECT causa_status||' - '||TRIM(descripcion)
						INTO vcMotivo
						FROM "informix".sd_causas_aumlincred
						WHERE status = cStatus
						AND causa_status = cCausa;
					END IF;
						
					IF NVL(cOrigen,'') = 'S' THEN	
						
						--Obtener el nombre del ejecutivo del maximo puesto						
						SELECT LIMIT 1 c.nombre 
						INTO cNomEjecutivoMaxPuesto
						FROM "informix".sd_historica_cac_aumlincred h
						INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
						WHERE h.solicitud = vcNumSol
						AND h.fecha_insert = dtFechaAtencion
						AND h.puesto = (
									SELECT max(puesto)
									FROM "informix".sd_historica_cac_aumlincred
									WHERE solicitud = vcNumSol
									AND fecha_insert =  dtFechaAtencion
								);
						
						IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
							SELECT LIMIT 1 c.nombre 
							INTO cNomEjecutivoMaxPuesto
							FROM "informix".sd_perfiles_cac_aumlincred h
							INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
							WHERE h.ejecutivo = cEjecutivo;
							
							IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
								LET cNomEjecutivoMaxPuesto = 'SUCURSAL';
							END IF;
							
						END IF;							
						--LET cOrigen = DECODE(cOrigen,'CENTRAL','C','SUCURSAL','S');
					ELSE
						LET cNomEjecutivoMaxPuesto = 'CENTRAL';
					END IF;
					LET cOrigen = DECODE(cOrigen,'C','CENTRAL','S','SUCURSAL');				
						LET iContador = iContador + 1;
						
						INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralaplicados(fecha_atencion, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechastatus, totalnumreg, nomejecutivomaxpuesto, usuario) 
						VALUES(dtFechaAtencion,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''), NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,''), pUsuario);
		
						
					END FOREACH; 
						
				ELSE
						--Busqueda por fechaAtencion: fecha_status
						FOREACH WITH HOLD							
							SELECT a.fecha_insert, a.num_solicitud,a.origen ,a.numcte,						
								a.lincred_actual,a.lincred_sugerida,a.status,a.causa_status,
								a.fecha_status,a.ejecutivo
							INTO  dtFechaAtencion,vcNumSol,cOrigen,vcNumCte, 
							dLinCredAct, dLinCredCal,cStatus, cCausa, dtFecha_status,cEjecutivo
							FROM "informix".sd_bitacora_aumlincred a
							WHERE a.status = "AP"	
							AND a.fecha_status >= pFechaInicial
							AND a.origen = (CASE WHEN pOrigen = '0' THEN a.origen ELSE pOrigen END)
							AND a.fecha_status <= pFechaFinal							
							ORDER BY fecha_status
						
							
							LET dMontoIncremento = dLinCredCal - dLinCredAct;
							IF dMontoIncremento > 0 AND dLinCredAct > 0 THEN
								LET dIncremento = ROUND( dMontoIncremento * 100) / dLinCredAct ;
							ELSE
								LET dIncremento = 0;
							END IF;
							
							SELECT TRIM(NVL(nombre1, ''))||' '||TRIM(NVL(nombre2,'')),TRIM(NVL(apell_paterno, '')),TRIM(NVL(apell_materno, ''))					
							INTO vcNombre, vcApellPaterno,vcApellMaterno
							FROM bdinteg:"informix".si_cliente
							WHERE numcte = vcNumCte;
							
							
						IF NVL(cCausa,'') <> '' THEN
						
						--se obtiene la descripcion del motivo de rechazo o cancelacion
							SELECT causa_status||' - '||TRIM(descripcion)
							INTO vcMotivo
							FROM 'informix'.sd_causas_aumlincred
							WHERE status = cStatus
							AND causa_status = cCausa;
						END IF;
							
					IF NVL(cOrigen,'') = 'S' THEN	
						
						--Obtener el nombre del ejecutivo del maximo puesto						
						SELECT LIMIT 1 c.nombre 
						INTO cNomEjecutivoMaxPuesto
						FROM "informix".sd_historica_cac_aumlincred h
						INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
						WHERE h.solicitud = vcNumSol
						AND h.fecha_insert = dtFechaAtencion
						AND h.puesto = (
									SELECT max(puesto)
									FROM "informix".sd_historica_cac_aumlincred
									WHERE solicitud = vcNumSol
									AND fecha_insert =  dtFechaAtencion
								);
						
						IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
							SELECT LIMIT 1 c.nombre 
							INTO cNomEjecutivoMaxPuesto
							FROM "informix".sd_perfiles_cac_aumlincred h
							INNER JOIN bdinteg:"informix".si_ejecut c ON h.ejecutivo = c.ejecutivo
							WHERE h.ejecutivo = cEjecutivo;
							
							IF  NVL(cNomEjecutivoMaxPuesto,'') = '' THEN 
								LET cNomEjecutivoMaxPuesto = 'SUCURSAL';
							END IF;
							
						END IF;							
						--LET cOrigen = DECODE(cOrigen,'CENTRAL','C','SUCURSAL','S');
					ELSE
						LET cNomEjecutivoMaxPuesto = 'CENTRAL';
					END IF;
						LET cOrigen = DECODE(cOrigen,'C','CENTRAL','S','SUCURSAL');		
						
							LET iContador = iContador + 1;
							INSERT INTO bdicnweb:"informix".sw_consultaincrementosgralaplicados(fecha_atencion, numerosolicitud, origen, numerocliente, apellpaterno, apell_materno, nombre, lincred_actual, lincred_sugerida, incremento, status, analistacac, analista2nivel, analista3nivel, analista4nivel, motivo, fechastatus, totalnumreg, nomejecutivomaxpuesto, usuario) 
							VALUES(dtFechaAtencion,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''), NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFecha_status,0), NVL(iContador,0), NVL(cNomEjecutivoMaxPuesto,''), pUsuario);
						END FOREACH; 
		END IF; 
		
		SELECT COUNT(*) 
		INTO iTotReg 
		FROM bdicnweb:"informix".sw_consultaincrementosgralaplicados 
		WHERE usuario = pUsuario;
		
		RETURN cCodRet, cMensajeRet, iTotReg;
						
				IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
					LET cCodRet= '000003';
					LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
					RETURN cCodRet, cMensajeRet,iTotReg;
				END IF;	   		
			--END IF
		END IF
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha (Fecha Origen o Fecha AtenciÃ³n)',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 06/02/2014',
'MODIFICO : Daniel Lazalde',
'BD: BDICRED',
'VERSION: 20140206.0001',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 15/08/2019',
'MODULO: CREDITO',
'FUNCIONALIDAD: Reporte de Incrementos de Linea de Credito',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_depura_si_refclientes()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE vNumCte      VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE fFecha       DATE;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET vNumCte      = '';
LET fFecha       = date(1);

-- SET ISOLATION TO COMMITTED READ LAST COMMITTED;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO 'sp_depura_sd_movhis2.out';
--    TRACE ON;

    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     where proceso = 11;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(11,'');
    END IF;

	select empresa, num_solicitud, numcte
	 from bdisolic:ss_solicitudes 
	where status_solicitud in ('CN','RT') 
	  AND fecha_insert <= mdy('12','31','2018')
	  AND num_solicitud > vNumCredAux 
	  into temp paso1 with no log;
	  
	create unique index inx_paso1 on paso1(num_solicitud, numcte);
	update statistics medium for table paso1;


    FOREACH WITH HOLD
       SELECT a.num_solicitud, a.numcte
	       INTO vNumCred, vNumCte
           FROM paso1 a,
                bdinteg:si_refclientes b
          WHERE a.empresa = b.empresa
            and a.numcte = b.numcte
            and a.num_solicitud = b.num_solicitud
		  group by 1,2
		  order by 1

        BEGIN WORK;

            insert into bdinteg:si_refclientes_0819
            select * from bdinteg:si_refclientes
            where empresa = '001'
            and num_solicitud = vNumCred
            and numcte = vNumCte;

            delete from bdinteg:si_refclientes
            where empresa = '001'
            and num_solicitud = vNumCred
            and numcte = vNumCte;

            UPDATE "informix".sd_param_movhis_dep
               SET num_credito = vNumCred
             where proceso = 11;

        COMMIT WORK;  

    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;