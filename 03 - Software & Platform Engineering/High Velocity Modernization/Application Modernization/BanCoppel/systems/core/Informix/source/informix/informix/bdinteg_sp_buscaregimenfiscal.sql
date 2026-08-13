CREATE PROCEDURE "informix".sp_buscaregimenfiscal(pRegFiscal CHAR(3))
RETURNING CHAR(5)	AS CodRetorno,
		  CHAR(3)	AS CodRegFiscal,
		  CHAR(150)	AS Descrip;

--Definicion de Variables
DEFINE iSqlErr 	     INTEGER;
DEFINE cCodRet		 CHAR(5);
DEFINE cRegimenFiscal	 CHAR(3);
DEFINE cDescripcion  CHAR(150);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cRegimenFiscal 	= '';
LET cDescripcion 	= '';

--SET DEBUG FILE TO '/tmp/sp_buscaregimenfiscal.out';
--TRACE ON;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet,'','';
            END IF;
        END EXCEPTION;

        SET LOCK MODE TO WAIT 3;


        IF NVL(pRegFiscal,'') = '' THEN
                LET cCodRet = '00001';
                RETURN cCodRet,'','';
        ELSE
                SELECT c_regimenfiscal, descripcion
                INTO cRegimenFiscal, cDescripcion
                FROM bdinteg:"informix".si_regimen_fiscal
                WHERE c_regimenfiscal=pRegFiscal;

                LET cCodRet = iSqlErr;
                RETURN cCodRet, NVL(cRegimenFiscal,''), NVL(cdescripcion,'');

        END IF;

    END;
END PROCEDURE
DOCUMENT
'Descripcion : Consulta el regimen fiscal del cliente',
'Etiqueta    : CFDI 4.0',
'Modifico    : Maria de los Angeles Perez Rios',
'Fecha       : 10/11/2023',
'VERSION     : 20231110.01',
'BD          : BDINTEG';

CREATE PROCEDURE "informix".sp_bitacora_mant_cte (pSuc CHAR(4), pGte CHAR(8), pUsuario CHAR(8), pNumcte CHAR(9), pFecha DATE, pIp CHAR(16))
       RETURNING CHAR(5) as codret;

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;


LET vcodret = '00000';
LET vsqlerr = 0;

BEGIN
        ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret;
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	
	if pNumcte <>'' then
	   INSERT INTO informix.bitacora_mantenimiento(sucursal, gerente, usuario_modifica, numcte, fecha_modifica, ip_maquina) 
              VALUES(pSuc, pGte, pUsuario, pNumcte, CURRENT, pIp);

	   LET vcodret='00000';
       RETURN vcodret;
	else
	  LET vcodret='00001';
      RETURN vcodret;
	end if;
END;
END PROCEDURE;