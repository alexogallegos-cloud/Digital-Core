CREATE PROCEDURE "informix".sp_rep_cobvent_ctetitular(pOpcion INTEGER, pFechaIni date, pFechaFin date) 
-- pOpcion = 1	FECHAS AUTOMATICAS, pOpcion = 2 CONSULTAR POR RANGO DE FECHA INICIO A FECHA FIN.	
--"pFechaIni" Y "pFechaFin" SON PARA LA pOpcion = 2, SI "pOpcion ES "1" LOS PARAMETRO DEBEMOS ENVIARLOS VACIOS.   		

	--RETORNOS
	RETURNING
	CHAR(6) AS cCodRet, 
	CHAR(50) AS cMensajeRet; 
	
	-- CREACION DE VARIABLES.
	DEFINE cCodRet              CHAR(6);		--	CODIGO DE RETORNO. 
	DEFINE iSqlErr              INTEGER;		--	ERROR CONTROLADO DE BDD.
	DEFINE cMensajeRet			CHAR(50);		--	MENSAJE DE RETORNO.
	DEFINE dFechaHoy		    DATE;			--	FECHA ACTUAL DEL SISTEMA.
	DEFINE iDia					INTEGER;		--	DIA ACTUAL.		
	DEFINE cRuta				CHAR(200);		--	RUTA DEL REPORTE.
	DEFINE cSeparador			CHAR(1);		--	SEPARADOR DE CAMPOS	
	DEFINE cNombreArchivo		CHAR(50);		--	NOMBRE DEL REPORTE.	
	DEFINE cGeneraSql			CHAR(2000);		--	GENERA EL ARCHIVO.
	DEFINE cSql                	CHAR(500);		--	ALMACENA LA CADENA A CREAR.
	DEFINE cEmpresa				CHAR(3);		--	EMPRESA.
	DEFINE cFechaRepINI			CHAR(10);		
	DEFINE cFechaRepFIN			CHAR(10);
	DEFINE dFechaRepINI 		DATE;
	DEFINE dFechaRepFIN 		DATE;
	DEFINE cNombreArchivo_head  CHAR(15);
	DEFINE cNombreArchivo_aux	CHAR(50);		--	ARCHIVO AUXILIAR.
	
	-- INICIALIZACION DE VARIABLES.
	LET cCodRet                 = 	'';
	LET iSqlErr                 =	0;
	LET cMensajeRet				=	'';
	LET dFechaHoy				=	NULL;
	LET iDia					=	0;	
	LET cRuta					=	'';
	LET cSeparador				=	'';	
	LET cNombreArchivo			=	'';
	LET cGeneraSql				=	'';	
	LET cSql 					=	'';	
	LET cEmpresa				=	'001';
	LET cFechaRepINI			=	'';
	LET cFechaRepFIN			=	'';
	LET dFechaRepINI 			=	date(1);
	LET dFechaRepFIN			= 	date(1);
	LET cNombreArchivo_head  = 'encabezado1.txt';
	LET cNombreArchivo_aux  = '';
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/home/sysifx/PaulGarcia/TRACE/sp_rep_cobvent_ctetitular.out';
	--SET DEBUG FILE TO '/ifxsif01/macf/sp_rep_cobvent_ctetitular.out';
	--TRACE ON;
	
	BEGIN
		
			ON EXCEPTION SET iSqlErr		
			 
			 LET cCodRet 			= iSqlErr;
			  LET cMensajeRet 	= "ERROR DE BDD";
			  RETURN cCodRet,cMensajeRet;
			  
			END EXCEPTION;
		
			--	*****************************************************************************
			--	*	cCodRet	=	"000000".	(CREACION DE REPORTE EXITOSO).					*
			--	*	cCodRet	=	"000001".	(ERROR OPCION INVALIDA).						*
			--	*	cCodRet	=	"000002".	(ERROR FECHAS INCORRECTAS).						*
			--	*	cCodRet	=	"000003".	(ERROR AL OBTENER RUTA O NOMBRE DEL REPORTE).	*
			--	*****************************************************************************
		
			IF pOpcion <= 0 OR pOpcion > 2  THEN
			
				LET cCodRet     	= "000001";
				LET cMensajeRet		= "ERROR OPCION INVALIDA.";
				
				RETURN cCodRet, cMensajeRet;
				
			ELIF pOpcion = 2 THEN
			
				--IF pFechaIni = "" AND pFechaFin = "" THEN
				IF NVL(pFechaIni,'') = "" AND NVL(pFechaFin,"") = "" THEN

					--	SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.
					LET cCodRet     	= "000002";
					LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
					
					RETURN cCodRet, cMensajeRet;
				
				ELSE
				
				   LET dFechaRepINI = pFechaIni;
	               LET dFechaRepFIN = pFechaFin;

				END IF;	
				
			END IF;
			
				--	OBTENER LA RUTA DONDE SE ALMACENARA EL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
				SELECT valor_alfabetico
				INTO cRuta
				FROM cb_param_campania
				WHERE empresa = cEmpresa 
				AND tipo_campania = 11 
				AND grupo_parametro = 'RUTAS' 
				AND num_parametro = 1;
				
				-- OBTIENE EL SEPARADOR DE LOS CAMPOS
				SELECT valor_alfabetico 
				INTO cSeparador
				FROM bdicobranza:cb_param_campania
				WHERE empresa       = cEmpresa
				AND tipo_campania   = '1'
				AND grupo_parametro = 'ARCHIVOS'
				AND num_parametro   = 2;
				
				-- OBTENER EL NOMBRE DEL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
				SELECT valor_alfabetico 
				INTO cNombreArchivo
				FROM cb_param_campania
				WHERE empresa = cEmpresa
				AND tipo_campania = 1 
				AND grupo_parametro = 'ARCHIVOS'
				AND num_parametro = 93;
		
				IF NVL(cRuta,'') = '' OR NVL(cSeparador,'') = '' OR NVL(cNombreArchivo,'') = '' THEN

					LET cCodRet     	= "000003";
					LET cMensajeRet 	= "ERROR AL OBTENER LA RUTA, SEPARADOR DE CAMPOS O NOMBRE DEL REPORTE.";
					
					RETURN cCodRet, cMensajeRet;

				END IF; 

			--	SE ASIGNAN VALORES A VARIABLES PARA MANEJO DE FECHAS.	
			
			SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicred:sd_fechas
			WHERE empresa = cEmpresa;
			
			--LET dFechaHoy = mdy(9,15,2020);

			LET iDia = TO_NUMBER(TO_CHAR(dFechaHoy,"%d") :: INTEGER);

			IF pOpcion = 1 THEN

				IF iDia = 8 OR iDia = 15 OR iDia = 22 THEN 
				
					--LET pFechaIni = TO_CHAR((dFechaHoy - 7),"%Y-%m-%d");
					--LET pFechaFin = TO_CHAR((dFechaHoy - 1),"%Y-%m-%d");
					LET dFechaRepINI = (dFechaHoy - 7);
					LET dFechaRepFIN = (dFechaHoy - 1);
					
				ELIF iDia = 1 THEN
										
					--LET pFechaIni = TO_CHAR(ADD_MONTHS(dFechaHoy,-1),"%Y-%m")||'-22';
					--LET pFechaFin = TO_CHAR(LAST_DAY(ADD_MONTHS(dFechaHoy,-1)),'%Y-%m-%d');
					LET dFechaRepINI = (ADD_MONTHS(dFechaHoy,-1) -22);
					LET dFechaRepFIN = (LAST_DAY(ADD_MONTHS(dFechaHoy,-1)));
							
				END IF;
			
			END IF;
					
			--IF dFechaRepINI <> '' AND dFechaRepFIN <> '' THEN
			IF NVL(dFechaRepINI,'') <> "" AND NVL(dFechaRepFIN,'') <> "" THEN
			
				-- CAMBIAR FORMATO DE FECHA PARA CONCATENARLO AL NOMBRE DEL REPORTE.
				--LET dFechaRepINI = TO_DATE(pFechaIni, "%Y-%m-%d");
				--LET dFechaRepFIN = TO_DATE(pFechaFin, "%Y-%m-%d");
				
				LET cFechaRepINI =  TO_CHAR(dFechaRepINI,"%d%m%Y");
				LET cFechaRepFIN =  TO_CHAR(dFechaRepFIN,"%d%m%Y");
				
				LET cNombreArchivo_aux = TRIM(cNombreArchivo) || '.txt';
				LET cNombreArchivo = TRIM(cNombreArchivo) || TRIM(cFechaRepINI) || '_al_' || TRIM(cFechaRepFIN) || '.txt';
				
	
				LET cSql = '' ;
				LET cSql = 'echo "Sucursal|Empleado|Nombre_Cajero|Si|No|" > '|| TRIM(cRuta) || trim(cNombreArchivo_head);
				SYSTEM trim(cSql);
				
			
				-- GENERAR EL ARCHIVO DE TEXTO.
				LET cSql = '' ;
				LET cSql = "SELECT cv.sucursal, cv.empleado,e.nombre,sum(cv.cont_si)::INTEGER CONT_SI,sum(cv.cont_no)::INTEGER CONT_NO "
							||"FROM cb_cob_vent_cliente_titular cv INNER JOIN bdinteg: si_ejecut e ON cv.empleado = e.ejecutivo "
							--||" AND " || "TRIM(TO_CHAR(cv.fecha,'%Y-%m-%d')) BETWEEN '" || TRIM(pFechaIni) || "' AND '" || TRIM(pFechaFin) || "' " 
							||" AND " || "cv.fecha BETWEEN '" || dFechaRepINI || "' AND '" || dFechaRepFIN || "' " 
							||"GROUP BY cv.sucursal, cv.empleado,e.nombre "
							||"ORDER BY cv.sucursal ASC; ";
				
				LET cGeneraSql = "'" || TRIM(cRuta) ||TRIM(cNombreArchivo_aux) || "' DELIMITER '" || cSeparador || "'";
				LET cGeneraSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cGeneraSql) || ' ' || TRIM(cSql) || '" > ' || TRIM(cRuta) || 'ctetitular.sql';
				SYSTEM trim(cGeneraSql);

				-- PERMISO PARA LA CREACION DE ARCHIVO.
				LET cSql = '' ;
				LET cSql = 'chmod 666 ' || TRIM(cRuta) || 'ctetitular.sql';
				LET cSql = '' ;
				LET cSql = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'ctetitular.sql';
				SYSTEM trim(cSql);
				
				LET cSql = '' ;
				LET cSql = 'cat ' || trim(cRuta) || trim(cNombreArchivo_head) || ' ' || trim(cRuta) || trim(cNombreArchivo_aux)  || ' >' ||trim(cRuta) || trim(cNombreArchivo); 
		        SYSTEM trim(cSql);

				-- BORRA EL ARCHIVO DE CONTROL.
				LET cSql = '' ;
				LET cSql = 'rm ' || TRIM(cRuta) || 'ctetitular.sql ' || TRIM(cRuta) || trim(cNombreArchivo_head) || ' ' || TRIM(cRuta) || trim(cNombreArchivo_aux) ;
				SYSTEM trim(cSql);

				LET cSql = '';
				LET cSql = 'gzip -f ' ||trim(cRuta) || trim(cNombreArchivo); 
				SYSTEM trim(cSql);
				
				LET cCodRet     	=	"000000";
				LET cMensajeRet 	=	"CREACION DE REPORTE EXITOSO.";
				
				RETURN cCodRet, cMensajeRet;
				
			ELSE
			
				--	SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.
				LET cCodRet     	= "000002";
				LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
				
				RETURN cCodRet, cMensajeRet;
			
			END IF;
			
		RETURN cCodRet,cMensajeRet; 
		
	END;
END PROCEDURE
DOCUMENT
'Folio:659.',
'Autor: 98786903 Paul Antonio Garcia Gastelum.',
'Fecha: 09/03/2020.',
'DESCRIPCION: Procedimineto para creacion de archivo con el conteo de la tabla cb_cob_vent_cliente_titular.',
'Solicita: Marco Campos.',
'BD: bdicobranza.';

CREATE PROCEDURE "informix".sp_rep_cobvent_mtvosrechazo(pOpcion INTEGER, pFechaIni date, pFechaFin date)
--	pOpcion = 1	FECHAS AUTOMATICAS, pOpcion = 2 CONSULTAR POR RANGO DE FECHA INICIO A FECHA FIN.															
--	"pFechaIni" Y "pFechaFin" SON PARA LA pOpcion = 2, SI "pOpcion ES "1" LOS PARAMETRO DEBEMOS ENVIARLOS VACIOS.   		
	
	--RETORNOS
	RETURNING
	CHAR(6) AS cCodRet, CHAR(50) AS cMensajeRet; 
	
	-- CREACION DE VARIABLES.
	DEFINE cCodRet              CHAR(6);		--	CODIGO DE RETORNO. 
	DEFINE iSqlErr              INTEGER;		--	ERROR CONTROLADO DE BDD.
	DEFINE cMensajeRet			CHAR(50);		--	MENSAJE DE RETORNO.
	DEFINE dFechaHoy		    DATE;			--	FECHA ACTUAL DEL SISTEMA.
	DEFINE iDia					INTEGER;		--	DIA ACTUAL.		
	DEFINE cRuta				CHAR(200);		--	RUTA DEL REPORTE.
	DEFINE cSeparador			CHAR(1);		--	SEPARADOR DE CAMPOS	
	DEFINE cNombreArchivo		CHAR(50);		--	NOMBRE DEL REPORTE.	
	DEFINE cGeneraSql			CHAR(2000);		--	GENERA EL ARCHIVO.
	DEFINE cSql                	CHAR(1000);		--	ALMACENA LA CADENA A CREAR.
	DEFINE cEmpresa				CHAR(3);		--	EMPRESA.
	DEFINE cInifecRep			CHAR(10);
	DEFINE cFechaRepINI			CHAR(10);		
	DEFINE cFechaRepFIN			CHAR(10);
	DEFINE dFechaRepINI 		DATE;
	DEFINE dFechaRepFIN 		DATE;
	DEFINE cNombreArchivo_head  CHAR(15);
	DEFINE cNombreArchivo_aux	CHAR(50);		--	ARCHIVO AUXILIAR.	
	
	-- INICIALIZACION DE VARIABLES.
	LET cCodRet                 = 	'';
	LET iSqlErr                 =	0;
	LET cMensajeRet				=	'';
	LET dFechaHoy				=	NULL;
	LET iDia					=	0;	
	LET cRuta					=	'';
	LET cSeparador				=	'';	
	LET cNombreArchivo			=	'';
	LET cGeneraSql				=	'';	
	LET cSql 					=	'';	
	LET cEmpresa				=	'001';
	LET cFechaRepINI			=	'';
	LET cFechaRepFIN			=	'';
	--LET dFechaRepINI 			=	NULL;
	--LET dFechaRepFIN			= 	NULL;
	LET dFechaRepINI = date(1);
	LET dFechaRepFIN = date(1);
	LET cNombreArchivo_head  = 'encabezado2.txt';
	LET cNombreArchivo_aux  = '';
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/home/sysifx/PaulGarcia/TRACE/sp_rep_cobvent_mtvosrechazo.out';
	--SET DEBUG FILE TO '/ifxsif01/macf/sp_rep_cobvent_mtvosrechazo.out';
	--TRACE ON;
	
	
	BEGIN
		
			ON EXCEPTION SET iSqlErr		
			 
				LET cCodRet			= iSqlErr;
				LET cMensajeRet 	= "ERROR DE BDD";
				
			RETURN cCodRet,cMensajeRet;
				  
			END EXCEPTION;
		
			--	*****************************************************************************
			--	*	cCodRet	=	"000000".	(CREACION DE REPORTE EXITOSO).					*
			--	*	cCodRet	=	"000001".	(ERROR OPCION INVALIDA).						*
			--	*	cCodRet	=	"000002".	(ERROR FECHAS INCORRECTAS).						*
			--	*	cCodRet	=	"000003".	(ERROR AL OBTENER RUTA O NOMBRE DEL REPORTE).	*
			--	*****************************************************************************
		
			IF pOpcion <= 0 OR pOpcion > 2  THEN
			
				LET cCodRet     	= "000001";
				LET cMensajeRet		= "ERROR OPCION INVALIDA.";
				
				RETURN cCodRet, cMensajeRet;
				
			ELIF pOpcion = 2 THEN
			
				IF NVL(pFechaIni,'') = "" AND NVL(pFechaFin,"") = "" THEN

					--	SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.
					LET cCodRet     	= "000002";
					LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
					
					RETURN cCodRet, cMensajeRet;
				ELSE
				   LET dFechaRepINI = pFechaIni;
	               LET dFechaRepFIN = pFechaFin;

				END IF;	
				
			END IF;
			
				--	OBTENER LA RUTA DONDE SE ALMACENARA EL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
				SELECT valor_alfabetico
				INTO cRuta	
				FROM cb_param_campania
				WHERE empresa = cEmpresa 
				AND tipo_campania = 11 
				AND grupo_parametro = 'RUTAS' 
				AND num_parametro = 1;
				
				-- OBTIENE EL SEPARADOR DE LOS CAMPOS
				SELECT valor_alfabetico 
				INTO cSeparador
				FROM bdicobranza:cb_param_campania
				WHERE empresa       = cEmpresa
				AND tipo_campania   = '1'
				AND grupo_parametro = 'ARCHIVOS'
				AND num_parametro   = 2;
				
				-- OBTENER EL NOMBRE DEL ARCHIVO DE CONTEO PARA CLIENTES TITULARES.
				SELECT valor_alfabetico 
				INTO cNombreArchivo
				FROM cb_param_campania
				WHERE empresa = cEmpresa
				AND tipo_campania = 1 
				AND grupo_parametro = 'ARCHIVOS'
				AND num_parametro = 94;
		
			IF NVL(cRuta,'') = '' OR NVL(cSeparador,'') = '' OR NVL(cNombreArchivo,'') = '' THEN

				LET cCodRet     	= "000003";
				LET cMensajeRet 	= "ERROR AL OBTENER LA RUTA, SEPARADOR DE CAMPOS O NOMBRE DEL REPORTE.";
				
				RETURN cCodRet, cMensajeRet;

			END IF; 

			--	SE ASIGNAN VALORES A VARIABLES PARA MANEJO DE FECHAS.			
			SELECT fecha_hoy
			 INTO dFechaHoy
			 FROM bdicred:sd_fechas
			WHERE empresa = cEmpresa;	
			
			--LET dFechaHoy = mdy(7,8,2020);

			LET iDia = TO_NUMBER(TO_CHAR(dFechaHoy,"%d"));

			IF pOpcion = 1 THEN

				IF iDia = 8 OR iDia = 15 OR iDia = 22 THEN 
				
					--LET pFechaIni = TO_CHAR((dFechaHoy - 7),"%Y-%m-%d");
					--LET pFechaFin = TO_CHAR((dFechaHoy - 1),"%Y-%m-%d");
					LET dFechaRepINI = (dFechaHoy - 7);
					LET dFechaRepFIN = (dFechaHoy - 1);
					
				ELIF iDia = 1 THEN
										
					--LET pFechaIni = TO_CHAR(ADD_MONTHS(dFechaHoy,-1),"%Y-%m")||'-22';
					--LET pFechaFin = TO_CHAR(LAST_DAY(ADD_MONTHS(dFechaHoy,-1)),'%Y-%m-%d');
					LET dFechaRepINI = (ADD_MONTHS(dFechaHoy,-1) -22);
					LET dFechaRepFIN = (LAST_DAY(ADD_MONTHS(dFechaHoy,-1)));
				END IF;

			END IF;
					

			IF NVL(dFechaRepINI,'') <> "" AND NVL(dFechaRepFIN,'') <> "" THEN
			
				-- CAMBIAR FORMATO DE FECHA PARA CONCATENARLO AL NOMBRE DEL REPORTE.
				--LET dFechaRepINI = TO_DATE(pFechaIni, "%Y-%m-%d");
				--LET dFechaRepFIN = TO_DATE(pFechaFin, "%Y-%m-%d");
				
				LET cFechaRepINI =  TO_CHAR(dFechaRepINI,"%d%m%Y");
				LET cFechaRepFIN =  TO_CHAR(dFechaRepFIN,"%d%m%Y");
					
				--LET cNombreArchivo = TRIM(cNombreArchivo) || TRIM(cFechaRepINI) || '_al_' || TRIM(cFechaRepFIN) || '.txt';
				
				LET cNombreArchivo_aux = TRIM(cNombreArchivo) || '.txt';
				LET cNombreArchivo = TRIM(cNombreArchivo) || TRIM(cFechaRepINI) || '_al_' || TRIM(cFechaRepFIN) || '.txt';
				
	
				LET cSql = '' ;  
				LET cSql = 'echo "Sucursal|Empleado|Nombre_Cajero|Num_Cliente|Mot_rechazo|" > '|| TRIM(cRuta) || trim(cNombreArchivo_head);
				SYSTEM trim(cSql);
				
				-- GENERAR EL ARCHIVO DE TEXTO.
				LET cSql = "SELECT b.sucursal AS sucursal, b.usr_captura AS empleado, e.nombre AS nombre_cajero, b.numcliente AS num_cliente, m.descripcion AS mot_rechazo "
							||"FROM cb_compac_bit_realiza b INNER JOIN  bdinteg: si_ejecut e ON  b.usr_captura = e.ejecutivo AND b.negociar_convenio IN ('N','NT') "
							||"INNER JOIN cb_param_campania m ON b.motivo = m.valor_numerico AND m.tipo_campania = 11 AND m.grupo_parametro = 'MOTRCOMPAC' AND "
							--||"SUBSTR(b.fh_movimiento, 0, 10) BETWEEN '" || TRIM(pFechaIni) || "' AND '" || TRIM(pFechaFin) || "' " 
							||"b.fh_movimiento BETWEEN mdy('" || month(dFechaRepINI) || "','" || day(dFechaRepINI)|| "','" || year(dFechaRepINI) || "') "
							||"AND mdy('" || month(dFechaRepFIN) || "','" || day(dFechaRepFIN)|| "','" || year(dFechaRepFIN) || "') " 
							||"GROUP BY b.sucursal, b.usr_captura, e.nombre, b.numcliente, m.descripcion ORDER BY b.sucursal ASC;";
				
				
				LET cGeneraSql = "'" || TRIM(cRuta) ||TRIM(cNombreArchivo_aux) || "' DELIMITER '" || cSeparador || "'";
				LET cGeneraSql = 'echo "UNLOAD TO ' || TRIM(cGeneraSql) || ' ' || TRIM(cSql) || '" > ' || TRIM(cRuta) || 'mtvosrechazo.sql';
				SYSTEM cGeneraSql;

				-- PERMISO PARA LA CREACION DE ARCHIVO.
				LET cSql = '' ;
				LET cSql = 'chmod 775 ' || TRIM(cRuta) || 'mtvosrechazo.sql';
				LET cSql = '' ;
				LET cSql = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'mtvosrechazo.sql';
				SYSTEM trim(cSql);

				LET cSql = '' ;
				LET cSql = 'cat ' || trim(cRuta) || trim(cNombreArchivo_head) || ' ' || trim(cRuta) || trim(cNombreArchivo_aux)  || '>' ||trim(cRuta) || trim(cNombreArchivo); 
		        SYSTEM trim(cSql);
				
				-- BORRA EL ARCHIVO DE CONTROL.
				LET cSql = '' ;
				LET cSql = 'rm ' || TRIM(cRuta) || 'mtvosrechazo.sql ' || TRIM(cRuta) || trim(cNombreArchivo_head) || ' ' || TRIM(cRuta) || trim(cNombreArchivo_aux) ;
				SYSTEM trim(cSql);

				LET cSql = '';
				LET cSql = 'gzip -f ' ||trim(cRuta) || trim(cNombreArchivo); 
				SYSTEM trim(cSql);
				
				LET cCodRet     	=	"000000";
				LET cMensajeRet 	=	"CREACION DE REPORTE EXITOSO.";
				
				RETURN cCodRet, cMensajeRet;
				
			ELSE
			
				--	SI LAS FECHAS SON VACIAS MANDAR MENSAJE DE ERROR CORRESPONDIENTE.
				LET cCodRet     	= "000002";
				LET cMensajeRet 	= "ERROR FECHAS INCORRECTAS.";
				
				RETURN cCodRet, cMensajeRet;
			
			END IF;
			
		RETURN cCodRet,cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
'Folio:659.',
'Autor: 98786903 Paul Antonio Garcia Gastelum.',
'Fecha: 09/03/2020.',
'DESCRIPCION: Procedimineto para creacion de archivo con el conteo motivos de rechazo.',
'Solicita: Marco Campos.',
'BD: bdicobranza.';

CREATE PROCEDURE "informix".sp_ctbcpl_gen_arctelefonos_pred(pEmpresa         CHAR(3),
                                                       pTipoCobranza    CHAR(1),
                                                       pFechaGenCartera DATE,
                                                       pStatusTel       CHAR(2))
RETURNING CHAR(6) AS COD_RET;

-- DECLARACIONES
DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensaje 		    CHAR(80);
DEFINE cRuta                CHAR(100);
DEFINE cNomArchivo          CHAR(100);
DEFINE cNomArchivoAux       CHAR(100);
DEFINE cNomArchivoEjecSql   CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(100);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cFechaGenArchivo     CHAR(8);
DEFINE cEmpresa             CHAR(3);
DEFINE cDelimitador         CHAR(1);
DEFINE cTipoCampania        CHAR(1);
DEFINE cCodRetIB            CHAR(6);
DEFINE vnumparametro        SMALLINT;
--1728
DEFINE cNumProd				CHAR(4);
DEFINE cNumProd2			CHAR(4);
DEFINE iConProd				INTEGER;
DEFINE iPrimeraVez			INTEGER;
DEFINE vnumparametro2       SMALLINT;
DEFINE vproceso			    CHAR(06);
DEFINE vday					INTEGER;
DEFINE vnum_prod			CHAR(4);
DEFINE vbandera				CHAR(1);
DEFINE vContTrab			INTEGER;
DEFINE v_num_producto	    CHAR(4);
DEFINE dt_FechaCorte        DATE;
DEFINE c_tipo_producto      CHAR(2);
DEFINE c_canal              CHAR(4); 	
DEFINE bandera_ree			CHAR(1);
DEFINE cNombreArchivo_ree   CHAR(50);
DEFINE dFechahoy_sys        DATE;
DEFINE c_canal_actual       CHAR(4);
DEFINE c_canal_temp         CHAR(4);
DEFINE iNumProds 			INTEGER;
DEFINE iNumProds_pent       INTEGER;
DEFINE iNumProds_siga       INTEGER;
DEFINE iNumProds_test       INTEGER;
DEFINE iCuentaPP            INTEGER;
DEFINE cComprimirArch       CHAR(1);

-- INICIALIZACIONES
LET iSqlErr                 = 0;
LET iIsamErr                = 0;
LET cCodRet                 = '000000';
LET cMensaje                = 'PROCESO EXITOSO';
LET cRuta                   = '';
LET cNomArchivo             = '';
LET cNomArchivoAux          = '';
LET cNomArchivoEjecSql      = '';
LET cSQL                    = '';
LET cSQL1                   = '';
LET cSQL2                   = '';
LET cSQL3                   = '';
LET cEmpresa                = '000';
LET cDelimitador            = '';
LET cTipoCampania           = '';
LET cCodRetIB               = '000000';
---
LET cNumProd           		= '';
LET cNumProd2           	= '';
LET iConProd                = 0;
LET iPrimeraVez             = 0;
LET vnumparametro2          = 0;
LET vproceso				= "0312";
LET vday 					= 0;
LET vnum_prod 				= '';
LET vbandera 				= '';
LET vContTrab 				= 0;
LET v_num_producto          = '';
LET dt_FechaCorte           = pFechaGenCartera;
LET c_tipo_producto         = '';
LET c_canal                 = ''; 
LET bandera_ree			    = ''; 
LET cNombreArchivo_ree      = '';
LET dFechahoy_sys           = today;
LET c_canal_actual          = '';
LET c_canal_temp            = '';
LET iNumProds               = 0;
LET iNumProds_pent          = 0;
LET iNumProds_siga          = 0; 
LET iNumProds_test          = 0;
LET iCuentaPP               = 0;
LET cComprimirArch          = '';
-----------------------Descripcion de Errores controlados----------------------------
--104001	Es necesario proporcionar todos los parametros de ejecucion                     
--104002	La empresa proporcionada es invalida                                            
--104003	El tipo de campana indicado no existe                                           
--104004	No se encuentra el parametros con el caracter de separador de archivo            
--104005	No se encuentra la ruta para almacenar el archivo                               
--104006	No se encuentra el parametros para nombrar el archivo                            
--104007	Es necesario proporcionar la empresa                                            
--104008	Es necesario indicar la fecha a consultar                                       
--104009	No se encontraron clientes marcados como excluidos                              
-------------------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, error_info
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = error_info;

				--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		-- DIRECTIVA PARA TENER LECTURA DE TABLAS AUNQUE ESTEN BLOQUEADAS
		SET ISOLATION TO DIRTY READ;
		-- DIRECTIVA PARA QUE EXISTA UNA ESPERA DE TRES SEGUNDOS AL ACCESO 
		SET LOCK MODE TO WAIT 3;

		--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"01") INTO cCodRetIB;

		--SET DEBUG FILE TO "/ifxsif01/macf/sp_ctbcpl_gen_arctelefonos_pred.trc";
		--TRACE ON;

		-- VALIDA LOS PARAMETROS DE ENTRADA   
		IF 	NVL(pEmpresa,'') = '' OR ( NVL(pTipoCobranza,'') = '' OR  NVL(pTipoCobranza,'') NOT IN ('A','P','R','E','X','Y')) 
			OR NVL(pFechaGenCartera,'')= '' OR NVL(pStatusTel,'') = '' THEN

			LET cCodRet = '104001';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen       = 3
			AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

			RETURN cCodRet;
		END IF

		LET vnumparametro = 56;

		SELECT empresa INTO cEmpresa
		FROM bdinteg: "informix".si_empresas
		WHERE empresa= pEmpresa;

		IF NVL(cEmpresa,'') = '' THEN
			LET cCodRet = '104002';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen       = 3
			AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ''; END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

			RETURN cCodRet;
		END IF;

		-- OBTIENE EL CARACTER SEPARADOR
		SELECT valor_alfabetico INTO cDelimitador
		FROM "informix".cb_param_campania 
		WHERE empresa       = pEmpresa 
		AND tipo_campania   = 1 
		AND grupo_parametro = "ARCHIVOS" 
		AND num_parametro   = 2;

		-- VALIDA QUE EXISTA EL CARACTER
		IF NVL(cDelimitador,'') = '' THEN
			LET cCodRet = '104004';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen       = 3
			AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ''; END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

			RETURN cCodRet;
		END IF;

		-- OBTIENE LA RUTA DESTINO DEL ARCHIVO
		SELECT valor_alfabetico INTO cRuta
		FROM "informix".cb_param_campania 
		WHERE empresa = pEmpresa
		AND tipo_campania   = 1 
		AND grupo_parametro = "ARCHIVOS" 
		AND num_parametro   = 3;

		--LET cRuta = '/RESPALDOS/Carlos/';
        --LET dFechahoy_sys = mdy(01,03,2020);   --- SOLO TEST MACF
		
		-- VALIDA QUE EXISTA LA CARPETA
		IF NVL(cRuta,'') = '' THEN
			LET cCodRet = '104005';

			SELECT descripcion INTO cMensaje
			FROM "informix".cb_errores
			WHERE origen       = 3
			AND codigo_error = cCodRet; 

			IF cMensaje IS NULL THEN LET cMensaje = ''; END IF;

			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

			RETURN cCodRet;
		END IF;

		LET pFechaGenCartera = DATE(1);

		IF ptipocobranza = 'A' THEN
		
		    --Nueva parte pq antes solo generaba 6001, poner esto para 8100 tambiï¿½n
			/* IF day(dt_FechaCorte) = 19 THEN
			    let v_num_producto = '8100';
				--let pfechacorte = pfechacorte - 1 units day;
		     ELIF day(dt_FechaCorte) = 21 THEN
			    let v_num_producto = '6001';
				--let pfechacorte = pfechacorte - 1 units day;
		     END IF;
		    */
			
			SELECT MAX(fecha_insert) INTO pFechaGenCartera
			FROM "informix".cb_cat_directorio_cte
			WHERE empresa = pEmpresa
			  --AND num_producto = v_num_producto
			AND tipo_cobranza = ptipocobranza;

			LET vday = DAY(pFechaGenCartera);

			FOREACH WITH HOLD
				SELECT valor_alfabetico INTO vnum_prod
				FROM "informix".cb_param_campania 
				WHERE empresa = pEmpresa AND tipo_campania = 61
				AND grupo_parametro = ptipocobranza
				AND valor_numerico = vday

				IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

				SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = pEmpresa AND valor = vnum_prod;

				IF vbandera IS NULL THEN LET vbandera = ''; END IF;

				IF vbandera = 'S' THEN
					LET vContTrab = vContTrab + 1;
				END IF;
			END FOREACH;

			IF vContTrab = 0 THEN
				RETURN cCodRet;
			END IF;
		END IF;

		IF ptipocobranza = 'X' OR ptipocobranza = 'Y' THEN
			IF ptipocobranza = 'X' THEN LET ptipocobranza = 'A'; ELSE LET ptipocobranza = 'R'; END IF;

			   IF  ptipocobranza = 'A'  THEN
			   
			       /*IF day(dt_FechaCorte) = 19 THEN
					let v_num_producto = '8100';
				   ELIF day(dt_FechaCorte) = 21 THEN
					let v_num_producto = '6001';
				   END IF;
			       */

				   -- SE OBTIENE LA FECHA MAXIMA SEGUN EL TIPO DE COBRANZA
					SELECT MAX(fecha_insert) INTO pFechaGenCartera
					FROM "informix".cb_cat_directorio_cte
					WHERE empresa = pEmpresa
					  --AND num_producto = v_num_producto  --MACF
					 AND tipo_cobranza = ptipocobranza;

					--LET pFechaGenCartera = mdy(04,18,2017);

					LET vday = DAY(pFechaGenCartera);				
					
					
					--IF (DAY(TODAY) <> 21) AND (ptipocobranza = "A") THEN
					IF ( (DAY(dFechahoy_sys) <> 21) AND (DAY(dFechahoy_sys) <> 19) )AND (ptipocobranza = "A") THEN
						LET cCodRet = '000000';
						RETURN cCodRet;
					END IF;
                    
					
					IF vday = 18 THEN
					   let v_num_producto = '8100';
					   --let pfechacorte = pfechacorte - 1 units day;
				    ELIF vday = 20 THEN
					   let v_num_producto = '6001';
					   --let pfechacorte = pfechacorte - 1 units day;
				    END IF;
					
					
					IF NVL(pFechaGenCartera,"") = "" THEN
						LET cCodRet     = "104008";
						SELECT descripcion
						INTO cMensaje
						FROM bdicobranza:"informix".cb_errores
						WHERE origen       = 3
						AND codigo_error = cCodRet; 

						IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

						--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

						RETURN cCodRet;
					END IF;

					--*--
					--GENERACION DE ARCHIVOS PARA TDC,PP,REE AGENCIA EXTERNA
					FOREACH WITH HOLD
					
						SELECT canal, tipo_producto, num_producto INTO c_canal, c_tipo_producto, cNumProd --c_num_producto_2 
						  FROM bdicobranza:cb_gestion_cobranza_agex
						 WHERE tipo_cobranza = ptipocobranza
						   AND activo = '1' 
						   AND num_producto = v_num_producto
					
						--SE OBTIENE EL NUMERO DEL PRODUCTO
						/*SELECT DISTINCT num_producto 
						INTO cNumProd
						FROM "informix".cb_cat_directorio_cte 
						WHERE empresa = '001'
						AND tipo_cobranza = ptipocobranza
						AND fecha_insert = pFechaGenCartera
						AND canal = "PENT"
						ORDER BY 1
						*/
						
						--IF ptipocobranza = "A" THEN
							IF cNumProd = "6001" THEN
								LET vnumparametro = 56; --TDC
							ELIF cNumProd = "8100" THEN
								LET vnumparametro = 73; --TDCO
							ELSE
								CONTINUE FOREACH;
							END IF;
						/*ELSE
							IF cNumProd = "6300" OR cNumProd = "7600" OR cNumProd = "7700" OR cNumProd = "6800" THEN
								LET vnumparametro = 58; --PP
							ELIF cNumProd = "6011" THEN
								LET vnumparametro = 57; --REE
							ELSE
								CONTINUE FOREACH;
							END IF;
						END IF;
                        */  
						-- OBTIENE EL NOMBRE DEL ARCHIVO
						SELECT valor_alfabetico INTO cNomArchivo
						FROM "informix".cb_param_campania 
						WHERE empresa         = pEmpresa 
						AND tipo_campania   = 1
						AND grupo_parametro = "ARCHIVOS" 
						AND num_parametro   = vnumparametro;

						-- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
						IF NVL(cNomArchivo,'') = '' THEN
							LET cCodRet = '104006';

							SELECT descripcion INTO cMensaje
							FROM "informix".cb_errores
							WHERE origen       = 3
							AND codigo_error = cCodRet; 

							IF cMensaje IS NULL THEN LET cMensaje = '' ; END IF;

							--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

							RETURN cCodRet;
						END IF
						
						LET cFechaGenArchivo = TRIM(LPAD(DAY(pFechaGenCartera),2,'0') || LPAD(MONTH(pFechaGenCartera),2,'0') || YEAR(pFechaGenCartera));

						IF c_canal = 'PENT' THEN
						   LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'_AE.txt';
						   LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '_AE.txt';
						ELSE
						   LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'_' || c_canal || '.txt';
						   LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '_' || c_canal || '.txt';
						END IF;

						LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";
						LET cSQL2 = "SELECT TO_CHAR(dir.fecha_insert,'%d/%m/%Y'), dir.numcte , substr(tel.telefono,length(tel.telefono)-9,10) telefono, "
							|| "tel.tipo_tel "
							|| "FROM bdicobranza:cb_cat_directorio_cte dir "
							|| "INNER JOIN bdinteg:si_telefonos_actual tel on dir.numcte = tel.numcte AND tel.tipo_tel in (1,2,3) AND tel.cofetel = 'V' "
							|| "LEFT OUTER JOIN bdinteg: si_bitsmstels bits on  bits.numcte  = tel.numcte AND bits.telefono = tel.telefono "
							|| " AND bits.fecha in (select max(bits2.fecha) from bdinteg:si_bitsmstels bits2 where bits.numcte = bits2.numcte and bits.telefono = bits2.telefono) "   
							|| "WHERE dir.tipo_cobranza = '" || pTipoCobranza || "' "
							
							|| "AND (dir.fecha_insert = '" || pFechaGenCartera || "' OR dir.fecha_reasignacion = '" || pFechaGenCartera || "') "
							|| "AND (dir.status_cliente NOT IN ('NT', 'EX') OR dir.fecha_reasignacion = '" || pFechaGenCartera || "') "

							|| "AND dir.canal = '" || c_canal || "' "
							|| "AND dir.num_producto = '" || cNumProd || "'";

						LET cSQL3 = ' " > '|| TRIM(cRuta) || 'arctele_pred_qry_AE.sql';
					
						LET cSQL1 = TRIM(cSQL1);
						LET cSQL3 = TRIM(cSQL3);
						LET cSQL = cSQL1 || TRIM(cSQL2) || cSQL3;

						-- Verifica que no este vacia la consulta.
						IF ( cSQL <> '' ) THEN 
							SYSTEM cSQL;
							--Permiso para la creacion de archivo.
							LET cSQL = '' ;
							LET cSQL = 'chmod 777 ' || TRIM(cRuta) || "arctele_pred_qry_AE.sql" ;
							LET cSQL = '' ;
							LET cSql = "dbaccess bdicobranza "|| TRIM(cRuta) || "arctele_pred_qry_AE.sql";
							SYSTEM TRIM(cSql);

							LET cSql = cSql;
							LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
							SYSTEM cSql;
						
							--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
							LET cSql = '';
							LET cSQL = "rm "||TRIM(cRuta)||'arctele_pred_qry_AE.sql';		
							SYSTEM TRIM(cSql); 

							LET cSQL = '' ;
							LET cSQL = 'rm ' || TRIM(cruta) || cNomArchivoAux;
							SYSTEM cSQL; 
							
							LET cSql = '';
					        LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
					        SYSTEM cSql;
 
					        LET cSql = '';
					        LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
					        SYSTEM cSql;
							
						END IF;	
					END FOREACH;

					/*LET cSql = '';
					LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
					SYSTEM cSql;

					LET cSql = '';
					LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
					SYSTEM cSql;*/

					RETURN cCodRet;
			
			ELSE 
			    --------<<<<<  TIPO COB R  AGEX
			    -- SE OBTIENE LA FECHA MAXIMA SEGUN EL TIPO DE COBRANZA
					SELECT MAX(fecha_insert) INTO pFechaGenCartera
					FROM "informix".cb_cat_directorio_cte
					WHERE empresa = pEmpresa
					AND tipo_cobranza = ptipocobranza;
				
                   --LET pFechaGenCartera = MDY(9,3,2020); --- USADO SOLO TEST MACF
				   LET vday = DAY(pFechaGenCartera);				
				
				-- Contar cuantos archivos para cada agencia
				FOREACH WITH HOLD
					SELECT canal, count(*) INTO c_canal_temp, iNumProds
					  FROM bdicobranza:cb_gestion_cobranza_agex
					 WHERE tipo_producto = 'PP' 
					 group by 1 order by 1
				
				    IF c_canal_temp = 'PENT' THEN
					   LET iNumProds_pent = iNumProds;
				    ELIF c_canal_temp = 'SIGA' THEN    
                       LET iNumProds_siga = iNumProds; 
					ELIF c_canal_temp = 'TEST' THEN
					   LET iNumProds_test = iNumProds;
				    END IF;
				END FOREACH;
				
				LET iCuentaPP = 0;
				--GENERACION DE ARCHIVOS PARA TDC,PP,REE AGENCIA EXTERNA
				FOREACH WITH HOLD
				
					SELECT canal, tipo_producto, num_producto INTO c_canal, c_tipo_producto, cNumProd --c_num_producto_2 
					  FROM bdicobranza:cb_gestion_cobranza_agex
					 WHERE tipo_cobranza = ptipocobranza
					   AND num_producto <> ''
					   AND activo = '1' 
					   order by canal, num_producto
	   
				
					--SE OBTIENE EL NUMERO DEL PRODUCTO
					/*SELECT DISTINCT num_producto 
					INTO cNumProd
					FROM "informix".cb_cat_directorio_cte 
					WHERE empresa = '001'
					AND tipo_cobranza = ptipocobranza
					AND fecha_insert = pFechaGenCartera
					AND canal = "PENT"
					ORDER BY 1
					*/
					
					/*IF ptipocobranza = "A" THEN
						IF cNumProd = "6001" THEN
							LET vnumparametro = 56; --TDC
						ELIF cNumProd = "8100" THEN
							LET vnumparametro = 73; --TDCO
						ELSE
							CONTINUE FOREACH;
						END IF;
					ELSE*/
									
					IF cNumProd = "6300" OR cNumProd = "7600" OR cNumProd = "7700" OR cNumProd = "6800" THEN
						LET vnumparametro = 58; --PP
						LET iCuentaPP = iCuentaPP +1;
					ELIF cNumProd = "6011" THEN
						IF vday NOT IN(3,18) THEN
						   CONTINUE FOREACH;
						ELSE
						   LET vnumparametro = 57; --REE
						   LET bandera_ree = "S";
						   
						END IF;
					ELSE
						CONTINUE FOREACH;
					END IF;
					--END IF;

					-- OBTIENE EL NOMBRE DEL ARCHIVO
					SELECT valor_alfabetico INTO cNomArchivo
					FROM "informix".cb_param_campania 
					WHERE empresa         = pEmpresa 
					AND tipo_campania   = 1
					AND grupo_parametro = "ARCHIVOS" 
					AND num_parametro   = vnumparametro;

					-- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
					IF NVL(cNomArchivo,'') = '' THEN
						LET cCodRet = '104006';

						SELECT descripcion INTO cMensaje
						FROM "informix".cb_errores
						WHERE origen       = 3
						AND codigo_error = cCodRet; 

						IF cMensaje IS NULL THEN LET cMensaje = '' ; END IF;

						--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

						RETURN cCodRet;
					END IF

										
					LET cFechaGenArchivo = TRIM(LPAD(DAY(pFechaGenCartera),2,'0') || LPAD(MONTH(pFechaGenCartera),2,'0') || YEAR(pFechaGenCartera));
					IF c_canal = 'PENT' THEN
					    LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'_AE.txt';
					    LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '_AE.txt';
					ELSE
                        LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'_' || c_canal || '.txt';
					    LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '_' ||  c_canal ||  '.txt';
                    END IF;					

					IF bandera_ree = "S" and vnumparametro = 57 THEN
					   LET cNombreArchivo_ree = cNomArchivo;
					END IF;
					
					LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";
					LET cSQL2 = "SELECT TO_CHAR(dir.fecha_insert,'%d/%m/%Y'), dir.numcte , substr(tel.telefono,length(tel.telefono)-9,10) telefono, "
						|| "tel.tipo_tel "
						|| "FROM bdicobranza:cb_cat_directorio_cte dir "
						|| "INNER JOIN bdinteg:si_telefonos_actual tel on dir.numcte = tel.numcte AND tel.tipo_tel in (1,2,3) AND tel.cofetel = 'V' "
						|| "LEFT OUTER JOIN bdinteg: si_bitsmstels bits on  bits.numcte  = tel.numcte AND bits.telefono = tel.telefono "
						|| " AND bits.fecha in (select max(bits2.fecha) from bdinteg:si_bitsmstels bits2 where bits.numcte = bits2.numcte and bits.telefono = bits2.telefono) "   
						|| "WHERE dir.tipo_cobranza = '" || pTipoCobranza || "' "
						|| "AND (dir.fecha_insert = '" || pFechaGenCartera || "' OR dir.fecha_reasignacion = '" || pFechaGenCartera || "') "
						|| "AND (dir.status_cliente NOT IN ('NT', 'EX') OR dir.fecha_reasignacion = '" || pFechaGenCartera || "') "
						|| "AND dir.canal = '" || c_canal || "' "
						|| "AND dir.num_producto = '" || cNumProd || "'";

					LET cSQL3 = ' " > '|| TRIM(cRuta) || 'arctele_pred_qry_AE.sql';
				
					LET cSQL1 = TRIM(cSQL1);
					LET cSQL3 = TRIM(cSQL3);
					LET cSQL = cSQL1 || TRIM(cSQL2) || cSQL3;

					-- Verifica que no este vacia la consulta.
					IF ( cSQL <> '' ) THEN 
						SYSTEM cSQL;
						--Permiso para la creacion de archivo.
						LET cSQL = '' ;
						LET cSQL = 'chmod 777 ' || TRIM(cRuta) || "arctele_pred_qry_AE.sql" ;
						LET cSQL = '' ;
						LET cSql = "dbaccess bdicobranza "|| TRIM(cRuta) || "arctele_pred_qry_AE.sql";
						SYSTEM TRIM(cSql);

						LET cSql = cSql;
						LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
						SYSTEM cSql;

						/*IF cNumProd = '6011' THEN
							LET cSql = '';
							LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
							SYSTEM cSql;

							LET cSql = '';
							LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
							SYSTEM cSql;
						END IF;
                        */
						--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
						LET cSql = '';
						LET cSQL = "rm "||TRIM(cRuta)||'arctele_pred_qry_AE.sql';		
						SYSTEM TRIM(cSql); 

						LET cSQL = '' ;
						LET cSQL = 'rm ' || TRIM(cruta) || cNomArchivoAux;
						SYSTEM cSQL;

						IF bandera_ree = 'S' THEN
							LET cSql = '';
							LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNombreArchivo_ree);
							SYSTEM cSql;
							LET bandera_ree = 'N';
							
							LET cSql = '';
						    LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNombreArchivo_ree)||".gz";
						    SYSTEM cSql;						
						ELSE
						    -- Validar si el canal no cambia aÃºn  20200916
							IF c_canal = 'PENT' and  c_tipo_producto = 'PP' THEN
							   IF iCuentaPP = iNumProds_pent THEN
							      LET cComprimirArch = 'S';
							   END IF;
							ELIF c_canal = 'SIGA' and  c_tipo_producto = 'PP' THEN
							   IF iCuentaPP = iNumProds_siga THEN
							      LET cComprimirArch = 'S';
							   END IF;
							ELIF c_canal = 'TEST' and  c_tipo_producto = 'PP' THEN
							   IF iCuentaPP = iNumProds_test THEN
							      LET cComprimirArch = 'S';
							   END IF;
							END IF
						
						
						    IF cComprimirArch = 'S' THEN
								LET cSql = '';
								LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
								SYSTEM cSql;
							
								LET cSql = '';
								LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
								SYSTEM cSql;	
								LET cComprimirArch = 'N';
								LET iCuentaPP = 0;
							END IF;
						END IF;		
					
						
					END IF;	
				END FOREACH;

				/*LET cSql = '';
				LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
				SYSTEM cSql;

				LET cSql = '';
				LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
				SYSTEM cSql;

				IF bandera_ree = 'S' THEN
				   LET cSql = '';
				   LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNombreArchivo_ree);
				   SYSTEM cSql;
				   LET bandera_ree = 'N';
				END IF;
				*/
				RETURN cCodRet;
			
			    --------------- TIPO COB R AGEX ---- >>>>
				
			END IF;
		 ELSE
			
			/* mi 1a modif
			IF ptipocobranza = 'A' THEN
				-- SE OBTIENE LA FECHA MAXIMA SEGUN EL TIPO DE COBRANZA
				SELECT MAX(fecha_insert) INTO pFechaGenCartera
				FROM "informix".cb_cat_directorio_cte
				WHERE empresa = pEmpresa
				AND num_producto = v_num_producto
				AND tipo_cobranza = ptipocobranza;
			ELIF ptipocobranza = 'R' THEN
			    SELECT MAX(fecha_insert) INTO pFechaGenCartera
				FROM "informix".cb_cat_directorio_cte
				WHERE empresa = pEmpresa
				AND tipo_cobranza = ptipocobranza;
            END IF; 			
            */
			
			-- SE OBTIENE LA FECHA MAXIMA SEGUN EL TIPO DE COBRANZA
			SELECT MAX(fecha_insert) INTO pFechaGenCartera
			FROM "informix".cb_cat_directorio_cte
			WHERE empresa = pEmpresa
			AND tipo_cobranza = ptipocobranza;
			
			--LET pFechaGenCartera = mdy(11,02,2019); -- SOLO TEST MACF

			IF NVL(pFechaGenCartera,"") = "" THEN
				LET cCodRet     = "104008";
				SELECT descripcion
				INTO cMensaje
				FROM bdicobranza:"informix".cb_errores
				WHERE origen       = 3
				AND codigo_error = cCodRet; 

				IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

				--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

				RETURN cCodRet;
			END IF;

			--*--
			--GENERACION DE ARCHIVOS PARA TDC,PP,REE CAT
			FOREACH WITH HOLD
				--SE OBTIENE EL NUMERO DEL PRODUCTO
				SELECT DISTINCT num_producto 
				INTO cNumProd
				FROM "informix".cb_cat_directorio_cte 
				WHERE empresa = '001'
				AND tipo_cobranza = ptipocobranza
				AND fecha_insert = pFechaGenCartera
				AND canal = ""
				ORDER BY 1
				--AND num_producto != '6400'

	/*			WHERE empresa = pEmpresa
				AND tipo_cobranza = ptipocobranza
				AND fecha_insert = fecha_insert 
				AND num_credito = num_credito*/

				IF ptipocobranza = "A" OR ptipocobranza = "P" THEN
					IF cNumProd = "8100" OR cNumProd = "8500" THEN
						LET vnumparametro = 73; --TCO
					ELIF cNumProd = "6001" THEN
						LET vnumparametro = 56; --TDC
					ELSE
						CONTINUE FOREACH;
					END IF;
				ELSE
					IF cNumProd = "6300" OR cNumProd = "6400" OR cNumProd = "7600" OR cNumProd = "7700" OR cNumProd = "6800" THEN
						LET vnumparametro = 58; --PP
	/*				ELSE
						LET vnumparametro = 57; --REE
					END IF*/
					ELIF cNumProd = "6011" THEN
						LET vnumparametro = 57; --REE
					ELSE
						CONTINUE FOREACH;
					END IF
				END IF;

				-- OBTIENE EL NOMBRE DEL ARCHIVO
				SELECT valor_alfabetico INTO cNomArchivo
				FROM "informix".cb_param_campania 
				WHERE empresa         = pEmpresa 
				AND tipo_campania   = 1
				AND grupo_parametro = "ARCHIVOS" 
				AND num_parametro   = vnumparametro;

				-- VALIDA QUE EXISTA EL NOMBRE DEL ARCHIVO
				IF NVL(cNomArchivo,'') = '' THEN
					LET cCodRet = '104006';

					SELECT descripcion INTO cMensaje
					FROM "informix".cb_errores
					WHERE origen       = 3
					AND codigo_error = cCodRet; 

					IF cMensaje IS NULL THEN LET cMensaje = '' ; END IF;

					--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"02") INTO cCodRetIB;

					RETURN cCodRet;
				END IF

				LET cFechaGenArchivo = TRIM(LPAD(DAY(pFechaGenCartera),2,'0') || LPAD(MONTH(pFechaGenCartera),2,'0') || YEAR(pFechaGenCartera));
				LET cNomArchivoAux = TRIM(cNomArchivo) || cFechaGenArchivo || '_aux_' || pTipoCobranza ||'.txt';
				LET cNomArchivo = TRIM(cNomArchivo) || cFechaGenArchivo || '.txt';

				LET cSQL1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNomArchivoAux) || " DELIMITER '" || cDelimitador || "' ";
				LET cSQL2 = "SELECT dir.numcte ,tel.tipo_tel,substr(tel.telefono,length(tel.telefono)-9,10),decode(tel.tipo_tel,1,'F',2,'M','M'),tel.carrier,"
					|| "DECODE(bits.bandera,'T','S','F','N','N') "
					|| "FROM bdicobranza:cb_cat_directorio_cte dir "
					|| "INNER JOIN bdinteg:si_telefonos_actual tel on dir.numcte = tel.numcte AND tel.tipo_tel in (1,2,3) AND tel.cofetel = 'V' "
					|| "LEFT OUTER JOIN bdinteg: si_bitsmstels bits on  bits.numcte  = tel.numcte AND bits.telefono = tel.telefono "
					--|| "	AND bits.rowid in (select max(bits2.rowid) from bdinteg:si_bitsmstels bits2 where bits.numcte = bits2.numcte and bits.telefono = bits2.telefono) "
					|| " AND bits.fecha in (select max(bits2.fecha) from bdinteg:si_bitsmstels bits2 where bits.numcte = bits2.numcte and bits.telefono = bits2.telefono) "   
					|| "WHERE dir.tipo_cobranza = '" || pTipoCobranza || "' "
					|| "AND dir.fecha_insert = '" || pFechaGenCartera || "' "
					--|| "AND dir.tipo_logica > 0 "
					|| "AND dir.status_cliente NOT IN ('NT', 'EX') "
					|| "AND dir.canal = ''"
					|| "AND dir.num_producto = '" || cNumProd || "'";

				LET cSQL3 = ' " > '|| TRIM(cRuta) || 'arctele_pred_qry.sql';
			
				LET cSQL1 = TRIM(cSQL1);
				LET cSQL3 = TRIM(cSQL3);
				LET cSQL = cSQL1 || TRIM(cSQL2) || cSQL3;

				-- Verifica que no este vacia la consulta.
				IF ( cSQL <> '' ) THEN 
					SYSTEM cSQL;
					--Permiso para la creacion de archivo.
					LET cSQL = '' ;
					LET cSQL = 'chmod 777 ' || TRIM(cRuta) || "arctele_pred_qry.sql" ;
					LET cSQL = '' ;
					LET cSql = "dbaccess bdicobranza "|| TRIM(cRuta) || "arctele_pred_qry.sql";
					SYSTEM TRIM(cSql);

					LET cSql = cSql;
					LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNomArchivoAux) || " >> " || TRIM(cRuta) || TRIM(cNomArchivo);
					SYSTEM cSql;

					IF cNumProd = '6011' THEN
						LET cSql = '';
						LET cSql = "wc -l "|| TRIM(cRuta) || TRIM(cNomArchivo) || ' > '  || TRIM(cRuta) ||'CC_'||TRIM(cNomArchivo);
						SYSTEM cSql;

						LET cSql = '';
						LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
						SYSTEM cSql;

						LET cSql = '';
						LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
						SYSTEM cSql;
					END IF;

					--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
					LET cSql = '';
					LET cSQL = "rm "||TRIM(cRuta)||'arctele_pred_qry.sql';		
					SYSTEM TRIM(cSql); 

					LET cSQL = '' ;
					LET cSQL = 'rm ' || TRIM(cruta) || cNomArchivoAux;
					SYSTEM cSQL; 
				END IF;	
			END FOREACH;

			--GENERACION DE ACHIVO DE CIFRAS DE CONTROL
			LET cSql = '';
			LET cSql = "wc -l "|| TRIM(cRuta) || TRIM(cNomArchivo) || ' > '  || TRIM(cRuta) ||'CC_'||TRIM(cNomArchivo);
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = "gzip -f " || TRIM(cRuta) || TRIM(cNomArchivo);
			SYSTEM cSql;

			LET cSql = '';
			LET cSql = "chmod 777 " || TRIM(cRuta) || TRIM(cNomArchivo)||".gz";
			SYSTEM cSql;

			--*--
			--EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,vproceso,cCodRet,cMensaje,"03") INTO cCodRetIB;

			RETURN cCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'MODIFICACION: ISARAI BOJORQUEZ',
'FECHA: 2015/06/24',
'DESCRIPCION: SE CREA PROCEDIMIENTO PARA LA GENERACION DE ARCHIVOS CATTELEFONOS',
'BD: BDIcOBRANZA',
'VERSION:20150624.1500',
'Modif.: MACF 20191031',
'Desc.: Para corregir Error -268 debido a uso de rowid en si_bitsmstels';

CREATE PROCEDURE "informix".sp_depura_tbls_eval_objetiva(pTipoEjec char(1), pFechaIni date, pFechaFin date)

RETURNING CHAR(6), char(80);
  -- vers 1.0.0 20190901
  DEFINE vcCodRet CHAR(5);
  DEFINE viSqlErr INTEGER;
  define vDataErr	      varchar(64);
  DEFINE vcEsTransaccion  CHAR(1);
  define iSqlErr	      integer;
  define iSamErr	      integer;
  define cCodRet	      char(6);
  define dtFecha	      date;
  define cMensaje         char(120);
  define vEmpresa         char(3);
  define vFechahoy        date;
  define cNumCte          char(20);	 
  define cProceso         char(4);
  define cCod_ret_2       char(6);	 
  define iContGral        integer;
  define iContGral_2      integer;
  define vNum_credito     char(20);
  define dImporteConvenio decimal(18,2);
  define dtHora_insert    DATETIME HOUR to FRACTION(3);
  define dtFecha_convenio date;
  define cSucursal_pago   char(4);
  define cSucursal_pago_2 char(4);
  define vNum_credito_2   char(20);
  define iNum_pm_realizados    integer;
  define iNum_pm_no_realizados integer;
  define cCalificacion         char(1);
  define dTotal_importe        decimal(18,2);
  define dImp_pagado_acum      decimal(18,2); 
  define dFecha_vencim    date;
  
  define vPlazo           char(2);
  define iCteAsisteSuc    integer;
  define cOrigen          char(10);
  define pSucursalOrig    char(4);
  define psucursal        char(4);
  define pfechasistema    date;
  define pefectuo_compac  integer;
  define pnombre_efectuo  char(40);
  define pnumcuenta       char(20);
  define pnumproducto		char(4); 
  define pplazo           char(2);
  define porigen	        smallint;
  define ptipo_compac     char(1);
  define pimporte         decimal(18,2);
  define dImp_pagado      decimal(18,2);
  define cUsuario_pago    char(8);
  define cNomUsuario_pago char(45);
  
  define dtFecha_hoy      date;
  define dt_pri_dia_mes   date;
  define dt_ult_dia_mes   date;  
  define dtFecha_ini      date;
  define dtFecha_fin      date;
  define dtFecha_insert   date;
  define iNumConvenios    integer;
  define cReinicio		  char(1);
  define cMensajeRet	  char(80);
  define iCuentasEliminadas     integer; 
  define iCuentasIns_crd        integer;
  define iCuentasEliminadas_crd integer;
  define dMonto_pagomin         decimal(18,2);
  define dMonto_recup_pm        decimal(18,2); 
  define dMonto_saldo_vencido   decimal(18,2); 
  define dMonto_recup_sv        decimal(18,2);
  define iNum_sv_realizados     integer;
  define iNum_sv_no_realizados  integer;
  define iCuentasIns_evalobj_nvahis  integer;
  define iCuentasIns_evalobj_crd     integer;
  define iCuentasEliminadas_evalobj_nvahis integer;
  define iCuentasEliminadas_evalobj_crd    integer;
  define cTipoEjec      char(1);
  
  define dPct_cump_pm     decimal(8,2);   
  define dPct_cump_sv     decimal(8,2);
  define cEfectuo_compac  char(8);
  
  define dFecha_ctetit    date;    -- Para depurar cb_cob_vent_cliente_titular
  define cSucursal_ctetit char(4);
  define cEmpleado_ctetit char(8);
  define iCont_si         integer;
  define iCont_no         integer;
  
  define dtFecha_ini_mes_ant      date;
  define dtFecha_fin_mes_ant      date;
  define iCuentasIns_ctetit        integer; 
  define iCuentasEliminadas_ctetit integer;
  define iCuentasEliminadas_ctetit_his integer;
  define iRegsABorrar    integer;
  define dtFecha_ini_mes_ant_2m      date;
  define dtFecha_fin_mes_ant_2m      date;
  define iCuentasEliminadas_ctetit_operativa integer;
    
  let cCodRet	        = "000000";
  let dtFecha           = date(1);
  let cMensaje          = 'PROCESO EXITOSO';	  
  let vEmpresa          = '001';
  let vFechahoy         = date(1);
  let cNumCte           = '';
  let cProceso          = '0088';
  let cCod_ret_2        = '';
  let iContGral         = 0;
  let iContGral_2       = 0;
  let vNum_credito      = '';
  let dImporteConvenio  = 0;
  let dtHora_insert     = CURRENT;
  let dtFecha_convenio  = date(1);
  let cSucursal_pago    = ''; 
  let cSucursal_pago_2  = '';
  let vNum_credito_2    = '';
  let iNum_pm_realizados = 0;
  let iNum_pm_no_realizados = 0;
  let cCalificacion      = '';
  let dTotal_importe     = 0;

  let iCteAsisteSuc    = 0;
  let cOrigen          = '';
  let pSucursalOrig    = '';
  let psucursal        = ''; 
  let pfechasistema    = date(1); 
  let pefectuo_compac  = 0;
  let pnombre_efectuo  = '';
  let pnumcuenta       = '';
  let pnumproducto     = '';
  let pplazo           = '';
  let porigen          = 0;
  let ptipo_compac     = '';
  let pimporte         = 0;  
  let dImp_pagado      = 0;
  let vPlazo           = '';
  let dImp_pagado_acum = 0;
  
  let vcCodRet  = '00000';
  let viSqlErr  = 0;
  let vDataErr	= '';
  let vcEsTransaccion = '';
  let dFecha_vencim = date(1);
  let cUsuario_pago = '';
  let cNomUsuario_pago = '';
  
  let dtFecha_hoy     = date(1); 
  let dt_pri_dia_mes  = date(1); 
  let dt_ult_dia_mes  = date(1);
  let dtFecha_ini     = date(1);
  let dtFecha_fin     = date(1);
  let dtFecha_insert  = date(1);
  let iNumConvenios   = 0;
  let cReinicio       = '';
  let iCuentasEliminadas = 0;
  let iCuentasIns_crd    = 0;
  let iCuentasEliminadas_crd = 0;
  let dMonto_pagomin     = 0;
  let dMonto_recup_pm    = 0;
  let dMonto_saldo_vencido  = 0; 
  let dMonto_recup_sv       = 0;
  let iNum_sv_realizados    = 0;
  let iNum_sv_no_realizados = 0;
  let iCuentasIns_evalobj_nvahis = 0;
  let iCuentasIns_evalobj_crd = 0;
  let iCuentasEliminadas_evalobj_nvahis = 0;
  let iCuentasEliminadas_evalobj_crd = 0;
  
  let cTipoEjec = pTipoEjec;
  let dPct_cump_pm  = 0;
  let dPct_cump_sv  = 0;
  let cEfectuo_compac = '';

  let dFecha_ctetit    = date(1);   
  let cSucursal_ctetit = ''; 
  let cEmpleado_ctetit = '';
  let iCont_si         = 0; 
  let iCont_no         = 0; 
  
  let dtFecha_ini_mes_ant = date(1);
  let dtFecha_fin_mes_ant = date(1);
  let iCuentasIns_ctetit  = 0;
  let iCuentasEliminadas_ctetit = 0; 
  let iCuentasEliminadas_ctetit_his = 0;
  let iRegsABorrar  = 0;
  let dtFecha_ini_mes_ant_2m = date(1);
  let dtFecha_fin_mes_ant_2m = date(1);
  let iCuentasEliminadas_ctetit_operativa = 0;
  let iCuentasEliminadas_ctetit_his = 0;
  
BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDataErr
        IF iSqlErr <> 0 THEN
            LET cCodRet=iSqlErr ;
			let cMensaje = trim(cCodRet) || ' ' || vNum_credito;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '02') RETURNING cCod_ret_2;
			 
            RETURN cCodRet, trim(cMensaje);
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/ifxsif01/macf/sp_depura_tbls_eval_objetiva.out";
	--TRACE ON;

	--CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
	CALL bdicobranza:sp_inserta_bitacora_cob(vEmpresa, cProceso, cCodRet, cMensaje, '01') RETURNING cCod_ret_2; 
   
    -- Se depurará cada mes lo del meses anterior
    -- correrá al cierre del día 1
	
	if cTipoEjec = 'A' then
	
		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes 
		  INTO dtFecha_hoy, dt_pri_dia_mes, dt_ult_dia_mes
		  FROM bdinteg:si_fechas
		 WHERE empresa = vEmpresa;
	   
         --LET dtFecha_hoy = MDY(11,2,2020);     -- SOLO TEST
		 --LET dt_pri_dia_mes = MDY(11,1,2020);  -- SOLO TEST
		 --LET dt_ult_dia_mes = MDY(11,30,2020); -- SOLO TEST
		 
		 let dtFecha_fin = date(dt_pri_dia_mes -1 units day);
		 let dtFecha_ini = month(dtFecha_fin)||'/01/'||year(dtFecha_fin);
		 		 
         let dtFecha_fin_mes_ant = date(dtFecha_ini -1 units day);
		 let dtFecha_ini_mes_ant = month(dtFecha_fin_mes_ant)||'/01/'||year(dtFecha_fin_mes_ant);
		 
		 let dtFecha_fin_mes_ant_2m = date(dtFecha_ini_mes_ant -1 units day);
		 let dtFecha_ini_mes_ant_2m = month(dtFecha_fin_mes_ant_2m)||'/01/'||year(dtFecha_fin_mes_ant_2m);
		 
    elif cTipoEjec = 'M' then
	     if (pFechaIni = '' or pFechaIni = '01/01/1900') or (pFechaFin = '' or pFechaFin = '01/01/1900') then
             LET cCodRet     = "000018";
		     LET cMensajeRet = "Error al obtener las fechas";
		     RETURN cCodRet, cMensajeRet;
	     else
	         let dtFecha_ini = pFechaIni;
             let dtFecha_fin = pFechaFin;
			 
			 let dtFecha_fin_mes_ant = date(dtFecha_ini -1 units day);
		     let dtFecha_ini_mes_ant = month(dtFecha_fin_mes_ant)||'/01/'||year(dtFecha_fin_mes_ant);
			 
		     let dtFecha_fin_mes_ant_2m = date(dtFecha_ini_mes_ant -1 units day);
		     let dtFecha_ini_mes_ant_2m = month(dtFecha_fin_mes_ant_2m)||'/01/'||year(dtFecha_fin_mes_ant_2m);
			 
	     end if; 
    end if;	

	--let dtFecha_hoy = mdy(9,2,2019);     -- SOLO TEST
	--let dt_pri_dia_mes = mdy(9,1,2019);   -- SOLO TEST
	--let dtFecha_fin = date(dt_pri_dia_mes -1 units day);              -- SOLO TEST
    --let dtFecha_ini = month(dtFecha_fin)||'/01/'||year(dtFecha_fin);  -- SOLO TEST
	

	
   SELECT valor INTO cReinicio FROM bdicobranza:cb_param WHERE empresa = vEmpresa AND cod_param = 6;

	IF NVL(cReinicio,"") = "" THEN
		LET cCodRet     = "000019";
		LET cMensajeRet = "Error al obtener el parametro de reinicio";
		RETURN cCodRet, cMensajeRet;
	END IF;
   
   IF cReinicio = '0' THEN
	   FOREACH WITH HOLD
		   SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.sucursal_convenio, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.plazo, a.origen, 
		          a.tipo_compac, a.convenio_monto, a.convenio_abono, a.cte_con_vencido, a.num_convenios, a.num_pm_realizados, a.num_pm_no_realizados, a.calificacion, 
				  a.fecha_compac, a.fecha_vencim
			 INTO vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, vPlazo, cOrigen, 
			 ptipo_compac, dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados,
				   cCalificacion, dtFecha_convenio, dFecha_vencim
			 FROM bdicobranza:cb_evaluacion_objetiva_convenios a
			 WHERE a.fecha_vencim between dtFecha_ini and dtFecha_fin
			   AND a.num_credito not in(select num_credito from cb_evaluacion_objetiva_convenios_his 
			                             where num_credito = a.num_credito and fecha_vencim = a.fecha_vencim)

	        
			begin work;
				INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_his(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, cajero, nom_cajero, 
							   num_producto, plazo,	origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
							   num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
																							 
				VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, vPlazo, cOrigen, ptipo_compac, 
					   dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, dtFecha_convenio, dFecha_vencim);
		
		        let iContGral_2 = iContGral_2 + 1;

				DELETE bdicobranza:cb_evaluacion_objetiva_convenios
                 WHERE num_credito = vNum_credito
                   AND fecha_vencim = dFecha_vencim; 
				   
		        LET iCuentasEliminadas = iCuentasEliminadas +1;
		         
			commit work; 
	   
		END FOREACH   
    
	    IF iContGral_2 > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj Convs: ' || iContGral_2;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a histórica: ' || iContGral_2;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj Convs: ' || iCuentasEliminadas;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	    END IF;     
	
	    let cReinicio = '1';
	    UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;

	END IF;
    		
   

    IF cReinicio = '1' THEN
      FOREACH WITH HOLD
		  
		  SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.sucursal_convenio, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.plazo, a.origen, 
		         a.tipo_compac, a.convenio_monto, a.convenio_abono, a.cte_con_vencido, a.num_convenios, a.num_pm_realizados, a.num_pm_no_realizados, a.calificacion, 
				 a.fecha_compac, a.fecha_vencim 
            INTO vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, vPlazo, cOrigen, 
			     ptipo_compac, dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, 
				 dtFecha_convenio, dFecha_vencim
			FROM bdicobranza:cb_evaluacion_objetiva_convenios_crd a
           WHERE fecha_vencim between dtFecha_ini and dtFecha_fin
			 AND a.num_credito not in(select num_credito from bdicobranza:cb_evaluacion_objetiva_convenios_crd_his 
			                          where num_credito = a.num_credito and fecha_vencim = a.fecha_vencim)   

		begin work;
			   INSERT INTO bdicobranza:cb_evaluacion_objetiva_convenios_crd_his(num_credito, sucursal_origen, sucursal_pago, sucursal_convenio, fecha_insert, cajero, nom_cajero, 
			                                                                num_producto, plazo, origen, tipo_compac, convenio_monto, convenio_abono, cte_con_vencido, 
																			num_convenios, num_pm_realizados, num_pm_no_realizados, calificacion, fecha_compac, fecha_vencim)
			                                                          
																	 
			 																 
			   VALUES (vNum_credito, pSucursalOrig, cSucursal_pago, psucursal, dtFecha_insert, pefectuo_compac, pnombre_efectuo,  pnumproducto, vPlazo, cOrigen, ptipo_compac, 
			           dImporteConvenio, dTotal_importe, iCteAsisteSuc, iNumConvenios, iNum_pm_realizados, iNum_pm_no_realizados, cCalificacion, dtFecha_convenio,dFecha_vencim);
        
				let iCuentasIns_crd = iCuentasIns_crd + 1;
		
				DELETE bdicobranza:cb_evaluacion_objetiva_convenios_crd
                 WHERE num_credito = vNum_credito
                   AND fecha_vencim = dFecha_vencim; 
				   
		        LET iCuentasEliminadas_crd = iCuentasEliminadas_crd +1;
		
		commit work;
		

 	  END FOREACH   
	  
	  IF iCuentasIns_crd > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj Convs CRD: ' || iCuentasIns_crd;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a histórica CRD: ' || iCuentasIns_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj Convs CRD: ' || iCuentasEliminadas_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	  END IF;     
	
	  let cReinicio = '2';
      UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;	  
	END IF;

		
	IF cReinicio = '2' THEN
		FOREACH WITH HOLD
	
			SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.monto_pago_minimo, a.monto_recup_pm, 
			       a.num_pm_realizados, a.num_pm_no_realizados, a.monto_saldo_vencido, a.monto_recup_sv, a.num_sv_realizados, a.num_sv_no_realizados, a.pct_cump_pm, a.pct_cump_sv
			  --INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			  INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			       iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, dPct_cump_pm, dPct_cump_sv
			  FROM bdicobranza:cb_evaluacion_objetiva_nueva a
			  WHERE a.num_credito >= '600000000001' and a.fecha_insert between dtFecha_ini and dtFecha_fin
               AND a.num_credito not in(select num_credito from bdicobranza:cb_evaluacion_objetiva_nueva_his 
			                             where num_credito = a.num_credito and fecha_insert = a.fecha_insert)
										 
			begin work;
				INSERT INTO bdicobranza:cb_evaluacion_objetiva_nueva_his(num_credito, sucursal_origen, sucursal_pago, fecha_insert, cajero, nom_cajero, num_producto, 
				       monto_pago_minimo, monto_recup_pm, num_pm_realizados, num_pm_no_realizados, monto_saldo_vencido, monto_recup_sv, num_sv_realizados, num_sv_no_realizados,
					   pct_cump_pm, pct_cump_sv)					   

				 --VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm,
				 VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm,
 			           iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, dPct_cump_pm, dPct_cump_sv); 
			
			    let iCuentasIns_evalobj_nvahis = iCuentasIns_evalobj_nvahis + 1;
			
	            DELETE bdicobranza:cb_evaluacion_objetiva_nueva
				 WHERE num_credito = vNum_credito
				   AND fecha_insert = dtFecha_insert;
	            
				let iCuentasEliminadas_evalobj_nvahis = iCuentasEliminadas_evalobj_nvahis + 1;
	
	        commit work;
					
		END FOREACH
		
		IF iCuentasIns_evalobj_nvahis > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj Nva: ' || iCuentasIns_evalobj_nvahis;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a Nva histórica: ' || iCuentasIns_evalobj_nvahis;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj Nva: ' || iCuentasEliminadas_evalobj_nvahis;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	    END IF;
		

	let cReinicio = '3';
    UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;	
	END IF;	

	
	IF cReinicio = '3' THEN
		FOREACH WITH HOLD
	
	         SELECT a.num_credito, a.sucursal_origen, a.sucursal_pago, a.fecha_insert, a.cajero, a.nom_cajero, a.num_producto, a.monto_pago_minimo, a.monto_recup_pm, 
			        a.num_pm_realizados, a.num_pm_no_realizados, a.monto_saldo_vencido, a.monto_recup_sv, a.num_sv_realizados, a.num_sv_no_realizados, a.pct_cump_pm, a.pct_cump_sv 
               --INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			   INTO vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			       iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, dPct_cump_pm, dPct_cump_sv
			   FROM bdicobranza:cb_evaluacion_objetiva_crd a
			   WHERE a.num_credito >= '600000000001' and a.fecha_insert between dtFecha_ini and dtFecha_fin
                 AND a.num_credito not in(select num_credito from bdicobranza:cb_evaluacion_objetiva_crd_his 
			                               where num_credito = a.num_credito and fecha_insert = a.fecha_insert)
	
	         begin work;
			    INSERT INTO bdicobranza:cb_evaluacion_objetiva_crd_his(num_credito, sucursal_origen, sucursal_pago, fecha_insert, cajero, nom_cajero, num_producto, 
				       monto_pago_minimo, monto_recup_pm, num_pm_realizados, num_pm_no_realizados, monto_saldo_vencido, monto_recup_sv, num_sv_realizados, num_sv_no_realizados,
					   pct_cump_pm, pct_cump_sv) 
	            --VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, pefectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
				VALUES(vNum_credito, pSucursalOrig, cSucursal_pago, dtFecha_insert, cEfectuo_compac, cNomUsuario_pago, pnumproducto, dMonto_pagomin, dMonto_recup_pm, 
			       iNum_pm_realizados, iNum_pm_no_realizados, dMonto_saldo_vencido, dMonto_recup_sv, iNum_sv_realizados, iNum_sv_no_realizados, 
				       dPct_cump_pm, dPct_cump_sv);   
		    
			    let iCuentasIns_evalobj_crd = iCuentasIns_evalobj_crd + 1;
				
  			    DELETE bdicobranza:cb_evaluacion_objetiva_crd
				 WHERE num_credito = vNum_credito
				   AND fecha_insert = dtFecha_insert;

                let iCuentasEliminadas_evalobj_crd = iCuentasEliminadas_evalobj_crd	+ 1;
				
			commit work;
		END FOREACH
		
		IF iCuentasIns_evalobj_crd > 0 THEN
	       LET cMensaje = 'TOTAL Ctas PROCS. Eval Obj CRD: ' || iCuentasIns_evalobj_crd;
	       LET cMensaje = TRIM(cMensaje) ||' - TOTAL Ctas INSERT a CRD histórica: ' || iCuentasIns_evalobj_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas ELIMINADAS Eval Obj CRD: ' || iCuentasEliminadas_evalobj_crd;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
	    END IF;
		
		let cReinicio = '4';
		UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;
	
			
	END IF;	
	
	-- dtFecha_fin = 01/10  dtFecha_ini= 31/10    dtFecha_fin_mes_ant= 30/09   dtFecha_ini_mes_ant= 01/09
	
	IF cReinicio = '4' THEN
        -- Ejem cuando corra en nov, dtFecha_hoy = 02/11, dt_pri_dia_mes= 01/11, dt_ult_dia_mes= 30/11  (bdinteg:si_fechas)
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, empleado, cont_si, cont_no 
			  INTO dFecha_ctetit, cSucursal_ctetit, cEmpleado_ctetit, iCont_si, iCont_no
			  FROM bdicobranza:cb_cob_vent_cliente_titular
	         WHERE fecha between dtFecha_ini_mes_ant and dtFecha_fin_mes_ant
			 
			 BEGIN WORK;
			    INSERT INTO bdicobranza:cb_cob_vent_cliente_titular_his(fecha, sucursal, empleado, cont_si, cont_no) 
	              VALUES(dFecha_ctetit, cSucursal_ctetit, cEmpleado_ctetit, iCont_si, iCont_no);

				let iCuentasIns_ctetit  = iCuentasIns_ctetit +1;
				
			 COMMIT WORK;
			 
		END FOREACH
		
  		
		let iCuentasEliminadas_ctetit = 0;
		
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, count(*)
			  INTO dFecha_ctetit, cSucursal_ctetit, iRegsABorrar
			  FROM bdicobranza:cb_cob_vent_cliente_titular
			 WHERE fecha between dtFecha_ini_mes_ant and dtFecha_fin_mes_ant
			 GROUP by 1,2
			
			BEGIN WORK;
				DELETE bdicobranza:cb_cob_vent_cliente_titular
				WHERE  fecha = dFecha_ctetit AND sucursal = cSucursal_ctetit;
			COMMIT WORK;
		    
			let iCuentasEliminadas_ctetit = iCuentasEliminadas_ctetit + iRegsABorrar;
			
			let iRegsABorrar = 0;
		END FOREACH
		let iCuentasEliminadas_ctetit_operativa = iCuentasEliminadas_ctetit;
		let iCuentasEliminadas_ctetit = 0;
			
	
		---- HIS
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, count(*)
			  INTO dFecha_ctetit, cSucursal_ctetit, iRegsABorrar
			  FROM bdicobranza:cb_cob_vent_cliente_titular_his
			 WHERE fecha between dtFecha_ini_mes_ant_2m and dtFecha_fin_mes_ant_2m
			 GROUP by 1,2
			
			BEGIN WORK;
				DELETE bdicobranza:cb_cob_vent_cliente_titular_his
				WHERE  fecha = dFecha_ctetit AND sucursal = cSucursal_ctetit;
			COMMIT WORK;
		    
			let iCuentasEliminadas_ctetit = iCuentasEliminadas_ctetit + iRegsABorrar;
			
			let iRegsABorrar = 0;
		END FOREACH
		let iCuentasEliminadas_ctetit_his = iCuentasEliminadas_ctetit;
				
		
		/*
		FOREACH WITH HOLD
		
			SELECT fecha, sucursal, empleado, cont_si, cont_no 
			  INTO dFecha_ctetit, cSucursal_ctetit, cEmpleado_ctetit, iCont_si, iCont_no
			  FROM bdicobranza:cb_cob_vent_cliente_titular_his
	         WHERE fecha between dtFecha_ini_mes_ant and dtFecha_fin_mes_ant
		
		    BEGIN WORK;
				DELETE bdicobranza:cb_cob_vent_cliente_titular_his
				 WHERE fecha = dFecha_ctetit,
				   AND sucursal = cSucursal_ctetit, empleado = cEmpleado_ctetit;
			COMMIT WORK;   
			
			let iCuentasEliminadas_ctetit_his = iCuentasEliminadas_ctetit_his +1;
				 
		END FOREACH		
	    */
		
		IF iCuentasIns_ctetit > 0 THEN
		   
		   --LET cMensaje = 'TOTAL Ctas PROCS. Cliente Titular: ' || iCuentasIns_ctetit;
	       LET cMensaje = ' TOTAL Ctas Cte Titular INSERT a histórica: ' || iCuentasIns_ctetit;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas Cte Titular ELIMINADAS: ' || iCuentasEliminadas_ctetit_operativa;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		END IF;
		
		IF iCuentasEliminadas_ctetit_his > 0 THEN
		   LET cMensaje = '';
	       LET cMensaje = 'TOTAL Ctas Cte Titular His ELIMINADAS: ' || iCuentasEliminadas_ctetit_his;
	       CALL "informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, TRIM(cMensaje), '02') RETURNING cCod_ret_2;
		END IF;
		let cReinicio = '0';
        UPDATE bdicobranza:cb_param SET valor = cReinicio WHERE empresa = vEmpresa AND cod_param = 6;
		
	END IF;
	
	
	
 --let cContGral = iContGral;
 LET cMensaje = 'PROCESO EXITOSO';
 --LET cMensaje = trim(cMensaje) || '. ' || iContGral || ' UPDs - ' || iContGral_2 || ' Inserts.' ;
 CALL bdicobranza:sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2;  
 --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, cMensaje, '03') RETURNING cCod_ret_2; 
 
 	
    ---RETURN cCodRet;
	RETURN cCodRet, trim(cMensaje);
	END
END PROCEDURE
DOCUMENT
'BD: bdicobranza',
'Ver: 1.0.0', 
'Autor: Marco A. Campos',
'Fecha: 20190901',
'DESCRIPCION: Depuración mensual de tablas de evaluación objetiva',
'Ver: 1.0.1',
'Autor: Marco A. Campos',
'Fecha: 20200802',
'Descripción: Modif para resolver incidencia error -1213 por tipo de dato en var. pefectuo_compac';

CREATE PROCEDURE "informix".sp_mail_primerconsumo()
returning 
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--2012-05-09
--crea archivo con datos que se muestran en pantalla cat con cliente con mora 1

----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte		char(20);
define vnumcredito	char(20);
define vnumtarjeta	char(20);
define vimporte		decimal(18,2);
define vfecha		date;
define vfechas		date;


---DECLARACIONES
DEFINE cNumCta			CHAR(20);
DEFINE dCapMtoCuota		DECIMAL(18,2);
DEFINE cDiasAnticipados	DECIMAL(18,2);
DEFINE cCel				CHAR(13);
DEFINE cEstado			CHAR(2);
DEFINE cCiudad			CHAR(3);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE cTipoRed			CHAR(10);
DEFINE cCodRet2			CHAR(6);
DEFINE cNumCarrier		CHAR(3);
DEFINE cSituacion		CHAR(1);
DEFINE iCausa			INTEGER;
DEFINE cNomEstado 		CHAR(20);
DEFINE cNomCiudad 		CHAR(20);
DEFINE iPagoVenc 		INTEGER;
DEFINE vSdoTotal1  		DECIMAL(18,2);
DEFINE vMtoVencido1  	DECIMAL(18,2);
DEFINE vMensualidad 	DECIMAL(18,2);
DEFINE vSdoTotal2  		DECIMAL(18,2);
DEFINE vMtoVencido2 	DECIMAL(18,2);
DEFINE vsaldo_total 	DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
define vpago 			DECIMAL(18,2);
DEFINE Vfecha_apertura 	DATE;
DEFINE iCel 			SMALLINT;
DEFINE vdia_pago 		smallint;
DEFINE vmail 			char(100);
DEFINE vvalor_numerico	INTEGER;
DEFINE vtotal1			INTEGER;
DEFINE vtotal2			INTEGER;
DEFINE vtotal			INTEGER;
define vregistrostotal	integer;
define vfecha1 			date;
define vfecha2 			date;
define vimporte1		DECIMAL(18,2);
define vimporte2 		DECIMAL(18,2);     

---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET     	VARCHAR(6);
DEFINE P_MENSAJE     	VARCHAR(80);
DEFINE vproceso			CHAR (4);
DEFINE cMensaje			CHAR(150);
DEFINE vpago_vencido	DECIMAL(18,2);
DEFINE vcontador		INTEGER;
define vpri_dia_mes		date;
define vapell_paterno 	char(30);
--define vcount 			INTEGER;
define iCount_TC_PRIMERC INTEGER; --A.L.L.
define iCount_TC_PRIMERS INTEGER; --A.L.L.
	define vvalor smallint;
define i integer;
define num smallint;
define vNumIniciudad 	char(8); --A.L.L
define vEstadoSiglas	char(10); --A.L.L
DEFINE iCuentasProcesadas     integer; 
DEFINE iCuentasExcluidasXMail integer;
--DEFINE iCuentasExcluidasXSdosVencidos integer;
--DEFINE dFechaCarLinea   date;
DEFINE iOtrasExclusiones integer;
DEFINE cNumProducto 	 char(04);
DEFINE iCuentasExcluidasXCel	INTEGER;

---INICIALIZACIONES
LET cNumCta				= '';
LET dCapMtoCuota		= 0;
LET	cDiasAnticipados	= 0;
LET cCel				= '';
LET cEstado				= '';
LET cCiudad				= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET cTipoRed			= '';
LET cCodRet2			= '';
LET cNumCarrier			= '';
LET cSituacion			= '';
LET iCausa				= 0;
LET cNomEstado = '';
LET cNomCiudad = '';
LET iPagoVenc = 0;
LET vSdoTotal1 = 0;
LET vMtoVencido1 = 0;
LET vMensualidad = 0;
LET vSdoTotal2 = 0;
LET vMtoVencido2 = 0;
LET vsaldo_total = 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo = 0;
LET vpago_minimo_total = 0;
let vpago = 0;
LET iCel = 0;
LET vdia_pago = 0;
LET vpago_vencido = 0;

let vnumcte = '';
let vnumcredito = '';
let vnumtarjeta = '';
let vimporte	=0;
let vfecha		= date(1);
let vfechas		= date(1);

let SQL_ERR		= 0;
let ISAM_ERR	= 0;
let ERROR_INFO	= '';
let P_COD_RET	= '000000';
--let P_MENSAJE	= 'PROCESO EXITOSO';
let P_MENSAJE	= 'El proceso de las campañas XX TDC PRIMER CONSUMO se realizó correctamente.';
let vproceso	= '2034';
let cMensaje	= '';
let vmail 		= '';
let vvalor_numerico	= 0;
let vtotal1			= 0;
let vtotal2			= 0;
let vtotal			= 0;
let vregistrostotal = 0;
let vcontador 		= 0;
let vfecha1 		= date(1);
let vfecha2 		= date(1);
let vimporte1		= 0;
let vimporte2 		= 0; 
let vpri_dia_mes = date(1);
let vapell_paterno = '';
--let vcount = 0;
let iCount_TC_PRIMERC = 0; --A.L.L.
let iCount_TC_PRIMERS = 0; --A.L.L.
let i = 0;
LET num = 0;
let vNumIniciudad	='';
let vEstadoSiglas	='';
let iCuentasProcesadas      = 0;
let iCuentasExcluidasXMail  = 0;
--let iCuentasExcluidasXSdosVencidos = 0;
--let dFechaCarLinea = date(1);
let iOtrasExclusiones = 0;
let cNumProducto 	= '';
let iCuentasExcluidasXCel = 0;


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, P_MENSAJE, '02')RETURNING P_COD_RET;	
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;

--  Set debug file to 'sp_mail_primerconsumo.out';
--  trace on;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	

    if P_COD_RET != '000000' then
--       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

	select fecha_ant into vfecha from bdicred:sd_fechas where empresa = '001';
--temporal para pruebas	
	--let vfecha = today;
--temporal para pruebas
	let vpri_dia_mes = mdy(month(vfecha),day(1),year(vfecha));
    set isolation to dirty read;
	
--	DELETE FROM bdicobranza:cb_info_administrativa WHERE empresa ='001' and fecha_ejecucion <= today and num_campania = 16; 
		select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
		
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)		
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'TC_PRIMERC',numcte,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
				
			let num = num + 10;
	end for
		
--------------------------------------------------------EMAIL------------------------------------------------------------------   
	FOREACH
	
		SELECT  
		a.numcte, a.num_credito, b.f_primer_compra,b.monto_primer_compra ,b.f_primer_disp, b.monto_primer_disp, a.num_producto
				INTO vnumcte, vnumcredito,vfecha1,vimporte1,vfecha2,vimporte2, cNumProducto
		FROM bdicred:sd_maecred a, bdicred:sd_indicador_cred b 
		WHERE a.empresa = '001'
			and a.empresa = b.empresa
			and a.num_credito = b.num_credito
			and a.num_producto = '6001'
			and (b.f_primer_compra = vfecha or b.f_primer_disp  = vfecha)
		--A.L.L	
		let iCuentasProcesadas = iCuentasProcesadas + 1;
		
		if (vfecha1 is null or vfecha2 is null) then
			if (vfecha1 = vfecha) then let vimporte = vimporte1; end if;
			if (vfecha2 = vfecha) then let vimporte = vimporte2; end if;
				
/*			select  apell_paterno into vapell_paterno
			from bdinteg:si_cliente where empresa = '001' and numcte = vnumcte ;*/
		  
			let vmail = '';
			select limit 1 cte.correo_elec into vmail 
			from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = vnumcte and cte.status_correo ='A'
			and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = vnumcte and status_correo ='A');		

			if vmail is null or vmail = '' then 
		       let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
		       continue foreach; 
		    end if;

			select LIMIT 1 t.num_tarjeta into vnumtarjeta
			from bdicred:sd_tarjeta t
			where t.empresa = '001'
			and t.num_credito = vnumcredito
			and t.secuencia = (select max(tar.secuencia)
                from bdicred:sd_tarjeta tar
                where tar.empresa = '001'
                and tar.num_credito = vnumcredito
                and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and t.tipo_tarjeta ='T'  and t.status_tar = 'A';   
				
--			if (vmail <> '') then	
--				if nvl(vnumcte,'') <> '' then
				--A.L.L.
				LET iCount_TC_PRIMERC = iCount_TC_PRIMERC +1;
				call bdimnsj:"informix".sp_registra_evento (1, 'TC_PRIMERC' , vnumcte, vnumcredito,vnumtarjeta, 2,
							'','','','','',vimporte,0,0,0,0, today, '')RETURNING P_COD_RET;

				call "informix".sp_inserta_info_rep_envios ('001','EMAIL',1009, vnumcredito, vnumcte, cNumProducto, today, vmail, '','', 0) returning P_COD_RET;
--				end if;
--			end if;
		end if;
	END FOREACH

		--A.L.L.
	IF iCount_TC_PRIMERC > 0 THEN
--        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERC',iCount_TC_PRIMERC) RETURNING P_COD_RET;
        CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERC',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;
	END IF;
	
--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TC_PRIMERC : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados TC_PRIMERC : ' ||iCount_TC_PRIMERC;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
	   end if;
--Genera cifras de control

	
---------------------------------------------------------SMS-------------------------------------------------------	
	let vfecha1 = date(1);		let vfecha2 = date(1);		let vimporte1 = 0;		let vimporte2 = 0; 
	let iCuentasProcesadas = 0;
	--- foreach para sms 
	let vfechas = date(vfecha)	+ 1 units day;
	select valor_numerico 
			into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro = 1;
		
	select nvl(count(*),0) into vtotal1
	from bdimnsj:mnsjr_trx_batch_his
		where id_mensaje ='TC_PRIMERS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	select nvl(count(*),0) into vtotal2
	from bdimnsj:mnsjr_trx_batch
		where id_mensaje ='TC_PRIMERS' and DATE(fecha_hora_registro) >= vpri_dia_mes;
	let vtotal = vtotal1 + vtotal2;
		
		---- consulta para saber cuantos registros faltan por buscar al mes	
		let vregistrostotal = vvalor_numerico - vtotal;
		
		LET vtotal = vtotal;
		if (day(vfechas) = 1 ) then 
			let vtotal = 0; 
			let vregistrostotal = vvalor_numerico;
		end if;
		
if(vtotal < vvalor_numerico) then 
	FOREACH
	
		SELECT 
		a.numcte, a.num_credito, b.f_primer_compra,b.monto_primer_compra ,b.f_primer_disp, b.monto_primer_disp, a.num_producto
				INTO vnumcte, vnumcredito,vfecha1,vimporte1,vfecha2,vimporte2, cNumProducto
		FROM bdicred:sd_maecred a, bdicred:sd_indicador_cred b --, bdinteg:si_correos d
		WHERE a.empresa = '001'
			and a.empresa = b.empresa
			and a.num_credito = b.num_credito
			and a.num_producto = '6001'
			and (b.f_primer_compra = vfecha or b.f_primer_disp  = vfecha)
		--A.L.L.	
		let iCuentasProcesadas = iCuentasProcesadas + 1;
		
		if (vfecha1 is null or vfecha2 is null) then
			if (vfecha1 = vfecha) then let vimporte = vimporte1; end if;
			if (vfecha2 = vfecha) then let vimporte = vimporte2; end if;
				
			LET iPagoVenc = 0;		
		
			select LIMIT 1 t.num_tarjeta into vnumtarjeta
			from bdicred:sd_tarjeta t
			where t.empresa = '001'
			and t.num_credito = vnumcredito
			and t.secuencia = (select max(tar.secuencia)
                from bdicred:sd_tarjeta tar
                where tar.empresa = '001'
                and tar.num_credito = vnumcredito
                and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and t.tipo_tarjeta ='T'  and t.status_tar = 'A';   
				
/*			SELECT limit 1  e.nombre, c.nombre --NVL(estado,''), NVL(ciudad,'') 
		    INTO  cNomEstado, cNomCiudad  --cEstado, cCiudad
		    FROM bdinteg:"informix".si_direcciones_actual d, 
             bdinteg:"informix".si_estados e, 
             bdinteg:"informix".si_ciudades c 
			WHERE d.numcte= vnumcte
		     AND d.tipo_dir= '1'
		     AND d.estado = e.estado
		     AND d.ciudad = c.ciudad
		     AND c.estado = e.estado;*/
			 
			SELECT limit 1 d.telefono
		    INTO cCel
		    FROM bdinteg:"informix".si_telefonos_actual d
		    WHERE d.numcte= vnumcte
		     AND d.tipo_tel= '2' and status_tel = 'A' and cofetel ='V' ;

			if cCel is null or cCel = '' then 
		       let iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
		       continue foreach; 
		    end if;

--			if (cCel <> '') then
		
				LET iCel = LENGTH(cCel) + 1 - 10;
    
--				IF cCel <> '' then
					IF ( LENGTH(cCel) > 10 ) THEN
						LET cCel = SUBSTR(cCel,iCel,10);
					ELIF ( LENGTH(cCel) < 10 ) THEN
						LET cCel =''; 
					END IF;		
--				END IF;
			
/*				SELECT NVL(nombre1,''), NVL(nombre2,''), NVL(apell_paterno,''), NVL(apell_materno,'')
				INTO cNombre1, cNombre2, cApellPat, cApellMat
				FROM bdinteg:"informix".si_cliente
				WHERE numcte= vnumcte;		*/
		
				SELECT {+ INDEX(bdisitesp:"informix".se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 situacion, causa
				INTO cSituacion, iCausa
				FROM bdisitesp:"informix".se_ctessitespcte
				WHERE numcte = vnumcte;
			
				IF cSituacion IS NULL THEN LET cSituacion = ''; END IF; 
				IF iCausa IS NULL THEN LET iCausa = 0; END IF; 
			
--				IF cCel <> '' then
--					if (vnumcredito is not null) then
/*					INSERT INTO bdicobranza:"informix".cb_info_administrativa
						(empresa, num_campania, producto, fecha_ejecucion, cliente, credito, cuenta, tarjeta, ciudad, estado, 
						nombre1, nombre2, apell_paterno, apell_materno, t_celular, sdo_total, 
						pago_min, fecha_pago, sdo_venc_int_mora, pago_venc, pago_min_sin_vdo, causa,situacion,
						pago_vencido ,pago_req_sms, cidad, estado)
					VALUES ('001', 16, '6001', today, vnumcte, vnumcredito, cNumCta, vnumtarjeta, cNomCiudad, cNomEstado, 
						cNombre1, cNombre2, cApellPat, cApellMat, cCel, 0,
						0, '', 0, iPagoVenc, 0, iCausa,cSituacion,0,vimporte, vNumIniciudad, vEstadoSiglas );*/
					--A.L.L.
					LET iCount_TC_PRIMERS = iCount_TC_PRIMERS +1;
					call bdimnsj:"informix".sp_registra_evento (2, 'TC_PRIMERS' , vnumcte, vnumcredito,vnumtarjeta, 2,
							'','','','','',0,0,0,0,0, '', '')RETURNING P_COD_RET;
							
					let vcontador = vcontador + 1;			
					call "informix".sp_inserta_info_rep_envios ('001','SMS',16, vnumcredito, vnumcte, cNumProducto, today, cCel, '','', 0) returning P_COD_RET;
					end if; 
--				end if;
--			end if;
			if (vcontador = vregistrostotal) then exit FOREACH; end if;
--		end if;
	END FOREACH
end if;
	
	if (vcontador >= 1) then 
	let i = 0;
	LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1)
		select  2, 'TC_PRIMERS',numcte,current,apell_paterno
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
			let num = num + 10;
	end for
	end if;
	
	-------------------------------------------contadores------------------------------------	

		--A.L.L.
		IF iCount_TC_PRIMERS > 0 THEN
--            CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERS',iCount_TC_PRIMERS) RETURNING P_COD_RET;
            CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TC_PRIMERS',iCuentasProcesadas,iCuentasExcluidasXCel) RETURNING P_COD_RET;
		END IF;
		
--Genera cifras de control
	    if iCuentasProcesadas > 0 then
	       let cMensaje = 'TOTAL Cuentas procesadas campaña TC_PRIMERS : ' ||iCuentasProcesadas;
	       let cMensaje = trim(cMensaje) ||'    EMAILs enviados TC_PRIMERS : ' ||iCount_TC_PRIMERS;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
	       let cMensaje = 'Cuentas excluidas por error cel : ' ||iCuentasExcluidasXCel;
	       CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
	    end if;
--Genera cifras de control
		
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03')RETURNING P_COD_RET;	
--    RETURN P_COD_RET;

    if P_COD_RET != '000000' then
--       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;
    
	RETURN P_COD_RET,P_MENSAJE;
end;
end procedure;