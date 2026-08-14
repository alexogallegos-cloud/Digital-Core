CREATE PROCEDURE "informix".sp_aviso_privacidad_web(pEmpresa CHAR(3), 
									 pCliente CHAR(9), 
									 pSucursal CHAR(20),
									 pRespuesta CHAR(8),
									 pMensaje CHAR(200),
									 pBandera CHAR(8))
RETURNING CHAR(5) as RETORNO;

--RETORNO FINAL									 
DEFINE iSqlErr INTEGER;
DEFINE codRet CHAR(5);


--RETORNO PRIMER SP
DEFINE cCodRet CHAR(3);

--RETORNO SEGUNDO SP
DEFINE cCodRetSeg CHAR(5);

LET iSqlErr = 0;
LET cCodRet = '';
LET cCodRetSeg = '';
LET codRet = '00000';


--SET DEBUG FILE TO '/informix/sp_aviso_privacidad_web.out';
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET codRet = iSqlErr;
       RETURN codRet;
   END IF;
END EXCEPTION;

IF pBandera IS NULL OR Trim(pBandera) = '' THEN
       LET codRet  = '00001';
       RETURN codRet;
END IF;

     IF pBandera = '1' THEN
     IF pEmpresa IS NOT NULL OR Trim(pEmpresa) <> '' AND pCliente IS NOT NULL OR Trim(pCliente) <> '' THEN
        Call bdinteg:"informix".sp_valida_aviso_privacidad(pEmpresa,pCliente) 
                 returning cCodRet;
            IF cCodRet <> '000' THEN
                LET codRet = '00001';
                RETURN codRet;
            ELSE
                 RETURN codRet;    
            END IF
        END IF
    END IF
    IF  pBandera = '2'  THEN
        IF pRespuesta = '1' AND pEmpresa IS NOT NULL OR Trim(pEmpresa)  <> '' AND  
        pCliente IS NOT NULL OR Trim(pCliente)  <> '' AND pSucursal IS NOT NULL OR Trim(pSucursal)  <> '' AND 
        pMensaje IS NOT NULL OR Trim(pMensaje)  <> ''  THEN
        Call bdinteg:"informix".sp_insert_autor_privacidad(pEmpresa,pCliente,pSucursal,pRespuesta,pMensaje) 
              returning codRet;
         RETURN codRet;
     END IF
END IF
    IF pRespuesta = '2' OR pRespuesta = '3' THEN
    IF  pBandera = '3' AND pEmpresa IS NOT NULL OR Trim(pEmpresa)  <> '' AND  
        pCliente IS NOT NULL OR Trim(pCliente)  <> '' AND pSucursal IS NOT NULL OR Trim(pSucursal)  <> '' AND 
        pMensaje IS NOT NULL OR Trim(pMensaje)  <> '' THEN
       Call bdinteg:"informix".sp_cancela_autor_privacidad(pEmpresa, pCliente)  
                 returning cCodRetSeg;
            IF cCodRetSeg <>'00000' THEN
                 LET codRet = '00001';
                RETURN codRet;
            ELSE
                RETURN codRet;    
      END IF
    END IF
END IF
    IF pBandera = '3' THEN
        IF  pEmpresa IS NOT NULL OR Trim(pEmpresa)  <> '' AND pCliente IS NOT NULL OR Trim(pCliente)  <> '' THEN
         Call bdinteg:"informix".sp_cancela_autor_privacidad(pEmpresa, pCliente)  
                 returning cCodRetSeg;
            IF cCodRetSeg <>'00000' THEN
                 LET codRet = '00001';
                RETURN codRet;
            ELSE
                RETURN codRet;    
            END IF
         END IF
    END IF
RETURN codRet;
END
END PROCEDURE;