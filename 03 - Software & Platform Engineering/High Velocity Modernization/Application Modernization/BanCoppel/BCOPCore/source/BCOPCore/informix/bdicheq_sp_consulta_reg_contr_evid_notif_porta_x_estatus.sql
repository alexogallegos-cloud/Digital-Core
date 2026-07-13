CREATE PROCEDURE "informix".sp_consulta_reg_contr_evid_notif_porta_x_estatus(pEstatus CHAR(1))
RETURNING CHAR(5)  AS codRet,					
		  CHAR(50) AS mensajeRet,                   
		  CHAR(20) AS cliente,					
		  CHAR(30) AS folio_solicitud,              
		  CHAR(20) AS nombre_banco,             
		  CHAR(20) AS cuenta_encript,           
		  CHAR(20) AS cuenta ,                  
		  CHAR(4)  AS producto,                 
		  CHAR(40) AS nombre_producto,          
		  DATE	   AS fecha_inicio_portab,      
		  CHAR(1)  AS estatus,                  
		  DATE     AS fecha_insert,
		  DATE 	   AS fecha_modificacion;

	DEFINE cCliente					CHAR(20);		--Numero de cliente
	DEFINE cFolio_solicitud         CHAR(30);       --Folio de la solcitud de portabilidad
	DEFINE cNom_corto_banco         CHAR(20);       --Nombre corto del banco receptor
	DEFINE cCuenta_encript          CHAR(20);       --Cuenta receptora del cliente con mascara
	DEFINE cCuenta                  CHAR(20);       --Cuenta ordenante del cliente
	DEFINE cProducto                CHAR(4);        --Codigo de producto
	DEFINE cProd_nombre             CHAR(40);       --Nombre del producto
	DEFINE dFecha_ini_portab        DATE;           --Fecha de inicio de la portabilidad
	DEFINE dFecha_insert			DATE;			--Fecha del dia de hoy
	DEFINE dFecha_modificacion		DATE;			--Fecha de modificacion del registro
	DEFINE cCodRet					CHAR(5); 		--Codigo de retorno
	DEFINE cMensajeRet 				CHAR(50);		--Mensaje de retorno
	DEFINE Sql_Err					INTEGER;		--Codigo de error SQL 
	DEFINE Desc_Err					CHAR(50);		--Descripcion de error no controlado
	DEFINE Isam_Err					INTEGER;		--Codigo de error ISAM 
	
	LET cCliente			= '';		
	LET cFolio_solicitud    = '';
	LET cNom_corto_banco    = '';
	LET cCuenta_encript     = '';
	LET cCuenta             = '';
	LET cProducto           = '';
	LET cProd_nombre        = '';
	LET dFecha_ini_portab   = TODAY;
	LET dFecha_modificacion = TODAY;
	LET cCodRet 			= '00000';
	LET cMensajeRet 		= '';
	
	--SET DEBUG FILE TO "/home/c90314833/Ejecuciones/sp_consulta_reg_contr_evid_notif_porta_x_estatus.out";
	--TRACE ON;	
	
	BEGIN
	
		ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
			IF Sql_Err <> 0 THEN
				LET cCodRet = Sql_Err;	
				LET cMensajeRet = Desc_Err;
			 RETURN cCodRet, cMensajeRet,'','','','','','','','','','','';
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
  		SET LOCK MODE TO WAIT 3;
		
		IF TRIM(pEstatus) = '' OR (pEstatus IS NULL) THEN
			LET cCodRet = '00002';
			LET cMensajeRet = 'El parametro de entrada esta vacio o es nulo.';
			RETURN cCodRet,cMensajeRet,'','','','','','','','','','','';
		END IF; 
		
		IF (SELECT COUNT(*) FROM sc_control_evidencia_notif_portab WHERE estatus = pEstatus) <= 0 THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'Sin registros por procesar.';
			RETURN cCodRet,cMensajeRet,'','','','','','','','','','','';
		END IF;
		
		--Consultamos los registros de la tabla sc_control_evidencia_notif_portab que esten pendientes y se hayan insertado hoy
		FOREACH WITH HOLD
		SELECT cliente,folio_solicitud,nom_corto_banco,cuenta_encript,cuenta,producto,prod_nombre,fecha_ini_portab,fecha_insert,fecha_modificacion
		INTO cCliente,cFolio_solicitud,cNom_corto_banco,cCuenta_encript,cCuenta,cProducto,cProd_nombre,dFecha_ini_portab,dFecha_insert,dFecha_modificacion
		FROM sc_control_evidencia_notif_portab 
		WHERE estatus = pEstatus 
			
			--Retornamos los datos 1 a 1 al WS.
			RETURN cCodRet,cMensajeRet,cCliente,cFolio_solicitud,cNom_corto_banco,cCuenta_encript,cCuenta,cProducto,cProd_nombre,dFecha_ini_portab,pEstatus,dFecha_insert,dFecha_modificacion WITH RESUME;
			
		END FOREACH;	
	END
END PROCEDURE
DOCUMENT 
'+----------------------------------------------------------------------------------------------------------------------+',
'+ Realizo: Daniel Hernandez Garcia																						+',
'+ Fecha de creacion: 01/07/2024																						+',
'+ Proyecto: RQM 06 895  Evidencia aceptacion alta portabilidad															+',
'+ Funcion del SP: Consulta los datos de la tabla sc_control_evidencia_notif_portab con el estatus indicado				+',
'+----------------------------------------------------------------------------------------------------------------------+';

CREATE PROCEDURE "informix".sp_inserta_reg_contr_evid_notif_portab(        
	pCliente 			CHAR(20),		--Numero de cliente
	pFolio_solicitud 	CHAR(30),		--Folio de la solicitud 
	pNom_corto_banco 	CHAR(20),       --Nombre del banco receptor
	pCuenta_encript 	CHAR(20),       --Cuenta receptora del cliente con mascara
	pCuenta 			CHAR(20),       --Cuenta ordenante del cliente (Tarjeta o Cuenta Clabe)
	pFecha_ini_portab 	DATE,           --Fecha de inicio de la portabilidad
	pEstatus 			CHAR(1))
	RETURNING CHAR(5) AS codRet,  --CODIGO RETORNO
		  CHAR(40) AS mensajeRet; --MENSAJE DE RETORNO

	DEFINE cCuenta                  CHAR(20);       --Numero de cuenta 
	DEFINE cProducto 				CHAR(4);		--Codigo de producto 
	DEFINE cNombre_producto 		CHAR(40);		--Nombre del producto
	DEFINE dFecha_hoy 				DATE;			--Fecha del dia de hoy
	DEFINE cCodRet					CHAR(5); 		--Codigo de retorno
	DEFINE cMensajeRet 				CHAR(40);		--Mensaje de retorno
	DEFINE cEmpresa					CHAR(3);		--Codigo de empresa
	DEFINE iTotalRegistros			INTEGER;		--Contador para la validacion de registros existentes
	DEFINE Sql_Err					INTEGER;
	DEFINE Desc_Err					CHAR(40);
	DEFINE Isam_Err					INTEGER;
	
	LET cCuenta             = '';
	LET cProducto 			= '';
	LET cNombre_producto	= '';
	LET dFecha_hoy			= TODAY;
	LET cCodRet 			= '00000';
	LET cMensajeRet 		= 'Registro existoso';
	LET cEmpresa			= '001';
	LET iTotalRegistros		= 0;
	
	--SET DEBUG FILE TO "/home/c90314833/Ejecuciones/sp_inserta_reg_contr_evid_notif_portab.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET Sql_Err,Isam_Err, Desc_Err
			IF Sql_Err <> 0 THEN
				LET cCodRet = Sql_Err;
				LET cMensajeRet = Desc_Err;
			 RETURN cCodRet, cMensajeRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
  		SET LOCK MODE TO WAIT 3;
		
		IF (TRIM(pCliente) = '' OR (pCliente IS NULL) OR
		TRIM(pFolio_solicitud) = '' OR (pFolio_solicitud IS NULL)) THEN
		
			LET cCodRet = '00002';
			LET cMensajeRet = 'Datos requeridos vacios o nulos.';
			RETURN cCodRet,cMensajeRet;
		END IF;
		
		
		--Consulta el codigo de producto y nombre del producto del cliente.
		
		SELECT mae.producto,prod.nombre,mae.cuenta
		INTO cProducto,cNombre_producto,cCuenta 
		FROM sc_maechq AS mae 
		INNER JOIN sc_producto AS prod ON mae.producto = prod.producto
		INNER JOIN sc_tarjeta AS tar ON mae.cuenta = tar.cuenta
		WHERE num_tarjeta = pCuenta;

		IF cProducto = '' OR cProducto IS NULL OR cNombre_producto = '' OR cNombre_producto IS NULL THEN
				
			SELECT mae.producto,prod.nombre,mae.cuenta
			INTO cProducto,cNombre_producto,cCuenta 
			FROM sc_maechq AS mae 
			INNER JOIN sc_producto AS prod ON mae.producto = prod.producto
			WHERE mae.cuenta_clabe = pCuenta;

		
			IF cProducto IS NULL OR cProducto = '' OR cNombre_producto IS NULL OR cNombre_producto = '' THEN 
				LET cCodRet = '00003';
				LET cMensajeRet = 'El producto o la cuenta no existe';
				RETURN cCodRet,cMensajeRet;
			END IF;
			
		END IF;
		

		
		--Valida que no exista una insercion a la tabla con estatus de carga de documento pendiente.
		SELECT COUNT(*) INTO iTotalRegistros 
		FROM sc_control_evidencia_notif_portab 
		WHERE cliente = pCliente 
		AND folio_solicitud = pFolio_solicitud;		
		
		--Si existe un registro retornamos el error 00001.
		IF(iTotalRegistros > 0) THEN
			LET cCodRet = '00001';
			LET cMensajeRet = 'Ya existe un registro con estos datos.';
			RETURN cCodRet,cMensajeRet;
		END IF;
		
		--Insertamos el registro en la tabla sc_control_evidencia_notif_portab.
		INSERT INTO sc_control_evidencia_notif_portab (cliente,folio_solicitud,nom_corto_banco,cuenta_encript,cuenta,producto,prod_nombre,fecha_ini_portab,estatus,fecha_insert,fecha_modificacion)
			VALUES(pCliente,pFolio_solicitud,pNom_corto_banco,pCuenta_encript,cCuenta,cProducto,cNombre_producto,pFecha_ini_portab,pEstatus,dFecha_hoy,NULL);
		
		--Retornamos el codigo y mensaje de retorno.
		RETURN cCodRet,cMensajeRet;
		
	END	
END PROCEDURE
DOCUMENT 
'+----------------------------------------------------------------------------------------------------------------------+',
'+ Realizo: Daniel Hernandez Garcia																						+',
'+ Fecha de creacion: 01/07/2024																						+',
'+ Proyecto: RQM 06 895  Evidencia aceptacion alta portabilidad															+',
'+ Funcion del SP: Insertar los datos requeridos en la tabla sc_control_evidencia_notif_portab usada para llevar el     +',
'+ control del guardado de la evidencia de alta de portabilidad en el expediente digital del cliente.					+',
'+----------------------------------------------------------------------------------------------------------------------+';

CREATE PROCEDURE "informix".sp_cargarchivoportab(pfecha_reg date,pnombrearchivo CHAR(30),cod_oper CHAR(2),itotalsol integer)
RETURNING CHAR(3),  --CODIGO RETORNO
		  CHAR(35), --NOMBRE DEL ARCHIVO
		  CHAR(50); --RUTA EN CENTRAL DONDE SE DEPOSITO ARCHIVO

		  
   -- // DESCRIPCION DE LOS PARAMETROS DE ENTRADA
    /*  pfecha_reg:       Fecha en la cual se va a cargar el arhivo
        pnombrearchivo:   Nombre del archivo que se va a cargar
		cod_oper:         Tipo de operaciÃ³n:  20= instrucciÃ³n de portabilidad de nomina  
                                              21= Respuesta a instrucciÃ³n de portabilidad de nomina
		itotalsol:        Numero total de solicitudes cargadas en central 								  
	*/
 
---- VARIABLES  GENERALES---
DEFINE cSqlerr				 INTEGER;
DEFINE cIsamErr				 INTEGER;
DEFINE cDescErr				 char(50);
DEFINE cCodret      		 char(5);
DEFINE cCodret2      		 char(5);
DEFINE cCodret3      		 char(50);
DEFINE cArchResp	    	 char(30);
DEFINE cMensaje 			 char(110);
DEFINE cSQL 				 char(250);
DEFINE cLinea 				 char(500);
DEFINE cBandera 			 char(1);
DEFINE iNumReg 				 INTEGER;
DEFINE cRenglon 			 char(500);
DEFINE cvalidacuentaexis	 INTEGER;
DEFINE cvalidaestatuscta 	 INTEGER;			
DEFINE cportact          	 INTEGER;
DEFINE dtFecNac           	 char(8);  
DEFINE dtFecNac2             char(8);  
DEFINE cnumcte            	 char(20);
DEFINE cfoliosolicitud    	 char(30);
DEFINE cbancoordenante    	 char(5);
DEFINE ccuentaordenante   	 char(20);
DEFINE ctipoctaordenante   	 char(2);
DEFINE cbcoreceptor       	 char(5);
DEFINE cctareceptora       	 char(20);
DEFINE ctipoctareceptora  	 char(2);
DEFINE cfechasolicitud    	 char(8);
DEFINE crfcempresa        	 char(12);
DEFINE cfecharespuesta    	 char(8);
DEFINE cestatusrespuesta  	 char(2);
DEFINE cestatusrespuestabcord char(2);
DEFINE cestatusportabilidad  char(2);
DEFINE vfecha_reg        	 char(8);  
DEFINE crespRutaArchivo  	 char(50);
DEFINE ccuenta           	 char(20);
DEFINE cBandCta				 char(1);
DEFINE cEstatuscarga	 	 char(1);
DEFINE ccuenta_nor           char(20);
DEFINE CodigoRetorno         char (5);
DEFINE MensajeEjecucion		 char (110);		
DEFINE cban_rec_cor          char (3);
DEFINE cCodRet_msj           char (5);
DEFINE csucursal             char (4);
DEFINE cfecha_solicitud10    char (10);
DEFINE cCodRet10             char(6);
DEFINE dtFecha10	         DATE;
DEFINE cfecha10_reg_even     char(10);

-- DEFINIR VARIABLES RUTAS
DEFINE csolRutaArchivo       char(60);
DEFINE csol_Res_RutaArchivo  char(60);
DEFINE cRutaArchivo     	 char(60);

-- DEFINIR VARIABLES ENCABEZADO 

DEFINE cfecha_presentacion   char(8);
DEFINE ccod_operacion        char(2);
DEFINE cnum_secuencia        INTEGER;
DEFINE cbanco_rec            INTEGER;
DEFINE csent_archi           char(1);

-- DEFINIR VARIABLES SUMARIO
DEFINE cnumsecuencia         INTEGER;
DEFINE ccodoperacion     	 INTEGER;
DEFINE itotalregistros   	 INTEGER;

-- DEFINIR VARIABLES DETALLE  
DEFINE ccod_ope              char(2); 
DEFINE isecuencia            integer; 
DEFINE cfolio_solicitud      char(30);
DEFINE cfecha_solicitud      char(8);
DEFINE cnombre_cte           char(60);
DEFINE crfc_cte              char(13);
DEFINE ccta_receptora        char(20);
DEFINE ctipo_cta_receptora   char(2);
DEFINE cbco_receptor         char(5);
DEFINE ccta_ordenante        char(20);
DEFINE ctipo_cta_ordenante   char(2);
DEFINE cbco_ordenante        char(5);
DEFINE cfecha_nacimiento     char(8);
DEFINE crfc_empresa          char(12);
DEFINE cestatus_respuesta    char(2);
DEFINE cfecha_respuesta      char(8);
DEFINE ccurp_cte             char(18);
DEFINE cmotivo               char(2);

DEFINE creproce_estatus_respuesta  char(2);

--#### variable para  definir la portabilidad

DEFINE psest_port            char(2);  

--#### variables retorno del sp_generarchivoresp

DEFINE cCodig_ret			 char(3);
DEFINE Itotal_sol			 INTEGER;	
DEFINE cruta_archi			 char(50);
DEFINE cArchivresp           char(35);
DEFINE cnombarcpar           char(20);

--#### variables para folios repetidos
DEFINE numero_folios        INTEGER;
DEFINE iRegistros		 	INTEGER; 
DEFINE cporta_existe  		CHAR(2);


--### variables para update codigo 21

DEFINE  cupd_folios   	    INTEGER;

DEFINE  cMensaje_smsdes     char(110);
DEFINE  Bandesap            char(1); 
DEFINE  cbanconombre        char (20);
DEFINE  cfecha_dmy          char(10);
DEFINE  cbanomb_esp         char (20);

--## variables para URLS 
DEFINE curl_aprueba 		 char(60);
DEFINE curl_desaprueba  	 char(60);
DEFINE cta_rec_ast           char(20);
DEFINE cencripta_tar         char(14);   
DEFINE pempresa              char(3);
DEFINE ven_transacc         SMALLINT;
DEFINE itot_arch			INTEGER;
--Bandera para identificar cuando se inserte registr en sc_portacec_solicitud clave_origen=3
DEFINE cBanderaClaveOr3      char(1);

--Variables para mensaje Prestamo Directo de Nomina y Anticipo de Nomina
DEFINE vSMScte char(20); 
DEFINE vSMStel char(10);  
DEFINE vSMSnumcred char(20);
DEFINE vSMScteAN char(20); 
DEFINE vSMStelAN char(10);  
DEFINE vSMSnumcredAN char(20);
--## variables para calcular 30 dias  
DEFINE dFechaHoy DATE;
DEFINE dtFechaVen	DATE;
DEFINE vhay  char(1);
--Variables para el control de retorno del sp_inserta_reg_contr_evid_notif_portab. RQM 06 895. Fecha:01-Jul-2024. Daniel Hernandez Garcia
DEFINE codRetIn			CHAR(5);
DEFINE mensajeRetIn		CHAR(40);

--Variables para la limpieza de TABLAS
DEFINE cNumSerial		INTEGER;
DEFINE cColumna			CHAR(500);

--VALORES INICIALES
LET cSqlerr 			= 0;
LET cIsamErr 			= 0;
LET cDescErr 			= '';
LET cCodret 			= '000';
LET cCodret2 			= '';
LET cCodret3 			= '';
LET cArchResp 				= '';
LET cMensaje = '';
LET cSQL 				= '';
LET cLinea = '';
LET cBandera = "F";
LET iNumReg = 0;
LET cRenglon = '';
LET cvalidacuentaexis = 0;
LET cvalidaestatuscta = 0;
LET cportact          = 0;
LET dtFecNac          = " "; 
LET dtFecNac2         = " "; 
LET cnumcte           = '';
LET cfoliosolicitud   = '';
LET cbancoordenante   = '';
LET ccuentaordenante  = '';
LET ctipoctaordenante = '';
LET cbcoreceptor      = '';
LET cctareceptora     = '';
LET ctipoctareceptora = '';
LET cfechasolicitud   = '';
LET crfcempresa       = '';
LET cfecharespuesta   = '';
LET cestatusrespuesta = '';
LET cestatusrespuestabcord = '';
LET  cestatusportabilidad = '';
LET cRutaArchivo        = '';
LET vfecha_reg          = ''; 
LET cmotivo             = ''; 
LET crespRutaArchivo    = '';
LET ccuenta             = ''; 
LET cBandCta			= "";
LET cEstatuscarga       = '0'; 
LET ccuenta_nor         = ''; 
LET CodigoRetorno       = ''; 
LET MensajeEjecucion	= ''; 	
LET cban_rec_cor        = '';
LET cCodRet_msj         = '';
LET csucursal           = ''; 
LET cfecha_solicitud10  = '';
LET cCodRet10           = "000000";
LET dtFecha10			= NULL;
LET cfecha10_reg_even   = '';


-- INICIALIZAR VARIABLES RUTAS

LET csolRutaArchivo     = '';
LET csol_Res_RutaArchivo   = '';
 
-- INICIALIZAR VARIABLES ENCABEZADO 

LET cfecha_presentacion  = '';
LET ccod_operacion       = '';
LET cnum_secuencia       = 0;
LET cbanco_rec           = 0;
LET csent_archi          = '';

-- INICIALIZAR VARIABLES DETALLE
LET  ccod_ope             = '';
LET  isecuencia           = 0;
LET  cfolio_solicitud     = '';
LET  cfecha_solicitud     = '';
LET  cnombre_cte          = '';
LET  crfc_cte             = '';
LET  ccta_receptora       = '';
LET  ctipo_cta_receptora  = '';
LET  cbco_receptor        = '';
LET  ccta_ordenante       = '';
LET  ctipo_cta_ordenante  = '';
LET  cbco_ordenante       = '';
LET  cfecha_nacimiento    = '';
LET  crfc_empresa         = '';
LET  cestatus_respuesta   = '';
LET  cfecha_respuesta     = '';
LET  ccurp_cte            = '';
LET  creproce_estatus_respuesta  = '';

-- INICIALIZAR VARIABLES SUMARIO
LET cnumsecuencia      = 0;
LET ccodoperacion      = 0;  
LET itotalregistros    = 0;


--#### variable para definir portabilidad

LET psest_port             = ''; 

--#### variables retorno del sp_generarchivoresp

LET cCodig_ret			   = '';
LET Itotal_sol			   = 0;	
LET cruta_archi			   = '';
LET cArchivresp            = "";
LET cnombarcpar            = "rporta40137E";

--#### variable para folios repetidos
LET numero_folios          = 0;	
LET iRegistros			   = 0;
LET cporta_existe		   = '';	


--### variables para update codigo 21

LET cupd_folios            = 0;

LET cMensaje_smsdes    	   = '';
LET Bandesap               = 'V';   
LET cbanconombre           = '';
LET cfecha_dmy             = '';
LET cbanomb_esp            = '';

--## variables para URLS 
LET curl_aprueba 		   = '';
LET curl_desaprueba  	   = '';
LET  cta_rec_ast           = '';
LET  cencripta_tar         = '**************';
LET  pempresa              = '001';
LET ven_transacc           = 0;
LET itot_arch			   = 0;	

--inicializar bandera clave_origen=3
LET cBanderaClaveOr3    = "F";
LET vSMScte =''; 
LET vSMStel ='';  
LET vSMSnumcred ='';
LET vSMScteAN =''; 
LET vSMStelAN ='';  
LET vSMSnumcredAN ='';

-- Variables para 30 dias

LET dFechaHoy   = DATE(1);
LET dtFechaVen  = DATE(1);
LET vhay  		= '';

--Variables para el retorno del sp_inserta_reg_contr_evid_notif_portab. RQM 06 895. Fecha:01-Jul-2024. Daniel Hernandez Garcia
LET codRetIn			= '';
LET mensajeRetIn		= '';
--Variables para la limpieza de TABLAS
LET cNumSerial		= 0;
LET cColumna		= '';


  BEGIN
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;   
			Let cCodret2 = cIsamErr;   
			Let cCodret3 = cDescErr;   
			IF ven_transacc = 1 THEN
                ROLLBACK WORK;			
            END IF;
           RETURN cCodret, cArchivresp, cruta_archi;
        END IF;
	END EXCEPTION;
	
	
    --SET DEBUG FILE TO "/resplogifx/conciliachq/portabilidad/sp_cargarchivoportab.out";
	--TRACE ON;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
		BEGIN WORK;
        LET ven_transacc = 1;
	
	    IF LENGTH(NVL(pfecha_reg,'')) = 0 OR LENGTH(NVL(pnombrearchivo,'')) = 0 OR LENGTH(NVL(cod_oper,'')) = 0  OR LENGTH(NVL(itotalsol,'')) = 0
	    THEN
			LET cCodret='777';   --PARAMETROS VACIOS	
			RETURN cCodret, cArchivresp, cruta_archi;
		END IF;
	
	--Se leerÃ¡ de la tabla de parÃ¡metros (sc_parametros), aquellos datos fijos(rutas).
	
		SELECT {+INDEX(sc_param idx_param1 )} valor
		INTO csolRutaArchivo 
		FROM BDICHEQ:sc_param 
		WHERE empresa = pempresa
		AND codparam = 'rta_ptsol';
		
		SELECT {+INDEX(sc_param idx_param1 )} valor
		INTO csol_Res_RutaArchivo 
		FROM BDICHEQ:sc_param 
		WHERE empresa = pempresa 
		AND codparam = 'rta_ptres';

		SELECT {+INDEX(sc_param idx_param1 )} valor 
		INTO curl_aprueba
		FROM bdicheq:sc_param 
		WHERE empresa = pempresa 
		AND codparam='urlApruebaPortab'; 

		SELECT {+INDEX(sc_param idx_param1 )} valor 
		INTO curl_desaprueba
		FROM bdicheq:sc_param 
		WHERE empresa = pempresa 
		AND codparam='urlDesapruebaPortab'; 
		
     -- Se leera la fecha de Hoy y se consultara fecha a 30 dias.

	
        select fecha_hoy
        into dFechaHoy
        from sc_fechas
        where empresa = pempresa;
		
		LET dtFechaVen = dFechaHoy - 30 UNITS DAY;
		
		
    --// PONE EN VARIABLES LA FECHA SOLICITADA (D/M/Y)	
		LET cfecha_dmy = LPAD(DAY(pfecha_reg),2,0)||'/'||LPAD(MONTH(pfecha_reg),2,0)||'/'||(YEAR(pfecha_reg));
		
	--// PONE EN VARIABLES LA FECHA SOLICITADA (AAAAMMDD)
		LET vfecha_reg = YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0); 
			
	--// SELECCIONA LA RUTA DEL ARCHIVO DEPENDIENDO EL CODIGO.	
		IF 	cod_oper= "20" THEN  
			LET cRutaArchivo=csolRutaArchivo;
		
		ELIF cod_oper= "21" THEN
			LET cRutaArchivo=csol_Res_RutaArchivo;

		END IF
		
		
		
		select count(*) 
		into  itot_arch
		FROM  BDICHEQ: sc_portacec_bitacora_archivo
		where fecha_carga=vfecha_reg and archivo=pnombrearchivo
		and estatus_carga ='0';
		
		
	IF   itot_arch > 0  THEN -- TRATA DE VOLVER A CARGAR EL ARCHIVO
		
		LET cCodret = '333';
		LET cEstatuscarga = '1'; 
		
		LET cArchivresp= TRIM(cnombarcpar) || TRIM(vfecha_reg) || '.txt';
		LET cruta_archi=csol_Res_RutaArchivo;
		
	ELSE
	
		--------------Validar que el archivo exista en la ruta del servidor ---------------------------------------------
		--- BORRAR  LA TABLA DE TEMPORAL EN CASO DE QUE EXISTA
		IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'porta_tmp2') THEN
			DROP TABLE bdicheq:"informix".porta_tmp2;

		END IF
		
		--- CREAR LA TABLA DE TEMPORAL
		CREATE TABLE bdicheq:"informix".porta_tmp2 (linea CHAR(500));

		LET cSQL = '';
		--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
		LET cSQL = 'ls ' ||trim(cRutaArchivo)||' > '||trim(cRutaArchivo)||'carpeta.car';
		SYSTEM cSQL;

		LET cSQL = '';
		--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
		LET cSQL = 'echo " LOAD FROM '  ||trim(cRutaArchivo) || 'carpeta.car' || ' INSERT INTO porta_tmp2" > '|| trim(cRutaArchivo) || 'Temporal.sql';
		SYSTEM cSQL;

		LET cSQL = '';
		--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
		--Let cSQL = 'dbaccess bdicheq ' ||trim(cRutaArchivo)|| 'Temporal.sql';   --Se activa para desarrollo   
		LET cSQL = '/ifxsif01/bin/dbaccess bdicheq ' ||trim(cRutaArchivo)|| 'Temporal.sql'; 
		COMMIT WORK;
		SYSTEM cSQL;

		
		BEGIN WORK;
			--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
		FOREACH
			SELECT linea INTO cLinea FROM porta_tmp2
			IF cLinea = pNombreArchivo THEN
				LET cBandera = "T";
				EXIT FOREACH;
			END IF
		END FOREACH
		
			--- BORRAR LA TABLA TEMPORAL
		DROP TABLE porta_tmp2;
		
			--- VALIDA QUE EL ARCHIVO EXISTA
		IF cBandera = "F" THEN
			--LET cMensaje = 'El Archivo no Existe en la ruta parametrizada';
			LET cCodret = '191';
			LET cEstatuscarga = '1'; 
			LET pnombrearchivo= 'Codigo error 191'; 
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
			
			
		ELSE
		
			IF 	cod_oper IN ("20","21") THEN   ---  AQUI EMPEZARIA PARA CODIGO 20 Y 21
			
					-----------------------------------	
				--LIMPIAR LAS TABLAS TEMPORALES
				COMMIT WORK;
				
				BEGIN WORK;
				TRUNCATE TABLE sc_portaarchtemp;
				COMMIT WORK;
				
				BEGIN WORK;
				TRUNCATE TABLE sc_portacec_archivotemp;
				COMMIT WORK;
				
				BEGIN WORK;
				
					---------Se carga archivo ( LOAD)---------
				Let cSQL = '';
				Let  cSQL = 'echo "load from '||trim(cRutaArchivo) ||trim(pnombrearchivo)||
							' insert into sc_portaarchtemp(columna);" > ' ||trim(cRutaArchivo) || 'cargaarchivo.sql';
				System cSQL;
				Let cSQL = '';
				--Let cSQL = 'dbaccess bdicheq '||trim(cRutaArchivo) ||'cargaarchivo.sql';  --Se activa para desarrollo
                Let cSQL = '/ifxsif01/bin/dbaccess bdicheq '||trim(cRutaArchivo) ||'cargaarchivo.sql';   
				COMMIT WORK;
				System cSQL;
				BEGIN WORK;

       
                    -------------------LIMPIA LOS REGISTROS EN BLANCO ----------------------------------------
                    FOREACH WITH HOLD
					SELECT {+AVOID_FULL("informix".sc_portaarchtemp)} num_serial,columna INTO cNumSerial,cColumna FROM sc_portaarchtemp
						IF LENGTH(TRIM(cColumna))<=1 THEN
							DELETE FROM BDICHEQ:sc_portaarchtemp WHERE num_serial = cNumSerial AND columna = cColumna;
						END IF; 
					END FOREACH;					
					------------------------------------------------------------------------------------------	      			
							------------------VALIDACIONES SOBRE EL ARCHIVO----------------------
								--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
				IF EXISTS(SELECT {+AVOID_FULL("informix".sc_portaarchtemp)} columna FROM sc_portaarchtemp WHERE SUBSTR(columna,1,2) NOT IN ("01","02","09")) THEN
					--Existe un tipo de registro que no es autorizado
					LET cCodret = '175';
					LET cEstatuscarga = '1'; 
					LET pnombrearchivo= 'Codigo error 175'; 
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
						
				ELSE		

					--- VALIDA QUE EXISTAN LOS NUMEROS DE REGISTROS CORRESPONDIENTES
					LET iNumReg = 0;
					--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
					SELECT {+AVOID_FULL("informix".sc_portaarchtemp)} COUNT(*)::INTEGER INTO iNumReg FROM  sc_portaarchtemp WHERE SUBSTR(columna,1,2) = "01";
					IF iNumReg = 0 THEN
						--No Existe Encabezado en el archivo
						LET cCodret = '176';
						LET cEstatuscarga = '1'; 
						LET pnombrearchivo= 'Codigo error 176'; 
						--Obtener los mensajes de retorno 
						SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
							
					   --Existe mas de un Encabezado en el archivo	
					ELIF iNumReg > 1 THEN			
						LET cCodret = '177';
						LET cEstatuscarga = '1'; 
						LET pnombrearchivo= 'Codigo error 177'; 
						--Obtener los mensajes de retorno 
						SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
						
					ELSE

						LET iNumReg		= 0;
						--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
						SELECT {+AVOID_FULL("informix".sc_portaarchtemp)} COUNT(*)::INTEGER INTO iNumReg FROM  sc_portaarchtemp WHERE SUBSTR(columna,1,2) = "09";
						IF iNumReg = 0 THEN
							--No Existe Sumario en el archivo
							LET cCodret = '178';
							LET cEstatuscarga = '1'; 
							LET pnombrearchivo= 'Codigo error 178'; 
							--Obtener los mensajes de retorno 
							SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
							
						ELIF iNumReg > 1 THEN
							--Existe mas de un Sumario en el archivo
							LET cCodret = '179';
							LET cEstatuscarga = '1'; 
							LET pnombrearchivo= 'Codigo error 179'; 
							--Obtener los mensajes de retorno 
							SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
							
						ELSE
						 
							LET iNumReg		= 0;
							--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
							SELECT {+AVOID_FULL("informix".sc_portaarchtemp)} COUNT(*)::INTEGER INTO iNumReg FROM  sc_portaarchtemp WHERE SUBSTR(columna,1,2) = "02";
							IF iNumReg = 0 THEN
								--No Existe Detalle en el archivo
								LET cCodret = '180';
								LET cEstatuscarga = '1'; 
								LET pnombrearchivo= 'Codigo error 180'; 
								--Obtener los mensajes de retorno 
								SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
								
							ELSE

											
											FOREACH		
													
												SELECT {+AVOID_FULL("informix".sc_portaarchtemp)} columna INTO cRenglon FROM sc_portaarchtemp ORDER BY(num_serial)		

												--ASIGNACION DE VALORES A LAS VARIABLES
												IF SUBSTR(cRenglon,1,2) = "01" THEN --- ENCABEZADO		
													LET  cnum_secuencia = SUBSTR(cRenglon,3,7);
													LET  ccod_operacion = SUBSTR(cRenglon,10,2);
													LET  cbanco_rec = SUBSTR(cRenglon,12,5);	
													LET  csent_archi = SUBSTR(cRenglon,17,1);	
													LET  cfecha_presentacion = SUBSTR(cRenglon,18,8);
													
												
												
												ELIF  SUBSTR(cRenglon,1,2) = "02" THEN --- DETALLE
													LET isecuencia = SUBSTR(cRenglon,3,7);			
													LET ccod_ope   = SUBSTR(cRenglon,10,2);
													LET cfolio_solicitud = SUBSTR(cRenglon,12,30);
													LET cfecha_solicitud = SUBSTR(cRenglon,42,8);
													LET cnombre_cte  = SUBSTR(cRenglon,50,99);
													LET crfc_cte     = SUBSTR(cRenglon,149,13);
													LET ccta_receptora  = SUBSTR(cRenglon,162,18);
													LET ctipo_cta_receptora = SUBSTR(cRenglon,180,2);
													LET cbco_receptor = SUBSTR(cRenglon,182,5);
													LET ccta_ordenante = SUBSTR(cRenglon,187,18);
													LET ctipo_cta_ordenante = SUBSTR(cRenglon,205,2);
													LET cbco_ordenante = SUBSTR(cRenglon,207,5);
													LET cfecha_nacimiento = SUBSTR(cRenglon,212,8);
													LET crfc_empresa = SUBSTR(cRenglon,220,13);
													LET cestatus_respuesta = SUBSTR(cRenglon,233,2);
													LET cfecha_respuesta = SUBSTR(cRenglon,235,8);
													LET ccurp_cte = SUBSTR(cRenglon,243,18);

													
													IF  bdiprog:isnumeric(isecuencia) <> '1' 
															OR TRIM(ccod_ope) = '' OR (ccod_ope IS null)
															OR TRIM(cfolio_solicitud) = '' OR (cfolio_solicitud IS null)
															OR TRIM(cfecha_solicitud) = '' OR (cfecha_solicitud IS null) 
															OR TRIM(cnombre_cte) = '' OR (cnombre_cte IS null) 
															OR TRIM(crfc_cte) = '' OR (crfc_cte IS null) 
															OR TRIM(ccta_receptora) = '' OR (ccta_receptora IS null) 
															OR TRIM(ctipo_cta_receptora) = '' OR (ctipo_cta_receptora IS null)
															OR TRIM(cbco_receptor) = '' OR (cbco_receptor IS null) 
															OR TRIM(ccta_ordenante) = '' OR (ccta_ordenante IS null) 
															OR TRIM(ctipo_cta_ordenante) = ''  OR (ctipo_cta_ordenante IS null) 
															OR TRIM(cbco_ordenante) = ''  OR (cbco_ordenante IS null) 
															OR TRIM(cfecha_nacimiento) = ''  OR (cfecha_nacimiento IS null) 
															OR TRIM(crfc_empresa) = ''  OR (crfc_empresa IS null) 
															OR TRIM(cestatus_respuesta) = ''  OR (cestatus_respuesta IS null) 
															OR TRIM(cfecha_respuesta) = ''  OR (cfecha_respuesta IS null) 
															OR TRIM(ccurp_cte) = ''  OR (ccurp_cte IS null) 
															
															THEN
															--Error Un valor nULLOS En EL Archivo
															LET cCodret = '182';
															LET cEstatuscarga = '1'; 
															LET pnombrearchivo= 'Codigo error 182'; 
															--Obtener los mensajes de retorno 
															SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
															
													ELSE

					
															-- // INSERTA EN LA TABLA sc_portacec_archfolio registra por cada folio de solicitud la fecha de carga y nombre de archivo 
																		
																INSERT INTO sc_portacec_archfolio
																	   (fecha_carga, archivo, folio_solicitud)
																values (vfecha_reg,pnombrearchivo,cfolio_solicitud);				

								
												IF cod_oper= "20"   THEN	--  AQUI EMPIEZA CODIGO 20	
																	
														-- // RECOLECCION DE INFORMACION DE LA CUENTA (QUE EXISTA, ESTE ACTIVA, NO BLOQUEADA, NO PORTABILIDAD ACTIVA)

															select /*{+ INDEX(sc_portacec_solicitud idx_sc_portacec1)}*/  count(*)
															into numero_folios
															from sc_portacec_solicitud 
															where folio_solicitud=cfolio_solicitud;
																	
																
                                                            -- Validacion para folios duplicados.
															
															select  LIMIT 1 estatus_portabilidad
															into cporta_existe														
															from sc_portacec_solicitud 															
															where folio_solicitud = cfolio_solicitud
															AND estatus_portabilidad= '1' ;
																																										
															
													IF  numero_folios > 0    AND   cporta_existe = 1  THEN
															
															     let cestatus_respuesta= "06";
																 
																			INSERT INTO sc_portacec_archivotemp
																	   (secuencia,folio_solicitud, fecha_solicitud, nombre_cte, rfc_cte, cta_receptora, tipo_cta_receptora, bco_receptor, 
																	   cta_ordenante, tipo_cta_ordenante, bco_ordenante, fecha_nacimiento, rfc_empresa, estatus_respuesta, fecha_respuesta, curp_cte)
																		values (isecuencia,cfolio_solicitud,cfecha_solicitud,cnombre_cte,crfc_cte,ccta_receptora,ctipo_cta_receptora,cbco_receptor,
																		ccta_ordenante,ctipo_cta_ordenante,cbco_ordenante,cfecha_nacimiento,crfc_empresa,cestatus_respuesta,vfecha_reg,ccurp_cte);																

																			
													ELSE														
					
																			IF   numero_folios > 0  THEN												
																					
																				delete from sc_portacec_solicitud 
																				where empresa = pempresa and folio_solicitud = cfolio_solicitud;
																				
																			END IF

																																					
																	
																			INSERT INTO sc_portacec_archivotemp
																			(secuencia,folio_solicitud, fecha_solicitud, nombre_cte, rfc_cte, cta_receptora, tipo_cta_receptora, bco_receptor, 
																			cta_ordenante, tipo_cta_ordenante, bco_ordenante, fecha_nacimiento, rfc_empresa, estatus_respuesta, fecha_respuesta, curp_cte)
																			values (isecuencia,cfolio_solicitud,cfecha_solicitud,cnombre_cte,crfc_cte,ccta_receptora,ctipo_cta_receptora,cbco_receptor,
																			ccta_ordenante,ctipo_cta_ordenante,cbco_ordenante,cfecha_nacimiento,crfc_empresa,cestatus_respuesta,cfecha_respuesta,ccurp_cte);
																	
																			
                                                                         -- // obtiene la cuenta y la consulta en la tabla sc_maechq para verificar que exista
																	
			
																		  IF  (ctipo_cta_ordenante = 40)   THEN
			
																				let ccuenta = SUBSTR(ccta_ordenante,7,11);
																				LET Bandesap = 'V';   
																																									
																				select count(*)
																				into cvalidacuentaexis
																				from bdicheq: sc_maechq
																				where empresa = pempresa 
																				and  cuenta = ccuenta;
																							
																						
																							
																				select {+ INDEX(sc_maechq idx_sc_maechq3)}
																				status_cta,num_cte,motivo,sucursal
																				into cvalidaestatuscta,cnumcte,cmotivo,csucursal
																				from bdicheq: sc_maechq
																				where empresa = pempresa
																				and cuenta = ccuenta;

																			
																		   ELSE       		
																				
																				 LET Bandesap = 'V';   
																				
																				LET ccta_ordenante = SUBSTR(ccta_ordenante,3,16);
																				
																				select cuenta 
																				into  ccuenta													
																				from bdicheq: sc_tarjeta
																				where empresa = pempresa
																				and num_tarjeta = ccta_ordenante;
																				
																				select count(*)
																				into cvalidacuentaexis
																				from bdicheq: sc_maechq
																				where empresa = pempresa 
																				and  cuenta = ccuenta;
																							
																				select {+ INDEX(sc_maechq idx_sc_maechq3)}
																				status_cta,num_cte,motivo,sucursal
																				into cvalidaestatuscta,cnumcte,cmotivo,csucursal
																				from bdicheq: sc_maechq
																				where empresa = pempresa
																				and cuenta = ccuenta; 

																			END IF
				
																				 

																	
																			

																				IF cvalidacuentaexis= 0 THEN -- //CONDICION PARA VALIDAR QUE LA CUENTA EXISTA
																																		
																					select numcte
																					into cnumcte
																					from bdinteg:si_cliente
																					where rfc= crfc_cte;	

																						IF	TRIM(cnumcte) = '' OR (cnumcte IS null) THEN
																						let cnumcte='000000000';
																						END IF
																							
																						let Bandesap = 'F'; 
																					
																					
																					SELECT descripcion INTO cMensaje FROM bdicheq :sc_portacec_estatus_respuesta WHERE estatus_respuesta = '01';
																					let cestatusrespuestabcord ='01';

																							
																				ELSE   
																						
																					 IF 	cvalidaestatuscta = "2" OR cvalidaestatuscta = "6" OR cvalidaestatuscta = "7" OR cvalidaestatuscta = "8" THEN    --// CONDICION PARA VALIDAR QUE LA CUENTA NO ESTE CANCELADA
																						
																						SELECT descripcion INTO cMensaje FROM bdicheq :sc_portacec_estatus_respuesta WHERE estatus_respuesta = '02';
																						let cestatusrespuestabcord ='02';
																							
																					 ELSE	
																						
																						--// CONDICION PARA VALIDAR QUE LA CUENTA TENGA DEPOSITOS DE NOMINA

																					select {+INDEX(sc_movhis idx_movhisnew4)} limit 1 1
																					into cBandCta
																					from bdicheq: sc_movhis
																					where empresa = pempresa
																					and cuenta= ccuenta
																					and transacc in ('0287','0293');
																					
																																										
																						IF 		DBINFO("sqlca.sqlerrd2") = 0 THEN
																						   
																							let vhay = 0;																						
																							
																							select limit 1 1
																							into cBandCta
																							from bdicheq: sc_movhis_old
																							where empresa = pempresa
																							and cuenta= ccuenta
																							and transacc in ('0287','0293')
																							and  fech_alt between dtFechaVen and dFechaHoy;
																					

																								IF 		DBINFO("sqlca.sqlerrd2") = 0 THEN
																									--LET cCodret = '202';
																									SELECT descripcion INTO cMensaje FROM bdicheq :sc_portacec_estatus_respuesta WHERE estatus_respuesta = '04';
																									let cestatusrespuestabcord ='04';

																									let vhay = 0;
																								else
																								
																									let vhay = 1;
																									
																								END IF
																						
																						else
																							
																							let vhay = 1;	
																						
																						END IF

																						
																						IF (vhay =1) then

																							--// CONDICION PARA VALIDAR QUE LA CUENTA NO ESTE CON BLOQUE JUDICIAL O ADMINISTRATIVO
																				
																							IF  cvalidaestatuscta= "3" and  cmotivo IN('01','09')  THEN 
																							
																							
																							SELECT descripcion INTO cMensaje FROM bdicheq :sc_portacec_estatus_respuesta WHERE estatus_respuesta = '05';
																							let cestatusrespuestabcord ='05';
																								
																							ELSE   
																														
																								--// CONDICION PARA VALIDAR QUE LA CUENTA NO TENGA UNA PORTABILIDAD ACTIVA
																									LET cportact   = 0;
																									

																									select estatus_portabilidad
																									into cportact 
																									from sc_portacec_solicitud       
																									where cta_ordenante= ccta_ordenante
																									and estatus_portabilidad= '1' ;

																								IF  cportact = 1 THEN 
																																															
																									SELECT descripcion INTO cMensaje FROM bdicheq :sc_portacec_estatus_respuesta WHERE estatus_respuesta = '06';
																									let cestatusrespuestabcord ='06';
																								ELSE		
																									--// CONDICION PARA VALIDAR QUE LA COINCIDAN LAS FECHAS DE NACIMIENTO
																					
																									select YEAR(fecha_nac)||LPAD(MONTH(fecha_nac),2,0)||LPAD(DAY(fecha_nac),2,0)
																									into dtFecNac
																									from bdinteg:si_ctepf
																									where numcte= cnumcte;
																				
																									select fecha_nacimiento
																									into dtFecNac2
																									from bdicheq: sc_portacec_archivotemp
																									where folio_solicitud= cfolio_solicitud;
																										
																									IF	dtFecNac <> dtFecNac2 THEN
																										
																										SELECT descripcion INTO cMensaje FROM bdicheq :sc_portacec_estatus_respuesta WHERE estatus_respuesta = '03';
																										let cestatusrespuestabcord ='03';	
																									
																									ELSE																			
																										let cestatusrespuestabcord ='00';  	
																										LET cCodret = '000';
																									END IF	--// CONDICION PARA VALIDAR QUE LA COINCIDAN LAS FECHAS DE NACIMIENTO
																																					
																								END IF    --// CONDICION PARA VALIDAR QUE LA CUENTA NO TENGA UNA PORTABILIDAD ACTIVA
																						
																							END IF  --// CONDICION PARA VALIDAR QUE LA CUENTA NO ESTE CON BLOQUE JUDICIAL O ADMINISTRATIVO
																								
																						END IF  --// CONDICION PARA VALIDAR QUE LA CUENTA TENGA DEPOSITOS DE NOMINA
																							
																					END IF --VALIDACION QUE LA CUENTA NO ESTE CANCELADA
																							
																				END IF 	--VALIDACION QUE LA CUENTA EXISTA
																		
																		
																			-- // SI ESTATUS RESPUESTA ES  
																	
																				IF 	cestatusrespuestabcord = "00" THEN
																					LET psest_port = '1';   
																				ELSE
																					LET psest_port = '5';
																				END IF		

																					-- // SI PORTABILIDAD ES IGUAL A UNO EJECUTAR sp_portabprocesaalta
																				
																		
																					IF 	psest_port = "1" then          
																									
																									---####	 ejecucion del sp_portabprocesaalta  para insertar en la tabla  sc_portabilidadnomina
																											
																										--LET ccuenta_nor = SUBSTR(ccta_ordenante,7,11);
																										LET cban_rec_cor= SUBSTR(cbco_receptor,3,3);
																										EXECUTE PROCEDURE "informix".sp_portabprocesaalta("OTRO BANCO",csucursal,cnumcte,ccuenta,cban_rec_cor,ccta_receptora,"","15 y 30", "informix")
																										INTO CodigoRetorno,MensajeEjecucion;
																										
														
																									-- // SI CODIGO DE RETORNO ES EXITOSO MANDA MENSAJE DE APROBACION E INSERTA EN  TABLA sc_portabilidadnomina
																					
																									IF CodigoRetorno <> "00000"   THEN
																
																										-- // SI CODIGO DE RETORNO  NO ES EXITOSO MANDA MENSAJE DE DESAPROBACION 																		
																										SELECT descripcion INTO cMensaje FROM bdicheq :sc_portacec_estatus_respuesta WHERE estatus_respuesta = '01';
																										let cestatusrespuestabcord ='01';																																		
																										LET psest_port = '5';   

																									END IF		
																			
																					END IF--// CONDICION PARA VALIDAR SI ES PORTABILIDAD 1  			
																		
																		
																					-- // ACTUALIZAR LA SOLICITUD EN LA TABLA TEMPORAL LA FECHA_RESPUESTA Y ESTATUS_RESPUESTA
											
																								update sc_portacec_archivotemp
																								set estatus_respuesta= cestatusrespuestabcord,
																								fecha_respuesta= vfecha_reg
																								where folio_solicitud = cfolio_solicitud;	
																		
																		
																				IF  Bandesap = 'V'  THEN
																			
																									-- // INSERTAR LA SOLICITUD EN LA TABLA sc_portacec_solicitud 
																						

																											INSERT INTO sc_portacec_solicitud
																											(empresa, folio_solicitud, sucursal,num_cte, bco_ordenante, cta_ordenante, tipo_cta_ordenante, bco_receptor,cta_receptora, tipo_cta_receptora, fecha_solicitud, rfc_empresa, 
																											cod_operacion, fecha_presentacion, estatus_cecoban, fecha_estatus_cecoban, estatus_respuesta, fecha_respuesta, estatus_portabilidad, fecha_estatus_portabilidad, clave_origen, clave_sentido, num_intentos, user_insert, fecha_solca_portabilidad)
																											values('001',cfolio_solicitud,'',cnumcte,cbco_ordenante, ccta_ordenante,ctipo_cta_ordenante,cbco_receptor,ccta_receptora,ctipo_cta_receptora,cfecha_solicitud,crfc_empresa,
																											'21',cfecha_presentacion, '', '', cestatusrespuestabcord, vfecha_reg,psest_port,vfecha_reg,'3','1','1',"informix", '' );
																											LET cBanderaClaveOr3='V';

																							-- //  FORMATEO DE FECHA PARA EXECUTAR EL SP sp_obtener_10dias
																					
																							LET cfecha_solicitud10=(SUBSTR(cfecha_solicitud,5,2))||'/' ||(SUBSTR(cfecha_solicitud,7,2))||'/' ||(SUBSTR(cfecha_solicitud,1,4));
																							
							
																							EXECUTE PROCEDURE bdinteg:sp_obtener_10dias(cfecha_solicitud10)
																							INTO cCodRet10,dtFecha10;	
																																		
																							LET cfecha10_reg_even=(SUBSTR(dtFecha10,4,2))||'/' ||(SUBSTR(dtFecha10,1,2))||'/' ||(SUBSTR(dtFecha10,7,4)); 
																							
																							select {+AVOID_FULL(bdinteg:"informix".si_bancos)} vchrnombrecorto
																							into cbanconombre
																							from bdinteg:si_bancos
																							where cvecesif= cbco_receptor;
																						
																							LET cbanomb_esp = REPLACE(TRIM(cbanconombre),' ','+');

																						IF 	psest_port = "1" then   
																							
																									LET cta_rec_ast= TRIM(cencripta_tar)||(SUBSTR(ccta_receptora,15,4));
																									
																									--RQM 06 895. Fecha: 01-Jul-2024. Realizada por: Daniel Hernandez Garcia. Modificacion: Se integra el llamado al SP
																									--que realiza el llenado de una tabla con la que se controla la insercion de la notificacion de aceptacion de portabilidad de nomina
																									EXECUTE PROCEDURE sp_inserta_reg_contr_evid_notif_portab(cnumcte,cfolio_solicitud,cbanconombre,cta_rec_ast,ccta_ordenante,dtFecha10,'0') 
																									INTO codRetIn,mensajeRetIn;
																							
																									EXECUTE PROCEDURE bdimnsj:sp_registra_evento
																									('1','PORTACEC','NOM_AENOMINA',cnumcte,'','','2',cbanconombre,ccta_receptora,cfecha10_reg_even,'','','','','','','','','',1,0,0,0,0,'','')
																									INTO cCodRet_msj;
																								
																								
																									EXECUTE PROCEDURE bdimnsj:sp_registra_evento
																									('1','PORTACECSM','NOM_ASMSPO',cnumcte,'','','2',cbanconombre,ccta_receptora,cfecha10_reg_even,'',trim(curl_aprueba)||'&'||trim(cbanomb_esp)||'&'||trim(cta_rec_ast)||'&'||trim(cfecha10_reg_even),'','','','','','','',1,0,0,0,0,'','')
																									INTO cCodRet_msj;

																						ELSE	

																										EXECUTE PROCEDURE bdimnsj:sp_registra_evento
																										('1','PORTACEC','NOM_DENOMINA',cnumcte,'','','2',cbanconombre,'',cfecha_dmy,'',cMensaje,'','','','','','','',1,0,0,0,0,'','')
																										INTO cCodRet_msj;
																										
																										LET cMensaje_smsdes = REPLACE(TRIM(cMensaje),' ','+');
																										
																										EXECUTE PROCEDURE bdimnsj:sp_registra_evento
																										('1','PORTACECSM','NOM_DSMSPO',cnumcte,'','','2',cbanconombre,'',cfecha_dmy,'',trim(curl_desaprueba)||'&'||trim(cbanomb_esp)||'&'||trim(cfecha_dmy)||'&'||trim(cMensaje_smsdes),'','','','','','','',1,0,0,0,0,'','')
																										INTO cCodRet_msj;
																	
																								
																						END IF
															
                                                                                        IF cBanderaClaveOr3='V' THEN
																						    LET cnumcte = cnumcte;
                                                                                        --Validacion de Prestamo Directo de Nomina vigente 
                                                                                            SELECT p.num_cte, t.telefono,a.num_credito 
                                                                                            INTO vSMScte, vSMStel, vSMSnumcred
                                                                                            FROM BDICHEQ:sc_portacec_solicitud p
                                                                                            INNER JOIN BDINTEG:si_telefonos_actual t
                                                                                            ON p.num_cte=t.numcte 
                                                                                            INNER JOIN BDICRED:sd_maecredcrd mc
                                                                                            ON p.num_cte=mc.numcte
                                                                                            INNER JOIN bdicred:sd_ctascarg a
                                                                                            ON a.num_credito=mc.num_credito
                                                                                            --INNER JOIN bdicred:sd_maesdos ms
                                                                                            --ON mc.num_credito=ms.num_credito
                                                                                            WHERE p.clave_origen='3' AND p.estatus_portabilidad='1'
																							AND p.fecha_estatus_portabilidad = vfecha_reg
                                                                                            AND p.clave_sentido=1 AND t.tipo_tel=2 AND t.status_tel='A' --AND t.verificado='V' 
                                                                                            AND (mc.status_cred='AA' OR mc.status_cred='BA' OR mc.status_cred='BT'OR mc.status_cred='E1' OR mc.status_cred='E2'OR mc.status_cred='E3')
                                                                                            AND mc.num_producto='6400' AND p.num_cte=cnumcte;
                                                                                            
                                                                                            

                                                                                        --Validacion de Anticipo de Nomina Vigente
                                                                                            SELECT p.num_cte, t.telefono,a.num_solicitud 
                                                                                            INTO vSMScteAN, vSMStelAN, vSMSnumcredAN
                                                                                            FROM BDICHEQ:sc_portacec_solicitud p
                                                                                            INNER JOIN BDINTEG:si_telefonos_actual t
                                                                                            ON p.num_cte=t.numcte 
                                                                                            INNER JOIN BDICRED:sd_maecred mc
                                                                                            ON p.num_cte=mc.numcte
                                                                                            INNER JOIN bdisolic:ss_adn_solicitudcuenta a
                                                                                            ON a.num_solicitud=mc.num_credito
                                                                                            INNER JOIN bdicred:sd_maesdos ms
                                                                                            ON mc.num_credito=ms.num_credito
                                                                                            WHERE p.clave_origen='3' AND p.estatus_portabilidad='1'
																							AND p.fecha_estatus_portabilidad = vfecha_reg
                                                                                            AND p.clave_sentido=1 AND t.tipo_tel=2 AND t.status_tel='A' --AND t.verificado='V' 
                                                                                            AND (mc.status_cred='AA' OR mc.status_cred='BA' OR mc.status_cred='BT'OR mc.status_cred='E1' OR mc.status_cred='E2'OR mc.status_cred='E3')
                                                                                            AND mc.num_producto='7800' AND ms.sdo_cap_insoluto>0 AND p.num_cte=cnumcte;
                                                                                            
                                                                                            IF vSMStel<>'' AND vSMScteAN<>'' AND vSMScte<>'' THEN
                                                                                                EXECUTE PROCEDURE bdimnsj:sp_registra_evento
                                                                                                ('1','OFI_RECO_ANPDN', 'OFI_RECOAN_PDN',cnumcte, '','','2', '', '', '', '', '', '', '', '', '', '', '', vSMStel, 1, 0, 0, 0, 0,current,current)
                                                                                                INTO cCodRet_msj;
                                                                                            ELIF vSMStel<>'' AND vSMScte='' THEN 
                                                                                                    EXECUTE PROCEDURE bdimnsj:sp_registra_evento
                                                                                                    ('1','OFI_RECOSMS', 'OFI_RECOPDN',cnumcte, '','','2', '', '', '', '', '', '', '', '', '', '', '', vSMStel, 1, 0, 0, 0, 0,current,current)
                                                                                                    INTO cCodRet_msj;
                                                                                                
                                                                                            ELIF  vSMScteAN<>'' AND vSMStel='' THEN 
                                                                                                    EXECUTE PROCEDURE bdimnsj:sp_registra_evento
                                                                                                    ('1','OFI_RECOANSMS', 'OFI_RECOAN',cnumcte, '','','2', '', '', '', '', '', '', '', '', '', '', '', vSMStel, 1, 0, 0, 0, 0,current,current)
                                                                                                    INTO cCodRet_msj;
                                                                                            END IF
                                                                                        END IF 
																		
																				END IF -- CLIENTES EN '00000'
																		
																		
													END IF		-- VALIDACION PARA NO EXISTAN FOLIOS DUPLICADOS			

																									
												END IF    --  AQUI TERMINA CODIGO 20	

																			
															IF cod_oper= "21"   THEN	--  AQUI EMPIEZA CODIGO 21
															

																	IF 	cestatus_respuesta = "00" then
																		LET psest_port = "1";   
																	else
																		LET psest_port = "5";
																	END IF
																		
																		
																		INSERT INTO sc_portacec_archivotemp
																	(secuencia,folio_solicitud, fecha_solicitud, nombre_cte, rfc_cte, cta_receptora, tipo_cta_receptora, bco_receptor, 
																	cta_ordenante, tipo_cta_ordenante, bco_ordenante, fecha_nacimiento, rfc_empresa, estatus_respuesta, fecha_respuesta, curp_cte)
																	values (isecuencia,cfolio_solicitud,cfecha_solicitud,cnombre_cte,crfc_cte,ccta_receptora,ctipo_cta_receptora,cbco_receptor,
																	ccta_ordenante,ctipo_cta_ordenante,cbco_ordenante,cfecha_nacimiento,crfc_empresa,cestatus_respuesta,cfecha_respuesta,ccurp_cte);
																															
																		select count(*)
																		into cupd_folios
																		from sc_portacec_archivotemp 
																		where folio_solicitud= cfolio_solicitud;


																		IF  cupd_folios > 1  THEN

																			select  min(estatus_respuesta)
																			into cestatus_respuesta
																			from sc_portacec_archivotemp 
																			where folio_solicitud= cfolio_solicitud;
																			
																		END IF
											
                                                                             select  estatus_respuesta
																			into creproce_estatus_respuesta
																			from sc_portacec_solicitud
																			where folio_solicitud= cfolio_solicitud;
																		
																			
																			IF 	creproce_estatus_respuesta <> "00" then
																			
																				update sc_portacec_solicitud
																				set estatus_respuesta = cestatus_respuesta,
																				fecha_respuesta   = cfecha_respuesta,
																				estatus_portabilidad  = psest_port,      
																				fecha_estatus_portabilidad= vfecha_reg,
																				cod_operacion= cod_oper
																				where folio_solicitud = cfolio_solicitud;	
																				
																		    END IF 
																	
															--	###############  creacion de bitacora para  monitorear fecha de respuestas de otros bancos -- #######  	
																	
																   INSERT INTO  sc_portacec_bitacora_solicitudes (empresa,cta_receptora,tipo_cta_receptora,bco_receptor,cta_ordenante,tipo_cta_ordenante,bco_ordenante,folio_solicitud,fecha_proceso)
                                                                  values ('001', ccta_receptora,ctipo_cta_receptora,cbco_receptor,ccta_ordenante,ctipo_cta_ordenante,cbco_ordenante,cfolio_solicitud,vfecha_reg); 
                                                                  
																  
																  
						
															END IF			
															

													END IF--VALIDA VALORES DEL DETALLE


												ELIF 	SUBSTR(cRenglon,1,2) = "09" THEN       --- SUMARIO			
													LET cnumsecuencia =   SUBSTR(cRenglon,3,7);
													LET ccodoperacion =   SUBSTR(cRenglon,10,2); 
													LET itotalregistros = SUBSTR(cRenglon,12,7);
												
												END IF
											
											END FOREACH		
											
												-- // EJECUCION DEL SP QUE GENERA EL ARCHIVO 
																
														
											IF cod_oper= "20"   THEN			
														EXECUTE PROCEDURE "informix".sp_generarchivoresport(pfecha_reg,cnombarcpar)
														INTO cCodig_ret,Itotal_sol,cruta_archi,cArchivresp;		

														IF  cCodig_ret <> '000' THEN													  
															ROLLBACK WORK;
															LET ven_transacc = 0;
															let cCodret = '666';
															RETURN cCodret, cArchivresp, cruta_archi;
														END IF
											END IF
							
							
											
											--// NO EXISTEN  REGISTROS
										SELECT COUNT(*) INTO iRegistros 
										FROM sc_portacec_archivotemp;   
											
										IF iRegistros = 0 THEN
											LET cCodRet = '001';								
										END IF

							END IF --VALIDA DETALLE	
							
						END IF--VALIDA SUMARIO
						
					END IF	--VALIDA ENCABEZADO
							
			END IF	-- para codigo 20 y 21

		END IF -- VALIDA TIPOS DE REGISTROS
				
		END IF-- VALIDACION DEL ARCHIVO

		
	END IF -- VALIDA QUE EL ARCHIVO NO SE VUELVA A PROCESAR
		
	-- // INSERTAR EN LA TABLA  sc_portacec_bitacora_archivo LA BITACORA DEL PROCESO 
			
	INSERT INTO sc_portacec_bitacora_archivo
	(fecha_carga, fecha_presentacion, archivo, estatus_carga, total_registros)
	values(vfecha_reg,cfecha_presentacion,pnombrearchivo,cEstatuscarga,iRegistros); 
								
	COMMIT WORK;				
    LET ven_transacc = 0;
					
	RETURN cCodret, cArchivresp, cruta_archi;
	
END
END PROCEDURE  ;