CREATE PROCEDURE "informix".sp_cons_folio_movil_pba(pRFC CHAR(13), pfolio CHAR(12), pOCR CHAR(9))
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





BEGIN
	ON EXCEPTION SET iSqlErr

	IF iSqlErr <> 0 THEN
		RETURN iSqlErr, sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac,
                       sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct,
                       sNumSolBanco, sNumSolCoppel, sNumSolPresPer, sFolioMovil, sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
        END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO '/tmp/anj/movil/sp_cons_folio_movil2.sql';
-- TRACE ON;

--SI EL CAMPO OCR VIENE EN BLANCO, SE RETORNA UN VALOR DE 8
IF pOCR='' THEN
    LET sTipoBusqueda='5';
    RETURN sCodRet, NVL(sRFC,''), NVL(sPaterno,''), NVL(sMaterno,''), NVL(sNombre1,''), NVL(sNombre2,''), sFecha_Nac,
                   NVL(sTelefono,''), NVL(sCteCoppel,''), NVL(sNumCteCoppel,''), NVL(sNumCteMovil,''), NVL(sCodPos,''), NVL(sDomicAct,'0'),
                   NVL(sNumSolBanco,''), NVL(sNumSolCoppel,''), NVL(sNumSolPresPer,''), NVL(sFolioMovil,''), sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
END IF;

        --BUSCANDO POR RFC y FOLIO
        IF EXISTS(SELECT * FROM bdinteg:si_solicitud_movil WHERE folio=pfolio AND rfc=pRFC AND folio_procesado='0') THEN

            LET sTipoBusqueda='1';

            SELECT numcte INTO sNumCte FROM bdinteg:si_cliente WHERE rfc=pRFC;


            SELECT a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel, a.numcte,
                   e.cod_postal, f.domicilio_actual, f.folio, f.rfc, f.empresa, f.tel_trabajo, f.ocr
               INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil,
                    sCodPos, sDomicAct, sFolioMovil, sRFC, sEmpresa, sTelTrab, sOCR
            FROM bdinteg:si_cliente a
            INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
            LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
            LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
            LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte
            WHERE a.numcte=sNumCte;

                SELECT num_solicitud INTO sNumSolBanco
                FROM bdisolic:ss_solicitudes
                WHERE numcte=sNumCte
                AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                SELECT num_solicitud INTO sNumSolCoppel
                FROM bdisolic:ss_solicitudes
                WHERE numcte=sNumCte
                AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                SELECT num_solicitud INTO sNumSolPresPer
                FROM bdisolic:ss_solicitudes
                WHERE numcte=sNumCte
                AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

          --BUSCANDO POR RFC CORRECTO y FOLIO INCORRECTO
          ELIF EXISTS(SELECT numcte FROM bdinteg:si_solicitud_movil WHERE rfc=pRFC AND folio_procesado='0') THEN
                LET sTipoBusqueda='2';

                --SE MANDA A BUSCAR EL NUM DE CTE CON EL RFC ENCONTRADO
                SELECT numcte INTO sNumCte FROM bdinteg:si_cliente WHERE rfc=pRFC;
                --SE MANDA A CONSULTAR SI EXISTE UNA SOLICITUD MOVIL CON EL NUM DE CTE
                IF EXISTS(SELECT * FROM bdinteg:si_solicitud_movil WHERE numcte=sNumCte AND folio_procesado='0') THEN
                    SELECT a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel,
                           a.numcte, e.cod_postal, f.domicilio_actual, f.folio, f.rfc, f.empresa, f.tel_trabajo, f.ocr
                       INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel,
                            sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sEmpresa, sTelTrab, sOCR
                        FROM bdinteg:si_cliente a
                         INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
                          LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
                           LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
                            LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte AND f.folio_procesado='0'
                        WHERE a.numcte=sNumCte;

                        SELECT num_solicitud INTO sNumSolBanco
                        FROM bdisolic:ss_solicitudes
                        WHERE numcte=sNumCte
                        AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                        SELECT num_solicitud INTO sNumSolCoppel
                        FROM bdisolic:ss_solicitudes
                        WHERE numcte=sNumCte
                        AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                        SELECT num_solicitud INTO sNumSolPresPer
                        FROM bdisolic:ss_solicitudes
                        WHERE numcte=sNumCte
                        AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');
                  END IF;

            --BUSCANDO POR FOLIO CORRECTO y RFC INCORRECTO RUTINA BTS
            ELIF EXISTS(SELECT * FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0') THEN

                --EXTRAYENDO EL NUMERO DE CLIENTE y DATOS GENERALES DE LA TABLA DE SOLICITUDES_MOVIL
                SELECT numcte, apell_paterno, apell_materno, nombre1, nombre2
                  INTO sNumCte, sApPatA, sApMatA, sNom1A, sNom2A
                    FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0';

                LET sFecNacA=(SELECT SUBSTRING(fecha_nac FROM 4 FOR 2)||'/'||SUBSTRING(fecha_nac FROM 1 FOR 2)||'/'||SUBSTRING(fecha_nac FROM 7 FOR 4)
                             FROM bdinteg:si_solicitud_movil WHERE folio=pFolio);

                --EXTRAYENDO LOS DATOS DEL CLIENTE A COMPARAR DE ACUERDO AL NUMCTE OBTENIDO DE LA TABLA SOLICITUDES_MOVIL
                SELECT apell_paterno, apell_materno, nombre1, nombre2, fecha_nac
                  INTO sApPatB, sApMatB, sNom1B, sNom2B, sFecNacB
                    FROM bdinteg:si_cliente cte INNER JOIN bdinteg:si_ctepf ctepf ON cte.numcte=ctepf.numcte
                       WHERE cte.rfc=pRFC;

                --EJECUTANDO RUTINA DE COMPARACION
                EXECUTE PROCEDURE bdinteg:sp_validanombrefn(sNom1A, sNom2A, sApPatA, sApMatA, sFecNacA, sNom1B,  sNom2B, sApPatB, sApMatB, sFecNacB, 0)
                    INTO sErrProc, dPorcentaje;

                SELECT valor INTO dParamPorc FROM bdinteg:si_param WHERE cod_param='337';

                --SI LA COMPARACION ES IGUAL O MAYOR AL RANGO OBTENIDO DEVUELVE LA INFORMACION
                IF dPorcentaje>=dParamPorc THEN
                    LET sTipoBusqueda='3';

                    SELECT a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel,
                           a.numcte, e.cod_postal, f.domicilio_actual, f.folio, f.rfc, f.empresa, f.tel_trabajo, f.ocr
                       INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel,
                            sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sEmpresa, sTelTrab, sOCR
                        FROM bdinteg:si_cliente a
                         INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
                          LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
                           LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
                            LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte AND f.folio_procesado='0'
                        WHERE a.numcte=sNumCte;

                        SELECT num_solicitud INTO sNumSolBanco
                        FROM bdisolic:ss_solicitudes
                        WHERE numcte=sNumCte
                        AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                        SELECT num_solicitud INTO sNumSolCoppel
                        FROM bdisolic:ss_solicitudes
                        WHERE numcte=sNumCte
                        AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                        SELECT num_solicitud INTO sNumSolPresPer
                        FROM bdisolic:ss_solicitudes
                        WHERE numcte=sNumCte
                        AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');
                ELSE
                    --PORCENTAJE DE RFC ES MENOR A 90%
                    LET sRFCCortoA= (select SUBSTRING(pRFC FROM 1 FOR 10) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0');
                    LET sRFCCortoB= (select SUBSTRING(RFC FROM 1 FOR 10) FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0');


                    IF sRFCCortoA=sRFCCortoB THEN
                        --RFC A 10 POSICIONES ES IGUAL
                        LET sOCRMovil=(select SUBSTRING(ocr FROM 5 FOR 9) from bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0');

                        --SI EL OCR QUE SE ENVIA DESDE ALTA UNICA COINCIDE CON EL OCR DE LA SOLICITUD MOVIL, SE ENVIARA SMS
                        --EN CASO CONTRARIO SE CANCELARA PORQUE COINCIDE FOLIO PERO NO LA PERSONA.
                        IF pOCR=sOCRMOVIL THEN

                            LET sTipoBusqueda='4';
                            LET sEnviaSMS='1';

                            /*SELECT apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, telefono, carrier, num_solicitud, cte_coppel, numcte_coppel, rfc, ocr
                              INTO sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCarrier, sFolioMovil, sCteCoppel, sNumCteCoppel, sRFC, sOCR
                                FROM bdinteg:si_solicitud_movil WHERE num_solicitud=pFolio;*/
                            LET sNumCte=(SELECT numcte FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0');

                            SELECT a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel, a.numcte, e.cod_postal, f.domicilio_actual, f.folio, f.rfc, d.carrier, f.empresa, f.tel_trabajo, f.ocr
                               INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sCarrier, sEmpresa, sTelTrab, sOCR
                                FROM bdinteg:si_cliente a
                                 INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
                                  LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
                                   LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
                                    LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte
                                WHERE a.numcte=sNumCte;

                            SELECT num_solicitud INTO sNumSolBanco
                            FROM bdisolic:ss_solicitudes
                            WHERE numcte=sNumCte
                            AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                            SELECT num_solicitud INTO sNumSolCoppel
                            FROM bdisolic:ss_solicitudes
                            WHERE numcte=sNumCte
                            AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                            SELECT num_solicitud INTO sNumSolPresPer
                            FROM bdisolic:ss_solicitudes
                            WHERE numcte=sNumCte
                            AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');


                        ELSE
                            LET sTipoBusqueda='5';
                        END IF;
                    --SI EL RFC NO COINCIDE, SE VALIDA EL OCR
                    ELIF EXISTS(SELECT * FROM bdinteg:si_solicitud_movil WHERE SUBSTRING(ocr FROM 5 FOR 9)=pOCR AND folio_procesado='0') THEN
                        LET pFolio=(select folio from bdinteg:si_solicitud_movil WHERE SUBSTRING(ocr FROM 5 FOR 9)=pOCR AND folio_procesado='0');

                         LET sTipoBusqueda='6';
                            LET sEnviaSMS='1';

                            /*SELECT apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, telefono, carrier, folio, cte_coppel, numcte_coppel, rfc, ocr, numcte
                              INTO sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCarrier, sFolioMovil, sCteCoppel, sNumCteCoppel, sRFC, sOCR, sNumCteMovil
                                FROM bdinteg:si_solicitud_movil WHERE folio=pFolio;*/

                            LET sNumCte=(SELECT numcte FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0');

                            SELECT a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel, a.numcte, e.cod_postal, f.domicilio_actual, f.folio, f.rfc, d.carrier, f.empresa, f.tel_trabajo, f.ocr
                               INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sCarrier, sEmpresa, sTelTrab, sOCR
                                FROM bdinteg:si_cliente a
                                 INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
                                  LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
                                   LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
                                    LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte
                                WHERE a.numcte=sNumCte;

                            SELECT num_solicitud INTO sNumSolBanco
                            FROM bdisolic:ss_solicitudes
                            WHERE numcte=sNumCte
                            AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                            SELECT num_solicitud INTO sNumSolCoppel
                            FROM bdisolic:ss_solicitudes
                            WHERE numcte=sNumCte
                            AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                            SELECT num_solicitud INTO sNumSolPresPer
                            FROM bdisolic:ss_solicitudes
                            WHERE numcte=sNumCte
                            AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                    END IF;
                END IF;
            --BUSCANDO POR RFC INCORRECTO y FOLIO INCORRECTO. SE BUSCA POR OCR
            ELIF EXISTS(SELECT * FROM bdinteg:si_solicitud_movil WHERE SUBSTRING(ocr FROM 5 FOR 9)=pOCR AND folio_procesado='0') THEN
                        LET pFolio=(select folio from bdinteg:si_solicitud_movil WHERE SUBSTRING(ocr FROM 5 FOR 9)=pOCR AND folio_procesado='0');

                        --SI EL OCR QUE SE ENVIA DESDE ALTA UNICA COINCIDE CON EL OCR DE LA SOLICITUD MOVIL, SE ENVIARA SMS
                        --EN CASO CONTRARIO SE CANCELARA PORQUE COINCIDE FOLIO PERO NO LA PERSONA.
                        --IF pOCR=sOCRMOVIL THEN

                            LET sTipoBusqueda='7';
                            LET sEnviaSMS='1';

                            LET sNumCte=(SELECT numcte FROM bdinteg:si_solicitud_movil WHERE folio=pFolio AND folio_procesado='0');

                            SELECT a.rfc, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, c.fecha_nac, d.telefono, f.cte_coppel, f.numcte_coppel, a.numcte, e.cod_postal, f.domicilio_actual, f.folio, f.rfc, d.carrier, f.empresa, f.tel_trabajo, f.ocr
                               INTO sRFC, sPaterno, sMaterno, sNombre1, sNombre2, sFecha_Nac, sTelefono, sCteCoppel, sNumCteCoppel, sNumCteMovil, sCodPos, sDomicAct, sFolioMovil, sRFC, sCarrier, sEmpresa, sTelTrab, sOCR
                                FROM bdinteg:si_cliente a
                                 INNER JOIN bdinteg:si_ctepf c ON a.numcte=c.numcte
                                  LEFT JOIN bdinteg:si_telefonos_actual d ON a.numcte=d.numcte AND d.status_tel='A' AND d.tipo_tel=2
                                   LEFT JOIN bdinteg:si_direcciones_actual e ON a.numcte=e.numcte AND e.tipo_dir='1'
                                    LEFT JOIN bdinteg:si_solicitud_movil f ON a.numcte=f.numcte
                                WHERE a.numcte=sNumCte;

                            SELECT num_solicitud INTO sNumSolBanco
                            FROM bdisolic:ss_solicitudes
                            WHERE numcte=sNumCte
                            AND num_producto='6001' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                            SELECT num_solicitud INTO sNumSolCoppel
                            FROM bdisolic:ss_solicitudes
                            WHERE numcte=sNumCte
                            AND num_producto='6500' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

                            SELECT num_solicitud INTO sNumSolPresPer
                            FROM bdisolic:ss_solicitudes
                            WHERE numcte=sNumCte
                            AND num_producto='6300' AND status_solicitud NOT IN ('CN','AN','CM','RP','RT');

        END IF;

        RETURN sCodRet, NVL(sRFC,''), NVL(sPaterno,''), NVL(sMaterno,''), NVL(sNombre1,''), NVL(sNombre2,''), sFecha_Nac,
               NVL(sTelefono,''), NVL(sCteCoppel,''), NVL(sNumCteCoppel,''), NVL(sNumCteMovil,''), NVL(sCodPos,''), NVL(sDomicAct,'0'),
               NVL(sNumSolBanco,''), NVL(sNumSolCoppel,''), NVL(sNumSolPresPer,''), NVL(sFolioMovil,''), sTipoBusqueda, sEnviaSMS, sCarrier, sOCR, sEmpresa, sTelTrab;
END
END PROCEDURE;