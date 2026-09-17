CREATE PROCEDURE "informix".sp_marcacancelacionadn_web(pEmpresa char(3), pCuenta char(20))

--DATOS A REGRESAR---
RETURNING
char(5)  as Cod_Ret	--Codigo de Retorno

--DEFINICION DE VARIABLES--
DEFINE Vcod_Ret         char(5);

--INICIALIZACION DE VARIABLES--
LET Vcod_Ret ="00000";
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Actualiza bandera para identificar que cliente solicito su portabilidad a otro banco
    update  bdisolic:ss_adn_solicitudcuenta set flag_porta=1
    where empresa= pEmpresa and num_solicitud=pCuenta;
    
    RETURN Vcod_Ret; 

END PROCEDURE;