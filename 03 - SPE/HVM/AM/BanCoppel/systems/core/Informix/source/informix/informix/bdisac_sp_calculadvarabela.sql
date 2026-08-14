CREATE PROCEDURE  "informix".sp_calculadvarabela(pNumReferencia CHAR(8))
RETURNING 
	CHAR (5) AS CodigoRetorno,
	SMALLINT AS IerrcomCodigo,
	SMALLINT AS IerrcomSistema;

--DEFINICION DE LAS VARIABLES
DEFINE iSqlErr			INTEGER;
DEFINE iI 				INTEGER;
DEFINE iNoPeso 			INTEGER;
DEFINE iSuma 			INTEGER;
DEFINE iValorDigito 	INTEGER;
DEFINE iAux 			INTEGER;
DEFINE cCodRet 			CHAR(5);
DEFINE cNum1 			CHAR(1);
DEFINE cNum2 			CHAR(1);
DEFINE iDigVerCapturado INTEGER;
DEFINE iResiduo 		INTEGER;
DEFINE sIerrcomCodigo   SMALLINT;
DEFINE sIerrcomSistema  SMALLINT;

--INICIALIZACION DE LAS VARIABLES
LET iSqlErr			 = 0;
LET iNoPeso 		 = 0;
LET iSuma 			 = 0;
LET iAux			 = 0;
LET iValorDigito	 = 0;
LET cCodRet			 = '00003'; --SI NO ENTRA AL SP, QUE NO RETORNE UN CODIGO DE EXITO '00000'.
LET iI				 = 1;
LET cNum1			 = '0';
LET cNum2			 = '0';
LET iDigVerCapturado = 0;
LET iResiduo 		 = 0;
LET sIerrcomCodigo   = 0;
LET sIerrcomSistema  = 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet, sIerrcomCodigo, sIerrcomSistema;
	   END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1483/migrado/sp_calculadvarabela.out';
	--TRACE ON;		
	
	SET ISOLATION TO DIRTY READ;	
	
	IF LENGTH(TRIM(pNumReferencia)) = 8 THEN
		LET iDigVerCapturado = SUBSTR(pNumReferencia,8,1)::SMALLINT;
		
		FOR iI = 1 TO 7		
			LET iValorDigito = SUBSTR(pNumReferencia,iI,1)::SMALLINT;
			IF MOD(iI,2) = 1 THEN
				LET iNoPeso = 2;
			ELSE
				LET iNoPeso = 1;
			END IF;
				LET iAux = iValorDigito * iNoPeso;
			IF iAux > 9 THEN
				--raise notice ''Multiplicacion Mayor a 7 = %'', iAux ;
				LET cNum1 = SUBSTR(iAux::CHAR(2),1,1) ;
				LET cNum2 = SUBSTR(iAux::CHAR(2),2,1) ;
				LET iAux  = (cNum1::SMALLINT) + (cNum2::SMALLINT);
			END IF; 
			LET iSuma = iSuma + iAux;
		END FOR;		
		
		LET iResiduo = MOD(iSuma , 10);
		IF iResiduo > 0 THEN
			LET iValorDigito = 10 - iResiduo;
			IF iValorDigito = iDigVerCapturado THEN
				LET cCodRet = '00000'; 
			ELSE
				LET cCodRet = '00001'; --ESCENARIO: DIGITO VERIFICADOR INCORRECTO.
				LET sIerrcomCodigo = 91;
				LET sIerrcomSistema = 24;
			END IF;
		ELSE
			IF iResiduo = iDigVerCapturado THEN
				LET cCodRet ='00000';
			ELSE
				LET cCodRet = '00001'; --ESCENARIO: DIGITO VERIFICADOR INCORRECTO.
				LET sIerrcomCodigo = 91;
				LET sIerrcomSistema = 24;
			END IF;
		END IF;	
	ELSE
		--ESCENARIO: LA LONGITUD DE LA REFERENCIA NO ES VÁLIDA (47, 24) 
		LET cCodRet = '00002';
		LET sIerrcomCodigo = 47;
		LET sIerrcomSistema = 24;		
	END IF;

	RETURN cCodRet, sIerrcomCodigo, sIerrcomSistema;
		
END;
END PROCEDURE
DOCUMENT
'-------------------------------------------------------------------------------------------------------------',
'DESCRIPCION: Se convierte una funcion de sucursal a una rutina de central, atendiendo el folio 1483-MttoValRefPagServAVON, (procedimiento en central para validar el digito verificador para pago de servicios ARABELA)', 
'Valida si el digito verificador capturado en pagos Arabela es correcto. El numero de referencia Arabela es de 10 digitos  Regresa: 0 Digito verificador es correcto , 1 Digito verificador es incorrecto ,  2 Referencia diferente a 8 digitos.',
'MODIFICO: Antonio Cebreros Perez',
'FECHA: 24/02/2015',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_cons_carac_msw(pOrigen CHAR(4),pCategoria CHAR(2),pConvenio CHAR(3))
	RETURNING
	CHAR(5)  AS codigo_de_respuesta,
	CHAR(30) AS mensaje,
	CHAR(20) AS trasaccion_sucursal,	
	CHAR(2)  AS numcategoria,
	CHAR(3)  AS numconvenio,	
	CHAR(50) AS nom_serv,
	CHAR(50) AS tituloform,
	CHAR(5)	 AS forma_de_pago,	
	CHAR(1)	 AS es_reversable,
	CHAR(40) AS caracteristicas_de_label_1,
	CHAR(1)	 AS tipo_text_1,
	CHAR(2)	 AS long_text_1,
	CHAR(1)	 AS valida_dv_1,
	CHAR(1)	 AS mascara_1,
	CHAR(4)	 AS cod_consulta_1,	
	CHAR(40) AS caracteristicas_de_label_2,
	CHAR(1)	 AS tipo_text_2,
	CHAR(2)	 AS long_text_2,
	CHAR(1)	 AS valida_dv_2,
	CHAR(4)	 AS cod_consulta_2,
	CHAR(40) AS caracteristicas_de_label_3,
	CHAR(1)	 AS tipo_text_3,	
	CHAR(3)	 AS long_text_3,
	CHAR(1)	 AS valida_dv_3,
	CHAR(4)	 AS cod_consulta_3,	
	CHAR(40) AS caracteristicas_de_label_4,
	CHAR(1)	 AS label_signo_4,
	CHAR(11) AS monto_max_text_4,
	CHAR(1)	 AS valida_imp_cond,
	CHAR(4)	 AS cod_consulta_4,
	CHAR(1)	 AS ind_cent_4,
	CHAR(1)	 AS long_dv,
	CHAR(8)	 AS fecha_actualizacion,
	CHAR(1)  AS acepta_pg,
	CHAR(1)	 AS encripta;
	
	DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cInfoErr         CHAR(100);
	DEFINE cCodRet          CHAR(5);
	DEFINE cMensaje			CHAR(30);
	DEFINE cTransacSuc		CHAR(4);
	DEFINE cCategoria		CHAR(2);
	DEFINE cConvenio		CHAR(3);
	DEFINE cNomServ			CHAR(50);
	DEFINE cTituloForm		CHAR(50);
	DEFINE cFormaPago		CHAR(5);
	DEFINE cReversable		CHAR(1);
	DEFINE cCaracLabel1		CHAR(40);
	DEFINE cTipoText1		CHAR(1);
	DEFINE cLongText1		CHAR(2);
	DEFINE cValidaDV1		CHAR(1);
	DEFINE cMascara1		CHAR(1);
	DEFINE cCodConsulta1	CHAR(4);
	DEFINE cCaracLabel2		CHAR(40);
	DEFINE cTipoText2		CHAR(1);
	DEFINE cLongText2		CHAR(2);
	DEFINE cValidaDV2		CHAR(1);
	DEFINE cCodConsulta2	CHAR(4);
	DEFINE cCaracLabel3		CHAR(40);
	DEFINE cTipoText3		CHAR(1);
	DEFINE cLongText3		CHAR(2);
	DEFINE cValidaDV3		CHAR(1);
	DEFINE cCodConsulta3	CHAR(4);
	DEFINE cCaracLabel4		CHAR(40);
	DEFINE cLabelSigno4		CHAR(1);
	DEFINE cMontoMaxText4	CHAR(11);
	DEFINE cValida_Imp_Cond	CHAR(1);
	DEFINE cCodConsulta4	CHAR(4);
	DEFINE cIndCent4		CHAR(1);
	DEFINE cLongDV			CHAR(1);
	DEFINE dFechaAct		CHAR(8);
	DEFINE cFechaFormat		CHAR(8);
	DEFINE cAcepta_PG		CHAR(1);
	DEFINE cEncripta		CHAR(1);
	
	LET cCodRet          = "00000";
	LET cMensaje         = "Exitoso";
	LET cTransacSuc    	 = '';
	LET cCategoria       = '';
	LET cConvenio        = '';
	LET cNomServ         = '';
	LET cTituloForm      = '';
	LET cFormaPago       = '';
	LET cReversable      = '';
	LET cCaracLabel1     = '';
	LET cTipoText1       = '';
	LET cLongText1       = '';
	LET cValidaDV1       = '';
	LET cMascara1        = '';
	LET cCodConsulta1    = '';
	LET cCaracLabel2     = '';
	LET cTipoText2       = '';
	LET cLongText2       = '';
	LET cValidaDV2       = '';
	LET cCodConsulta2    = '';
	LET cCaracLabel3     = '';
	LET cTipoText3       = '';
	LET cLongText3       = '';
	LET cValidaDV3       = '';
	LET cCodConsulta3    = '';	
	LET cCaracLabel4     = '';
	LET cLabelSigno4     = '';
	LET cMontoMaxText4   = '';
	LET cValida_Imp_Cond = '';
	LET cCodConsulta4    = '';
	LET cIndCent4        = '';
	LET cLongDV          = '';
	LET dFechaAct        = '';
	LET cFechaFormat     = '';
	LET cAcepta_PG       = '';
	LET cEncripta        = '';
	
	--SET DEBUG FILE TO  '/informix/EPG/sp_cons_carac_msw_epg.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error:sp_cons_carac_msw";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_cons_carac_msw");
			RETURN cCodRet, cMensaje, cTransacSuc, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
					cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
					cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, 
					cCodConsulta4, cIndCent4, cLongDV, dFechaAct, cAcepta_PG, cEncripta;
            END IF;
        END EXCEPTION;
		
		IF pOrigen = "" OR pOrigen is null OR pConvenio = "" or pConvenio is null OR pCategoria = "" OR pCategoria is null THEN
			LET cCodRet = '00200';
			LET cMensaje = 'Error:sp_cons_carac_msw';
			RETURN cCodRet, cMensaje, cTransacSuc, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
					cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
					cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, 
					cCodConsulta4, cIndCent4, cLongDV, dFechaAct, cAcepta_PG, cEncripta;
		END IF;

		
		IF pOrigen = 'CPL' or pOrigen = 'cpl' THEN
            SELECT b.trans_suc_efectivo, a.numcategoria, a.numconvenio, b.nomconvenio, a.tituloform, case when (d.efectivo || d.cargo_cta || d.cargo_tdc) = '111' then '1-2-5'
                                                                                                          when  (d.efectivo || d.cargo_cta || d.cargo_tdc) = '110' then '1-2' 
                                                                                                          when (d.efectivo || d.cargo_cta || d.cargo_tdc) = '100' then '1' end AS forma_pago, a.reversable,
                    a.label_1, a.tipo_text_1, a.long_text_1, a.valida_dv_1, a.mascara_1, a.cod_consulta_1, a.label_2, a.tipo_text_2, long_text_2,
                    a.valida_dv_2, a.cod_consulta_2, a.label_3, a.tipo_text_3, a.long_text_3, a.valida_dv_3, a.cod_consulta_3, a.label_4, 
                    a.label_signo_4, a.monto_max_text_4, a.valida_imp_cond, a.cod_consulta_4 , a.ind_cent_4, a.long_dv, 
                    lpad(substr(a.fechaactualizacion,1,4),4,'0') || lpad(substr(a.fechaactualizacion,6,2),2,'0') || lpad(substr(a.fechaactualizacion,9,11),2,'0'),
                     a.acepta_pg, a.encripta
			INTO cTransacSuc, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, cTipoText1, cLongText1, 
			     cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, cCaracLabel3, cTipoText3, 
			     cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, cCodConsulta4, cIndCent4, 
			     cLongDV, dFechaAct, cAcepta_PG, cEncripta
            FROM bdisac:"informix".sac_controlconvenios a, bdisac:"informix".sac_convenios b, bdisac:"informix".sac_tipopago_convenio d, bdisac:"informix".sac_servicios_cpl e
            WHERE a.numcategoria = b.numcategoria
            AND a.numconvenio = b.numconvenio
            AND a.numcategoria = d.numcategoria
            AND a.numconvenio = d.numconvenio
			AND a.numcategoria = pCategoria
            AND a.numconvenio = pConvenio
			AND a.numcategoria = e.numcategoria
			AND a.numconvenio = e.numconvenio;
			
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN

				LET cCodRet   = "00202";
				LET cMensaje  = "Error:Categoria ó Convenio invalido";
				RETURN cCodRet, cMensaje, '', '', '', '', '', '', '', '', '', '', '', '', '', ''
				       ,'', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', '', '', '';
			ELSE	
				RETURN cCodRet, cMensaje, cTransacSuc, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
						cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
						cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, 
						cCodConsulta4, cIndCent4, cLongDV, dFechaAct, cAcepta_PG, cEncripta;
			END IF;
			
        ELIF pOrigen = 'BCPL' or pOrigen = 'bcpl' THEN

            SELECT b.trans_suc_efectivo, a.numcategoria, a.numconvenio, b.nomconvenio, a.tituloform, case when (d.efectivo || d.cargo_cta || d.cargo_tdc) = '111' then '1-2-5'
                                                                                                          when  (d.efectivo || d.cargo_cta || d.cargo_tdc) = '110' then '1-2' 
                                                                                                          when (d.efectivo || d.cargo_cta || d.cargo_tdc) = '100' then '1' end AS forma_pago, a.reversable,
                    a.label_1, a.tipo_text_1, a.long_text_1, a.valida_dv_1, a.mascara_1, a.cod_consulta_1, a.label_2, a.tipo_text_2, long_text_2,
                    a.valida_dv_2, a.cod_consulta_2, a.label_3, a.tipo_text_3, a.long_text_3, a.valida_dv_3, a.cod_consulta_3, a.label_4, 
                    a.label_signo_4, a.monto_max_text_4, a.valida_imp_cond, a.cod_consulta_4 , a.ind_cent_4, a.long_dv, 
                    lpad(substr(a.fechaactualizacion,1,4),4,'0') || lpad(substr(a.fechaactualizacion,6,2),2,'0') || lpad(substr(a.fechaactualizacion,9,11),2,'0'),
                     a.acepta_pg, a.encripta
			INTO cTransacSuc, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, cTipoText1, cLongText1, 
			     cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, cCaracLabel3, cTipoText3, 
			     cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, cCodConsulta4, cIndCent4, 
			     cLongDV, dFechaAct, cAcepta_PG, cEncripta
            FROM bdisac:"informix".sac_controlconvenios a, bdisac:"informix".sac_convenios b, bdisac:"informix".sac_tipopago_convenio d
            WHERE a.estatus = 'A'
            AND a.numcategoria = b.numcategoria
            AND a.numconvenio = b.numconvenio
            AND a.numcategoria = d.numcategoria
            AND a.numconvenio = d.numconvenio
			AND a.numcategoria = pCategoria
            AND a.numconvenio = pConvenio;
			
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN

				LET cCodRet   = "00202";
				LET cMensaje  = "Error:Categoria ó Convenio invalido";
				RETURN cCodRet, cMensaje, '', '', '', '', '', '', '', '', '', '', '', '', '', ''
				       ,'', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', '', '', '';
			ELSE	
				RETURN cCodRet, cMensaje, cTransacSuc, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
						cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
						cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, 
						cCodConsulta4, cIndCent4, cLongDV, dFechaAct, cAcepta_PG, cEncripta;
			END IF;
		ELSE

			LET cCodRet = '00201';
			LET cMensaje = 'Origen Desconocido';
			RETURN cCodRet, cMensaje, cTransacSuc, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
					cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
					cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, 
					cCodConsulta4, cIndCent4, cLongDV, dFechaAct, cAcepta_PG, cEncripta;
		END IF;
		
	END;

END PROCEDURE
;