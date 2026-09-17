CREATE PROCEDURE "informix".sp_generaarchivoconsultarespuestaburo(p_Empresa CHAR(3), p_TipoMov1 CHAR(2), p_TipoMov2 CHAR(2))
RETURNING
     CHAR(5); ---cod_ret

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);

	DEFINE v_Sucursal		    CHAR(4);
	DEFINE sTiendaFolio			SMALLINT;
	DEFINE v_CteNomUno		    CHAR(26);
	DEFINE v_CteNomDos		    CHAR(26);
	DEFINE v_CteApePat		    CHAR(26);
	DEFINE v_CteApeMat		    CHAR(26);
	DEFINE v_CteBancoppel		CHAR(20);
	DEFINE v_Consulta			LVARCHAR (32000);
	DEFINE v_Idburo				CHAR(1);
	DEFINE v_FechaConsulta		DATE;
	DEFINE v_Trama				LVARCHAR (32000);
	DEFINE v_Respuesta			LVARCHAR(4005);
	DEFINE vFecha_Hoy 			DATE;
	DEFINE vnumcte 				CHAR(20);
	DEFINE v_NumSol				CHAR(20);
	DEFINE iSecuencia			INTEGER;
	DEFINE cFec_Consult			CHAR(10);

	LET v_Sucursal		    = '';
	LET sTiendaFolio		= 0 ;
	LET v_CteNomUno		    = '';
	LET v_CteNomDos		    = '';
	LET v_CteApePat		    = '';
	LET v_CteApeMat		    = '';
	LET v_CteBancoppel		= '';
	LET v_Consulta			= '';
	LET v_Idburo			= '';
	LET v_FechaConsulta		= DATE(1);
	LET v_Trama				= '';
	LET v_Respuesta			= '';
	LET vFecha_Hoy 			= DATE(1);
	LET vnumcte				= '';
	LET v_NumSol 			= '';
	LET cFec_Consult		= '19000101';
	
	SET LOCK MODE TO WAIT 10;

BEGIN

    ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/tmp/sp_GeneraArchivoConsultaRespuestaBuro.out";
    --TRACE ON;

	LET v_cod_ret = '00000';
	LET vDesErr = '';
	
	SELECT fecha_hoy INTO vFecha_Hoy FROM bdinteg:"informix".si_fechas;

	IF (p_Empresa IS NULL OR p_Empresa = '')  THEN 
		RETURN '00001';
	ELSE
	
		IF(p_TipoMov1 IS NOT NULL AND p_TipoMov1 <> '')  THEN 
			---BURO CONSULTA - BC
			FOREACH
				SELECT {+INDEX(bdinteg:"informix".si_adiccoppel idx_adiccoppel)} a.numcte--, TRIM(ss.sucursal), ss.num_solicitud 
				INTO vnumcte--, v_Sucursal, v_NumSol
				FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_adiccoppel b--, bdisolic:"informix".ss_solicitudes ss
				WHERE a.fecha_insert = vFecha_Hoy 
				AND a.numcte_ref = b.numctecoppel AND a.numcte = b.numcte AND a.empresa = b.empresa
				AND b.empresa = p_Empresa AND b.secuencia = 1 AND b.numcte = b.numcte AND b.sucursal = b.sucursal 
				
				SELECT ss.sucursal,ss.sucursal::SMALLINT, ss.num_solicitud 
				INTO v_Sucursal, sTiendaFolio, v_NumSol
				FROM bdisolic:"informix".ss_solicitudes ss
				WHERE ss.numcte = vnumcte AND ss.status_solicitud = 'BC';
				
				IF NVL(v_NumSol, '') <> '' THEN 
					
					SELECT TRIM(numcte), TRIM(nombre1), TRIM(nombre2) , TRIM(apell_paterno) , TRIM(apell_materno)
					INTO  v_CteBancoppel, v_CteNomUno, v_CteNomDos, v_CteApePat, v_CteApeMat
					FROM bdinteg:"informix".si_cliente
					WHERE empresa = p_Empresa AND numcte = vnumcte;
					
					SELECT (envio||envio1||envio2),'1', fecha_insert
					INTO v_Consulta,v_Idburo, v_FechaConsulta
					FROM bdiburo:"informix".br_traslado
					WHERE num_solicitud = v_NumSol AND (envio IS NOT NULL OR envio <> "") 
					AND (envio1 IS NOT NULL OR envio1 <> "") AND (envio2 IS NOT NULL OR envio2 <> "");
					
					LET cFec_Consult = YEAR(v_FechaConsulta)||""||LPAD(MONTH(v_FechaConsulta),2,0)||""||LPAD(DAY(v_FechaConsulta),2,0);
													
					IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = p_Empresa AND tipomovto <> 'TO') THEN
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO') THEN
							LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO');
						ELSE
							LET iSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1  FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = p_Empresa AND tipomovto <> 'TO');
						END IF;
					ELSE
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO') THEN
							LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO');
						ELSE
							LET iSecuencia = 1;
						END IF;
					END IF;
					
					LET v_Trama = sTiendaFolio|| " 	 "||v_CteNomUno|| " 	 "||v_CteNomDos|| " 	 "||v_CteApePat|| " 	 "||v_CteApeMat|| " 	 "||v_CteBancoppel|| " 	 "||v_Consulta|| " 	 "||v_Idburo|| " 	 "||TRIM(NVL(cFec_Consult, '19000101'));
					LET v_Trama =  NVL(v_Trama,'');
					
					INSERT  INTO  bdinteg:"informix". si_archivoscoppeldiario  (empresa,secuencia,sucursal,trama,tipomovto,fecha_insert)
					VALUES (p_Empresa,iSecuencia,v_Sucursal,v_Trama,p_TipoMov1,current);
				END IF;
			END FOREACH
		ELSE
			RETURN '00001';
		END IF

		IF (p_TipoMov2 IS NOT NULL AND p_TipoMov2 <> '')  THEN 
			---BURO RESPUESTA - BR    
			FOREACH
				SELECT {+INDEX(bdinteg:"informix".si_adiccoppel idx_adiccoppel)} a.numcte--, TRIM(ss.sucursal), ss.num_solicitud 
				INTO vnumcte--, v_Sucursal, v_NumSol
				FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_adiccoppel b--, bdisolic:"informix".ss_solicitudes ss
				WHERE a.fecha_insert = vFecha_Hoy 
				AND a.numcte_ref = b.numctecoppel AND a.numcte = b.numcte AND a.empresa = b.empresa
				AND b.empresa = p_Empresa AND b.secuencia = 1 AND b.numcte = b.numcte AND b.sucursal = b.sucursal 

				SELECT TRIM(ss.sucursal), ss.sucursal::SMALLINT, ss.num_solicitud 
				INTO v_Sucursal, sTiendaFolio, v_NumSol
				FROM bdisolic:"informix".ss_solicitudes ss
				WHERE ss.numcte = vnumcte AND ss.status_solicitud IN ('RT', 'AT', 'EE', 'CC', 'AP');
				
				IF NVL(v_NumSol, '') <> '' THEN 			

					SELECT TRIM(numcte), TRIM(nombre1), TRIM(nombre2) , TRIM(apell_paterno) , TRIM(apell_materno)
					INTO v_CteBancoppel, v_CteNomUno, v_CteNomDos, v_CteApePat, v_CteApeMat
					FROM bdinteg:"informix".si_cliente
					WHERE empresa = p_Empresa AND numcte = vnumcte;
					
					SELECT regreso, '1'
					INTO  v_Respuesta, v_Idburo
					FROM  bdiburo:"informix".sb_regreso 
					WHERE  num_solicitud = v_NumSol;
					
					LET v_FechaConsulta = CURRENT;
					
					LET cFec_Consult = YEAR(v_FechaConsulta)||""||LPAD(MONTH(v_FechaConsulta),2,0)||""||LPAD(DAY(v_FechaConsulta),2,0);
					
					IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = p_Empresa AND tipomovto <> 'TO') THEN
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO') THEN
							LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO');
						ELSE
							LET iSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1  FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = p_Empresa AND tipomovto <> 'TO');
						END IF;
					ELSE
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO') THEN
							LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO');
						ELSE
							LET iSecuencia = 1;
						END IF;
					END IF;
					
					LET v_Trama = sTiendaFolio|| " 	 "||v_CteNomUno|| " 	 "||v_CteNomDos|| " 	 "||v_CteApePat|| " 	 "||v_CteApeMat|| " 	 "||v_CteBancoppel|| " 	 "||""|| " 	 "||v_Respuesta|| " 	 "||v_Idburo|| " 	 "||TRIM(NVL(cFec_Consult, '19000101'));
					LET v_Trama =  NVL(v_Trama,'');
					
					INSERT INTO bdinteg:"informix".si_archivoscoppeldiario  (empresa,secuencia,sucursal,trama,tipomovto,fecha_insert)
					VALUES (p_Empresa,iSecuencia,v_Sucursal,v_Trama,p_TipoMov2,current);
				END IF;	
			END FOREACH
		ELSE
			RETURN '00001';
		END IF
	END IF
	
	RETURN v_cod_ret;

END;
--##############################################################################
--## Procedimiento  : "informix".sp_GeneraArchivoConsultaRespuestaBuro
--## Version        : 1.0
--## Creado por     : Mohamed Carreón
--## Fecha creacion : Diciembre de 2008
--##Descripcion 	: Realiza la extraccion de datos para la Consulta y Respuesta del buro.
--##############################################################################
--##Modificado por  : Adrian Lara
--##Fecha Modifica  : Junio de 2011
--##Descripción     : Se generan archivos, se agreagan nuevas consultas y correcciones en la trama de datos.
--##############################################################################
END PROCEDURE;