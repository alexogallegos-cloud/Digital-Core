CREATE PROCEDURE "informix".sp_consulta_gral_aumlincred_aut	(pFechaInicial 	CHAR(10),pFechaFinal 	CHAR(10),	pStatus CHAR(2)	)
	RETURNING CHAR(6)  		AS codigo_retorno,
			  CHAR(80) 		AS mensaje_retorno,     
			  DATE  		AS fecha_origen,
			  VARCHAR(20) 	AS Numero_solicitud,
			  CHAR(1) 		AS  Origen,
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
			  DATE              AS fecha_ingresoAC,
			  DATETIME HOUR TO FRACTION(3) AS hora_ingresoAC,
			  DATE              AS fecha_atencion,
			  DATETIME HOUR TO FRACTION(3) AS hora_atencion;
			  
			  
	---DECLARACIONES         
	DEFINE cCodRet               	CHAR(6); 
	DEFINE cMensajeRet           	CHAR(80);
	DEFINE cComentario           	CHAR(80);
	DEFINE iSqlErr      	     	INTEGER;
	DEFINE iIsamErr              	INTEGER;
	DEFINE iCon            		 	INTEGER;
	DEFINE cErrorInfo            	CHAR(80);

	DEFINE dtFechaOrigen 			DATE;
	DEFINE vcNumSol 				VARCHAR(20);	
	DEFINE cOrigen  				CHAR(1);
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
	DEFINE dtFechaIngresoAC     DATE;
	DEFINE dtFechaIngreso     DATE;
	DEFINE dtHoraIngresoAC      DATETIME HOUR TO FRACTION;
	DEFINE dtHoraIngreso      DATETIME HOUR TO FRACTION;
	DEFINE dtFechaAtencion     DATE;
	DEFINE dtHoraAtencion      DATETIME HOUR TO FRACTION;
	
	---INICIALIZACIONES
	LET iSqlErr                  	= 0;
	LET iIsamErr                 	= 0;
	LET iCon                 	 	= 0;
	LET cErrorInfo               	= '';
	LET cCodRet                  	= '000000';
	LET cMensajeRet              	= 'SE REALIZÓ LA CONSULTA CORRECTAMENTE';

	LET dtFechaOrigen 		 		=DATE(1);
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
	LET dtFechaIngresoAC     = DATE(1);
	LET dtHoraIngresoAC      = CURRENT;
	LET dtFechaAtencion     = DATE(1);
	LET dtHoraAtencion      = CURRENT;
	

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				LET cMensajeRet = cErrorInfo;
				IF iSqlErr IN (-1204,-1205,-1206) THEN
					LET cCodRet = '000002';
					LET cMensajeRet = 'PARÁMETRO DE FECHA INVALIDO PARA REALIZAR  LA CONSULTA';
				END IF;	
				RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
				       NVL(vcNombre,''),0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT);	
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
				   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT);
		ELSE
			IF pFechaInicial > pFechaFinal THEN
				LET cCodRet = '000002';
				LET cMensajeRet = 'LA FECHA INICIAL ES MAYOR A LA FECHA FINAL';
				RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
					   NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT);
			ELSE		
				FOREACH WITH HOLD							
					SELECT fecha_insert, num_solicitud,origen ,numcte,						
						lincred_actual,lincred_sugerida,status,causa_status						
					INTO dtFechaOrigen,vcNumSol,cOrigen,vcNumCte, 
					dLinCredAct, dLinCredCal,cStatus, cCausa 					
					FROM  bdicred:"informix".sd_bitacora_aumlincred
					WHERE empresa ='001'
					AND fecha_insert  >= pFechaInicial
					AND fecha_insert <= pFechaFinal
					AND status=pStatus							
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
					
					LET vcAnalistaCac		 		= '';
					LET vcAnalista2nivel 	 		= '';
					LET vcAnalista3nivel 	 		= '';
					LET vcAnalista4nivel      		= '';
					
					IF NVL(cOrigen,"") = "S" THEN
						FOREACH WITH HOLD
							SELECT b.nombre,a.puesto,a.fecha_atencion, EXTEND(a.hora_atencion, HOUR TO SECOND)  
							INTO cNomEjecutivo,cPuesto,dtFechaIngreso, dtHoraIngreso
							FROM bdicred:"informix".sd_historica_cac_aumlincred a
							INNER JOIN bdinteg:"informix".si_ejecut b ON (b.ejecutivo = a.ejecutivo)
							WHERE a.solicitud = vcNumSol
							AND a.fecha_insert = dtFechaOrigen
							ORDER BY a.puesto							

							IF cPuesto = '01' 	THEN  
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
						IF cPuesto = '01' 	THEN
							LET dtFechaAtencion =dtFechaIngresoAC;
							LET dtHoraAtencion = dtHoraIngresoAC;
						END IF;
					END IF;
					
					
					IF NVL(cCausa,"") <> "" THEN
					
					--se obtiene la descripcion del motivo de rechazo o cancelacion
						SELECT causa_status||' - '||TRIM(descripcion)
						INTO vcMotivo
						FROM bdicred:'informix'.sd_causas_aumlincred
						WHERE status = cStatus
						AND causa_status = cCausa;
					END IF;	
				
				
					RETURN cCodRet, cMensajeRet,dtFechaOrigen,NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
					NVL(vcNombre,''), NVL(dLinCredAct,0),NVL(dLinCredCal,0),NVL(dIncremento,0),NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT) WITH RESUME;	
					
				END FOREACH;  
				
				IF (dbinfo('sqlca.sqlerrd2') = 0) THEN
					LET cCodRet= '000003';
					LET cMensajeRet= 'NO SE ENCONTRARON REGISTROS PARA LA CONSULTA';
					RETURN cCodRet, cMensajeRet,'',NVL(vcNumSol,''),NVL(cOrigen,''),NVL(vcNumCte,''),NVL(vcApellPaterno,''),NVL(vcApellMaterno,''),
					       NVL(vcNombre,''), 0,0,0,NVL(cStatus,''), NVL(vcAnalistaCac,''),NVL(vcAnalista2nivel,''),NVL(vcAnalista3nivel,''),NVL(vcAnalista4nivel,''),NVL(vcMotivo,''), NVL(dtFechaIngresoAC,DATE(1)), NVL(dtHoraIngresoAC,CURRENT), NVL(dtFechaAtencion,DATE(1)), NVL(dtHoraAtencion,CURRENT);
				END IF;	   		
			END IF
		END IF
	END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener los registros de acuerdo a un status en especifico de un periodo de fecha',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 09/03/2011',
'MODIFICO : Mohamed Carreón',
'DESCIPCION CAMBIO : Se agregó la fecha final y la fecha inicial',
'FECHA : 12/06/2011',
'MODIFICACIÓN: Se modifica para contemplar las reglas de informix, se elimina la variable "cNum_credito" ya que no es utilizada en el codigo.',
'FECHA MODIFICACIÓN: 25/07/2012',
'MODIFICÓ: Guadalupe Payan',
'BD: BDICRED',
'VERSION: 20120725.1150',
'----------------------------------------------------------------------------------',
'Autor: Josué Remberto Zazueta Acosta',
'Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían,Se implementan reglas', 'de informix',
'Fecha de modificación: 02/Octubre/2012',
'BD : bdicred',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agregan los campos Fecha Ingreso AC, Hora Ingreso AC, Fecha Atención, Hora Atención en el retorno del sp',
'Fecha de modificación: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consultar_excepciones_aumlincred()
RETURNING 
CHAR(6)		AS codigo_retorno,
CHAR(80)	AS mensaje_retorno,	
CHAR(4)		AS clave_excepcion,
CHAR(80)	AS desc_status; 

---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cDescripcion		CHAR(80);
DEFINE cCveExcepcion	CHAR(4);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = '';
LET cCodRet             = '000000';
LET cMensajeRet         = 'SE REALIZÓ LA CONSULTA CORRECTAMENTE';
LET cCveExcepcion		= '';
LET cDescripcion		= '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet,cCveExcepcion,cDescripcion;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO 'sp_consultar_excepciones_aumlincred.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	FOREACH WITH HOLD
		SELECT clave_excepcion,TRIM(descripcion)
		INTO cCveExcepcion,cDescripcion
		FROM 'informix'.sd_excepciones_aumlincred
		ORDER BY clave_excepcion	
					
		RETURN cCodRet,cMensajeRet,cCveExcepcion,cDescripcion WITH RESUME;
	END FOREACH;		

    IF dbinfo("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = '000001';
        LET cMensajeRet = 'NO HAY INFORMACIÓN DEL CATÁLOGO DE EXCEPCIONES DE AUMENTO DE LÍNEA DE CRÉDITO';
		RETURN cCodRet,cMensajeRet,cCveExcepcion,cDescripcion;
    END IF
	
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la obtencion de las excepciones de incrementos de linea de crédito',
'AUTOR : Juan Daniel Lazalde Centeno',
'FECHA : 04/02/2013',
'BD    : BDICRED',
'Version: 20130204.0001',
'MODIFICADO POR :  ';

CREATE PROCEDURE "informix".detalle_edocta(
								 pEmpresa CHAR(3),
			           pNumCredito CHAR(20),
			           pFechaEmision DATE,
			           pNumRegistros SMALLINT)
RETURNING CHAR(5),
    			DATE ,    			CHAR(20),    			SMALLINT,
					SMALLINT,				CHAR(9),					CHAR(255),
					CHAR(16),				CHAR(16);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err   SMALLINT;
DEFINE sCodRet   CHAR(5);

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 			CHAR(20);

DEFINE v_secuencia 		SMALLINT;
DEFINE v_nlinea 			SMALLINT;
DEFINE v_fecha_mov 		CHAR(9);
DEFINE v_concepto 		CHAR(255);
DEFINE v_cargos 			CHAR(16);
DEFINE v_abonos 			CHAR(16);

DEFINE v_Registros    SMALLINT;

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';

LET v_fecha_emision 		= " ";
LET v_num_credito 			= "";

LET v_secuencia 		= 0;
LET v_nlinea 				= 0;
LET v_fecha_mov 		= "";
LET v_concepto 			= "";
LET v_cargos 				= "";
LET v_abonos 				= "";

LET v_Registros    	= 0;

--SET DEBUG FILE TO "detalle_edocta.out";
--TRACE ON;

BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
					nvl(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
					NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
					NVL(v_cargos,""),NVL(v_abonos,"");
		END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	FOREACH 
		SELECT	fecha_emision,			num_credito,				secuencia,
						nlinea,							fecha_mov,					concepto,
						cargos,							abonos
		INTO		v_fecha_emision,			v_num_credito,				v_secuencia,
						v_nlinea,							v_fecha_mov,					v_concepto,
						v_cargos,							v_abonos
		 FROM bdicred@pld_tcp:sd_detalle_edocta
		 --FROM sd_detalle_edocta
		 WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
		 ORDER BY secuencia,nlinea


		LET v_Registros = v_Registros + 1;
		IF v_Registros <= pNumRegistros THEN
				CONTINUE FOREACH;
		END IF
		
		IF v_num_credito IS NULL THEN
				LET sCodRet = "185";
	      RETURN sCodRet, 
					nvl(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
					NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
					NVL(v_cargos,""),NVL(v_abonos,"");
		END IF

	  RETURN sCodRet, 
					v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0),
					NVL(v_nlinea,0), NVL(v_fecha_mov,""), NVL(v_concepto,""),
					NVL(v_cargos,""),NVL(v_abonos,"")
     WITH RESUME;
	
	END FOREACH
	
END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".mensajes_edocta(
					   pEmpresa CHAR(3),
			           pNumCredito CHAR(20),
			           pFechaEmision DATE,
			           pNumRegistros SMALLINT)
RETURNING CHAR(5), DATE ,CHAR(20),SMALLINT,	SMALLINT,CHAR(255),	CHAR(255);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);

DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 		CHAR(20);

DEFINE v_secuencia 			SMALLINT;
DEFINE v_nlinea 			SMALLINT;
DEFINE v_si_paga 			CHAR(255);
DEFINE v_mensajes 			CHAR(255);


DEFINE v_Registros          SMALLINT;

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err          = 0;
LET sCodRet          = '000';
LET v_fecha_emision  = " ";
LET v_num_credito 	 = "";
LET v_secuencia 	 = 0;
LET v_nlinea 		 = 0;
LET v_si_paga 		 = "";
LET v_mensajes 		 = "";
LET v_Registros    	 = 0;

--SET DEBUG FILE TO "mensajes_edocta.out";
--TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err
    LET sCodRet = sql_err;
    RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
    END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
    
   IF pFechaEmision <= mdy('03','20','2010') THEN

        FOREACH 
            SELECT 	fecha_emision,	num_credito, secuencia,
                    nlinea,	si_paga, mensajes
            INTO 	v_fecha_emision, v_num_credito,	v_secuencia,
                    v_nlinea, v_si_paga, v_mensajes
            FROM bdicred@pld_tcp:sd_mensajes_edocta
			--FROM sd_mensajes_edocta
            WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
            ORDER BY secuencia,nlinea


            LET v_Registros = v_Registros + 1;

            IF v_Registros <= pNumRegistros THEN
                    CONTINUE FOREACH;
            END IF

            IF v_num_credito IS NULL THEN
                LET sCodRet = "185";

            RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
            END IF

            RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
            WITH RESUME;

        END FOREACH

   ELSE

        FOREACH 


            SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
			--FROM sd_mensajes_edocta a
            FROM bdicred@pld_tcp:sd_mensajes_edocta a
            --left outer join bdicred:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
			left outer join bdicred@pld_tcp:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
            WHERE a.fecha_emision = pFechaEmision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = pNumCredito
            UNION ALL
            select fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
            INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
            FROM bdicred@pld_tcp:sd_mensajes_edocta a
			--FROM sd_mensajes_edocta a
            WHERE a.fecha_emision = pFechaEmision and num_credito = pNumCredito
            order by 2,3,4


            LET v_Registros = v_Registros + 1;

            IF v_Registros <= pNumRegistros THEN
                    CONTINUE FOREACH;
            END IF

            IF v_num_credito IS NULL THEN
                LET sCodRet = "185";

            RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
            END IF

            RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
            WITH RESUME;

        END FOREACH

   END IF;
	
END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_rep_ctes_pagvencidos(pEmpresa CHAR(03))

RETURNING CHAR(6),CHAR(80);

DEFINE cCodret         CHAR(6);
DEFINE iIsamErr        SMALLINT;
DEFINE cMensajeRet     CHAR(80);
DEFINE sql_err         INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE v_fch_ini       DATE;
DEFINE v_fch_fin       DATE;
DEFINE cNombre_Archivo CHAR(100);
DEFINE cSql            CHAR(2024);
DEFINE var_rga         CHAR(05);
DEFINE cNom_mes        CHAR(10);
DEFINE pFecha          DATE;
DEFINE iNum_dia        INTEGER;
DEFINE iNum_mes        INTEGER;
DEFINE iNum_anio       INTEGER;
DEFINE iQuery          SMALLINT;
DEFINE cruta				CHAR(100);

DEFINE cNum_credito             CHAR(20);
DEFINE cSucursal				CHAR(04);
DEFINE dFecha_apertura			DATE;
DEFINE sNum_periodos			SMALLINT;
DEFINE dMonto_otorgado			DECIMAL(18,02);
DEFINE dSdo_cap_insoluto		DECIMAL(18,02);
DEFINE dSdo_capital				DECIMAL(18,02);
DEFINE dTransitorio				DECIMAL(18,02);
DEFINE dVencido_exigible		DECIMAL(18,02);
DEFINE dVencido_no_exigible		DECIMAL(18,02);
DEFINE dInteres_vencido			DECIMAL(18,02);


LET cCodret         = '000000';
LET iIsamErr        = 0;
LET v_fch_ini       = '';
LET v_fch_fin       = '';
LET sql_err         = 0;
LET cErrorInfo      = '';
LET cNombre_Archivo = '';
LET cSql            = '';
LET iNum_dia        = 0;
LET iNum_anio       = 0;
LET iNum_mes        = 0;
LET cNom_mes        = '';
LET iQuery          = 0;
LET cMensajeRet     = 'El proceso de PAGOS VENCIDOS se ejecutó correctamente';
--Variables que se usan para el insert y creación del archivo de salida
LET cNum_credito            = '';
LET cSucursal				= '';
LET dFecha_apertura			= date(0);
LET sNum_periodos			= 0;
LET dMonto_otorgado			= 0.00;
LET dSdo_cap_insoluto		= 0.00;
LET dSdo_capital			= 0.00;
LET dTransitorio			= 0.00;
LET dVencido_exigible		= 0.00;
LET dVencido_no_exigible	= 0.00;
LET dInteres_vencido		= 0.00;
LET cruta					= "";

BEGIN

 ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
             LET cCodret = sql_err;
             LET cMensajeRet= cErrorInfo;
             RETURN cCodret,cMensajeRet;
  END EXCEPTION;

--SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_rep_ctes_pagvencidos.out";
--TRACE ON;
--Ruta
SELECT TRIM(valor_alfabetico) 
	INTO cRuta
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' and tipo_campania = 50 
	AND num_parametro = 2;

LET pFecha    = TODAY;
LET iNum_dia  = day(pFecha);
LET iNum_mes  = month(pFecha);
LET iNum_anio = year(pFecha);

IF iNum_dia >= 1 AND iNum_dia <= 5 THEN
--Query de consulta al fin de mes
    LET iQuery = 1;
    LET iNum_dia = day(mdy(month(pFecha),1,year(pFecha))-1);
    IF iNum_mes > 1  THEN LET iNum_mes = iNum_mes - 1; ELSE LET iNum_mes = 12; END IF;
    IF iNum_mes = 1  THEN LET cNom_mes = 'Enero';         END IF;
    IF iNum_mes = 2  THEN LET cNom_mes = 'Febrero';       END IF;
    IF iNum_mes = 3  THEN LET cNom_mes = 'Marzo';         END IF;
    IF iNum_mes = 4  THEN LET cNom_mes = 'Abril';         END IF;
    IF iNum_mes = 5  THEN LET cNom_mes = 'Mayo';          END IF;
    IF iNum_mes = 6  THEN LET cNom_mes = 'Junio';         END IF;
    IF iNum_mes = 7  THEN LET cNom_mes = 'Julio';         END IF;
    IF iNum_mes = 8  THEN LET cNom_mes = 'Agosto';        END IF;
    IF iNum_mes = 9  THEN LET cNom_mes = 'Septiembre';    END IF;
    IF iNum_mes = 10 THEN LET cNom_mes = 'Octubre';       END IF;
    IF iNum_mes = 11 THEN LET cNom_mes = 'Noviembre';     END IF;
    IF iNum_mes = 12 THEN LET cNom_mes = 'Diciembre'; LET iNum_anio = year(pFecha)-1; END IF;
ELIF iNum_dia >= 21 AND iNum_dia <= 25 THEN
--Query de consulta al corte
    LET iQuery = 2;
    LET iNum_dia = 20;
    IF iNum_mes = 1  THEN LET cNom_mes = 'Enero';       END IF;
    IF iNum_mes = 2  THEN LET cNom_mes = 'Febrero';     END IF;
    IF iNum_mes = 3  THEN LET cNom_mes = 'Marzo';       END IF;
    IF iNum_mes = 4  THEN LET cNom_mes = 'Abril';       END IF;
    IF iNum_mes = 5  THEN LET cNom_mes = 'Mayo';        END IF;
    IF iNum_mes = 6  THEN LET cNom_mes = 'Junio';       END IF;
    IF iNum_mes = 7  THEN LET cNom_mes = 'Julio';       END IF;
    IF iNum_mes = 8  THEN LET cNom_mes = 'Agosto';      END IF;
    IF iNum_mes = 9  THEN LET cNom_mes = 'Septiembre';  END IF;
    IF iNum_mes = 10 THEN LET cNom_mes = 'Octubre';     END IF;
    IF iNum_mes = 11 THEN LET cNom_mes = 'Noviembre';   END IF;
    IF iNum_mes = 12 THEN LET cNom_mes = 'Diciembre';   END IF;
ELSE
    LET cCodret     = '999999';
    LET cMensajeRet = 'Hoy no es un día válido para ejecutar el proceso de PAGOS VENCIDOS';
    RETURN cCodret,cMensajeRet;
END IF;

LET  cNombre_Archivo= 'Rep_Ctes_PagosVencidos_' || iNum_dia || TRIM(cNom_mes) || iNum_anio || '.txt';

IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_ctes_pagosvencidos' ) THEN
   DROP TABLE temp_ctes_pagosvencidos;
END IF;

   CREATE TABLE  temp_ctes_pagosvencidos
    ( num_credito        CHAR(20),  
      sucursal           CHAR(04),
      fecha_apertura     DATE,
      num_periodos       SMALLINT,
      monto_otorgado     DECIMAL(18,02),
      sdo_cap_insoluto   DECIMAL(18,02),
      sdo_capital        DECIMAL(18,02),
      monto_vencido      DECIMAL(18,02),
      mto_venc_trasp     DECIMAL(18,02),
      cap_tras_no_venci  DECIMAL(18,02),
      interes_vencido    DECIMAL(18,02)
    );

CREATE INDEX idx_temp_ctes
    ON informix.temp_ctes_pagosvencidos(num_credito, sucursal);

SET ISOLATION TO dirty READ;
SET LOCK MODE TO WAIT 3;

IF iQuery = 1 THEN
  INSERT INTO  temp_ctes_pagosvencidos
    select a.num_credito, a.sucursal, fecha_apertura, num_periodos, monto_otorgado, sdo_cap_insoluto,  
    sdo_capital vigente, monto_vencido transitorio, mto_venc_trasp vencido_exigible, cap_tras_no_venci vencido_no_exigible, 
    case when mto_venc_trasp > 0 then int_tra_no_exig - nvl((select sdo_int_anticip from bdicred:sd_maesdoshist where empresa = pEmpresa 
    and a.num_credito = num_credito and fecha = mdy(month(a.fecha),'20',year(a.fecha))),0) else 0 end interes_vencido 
    from bdicred:sd_maecredcont a,
    bdicred:sd_maesdoscont c,
    bdicred:sd_histvalcon b
    where a.empresa = pEmpresa
      and a.empresa = b.empresa and a.empresa = c.empresa
      and a.num_credito = b.num_credito and a.num_credito = c.num_credito
      and a.fecha = mdy(iNum_mes,iNum_dia,iNum_anio) and a.fecha = c.fecha
      and fecha_alta = a.fecha and num_periodos in (1,2,3);
ELSE
    FOREACH
        select b.num_credito, 
        (select count(*) from bdicred:sd_maesdoshist d where empresa = pEmpresa and b.num_credito = d.num_credito and fecha >= 
        (select max(fecha) from bdicred:sd_maesdoshist where empresa = pEmpresa and b.num_credito = num_credito and monto_vencido > 0) and fecha <= b.fecha and (monto_vencido > 0 or mto_venc_trasp > 0)), 
        monto_otorgado, sdo_cap_insoluto, sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, 
        case when mto_venc_trasp > 0  then int_tra_no_exig - sdo_int_anticip else 0 end
          into cNum_credito, 
        sNum_periodos, dMonto_otorgado, dSdo_cap_insoluto, dSdo_capital, dTransitorio, dVencido_exigible, dVencido_no_exigible, 
        dInteres_vencido 
        from bdicred:sd_maesdoshist b
        where b.empresa = pEmpresa
          and b.num_credito = b.num_credito
        and b.fecha = mdy(iNum_mes,iNum_dia,iNum_anio)
                and b.num_credito = (select num_credito from bdicred:sd_maecred where empresa=pEmpresa and num_credito=b.num_credito)
          and (monto_vencido > 0 or mto_venc_trasp > 0)
          and (select count(*) from bdicred:sd_maesdoshist c where empresa = pEmpresa and b.num_credito = c.num_credito and fecha >= 
        (select max(fecha) from bdicred:sd_maesdoshist where empresa = pEmpresa and b.num_credito = num_credito and monto_vencido > 0)
        and fecha <= b.fecha and (monto_vencido > 0 or mto_venc_trasp > 0)) in (1,2,3)

        select a.sucursal, fecha_apertura 
          into cSucursal, dFecha_apertura
        from bdicred:sd_maecred a
        where a.empresa = '001' 
          and a.num_credito = cNum_credito;

      INSERT INTO temp_ctes_pagosvencidos VALUES (
         cNum_credito,cSucursal,dFecha_apertura,sNum_periodos,dMonto_otorgado,dSdo_cap_insoluto,
         dSdo_capital,dTransitorio,dVencido_exigible,dVencido_no_exigible,dInteres_vencido);

--Se inicializan las variables que se usan para el insert y creación del archivo de salida
        LET cNum_credito            = '';
        LET cSucursal				= '';
        LET dFecha_apertura			= date(0);
        LET sNum_periodos			= 0;
        LET dMonto_otorgado			= 0.00;
        LET dSdo_cap_insoluto		= 0.00;
        LET dSdo_capital			= 0.00;
        LET dTransitorio			= 0.00;
        LET dVencido_exigible		= 0.00;
        LET dVencido_no_exigible	= 0.00;
        LET dInteres_vencido		= 0.00;

    END FOREACH

END IF;

  --Se genera archivo con la informacion del reporte
LET cSql = '';
LET cSql = 'echo "UNLOAD TO ' ||  trim(cRuta) || 'ReporteCtes_PagosVencidos.unl' || ' DELIMITER ' || '''|'''|| 
           ' select * from bdicred:temp_ctes_pagosvencidos;'|| 
           ' " >'||TRIM(cruta)||'ReporteCtes_PagosVencidos.sql';

SYSTEM cSql;

LET cSql = '';
LET cSql = 'dbaccess bdicred ' || TRIM(cruta) || 'ReporteCtes_PagosVencidos.sql';
SYSTEM cSql;

LET cSql = "sed 's/|$//g' " || trim(cruta) || "ReporteCtes_PagosVencidos.unl > " || trim(cruta) || cNombre_Archivo;
SYSTEM cSql;
     
LET cSql = '';
LET cSQL = 'rm ' || trim(cruta) || 'ReporteCtes_PagosVencidos.sql';
SYSTEM cSql;

LET cSql = '';
LET cSQL = 'rm ' || trim(cruta) || 'ReporteCtes_PagosVencidos.unl';
SYSTEM cSql;

DROP TABLE  temp_ctes_pagosvencidos;  
       
RETURN cCodret,cMensajeRet;

END
END PROCEDURE;