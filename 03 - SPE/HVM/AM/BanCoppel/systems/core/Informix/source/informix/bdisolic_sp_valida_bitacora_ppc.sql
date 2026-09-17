CREATE PROCEDURE "informix".sp_valida_bitacora_ppc(pnumcte CHAR(20), pfolioPres CHAR(20), pSuc CHAR(4), pUsuario CHAR(30))
   RETURNING CHAR(5) AS cCodRet;

DEFINE cCodRet			CHAR(5); 
DEFINE iSqlErr          INTEGER; 
DEFINE cFolioPres       CHAR (20);
DEFINE cCandidato       CHAR(1);
DEFINE cStatus          CHAR(1);


LET cCodRet = "00000";
LET iSqlErr = 0;
LET cFolioPres ="";
LET cCandidato ="";
LET cStatus="";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

--SET DEBUG FILE TO "/tmp/mfinis/ss_bitacoraeventosppcoppel.out";
--TRACE ON;

IF pfolioPres="" then

   SELECT {+AVOID_FULL("informix".ss_bitacoraeventosppcoppel)} candidato INTO cCandidato FROM bdisolic:ss_bitacoraeventosppcoppel WHERE promotor=pUsuario AND sucursal=pSuc 
   AND numctebanco=pnumcte AND folioprestamo='' AND candidato ='1' ;
  
   IF cCandidato <> '' THEN
     UPDATE bdisolic:ss_bitacoraeventosppcoppel SET candidato = '0', solicitud = '0', amortizacion = '0', AsigCta = '0', AsigTarj = '0', autorizacion = '0'
	 WHERE promotor=pUsuario AND sucursal=pSuc AND numctebanco=pnumcte AND folioprestamo='' AND candidato ='1';
   ELSE 
	 LET cCodRet = "00001"; -- no se encontro informacion
    END IF;

ELSE

   SELECT status_solicitud INTO cStatus FROM bdisolic:ss_prestamoscoppel WHERE folio_prestamo = pfolioPres AND numcte=pnumcte;
 
   IF cStatus ="A" THEN
     UPDATE bdisolic:ss_bitacoraeventosppcoppel SET candidato = '1', solicitud = '1', amortizacion = '1', AsigCta = '0', AsigTarj = '0', autorizacion = '1'
	 WHERE promotor=pUsuario AND sucursal=pSuc AND numctebanco=pnumcte AND folioprestamo=pfolioPres;
	 
	  LET cCodRet = "00000";
   ELSE
      UPDATE bdisolic:ss_bitacoraeventosppcoppel SET candidato = '1', solicitud = '1', amortizacion = '1', AsigCta = '0', AsigTarj = '0', autorizacion = '0'
	  WHERE promotor=pUsuario AND sucursal=pSuc AND numctebanco=pnumcte AND folioprestamo=pfolioPres;
	  LET cCodRet = "00000";
   END IF;
	 
    
END IF;
RETURN cCodRet;
END;
END PROCEDURE;