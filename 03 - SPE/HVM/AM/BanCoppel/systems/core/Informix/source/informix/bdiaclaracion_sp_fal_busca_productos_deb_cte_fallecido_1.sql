CREATE PROCEDURE "informix".sp_fal_busca_productos_deb_cte_fallecido_1(p_sNumeroCliente CHAR(20))

     RETURNING  
                        CHAR(6) AS numeroProducto,
                        CHAR(60) AS nombreProducto, 
                        CHAR(30) AS numeroCuenta, 
                        CHAR(30) AS estatus , 
                        CHAR(100) AS motivo,
                        MONEY(16)   AS montoActual,
                        CHAR(30) AS numeroCuentaDeposito,
                        CHAR(30) AS fechaVenc;

    --definicion de variables--     
    DEFINE resultado_numeroProducto CHAR(6);
    DEFINE resultado_nombreProducto     CHAR(60);
    DEFINE resultado_numeroCuenta       CHAR(30);
    DEFINE resultado_estatus                CHAR(30);
    DEFINE resultado_motivo                 CHAR(100);
    DEFINE resultado_montoActual           MONEY(16);
    DEFINE resultado_cuentaDeposito          CHAR(30);
    DEFINE resultado_fechaVenc               CHAR(30);
    DEFINE iSqlErr                                INTEGER;
    
     -- Inicializacion de las variables.
    LET resultado_numeroProducto ='';
    LET resultado_nombreProducto = '';
    LET resultado_numeroCuenta = '';
    LET resultado_estatus = '';
    LET resultado_motivo = '';
    LET resultado_montoActual = 0;
    LET resultado_cuentaDeposito = '';
    LET resultado_fechaVenc = '';
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	        
    BEGIN

        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET resultado_numeroProducto = '';
                LET resultado_nombreProducto = '';
                LET resultado_numeroCuenta = '';
                LET resultado_estatus = '';
                LET resultado_motivo = '';
                LET resultado_montoActual = 0;
                RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc;
            END IF;
        END EXCEPTION;

        FOREACH

                SELECT DISTINCT qc.producto as numeroProducto, 
                pr.nombre AS nombreProducto,
                        qc. cuenta AS cuentaProducto,
                        --qc.status_cta as estatus,
                        stc.descripcion as estatus,
                        bl.descripcion as motivo,
                        qc.sdo_actual,
                        mae.cuentadep as cuentaDeposito ,
                        vin.fecha_vencimiento as fechaDepostio
                        INTO resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta, resultado_estatus,resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc
                        FROM bdicheq:sc_maechq qc
                        LEFT JOIN bdicheq:"informix".sc_bloqueo bl ON (qc.motivo = bl.codigo)
                        LEFT JOIN bdicheq:"informix".sc_producto pr ON (qc.producto = pr.producto ) 
                        LEFT JOIN fal_cat_estatus_cuenta stc ON (qc.status_cta = stc.pky_estatus_cuenta )
                        LEFT JOIN bdicheq:"informix".sc_maeinstrucc mae ON (qc.cuenta = mae.cuenta )  
                        LEFT JOIN bdicheq:"informix".sc_vencinvpag vin ON (vin.numcta = mae.cuenta )
                        INNER JOIN bdicheq:"informix".sc_maechq cd ON cd.cuenta = mae.cuentadep
                        INNER JOIN fal_control_tramite con ON con.cuenta_cliente_fallecido = qc.cuenta
                        WHERE qc.num_cte = p_sNumeroCliente 
                        AND cd.status_cta not in( 2)
                        AND qc.status_cta = 2
                        AND pr.producto = '1100'


                        RETURN resultado_numeroProducto,resultado_nombreProducto, resultado_numeroCuenta ,resultado_estatus, resultado_motivo,resultado_montoActual,resultado_cuentaDeposito,resultado_fechaVenc WITH RESUME;

        END FOREACH;
    END
END PROCEDURE
DOCUMENT
'Sistema		:	Aclaraciones',
'CreaciÃ³n		:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'FECHA			: 	Septiembre/2018',
'Requerimiento	:	RQM 06 279',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

CREATE PROCEDURE "informix".sp_mueve_aclaraciones_historico_pendiente()

RETURNING CHAR(5);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE v_pky_aclaracion CHAR(20);
DEFINE icontador        INTEGER;
DEFINE v_folio_csuac    VARCHAR(11);
DEFINE v_sol_eglobal    INTEGER;
DEFINE v_res_eglobal    INTEGER;
DEFINE v_fecha_limit    DATE;
DEFINE vsql	        	char(3000);
Define cCadena 			CHAR(1000);
DEFINE respuesta_repetida_e_global	INTEGER;
DEFINE solicitud_faltante_e_global	INTEGER;
DEFINE cRuta CHAR(100);
DEFINE horaActual     datetime year to fraction;
DEFINE horafinal     datetime year to fraction;
DEFINE v_pky_movimiento CHAR(20);
DEFINE v_pky_movimiento2 CHAR(20);
DEFINE v_pky_bitacora CHAR(20);
DEFINE v_resul_mov INTEGER;

LET v_resul_mov = NULL;
LET scod_ret  = "00000";
LET vsqlerr = 0;
LET icontador=1;
		--SET DEBUG FILE TO "/ifxsif01/reydavid/mover.out";
		--TRACE ON;
		
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_2') THEN
			DROP TABLE "informix".temp_mov_2;
		END IF;
--Verificar tabla fisica
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_bitacora') THEN
			DROP TABLE "informix".temp_bitacora;
		END IF;
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov') THEN
			DROP TABLE "informix".temp_mov;
		END IF;
--Verificar tabla fisica
		IF EXISTS( SELECT * FROM systables WHERE tabname ='temp_mov_3') THEN
			DROP TABLE "informix".temp_mov_3;
		END IF;

	CREATE /*TEMP*/ table temp_mov(
		pky_movimiento    integer,
		fky_padre integer);
---	CREATE /*TEMP*/ table temp_mov_2(
--		pky_movimiento    integer);
--	CREATE /*TEMP*/ table temp_mov_3(
--		pky_movimiento   integer,
--		fky_padre integer);
	CREATE /*TEMP*/ table temp_bitacora(
		pky_bitacora   integer);

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
	   LET scod_ret=vsqlerr;
	   ROLLBACK WORK;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;


			INSERT INTO temp_bitacora		
			select pky_bitacora from "informix".acl_sistema_bitacora_his;
----------------
			INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is not null order by fky_padre asc; 
			--fky_padre is not null;
			INSERT INTO temp_mov
			SELECT pky_movimiento,fky_padre
			FROM "informix".acl_movimiento_his where (fky_aclaracion in(select pky_aclaracion from temp_aclara) or folio_csuac in(select folio_csuac from temp_aclara where folio_csuac is not null)) and fky_padre is null order by pky_movimiento asc;
			--fky_padre is null;
			
			INSERT INTO temp_mov
			SELECT pky_movimiento, fky_padre
			FROM "informix".acl_movimiento_his where fky_aclaracion is null and folio_csuac is null and fechahora <= (select last_day(add_months(((today) - 1 units year),-(month(today)))) from bdinteg:"informix".si_fechas where empresa=001)  order by pky_movimiento asc;
		
FOREACH WITH HOLD
			
			select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
			from temp_aclara 
		BEGIN WORK;	
			INSERT INTO "informix".acl_documento_his 
			select * from "informix".acl_documento WHERE fky_aclaracion =v_pky_aclaracion and folio_csuac = v_folio_csuac;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion, folio_csuac
			into v_pky_aclaracion,v_folio_csuac
			from temp_aclara
		BEGIN WORK;	
        		 --********************Eliminacion de historico en entrada bitacora
			delete from "informix".acl_entrada_bitacora WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_documento WHERE  fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico en documentos
			delete from "informix".acl_recuperacion_saldos WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de solicitud E-GALOBAL
			--********************Eliminacion de historico de control de aclaraciones via telefonica
			delete from "informix".acl_control_aclaracion_tel WHERE fky_aclaracion = v_pky_aclaracion;
			--********************Eliminacion de historico de regulatorio 27
			delete from "informix".acl_regulatorio27 WHERE folio_csuac = v_folio_csuac;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov where fky_padre is not null --order by pky_movimiento desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			UPDATE "informix".acl_movimiento SET fky_padre = NULL WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_movimiento
			into v_pky_movimiento
			from temp_mov order by fky_padre desc
		BEGIN WORK;	
			LET v_resul_mov = v_pky_movimiento;
			--********************Eliminacion de historico en movimiento
			delete from "informix".acl_movimiento WHERE pky_movimiento = v_pky_movimiento;
			LET v_resul_mov = NULL;
		COMMIT WORK;
END FOREACH;


FOREACH WITH HOLD		
			select pky_solicitud_e_global
			into v_sol_eglobal
			from temp_solic
		BEGIN WORK;	
			--********************Eliminacion de historico de Solicitud E-GALOBAL
			delete from "informix".acl_solicitud_e_global WHERE pky_solicitud_e_global = v_sol_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD		
			select pky_respuesta_e_global
			into v_res_eglobal
			from temp_respues
		BEGIN WORK;	
    	--********************Eliminacion de historico de respuesta E-GALOBAL
			delete from "informix".acl_respuesta_e_global WHERE pky_respuesta_e_global = v_res_eglobal;
		COMMIT WORK;
END FOREACH;

FOREACH WITH HOLD
			
			select pky_aclaracion
			into v_pky_aclaracion
			from temp_aclara
		BEGIN WORK;	
		---********* Se elimina la informacion principal de aclaraciones********
			delete from "informix".acl_aclaracion WHERE  pky_aclaracion = v_pky_aclaracion;
		COMMIT WORK;
END FOREACH;
			
FOREACH WITH HOLD
			select pky_bitacora
			into v_pky_bitacora
			from temp_bitacora
		BEGIN WORK;		
			--------------------Elimina historico del bitacora del sistema----------------------
			delete from "informix".acl_sistema_bitacora WHERE pky_bitacora = v_pky_bitacora;
		COMMIT WORK;
END FOREACH;

RETURN scod_ret;
END
END PROCEDURE;