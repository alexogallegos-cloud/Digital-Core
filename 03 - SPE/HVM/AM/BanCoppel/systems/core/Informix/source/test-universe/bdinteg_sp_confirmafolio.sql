CREATE PROCEDURE "informix".sp_confirmafolio(psucursal CHAR(4), pnumcte CHAR(9), pejecutivo CHAR(8), ptelefono CHAR(10), pRandom CHAR(4))
RETURNING char(5) as codret;
DEFINE iSqlErr			INTEGER;
DEFINE sCodRet          CHAR(5);
DEFINE sNumRnd          INTEGER;
DEFINE sNumRnd2         DECIMAL(10,0);
DEFINE sCodigo          CHAR(4);
DEFINE sCodSp           CHAR(5);

LET sNumRnd     =   0;
LET sNumRnd2    =   0;
LET sCodigo     =   '';
LET sCodRet     =   '';     
LET sCodSp      =   '00000';


BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
    	END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/anj/sp_confirmafolio.SQL";
	--TRACE ON;
	  

      EXECUTE PROCEDURE sp_registra_telefonos('001', pnumcte, ptelefono, 2, '', 0, 1, pejecutivo) INTO sCodRet;

      IF sCodRet="000" THEN
           IF EXISTS(SELECT * FROM si_bitsmstels WHERE numcte<>pnumcte and DATE(fecha)=current) THEN 
               LET sCodRet='00001';
               RETURN sCodRet;
           END IF;

           IF EXISTS(SELECT * FROM si_bitsmstels WHERE numcte=pnumcte AND teclea_ejecut IS NULL) THEN    
                UPDATE si_bitsmstels SET teclea_ejecut='GENERA NUEVO FOLIO', fecha=current where numcte=pnumcte and teclea_ejecut IS NULL;
           END IF;

           INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
                       VALUES(pnumcte, pejecutivo, psucursal, pRandom, ptelefono, current);
           
           EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL2','000000000', 'XXXXXXXXXXX','', '1', pRandom, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
               INTO sCodRet;

      ELSE
            RETURN sCodRet;
      END IF;

      RETURN sCodSp;
END
END PROCEDURE;