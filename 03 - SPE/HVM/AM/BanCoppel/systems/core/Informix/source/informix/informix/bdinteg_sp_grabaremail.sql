CREATE PROCEDURE "informix".sp_grabaremail (pEmpresa CHAR(3), pNumCte CHAR(20), pEMail CHAR(60))
    RETURNING CHAR(6), CHAR(80);

	--pEmpresa: Empresa
	--pNumCte: Número de Cte
    --pEMail : Correo electrónico del cliente.    
    --Autor: Walber Castro
    --20-05-2010
    --Guarda el email en la tabla si_ctepf.

    DEFINE sCodRet CHAR(6);			--CODIGO DE RETORNO PERSONALIZADO
    DEFINE iCodRet INTEGER;			--CODIGO DE RETORNO INTERNO
    DEFINE sErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE cErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE iIsamErr smallint;           --VARIABLE PARA CACHAR EL CODIGO DE ERROR
	DEFINE v_codret1 CHAR(5);
	DEFINE v_TipoCorreo SMALLINT;
	DEFINE v_Canal SMALLINT;
	DEFINE v_UserInsert CHAR(8);
    
    LET sCodRet = "000";
    LET cErrorInfo="EMAIL ACTUALIZADO EXITOSAMENTE";
    LET sErrorInfo="";
    LET	iCodRet=0;   
	LET v_codret1 = '00000';	
	LET v_TipoCorreo = '3';
	LET v_Canal = '3';
	LET v_UserInsert ='transBPI';

   --SET DEBUG FILE TO '/tmp/sp_grabaremail.out';
   --TRACE ON;

    BEGIN
        ON EXCEPTION SET iCodRet, iIsamErr, sErrorInfo
            LET sCodRet = iCodRet;
            LET cErrorInfo = sErrorInfo;
            RETURN sCodRet, cErrorInfo;
        END Exception;
		
		--Se valida la empresa
        IF nvl(pEmpresa,'') = '' THEN
                LET sCodRet='001';
                LET cErrorInfo='EMPRESA NO VALIDA';
                RETURN sCodRet, cErrorInfo;
        END IF;
		
		--Se valida el cliente
        IF nvl(pNumCte,'') = '' THEN
                LET sCodRet='001';
                LET cErrorInfo='CLIENTE NO VALIDO';
                RETURN sCodRet, cErrorInfo;
        END IF;
		
        --Se valida el email
        IF nvl(pEMail,'') = '' THEN
                LET sCodRet='001';
                LET cErrorInfo='EMAIL NO VALIDO';
                RETURN sCodRet, cErrorInfo;
        END IF;         
				
		--UPDATE bdinteg:si_ctepf SET email = pEMail WHERE numcte = pNumCte and empresa = pEmpresa;
		IF (pEMail <> '') THEN
			IF (SELECT count (correo_elec) from bdinteg:"informix".si_correos where numcte = pNumCte and correo_elec = pEMail and status_correo = 'A') = 0 THEN
            EXECUTE PROCEDURE bdinteg:sp_registra_correos(pEmpresa,pNumCte,pEMail,v_TipoCorreo,v_Canal,v_UserInsert)
                            INTO v_codret1;
			END IF;				
        END IF;
        RETURN sCodRet, cErrorInfo;

    END ;
END PROCEDURE ;