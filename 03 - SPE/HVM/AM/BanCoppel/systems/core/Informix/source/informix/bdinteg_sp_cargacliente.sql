CREATE PROCEDURE "informix".sp_cargacliente(pEmpresa char(3),pNumCredito CHAR(20),pNumCliente CHAR(10), pOpcion CHAR(1))

RETURNING CHAR(5) AS cCodRet,DATE AS fechaAlta ,CHAR(30) AS Nombre1,CHAR(30) AS Nombre2,
CHAR(30) AS ApellPaterno,CHAR(30) AS ApellMaterno,CHAR(30) AS RazonSocial,CHAR(1) AS Codidentifi,
CHAR(30) AS Numidentifi,CHAR(15) AS Rfc,DATE AS Fecha_nac,CHAR(1) AS ExisteCred;

--Declaracion de variables
DEFINE cCodRet        CHAR(5);
DEFINE iSqlErr        INTEGER;
DEFINE dfechaAlta     DATE;
DEFINE cNombre1       CHAR(30);
DEFINE cNombre2       CHAR(30);
DEFINE cApellPaterno  CHAR(30);
DEFINE cApellMaterno  CHAR(30);
DEFINE cRazonSocial   CHAR(30);
DEFINE cCodidentifi   CHAR(1);
DEFINE iNumidentifi   CHAR(30);
DEFINE cRfc           CHAR(15);
DEFINE dFecha_nac     DATE;
DEFINE cCliente       CHAR(10);
DEFINE iExiste		  INTEGER;
 
--Asignacion de variables
LET cCodRet           = '00001';
LET iSqlErr           = 0;
LET dfechaAlta        = '';
LET cNombre1          = '';
LET cNombre2          = '';
LET cApellPaterno     = '';
LET cApellMaterno     = '';
LET cRazonSocial      = '';
LET cCodidentifi      = '';
LET iNumidentifi      = '';
LET cRfc              = '';
LET dFecha_nac        = '';
LET cCliente          = '';
LET iExiste           = 0;

BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;		
			RETURN cCodRet,dfechaAlta,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cRazonSocial,cCodidentifi,iNumidentifi,cRfc,dFecha_nac,iExiste;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_CargaCliente.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	
	IF pOpcion = "1" THEN 
		IF pNumCliente != "" AND pEmpresa != "" THEN

			SELECT a.numcte,a.fecha_alta, a.nombre1, a.nombre2, a.apell_paterno,a.apell_materno, a.razon_social, b.codidentifi, b.numidentifi, a.rfc, b.fecha_nac 
			INTO cCliente,dfechaAlta,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cRazonSocial,cCodidentifi,iNumidentifi,cRfc,dFecha_nac
			FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_ctepf b 
			WHERE a.numcte = pNumCliente 
			AND a.empresa = pEmpresa 
			AND b.empresa = a.empresa 
			AND b.numcte = a.numcte;

			LET cCodRet  = '00000';
			
			IF cCliente IS NULL THEN 
				LET cCodRet  = '00001';
			END IF;
			
			RETURN cCodRet,dfechaAlta,cNombre1,cNombre2,cApellPaterno,cApellMaterno,cRazonSocial,cCodidentifi,iNumidentifi,cRfc,dFecha_nac,NVL(iExiste,'0');	
		ELSE
			LET cCodRet  = '00001';	
		END IF;
	
	
	ELIF pOpcion = "2" THEN 	
	
		SELECT 1 INTO iExiste
		FROM bdisolic:"informix".ss_solicitudes
		WHERE empresa = pempresa 
		AND num_solicitud = pNumCredito 
		AND numcte = pNumCliente;

		LET cCodRet  = '00000';
	
	    RETURN cCodRet,NVL(dfechaAlta,''),NVL(cNombre1,''),NVL(cNombre2,''),NVL(cApellPaterno,''),NVL(cApellMaterno,''),NVL(cRazonSocial,''),NVL(cCodidentifi,''),NVL(iNumidentifi,''),NVL(cRfc,''),NVL(dFecha_nac,''),NVL(iExiste,'0');
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Josue Zepeda',
'FECHA: 03/08/2012',
'BD: bdinteg',
'Objetivo: Carga los Datos del Cliente y verifica numero de credito';

CREATE PROCEDURE "informix".sp_depura_bitacorabpi_v2(fechmin CHAR(10), fechmax CHAR(10))
    RETURNING CHAR(5), integer, integer;  --Códigos de retorno

DEFINE cCodRet       CHAR(5);
DEFINE vid_operacion    CHAR (4);
DEFINE vtotregshist  integer;
DEFINE iSqlErr       integer;
DEFINE cont_borra    integer;
DEFINE cursor_borra  integer;

LET cCodRet        = '00000';
LET vid_operacion     = '0000';
LET vtotregshist   = 0;
LET iSqlErr        = 0;
LET cont_borra     = 0;
LET cursor_borra   = 0;

 --SET DEBUG FILE TO "/tmp/sp_depura_bitacorabpi_v2.out";
 --TRACE ON;

        SET LOCK MODE TO wait 5;
BEGIN

   ON EXCEPTION SET iSqlErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    RETURN cCodRet, vtotregshist, cont_borra;
                END IF;
    END EXCEPTION;

     SELECT  count(*) 
        INTO vtotregshist  
     FROM bdinteg:si_bpibitacora
     WHERE extend (fecha_oper, year to day) between fechmin and fechmax
     and NVL(id_operacion,'') <> '';
	
	FOREACH cursor_borra WITH HOLD FOR
		SELECT id_operacion
			INTO vid_operacion
			FROM bdinteg:si_bpibitacora
			WHERE extend (fecha_oper, year to day) between fechmin and fechmax
			and NVL(id_operacion,'') <> ''
   begin work;
		DELETE FROM bdinteg:si_bpibitacora
			WHERE CURRENT OF cursor_borra;
		commit work;
		

        LET cont_borra = cont_borra + 1;

    END FOREACH;

END;
RETURN cCodRet, vtotregshist, cont_borra;
END PROCEDURE



;