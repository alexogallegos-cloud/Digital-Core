CREATE PROCEDURE "informix".sp_act_retenido(pEmpresa CHAR(3))
    RETURNING CHAR(5), char(100);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

   DEFINE CodRet              CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vNumCred            CHAR(20);
   DEFINE vNumfolio           CHAR(16);
   DEFINE VMONTO              DECIMAL(16,2);
   DEFINE iAcumulado          integer;  
   DEFINE iContador           integer;



   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
         ROLLBACK WORK;
         RETURN CodRet, "Error en el proceso"||isam_err;
   END EXCEPTION WITH RESUME;


  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET CodRet            = '000';
   LET vNumCred          = "";   
   LET vNumfolio         = "";
   let VMONTO            = 0;
   LET iAcumulado        = 0;
   LET iContador         = 0;

   
    SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_act_retenido.out";
    TRACE OFF;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   FOREACH WITH HOLD
        SELECT num_credito
        into vNumCred
        FROM ret1
          
        let VMONTO = 0;

        BEGIN WORK;

            SELECT NVL(SUM(MONTO),0) 
              INTO VMONTO
              FROM bdicred:"informix".sd_maeretenido
            WHERE empresa = pEmpresa
              AND num_credito = vNumCred
              AND estatus = 'P';

              IF (VMONTO < 0 OR VMONTO IS NULL ) THEN
                let VMONTO = 0;
              END IF;

            UPDATE bdicred:"informix".sd_maesdos
               SET sdo_retenido = VMONTO
            WHERE empresa = pEmpresa
              AND num_credito = vNumCred;

       commit work;

       IF ( iContador >= 2000 ) then
            TRACE ON;
            LET iAcumulado = iAcumulado;
            TRACE OFF;
            LET iContador = 0;
       END IF

       LET iAcumulado = iAcumulado + 1;
       LET iContador = iContador + 1;

    END FOREACH;

  LET CodRet='000';

  RETURN CodRet, "Proceso Exitoso";

END PROCEDURE;