CREATE PROCEDURE "informix".sp_remplaza_n(cCadena LVARCHAR(525))
RETURNING LVARCHAR(525) AS CADENA;

DEFINE cCodRet                  CHAR(6);
DEFINE cLetra                   CHAR(10);
DEFINE cEscritura               LVARCHAR(525);
DEFINE iSqlErr                  SMALLINT;
DEFINE iCantVueltas             SMALLINT;
DEFINE iNumCaracter             SMALLINT;

LET cCodRet                             = '000000';
LET cLetra                              = '';
LET cEscritura                  = '';
LET iSqlErr                             = 0;
LET iCantVueltas                = 0;
LET iNumCaracter                = 0;


BEGIN
        ON EXCEPTION SET iSqlErr
                IF iSqlErr != 0 THEN
                        LET cCodRet= iSqlErr;

                        RETURN cCadena;
                END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        --SET DEBUG FILE TO "/informix/sp_remplaza_n.out";
        --TRACE ON;

        LET iCantVueltas = LENGTH(cCadena);
        IF iCantVueltas >= 1 THEN
                FOR iNumCaracter = 1 TO iCantVueltas
                        LET cLetra = '';
                        LET cLetra = SUBSTR(cCadena,iNumCaracter,1);
                        IF (ASCII(cLetra) == 209 ) THEN                               --  LETRA Ã
                                LET cEscritura = TRIM(cEscritura) || '#';
                        ELIF cLetra = ' ' THEN
                                LET cEscritura = TRIM(cEscritura) || '_';
                        ELIF (ASCII(cLetra) == 193 ) THEN                                     --  LETRA Ã
                                LET cEscritura = TRIM(cEscritura) || 'A';
                        ELIF (ASCII(cLetra) == 201 ) THEN                                     --  LETRA Ã
                                LET cEscritura = TRIM(cEscritura) || 'E';
                        ELIF (ASCII(cLetra) == 205 ) THEN                                     --  LETRA Ã
                                LET cEscritura = TRIM(cEscritura) || 'I';
                        ELIF (ASCII(cLetra) == 211 ) THEN                                     --  LETRA Ã
                                LET cEscritura = TRIM(cEscritura) || 'O';
                        ELIF (ASCII(cLetra) == 218 ) THEN                                     --  LETRA Ã
                                LET cEscritura = TRIM(cEscritura) || 'U';
                        ELSE
                                LET cEscritura = TRIM(cEscritura) || cLetra;
                        END IF;
                END FOR;
        END IF;

        LET cEscritura = REPLACE (cEscritura, '_',' ');
        RETURN cEscritura;
END;
END PROCEDURE
DOCUMENT
'BD: bdinteg',
'SP que toma una cadena de entrada y reemplaza cualquiere Ã dentro de la cadena, por el simbolo #',
'se agrega una modificacion para eliminar los acentos de las vocales',
'VERSION: 20220117.01';

CREATE PROCEDURE "informix".sp_actualiza_cta_calificacion(pNumCte VARCHAR(20), pCta VARCHAR(20))

	RETURNING CHAR(5) AS CodRet;
	

	DEFINE v_CodRet									CHAR(5);
	DEFINE v_Row					 				INTEGER;
	
	LET v_CodRet = '00000';
	LET v_Row = 0;
	
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	BEGIN
	

		SELECT MAX(ROWID) INTO v_Row from si_cte_grado_riesgo WHERE numcte = pNumCte;
	
		UPDATE si_cte_grado_riesgo SET numcta = pCta WHERE ROWID = v_Row;
	
		RETURN v_CodRet;
	END;
END PROCEDURE

DOCUMENT
'SP para actualizar la cuenta de captaciÃ³n del cliente',
'AUTOR : Eduardo Ãvila PÃ©re Tagle',
'Area: Sistemas',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Miguel Angel Mendoza Maldonado',
'Gerente: Victor Hugo SÃ¡nchez Mendoza',
'Fecha: 20/Abril/2024',
'Version: 1.0.0',
'BD: bdinteg',
'Requerimiento: RQM 11 178 CalificaciÃ³n inicial de riesgo de cliente';

CREATE PROCEDURE "informix".sp_consulta_sorteo_2024(pcuenta CHAR(20), ppaginas CHAR(2)) 
RETURNING 
	CHAR(5) AS cCodRet,
	CHAR(45) AS vNomCliente,
	CHAR(20) AS pcuenta,
	CHAR(16) AS vBoleto,
	CHAR(1) AS vGanador,
    CHAR(2) AS ppaginas;

-- DEFINICION DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE iSqlErr						INTEGER;
DEFINE cDia							CHAR(2);
DEFINE cMes							CHAR(2);
DEFINE cAnio						CHAR(4);
DEFINE vCadena_req					CHAR(334);

DEFINE dFecha_Hoy					DATE;
DEFINE dFecha_Max_Procesada			DATE;
DEFINE vMesActualNumero 			INTEGER;
DEFINE vAnioActualNumero 			INTEGER;
DEFINE vNum_cte						CHAR(20);
DEFINE vNum_cte_v					CHAR(20);
DEFINE vcontador					INTEGER;
DEFINE vNombre						CHAR(45);
DEFINE vNum_folio 					CHAR(16);
DEFINE vGanador						CHAR(1);
DEFINE vNombre1						CHAR(26);
DEFINE vNombre2						CHAR(26);
DEFINE vApell_paterno				CHAR(26);
DEFINE vApell_materno				CHAR(26);
DEFINE vLongitud_cadena				INTEGER;
DEFINE vNum_sorteo					INTEGER;
DEFINE vFechaInicio_consulta		DATE;
DEFINE vFechaFinal_consulta			DATE;
DEFINE vNumCuenta_longitud			INTEGER;
DEFINE vNomCliente					CHAR(50);
DEFINE vNum_sorteo_numero			INTEGER;
DEFINE vPaginas                     INTEGER;
DEFINE vRegistrosTotales            INTEGER;
DEFINE vRegistroInicial             INTEGER;
DEFINE vRegistroFinal               INTEGER;
DEFINE vPaginaCompleta              INTEGER;
DEFINE vRegistrosDivididos          DECIMAL(5,2);
DEFINE vLista                       INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet						= "00000";
LET iSqlErr						= 0;
LET cDia						= '';
LET cMes						= '';
LET cAnio						= '';

LET dFecha_Hoy					= MDY('01','01','1900');
LET vCadena_req					= '';
LET dFecha_Max_Procesada		= MDY('01','01','1900');
LET vMesActualNumero 			= 0;
LET vAnioActualNumero 			= 0;
LET vNum_cte					= '';
LET vNum_cte_v					= '';
LET vcontador					= 0;
LET vNombre						= '';
LET vNum_folio 					= '';
LET vGanador					= '';
LET vNombre1					= '';
LET vNombre2					= '';
LET vApell_paterno				= '';
LET vApell_materno				= '';
LET vLongitud_cadena			= 0;

LET vNum_sorteo					= 0;
LET vFechaInicio_consulta		= '';
LET vFechaFinal_consulta		= '';
LET vNumCuenta_longitud			= 0;
LET vNomCliente					= '';
LET vNum_sorteo_numero			= '';
LET vPaginas                    = 0;
LET vRegistrosTotales           = 0;
LET vPaginaCompleta             = 0;
LET vLista                      = 0;
LET vRegistrosDivididos         = 0.0;
LET vRegistroInicial            = 0;
LET vRegistroFinal              = 0;
LET vPaginaCompleta             = 0;

	-- SET DEBUG FILE TO  '/home/e97802948/sp_consulta_folios.out';
	-- TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				--insert into "informix".sac_log_errores_sorteo (codigoError,mensaje,fecha)
				--values (cCodRet,vCadena_req,sysdate);
				RETURN cCodRet, '0', '0', '0', '0', '0';
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		--Consulta que regresa la fecha del dia actual
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".si_fechas
		WHERE empresa = "001";
		
		--Se inicializa la variable dFecha_Max_Procesada con el valor dFecha_Hoy
		LET dFecha_Max_Procesada = dFecha_Hoy;
		
		--Se asignan los valores a las variables cDia,cMes,cAnio, vMesActualCadena

		LET cDia = LPAD(DAY(dFecha_Max_Procesada::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Max_Procesada::DATE), 2, '0'); 
		LET cAnio = LPAD(YEAR(dFecha_Max_Procesada::DATE),4,'0');

		--Se recupera mes en entero para calcular el numero de sorteo y las fechas de publicacion disponibles

		LET vMesActualNumero = cast(cMes as INTEGER);
		LET vAnioActualNumero = cast(cAnio as INTEGER);

		SELECT numsorteo, fecha_inicio, fecha_final
		INTO vNum_sorteo, vFechaInicio_consulta, vFechaFinal_consulta
		FROM "informix".si_sorteo_cat_fechas_premios
		WHERE dFecha_Max_Procesada >= fecha_inicio 
		AND dFecha_Max_Procesada <= fecha_final; 


		--IF vFechaInicio_consulta IS NOT NULL OR vFechaInicio_consulta <> '' THEN
		
		--Se verificara la longitud de la cuenta para consultar el numero de cliente

		LET vNumCuenta_longitud = length(TRIM(REPLACE(pcuenta, ' ', '')));


		IF vNumCuenta_longitud = 16 THEN

            -- Query certificado
			-- Consulta correcta
			SELECT numcliente
			  INTO vNum_cte
			  FROM intercard:"informix".tarjeta
			 WHERE numtarjeta = pcuenta
			   AND codstatustarjeta IN ('ACT','BLO','BLT');

		END IF;

		IF vNumCuenta_longitud = 12 THEN

        	-- Query certificado
			-- esta consulta no aplica para los nÃºmeros de cuentas de credito p nÃºmeros de creditos
			SELECT numcte
			  INTO vNum_cte
			  FROM bdicred:"informix".sd_maecred
			 WHERE num_credito = pcuenta;

		END IF;

		IF vNumCuenta_longitud = 11 THEN

        
        	-- Query certificado
			SELECT num_cte
			  INTO vNum_cte
			  FROM bdicheq:"informix".sc_maechq
			 WHERE cuenta = pcuenta;

			IF vNum_cte = '' OR vNum_cte IS NULL THEN

          		--Query certificado
				SELECT num_cte
				  INTO vNum_cte
				  FROM bdinvers:"informix".sv_maeinv
				 WHERE cuenta = pcuenta;

			END IF;

		END IF;

		IF vNumCuenta_longitud = 9 THEN

			SELECT numcte
			  INTO vNum_cte
			  FROM bdinteg:"informix".si_cliente
			 WHERE numcte = pcuenta;

		END IF;

		IF vNum_cte = '' OR vNum_cte IS NULL THEN
			LET cCodRet = '00002';   -- No se encontrÃ³ informaciÃ³n del cliente
			RETURN cCodRet, '0', '0', '0', '0', '0';

		ELSE

			SELECT nombre1, nombre2, apellido_pa, apellido_ma
			INTO vNombre1, vNombre2, vApell_paterno, vApell_materno
			FROM "informix".si_sorteo_info_cliente
			WHERE num_cliente = vNum_cte; 

			IF vNombre1 = '' 
				OR vNombre1 IS NULL 
				OR vApell_paterno = '' 
				OR vApell_paterno IS NULL THEN

				LET cCodRet = '00002';
				RETURN cCodRet, vNomCliente, pcuenta, vNum_folio, vGanador, ppaginas;
			END IF;

		END IF;

		--Quitar de nombre1 la cadena desde la posicion 2 a la derecha en nombre y sustituir con asterisco

		LET vLongitud_cadena = length(trim(REPLACE(vNombre1, ' ', '')));
		LET vNombre1 = substr(trim(REPLACE(vNombre1, ' ', '')),1,1);
		LET vNombre1 = RPAD(trim(REPLACE(vNombre1, ' ', '')),vLongitud_cadena, '*');

		--Quitar de nombre2 la cadena desde la posicion 2 a la derecha en nombre y sustituir con asterisco
		LET vLongitud_cadena = length(trim(REPLACE(vNombre2, ' ', '')));
		IF vLongitud_cadena > 0 THEN 
			LET vNombre2 = substr(trim(REPLACE(vNombre2, ' ', '')),1,1);
			LET vNombre2 = RPAD(trim(REPLACE(vNombre2, ' ', '')),vLongitud_cadena, '*');
		ENd IF;

		--Quitar de apell_paterno la cadena desde la posicion 2 a la derecha en nombre y sustituir con asterisco
		LET vLongitud_cadena = length(trim(REPLACE(vApell_paterno, ' ', '')));
		LET vApell_paterno = substr(trim(REPLACE(vApell_paterno, ' ', '')),1,1);
		LET vApell_paterno = RPAD(trim(REPLACE(vApell_paterno, ' ', '')),vLongitud_cadena, '*');

		--Quitar de apell_materno la cadena desde la posicion 2 a la derecha en nombre y sustituir con asterisco
		LET vLongitud_cadena = length(trim(REPLACE(vApell_materno, ' ', '')));
		IF vLongitud_cadena > 0 THEN 
			LET vApell_materno = substr(trim(REPLACE(vApell_materno, ' ', '')),1,1);
			LET vApell_materno = RPAD(trim(REPLACE(vApell_materno, ' ', '')),vLongitud_cadena, '*');
		ENd IF;

		-- OPCION 1: Se concatena todo este vacio o no el nombre2 y/o apellido materno

		--LET vNomCliente = vNombre1 || vNombre2 || vApell_paterno || apell_materno;

		-- OPCION 2: Se valida si el nombre2 y el apellido materno existen para hacer el concatenado

		LET vNomCliente = vNombre1;

		-- Validar si existe nombre 2 para concatenarlo con el nombre1
		IF vNombre2 <> '' OR vNombre2 IS NULL THEN
			LET vNomCliente = TRIM(vNomCliente) ||' '||TRIM(vNombre2);
		END IF;

		LET vNomCliente = TRIM(vNomCliente) ||' '||TRIM(vApell_paterno);

		-- Validar si existe apellido paternmo para concatenarlo con el nombre comnpleto del cliente
		IF vApell_materno <> '' OR vApell_materno IS NULL THEN
			LET vNomCliente = TRIM(vNomCliente)||' '||TRIM(vApell_materno);
		END IF;

		-- Se muestran los ultimos 4 digitos del numero de cuenta
		-- obtener pcuenta de tabla si_sorteos_cuentas_participantes 

		-- Calcular el tiempo que se podrÃ¡ mostrar en el micrositio los folios por participante
		LET vNum_sorteo_numero = cast(vNum_sorteo as INTEGER);

		
		/*SELECT num_cuenta
		INTO pcuenta
		FROM "informix".si_sorteos_cuentas_participantes
		WHERE num_cliente = vNum_cte
		LIMIT 1;*/
		
		SELECT num_cliente
			INTO vNum_cte_v
		FROM si_sorteo_folios
		WHERE num_cliente = vNum_cte AND num_sorteo = vNum_sorteo_numero
		LIMIT 1;

	    -- validamos si el cliente tiene participacion en la tabla de sorteos y cuentas participantes
		IF vNum_cte_v = '' OR vNum_cte_v IS NULL THEN
			LET cCodRet = '00004';
			RETURN cCodRet, vNomCliente, '0', '0', '0', '0';
		END IF;


		
		LET pcuenta  = TRIM(pcuenta);
		LET vLongitud_cadena = length(trim(REPLACE(pcuenta, ' ', '')));
		LET pcuenta = LPAD(substr(pcuenta,8,4),vLongitud_cadena,'*');

		-- Calcular el tiempo que se podrÃ¡ mostrar en el micrositio los folios por participante
		--LET vNum_sorteo_numero = cast(vNum_sorteo as INTEGER);

		LET vPaginas = CAST(ppaginas as INT);

		IF vPaginas = 0 THEN

			SELECT COUNT(numero_folio)
			INTO vRegistrosTotales
			FROM si_sorteo_folios
			WHERE num_cliente = vNum_cte AND num_sorteo = vNum_sorteo_numero;

			-- Validamos el nÃºmero de registros que se encontraron
			IF vRegistrosTotales = 0 THEN 
				LET cCodRet = '00005';   -- No se encontraron registros
				RETURN cCodRet, vNomCliente, pcuenta, vNum_folio, vGanador, ppaginas;

			ELSE
				LET vRegistrosDivididos = vRegistrosTotales / 10;

				IF vRegistrosDivididos > 0 THEN
					LET vRegistroFinal = ceil(vRegistrosDivididos);
					RETURN cCodRet, vNomCliente, pcuenta, vNum_folio, vGanador, vRegistroFinal;

				ELSE
					LET cCodRet = '00006';
					RETURN cCodRet, vNomCliente, pcuenta, vNum_folio, vGanador, ppaginas;

				END IF;

			END IF;

		ELSE

			SELECT COUNT(numero_folio)
			  INTO vRegistrosTotales
			  FROM si_sorteo_folios
			 WHERE num_cliente = vNum_cte AND num_sorteo = vNum_sorteo_numero;

			LET vPaginaCompleta = ppaginas * 10;
			LET vLista = vRegistrosTotales - vPaginaCompleta;

			IF vLista < 0 THEN
				LET vRegistroInicial = vPaginaCompleta - 10;
				LET vRegistroFinal = vRegistrosTotales;

			ELSE

				IF vLista = 0 THEN
					LET vRegistroInicial = vPaginaCompleta - 10;
					LET vRegistroFinal = vPaginaCompleta;

				ELSE

					IF vLista > 0 THEN
						LET vRegistroInicial = vPaginaCompleta - 10;
						LET vRegistroFinal = vPaginaCompleta;

					END IF;

				END IF;

			END IF;

		END IF;


			-- ****************************************************************************
			-- * Obtener folios y si fue ganador o no
			-- ****************************************************************************
		IF vFechaInicio_consulta IS NOT NULL OR vFechaInicio_consulta <> '' THEN
			
			FOREACH

				SELECT 
                    SKIP vRegistroInicial LIMIT vRegistroFinal
                    numero_folio, 
					ganador--- Haniamos quedado que esto se mandaria solamente el valor 1 o 0
				INTO vNum_folio, vGanador
				FROM si_sorteo_folios
				WHERE num_cliente = vNum_cte AND num_sorteo = vNum_sorteo_numero
				--WITH resume;

				RETURN cCodRet, vNomCliente, pcuenta, vNum_folio, vGanador, vPaginas WITH RESUME;

			END FOREACH
		
		ELSE

			--Se manda excepcion de que no esta disponible la fecha
			LET cCodRet = '00001';
			RETURN cCodRet, vNomCliente, pcuenta, vNum_folio, vGanador, vPaginas;

		END IF;

	
	END;   -- END DEL BEGIN
END PROCEDURE;