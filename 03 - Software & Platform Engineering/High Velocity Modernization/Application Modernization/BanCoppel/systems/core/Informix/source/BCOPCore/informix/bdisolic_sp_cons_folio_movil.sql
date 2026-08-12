CREATE PROCEDURE "informix".sp_cons_folio_movil(pRFC CHAR(13), pfolio CHAR(12), pOCR CHAR(9), pApPat CHAR(30), pApMat CHAR(30), pNom1 CHAR(30), pNom2 CHAR(30), pFecNac CHAR(10))
       RETURNING CHAR(5) as codret, CHAR(13) as RFC, CHAR(26) as Paterno, CHAR(26) as Materno, CHAR(26) as Nombre1,
                 CHAR(26) as sNombre2, CHAR(10) as Fecha_Nac, CHAR(10) as Telefono, CHAR(1) as esCteCoppel, CHAR(11) as NumCteCoppel,
                 CHAR(9) as NumCteMovil, CHAR(5) as CodPos, CHAR(1) as DomicAct, CHAR(12) as NumSolBanco, CHAR(12) as NumSolCoppel,
                 CHAR(12) as NumSolPresPer, CHAR(15) as FolioMovil, CHAR(2) as Opcion, CHAR(1) as EnviaSMS, CHAR(1) as Carrier,
                 CHAR(13) as OCR, CHAR(60) as Empresa, CHAR(10) as TelTrab;

DEFINE iSqlErr		INTEGER;
DEFINE sCodRet          CHAR(5);
DEFINE sErrProc		CHAR(5);
DEFINE sNumCte          CHAR(9);
DEFINE sRFC             CHAR(13);
DEFINE sPaterno         CHAR(26);
DEFINE sMaterno         CHAR(26);
DEFINE sNombre1         CHAR(26);
DEFINE sNombre2         CHAR(26);
DEFINE sFecha_Nac       CHAR(10);
DEFINE sTelefono        CHAR(10);
DEFINE sCteCoppel       CHAR(1);
DEFINE sNumCteCoppel    CHAR(11);
DEFINE sNumCteMovil     CHAR(9);
DEFINE sCodPos          CHAR(5);
DEFINE sDomicAct        CHAR(1);
DEFINE sNumSolBanco     CHAR(12);
DEFINE sNumSolCoppel    CHAR(12);
DEFINE sNumSolPresPer   CHAR(12);
DEFINE sFolioMovil      CHAR(15);
DEFINE sTipoBusqueda    CHAR(2);
DEFINE sEnviaSMS        CHAR(1);
DEFINE sCarrier         CHAR(1);
DEFINE sEmpresa         CHAR(60);
DEFINE sTelTrab         CHAR(10);
DEFINE pOCRconsulta     CHAR(13);

--VARIABLES PARA COMPARACION DE NOMBRES
DEFINE sNom1A           CHAR(26);
DEFINE sNom2A           CHAR(26);
DEFINE sApPatA          CHAR(26);
DEFINE sApMatA          CHAR(26);
DEFINE sFecNacA         CHAR(10);
DEFINE sNom1B           CHAR(26);
DEFINE sNom2B           CHAR(26);
DEFINE sApPatB          CHAR(26);
DEFINE sApMatB          CHAR(26);
DEFINE sFecNacB         CHAR(10);
DEFINE dPorcentaje      DECIMAL(6,1);
DEFINE dParamPorc       DECIMAL(6,1);
DEFINE sRFCCortoA       CHAR(10);
DEFINE sRFCCortoB       CHAR(10);
DEFINE sOCRMovil        CHAR(9);
DEFINE sOCR             CHAR(13);

DEFINE sOCRMin          CHAR(13);
DEFINE sOCRMay          CHAR(13);

DEFINE sNom1_Ap           CHAR(26);
DEFINE sNom2_AP           CHAR(26);
DEFINE sApPat_AP          CHAR(26);
DEFINE sApMat_AP          CHAR(26);
DEFINE sFecNac_AP         CHAR(10);
DEFINE sCodRetRFC         CHAR(5);
DEFINE sAp_RFC            CHAR(13);
DEFINE svt_dia            CHAR(2);
DEFINE svt_mes            CHAR(2);
DEFINE svt_year           CHAR(4);
DEFINE sFecNac            CHAR(10);

DEFINE sRevTdcCopp        CHAR(12);
DEFINE sRevTdcBanc        CHAR(12);
DEFINE sRevNumPP          CHAR(12);
DEFINE iRevConta          INTEGER;
DEFINE iRevContaCN        INTEGER;
DEFINE iExists		      INTEGER;
DEFINE iExistsA		      INTEGER;
DEFINE iExistsB		      INTEGER;
DEFINE iExistsC		      INTEGER;
DEFINE iExistsD		      INTEGER;

LET iSqlErr          =0;
LET sCodRet          ='00000';
LET sErrProc         ='';
LET sNumCte          ='';
LET sRFC             ='';
LET sPaterno         ='';
LET sMaterno         ='';
LET sNombre1         ='';
LET sNombre2         ='';
LET sFecha_Nac       ='';
LET sTelefono        ='';
LET sCteCoppel       ='';
LET sNumCteCoppel    ='';
LET sNumCteMovil     ='';
LET sCodPos          ='';
LET sDomicAct        ='';
LET sNumSolBanco     ='';
LET sNumSolCoppel    ='';
LET sNumSolPresPer   ='';
LET sFolioMovil      ='';
LET sTipoBusqueda    ='';
LET sEnviaSMS        ='0';
LET sCarrier         ='';

LET sNom1A           ='';
LET sNom2A           ='';
LET sApPatA          ='';
LET sApMatA          ='';
LET sFecNacA         ='';
LET sNom1B           ='';
LET sNom2B           ='';
LET sApPatB          ='';
LET sApMatB          ='';
LET sFecNacB         ='';
LET dPorcentaje      =0;
LET dParamPorc       =0;
LET sRFCCortoA       ='';
LET sRFCCortoB       ='';
LET sOCRMovil        ='';
LET sOCR             ='';
LET sEmpresa         ='';
LET sTelTrab         ='';

LET sOCRMin             ='';
LET sOCRMay             ='';

LET sNom1_Ap         ='';
LET sNom2_AP         ='';
LET sApPat_AP        ='';
LET sApMat_AP        ='';
LET sFecNac_AP       ='';
LET sCodRetRFC       ='';
LET sAp_RFC          ='';
LET svt_dia          ='';
LET svt_mes          ='';
LET svt_year         ='';
LET sFecNac          ='';

LET sRevTdcCopp      ='';
LET sRevTdcBanc      ='';
LET sRevNumPP        ='';   
LET iRevConta        =0;
LET iRevContaCN      =0;
LET iExists 		 =0;
LET iExistsA 		 =0;
LET iExistsB 		 =0;
LET iExistsC 		 =0;
LET iExistsD 		 =0;
LET pOCRconsulta     ='';

BEGIN
	ON EXCEPTION SET iSqlErr

	IF iSqlErr <> 0 THEN
		RETURN iSqlErr, sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac,
                       sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct,
                       sNumSolBanco, sNumSolCoppel, sNumSolPresPer, sFolioMovil, sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
        END IF;

	END EXCEPTION;

--SET DEBUG FILE TO '/informix/gaby/cons_folio.sql';
--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
--SI EL CAMPO OCR VIENE EN BLANCO, SE RETORNA UN VALOR DE 8
		
		
        --BUSCANDO POR RFC y FOLIO
		SELECT COUNT(*) INTO iExists  FROM bdinteg:si_solicitud_movil WHERE folio=pfolio AND ap_rfc=pRFC AND folio_procesado='0' AND status_valua='1';
		--BUSCA EL NUMCTE DEL CLIENTE
		SELECT FIRST 1 numcte INTO sNumCte FROM bdinteg:si_cliente WHERE rfc=pRFC;   
		
		IF (iExists <= 0) THEN
			--BUSCANDO POR RFC CORRECTO y FOLIO INCORRECTO
			SELECT count(*) INTO iExistsA FROM bdinteg:si_solicitud_movil WHERE ap_rfc=pRFC AND folio_procesado='0' AND status_valua='1';
			IF (iExistsA <= 0) THEN
				--BUSCANDO POR FOLIO CORRECTO y RFC INCORRECTO RUTINA BTS
				SELECT COUNT(*) INTO iExistsB FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1';
				IF (iExistsB <= 0 and pOCR <> '' )  THEN		
					LET pOCRconsulta =  '*'||trim(pOCR);
					--SI EL RFC NO COINCIDE, SE VALIDA EL OCR
					--BUSCANDO POR RFC INCORRECTO y FOLIO INCORRECTO. SE BUSCA POR OCR
					SELECT COUNT(*) INTO iExistsC FROM bdinteg:si_solicitud_movil WHERE numcte = sNumCte and  ocr <> '' and ocr matches pOCRconsulta AND folio_procesado='0' and status_valua='1';
					LET iExistsD = iExistsC;
				END IF;
			END IF;
		END IF;

        IF (iExists > 0) THEN
			LET iExists = 0;
		
            LET sTipoBusqueda='1';
            --OBTENIENDO EL RFC CON LOS DATOS MODIFICADOS
			
			SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_folio_procesado)} FIRST 1 ap_apell_paterno, ap_apell_materno, ap_nombre1, ap_nombre2, ap_fecha_nac 
			INTO sappat_ap, sapmat_ap, snom1_ap, snom2_ap, sfecnac_ap
			FROM bdinteg:si_solicitud_movil WHERE folio=pfolio AND ap_rfc=pRFC AND folio_procesado='0' AND status_valua='1'
			AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pfolio AND ap_rfc=pRFC AND folio_procesado='0' AND status_valua='1');
			
			LET svt_dia = "";
			LET svt_mes = "";
			LET svt_year = "";

			IF LENGTH(sfecnac_ap)=8 THEN
				LET svt_dia = sfecnac_ap[1,2];
				LET svt_mes = sfecnac_ap[3,4];
				LET svt_year = sfecnac_ap[5,8];
				UPDATE 
				{+INDEX (bdinteg:"informix".si_solicitud_movil idx_ap_rfc)}
				bdinteg:si_solicitud_movil SET ap_fecha_nac=(svt_dia||'/'||svt_mes||'/'||svt_year) WHERE ap_rfc=pRFC;
			ELSE
				LET svt_dia = sfecnac_ap[1,2];
				LET svt_mes = sfecnac_ap[4,5];
				LET svt_year = sfecnac_ap[7,10];
			END IF;

			IF LENGTH(svt_year)<=2 THEN
				LET svt_year="19"||svt_year;
			END IF;

			LET sfecnac_ap = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);

			CALL bdinteg:sp_calcularrfc(sappat_ap, sapmat_ap, snom1_ap||' '||snom2_ap, sfecnac_ap) RETURNING sCodRetRFC, sAp_RFC;
		
			IF pRFC<>sAp_RFC THEN
			   LET pRFC=sAp_RFC;
			END IF;
   --FIN DE LA BUSQUEDA CON DATOS MODIFICADOS
		  

--***********************NUEVOS CAMBIOS
			SELECT FIRST 1 num_tdc_coppel, num_tdc_bcoppel, num_prestamo INTO sRevTdcCopp, sRevTdcBanc, sRevNumPP
			FROM bdinteg:si_solicitud_movil where numcte=sNumCte AND folio=pfolio
			AND fecha_hora = (SELECT MAX(fecha_hora) from bdinteg:si_solicitud_movil where numcte=sNumCte AND folio=pfolio);

			IF (NVL(sRevTdcCopp,'0'))<>'0' then
				LET iRevConta=iRevConta+1; 

				select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcCopp and status_solicitud='CN';
				IF (iExists > 0) THEN
					LET iExists = 0;
					LET iRevContaCN=iRevContaCN+1;      
				END IF;
			END IF;

			IF (NVL(sRevTdcBanc,'0'))<>'0' then
				LET iRevConta=iRevConta+1;

				select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcBanc and status_solicitud='CN';
				IF (iExists > 0) THEN
					LET iExists = 0;
					LET iRevContaCN=iRevContaCN+1;      
				END IF;      
			END IF;

			IF (NVL(sRevNumPP,'0'))<>'0' then
				LET iRevConta=iRevConta+1;      

				select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevNumPP and status_solicitud='CN';
				IF (iExists > 0) THEN
					LET iExists = 0;
					LET iRevContaCN=iRevContaCN+1;      
				END IF;      
			END IF;

			IF iRevConta=iRevContaCN THEN
				UPDATE {+INDEX (bdinteg:"informix".si_solicitud_movil idx_ct)} bdinteg:si_solicitud_movil set folio_procesado='1' where numcte=sNumCte and folio=pfolio;

				LET sTipoBusqueda=0;

				--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
			    LET sOCRMin = LOWER(sOCR);
				LET sOCRMay = UPPER(sOCR);
				
				IF(sOCRMin != sOCRMay) THEN
					LET sOCR = '';
				END IF;
				--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
			   
			   RETURN sCodRet, sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac,
					   sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct,
					   sNumSolBanco, sNumSolCoppel, sNumSolPresPer, sFolioMovil, sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
			END IF;
--***********************NUEVOS CAMBIOS
			
			SELECT FIRST 1 a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel, a.numcte,
			e.cod_postal, f.domicilio_actual, f.folio, a.rfc, f.empresa, f.tel_trabajo, f.ocr
			INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil,
			sCodPos, sDomicAct, sFolioMovil, sRFC, sEmpresa, sTelTrab, sOCR
			FROM bdinteg:si_cliente a
			INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
			LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
			LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
			LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte 
			--AND f.fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pfolio AND numcte = a.numcte)
			WHERE a.numcte=sNumCte AND f.folio=pfolio;

			
			SELECT FIRST 1 num_solicitud INTO sNumSolBanco
			FROM bdisolic:ss_solicitudes
			WHERE numcte=sNumCte
			AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

			
			SELECT FIRST 1 num_solicitud INTO sNumSolCoppel
			FROM bdisolic:ss_solicitudes
			WHERE numcte=sNumCte
			AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

			
			SELECT FIRST 1 num_solicitud INTO sNumSolPresPer
			FROM bdisolic:ss_solicitudes
			WHERE numcte=sNumCte
			AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

          --BUSCANDO POR RFC CORRECTO y FOLIO INCORRECTO
		ELIF (iExistsA > 0) THEN

				LET iExists = 0;
                LET sTipoBusqueda='2';
                
			--OBTENIENDO EL RFC CON LOS DATOS MODIFICADOS
			
			SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_ap_rfc, idx_valida_opera)} FIRST 1 ap_apell_paterno, ap_apell_materno, ap_nombre1, ap_nombre2, ap_fecha_nac , folio
			INTO sappat_ap, sapmat_ap, snom1_ap, snom2_ap, sfecnac_ap, pFolio
			FROM bdinteg:si_solicitud_movil WHERE ap_rfc=pRFC AND folio_procesado='0' AND status_valua='1'
			AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE ap_rfc=pRFC AND folio_procesado='0' AND status_valua='1');

			LET svt_dia = "";
			LET svt_mes = "";
			LET svt_year = "";

			IF LENGTH(sfecnac_ap)=8 THEN
				LET svt_dia = sfecnac_ap[1,2];
				LET svt_mes = sfecnac_ap[3,4];
				LET svt_year = sfecnac_ap[5,8];
				UPDATE 
				{+INDEX (bdinteg:"informix".si_solicitud_movil idx_ap_rfc)}
				bdinteg:si_solicitud_movil SET ap_fecha_nac=(svt_dia||'/'||svt_mes||'/'||svt_year) WHERE ap_rfc=pRFC;
			ELSE
				LET svt_dia = sfecnac_ap[1,2];
				LET svt_mes = sfecnac_ap[4,5];
				LET svt_year = sfecnac_ap[7,10];
			END IF; 

			IF LENGTH(svt_year)<=2 THEN
				LET svt_year="19"||svt_year;
			END IF;

            LET sfecnac_ap = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);

            CALL bdinteg:sp_calcularrfc(sappat_ap, sapmat_ap, snom1_ap||' '||snom2_ap, sfecnac_ap) RETURNING sCodRetRFC, sAp_RFC;
                
			IF pRFC<>sAp_RFC THEN
			   LET pRFC=sAp_RFC;
			END IF;
           --FIN DE LA BUSQUEDA CON DATOS MODIFICADOS
                --SE MANDA A BUSCAR EL NUM DE CTE CON EL RFC ENCONTRADO
            SELECT FIRST 1 numcte INTO sNumCte FROM bdinteg:si_cliente WHERE rfc=pRFC;
			--SE MANDA A CONSULTAR SI EXISTE UNA SOLICITUD MOVIL CON EL NUM DE CTE
			    SELECT COUNT(*) INTO iExists FROM bdinteg:si_solicitud_movil WHERE numcte=sNumCte AND folio_procesado='0' AND status_valua='1';
				IF (iExists > 0) THEN
					LET iExists = 0;
		--***********************NUEVOS CAMBIOS
					
					SELECT FIRST 1 num_tdc_coppel, num_tdc_bcoppel, num_prestamo INTO sRevTdcCopp, sRevTdcBanc, sRevNumPP
					FROM bdinteg:si_solicitud_movil where numcte=sNumCte AND folio_procesado='0' AND status_valua='1'
					AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil where numcte=sNumCte AND folio_procesado='0' AND status_valua='1');

					IF (NVL(sRevTdcCopp,'0'))<>'0' then
						LET iRevConta=iRevConta+1; 
						select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcCopp and status_solicitud='CN';
						IF (iExists > 0) THEN
							LET iExists = 0;
							LET iRevContaCN=iRevContaCN+1;      
						END IF;
					END IF;

					IF (NVL(sRevTdcBanc,'0'))<>'0' then
						LET iRevConta=iRevConta+1;
						select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcBanc and status_solicitud='CN';
						IF (iExists > 0) THEN
							LET iExists = 0;
							LET iRevContaCN=iRevContaCN+1;      
						END IF;      
					END IF;

					IF (NVL(sRevNumPP,'0'))<>'0' then
						LET iRevConta=iRevConta+1;      
						select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevNumPP and status_solicitud='CN';
						IF (iExists > 0) THEN
							LET iExists = 0;
							LET iRevContaCN=iRevContaCN+1;      
						END IF;      
					END IF;

					IF iRevConta=iRevContaCN THEN
						UPDATE {+INDEX (bdinteg:"informix".si_solicitud_movil idx_ct)} bdinteg:si_solicitud_movil set folio_procesado='1' where numcte=sNumCte and folio = pFolio;
						LET sTipoBusqueda=0;
						
						--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
						LET sOCRMin = LOWER(sOCR);
						LET sOCRMay = UPPER(sOCR);
						
						IF(sOCRMin != sOCRMay) THEN
							LET sOCR = '';
						END IF;
						--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
						
						RETURN sCodRet, sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac,
							   sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct,
							   sNumSolBanco, sNumSolCoppel, sNumSolPresPer, sFolioMovil, sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
					END IF;
		--***********************NUEVOS CAMBIOS
					
					SELECT FIRST 1 a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel,
					a.numcte, e.cod_postal, f.domicilio_actual, f.folio, a.rfc, f.empresa, f.tel_trabajo, f.ocr
					INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel,
					sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sEmpresa, sTelTrab, sOCR
					FROM bdinteg:si_cliente a
					INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
					LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
					LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
					LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte AND f.folio_procesado='0' AND f.status_valua='1' 
					--AND f.fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE numcte = a.numcte AND folio_procesado='0' AND status_valua='1' and folio = pFolio)
					WHERE a.numcte=sNumCte and f.folio = pFolio;

					
					SELECT FIRST 1 num_solicitud INTO sNumSolBanco
					FROM bdisolic:ss_solicitudes
					WHERE numcte=sNumCte
					AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

					
					SELECT FIRST 1 num_solicitud INTO sNumSolCoppel
					FROM bdisolic:ss_solicitudes
					WHERE numcte=sNumCte
					AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

					
					SELECT FIRST 1 num_solicitud INTO sNumSolPresPer
					FROM bdisolic:ss_solicitudes
					WHERE numcte=sNumCte
					AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');
				END IF;

            --BUSCANDO POR FOLIO CORRECTO y RFC INCORRECTO RUTINA BTS
        ELIF (iExistsB > 0) THEN
			LET iExists = 0;
			--EXTRAYENDO EL NUMERO DE CLIENTE y DATOS GENERALES DE LA TABLA DE SOLICITUDES_MOVIL
			
			SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_folio, idx_valida_opera)} FIRST 1 numcte, ap_apell_paterno, ap_apell_materno, ap_nombre1, ap_nombre2
			INTO sNumCte, sApPatA, sApMatA, sNom1A, sNom2A
			FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'
			AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1');

			LET sFecNacA=(SELECT {+INDEX (bdinteg:"informix".si_fechas idx_folio)} FIRST 1 SUBSTRING(ap_fecha_nac FROM 4 FOR 2)||'/'||SUBSTRING(ap_fecha_nac FROM 1 FOR 2)||'/'||SUBSTRING(ap_fecha_nac FROM 7 FOR 4)
						 FROM bdinteg:si_solicitud_movil WHERE folio=pFolio
						 AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio));

                --EXTRAYENDO LOS DATOS DEL CLIENTE A COMPARAR DE ACUERDO AL NUMCTE OBTENIDO DE LA TABLA SOLICITUDES_MOVIL

			LET pFecNac=(SELECT SUBSTRING(pFecNac FROM 4 FOR 2)||'/'||SUBSTRING(pFecNac FROM 1 FOR 2)||'/'||SUBSTRING(pFecNac FROM 7 FOR 4)
						 FROM bdinteg:si_fechas);

			--EJECUTANDO RUTINA DE COMPARACION
			EXECUTE PROCEDURE bdinteg:sp_validanombrefn(sNom1A, sNom2A, sApPatA, sApMatA, sFecNacA, pNom1,  pNom2, pApPat, pApMat, pFecNac, 0)
			INTO sErrProc, dPorcentaje;

			SELECT valor INTO dParamPorc FROM bdinteg:si_param WHERE cod_param='337';

                --SI LA COMPARACION ES IGUAL O MAYOR AL RANGO OBTENIDO DEVUELVE LA INFORMACION
			IF dPorcentaje>=dParamPorc THEN
				LET sTipoBusqueda='3';

				
				SELECT FIRST 1 a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel,
				a.numcte, e.cod_postal, f.domicilio_actual, f.folio, a.rfc, f.empresa, f.tel_trabajo, f.ocr
				INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel,
				sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sEmpresa, sTelTrab, sOCR
				FROM bdinteg:si_cliente a
				INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
				LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
				LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
				LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte AND f.folio_procesado='0' AND f.status_valua='1'
				--AND f.fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE numcte = a.numcte AND folio_procesado='0' AND status_valua='1' AND folio=pFolio)
				WHERE a.numcte=sNumCte AND f.folio=pFolio;

                                --***********************NUEVOS CAMBIOS
				SELECT FIRST 1 num_tdc_coppel, num_tdc_bcoppel, num_prestamo INTO sRevTdcCopp, sRevTdcBanc, sRevNumPP
				from bdinteg:si_solicitud_movil where numcte=sNumCte AND folio=pFolio
				AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE numcte=sNumCte AND folio=pFolio);

				IF (NVL(sRevTdcCopp,'0'))<>'0' then
					LET iRevConta=iRevConta+1; 

					select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcCopp and status_solicitud='CN';
					IF (iExists > 0) THEN
						LET iExists = 0;
						LET iRevContaCN=iRevContaCN+1;      
					END IF;
				END IF;

				IF (NVL(sRevTdcBanc,'0'))<>'0' then
					LET iRevConta=iRevConta+1;

					select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcBanc and status_solicitud='CN';
					IF (iExists > 0) THEN
						LET iExists = 0;
						LET iRevContaCN=iRevContaCN+1;      
					END IF;      
				END IF;

				IF (NVL(sRevNumPP,'0'))<>'0' then
					LET iRevConta=iRevConta+1;      

					select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevNumPP and status_solicitud='CN';
					IF (iExists > 0) THEN
						LET iExists = 0;
						LET iRevContaCN=iRevContaCN+1;      
					END IF;      
				END IF;

				IF iRevConta=iRevContaCN THEN
					UPDATE {+INDEX (bdinteg:"informix".si_solicitud_movil idx_ct)} bdinteg:si_solicitud_movil set folio_procesado='1' where numcte=sNumCte and folio=pFolio;

					LET sTipoBusqueda=0;

					--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
					LET sOCRMin = LOWER(sOCR);
					LET sOCRMay = UPPER(sOCR);
					
					IF(sOCRMin != sOCRMay) THEN
						LET sOCR = '';
					END IF;
					--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
					
					RETURN sCodRet, sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac,
						   sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct,
						   sNumSolBanco, sNumSolCoppel, sNumSolPresPer, sFolioMovil, sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
				END IF;
        --***********************NUEVOS CAMBIOS
				
				SELECT FIRST 1 num_solicitud INTO sNumSolBanco
				FROM bdisolic:ss_solicitudes
				WHERE numcte=sNumCte
				AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

								
				SELECT FIRST 1 num_solicitud INTO sNumSolCoppel
				FROM bdisolic:ss_solicitudes
				WHERE numcte=sNumCte
				AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

								
				SELECT FIRST 1 num_solicitud INTO sNumSolPresPer
				FROM bdisolic:ss_solicitudes
				WHERE numcte=sNumCte
				AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');
			ELSE
				--PORCENTAJE DE RFC ES MENOR A 90%
                LET sRFCCortoA= (select FIRST 1 SUBSTRING(pRFC FROM 1 FOR 10) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'
				AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'));
                LET sRFCCortoB= (select FIRST 1 SUBSTRING(rfc FROM 1 FOR 10) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'
				AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'));

                IF sRFCCortoA=sRFCCortoB THEN
					--RFC A 10 POSICIONES ES IGUAL
					IF ( pOCR <> '' ) THEN
						LET sOCRMovil=(select FIRST 1 SUBSTRING(ocr FROM 5 FOR 9) from bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1' 
									AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'));
					END IF;
									

					--SI EL OCR QUE SE ENVIA DESDE ALTA UNICA COINCIDE CON EL OCR DE LA SOLICITUD MOVIL, SE ENVIARA SMS
					--EN CASO CONTRARIO SE CANCELARA PORQUE COINCIDE FOLIO PERO NO LA PERSONA.
					IF pOCR=sOCRMOVIL THEN
						LET sTipoBusqueda='4';
						LET sEnviaSMS='1';
						LET sNumCte=(SELECT FIRST 1 numcte FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'
						AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'));
                        --***********************NUEVOS CAMBIOS
						SELECT FIRST 1 num_tdc_coppel, num_tdc_bcoppel, num_prestamo INTO sRevTdcCopp, sRevTdcBanc, sRevNumPP
						from bdinteg:si_solicitud_movil where numcte=sNumCte AND folio=pFolio
						AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE numcte=sNumCte AND folio=pFolio);

						IF (NVL(sRevTdcCopp,'0'))<>'0' then
							LET iRevConta=iRevConta+1; 

							select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcCopp and status_solicitud='CN';
							IF (iExists > 0) THEN
								LET iExists = 0;
								LET iRevContaCN=iRevContaCN+1;      
							END IF;
						END IF;

						IF (NVL(sRevTdcBanc,'0'))<>'0' then
							LET iRevConta=iRevConta+1;

							select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcBanc and status_solicitud='CN';
							IF (iExists > 0) THEN
								LET iExists = 0;
								LET iRevContaCN=iRevContaCN+1;      
							END IF;      
						END IF;

						IF (NVL(sRevNumPP,'0'))<>'0' then
							LET iRevConta=iRevConta+1;      

							select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevNumPP and status_solicitud='CN';
							IF (iExists > 0) THEN
								LET iExists = 0;
								LET iRevContaCN=iRevContaCN+1;      
							END IF;      
						END IF;

						IF iRevConta=iRevContaCN THEN
						   UPDATE {+INDEX (bdinteg:"informix".si_solicitud_movil idx_ct)} bdinteg:si_solicitud_movil set folio_procesado='1' where numcte=sNumCte and folio=pFolio;

						   LET sTipoBusqueda=0;

							--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
							LET sOCRMin = LOWER(sOCR);
							LET sOCRMay = UPPER(sOCR);
							
							IF(sOCRMin != sOCRMay) THEN
								LET sOCR = '';
							END IF;
							--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
						   
						   RETURN sCodRet, sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac,
								   sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct,
								   sNumSolBanco, sNumSolCoppel, sNumSolPresPer, sFolioMovil, sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
						END IF;
                        --***********************NUEVOS CAMBIOS
						
						SELECT FIRST 1 a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel, a.numcte, e.cod_postal, f.domicilio_actual, f.folio, a.rfc, d.carrier, f.empresa, f.tel_trabajo, f.ocr
						INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sCarrier, sEmpresa, sTelTrab, sOCR
						FROM bdinteg:si_cliente a
						INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
						LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
						LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
						LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte
						--AND f.fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE numcte = a.numcte)
						WHERE a.numcte=sNumCte AND f.folio=pFolio;

						
						SELECT FIRST 1 num_solicitud INTO sNumSolBanco
						FROM bdisolic:ss_solicitudes
						WHERE numcte=sNumCte
						AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

												
						SELECT FIRST 1 num_solicitud INTO sNumSolCoppel
						FROM bdisolic:ss_solicitudes
						WHERE numcte=sNumCte
						AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

						
						SELECT FIRST 1 num_solicitud INTO sNumSolPresPer
						FROM bdisolic:ss_solicitudes
						WHERE numcte=sNumCte
						AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

                    ELSE
						LET sTipoBusqueda='5';

						LET sNumCte=(SELECT FIRST 1 numcte FROM bdinteg:si_solicitud_movil WHERE ap_rfc=pRFC AND folio_procesado='0' AND status_valua='1'
						AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE ap_rfc=pRFC AND folio_procesado='0' AND status_valua='1'));

						
						SELECT FIRST 1 a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel, a.numcte, e.cod_postal, f.domicilio_actual, f.folio, a.rfc, d.carrier, f.empresa, f.tel_trabajo, f.ocr
						INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sCarrier, sEmpresa, sTelTrab, sOCR
						FROM bdinteg:si_cliente a
						INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
						LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
						LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
						LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte
						--AND f.fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE numcte = a.numcte)
						WHERE a.numcte=sNumCte AND f.folio=pFolio;

						
						SELECT FIRST 1 num_solicitud INTO sNumSolBanco
						FROM bdisolic:ss_solicitudes
						WHERE numcte=sNumCte
						AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

						
						SELECT FIRST 1 num_solicitud INTO sNumSolCoppel
						FROM bdisolic:ss_solicitudes
						WHERE numcte=sNumCte
						AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

						
						SELECT FIRST 1 num_solicitud INTO sNumSolPresPer
						FROM bdisolic:ss_solicitudes
						WHERE numcte=sNumCte
						AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');
                    END IF;
                    --SI EL RFC NO COINCIDE, SE VALIDA EL OCR
                ELIF (iExistsC > 0 ) THEN
					LET iExists = 0;
					LET pFolio=(select
					{+INDEX (bdinteg:"informix".si_solicitud_movil idx_ocr)}
					FIRST 1 folio from bdinteg:si_solicitud_movil WHERE numcte = sNumCte and ocr <> '' and ocr matches pOCRconsulta AND folio_procesado='0' 
					AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE numcte = sNumCte and ocr <> '' and ocr matches pOCRconsulta AND folio_procesado='0'));

					LET sTipoBusqueda='6';
					LET sEnviaSMS='1';

					LET sNumCte=(SELECT FIRST 1 numcte FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0'
					AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0'));
                            --***********************NUEVOS CAMBIOS
					SELECT FIRST 1 num_tdc_coppel, num_tdc_bcoppel, num_prestamo INTO sRevTdcCopp, sRevTdcBanc, sRevNumPP
					from bdinteg:si_solicitud_movil where numcte=sNumCte AND folio=pFolio
					AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil where numcte=sNumCte AND folio=pFolio);

					IF (NVL(sRevTdcCopp,'0'))<>'0' then
						LET iRevConta=iRevConta+1; 

						select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcCopp and status_solicitud='CN';
						IF (iExists > 0) THEN
						LET iExists = 0;
						LET iRevContaCN=iRevContaCN+1;      
						END IF;
					END IF;

					IF (NVL(sRevTdcBanc,'0'))<>'0' then
						LET iRevConta=iRevConta+1;

						select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcBanc and status_solicitud='CN';
						IF (iExists > 0) THEN
						LET iExists = 0;
						LET iRevContaCN=iRevContaCN+1;      
						END IF;      
					END IF;

					IF (NVL(sRevNumPP,'0'))<>'0' then
						LET iRevConta=iRevConta+1;      

						select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevNumPP and status_solicitud='CN';
						IF (iExists > 0) THEN
							LET iExists = 0;
							LET iRevContaCN=iRevContaCN+1;      
						END IF;      
					END IF;

					IF iRevConta=iRevContaCN THEN
						UPDATE {+INDEX (bdinteg:"informix".si_solicitud_movil idx_ct)} bdinteg:si_solicitud_movil set folio_procesado='1' where numcte=sNumCte and folio = pFolio;

						LET sTipoBusqueda=0;

						--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
						LET sOCRMin = LOWER(sOCR);
						LET sOCRMay = UPPER(sOCR);
						
						IF(sOCRMin != sOCRMay) THEN
							LET sOCR = '';
						END IF;
						--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
						
						RETURN sCodRet, sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac,
							   sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct,
							   sNumSolBanco, sNumSolCoppel, sNumSolPresPer, sFolioMovil, sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
					END IF;
                        --***********************NUEVOS CAMBIOS
											
					SELECT FIRST 1 a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel, a.numcte, e.cod_postal, f.domicilio_actual, f.folio, a.rfc, d.carrier, f.empresa, f.tel_trabajo, f.ocr
					INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sCarrier, sEmpresa, sTelTrab, sOCR
					FROM bdinteg:si_cliente a
					INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
					LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
					LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
					LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte
					--AND f.fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE numcte = a.numcte)
					WHERE a.numcte=sNumCte AND f.folio=pFolio;

					
					SELECT FIRST 1 num_solicitud INTO sNumSolBanco
					FROM bdisolic:ss_solicitudes
					WHERE numcte=sNumCte
					AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

					
					SELECT FIRST 1 num_solicitud INTO sNumSolCoppel
					FROM bdisolic:ss_solicitudes
					WHERE numcte=sNumCte
					AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

					
					SELECT FIRST 1 num_solicitud INTO sNumSolPresPer
					FROM bdisolic:ss_solicitudes
					WHERE numcte=sNumCte
					AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

                END IF;
            END IF;
            --BUSCANDO POR RFC INCORRECTO y FOLIO INCORRECTO. SE BUSCA POR OCR
        ELIF (iExistsD > 0) THEN
			LET iExists = 0;
			LET pFolio=(SELECT 
						{+INDEX (bdinteg:"informix".si_solicitud_movil idx_ocr)}
						FIRST 1 folio 
						from bdinteg:si_solicitud_movil WHERE numcte = sNumCte and ocr <> '' and ocr matches pOCRconsulta AND folio_procesado='0' AND status_valua='1'  
						AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE  numcte = sNumCte and ocr <> '' and ocr matches pOCRconsulta AND folio_procesado='0' AND status_valua='1'));

			--SI EL OCR QUE SE ENVIA DESDE ALTA UNICA COINCIDE CON EL OCR DE LA SOLICITUD MOVIL, SE ENVIARA SMS
			--EN CASO CONTRARIO SE CANCELARA PORQUE COINCIDE FOLIO PERO NO LA PERSONA.
			--IF pOCR=sOCRMOVIL THEN

			LET sTipoBusqueda='7';
			LET sEnviaSMS='1';

			LET sNumCte=(SELECT FIRST 1 numcte FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'
			AND fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0' AND status_valua='1'));
			--***********************NUEVOS CAMBIOS
			SELECT num_tdc_coppel, num_tdc_bcoppel, num_prestamo INTO sRevTdcCopp, sRevTdcBanc, sRevNumPP
			from bdinteg:si_solicitud_movil where numcte=sNumCte AND folio=pFolio
			and fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil where numcte=sNumCte AND folio=pFolio);

			IF (NVL(sRevTdcCopp,'0'))<>'0' then
				LET iRevConta=iRevConta+1; 

				select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcCopp and status_solicitud='CN';
				IF (iExists > 0) THEN
					LET iExists = 0;
					LET iRevContaCN=iRevContaCN+1;      
				END IF;
			END IF;

			IF (NVL(sRevTdcBanc,'0'))<>'0' then
				  LET iRevConta=iRevConta+1;

				  select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevTdcBanc and status_solicitud='CN';
				  IF (iExists > 0) THEN
					 LET iExists = 0;
					 LET iRevContaCN=iRevContaCN+1;      
				  END IF;      
			END IF;

			IF (NVL(sRevNumPP,'0'))<>'0' then
				  LET iRevConta=iRevConta+1;      

				  select count(*) into iExists from bdisolic:ss_solicitudes where numcte=sNumCte and num_solicitud=sRevNumPP and status_solicitud='CN';
				  IF (iExists > 0) THEN
					 LET iExists = 0;
					 LET iRevContaCN=iRevContaCN+1;      
				  END IF;      
			END IF;

			IF iRevConta=iRevContaCN THEN
				UPDATE {+INDEX (bdinteg:"informix".si_solicitud_movil idx_ct)} bdinteg:si_solicitud_movil set folio_procesado='1' where numcte=sNumCte and folio = pFolio;

				LET sTipoBusqueda=0;

				--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
			    LET sOCRMin = LOWER(sOCR);
				LET sOCRMay = UPPER(sOCR);
				
				IF(sOCRMin != sOCRMay) THEN
					LET sOCR = '';
				END IF;
				--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
				
				RETURN sCodRet, sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac,
					   sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct,
					   sNumSolBanco, sNumSolCoppel, sNumSolPresPer, sFolioMovil, sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
			END IF;
                        --***********************NUEVOS CAMBIOS
									
			SELECT FIRST 1 a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel, a.numcte, e.cod_postal, f.domicilio_actual, f.folio, a.rfc, d.carrier, f.empresa, f.tel_trabajo, f.ocr
			INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sCarrier, sEmpresa, sTelTrab, sOCR
			FROM bdinteg:si_cliente a
			INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
			LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
			LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
			LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte
			--AND f.fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:si_solicitud_movil WHERE numcte = a.numcte)
			WHERE a.numcte=sNumCte AND f.folio=pFolio;

			
			SELECT FIRST 1 num_solicitud INTO sNumSolBanco
			FROM bdisolic:ss_solicitudes
			WHERE numcte=sNumCte
			AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

			
			SELECT FIRST 1 num_solicitud INTO sNumSolCoppel
			FROM bdisolic:ss_solicitudes
			WHERE numcte=sNumCte
			AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

			
			SELECT FIRST 1 num_solicitud INTO sNumSolPresPer
			FROM bdisolic:ss_solicitudes
			WHERE numcte=sNumCte
			AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT','PC', 'AT', 'AP');

        END IF;

		--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
	    LET sOCRMin = LOWER(sOCR);
		LET sOCRMay = UPPER(sOCR);
				
		IF(sOCRMin != sOCRMay) THEN
			LET sOCR = '';
		END IF;
		--****VALIDAR SI OCR CONTIENE CARACTERES EN LUGAR DE NUMEROS***--
		
        RETURN sCodRet, NVL(sRFC,''), NVL(sPaterno,''), NVL(sMaterno,''), NVL(sNombre1,''), NVL(sNombre2,''), sFecha_Nac,
               NVL(sTelefono,''), NVL(sCteCoppel,''), NVL(sNumCteCoppel,''), NVL(sNumCteMovil,''), NVL(sCodPos,''), NVL(sDomicAct,'0'),
               NVL(sNumSolBanco,''), NVL(sNumSolCoppel,''), NVL(sNumSolPresPer,''), NVL(sFolioMovil,''), sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
END;
END PROCEDURE
