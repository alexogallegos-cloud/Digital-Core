CREATE PROCEDURE "informix".sp_minds_diferencias_txt()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;
		  
--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(100);	
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE v_fecha_ant				DATE;
DEFINE v_fecha_hoy 				DATE;
DEFINE v_diff_captacion			INTEGER;
DEFINE v_diff_credito			INTEGER;
DEFINE v_sp_banca_nombre		CHAR(35);
DEFINE v_sp_credito_nombre		CHAR(35);
DEFINE v_maxid_captacion		INTEGER;
DEFINE v_maxid_credito			INTEGER;

--SE INICIALIZAN VARIABLES
LET v_sp_banca_nombre    = 'sp_mindsbancatradicional_diario';
LET v_sp_credito_nombre  = 'sp_mindscredito_diario';
BEGIN
	--CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = 'ERROR OBTENIENDO DIFRENCIAS TXT: ' || TRIM(ERROR_INFO);
		RETURN cod_ret, vmensaje;
    END EXCEPTION;

	--FECHA
	SELECT fecha_ant, fecha_hoy 
	INTO v_fecha_ant, v_fecha_hoy
	FROM bdinteg:si_fechas;
	
	--OBTENER ULTIMA EXTRACCION DE CAPTACION
	SELECT MAX(idlog)
	INTO v_maxid_captacion
	FROM tbl_logextraccion_minds
	WHERE rutina = v_sp_banca_nombre
	AND fechaejecucion = v_fecha_hoy;
	
	SELECT difftxt
	INTO v_diff_captacion
	FROM tbl_logextraccion_minds
	WHERE idlog = v_maxid_captacion;
	
	--OBTENER ULTIMA EXTRACCION DE CREDITO
	SELECT MAX(idlog)
	INTO v_maxid_credito
	FROM tbl_logextraccion_minds
	WHERE rutina = v_sp_credito_nombre
	AND fechaejecucion = v_fecha_hoy;
	
	SELECT difftxt
	INTO v_diff_credito
	FROM tbl_logextraccion_minds
	WHERE idlog = v_maxid_credito;
	
	--REVISAR SI EXISTEN DIFERENCIAS
	IF (v_diff_captacion <> 0 AND v_diff_captacion IS NOT NULL) OR (v_diff_credito <> 0 AND v_diff_credito IS NOT NULL) THEN
		LET cod_ret = '11111';
		LET vmensaje = 'DIFERENCIAS CAPTACION: ' || NVL(v_diff_captacion,'') || ', DIFERENCIAS CREDITO :' || NVL(v_diff_credito,'');
		RETURN cod_ret, vmensaje;
	END IF
	
	LET cod_ret = '00000';
	LET vmensaje = 'PROCESO EXITOSO';

	RETURN cod_ret, vmensaje;
END;
END PROCEDURE
DOCUMENT 
'AUTOR: Fernando Torres Soto',
'FECHA: 13/03/2023',
'DESCRIPCION: Revisa si las operaciones de captacion y credito se encuentran incompletas en los txt generados para el sistema MINDS',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_pld_chq_crg_xml(pperiodo CHAR(20))
RETURNING	 CHAR (08)	AS 	cod_ret
			,CHAR (120)	AS 	mensaje
			,DATETIME YEAR TO FRACTION(3) AS fecha_proceso			
			,char(020)	AS	periodo                 
			,char(006)	AS	cve_autoridad           
			,char(006)	AS	cve_entidad             
			,char(014)	AS	folio_consec_oper       
			,char(014)	AS	folio_prev_oper         
			,char(008)	AS	fecha_oper              
			,char(008)	AS	cve_sucursal            
			,char(018)	AS	numcheque               
			,char(003)	AS	cve_moneda              
			,char(017)	AS	monto_cheque            
			,char(017)	AS	monto_liq               
			,char(200)	AS	cve_banco_emisor        
			,char(002)	AS	cve_medio_liq           
			,char(018)	AS	cuenta_abono            
			,char(003)	AS	cve_moneda_liq          
			,char(060)	AS	nombres_pf              
			,char(060)	AS	apell_parterno_pf       
			,char(060)	AS	apell_materno_pf        
			,CHAR(008)  AS	fecha_nac_pf            
			,char(020)	AS	curp_pf                 
			,char(013)	AS	rfc_pf                  
			,char(002)	AS	cve_nacionalidad_pf     
			,char(007)	AS	cve_act_econ_pf         
			,char(060)	AS	razon_social_pm         
			,char(008)  AS	fecha_constitucion_pm   
			,char(013)	AS	rfc_pm                  
			,char(002)	AS	cve_nacionalidad_pm     
			,char(060)	AS	giro_pm                 
			,char(060)	AS	correo_elect_pm         
			,char(060)	AS	nombreapoderado_pm      
			,char(200)	AS	domicilio_unific        
			,char(060)	AS	ciudad_dom_unif         
			,char(060)	AS	colonia_dom_unif        
			,char(005)	AS	codpost_dom_unif        
			,char(002)	AS	cve_pais_telefono       
			,char(012)	AS	telefono				
			,char(006)	AS	extension		
			;

--variables de retorno
	DEFINE 	cod_ret					 CHAR(008);
	DEFINE	mensaje					 CHAR(120);
	DEFINE	vfecha_proceso			 DATETIME YEAR TO FRACTION(3);
	DEFINE	vperiodo                 char(020);
	DEFINE	vcve_autoridad           char(006);
	DEFINE	vcve_entidad             char(006);
	DEFINE	vfolio_consec_oper       char(014);
	DEFINE	vfolio_prev_oper         char(014);
	DEFINE	vfecha_oper              char(008);
	DEFINE	vcve_sucursal            char(008);
	DEFINE	vnumcheque               char(018);
	DEFINE	vcve_moneda              char(003);
	DEFINE	vmonto_cheque            char(017);
	DEFINE	vmonto_liq               char(017);
	DEFINE	vcve_banco_emisor        char(200);
	DEFINE	vcve_medio_liq           char(002);
	DEFINE	vcuenta_abono            char(018);
	DEFINE	vcve_moneda_liq          char(003);
	DEFINE	vnombres_pf              char(060);
	DEFINE	vapell_parterno_pf       char(060);
	DEFINE	vapell_materno_pf        char(060);
	DEFINE	vfecha_nac_pf            DATE	  ;
	DEFINE	vcurp_pf                 char(020);
	DEFINE	vrfc_pf                  char(013);
	DEFINE	vcve_nacionalidad_pf     char(002);
	DEFINE	vcve_act_econ_pf         char(007);
	DEFINE	vrazon_social_pm         char(060);
	DEFINE	vfecha_constitucion_pm   DATE	  ;
	DEFINE	vrfc_pm                  char(013);
	DEFINE	vcve_nacionalidad_pm     char(002);
	DEFINE	vgiro_pm                 char(060);
	DEFINE	vcorreo_elect_pm         char(060);
	DEFINE	vnombreapoderado_pm      char(060);
	DEFINE	vdomicilio_unific        char(200);
	DEFINE	vciudad_dom_unif         char(060);
	DEFINE	vcolonia_dom_unif        char(060);
	DEFINE	vcodpost_dom_unif        char(005);
	DEFINE	vcve_pais_telefono       char(002);
	DEFINE	vtelefono				 char(012);
	DEFINE	vextension		         char(006);


--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE	vpaso			INTEGER; 

	--SET DEBUG FILE TO "/tmp/mfinis/sp_pld_chq_crg_xml.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cod_ret = iSqlErr;
			LET mensaje = vErrorInfo;
			RETURN 	 cod_ret
					,'iIsamErr: '|| iIsamErr || 'vErrorInfo: sp_pld_chq_crg_xml ' || vErrorInfo || ' En paso: ' || vpaso 
					,"1900-01-01 12:01:01.001"
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,"19000101"
					,""
					,""
					,""
					,""
					,""
					,"19000101"
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
			;

		END IF;
	END EXCEPTION;


	LET vpaso					=	1;
	--inicilizacion de variables

	LET	cod_ret					=	"00000000";
	LET	mensaje					=	"PROCESO EXITOSO";
	LET	vfecha_proceso			=	"1900-01-01 12:01:01.001";
	LET	vperiodo                =	"";
	LET	vcve_autoridad          =   "";
	LET	vcve_entidad            =   "";
	LET	vfolio_consec_oper      =   "";
	LET	vfolio_prev_oper        =   "";
	LET	vfecha_oper             =   "";
	LET	vcve_sucursal           =   "";
	LET	vnumcheque              =   "";
	LET	vcve_moneda             =   "";
	LET	vmonto_cheque           =   "";
	LET	vmonto_liq              =   "";
	LET	vcve_banco_emisor       =   "";
	LET	vcve_medio_liq          =   "";
	LET	vcuenta_abono           =   "";
	LET	vcve_moneda_liq         =   "";
	LET	vnombres_pf             =   "";
	LET	vapell_parterno_pf      =   "";
	LET	vapell_materno_pf       =   "";
	LET	vfecha_nac_pf           =   "01/01/1900";
	LET	vcurp_pf                =   "";
	LET	vrfc_pf                 =   "";
	LET	vcve_nacionalidad_pf    =   "";
	LET	vcve_act_econ_pf        =   "";
	LET	vrazon_social_pm        =   "";
	LET	vfecha_constitucion_pm  =   "01/01/1900";
	LET	vrfc_pm                 =   "";
	LET	vcve_nacionalidad_pm    =   "";
	LET	vgiro_pm                =   "";
	LET	vcorreo_elect_pm        =   "";
	LET	vnombreapoderado_pm     =   "";
	LET	vdomicilio_unific       =   "";
	LET	vciudad_dom_unif        =   "";
	LET	vcolonia_dom_unif       =   "";
	LET	vcodpost_dom_unif       =   "";
	LET	vcve_pais_telefono      =   "";
	LET	vtelefono				=   "";
	LET	vextension		        =   "";
	
	SET ISOLATION TO DIRTY READ;
	LET vpaso					=	2;
	--se valida que exista informaciÃ³n del periodo a seleccionar
	IF (SELECT count(*) FROM tblpld_chqc_crg WHERE periodo = pperiodo) > 0 THEN
	LET vpaso					=	3;		
			FOREACH cur1 WITH HOLD FOR
				SELECT 	 fecha_proceso
						,periodo              
						,cve_autoridad        
						,cve_entidad          
						,folio_consec_oper    
						,folio_prev_oper      
						,fecha_oper           
						,cve_sucursal         
						,numcheque            
						,cve_moneda           
						,monto_cheque         
						,monto_liq            
						,cve_banco_emisor     
						,cve_medio_liq        
						,cuenta_abono
						,cve_moneda_liq       
						,fn_formateo_chqcajas(nombres_pf)
						,fn_formateo_chqcajas(apell_parterno_pf)
						,fn_formateo_chqcajas(apell_materno_pf)
						,fn_formateo_chqcajas(fecha_nac_pf)
						,curp_pf
						,rfc_pf               
						,cve_nacionalidad_pf  
						,cve_act_econ_pf
						,fn_formateo_chqcajas(razon_social_pm)
						,fn_formateo_chqcajas(fecha_constitucion_pm)
						,rfc_pm
						,cve_nacionalidad_pm  
						,giro_pm
						,correo_elect_pm
						,fn_formateo_chqcajas(nombreapoderado_pm)
						,fn_formateo_chqcajas(domicilio_unific)
						,fn_formateo_chqcajas(ciudad_dom_unif)
						,fn_formateo_chqcajas(colonia_dom_unif)
						,codpost_dom_unif     
						,cve_pais_telefono    
						,telefono			
						,extension	
						
				INTO	 vfecha_proceso			
				        ,vperiodo              
				        ,vcve_autoridad        
				        ,vcve_entidad          
				        ,vfolio_consec_oper    
				        ,vfolio_prev_oper      
				        ,vfecha_oper           
				        ,vcve_sucursal         
				        ,vnumcheque            
				        ,vcve_moneda           
				        ,vmonto_cheque         
				        ,vmonto_liq            
				        ,vcve_banco_emisor     
				        ,vcve_medio_liq        
				        ,vcuenta_abono         
				        ,vcve_moneda_liq       
				        ,vnombres_pf           
				        ,vapell_parterno_pf    
				        ,vapell_materno_pf     
				        ,vfecha_nac_pf        
				        ,vcurp_pf              
				        ,vrfc_pf               
				        ,vcve_nacionalidad_pf  
				        ,vcve_act_econ_pf      
				        ,vrazon_social_pm      
				        ,vfecha_constitucion_pm
				        ,vrfc_pm               
				        ,vcve_nacionalidad_pm  
				        ,vgiro_pm              
				        ,vcorreo_elect_pm      
				        ,vnombreapoderado_pm   
				        ,vdomicilio_unific     
				        ,vciudad_dom_unif      
				        ,vcolonia_dom_unif     
				        ,vcodpost_dom_unif     
				        ,vcve_pais_telefono    
				        ,vtelefono				
				        ,vextension		      
				
				FROM tblpld_chqc_crg 
				WHERE periodo = pperiodo
				
				IF vapell_parterno_pf IS NULL OR vapell_parterno_pf = "" THEN
					LET vapell_parterno_pf = 'XXXX';
				END IF;
				
				IF vapell_materno_pf IS NULL OR vapell_materno_pf = "" THEN
					LET vapell_materno_pf = 'XXXX';
				END IF;
				
				IF vcve_act_econ_pf IS NULL OR vcve_act_econ_pf = "" OR vcve_act_econ_pf = '0000000' OR vcve_act_econ_pf = '9999999' THEN
					LET vcve_act_econ_pf = '8429012';
				END IF;
				
				IF vdomicilio_unific IS NULL OR vdomicilio_unific = "" THEN
					LET vdomicilio_unific = 'SIN DOM';
				END IF;
			
				LET vpaso =	4;
				RETURN	 cod_ret, mensaje
						,vfecha_proceso
					    ,vperiodo
					    ,vcve_autoridad
					    ,vcve_entidad
					    ,vfolio_consec_oper
					    ,vfolio_prev_oper
					    ,vfecha_oper
					    ,vcve_sucursal         
					    ,vnumcheque            
					    ,vcve_moneda           
					    ,vmonto_cheque         
					    ,vmonto_liq
					    ,vcve_banco_emisor
					    ,vcve_medio_liq
					    ,vcuenta_abono
					    ,vcve_moneda_liq
					    ,vnombres_pf
					    ,vapell_parterno_pf
					    ,vapell_materno_pf
					    ,YEAR(vfecha_nac_pf)||LPAD(MONTH(vfecha_nac_pf),2,'0') ||LPAD(DAY(vfecha_nac_pf),2,'0') 
					    ,vcurp_pf
					    ,vrfc_pf
					    ,vcve_nacionalidad_pf
					    ,vcve_act_econ_pf
					    ,vrazon_social_pm   
					    ,YEAR(vfecha_constitucion_pm)||LPAD(MONTH(vfecha_constitucion_pm),2,'0') ||LPAD(DAY(vfecha_constitucion_pm),2,'0')   
					    ,vrfc_pm
					    ,vcve_nacionalidad_pm
					    ,vgiro_pm
					    ,vcorreo_elect_pm
					    ,vnombreapoderado_pm
					    ,vdomicilio_unific
					    ,vciudad_dom_unif
					    ,vcolonia_dom_unif
					    ,vcodpost_dom_unif
					    ,vcve_pais_telefono
					    ,NVL(vtelefono,'0000000000')
					    ,NVL(vextension,'0')
						 WITH RESUME;

			END FOREACH
	
		ELSE
			LET vpaso					=	5;
			RETURN	 "0000002"
					,"NO SE ENCONTRO INFORMACION DEL PERIODO"
					--,"1900-01-01 12:01"
					,"1900-01-01 12:01:01.001"
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,"19000101"
					,""
					,""
					,""
					,""
					,""
					,"19000101"
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,""
					,"";					
					
	END IF
			
END
END PROCEDURE 
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 31/03/2023',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: Se modifica procedimiento almacenado para definir el valor 8429012 en actividad economica';

CREATE PROCEDURE "informix".sp_pld_chqc_crg_dia(pfecha DATE, pproceso CHAR(20),pproducto CHAR(20) ,pcommit INTEGER, pprocesados INTEGER)
RETURNING 	CHAR(008) AS cod_ret,
			CHAR(220) AS mensaje;
			
--variables de retorno
	DEFINE	cod_ret						 CHAR(008);
	DEFINE	mensaje						 CHAR(220);

--variables de proceso
	DEFINE	vfecha_proceso				 DATETIME YEAR TO FRACTION(3) ;
	DEFINE	vperiodo                     char(020);
	DEFINE	vcve_autoridad               char(006);
	DEFINE	vcve_entidad                 char(006);
	DEFINE	vfolio_consec_oper           char(014);
	DEFINE	vfolio_prev_oper             char(014);
	DEFINE	vfecha_oper                  char(008);
	DEFINE	vcve_sucursal                char(008);
	DEFINE	vnumcheque                   char(018);
	DEFINE	vcve_moneda                  char(003);
	DEFINE	vmonto_cheque                char(017);
	DEFINE	vcve_banco_emisor            char(200);
	DEFINE	vcve_medio_liq               char(002);
	DEFINE	vcuenta_abono                char(018);
	DEFINE	vcve_moneda_liq              char(003);
	DEFINE	vmonto_liq                   char(017);
	DEFINE	vnombres_pf                  char(060);
	DEFINE	vapell_parterno_pf           char(060);
	DEFINE	vapell_materno_pf            char(060);
	DEFINE	vfecha_nac_pf                date     ;
	DEFINE	vcurp_pf                     char(020);
	DEFINE	vrfc_pf                      char(013);
	DEFINE	vcve_nacionalidad_pf         char(002);
	DEFINE	vcve_act_econ_pf             char(007);
	DEFINE	vrazon_social_pm             char(060);
	DEFINE	vfecha_constitucion_pm       date     ;
	DEFINE	vrfc_pm                      char(013);
	DEFINE	vcve_nacionalidad_pm         char(002);
	DEFINE	vgiro_pm                     char(060);
	DEFINE	vcorreo_elect_pm             char(060);
	DEFINE	vnombreapoderado_pm          char(060);
	DEFINE	vdomicilio_unific            char(200);
	DEFINE	vciudad_dom_unif             char(060);
	DEFINE	vcolonia_dom_unif            char(060);
	DEFINE	vcodpost_dom_unif            char(005);
	DEFINE	vcve_pais_telefono           char(002);
	DEFINE	vtelefono					 char(012);
	DEFINE	vextension					 char(006);
	DEFINE	cNumCliente					 char(020);	
		
-- variables auxiliares	
	DEFINE	vmes						 INTEGER;	
	DEFINE	vyear						 CHAR(004);
	DEFINE	vtipo_cambio				 money(16,2);
	
	DEFINE	vcount						 INTEGER;
	DEFINE	vprocesados					 INTEGER;
	DEFINE	vconsecutivo				 INTEGER;
	DEFINE	vanio_f					     INTEGER;
	DEFINE	vconsec_f					 INTEGER;
	
--variables de control de errores
	DEFINE	iSqlErr 					 INTEGER;
	DEFINE	iIsamErr					 INTEGER;
	DEFINE	vErrorInfo					 VARCHAR(80);
	DEFINE	vpaso						 INTEGER;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_pld_chqc_crg_dia.out';
	--TRACE ON;

BEGIN	

	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cod_ret = iSqlErr;
			LET mensaje = vErrorInfo;
			RETURN cod_ret, 'iIsamErr: '|| iIsamErr || 'vErrorInfo: sp_pld_chqc_crg_dia ' || vErrorInfo || ' En paso: ' || vpaso ;
		END IF;
	END EXCEPTION;

	
--inicializacion de variables

	LET cod_ret					=	'00000000';
	LET	mensaje					=	'PROCESO EXITOSO';
	LET	vfecha_proceso			=	'1900-01-01 01:01:01.001';
	LET	vperiodo                =	'';
	LET	vcve_autoridad          =	'';
	LET	vcve_entidad            =	'';
	LET	vfolio_consec_oper      =	'';
	LET	vfolio_prev_oper        =	'';
	LET	vfecha_oper             =	'01/01/1900';
	LET	vcve_sucursal           =	'';
	LET	vnumcheque              =	'';
	LET	vcve_moneda             =	'';
	LET	vmonto_cheque           =	'';
	LET	vcve_banco_emisor       =	'';
	LET	vcve_medio_liq          =	'';
	LET	vcuenta_abono           =	'';
	LET	vcve_moneda_liq         =	'';
	LET	vmonto_liq              =	'';
	LET	vnombres_pf             =	'';
	LET	vapell_parterno_pf      =	'';
	LET	vapell_materno_pf       =	'';
	LET	vfecha_nac_pf           =	'01/01/1900';
	LET	vcurp_pf                =	'';
	LET	vrfc_pf                 =	'';
	LET	vcve_nacionalidad_pf    =	'';
	LET	vcve_act_econ_pf        =	'';
	LET	vrazon_social_pm        =	'';
	LET	vfecha_constitucion_pm  =	'';
	LET	vrfc_pm                 =	'';
	LET	vcve_nacionalidad_pm    =	'';
	LET	vgiro_pm                =	'';
	LET	vcorreo_elect_pm        =	'';
	LET	vnombreapoderado_pm     =	'';
	LET	vdomicilio_unific       =	'';
	LET	vciudad_dom_unif        =	'';
	LET	vcolonia_dom_unif       =	'';
	LET	vcodpost_dom_unif       =	'';
	LET	vcve_pais_telefono      =	'';
	LET	vtelefono				=	'';
	LET	vextension				=	'';
	LET cNumCliente			= 	'';
	
	LET vfecha_proceso 			= 	pfecha;
	
	LET vcount					=	0;
	LET	vprocesados				=	0;
	
	LET vtipo_cambio			=	0;
	
	--Lectura sucia
	SET ISOLATION TO DIRTY READ;
	--
	LET	vpaso =	1;
	
	LET	vmes = MONTH(pfecha);
	LET vyear = YEAR(pfecha);
	--identificar el periodo
	IF vmes IN (1,2,3) THEN
		LET vperiodo = vyear ||'1';
	ELIF vmes IN (4,5,6) THEN
		LET vperiodo = vyear ||'2';
	ELIF vmes IN (7,8,9) THEN
		LET vperiodo = vyear ||'3';
	ELIF vmes IN (10,11,12) THEN
		LET vperiodo = vyear ||'4';
	END IF
	
	SET EXPLAIN ON;
	SET EXPLAIN FILE TO '/ifxsif01/Control-M/PRUEBA_SP_CRG_DIA.OUT';

	SET ISOLATION TO DIRTY READ;
	--se optienen los parametros de la tabla bdiauditor:param
	LET	vpaso =	2;
	
	SELECT valor INTO vcve_autoridad FROM bdiauditor:"informix".param WHERE llave = 'CVE_ORGANO_REGULADOR';
	SELECT valor INTO vcve_entidad FROM bdiauditor:"informix".param WHERE llave = 'CVE_ENTIDAD';
	SELECT valor INTO vfolio_consec_oper FROM bdiauditor:"informix".param WHERE llave = 'FOLIO_CONSEC_OPERAC';
	SELECT valor INTO vcve_moneda FROM bdiauditor:"informix".param WHERE llave = 'MONEDA_CHEQUES_CJA';
	SELECT valor INTO vcve_medio_liq FROM bdiauditor:"informix".param WHERE llave = 'CVE_MEDIO_LIQUIDA';
	SELECT valor INTO vtipo_cambio FROM bdiauditor:"informix".param WHERE llave = 'MNTO_TIPO_CAMBIO_USD';
	
	LET	vanio_f		=	trim(substr(trim(vfolio_consec_oper),0,4));
	LET	vconsec_f	=	trim(substr(trim(vfolio_consec_oper),6,14));
	
--	IF (SELECT inttransefe FROM bdiauditor:"informix".tblpldcontrol WHERE chrproceso = pproceso and chrproducto = pproducto)= 0  THEN
	
		LET vconsecutivo = vconsec_f;
/*	
	ELSE
		
		SELECT inttransefe INTO vconsecutivo FROM bdiauditor:"informix".tblpldcontrol WHERE chrproceso = pproceso and chrproducto = pproducto;
			

	END IF
*/	
	
	LET vcve_moneda_liq = vcve_moneda;
	LET	vpaso =	3;
		
	--extracion de la informacion
	SET ISOLATION TO DIRTY READ;
	
	FOREACH cur1 WITH HOLD FOR
	SELECT	skip pprocesados
			 YEAR(det.fecha_alta)||LPAD(MONTH(det.fecha_alta),2,'0') ||LPAD(DAY(det.fecha_alta),2,'0')
			,doc.sucursal
			,det.numcheque
			,det.monto			
			,(SELECT ban.casfim FROM bdinteg:si_bancos ban where ban.banco = det.cvebanco) as casfim /*ban.casfim,*/ 
			,doc.cuenta
			,det.monto
	INTO	 vfecha_oper
			,vcve_sucursal
			,vnumcheque
			,vmonto_cheque
			,vcve_banco_emisor
			,vcuenta_abono
			,vmonto_liq
	FROM	bditef:"informix".cce_cheques_det det
			join bdicheq:"informix".sc_docret_sbc doc on (det.numcheque = doc.num_chq and det.numcuenta = doc.numcuenta and det.monto = doc.monto_ori)
	WHERE	det.fecha_alta = pfecha
			and det.transaccion = '55'
			and (det.monto / (SELECT precio FROM bdiauditor:"informix".tipo_cambio tp WHERE tp.fecha_tc = det.fecha_alta -1 ) ) > vtipo_cambio
			and det.presentado = 1
			and doc.cancelado <> 'S'
	ORDER by doc.cuenta
			
		IF vcount = 0 THEN
		
			BEGIN WORK;
		
		END IF 
			
		LET	vpaso =	4;
		-- datos del cliente
		SELECT 	  DISTINCT 
			      chq.num_cte
				 ,UPPER(REPLACE(trim(cte.nombre1)||' '||trim(cte.nombre2),'Ñ','N'))
				 ,UPPER(REPLACE(trim(cte.apell_paterno),'Ñ','N'))
				 ,UPPER(REPLACE(trim(cte.apell_materno),'Ñ','N'))
				 ,pf.fecha_nac
				 ,UPPER(pf.curp)
				 ,UPPER(cte.rfc)
				 ,case cte.tpo_persona when '01' then ps_f.clave_pais else ps_m.clave_pais end as clave_pais -- pais de nacimiento del cliente
				 ,UPPER(REPLACE(trim(cte.razon_social),'Ñ','N'))
				 ,pm.fecha_constitct
				 ,UPPER(cte.rfc)
				 ,case cte.tpo_persona when '01' then ps_f.clave_pais else ps_m.clave_pais end as nacionalidad -- nacionalidad del cliente
				 ,act.casfim
				 ,UPPER(pm.emailpm)
				 ,UPPER(REPLACE(trim(apo.nombreapoderado),'Ñ','N'))
				 ,UPPER(REPLACE(trim(calle.nombrecalle),'Ñ','N') ||' No Ext. '|| trim(numeroextcalle) ||' No Int. '|| trim(numerointcalle) ||' '|| REPLACE(trim(ciu.nombreciudad),'Ñ','N') ||' Municipio. '|| REPLACE(trim(zona.municipiozona),'Ñ','N')) as domicilio_unif
				 ,UPPER(REPLACE(ciu.nombreciudad,'Ñ','N'))
				 ,UPPER(REPLACE(zona.nombrezona,'Ñ','N'))
				 ,dir.cod_postal
				 ,"MX"
				 ,tel.telefono
				 ,tel.extension
		INTO
				  cNumCliente
				 ,vnombres_pf       
		         ,vapell_parterno_pf
		         ,vapell_materno_pf 
		         ,vfecha_nac_pf     
		         ,vcurp_pf          
		         ,vrfc_pf           
				 ,vcve_nacionalidad_pf         
				 ,vrazon_social_pm        
				 ,vfecha_constitucion_pm  
				 ,vrfc_pm                 
				 ,vcve_nacionalidad_pm    
				 ,vgiro_pm                
				 ,vcorreo_elect_pm        
				 ,vnombreapoderado_pm     
				 ,vdomicilio_unific       
				 ,vciudad_dom_unif        
				 ,vcolonia_dom_unif       
				 ,vcodpost_dom_unif       
				 ,vcve_pais_telefono      
				 ,vtelefono				
				 ,vextension				
		FROM    bdicheq:"informix".sc_maechq  chq
				join bdinteg:"informix".si_cliente cte on chq.cuenta = vcuenta_abono and chq.num_cte = cte.numcte
				left outer join bdinteg:"informix".si_ctepf pf on (pf.numcte = cte.numcte)
				left outer join bdinteg:"informix".si_ctepm pm on (pm.numcte = cte.numcte)
                left outer join bdiauditor:"informix".si_paises_nacionalidades ps_f on (ps_f.nacion = pf.nacionalidad)
                left outer join bdiauditor:"informix".si_paises_nacionalidades ps_m on (ps_m.nacion = pm.nacionalidad)
				left outer join bdinteg:"informix".si_actecon act on (pm.giro = act.actividad)
				left outer join bdinteg:"informix".si_apoderado apo on (pm.numcte = apo.numcte)				
				left outer join bdinteg:"informix".si_direcciones_actual dir on (dir.numcte = cte.numcte and dir.tipo_dir = 1)
				left outer join bdinteg:"informix".si_catcalles calle on (calle.numerocalle = dir.numerocalle)
				left outer join bdinteg:"informix".si_catzonas zona on (zona.numerociudad = dir.numerociudad and zona.numerocolonia = dir.numerocolonia)
				left outer join bdinteg:"informix".si_catciudades ciu on (ciu.numerociudad = dir.numerociudad)
				left outer join bdinteg:"informix".si_telefonos_actual tel on (tel.numcte = cte.numcte and tel.tipo_tel = 1)     
				;
				
			LET cNumCliente = TRIM(cNumCliente);
			
			SELECT acts.idcnbv 
			INTO vcve_act_econ_pf 
			FROM bdinteg:si_bitacoraapertura bta 
			JOIN bdinteg:si_actsubact acts ON acts.id_act = bta.id_act AND acts.id_subact = bta.id_subact
			WHERE  bta.numcte = cNumCliente AND bta.id_secuencia = (SELECT MAX(id_secuencia) FROM bdinteg:si_bitacoraapertura WHERE numcte = cNumCliente AND id_pregunta = 6);

			IF vcve_act_econ_pf IS NULL OR vcve_act_econ_pf = '' OR vcve_act_econ_pf = '0000000' OR vcve_act_econ_pf = '9999999' THEN 
				LET vcve_act_econ_pf = '8429012';
			END IF;
			
			LET	vpaso =	5;
			INSERT INTO bdiauditor:"informix".tblpld_chqc_crg (	 
							 fecha_proceso			
							,periodo                		
							,cve_autoridad          
							,cve_entidad            
							,folio_consec_oper      
							,folio_prev_oper        
							,fecha_oper             
							,cve_sucursal           
							,numcheque              
							,cve_moneda             
							,monto_cheque           
							,monto_liq              
							,cve_banco_emisor       
							,cve_medio_liq          
							,cuenta_abono           
							,cve_moneda_liq         
							,nombres_pf             
							,apell_parterno_pf      
							,apell_materno_pf       
							,fecha_nac_pf           
							,curp_pf                
							,rfc_pf                 
							,cve_nacionalidad_pf    
							,cve_act_econ_pf        
							,razon_social_pm        
							,fecha_constitucion_pm  
							,rfc_pm                 
							,cve_nacionalidad_pm    
							,giro_pm                
							,correo_elect_pm        
							,nombreapoderado_pm     
							,domicilio_unific       
							,ciudad_dom_unif        
							,colonia_dom_unif       
							,codpost_dom_unif       
							,cve_pais_telefono      
							,telefono               
							,extension				
							)
							VALUES (
							 vfecha_proceso			
							,vperiodo                		
							,vcve_autoridad          
							,vcve_entidad            
							,vanio_f ||'-'|| vconsecutivo      
							,vanio_f ||'-'|| (vconsecutivo - 1)
							,vfecha_oper             
							,vcve_sucursal           
							,vnumcheque              
							,vcve_moneda             
							,vmonto_cheque           
							,vmonto_liq              
							,vcve_banco_emisor       
							,vcve_medio_liq          
							,vcuenta_abono           
							,vcve_moneda_liq         
							,vnombres_pf             
							,vapell_parterno_pf      
							,vapell_materno_pf       
							,vfecha_nac_pf           
							,vcurp_pf                
							,vrfc_pf                 
							,vcve_nacionalidad_pf    
							,vcve_act_econ_pf        
							,vrazon_social_pm        
							,vfecha_constitucion_pm  
							,vrfc_pm                 
							,vcve_nacionalidad_pm    
							,vgiro_pm                
							,vcorreo_elect_pm        
							,vnombreapoderado_pm     
							,vdomicilio_unific       
							,vciudad_dom_unif        
							,vcolonia_dom_unif       
							,vcodpost_dom_unif       
							,vcve_pais_telefono      
							,vtelefono               
							,vextension				
							
							);
							
		LET vcount = vcount + 1;
		LET vprocesados = vprocesados +1;
		LET vconsecutivo = vconsecutivo + 1; 
		
		
		IF vcount = pcommit THEN
		
			COMMIT WORK;
			
			LET vcount = 0;
		
			UPDATE bdiauditor:"informix".tblpldcontrol SET intregprocesados = vprocesados, inttransefe = nvl(vconsecutivo,0) WHERE chrproceso = pproceso and chrproducto = pproducto;
			
		END IF
		
	
	END FOREACH;
	
	IF vcount > 0 THEN
	
		COMMIT WORK;
		UPDATE bdiauditor:"informix".tblpldcontrol SET intregprocesados = vprocesados, inttransefe = nvl(vconsecutivo,0) WHERE chrproceso = pproceso and chrproducto = pproducto;		
		UPDATE bdiauditor:"informix".param SET valor = vanio_f || "-" || vconsecutivo WHERE llave = 'FOLIO_CONSEC_OPERAC'; 
	
	END IF
	
	
	RETURN cod_ret, mensaje;
END
END PROCEDURE 
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 31/03/2023',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: Se modifica procedimiento almacenado para definir el valor 8429012 en actividad economica',
'FECHA: 31/03/2023',
'AUTOR: Veronica Sanchez Tlacomulco',
'DESCRIPCION: Se modifica procedimiento almacenado para recuperar informacion del campo idcnbv de la tabla bdinteg:si_actsubact',
'FECHA: 18/04/2023',
'AUTOR: Veronica Sanchez Tlacomulco',
'DESCRIPCION: Se modifica procedimiento almacenado para geneser subconsulta para obtener informacion del campo idcnbv de la tabla bdinteg:si_actsubact';

CREATE PROCEDURE "informix".sp_ope_addfolio_xml(pNumcheque CHAR(18), pCuenta_abono CHAR(18), pPeriodo CHAR(20),pFolio CHAR(14))
	RETURNING CHAR(5) AS codret,
			CHAR(90) AS mensaje;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensaje CHAR(90);
	DEFINE cCodRetSp CHAR(8);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;	
	LET cMensaje = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cMensaje;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_addfolio_xml.out';
		--TRACE ON;
		
		IF pNumcheque = '' OR pCuenta_abono = '' OR pPeriodo = '' OR pFolio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cMensaje;
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		/*
		EXECUTE PROCEDURE bdiauditor:"informix".sp_pld_chq_addfolio_clon(pNumcheque, pCuenta_abono, pPeriodo, pFolio) 
		INTO cCodRetSp,cMensaje;
		*/
		
		LET cCodRetSp		= "00000000";
		LET	cMensaje		= "PROCESO EXITOSO";
		
		IF cCodRetSp::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdiauditor:sp_pld_chq_addfolio_clon';
		ELIF cCodRetSp::INTEGER > 0 THEN
			LET cCodRet = cCodRetSp;
		END IF;
		
		RETURN cCodRet,cMensaje;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 18/07/2022',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTE CHEQUES TXT',
'DESCRIPCION: SPL encargado de ejecutar el SP productivo bdiauditor:sp_pld_chq_addfolio encargado de realizar Â´la inserciÃ³n',
'del numero de folio sobre la informaciÃ³n a cargada anteriormente',
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 11/08/2022',
'DESCRIPCION: Se realiza mantenimiento a SPL para cambiar llamado a nuevo procedimiento almacenado.';

CREATE PROCEDURE "informix".sp_perfisica_listanegra( pRfc CHAR(13),
                                                     pNombre1 CHAR(26),
                                                     pNombre2 CHAR(26),
                                                     pApellPaterno CHAR(26),
                                                     pApellMaterno CHAR(26),
                                                     pFechaNac CHAR(8) )
RETURNING CHAR(5) AS codRet,
		  CHAR(50) AS mensaje,
		  CHAR(1) AS listaNegra,
		  CHAR(1) AS TipoLista;
    
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iExisteRfc INTEGER;
	DEFINE iExisteLis CHAR(1);
	DEFINE iExisteLisW CHAR(1);
	DEFINE TipoLista CHAR(1);
	DEFINE Mensaje CHAR(50);
	DEFINE listaNegra CHAR(1);
	DEFINE rfcint CHAR(13);
	DEFINE nombre CHAR(26);
	DEFINE vnombre2 CHAR(26);
	DEFINE apellidopto CHAR(26);
	DEFINE apellidomto CHAR(26);
	DEFINE fechanac CHAR(8);
	DEFINE firstname CHAR(50);
	DEFINE lastname CHAR(80);
	DEFINE fechanacFor CHAR(8);
	DEFINE anio CHAR(4);
	DEFINE mes CHAR(2);
	DEFINE dia CHAR(2);
	DEFINE pAnio CHAR(4);
	DEFINE pMes CHAR(2);
	DEFINE pDia CHAR(2);
	DEFINE wNombre1 CHAR(26);
	DEFINE wNombre2 CHAR(26);
	DEFINE wApellPaterno CHAR(26);
	DEFINE wApellMaterno CHAR(26);
	DEFINE wlast_name CHAR(60);
	DEFINE wfirst_name CHAR(60);
	
	LET cCodRet = '000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iExisteLis = 0;
	LET iExisteLisW = 0;
	LET TipoLista = 0;
	LET Mensaje = 'Sin coincidencia';
	LET listaNegra = 0;
	LET rfcint = '';
	LET nombre = '';
	LET vnombre2 = '';
	LET apellidopto = '';
	LET apellidomto = '';
	LET fechanac = '';
	LET firstname = '';
	LET lastname = '';
	LET anio = '';
	LET mes = '';
	LET dia = '';
	LET pAnio = '';
	LET pMes = '';
	LET pDia = '';
	
	LET	pAnio = SUBSTR(pRfc,5,2);
	LET pMes = SUBSTR(pRfc,7,2);
	LET pDia = SUBSTR(pRfc,9,2);
	
	LET wNombre1 = TRIM(pNombre1);
	LET wNombre2 = TRIM(pNombre2);
	LET wApellPaterno = TRIM(pApellPaterno);
	LET wApellMaterno = TRIM(pApellMaterno);
	LET wlast_name = wApellPaterno||' '||wApellMaterno;
	LET wfirst_name = wNombre1||' '||wNombre2;
	
	BEGIN
	
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN 
            LET cCodRet = iSqlErr;
            RETURN cCodRet,mensaje,listaNegra,tipoLista;
        END IF;
    END EXCEPTION;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
    --SET DEBUG FILE TO '/informix/jmss/sp_perfisica_listanegra.out';
    --TRACE ON;
    
    --- VALIDACION DE CAMPOS REQUERIDOS
    IF (pRfc IS NULL OR pRfc = '') THEN 
		LET cCodRet = '110';
		LET mensaje = 'Parametro pRfc vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	IF (pNombre1 IS NULL OR pNombre1= '') THEN
		LET cCodRet = '110';
		LET mensaje = 'Parametro Nombre vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	IF (pApellPaterno IS NULL OR pApellPaterno = '') THEN
	    LET cCodRet = '110';
		LET mensaje = 'Parametro Apellido Paterno vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	IF (pFechaNac IS NULL OR pFechaNac = '') THEN
	    LET cCodRet = '110';
		LET mensaje = 'Parametro Fecha Nacimiento vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	
	LET fechanacFor = SUBSTR(pFechaNac,3,2) || SUBSTR(pFechaNac,1,2) || SUBSTR(pFechaNac,5,4);

    --- VALIDA EN LISTAS NEGRA INTERNA
    SELECT trim(rfc),trim(nombre1),trim(nombre2),trim(apell_paterno),trim(apell_materno),to_char(fecha_nac,"%d%m%Y")
	  INTO rfcint,nombre,vnombre2,apellidopto,apellidomto,fechanac
      FROM bdiauditor:tbl_listainterna
     WHERE rfc = pRfc 
	   AND nombre1 = pNombre1
	   AND (apell_paterno = pApellPaterno OR nombre1 = pNombre1)
	   AND nombre2 = pNombre2
	   AND apell_paterno = pApellPaterno
	   AND apell_materno = pApellMaterno
	   AND (fecha_nac = fechanacFor OR nombre1 = pNombre1)
	   AND apell_paterno = pApellPaterno
	   AND fecha_nac = fechanacFor;
		
    --- VALIDA EN LISTAS NEGRAS EXTERNA
	FOREACH 
		SELECT trim(first_name),trim(last_name),SUBSTR(dob,3,2),SUBSTR(dob,6,2),SUBSTR(dob,9,2)
		  INTO firstname,lastname,anio,mes,dia
		  FROM "informix".worldcheck_compara
		 WHERE last_name = wlast_name
		   AND first_name = wfirst_name

		IF (dia = '00' OR dia = ' ' OR dia IS NULL) THEN
			CONTINUE FOREACH;
		ELSE
			EXIT FOREACH;
		END IF		
	END FOREACH


	/* ##################################################################################################################
	IF rfcint in ('MAPJ900922FZ3','AECS890507ME7','AAMR9307132F7','MUSJ9202012Y8','VAVA8204115T4','REOI721227FGA') THEN
		LET rfcint = ' ';
	END IF;
	################################################################################################################## */
	IF pNombre2 = '' and pApellMaterno = '' THEN
	--Checar claves 
		IF rfcint = pRfc and nombre = pNombre1 and apellidopto = pApellPaterno THEN
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF
		
	ELIF pNombre2 <> '' AND pApellMaterno = '' then
	--checar rfc hasta fechanacimiento omitir materno
		IF rfcint = pRfc and nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and fechanac = pFechaNac THEN
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF
		
	ELIF pApellMaterno <> '' and pNombre2 = '' then 
	--checar rfc hasta fechanacimiento omitir nombre2
		IF rfcint = pRfc and nombre = pNombre1 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and fechanac = pFechaNac THEN 
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF;
	ELSE 
	--checar todos los campos 
		IF rfcint = pRfc and nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and 
			fechanac = pFechaNac THEN 
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF;
	END IF;
		
	IF rfcint = '' THEN
		IF pNombre2 = '' and pApellMaterno = '' THEN
			--Checar claves 
			IF nombre = pNombre1 and apellidopto = pApellPaterno THEN
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF
		ELIF pNombre2 <> '' AND pApellMaterno = '' then
			--checar rfc hasta fechanacimiento omitir materno
			IF  nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and fechanac = pFechaNac THEN
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF
		ELIF pApellMaterno <> '' and pNombre2 = '' then 
			--checar rfc hasta fechanacimiento omitir nombre2
			IF nombre = pNombre1 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and fechanac = pFechaNac THEN 
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF;
		ELSE 
			--checar todos los campos 
			IF nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and 
				fechanac = pFechaNac THEN 
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF;
		END IF;
	END IF;
		
	--- VALIDA SI SE ENCUENTRE DADO DE ALTA EN LAS LISTAS EXTERNA
	IF (firstname = trim(pNombre1) ||' '|| trim(pNombre2) and lastname = trim (pApellPaterno)||' '||trim (pApellMaterno) and anio = pAnio and pMes = mes and pDia = dia) THEN
		LET listaNegra = 1;
		LET cCodRet = '211';
		LET tipoLista = 2;
		LET mensaje = '	Match Nombre y Fecha (PF) Lista Externa';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
	ELSE
		IF firstname = trim(pNombre1) ||' '|| trim(pNombre2) and lastname = trim (pApellPaterno)||' '||trim (pApellMaterno) THEN
			LET listaNegra = 1;
			LET cCodRet = '212';
			LET tipoLista = 2;
			LET mensaje = '	Match Nombre (PF) Lista Externa';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF;
	END IF;
	
	RETURN cCodRet,mensaje,listaNegra,tipoLista;
	
	END;
	    
END PROCEDURE
DOCUMENT 'AUTOR: Martha Gabriela Angulo Zazueta',
'FECHA: 30/06/2021',
'DESCRIPCION: SPL encargado de validar si se encuentra registrado en listas negras',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_perfisica_listanegra_exp( pRfc CHAR(13),
												pNombre1 CHAR(26),
												pNombre2 CHAR(26),
												pApellPaterno CHAR(26),
												pApellMaterno CHAR(26),
												pFechaNac CHAR(8) )
												
												
RETURNING CHAR(5) AS codRet,
		  CHAR(50) AS mensaje,
		  CHAR(1) AS listaNegra,
		  CHAR(1) AS TipoLista;
    
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iExisteRfc INTEGER;
	DEFINE iExisteLis CHAR(1);
	DEFINE iExisteLisW CHAR(1);
	DEFINE TipoLista CHAR(1);
	DEFINE Mensaje CHAR(50);
	DEFINE listaNegra CHAR(1);
	DEFINE rfcint CHAR(13);
	DEFINE nombre CHAR(26);
	DEFINE vnombre2 CHAR(26);
	DEFINE apellidopto CHAR(26);
	DEFINE apellidomto CHAR(26);
	DEFINE fechanac CHAR(8);
	DEFINE firstname CHAR(50);
	DEFINE lastname CHAR(80);
	DEFINE fechanacFor CHAR(8);
	DEFINE anio CHAR(4);
	DEFINE mes CHAR(2);
	DEFINE dia CHAR(2);
	DEFINE pAnio CHAR(4);
	DEFINE pMes CHAR(2);
	DEFINE pDia CHAR(2);
	DEFINE wNombre1 CHAR(26);
	DEFINE wNombre2 CHAR(26);
	DEFINE wApellPaterno CHAR(26);
	DEFINE wApellMaterno CHAR(26);
	DEFINE wlast_name CHAR(60);
	DEFINE wfirst_name CHAR(60);
	
	LET cCodRet = '000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iExisteLis = 0;
	LET iExisteLisW = 0;
	LET TipoLista = 0;
	LET Mensaje = 'Sin coincidencia';
	LET listaNegra = 0;
	LET rfcint = '';
	LET nombre = '';
	LET vnombre2 = '';
	LET apellidopto = '';
	LET apellidomto = '';
	LET fechanac = '';
	LET firstname = '';
	LET lastname = '';
	LET anio = '';
	LET mes = '';
	LET dia = '';
	LET pAnio = '';
	LET pMes = '';
	LET pDia = '';
	
	LET	pAnio = SUBSTR(pRfc,5,2);
	LET pMes = SUBSTR(pRfc,7,2);
	LET pDia = SUBSTR(pRfc,9,2);
	
	LET wNombre1 = TRIM(pNombre1);
	LET wNombre2 = TRIM(pNombre2);
	LET wApellPaterno = TRIM(pApellPaterno);
	LET wApellMaterno = TRIM(pApellMaterno);
	LET wlast_name = wApellPaterno||' '||wApellMaterno;
	LET wfirst_name = wNombre1||' '||wNombre2;
	
	BEGIN
	
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN 
            LET cCodRet = iSqlErr;
            RETURN cCodRet,mensaje,listaNegra,tipoLista;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/informix/jmss/sp_perfisica_listanegra.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- VALIDACION DE CAMPOS REQUERIDOS
    IF (pRfc IS NULL OR pRfc = '') THEN 
		LET cCodRet = '110';
		LET mensaje = 'Parametro pRfc vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	IF (pNombre1 IS NULL OR pNombre1= '') THEN
		LET cCodRet = '110';
		LET mensaje = 'Parametro Nombre vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	IF (pApellPaterno IS NULL OR pApellPaterno = '') THEN
	    LET cCodRet = '110';
		LET mensaje = 'Parametro Apellido Paterno vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	IF (pFechaNac IS NULL OR pFechaNac = '') THEN
	    LET cCodRet = '110';
		LET mensaje = 'Parametro Fecha Nacimiento vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	
	LET fechanacFor = SUBSTR(pFechaNac,3,2) || SUBSTR(pFechaNac,1,2) || SUBSTR(pFechaNac,5,4);

    --- VALIDA EN LISTAS NEGRA INTERNA
    SELECT trim(rfc),trim(nombre1),trim(nombre2),trim(apell_paterno),trim(apell_materno),to_char(fecha_nac,"%d%m%Y")
	INTO rfcint,nombre,vnombre2,apellidopto,apellidomto,fechanac
    FROM bdiauditor:tbl_listainterna
    WHERE rfc = pRfc 
	AND nombre1 = pNombre1
	AND apell_paterno = pApellPaterno
	OR nombre1 = pNombre1
	AND nombre2 = pNombre2
	AND apell_paterno = pApellPaterno
	AND apell_materno = pApellMaterno
	and fecha_nac = fechanacFor
	OR nombre1 = pNombre1
	AND apell_paterno = pApellPaterno
	AND fecha_nac = fechanacFor;
		
	
    --- VALIDA EN LISTAS NEGRAS EXTERNA
	FOREACH 
		SELECT trim(first_name),trim(last_name),SUBSTR(dob,3,2),
		SUBSTR(dob,6,2),SUBSTR(dob,9,2)
		INTO firstname,lastname,anio,mes,dia
		FROM bdiauditor:tblpld_worldcheck_compara
			WHERE  last_name = wlast_name
			AND first_name = wfirst_name
			
		IF (dia = '00' OR dia = " " OR dia IS NULL) THEN
			CONTINUE FOREACH;
		ELSE
			EXIT FOREACH;
		END IF		
	END FOREACH
	
	IF rfcint in ('MAPJ900922FZ3','AECS890507ME7','AAMR9307132F7','MUSJ9202012Y8','VAVA8204115T4','REOI721227FGA') THEN
	LET rfcint = ' ';
	END IF;
	
	IF pNombre2 = '' and pApellMaterno = '' THEN
	--Checar claves 
		IF rfcint = pRfc and nombre = pNombre1 and apellidopto = pApellPaterno THEN
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF
	
	ELIF pNombre2 <> '' AND pApellMaterno = '' then
	--checar rfc hasta fechanacimiento omitir materno
		IF rfcint = pRfc and nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and fechanac = pFechaNac THEN
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF
	
	
	ELIF pApellMaterno <> '' and pNombre2 = '' then 
	--checar rfc hasta fechanacimiento omitir nombre2
		IF rfcint = pRfc and nombre = pNombre1 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and fechanac = pFechaNac THEN 
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF;
		
	else 
	--checar todos los campos 
		IF rfcint = pRfc and nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and 
			fechanac = pFechaNac THEN 
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF;
	END IF;
	
	
	IF rfcint = '' THEN
		IF pNombre2 = '' and pApellMaterno = '' THEN
			--Checar claves 
			IF nombre = pNombre1 and apellidopto = pApellPaterno THEN
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF
		
		ELIF pNombre2 <> '' AND pApellMaterno = '' then
			--checar rfc hasta fechanacimiento omitir materno
			IF  nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and fechanac = pFechaNac THEN
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF
		
		ELIF pApellMaterno <> '' and pNombre2 = '' then 
			--checar rfc hasta fechanacimiento omitir nombre2
			IF nombre = pNombre1 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and fechanac = pFechaNac THEN 
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF;
			
		else 
			--checar todos los campos 
			IF nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and 
				fechanac = pFechaNac THEN 
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF;
		
		END IF;
	END IF;
	
	--- VALIDA SI SE ENCUENTRE DADO DE ALTA EN LAS LISTAS EXTERNA
    IF (firstname = trim(pNombre1) ||' '|| trim(pNombre2) and lastname = trim (pApellPaterno)||' '||trim (pApellMaterno)
		and anio = pAnio and pMes = mes and pDia = dia) THEN
		LET listaNegra = 1;
        LET cCodRet = '211';
		LET tipoLista = 2;
		LET mensaje = '	Match Nombre y Fecha (PF) Lista Externa';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
	ELSE
		IF firstname = trim(pNombre1) ||' '|| trim(pNombre2) and lastname = trim (pApellPaterno)||' '||trim (pApellMaterno) THEN
			LET listaNegra = 1;
			LET cCodRet = '212';
			LET tipoLista = 2;
			LET mensaje = '	Match Nombre (PF) Lista Externa';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF;
    END IF;
	
	RETURN cCodRet,mensaje,listaNegra,tipoLista;
	
	END;
	    
END PROCEDURE
DOCUMENT 'AUTOR: Martha Gabriela Angulo Zazueta',
'FECHA: 30/06/2021',
'DESCRIPCION: SPL encargado de validar si se encuentra registrado en listas negras',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_rpt_retirosatmextranjero()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;
		  
--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(100);	
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE v_fecha_ant				DATE;
DEFINE v_fecha_hoy 				DATE;
DEFINE v_fecha_ant_tc			DATE;
DEFINE vsql						CHAR(200);
DEFINE v_dolar        			MONEY(10,4);

-- LAYOUT REPORTE
DEFINE  vnumcte  				VARCHAR(10);
DEFINE	vnombre 				VARCHAR(50);
DEFINE	vcuenta 				VARCHAR(12);
DEFINE	vnum_tarjeta 			VARCHAR(16);
DEFINE	vfecha_nacimiento 		VARCHAR(10);
DEFINE	vedad 					SMALLINT;
DEFINE	vgenero 				VARCHAR(15);
DEFINE	vnacionalidad 			VARCHAR(15);
DEFINE	vestado_cliente 		VARCHAR(30);
DEFINE	vmunicipio_cliente 		VARCHAR(30);
DEFINE	vactividad_economica 	VARCHAR(120);
DEFINE	vfecha_aper_cuenta 		VARCHAR(10);
DEFINE	vsucursal_apertura 		VARCHAR(4);
DEFINE	vmunicipio_apertura 	VARCHAR(60);
DEFINE	vestado_apertura 		VARCHAR(30);
DEFINE	vnombre_beneficiario 	VARCHAR(250);
DEFINE	vparentesco_bene		VARCHAR(150);
DEFINE	vsaldo_cuenta 			MONEY(14,2);
DEFINE	vfecha_hora 			VARCHAR(20);
DEFINE	vmonto_usd 				MONEY(14,2);
DEFINE	vmonto_pesos 			MONEY(14,2);
DEFINE	vpais 					VARCHAR(20);
DEFINE	vnombre_atm 			VARCHAR(40);
DEFINE	vnumero_atm 			VARCHAR(16);

-- VARIABLES DE PASO
DEFINE vpaso 					INT;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vpfech_alt				DATE;
DEFINE vpfech_hora				DATETIME HOUR TO FRACTION(3);
DEFINE vpfecha_alta				DATE;
DEFINE vpnombre1				VARCHAR(20);
DEFINE vpnombre2				VARCHAR(20);
DEFINE vpapell_paterno			VARCHAR(20);
DEFINE vpapell_materno			VARCHAR(20);
DEFINE vpnombre1ben				VARCHAR(20);
DEFINE vpnombre2ben				VARCHAR(20);
DEFINE vpapell_paternoben		VARCHAR(20);
DEFINE vpapell_maternoben		VARCHAR(20);
DEFINE vpfecha_nac				DATE;
DEFINE vpmaxsecuenciadir		INT;
DEFINE vpmaxsecuenciaact		INT;
DEFINE vpmaxsecuenciben			SMALLINT;
DEFINE vpid_act					SMALLINT;
DEFINE vpid_subact				SMALLINT;
DEFINE vpsexo					CHAR(1);
DEFINE vrfc						VARCHAR(13);
DEFINE vpparen					CHAR(20);
DEFINE vpfolio_suc				CHAR(16);
DEFINE vppais 					VARCHAR(3);
DEFINE vppaiscount 				SMALLINT;
DEFINE vpcounben				SMALLINT;
DEFINE vpbensumporcentaje		SMALLINT;
DEFINE vpparentesco_bene		VARCHAR(20);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE NOMBRE_ARCHIVO			VARCHAR(50);
DEFINE cCodRetEdad              CHAR(5);
DEFINE cnomcteEdad              CHAR(104);
DEFINE vEdadCte	                SMALLINT;

--SE INICIALIZAN VARIABLES
LET vpaso = 0;

BEGIN
	--CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = 'ERROR GENERANDO REPORTE: ' || TRIM(ERROR_INFO) || ', EN PASO: ' || vpaso;
		RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/c90244910/ReporteATMInt/sp_rpt_retirosatmextranjero.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	--SET EXPLAIN ON;

	LET vpaso = 1;
	
	--FECHA DEL DIA ANTERIOR
	SELECT fecha_ant
	INTO v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET v_fecha_ant_tc = DATE(v_fecha_ant - 1 UNITS day);
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--FORMATO 'AAAAMMDD' FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET NOMBRE_ARCHIVO = 'rpt_retirosatmextranjero_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	TRUNCATE TABLE rpt_retirosatmextranjero_tmp;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD 
		-- RETIROS DE EFECTIVO INTERNACIONALES EN ATMS EN EL EXTRANJERO
		SELECT mov.cuenta, mov.num_tarjeta, mov.sdo_cuenta, mov.monto_tot, mov.fech_alt, 
		       mov.fech_hor, noc.fecha_alta, maechq.num_cte, maechq.sucursal, mov.folio_suc
		INTO   vcuenta, vnum_tarjeta, vsaldo_cuenta, vmonto_pesos, vpfech_alt, vpfech_hora, 
			   vpfecha_alta, vnumcte, vsucursal_apertura, vpfolio_suc 
		FROM bdicheq:sc_movhis mov
		JOIN bdicheq:sc_maechq maechq ON mov.cuenta = maechq.cuenta
		JOIN bdicheq:sc_maenoc noc ON maechq.cuenta = noc.cuenta
		WHERE mov.transacc = '0873' 
		AND mov.fech_alt = v_fecha_ant 
		AND mov.cancelad <> 'S'
		
		LET vfecha_hora = TRIM ( TRIM(TO_CHAR(vpfech_alt, "%d/%m/%Y")) || ' ' || TRIM(TO_CHAR(vpfech_hora, "%H:%M:%S")) );
		LET vfecha_aper_cuenta = TO_CHAR(vpfecha_alta, "%Y-%m-%d");
		
		LET vpaso = 5;
		-- DATOS DEL CLIENTE
		SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, ctpf.fecha_nac, ctpf.sexo,
		       TRIM(NVL(nac.descripcion,'')), cte.rfc
		INTO vpnombre1, vpnombre2, vpapell_paterno, vpapell_materno, vpfecha_nac, vpsexo, vnacionalidad,
		     vrfc
		FROM bdinteg:si_cliente cte
		LEFT JOIN bdinteg:si_ctepf ctpf ON cte.numcte = ctpf.numcte
		LEFT JOIN bdinteg:si_nacion nac ON ctpf.nacionalidad = nac.nacion
		WHERE cte.numcte = vnumcte;
		
		IF vpfecha_nac IS NOT NULL THEN
			LET vfecha_nacimiento = TO_CHAR(vpfecha_nac, "%Y-%m-%d");
		ELSE 
			LET vfecha_nacimiento = '';
		END IF;
		
		IF vpsexo IS NOT NULL AND vpsexo <> '' THEN	
			IF	vpsexo = 'M' THEN
				LET vgenero = 'MASCULINO';
			ELIF vpsexo = 'F' THEN
				LET vgenero = 'FEMENINO';
			ELSE
				LET vgenero = 'N/A';
			END IF;
		ELSE
			LET vgenero = '';
		END IF;
		
		LET vnombre = TRIM(NVL(vpnombre1, '')) || ' ' || TRIM(NVL(vpnombre2, '')) || ' ' || TRIM(NVL(vpapell_paterno, '')) || ' ' || TRIM(NVL(vpapell_materno, ''));
		
		--OBTENER EDAD DEL CLIENTE
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte('001', vnumcte) INTO cCodRetEdad, cnomcteEdad, vEdadCte;
				
		IF cCodRetEdad = '000' AND cCodRetEdad IS NOT NULL THEN
			LET vedad = vEdadCte;
		ELSE
			LET vedad = NULL;
		END IF;
		
		LET vpaso = 6;
		-- DIRECCION DEL CLIENTE
		SELECT MAX(secuencia)
		INTO vpmaxsecuenciadir
		FROM bdinteg:si_direcciones_actual 
		WHERE numcte = vnumcte
		AND tipo_dir = '1';
		
		SELECT TRIM(NVL(est.nombre, '')), TRIM(NVL(ctz.municipiozona, ''))
		INTO vestado_cliente, vmunicipio_cliente 
		FROM bdinteg:si_direcciones_actual dir
		LEFT JOIN bdinteg:si_estados est ON dir.estado::INTEGER = est.estado::INTEGER
		LEFT JOIN bdinteg:si_catzonas ctz ON dir.numerociudad = ctz.numerociudad AND dir.numerocolonia = ctz.numerocolonia
		WHERE dir.numcte = vnumcte
		AND dir.tipo_dir = '1'
		AND dir.secuencia = vpmaxsecuenciadir;
		
		LET vpaso = 7;
		-- ACTIVIDAD ECONOMICA
		SELECT NVL(MAX(id_secuencia),0)
		INTO vpmaxsecuenciaact
		FROM bdinteg:si_bitacoraapertura
		WHERE rfc = vrfc
		AND numcte = vnumcte 
		AND id_pregunta = 6;
		
		SELECT NVL(id_act,0), NVL(id_subact,0)
		INTO vpid_act, vpid_subact
		FROM bdinteg:si_bitacoraapertura
		WHERE rfc = vrfc
		AND numcte = vnumcte 
		AND id_pregunta = 6
		AND id_secuencia = vpmaxsecuenciaact;
		
		SELECT TRIM(NVL(descrip, ''))
		INTO vactividad_economica
		FROM bdinteg:si_actsubact
		WHERE id_act = vpid_act
		AND id_subact = vpid_subact;
		
		IF vactividad_economica = '' OR vactividad_economica IS NULL THEN
			LET vactividad_economica = 'Otros Servicios';
		END IF;
		
		LET vpaso = 8;
		-- SUCURSAL APERTURA CUENTA
		SELECT TRIM(NVL(ciu.nombre,'')), TRIM(NVL(est.nombre,''))
		INTO vmunicipio_apertura, vestado_apertura
		FROM bdinteg:si_sucursales suc
		LEFT JOIN bdinteg:si_ciudades ciu ON ciu.ciudad = suc.ciudad AND ciu.estado = suc.estado
		LEFT JOIN bdinteg:si_estados est ON suc.estado = est.estado
		WHERE suc.sucursal = vsucursal_apertura;
		
		LET vpaso = 9;
		-- BENEFICIARIO
		
		SELECT SUM(porcentaje), COUNT(*)
		INTO vpbensumporcentaje, vpcounben
		FROM bdicheq:sc_beneficiario
		WHERE cuenta = vcuenta;
		
		IF vpcounben > 1 AND vpbensumporcentaje = 100 THEN
		-- CASO MULTIPLES BENEFICIARIOS
		
			LET vnombre_beneficiario = '';
			LET vparentesco_bene = '';
			
			FOREACH WITH HOLD
				SELECT TRIM(NVL(paren.descripcion, '')), ben.parentesco, cteben.nombre1, cteben.nombre2, cteben.apell_paterno, cteben.apell_materno
				INTO vpparentesco_bene, vpparen, vpnombre1ben, vpnombre2ben, vpapell_paternoben, vpapell_maternoben
				FROM bdicheq:sc_beneficiario ben
				LEFT JOIN bdinteg:si_parentesco paren ON ben.parentesco = paren.parentesco
				LEFT JOIN bdinteg:si_cliente cteben ON ben.numcte = cteben.numcte
				WHERE ben.cuenta = vcuenta
				
				IF vpparentesco_bene = '' AND vpparen IS NOT NULL THEN
					LET vparentesco_bene = vparentesco_bene || TRIM(vpparen) || ', ';
				ELSE
					LET vparentesco_bene = vparentesco_bene || vpparentesco_bene || ', ';
				END IF;
				
				LET vnombre_beneficiario = vnombre_beneficiario || TRIM(NVL(vpnombre1ben, '')) || ' ' || TRIM(NVL(vpnombre2ben, '')) || ' ' || TRIM(NVL(vpapell_paternoben, '')) || ' ' || TRIM(NVL(vpapell_maternoben, '')) || ', ';
				
			END FOREACH;
		
		ELSE
			SELECT NVL(MAX(secuencia),0)
			INTO vpmaxsecuenciben
			FROM bdicheq:sc_beneficiario
			WHERE empresa = '001'
			AND cuenta = vcuenta;
			
			SELECT TRIM(NVL(paren.descripcion, '')), ben.parentesco, cteben.nombre1, cteben.nombre2, cteben.apell_paterno, cteben.apell_materno
			INTO vparentesco_bene, vpparen, vpnombre1ben, vpnombre2ben, vpapell_paternoben, vpapell_maternoben
			FROM bdicheq:sc_beneficiario ben
			LEFT JOIN bdinteg:si_parentesco paren ON ben.parentesco = paren.parentesco
			LEFT JOIN bdinteg:si_cliente cteben ON ben.numcte = cteben.numcte
			WHERE ben.empresa = '001'
			AND ben.cuenta = vcuenta
			AND ben.secuencia = vpmaxsecuenciben;
			
			IF vparentesco_bene = '' AND vpparen IS NOT NULL THEN
				LET vparentesco_bene = TRIM(vpparen);
			END IF;
		
			LET vnombre_beneficiario = TRIM(NVL(vpnombre1ben, '')) || ' ' || TRIM(NVL(vpnombre2ben, '')) || ' ' || TRIM(NVL(vpapell_paternoben, '')) || ' ' || TRIM(NVL(vpapell_maternoben, ''));
			
		END IF;
		
		
		LET vpaso = 10;
		-- INFORMACION CAJERO
		SELECT TRIM(NVL(pais,'')), TRIM(NVL(infreceptor,'')), TRIM(NVL(idterminal,''))
		INTO vppais, vnombre_atm, vnumero_atm
		FROM intercard:movimiento
		WHERE numtarjeta = vnum_tarjeta
		AND secuenciaextendida = SUBSTR(vpfolio_suc, 2, 15);
		
		LET vpaso = 11;
		-- NOMBRE PAIS
		SELECT COUNT(*)
		INTO vppaiscount
		FROM bdinteg:si_paises
		WHERE clave_pais = vppais;
		
		IF vppaiscount = 1 THEN
			SELECT TRIM(NVL(nombre,''))
			INTO vpais
			FROM bdinteg:si_paises
			WHERE clave_pais = vppais;
		ELSE
			LET vpais =  vppais;
		END IF;
		
		LET vpaso = 12;
		-- MONTO DLS
		SELECT LIMIT 1 precio
		INTO v_dolar
		FROM bdiauditor:tipo_cambio  --- SINONIMO
		WHERE empresa = '001'
		AND fecha_tc = v_fecha_ant_tc;
		
		LET vmonto_usd = vmonto_pesos / v_dolar;
		
		LET vpaso = 13;
		INSERT INTO rpt_retirosatmextranjero_tmp(cuenta, num_tarjeta, saldo_cuenta, monto_pesos, fecha_hora, fecha_aper_cuenta,
												 numcte, nombre, fecha_nacimiento, genero, nacionalidad, estado_cliente , municipio_cliente,
												 actividad_economica, sucursal_apertura, municipio_apertura, estado_apertura, parentesco_beneficiario,
												 nombre_beneficiario, pais, nombre_atm, numero_atm, edad, monto_usd)
		VALUES(vcuenta, vnum_tarjeta, vsaldo_cuenta, vmonto_pesos, vfecha_hora, vfecha_aper_cuenta, vnumcte, vnombre, vfecha_nacimiento,
		       vgenero, vnacionalidad, vestado_cliente, vmunicipio_cliente, vactividad_economica, vsucursal_apertura, vmunicipio_apertura,
			   vestado_apertura, vparentesco_bene, vnombre_beneficiario, vpais, vnombre_atm, vnumero_atm, vedad, vmonto_usd);
	
	END FOREACH;
	
	LET vpaso = 14;
	-- SE CREA SCRIPT
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'.txt SELECT * FROM bdiauditor:rpt_retirosatmextranjero_tmp;">'||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 15;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	
	LET vpaso = 16;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	
	
	LET cod_ret = '00000';
	LET vmensaje = 'PROCESO EXITOSO';

	RETURN cod_ret, vmensaje;
END;
END PROCEDURE
DOCUMENT 
'AUTOR: Fernando Torres Soto',
'FECHA: 18/05/2023',
'DESCRIPCION: Genera reporte de clientes que retiran efectivo de ATMs en el extranjero',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_carga_geolocalizacion()
RETURNING CHAR(5) AS CodRet,
          CHAR(180) AS mensaje;

-- DeclaraciÃ³n de variables
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(250);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(50);
DEFINE vconteo					INTEGER;
DEFINE v_fecha_oper 			DATE;
DEFINE v_folio 					CHAR(40);
DEFINE v_latitud 				CHAR(100);
DEFINE v_longitud 				CHAR(100);
DEFINE v_version 				CHAR(10);
DEFINE v_version_b 				CHAR(10);
DEFINE v_folio_suc 				CHAR(40); 
DEFINE v_referencia_23 			CHAR(23);
DEFINE vcount 					INTEGER;
DEFINE v_idoperacion 			CHAR(4);
DEFINE v_idregistro 			CHAR(7);

--VARIABLES DE PASO
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_menos_uno		DATE;
DEFINE v_fecha_str 				CHAR(10);


--SE INICIALIZAN VARIABLES
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_carga_geolocalizacion en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_carga_geolocalizacion');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
    --SET DEBUG FILE TO "/informix/c90307913/sp_carga_geolocalizacion.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA Y LA FECHA DEL DIA MENOS 1 DIA
	SELECT fecha_hoy, fecha_ant
	INTO v_fecha_hoy, v_fecha_menos_uno
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_menos_uno), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_menos_uno), 2, '0');
	LET cAno = YEAR(v_fecha_menos_uno);
	
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CTA	 = 'CargaGeoLocalizacion_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".bi_geolocalizacion_paso;
	COMMIT;
	
	
	LET vpaso = 4;
		
	
	LET vcount = 1;

	FOREACH WITH HOLD
		SELECT id_operacion, fecha_oper, folio, latitud, longitud, version, folio_suc, referencia_23, version_b
		INTO v_idoperacion, v_fecha_oper, v_folio, v_latitud, v_longitud, v_version, v_folio_suc, v_referencia_23, v_version_b
		FROM bdibpi:bi_geolocalizacion
		WHERE fecha_oper = v_fecha_menos_uno
		
		LET vpaso = 5;
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		LET v_idregistro = LPAD(vcount, 7, '0');

		INSERT INTO "informix".bi_geolocalizacion_paso (id_registro, id_operacion, fecha_oper, folio, latitud, longitud, version, version_b, folio_suc, referencia_23, fecha_registro)	
		VALUES(v_idregistro, v_idoperacion, v_fecha_oper, v_folio, v_latitud, v_longitud, v_version, v_version_b, v_folio_suc, v_referencia_23, v_fecha_menos_uno);
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;
		END IF

		LET vcount =  vcount + 1;
	
	END FOREACH
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF


	LET vpaso = 6;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * from bdiauditor:bi_geolocalizacion_paso;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 7;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 8;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 9;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_carga_geolocalizacion');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE

DOCUMENT 'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 18/09/2023',
'DESCRIPCION: GeneraciÃ³n de informaciÃ³n geolocalizacion para sistemas MINDS PLD',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_rpt_retirosatmextranjero_cred()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;
		  
--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(100);	
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE v_fecha_ant				DATE;
DEFINE v_fecha_ant_tc			DATE;
DEFINE vsql						CHAR(250);
DEFINE v_dolar        			MONEY(10,4);

-- LAYOUT REPORTE
DEFINE  vnumcte  				VARCHAR(10);
DEFINE	vnombre 				VARCHAR(50);
DEFINE	vcuenta 				VARCHAR(12);
DEFINE	vnum_tarjeta 			VARCHAR(16);
DEFINE	vfecha_nacimiento 		VARCHAR(10);
DEFINE	vedad 					SMALLINT;
DEFINE	vgenero 				VARCHAR(15);
DEFINE	vnacionalidad 			VARCHAR(15);
DEFINE	vestado_cliente 		VARCHAR(30);
DEFINE	vmunicipio_cliente 		VARCHAR(30);
DEFINE	vactividad_economica 	VARCHAR(120);
DEFINE	vfecha_aper_cuenta 		VARCHAR(10);
DEFINE	vsucursal_apertura 		VARCHAR(4);
DEFINE	vmunicipio_apertura 	VARCHAR(60);
DEFINE	vestado_apertura 		VARCHAR(30);
DEFINE	vfecha_hora 			VARCHAR(20);
DEFINE	vmonto_usd 				MONEY(14,2);
DEFINE	vmonto_pesos 			MONEY(14,2);
DEFINE	vpais 					VARCHAR(20);
DEFINE	vnombre_atm 			VARCHAR(40);
DEFINE	vnumero_atm 			VARCHAR(16);

-- VARIABLES DE PASO
DEFINE vpaso 					INT;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vpfech_alt				DATE;
DEFINE vpfech_hora				DATETIME HOUR TO FRACTION(3);
DEFINE vpfecha_mov				DATE;
DEFINE vpnombre1				VARCHAR(20);
DEFINE vpnombre2				VARCHAR(20);
DEFINE vpapell_paterno			VARCHAR(20);
DEFINE vpapell_materno			VARCHAR(20);
DEFINE vpnombre1ben				VARCHAR(20);
DEFINE vpnombre2ben				VARCHAR(20);
DEFINE vpapell_paternoben		VARCHAR(20);
DEFINE vpapell_maternoben		VARCHAR(20);
DEFINE vpfecha_nac				DATE;
DEFINE vpmaxsecuenciadir		INT;
DEFINE vpmaxsecuenciaact		INT;
DEFINE vpmaxsecuenciben			SMALLINT;
DEFINE vpid_act					SMALLINT;
DEFINE vpid_subact				SMALLINT;
DEFINE vpsexo					CHAR(1);
DEFINE vrfc						VARCHAR(13);
DEFINE vpfolio_suc				CHAR(16);
DEFINE vppais 					VARCHAR(3);
DEFINE vppaiscount 				SMALLINT;
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE NOMBRE_ARCHIVO			VARCHAR(100);
DEFINE cCodRetEdad              CHAR(5);
DEFINE cnomcteEdad              CHAR(104);
DEFINE vEdadCte	                SMALLINT;

--SE INICIALIZAN VARIABLES
LET vpaso = 0;

BEGIN
	--CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = 'ERROR GENERANDO REPORTE: ' || TRIM(ERROR_INFO) || ', EN PASO: ' || vpaso;
		RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/c90307913/sp_rpt_retirosatmextranjero_cred.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	--SET EXPLAIN ON;

	LET vpaso = 1;
	
	--FECHA DEL DIA ANTERIOR
	SELECT fecha_ant
	INTO v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET v_fecha_ant_tc = DATE(v_fecha_ant - 1 UNITS day);
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--FORMATO 'AAAAMMDD' FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET NOMBRE_ARCHIVO = 'rpt_retirosatmextranjero_cred_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	TRUNCATE TABLE rpt_retirosatmextranjero_cred_tmp;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD 
		-- RETIROS DE EFECTIVO INTERNACIONALES EN ATMS EN EL EXTRANJERO
		SELECT  mov.num_credito, mov.nro_tarjeta, mov.monto, mov.fecha_mov, mov.hora_mov, maecred.numcte, maecred.sucursal, mov.folio_suc
  		INTO   vcuenta, vnum_tarjeta, vmonto_pesos, vpfecha_mov, vpfech_hora, vnumcte, vsucursal_apertura, vpfolio_suc 
        FROM bdicred:sd_movhis mov
        JOIN bdicred:sd_maecred maecred ON mov.num_credito = maecred.num_credito
        JOIN bdicred:sd_maecredanexo crd ON maecred.num_credito = crd.num_credito
        WHERE mov.codigo_fun = '002'
		AND mov.codigo_ref = 42 
        AND mov.fecha_mov = v_fecha_ant
        AND mov.reversado <> 'S'
		
		LET vfecha_hora = TRIM ( TRIM(TO_CHAR(vpfecha_mov, "%d/%m/%Y")) || ' ' || TRIM(TO_CHAR(vpfech_hora, "%H:%M:%S")) );
		LET vfecha_aper_cuenta = TO_CHAR(vpfecha_mov, "%Y-%m-%d");
		
		LET vpaso = 5;
		-- DATOS DEL CLIENTE
		SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, ctpf.fecha_nac, ctpf.sexo,
		       TRIM(NVL(nac.descripcion,'')), cte.rfc
		INTO vpnombre1, vpnombre2, vpapell_paterno, vpapell_materno, vpfecha_nac, vpsexo, vnacionalidad,
		     vrfc
		FROM bdinteg:si_cliente cte
		LEFT JOIN bdinteg:si_ctepf ctpf ON cte.numcte = ctpf.numcte
		LEFT JOIN bdinteg:si_nacion nac ON ctpf.nacionalidad = nac.nacion
		WHERE cte.numcte = vnumcte;
		
		IF vpfecha_nac IS NOT NULL THEN
			LET vfecha_nacimiento = TO_CHAR(vpfecha_nac, "%Y-%m-%d");
		ELSE 
			LET vfecha_nacimiento = '';
		END IF;
		
		IF vpsexo IS NOT NULL AND vpsexo <> '' THEN	
			IF	vpsexo = 'M' THEN
				LET vgenero = 'MASCULINO';
			ELIF vpsexo = 'F' THEN
				LET vgenero = 'FEMENINO';
			ELSE
				LET vgenero = 'N/A';
			END IF;
		ELSE
			LET vgenero = '';
		END IF;
		
		LET vnombre = TRIM(NVL(vpnombre1, '')) || ' ' || TRIM(NVL(vpnombre2, '')) || ' ' || TRIM(NVL(vpapell_paterno, '')) || ' ' || TRIM(NVL(vpapell_materno, ''));
		
		--OBTENER EDAD DEL CLIENTE
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte('001', vnumcte) INTO cCodRetEdad, cnomcteEdad, vEdadCte;
				
		IF cCodRetEdad = '000' AND cCodRetEdad IS NOT NULL THEN
			LET vedad = vEdadCte;
		ELSE
			LET vedad = NULL;
		END IF;
		
		LET vpaso = 6;
		-- DIRECCION DEL CLIENTE
		SELECT MAX(secuencia)
		INTO vpmaxsecuenciadir
		FROM bdinteg:si_direcciones_actual 
		WHERE numcte = vnumcte
		AND tipo_dir = '1';
		
		SELECT TRIM(NVL(est.nombre, '')), TRIM(NVL(ctz.municipiozona, ''))
		INTO vestado_cliente, vmunicipio_cliente 
		FROM bdinteg:si_direcciones_actual dir
		LEFT JOIN bdinteg:si_estados est ON dir.estado::INTEGER = est.estado::INTEGER
		LEFT JOIN bdinteg:si_catzonas ctz ON dir.numerociudad = ctz.numerociudad AND dir.numerocolonia = ctz.numerocolonia
		WHERE dir.numcte = vnumcte
		AND dir.tipo_dir = '1'
		AND dir.secuencia = vpmaxsecuenciadir;
		
		LET vpaso = 7;
		-- ACTIVIDAD ECONOMICA
		SELECT NVL(MAX(id_secuencia),0)
		INTO vpmaxsecuenciaact
		FROM bdinteg:si_bitacoraapertura
		WHERE rfc = vrfc
		AND numcte = vnumcte 
		AND id_pregunta = 6;
		
		SELECT NVL(id_act,0), NVL(id_subact,0)
		INTO vpid_act, vpid_subact
		FROM bdinteg:si_bitacoraapertura
		WHERE rfc = vrfc
		AND numcte = vnumcte 
		AND id_pregunta = 6
		AND id_secuencia = vpmaxsecuenciaact;
		
		SELECT TRIM(NVL(descrip, ''))
		INTO vactividad_economica
		FROM bdinteg:si_actsubact
		WHERE id_act = vpid_act
		AND id_subact = vpid_subact;
		
		IF vactividad_economica = '' OR vactividad_economica IS NULL THEN
			LET vactividad_economica = 'Otros Servicios';
		END IF;
		
		LET vpaso = 8;
		-- SUCURSAL APERTURA CUENTA
		SELECT TRIM(NVL(ciu.nombre,'')), TRIM(NVL(est.nombre,''))
		INTO vmunicipio_apertura, vestado_apertura
		FROM bdinteg:si_sucursales suc
		LEFT JOIN bdinteg:si_ciudades ciu ON ciu.ciudad = suc.ciudad AND ciu.estado = suc.estado
		LEFT JOIN bdinteg:si_estados est ON suc.estado = est.estado
		WHERE suc.sucursal = vsucursal_apertura;
		
		LET vpaso = 9;
		-- INFORMACION CAJERO
		SELECT TRIM(NVL(pais,'')), TRIM(NVL(infreceptor,'')), TRIM(NVL(idterminal,''))
		INTO vppais, vnombre_atm, vnumero_atm
		FROM intercard:movimiento
		WHERE numtarjeta = vnum_tarjeta
		AND secuenciaextendida = SUBSTR(vpfolio_suc, 2, 15);
		
		LET vpaso = 10;
		-- NOMBRE PAIS
		SELECT COUNT(*)
		INTO vppaiscount
		FROM bdinteg:si_paises
		WHERE clave_pais = vppais;
		
		IF vppaiscount = 1 THEN
			SELECT TRIM(NVL(nombre,''))
			INTO vpais
			FROM bdinteg:si_paises
			WHERE clave_pais = vppais;
		ELSE
			LET vpais =  vppais;
		END IF;
		
		LET vpaso = 11;
		-- MONTO DLS
		SELECT LIMIT 1 precio
		INTO v_dolar
		FROM bdiauditor:tipo_cambio  --- SINONIMO
		WHERE empresa = '001'
		AND fecha_tc = v_fecha_ant_tc;
		
		LET vmonto_usd = vmonto_pesos / v_dolar;
		
		LET vpaso = 12;
		INSERT INTO rpt_retirosatmextranjero_cred_tmp(cuenta, num_tarjeta, monto_pesos, monto_usd, fecha_hora, fecha_aper_cuenta,
												 numcte, nombre, fecha_nacimiento, genero, nacionalidad, estado_cliente , municipio_cliente,
												 actividad_economica, sucursal_apertura, municipio_apertura, estado_apertura,
												 pais, nombre_atm, numero_atm, edad)
		VALUES(vcuenta, vnum_tarjeta, vmonto_pesos, vmonto_usd, vfecha_hora, vfecha_aper_cuenta, vnumcte, vnombre, vfecha_nacimiento,
		       vgenero, vnacionalidad, vestado_cliente, vmunicipio_cliente, vactividad_economica, vsucursal_apertura, vmunicipio_apertura,
			   vestado_apertura, vpais, vnombre_atm, vnumero_atm, vedad);
	
	END FOREACH;
	
	LET vpaso = 13;
	-- SE CREA SCRIPT
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'.txt SELECT * FROM bdiauditor:rpt_retirosatmextranjero_cred_tmp;">'||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 14;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	
	LET vpaso = 15;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	
	
	LET cod_ret = '00000';
	LET vmensaje = 'PROCESO EXITOSO';

	RETURN cod_ret, vmensaje;
END;
END PROCEDURE
DOCUMENT 
'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 17/10/2023',
'DESCRIPCION: Genera reporte de clientes que retiran efectivo de ATMs en el extranjero de credito',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_carga_geolocalizacion_bpi()
RETURNING CHAR(5) AS CodRet,
          CHAR(180) AS mensaje;

-- DeclaraciÃ³n de variables
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(250);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(80);

--VARIABLES TABLA
DEFINE vconteo					INTEGER;
DEFINE vcount 					INTEGER;
DEFINE v_id_operacion 			CHAR(4);
DEFINE v_fecha_oper 			DATE;
DEFINE v_folio 					CHAR(16);
DEFINE v_cuenta_origen 			CHAR(12);
DEFINE v_destino 				CHAR(18);
DEFINE v_ipusuario 				CHAR(15);
DEFINE v_latitud 				CHAR(100);
DEFINE v_longitud 				CHAR(100);
DEFINE v_version 				CHAR(10);
DEFINE v_referencia_23 			CHAR(23);
DEFINE v_cve_geo 				CHAR(1);
DEFINE v_version_a 				CHAR(10);
DEFINE v_version_b 				CHAR(10);
DEFINE v_idregistro 			CHAR(7);

--VARIABLES DE PASO
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_menos_uno		DATE;


--SE INICIALIZAN VARIABLES
LET vpaso = 0;
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_carga_geolocalizacion_bpi en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_carga_geolocalizacion_bpi');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
    --SET DEBUG FILE TO "/ifxsif01/c90307913/sp_carga_geolocalizacion_bpi.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA Y LA FECHA DEL DIA MENOS 1 DIA
	SELECT fecha_hoy, fecha_ant
	INTO v_fecha_hoy, v_fecha_menos_uno
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_menos_uno), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_menos_uno), 2, '0');
	LET cAno = YEAR(v_fecha_menos_uno);
	
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CTA	 = 'CargaGeoLocalizacion_bpi_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".bpi_geolocalizacion_paso;
	COMMIT;
	
	
	LET vpaso = 4;
		
	
	LET vcount = 1;

	FOREACH WITH HOLD
		SELECT  id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b
		INTO v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b
		FROM bdibpi:bpi_geolocalizacion
		WHERE fecha_oper >= v_fecha_menos_uno AND fecha_oper < v_fecha_hoy

		
		LET vpaso = 5;
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		LET v_idregistro = LPAD(vcount, 7, '0');
		
		INSERT INTO "informix".bpi_geolocalizacion_paso (id_registro,id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b, fecha_registro)	
		VALUES(v_idregistro,v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b, v_fecha_menos_uno);
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;
		END IF

		LET vcount =  vcount + 1;
	
	END FOREACH
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF


	LET vpaso = 6;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * from bdiauditor:bpi_geolocalizacion_paso;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 7;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 8;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 9;
	LET cod_ret = '000000';
    LET vmensaje = 'EXITO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_carga_geolocalizacion_bpi');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE

DOCUMENT 'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 09/01/2024',
'DESCRIPCION: GeneraciÃ³n de informaciÃ³n geolocalizacion para sistemas MINDS PLD',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_carga_geolocalizacion_bpi2()
RETURNING CHAR(5) AS CodRet,
          CHAR(180) AS mensaje;

-- DeclaraciÃ³n de variables
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(250);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(80);

--VARIABLES TABLA
DEFINE vconteo					INTEGER;
DEFINE vcount 					INTEGER;
DEFINE v_id_operacion 			CHAR(4);
DEFINE v_fecha_oper 			DATE;
DEFINE v_folio 					CHAR(16);
DEFINE v_cuenta_origen 			CHAR(12);
DEFINE v_destino 				CHAR(18);
DEFINE v_ipusuario 				CHAR(15);
DEFINE v_latitud 				CHAR(100);
DEFINE v_longitud 				CHAR(100);
DEFINE v_version 				CHAR(10);
DEFINE v_referencia_23 			CHAR(23);
DEFINE v_cve_geo 				CHAR(1);
DEFINE v_version_a 				CHAR(10);
DEFINE v_version_b 				CHAR(10);
DEFINE v_idregistro 			CHAR(7);

--VARIABLES DE PASO
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_menos_uno		DATE;


--SE INICIALIZAN VARIABLES
LET vpaso = 0;
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_carga_geolocalizacion_bpi2 en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_carga_geolocalizacion_bpi2');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
    --SET DEBUG FILE TO "/ifxsif01/c90307913/sp_carga_geolocalizacion_bpi2.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA Y LA FECHA DEL DIA MENOS 1 DIA
	SELECT fecha_hoy, fecha_ant
	INTO v_fecha_hoy, v_fecha_menos_uno
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_menos_uno), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_menos_uno), 2, '0');
	LET cAno = YEAR(v_fecha_menos_uno);
	
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CTA	 = 'CargaGeoLocalizacion_bpi2_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".bpi_geolocalizacion_paso;
	COMMIT;
	
	
	LET vpaso = 4;
		
	
	LET vcount = 1;

	FOREACH WITH HOLD
		SELECT  id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b
		INTO v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b
		FROM bdibpi:bpi_geolocalizacion
		WHERE fecha_oper >= v_fecha_menos_uno AND fecha_oper < v_fecha_hoy AND version_a IS NOT NULL AND referencia_23 IS NULL

		
		LET vpaso = 5;
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		LET v_idregistro = LPAD(vcount, 7, '0');
		
		INSERT INTO "informix".bpi_geolocalizacion_paso (id_registro,id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b, fecha_registro)	
		VALUES(v_idregistro,v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b, v_fecha_menos_uno);
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;
		END IF

		LET vcount =  vcount + 1;
	
	END FOREACH
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF


	LET vpaso = 6;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * from bdiauditor:bpi_geolocalizacion_paso;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 7;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 8;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 9;
	LET cod_ret = '000000';
    LET vmensaje = 'EXITO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_carga_geolocalizacion_bpi2');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE

DOCUMENT 'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 09/01/2024',
'DESCRIPCION: GeneraciÃ³n de informaciÃ³n geolocalizacion para sistemas MINDS PLD',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_mindscuentasrelacionadas_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CUENTASRELACIONADAS	VARCHAR(50);

--VARIABLE LAYOUT cta relacionada
DEFINE  v_idregistro				INTEGER;
DEFINE 	v_nocuenta					CHAR(20);
DEFINE 	v_cuentarelacionada			CHAR(20);
DEFINE	v_titularcuenta				CHAR(104);
DEFINE  v_propositocuenta			CHAR(10);
DEFINE  v_idestatuscargaminds		INTEGER;
DEFINE  v_notransaccion				INTEGER;
DEFINE  v_montomensual				DECIMAL(14,2);
DEFINE	v_idrelacion				INTEGER;
DEFINE	v_rfc						CHAR(13);
DEFINE  v_esdeposito				INTEGER;
DEFINE  v_esretiro					INTEGER;
DEFINE  v_eraconocida				INTEGER;
DEFINE	v_tipopersonarel			CHAR(2);
DEFINE  v_fecharegistro 			CHAR(10);
DEFINE 	v_fechaactualizacion		CHAR(10);
DEFINE 	v_idtipocuenta              CHAR(1);


--VARIABLES DE PASO
DEFINE temp_fecharegistro		DATE;
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vconteo					INTEGER;
DEFINE nombrepf1 				CHAR(26);
DEFINE nombrepf2 				CHAR(26);
DEFINE v_apaterno				CHAR(26);
DEFINE v_amaterno 				CHAR(26);
DEFINE v_idsexo					CHAR(1);

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET v_nocuenta = '';
LET v_cuentarelacionada= '';
LET v_propositocuenta = '5';
LET v_titularcuenta = null;
LET	v_rfc = '';
LET v_idrelacion = 0;
LET v_tipopersonarel = '';
LET v_esdeposito = 0;
LET v_esretiro = 0;
LET v_eraconocida = 0;
LET v_idregistro = 0;
LET v_notransaccion = 0;
LET v_montomensual = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET v_idtipocuenta = '1';
LET v_idsexo = '';

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindscuentasrelacionadas_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CUENTASRELACIONADAS,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindscuentasrelacionadas_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindscuentasrelacionadas_diario.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CUENTASRELACIONADAS = 'CargaCtaRelMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_cuentarelacionada_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD
		SELECT se.numcte,se.cuenta,sd.nombre1,sd.nombre2,sd.apell_paterno,sd.apell_materno,se.tipo_relacion,sd.rfc,se.parentesco,se.fecha_insert
		INTO v_nocuenta,v_cuentarelacionada,nombrepf1,nombrepf2,v_apaterno,v_amaterno,v_idrelacion,v_rfc,v_tipopersonarel,temp_fecharegistro
		FROM bdinteg:si_cterelacionado se
		LEFT JOIN bdinteg:si_cliente sd ON se.numcte = sd.numcte
		WHERE sd.tipo_cliente = '1'
		AND se.fecha_insert = v_fecha_ant
        AND se.sistema<>'SV'
		
		LET vpaso = 5;
		
		SELECT sexo
		INTO v_idsexo
		FROM bdinteg:si_ctepf 
		where numcte = v_nocuenta;
		
		LET vpaso = 6;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		LET v_titularcuenta = TRIM(nombrepf1)||' '||TRIM(nombrepf2)||' '||TRIM(v_apaterno)||' '||TRIM(v_amaterno);
		LET v_fecharegistro = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET v_fechaactualizacion = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET vconteo = vconteo + 1;
		
		IF (v_tipopersonarel IS NULL or v_tipopersonarel = '0' or v_tipopersonarel = '01' or v_tipopersonarel = 'S' 
			or v_tipopersonarel = 'O' or v_tipopersonarel = 'M' or v_tipopersonarel = 'K' or v_tipopersonarel = '') THEN
			LET v_tipopersonarel = '1';
		ELIF (v_tipopersonarel = 'A' ) THEN
			LET v_tipopersonarel = '2';
		ELIF (v_tipopersonarel = 'B' ) THEN
			LET v_tipopersonarel = '11';
		ELIF (v_tipopersonarel = 'C' ) THEN
			LET v_tipopersonarel = '12';
		ELIF (v_tipopersonarel = 'E' ) THEN
			LET v_tipopersonarel = '10';
		ELIF (v_tipopersonarel = 'H' ) THEN
			LET v_tipopersonarel = '6';
		ELIF (v_tipopersonarel = 'I' ) THEN
			LET v_tipopersonarel = '13';
		ELIF (v_tipopersonarel = 'J' ) THEN
			LET v_tipopersonarel = '5';
		ELIF (v_tipopersonarel = 'N' ) THEN
			LET v_tipopersonarel = '7';
		ELIF (v_tipopersonarel = 'R' ) THEN
			LET v_tipopersonarel = '9';
		ELIF (v_tipopersonarel = 'T' ) THEN
			LET v_tipopersonarel = '8';
		ELIF (v_tipopersonarel = 'U' ) THEN
			LET v_tipopersonarel = '14';
		ELIF (v_tipopersonarel = 'P' and v_idsexo = 'M' ) THEN
			LET v_tipopersonarel = '3';
		ELIF (v_tipopersonarel = 'P' and v_idsexo = 'F' ) THEN
			LET v_tipopersonarel = '4';
		END IF
			
		LET vpaso = 7;
		
		INSERT INTO "informix".tbl_cuentarelacionada_minds(idregistro,idtipocuenta,nocuenta,cuentarelacionada,titularcuenta,propositocuenta,idestatuscargaminds,fechaactualizacion,notransaccion,montomensual,idrelacion,rfc,esdeposito,esretiro,eraconocida,tipopersonarel,fecharegistro)
		VALUES(vconteo,v_idtipocuenta,v_cuentarelacionada,v_cuentarelacionada,v_titularcuenta,V_propositocuenta,v_idestatuscargaminds,v_fechaactualizacion,v_notransaccion,v_montomensual,v_idrelacion,v_rfc,v_esdeposito,v_esretiro,v_eraconocida,v_tipopersonarel,v_fecharegistro);
		
		LET vpaso = 8;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	END FOREACH
	
	LET vpaso = 9;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 10;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'.txt select * FROM bdiauditor:tbl_cuentarelacionada_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 11;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql';
	system vsql;
	
	LET vpaso = 12;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql';
	system vsql;
	
	LET vpaso = 13;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CUENTASRELACIONADAS);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindscuentasrelacionadas_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE;