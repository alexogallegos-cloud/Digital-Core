CREATE PROCEDURE "informix".sp_ctes_tels_repetidos()

RETURNING CHAR(5) AS CODRET, INTEGER AS iTotales;

    DEFINE sCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE cNumCte          CHAR(10);
    DEFINE cNumCteBorrado   CHAR(10);
    DEFINE iTotales         INTEGER;
    DEFINE i                INTEGER;
    DEFINE iContIni         INTEGER;
    DEFINE iSecMax          INTEGER;
    DEFINE iSecAnt          INTEGER;
    /*Inicio Declaracion Variables Tabla*/
    DEFINE cEmpresa         CHAR(3);
    DEFINE cNumcte2         CHAR(20);
    DEFINE cTelefon         CHAR(13);
    DEFINE iTipoTel         SMALLINT;
    DEFINE cStatusTel       CHAR(1);
    DEFINE iSecuencia       SMALLINT;
    DEFINE cExtension       CHAR(5);
    DEFINE iCarrier         SMALLINT;
    DEFINE iCanal           SMALLINT;
    DEFINE iContacto        SMALLINT;
    DEFINE cCofetel         CHAR(1);
    DEFINE dFechaHora       DATETIME YEAR to SECOND;
    DEFINE cUserInsert      CHAR(8);
    DEFINE cMovilFijo       CHAR(1);
    DEFINE cStatusStel      CHAR(1);
    DEFINE cVerificado      CHAR(1);
    DEFINE cMarcatel        CHAR(1);
    DEFINE dFechaActualiza  DATE;
    DEFINE cTelConfirmado   CHAR(1);
    DEFINE dFechConfirmado  DATETIME YEAR to SECOND;
    /*Fin Declaracion Variables Tabla*/

    LET sCodRet         = "00000";
    LET iSqlErr         = 0;
    LET cNumCte         = '';
    LET cNumCteBorrado  = '';
    LET iTotales        = 0;
    LET iContIni        = 0;
    LET iSecMax         = 0;
    LET iSecAnt         = 0;
    /*Inicio Variables Tabla*/
    LET cEmpresa        = '';
    LET cNumcte2        = '';
    LET cTelefon        = '';
    LET iTipoTel        = 0;
    LET cStatusTel      = '';
    LET iSecuencia      = 0;
    LET cExtension      = '';
    LET iCarrier        = 0;
    LET iCanal          = 0;
    LET iContacto       = 0;
    LET cCofetel        = '';
    LET dFechaHora      = DATE(1);
    LET cUserInsert     = '';
    LET cMovilFijo      = '';
    LET cStatusStel     = '';
    LET cVerificado     = '';
    LET cMarcatel       = '';
    LET dFechaActualiza = DATE(1);
    LET cTelConfirmado  = '';
    LET dFechConfirmado = DATE(1);
    /*Fin Variables Tabla*/

BEGIN
ON EXCEPTION SET iSqlErr
   IF iSqlErr <> 0 THEN
      LET sCodRet = iSqlErr;
	  RETURN sCodRet, iTotales;
   END IF;
END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/cr/sp_ctes_tels_repetidos.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
   		
    LET sCodRet         = "00000";
 	  
    --Obtiene total de clientes a procesar
    SELECT count(*)
    INTO iContIni
    FROM bdinteg:"informix".si_ctstelsrepetidos;

    IF iContIni > 0 THEN
        
        FOREACH WITH HOLD
            --Obtiene los clientes a procesar
            SELECT num_cte
            INTO cNumCteBorrado
            FROM si_ctstelsrepetidos

            --1.- Se obtiene la mÃ¡xima secuencia para obtener el Ãºltimo telÃ©fono
            SELECT MAX(secuencia) 
            INTO iSecMax
            FROM si_telefonos 
            WHERE tipo_tel = '2' 
            AND numcte = cNumCteBorrado;
            
            --2.- Se obtiene una secuencia anterior que nos da los datos correctos
            SELECT MAX(secuencia)
            INTO iSecAnt
            FROM si_telefonos
            WHERE numcte = cNumCteBorrado
            AND tipo_tel = '2' 
            AND secuencia <> iSecMax;
            
            IF NVL(iSecAnt,'') <> '' THEN

                --3.- Se obtienen los datos del cliente y almacenan en las variables
                SELECT empresa,numcte,telefono,tipo_tel,status_tel,secuencia,extension,carrier,canal,contacto,
                cofetel,fecha_hora,user_insert,movil_fijo,status_stel,verificado,marcatel,fecha_actualiza,tel_confirmado,fech_confirmado
                INTO cEmpresa,cNumcte2,cTelefon,iTipoTel,cStatusTel,iSecuencia,cExtension,iCarrier,iCanal,iContacto,
                cCofetel,dFechaHora,cUserInsert,cMovilFijo,cStatusStel,cVerificado,cMarcatel,dFechaActualiza,cTelConfirmado,dFechConfirmado
                FROM bdinteg:si_telefonos 
                WHERE numcte = cNumCteBorrado AND tipo_tel = '2' AND secuencia = iSecAnt;

                --4.-Eliminar la mÃ¡xima secuencia ya que es la errÃ³nea
                DELETE FROM bdinteg:si_telefonos WHERE numcte = cNumCteBorrado AND tipo_tel = '2' AND secuencia = iSecMax;

                --5.-Eliminar la secuencia anterior para volverla a insertar y el trigger lo vuelva a insertar en la si_telefonos_actual
                DELETE FROM bdinteg:si_telefonos WHERE numcte = cNumCteBorrado AND tipo_tel = '2' AND secuencia = iSecAnt;

                --6.-Se valida el valor de 'C'-Cancelado a 'A'-Activo
                LET cStatusTel = 'A';

                --7.-Inserta valores originales, el trigger los replica a la si_telefonos_actual
                INSERT INTO si_telefonos (empresa,numcte,telefono,tipo_tel,status_tel,secuencia,extension,carrier,canal,contacto,
                cofetel,fecha_hora,user_insert,movil_fijo,status_stel,verificado,marcatel,fecha_actualiza,tel_confirmado,fech_confirmado)
                VALUES(cEmpresa,cNumcte2,cTelefon,iTipoTel,cStatusTel,iSecuencia,cExtension,iCarrier,iCanal,iContacto,
                cCofetel,dFechaHora,cUserInsert,cMovilFijo,cStatusStel,cVerificado,cMarcatel,dFechaActualiza,cTelConfirmado,dFechConfirmado);

            END IF

        END FOREACH;
    END IF

	RETURN sCodRet, iContIni;

END;
END PROCEDURE;