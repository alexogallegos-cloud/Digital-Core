CREATE PROCEDURE "informix".sp_validarfc_dos()
    RETURNING CHAR(5) AS codret;

DEFINE cCodRet      CHAR(5);
DEFINE iSqlErr	    INTEGER;
DEFINE cNumcte      CHAR(9);
DEFINE cApell_Pat   CHAR(25);
DEFINE cApell_Mat   CHAR(25);
DEFINE cNombre      CHAR(55);
DEFINE cFecNac      CHAR(10);
DEFINE cRFCOrig     CHAR(15);
DEFINE cRFCNuevo    CHAR(15);
DEFINE cComp        CHAR(10);
DEFINE iNumRows     INTEGER;
DEFINE iTotDupRec   INTEGER;
DEFINE cCteDupRec   CHAR(15);
DEFINE cCadRFCDup   CHAR(90);
DEFINE vNumCteIni   CHAR(9);


LET cCodRet      ='00000';
LET iSqlErr		 =0;
LET cNumcte      ='';
LET cApell_Pat   ='';
LET cApell_Mat   ='';
LET cNombre      ='';
LET cFecNac      ='';
LET cRFCOrig     ='';
LET cRFCNuevo    ='';
LET cComp        ='';
LET iNumRows     =0;
LET iTotDupRec   =0;
LET cCteDupRec   ='';
LET cCadRFCDup   ='';
LET vNumCteIni   ='';


BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE si_param SET valor=cNumcte WHERE cod_param='316';
			RETURN cCodRet;
		END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/sp_calcularrfcout.sql';
		--TRACE ON;
        
        SELECT valor into vNumCteIni from si_param where cod_param='316';

        set isolation to dirty read;
        FOREACH  
                SELECT a.numcte, trim(apell_paterno), trim(apell_materno), trim(nombre1)||' '||trim(nombre2), fecha_nac, rfc
                INTO cNumcte, cApell_Pat, cApell_Mat, cNombre, cFecNac, cRFCOrig
                    FROM bdinteg:si_cliente a
                        INNER JOIN bdinteg:si_ctepf b
                            ON a.numcte=b.numcte
                    WHERE a.empresa='001' and length(a.apell_paterno)>2
						AND a.tpo_persona='01'
                        AND a.numcte>=vNumCteIni
                    ORDER BY a.numcte
                        
             LET cComp='';
             LET cCteDupRec='';
             LET cCadRFCDup='';
             LET iTotDupRec=0;

             EXECUTE PROCEDURE bdinteg:"informix".sp_calcularrfc(cApell_Pat, cApell_Mat, cNombre, cFecNac)
                INTO cCodRet, cRFCNuevo;
    
                if ccodret<>'00000' then
                    --SI EL SP QUE CALCULA EL RFC REGRESA UN ERROR SE CONTINUA CON EL SIGUIENTE REGISTRO
                    CONTINUE FOREACH;
                end if;

            IF TRIM(cRFCOrig)=TRIM(cRFCNuevo) THEN
                --Si el RFC Calculado es igual al que tiene el cliente actualmente, se continua con el ciclo
                CONTINUE FOREACH;
            ELSE
                LET cComp='FALLO';
                
                --SE COMPARA EL RFC RECALCULADO ENTRE TODA LA TABLA DE RECALCULADOS 
                SELECT count(*) INTO iTotDupRec FROM bdinteg:resultadosrfc WHERE rfc_calculado=cRFCNuevo;
                LET iNumRows = dbinfo("sqlca.sqlerrd2");
                IF iNumRows > 0 AND iTotDupRec> 0 THEN
                --SE ENCONTRARON REGISTROS CON EL MISMO RFC
                    LET cCadRFCDup='';
                    ---ALMACENAR EN LA BITACORA DE RFCS CALCULADOS
                    IF iTotDupRec=1 THEN
                        SELECT numcte INTO cCteDupRec FROM bdinteg:resultadosrfc WHERE rfc_calculado=cRFCNuevo;
                    ELSE
                        FOREACH SELECT numcte INTO cCteDupRec FROM bdinteg:resultadosrfc WHERE rfc_calculado=cRFCNuevo
                            LET cCadRFCDup=TRIM(cCadRFCDup)||'|'||TRIM(cCteDupRec);
                        END FOREACH;
                    END IF;
                    LET cCadRFCDup=TRIM(cCadRFCDup)||'|      TABLA DE RECALCULO';
                    INSERT INTO bdinteg:resultadosrfc (numcte, rfc_original, rfc_calculado, resultado, numcte2, cantidad, numcte_cadena, procesado, fecha)
                        VALUES(cNumcte, cRFCOrig, cRFCNuevo, cComp, cCteDupRec, iTotDupRec, cCadRFCDup, '1', '10/28/2014');
                ELSE
                --NO SE ENCONTRARON REGISTROS CON EL MISMO RFC EN RECALCULADOS, SE BUSCA EN si_cliente
                    SELECT count(*) INTO iTotDupRec FROM bdinteg:si_cliente WHERE rfc=cRFCNuevo;
                    LET iNumRows = dbinfo("sqlca.sqlerrd2");
                    IF iNumRows>0 AND iTotDupRec>0 THEN
                    --SE ENCONTRARON REGISTROS DUPLICADOS EN si_cliente
                        IF iTotDupRec=1 THEN
                           SELECT numcte INTO cCteDupRec FROM bdinteg:si_cliente WHERE rfc=cRFCNuevo; 
                        ELSE
                            FOREACH SELECT numcte INTO cCteDupRec FROM bdinteg:si_cliente WHERE rfc=cRFCNuevo
                                LET cCadRFCDup=TRIM(cCadRFCDup)||'|'||TRIM(cCteDupRec);
                            END FOREACH;
                        END IF;

                        INSERT INTO bdinteg:resultadosrfc (numcte, rfc_original, rfc_calculado, resultado, numcte2, cantidad, numcte_cadena, procesado, fecha)
                        VALUES(cNumcte, cRFCOrig, cRFCNuevo, cComp, cCteDupRec, iTotDupRec, cCadRFCDup, '1', '10/28/2014');
                    ELSE--CUANDO NO SE ENCUENTREN EN LA TABLA DE RECALCULADOS NI EN LA SI_CLIENTES
                        INSERT INTO bdinteg:resultadosrfc (numcte, rfc_original, rfc_calculado, resultado, numcte2, cantidad, numcte_cadena, procesado, fecha)
                        VALUES(cNumcte, cRFCOrig, cRFCNuevo, cComp, cCteDupRec, iTotDupRec, cCadRFCDup, '1', '10/28/2014');
                    END IF;
                END IF;
                

            END IF;
            
        END FOREACH;
		RETURN cCodRet;
	END;
			
END PROCEDURE;