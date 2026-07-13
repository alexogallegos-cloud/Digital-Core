CREATE PROCEDURE  "informix".sp_control_cierre_sucursal(p_sucursal_origen CHAR(4), p_sucursal_destino CHAR(4))
RETURNING   CHAR(5) as vcodRet, CHAR(80) as vErrorInfo;

    DEFINE tmp_file_path               VARCHAR(255);  --- Variable para la ruta del archivo
    DEFINE vSQL                        CHAR(800);     --- Variable para la ejecucion de un system
    DEFINE v_cuenta                    CHAR(20);      --- Tipo de dato adecuado para 'cuenta'
    DEFINE v_commit_interval           INT;           --- Control de cuantas iteraciones antes de hacer un commit
    DEFINE v_counter                   INT;           --- Contador de iteraciones
    DEFINE v_no_more_rows              INT;           --- Variable de control para verificar si hay mas filas
    DEFINE cont_sucursal_destino       INT;           --- Variable de numero de sucursal
    DEFINE cont_sucursal_orig          INT;           --- Variable de numero de sucursal
    DEFINE cDescErr                    CHAR(80);
    DEFINE vErrorInfo                  CHAR(80);


    DEFINE anio_actual      	CHAR(4);       --- AÃ±o actual
    DEFINE mes_actual       	CHAR(2);       --- Declara el mes actual
    DEFINE anio_mes		        CHAR(6);
    DEFINE fech_in_anio     	CHAR(15);
    DEFINE vcodRet          	CHAR(5);
    DEFINE cCodRet2         	CHAR(5);
    DEFINE cCodRet3         	CHAR(50);
    DEFINE v_c_vcomienza    	SMALLINT;
    DEFINE ven_transacc     	SMALLINT;
    DEFINE vsqlerr          	INTEGER;
    DEFINE iIsamErr         	SMALLINT;
    DEFINE cErrorInfo       	CHAR(80);
    DEFINE v_sucursal       	CHAR(4);
    DEFINE cUsrBin          	CHAR(100);
    DEFINE cRutaInformix    	CHAR(100);
    DEFINE cCmd1            	CHAR(500);

    DEFINE v_empresa       		CHAR(3);
    DEFINE v_num_cliente   		CHAR(9);
    DEFINE v_ns_token      		VARCHAR(10);


    LET v_commit_interval       =      		   	   100; --- Numero de iteraciones antes de hacer un commit
    LET v_counter               =      		     	 0; --- Inicializacion del contador
    LET v_no_more_rows          =      		     	 0; --- Inicializa el control de filas
    LET v_c_vcomienza           =      		    	-1; --- Se inicializa la variable para abrir un transaccion
    LET ven_transacc            =      		     	 0; --- Valida si existe una tansaccion abierta
    LET vSQL                    =      		   	   ' '; --- Limpia la cadena del SQL
    LET anio_actual             =      		   	   ' '; --- inicializa el valor del aÃ±o en vacio
    LET mes_actual              =      		   	   ' '; --- inicializa el valor del mes en vacio
    LET vsqlerr                 =      		     	 0;
    LET iIsamErr                =      		     	 0;
    LET anio_mes                =      		    	'';
    LET fech_in_anio            =           		'';
    LET vcodRet                 =      	   	   "00000";
    LET cErrorInfo              =           		"";
    LET cUsrBin                 =  	   	   '/usr/bin/';
    LET cRutaInformix           = 	  '/informix/bin/';
    LET cCmd1 					= 					'';
    LET vErrorInfo          	= "INICIO DEL PROCESO";




    BEGIN

        ON EXCEPTION SET vsqlerr, iIsamErr, cDescErr
            SET DEBUG FILE TO "/RESPALDOSNEW/sp_control_cierre_sucursal.err";
            TRACE ON;
            IF vsqlerr <> 0 THEN
                LET vcodRet   = vsqlerr;
                LET vErrorInfo = cErrorInfo;
                IF ven_transacc = 1 THEN
                    ROLLBACK WORK;
                END IF;
                RETURN vcodRet,vErrorInfo;
            END IF;
        END EXCEPTION;

        --- SET DEBUG FILE TO '/resplogifx/conciliachq/sp_control_cierre_sucursal.txt';
        --- SET DEBUG FILE TO '/RESPALDOSNEW/sp_control_cierre_sucursal.out';
        --- TRACE ON;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;


        SELECT count(*)
        INTO cont_sucursal_destino
        FROM si_sucursales
        WHERE sucursal = p_sucursal_origen;

        SELECT count(*)
        INTO cont_sucursal_orig
        FROM si_sucursales
        WHERE sucursal = p_sucursal_origen;

        /*

        IF cont_sucursal_destino = 0 OR p_sucursal_origen IS NULL OR p_sucursal_origen = ''  THEN
            LET vcodRet = '110';
            LET cCodRet3 = 'La sucursal origen esta vacia';
            RETURN vcodRet, cCodRet2, cCodRet3;
        END IF;

        IF cont_sucursal_orig = 0 OR p_sucursal_destino IS NULL OR p_sucursal_destino = '' THEN
            LET vcodRet = '110';
            LET cCodRet3 = 'La sucursal destino esta vacia';
            RETURN vcodRet, cCodRet2, cCodRet3;
        END IF;*/
		
		UPDATE bdicheq:sc_prog_cierre
        SET estatus = '1'
        WHERE origen = p_sucursal_origen
		AND destino = p_sucursal_destino;

        -- Truncar las tablas fisicas
        TRUNCATE TABLE bdicheq:sc_suc_bdicheq_t1;
        TRUNCATE TABLE bdicheq:sc_sucursal_si_bpitoken;
        TRUNCATE TABLE bdicheq:sc_sucursal_si_bm_usuarios;
        TRUNCATE TABLE bdicheq:sc_sucursal_si_bpiusuarios;
        ---TRUNCATE TABLE sc_suc_bdicheq_t2;

        ------------- TODOS LOS CAMPOS SE INICIALIZAR
        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET

            extrae_cuentas = 0,  -- Nuevo valor para el campo extrae_cuentas
            ejecuta_bdicheq = 0,  -- Nuevo valor para ejecuta_bdicheq
            ejecuta_bdibpi = 0,  -- Nuevo valor para ejecuta_bdibpi
            ejecuta_bdicred = 0,  -- Nuevo valor para ejecuta_bdicred
            ejecuta_bdicred_crd = 0,  -- Nuevo valor para ejecuta_bdicred_crd
            ejecuta_bdinteg = 0,  -- Nuevo valor para ejecuta_bdinteg
            ejecuta_bdinvers = 0,  -- Nuevo valor para ejecuta_bdinvers
            ejecuta_bdisolic = 0,  -- Nuevo valor para ejecuta_bdisolic
            ejecuta_bdicheq_comp = 0,  -- Nuevo valor para ejecuta_bdicheq_comp
            sucursal_origen = p_sucursal_origen,  -- Nuevo valor para sucursal_origen
            sucursal_destino = p_sucursal_destino; -- Nuevo valor para sucursal_destino

        ---------------------------------------------------

        ---  Obtiene el mes actual
        select
        Lpad( month(fecha_hoy-1 units day),2,'0'),
        year(fecha_hoy-1 units day)
        INTO mes_actual, anio_actual
        from bdicheq:sc_fechas;

        --- Sacar el anio actual
        select
        year(fecha_hoy-1 units day)
        INTO anio_actual
        from bdicheq:sc_fechas;

        --- Variable de aÃ±o mes  '202501'
        LET anio_mes = anio_actual||'01';

        LET  fech_in_anio = "0101"||anio_actual; ---01012025



        ------------------------------------------------------------
        --------------------------  bdicheq     extrae_cuentas.sql
        ------------------------------------------------------------


        -------------------------------------------------------------- extrear info de la tabla si_bpiusuarios y la carga en la tabla sc_sucursal_si_bpiusuarios



        --------- Descarga la info de la tabla si_bpitoken
        LET vsql = '';
        LET vsql = 'echo "UNLOAD TO /RESPALDOSNEW/descarga_si_bpitoken.txt select * from bdinteg:si_bpitoken where suc_registro = '||p_sucursal_origen||'" > /RESPALDOSNEW/descarga_si_bpitoken.sql "';
        --LET vsql = 'echo "UNLOAD TO /RESPALDOSNEW/Alfredo/descarga_si_bpitoken.txt select * from bdinteg:si_bpitoken where suc_registro = '||p_sucursal_origen||'" > /RESPALDOSNEW/Alfredo/descarga_si_bpitoken.sql "';

        SYSTEM vsql;

        --------- Le da todos los permisos al archivo .sql
        LET vsql = '';
        LET vsql = 'chmod 777 /RESPALDOSNEW/descarga_si_bpitoken.sql';
        --LET vsql = 'chmod 777 /RESPALDOSNEW/Alfredo/descarga_si_bpitoken.sql';
        SYSTEM(vsql);

        -------- Ejecuta el archivo SQL con los registros
        LET vsql = '';
        LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/descarga_si_bpitoken.sql';
        --LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/Alfredo/descarga_si_bpitoken.sql';
        SYSTEM vsql;



        -------- Carga la info de la tabla si_bpitoken
        LET vsql = '';
        LET vsql = 'echo "LOAD FROM /RESPALDOSNEW/descarga_si_bpitoken.txt  DELIMITER ''|'' INSERT INTO bdicheq:sc_sucursal_si_bpitoken" > /RESPALDOSNEW/carga_si_bpitoken.sql';
        --LET vsql = 'echo "LOAD FROM /RESPALDOSNEW/Alfredo/descarga_si_bpitoken.txt  DELIMITER ''|'' INSERT INTO bdicheq:sc_sucursal_si_bpitoken" > /RESPALDOSNEW/Alfredo/carga_si_bpitoken.sql';
        SYSTEM vsql;

        --------- Le da todos los permisos al archivo .sql
        LET vsql = '';
        LET vsql = 'chmod 777 /RESPALDOSNEW/carga_si_bpitoken.sql';
        --LET vsql = 'chmod 777 /RESPALDOSNEW/Alfredo/carga_si_bpitoken.sql';
        SYSTEM(vsql);

        -------- Ejecuta el archivo SQL con los registros
        LET vsql = '';
        LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/carga_si_bpitoken.sql';
        --LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/Alfredo/carga_si_bpitoken.sql';
        SYSTEM vsql;
        LET vsql = '';



        -------------------------------------:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::----------------------------------------



        --------- Descarga la info de la tabla si_bm_usuarios
        LET vsql = '';
        LET vsql = 'echo "UNLOAD TO /RESPALDOSNEW/descarga_si_bm_usuarios.txt select * from bdinteg:si_bm_usuarios where suc_registra = '||p_sucursal_origen||'" > /RESPALDOSNEW/descarga_si_bm_usuarios.sql "';
        --LET vsql = 'echo "UNLOAD TO /RESPALDOSNEW/Alfredo/descarga_si_bm_usuarios.txt select * from bdinteg:si_bm_usuarios where suc_registra = '||p_sucursal_origen||'" > /RESPALDOSNEW/Alfredo/descarga_si_bm_usuarios.sql "';
        SYSTEM vsql;

        --------- Le da todos los permisos al archivo .sql
        LET vsql = '';
        LET vsql = 'chmod 777 /RESPALDOSNEW/descarga_si_bm_usuarios.sql';
        --LET vsql = 'chmod 777 /RESPALDOSNEW/Alfredo/descarga_si_bm_usuarios.sql';
        SYSTEM(vsql);

        -------- Ejecuta el archivo SQL con los registros
        LET vsql = '';
        LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/descarga_si_bm_usuarios.sql';
        --LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/Alfredo/descarga_si_bm_usuarios.sql';
        SYSTEM vsql;


        -------- Carga la info de la tabla si_bm_usuarios
        LET vsql = '';
        LET vsql = 'echo "LOAD FROM /RESPALDOSNEW/descarga_si_bm_usuarios.txt DELIMITER ''|'' INSERT INTO bdicheq:sc_sucursal_si_bm_usuarios" > /RESPALDOSNEW/carga_si_bm_usuarios.sql';
        --LET vsql = 'echo "LOAD FROM /RESPALDOSNEW/Alfredo/descarga_si_bm_usuarios.txt DELIMITER ''|'' INSERT INTO bdicheq:sc_sucursal_si_bm_usuarios" > /RESPALDOSNEW/Alfredo/carga_si_bm_usuarios.sql';
        SYSTEM vsql;

        --------- Le da todos los permisos al archivo .sql
        LET vsql = '';
        LET vsql = 'chmod 777 /RESPALDOSNEW/carga_si_bm_usuarios.sql';
        --LET vsql = 'chmod 777 /RESPALDOSNEW/Alfredo/carga_si_bm_usuarios.sql';
        SYSTEM(vsql);

        -------- Ejecuta el archivo SQL con los registros
        LET vsql = '';
        LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/carga_si_bm_usuarios.sql';
        --LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/Alfredo/carga_si_bm_usuarios.sql';
        SYSTEM vsql;
        LET vsql = '';



        -------------------------------------:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::----------------------------------------




        --------- Descarga la info de la tabla si_bpiusuarios
        LET vsql = '';
        LET vsql = 'echo "UNLOAD TO /RESPALDOSNEW/descarga_si_bpiusuarios.txt select * from bdinteg:si_bpiusuarios where suc_registro = '||p_sucursal_origen||'" > /RESPALDOSNEW/descarga_si_bpiusuarios.sql "';
        --LET vsql = 'echo "UNLOAD TO /RESPALDOSNEW/Alfredo/descarga_si_bpiusuarios.txt select * from bdinteg:si_bpiusuarios where suc_registro = '||p_sucursal_origen||'" > /RESPALDOSNEW/Alfredo/descarga_si_bpiusuarios.sql "';
        SYSTEM vsql;

        --------- Le da todos los permisos al archivo .sql
        LET vsql = '';
        LET vsql = 'chmod 777 /RESPALDOSNEW/descarga_si_bpiusuarios.sql';
        --LET vsql = 'chmod 777 /RESPALDOSNEW/Alfredo/descarga_si_bpiusuarios.sql';
        SYSTEM(vsql);

        -------- Ejecuta el archivo SQL con los registros
        LET vsql = '';
        LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/descarga_si_bpiusuarios.sql';
        --LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/Alfredo/descarga_si_bpiusuarios.sql';
        SYSTEM vsql;


        -------- Carga la info de la tabla si_bpiusuarios
        LET vsql = '';
        LET vsql = 'echo "LOAD FROM /RESPALDOSNEW/descarga_si_bpiusuarios.txt DELIMITER ''|'' INSERT INTO bdicheq:sc_sucursal_si_bpiusuarios" > /RESPALDOSNEW/carga_si_bpiusuarios.sql';
        --LET vsql = 'echo "LOAD FROM /RESPALDOSNEW/Alfredo/descarga_si_bpiusuarios.txt DELIMITER ''|'' INSERT INTO bdicheq:sc_sucursal_si_bpiusuarios" > /RESPALDOSNEW/Alfredo/carga_si_bpiusuarios.sql';
        SYSTEM vsql;

        --------- Le da todos los permisos al archivo .sql
        LET vsql = '';
        LET vsql = 'chmod 777 /RESPALDOSNEW/carga_si_bpiusuarios.sql';
        --LET vsql = 'chmod 777 /RESPALDOSNEW/Alfredo/carga_si_bpiusuarios.sql';
        SYSTEM(vsql);

        -------- Ejecuta el archivo SQL con los registros
        LET vsql = '';
        LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/carga_si_bpiusuarios.sql';
        --LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/Alfredo/carga_si_bpiusuarios.sql';
        SYSTEM vsql;
        LET vsql = '';





        -------------------------------------:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::----------------------------------------


        LET tmp_file_path = '/RESPALDOSNEW/descarga_sc_maechq_'||p_sucursal_origen||'.txt';
        --LET tmp_file_path = '/RESPALDOSNEW/Alfredo/descarga_sc_maechq_'||p_sucursal_origen||'.txt';



        --------- Descarga la info de la tabla sc_maechq
        LET vsql = '';
        LET vsql = 'echo "UNLOAD TO '|| tmp_file_path ||' select cuenta,empresa from bdicheq:sc_maechq where sucursal = '||p_sucursal_origen||'" > /RESPALDOSNEW/descarga_sc_maechq.sql "';
        --LET vsql = 'echo "UNLOAD TO '|| tmp_file_path ||' select cuenta,empresa from bdicheq:sc_maechq where sucursal = '||p_sucursal_origen||'" > /RESPALDOSNEW/Alfredo/descarga_sc_maechq.sql "';
        SYSTEM vsql;

        --------- Le da todos los permisos al archivo .sql
        LET vsql = '';
        LET vsql = 'chmod 777 /RESPALDOSNEW/descarga_sc_maechq.sql';
        --LET vsql = 'chmod 777 /RESPALDOSNEW/Alfredo/descarga_sc_maechq.sql';
        SYSTEM(vsql);

        -------- Ejecuta el archivo SQL con los registros
        LET vsql = '';
        LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/descarga_sc_maechq.sql';
        --LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/Alfredo/descarga_sc_maechq.sql';
        SYSTEM vsql;



        -------- Carga la info de la tabla sc_maechq
        LET vsql = '';
        LET vsql = 'echo "LOAD FROM '|| tmp_file_path ||' DELIMITER ''|'' INSERT INTO bdicheq:sc_suc_bdicheq_t1" > /RESPALDOSNEW/carga_sc_maechq.sql';
        --LET vsql = 'echo "LOAD FROM '|| tmp_file_path ||' DELIMITER ''|'' INSERT INTO bdicheq:sc_suc_bdicheq_t1" > /RESPALDOSNEW/Alfredo/carga_sc_maechq.sql';
        SYSTEM vsql;

        --------- Le da todos los permisos al archivo .sql
        LET vsql = '';
        LET vsql = 'chmod 777 /RESPALDOSNEW/carga_sc_maechq.sql';
        --LET vsql = 'chmod 777 /RESPALDOSNEW/Alfredo/carga_sc_maechq.sql';
        SYSTEM(vsql);

        -------- Ejecuta el archivo SQL con los registros
        LET vsql = '';
        LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/carga_sc_maechq.sql';
        --LET vsql = 'dbaccess bdicheq /RESPALDOSNEW/Alfredo/carga_sc_maechq.sql';
        SYSTEM vsql;
        LET vsql = '';



        -- Fase 2: Crear una tabla fisica para las cuentas con valores nulos
        --    CREATE TABLE sc_suc_bdicheq_t1 (
        ---        cuenta char(20),
        ---        tipo_token char(1) default '1'
        --    );

        ----- ACTUALIZA LA TABLA CONTROL
        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET extrae_cuentas = '1'
        WHERE sucursal_origen = p_sucursal_origen;

        ----------------------------------------------------------------------------------
        ------------------------------------------  bdicheq     ejecuta_bdicheq.sql
        ----------------------------------------------------------------------------------

        -- Fase 4: Cargar las cuentas desde el archivo .unl


        FOREACH WITH HOLD
                SELECT cuenta
                INTO v_cuenta
                FROM bdicheq:sc_suc_bdicheq_t1
                WHERE empresa = '001'

                -- Abre la transaccion
                IF  (v_c_vcomienza = -1) THEN
                    LET v_c_vcomienza = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

                -- Actualiza la tabla para cada cuenta encontrada
                UPDATE informix.sc_maechq
                SET sucursal = p_sucursal_destino
                WHERE cuenta = v_cuenta;

                UPDATE informix.sc_proac
                SET sucursal = p_sucursal_destino
                WHERE cuenta = v_cuenta;

                LET v_counter = v_counter + 1;

                --Realiza commit cada 100 registros
                IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
                END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;

        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET ejecuta_bdicheq = '2'
        WHERE sucursal_origen = p_sucursal_origen;

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ----------------------    bdibpi        ejecuta_bdibpi.sql
        ------------------------------------------------------------------------------------------------------------------------------------------------

        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;


        -- Actualizar bpi_tokensolicitud
        FOREACH WITH HOLD
            SELECT sucursal
            INTO v_sucursal
            FROM bdibpi:bpi_tokensolicitud
            WHERE sucursal = p_sucursal_origen

            -- Abre la transaccion
                IF  (v_c_vcomienza = -1) THEN
                    LET v_c_vcomienza = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

            -- Actualiza la tabla para cada cuenta encontrada
            UPDATE bdibpi:bpi_tokensolicitud
            SET sucursal = p_sucursal_destino
            WHERE sucursal = p_sucursal_origen;

            LET v_counter = v_counter + 1;

            --Realiza commit cada 100 registros
            IF v_counter >= 100 THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;

        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET ejecuta_bdibpi = '3'
        WHERE sucursal_origen = p_sucursal_origen;

        ------------------------------------------------------------------------------------------------------------------------------------------------
        ---------------------   bdicred ejecuta_bdicred.sql
        ------------------------------------------------------------------------------------------------------------------------------------------------


        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;
        LET v_sucursal           =  "0000";

        -- Actualizar sd_maecred
        FOREACH WITH HOLD
            SELECT sucursal
            INTO v_sucursal
            FROM bdicred:sd_maecred
            WHERE sucursal = p_sucursal_origen


            -- Abre la transaccion
            IF  (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;

            -- Actualiza la tabla para cada cuenta encontrada
            UPDATE bdicred:sd_maecred
            SET sucursal = p_sucursal_destino
            WHERE sucursal = p_sucursal_origen;

            LET v_counter = v_counter + 1;

            --Realiza commit cada 100 registros
            IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;


        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;
        LET v_sucursal           =  "0000";

        -- Actualizar sdomensual
        FOREACH WITH HOLD
            SELECT sucursal
            INTO v_sucursal
            FROM bdicred:sd_sdomensual
            WHERE anio = anio_actual
            AND sucursal = p_sucursal_origen

            -- Abre la transaccion
            IF  (v_c_vcomienza = -1) THEN
                LET v_c_vcomienza = 0;
                LET ven_transacc = 1;
                BEGIN WORK;
            END IF;

            -- Actualiza la tabla para cada cuenta encontrada
            UPDATE bdicred:sd_sdomensual
            SET sucursal = p_sucursal_destino
            WHERE anio = anio_actual AND sucursal = p_sucursal_origen;

            LET v_counter = v_counter + 1;

            --Realiza commit cada 5000 registros
            IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;

        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;
        LET v_sucursal           =  "0000";
        -- Actualizar sdodiario


        FOREACH WITH HOLD
                select sucursal
                into v_sucursal
                from  bdicred:sd_sdodiario
                WHERE sucursal = p_sucursal_origen
                AND fecha >=  fech_in_anio

                -- Abre la transaccion
                IF  (v_c_vcomienza = -1) THEN
                    LET v_c_vcomienza = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

                -- Actualiza la tabla para cada cuenta encontrada
                UPDATE bdicred:sd_sdodiario
                SET sucursal = p_sucursal_destino
                WHERE sucursal = p_sucursal_origen
                AND fecha >= fech_in_anio;

                LET v_counter = v_counter + 1;

                --Realiza commit cada 100 registros
                IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
                END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;

        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET ejecuta_bdicred = '4'
        WHERE sucursal_origen = p_sucursal_origen;

        -------------------------------------------------------------------------
        --------------------------------------- bdicred ejecuta_bdicred_crd.sql
        -------------------------------------------------------------------------


        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;
        LET v_sucursal           =  "0000";

        -- Actualizar sd_maecredcrd
        FOREACH WITH HOLD
                SELECT sucursal
                INTO v_sucursal
                FROM bdicred:sd_maecredcrd
                WHERE sucursal = p_sucursal_origen


                -- Abre la transaccion
                IF  (v_c_vcomienza = -1) THEN
                    LET v_c_vcomienza = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

                -- Actualiza la tabla para cada cuenta encontrada
                UPDATE bdicred:sd_maecredcrd
                SET sucursal = p_sucursal_destino
                WHERE sucursal = p_sucursal_origen;

                LET v_counter = v_counter + 1;

                --Realiza commit cada 100 registros
                IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
                END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;



        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;
        LET v_sucursal           =  "0000";

        -- sd_sdodiariocrd
        FOREACH WITH HOLD
                SELECT sucursal
                INTO v_sucursal
                FROM bdicred:sd_sdodiariocrd
                WHERE sucursal = p_sucursal_origen
                and fecha >= fech_in_anio

                -- Abre la transaccion
                IF  (v_c_vcomienza = -1) THEN
                    LET v_c_vcomienza = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

                -- Actualiza la tabla para cada cuenta encontrada
                update bdicred:sd_sdodiariocrd
                set sucursal = p_sucursal_destino
                where sucursal = p_sucursal_origen
                and fecha >= fech_in_anio;  -- '01/01/2025';

                LET v_counter = v_counter + 1;

                --Realiza commit cada 100 registros
                IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
                END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;

        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET ejecuta_bdicred_crd = '5'
        WHERE sucursal_origen = p_sucursal_origen;

        -------------------------------------------------------------------------
        --------------------------------------- bdinteg ejecuta_bdinteg.sql
        -------------------------------------------------------------------------


        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;
        LET v_sucursal           =  "0000";



        -- Actualizar si_cliente
        FOREACH WITH HOLD
                SELECT sucursal
                INTO v_sucursal
                FROM bdinteg:si_cliente
                WHERE sucursal = p_sucursal_origen


                -- Abre la transaccion
                IF  (v_c_vcomienza = -1) THEN
                    LET v_c_vcomienza = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

                -- Actualiza la tabla para cada cuenta encontrada
                UPDATE bdinteg:si_cliente
                SET sucursal = p_sucursal_destino
                WHERE sucursal = p_sucursal_origen;

                LET v_counter = v_counter + 1;

                --Realiza commit cada 5000 registros
                IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
                END IF;

        END FOREACH;


        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;


        -- Actualizar si_ctepm
        BEGIN;
        UPDATE bdinteg:si_ctepm
        SET sucursal = p_sucursal_destino
        WHERE sucursal = p_sucursal_origen;
        COMMIT;


        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;
        LET v_sucursal           =  "0000";


           -- Actualizar si_bpiusuarios
        FOREACH WITH HOLD
                SELECT suc_registro
                INTO v_sucursal
                FROM bdicheq:sc_sucursal_si_bpiusuarios
                WHERE suc_registro = p_sucursal_origen


                -- Abre la transaccion
                IF  (v_c_vcomienza = -1) THEN
                    LET v_c_vcomienza = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

                -- Actualiza la tabla para cada cuenta encontrada
                UPDATE bdinteg:si_bpiusuarios
                SET suc_registro = p_sucursal_destino
                WHERE suc_registro = p_sucursal_origen;

                LET v_counter = v_counter + 1;

                --Realiza commit cada 100 registros
                IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
                END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;


        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;
        LET v_sucursal           =  "0000";


        -- Actualizar si_bm_usuarios
        FOREACH WITH HOLD
                SELECT suc_registra
                INTO v_sucursal
                FROM bdicheq:sc_sucursal_si_bm_usuarios
                WHERE suc_registra = p_sucursal_origen


                -- Abre la transaccion
                IF  (v_c_vcomienza = -1) THEN
                    LET v_c_vcomienza = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

                -- Actualiza la tabla para cada cuenta encontrada
                UPDATE bdinteg:si_bm_usuarios
                SET suc_registra = p_sucursal_destino
                WHERE suc_registra = p_sucursal_origen;

                LET v_counter = v_counter + 1;

                --Realiza commit cada 5000 registros
                IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
                END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;


        BEGIN WORK;
        UPDATE bdinteg:si_bpitoken
        SET suc_registro = p_sucursal_destino
        WHERE suc_registro = p_sucursal_origen;
        COMMIT WORK;


        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET ejecuta_bdinteg = '6'
        WHERE sucursal_origen = p_sucursal_origen;

        -------------------------------------------------------------------------
        --------------------------------------- bdinvers        ejecuta_bdinvers.sql
        -------------------------------------------------------------------------

        -- Actualizar sv_maeinv
        BEGIN;
        UPDATE bdinvers:sv_maeinv
        SET sucursal = p_sucursal_destino
        WHERE sucursal = p_sucursal_origen;
        COMMIT;

        -- Actualizar sv_provdia
        BEGIN;
        UPDATE bdinvers:sv_provdia
        SET sucursal = p_sucursal_destino
        WHERE empresa = '001'
        AND cuenta >= '30000000000'
        AND secuencia >= 1
        AND sucursal = p_sucursal_origen
        AND aniomes >= anio_mes;
        COMMIT;

        -- Actualizar sv_provmes
        BEGIN;
        UPDATE bdinvers:sv_provmes
        SET sucursal = p_sucursal_destino
        WHERE empresa = '001'
        AND cuenta >= '30000000000'
        AND secuencia >= 1
        AND sucursal = p_sucursal_origen
        AND aniomes >= anio_mes;
        COMMIT;

        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET ejecuta_bdinvers = '7'
        WHERE sucursal_origen = p_sucursal_origen;

        -------------------------------------------------------------------------
        --------------------------------------- bdisolic        ejecuta_bdisolic.sql
        -------------------------------------------------------------------------

        -- Actualizar solicitudes
        BEGIN;
        UPDATE bdisolic:ss_solicitudes
        SET sucursal = p_sucursal_destino
        WHERE sucursal = p_sucursal_origen
        AND status_solicitud IN ('AT', 'BC', 'OS', 'EE', 'CE', 'CC', 'OA', 'ST', 'CM', 'MC');
        COMMIT;

        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET ejecuta_bdisolic = 8
        WHERE sucursal_origen = p_sucursal_origen;

        -------------------------------------------------------------------------
        --------------------------------------- bdicheq ejecuta_bdicheq_comp.sql
        -------------------------------------------------------------------------

        -- Fase 6: Operaciones adicionales para cuentas nulas
        --CREATE TABLE sc_suc_bdicheq_t2 (
        ---    cuenta char(20)
        ---);


        --SYSTEM "load from " || tmp_file_path || " insert into bdicheq:sc_suc_bdicheq_t2";


        --- Limpiar variables de foreach
        LET v_c_vcomienza        =      -1;
        LET ven_transacc         =       0;
        LET v_counter            =       0;
        LET v_commit_interval    =     100;
        LET v_cuenta             = '';

        FOREACH WITH HOLD
                SELECT cuenta
                INTO v_cuenta
                FROM bdicheq:sc_suc_bdicheq_t1
                WHERE empresa = '001'


                -- Abre la transaccion
                IF  (v_c_vcomienza = -1) THEN
                    LET v_c_vcomienza = 0;
                    LET ven_transacc = 1;
                    BEGIN WORK;
                END IF;

                -- Actualiza la tabla para cada cuenta encontrada

                -- Actualizar sc_sdodiarioc
                UPDATE bdicheq:sc_sdodiarioc
                SET sucursal = p_sucursal_destino
                WHERE aniomes >= anio_mes
                AND cuenta = v_cuenta;

                -- Actualizar sc_sdo_mensualc

                UPDATE bdicheq:sc_sdomensualc
                SET sucursal = p_sucursal_destino
                WHERE anio = anio_actual
                AND cuenta = v_cuenta;

                -- Actualizar sc_sdotrimestralc

                UPDATE bdicheq:sc_sdotrimestralc
                SET sucursal = p_sucursal_destino
                WHERE anio = anio_actual
                AND cuenta = v_cuenta;

                -- Actualizar sc_indicadores

                UPDATE bdicheq:sc_indicadores
                SET sucursal_apertura = p_sucursal_destino
                WHERE cuenta = v_cuenta;


                LET v_counter = v_counter + 1;

                --Realiza commit cada 100 registros
                IF v_counter >= v_commit_interval THEN
                LET v_counter = 0;
                COMMIT WORK;
                BEGIN WORK;
                END IF;

        END FOREACH;

        --Si la transaccion esta abierta realiza el commit
        IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;

        UPDATE bdicheq:sc_ctrl_cierre_suc
        SET ejecuta_bdicheq_comp = '9'
        WHERE sucursal_origen = p_sucursal_origen;

        -- Opcional: Eliminar las tablas fisicas si no se van a usar mas
        -- DROP TABLE sc_suc_bdicheq_t1;
        -- DROP TABLE sc_suc_bdicheq_t2;

        RETURN vcodRet,vErrorInfo;

    END;

END PROCEDURE;