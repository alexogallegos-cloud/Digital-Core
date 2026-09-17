CREATE PROCEDURE "informix".sp_sac_valida_ctesremesas(pNumCte CHAR(20), pNombre1 CHAR(26), pNombre2 CHAR(26), pApell_paterno CHAR(26), pApell_materno CHAR(26), pFecha_nac CHAR(20), pNumIdentificacion CHAR(30))
RETURNING  
            CHAR(5) AS cCodRet,
            CHAR(20) AS cNumcte,
            CHAR(1) AS iTipoCliente,
            CHAR(5) AS cValIne,
            CHAR(5) AS cListaNegra,
            CHAR(5) AS cSespecial,
            CHAR(13) AS cRfc;

            DEFINE cCodRet CHAR(5);
            DEFINE cNumcte CHAR(20);
            DEFINE iTipoCliente CHAR(1);
            DEFINE cValIne CHAR(5);
            DEFINE cResultINE CHAR(50);
            DEFINE cListaNegra CHAR(5);
            DEFINE cSespecial CHAR(5);
            DEFINE cStatuscte CHAR(1);
            DEFINE cRfc CHAR(13);
            DEFINE cCodRetRfc CHAR(5);

            DEFINE iSqlErr INTEGER;
            DEFINE iIsamErr INTEGER;
            DEFINE cInfoErr CHAR(10);

            DEFINE icontEsp INTEGER;
            DEFINE iContList INTEGER;

            DEFINE cSituacion CHAR(5);
            DEFINE cCausa CHAR(5);
            DEFINE iContListRfc INTEGER;
            DEFINE cRfcCte CHAR(13);
            DEFINE pNombre3 CHAR(40);

            LET cCodRet = "00000";
            LET cNumcte = "";
            LET iTipoCliente = "";
            LET cValIne = "";
            LET cListaNegra = "";
            LET cSespecial = "";
            LET cStatuscte = "";
            LET cRfc = "";

            LET icontEsp = 0;
            LET iContList = 0;

            LET pNumIdentificacion = TRIM(pNumIdentificacion);

            LET cSituacion = '';
            LET cCausa = '';
            LET cRfc = '';
            LET iContListRfc = 0;
            LET cRfcCte = "";
            LET pNombre3 = "";

          --SET DEBUG FILE TO '/informix/ENP/spHuellas/out/sp_sac_valida_ctesremesas.out';
          --TRACE ON;

BEGIN 
            ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr::CHAR(5);
                    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                END IF;
	        END EXCEPTION;	

            SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;
          ----------------------------BUSEQUEDA POR NUM CTE-----------------------------------
        IF  NVL(pNombre1, "") = ""AND NVL(pNombre2, "") = ""AND NVL(pApell_paterno, "") = ""AND NVL(pApell_materno, "") = ""AND NVL(pFecha_nac::DATE, "") = "" and NVL(pNumIdentificacion, "") = ""  THEN

            SELECT cterem.numcte,"1",cterem.status_cte,cte.rfc INTO cNumcte,iTipoCliente,cStatuscte,cRfc
            FROM bdinteg :"informix".si_cliente cte
                INNER JOIN bdinteg :"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
                INNER JOIN bdisac :"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
            WHERE cte.numcte = pNumCte;
                
                IF NVL(cNumcte, "") = "" THEN
                    SELECT cte.numcte,"2",cte.rfc INTO cNumcte,iTipoCliente,cRfc
                    FROM bdinteg :"informix".si_cliente cte
                    INNER JOIN bdinteg :"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte
                    WHERE cte.numcte = pNumCte
                    AND cte.tipo_cliente in("1", "2");
                            
                    IF NVL(cNumcte, "") = "" THEN LET cNumcte = "000000000";
                        LET iTipoCliente = "3";
                        RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                    END IF;
                        ELSE IF TRIM(cStatuscte) <> "A" THEN LET cCodRet = "00003";
                            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                        END IF;
                END IF;
                    ----------------------------BUSEQUEDA POR NUM DE IDENTIFICACION----------------------------
                        ELSE 
                            IF NVL(pNumCte, "") = ""AND NVL(pNombre1, "") = ""AND NVL(pNombre2, "") = ""AND NVL(pApell_paterno, "") = ""AND NVL(pApell_materno, "") = "" AND NVL(pFecha_nac::DATE, "") = "" THEN
                                SELECT cterem.numcte,"1",cterem.status_cte,cte.rfc INTO cNumcte,iTipoCliente,cStatuscte,cRfc
                                FROM bdinteg :"informix".si_cliente cte
                                INNER JOIN bdinteg :"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
                                INNER JOIN bdisac :"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
                                WHERE ctepf.numidentifi = pNumIdentificacion;

                                IF NVL(cNumcte, "") = "" THEN
                                    SELECT cte.numcte,"2",cte.rfc INTO cNumcte,iTipoCliente,cRfc
                                    FROM bdinteg :"informix".si_cliente cte
                                    INNER JOIN bdinteg :"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte
                                    WHERE ctepf.numidentifi = pNumIdentificacion
                                    AND cte.tipo_cliente in("1", "2");

                                    IF NVL(cNumcte, "") = "" THEN LET cNumcte = "000000000";
                                        LET iTipoCliente = "3";
                                        RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                    END IF;
                                        ELSE IF TRIM(cStatuscte) <> "A" THEN LET cCodRet = "00003";
                                            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                END IF;
                            END IF;
                            -----------------------------------BUSEQUEDA POR NUM nombre y fecha de nacimiento-----------------------------------
                                ELSE 
                                    IF  NVL(pNumCte, "") = "" AND NVL(pNumIdentificacion, "") = "" THEN 
                                        LET pNombre3 = TRIM(pNombre1)||' '||TRIM(pNombre2);
                                        LET pNombre1 = TRIM(pNombre1);
                                        LET pNombre2 = TRIM(pNombre2);
                                        LET pApell_paterno = TRIM(pApell_paterno);
                                        LET pApell_materno = TRIM(pApell_materno);	
                                        EXECUTE PROCEDURE bdinteg:sp_calcularrfc(pApell_paterno,pApell_materno,pNombre3,pFecha_nac::DATE) INTO cCodRetRfc, cRfc;
                                        IF NVL(cCodRetRfc,'') <> '00000' THEN
                                            LET cCodRet = cCodRetRfc;
                                        END IF;
                                        
                                        SELECT     cterem.numcte, "1", cterem.status_cte
                                        INTO       cNumcte, iTipoCliente, cStatuscte
                                            FROM       bdinteg:"informix".si_cliente cte 
                                        INNER JOIN bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
                                        INNER JOIN bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
                                            WHERE      	ctepf.fecha_nac = pFecha_nac::DATE 
                                        AND		   TRIM(cte.Nombre1)=  TRIM(pNombre1)
                                        AND        TRIM(cte.Nombre2) =  TRIM(pNombre2)
                                        AND        TRIM(cte.apell_paterno) =  TRIM(pApell_paterno)
                                        AND        TRIM(cte.apell_materno) =  TRIM(pApell_materno)
                                        OR         cte.rfc = cRfc ;

                                            IF NVL(cNumcte,"") = "" THEN
                                                SELECT      cte.numcte, "2"
                                                INTO        cNumcte, iTipoCliente
                                                FROM        bdinteg:"informix".si_cliente cte 
                                                INNER JOIN  bdinteg:"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte 
                                                WHERE      	ctepf.fecha_nac = pFecha_nac::DATE 
                                                AND			TRIM(cte.Nombre1)=  TRIM(pNombre1)
                                                AND         TRIM(cte.Nombre2) =  TRIM(pNombre2)
                                                AND        	TRIM(cte.apell_paterno) =  TRIM(pApell_paterno)
                                                AND        	TRIM(cte.apell_materno) =  TRIM(pApell_materno)
                                                OR          cte.rfc = cRfc  
                                                AND         cte.tipo_cliente in("1","2");

                                                IF NVL(cNumcte,"") = "" THEN
                                                    LET cNumcte = "000000000";
                                                    LET iTipoCliente = "3";
                                                    SELECT COUNT(*) INTO iContListRfc FROM bdiauditor:"informix".tbl_listainterna  WHERE rfc = cRfc;
                                                    LET iContList = iContList + iContListRfc;
                                                    IF iContList > 0 THEN
                                                        LET cListaNegra = "True";
                                                        LET iTipoCliente = "2";
                                                        LET cNumcte = "000000001";
                                                    END IF;
                                                    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                                END IF;

                                            ELSE
                                                IF TRIM(cStatuscte) <> "A" THEN
                                                    LET cCodRet = "00003";
                                                    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                                END IF;
                                END IF;
                         END IF;
                END IF;
        END IF;
                -----------------------------------Validacion de INE -----------------------------------
                    SELECT resultado INTO cResultINE
                    FROM bdinteg :"informix".si_bitacora_ife
                    WHERE numcte = cNumcte
                    AND fecha = (SELECT MAX(fecha)FROM bdinteg :"informix".si_bitacora_ife WHERE numcte = cNumcte);
                    IF ((TRIM(NVL(cResultINE, "")) = "") AND (iTipoCliente = 1 OR iTipoCliente = 2))
                        OR (UPPER(TRIM(cResultINE)) = "VERDADERO")
                        OR (UPPER(TRIM(cResultINE)) = "TRUE") THEN LET cValIne = "True";
                        ELIF (TRIM(NVL(cResultINE, "")) = "") AND iTipoCliente = 3 THEN 
                        LET cValIne = "";
                            ELIF (UPPER(TRIM(cResultINE)) = "FALSO")
                            OR (UPPER(TRIM(cResultINE)) = "FALSE") THEN LET cValIne = "False";
                    END IF;
                    ----------------------------------Validacion LISTA NEGRA  -----------------------------------
                        SELECT COUNT(*) INTO iContList
                        FROM bdiauditor :"informix".tbl_listainterna
                        WHERE numcte = cNumCte;

                        SELECT COUNT(*) INTO iContListRfc
                        FROM bdiauditor :"informix".tbl_listainterna
                        WHERE rfc = cRfc;
                        LET iContList = iContList + iContListRfc;

                        IF iContList > 0 THEN LET cListaNegra = "True";
                            ELSE LET cListaNegra = "False";
                        END IF;
                        -----------------------------------Validacion SITUACION ESPECIAL -----------------------------------
                            SELECT COUNT(*) INTO icontEsp
                            FROM bdisitesp :"informix".se_ctessitespcte
                            where numcte = cNumCte;

                            IF icontEsp > 0 THEN
                                SELECT situacion,causa INTO cSituacion,cCausa
                                FROM bdisitesp :"informix".se_ctessitespcte
                                where numcte = cNumCte;
                                LET cSituacion = TRIM(cSituacion) || TRIM(cCausa);

                                IF cSituacion IN ('F42', 'P72', 'P108', 'U60') THEN LET cSespecial = "True";
                                    ELSE LET cSespecial = "False";
                                END IF;
        
                                ELSE LET cSespecial = "False";
                            END IF;
                            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Valida datos cliente (INE, Lista negra y Situacion especial) por numero de clietne , numero de identificacion o nombre ',
'AUTOR: Edgar Navarro',
'SUSTENTO: RQM 10 1534 Envio de remesas outbound',
'FECHA DE MOFICACION: 01/08/2022',
'SOLICITA: LEONARDO HERNANDEZ',
'BD: BDISAC',
'------------------------------------------------------------------------------------------------------------------------',
'FOLIO: 433',
'DESCRIPCION: Actualiza informacion de usuario de remesas',
'AUTOR: MARCO RIVERA',
'SUSTENTO: 433 REQ. Base de datos para el alta de usuarios de remesas',
'FECHA DE CREACION: 21/08/2018',
'SOLICITA: LEONARDO HERNANDEZ',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_valida_ctehuella_comp(pNumCte CHAR(20))
    --DATOS A REGRESAR---
    RETURNING CHAR(5),CHAR(942),CHAR(942);
    
    --DEFINICION DE VARIABLES--
    DEFINE iSql_err INTEGER;
    DEFINE cCodRet  CHAR(5);
    DEFINE cHuellaD CHAR(942);
    DEFINE cHuellaI CHAR(942);
   	DEFINE existe INTEGER;
    
    --SET DEBUG FILE TO "/informix/jfponce/gabriel/err/sp_generahuellalinea.out";
    --TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET iSql_err = 0;
    LET cCodRet  = '00000';
    LET cHuellaD = "";
    LET cHuellaI = "";
   	let existe = 0;

BEGIN
    ON EXCEPTION SET iSql_err
        IF iSql_err    <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet, cHuellaD,cHuellaI;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT 1, dmapa, imapa
    INTO existe, cHuellaD, cHuellaI
    FROM bdinteg:"informix".si_cte_huella
    WHERE numcte = pNumcte AND estado ="A";

    IF existe IS NULL THEN
        LET cCodRet="00001";
        RETURN cCodRet, TRIM(cHuellaD),TRIM(cHuellaI);
    END IF;
   
    RETURN cCodRet, TRIM(cHuellaD),TRIM(cHuellaI);
END;
END PROCEDURE;