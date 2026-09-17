CREATE PROCEDURE "informix".sp_consultasufijos(pNumEmpresa CHAR(3), pCodigo CHAR(2))

	RETURNING

		CHAR(6) AS CodRet,
		CHAR(80) AS MensajeErr,
		CHAR(2) AS CodSufijo,
		CHAR(60) AS Descripcion;
--------------------------DECLARACION DE VARIABLES
		DEFINE iSqlErr			INTEGER;
		DEFINE iSam_Err   		INTEGER;
		DEFINE cError_Info 		CHAR(200);
		DEFINE cCodRet         	CHAR(6);
		DEFINE cMensajeErr		CHAR(80);
		DEFINE cCodSufijo		CHAR(2);
		DEFINE cDescripcion		CHAR(60);
--------------------------INICIALIZACION DE VARIABLES
		LET iSqlErr				= 0;
		LET iSam_Err			= 0;
		LET cError_Info			= '';
		LET cCodSufijo			= '';
		LET cCodRet         	= '000000';
		LET cMensajeErr			= 'PROCESO EXITOSO';
		LET cDescripcion		= '';

	BEGIN

		ON EXCEPTION SET iSqlErr, iSam_Err, cError_Info
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeErr = 'ERROR EN EL PROCEDIMIENTO PRINCIPAL';
				RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodSufijo,'')), TRIM(NVL(cDescripcion,''));
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SET DEBUG FILE TO '/dbexportb/Hugo/sp_consultasufijos.out';
		--TRACE ON;

		IF NVL(pNumEmpresa, '') = '' THEN----NO SE RECIBIO PARAMETRO DE EMPRESA
			LET cCodRet		= '00001';
			LET cMensajeErr    = 'ERROR EN EL PARAMETRO DE EMPRESA';

			RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodSufijo,'')), TRIM(NVL(cDescripcion,''));
		END IF
		IF  NVL(pCodigo, '') = '' THEN---CONSULTA GENERAL, REGRESA TODOS LOS REGISTROS

			FOREACH

				SELECT TRIM(codigo), TRIM(Descripcion)
				INTO cCodSufijo, cDescripcion
				FROM "informix".si_sufijos
				WHERE empresa = pNumEmpresa
				AND status = 1
				ORDER BY codigo

				RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodSufijo,'')), TRIM(NVL(cDescripcion,'')) WITH RESUME;

			END FOREACH

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN---NO EXISTEN DATOS EN LA TABLA
				LET cCodRet		= '000002';
				LET cMensajeErr    = 'NO EXISTEN DATOS EN LA TABLA';

				RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodSufijo,'')), TRIM(NVL(cDescripcion,''));

			END IF

		ELSE--CONSULTA CON UN CODIGO EN ESPECIFICO

			SELECT TRIM(codigo), TRIM(Descripcion)
			INTO cCodSufijo, cDescripcion
			FROM "informix".si_sufijos
			WHERE empresa = pNumEmpresa
			AND	codigo = pCodigo;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN--NO HAY REGISTROS EN LA TABLA
				LET cCodRet		= '000003';
				LET cMensajeErr    = 'ERROR NO HAY REGISTROS EN LA TABLA';
			END IF

			RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cMensajeErr,'')), TRIM(NVL(cCodSufijo,'')), TRIM(NVL(cDescripcion,''));

		END IF

	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta catalogo sufijos',
'Modificó: Hugo Vazquez',
'FECHA: 16 Julio 2013',
'VERSION: 20130716.0936',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_campaniamensaje_multiple(pIdMensaje SMALLINT)

--DATOS A REGRESAR---
	RETURNING
	CHAR(6)  AS codigo_retorno,
	CHAR(55) AS mensaje,
	SMALLINT AS Orden;

--DEFINICION DE VARIABLES--
	DEFINE iSqlErr     INTEGER;
	DEFINE cCodRet     CHAR(6);
	DEFINE iRows       INTEGER; 
	DEFINE cMensaje    CHAR(55);
	DEFINE cMensajeInc CHAR(55);
	DEFINE cVariable   CHAR(20);
	DEFINE cValorVar   CHAR(10);
	DEFINE i           INTEGER;
	DEFINE sOrden	   SMALLINT;	

--INICIALIZACION DE VARIABLES--
	LET iSqlErr     = 0;
	LET cCodRet     = '000000';
	LET iRows       = 0;  
	LET cMensaje    = '';
	LET cMensajeInc = '';
	LET cVariable   = '';
	LET cValorVar   = '';
	LET i           = 0;
	LET sOrden      = 0;

	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_campaniamensaje_multiple.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensaje,'')),NVL(sOrden,0);
			END IF;
			
		END EXCEPTION;

		--Valida parámetros de entrada
		IF NVL(pIdMensaje,0) <> 0  THEN

			-- Se obtiene el mensaje de la campaña
			FOREACH
				SELECT mensaje,orden
				INTO cMensajeInc,sOrden
				FROM "informix".si_detcamp
				WHERE empresa = '001'
				AND idmensaje = NVL(pIdMensaje,0)
				ORDER  BY orden ASC

				LET i = 1;
				LET cVariable = "";
				LET cMensaje = "";

				WHILE i <= LENGTH(cMensajeInc)
					IF SUBSTR(cMensajeInc,i,1) = "<" THEN
					
						LET i = i + 1;
						
						WHILE SUBSTR(cMensajeInc,i,1) != ">"
						
						   IF SUBSTR(cMensajeInc,i,1) <> " " tHEN
								LET cVariable = TRIM(cVariable) || SUBSTR(cMensajeInc,i,1);
						   ELSE
								LET cVariable = TRIM(cVariable) || "|";
						   END IF;
							LET i = i + 1;
							
						END WHILE;
						
						--Se reemplaza caracter para respetar el espacio en blanco
						LET cVariable =  REPLACE(cVariable, "|" ," ");

						IF TRIM(NVL(cVariable,'')) <> '' THEN
							-- Se obtiene el valor de la variable
							SELECT valor
							INTO cValorVar
							FROM "informix".si_cat_variables
							WHERE nomvar = TRIM(NVL(cVariable,''));

							LET iRows = DBINFO("sqlca.sqlerrd2");

							IF iRows = 0 THEN
							   -- No se encontraron registros para ese Id de Mensaje
							   LET cCodRet = '000002';
								RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensaje,'')),NVL(sOrden,0);
							END IF;

							LET cMensaje =  REPLACE(cMensajeInc,"<" || TRIM(cVariable) || ">" ,TRIM(NVL(cValorVar,'')));

							LET cVariable = '';
							LET cMensajeInc = TRIM(NVL(cMensaje,''));
							LET i = 1;

						END IF;
						
					END IF;
					
					LET i = i + 1;
					
				END WHILE;

			--Si no encuentra variables en el texto se asigna el texto original
				IF TRIM(NVL(cMensaje,'')) = '' THEN
					LET cMensaje =  TRIM(NVL(cMensajeInc,''));
				END IF;

				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensaje,'')),NVL(sOrden,0) WITH RESUME ;
			END FOREACH;

			LET iRows = DBINFO("sqlca.sqlerrd2");
			
			IF iRows = 0 THEN
			   -- No se encontraron registros para ese Id de Mensaje
			   LET cCodRet = '000002';
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensaje,'')),NVL(sOrden,0);
			END IF;
			
		ELSE
			--Párametros de entrada vacíos
			LET cCodRet = '000001';
			 RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cMensaje,'')),NVL(sOrden,0);
		END IF;

	END
END PROCEDURE
DOCUMENT
'FECHA: 09/04/2015',
'FOLIO :1711',
'PROYECTO: TICKETINTELIGENTEBANCOPPEL',
'DESCRIPCION: PROCEDIMIENTO PARA OBTENER EL MENSAJE DE UNA CAMPANIA',
'AUTOR: ISARAI BOJORQUEZ',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_consulta_campania_multiple(pTipoBusqueda CHAR(1), pId CHAR(5))
--DATOS A REGRESAR---
RETURNING
	CHAR(6)   AS Codigo_retorno,
	SMALLINT  AS Id_Campana,
	SMALLINT  AS Id_Jerarquia,
	CHAR(40)  AS nombre_campana,
	CHAR(5)	  AS producto_campana,
	CHAR(5)	  AS sistema_campana,
	CHAR(8)   AS estado_campana,
	CHAR(55)  AS mensaje_campana,
	CHAR(5)  AS num_transsac,
	CHAR(10)  AS estatus,
	CHAR(5)   AS sucursal;

		
--DEFINICION DE VARIABLES--

--1711
	DEFINE	cCodRet					CHAR(6);
	DEFINE	iSqlErr					INTEGER;
	DEFINE	sIdCampania				SMALLINT;
	DEFINE	sIDJerarquia			SMALLINT;
	DEFINE	sPrimeraVez				SMALLINT;
	DEFINE	sIdCampania2			SMALLINT;
	DEFINE	sIDJerarquia2			SMALLINT;
	DEFINE	cNombre					CHAR(40);
	DEFINE	cProducto				CHAR(5);
	DEFINE	csistema				CHAR(5);
	DEFINE	csistema2				CHAR(5);
	DEFINE	cEstado					CHAR(8);
	DEFINE	sIDMensaje				SMALLINT;
	DEFINE	cIDSucursal				CHAR(20);
	DEFINE	cIDZona					CHAR(5);
	DEFINE	sIdCampaniaRet			SMALLINT;
	DEFINE	sIDJerarquiaRet			SMALLINT;
	DEFINE	cNombreRet				CHAR(65);
	DEFINE	cProductoRet			CHAR(55);
	DEFINE	csistemaRet				CHAR(55);
	DEFINE	csistemaRet2			CHAR(55);
	DEFINE	sEstadoRet				SMALLINT;
	DEFINE	sIDMensajeRet			SMALLINT;
	DEFINE	cIDSucursalRet			CHAR(30);
	DEFINE	cMensaje				CHAR(65);
	DEFINE	sMensaje3				SMALLINT;
	DEFINE	cMensajeRet				CHAR(55);
	DEFINE	iContadorSuc			INTEGER;
	DEFINE	iContadorZona			INTEGER;
	DEFINE	sCombinable				SMALLINT;
	DEFINE	sCombinableRet			SMALLINT;
	DEFINE	cEstatus				CHAR(10);
	DEFINE	cEst					CHAR (10);
	DEFINE	cEstatusRet				CHAR(1);
	DEFINE	cNomProductoRet			CHAR(40);
	DEFINE	sTranNum				SMALLINT;
	DEFINE	cDesTranRet				CHAR(49);
	DEFINE 	cSucursal				CHAR(5);
	DEFINE sActivo 					SMALLINT;
	DEFINE sEstado 					SMALLINT;
	--1711	
	DEFINE	sOrden					SMALLINT;
	DEFINE	sContSist				SMALLINT;
	DEFINE	sContProd				SMALLINT;
	DEFINE	sContSuc				SMALLINT;
	DEFINE  sTranssac				CHAR(5);
	--sp_campaniamensajeporlinea
	DEFINE cCodRet2					CHAR(5);
	DEFINE sActiva					SMALLINT;
	DEFINE cMensaje2				CHAR(65);	
	DEFINE	ssistema				SMALLINT;
	DEFINE	sProd					SMALLINT;
	DEFINE	sSuc					SMALLINT;
	DEFINE 	iSC						INTEGER;
	DEFINE 	iSD						INTEGER;
	DEFINE 	iSE						INTEGER;
	DEFINE iTipoBusqueda			INTEGER;
	DEFINE cPlaza       			CHAR(3);
	DEFINE cTransaccion 			CHAR(10);
	DEFINE iConEst 					INTEGER;
	DEFINE 	sSistema3				CHAR(2);
	DEFINE 	sSistema4				CHAR(2);
	DEFINE 	sSistema5				CHAR(2);
	DEFINE 	sSistema6				CHAR(2);
	
--INICIALIZACION DE VARIABLES--
	LET iConEst 				= 0;
	LET sSistema6 				= '';
	LET sSistema3 				= '';
	LET sSistema4 				= '';
	LET sSistema5 				= '';
	LET cTransaccion 			= '';
	LET cCodRet2 				= '';
	LET cEst 					= '';
	LET cMensaje2				= '';
	LET cSucursal 				= '';
	LET cCodRet					= '000000';
	LET iSqlErr					= 0;
	LET sMensaje3				= 0;
	LET iTipoBusqueda			= 0;
	LET iSC						= 0;
	LET iSD						= 0;
	LET iSE						= 0;
	LET sProd					= 0;
	LET sSuc					= 0;
	LET ssistema				= 0;
	LET sContSist				= 0;
	LET sContProd				= 0;
	LET sContSuc				= 0;
	LET	sIdCampania				= 0;
	LET	sIDJerarquia			= 0;
	LET	sPrimeraVez				= 0;
	LET	sIdCampania2			= 0;
	LET	sIDJerarquia2			= 0;
	LET	cNombre					= "";
	LET	cProducto				= "";
	LET	csistema				= "";
	LET	csistema2				= "";
	LET	cEstado					= '';
	LET	sIDMensaje				= 0;
	LET	cIDSucursal				= "";
	LET	cIDZona					= "";
	LET	sIdCampaniaRet			= 0;
	LET	sIDJerarquiaRet			= 0;
	LET	cNombreRet				= "";
	LET	cProductoRet			= "";
	LET	csistemaRet				= "";
	LET	csistemaRet2			= "";
	LET	sEstadoRet				= 0;
	LET	sIDMensajeRet			= 0;
	LET	cIDSucursalRet			= "";
	LET	cMensaje				= "";
	LET cMensajeRet				= "";
	LET	iContadorSuc			= 0;
	LET	iContadorZona			= 0;
	LET	sCombinable				= 0;
	LET	sCombinableRet			= 0;
	LET	cEstatus				= "";
	LET	cEstatusRet				= "";
	LET	cNomProductoRet			= "";
	LET	sTranNum				= 0;
	LET	cDesTranRet				= "";		
	LET sOrden 					= 0;
	LET sActivo 				= 0;
	LET sestado 				= 0;
	LET sActiva					= 0;
	LET sTranssac				= '';
	LET cPlaza        			= ''; 

	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_consulta_campania_multiple.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),TRIM(NVL(cProductoRet,'')),
				TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')), 
				TRIM(NVL(cIDSucursalRet,''));
			END IF;
		END EXCEPTION;	

		IF TRIM(NVL(pTipoBusqueda,'')) <> '' AND  TRIM(NVL(pId,'')) <> '' THEN
			--BUSQUEDA POR SUCURSAL
			IF pTipoBusqueda = '0' THEN
			
				FOREACH

				-- Se obtienen los datos de las campañas
					SELECT DISTINCT idcamp,idJerarquia,idmensaje 
					INTO sIdCampania,sIDJerarquia,sIdMensaje			   
					FROM "informix".si_maecamp
					WHERE sucursal = TRIM(pId)
					OR sucursal = 'T'
					
					--CUANDO SE OBTIENE EL PRIMER REGISTRO
					LET sPrimeraVez = 1;

					FOREACH
					
						SELECT DISTINCT DECODE(num_producto, 'T','T',num_producto),DECODE(sistema,'T','T',sistema),activa,estatus			
						INTO cProducto, csistema,sActiva,cEstatus
						FROM "informix".si_maecamp
						WHERE (sucursal = TRIM(pId) or sucursal = 'T')
						AND idcamp = NVL(sIdCampania,0)
						AND idjerarquia = NVL(sIDJerarquia,0)
						
						
						--CONTABILIZA EL NUMERO DE sistemaS QUE EXISTEN PARA LA CAMPAÑA
						SELECT COUNT(DISTINCT sistema) INTO ssistema FROM "informix".si_maecamp  
						WHERE (sucursal = TRIM(pId) or sucursal = 'T') AND idcamp = NVL(sIdCampania,0)	
						AND idjerarquia = NVL(sIDJerarquia,0) AND sistema <> '';

						
						--CONTABILIZA EL NUMERO DE PRODUCTOS QUE EXISTEN PARA LA CAMPAÑA
						SELECT COUNT(DISTINCT num_producto) INTO sProd FROM "informix".si_maecamp  
						WHERE idcamp =   NVL(sIdCampania,0)	AND idjerarquia = NVL(sIDJerarquia,0) 
						AND num_producto = TRIM(NVL(cProducto,'')) AND num_producto IS NOT NULL
						AND (sucursal = TRIM(pId) or sucursal = 'T');
			
						--SI EXISTEN PRODUCTOS
						IF NVL(sProd,0) = 1 AND TRIM(cProductoRet) <>  TRIM(cProducto) THEN 
							LET sContProd = sContProd + 1 ;
						END IF;	
						
						IF sPrimeraVez = 1 THEN
							--SE GUARDA EL IDCAMPAÑA, IDJERARQUIA, NOMBRE CAMAPAÑA, PRODUCTO, sistema, STATUS, SI ESTA ACTIVA, SI ES COMBINABLE Y EL IDMENSAJE LA CAMAPAÑA PARA DESPUES RETORNARLO
							LET sIdCampaniaRet =   NVL(sIdCampania,0);
							LET sIDJerarquiaRet = NVL(sIDJerarquia,0);
							LET cProductoRet = TRIM(NVL(cProducto,''));
							LET csistemaRet = TRIM(NVL(csistema,''));
							LET	cEstatusRet = TRIM(NVL(cEstatus,''));
							LET sIDMensajeRet = NVL(sIDMensaje,0);
							
							LET sPrimeraVez = 0;
						ELSE

							--SI EXISTEN MAS DE UN PRODUCTO SE RETORNA LA LETRA V
							IF sContProd > 1 AND TRIM(cProductoRet) <>  TRIM(cProducto)THEN
								LET cProductoRet = 'V';
							ELSE
								--SI SOLO EXISTE UN PRODUCTO
								LET cProductoRet = TRIM(NVL(cProducto,''));
							END IF;
						END IF;
						
						--SI EXISTEN sistemaS
						IF NVL(ssistema,0) = 1 THEN
							IF (NVL(cSistema,'')) <> '' THEN
								LET cSistemaRet2 = TRIM(NVL(cSistema,'')) ;
							ELSE
								LET cSistemaRet2 = TRIM(NVL(cSistemaRet2,'')) ;
							END IF;
						ELIF NVL(ssistema,0) = 3 THEN
							LET cSistemaRet2 = TRIM(NVL('T','')) ;
						ELIF NVL(ssistema,0) = 2 THEN	
							FOREACH
								SELECT DISTINCT DECODE(sistema,'T','T',sistema),sistema
								INTO sSistema3,ssistema6
								FROM "informix".si_maecamp
								WHERE empresa = TRIM('001')
								AND idcamp =  NVL(sIdCampania,0)
								AND idjerarquia = NVL(sIDJerarquia,0)
								ORDER BY sistema ASC 	

								SELECT DISTINCT DECODE(sistema,'T','T',sistema)
								INTO sSistema4
								FROM "informix".si_maecamp
								WHERE empresa = TRIM('001')
								AND idcamp =  NVL(sIdCampania,0)
								AND idjerarquia = NVL(sIDJerarquia,0)	
								AND sistema <> TRIM(sSistema3);

								LET cSistemaRet2 = TRIM(sSistema4) || "|" || TRIM(sSistema3);
							END FOREACH	
						END IF;
						
						--SI EXISTE MAS DE UN RENGLON CON INFORMACION
						IF (SELECT  COUNT (mensaje) FROM "informix".si_detcamp WHERE idmensaje = sIdMensaje ) =  1 THEN
							--SI LA CAMPAÑA TIENE SOLO UN RENGLON PARA EL MENSAJE
							--SE OBTIENE LA DESCRIPCION DEL MENSAJE
							SELECT FIRST 1 orden INTO sOrden FROM "informix".si_detcamp 
							WHERE idmensaje = NVL(sIDMensaje,0) AND NVL(mensaje,'') <> '';
			
							EXECUTE  PROCEDURE "informix".sp_campaniamensajeporlinea(sIdMensaje,sOrden) INTO cCodRet2,cMensaje2;
							--OCURRIO UN ERROR EN EL LLAMADO DEL PROCEDIMIENTO
							IF  NVL(cCodRet2:: INTEGER,0) <> 0 THEN
								LET cCodRet = NVL(cCodRet2:: INTEGER,0);
								RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),
								TRIM(NVL(cProductoRet,'')),TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),
								TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')), TRIM(NVL(cIDSucursalRet,''));
							ELSE
								--SE OBTIENE LA DESCRIPCION DEL MENSAJE
								LET cMensaje = TRIM(TRIM(NVL(sIdMensaje,0)::CHAR(5))||"|"||TRIM(NVL(cMensaje2,''))); 
							END IF 
						ELSE

							--SI EXISTE MAS DE UN RENGLON PARA EL MENSAJE DE LA CAMPAÑA
							LET cMensaje  = TRIM(TRIM(NVL(sIdMensaje,0)::CHAR(5))||"|"||'V');
						END IF;
							
						--SE OBTIENE EL ESTADO DE LA CAMPAÑA
						SELECT FIRST 1 activa INTO sActivo FROM "informix".si_maecamp		
						WHERE idcamp =   NVL(sIdCampania,0)	AND idjerarquia = NVL(sIDJerarquia,0) AND (sucursal = TRIM(pId) or sucursal = 'T') ; 

						IF NVL(sActivo,0) = 1 THEN
							LET cEstado =  TRIM('SI');
						ELSE
							LET cEstado =  TRIM('NO');
						END IF;	
						
						IF csistema = 'SD' OR csistema = 'T' THEN
								SELECT COUNT(DISTINCT estatus) INTO iConEst FROM "informix".si_maecamp WHERE idcamp =   NVL(sIdCampania,0) 
								AND idjerarquia = NVL(sIDJerarquia,0) 
								AND (sucursal = TRIM(pId) or sucursal = 'T')
								AND (sistema = 'SD' or sistema = 'T')
								AND sistema = TRIM(NVL(csistema,'')) ;
								
								IF iConEst = 1 THEN
									SELECT DISTINCT DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS') 
									INTO cEstatus  FROM "informix".si_maecamp WHERE idcamp =   NVL(sIdCampania,0) 
									AND idjerarquia = NVL(sIDJerarquia,0) 
									AND (sucursal = TRIM(pId) or sucursal = 'T')
									AND (sistema = 'SD' or sistema = 'T')
									AND sistema = TRIM(NVL(csistema,'')) ;
								ELIF iConEst > 1 THEN
									--SI ES MAS DE UN ESTATUS
									LET cEstatus = TRIM('V');
								ELIF iConEst = 0 THEN	
									LET cEstatus = TRIM('NO APLICA');
								END IF;
								
						ELSE	
							IF 	iConEst = 1 THEN
								SELECT DISTINCT DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS') 
								INTO cEstatus  FROM "informix".si_maecamp WHERE idcamp =   NVL(sIdCampania,0) 
								AND idjerarquia = NVL(sIDJerarquia,0) 
								AND (sucursal = TRIM(pId) or sucursal = 'T')
								AND (sistema = 'SD' or sistema = 'T');
								--and sistema = csistema ;
							ELIF iConEst > 1 THEN
								--SI ES MAS DE UN ESTATUS
								LET cEstatus = TRIM('V');
							ELIF iConEst = 0 THEN	
								LET cEstatus = TRIM('NO APLICA');
							END IF;
						END IF;	
							
						--SE OBTIENEN LAS TRANSACCIONES POR CADA CAMPAÑA
						IF ( SELECT COUNT(DISTINCT tran_nro) FROM "informix".si_maecamp WHERE idcamp =   NVL(sIdCampania,0) 
							AND idjerarquia = NVL(sIDJerarquia,0) AND (sucursal = TRIM(pId) or sucursal = 'T')) = 1 THEN
							
							SELECT DISTINCT TRIM(tran_nro::CHAR(5)) INTO sTranssac FROM "informix".si_maecamp WHERE idcamp =   NVL(sIdCampania,0) 
							AND idjerarquia = NVL(sIDJerarquia,0) AND (sucursal = TRIM(pId) or sucursal = 'T');
							
							IF TRIM(NVL(sTranssac,''))= '0' THEN
								LET cTransaccion = TRIM('T');
							ELSE
								LET cTransaccion = TRIM(sTranssac::CHAR(5)) ;
							END IF;
						ELSE
							LET cTransaccion = TRIM('V');
						END IF;	
						
						--SE OBTIENE EL NOMBRE DE LA CAMPAÑA
						SELECT FIRST 1  nombre INTO cNombreRet  FROM "informix".si_maecamp		
						WHERE idcamp =   NVL(sIdCampania,0)	AND idjerarquia = NVL(sIDJerarquia,0);
							
						LET cIDSucursalRet = TRIM(NVL(pid,''));
						--LET iconest = 0;
					END FOREACH;
					 	
					RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(SIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),
						TRIM(NVL(cProductoRet,'')),TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),
						TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')), TRIM(NVL(cIDSucursalRet,'')) WITH RESUME;
					LET csistema = ''; 
					LET csistemaRet2 = '';	
					LET scontsist = 0;
					LET sContProd = 0;	
					LET iconest = 0;
				END FOREACH	;
						
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					--NO EXISTEN CAMPAÑAS
						LET cCodRet = '000002';
						RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),
						TRIM(NVL(cProductoRet,'')), TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),
						TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')),TRIM(NVL(cIDSucursalRet,''));
					END IF;
					
					LET sIdCampaniaRet = 0; 
					LET sIDJerarquiaRet = 0; 
					LET cNombreRet = ''; 
					LET cProductoRet = '';
					LET csistemaRet2 = ''; 
					LET cEstado =''; 
					LET cMensaje = ''; 
					LET cTransaccion = '';
					LET cEstatus = ''; 
					LET cIDSucursalRet = '';
					LET csistema2='';
					
				--BUSCAR SI LA SUCURSAL PERTENECE A UNA ZONA PARA RETORNAR LAS CAMPAÑAS DE LAS ZONAS
				SELECT plaza INTO cPlaza FROM "informix".si_sucursales WHERE sucursal = TRIM(NVL(pid,''));	
				
				--CUANDO LA BUSQUEDA ES POR ZONA
				IF EXISTS (SELECT 1 FROM "informix".si_maecamp WHERE idzona = TRIM(NVL(cPlaza,0))) 
					AND NVL(cCodRet:: INTEGER,0) = 0 THEN
				
					FOREACH
						-- Se obtienen los datos de las campañas
						SELECT DISTINCT idcamp,idJerarquia,idmensaje 
						INTO sIdCampania,sIDJerarquia,sIdMensaje			   
						FROM "informix".si_maecamp
						WHERE idzona = TRIM(NVL(cPlaza,''))
						
						--CUANDO SE OBTIENE EL PRIMER REGISTRO
						LET sPrimeraVez = 1;
						LET iContadorSuc = 1;
						
						FOREACH
							SELECT DISTINCT DECODE(num_producto, 'T','T',num_producto),DECODE(sistema,'T','T',sistema)
							INTO cProducto, csistema
							FROM "informix".si_maecamp
							WHERE idcamp =   NVL(sIdCampania,0)
							AND idjerarquia = NVL(sIDJerarquia,0)
							AND idzona = TRIM(NVL(cPlaza,''))
							
							--CONTABILIZA EL NUMERO DE sistemaS QUE EXISTEN PARA LA CAMPAÑA
							SELECT COUNT(DISTINCT sistema) INTO ssistema FROM "informix".si_maecamp  
							WHERE idcamp =   NVL(sIdCampania,0)	
							AND idjerarquia = NVL(sIDJerarquia,0)  AND sistema <> ''
							AND idzona = TRIM(NVL(cPlaza,''));
							
							--CONTABILIZA EL NUMERO DE PRODUCTOS QUE EXISTEN PARA LA CAMPAÑA
							SELECT COUNT(DISTINCT num_producto) INTO sProd FROM "informix".si_maecamp  
							WHERE idcamp =   NVL(sIdCampania,0)	
							AND idjerarquia = NVL(sIDJerarquia,0) AND num_producto = TRIM(NVL(cProducto,'')) 
							AND num_producto IS NOT NULL
							AND idzona = TRIM(NVL(cPlaza,''));

							--SI EXISTEN PRODUCTOS
							IF NVL(sProd,0) = 1 AND TRIM(cProductoRet) <>  TRIM(cProducto) THEN 
								LET sContProd = NVL(sContProd,0) + 1 ;
							END IF;	
							
							IF sPrimeraVez = 1 THEN
								--SE GUARDA EL IDCAMPAÑA, IDJERARQUIA, NOMBRE CAMAPAÑA, PRODUCTO, sistema, STATUS, SI ESTA ACTIVA, SI ES COMBINABLE Y EL IDMENSAJE LA CAMAPAÑA PARA DESPUES RETORNARLO
								LET sIdCampaniaRet =   NVL(sIdCampania,0);
								LET sIDJerarquiaRet = NVL(sIDJerarquia,0);
								LET cProductoRet = TRIM(NVL(cProducto,''));
								LET csistemaRet = TRIM(NVL(csistema,''));
								LET	cEstatusRet = TRIM(NVL(cEstatus,''));
								LET sIDMensajeRet = NVL(sIDMensaje,0);
								LET sPrimeraVez = 0;
							ELSE

								--SI EXISTEN MAS DE UN PRODUCTO SE RETORNA LA LETRA V
								IF sContProd > 1 AND TRIM(cProductoRet) <>  TRIM(cProducto)THEN
									LET cProductoRet = 'V';
								ELSE
									--SI SOLO EXISTE UN PRODUCTO
									LET cProductoRet = TRIM(NVL(cProducto,''));
								END IF;
							END IF;
							
							--SI EXISTEN sistemaS
							IF NVL(ssistema,0) = 1 THEN
								IF (NVL(cSistema,'')) <> '' THEN
									LET cSistemaRet2 = TRIM(NVL(cSistema,'')) ;
								ELSE
									LET cSistemaRet2 = TRIM(NVL(cSistemaRet2,'')) ;
								END IF;
							ELIF NVL(ssistema,0) = 3 THEN
								LET cSistemaRet2 = TRIM(NVL('T','')) ;
							ELIF NVL(ssistema,0) = 2 THEN	
								FOREACH
									SELECT DISTINCT DECODE(sistema,'T','T',sistema),sistema
									INTO sSistema3,ssistema6
									FROM "informix".si_maecamp
									WHERE empresa = TRIM('001')
									AND idcamp =  NVL(sIdCampania,0)
									AND idjerarquia = NVL(sIDJerarquia,0)
									ORDER BY sistema ASC
									
									SELECT DISTINCT DECODE(sistema,'T','T',sistema) 
									INTO sSistema4
									FROM "informix".si_maecamp
									WHERE empresa = TRIM('001')
									AND idcamp =  NVL(sIdCampania,0)
									AND idjerarquia = NVL(sIDJerarquia,0)	
									AND sistema <> TRIM(sSistema3);
									
									LET cSistemaRet2 = TRIM(sSistema4) || "|" || TRIM(sSistema3);
								END FOREACH	
							END IF;
							--SI EXISTE MAS DE UN RENGLON CON INFORMACION
							IF (SELECT  COUNT (mensaje) FROM "informix".si_detcamp WHERE idmensaje = NVL(sIDMensaje,0) ) =  1 THEN
								--SI LA CAMPAÑA TIENE SOLO UN RENGLON PARA EL MENSAJE
								--SE OBTIENE LA DESCRIPCION DEL MENSAJE
								SELECT FIRST 1 orden INTO sOrden FROM "informix".si_detcamp 
								WHERE idmensaje = NVL(sIDMensaje,0) AND NVL(mensaje,'') <> '';
				
								EXECUTE  PROCEDURE "informix".sp_campaniamensajeporlinea(sIdMensaje,sOrden) INTO cCodRet2,cMensaje2;
								--OCURRIO UN ERROR EN EL LLAMADO DEL PROCEDIMIENTO
								IF  NVL(cCodRet2:: INTEGER,0) <> 0 THEN
									LET cCodRet = NVL(cCodRet2:: INTEGER,0);
									RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),
										  TRIM(NVL(cNombreRet,'')),TRIM(NVL(cProductoRet,'')),TRIM(NVL(csistemaRet2,'')),
										  TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')), TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')), 
										  TRIM(NVL(cIDSucursalRet,''));
								ELSE
									--SE OBTIENE LA DESCRIPCION DEL MENSAJE
									LET cMensaje = TRIM(TRIM(NVL(sIdMensaje,0)::CHAR(5))||"|"||TRIM(NVL(cMensaje2,'')));
								END IF; 
							ELSE

								LET cMensaje  = TRIM(TRIM(NVL(sIdMensaje,0)::CHAR(5))||"|"||'V');
							END IF;
							
							--SE OBTIENE EL ESTADO DE LA CAMPAÑA
							SELECT FIRST 1 activa INTO sActivo FROM "informix".si_maecamp		
							WHERE idcamp = NVL(sIdCampania,0)AND idjerarquia = NVL(sIDJerarquia,0) AND idzona = TRIM(NVL(cPlaza,'')) ; 

							IF NVL(sActivo,0) = 1 THEN
								LET cEstado =  TRIM('SI');
							ELSE
								LET cEstado =  TRIM('NO');
							END IF;	
								
							--SE OBTIENE EL ESTATUS DE LA CAMPAÑA SOLO PARA LOS DE CREDITO 
							IF csistema = 'SD' OR csistema = 'T' THEN
								SELECT COUNT(DISTINCT estatus) INTO iConEst FROM "informix".si_maecamp 
								WHERE idcamp =   NVL(sIdCampania,0) 
								AND idjerarquia = NVL(sIDJerarquia,0) 
								AND idzona = TRIM(NVL(cPlaza,''))
								AND (sistema = 'SD' or sistema = 'T')
								AND sistema = TRIM(NVL(cSistema,''));
								
								IF iConEst = 1 THEN
									SELECT DISTINCT DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS') 
									INTO cEstatus  FROM "informix".si_maecamp 
									WHERE idcamp =   NVL(sIdCampania,0) 
									AND idjerarquia = NVL(sIDJerarquia,0) 
									AND idzona = TRIM(NVL(cPlaza,''))
									AND (sistema = 'SD' or sistema = 'T')
									AND sistema = TRIM(NVL(cSistema,''));
								ELIF iConEst > 1 THEN
									--SI ES MAS DE UN ESTATUS
									LET cEstatus = TRIM('V');
								ELIF iConEst = 0 THEN	
									LET cEstatus = TRIM('NO APLICA');
								END IF;
							ELSE	
								IF 	iConEst = 1 THEN
									SELECT DISTINCT DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS') 
									INTO cEstatus  FROM "informix".si_maecamp 
									WHERE idcamp = NVL(sIdCampania,0) 
									AND idjerarquia = NVL(sIDJerarquia,0) 
									AND idzona = TRIM(NVL(cPlaza,''))
									AND (sistema = 'SD' or sistema = 'T');
								ELIF iConEst > 1 THEN
									--SI ES MAS DE UN ESTATUS
									LET cEstatus = TRIM('V');
								ELIF iConEst = 0 THEN	
									LET cEstatus = TRIM('NO APLICA');
								END IF;
							END IF;		
								
							--SE OBTIENEN LAS TRANSACCIONES POR CADA CAMPAÑA
							IF ( SELECT COUNT(DISTINCT tran_nro) FROM "informix".si_maecamp WHERE idcamp =   NVL(sIdCampania,0) 
								AND idjerarquia = NVL(sIDJerarquia,0) AND idzona = TRIM(NVL(cPlaza,'')))  = 1 THEN
								
								SELECT DISTINCT TRIM(tran_nro::CHAR(5)) INTO sTranssac FROM "informix".si_maecamp 
								WHERE idcamp =   NVL(sIdCampania,0)	AND idjerarquia = NVL(sIDJerarquia,0) AND idzona = TRIM(NVL(cPlaza,'')) ;
								
								IF TRIM(NVL(sTranssac,''))= '0' THEN
									LET cTransaccion = TRIM('T');
								ELSE
									LET cTransaccion = TRIM(sTranssac::CHAR(5)) ;
								END IF;
							ELSE
								LET cTransaccion = TRIM('V');
							END IF;	
							
							--SE OBTIENE EL NOMBRE DE LA CAMPAÑA
							SELECT FIRST 1 nombre INTO cNombreRet  FROM "informix".si_maecamp		
							WHERE idcamp =   NVL(sIdCampania,0)	AND idjerarquia = NVL(sIDJerarquia,0);

							LET cIDSucursalRet = '';
							--	LET iconest = 0;

						END FOREACH;
						
					 	RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),
							TRIM(NVL(cProductoRet,'')),TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),
							TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')), TRIM(NVL(cIDSucursalRet,'')) WITH RESUME;
	
						LET csistema = ''; 
						LET csistemaRet2 = '';
						LET scontsist = 0;
						LET sContProd = 0;
					LET iconest = 0;
						
					END FOREACH	;

					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					--NO EXISTEN CAMPAÑAS
						LET cCodRet = "000002";
						RETURN TRIM(NVL(cCodRet,'')),NVL(SIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),TRIM(NVL(cProductoRet,'')),
						TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')),
						TRIM(NVL(cIDSucursalRet,''));
					END IF;
				END IF;
			ELSE 
				--CUANDO LA BUSQUEDA ES POR ZONA
				FOREACH
			
					-- Se obtienen los datos de las campañas
					SELECT DISTINCT idcamp,idJerarquia,idmensaje 
					INTO sIdCampania,sIDJerarquia,sIdMensaje			   
					FROM "informix".si_maecamp
					WHERE idzona = TRIM(NVL(pId,'')) 
					
					--CUANDO SE OBTIENE EL PRIMER REGISTRO
					LET sPrimeraVez = 1;
					LET iContadorSuc = 1;
					
					FOREACH
						
						SELECT DISTINCT DECODE(num_producto, 'T','T',num_producto),DECODE(sistema,'T','T',sistema)
						INTO cProducto, csistema
						FROM "informix".si_maecamp
						WHERE idcamp =   NVL(sIdCampania,0)
						AND idjerarquia = NVL(sIDJerarquia,0)
						AND idzona = TRIM(NVL(pId,''))
						
						--CONTABILIZA EL NUMERO DE sistemaS QUE EXISTEN PARA LA CAMPAÑA
						SELECT COUNT(DISTINCT sistema) INTO ssistema FROM "informix".si_maecamp  
						WHERE idcamp =   NVL(sIdCampania,0)	
						AND idjerarquia = NVL(sIDJerarquia,0)  AND sistema <> ''
						AND idzona = TRIM(NVL(pId,''));
						
						--CONTABILIZA EL NUMERO DE PRODUCTOS QUE EXISTEN PARA LA CAMPAÑA
						SELECT COUNT(DISTINCT num_producto) INTO sProd FROM "informix".si_maecamp  
						WHERE idcamp =   NVL(sIdCampania,0)	
						AND idjerarquia = NVL(sIDJerarquia,0) AND num_producto = TRIM(NVL(cProducto,'')) AND num_producto IS NOT NULL
						AND idzona = TRIM(NVL(pId,''));
					
						--SI EXISTEN PRODUCTOS
						IF NVL(sProd,0) = 1 AND TRIM(cProductoRet) <>  TRIM(cProducto) THEN 
							LET sContProd = sContProd + 1 ;
						END IF;	
						
						IF sPrimeraVez = 1 THEN
							--SE GUARDA EL IDCAMPAÑA, IDJERARQUIA, NOMBRE CAMAPAÑA, PRODUCTO, sistema, STATUS, SI ESTA ACTIVA, SI ES COMBINABLE Y EL IDMENSAJE LA CAMAPAÑA PARA DESPUES RETORNARLO
							LET sIdCampaniaRet =   NVL(sIdCampania,0);
							LET sIDJerarquiaRet = NVL(sIDJerarquia,0);
							LET cProductoRet = TRIM(NVL(cProducto,''));
							LET csistemaRet = TRIM(NVL(csistema,''));
							LET	cEstatusRet = TRIM(NVL(cEstatus,''));
							LET sIDMensajeRet = NVL(sIDMensaje,0);
							LET sPrimeraVez = 0;
						ELSE
							
							--SI EXISTEN MAS DE UN PRODUCTO SE RETORNA LA LETRA V
							IF sContProd > 1 AND TRIM(cProductoRet) <>  TRIM(cProducto)THEN
								LET cProductoRet = 'V';
							ELSE
								--SI SOLO EXISTE UN PRODUCTO
								LET cProductoRet = TRIM(NVL(cProducto,''));
							END IF;
						END IF;
						
						--SI EXISTEN sistemaS
						IF NVL(ssistema,0) = 1 THEN
							IF (NVL(cSistema,'')) <> '' THEN
								LET cSistemaRet2 = TRIM(NVL(cSistema,'')) ;
							ELSE
								LET cSistemaRet2 = TRIM(NVL(cSistemaRet2,'')) ;
							END IF;
						ELIF NVL(ssistema,0) = 3 THEN
							LET cSistemaRet2 = TRIM(NVL('T','')) ;
						ELIF NVL(ssistema,0) = 2 THEN	
							FOREACH
								SELECT DISTINCT DECODE(sistema,'T','T',sistema),sistema
								INTO sSistema3,ssistema6
								FROM "informix".si_maecamp
								WHERE empresa = TRIM('001')
								AND idcamp =  NVL(sIdCampania,0)
								AND idjerarquia = NVL(sIDJerarquia,0)
								ORDER BY sistema ASC

								SELECT DISTINCT DECODE(sistema,'T','T',sistema) 
								INTO sSistema4
								FROM "informix".si_maecamp
								WHERE empresa = TRIM('001')
								AND idcamp =  NVL(sIdCampania,0)
								AND idjerarquia = NVL(sIDJerarquia,0)	
								AND sistema <> TRIM(sSistema3);

								LET cSistemaRet2 = TRIM(sSistema4) || "|" || TRIM(sSistema3);
							END FOREACH	
						END IF;	
						--SI EXISTE MAS DE UN RENGLON CON INFORMACION
						IF (SELECT  COUNT (mensaje) FROM "informix".si_detcamp WHERE idmensaje = NVL(sIDMensaje,0)) =  1 THEN
							--SI LA CAMPAÑA TIENE SOLO UN RENGLON PARA EL MENSAJE
							--SE OBTIENE LA DESCRIPCION DEL MENSAJE
							SELECT FIRST 1 orden INTO sOrden FROM "informix".si_detcamp 
							WHERE idmensaje = NVL(sIDMensaje,0) AND NVL(mensaje,'') <> '';
			
							EXECUTE  PROCEDURE "informix".sp_campaniamensajeporlinea(sIdMensaje,sOrden) INTO cCodRet2,cMensaje2;
							--OCURRIO UN ERROR EN EL LLAMADO DEL PROCEDIMIENTO
							IF  NVL(cCodRet2:: INTEGER,0) <> 0 THEN
								LET cCodRet = NVL(cCodRet2:: INTEGER,0);
								RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),
								TRIM(NVL(cProductoRet,'')),TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),
								TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')), TRIM(NVL(cIDSucursalRet,''));
							ELSE
								--SE OBTIENE LA DESCRIPCION DEL MENSAJE
								LET cMensaje = TRIM(TRIM(NVL(sIdMensaje,0)::CHAR(5))||"|"||TRIM(NVL(cMensaje2,'')));
							END IF 
						ELSE
							LET cMensaje  = TRIM(TRIM(NVL(sIdMensaje,0)::CHAR(5))||"|"||'V');
						END IF;
						
						--SE OBTIENE EL ESTADO DE LA CAMPAÑA
						SELECT FIRST 1 activa INTO sActivo  FROM "informix".si_maecamp		
						WHERE idcamp =   NVL(sIdCampania,0)	AND idjerarquia = NVL(sIDJerarquia,0) AND idzona = TRIM(NVL(pId,'')) ; 

						IF NVL(sActivo,0) = 1 THEN
							LET cEstado =  TRIM('SI');
						ELSE
							LET cEstado =  TRIM('NO');
						END IF;	
					
						IF csistema = 'SD' OR csistema = 'T' THEN
							SELECT COUNT(DISTINCT estatus) INTO iConEst FROM "informix".si_maecamp WHERE idcamp =   NVL(sIdCampania,0) 
							AND idjerarquia = NVL(sIDJerarquia,0) AND idzona = TRIM(NVL(pId,''))
							AND (sistema = 'SD' or sistema = 'T')
							AND sistema = TRIM(NVL(csistema,''));
							
							IF iConEst = 1 THEN
								SELECT DISTINCT DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS') 
								INTO cEstatus  FROM "informix".si_maecamp WHERE idcamp = NVL(sIdCampania,0) 
								AND idjerarquia = NVL(sIDJerarquia,0) 
								AND idzona = TRIM(NVL(pId,''))
								AND (sistema = 'SD' or sistema = 'T')
								AND sistema = TRIM(NVL(csistema,''));
							ELIF iConEst > 1 THEN
								--SI ES MAS DE UN ESTATUS
								LET cEstatus = TRIM('V');
							ELIF iConEst = 0 THEN	
								LET cEstatus = TRIM('NO APLICA');
							END IF;
						ELSE	
							IF 	iConEst = 1 THEN
								SELECT DISTINCT DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS') 
								INTO cEstatus  FROM "informix".si_maecamp WHERE idcamp =   NVL(sIdCampania,0) 
								AND idjerarquia = NVL(sIDJerarquia,0) 
								AND idzona = TRIM(NVL(pId,''))
								AND (sistema = 'SD' or sistema= 'T');
							ELIF iConEst > 1 THEN
								--SI ES MAS DE UN ESTATUS
								LET cEstatus = TRIM('V');
							ELIF iConEst = 0 THEN	
								LET cEstatus = TRIM('NO APLICA');
							END IF;
						END IF;	
						
						--SE OBTIENEN LAS TRANSACCIONES POR CADA CAMPAÑA
						IF ( SELECT COUNT(DISTINCT tran_nro) FROM "informix".si_maecamp WHERE idcamp = NVL(sIdCampania,0) 
							AND idjerarquia = NVL(sIDJerarquia,0) AND idzona = TRIM(NVL(pId,'')))  = 1 THEN
							
							SELECT DISTINCT TRIM(tran_nro::CHAR(5)) INTO sTranssac FROM "informix".si_maecamp WHERE idcamp = NVL(sIdCampania,0) 
							AND idjerarquia = NVL(sIDJerarquia,0) AND idzona = TRIM(NVL(pId,'')) ;
							
							IF TRIM(NVL(sTranssac,''))= '0' THEN
								LET cTransaccion = TRIM('T');
							ELSE
								LET cTransaccion = TRIM(sTranssac::CHAR(5)) ;
							END IF;
						ELSE
							LET cTransaccion = TRIM('V');
						END IF;	
						
						--SE OBTIENE EL NOMBRE DE LA CAMPAÑA
						SELECT FIRST 1 nombre INTO cNombreRet  FROM "informix".si_maecamp		
						WHERE idcamp =   NVL(sIdCampania,0)	AND idjerarquia = NVL(sIDJerarquia,0);
						
						LET cIDSucursalRet = '';
						--LET iconest = 0;
					END FOREACH;
			
					 RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),
						TRIM(NVL(cProductoRet,'')),TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),
						TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')), TRIM(NVL(cIDSucursalRet,'')) WITH RESUME;
						
					LET csistema = ''; 
					LET csistemaRet2 = '';
					LET scontsist = 0;
					LET sContProd = 0;
					LET iconest = 0;
				END FOREACH	;

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				--NO EXISTEN CAMPAÑAS
					LET cCodRet = '000002';
					RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),
					TRIM(NVL(cProductoRet,'')),	TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),
					TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')), TRIM(NVL(cIDSucursalRet,''));
				END IF; 
			END IF;	
		ELSE 
			-- Parámetros de entrada vacíos
			LET cCodRet = '000001';
			RETURN TRIM(NVL(cCodRet,'')),NVL(sIdCampaniaRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),TRIM(NVL(cProductoRet,'')),
				TRIM(NVL(csistemaRet2,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cMensaje,'')),TRIM(NVL(cTransaccion,'')),TRIM(NVL(cEstatus,'')),
				TRIM(NVL(cIDSucursalRet,''));
		END IF;				
	END
END PROCEDURE
DOCUMENT
'FECHA: 09/04/2015',
'FOLIO :1711',
'PROYECTO: TICKETINTELIGENTEBANCOPPEL',
'DESCRIPCION: PROCEDIMIENTO PARA OBTENER TODAS LAS CAMPANIAS QUE TIENE UNA SUCURSAL O ZONA',
'AUTOR: ISARAI BOJORQUEZ',
'FECHA: 05/05/2015',
'MODIFICACION: SE MODIFICA PARA CONSULTAR TODAS LAS SUCURSALES SI EL PARAMETRO O SUCURSAL ES IGUAL A T',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_modificaguardacampania_multiple(
cEmpresa 		CHAR(3), 
cSucursal 		CHAR(5), 
cZona 			CHAR(5), 
cSistema 		CHAR(2), 
cProducto 		CHAR(5), 
sTransaccion 	SMALLINT, 
cEstatus 		CHAR(1), 
sNivel 			SMALLINT, 
sActiva 		SMALLINT, 
sAct_Zona 		SMALLINT, 
sCombinable 	SMALLINT, 
sCampania 		SMALLINT, 
sJerarquia 		SMALLINT, 
cMensaje1 		CHAR(55), 
cMensaje2 		CHAR(55), 
cMensaje3 		CHAR(55), 
cMensaje4 		CHAR(55), 
cMensaje5 		CHAR(55), 
cMensaje6 		CHAR(55),
cNomCamp 		CHAR(40), 
cCampNueva 		CHAR(1)) --DSB 20-08-2013 SE AGREGA EL PARAMETRO CNOMCAMP Y CCAMPNUEVA
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Guarda o modifica la información de la campaña
--Realizó: Nancy Sevilla Camacho
 
--MODIFICACION: 
--DSB 20-08-2013
--DESCRIPCION: Se modifica para que inserte nombre de campaña y cree un solo mensaje por campaña
--MODIFICO:   Vega
--FECHA MODIFICACION: 20/Agosto/2013
--------------------------------------------------------------------

	--DATOS A REGRESAR---
	RETURNING
		CHAR(6) AS Codigo_retorno;

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr      INTEGER;
	DEFINE cCodRet      CHAR(6);

	---------------------------	
	DEFINE sIdMensajeMax SMALLINT;
	DEFINE sIdMensaje SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr       = 0;
	LET cCodRet       = '000000';
	LET sIdMensajeMax = 0;
	LET sIdMensaje    = 0;

	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_modificaguardacampania_multiple.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,''));
			END IF;
		END EXCEPTION;	
		
		IF NVL(cEmpresa,'') = '' OR NVL(sCampania, 0) = 0 OR NVL(sJerarquia, 0) = 0 THEN
		
			LET cCodRet = '000002';
			RETURN TRIM(NVL(cCodRet,''));
		
		ELSE
				
			IF TRIM(cCampNueva) <> "1" THEN --MODIFICAR CAMPAÑA
			
				IF TRIM(cProducto) = "0" THEN
					LET cProducto = "T";
				END IF;
				
				--Se obtiene el ID del mensaje de la campaña a modificar para no perderlo
				SELECT FIRST 1 idmensaje
				INTO sIdMensaje
				FROM "informix".si_maecamp
				WHERE idcamp = NVL(sCampania, 0)
				AND idJerarquia = NVL(sJerarquia, 0)
				AND empresa = cEmpresa
				AND sucursal IS NOT NULL
				AND empresa IS NOT NULL
				AND num_producto IS NOT NULL
				AND sistema IS NOT NULL
				AND estatus IS NOT NULL
				AND tran_nro IS NOT NULL;
				
				IF TRIM(cCampNueva) = "2" THEN
					--Se borra la campaña existente para crearla nuevamente con la nueva informacion
					DELETE FROM "informix".si_maecamp
					WHERE idcamp = NVL(sCampania, 0)
					AND idJerarquia = NVL(sJerarquia, 0)
					AND empresa = NVL(cEmpresa,'');
					
					--Se borra el mensaje existente para crearlo nuevamente con la informacion nueva
					IF NVL(sIdMensaje,0) <> 0 OR NVL(sIdMensaje,0) IS NOT NULL THEN
						DELETE FROM "informix".si_detcamp 
						WHERE empresa = NVL(cEmpresa,'') 
						AND idmensaje = NVL(sIdMensaje,0)
						AND NVL(orden,0) <> 0;
										
						IF TRIM(NVL(cMensaje1,'')) <> '' OR TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' 
							OR TRIM(NVL(cMensaje4,'')) <> '' OR TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
							
							INSERT INTO "informix".si_detcamp
								(empresa, idmensaje, mensaje, orden)
							VALUES
								(NVL(cEmpresa,''), NVL(sIdMensaje,0), NVL(cMensaje1,''), 1);	
						END IF;
						
						IF TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
						   OR TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
							
							INSERT INTO "informix".si_detcamp
								(empresa, idmensaje, mensaje, orden)
							VALUES
								(NVL(cEmpresa,''), NVL(sIdMensaje,0), NVL(cMensaje2,''), 2);	
						END IF;
						
						IF TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' 
						   OR TRIM(NVL(cMensaje6,'')) <> '' THEN
							
							INSERT INTO "informix".si_detcamp
								(empresa, idmensaje, mensaje, orden)
							VALUES
								(NVL(cEmpresa,''), NVL(sIdMensaje,0), NVL(cMensaje3,''), 3);	
						END IF;
						
						IF TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
							
							INSERT INTO "informix".si_detcamp
								(empresa, idmensaje, mensaje, orden)
							VALUES
								(NVL(cEmpresa,''), NVL(sIdMensaje,0), NVL(cMensaje4,''), 4);	
						END IF;
						
						IF TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
							
							INSERT INTO "informix".si_detcamp
								(empresa, idmensaje, mensaje, orden)
							VALUES
								(NVL(cEmpresa,''), NVL(sIdMensaje,0), NVL(cMensaje5,''), 5);	
						END IF;
						
						IF TRIM(NVL(cMensaje6,'')) <> '' THEN						   			   

							INSERT INTO "informix".si_detcamp
								(empresa, idmensaje, mensaje, orden)
							VALUES
								(NVL(cEmpresa,''), NVL(sIdMensaje,0), NVL(cMensaje6,''), 6);							   		   
						END IF;	
					ELSE
						--NO SE ENCONTRÓ EL IDMENSAJE PARA ESA CAMPAÑA Y JERARQUÍA
						LET cCodRet = '000001';
						RETURN TRIM(NVL(cCodRet,''));
					END IF;
				END IF;
				
					INSERT INTO "informix".si_maecamp
						(empresa, sucursal, num_producto, sistema, estatus, idcamp, idjerarquia, idnivel, idzona, activa, 
						act_zona, combinable, idmensaje, tran_nro, nombre)
					VALUES
						( NVL(cEmpresa,''), NVL(cSucursal,''), NVL(cProducto,''), NVL(cSistema,''), NVL(cEstatus,''), 
						  NVL(sCampania, 0), NVL(sJerarquia, 0), NVL(sNivel,0), NVL(cZona,''), NVL(sActiva,0), NVL(sAct_Zona,0), NVL(sCombinable,0), NVL(sIdMensaje,0), NVL(sTransaccion,0), NVL(cNomCamp,''));
						
				RETURN TRIM(NVL(cCodRet,''));

			ELSE --CAMPAÑA NUEVA
				SELECT FIRST 1 idmensaje
				INTO sIdMensaje
				FROM "informix".si_maecamp
				WHERE idcamp = sCampania
				AND idJerarquia = sJerarquia
				AND empresa = cEmpresa
				AND sucursal IS NOT NULL;

				
				IF NVL(sIdMensaje,0) <> 0  THEN --OR NVL(sIdMensaje,0) IS NOT NULL THEN
					-- INSERTA EN LA TABLA SI_MAECAMP LOS DATOS QUE CORRESPONDEN A LA CAMPAÑA CREADA
					INSERT INTO "informix".si_maecamp
						(empresa, sucursal, num_producto, sistema, estatus, idcamp, idjerarquia, idnivel, idzona, activa, act_zona, combinable, idmensaje, tran_nro, nombre)
					VALUES
						( NVL(cEmpresa,''), NVL(cSucursal,''), NVL(cProducto,''), NVL(cSistema,''), NVL(cEstatus,''), 
						  NVL(sCampania, 0), NVL(sJerarquia, 0), NVL(sNivel,0), NVL(cZona,''), NVL(sActiva,0), NVL(sAct_Zona,0), NVL(sCombinable,0), NVL(sIdMensaje,0), NVL(sTransaccion,0), NVL(cNomCamp,''));
				
				ELSE
					-- SE OBTIENE EL VALOR MÁXIMO DEL ID MENSAJE
					SELECT MAX(idmensaje)
					INTO sIdMensajeMax
					FROM "informix".si_maecamp;
									
					IF NVL(sIdMensajeMax,0) = 0 OR sIdMensajeMax IS NULL THEN
						LET sIdMensajeMax = 1;			
					ELSE
						LET sIdMensajeMax = sIdMensajeMax + 1;
					END IF;
				
					-- INSERTA EN LA TABLA SI_MAECAMP LOS DATOS QUE CORRESPONDEN A LA CAMPAÑA CREADA
					INSERT INTO "informix".si_maecamp
						(empresa, sucursal, num_producto, sistema, estatus, idcamp, idjerarquia, idnivel, idzona, activa, act_zona, combinable, idmensaje, tran_nro, nombre)
					VALUES
						( NVL(cEmpresa,''), NVL(cSucursal,''), NVL(cProducto,''), NVL(cSistema,''), NVL(cEstatus,''), 
						  NVL(sCampania, 0), NVL(sJerarquia, 0), NVL(sNivel,0), NVL(cZona,''), NVL(sActiva,0), NVL(sAct_Zona,0), NVL(sCombinable,0), NVL(sIdMensajeMax,0), NVL(sTransaccion,0), NVL(cNomCamp,''));
						  
					-- INSERTA EN LA TABLA SI_DETCAMP LOS DATOS QUE CORRESPONDEN A LA CAMPAÑA CREADA
					IF TRIM(NVL(cMensaje1,'')) <> '' OR TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' 
						OR TRIM(NVL(cMensaje4,'')) <> '' OR TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO "informix".si_detcamp
							(empresa, idmensaje, mensaje, orden)
						VALUES
							(NVL(cEmpresa,''), NVL(sIdMensajeMax,0), NVL(cMensaje1,''), 1);
					END IF;
					
					IF TRIM(NVL(cMensaje2,'')) <> '' OR TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' 
					   OR TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO "informix".si_detcamp
							(empresa, idmensaje, mensaje, orden)
						VALUES
							(NVL(cEmpresa,''), NVL(sIdMensajeMax,0), NVL(cMensaje2,''), 2);	
					END IF;
					
					IF TRIM(NVL(cMensaje3,'')) <> '' OR  TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' 
					   OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO "informix".si_detcamp
							(empresa, idmensaje, mensaje, orden)
						VALUES
							(NVL(cEmpresa,''), NVL(sIdMensajeMax,0), NVL(cMensaje3,''), 3);
					END IF;
					
					IF TRIM(NVL(cMensaje4,'')) <> '' OR  TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO "informix".si_detcamp
							(empresa, idmensaje, mensaje, orden)
						VALUES
							(NVL(cEmpresa,''), NVL(sIdMensajeMax,0), NVL(cMensaje4,''), 4);	
					END IF;
					
					IF TRIM(NVL(cMensaje5,'')) <> '' OR TRIM(NVL(cMensaje6,'')) <> '' THEN
						
						INSERT INTO "informix".si_detcamp
							(empresa, idmensaje, mensaje, orden)
						VALUES
							(NVL(cEmpresa,''), NVL(sIdMensajeMax,0), NVL(cMensaje5,''), 5);	
					END IF;
					
					IF TRIM(NVL(cMensaje6,'')) <> '' THEN						   			   

						INSERT INTO "informix".si_detcamp
							(empresa, idmensaje, mensaje, orden)
						VALUES
							(NVL(cEmpresa,''), NVL(sIdMensajeMax,0), NVL(cMensaje6,''), 6);						   		   
					END IF;					   
				END IF;
				RETURN TRIM(NVL(cCodRet,''));	
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'Fecha: 10/04/2015',
'Folio :1711',
'Proyecto: TicketInteligenteBancoppel',
'Descripcion: Procedimiento para modificar o guardar campania',
'Autor: Isarai Bojorquez',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_obtiene_campanias_multiple(pEmpresa CHAR(3))
RETURNING	CHAR(6) 	AS CodRet,
			SMALLINT 	AS IDCamp,
			SMALLINT 	AS IDJerarquia,
			CHAR(40) 	AS Nombre,
			CHAR(55) 	AS Producto,
			CHAR(55) 	AS Sistema,
			CHAR(8) 	AS Estado,
			SMALLINT 	AS Combinable,
			CHAR(65) 	AS Mensaje,
			CHAR(55) 	AS Sucursales;
			

	-- DEFINICION DE VARIABLES
    DEFINE	cCodRet				CHAR(6);
	DEFINE	iSqlErr				INTEGER;
	DEFINE	sIDCamp				SMALLINT;
	DEFINE	sIDJerarquia		SMALLINT;
	DEFINE	sPrimeraVez			SMALLINT;
	DEFINE	sIDCamp2			SMALLINT;
	DEFINE	sIDJerarquia2		SMALLINT;
	DEFINE	cNombre				CHAR(40);
	DEFINE	cProducto			CHAR(5);
	DEFINE	cSistema			CHAR(5);
	DEFINE	cSistema2			CHAR(5);
	DEFINE	cEstado				CHAR(8);
	DEFINE	sIDMensaje			SMALLINT;
	DEFINE	cIDSucursal			CHAR(20);
	DEFINE	cIDZona				CHAR(5);
	DEFINE	sIDCampRet			SMALLINT;
	DEFINE	sIDJerarquiaRet		SMALLINT;
	DEFINE	cNombreRet			CHAR(65);
	DEFINE	cProductoRet		CHAR(55);
	DEFINE	cSistemaRet			CHAR(55);
	DEFINE	cSistemaRet2		CHAR(55);
	DEFINE	sEstadoRet			SMALLINT;
	DEFINE	sIDMensajeRet		SMALLINT;
	DEFINE	cIDSucursalRet		CHAR(30);
	DEFINE	cMensaje			CHAR(65);
	DEFINE	cMensajeRet			CHAR(55);
	DEFINE	iContadorSuc		INTEGER;
	DEFINE	iContadorZona		INTEGER;
	DEFINE	sCombinable			SMALLINT;
	DEFINE	sCombinableRet		SMALLINT;
	DEFINE	cEstatus			CHAR(1);
	DEFINE	cEstatusRet			CHAR(1);
	DEFINE	cNomProductoRet		CHAR(40);
	DEFINE	sTranNum			SMALLINT;
	DEFINE	cDesTranRet			CHAR(49);
	DEFINE 	cSucursal			CHAR(5);
	DEFINE sActivo 				SMALLINT;
	DEFINE sEstado 				SMALLINT;
	--1711
	DEFINE	sOrden				SMALLINT;
	DEFINE	sContSist			SMALLINT;
	DEFINE	sContProd			SMALLINT;
	DEFINE	sContSuc			SMALLINT;
	DEFINE	sContSuc2			SMALLINT;
	--sp_campaniamensajeporlinea
	DEFINE cCodRet2				CHAR(5);
	DEFINE cMensaje2			CHAR(65);	
	DEFINE	sSistema			SMALLINT;
	DEFINE	sProd				SMALLINT;
	DEFINE	sSuc				SMALLINT;
	DEFINE 	iSC					INTEGER;
	DEFINE 	iSD					INTEGER;
	DEFINE 	iSE					INTEGER;
	DEFINE 	cSucursal2			CHAR(5);
	DEFINE	sSistema2			SMALLINT;
	DEFINE 	sSistema3			CHAR(2);
	DEFINE 	sSistema4			CHAR(2);
	
		
	--INICIALIZACION DE VARIABLES--
	LET cCodRet2 			= '';
	LET sSistema3 			= '';
	LET sSistema4 			= '';
	LET cMensaje2			= '';
	LET cSucursal 			= '';
	LET cCodRet				= "000000";
	LET sSistema2			= 0;
	LET iSqlErr				= 0;
	LET iSC					= 0;
	LET iSD					= 0;
	LET iSE					= 0;
	LET sProd				= 0;
	LET sSuc				= 0;
	LET sSistema			= 0;
	LET sContSist			= 0;
	LET sContProd			= 0;
	LET sContSuc			= 0;
	LET sContSuc2			= 0;
	LET	sIDCamp				= 0;
	LET	sIDJerarquia		= 0;
	LET	sPrimeraVez			= 0;
	LET	sIDCamp2			= 0;
	LET	sIDJerarquia2		= 0;
	LET	cNombre				= "";
	LET	cProducto			= "";
	LET	cSistema			= "";
	LET	cSistema2			= "";
	LET	cEstado				= '';
	LET	sIDMensaje			= 0;
	LET	cIDSucursal			= "";
	LET	cIDZona				= "";
	LET	sIDCampRet			= 0;
	LET	sIDJerarquiaRet		= 0;
	LET	cNombreRet			= "";
	LET	cProductoRet		= "";
	LET	cSistemaRet			= "";
	LET	cSistemaRet2		= "";
	LET	sEstadoRet			= 0;
	LET	sIDMensajeRet		= 0;
	LET	cIDSucursalRet		= "";
	LET	cMensaje			= "";
	LET cMensajeRet			= "";
	LET	iContadorSuc		= 0;
	LET	iContadorZona		= 0;
	LET	sCombinable			= 0;
	LET	sCombinableRet		= 0;
	LET	cEstatus			= "";
	LET	cEstatusRet			= "";
	LET	cNomProductoRet		= "";
	LET	sTranNum			= 0;
	LET	cDesTranRet			= "";		
	LET sOrden 				= 0;
	LET sActivo 			= 0;
	LET sestado 			= 0;
	LET	cSucursal2			= "";
	
	--SET DEBUG FILE TO '/respaldosbd/isarai/sp_obtiene_campanias_multiple.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    BEGIN

        ON EXCEPTION SET iSqlErr
		
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,'')),NVL(sIDCampRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),TRIM(NVL(cProductoRet,'')),
					   TRIM(NVL(cSistemaRet2,'')),TRIM(NVL(cEstado,'')),NVL(sCombinableRet,0),TRIM(NVL(cMensaje,'')), TRIM(NVL(cIDSucursalRet,''));
            END IF;
			
        END EXCEPTION;
		
		IF LENGTH(TRIM(NVL(pEmpresa,""))) = 0 THEN
			--PROPORCIONAR EMPRESA
			LET cCodRet = "00001";
			RETURN TRIM(NVL(cCodRet,'')),NVL(sIDCampRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),TRIM(NVL(cProductoRet,'')),
			       TRIM(NVL(cSistemaRet2,'')),TRIM(NVL(cEstado,'')),NVL(sCombinableRet,0),TRIM(NVL(cMensaje,'')),TRIM(NVL(cIDSucursalRet,''));
		ELSE
			FOREACH
				--SE OBTIENEN EL TOTAL DE CAMPÑAS
				SELECT DISTINCT idcamp, idjerarquia,idmensaje
				INTO sIDCamp, sIDJerarquia,sIdMensaje
				FROM "informix".si_maecamp
				WHERE empresa = TRIM(pEmpresa)
				
				LET sPrimeraVez = 1;
				
				FOREACH
										--SE OBTIENEN LAS PRIMERAS 5 SUCURSALES
					SELECT DISTINCT DECODE(num_producto, 'T','T',num_producto),
									DECODE(sistema,'T','T',sistema), 
									DECODE(sucursal,'T','T',sucursal),idzona,combinable
					INTO cProducto, cSistema,cIDSucursal,cIDZona,sCombinableRet
					FROM "informix".si_maecamp
					WHERE empresa = TRIM(pEmpresa)
					AND idcamp = NVL(sIDCamp,0)
					AND idjerarquia = NVL(sIDJerarquia,0)
					
					SELECT COUNT(DISTINCT sucursal) INTO sSuc FROM "informix".si_maecamp  
					WHERE empresa = TRIM(pEmpresa) AND idcamp = NVL(sIDCamp,0)	
					AND idjerarquia = NVL(sIDJerarquia,0) AND sucursal = TRIM(NVL(cIDSucursal,'')) AND sucursal IS NOT NULL;
					
					SELECT COUNT(DISTINCT num_producto) INTO sProd FROM "informix".si_maecamp  
					WHERE empresa = TRIM(pEmpresa) AND idcamp = NVL(sIDCamp,0)	
					AND idjerarquia = NVL(sIDJerarquia,0) AND num_producto = TRIM(NVL(cProducto,'')) AND num_producto IS NOT NULL;
					
					SELECT  COUNT(DISTINCT sistema) INTO sSistema2 FROM "informix".si_maecamp  
					WHERE empresa = TRIM(pEmpresa) AND idcamp = NVL(sIDCamp,0)	
					AND idjerarquia = NVL(sIDJerarquia,0) AND sistema <> '';
					
						IF NVL(sProd,0) = 1 AND TRIM(cProductoRet) <>  TRIM(NVL(cProducto,'')) THEN 
							LET sContProd = NVL(sContProd,0) + 1 ;
						END IF;	
						IF NVL(sSuc,0) = 1 AND TRIM(cIDSucursalRet) <>  TRIM(cIDSucursal) AND TRIM(cIDSucursalRet) <>  '' THEN 
							LET sContSuc = NVL(sContSuc,0) + 1 ;
						END IF;	

					IF sPrimeraVez = 1 THEN
						--SE GUARDA EL IDCAMPAÑA, IDJERARQUIA, NOMBRE CAMAPAÑA, PRODUCTO, SISTEMA, STATUS, SI ESTA ACTIVA, SI ES COMBINABLE Y EL IDMENSAJE LA CAMAPAÑA PARA DESPUES RETORNARLO
						LET sIDCampRet = NVL(sIDCamp,0);
						LET sIDJerarquiaRet = NVL(sIDJerarquia,0);
						LET cNombreRet = TRIM(NVL(cNombre,''));
						LET cProductoRet = TRIM(NVL(cProducto,''));
						LET cSistemaRet = TRIM(NVL(cSistema,''));
						LET	cEstatusRet = NVL(cEstatus,"");
						LET sEstadoRet = NVL(sEstado,0);
						LET	sCombinableRet = NVL(sCombinableRet,0);
						LET sIDMensajeRet = NVL(sIdMensaje,0);
						
						IF TRIM(cIDSucursal) <> ''  THEN	
							LET cIDSucursalRet = TRIM(NVL(cIDSucursal,''));

						ELSE
							LET cIDSucursalRet = 'Z'|| "|" || TRIM(NVL(cIDZona,''));
						END IF;	
						
						IF sContSuc = 1 THEN
							LET cSucursal2 = TRIM(NVL(cIDSucursal,'')) ;
						END IF;
						
						LET sPrimeraVez = 0;
					ELSE
						
						IF sContProd > 1 AND TRIM(cProductoRet) <>  TRIM(NVL(cProducto,'')) THEN
							LET cProductoRet = 'V';
						ELSE
							LET cProductoRet = TRIM(NVL(cProducto,''));
						END IF;
						
						IF sContSuc > 1 AND cSucursal2 <> TRIM(NVL(cIDSucursal,'')) THEN
							LET cIDSucursalRet = 'V';
						ELSE 
							LET cIDSucursalRet = TRIM(NVL(cIDSucursalRet,''));
						END IF;

					END IF;
					
					IF NVL(sSistema2,0) = 1 THEN
						IF (NVL(cSistema,'')) <> '' THEN
							LET cSistemaRet2 = TRIM(NVL(cSistema,'')) ;
						ELSE
							LET cSistemaRet2 = TRIM(NVL(cSistemaRet2,'')) ;
						END IF;	
					ELIF NVL(sSistema2,0) = 3 THEN
						LET cSistemaRet2 = TRIM(NVL('T','')) ;
					ELIF NVL(sSistema2,0) = 2 THEN	
						FOREACH
							SELECT DISTINCT DECODE(sistema,'T','T',sistema) INTO sSistema3 
							FROM "informix".si_maecamp
							WHERE empresa = TRIM(pEmpresa)
							AND idcamp = NVL(sIDCamp,0)
							AND idjerarquia = NVL(sIDJerarquia,0)
							
							SELECT DISTINCT DECODE(sistema,'T','T',sistema) INTO sSistema4 
							FROM "informix".si_maecamp
							WHERE empresa = TRIM(pEmpresa)
							AND idcamp = NVL(sIDCamp,0)
							AND idjerarquia = NVL(sIDJerarquia,0)	
							AND sistema <> TRIM(sSistema3);
							
							LET cSistemaRet2 = TRIM(NVL(sSistema4,'')) || "|" || TRIM(NVL(sSistema3,''));
						END FOREACH	
					END IF;
					
					SELECT FIRST 1 orden INTO sOrden FROM "informix".si_detcamp WHERE idmensaje = NVL(sIdMensaje,0) AND NVL(mensaje,'') <> '';
				
					EXECUTE  PROCEDURE "informix".sp_campaniamensajeporlinea(sIdMensaje,sOrden) INTO cCodRet2,cMensaje2;
				
					IF  NVL(cCodRet2:: INTEGER,0) <> 0 THEN
						LET cCodRet = TRIM(NVL(cCodRet2,'')); --NVL(cCodRet2:: INTEGER,0);
						RETURN TRIM(NVL(cCodRet,'')),NVL(sIDCampRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),
							   TRIM(NVL(cProductoRet,'')),		TRIM(NVL(cSistemaRet2,'')),TRIM(NVL(cEstado,'')),NVL(sCombinableRet,0),
						       TRIM(NVL(cMensaje,'')),TRIM(NVL(cIDSucursalRet,''));
					ELSE
						LET cMensaje = NVL(sIdMensaje,0) || "|" || TRIM(NVL(cMensaje2,''));
					END IF 
					
					SELECT FIRST 1 activa,nombre INTO sActivo,cNombreRet  FROM "informix".si_maecamp		
					WHERE empresa = TRIM('001')	AND idcamp = sIDCampRet	AND idjerarquia = sIDJerarquiaRet; 
					
					IF NVL(sActivo,0) = 1 THEN
						LET cEstado =  TRIM('Activa');
					ELSE
						LET cEstado =  TRIM('Inactiva');
					END IF;	
								
					LET sContSuc2 = NVL(sContSuc,0);
				END FOREACH;
				
				RETURN TRIM(NVL(cCodRet,'')),NVL(sIDCampRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),TRIM(NVL(cProductoRet,'')),
				       TRIM(NVL(cSistemaRet2,'')),TRIM(NVL(cEstado,'')),NVL(sCombinableRet,0),TRIM(NVL(cMensaje,'')),
				       TRIM(NVL(cIDSucursalRet,'')) WITH RESUME;
				
				LET sContSist 		= 0;
				LET sContSuc 		= 0;
				LET cSistemaRet2 	= '';
				LET cSistemaRet		= '';
				LET cSistema 		= '';
				LET sContProd 		= 0;
				LET sSistema2		= 0;
				
			END FOREACH;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				--NO EXISTEN CAMPAÑAS
				LET cCodRet = "00002";
				RETURN TRIM(NVL(cCodRet,'')),NVL(sIDCampRet,0),NVL(sIDJerarquiaRet,0),TRIM(NVL(cNombreRet,'')),TRIM(NVL(cProductoRet,'')),		
				       TRIM(NVL(cSistemaRet2,'')),TRIM(NVL(cEstado,'')),NVL(sCombinableRet,0),TRIM(NVL(cMensaje,'')),
				       TRIM(NVL(cIDSucursalRet,''));
			END IF;
			
		END IF;
	END;
END PROCEDURE
DOCUMENT
'FECHA: 09/04/2015',
'FOLIO :1711',
'PROYECTO: TICKETINTELIGENTEBANCOPPEL',
'DESCRIPCION: PROCEDIMIENTO PARA OBTENER TODAS LAS CAMPANIAS',
'AUTOR: ISARAI BOJORQUEZ',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_obtiene_estatus_multiple(pEmpresa CHAR(3), pIdCamp SMALLINT, pIdJerarquia SMALLINT)

RETURNING
	CHAR(6)   AS Codigo_retorno,
	CHAR(15)  AS Descrip_estatus,
	CHAR(1)	  AS cEstatus;

--DECLARACION DE VARIABLES
	DEFINE cCodRet						CHAR(6);
	DEFINE iSqlErr						INTEGER;
	DEFINE cDescripEst					CHAR(15);
	DEFINE iContador,i					INTEGER;
	DEFINE cEstatus						CHAR(1);

--INICIALIZACION DE VARIABLES
	LET cCodRet 		= '000000';
	LET iSqlErr 		= 0;
	LET cDescripEst 	= '';
	LET cEstatus 		= '';
	LET iContador		= 0;
	LET i				= 0;

	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_obtiene_estatus_multiple.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripEst,'')),TRIM(NVL(cEstatus,''));
			END IF;
			
		END EXCEPTION;	
		
		IF TRIM(NVL(pEmpresa,'')) <> '' AND NVL(pIdCamp,0) <> 0 AND NVL(pIdJerarquia,0) <> 0 THEN
		
			FOREACH
			
				SELECT DISTINCT DECODE(estatus,'N','NORMAL','A','ATRASO','V','POR VENCER','T','TODOS'),estatus
				INTO cDescripEst,cEstatus
				FROM "informix".si_maecamp
				WHERE idcamp = NVL(pIdCamp,0)
				AND idjerarquia = NVL(pIdJerarquia,0)
				AND (sistema = 'SD' OR sistema = 'T')
				
				LET iContador = NVL(iContador,0) + 1;
				
				IF cDescripEst = TRIM('TODOS') THEN
				
					WHILE iContador <= 3

						IF iContador = 1 THEN
							LET cDescripEst =  TRIM('ATRASO');
							LET cEstatus = 'A';
						ELIF iContador = 2 THEN
							LET cDescripEst =  TRIM('NORMAL');
							LET cEstatus = 'N';
						ELIF iContador = 3 THEN
							LET cDescripEst =  TRIM('POR VENCER');
							LET cEstatus = 'V';
						ELIF iContador > 3 THEN
							EXIT FOREACH;
						END IF	

						LET iContador = NVL(iContador,0) + 1;
						RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripEst,'')),TRIM(NVL(cEstatus,'')) WITH RESUME;

					END WHILE;
				ELSE 
					RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripEst,'')),TRIM(NVL(cEstatus,'')) WITH RESUME;
				END IF;
				
			END FOREACH	
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				--NO EXISTEN CAMPAÑAS
				LET cCodRet = "000002";
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripEst,'')),TRIM(NVL(cEstatus,''));
			END IF;
			
		ELSE
			LET cCodRet = '000001';	
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripEst,'')),TRIM(NVL(cEstatus,''));
		END IF;
		
	END
END PROCEDURE
DOCUMENT
'FECHA: 09/04/2015',
'FOLIO :1711',
'PROYECTO: TICKETINTELIGENTEBANCOPPEL',
'DESCRIPCION: PROCEDIMIENTO PARA OBTENER LOS ESTATUS DEL SISTEMA DE CREDITO DE UNA CAMPANIA',
'AUTOR: 95358897-ISARAI BOJORQUEZ',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_obtiene_producto_multiple(pEmpresa CHAR(3),pIdCamp SMALLINT,pIdJerarquia SMALLINT)

RETURNING
	CHAR(6)  AS codigo_retorno,
	CHAR(40) AS DesProducto,
	CHAR(4)  AS codigo_producto,
	CHAR(2)  AS sist_producto;

--DEFINICION DE VARIABLES--
	DEFINE iSqlErr     			INTEGER;
	DEFINE cCodRet     			CHAR(6);
	DEFINE cDescripProd    		CHAR(40);
	DEFINE cCodProd 			CHAR(4);
	DEFINE cSistProd   			CHAR(2);
	DEFINE cSistProd3   		CHAR(2);
	DEFINE	cProducto			CHAR(4);
	DEFINE	sPrimeraVez			SMALLINT;
	DEFINE cCodProd2 			CHAR(4);
	DEFINE cSistProd2   		CHAR(2);

--INICIALIZACION DE VARIABLES--
	LET iSqlErr     	= 0;
	LET sPrimeraVez     = 0;
	LET cCodRet     	= '000000';
	LET cDescripProd    = '';
	LET cCodProd 		= '';
	LET cSistProd   	= '';
	LET cCodProd2 		= '';
	LET cSistProd2  	= '';
	LET cProducto  		= '';

	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_obtiene_producto_multiple.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),TRIM(NVL(cSistProd,''));
			END IF;
			
		END EXCEPTION;
		
		IF TRIM(NVL(pEmpresa,'')) <> '' AND NVL(pIdCamp,0) <> 0 AND NVL(pIdJerarquia,0) <> 0 THEN
		
			FOREACH
				--OBTIENE TODOS LOS SISTEMAS DE LA CAMPAÑA
				SELECT DISTINCT DECODE(sistema,'T','T',sistema),sistema			
				INTO cSistProd,cSistProd3
				FROM "informix".si_maecamp
				WHERE empresa = TRIM(NVL(pEmpresa,''))
				AND idcamp = NVL(pIdCamp,0)
				AND idjerarquia = NVL(pIdJerarquia,0)
				ORDER BY sistema ASC
					
				LET sPrimeraVez = 1;
				
				FOREACH
				
					SELECT DISTINCT DECODE(num_producto,'T','T',num_producto)	
					INTO cCodProd
					FROM "informix".si_maecamp
					WHERE empresa = TRIM(NVL(pEmpresa,''))
					AND idcamp = NVL(pIdCamp,0)
					AND idjerarquia = NVL(pIdJerarquia,0)
					AND sistema = TRIM(NVL(cSistProd,''))
					
					--CUANDO SE OBTIENE EL PRIMER REGISTRO
					IF sPrimeraVez = 1 THEN 
						LET cSistProd2 = TRIM(cSistProd);
						LET cCodProd2 = TRIM(cCodProd);
						LET sPrimeraVez = 0;
					END IF ;

					IF TRIM(NVL(cSistProd,'')) = 'SC' THEN
							
						IF TRIM(NVL(cCodProd,'')) = 'T' THEN
							LET cCodProd = '';
						END IF;
						
						FOREACH 
						
							SELECT DiSTINCT nombre,producto INTO cDescripProd,cProducto FROM bdicheq: "informix".sc_producto 
							WHERE producto =  DECODE(cCodProd,'',producto,cCodProd)
							ORDER BY producto ASC
							
							LET cCodProd =  TRIM(NVL(cProducto,''));
							LET cProducto = '';

							RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cDescripProd,'')), TRIM(NVL(cCodProd,'')),
								   TRIM(NVL(cSistProd,'')) WITH RESUME;	
							
						END FOREACH
						
						IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
							--NO SE ENCONTRARON PRODUCTOS PARA ESTA CAMPANIA
							LET cCodRet = '000002';
							RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),TRIM(NVL(cSistProd,''));
						END IF;	
						
					ELIF TRIM(NVL(cSistProd,'')) = 'SD'	THEN
					
						IF TRIM(NVL(cCodProd,'')) = 'T' THEN
							LET cCodProd = '';
						END IF;
						
						FOREACH 
							SELECT DiSTINCT nombre_prod,num_producto  INTO cDescripProd, cProducto
							FROM bdicred: "informix".sd_definicion
							where num_producto = DECODE(cCodProd,'',num_producto,cCodProd)
							ORDER BY num_producto ASC

							LET cCodProd =  TRIM(NVL(cProducto,''));
							LET cProducto = '';
							
							IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
								--NO SE ENCONTRARON PRODUCTOS PARA ESTA CAMPANIA
								LET cCodRet = '000002';
								RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cDescripProd,'')), TRIM(NVL(cCodProd,'')),
									   TRIM(NVL(cSistProd,''));
							END IF;
							
							RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),
								   TRIM(NVL(cSistProd,'')) WITH RESUME;	
							
						END FOREACH	
						
					ELIF TRIM(NVL(cSistProd,'')) = 'SE' THEN
					
						LET cCodProd = TRIM('T');
						LET cSistProd = TRIM('SE');
						LET cDescripProd = TRIM('SERVICIOS');
						
						RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),
							   TRIM(NVL(cSistProd,'')) WITH RESUME;	
						
					ELIF TRIM(NVL(cSistProd,'')) = 'T' THEN	
						
						IF TRIM(NVL(cCodProd,'')) = 'T' THEN
							LET cProducto =  TRIM(NVL(cCodProd,''));
							LET cCodProd = '';
							
						END IF;
						
						FOREACH 
						
							SELECT DiSTINCT nombre,producto INTO cDescripProd,cProducto FROM bdicheq: "informix".sc_producto 
							WHERE producto =  DECODE(cCodProd,'',producto,cCodProd)
							ORDER BY producto ASC
								
							LET cCodProd =  TRIM(NVL(cProducto,''));
							LET cSistProd = TRIM('SC');
								
							IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
								--NO SE ENCONTRARON PRODUCTOS PARA ESTA CAMPANIA
								LET cCodRet = '000002';
								RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),
								       TRIM(NVL(cSistProd,''));
							END IF;
								
							RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),
								   TRIM(NVL(cSistProd,'')) WITH RESUME;	
							
						END FOREACH	
							
							LET cCodProd = '';
							LET cProducto = '';
							LET cSistProd = '';
							
						FOREACH 
							SELECT DiSTINCT nombre_prod,num_producto  INTO cDescripProd, cProducto
							FROM bdicred: "informix".sd_definicion
							where num_producto = DECODE(cCodProd,'',num_producto,cCodProd)
							ORDER BY num_producto ASC

								LET cCodProd =  TRIM(NVL(cProducto,''));
								LET cSistProd = TRIM('SD');

							IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
								--NO SE ENCONTRARON PRODUCTOS PARA ESTA CAMPANIA
								LET cCodRet = '000002';
								RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),TRIM(NVL(cSistProd,''));
							END IF;
							
							RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),
							       TRIM(NVL(cSistProd,'')) WITH RESUME;
							
						END FOREACH	
							
							LET cCodProd = TRIM('T');
							LET cSistProd = TRIM('SE');
							LET cDescripProd = TRIM('SERVICIOS');	
							RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),
							       TRIM(NVL(cSistProd,''));	
								   
						END IF;
						
				END FOREACH
				
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
						--NO SE ENCONTRARON PRODUCTOS PARA ESTA CAMPANIA
						LET cCodRet = '000002';
						RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),TRIM(NVL(cSistProd,''));
					END IF;	
					
			END FOREACH	

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				--NO SE ENCONTRO LA CAMPANIA
				LET cCodRet = '000003';
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),TRIM(NVL(cSistProd,''));
			END IF;	
			
		ELSE
			--Párametros de entrada vacíos
			LET cCodRet = '000001';
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripProd,'')),TRIM(NVL(cCodProd,'')),TRIM(NVL(cSistProd,''));
			
		END IF;
	END
END PROCEDURE
DOCUMENT
'FECHA: 10/04/2015',
'FOLIO :1711',
'PROYECTO: TICKETINTELIGENTEBANCOPPEL',
'DESCRIPCION: PROCEDIMIENTO PARA OBTENER LOS PRODUCTOS  DE UNA CAMPANIA',
'AUTOR: 95358897-ISARAI BOJORQUEZ',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_obtiene_transaccion_multiple(pEmpresa CHAR(3),pIdCamp SMALLINT,pIdJerarquia SMALLINT)

RETURNING
	CHAR(6)  AS codigo_retorno,
	CHAR(40) AS DescripTransacc,
	SMALLINT  AS codigo_transacc,
	CHAR(2)  AS sist_transacc;

--DEFINICION DE VARIABLES--
	DEFINE 	iSqlErr     			INTEGER;
	DEFINE 	cCodRet     			CHAR(6);
	DEFINE 	cDescripTransacc    	CHAR(40);
	DEFINE 	cCodigo_transacc		SMALLINT;
	DEFINE 	sSist_transacc   		CHAR(2);
	DEFINE	cProducto				CHAR(4);
	DEFINE	sNumero					SMALLINT;
	DEFINE	cSistema				CHAR(2);

--INICIALIZACION DE VARIABLES--
	LET iSqlErr     		= 0;
	LET cCodRet     		= '000000';
	LET cDescripTransacc    = '';
	LET cCodigo_transacc 	= 0;
	LET sNumero 			= 0;
	LET sSist_transacc   	= '';
	LET cProducto   		= '';
	LET cSistema   			= '';

	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_obtiene_transaccion_multiple.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripTransacc,'')),NVL(cCodigo_transacc,0),TRIM(NVL(sSist_transacc,''));
			END IF;
			
		END EXCEPTION;
		
		IF TRIM(NVL(pEmpresa,'')) <> '' AND NVL(pIdCamp,0) <> 0 AND NVL(pIdJerarquia,0) <> 0 THEN
		
			FOREACH
				--OBTIENE TODOS LOS SISTEMAS DE LA CAMPAÑA
				SELECT DISTINCT DECODE(sistema,'T','T',sistema)	
				INTO sSist_transacc
				FROM "informix".si_maecamp
				WHERE empresa = TRIM(NVL(pEmpresa,''))
				AND idcamp = NVL(pIdCamp,0)
				AND idjerarquia = NVL(pIdJerarquia,0)
				--ORDER BY sistema ASC
				
				FOREACH	
					SELECT DISTINCT DECODE(tran_nro, 0,0,tran_nro) INTO cCodigo_transacc
					FROM "informix".si_maecamp
					WHERE empresa = TRIM(NVL(pEmpresa,''))
					AND idcamp = NVL(pIdCamp,0)
					AND idjerarquia = NVL(pIdJerarquia,0)
					AND sistema = TRIM(NVL(sSist_transacc,''))
					
					IF  TRIM(NVL(sSist_transacc,'')) = 'T' AND TRIM(NVL(sSist_transacc,'')) <> '' THEN
						LET sSist_transacc = '';
						LET cCodigo_transacc = 0;
					END IF;
					
					FOREACH
						SELECT descripcion,numero,sistema INTO cDescripTransacc,sNumero,cSistema
						FROM "informix".itran 
						WHERE empresa = TRIM(NVL(pEmpresa,''))
						AND numero = DECODE (cCodigo_transacc, 0,numero,cCodigo_transacc)
						AND sistema = TRIM(DECODE (sSist_transacc, '',sistema,sSist_transacc))
						AND sistema IN ('SD','SC','SE')
						ORDER BY numero,sistema ASC
							
						IF cCodigo_transacc = 0 THEN
							LET cCodigo_transacc = NVL(sNumero,0);
							LET sNumero = 0;
						ELSE
							LET cCodigo_transacc = NVL(cCodigo_transacc,0);
						END IF;	
							
						IF sSist_transacc = '' THEN
							LET sSist_transacc = TRIM(NVL(cSistema,''));
							LET cSistema = '';
						END IF;
						
						RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cDescripTransacc,'')), NVL(cCodigo_transacc,0),
							   TRIM(NVL(sSist_transacc,'')) WITH RESUME;
						
						LET cCodigo_transacc = 0;
						LET sSist_transacc = '';
						
						IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
							--NO SE ENCONTRO LA CAMPANIA
							LET cCodRet = '000003';
							RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cDescripTransacc,'')), NVL(cCodigo_transacc,0),
							       TRIM(NVL(sSist_transacc,''));
						END IF;	
						
					END FOREACH	
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
						--NO SE ENCONTRO LA CAMPANIA
						LET cCodRet = '000003';
						RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cDescripTransacc,'')), NVL(cCodigo_transacc,0), 
							   TRIM(NVL(sSist_transacc,''));
					END IF;	
				END FOREACH

					IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
						--NO SE ENCONTRO LA CAMPANIA
						LET cCodRet = '000003';
						RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cDescripTransacc,'')), NVL(cCodigo_transacc,0),
							   TRIM(NVL(sSist_transacc,''));
					END IF;
	
			END FOREACH	

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
				--NO SE ENCONTRO LA CAMPANIA
				LET cCodRet = '000003';
				RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripTransacc,'')),NVL(cCodigo_transacc,0),TRIM(NVL(sSist_transacc,''));
			END IF;
			
		ELSE
			LET cCodRet = '000001';
			RETURN TRIM(NVL(cCodRet,'')),TRIM(NVL(cDescripTransacc,'')),NVL(cCodigo_transacc,0),TRIM(NVL(sSist_transacc,''));
		END IF;
	END
END PROCEDURE
DOCUMENT
'FECHA: 10/04/2015',
'FOLIO :1711',
'PROYECTO: TICKETINTELIGENTEBANCOPPEL',
'DESCRIPCION: PROCEDIMIENTO PARA OBTENER LAS TRANSACCIONES SELECCIONADAS  DE UNA CAMPANIA',
'AUTOR: 95358897-ISARAI BOJORQUEZ',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_consmaecamreplica (cSucursalParam CHAR(5), iNumRegistros INTEGER)

RETURNING
CHAR(5)  AS codigo_retorno,
CHAR(5)  AS codigo_retorno2,
CHAR(3)  AS cEmpresa,
CHAR(5)  AS cSucursal,
CHAR(5)  AS cNum_Producto,
CHAR(2)  AS cSistem,
CHAR(1)  AS cEstatus,
SMALLINT AS sIdCamp,
SMALLINT AS sIdJerarquia,
SMALLINT AS sIdNivel,
SMALLINT AS sIdZona,
SMALLINT AS sActiva,
SMALLINT AS sAct_Zona,
SMALLINT AS sCombinable,
SMALLINT AS sIdMensaje,
SMALLINT AS sTran_nro;

--DEFINICION DE VARIABLES--
DEFINE iSqlErr       INTEGER;
DEFINE cCodRet       CHAR(5);	
DEFINE cCodRet2      CHAR(5);
DEFINE iRows         INTEGER;
---------------------------
DEFINE cEmpresa       CHAR(3);
DEFINE cSucursal      CHAR(5);
DEFINE cNum_Producto  CHAR(5);
DEFINE cSistema       CHAR(2);
DEFINE cEstatus       CHAR(1);
DEFINE sIdCamp        SMALLINT;
DEFINE sIdJerarquia   SMALLINT;
DEFINE sIdNivel       SMALLINT;
DEFINE sIdZona        SMALLINT;
DEFINE sActiva        SMALLINT;
DEFINE sAct_Zona      SMALLINT;
DEFINE sCombinable    SMALLINT;
DEFINE sIdMensaje     SMALLINT;
DEFINE sTran_nro      SMALLINT;
DEFINE iContador      INTEGER;
DEFINE cPlaza         CHAR(3);

--INICIALIZACION DE VARIABLES--
LET iSqlErr        = 0;
LET cCodRet        = '00000';
LET cCodRet2        = '00000';
LET iRows          = 0;
-------------------------------
LET cEmpresa       = '';
LET cSucursal      = '';
LET cNum_Producto  = '';
LET cSistema       = '';
LET cEstatus       = '';
LET sIdCamp        = 0;
LET sIdJerarquia   = 0;
LET sIdNivel       = 0;
LET sIdZona        = '';
LET sActiva        = 0;
LET sAct_Zona      = 0;
LET sCombinable    = 0;
LET sIdMensaje     = 0;
LET sTran_nro      = 0;
LET iContador      = 0;
LET cPlaza         = '';

	--SET DEBUG FILE TO "/respaldosbd/isarai/sp_consmaecamreplica.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			   RETURN cCodRet, 
			         cCodRet2, 
					 cEmpresa,     
					 cSucursal,    
					 cNum_Producto,
					 cSistema,     
					 cEstatus,     
					 NVL(sIdCamp,0),      
					 NVL(sIdJerarquia,0), 
					 NVL(sIdNivel,0),     
					 NVL(sIdZona,0),      
					 NVL(sActiva,0),     
					 NVL(sAct_Zona,0), 
					 NVL(sCombinable,0),  
					 NVL(sIdMensaje,0),      	  
					 NVL(sTran_nro,0);
			END IF;
		END EXCEPTION;	
		
		--Valida parámetros de entrada
		IF NVL(cSucursalParam,'') = '' OR iNumRegistros IS NULL THEN	

			-- Parámetro de entrada vacío
			LET cCodRet2 = '00001';
			
		   RETURN cCodRet, 
		         cCodRet2,
				 cEmpresa,     
				 cSucursal,    
				 cNum_Producto,
				 cSistema,     
				 cEstatus,     
				 sIdCamp,      
				 sIdJerarquia, 
				 sIdNivel,     
				 sIdZona,      
				 sActiva,     
				 sAct_Zona, 
				 sCombinable,  
				 sIdMensaje,  				 
				 sTran_nro
			WITH RESUME;

		ELSE		

			-- Se consulta si la zona de la sucursal asignada está activa
			SELECT plaza
			  INTO cPlaza
			  FROM bdinteg:"informix".si_sucursales
			 WHERE sucursal = cSucursalParam;
			 
			IF NVL(cPlaza,'') <> '' THEN
			 
				IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_maecamp WHERE idzona = cPlaza AND activa = 1 AND act_zona = 1 ) THEN
				
					FOREACH
					
						SELECT  empresa,     			  			
								num_producto,			
								sistema,     			
								estatus,     			
								idcamp,      			
								idjerarquia, 			
								idnivel,     			
								idzona,      			
								activa,      			
								act_zona,    			
								combinable,  			
								idmensaje,   			
								tran_nro    			
						   INTO cEmpresa,        
								cNum_Producto,
								cSistema,     
								cEstatus,     
								sIdCamp,      
								sIdJerarquia, 
								sIdNivel,     
								sIdZona,      
								sActiva,      
								sAct_Zona,    
								sCombinable,  
								sIdMensaje,   
								sTran_nro    			   
						   FROM bdinteg:"informix".si_maecamp
						  WHERE idzona = cPlaza
						    AND	activa = 1	
							AND	act_zona = 1
							
							LET iContador = iContador + 1;

							IF iContador <= iNumRegistros THEN
								CONTINUE FOREACH;
							END IF; 							

						   RETURN cCodRet, 
								 cCodRet2,
								 cEmpresa,     
								 cSucursal,    
								 cNum_Producto,
								 cSistema,     
								 cEstatus,     
								 sIdCamp,      
								 sIdJerarquia, 
								 sIdNivel,     
								 sIdZona,      
								 sActiva,     
								 sAct_Zona, 
								 sCombinable,  
								 sIdMensaje,  				 
								 sTran_nro
							WITH RESUME;	

					END FOREACH;
				
				END IF;

			END IF; 
			
			FOREACH		
			
				--Se seleccionan los datos de central
				SELECT  empresa,     			
						sucursal,    			
						num_producto,			
						sistema,     			
						estatus,     			
						idcamp,      			
						idjerarquia, 			
						idnivel,     			
						idzona,      			
						activa,      			
						act_zona,    			
						combinable,  			
						idmensaje,   			
						tran_nro    			
				   INTO cEmpresa,     
						cSucursal,    
						cNum_Producto,
						cSistema,     
						cEstatus,     
						sIdCamp,      
						sIdJerarquia, 
						sIdNivel,     
						sIdZona,      
						sActiva,      
						sAct_Zona,    
						sCombinable,  
						sIdMensaje,   
						sTran_nro    			   
				   FROM bdinteg:"informix".si_maecamp
				  WHERE empresa='001' and (sucursal = cSucursalParam  OR sucursal = 'T')
					AND	activa = 1	
					
				IF NVL(cEmpresa,"") <> "" OR NVL(cSucursal,"") <> "" OR NVL(cNum_Producto,"") <> "" OR NVL(cSistema,"") <> "" THEN
													
					LET iContador = iContador + 1;

					IF iContador <= iNumRegistros THEN --DSB 11/10/2013 Christian Echavarria se agrega =
						CONTINUE FOREACH;
					END IF; 
					
				   RETURN cCodRet, 
				         cCodRet2,
						 cEmpresa,     
						 cSucursal,    
						 cNum_Producto,
						 cSistema,     
						 cEstatus,     
						 sIdCamp,      
						 sIdJerarquia, 
						 sIdNivel,     
						 sIdZona,      
						 sActiva,     
						 sAct_Zona, 
						 sCombinable,  
						 sIdMensaje,  				 
						 sTran_nro
					WITH RESUME;					
				
				ELSE	

					--No se encontraron datos
					LET cCodRet2 = '00002';

				  RETURN cCodRet, 
				         cCodRet2,
						 cEmpresa,     
						 cSucursal,    
						 cNum_Producto,
						 cSistema,     
						 cEstatus,     
						 sIdCamp,      
						 sIdJerarquia, 
						 sIdNivel,     
						 sIdZona,      
						 sActiva,     
						 sAct_Zona, 
						 sCombinable,  
						 sIdMensaje,  				 
						 sTran_nro
					WITH RESUME;
				  					
				END IF;

			END FOREACH; 
																--1711
			IF NVL(cEmpresa,"") = "" OR (NVL(cSucursal,"") = "" AND NVL(cPlaza,"") = "" ) OR NVL(cNum_Producto,"") = "" OR NVL(cSistema,"") = "" THEN		
				LET cCodRet2 = '00003';

				  RETURN cCodRet, 
				         cCodRet2,
						 cEmpresa,     
						 cSucursal,    
						 cNum_Producto,
						 cSistema,     
						 cEstatus,     
						 sIdCamp,      
						 sIdJerarquia, 
						 sIdNivel,     
						 sIdZona,      
						 sActiva,     
						 sAct_Zona, 
						 sCombinable,  
						 sIdMensaje,  				 
						 sTran_nro;
			END IF;
			
		END IF;

	END
END PROCEDURE
DOCUMENT
'Se consultan los datos de la tabla si_maecamp para replicarlos en sucursal',
'Realizó: Nancy Sevilla Camacho',
'Fecha: 03/05/2012  ',
'Se modifica el foreach para la paginación',
'Realizó: Christian Echavarria',
'Fecha: 11/10/2013',
'BD    : bdinteg',
'FECHA: 27/04/2015',
'FOLIO :1711',
'PROYECTO: TICKETINTELIGENTEBANCOPPEL',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA VALIDAR SI EL NUMERO DE ZONA O DE SUCURSAL ESTAN VACIAS RETORNE EL CODIGO 3',
'AUTOR: 95358897-ISARAI BOJORQUEZ',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_generararchivoplanobatch_pba(cTipoMov CHAR(2), pFechaAct DATE)
RETURNING
     CHAR(6); ---cod_ret

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);
	DEFINE vsSQL1 				CHAR (150);
	DEFINE vsSQL2 				CHAR (750) ;
	DEFINE vsSQL3 				CHAR (150) ;
	--DEFINE v_NomArchivo  VARCHAR(50);
	DEFINE vRuta CHAR (90);
	DEFINE vsSQL CHAR (1050) ;
	DEFINE sPreNomArchivoFinal VARCHAR(100);
	DEFINE sNombreArchivoFinal VARCHAR(100);
	-- AAME RQI 27 067 SE AGREGA VARIABLE PARA EL NUEVO ARCHIVO
	DEFINE sAntNomArchivoFinal VARCHAR(100);
	DEFINE sAnterNomArchivoFinal VARCHAR(100);
	DEFINE iCountMovTO INTEGER;
	DEFINE v_TipoMov VARCHAR (20);
	DEFINE cFecha_hoy CHAR(8);
	DEFINE cFechaSistema DATE;
	DEFINE vAux VARCHAR(50,1);
	
	LET vsSQL = '' ;
	LET vsSQL1 = '' ;
	LET vsSQL2 = '' ;
	LET vsSQL3 = '' ;
	LET iCountMovTO = 0;
	LET  v_TipoMov = '';
	LET cFecha_hoy = '19000101';
	LET cFechaSistema = DATE(1);
	LET sPreNomArchivoFinal ='';
	LET sNombreArchivoFinal ='';
	-- AAME RQI 27 067 SE INICIALIZA VARIABLE PARA EL NUEVO ARCHIVO
	LET sAntNomArchivoFinal ='';
	LET sAnterNomArchivoFinal='';
    LET vAux = "||'||'||'|'||1||'||'||-99999||'|'||99999";
	
SET ISOLATION TO COMMITTED READ LAST COMMITTED;	
	---SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE  "informix".sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/sp_GenerarArchivoPlano.out";
	--SET DEBUG FILE TO "/informix/Malena/sp_GenerarArchivoPlano.out";
	--TRACE ON;

	LET v_cod_ret = '000000';
	LET vDesErr = '';
	
	SELECT TRIM(valor)
	INTO vRuta
	FROM "informix".si_param
	WHERE cod_param='193';

	--LET vRuta = '/resplogifx/archivoscartera/altaunica/envios/';
	LET sNombreArchivoFinal = TRIM(vRuta)||'movimientosaltaunica';
	-- INC 27 047 Se cambia el nombrado de los archivos generados a como se encontraban los productivos.
	
	IF cTipoMov IS NULL OR (cTipoMov <> '' AND cTipoMov <> 'TO') THEN
		LET v_cod_ret = '000001';
		RETURN v_cod_ret;
	END IF;
	
	SELECT COUNT(tipomovto) INTO iCountMovTO FROM "informix".si_archivoscopdiario WHERE tipomovto = 'TO' AND fecha_insert = pFechaAct;
	
	SELECT fecha_hoy INTO cFechaSistema FROM bdinteg:"informix".si_fechas;
    
	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		IF iCountMovTO > 0 THEN
			IF cTipoMov = '' THEN	---	Se valida el tipo de movimiento
					
				IF EXISTS (SELECT  {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} DISTINCT tipomovto FROM "informix".si_archivoscopdiario WHERE tipomovto <> 'TO' AND fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					LET sNombreArchivoFinal = TRIM(vRuta)||'movimientosaltaunica'|| cFecha_hoy || '.txt' ;
					LET sPreNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica.unl';
					-- AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
					LET sAntNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica2.unl';
					LET sAnterNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica3.unl';
					--
					LET vsSQL = ' echo "UNLOAD TO ' ||  TRIM(vRuta)|| 'movimientosaltaunicax.unl' || ' DELIMITER ' || '''|''' || 
								' SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} trama ' || TRIM(vAux) ||
								' FROM "informix".si_archivoscopdiario '||
								' WHERE tipomovto <> '||'''TO'''||
								' AND fecha_insert = '||''''||pFechaAct||''''||
								' " > ' || TRIM(vRuta)|| 'Ejecutamovimientosaltaunica.sql';
					SYSTEM vsSQL;
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "Ejecutamovimientosaltaunica.sql";
					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg ' || TRIM(vRuta)|| 'Ejecutamovimientosaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "movimientosaltaunicax.unl > " || sPreNomArchivoFinal;
					SYSTEM vsSQL;					
					LET vsSQL = '';
					LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "movimientosaltaunica.unl > " || sAntNomArchivoFinal;
					SYSTEM vsSQL;
					-- AAME RQI 27 067 SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÍOS
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "movimientosaltaunica2.unl > " || sAnterNomArchivoFinal;
					SYSTEM vsSQL;				
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "movimientosaltaunica3.unl > " || sNombreArchivoFinal;
					SYSTEM vsSQL;	
					--
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "movimientosaltaunicaderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm " || TRIM(vRuta)|| "movimientosaltaunicaderechos.txt";
					SYSTEM vsSQL;
					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO "informix".si_archivoscophist(empresa,secuencia, identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
					FROM "informix".si_archivoscopdiario
					WHERE tipomovto <> 'TO'
					AND fecha_insert = pFechaAct;
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE FROM "informix".si_archivoscopdiario
					WHERE tipomovto <> 'TO' 
					AND fecha_insert = pFechaAct;					
									
				END IF;
			ELIF cTipoMov = 'TO'  THEN --Valida el tipo de movimiento para generar el archivo de totales
				LET v_cod_ret = '000000';
				IF EXISTS (SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)}DISTINCT tipomovto FROM "informix".si_archivoscopdiario WHERE tipomovto = 'TO' AND fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					LET sNombreArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica'|| cFecha_hoy || '.txt';
					LET sPreNomArchivoFinal =  TRIM(vRuta)|| 'cifrasaltaunica.unl';
					-- AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
					LET sAntNomArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica2.unl';
					LET sAnterNomArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica3.unl';
					--
					---	GENERA EL ARCHIVO PLANO
					LET vsSQL1 = ' echo "UNLOAD TO ' || TRIM(vRuta)||'cifrasaltaunicax.unl' || ' DELIMITER ' || '''|''';
					LET vsSQL2 = "SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} trama FROM  bdinteg:si_archivoscopdiario WHERE  tipomovto = '"||cTipoMov||"' AND fecha_insert ='"||pFechaAct||"';";
					LET vsSQL3 = ' " > '|| TRIM(vRuta) || 'Ejecutacifrasaltaunica.sql'; 
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
					SYSTEM vsSQL;
				    LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "Ejecutacifrasaltaunica.sql";
					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg '|| TRIM(vRuta)|| 'Ejecutacifrasaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "cifrasaltaunicax.unl > "|| sPreNomArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "cifrasaltaunica.unl > "|| sAntNomArchivoFinal;
					SYSTEM vsSQL;
					-- AAME RQI 27 067 SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÍOS
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "cifrasaltaunica2.unl > " || sAnterNomArchivoFinal;
					SYSTEM vsSQL;	
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "cifrasaltaunica3.unl > " || sNombreArchivoFinal;
					SYSTEM vsSQL;	
					--
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 " || sNombreArchivoFinal || " > "|| TRIM(vRuta)|| "cifrasaltaunicaderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm "|| TRIM(vRuta)|| "cifrasaltaunicaderechos.txt";
					SYSTEM vsSQL;
				
					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO "informix".si_archivoscophist(empresa,secuencia, identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
					FROM "informix".si_archivoscopdiario
					WHERE tipomovto = 'TO'
					AND fecha_insert = pFechaAct;
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE {+INDEX(si_archivoscopdiario idx_si_archivoscopdiario1)} FROM "informix".si_archivoscopdiario
					WHERE tipomovto = 'TO' 
					AND fecha_insert = pFechaAct;							

				END IF;
			END IF;
		ELSE
			LET v_cod_ret = '000002';
		END IF;
	ELSE
		LET v_cod_ret = '000003';
	END IF;
	RETURN v_cod_ret;
END;
--##############################################################################
--## Procedimiento   : "informix".sp_GenerarArchivoPlanobatch
--## Version         : 1.0
--## Creado por      : Maria Elena Angulo
--## Fecha creacion  : Diciembre de 2008
--## Descripcion     : Espejo del procedimiento sp_GenerarArchivoPlano que Realiza la generacion del archivo plano con las 
--## adecuaciones para los nuevos procesos que realizan la generación de archivos batch.
--##############################################################################
END PROCEDURE;