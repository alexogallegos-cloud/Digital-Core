CREATE PROCEDURE "informix".sp_total_bitsmstelsms(pNumCliente CHAR(9),pNumTelefono CHAR(10))
   returning CHAR(5);

    DEFINE sql_err INTEGER ;
    DEFINE cCodRet CHAR(5);
	DEFINE iContador INTEGER;
	
	LET cCodRet='00000';
	
  --SET DEBUG FILE TO "/tmp/sp_total_bitsmstelsms.out";
  --TRACE ON;
  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
            RETURN cCodRet;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT COUNT(numcte) 
	INTO iContador 
	FROM bdinteg:"informix".si_bitsmstelsms 
	WHERE numcte =pNumCliente AND telefono =pNumTelefono AND DATE(fecha)=DATE(CURRENT);
	IF iContador>10 THEN
		LET cCodRet='00001';
	ELSE
		LET cCodRet='00000';
	END IF;

	RETURN cCodRet;
	
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1616BPI-ValidaNumeroCelular',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 30-11-2015',
'MODIFICACIÓN..: Se crea stored procedure para contabilizar las oportunidades de solicitud de clave nueva por sms',
'SOLICITA......: Walber Castro',
'BD............: BDINTEG';

CREATE PROCEDURE "informix".sps_activausuario_bpi(pEmpresa char(3), pNumCte char(20), pStatus integer,pIp char (15), pSuc char (4), pUsuCambio char (8))
   returning char(5);

-- Define variables

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE iCont smallint ;
	DEFINE vStatus integer;
	
	-- Descripción: Activa usuarios
	--22/04/2015
	-- Se agrega la actualizacion del estatus en bdinteg:si_bpiusuarios
	-- 12/02/2016
	-- Bibiana Gaxiola Verdugo
	
-- Inicializa variables

   LET cod_ret  = 000;
   LET iCont = 0;
   LET vStatus = 0;

    --SET DEBUG FILE TO '/home/informix/bibiana/sps_activausuario_bpi.out';
    --TRACE ON;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;


   IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN

		SELECT id_status INTO vStatus FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa and numcte = pNumCte;

		INSERT INTO bdinteg:"informix".si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (pNumCte,vStatus,pStatus,pIp,current,pSuc,pUsuCambio);
		
		UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus  WHERE numcte = pNumCte;

        LET cod_ret = '000';  -- Usuario activado

   ELSE

        LET cod_ret = '002';  -- No existe el Cliente

   END IF ;

   RETURN cod_ret;

END

END PROCEDURE
Document
'DESCRIPCION: Se modifica sp para el nuevo proceso HSM para la validacion de usuarios y contrasenias en la banca.', 
'AUTOR:Ilse Gomez',
'FECHA:06-04-2015',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_movctes_huellasatrasadas(pLimite INTEGER)
   RETURNING char (5) AS cCodRet;
      
DEFINE sCont	SMALLINT;
DEFINE cCodRet	char(5);
DEFINE iSql_err integer;

---Datos de tabla
DEFINE vnumcte   CHAR(20);
DEFINE vfecha_consulta DATE;
DEFINE vsecuencia CHAR(2);
DEFINE vsucursal CHAR(4);
DEFINE vip CHAR(15);
DEFINE vstatus_huella CHAR(1);
DEFINE vticket CHAR(20);
DEFINE vstatus_consulta CHAR(1);
DEFINE vrespuesta_msj601 CHAR(1);
DEFINE vfecha_insert DATETIME YEAR to SECOND;
  
LET sCont	= 0;
LET cCodRet	='00000';

	BEGIN
	    ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		-- Se eliminan registros de la tabla de paso
		TRUNCATE TABLE "informix".tmp_si_huella_linea; 
		
		BEGIN WORK;
		
		FOREACH WITH HOLD
		
			SELECT LIMIT pLimite {+AVOID_FULL("informix".si_huella_linea)} numcte,fecha_consulta,secuencia,sucursal,ip,status_huella,ticket,status_consulta,respuesta_msj601,fecha_insert  
				INTO vnumcte,vfecha_consulta,vsecuencia,vsucursal,vip,vstatus_huella,vticket,vstatus_consulta,vrespuesta_msj601,vfecha_insert
			FROM "informix".si_huella_linea 
			WHERE status_consulta IN ('3','9','0')
			AND fecha_insert < CURRENT - 1 UNITS DAY 
			AND (CASE WHEN NVL(ticket, '') = '' THEN 0 ELSE ticket::INT END) <= 0 
							
			INSERT INTO "informix".tmp_si_huella_linea 
				(numcte,fecha_consulta,secuencia,status_huella,ticket,status_consulta,respuesta_msj601,fecha_insert)
			VALUES 
             	(vnumcte,vfecha_consulta,vsecuencia,vstatus_huella,vticket,vstatus_consulta,vrespuesta_msj601,vfecha_insert);		

					
			LET sCont= sCont+1; 
			IF sCont=1000 THEN
				COMMIT WORK;
			   LET sCont=0;
				BEGIN WORK;
			END IF;
			
		END FOREACH;
		
		IF sCont >= 0 THEN
		  COMMIT WORK;
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE;