CREATE PROCEDURE "informix".sp_cnsif_comprobantepp(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cCVEPROGRAMACION CHAR(10))
							
				returning CHAR(5)             AS Cod_Retorno,
						  CHAR(20)            AS Numero_Cliente,
						  CHAR(70)            AS Nombre,
						  CHAR(20)            AS Concepto,
						  DATE                AS Fecha_Programacion,
						  CHAR(08)            AS Hora_Programacion,
						  CHAR(30)            AS Canal_Programacion,
						  CHAR(40)            AS Cuenta_Origen,
						  CHAR(30)            AS Tipo_Cuenta_Origen,
						  CHAR(60)            AS Nombre_Beneficiario,
						  CHAR(40)            AS Banco_Receptor,
                          CHAR(20)            AS Cuenta_Destino,
						  CHAR(60)            AS Concepto_Pago,
						  MONEY(16,2)         AS Monto,
						  CHAR(40)            AS Referencia_1,
                          CHAR(20)            AS Referencia_2,
						  CHAR(70)            AS Tipo_Pago,
						  CHAR(61)            AS Notifica_Cliente_Recep,
						  CHAR(10)            AS Frecuencia,
                          CHAR(30)            AS Estado,
                          CHAR(07)            AS Porcentaje;
						  
						  
						  
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
----VARIABLES STORE
DEFINE v_NumCte             CHAR(20);
DEFINE v_NomCte             CHAR(70);
DEFINE v_Descripcion        CHAR(20);
DEFINE v_FechaProg          DATE;
DEFINE v_HoraProg           CHAR(8);
DEFINE v_Canal              CHAR(30);
DEFINE v_CtaOrigen          CHAR(40);
DEFINE v_TipoCtaOrigen      CHAR(30);
DEFINE v_NomBeneficiario    CHAR(60);
DEFINE v_BancoReceptor      CHAR(40);
DEFINE v_CtaDestino         CHAR(20);
DEFINE v_ConceptoPago       CHAR(60);
DEFINE v_Importe            MONEY(16,2);
DEFINE v_ImporteIva         MONEY(16,2);
DEFINE v_Referencia1        CHAR(40);
DEFINE v_Referencia2        CHAR(20);
DEFINE v_FechaPagoProg      DATE;
DEFINE v_TipoPago           CHAR(70);
DEFINE v_Notificacion       CHAR(30);
DEFINE v_Notificacion2      CHAR(30);
DEFINE v_Estado             CHAR(30);
DEFINE v_FechaCanc          DATE;
DEFINE v_HoraPago           CHAR(04);

DEFINE cFrecuencia          CHAR(10);
DEFINE cPorcentajeAux       CHAR(07);
DEFINE cCvePorcentaje       CHAR(02);
DEFINE iTipoSpei            INTEGER;
DEFINE dHora		DATETIME HOUR to FRACTION(3);

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;	

LET v_NumCte             = "";
LET v_NomCte             = "";
LET v_Descripcion        = "";
LET v_FechaProg          = "";
LET v_HoraProg           = "00:00:00";
LET v_Canal              = "";
LET v_CtaOrigen          = "";
LET v_TipoCtaOrigen      = "";
LET v_NomBeneficiario    = "";
LET v_BancoReceptor      = "";
LET v_CtaDestino         = "";
LET v_ConceptoPago       = "";
LET v_Importe            = 0;
LET v_ImporteIva         = 0;
LET v_Referencia1        = "";
LET v_Referencia2        = "";
LET v_FechaPagoProg      = "";
LET v_TipoPago           = "";
LET v_Notificacion       = "";
LET v_Notificacion2      = "";
LET v_Estado             = "";
LET v_FechaCanc          = "";

LET cFrecuencia          = '';
LET cPorcentajeAux       = '';
LET cCvePorcentaje       = '';
LET iTipoSpei            = 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,v_NumCte,v_NomCte,v_Descripcion,v_FechaProg,v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,  
			       v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe,v_Referencia1,v_Referencia2,
			       v_TipoPago,v_Notificacion2 ||'/' || v_Notificacion,cFrecuencia,v_Estado,cPorcentajeAux;
		END IF;
	END EXCEPTION;
	
	--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_comprobantepp.out";
	--	TRACE ON;

	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCLIENTE   = ''	OR 
		cCVEPROGRAMACION = '' THEN 
		LET cCodRet = "00067";
		RETURN cCodRet,v_NumCte,v_NomCte,v_Descripcion,v_FechaProg,v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,  
			   v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe,v_Referencia1,v_Referencia2,
			   v_TipoPago,v_Notificacion2 ||'/' || v_Notificacion,cFrecuencia,v_Estado,cPorcentajeAux;
	END IF 	   
		
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'26','2')
	INTO
	cCodRet;

	IF (cCodRet != '00000')  THEN
	 RETURN cCodRet,v_NumCte,v_NomCte,v_Descripcion,v_FechaProg,v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,  
		   v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe,v_Referencia1,v_Referencia2,
		   v_TipoPago,v_Notificacion2 ||'/' || v_Notificacion,cFrecuencia,v_Estado,cPorcentajeAux;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	
   EXECUTE PROCEDURE bdiprog:sp_encabezadoreportetransaccionesprogramadas(cNUMCLIENTE, cCVEPROGRAMACION, 2)
   INTO
	cCodRet,v_NumCte,v_NomCte,v_Descripcion,v_FechaProg,v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,  
	v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe,v_ImporteIva,v_Referencia1,v_Referencia2,v_FechaPagoProg,
	v_TipoPago,v_Notificacion,v_Notificacion2 ,v_Estado,v_FechaCanc,v_HoraPago;
	
	IF cCodRet = '10142' THEN
		LET cCodRet = '00086';
		RETURN cCodRet,v_NumCte,v_NomCte,v_Descripcion,v_FechaProg,v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,  
			   v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe,v_Referencia1,v_Referencia2,
			   v_TipoPago,v_Notificacion2 ||'/' || v_Notificacion,cFrecuencia,v_Estado,cPorcentajeAux;
	END IF
	
	IF cCodRet != '00000' THEN
		RETURN cCodRet,v_NumCte,v_NomCte,v_Descripcion,v_FechaProg,v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,  
			   v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe,v_Referencia1,v_Referencia2,
			   v_TipoPago,v_Notificacion2 ||'/' || v_Notificacion,cFrecuencia,v_Estado,cPorcentajeAux;
	END IF

	SELECT 
	CASE
	WHEN cve_programa = '01' THEN 'DIARIA'
	WHEN cve_programa = '02' THEN 'SEMANAL'
	WHEN cve_programa = '03' THEN 'MENSUAL'
	WHEN cve_programa = '04' THEN 'UNICA' END AS Frecuencia,tipo_spei
	INTO
	cFrecuencia,iTipoSpei
	FROM  bdiprog:pp_pagoprog
	WHERE num_cte = cNUMCLIENTE
	AND cve_pagoprog = cCVEPROGRAMACION;
	
	LET  cCvePorcentaje = SUBSTR(cCVEPROGRAMACION,1,2);
	
	IF cCvePorcentaje = '05' AND iTipoSpei = 3 THEN
		LET cPorcentajeAux = v_Importe ||' %';
		LET cPorcentajeAux = REPLACE(cPorcentajeAux,'$','');
		LET cPorcentajeAux = REPLACE(cPorcentajeAux,'.00','');
		LET cPorcentajeAux = TRIM(cPorcentajeAux) ||' %';
		LET v_Importe = 0.00;
	ELSE
		--  LET cPorcentajeAux = TO_CHAR(v_Importe);
        LET cPorcentajeAux = '';
	END IF

    LET dHora = current;
    LET v_HoraProg= SUBSTR(TO_CHAR(dHora),12,8);
	
	RETURN  cCodRet,v_NumCte,v_NomCte,v_Descripcion,v_FechaProg,v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,  
			v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe,v_Referencia1,v_Referencia2,
			v_TipoPago,v_Notificacion2 ||'/' || v_Notificacion,cFrecuencia,v_Estado,cPorcentajeAux; 

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información para generar el Comprobante de Transacciones Programadas. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de Cliente, Programación  y Tipo Pago.",
"FECHA : 27-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_cons_instvento(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20))
							
			returning   CHAR(5)         AS Cod_Retorno,
						CHAR(10)        AS Cap_Int,	      
						CHAR(35)        AS Instruccion,          
						MONEY(14,2)     AS Importe, 	      
						CHAR(20)        AS Cuenta_Deposito;	      

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE cCapInt	        CHAR(10);
DEFINE cInstruccion     CHAR(35);
DEFINE mImporte 	    MONEY(14,2);
DEFINE cCuentaDeposito 	CHAR(20);


--- variables store
DEFINE v_cuenta                CHAR(20); 
DEFINE v_aplicado              CHAR(1);  
DEFINE v_nom_cap_int           CHAR(7);  
DEFINE v_sec_capint, v_conta   SMALLINT; 
DEFINE v_inst_vento, v_sistema CHAR(2);  
DEFINE v_nom_inst_vento,                 
       v_nom_sistema           CHAR(35); 
DEFINE v_ciclo, longitud       SMALLINT; 
DEFINE v_cod_ret               CHAR(5);  
DEFINE v_env_dir               CHAR(1);  
DEFINE v_fecha_venc            DATE;     
DEFINE v_long_param            CHAR(2);  
DEFINE sBandera                SMALLINT;
    
--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;	
LET cCapInt 		 = "";
LET cInstruccion     = "";
LET mImporte	     = 0;
LET cCuentaDeposito	 = 0;

-- inicializa variables store
LET v_cod_ret         = "000";                                   
LET v_cuenta          = "000000000";                                                                                  
LET v_sec_capint      = 0;                                       
LET v_cod_ret         ="000";                                    
LET v_conta           = 0;                                       
LET v_nom_inst_vento  = "                              ";                                                                        
LET v_nom_sistema     = "                                   ";   
LET v_aplicado        = " ";                                     
LET v_fecha_venc      = "          ";                            
LET v_ciclo           = 0;   
LET sBandera          =0;                                    

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cCapInt,cInstruccion,mImporte, cCuentaDeposito;						
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_cons_instvento.out";
	--TRACE ON;
		
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA   = ''	THEN 
		LET cCodRet = "00040";
		RETURN cCodRet,cCapInt,cInstruccion,mImporte, cCuentaDeposito;
	END IF;	
	
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cCapInt,cInstruccion,mImporte, cCuentaDeposito;	
	END IF;
	
	SELECT NVL(COUNT(cuenta),0)	INTO iexiste FROM  bdinvers:sv_maeinv WHERE cuenta  = cNUMCUENTA;
	IF iexiste  = 0 THEN 
	LET cCodRet = "00041";
	RETURN cCodRet,cCapInt,cInstruccion,mImporte, cCuentaDeposito;
	END IF;

	SET ISOLATION TO DIRTY READ;

	FOREACH
        SELECT m.cap_int,trim(i.descripcion) instrucc,m.importe,m.cta_cheques 
        INTO cCapInt,cInstruccion,mImporte, cCuentaDeposito
        FROM bdinvers:sv_maeinstrucc m,bdinvers:sv_instrucc i 
        WHERE m.empresa = '001' and m.cuenta = cNUMCUENTA
        AND i.empresa = m.empresa and inst_vento = codigo
        
        LET sBandera=1;
		RETURN 	cCodRet,cCapInt,cInstruccion,mImporte, cCuentaDeposito WITH Resume;
	
	END FOREACH

    IF sBandera=0 THEN
        LET cCodRet='00099';
        RETURN cCodRet,cCapInt,cInstruccion,mImporte, cCuentaDeposito;
    END IF;

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de las Instrucciones a ejecutar al vencimiento de una Cuenta de Inversión. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de cuenta.",
"FECHA : 15-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultarprogramaciongeneral_ofi(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cCVEPROG CHAR(10))
							
			returning   CHAR(5)       AS Cod_Retorno,
						CHAR(20)      AS Cuenta_Origen,
						CHAR(20)      AS Cuenta_Destino,
						MONEY(16,2)   AS Monto,
						CHAR(60)      AS Concepto,	      
						CHAR(60)      AS Nombre,	      
						CHAR(40)      AS Banco,          
						CHAR(40)      AS Referencia,
						CHAR(60)      AS Proveedor,
						CHAR(70)      AS Tipo_Pago,
						CHAR(10)      AS Porcentaje,
						CHAR(20)      AS Referencia_2,
						CHAR(40)      AS Referencia_Cobranza,
						MONEY(16,2)   AS IVA_Cobranza,
						CHAR(15)      AS Desc_Frecuencia,
						CHAR(20)      AS Desc_Frecuencia_Diaria,
						INTEGER       AS Cada_X_Dias,
						INTEGER       AS Indicador_Frecuencia_Semanal,
						CHAR(07)      AS Repetir_Cada,						
						INTEGER       AS El_1,
						INTEGER       AS El_2,
						CHAR(15)      AS El_Dia,
						CHAR(15)      AS De_Cada,
						INTEGER       AS Indicador_Frecuencia_Mensual,
						DATE          AS Comienzo_O_Fecha_Pago,
						INTEGER       AS Finalizar_Despues_De,
						DATE          AS Finalizar_El,
						CHAR(04)      AS Sucursal,
						CHAR(100)     AS Mensaje,
						CHAR(30)      AS Compania_Emisor,
						CHAR(10)      AS Numero_Celular_Emisor,
						CHAR(40)      AS E_Mail_Emisor,
						CHAR(30)      AS Compania_Receptor,
						CHAR(10)      AS Numero_Celular_Receptor,
						CHAR(40)      AS E_Mail_Receptor,
                        CHAR(2)       AS SistemaCuentaOrigen,  
                        CHAR(2)       AS SistemaCuentaDestino;
							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;		
					
--VARIABLES
DEFINE cConcepto        				CHAR(60);
DEFINE cBanco           				CHAR(40);
DEFINE cPorcentaje                      CHAR(10);
DEFINE iIndicadorFrecuenciaMensual      INTEGER;
DEFINE cCompaniaEmisor                  CHAR(30);
DEFINE cCompaniaReceptor                CHAR(30);
  
DEFINE cProvedor                        CHAR(60);      
DEFINE cFrecuencia                      CHAR(15);    
DEFINE cDescFrecuenciaDiaria            CHAR(20); 
DEFINE cDescElDia                       CHAR(15);
DEFINE cDescDeCada                      CHAR(15);
DEFINE cSucursal                        CHAR(04);   


--ADICIONALES
DEFINE v_scve_pagoprog 				CHAR(10);
DEFINE v_snum_cte 					CHAR(20);
DEFINE v_sdescripcion 				CHAR(20);
DEFINE v_scve_pago 					CHAR(2);
DEFINE v_scve_cuenta_ori 			CHAR(2);
DEFINE v_scuenta_origen 			CHAR(20);
DEFINE v_scve_cuenta_dest 			CHAR(2);
DEFINE v_scuenta_destino 			CHAR(20);
DEFINE v_sbanco_destino 			CHAR(3);
DEFINE v_sreferencia1 				CHAR(40);
DEFINE v_sreferencia2 				CHAR(20);
DEFINE v_sconvenio 					CHAR(5);
DEFINE v_mimporte 					MONEY(16,2);
DEFINE v_sref_cobranza 				CHAR(40);
DEFINE v_mimporte_iva 				MONEY(16,2);
DEFINE v_itipo_spei 				INTEGER;
DEFINE v_sconcepto 					CHAR(70);
DEFINE v_dfecha_inicio 				DATE;
DEFINE v_scve_final 				CHAR(2);
DEFINE v_ino_repeticiones 			INTEGER;
DEFINE v_dfecha_fin 				DATE;
DEFINE v_scve_programa 				CHAR(2);
DEFINE v_stipo_diaria 				CHAR(2);
DEFINE v_icada_x_dias 				INTEGER;
DEFINE v_icada_x_semanas 			INTEGER;
DEFINE v_sdias_semana 				CHAR(7);
DEFINE v_stipo_mensual				CHAR(2);
DEFINE v_idia_x_del_mes 			INTEGER;
DEFINE v_icada_x_meses 				INTEGER;
DEFINE v_scve_ocurre 				CHAR(2);
DEFINE v_scve_dia 					CHAR(2);
DEFINE v_scve_canal 				CHAR(2);
DEFINE v_scve_notifica 				CHAR(2);
DEFINE v_sben_email 				CHAR(40);
DEFINE v_sben_cve_compania 			CHAR(2);
DEFINE v_sben_celular 				CHAR(10);
DEFINE v_scve_notifica_emi			CHAR(2);
DEFINE v_semi_email 				CHAR(40);
DEFINE v_semi_cve_compania 			CHAR(2);
DEFINE v_semi_celular 				CHAR(10);
DEFINE v_smensaje 					CHAR(100);
DEFINE v_scve_estado 				CHAR(2);
DEFINE v_suser_insert 				CHAR(8);
DEFINE v_dfecha_insert 				DATE;
DEFINE v_suser_cancela				CHAR(8);
DEFINE v_dfecha_cancela 			DATE;
DEFINE v_scanal_cancela 			CHAR(2);
DEFINE v_nombre 					CHAR(60);   
DEFINE vSistemaCtaO                 CHAR(2);
DEFINE vSistemaCtaD                 CHAR(2);


--PARA PAGINACION
DEFINE iCont                INTEGER;

LET cConcepto          = '';
LET cBanco             = '';
LET cPorcentaje        = '';
LET iIndicadorFrecuenciaMensual = 0;
LET cCompaniaEmisor       = '';
LET cCompaniaReceptor     = '';

LET cProvedor                   = '';   
LET cFrecuencia                 = ''; 
LET cDescFrecuenciaDiaria       = ''; 
LET cDescElDia                  = '';  
LET cDescDeCada                 = ''; 
LET cSucursal                   = ''; 



--ADICIONALES

LET v_scve_pagoprog			 = '';
LET v_snum_cte               = '';
LET v_sdescripcion 			 = '';
LET v_scve_pago 			 = '';
LET v_scve_cuenta_ori 		 = '';
LET v_scuenta_origen 		 = '';
LET v_scve_cuenta_dest 		 = '';
LET v_scuenta_destino 		 = '';
LET v_sbanco_destino 		 = '';
LET v_sreferencia1 			 = '';
LET v_sreferencia2 			 = '';
LET v_sconvenio 			 = '';
LET v_mimporte 				 = 0.00;
LET v_sref_cobranza 		 = '';
LET v_mimporte_iva 			 = 0.00;
LET v_itipo_spei 		     = 0;
LET v_sconcepto 			 = '';
LET v_dfecha_inicio 		 = '';
LET v_scve_final			 = '';
LET v_ino_repeticiones		 = 0;
LET v_dfecha_fin 			 = '';
LET v_scve_programa 		 = '';
LET v_stipo_diaria 			 = '';
LET v_icada_x_dias 			 = 0;
LET v_icada_x_semanas 		 = 0;
LET v_sdias_semana 			 = '';
LET v_stipo_mensual 		 = '';
LET v_idia_x_del_mes 		 = 0;
LET v_icada_x_meses 		 = 0;
LET v_scve_ocurre 			 = '';
LET v_scve_dia 				 = '';
LET v_scve_canal		 	 = '';
 LET v_scve_notifica 		 = '';
LET v_sben_email 			 = '';
LET v_sben_cve_compania		 = '';
LET v_sben_celular			 = '';
LET v_scve_notifica_emi 	 = '';
LET v_semi_email			 = '';
LET v_semi_cve_compania		 = '';
LET v_semi_celular 			 = '';
LET v_smensaje 				 = '';
LET v_scve_estado 			 = '';
LET v_dfecha_insert			 = '';
LET v_suser_cancela			 = '';
LET v_dfecha_cancela 		 = '';
LET v_scanal_cancela		 = '';
LET v_nombre 				 = "";
LET v_suser_insert			 = "";
LET vSistemaCtaO             ='';
LET vSistemaCtaD             ='';


LET iCont            = 0;
   
--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;
                              

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN  cCodRet,v_scuenta_origen,v_scuenta_destino,v_mimporte, cConcepto, v_nombre,cBanco, v_sreferencia1, cProvedor, v_sconcepto, cPorcentaje, v_sreferencia2, v_sref_cobranza,            
					v_mimporte_iva,cFrecuencia,cDescFrecuenciaDiaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_idia_x_del_mes,v_icada_x_meses,cDescElDia,cDescDeCada,iIndicadorFrecuenciaMensual,                
					v_dfecha_inicio,v_ino_repeticiones,v_dfecha_fin,cSucursal,v_smensaje,cCompaniaEmisor,v_semi_celular,v_semi_email,cCompaniaReceptor,           
					v_sben_celular,v_sben_email,vSistemaCtaO,vSistemaCtaD;                                                                                                                            
		END IF;
	END EXCEPTION;
	
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultarprogramaciongeneral_ofi_2.out";
	--	TRACE ON;
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'26','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	 RETURN cCodRet,v_scuenta_origen,v_scuenta_destino,v_mimporte, cConcepto, v_nombre,cBanco, v_sreferencia1, cProvedor, v_sconcepto, cPorcentaje, v_sreferencia2, v_sref_cobranza,            
				v_mimporte_iva,cFrecuencia,cDescFrecuenciaDiaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_idia_x_del_mes,v_icada_x_meses,cDescElDia,cDescDeCada,iIndicadorFrecuenciaMensual,                
				v_dfecha_inicio,v_ino_repeticiones,v_dfecha_fin,cSucursal,v_smensaje,cCompaniaEmisor,v_semi_celular,v_semi_email,cCompaniaReceptor,           
				v_sben_celular,v_sben_email,vSistemaCtaO,vSistemaCtaD;    
	END IF;
	-- TERMINA VALIDACION
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cCVEPROG     =  ''  OR
		cNUMCLIENTE   = ''	THEN 
		LET cCodRet = "00067";
		RETURN  cCodRet,v_scuenta_origen,v_scuenta_destino,v_mimporte, cConcepto, v_nombre,cBanco, v_sreferencia1, cProvedor, v_sconcepto, cPorcentaje, v_sreferencia2, v_sref_cobranza,            
				v_mimporte_iva,cFrecuencia,cDescFrecuenciaDiaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_idia_x_del_mes,v_icada_x_meses,cDescElDia,cDescDeCada,iIndicadorFrecuenciaMensual,                
				v_dfecha_inicio,v_ino_repeticiones,v_dfecha_fin,cSucursal,v_smensaje,cCompaniaEmisor,v_semi_celular,v_semi_email,cCompaniaReceptor,           
				v_sben_celular,v_sben_email,vSistemaCtaO,vSistemaCtaD;    
	END IF;	
	

	SELECT NVL(COUNT(num_cte),0)	INTO iexiste FROM  bdiprog:pp_pagoprog WHERE num_cte  = cNUMCLIENTE;
	IF iexiste  = 0 THEN 
	LET cCodRet = "00085";
	RETURN  cCodRet,v_scuenta_origen,v_scuenta_destino,v_mimporte, cConcepto, v_nombre,cBanco, v_sreferencia1, cProvedor, v_sconcepto, cPorcentaje, v_sreferencia2, v_sref_cobranza,            
			v_mimporte_iva,cFrecuencia,cDescFrecuenciaDiaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_idia_x_del_mes,v_icada_x_meses,cDescElDia,cDescDeCada,iIndicadorFrecuenciaMensual,                
			v_dfecha_inicio,v_ino_repeticiones,v_dfecha_fin,cSucursal,v_smensaje,cCompaniaEmisor,v_semi_celular,v_semi_email,cCompaniaReceptor,           
			v_sben_celular,v_sben_email,vSistemaCtaO,vSistemaCtaD;    
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE bdiprog:sp_consultarprogramaciongeneral_ofi(cNUMCLIENTE,cCVEPROG)
	INTO
	cCodRet, v_scve_pagoprog,v_snum_cte, v_sdescripcion, v_scve_pago,v_scve_cuenta_ori,v_scuenta_origen,v_scve_cuenta_dest,              
	v_scuenta_destino,v_sbanco_destino,v_sreferencia1,v_sreferencia2,v_sconvenio,v_mimporte,v_sref_cobranza,                                                                          
	v_mimporte_iva,v_itipo_spei,v_sconcepto,v_dfecha_inicio,v_scve_final,v_ino_repeticiones,v_dfecha_fin,
	v_scve_programa,v_stipo_diaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_stipo_mensual,v_idia_x_del_mes,	
	v_icada_x_meses,v_scve_ocurre,v_scve_dia,v_scve_canal,v_scve_notifica,v_sben_email,v_sben_cve_compania,
	v_sben_celular,v_scve_notifica_emi,v_semi_email,v_semi_cve_compania,v_semi_celular,v_smensaje,v_scve_estado,
	v_suser_insert,v_dfecha_insert,v_suser_cancela,v_dfecha_cancela,v_scanal_cancela, v_nombre;
	
	
	IF cCodRet != '00000' THEN
		RETURN  cCodRet,v_scuenta_origen,v_scuenta_destino,v_mimporte, cConcepto, v_nombre,cBanco, v_sreferencia1, cProvedor, v_sconcepto, cPorcentaje, v_sreferencia2, v_sref_cobranza,            
				v_mimporte_iva,cFrecuencia,cDescFrecuenciaDiaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_idia_x_del_mes,v_icada_x_meses,cDescElDia,cDescDeCada,iIndicadorFrecuenciaMensual,                
				v_dfecha_inicio,v_ino_repeticiones,v_dfecha_fin,cSucursal,v_smensaje,cCompaniaEmisor,v_semi_celular,v_semi_email,cCompaniaReceptor,           
				v_sben_celular,v_sben_email,vSistemaCtaO,vSistemaCtaD;    
	END IF
	

	SELECT UPPER(descripcion)
	INTO v_sconcepto
	FROM bdiprog:pp_tppago 
	WHERE cve_pago = v_scve_pago;
	
	IF v_scve_programa = '01' THEN
		LET cFrecuencia = 'DIARIO';
	ELIF v_scve_programa = '02' THEN
		LET cFrecuencia = 'SEMANAL';
	ELIF v_scve_programa = '03' THEN
		LET cFrecuencia = 'MENSUAL';
	ELIF v_scve_programa = '04' THEN
		LET cFrecuencia = 'UNICA';
	ELSE
		LET cFrecuencia = '';
	END IF
	
	IF v_stipo_diaria = '01' THEN
		LET cDescFrecuenciaDiaria = 'LUNES A DOMINGO';
	ELIF v_stipo_diaria = '02' THEN
		LET cDescFrecuenciaDiaria = 'LUNES A VIERNES';
	ELSE
		LET cDescFrecuenciaDiaria = '';
	END IF
	
	IF v_stipo_mensual = '02' THEN
		LET iIndicadorFrecuenciaMensual = v_icada_x_meses;
		LET v_icada_x_meses = 0;
	END IF
	
	IF v_scve_ocurre = 1 THEN 
		LET cDescElDia = 'PRIMERO';
	ELIF v_scve_ocurre = 2 THEN 
		LET cDescElDia = 'SEGUNDO';
	ELIF v_scve_ocurre = 3 THEN 
		LET cDescElDia = 'TERCERO';
	ELIF v_scve_ocurre = 4 THEN 
		LET cDescElDia = 'CUARTO';
	ELIF v_scve_ocurre = 5 THEN 
		LET cDescElDia = 'QUINTO';
	ELIF v_scve_ocurre = 6 THEN 
		LET cDescElDia = 'ULTIMO';
	END IF
	
	IF v_scve_dia = '01' THEN 
		LET cDescDeCada = 'LUNES';
	ELIF v_scve_dia = '02' THEN 
		LET cDescDeCada = 'MARTES';
	ELIF v_scve_dia = '03' THEN 
		LET cDescDeCada = 'MIERCOLES';
	ELIF v_scve_dia = '04' THEN 
		LET cDescDeCada = 'JUEVES';
	ELIF v_scve_dia = '05' THEN 
		LET cDescDeCada = 'VIERNES';
	ELIF v_scve_dia = '06' THEN 
		LET cDescDeCada = 'SABADO';
	ELIF v_scve_dia = '07' THEN 
		LET cDescDeCada = 'DOMINGO';
	END IF
	
	IF v_scve_pago = '05' THEN
		IF v_itipo_spei = 1 THEN
			LET cPorcentaje = 'FIJO';
		ELIF v_itipo_spei = 2 THEN
			LET cPorcentaje = 'MINIMO';
		ELIF v_itipo_spei = 3 THEN
			LET cPorcentaje = 'TOTAL';
		END IF
	END IF
	
	SELECT descripcion
	INTO cConcepto	
	FROM bdiprog:pp_pagoprog 
	WHERE num_cte = cNUMCLIENTE 
	AND cve_pagoprog = cCVEPROG;
	
	SELECT sucursal
	INTO cSucursal
	FROM si_ejecut
	WHERE ejecutivo = v_suser_insert;

	SELECT descripcion
	INTO cBanco
	FROM si_bancos
	WHERE banco = v_sbanco_destino;
	
	SELECT nomconvenio
	INTO cProvedor
	FROM bdisac:sac_convenios
	WHERE numcategoria  = SUBSTR(v_sconvenio,1,2)
	AND   numconvenio = SUBSTR(v_sconvenio,3,3);
	
	SELECT UPPER(descripcion)
	INTO cCompaniaReceptor
	FROM bdiprog:pp_companias
	WHERE cve_compania = v_sben_cve_compania;
	
	SELECT UPPER(descripcion)
	INTO cCompaniaEmisor
	FROM bdiprog:pp_companias
	WHERE cve_compania = v_semi_cve_compania;

    IF v_scve_pago='01' THEN
        LET vSistemaCtaO='01';
        LET vSistemaCtaD='01';
    ELIF v_scve_pago='02' THEN
        LET vSistemaCtaO='01';
        LET vSistemaCtaD='01';
    ELIF v_scve_pago='03' THEN
        LET vSistemaCtaO='01';
        LET vSistemaCtaD='00';
    ELIF v_scve_pago='04' THEN
        LET vSistemaCtaO='01';
        LET vSistemaCtaD='00';
    ELIF v_scve_pago='05' THEN
        LET vSistemaCtaO='01';
        LET vSistemaCtaD='06';
    ELIF v_scve_pago='06' THEN
        LET vSistemaCtaO='01';
        LET vSistemaCtaD='00';
    ELIF v_scve_pago='07' THEN
        LET vSistemaCtaO='01';
        LET vSistemaCtaD='00';
    ELSE
        LET vSistemaCtaO='00';
        LET vSistemaCtaD='00';
    END IF;


	RETURN  cCodRet,v_scuenta_origen,v_scuenta_destino,v_mimporte, cConcepto, v_nombre,cBanco, v_sreferencia1, cProvedor, v_sconcepto, cPorcentaje, v_sreferencia2, v_sref_cobranza,            
			v_mimporte_iva,cFrecuencia,cDescFrecuenciaDiaria,v_icada_x_dias,v_icada_x_semanas,v_sdias_semana,v_idia_x_del_mes,v_icada_x_meses,cDescElDia,cDescDeCada,iIndicadorFrecuenciaMensual,                
			v_dfecha_inicio,v_ino_repeticiones,v_dfecha_fin,cSucursal,v_smensaje,cCompaniaEmisor,v_semi_celular,v_semi_email,cCompaniaReceptor,           
			v_sben_celular,v_sben_email,vSistemaCtaO,vSistemaCtaD;    

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información general de los Pagos Programados asociados a un Cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de Cliente.",
"FECHA : 02-abril-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_detallereportetransaccionesprogramadas(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cCVEPROGRAMACION CHAR(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
			returning   CHAR(5)      		  AS Cod_Retorno,
						DATE                  AS Fecha_Programacion,
						MONEY(16,2)    		  AS Importe,
						CHAR(30)    		  AS Estado,
						DATE    		      AS Fecha_Estado,
						CHAR(50)    		  AS Causa_Rechazo;	
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE dFechaProgramacion    DATE;
DEFINE mImporte	       		 MONEY(16,2);
DEFINE cEstado	       		 CHAR(30);
DEFINE dFechaEstado		   	 DATE;
DEFINE cCausaRechazo		 CHAR(50);
DEFINE cCveRechazo           CHAR(5);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--INICIALIZA VARIABLES
LET  iexiste 		    = 0;
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	
LET dFechaProgramacion       = "";
LET mImporte 				 = 0;
LET cEstado		  	         = "";
LET dFechaEstado			 = '';
LET cCausaRechazo		     = '';
LET cCveRechazo              = '';
--VARIABLES DE PAGINACION 
LET iCont       = 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN  cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo;
		END IF;
	END EXCEPTION;

--	SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_detallereportetransaccionesprogramadas_2.out";
--	TRACE ON;

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo;
        END IF;
    END IF;  
    --VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'26','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	 RETURN cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo;
	END IF;
	-- TERMINA VALIDACION
	IF 	cID_USUARIOC 	 = "" 	OR
		cID_FUNCIONC 	 = ""   OR
		cCVEPROGRAMACION = ''   OR
		cNUMCLIENTE      = '' THEN 
		LET cCodRet = "00067";
		RETURN cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo;
	END IF;	

    --VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'26','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	 RETURN cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo;
	END IF;
	-- TERMINA VALIDACION
	
	SELECT NVL(COUNT(numcte),0) into iexiste FROM bdinteg:si_cliente WHERE numcte = cNUMCLIENTE;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00085";
		RETURN  cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo;
	END IF;

	IF EXISTS (SELECT  ppe.fecha_prog FROM  bdiprog: pp_pagospend ppe, bdiprog: pp_pagoprog pp, bdiprog: pp_estados e
                WHERE ppe.cve_pagoprog = pp.cve_pagoprog AND ppe.cve_pagoprog  = cCVEPROGRAMACION AND pp.num_cte = cNUMCLIENTE AND ppe.estado = e.cve_estado) THEN

        FOREACH
            SELECT  SKIP pNumRegistro FIRST pRecuperacion
            ppe.fecha_prog, pp.importe, e.descripcion,  
			decode(ppe.estado,'02',ppe.fecha_cancela,'06',ppe.fecha_cancela,'05',ppe.fecha_aplic),ppe.cve_rechazo			
            INTO dFechaProgramacion, mImporte, cEstado, dFechaEstado,cCveRechazo
            FROM  bdiprog:pp_pagospend ppe, bdiprog:pp_pagoprog pp, bdiprog:pp_estados e
            WHERE ppe.cve_pagoprog = pp.cve_pagoprog
            AND ppe.cve_pagoprog  = cCVEPROGRAMACION
            AND pp.num_cte = cNUMCLIENTE
            AND ppe.estado = e.cve_estado
            ORDER BY ppe.consecutivo

            IF dFechaProgramacion IS NULL THEN
                LET dFechaProgramacion = "";
            END IF

            IF dFechaEstado IS NULL THEN
                LET dFechaEstado ="";
            END IF

			IF cCveRechazo != '' THEN
				SELECT {+INDEX (bdiprog:pp_tprechazo 123_28)} descripcion
				INTO cCausaRechazo
				FROM bdiprog:pp_tprechazo
				WHERE  cve_rechazo = cCveRechazo;
			END IF

			LET iCont = iCont + 1;

            RETURN cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo WITH RESUME;

         END FOREACH;

		 IF iCont = 0 THEN
			LET cCodRet = 1001; 
			RETURN cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo;
		END IF
	ELSE
		LET cCodRet = "00068";
		RETURN cCodRet,dFechaProgramacion,mImporte,cEstado,dFechaEstado,cCausaRechazo;
	END IF

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información del Detalle General por Pago Programado asociado a un cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el Número de Cliente, Programación  y Tipo Pago.",
"FECHA : 26-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_ideconsultageneral(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cPERIODO CHAR(06))
							
			returning   CHAR(5)     AS Cod_Retorno,          
						MONEY(16,2) AS Total_Depositos,
						MONEY(16,2) AS Monto_Excedente,
						MONEY(16,2) AS Impuesto_Determinado,	      
                        MONEY(16,2) AS Impuesto_Recaudado,
                        MONEY(16,2) AS Impuesto_Pendiente_Recaudar,
                        CHAR (6) AS Periodo;

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;		

DEFINE v_cod_ret    		   CHAR(5);
DEFINE mTotalDepositos  	   MONEY(16,2);
DEFINE mMontoExcedente   	   MONEY(16,2);
DEFINE mImpuestoDeterminado    MONEY(16,2);
DEFINE vImprecaudado           MONEY(16,2);
DEFINE vImppendiente           MONEY(16,2);
DEFINE vImpperiodosant         MONEY(16,2);

LET  v_cod_ret   			 = "00000";
LET mTotalDepositos  		= 0;
LET mMontoExcedente     	= 0;
LET mImpuestoDeterminado    = 0;
LET vImprecaudado           = 0;
LET vImppendiente           = 0;
LET vImpperiodosant         = 0;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;                         

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 	cCodRet,mTotalDepositos,mMontoExcedente,mImpuestoDeterminado,vImprecaudado,vImppendiente,cPERIODO;
		END IF;
	END EXCEPTION;
	
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_ideconsultageneral.out";
	--  TRACE ON;

	IF 	cID_USUARIOC  = '' 	OR
		cID_FUNCIONC  = '' 	OR
		cNUMCLIENTE   = ''	OR
		cPERIODO      = ''  THEN 
		LET cCodRet = "00060";
		RETURN 	cCodRet,mTotalDepositos,mMontoExcedente,mImpuestoDeterminado,vImprecaudado,vImppendiente,cPERIODO;
	END IF;	

	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'23','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,mTotalDepositos,mMontoExcedente,mImpuestoDeterminado,vImprecaudado,vImppendiente,cPERIODO;
	END IF;
	-- TERMINA VALIDACION

	--SELECT NVL(COUNT(num_cte),0)	INTO iexiste FROM  bdilide:sl_retlide WHERE num_cte  = cNUMCLIENTE  AND aniomes = cPERIODO;
	SELECT NVL(COUNT(numcte),0)	INTO iexiste FROM bdinteg:si_cliente WHERE numcte  = cNUMCLIENTE;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00062";
		RETURN 	cCodRet,mTotalDepositos,mMontoExcedente,mImpuestoDeterminado,vImprecaudado,vImppendiente,cPERIODO;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	
	EXECUTE PROCEDURE bdilide:sp_ideconsultageneral(cNUMCLIENTE, cPERIODO, cPERIODO)
	INTO
	v_cod_ret, mMontoExcedente,mImpuestoDeterminado,vImprecaudado, vImppendiente,mTotalDepositos,vImpperiodosant;
				
	IF LENGTH(v_cod_ret) = 3 THEN
		LET  cCodRet = '00' || v_cod_ret;
	ELIF LENGTH(v_cod_ret) = 5 THEN
		LET  cCodRet = v_cod_ret;
	END IF
    
    IF cCodRet='000200' THEN
        LET  cCodRet ='00063';
    END IF;

	RETURN 	cCodRet,mTotalDepositos,mMontoExcedente,mImpuestoDeterminado,vImprecaudado,vImppendiente,cPERIODO;
		
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Totales de la Consulta de recaudaciones LIDE  de un Cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el Número de Cliente.",
"FECHA : 16-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_repmovtoside(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cPERIODO CHAR(07),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
			returning   CHAR(5)     AS Cod_Retorno,          
						MONEY(16,2) AS Monto_Excedente,
						MONEY(16,2) AS IDE_Determinado,
						MONEY(16,2) AS IDE_Recaudado,
						MONEY(16,2) AS IDE_Pendiente_Recaudar,
						MONEY(16,2) AS IDE_Recuadado_Per_Ant;
						
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;

DEFINE cPeriodos               CHAR(06);
DEFINE v_cod_ret    		   CHAR(5);

DEFINE mImparecaudar 		   MONEY(16,2);
DEFINE mImprecaudado 		   MONEY(16,2);
DEFINE mTotalDepositos  	   MONEY(16,2);
DEFINE mMontoExcedente   	   MONEY(16,2);
DEFINE mImpuestoDeterminado    MONEY(16,2);
DEFINE mImpRemPerAnt           MONEY(16,2); 

--PARA PAGINACION
DEFINE iCont                INTEGER;

LET cPeriodos             = '';
LET  v_cod_ret   		  = "00000";

LET mImparecaudar 		  = 0;
LET mImprecaudado  		  = 0;
LET mTotalDepositos  		= 0;
LET mMontoExcedente     	= 0;
LET mImpuestoDeterminado    = 0;
LET mImpRemPerAnt           = 0;

LET iCont                   = 0;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;                         

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
		END IF
	END EXCEPTION
	
	  --    SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_repmovtoside.out";
		--  TRACE ON;
	
	IF 	cID_USUARIOC  = '' 	OR
		cID_FUNCIONC  = '' 	OR
		cNUMCLIENTE   = ''	OR
		cPERIODO      = ''  THEN 
		LET cCodRet = "00060";
		RETURN cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
	END IF

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
        END IF;
    END IF;    
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'23','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
	END IF;
	-- TERMINA VALIDACION

	LET cPeriodos = SUBSTR(cPERIODO,4,4) ||  SUBSTR(cPERIODO,1,2);
	
	SELECT NVL(COUNT(numcte),0)	INTO iexiste FROM bdinteg:si_cliente WHERE numcte  = cNUMCLIENTE;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00062";
		RETURN cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
	END IF
	
	IF pNumRegistro = 0 THEN
		
		DELETE FROM si_temporepmovtoside WHERE num_cte  = cNUMCLIENTE AND aniomes = cPeriodos AND ejecutivosif= cID_USUARIOC;
		
		SET ISOLATION TO DIRTY READ;
		
		EXECUTE PROCEDURE bdilide:sp_ideconsultageneral(cNUMCLIENTE,cPeriodos,cPeriodos)
		INTO
		cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mTotalDepositos,mImpRemPerAnt;
		
		IF cCodRet = '200' THEN
			LET  cCodRet = '00063';
			RETURN cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
		END IF
		
		IF LENGTH(cCodRet) = 3 THEN
			LET cCodRet = '00' || cCodRet;
		END IF

		IF cCodRet != '00000' THEN
			RETURN cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
		END IF
		
		INSERT INTO si_temporepmovtoside(cod_ret,montoexcedente,impuestodeterminado,ide_recaudado,ide_pend_reca,ide_reca_anios_ant,num_cte,aniomes,ejecutivosif)
		VALUES(cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt,cNUMCLIENTE,cPeriodos,cID_USUARIOC);				

		SELECT NVL(COUNT(cod_ret),0) into iexiste FROM si_temporepmovtoside WHERE num_cte = cNUMCLIENTE AND aniomes = cPeriodos AND ejecutivosif= cID_USUARIOC;
		IF iexiste  = 0 THEN 
			LET cCodRet = "00091";
			RETURN 	cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
		END IF;	

	END IF
	
	SET ISOLATION TO DIRTY READ;
	
	FOREACH
	
		SELECT SKIP pNumRegistro FIRST pRecuperacion
		cod_ret,montoexcedente,impuestodeterminado,ide_recaudado,ide_pend_reca,ide_reca_anios_ant
		INTO
		v_cod_ret, mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt
		FROM si_temporepmovtoside
		WHERE num_cte  = cNUMCLIENTE
		AND aniomes = cPeriodos AND ejecutivosif= cID_USUARIOC
		
		IF LENGTH(v_cod_ret) = 3 THEN
			LET  cCodRet = '00' || v_cod_ret;
		ELIF LENGTH(v_cod_ret) = 5 THEN
			LET  cCodRet = v_cod_ret;
		END IF
		
		LET iCont = iCont + 1;
		
		RETURN 	cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt WITH Resume;
		
	END FOREACH
	
	IF iCont = 0 THEN
		DELETE FROM si_temporepmovtoside WHERE num_cte = cNUMCLIENTE AND aniomes = cPeriodos AND ejecutivosif= cID_USUARIOC;
		LET cCodRet = '1001'; 
		RETURN 	cCodRet,mMontoExcedente,mImpuestoDeterminado,mImprecaudado,mImparecaudar,mImpRemPerAnt;
	END IF; 
		
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de datos generales necesarios para generar el Reporte de Movimientos en Efectivo que causaron IDE. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Folio.",
"FECHA : 20-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cnsif_indcred(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)  AS Cod_Retorno,      
						  DATE     AS Fecha_Actualizacion,          
						  DATE     AS Fecha_Ultimo_Pago, 
						  DECIMAL(18,2) AS Monto_Ultimo_Pago, 
						  CHAR(4)  AS Transaccion_Ultimo_Pago, 
						  DATE     AS Fecha_Ultima_Disposicion,          
						  DECIMAL(18,2) AS Importe_Ultima_Disposicion, 
                          CHAR(4)  AS Transaccion_Ultima_Disposicion,          
						  DATE     AS Fecha_Ultima_Compra,    
						  DECIMAL(18,2) AS Importe_Ultima_Compra, 
                          CHAR(4)  AS Transaccion_Ultima_Compra, 
						  DATE     AS Fecha_Ultima_Disp_Ventanilla,         
						  DECIMAL(18,2) AS Importe_Ultima_Disp_Ventanilla,
						  DATE     AS Fecha_Ultimo_Convenio,         
						  DECIMAL(18,2) AS Importe_Ultimo_Convenio, 
						  DATE      AS Fecha_Saldo_Maximo, 
						  DECIMAL(18,2) AS Importe_Saldo_Maximo, 
						  INTEGER   AS Numero_Disposiciones_ATM, 
						  DECIMAL(18,2) AS Importe_Disp_ATM, 
						  INTEGER   AS Numero_Disposiciones_POS,       
						  DECIMAL(18,2) AS Importe_Disp_POS, 
						  INTEGER   AS Numero_Disposiciones_Ventanilla, 
						  DECIMAL(18,2) AS Importe_Disp_Ventanilla, 
						  INTEGER   AS Numero_Pagos_Acumulados,  
						  DECIMAL(18,2) AS Importe_Pagos_Acumulados;
						   
							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
							
--VARIABLES STORE
DEFINE dFechaActualizacion     DATE;      
DEFINE dFechaUltimoPago        DATE;      
DEFINE decMontoUltPago         DECIMAL(18,2);     
DEFINE cTransaccionUltPago     CHAR(4);          
DEFINE dFechaUltimaDisp    	   DATE; 
DEFINE decImporteUltDisp       DECIMAL(18,2);      
DEFINE cTransaccionUlt     	   CHAR(4);       
DEFINE dFechaUltCompra     	   DATE;      
DEFINE decImporteUltCompra     DECIMAL(18,2);
DEFINE cTransaccionUltCompra   CHAR(4); 
DEFINE dFechaUltimaDispVent    DATE; 
DEFINE decImporteUltDispVent   DECIMAL(18,2);      
--DEFINE cTransaccionUltDispVent CHAR(20);
DEFINE dFechaUltConvenio   	   DATE;
DEFINE decImporteUltComvenio   DECIMAL(18,2);
DEFINE dFechaSaldoMaximo   	   DATE;
DEFINE decImporteSaldoMax      DECIMAL(18,2);
DEFINE iNumeroDispAtm          INTEGER;
DEFINE decImporteDispAtm       DECIMAL(18,2);
DEFINE iNumeroDispPos          INTEGER;
DEFINE decImporteDispPos       DECIMAL(18,2);
DEFINE iNumeroDispVent         INTEGER;
DEFINE decImporteDispVent      DECIMAL(18,2);
DEFINE iNumeroPagosAcum        INTEGER;
DEFINE decImportePagosAcum     DECIMAL(18,2);

--VARIABLES DE PAGINACION
DEFINE iCont            INT;

--inicializando variables
LET  iexiste 		 	   = 0;
LET cCodRet 		 	   = "00000";
LET iSql_err 		 	   = 0;

LET dFechaActualizacion     = "";
LET dFechaUltimoPago        = "";
LET decMontoUltPago         = 0;
LET cTransaccionUltPago     = "";
LET dFechaUltimaDisp        = "";
LET decImporteUltDisp  		    = 0;
LET cTransaccionUlt         = "";
LET dFechaUltCompra   	    = "";
LET decImporteUltCompra     = 0;
LET cTransaccionUltCompra   = "";
LET dFechaUltimaDispVent    = "";
LET decImporteUltDispVent  	= 0;
--LET cTransaccionUltDispVent = "";
LET dFechaUltConvenio   	= "";
LET decImporteUltComvenio   = 0;
LET dFechaSaldoMaximo   	= "";
LET decImporteSaldoMax      = 0;
LET iNumeroDispAtm          = 0;
LET decImporteDispAtm       = 0;
LET iNumeroDispPos          = 0;
LET decImporteDispPos       = 0;
LET iNumeroDispVent         = 0;
LET decImporteDispVent      = 0;
LET iNumeroPagosAcum        = 0;
LET decImportePagosAcum     = 0;

--VARIABLES DE PAGINACION 
LET iCont       = 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFechaActualizacion, dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
				   cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
				   iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum; 						
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_indcred_2.out";
	--TRACE ON;
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA   = ''   THEN 
		LET cCodRet = "00045";
		RETURN cCodRet,dFechaActualizacion, dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
			   cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
			   iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN cCodRet,dFechaActualizacion, dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
			   cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
			   iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFechaActualizacion, dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
                   cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
                   iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum;
        END IF;
    END IF;  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,dFechaActualizacion, dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
			   cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
			   iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum; 						
	END IF;
	-- TERMINA VALIDACION	

    FOREACH
        SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE empresa = '001' AND  num_credito = cNUMCUENTA 
        UNION
        SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE empresa = '001' AND  num_credito = cNUMCUENTA ORDER BY CONT DESC
    END FOREACH;
	IF iexiste  = 0 THEN 
	LET cCodRet = "00046";
	RETURN cCodRet,dFechaActualizacion, dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
		   cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
		   iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum;						
	END IF;

    FOREACH    
         SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT
         INTO iexiste
         FROM bdicred:sd_indicador_cred
         WHERE num_credito = cNUMCUENTA
         /*UNION
         SELECT NVL(COUNT(num_credito),0) AS CONT
         FROM bdicred:sd_indicador_cred_his
         WHERE num_credito = cNUMCUENTA ORDER BY CONT DESC*/
    END FOREACH;

     IF iexiste=0 THEN
        LET cCodRet='00090';
        RETURN cCodRet,dFechaActualizacion, dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
               cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
               iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum;     
     END IF;
	SET ISOLATION TO DIRTY READ;
	FOREACH 
	
	 SELECT SKIP pNumRegistro FIRST pRecuperacion
	 NVL(fecha_alta,''),NVL(fecha_ultimo_pago,''), NVL(monto_ultimo_pago,0), NVL(trans_ultimo_pago,''), NVL(atm_disp_fecha,''), NVL(atm_disp_monto,0), NVL(atm_disp_transacc,''), NVL(pos_disp_fecha,''), NVL(pos_disp_monto,0),
	 NVL(pos_disp_transacc,''), NVL(vnt_disp_fecha,''), NVL(vnt_disp_monto,0), NVL(fecha_ult_convenio,''), NVL(monto_ult_convenio,0), NVL(fecha_sdo_maximo,''), NVL(saldo_maximo,0),
	 NVL(num_atm,0), NVL(monto_atm,0), NVL(num_pos,0),NVL(monto_pos,0), NVL(num_vtn,0),NVL(monto_vtn,0), NVL(num_pagos,0), NVL(monto_pagos,0)
	 INTO 		
	  dFechaActualizacion,dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
	  cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
	  iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum
	 FROM bdicred:sd_indicador_cred
	 WHERE num_credito = cNUMCUENTA
	
	 /*UNION
	 SELECT 
	 NVL(fecha_insert,'01/01/1900'),NVL(fecha_ultimo_pago,'01/01/1900'), NVL(monto_ultimo_pago,0), NVL(trans_ultimo_pago,''), NVL(atm_disp_fecha,'01/01/1900'), NVL(atm_disp_monto,0), NVL(atm_disp_transacc,''), NVL(pos_disp_fecha,'01/01/1900'), NVL(pos_disp_monto,0),
	 NVL(pos_disp_transacc,''), NVL(vnt_disp_fecha,'01/01/1900'), NVL(vnt_disp_monto,0), NVL(fecha_ult_convenio,'01/01/1900'), NVL(monto_ult_convenio,0), NVL(fecha_sdo_maximo,'01/01/1900'), NVL(saldo_maximo,0),
	 NVL(num_atm,0), NVL(monto_atm,0), NVL(num_pos,0),NVL(monto_pos,0), NVL(num_vtn,0),NVL(monto_vtn,0), NVL(num_pagos,0), NVL(monto_pagos,0)
	 FROM bdicred:sd_indicador_cred_his
	 WHERE num_credito = cNUMCUENTA*/
	
	LET iCont = iCont +1 ;
	
	RETURN  cCodRet,dFechaActualizacion, dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
			cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
			iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum WITH RESUME;
	
	END FOREACH;
	
	IF iCont = 0 THEN
		LET cCodRet = 1001; 
		RETURN  cCodRet,dFechaActualizacion, dFechaUltimoPago, decMontoUltPago, cTransaccionUltPago, dFechaUltimaDisp, decImporteUltDisp, cTransaccionUlt, dFechaUltCompra, decImporteUltCompra,     
				cTransaccionUltCompra, dFechaUltimaDispVent, decImporteUltDispVent, dFechaUltConvenio, decImporteUltComvenio, dFechaSaldoMaximo, decImporteSaldoMax,      
				iNumeroDispAtm, decImporteDispAtm, iNumeroDispPos, decImporteDispPos, iNumeroDispVent, decImporteDispVent, iNumeroPagosAcum, decImportePagosAcum;
	END IF
			
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Indicadores asociados a una Cuenta de Crédito. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el No. de Cuenta",
"FECHA : 29-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

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