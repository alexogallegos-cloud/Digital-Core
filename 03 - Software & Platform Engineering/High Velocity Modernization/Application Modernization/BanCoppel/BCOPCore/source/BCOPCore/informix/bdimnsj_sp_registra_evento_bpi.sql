create procedure "informix".sp_registra_evento_bpi (
					pTipoMsj char(1), pIdMsj char(10), pNumclt char(20),
					pNumcta char(20), pNumTarjeta char(16),pTipoproc char(1), pStr1 char(30), 
					pStr2 char(30), pStr3 char(30), pStr4 char (30), 
					pStr5 char(150), pStr6 char(100), pStr7 char(60), pStr8 char(60), 
					pStr9 char(15), pStr10 char(100), pcorreo_alterno char(100), pcelular_alterno char(10), 
					pImporte1 money (16,2), pImporte2 money (16,2),
					pImporte3 money (16,2), pImporte4 money (16,2), pImporte5 money (16,2), 
					pfecha1 datetime year to fraction(3), pfecha2 datetime year to fraction(3)
				    )

RETURNING CHAR(5) as cCodRet;  -- Codigo de Retorno.

--DefiniciÃ³n de Variables
DEFINE cCodRet CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE pIdPlantilla CHAR(12);
DEFINE vIdMsj CHAR(10);

--Inicializa Variables
LET cCodRet = '00000';
LET pIdPlantilla = '';
LET vsqlerr = 0;
LET vIdMsj = '';

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         return vsqlerr;
      END IF;
   END EXCEPTION;
	--SET DEBUG FILE TO "/informix/Aida/sp_registra_evento_bpi.out";
	--TRACE ON;
	

  IF pIdMsj[1,3] = 'BPI' OR pIdMsj[1,3] = 'BEX' THEN
  LET pIdPlantilla = pIdMsj;
  LET vIdMsj = "PORTAL_BPI";
  END IF;
  
  IF pIdMsj[1,3] = 'ENT' THEN
   LET pIdPlantilla = pIdMsj;
   LET vIdMsj = "EMPRESANET";
   END IF;

 LET cCodRet = '00001';
 IF pIdPlantilla <> '' or pIdPlantilla is NOT null  then
  --Llama al nuevo sp_registra_evento que contiene un parametro mÃ¡s (IdPlantilla)
  CALL "informix".sp_registra_evento( pTipoMsj, vIdMsj,pIdPlantilla, pNumclt,
					pNumcta, pNumTarjeta,pTipoproc, pStr1, 
					pStr2, pStr3, pStr4, 
					pStr5, pStr6, pStr7, pStr8, 
					pStr9,pStr10,pcorreo_alterno, pcelular_alterno, 
					pImporte1, pImporte2,
					pImporte3, pImporte4, pImporte5, 
					pfecha1, pfecha2) RETURNING cCodRet;
 END IF;
 END;
 RETURN 	cCodRet;
 END PROCEDURE;