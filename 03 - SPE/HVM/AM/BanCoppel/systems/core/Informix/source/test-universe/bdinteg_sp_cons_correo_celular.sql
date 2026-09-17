CREATE PROCEDURE "informix".sp_cons_correo_celular(pempresa char(3), pnumcte char(20))
--DATOS A REGRESAR---
RETURNING
CHAR(5),     -- Código de retorno
CHAR(100),   -- Cuenta de Correo
CHAR(13),    -- Telefono Celular
CHAR(02);    -- Carrier

--DEFINICION DE VARIABLES--
DEFINE iSql_Err 		INTEGER;
DEFINE iLongitud        SMALLINT;
DEFINE iCarrier         SMALLINT;
DEFINE iTipo            SMALLINT;
DEFINE cSecuencia 		SMALLINT;
DEFINE iStatusValidacion SMALLINT;
DEFINE cCorreo          CHAR(100);
DEFINE cCelular         CHAR(13);
DEFINE cCarrier         CHAR(2);
DEFINE cCod_Ret 		CHAR(5);
DEFINE cStatus  		CHAR(1);
DEFINE cTipoTel 		CHAR(1);
DEFINE cStatus_Tel 		CHAR(1);
DEFINE cExtension 		CHAR(5);
DEFINE cNombreCarrier 	CHAR(20);

--INICIALIZACION DE VARIABLES--
LET cCod_Ret         = "00000";
LET cCorreo          = "";
LET cCelular         = "";
LET cCarrier         = "";
LET iCarrier         = 0;

--  SET DEBUG FILE TO "/tmp/sp_cons_correo_celular.out";
--  TRACE ON;

set isolation to dirty read;
SET LOCK MODE TO WAIT 3;

-- INICIO DEL PROCEDIMIENTO
BEGIN
  -- MANEJADOR DE ERRORES
  ON EXCEPTION SET iSql_Err
     IF iSql_Err <> 0 THEN
   	     LET cCod_Ret = iSql_Err;
	     RETURN cCod_Ret, cCorreo, cCelular, cCarrier;
     END IF;
   END EXCEPTION;

IF NVL(pEmpresa,'') = ''  THEN
	LET cCod_Ret = "00001";
	LET cCorreo = 'Parámetros incompletos';
	RETURN cCod_Ret, cCorreo, cCelular, cCarrier;
END IF;

SET ISOLATION TO DIRTY READ;
-- Recupera Cuenat de Correo Actual
EXECUTE FUNCTION bdinteg:"informix".sp_consulta_correos(pEmpresa, pNumCte, 1, 0)
INTO cCod_Ret, cCorreo, iTipo, cStatus;
-- Recupera Telefono Celular Actual
EXECUTE FUNCTION bdinteg:"informix".sp_consulta_telefonos(pEmpresa, pNumCte, 2, 0)
INTO cCod_Ret, cCelular, cTipoTel, cSecuencia, cStatus_Tel, cExtension, iCarrier, cNombreCarrier, iStatusValidacion;

LET cCarrier =  LPAD(NVL(iCarrier,0),2,'0');

RETURN LPAD(TRIM(cCod_Ret), 5,'0'), cCorreo, cCelular, cCarrier;
END;
END PROCEDURE
DOCUMENT
'Consulta Cuenta de Correo y Telefono Celular',
'AUTOR : Jaime González',
'FECHA : 02/Marzo/2012',
'Ver.  : 1.0',
'BD    : bdinteg';

CREATE PROCEDURE  "informix".sp_llena_ctes_infosat()
       returning CHAR(5)  AS Cod_Retorno;

DEFINE vcodret     CHAR(5);
DEFINE vsqlerr     INTEGER;
DEFINE ultcte      CHAR(9);
DEFINE iContador   INTEGER;
DEFINE sCommit     SMALLINT;
DEFINE sEmpresa    CHAR(3);
DEFINE sNumcte     CHAR(20); 


BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;

LET vcodret="00000";
LET ultcte='';
LET iContador = 0;
LET sCommit = 0;

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "/informix/OMC/sp_llena_ctes_infosat.out";
--TRACE ON;

            --Obteniendo el ultimo cliente generado con la info para el SAT
			  SELECT valor INTO ultcte
			  FROM si_param WHERE empresa='001' AND cod_param='139';	
			  
            --Obteniendo los registros de clientes ordenados
            SET ISOLATION TO DIRTY READ;
            FOREACH WITH HOLD
                SELECT LIMIT 1000000  empresa, numcte
				INTO sEmpresa, sNumcte
                FROM bdinteg:si_cliente
                WHERE empresa='001' AND tpo_persona='01'
                AND tipo_cliente='1' AND numcte >ultcte ORDER BY numcte
                

            --Llenando la tabla de control
                
                IF (sCommit = 0) THEN
					BEGIN WORK;
					LET iContador = 0;
					LET sCommit = -1;
                END IF;
                
                INSERT INTO si_ctessat(empresa, numcte,estatus_proc)
                VALUES(sEmpresa, sNumcte, 0);

				LET iContador = iContador  + 1;	
				
                --Ejecutar un commit cada 10000 registros.
                IF (iContador >= 10000) THEN
                    COMMIT WORK;	
                    LET iContador = 0;				
                    BEGIN WORK;
                END IF;	
			END FOREACH;

            IF sCommit = -1 THEN
            	COMMIT WORK;                
            END IF;
            LET sCommit = 0;
			
END;
return vcodret;   
END PROCEDURE;