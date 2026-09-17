CREATE PROCEDURE "informix".sp_insbitsmstelcte(popcion CHAR(1), pnumcte CHAR(9), pejecutivo CHAR(8), psucursal CHAR(5), pdigito_ver CHAR(4), ptelefono CHAR(10), pteclea_ejecut CHAR(100), pbandera boolean)
RETURNING char(5) as codret;
DEFINE iSqlErr			INTEGER;
DEFINE sNumRnd          INTEGER;
DEFINE sNumRnd2         DECIMAL(10,0);
DEFINE sCodigo          CHAR(4);
DEFINE sCodSp           CHAR(5);
DEFINE iMinutos         INTEGER;
DEFINE iReintentos      INTEGER;
DEFINE iEnviados        INTEGER;
DEFINE iMinTrans        INTEGER;
DEFINE sDiferencia      CHAR(30);
DEFINE iExiste          SMALLINT;
DEFINE pCte             CHAR(20);
DEFINE sCodSp2          CHAR(5);
DEFINE sCorreo          CHAR(100);
DEFINE pfecha           DATETIME YEAR TO FRACTION;

LET sNumRnd     =   0;
LET sNumRnd2    =   0;
LET sCodigo     =   '';
LET sCodSp      =   '00000';
LET iMinutos    =   0;
LET iReintentos =   0;
LET iEnviados   =   0;
LET iMinTrans   =   0;
LET sDiferencia =   '';
LET iExiste     =   0;
LET pCte        =   '';
LET pfecha      =   '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;

SET ISOLATION TO DIRTY READ;
--SET ISOLATION COMMITTED READ;
SET LOCK MODE TO WAIT 5;

--SET DEBUG FILE TO '/tmp/anj/sp_insbitsmstel.sql';
--TRACE ON;

IF popcion='1' THEN		
--*****OPCION 1 DE INSERCION*****--



       --IF NOT EXISTS(SELECT * FROM si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current)) THEN
       SELECT FIRST 1 numcte INTO pCte FROM si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current);
       LET iExiste = dbinfo("sqlca.sqlerrd2");
       IF iExiste=0 THEN
           INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
                  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);
	   ELSE
			SELECT FIRST 1 digito_ver INTO pdigito_ver FROM si_bitsmstels WHERE numcte=pnumcte and telefono=ptelefono and date(fecha)=date(current);
       END IF;

       EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL2','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
               INTO sCodSp;

       --***ATENCION DEL RQI 63 421***--
            --EXTRAYENDO EL E-MAIL DEL CLIENTE
            SELECT FIRST 1 correo_elec INTO sCorreo FROM SI_CORREOS WHERE numcte=pnumcte AND status_correo='A';
            IF NVL(sCorreo,'')<>'' THEN
                EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_ATC','OFI_ATC','000000000','','','1',pdigito_ver,'','','','','','','','','',sCorreo,'',1,0,0,0,0,current,current) INTO sCodSp;
            END IF;
       --***ATENCION DEL RQI 63 421***--
        
ELIF popcion='2' THEN
--*****OPCION 2 INSERTAR CODIGO INCORRECTO*****--
        SELECT MAX(fecha) INTO pfecha FROM bdinteg:"informix".si_bitsmstels 
            WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL;
        UPDATE bdinteg:"informix".si_bitsmstels set teclea_ejecut = pteclea_ejecut
            WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL AND fecha = pfecha;
        INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, bandera, fecha) 
            VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, pbandera, current);
ELIF popcion='3' THEN
--*****OPCION 3 ACTUALIZACION CODIGO CORRECTO*****--
        --IF EXISTS (SELECT * FROM si_bitsmstels WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL) THEN 
        SELECT FIRST 1 numcte INTO pCte FROM si_bitsmstels WHERE numcte=pnumcte AND ejecutivo=pejecutivo AND sucursal=psucursal AND DATE(fecha)=DATE(CURRENT) AND teclea_ejecut IS NULL;
        LET iExiste = dbinfo("sqlca.sqlerrd2");
        IF iExiste>0 THEN
            SELECT MAX(fecha) INTO pfecha FROM bdinteg:"informix".si_bitsmstels 
                WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL;
            UPDATE si_bitsmstels SET teclea_ejecut=pteclea_ejecut, bandera=pbandera, fecha=CURRENT
                WHERE numcte = pnumcte AND ejecutivo = pejecutivo AND sucursal = psucursal AND fecha = pfecha AND teclea_ejecut IS NULL;
        ELSE
            INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, teclea_ejecut, bandera, fecha) 
                              VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, pteclea_ejecut, pbandera, current);
        END IF;
        --AQUI AGREGAR EL UPDATE A LA SI_TELEFONOS POR NUMERO DE CLIENTE, TELEFONO, CAMBIAR EL CAMPO VERIFICADO A 'V'
        IF pbandera<>'F' or pbandera<>'f' THEN
            UPDATE si_telefonos SET verificado="V" WHERE numcte= pnumcte and telefono=ptelefono;
            UPDATE si_telefonos SET verificado="F" WHERE numcte<> pnumcte and telefono=ptelefono;
        END IF;

ELIF popcion='5' THEN
	--Realizar el ReenvÃÂ­o de nuevo cuando es mantenimiento

        INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
        VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);


        EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL2','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
			INTO sCodSp;

       --***ATENCION DEL RQI 63 421***--
            --EXTRAYENDO EL E-MAIL DEL CLIENTE
        SELECT FIRST 1 correo_elec INTO sCorreo FROM SI_CORREOS WHERE numcte=pnumcte AND status_correo='A';
        IF NVL(sCorreo,'')<>'' THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_ATC','OFI_ATC','000000000','','','1',pdigito_ver,'','','','','','','','','',sCorreo,'',1,0,0,0,0,current,current) INTO sCodSp;
        END IF;
       --***ATENCION DEL RQI 63 421***--

ELSE
--*****OPCION 4 ENVIO DEL SMS DE NUEVA CUENTA*****--

  --OBTENIENDO LOS PARAMETROS
    --MINUTOS MAXIMO PARA REENVIAR EL SMS
    SELECT TRIM(valor) INTO iMinutos FROM si_param WHERE cod_param='382';
    --CANTIDAD DE REINTENTOS MAXIMOS POR DIA (SOLO REENVIO)
    SELECT TRIM(valor) INTO iReintentos FROM si_param WHERE cod_param='383';


  --OBTENIENDO LA CANTIDAD DE REENVIOS DEL DIA POR CTE-TELEFONO
    SELECT COUNT(*) INTO iEnviados
      FROM si_bitsmstels where numcte=pnumcte AND telefono=ptelefono
        AND TRIM(teclea_ejecut)='REENVIO SMS'
        AND DATE(fecha)=DATE(current);

  --SI SE SUPERA EL MAXIMO DE SMS REENVIADOS SE DA POR TERMINADO EL SP
    IF  iEnviados>=iReintentos THEN
        RETURN sCodSp;
    END IF;

  --OBTENIENDO LOS MINUTOS QUE HAN TRANSCURRIDO DEL ULTIMO MENSAJE
    SELECT CURRENT-MIN(fecha) INTO sDiferencia
      FROM si_bitsmstels where numcte=pnumcte AND telefono=ptelefono
        AND DATE(fecha)=DATE(current) AND digito_ver = pdigito_ver;

    IF LENGTH(TRIM(sDiferencia))=16 THEN
        select SUBSTRING((TRIM(sDiferencia))  from 8 for 2) INTO iMinTrans FROM si_fechas;
    ELIF LENGTH(TRIM(sDiferencia))=15 THEN
        select SUBSTRING((TRIM(sDiferencia))  from 7 for 2) INTO iMinTrans FROM si_fechas;   
    ELSE
        select SUBSTRING((TRIM(sDiferencia))  from 6 for 2) INTO iMinTrans FROM si_fechas;   
    END IF;

   --SI LOS MINUTOS OBTENIDOS SON MENORES AL RANGO ESTABLECIDO NO SE ENVIA MENSAJE
   IF iMinTrans<iMinutos THEN
      RETURN sCodSp;
   END IF;

        --IF EXISTS(SELECT * FROM si_bitsmstels WHERE numcte=pnumcte AND telefono=ptelefono AND teclea_ejecut IS NULL) THEN
        SELECT FIRST 1 numcte INTO pCte FROM si_bitsmstels WHERE numcte=pnumcte AND telefono=ptelefono AND teclea_ejecut IS NULL;
        LET iExiste = dbinfo("sqlca.sqlerrd2");
        IF iExiste>0 THEN
            --
            SELECT MAX(fecha) INTO pfecha FROM bdinteg:"informix".si_bitsmstels WHERE numcte = pnumcte AND telefono = ptelefono;
            
            UPDATE bdinteg:"informix".si_bitsmstels set teclea_ejecut='REENVIO SMS'
                WHERE numcte = pnumcte AND telefono = ptelefono AND teclea_ejecut IS NULL AND fecha = pfecha;
        ELSE
            INSERT INTO bdinteg:"informix".si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, teclea_ejecut, fecha) 
                  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono,'REENVIO SMS', current);
        END IF;

            INSERT INTO si_bitsmstels(numcte, ejecutivo, sucursal, digito_ver, telefono, fecha) 
                  VALUES(pnumcte, pejecutivo, psucursal, pdigito_ver, ptelefono, current);

            EXECUTE PROCEDURE bdimnsj:sp_registra_evento(1,'OFI_AVSMS', 'OFI_CNCEL3','000000000', 'XXXXXXXXXXX','', '1', pdigito_ver, '', pnumcte, '', '', '', '', '', '', '', '', ptelefono, 1, 0, 0, 0, 0,current,current)
               INTO sCodSp;
            
            --***ATENCION DEL RQI 63 421***--
                --EXTRAYENDO EL E-MAIL DEL CLIENTE
                SELECT FIRST 1 correo_elec INTO sCorreo FROM SI_CORREOS WHERE numcte=pnumcte AND status_correo='A';
                IF NVL(sCorreo,'')<>'' THEN
                    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_ATC','OFI_ATC','000000000','','','1',pdigito_ver,'','','','','','','','','',sCorreo,'',1,0,0,0,0,current,current) INTO sCodSp;
                END IF;
            --***ATENCION DEL RQI 63 421***--
        
END IF;  
       RETURN sCodSp;
	END
END PROCEDURE;