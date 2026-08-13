CREATE PROCEDURE "informix".sp_sesioncaja_web(pEmpresa CHAR(3),pCaja CHAR(14),pUsuario CHAR(8),pTipo CHAR(1),pTiempo INTEGER)

	RETURNING CHAR(5) AS Cod_Retorno, CHAR(53) AS Empleado;
			  
--DEFINICION DE VARIABLES
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr	INTEGER;
	DEFINE iActualizar	INTEGER;
	DEFINE cNumEmpleado CHAR(8);
	DEFINE cDescripcion CHAR(45);
	DEFINE dHoraOcupada DATETIME YEAR TO MINUTE;
	DEFINE dHoraActual  DATETIME YEAR TO MINUTE;
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet = '00000';
	LET iActualizar = 0;
	LET cNumEmpleado	= '';
	LET cDescripcion = '';
	LET dHoraOcupada	= '';
	LET dHoraActual = '';
	
	------------------------------------------------------------
			--	CODIGOS DE RETORNO
			--	000000	=	EJECUCION CORRECTA
			--	000001	=	PARAMETROS DE ENTRADA VACIOS O NULOS
			--	000002	=	CAJA ABIERTA
			--	000003	=	SESION EXPIRADA
			--	000004	=	SESION ACTIVA
			--	000005	=	CAJA DISPONIBLE
			--	000006	=	NO SE ENCONTRO REGISTRO
	------------------------------------------------------------
	
	BEGIN
		
		ON EXCEPTION  SET iSqlErr
			IF iSqlErr <> 0  THEN
				LET  cCodRet  = iSqlErr;
				RETURN cCodRet,cNumEmpleado||' '||cDescripcion;
			END IF;
		END  EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_sesioncaja.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pEmpresa,'') = '' OR NVL(pCaja,'') = '' OR NVL(pUsuario,'') = '' OR NVL(pTipo,'') = '' OR NVL(pTiempo,0) = 0 THEN	
			LET  cCodRet  = '00001';			
		ELSE			
			--SELECCIONA LA FECHA DEL SERVIDOR
			SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO MINUTE
			INTO dHoraActual
			FROM sysmaster:"informix".sysshmvals;		
			
			SELECT numempleado_cajaocupada,fecha_cajaocupada
			INTO cNumEmpleado, dHoraOcupada
			FROM "informix".ss_numcajas
			WHERE empresa = pEmpresa
			AND numerocaja = pCaja;		

			IF NVL(cNumEmpleado,'') <> '' THEN
				LET dHoraOcupada  = dHoraOcupada::DATETIME YEAR TO MINUTE +  (pTiempo) UNITS MINUTE;
			END IF;		
			
			IF pTipo = '0' THEN						--EL USUARIO QUEIRE ABRIR LA CAJA	(BLOQUEAR)
				IF NVL(cNumEmpleado,'') = '' THEN	--EL NUMERO DE EMPLEADO ESTA VACIO
					LET iActualizar = 1;			--SE PUEDE ABRIR LA CAJA CORRECTAMENTE
				ELSE
					IF pUsuario = cNumEmpleado AND dHoraOcupada > dHoraActual THEN
						LET cCodRet = '00004';
						LET cNumEmpleado = '';
					ELIF dHoraOcupada > dHoraActual THEN	--EL NUMERO DE EMPLEADO TIENE DATOS Y LA FECHA-HORA OCUPADA ES MAYOR A LA HORA ACTUAL
						LET cCodRet = '00002';			--REGRESA EL NOMBRE Y NUMERO DEL EMPLEADO QUE LA ESTA USANDO
						SELECT nombre				
						INTO cDescripcion
						FROM bdinteg:"informix".si_ejecut
						WHERE empresa = pEmpresa
						AND ejecutivo = cNumEmpleado;
					ELIF dHoraOcupada <= dHoraActual THEN	--LA FECHA-HORA ES MENOR O IGUAL A LA HORA ACTUAL
						LET iActualizar = 1;				--SE ACTUALIZA PARA PODER ABRIR LA CAJA
					END IF;
				END IF;
			ELIF pTipo = '1' THEN					--EL USUARIO QUIERE CERRAR LA CAJA	(DESBLOQUEAR)		
				IF cNumEmpleado = pUsuario THEN		--EL NUMERO DE EMPLEADO REGISTRADO ES IGUAL AL DEL PARAMETRO
					LET pUsuario = NULL;			--VARIABLES EN NULL PARA PODER CERRAR LA CAJA
					LET dHoraActual = NULL;			--VARIABLES EN NULL PARA PODER CERRAR LA CAJA
					LET iActualizar = 1;				--SE ACTUALIZARA SEGUN SEA LA SIGUIENTE VALIDACION
				END IF;
			ELIF pTipo = '2' THEN					--SE CONSULTA LA SESION
				IF cNumEmpleado = pUsuario THEN			--EL NUMERO DE EMPLEADO ES IGUAL AL PARAMETRO
					IF dHoraOcupada > dHoraActual THEN	--LA FECHA-HORA OCUPADA ES MAYOR A LA HORA
						LET cCodRet = '00004';
						LET cNumEmpleado = '';
					ELIF dHoraOcupada <= dHoraActual THEN	--LA FECHA-HORA ES MENOR O IGUAL A LA HORA ACTUAL (CAJA DISPONIBLE)
						LET cCodRet = '00003';				
						LET pUsuario = NULL;                --VARIABLES EN NULL PARA PODER CERRAR LA CAJA
						LET dHoraActual = NULL;				--VARIABLES EN NULL PARA PODER CERRAR LA CAJA
						LET iActualizar = 1;	            
					END IF;
				ELSE
					IF cNumEmpleado <> pUsuario THEN	--EL NUMERO DE EMPLEADO ES DIFERENTE AL PARAMETRO
						IF NVL(cNumEmpleado,'') = '' THEN	-- --EL NUMERO DE EMPLEADO ESTA EN NULL
							LET cCodRet = '00005';
							LET cNumEmpleado = '';
						ELSE
							LET cCodRet = '00002';		--EL NUMERO DE EMPLEADO ES DIFERENTE AL PARAMETRO Y DIFERENTE DE NULL
							SELECT nombre
							INTO cDescripcion
							FROM bdinteg:"informix".si_ejecut
							WHERE empresa = pEmpresa
							AND ejecutivo = cNumEmpleado;
						END IF;	
					END IF;
				END IF;
			END IF;
			
			IF iActualizar = 1 THEN				
				UPDATE "informix".ss_numcajas
				SET numempleado_cajaocupada = pUsuario,
				fecha_cajaocupada= dHoraActual
				WHERE empresa = pEmpresa
				AND numerocaja = pCaja;
			END IF;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCodRet = '00006';				
			END IF;
		END IF;
		
		RETURN cCodRet,cNumEmpleado||' '||cDescripcion;
			
	END
END PROCEDURE
;