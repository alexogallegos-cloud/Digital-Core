CREATE PROCEDURE "informix".sp_compac_consultacompromisosvigente_ofi( pEmpresa CHAR(3), pNumCuenta CHAR(20))
RETURNING CHAR(5)       AS Codigo_Retorno,
          CHAR(80)      AS Mensaje_Retorno,
          DATE          AS Fecha_Convenio,
          DATE          AS Fecha_Vencimiento,
          DECIMAL(14,2) AS Importe,
          CHAR (3)      AS Origen;
--definicion de variables
DEFINE iSqlErr      	           INTEGER;
DEFINE iIsamErr                    INTEGER;
DEFINE cErrorInfo                  CHAR(80);
DEFINE Codigo_Retorno              CHAR(5); 
DEFINE Mensaje_Retorno             CHAR(80); 
DEFINE Fecha_Convenio              DATE;
DEFINE Fecha_Vencimiento           DATE;
DEFINE Importe                     DECIMAL;
DEFINE Origen                      CHAR(3);

--inicializacion de variables	  
LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = '';
LET Codigo_Retorno           = '';
LET Mensaje_Retorno          = '';
LET Fecha_Convenio          = DATE(1);
LET Fecha_Vencimiento       = DATE(1);
LET Importe                 = 0;  
LET Origen                  = '';

--Set debug file to '/home/sysifx/jesusm/sp_debug_OFI.out';
--trace on;	


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET Codigo_Retorno= iSqlErr;
          LET Mensaje_Retorno= cErrorInfo;
          RETURN  Codigo_Retorno,Mensaje_Retorno,Fecha_Convenio,Fecha_Vencimiento,Importe,Origen;
       END IF;
    END EXCEPTION;

	EXECUTE PROCEDURE sp_compac_consultacompromisosvigente( pEmpresa , pNumCuenta)
					INTO Codigo_Retorno,Mensaje_Retorno,Fecha_Convenio,Fecha_Vencimiento,Importe,Origen;
					
    RETURN  Codigo_Retorno,Mensaje_Retorno,Fecha_Convenio,Fecha_Vencimiento,Importe,Origen;
END;
END PROCEDURE;