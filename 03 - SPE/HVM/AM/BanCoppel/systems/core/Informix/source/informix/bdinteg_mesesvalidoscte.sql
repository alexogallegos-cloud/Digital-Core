CREATE PROCEDURE "informix".mesesvalidoscte(pNumcte CHAR(20)) 
RETURNING 
CHAR(6) AS codret,
INTEGER AS mesescte;


---DECLARACION DE VARIABLES
DEFINE cCodRet CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE error_info CHAR(80);
DEFINE isam_err INTEGER;

DEFINE vlFecha	DATE;

DEFINE iAnios INTEGER;
DEFINE iAniosValidos INTEGER;
DEFINE iMeses INTEGER;


--SET DEBUG FILE TO "/informix/jesus/mesesvalidoscte.out";
--TRACE ON;

---INICIALIZACION DE VARIABLES
LET cCodRet  = '000000';
LET iSqlErr = 0;
LET error_info = '';
LET isam_err = 0;


LET vlFecha = DATE(1);
LET iAnios = 0;
LET iAniosValidos = 0;
LET iMeses = 0;

BEGIN

ON EXCEPTION SET iSqlErr, isam_err, error_info
LET cCodRet = iSqlErr;
	RETURN cCodRet,0;
END EXCEPTION;

--Directiva para lectura de tablas bloqueadas.
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy 
  into vlFecha
 FROM bdicred:"informix".sd_fechas
 WHERE empresa = '001';

 SELECT valor 
  into iAniosValidos
 FROM bdicred:"informix".sd_param 
 WHERE empresa = '001'
 and cod_param = '095';
 
SELECT  YEAR(TODAY) - YEAR(fecha_nac),CASE WHEN MONTH(fecha_nac) = MONTH(TODAY) AND DAY(fecha_nac) <= DAY(TODAY) 
		THEN 0
		ELSE 
			CASE WHEN MONTH(fecha_nac) < MONTH(TODAY) AND DAY(fecha_nac) <= DAY(TODAY) 
			THEN 				
				MONTH(TODAY) - MONTH(fecha_nac) 
			ELSE
				MONTH(TODAY) - MONTH(fecha_nac) -1
			END 
		END 
		INTO iAnios,iMeses
 FROM "informix".si_ctepf 
WHERE numcte = pNumcte;


LET iAnios = iAnios - iAniosValidos;LET iMeses =  (iAnios *  12) + iMeses;
IF iMeses < 0 THEN 
	LET iMeses = 0;
END IF;
	RETURN cCodRet,iMeses;
END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener numero de de meses de historia validos del cliente de acuerdo a su edad ',
'AUTOR: Jesus manuel aguilar heredia',
'FECHA: 05-27-2015',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actualizastatususuario_app(pEmpresa char(3), pIdUsuario INTEGER, pUsuario char(50), pStatus integer, pIp char (15),pSuc char (4), pUsuCambio char (8))
returning char(5);
   
   --Modificó: Alejandro Vazquez
   --Actividad: actualiza el status en del usuario y registra ese cambio
   --Solicito: APPS
   --Fecha: 28-05-2015
 
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;
   DEFINE vStatus integer;
   DEFINE vNumcte char(20);
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "000";
   LET vStatus = "0";
   LET vNumcte ="";

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;


    IF pIdUsuario <> 0 THEN
			SELECT bpi.numcte INTO vNumcte
				FROM bdinteg:si_bpiusuarios bpi INNER JOIN bdibpi:bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'  
				WHERE empresa = pEmpresa AND id_usuario = pIdUsuario;
				
        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = vNumcte )  THEN
		
			SELECT id_status INTO vStatus FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa and numcte = vNumcte;
							
				INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (vNumcte, vStatus, pStatus, pIp, current, pSuc, pUsuCambio);
				
				UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND numcte = vNumcte;

				LET cod_ret = '000';  -- Usuario bloqueado

        ELSE

            LET cod_ret = '001';  -- No existe el Cliente

        END IF ;

    ELSE

        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN
		
			SELECT id_status, numcte INTO vStatus,vNumcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa and usuario = pUsuario;
			
				 INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (vNumcte, vStatus, pStatus, pIp, current, pSuc, pUsuCambio);	
					
				 UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND usuario = pUsuario;

				LET cod_ret = '000';  -- Usuario bloqueado
			

        ELSE

            LET cod_ret = '002';  -- No existe el Usuario

        END IF ;

    END IF ;

    RETURN cod_ret;

END

END PROCEDURE ;