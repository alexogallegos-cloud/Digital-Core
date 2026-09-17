CREATE PROCEDURE "informix".sp_calcularfc(pEmpresa CHAR(3), 
                                          pApePat VARCHAR(26), 
                                          pApeMat VARCHAR(26), 
                                          pNombre1 VARCHAR(26),  
                                          pNombre2 VARCHAR(26), 
                                          pFechaNac DATE) 

RETURNING CHAR(6)       AS retorno, 
          VARCHAR(100)  AS mensaje, 
          VARCHAR(13)   AS rfc; 

-- Variables del proceso
DEFINE vNombre      VARCHAR(53);
DEFINE vApell_Pat   VARCHAR(26);
DEFINE vApell_Mat   VARCHAR(26);
DEFINE cLetraApePat CHAR(1);
DEFINE cVocalApePat CHAR(1);
DEFINE cLetraapeMat CHAR(1);
DEFINE cLetraNombre CHAR(1);
DEFINE cDia         CHAR(2);
DEFINE cMes         CHAR(2);
DEFINE cAnio        CHAR(2);
DEFINE i,a          INTEGER;
DEFINE cLetra       CHAR(1);
DEFINE cCaracter    CHAR(1);
DEFINE cRfc         VARCHAR(13);
DEFINE cPalabra     VARCHAR(26);
DEFINE cFechaNac    VARCHAR(10);
DEFINE cHomoclave   CHAR(2);
DEFINE cDigito      CHAR(1);

-- Control de errores
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE vErrorInfo   VARCHAR(100);
DEFINE vCodRet      CHAR(6);
DEFINE cMensaje     VARCHAR(100);

-- Variables del proceso
LET vNombre         = "";
LET vApell_Pat      = TRIM(UPPER(pApePat));
LET vApell_Mat      = TRIM(UPPER(pApeMat));
LET cLetraApePat    = "";
LET cVocalApePat    = "";
LET cLetraapeMat    = "";
LET cLetraNombre    = "";
LET cDia            = "";
LET cMes            = "";
LET cAnio           = "";
LET i               = 0;
LET a               = 0;
LET cLetra          = "";
LET cCaracter       = "";
LET cRfc            = "";
LET cPalabra        = "";
LET cFechaNac       = pFechaNac;
LET cHomoclave      = "";
LET cDigito         = "";


-- Control de errores
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET vErrorInfo      = "";
LET vCodRet         = "000000";
LET cMensaje        = "El proceso se realizó con éxito.";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
   IF iSqlErr != 0 THEN
      LET vCodRet= iSqlErr;
      LET cMensaje= vErrorInfo;
      RETURN vCodRet, cMensaje,cRfc;
   END IF;
END EXCEPTION; 

  --SET DEBUG FILE TO "/home/sysifx/viridiana/sp_calcularfc.out";
  --TRACE ON;

   IF NVL(pEmpresa,"") = "" THEN
       LET vCodRet = "000001";
       LET cMensaje = "La información de la empresa no es correcta.";
       RETURN vCodRet, cMensaje,cRfc;
   END IF;

   IF NVL(pApePat,"") = "" AND NVL(pApeMat,"") = "" THEN
       LET vCodRet = "000002";
       LET cMensaje = "Es necesario proporcionar al menos un apellido del cliente.";
       RETURN vCodRet, cMensaje,cRfc;
   END IF;

   IF NVL(pNombre1,"") = "" AND NVL(pNombre2,"") = "" THEN
       LET vCodRet = "000003";
       LET cMensaje = "Es necesario proporcionar al menos un nombre del cliente.";
       RETURN vCodRet, cMensaje,cRfc;
   END IF;

   LET cFechaNac = LPAD(YEAR(pFechaNac),4,0) ||"/" || LPAD(MONTH(pFechaNac),2,0) || "/" || LPAD(DAY(pFechaNac),2,0);

   IF NVL(cFechaNac,"") <> "" AND (LENGTH(cFechaNac) = 10) AND SUBSTR(cFechaNac,1,1) <> "0" THEN    

           LET cAnio = SUBSTR(cFechaNac,3,2);
           LET cMes  = SUBSTR(cFechaNac,6,2);
           LET cDia  = SUBSTR(cFechaNac,9,2);       
                 
   ELSE
       LET vCodRet = "000005";
       LET cMensaje = "La fecha de nacimiento del proporcionada no es válida.";
       RETURN vCodRet, cMensaje,cRfc;     
   
   END IF   

   IF  NVL(pApePat,"") = ""  AND NVL(pApeMat,"") <> "" THEN
       LET vApell_Pat = TRIM(UPPER(pApeMat));
       LET vApell_Mat = "";
   END IF; 


   LET vNombre = UPPER(TRIM(pNombre1) ||" "|| TRIM(pNombre2));
   
   EXECUTE PROCEDURE bdinteg:sp_calcularrfc(vApell_Pat, vApell_Mat, vNombre, pFechaNac)
            INTO vCodRet, cRfc;
   
IF vCodRet <> "00000" THEN
    LET vCodRet = "000017";
    LET cMensaje = "Ocurrió un error al calcular el dígito verificador para el RFC.";
    RETURN vCodRet, cMensaje,cRfc;
ELSE
    LET vCodRet = "000000";
END IF;


RETURN vCodRet, cMensaje,cRfc;
END 
END PROCEDURE
DOCUMENT
"Descripción: Procedimiento que realiza el cálculo del RFC de un cliente.",
"BD: bdinteg",
"Fecha: 06-Abril-2010",
"Autor: Viridiana Osobampo Aguilar";

CREATE PROCEDURE "informix".sp_actualizarfc_prosp()
RETURNING CHAR(5) as codret, CHAR(5) as codret2, CHAR(5) as mensaje;

DEFINE vcodret1         char(5); 
DEFINE vcodret2         char(5);
DEFINE vcodret3         char(50);
DEFINE sql_err          integer;
DEFINE isam_err         integer;
DEFINE desc_err         char(50);
DEFINE vnumcte          char(10);
DEFINE vrfc_calculado   char(13);
DEFINE vcomienza        smallint;
DEFINE ven_transacc     smallint;
DEFINE vcontador1       integer;

LET vcodret1            ='00000';
LET vcodret2            ='0000';
LET vcodret3            ='PROCESO CONCLUIDO SATISFACTORIAMENTE';
LET sql_err             =0;
LET isam_err            =0;
LET desc_err            ='';
LET vcomienza           =-1;
LET ven_transacc        = 0;  
LET vnumcte             ='';
LET vrfc_calculado      ='';
LET vcontador1          =0;



BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/arch_sp_actualizarfc.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;

            RETURN vcodret1, vcodret2, vcodret3;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH WITH HOLD
        select  numcte, rfc_calculado INTO vnumcte,  vrfc_calculado from resultadosrfc_prosp where rfc_duplicado=0
    
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        UPDATE si_cliente set rfc=vrfc_calculado where numcte=vnumcte;

        LET vcontador1 = vcontador1 + 1;
        

        IF (vcontador1 >= 5000) THEN
            LET vcontador1 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
     END FOREACH;

     IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
     END IF;

END;
RETURN vcodret1, vcodret2, vcodret3; 
END PROCEDURE;