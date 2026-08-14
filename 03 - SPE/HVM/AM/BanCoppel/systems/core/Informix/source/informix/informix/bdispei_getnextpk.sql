CREATE PROCEDURE "informix".getnextpk(NombreTabla varchar(50)) RETURNING INTEGER;
DEFINE NoError, NoRegistros, NuevoPk integer;
  Let NoError = 0;
  Select Count(*) into NoRegistros from CTRLTABLAS Where PKCTRLTABLAS = NombreTabla; 
  if NoRegistros = 0 THEN
        insert into CTRLTABLAS values (NombreTabla,0,NombreTabla,0);
  END IF;

  Select NEXTPK Into NuevoPk from CTRLTABLAS Where PKCTRLTABLAS = NombreTabla;
  Update CTRLTABLAS set NEXTPK = NEXTPK+1  Where PKCTRLTABLAS = NombreTabla;
  return NuevoPk;
END PROCEDURE;