CREATE PROCEDURE "informix".sp_cnsif_datinicred(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20))
							
				returning CHAR(5)  AS Cod_Retorno, 
						  DATE     AS Fecha_Alta_Credito, 
						  DATE     AS Fecha_Cancelacion, 
						  CHAR(60) AS Desc_Status, 
						  DATE     AS Fecha_Primer_Compra, 
						  DECIMAL(18,2) AS Monto_Primera_Compra, 
						  CHAR(4)  AS Transaccion_Primera_Compra, 
						  DATE     AS Fecha_Primera_Disposicion, 
						  DECIMAL(18,2) AS Monto_Primera_Disposicion, 
						  CHAR(4)  AS Transaccion_Primera_Disposicion, 
						  DATE     AS Fecha_Ultimo_Vencido,
                          CHAR(101)     AS Desc_Transaccion_Primera_Compra,
                          CHAR(101)     AS Desc_Transaccion_Primera_Disposicion;
												
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
							
--VARIABLES STORE
DEFINE dFechaAltaCredito       	  DATE;      
DEFINE dFechaCancelacion       	  DATE;      
DEFINE cDescStatus             	  CHAR(60);     
DEFINE dFechaPrimeraCompra     	  DATE;          
DEFINE decMontoPrimeracompra      DECIMAL(18,2); 
DEFINE cTransaccionPrimeraCompra  CHAR(4);     
DEFINE dFechaPrimeraDisp     	  DATE;      
DEFINE decMontoPrimeraDisp        DECIMAL(18,2);
DEFINE cTransaccionPrimeraDisp    CHAR(4); 
DEFINE dFechaUltimoVencido        DATE;
DEFINE cDesc_PC                   CHAR(100);
DEFINE cDesc_PD                   CHAR(100);

--inicializando variables
LET  iexiste 		 	   = 0;
LET cCodRet 		 	   = "00000";
LET iSql_err 		 	   = 0;

LET dFechaAltaCredito         = "";
LET dFechaCancelacion         = "";
LET cDescStatus               = "";
LET dFechaPrimeraCompra       = "";
LET decMontoPrimeracompra     = 0;
LET cTransaccionPrimeraCompra = "";
LET dFechaPrimeraDisp   	  = "";
LET decMontoPrimeraDisp       = 0;
LET cTransaccionPrimeraDisp   = "";
LET dFechaUltimoVencido       = "";
LET cDesc_PC                  = "";
LET cDesc_PD                  = "";


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFechaAltaCredito, dFechaCancelacion, cDescStatus, dFechaPrimeraCompra, decMontoPrimeracompra, cTransaccionPrimeraCompra, dFechaPrimeraDisp, decMontoPrimeraDisp,     
				   cTransaccionPrimeraDisp, dFechaUltimoVencido,cDesc_PC,cDesc_PD; 						
		END IF;
	END EXCEPTION;
	
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_datinicred.out";
	--  TRACE ON;
		
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA   = ''   THEN 
		LET cCodRet = "00045";
		RETURN cCodRet,dFechaAltaCredito, dFechaCancelacion, cDescStatus, dFechaPrimeraCompra, decMontoPrimeracompra, cTransaccionPrimeraCompra, dFechaPrimeraDisp, decMontoPrimeraDisp,     
			   cTransaccionPrimeraDisp, dFechaUltimoVencido,cDesc_PC,cDesc_PD; 						
	END IF;	
  	   
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,dFechaAltaCredito, dFechaCancelacion, cDescStatus, dFechaPrimeraCompra, decMontoPrimeracompra, cTransaccionPrimeraCompra, dFechaPrimeraDisp, decMontoPrimeraDisp,     
			   cTransaccionPrimeraDisp, dFechaUltimoVencido,cDesc_PC,cDesc_PD;
	END IF;
	-- TERMINA VALIDACION		   
    FOREACH
        SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE empresa = '001' AND  num_credito = cNUMCUENTA 
        UNION
        SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE empresa = '001' AND  num_credito = cNUMCUENTA ORDER BY CONT DESC 
    END FOREACH;

	IF iexiste  = 0 THEN 
	LET cCodRet = "00046";
	RETURN cCodRet,dFechaAltaCredito, dFechaCancelacion, cDescStatus, dFechaPrimeraCompra, decMontoPrimeracompra, cTransaccionPrimeraCompra, dFechaPrimeraDisp, decMontoPrimeraDisp,     
		   cTransaccionPrimeraDisp, dFechaUltimoVencido,cDesc_PC,cDesc_PD;
	END IF;
	  
    SELECT NVL(COUNT(*),0) INTO iexiste FROM bdicred:sd_indicador_cred WHERE empresa = '001' AND  num_credito = cNUMCUENTA;
    IF iexiste=0 THEN
        LET cCodRet='00090';
	    RETURN cCodRet,dFechaAltaCredito, dFechaCancelacion, cDescStatus, dFechaPrimeraCompra, decMontoPrimeracompra, cTransaccionPrimeraCompra, dFechaPrimeraDisp, decMontoPrimeraDisp,     
			   cTransaccionPrimeraDisp, dFechaUltimoVencido,cDesc_PC,cDesc_PD;
    END IF;
	SET ISOLATION TO DIRTY READ;
	FOREACH 
	
	 SELECT NVL(fecha_alta,''),NVL(fecha_cancelacion,''),NVL(f_primer_compra,''),monto_primer_compra,trans_primer_compra,NVL(f_primer_disp,''),monto_primer_disp,
			trans_primer_disp, NVL(fecha_vencido,'')
	 INTO 		
			dFechaAltaCredito, dFechaCancelacion, dFechaPrimeraCompra, decMontoPrimeracompra, cTransaccionPrimeraCompra, dFechaPrimeraDisp, decMontoPrimeraDisp,     
			cTransaccionPrimeraDisp, dFechaUltimoVencido
	 FROM bdicred:sd_indicador_cred
	 WHERE num_credito = cNUMCUENTA
	 
	 SELECT b.descripcion
	 INTO
	 cDescStatus
	 FROM bdicred:sd_maecred a,
	      bdicred:sd_tipocartera b 
	 WHERE a.status_cred = b.status_cred
	 AND  a.num_credito = cNUMCUENTA;

     
     SELECT NVL(descripcion,'') INTO cDesc_PC FROM bdicred:sd_transfun
     WHERE transacc=cTransaccionPrimeraCompra;
	 
     SELECT NVL(descripcion,'') INTO cDesc_PD FROM bdicred:sd_transfun
     WHERE transacc=cTransaccionPrimeraDisp;
	
	RETURN cCodRet,dFechaAltaCredito, dFechaCancelacion, cDescStatus, dFechaPrimeraCompra, decMontoPrimeracompra, cTransaccionPrimeraCompra, dFechaPrimeraDisp, decMontoPrimeraDisp,     
		   cTransaccionPrimeraDisp, dFechaUltimoVencido,cDesc_PC,cDesc_PD WITH RESUME;
	
	END FOREACH;
			
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información inicial de una Cuenta de Crédito. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  No. de Cuenta.",
"FECHA : 29-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_obtienepaises(p_NumRegs INTEGER)
	RETURNING
    CHAR(5), CHAR(3), CHAR(20);


    --Definicion de Variables
    DEFINE cCodRet      CHAR(5);
	DEFINE cPais 		CHAR(3);
	DEFINE cDescripcion CHAR(20);
	DEFINE iSqlErr		INTEGER;
	DEFINE iContador    INTEGER;


	-- Inicializa variables
    LET cCodRet 		= "00000";
	LET cPais 			= "";
	LET cDescripcion 	= "";
	LET iSqlErr 		= 0;
	LET iContador		= 0;

	--SET DEBUG FILE TO '/tmp/sp_obtienepaises.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
	
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet, cPais, cDescripcion;
            END IF;
        END EXCEPTION;
		
		FOREACH 
		
		SELECT pais, nombre 
		INTO cPais, cDescripcion
		FROM "informix".si_paises
		ORDER BY nombre 
		
		LET iContador = iContador + 1;

		IF iContador < p_NumRegs THEN
			CONTINUE FOREACH;
		END IF; 
			
		RETURN cCodRet, cPais, cDescripcion WITH RESUME;
		
		END FOREACH
	
    END;
END PROCEDURE
 DOCUMENT
 'AUTOR: Urias Rocha Felipe de Jesus',
 'DESCRIPCION: se optienen los codigos y las descripciones de los países de si_paises en bdinteg.',
 'FECHA: 20120413',
 'BD:   bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_consfuncionalidadusu(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_USUARIO char(8),cID_FUNCION char(10))
 
    RETURNING CHAR(5),CHAR(10),CHAR(1),CHAR(1);
													
	DEFINE iexiste INT;
	DEFINE cCodRet CHAR(5);
    DEFINE cIdfun CHAR(10);
    DEFINE cStatfun CHAR(1);
    DEFINE cStatusufun CHAR(1);
	DEFINE iSql_err INT;
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
    LET cIdfun="";
    LET cStatfun="";
    LET cStatusufun="";
		
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cIdfun,cStatfun,cStatusufun;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consfuncionalidadusu_2.out";
		--TRACE ON;
		
		IF 	cID_USUARIOC = '' OR 
			cID_FUNCIONC ='' OR 
			cID_FUNCION = '' OR
            cID_USUARIO = '' THEN
			LET cCodRet = "00003";
			 RETURN cCodRet,cIdfun,cStatfun,cStatusufun;
		END IF;
        EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cIdfun,cStatfun,cStatusufun;
		END IF;
		
        SELECT nvl(Count(funciones.id_funcion),0) INTO iexiste
        FROM si_seg_funciones funciones
        LEFT JOIN si_seg_usuarios_funciones usuarios_funciones
        ON funciones.id_funcion  = usuarios_funciones.id_funcion 
        LEFT JOIN si_seg_modulos seg
        ON funciones.id_modulo=seg.id_modulo
        WHERE usuarios_funciones.id_usuario=cID_USUARIO
        AND usuarios_funciones.id_funcion=cID_FUNCION
        AND usuarios_funciones.status=1 AND funciones.status=1 AND seg.status=1;

		IF iexiste = 0 THEN
			LET cCodRet = "00074";
        ELSE
            SELECT funciones.id_funcion,funciones.status,usuarios_funciones.status
            INTO cIdfun,cStatfun,cStatusufun
            FROM si_seg_funciones funciones
            LEFT JOIN si_seg_usuarios_funciones usuarios_funciones
            ON funciones.id_funcion  = usuarios_funciones.id_funcion 
            LEFT JOIN si_seg_modulos seg
            ON funciones.id_modulo=seg.id_modulo
            WHERE usuarios_funciones.id_usuario=cID_USUARIO
            AND usuarios_funciones.id_funcion=cID_FUNCION
            AND usuarios_funciones.status=1 AND funciones.status=1 AND seg.status=1;
		END IF;

    RETURN cCodRet,cIdfun,cStatfun,cStatusufun;
    END
END PROCEDURE
DOCUMENT
"AUTOR : Victor Hugo Sánchez",
"FUNCIONAMIENTO: El propósito de esta interfaz es el de realizar la búsqueda y consulta de una funcionalidad, para determinar si la tiene o no asociada un usuario.", 
"FECHA : 18-01-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultadatospagare(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20))
							
			returning   CHAR(5)         AS Cod_Retorno,
						CHAR(50)        AS Sucursal,	      
						CHAR(08)        AS Promotor,          
						MONEY(14,2)     AS Capital, 	      
						SMALLINT        AS Plazo, 	      
						DATE            AS Vencimiento,       
						DATE            AS Ultimo_Movimiento, 
						MONEY(14,2)     AS Interes_Bruto,     
						DECIMAL(9,6)    AS Tasa_Neta, 	      
						DECIMAL(9,6)    AS Tasa_Bruta,	      
						MONEY(14,2)     AS ISR, 	      
						MONEY(14,2)     AS Interes_Neto,      
						DECIMAL(9,6)    AS Sobretasa;	      

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE cEmpresa			CHAR(3);
DEFINE cSucursal	    CHAR(4);
DEFINE cPromotor        CHAR(08);
DEFINE mCapital 	    MONEY(14,2);
DEFINE smallPlazo 	    SMALLINT;
DEFINE dFechaVencimiento 	DATE;
DEFINE dFechaUltimoMovto    DATE;
DEFINE mInteresBruto 	MONEY(14,2);
DEFINE decTasaNeta 	    DECIMAL(9,6);
DEFINE decTasaBruta		DECIMAL(9,6);
DEFINE mISR 			MONEY(14,2);
DEFINE decInteresNeto  	MONEY(14,2);
DEFINE decSobretasa		DECIMAL(9,6);

--- variables store
DEFINE cValRetorno		    CHAR(5);
DEFINE cCod_instrum         CHAR(4);
DEFINE cCuenta				CHAR(20);
DEFINE cNumcte				CHAR(20);
DEFINE cNumcte2			    CHAR(20);		         
DEFINE cTipo_banca		    CHAR(3); 
DEFINE cCta_cheques			CHAR(20);   
DEFINE cNombre				CHAR(60);   
DEFINE cTipo   				CHAR(1);    
DEFINE cNombre2				CHAR(20);   
DEFINE cApell_pat       	CHAR(26);   
DEFINE cApell_mat			CHAR(26);   
DEFINE cNombre1         	CHAR(26);   
DEFINE cRFC					CHAR(13);   
DEFINE cFech_nac			CHAR(10);   
DEFINE cParentesco			CHAR(2);    
DEFINE cProducto			CHAR(4);    
DEFINE cStatus_cta      	CHAR(1);    
DEFINE cMotivo				CHAR(2);    
DEFINE cOpcion_retiro   	CHAR(2);    
DEFINE cAdicionado			CHAR(8);    
DEFINE cPlaza    			CHAR(3);    
DEFINE cReg_firmas			CHAR(1);    
DEFINE cEnvio				CHAR(1);    
DEFINE cCobraisr			CHAR(1);    
DEFINE cPer_acred_int   	CHAR(1);    
DEFINE cModificado			CHAR(8);               				
DEFINE mImp_ISR				MONEY(14,2);
DEFINE mRend_neto			MONEY(14,2);
DEFINE cSdo_retenido		MONEY(14,2);
DEFINE cSdo_cong			MONEY(14,2);
DEFINE cIntereses			MONEY(14,2);   					
DEFINE cAcum_sdo_pos		MONEY(14,2);
DEFINE cSdo_prom_mesant 	MONEY(14,2);
DEFINE cSdo_mes_ant			MONEY(14,2);
DEFINE cSdo_dia_ant			MONEY(14,2);
DEFINE cSdo_ult_corte   	MONEY(14,2);
DEFINE dFecha_alta			DATE;                                                   
DEFINE cFec_cancelac    	DATE;       
DEFINE cFec_reinversion 	DATE;       
DEFINE cFecha_val			DATE;               
DEFINE cFecha_mod			DATE;               
DEFINE sPlazo2				SMALLINT;   
DEFINE sDireccion_env		SMALLINT;   
DEFINE sCantReg         	SMALLINT;   
DEFINE sSecuencia       	SMALLINT;   
DEFINE cDia_sdo_pos			SMALLINT;   
DEFINE cSecuencia2			SMALLINT;                                          
DEFINE vTasa_isr			DECIMAL(9,6);                                       
DEFINE vTasa_base			DECIMAL(9,6);
DEFINE cTasa				DECIMAL(9,6);                                       
DEFINE cVencimiento			CHAR(2);    
DEFINE iCanIntVen			INTEGER;  
DEFINE iMaxSec              INTEGER;  
DEFINE dvalor               DECIMAL(9,6);
DEFINE cDesSucursal         CHAR(50);


--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;	
LET cSucursal 		 = "";
LET cPromotor        = "";
LET mCapital	     = 0;
LET smallPlazo	     = 0;
LET dFechaVencimiento	 = "";
LET dFechaUltimoMovto    = "";
LET mInteresBruto	 = 0;
LET decTasaNeta	     = 0;
LET decTasaBruta	 = 0;
LET mISR 		     = 0;
LET decInteresNeto   = 0;
LET decSobretasa	 = 0;

-- inicializa variables store
--INICIALIZACION DE VARIABLES   
LET cValRetorno     = '00000';     
LET cEmpresa	    = '001';                             
LET cCod_instrum    = '';       
LET cCuenta  	    = '';       
LET cNumcte	        = '';       
LET cTipo_banca	    = '';       
LET cCta_cheques    = '';       
LET cTipo	  		= '';       
LET cNumcte2	    = '';       
LET cApell_pat      = '';       
LET cApell_mat      = '';       
LET cNombre1	    = '';       
LET cNombre2	    = '';       
LET cRFC		    = '';       
LET cFech_nac	    = '';       
LET cParentesco	    = '';       
LET cProducto	    = '';       
LET cStatus_cta 	= '';       
LET cMotivo	   		= '';       
LET cOpcion_retiro  = '';       
LET cModificado	    = '';       
LET cAdicionado	    = '';       
LET cPlaza    	    = '';       
LET cReg_firmas	    = '';       
LET cEnvio	        = '';       
LET cCobraisr	    = '';       
LET cPer_acred_int  = '';              
LET mImp_ISR	    = 0;        
LET mRend_neto      = 0;        
LET sDireccion_env  = 0;        
LET sCantReg 	    = 0;        
LET vTasa_base	    = 0;        
LET vTasa_isr 	    = 0;               
LET sSecuencia	    = 0;        
LET cSecuencia2	    = 0;        
LET cIntereses	    = 0;                                     
LET cDia_sdo_pos	= 0;        
LET cAcum_sdo_pos   = 0;        
LET cSdo_prom_mesant = 0;       
LET cSdo_mes_ant	= 0;        
LET cSdo_dia_ant	= 0;        
LET cSdo_ult_corte  = 0;        
LET cSdo_retenido   = 0;        
LET cSdo_cong	    = 0;        
LET dFecha_alta	    = date(1);    
LET cFec_cancelac   = date(1);  
LET cFec_reinversion = date(1); 
LET cFecha_val	    = date(1);  
LET cFecha_mod	    = date(1);  
LET cVencimiento	= '';       
LET iCanIntVen	    = 0;      
LET iMaxSec         =0;  
LET dvalor          =0;         
LET cDesSucursal    ="";


BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cSucursal,cPromotor,mCapital, smallPlazo, dFechaVencimiento, dFechaUltimoMovto, mInteresBruto, decTasaNeta, decTasaBruta, mISR, decInteresNeto,decSobretasa;						
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultadatospagare.out";
	--TRACE ON;
		
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA   = ''	THEN 
		LET cCodRet = "00040";
		RETURN cCodRet,cSucursal,cPromotor,mCapital, smallPlazo, dFechaVencimiento, dFechaUltimoMovto, mInteresBruto, decTasaNeta, decTasaBruta, mISR, decInteresNeto,decSobretasa;						
	END IF;	
	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cSucursal,cPromotor,mCapital, smallPlazo, dFechaVencimiento, dFechaUltimoMovto, mInteresBruto, decTasaNeta, decTasaBruta, mISR, decInteresNeto,decSobretasa;						
	END IF;
	-- TERMINA VALIDACION	
	
	SELECT NVL(COUNT(cuenta),0)	INTO iexiste FROM  bdinvers:sv_maeinv WHERE cuenta  = cNUMCUENTA;
	IF iexiste  = 0 THEN 
        LET cCodRet = "00041";
        RETURN cCodRet,cSucursal,cPromotor,mCapital, smallPlazo, dFechaVencimiento, dFechaUltimoMovto, mInteresBruto, decTasaNeta, decTasaBruta, mISR, decInteresNeto,decSobretasa;						
	END IF;

    
    SELECT NVL(MAX(secuencia),0) INTO iMaxSec FROM bdinvers:sv_maeinv WHERE empresa ='001' and cuenta = cNUMCUENTA;

    SELECT NVL(valor,0) INTO dvalor FROM bdinteg:si_fechavalor WHERE empresa = '001' AND tasa = 'I.S.R.' 
    AND fecha=(SELECT MAX(fecha) FROM bdinteg:si_fechavalor WHERE empresa = '001' AND tasa = 'I.S.R.');

	SET ISOLATION TO DIRTY READ;

    SELECT sucursal,promotor,capital,plazo,fecha_venc,fec_ult_mov,intereses,tasa-dvalor AS tasa_neta,tasa AS tasa_bruta,isr,intereses - isr AS interes_neto,sobretasa
    INTO cSucursal,cPromotor,mCapital,smallPlazo,dFechaVencimiento,dFechaUltimoMovto,mInteresBruto,decTasaNeta,decTasaBruta,mISR,decInteresNeto,decSobretasa
    FROM bdinvers:sv_maeinv 
    WHERE empresa = '001' AND cuenta = cNUMCUENTA
    AND secuencia = iMaxSec;

    SELECT NVL(nombre,'') INTO cDesSucursal FROM bdinteg:si_sucursales
    WHERE sucursal=cSucursal;

    LET cDesSucursal=cSucursal||' '||cDesSucursal;

	RETURN 	cCodRet,cDesSucursal,cPromotor,mCapital, smallPlazo, dFechaVencimiento, dFechaUltimoMovto, mInteresBruto, decTasaNeta, decTasaBruta, mISR, decInteresNeto,decSobretasa;						

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información general de una Cuenta de Inversión. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de Cuenta.",
"FECHA : 15-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultatodousuarios(cID_USUARIOC char(8),cID_FUNCIONC char(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
 
    RETURNING CHAR(5),CHAR(8),CHAR(45);
													
	DEFINE iexiste 		INT;
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSql_err 	INT;
	DEFINE cId_usuario	CHAR(8);
	DEFINE cNombre		CHAR(45);
    DEFINE iCont            INTEGER;
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET	cId_usuario ="";
	LET cNombre = "";
    LET iCont=0;

	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cId_usuario,cNombre;
            END IF;
        END EXCEPTION;
		--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultatodousuarios.out";
		--	TRACE ON;
		IF 	cID_USUARIOC ='' OR 
			cID_FUNCIONC = '' THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cId_usuario,cNombre;
		END IF;		

        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cId_usuario,cNombre;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cId_usuario,cNombre;
            END IF;
        END IF; 
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cId_usuario,cNombre;
		END IF;		
		
		SELECT {+INDEX (bdinteg:si_seg_usuarios idxsegidusu)} nvl(Count(id_usuario),0) INTO iexiste  FROM si_seg_usuarios where id_usuario is not null;
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cId_usuario,cNombre;
		END IF;
		SET ISOLATION TO DIRTY READ;
        FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion US.id_usuario,EJ.nombre  
			INTO cId_usuario,cNombre
			FROM  si_seg_usuarios US
			INNER JOIN si_ejecut EJ 
			ON EJ.ejecutivo = US.id_usuario
            WHERE id_usuario IS NOT NULL
            ORDER BY EJ.nombre 

            LET cNombre=cId_usuario||'-'||cNombre;

            LET iCont=iCont+1;

			RETURN cCodRet,cId_usuario,cNombre WITH resume;
		END FOREACH;		
         IF iCont = 0 THEN
            LET cCodRet = 1001; 
            RETURN cCodRet,cId_usuario,cNombre;
        END IF 
    END
END PROCEDURE
DOCUMENT
"AutOR : Antonio Flores",
"FUNICIONAMIENTO: Este SP regresara todos los usuarios existentes dentro de la base, mostrando el id_usuario y el nombre",
"FECHA : 28-12-2011",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_actualizapass_bpi(pEmpresa char(3), pNumCte char(20), pPass char(50), pIp char (15), pSucVirtual char (4), pUsuVirtual char(8))                                                                                
   returning char(5);                                                                                                                                                                                                                         
                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                              
   --Modificó: Javier A. Chávez T.                                                                                                                                                                                                            
   --Actividad: activa el usuario y registra el cambio de status                                                                                                                                                                              
   --Solicito: Mauricio León                                                                                                                                                                                                                  
   --Fecha: 05-03-09                                                                                                                                                                                                                          
                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                              
-- ***************************************************************************                                                                                                                                                                
-- Define variables                                                                                                                                                                                                                           
-- ***************************************************************************                                                                                                                                                                
    DEFINE cod_ret char(5);                                                                                                                                                                                                                   
    DEFINE sql_err integer ;                                                                                                                                                                                                                  
    DEFINE iStatus smallint ;                                                                                                                                                                                                                 
    --DEFINE iStBloqueado smallint ;                                                                                                                                                                                                          
   -- DEFINE iStActivado smallint ;                                                                                                                                                                                                           
                                                                                                                                                                                                                                              
-- ***************************************************************************                                                                                                                                                                
-- Inicializa variables                                                                                                                                                                                                                       
-- ***************************************************************************                                                                                                                                                                
   LET cod_ret  = "000";                                                                                                                                                                                                                      
   LET iStatus = 0;                                                                                                                                                                                                                           
   --LET iStBloqueado = 0;                                                                                                                                                                                                                    
   --LET iStActivado = 0;                                                                                                                                                                                                                                                                                                                                                                                                                                                               
      
--SET DEBUG FILE TO "/home/informix/ivonne/sp_actualizapass_bpi.out";
--TRACE ON;
                                                                                                                                                                                                                                             
BEGIN                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                              
   ON EXCEPTION SET sql_err                                                                                                                                                                                                                   
      IF sql_err <> 0 THEN                                                                                                                                                                                                                    
            let cod_ret = sql_err;                                                                                                                                                                                                            
            RETURN cod_ret;                                                                                                                                                                                                                   
      END IF ;                                                                                                                                                                                                                                
   END EXCEPTION ;                                                                                                                                                                                                                            
                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                              
   IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN                                                                                                                                 
                                                                                                                                                                                                                                              
        UPDATE bdinteg:si_bpiusuarios SET pass3 = pass2, pass2 = pass1, pass1 = pass, f_pass3 = f_pass2,                                                                                                                                      
                        f_pass2 = f_pass1, f_pass1 = f_pass, pass = pPass, f_pass = current, f_actualizacion = current                                                                                                                        
                         WHERE  empresa = pEmpresa AND numcte = pNumCte;                                                                                                                                                                      
                                                                                                                                                                                                                                              
        SELECT id_status INTO iStatus FROM bdinteg:si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pNumCte;                                                                                                                             
        --SELECT id_status INTO iStBloqueado FROM bdinteg:si_catstatus  WHERE desc_status = 'BLOQUEADO';                                                                                                                                      
        --SELECT id_status INTO iStActivado FROM bdinteg:si_catstatus  WHERE desc_status = 'ACTIVADO';                                                                                                                                        
                                                                                                                                                                                                                                              
        --IF iStatus = iStBloqueado THEN                                                                                                                                                                                                      
                                                                                                                                                                                                                                              
			IF iStatus = 40 OR  iStatus = 90 THEN                                                                                                                                                                                 
				INSERT INTO bdinteg:si_cambiostcte  (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (pNumCte,iStatus,30,pIp ,current, pSucVirtual, pUsuVirtual);
				--UPDATE bdinteg:si_bpiusuarios SET id_status = iStActivado, f_status = current WHERE empresa = pEmpresa AND numcte = pNumCte;                                                                                
				UPDATE bdinteg:si_bpiusuarios SET id_status = 30, f_status = current WHERE empresa = pEmpresa AND numcte = pNumCte;                                                                                           
                                                                                                                                                                                                                                              
			END IF ;                                                                                                                                                                                                              
                        --Se modifica el insert, para que al grabar en tabla la hora tenga un segundo mas, evitando el problema de cambio de servicio básico a avanzado                                                                                                                                                                                                               
			INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio) VALUES (pNumCte,35,iStatus,pIp,current + 1 units second,pSucVirtual,pUsuVirtual);             
                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                              
   ELSE                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                              
        LET cod_ret = '001';  -- No existe el Cliente                                                                                                                                                                                         
                                                                                                                                                                                                                                              
   END IF ;                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                              
   RETURN cod_ret;                                                                                                                                                                                                                            
                                                                                                                                                                                                                                              
END                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                              
END PROCEDURE ;