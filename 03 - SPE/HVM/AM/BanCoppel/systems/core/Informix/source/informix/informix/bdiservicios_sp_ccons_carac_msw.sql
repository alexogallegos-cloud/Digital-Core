CREATE PROCEDURE "informix".sp_ccons_carac_msw(	pcOrigen CHAR(4),
												pcCategoria CHAR(2),
												pcConvenio CHAR(3)) 
	RETURNING
		CHAR(5) 	AS codigo_de_respuesta,
		CHAR(30) 	AS mensaje,
		CHAR(20) 	AS trasaccion_sucursal,	
		CHAR(2) 	AS numcategoria,
		CHAR(3) 	AS numconvenio,	
		CHAR(50)	AS nom_serv,
		CHAR(50)	AS tituloform,
		CHAR(5)		AS forma_de_pago,	
		CHAR(1)		AS es_reversable,
		CHAR(40)	AS caracteristicas_de_label_1,
		CHAR(1)		AS tipo_text_1,
		CHAR(2)		AS long_text_1,
		CHAR(1)		AS valida_dv_1,
		CHAR(1)		AS mascara_1,
		CHAR(4)		AS cod_consulta_1,	
		CHAR(40)	AS caracteristicas_de_label_2,
		CHAR(1)		AS tipo_text_2,
		CHAR(2)		AS long_text_2,
		CHAR(1)		AS valida_dv_2,
		CHAR(4)		AS cod_consulta_2,
		CHAR(40)	AS caracteristicas_de_label_3,
		CHAR(1)		AS tipo_text_3,	
		CHAR(3)		AS long_text_3,
		CHAR(1)		AS valida_dv_3,
		CHAR(4)		AS cod_consulta_3,	
		CHAR(40)	AS caracteristicas_de_label_4,
		CHAR(1)		AS label_signo_4,
		CHAR(11)	AS monto_max_text_4,
		CHAR(1)		AS valida_imp_cond,
		CHAR(4)		AS cod_consulta_4,
		CHAR(1)		AS ind_cent_4,
		CHAR(1)		AS long_dv,
		CHAR(8)		AS fecha_actualizacion,
		CHAR(1)  	AS acepta_pg,
		CHAR(1)		AS encripta;

	
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  			INTEGER;
	DEFINE cPCodRet 			CHAR(5);
	
	DEFINE cCodRet              CHAR(5);
	DEFINE cMensaje				CHAR(30);
	DEFINE cTransacSuc			CHAR(20);
	DEFINE cCaegoria			CHAR(2);
	DEFINE cConvenio			CHAR(3);
	DEFINE cNomServ				CHAR(50);
	DEFINE cTituloForm			CHAR(50);
	DEFINE cFormaPago			CHAR(5);
	DEFINE cReversable			CHAR(1);
	DEFINE cCaracLabel1			CHAR(40);
	DEFINE cTipoText1			CHAR(1);
	DEFINE cLongText1			CHAR(2);
	DEFINE cValidaDV1			CHAR(1);
	DEFINE cMascara1			CHAR(1);
	DEFINE cCodConsulta1		CHAR(4);
	DEFINE cCaracLabel2			CHAR(40);
	DEFINE cTipoText2			CHAR(1);
	DEFINE cLongText2			CHAR(2);
	DEFINE cValidaDV2			CHAR(1);
	DEFINE cCodConsulta2		CHAR(4);
	DEFINE cCaracLabel3			CHAR(40);
	DEFINE cTipoText3			CHAR(1);
	DEFINE cLongText3			CHAR(2);
	DEFINE cValidaDV3			CHAR(1);
	DEFINE cCodConsulta3		CHAR(4);
	DEFINE cCaracLabel4			CHAR(40);
	DEFINE cLabelSigno4			CHAR(1);
	DEFINE cMontoMaxText4		CHAR(11);
	DEFINE cValida_Imp_Cond		CHAR(1);
	DEFINE cCodConsulta4		CHAR(4);
	DEFINE cIndCent4			CHAR(1);
	DEFINE cLongDV				CHAR(1);
	DEFINE dFechaAct			CHAR(10);
	DEFINE cFechaFormat			CHAR(8);
	DEFINE cAcepta_PG			CHAR(1);
	DEFINE cEncripta			CHAR(1);
			
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cPCodRet = '0';

	LET cCodRet  =   "00000";
	LET cMensaje = "";
	LET cTransacSuc	= '';
	LET cCaegoria = '';
	LET cConvenio = '';
	LET cNomServ = '';
	LET cTituloForm = '';
	LET cFormaPago = '';
	LET cReversable = '';
	LET cCaracLabel1 = '';
	LET cTipoText1 = '';
	LET cLongText1 = '';
	LET cValidaDV1 = '';
	LET cMascara1 = '';
	LET cCodConsulta1 = '';
	LET cCaracLabel2 = '';
	LET cTipoText2 = '';
	LET cLongText2 = '';
	LET cValidaDV2 = '';
	LET cCodConsulta2 = '';
	LET cCaracLabel3 = '';
	LET cTipoText3 = '';
	LET cLongText3 = '';
	LET cValidaDV3	= '';
	LET cCodConsulta3 = '';	
	LET cCaracLabel4 = '';
	LET cLabelSigno4 = '';
	LET cMontoMaxText4 = '';
	LET cValida_Imp_Cond = '';
	LET cCodConsulta4 = '';
	LET cIndCent4 = '';
	LET cLongDV = '';
	LET dFechaAct = '';
	LET cFechaFormat = '';
	LET cAcepta_PG = '';
	LET cEncripta = '';
	

--SET DEBUG FILE TO '/informix/andrescrespo/sp_cpagos_activos_msw.out';
--TRACE ON;

    BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
           
			LET cPCodRet = iSqlErr;
	  	
			LET cMensaje='Error desconocido';
						
			RETURN cCodRet, cMensaje, cTransacSuc, cCaegoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
					cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
					cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, 
					cCodConsulta4, cIndCent4, cLongDV, cFechaFormat, cAcepta_PG, cEncripta;
			
		
        END IF;
    END EXCEPTION;
	
--SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 10;
 
foreach	
	EXECUTE PROCEDURE bdisac:"informix".sp_cons_carac_msw(pcOrigen,pcCategoria,pcConvenio)
	into  cCodRet, cMensaje, cTransacSuc, cCaegoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
					cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
					cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, 
					cCodConsulta4, cIndCent4, cLongDV, cFechaFormat, cAcepta_PG, cEncripta
			
	RETURN cCodRet, cMensaje, cTransacSuc, cCaegoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
					cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
					cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, 
					cCodConsulta4, cIndCent4, cLongDV, cFechaFormat, cAcepta_PG, cEncripta
	with resume;
end foreach;


	END;
END PROCEDURE
