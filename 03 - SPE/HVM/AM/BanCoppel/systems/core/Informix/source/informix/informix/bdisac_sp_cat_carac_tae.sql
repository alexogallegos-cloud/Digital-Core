CREATE PROCEDURE "informix".sp_cat_carac_tae(pOrigen CHAR(4),pCategoria CHAR(2),pConvenio CHAR(3))
	RETURNING
	CHAR(5)  AS codigo_de_respuesta,
	CHAR(30) AS mensaje,
	CHAR(20) AS id_serv_proveedor,
	CHAR(4)  AS trasaccion_sucursal,
	CHAR(4)  AS trasaccion_cargo_deb,
	CHAR(4)  AS trasaccion_cargo_cred,
	CHAR(2)  AS numcategoria,
	CHAR(3)  AS numconvenio,	
	CHAR(50) AS nom_serv,
	CHAR(50) AS tituloform,
	CHAR(5)	 AS forma_de_pago,	
	CHAR(1)	 AS es_reversable,
	CHAR(40) AS caracteristicas_de_label_1,
	CHAR(1)	 AS tipo_text_1,
	CHAR(5)	 AS long_text_1,
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
	CHAR(11) AS monto_min_text_4,
	CHAR(80) AS montos_fijos,
	CHAR(1)	 AS valida_imp_cond,
	CHAR(4)	 AS cod_consulta_4,
	CHAR(5)	 AS importe_comision,
	CHAR(5)  AS iva_comision,
	CHAR(1)	 AS ind_cent_4,
	CHAR(1)	 AS long_dv,
	CHAR(8)	 AS fecha_actualizacion,
	CHAR(1)  AS acepta_pg,
	CHAR(1)	 AS encripta,
	CHAR(1)  AS consulta_balance;
	
	
	DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cInfoErr         CHAR(100);
	DEFINE cCodRet          CHAR(5);
	DEFINE cMensaje			CHAR(30);
	DEFINE cIdservicioprov	CHAR(20);
	DEFINE cTransacSuc		CHAR(4);
	DEFINE cTransCrgDeb		CHAR(4);
	DEFINE cTransCrgCred	CHAR(4);
	DEFINE cCategoria		CHAR(2);
	DEFINE cConvenio		CHAR(3);
	DEFINE cNomServ			CHAR(50);
	DEFINE cTituloForm		CHAR(50);
	DEFINE cFormaPago		CHAR(5);
	DEFINE cReversable		CHAR(1);
	DEFINE cCaracLabel1		CHAR(40);
	DEFINE cTipoText1		CHAR(1);
	DEFINE cLongText1		CHAR(5);
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
	DEFINE cMontoMinText4	CHAR(11);
	DEFINE cMontosFijos		CHAR(80);
	DEFINE cValida_Imp_Cond	CHAR(1);
	DEFINE cCodConsulta4	CHAR(4);
	DEFINE cImpComision		CHAR(5);
	DEFINE cIvaComision		CHAR(5);
	DEFINE cIndCent4		CHAR(1);
	DEFINE cLongDV			CHAR(1);
	DEFINE dFechaAct		CHAR(8);
	DEFINE cFechaFormat		CHAR(8);
	DEFINE cAcepta_PG		CHAR(1);
	DEFINE cEncripta		CHAR(1);
	DEFINE cConsBalance		CHAR(1);
	DEFINE cEmpresa			CHAR(3);
	DEFINE cHoraServidor	DATETIME HOUR TO SECOND;
	DEFINE cHoraOper_ini DATETIME HOUR TO SECOND;
	DEFINE cHoraOper_fin DATETIME HOUR TO SECOND;
	
	LET cCodRet          = "00000";
	LET cMensaje         = "Exitoso";
	LET cIdservicioprov	 = '';
	LET cTransacSuc    	 = '';
	LET cTransCrgDeb   	 = '';
	LET cTransCrgCred  	 = '';
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
	LET cMontoMinText4	 = '';
	LET cMontosFijos	 = '';
	LET cValida_Imp_Cond = '';
	LET cCodConsulta4    = '';
	LET cImpComision	 = '0.00';
	LET cIvaComision	 = '0.00';
	LET cIndCent4        = '';
	LET cLongDV          = '';
	LET dFechaAct        = '';
	LET cFechaFormat     = '';
	LET cAcepta_PG       = '';
	LET cEncripta        = '';
	LET cConsBalance   	 = '';
	LET cEmpresa		 = "001";
	LET cHoraServidor	 = "";
	LET cHoraOper_ini = "";
	LET cHoraOper_fin = "";	
	
	--SET DEBUG FILE TO  '/informix/EPG/sp_cons_carac_msw_epg.out';
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error:sp_cat_carac_tae";
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_cons_carac_msw");
			RETURN cCodRet, cMensaje, cIdservicioprov, cTransacSuc, cTransCrgDeb, cTransCrgCred, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
					cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
					cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cMontoMinText4, 
					cMontosFijos, cValida_Imp_Cond, cCodConsulta4, cImpComision, cIvaComision, cIndCent4, cLongDV, dFechaAct, cAcepta_PG, cEncripta, cConsBalance;
            END IF;
        END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
		
		IF pOrigen = "" OR pOrigen is null THEN
			LET cCodRet = '00200';
			LET cMensaje = 'Error:sp_cat_carac_tae';
			RETURN cCodRet, cMensaje, cIdservicioprov,cTransacSuc, cTransCrgDeb, cTransCrgCred, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
					cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
					cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cMontoMinText4,
					cMontosFijos, cValida_Imp_Cond, cCodConsulta4, cImpComision, cIvaComision, cIndCent4, cLongDV, dFechaAct, cAcepta_PG, cEncripta, cConsBalance;
		END IF;

		SELECT valor 
		INTO cHoraOper_ini
		FROM "informix".sac_param 
		WHERE cod_param = '151'
			AND empresa = cEmpresa;
		
		SELECT valor 
		INTO cHoraOper_fin 
		FROM "informix".sac_param 
		WHERE cod_param = '152'
			AND empresa = cEmpresa;

		LET cHoraServidor = CURRENT HOUR TO SECOND;

		IF cHoraServidor < cHoraOper_ini OR cHoraServidor > cHoraOper_fin THEN
			LET cCodRet   = "00202";
			LET cMensaje  = "Error:Horario no operativo";
			RETURN cCodRet, cMensaje, '', '', '', '', '', '', '', '', '', '', '', '', '', ''
					,'', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', '', '', ''
					,'', '', '', '', '', '', '', '';
		END IF;
		
		IF pOrigen = 'BEX' or pOrigen = 'bex' THEN

            FOREACH
				SELECT b.trans_suc_efectivo, can.trans_cargo_cliente, b.trans_cen_cargo_cliente, a.numcategoria, a.numconvenio, cat.compania, a.tituloform
					,case when (d.efectivo || d.cargo_cta || d.cargo_tdc) = '111' then '1-2-5'
						when  (d.efectivo || d.cargo_cta || d.cargo_tdc) = '110' then '1-2' 
						when (d.efectivo || d.cargo_cta || d.cargo_tdc) = '100' then '1' end AS forma_pago, a.reversable
					,a.label_1, a.tipo_text_1, TRIM(a.long_text_1) || "-" || a.long_text_2, a.valida_dv_1, a.mascara_1, a.cod_consulta_1, a.label_2, a.tipo_text_2, long_text_2
					,a.valida_dv_2, a.cod_consulta_2, a.label_3, a.tipo_text_3, a.long_text_3, a.valida_dv_3, a.cod_consulta_3, a.label_4
					,a.label_signo_4, a.monto_max_text_4, a.valida_imp_cond, a.cod_consulta_4 , a.ind_cent_4, a.long_dv
					,lpad(substr(a.fechaactualizacion,7,11),4,'0') || lpad(substr(a.fechaactualizacion,4,6),2,'0') || lpad(substr(a.fechaactualizacion,1,2),2,'0')
					,a.acepta_pg, a.encripta, cat.cve_compania, REPLACE(cat.tlf_compania,' ','')
					,cat.montos_fijos
					,a.consulta_adeudo
				INTO cTransacSuc, cTransCrgDeb, cTransCrgCred, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, cTipoText1, cLongText1, 
					 cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, cCaracLabel3, cTipoText3, 
					 cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cValida_Imp_Cond, cCodConsulta4, cIndCent4, 
					 cLongDV, dFechaAct, cAcepta_PG, cEncripta, cIdservicioprov, cMontoMinText4, cMontosFijos, cConsBalance		 
				FROM "informix".sac_controlconvenios a, "informix".sac_convenios b, "informix".sac_tipopago_convenio d, "informix".sac_catalogos_taecoppel cat, "informix".sac_control_convenios_canales can
				WHERE a.estatus = 'A'
				AND a.numcategoria = b.numcategoria
				AND a.numconvenio = b.numconvenio
				AND a.numcategoria = d.numcategoria
				AND a.numconvenio = d.numconvenio
				AND a.numcategoria = cat.numcategoria
				AND a.numconvenio = cat.numconvenio
				AND a.numcategoria = can.numcategoria
				AND a.numconvenio = can.numconvenio
				AND a.numcategoria = pCategoria
				AND a.numconvenio = pConvenio
				AND can.canal = 'BEX'
				AND a.status_bex = 'A'
				AND cat.estatus = 'A'
				order by cat.orden asc
				
				IF  dbinfo("sqlca.sqlerrd2") = 0 THEN

					LET cCodRet   = "00202";
					LET cMensaje  = "Error:Categoria ?? Convenio invalido";
					RETURN cCodRet, cMensaje, '', '', '', '', '', '', '', '', '', '', '', '', '', ''
						   ,'', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', '', '', ''
						   ,'', '', '', '', '', '', '', '';
				ELSE	
					RETURN cCodRet, cMensaje, cIdservicioprov ,cTransacSuc, cTransCrgDeb, cTransCrgCred, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
							cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
							cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cMontoMinText4,
							cMontosFijos, cValida_Imp_Cond, cCodConsulta4, cImpComision, cIvaComision, cIndCent4, cLongDV, dFechaAct, cAcepta_PG, cEncripta, cConsBalance
					WITH RESUME;
				END IF;
			END FOREACH;
		ELSE
			LET cCodRet = '00201';
			LET cMensaje = 'Origen Desconocido';
			RETURN cCodRet, cMensaje, cIdservicioprov, cTransacSuc, cTransCrgDeb, cTransCrgCred, cCategoria, cConvenio, cNomServ, cTituloForm, cFormaPago, cReversable, cCaracLabel1, 
					cTipoText1, cLongText1,	cValidaDV1, cMascara1, cCodConsulta1, cCaracLabel2, cTipoText2, cLongText2, cValidaDV2, cCodConsulta2, 
					cCaracLabel3, cTipoText3, cLongText3, cValidaDV3, cCodConsulta3, cCaracLabel4, cLabelSigno4, cMontoMaxText4, cMontoMinText4,
					cMontosFijos, cValida_Imp_Cond, cCodConsulta4, cImpComision, cIvaComision, cIndCent4, cLongDV, dFechaAct, cAcepta_PG, cEncripta, cConsBalance;
		END IF;
		
	END;

END PROCEDURE
DOCUMENT
'AUTOR : 90232799 - Christopher Siverio',
'DESCRIPCION:  SP para retorna el catalago  de TAE ',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'FECHA : 14/10/2022',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------',
'AUTOR : 90034397 - Brando Garcia',
'DESCRIPCION:  Se agrega validacion de cierre de dia.',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'FECHA : 09/02/2023',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------',
'AUTOR : 90034397 - Brando Garcia',
'DESCRIPCION:  Se agrega en la salida cMontoMinText4 el numero telefonico de la compaÃ±ia proveedora.',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'FECHA : 19/05/2023',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------',
-- FOLIO.........: Iniciativa: Pago de Servicios
-- AUTOR.........: 90155378 - Leon Fernando Chavez Murillo.
-- FECHA.........: 20/08/2024
-- CREACION......: SE AGREGA VALIDACION PARA MUETRA DE CATALOGO DE COMPANIAS ACTIVAS sac_catalogos_taecoppel
-- SOLICITA......: Luis Trujillo
-- BD............: bdisac
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".extrae_cont( pempresa     char(3),
                                         psecuencia   smallint,
                                         pmonto_tot   money(14,2),
                                         psucope      char(4),
                                         pproducto    char(4),
                                         pmoneda      char(2),
                                         ptransacc    char(4),
                                         psector      char(2),
                                         pcancelad    char(1),
                                         psuccta      char(4),
                                         pdescripcion char(30) )
returning char(5);
    
    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;

    define vcodret           char(5); 
    define vsqlerr           integer;
    define vp_num_cte        char(9);
    define v_tipo_cuenta     char(1);
    define v_auxiliar        char(9);
    define v_aux             integer;
    define w_secuencia       smallint;
    define vw_auxiliar       char(1);
    define v_sectoriza_cta   char(1);
    define vsuctmp           char(4);
    define vc_ccmayor        char(10);
    define vc_ccsub          char(10);
    define vc_ccsubsub       char(10);
    define vc_ccsssub        char(10);
    define vc_ccssssub       char(10);
    define vc_sector         char(10);
    define va_ccmayor        char(10);
    define va_ccsub          char(10);
    define va_ccsubsub       char(10);
    define va_ccsssub        char(10);
    define va_ccssssub       char(10);
    define va_sector         char(10);
    define viva_ccmayor      char(10);
    define viva_ccsub        char(10);
    define viva_ccsubsub     char(10);
    define viva_ccsssub      char(10);
    define viva_ccssssub     char(10);
    define viva_sector       char(10);
    define vitr_ccmayor      char(10);
    define vitr_ccsub        char(10);
    define vitr_ccsubsub     char(10);
    define vitr_ccsssub      char(10);
    define vitr_ccssssub     char(10);
    define vitr_sector       char(10);
	define vsc_contab_temp   BOOLEAN;  
    define vsuccta           char(4);

    let vcodret           = '000';
    let vsqlerr           = 0;
    let vp_num_cte        = ' ';
    let v_tipo_cuenta     = ' ';
    let v_auxiliar        = ' ';
    let v_aux             = 0;
    let w_secuencia       = 0;
    let vw_auxiliar       = ' ';
    let v_sectoriza_cta   = ' ';
    let vsuctmp           = ' ';
    let vc_ccmayor        = ' ';
    let vc_ccsub          = ' ';
    let vc_ccsubsub       = ' ';
    let vc_ccsssub        = ' ';
    let vc_ccssssub       = ' ';
    let vc_sector         = ' ';
    let va_ccmayor        = ' ';
    let va_ccsub          = ' ';
    let va_ccsubsub       = ' ';
    let va_ccsssub        = ' ';
    let va_ccssssub       = ' ';
    let va_sector         = ' ';
    let viva_ccmayor      = ' ';
    let viva_ccsub        = ' ';
    let viva_ccsubsub     = ' ';
    let viva_ccsssub      = ' ';
    let viva_ccssssub     = ' ';
    let viva_sector       = ' ';
    let vitr_ccmayor      = ' ';
    let vitr_ccsub        = ' ';
    let vitr_ccsubsub     = ' ';
    let vitr_ccsssub      = ' ';
    let vitr_ccssssub     = ' ';
    let vitr_sector       = ' ';
	let vsc_contab_temp   = 'F';
    let vsuccta           = psuccta;

    --- SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    --- SET ISOLATION COMMITTED READ;

    begin

    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
			
			IF vsc_contab_temp = 'T' THEN
				DROP TABLE sc_contab_temp;
			END IF
			
            return vcodret;
        end if;
    end exception;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    let viva_ccmayor  = substr(vgcta_iva, 1, 4);
    let viva_ccsub    = substr(vgcta_iva, 5, 2);
    let viva_ccsubsub = substr(vgcta_iva, 7, 2);
    let viva_ccsssub  = substr(vgcta_iva, 9, 2);
    let viva_ccssssub = substr(vgcta_iva, 11, 2);
    let viva_sector   = substr(vgcta_iva, 13, 2);

    let vitr_ccmayor  = substr(vgcta_itr, 1, 4);
    let vitr_ccsub    = substr(vgcta_itr, 5, 2);
    let vitr_ccsubsub = substr(vgcta_itr, 7, 2);
    let vitr_ccsssub  = substr(vgcta_itr, 9, 2);
    let vitr_ccssssub = substr(vgcta_itr, 11, 2);
    let vitr_sector   = substr(vgcta_itr, 13, 2);

    select c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub, c_ccssssub, c_sector,
           a_ccmayor, a_ccsub, a_ccsubsub, a_ccsssub, a_ccssssub, a_sector
      into vc_ccmayor, vc_ccsub, vc_ccsubsub, vc_ccsssub, vc_ccssssub, vc_sector,
           va_ccmayor, va_ccsub, va_ccsubsub, va_ccsssub, va_ccssssub, va_sector
      from bdinteg:si_prodtran
     where empresa = pempresa 
       and producto = pproducto 
       and sistema = vg_sistema 
       and transaccion = ptransacc 
       and secuencia = psecuencia;

	IF (vc_ccmayor =' '  OR vc_ccmayor IS NULL) AND (va_ccmayor = ' ' OR va_ccmayor IS NULL) THEN

		CALL sp_suspenso(pempresa,'01',pmonto_tot,psecuencia,psucope,psuccta,pcancelad,pproducto,pmoneda,ptransacc,psector,
						 case when pdescripcion = 'ABSPEIWU' OR pdescripcion = 'ABSPEIBTS' OR pdescripcion = 'ABSPEIAPP' then 'ABSPEI' else pdescripcion end ,vfecha_hoy) 

        RETURNING vcodret,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,
                          va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector;
						  
	END IF 
  
	CREATE TEMP TABLE sc_contab_temp ( 
		empresa    	CHAR(3),
		secuencia  	SMALLINT,
		sucursal   	CHAR(4),
		succta     	CHAR(4),
		ccmayor    	CHAR(10),
		ccsub      	CHAR(10),
		ccsubsub   	CHAR(10),
		ccssubsub  	CHAR(10),
		ccsssubsub 	CHAR(10),
		sector     	CHAR(10),
		auxiliar   	CHAR(9),
		tot_cargo  	MONEY,
		tot_abono  	MONEY,
		moneda     	CHAR(2),
		descripcion	CHAR(30) 
    ) WITH NO LOG;


	LET vsc_contab_temp = 'T';
	
    -- / / / / / / / / / /    CUENTA CARGO   / / / / / / / / / /
    if vc_ccmayor is null then 
        let vc_ccmayor = " "; 
    end if;
    
    if vc_ccsub is null then 
        let vc_ccsub = " "; 
    end if;
    
    if vc_ccsubsub is null then 
        let vc_ccsubsub = " "; 
    end if;
    
    if vc_ccsssub is null then 
        let vc_ccsssub = " "; 
    end if;
    
    if vc_ccssssub is null then 
        let vc_ccssssub = " "; 
    end if;

    select tipo_cuenta, sectoriza_cta, auxiliar 
      into v_tipo_cuenta, v_sectoriza_cta, vw_auxiliar
      from bdinteg:si_catalog
     where empresa    = pempresa    
       and ccmayor    = vc_ccmayor    
       and ccsub      = vc_ccsub     
       and ccsubsub   = vc_ccsubsub   
       and ccssubsub  = vc_ccsssub   
       and ccsssubsub = vc_ccssssub   
       and sector     = vc_sector;
       
    if v_sectoriza_cta = "N" then  
        let vc_sector = "00"; -- // La cuenta NO se sectoriza
    else
        let vc_sector = psector;
    end if;
    
    -- // Se agrega la transacció® ¤e Pago de Cheque Propio por Cá­¡ra y TEF
    if ptransacc = vgtransacc_t1 or ptransacc = vgtransacc_t2 or ptransacc = '0231' or ptransacc = '1114' or ptransacc = '3300' then
        if vc_ccmayor = "1102" then
            let vc_sector = "21";
        end if;
    end if;

    if ptransacc = "1171" or ptransacc = "1143" then
        if vc_ccmayor = "2402" then
            let vc_sector = "31";
        end if;	 
    end if;

{--08/08/2017
    -- // Pago de Remesas BTS
    if ptransacc = '1110' or ptransacc = '1140' then
        if vc_ccmayor = '2101' then
            let vc_sector = '42';
        end if;	 
    end if;
	
    -- // Pago de Remesas WU - ORLANDI - VIGO
    if ptransacc IN ('1121','1122','1123','1151','1152','1153') then
        if vc_ccmayor = '2101' then
            let vc_sector = '31';
        end if;	 
    end if;
	
	-- // Pago de Remesas APPRIZA PAY
    if ptransacc = '1325' or ptransacc = '1355' then
        if vc_ccmayor = '2101' then
            let vc_sector = '42';
        end if;	 
    end if;
}
--//TRANSACCION CFE

    if ptransacc IN ('1437','1436','1321','1435') then
        if vc_ccmayor = '2402' then
            let vc_sector = '14';
        end if;	 
    end if;

    if ptransacc = vgtransacc_corresp then
        if vc_ccmayor = "1402" then
            let vc_sector = "31";
        end if;
    end if;

	if ptransacc in("0283", "0305", "0308", "0410") then
        if vc_ccmayor = "1402" then
            let vc_sector = "31";
        end if;
    end if;
	
    if ptransacc = "0326" then
        if vc_ccmayor = "1402" then
            let vc_sector = "11";
        end if;	 
    end if;
	
	if ptransacc = "0205" and pproducto = "8000" then
        if vc_ccmayor = "2101" then
            let vc_sector = "32";
        end if;	 
    end if;
	
	if pproducto = "8000" THEN
	   IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '210101030201' THEN
        LET vc_sector = '31';
	   END IF;
	end if;
	
    if pcancelad = "V" then
        let pmoneda = vgcodigo_mn;
    end if;

    if vc_ccmayor  = viva_ccmayor  AND 
       vc_ccsub    = viva_ccsub    AND 
       vc_ccsubsub = viva_ccsubsub AND 
       vc_ccsssub  = viva_ccsssub  AND 
       vc_ccssssub = viva_ccssssub THEN
        let vc_sector = viva_sector;
    end if;

    if vc_ccmayor  = vitr_ccmayor   AND
       vc_ccsub    = vitr_ccsub     AND
       vc_ccsubsub = vitr_ccsubsub  AND
       vc_ccsssub  = vitr_ccsssub   AND
       vc_ccssssub = vitr_ccssssub  THEN
        let vc_sector = vitr_sector;
    end if;

    let vc_ccmayor  = trim(vc_ccmayor);
    let vc_ccsub    = trim(vc_ccsub);
    let vc_ccsubsub = trim(vc_ccsubsub);
    let vc_ccsssub  = trim(vc_ccsssub);
    let vc_ccssssub = trim(vc_ccssssub);
    
    if (ptransacc = '0273' OR ptransacc = '0277') AND trim(vc_ccmayor)||trim(vc_ccsub) = '951207' THEN
        let psucope = '9201';
    end if;
    
    if (ptransacc = '0276') AND trim(vc_ccmayor)||trim(vc_ccsub) = '951102' THEN
        let psucope = '9201';
    end if;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '240290200201' THEN
        LET vc_sector = '31';
    END IF;
	
	IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '240290240000' THEN
        LET vc_sector = '31';
    END IF;
	
	IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '140290141101' THEN
        LET vc_sector = '31';
    END IF;

	IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '240293030400' THEN
        LET vc_sector = '31';
    END IF;	
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '240208040303' THEN
        LET vc_sector = '11';
    END IF;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub)||trim(vc_sector) = '14029025000000' THEN
        LET psuccta = '9201';
    END IF;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '140295040100' THEN
        LET psuccta = '5001';
    END IF;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '140290140101' THEN
        LET psuccta = '5005';
    END IF;
    
    IF trim(vc_ccmayor)||trim(vc_ccsub)||trim(vc_ccsubsub)||trim(vc_ccsssub)||trim(vc_ccssssub) = '140290141101' THEN
        LET psuccta = '5005';
    END IF;
	
	insert into aux_auditerr values
    (pempresa,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,v_auxiliar,pproducto,ptransacc,pmonto_tot);

    -- // Para cuentas de enlace..
    IF vc_ccmayor[1,2] = "95" THEN 
        insert into sc_contab_temp values
        (pempresa, w_secuencia, psucope, psucope, vc_ccmayor, vc_ccsub, vc_ccsubsub, 
         vc_ccsssub, vc_ccssssub, vc_sector, v_auxiliar, pmonto_tot, 0, pmoneda, 
		 case when pdescripcion = 'ABSPEIWU' OR pdescripcion = 'ABSPEIBTS' OR pdescripcion = 'ABSPEIAPP' then 'ABSPEI' else pdescripcion end );
    ELSE -- // Para el resto de las cuentas...
        insert into sc_contab_temp values
        (pempresa, w_secuencia, psucope, psuccta, vc_ccmayor, vc_ccsub, vc_ccsubsub,
         vc_ccsssub, vc_ccssssub, vc_sector, v_auxiliar, pmonto_tot, 0, pmoneda, 
		 case when pdescripcion = 'ABSPEIWU' OR pdescripcion = 'ABSPEIBTS' OR pdescripcion = 'ABSPEIAPP' then 'ABSPEI' else pdescripcion end );
    END IF;
    
    -- / / / / / / / / / /   CUENTA ABONO   / / / / / / / / / / 
    if va_ccmayor is null then 
        let va_ccmayor = " "; 
    end if;
    
    if va_ccsub is null then 
        let va_ccsub = " "; 
    end if;
    
    if va_ccsubsub is null then 
        let va_ccsubsub = " "; 
    end if;
    
    if va_ccsssub is null then 
        let va_ccsssub = " "; 
    end if;
    
    if va_ccssssub is null then 
        let va_ccssssub = " "; 
    end if;
    
    if va_sector is null then 
        let va_sector = " "; 
    end if;

    select tipo_cuenta, sectoriza_cta, auxiliar 
      into v_tipo_cuenta, v_sectoriza_cta, vw_auxiliar
      from bdinteg:si_catalog
     where empresa    = pempresa    
       and ccmayor    = va_ccmayor    
       and ccsub      = va_ccsub     
       and ccsubsub   = va_ccsubsub   
       and ccssubsub  = va_ccsssub   
       and ccsssubsub = va_ccssssub   
       and sector     = va_sector;
       
    if v_sectoriza_cta = "N" then 
        let va_sector = "00";    -- // La cuenta NO se sectoriza
    else
        let va_sector = psector; -- // Se respeta el sector del cliente
    end if;
    
    -- // Se agrega la transacció® ¤e Pago de Cheque Propio por Cá­¡ra
    if ptransacc = vgtransacc_t1 or ptransacc = vgtransacc_t2 or ptransacc = '0231' or ptransacc = '3300'then
        if va_ccmayor = "1102" then
            let va_sector = "21";
        end if;
    end if;

	if ptransacc IN ("3387", "3393") then
        if va_ccmayor = "5390" then
            let va_sector = "31";
        end if;	 
    end if;
	
	if ptransacc IN ("3388", "3394") then
        if va_ccmayor = "2402" then
            let va_sector = "11";
        end if;	 
    end if;

    --if ptransacc = "1141" or ptransacc = "1113" or ptransacc = "1144"   then
	if ptransacc IN ("1141", "1113", "1144", "3396","3398","3399","4000" ) then
        if va_ccmayor = "2402" then
            let va_sector = "31";
        end if;	 
    end if;
	
{--08/08/2017
    if ptransacc = "1119" or ptransacc = "1179" or ptransacc = "1180" then
        if va_ccmayor = "2101" then
            let va_sector = "12";
        end if;	 
    end if;
}	
	--TRANSACCION CFE
    if ptransacc = "1311" or ptransacc = "1371" or ptransacc = "1438" then
        if va_ccmayor = "2402" then
            let va_sector = "14";
        end if;	 
    end if;
    if ptransacc = vgtransacc_corresp then
        if va_ccmayor = "1402" then
            let va_sector = "31";
        end if;
    end if;

	if ptransacc in("0283", "0305", "0308", "0410") then
       if va_ccmayor = "1402" then
          let vc_sector = "31";
       end if;
	end if;
	
    if ptransacc = "1204" then
        if va_ccmayor = "5309" then
            let va_sector = "32";
        end if;	 
    end if;

	if ptransacc = "0326" then
        if va_ccmayor = "1402" then
            let va_sector = "11";
        end if;	 
    end if;

    -- // Pagos Referenciados SOLFI ABONO / CONTIGO
	if ptransacc IN ("1127","1187","1604","1694") then
        if va_ccmayor = "2402" then
            let va_sector = "26";
        end if;	 
    end if;

{--08/08/2017	
    -- // Pagos Referenciados CREDIAVANCE ABONO
	if ptransacc IN ("1328","1388") then
        if va_ccmayor = "2101" then
            let va_sector = "26";
        end if;	 
    end if;	
	
 
 -- // Pago de Remesas BTS
    if ptransacc = '0273' and psecuencia = '2' and pproducto = '1600' and pdescripcion = 'ABSPEIBTS' then
        if va_ccmayor = '2101' then
            let va_sector = '42';
            let pdescripcion = 'ABSPEI';            
        end if;	 
    end if;

	
    -- // Pago de Remesas WU
    if ptransacc = '0273' and psecuencia = '2' and pproducto = '2200' and pdescripcion = 'ABSPEIWU' then
        if va_ccmayor = '2101' then
            let va_sector = '31';
            let pdescripcion = 'ABSPEI';
        end if;	 
    end if;
	
	-- // Pago de Remesas APPRIZA PAY
    if ptransacc = '0273' and psecuencia = '2' and pproducto = '1600' and pdescripcion = 'ABSPEIAPP' then
        if va_ccmayor = '2101' then
            let va_sector = '42';
            let pdescripcion = 'ABSPEI';            
        end if;	 
    end if;
}	

    if ptransacc = "0205" and pproducto = "8000" then
        if va_ccmayor = "2101" then
            let va_sector = "32";
        end if;	 
    end if;
	
	if pproducto = "8000" THEN
	   IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '210101030201' THEN
        LET va_sector = '31';
	   END IF;
	end if;
	   
	
	if pcancelad = "V" then
        let pmoneda = vgcodigo_mn;
    end if;

    if va_ccmayor  = viva_ccmayor   AND
       va_ccsub    = viva_ccsub     AND
       va_ccsubsub = viva_ccsubsub  AND
       va_ccsssub  = viva_ccsssub   AND
       va_ccssssub = viva_ccssssub  THEN
        let va_sector = viva_sector;
    end if;

    if va_ccmayor  = vitr_ccmayor   AND
       va_ccsub    = vitr_ccsub     AND
       va_ccsubsub = vitr_ccsubsub  AND
       va_ccsssub  = vitr_ccsssub   AND
       va_ccssssub = vitr_ccssssub  THEN
        let va_sector = vitr_sector;
    end if;

    let va_ccmayor  = trim(va_ccmayor);
    let va_ccsub    = trim(va_ccsub);
    let va_ccsubsub = trim(va_ccsubsub);
    let va_ccsssub  = trim(va_ccsssub);
    let va_ccssssub = trim(va_ccssssub);
    
    if ptransacc = '0274' AND trim(va_ccmayor)||trim(va_ccsub) = '951102' THEN
        let psucope = '9201';
    end if;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '240290200201' THEN
        LET va_sector = '31';
    END IF;
	
	IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '240290240000' THEN
        LET va_sector = '31';
    END IF;
	
	IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '140290141101' THEN
        LET va_sector = '31';
    END IF;

	IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '240293030400' THEN
        LET va_sector = '31';
    END IF;		
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '240208040303' THEN
        LET va_sector = '11';
    END IF;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub)||trim(va_sector) = '14029025000000' THEN
        LET psuccta = '9201';
    END IF;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '140295040100' THEN
        LET psuccta = '5001';
    END IF;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '140290140101' THEN
        LET psuccta = '5005';
    END IF;
    
    IF trim(va_ccmayor)||trim(va_ccsub)||trim(va_ccsubsub)||trim(va_ccsssub)||trim(va_ccssssub) = '140290141101' THEN
        LET psuccta = '5005';
    END IF;
	
	IF ptransacc IN('0273', '0276', '0277') AND va_ccmayor = '2101' THEN
	   --- LET psucope = vsuccta;
       LET psuccta = vsuccta;
	END IF;

    insert into aux_auditerr values
    (pempresa,va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector,v_auxiliar,pproducto,ptransacc,pmonto_tot);	
	
    -- // Para cuentas de enlace..
    IF va_ccmayor[1,2] = "95" THEN 
        insert into sc_contab_temp values
        (pempresa, w_secuencia, psucope, psucope, va_ccmayor, va_ccsub, va_ccsubsub, 
         va_ccsssub, va_ccssssub, va_sector, v_auxiliar, 0, pmonto_tot, pmoneda, pdescripcion);
    ELSE -- // Para el resto de las cuentas...
        insert into sc_contab_temp values
        (pempresa, w_secuencia, psucope, psuccta, va_ccmayor, va_ccsub, va_ccsubsub,
         va_ccsssub, va_ccssssub, va_sector, v_auxiliar, 0, pmonto_tot, pmoneda, pdescripcion);
    END IF;

    end;

	IF ( ((SELECT COUNT(*) FROM tmp_si_catalog 
	                    WHERE empresa = pempresa 
						  AND ccmayor = va_ccmayor 
						  AND ccsub = va_ccsub
						  AND ccsubsub = va_ccsubsub
						  AND ccssubsub = va_ccsssub
						  AND ccsssubsub = va_ccssssub
						  AND sector = va_sector ) > 0) 
		AND
		  ((SELECT COUNT(*) FROM tmp_si_catalog 
	                    WHERE empresa = pempresa 
						  AND ccmayor = vc_ccmayor 
						  AND ccsub = vc_ccsub
						  AND ccsubsub = vc_ccsubsub
						  AND ccssubsub = vc_ccsssub
						  AND ccsssubsub = vc_ccssssub
						  AND sector = vc_sector ) > 0)						  
						  ) THEN
	
		INSERT INTO bdicheq:sc_contab		
		SELECT empresa,secuencia,sucursal,succta,ccmayor,ccsub,ccsubsub,     
					ccssubsub,ccsssubsub,sector,auxiliar,tot_cargo,tot_abono,moneda,descripcion 
			   FROM sc_contab_temp;
		
	ELSE
	
        IF vsc_contab_temp = 'T' THEN
	
			DROP TABLE sc_contab_temp;
			LET vsc_contab_temp = 'F';
		
		END IF
		
		CALL sp_suspenso(pempresa,'01',pmonto_tot,psecuencia,psucope,psuccta,pcancelad,pproducto,pmoneda,ptransacc,psector,
		                 case when pdescripcion = 'ABSPEIWU' OR pdescripcion = 'ABSPEIBTS' OR pdescripcion = 'ABSPEIAPP' then 'ABSPEI' else pdescripcion end ,vfecha_hoy) 

        RETURNING vcodret,vc_ccmayor,vc_ccsub,vc_ccsubsub,vc_ccsssub,vc_ccssssub,vc_sector,
                          va_ccmayor,va_ccsub,va_ccsubsub,va_ccsssub,va_ccssssub,va_sector;

		INSERT INTO bdicheq:sc_contab 
		     VALUES (pempresa, w_secuencia, psucope, psuccta, vc_ccmayor, vc_ccsub, vc_ccsubsub,
                     vc_ccsssub, vc_ccssssub, vc_sector, v_auxiliar, pmonto_tot, 0, pmoneda, pdescripcion );
		
		INSERT INTO bdicheq:sc_contab 
			 VALUES (pempresa, w_secuencia, psucope, psuccta, va_ccmayor, va_ccsub, va_ccsubsub,
					va_ccsssub, va_ccssssub, va_sector, v_auxiliar, 0, pmonto_tot, pmoneda, pdescripcion);
		
	END IF;
	
	IF vsc_contab_temp = 'T' THEN
	
		DROP TABLE sc_contab_temp;
		LET vsc_contab_temp = 'F';
		
	END IF
	
    return vcodret;

end procedure;