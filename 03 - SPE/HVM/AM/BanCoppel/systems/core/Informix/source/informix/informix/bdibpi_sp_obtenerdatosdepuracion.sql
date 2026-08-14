CREATE PROCEDURE "informix".sp_obtenerdatosdepuracion(pFiltro SMALLINT, pFechaInicial DATE, pFechaFinal DATE, pDiasVencimiento SMALLINT)
returning CHAR(5), CHAR(9),  CHAR(50), Char(4), DATE, SMALLINT;

	DEFINE iSql_err		 		INT;
	DEFINE cCodRet				CHAR(5);
	DEFINE cNumcte		 		CHAR(9);
	DEFINE cNomcte		 		CHAR(50);
	DEFINE cSucursal	 		Char(4);
	DEFINE dFechaReenvio 		DATE;
	DEFINE dFechaCancelacion    DATE;
	DEFINE dFechaActual			DATE;
	DEFINE dFechaVencimiento	DATE;
	DEFINE sDiasTranscurridos	SMALLINT;
	DEFINE cNumSolicitud		CHAR(10);
	
	--SE INICIALIZAN VARIABLES
	LET iSql_err = 0;
	LET cCodret = '00000';
	LET cNumcte = '';
	LET cNomcte = '';
	LET cSucursal = '';
	LET dFechaReenvio = DATE(1);
	LET dFechaCancelacion = DATE(1);
	LET dFechaActual = DATE(1);
	LET dFechaVencimiento = DATE(1);	
	LET sDiasTranscurridos = 0;
	LET cNumSolicitud = '';
	
	--SET DEBUG FILE TO "/informix/temp/sp_obtenerdatosdepuracion.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodret = iSql_err;
				RETURN cCodret, cNumcte, cNomcte, cSucursal, dFechaReenvio, pDiasVencimiento;
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		
		IF (NVL(pFiltro,'')='') THEN
			LET cCodRet = '00002';
			RETURN cCodRet, cNumcte, cNomcte, cSucursal, dFechaReenvio, pDiasVencimiento; 
		END IF;		
		
		--SE OBTIENE LA FECHA DEL DIA ACTUAL
		LET dFechaActual = (SELECT FECHA_HOY FROM BDINTEG: "informix".SI_FECHAS);
		
		--OPCION REENVIO
		IF pFiltro = 1 THEN			
			
			FOREACH 	
				--SE OBTIENEN LOS DATOS NUMERO DE CLIENTE, SUCURSAL Y LA FECHA EN QUE SE DIO DE ALTA EL REENVIO
				--CON EL FILTRO DEL CAMPO ID_STATUS Y CON LOS PARAMETROS DE ENTRADA PFECHAINI Y PFECHAFIN
				SELECT numcte, sucursal, f_atencion::DATE   
					INTO cNumcte, cSucursal, dFechaReenvio
				FROM bdibpi: "informix". bpi_tokensolicitud 
				WHERE id_status = '180' AND f_atencion::DATE BETWEEN pFechaInicial AND pFechaFinal
				
				--SE OBTIENE LA DIFERENCIA ENTRE LA FECHA DE REENVÍO DEL TOKEN Y LA FECHA ACTUAL
				LET sDiasTranscurridos = (dFechaActual - dFechaReenvio);
				
				--SE OBTIENE EL NOMBRE COMPLETO DEL CLIENTE
				SELECT  TRIM(nombre1) || " " || TRIM(nombre2) || " " || TRIM(apell_paterno) || " " || TRIM(apell_materno) 
					INTO cNomcte
				FROM BDINTEG: "informix". si_cliente WHERE numcte = cNumcte;
					
				RETURN cCodRet, cNumcte, cNomcte, cSucursal, dFechaReenvio, sDiasTranscurridos WITH RESUME; 
			
			END FOREACH;	
			
			--OPCION PROXIMOS A CANCELAR
			ELSE IF pFiltro = 2 THEN
					
				--SE OBTIENE LOS DIAS TRANSCURRIDOS, ESTOS DEPENDEN DEL PARAMETRO DE ENTRADA pDiasVencimiento
				LET dFechaVencimiento = (dFechaActual  - pDiasVencimiento units day);
				
				--SE OBTIENE LOS DATOS DEL CLIENTE CON ESTATUS 180 CUYAS SOLICITUDES NO HAN SIDO CANCELADAS
				FOREACH 				
					SELECT numcte, sucursal, f_atencion::DATE  
						INTO cNumcte, cSucursal, dFechaReenvio
						FROM bdibpi: "informix". bpi_tokensolicitud 
					WHERE id_status = '180' and f_atencion::DATE = dFechaVencimiento
					
					SELECT  TRIM(nombre1) || " " || TRIM(nombre2) || " " || TRIM(apell_paterno) || " " || TRIM(apell_materno) 
						INTO cNomcte
					FROM BDINTEG: "informix". si_cliente WHERE numcte = cNumcte;
					
					--SE OBTIENE LA DIFERENCIA ENTRE LA FECHA DE REENVÍO DEL TOKEN Y LA FECHA ACTUAL
					LET sDiasTranscurridos = (dFechaActual - dFechaReenvio);				
					
					RETURN cCodRet, cNumcte, cNomcte, cSucursal, dFechaReenvio, sDiasTranscurridos WITH RESUME; 
				
				END FOREACH;
					
				--OPCION DE SOLICITUDES CANCELADAS
				ELSE IF pFiltro = 3 THEN
					
					--SE OBTIENE LOS DATOS DEL CLIENTE CON ESTATUS 180 QUE SON AQUELLAS SOLICITUDES QUE FUERON CANCELADAS.
					FOREACH 
						
						SELECT numcliente, fecha_depuracion, num_solicitud
							INTO cNumcte, dFechaCancelacion, cNumSolicitud
						FROM bdibpi: "informix". bpi_bitacora_reenvios 
						WHERE estatus_depuracion = '180' AND fecha_depuracion BETWEEN pFechaInicial AND pFechaFinal					
						
						SELECT  TRIM(a.nombre1) || " " || TRIM(a.nombre2) || " " || TRIM(a.apell_paterno) || " " || TRIM(a.apell_materno), b.sucursal
							INTO cNomcte, cSucursal
						FROM BDINTEG: "informix". si_cliente a, bdibpi: bpi_tokensolicitud b
						WHERE a.numcte = cNumcte AND b.numcte = cNumcte
						AND b.solicitud = cNumSolicitud;
						
						--SE OBTIENE LA DIFERENCIA ENTRE LA FECHA DE REENVÍO DEL TOKEN Y LA FECHA ACTUAL
						LET sDiasTranscurridos = (dFechaActual - dFechaCancelacion);
						
						RETURN cCodRet, cNumcte, cNomcte, cSucursal, dFechaCancelacion, sDiasTranscurridos WITH RESUME; 
					
					END FOREACH;
				END IF;	
			END IF;		
		END IF;

		IF (cNumcte = '' AND cSucursal = '')THEN
			LET cCodRet = '00001';
			RETURN cCodRet, cNumcte, cNomcte, cSucursal, dFechaReenvio, pDiasVencimiento; 
		END IF;
	END
	
END PROCEDURE
DOCUMENT
'AUTOR: 93078021 Yaneli Barraza',
'FECHA: 19/10/2015',
'BD: bdibpi',
'Objetivo: Obtiene los datos de las solicitudes de Reenvio, Proximos a cancelar y Canceladas',
'--****    MODIFICACION     ****--',
'AUTOR: 95414878 Roberto Castro',
'FECHA: 07/12/2015',
'Objetivo: Se agrega filtro por numero de solicitud en el filtro 3';

CREATE PROCEDURE "informix".sp_actualizastatususuario_bpi(pEmpresa char(3), pIdUsuario integer, pUsuario char(50), pStatus integer, pIp char (15),pSuc char (4), pUsuCambio char (8))
   returning char(5);
      
   --Modificó: Javier A. Chávez T.
   --Actividad: actualiza el status en del usuario y registra ese cambio
   --Solicito: Mauricio León
   --Fecha: 05-03-09
  
   --Modificó: Elmer López Valenzuela.
   --Actividad: se cambia parametro de numero de cliente por id de usuario
   --Solicito: Alejandro Vazquez
   --Fecha: 15-01-16   

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cCod_ret char(5);
   DEFINE iSql_err integer;
   DEFINE iStatus integer;
   DEFINE cNumcte char(9);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cCod_ret = "000";
   LET iStatus = "0";
   LET cNumcte = "";

BEGIN

   ON EXCEPTION SET iSql_err
      IF iSql_err <> 0 THEN
            let cCod_ret = iSql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;
   
    --SET DEBUG FILE TO '/tmp/sp_actualizastatususuario_bpi.out';
    --TRACE ON;
		
    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

    IF pIdUsuario <> 0 THEN
	  
	  SELECT bpi.numcte INTO cNumcte
			FROM bdinteg:si_bpiusuarios bpi INNER JOIN bdibpi:bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'  
			WHERE empresa = pEmpresa AND id_usuario = pIdUsuario;
					
	ELSE
		LET cCod_ret = '003';
	END IF;

    IF cNumcte <> "" THEN

        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumcte ) THEN
		
			SELECT id_status INTO iStatus FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa and numcte = cNumcte;
							
				INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (cNumcte, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);
				
				UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND numcte = cNumcte;

				LET cCod_ret = '000';  -- Usuario bloqueado

        ELSE

            LET cCod_ret = '001';  -- No existe el Cliente

        END IF ;

    ELSE

        IF EXISTS ( SELECT numcte FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN
		
			SELECT id_status INTO iStatus FROM bdinteg:si_bpiusuarios WHERE empresa = pEmpresa and usuario = pUsuario;
			
				 INSERT INTO bdinteg:si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (cNumcte, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);	
					
				 UPDATE bdinteg:si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND usuario = pUsuario;

				LET cCod_ret = '000';  -- Usuario bloqueado
			

        ELSE

            LET cCod_ret = '002';  -- No existe el Usuario

        END IF ;

    END IF ;

    RETURN cCod_ret;

END

END PROCEDURE ;