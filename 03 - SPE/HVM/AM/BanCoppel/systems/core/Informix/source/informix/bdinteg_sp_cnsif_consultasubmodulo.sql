CREATE PROCEDURE "informix".sp_cnsif_consultasubmodulo(cID_USUARIOC CHAR(8),cID_FUNCIONC CHAR(10))
    RETURNING CHAR(5),INTEGER,CHAR(20),CHAR(10);												
	DEFINE iexiste 			INT;
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSql_err 		INT;
	DEFINE cId_submodulo	INTEGER;
	DEFINE cD_submodulo		CHAR(20);
    DEFINE cIdModulo        CHAR(10);
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET	cId_submodulo ="00";
	LET cD_submodulo = "00";
    LET cIdModulo='MOD000';
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cId_submodulo,cD_submodulo,cIdModulo;
            END IF;
        END EXCEPTION;
		/*SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultasubmodulo.out";
		TRACE ON;*/
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cId_submodulo,cD_submodulo,cIdModulo;
		END IF;		
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(cID_USUARIOC, cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cId_submodulo,cD_submodulo,cIdModulo;
		END IF;		
		
		SELECT {+INDEX (bdinteg:si_seg_submodulo idxidsubm)} nvl(Count(id_submodulo),0) INTO iexiste  FROM bdinteg:"informix".si_seg_submodulo WHERE id_submodulo IS NOT NULL;
		
		IF iexiste = 0 THEN
			LET cCodRet = "00002";
			RETURN cCodRet,cId_submodulo,cD_submodulo,cIdModulo;
		END IF;
		set isolation to dirty read;
        FOREACH
			SELECT {+INDEX (bdinteg:si_seg_submodulo idxidsubm)} Id_submodulo, D_submodulo INTO cId_submodulo,cD_submodulo 
			FROM bdinteg:"informix".si_seg_submodulo WHERE id_submodulo is not null ORDER BY id_submodulo
			
			SELECT id_modulo
			INTO cIdModulo
			FROM bdinteg:"informix".si_seg_funciones 
			WHERE id_submodulo = cId_submodulo GROUP BY 1;

			RETURN cCodRet,cId_submodulo,cD_submodulo,cIdModulo WITH resume;
		END FOREACH;		
    END
END PROCEDURE;