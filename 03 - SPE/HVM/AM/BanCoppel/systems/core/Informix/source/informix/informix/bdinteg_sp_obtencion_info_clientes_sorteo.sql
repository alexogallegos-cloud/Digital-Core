CREATE PROCEDURE "informix".sp_obtencion_info_clientes_sorteo(pNumero CHAR(1))
RETURNING CHAR(5) AS cCod_Ret;
-- DEFINICION DE VARIABLES
DEFINE cCodRet						CHAR(5);
DEFINE iSqlErr						INTEGER;

DEFINE vContadorCuenta				INTEGER;
DEFINE vcontador					INTEGER;
DEFINE vNum_cte						CHAR(20);
DEFINE v_calle 						char(30);
DEFINE v_num_estado					INTEGER;
DEFINE v_num_ciudad					INTEGER;
DEFINE v_cod_postal					char(5);
DEFINE v_numeroextcalle 			char(10);
DEFINE v_numerointcalle				char(10);
DEFINE v_nombre_ciudad				VARCHAR(50);
DEFINE v_apell_paterno      CHAR(30);
DEFINE v_apell_materno      CHAR(30);
DEFINE v_nombre1            CHAR(30);
DEFINE v_nombre2			CHAR(30);
DEFINE v_sucursal 			CHAR(5);
DEFINE v_fecha_alta			DATETIME YEAR TO FRACTION;
DEFINE v_nom_completo		CHAR(50);
DEFINE v_tel_casa			CHAR(12);
DEFINE v_celular			CHAR(12);
DEFINE v_domicilio			CHAR(100);
DEFINE v_cliente_inicial            CHAR(20);
DEFINE v_cliente_final              CHAR(20);
DEFINE v_cte_info_cte				CHAR(20);
DEFINE v_cliente_informacion		CHAR(20);
DEFINE v_estado						CHAR(2);
DEFINE v_des_estado					CHAR(30);
DEFINE v_ciudad						CHAR(3);
DEFINE dFecha_Hoy					DATE;
DEFINE dFecha_Max_Procesada			DATE;
DEFINE cDia							CHAR(2);
DEFINE cMes							CHAR(2);
DEFINE cAnio						CHAR(4);
DEFINE v_numcalle					INTEGER;
--INICIALIZACION DE VARIABLES--
LET cCodRet						= "00000";
LET iSqlErr						= 0;

LET vContadorCuenta				= 0;
LET vcontador					= 0;
LET vNum_cte					= '';
LET v_calle 			        = '';
LET v_num_estado		        = 0;
LET v_num_ciudad		        = 0;
LET v_cod_postal		        = '';
LET v_numeroextcalle 		        = '';
LET v_numerointcalle		        = '';
LET	v_nombre_ciudad					= '';
LET v_apell_paterno                 = '';
LET v_apell_materno                 = '';
LET v_nombre1                       = '';
LET v_nombre2			            = '';
LET v_sucursal 			            = '';
LET v_fecha_alta		            = NULL;
LET v_nom_completo		            = '';
LET v_tel_casa			            = '';
LET v_celular			            = '';
LET v_domicilio						= '';
LET v_cliente_inicial            	= '';
LET v_cliente_final              	= '';
LET v_cte_info_cte					= '';
LET v_cliente_informacion 			= '';
LET v_estado						= '';
LET v_des_estado					= '';
LET v_ciudad						= '';

LET cDia						= '';
LET cMes						= '';
LET cAnio						= '';
LET dFecha_Max_Procesada		= MDY('01','01','1900');
LET v_numcalle					= 0;

	--SET DEBUG FILE TO  '/ifxsif01/sor/sp_obtencion_info_clientes_sorteo.out';
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				/*insert into "informix".sac_log_errores_sorteo (codigoError,mensaje,fecha)
				values (cCodRet,vCadena_req,sysdate);*/
				ROLLBACK WORK;
				RETURN cCodRet;
				
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
--Consulta que regresa la fecha del dia actual
		/*SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".si_fechas
		WHERE empresa = "001";*/
		SELECT fecha_hoy
		INTO dFecha_Hoy
		FROM "informix".si_fechas
		WHERE empresa = "001";
		
--Se inicializa la variable dFecha_Max_Procesada con el valor dFecha_Hoy
		--LET dFecha_Max_Procesada = dFecha_Hoy;
		
--Se asignan los valores a las variables cDia,cMes,cAnio, vMesActualCadena

		LET dFecha_Max_Procesada = EXTEND(dFecha_Hoy, YEAR TO DAY) - 1 UNITS MONTH;

		LET cDia = LPAD(DAY(dFecha_Max_Procesada::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Max_Procesada::DATE), 2, '0'); 
		LET cAnio = LPAD(YEAR(dFecha_Max_Procesada::DATE),4,'0');
		
		LET v_fecha_alta =  LAST_DAY(dFecha_Max_Procesada);
		
		SELECT cliente_inicial, cliente_final, cte_info_cte
			INTO v_cliente_inicial, v_cliente_final, v_cte_info_cte
		FROM "informix".si_sorteo_hilos WHERE numero_proceso = pNumero;

		IF v_cte_info_cte  > '0' THEN
			LET v_cliente_inicial = v_cte_info_cte + 1;
		END IF;

--Se verificara que los clientes cumplan con las reglas para participar

		BEGIN WORK;

			FOREACH WITH HOLD

				SELECT DISTINCT(num_cliente)
				INTO vNum_cte
				FROM "informix".si_sorteos_cuentas_participantes WHERE num_cliente between v_cliente_inicial and v_cliente_final AND mes = cMes --- agregar un disting para que sea por cliente

				--Se obtiene la direccion
				SELECT   estado, ciudad, cod_postal, numeroextcalle, numerointcalle, numerocalle
					into   v_num_estado, v_num_ciudad, v_cod_postal, v_numeroextcalle, v_numerointcalle, v_numcalle
				FROM bdinteg:si_direcciones_actual WHERE tipo_dir = '1' and numcte = vNum_cte;
				
				IF v_num_estado IS NULL OR v_num_estado = '' THEN
					LET v_estado = 'Sin Estado';
				ELSE
					LET v_estado = LPAD(v_num_estado,'2','0');
					SELECT nombre INTO v_des_estado FROM bdinteg:si_estados WHERE estado = v_estado;    
					
					IF v_des_estado IS NULL OR v_des_estado = '' THEN
						LET v_des_estado = 'Sin Estado';
					END IF;
				END IF;
				--EXECUTE PROCEDURE "informix".sp_quitar_acentos(v_calle) INTO v_calle;

				IF v_num_ciudad IS NULL OR v_num_ciudad  = '' THEN
					LET v_nombre_ciudad = 'Sin Ciudad';
				ELSE
					LET v_ciudad = LPAD(v_num_ciudad,'3','0');
					
					SELECT nombre
						INTO v_nombre_ciudad
					FROM bdinteg:si_ciudades WHERe ciudad = v_ciudad and estado = v_estado;
					
					EXECUTE PROCEDURE "informix".sp_quitar_acentos(v_nombre_ciudad) INTO v_nombre_ciudad;
				
					IF v_nombre_ciudad IS NULL OR v_nombre_ciudad = '' THEN
						LET v_nombre_ciudad = 'Sin Ciudad';
					END IF;			
				END IF;
				
				
				IF v_numcalle IS NULL OR v_numcalle = ''then
					LET v_calle ='SC';
				ELSE
					
					SELECT nombrecalle INTO v_calle FROM si_catcalles WHERE numerocalle = v_numcalle;
						
						LET v_calle = trim(v_calle);
				
					IF v_calle IS NULL OR v_calle  = '' THEN
						LET v_calle ='SC';
					
					END IF;
				END IF;
				
				
				
				LET v_numerointcalle  = trim(v_numerointcalle);
				
				
				IF v_numerointcalle IS NULL OR v_numerointcalle = '' THEN
					LET v_numerointcalle = '0';
				END IF;
				
				LET v_numeroextcalle = trim(v_numeroextcalle);
				
				IF v_numeroextcalle IS NULL OR v_numeroextcalle = '' THEN
					LET v_numeroextcalle = '0';
				END IF;
				
				LET v_cod_postal = TRIM(v_cod_postal);
				
				IF v_cod_postal IS NULL OR v_cod_postal = '' THEN
					LET v_cod_postal = '00000';
				END IF;
				
				LET v_domicilio  = TRIM(v_calle)||' NEX '||TRIM(v_numeroextcalle)||' INT '||TRIM(v_numerointcalle)||' CP '||TRIM(v_cod_postal);
				
				EXECUTE PROCEDURE "informix".sp_sorteo_caracteres(v_domicilio) INTO v_domicilio;
				
				IF v_domicilio IS NULL OR  v_domicilio = '' THEN
					LET v_domicilio = 'SIN DIRECCION';
				END IF;
				
				SELECT	apell_paterno, apell_materno, nombre1, nombre2, sucursal--, fecha_alta
					into v_apell_paterno, v_apell_materno, v_nombre1, v_nombre2, v_sucursal--, v_fecha_alta
				FROM bdinteg:si_cliente WHERE numcte = vNum_cte;

				LET v_nom_completo = trim(v_apell_paterno)||' '||trim(v_apell_materno)||' '||trim(v_nombre1)||' '||trim(v_nombre2);
					
					EXECUTE PROCEDURE "informix".sp_quitar_acentos(v_nom_completo) INTO v_nom_completo;
				
				
				SELECT telefono
					into v_tel_casa
				FROM bdinteg:si_telefonos_actual  where numcte = vNum_cte and tipo_tel = '1' and status_tel = 'A';
				
				SELECT telefono
					into v_celular
				FROM bdinteg:si_telefonos_actual  where numcte = vNum_cte and tipo_tel = '2' and status_tel = 'A';
                
				EXECUTE PROCEDURE "informix".sp_sorteo_caracteres(v_celular) INTO v_celular;
				EXECUTE PROCEDURE "informix".sp_sorteo_caracteres(v_tel_casa) INTO v_tel_casa;
				
				IF v_tel_casa  IS NULL OR v_tel_casa = '' Then
					LET v_tel_casa = '0';
				end if;
				
				IF v_celular  IS NULL OR v_celular = '' Then
					LET v_celular = '0';
				end if;
				
								
				SELECT num_cliente INTO v_cliente_informacion FROM  "informix".si_sorteo_info_cliente where num_cliente = vNum_cte;
				
				IF v_cliente_informacion IS NULL OR v_cliente_informacion  = '' THEN
					insert into "informix".si_sorteo_info_cliente(num_cliente, ciudad, sucursal, telefono_casa, num_celular, nombre1, nombre2, apellido_pa, apellido_ma, domicilio, nombre_completo, fecha_alta, des_estado)
					VALUES(vNum_cte, v_nombre_ciudad, v_sucursal, v_tel_casa, v_celular, v_nombre1, v_nombre2, v_apell_paterno, v_apell_materno, v_domicilio, v_nom_completo, v_fecha_alta, v_des_estado);
				ELSE
					UPDATE "informix".si_sorteo_info_cliente SET ciudad = v_nombre_ciudad , sucursal = v_sucursal, telefono_casa = v_tel_casa, 
																 num_celular =  v_celular, nombre1 = v_nombre1, nombre2 = v_nombre2, 
																 apellido_pa = v_apell_paterno, apellido_ma = v_apell_materno, domicilio = v_domicilio, 
																 nombre_completo = v_nom_completo, fecha_alta = v_fecha_alta, des_estado = v_des_estado WHERE num_cliente = vNum_cte;
				END IF;
				
				
				
				LET vcontador = vcontador + 1;
	
				IF vcontador = 1000 THEN
					COMMIT WORK;
						UPDATE "informix".si_sorteo_hilos SET cte_info_cte = vNum_cte where numero_proceso = pNumero;
					LET vcontador = 0;
					BEGIN WORK;
				END IF;
		
			END FOREACH;
		COMMIT WORK;		
			UPDATE "informix".si_sorteo_hilos SET cte_info_cte = '0' where numero_proceso = pNumero;
		RETURN cCodRet;
	
	END;
END PROCEDURE;