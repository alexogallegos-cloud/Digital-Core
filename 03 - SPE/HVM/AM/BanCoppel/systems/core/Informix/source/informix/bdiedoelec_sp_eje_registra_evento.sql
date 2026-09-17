CREATE PROCEDURE "informix".sp_eje_registra_evento (pempresa char(3),pnumcte char(20),pass_sec_part char(4)) 

DEFINE vcodret 			CHAR(5);

DEFINE vcodret1 		CHAR(5);
DEFINE vTelefono        CHAR(13);
DEFINE vTipoTel         SMALLINT;
DEFINE vSecuencia       SMALLINT;
DEFINE vStatus_Tel      CHAR(1);
DEFINE vExtension       CHAR(5);
DEFINE vCarrier         SMALLINT;
DEFINE vNombreCarrier   CHAR(30);
DEFINE StatusValidacion SMALLINT;

LET vcodret          = '00000';

LET vcodret1         = '';
LET vTelefono        = '';
LET vTipoTel         = 0;
LET vSecuencia       = 0;
LET vStatus_Tel      = '';
LET vExtension       = '';
LET vCarrier         = 0;
LET vNombreCarrier   = '';
LET StatusValidacion = 0;



--SET DEBUG FILE TO "/tmp/sp_eje_registra_evento.out";
--TRACE ON;


BEGIN

	EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_telefonos(pempresa, pnumcte, 2, 0) 
		INTO vcodret1,vtelefono,vtipotel,vsecuencia,vstatus_tel,vextension,vcarrier,vnombrecarrier,statusvalidacion;
	
	IF vcodret1 = '000'THEN
			
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CFDI_SMS','000000000','','','1',pass_sec_part,'','','','','','','','','','',vtelefono,0,0,0,0,0,CURRENT,CURRENT - 10 UNITS SECOND)			
		INTO vcodret;	
				
	END IF	
		 
END;	

END PROCEDURE;